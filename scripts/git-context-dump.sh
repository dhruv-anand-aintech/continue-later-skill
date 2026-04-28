#!/usr/bin/env bash
# Single source for raw git snapshot text used by continue-later-fast and the Claude hook.
# Usage:
#   git-context-dump.sh markdown-full   — markdown for continuation-fast.md (header + ## Raw Context Dump …)
#   git-context-dump.sh hook-block      — stdin unchanged; reads ARCHIVED_MSG; Claude hook injection blob
#
# Run from repository root (or any cwd inside a git worktree).

set -eu

_collect_git_snapshot() {
  GIT_LOG_OUT=$(git log --oneline -10 2>/dev/null || echo "not a git repo")
  GIT_STATUS_OUT=$(git status --short 2>/dev/null || echo "not a git repo")
  GIT_DIFFSTAT_OUT=$(git diff --stat HEAD 2>/dev/null || echo "no diff")
  GIT_FILES_OUT=$(git diff HEAD --name-only 2>/dev/null | head -20 || echo "none")
}

_emit_markdown_sections() {
  echo "### git log (last 10)"
  printf '%s\n' "$GIT_LOG_OUT"
  echo ""
  echo "### git status"
  printf '%s\n' "$GIT_STATUS_OUT"
  echo ""
  echo "### git diff --stat HEAD"
  printf '%s\n' "$GIT_DIFFSTAT_OUT"
  echo ""
  echo "### recently changed files"
  printf '%s\n' "$GIT_FILES_OUT"
}

emit_markdown_full() {
  _collect_git_snapshot
  echo "# Continuation: $(basename "$(pwd)")"
  echo ""
  echo "**Date:** $(date)"
  echo "**Working directory:** $(pwd)"
  echo ""
  echo "## Raw Context Dump"
  echo ""
  _emit_markdown_sections
}

emit_hook_block() {
  _collect_git_snapshot
  local footer="${ARCHIVED_MSG:-}"
  cat <<DEOF
=== CONTINUATION CONTEXT DUMP (auto-generated before skill) ===
Date: $(date)
Directory: $(pwd)

--- git log (last 10) ---
${GIT_LOG_OUT}

--- git status ---
${GIT_STATUS_OUT}

--- git diff --stat HEAD ---
${GIT_DIFFSTAT_OUT}

--- recently changed files ---
${GIT_FILES_OUT}

${footer}
=== END DUMP ===
DEOF
}

case "${1:-}" in
  markdown-full)
    emit_markdown_full
    ;;
  hook-block)
    emit_hook_block
    ;;
  -h|--help|help)
    grep '^#' "$0" | head -15 | sed 's/^# \{0,1\}//'
    ;;
  *)
    echo "usage: $(basename "$0") markdown-full | hook-block" >&2
    exit 1
    ;;
esac
