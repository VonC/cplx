#!/bin/bash
# Enter the verified, shipped Python boundary for one serialized deployment.
set -euo pipefail

tools='' helper='' runtime='' evidence=''
args=("$@")
write_not_ready() {
    local temporary
    [[ "$evidence" == /* ]] || return 0
    mkdir -p -- "$evidence" || return 0
    temporary=$(mktemp "$evidence/readiness.XXXXXXXX.tmp") || return 0
    printf '{"schema":1,"operation":"entry-preflight","state":"not-ready"}\n' > "$temporary"
    mv -f -- "$temporary" "$evidence/readiness.json"
}
early_failure() {
    local status=$?
    if ((status != 0)); then
        write_not_ready
    fi
}
while (($#)); do
    case "$1" in
        --tools-prefix) tools=${2:?}; shift 2 ;;
        --helper) helper=${2:?}; shift 2 ;;
        --runtime-setup) runtime=${2:?}; shift 2 ;;
        --evidence-root) evidence=${2:?}; shift 2 ;;
        --application-root|--project|--manifest|--profile|--selection-profile|--serialization-attestation)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
            shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
trap early_failure EXIT
[[ $(uname -s) == Linux && "$tools" == /* && "$helper" == /* && "$runtime" == /* ]] || {
    echo 'Native Linux and absolute verified helper/runtime/tool paths required' >&2; exit 2;
}
[[ "${tools##*/}" == tools ]] || { echo 'Tools prefix must end in tools' >&2; exit 2; }
[[ -f "$helper" && ! -L "$helper" && -f "$runtime" && ! -L "$runtime" ]] || {
    echo 'Verified helper or runtime setup missing' >&2; exit 2;
}
python=''
for candidate in "$tools"/python/current/bin/python3*_bin; do
    [[ -f "$candidate" && -x "$candidate" ]] || continue
    [[ -z "$python" ]] || { echo 'Ambiguous shipped Python' >&2; exit 2; }
    python=$(readlink -f -- "$candidate")
done
[[ -n "$python" && -x "$python" ]] || { echo 'Selected shipped Python missing' >&2; exit 2; }
# The consumer verifies the companion/member hashes before dispatching this entry.
# Source only the delivered runtime setup, leaving host utilities on their host pair.
export PDFSS_RUNTIME_PREFIX="${tools%/tools}"
# shellcheck source=/dev/null
source "$runtime" "$PDFSS_RUNTIME_PREFIX"
forward=()
while ((${#args[@]})); do
    case "${args[0]}" in
        --helper|--runtime-setup) args=("${args[@]:2}") ;;
        *) forward+=("${args[0]}"); args=("${args[@]:1}") ;;
    esac
done
export DVS_HELPER_ROOT="${helper%/*}"
write_not_ready
trap - EXIT
pdfss_runtime_run "$python" -I - "${forward[@]}" <<'PYTHON_LIFECYCLE'
"""Reconstruct one manifest-bound Linux venv at its full-version path.

The consumer owns the root lock across archive mirroring and this operation.
Every dependency input is verified before mutation; a failed operation leaves
an explicit not-ready record and its first failing command in retained evidence.
"""

from __future__ import annotations

import argparse
import errno
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
import time
import tomllib
import uuid
import zipfile

sys.path.insert(0, os.environ["DVS_HELPER_ROOT"])
from deploy_venv_inputs import encoded, load, local_path, sha256, verify
from deploy_venv_probe import file_index, check_uv_version
from deploy_venv_selection import effective_groups, verify as verify_selection
from deploy_venv_transport import check_workspace, workspace

SUFFIX = re.compile(r"[A-Za-z0-9][A-Za-z0-9_-]*\Z")
VERSION = re.compile(r"\d+\.\d+\.\d+\Z")


def exact_path(application_root, project, version):
    """Select only the declared full-version environment, never a recent one."""
    if not isinstance(project, str) or not SUFFIX.fullmatch(project):
        raise ValueError("invalid project suffix")
    if not isinstance(version, str) or not VERSION.fullmatch(version):
        raise ValueError("full Python version required")
    root = Path(application_root)
    if not root.is_absolute():
        raise ValueError("application root must be absolute")
    return root / "venvs" / ("python_" + version + "_" + project.replace("-", "_"))


def require_target_directory(target):
    """Refuse aliases and non-directory targets before creation or reuse."""
    target = Path(target)
    if target.is_symlink():
        raise ValueError("target venv is a symlink")
    if target.exists() and not target.is_dir():
        raise ValueError("target venv is not a directory")
    if target.parent.is_symlink():
        raise ValueError("venv parent is a symlink")
    if target.parent.exists() and not target.parent.is_dir():
        raise ValueError("venv parent is not a directory")
    if target.parent.exists() and target.parent.resolve() != target.parent:
        raise ValueError("venv parent escapes exact path")


def assert_venv_state(state, target, base_python, version):
    """Reject an equal-version venv whose base or exact prefix is foreign."""
    target = Path(target).resolve()
    base_python = Path(base_python).resolve()
    if Path(state["prefix"]).resolve() != target:
        raise ValueError("venv prefix differs from exact path")
    if Path(state["base_executable"]).resolve() != base_python:
        raise ValueError("venv has a foreign base executable")
    if state["version"] != version:
        raise ValueError("venv full Python version differs")
    if not base_python.is_relative_to(Path(state["base_prefix"]).resolve()):
        raise ValueError("venv has a foreign base prefix")


def selection_flags(profile):
    """Reproduce qualified default, excluded, requested group and extra policy."""
    result = ["--no-default-groups"] if profile["no_default_groups"] else []
    for value in profile["excluded_groups"]:
        result.extend(("--no-group", value))
    for value in profile["requested_groups"]:
        result.extend(("--group", value))
    for value in profile["extras"]:
        result.extend(("--extra", value))
    return result


def sync_environment(ambient, python, target, cache):
    """Discard ambient uv, pip, Python and activation settings for offline sync."""
    foreign = ambient.get("VIRTUAL_ENV", "")
    path_parts = [part for part in ambient.get("PATH", "").split(os.pathsep)
                  if part and not (foreign and Path(part).is_relative_to(Path(foreign)))]
    result = {key: value for key, value in ambient.items()
              if not key.startswith(("UV_", "PIP_", "PYTHON")) and key not in
              {"VIRTUAL_ENV", "VIRTUAL_ENV_PROMPT", "CONDA_PREFIX", "PYENV_VERSION",
               "HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "NO_PROXY",
               "http_proxy", "https_proxy", "all_proxy", "no_proxy"}}
    result["LD_LIBRARY_PATH"] = ambient.get("LD_LIBRARY_PATH", "")
    result.update(UV_PYTHON=str(python), UV_PROJECT_ENVIRONMENT=str(target),
                  UV_PYTHON_DOWNLOADS="never", UV_NO_BUILD="true", UV_NO_SOURCES="true",
                  UV_OFFLINE="true", UV_NO_CONFIG="true", UV_CACHE_DIR=str(cache))
    result["PATH"] = os.pathsep.join([str(Path(target) / "bin"), str(Path(python).parent),
                                      *path_parts])
    return result


def invalidate_readiness(path, operation):
    """Replace any prior success before changing the selected environment."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + "." + operation + ".tmp")
    temporary.write_bytes(encoded({"schema": 1, "operation": operation, "state": "not-ready"}))
    temporary.replace(path)


def require_serialization(path, application_root):
    """Verify the consumer still holds its root lock on a separate descriptor."""
    import fcntl
    attestation = load(path)
    if set(attestation) != {"schema", "application_root", "lock_path"} or attestation["schema"] != 1:
        raise ValueError("invalid serialization attestation")
    if Path(attestation["application_root"]).resolve() != Path(application_root).resolve():
        raise ValueError("serialization root differs")
    lock = Path(attestation["lock_path"])
    root = Path(application_root).resolve()
    stable_prefix_lock = root.parent.parent / ".deploy-venv.lock"
    if (not lock.is_absolute() or lock.is_symlink() or not lock.is_file()
            or not (lock.resolve().is_relative_to(root.parent)
                    or lock.resolve() == stable_prefix_lock)):
        raise ValueError("serialization lock file missing")
    with lock.open("rb") as stream:
        try:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            if error.errno not in (errno.EAGAIN, errno.EWOULDBLOCK):
                raise
        else:
            fcntl.flock(stream, fcntl.LOCK_UN)
            raise ValueError("serialization lock is not held")
    return str(lock)


def run(command, *, cwd=None, env=None, record=None, label=None):
    """Keep one bounded command log and the original exit status."""
    result = subprocess.run([str(item) for item in command], cwd=cwd, env=env,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
                            errors="replace", check=False)
    if record is not None:
        log = Path(record["directory"]) / (label + ".log")
        log.write_text(result.stdout, encoding="utf-8")
        record["commands"].append({"name": label, "argv": [str(item) for item in command],
                                   "returncode": result.returncode, "log": str(log)})
    if result.returncode:
        raise ValueError("command failed: " + (label or str(command[0])) +
                         " (exit " + str(result.returncode) + ")")
    return result.stdout


def interpreter_state(python, target, version, env, record, label="venv-state"):
    """Read actual base, prefix, stdlib and site paths from the selected venv."""
    probe = ("import json,pathlib,sys,sysconfig,ssl,zlib,sqlite3; "
             "print(json.dumps({'prefix':sys.prefix,'base_prefix':sys.base_prefix,"
             "'base_executable':sys._base_executable,"
             "'version':'.'.join(map(str,sys.version_info[:3])),"
             "'stdlib':sysconfig.get_path('stdlib'),"
             "'site':sysconfig.get_path('platlib')}))")
    output = run([target / "bin/python", "-I", "-c", probe], env=env,
                 record=record, label=label)
    state = json.loads(output.strip().splitlines()[-1])
    assert_venv_state(state, target, python, version)
    target_root = Path(target).resolve()
    if not Path(state["stdlib"]).resolve().is_relative_to(Path(state["base_prefix"]).resolve()):
        raise ValueError("stdlib lies outside shipped Python")
    if not Path(state["site"]).resolve().is_relative_to(target_root):
        raise ValueError("site packages lie outside exact venv")
    config = target / "pyvenv.cfg"
    if not config.is_file() or config.is_symlink():
        raise ValueError("venv configuration missing or aliased")
    for line in config.read_text(encoding="utf-8").splitlines():
        key, separator, value = line.partition("=")
        if separator and key.strip().lower() in {"home", "executable"}:
            if not Path(value.strip()).resolve().is_relative_to(Path(python).resolve().parents[2]):
                raise ValueError("pyvenv.cfg references a foreign Python")
    bin_dir = target_root / "bin"
    interpreters = {bin_dir / "python"}
    primary = (target / "bin/python").resolve()
    for candidate in bin_dir.glob("python*"):
        if candidate.is_symlink():
            if candidate.resolve() != primary:
                raise ValueError("venv has a foreign Python interpreter link")
            interpreters.add(candidate)
    for script in (target / "bin").iterdir():
        if not script.is_file() or script.is_symlink():
            continue
        with script.open("rb") as stream:
            first = stream.readline(4096)
        if first.startswith(b"#!") and b"python" in first.lower():
            interpreter = first[2:].decode("utf-8", errors="replace").strip().split(" ", 1)[0]
            shebang = Path(interpreter)
            if (not shebang.is_absolute() or
                    Path(os.path.abspath(shebang)) not in interpreters):
                raise ValueError("venv script has a foreign Python shebang")
    return Path(state["site"])


def preflight(args, manifest):
    """Verify all named files, selected toolchain and lock before mutation."""
    root = args.manifest.resolve().parent
    verify(manifest, root)
    if args.manifest.name != "manifest.json":
        raise ValueError("release manifest must be named manifest.json")
    if args.application_root.is_symlink() or not args.application_root.is_dir():
        raise ValueError("application root missing or aliased")
    require_serialization(args.serialization_attestation, args.application_root)
    if not any(local_path(root, row["path"]).resolve() == args.profile.resolve()
               for row in manifest["profiles"]):
        raise ValueError("target profile is not bound by release")
    if not any(local_path(root, row["path"]).resolve() == args.selection_profile.resolve()
               for row in manifest["profiles"]):
        raise ValueError("selection profile is not bound by release")
    target_profile = load(args.profile)
    selection = load(args.selection_profile)
    if target_profile["os"] != "linux" or target_profile["arch"] != platform.machine():
        raise ValueError("wrong target platform")
    if selection["toolchain_sha256"] != manifest["tools"]["sha256"] or selection["source_revision"] != manifest["application"]["revision"]:
        raise ValueError("selection release identity differs")
    canonical = root / "metadata"
    project = tomllib.loads((canonical / "pyproject.toml").read_text(encoding="utf-8"))
    effective_groups(project, selection)
    if set(selection["groups"]) != set(target_profile["groups"]) or set(selection["extras"]) != set(target_profile["extras"]):
        raise ValueError("target and selection groups differ")
    for row in manifest["metadata"]:
        installed = args.application_root / row["path"].removeprefix("metadata/")
        if not installed.is_file() or sha256(installed) != row["sha256"]:
            raise ValueError("application metadata differs from release")
    current = args.tools_prefix / "python/current"
    if not current.exists() or not current.is_dir():
        raise ValueError("toolchain current Python missing")
    version = manifest["tools"]["python"]
    if current.resolve().name not in {"python-" + version, "python_" + version}:
        raise ValueError("toolchain directory version differs")
    candidates = [path for path in (current / "bin").glob("python3*_bin")
                  if path.is_file() and os.access(path, os.X_OK)]
    if len(candidates) != 1:
        raise ValueError("one selected shipped Python executable required")
    python = candidates[0].resolve(strict=True)
    if not python.is_relative_to(args.tools_prefix.resolve()) or not os.access(python, os.X_OK):
        raise ValueError("selected Python escapes supplied toolchain")
    if Path(sys.executable).resolve() != python or platform.python_version() != version:
        raise ValueError("running Python is not the selected shipped interpreter")
    if sha256(local_path(root, manifest["tools"]["path"])) != manifest["tools"]["sha256"]:
        raise ValueError("toolchain archive changed")
    target = exact_path(args.application_root, args.project, version)
    require_target_directory(target)
    uv = local_path(root, manifest["uv"]["path"])
    if not os.access(uv, os.X_OK):
        raise ValueError("qualified uv is not executable")
    check_uv_version(run([uv, "--version"], label="uv-version"), manifest["uv"]["version"])
    return root, python, target, uv, selection


def prepare_sources(manifest, root, owned):
    """Create a file-only Simple index and a checked effective metadata copy."""
    locations = load(local_path(root, manifest["transport"]["path"]))["locations"]
    lock = tomllib.loads(local_path(root, "metadata/uv.lock").read_text(encoding="utf-8"))
    registries = {locations[row["source"]["registry"]] for row in lock["package"]
                  if "registry" in row["source"]}
    file_root = owned / "file-source"
    file_index(root, manifest["wheels"], registries, file_root)
    metadata = owned / "metadata"
    mapping = workspace(manifest, root, metadata, file_root.as_uri())
    return metadata, mapping


def finish_checks(args, manifest, root, target, python, selection, owned, record):
    """Bind installed wheels, ELF bytes and interpreter facts before success."""
    import deploy_venv_selection
    import tools_wheel_inventory
    site = interpreter_state(python, target, manifest["tools"]["python"],
                             os.environ.copy(), record)
    wheel_dir = owned / "selected-wheels"
    wheel_dir.mkdir()
    for row in manifest["wheels"]:
        source = local_path(root, row["path"])
        destination = wheel_dir / row["filename"]
        if destination.exists():
            raise ValueError("duplicate wheel basename")
        shutil.copyfile(source, destination)
    inventory = owned / "wheel-inventory.json"
    inventory_args = argparse.Namespace(lock=root / "metadata/uv.lock", wheel_dir=wheel_dir,
                                        installed_root=site, venv_root=target,
                                        profile=args.selection_profile, output=inventory)
    tools_wheel_inventory.capture(inventory_args)
    result = verify_selection(root / "metadata/uv.lock", root / "metadata/pyproject.toml",
                              args.selection_profile, wheel_dir, site, inventory,
                              args.manifest, args.profile)
    record.update(result)
    record["inventory_sha256"] = sha256(inventory)
    record["venv"] = str(target)
    return result


def operate(args):
    """Run one offline lifecycle and retain a truthful operation result."""
    started = time.monotonic()
    operation = uuid.uuid4().hex
    args.evidence_root.mkdir(parents=True, exist_ok=True)
    owned = args.evidence_root / ("operation-" + operation)
    owned.mkdir()
    record = {"schema": 1, "state": "not-ready", "operation": operation,
              "directory": str(owned), "commands": []}
    result_path = owned / "result.json"
    ready_path = args.evidence_root / "readiness.json"
    try:
        invalidate_readiness(ready_path, operation)
        manifest = load(args.manifest)
        require_serialization(args.serialization_attestation, args.application_root)
        root, python, target, uv, selection = preflight(args, manifest)
        identity = {"manifest_sha256": sha256(args.manifest),
                    "toolchain_sha256": manifest["tools"]["sha256"],
                    "lock_sha256": sha256(root / "metadata/uv.lock"),
                    "profile_sha256": sha256(args.profile),
                    "selection_profile_sha256": sha256(args.selection_profile),
                    "venv": str(target), "python": str(python)}
        record.update(identity)
        require_serialization(args.serialization_attestation, args.application_root)
        require_target_directory(target)
        metadata, mapping = prepare_sources(manifest, root, owned)
        cache = owned / "cache"
        cache.mkdir()
        env = sync_environment(os.environ, python, target, cache)
        if target.exists():
            interpreter_state(python, target, manifest["tools"]["python"],
                              os.environ.copy(), record, "venv-state-before")
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            run([uv, "venv", "--python", python, "--no-python-downloads", target],
                env=env, record=record, label="create-venv")
            interpreter_state(python, target, manifest["tools"]["python"],
                              os.environ.copy(), record, "venv-state-created")
        command = [uv, "sync", "--locked", "--offline", "--no-build",
                   "--no-install-project", "--no-install-workspace",
                   "--python", python, "--no-python-downloads", *selection_flags(selection)]
        run(command, cwd=metadata, env=env, record=record, label="locked-sync")
        check_workspace(manifest, root, metadata, mapping)
        verify(manifest, root)
        finish_checks(args, manifest, root, target, python, selection, owned, record)
        require_serialization(args.serialization_attestation, args.application_root)
        record["state"] = "ready"
        temporary = ready_path.with_name(ready_path.name + "." + operation + ".tmp")
        temporary.write_bytes(encoded(record))
        temporary.replace(ready_path)
        print("VENV=" + str(target))
        return 0
    except (OSError, ValueError, KeyError, TypeError, RuntimeError,
            tomllib.TOMLDecodeError, zipfile.BadZipFile) as error:
        record["error"] = str(error)
        print("Deployment venv not ready: " + str(error), file=sys.stderr)
        return 5
    finally:
        record["elapsed_seconds"] = time.monotonic() - started
        result_path.write_bytes(encoded(record))
        print("EVIDENCE=" + str(result_path))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("application-root", "tools-prefix", "manifest", "profile",
                 "selection-profile", "serialization-attestation", "evidence-root"):
        parser.add_argument("--" + name, required=True, type=Path)
    parser.add_argument("--project", required=True)
    args = parser.parse_args()
    if platform.system() != "Linux" or any(not getattr(args, name).is_absolute()
                                            for name in ("application_root", "tools_prefix", "manifest",
                                                         "profile", "selection_profile", "serialization_attestation",
                                                         "evidence_root")):
        parser.error("native Linux and absolute paths required")
    return operate(args)


if __name__ == "__main__":
    sys.exit(main())
PYTHON_LIFECYCLE
