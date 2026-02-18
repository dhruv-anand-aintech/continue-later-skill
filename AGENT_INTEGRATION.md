# Integration Guide: Using create-continuation-skill with AI Coding Agents

This guide shows how to integrate `create-continuation-skill` with major AI coding agents and IDEs so it's available globally in your workflow.

## Table of Contents

1. [Cursor IDE](#cursor-ide)
2. [Claude Code](#claude-code)
3. [Cline (VSCode Extension)](#cline-vscode-extension)
4. [GitHub Copilot](#github-copilot)
5. [Aider](#aider)
6. [Continue.dev](#continuedev)
7. [OpenCode](#opencode)
8. [AntiGravity](#antigravity)

---

## Cursor IDE

Cursor is the most popular AI code editor. Integrate the skill as a native Cursor skill.

### Option 1: Use as Cursor Skill (Recommended)

Create a `SKILL.md` file in your project and reference it:

```markdown
# Continue Later Skill

Use this skill to generate project handoff documentation or resume from earlier continuations.

## When to Use

- Handing off work to a teammate
- Taking a break from a long project
- Starting a new session and need context
- Documenting architectural decisions

## Commands

\`\`\`bash
continue-later --config continuation-config.yaml
resume-from-earlier --file continuation.md --section tasks
\`\`\`

## How to Set Up

1. \`npm install -g create-continuation-skill\`
2. Create continuation-config.yaml in your project
3. Run: \`continue-later --config continuation-config.yaml\`
4. Share continuation.md with teammates

## Sections Available

- tasks: pending work
- gotchas: traps and lessons learned
- state: current project state
- decisions: architectural decisions
- build: build instructions
```

Place this in `.cursor/skills/continue-later/SKILL.md`.

### Option 2: Global NPM Installation + Shell Integration

```bash
# 1. Install globally
npm install -g create-continuation-skill

# 2. Verify installation
which continue-later
which resume-from-earlier

# 3. Use in Cursor terminal
continue-later --config ./continuation-config.yaml
resume-from-earlier --file ./continuation.md --section tasks
```

Then in Cursor, use the built-in terminal to run commands.

### Option 3: Add to .cursor/rules/ for Auto-Suggestions

Create `.cursor/rules/continuation-workflow.md`:

```markdown
# Continuation Workflow Rule

When a user asks to:
- "Hand this off" or "continue later"
  → Suggest: continue-later --config continuation-config.yaml
  
- "Resume from earlier" or "what was I working on"
  → Suggest: resume-from-earlier --file continuation.md --section tasks

- "Show me the gotchas"
  → Suggest: resume-from-earlier --file continuation.md --section gotchas

When creating continuations, include:
- Recent changes (what was done)
- Current state (working/broken/in-progress)
- Pending tasks (next steps)
- Key gotchas (lessons learned)
- Build/deploy instructions
```

Cursor will reference this and suggest the commands automatically.

---

## Claude Code

Claude Code is Claude's code editing capability. Integrate via environment variables and configuration.

### Setup for Claude Code

1. **Install globally:**
   ```bash
   npm install -g create-continuation-skill
   ```

2. **Create a Claude Code prompt in your project:**

   Create `.claude/continuation-prompt.md`:

   ```markdown
   # Continuation Workflow
   
   When I ask you to "continue later" or "save state":
   1. Generate a YAML config summarizing the project state
   2. Run: continue-later --config continuation-config.yaml
   3. Show me the generated continuation.md
   
   When I ask you to "resume from earlier":
   1. Run: resume-from-earlier --file continuation.md
   2. Extract and highlight the key sections
   3. Focus on gotchas and pending tasks
   
   Available commands:
   - continue-later --config <file> --output <file>
   - resume-from-earlier --file <file> --section <name>
   ```

3. **Tell Claude Code to use these commands:**

   In your `.claude/context.md`:

   ```markdown
   # Tools Available
   
   The project has continuation-skill installed globally:
   
   - `continue-later` - Generate project handoff documentation
   - `resume-from-earlier` - Load and read continuation files
   
   Use these when:
   - Handing off to another session
   - Need to quickly review project state
   - Documenting architectural decisions
   ```

---

## Cline (VSCode Extension)

Cline is a popular VSCode extension for AI-assisted coding.

### Setup for Cline

1. **Install globally:**
   ```bash
   npm install -g create-continuation-skill
   ```

2. **Add to your VSCode workspace settings** (`.vscode/settings.json`):

   ```json
   {
     "cline.custom-tools": [
       {
         "name": "continue-later",
         "description": "Generate project continuation/handoff documentation",
         "command": "continue-later --config continuation-config.yaml",
         "when": "need_to_save_project_state"
       },
       {
         "name": "resume-from-earlier",
         "description": "Load and display continuation file",
         "command": "resume-from-earlier --file continuation.md --section tasks",
         "when": "need_to_understand_project_state"
       }
     ]
   }
   ```

3. **Create a Cline task** in `.vscode/tasks.json`:

   ```json
   {
     "version": "2.0.0",
     "tasks": [
       {
         "label": "Generate Continuation",
         "type": "shell",
         "command": "continue-later",
         "args": ["--config", "continuation-config.yaml"],
         "problemMatcher": []
       },
       {
         "label": "Resume From Earlier",
         "type": "shell",
         "command": "resume-from-earlier",
         "args": ["--file", "continuation.md", "--section", "tasks"],
         "problemMatcher": []
       }
     ]
   }
   ```

4. **Use in Cline:**
   - Type: "Generate a continuation for handoff" → Cline will suggest the tool
   - Type: "What are the pending tasks?" → Cline will run resume-from-earlier

---

## GitHub Copilot

GitHub Copilot in VSCode can suggest these commands based on context.

### Setup for Copilot

1. **Install globally:**
   ```bash
   npm install -g create-continuation-skill
   ```

2. **Create code snippets** in `.vscode/continuation.code-snippets`:

   ```json
   {
     "Continue Later": {
       "prefix": "continue-later",
       "body": ["continue-later --config continuation-config.yaml"],
       "description": "Generate project continuation documentation"
     },
     "Resume From Earlier": {
       "prefix": "resume-from-earlier",
       "body": ["resume-from-earlier --file continuation.md --section ${1|tasks,gotchas,state,build,decisions|}"],
       "description": "Load and display continuation file"
     },
     "Show Gotchas": {
       "prefix": "show-gotchas",
       "body": ["resume-from-earlier --file continuation.md --section gotchas"],
       "description": "Display project gotchas and lessons learned"
     }
   }
   ```

3. **Add a comment in your code** that hints to Copilot:

   ```javascript
   // When handing off work, use:
   // continue-later --config continuation-config.yaml
   
   // When resuming, use:
   // resume-from-earlier --file continuation.md --section tasks
   ```

   Copilot will suggest similar patterns.

---

## Aider

Aider is a terminal-based AI assistant for coding.

### Setup for Aider

1. **Install globally:**
   ```bash
   npm install -g create-continuation-skill
   ```

2. **Create an Aider workflow file** (`.aider/continuation.md`):

   ```markdown
   # Aider Continuation Workflow
   
   ## When starting a new session:
   
   ```aider
   /read continuation.md
   /ask What are the pending tasks?
   /run resume-from-earlier --file continuation.md --section tasks
   ```

   ## When finishing work:
   
   ```aider
   /run continue-later --config continuation-config.yaml
   /read continuation.md
   /ask Summarize the recent changes
   ```

3. **Add to your Aider config** (`~/.aider/aider.conf`):

   ```ini
   [tools]
   continue-later = continue-later --config continuation-config.yaml
   resume-from-earlier = resume-from-earlier --file continuation.md
   show-tasks = resume-from-earlier --file continuation.md --section tasks
   ```

4. **Use in Aider:**
   ```bash
   aider --tools continue-later,resume-from-earlier
   ```

---

## Continue.dev

Continue.dev is an open-source AI code assistant for VSCode.

### Setup for Continue.dev

1. **Install globally:**
   ```bash
   npm install -g create-continuation-skill
   ```

2. **Configure Continue** (`~/.continue/config.json`):

   ```json
   {
     "customCommands": [
       {
         "name": "Continue Later",
         "description": "Generate project continuation documentation",
         "prompt": "Generate a continuation.md file for handoff using continue-later --config continuation-config.yaml"
       },
       {
         "name": "Resume From Earlier",
         "description": "Show pending tasks and current state",
         "prompt": "Show me the pending tasks using resume-from-earlier --file continuation.md --section tasks"
       },
       {
         "name": "Show Gotchas",
         "description": "Display project gotchas and lessons learned",
         "prompt": "Show the gotchas using resume-from-earlier --file continuation.md --section gotchas"
       }
     ]
   }
   ```

3. **Use in Continue:**
   - Click "Continue Later" in the custom commands menu
   - Continue will run the command and display the output

---

## OpenCode

OpenCode is an open-source code assistant IDE.

### Setup for OpenCode

1. **Install globally:**
   ```bash
   npm install -g create-continuation-skill
   ```

2. **Create a plugin** in your project or OpenCode extensions:

   `opencode-continuation-plugin.js`:
   ```javascript
   // OpenCode Plugin: Continuation Skill Integration
   
   export function registerContinuationPlugin(vscode) {
     // Register continue-later command
     vscode.commands.registerCommand('continuation.continueLater', () => {
       const terminal = vscode.window.createTerminal('Continue Later');
       terminal.sendText('continue-later --config continuation-config.yaml');
       terminal.show();
     });
     
     // Register resume-from-earlier command
     vscode.commands.registerCommand('continuation.resumeFromEarlier', () => {
       const terminal = vscode.window.createTerminal('Resume From Earlier');
       terminal.sendText('resume-from-earlier --file continuation.md');
       terminal.show();
     });
   }
   ```

3. **Add to OpenCode configuration:**

   ```json
   {
     "plugins": ["opencode-continuation-plugin.js"],
     "commands": [
       {
         "id": "continuation.continueLater",
         "title": "Continue Later: Generate Handoff"
       },
       {
         "id": "continuation.resumeFromEarlier",
         "title": "Resume From Earlier: Load Project State"
       }
     ]
   }
   ```

---

## AntiGravity

AntiGravity is a no-code platform with AI coding capabilities.

### Setup for AntiGravity

1. **Install globally on your system:**
   ```bash
   npm install -g create-continuation-skill
   ```

2. **Create a workflow in AntiGravity:**

   ```yaml
   name: Project Continuation Workflow
   
   triggers:
     - name: Hand Off Project
       action: run_command
       command: continue-later --config continuation-config.yaml
   
     - name: Resume Work
       action: run_command
       command: resume-from-earlier --file continuation.md --section tasks
   
     - name: Review Gotchas
       action: run_command
       command: resume-from-earlier --file continuation.md --section gotchas
   
     - name: Check Build Instructions
       action: run_command
       command: resume-from-earlier --file continuation.md --section build
   ```

3. **Integrate with AntiGravity UI:**
   - Add buttons for each command
   - Connect to project handoff workflow
   - Auto-generate continuations on project completion

---

## Universal Installation & Global Access

### Option 1: NPM (Easiest)

```bash
# Install globally (accessible everywhere)
npm install -g create-continuation-skill

# Verify
which continue-later
which resume-from-earlier

# Use anywhere
continue-later --config config.yaml
resume-from-earlier --file continuation.md
```

### Option 2: Homebrew (macOS/Linux)

```bash
# Install via Homebrew (when published to homebrew-core)
brew install create-continuation-skill

# Use anywhere
continue-later --config config.yaml
```

### Option 3: System PATH

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Add npm global bins to PATH (if not already)
export PATH="$(npm config get prefix)/bin:$PATH"

# Create aliases for convenience
alias continue-later='continue-later'
alias resume-from-earlier='resume-from-earlier'
```

Then reload:
```bash
source ~/.zshrc  # or ~/.bashrc
```

---

## Quick Reference

| Agent | Setup Method | Command Access |
|-------|--------------|-----------------|
| **Cursor** | Skill file + global npm | Terminal + suggestions |
| **Claude Code** | Environment + config | Terminal + context |
| **Cline** | VSCode tasks | Task runner + suggestions |
| **Copilot** | Snippets + hints | Autocomplete suggestions |
| **Aider** | Config file | Terminal commands |
| **Continue.dev** | Config + commands | UI menu |
| **OpenCode** | Plugin | Command palette |
| **AntiGravity** | Workflow YAML | UI workflows |

---

## Usage Patterns Across Agents

### Pattern 1: Hand Off to Team Member

```bash
# In any agent, when finishing work:
continue-later --config continuation-config.yaml
# Share continuation.md with team
```

### Pattern 2: Resume From Earlier

```bash
# In any agent, when starting new session:
resume-from-earlier --file continuation.md --section tasks
# Shows pending tasks
```

### Pattern 3: Quick Lookup

```bash
# Show specific information without full context:
resume-from-earlier --file continuation.md --section gotchas
resume-from-earlier --file continuation.md --section decisions
resume-from-earlier --file continuation.md --section build
```

### Pattern 4: Onboard New Developer

```bash
# New developer joins and needs context:
resume-from-earlier --file continuation.md
# Full context without meetings
```

---

## Environment Variables

Set these to customize behavior across all agents:

```bash
# Use a default output location
export CONTINUATION_OUTPUT_DIR="~/Projects/continuations"

# Suppress color output (for logging)
export CONTINUATION_NO_COLOR=1

# Set default section
export CONTINUATION_DEFAULT_SECTION="tasks"

# Enable debug logging
export CONTINUATION_DEBUG=1
```

---

## Pro Tips

1. **Version Your Continuations**: Keep multiple continuations for different milestones
   ```bash
   continue-later --config config.yaml --output continuation-v1.0.md
   continue-later --config config.yaml --output continuation-v1.1.md
   ```

2. **Schedule Regular Continuations**: Use cron jobs to auto-generate
   ```bash
   # Every Friday at 5 PM
   0 17 * * FRI continue-later --config continuation-config.yaml
   ```

3. **Share via Git**: Commit continuation.md to version control
   ```bash
   git add continuation.md
   git commit -m "docs: save project state for team handoff"
   git push
   ```

4. **Continuous Integration**: Generate continuations in CI/CD pipelines
   ```yaml
   # GitHub Actions example
   - name: Generate Continuation
     run: continue-later --config continuation-config.yaml
   - name: Commit and Push
     run: |
       git add continuation.md
       git commit -m "chore: auto-generated continuation"
       git push
   ```

5. **Documentation Integration**: Combine with project docs
   ```bash
   resume-from-earlier --file continuation.md > docs/project-state.md
   ```

---

## Troubleshooting

### Commands Not Found

```bash
# Check if globally installed
npm list -g create-continuation-skill

# Re-install if needed
npm install -g create-continuation-skill

# Check PATH
echo $PATH

# Verify npm bin directory
npm config get prefix
```

### Permission Issues

```bash
# Fix permissions (macOS/Linux)
sudo npm install -g create-continuation-skill --unsafe-perm

# Or use a node version manager (recommended)
nvm install node  # get latest Node
npm install -g create-continuation-skill
```

### Agent Not Finding Commands

1. Install globally first: `npm install -g create-continuation-skill`
2. Reload agent terminal: Close and reopen
3. Verify with: `which continue-later`
4. Check agent's PATH settings

---

## Next Steps

1. Choose your primary agent (Cursor, Claude, Copilot, etc.)
2. Follow the setup steps for that agent
3. Install globally: `npm install -g create-continuation-skill`
4. Test both commands:
   ```bash
   continue-later --help
   resume-from-earlier --help
   ```
5. Create your first continuation!

---

**Made for AI-assisted development.** Seamlessly integrate with your favorite coding agent.
