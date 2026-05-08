---
name: web-architecture-grand-design-patterns
description: >
  Apply Yu Inao's personal catalogue of web architecture grand-design patterns.
  Use when designing, reviewing, or documenting whole-system web architecture
  decisions and selecting the relevant reference pattern from this skill.
license: CC-BY-NC-4.0
metadata:
  author: "Yu Inao"
  author_email: "84360+japboy@users.noreply.github.com"
  copyright: "Copyright (c) 2026 Yu Inao."
  version: "0.1.0"
  license_url: "https://creativecommons.org/licenses/by-nc/4.0/"
  commercial_use: "Commercial use requires separate permission from the author."
---

# Web Grand Design Patterns

## Purpose

Use this skill to reason about web architecture as a whole-system design
problem, not as isolated frontend implementation work.

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

For design guidance, prefer this structure:

1. **Decision**: the recommended architecture or review outcome
2. **Why**: the architectural rationale
3. **Reference**: which catalogue reference was applied
4. **Model**: the explicit states, contracts, boundaries, or schemas involved
5. **Risks**: ambiguity, coupling, refactoring hazards, or semantic drift
6. **Checklist**: concrete validation questions

Keep the answer grounded in the actual project artifacts when reviewing a real
codebase.

## License Notes

This skill catalogue is licensed as documentation and knowledge material under
CC-BY-NC-4.0. Attribution to Yu Inao is required for permitted use. Commercial
use is not granted by this license and requires separate permission from the
author.
