---
name: assessing-frontend-test-value
description: >
  Evaluate whether frontend implementation tests deliver meaningful
  defect-prevention value using the Testing Trophy as the primary decision
  model. Use when asked to assess frontend test strategy, static vs unit vs
  integration vs end-to-end layer placement, mock-heavy suites,
  browser/device realism, accessibility semantics, visual regression value,
  existing mutation reports, or flaky test risk.
---

# Assessing Frontend Test Value

## Scope

Primary target:

- Frontend implementation tests across static checks, unit tests, integration tests, and end-to-end tests
- Frontend behaviors with direct user impact, including accessibility semantics, visual regressions, browser/device behavior, and boundary compatibility
- React hooks and component tests only insofar as they compete with higher-ROI layers for the same risk
- Storybook stories and portable stories only insofar as they define canonical public component scenarios for review or reuse in tests

Out of primary scope:

- Pure backend or service-only tests with no frontend behavior impact
- Load, soak, or backend performance testing unless directly tied to a frontend regression question

## Primary Decision Model

Treat the Testing Trophy as the center of the skill.

Use this priority order when deciding where confidence should come from:

1. Static
2. Integration
3. End-to-End
4. Unit

Interpretation requirements:

- `Static` is the cheapest and broadest confidence for syntax, types, linting, schema shape, and other machine-verifiable guarantees.
- `Integration` is the default destination for most frontend behavior because it exercises multiple units together with user-visible outcomes.
- `End-to-End` is required when real browser, device, navigation, persistence, backend integration, or cross-screen workflow behavior materially affects risk.
- `Unit` is the narrowest and lowest-priority dynamic layer. Reserve it for pure local logic that cannot be protected more cheaply by static analysis or more meaningfully by integration.

Treat these as mandatory:

- Write tests. Not too many. Mostly integration.
- React hook tests and isolated component tests are not preferred destinations by default. They are exceptions when they uniquely protect local logic or semantics at lower cost.
- Tool choice does not define layer by itself. A Playwright test can be integration or end-to-end depending on runtime and mocking. A component test can be unit or integration depending on how much behavior and collaboration it exercises.
- Storybook does not create a new Trophy layer. Story-driven component tests are only an implementation pattern to use when a component test is already justified.

## Evaluation Basis

Apply the following sequence in order.

### 1. Classify the Risk

Identify what regression the test is meant to prevent:

- Static or structural rule
- Integrated frontend behavior across multiple units
- Real browser or device behavior
- Boundary contract compatibility
- Accessibility semantics
- Visual presentation or layout
- Pure local logic

### 2. Route to the Best Trophy Layer

Choose the highest-ROI layer first:

1. `MOVE_TO_STATIC`
- Use when type checks, lint rules, schema validation, contract generation, or similar static mechanisms can prevent the defect better than runtime tests.

2. `MOVE_TO_INTEGRATION`
- Use by default for most frontend behavior involving UI rendering, state propagation, router coordination, client adapters, accessibility semantics, or boundary mapping that can be validated without full production infrastructure.

3. `MOVE_TO_E2E`
- Use when the risk depends on real browser engines, real navigation, persistence, authentication flow, backend round trips, third-party integrations, multi-screen workflows, or device-specific behavior.

4. `MOVE_TO_UNIT`
- Use only when the protected logic is pure, local, and not more clearly verified by static analysis or integrated behavior.

5. `REMOVE`
- Use when the test adds negligible unique confidence beyond stronger coverage elsewhere.

### 3. Judge In-Layer Quality

After selecting the best layer, evaluate whether the current test is:

- `KEEP_*`: already in the best layer and providing strong signal
- `REWRITE_AT_SAME_LAYER`: best layer is correct, but the oracle, realism, or maintainability is weak
- `MOVE_TO_*`: current layer is wrong for the intended risk
- `REMOVE`: no unique value remains

## Detailed Review Criteria

Use these criteria after the Trophy routing decision.

1. User-Centric Observable Outcome:
- Prefer assertions tied to outcomes a user or assistive technology can perceive.

2. Accessibility Semantics:
- Prefer tests that protect accessible names, roles, focus behavior, keyboard behavior, and announcement-relevant semantics when they are part of the user contract.

3. Behavior, Not Implementation:
- Penalize tests that mainly assert internal branches, hook internals, method calls, or prop plumbing.

4. Refactor Resilience:
- Penalize tests that fail under harmless internal refactors.

5. Runtime Realism:
- Prefer runtimes that expose the browser, device, timing, network, and persistence behavior relevant to the risk.

