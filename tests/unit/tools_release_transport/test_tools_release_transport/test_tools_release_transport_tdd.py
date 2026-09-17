"""Test the real adapter against an isolated TLS repository, without live writes.

These are process integration fixtures using unittest, not unit coverage claims.
The finite outcome matrix needs no additional property-testing dependency.
"""

import hashlib
import http.server
import io
import json
import os
from pathlib import Path
import re
import socket
import ssl
import subprocess
import sys
import tarfile
import tempfile
import threading
import unittest


APP = Path(os.environ.get("TOOLS_TEST_APP", "/missing-app"))
CPLX = Path(__file__).resolve().parents[4]
PAYLOAD = b"verified archive bytes\n" * 4000
DIGEST = hashlib.sha256(PAYLOAD).hexdigest()


class Repository(http.server.BaseHTTPRequestHandler):
    """Keep unfinished bodies private and inject final-response failures."""

    protocol_version = "HTTP/1.1"

    def log_message(self, *_args):
        pass

    def answer(self, status, body=b""):
        self.send_response(status)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)

    def do_HEAD(self):
        self.server.events.append(("HEAD", self.path))
        self.answer(200 if self.server.asset is not None else 404)

    def do_GET(self):
        self.server.events.append(("GET", self.path))
        if self.server.mode == "unavailable":
            self.answer(503)
        elif self.server.mode == "absent" or self.server.asset is None:
            self.answer(404)
        else:
            self.answer(200, self.server.asset)

    def do_PUT(self):
        self.server.events.append(("PUT", self.path))
        chunks = []
        while True:
            try:
                line = self.rfile.readline()
            except ConnectionResetError:
                line = b""
            if not line:
                self.server.events.append(("ABORT", self.path))
                return
            size = int(line.strip(), 16)
            if size == 0:
                self.rfile.readline()
                break
            chunks.append(self.rfile.read(size))
            self.rfile.read(2)
            if self.server.mode == "partial":
                self.connection.shutdown(socket.SHUT_RDWR)
                self.connection.close()
                return
        self.server.events.append(("COMMIT", self.path))
        if self.server.asset is not None:
            self.answer(400)
            return
        self.server.asset = b"different" if self.server.mode == "mismatch" else b"".join(chunks)
        if self.server.mode == "hold":
            self.server.committed.set()
            self.server.release.wait(5)
        if self.server.mode in {"lost", "unavailable", "absent", "mismatch", "hold"}:
            self.connection.shutdown(socket.SHUT_RDWR)
            self.connection.close()
        elif self.server.mode == "malformed":
            self.connection.sendall(b"BROKEN\r\n\r\n")
            self.connection.close()
        else:
            self.answer(500 if self.server.mode == "error" else 201)


