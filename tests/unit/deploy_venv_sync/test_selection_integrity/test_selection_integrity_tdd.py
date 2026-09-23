"""Selection and venv ELF checks reject drift while preserving schema one."""

import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
import zipfile

BIN = Path(__file__).resolve().parents[4] / "src/setups/env/bin"


def module(name):
    spec = importlib.util.spec_from_file_location(name, BIN / (name + ".py"))
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


class SelectionIntegrityTest(unittest.TestCase):
    """Original wheel, lock, metadata and bin ELF identities must agree."""

    def setUp(self):
        self.selection = module("deploy_venv_selection")
        self.inventory = module("tools_wheel_inventory")
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.site = self.root / "venv/lib/python/site-packages"
        self.site.mkdir(parents=True)
        self.bin = self.root / "venv/bin"
        self.bin.mkdir()
        self.wheels = self.root / "wheels"
        self.wheels.mkdir()
        self.filename = "demo_pkg-1.0-py3-none-any.whl"
        self.payload = b"\x7fELF$ORIGIN/libdemo"
        self.wheel = self.wheels / self.filename
        with zipfile.ZipFile(self.wheel, "w") as archive:
            archive.writestr("demo_pkg/native.so", self.payload)
            archive.writestr("demo_pkg-1.0.data/scripts/helper", self.payload)
        (self.site / "demo_pkg").mkdir()
        (self.site / "demo_pkg/native.so").write_bytes(self.payload)
        (self.bin / "helper").write_bytes(self.payload)
        (self.bin / "python3").write_bytes(b"\x7fELFgenerated interpreter")
        metadata = self.site / "demo_pkg-1.0.dist-info"
        metadata.mkdir()
        (metadata / "METADATA").write_text("Name: demo-pkg\nVersion: 1.0\n")
        self.lock = self.root / "uv.lock"
        self.project = self.root / "pyproject.toml"
        self.project.write_text('[tool.uv]\ndefault-groups = ["dev", "tooling"]\n')
        self.lock.write_text('version = 1\n[[package]]\nname = "project"\n'
                             'version = "1.0"\nsource = {virtual = "."}\n'
                             'dependencies = [{name = "demo-pkg", marker = "sys_platform == '
                             "'linux'" + '"}]\n'
                             '[[package]]\nname = "demo-pkg"\nversion = "1.0"\n'
                             'wheels = [{url = "https://example.invalid/' + self.filename +
                             '", hash = "sha256:' + self.selection.digest(self.wheel) + '"}]\n')
        self.profile = self.root / "profile.json"
        self.row = {"name": "demo_pkg", "version": "1.0", "filename": self.filename,
                    "sha256": self.selection.digest(self.wheel)}
        self.data = {"schema": 1, "lock_sha256": self.selection.digest(self.lock),
                     "project_sha256": self.selection.digest(self.project),
                     "target": "linux-x86_64", "python": "3.13.15", "tags": ["py3-none-any"],
                     "markers": {"sys_platform": "linux", "platform_machine": "x86_64"},
                     "groups": [], "requested_groups": [], "excluded_groups": [],
                     "no_default_groups": True, "extras": [], "qualified_uv": "0.12.17",
                     "toolchain_sha256": "a" * 64,
                     "source_revision": "a" * 40, "selected": [self.row]}
        self.save()

    def save(self):
        self.profile.write_text(json.dumps(self.data))

    def test_selection_binds_installed_metadata_and_original_wheel(self):
        report = self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)
        self.assertEqual(report["distributions"], 1)
        self.assertEqual(report["profile_sha256"], self.selection.digest(self.profile))
        self.assertEqual(report["lock_sha256"], self.selection.digest(self.lock))

    def test_selection_and_elf_reports_share_exact_wheel_set(self):
        inventory = self.root / "inventory.json"
        record = {"schema": 2, "lock_sha256": self.selection.digest(self.lock),
                  "profile_sha256": self.selection.digest(self.profile),
                  "wheels": [{"filename": self.filename,
                              "sha256": self.selection.digest(self.wheel)}]}
        inventory.write_text(json.dumps(record))
        self.selection.verify(self.lock, self.project, self.profile, self.wheels,
                              self.site, inventory)
        record["wheels"] = []
        inventory.write_text(json.dumps(record))
        with self.assertRaisesRegex(ValueError, "ELF inventory wheel selection"):
            self.selection.verify(self.lock, self.project, self.profile,
                                  self.wheels, self.site, inventory)

    def test_selection_toolchain_digest_matches_manifest(self):
        manifest = self.root / "manifest.json"
        manifest.write_text(json.dumps({"tools": {"sha256": "a" * 64},
                                        "application": {"revision": "a" * 40}}))
        self.selection.verify(self.lock, self.project, self.profile,
                              self.wheels, self.site, manifest_path=manifest)
        manifest.write_text(json.dumps({"tools": {"sha256": "b" * 64},
                                        "application": {"revision": "a" * 40}}))
        with self.assertRaisesRegex(ValueError, "toolchain digest mismatch"):
            self.selection.verify(self.lock, self.project, self.profile,
                                  self.wheels, self.site, manifest_path=manifest)
        manifest.write_text(json.dumps({"tools": {"sha256": "a" * 64},
                                        "application": {"revision": "b" * 40}}))
        with self.assertRaisesRegex(ValueError, "source revision mismatch"):
            self.selection.verify(self.lock, self.project, self.profile,
                                  self.wheels, self.site, manifest_path=manifest)

    def test_selection_target_profile_matches_effective_groups(self):
        target = self.root / "target.json"
        target.write_text(json.dumps({"os": "linux", "arch": "x86_64",
                                      "groups": [], "extras": []}))
        self.selection.verify(self.lock, self.project, self.profile,
                              self.wheels, self.site, target_profile_path=target)
        target.write_text(json.dumps({"os": "linux", "arch": "x86_64",
                                      "groups": ["dev"], "extras": []}))
        with self.assertRaisesRegex(ValueError, "target profile mismatch"):
            self.selection.verify(self.lock, self.project, self.profile,
                                  self.wheels, self.site, target_profile_path=target)

    def test_selection_rejects_missing_extra_duplicate_and_wrong_tag(self):
        self.data["selected"] = []
        self.save()
        with self.assertRaisesRegex(ValueError, "qualified selection"):
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)
        self.data["selected"] = [self.row, dict(self.row)]
        self.save()
        with self.assertRaisesRegex(ValueError, "duplicate selected"):
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)
        self.data["selected"] = [self.row]
        self.data["tags"] = ["cp313-cp313-linux_x86_64"]
        self.save()
        with self.assertRaisesRegex(ValueError, "wheel tag"):
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)

    def test_selection_rejects_hash_and_installed_drift(self):
        self.row["sha256"] = "0" * 64
        self.save()
        with self.assertRaisesRegex(ValueError, "canonical lock"):
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)
        self.row["sha256"] = self.selection.digest(self.wheel)
        self.save()
        self.wheel.write_bytes(b"substituted")
        with self.assertRaisesRegex(ValueError, "original wheel"):
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)

    def test_installed_normalized_duplicate_and_wrong_version_fail(self):
        duplicate = self.site / "demo.pkg-1.0.dist-info"
        duplicate.mkdir()
        (duplicate / "METADATA").write_text("Name: demo_pkg\nVersion: 1.0\n")
        with self.assertRaisesRegex(ValueError, "duplicate installed distribution"):
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)
        (duplicate / "METADATA").write_text("Name: other\nVersion: 1.0\n")
        with self.assertRaisesRegex(ValueError, "installed distribution selection mismatch"):
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)
        (duplicate / "METADATA").write_text("Name: demo_pkg\nVersion: 2.0\n")
        with self.assertRaisesRegex(ValueError, "duplicate installed distribution"):
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)

    def test_marker_exclusion_does_not_require_distribution(self):
        self.data["markers"]["sys_platform"] = "win32"
        self.data["selected"] = []
        self.save()
        self.assertEqual(self.selection.selected_lock_packages(
            __import__("tomllib").loads(self.lock.read_text()), self.data), {})

    def test_python_version_markers_compare_numeric_components(self):
        import ast

        marker = ast.parse("python_version < '3.10'", mode="eval")
        self.assertTrue(self.selection.marker_value(marker, {"python_version": "3.9"}))
        self.assertFalse(self.selection.marker_value(marker, {"python_version": "3.10"}))

    def test_qualified_selection_cannot_add_marker_excluded_package(self):
        self.data["markers"]["sys_platform"] = "win32"
        self.save()
        with self.assertRaisesRegex(ValueError, "qualified selection"):
            self.selection.verify(self.lock, self.project, self.profile, self.wheels, self.site)

    def test_group_extra_and_transitive_marker_closure(self):
        root = {"name": "project", "version": "1", "source": {"virtual": "."},
                "dependencies": [{"name": "base", "extra": ["speed"]}],
                "dev-dependencies": {"dev": [{"name": "tests"}]},
                "optional-dependencies": {"feature": [{"name": "feature-pkg"}]}}
        lock = {"package": [root,
                {"name": "base", "version": "1", "dependencies": [],
                 "optional-dependencies": {"speed": [{"name": "fast"}]}},
                {"name": "fast", "version": "2"},
                {"name": "tests", "version": "3", "dependencies": [
                    {"name": "windows-only", "marker": "sys_platform == 'win32'"}]},
                {"name": "feature-pkg", "version": "4"},
                {"name": "windows-only", "version": "5"}]}
        profile = {"markers": {"sys_platform": "linux"}, "groups": ["dev"],
                   "extras": ["feature"]}
        self.assertEqual(self.selection.selected_lock_packages(lock, profile),
                         {"base": "1", "fast": "2", "tests": "3", "feature-pkg": "4"})
        profile["markers"]["sys_platform"] = "win32"
        self.assertEqual(self.selection.selected_lock_packages(lock, profile)["windows-only"], "5")

    def test_effective_groups_include_defaults_unless_excluded(self):
        self.data.update(no_default_groups=False, groups=["dev"],
                         excluded_groups=["tooling"])
        self.selection.effective_groups({"tool": {"uv": {
            "default-groups": ["dev", "tooling"]}}}, self.data)
        self.data["groups"] = []
        with self.assertRaisesRegex(ValueError, "effective dependency groups"):
            self.selection.effective_groups({"tool": {"uv": {
                "default-groups": ["dev", "tooling"]}}}, self.data)

    def test_schema_two_inventory_binds_profile_and_selected_wheels(self):
        output = self.root / "inventory.json"
        args = SimpleNamespace(lock=self.lock, wheel_dir=self.wheels,
                               installed_root=self.site, venv_root=self.root / "venv",
                               profile=self.profile, output=output)
        self.inventory.capture(args)
        data = self.inventory.load_inventory(output, self.lock, self.profile)
        self.assertEqual(data["profile_sha256"], self.selection.digest(self.profile))
        self.assertEqual([wheel["filename"] for wheel in data["wheels"]], [self.filename])
        self.data["selected"][0]["sha256"] = "0" * 64
        self.save()
        with self.assertRaisesRegex(ValueError, "selected wheel digest"):
            self.inventory.capture(SimpleNamespace(**{**vars(args), "output": self.root / "bad.json"}))

    def test_schema_two_rejects_duplicate_installed_elf_destinations(self):
        second = self.wheels / "other-1.0-py3-none-any.whl"
        with zipfile.ZipFile(second, "w") as archive:
            archive.writestr("other-1.0.data/scripts/helper", self.payload)
        self.data["selected"].append({"name": "other", "version": "1.0",
                                      "filename": second.name,
                                      "sha256": self.selection.digest(second)})
        self.save()
        args = SimpleNamespace(lock=self.lock, wheel_dir=self.wheels,
                               installed_root=self.site, venv_root=self.root / "venv",
                               profile=self.profile, output=self.root / "inventory.json")
        with self.assertRaisesRegex(ValueError, "duplicate installed ELF"):
            self.inventory.capture(args)

    def test_schema_two_maps_scripts_and_rejects_changed_bin_elf(self):
        with zipfile.ZipFile(self.wheel) as archive:
            members = self.inventory.wheel_members(archive, venv=True)
        self.assertEqual({item["installed"] for item in members},
                         {"site/demo_pkg/native.so", "bin/helper"})
        expected = {item["installed"]: item["sha256"] for item in members}
        self.assertEqual(self.inventory.venv_elfs(self.site, self.root / "venv", expected), expected)
        (self.bin / "helper").write_bytes(b"\x7fELFmodified")
        self.assertNotEqual(self.inventory.venv_elfs(self.site, self.root / "venv", expected), expected)

    def test_schema_one_rejects_script_elf_and_preserves_old_mapping(self):
        self.assertEqual(self.inventory.installed_name("demo_pkg-1.data/purelib/a.so"), "a.so")
        with self.assertRaisesRegex(ValueError, "outside site-packages"):
            self.inventory.installed_name("demo_pkg-1.data/scripts/helper")


if __name__ == "__main__":
    unittest.main()
