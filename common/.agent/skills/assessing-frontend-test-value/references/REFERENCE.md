# Reference

This document defines evidence requirements and interpretation notes for frontend test-value reviews centered on the Testing Trophy.

## Core Position

The Testing Trophy is the primary decision model for this skill.

Interpret it as a guide to confidence-per-cost:

- Static checks provide the cheapest and broadest defect prevention.
- Integration tests are the default dynamic layer for frontend behavior.
- End-to-end tests are necessary when realistic browser, device, workflow, or backend behavior matters.
- Unit tests are the narrowest and least-preferred dynamic layer, reserved for pure local logic and hard-to-reach edge logic.

For this skill, layer selection comes before in-layer quality scoring.

Storybook stories and portable stories do not add a new layer to the Testing Trophy. They are a way to define canonical component scenarios and, when component tests are justified, to reuse those scenarios without duplicating setup.

## Primary Source Understanding

Kent C. Dodds describes the Testing Trophy as a return-on-investment guide for testing JavaScript applications, not a neutral taxonomy. He further explains:

- end-to-end tests are where you validate behavior with as little mocking as practical
- unit tests are tests of single logic-containing units with collaborators absent or mocked
- integration tests are tests of multiple units integrating with one another

Source:

- https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications

## Frontend Interpretation Rules

### 1. Static First

If the risk can be prevented via typing, linting, schema validation, generated contracts, or comparable static guarantees, prefer `STATIC`.

### 2. Mostly Integration

For most frontend behavior, prefer `INTEGRATION`. This includes:

- UI rendering with user-visible assertions
- router and state propagation
- accessibility semantics that can be observed from the DOM and interactions
- contract mapping from boundary data into UI state

### 3. Selective End-to-End

Prefer `E2E` when the risk materially depends on:

- real browser engines
- real navigation and persistence
- multi-screen flows
- backend round trips
- auth and session behavior
- device-specific or timing-sensitive behavior

### 4. Minimal Unit

Prefer `UNIT` only when the logic is:

- pure
- local
- not well prevented statically
- not more clearly verified through integrated behavior

### 5. Hooks and Components Are Forms, Not Primary Strategies

Direct hook tests and isolated component tests are not top-level strategic destinations. They should be classified according to what they actually validate:

- pure local logic -> `UNIT`
- multiple frontend units through user-visible DOM behavior -> `INTEGRATION`
- mere plumbing or implementation detail -> usually low ROI

### 6. Story-Driven Component Tests Are Exception Patterns

When a component test is justified, Storybook may be the best place to define the canonical public scenarios for that component.

- Treat a story as a public use case or meaningful visible state, not as an exhaustive matrix of internal implementation states.
- Prefer one concept or use case per story, with enough description to explain why the scenario matters.
- Prefer reusing stories in tests through `composeStories` or `composeStory` and applying `.storybook/preview` annotations through `setProjectAnnotations`.
- Reusing stories improves synchronization and maintainability, but does not change Trophy routing by itself.
- If a component test hand-recreates props, decorators, or providers that an equivalent story already defines, treat that duplication as lower quality unless the test requires a materially different runtime.

## Secondary Quality Checks

After choosing the best Trophy layer, evaluate quality with these secondary checks:

- user-visible outcome
- accessibility semantics
- runtime realism
- boundary confidence
- visual signal
- refactor resilience
- implementation coupling
- flake risk
- fidelity of collaborators

These checks refine `KEEP` versus `REWRITE`, but they do not replace the Trophy routing decision.

## Supporting Sources

### User-Centric Testing

- Testing Library introduction:
  - https://testing-library.com/docs/dom-testing-library/intro/
- Testing Library query priority:
  - https://testing-library.com/docs/queries/about/#priority
- DOM Testing Library source:
  - https://github.com/testing-library/dom-testing-library

### Frontend Layer Selection

- Cypress testing types:
  - https://docs.cypress.io/app/core-concepts/testing-types
- Playwright browsers and projects:
  - https://playwright.dev/docs/browsers
- Playwright locators:
  - https://playwright.dev/docs/locators
- Playwright source:
  - https://github.com/microsoft/playwright

### Storybook Stories and Portable Stories

- Storybook AI best practices:
  - https://storybook.js.org/docs/ai/best-practices
- Storybook writing stories:
  - https://storybook.js.org/docs/writing-stories
- Storybook writing tests:
  - https://storybook.js.org/docs/writing-tests
- Storybook stories in unit tests:
  - https://storybook.js.org/docs/writing-tests/integrations/stories-in-unit-tests
- Storybook portable stories in Vitest:
  - https://storybook.js.org/docs/api/portable-stories/portable-stories-vitest
- Storybook React portable stories source:
  - https://github.com/storybookjs/storybook/blob/370524faae96a30d27e36efcaa2fc39cd65fab29/code/renderers/react/src/portable-stories.tsx#L46-L159
- Storybook core portable stories source:
  - https://github.com/storybookjs/storybook/blob/370524faae96a30d27e36efcaa2fc39cd65fab29/code/core/src/preview-api/modules/store/csf/portable-stories.ts#L73-L233

### Accessibility Semantics

- W3C Accessible Name and Description Computation:
  - https://www.w3.org/TR/accname-1.1/

### Boundary Contracts

- Martin Fowler consumer-driven contracts:
  - https://martinfowler.com/articles/consumerDrivenContracts.html
- Pact docs:
  - https://docs.pact.io/
- Pact JS source:
  - https://github.com/pact-foundation/pact-js

### Visual Regression

- Playwright screenshot assertions:
  - https://playwright.dev/docs/test-snapshots

### Test Fidelity and Mock Overuse

- Google Testing Blog:
  - https://testing.googleblog.com/2024/02/increase-test-fidelity-by-avoiding-mocks.html

### Mutation Testing

- StrykerJS docs:
  - https://stryker-mutator.io/docs/stryker-js/introduction/

### Flaky Tests

- Martin Fowler:
  - https://martinfowler.com/articles/nonDeterminism.html

## Evidence Protocol

Attach explicit evidence for every claim.

1. Trophy routing claim:
- current layer
- recommended layer
- concrete risk that justifies the move

2. Framework claim:
- official documentation URL
- framework source code permalink with commit and lines

3. Product behavior claim:
- production file path and symbol
- test file path and assertion lines
- story file path and export name when the test reuses Storybook state

4. Accessibility claim:
- role, name, focus, or keyboard expectation
- locator or assertion location

5. Runtime claim:
- browser, device, or runtime used
- evidence that the failure mode is or is not exposed there

6. Visual claim:
- screenshot assertion or baseline location
- diff artifact or approval rule

7. Contract claim:
- contract definition artifact
- boundary assertion location

8. Mutation and stability claim:
- optional mutation report excerpt
- flaky evidence

9. Storybook reuse claim:
- evidence that `composeStories` or `composeStory` is used
- evidence that `setProjectAnnotations` or equivalent project-level annotation setup is applied when required
- evidence that the story represents a public use case rather than internal state enumeration

## Recommended Higher-Value Scenario Shapes

1. Static rule or schema validation prevents the defect before runtime.
2. Integrated frontend behavior exercises rendered output, state propagation, and boundary mapping through user interactions.
3. Browser-level flow validates navigation, persistence, timing, and backend response in a real engine.
4. Accessible interaction validates role, name, focus, and keyboard semantics.
5. Visual regression validates layout, theming, overflow, or responsive behavior through a visual oracle.
6. Story-driven component test reuses a canonical story scenario to verify component-specific behavior that is not better protected by higher Trophy layers.
