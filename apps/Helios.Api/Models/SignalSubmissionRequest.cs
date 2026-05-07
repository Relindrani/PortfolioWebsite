using System.ComponentModel.DataAnnotations;

namespace Helios.Api.Models;

public sealed record SignalSubmissionRequest(
    [Required, MinLength(1), MaxLength(80)] string Source,
    [Required, MinLength(1), MaxLength(80)] string Type,
    [Required, MinLength(1), MaxLength(160)] string Subject,
    [MaxLength(4096)] string? Payload,
    [MaxLength(120)] string? CorrelationId);
