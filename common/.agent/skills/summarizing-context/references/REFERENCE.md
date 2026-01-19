# MFR (Model-First Reasoning) Methodology Reference

## Overview

Model-First Reasoning (MFR) is a two-phase paradigm that explicitly separates **problem representation** from **problem solving**. Originally proposed for reducing hallucinations in LLM-based planning tasks, MFR is adapted here for agent-to-agent context handoff.

> "Before attempting to reason, plan, or act, the model must first construct an explicit model of the problem space. All subsequent reasoning is then constrained to operate within this model."
>
> — Kumar & Rana, "Model-First Reasoning LLM Agents" (arXiv:2512.14474)

## Theoretical Foundation

### Why Explicit Modeling Matters

LLM failures in complex tasks often arise from **representational deficiencies** rather than reasoning deficiencies:

| Problem | Cause | MFR Solution |
|---------|-------|--------------|
| Constraint violations | Implicit state tracking | Explicit constraint definition |
| Inconsistent plans | Unstated assumptions | Externalized entity/state model |
| Brittle solutions | Latent representation drift | Stable, inspectable structure |

### Two-Phase Structure

**Phase 1: Model Construction**

- Identify entities, state variables, actions, and constraints
- Do NOT propose solutions during this phase
- Output must be explicit, inspectable, and stable

**Phase 2: Reasoning Over the Model**

- Generate solutions using only the constructed model
- Actions must respect stated preconditions
- State transitions must be consistent with defined effects
- Constraints must remain satisfied at every step

## MFR Components for Context Handoff

### 1. Entities

Objects, agents, or concepts involved in the current context.

**Original MFR definition**: "The objects or agents involved in the problem (e.g., people, resources, locations)."

**For context handoff, include:**

- Files, modules, or components being worked on
- External systems or APIs involved
- Configuration objects or data structures
- User requirements or specifications
- Tools or dependencies used

**Writing guidance:**

```markdown
## Entities

- **[Name]** (`[path/reference]`): [Role and current relevance]
```

### 2. State Variables

Properties of entities that can change over time.

**Original MFR definition**: "Properties of the entities that can change over time (e.g., availability, location, status)."

**For context handoff, capture:**

- Progress percentage or milestone
- Success/failure/pending/blocked status
- Version or revision information
- Configuration values
- Test results or validation status

**Writing guidance:**

```markdown
## States

| Entity | State | Details |
|--------|-------|---------|
| [Name] | [Current status] | [Explanation with evidence] |
```

### 3. Actions

Operations that modify state, with preconditions and effects.

**Original MFR definition**: "Allowed operations that modify the state, each optionally described with preconditions and effects."

**For context handoff, categorize:**

- **Completed**: Past actions with outcomes (include preconditions that were met)
- **Pending**: Future actions with required context (include preconditions to verify)
- **Blocked**: Actions that cannot proceed (include blocker and potential resolution)
- **Recommended**: Prioritized suggestions with rationale

**Writing guidance:**

```markdown
## Actions

### Completed
- [Action] - [Outcome and impact]
  - Precondition: [What was required]
  - Effect: [What changed]

### Pending
- [ ] [Task] - [Context and priority]
  - Precondition: [What must be true before starting]

### Blocked
- [Action] - Blocked by: [Blocker description]
  - Resolution: [How to unblock]
```

### 4. Constraints

Invariants, rules, or limitations that must always be respected.

**Original MFR definition**: "Invariants, rules, or limitations that must always be respected."

**For context handoff, document:**

- **Technical**: Language versions, API limitations, performance requirements
- **Scope**: What is explicitly in/out of scope
- **Dependencies**: External systems or approvals needed
- **Temporal**: Deadlines or time-sensitive requirements
- **Business**: Non-negotiable rules from requirements

**Writing guidance:**

```markdown
## Constraints

- **[Type]**: [Description] - [Source/Reason if known]
```

## Best Practices

### Be Specific, Not Vague

Bad:

```markdown
## Entities
- The API
- Some files
```

Good:

```markdown
## Entities

- **UserService API** (`src/services/user.ts`): Handles user authentication and profile management
- **Migration Script** (`scripts/migrate-v2.sql`): Database schema changes for v2
```

### Preserve "Why" Alongside "What"

