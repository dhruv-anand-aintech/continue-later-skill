#!/usr/bin/env bash
# Install continuation skills into Cursor's skills directory (~/.cursor/skills by default).
# Usage: curl -fsSL …/install.sh | bash
set -euo pipefail

OWNER_REPO="${CONTINUE_LATER_SKILLS_REPO:-dhruv-anand-aintech/continue-later-skill}"
BRANCH="${CONTINUE_LATER_SKILLS_BRANCH:-main}"
DEST="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}"

TMP="$(mktemp -d)"
cleanup() { rm -rf "${TMP}"; }
trap cleanup EXIT

URL="https://codeload.github.com/${OWNER_REPO}/tar.gz/refs/heads/${BRANCH}"
echo "Downloading ${OWNER_REPO} (${BRANCH})…"
curl -fsSL "${URL}" | tar xz -C "${TMP}"

TOP="$(find "${TMP}" -maxdepth 1 -mindepth 1 -type d | head -1)"
SKILLS_SRC="${TOP}/skills"

if [[ ! -d "${SKILLS_SRC}/continue-later" ]]; then
  echo "error: expected skills bundle not found in archive (missing ${SKILLS_SRC}/continue-later)." >&2
  exit 1
fi

mkdir -p "${DEST}"
for name in continue-later continue-later-fast resume-continuation; do
  if [[ ! -f "${SKILLS_SRC}/${name}/SKILL.md" ]]; then
    echo "error: missing ${SKILLS_SRC}/${name}/SKILL.md" >&2
    exit 1
  fi
  mkdir -p "${DEST}/${name}"
  cp "${SKILLS_SRC}/${name}/SKILL.md" "${DEST}/${name}/SKILL.md"
done

echo ""
echo "Installed into:"
echo "  ${DEST}/continue-later/SKILL.md"
echo "  ${DEST}/continue-later-fast/SKILL.md"
echo "  ${DEST}/resume-continuation/SKILL.md"
echo ""
echo "Restart Cursor (or reload the window) so skills are picked up."
