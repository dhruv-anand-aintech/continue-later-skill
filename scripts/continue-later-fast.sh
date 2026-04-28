#!/usr/bin/env bash
# Raw git dump to continuation.md (no LLM). Run from your project root.
# Same behavior as skills/continue-later-fast/SKILL.md

set -eu

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [[ -f continuation.md ]]; then
  mv continuation.md "continuation.archive.$(date +%Y%m%d_%H%M%S).md"
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
} > continuation.md

echo "Written: continuation.md"
