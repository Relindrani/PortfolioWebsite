namespace Helios.Api.Models;

public sealed record SignalDetailResponse(
    Guid SignalId,
    string IdempotencyKey,
    string Source,
    string Type,
    string Subject,
    string? Payload,
    string CorrelationId,
    DateTimeOffset RecordedAtUtc,
    DomainEventEnvelope Event);
