"""Release inputs reject drift before assembly and preserve transport identities."""

import copy
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import sys
import tarfile
import tempfile
import unittest

HELPERS = Path(__file__).resolve().parents[4] / "src/setups/env/bin"
sys.path.insert(0, str(HELPERS))


def module(name):
    spec = importlib.util.spec_from_file_location(name, HELPERS / (name + ".py"))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def fixture(root):
    """Independent minimal manifest with separate application and tools versions."""
    def artifact(name, content):
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)
        return {"path": name, "sha256": hashlib.sha256(content).hexdigest()}

    project = b'[project]\nname="fixture"\nversion="2.0"\nrequires-python=">=3.11"\ndependencies=[]\n'
    lock = b'version=1\nrevision=3\nrequires-python=">=3.11"\n[[package]]\nname="fixture"\nversion="2.0"\nsource={virtual="."}\n'
    return {
        "schema": 1,
        "application": {"version": "2.0", "revision": "a" * 40,
                        **artifact("external/app.tar", b"app")},
        "tools": {"version": "1.7", "coordinate": "tools/1.7/tools.tar",
                  "python": "3.13.15", **artifact("external/tools.tar", b"tools")},
        "entry": artifact("external/deploy.sh", b"#!/bin/bash\n"),
        "uv": {"version": "0.12.17", "provenance": "original-static",
               **artifact("bin/uv", b"uv fixture")},
        "metadata": [artifact("metadata/pyproject.toml", project),
                     artifact("metadata/uv.lock", lock)],
        "profiles": [artifact("profiles/runtime.json", b'{"os":"linux","arch":"x86_64","groups":[],"extras":[]}')],
        "wheels": [],
        "transport": artifact("transport.json", b'{"schema":1,"locations":{}}'),
        "runtime": [artifact("evidence/runtime.json", b'{"qualified":true}')],
        "helpers": {"revision": "b" * 40, "members": [artifact("helpers/entry.py", b"print('fixture')\n")]},
    }


