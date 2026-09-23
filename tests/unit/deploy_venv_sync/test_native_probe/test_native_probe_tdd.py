"""Native probe prerequisites reject drift and serve only verified wheel inputs."""

import importlib
import errno
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import MagicMock, patch
from urllib.error import HTTPError
from urllib.request import Request, urlopen

sys.path.insert(0, str(Path(__file__).resolve().parents[4] / "src/setups/env/bin"))


class NativeProbeTest(unittest.TestCase):
    """Version, isolation and local HTTP boundaries fail closed before sync."""

    def setUp(self):
        self.probe = importlib.import_module("deploy_venv_probe")

    def test_version_accepts_platform_suffix_but_not_a_different_pin(self):
        for text in ("uv 0.12.17", "uv 0.12.17 (abcdef x86_64-unknown-linux-musl)"):
            self.probe.check_uv_version(text, "0.12.17")
        for text in ("uv 0.12.170", "uv 0.12.16", "other 0.12.17", "uv 0.12.17 junk"):
            with self.subTest(text=text), self.assertRaises(ValueError):
                self.probe.check_uv_version(text, "0.12.17")

    def test_isolation_rejects_an_external_interface(self):
        with self.assertRaisesRegex(ValueError, "loopback"):
            self.probe.check_isolation(["lo", "eth0"])

    def test_isolation_rejects_unusable_loopback(self):
        for operation in ("bind", "connect"):
            with self.subTest(operation=operation):
                external, listener, client = (MagicMock() for _ in range(3))
                for connection in (external, listener, client):
                    connection.__enter__.return_value = connection
                external.connect.side_effect = OSError(errno.ENETUNREACH, "no route")
                target = listener if operation == "bind" else client
                getattr(target, operation).side_effect = OSError(errno.ENETUNREACH, "no route")
                with patch.object(self.probe.socket, "socket", side_effect=[external, listener, client]), \
                        patch.object(Path, "read_text", return_value=""), \
                        self.assertRaisesRegex(ValueError, "supplied namespace has no usable loopback"):
                    self.probe.check_isolation(["lo"])

    def test_isolation_accepts_working_loopback_without_external_route(self):
        external = MagicMock()
        external.__enter__.return_value = external
        external.connect.side_effect = OSError(errno.ENETUNREACH, "no route")
        factory = self.probe.socket.socket
        with factory() as listener, factory() as client:
            with patch.object(self.probe.socket, "socket", side_effect=[external, listener, client]), \
                    patch.object(Path, "read_text", return_value=""):
                evidence = self.probe.check_isolation(["lo"])
        self.assertTrue(evidence["loopback_connect"])
        self.assertEqual(evidence["external_connect_errno"], errno.ENETUNREACH)

    def test_file_index_points_to_actual_delivered_wheel_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            wheel = root / "wheels/demo.whl"
            wheel.parent.mkdir()
            wheel.write_bytes(b"original")
            rows = [{"path": "wheels/demo.whl", "name": "Demo_Name", "sha256": "a" * 64}]
            self.probe.file_index(root, rows, {"registry/simple"})
            page = root / "registry/simple/demo-name/index.html"
            self.assertIn(wheel.resolve().as_uri(), page.read_text())
            self.assertIn("sha256=" + "a" * 64, page.read_text())
            with self.assertRaises(FileExistsError):
                self.probe.file_index(root, rows, {"registry/simple"})

    def test_server_maps_only_declared_wheels_and_generated_index(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            wheel = root / "demo.whl"
            wheel.write_bytes(b"original")
            (root / "secret").write_bytes(b"not served")
            wheels = [{"path": "demo.whl", "name": "Demo_Name", "sha256": "a" * 64}]
            with self.probe.local_index(root, wheels, {"registry/simple"}) as server:
                origin = f"http://127.0.0.1:{server.server_port}"
                with urlopen(origin + "/registry/simple/demo-name/") as response:
                    self.assertIn(b"sha256=" + b"a" * 64, response.read())
                with urlopen(origin + "/demo.whl") as response:
                    self.assertEqual(response.read(), b"original")
                with urlopen(Request(origin + "/demo.whl", method="HEAD")) as response:
                    self.assertEqual(response.headers["Content-Length"], "8")
                    self.assertEqual(response.read(), b"")
                for path in ("/secret", "/../secret", "/%2e%2e/secret"):
                    with self.assertRaises(HTTPError):
                        urlopen(origin + path)
                server.withhold_wheels = True
                with self.assertRaises(HTTPError):
                    urlopen(origin + "/demo.whl")
            self.assertFalse(server.worker.is_alive())


if __name__ == "__main__":
    unittest.main()
