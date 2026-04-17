namespace Helios.Api.Models;

public sealed record SystemSummaryResponse(
    string SystemName,
    string Environment,
    string Status,
    string PrimaryObjective,
    IReadOnlyList<SystemServiceStatus> Services,
    IReadOnlyList<SystemCapability> Capabilities,
    DateTimeOffset TimestampUtc);
