#!/usr/bin/env bash
# Raw git dump to continuation-fast.md (no LLM). Appends recent human user prompts from
# Claude Code / Cursor JSONL transcripts. With no --agent/--jsonl/--from-cwd, picks the
# transcript file with the newest mtime under ~/.cursor/projects and ~/.claude/projects.
#
# Usage:
#   continue-later-fast.sh [--agent SESSION_OR_AGENT_ID] [-n N] [--jsonl PATH] [--from-cwd]
#   CONTINUE_LATER_AGENT=uuid continue-later-fast.sh
#
# AGENT_ID matches **/<ID>.jsonl under ~/.claude/projects or ~/.cursor/projects.

set -eu

# Resolve directory containing this script (works when invoked via symlink; install.sh puts helpers in ~/.config/continue-later/).
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
DUMP="$SCRIPT_DIR/git-context-dump.sh"
PY="$SCRIPT_DIR/session_recent_user_messages.py"

if [[ ! -f "$DUMP" ]]; then
  echo "error: git-context-dump.sh must sit beside continue-later-fast.sh — reinstall via install.sh (~/.config/continue-later/) or clone scripts/." >&2
  exit 1
fi

AGENT="${CONTINUE_LATER_AGENT:-}"
LIMIT="${CONTINUE_LATER_LIMIT:-12}"
JSONL="${CONTINUE_LATER_JSONL:-}"
FROM_CWD="${CONTINUE_LATER_FROM_CWD:-0}"
SKIP_PY="${CONTINUE_LATER_SKIP_TRANSCRIPT:-0}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [agent-id]

Write continuation-fast.md with git context and recent human prompts from the local
transcript (default: newest-by-mtime JSONL under ~/.cursor/projects and ~/.claude/projects).

Options:
  -a, --agent ID     Transcript id (Claude session UUID, Cursor agent id, or subagent stem).
                     Matches **/<ID>.jsonl under ~/.claude/projects and ~/.cursor/projects.
  -n, --limit N      Max recent human prompts (default: \$CONTINUE_LATER_LIMIT or 12).
  -j, --jsonl PATH   Use this transcript file explicitly (skips discovery).
      --from-cwd     Prefer newest Claude session mentioning cwd; else fall back to newest mtime.
      --skip-transcript   Git snapshot only (same as CONTINUE_LATER_SKIP_TRANSCRIPT=1).
  -h, --help         Show this help.

Environment:
  CONTINUE_LATER_AGENT, CONTINUE_LATER_LIMIT, CONTINUE_LATER_JSONL,
  CONTINUE_LATER_FROM_CWD=1 (same as --from-cwd),
  CONTINUE_LATER_SKIP_TRANSCRIPT=1 — omit transcript section.
  CONTINUE_LATER_FAST_FILE — override output filename (default continuation-fast.md)

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
    --skip-transcript)
      SKIP_PY=1
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

OUT="${CONTINUE_LATER_FAST_FILE:-continuation-fast.md}"

# Match continue-later-dump.sh / continue-later: archive both handoff filenames before writing.
TS="$(date +%Y%m%d_%H%M%S)"
if [[ -f continuation.md ]]; then
  mv continuation.md "continuation.archive.${TS}.md"
fi
if [[ -f "$OUT" ]]; then
  mv "$OUT" "continuation-fast.archive.${TS}.md"
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
  bash "$DUMP" markdown-full
  echo ""
  if [[ "$SKIP_PY" == "1" ]]; then
    :
  elif [[ ! -f "$PY" ]]; then
    echo "_Transcript excerpt skipped: missing \`session_recent_user_messages.py\` beside this script — clone the repo or download both files under \`scripts/\`._"
  else
    if ((${#PY_ARGS[@]})); then
      python3 "$PY" "${PY_ARGS[@]}" --limit "$LIMIT" || true
    else
      python3 "$PY" --limit "$LIMIT" || true
    fi
  fi
} > "$OUT"

echo "Written: $OUT"
