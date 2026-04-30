# Changelog

All notable changes to Continue Later Skills are documented here.

## Unreleased

### Added

- **`resume-from-earlier`** skill folder: same workflow as **resume-continuation**, installed separately so **`/resume-from-earlier`** is discoverable on every platform (not only via a shared manifest).

## [1.0.0] - 2026-04-29

### Added

- Three agent skills: `continue-later`, `continue-later-fast`, and `resume-continuation`.
- One-command installer for Cursor, Claude Code, Codex, shared `~/.agents`, Gemini Antigravity, and OpenCode skill directories.
- Fast CLI bundle installed under `~/.config/continue-later/` by default.
- `continue-later-fast` symlink under `~/.local/bin/`.
- Shared git snapshot helper for markdown and hook output.
- Local transcript excerpt support for Claude/Cursor JSONL files.
- Cursor `beforeSubmitPrompt` hook registration.
- Codex `UserPromptSubmit` hook registration.
- Gemini `BeforeAgent` hook registration.
- Claude Code hook example and setup docs.
- Public verification workflow and issue templates.

### Notes

- The default installer tracks `main`.
- Use `CONTINUE_LATER_SKIP_TRANSCRIPT=1` or `--skip-transcript` for git-only fast dumps.
- Use hook opt-outs during install when needed: `CONTINUE_LATER_CURSOR_HOOK=0`, `CONTINUE_LATER_CODEX_HOOK=0`, `CONTINUE_LATER_GEMINI_HOOK=0`.
