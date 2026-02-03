# System Architecture

Helios is designed as a **production-style, event-driven system** composed of multiple independently deployed services.  
Each service has a clearly defined responsibility, enforced boundaries, and a specific reason for existing.

The architecture favors **loose coupling, deterministic behavior, and operational clarity** over convenience.

---

## Architectural Overview

At a high level:

- External events are ingested through stable API boundaries
- Core business logic is executed deterministically and isolated from infrastructure
- Services communicate primarily via asynchronous messages
- Insights are derived through separate, non-critical analytics pipelines
- User interaction happens through a cross-platform client
- Documentation and portfolio surfaces are statically served and decoupled from runtime systems

This separation allows the system to degrade gracefully under failure and evolve without cascading changes.

---

## Core Principles

- **Clear ownership boundaries** per service and language
- **Deterministic business logic** isolated from infrastructure concerns
- **Event-driven communication** for loose coupling and resilience
- **Infrastructure as code** for reproducibility and auditability
- **Failure-aware design**, with explicit recovery paths
- **Independent deployability** across all applications

---

## Service Responsibilities

### ASP.NET Core API — System Orchestrator

The ASP.NET Core service acts as the **externally facing control plane**.

**Responsibilities**
- Authentication and authorization
- Public API consumed by the Flutter client
- Event ingestion endpoints
- Coordination between internal services
- Publishing messages to queues

**Out of scope**
- Heavy analytics
- Deterministic business rules
- High-throughput background processing

This service is optimized for **stability, clarity, and contract-driven APIs**.

---

### Rust Core — Deterministic Business Logic

The Rust core encapsulates **correctness-critical domain logic**.

**Responsibilities**
- Event normalization
- Conflict resolution
- Scoring and weighting algorithms
- Validation logic
- Deterministic state transitions

**Design intent**
- No infrastructure awareness
- Explicit inputs and outputs
- Language-level guarantees around safety and correctness

This component can be consumed via a service boundary (e.g. gRPC) or as a shared library, depending on deployment needs.

---

### Rails Admin — Product & Lifecycle Workflows

The Rails application provides **high-velocity internal tooling**.

**Responsibilities**
- Admin UI
- Feature flag management
- Rule and configuration management
- User lifecycle workflows
- Email notifications
- Background jobs

**Out of scope**
- Public APIs
- Core deterministic logic
- High-throughput ingestion

Rails is used intentionally to optimize for **developer speed and domain expressiveness** without risking core system stability.

---

### Go Services — Ingestion & Infrastructure Workers

Go-based services handle **infrastructure-adjacent and high-throughput workloads**.

**Responsibilities**
- Webhook consumers
- Event fan-in and fan-out
- High-throughput workers
- Scheduled infrastructure jobs

These services are designed to be:
- Simple
- Concurrent
- Fast to start
- Easy to reason about under load

---

### Python Analytics — Insight Generation

The Python layer is responsible for **non-critical, asynchronous analysis**.

**Responsibilities**
- Batch aggregation
- Trend analysis
- Scheduled reports
- Insight generation

This layer is intentionally decoupled so failures or delays do not impact core system behavior.

---

### Flutter Client — User Interface

The Flutter application provides a **single, cross-platform client**.

**Responsibilities**
- User dashboards
- Timeline and activity views
- Client-side state management
- Offline-friendly behavior (where applicable)

The client communicates exclusively through the public API and does not bypass service boundaries.

---

### Astro Portfolio — Documentation & Narrative Layer

The Astro-based site serves as the **static documentation and portfolio surface**.

**Responsibilities**
- System overview and case study
- Architecture documentation
- Design decisions and tradeoffs
- Failure scenarios and recovery notes
- Links to live services and source code

This site is:
- Static
- Independently deployed
- Outside the runtime blast radius

It exists to **explain the system**, not to participate in it.

---

## Data & Messaging

### Datastores

- **PostgreSQL**
  - Primary system of record
  - Transactional consistency
- **Redis**
  - Caching
  - Idempotency keys
  - Rate limiting

### Messaging

- **Amazon SQS**
  - Asynchronous service communication
  - Retry handling and dead-letter queues
  - Backpressure management

Messaging is used to:
- Reduce coupling
- Absorb load spikes
- Isolate failures

---

## Infrastructure

All infrastructure is provisioned via **Terraform**.

Primary components include:
- AWS ECS (Fargate) for containerized workloads
- AWS RDS for managed PostgreSQL
- AWS SQS for messaging
- VPC with basic network isolation

Infrastructure is treated as **versioned, reviewable code**.

---

## Failure Considerations

The system is designed with the assumption that **components will fail**.

Examples:
- Database unavailability
- Queue backlogs
- Worker crashes
- Partial service outages
- Failed deployments

Failure modes and recovery strategies are documented separately in `/docs/runbooks`.

---

## Summary

Helios is not optimized for minimalism or novelty.

It is optimized to demonstrate:
- Clear system boundaries
- Intentional technology choices
- Real-world tradeoffs
- Operational awareness
- The ability to design, deploy, and reason about a distributed system

This architecture favors **clarity over cleverness** and **depth over breadth**.
