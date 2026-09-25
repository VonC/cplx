"""Validate and retain exact local release inputs for offline deployment.

This module performs no acquisition and never selects a newest file. A release
record binds the outer bytes; the companion's inner manifest binds its members.
Retention staging and promotion are separate so failed readiness keeps the
previous safe release protected.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import sys
import tarfile
import tempfile

KEYS = ("schema", "application_version", "application_sha256", "entry_sha256",
        "companion_sha256", "tools_version", "tools_coordinate", "tools_sha256",
        "helpers_revision", "helpers_manifest_sha256")
FILES = {"application": "application_sha256", "entry": "entry_sha256",
         "companion": "companion_sha256", "tools": "tools_sha256"}
SHA256 = re.compile(r"[0-9a-f]{64}\Z")
VERSION = re.compile(r"[A-Za-z0-9][A-Za-z0-9_.+-]*\Z")
REVISION = re.compile(r"[0-9a-f]{40}(?:[0-9a-f]{24})?\Z")
COORDINATE = re.compile(r"[A-Za-z0-9_.+-]+(?:/[A-Za-z0-9_.+-]+)+\Z")
VALUE = re.compile(r"[A-Za-z0-9_./+-]+\Z")


def sha256(path):
    """Stream a whole local file at each transfer boundary."""
    digest = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def validate(row):
    """Require the complete ten-key bootstrap schema and safe exact values."""
    if set(row) != set(KEYS) or row["schema"] != "1":
        raise ValueError("incomplete or unsupported release record")
    if any(not isinstance(value, str) or not VALUE.fullmatch(value)
           for value in row.values()):
        raise ValueError("unsafe release record value")
    if any(not VERSION.fullmatch(row[key]) for key in ("application_version", "tools_version")):
        raise ValueError("invalid release version")
    if (not COORDINATE.fullmatch(row["tools_coordinate"])
            or any(part in (".", "..") for part in row["tools_coordinate"].split("/"))):
        raise ValueError("invalid tools coordinate")
    if not REVISION.fullmatch(row["helpers_revision"]):
        raise ValueError("helpers must have an immutable revision")
    if any(not SHA256.fullmatch(row[key]) for key in (*FILES.values(), "helpers_manifest_sha256")):
        raise ValueError("invalid release digest")
    return row


def parse(path):
    """Read one UTF-8 key/value record without shell evaluation or duplicates."""
    row = {}
    with Path(path).open("r", encoding="utf-8", newline="") as stream:
        for line in stream:
            if not line.endswith("\n") or line.endswith("\r\n") or line.count("=") != 1:
                raise ValueError("malformed release record line")
            key, value = line[:-1].split("=", 1)
            if key in row:
                raise ValueError("duplicate release record key")
            row[key] = value
    return validate(row)


def record(identity, files):
    """Bind exact outer file bytes without hashing this enclosing record."""
    row = {"schema": "1", **identity}
    for name, key in FILES.items():
        row[key] = sha256(files[name])
    validate(row)
    return "".join(key + "=" + row[key] + "\n" for key in KEYS)


def create_record(files):
    """Derive immutable release identities from a verified companion."""
    spec = importlib.util.spec_from_file_location(
        "deploy_venv_inputs", Path(__file__).with_name("deploy_venv_inputs.py"))
    inputs = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(inputs)
    with tempfile.TemporaryDirectory(prefix=".release-record-") as scratch:
        manifest = inputs.extract(files["companion"], Path(scratch) / "contents",
                                  sha256(files["companion"]))
    for section in ("application", "tools", "entry"):
        if sha256(files[section]) != manifest[section]["sha256"]:
            raise ValueError("companion outer identity differs: " + section)
    identity = {
        "application_version": manifest["application"]["version"],
        "tools_version": manifest["tools"]["version"],
        "tools_coordinate": manifest["tools"]["coordinate"],
        "helpers_revision": manifest["helpers"]["revision"],
        "helpers_manifest_sha256": hashlib.sha256(
            inputs.encoded(manifest["helpers"])).hexdigest(),
    }
    return record(identity, files)


def retained_names(row, application_prefix="application"):
    """Keep accepted archive basenames while retaining their exact bytes."""
    if not VERSION.fullmatch(application_prefix):
        raise ValueError("invalid application archive prefix")
    return {"application": application_prefix + "." + row["application_version"] + ".tar.gz",
            "tools": "tools." + row["tools_version"] + ".tar.gz",
            "entry": "entry", "companion": "companion"}


def preflight(record_path, files):
    """Verify every supplied file before mutation, including symlink refusal."""
    row = parse(record_path)
    for name, key in FILES.items():
        path = Path(files[name])
        if path.is_symlink() or not path.is_file() or sha256(path) != row[key]:
            raise ValueError("missing or changed local input: " + name)
    return row


def qualify(record_path, files):
    """Check the complete companion and its outer bindings before mirroring."""
    row = preflight(record_path, files)
    spec = importlib.util.spec_from_file_location(
        "deploy_venv_inputs", Path(__file__).with_name("deploy_venv_inputs.py"))
    inputs = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(inputs)
    with tempfile.TemporaryDirectory(prefix=".release-check-") as scratch:
        root = Path(scratch) / "contents"
        manifest = inputs.extract(files["companion"], root, row["companion_sha256"])
        bindings = (("application", "application_version", "application_sha256"),
                    ("tools", "tools_version", "tools_sha256"))
        for section, version, digest in bindings:
            if (manifest[section]["version"] != row[version]
                    or manifest[section]["sha256"] != row[digest]):
                raise ValueError("companion outer identity differs: " + section)
        if manifest["entry"]["sha256"] != row["entry_sha256"]:
            raise ValueError("companion entry identity differs")
        if (manifest["tools"]["coordinate"] != row["tools_coordinate"]
                or manifest["helpers"]["revision"] != row["helpers_revision"]
                or hashlib.sha256(inputs.encoded(manifest["helpers"])).hexdigest()
                != row["helpers_manifest_sha256"]):
            raise ValueError("companion tool or helper identity differs")
        for name in ("application", "tools", "entry"):
            target = inputs.local_path(root, manifest[name]["path"])
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(files[name], target)
        inputs.verify(manifest, root)
    return row


def selected(retention, identity, application_prefix="application"):
    """Read only the explicit retained identity and verify it again."""
    if not SHA256.fullmatch(identity):
        raise ValueError("invalid retained release identity")
    root = Path(retention) / identity
    row = parse(root / "release-inputs.txt")
    files = {name: root / filename for name, filename in retained_names(row, application_prefix).items()}
    preflight(root / "release-inputs.txt", files)
    if sha256(root / "release-inputs.txt") != identity:
        raise ValueError("retained record changed")
    return root, files


def index(retention, application_prefix="application"):
    """Read one selected current/predecessor index, without directory scans."""
    path = Path(retention) / "index.json"
    if not path.exists():
        return {"schema": 1, "current": None, "predecessor": None}
    with path.open(encoding="utf-8") as stream:
        data = json.load(stream)
    if set(data) != {"schema", "current", "predecessor"} or data["schema"] != 1:
        raise ValueError("invalid retained release index")
    for key in ("current", "predecessor"):
        if data[key] is not None:
            selected(retention, data[key], application_prefix)
    return data


def promote(retention, candidate, ready, application_prefix="application"):
    """Advance current only after an explicit ready result; keep predecessor."""
    if not ready:
        raise ValueError("readiness has not succeeded")
    selected(retention, candidate, application_prefix)
    state = index(retention, application_prefix)
    if candidate == state["current"]:
        return state
    update = {"schema": 1, "current": candidate, "predecessor": state["current"]}
    path = Path(retention) / "index.json"
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", newline="\n",
                                     prefix=".index-", dir=retention, delete=False) as stream:
        json.dump(update, stream, separators=(",", ":"))
        stream.write("\n")
        temporary = Path(stream.name)
    os.replace(temporary, path)
    return update


def write_qualified_record(output, files):
    """Publish a new record only after its complete companion qualifies."""
    output = Path(output)
    if output.exists() or output.is_symlink():
        raise FileExistsError("record output already exists")
    content = create_record(files)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", newline="\n",
                                         prefix=".release-record-", dir=output.parent,
                                         delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(content)
        qualify(temporary, files)
        os.link(temporary, output)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("record", "preflight", "qualify", "select", "promote"))
    parser.add_argument("--record", type=Path)
    parser.add_argument("--application", type=Path)
    parser.add_argument("--entry", type=Path)
    parser.add_argument("--companion", type=Path)
    parser.add_argument("--tools", type=Path)
    parser.add_argument("--retention", type=Path)
    parser.add_argument("--identity")
    parser.add_argument("--ready", action="store_true")
    parser.add_argument("--application-prefix", default="application")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    files = {name: getattr(args, name) for name in FILES}
    try:
        if args.operation == "record":
            if args.output is None:
                raise ValueError("record output path is required")
            write_qualified_record(args.output, files)
        elif args.operation == "preflight":
            preflight(args.record, files)
        elif args.operation == "qualify":
            qualify(args.record, files)
        elif args.operation == "select":
            root, _ = selected(args.retention, args.identity, args.application_prefix)
            print(root)
        else:
            promote(args.retention, args.identity, args.ready, args.application_prefix)
    except (OSError, ValueError, KeyError, TypeError, tarfile.TarError) as error:
        print("Release refused: " + str(error), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
