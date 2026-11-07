---
id: "http-retries"
title: "Handle request failure without duplicating effects"
kind: "statechart"
status: "implemented"
summary: "After a failed mutation, reconcile its remote effect before deciding
  whether to send it again."
parent: "boat-client"
sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
sources:
  [
    "src/client/transport.rs",
    "src/config.rs",
    "src/error.rs",
    "tests/retries.rs",
  ]
diagramLinks: {}
model: { "spec": "tla/http-retries.tla", "config": "tla/http-retries.cfg" }
diagramDetails:
  [{ "diagram": 0, "node": "Failed", "section": "What retries actually do" }]
modelCheck:
  sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
  checker: tlc-1.7.4
  date: 2026-11-03T08:52:19.905Z
  config: tla/http-retries.cfg
  modelDigest: 365756272ae38da045baa02e63f5c133c67e513d9d68f5653bc97e89e98d3b2f
  states: 12
  held:
    - MutationOnce
    - AttemptBound
  broke: []
  unchecked: []
---

After a failed mutation, reconcile its remote effect before deciding whether to send it again.

For example, a create request can reach Boat before the client loses its reply. The client sends mutations only once automatically. An idempotency key supplied to an endpoint can help the server recognize retries, but it does not enable the HTTP retry loop. By contrast, a transient GET failure may retry within the configured attempt count.

```mermaid
stateDiagram-v2
    [*] --> Sending
    Sending --> Complete: Successful bounded response and decode
    Sending --> Backoff: GET and retryable failure and attempts remain
    Backoff --> Sending: Delay fits request budget
    Sending --> Failed: Mutation or permanent failure or attempts exhausted
    Backoff --> Failed: Delay exceeds request timeout
```

## What retries actually do

Retry safety is derived from the actual HTTP method, so an endpoint cannot opt a mutation into retries with a flag. Default backoff starts at 200 ms, doubles and adds jitter within a 30-second local cap. A valid Retry-After can be longer; the client uses the greater server/local delay. If that delay exceeds configured request timeout, it returns the error rather than shortening the server delay. JSON decoding happens after successful body delivery and is not retried as a new HTTP attempt.

Cancellation drops local work, including a retry sleep or in-flight request. It does not undo a delivered mutation. The full wait helpers wrap retries and sleeps in a common deadline; a standalone request sequence is not a single global request-timeout budget.

## Model coverage

The model chooses GET or POST, up to three total attempts, and a transient/nontransient result. It checks mutation delivery happens once and the attempt cap is enforced. Controls opt POST into retries and permit a fourth GET attempt. Backoff arithmetic, Retry-After dates, response byte limits, actual network delivery and server idempotency are source/test contracts outside this finite model.
