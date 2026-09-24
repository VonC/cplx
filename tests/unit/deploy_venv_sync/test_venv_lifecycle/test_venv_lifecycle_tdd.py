"""Reject foreign environments and selection drift before release readiness."""

from __future__ import annotations

import json
from pathlib import Path
import sys
import tempfile
import types
import unittest
from unittest.mock import patch
import os
import argparse

HELPERS = Path(__file__).resolve().parents[4] / "src/setups/env/bin"
sys.path.insert(0, str(HELPERS))


def lifecycle():
    source = (HELPERS / "deploy_venv.sh").read_text(encoding="utf-8")
    body = source.split("<<'PYTHON_LIFECYCLE'\n", 1)[1].split("\nPYTHON_LIFECYCLE", 1)[0]
    module = types.ModuleType("deploy_venv_lifecycle")
    with patch.dict(os.environ, {"DVS_HELPER_ROOT": str(HELPERS)}):
        exec(compile(body, str(HELPERS / "deploy_venv.sh"), "exec"), module.__dict__)
    return module


class VenvLifecycleTest(unittest.TestCase):
    """Cover exact target selection, foreign-base rejection and failure evidence."""

    def setUp(self):
        self.lifecycle = lifecycle()
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def test_exact_path_uses_full_version_and_ignores_other_versions(self):
        app = self.root / "application"
        (app / "venvs/python_3.13.14_fixture").mkdir(parents=True)
        target = self.lifecycle.exact_path(app, "fixture", "3.13.15")
        self.assertEqual(target, app / "venvs/python_3.13.15_fixture")

    def test_project_suffix_cannot_escape_target_root(self):
        for suffix in ("../escape", "other/name", "", "bad space"):
            with self.subTest(suffix=suffix), self.assertRaisesRegex(ValueError, "project suffix"):
                self.lifecycle.exact_path(self.root, suffix, "3.13.15")

    def test_existing_target_rejects_symlink_and_foreign_base(self):
        target = self.root / "venvs/python_3.13.15_fixture"
        target.parent.mkdir()
        try:
            target.symlink_to(self.root, target_is_directory=True)
        except OSError:
            pass  # Windows may deny unprivileged symlink creation.
        else:
            with self.assertRaisesRegex(ValueError, "symlink"):
                self.lifecycle.require_target_directory(target)
            target.unlink()
        target.mkdir()
        base = self.root / "tools/python/python_3.13.15/bin/python3"
        state = {"prefix": str(target), "base_executable": str(self.root / "host/python3"),
                 "version": "3.13.15", "base_prefix": str(self.root / "tools/python/python_3.13.15")}
        with self.assertRaisesRegex(ValueError, "foreign base"):
            self.lifecycle.assert_venv_state(state, target, base, "3.13.15")

    def test_selection_flags_preserve_default_and_explicit_groups(self):
        profile = {"no_default_groups": False, "requested_groups": ["service"],
                   "excluded_groups": ["tooling"], "groups": ["dev", "service"],
                   "extras": ["image"]}
        flags = self.lifecycle.selection_flags(profile)
        self.assertEqual(flags, ["--no-group", "tooling", "--group", "service",
                                 "--extra", "image"])
        profile["no_default_groups"] = True
        self.assertEqual(self.lifecycle.selection_flags(profile)[0], "--no-default-groups")

    def test_sanitized_sync_environment_overrides_ambient_selection(self):
        ambient = {"PATH": "/host/bin", "UV_INDEX_URL": "https://wrong.invalid",
                   "UV_PYTHON": "/host/python", "VIRTUAL_ENV": "/foreign",
                   "PIP_INDEX_URL": "https://wrong.invalid", "PYTHONPATH": "/host/modules",
                   "LD_LIBRARY_PATH": "/shipped/lib", "PDFSS_RUNTIME_HOST_LIB_PATH": "/host/lib"}
        env = self.lifecycle.sync_environment(ambient, Path("/tools/python"), Path("/app/venv"),
                                              Path("/cache"))
        self.assertEqual(env["UV_PYTHON"], str(Path("/tools/python")))
        self.assertEqual(env["UV_PROJECT_ENVIRONMENT"], str(Path("/app/venv")))
        self.assertEqual(env["UV_PYTHON_DOWNLOADS"], "never")
        self.assertEqual(env["UV_OFFLINE"], "true")
        self.assertEqual(env["LD_LIBRARY_PATH"], "/shipped/lib")
        self.assertNotIn("UV_INDEX_URL", env)
        self.assertNotIn("VIRTUAL_ENV", env)
        self.assertNotIn("PIP_INDEX_URL", env)
        self.assertNotIn("PYTHONPATH", env)

    def test_foreign_activation_does_not_supply_commands_or_proxy(self):
        foreign = self.root / "foreign"
        host = self.root / "host"
        ambient = {"PATH": os.pathsep.join((str(foreign / "bin"), str(host / "bin"))),
                   "VIRTUAL_ENV": str(foreign), "CONDA_PREFIX": str(foreign),
                   "http_proxy": "http://wrong.invalid"}
        env = self.lifecycle.sync_environment(ambient, Path("/tools/bin/python3"),
                                              Path("/app/venv"), Path("/cache"))
        self.assertNotIn(str(foreign / "bin"), env["PATH"])
        self.assertIn(str(host / "bin"), env["PATH"])
        self.assertNotIn("CONDA_PREFIX", env)
        self.assertNotIn("http_proxy", env)

    def test_existing_target_rejects_wrong_prefix_and_version(self):
        target = self.root / "venvs/python_3.13.15_fixture"
        base = self.root / "tools/python/python-3.13.15/bin/python3"
        state = {"prefix": str(target), "base_executable": str(base),
                 "base_prefix": str(base.parents[2]), "version": "3.13.15"}
        for key, value, message in (("prefix", str(self.root / "other"), "prefix"),
                                    ("version", "3.13.14", "version")):
            with self.subTest(key=key), self.assertRaisesRegex(ValueError, message):
                self.lifecycle.assert_venv_state({**state, key: value}, target, base, "3.13.15")

    def test_command_failure_retains_exit_and_log(self):
        directory = self.root / "operation"
        directory.mkdir()
        record = {"directory": str(directory), "commands": []}
        with self.assertRaisesRegex(ValueError, "exit 23"):
            self.lifecycle.run([sys.executable, "-c", "print('first failure'); raise SystemExit(23)"],
                               record=record, label="sync")
        self.assertEqual(record["commands"][0]["returncode"], 23)
        self.assertIn("first failure", (directory / "sync.log").read_text(encoding="utf-8"))

    def test_failure_cannot_leave_prior_readiness(self):
        evidence = self.root / "evidence"
        evidence.mkdir()
        ready = evidence / "readiness.json"
        ready.write_text(json.dumps({"state": "ready"}), encoding="utf-8")
        self.lifecycle.invalidate_readiness(ready, "operation-1")
        self.assertEqual(json.loads(ready.read_text(encoding="utf-8")),
                         {"schema": 1, "operation": "operation-1", "state": "not-ready"})

    def test_invalid_manifest_still_revokes_prior_readiness(self):
        evidence = self.root / "evidence"
        evidence.mkdir()
        (evidence / "readiness.json").write_text('{"state":"ready"}', encoding="utf-8")
        args = argparse.Namespace(evidence_root=evidence, manifest=self.root / "missing.json",
                                  serialization_attestation=self.root / "missing-attestation.json",
                                  application_root=self.root)
        self.assertEqual(self.lifecycle.operate(args), 5)
        readiness = json.loads((evidence / "readiness.json").read_text(encoding="utf-8"))
        self.assertEqual(readiness["state"], "not-ready")
        results = list(evidence.glob("operation-*/result.json"))
        self.assertEqual(len(results), 1)
        self.assertIn("error", json.loads(results[0].read_text(encoding="utf-8")))

    def test_serialization_attestation_rejects_unheld_and_external_locks(self):
        if os.name == "nt":
            self.skipTest("fcntl is native Linux only")
        app = self.root / "pdfs" / "application"
        app.mkdir(parents=True)
        lock = app / ".deployment.lock"
        lock.touch()
        attestation = self.root / "attestation.json"
        def write_lock(path):
            attestation.write_text(json.dumps({"schema": 1, "application_root": str(app),
                                               "lock_path": str(path)}), encoding="utf-8")
        write_lock(lock)
        with self.assertRaisesRegex(ValueError, "not held"):
            self.lifecycle.require_serialization(attestation, app)
        import fcntl
        with lock.open("wb") as stream:
            fcntl.flock(stream, fcntl.LOCK_EX)
            self.assertEqual(self.lifecycle.require_serialization(attestation, app), str(lock))
        stable_lock = self.root / ".deploy-venv.lock"
        stable_lock.touch()
        write_lock(stable_lock)
        with stable_lock.open("wb") as stream:
            fcntl.flock(stream, fcntl.LOCK_EX)
            self.assertEqual(self.lifecycle.require_serialization(attestation, app), str(stable_lock))
        other = tempfile.TemporaryDirectory()
        self.addCleanup(other.cleanup)
        outside = Path(other.name) / "outside.lock"
        outside.touch()
        write_lock(outside)
        with self.assertRaisesRegex(ValueError, "lock file missing"):
            self.lifecycle.require_serialization(attestation, app)


if __name__ == "__main__":
    unittest.main()
