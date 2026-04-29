from pathlib import Path
import unittest


class SkillFrontmatterTests(unittest.TestCase):
    def test_all_skills_have_yaml_frontmatter_delimiters(self):
        root = Path(__file__).resolve().parents[1]
        skill_files = sorted((root / "skills").glob("*/SKILL.md"))

        self.assertGreater(len(skill_files), 0)

        for path in skill_files:
            with self.subTest(path=path):
                lines = path.read_text(encoding="utf-8").splitlines()
                self.assertGreaterEqual(len(lines), 4)
                self.assertEqual(lines[0], "---")
                self.assertIn("---", lines[1:])
                end = lines[1:].index("---") + 1
                frontmatter = "\n".join(lines[1:end])
                self.assertIn("name:", frontmatter)
                self.assertIn("description:", frontmatter)


if __name__ == "__main__":
    unittest.main()
