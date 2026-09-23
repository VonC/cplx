"""Qualify manifest-bound locked sync with OS isolation and an owned local index.

The caller supplies a network namespace or container with only loopback. File
transport is attempted first; the approved fallback serves declared wheel bytes
and deterministic index pages only. All commands and failures retain evidence.
"""

from contextlib import contextmanager
import errno
import hashlib
import html
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import platform
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import threading
import time
import tomllib
from urllib.parse import quote

from deploy_venv_inputs import encoded, local_path, load, sha256, verify


def check_uv_version(output, expected):
    """Match the exact release version while accepting uv's build description."""
    if not re.fullmatch(r"uv " + re.escape(expected) + r"(?: \([^\r\n()]+\))?", output.strip()):
        raise ValueError("uv version differs from release binding")


def check_isolation(interfaces=None):
    """Require an isolated Linux network stack, including IPv6 interfaces."""
    # sysfs can remain mounted from the parent network namespace after unshare.
    # Query the current kernel network namespace instead of that inherited mount.
    names = {name for _, name in socket.if_nameindex()} if interfaces is None else set(interfaces)
    if names != {"lo"}:
        raise ValueError("native qualification requires only loopback networking")
    with socket.socket() as connection:
        connection.settimeout(2)
        try:
            connection.connect(("192.0.2.1", 443))
        except OSError as error:
            if error.errno != errno.ENETUNREACH:
                raise ValueError("external access must fail with no network route") from error
            external_errno = error.errno
        else:
            raise ValueError("external network access is not denied")
    try:
        with socket.socket() as listener, socket.socket() as client:
            listener.bind(("127.0.0.1", 0))
            listener.listen(1)
            client.settimeout(2)
            client.connect(listener.getsockname())
    except OSError as error:
        raise ValueError("supplied namespace has no usable loopback") from error
    return {"interfaces": ["lo"], "external_connect_errno": external_errno,
            "loopback_connect": True,
            "ipv4_routes": Path("/proc/net/route").read_text(),
            "ipv6_routes": Path("/proc/net/ipv6_route").read_text()}


@contextmanager
def local_index(root, wheels, registries):
    """Serve an allowlist, with generated Simple pages and no proxy or redirects."""
    files, packages = {}, {}
    for row in wheels:
        path = "/" + quote(row["path"])
        files[path] = local_path(root, row["path"])
        name = re.sub(r"[-_.]+", "-", row["name"]).lower()
        packages.setdefault(name, []).append(
            '<a href="' + html.escape(path) + '#sha256=' + row["sha256"] + '">' +
            html.escape(Path(row["path"]).name) + '</a>\n')
    pages = {}
    for registry in registries:
        for name, links in packages.items():
            pages["/" + quote(registry.rstrip("/")) + "/" + name + "/"] = "".join(links).encode()

    class Handler(BaseHTTPRequestHandler):
        """No filesystem path comes from a request; undeclared requests get 404."""

        def do_GET(self):
            self.respond(send_body=True)

        def do_HEAD(self):
            self.respond(send_body=False)

        def respond(self, *, send_body):
            path = self.path
            if path in pages:
                data = pages[path]
                size = len(data)
                kind = "text/html"
            elif path in files and not self.server.withhold_wheels:
                data = None
                size = files[path].stat().st_size
                kind = "application/octet-stream"
            else:
                self.server.requests.append({"path": path, "status": 404})
                self.send_error(404)
                return
            self.server.requests.append({"path": path, "status": 200})
            self.send_response(200)
            self.send_header("Content-Type", kind)
            self.send_header("Content-Length", str(size))
            self.end_headers()
            if send_body:
                if data is not None:
                    self.wfile.write(data)
                else:
                    with files[path].open("rb") as source:
                        shutil.copyfileobj(source, self.wfile)

        def log_message(self, *_args):
            pass

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    server.withhold_wheels = False
    server.requests = []
    server.worker = threading.Thread(target=server.serve_forever, daemon=True)
    server.worker.start()
    try:
        yield server
    finally:
        server.shutdown()
        server.server_close()
        server.worker.join()


