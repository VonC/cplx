"""Exercise lifecycle integrity branches and repeatable operation states."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
import zipfile

from .test_venv_lifecycle_tdd import HELPERS, lifecycle


class InterpreterStateMatrixTest(unittest.TestCase):
    """Check venv entry points without following their base-interpreter symlink."""

    def setUp(self):
        self.module = lifecycle()
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.base = self.root / "tools/python/python-3.13.15"
        self.python = self.base / "bin/python3"
        self.python.parent.mkdir(parents=True)
        self.python.write_bytes(b"base")
        self.target = self.root / "application/venvs/python_3.13.15_fixture"
        (self.target / "bin").mkdir(parents=True)
        (self.target / "lib/site-packages").mkdir(parents=True)
        if os.name == "nt":
            self.skipTest("venv interpreter symlinks require native Linux")
        (self.target / "bin/python").symlink_to(self.python)
        (self.target / "pyvenv.cfg").write_text(
            "home = " + str(self.python.parent) + "\nexecutable = " + str(self.python) + "\n",
            encoding="utf-8")
        self.script = self.target / "bin/fixture-cli"
        self.script.write_text("#!" + str(self.target / "bin/python") + "\n", encoding="utf-8")
        self.state = {"prefix": str(self.target), "base_prefix": str(self.base),
                      "base_executable": str(self.python), "version": "3.13.15",
                      "stdlib": str(self.base / "lib/python3.13"),
                      "site": str(self.target / "lib/site-packages")}
        self.record = {"directory": str(self.root), "commands": []}

    def inspect(self, label="state-before"):
        with patch.object(self.module, "run", return_value=json.dumps(self.state)) as runner:
            site = self.module.interpreter_state(self.python, self.target, "3.13.15",
                                                 {}, self.record, label)
        self.assertEqual(runner.call_args.kwargs["label"], label)
        return site

    def test_console_script_symlinks_to_shipped_base_and_passes(self):
        self.assertEqual(self.inspect(), self.target / "lib/site-packages")

    def test_console_script_may_name_a_matching_python_link(self):
        (self.target / "bin/python3").symlink_to(self.target / "bin/python")
        self.script.write_text("#!" + str(self.target / "bin/python3") + "\n", encoding="utf-8")
        self.assertEqual(self.inspect(), self.target / "lib/site-packages")

    def test_foreign_python_link_fails(self):
        foreign = self.root / "foreign/python3"
        foreign.parent.mkdir()
        foreign.write_bytes(b"foreign")
        (self.target / "bin/python3").symlink_to(foreign)
        with self.assertRaisesRegex(ValueError, "foreign Python interpreter link"):
            self.inspect()

    def test_foreign_shebang_fails(self):
        self.script.write_text("#!/usr/bin/python3\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "foreign Python shebang"):
            self.inspect()

    def test_foreign_configuration_home_fails(self):
        (self.target / "pyvenv.cfg").write_text("home = /usr/bin\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "foreign Python"):
            self.inspect()

    def test_stdlib_outside_base_fails(self):
        self.state["stdlib"] = "/usr/lib/python3.13"
        with self.assertRaisesRegex(ValueError, "stdlib lies outside"):
            self.inspect()

    def test_changed_toolchain_at_equal_version_fails(self):
        self.state["base_executable"] = str(self.root / "other/python3")
        with self.assertRaisesRegex(ValueError, "foreign base executable"):
            self.inspect()


class PreflightMatrixTest(unittest.TestCase):
    """Reject unbound, drifted and ambiguous shipped-Python inputs."""

    def setUp(self):
        self.module = lifecycle()
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.release = self.root / "release"
        (self.release / "metadata").mkdir(parents=True)
        (self.release / "metadata/pyproject.toml").write_text("[project]\nname='fixture'\nversion='1'\n", encoding="utf-8")
        self.manifest_path = self.release / "manifest.json"
        self.manifest_path.touch()
        self.profile = self.release / "profiles/target.json"
        self.selection_path = self.release / "profiles/selection.json"
        self.profile.parent.mkdir()
        self.profile.touch()
        self.selection_path.touch()
        self.app = self.root / "application"
        self.app.mkdir()
        self.tools = self.root / "tools"
        self.version_dir = self.tools / "python/python-3.13.15"
        (self.version_dir / "bin").mkdir(parents=True)
        self.current = self.tools / "python/current"
        if os.name == "nt":
            self.skipTest("toolchain current symlink requires native Linux")
        self.current.symlink_to(self.version_dir, target_is_directory=True)
        self.python = self.version_dir / "bin/python3.13_bin"
        self.python.write_bytes(b"python")
        self.python.chmod(0o755)
        self.uv = self.release / "uv"
        self.uv.write_bytes(b"uv")
        self.uv.chmod(0o755)
        self.manifest = {"profiles": [{"path": "profiles/target.json"},
                                      {"path": "profiles/selection.json"}],
                         "metadata": [], "tools": {"sha256": "digest", "python": "3.13.15",
                                                   "path": "tools.tar.gz"},
                         "uv": {"path": "uv", "version": "0.12.17"},
                         "application": {"revision": "revision"}}
        self.target_profile = {"os": "linux", "arch": platform.machine(),
                               "groups": [], "extras": []}
        self.selection = {"toolchain_sha256": "digest", "source_revision": "revision",
                          "groups": [], "extras": []}
        self.args = argparse.Namespace(manifest=self.manifest_path, application_root=self.app,
                                       serialization_attestation=self.root / "lock.json",
                                       profile=self.profile, selection_profile=self.selection_path,
                                       tools_prefix=self.tools, project="fixture")

    def preflight(self, running_python=None):
        def load_profile(path):
            return self.target_profile if path == self.profile else self.selection
        with patch.object(self.module, "verify"), patch.object(self.module, "require_serialization"), \
             patch.object(self.module, "load", side_effect=load_profile), \
             patch.object(self.module, "effective_groups"), \
             patch.object(self.module, "sha256", return_value="digest"), \
             patch.object(self.module, "run", return_value="uv 0.12.17"), \
             patch.object(self.module, "check_uv_version"), \
             patch.object(self.module.sys, "executable", str(running_python or self.python)), \
             patch.object(self.module.platform, "python_version", return_value="3.13.15"):
            return self.module.preflight(self.args, self.manifest)

    def test_selected_shipped_python_passes(self):
        self.assertEqual(self.preflight()[1], self.python)

    def test_zero_or_several_python_candidates_fail(self):
        for count in (0, 2):
            with self.subTest(count=count):
                if count == 0:
                    self.python.unlink()
                else:
                    self.python.write_bytes(b"python")
                    self.python.chmod(0o755)
                    extra = self.version_dir / "bin/python3.13_extra_bin"
                    extra.write_bytes(b"python")
                    extra.chmod(0o755)
                with self.assertRaisesRegex(ValueError, "one selected shipped Python"):
                    self.preflight()
                if count == 2:
                    extra.unlink()

    def test_toolchain_directory_version_mismatch_fails(self):
        self.current.unlink()
        wrong = self.tools / "python/python-3.13.14"
        wrong.mkdir()
        self.current.symlink_to(wrong, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, "directory version differs"):
            self.preflight()

    def test_running_interpreter_differs_fails(self):
        with self.assertRaisesRegex(ValueError, "running Python"):
            self.preflight(Path("/usr/bin/python3"))

    def test_unbound_profile_and_metadata_drift_fail(self):
        self.manifest["profiles"] = [{"path": "profiles/selection.json"}]
        with self.assertRaisesRegex(ValueError, "target profile is not bound"):
            self.preflight()
        self.manifest["profiles"].append({"path": "profiles/target.json"})
        self.manifest["metadata"] = [{"path": "metadata/pyproject.toml", "sha256": "other"}]
        (self.app / "pyproject.toml").write_text("drift", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "application metadata differs"):
            self.preflight()


class OperationMatrixTest(unittest.TestCase):
    """Keep readiness false for input, sync and final-check failures."""

    def setUp(self):
        self.module = lifecycle()
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.app = self.root / "application"
        self.app.mkdir()
        self.target = self.app / "venvs/python_3.13.15_fixture"
        self.release = self.root / "release"
        self.release.mkdir()
        self.metadata = self.root / "metadata"
        self.metadata.mkdir()
        self.manifest = {"tools": {"sha256": "digest", "python": "3.13.15"}}
        self.selection = {"no_default_groups": False, "excluded_groups": [],
                          "requested_groups": [], "extras": []}
        self.args = argparse.Namespace(evidence_root=self.root / "evidence",
                                       manifest=self.release / "manifest.json",
                                       serialization_attestation=self.root / "lock.json",
                                       application_root=self.app, profile=self.root / "profile.json",
                                       selection_profile=self.root / "selection.json")
        self.args.evidence_root.mkdir()

    def invoke(self, failure=None, create=True):
        def command(argv, **kwargs):
            label = kwargs.get("label")
            if label == "create-venv" and create:
                self.target.mkdir(parents=True)
            if failure == "interrupted sync" and label == "locked-sync":
                raise KeyboardInterrupt("interrupted")
            if failure == "sync" and label == "locked-sync":
                raise ValueError("command failed: locked-sync (exit 9)")
            return ""
        def source(*_):
            if failure == "missing wheel":
                raise ValueError("missing wheel")
            return self.metadata, {}
        def checks(*arguments):
            if failure == "post-sync":
                raise ValueError("post-sync check failed")
            if failure == "corrupt wheel":
                raise zipfile.BadZipFile("corrupt wheel")
            arguments[-1]["venv"] = str(self.target)
            return {}
        def locked(*_):
            if failure == "stale lock":
                raise ValueError("stale lock")
            return self.release, self.root / "tools/python", self.target, self.root / "uv", self.selection
        with patch.object(self.module, "load", return_value=self.manifest), \
             patch.object(self.module, "sha256", return_value="digest"), \
             patch.object(self.module, "require_serialization"), \
             patch.object(self.module, "preflight", side_effect=locked), \
             patch.object(self.module, "prepare_sources", side_effect=source), \
             patch.object(self.module, "run", side_effect=command), \
             patch.object(self.module, "interpreter_state", return_value=self.target / "site"), \
             patch.object(self.module, "check_workspace"), \
             patch.object(self.module, "verify"), \
             patch.object(self.module, "finish_checks", side_effect=checks):
            return self.module.operate(self.args)

    def latest_result(self):
        results = sorted(self.args.evidence_root.glob("operation-*/result.json"),
                         key=lambda path: path.stat().st_mtime_ns)
        return json.loads(results[-1].read_text(encoding="utf-8"))

    def test_stale_lock_missing_wheel_sync_and_post_sync_fail_closed(self):
        for reason, expected in (("stale lock", "stale lock"),
                                 ("missing wheel", "missing wheel"),
                                 ("sync", "locked-sync"),
                                 ("post-sync", "post-sync"),
                                 ("corrupt wheel", "corrupt wheel")):
            with self.subTest(reason=reason):
                self.assertEqual(self.invoke(reason), 5)
                result = self.latest_result()
                self.assertIn(expected, result["error"])
                readiness = json.loads((self.args.evidence_root / "readiness.json").read_text())
                self.assertEqual(readiness["operation"], result["operation"])
                self.assertEqual(readiness["state"], "not-ready")

    def test_interrupted_sync_retains_operation_and_not_ready(self):
        with self.assertRaises(KeyboardInterrupt):
            self.invoke("interrupted sync")
        result = self.latest_result()
        self.assertEqual(result["state"], "not-ready")
        self.assertEqual(json.loads((self.args.evidence_root / "readiness.json").read_text())
                         ["operation"], result["operation"])

    def test_repeated_and_mirror_removed_target_recreate_exact_path(self):
        self.assertEqual(self.invoke(), 0)
        first = self.latest_result()
        self.assertEqual(self.invoke(), 0)
        second = self.latest_result()
        self.assertNotEqual(first["operation"], second["operation"])
        self.assertEqual(second["venv"], str(self.target))
        shutil.rmtree(self.target)
        self.assertEqual(self.invoke(), 0)
        third = self.latest_result()
        self.assertEqual(third["venv"], str(self.target))
        self.assertTrue(self.target.is_dir())

    def test_venv_parent_escape_fails_closed(self):
        if os.name == "nt":
            self.skipTest("parent symlink requires native Linux")
        outside = self.root / "outside"
        outside.mkdir()
        (self.app / "venvs").symlink_to(outside, target_is_directory=True)
        self.assertEqual(self.invoke(), 5)
        self.assertIn("venv parent", self.latest_result()["error"])


class SourceAndFinishMatrixTest(unittest.TestCase):
    """Reach source preparation and installed-inventory checks directly."""

    def setUp(self):
        self.module = lifecycle()
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.release = self.root / "release"
        (self.release / "metadata").mkdir(parents=True)
        (self.release / "metadata/uv.lock").write_text(
            '[[package]]\nname = "fixture-cli"\n[package.source]\n'
            'registry = "https://index.invalid/simple"\n', encoding="utf-8")
        self.owned = self.root / "operation"
        self.owned.mkdir()
        self.wheel = self.release / "wheels/fixture_cli-1-py3-none-any.whl"
        self.wheel.parent.mkdir()
        self.wheel.write_bytes(b"wheel")
        self.manifest = {"transport": {"path": "transport.json"},
                         "wheels": [{"path": "wheels/fixture_cli-1-py3-none-any.whl",
                                     "filename": self.wheel.name}],
                         "tools": {"python": "3.13.15"}}

    def test_prepare_sources_uses_file_index_and_workspace(self):
        with patch.object(self.module, "load", return_value={"locations": {
                "https://index.invalid/simple": "file:///offline/simple"}}), \
             patch.object(self.module, "file_index") as index, \
             patch.object(self.module, "workspace", return_value={"registry": "file"}) as workspace:
            metadata, mapping = self.module.prepare_sources(self.manifest, self.release, self.owned)
        self.assertEqual(metadata, self.owned / "metadata")
        self.assertEqual(mapping, {"registry": "file"})
        self.assertEqual(index.call_args.args[2], {"file:///offline/simple"})
        self.assertEqual(workspace.call_args.args[2], metadata)

    def test_prepare_sources_records_missing_wheel_error(self):
        with patch.object(self.module, "load", return_value={"locations": {
                "https://index.invalid/simple": "file:///offline/simple"}}), \
             patch.object(self.module, "file_index", side_effect=ValueError("missing wheel")):
            with self.assertRaisesRegex(ValueError, "missing wheel"):
                self.module.prepare_sources(self.manifest, self.release, self.owned)

    def test_finish_checks_binds_inventory_and_exact_site(self):
        target = self.root / "application/venvs/python_3.13.15_fixture"
        target.mkdir(parents=True)
        site = target / "lib/site-packages"
        site.mkdir(parents=True)
        args = argparse.Namespace(selection_profile=self.root / "selection.json",
                                  manifest=self.release / "manifest.json",
                                  profile=self.root / "profile.json")
        record = {"directory": str(self.owned), "commands": []}
        import tools_wheel_inventory
        def capture(inventory_args):
            self.assertEqual(inventory_args.installed_root, site)
            inventory_args.output.write_text("{}", encoding="utf-8")
        with patch.object(self.module, "interpreter_state", return_value=site), \
             patch.object(tools_wheel_inventory, "capture", side_effect=capture), \
             patch.object(self.module, "verify_selection", return_value={"distributions": 1}), \
             patch.object(self.module, "sha256", return_value="digest"):
            result = self.module.finish_checks(args, self.manifest, self.release, target,
                                               self.root / "python", {}, self.owned, record)
        self.assertEqual(result["distributions"], 1)
        self.assertEqual(record["venv"], str(target))
        self.assertEqual(record["inventory_sha256"], "digest")
        self.assertTrue((self.owned / "selected-wheels" / self.wheel.name).is_file())


class BashPythonSelectionTest(unittest.TestCase):
    """Run the entry boundary with missing, ambiguous and sole shipped Python."""

    def test_shipped_python_selection(self):
        if os.name == "nt":
            self.skipTest("native Linux Bash entry")
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            tools = root / "tools"
            binaries = tools / "python/current/bin"
            binaries.mkdir(parents=True)
            helper = root / "helper"
            helper.touch()
            runtime = root / "runtime.sh"
            runtime.write_text('pdfss_runtime_run() { printf "%s\\n" "$1" > "$DVS_CAPTURE"; }\n',
                               encoding="utf-8")
            capture = root / "selected"
            entry = HELPERS / "deploy_venv.sh"
            argv = ["bash", str(entry), "--tools-prefix", str(tools), "--helper", str(helper),
                    "--runtime-setup", str(runtime), "--evidence-root", str(root / "evidence")]
            env = {**os.environ, "DVS_CAPTURE": str(capture)}
            empty = subprocess.run(argv, env=env, capture_output=True, text=True, check=False)
            self.assertNotEqual(empty.returncode, 0)
            self.assertIn("Python missing", empty.stderr)
            one = binaries / "python3.13_bin"
            one.symlink_to(Path(sys.executable))
            valid = subprocess.run(argv, env=env, capture_output=True, text=True, check=False)
            self.assertEqual(valid.returncode, 0, valid.stderr)
            self.assertEqual(capture.read_text(encoding="utf-8").strip(),
                             str(Path(sys.executable).resolve()))
            (binaries / "python3.14_bin").symlink_to(Path(sys.executable))
            ambiguous = subprocess.run(argv, env=env, capture_output=True, text=True, check=False)
            self.assertNotEqual(ambiguous.returncode, 0)
            self.assertIn("Ambiguous shipped Python", ambiguous.stderr)

    def test_runtime_failure_invalidates_earlier_ready_record(self):
        if os.name == "nt":
            self.skipTest("native Linux Bash entry")
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            tools = root / "tools"
            binaries = tools / "python/current/bin"
            binaries.mkdir(parents=True)
            (binaries / "python3.13_bin").symlink_to(Path(sys.executable))
            helper = root / "helper"
            helper.touch()
            runtime = root / "runtime.sh"
            runtime.write_text("pdfss_runtime_run() { return 2; }\n", encoding="utf-8")
            evidence = root / "evidence"
            evidence.mkdir()
            (evidence / "readiness.json").write_text('{"state":"ready"}\n', encoding="utf-8")
            result = subprocess.run(["bash", str(HELPERS / "deploy_venv.sh"),
                                     "--tools-prefix", str(tools), "--helper", str(helper),
                                     "--runtime-setup", str(runtime),
                                     "--evidence-root", str(evidence)],
                                    capture_output=True, text=True, check=False)
            self.assertEqual(result.returncode, 2)
            readiness = json.loads((evidence / "readiness.json").read_text(encoding="utf-8"))
            self.assertEqual(readiness["state"], "not-ready")


if __name__ == "__main__":
    unittest.main()
