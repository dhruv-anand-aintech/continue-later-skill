# Contributing to create-continuation-skill

Thank you for your interest in improving this project! Here's how you can help.

## Development Setup

```bash
git clone https://github.com/dhruvanand/create-continuation-skill.git
cd create-continuation-skill
npm install
npm run build
npm run dev -- --help
```

## Running Tests

```bash
npm test
```

## Code Style

We use Prettier and ESLint to maintain code quality. Before committing:

```bash
npm run format
npm run lint
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Run tests and linting (`npm run lint && npm test`)
5. Commit with clear messages following [Conventional Commits](https://www.conventionalcommits.org/)
6. Push to your fork and open a PR

## Ideas for Contribution

- **Templates**: Add new continuation config templates for different project types
- **Features**: Interactive CLI prompt for building configs without YAML
- **Export formats**: Support for JSON, TOML, or other formats
- **Integration**: Plugins for popular tools (VS Code, GitHub Actions, etc.)
- **Examples**: Real-world continuation files from open source projects
- **Tests**: Improve test coverage

## Questions?

Open an issue or reach out on GitHub. We're friendly!
