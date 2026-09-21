"""Validate evidence identity, retention and lifecycle with finite mutations.

The generated matrix exercises every required cell and result state using only
unittest; a property-testing dependency would add no useful input coverage.
"""

import copy
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[4]
MODULE = ROOT / "src/setups/env/bin/tools_release_record.py"
SPEC = importlib.util.spec_from_file_location("tools_release_record", MODULE)
release = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(release)
REVISION = "1" * 40


def valid_record(archive, evidence):
    """Build synthetic evidence only inside an owned test directory."""
    content = archive.read_bytes()
    digest = hashlib.sha256(content).hexdigest()
    capture = evidence / "capture.txt"
    capture.write_bytes(b"conclusive fixture observation\n")
    record = {
        "candidate": {"filename": archive.name, "size": len(content), "sha256": digest,
                      "sha1": hashlib.sha1(content).hexdigest(), "python": "3.13.15",
                      "payloads": {"rpm-index": "2" * 64},
                      "regression": {"date": "2026-09-17", "decision": "clean",
                                     "sources": ["capture"]}},
        "authority": {"source_commit": "3" * 40, "declaration_sha256": "4" * 64,
                      "release_revision": REVISION, "renewed": False, "captures": ["capture"]},
        "consumers": {"application_revision": "5" * 40, "pipeline_revision": "6" * 40,
                      "lock_sha256": "7" * 64, "wheels": {"fixture.whl": "8" * 64},
                      "venv_base": "python-3.13.15-candidate"},
        "environments": {role: {"run": "fixture-run", "os": os_name,
                               "image": "image-identity", "container": "container-identity",
                               "runtime": {"loader": "9" * 64}, "transfer_sha256": digest}
                         for role, os_name in (("debian", "Debian-12"),
                                               ("rhel-build", "RHEL-9.8"),
                                               ("rhel-deploy", "RHEL-9.8"))},
        "validator": {"identity": "independent-authoring-python", "version": "3.9.25",
                      "independent": True},
        "captures": {"capture": {"path": "capture.txt", "sha256": hashlib.sha256(
            capture.read_bytes()).hexdigest(), "identity": "fixture-capture", "retention": "retained"}},
        "results": {}, "assessments": {},
        "d10": {"packaged_generation": 11, "selected_generation": 11,
                "readings": [{"generation": 11, "selected_generation": 11,
                              "consumers": {"fixture.whl": "8" * 64},
                              "required_nodes": ["GLIBCXX_3.4.29"],
                              "providers": {"11": {"identity": "gcc11", "satisfies": True},
                                            "12": {"identity": "gcc12", "satisfies": True}},
                              "captures": ["capture"]}]},
        "publication": {"coordinate": "releases:org.example:Tool:1.2.3:tools",
                        "state": "pending", "sha256": "", "sha1": "", "captures": []},
        "adoption": {"state": "pending", "recovery": "pending", "captures": [],
                     "pin_revision": "", "configuration_revision": ""},
    }
    inputs = release.current_inputs(record)
    for cell in release.CELLS:
        state = "pass" if cell in release.PUBLICATION else "pending"
        record["results"][cell] = {"state": state, "run": "fixture-run",
                                  "captures": ["capture"], "inputs": copy.deepcopy(inputs)}
    return {"schema_version": 1, "candidates": {digest: record}}


