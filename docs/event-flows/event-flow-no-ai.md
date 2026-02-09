## Example Event

**Event:** `ThresholdExceeded`

A deterministic system signal that requires immediate action without enrichment.

---

## Step-by-Step Lifecycle

### 1. Signal Submission

* Client or system submits event
* Edge validates and forwards request

**Component:** Edge / BFF (TypeScript)

---

### 2. Canonical Fact Recording

* Domain rules enforced
* Fact persisted
* Event emitted

**Component:** Core Domain API (ASP.NET Core)

---

### 3. Event Consumption

* Processor consumes event
* Determines no enrichment required

**Component:** Event Processor (Go / Rust)

---

### 4. Deterministic Evaluation

* Rules engine evaluates thresholds
* Decision is produced

**Component:** Rules Engine (Rust)

---

### 5. Direct Outcome Persistence

* Decision is persisted
* No workflow invoked

**Component:** Core Domain API

---

### 6. State Is Queried

* UI queries system state

**Component:** Query API (Rails)

---

## Key Differences from AI Flow

* No Step Functions execution
* No AI calls
* Lower latency
* Fully deterministic

This path demonstrates the system's **baseline reliability**.
