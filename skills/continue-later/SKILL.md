---
name: continue-later
description: Generate a structured continuation.md for handoffs—project context, state, tasks, gotchas, and deploy steps. Use when the user wants to save state or hand off work (not for quick raw git dumps; use continue-later-fast for that).
---

# Continue Later

Generate and manage project continuation documentation for seamless handoffs, team transitions, and knowledge preservation across coding sessions.

## Overview

When the user asks to hand off work, save state, or create a continuation, generate a comprehensive `continuation.md` following this structure.

**Use this skill when the user says:**
- "Hand this off" / "Continue later" / "Save project state"
- "Create a continuation for the team"
- "Document where we left off"
- "I'm done for the day, create handoff docs"

For summarizing handoff files, use the **resume-continuation** skill (it reads **`continuation.md`** and/or **`continuation-fast.md`**—prefer structured `continuation.md` when both exist). For a raw git-focused dump, use **continue-later-fast** (writes **`continuation-fast.md`**).

## Continuation.md Structure

When generating a continuation, create a file with these sections. Be specific—use actual project context, not placeholders.

```markdown
# Continuation: [Project Name]

**Date:** YYYY-MM-DD
**Working directory:** [absolute path]

---

## What This Project Is

[2-3 sentences. What does it do, for whom, and why it matters.]

## Tech Stack

[Bullet list: language, frameworks, databases, key libraries]

## How to Build & Run

[Exact commands. Nothing assumed.]

## Key Files

| File | Purpose |
|------|---------|
| path/to/file | What it does |

## What Was Just Done (Most Recent Session)

[Chronological summary of changes. Be specific: what was changed, why, what bug it fixed. Include the actual fix—not just "fixed bug X".]

## Current State

**Working:**
- [List what demonstrably works]

**Broken / Known Issues:**
- [List known bugs with root cause if known]

**In Progress:**
- [Anything half-done or partially implemented]

## Pending Tasks

[Ordered list of what the user still wants done, in priority order. Copy verbatim from the user's most recent requests if possible.]

## Key Technical Decisions

[Decisions made during the session that a new agent must not undo or re-litigate. Include the *why*.]

## Gotchas & Traps

[Anything that caused problems, wasted time, or was non-obvious. Future agent must know these. Format:]

**Title**
Description of what went wrong.
**Solution:** How to fix it.
**Lesson:** What we learned.

## How to Deploy

[Exact commands to build, package, and deploy.]
```

## Rules for Generating Continuations

0. **Archive existing handoffs before writing.** If **`continuation.md`** and/or **`continuation-fast.md`** exist in the project root, move each to **`continuation.archive.YYYYMMDD_HHMMSS.md`** / **`continuation-fast.archive.YYYYMMDD_HHMMSS.md`** (same pattern as **`continue-later-fast`** and **`claude-code/hooks/continue-later-dump.sh`**), then write the new **`continuation.md`**.
1. **Be specific, not vague.** "Fixed the regex to match AM/PM filenames" beats "fixed the filename bug".
2. **State the exact current state.** If the DB has 0 rows, say so. Don't paper over partial states.
3. **Pending tasks verbatim.** Copy the user's unmet requests word-for-word—don't paraphrase.
4. **Gotchas are mandatory.** Every trap that cost time goes in Gotchas. This is the highest-value section.
5. **Include exact commands.** The next agent should copy-paste build, run, test, and deploy commands.
6. **Write to project root** as `continuation.md`, so it's immediately visible.

## Anti-Patterns to Avoid

- ❌ Vague state: "mostly working" → ✅ "11 rows in DB, gallery shows 0 due to pending refreshGallery fix"
- ❌ Omitting install steps → ✅ Include exact commands
- ❌ Summarising pending tasks → ✅ Quote user requests directly
- ❌ Skipping gotchas → These are the most valuable lines

## Example Gotcha Format

```markdown
**Mac Screenshots Use 12-Hour Format**
The original regex only matched 24-hour filenames. Zero screenshots were indexed until fixed.
**Solution:** Updated regex to match `Screenshot 2024-10-30 at 11.07.04 AM.png`
**Lesson:** Test with real production data formats early.
```
