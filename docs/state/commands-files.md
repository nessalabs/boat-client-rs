---
id: "commands-files"
title: "Run commands and transfer bounded files"
kind: "contract"
status: "implemented"
summary: "Choose synchronous JSON results or detached command observation before sending a command."
parent: "boat-client"
sourceRevision: "4d68256bb0b6a889633abc567fb09214681874db"
sources:
  [
    "src/client.rs",
    "src/helpers.rs",
    "src/types/commands.rs",
    "tests/boat_command_stream.rs",
    "tests/api_contracts.rs",
  ]
diagramLinks: {}
---

Choose synchronous JSON results or detached command observation before sending a command.

A normal command returns JSON under a request timeout that covers the requested command budget plus configured slack. The convenience exec helper supplies a 30-second command default. Synchronous `stream: true` is rejected before HTTP because this client has no command NDJSON decoder; no command is launched by that refusal. Detached commands use the documented server behavior of ignoring stream and can be followed through command_status. Transport errors after delivery still require reconciliation, not blind replay.

File reads/writes use explicit paths and encoding. read_text returns content as UTF-8 text (or an empty value when the response omits content); write_text sends UTF-8. Binary content and artifact/snapshot downloads remain byte/encoding contracts. Response buffering is capped even for downloads; this is not a streaming filesystem or an atomic compare-and-swap editor API. A failed write response does not prove the destination file is unchanged.

Prompt submission, prompt status and interrupt are separate endpoint operations. Cancelling a local prompt stream does not call interrupt. Desktop access, hosted ports and SSH keys provide remote access information; the application chooses public access and must handle credentials deliberately. None of these helpers implements the remote process supervisor or verifies cloud cleanup.

For executable usage see the existing [SDK guide](../guide.md). Shared delivery policy is [HTTP retries](http-retries.md), while completion observation is [waits](waits.md). This page documents endpoint/value contracts; remote command/file lifecycle is an external-service boundary rather than an invented local state machine.
