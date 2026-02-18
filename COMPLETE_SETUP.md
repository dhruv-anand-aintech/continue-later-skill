# Complete Setup: From Installation to Global Integration

**Full journey: Getting `create-continuation-skill` working across all your AI coding agents.**

## TL;DR (5 Minutes)

```bash
# 1. Install globally
npm install -g create-continuation-skill

# 2. Verify installation
which continue-later
which resume-from-earlier

# 3. Create a config (optional, for first test)
cat > continuation-config.yaml << 'EOF'
projectName: My Project
workingDirectory: $(pwd)
projectDescription: A great project
techStack:
  - Node.js
  - React
currentState:
  working:
    - Feature X
  broken:
    - Bug Y
  inProgress:
    - Feature Z
pendingTasks:
  - Fix Bug Y
  - Add Feature Z
buildInstructions: npm install && npm run dev
deployInstructions: npm run build && npm run deploy
EOF

# 4. Test both commands
continue-later --config continuation-config.yaml
resume-from-earlier --file continuation.md --section tasks

# 5. Follow agent-specific setup below
```

---

## Step 1: Global Installation

Choose **one** installation method:

### Method A: NPM (Recommended - works everywhere)

```bash
npm install -g create-continuation-skill

# Verify
which continue-later
which resume-from-earlier

# Both should return paths like:
# /usr/local/bin/continue-later
# /usr/local/bin/resume-from-earlier
```

### Method B: Homebrew (macOS/Linux - when published)

```bash
# After formula is published to homebrew-core
brew install create-continuation-skill
```

### Method C: Manual PATH (Advanced)

```bash
# 1. Install locally
npm install create-continuation-skill

# 2. Add to ~/.zshrc or ~/.bashrc
export PATH="$(npm config get prefix)/bin:$PATH"

# 3. Reload shell
source ~/.zshrc  # or ~/.bashrc

# 4. Verify
continue-later --help
```

---

## Step 2: Verify Global Access

```bash
# Test 1: Command is in PATH
which continue-later
which resume-from-earlier

# Test 2: Help works
continue-later --help
resume-from-earlier --help

# Test 3: Use from any directory
cd /tmp
continue-later --help
cd ~
continue-later --help
```

If any test fails, see Troubleshooting section below.

---

## Step 3: Choose Your Primary Agent

Pick the AI coding agent you use most, then follow the setup for that agent.

### Cursor IDE (Most Popular)

**Setup Time: 5 minutes**

```bash
# Option 1: Use globally installed commands in terminal
# Just run in Cursor's built-in terminal:
continue-later --config ./continuation-config.yaml
resume-from-earlier --file ./continuation.md --section tasks

# Option 2: Create a Cursor skill (auto-suggestions)
# Create: .cursor/skills/continue-later/SKILL.md
mkdir -p .cursor/skills/continue-later
cat > .cursor/skills/continue-later/SKILL.md << 'EOF'
# Continue Later Skill

Generate project continuation/handoff documentation.

## When to Use

- Handing off work to teammates
- Taking a break from long projects
- Documenting architectural decisions

## Commands

continue-later --config continuation-config.yaml
resume-from-earlier --file continuation.md --section tasks

## Available Sections

- tasks: pending work
- gotchas: lessons learned
- state: current state
- decisions: architecture
- build: how to build
EOF

# Option 3: Add to Cursor rules (for auto-suggestions)
# Create: .cursor/rules/continuation-workflow.md
mkdir -p .cursor/rules
cat > .cursor/rules/continuation-workflow.md << 'EOF'
# Continuation Workflow

When user asks to:
- "hand this off" → suggest: continue-later --config continuation-config.yaml
- "show tasks" → suggest: resume-from-earlier --file continuation.md --section tasks
- "show gotchas" → suggest: resume-from-earlier --file continuation.md --section gotchas
EOF
```

### Claude Code

**Setup Time: 3 minutes**

```bash
# Create: .claude/context.md
mkdir -p .claude
cat > .claude/context.md << 'EOF'
# Tools Available

Commands installed globally:
- continue-later --config file.yaml
- resume-from-earlier --file continuation.md --section SECTION

Use these to:
- Generate handoff docs for team
- Resume project state between sessions
- Document architectural decisions
EOF
```

### Cline (VSCode Extension)

**Setup Time: 5 minutes**

```bash
# Create: .vscode/tasks.json
mkdir -p .vscode
cat > .vscode/tasks.json << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Generate Continuation",
      "type": "shell",
      "command": "continue-later",
      "args": ["--config", "continuation-config.yaml"]
    },
    {
      "label": "Resume From Earlier",
      "type": "shell",
      "command": "resume-from-earlier",
      "args": ["--file", "continuation.md", "--section", "tasks"]
    }
  ]
}
EOF
```

### GitHub Copilot

**Setup Time: 3 minutes**

```bash
# Create: .vscode/continuation.code-snippets
mkdir -p .vscode
cat > .vscode/continuation.code-snippets << 'EOF'
{
  "Continue Later": {
    "prefix": "continue-later",
    "body": ["continue-later --config continuation-config.yaml"]
  },
  "Resume From Earlier": {
    "prefix": "resume-from-earlier",
    "body": ["resume-from-earlier --file continuation.md --section tasks"]
  }
}
EOF
```

### Aider (Terminal)

**Setup Time: 3 minutes**

```bash
# Add to: ~/.aider/aider.conf
cat >> ~/.aider/aider.conf << 'EOF'

[tools]
continue-later = continue-later --config continuation-config.yaml
resume-from-earlier = resume-from-earlier --file continuation.md
show-tasks = resume-from-earlier --file continuation.md --section tasks
EOF

# Use with:
aider --tools continue-later,resume-from-earlier
```

### Continue.dev

**Setup Time: 3 minutes**

