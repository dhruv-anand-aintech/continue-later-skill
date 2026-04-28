#!/usr/bin/env bash
# Raw git dump to continuation.md (no LLM). Optionally append recent human user
# prompts from Claude Code / Cursor JSONL transcripts (same layout as
# claude-session-viewer: ~/.claude/projects/**/<session>.jsonl).
#
# Usage:
#   continue-later-fast.sh [--agent SESSION_OR_AGENT_ID] [-n N] [--jsonl PATH] [--from-cwd]
#   CONTINUE_LATER_AGENT=uuid continue-later-fast.sh
#
# AGENT_ID matches **/<ID>.jsonl under ~/.claude/projects or ~/.cursor/projects.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$SCRIPT_DIR/session_recent_user_messages.py"

AGENT="${CONTINUE_LATER_AGENT:-}"
LIMIT="${CONTINUE_LATER_LIMIT:-12}"
JSONL="${CONTINUE_LATER_JSONL:-}"
FROM_CWD="${CONTINUE_LATER_FROM_CWD:-0}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [agent-id]

Write continuation.md with git context and (when transcript args are given)
recent human user prompts from local JSONL sessions.

Options:
  -a, --agent ID     Transcript id (Claude session UUID, Cursor agent id, or subagent stem).
                     Matches **/<ID>.jsonl under ~/.claude/projects and ~/.cursor/projects.
  -n, --limit N      Max recent human prompts (default: \$CONTINUE_LATER_LIMIT or 12).
  -j, --jsonl PATH   Use this transcript file explicitly (skips discovery).
      --from-cwd     Pick newest Claude Code session whose file mentions cwd (\$PWD).
  -h, --help         Show this help.

Environment:
  CONTINUE_LATER_AGENT, CONTINUE_LATER_LIMIT, CONTINUE_LATER_JSONL,
  CONTINUE_LATER_FROM_CWD=1 (same as --from-cwd)

Examples:
  $(basename "$0") --agent 7b252952-7b76-4ae4-ad55-9db805a8e546
  CONTINUE_LATER_AGENT=\$YOUR_SESSION_ID $(basename "$0")
  $(basename "$0") --from-cwd
EOF
}

while [[ $# -gt 0 ]]; do
  case "${1:-}" in
    -h|--help)
      usage
      exit 0
      ;;
    -a|--agent)
      AGENT="$2"
      shift 2
      ;;
    -n|--limit)
      LIMIT="$2"
      shift 2
      ;;
    -j|--jsonl)
      JSONL="$2"
      shift 2
      ;;
    --from-cwd)
      FROM_CWD=1
      shift
      ;;
    *)
      if [[ "${1:-}" == -* ]]; then
        echo "error: unknown option: $1" >&2
        exit 1
      fi
      if [[ -z "$AGENT" ]]; then
        AGENT="$1"
      else
        echo "error: unexpected argument: $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [[ -f continuation.md ]]; then
  mv continuation.md "continuation.archive.$(date +%Y%m%d_%H%M%S).md"
fi

PY_ARGS=()
if [[ -n "$JSONL" ]]; then
  PY_ARGS+=(--jsonl "$JSONL")
elif [[ -n "$AGENT" ]]; then
  PY_ARGS+=(--agent "$AGENT")
elif [[ "$FROM_CWD" == "1" ]]; then
  PY_ARGS+=(--from-cwd --cwd "$(pwd)")
fi

{
  echo "# Continuation: $(basename "$(pwd)")"
  echo ""
  echo "**Date:** $(date)"
  echo "**Working directory:** $(pwd)"
  echo ""
  echo "## Raw Context Dump"
  echo ""
  echo "### git log (last 10)"
  git log --oneline -10 2>/dev/null || echo "not a git repo"
  echo ""
  echo "### git status"
  git status --short 2>/dev/null
  echo ""
  echo "### git diff --stat HEAD"
  git diff --stat HEAD 2>/dev/null
  echo ""
  echo "### recently changed files"
  git diff HEAD --name-only 2>/dev/null | head -20
  if [[ ${#PY_ARGS[@]} -gt 0 ]]; then
    echo ""
    if [[ ! -f "$PY" ]]; then
      echo ""
      echo "_Transcript excerpt skipped: missing \`session_recent_user_messages.py\` beside this script — clone the repo or download both files under \`scripts/\`._"
    else
      python3 "$PY" "${PY_ARGS[@]}" --limit "$LIMIT" || true
    fi
  fi
} > continuation.md

echo "Written: continuation.md"
