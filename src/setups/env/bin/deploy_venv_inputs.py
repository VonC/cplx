"""Verify explicitly supplied release inputs and assemble a non-circular companion.

No acquisition or interpreter discovery occurs here. The consumer supplies local
paths; the outer bootstrap record binds final bytes while the inner manifest
binds members. Qualification evidence is separate from these immutable inputs.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import sys
import tarfile
import tomllib

REQUIRED = {"schema", "application", "tools", "entry", "uv", "metadata",
            "profiles", "wheels", "transport", "runtime", "helpers"}
SHA256 = re.compile(r"[0-9a-f]{64}\Z")
VERSION = re.compile(r"[A-Za-z0-9][A-Za-z0-9_.+-]*\Z")
REVISION = re.compile(r"[0-9a-f]{40}(?:[0-9a-f]{24})?\Z")


def sha256(path):
    """Stream an artifact once, without loading archives into memory."""
    digest = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def safe_name(name):
    """Require one unambiguous relative POSIX member path on every platform."""
    if (not isinstance(name, str) or not name or name.startswith("/")
            or any(c in name for c in "\\:%\x00\r\n")
            or any(part in ("", ".", "..") for part in name.split("/"))):
        raise ValueError("unsafe member path")
    return name


def local_path(root, name):
    """Reject escaping paths and symlink components before any read or write."""
    root = Path(root).resolve()
    path = root
    for part in PurePosixPath(safe_name(name)).parts:
        path = path / part
        if path.is_symlink():
            raise ValueError("symlink input is not a retained original file")
    if not path.resolve().is_relative_to(root):
        raise ValueError("input escapes declared root")
    return path


def unique(pairs):
    """Reject ambiguous JSON objects at either manifest boundary."""
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate manifest key")
        result[key] = value
    return result


def load(path):
    """Read exactly the selected manifest; reject duplicate JSON keys."""
    with Path(path).open(encoding="utf-8") as stream:
        return json.load(stream, object_pairs_hook=unique)


def encoded(value):
    """Canonical encoding preserves declared order without an extra sort pass."""
    return (json.dumps(value, ensure_ascii=True, separators=(",", ":")) + "\n").encode()


def members(manifest):
    """Enumerate only the declared companion members, excluding external archives."""
    return [manifest["uv"], *manifest["metadata"], *manifest["profiles"],
            *manifest["wheels"], manifest["transport"], *manifest["runtime"],
            *manifest["helpers"]["members"]]


def checked_artifact(row, root):
    if not isinstance(row, dict) or not {"path", "sha256"} <= row.keys():
        raise ValueError("artifact needs path and sha256")
    if not isinstance(row["sha256"], str) or not SHA256.fullmatch(row["sha256"]):
        raise ValueError("invalid sha256")
    path = local_path(root, row["path"])
    if not path.is_file() or sha256(path) != row["sha256"]:
        raise ValueError("absent or changed input: " + row["path"])
    return path


def verify(manifest, root, tools_pin=None, *, companion_only=False):
    """Validate schema, immutable bytes and workspace closure before mutation."""
    if not isinstance(manifest, dict) or set(manifest) != REQUIRED or manifest["schema"] != 1:
        raise ValueError("incomplete or unsupported release manifest")
    try:
        for section in ("application", "tools", "uv"):
            if not VERSION.fullmatch(manifest[section]["version"]):
                raise ValueError("invalid version")
        for section in ("application", "helpers"):
            if not REVISION.fullmatch(manifest[section]["revision"]):
                raise ValueError("source revision must be immutable")
        safe_name(manifest["tools"]["coordinate"])
        if not re.fullmatch(r"\d+\.\d+\.\d+", manifest["tools"]["python"]):
            raise ValueError("full Python version required")
        if manifest["uv"]["provenance"] != "original-static":
            raise ValueError("derived uv needs separate qualified adaptation support")
        for key in ("metadata", "profiles", "runtime"):
            if not isinstance(manifest[key], list) or not manifest[key]:
                raise ValueError("missing " + key)
        if not manifest["helpers"]["members"]:
            raise ValueError("missing helper closure")
        rows = members(manifest)
    except (KeyError, TypeError) as error:
        raise ValueError("incomplete release binding") from error
    if tools_pin is not None:
        if Path(tools_pin).read_text(encoding="utf-8").strip() != manifest["tools"]["version"]:
            raise ValueError("missing or conflicting tools pin")
    seen = {"manifest.json"}
    for row in rows:
        name = safe_name(row["path"])
        if name in seen:
            raise ValueError("duplicate or self-referencing member")
        seen.add(name)
        checked_artifact(row, root)
    if not companion_only:
        for key in ("application", "tools", "entry"):
            checked_artifact(manifest[key], root)
    metadata = {row["path"]: local_path(root, row["path"]) for row in manifest["metadata"]}
    if not {"metadata/pyproject.toml", "metadata/uv.lock"} <= metadata.keys():
        raise ValueError("canonical project and lock required")
    project = tomllib.loads(metadata["metadata/pyproject.toml"].read_text(encoding="utf-8"))
    lock = tomllib.loads(metadata["metadata/uv.lock"].read_text(encoding="utf-8"))
    workspace = project.get("tool", {}).get("uv", {}).get("workspace", {})
    for member in workspace.get("members", []):
        safe_name(member)
        if any(c in member for c in "*?["):
            raise ValueError("workspace members must be explicit retained paths")
        if "metadata/" + member + "/pyproject.toml" not in metadata:
            raise ValueError("workspace metadata omitted")
    hashes = {}
    for package in lock.get("package", []):
        source = package.get("source", {})
        for key in ("editable", "virtual", "directory"):
            if key in source and source[key] != ".":
                relative = safe_name(source[key])
                if "metadata/" + relative + "/pyproject.toml" not in metadata:
                    raise ValueError("local source metadata omitted")
        for wheel in package.get("wheels", []):
            digest = wheel.get("hash", "")
            hashes.setdefault(digest, set()).add((package["name"], package["version"]))
    wheel_names = set()
    for row in manifest["wheels"]:
        try:
            if not row["path"].endswith(".whl") or Path(row["path"]).name != row["filename"]:
                raise ValueError("only original wheels allowed")
            if row["filename"] in wheel_names:
                raise ValueError("ambiguous wheel filename")
            wheel_names.add(row["filename"])
            if (row["name"], row["version"]) not in hashes.get("sha256:" + row["sha256"], set()):
                raise ValueError("wheel is not bound by the canonical lock")
        except KeyError as error:
            raise ValueError("incomplete wheel identity") from error
    return manifest


def assemble(manifest, root, output):
    """Write only verified members into a new archive; never overwrite candidates."""
    import io
    verify(manifest, root)
    executable_members = {row["path"] for row in manifest["helpers"]["members"]}
    executable_members.add(manifest["uv"]["path"])
    with Path(output).open("xb") as target:
        with tarfile.open(fileobj=target, mode="w") as archive:
            data = encoded(manifest)
            info = tarfile.TarInfo("manifest.json")
            info.size = len(data)
            info.mode = 0o644
            archive.addfile(info, io.BytesIO(data))
            for row in members(manifest):
                path = local_path(root, row["path"])
                info = tarfile.TarInfo(row["path"])
                info.size = path.stat().st_size
                info.mode = 0o755 if row["path"] in executable_members else 0o644
                with path.open("rb") as source:
                    archive.addfile(info, source)
    # Detect input changes across the transfer boundary, never bless partial bytes.
    verify(manifest, root)
    return sha256(output)


def extract(archive_path, destination, expected_sha256):
    """Check the entire member inventory before creating an owned destination."""
    if not SHA256.fullmatch(expected_sha256) or sha256(archive_path) != expected_sha256:
        raise ValueError("companion digest mismatch")
    destination = Path(destination)
    if destination.exists() or destination.is_symlink():
        raise ValueError("extraction destination must be new")
    with tarfile.open(archive_path, "r:*") as archive:
        entries = archive.getmembers()
        by_name = {}
        for item in entries:
            safe_name(item.name)
            if not item.isfile() or item.name in by_name:
                raise ValueError("nonregular or duplicate companion member")
            by_name[item.name] = item
        if "manifest.json" not in by_name:
            raise ValueError("missing inner manifest")
        manifest = json.load(archive.extractfile(by_name["manifest.json"]), object_pairs_hook=unique)
        if not isinstance(manifest, dict) or set(manifest) != REQUIRED:
            raise ValueError("invalid inner manifest")
        declared = {row["path"]: row for row in members(manifest)}
        if len(declared) != len(members(manifest)) or set(by_name) != set(declared) | {"manifest.json"}:
            raise ValueError("unlisted or missing companion member")
        for name, row in declared.items():
            with archive.extractfile(by_name[name]) as source:
                if hashlib.file_digest(source, "sha256").hexdigest() != row["sha256"]:
                    raise ValueError("changed companion member")
        destination.mkdir()
        for item in entries:
            path = local_path(destination, item.name)
            path.parent.mkdir(parents=True, exist_ok=True)
            with archive.extractfile(item) as source, path.open("xb") as target:
                shutil.copyfileobj(source, target)
            path.chmod(item.mode & 0o777)
    verify(manifest, destination, companion_only=True)
    if sha256(archive_path) != expected_sha256:
        raise ValueError("companion changed during extraction")
    return manifest


def release_record(manifest, bundle):
    """Generate the fixed UTF-8 bootstrap key/value format, never shell code."""
    rows = {"schema": "1", "application_version": manifest["application"]["version"],
            "application_sha256": manifest["application"]["sha256"],
            "entry_sha256": manifest["entry"]["sha256"], "companion_sha256": sha256(bundle),
            "tools_version": manifest["tools"]["version"],
            "tools_coordinate": manifest["tools"]["coordinate"],
            "tools_sha256": manifest["tools"]["sha256"],
            "helpers_revision": manifest["helpers"]["revision"],
            "helpers_manifest_sha256": hashlib.sha256(encoded(manifest["helpers"])).hexdigest()}
    for key, value in rows.items():
        if not re.fullmatch(r"[A-Za-z0-9_./+-]+", value):
            raise ValueError("unsafe bootstrap record value: " + key)
    return "".join(key + "=" + value + "\n" for key, value in rows.items())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("verify", "assemble", "extract"))
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--archive", type=Path)
    parser.add_argument("--sha256")
    parser.add_argument("--tools-pin", type=Path)
    parser.add_argument("--record", type=Path)
    args = parser.parse_args()
    try:
        if args.operation == "extract":
            extract(args.archive, args.root, args.sha256)
        else:
            manifest = load(args.manifest)
            verify(manifest, args.root, args.tools_pin)
            if args.operation == "assemble":
                assemble(manifest, args.root, args.archive)
                if args.record:
                    with args.record.open("x", encoding="utf-8", newline="\n") as stream:
                        stream.write(release_record(manifest, args.archive))
    except (OSError, ValueError, TypeError, KeyError, tarfile.TarError) as error:
        print("Release inputs refused: " + str(error), file=sys.stderr)
        return 2
    print("Release inputs verified")
    return 0


if __name__ == "__main__":
    sys.exit(main())
