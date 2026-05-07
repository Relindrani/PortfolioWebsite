package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type outboxEvent struct {
	OutboxEventID string    `db:"outbox_event_id"`
	EventID       string    `db:"event_id"`
	Type          string    `db:"type"`
	Source        string    `db:"source"`
	Subject       string    `db:"subject"`
	CorrelationID string    `db:"correlation_id"`
	Payload       *string   `db:"payload"`
	OccurredAtUTC time.Time `db:"occurred_at_utc"`
	AttemptCount  int       `db:"attempt_count"`
}

type processor struct {
	db           *pgxpool.Pool
	pollInterval time.Duration
	batchSize    int
	rulesPath    string
}

type decisionInput struct {
	EventID       string  `json:"eventId"`
	SignalType    string  `json:"signalType"`
	Source        string  `json:"source"`
	Subject       string  `json:"subject"`
	CorrelationID string  `json:"correlationId"`
	Payload       *string `json:"payload"`
}

type decisionResult struct {
	Decision   string   `json:"decision"`
	Outcome    string   `json:"outcome"`
	Confidence float64  `json:"confidence"`
	Reasons    []string `json:"reasons"`
}

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	connectionString := getenv("HELIOS_POSTGRES_DSN", "postgres://helios:helios@localhost:5432/helios?sslmode=disable")
	pool, err := pgxpool.New(ctx, connectionString)
	if err != nil {
		log.Fatalf("create postgres pool: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("ping postgres: %v", err)
	}

	worker := processor{
		db:           pool,
		pollInterval: getDuration("HELIOS_OUTBOX_POLL_INTERVAL", 5*time.Second),
		batchSize:    getInt("HELIOS_OUTBOX_BATCH_SIZE", 10),
		rulesPath:    getenv("HELIOS_RULES_ENGINE_PATH", "/app/helios_rules"),
	}

	log.Printf("Helios Event Processor running. poll_interval=%s batch_size=%d", worker.pollInterval, worker.batchSize)
	if err := worker.run(ctx); err != nil && !errors.Is(err, context.Canceled) {
		log.Fatalf("event processor stopped: %v", err)
	}
}

func (p processor) run(ctx context.Context) error {
	ticker := time.NewTicker(p.pollInterval)
	defer ticker.Stop()

	for {
		processed, err := p.processBatch(ctx)
		if err != nil {
			log.Printf("process outbox batch: %v", err)
		} else if processed == 0 {
			log.Println("No pending outbox events.")
		}

		select {
		case <-ctx.Done():
			log.Println("Helios Event Processor shutting down.")
			return ctx.Err()
		case <-ticker.C:
		}
	}
}

func (p processor) processBatch(ctx context.Context) (int, error) {
	tx, err := p.db.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return 0, err
	}
	defer tx.Rollback(ctx)

	rows, err := tx.Query(ctx, `
		select
			outbox_event_id,
			event_id,
			type,
			source,
			subject,
			correlation_id,
			payload,
			occurred_at_utc,
			attempt_count
		from outbox_events
		where processed_at_utc is null
		order by occurred_at_utc
		limit $1
		for update skip locked;
	`, p.batchSize)
	if err != nil {
		return 0, err
	}

	events, err := pgx.CollectRows(rows, pgx.RowToStructByName[outboxEvent])
	if err != nil {
		return 0, err
	}

	for _, event := range events {
		if err := p.handleEvent(ctx, tx, event); err != nil {
			if markErr := p.markFailed(ctx, tx, event, err); markErr != nil {
				return 0, markErr
			}
			continue
		}

		if err := p.markProcessed(ctx, tx, event); err != nil {
			return 0, err
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return 0, err
	}

	return len(events), nil
}

