# Rejected Edits

This file records rejected or intentionally avoided edits for the
`agent-skill-authoring` skill. It is negative feedback for future maintenance, not
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

## 2026-07-25

### Encoding Claude Opus 5 or GPT-5.6 Sol specifics as runtime rules

Decision: rejected.

Reason: context window sizes, thinking-disabled output artifacts, API
parameters such as verbosity and programmatic tool calling, and recommended
effort defaults describe one model on one harness. Writing them into `SKILL.md`
would turn a portable Agent Skill into a tuning document for a single model.
Only the rules that two independent vendors document convergently were promoted,
and the model-specific observations are kept in `evaluation-notes.md` with the
target stated.

### Adopting Anthropic long-context prompt ordering as portable guidance

Decision: rejected.

Reason: the "place longform data at the top, query at the end" recommendation
applies to constructing a single request. A skill author does not control where
the skill body lands in the assembled context, so adopting the rule would be
over-fitting to one vendor's request format without a mechanism to act on it.

### Adding a separate `Forward-Testing` section alongside evaluation guidance

Decision: rejected as a separate section; merged instead.

Reason: forward-testing with minimal leaked context and baseline evaluation
answer the same question and would otherwise state overlapping rules twice. The
minimal-leaked-context requirement survives inside `Evaluation and Iteration`,
where it reinforces the clean-context requirement rather than competing with it.

### Keeping the full standard field list in both `SKILL.md` and `REFERENCE.md`

Decision: rejected.

Reason: the enumerated frontmatter fields and validation rules were duplicated
verbatim across both files, which the skill's own guidance forbids. `SKILL.md`
now states the rules in prose and links the full field reference. This also
freed the lines needed to stay under the 500-line recommendation.
