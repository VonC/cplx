"""Qualify retained candidates and publish immutable objects before their binding.

Transport is a consumer-owned port with digest(coordinate) and
upload(coordinate, local_path) operations. It must enforce immutable creation
and repository retention; this module owns eligibility, byte identity and order.
No build, deployment, acquisition or credential mechanism lives here.
"""

import argparse
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import sys
import tarfile
import tempfile


def release_helper():
    """Load the installed sibling, including under Python isolated mode."""
    spec = importlib.util.spec_from_file_location(
        "deploy_venv_release", Path(__file__).with_name("deploy_venv_release.py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def encoded(value):
    """Produce deterministic manifest bytes for safe equal-byte retries."""
    return (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()


def shape(value, keys, label):
    """Reject missing, extra and mistyped fields instead of guessing defaults."""
    if not isinstance(value, dict) or set(value) != set(keys):
        raise ValueError("invalid " + label)
    return value


def regular(value):
    """Require explicit existing regular inputs, never newest-file discovery."""
    if not isinstance(value, (str, Path)):
        raise ValueError("invalid local input path")
    path = Path(value)
    if not path.is_absolute() or path.is_symlink() or not path.is_file():
        raise ValueError("missing or unsafe local input")
    return path


def document(path):
    """Read strict JSON from a caller-supplied regular file."""
    with regular(path).open(encoding="utf-8") as stream:
        return json.load(stream, object_pairs_hook=release_helper()._unique)


def schema(value, keys, label):
    shape(value, {"schema", *keys}, label)
    if type(value["schema"]) is not int or value["schema"] != 1:
        raise ValueError("invalid " + label + " schema")


def local_files(value, names):
    shape(value, names, "input files")
    return {name: regular(path) for name, path in value.items()}


def predecessor_inputs(value, release):
    """Verify both recovery forms and keep all of their required retained bytes."""
    shape(value, {"venv_free", "shipped_venv"}, "predecessors")
    bindings, files = {}, {}
    free = shape(value["venv_free"], {"record", "files"}, "venv-free predecessor")
    record = regular(free["record"])
    inputs = local_files(free["files"], release.FILES)
    row = release.qualify(record, inputs)
    bindings["venv_free"] = {"record_sha256": release.sha256(record),
                             **{key: row[key] for key in release.FILES.values()}}
    files.update({"predecessor.venv_free." + name: path
                  for name, path in {"record": record, **inputs}.items()})
    shipped = shape(value["shipped_venv"], {"files", "sha256"}, "shipped predecessor")
    inputs = local_files(shipped["files"], {"application", "entry", "tools"})
    shape(shipped["sha256"], inputs, "shipped predecessor digests")
    bindings["shipped_venv"] = {}
    for name, path in inputs.items():
        digest = release.sha256(path)
        if shipped["sha256"][name] != digest:
            raise ValueError("shipped predecessor identity differs")
        bindings["shipped_venv"][name + "_sha256"] = digest
        files["predecessor.shipped_venv." + name] = path
    return bindings, files


def eligible(candidate_path, qualification_path):
    """Bind complete observations to exact CI bytes, helper inputs and recovery."""
    release = release_helper()
    candidate = document(candidate_path)
    schema(candidate, {"identity", "state", "expires_at", "record", "files",
                       "ci_evidence", "coverage", "predecessors"}, "candidate")
    if candidate["state"] != "retained":
        raise ValueError("candidate is not retained")
    if candidate["expires_at"] is not None:
        expiry = datetime.fromisoformat(candidate["expires_at"])
        if expiry.tzinfo is None or expiry <= datetime.now(timezone.utc):
            raise ValueError("candidate expired or expiry lacks timezone")
    record = regular(candidate["record"])
    if candidate["identity"] != release.sha256(record):
        raise ValueError("candidate record identity differs")
    files = local_files(candidate["files"], release.FILES)
    ci_path, coverage = regular(candidate["ci_evidence"]), regular(candidate["coverage"])
    ci = release.validate_ci_evidence(record, files, coverage, ci_path)
    row = release.parse(record)
    binding = {**ci["candidate"], "entry_sha256": row["entry_sha256"],
               "build": ci["build"]["number"], "revision": ci["build"]["revision"],
               "ci_evidence_sha256": release.sha256(ci_path),
               "coverage_sha256": release.sha256(coverage)}
    predecessors, retained = predecessor_inputs(candidate["predecessors"], release)
    qualification_digest = release.sha256(regular(qualification_path))
    qualification = document(qualification_path)
    schema(qualification, {"candidate", "predecessors", "results"}, "qualification")
    if qualification["candidate"] != binding or qualification["predecessors"] != predecessors:
        raise ValueError("qualification identity differs")
    cases = {"debian", "rhel", "offline", "readiness", "rollback_venv_free", "rollback_shipped_venv"}
    shape(qualification["results"], cases, "qualification results")
    for name, result in qualification["results"].items():
        shape(result, {"status", "complete", "candidate", "predecessors", "evidence",
                       "evidence_sha256"}, "qualification result")
        if (result["status"] != "success" or result["complete"] is not True
                or result["candidate"] != binding or result["predecessors"] != predecessors):
            raise ValueError("incomplete or mismatched qualification result")
        evidence = regular(result["evidence"])
        if release.sha256(evidence) != result["evidence_sha256"] or evidence.stat().st_size == 0:
            raise ValueError("qualification evidence differs or is empty")
        files["evidence." + name] = evidence
    files.update(record=record, ci_evidence=ci_path, coverage=coverage,
                 qualification=regular(qualification_path))
    files.update(retained)
    digests = {name: row[key] for name, key in release.FILES.items()}
    digests.update(record=binding["record_sha256"],
                   ci_evidence=binding["ci_evidence_sha256"],
                   coverage=binding["coverage_sha256"], qualification=qualification_digest)
    for name, result in qualification["results"].items():
        digests["evidence." + name] = result["evidence_sha256"]
    for kind, retained_binding in predecessors.items():
        for name, digest in retained_binding.items():
            digests["predecessor." + kind + "." + name.removesuffix("_sha256")] = digest
    # Keep the validated identities through the snapshot boundary. Rehashing a
    # changed source into a new identity would silently qualify different bytes.
    if any(release.sha256(path) != digests[name] for name, path in files.items()):
        raise ValueError("local input changed after qualification validation")
    return {"candidate": binding, "predecessors": predecessors, "files": files,
            "digests": digests}


def coordinates(config_path, digests, release):
    """Allow shared retained bytes only when every role binds the same digest."""
    config = document(config_path)
    schema(config, {"objects", "manifest"}, "publication coordinates")
    shape(config["objects"], digests, "publication object coordinates")
    seen = {}
    for name, coordinate in (*config["objects"].items(), ("manifest", config["manifest"])):
        if (not isinstance(coordinate, str) or not release.COORDINATE.fullmatch(coordinate)
                or any(part in (".", "..") or "SNAPSHOT" in part.upper()
                       for part in coordinate.split("/"))):
            raise ValueError("unsafe or aliased immutable coordinate")
        digest = digests.get(name)
        if coordinate in seen and (name == "manifest" or seen[coordinate] != digest):
            raise ValueError("aliased immutable coordinate has different bytes")
        seen[coordinate] = digest
    return config


def publish(candidate_path, qualification_path, config_path, backend, evidence_root):
    """Verify retention, upload exact snapshots and expose the manifest last.

    The backend's digest reads full remote bytes, returns None only for absence,
    and raises on uncertain status. upload uses immutable create semantics and
    must never overwrite. Credentials and backend policy are consumer concerns.
    """
    qualified = eligible(candidate_path, qualification_path)
    release = release_helper()
    config = coordinates(config_path, qualified["digests"], release)
    output = Path(evidence_root)
    if not output.is_absolute() or output.is_symlink():
        raise ValueError("explicit safe evidence root required")
    output.mkdir(parents=True, exist_ok=True)
    manifest = {"schema": 1, "candidate": qualified["candidate"],
                "predecessors": qualified["predecessors"], "objects": {
                    name: {"coordinate": config["objects"][name], "sha256": digest}
                    for name, digest in qualified["digests"].items()}}
    manifest_bytes = encoded(manifest)
    manifest_digest = hashlib.sha256(manifest_bytes).hexdigest()
    with tempfile.TemporaryDirectory(prefix=".publication-", dir=output) as scratch:
        # Freeze caller-controlled paths before the first transport operation.
        snapshots = {}
        for name, source in qualified["files"].items():
            target = Path(scratch) / name
            shutil.copyfile(source, target)
            if release.sha256(target) != qualified["digests"][name]:
                raise ValueError("local input changed during publication snapshot")
            snapshots[name] = target
        binding = Path(scratch) / "binding.json"
        binding.write_bytes(manifest_bytes)
        observations = {}
        for name, item in manifest["objects"].items():
            found = backend.digest(item["coordinate"])
            if found is not None and found != item["sha256"]:
                raise ValueError("remote identity conflict: " + name)
            if found is None and (name == "tools" or name.startswith("predecessor.")):
                raise ValueError("required retained input missing: " + name)
            observations[name] = found
        found = backend.digest(config["manifest"])
        if found is not None and found != manifest_digest:
            raise ValueError("remote manifest conflict")
        if found is not None and any(value is None for value in observations.values()):
            raise ValueError("announced release lost required retained objects")
        for name, item in manifest["objects"].items():
            if observations[name] is None:
                backend.upload(item["coordinate"], snapshots[name])
            if backend.digest(item["coordinate"]) != item["sha256"]:
                raise ValueError("remote object read-back failed: " + name)
        if found is None:
            backend.upload(config["manifest"], binding)
        if backend.digest(config["manifest"]) != manifest_digest:
            raise ValueError("remote manifest read-back failed")
    receipt = {"schema": 1, "manifest": config["manifest"],
               "manifest_sha256": manifest_digest, "objects": manifest["objects"]}
    # Receipts are diagnostic; the verified immutable remote binding is authoritative.
    (output / "receipt.json").write_bytes(encoded(receipt))
    return receipt


def main():
    """Check eligibility on the operator host without a transport or credentials."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("publication-check",))
    parser.add_argument("--candidate-manifest", type=Path, required=True)
    parser.add_argument("--qualification-record", type=Path, required=True)
    args = parser.parse_args()
    try:
        eligible(args.candidate_manifest, args.qualification_record)
    except (OSError, ValueError, KeyError, TypeError, tarfile.TarError) as error:
        print("Publication refused: " + str(error), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
