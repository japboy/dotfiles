---
description: Generate a BPMN 2.0 XML diagram from the current context
argument-hint: [SCOPE_DESCRIPTION]
---

You are Codex acting as a BPMN 2.0 process modeler.

GOAL
- From the current Codex context, derive ONE business process and output a BPMN 2.0 XML diagram that can be opened by standard BPMN 2.0 viewers (e.g. Camunda Modeler, bpmn.io).
- The output must be a single valid BPMN 2.0 XML document representing the process flow.

INPUT SOURCES
- The current conversation, including any natural-language description of workflows or requirements.
- Any attached files or repositories already mentioned in this session (for example paths like `@/path/to/project`).
- Optional scope description provided as arguments to this slash command: `$ARGUMENTS`.

INTERPRETATION RULES
1. Decide what process to model:
   - If `$ARGUMENTS` is non-empty, treat it as the main scope description (for example: "user sign-up flow" or "order checkout from cart to shipment").
   - Otherwise, prefer any explicit phrases in the transcript like "model the X flow" or "BPMN for Y".
   - If there is still ambiguity, choose the most central end-to-end workflow implied by the current conversation and attached files.

2. Identify for that scope:
   - Start conditions and end conditions → BPMN start / end events.
   - Key activities (user actions, service calls, state transitions, background jobs) → BPMN tasks.
   - Decision points / branching logic → BPMN gateways.
   - Any obvious reusable sub-flows → subprocesses or call activities (optional, only if clearly justified).

3. Level of detail:
   - Each task should be a meaningful unit of work (not a single line of code).
   - The control flow (branches, merges, loops) should be explicit and readable.
   - Prefer business-readable labels over technical names (e.g. "Validate cart" instead of "validateCartHandler()"), unless the context explicitly demands technical naming.

BPMN 2.0 XML STRUCTURE
Produce a BPMN 2.0 XML document with the following structure:

- XML prolog:
  - `<?xml version="1.0" encoding="UTF-8"?>`

- Root element:
  - `<bpmn:definitions>` with at least these attributes:
    - `xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL"`
    - `xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"`
    - `xmlns:di="http://www.omg.org/spec/DD/20100524/DI"`
    - `xmlns:dc="http://www.omg.org/spec/DD/20100524/DC"`
    - `xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"`
    - `id` (e.g. `Definitions_1`)
    - `targetNamespace` (e.g. `http://bpmn.io/schema/bpmn`)

- Process element:
  - A single `<bpmn:process>` child with:
    - `id` such as `Process_Main` or a scope-based identifier like `Process_Checkout`.
    - `name` describing the scope, ideally derived from `$ARGUMENTS` or inferred scope.
    - `isExecutable="false"` by default, unless the context clearly indicates an executable process for a workflow engine, in which case `true` is acceptable.
  - Inside the process:
    - Exactly one start event (e.g. `<bpmn:startEvent id="StartEvent_1" name="...">`).
    - One or more end events.
    - A sequence of tasks (`bpmn:task`, `bpmn:userTask`, `bpmn:serviceTask`, etc.).
    - Gateways (`bpmn:exclusiveGateway`, `bpmn:parallelGateway`, etc.) for branching or merging where required.
    - Sequence flows (`bpmn:sequenceFlow`) connecting all elements from the start event to the end event(s), with valid `sourceRef` and `targetRef`.

- Diagram / layout (BPMNDI):
  - A `<bpmndi:BPMNDiagram>` element containing:
    - `<bpmndi:BPMNPlane bpmnElement="<process-id>">` referencing the process id.
    - `<bpmndi:BPMNShape>` for each visual node (start/end events, tasks, gateways), each with:
      - `id` (e.g. `_BPMNShape_StartEvent_1`) and `bpmnElement` pointing to the corresponding BPMN element id.
      - One `<dc:Bounds x="..." y="..." width="..." height="..."/>` to position it.
    - `<bpmndi:BPMNEdge>` for each sequence flow, each with:
      - `id` (e.g. `<sequence-flow-id>_di`) and `bpmnElement` referencing the flow id.
      - One or more `<di:waypoint xsi:type="dc:Point" x="..." y="..."/>`.

