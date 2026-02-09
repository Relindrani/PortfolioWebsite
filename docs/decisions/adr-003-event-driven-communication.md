## ADR-003: Event-Driven Communication

### Context

Direct service-to-service coupling increases failure propagation and reduces evolvability.

### Decision

Use **asynchronous events** as the primary integration mechanism.

### Rationale

* Loose coupling
* Natural backpressure
* Easier reprocessing
* Clear ownership boundaries

Synchronous APIs are reserved for edge and query use cases.