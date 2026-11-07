---
id: "handoff"
title: "Resume an uncertain application handoff"
kind: "statechart"
status: "implemented"
summary: "Reload the handoff receipt after an error before deciding whether an
  external action may run again."
parent: "boat-client"
sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
sources: ["src/handoff/mod.rs", "src/handoff/file.rs", "tests/handoff.rs"]
diagramLinks: {}
model: { "spec": "tla/handoff.tla", "config": "tla/handoff.cfg" }
diagramDetails:
  [
    {
      "diagram": 0,
      "node": "Starting",
      "section": "Intent, callback and confirmation",
    },
  ]
modelCheck:
  sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
  checker: tlc-1.7.4
  date: 2026-11-03T08:52:19.224Z
  config: tla/handoff.cfg
  modelDigest: 2df4b15cbcd8f11ee80bb682e5a849de26112fe80b1a79bd40943092e8942109
  states: 5
  held:
    - SingleWinner
    - ActionAfterIntent
  broke: []
  unchecked: []
---

Reload the handoff receipt after an error before deciding whether an external action may run again.

For example, your launch callback starts the destination command, but saving Started fails. The receipt may remain Starting or the write may already have committed. Reload it and reconcile the actual destination run. Do not call the launch callback again merely because its acknowledgement was lost. A receipt records progress; the application still owns stopping the source, transferring bytes, verifying the checkpoint and starting the destination.

```mermaid
stateDiagram-v2
    [*] --> Prepared
    Prepared --> Capturing: Commit BeginCapture
    Capturing --> Captured: Confirm checkpoint reference
    Captured --> Restoring: Commit BeginRestore
    Restoring --> Restored: Confirm restore
    Restored --> Starting: Commit BeginStart
    Starting --> Started: Confirm run identity
    Capturing --> Prepared: Reconcile not applied with evidence
    Restoring --> Captured: Reconcile not applied with evidence
    Starting --> Restored: Reconcile not applied with evidence
```

## Intent, callback and confirmation

A fresh successful Begin transition grants that caller permission to perform its action once. The helper commits Begin before invoking a callback and commits confirmation after success. Callback error/cancellation leaves an in-flight phase requiring reconciliation. A stale receipt loses compare-and-exchange: the store must atomically compare the expected revision and durably commit the new one. Reloading an in-flight phase is not a new permission to run its action.

ReconcileNotApplied requires the application to verify the old action cannot still complete and make partial effects safe, then supply an evidence reference. The SDK checks the reference is nonblank; it cannot validate that external claim. Confirmation transitions can record work discovered to have completed. Never reset uncertain work based only on a timeout or missing response.

## Durable storage and limits

Plans bind source sandbox, destination sandbox and complete intent to an operation ID. Reusing that ID with another plan is rejected. Checkpoint references and optional digests are stored, not fetched or checked against actual bytes. Do not put credentials in plans, callbacks' persisted results or evidence references.

The bundled FileReceiptStore is Unix-only and uses a local application-owned directory, atomic replacement, locks and fsync. It is not cross-host coordination or a promise about network filesystems. New directories/files use private modes; existing directory permissions are not changed. Reads and writes have a configurable one-MiB default limit. A cancelled blocking store operation may still finish; load also synchronizes an existing receipt before exposing it. For distributed controllers implement the ReceiptStore contract with suitable atomic durable storage.

## Model coverage

The model represents one Begin/action boundary with two callers holding the same old revision. It checks only one wins the compare-and-exchange and that callback action follows committed intent. Controls remove revision comparison and allow action without Begin. It does not prove disk durability, application reconciliation evidence, the seven-phase receipt schema, callback idempotency or source-process safety. The [handoff API guide](../handoff.md) contains full usage examples.
