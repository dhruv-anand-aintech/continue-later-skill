# Continue Later Skill

A **Cursor skill** for generating and managing project continuation documentation. Install via **Skillfish marketplace**—no npm or additional setup required.

## What It Does

When you ask your AI to "hand this off" or "continue later," it generates a comprehensive `continuation.md` file with:

- Project overview and tech stack
- Current state (working/broken/in-progress)
- Recent changes and decisions
- Pending tasks (next steps)
- Gotchas & traps (lessons learned)
- Build and deploy instructions

When you ask to "resume from earlier," it reads your existing `continuation.md` and surfaces the relevant sections.

## Installation

**Install from Skillfish marketplace:** [mcpmarket.com](https://mcpmarket.com)

1. Go to Skillfish marketplace
2. Search for "Continue Later"
3. Click Install
4. The skill is available in Cursor—no npm, no CLI, no extra setup

## Usage

### Generate a Continuation

Say to your AI:
- "Hand this off"
- "Create a continuation for the team"
- "Save project state—I'm done for the day"
- "Document where we left off"

The AI generates `continuation.md` in your project root following the skill's structure.

### Resume From Earlier

Say to your AI:
- "Resume from earlier"
- "What was I working on?"
- "Show me the pending tasks"
- "What are the gotchas?"

The AI reads `continuation.md` and presents the relevant information.

## Continuation Structure

The skill produces markdown with these sections:

| Section | Purpose |
|---------|---------|
| What This Project Is | 2-3 sentence overview |
| Tech Stack | Languages, frameworks, databases |
| How to Build & Run | Exact commands |
| Key Files | File → purpose table |
| What Was Just Done | Recent changes (specific) |
| Current State | Working / broken / in progress |
| Pending Tasks | Next steps (verbatim) |
| Key Technical Decisions | Don't re-litigate |
| Gotchas & Traps | Lessons learned |
| How to Deploy | Exact deploy commands |

## Example

See [examples/continuation-config.yaml](examples/continuation-config.yaml) for a complete example structure (YAML format for reference—the AI generates markdown directly).

## Use Cases

- **Team handoffs** — Hand off to teammates with full context
- **Long projects** — Resume after weeks with zero ramp-up
- **Onboarding** — New developers get complete context
- **Knowledge preservation** — Capture decisions before people leave

## License

MIT
