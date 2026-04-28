#!/usr/bin/env python3
"""
Extract recent human-authored user prompts from Claude Code or Cursor agent JSONL transcripts.

Discovery mirrors ~/.claude/projects/*.jsonl layout used by claude-session-viewer (sync-sessions.ts):
  ~/.claude/projects/<encoded-project>/<session-id>.jsonl
  ~/.claude/projects/.../subagents/<agent>.jsonl

Cursor agent transcripts:
  ~/.cursor/projects/<workspace>/agent-transcripts/<id>/<id>.jsonl

Reads JSON lines only (no SQLite — Claude Code ships line-delimited sessions on disk).
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Iterable, Optional


def _decode_cursor_user_query(text: str) -> str:
    text = text.strip()
    m = re.search(r"<user_query>\s*(.*?)\s*</user_query>", text, flags=re.DOTALL | re.IGNORECASE)
    if m:
        return m.group(1).strip()
    return text


def _text_from_cursor(obj: dict[str, Any]) -> Optional[str]:
    if obj.get("role") != "user":
        return None
    parts = (obj.get("message") or {}).get("content")
    if not isinstance(parts, list):
        return None
    chunks: list[str] = []
    for block in parts:
        if not isinstance(block, dict):
            continue
        if block.get("type") != "text":
            continue
        raw = block.get("text") or ""
        chunks.append(_decode_cursor_user_query(raw))
    out = "\n\n".join(c for c in chunks if c).strip()
    return out or None


def _text_from_claude_user(obj: dict[str, Any]) -> Optional[str]:
    if obj.get("type") not in ("user", "human"):
        return None
    msg = obj.get("message")
    if not isinstance(msg, dict) or msg.get("role") != "user":
        return None
    content = msg.get("content")
    if isinstance(content, str):
        s = content.strip()
        return s or None
    if isinstance(content, list):
        pieces: list[str] = []
        for block in content:
            if not isinstance(block, dict):
                continue
            if block.get("type") == "tool_result":
                continue
            if block.get("type") == "text" and block.get("text"):
                pieces.append(str(block["text"]).strip())
            elif isinstance(block.get("content"), str):
                pieces.append(block["content"].strip())
        out = "\n\n".join(c for c in pieces if c).strip()
        return out or None
    return None


def extract_human_prompt(line_obj: dict[str, Any]) -> Optional[str]:
    return _text_from_cursor(line_obj) or _text_from_claude_user(line_obj)


def iter_messages(jsonl_path: Path) -> Iterable[dict[str, Any]]:
    with jsonl_path.open(encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def collect_recent_prompts(jsonl_path: Path, limit: int) -> list[tuple[int, str]]:
    """Returns (line_index, text) newest last — we take the last `limit` human prompts."""
    found: list[tuple[int, str]] = []
    for i, obj in enumerate(iter_messages(jsonl_path)):
        text = extract_human_prompt(obj)
        if text:
            found.append((i, text))
    return found[-limit:]


def discover_by_agent_id(agent_id: str) -> Optional[Path]:
    home = Path.home()
    hits: list[tuple[float, Path]] = []
    for base in (home / ".claude/projects", home / ".cursor/projects"):
        if not base.is_dir():
            continue
        for p in base.rglob(f"{agent_id}.jsonl"):
            try:
                hits.append((p.stat().st_mtime, p.resolve()))
            except OSError:
                continue
    if not hits:
        return None
    return max(hits, key=lambda x: x[0])[1]


def discover_by_cwd(cwd: str) -> Optional[Path]:
    """Pick the newest top-level Claude session JSONL whose early content mentions cwd."""
    base = Path.home() / ".claude/projects"
    if not base.is_dir():
        return None
    candidates: list[tuple[float, Path]] = []
    for p in base.rglob("*.jsonl"):
        if "/subagents/" in str(p):
            continue
        try:
            with p.open(encoding="utf-8", errors="replace") as f:
                head = f.read(262_144)
            if cwd not in head:
                continue
            candidates.append((p.stat().st_mtime, p.resolve()))
        except OSError:
            continue
    if not candidates:
        return None
    return max(candidates, key=lambda x: x[0])[1]


def discover_latest_transcript() -> Optional[Path]:
    """
    Pick the transcript `.jsonl` with the newest `st_mtime` under local Claude Code and
    Cursor project trees. Mirrors "most recently written to" session = active thread heuristic.
    """
    home = Path.home()
    candidates: list[tuple[float, Path]] = []
    for base in (home / ".cursor/projects", home / ".claude/projects"):
        if not base.is_dir():
            continue
        for p in base.rglob("*.jsonl"):
            try:
                candidates.append((p.stat().st_mtime, p.resolve()))
            except OSError:
                continue
    if not candidates:
        return None
    return max(candidates, key=lambda x: x[0])[1]


def pick_latest_transcript_logged() -> Optional[Path]:
    path = discover_latest_transcript()
    if path is not None:
        print(f"(using newest transcript by mtime: {path})", file=sys.stderr)
    return path


def format_section(
    jsonl_path: Path, items: list[tuple[int, str]], limit: int
) -> str:
    lines = [
        "",
        "### Recent user messages (local transcript)",
        "",
        f"_Source: `{jsonl_path}` — last **{len(items)}** human prompt(s), max {limit}._",
        "",
    ]
    for n, (_, text) in enumerate(items, start=1):
        lines.append(f"{n}. {text}")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    default_limit = int(os.environ.get("CONTINUE_LATER_LIMIT", "12"))
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--agent",
        "-a",
        metavar="ID",
        help="Session/agent id (Claude Code session UUID, subagent stem, or Cursor agent id). Matches `**/<ID>.jsonl` under ~/.claude/projects and ~/.cursor/projects.",
    )
    ap.add_argument(
        "--jsonl",
        "-j",
        metavar="PATH",
        type=Path,
        help="Explicit transcript .jsonl path (skips discovery).",
    )
    ap.add_argument(
        "--limit",
        "-n",
        type=int,
        default=default_limit,
        help=f"Max number of recent human user prompts (default {default_limit}, env CONTINUE_LATER_LIMIT).",
    )
    ap.add_argument(
        "--from-cwd",
        action="store_true",
        help="Prefer the newest Claude session under ~/.claude/projects whose first 256 KiB mention --cwd; if none match, fall back to --latest.",
    )
    ap.add_argument(
        "--cwd",
        metavar="PATH",
        type=Path,
        help="Working tree for --from-cwd (default: git root or current directory).",
    )
    ap.add_argument(
        "--skip-latest",
        action="store_true",
        help="Do not append a transcript section (git-only; for automation).",
    )
    args = ap.parse_args()

    if args.skip_latest or os.environ.get("CONTINUE_LATER_SKIP_TRANSCRIPT") == "1":
        return 0

    jsonl: Optional[Path] = None
    if args.jsonl:
        jsonl = args.jsonl.expanduser().resolve()
        if not jsonl.is_file():
            print(f"error: --jsonl not a file: {jsonl}", file=sys.stderr)
            return 1
    elif args.agent:
        jsonl = discover_by_agent_id(args.agent.strip())
        if jsonl is None:
            print(
                f"error: no transcript `**/{args.agent}.jsonl` under ~/.claude/projects or ~/.cursor/projects",
                file=sys.stderr,
            )
            return 1
    elif args.from_cwd or os.environ.get("CONTINUE_LATER_FROM_CWD") == "1":
        cwd = args.cwd.resolve() if args.cwd else Path.cwd()
        jsonl = discover_by_cwd(str(cwd))
        if jsonl is None:
            print(
                "(no Claude Code transcript matched cwd — trying newest transcript by mtime)",
                file=sys.stderr,
            )
            jsonl = pick_latest_transcript_logged()
    else:
        jsonl = pick_latest_transcript_logged()

    if jsonl is None:
        print(
            "(no local Claude/Cursor *.jsonl transcripts found — skipping conversation section)",
            file=sys.stderr,
        )
        return 0

    limit = max(1, args.limit)
    prompts = collect_recent_prompts(jsonl, limit)
    if not prompts:
        print(f"(no parseable user prompts in {jsonl})", file=sys.stderr)
        return 0
    sys.stdout.write(format_section(jsonl, prompts, limit))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
