# Reference

This document defines evidence requirements and interpretation notes for UI client-side unit-test-value reviews.

## Scope Anchor

Primary focus:

- UI client-side unit tests (component, hook, presenter/view-model, reducer/store, state machine)
- Browser-facing logic and client-server contract boundaries

## Core Thesis

Technical quality and strategic value are different questions. A technically correct test can still be low-ROI when it mirrors implementation logic, duplicates framework semantics, lacks boundary coverage, or remains unstable.

## Ten Evaluation Lenses

### 1. Tautological Test

A test is likely tautological when assertions reproduce the same logical predicate as production code with mirrored fixtures.

### 2. Testing Trophy ROI

ROI decreases when effort is concentrated in isolated unit tests while higher-value boundary confidence is missing.

### 3. Solitary vs Sociable Unit Test

Risk coverage decreases when collaborators are fully mocked and propagation paths are not exercised.

### 4. Classical vs London School

Refactoring resilience decreases when tests over-focus interaction expectations rather than externally visible behavior.

### 5. Do Not Test the Framework

Framework semantics should be trusted to framework test suites; product tests should target domain-specific behavior.

### 6. Test Behavior, Not Implementation

Value increases when assertions validate externally observable outcomes rather than internal branch/guard ordering.

### 7. Consumer-Driven Contract Testing

Client-side risks often emerge at API/BFF schema boundaries; isolated unit tests rarely prove compatibility alone.

### 8. Test Fidelity (Avoid Mock Overuse)

Higher-fidelity collaborators (real/fake/contract-backed) provide better defect detection than brittle interaction mocks.

### 9. Mutation Testing Effectiveness

Surviving mutants indicate missing assertion signal or dead test logic.

### 10. Flaky / Non-Deterministic Test Risk

Non-deterministic tests reduce trust and erode release confidence.

## Official Sources

### Existing Lens Anchors

- Martin Fowler, Unit testing terminology and styles:
  - https://martinfowler.com/bliki/UnitTest.html
- Martin Fowler, non-deterministic tests:
  - https://martinfowler.com/articles/nonDeterminism.html

### Added Lens Anchors

- Consumer-driven contracts:
  - https://martinfowler.com/articles/consumerDrivenContracts.html
  - https://docs.pact.io/
  - https://github.com/pact-foundation/pact-js
- Test fidelity and mock overuse:
  - https://testing.googleblog.com/2024/02/increase-test-fidelity-by-avoiding-mocks.html
- Mutation testing:
  - https://stryker-mutator.io/docs/stryker-js/introduction/
  - https://github.com/stryker-mutator/stryker-js

## Evidence Protocol

Attach explicit evidence for every claim:

1. Framework claim:
- Official documentation URL
- Framework source code permalink (repository path + commit + line)

2. Product behavior claim:
- Production file path + symbol + lines
- Test file path + assertion lines

3. Contract claim:
- Contract definition artifact (OpenAPI/Pact/schema)
- Boundary assertion location and expected compatibility rule

4. Mutation/stability claim:
- Mutation report excerpt (score or surviving mutants)
- Flaky evidence (rerun divergence, quarantine, intermittent failure logs)

## Recommended Higher-Value Scenario Shapes

1. UI action -> request payload -> contract verification -> response mapping -> rendered outcome.
2. State propagation across modules -> boundary event emission -> visible UI state change.
3. Failure and recovery path -> deterministic user feedback -> no flaky rerun divergence.