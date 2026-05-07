namespace Helios.Api.Models;

public sealed record SignalRecordedResponse(
    Guid SignalId,
    string IdempotencyKey,
    string Status,
    bool WasDuplicate,
    DateTimeOffset RecordedAtUtc,
    DomainEventEnvelope Event);
