# Quick Start: create-continuation-skill

A production-ready npm package for generating **continuation.md** handoff documentation.

## What It Does

Generates comprehensive handoff documentation from a YAML config file:
- Project overview and tech stack
- Current state (working/broken/in-progress)
- Recent changes (what was just done)
- Pending tasks (prioritized next steps)
- Key technical decisions (avoid re-litigating them)
- **Gotchas & traps** (saves hours for the next developer)
- Build and deploy instructions (exact commands)

## Install

```bash
npm install -g create-continuation-skill
# or locally:
npm install --save-dev create-continuation-skill
```

## Usage

### 1. Create a config file

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
  Fixed export crash by streaming large datasets instead of loading into memory.
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

### 2. Generate the continuation file

```bash
create-continuation --config continuation-config.yaml --output continuation.md
```

This creates `continuation.md` with all sections properly formatted and ready to share.

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

✅ **YAML configuration** - Easy to write and version control
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

**Ready to generate your first continuation?** Copy [examples/continuation-config.yaml](examples/continuation-config.yaml), edit it for your project, and run:

```bash
create-continuation --config YOUR-CONFIG.yaml
```
