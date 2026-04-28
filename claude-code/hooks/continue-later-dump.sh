#!/usr/bin/env bash
# Claude Code UserPromptSubmit hook: runs *before* the LLM sees your prompt.
# On continuation-style messages, archives continuation.md / continuation-fast.md,
# injects git snapshot via scripts/git-context-dump.sh hook-block (single source of truth).
#
# Install: copy this file next to git-context-dump.sh (from scripts/), chmod +x both,
#          or set GIT_CONTEXT_DUMP_SCRIPT to an absolute path to git-context-dump.sh.
# Merge claude-code/settings.hooks.example.json into ~/.claude/settings.json.

set -eu

_resolve_git_dump_helper() {
  local h="${GIT_CONTEXT_DUMP_SCRIPT:-}"
  if [[ -n "$h" && -f "$h" ]]; then
    printf '%s' "$h"
    return 0
  fi
  local hook_dir
  hook_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -f "${hook_dir}/git-context-dump.sh" ]]; then
    printf '%s' "${hook_dir}/git-context-dump.sh"
    return 0
  fi
  # Repo checkout: claude-code/hooks → ../../scripts
  if [[ -f "${hook_dir}/../../scripts/git-context-dump.sh" ]]; then
    printf '%s' "$(cd "${hook_dir}/../../scripts" && pwd)/git-context-dump.sh"
    return 0
  fi
  echo ""
}

PROMPT=$(python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('message','').lower())" 2>/dev/null || echo "")

if echo "$PROMPT" | grep -qE 'continue.later|continue later|save.state|save state|hand.?off|hand this off|i.?m done|done for today|create.?continuation|compact'; then
  ARCHIVED_MSG=""
  if [[ -f "continuation.md" ]]; then
    ARCHIVE="continuation.archive.$(date +%Y%m%d_%H%M%S).md"
    mv "continuation.md" "$ARCHIVE"
    ARCHIVED_MSG="Archived previous continuation.md → ${ARCHIVE}"
  fi
  if [[ -f "continuation-fast.md" ]]; then
    ARCHIVE_FAST="continuation-fast.archive.$(date +%Y%m%d_%H%M%S).md"
    mv "continuation-fast.md" "$ARCHIVE_FAST"
    ARCHIVED_MSG="${ARCHIVED_MSG:+${ARCHIVED_MSG}; }Archived previous continuation-fast.md → ${ARCHIVE_FAST}"
  fi

  HELPER="$(_resolve_git_dump_helper)"
  if [[ -z "$HELPER" || ! -f "$HELPER" ]]; then
    echo "continue-later-dump.sh: install scripts/git-context-dump.sh beside this hook or set GIT_CONTEXT_DUMP_SCRIPT" >&2
    exit 0
  fi

  export ARCHIVED_MSG
  DUMP=$("$HELPER" hook-block)

  export CONTINUATION_DUMP="$DUMP"
  python3 << 'PYEOF'
import json
import os

dump = os.environ.get("CONTINUATION_DUMP", "")
print(
    json.dumps(
        {
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": dump,
            }
        }
    )
)
PYEOF
fi
