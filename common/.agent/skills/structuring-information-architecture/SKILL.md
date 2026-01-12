---
name: structuring-information-architecture
description: Analyze the current context (code, docs, specs) and organize it into an Information Architecture (IA) YAML model: domain objects, organization, navigation, terminology, and search.
license: Apache-2.0
compatibility: Designed for Claude Code and similar agents that can load repositories and docs into context.
metadata:
  author: information-architecture-lab
  version: "0.1.0"
---

# Structuring Information Architecture Skill

## Purpose

This skill analyzes the currently loaded context (repository, specs, design docs, etc.) and synthesizes a concise Information Architecture (IA) model as YAML. It focuses on:

- Domain / UX objects
- Organizational structures (hierarchies, lists, workspaces, taxonomies)
- Navigation patterns
- Terminology / labels
- Search & discovery patterns

If the user writes in Japanese, respond in Japanese. Otherwise, respond in the user's language.

For details about the IA YAML schema, see `references/ia-dsl.md`.

## When to use

Use this skill when:

- The user mentions information architecture / IA / 情報設計 / navigation structure.
- The user asks to 整理 or 構造化 an existing project by IA.
- The context already includes a repository or substantial spec/design content.

Avoid this skill when:

- The context is a single small script with no meaningful domain or navigation.
- The user only wants low-level code explanation or bug fixing.

## Workflow

When this skill is active, follow this checklist.

### 1. Determine scope and language

- Detect the user's language from recent messages.
- Infer scope from:
  - Repo root or subdirectory names currently loaded.
  - High-level docs (README, ADRs, specs).
- If scope is ambiguous, write a short honest description in `ia.scope` and mark assumptions in text.

### 2. Collect IA signals from context

Look for:

- Domain / UX objects
  - Entities, models, schemas, DB tables
  - GraphQL/OpenAPI/protobuf types, domain entities
- Organization structures
  - Hierarchies (e.g. organization > workspace > project > task)
  - Lists, workspaces, folders, teams, groups
  - Facets / taxonomies (status, owner, tag, category, etc.)
- Navigation
  - Route configs and page components
  - Layout and navigation components (sidebar, app shell, etc.)
  - Major sections and flows
- Labels / terminology
  - UI text, headings, button labels, i18n strings
  - Domain terms in docs and comments
- Search & discovery
  - Search endpoints and query parameters
  - Search bars and filter panels
  - GraphQL queries with filters/sorting

Distinguish observed facts from reasonable inferences. Mark inferences as such later in YAML `notes`.

### 3. Build the IA YAML model

Produce a compact but representative YAML model with this structure:

```yaml
ia:
  scope: "<short description of the system or feature>"
  goals:
    - "<business or user goal 1 (mark as assumption if inferred)>"
    - "<business or user goal 2>"

  objects:
    - name: "<ObjectName>"
      kind: core | supporting | meta
      description: "<short description based on context>"
      attributes:
        - name: "<attributeName>"
          type: "<string|number|enum|date|id|... (approximate)>"
          notes: "<optional; indicate if inferred or exact>"
      states:
        - "<state1>"
        - "<state2>"
      actions:
        - "<actionName>"

  organization:
    structures:
      - name: "<structureName>"
        pattern: hierarchy | list | workspace | folder | other
        path: "<e.g. organization > workspace > project > task>"
        primary_objects: ["<ObjectName>", ...]
        notes: "<where in the code/docs this structure is implied>"
    facets:
      - name: "<facetName>"
        applies_to: ["<ObjectName>", ...]
        source: attribute | derived | external
        notes: "<which field or concept it maps to>"

  navigation:
    global_nav:
      - label: "<Menu label or route group>"
        target: "<screen or route name>"
        primary_object: "<ObjectName or null>"
        notes: "<route/component/file names used as evidence>"
    key_paths:
      - name: "<pathName>"
        from: "<entry point (e.g. login, dashboard)>"
        to: "<goal (e.g. complete order checkout)>"
        steps:
          - "<step 1>"
          - "<step 2>"
        notes: "<files/endpoints/flows where this path is visible>"

  labels:
    glossary:
      - term: "<CanonicalTerm>"
        aliases: ["<alias1>", "<alias2>"]
        ui_label_ja: "<Japanese label if relevant or inferable>"
        ui_label_en: "<English label if relevant or inferable>"
        notes: "<where this term appears; note any conflicts>"

  search:
    entry_points:
      - name: "<Search entry name or API>"
        scope: ["<ObjectName>", ...]
        default_sort: "<field + direction, if inferable>"
        facets: ["<facetName>", ...]
        notes: "<search endpoints, filters, or UI where this is defined>"
```

Guidelines:

- Aim for 3–10 `objects` that are clearly central.
- Use 1–5 `organization.structures` and 1–5 `navigation.global_nav` items, or fewer if the product is small.
- Prefer project-specific wording over generic IA jargon.
- Use `notes` to distinguish facts (with file paths) from assumptions.

### 4. Summarize rationale and open questions

After the YAML code block, always output:

```markdown
### Rationale

- ...

### Open questions

- ...
```

In **Rationale**, explain key modeling decisions and which files/directories/docs influenced them.

In **Open questions**, list concrete questions that would help refine the IA (e.g. concept boundaries, primary navigation paths, naming conflicts).

## Output format

When using this skill, the agent MUST:

1. Output **one YAML code block** starting with ` ```yaml` and rooted at `ia:`.
2. Immediately after the YAML block, output the `### Rationale` and `### Open questions` sections as shown above.

Avoid extra prose outside these structures unless necessary for clarity.
