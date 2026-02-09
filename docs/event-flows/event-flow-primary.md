## Example Event

**Event:** `SignalReceived`

A signal represents an external fact, such as:

* a system activity
* a scheduled trigger
* a user-initiated action

This example assumes a signal that requires evaluation, possible AI enrichment, and a surfaced outcome.

---

## Step-by-Step Lifecycle

### 1. Client Submits Signal

* Client (Flutter UI or external integration) sends a request
* Request is authenticated and validated at the edge

**Component:** Edge / BFF (TypeScript)

**Outcome:**

* Request accepted or rejected
* No business logic applied

---

### 2. Canonical Fact Is Recorded

* Edge forwards validated request to the Core Domain API
* Domain rules are enforced
* Idempotency is checked
* Canonical fact is persisted

**Component:** Core Domain API (ASP.NET Core)

**Outcome:**

* Fact is stored in PostgreSQL
* `SignalRecorded` domain event is emitted

This step defines **truth**.

---

### 3. Event Is Consumed

* Event processors consume `SignalRecorded`
* Payload is enriched with contextual data
* Routing logic determines next action

**Component:** Event Processor (Go / Rust)

**Outcome:**

* Decision evaluation is triggered

---

### 4. Deterministic Decision Evaluation

* Processor invokes the Rust decision engine
* Rules are evaluated deterministically
* A decision payload is produced

**Component:** Deterministic Rules Engine (Rust)

**Outcome:**

* Clear, explainable decision result
* No side effects

---

### 5. Workflow Is Orchestrated

* If required, a workflow is started
* Branching, retries, and waiting are handled

**Component:** AWS Step Functions

**Outcome:**

* External work is coordinated safely
* Time-based behavior is handled explicitly

---

### 6. Optional AI Enrichment

* Workflow invokes AI services
* Context is retrieved (RAG)
* Suggestions or summaries are generated

**Component:** AI Services (Python)

**Outcome:**

* Non-authoritative AI output
* Confidence scores included

AI output is treated as **advisory only**.

---

### 7. Outcome Is Persisted

* Final decision and metadata are persisted
* Workflow completes

**Component:** Core Domain API / Workflow integration

**Outcome:**

* Immutable decision record
* Full audit trail

---

### 8. System State Is Queried

* UI requests timelines, explanations, or summaries
* Read models are queried

**Component:** Query API (Ruby on Rails)

**Outcome:**

* Explainable system state surfaced to the user

---

## Key Takeaways

* Truth is recorded once
* Decisions are deterministic
* Time is owned by workflows
* AI never overrides rules
* Analytics are downstream

This flow is representative of **all** Helios behavior.
