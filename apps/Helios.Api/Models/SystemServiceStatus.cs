namespace Helios.Api.Models;

public sealed record SystemServiceStatus(
    string Name,
    string Responsibility,
    string Status,
    string Plane);
