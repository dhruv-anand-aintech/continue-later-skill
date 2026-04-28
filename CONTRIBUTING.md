# Contributing

1. Fork the repository.
2. Edit the skills under `skills/{continue-later,continue-later-fast,resume-continuation}/SKILL.md`, or docs like `README.md` and `install.sh`.
3. Submit a pull request.

No build step and no npm. Keep `install.sh` working for the default branch tarball layout (`skills/<name>/SKILL.md` plus **`scripts/*.sh` / `session_recent_user_messages.py`** copied to **`${CONTINUE_LATER_CLI_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/continue-later}`** and the **`continue-later-fast`** symlink under **`${CONTINUE_LATER_BIN_DIR:-$HOME/.local/bin}`**). Destination discovery should stay aligned with **agent-rules-sync-standalone** `AgentSkillsSync.frameworks` paths (`install.sh` comments). Hook changes live under `claude-code/`; update `claude-code/README.md` if install steps change. The fast CLI lives at `scripts/continue-later-fast.sh` with transcript parsing in `scripts/session_recent_user_messages.py`. **Git snapshot text must stay in `scripts/git-context-dump.sh` only** (`markdown-full` / `hook-block`) — `continue-later-fast.sh` and `claude-code/hooks/continue-later-dump.sh` call it; do not duplicate `git log` / `status` / `diff` elsewhere.
