# Independent reader, source and model review

Parent reviewer, separate from the atlas author. Source checkpoint:
`4d68256bb0b6a889633abc567fb09214681874db`. Read the new documentation first for
four caller decisions, then inspected production transport/wait/stream/handoff
owners, the four models, configs, control definitions and final result summaries.

## Docs-only tasks

1. **POST create lost its reply:** root → HTTP retries. Mutations receive only one
   automatic attempt; a supplied idempotency key does not enable the GET retry
   loop. Reconcile the remote effect before another submission. The page does not
   invent an endpoint-independent recovery command.
2. **Sandbox hidden while deletion is blocked:** root → waits. Preserve the deletion
   operation ID and observe that operation. Only completed is success; hidden,
   blocked and local timeout do not prove cleanup. This is stated near the example
   and in the helper comparison table.
3. **Cancel a prompt stream after submission:** root → streams. Creation is lazy;
   first poll submits, cancellation stops local observation and is not a remote
   interrupt. A terminal prompt still drains buffered/known pages. The page names
   the limited final refresh rather than promising no later backend event.
4. **Launch callback ran but receipt save failed:** root → handoff. Reload the
   receipt and reconcile actual effects. An in-flight receipt is not renewed
   permission to run the callback. Reset requires application evidence that the
   action cannot still complete and partial effects are safe.

All four questions were answerable with supporting text without opening source.
These were simulated library-reader tasks, not cloud calls or real-user research.

## Source fidelity

- `execute_bytes` derives retry safety from the actual GET method, caps attempts,
  honors the greater Retry-After/backoff and refuses an excessive delay. Decode
  runs after byte delivery, matching the no-decode-retry explanation.
- `wait_for_deletion` accepts only status completed. Other wait predicates and
  the distinction between local deadline and backend progress remain explicit.
- `next_event` checks cancellation while draining, yields pending events before
  terminal completion, validates advancing cursors and refreshes after terminal
  status observation. The docs explicitly omit an unlimited eventual-event promise.
- `run_step` commits Begin before invoking the callback; `advance` uses the old
  revision and warns that storage cancellation may still commit. The documentation
  keeps application reconciliation evidence separate from store enforcement.

The page structure preserves ownership: shared HTTP policy belongs to transport,
resource APIs provide wire inputs, waits/streams compose them, and handoff storage
is a separate application-managed boundary. Verification scripts call canonical
Nessa Docs interfaces instead of implementing another parser/checker policy.

## Adversarial model review

Checked guard-removal controls without changing invariants:

- HTTP model permits both GET/POST and transient outcomes independently; removing
  method safety permits repeat mutation, while increasing the finite attempt cap
  violates the recorded count. Timing and server idempotency remain excluded.
- Deletion model varies visibility independently of status and captures the actual
  status at acceptance. Treating blocked as success yields the intended failure.
- Stream model keeps pending events and known remaining pages independent of
  terminal knowledge. Each completion guard has a distinct control, so an empty
  current buffer cannot stand in for all pages drained.
- Handoff model admits two callers with the same old revision and keeps callback
  execution separate from Begin. Controls expose two winners or action without a
  committed Begin. It deliberately covers one boundary, not whole-plan recovery.

Final receipts report four passing baselines, seven invariants and seven expected
semantic control failures, with no unchecked rule. Model counts do not establish
implementation conformance. I inspected the definitions/results; the author ran
canonical TLC and the local Rust suites.

## Decision and limits

Pass for the new atlas and selected model/source scope. No material reader,
source-fidelity or model finding was discovered in this pass. No fabricated defect
was added merely to make the review appear adversarial. Source-level quality,
local tests, loopback performance and rendered docs have distinct evidence; live
Boat/cloud, WAN performance, other operating systems and external parser/provenance
tools remain outside this qualification. `git diff --check` passed in this review.
