---
id: "resources"
title: "Find resource and administration ownership"
kind: "contract"
status: "implemented"
summary: "Resource operations build typed HTTP requests; Boat owns the resulting remote lifecycle."
parent: "boat-client"
sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
sources:
  [
    "src/client.rs",
    "src/client/administration.rs",
    "scripts/supported-operations.json",
    "src/types/environments.rs",
    "src/types/named_snapshots.rs",
  ]
diagramLinks: {}
---

Resource operations build typed HTTP requests; Boat owns the resulting remote lifecycle.

| Area                     | Exposed tasks                                                                                     | Local owner and important boundary                                              |
| ------------------------ | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Sandboxes                | List, create, inspect, update, stop, resume, fork, delete                                         | client.rs; stop/archive and permanent deletion are distinct                     |
| Snapshots                | List global/sandbox snapshots, latest, tree, file, download manifest, delete                      | client.rs; response bytes are bounded; deletion returns an operation            |
| Named snapshots          | Save/get/list/delete names                                                                        | client/administration.rs; naming is a server contract, not local storage        |
| Environments             | List/create/update/delete/upgrade; set/remove variables and secret files; add/remove repositories | client and administration; organization is carried in query scope               |
| Repositories and secrets | List/select repositories and read/update secret settings                                          | administration; content is sensitive and transport does not retry mutations     |
| Webhooks                 | Create/get/list/update/delete and signing-secret rotation                                         | administration; webhook delivery/signature verification is not implemented here |
| Account and policy       | Profile, limits, API-key summaries/usage and retention policy                                     | client and administration; remote service enforces permissions/quotas           |
| Access                   | Desktop, hosted port and SSH key                                                                  | client.rs; returned access information is not a readiness or cleanup proof      |

For example, deleting a snapshot or sandbox can return accepted deletion while the backend is still working or blocked. Preserve its operation ID and use [deletion observation](waits.md). The `stop_and_remove` convenience name means stop/archive by default; permanent deletion requires its explicit delete choice and returns a different response variant.

The [API reference](../api.md) gives method signatures and request/response models; [the inventory](inventory.md) enumerates all pinned operations so newer server capabilities are not accidentally advertised. External resource behavior is not formally modeled by this client atlas.
