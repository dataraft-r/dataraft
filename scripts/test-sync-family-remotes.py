"""Run with python scripts/test-sync-family-remotes.py (standard library only)."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("sync", Path(__file__).with_name("sync-family-remotes.py"))
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)


class FamilyRemotesTest(unittest.TestCase):
    def setUp(self):
        self.lock = {"schema_version": 1, "packages": {
            "dataraft": {"repository": "dataraft-r/dataraft", "ref": "self", "version": "0.1.0.9000"},
            "dataraft.core": {"repository": "dataraft-r/dataraft.core", "ref": "a" * 40, "version": "0.1.0.9002"},
        }}
        self.description = (
            "Package: dataraft\nVersion: 0.1.0.9000\n"
            "Imports: dataraft.core (>= 0.1.0.9000), cli\n"
            "Remotes: dataraft-r/dataraft.core@old,\n    owner/external@keep\n"
        )

    def test_update_is_idempotent_and_preserves_non_family_fields(self):
        packages = sync.validate_lock(self.lock)
        result = sync.synchronize(self.description, packages)
        self.assertIn("dataraft.core (>= 0.1.0.9002)", result)
        self.assertIn("dataraft-r/dataraft.core@" + "a" * 40, result)
        self.assertIn("owner/external@keep", result)
        self.assertIn("Version: 0.1.0.9000", result)
        self.assertEqual(sync.synchronize(result, packages), result)

    def test_rejects_moving_refs_and_circular_self(self):
        self.lock["packages"]["dataraft.core"]["ref"] = "main"
        with self.assertRaises(ValueError):
            sync.validate_lock(self.lock)
        with self.assertRaisesRegex(ValueError, "umbrella"):
            sync.synchronize("Package: dataraft.core\nRemotes: dataraft-r/dataraft@old\n",
                             self.lock["packages"])

    def test_rejects_unknown_family_and_nonminimum_constraints(self):
        packages = sync.validate_lock(self.lock)
        for text in (
            "Package: dataraft\nRemotes: dataraft-r/dataraft.unknown@abc\n",
            "Package: dataraft\nImports: dataraft.core (< 2.0)\n",
            "Package: dataraft\nRemotes: dataraft-r/dataraft.core/subdir@abc\n",
        ):
            with self.assertRaises(ValueError):
                sync.synchronize(text, packages)

    def test_check_and_multi_file_validation_do_not_write(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            lock = root / "lock.json"
            lock.write_text(json.dumps(self.lock))
            repo = root / "repo"
            repo.mkdir()
            target = repo / "DESCRIPTION"
            target.write_text(self.description)
            self.assertEqual(sync.main([str(repo), "--lock", str(lock), "--check"]), 1)
            self.assertEqual(target.read_text(), self.description)
            self.assertEqual(sync.main([str(repo), str(root / "missing"), "--lock", str(lock)]), 2)
            self.assertEqual(target.read_text(), self.description)
            self.assertEqual(sync.main([str(repo), "--lock", str(lock)]), 0)
            self.assertEqual(sync.main([str(repo), "--lock", str(lock), "--check"]), 0)


if __name__ == "__main__":
    unittest.main()
