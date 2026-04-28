---
name: continue-later-fast
description: Use for a quick no-LLM dump to continuation-fast.md—raw git state plus optional last user messages from Claude Code / Cursor JSONL transcripts when you pass --agent SESSION_ID. Runs scripts/continue-later-fast.sh (or hook-injected dump), archives any existing continuation-fast.md.
---

# Continue Later Fast

## Overview

Archive any existing **`continuation-fast.md`**, dump **raw git context** to **`continuation-fast.md`**, and optionally append the **last few human-authored user prompts** from the local transcript (same JSONL layout under `~/.claude/projects/` as described in community tooling such as **claude-session-viewer**, plus Cursor `~/.cursor/projects/**/agent-transcripts/**/*.jsonl`). Does **not** overwrite **`continuation.md`** (structured handoff from **continue-later**). No LLM synthesis in the file itself.

## When to Use

- User says "/continue-later-fast" or "quick save" or "just dump the context"
- You want raw context, optionally with **recent conversation text** from disk
- As a sub-step before running the full **continue-later** skill

## Pass the transcript / agent id

| Product | What to pass as `--agent` | Where it lives |
|--------|---------------------------|----------------|
| **Claude Code** | Session UUID (same as the `.jsonl` basename) | `~/.claude/projects/<encoded-project>/<SESSION>.jsonl` |
| **Claude Code subagent** | Subagent file stem (e.g. `agent-a865d3008b337f458`) | `.../<session>/subagents/<stem>.jsonl` |
| **Cursor agent** | Agent transcript UUID (folder name under `agent-transcripts`) | `~/.cursor/projects/.../agent-transcripts/<UUID>/<UUID>.jsonl` |

Discovery scans **`**/<ID>.jsonl`** under `~/.claude/projects` and `~/.cursor/projects` and picks the **newest by mtime** if duplicates exist.

When calling from **this chat**, pass the **current agent/session transcript id** as `--agent` (or `CONTINUE_LATER_AGENT`). That ties the dump to the conversation from which the skill runs.

## Steps

### 1 — Archive existing continuation-fast.md

```bash
[ -f continuation-fast.md ] && mv continuation-fast.md continuation-fast.archive.$(date +%Y%m%d_%H%M%S).md
```

### 2 — Prefer programmatic paths (hook or CLI)

**A — Claude Code hook already injected context**

Look for `=== CONTINUATION CONTEXT DUMP` (see `claude-code/hooks/continue-later-dump.sh`). If present, you still may append transcript excerpts via the script below.

**B — Run the repo script (recommended)**

From the **git repo root** (or `cd` there first):

```bash
scripts/continue-later-fast.sh --agent "<TRANSCRIPT_OR_SESSION_ID>" -n 12
```

Or one-shot download (downloads **only** the shell script—you still need `session_recent_user_messages.py` beside it for transcript support, so prefer a clone or copy **both** files from `scripts/`):

```bash
# Minimal git-only dump (no transcript helper):
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/scripts/continue-later-fast.sh | bash

# Full clone (transcript extraction):
git clone https://github.com/dhruv-anand-aintech/continue-later-skill.git && \
  cd continue-later-skill && ./scripts/continue-later-fast.sh --agent "<ID>"
```

Environment equivalent:

```bash
export CONTINUE_LATER_AGENT="<TRANSCRIPT_OR_SESSION_ID>"
./scripts/continue-later-fast.sh
```

**C — Explicit JSONL path**

```bash
./scripts/continue-later-fast.sh --jsonl ~/.claude/projects/-Users-you-Code-foo/bar.jsonl
```

**D — Heuristic: newest Claude session mentioning cwd**

```bash
./scripts/continue-later-fast.sh --from-cwd
# or: CONTINUE_LATER_FROM_CWD=1 ./scripts/continue-later-fast.sh
```

Transcript parsing is implemented in [`scripts/session_recent_user_messages.py`](https://github.com/dhruv-anand-aintech/continue-later-skill/blob/main/scripts/session_recent_user_messages.py) (JSONL only; no separate DB).

### 3 — If you cannot run the full wrapper (fallback: git snapshot only)

Git snapshot text lives in **one place**: [`scripts/git-context-dump.sh`](https://github.com/dhruv-anand-aintech/continue-later-skill/blob/main/scripts/git-context-dump.sh). **`continue-later-fast.sh`** and the Claude **`continue-later-dump`** hook both call it—do not duplicate `git log` / `git status` / `diff` blocks elsewhere.

```bash
scripts/git-context-dump.sh markdown-full > continuation-fast.md
echo "Written: continuation-fast.md"
```

### 4 — Done

The output **`continuation-fast.md`** holds **git ground truth** and, when you used `--agent` / `--jsonl` / `--from-cwd`, a **Recent user messages** section. For a structured **`continuation.md`**, run **continue-later** (resume reads either file—see **resume-continuation**).
