# Architectural Decision Records (ADRs)

This document captures **key architectural decisions** made in Helios V2.

Each ADR records the **context**, **decision**, and **rationale**, with an emphasis on tradeoffs.

---

## ADR-001: Use AWS Step Functions for Orchestration

### Context

Helios V2 requires:

* Long-running workflows
* Explicit retry and backoff behavior
* Branching logic
* Time-based waits

Temporal was considered, but introduces operational and conceptual overhead.

### Decision

Use **AWS Step Functions** as the orchestration engine.

### Rationale

* Managed service with strong reliability guarantees
* Native AWS integration
* Clear ownership of time and retries
* Reduced operational complexity

The goal is **clarity and correctness**, not maximum flexibility.

---

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

---

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

---

## ADR-004: AI as Advisory Only

### Context

AI systems are probabilistic and non-deterministic.

### Decision

AI outputs are **never authoritative**.

### Rationale

* Deterministic logic ensures correctness
* AI augments human understanding
* Failures degrade gracefully

This preserves trust in system behavior.

---

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
