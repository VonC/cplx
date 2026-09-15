#!/usr/bin/env python3
"""Prove SQLite persistence and mapped library identity in the assessed process.

Callers select the interpreter, the enclosing Python tool tree (containing both
the installation/source and sandbox), the exact extension directory, and the
shipped provider. Build callers also name their configured libpython in the
source directory. No observation is used to invent an expected root. This
standalone, standard-library script reads Linux maps once after closing the
reopened database. Synthetic observations belong only in the unit tests.
"""

import argparse
from contextlib import closing
import importlib
import json
import os
from pathlib import Path
import re
import stat
import sys
import tempfile


class ProbeError(Exception):
    """Carry a failed rule or an inconclusive observation to the JSON boundary."""

    def __init__(self, message, outcome="failed"):
        super().__init__(message)
        self.outcome = outcome


class ProbeArguments(argparse.ArgumentParser):
    """Keep argument failures inside the same structured result contract."""

    def error(self, message):
        raise ProbeError(message)


def require_inside(path, root, label):
    """Compare already normalized paths using components, never string prefixes."""
    if not path.is_relative_to(root):
        raise ProbeError(f"{label} escapes expected root: {path} outside {root}")
    return path


def canonical(path):
    """Require an independently supplied or observed absolute path to exist."""
    path = Path(path)
    if not path.is_absolute():
        raise ProbeError(f"absolute path required: {path}")
    try:
        return path.resolve(strict=True)
    except (OSError, RuntimeError) as error:
        raise ProbeError(f"path unavailable: {path}: {error}", "inconclusive") from error


def directory(path):
    resolved = canonical(path)
    if not resolved.is_dir():
        raise ProbeError(f"directory required: {path}")
    return resolved


def device_numbers(device):
    """Linux major/minor values must agree with the device field from procfs."""
    if not hasattr(os, "major"):
        raise ProbeError("Linux device identity is unavailable", "inconclusive")
    return os.major(device), os.minor(device)


def file_identity(path):
    """Open only the named backing file; fstat ties identity to that open file."""
    resolved = canonical(path)
    try:
        with resolved.open("rb") as stream:
            metadata = os.fstat(stream.fileno())
    except OSError as error:
        raise ProbeError(f"backing file unreadable: {resolved}: {error}", "inconclusive") from error
    if not stat.S_ISREG(metadata.st_mode):
        raise ProbeError(f"regular backing file required: {resolved}", "inconclusive")
    major, minor = device_numbers(metadata.st_dev)
    return {"path": str(resolved), "identity": (major, minor, metadata.st_ino)}


def parse_maps(content):
    """Parse one snapshot in linear time, retaining unrelated and anonymous rows."""
    records = []
    for line in content.splitlines():
        fields = line.split(maxsplit=5)
        if len(fields) < 5:
            raise ProbeError("malformed process mapping", "inconclusive")
        address, permissions, offset, device, inode = fields[:5]
        try:
            start, end = (int(part, 16) for part in address.split("-"))
            major, minor = (int(part, 16) for part in device.split(":"))
            number = int(inode, 10)
            if start >= end or min(start, major, minor, number, int(offset, 16)) < 0:
                raise ValueError("invalid range or identity")
            if not re.fullmatch(r"[r-][w-][x-][ps]", permissions):
                raise ValueError("invalid permissions")
        except ValueError as error:
            raise ProbeError(f"malformed process mapping: {error}", "inconclusive") from error
        name = fields[5] if len(fields) == 6 else ""
        deleted = name.endswith(" (deleted)")
        records.append({"path": name[:-10] if deleted else name,
                        "deleted": deleted, "identity": (major, minor, number)})
    if not records:
        raise ProbeError("process mappings are empty", "inconclusive")
    return records


def read_maps():
    """Read this process's map snapshot once; missing procfs never implies success."""
    try:
        return Path("/proc/self/maps").read_text(encoding="utf-8", errors="surrogateescape")
    except OSError as error:
        raise ProbeError(f"process mappings unavailable: {error}", "inconclusive") from error


def mapping_identity(record):
    """Resolve procfs path spelling and require its current inode to match the map.

    Procfs escapes newlines. Literal backslash sequences can be ambiguous, so
    try the literal spelling first and accept only a device/inode match. The
    decoded spelling also supports escaped whitespace from mapping fixtures.
    """
    if record["deleted"]:
        raise ProbeError("deleted library mapping", "inconclusive")
    raw = record["path"]
    decoded = re.sub(r"\\(012|011|040|134)", lambda match: chr(int(match[1], 8)), raw)
    failure = ProbeError("mapped backing file identity differs from disk")
    for name in dict.fromkeys((raw, decoded)):
        try:
            observed = file_identity(name)
        except ProbeError as error:
            failure = error
            continue
        if observed["identity"] == record["identity"]:
            return observed
    raise failure


