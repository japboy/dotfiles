---
name: japanese-naturalization
description: >
  Naturalize the current or referenced assistant output into
  context-appropriate Japanese while preserving meaning. Use when the user asks
  to make the previous response sound natural, remove AI-like Japanese, fix
  translationese, adjust register, or choose Japanese terminology from audience
  and domain context.
---

# Japanese Naturalization

## Purpose

Use this skill to naturalize assistant-generated Japanese so it sounds like
something a native speaker in the inferred target context would plausibly write.

This is a response-naturalization and localization skill, not a fact-checking,
summarizing, or copywriting skill. Preserve the target output's meaning, factual
claims, intent, structure, numbers, citations, links, code, and named entities
unless the user explicitly asks to change them.

## Core Principle

Define "natural Japanese" as context fit: the wording should match the likely
audience, domain, channel, register, and purpose. Do not equate naturalness with
plain language, pure Japanese vocabulary, fewer katakana words, or more kanji.

## Invocation Model

When invoked:

1. Treat the current user message as an instruction for how to naturalize the
   target output, not as the target text itself.
2. Treat the immediately previous assistant response as the default target.
3. If the user explicitly references another assistant response or earlier
   generated draft in the conversation, use that referenced output as the
   target.
4. Do not assume that quoted, fenced, or pasted text in the current user message
   is the target text. Treat it as instruction or context unless the user
   explicitly says it is the assistant output to naturalize.
5. If the target context is explicit, use it.
6. If the target context is missing, infer it from the target output and current
   conversation. State assumptions only when they affect the output or the user
   asked for notes.

## Workflow

1. Infer the communication context.
   - Identify domain, audience, channel, register, purpose, source language, and
     terminology risk.
   - Classify the target as casual chat, technical explanation, product UI,
     business document, support text, academic prose, marketing copy, or another
     explicit finite category.

2. Preserve meaning before style.
   - Keep claims, uncertainty, scope, examples, ordering, code blocks, URLs,
     file paths, citations, numbers, and proper nouns intact.
   - Do not add new evidence, promises, caveats, or persuasive claims.
   - Do not silently remove nuance to make the sentence shorter.

3. Choose terminology by context.
   - Use [terminology-traps.md](references/terminology-traps.md) for
     context-sensitive term choices that can produce unnatural or misleading
     Japanese.
   - If a term choice could change meaning and the reference does not cover it,
     inspect available local project evidence first.
   - For substantial term research, use the `term-translation-research` skill
     when available.
   - Prefer official, primary, product-maintained, or domain-specific sources
     over dictionaries and search snippets when external evidence is needed.

4. Check audience-sensitive register risks.
   - Use [audience-register-risks.md](references/audience-register-risks.md)
     when casual expressions, jokes, slang, age/generation cues, hierarchy,
     identity or attribute references, or harassment sensitivity could affect
     how the wording lands.
   - Prefer widely understood, neutral wording when the audience is mixed,
     unknown, external, or workplace-broad.
   - Preserve intentionally community-specific wording only when local evidence
     or user instruction shows it fits the target context.

5. Check notation variation and consistency.
   - Use [notation-variation-risks.md](references/notation-variation-risks.md)
     when kanji/kana choices, okurigana, same-reading kanji,
     katakana/English variants, punctuation, number style, or full-width and
     half-width forms vary within the target text.
   - Preserve intentional variation when it carries meaning, register,
     readability, quoted/source form, or local product terminology.
   - Normalize confusing variation when it makes one concept look like multiple
     concepts, hides a meaning distinction, or breaks document-level
     predictability.

6. Apply Japanese style defaults.
   - Use [japanese-style-defaults.md](references/japanese-style-defaults.md) for
     orthography and lightweight style defaults.
   - Treat these as defaults, not rules. Project style guides and target
     publication norms override them.

7. Remove translationese and AI-like stiffness.
   - Use [ai-like-japanese-patterns.md](references/ai-like-japanese-patterns.md)
     as warning signs, not banned words.
   - Replace only when the alternative is more natural in the inferred context.
   - Keep technical katakana, kanji compounds, and passive constructions when
     they are normal for the domain.

8. Control register explicitly.
   - Match the user's requested tone if present.
   - Otherwise, preserve the source's communicative intent while making the
     Japanese less stiff, less literal, and less templated.
   - Avoid making a serious document casual or a casual answer overly formal.

## Output Contract

Default output:

- Return only the rewritten Japanese.
- Preserve Markdown structure when it carries meaning.
- Keep code blocks, commands, tables, links, citations, and file paths stable.

When the user asks for explanation or when a key ambiguity affects the result,
use:

```markdown
## Rewritten Japanese

...

## Notes

- Context: ...
- Terminology: ...
- Ambiguity: ...
```

## Ambiguity Handling

- If one conservative wording preserves meaning and sounds natural, use it.
- If two plausible term choices imply different concepts, ask one concise
  question before rewriting.
- If the user requested no questions, choose the safest wording and include a
  short note when notes are allowed.

## Quality Checklist

Before answering, check that:

- The rewritten text still says the same thing.
- The terminology matches the inferred audience and domain.
- The register fits the channel.
- Audience-sensitive register and harassment risks were checked when relevant.
- Natural notation variation and confusing notation inconsistency were separated
  when relevant.
- AI-like patterns were inspected but not mechanically removed.
- No new factual claim, citation, example, or recommendation was added.
- The result sounds like a plausible Japanese speaker wrote it for that context.

## Evaluation Fixtures

For examples and regression prompts, use
[evaluation-prompts.csv](references/evaluation-prompts.csv).

## Reference Map

For a complete map of runtime references, maintenance records, and source
hierarchy, use [REFERENCE.md](references/REFERENCE.md).

## Skill Improvement Feedback

When the user points out an unnatural expression, or when you notice a
potentially reusable expression problem while applying this skill, fix the
current rewrite first. Then evaluate whether the feedback should become a skill
improvement candidate. If it appears reusable, explicitly propose a bounded
skill update and name the likely destination reference file. If the user is
already asking to update or maintain the skill, apply the update using the
workflow below.

Do not silently edit the skill for a one-off preference. For skill updates from
expression feedback, use [improvement-workflow.md](references/improvement-workflow.md).
Keep updates bounded, evidence-backed, and validated. If the update involves
Agent Skills structure, metadata, validation, or SkillOpt-style review
discipline, use the `agent-skill-authoring` skill when available.
