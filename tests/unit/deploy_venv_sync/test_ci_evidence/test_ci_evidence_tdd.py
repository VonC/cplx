"""Combined CI evidence binds one successful build to immutable candidate bytes."""

import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest

HELPERS = Path(__file__).resolve().parents[4] / "src/setups/env/bin"
sys.path.insert(0, str(HELPERS))
from tests.unit.deploy_venv_sync.test_release_inputs.test_release_inputs_tdd import fixture


def load(name):
    spec = importlib.util.spec_from_file_location(name, HELPERS / (name + ".py"))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


class CiEvidenceTest(unittest.TestCase):
    """Reject stale, mistyped, masked or mismatched outcomes before eligibility."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.inputs = load("deploy_venv_inputs")
        self.release = load("deploy_venv_release")
        manifest = fixture(self.root)
        self.revision = manifest["application"]["revision"]
        bundle = self.root / "companion.tar"
        self.inputs.assemble(manifest, self.root, bundle)
        self.files = {"application": self.root / manifest["application"]["path"],
                      "tools": self.root / manifest["tools"]["path"],
                      "entry": self.root / manifest["entry"]["path"],
                      "companion": bundle}
        self.record = self.root / "release-inputs.txt"
        self.record.write_text(self.inputs.release_record(manifest, bundle), newline="\n")
        self.coverage = self.root / "coverage.xml"
        self.coverage.write_text("<coverage/>\n", newline="\n")
        row = self.release.parse(self.record)
        profile = hashlib.sha256(b"selection").hexdigest()
        inventory = hashlib.sha256(b"inventory").hexdigest()
        identity = {"tools_sha256": row["tools_sha256"],
                    "helpers_manifest_sha256": row["helpers_manifest_sha256"],
                    "profile_sha256": profile}
        self.evidence = {
            "schema": 1,
            "build": {"number": "211", "revision": self.revision, "result": "SUCCESS"},
            "candidate": {"record_sha256": self.release.sha256(self.record),
                          "application_sha256": row["application_sha256"],
                          "companion_sha256": row["companion_sha256"],
                          "helpers_revision": row["helpers_revision"], **identity},
            "phase1": {"build": "211", "revision": self.revision,
                       "status": "success", "complete": True,
                       "coverage_sha256": self.release.sha256(self.coverage),
                       "coverage_revision": self.revision,
                       "inventory_sha256": inventory, **identity},
            "phase2": {"build": "211", "revision": self.revision,
                       "test_revision": self.revision, "sonar_revision": self.revision,
                       "status": "success", "complete": True,
                       "sonar_status": "success", "quality_status": "success",
                       "publish_status": "dry-run",
                       "sync_status": 0, "install_status": 0,
                       "test_session": {"started": True, "completed": True,
                                        "exit_status": 0},
                       "inventory_before_sha256": inventory,
                       "inventory_after_sha256": inventory, **identity},
        }

    def check(self, evidence=None):
        path = self.root / "ci-evidence.json"
        path.write_text(json.dumps(self.evidence if evidence is None else evidence))
        return self.release.validate_ci_evidence(self.record, self.files,
                                                 self.coverage, path)

    def test_complete_build_is_eligible(self):
        self.assertEqual(self.check()["build"]["number"], "211")

    def test_rejects_mistyped_or_unsupported_schema(self):
        for value in (True, False, 1.0, "1", 2, None):
            bad = copy.deepcopy(self.evidence)
            bad["schema"] = value
            with self.subTest(schema=value), self.assertRaisesRegex(ValueError, "incomplete CI evidence"):
                self.check(bad)

    def test_rejects_duplicate_json_keys(self):
        path = self.root / "duplicate.json"
        for text in ('{"schema":1,' + json.dumps(self.evidence)[1:],
                     json.dumps(self.evidence).replace('"number": "211"',
                                                      '"number":"999","number":"211"')):
            path.write_text(text, encoding="utf-8")
            with self.subTest(text=text), self.assertRaisesRegex(ValueError, "duplicate CI evidence key"):
                self.release.validate_ci_evidence(self.record, self.files, self.coverage, path)

    def test_rejects_wrong_evidence_shape(self):
        for value in ([], None, "success"):
            path = self.root / "shape.json"
            path.write_text(json.dumps(value), encoding="utf-8")
            with self.subTest(value=value), self.assertRaisesRegex(ValueError, "incomplete CI evidence"):
                self.release.validate_ci_evidence(self.record, self.files, self.coverage, path)
        for section in (None, "build", "candidate", "phase1", "phase2"):
            for operation in ("missing", "extra", "non-object"):
                bad = copy.deepcopy(self.evidence)
                target = bad if section is None else bad[section]
                if operation == "missing":
                    del target[next(iter(target))]
                elif operation == "extra":
                    target["unexpected"] = True
                elif section is None:
                    bad = []
                else:
                    bad[section] = []
                with self.subTest(section=section, operation=operation), self.assertRaisesRegex(ValueError, "incomplete CI"):
                    self.check(bad)

    def test_rejects_failed_or_unsafe_stages(self):
        for section, field, values, message in (
                ("build", "result", ("FAILURE",), "CI build did not succeed"),
                ("build", "number", (0, "0", "x"), "CI build did not succeed"),
                ("phase1", "status", ("failure",), "stale or incomplete"),
                ("phase2", "status", ("failure",), "stale or incomplete"),
                ("phase2", "sonar_status", ("failure", "skipped"), "mandated stages"),
                ("phase2", "quality_status", ("failure", "skipped"), "mandated stages"),
                ("phase2", "publish_status", ("success", "skipped"), "mandated stages")):
            for value in values:
                bad = copy.deepcopy(self.evidence)
                bad[section][field] = value
                with self.subTest(section=section, field=field, value=value), self.assertRaisesRegex(ValueError, message):
                    self.check(bad)

    def test_rejects_malformed_profile_digest(self):
        for value in (None, 1, "invalid", "A" * 64, "a" * 63):
            bad = copy.deepcopy(self.evidence)
            bad["candidate"]["profile_sha256"] = value
            with self.subTest(value=value), self.assertRaisesRegex(ValueError, "invalid CI profile identity"):
                self.check(bad)

    def test_rejects_stale_or_incomplete_observation(self):
        for change in ({"build": {"number": "212"}},
                       {"phase1": {"complete": False}},
                       {"phase2": {"complete": False}},
                       {"phase2": {"test_session": {"completed": False}}},
                       {"phase2": {"sync_status": 1}},
                       {"phase2": {"install_status": 1}},
                       {"phase2": {"test_session": {"exit_status": 1}}}):
            bad = copy.deepcopy(self.evidence)
            for section, values in change.items():
                for key, value in values.items():
                    if isinstance(value, dict):
                        bad[section][key].update(value)
                    else:
                        bad[section][key] = value
            with self.subTest(change=change), self.assertRaises(ValueError):
                self.check(bad)

    def test_rejects_identity_and_revision_drift(self):
        for section, key in (("build", "revision"), ("phase1", "revision"),
                             ("phase2", "test_revision"), ("phase2", "sonar_revision"),
                             ("candidate", "application_sha256"),
                             ("candidate", "companion_sha256"),
                             ("candidate", "helpers_revision"),
                             ("candidate", "record_sha256"),
                             ("candidate", "helpers_manifest_sha256"),
                             ("candidate", "tools_sha256"),
                             ("phase1", "helpers_manifest_sha256"),
                             ("phase1", "tools_sha256"),
                             ("phase1", "profile_sha256"),
                             ("phase2", "helpers_manifest_sha256"),
                             ("phase2", "tools_sha256"),
                             ("phase2", "profile_sha256")):
            bad = copy.deepcopy(self.evidence)
            bad[section][key] = "f" * (40 if key.endswith("revision") else 64)
            with self.subTest(section=section, key=key), self.assertRaises(ValueError):
                self.check(bad)

    def test_rejects_mistyped_dependency_status(self):
        for field in ("sync_status", "install_status"):
            for value in (False, 0.0, "0", None):
                bad = copy.deepcopy(self.evidence)
                bad["phase2"][field] = value
                with self.subTest(field=field, value=value), self.assertRaisesRegex(ValueError, "dependency or test command"):
                    self.check(bad)

    def test_rejects_mistyped_session_outcomes(self):
        for field, value in (("started", 1), ("started", 1.0),
                             ("completed", 1), ("completed", 1.0),
                             ("exit_status", False), ("exit_status", 0.0)):
            bad = copy.deepcopy(self.evidence)
            bad["phase2"]["test_session"][field] = value
            with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                self.check(bad)

    def test_rejects_coverage_or_inventory_drift(self):
        for section, key in (("phase1", "coverage_sha256"),
                             ("phase1", "coverage_revision"),
                             ("phase2", "inventory_before_sha256"),
                             ("phase2", "inventory_after_sha256")):
            bad = copy.deepcopy(self.evidence)
            bad[section][key] = "f" * (40 if key.endswith("revision") else 64)
            with self.subTest(section=section, key=key), self.assertRaises(ValueError):
                self.check(bad)
        self.coverage.write_text("<changed/>\n")
        with self.assertRaises(ValueError):
            self.check()

    def test_rejects_symlinked_coverage(self):
        target = self.root / "actual-coverage.xml"
        self.coverage.rename(target)
        self.coverage.symlink_to(target)
        with self.assertRaisesRegex(ValueError, "phase 1 coverage identity differs"):
            self.check()

    def test_rejects_missing_coverage(self):
        self.coverage.unlink()
        with self.assertRaisesRegex(ValueError, "phase 1 coverage identity differs"):
            self.check()

    def test_rejects_profile_shared_by_both_phases_but_not_candidate(self):
        bad = copy.deepcopy(self.evidence)
        for section in ("candidate", "phase1", "phase2"):
            bad[section]["profile_sha256"] = "f" * 64
        with self.assertRaises(ValueError):
            self.check(bad)

    def test_rejects_missing_archive_pair_and_overwritten_record(self):
        self.files["application"].unlink()
        with self.assertRaises(ValueError):
            self.check()
        self.files["application"].write_bytes(b"app")
        self.record.write_text(self.record.read_text().replace(
            "application_version=2.0", "application_version=2.1"))
        with self.assertRaises(ValueError):
            self.check()
