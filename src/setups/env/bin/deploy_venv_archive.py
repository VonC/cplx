"""Package declared application roots without any discovered Python venv.

The caller owns the package coordinates. This adapter supplies literal exclusions
to pkg.sh and inspects the final archive before it can be used as a release input.
It never follows directory aliases while walking the source tree.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path, PurePosixPath
import subprocess
import sys
import tarfile
import xml.etree.ElementTree as ET


def discover(roots):
    """Walk each declared root once and return its venv boundary names."""
    result = {}
    for supplied in roots:
        root = Path(supplied)
        if root.is_symlink() or not root.exists():
            raise ValueError("packaging root absent or aliased: " + str(root))
        found = set()
        if root.is_dir():
            for directory, dirs, files in os.walk(root, topdown=True, followlinks=False):
                base = Path(directory)
                relative = base.relative_to(root)
                if "pyvenv.cfg" in files:
                    found.add(relative.as_posix() if relative.parts else ".")
                    dirs.clear()
                    continue
                for name in dirs[:]:
                    alias = base / name
                    if alias.is_symlink():
                        dirs.remove(name)
                        target = alias.resolve(strict=True)
                        if target.is_dir() and (target / "pyvenv.cfg").is_file():
                            found.add(alias.relative_to(root).as_posix())
                # A symlink named pyvenv.cfg is itself a venv boundary.
                if (base / "pyvenv.cfg").is_symlink():
                    found.add(relative.as_posix() if relative.parts else ".")
                    dirs.clear()
        result[root] = found
    return result


def validate_tar_rules(rules):
    """Accept only the existing application exclusion vocabulary."""
    switches = {"--no-wildcards-match-slash", "--wildcards-match-slash"}
    for rule in rules:
        if rule in switches:
            continue
        if (not rule.startswith("--exclude=") or len(rule) == len("--exclude=")
                or any(char in rule for char in "\x00\r\n")):
            raise ValueError("unsafe tar option: " + rule)
    return rules


def exclusions(roots, found=None):
    """Convert discovered roots to literal GNU tar exclusions."""
    arguments = ["--no-wildcards"]
    excluded = set()
    if found is None:
        found = discover(roots.values())
    for archive_name, source in roots.items():
        for relative in found[Path(source)]:
            name = archive_name if relative == "." else archive_name + "/" + relative
            if any(char in name for char in "\x00\r\n"):
                raise ValueError("venv name cannot be passed safely to tar")
            excluded.add(name)
            arguments.append("--exclude=" + name)
    return arguments, excluded


def inspect(archive_path, required=(), excluded=()):
    """Reject venv payloads and omissions in the produced regular archive."""
    seen = set()
    excluded = set(excluded)
    with tarfile.open(archive_path, "r:*") as archive:
        for member in archive:
            name = member.name.removeprefix("./").rstrip("/")
            parts = PurePosixPath(name).parts
            if (not name or name.startswith("/") or ".." in parts
                    or any(char in name for char in "\x00\r\n")):
                raise ValueError("unsafe archive member")
            if name in seen:
                raise ValueError("duplicate archive member")
            seen.add(name)
            parent = name
            within_excluded = parent in excluded
            while not within_excluded and "/" in parent:
                parent = parent.rpartition("/")[0]
                within_excluded = parent in excluded
            if parts[-1] == "pyvenv.cfg" or within_excluded:
                raise ValueError("application venv found in archive: " + name)
        absent = set(required) - seen
        if absent:
            raise ValueError("required release input absent from archive: " + ", ".join(sorted(absent)))
    return seen


def descriptor(template, output, source, found=None):
    """Generate the assembly descriptor with the same discovered boundaries."""
    namespace = "http://maven.apache.org/ASSEMBLY/2.1.0"
    ET.register_namespace("", namespace)
    tree = ET.parse(template)
    excludes = tree.find(".//{" + namespace + "}fileSet/{" + namespace + "}excludes")
    if excludes is None:
        raise ValueError("assembly descriptor has no exclusion block")
    boundaries = (discover((Path(source),)) if found is None else found)[Path(source)]
    for relative in boundaries:
        if relative == ".":
            raise ValueError("the whole application root is a venv")
        ET.SubElement(excludes, "{" + namespace + "}exclude").text = relative + "/**"
        ET.SubElement(excludes, "{" + namespace + "}exclude").text = relative
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    tree.write(output, encoding="utf-8", xml_declaration=True)
    return boundaries


def package(pkg_sh, target, source_root, home_root, add, tar_rules, required,
            template=None, descriptor_path=None):
    """Run canonical pkg.sh, then verify its exact output before returning it."""
    validate_tar_rules(tar_rules)
    source_root = Path(source_root)
    home_root = Path(home_root)
    if not target or "/" in target or target in (".", ".."):
        raise ValueError("one target folder is required")
    roots = {target: source_root / target}
    for item in add:
        if not item or item.startswith("/") or ".." in PurePosixPath(item).parts:
            raise ValueError("unsafe extra packaging root")
        roots[item] = home_root / item
    found = discover(roots.values())
    args, excluded = exclusions(roots, found)
    if template or descriptor_path:
        if not template or not descriptor_path:
            raise ValueError("assembly template and descriptor must be supplied together")
        descriptor(template, descriptor_path, roots[target], found)
    command = ["bash", str(pkg_sh), target, "--source-root", str(source_root)]
    for item in add:
        command.extend(("--add", item))
    command.extend(("--", *tar_rules, *args))
    environment = {**os.environ, "HOME": str(home_root)}
    if "DEPLOY_VENV_HOST_LIB_PATH" in environment:
        environment["LD_LIBRARY_PATH"] = environment["DEPLOY_VENV_HOST_LIB_PATH"]
    run = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE, env=environment,
                         check=False)
    if run.returncode:
        raise ValueError("pkg.sh failed: " + run.stderr.strip())
    paths = [Path(line) for line in run.stdout.splitlines() if line.endswith(".tar.gz")]
    if not paths or not paths[-1].is_file():
        raise ValueError("pkg.sh did not identify its final archive")
    inspect(paths[-1], required, excluded)
    return paths[-1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("inspect", "package", "descriptor"))
    parser.add_argument("--archive", type=Path)
    parser.add_argument("--pkg-sh", type=Path)
    parser.add_argument("--target")
    parser.add_argument("--source-root", type=Path)
    parser.add_argument("--home-root", type=Path)
    parser.add_argument("--add", action="append", default=[])
    parser.add_argument("--tar-rule", action="append", default=[])
    parser.add_argument("--required", action="append", default=[])
    parser.add_argument("--template", type=Path)
    parser.add_argument("--descriptor", type=Path)
    parser.add_argument("--tree", type=Path)
    args = parser.parse_args()
    try:
        if args.operation == "inspect":
            inspect(args.archive, args.required)
        elif args.operation == "descriptor":
            descriptor(args.template, args.descriptor, args.tree)
        else:
            archive = package(args.pkg_sh, args.target, args.source_root,
                              args.home_root, args.add, args.tar_rule, args.required,
                              args.template, args.descriptor)
            print(archive)
    except (OSError, ValueError, tarfile.TarError) as error:
        print("Archive refused: " + str(error), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
