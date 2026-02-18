# Continue Later Skill

Generate and manage project continuation documentation for seamless handoffs, team transitions, and knowledge preservation across coding sessions.

## Overview

The **Continue Later** skill provides a structured approach to documenting project state. When the user asks to hand off work, save state, or create a continuation, you generate a comprehensive `continuation.md` file following this structure.

**Use this skill when the user says:**
- "Hand this off" / "Continue later" / "Save project state"
- "Create a continuation for the team"
- "Document where we left off"
- "I'm done for the day, create handoff docs"
- "Resume from earlier" / "What was I working on?" (read existing continuation.md)

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

1. **Be specific, not vague.** "Fixed the regex to match AM/PM filenames" beats "fixed the filename bug".
2. **State the exact current state.** If the DB has 0 rows, say so. Don't paper over partial states.
3. **Pending tasks verbatim.** Copy the user's unmet requests word-for-word—don't paraphrase.
4. **Gotchas are mandatory.** Every trap that cost time goes in Gotchas. This is the highest-value section.
5. **Include exact commands.** The next agent should copy-paste build, run, test, and deploy commands.
6. **Write to project root** as `continuation.md`, so it's immediately visible.

## When User Asks to "Resume From Earlier"

If the user has an existing `continuation.md`:

1. Read the file
2. Summarize or extract the section they need:
   - **Tasks** → Pending tasks (what to do next)
   - **Gotchas** → Lessons learned (avoid repeating mistakes)
   - **State** → What works, what's broken, what's in progress
   - **Decisions** → Don't re-litigate these
   - **Build** → How to get running
3. Present the relevant information clearly

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

## Installation

**Install via Skillfish marketplace.** This skill is distributed through Skillfish. Add it to Cursor from the Skillfish marketplace—no npm or additional setup required.

Once installed, the AI has access to this skill and will generate or read continuations when you ask.
