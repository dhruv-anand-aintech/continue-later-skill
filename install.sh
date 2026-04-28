#!/usr/bin/env bash
# Install continuation skills into agent skill directories (latest tarball from GitHub).
#
# Destination rules (aligned with ~/.config/agent-rules-sync agent_skills_sync.py):
#   • AGENT_SKILLS_DIRS — optional colon-separated list (if set, only these paths).
#   • Else CURSOR_SKILLS_DIR — legacy single path (backward compatible).
#   • Else discover: copy into each framework tree whose home directory already exists:
#       ~/.cursor/skills + ~/.cursor/skills-cursor  when ~/.cursor exists
#       ~/.claude/skills                             when ~/.claude exists
#       $CODEX_HOME/skills or ~/.codex/skills       when that codex home exists
#       ~/.agents/skills                             when ~/.agents exists
#       ~/.gemini/antigravity/skills                 when ~/.gemini/antigravity exists
#       ~/.config/opencode/skills                    when ~/.config/opencode exists
#   • If none of the above homes exist, ~/.cursor/skills is created and used.
#
# Usage: curl -fsSL …/install.sh | bash
set -euo pipefail

OWNER_REPO="${CONTINUE_LATER_SKILLS_REPO:-dhruv-anand-aintech/continue-later-skill}"
BRANCH="${CONTINUE_LATER_SKILLS_BRANCH:-main}"

_resolve_codex_home() {
  local c="${CODEX_HOME:-}"
  if [[ -z "$c" ]]; then
    printf '%s' "${HOME}/.codex"
    return
  fi
  case "$c" in
    ~/*) c="${HOME}/${c:2}" ;;
    ~)   c="${HOME}" ;;
  esac
  printf '%s' "$c"
}

_dedupe_array() {
  local -a src=("$@")
  local -a out=()
  local p q skip
  for p in "${src[@]}"; do
    skip=0
    for q in "${out[@]:-}"; do
      [[ "$p" == "$q" ]] && { skip=1; break; }
    done
    [[ "$skip" -eq 0 ]] && out+=("$p")
  done
  DESTINATIONS=("${out[@]}")
}

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

DESTINATIONS=()
if [[ -n "${AGENT_SKILLS_DIRS:-}" ]]; then
  IFS=':' read -ra _agent_raw <<< "${AGENT_SKILLS_DIRS}"
  for x in "${_agent_raw[@]}"; do
    [[ -n "$x" ]] && DESTINATIONS+=("$x")
  done
elif [[ -n "${CURSOR_SKILLS_DIR:-}" ]]; then
  DESTINATIONS=("${CURSOR_SKILLS_DIR}")
else
  h="$HOME"
  codex_home="$(_resolve_codex_home)"
  [[ -d "${h}/.cursor" ]]             && DESTINATIONS+=("${h}/.cursor/skills" "${h}/.cursor/skills-cursor")
  [[ -d "${h}/.claude" ]]             && DESTINATIONS+=("${h}/.claude/skills")
  [[ -d "${codex_home}" ]]           && DESTINATIONS+=("${codex_home}/skills")
  [[ -d "${h}/.agents" ]]            && DESTINATIONS+=("${h}/.agents/skills")
  [[ -d "${h}/.gemini/antigravity" ]] && DESTINATIONS+=("${h}/.gemini/antigravity/skills")
  [[ -d "${h}/.config/opencode" ]]    && DESTINATIONS+=("${h}/.config/opencode/skills")
  if [[ ${#DESTINATIONS[@]} -eq 0 ]]; then
    mkdir -p "${h}/.cursor/skills"
    DESTINATIONS+=("${h}/.cursor/skills")
  fi
fi

_dedupe_array "${DESTINATIONS[@]}"

if [[ ${#DESTINATIONS[@]} -eq 0 ]]; then
  echo "error: no install destinations resolved." >&2
  exit 1
fi

for i in "${!DESTINATIONS[@]}"; do
  p="${DESTINATIONS[$i]}"
  case "$p" in
    ~/*) DESTINATIONS[$i]="${HOME}/${p:2}" ;;
    ~)   DESTINATIONS[$i]="${HOME}" ;;
  esac
done

for DEST in "${DESTINATIONS[@]}"; do
  mkdir -p "${DEST}"
  for name in continue-later continue-later-fast resume-continuation; do
    if [[ ! -f "${SKILLS_SRC}/${name}/SKILL.md" ]]; then
      echo "error: missing ${SKILLS_SRC}/${name}/SKILL.md" >&2
      exit 1
    fi
    mkdir -p "${DEST}/${name}"
    cp "${SKILLS_SRC}/${name}/SKILL.md" "${DEST}/${name}/SKILL.md"
  done
done

echo ""
echo "Installed (${#DESTINATIONS[@]} location(s)):"
for DEST in "${DESTINATIONS[@]}"; do
  echo "  ${DEST}/{continue-later,continue-later-fast,resume-continuation}/SKILL.md"
done
echo ""
echo "Restart each assistant (Cursor, Claude Code, Antigravity, OpenCode, Codex, …) or reload so skills apply."
