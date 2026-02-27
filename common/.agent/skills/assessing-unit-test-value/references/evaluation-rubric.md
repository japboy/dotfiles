# Evaluation Rubric

## Scope

This rubric is optimized for UI client-side unit tests.

## Scoring Dimensions (0-2 each)

Score each test on all ten dimensions.

| Dimension | 0 | 1 | 2 |
|---|---|---|---|
| Non-tautology | Mirrors implementation logic | Partial duplication | Independent behavioral oracle |
| ROI placement | Better suited for integration layer | Ambiguous layer fit | Clear high-value unit scope |
| Sociability coverage | No real collaborator path | Limited collaborator path | Critical collaborator path covered |
| Refactor resilience | Breaks on harmless refactor | Moderate coupling | Stable under internal refactor |
| Framework independence | Mostly framework semantics | Mixed framework/domain | Domain-specific behavior focused |
| Behavioral observability | Internal branch only | Partial external behavior | Clear user-visible outcome |
| Contract coverage | No contract risk assertion | Partial contract checks | Explicit boundary compatibility verified |
| Fidelity level | Heavy fragile mocks | Mixed doubles with gaps | High-fidelity collaborators/fakes/contracts |
| Mutation effectiveness | Critical mutants survive | Partial mutation signal | Strong kill signal on meaningful mutants |
| Determinism stability | Intermittent/flaky | Rare instability | Stable across reruns |

## Aggregate Interpretation

- 16-20: `KEEP`
- 11-15: `REWRITE`
- 6-10: `MOVE_TO_INTEGRATION`
- 0-5: `REMOVE`

## Override Rules

Apply these rules before finalizing aggregate status:

1. If `Framework independence = 0` and `Behavioral observability = 0`, status cannot be `KEEP`.
2. If `Contract coverage = 0` on a contract-critical UI path, prefer `MOVE_TO_INTEGRATION` regardless of aggregate score.
3. If `Determinism stability = 0`, status cannot be `KEEP`.
4. If `Mutation effectiveness = 0` on a critical path, cap status at `REWRITE` until replacement coverage is added.
5. If missing failure mode is cross-module propagation, prefer `MOVE_TO_INTEGRATION` even when aggregate is 11-15.

## Minimal Safety-Net Rule

Before removing any test, keep at least one test that protects the same business risk at a higher-value layer (contract or integration).

## Output Template

```markdown
## Decision Summary

- Scope: <module/test-set>
- Final status: <KEEP|REWRITE|MOVE_TO_INTEGRATION|REMOVE>
- Rationale: <1-2 sentences>

## Findings by Test

- <test name>: <status>
  - Scores: Nontautology=<0-2>, ROI=<0-2>, Sociability=<0-2>, Resilience=<0-2>, Framework=<0-2>, Behavior=<0-2>, Contract=<0-2>, Fidelity=<0-2>, Mutation=<0-2>, Stability=<0-2>
  - Evidence: <prod path#Lx>, <test path#Ly>, <doc URL>, <source permalink>

## Contract/Integration Scenarios to Add

1. <UI trigger -> boundary payload -> contract assertion -> rendered result>

## Risk After Change

- Remaining gaps:
- Mitigation:
```