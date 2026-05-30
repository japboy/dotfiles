# Rejected Edits

This file records rejected or intentionally avoided edits for the
`creating-skills` skill. It is negative feedback for future maintenance, not
runtime instruction.

## 2026-05-30

### Treating SkillOpt as a format specification

Decision: rejected.

Reason: SkillOpt is a research source for evaluating and iterating skill text;
it does not define Agent Skills syntax. The skill keeps SkillOpt guidance in a
review layer rather than the standard baseline.

### Shipping chronological history in `SKILL.md`

Decision: rejected.

Reason: time-ordered change history is useful for maintenance, but it is not an
activation-time procedure. It belongs in `references/CHANGELOG.md` or related
record files unless a validated runtime rule is extracted from it.

### Using `skills-ref validate` as the primary command

Decision: rejected for current package usage.

Reason: current PyPI package metadata exposes the executable as `agentskills`.
The retained command is:

```bash
uvx --from skills-ref agentskills validate ./skill-name
```

The old `skills-ref validate` spelling may still appear only when explicitly
explaining public specification examples or historical usage.
