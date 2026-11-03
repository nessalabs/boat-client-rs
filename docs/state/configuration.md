---
id: "configuration"
title: "Choose credentials, scope and budgets"
kind: "contract"
status: "implemented"
summary: "Configure an authenticated client explicitly, then clone it for each organization scope you need."
parent: "boat-client"
sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
sources:
  [
    "src/config.rs",
    "src/service.rs",
    "src/client.rs",
    "src/client/transport.rs",
    "src/error.rs",
  ]
diagramLinks: {}
---

Configure an authenticated client explicitly, then clone it for each organization scope you need.

`ClientConfig::new(token)` accepts an explicit nonblank token. `from_env` reads BOAT_API_KEY and optional BOAT_BASE_URL/BOAT_ORG. The base URL must use HTTPS except for loopback HTTP fixtures. `Api::new` validates retry settings and constructs one pooled HTTP client; clones share its pool.

For example, clone an existing API with `with_org(Some(org))` to call another organization without mutating the first handle. Environment routes carry `org` in their query; other operations use the wallet header. Clearing scope with `with_org(None)` means personal environment scope but the server's active wallet for sandbox operations. Explicit `personal` selects personal billing. A scope is a request parameter, not a local authorization proof.

| Budget            | Default and meaning                                                  |
| ----------------- | -------------------------------------------------------------------- |
| Connection        | 10 seconds to establish the connection                               |
| Request           | 60 seconds per HTTP request                                          |
| Command           | Maximum of request timeout and command timeout plus 15 seconds slack |
| Buffered response | 64 MiB, checked against declared size and each received chunk        |
| GET attempts      | Three total, including the first; mutations get one                  |

A polling helper has its own whole-operation deadline in addition to these per-request settings. Zero wait timeout means unlimited observation, not instant failure.

## Diagnostics and sensitive data

Transport tracing records static operation names, method, attempt count, duration, status and error category, not URLs, headers or payloads. HTTP errors strip their URL; server messages and response bodies are omitted from ordinary error formatting but remain available for deliberate handling. Content-bearing model Debug implementations redact content. This does not make every arbitrary config string, server code/request ID, application log or child output secret-free. Do not put credentials in handoff plans or evidence references.

These are configuration/value contracts. HTTP delivery ownership is explained in [retries](http-retries.md); no persistent lifecycle is invented for immutable options.
