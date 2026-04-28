# Contributing

1. Fork the repository.
2. Edit the skills under `skills/{continue-later,continue-later-fast,resume-continuation}/SKILL.md`, or docs like `README.md` and `install.sh`.
3. Submit a pull request.

No build step and no npm. Keep `install.sh` working for the default branch tarball layout (`skills/<name>/SKILL.md`). Hook changes live under `claude-code/`; update `claude-code/README.md` if install steps change. The fast CLI lives at `scripts/continue-later-fast.sh` — keep it aligned with `skills/continue-later-fast/SKILL.md`.
