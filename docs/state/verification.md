---
id: "verification"
title: "Verification and its limits"
kind: "guide"
status: "reference"
summary: "Separate source review, local executable tests and bounded design checks from live cloud qualification."
parent: "boat-client"
sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
sources:
  [
    "docs/testing.md",
    "tests/client_performance.rs",
    "scripts/supported-operations.json",
  ]
diagramLinks: {}
---

Separate source review, local executable tests and bounded design checks from live cloud qualification.

The source checkpoint is this repository's inspected revision. Existing testing documents retain historical Box/live smoke evidence; that is not current Boat cloud certification. This atlas does not use real cloud credentials or create/delete remote resources.

## Reproduce local checks

Run `cargo test`, `cargo clippy --all-targets -- -D warnings`, `cargo fmt -- --check` and `cargo test --test client_performance -- --ignored --nocapture` from the repository root. The crate intentionally does not track Cargo.lock; a fresh checkout resolves dependencies. Live tests remain ignored by default. The local performance test exercises loopback HTTP bodies/request counts, not WAN/cloud latency.

For models, set NESSA_DOCS_ROOT to a built Nessa Docs checkout with canonical checker cache, then run `node scripts/state-docs/check.mjs --models --write` and `node scripts/state-docs/probe-models.mjs`. Without --models the check only validates documents. Only --write saves baseline results; negative controls run in memory. Models intentionally disable deadlock checking for terminal states and assert no fairness/liveness.

## Executed evidence

All four models passed their seven semantic invariants across 40 aggregate states. Seven finite negative controls each broke its expected invariant with none unchecked. [Baseline receipts](../../verification/state-models/baselines.json) and [negative controls with counterexamples](../../verification/state-models/negative-controls.json) retain source revisions, checker dates and final model digests. No model is an automatic execution or proof of Rust functions.

[Local check results](../../verification/state-models/local-checks.json) record successful Rust tests, strict Clippy, formatting, warning-free Rustdoc and the explicit loopback performance probe on arm64 macOS with Rust 1.99.1. The [full cargo test log](../../verification/state-models/cargo-test.log) distinguishes ignored live probes. The three 128-request loopback samples took about 17.76, 16.45 and 13.64 ms; they establish exact response/request checks in that harness, not cloud latency or a statistical baseline.

[Browser evidence](../../verification/state-models/browser.json) opened all ten pages and five diagrams in headless Chrome without page or diagram errors. [Independent reader/source/model review](../../verification/state-models/independent-review.md) found no unresolved material findings in the sampled tasks and four models. No live cloud credentials/resources were used; upstream Node fixture-provenance scripts were not rerun, and other operating systems were not qualified in this pass.
