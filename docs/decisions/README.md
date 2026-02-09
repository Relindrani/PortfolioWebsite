# Architectural Decisions

This folder contains **Architectural Decision Records (ADRs)** for Helios.

ADRs document **why the system is designed the way it is**, not just what was built.
They capture the context, decision, and rationale behind choices that have a significant impact on the system’s structure, behavior, or evolution.

---

## Purpose

The goals of this folder are to:

* Make architectural tradeoffs explicit
* Preserve decision context over time
* Explain *why alternatives were rejected*
* Support future evolution without rewriting history

These documents are written to be understandable by engineers who were not present when the decision was made.

---

## What Belongs Here

ADRs are created for decisions that:

* Affect system-wide architecture
* Introduce or remove major dependencies
* Define responsibility boundaries
* Impact correctness, reliability, or operability

Examples include:

* Choice of orchestration mechanism
* Deterministic vs probabilistic decision-making
* Communication patterns between services
* Constraints placed on specific layers

---

## What Does *Not* Belong Here

* Implementation details
* Low-level refactors
* Temporary experiments
* Tooling choices with limited blast radius

If a decision can be easily reversed without broad impact, it likely does not need an ADR.

---

## How to Use These Documents

* Read ADRs to understand **why the system looks the way it does**
* Reference them during design discussions or reviews
* Revisit them when constraints or assumptions change

When a decision is superseded, a new ADR should be added that references the earlier one rather than deleting history.

---

## Design Philosophy

ADRs in Helios are:

* Concise and intentional
* Focused on tradeoffs, not justification
* Written for long-term clarity

Architecture evolves, but decisions should never be mysterious.
