---
name: continue-later-fast
description: Run continue-later-fast from PATH (installed to ~/.local/bin by install.sh) from the project git root, or ~/.config/continue-later/continue-later-fast.sh. Writes continuation-fast.md (git + recent prompts). No LLM summary.
---

# Continue Later Fast

## Do this

After **`curl … | bash install`** (see repo README), the CLI bundle lives in **`${XDG_CONFIG_HOME:-~/.config}/continue-later/`** and a **`continue-later-fast`** symlink is added under **`${CONTINUE_LATER_BIN_DIR:-~/.local/bin}`** (ensure that directory is on `PATH`). From **any directory**, `cd` to the **git repository root** of the project being handed off, then run:

```bash
continue-later-fast -n 12
```

Equivalent paths (no PATH needed):

```bash
"${XDG_CONFIG_HOME:-$HOME/.config}/continue-later/continue-later-fast.sh" -n 12
```

That script archives prior `continuation.md` / `continuation-fast.md`, writes **`continuation-fast.md`**, and appends recent user messages (newest local `*.jsonl` by mtime by default).

**Developing in a clone of this repo** you can run **`./scripts/continue-later-fast.sh`** instead (same behavior; helpers must stay beside the wrapper).

**Do not** hand-roll inline `git log` / `status` / `diff` into `continuation.md` when the installed script exists.

## Optional

| Flag / env | Purpose |
|------------|---------|
| `--agent <id>` / `CONTINUE_LATER_AGENT` | Pin a specific session JSONL |
| `--skip-transcript` / `CONTINUE_LATER_SKIP_TRANSCRIPT=1` | Git snapshot only |
| `--from-cwd` / `CONTINUE_LATER_FROM_CWD=1` | Prefer Claude transcript mentioning `$PWD`; else newest mtime |
| `-n` / `CONTINUE_LATER_LIMIT` | Max prompts (default 12) |
| `CONTINUE_LATER_CLI_DIR` / `CONTINUE_LATER_BIN_DIR` | Installer overrides for custom install locations |

**Claude Code:** If `=== CONTINUATION CONTEXT DUMP … ===` is already injected by the hook, you may still run **`continue-later-fast`** once to persist **`continuation-fast.md`** on disk.

See repo **README.md** for install and fork options.

## When to use

`/continue-later-fast`, `quick save`, `just dump the context`—or as a fast step before **continue-later** for a structured `continuation.md`.
