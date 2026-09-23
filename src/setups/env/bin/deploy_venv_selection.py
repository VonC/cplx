"""Check a qualified uv selection against canonical lock, wheels and installed metadata."""

from __future__ import annotations

import argparse
import ast
import hashlib
import importlib.metadata
import json
from pathlib import Path
import re
import sys
import tomllib
from urllib.parse import unquote, urlsplit

SHA = re.compile(r"[0-9a-f]{64}\Z")
NAME = re.compile(r"[-_.]+")


def require(ok, message):
    if not ok:
        raise ValueError(message)


def digest(path):
    value = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def normalized(name):
    require(isinstance(name, str) and bool(name), "empty distribution name")
    return NAME.sub("-", name).lower()


def unique(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, "duplicate profile field")
        result[key] = value
    return result


def wheel_tags(filename):
    require(isinstance(filename, str) and filename.endswith(".whl") and Path(filename).name == filename,
            "invalid wheel filename")
    fields = filename[:-4].split("-")
    require(len(fields) in (5, 6), "invalid wheel filename")
    return fields[0], fields[1], {"-".join(tag) for tag in
                                  ((py, abi, platform) for py in fields[-3].split(".")
                                   for abi in fields[-2].split(".")
                                   for platform in fields[-1].split("."))}


def installed(root):
    """Read distribution metadata once and reject normalized collisions."""
    require(root.is_dir() and not root.is_symlink(), "site-packages unavailable")
    result = {}
    for distribution in importlib.metadata.distributions(path=[str(root)]):
        name = normalized(distribution.metadata["Name"])
        require(name not in result, "duplicate installed distribution: " + name)
        result[name] = distribution.version
    return result


def marker_value(node, variables):
    """Evaluate only the comparison/Boolean grammar of PEP 508 markers."""
    if isinstance(node, ast.Expression):
        return marker_value(node.body, variables)
    if isinstance(node, ast.Name):
        require(node.id in variables, "unknown marker variable: " + node.id)
        return variables[node.id]
    if isinstance(node, ast.Constant) and isinstance(node.value, str):
        return node.value
    if isinstance(node, ast.BoolOp) and isinstance(node.op, (ast.And, ast.Or)):
        values = [marker_value(item, variables) for item in node.values]
        require(all(isinstance(value, bool) for value in values), "invalid marker Boolean")
        return all(values) if isinstance(node.op, ast.And) else any(values)
    if isinstance(node, ast.Compare):
        left = marker_value(node.left, variables)
        left_node = node.left
        for operator, right_node in zip(node.ops, node.comparators):
            right = marker_value(right_node, variables)
            require(isinstance(left, str) and isinstance(right, str), "invalid marker comparison")
            version_field = {"python_version", "python_full_version", "implementation_version"}
            if (isinstance(left_node, ast.Name) and left_node.id in version_field or
                    isinstance(right_node, ast.Name) and right_node.id in version_field):
                require(re.fullmatch(r"\d+(?:\.\d+)*", left) and
                        re.fullmatch(r"\d+(?:\.\d+)*", right),
                        "invalid numeric marker version")
                left_parts = tuple(map(int, left.split(".")))
                right_parts = tuple(map(int, right.split(".")))
                width = max(len(left_parts), len(right_parts))
                ordered_left = left_parts + (0,) * (width - len(left_parts))
                ordered_right = right_parts + (0,) * (width - len(right_parts))
            else:
                ordered_left, ordered_right = left, right
            if isinstance(operator, ast.Eq):
                result = ordered_left == ordered_right
            elif isinstance(operator, ast.NotEq):
                result = ordered_left != ordered_right
            elif isinstance(operator, ast.In):
                result = left in right
            elif isinstance(operator, ast.NotIn):
                result = left not in right
            elif isinstance(operator, (ast.Lt, ast.LtE, ast.Gt, ast.GtE)):
                result = ((ordered_left < ordered_right) if isinstance(operator, ast.Lt) else
                          (ordered_left <= ordered_right) if isinstance(operator, ast.LtE) else
                          (ordered_left > ordered_right) if isinstance(operator, ast.Gt) else
                          ordered_left >= ordered_right)
            else:
                raise ValueError("unsupported marker operator")
            if not result:
                return False
            left = right
            left_node = right_node
        return True
    raise ValueError("unsupported marker expression")