```bash
# Edit: ~/.continue/config.json
cat >> ~/.continue/config.json << 'EOF'
{
  "customCommands": [
    {
      "name": "Continue Later",
      "description": "Generate project continuation",
      "prompt": "Run: continue-later --config continuation-config.yaml"
    },
    {
      "name": "Resume From Earlier",
      "description": "Load continuation file",
      "prompt": "Run: resume-from-earlier --file continuation.md --section tasks"
    }
  ]
}
EOF
```

---

## Step 4: Create Your First Continuation Config

Create a `continuation-config.yaml` in your project:

```yaml
projectName: My Awesome Project
workingDirectory: /path/to/project
projectDescription: |
  A web app that does X, Y, and Z.
  Built with Node.js, React, and PostgreSQL.

techStack:
  - Node.js
  - React
  - PostgreSQL
  - Docker

currentState:
  working:
    - User authentication
    - Dashboard UI
    - Email notifications
  broken:
    - Export feature (crashes on large files)
    - Widget refresh on mobile
  inProgress:
    - Dark mode
    - Performance optimization

recentChanges: |
  ### Fixed Export Crash
  Implemented streaming to handle large files.
  Added 1000-row batching logic.

  ### Migrated to PostgreSQL 15
  Updated schema, ran migration successfully.

pendingTasks:
  - Fix export for mobile users
  - Complete dark mode UI
  - Performance test with 1M records
  - Security audit

keyDecisions:
  - Used streaming over in-memory loading for memory efficiency
  - PostgreSQL over MongoDB for ACID compliance

gotchas:
  - title: Export Timeout on Large Files
    description: OOM when loading all data at once
    solution: Stream data in 1000-row batches
    lesson: Test with production data sizes early

buildInstructions: |
  npm install
  npm run dev

deployInstructions: |
  npm run build
  npm run deploy
```

---

## Step 5: Test Both Commands

```bash
# Generate a continuation
continue-later --config continuation-config.yaml

# This creates: continuation.md

# View it
cat continuation.md

# Or use the resume command to view sections
resume-from-earlier --file continuation.md
resume-from-earlier --file continuation.md --section tasks
resume-from-earlier --file continuation.md --section gotchas
```

---

## Step 6: Integration Patterns

### Pattern A: Handoff to Team

```bash
# When you're done for the day or handing off:
continue-later --config continuation-config.yaml

# Commit to git
git add continuation.md
git commit -m "docs: save project state for team handoff"
git push

# Share continuation.md with team
```

### Pattern B: Resume From Earlier

```bash
# When starting a new session:
resume-from-earlier --file continuation.md --section tasks

# Shows pending tasks - perfect way to start work
```

### Pattern C: Get Just What You Need

```bash
# Only show pending tasks
resume-from-earlier --file continuation.md --section tasks

# Only show gotchas (lessons learned)
resume-from-earlier --file continuation.md --section gotchas

# Only show build instructions
resume-from-earlier --file continuation.md --section build

# Only show key decisions
resume-from-earlier --file continuation.md --section decisions
```

---

## Step 7: Automation (Optional)

### Auto-Generate on Schedule

```bash
# Add to crontab (generates every Friday at 5 PM)
0 17 * * FRI continue-later --config /path/to/project/continuation-config.yaml
```

### GitHub Actions (Auto-generate on merge)

Create `.github/workflows/continuation.yml`:

```yaml
name: Generate Continuation

on:
  push:
    branches: [main, develop]

jobs:
  continuation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm install -g create-continuation-skill
      - run: continue-later --config continuation-config.yaml
      - run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add continuation.md
          git commit -m "chore: auto-generated continuation" || true
          git push
```

---

## Troubleshooting

### "Command not found: continue-later"

```bash
# Solution 1: Verify installation
npm list -g create-continuation-skill

# If not listed, reinstall:
npm install -g create-continuation-skill

# Solution 2: Check PATH
echo $PATH

# Your npm global bin should be in PATH:
npm config get prefix
# Should be: /usr/local/node or similar

# Solution 3: Reload shell
source ~/.zshrc  # or ~/.bashrc

# Solution 4: Full verification
which npm
which continue-later  # Should show: /usr/local/bin/continue-later
```

### "Permission denied"

```bash
# Solution 1: Use nvm (recommended)
nvm install node
npm install -g create-continuation-skill

# Solution 2: Fix permissions (if needed)
sudo npm install -g create-continuation-skill --unsafe-perm=true --allow-root
```

### Agent Can't Find Commands

```bash
# 1. Verify global installation first
which continue-later

# 2. Reload agent terminal (close and reopen)

# 3. Check agent's shell configuration
# Add to ~/.zshrc or ~/.bashrc:
export PATH="$(npm config get prefix)/bin:$PATH"

# 4. Restart agent
```

---

## Next Steps

1. ✅ Install globally: `npm install -g create-continuation-skill`
2. ✅ Choose your primary agent (Cursor, Claude, Copilot, etc.)
3. ✅ Follow agent-specific setup above
4. ✅ Create `continuation-config.yaml`
5. ✅ Run: `continue-later --config continuation-config.yaml`
6. ✅ Run: `resume-from-earlier --file continuation.md`
7. 🎉 Start using it in your workflow!

---

## For More Details

- **README.md** - Full feature overview
- **QUICK_START.md** - Quick start guide
- **AGENT_INTEGRATION.md** - Detailed agent-specific setup
- **NEXT_STEPS.md** - Publishing guide

---

## Need Help?

If something doesn't work:

1. Check **Troubleshooting** section above
2. Read **AGENT_INTEGRATION.md** for detailed agent setup
3. Verify: `which continue-later` and `which resume-from-earlier`
4. Check: `npm list -g create-continuation-skill`

Happy handing off! 🚀
