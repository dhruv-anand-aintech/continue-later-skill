# Continue Later Skills

Cursor skills for **structured handoffs** (`continuation.md`), **quick raw dumps** (`continuation-fast.md`), and **resuming** from whichever handoff file exists—without a marketplace or npm.

## Install (one command)

Copies three skill folders into `~/.cursor/skills/` (override with `CURSOR_SKILLS_DIR`):

```bash
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/install.sh | bash
```

Requirements: `curl`, `tar`, and network access. No Git binary required.

### Claude Code / custom skills directory

Install into another tree (for example `~/.claude/skills`):

```bash
CURSOR_SKILLS_DIR="$HOME/.claude/skills" curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/install.sh | bash
```

### Forks or alternate branches

Point the installer at your fork’s tarball (and use the same repo for `install.sh`):

```bash
curl -fsSL "https://raw.githubusercontent.com/<fork-owner>/continue-later-skill/main/install.sh" | \
  CONTINUE_LATER_SKILLS_REPO="<fork-owner>/continue-later-skill" CONTINUE_LATER_SKILLS_BRANCH=main bash
```

Restart Cursor (or reload the window) after installing.

### Continue later fast (CLI script)

Requires `bash`, `git`, `python3`, [`scripts/git-context-dump.sh`](scripts/git-context-dump.sh) (shared git snapshot—used by **`continue-later-fast.sh`** and the Claude hook), and—**for transcript excerpts**—[`scripts/session_recent_user_messages.py`](scripts/session_recent_user_messages.py). Clone the repo or download the needed files into the same directory.

**Git-only** — fetch **`git-context-dump.sh`** and **`continue-later-fast.sh`** into the **same directory**, then run (single-file curl alone will fail—the wrapper calls `git-context-dump.sh`):

```bash
mkdir -p ~/.local/share/continue-later-skill/scripts && cd $_
curl -fsSO https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/scripts/git-context-dump.sh
curl -fsSO https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/scripts/continue-later-fast.sh
chmod +x git-context-dump.sh continue-later-fast.sh
./continue-later-fast.sh
```

**Git + last user prompts from Claude Code / Cursor JSONL** — writes **`continuation-fast.md`** (session id = transcript filename stem under `~/.claude/projects` or `~/.cursor/projects`, see skill doc):

```bash
./scripts/continue-later-fast.sh --agent "<SESSION_OR_AGENT_UUID>" -n 12
```

Optional: `--jsonl /path/to/session.jsonl`, `--from-cwd` (newest Claude session file mentioning the current directory), env `CONTINUE_LATER_AGENT`, `CONTINUE_LATER_FROM_CWD=1`, or **`CONTINUE_LATER_FAST_FILE`** to override the output path.

Discovery follows the same `~/.claude/projects/**/*.jsonl` layout tools such as **claude-session-viewer** use; transcripts are JSONL only (no SQLite).

### Claude Code: hook (programmatic dump before the LLM)

If you use **Claude Code**, you can install a **`UserPromptSubmit`** hook that archives **`continuation.md`** / **`continuation-fast.md`** when present, runs the git dump, and injects **`=== CONTINUATION CONTEXT DUMP`** into context so the agent does not need to shell out first. See **[claude-code/README.md](claude-code/README.md)** and **[claude-code/hooks/continue-later-dump.sh](claude-code/hooks/continue-later-dump.sh)**.

## What gets installed

| Skill folder | Role |
|----------------|------|
| `continue-later` | Full structured `continuation.md` (overview, stack, state, tasks, gotchas, deploy). |
| `continue-later-fast` | Archive existing file, dump raw git context into **`continuation-fast.md`**—no narrative summary. |
| `resume-continuation` | Read **`continuation.md`** and/or **`continuation-fast.md`** (prefer structured file when both exist). |

Source files in this repo: [skills/continue-later/](skills/continue-later/), [skills/continue-later-fast/](skills/continue-later-fast/), [skills/resume-continuation/](skills/resume-continuation/).

## Usage

Ask the agent in natural language, for example:

- **Handoff:** “Hand this off”, “continue later”, “save project state”, “document where we left off”
- **Quick dump:** “quick save”, “continue-later-fast”, “just dump the context”
- **Resume:** “resume from earlier”, “what was I working on?”, “show pending tasks”

## Continuation structure (full skill)

The **continue-later** skill defines markdown sections such as project overview, tech stack, build/run commands, current state, pending tasks, decisions, gotchas, and deploy steps.

## Example file

See [examples/continuation-example.md](examples/continuation-example.md).

## Use cases

- Team handoffs and async collaboration
- Long-running projects with gaps between sessions
- Onboarding with preserved context
- Capturing decisions and traps before context switches

## License

MIT
