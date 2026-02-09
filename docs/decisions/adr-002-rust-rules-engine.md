## ADR-002: Deterministic Rules Engine in Rust

### Context

Helios requires:

* Explainable decisions
* Predictable behavior
* Clear audit trails

Dynamic or AI-driven decision-making would compromise trust.

### Decision

Implement the core rules engine in **Rust** with strict determinism.

### Rationale

* Strong type system
* Memory safety
* Performance without runtime unpredictability
* Clear signaling of correctness-critical logic

Rust is intentionally isolated from infrastructure concerns.