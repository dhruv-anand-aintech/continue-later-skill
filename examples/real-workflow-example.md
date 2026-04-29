# Real Workflow Example

This example shows the intended shape of a short Continue Later workflow on a small repo.

## Stop Work

User prompt:

```text
continue later
```

Fast handoff command:

```bash
continue-later-fast -n 3
```

Generated file:

```text
continuation-fast.md
```

Expected contents include:

- current branch and recent commits
- `git status --short`
- changed file summary
- recent human prompts, unless transcript excerpts are disabled

## Resume Work

User prompt:

```text
resume from earlier
```

Agent response should use the handoff file to report:

- current objective
- next tasks
- known blockers
- important decisions
- exact commands to restart work

## Why This Helps

The next session does not need to rediscover basic context from scratch. The handoff file sits in the repo root, so it is visible to another assistant, a teammate, or future you.