def match_library(records, expected, root, family):
    """Require exactly the expected SQLite/libpython backing identity and path."""
    root = directory(root)
    wanted = file_identity(expected)
    require_inside(Path(wanted["path"]), root, f"expected {family}")
    names = {Path(expected).name, Path(wanted["path"]).name}
    family_prefix = "libsqlite3" if family == "sqlite" else "libpython"
    seen = set()
    identities = set()
    matched = None
    unexpected = None
    for record in records:
        name = Path(record["path"]).name
        relevant = (name.startswith(family_prefix) or name in names
                    or record["identity"] == wanted["identity"])
        if not relevant:
            continue
        key = (record["path"], record["identity"], record["deleted"])
        if key in seen:
            continue
        seen.add(key)
        observed = mapping_identity(record)
        identities.add(observed["identity"])
        try:
            require_inside(Path(observed["path"]), root, f"mapped {family}")
            if observed != wanted:
                raise ProbeError(f"unexpected {family} provider: {observed['path']}")
        except ProbeError as error:
            # Finish the snapshot so multiple providers have one order-independent outcome.
            unexpected = unexpected or error
        else:
            matched = observed
    if len(identities) > 1:
        raise ProbeError(f"ambiguous {family} backing identities", "inconclusive")
    if unexpected is not None:
        raise unexpected
    if matched is None:
        raise ProbeError(f"expected {family} mapping was not observed", "inconclusive")
    return matched


def database_roundtrip(sqlite, scratch):
    """Commit, close, reopen and read one fixed record in an owned temporary DB."""
    scratch = directory(scratch)
    with tempfile.TemporaryDirectory(prefix="sqlite-probe-", dir=scratch) as owned:
        database = str(Path(owned) / "probe.sqlite")
        with closing(sqlite.connect(database)) as connection:
            connection.execute("CREATE TABLE probe (id INTEGER PRIMARY KEY, value TEXT)")
            connection.execute("INSERT INTO probe VALUES (?, ?)", (1, "cplx-sqlite-probe"))
            connection.commit()
        with closing(sqlite.connect(database)) as connection:
            record = connection.execute("SELECT id, value FROM probe").fetchall()
        if record != [(1, "cplx-sqlite-probe")]:
            raise ProbeError("database record did not survive close and reopen")
    return "passed"


def check_extension(args, extension, python_root, executable):
    """Keep source-generated links distinct from installed lib-dynload bounds."""
    imported = Path(os.path.abspath(extension))
    extension_root = directory(args.expected_extension_root)
    require_inside(extension_root, python_root, "extension root")
    backing = canonical(extension)
    if args.stage == "build":
        # CPython places the configured shared library alongside its executable.
        build_root = canonical(args.expected_libpython).parent
        require_inside(build_root, python_root, "build root")
        if executable.parent != build_root:
            raise ProbeError("source executable differs from the declared libpython build")
        require_inside(extension_root, build_root, "generated extension directory")
        # Normalize symlinked root spelling without resolving the module link itself.
        imported = canonical(imported.parent) / imported.name
        require_inside(imported, extension_root, "extension import path")
        modules = directory(build_root / "Modules")
        require_inside(modules, build_root, "Modules directory")
        require_inside(backing, modules, "source extension backing")
    else:
        require_inside(backing, extension_root, "installed extension backing")
    if not backing.is_file():
        raise ProbeError("extension backing is not a regular file")
    return {"import_path": str(extension), "path": str(backing)}


def assess(args):
    """Return partial evidence on every failure while keeping one JSON result."""
    result = {"stage": args.stage, "python_version": sys.version,
              "executable": sys.executable, "extension": None,
              "database": "not-run", "provider": None, "outcome": "failed"}
    try:
        if args.stage not in ("build", "installed", "operator"):
            raise ProbeError("unknown probe stage")
        if args.stage == "build" and not args.expected_libpython:
            raise ProbeError("build stage requires --expected-libpython")
        python_root = directory(args.expected_python_root)
        executable = canonical(sys.executable)
        require_inside(executable, python_root, "Python executable")
        result["executable"] = str(executable)
        native = importlib.import_module("_sqlite3")
        result["extension"] = check_extension(args, native.__file__, python_root, executable)
        sqlite = importlib.import_module("sqlite3")
        result["database"] = "failed"
        result["database"] = database_roundtrip(sqlite, args.scratch_dir)
        records = parse_maps(read_maps())
        result["provider"] = match_library(records, args.expected_provider, python_root, "sqlite")
        if args.stage == "build":
            result["libpython"] = match_library(records, args.expected_libpython,
                                                canonical(args.expected_libpython).parent, "python")
        result["outcome"] = "passed"
    except ProbeError as error:
        result.update(outcome=error.outcome, error=str(error))
    except Exception as error:
        # SQLite/import/IO failures must not prevent machine-readable diagnostics.
        result.update(outcome="failed", error=f"{type(error).__name__}: {error}")
    return result


def main(argv=None):
    parser = ProbeArguments(description=__doc__, allow_abbrev=False)
    parser.add_argument("--stage", choices=("build", "installed", "operator"), required=True)
    for name in ("expected-python-root", "expected-extension-root", "expected-provider", "scratch-dir"):
        parser.add_argument("--" + name, required=True)
    parser.add_argument("--expected-libpython")
    try:
        result = assess(parser.parse_args(argv))
    except ProbeError as error:
        result = {"outcome": error.outcome, "error": str(error)}
    print(json.dumps(result, ensure_ascii=True))
    return 0 if result["outcome"] == "passed" else 2


if __name__ == "__main__":
    sys.exit(main())
