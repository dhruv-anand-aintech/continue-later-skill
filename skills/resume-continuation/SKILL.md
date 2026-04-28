---
name: resume-continuation
description: Read and summarize an existing continuation.md so work can resume quickly without losing context.
---

# Resume Continuation

Read and summarize an existing `continuation.md` so work can resume quickly without losing context.

## Overview

Use this skill when the user asks to resume prior work, check project status, or recall the last session.

**Use this skill when the user says:**
- "/resume"
- "resume from continuation"
- "resume from earlier"
- "what was I working on?"
- "continue from last session"

## Workflow

1. Locate `continuation.md` in the current project root.
2. If the file does not exist, say so and ask whether to create one (via **continue-later**).
3. Read the file and extract only what the user needs.
4. Prefer these sections:
   - `## Pending Tasks` for what to do next
   - `## Current State` for working vs broken areas
   - `## Key Technical Decisions` to avoid re-litigating choices
   - `## Gotchas & Traps` to avoid repeated mistakes
   - `## How to Build & Run` to restart quickly
5. Return a concise, actionable resume summary.

## Output Format

When asked for a full resume, respond with:

```markdown
## Resume Snapshot

- **Current objective:** ...
- **Next 3 tasks:** ...
- **Known blockers:** ...
- **Important decisions:** ...
- **Gotchas:** ...
- **Run commands:** ...
```

When asked for only one area (for example "show tasks"), return that section only.

## Guardrails

- Do not invent project status; only report what exists in `continuation.md`.
- Quote pending tasks verbatim when possible.
- If information is stale or ambiguous, call it out explicitly.
- If the user requests updates, suggest regenerating `continuation.md` with the **continue-later** skill.
