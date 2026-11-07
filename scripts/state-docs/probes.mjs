const cases = [
  [
    "http-retries",
    "retry-mutation",
    "MutationOnce",
    '/\\ method = "GET"',
    "/\\ TRUE",
  ],
  [
    "http-retries",
    "exceed-attempt-cap",
    "AttemptBound",
    "attempts < 3",
    "attempts < 4",
  ],
  [
    "waits",
    "blocked-is-not-completed",
    "OnlyCompleted",
    'status = "completed" /\\ done\'',
    'status \\in {"blocked","completed"} /\\ done\'',
  ],
  [
    "streams",
    "finish-with-buffered-events",
    "BufferDrained",
    "/\\ pending = 0 /\\ ~more",
    "/\\ ~more",
  ],
  [
    "streams",
    "finish-before-last-page",
    "KnownPagesDrained",
    "/\\ pending = 0 /\\ ~more",
    "/\\ pending = 0",
  ],
  [
    "handoff",
    "stale-controller-wins",
    "SingleWinner",
    "/\\ revision = 0 /\\ begun'",
    "/\\ TRUE /\\ begun'",
  ],
  [
    "handoff",
    "action-without-commit",
    "ActionAfterIntent",
    "/\\ p \\in begun",
    "/\\ TRUE",
  ],
];
export const probes = cases.map(([document, name, rule, before, after]) => ({
  document,
  name,
  expectedRules: [rule],
  mutate(spec) {
    if (spec.split(before).length !== 2)
      throw new Error("Mutation target must match once");
    return spec.replace(before, after);
  },
}));
