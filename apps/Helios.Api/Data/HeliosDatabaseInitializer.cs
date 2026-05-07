using Npgsql;

namespace Helios.Api.Data;

public sealed class HeliosDatabaseInitializer(
    NpgsqlDataSource dataSource,
    ILogger<HeliosDatabaseInitializer> logger) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await using var connection = await dataSource.OpenConnectionAsync(cancellationToken);
        await using var command = connection.CreateCommand();
        command.CommandText = """
            create table if not exists signals (
                signal_id uuid primary key,
                idempotency_key text not null unique,
                source text not null,
                type text not null,
                subject text not null,
                payload text null,
                correlation_id text not null,
                recorded_at_utc timestamptz not null
            );

            create table if not exists outbox_events (
                outbox_event_id uuid primary key,
                event_id text not null unique,
                type text not null,
                source text not null,
                subject text not null,
                correlation_id text not null,
                payload text null,
                occurred_at_utc timestamptz not null,
                processed_at_utc timestamptz null,
                attempt_count integer not null default 0,
                created_at_utc timestamptz not null
            );

            create index if not exists ix_outbox_events_unprocessed
                on outbox_events (occurred_at_utc)
                where processed_at_utc is null;

            create table if not exists decision_evaluations (
                decision_evaluation_id uuid primary key,
                source_event_id text not null unique,
                signal_type text not null,
                source text not null,
                subject text not null,
                correlation_id text not null,
                decision text not null,
                outcome text not null,
                confidence double precision not null,
                reasons jsonb not null,
                evaluated_at_utc timestamptz not null
            );
            """;

        await command.ExecuteNonQueryAsync(cancellationToken);
        logger.LogInformation("Helios database schema is ready.");
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}
