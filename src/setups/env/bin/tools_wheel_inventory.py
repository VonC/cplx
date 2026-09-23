"""Bind retained wheel bytes to installed ELF bytes without dependency resolution.

Capture takes an explicit directory containing the wheels used by sync and the
agent's site-packages root. Every installed ELF must match exactly one wheel
member, including .data purelib/platlib relocation. Materialization verifies the
lock, all wheel hashes and the same ELF set before publishing a private root.
An opt-in venv inventory also maps wheel .data/scripts ELF members into bin,
while preserving the schema-1 site-packages interface and generated Python links.
Describe emits identities only: closure_elf remains the sole ABI interpreter.
Python 3.9+; standard library only, independent of the candidate interpreter.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import sys
import zipfile


def require(condition, message):
    if not condition:
        raise ValueError(message)


def safe_path(value):
    require(isinstance(value, str) and value, "empty path")
    require(not any(ord(c) < 32 or c in "\\|:" for c in value), "unsafe wheel member: " + repr(value))
    path = PurePosixPath(value)
    require(not path.is_absolute() and all(p not in ("", ".", "..") for p in value.split("/")),
            "unsafe wheel member: " + repr(value))
    return value


def digest(path):
    with open(path, "rb") as stream:
        return stream_digest(stream)[0]


def stream_digest(stream, output=None):
    sha = hashlib.sha256()
    first = stream.read(1024 * 1024)
    elf = first.startswith(b"\x7fELF")
    block = first
    while block:
        sha.update(block)
        if output is not None:
            output.write(block)
        block = stream.read(1024 * 1024)
    return sha.hexdigest(), elf


def installed_name(member, venv=False):
    parts = member.split("/")
    if parts[0].endswith(".data"):
        require(len(parts) > 2 and parts[1] in (("purelib", "platlib", "scripts") if venv else ("purelib", "platlib")),
                "ELF outside site-packages: " + member)
        if parts[1] == "scripts":
            require(len(parts) == 3, "nested ELF script destination")
            return "bin/" + parts[2]
        return ("site/" if venv else "") + "/".join(parts[2:])
    return ("site/" if venv else "") + member


def wheel_members(wheel, destination=None, venv=False):
    """Read each member once, refusing links, collisions and unsafe ZIP names."""
    seen = set()
    files = set()
    directories = set()
    elfs = []
    for item in wheel.infolist():
        name = safe_path(item.filename.rstrip("/") if item.is_dir() else item.filename)
        require(name not in seen, "duplicate wheel member: " + name)
        seen.add(name)
        mode = item.external_attr >> 16
        require(stat.S_IFMT(mode) in (0, stat.S_IFREG, stat.S_IFDIR), "unsafe wheel member type: " + name)
        parts = name.split("/")
        parents = ["/".join(parts[:i]) for i in range(1, len(parts))]
        require(not any(parent in files for parent in parents), "wheel file/directory collision")
        directories.update(parents)
        if item.is_dir():
            require(name not in files, "wheel file/directory collision")
            directories.add(name)
            continue
        require(name not in directories, "wheel file/directory collision")
        files.add(name)
        with wheel.open(item) as source:
            if destination is None:
                sha, elf = stream_digest(source)
            else:
                target = destination / name
                target.parent.mkdir(parents=True, exist_ok=True)
                with target.open("xb") as output:
                    sha, elf = stream_digest(source, output)
        if elf:
            elfs.append({"member": name, "installed": installed_name(name, venv), "sha256": sha})
    return elfs


def installed_elfs(root):
    require(root.is_dir() and not root.is_symlink(), "installed root unavailable")
    result = {}

    def failed(error):
        raise error

    for folder, dirs, files in os.walk(root, onerror=failed):
        for name in dirs + files:
            require(not (Path(folder) / name).is_symlink(), "symlink in installed inventory")
        for name in files:
            path = Path(folder) / name
            with path.open("rb") as stream:
                prefix = stream.read(4)
                if prefix != b"\x7fELF":
                    continue
                stream.seek(0)
                sha, _ = stream_digest(stream)
            result[safe_path(path.relative_to(root).as_posix())] = sha
    return result


def venv_elfs(site_root, venv_root, expected):
    """Inspect site and bin, allowing only generated interpreter ELF links."""
    require(venv_root.is_dir() and not venv_root.is_symlink(), "venv root unavailable")
    bin_root = venv_root / "bin"
    require(bin_root.is_dir() and not bin_root.is_symlink(), "venv bin unavailable")
    result = {"site/" + name: sha for name, sha in installed_elfs(site_root).items()}
    interpreter = re.compile(r"python(?:3(?:\.\d+)?)?\Z")
    for path in bin_root.iterdir():
        name = safe_path(path.name)
        key = "bin/" + name
        if path.is_symlink():
            require(interpreter.fullmatch(name) and key not in expected,
                    "symlink in wheel executable inventory")
            continue
        require(path.is_file(), "non-file in venv bin")
        with path.open("rb") as stream:
            if stream.read(4) != b"\x7fELF":
                continue
            stream.seek(0)
            sha, _ = stream_digest(stream)
        if key not in expected and interpreter.fullmatch(name):
            continue
        result[key] = sha
    return result


def unique_object(pairs):
    obj = {}
    for key, value in pairs:
        require(key not in obj, "duplicate inventory field: " + key)
        obj[key] = value
    return obj


def hash_value(value):
    require(isinstance(value, str) and len(value) == 64 and all(c in "0123456789abcdef" for c in value),
            "invalid SHA-256")


def load_inventory(path, lock, profile=None):
    with path.open(encoding="utf-8") as stream:
        data = json.load(stream, object_pairs_hook=unique_object)
    require(data.get("schema") in (1, 2) and
            set(data) == ({"schema", "lock_sha256", "wheels"} if data.get("schema") == 1 else
                          {"schema", "lock_sha256", "profile_sha256", "wheels"}),
            "unsupported wheel inventory")
    hash_value(data["lock_sha256"])
    if data["schema"] == 2:
        hash_value(data["profile_sha256"])
        require(profile is not None and data["profile_sha256"] == digest(profile),
                "qualified profile digest mismatch")
    require(data["lock_sha256"] == digest(lock), "lock digest mismatch")
    require(isinstance(data["wheels"], list) and data["wheels"], "empty wheel inventory")
    names = set()
    installed = set()
    for wheel in data["wheels"]:
        require(set(wheel) == {"filename", "sha256", "elfs"}, "invalid wheel fields")
        name = safe_path(wheel["filename"])
        require("/" not in name and name.endswith(".whl") and name not in names, "invalid wheel filename")
        names.add(name)
        hash_value(wheel["sha256"])
        require(isinstance(wheel["elfs"], list), "invalid ELF inventory")
        members = set()
        for elf in wheel["elfs"]:
            require(set(elf) == {"member", "installed", "sha256"}, "invalid ELF fields")
            member = safe_path(elf["member"])
            target = safe_path(elf["installed"])
            require(member not in members and target not in installed and target == installed_name(member, data["schema"] == 2),
                    "duplicate or invalid installed ELF inventory")
            members.add(member)
            installed.add(target)
            hash_value(elf["sha256"])
    if data["schema"] == 2:
        with profile.open(encoding="utf-8") as stream:
            qualified = json.load(stream, object_pairs_hook=unique_object)
        chosen = {row["filename"]: row["sha256"] for row in qualified["selected"]}
        require(len(chosen) == len(qualified["selected"]) and
                chosen == {row["filename"]: row["sha256"] for row in data["wheels"]},
                "qualified wheel selection mismatch")
    return data


def elf_map(elfs):
    return {elf["member"]: (elf["installed"], elf["sha256"]) for elf in elfs}


def capture(args):
    wheels = []
    expected = {}
    lock_sha = digest(args.lock)
    selected = None
    if args.venv_root is not None:
        require(args.profile is not None, "schema-2 capture requires qualified profile")
        with args.profile.open(encoding="utf-8") as stream:
            profile = json.load(stream, object_pairs_hook=unique_object)
        require(profile["lock_sha256"] == lock_sha, "profile lock digest mismatch")
        selected = {}
        for row in profile["selected"]:
            name = safe_path(row["filename"])
            require("/" not in name and name not in selected, "invalid selected wheel filename")
            hash_value(row["sha256"])
            selected[name] = row["sha256"]
        require(selected, "empty selected wheel set")
    else:
        require(args.profile is None, "profile requires venv-aware capture")
    for path in args.wheel_dir.iterdir():
        if path.suffix != ".whl" or (selected is not None and path.name not in selected):
            continue
        safe_path(path.name)
        require(path.is_file() and not path.is_symlink(), "wheel unavailable: " + path.name)
        # Hold one descriptor across hashing and ZIP reads: never reselect bytes.
        with path.open("rb") as stream:
            sha, _ = stream_digest(stream)
            if selected is not None:
                require(sha == selected[path.name], "selected wheel digest mismatch: " + path.name)
            stream.seek(0)
            with zipfile.ZipFile(stream) as wheel:
                elfs = wheel_members(wheel, venv=args.venv_root is not None)
            stream.seek(0)
            require(stream_digest(stream)[0] == sha, "wheel changed during capture")
        for elf in elfs:
            require(elf["installed"] not in expected, "duplicate installed ELF inventory")
            expected[elf["installed"]] = elf["sha256"]
        wheels.append({"filename": path.name, "sha256": sha, "elfs": elfs})
    require(wheels, "no retained wheels supplied")
    if selected is not None:
        require({wheel["filename"] for wheel in wheels} == set(selected),
                "selected wheel unavailable")
    actual = (venv_elfs(args.installed_root, args.venv_root, expected)
              if args.venv_root is not None else installed_elfs(args.installed_root))
    require(expected == actual, "installed ELF inventory mismatch")
    require(digest(args.lock) == lock_sha, "lock changed during capture")
    data = {"schema": 2 if args.venv_root is not None else 1,
            "lock_sha256": lock_sha, "wheels": wheels}
    if selected is not None:
        data["profile_sha256"] = digest(args.profile)
    with args.output.open("x", encoding="utf-8") as stream:
        json.dump(data, stream, indent=2)
        stream.write("\n")
    print("wheel inventory: captured; installed walks=1 wheels=" + str(len(wheels)))


def materialize(args):
    data = load_inventory(args.inventory, args.lock, args.profile)
    # mkdir is exclusive: cleanup can only remove the directory this call owns.
    args.destination.mkdir(mode=0o700)
    try:
        subjects = args.destination / "subjects"
        subjects.mkdir()
        for entry in data["wheels"]:
            path = args.wheel_dir / entry["filename"]
            require(path.is_file() and not path.is_symlink(), "wheel unavailable: " + entry["filename"])
            with path.open("rb") as stream:
                require(stream_digest(stream)[0] == entry["sha256"], "wheel digest mismatch: " + entry["filename"])
                stream.seek(0)
                with zipfile.ZipFile(stream) as wheel:
                    actual = wheel_members(wheel, subjects / entry["filename"], data["schema"] == 2)
                require(elf_map(actual) == elf_map(entry["elfs"]), "wheel ELF inventory mismatch")
                stream.seek(0)
                require(stream_digest(stream)[0] == entry["sha256"], "wheel changed during extraction")
        require(digest(args.lock) == data["lock_sha256"], "lock changed during extraction")
        with (args.destination / "inventory.json").open("x", encoding="utf-8") as stream:
            json.dump(data, stream, indent=2)
            stream.write("\n")
    except BaseException:
        shutil.rmtree(args.destination)
        raise
    print("wheel inventory: materialized " + str(args.destination))


def describe(args):
    require(args.root.is_dir() and not args.root.is_symlink(), "wheel root unavailable")
    data = load_inventory(args.root / "inventory.json", args.lock, args.profile)
    for wheel in data["wheels"]:
        for elf in wheel["elfs"]:
            print("\t".join((wheel["filename"] + "/" + elf["member"], elf["sha256"],
                             wheel["filename"], wheel["sha256"], elf["installed"])))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    for name, handler, fields in (
        ("capture", capture, ("wheel-dir", "installed-root", "output")),
        ("materialize", materialize, ("wheel-dir", "inventory", "destination")),
        ("describe", describe, ("root",)),
    ):
        command = commands.add_parser(name)
        command.set_defaults(handler=handler)
        for field in ("lock",) + fields:
            command.add_argument("--" + field, required=True, type=Path)
        command.add_argument("--profile", type=Path,
                             help="qualified selection for schema-2 inventory")
        if name == "capture":
            command.add_argument("--venv-root", type=Path,
                                 help="opt in to schema-2 site and bin ELF mapping")
    args = parser.parse_args()
    try:
        require(sys.version_info >= (3, 9), "independent Python 3.9+ required")
        args.handler(args)
    except (OSError, ValueError, TypeError, KeyError, zipfile.BadZipFile, RuntimeError) as error:
        print("wheel inventory: INCONCLUSIVE: " + str(error), file=sys.stderr)
        return 5
    return 0


if __name__ == "__main__":
    sys.exit(main())
