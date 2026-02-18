# Quick Start: create-continuation-skill

A production-ready npm package with **two commands** for comprehensive handoff documentation:

- **`continue-later`** - Generate handoff documentation from YAML config
- **`resume-from-earlier`** - Load and read continuation files

## What It Does

### continue-later Command

Generates comprehensive handoff documentation from a YAML config file:
- Project overview and tech stack
- Current state (working/broken/in-progress)
- Recent changes (what was just done)
- Pending tasks (prioritized next steps)
- Key technical decisions (avoid re-litigating them)
- **Gotchas & traps** (saves hours for the next developer)
- Build and deploy instructions (exact commands)

### resume-from-earlier Command

Loads and displays a continuation file:
- View full continuation or specific sections
- Extract tasks, gotchas, build instructions, etc.
- Perfect for picking up where you left off

## Install

```bash
npm install -g create-continuation-skill
# or locally:
npm install --save-dev create-continuation-skill
```

## Usage: Two Commands

### Command 1: continue-later (Generate)

Create a configuration file:

```yaml
# continuation-config.yaml
projectName: My Project
workingDirectory: /path/to/project
projectDescription: A web app that does X

techStack:
  - Node.js
  - React
  - PostgreSQL

currentState:
  working:
    - User authentication
    - Dashboard
  broken:
    - Export feature (crashes on large datasets)
  inProgress:
    - Dark mode UI

recentChanges: |
  Fixed export crash by streaming large datasets.
  Implemented batching logic that writes 1000 rows at a time.

pendingTasks:
  - Add dark mode toggle
  - Performance test with 1M+ records
  - Security audit

keyDecisions:
  - Chose streaming over pagination for memory efficiency

gotchas:
  - title: Export crash on large datasets
    description: OOM when loading all data at once
    solution: Stream data in 1000-row batches
    lesson: Test with production data sizes early

buildInstructions: |
  npm install
  npm run dev

deployInstructions: |
  npm run build && npm run deploy
```

See [examples/continuation-config.yaml](examples/continuation-config.yaml) for a full example.

Then generate:

```bash
continue-later --config continuation-config.yaml --output continuation.md
```

This creates `continuation.md` with all sections properly formatted and ready to share.

### Command 2: resume-from-earlier (Read)

Load and display a continuation file:

```bash
# View the entire continuation
resume-from-earlier --file continuation.md

# View specific sections
resume-from-earlier --file continuation.md --section tasks
resume-from-earlier --file continuation.md --section gotchas
resume-from-earlier --file continuation.md --section state
resume-from-earlier --file continuation.md --section build
```

Perfect for picking up where you left off or reviewing project status.

## Use Cases

- **Team handoffs**: Give new team members complete context without meetings
- **Long projects**: Document progress before context gets lost
- **Solo work**: Resume projects after weeks/months away with full clarity
- **Retrospectives**: Capture lessons learned for future reference
- **Onboarding**: Provide incoming developers with architectural decisions and gotchas

## Programmatic Usage

```typescript
import {
  ContinuationBuilder,
  ContinuationGenerator,
} from "create-continuation-skill";

const config = new ContinuationBuilder()
  .setProject("My App", "A real-time chat application")
  .setWorkingDirectory("/path/to/project")
  .setTechStack(["Node.js", "React", "MongoDB"])
  .setState(
    ["Login", "Chat UI"], // working
    ["Group chat notifications"], // broken
    ["File sharing"] // in progress
  )
  .setRecentChanges("Implemented exponential backoff for socket reconnections")
  .setPendingTasks([
    "Fix group notifications (race condition in subscriber list)",
    "Add typing indicators",
  ])
  .addGotcha({
    title: "Socket timeout after 10 minutes",
    description: "NAT timeout causes real-time disconnect",
    solution: "Added heartbeat pings every 5 minutes",
    lesson: "Long-lived connections need keepalives",
  })
  .setBuildInstructions("npm install && npm run dev")
  .build();

const generator = new ContinuationGenerator(config);
const markdown = generator.generate();

console.log(markdown);
```

## Examples

See [examples/](examples/) for real-world continuation config files:
- Django blog platform
- React Native mobile app
- And more...

## Features

✅ **Two commands** - `continue-later` (generate) and `resume-from-earlier` (read)
✅ **YAML configuration** - Easy to write and version control
✅ **Section extraction** - View specific parts (tasks, gotchas, build, etc.)
✅ **Structured sections** - Project, state, decisions, gotchas, etc.
✅ **Markdown output** - Beautiful, readable format
✅ **CLI tool** - Use from terminal or scripts
✅ **Programmatic API** - Use in Node.js code
✅ **TypeScript types** - Full type support for developers

## Publishing

This package is published on npm. To publish your own version:

1. [Create an npm account](https://npmjs.com)
2. Run `npm login`
3. Update version in `package.json`
4. Run `npm publish`

See [PUBLISH.md](PUBLISH.md) for detailed steps.

## Contributing

Have ideas? Found a bug? Want to add features?

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to get involved.

## License

MIT - use freely in your projects!

---

**Ready to create your first continuation?** Copy [examples/continuation-config.yaml](examples/continuation-config.yaml), edit it for your project, and run:

```bash
# Generate a continuation
continue-later --config YOUR-CONFIG.yaml

# Later, resume from it
resume-from-earlier --file continuation.md
resume-from-earlier --file continuation.md --section tasks
```
