# Claude Code hook: programmatic continuation dump

This runs **before** the model sees your message. When your prompt matches continuation-style phrases, the hook:

1. Archives existing root **`continuation.md`** and **`continuation-fast.md`** when present (timestamped `*.archive.*.md`).
2. Runs **[`scripts/git-context-dump.sh`](../scripts/git-context-dump.sh)** (`hook-block` mode)—the same helper **`continue-later-fast.sh` uses—so git snapshot logic is not duplicated.
3. Injects that block as **`additionalContext`** so the skill can use it immediately (look for `=== CONTINUATION CONTEXT DUMP` in context) instead of asking the agent to run shell.

## Install

1. Copy **two** scripts into your Claude Code hooks directory (the hook invokes **`git-context-dump.sh`** next to itself, or via `GIT_CONTEXT_DUMP_SCRIPT`):

   ```bash
   mkdir -p ~/.claude/hooks
   cp claude-code/hooks/continue-later-dump.sh ~/.claude/hooks/
   cp scripts/git-context-dump.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/continue-later-dump.sh ~/.claude/hooks/git-context-dump.sh
   ```

   Raw URLs if not cloning:

   ```bash
   mkdir -p ~/.claude/hooks
   curl -fsSL -o ~/.claude/hooks/continue-later-dump.sh \
     https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/claude-code/hooks/continue-later-dump.sh
   curl -fsSL -o ~/.claude/hooks/git-context-dump.sh \
     https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/scripts/git-context-dump.sh
   chmod +x ~/.claude/hooks/continue-later-dump.sh ~/.claude/hooks/git-context-dump.sh
   ```

2. Merge **`settings.hooks.example.json`** into **`~/.claude/settings.json`**: add the `hooks` key from the example, or nest `UserPromptSubmit` under your existing `"hooks"` object if you already use hooks. For a first-time `hooks` section, you can paste the example file contents at the top level of `settings.json` (only if you do not already have a `hooks` key—otherwise merge manually to avoid overwriting `Notification` or other hook types).

   The `command` path must point at the installed script. This repo’s example uses `"~/.claude/hooks/continue-later-dump.sh"` (same style as Claude Code typically resolves). If your environment does not expand that path, use an absolute path instead.

3. Restart Claude Code (or reload settings) so the hook is registered.

## Matched phrases (case-insensitive)

The hook triggers when the submitted user message matches (substring) any of these patterns (see script `grep`): `continue later`, `save state`, `hand off` / `hand this off`, `i'm done`, `done for today`, `create continuation`, `compact`, and dotted variants like `continue.later`.

Tighten or extend the regex in **`continue-later-dump.sh`** if you need different triggers.

## Relationship to skills

- **continue-later-fast** — if the hook ran, the dump is already in context; the skill skips re-running the bash dump.
- **continue-later** — can layer a structured narrative on top of the same injected block.

## Requirements

`bash`, `python3`, and `git` on `PATH`; runs with the **project working directory** as cwd (Claude Code’s normal hook behavior for project sessions).
