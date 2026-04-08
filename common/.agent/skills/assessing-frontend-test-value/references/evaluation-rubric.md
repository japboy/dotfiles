# Evaluation Rubric

## Scope

This rubric is optimized for frontend tests evaluated with the Testing Trophy as the primary routing model.

## Phase 1: Trophy Routing

Answer these in order. Stop at the first decisive answer.

1. Can a static mechanism prevent this defect with equal or better confidence?
- Yes -> `MOVE_TO_STATIC` or `KEEP_STATIC`

2. Is the risk mainly user-visible behavior spanning multiple frontend units?
- Yes -> prefer `INTEGRATION`

3. Does the risk materially depend on real browser engines, real navigation, persistence, backend round trips, auth flow, device behavior, or multi-screen workflow realism?
- Yes -> prefer `E2E`

4. Is the logic pure, local, and not better expressed through integration or static guarantees?
- Yes -> prefer `UNIT`

5. If none of the above justify unique value:
- prefer `REMOVE`

## Phase 2: In-Layer Quality Checks

Once the best layer is chosen, score quality checks from 0 to 2.

| Dimension | 0 | 1 | 2 |
|---|---|---|---|
| User outcome | Internal detail only | Partial user-visible signal | Clear user-visible or AT-visible outcome |
| Accessibility semantics | Critical semantics untested | Partial semantic checks | Role/name/focus/keyboard semantics covered |
| Behavior focus | Implementation-coupled | Mixed internal and external checks | Behavior-focused assertions |
| Runtime realism | Unrealistic runtime for the risk | Partial realism | Relevant runtime exercised |
| Contract confidence | Boundary risk unverified | Partial boundary checks | Explicit compatibility verified |
| Visual signal | Visual risk unprotected | Partial visual oracle | Meaningful visual guarantee covered |
| Refactor resilience | Breaks on harmless refactor | Moderate coupling | Stable under internal refactor |
| Stability | Intermittent or flaky | Rare instability | Stable across reruns |
| Fidelity | Unrealistic mocks dominate | Mixed doubles with gaps | High-fidelity collaborators or realistic doubles |

Additional Storybook-specific checks when stories are part of the setup:

- Scenario canonicality: `0` if the story is an internal-state dump or arbitrary fixture, `1` if partly meaningful, `2` if it represents a clear public use case or visible state.
- Story/test synchronization: `0` if the test duplicates story setup by hand, `1` if reuse is partial or annotations are missing, `2` if the test composes the story and keeps project annotations in sync.

## Phase 3: Final Status

Use the Phase 1 layer choice first, then Phase 2 quality to decide status.

- Best layer selected and quality mostly strong -> `KEEP_STATIC`, `KEEP_INTEGRATION`, `KEEP_E2E`, or `KEEP_UNIT`
- Best layer selected but quality weak -> `REWRITE_AT_SAME_LAYER`
- Wrong layer selected -> `MOVE_TO_STATIC`, `MOVE_TO_INTEGRATION`, `MOVE_TO_E2E`, or `MOVE_TO_UNIT`
- No unique value remains -> `REMOVE`

## Override Rules

1. If a static mechanism can reasonably prevent the same defect, dynamic tests cannot be the default recommendation.
2. If the risk spans multiple frontend units and the current test is unit-level, status cannot be `KEEP_UNIT`.
3. If the risk depends on real browser or device behavior and the current runtime cannot expose it, prefer `MOVE_TO_E2E`.
4. If the risk is a critical user journey, unit-only coverage is insufficient.
5. If the same behavior is better expressed through user-visible integration than direct hook or prop wiring checks, prefer `MOVE_TO_INTEGRATION`.
6. If `User outcome = 0` and `Behavior focus = 0`, status cannot be `KEEP_*`.
7. If `Stability = 0`, status cannot be `KEEP_*`.

## Special Guidance for Hooks and Components

- Direct hook tests are presumptively `UNIT`.
- Isolated component tests are presumptively `UNIT` unless they exercise multiple units and user-visible DOM semantics strongly enough to count as `INTEGRATION`.
- Hook or component tests that only verify plumbing, state wiring, or callback forwarding should generally be `REWRITE_AT_SAME_LAYER`, `MOVE_TO_INTEGRATION`, or `REMOVE`.
- Story-driven component tests are preferred over bespoke fixtures only when a component test is already justified.
- A story used in tests should represent a public use case or meaningful visible state, not an exhaustive internal state matrix.
- Reusing stories with `composeStories` or `composeStory` and applying project annotations improves maintainability, but does not upgrade the Trophy layer by itself.
- If an equivalent story exists and the component test duplicates its props, decorators, or providers manually, prefer `REWRITE_AT_SAME_LAYER` unless a concrete runtime reason prevents reuse.

## Supplementary Evidence

Mutation reports are optional supporting evidence, not routing criteria.

- If a recent mutation report exists and meaningful mutants survive, use that as additional support for `REWRITE_AT_SAME_LAYER`.
- Do not penalize a code area solely because no mutation report exists.

## Minimal Safety-Net Rule

Before removing or relocating a test, keep at least one higher-value check that protects the same business risk in the recommended layer.

## Output Template

```markdown
## Decision Summary

- Scope: <module/test-set>
- Current layer: <STATIC|INTEGRATION|E2E|UNIT>
- Recommended layer: <STATIC|INTEGRATION|E2E|UNIT|NONE>
- Final status: <KEEP_STATIC|KEEP_INTEGRATION|KEEP_E2E|KEEP_UNIT|REWRITE_AT_SAME_LAYER|MOVE_TO_STATIC|MOVE_TO_INTEGRATION|MOVE_TO_E2E|MOVE_TO_UNIT|REMOVE>
- Rationale: <1-2 sentences>

## Trophy Routing Decision

- Risk: <risk>
- Why current layer is or is not the best ROI: <reason>

## Findings by Test

- <test name>: <status>
  - Quality checks: Outcome=<0-2>, A11y=<0-2>, Behavior=<0-2>, Runtime=<0-2>, Contract=<0-2>, Visual=<0-2>, Resilience=<0-2>, Stability=<0-2>, Fidelity=<0-2>
  - Story checks when applicable: Canonicality=<0-2>, Sync=<0-2>
  - Evidence: <prod path#Lx>, <test path#Ly>, <doc URL>, <source permalink>

## Recommended Moves

- <test name> -> <destination layer> because <reason>

## Higher-Value Scenarios to Add

1. <risk -> recommended layer -> expected oracle>

## Residual Risk

- Remaining gaps:
- Mitigation:
```
