# Quick start

## Install

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/install.sh | bash
```

Then restart Cursor (or reload the window).

### CLI only (continue-later-fast)

Needs **`git-context-dump.sh`** beside **`continue-later-fast.sh`** (shared git snapshot). From your project directory:

```bash
./continue-later-fast.sh
```

See [README.md](README.md) for downloading both scripts with `curl`. For **recent user messages**, add **`session_recent_user_messages.py`** and run `./scripts/continue-later-fast.sh --agent "<session-id>"`.

Env: `CONTINUE_LATER_AGENT`, `CONTINUE_LATER_LIMIT`, `CONTINUE_LATER_FROM_CWD=1` with `--from-cwd`.

## Use

| You say | Skill |
|---------|--------|
| Hand this off / continue later / save state | **continue-later** → writes structured `continuation.md` |
| Quick save / dump raw git only | **continue-later-fast** |
| Resume from earlier / what was I working on | **resume-continuation** reads `continuation.md` and/or `continuation-fast.md` |

No npm, no marketplace. Optional: `CURSOR_SKILLS_DIR` to choose the install folder (default `~/.cursor/skills`).
