---
name: resume-from-earlier
description: Resume work from continuation.md or continuation-fast.md. Use when the user runs /resume-from-earlier or asks to pick up from a handoff file—same logic as resume-continuation, shipped as its own skill folder so every platform discovers it by name.
---

# Resume From Earlier

Read and summarize project handoff markdown so work can resume quickly without losing context.

This is a **separate skill folder** from **resume-continuation** so assistants that only load skills by directory name (not a shared manifest) still pick up the slash-style command **`/resume-from-earlier`**. The workflow is identical to **resume-continuation**.

## Files

| File | Typical source |
|------|----------------|
| **`continuation.md`** | Full structured handoff (**continue-later** skill) |
| **`continuation-fast.md`** | Raw git dump (+ optional transcript excerpts) from **continue-later-fast** |

## Overview

**Use this skill when the user says:**
- **`/resume-from-earlier`** (manual attach / slash command)
- "resume from earlier"
- "resume from continuation"
- "what was I working on?"
- "continue from last session"

Natural-language variants without a slash are also covered by the **resume-continuation** skill; either skill may run for the same request.

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