def file_index(root, wheels, registries, destination=None):
    """Build real Simple pages and original wheel copies in an owned file tree."""
    destination = Path(root if destination is None else destination)
    packages = {}
    for row in wheels:
        source = local_path(root, row["path"])
        target = local_path(destination, row["path"])
        if source != target:
            target.parent.mkdir(parents=True, exist_ok=True)
            with source.open("rb") as original, target.open("xb") as copied:
                shutil.copyfileobj(original, copied)
        name = re.sub(r"[-_.]+", "-", row["name"]).lower()
        packages.setdefault(name, []).append(
            '<a href="' + html.escape(target.as_uri()) + '#sha256=' + row["sha256"] + '">' +
            html.escape(target.name) + '</a>\n')
    for registry in registries:
        for name, links in packages.items():
            page = local_path(destination, registry.rstrip("/") + "/" + name + "/index.html")
            page.parent.mkdir(parents=True, exist_ok=True)
            with page.open("x", encoding="utf-8") as output:
                output.write("".join(links))


def probe(manifest, root, tools_prefix, application_root, profile_path, evidence_root):
    """Run the delivered acceptance path; never use Git or acquire missing inputs."""
    from deploy_venv_transport import workspace, check_workspace
    verify(manifest, root)
    profile_path = Path(profile_path).resolve()
    if not any(local_path(root, row["path"]).resolve() == profile_path for row in manifest["profiles"]):
        raise ValueError("profile is not bound by the release")
    profile = load(profile_path)
    if profile["os"] != "linux" or profile["arch"] != platform.machine():
        raise ValueError("wrong target profile")
    python = Path(sys.executable).resolve()
    if not python.is_relative_to(Path(tools_prefix).resolve()):
        raise ValueError("probe interpreter is outside supplied toolchain")
    if platform.python_version() != manifest["tools"]["python"]:
        raise ValueError("toolchain Python version differs from release binding")
    for row in manifest["metadata"]:
        source = local_path(application_root, row["path"][len("metadata/"):])
        if sha256(source) != row["sha256"]:
            raise ValueError("application metadata differs from retained source")
    uv = local_path(root, manifest["uv"]["path"])
    evidence_root = Path(evidence_root)
    evidence_root.mkdir(parents=True, exist_ok=True)
    owned = Path(tempfile.mkdtemp(prefix="step1-", dir=evidence_root))
    started = time.monotonic()
    record = {"schema": 1, "state": "failed", "scope": "step1-manifest-transport-probe",
              "manifest_sha256": hashlib.sha256(encoded(manifest)).hexdigest(),
              "python": str(python), "python_version": platform.python_version(),
              "platform": platform.freedesktop_os_release(), "machine": platform.machine(),
              "uv_sha256": sha256(uv), "tools_sha256": manifest["tools"]["sha256"],
              "profile_sha256": sha256(profile_path), "commands": []}
    env = {key: value for key, value in os.environ.items()
           if not key.startswith(("UV_", "PIP_", "PYTHON")) and key.upper() not in
           {"HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "NO_PROXY", "VIRTUAL_ENV"}}
    env.update(UV_PYTHON_DOWNLOADS="never", UV_PYTHON=str(python), UV_NO_BUILD="true")
    command = [uv, "sync", "--locked", "--no-build", "--no-install-project",
               "--no-install-workspace", "--python", python, "--no-python-downloads",
               "--no-default-groups"]
    for flag, key in (("--group", "groups"), ("--extra", "extras")):
        for value in profile[key]:
            command.extend([flag, value])

    def run(args, name, cwd=None, *, expected=True):
        command_env = env | {"UV_CACHE_DIR": str(owned / (name + "-cache")),
                             "UV_PROJECT_ENVIRONMENT": str(owned / (name + "-venv"))}
        result = subprocess.run([str(item) for item in args], cwd=cwd, env=command_env,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        (owned / (name + ".log")).write_text(result.stdout, encoding="utf-8")
        record["commands"].append({"name": name, "argv": [str(item) for item in args],
                                   "returncode": result.returncode})
        if expected and result.returncode:
            raise ValueError("probe command failed: " + name + "; evidence: " + str(owned))
        return result

    def sync(mode, base=None):
        metadata = owned / (mode + "-metadata")
        mapping = workspace(manifest, root, metadata, base)
        (owned / (mode + "-mapping.json")).write_bytes(encoded(mapping))
        result = run(command + (["--offline"] if mode == "file" else []), mode, metadata, expected=False)
        check_workspace(manifest, root, metadata, mapping)
        return result, metadata, mapping

    def inventory(mode):
        result = run([owned / (mode + "-venv/bin/python"), "-I", "-c",
                      "import pathlib,sys,json,importlib.metadata as m; "
                      "assert pathlib.Path(sys._base_executable).resolve() == pathlib.Path(sys.argv[1]).resolve(); "
                      "print(json.dumps({d.metadata['Name'].lower():d.version for d in m.distributions()}))", python],
                     mode + "-inventory")
        installed = json.loads(result.stdout)
        allowed = {(row["name"].lower(), row["version"]) for row in manifest["wheels"]}
        if not set(installed.items()) <= allowed:
            raise ValueError("installed distribution was not delivered as a verified wheel")
        record["installed"] = installed

    def negative_metadata(base, negative_command):
        from deploy_venv_transport import dumps
        stale_dir = owned / "stale-metadata"
        workspace(manifest, root, stale_dir, base)
        project_path = stale_dir / "pyproject.toml"
        project = tomllib.loads(project_path.read_text())
        project["project"]["version"] = "999999.0.0"
        project_path.write_text(dumps(project))
        stale = run(negative_command, "stale-lock", stale_dir, expected=False)
        if not stale.returncode or "--locked" not in stale.stdout:
            raise ValueError("stale-lock rejection was not demonstrated")
        incompatible_dir = owned / "incompatible-metadata"
        workspace(manifest, root, incompatible_dir, base)
        lock_path = incompatible_dir / "uv.lock"
        incompatible_lock = tomllib.loads(lock_path.read_text())
        for package in incompatible_lock["package"]:
            package.pop("sdist", None)
            for wheel in package.get("wheels", []):
                wheel["url"] = wheel["url"].rsplit("-", 1)[0] + "-win_amd64.whl"
        lock_path.write_text(dumps(incompatible_lock))
        incompatible = run(negative_command, "incompatible-wheel", incompatible_dir, expected=False)
        if not incompatible.returncode or not any(
                word in incompatible.stdout.lower() for word in ("platform", "compatible")):
            raise ValueError("missing compatible-wheel rejection was not demonstrated")

    try:
        record["isolation"] = check_isolation()
        headers = run(["readelf", "-l", uv], "uv-headers").stdout
        dynamic = run(["readelf", "-d", uv], "uv-dynamic").stdout
        if "INTERP" in headers or "(NEEDED)" in dynamic:
            raise ValueError("original uv is not fully static")
        check_uv_version(run([uv, "--version"], "uv-version").stdout, manifest["uv"]["version"])
        locations = load(local_path(root, manifest["transport"]["path"]))["locations"]
        lock = tomllib.loads(local_path(root, "metadata/uv.lock").read_text())
        registries = {locations[row["source"]["registry"]] for row in lock["package"]
                      if "registry" in row["source"]}
        file_root = owned / "file-source"
        file_index(root, manifest["wheels"], registries, file_root)
        result, metadata, mapping = sync("file", file_root.as_uri())
        if result.returncode:
            # uv may report either a required lock update or an unavailable
            # offline registry. Neither authorizes changing dependency identity.
            # The fallback still has to pass the identical --locked contract.
            with local_index(root, manifest["wheels"], registries) as server:
                base = f"http://127.0.0.1:{server.server_port}"
                result, metadata, mapping = sync("loopback", base)
                if result.returncode:
                    raise ValueError("both designed transports failed; design review required")
                inventory("loopback")
                if manifest["wheels"]:
                    server.withhold_wheels = True
                    request_start = len(server.requests)
                    missing = run(command, "missing-wheel", metadata, expected=False)
                    server.withhold_wheels = False
                    if not missing.returncode or not any(row["status"] == 404 for row in server.requests[request_start:]):
                        raise ValueError("missing-wheel rejection was not demonstrated")
                negative_metadata(base, command)
                record["http_requests"] = server.requests
                check_workspace(manifest, root, metadata, mapping)
                record["transport"] = "loopback"
        else:
            inventory("file")
            hidden = []
            try:
                for row in manifest["wheels"]:
                    path = local_path(file_root, row["path"])
                    retained = path.with_name(path.name + ".withheld")
                    path.rename(retained)
                    hidden.append((path, retained))
                missing = run(command + ["--offline"], "missing-wheel", metadata, expected=False)
                if not hidden or not missing.returncode:
                    raise ValueError("missing-wheel rejection was not demonstrated")
            finally:
                for path, retained in hidden:
                    retained.rename(path)
            negative_metadata(file_root.as_uri(), command + ["--offline"])
            check_workspace(manifest, root, metadata, mapping)
            record["transport"] = "file"
        verify(manifest, root)
        record["state"] = "passed"
    finally:
        record["elapsed_seconds"] = time.monotonic() - started
        (owned / "result.json").write_bytes(encoded(record))
        print("Probe evidence: " + str(owned), flush=True)
    return record
