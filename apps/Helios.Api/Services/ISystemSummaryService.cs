using Helios.Api.Models;

namespace Helios.Api.Services;

public interface ISystemSummaryService
{
    SystemSummaryResponse GetSummary();
}
