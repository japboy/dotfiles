---
name: assessing-unit-test-value
description: >
  Evaluate whether UI client-side unit tests deliver meaningful defect-prevention
  value or become tautological low-ROI checks. Use when asked to assess test
  strategy, unit-vs-integration investment, mock-heavy test suites, contract
  boundaries, mutation effectiveness, or flaky test risk.
---

# Assessing Unit Test Value

## Scope

Primary target:

- UI client-side unit tests (component, hook, presenter/view-model, reducer/store, state machine)
- Browser runtime behavior and UI-facing domain logic

Out of primary scope:

- Pure backend/service-only unit tests with no UI boundary impact

## Premise

Evaluate both axes explicitly:

- Technical correctness of test code
- Strategic value of test investment (confidence-per-cost and risk coverage)

Treat the following principle as mandatory:

- A technically correct unit test can still be low value when it mainly replays framework semantics or mirrors implementation predicates.

## Evaluation Basis

Use these ten named practices as fixed evaluation lenses.

1. Tautological Test:
- Detect assertions that re-express the same predicate as production logic with mirrored fixtures.

2. Testing Trophy:
- Prioritize confidence-per-cost; identify over-investment in isolated unit tests when boundary confidence is missing.

3. Sociable Unit Test vs Solitary Unit Test:
- Identify coverage gaps caused by full mock isolation across collaborator boundaries.

4. Classical (Detroit) vs London (Mockist):
- Prefer behavior and state verification resilient to refactoring over fragile interaction coupling.

5. Do Not Test the Framework:
- Avoid spending product-test budget on semantics guaranteed by framework internals.

6. Test Behavior, Not Implementation:
- Prefer externally observable outcomes over internal branch/guard implementation checks.

7. Consumer-Driven Contract Testing:
- Detect client-server contract risk not covered by isolated unit tests.

8. Test Fidelity (Avoid Mock Overuse):
- Prefer higher-fidelity doubles (real/fake/contract-backed) over brittle interaction mocks when practical.

9. Mutation Testing Effectiveness:
- Verify that tests fail under meaningful code mutations; treat surviving mutants as missed signal.

10. Flaky / Non-Deterministic Test Risk:
- Penalize unstable tests that reduce trust and block rapid regression detection.

## Official References Requirement

Attach concrete references for every framework-bound claim:

- Official documentation URL
- Framework source code permalink (repository path + commit + line)

Use these references for added criteria:

- Consumer-driven contracts: https://martinfowler.com/articles/consumerDrivenContracts.html
- Pact docs: https://docs.pact.io/
- Pact JS source: https://github.com/pact-foundation/pact-js
- Test fidelity (Google Testing Blog): https://testing.googleblog.com/2024/02/increase-test-fidelity-by-avoiding-mocks.html
- Mutation testing (Stryker JS): https://stryker-mutator.io/docs/stryker-js/introduction/
- Stryker JS source: https://github.com/stryker-mutator/stryker-js
- Flaky/non-deterministic tests (Fowler): https://martinfowler.com/articles/nonDeterminism.html

## Entities

### Evaluation Target

- Production code under test (SUT)
- Unit tests under evaluation
- UI boundary collaborators (router, storage, network client, browser APIs)
- External contract boundaries (BFF/API schema, event payloads)
- Framework/runtime responsibilities

### Evidence

- Assertions and fixtures in test code
- Corresponding source-code predicates and branches
- Public behavior observable from UI boundaries
- Contract artifacts (OpenAPI/Pact/schema snapshots)
- Mutation report (for example, Stryker score)
- Flakiness signals (rerun instability, quarantine history)

## States

- Intake: scope and decision question defined
- Traceability: each assertion mapped to source behavior and boundary risk
- Value classification: tests categorized by ROI and risk coverage
- Recommendation: keep, rewrite, relocate, or remove decision produced

## Actions

### 1. Define Decision Scope

Capture one decision question per review:

- Keep as unit test
- Move to contract/integration test
- Remove as tautological or low-signal check

Record critical regression risk that must remain protected.

### 2. Build Assertion-to-Behavior Map

For each test assertion:

1. Identify exact production predicate/branch exercised.
2. Identify externally observable UI behavior protected by the assertion.
3. Mark whether assertion duplicates implementation logic.
4. Mark whether assertion protects a client-server contract.

Use this table:

| Test | Source Predicate | Observable UI Behavior | Contract Boundary | Duplication Risk |
|---|---|---|---|---|

### 3. Classify With Ten Lenses

Apply all lenses exhaustively.

1. Tautological Test:
- Mark `High` when assertion reproduces the same logical expression as implementation with mirrored fixtures.

2. Testing Trophy ROI:
- Mark `Low ROI` when effort is concentrated in isolated unit tests while contract/integration confidence remains untested.

3. Solitary vs Sociable:
- Mark `Coverage Gap` when mocks replace collaborating modules and propagation paths are unverified.

4. Classical vs London School:
- Mark `Fragile` when tests mainly verify interactions that break under harmless refactor.

5. Don't Test the Framework:
- Mark `Framework Duplication` when tests restate framework guarantees instead of domain rules.

6. Test Behavior, Not Implementation:
- Mark `Implementation-Coupled` when assertions target internal branches/guards over UI-visible outcomes.

7. Consumer-Driven Contract Testing:
- Mark `Contract Gap` when request/response schema compatibility is critical but not verified.

8. Test Fidelity:
- Mark `Low Fidelity` when heavy mocks hide realistic collaborator behavior available via stable fakes/contracts.

9. Mutation Testing Effectiveness:
- Mark `Weak Kill Signal` when meaningful mutants survive without test failure.

10. Flaky / Non-Deterministic Risk:
- Mark `Unstable` when repeated runs diverge under unchanged code.

### 4. Score Decision

Assign one status per test:

- `KEEP`: protects unique UI behavior/contract risk with high signal.
- `REWRITE`: intent valid, but assertions are implementation-coupled or low-fidelity.
- `MOVE_TO_INTEGRATION`: value appears mainly across contract or multi-module boundaries.
- `REMOVE`: tautological/framework-duplication with negligible incremental confidence.

### 5. Propose Replacement Scenarios

When status is `MOVE_TO_INTEGRATION` or `REMOVE`, define at least one higher-value scenario including:

- Trigger event sequence
- State/data propagation path
- Observable UI output at boundary
- Contract verification point (schema/payload/status)
- Failure mode prevented

Recommended scenario patterns:

1. UI action emits request payload; contract check validates schema; UI renders mapped response state.
2. Offline/online transition propagates through state modules and updates visible UI affordances.
3. Recoverable API failure triggers fallback path and deterministic user feedback.

### 6. Require Stability and Mutation Evidence for Critical Paths

For critical UI flows (authentication, purchase, destructive actions):

- Require documented mutation score trend or targeted mutant checks.
- Require no unresolved flaky-test evidence in the reviewed set.

### 7. Produce Structured Report

Output sections in this order:

1. Decision Summary
2. Findings by Test (with status)
3. Evidence Table
4. Contract/Integration Scenarios to Add
5. Risk After Change
6. References

## Constraints

- Cite official documentation and relevant framework source code for every framework-bound claim.
- Cite concrete production/test file paths and symbols for every finding.
- Avoid speculation; mark unknowns explicitly.
- Preserve a minimal regression safety net when removing tests.
- Follow declarative, self-describing, deterministic, explicit-state, finite-state, self-documenting, exhaustive, and predictable reasoning.

## Additional Rubric

Use [evaluation rubric](references/evaluation-rubric.md) for scoring thresholds and override rules.
Use [reference](references/REFERENCE.md) for evidence protocol and source anchors.