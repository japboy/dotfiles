---
name: reviewing-xstate-architecture
description: >
  Evaluate and apply XState architectural patterns and best practices.
  Use when the user asks to "review XState implementation", "evaluate state machine architecture",
  "check XState conventions", "audit actor model design", "review state chart structure",
  or mentions XState architectural patterns and best practices.
---

# Reviewing XState Architecture

## Entities

Review the following XState v5 concepts:

- State machines / State charts
- Actor models (fromPromise, fromCallback)
- States / Parallel states / Sub states
- Events / Transitions
- Actions (assign, emit)
- Guards (basic and parameterized)
- Selectors (basic and derived)
- ActorContext (React integration)

### XState Conventions

Apply [XState conventions](./references/xstate-conventions.md):

- Naming conventions (States, Events, Actions, Guards)
- Machine definition pattern (setup + createMachine)
- Actor implementation patterns (fromPromise, fromCallback)
- Guard definition patterns (basic and parameterized)
- Actor communication patterns (emit, actor.on)
- Parallel states
- Global event handling
- Type definition rules and export policy
- State definition order (idle first, error last)
- Test strategy

### React Binding Conventions

Apply [React binding conventions](./references/react-conventions.md):

- Directory structure and file naming
- ActorContext pattern and Provider placement
- Selector pattern (basic and derived)
- Facade hook pattern
- Component 1:1 lifecycle pattern (useActor + provide)
- Event subscription pattern

## States

### Implementation under review

Analyze the provided XState implementation against conventions.

### Review feedback

Provide structured feedback:

1. **Summary**: Brief overview of the implementation quality
2. **Violations**: List convention violations with severity (error/warning/info)
   - Reference the specific convention rule
   - Show the problematic code
   - Provide corrected example
3. **Recommendations**: Suggestions for improvement beyond conventions
4. **Positive aspects**: Highlight well-implemented patterns

## Actions

Provide feedback based on official XState references. Cite specific documentation sections and code examples when giving recommendations.

Evaluate against:
- [XState conventions](./references/xstate-conventions.md) for general XState patterns
- [React binding conventions](./references/react-conventions.md) for React integration patterns

## Constraints

- Always cite official XState documentation and source code as evidence for feedback
- Never evaluate anything unrelated to XState architectural design
- Focus on XState v5 patterns (not v4)
- Reference the appropriate convention file based on review scope
