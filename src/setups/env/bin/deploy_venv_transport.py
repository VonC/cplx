"""Create disposable offline metadata by structurally mapping only URL locations.

The canonical files remain immutable. Before and after uv runs, parsed trees
must match through the exact inverse mapping, including dependency and wheel
hash identities. No resolver or source download is hidden in this adapter.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
import tomllib
from urllib.parse import unquote, urlsplit

# Isolated Python does not include the script directory; load only this delivered closure.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from deploy_venv_inputs import local_path, load, sha256, verify

LOCATION_KEYS = {"url", "registry", "index", "index-url", "extra-index-url"}


def checked_mapping(mapping):
    if not isinstance(mapping, dict):
        raise ValueError("location mapping must be an object")
    inverse = {}
    for source, target in mapping.items():
        for value in (source, target):
            if not isinstance(value, str):
                raise ValueError("location is not a string")
            parsed = urlsplit(value)
            if (parsed.scheme not in ("https", "http", "file") or parsed.username or parsed.password
                    or parsed.query or parsed.fragment or "\\" in value
                    or any(part == ".." for part in unquote(parsed.path).split("/"))):
                raise ValueError("unsafe transport URL")
            if parsed.scheme == "file" and (parsed.netloc or not parsed.path.startswith("/")):
                raise ValueError("file location must be local and absolute")
        if target in inverse:
            raise ValueError("ambiguous transport mapping")
        inverse[target] = source
    return inverse


def rewrite(document, mapping):
    """Visit each parsed node once; only explicitly mapped location values change."""
    checked_mapping(mapping)
    def visit(node, key=""):
        if isinstance(node, dict):
            return {name: visit(value, name) for name, value in node.items()}
        if isinstance(node, list):
            return [visit(value, key) for value in node]
        if key in LOCATION_KEYS and isinstance(node, str) and "://" in node:
            if node not in mapping:
                raise ValueError("unmapped or unsupported URL location")
            return mapping[node]
        return node
    return visit(document)


def validate(canonical, effective, mapping):
    """Round-trip comparison covers all fields, including previously unknown ones."""
    inverse = checked_mapping(mapping)
    if rewrite(effective, inverse) != canonical or rewrite(canonical, mapping) != effective:
        raise ValueError("transport changed dependency or artifact identity")


def dumps(document):
    """Emit standard TOML values without adding a third-party parser dependency."""
    def value(node):
        if isinstance(node, str):
            return json.dumps(node, ensure_ascii=False)
        if isinstance(node, bool):
            return "true" if node else "false"
        if isinstance(node, int):
            return str(node)
        if isinstance(node, list):
            return "[" + ", ".join(value(item) for item in node) + "]"
        if isinstance(node, dict):
            return "{ " + ", ".join(json.dumps(key) + " = " + value(item) for key, item in node.items()) + " }"
        raise ValueError("unsupported metadata value type")
    result = "\n".join(json.dumps(key) + " = " + value(item) for key, item in document.items()) + "\n"
    if tomllib.loads(result) != document:
        raise ValueError("TOML round trip changed metadata")
    return result


def mapping_for(manifest, root, base_url=None):
    """Resolve release-relative map targets only inside the retained companion."""
    transport = load(local_path(root, manifest["transport"]["path"]))
    if set(transport) != {"schema", "locations"} or transport["schema"] != 1:
        raise ValueError("invalid transport map")
    mapping = {}
    for source, relative in transport["locations"].items():
        path = local_path(root, relative)
        if base_url:
            parsed = urlsplit(base_url)
            file_base = parsed.scheme == "file" and not parsed.netloc and parsed.path.startswith("/")
            loopback = (parsed.scheme == "http" and parsed.hostname == "127.0.0.1"
                        and parsed.port and parsed.path in ("", "/"))
            if (not (file_base or loopback) or parsed.username or parsed.password
                    or parsed.query or parsed.fragment):
                raise ValueError("fallback must use an explicit loopback endpoint")
            from urllib.parse import quote
            mapping[source] = base_url.rstrip("/") + "/" + quote(relative)
        else:
            mapping[source] = path.as_uri()
    checked_mapping(mapping)
    return mapping


def workspace(manifest, root, destination, base_url=None):
    """Verify all supplied bytes before creating a fresh metadata-only workspace."""
    verify(manifest, root)
    mapping = mapping_for(manifest, root, base_url)
    prepared = []
    for row in manifest["metadata"]:
        if not row["path"].startswith("metadata/"):
            raise ValueError("metadata must have an explicit workspace-relative path")
        source = local_path(root, row["path"])
        raw = source.read_bytes()
        if source.suffix == ".toml" or source.name == "uv.lock":
            canonical = tomllib.loads(raw.decode("utf-8"))
            effective = rewrite(canonical, mapping)
            validate(canonical, effective, mapping)
            raw = dumps(effective).encode()
        prepared.append((row["path"][len("metadata/"):], raw))
    destination = Path(destination)
    destination.mkdir(exist_ok=False)
    for relative, raw in prepared:
        path = local_path(destination, relative)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(raw)
    check_workspace(manifest, root, destination, mapping)
    return mapping


def check_workspace(manifest, root, destination, mapping):
    """Recheck canonical hashes and effective trees across the uv sync boundary."""
    for row in manifest["metadata"]:
        source = local_path(root, row["path"])
        if sha256(source) != row["sha256"]:
            raise ValueError("canonical source drift")
        effective = local_path(destination, row["path"][len("metadata/"):])
        if source.suffix == ".toml" or source.name == "uv.lock":
            validate(tomllib.loads(source.read_text(encoding="utf-8")),
                     tomllib.loads(effective.read_text(encoding="utf-8")), mapping)
        elif source.read_bytes() != effective.read_bytes():
            raise ValueError("non-TOML workspace input changed")


def probe(manifest, root, tools_prefix, application_root, profile_path, evidence_root):
    """Dispatch the manifest-bound native qualification through the delivered helper."""
    from deploy_venv_probe import probe as native_probe
    return native_probe(manifest, root, tools_prefix, application_root, profile_path, evidence_root)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("prepare", "check", "probe"))
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--workspace", type=Path)
    parser.add_argument("--loopback")
    parser.add_argument("--tools-prefix", type=Path)
    parser.add_argument("--application-root", type=Path)
    parser.add_argument("--profile", type=Path)
    parser.add_argument("--evidence-root", type=Path)
    args = parser.parse_args()
    try:
        manifest = load(args.manifest)
        if args.operation == "probe":
            probe(manifest, args.root, args.tools_prefix, args.application_root, args.profile, args.evidence_root)
        elif args.operation == "prepare":
            workspace(manifest, args.root, args.workspace, args.loopback)
        else:
            verify(manifest, args.root)
            check_workspace(manifest, args.root, args.workspace, mapping_for(manifest, args.root, args.loopback))
    except (OSError, ValueError, KeyError, TypeError) as error:
        print("Offline transport refused: " + str(error), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
