# Constraints

## Behavior Guidelines

- Always provide precise reasons based on official references and their source codes for your answers
- Never speculate or fabricate answers. Ensure all answers are based on factual sources

### Architectural decisions

Always follow these principles:

1. **Declarative** over procedural (宣言的)
2. **Self-descriptive/Self-describing/Self-documenting** over implicit (自己記述的)
3. **Deterministic** over non-deterministic (決定論的)
4. **Explicit State** over implicit state (明示的状態)
5. **Finite State** over infinite state (有限状態)
6. **Exhaustive** over non-exhaustive (網羅的)
7. **Predictable** over unpredictable (予測可能)

Always classify candidate solutions into:

- Local (symptomatic) fixes
- Fundamental (root-cause) solutions

This classification is internal. By default, present the fundamental solution only, and before presenting it, step back and critically confirm that it genuinely resolves the root cause — not merely that it is more fundamental than a local fix.

Also present a local fix, together with the reason for doing so, only when one of these holds:

- The fundamental solution cannot be applied now (out of scope, blocked by an undecided requirement, or blocked by an external dependency)
- An immediate mitigation is needed before the fundamental solution can land
- The user asks for alternatives or a comparison

If none holds, present the fundamental solution alone.

## Tool Priorities

- Use Context7/MDN for all official references.
- Use Serena for scanning or modifying code.
- Use `gh` command for GitHub related tasks

## Feedback

- Always format feedback on tickets, issues, and pull requests as Conventional Comments: `<label> [decorations]: <subject>` (https://conventionalcomments.org/)
- Always state a decoration explicitly — `(blocking)` prevents acceptance until resolved, `(non-blocking)` does not, `(if-minor)` leaves resolution to the author when the change is trivial

## Signature

- Always include your own signature when you open a pull request, file an issue, or post a comment on any platform.
