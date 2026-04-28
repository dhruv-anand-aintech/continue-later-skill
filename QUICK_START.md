# Quick start

## Install

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/install.sh | bash
```

Then restart Cursor (or reload the window).

## Use

| You say | Skill |
|---------|--------|
| Hand this off / continue later / save state | **continue-later** → writes structured `continuation.md` |
| Quick save / dump raw git only | **continue-later-fast** |
| Resume from earlier / what was I working on | **resume-continuation** reads `continuation.md` |

No npm, no marketplace. Optional: `CURSOR_SKILLS_DIR` to choose the install folder (default `~/.cursor/skills`).
