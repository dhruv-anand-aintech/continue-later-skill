/**
 * Configuration for continuation file generation
 */
export interface ContinuationConfig {
  projectName: string;
  workingDirectory: string;
  projectDescription: string;
  techStack: string[];
  currentState: {
    working: string[];
    broken: string[];
    inProgress: string[];
  };
  recentChanges: string;
  pendingTasks: string[];
  keyDecisions: string[];
  gotchas: Gotcha[];
  buildInstructions: string;
  deployInstructions: string;
}

/**
 * A gotcha or trap that consumed time and should be documented
 */
export interface Gotcha {
  title: string;
  description: string;
  solution?: string;
  lesson?: string;
}

/**
 * File entry for the key files table
 */
export interface FileEntry {
  path: string;
  purpose: string;
}

/**
 * Output format options
 */
export type OutputFormat = "markdown" | "yaml" | "json";
