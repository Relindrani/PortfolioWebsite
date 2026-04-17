using Helios.Api.Models;
using Helios.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddCors(options =>
{
    options.AddPolicy("HeliosUi", policy =>
    {
        policy
            .WithOrigins(
                "http://localhost:4321",
                "https://localhost:4321",
                "http://127.0.0.1:4321",
                "https://127.0.0.1:4321")
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});
builder.Services.AddSingleton<ISystemSummaryService, DemoSystemSummaryService>();

var app = builder.Build();

app.UseHttpsRedirection();
app.UseCors("HeliosUi");
app.UseAuthorization();
app.MapControllers();

app.MapGet("/health", () =>
{
    return Results.Ok(new HealthResponse(
        Status: "Healthy",
        Service: "helios-api",
        TimestampUtc: DateTimeOffset.UtcNow));
});

app.Run();
