import json
import importlib.util
import tempfile
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "scripts" / "session_recent_user_messages.py"
SPEC = importlib.util.spec_from_file_location("session_recent_user_messages", MODULE_PATH)
assert SPEC is not None
session_recent_user_messages = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(session_recent_user_messages)

collect_recent_prompts = session_recent_user_messages.collect_recent_prompts
extract_human_prompt = session_recent_user_messages.extract_human_prompt
format_section = session_recent_user_messages.format_section


class SessionRecentUserMessagesTests(unittest.TestCase):
    def test_extracts_claude_string_prompt(self):
        obj = {
            "type": "user",
            "message": {"role": "user", "content": "continue later"},
        }

        self.assertEqual(extract_human_prompt(obj), "continue later")

    def test_extracts_cursor_user_query(self):
        obj = {
            "role": "user",
            "message": {
                "content": [
                    {
                        "type": "text",
                        "text": "<user_query>resume from earlier</user_query>",
                    }
                ]
            },
        }

        self.assertEqual(extract_human_prompt(obj), "resume from earlier")

    def test_collect_recent_prompts_skips_injected_messages(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "session.jsonl"
            rows = [
                {
                    "type": "user",
                    "message": {
                        "role": "user",
                        "content": "<system-reminder>ignore me</system-reminder>",
                    },
                },
                {
                    "type": "user",
                    "message": {"role": "user", "content": "first real prompt"},
                },
                {"bad json": object()},
                {
                    "role": "user",
                    "message": {
                        "content": [
                            {"type": "text", "text": "second real prompt"},
                        ]
                    },
                },
            ]
            with path.open("w", encoding="utf-8") as f:
                for row in rows[:2]:
                    f.write(json.dumps(row) + "\n")
                f.write("{not-json}\n")
                f.write(json.dumps(rows[3]) + "\n")

            self.assertEqual(
                collect_recent_prompts(path, 10),
                [(1, "first real prompt"), (2, "second real prompt")],
            )

    def test_format_section_includes_source_and_items(self):
        section = format_section(Path("/tmp/session.jsonl"), [(4, "hello")], 3)

        self.assertIn("Recent user messages", section)
        self.assertIn("/tmp/session.jsonl", section)
        self.assertIn("1. hello", section)


if __name__ == "__main__":
    unittest.main()
