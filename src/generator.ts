import { ContinuationConfig, Gotcha } from "./types.js";

/**
 * Generate a continuation.md file from configuration
 * Produces comprehensive handoff documentation for fresh sessions
 */
export class ContinuationGenerator {
  private config: ContinuationConfig;

  constructor(config: ContinuationConfig) {
    this.config = config;
  }

  /**
   * Generate the full markdown output
   */
  generate(): string {
    const sections = [
      this.generateHeader(),
      this.generateProjectDescription(),
      this.generateTechStack(),
      this.generateBuildInstructions(),
      this.generateCurrentState(),
      this.generateRecentChanges(),
      this.generatePendingTasks(),
      this.generateKeyDecisions(),
      this.generateGotchas(),
      this.generateDeployInstructions(),
    ];

    return sections.filter((s) => s.length > 0).join("\n\n");
  }

  private generateHeader(): string {
    const now = new Date().toISOString().split("T")[0];
    return `# Continuation: ${this.config.projectName}

**Date:** ${now}  
**Working directory:** \`${this.config.workingDirectory}\``;
  }

  private generateProjectDescription(): string {
    return `## What This Project Is

${this.config.projectDescription}`;
  }

  private generateTechStack(): string {
    if (this.config.techStack.length === 0) return "";

    const items = this.config.techStack.map((item) => `- ${item}`).join("\n");
    return `## Tech Stack

${items}`;
  }

  private generateBuildInstructions(): string {
    if (!this.config.buildInstructions) return "";
    return `## How to Build & Run

${this.config.buildInstructions}`;
  }

  private generateCurrentState(): string {
    const sections = [];

    if (this.config.currentState.working.length > 0) {
      const items = this.config.currentState.working
        .map((item) => `- ${item}`)
        .join("\n");
      sections.push(`**Working:**\n${items}`);
    }

    if (this.config.currentState.broken.length > 0) {
      const items = this.config.currentState.broken
        .map((item) => `- ${item}`)
        .join("\n");
      sections.push(`**Broken / Known Issues:**\n${items}`);
    }

    if (this.config.currentState.inProgress.length > 0) {
      const items = this.config.currentState.inProgress
        .map((item) => `- ${item}`)
        .join("\n");
      sections.push(`**In Progress:**\n${items}`);
    }

    if (sections.length === 0) return "";
    return `## Current State\n\n${sections.join("\n\n")}`;
  }

  private generateRecentChanges(): string {
    if (!this.config.recentChanges) return "";
    return `## What Was Just Done (Most Recent Session)

${this.config.recentChanges}`;
  }

  private generatePendingTasks(): string {
    if (this.config.pendingTasks.length === 0) return "";

    const items = this.config.pendingTasks
      .map((task, i) => `${i + 1}. ${task}`)
      .join("\n");

    return `## Pending Tasks

${items}`;
  }

  private generateKeyDecisions(): string {
    if (this.config.keyDecisions.length === 0) return "";

    const items = this.config.keyDecisions
      .map((decision) => `- ${decision}`)
      .join("\n\n");

    return `## Key Technical Decisions

${items}`;
  }

  private generateGotchas(): string {
    if (this.config.gotchas.length === 0) return "";

    const items = this.config.gotchas
      .map((gotcha) => this.formatGotcha(gotcha))
      .join("\n\n");

    return `## Gotchas & Traps

${items}`;
  }

  private formatGotcha(gotcha: Gotcha): string {
    let output = `**${gotcha.title}**\n${gotcha.description}`;

    if (gotcha.solution) {
      output += `\n**Solution:** ${gotcha.solution}`;
    }

    if (gotcha.lesson) {
      output += `\n**Lesson:** ${gotcha.lesson}`;
    }

    return output;
  }

  private generateDeployInstructions(): string {
    if (!this.config.deployInstructions) return "";
    return `## How to Deploy

${this.config.deployInstructions}`;
  }
}

/**
 * Helper to build a ContinuationConfig interactively or from structured data
 */
export class ContinuationBuilder {
  private config: Partial<ContinuationConfig> = {};

  setProject(name: string, description: string): this {
    this.config.projectName = name;
    this.config.projectDescription = description;
    return this;
  }

  setWorkingDirectory(dir: string): this {
    this.config.workingDirectory = dir;
    return this;
  }

  setTechStack(stack: string[]): this {
    this.config.techStack = stack;
    return this;
  }

  setState(working: string[], broken: string[], inProgress: string[]): this {
    this.config.currentState = { working, broken, inProgress };
    return this;
  }

  setRecentChanges(changes: string): this {
    this.config.recentChanges = changes;
    return this;
  }

  setPendingTasks(tasks: string[]): this {
    this.config.pendingTasks = tasks;
    return this;
  }

  setKeyDecisions(decisions: string[]): this {
    this.config.keyDecisions = decisions;
    return this;
  }

  addGotcha(gotcha: Gotcha): this {
    if (!this.config.gotchas) {
      this.config.gotchas = [];
    }
    this.config.gotchas.push(gotcha);
    return this;
  }

  setBuildInstructions(instructions: string): this {
    this.config.buildInstructions = instructions;
    return this;
  }

  setDeployInstructions(instructions: string): this {
    this.config.deployInstructions = instructions;
    return this;
  }

  build(): ContinuationConfig {
    if (!this.config.projectName) {
      throw new Error("Project name is required");
    }
    if (!this.config.workingDirectory) {
      throw new Error("Working directory is required");
    }

    return {
      projectName: this.config.projectName,
      workingDirectory: this.config.workingDirectory,
      projectDescription: this.config.projectDescription || "",
      techStack: this.config.techStack || [],
      currentState: this.config.currentState || {
        working: [],
        broken: [],
        inProgress: [],
      },
      recentChanges: this.config.recentChanges || "",
      pendingTasks: this.config.pendingTasks || [],
      keyDecisions: this.config.keyDecisions || [],
      gotchas: this.config.gotchas || [],
      buildInstructions: this.config.buildInstructions || "",
      deployInstructions: this.config.deployInstructions || "",
    };
  }
}