class ReleaseInputsTest(unittest.TestCase):
    """Required bindings, safe extraction and immutable records fail closed."""

    def setUp(self):
        self.inputs = module("deploy_venv_inputs")
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.manifest = fixture(self.root)

    def test_assembly_and_outer_record_bind_different_versions(self):
        self.inputs.verify(self.manifest, self.root)
        bundle = self.root / "companion.tar"
        self.inputs.assemble(self.manifest, self.root, bundle)
        record = self.inputs.release_record(self.manifest, bundle)
        self.assertIn("tools_version=1.7\n", record)
        self.assertIn("application_version=2.0\n", record)
        self.assertIn("companion_sha256=" + self.inputs.sha256(bundle), record)
        destination = self.root / "unpacked"
        self.inputs.extract(bundle, destination, self.inputs.sha256(bundle))
        inner = json.loads((destination / "manifest.json").read_text())
        self.assertNotIn("companion", inner)
        self.assertEqual((destination / "helpers/entry.py").read_bytes(), b"print('fixture')\n")
        self.assertFalse((destination / "external/tools.tar").exists())

    def test_missing_required_fields(self):
        for key in self.manifest:
            with self.subTest(key=key):
                candidate = copy.deepcopy(self.manifest)
                del candidate[key]
                with self.assertRaises(ValueError):
                    self.inputs.verify(candidate, self.root)

    def test_changed_members_and_metadata_fail(self):
        for row in [self.manifest["uv"], *self.manifest["metadata"], *self.manifest["helpers"]["members"]]:
            path = self.root / row["path"]
            original = path.read_bytes()
            path.write_bytes(original + b"corrupt")
            with self.assertRaises(ValueError):
                self.inputs.verify(self.manifest, self.root)
            path.write_bytes(original)

    def test_tools_pin_missing_or_conflicting(self):
        pin = self.root / "tools.version"
        with self.assertRaises((ValueError, OSError)):
            self.inputs.verify(self.manifest, self.root, pin)
        for content in ("", "2.0\n", "1.7\n2.0\n"):
            pin.write_text(content)
            with self.assertRaises(ValueError):
                self.inputs.verify(self.manifest, self.root, pin)
        pin.write_text("1.7\n")
        self.inputs.verify(self.manifest, self.root, pin)

    def test_self_reference_and_duplicate_members_fail(self):
        for path in ("manifest.json", "../outside", "/absolute", "a/../b", "a\\b", "a//b", "C:escape", "a/%2e%2e/b"):
            candidate = copy.deepcopy(self.manifest)
            candidate["helpers"]["members"][0]["path"] = path
            with self.subTest(path=path), self.assertRaises(ValueError):
                self.inputs.verify(candidate, self.root)
        self.manifest["helpers"]["members"].append(self.manifest["uv"])
        with self.assertRaises(ValueError):
            self.inputs.verify(self.manifest, self.root)

    def test_unsafe_tar_fails_before_destination_creation(self):
        for name, kind in (("../escape", tarfile.REGTYPE), ("link", tarfile.SYMTYPE), ("/absolute", tarfile.REGTYPE)):
            archive = self.root / "unsafe.tar"
            with tarfile.open(archive, "w") as stream:
                info = tarfile.TarInfo(name)
                info.type = kind
                info.linkname = "../escape" if kind == tarfile.SYMTYPE else ""
                stream.addfile(info, io.BytesIO())
            destination = self.root / "unsafe"
            with self.assertRaises(ValueError):
                self.inputs.extract(archive, destination, self.inputs.sha256(archive))
            self.assertFalse(destination.exists())

    def test_unlisted_workspace_metadata_fails(self):
        path = self.root / "metadata/pyproject.toml"
        path.write_text(path.read_text() + '\n[tool.uv.workspace]\nmembers=["child"]\n')
        self.manifest["metadata"][0]["sha256"] = self.inputs.sha256(path)
        with self.assertRaises(ValueError):
            self.inputs.verify(self.manifest, self.root)

    def test_lock_local_source_requires_retained_project_metadata(self):
        path = self.root / "metadata/uv.lock"
        path.write_text(path.read_text() + '\n[[package]]\nname="child"\nversion="1"\nsource={editable="child"}\n')
        self.manifest["metadata"][1]["sha256"] = self.inputs.sha256(path)
        with self.assertRaisesRegex(ValueError, "local source metadata omitted"):
            self.inputs.verify(self.manifest, self.root)

    def test_original_wheel_requires_canonical_hash_and_unique_identity(self):
        wheel = self.root / "wheels/demo-1-py3-none-any.whl"
        wheel.parent.mkdir()
        wheel.write_bytes(b"original wheel")
        row = {"path": "wheels/" + wheel.name, "filename": wheel.name,
               "sha256": self.inputs.sha256(wheel), "name": "demo", "version": "1"}
        self.manifest["wheels"] = [row]
        with self.assertRaises(ValueError):
            self.inputs.verify(self.manifest, self.root)
        lock_path = self.root / "metadata/uv.lock"
        lock_path.write_text(lock_path.read_text() + '\n[[package]]\nname="demo"\nversion="1"\nwheels=[{url="https://example.org/demo.whl",hash="sha256:' + row["sha256"] + '"}]\n')
        self.manifest["metadata"][1]["sha256"] = self.inputs.sha256(lock_path)
        self.inputs.verify(self.manifest, self.root)
        wheel.write_bytes(b"corrupt wheel")
        with self.assertRaises(ValueError):
            self.inputs.verify(self.manifest, self.root)

    def test_manifest_duplicate_keys_are_refused(self):
        path = self.root / "bad.json"
        path.write_text('{"schema":1,"schema":1}')
        with self.assertRaises(ValueError):
            self.inputs.load(path)

    def test_bundle_cannot_overwrite_a_frozen_candidate(self):
        output = self.root / "frozen.tar"
        output.write_bytes(b"retained release")
        with self.assertRaises(FileExistsError):
            self.inputs.assemble(self.manifest, self.root, output)
        self.assertEqual(output.read_bytes(), b"retained release")

    def test_inner_manifest_duplicate_keys_are_refused_before_extraction(self):
        output = self.root / "duplicate.tar"
        data = self.inputs.encoded(self.manifest).replace(b'{', b'{"schema":1,', 1)
        with tarfile.open(output, "w") as archive:
            item = tarfile.TarInfo("manifest.json")
            item.size = len(data)
            archive.addfile(item, io.BytesIO(data))
            for row in self.inputs.members(self.manifest):
                archive.add(self.root / row["path"], arcname=row["path"])
        destination = self.root / "destination"
        with self.assertRaisesRegex(ValueError, "duplicate manifest key"):
            self.inputs.extract(output, destination, self.inputs.sha256(output))
        self.assertFalse(destination.exists())

    def test_unlisted_tar_member_is_refused(self):
        output = self.root / "bundle.tar"
        self.inputs.assemble(self.manifest, self.root, output)
        with tarfile.open(output, "a") as archive:
            item = tarfile.TarInfo("unlisted.py")
            archive.addfile(item, io.BytesIO())
        destination = self.root / "destination"
        with self.assertRaises(ValueError):
            self.inputs.extract(output, destination, self.inputs.sha256(output))
        self.assertFalse(destination.exists())


