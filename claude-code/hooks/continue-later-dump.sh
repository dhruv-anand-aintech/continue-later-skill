#!/usr/bin/env bash
# Claude Code UserPromptSubmit hook: runs *before* the LLM sees the prompt.
# On continuation-style messages, archives any existing continuation.md, runs a
# programmatic git dump, and injects it as additionalContext (see skills).
#
# Install: copy to ~/.claude/hooks/continue-later-dump.sh, chmod +x, and merge
#          claude-code/settings.hooks.example.json into ~/.claude/settings.json
#          (see claude-code/README.md).

PROMPT=$(python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('message','').lower())" 2>/dev/null || echo "")

if echo "$PROMPT" | grep -qE 'continue.later|continue later|save.state|save state|hand.?off|hand this off|i.?m done|done for today|create.?continuation|compact'; then
  ARCHIVED_MSG=""
  if [[ -f "continuation.md" ]]; then
    ARCHIVE="continuation.archive.$(date +%Y%m%d_%H%M%S).md"
    mv "continuation.md" "$ARCHIVE"
    ARCHIVED_MSG="Archived previous continuation.md → ${ARCHIVE}"
  fi

  DUMP=$(cat << DUMPEOF
=== CONTINUATION CONTEXT DUMP (auto-generated before skill) ===
Date: $(date)
Directory: $(pwd)

--- git log (last 10) ---
$(git log --oneline -10 2>/dev/null || echo "not a git repo")

--- git status ---
$(git status --short 2>/dev/null || echo "not a git repo")

--- git diff --stat HEAD ---
$(git diff --stat HEAD 2>/dev/null || echo "no diff")

--- recently changed files ---
$(git diff HEAD --name-only 2>/dev/null | head -20 || echo "none")

${ARCHIVED_MSG}
=== END DUMP ===
DUMPEOF
)

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
