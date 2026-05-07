# Helios API

This service is the first backend entry point for Helios.

Current responsibilities:

- expose a basic health endpoint
- expose a system summary contract for the first UI
- persist idempotent signal submissions as canonical facts
- write `SignalRecorded` domain events to the outbox
- establish the ASP.NET Core project structure for future domain endpoints

## Endpoints

- `GET /health`
- `GET /api/system/summary`
- `POST /api/signals`
- `GET /api/signals`
- `GET /api/signals/{signalId}`

`POST /api/signals` requires an `Idempotency-Key` header. Reusing the same key
returns the previously recorded signal instead of creating a second canonical
fact.

## Persistence

The API owns canonical fact storage in PostgreSQL. On startup it creates:

- `signals` for durable submitted facts
- `outbox_events` for pending domain events that background processors can consume
