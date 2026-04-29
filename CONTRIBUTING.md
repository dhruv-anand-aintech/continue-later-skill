# Contributing

Thanks for improving Continue Later Skills.

## Workflow

1. Fork the repository.
2. Edit the relevant skills, scripts, hooks, docs, or tests.
3. Run the verification commands below.
4. Submit a pull request with a short description of the behavior change.

## Verification

Run:

```bash
bash -n install.sh scripts/*.sh claude-code/hooks/*.sh cursor/hooks/*.sh
python3 -m unittest discover -s tests
python3 -m json.tool manifest.json >/dev/null
```

If `shellcheck` is installed, also run:

```bash
shellcheck install.sh scripts/*.sh claude-code/hooks/*.sh cursor/hooks/*.sh
```

No npm package or build step is required.

## Installer Contract

Keep `install.sh` working for the default GitHub tarball layout:

- `skills/<name>/SKILL.md`
- `scripts/continue-later-fast.sh`
- `scripts/git-context-dump.sh`
- `scripts/session_recent_user_messages.py`
- `scripts/continue-later-prompt-hook.sh`
- `cursor/hooks/continue-later-before-submit.sh`

The installer copies the CLI bundle to:

```text
${CONTINUE_LATER_CLI_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/continue-later}
```

It symlinks:

```text
${CONTINUE_LATER_BIN_DIR:-$HOME/.local/bin}/continue-later-fast
```

Destination discovery should stay aligned with the assistant homes documented in
`install.sh`:

- Cursor
- Claude Code
- Codex
- shared `~/.agents`
- Gemini Antigravity
- OpenCode

## Hook Contract

- Cursor hook changes live under `cursor/hooks/`; update `README.md` if install behavior changes.
- Claude Code hook changes live under `claude-code/`; update
  `claude-code/README.md` if install steps change.
- Codex and Gemini prompt hook behavior lives in
  `scripts/continue-later-prompt-hook.sh`; update `README.md` and
  `QUICK_START.md` if registration changes.
- Hook opt-outs must continue to work:
  `CONTINUE_LATER_CURSOR_HOOK=0`, `CONTINUE_LATER_CODEX_HOOK=0`, and
  `CONTINUE_LATER_GEMINI_HOOK=0`.

## Shared Git Dump Contract

Git snapshot text must stay in `scripts/git-context-dump.sh` only.

These callers use it:

- `scripts/continue-later-fast.sh`
- `scripts/continue-later-prompt-hook.sh`
- `claude-code/hooks/continue-later-dump.sh`
- `cursor/hooks/continue-later-before-submit.sh` through `continue-later-fast.sh`

Do not duplicate `git log`, `git status`, or `git diff` formatting elsewhere.
