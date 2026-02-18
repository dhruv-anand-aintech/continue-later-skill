#!/usr/bin/env node

import { readFileSync, existsSync } from "fs";
import { resolve } from "path";
import { ContinuationGenerator, ContinuationBuilder } from "./generator.js";
import { loadConfig, saveMarkdown } from "./io.js";

const args = process.argv.slice(2);

/**
 * Display CLI help
 */
function showHelp(): void {
  console.log(`
create-continuation-skill

Generate comprehensive continuation.md handoff documentation for fresh sessions.

Usage:
  create-continuation [options]

Options:
  --config <file>      Load configuration from YAML file
  --output <file>      Write output to file (default: continuation.md)
  --help              Show this help message
  --version           Show version

Examples:
  # Generate from config file
  create-continuation --config continuation-config.yaml

  # Output to specific file
  create-continuation --config config.yaml --output docs/handoff.md

  # Use interactive mode (coming soon)
  create-continuation

For more info: https://github.com/dhruvanand/create-continuation-skill
`);
}

/**
 * Display version
 */
function showVersion(): void {
  const pkg = JSON.parse(
    readFileSync(resolve(import.meta.dir, "../package.json"), "utf-8")
  );
  console.log(`create-continuation-skill v${pkg.version}`);
}

/**
 * Parse CLI arguments
 */
function parseArgs(): { config?: string; output: string; help: boolean } {
  let config: string | undefined;
  let output = "continuation.md";
  let help = false;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--config" && i + 1 < args.length) {
      config = args[++i];
    } else if (args[i] === "--output" && i + 1 < args.length) {
      output = args[++i];
    } else if (args[i] === "--help" || args[i] === "-h") {
      help = true;
    } else if (args[i] === "--version" || args[i] === "-v") {
      showVersion();
      process.exit(0);
    }
  }

  return { config, output, help };
}

/**
 * Main CLI entry point
 */
async function main(): Promise<void> {
  const { config, output, help } = parseArgs();

  if (help) {
    showHelp();
    process.exit(0);
  }

  if (!config) {
    console.error(
      "Error: --config argument required. Use --help for usage information."
    );
    process.exit(1);
  }

  if (!existsSync(config)) {
    console.error(`Error: Config file not found: ${config}`);
    process.exit(1);
  }

  try {
    console.log(`Loading configuration from ${config}...`);
    const cfg = loadConfig(config);

    console.log(`Generating continuation for "${cfg.projectName}"...`);
    const generator = new ContinuationGenerator(cfg);
    const markdown = generator.generate();

    saveMarkdown(markdown, output);
    console.log(`✓ Continuation written to ${output}`);
  } catch (error) {
    console.error(`Error: ${error}`);
    process.exit(1);
  }
}

main();
