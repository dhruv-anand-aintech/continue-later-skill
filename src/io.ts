import { readFileSync, writeFileSync } from "fs";
import { join } from "path";
import { parse, stringify } from "yaml";
import { ContinuationConfig } from "./types.js";

/**
 * Load a continuation configuration from a YAML file
 */
export function loadConfig(filePath: string): ContinuationConfig {
  try {
    const content = readFileSync(filePath, "utf-8");
    const config = parse(content) as ContinuationConfig;
    return config;
  } catch (error) {
    throw new Error(`Failed to load config from ${filePath}: ${error}`);
  }
}

/**
 * Save a continuation configuration to a YAML file
 */
export function saveConfig(
  config: ContinuationConfig,
  filePath: string
): void {
  try {
    const yaml = stringify(config, { indent: 2 });
    writeFileSync(filePath, yaml, "utf-8");
  } catch (error) {
    throw new Error(`Failed to save config to ${filePath}: ${error}`);
  }
}

/**
 * Load a markdown continuation file (parsing front matter if present)
 */
export function loadMarkdown(filePath: string): string {
  try {
    return readFileSync(filePath, "utf-8");
  } catch (error) {
    throw new Error(`Failed to load markdown from ${filePath}: ${error}`);
  }
}

/**
 * Save a markdown continuation file
 */
export function saveMarkdown(content: string, filePath: string): void {
  try {
    writeFileSync(filePath, content, "utf-8");
  } catch (error) {
    throw new Error(`Failed to save markdown to ${filePath}: ${error}`);
  }
}
