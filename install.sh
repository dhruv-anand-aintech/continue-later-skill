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
#
# Always installs the fast CLI bundle into CONTINUE_LATER_CLI_DIR (default:
# ~/.config/continue-later/) and symlinks CONTINUE_LATER_BIN_DIR/continue-later-fast → …/continue-later-fast.sh
# so the command works from any directory inside a git repo.
#
# When CONTINUE_LATER_CURSOR_HOOK is unset or non-zero: installs a Cursor beforeSubmitPrompt hook
# (~/.cursor/hooks/continue-later-before-submit.sh + merge into ~/.cursor/hooks.json) so
# continuation-style prompts trigger continue-later-fast on disk. Set CONTINUE_LATER_CURSOR_HOOK=0 to skip.
# When CONTINUE_LATER_CODEX_HOOK / CONTINUE_LATER_GEMINI_HOOK are unset or non-zero:
# registers Codex UserPromptSubmit / Gemini BeforeAgent hooks if those tool homes exist.
set -euo pipefail

OWNER_REPO="${CONTINUE_LATER_SKILLS_REPO:-dhruv-anand-aintech/continue-later-skill}"
BRANCH="${CONTINUE_LATER_SKILLS_BRANCH:-main}"

_resolve_codex_home() {
  local c="${CODEX_HOME:-}"
  if [[ -z "$c" ]]; then
    printf '%s' "${HOME}/.codex"
    return
  fi
  # Do not use `case ... ~/*)` — bash expands ~ inside case patterns and breaks paths like /Users/...
  if [[ "${c:0:1}" == "~" && "${c:1:1}" == "/" ]]; then
    c="${HOME}/${c:2}"
  elif [[ "$c" == '~' ]]; then
    c="${HOME}"
  fi
  printf '%s' "$c"
}

codex_home="$(_resolve_codex_home)"

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

SCRIPTS_SRC="${TOP}/scripts"
for _need in continue-later-fast.sh git-context-dump.sh session_recent_user_messages.py continue-later-prompt-hook.sh; do
  if [[ ! -f "${SCRIPTS_SRC}/${_need}" ]]; then
    echo "error: missing ${SCRIPTS_SRC}/${_need}" >&2
    exit 1
  fi
done

CURSOR_HOOK_SRC="${TOP}/cursor/hooks/continue-later-before-submit.sh"
if [[ ! -f "${CURSOR_HOOK_SRC}" ]]; then
  echo "error: missing ${CURSOR_HOOK_SRC}" >&2
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
  if [[ "${p:0:1}" == "~" && "${p:1:1}" == "/" ]]; then
    DESTINATIONS[i]="${HOME}/${p:2}"
  elif [[ "$p" == '~' ]]; then
    DESTINATIONS[i]="${HOME}"
  fi
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

_XDG_CFG="${XDG_CONFIG_HOME:-${HOME}/.config}"
CLI_DIR="${CONTINUE_LATER_CLI_DIR:-${_XDG_CFG}/continue-later}"
mkdir -p "${CLI_DIR}"
cp "${SCRIPTS_SRC}/continue-later-fast.sh" "${SCRIPTS_SRC}/git-context-dump.sh" "${SCRIPTS_SRC}/session_recent_user_messages.py" "${SCRIPTS_SRC}/continue-later-prompt-hook.sh" "${CLI_DIR}/"
chmod +x "${CLI_DIR}/continue-later-fast.sh" "${CLI_DIR}/git-context-dump.sh" "${CLI_DIR}/continue-later-prompt-hook.sh"

BIN_DIR="${CONTINUE_LATER_BIN_DIR:-${HOME}/.local/bin}"
mkdir -p "${BIN_DIR}"
ln -sf "${CLI_DIR}/continue-later-fast.sh" "${BIN_DIR}/continue-later-fast"

