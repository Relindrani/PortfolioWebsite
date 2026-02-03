# Helios

**Helios** is a personal control plane for projects, systems, and activity signals.

It aggregates events from multiple sources, applies deterministic business logic, and surfaces insights through a cross-platform dashboard. The system is intentionally designed and operated as a **production-style, polyglot platform** to demonstrate full-stack, backend, and infrastructure ownership.

Helios serves two purposes:

- A **real, usable personal dashboard**
- A **deep, documented portfolio project** focused on system design, tradeoffs, and operational thinking

---

## Goals

- Demonstrate language flexibility with **clear, enforced responsibility boundaries**
- Design and operate a **distributed, event-driven system**
- Showcase real-world **infrastructure, deployment, and observability practices**
- Practice failure handling, recovery, and system evolution
- Provide a polished, static **portfolio and system narrative** alongside a live application

---

## High-Level Architecture

Helios is composed of multiple independently deployed services, each chosen for a specific role:

- **Flutter** — Cross-platform client (web + mobile)
- **ASP.NET Core** — Public API, authentication, and system orchestration
- **Rust** — Deterministic, correctness-critical business logic
- **Ruby on Rails** — Admin UI, configuration, and lifecycle workflows
- **Go** — Ingestion services and infrastructure-facing workers
- **Python** — Analytics, aggregation, and insight generation
- **Astro** — Static portfolio and system documentation site

### Infrastructure & Data

- **PostgreSQL** — Primary datastore
- **Redis** — Caching, idempotency, and rate limiting
- **AWS**
  - ECS (Fargate) for containerized services
  - RDS for managed PostgreSQL
  - SQS for asynchronous messaging and decoupling

The system is intentionally **event-driven** to enable loose coupling, failure isolation, and scalability.

---

## Monorepo Philosophy

Helios is organized as a **monorepo with independent applications and services**.

> **Monorepo does not mean monodeploy.**  
> Each app and service is built, tested, and deployed independently.

This approach keeps the platform cohesive while preserving clear ownership and operational boundaries.

---

## Repository Structure

The repository is organized as a monorepo with independently deployable applications and services:


```
/apps
    /portfolio-astro    -> Static portfolio & system documentation
    /api-dotnet         -> ASP.NET Core public API & orchestrator
    /admin-rails        -> Rails admin UI & workflows
    /flutter            -> Cross-platform client (web + mobile)

/services
    /rust-core          -> Deterministic business core logic
    /go-workers         -> Ingestion & infra-facing services
    /python-analytics   -> Analytics & insight generation

/infra
/terraform              -> AWS infrastructure as code

/docs
    ARCHITECTURE.md     -> System overview
    DECISIONS.md        -> Architechtural decicion records (ADRs)
    runbooks/           -> Operational notes & failure scenarios

```

## Portfolio & Documentation Site

The **Astro-based portfolio site** lives alongside the system it documents.

It is intentionally:
- Static and independently deployed
- Outside the backend blast radius
- Focused on narrative, tradeoffs, and system design

The site includes:
- A high-level system overview
- A deep case study of Helios
- Architecture diagrams and decisions
- Documented failure modes and recovery strategies
- Links to the live application and source code

This separation mirrors real-world practice, where marketing and documentation surfaces are decoupled from production systems.

---

## Licensing

This project is released under the **MIT License**.

The MIT license was chosen to:
- Encourage exploration and reuse
- Keep the project accessible as a learning reference
- Avoid unnecessary restrictions on experimentation

---

## Status

Helios is an **active, evolving system**.  
The architecture favors clarity and correctness over premature optimization, with room for iteration as new ideas and constraints emerge.