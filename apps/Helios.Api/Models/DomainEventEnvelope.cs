namespace Helios.Api.Models;

public sealed record DomainEventEnvelope(
    string EventId,
    string Type,
    string Source,
    string Subject,
    string CorrelationId,
    DateTimeOffset OccurredAtUtc);
