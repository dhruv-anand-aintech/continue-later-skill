# Continue Later Skills

Cursor skills for **structured handoffs** (`continuation.md`), **quick raw dumps** (`continuation-fast.md`), and **resuming** from whichever handoff file exists—without a marketplace or npm.

## Install (one command)

Fetches the latest `main` tarball and copies **continue-later**, **continue-later-fast**, and **resume-continuation** into your agent skill folders. It also installs the **fast CLI** into `${XDG_CONFIG_HOME:-~/.config}/continue-later/` (`continue-later-fast.sh`, `git-context-dump.sh`, `session_recent_user_messages.py`) and symlinks **`continue-later-fast`** into **`~/.local/bin/`** so you can run the handoff from **any** project directory (add `~/.local/bin` to `PATH` if needed). **No skill-dir variable is required:** the script installs everywhere it can find an existing assistant home directory (same discovery idea as **agent-rules-sync-standalone** / `AgentSkillsSync.frameworks`: Cursor, Claude Code, Codex, shared `~/.agents`, Gemini Antigravity, OpenCode). If none of those homes exist yet, it creates **`~/.cursor/skills`**.

```bash
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/install.sh | bash
```

Requirements: `curl`, `tar`, `bash`, network access. No Git binary required.

### Override destinations (optional)

- **`AGENT_SKILLS_DIRS`** — colon-separated list of roots (only these paths):
  ```bash
  AGENT_SKILLS_DIRS="$HOME/.cursor/skills:$HOME/.claude/skills" \
    curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/install.sh | bash
  ```
- **`CURSOR_SKILLS_DIR`** — legacy single directory (still supported).

When unset, discovery checks which of **`~/.cursor`**, **`~/.claude`**, **`$CODEX_HOME`** / **`~/.codex`**, **`~/.agents`**, **`~/.gemini/antigravity`**, **`~/.config/opencode`** exist and installs under each corresponding **`…/skills`** tree.

- **`CONTINUE_LATER_CLI_DIR`** — where the three scripts are copied (default `${XDG_CONFIG_HOME:-$HOME/.config}/continue-later`).
- **`CONTINUE_LATER_BIN_DIR`** — where the **`continue-later-fast`** symlink is created (default **`~/.local/bin`**).

### Forks or alternate branches

Point the installer at your fork’s tarball (and use the same repo for `install.sh`):

```bash
curl -fsSL "https://raw.githubusercontent.com/<fork-owner>/continue-later-skill/main/install.sh" | \
  CONTINUE_LATER_SKILLS_REPO="<fork-owner>/continue-later-skill" CONTINUE_LATER_SKILLS_BRANCH=main bash
```

Restart Cursor, Claude Code, or other assistants after installing so skills reload.

### Continue later fast (CLI script)

Requires `bash`, `git`, [`scripts/git-context-dump.sh`](scripts/git-context-dump.sh) (shared git snapshot—used by **`continue-later-fast.sh`** and the Claude hook), and—**for transcript excerpts**—[`scripts/session_recent_user_messages.py`](scripts/session_recent_user_messages.py), plus **`python3`**.

**Recommended:** install via **`install.sh`** (above)—then from a project’s git root:

```bash
continue-later-fast -n 12
```

**Git + transcript excerpts:** writes **`continuation-fast.md`** in that repo’s root. **By default** (no `--agent`) the helper picks the **newest `*.jsonl` by filesystem mtime** under `~/.cursor/projects` and `~/.claude/projects`. Pin if needed:

```bash
continue-later-fast --agent "<SESSION_OR_AGENT_UUID>" -n 12
```

Optional: `--jsonl /path/to/session.jsonl`, `--from-cwd` (prefer Claude session mentioning cwd, else newest mtime), env `CONTINUE_LATER_AGENT`, `CONTINUE_LATER_FROM_CWD=1`, `CONTINUE_LATER_SKIP_TRANSCRIPT=1` (git only), or **`CONTINUE_LATER_FAST_FILE`** to override the output path.

**Without running `install.sh`:** download all three scripts into **one directory** (single-file curl is not enough—the wrapper calls `git-context-dump.sh`):

```bash
mkdir -p ~/.local/share/continue-later-skill/scripts && cd $_
curl -fsSO https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/scripts/git-context-dump.sh
curl -fsSO https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/scripts/continue-later-fast.sh
curl -fsSO https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/scripts/session_recent_user_messages.py
chmod +x git-context-dump.sh continue-later-fast.sh
./continue-later-fast.sh
```

**Developing** in a clone of this repo, **`./scripts/continue-later-fast.sh`** works the same way.

Discovery follows the same `~/.claude/projects/**/*.jsonl` layout tools such as **claude-session-viewer** use; transcripts are JSONL only (no SQLite).

### Claude Code: hook (programmatic dump before the LLM)

If you use **Claude Code**, you can install a **`UserPromptSubmit`** hook that archives **`continuation.md`** / **`continuation-fast.md`** when present, runs the git dump, and injects **`=== CONTINUATION CONTEXT DUMP`** into context so the agent does not need to shell out first. See **[claude-code/README.md](claude-code/README.md)** and **[claude-code/hooks/continue-later-dump.sh](claude-code/hooks/continue-later-dump.sh)**.

## What gets installed


| Skill folder          | Role                                                                                                    |
| --------------------- | ------------------------------------------------------------------------------------------------------- |
| `continue-later`      | Full structured `continuation.md` (overview, stack, state, tasks, gotchas, deploy).                     |
| `continue-later-fast` | Run the **`continue-later-fast`** CLI for **`continuation-fast.md`**—no narrative summary in that file. |
| `resume-continuation` | Read **`continuation.md`** and/or **`continuation-fast.md`** (prefer structured file when both exist).  |



| Path                                                                                               | Role                                                                                                                        |
| -------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `$CONTINUE_LATER_CLI_DIR` (default **`~/.config/continue-later/`**)                                | **`continue-later-fast.sh`**, **`git-context-dump.sh`**, **`session_recent_user_messages.py`**.                             |
| `$CONTINUE_LATER_BIN_DIR/continue-later-fast` (default **`~/.local/bin/continue-later-fast`**) | Symlink to **`continue-later-fast.sh`** — run from any repo after **`cd`** to git root (ensure **`BIN_DIR`** is on `PATH`). |


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