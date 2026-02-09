## ADR-005: Read-Only Presentation Layer

### Context

Mixing reads and writes increases complexity and risk.

### Decision

Enforce a **read-only presentation layer** using Rails.

### Rationale

* Clear CQRS separation
* Faster iteration
* Reduced blast radius

Writes always flow through the domain API.