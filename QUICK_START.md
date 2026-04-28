# Quick start

## Install

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/continue-later-skill/main/install.sh | bash
```

Then restart Cursor (or reload the window).

### CLI (continue-later-fast)

**After `install.sh`:** run **`continue-later-fast`** from your project’s **git root** (scripts install to **`~/.config/continue-later/`**; symlink at **`~/.local/bin/continue-later-fast`** — add **`~/.local/bin`** to `PATH` if needed).

```bash
continue-later-fast -n 12
```

Without the installer, see [README.md](README.md) for `curl` bundles or use **`./scripts/continue-later-fast.sh`** from a repo clone. Defaults to the **newest local transcript by mtime** unless you pass **`--agent`**.

Env: `CONTINUE_LATER_AGENT`, `CONTINUE_LATER_LIMIT`, `CONTINUE_LATER_FROM_CWD`, `CONTINUE_LATER_SKIP_TRANSCRIPT`, `CONTINUE_LATER_CLI_DIR`, `CONTINUE_LATER_BIN_DIR` (installer). **`CONTINUE_LATER_CURSOR_HOOK=0`** skips registering the Cursor **`beforeSubmitPrompt`** hook during install.

## Use


| You say                                     | Skill                                                                         |
| ------------------------------------------- | ----------------------------------------------------------------------------- |
| Hand this off / continue later / save state | **continue-later** → writes structured `continuation.md`                      |
| Quick save / dump raw git + recent prompts  | **continue-later-fast**                                                       |
| Resume from earlier / what was I working on | **resume-continuation** reads `continuation.md` and/or `continuation-fast.md` |


No npm, no marketplace. Installer chooses skill roots automatically from existing assistant dirs (see README); optional **`AGENT_SKILLS_DIRS`** (colon-separated) or legacy **`CURSOR_SKILLS_DIR`**.
