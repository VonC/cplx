"""Acceptance runs require fresh observations, real exit codes and exact bytes."""

from contextlib import redirect_stderr, redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

from tests.unit.deploy_venv_sync.test_ci_evidence import test_ci_evidence_tdd as ci_fixture


DRIVER = Path(__file__).resolve().parents[4] / "docs/v0.27.0/acceptance_deploy_venv_sync.py"


class AcceptanceEvidenceTest(unittest.TestCase):
    """Reject stand-in successes and retain diagnostics for failed native cases."""

    def setUp(self):
        spec = importlib.util.spec_from_file_location("acceptance", DRIVER)
        self.driver = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.driver)
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.binding = {"record_sha256": "a" * 64, "tools_sha256": "b" * 64}
        self.worker = self.root / "worker.py"
        self.worker.write_text('''import hashlib, json, os, pathlib, sys
root = pathlib.Path(os.environ["DVS_ACCEPTANCE_OUTPUT"])
request = json.loads((root / "request.json").read_text())
mode = sys.argv[1]
if mode == "silent":
    raise SystemExit(0)
raw = root / "observed.txt"
raw.write_text("subprocess observation\\n")
checks = {name: {"path": str(raw), "sha256": hashlib.sha256(raw.read_bytes()).hexdigest()}
          for name in request["required_checks"]}
result = {"schema": 1, "run_id": request["run_id"], "case": request["case"],
          "candidate": request["candidate"], "checks": checks}
if mode == "stale": result["run_id"] = "old"
if mode == "wrong": result["candidate"]["record_sha256"] = "c" * 64
if mode == "missing": result["checks"].pop(next(iter(checks)))
if mode == "changed": raw.write_text("changed")
if mode == "empty":
    raw.write_bytes(b"")
    for item in checks.values(): item["sha256"] = hashlib.sha256(b"").hexdigest()
(root / "observation.json").write_text(json.dumps(result))
print("executed real subprocess", mode)
raise SystemExit(17 if mode == "failed" else 0)
''', encoding="utf-8")

    def run_case(self, mode="valid", case="fresh", expected_exit=0):
        return self.driver.run_case(
            case, [sys.executable, str(self.worker), mode], expected_exit,
            self.binding, self.root / "evidence", fixture=True)

    def test_subprocess_records_exact_command_exit_and_bound_observations(self):
        result = self.run_case()
        self.assertEqual(result["status"], "passed")
        self.assertEqual(result["returncode"], 0)
        self.assertEqual(result["candidate"], self.binding)
        self.assertEqual(result["command"][0], sys.executable)
        self.assertFalse(result["qualifying"])
        self.assertIn("executed real subprocess", Path(result["log"]).read_text())

    def test_successful_exit_without_observations_is_not_acceptance(self):
        with self.assertRaisesRegex(ValueError, "observation"):
            self.run_case("silent")
        self.assertTrue(list((self.root / "evidence").glob("*/result.json")))

    def test_nonzero_exit_is_not_masked_by_success_observations(self):
        with self.assertRaisesRegex(ValueError, "exit"):
            self.run_case("failed")
        result_path = next((self.root / "evidence").glob("*/result.json"))
        result = json.loads(result_path.read_text())
        self.assertEqual(result["returncode"], 17)
        self.assertEqual(result["status"], "failed")

    def test_negative_case_requires_its_explicit_failure_status(self):
        self.assertEqual(self.run_case("failed", "missing-inputs", 17)["status"], "passed")
        with self.assertRaisesRegex(ValueError, "exit"):
            self.run_case("valid", "missing-inputs", 17)

    def test_freshness_binding_completeness_and_bytes_fail_closed(self):
        for mode in ("stale", "wrong", "missing", "changed", "empty"):
            with self.subTest(mode=mode), self.assertRaises(ValueError):
                self.run_case(mode)

    def test_unknown_case_and_invalid_expected_status_fail_before_execution(self):
        for case, status in (("invented", 0), ("fresh", 17), ("missing-inputs", 0),
                             ("fresh", True), ("missing-inputs", -1)):
            with self.subTest(case=case, status=status), self.assertRaises(ValueError):
                self.run_case(case=case, expected_exit=status)
        self.assertFalse((self.root / "evidence").exists())

    def test_all_design_rows_and_acceptance_criteria_have_cases(self):
        requirements = set().union(*(set(row["requirements"]) for row in self.driver.CASES.values()))
        self.assertEqual(requirements, {"AC%02d" % n for n in range(1, 16)} | {"AC10a", "AC10b"})
        for case in ("rollback-venv-free", "rollback-shipped-venv", "serialization",
                     "wrong-qualification", "retention", "consumer-delivery", "promotion"):
            self.assertIn(case, self.driver.CASES)

    def test_duplicate_observation_fields_and_escaped_evidence_are_rejected(self):
        self.worker.write_text('''import json, os, pathlib
root = pathlib.Path(os.environ["DVS_ACCEPTANCE_OUTPUT"])
(root / "observation.json").write_text('{"schema":1,"schema":1}')
''', encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "duplicate"):
            self.run_case()
        outside = self.root / "outside.txt"
        outside.write_text("outside")
        with self.assertRaisesRegex(ValueError, "outside"):
            self.driver.evidence_file({"path": str(outside), "sha256": "a" * 64}, self.root / "evidence")

    def candidate_fixture(self):
        """Reuse byte-valid CI inputs for preflight checks, never qualification."""
        fixture = ci_fixture.CiEvidenceTest()
        fixture.setUp()
        self.addCleanup(fixture.doCleanups)
        ci = fixture.root / "ci.json"
        ci.write_text(json.dumps(fixture.evidence))
        candidate = {"schema": 1, "identity": fixture.release.sha256(fixture.record),
                     "state": "retained", "expires_at": None,
                     "record": str(fixture.record),
                     "files": {key: str(path) for key, path in fixture.files.items()},
                     "ci_evidence": str(ci), "coverage": str(fixture.coverage),
                     "predecessors": None}
        path = fixture.root / "candidate.json"
        path.write_text(json.dumps(candidate))
        return path, candidate, fixture

    def test_candidate_binding_rechecks_ci_and_local_bytes(self):
        path, candidate, fixture = self.candidate_fixture()
        binding = self.driver.candidate_binding(path)
        self.assertEqual(binding["record_sha256"], candidate["identity"])
        self.assertEqual(binding["profile_sha256"], fixture.evidence["candidate"]["profile_sha256"])
        self.assertIsNone(binding["predecessors"])
        fixture.files["tools"].write_bytes(b"different archive with the same name")
        with self.assertRaisesRegex(ValueError, "changed local input: tools"):
            self.driver.candidate_binding(path)

    def test_published_binding_requires_explicit_observation_mode(self):
        path, candidate, fixture = self.candidate_fixture()
        fixture.evidence["phase2"]["publish_status"] = "published"
        Path(candidate["ci_evidence"]).write_text(json.dumps(fixture.evidence))
        with self.assertRaisesRegex(ValueError, "mandated stages"):
            self.driver.candidate_binding(path)
        observed = self.driver.candidate_binding(path, published=True)
        self.assertEqual(observed["ci_publication"], "published")
        self.assertEqual(observed["record_sha256"], candidate["identity"])
        fixture.evidence["phase2"]["inventory_after_sha256"] = "f" * 64
        Path(candidate["ci_evidence"]).write_text(json.dumps(fixture.evidence))
        with self.assertRaisesRegex(ValueError, "inventory drift"):
            self.driver.candidate_binding(path, published=True)

    def invoke_main(self, candidate, plan, evidence, *options):
        """Exercise native entry gates on every test host with real adapters."""
        argv = [str(DRIVER), "--candidate-manifest", str(candidate),
                "--acceptance-plan", str(plan), "--evidence-root", str(evidence), *options]
        stdout, stderr = io.StringIO(), io.StringIO()
        with (patch.object(sys, "argv", argv),
              patch.object(self.driver.platform, "system", return_value="Linux"),
              redirect_stdout(stdout), redirect_stderr(stderr)):
            status = self.driver.main()
        return status, stdout.getvalue(), stderr.getvalue()

    def test_missing_inputs_recovery_and_unauthorized_promotion_never_run_adapter(self):
        path, _, fixture = self.candidate_fixture()
        evidence = self.root / "native-results"
        reasons = {
            "rollback-shipped-venv": "recovery cases require verified predecessor inputs",
            "promotion": "promotion requires explicit publication authorization",
            "fresh": "missing or unsafe local input",
        }
        for case, reason in reasons.items():
            with self.subTest(case=case):
                if case == "fresh":
                    fixture.files["tools"].unlink()
                plan = self.root / (case + ".json")
                plan.write_text(json.dumps({"schema": 1, "cases": {
                    case: {"command": [sys.executable, str(self.worker), "valid"],
                           "expected_exit": 0}}}))
                with patch.object(self.driver, "run_case", wraps=self.driver.run_case) as adapter:
                    status, stdout, stderr = self.invoke_main(path, plan, evidence)
                self.assertEqual(status, 2, stderr)
                self.assertEqual(stderr, "acceptance refused: " + reason + "\n")
                self.assertEqual(stdout, "")
                adapter.assert_not_called()
                self.assertFalse(evidence.exists())

    def test_main_writes_incomplete_native_summary_for_dry_run_and_published_inputs(self):
        for published in (False, True):
            with self.subTest(published=published):
                path, candidate, fixture = self.candidate_fixture()
                options = ("--published-candidate",) if published else ()
                if published:
                    fixture.evidence["phase2"]["publish_status"] = "published"
                    Path(candidate["ci_evidence"]).write_text(json.dumps(fixture.evidence))
                evidence = self.root / ("published" if published else "dry-run")
                plan = self.root / "success.json"
                plan.write_text(json.dumps({"schema": 1, "cases": {
                    "fresh": {"command": [sys.executable, str(self.worker), "valid"],
                              "expected_exit": 0}}}))
                status, stdout, stderr = self.invoke_main(path, plan, evidence, *options)
                self.assertEqual(status, 0, stderr)
                self.assertEqual(stderr, "")
                summaries = list(evidence.glob("acceptance-*.json"))
                self.assertEqual(len(summaries), 1)
                self.assertEqual(stdout.strip(), str(summaries[0]))
                summary = json.loads(summaries[0].read_text())
                self.assertFalse(summary["complete"])
                self.assertEqual(set(summary["missing"]), set(self.driver.CASES) - {"fresh"})
                self.assertEqual(len(summary["missing"]), 26)
                self.assertEqual(summary["candidate"]["record_sha256"], candidate["identity"])
                if published:
                    self.assertEqual(summary["candidate"]["ci_publication"], "published")
                else:
                    self.assertNotIn("ci_publication", summary["candidate"])
                self.assertEqual(len(summary["results"]), 1)
                result = summary["results"][0]
                self.assertEqual(result["candidate"], summary["candidate"])
                self.assertEqual(result["status"], "passed")
                self.assertEqual(result["returncode"], 0)
                self.assertTrue(result["qualifying"])
                self.assertFalse(result["fixture"])


if __name__ == "__main__":
    unittest.main()
