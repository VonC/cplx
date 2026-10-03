"""Run explicit acceptance adapters and retain fresh, byte-bound observations.

Adapters execute the real deployment/runtime/backend commands and assert their
outcomes. This runner checks their process status and evidence contract; it does
not infer runtime success from log text or turn fixture results into qualification.
Keep adapters, native results and infrastructure configuration outside public docs.
"""

import argparse
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import uuid


def case(requirements, checks, negative=False):
    """Declare mandatory observations, including negative readiness evidence."""
    return {"requirements": requirements.split(), "checks": checks.split(),
            "negative": negative}


CASES = {
    "packaging": case("AC01", "archive-members metadata alias-exclusion"),
    "fresh": case("AC02 AC03 AC06 AC14", "local-inputs network-denial empty-cache no-git interpreter readiness"),
    "repeat": case("AC04 AC05", "venv-path interpreter inventory readiness"),
    "mirror-removed": case("AC04 AC06", "removed-venv recreated-venv network-denial readiness"),
    "foreign-base": case("AC03", "foreign-base rejection not-ready no-mutation", True),
    "wrong-host": case("AC03", "host-python foreign-activation selected-interpreter readiness"),
    "changed-tools": case("AC15", "equal-python changed-archive renewed-attestation readiness"),
    "missing-inputs": case("AC02 AC06", "missing-input rejection no-mutation no-fetch", True),
    "stale-lock": case("AC05", "stale-lock rejection not-ready", True),
    "missing-wheel": case("AC05 AC14", "missing-wheel rejection no-build not-ready", True),
    "partial-sync": case("AC05", "interrupted-command rejection not-ready recovery", True),
    "extra-distribution": case("AC07", "inventory-drift rejection not-ready", True),
    "wheel-tamper": case("AC07", "wheel-digest rejection not-ready", True),
    "bin-elf-tamper": case("AC07", "bin-elf-digest rejection not-ready", True),
    "provider-failure": case("AC08 AC09", "live-provider rejection not-ready", True),
    "debian": case("AC08 AC09", "agent interpreter stdlib heavy-wheels abi live-providers wheel-elf origin readiness"),
    "rhel": case("AC08 AC09", "agent interpreter stdlib heavy-wheels live-providers wheel-elf origin readiness"),
    "ci-equivalence": case("AC10 AC10a", "phase1-agent phase2-agent inventories commands tests coverage revisions"),
    "ci-failures": case("AC10 AC10b", "revision-drift masked-failure missing-observation phase-order"),
    "no-publication": case("AC11", "publisher-commands parameter-overrides"),
    "rollback-venv-free": case("AC12 AC14", "predecessor-inputs own-entry own-helpers network-denial readiness"),
    "rollback-shipped-venv": case("AC12", "predecessor-inputs own-entry shipped-venv network-denial readiness"),
    "serialization": case("AC15", "mirror-excluded sync-excluded rollback-excluded independent-root"),
    "consumer-delivery": case("AC02 AC13", "acquisition input-digests actual-invocation readiness"),
    "wrong-qualification": case("AC11", "wrong-digest rejection no-publication", True),
    "retention": case("AC12", "candidate-before later-build candidate-after protected-inputs"),
    "promotion": case("AC01 AC11 AC14", "authorization qualification receipts retrieved-digests offline-deploy offline-rollback"),
}


def unique(pairs):
    """Reject duplicate JSON fields at every nesting level."""
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON field: " + key)
        result[key] = value
    return result


def document(path):
    """Read an explicitly named regular JSON file without following aliases."""
    path = Path(path)
    if not path.is_absolute() or path.is_symlink() or not path.is_file():
        raise ValueError("missing or unsafe observation/input: " + str(path))
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique)


def digest(path):
    """Hash large retained inputs with bounded memory."""
    with Path(path).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def write(path, value):
    """Write a new record; existing results are never silently replaced."""
    with Path(path).open("x", encoding="utf-8") as stream:
        json.dump(value, stream, sort_keys=True, indent=2)
        stream.write("\n")


