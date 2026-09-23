"""Exercise real publication entry ordering and promoted digest binding on Linux.

Only the inherited closure-content checks are stubbed here; their full existing
suite runs separately. Promotion, descriptor snapshots and streaming stay real.
The spy adapter records its load as well as every call, with no network access.
Step 7 also composes the real TLS adapter and normal-pin downloader against the
isolated repository, then checks completion and immutable collision refusal.
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


@unittest.skipUnless(sys.platform.startswith("linux"), "requires native Linux shell paths")
class ReleasePublicationTests(unittest.TestCase):
    """Bind eligibility, streaming, retrieval and completion on native Linux."""

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

    def test_transaction_normal_pin_retrieval_and_completion(self):
        from tests.unit.tools_release_transport.test_tools_release_transport import (
            test_tools_release_transport_tdd as transport,
        )

        # Reuse the existing isolated HTTPS backend. Its assets stay private
        # until the real adapter terminates the verified streaming request.
        transport.TransportTests.setUpClass()
        self.addCleanup(transport.TransportTests.tearDownClass)
        backend = transport.TransportTests()
        backend.setUp()
        self.addCleanup(backend.doCleanups)
        app = Path(os.environ["TOOLS_TEST_APP"])
        for name in ("tools_release_adapter.sh", "tools_release_http.py", "tools_release_transport.py"):
            shutil.copyfile(app / "tools" / name, self.app / name)
        self.env.update(backend.env)
        self.env["VERSION"] = "1.2.3"
        result = self.run_entry()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(backend.server.asset, self.archive.read_bytes())

        # Independent bundle delivery has its own composed fixture suite. Only
        # that network operation is replaced here; source selection, the URL
        # from tools.version, TLS download and digest capture remain real.
        workspace = self.app.parent
        ci = workspace / "ci"
        ci.mkdir()
        for name in ("tools_candidate.sh", "provision_toolchain.sh", "tools_agent_identity.sh"):
            shutil.copyfile(app / "ci" / name, ci / name)
        with (ci / "tools_candidate.sh").open("a") as stream:
            stream.write('''
tools_verification_fetch() {
    mkdir -p "$2"
    printf 'revision=fixture\\narchive_sha256=release-pin\\n' > "$2/identity"
    printf 'fixture\\n' > "$2/verification.sha256"
}
''')
        (self.app / "tools.verification").write_text(
            "bundle_url=https://invalid.example/bundle\nbundle_sha256=" + "a" * 64
            + "\nrevision=" + "b" * 40 + "\n")
        (self.app / "tools.version").write_text("1.2.3\n")
        (self.app / "publish.mode").write_text("off\n")
        # This native fixture has no Docker executor. Supply only the identity
        # command; actual Jenkins acceptance still requires its real image.
        fixture_bin = self.root / "fixture-bin"
        fixture_bin.mkdir()
        docker = fixture_bin / "docker"
        docker.write_text("#!/bin/bash\n[[ $1 == inspect && $2 == --format && $3 == '{{.Image}}' ]] || exit 2\n"
                          "printf 'sha256:" + "c" * 64 + "\\n'\n")
        docker.chmod(0o755)
        env = dict(self.env, WORKSPACE=str(workspace), PREFIX=str(self.root / "prefix"),
                   PATH=str(fixture_bin) + os.pathsep + os.environ["PATH"],
                   DOCKER_CONTAINER_ID="d" * 64,
                   PUBLISH_MODE="off", CA_BUNDLE=str(backend.cert),
                   NEXUS_RELEASES=backend.env["NEXUS_URL"] + "/repository/releases",
                   TOOLS_GAV_DIR="org/example/Tool/1.2.3")
        for key in ("TOOLS_VERSION", "TOOLS_VALIDATION_ASSET", "TOOLS_VALIDATION_SHA256"):
            env.pop(key, None)
        result = subprocess.run(["bash", str(ci / "provision_toolchain.sh"), "fetch"],
                                env=env, capture_output=True, text=True, timeout=15)
        self.assertEqual(result.returncode, 0, result.stderr)
        downloaded = self.root / "prefix/pkgs/tools.1.2.3.tar.gz"
        self.assertEqual(downloaded.read_bytes(), self.archive.read_bytes())
        self.assertIn(self.digest, (workspace / "a.evidence/release-archive.sha256").read_text())
        self.assertIn(("GET", "/repository/releases/org/example/Tool/1.2.3/PDF-1.2.3-tools.tar.gz"),
                      backend.server.events)

        record = self.document["candidates"][self.digest]
        record["publication"].update(state="pass", sha256=self.digest,
                                     sha1=hashlib.sha1(downloaded.read_bytes()).hexdigest(), captures=["capture"])
        with self.assertRaises(ValueError):
            release.validate(self.document, self.archive, self.root, REVISION, "completion")
        record["adoption"].update(state="pass", recovery="not applicable", captures=["capture"],
                                  pin_revision="a" * 40, configuration_revision="b" * 40)
        for cell in release.COMPLETION:
            record["results"][cell]["state"] = "pass"
        self.assertEqual(release.validate(self.document, self.archive, self.root, REVISION, "completion"),
                         self.digest)

        # A different immutable asset is never overwritten, even with an
        # otherwise eligible local record and a fresh adapter journal.
        record["publication"].update(state="pending", sha256="", sha1="", captures=[])
        record["adoption"].update(state="pending", recovery="pending")
        backend.server.asset = b"existing different immutable bytes"
        self.env["TOOLS_RELEASE_STATE_DIR"] = str(self.root / "fresh-journal")
        puts = sum(method == "PUT" for method, _ in backend.server.events)
        self.assertNotEqual(self.run_entry().returncode, 0)
        self.assertEqual(sum(method == "PUT" for method, _ in backend.server.events), puts)
        self.assertEqual(backend.server.asset, b"existing different immutable bytes")

    def test_recovery_restores_the_pin_and_compatible_configuration_together(self):
        # Execute the recovery procedure on an owned Git tree. Restoring only
        # the pin must fail the same exact-tree comparison used by the operator.
        workspace = self.root / "recovery"
        workspace.mkdir()
        env = dict(os.environ, GIT_AUTHOR_NAME="fixture", GIT_AUTHOR_EMAIL="fixture@example.invalid",
                   GIT_COMMITTER_NAME="fixture", GIT_COMMITTER_EMAIL="fixture@example.invalid")

        def git(*args):
            return subprocess.run(["git", "-C", str(workspace), *args], env=env,
                                  capture_output=True, text=True, check=False, timeout=10)

        self.assertEqual(git("init", "-q").returncode, 0)
        (workspace / "tools").mkdir()
        (workspace / "tools/tools.version").write_text("0.9.0\n")
        (workspace / "tools/publish.mode").write_text("off\n")
        (workspace / "Jenkinsfile").write_text("compatible prior pipeline\n")
        self.assertEqual(git("add", ".").returncode, 0)
        self.assertEqual(git("commit", "-qm", "retained coherent configuration").returncode, 0)
        prior = git("rev-parse", "HEAD").stdout.strip()
        (workspace / "tools/tools.version").write_text("1.2.3\n")
        (workspace / "Jenkinsfile").write_text("new incompatible pipeline\n")
        self.assertEqual(git("add", ".").returncode, 0)
        self.assertEqual(git("commit", "-qm", "attempted adoption").returncode, 0)
        self.assertEqual(git("restore", "--source", prior, "--", "tools/tools.version").returncode, 0)
        self.assertNotEqual(git("diff", "--quiet", prior, "--", ".").returncode, 0)
        self.assertEqual(git("restore", "--source", prior, "--staged", "--worktree", "--", ".").returncode, 0)
        self.assertEqual(git("diff", "--quiet", prior, "--", ".").returncode, 0)
        self.assertEqual((workspace / "tools/publish.mode").read_text(), "off\n")
        # Even a coherent restored tree does not establish accepted adoption.
        record = self.document["candidates"][self.digest]
        record["publication"].update(state="pass", sha256=self.digest,
                                     sha1=hashlib.sha1(self.archive.read_bytes()).hexdigest(), captures=["capture"])
        record["adoption"].update(state="fail", recovery="pass", captures=["capture"],
                                  pin_revision=prior, configuration_revision=prior)
        with self.assertRaises(ValueError):
            release.validate(self.document, self.archive, self.root, REVISION, "completion")


if __name__ == "__main__":
    unittest.main()