6. Boundary Contract Confidence:
- Prefer tests that actually validate request, response, event, storage, or browser capability boundaries at the seam that matters.

7. Visual Regression Signal:
- Prefer visual or layout-sensitive oracles when the risk is fundamentally visual.

8. Flaky or Non-Deterministic Risk:
- Penalize unstable tests that reduce trust.

9. Test Fidelity:
- Prefer higher-fidelity collaborators over mocks when realistic failures matter.

10. Framework Responsibility:
- Avoid spending product-test budget on guarantees already owned by framework internals.

11. Scenario Canonicality:
- Prefer component tests whose setup comes from canonical public scenarios already defined as stories, rather than bespoke duplicated fixtures or internal state matrices.

12. Story/Test Synchronization:
- Prefer Storybook-based component tests that reuse stories through `composeStories` or `composeStory` with project annotations applied, so args, decorators, globals, and play-related setup do not drift.

## Default Biases

These biases are deliberate and should be applied unless concrete evidence overrides them.

- Bias toward `Integration` over `Unit` for frontend behavior.
- Bias toward browser-based Playwright integration or end-to-end tests when the real contract is user behavior, browser behavior, layout, focus, storage, timing, or navigation.
- Bias against direct React hook tests when the same risk is better expressed through user-visible behavior.
- Bias against isolated component tests that only verify props, state wiring, or callback plumbing.
- Bias toward story-defined public use cases over hand-written component-test fixtures when a component test is unavoidable.
- Bias against treating Storybook stories as exhaustive internal state tables. Prefer one concept or use case per story.
- Bias toward `Static` when the defect can be prevented before runtime.

## Official References Requirement

Attach concrete references for every framework-bound claim:

- Official documentation URL
- Framework source code permalink (repository path + commit + line)

Use these references for added criteria:

- Testing Trophy primary source:
  - https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications
- User-centric testing guidance:
  - Testing Library introduction: https://testing-library.com/docs/dom-testing-library/intro/
  - Testing Library query priority: https://testing-library.com/docs/queries/about/#priority
- Frontend test type and layer guidance:
  - Cypress testing types: https://docs.cypress.io/app/core-concepts/testing-types
  - Playwright browsers/projects: https://playwright.dev/docs/browsers
  - Playwright locators: https://playwright.dev/docs/locators
- Storybook story writing and story reuse guidance:
  - Storybook AI best practices: https://storybook.js.org/docs/ai/best-practices
  - Storybook writing stories: https://storybook.js.org/docs/writing-stories
  - Storybook writing tests: https://storybook.js.org/docs/writing-tests
  - Storybook stories in unit tests: https://storybook.js.org/docs/writing-tests/integrations/stories-in-unit-tests
  - Storybook portable stories in Vitest: https://storybook.js.org/docs/api/portable-stories/portable-stories-vitest
  - Storybook React portable stories source: https://github.com/storybookjs/storybook/blob/370524faae96a30d27e36efcaa2fc39cd65fab29/code/renderers/react/src/portable-stories.tsx#L46-L159
  - Storybook core portable stories source: https://github.com/storybookjs/storybook/blob/370524faae96a30d27e36efcaa2fc39cd65fab29/code/core/src/preview-api/modules/store/csf/portable-stories.ts#L73-L233
- Accessibility semantics:
  - W3C Accessible Name and Description Computation: https://www.w3.org/TR/accname-1.1/
- Boundary contracts:
  - Martin Fowler consumer-driven contracts: https://martinfowler.com/articles/consumerDrivenContracts.html
  - Pact docs: https://docs.pact.io/
  - Pact JS source: https://github.com/pact-foundation/pact-js
- Visual regression:
  - Playwright screenshot assertions: https://playwright.dev/docs/test-snapshots
- Test fidelity and mock overuse:
  - Google Testing Blog: https://testing.googleblog.com/2024/02/increase-test-fidelity-by-avoiding-mocks.html
- Mutation testing (supplementary evidence only when reports already exist):
  - StrykerJS docs: https://stryker-mutator.io/docs/stryker-js/introduction/
- Flaky or non-deterministic tests:
  - Martin Fowler: https://martinfowler.com/articles/nonDeterminism.html

## Entities

### Evaluation Target

- Production code under test
- Static checks, unit tests, integration tests, and end-to-end tests under evaluation
- Frontend runtime surfaces: DOM, CSS, router, storage, browser APIs, network client, timing, and persistence
- External contract boundaries: API schema, event payloads, storage formats, and browser capability assumptions

### Evidence

