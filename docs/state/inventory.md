---
id: "inventory"
title: "Inventory the public feature surface"
kind: "guide"
status: "reference"
summary: "The current library implements 59 pinned endpoint operations plus local observation and recovery helpers."
parent: "boat-client"
sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
sources:
  [
    "src/lib.rs",
    "scripts/supported-operations.json",
    "docs/api.md",
    "tests/sdk_operations.rs",
  ]
diagramLinks: {}
---

The current library implements 59 pinned endpoint operations plus local observation and recovery helpers.

The operation names below are the canonical parity-fixture identifiers, not Rust spellings. [The API reference](../api.md) maps them to public Rust methods and types. Source owners are `src/client.rs` and `src/client/administration.rs`; all compose the shared transport. The fixture baseline is the published SDK 1.9.7 contract retained by this repository, not a claim that every newer upstream API is implemented.

| Implemented operation         |
| ----------------------------- |
| `addEnvironmentRepo`          |
| `apiKeyUsage`                 |
| `apiKeys`                     |
| `artifact`                    |
| `sandboxes`                   |
| `command`                     |
| `commandStatus`               |
| `create`                      |
| `createEnvironment`           |
| `createWebhook`               |
| `deleteSandbox`               |
| `deleteEnvironment`           |
| `deleteEnvironmentRepo`       |
| `deleteEnvironmentSecretFile` |
| `deleteEnvironmentVar`        |
| `deleteNamedSnapshot`         |
| `deleteSnapshot`              |
| `deleteWebhook`               |
| `desktop`                     |
| `environments`                |
| `events`                      |
| `fork`                        |
| `get`                         |
| `getDataRetention`            |
| `getDeletionOperation`        |
| `getLatestSandboxSnapshot`    |
| `getNamedSnapshot`            |
| `getSnapshotDownload`         |
| `getSnapshotFile`             |
| `getSnapshotTree`             |
| `getWebhook`                  |
| `hostPort`                    |
| `interrupt`                   |
| `limits`                      |
| `listSandboxSnapshots`        |
| `listNamedSnapshots`          |
| `listSnapshots`               |
| `listWebhooks`                |
| `me`                          |
| `prompt`                      |
| `promptRunStatus`             |
| `readFile`                    |
| `repos`                       |
| `resume`                      |
| `rotateWebhookSigningSecret`  |
| `saveNamedSnapshot`           |
| `secrets`                     |
| `selectRepo`                  |
| `setEnvironmentSecretFile`    |
| `setEnvironmentVar`           |
| `sshKey`                      |
| `stop`                        |
| `update`                      |
| `updateDataRetention`         |
| `updateEnvironment`           |
| `updateSecrets`               |
| `updateWebhook`               |
| `upgradeEnvironment`          |
| `writeFile`                   |

## Helpers and infrastructure

| Feature                                                           | Owner                    | Coverage disposition                                                      |
| ----------------------------------------------------------------- | ------------------------ | ------------------------------------------------------------------------- |
| Client construction, aliases, organization clones, service naming | config, lib, service     | [Configuration contract](configuration.md)                                |
| HTTP attempts, errors, byte caps, diagnostics                     | client/transport, error  | [Retry model](http-retries.md); other boundaries source/tests             |
| Ready, idle, prompt, desktop, deletion waits                      | wait                     | [Deletion model](waits.md); clocks/other predicates source/tests          |
| Event and prompt streams                                          | stream                   | [Drain model](streams.md); cursor/filter/request behavior source/tests    |
| Exec/read_text/write_text/stop helpers                            | helpers                  | [Command/file contracts](commands-files.md)                               |
| Handoff plans, transitions, callback helpers, store abstraction   | handoff/mod              | [Begin/action model](handoff.md); full protocol source/tests              |
| Local Unix atomic receipt store                                   | handoff/file             | [Handoff storage contract](handoff.md); filesystem semantics source/tests |
| Typed wire models, nullable values and redaction                  | types and submodules     | Immutable contracts; no invented lifecycle                                |
| Examples, fixtures, live probes and SDK comparison                | examples, tests, scripts | [Verification](verification.md); live cloud explicitly excluded           |

No production app composition is implied by a standalone helper's existence. Four focused models do not constitute formal coverage of all endpoints; resource lifecycle remains the external Boat service's responsibility.
