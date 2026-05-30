# Evaluation Notes

This file records validation evidence for changes to the `creating-skills`
skill. It is update/audit context, not runtime instruction.

## 2026-05-30 Validation

Target:

- Skill: `common/.agents/skills/creating-skills`
- Validator: current PyPI `skills-ref` package via the `agentskills` executable
- Command:

  ```bash
  uvx --from skills-ref agentskills validate common/.agents/skills/creating-skills
  ```

Result:

```text
Valid skill: common/.agents/skills/creating-skills
```

Additional checks performed:

- Confirmed `SKILL.md` frontmatter description is within the 1024-character
  standard limit.
- Confirmed Markdown code fences are balanced.
- Confirmed local links from `SKILL.md` to `references/` files resolve.
- Confirmed `SKILL.md` remains below the 500-line recommendation after adding
  record/runtime separation guidance.

Evidence basis:

- Agent Skills specification and source for portable structure, frontmatter,
  progressive disclosure, and optional directories.
- OpenAI Codex skills documentation for Codex-specific discovery and
  `agents/openai.yaml` behavior.
- Claude Code skills documentation for Claude Code-specific frontmatter,
  dynamic context injection, and discovery behavior.
- SkillOpt v2 paper and arXiv source for bounded updates, validation gates,
  rejected-edit buffers, optimizer-side meta guidance, and compact deployed
  skills.
