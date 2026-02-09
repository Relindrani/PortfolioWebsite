## ADR-001: Use AWS Step Functions for Orchestration

### Context

Helios requires:

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