- Static rule definitions or compiler diagnostics
- Assertions, locators, fixtures, and helpers in test code
- Story files, exported story names, args, decorators, parameters, globals, loaders, and play functions when story-driven tests are involved
- Corresponding source predicates, rendering paths, and integration seams
- User-visible and assistive-technology-visible outcomes
- Cross-browser or device execution evidence
- Contract artifacts such as OpenAPI, Pact, or schema snapshots
- Visual baselines or screenshot diffs
- Optional mutation report
- Flakiness evidence

## Actions

### 1. Define the Question

Capture:

- The regression risk that must remain protected
- The current test layer
- The runtime used by the current test
- Whether a Storybook story already defines the public scenario under review
- The highest-value replacement layer if the current one is wrong

### 2. Determine the Best Trophy Layer

Apply these routing rules in order:

1. If static analysis can prevent the defect well enough, prefer `MOVE_TO_STATIC`.
2. Else if the risk is user-visible behavior spanning multiple frontend units, prefer `MOVE_TO_INTEGRATION`.
3. Else if real browser, device, backend, or full workflow realism matters, prefer `MOVE_TO_E2E`.
4. Else if the logic is pure and local, prefer `MOVE_TO_UNIT`.
5. Else if no unique risk remains, prefer `REMOVE`.

### 3. Special Rules for Hooks and Components

- A direct React hook test should be treated as `Unit` unless it uniquely protects pure local logic.
- An isolated component test should be treated as `Unit` when it mostly checks props, state, or callback wiring.
- An isolated component test may count as `Integration` only when it exercises multiple collaborating units through user-visible DOM behavior and realistic interactions.
- If the same behavior is better covered through page-level or browser-level interaction, prefer `MOVE_TO_INTEGRATION` or `MOVE_TO_E2E`.
- If a component test is still justified, prefer a story-driven pattern where each story represents a public use case or meaningful visible state, not an exhaustive internal state matrix.
- When using Storybook stories as test fixtures, prefer `composeStories` or `composeStory` and apply project annotations via `setProjectAnnotations` so decorators, globals, parameters, and related setup remain synchronized with Storybook.
- Reusing a story in a component test improves maintainability, but does not by itself upgrade the Trophy layer. Route the test by protected risk and runtime realism first.
- If a component test duplicates props, args, decorators, or providers that are already represented by an equivalent story, prefer `REWRITE_AT_SAME_LAYER` unless there is a concrete runtime reason not to reuse the story.

### 4. Evaluate In-Layer Quality

Once the best layer is chosen, judge whether the current test:

- protects user-visible outcomes
- avoids implementation coupling
- exercises realistic runtime behavior
- covers accessibility, contract, or visual guarantees when relevant
- is stable and maintainable
- reuses canonical story scenarios instead of duplicating component setup when Storybook is already the source of truth

### 5. Produce a Final Status

Use exactly one status:

- `KEEP_STATIC`
- `KEEP_INTEGRATION`
- `KEEP_E2E`
- `KEEP_UNIT`
- `REWRITE_AT_SAME_LAYER`
- `MOVE_TO_STATIC`
- `MOVE_TO_INTEGRATION`
- `MOVE_TO_E2E`
- `MOVE_TO_UNIT`
- `REMOVE`

### 6. Require Critical-Path Coverage

For critical frontend journeys such as authentication, onboarding, purchase, and destructive actions:

- Require at least one realistic non-unit test.
- Prefer `E2E` when browser or backend realism materially affects risk.
- Do not accept unit-only coverage as sufficient.
- Require no unresolved flaky evidence in the reviewed set.

If mutation reports already exist:

- Use surviving meaningful mutants as supplementary evidence of weak assertions.
- Do not penalize a code area solely because no mutation report exists.

### 7. Produce Structured Report

Output sections in this order:

1. Decision Summary
2. Trophy Routing Decision
3. Findings by Test
4. Recommended Moves
5. Higher-Value Scenarios to Add
6. Residual Risk
7. References

## Constraints

- Cite official documentation and relevant framework source code for every framework-bound claim.
- Cite concrete production and test file paths for every finding.
- Cite story file paths and export names when a Storybook story is treated as canonical test setup or evidence.
- Avoid speculation; mark unknowns explicitly.
- Preserve a minimal regression safety net when removing or relocating tests.
- Follow declarative, self-describing, deterministic, explicit-state, finite-state, self-documenting, exhaustive, and predictable reasoning.

## Additional Rubric

Use [evaluation rubric](references/evaluation-rubric.md) for routing and override rules.
Use [reference](references/REFERENCE.md) for evidence protocol and source anchors.
