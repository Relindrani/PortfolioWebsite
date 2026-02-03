# Architecture Decision Log

This document records **significant architectural and technical decisions** made during the design of Helios, along with the rationale behind them.

The goal is not to claim that these decisions are universally optimal, but to document **tradeoffs, constraints, and intent**. This log is treated as a living document and evolves as the system changes.

---

## ADR-001: Use Rust for Deterministic Business Logic

**Decision**  
Rust is used to implement correctness-critical and deterministic business logic.

**Context**  
Helios processes events from multiple sources and applies normalization, conflict resolution, and scoring logic that must behave consistently regardless of load or execution environment.

Duplicating this logic across services or embedding it directly in infrastructure-heavy components increases the risk of divergence and subtle bugs.

**Rationale**
- Strong compile-time guarantees
- Memory safety without garbage collection
- Explicit handling of state and errors
- Well-suited for deterministic, side-effect-free logic
- Clear isolation from infrastructure concerns

**Consequences**
- Increased integration complexity (FFI or service boundary)
- Smaller pool of contributors familiar with Rust
- Slower iteration compared to dynamic languages

This tradeoff is intentional to prioritize **correctness and clarity over velocity** for core logic.

---

## ADR-002: Use Ruby on Rails for Admin and Lifecycle Workflows

**Decision**  
Ruby on Rails is used for admin tooling, configuration management, and lifecycle workflows.

**Context**  
Administrative and internal workflows change frequently and benefit from fast iteration, expressive domain modeling, and strong conventions.

These workflows are not performance-critical and should not risk the stability of the core system.

**Rationale**
- High developer productivity
- Mature ecosystem for CRUD, background jobs, and email
- Strong conventions reduce accidental complexity
- Clear separation from public APIs and core logic

**Consequences**
- Additional service to operate
- Not suitable for high-throughput or latency-sensitive paths

Rails is intentionally scoped to **high-churn, internal-facing functionality**.

---

## ADR-003: Use AWS ECS (Fargate) Instead of Kubernetes

**Decision**  
AWS ECS with Fargate is used as the primary container orchestration platform.

**Context**  
The goal of the project is to demonstrate ownership of production-style infrastructure without introducing unnecessary operational overhead.

Operating Kubernetes clusters adds complexity that is not directly relevant to the learning goals of this system.

**Rationale**
- Managed control plane
- No node management
- Native AWS integration
- Lower cognitive and operational overhead
- Still demonstrates containerized, distributed workloads

**Consequences**
- Less flexibility than Kubernetes
- Vendor lock-in to AWS primitives

This decision prioritizes **operability and focus** over maximal flexibility.

---

## ADR-004: Use SQS for Asynchronous Messaging

**Decision**  
Amazon SQS is used for asynchronous communication between services.

**Context**  
Helios is designed as an event-driven system but does not require Kafka-level throughput, ordering guarantees, or operational complexity.

The primary goals are decoupling, retries, and failure isolation.

**Rationale**
- Fully managed service
- Built-in retry and dead-letter queues
- Simple operational model
- Integrates naturally with ECS and AWS tooling

**Consequences**
- Limited message ordering guarantees
- Not suitable for streaming analytics or real-time pipelines

SQS is chosen as a **pragmatic learning tool** that mirrors many real-world production systems.

---

## ADR-005: Use a Monorepo with Independent Deployments

**Decision**  
All applications and services live in a single repository but are built and deployed independently.

**Context**  
Helios is a cohesive platform with shared concepts, documentation, and infrastructure. However, coupling build and deploy pipelines would reduce clarity and increase risk.

**Rationale**
- Single source of truth for the system
- Easier cross-service refactoring
- Centralized documentation and architecture context
- Independent CI/CD pipelines per app or service

**Consequences**
- Requires disciplined repository structure
- CI/CD configuration is more complex than a single-app repo

This decision reflects a **platform-oriented mindset** rather than convenience.

---

## ADR-006: Use Astro for Portfolio and Documentation Site

**Decision**  
Astro is used to build a static portfolio and system documentation site.

**Context**  
The portfolio exists to explain the system, document decisions, and provide a narrative layer — not to participate in runtime behavior.

It must remain available even when backend services are degraded or offline.

**Rationale**
- Static-first by default
- Minimal runtime dependencies
- Excellent Markdown support
- Strong performance and SEO characteristics
- Clear separation from production workloads

**Consequences**
- No dynamic runtime content
- Requires a separate deployment pipeline

This reinforces the principle that **documentation and marketing surfaces should be outside the production blast radius**.

---

## ADR-007: Use the MIT License

**Decision**  
The repository is licensed under the MIT License.

**Context**  
Helios is intended as a learning resource, reference implementation, and portfolio project.

**Rationale**
- Minimal restrictions
- Encourages reuse and experimentation
- Widely understood and accepted
- Suitable for educational and demonstrative projects

**Consequences**
- No protection against commercial reuse
- No warranty or liability guarantees

This aligns with the goal of **openness and accessibility**.

---

## Summary

These decisions reflect a consistent set of priorities:

- Correctness over convenience
- Clarity over cleverness
- Operational awareness over novelty
- Depth of understanding over breadth of tooling

As the system evolves, new decisions will be recorded here and existing ones may be revisited.
