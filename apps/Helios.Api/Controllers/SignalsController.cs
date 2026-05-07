using Helios.Api.Models;
using Helios.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Helios.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class SignalsController(ISignalIngestionService signalIngestionService) : ControllerBase
{
    [HttpPost]
    [ProducesResponseType<SignalRecordedResponse>(StatusCodes.Status201Created)]
    [ProducesResponseType<ValidationProblemDetails>(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<SignalRecordedResponse>> RecordSignal(
        [FromBody] SignalSubmissionRequest request,
        [FromHeader(Name = "Idempotency-Key")] string? idempotencyKey,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(idempotencyKey))
        {
            ModelState.AddModelError("Idempotency-Key", "The Idempotency-Key header is required.");
            return ValidationProblem(ModelState);
        }

        if (idempotencyKey.Length > 128)
        {
            ModelState.AddModelError("Idempotency-Key", "The Idempotency-Key header must be 128 characters or fewer.");
            return ValidationProblem(ModelState);
        }

        var response = await signalIngestionService.RecordSignalAsync(
            request,
            idempotencyKey.Trim(),
            cancellationToken);

        return response.WasDuplicate
            ? Ok(response)
            : CreatedAtAction(nameof(GetSignal), new { signalId = response.SignalId }, response);
    }

    [HttpGet("{signalId:guid}")]
    [ProducesResponseType<SignalDetailResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<SignalDetailResponse>> GetSignal(
        Guid signalId,
        CancellationToken cancellationToken)
    {
        var signal = await signalIngestionService.GetSignalAsync(signalId, cancellationToken);
        return signal is null ? NotFound() : Ok(signal);
    }

    [HttpGet]
    [ProducesResponseType<IReadOnlyList<SignalDetailResponse>>(StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<SignalDetailResponse>>> GetRecentSignals(
        [FromQuery] int take = 25,
        CancellationToken cancellationToken = default)
    {
        return Ok(await signalIngestionService.GetRecentSignalsAsync(take, cancellationToken));
    }
}
