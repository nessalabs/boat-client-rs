---
id: "waits"
title: "Observe readiness and deletion honestly"
kind: "statechart"
status: "implemented"
summary: "A wait stops observing when its budget ends; the remote operation can
  continue."
parent: "boat-client"
sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
sources:
  [
    "src/wait.rs",
    "src/types.rs",
    "src/types/lifecycle.rs",
    "tests/runtime_regressions.rs",
  ]
diagramLinks: {}
model: { "spec": "tla/waits.tla", "config": "tla/waits.cfg" }
diagramDetails:
  [
    {
      "diagram": 0,
      "node": "TimedOut",
      "section": "Which result finishes which wait",
    },
  ]
modelCheck:
  sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
  checker: tlc-1.7.4
  date: 2026-11-03T08:52:21.274Z
  config: tla/waits.cfg
  modelDigest: c0a12916d01a4e57119e8b1b859c924623ef7b84b2ba4f5fcf4d43f2f164cbcf
  states: 8
  held:
    - OnlyCompleted
  broke: []
  unchecked: []
---

A wait stops observing when its budget ends; the remote operation can continue.

Suppose deletion returned an operation ID, then the sandbox vanished from ordinary listing. Keep the deletion ID and poll that operation. Only status `completed` ends the deletion helper successfully. `blocked`, `pending`, unknown noncompleted status and hidden sandbox visibility do not establish cleanup. A five-minute timeout is the caller's default observation budget, not a backend completion promise.

```mermaid
stateDiagram-v2
    [*] --> Observing
    Observing --> Observing: Pending or blocked deletion
    Observing --> Completed: Operation status is completed
    Observing --> TimedOut: Whole wait budget expires
    Observing --> StoppedLocally: Caller drops wait
```

## Which result finishes which wait

| Helper   | Success or terminal rule                                                     |
| -------- | ---------------------------------------------------------------------------- |
| Ready    | Sandbox state is operable; terminal-failure states return an error           |
| Idle     | State is exactly Idle; terminal-failure states return an error               |
| Prompt   | Returns a terminal run for either finished or failed; caller inspects status |
| Desktop  | Nonempty desktop URL and provisioning is not true                            |
| Deletion | Only operation status completed                                              |

A nonzero timeout bounds HTTP attempts, retry sleeps and poll sleeps together. Budget checks occur before and after each awaited operation. Zero disables this deadline. Dropping the wait stops local polling, not the server's work. Desktop polling repeatedly calls its desktop endpoint and can carry the explicit public-access request; do not confuse it with a pure local readiness flag.

## Model coverage

The deletion model varies operation status and sandbox visibility independently. Completion captures the actual accepted status and requires completed. Its negative control treats blocked as success. HTTP errors/deadlines and other readiness predicates are documented source contracts, not modeled clock or service-progress guarantees.
