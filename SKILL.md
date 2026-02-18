# Continue Later Skill

Generate and manage project continuation documentation for seamless handoffs, team transitions, and knowledge preservation across coding sessions.

## Overview

The **Continue Later** skill provides a structured approach to documenting project state, enabling developers to:
- Hand off work to teammates with full context
- Resume projects after breaks without losing context
- Document architectural decisions and lessons learned
- Onboard new developers with complete project understanding

Perfect for:
- Team transitions and handoffs
- Multi-week projects requiring context preservation
- Capturing gotchas and lessons learned
- Creating living project documentation

## What This Skill Does

### Generate Phase: `continue-later`

Creates comprehensive continuation.md files from project configuration:

```bash
continue-later --config continuation-config.yaml --output continuation.md
```

**Generates sections for:**
- Project overview and description
- Tech stack
- Current state (working/broken/in-progress)
- Recent changes and decisions
- Pending tasks (next steps)
- Key technical decisions (don't re-litigate them)
- Gotchas & traps (lessons learned)
- Build and deployment instructions

### Resume Phase: `resume-from-earlier`

Load and extract information from continuation files:

```bash
# View full continuation
resume-from-earlier --file continuation.md

# View specific sections
resume-from-earlier --file continuation.md --section tasks
resume-from-earlier --file continuation.md --section gotchas
resume-from-earlier --file continuation.md --section state
resume-from-earlier --file continuation.md --section decisions
resume-from-earlier --file continuation.md --section build
```

**Available sections:**
- `project` - Project overview
- `state` - Current state (working/broken/in-progress)
- `tech` - Tech stack
- `tasks` - Pending tasks
- `gotchas` - Gotchas & traps (lessons learned)
- `recent` - Recent changes
- `decisions` - Key technical decisions
- `build` - Build instructions
- `deploy` - Deploy instructions

## When to Use

- **Handing off work:** "I'm done for the day, hand this off to someone else"
- **Team transitions:** New developer joining the project
- **Long breaks:** Resuming after vacation or time away
- **Project milestones:** Document progress and decisions
- **Onboarding:** Provide incoming developers complete context
- **Knowledge preservation:** Capture how things work before people leave

## Installation

### Global Installation (Recommended)

```bash
# Install via npm
npm install -g create-continuation-skill

# Verify
which continue-later
which resume-from-earlier
```

### In Cursor

Both commands are immediately available after global npm installation:

```bash
# In Cursor terminal
continue-later --config ./continuation-config.yaml
resume-from-earlier --file ./continuation.md --section tasks
```

### Add Skill to Cursor

For auto-suggestions and integrated help:

1. Copy this directory to your Cursor skills folder:
   ```bash
   cp -r create-continuation-skill ~/.cursor/skills/continue-later
   ```

2. Or add to `.cursor/rules/continuation-workflow.md` in your project:

   ```markdown
   # Continuation Workflow

   When user asks to:
   - "hand this off" or "continue later"
     → suggest: continue-later --config continuation-config.yaml
   
   - "resume from earlier" or "what was I working on"
     → suggest: resume-from-earlier --file continuation.md --section tasks

   - "show me the gotchas" or "show me lessons learned"
     → suggest: resume-from-earlier --file continuation.md --section gotchas
   ```

## Quick Start

### Step 1: Create Configuration

Create `continuation-config.yaml` in your project:

```yaml
projectName: My Project
workingDirectory: /path/to/project
projectDescription: |
  Brief description of what your project does.
  One or two sentences.

techStack:
  - Technology 1
  - Technology 2
  - Technology 3

currentState:
  working:
    - Feature or component that works
    - Another working feature
  broken:
    - Known issue (with brief description)
  inProgress:
    - Feature currently being built

recentChanges: |
  ### What Was Done
  - Summary of recent work
  - Bug fixes or features completed
  - Why it was important

pendingTasks:
  - Next task to work on
  - Another pending task
  - Priority-ordered list

keyDecisions:
  - Decision made and why
  - Trade-off explanation
  - Don't re-litigate these

gotchas:
  - title: Brief title of gotcha
    description: What went wrong
    solution: How to fix it
    lesson: What we learned

buildInstructions: |
  npm install
  npm run dev

deployInstructions: |
  npm run build
  npm run deploy
```

### Step 2: Generate Continuation

```bash
continue-later --config continuation-config.yaml
```

Creates `continuation.md` in your project.

### Step 3: Share or Resume

```bash
# Share with team
git add continuation.md
git commit -m "docs: save project state for handoff"

# Later, resume with
resume-from-earlier --file continuation.md

# Or get just what you need
resume-from-earlier --file continuation.md --section tasks
```

## Features

✨ **Two-command workflow:**
- Generate handoff documentation
- Resume with context extraction

✨ **Section extraction:**
- View specific information without full context
- Perfect for quick lookups

✨ **YAML configuration:**
- Human-readable input format
- Version control friendly
- Easy to update

✨ **Structured sections:**
- Project overview
- Tech stack
- Current state (working/broken/in-progress)
- Recent changes
- Pending tasks
- Key decisions
- Gotchas & lessons learned
- Build & deploy instructions

✨ **Beautiful markdown output:**
- GitHub-ready formatting
- Shareable with teams
- Professional appearance

✨ **Multi-format integration:**
- CLI commands
- Programmatic API (TypeScript/JavaScript)
- Integrates with all major coding agents

## Real-World Example

See [examples/continuation-config.yaml](examples/continuation-config.yaml) for a complete Django web app example with all sections filled out.

## Advanced Usage

### Automation with Cron

Auto-generate continuations on a schedule:

```bash
# Generate every Friday at 5 PM
0 17 * * FRI continue-later --config ~/my-project/continuation-config.yaml
```

### GitHub Actions

Auto-generate continuations on merge:

```yaml
name: Generate Continuation

on:
  push:
    branches: [main]

jobs:
  continuation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install -g create-continuation-skill
      - run: continue-later --config continuation-config.yaml
      - run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add continuation.md
          git commit -m "chore: auto-generated continuation" || true
          git push
```

### Git Integration

Store continuations in version control:

```bash
# Commit continuation with your work
git add continuation.md
git commit -m "docs: project state after feature X implementation"

# Share via git push
git push

# New developer clones and resumes
resume-from-earlier --file continuation.md --section tasks
```

## Use Cases

### 1. Handing Off to Teammate

```bash
# Before leaving for the day
continue-later --config continuation-config.yaml
git add continuation.md
git commit -m "docs: save project state for team handoff"
git push

# Teammate picks up
git pull
resume-from-earlier --file continuation.md --section tasks
```

### 2. Onboarding New Developer

```bash
# New developer clones repo
git clone <repo>

# Gets full context
resume-from-earlier --file continuation.md

# Understands gotchas
resume-from-earlier --file continuation.md --section gotchas

# Knows build process
resume-from-earlier --file continuation.md --section build
```

### 3. Resuming After Break

```bash
# Coming back after vacation
resume-from-earlier --file continuation.md --section recent  # What was done
resume-from-earlier --file continuation.md --section tasks   # What's next
resume-from-earlier --file continuation.md --section gotchas # Lessons learned
```

### 4. Project Milestone

```bash
# Document progress at v1.0 release
continue-later --config continuation-config.yaml --output v1.0-continuation.md

# Keep multiple versions
continue-later --config continuation-config.yaml --output v1.1-continuation.md

# Reference historical decisions
resume-from-earlier --file v1.0-continuation.md --section decisions
```

## Integration Guides

This skill integrates seamlessly with:
- **Cursor IDE** - Global commands + skill integration
- **Claude Code** - Environment setup
- **Cline (VSCode)** - Tasks and custom tools
- **GitHub Copilot** - Code snippets
- **Aider** - Terminal integration
- **Continue.dev** - Custom commands
- **OpenCode** - Plugin system
- **AntiGravity** - Workflow integration

See [AGENT_INTEGRATION.md](AGENT_INTEGRATION.md) for platform-specific setup.

## Documentation

- **README.md** - Full feature documentation
- **QUICK_START.md** - 5-minute getting started
- **COMPLETE_SETUP.md** - Step-by-step setup for all agents
- **AGENT_INTEGRATION.md** - Platform-specific integration guides
- **examples/continuation-config.yaml** - Real-world example

## License

MIT - Free for personal and commercial use.

## Support

For issues, questions, or suggestions:
- GitHub Issues: [create-continuation-skill/issues](https://github.com/dhruvanand/create-continuation-skill/issues)
- Documentation: See README.md and other .md files in this repository

---

**Ready to hand off projects with confidence? Start with `continue-later` today!** 🚀
