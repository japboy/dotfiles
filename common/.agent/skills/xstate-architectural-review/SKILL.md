---
name: xstate-architectural-review
description: Review XState architectural design. Use when a user needs to evaluate their XState implementation.
---

# Entities

- State machines
- State charts
- Actor models
- States/sub states
- Events/transitions
- Actions
- Guards

## Naming conventions

- Use `dot.case` for events/transitions
    - https://stately.ai/blog/2024-01-23-state-machines-whats-in-a-name#xstate-v5-and-dotcase
- Follow official article about the conventions
    - https://stately.ai/blog/2024-01-23-state-machines-whats-in-a-name

## React bindings

- Communication between state machines should be loosely coupled through messaging via Actor Context.
    - https://stately.ai/docs/actor-model
    - https://stately.ai/docs/actors
    - https://stately.ai/docs/actions

# States

- Implementation under review
- Review feedback

# Actions

- Provide feedback based on official XState references

# Constraints

- Always cite official XState documentation and source code as evidence for feedback.
- Never evaluate anything unrelated to XState architectural design.
