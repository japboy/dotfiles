---
name: web-architecture-pattern-application
description: >
  Apply Yu Inao's route-state-based product analytics pattern to web
  architecture decisions. Use when designing or reviewing declarative analytics
  derived from route transitions, URL-as-state, route registries, measurement
  manifests, or DWH semantic models. Do not use for unrelated web architecture.
license: CC-BY-NC-4.0
metadata:
  author: "Yu Inao"
  author_email: "84360+japboy@users.noreply.github.com"
  copyright: "Copyright (c) 2026 Yu Inao."
  version: "0.1.0"
  license_url: "https://creativecommons.org/licenses/by-nc/4.0/"
  commercial_use: "Commercial use requires separate permission from the author."
---

# Web Architecture Pattern Application

## Purpose

Use this skill to reason about route-state product analytics as a whole-system
web architecture problem, not as isolated frontend tracking calls.

The expected output is an architectural decision, critique, or pattern proposal
that selects and applies the relevant reference pattern from this catalogue.

## Architectural Axioms

Apply these axioms consistently:

- Declarative
- Self-describing
- Deterministic
- Explicit state
- Finite state
- Self-documenting
- Exhaustive
- Predictable

Prefer designs where important behavior is derived from explicit models instead
of scattered procedural side effects.

## Working Model

Start by identifying the architectural level of the user's question:

- conceptual model
- information architecture
- application state
- runtime boundary
- data or observability model
- operational contract
- governance or review policy

Then load only the reference files needed for that level. Do not import one
reference pattern's assumptions into unrelated architecture decisions.

Choose exactly one terminal applicability state before recommending a pattern:

- `applicable`: the task matches a catalogue entry and the project evidence is
  sufficient to apply it.
- `not-applicable`: no catalogue entry matches. State that result and stop; do
  not turn the catalogue into generic web architecture advice.
- `defer`: a catalogue entry may match, but a required project fact is missing.
  Name the missing fact and the artifact that can resolve it, then stop.

## Reference Catalog

Available references:

| Reference | Use when |
|---|---|
| [Route-State-Based Product Analytics](references/route-state-product-analytics.md) | The task involves product analytics, tracking, declarative instrumentation, route transition logs, URL-as-state, IA-aligned route design, or DWH semantic modeling from web behavior logs. |

## Review Stance

When applying a pattern:

1. Separate project facts from pattern recommendations.
2. Identify which reference pattern is being applied.
3. Keep each reference pattern's scope explicit.
4. Avoid applying a pattern merely because it is available.
5. Surface tradeoffs, missing evidence, and unknowns explicitly.
6. Prefer declarative, self-describing models over scattered procedural
   conventions.

## Output Shape

For an `applicable` result, prefer this structure:

1. **Decision**: the recommended architecture or review outcome
2. **Why**: the architectural rationale
3. **Reference**: which catalogue reference was applied
4. **Model**: the explicit states, contracts, boundaries, or schemas involved
5. **Risks**: ambiguity, coupling, refactoring hazards, or semantic drift
6. **Checklist**: concrete validation questions
7. **Applicability State**: `applicable`

Keep the answer grounded in the actual project artifacts when reviewing a real
codebase.

For `not-applicable` or `defer`, return only the applicability state, the reason,
and, for `defer`, the missing fact and resolving artifact.

## License Notes

This skill catalogue is licensed as documentation and knowledge material under
CC-BY-NC-4.0. Attribution to Yu Inao is required for permitted use. Commercial
use is not granted by this license and requires separate permission from the
author.