```markdown
## Actions

### Completed

- Refactored `validateInput()` to use Zod schema
  - Precondition: Zod library installed (v3.22+)
  - Effect: Previous regex-based validation replaced; now handles Unicode edge cases
  - Rationale: Issue #234 identified missing Unicode support
```

### Indicate Confidence Levels

Mark uncertain or assumed information explicitly:

```markdown
## States

| Entity | State | Details |
|--------|-------|---------|
| API Compatibility | Verified ✓ | Compatible with v2.3+ (tested) |
| Performance Impact | Estimated | <5ms overhead (not benchmarked) |
```

### Avoid Implicit Assumptions

The core principle of MFR is to prevent "reasoning performed without a clearly defined model." Apply this to handoffs:

- Do NOT assume the next agent knows project conventions
- Do NOT omit context because it "seems obvious"
- DO state constraints even if they seem self-evident

## Template

```markdown
# Context Summary: [Descriptive Title]

**Date**: YYYY-MM-DD HH:mm
**Session Goal**: [One sentence describing the primary objective]
**Handoff Reason**: [Why this context is being preserved]

## Entities

- **[Name]** (`[path/reference]`): [Role and relevance]

## States

| Entity | State | Details |
|--------|-------|---------|
| [Name] | [Status] | [Explanation] |

## Actions

### Completed

- [Action] - [Outcome]
  - Effect: [What changed]

### Pending

- [ ] [Task] - [Context]
  - Precondition: [What must be true]

### Blocked (if any)

- [Action] - Blocked by: [Description]

### Recommended Next Steps

1. [Highest priority action with rationale]
2. [Secondary action]

## Constraints

- **[Type]**: [Description]

## Additional Notes

[Information that does not fit above categories but is relevant for handoff]
```

## Example: Feature Implementation Handoff

```markdown
# Context Summary: User Profile Avatar Upload

**Date**: 2025-01-19 14:30
**Session Goal**: Implement avatar upload functionality for user profiles
**Handoff Reason**: Session ending; validation and testing remain

## Entities

- **AvatarUpload Component** (`src/components/AvatarUpload.tsx`): New React component for image selection and preview
- **uploadAvatar API** (`src/api/user.ts`): Endpoint wrapper for POST /users/{id}/avatar
- **ImageProcessor** (`src/utils/image.ts`): Client-side image resizing utility
- **PRD Section 4.2**: Requirements specification for file validation

## States

| Entity | State | Details |
|--------|-------|---------|
| AvatarUpload Component | 80% Complete | UI done, validation pending |
| uploadAvatar API | Complete ✓ | Tested with mock server |
| ImageProcessor | Complete ✓ | Supports JPEG, PNG, WebP |
| Backend endpoint | Deployed | Available on staging environment |

## Actions

### Completed

- Created AvatarUpload component with drag-and-drop support
  - Effect: Users can drag files or click to select
- Implemented client-side image resizing to 256x256
  - Effect: All uploaded images normalized to standard size
- Added uploadAvatar API wrapper with retry logic
  - Effect: 3 retry attempts with exponential backoff

### Pending

- [ ] Add file type validation (JPEG, PNG only)
  - Precondition: PRD Section 4.2 specifies allowed types
- [ ] Implement upload progress indicator
  - Precondition: Design mockup in Figma (link in PRD)
- [ ] Write unit tests for ImageProcessor
  - Precondition: Jest configured in project

### Recommended Next Steps

1. Complete file type validation - Spec in PRD section 4.2; straightforward implementation
2. Add E2E test for full upload flow - Ensures integration works end-to-end

## Constraints

- **Technical**: Max file size 5MB (backend returns 413 for larger files)
- **Technical**: Images must be resized client-side before upload (bandwidth optimization)
- **Scope**: GIF animation support explicitly deferred to v2 per product decision
- **Dependencies**: Backend avatar endpoint must be deployed (currently on staging only)

## Additional Notes

Designer requested rounded preview (border-radius: 50%). CSS is in place but may need adjustment based on final review. Design review scheduled for next sprint.
```

## References

- Kumar, G. & Rana, A. (2025). "Model-First Reasoning LLM Agents: Reducing Hallucinations through Explicit Problem Modeling." arXiv:2512.14474v1. https://arxiv.org/abs/2512.14474
