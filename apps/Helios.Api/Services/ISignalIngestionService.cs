using Helios.Api.Models;

namespace Helios.Api.Services;

public interface ISignalIngestionService
{
    Task<SignalRecordedResponse> RecordSignalAsync(
        SignalSubmissionRequest request,
        string idempotencyKey,
        CancellationToken cancellationToken);

    Task<SignalDetailResponse?> GetSignalAsync(
        Guid signalId,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<SignalDetailResponse>> GetRecentSignalsAsync(
        int take,
        CancellationToken cancellationToken);
}
