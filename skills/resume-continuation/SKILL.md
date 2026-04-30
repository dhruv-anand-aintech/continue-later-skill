---
name: resume-continuation
description: Read and summarize continuation.md or continuation-fast.md (whichever exists—prefer structured continuation.md when both are present) so work can resume quickly without losing context.
---

# Resume Continuation

Read and summarize project handoff markdown so work can resume quickly without losing context.

## Files

| File | Typical source |
|------|----------------|
| **`continuation.md`** | Full structured handoff (**continue-later** skill) |
| **`continuation-fast.md`** | Raw git dump (+ optional transcript excerpts) from **continue-later-fast** |

## Overview

Use this skill when the user asks to resume prior work, check project status, or recall the last session.

**Use this skill when the user says:**
- **`/resume-continuation`** (common manual attach label in Cursor)
- **`/resume-from-earlier`** — same workflow; alias people remember from older docs or npm-style CLI naming
- "/resume"
- "resume from continuation"
- "resume from earlier"
- "what was I working on?"
- "continue from last session"

## Workflow

1. **Resolve which file(s) to read** (project root):
   - If **`continuation.md`** exists → treat it as the **primary** handoff (structured sections).
   - Else if **`continuation-fast.md`** exists → read it (often "## Raw Context Dump" / "## Recent user messages").
   - If **both** exist → read **`continuation.md` first** for tasks/state/decisions/gotchas; then skim **`continuation-fast.md`** only when the user asks for the latest git snapshot, raw diff stats, or recent user prompts duplicated there—or when structured sections are missing.
   - If **neither** exists → say so and ask whether to create one (**continue-later** or **continue-later-fast**).
2. Extract only what the user asked for.
3. Prefer these sections when present (mostly in structured `continuation.md`):
   - `## Pending Tasks` for what to do next
   - `## Current State` for working vs broken areas
   - `## Key Technical Decisions` to avoid re-litigating choices
   - `## Gotchas & Traps` to avoid repeated mistakes
   - `## How to Build & Run` to restart quickly  
   From **`continuation-fast.md`**, surface **`## Raw Context Dump`** / **`### Recent user messages`** when relevant.
4. Return a concise, actionable resume summary.

## Output Format

When asked for a full resume, respond with:

```markdown
## Resume Snapshot

- **Sources read:** continuation.md / continuation-fast.md / both
- **Current objective:** ...
- **Next 3 tasks:** ...
- **Known blockers:** ...
- **Important decisions:** ...
- **Gotchas:** ...
- **Run commands:** ...
```

When asked for only one area (for example "show tasks"), return that section only.

## Guardrails

- Do not invent project status; only report what exists in the file(s) you read.
- Quote pending tasks verbatim when possible.
- If information is stale or ambiguous, call it out explicitly.
- If the user requests updates, suggest regenerating **`continuation.md`** with **continue-later**, or **`continuation-fast.md`** with **continue-later-fast**, depending on what they need.
