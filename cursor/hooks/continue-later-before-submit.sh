#!/usr/bin/env bash
# Cursor beforeSubmitPrompt hook: on continuation-style prompts, runs continue-later-fast
# in the workspace git repo so continuation-fast.md is written without invoking the skill.
# Cursor does not inject extra prompt text (unlike Claude Code); this only updates disk.
#
# Install: copied to ~/.cursor/hooks/ by install.sh; registered in ~/.cursor/hooks.json.
# Disable install: CONTINUE_LATER_CURSOR_HOOK=0 bash install.sh
set -euo pipefail

_resolve_cli_bundle() {
  local xdg="${XDG_CONFIG_HOME:-${HOME}/.config}"
  local d="${CONTINUE_LATER_CLI_DIR:-${xdg}/continue-later}"
  local w="${d}/continue-later-fast.sh"
  if [[ -f "$w" ]]; then
    printf '%s' "$w"
    return 0
  fi
  echo ""
}

INPUT=$(cat || true)
[[ -z "$INPUT" ]] && INPUT="{}"

PROMPT_LC=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin)
    print((d.get("prompt") or "").lower())
except Exception:
    print("")' 2>/dev/null || echo "")

if ! printf '%s' "$PROMPT_LC" | grep -qE 'continue\.later|continue later|save\.state|save state|hand.?off|hand this off|i.?m done|done for today|create.?continuation|compact'; then
  echo '{"continue": true}'
  exit 0
fi

GIT_ROOT=$(printf '%s' "$INPUT" | python3 -c 'import json, os, subprocess, sys

def git_toplevel(path):
    if not path or not os.path.isdir(path):
        return None
    try:
        r = subprocess.run(
            ["git", "-C", path, "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            timeout=60,
        )
        if r.returncode == 0:
            return (r.stdout or "").strip() or None
    except (OSError, subprocess.TimeoutExpired):
        pass
    return None

raw = sys.stdin.read()
try:
    d = json.loads(raw)
except json.JSONDecodeError:
    d = {}

for w in d.get("workspace_roots") or []:
    top = git_toplevel(w)
    if top:
        print(top)
        sys.exit(0)

for a in d.get("attachments") or []:
    p = a.get("file_path")
    if p:
        parent = os.path.dirname(p)
        top = git_toplevel(parent)
        if top:
            print(top)
            sys.exit(0)

for env in ("PWD", "CLAUDE_PROJECT_DIR"):
    v = os.environ.get(env)
    if v:
        top = git_toplevel(v)
        if top:
            print(top)
            sys.exit(0)
')

WRAP="$(_resolve_cli_bundle)"
if [[ -z "$GIT_ROOT" ]]; then
  echo "continue-later-before-submit: no git root (workspace_roots / attachments / PWD)" >&2
  echo '{"continue": true}'
  exit 0
fi

if [[ -z "$WRAP" || ! -f "$WRAP" ]]; then
  echo "continue-later-before-submit: missing continue-later-fast.sh (run install.sh)" >&2
  echo '{"continue": true}'
  exit 0
fi

LIMIT="${CONTINUE_LATER_FAST_HOOK_LIMIT:-${CONTINUE_LATER_LIMIT:-12}}"
(cd "$GIT_ROOT" && bash "$WRAP" -n "$LIMIT") || echo "continue-later-before-submit: continue-later-fast failed (non-fatal)" >&2

echo '{"continue": true}'
