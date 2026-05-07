using Helios.Api.Models;
using Npgsql;
using NpgsqlTypes;

namespace Helios.Api.Services;

public sealed class PostgresSignalIngestionService(NpgsqlDataSource dataSource) : ISignalIngestionService
{
    public async Task<SignalRecordedResponse> RecordSignalAsync(
        SignalSubmissionRequest request,
        string idempotencyKey,
        CancellationToken cancellationToken)
    {
        var signalId = Guid.NewGuid();
        var recordedAtUtc = DateTimeOffset.UtcNow;
        var source = request.Source.Trim();
        var type = request.Type.Trim();
        var subject = request.Subject.Trim();
        var payload = string.IsNullOrWhiteSpace(request.Payload) ? null : request.Payload;
        var correlationId = string.IsNullOrWhiteSpace(request.CorrelationId)
            ? signalId.ToString("N")
            : request.CorrelationId.Trim();

        await using var connection = await dataSource.OpenConnectionAsync(cancellationToken);
        await using var transaction = await connection.BeginTransactionAsync(cancellationToken);

        var insertedSignal = await TryInsertSignalAsync(
            connection,
            transaction,
            signalId,
            idempotencyKey,
            source,
            type,
            subject,
            payload,
            correlationId,
            recordedAtUtc,
            cancellationToken);

        if (insertedSignal is not null)
        {
            await InsertOutboxEventAsync(
                connection,
                transaction,
                insertedSignal,
                cancellationToken);

            await transaction.CommitAsync(cancellationToken);
            return ToRecordedResponse(insertedSignal, wasDuplicate: false);
        }

        var existingSignal = await GetSignalByIdempotencyKeyAsync(
            connection,
            transaction,
            idempotencyKey,
            cancellationToken);

        await transaction.CommitAsync(cancellationToken);
        return ToRecordedResponse(existingSignal, wasDuplicate: true);
    }

    public async Task<SignalDetailResponse?> GetSignalAsync(
        Guid signalId,
        CancellationToken cancellationToken)
    {
        await using var connection = await dataSource.OpenConnectionAsync(cancellationToken);
        await using var command = connection.CreateCommand();
        command.CommandText = """
            select signal_id, idempotency_key, source, type, subject, payload, correlation_id, recorded_at_utc
            from signals
            where signal_id = @signal_id;
            """;
        command.Parameters.AddWithValue("signal_id", signalId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        return await reader.ReadAsync(cancellationToken)
            ? ReadSignal(reader)
            : null;
    }

    public async Task<IReadOnlyList<SignalDetailResponse>> GetRecentSignalsAsync(
        int take,
        CancellationToken cancellationToken)
    {
        var boundedTake = Math.Clamp(take, 1, 100);

        await using var connection = await dataSource.OpenConnectionAsync(cancellationToken);
        await using var command = connection.CreateCommand();
        command.CommandText = """
            select signal_id, idempotency_key, source, type, subject, payload, correlation_id, recorded_at_utc
            from signals
            order by recorded_at_utc desc
            limit @take;
            """;
        command.Parameters.AddWithValue("take", boundedTake);

        var signals = new List<SignalDetailResponse>();
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            signals.Add(ReadSignal(reader));
        }

        return signals;
    }

    private static async Task<SignalDetailResponse?> TryInsertSignalAsync(
        NpgsqlConnection connection,
        NpgsqlTransaction transaction,
        Guid signalId,
        string idempotencyKey,
        string source,
        string type,
        string subject,
        string? payload,
        string correlationId,
        DateTimeOffset recordedAtUtc,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = """
            insert into signals (
                signal_id,
                idempotency_key,
                source,
                type,
                subject,
                payload,
                correlation_id,
                recorded_at_utc
            )
            values (
                @signal_id,
                @idempotency_key,
                @source,
                @type,
                @subject,
                @payload,
                @correlation_id,
                @recorded_at_utc
            )
            on conflict (idempotency_key) do nothing
            returning signal_id, idempotency_key, source, type, subject, payload, correlation_id, recorded_at_utc;
            """;

        AddSignalParameters(
            command,
            signalId,
            idempotencyKey,
            source,
            type,
            subject,
            payload,
            correlationId,
            recordedAtUtc);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        return await reader.ReadAsync(cancellationToken)
            ? ReadSignal(reader)
            : null;
    }

