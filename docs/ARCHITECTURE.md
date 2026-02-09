# System Architecture

Helios V2 is designed as a **production-style, event-driven control plane** composed of independently deployable services with explicitly defined boundaries.

Each component exists for a single reason, owns a narrow concern, and communicates primarily through **asynchronous events and managed workflows**.

The architecture favors **deterministic behavior, explainability, and operational clarity** over convenience or premature optimization.

---

## Architectural Overview

Helios V2 is organized into four distinct planes:

```
Ingress Plane
    ↓
Decision Plane
    ↓
Presentation Plane
    ↘
     Analytics Plane (observational only)
```

Rules of the system:

* No plane bypasses another
* No plane owns more than one concern
* Analytics never influence live decisions

This structure allows the system to evolve safely, degrade gracefully, and remain explainable under failure.

---

# Architecture Diagram

This diagram provides a **high-level view** of Helios V2.

It intentionally avoids low-level detail and focuses on **boundaries and data flow**.

---

## System Diagram

```
+--------------------+
|    Clients         |
|  (Flutter / Ext)   |
+---------+----------+
          |
          v
+--------------------+
|  Edge / BFF        |
|  TypeScript        |
+---------+----------+
          |
          v
+--------------------+
| Core Domain API    |
| ASP.NET Core       |
+---------+----------+
          |
          v
+--------------------+
| Event Backbone     |
| Kafka / SNS/SQS    |
+---------+----------+
          |
          v
+--------------------+
| Event Processors   |
| Go / Rust          |
+---------+----------+
          |
          v
+--------------------+
| Rules Engine       |
| Rust               |
+---------+----------+
          |
          v
+--------------------+
| Step Functions     |
| (Workflows)        |
+----+-----------+---+
     |           |
     v           v
+---------+   +-----------+
| AI / RAG|   | Persistence|
| Python  |   | PostgreSQL |
+---------+   +-----------+
                    |
                    v
              +-----------+
              | Query API |
              | Rails     |
              +-----+-----+
                    |
                    v
              +-----------+
              | Clients   |
              | (Flutter) |
              +-----------+
```

---

## Diagram Notes

* Arrows represent **primary data flow**, not control flow
* Analytics and observability are omitted for clarity
* All components are independently deployable
* AI is downstream of deterministic decisions

This diagram is intended for **communication**, not implementation.


---

## Core Principles

* **Clear ownership boundaries** per service and language
* **Deterministic decision-making** isolated from infrastructure
* **Event-driven communication** for loose coupling
* **Managed orchestration** for long-running workflows
* **Infrastructure as code** for reproducibility
* **Failure-aware design** with documented recovery paths
* **Independent deployability** across all services

---

## Planes & Responsibilities

### Ingress Plane — Accept and Record Truth

This plane is responsible for **what happened**, not what should happen next.

#### Edge / BFF — TypeScript (Node.js)

**Responsibilities**

* Authentication and authorization
* Request validation
* Client-specific request shaping
* Rate limiting and edge concerns

**Out of scope**

* Business logic
* Persistence
* Decision-making

---

#### Core Domain API — C# / ASP.NET Core

This service is the **system of record**.

**Responsibilities**

* Domain validation
* Idempotency enforcement
* Persistence of canonical facts
* Emitting domain events

**Out of scope**

* Orchestration
* Analytics
* AI integration

This service defines truth. Everything else reacts to it.

---

### Decision Plane — Evaluate and Act

This plane determines **what the system should do** in response to events.

---

#### Deterministic Rules Engine — Rust

**Responsibilities**

* Policy evaluation
* Rule execution
* Scoring and thresholds
* Explainable decision outputs

**Design constraints**

* No infrastructure awareness
* Explicit inputs and outputs
* Fully deterministic behavior

Rust is used here intentionally to signal correctness-critical logic.

---

#### Event Processors — Go & Rust

**Responsibilities**

* Event enrichment
* Routing
* Fan-in / fan-out
* Workflow triggering

These services are:

* Stateless
* Horizontally scalable
* Infrastructure-adjacent

---

#### Workflow Orchestration — AWS Step Functions

**Responsibilities**

* Long-running workflows
* Retries and backoff
* Branching logic
* Time-based behavior
* Failure handling

Step Functions owns **time and coordination**, not business rules.

---

#### AI / RAG Services — Python

**Responsibilities**

* Embedding generation
* Retrieval and context assembly
* LLM interaction
* Confidence scoring

AI is **augmentative only**.
Deterministic decisions always take precedence.

---

### Presentation Plane — Explain System State

This plane answers **why the system behaved the way it did**.

---

#### Query API — Ruby on Rails

**Responsibilities**

* Read models and projections
* Aggregations and timelines
* Admin and inspection endpoints

**Constraints**

* Read-only
* No domain mutations
* No orchestration

Rails is used here to maximize clarity and developer velocity without risking system correctness.

---

#### Client Applications — Flutter

**Responsibilities**

* Cross-platform UI
* Visualization of system state
* Interaction and exploration

The client communicates exclusively through public APIs.

---

#### Portfolio & Docs — Astro

**Responsibilities**

* Architecture documentation
* System narrative
* Design decisions and tradeoffs
* Failure analysis

This surface is static, independently deployed, and outside the runtime blast radius.

---

### Analytics Plane — Observe, Never Influence

Analytics are strictly **downstream and non-authoritative**.

**Responsibilities**

* Operational metrics
* Logs and traces
* Decision metadata
* Offline insights

**Tooling**

* OpenTelemetry
* CloudWatch
* Prometheus / Grafana

Analytics never participate in real-time decisions.

---

## Data & Messaging

### Data Stores

* **PostgreSQL (RDS)**

  * Domain facts
  * Decision outcomes
  * AI metadata

* **pgvector**

  * Embeddings only

* **Object Storage (S3)**

  * Raw payloads
  * Large artifacts

Write ownership is explicit:

| Data Type      | Owner          |
| -------------- | -------------- |
| Domain facts   | ASP.NET Core   |
| Decisions      | Rust           |
| Workflow state | Step Functions |
| AI outputs     | Python         |
| Read models    | Rails          |

---

### Messaging & Events

* **Kafka or SNS/SQS**

  * Asynchronous communication
  * Backpressure handling
  * Failure isolation

Events are the primary integration mechanism between services.

---

## Infrastructure

All infrastructure is provisioned via **Terraform**.

Primary components:

* AWS API Gateway
* AWS ECS (Fargate) and/or Lambda
* AWS Step Functions
* AWS RDS (PostgreSQL)
* VPC with network isolation

Infrastructure is intentionally conservative; complexity lives in system design, not bespoke tooling.

---

## Failure & Recovery

Helios V2 assumes components will fail.

Documented scenarios include:

* Partial workflow failure
* Event reprocessing
* Queue backlogs
* AI service degradation
* Regional outages

Recovery strategies are documented in `/docs/runbooks`.

---

## Summary

Helios V2 is not a demo system.

It is a deliberately designed control plane intended to demonstrate:

* Senior-level system thinking
* Clear architectural boundaries
* Responsible AI integration
* Cloud-native operation
* Explainability under failure

The system favors **clarity over cleverness** and **correctness over convenience**.
