#!/usr/bin/env node

import { readFileSync, existsSync } from "fs";
import { resolve, basename } from "path";
import { ContinuationGenerator, ContinuationBuilder } from "./generator.js";
import { loadConfig, saveMarkdown, loadMarkdown } from "./io.js";

const args = process.argv.slice(2);
const commandName = basename(process.argv[1]);

/**
 * Display CLI help for continue-later command
 */
function showContinueLaterHelp(): void {
  console.log(`
continue-later

Generate comprehensive continuation.md handoff documentation for fresh sessions.
Perfect for handing off to new team members or resuming after a long break.

Usage:
  continue-later [options]

Options:
  --config <file>      Load configuration from YAML file
  --output <file>      Write output to file (default: continuation.md)
  --help              Show this help message
  --version           Show version

Examples:
  # Generate from config file
  continue-later --config continuation-config.yaml

  # Output to specific file
  continue-later --config config.yaml --output docs/handoff.md

For more info: https://github.com/dhruvanand/create-continuation-skill
`);
}

/**
 * Display CLI help for resume-from-earlier command
 */
function showResumeFromEarlierHelp(): void {
  console.log(`
resume-from-earlier

Load and display a continuation.md file to quickly understand project state.
Use after reading a continuation.md to extract specific information.

Usage:
  resume-from-earlier [options]

Options:
  --file <file>        Path to continuation.md file to load (required)
  --section <name>     Show specific section: project, state, tasks, gotchas, etc.
  --help              Show this help message
  --version           Show version

Examples:
  # Display full continuation
  resume-from-earlier --file continuation.md

  # Show only pending tasks
  resume-from-earlier --file continuation.md --section tasks

  # Show only gotchas
  resume-from-earlier --file continuation.md --section gotchas

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
 * Extract section from markdown
 */
function extractSection(markdown: string, section: string): string {
  const sectionMap: Record<string, string> = {
    project: "## What This Project Is",
    state: "## Current State",
    tasks: "## Pending Tasks",
    gotchas: "## Gotchas & Traps",
    tech: "## Tech Stack",
    build: "## How to Build",
    deploy: "## How to Deploy",
    decisions: "## Key Technical Decisions",
    recent: "## What Was Just Done",
  };

  const sectionHeader = sectionMap[section.toLowerCase()];
  if (!sectionHeader) {
    console.error(`Unknown section: ${section}`);
    console.error(
      "Available: project, state, tasks, gotchas, tech, build, deploy, decisions, recent"
    );
    process.exit(1);
  }

  const lines = markdown.split("\n");
  const startIdx = lines.findIndex((l) => l.includes(sectionHeader));

  if (startIdx === -1) {
    console.error(`Section not found: ${sectionHeader}`);
    process.exit(1);
  }

  // Find next section header
  const endIdx = lines.findIndex(
    (l, i) => i > startIdx && l.startsWith("## ") && !l.includes(sectionHeader)
  );

  const endLine = endIdx === -1 ? lines.length : endIdx;
  return lines.slice(startIdx, endLine).join("\n");
}

/**
 * Parse CLI arguments for continue-later
 */
function parseContinueLaterArgs(): {
  config?: string;
  output: string;
  help: boolean;
} {
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
 * Parse CLI arguments for resume-from-earlier
 */
function parseResumeFromEarlierArgs(): {
  file?: string;
  section?: string;
  help: boolean;
} {
  let file: string | undefined;
  let section: string | undefined;
  let help = false;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--file" && i + 1 < args.length) {
      file = args[++i];
    } else if (args[i] === "--section" && i + 1 < args.length) {
      section = args[++i];
    } else if (args[i] === "--help" || args[i] === "-h") {
      help = true;
    } else if (args[i] === "--version" || args[i] === "-v") {
      showVersion();
      process.exit(0);
    }
  }

  return { file, section, help };
}

/**
 * Handle continue-later command (generate continuation)
 */
async function handleContinueLater(): Promise<void> {
  const { config, output, help } = parseContinueLaterArgs();

  if (help) {
    showContinueLaterHelp();
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

/**
 * Handle resume-from-earlier command (load and display continuation)
 */
async function handleResumeFromEarlier(): Promise<void> {
  const { file, section, help } = parseResumeFromEarlierArgs();

  if (help) {
    showResumeFromEarlierHelp();
    process.exit(0);
  }

  if (!file) {
    console.error(
      "Error: --file argument required. Use --help for usage information."
    );
    process.exit(1);
  }

  if (!existsSync(file)) {
    console.error(`Error: Continuation file not found: ${file}`);
    process.exit(1);
  }

  try {
    const markdown = loadMarkdown(file);

    if (section) {
      const extracted = extractSection(markdown, section);
      console.log(extracted);
    } else {
      console.log(markdown);
    }
  } catch (error) {
    console.error(`Error: ${error}`);
    process.exit(1);
  }
}

/**
 * Main CLI entry point - dispatch to correct command
 */
async function main(): Promise<void> {
  if (commandName.includes("continue-later")) {
    await handleContinueLater();
  } else if (commandName.includes("resume-from-earlier")) {
    await handleResumeFromEarlier();
  } else {
    // Default to continue-later
    await handleContinueLater();
  }
}

main();
