# Security

Continue Later Skills is local-first. It does not run a hosted service and does not upload data by itself.

## What It Reads

- Git metadata and diffs from the current repo.
- Optional local Claude/Cursor JSONL transcripts under `~/.claude/projects` and `~/.cursor/projects` when transcript excerpts are enabled.
- Existing local assistant config files when registering hooks.

## What It Writes

- `continuation.md` or `continuation-fast.md` in the current repo root.
- Timestamped `continuation*.archive.*.md` files when replacing older handoffs.
- Installed skill files, CLI scripts, symlinks, and optional hook config entries under the user's home directory.

## Reducing Data Exposure

Use git-only fast dumps:

```bash
continue-later-fast --skip-transcript
```

or:

```bash
CONTINUE_LATER_SKIP_TRANSCRIPT=1 continue-later-fast
```

Review generated handoff files before committing or sharing them. They can contain diffs, file paths, branch names, and recent prompt text.

## Reporting Issues

Please report security issues privately by emailing the maintainer or by opening a GitHub security advisory if available on the repository. Avoid posting secrets or private transcripts in public issues.