def evidence_file(item, root):
    """Require a nonempty regular observation inside this execution's directory."""
    if not isinstance(item, dict) or set(item) != {"path", "sha256"}:
        raise ValueError("invalid evidence file")
    path = Path(item["path"])
    root = Path(root).resolve()
    if not path.is_absolute() or not path.resolve().is_relative_to(root):
        raise ValueError("evidence outside current execution")
    if path.is_symlink() or not path.is_file() or path.stat().st_size == 0:
        raise ValueError("missing, aliased or empty evidence")
    if digest(path) != item["sha256"]:
        raise ValueError("changed evidence bytes")
    return path


def validate_command(name, command, expected_exit):
    """Refuse unspecified cases and ambiguous success/failure expectations."""
    if name not in CASES:
        raise ValueError("unknown acceptance case")
    if type(expected_exit) is not int or not 0 <= expected_exit <= 255:
        raise ValueError("invalid expected exit status")
    if (expected_exit != 0) != CASES[name]["negative"]:
        raise ValueError("expected exit status contradicts case")
    if (not isinstance(command, list) or not command
            or any(not isinstance(arg, str) or not arg or "\0" in arg for arg in command)):
        raise ValueError("command must be an explicit argument list")
    executable = Path(command[0])
    if not executable.is_absolute() or not executable.is_file():
        raise ValueError("command executable must exist at an absolute path")


def run_case(name, command, expected_exit, binding, evidence_root, *, fixture=True):
    """Execute one adapter, preserving failed process and observation diagnostics."""
    validate_command(name, command, expected_exit)
    run_id = uuid.uuid4().hex
    output = Path(evidence_root).resolve() / (name + "-" + run_id)
    output.mkdir(parents=True)
    request = {"schema": 1, "run_id": run_id, "case": name, "candidate": binding,
               "required_checks": CASES[name]["checks"]}
    write(output / "request.json", request)
    log = output / "command.log"
    result = {**request, "command": command, "expected_exit": expected_exit,
              "returncode": None, "status": "failed", "qualifying": False,
              "fixture": fixture, "log": str(log),
              "started": datetime.now(timezone.utc).isoformat(),
              "host": platform.node(), "platform": platform.platform()}
    try:
        env = {**os.environ, "DVS_ACCEPTANCE_OUTPUT": str(output)}
        with log.open("xb") as stream:
            process = subprocess.run(command, env=env, stdout=stream,
                                     stderr=subprocess.STDOUT, check=False)
        result["returncode"] = process.returncode
        if process.returncode != expected_exit:
            raise ValueError("command exit status differs from expected result")
        observation_path = output / "observation.json"
        observation = document(observation_path)
        keys = {"schema", "run_id", "case", "candidate", "checks"}
        if not isinstance(observation, dict) or set(observation) != keys:
            raise ValueError("invalid observation fields")
        if type(observation["schema"]) is not int or observation["schema"] != 1:
            raise ValueError("invalid observation schema")
        for key in ("run_id", "case", "candidate"):
            if observation[key] != request[key]:
                raise ValueError("stale or wrong-candidate observation: " + key)
        checks = observation["checks"]
        if not isinstance(checks, dict) or set(checks) != set(request["required_checks"]):
            raise ValueError("incomplete observation checks")
        for item in checks.values():
            evidence_file(item, output)
        result.update(status="passed", qualifying=not fixture,
                      observation=str(observation_path),
                      observation_sha256=digest(observation_path))
        return result
    except (OSError, ValueError) as exc:
        result["error"] = str(exc)
        raise ValueError(str(exc)) from exc
    finally:
        result["ended"] = datetime.now(timezone.utc).isoformat()
        if log.is_file():
            result["log_sha256"] = digest(log)
        write(output / "result.json", result)


