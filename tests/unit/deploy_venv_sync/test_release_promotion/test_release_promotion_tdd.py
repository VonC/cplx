"""Promotion requires exact qualification and publishes its binding record last."""

import copy
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import unittest
from unittest import mock

from tests.unit.deploy_venv_sync.test_ci_evidence import test_ci_evidence_tdd as ci_fixture


def encoded(value):
    return (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()


class ReleasePromotionTest(unittest.TestCase):
    """Exercise identity mutations, retained inputs and every publication boundary."""

    def setUp(self):
        ci_fixture.CiEvidenceTest.setUp(self)
        self.publication = ci_fixture.load("deploy_venv_publication")
        self.ci = self.root / "ci.json"
        self.ci.write_bytes(encoded(self.evidence))
        self.candidate_path = self.root / "candidate.json"
        self.qualification_path = self.root / "qualification.json"
        self.config_path = self.root / "coordinates.json"
        self.output = self.root / "receipts"
        self.candidate = {
            "schema": 1, "identity": self.release.sha256(self.record),
            "state": "retained", "expires_at": None,
            "record": str(self.record), "files": {k: str(v) for k, v in self.files.items()},
            "ci_evidence": str(self.ci), "coverage": str(self.coverage),
            "predecessors": {
                "venv_free": {"record": str(self.record),
                              "files": {k: str(v) for k, v in self.files.items()}},
                "shipped_venv": {
                    "files": {k: str(self.files[k]) for k in ("application", "entry", "tools")},
                    "sha256": {k: self.release.sha256(self.files[k])
                               for k in ("application", "entry", "tools")}},
            },
        }
        row = self.release.parse(self.record)
        binding = {**self.evidence["candidate"], "entry_sha256": row["entry_sha256"],
                   "build": "211", "revision": self.revision,
                   "ci_evidence_sha256": self.release.sha256(self.ci),
                   "coverage_sha256": self.release.sha256(self.coverage)}
        predecessors = {
            "venv_free": {"record_sha256": self.release.sha256(self.record),
                          **{key: row[key] for key in self.release.FILES.values()}},
            "shipped_venv": {key + "_sha256": self.release.sha256(self.files[key])
                             for key in ("application", "entry", "tools")},
        }
        cases = ("debian", "rhel", "offline", "readiness", "rollback_venv_free",
                 "rollback_shipped_venv")
        self.qualification = {"schema": 1, "candidate": binding,
                              "predecessors": predecessors, "results": {}}
        for name in cases:
            evidence = self.root / (name + ".evidence")
            evidence.write_text("actual observation fixture " + name)
            self.qualification["results"][name] = {
                "status": "success", "complete": True, "candidate": binding,
                "predecessors": predecessors, "evidence": str(evidence),
                "evidence_sha256": self.release.sha256(evidence),
            }
        keys = ("application", "entry", "companion", "tools", "record", "ci_evidence",
                "coverage", "qualification", "predecessor.venv_free.record",
                *("evidence." + name for name in cases),
                *("predecessor.venv_free." + key for key in self.files),
                *("predecessor.shipped_venv." + key for key in ("application", "entry", "tools")))
        self.config = {"schema": 1, "objects": {k: "test/release/" + k for k in keys},
                       "manifest": "test/release/binding.json"}
        self.remote = {}
        self.calls = []
        for key, coordinate in self.config["objects"].items():
            if key == "tools" or key.startswith("predecessor."):
                name = key.rsplit(".", 1)[-1]
                source = self.record if name == "record" else self.files[name]
                self.remote[coordinate] = source.read_bytes()
        self.failure = None

    def write_inputs(self):
        self.candidate_path.write_bytes(encoded(self.candidate))
        self.qualification_path.write_bytes(encoded(self.qualification))
        self.config_path.write_bytes(encoded(self.config))

    def digest(self, coordinate):
        self.calls.append(("read", coordinate))
        data = self.remote.get(coordinate)
        return None if data is None else hashlib.sha256(data).hexdigest()

    def upload(self, coordinate, path):
        self.calls.append(("upload", coordinate))
        if self.failure == coordinate:
            raise OSError("injected upload failure")
        if coordinate in self.remote:
            raise FileExistsError("immutable repository")
        self.remote[coordinate] = Path(path).read_bytes()

    def publish(self):
        self.write_inputs()
        return self.publication.publish(self.candidate_path, self.qualification_path,
                                        self.config_path, self, self.output)

    def test_complete_publication_preserves_bytes_and_exposes_manifest_last(self):
        result = self.publish()
        uploads = [key for op, key in self.calls if op == "upload"]
        self.assertEqual(uploads[-1], self.config["manifest"])
        for key in ("application", "entry", "companion"):
            self.assertEqual(self.remote[self.config["objects"][key]], self.files[key].read_bytes())
        manifest = json.loads(self.remote[self.config["manifest"]])
        self.assertEqual(manifest["candidate"], self.qualification["candidate"])
        self.assertEqual(manifest["predecessors"], self.qualification["predecessors"])
        self.assertEqual(manifest["objects"]["qualification"]["sha256"],
                         self.release.sha256(self.qualification_path))
        self.assertEqual(result["manifest_sha256"], hashlib.sha256(encoded(manifest)).hexdigest())
        self.assertTrue((self.output / "receipt.json").is_file())

    def test_identical_retry_performs_no_upload(self):
        first = self.publish()
        self.calls.clear()
        self.assertEqual(self.publish(), first)
        self.assertFalse(any(op == "upload" for op, _ in self.calls))

    def test_partial_upload_and_manifest_failure_are_retryable_without_announcement(self):
        initial = copy.deepcopy(self.remote)
        for failed in ("application", "entry", "companion", "record", "qualification", "manifest"):
            with self.subTest(failed=failed):
                self.remote = copy.deepcopy(initial)
                self.failure = (self.config["manifest"] if failed == "manifest"
                                else self.config["objects"][failed])
                with self.assertRaisesRegex(OSError, "injected"):
                    self.publish()
                self.assertNotIn(self.config["manifest"], self.remote)
                self.failure = None
                self.publish()
                self.assertIn(self.config["manifest"], self.remote)

    def test_conflicting_remote_object_or_manifest_is_never_overwritten(self):
        initial = copy.deepcopy(self.remote)
        for key in (*self.config["objects"].values(), self.config["manifest"]):
            with self.subTest(coordinate=key):
                self.remote = {**initial, key: b"different bytes"}
                self.calls.clear()
                with self.assertRaisesRegex(ValueError, "conflict"):
                    self.publish()
                self.assertFalse(any(op == "upload" for op, _ in self.calls))
                self.assertEqual(self.remote[key], b"different bytes")

    def test_missing_predecessor_or_tools_blocks_before_upload(self):
        initial = copy.deepcopy(self.remote)
        for key in initial:
            self.remote = copy.deepcopy(initial)
            del self.remote[key]
            self.calls.clear()
            with self.subTest(coordinate=key), self.assertRaisesRegex(ValueError, "retained"):
                self.publish()
            self.assertFalse(any(op == "upload" for op, _ in self.calls))

    def test_mismatched_qualification_identity_blocks_before_backend(self):
        original = copy.deepcopy(self.qualification)
        for key in original["candidate"]:
            self.qualification = copy.deepcopy(original)
            self.qualification["candidate"][key] = "wrong"
            with self.subTest(field=key), self.assertRaises(ValueError):
                self.publish()
            self.assertEqual(self.calls, [])

    def test_missing_failed_mistyped_or_wrongly_bound_result_blocks_before_backend(self):
        original = copy.deepcopy(self.qualification)
        for name in original["results"]:
            for change in ("missing", "status", "complete", "candidate", "predecessors", "evidence_sha256"):
                self.qualification = copy.deepcopy(original)
                if change == "missing":
                    del self.qualification["results"][name]
                else:
                    self.qualification["results"][name][change] = 1
                with self.subTest(name=name, field=change), self.assertRaises(ValueError):
                    self.publish()
                self.assertEqual(self.calls, [])

    def test_expired_abandoned_or_wrong_candidate_never_reaches_backend(self):
        original = copy.deepcopy(self.candidate)
        for key, value in (("expires_at", "2000-01-01T00:00:00+00:00"),
                           ("expires_at", "9999-01-01T00:00:00"),
                           ("expires_at", "not-a-date"), ("state", "abandoned"),
                           ("identity", "f" * 64), ("schema", True)):
            self.candidate = {**original, key: value}
            with self.subTest(field=key), self.assertRaises(ValueError):
                self.publish()
            self.assertEqual(self.calls, [])

    def test_same_revision_with_changed_bytes_and_missing_candidate_are_refused(self):
        path = self.files["application"]
        path.write_bytes(b"same source, different archive")
        with self.assertRaises(ValueError):
            self.publish()
        path.unlink()
        with self.assertRaises((OSError, ValueError)):
            self.publish()
        self.assertEqual(self.calls, [])

    def test_operator_cli_checks_qualification_in_isolated_mode(self):
        self.write_inputs()
        command = [sys.executable, "-I", self.publication.__file__, "publication-check",
                   "--candidate-manifest", str(self.candidate_path),
                   "--qualification-record", str(self.qualification_path)]
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.qualification["results"]["debian"]["complete"] = False
        self.write_inputs()
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn("Publication refused:", result.stderr)
        self.assertEqual(self.calls, [])

    def test_snapshot_coordinates_are_refused_before_transport(self):
        original = copy.deepcopy(self.config)
        for token in ("SNAPSHOT", "snapshot", "SnApShOt"):
            for role in ("entry", "manifest"):
                self.config = copy.deepcopy(original)
                coordinate = "test/release-" + token + "/object"
                if role == "manifest":
                    self.config[role] = coordinate
                else:
                    self.config["objects"][role] = coordinate
                with self.subTest(token=token, role=role), self.assertRaisesRegex(ValueError, "coordinate"):
                    self.publish()
                self.assertEqual(self.calls, [])

    def test_announced_release_with_missing_object_is_not_repaired(self):
        self.publish()
        original = copy.deepcopy(self.remote)
        for role in ("application", "entry", "companion", "qualification", "evidence.debian"):
            self.remote = copy.deepcopy(original)
            del self.remote[self.config["objects"][role]]
            self.calls.clear()
            with self.subTest(role=role), self.assertRaisesRegex(ValueError, "announced release"):
                self.publish()
            self.assertFalse(any(op == "upload" for op, _ in self.calls))
            self.assertEqual(self.remote[self.config["manifest"]], original[self.config["manifest"]])

    def test_manifest_readback_mismatch_never_produces_receipt(self):
        original_upload = self.upload

        def corrupt_manifest(coordinate, path):
            original_upload(coordinate, path)
            if coordinate == self.config["manifest"]:
                self.remote[coordinate] = b"corrupt binding"

        self.upload = corrupt_manifest
        with self.assertRaisesRegex(ValueError, "manifest read-back"):
            self.publish()
        self.assertEqual(self.calls[-1], ("read", self.config["manifest"]))
        self.assertFalse((self.output / "receipt.json").exists())

    def test_empty_evidence_with_matching_digest_is_refused_before_transport(self):
        for name, result in self.qualification["results"].items():
            path = Path(result["evidence"])
            original = path.read_bytes()
            path.write_bytes(b"")
            result["evidence_sha256"] = self.release.sha256(path)
            with self.subTest(case=name), self.assertRaisesRegex(ValueError, "empty"):
                self.publish()
            self.assertEqual(self.calls, [])
            path.write_bytes(original)
            result["evidence_sha256"] = self.release.sha256(path)

    def test_relative_evidence_root_is_refused_before_transport(self):
        self.output = Path("relative-receipts")
        with self.assertRaisesRegex(ValueError, "safe evidence root"):
            self.publish()
        self.assertEqual(self.calls, [])

    @unittest.skipIf(sys.platform == "win32", "actual symlink exercised by native Linux gate")
    def test_symlinked_evidence_root_is_refused_before_transport(self):
        destination = self.root / "real-receipts"
        destination.mkdir()
        self.output.symlink_to(destination, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, "safe evidence root"):
            self.publish()
        self.assertEqual(self.calls, [])
        self.assertEqual(list(destination.iterdir()), [])

    def test_non_path_local_input_is_refused_before_transport(self):
        for value in (1, None, [], {}):
            self.candidate["files"]["application"] = value
            with self.subTest(value=value), self.assertRaisesRegex(ValueError, "local input path"):
                self.publish()
            self.assertEqual(self.calls, [])

    def test_failed_combined_ci_cannot_be_replaced_by_target_qualification(self):
        self.evidence["phase2"]["complete"] = False
        self.ci.write_bytes(encoded(self.evidence))
        with self.assertRaises(ValueError):
            self.publish()
        self.assertEqual(self.calls, [])

    def test_changed_result_evidence_is_refused(self):
        Path(self.qualification["results"]["debian"]["evidence"]).write_bytes(b"changed")
        with self.assertRaisesRegex(ValueError, "evidence"):
            self.publish()
        self.assertEqual(self.calls, [])

    def test_coordinate_alias_traversal_and_missing_mapping_are_refused(self):
        original = copy.deepcopy(self.config)
        for mutation in ("alias", "traversal", "missing", "manifest-alias"):
            self.config = copy.deepcopy(original)
            if mutation == "alias":
                self.config["objects"]["entry"] = self.config["objects"]["application"]
            elif mutation == "traversal":
                self.config["objects"]["entry"] = "../escape"
            elif mutation == "missing":
                del self.config["objects"]["entry"]
            else:
                self.config["manifest"] = self.config["objects"]["entry"]
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                self.publish()
            self.assertEqual(self.calls, [])

    def test_false_upload_success_is_refused_before_manifest(self):
        self.upload = lambda coordinate, path: self.calls.append(("upload", coordinate))
        with self.assertRaisesRegex(ValueError, "read-back"):
            self.publish()
        self.assertNotIn(self.config["manifest"], self.remote)

    def test_equal_current_and_predecessor_tools_can_share_retained_coordinate(self):
        previous = self.config["objects"]["predecessor.venv_free.tools"]
        self.config["objects"]["predecessor.venv_free.tools"] = self.config["objects"]["tools"]
        del self.remote[previous]
        self.publish()
        self.assertIn(self.config["manifest"], self.remote)

    def test_evidence_changed_after_validation_never_reaches_backend(self):
        evidence = Path(self.qualification["results"]["debian"]["evidence"])
        original_hash = self.release.sha256

        def changing_hash(path):
            digest = original_hash(path)
            if Path(path) == evidence:
                evidence.write_bytes(b"changed after qualification validation")
            return digest

        with mock.patch.object(self.publication, "release_helper", return_value=self.release), \
                mock.patch.object(self.release, "sha256", side_effect=changing_hash):
            with self.assertRaisesRegex(ValueError, "changed"):
                self.publish()
        self.assertEqual(self.calls, [])
