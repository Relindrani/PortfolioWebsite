using Helios.Api.Models;
using Helios.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Helios.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SystemController(ISystemSummaryService systemSummaryService) : ControllerBase
{
    [HttpGet("summary")]
    [ProducesResponseType<SystemSummaryResponse>(StatusCodes.Status200OK)]
    public ActionResult<SystemSummaryResponse> GetSummary()
    {
        return Ok(systemSummaryService.GetSummary());
    }
}