def candidate_binding(path, *, published=False):
    """Validate retained local CI inputs before any adapter can mutate a target."""
    helper = Path(__file__).resolve().parents[2] / "src/setups/env/bin/deploy_venv_publication.py"
    spec = importlib.util.spec_from_file_location("publication", helper)
    publication = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(publication)
    candidate = publication.document(path)
    publication.schema(candidate, {"identity", "state", "expires_at", "record", "files",
                                   "ci_evidence", "coverage", "predecessors"}, "candidate")
    if candidate["state"] != "retained":
        raise ValueError("candidate is not retained")
    if candidate["expires_at"] is not None:
        expiry = datetime.fromisoformat(candidate["expires_at"])
        if expiry.tzinfo is None or expiry <= datetime.now(timezone.utc):
            raise ValueError("expired candidate or ambiguous expiry")
    release = publication.release_helper()
    record = publication.regular(candidate["record"])
    if digest(record) != candidate["identity"]:
        raise ValueError("candidate record identity differs")
    files = publication.local_files(candidate["files"], release.FILES)
    ci_path = publication.regular(candidate["ci_evidence"])
    coverage = publication.regular(candidate["coverage"])
    if published:
        ci = release.validate_ci_observation(record, files, coverage, ci_path,
                                             publication="published")
    else:
        ci = release.validate_ci_evidence(record, files, coverage, ci_path)
    row = release.parse(record)
    # Recovery inputs may still be pending while independent cplx cases run.
    predecessors = None
    if candidate["predecessors"] is not None:
        predecessors, _ = publication.predecessor_inputs(candidate["predecessors"], release)
    return {**ci["candidate"], **({"ci_publication": "published"} if published else {}),
            "entry_sha256": row["entry_sha256"],
            "build": ci["build"]["number"], "revision": ci["build"]["revision"],
            "ci_evidence_sha256": digest(ci_path), "coverage_sha256": digest(coverage),
            "predecessors": predecessors}


def main():
    """Run a private, explicitly selected native-target plan; subsets stay incomplete."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--candidate-manifest", type=Path, required=True)
    parser.add_argument("--acceptance-plan", type=Path, required=True)
    parser.add_argument("--evidence-root", type=Path, required=True)
    parser.add_argument("--publication-authorized", action="store_true")
    parser.add_argument("--published-candidate", action="store_true",
                        help="observe an already published build; does not grant promotion eligibility")
    args = parser.parse_args()
    try:
        if platform.system() != "Linux" or not args.evidence_root.is_absolute():
            raise ValueError("native Linux and an absolute evidence root are required")
        plan = document(args.acceptance_plan)
        if (not isinstance(plan, dict) or set(plan) != {"schema", "cases"}
                or type(plan["schema"]) is not int or plan["schema"] != 1
                or not isinstance(plan["cases"], dict) or not plan["cases"]):
            raise ValueError("invalid acceptance plan")
        for name, row in plan["cases"].items():
            if not isinstance(row, dict) or set(row) != {"command", "expected_exit"}:
                raise ValueError("invalid acceptance command")
            validate_command(name, row["command"], row["expected_exit"])
        if "promotion" in plan["cases"] and not args.publication_authorized:
            raise ValueError("promotion requires explicit publication authorization")
        binding = candidate_binding(args.candidate_manifest, published=args.published_candidate)
        if binding["predecessors"] is None and any(
                name.startswith("rollback-") or name == "promotion" for name in plan["cases"]):
            raise ValueError("recovery cases require verified predecessor inputs")
        results = []
        for name, row in plan["cases"].items():
            results.append(run_case(name, row["command"], row["expected_exit"], binding,
                                    args.evidence_root, fixture=False))
        missing = [name for name in CASES if name not in plan["cases"]]
        summary = {"schema": 1, "candidate": binding, "results": results,
                   "missing": missing, "complete": not missing}
        output = args.evidence_root / ("acceptance-" + uuid.uuid4().hex + ".json")
        write(output, summary)
        print(str(output))
        return 0
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print("acceptance refused: " + str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
