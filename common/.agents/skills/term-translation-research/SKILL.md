---
name: term-translation-research
description: >
  Research evidence-backed translations and established terms across
  domain-specific, industry, and general usage. Use when selecting
  English/Japanese terminology, validating standard translations, resolving
  product wording collisions, or proposing audience-specific term usage with
  citations.
---

# Term Translation Research

Use this skill to recommend term translations with explicit evidence, audience
scope, and adoption status. Treat "domain-specific", "industry", and "general"
usage as separate layers rather than collapsing them into one answer.

## Core Rules

- Ground every recommendation in cited sources or explicitly mark it
  `unverified`.
- Prefer official, primary, and product-maintained sources over secondary
  summaries.
- Separate a concept decision from a wording decision: first define the concept,
  then compare candidate terms.
- Do not call a wording an established term merely because it is understandable
  or frequent in search results.
- Use finite candidate statuses: `established`, `preferred`, `acceptable`,
  `descriptive`, `avoid`, or `unverified`.
- Always classify proposals into local fixes and fundamental solutions.

## Workflow

1. Define the term problem.
   - Identify source term, target language, concept definition, domain, target
     audience, product surface, and known collisions.
   - If the user provides an internal page, glossary, repository, or design
     artifact, treat it as domain-specific evidence and inspect it before public
     sources.
   - If the missing context would change the recommendation, ask one concise
     question. Otherwise proceed and list assumptions.

2. Gather evidence by layer.
   - Domain-specific: internal glossaries, product UI, code identifiers, Notion
     pages, design files, support docs, and brand guidelines.
   - Industry: standards bodies, government ministries, international
     organizations, professional associations, academic glossaries, and
     product-maintained terminology portals.
   - General: dictionaries, public-sector explainers, general audience guides,
     style guides, and mainstream usage.
   - Use search counts, blogs, and generated summaries only as weak supporting
     evidence, never as the deciding source.

3. Load the detailed reference when making a recommendation.
   - Use [REFERENCE.md](references/REFERENCE.md) for the source hierarchy,
     evidence fields, status definitions, red flags, and output schema.
   - Load only the relevant sections if the task is narrow.

4. Compare candidates.
   - For each candidate, check concept fit, source authority, adoption breadth,
     audience clarity, collision risk, brand/product fit, and date freshness.
   - Distinguish "technically correct for specialists" from "clear for general
     users".
   - When two terms collide, prefer preserving the higher-authority established
     term and rename the lower-authority product or general label.

5. Recommend usage by audience.
   - If one candidate is clearly established for the target layer, recommend it.
   - If no established term exists, say so and propose a `preferred` or
     `descriptive` alternative with caveats.
   - If specialist and general-audience needs differ, provide a use-by-audience
     table rather than forcing one term.

## Output Shape

Use this structure for substantive answers:

1. **Decision**: recommended term, target audience, and status.
2. **Use By Audience**: domain-specific, industry, and general usage.
3. **Evidence Matrix**: candidate, layer, status, source authority, fit, risks.
4. **Local Fixes**: immediate wording or collision-resolution choices.
5. **Fundamental Solutions**: glossary, termbase, naming policy, or review
   workflow changes that address root causes.
6. **Unknowns**: missing sources, stale evidence, or follow-up validation.

Keep citations close to the claim they support. Prefer concise paraphrase over
long quotations.
