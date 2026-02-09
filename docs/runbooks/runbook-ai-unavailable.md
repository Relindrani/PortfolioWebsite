# Runbook: AI Service Unavailable

This runbook documents how Helios behaves when **AI / RAG services are unavailable** and how the system is expected to recover.

---

## Scenario

* AI provider outage
* Network timeout
* Embedding store unavailable
* LLM rate limiting or throttling

This failure is expected and explicitly designed for.

---

## Expected System Behavior

1. **AI calls fail inside workflow steps**
2. Step Functions retries according to configured policy
3. After retry exhaustion, workflow continues without AI enrichment
4. Deterministic decision output remains authoritative
5. System produces a valid outcome

No user-facing errors occur.

---

## Impact Analysis

| Area               | Impact              |
| ------------------ | ------------------- |
| Core decisions     | None                |
| Workflow execution | Partial degradation |
| User experience    | Reduced context     |
| Data integrity     | Preserved           |

AI failure degrades **quality**, not **correctness**.

---

## Detection

* Elevated error rate in AI service logs
* Step Functions execution warnings
* Increased workflow fallback paths

Metrics are visible in:

* CloudWatch
* Grafana dashboards

---

## Recovery

1. AI service recovers
2. New workflows automatically resume enrichment
3. No replay required

Optional:

* Re-run enrichment for affected decisions (offline)

---

## Postmortem Notes

This failure mode validates the architectural decision to treat AI as advisory.

The system continues to operate correctly without manual intervention.