    private static async Task<SignalDetailResponse> GetSignalByIdempotencyKeyAsync(
        NpgsqlConnection connection,
        NpgsqlTransaction transaction,
        string idempotencyKey,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = """
            select signal_id, idempotency_key, source, type, subject, payload, correlation_id, recorded_at_utc
            from signals
            where idempotency_key = @idempotency_key;
            """;
        command.Parameters.AddWithValue("idempotency_key", idempotencyKey);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return ReadSignal(reader);
        }

        throw new InvalidOperationException("Expected existing signal was not found.");
    }

    private static async Task InsertOutboxEventAsync(
        NpgsqlConnection connection,
        NpgsqlTransaction transaction,
        SignalDetailResponse signal,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = """
            insert into outbox_events (
                outbox_event_id,
                event_id,
                type,
                source,
                subject,
                correlation_id,
                payload,
                occurred_at_utc,
                processed_at_utc,
                attempt_count,
                created_at_utc
            )
            values (
                @outbox_event_id,
                @event_id,
                @type,
                @source,
                @subject,
                @correlation_id,
                @payload,
                @occurred_at_utc,
                null,
                0,
                @created_at_utc
            )
            on conflict (event_id) do nothing;
            """;

        command.Parameters.AddWithValue("outbox_event_id", Guid.NewGuid());
        command.Parameters.AddWithValue("event_id", signal.Event.EventId);
        command.Parameters.AddWithValue("type", signal.Event.Type);
        command.Parameters.AddWithValue("source", signal.Event.Source);
        command.Parameters.AddWithValue("subject", signal.Event.Subject);
        command.Parameters.AddWithValue("correlation_id", signal.Event.CorrelationId);
        command.Parameters.AddWithValue(
            "payload",
            NpgsqlDbType.Text,
            signal.Payload is null ? DBNull.Value : signal.Payload);
        command.Parameters.AddWithValue("occurred_at_utc", signal.Event.OccurredAtUtc);
        command.Parameters.AddWithValue("created_at_utc", DateTimeOffset.UtcNow);

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static void AddSignalParameters(
        NpgsqlCommand command,
        Guid signalId,
        string idempotencyKey,
        string source,
        string type,
        string subject,
        string? payload,
        string correlationId,
        DateTimeOffset recordedAtUtc)
    {
        command.Parameters.AddWithValue("signal_id", signalId);
        command.Parameters.AddWithValue("idempotency_key", idempotencyKey);
        command.Parameters.AddWithValue("source", source);
        command.Parameters.AddWithValue("type", type);
        command.Parameters.AddWithValue("subject", subject);
        command.Parameters.AddWithValue(
            "payload",
            NpgsqlDbType.Text,
            payload is null ? DBNull.Value : payload);
        command.Parameters.AddWithValue("correlation_id", correlationId);
        command.Parameters.AddWithValue("recorded_at_utc", recordedAtUtc);
    }

    private static SignalDetailResponse ReadSignal(NpgsqlDataReader reader)
    {
        var signalId = reader.GetGuid(0);
        var idempotencyKey = reader.GetString(1);
        var source = reader.GetString(2);
        var type = reader.GetString(3);
        var subject = reader.GetString(4);
        var payload = reader.IsDBNull(5) ? null : reader.GetString(5);
        var correlationId = reader.GetString(6);
        var recordedAtUtc = reader.GetFieldValue<DateTimeOffset>(7);

        return new SignalDetailResponse(
            SignalId: signalId,
            IdempotencyKey: idempotencyKey,
            Source: source,
            Type: type,
            Subject: subject,
            Payload: payload,
            CorrelationId: correlationId,
            RecordedAtUtc: recordedAtUtc,
            Event: new DomainEventEnvelope(
                EventId: $"evt_{signalId:N}",
                Type: "SignalRecorded",
                Source: source,
                Subject: subject,
                CorrelationId: correlationId,
                OccurredAtUtc: recordedAtUtc));
    }

    private static SignalRecordedResponse ToRecordedResponse(
        SignalDetailResponse signal,
        bool wasDuplicate)
    {
        return new SignalRecordedResponse(
            SignalId: signal.SignalId,
            IdempotencyKey: signal.IdempotencyKey,
            Status: "Recorded",
            WasDuplicate: wasDuplicate,
            RecordedAtUtc: signal.RecordedAtUtc,
            Event: signal.Event);
    }
}
