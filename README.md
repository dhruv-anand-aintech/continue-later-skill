# create-continuation-skill

Generate comprehensive **continuation.md** handoff documentation for fresh development sessions. Perfect for handing off projects to new team members, resuming long-running tasks, or documenting your work before context gets lost.

**Two commands, two workflows:**
- **`continue-later`** - Create a continuation file (hand off or save your state)
- **`resume-from-earlier`** - Load and read a continuation file (pick up where you left off)

## The Problem

Long projects, multi-week tasks, or team handoffs require detailed context that's easy to lose:
- **What was just implemented?** (Exact changes, not vague summaries)
- **What's currently broken?** (Root causes matter)
- **What's the next step?** (In priority order)
- **What trapped us?** (Gotchas save hours)
- **How do we build & deploy?** (Exact commands, nothing assumed)

A simple `continuation.md` file solves this—and this tool generates it automatically.

## Installation

```bash
npm install -g create-continuation-skill
```

Or use it locally in a project:

```bash
npm install --save-dev create-continuation-skill
```

## Usage: Two Workflows

### Workflow 1: Continue Later (Creating a Handoff)

Use **`continue-later`** to save your project state for handoff or future resumption.

#### Step 1: Create a configuration file

Save this as `continuation-config.yaml`:

```yaml
projectName: MyAwesomeApp
workingDirectory: /Users/you/Code/my-awesome-app
projectDescription: |
  A cross-platform mobile app for tracking water usage.
  Built with React Native, PostgreSQL backend, and real-time analytics.

techStack:
  - React Native (iOS/Android)
  - PostgreSQL with TimescaleDB
  - Node.js / Express
  - Redux for state management
  - Jest + Detox for testing

currentState:
  working:
    - User authentication
    - Real-time dashboard
    - Email notifications
  broken:
    - File upload for videos (500 error)
    - Widget refresh on Android
  inProgress:
    - Dark mode implementation
    - Performance optimizations

recentChanges: |
  ### Fixed Real-time Sync Issue
  The dashboard wasn't syncing data in real-time due to socket timeout after 10 minutes.
  Implemented heartbeat mechanism: client sends ping every 5 minutes, server responds with pong.

  ### Migrated to TimescaleDB
  Replaced vanilla PostgreSQL with TimescaleDB for time-series data.
  Water usage queries now 100x faster (3s → 30ms).

pendingTasks:
  - Fix file upload for videos (investigate 500 error)
  - Test dark mode on Android 8-14
  - Performance test with 1M+ records
  - Security audit of API endpoints

keyDecisions:
  - Used heartbeat mechanism instead of long-polling for real-time updates
  - Chose TimescaleDB over vanilla Postgres for time-series optimization

gotchas:
  - title: WebSocket NAT Timeout
    description: Idle connections drop after exactly 10 minutes
    solution: Implement heartbeat pings every 5 minutes
    lesson: Always add keepalive to long-lived connections

  - title: File Upload Timeout
    description: Large videos fail with 500 error after 30s
    solution: Implement chunked/multipart upload
    lesson: Test with production file sizes early

buildInstructions: |
  ```bash
  npm install
  npm run dev
  ```

deployInstructions: |
  ```bash
  npm run build && npm run deploy
  ```
```

#### Step 2: Generate the continuation file

```bash
continue-later --config continuation-config.yaml --output continuation.md
```

This creates `continuation.md` with all sections properly formatted and ready to share.

---

### Workflow 2: Resume From Earlier (Reading a Handoff)

Use **`resume-from-earlier`** to load and read a continuation file.

#### View the Full Continuation

```bash
resume-from-earlier --file continuation.md
```

Displays the entire continuation file beautifully formatted.

#### View Specific Sections

```bash
# Show just the pending tasks
resume-from-earlier --file continuation.md --section tasks

# Show just the gotchas (learn from past mistakes)
resume-from-earlier --file continuation.md --section gotchas

# Show current state (what works/broken)
resume-from-earlier --file continuation.md --section state

# Show recent changes (context of where we left off)
resume-from-earlier --file continuation.md --section recent

# Show build instructions (how to start)
resume-from-earlier --file continuation.md --section build

# Show key decisions (don't re-litigate them)
resume-from-earlier --file continuation.md --section decisions
```

**Available sections:**
- `project` - Project overview
- `state` - Current state (working/broken/in-progress)
- `tech` - Tech stack
- `tasks` - Pending tasks (next steps)
- `gotchas` - Gotchas & traps (learn from history)
- `recent` - Recent changes (context)
- `decisions` - Key technical decisions
- `build` - Build instructions
- `deploy` - Deploy instructions

---

## Use Cases

✅ **Team Handoffs** - Hand off to new team members with full context
✅ **Long Projects** - Resume after weeks/months with zero ramp-up time
✅ **Vacation/Leave** - Someone else can continue your work seamlessly
✅ **Multi-Sprint Work** - Document progress before context fades
✅ **Retrospectives** - Capture lessons learned for future reference
✅ **Onboarding** - Provide incoming developers with architectural decisions

## Features

✅ **`continue-later` command** - Generate handoff documentation from YAML
✅ **`resume-from-earlier` command** - Load and read continuation files
✅ **YAML configuration** - Easy to write and version control
✅ **Markdown output** - Beautiful, GitHub-ready format
✅ **CLI tool** - Use from terminal or scripts
✅ **Programmatic API** - Use in Node.js code
✅ **TypeScript support** - Full type definitions
✅ **Real-world examples** - Django, React Native, etc.

## Programmatic Usage

```typescript
import {
  ContinuationBuilder,
  ContinuationGenerator,
  loadMarkdown,
} from "create-continuation-skill";

// Create a continuation
const config = new ContinuationBuilder()
  .setProject("My App", "A real-time chat application")
  .setWorkingDirectory("/path/to/project")
  .setTechStack(["Node.js", "React", "MongoDB"])
  .setState(
    ["Login", "Chat UI"], // working
    ["Group notifications"], // broken
    ["File sharing"] // in progress
  )
  .setRecentChanges("Implemented exponential backoff for socket reconnections")
  .setPendingTasks(["Fix group notifications", "Add typing indicators"])
  .addGotcha({
    title: "Socket timeout after 10 minutes",
    description: "NAT timeout causes real-time disconnect",
    solution: "Added heartbeat pings every 5 minutes",
    lesson: "Long-lived connections need keepalives",
  })
  .setBuildInstructions("npm install && npm run dev")
  .setDeployInstructions("npm run deploy")
  .build();

const generator = new ContinuationGenerator(config);
const markdown = generator.generate();
console.log(markdown);

// Load and read a continuation
const content = loadMarkdown("continuation.md");
console.log(content);
```

## Examples

See [examples/](examples/) for real-world continuation configs.

## Contributing

Have ideas? Found a bug? Want to add features?

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to get involved.

## Publishing

To publish the package to npm:

See [NEXT_STEPS.md](NEXT_STEPS.md) for detailed steps.

## License

MIT - use freely in your projects!

---

**Ready to get started?**

```bash
# Create your first continuation
continue-later --config continuation-config.yaml

# Later, resume from it
resume-from-earlier --file continuation.md
resume-from-earlier --file continuation.md --section tasks
```
