# Event Flows

This folder contains **concrete, step-by-step event lifecycles** for Helios.

The goal of these documents is to explain **how the system behaves in practice**, not just how it is structured.

Each event flow traces a single event from ingestion to outcome, highlighting:

* Which components are involved
* Where decisions are made
* How failures are handled
* Which paths are deterministic vs optional

---

## How to Use These Documents

* Start here if you want to understand **runtime behavior**
* Use these during system design discussions or interviews
* Reference them when reasoning about changes or failures

These flows intentionally avoid implementation detail and focus on **responsibility boundaries and data movement**.

---

## Included Flows

* **Deterministic-only flow** — baseline system behavior without AI
* **AI-enriched flow** — deterministic decisions augmented with AI

Additional flows may be added as new behaviors are introduced.

---

## Design Philosophy

Event flows are:

* Representative, not exhaustive
* Written to be readable in sequence
* Stable over time, even as implementations change

If the system behavior changes, these documents should be updated first.
