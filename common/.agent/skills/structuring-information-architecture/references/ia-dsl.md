# IA-DSL Reference

This file describes the IA YAML schema used by the `structuring-information-architecture` skill.

## Top-level structure

```yaml
ia:
  scope: string
  goals: string[]
  objects: Object[]
  organization:
    structures: Structure[]
    facets: Facet[]
  navigation:
    global_nav: NavItem[]
    key_paths: Path[]
  labels:
    glossary: Term[]
  search:
    entry_points: SearchEntry[]
```

## Field summaries

- `scope`  
  Short description of the system or feature. Mention assumptions if scope is inferred.

- `goals`  
  1–3 key business or user goals. You can mark inferred goals inline, e.g. `"assumed: ..."`.

- `objects` (`Object`)  
  Represents core domain / UX entities.

  - `name`: Canonical object name (e.g. `Project`, `Task`, `Workspace`).  
  - `kind`: `core`, `supporting`, or `meta`.  
  - `description`: 1–3 lines describing what this object represents.  
  - `attributes`: Small set of meaningful fields relevant to IA and UX.  
  - `states`: Typical lifecycle states if present (e.g. `draft`, `active`, `archived`).  
  - `actions`: Common user/system actions related to this object.

- `organization.structures` (`Structure`)  
  Main hierarchies and groupings, e.g. `organization > workspace > project > task`.

- `organization.facets` (`Facet`)  
  Filtering dimensions used in search/list UIs, such as `status`, `owner`, `tag`.

- `navigation.global_nav` (`NavItem`)  
  Major sections in the main navigation (dashboard, projects, settings, etc.).

- `navigation.key_paths` (`Path`)  
  End-to-end flows from an entry point to a goal.

- `labels.glossary` (`Term`)  
  Canonical terms, their aliases, and where they appear, to enforce consistent naming.

- `search.entry_points` (`SearchEntry`)  
  Major search surfaces and their scope, sort order, and facets.

You may attach `notes` fields to any element when needed, but keep the overall shape stable so other tools can consume the IA model reliably.
