# Helios

**Helios** is a personal control plane for projects, systems, and activity signals.

It ingests events from multiple sources, evaluates them using deterministic rules, optionally enriches them with AI, and surfaces **explainable outcomes** through a cross-platform dashboard.

The system is intentionally designed and operated as a **production-style, event-driven, polyglot system** to demonstrate senior-level system design, backend ownership, and cloud-native architectural thinking.

Helios serves two purposes:

- A **real, usable personal control plane**
- A **deep, documented portfolio project** focused on architecture, tradeoffs, and evolution

---

## Goals

- Demonstrate **clear responsibility boundaries** across a polyglot system
- Design and operate an **event-driven control plane**, not a generic data platform
- Separate **truth, decision-making, orchestration, and presentation**
- Showcase **cloud-native infrastructure and managed services**
- Treat AI as **augmentation**, not an authority
- Provide a polished, static **portfolio and system narrative** alongside a live system

---

## Architectural Overview

Helios is organized into **four explicit planes**, each with strict boundaries:

```
Ingress Plane
↓
Decision Plane
↓
Presentation Plane
↘
Analytics Plane (observational only)
```


No plane bypasses another. No plane owns more than one concern.

---

## System Components

### Ingress Plane — Accept and Record Truth

- **TypeScript (Node.js)** — Edge / BFF  
  Authentication, request validation, client-specific shaping

- **C# / ASP.NET Core** — Core Domain API  
  Domain validation, idempotency, persistence of canonical facts

- **Event Backbone** — Kafka or AWS SNS/SQS  
  Durable, asynchronous event transport

This plane is responsible for **what happened**, not what happens next.

---

### Decision Plane — Evaluate and Act Reliably

- **Rust** — Deterministic decision engine  
  Policy evaluation, rules, thresholds, scoring, auditability

- **Go & Rust** — Stateless event processors  
  Event enrichment, routing, workflow triggering

- **AWS Step Functions** — Orchestration & time  
  Long-running workflows, retries, backoff, branching, failure handling

- **Python** — AI / RAG services  
  Embeddings, retrieval, LLM interaction, scoring and summarization

AI is **explicitly non-authoritative**.  
Deterministic logic always has precedence.

---

### Presentation Plane — Explain System State

- **Ruby on Rails** — Query / read API  
  Aggregations, timelines, explanations, admin endpoints (read-only)

- **Flutter** — Cross-platform client  
  Visualization, interaction, system state exploration

- **Astro** — Static portfolio & documentation site  
  Architecture, tradeoffs, diagrams, and system narrative

This plane explains **why Helios did what it did** — it does not drive behavior.

---

### Analytics Plane — Observe, Don’t Influence

Analytics are intentionally **downstream and non-authoritative**.

- **Operational analytics** — metrics, logs, traces  
  CloudWatch, Prometheus, Grafana, OpenTelemetry

- **Decision analytics** — append-only metadata  
  Rule firings, AI suggestion acceptance, confidence scores

- **Insight analytics (stretch)** — offline analysis  
  Rule effectiveness, AI drift, system improvement

Analytics never participate in real-time decision-making.

---

## Infrastructure & Data

### Infrastructure

- **AWS**
  - API Gateway
  - ECS (Fargate) and/or Lambda
  - Step Functions
  - Managed PostgreSQL (RDS)
- **Terraform** — Infrastructure as Code

The infrastructure is intentionally **boring by design**.  
Complexity lives in system boundaries, not bespoke infrastructure.

---

### Data Layer

- **PostgreSQL**
  - Domain facts
  - Decision outcomes
  - AI metadata
  - Analytics tables
- **pgvector**
  - Embeddings only
- **Object Storage**
  - Raw payloads and large artifacts

Write ownership is explicit and enforced:

| Data Type | Owner |
|----------|-------|
| Domain facts | .NET |
| Deterministic decisions | Rust |
| Workflow outcomes | Step Functions |
| AI outputs | Python (via workflows) |
| Read models | Rails |

---

## Monorepo Philosophy

Helios is organized as a **monorepo with independently deployable applications and services**.

> **Monorepo does not mean monodeploy.**  
> Each application and service is built, tested, and deployed independently.

This keeps the system cohesive while preserving clear ownership, evolution paths, and operational boundaries.

---

## Repository Structure

```
/apps
    /portfolio-astro -> Static portfolio & documentation
    /edge-bff-node -> TypeScript edge / BFF
    /core-api-dotnet -> ASP.NET Core domain API
    /query-api-rails -> Read-only query & admin API
    /flutter-client -> Cross-platform UI

/services
    /rust-decisions -> Deterministic rules engine
    /go-processors -> Stateless event processors
    /python-ai -> AI / RAG services

/infra
    /terraform -> AWS infrastructure as code

/docs
    architecture.md -> System overview & boundaries
    decisions.md -> Architectural decision records
    runbooks/ -> Failure scenarios & recovery notes
```


---

## Portfolio & Documentation Site

The **Astro-based portfolio site** lives alongside the system it documents.

It is intentionally:

- Static and independently deployed
- Outside the backend blast radius
- Focused on narrative, tradeoffs, and architectural reasoning

The site includes:

- A high-level system overview
- Architecture diagrams and boundaries
- Documented failure modes and recovery strategies
- Links to the live system and source code

This mirrors real-world practice, where documentation and marketing surfaces are decoupled from production systems.

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

The architecture favors **clarity, correctness, and explainability** over premature optimization, with deliberate room for iteration as new constraints and ideas emerge.

---

### Final Note

Helios is not a “demo platform.”  
It is a **control plane designed to evolve**, and the documentation reflects not just *what* was built, but *why* it was built this way.
