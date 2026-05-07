# Helios Event Processor

This Go service consumes durable domain events from the Core API outbox.

Current responsibilities:

- poll PostgreSQL `outbox_events`
- claim unprocessed events with `FOR UPDATE SKIP LOCKED`
- process `SignalRecorded` events
- call the Rust rules engine for deterministic evaluation
- persist decision results in `decision_evaluations`
- mark events processed after successful handling

This service coordinates background work. Deterministic business decisions belong
in the Rust rules engine; this processor only invokes that boundary and stores
the result.

## Configuration

- `HELIOS_POSTGRES_DSN`
- `HELIOS_OUTBOX_POLL_INTERVAL`
- `HELIOS_OUTBOX_BATCH_SIZE`
- `HELIOS_RULES_ENGINE_PATH`
