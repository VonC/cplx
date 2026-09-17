"""Exercise real publication entry ordering and promoted digest binding on Linux.

Only the inherited closure-content checks are stubbed here; their full existing
suite runs separately. Promotion, descriptor snapshots and streaming stay real.
The spy adapter records its load as well as every call, with no network access.
"""

import copy
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

from .test_tools_release_record_tdd import ROOT, REVISION, release, valid_record


class ReleasePublicationTests(unittest.TestCase):
    """Prove invalid eligibility never loads an uploader or runs a preflight."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tools-entry-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "stage").mkdir(mode=0o700)
        app = Path(os.environ["TOOLS_TEST_APP"])
        self.app = self.root / "app/tools"
        self.app.mkdir(parents=True)
        shutil.copyfile(app / "tools/publish_pdf_nexus.sh", self.app / "publish_pdf_nexus.sh")
        self.repo = self.root / "cplx"
        self.bin = self.repo / "src/setups/env/bin"
        shutil.copytree(ROOT / "src/setups/env/bin", self.bin)
        gate = self.bin / "closure_publish.sh"
        source = gate.read_text()
        self.assertIn("# --- MAIN BOUNDARY ---", source)
        stubs = '''closure_publish_step1() { CLOSURE_PUBLISH_CONFIG_DIGEST=fixture; }
closure_publish_step2() { return 0; }
closure_publish_step34() { return 0; }
'''
        gate.write_text(source.replace("# --- MAIN BOUNDARY ---", stubs + "# --- MAIN BOUNDARY ---"))
        adapter = self.app / "tools_release_adapter.sh"
        adapter.write_text('''printf 'loaded\\n' >> "$SPY_LOG"
upload_begin() { printf 'begin\\n' >> "$SPY_LOG"; printf 'fixture'; }
upload_write() { printf 'write\\n' >> "$SPY_LOG"; cat > "$SPY_BYTES"; }
upload_commit() { printf 'commit\\n' >> "$SPY_LOG"; }
upload_abort() { printf 'abort\\n' >> "$SPY_LOG"; }
''')
        self.archive = self.root / "tools.20260917_120000.tar.gz"
        self.archive.write_bytes(b"first eligible archive")
        self.document = valid_record(self.archive, self.root)
        self.digest = next(iter(self.document["candidates"]))
        self.record = self.root / "record.json"
        self.log = self.root / "spy.log"
        self.bytes = self.root / "uploaded"
        self.env = dict(os.environ, TOOLS_RELEASE_PYTHON=sys.executable,
                        NEXUS_URL="https://invalid.example", NEXUS_REPO="releases",
                        GROUP="org.example", ARTIFACT="Tool", REPO_ID="fixture",
                        CLOSURE_PUBLISH_STAGING=str(self.root / "stage"),
                        SPY_LOG=str(self.log), SPY_BYTES=str(self.bytes),
                        MVN="/must-not-run-maven")
        self.env.pop("CPLX_TOOLS_RELEASE", None)
        self.args = ["bash", str(self.app / "publish_pdf_nexus.sh"), str(self.archive),
                     "--with-tools", "--version", "1.2.3", "--yes",
                     "--release-record", str(self.record), "--evidence-root", str(self.root),
                     "--cplx-repo", str(self.repo), "--release-revision", REVISION,
                     "--closure-results", str(self.root / "closure-results"),
                     "--validator-capture", str(self.root / "a.validator.json")]

    def run_entry(self):
        self.record.write_text(json.dumps(self.document))
        return subprocess.run(self.args, env=self.env, capture_output=True, text=True, timeout=10)

    def assert_refused_without_adapter(self, result):
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertFalse(self.log.exists(), result.stdout + result.stderr)
        self.assertFalse(self.bytes.exists())

    def test_eligible_record_streams_exact_bytes(self):
        result = self.run_entry()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.bytes.read_bytes(), self.archive.read_bytes())
        self.assertEqual(self.log.read_text().splitlines(), ["loaded", "begin", "write", "commit"])
        capture = json.loads((self.root / "a.validator.json").read_text())
        self.assertEqual(capture["sha1"], hashlib.sha1(self.bytes.read_bytes()).hexdigest())

    def test_missing_failed_and_mismatched_eligibility_never_load_adapter(self):
        baseline = copy.deepcopy(self.document)
        for mutation in ("missing", "pending", "fail", "inconclusive", "digest", "revision", "coordinate"):
            with self.subTest(mutation=mutation):
                self.document = copy.deepcopy(baseline)
                record = self.document["candidates"][self.digest]
                if mutation == "missing":
                    del record["results"]["PA9:debian"]
                elif mutation in {"pending", "fail", "inconclusive"}:
                    record["results"]["PA9:debian"]["state"] = mutation
                elif mutation == "digest":
                    record["candidate"]["sha256"] = "f" * 64
                elif mutation == "revision":
                    record["authority"]["release_revision"] = "f" * 40
                else:
                    record["publication"]["coordinate"] = "releases:org.example:Tool:2.0:tools"
                self.assert_refused_without_adapter(self.run_entry())

    def test_archive_replacement_after_validation_is_refused(self):
        validator = self.bin / "tools_release_record.py"
        original = self.root / "original_validator.py"
        validator.rename(original)
        validator.write_text('import runpy, sys\nfrom pathlib import Path\n'
                             f'm = runpy.run_path({str(original)!r})\n'
                             'rc = m["main"]()\n'
                             f'Path({str(self.archive)!r}).write_bytes(b"other closure-valid candidate")\n'
                             'sys.exit(rc)\n')
        result = self.run_entry()
        self.assert_refused_without_adapter(result)
        self.assertIn("expected release-record SHA-256", result.stderr)

    def test_empty_validator_output_is_not_eligibility(self):
        (self.bin / "tools_release_record.py").write_text("# Empty successful command is not a digest.\n")
        result = self.run_entry()
        self.assert_refused_without_adapter(result)
        self.assertIn("no valid expected SHA-256", result.stderr)

    def test_omitted_gate_guard_refuses_in_tools_mode(self):
        publisher = self.app / "publish_pdf_nexus.sh"
        source = publisher.read_text()
        guard = '--expected-sha256 "$EXPECTED_SHA256"'
        self.assertIn(guard, source)
        publisher.write_text(source.replace(guard, ""))
        result = self.run_entry()
        self.assert_refused_without_adapter(result)
        self.assertIn("explicit expected SHA-256", result.stderr)

    def test_other_gate_callers_keep_optional_guard_compatibility(self):
        result = subprocess.run(["bash", str(self.bin / "closure_publish.sh"),
                                 "--archive", str(self.archive), "--commit", REVISION,
                                 "--repo", str(self.repo), "--results", str(self.root),
                                 "--adapter", str(self.app / "tools_release_adapter.sh")],
                                env=self.env, capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.bytes.read_bytes(), self.archive.read_bytes())


if __name__ == "__main__":
    unittest.main()
