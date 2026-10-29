"""Archive and retained release inputs reject drift before any mutation."""

from __future__ import annotations

import hashlib
import importlib.util
import io
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import tempfile
import unittest
import xml.etree.ElementTree as ET

HELPERS = Path(__file__).resolve().parents[4] / "src/setups/env/bin"


def module(name):
    spec = importlib.util.spec_from_file_location(name, HELPERS / (name + ".py"))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def artifact(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


class ArchiveRecoveryTest(unittest.TestCase):
    """Inspect every supplied packaging root and the resulting tar boundary."""

    def setUp(self):
        self.archive = module("deploy_venv_archive")
        self.release = module("deploy_venv_release")
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.app = self.root / "application"
        self.app.mkdir()
        (self.app / "pyproject.toml").write_text("[project]\nname='example'\n")
        (self.app / "uv.lock").write_text("version=1\n")

    def retain_fixture(self, record_path, files, retention, application_prefix="application"):
        """Model the consumer-owned retained layout for cplx selection tests."""
        row = self.release.preflight(record_path, files)
        identity = self.release.sha256(record_path)
        destination = retention / identity
        destination.mkdir(parents=True)
        for name, filename in self.release.retained_names(row, application_prefix).items():
            shutil.copyfile(files[name], destination / filename)
        shutil.copyfile(record_path, destination / "release-inputs.txt")
        return identity

    def test_discovery_covers_current_stale_nested_alternate_and_alias(self):
        for name in ("venvs/current", "venvs/stale", "data/cache/inner", "other name"):
            boundary = self.app / name
            boundary.mkdir(parents=True)
            (boundary / "pyvenv.cfg").write_text("home = /outside\n")
            (boundary / "payload").write_text("do not ship")
        try:
            (self.app / "alias").symlink_to(self.app / "venvs/current", target_is_directory=True)
            alias = {"alias"}
        except OSError:
            if sys.platform != "win32":
                raise
            alias = set()
        extra = self.root / "extras"
        extra.mkdir()
        (extra / "old env").mkdir()
        (extra / "old env/pyvenv.cfg").touch()
        found = self.archive.discover((self.app, extra))
        self.assertEqual(found[self.app], {"venvs/current", "venvs/stale", "data/cache/inner", "other name"} | alias)
        self.assertEqual(found[extra], {"old env"})

    def test_archive_inspection_rejects_venv_even_with_unusual_name(self):
        candidate = self.root / "app.tar.gz"
        with tarfile.open(candidate, "w:gz") as stream:
            for name, content in (("application/pyproject.toml", b"project"),
                                  ("application/uv.lock", b"lock"),
                                  ("application/other name/pyvenv.cfg", b"home=/outside")):
                info = tarfile.TarInfo(name)
                info.size = len(content)
                stream.addfile(info, io.BytesIO(content))
        with self.assertRaisesRegex(ValueError, "venv"):
            self.archive.inspect(candidate, {"application/pyproject.toml", "application/uv.lock"})

    def test_unsafe_tar_options_refused_before_packaging(self):
        for option in ("--dereference", "-h", "--hard-dereference", "--transform=s,x,y,", "--files-from=x"):
            with self.subTest(option=option), self.assertRaises(ValueError):
                self.archive.validate_tar_rules([option])

    def test_assembly_descriptor_excludes_discovered_boundaries(self):
        venv = self.app / "alternate name"
        venv.mkdir()
        (venv / "pyvenv.cfg").touch()
        template = self.root / "template.xml"
        template.write_text('<assembly xmlns="http://maven.apache.org/ASSEMBLY/2.1.0">'
                            '<fileSets><fileSet><excludes><exclude>*.pdf</exclude>'
                            '</excludes></fileSet></fileSets></assembly>')
        output = self.root / "generated.xml"
        self.archive.descriptor(template, output, self.app)
        ns = {"a": "http://maven.apache.org/ASSEMBLY/2.1.0"}
        values = [item.text for item in ET.parse(output).findall(".//a:exclude", ns)]
        self.assertIn("*.pdf", values)
        self.assertIn("alternate name/**", values)
        self.assertIn("alternate name", values)

    @unittest.skipUnless(sys.platform.startswith("linux"), "canonical pkg.sh fixture needs GNU tar")
    def test_canonical_packager_excludes_all_declared_roots_and_keeps_metadata(self):
        home = self.root / "home"
        app = home / "application"
        app.mkdir(parents=True)
        (app / "pyproject.toml").write_text("[project]\nname='fixture'\n")
        (app / "uv.lock").write_text("version=1\n")
        (home / "senv").write_text("source fixture\n")
        for boundary in (app / "venvs/current", app / "nested/other", home / "extras/old"):
            boundary.mkdir(parents=True)
            (boundary / "pyvenv.cfg").write_text("home=/foreign\n")
        (home / "extras/keep.txt").write_text("keep\n")
        template = self.root / "template.xml"
        template.write_text('<assembly xmlns="http://maven.apache.org/ASSEMBLY/2.1.0">'
                            '<fileSets><fileSet><excludes /></fileSet></fileSets></assembly>')
        generated = self.root / "generated.xml"
        archive = self.archive.package(HELPERS / "pkg.sh", "application", home, home,
                                       ["senv", "extras"], [],
                                       ["application/pyproject.toml", "application/uv.lock", "extras/keep.txt"],
                                       template, generated)
        names = self.archive.inspect(archive)
        self.assertIn("senv", names)
        self.assertFalse(any("pyvenv.cfg" in name for name in names))
        self.assertIn("venvs/current", generated.read_text())

    @unittest.skipUnless(sys.platform.startswith("linux"), "installer selection needs Linux")
    def test_installer_explicit_archive_ignores_newer_and_refuses_aliases(self):
        home = self.root / "home"
        home.mkdir()
        prefix = self.root / "prefix"
        pkgs = prefix / "pkgs"
        pkgs.mkdir(parents=True)
        chosen = self.root / "application.1.tar.gz"
        newer = self.root / "application.2.tar.gz"
        chosen.write_bytes(b"selected")
        newer.write_bytes(b"unrelated")
        os.utime(newer, (chosen.stat().st_mtime + 10,) * 2)
        (pkgs / "application.1.done").touch()
        env = {**os.environ, "HOME": str(home)}

        def run(archive):
            return subprocess.run(
                ["bash", str(HELPERS / "install_pkg.sh"), "application",
                 "--prefix", str(prefix), "--archive", str(archive)],
                env=env, capture_output=True, text=True, check=False)

        selected = run(chosen)
        self.assertEqual(selected.returncode, 0, selected.stdout + selected.stderr)
        self.assertIn("Found: " + str(chosen), selected.stdout + selected.stderr)
        self.assertNotIn("Found: " + str(newer), selected.stdout + selected.stderr)
        alias = self.root / "application.alias.tar.gz"
        alias.symlink_to(chosen)
        mismatch = self.root / "other.1.tar.gz"
        mismatch.write_bytes(b"wrong name")
        for archive in (Path("application.1.tar.gz"), alias, mismatch):
            with self.subTest(archive=archive):
                result = run(archive)
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("Found: ", result.stdout + result.stderr)

    def test_release_record_rejects_missing_or_changed_inputs(self):
        files = {}
        for name in ("entry", "application", "companion", "tools"):
            path = self.root / ("release-" + name)
            path.write_bytes(name.encode())
            files[name] = path
        record = self.release.record({
            "application_version": "2.0", "tools_version": "1.7",
            "tools_coordinate": "tools/1.7/tools.tar", "helpers_revision": "a" * 40,
            "helpers_manifest_sha256": "b" * 64,
        }, files)
        path = self.root / "release-inputs.txt"
        path.write_text(record, newline="\n")
        self.release.preflight(path, files)
        for name in files:
            with self.subTest(name=name):
                files[name].write_bytes(b"changed")
                with self.assertRaises(ValueError):
                    self.release.preflight(path, files)
                files[name].write_bytes(name.encode())
        path.unlink()
        with self.assertRaises((OSError, ValueError)):
            self.release.preflight(path, files)

    def test_release_record_rejects_duplicate_and_invalid_values(self):
        files = {}
        for name in ("entry", "application", "companion", "tools"):
            path = self.root / ("release-" + name)
            path.write_bytes(name.encode())
            files[name] = path
        record = self.release.record({
            "application_version": "2.0", "tools_version": "1.7",
            "tools_coordinate": "tools/1.7/tools.tar", "helpers_revision": "a" * 40,
            "helpers_manifest_sha256": "b" * 64,
        }, files)
        path = self.root / "release-inputs.txt"
        for changed in (record + "tools_version=2.0\n", record.replace("schema=1", "schema=2"),
                        record.replace("tools_coordinate=tools/1.7/tools.tar", "tools_coordinate=../escape")):
            path.write_text(changed, newline="\n")
            with self.assertRaises(ValueError):
                self.release.preflight(path, files)

    def test_retention_requires_readiness_and_preserves_predecessor(self):
        files = {}
        for name in ("entry", "application", "companion", "tools"):
            path = self.root / ("release-" + name)
            path.write_bytes(name.encode())
            files[name] = path
        identity = {"application_version": "2.0", "tools_version": "1.7",
                    "tools_coordinate": "tools/1.7/tools.tar", "helpers_revision": "a" * 40,
                    "helpers_manifest_sha256": "b" * 64}
        record_path = self.root / "release-inputs.txt"
        retention = self.root / "retained"
        record_path.write_text(self.release.record(identity, files), newline="\n")
        first = self.retain_fixture(record_path, files, retention)
        with self.assertRaises(ValueError):
            self.release.promote(retention, first, ready=False)
        self.assertIsNone(self.release.index(retention)["current"])
        self.release.promote(retention, first, ready=True)
        files["application"].write_bytes(b"second")
        identity["application_version"] = "2.1"
        record_path.write_text(self.release.record(identity, files), newline="\n")
        second = self.retain_fixture(record_path, files, retention)
        self.assertEqual(self.release.index(retention)["current"], first)
        self.release.promote(retention, second, ready=True)
        self.assertEqual(self.release.index(retention)["predecessor"], first)
        self.release.selected(retention, first)
        (retention / first / "companion").write_bytes(b"damaged")
        with self.assertRaises(ValueError):
            self.release.index(retention)

    def test_retention_uses_explicit_application_archive_prefix(self):
        files = {}
        for name in ("entry", "application", "companion", "tools"):
            path = self.root / ("release-" + name)
            path.write_bytes(name.encode())
            files[name] = path
        identity = {"application_version": "2.0", "tools_version": "1.7",
                    "tools_coordinate": "tools/1.7/tools.tar", "helpers_revision": "a" * 40,
                    "helpers_manifest_sha256": "b" * 64}
        record_path = self.root / "release-inputs.txt"
        retention = self.root / "retained"
        record_path.write_text(self.release.record(identity, files), newline="\n")
        first = self.retain_fixture(record_path, files, retention, "custom")
        self.assertTrue((retention / first / "custom.2.0.tar.gz").is_file())
        self.release.promote(retention, first, ready=True, application_prefix="custom")
        self.assertEqual(self.release.index(retention, "custom")["current"], first)
        self.release.selected(retention, first, "custom")
        with self.assertRaises((OSError, ValueError)):
            self.release.selected(retention, first)
        with self.assertRaises(ValueError):
            self.release.retained_names(identity, "../unsafe")
        self.assertFalse((self.root / "unsafe-retained").exists())

    def test_production_helper_closure_cannot_omit_runtime_support(self):
        inputs = module("deploy_venv_inputs")
        file = self.root / "helpers/deploy_venv.sh"
        file.parent.mkdir()
        file.write_bytes(b"#!/bin/bash\n")
        self.assertIn("deploy_venv_archive.py", inputs.HELPER_SOURCES)
        self.assertIn("deploy_venv_release.py", inputs.HELPER_SOURCES)
        self.assertIn("install_pkg.sh", inputs.HELPER_SOURCES)
        manifest = {
            "schema": 1,
            "application": {"version": "2.0", "revision": "a" * 40, "path": "application", "sha256": "b" * 64},
            "tools": {"version": "1.7", "coordinate": "tools/1.7/tools.tar", "python": "3.13.15",
                      "path": "tools", "sha256": "b" * 64},
            "entry": {"path": "entry", "sha256": "b" * 64},
            "uv": {"version": "0.12.17", "provenance": "original-static", "path": "uv", "sha256": "b" * 64},
            "metadata": [{"path": "metadata/pyproject.toml", "sha256": "b" * 64}],
            "profiles": [{"path": "profile", "sha256": "b" * 64}],
            "wheels": [], "transport": {"path": "transport", "sha256": "b" * 64},
            "runtime": [{"path": "runtime", "sha256": "b" * 64}],
            "helpers": {"revision": "a" * 40, "members": [{"path": "helpers/deploy_venv.sh", "sha256": artifact(file)}]},
        }
        with self.assertRaisesRegex(ValueError, "closure"):
            inputs.verify(manifest, self.root)


if __name__ == "__main__":
    unittest.main()
