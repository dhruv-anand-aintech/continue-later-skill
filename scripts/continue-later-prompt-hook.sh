#!/usr/bin/env bash
# Cross-agent prompt hook for Codex UserPromptSubmit and Gemini BeforeAgent.
# On continuation-style prompts, archives existing handoff files and injects
# the shared git context dump as one-turn context.
set -eu

_resolve_script_dir() {
  local script="${BASH_SOURCE[0]}"
  local dir
  while [[ -L "$script" ]]; do
    dir="$(cd "$(dirname "$script")" && pwd)"
    script="$(readlink "$script")"
    [[ "$script" != /* ]] && script="$dir/$script"
  done
  cd "$(dirname "$script")" && pwd
}

SCRIPT_DIR="$(_resolve_script_dir)"
DUMP="${GIT_CONTEXT_DUMP_SCRIPT:-${SCRIPT_DIR}/git-context-dump.sh}"

INPUT="$(cat || true)"
[[ -z "$INPUT" ]] && INPUT="{}"

META="$(printf '%s' "$INPUT" | python3 -c 'import json, os, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
event = d.get("hook_event_name") or os.environ.get("CONTINUE_LATER_HOOK_EVENT") or ""
prompt = d.get("prompt") or d.get("message") or ""
cwd = d.get("cwd") or os.environ.get("GEMINI_CWD") or os.environ.get("CLAUDE_PROJECT_DIR") or os.environ.get("PWD") or ""
print(json.dumps({"event": event, "prompt": prompt, "cwd": cwd}))
' 2>/dev/null || printf '{"event":"","prompt":"","cwd":""}')"

EVENT="$(printf '%s' "$META" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("event",""))')"
PROMPT_LC="$(printf '%s' "$META" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("prompt","").lower())')"
CWD_IN="$(printf '%s' "$META" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))')"

if ! printf '%s' "$PROMPT_LC" | grep -qE 'continue\.later|continue later|save\.state|save state|hand.?off|hand this off|i.?m done|done for today|create.?continuation|quick save|compact'; then
  echo '{"continue":true}'
  exit 0
fi

if [[ ! -f "$DUMP" ]]; then
  echo "continue-later-prompt-hook: missing git-context-dump.sh beside hook" >&2
  echo '{"continue":true}'
  exit 0
fi

if [[ -n "$CWD_IN" && -d "$CWD_IN" ]]; then
  cd "$CWD_IN"
fi
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

ARCHIVED_MSG=""
TS="$(date +%Y%m%d_%H%M%S)"
if [[ -f continuation.md ]]; then
  mv continuation.md "continuation.archive.${TS}.md"
  ARCHIVED_MSG="Archived previous continuation.md -> continuation.archive.${TS}.md"
fi
if [[ -f continuation-fast.md ]]; then
  mv continuation-fast.md "continuation-fast.archive.${TS}.md"
  ARCHIVED_MSG="${ARCHIVED_MSG:+${ARCHIVED_MSG}; }Archived previous continuation-fast.md -> continuation-fast.archive.${TS}.md"
fi

DUMP_TEXT="$(bash "$DUMP" hook-block)"
export CONTINUE_LATER_DUMP_TEXT="$DUMP_TEXT"
export CONTINUE_LATER_HOOK_EVENT="$EVENT"

python3 <<'PY'
import json
import os

event = os.environ.get("CONTINUE_LATER_HOOK_EVENT") or ""
dump = os.environ.get("CONTINUE_LATER_DUMP_TEXT") or ""

if event == "BeforeAgent":
    output = {
        "continue": True,
        "hookSpecificOutput": {
            "additionalContext": dump,
        },
    }
else:
    output = {
        "continue": True,
        "hookSpecificOutput": {
            "hookEventName": event or "UserPromptSubmit",
            "additionalContext": dump,
        },
    }

print(json.dumps(output))
PY