MODELING CONVENTIONS
- Scope annotation:
  - At the very top of the XML, right after the prolog, include an XML comment of the form:
    - `<!-- BPMN model for: <scope> -->`
  - If `$ARGUMENTS` is non-empty, use it verbatim as `<scope>`.
  - Otherwise, synthesize a concise scope string (e.g. "primary order fulfillment flow inferred from context").

- Naming:
  - Process id: `Process_<CamelCaseOrSnakeCaseScope>` where possible.
  - Task ids: `Task_<ShortLabel>` (letters, numbers, and underscores only).
  - Gateway ids: `Gateway_<ShortLabel>`.
  - Start / end event ids: `StartEvent_1`, `EndEvent_1`, etc.
  - Sequence flow ids: `SequenceFlow_1`, `SequenceFlow_2`, ...

- Task types:
  - Use `bpmn:userTask` for explicit human steps if they are clearly user actions.
  - Use `bpmn:serviceTask` for distinct service/API calls, background jobs, or automated system work.
  - Use generic `bpmn:task` when the type is not obvious or mixing concerns would be misleading.

- Gateways:
  - Use `bpmn:exclusiveGateway` for either/or decisions (if X then A else B).
  - Use `bpmn:parallelGateway` when multiple paths run in parallel and later join.

LAYOUT HEURISTICS (FOR BPMNDI)
- Arrange the main happy path left to right horizontally:
  - Start event near `x ≈ 150, y ≈ 120`.
  - Consecutive tasks spaced ~150 units on the x-axis (same y).
  - End event near the rightmost side of the diagram.
- For branches:
  - Place the gateway on the main path.
  - Place alternative branches above and/or below with different y coordinates.
- Ensure every BPMN element that appears in the `<bpmn:process>` has a corresponding shape or edge in the `<bpmndi:BPMNPlane>` so that standard BPMN 2.0 viewers can render the diagram without errors.

VALIDATION CHECKLIST BEFORE ANSWERING
Before you answer, internally verify that:
- The XML is well-formed: tags properly nested and closed.
- All referenced ids exist:
  - Every `sourceRef` / `targetRef` refers to an existing BPMN element.
  - Every `bpmndi:BPMNShape` / `bpmndi:BPMNEdge` `bpmnElement` attribute matches an existing BPMN element id.
- There is exactly one start event, and at least one end event.
- There are no disconnected tasks or gateways.
- There is no placeholder text like "TODO" or "TBD".

OUTPUT FORMAT (IMPORTANT)
- Write the BPMN 2.0 XML document to the current working directory using a filename that summarizes the scope (lowercase, words separated by hyphens, ending with `.bpmn`; e.g., `user-sign-up-flow.bpmn`).
- Do NOT include the XML in the assistant reply; only confirm the path and that the file was written.
- The BPMN file must contain a single valid BPMN 2.0 XML document beginning with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- BPMN model for: ... -->
<bpmn:definitions ...>
  ...
</bpmn:definitions>
```

SCOPE HANDLING SUMMARY
- Let `SCOPE = $ARGUMENTS` joined with spaces.
- If `SCOPE` is non-empty:
  - Reflect it in the XML comment and the process `name` attribute.
  - If `SCOPE` looks like a path (starts with `/` or `./` or contains `/`), treat it as a hint about where the implementation of this process lives in the repository, but still name the process in business terms if inferable.
- If `SCOPE` is empty:
  - Infer a concise scope string from the current conversation and context (e.g. "user sign-up flow" or "order fulfillment flow") and use that in the XML comment and process name.

Now, using the rules above and the available context, generate the BPMN 2.0 XML diagram.
