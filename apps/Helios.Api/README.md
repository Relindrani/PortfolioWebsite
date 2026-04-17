# Helios API

This service is the first backend entry point for Helios.

Current responsibilities:

- expose a basic health endpoint
- expose a system summary contract for the first UI
- establish the ASP.NET Core project structure for future domain endpoints

## Endpoints

- `GET /health`
- `GET /api/system/summary`