func (p processor) handleEvent(ctx context.Context, tx pgx.Tx, event outboxEvent) error {
	switch event.Type {
	case "SignalRecorded":
		log.Printf(
			"Processing SignalRecorded event_id=%s source=%s subject=%s correlation_id=%s",
			event.EventID,
			event.Source,
			event.Subject,
			event.CorrelationID,
		)

		decision, err := p.evaluateSignal(ctx, tx, event)
		if err != nil {
			return err
		}

		if err := p.persistDecision(ctx, tx, event, decision); err != nil {
			return err
		}

		log.Printf(
			"DecisionEvaluated source_event_id=%s decision=%s outcome=%s",
			event.EventID,
			decision.Decision,
			decision.Outcome,
		)
		return nil
	default:
		log.Printf("Skipping unknown outbox event type=%s event_id=%s", event.Type, event.EventID)
		return nil
	}
}

func (p processor) evaluateSignal(ctx context.Context, tx pgx.Tx, event outboxEvent) (decisionResult, error) {
	input := decisionInput{
		EventID:       event.EventID,
		Source:        event.Source,
		Subject:       event.Subject,
		CorrelationID: event.CorrelationID,
		Payload:       event.Payload,
	}

	if err := tx.QueryRow(ctx, `
		select type
		from signals
		where ('evt_' || replace(signal_id::text, '-', '')) = $1;
	`, event.EventID).Scan(&input.SignalType); err != nil {
		return decisionResult{}, fmt.Errorf("load signal type for %s: %w", event.EventID, err)
	}

	inputJSON, err := json.Marshal(input)
	if err != nil {
		return decisionResult{}, err
	}

	command := exec.CommandContext(ctx, p.rulesPath, string(inputJSON))
	var stderr bytes.Buffer
	command.Stderr = &stderr

	output, err := command.Output()
	if err != nil {
		return decisionResult{}, fmt.Errorf("rules engine failed: %w: %s", err, stderr.String())
	}

	var decision decisionResult
	if err := json.Unmarshal(bytes.TrimSpace(output), &decision); err != nil {
		return decisionResult{}, fmt.Errorf("decode rules engine output: %w", err)
	}

	return decision, nil
}

func (p processor) persistDecision(ctx context.Context, tx pgx.Tx, event outboxEvent, decision decisionResult) error {
	reasonsJSON, err := json.Marshal(decision.Reasons)
	if err != nil {
		return err
	}

	_, err = tx.Exec(ctx, `
		insert into decision_evaluations (
			decision_evaluation_id,
			source_event_id,
			signal_type,
			source,
			subject,
			correlation_id,
			decision,
			outcome,
			confidence,
			reasons,
			evaluated_at_utc
		)
		values (
			$1,
			$2,
			(select type from signals where ('evt_' || replace(signal_id::text, '-', '')) = $2),
			$3,
			$4,
			$5,
			$6,
			$7,
			$8,
			$9::jsonb,
			now()
		)
		on conflict (source_event_id) do update
		set decision = excluded.decision,
			outcome = excluded.outcome,
			confidence = excluded.confidence,
			reasons = excluded.reasons,
			evaluated_at_utc = excluded.evaluated_at_utc;
	`,
		event.OutboxEventID,
		event.EventID,
		event.Source,
		event.Subject,
		event.CorrelationID,
		decision.Decision,
		decision.Outcome,
		decision.Confidence,
		string(reasonsJSON),
	)
	return err
}

func (p processor) markProcessed(ctx context.Context, tx pgx.Tx, event outboxEvent) error {
	_, err := tx.Exec(ctx, `
		update outbox_events
		set processed_at_utc = now(),
			attempt_count = attempt_count + 1
		where outbox_event_id = $1;
	`, event.OutboxEventID)
	return err
}

func (p processor) markFailed(ctx context.Context, tx pgx.Tx, event outboxEvent, processErr error) error {
	log.Printf("Failed processing event_id=%s: %v", event.EventID, processErr)
	_, err := tx.Exec(ctx, `
		update outbox_events
		set attempt_count = attempt_count + 1
		where outbox_event_id = $1;
	`, event.OutboxEventID)
	return err
}

func getenv(key string, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	return value
}

func getInt(key string, fallback int) int {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	parsed, err := strconv.Atoi(value)
	if err != nil || parsed < 1 {
		return fallback
	}

	return parsed
}

func getDuration(key string, fallback time.Duration) time.Duration {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	parsed, err := time.ParseDuration(value)
	if err != nil {
		return fallback
	}

	return parsed
}