def selected_lock_packages(lock, profile):
    """Traverse root, group and extra edges under the explicit target marker set."""
    variables = profile["markers"]
    require(isinstance(variables, dict) and all(isinstance(key, str) and
            isinstance(value, str) for key, value in variables.items()),
            "invalid target markers")
    packages = {}
    roots = []
    for package in lock.get("package", []):
        name = normalized(package["name"])
        packages.setdefault(name, []).append(package)
        if package.get("source", {}).get("virtual") == ".":
            roots.append(package)
    require(len(roots) == 1, "canonical lock needs one virtual project root")
    require(not profile["extras"] or roots[0].get("optional-dependencies"),
            "unknown project extra")
    queue = [(roots[0], frozenset(profile["extras"]), True)]
    for group in profile["groups"]:
        require(group in roots[0].get("dev-dependencies", {}), "unknown dependency group")
        queue.extend((dependency, frozenset(), False) for dependency in
                     roots[0]["dev-dependencies"][group])
    for extra in profile["extras"]:
        require(extra in roots[0].get("optional-dependencies", {}), "unknown project extra")
        queue.extend((dependency, frozenset(), False) for dependency in
                     roots[0]["optional-dependencies"][extra])
    result = {}
    visited = set()
    while queue:
        item, extras, is_root = queue.pop()
        if is_root:
            package = item
        else:
            marker = item.get("marker")
            if marker:
                require(isinstance(marker, str), "invalid dependency marker")
                active = extras or frozenset(("",))
                if not any(marker_value(ast.parse(marker, mode="eval"),
                                        variables | {"extra": extra}) for extra in active):
                    continue
            name = normalized(item["name"])
            matches = [candidate for candidate in packages.get(name, []) if
                       "version" not in item or candidate["version"] == item["version"]]
            require(len(matches) == 1, "ambiguous or missing locked dependency: " + name)
            package = matches[0]
            extras = frozenset(item.get("extra", item.get("extras", [])))
        name = normalized(package["name"])
        if package is not roots[0]:
            require(name not in result or result[name] == package["version"],
                    "conflicting selected package versions")
            result[name] = package["version"]
        state = (name, package["version"], extras)
        if state in visited:
            continue
        visited.add(state)
        queue.extend((dependency, extras, False) for dependency in package.get("dependencies", []))
        for extra in extras:
            queue.extend((dependency, frozenset(), False) for dependency in
                         package.get("optional-dependencies", {}).get(extra, []))
    return result


def effective_groups(project, profile):
    defaults = project.get("tool", {}).get("uv", {}).get("default-groups", ["dev"])
    require(isinstance(defaults, list) and all(isinstance(item, str) for item in defaults),
            "invalid project default groups")
    require(isinstance(profile["no_default_groups"], bool), "invalid default-group policy")
    require(not set(profile["requested_groups"]).intersection(profile["excluded_groups"]),
            "conflicting group selection")
    selected = set() if profile["no_default_groups"] else set(defaults)
    selected.difference_update(profile["excluded_groups"])
    selected.update(profile["requested_groups"])
    require(selected == set(profile["groups"]), "effective dependency groups mismatch")