if [[ "${CONTINUE_LATER_CURSOR_HOOK:-1}" != "0" ]]; then
  mkdir -p "${HOME}/.cursor/hooks"
  cp "${CURSOR_HOOK_SRC}" "${HOME}/.cursor/hooks/continue-later-before-submit.sh"
  chmod +x "${HOME}/.cursor/hooks/continue-later-before-submit.sh"
  python3 - "${HOME}/.cursor/hooks.json" <<'PY'
import json
import sys
from pathlib import Path

hooks_path = Path(sys.argv[1])
cmd = "./hooks/continue-later-before-submit.sh"

if hooks_path.exists():
    try:
        data = json.loads(hooks_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"error: invalid JSON in {hooks_path}: {e}", file=sys.stderr)
        sys.exit(1)
else:
    data = {"version": 1, "hooks": {}}

if not isinstance(data.get("hooks"), dict):
    data["hooks"] = {}
hooks = data["hooks"]
subs = hooks.get("beforeSubmitPrompt")
if subs is None:
    hooks["beforeSubmitPrompt"] = []
    subs = hooks["beforeSubmitPrompt"]
elif not isinstance(subs, list):
    print(f"error: {hooks_path} hooks.beforeSubmitPrompt must be a list", file=sys.stderr)
    sys.exit(1)

if any(cmd in str(entry.get("command", "")) for entry in subs):
    print(f"Cursor beforeSubmitPrompt hook already present in {hooks_path}")
else:
    subs.append({"command": cmd})
    data.setdefault("version", 1)
    hooks_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"Registered Cursor beforeSubmitPrompt hook in {hooks_path}")
PY
fi

if [[ "${CONTINUE_LATER_CODEX_HOOK:-1}" != "0" && -d "${codex_home}" ]]; then
  mkdir -p "${codex_home}"
  python3 - "${codex_home}/hooks.json" "${CLI_DIR}/continue-later-prompt-hook.sh" <<'PY'
import json
import sys
from pathlib import Path

hooks_path = Path(sys.argv[1])
script = sys.argv[2]
cmd = f"bash {json.dumps(script)}"

if hooks_path.exists():
    try:
        data = json.loads(hooks_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"error: invalid JSON in {hooks_path}: {e}", file=sys.stderr)
        sys.exit(1)
else:
    data = {"hooks": {}}

if not isinstance(data.get("hooks"), dict):
    data["hooks"] = {}
groups = data["hooks"].setdefault("UserPromptSubmit", [])
if not isinstance(groups, list):
    print(f"error: {hooks_path} hooks.UserPromptSubmit must be a list", file=sys.stderr)
    sys.exit(1)

already = any(
    "continue-later-prompt-hook.sh" in str(h.get("command", ""))
    for group in groups
    if isinstance(group, dict)
    for h in (group.get("hooks") or [])
    if isinstance(h, dict)
)
if already:
    print(f"Codex UserPromptSubmit hook already present in {hooks_path}")
else:
    groups.append(
        {
            "hooks": [
                {
                    "type": "command",
                    "command": cmd,
                    "timeout": 30,
                    "statusMessage": "Loading continue-later context",
                }
            ]
        }
    )
    hooks_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"Registered Codex UserPromptSubmit hook in {hooks_path}")
PY

  python3 - "${codex_home}/config.toml" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8") if path.exists() else ""
lines = text.splitlines()

features_start = None
features_end = len(lines)
for i, line in enumerate(lines):
    if re.match(r"\s*\[features\]\s*(?:#.*)?$", line):
        features_start = i
        for j in range(i + 1, len(lines)):
            if re.match(r"\s*\[", lines[j]):
                features_end = j
                break
        break

if features_start is None:
    if lines and lines[-1].strip():
        lines.append("")
    lines.extend(["[features]", "codex_hooks = true"])
else:
    key_re = re.compile(r"\s*codex_hooks\s*=")
    for i in range(features_start + 1, features_end):
        if key_re.match(lines[i]):
            lines[i] = "codex_hooks = true"
            break
    else:
        lines.insert(features_end, "codex_hooks = true")

