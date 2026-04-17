# Helios Bootstrap

This repository now contains the first implementation foundation for Helios in
addition to the portfolio site:

- `docker-compose.yml` - single entry point for local containers
- `Helios.sln` - solution entry point for backend work
- `apps/Helios.Api` - ASP.NET Core API bootstrap
- `apps/helios-ui` - Flutter dashboard bootstrap
- `apps/portfolio-astro` - Astro portfolio site

## Run Everything With Docker

From the repository root:

```bash
docker compose up --build
```

Available services:

- Helios API: `http://localhost:5091/health`
- Helios UI (Flutter Web): `http://localhost:4321`
- Portfolio site (Astro): `http://localhost:4322`
- PostgreSQL: `localhost:5432`

## Suggested next steps

1. Replace the demo system summary service with persisted read models.
2. Add workflow and event endpoints.
3. Introduce authentication and environment configuration.
4. Expand the Flutter client beyond the bootstrap dashboard into workflow and diagnostics views.