def verify(lock_path, project_path, profile_path, wheel_dir, installed_root,
           inventory_path=None, manifest_path=None, target_profile_path=None):
    """Bind one qualified selection and every original wheel to exact installs."""
    with Path(profile_path).open(encoding="utf-8") as stream:
        profile = json.load(stream, object_pairs_hook=unique)
    required = {"schema", "lock_sha256", "project_sha256", "target", "python", "tags",
                "markers", "groups", "requested_groups", "excluded_groups",
                "no_default_groups", "extras",
                "qualified_uv", "toolchain_sha256", "source_revision", "selected"}
    require(isinstance(profile, dict) and set(profile) == required and profile["schema"] == 1,
            "unsupported qualified selection profile")
    lock_sha = digest(lock_path)
    require(profile["lock_sha256"] == lock_sha, "selection lock digest mismatch")
    project_sha = digest(project_path)
    require(profile["project_sha256"] == project_sha, "selection project digest mismatch")
    for field in ("target", "python", "qualified_uv", "source_revision"):
        require(isinstance(profile[field], str) and profile[field], "missing selection provenance")
    require(isinstance(profile["toolchain_sha256"], str) and
            SHA.fullmatch(profile["toolchain_sha256"]), "invalid toolchain digest")
    if manifest_path is not None:
        with Path(manifest_path).open(encoding="utf-8") as stream:
            manifest = json.load(stream, object_pairs_hook=unique)
        require(manifest["tools"]["sha256"] == profile["toolchain_sha256"],
                "selection toolchain digest mismatch")
        require(manifest["application"]["revision"] == profile["source_revision"],
                "selection source revision mismatch")
        if target_profile_path is not None:
            bundle_root = Path(manifest_path).resolve().parent
            require(any((bundle_root / row["path"]).resolve() ==
                        Path(target_profile_path).resolve()
                        for row in manifest["profiles"]),
                    "target profile absent from release manifest")
    if target_profile_path is not None:
        with Path(target_profile_path).open(encoding="utf-8") as stream:
            target_profile = json.load(stream, object_pairs_hook=unique)
        require(target_profile["os"] == profile["markers"].get("sys_platform") and
                target_profile["arch"] == profile["markers"].get("platform_machine") and
                target_profile["arch"] in profile["target"] and
                set(target_profile["groups"]) == set(profile["groups"]) and
                set(target_profile["extras"]) == set(profile["extras"]),
                "selection target profile mismatch")
    for field in ("tags", "groups", "requested_groups", "excluded_groups", "extras"):
        require(isinstance(profile[field], list) and len(set(profile[field])) == len(profile[field])
                and all(isinstance(item, str) and item for item in profile[field]),
                "invalid selection " + field)
    require(profile["tags"] and isinstance(profile["selected"], list), "empty selection tags")
    with Path(lock_path).open("rb") as stream:
        lock = tomllib.load(stream)
    with Path(project_path).open("rb") as stream:
        project = tomllib.load(stream)
    effective_groups(project, profile)
    locked = {}
    for package in lock.get("package", []):
        key = (normalized(package["name"]), package["version"])
        require(key not in locked, "ambiguous lock package identity")
        locked[key] = package
    expected = selected_lock_packages(lock, profile)
    chosen = {}
    wheel_manifest = []
    for row in profile["selected"]:
        require(isinstance(row, dict) and set(row) == {"name", "version", "filename", "sha256"},
                "invalid selected wheel")
        name = normalized(row["name"])
        require(name not in chosen, "duplicate selected distribution")
        key = (name, row["version"])
        require(key in locked, "selected distribution absent from lock")
        filename = row["filename"]
        wheel_name, wheel_version, tags = wheel_tags(filename)
        require(normalized(wheel_name) == name and wheel_version == row["version"],
                "wheel filename identity mismatch")
        require(bool(tags.intersection(profile["tags"])), "wheel tag excluded by profile")
        sha = row["sha256"]
        require(isinstance(sha, str) and SHA.fullmatch(sha), "invalid wheel digest")
        wheels = locked[key].get("wheels", [])
        require(any(Path(unquote(urlsplit(wheel.get("url", "")).path)).name == filename
                    and wheel.get("hash") == "sha256:" + sha for wheel in wheels),
                "selected wheel absent from canonical lock")
        path = Path(wheel_dir) / filename
        require(path.is_file() and not path.is_symlink() and digest(path) == sha,
                "retained original wheel mismatch: " + filename)
        chosen[name] = row["version"]
        wheel_manifest.append(row)
    require(chosen == expected, "qualified selection differs from lock marker/group/extra closure")
    require(chosen == installed(Path(installed_root)), "installed distribution selection mismatch")
    if inventory_path is not None:
        with Path(inventory_path).open(encoding="utf-8") as stream:
            inventory = json.load(stream, object_pairs_hook=unique)
        require(inventory["schema"] == 2 and inventory["lock_sha256"] == lock_sha
                and inventory["profile_sha256"] == digest(profile_path),
                "ELF inventory identity mismatch")
        inventory_wheels = {row["filename"]: row["sha256"]
                            for row in inventory["wheels"]}
        require(len(inventory_wheels) == len(inventory["wheels"]) and
                inventory_wheels == {row["filename"]: row["sha256"]
                                     for row in wheel_manifest},
                "ELF inventory wheel selection mismatch")
    require(digest(lock_path) == lock_sha, "lock changed during selection check")
    require(digest(project_path) == project_sha, "project metadata changed during selection check")
    return {"lock_sha256": lock_sha, "project_sha256": project_sha,
            "toolchain_sha256": profile["toolchain_sha256"],
            "profile_sha256": digest(profile_path),
            "wheel_manifest_sha256": hashlib.sha256(json.dumps(sorted(wheel_manifest,
                key=lambda row: normalized(row["name"])),
                sort_keys=True, separators=(",", ":")).encode()).hexdigest(),
            "distributions": len(chosen)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for field in ("lock", "project", "profile", "wheel-dir", "installed-root"):
        parser.add_argument("--" + field, required=True, type=Path)
    parser.add_argument("--inventory", type=Path)
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--target-profile", type=Path)
    args = parser.parse_args()
    try:
        print(json.dumps(verify(args.lock, args.project, args.profile,
                                args.wheel_dir, args.installed_root, args.inventory,
                                args.manifest, args.target_profile),
                         sort_keys=True))
    except (OSError, ValueError, KeyError, TypeError, SyntaxError,
            tomllib.TOMLDecodeError) as error:
        print("Selection INCONCLUSIVE: " + str(error), file=sys.stderr)
        return 5
    return 0


if __name__ == "__main__":
    sys.exit(main())
