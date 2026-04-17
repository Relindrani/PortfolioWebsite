using Helios.Api.Models;

namespace Helios.Api.Services;

public sealed class DemoSystemSummaryService : ISystemSummaryService
{
    public SystemSummaryResponse GetSummary()
    {
        return new SystemSummaryResponse(
            SystemName: "Helios",
            Environment: "Local",
            Status: "Bootstrap",
            PrimaryObjective: "Establish the first runnable UI/API foundation for the control plane.",
            Services:
            [
                new SystemServiceStatus(
                    Name: "Core API",
                    Responsibility: "Accept requests and expose system state",
                    Status: "Online",
                    Plane: "Ingress"),
                new SystemServiceStatus(
                    Name: "Decision Engine",
                    Responsibility: "Evaluate deterministic rules and produce outcomes",
                    Status: "Planned",
                    Plane: "Decision"),
                new SystemServiceStatus(
                    Name: "Operator Dashboard",
                    Responsibility: "Visualize current state and explain outcomes",
                    Status: "Online",
                    Plane: "Presentation")
            ],
            Capabilities:
            [
                new SystemCapability(
                    Name: "Health Monitoring",
                    Description: "Expose service readiness so the UI and future orchestrators can verify the API is reachable.",
                    Status: "Ready"),
                new SystemCapability(
                    Name: "System Summary",
                    Description: "Provide one endpoint with high-level state for the first Helios dashboard.",
                    Status: "Ready"),
                new SystemCapability(
                    Name: "Workflow Timeline",
                    Description: "Surface long-running workflow progress and recent events.",
                    Status: "Planned")
            ],
            TimestampUtc: DateTimeOffset.UtcNow);
    }
}