class TransportTest(unittest.TestCase):
    """Only explicitly mapped registry/artifact strings may change in TOML trees."""

    def setUp(self):
        self.transport = module("deploy_venv_transport")

    def test_project_documentation_urls_are_not_transport_locations(self):
        original = {"project": {"urls": {"Homepage": "https://example.org/project"}},
                    "source": {"registry": "https://example.org/simple"}}
        mapping = {"https://example.org/simple": "file:///bundle/simple"}
        changed = self.transport.rewrite(original, mapping)
        self.assertEqual(changed["project"], original["project"])
        self.transport.validate(original, changed, mapping)

    def test_mapped_roundtrip_preserves_every_non_location_field(self):
        original = {"version": 1, "package": [{"name": "demo", "version": "1", "source": {"registry": "https://example.org/simple"}, "wheels": [{"url": "https://example.org/demo.whl", "hash": "sha256:" + "a" * 64}]}]}
        mapping = {"https://example.org/simple": "file:///bundle/simple", "https://example.org/demo.whl": "file:///bundle/demo.whl"}
        rewritten = self.transport.rewrite(original, mapping)
        self.transport.validate(original, rewritten, mapping)
        rewritten["package"][0]["version"] = "2"
        with self.assertRaises(ValueError):
            self.transport.validate(original, rewritten, mapping)

    def test_unmapped_or_ambiguous_urls_fail(self):
        for mapping in ({}, {"https://a/a": "file:///a", "https://a/b": "file:///a"}):
            with self.assertRaises(ValueError):
                self.transport.rewrite({"url": "https://a/a"}, mapping)

    def test_toml_serializer_roundtrip_handles_workspace_and_markers(self):
        import tomllib
        value = {"project": {"name": "quote\"name", "dependencies": ["a; python_version >= '3.11'"]}, "tool": {"uv": {"index": [{"name": "local", "url": "file:///wheels", "default": True}], "workspace": {"members": ["child"]}}}}
        self.assertEqual(tomllib.loads(self.transport.dumps(value)), value)

    def test_workspace_is_new_and_canonical_bytes_are_immutable(self):
        inputs = module("deploy_venv_inputs")
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            manifest = fixture(root)
            workspace = root / "operation"
            before = {row["path"]: (root / row["path"]).read_bytes() for row in manifest["metadata"]}
            mapping = self.transport.workspace(manifest, root, workspace)
            self.transport.check_workspace(manifest, root, workspace, mapping)
            self.assertEqual(before, {name: (root / name).read_bytes() for name in before})
            with self.assertRaises(FileExistsError):
                self.transport.workspace(manifest, root, workspace)
            lock = workspace / "uv.lock"
            lock.write_text(lock.read_text().replace('"2.0"', '"2.1"'))
            with self.assertRaises(ValueError):
                self.transport.check_workspace(manifest, root, workspace, mapping)
            (root / "metadata/uv.lock").write_text("version=2\n")
            with self.assertRaises(ValueError):
                self.transport.check_workspace(manifest, root, workspace, mapping)
            self.assertNotEqual(inputs.sha256(root / "metadata/uv.lock"), manifest["metadata"][1]["sha256"])

    def test_transport_mapping_rejects_credentials_remote_file_and_escape(self):
        for target in ("file://remote/a.whl", "file:///a/%2e%2e/b.whl", "https://user:password@example.org/a", "file:relative"):
            with self.subTest(target=target), self.assertRaises(ValueError):
                self.transport.rewrite({"url": "https://example.org/a.whl"}, {"https://example.org/a.whl": target})

    def test_release_mapping_uses_only_explicit_local_members(self):
        inputs = module("deploy_venv_inputs")
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            manifest = fixture(root)
            path = root / "transport.json"
            path.write_text(json.dumps({"schema": 1, "locations": {"https://example.org/simple": "registry/simple"}}))
            manifest["transport"]["sha256"] = inputs.sha256(path)
            mapping = self.transport.mapping_for(manifest, root)
            self.assertEqual(mapping["https://example.org/simple"], (root.resolve() / "registry/simple").as_uri())
            with self.assertRaises(ValueError):
                self.transport.mapping_for(manifest, root, "http://example.org:8000")
            mapping = self.transport.mapping_for(manifest, root, "http://127.0.0.1:8000")
            self.assertEqual(mapping["https://example.org/simple"], "http://127.0.0.1:8000/registry/simple")


if __name__ == "__main__":
    unittest.main()
