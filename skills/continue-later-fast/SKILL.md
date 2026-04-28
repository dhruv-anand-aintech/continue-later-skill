---
name: continue-later-fast
description: Use when the user wants a quick no-LLM context dump to continuation.md. Runs the dump script (or tool call fallback), archives any existing continuation.md, and writes raw git context only — no synthesized summary.
---

# Continue Later Fast

## Overview

Fastest possible handoff: archive existing `continuation.md`, run the git dump script, write raw output directly to `continuation.md`. No LLM synthesis. Use when speed matters or you want pure ground truth without a narrative summary.

## When to Use

- User says "/continue-later-fast" or "quick save" or "just dump the context"
- You want raw context only, no LLM summary
- As a sub-step before running the full `continue-later` skill

## Steps

### 1 — Archive existing continuation.md

```bash
[ -f continuation.md ] && mv continuation.md continuation.archive.$(date +%Y%m%d_%H%M%S).md
```

### 2 — Check for pre-injected dump

Look for `=== CONTINUATION CONTEXT DUMP` in your context (injected by the Claude Code `UserPromptSubmit` hook—see `claude-code/hooks/continue-later-dump.sh` in the [continue-later-skill](https://github.com/dhruv-anand-aintech/continue-later-skill) repo).

- **If present:** use it as the content. Skip the tool call below.
- **If absent:** run this via Bash tool:

```bash
{
  echo "# Continuation: $(basename $(pwd))"
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
```

### 3 — Done

No synthesis step. The file contains raw git state only. A follow-up `continue-later` run can add the structured summary on top.