class ReleaseRecordTests(unittest.TestCase):
    """Reject incomplete or stale evidence before handing out a release digest."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.archive = self.root / "tools.20260917_120000.tar.gz"
        self.archive.write_bytes(b"fixture archive")
        self.document = valid_record(self.archive, self.root)
        self.digest = next(iter(self.document["candidates"]))
        self.record = self.document["candidates"][self.digest]

    def validate(self, phase="publication", document=None):
        return release.validate(document or self.document, self.archive, self.root, REVISION, phase)

    def test_publication_does_not_require_future_adoption(self):
        self.assertEqual(self.validate(), self.digest)
        with self.assertRaises(ValueError):
            self.validate("completion")
        for field, length in (("sha256", 64), ("sha1", 40)):
            with self.subTest(field=field):
                self.record["publication"][field] = "f" * length
                with self.assertRaises(ValueError):
                    self.validate()
                self.record["publication"][field] = ""

    def test_every_required_cell_rejects_nonpassing_or_missing_results(self):
        for cell in release.PUBLICATION:
            for state in ("", "pending", "fail", "inconclusive", "not applicable", "invented"):
                with self.subTest(cell=cell, state=state):
                    mutated = copy.deepcopy(self.document)
                    mutated["candidates"][self.digest]["results"][cell]["state"] = state
                    with self.assertRaises(ValueError):
                        self.validate(document=mutated)
            mutated = copy.deepcopy(self.document)
            del mutated["candidates"][self.digest]["results"][cell]
            with self.assertRaises(ValueError):
                self.validate(document=mutated)

    def test_optional_and_inapplicable_cells_can_be_absent(self):
        for cell in release.OPTIONAL | release.INAPPLICABLE:
            self.record["results"].pop(cell, None)
        self.assertEqual(self.validate(), self.digest)
        self.record["results"]["PA12:debian"] = {"state": "pass"}
        with self.assertRaises(ValueError):
            self.validate()

    def test_archive_and_release_revision_are_exact(self):
        for area, key, value in (("candidate", "sha1", "0" * 40),
                                 ("candidate", "size", 999),
                                 ("candidate", "filename", "tools.latest.tar.gz"),
                                 ("candidate", "sha256", "0" * 64),
                                 ("authority", "release_revision", "0" * 40)):
            with self.subTest(key=key):
                mutated = copy.deepcopy(self.document)
                mutated["candidates"][self.digest][area][key] = value
                with self.assertRaises(ValueError):
                    self.validate(document=mutated)
        self.archive.write_bytes(b"replaced archive")
        with self.assertRaises(ValueError):
            self.validate()

    def test_changed_inputs_need_explicit_reasoned_retention(self):
        for key, value in (("application_revision", "a" * 40),
                           ("pipeline_revision", "b" * 40), ("lock_sha256", "c" * 64),
                           ("wheels", {"replacement.whl": "d" * 64})):
            with self.subTest(key=key):
                mutated = copy.deepcopy(self.document)
                mutated["candidates"][self.digest]["consumers"][key] = value
                with self.assertRaises(ValueError):
                    self.validate(document=mutated)
        self.record["environments"]["debian"]["runtime"]["loader"] = "e" * 64
        with self.assertRaises(ValueError):
            self.validate()

    def test_unaffected_evidence_keeps_original_run_and_inputs(self):
        original = copy.deepcopy(self.record["results"]["AR1"])
        self.record["consumers"]["application_revision"] = "a" * 40
        current = release.current_inputs(self.record)
        for cell in release.PUBLICATION:
            self.record["assessments"][cell] = {
                "decision": "unaffected", "reason": "Documentation-only application change",
                "previous_inputs": copy.deepcopy(self.record["results"][cell]["inputs"]),
                "current_inputs": copy.deepcopy(current), "captures": ["capture"]}
        self.assertEqual(self.validate(), self.digest)
        self.assertEqual(self.record["results"]["AR1"], original)
        self.record["assessments"]["AR1"]["reason"] = ""
        with self.assertRaises(ValueError):
            self.validate()

    def test_wheel_changes_cannot_retain_old_d10_or_abi(self):
        self.record["consumers"]["wheels"]["fixture.whl"] = "a" * 64
        current = release.current_inputs(self.record)
        for cell in release.PUBLICATION:
            self.record["assessments"][cell] = {
                "decision": "unaffected", "reason": "Claimed harmless wheel change",
                "previous_inputs": copy.deepcopy(self.record["results"][cell]["inputs"]),
                "current_inputs": copy.deepcopy(current), "captures": ["capture"]}
        with self.assertRaises(ValueError):
            self.validate()

    def test_capture_integrity_retention_and_run_are_required(self):
        for change in ("missing", "damaged", "unknown", "local", "escape", "run", "empty"):
            with self.subTest(change=change):
                mutated = copy.deepcopy(self.document)
                record = mutated["candidates"][self.digest]
                if change == "missing":
                    record["captures"]["capture"]["path"] = "absent.txt"
                elif change == "damaged":
                    record["captures"]["capture"]["sha256"] = "0" * 64
                elif change == "unknown":
                    record["results"]["AR1"]["captures"] = ["unknown"]
                elif change == "local":
                    record["captures"]["capture"]["retention"] = "ignored-local"
                elif change == "escape":
                    record["captures"]["capture"]["path"] = "../outside.txt"
                elif change == "run":
                    record["results"]["AR1"]["run"] = ""
                else:
                    record["results"]["AR1"]["captures"] = []
                with self.assertRaises(ValueError):
                    self.validate(document=mutated)

    def test_completion_requires_confirmed_publication_and_adoption(self):
        self.record["publication"].update(state="pass", sha256=self.digest,
                                          sha1=self.record["candidate"]["sha1"], captures=["capture"])
        self.record["adoption"].update(state="pass", recovery="not applicable", captures=["capture"],
                                       pin_revision="a" * 40, configuration_revision="b" * 40)
        for cell in release.COMPLETION:
            self.record["results"][cell]["state"] = "pass"
        self.assertEqual(self.validate("completion"), self.digest)
        for area, field, value in (("publication", "state", "inconclusive"),
                                   ("publication", "sha256", "f" * 64),
                                   ("adoption", "recovery", "pass"),
                                   ("adoption", "state", "fail")):
            mutated = copy.deepcopy(self.document)
            mutated["candidates"][self.digest][area][field] = value
            with self.assertRaises(ValueError):
                self.validate("completion", mutated)

    def test_duplicate_keys_and_nonsanitized_records_refuse(self):
        path = self.root / "record.json"
        path.write_text('{"schema_version":1,"schema_version":1}', encoding="utf-8")
        with self.assertRaises(ValueError):
            release.load(path)
        for text in ("/home/private/person", "C:\\Users\\person", "https://user:secret@host/path",
                     "Authorization: Bearer secret", "password=secret", "secret\nnew line"):
            mutated = copy.deepcopy(self.document)
            mutated["candidates"][self.digest]["validator"]["identity"] = text
            with self.subTest(text=text), self.assertRaises(ValueError):
                release.render(mutated)

    def test_render_is_deterministic_and_includes_pending_cells(self):
        first = release.render(self.document)
        self.assertEqual(first, release.render(copy.deepcopy(self.document)))
        self.assertIn("RA6", first)
        self.assertIn("pending", first)
        self.assertNotIn(str(self.root), first)

    def test_renewal_fallback_and_one_d10_rebuild_are_supported(self):
        self.record["authority"].update(renewed=True, renewal_proof=["capture"])
        self.record["candidate"]["python"] = "3.13.14"
        self.record["candidate"]["regression"]["decision"] = "blocking regression"
        first = self.record["d10"]["readings"][0]
        first["providers"]["11"]["satisfies"] = False
        first["selected_generation"] = 12
        second = copy.deepcopy(first)
        second["generation"] = 12
        self.record["d10"].update(packaged_generation=12, selected_generation=12, readings=[first, second])
        self.assertEqual(self.validate(), self.digest)
        second["selected_generation"] = 11
        with self.assertRaises(ValueError):
            self.validate()

    def test_required_metadata_mutations_fail_closed(self):
        paths = [(area, field) for area in ("candidate", "authority", "consumers", "validator", "d10")
                 for field in self.record[area]]
        paths += [("environments", role) for role in self.record["environments"]]
        for area, field in paths:
            with self.subTest(area=area, field=field):
                mutated = copy.deepcopy(self.document)
                del mutated["candidates"][self.digest][area][field]
                with self.assertRaises(ValueError):
                    self.validate(document=mutated)
        for area, field, value in (("validator", "independent", False),
                                   ("validator", "version", "3.8.20"),
                                   ("candidate", "python", "3.14.0"),
                                   ("candidate", "size", True),
                                   ("d10", "readings", []),
                                   ("publication", "state", "inconclusive")):
            mutated = copy.deepcopy(self.document)
            mutated["candidates"][self.digest][area][field] = value
            with self.assertRaises(ValueError):
                self.validate(document=mutated)

    def test_invalid_schema_types_and_unknown_phase_refuse(self):
        for document in ({"schema_version": 2, "candidates": {}},
                         {"schema_version": 1, "candidates": {"bad": {}}},
                         {"schema_version": 1, "candidates": {}, "extra": 1.5}):
            with self.assertRaises(ValueError):
                release.render(document)
        with self.assertRaises(ValueError):
            self.validate("unknown")

    def test_cli_entry_render_validation_and_refusal(self):
        record = self.root / "record.json"
        record.write_text(json.dumps(self.document), encoding="utf-8")
        args = [str(MODULE), "publication", "--record", str(record), "--archive", str(self.archive),
                "--evidence-root", str(self.root), "--release-revision", REVISION,
                "--capture", str(self.root / "a.local.json"),
                "--coordinate", self.record["publication"]["coordinate"]]
        with patch.object(sys, "argv", args), patch("sys.stdout", new_callable=io.StringIO) as output:
            with self.assertRaises(SystemExit) as exited:
                runpy.run_path(str(MODULE), run_name="__main__")
            self.assertEqual(exited.exception.code, 0)
            self.assertEqual(output.getvalue().strip(), self.digest)
        with patch("sys.stdout", new_callable=io.StringIO) as output:
            self.assertEqual(release.main(["render", "--record", str(record)]), 0)
            self.assertEqual(output.getvalue(), release.render(self.document))
        with patch("sys.stderr", new_callable=io.StringIO):
            self.assertEqual(release.main(["publication", "--record", str(record)]), 1)
            for target in (record, self.archive, self.root / "capture.txt"):
                original = target.read_bytes()
                overwrite = args[1:]
                overwrite[overwrite.index("--capture") + 1] = str(target)
                self.assertEqual(release.main(overwrite), 1)
                self.assertEqual(target.read_bytes(), original)
            bad_coordinate = args[1:-1] + ["releases:org.example:Tool:other:tools"]
            self.assertEqual(release.main(bad_coordinate), 1)
            record.write_text("{", encoding="utf-8")
            self.assertEqual(release.main(args[1:]), 1)

    def test_cli_reports_digest_and_local_independent_interpreter(self):
        record = self.root / "record.json"
        record.write_text(json.dumps(self.document), encoding="utf-8")
        capture = self.root / "local.json"
        args = [sys.executable, str(MODULE), "publication", "--record", str(record),
                "--archive", str(self.archive), "--evidence-root", str(self.root),
                "--release-revision", REVISION, "--capture", str(capture)]
        result = subprocess.run(args, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), self.digest)
        observed = json.loads(capture.read_text())
        self.assertEqual(observed["interpreter"], sys.executable)
        self.assertEqual(observed["record_reads"], 1)
        self.assertEqual(observed["capture_reads"], 1)
        self.assertGreaterEqual(observed["elapsed_seconds"], 0)
        self.archive.write_bytes(b"another archive")
        result = subprocess.run(args, capture_output=True, text=True, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