class TransportTests(unittest.TestCase):
    """Assert privacy, byte binding and mandatory response-loss reconciliation."""

    @classmethod
    def setUpClass(cls):
        if not (APP / "tools/tools_release_adapter.sh").is_file():
            raise AssertionError("application tools release adapter is missing")
        cls.suite = tempfile.TemporaryDirectory(prefix="tools-contract-")
        root = Path(cls.suite.name)
        cls.cert = root / "cert.pem"
        key = root / "key.pem"
        subprocess.run([
            "openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes",
            "-keyout", str(key), "-out", str(cls.cert), "-days", "1",
            "-subj", "/CN=localhost", "-addext", "subjectAltName=DNS:localhost",
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        cls.server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Repository)
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cls.cert, key)
        cls.server.socket = context.wrap_socket(cls.server.socket, server_side=True)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()
        cls.suite.cleanup()

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=self.suite.name)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        settings = self.root / "settings.xml"
        settings.write_text("<settings><servers><server><id>fixture</id>"
                            "<username>fixture</username><password>fixture</password>"
                            "</server></servers></settings>", encoding="utf-8")
        self.server.asset = None
        self.server.events = []
        self.server.mode = "ok"
        self.server.committed = threading.Event()
        self.server.release = threading.Event()
        self.env = dict(os.environ, NEXUS_URL=f"https://localhost:{self.server.server_port}",
                        NEXUS_REPO="releases", GROUP="org.example", ARTIFACT="Tool",
                        VERSION="probe", REPO_ID="fixture", MAVEN_SETTINGS=str(settings),
                        TOOLS_RELEASE_STATE_DIR=str(self.root / "state"),
                        TOOLS_RELEASE_PYTHON=sys.executable, SSL_CERT_FILE=str(self.cert),
                        TOOLS_RELEASE_TIMEOUT="2")
        self.handles = []
        self.addCleanup(self.abort_active)

    def call(self, action, handle=None, data=None):
        args = ["bash", str(APP / "tools/tools_release_adapter.sh"), action]
        if handle:
            args.append(handle)
        return subprocess.run(args, input=data, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE, env=self.env, timeout=15)

    def begin_write(self):
        result = self.call("begin")
        self.assertEqual(result.returncode, 0, result.stderr)
        handle = result.stdout.decode().strip()
        self.handles.append(handle)
        self.assertTrue(Path(handle).is_dir())
        result = self.call("write", handle, PAYLOAD)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIsNone(self.server.asset, "write made bytes public before commit")
        return handle

    def abort_active(self):
        for handle in self.handles:
            self.call("abort", handle)

    def test_private_write_and_abort(self):
        handle = self.begin_write()
        result = self.call("abort", handle)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIsNone(self.server.asset)
        self.assertFalse(any(verb == "COMMIT" for verb, _ in self.server.events))

    def test_valid_acknowledgement(self):
        handle = self.begin_write()
        self.assertEqual(self.call("commit", handle).returncode, 0)
        self.assertEqual(self.server.asset, PAYLOAD)
        self.assertNotEqual(self.call("begin").returncode, 0)

    def test_missing_unusable_and_error_replies_require_readback(self):
        for mode in ("lost", "malformed", "error"):
            with self.subTest(mode=mode):
                self.env["VERSION"] = mode
                self.server.asset = None
                self.server.events = []
                self.server.mode = mode
                handle = self.begin_write()
                result = self.call("commit", handle)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.server.asset, PAYLOAD)
                self.assertIn(("GET", self.server.events[0][1]), self.server.events)
                self.assertEqual(json.loads((Path(handle) / "attempt.json").read_text())["phase"], "COMMITTED")
                self.assertNotEqual(self.call("begin").returncode, 0)
                self.call("abort", handle)
                self.assertEqual(self.server.asset, PAYLOAD, "cleanup deleted committed bytes")

    def test_inconclusive_checks_block_retry_and_support_readonly_recovery(self):
        for mode in ("unavailable", "absent", "mismatch"):
            with self.subTest(mode=mode):
                self.env["VERSION"] = mode
                self.server.asset = None
                self.server.events = []
                self.server.mode = mode
                handle = self.begin_write()
                result = self.call("commit", handle)
                self.assertEqual(result.returncode, 3, result.stderr)
                self.assertIn(b"unresolved", result.stderr.lower())
                self.assertNotEqual(self.call("begin").returncode, 0)
                self.assertEqual(sum(verb == "PUT" for verb, _ in self.server.events), 1)
                self.assertNotEqual(self.call("abort", handle).returncode, 0)
                self.server.mode = "ok"
                self.server.asset = PAYLOAD
                self.assertEqual(self.call("reconcile", handle).returncode, 0)
                self.assertEqual(sum(verb == "PUT" for verb, _ in self.server.events), 1)

    def test_existing_coordinate_is_never_overwritten(self):
        self.server.asset = b"existing"
        self.assertNotEqual(self.call("begin").returncode, 0)
        self.assertEqual(self.server.asset, b"existing")
        self.assertFalse(any(verb == "PUT" for verb, _ in self.server.events))

    def test_unreadable_credentials_during_readback_retain_unknown_attempt(self):
        self.server.mode = "lost"
        handle = self.begin_write()
        settings = Path(self.env["MAVEN_SETTINGS"])
        original = settings.read_bytes()
        settings.write_text("<broken>", encoding="utf-8")
        result = self.call("commit", handle)
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertEqual(self.server.asset, PAYLOAD)
        self.assertEqual(json.loads((Path(handle) / "attempt.json").read_text())["phase"], "UNKNOWN")
        self.assertNotEqual(self.call("begin").returncode, 0)
        settings.write_bytes(original)
        self.assertEqual(self.call("reconcile", handle).returncode, 0)
        self.assertEqual(sum(verb == "PUT" for verb, _ in self.server.events), 1)

    def test_interrupted_commit_caller_recovers_without_republication(self):
        self.server.mode = "hold"
        handle = self.begin_write()
        process = subprocess.Popen(["bash", str(APP / "tools/tools_release_adapter.sh"),
                                    "commit", handle], env=self.env, start_new_session=True,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            self.assertTrue(self.server.committed.wait(3), "commit never reached backend")
            receipt = json.loads((Path(handle) / "attempt.json").read_text())
            self.assertEqual(receipt["phase"], "COMMITTING")
            self.assertEqual(receipt["digest"], DIGEST)
            os.killpg(process.pid, 15)
            process.communicate(timeout=3)
        finally:
            self.server.release.set()
            if process.poll() is None:
                os.killpg(process.pid, 9)
                process.communicate(timeout=3)
        # The surviving worker or cleanup must reconcile durable commit intent.
        self.assertEqual(self.call("abort", handle).returncode, 3)
        self.assertEqual(self.call("reconcile", handle).returncode, 0)
        self.assertNotEqual(self.call("begin").returncode, 0)
        self.assertEqual(self.server.asset, PAYLOAD)
        self.assertEqual(sum(verb == "PUT" for verb, _ in self.server.events), 1)
        self.assertTrue(any(verb == "GET" for verb, _ in self.server.events))

    def gate(self, expected):
        archive = self.root / "archive"
        archive.write_bytes(PAYLOAD)
        self.env.update(TEST_ARCHIVE=str(archive), TEST_EXPECTED=expected,
                        TEST_GATE=str(CPLX / "src/setups/env/bin/closure_publish.sh"),
                        TEST_ADAPTER=str(APP / "tools/tools_release_adapter.sh"),
                        CLOSURE_PUBLISH_STAGING=str(self.root))
        return subprocess.run(["bash", "-c", 'source "$TEST_GATE"; source "$TEST_ADAPTER"; '
                               'exec {CPLX_CLOSURE_ARCHIVE_FD}<"$TEST_ARCHIVE"; '
                               'closure_publish_upload "$TEST_EXPECTED"'], env=self.env,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=15)

    def test_gate_digest_failure_aborts_before_commit(self):
        result = self.gate("0" * 64)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b"streamed bytes differ", result.stderr)
        self.assertIsNone(self.server.asset)

    def test_partial_remote_write_never_commits(self):
        self.server.mode = "partial"
        result = self.gate(DIGEST)
        self.assertNotEqual(result.returncode, 0)
        self.assertIsNone(self.server.asset)
        self.assertFalse(any(verb == "COMMIT" for verb, _ in self.server.events))

    def test_interruption_aborts_unfinished_stage(self):
        marker = self.root / "ready"
        self.env.update(TEST_GATE=str(CPLX / "src/setups/env/bin/closure_publish.sh"),
                        TEST_ADAPTER=str(APP / "tools/tools_release_adapter.sh"),
                        TEST_MARKER=str(marker), CLOSURE_PUBLISH_STAGING=str(self.root))
        # Exercise the gate's actual trap after the adapter has a private stream.
        script = ('source "$TEST_GATE"; source "$TEST_ADAPTER"; '
                  'CLOSURE_PUBLISH_STAGE=$(upload_begin) || exit; '
                  'CLOSURE_PUBLISH_COMMITTED=0; trap closure_publish_cleanup EXIT; '
                  'trap "exit 143" TERM; printf private | upload_write "$CLOSURE_PUBLISH_STAGE"; '
                  'touch "$TEST_MARKER"; kill -TERM "$$"')
        result = subprocess.run(["bash", "-c", script], env=self.env, capture_output=True, timeout=15)
        self.assertTrue(marker.exists())
        self.assertEqual(result.returncode, 143, result.stderr)
        self.assertIsNone(self.server.asset)
        self.assertFalse(any(verb == "COMMIT" for verb, _ in self.server.events))

    def test_abort_failure_names_retained_attempt(self):
        script = ('source "$1"; CLOSURE_PUBLISH_STAGE=fixture-retained-stage; '
                  'CLOSURE_PUBLISH_COMMITTED=0; upload_abort() { return 1; }; '
                  'trap closure_publish_cleanup EXIT; exit 7')
        result = subprocess.run(["bash", "-c", script, "fixture",
                                 str(CPLX / "src/setups/env/bin/closure_publish.sh")],
                                capture_output=True, timeout=5)
        self.assertEqual(result.returncode, 7)
        self.assertIn(b"abort FAILED, stage fixture-retained-stage may persist", result.stderr)

    def test_gate_resolves_lost_commit_response(self):
        self.server.mode = "lost"
        result = self.gate(DIGEST)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.server.asset, PAYLOAD)

    def test_gate_never_claims_absence_after_uncertain_commit(self):
        self.server.mode = "unavailable"
        result = self.gate(DIGEST)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn(b"nothing is public", result.stderr)
        self.assertIn(b"unresolved", result.stderr)
        self.assertEqual(self.server.asset, PAYLOAD)

    def test_old_tools_entry_refuses_before_external_commands(self):
        self.env["MVN"] = "/nonexistent-maven"
        result = subprocess.run(["bash", str(APP / "tools/publish_pdf_nexus.sh"),
                                 "--with-tools", "--version", "probe", "--yes"],
                                env=self.env, capture_output=True, timeout=10)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b"release record", result.stderr)
        self.assertEqual(self.server.events, [])

    def test_ordinary_publisher_preserves_release_and_snapshot_behaviour(self):
        publisher = APP / "tools/publish_pdf_nexus.sh"
        pattern = re.search(r"tar -xzOf .*?--wildcards '([^']+)'", publisher.read_text()).group(1)
        archive = self.root / "application.tar.gz"
        deploy = b"#!/bin/bash\nexit 0\n"
        with tarfile.open(archive, "w:gz") as output:
            item = tarfile.TarInfo(pattern.replace("*", "pdfs"))
            item.size = len(deploy)
            output.addfile(item, io.BytesIO(deploy))
        digests = {"pdfs": hashlib.sha1(archive.read_bytes()).hexdigest(),
                   "deploy_pkgs": hashlib.sha1(deploy).hexdigest()}
        stubs = self.root / "bin"
        stubs.mkdir()
        marker, log = self.root / "published", self.root / "maven.jsonl"
        curl = stubs / "curl"
        curl.write_text(f"#!{sys.executable}\n" + '''import json, os, sys
from pathlib import Path
url = sys.argv[-1]
digests = json.loads(os.environ['STUB_DIGESTS'])
if not Path(os.environ['STUB_MARKER']).exists():
    sys.exit(22)
key = 'deploy_pkgs' if 'deploy_pkgs' in url else 'pdfs'
digest = 'f' * 40 if os.environ['STUB_MODE'] == 'different' else digests[key]
print(json.dumps({'sha1': digest}) if '/search/' in url else digest)
''')
        maven = stubs / "maven"
        maven.write_text(f"#!{sys.executable}\n" + '''import json, os, sys
from pathlib import Path
with Path(os.environ['STUB_LOG']).open('a') as stream:
    stream.write(json.dumps(sys.argv[1:]) + '\\n')
Path(os.environ['STUB_MARKER']).touch()
''')
        curl.chmod(0o700)
        maven.chmod(0o700)
        self.env.update(PATH=f"{stubs}:{self.env['PATH']}", MVN=str(maven),
                        STUB_DIGESTS=json.dumps(digests), STUB_MARKER=str(marker), STUB_LOG=str(log))
        for mode in ("fresh", "identical", "different", "snapshot"):
            with self.subTest(mode=mode):
                marker.unlink(missing_ok=True)
                log.unlink(missing_ok=True)
                if mode in {"identical", "different"}:
                    marker.touch()
                self.env["STUB_MODE"] = mode
                args = ["bash", str(publisher), str(archive), "--version", "probe", "--yes"]
                if mode == "snapshot":
                    args.append("--snapshot")
                result = subprocess.run(args, env=self.env, capture_output=True, timeout=15)
                if mode == "different":
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn(b"DIFFERENT sha1", result.stderr)
                    self.assertFalse(log.exists())
                    continue
                self.assertEqual(result.returncode, 0, result.stderr)
                calls = [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []
                self.assertEqual(len(calls), {"fresh": 2, "identical": 0, "snapshot": 1}[mode])
                if calls:
                    self.assertIn("-Dclassifier=deploy_pkgs", calls[-1])
                    self.assertIn("-Dclassifiers=pdfs", calls[-1])
                    self.assertNotIn("-Dclassifier=tools", calls[-1])


if __name__ == "__main__":
    unittest.main()