new = "\n".join(lines) + "\n"
if new != text:
    path.write_text(new, encoding="utf-8")
    print(f"Enabled Codex hooks feature in {path}")
PY
fi

if [[ "${CONTINUE_LATER_GEMINI_HOOK:-1}" != "0" && -d "${HOME}/.gemini" ]]; then
  python3 - "${HOME}/.gemini/settings.json" "${CLI_DIR}/continue-later-prompt-hook.sh" <<'PY'
import json
import sys
from pathlib import Path

settings_path = Path(sys.argv[1])
script = sys.argv[2]
cmd = f"bash {json.dumps(script)}"

if settings_path.exists():
    try:
        data = json.loads(settings_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"error: invalid JSON in {settings_path}: {e}", file=sys.stderr)
        sys.exit(1)
else:
    data = {}

if not isinstance(data.get("hooks"), dict):
    data["hooks"] = {}
groups = data["hooks"].setdefault("BeforeAgent", [])
if not isinstance(groups, list):
    print(f"error: {settings_path} hooks.BeforeAgent must be a list", file=sys.stderr)
    sys.exit(1)

already = any(
    "continue-later-prompt-hook.sh" in str(h.get("command", ""))
    for group in groups
    if isinstance(group, dict)
    for h in (group.get("hooks") or [])
    if isinstance(h, dict)
)
if already:
    print(f"Gemini BeforeAgent hook already present in {settings_path}")
else:
    groups.append(
        {
            "hooks": [
                {
                    "name": "continue-later",
                    "type": "command",
                    "command": cmd,
                    "timeout": 30000,
                    "description": "Inject continue-later git context on handoff prompts",
                }
            ]
        }
    )
    settings_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"Registered Gemini BeforeAgent hook in {settings_path}")
PY
fi

echo ""
echo "Installed (${#DESTINATIONS[@]} skill location(s)):"
for DEST in "${DESTINATIONS[@]}"; do
  echo "  ${DEST}/{continue-later,continue-later-fast,resume-continuation}/SKILL.md"
done
echo ""
echo "Fast CLI (run from any git repo root; add ${BIN_DIR} to PATH if needed):"
echo "  ${CLI_DIR}/{continue-later-fast.sh,git-context-dump.sh,session_recent_user_messages.py,continue-later-prompt-hook.sh}"
echo "  ${BIN_DIR}/continue-later-fast → continue-later-fast.sh"
echo ""
if [[ "${CONTINUE_LATER_CURSOR_HOOK:-1}" != "0" ]]; then
  echo "Cursor hook (beforeSubmitPrompt): ~/.cursor/hooks/continue-later-before-submit.sh"
  echo "  Continuation-style chat prompts run continue-later-fast in the workspace git root."
  echo "  Skip with: CONTINUE_LATER_CURSOR_HOOK=0"
  echo ""
fi
if [[ "${CONTINUE_LATER_CODEX_HOOK:-1}" != "0" && -d "${codex_home}" ]]; then
  echo "Codex hook (UserPromptSubmit): ${codex_home}/hooks.json"
  echo "  Continuation-style prompts inject the shared git context dump."
  echo "  Skip with: CONTINUE_LATER_CODEX_HOOK=0"
  echo ""
fi
if [[ "${CONTINUE_LATER_GEMINI_HOOK:-1}" != "0" && -d "${HOME}/.gemini" ]]; then
  echo "Gemini hook (BeforeAgent): ~/.gemini/settings.json"
  echo "  Continuation-style prompts inject the shared git context dump."
  echo "  Skip with: CONTINUE_LATER_GEMINI_HOOK=0"
  echo ""
fi
echo "Restart each assistant (Cursor, Claude Code, Antigravity, OpenCode, Codex, …) or reload so skills apply."
