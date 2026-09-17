#!/usr/bin/env python3
"""Validate retained release evidence before publication and after adoption.

Python 3.9+ stdlib only. The explicitly supplied authoring interpreter must be
independent of the candidate. Input is one versioned archive-indexed JSON record;
capture paths are relative to an explicit retained evidence root. No directory
discovery, candidate execution, network access or uploader is performed here.
"""

import argparse
from datetime import date
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import sys
import time


STATES = {"", "pending", "pass", "fail", "inconclusive", "not applicable"}
ARCHIVE_CELLS = tuple("AR%d" % n for n in range(1, 5))
PLATFORM_CELLS = tuple("PA%d:%s" % (n, role) for n in range(1, 12)
                       for role in ("debian", "rhel") if not (n == 3 and role == "rhel"))
ROLE_CELLS = ("PA3:rhel-build", "PA3:rhel-deploy")
LATER = ("RA5:adoption", "RA6", "RA8:adoption")
OBLIGATIONS = ("RA1", "RA2", "RA3", "RA4", "RA5:publication", "RA7", "RA8:publication", "backend")
OPTIONAL = {"PA7:rhel", "PA8:rhel", "PA9:rhel"}
INAPPLICABLE = {"PA10:debian", "PA11:debian"}
CELLS = ARCHIVE_CELLS + PLATFORM_CELLS + ROLE_CELLS + OBLIGATIONS + LATER
PUBLICATION = tuple(cell for cell in CELLS if cell not in OPTIONAL | INAPPLICABLE
                    and cell not in LATER)
COMPLETION = PUBLICATION + LATER
INPUT_KEYS = {"archive", "application", "pipeline", "lock", "wheels", "runtime"}


def require(condition, message):
    """Use one diagnostic boundary for malformed and ineligible records."""
    if not condition:
        raise ValueError(message)


def text(value, label):
    require(isinstance(value, str) and bool(value.strip()), label + " is missing")
    return value


def digest(value, length=64):
    require(isinstance(value, str) and re.fullmatch("[0-9a-f]{%d}" % length, value),
            "invalid digest or revision")
    return value


def mapping(value, label):
    require(isinstance(value, dict) and bool(value), label + " must be a nonempty object")
    return value


def hash_file(path, metrics=None):
    """Hash each artifact once with bounded buffers, retaining both associations."""
    sha256, sha1, size = hashlib.sha256(), hashlib.sha1(), 0
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            sha256.update(chunk)
            sha1.update(chunk)
            size += len(chunk)
    if metrics is not None:
        metrics["bytes_read"] = metrics.get("bytes_read", 0) + size
    return sha256.hexdigest(), sha1.hexdigest(), size


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, "duplicate JSON key: " + key)
        result[key] = value
    return result


def sanitized(value):
    """Refuse local paths, access details and multiline injection in shared data."""
    if isinstance(value, dict):
        for key, item in value.items():
            require(isinstance(key, str), "record keys must be strings")
            require(key.lower() not in {"password", "token", "authorization", "credentials"},
                    "access details do not belong in versioned evidence")
            sanitized(key)
            sanitized(item)
    elif isinstance(value, list):
        for item in value:
            sanitized(item)
    elif isinstance(value, str):
        require(not re.search(r"[\x00-\x1f\x7f]|\\|(?:^|\s)(?:/|~/|[A-Za-z]:)|"
                              r"https?://[^/]*@|(?:password|token|authorization)\s*[:=]",
                              value, re.IGNORECASE), "unsanitized record value")
    else:
        require(value is None or type(value) in (bool, int), "unsupported record value")


def load(path):
    document = json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
    structure(document)
    return document


def structure(document):
    sanitized(document)
    require(isinstance(document, dict) and type(document.get("schema_version")) is int
            and document["schema_version"] == 1, "unsupported release record schema")
    require(isinstance(document.get("candidates"), dict), "candidates must be archive-indexed")
    for key in document["candidates"]:
        digest(key)


def current_inputs(record):
    consumers = record["consumers"]
    return {"archive": record["candidate"]["sha256"],
            "application": consumers["application_revision"],
            "pipeline": consumers["pipeline_revision"], "lock": consumers["lock_sha256"],
            "wheels": consumers["wheels"], "runtime": record["environments"]}


def capture_map(record, root, metrics):
    """Read each explicitly indexed capture once; never discover files by scanning."""
    root = root.resolve(strict=True)
    captures, identities, paths = {}, set(), {}
    for name, capture in mapping(record["captures"], "captures").items():
        text(name, "capture key")
        identity = text(capture["identity"], "capture identity")
        require(identity not in identities, "duplicate capture identity")
        identities.add(identity)
        require(capture["retention"] in {"retained", "versioned"}, "capture is not durably retained")
        relative = PurePosixPath(text(capture["path"], "capture path"))
        require(not relative.is_absolute() and ".." not in relative.parts,
                "capture path escapes evidence root")
        require(not any(part.startswith("a.") for part in relative.parts),
                "ignored local capture alone is not durable evidence")
        path = (root / relative).resolve(strict=True)
        require(root in path.parents and path.is_file(), "capture is outside evidence root")
        if path not in paths:
            paths[path] = hash_file(path, metrics)[0]
            metrics["capture_reads"] += 1
        require(paths[path] == digest(capture["sha256"]), "capture digest mismatch: " + name)
        captures[name] = capture
    return captures


def references(names, captures):
    require(isinstance(names, list) and bool(names), "retained capture references are required")
    seen = set()
    for name in names:
        require(isinstance(name, str) and name in captures, "unknown capture reference")
        require(name not in seen, "duplicate capture reference")
        seen.add(name)


def validate_inputs(inputs):
    require(isinstance(inputs, dict) and set(inputs) == INPUT_KEYS, "incomplete affected input identities")
    digest(inputs["archive"])
    digest(inputs["application"], 40)
    digest(inputs["pipeline"], 40)
    digest(inputs["lock"])
    for filename, sha256 in mapping(inputs["wheels"], "wheels").items():
        require(filename.endswith(".whl") and "/" not in filename, "invalid wheel filename")
        digest(sha256)
    mapping(inputs["runtime"], "runtime identities")


def result_current(cell, result, record, current, captures):
    previous = result["inputs"]
    validate_inputs(previous)
    require(previous["archive"] == current["archive"], "old archive evidence cannot be retained")
    if previous == current:
        return
    assessment = record["assessments"].get(cell, {})
    require(assessment.get("decision") == "unaffected", "changed inputs require reassessment: " + cell)
    text(assessment.get("reason"), "retention reason")
    require(assessment.get("previous_inputs") == previous and assessment.get("current_inputs") == current,
            "assessment identities do not match original and current inputs")
    references(assessment.get("captures"), captures)
    wheel_change = previous["wheels"] != current["wheels"] or previous["lock"] != current["lock"]
    affected = cell in {"RA3", "RA4", "RA6", "RA7"} or cell.split(":")[0] in {
        "PA5", "PA6", "PA7", "PA8", "PA9"}
    require(not (wheel_change and affected), "wheel/lock change requires fresh D10/ABI/application acceptance")


def validate_d10(record, captures):
    d10 = record["d10"]
    readings = d10["readings"]
    require(isinstance(readings, list) and 1 <= len(readings) <= 2, "D10 needs one or two readings")
    for reading in readings:
        require(reading["generation"] in (11, 12), "unknown D10 generation")
        require(reading["consumers"] == record["consumers"]["wheels"], "D10 wheel identities differ")
        require(isinstance(reading["required_nodes"], list), "D10 required nodes must be enumerated")
        for node in reading["required_nodes"]:
            text(node, "D10 required node")
        providers = reading["providers"]
        require(set(providers) == {"11", "12"}, "D10 requires both candidate capabilities")
        for provider in providers.values():
            text(provider["identity"], "D10 provider identity")
            require(type(provider["satisfies"]) is bool, "D10 capability is inconclusive")
        selected = 11 if providers["11"]["satisfies"] else 12
        require(providers[str(selected)]["satisfies"] and reading["selected_generation"] == selected,
                "D10 did not select the lowest satisfying generation")
        references(reading["captures"], captures)
    if len(readings) == 1:
        require(readings[0]["generation"] == readings[0]["selected_generation"], "D10 rebuild is pending")
    else:
        require(readings[0]["generation"] != readings[0]["selected_generation"]
                and readings[1]["generation"] == readings[0]["selected_generation"], "invalid D10 rebuild")
    require(d10["packaged_generation"] == d10["selected_generation"] == readings[-1]["generation"]
            == readings[-1]["selected_generation"], "D10 did not converge")


def validate_metadata(record, archive, identity, sha1, size, revision, captures):
    candidate, authority = record["candidate"], record["authority"]
    require(candidate["sha256"] == identity and candidate["sha1"] == sha1
            and type(candidate["size"]) is int and candidate["size"] == size, "archive identity differs")
    require(candidate["filename"] == archive.name and re.fullmatch(r"tools\.[0-9][0-9_.-]*\.tar\.gz", archive.name),
            "explicit timestamped archive filename required")
    require(candidate["python"] in {"3.13.14", "3.13.15"}, "unsupported release Python")
    for value in mapping(candidate["payloads"], "payload identities").values():
        digest(value)
    regression = candidate["regression"]
    date.fromisoformat(regression["date"])
    require(regression["decision"] == ("clean" if candidate["python"] == "3.13.15" else "blocking regression"),
            "Python selection requires a conclusive regression decision")
    references(regression["sources"], captures)
    digest(authority["source_commit"], 40)
    digest(authority["declaration_sha256"])
    require(digest(authority["release_revision"], 40) == digest(revision, 40), "release revision differs")
    references(authority["captures"], captures)
    require(type(authority["renewed"]) is bool, "authority renewal state is missing")
    if authority["renewed"]:
        references(authority["renewal_proof"], captures)
    text(record["consumers"]["venv_base"], "venv base interpreter")
    environments = record["environments"]
    require(set(environments) == {"debian", "rhel-build", "rhel-deploy"}, "required environment roles missing")
    for role, environment in environments.items():
        for field in ("run", "os"):
            text(environment[field], role + " " + field)
        mapping(environment["runtime"], role + " runtime providers")
        require(environment["transfer_sha256"] == identity, "transferred archive differs")
        if role == "debian":
            text(environment["image"], "actual Debian image")
            text(environment["container"], "actual Debian container")
    validator = record["validator"]
    text(validator["identity"], "independent interpreter identity")
    version = text(validator["version"], "independent interpreter version")
    require(re.fullmatch(r"\d+\.\d+\.\d+", version) and tuple(map(int, version.split("."))) >= (3, 9, 0)
            and validator["independent"] is True, "independent Python 3.9+ required")
    validate_d10(record, captures)


def lifecycle(record, phase, captures):
    publication, adoption = record["publication"], record["adoption"]
    coordinate = text(publication["coordinate"], "selected release coordinate")
    require(re.fullmatch(r"releases:[A-Za-z0-9_.-]+:[A-Za-z0-9_.-]+:[A-Za-z0-9_.-]+:tools", coordinate)
            and "SNAPSHOT" not in coordinate, "immutable release coordinate required")
    for state in (publication["state"], adoption["state"], adoption["recovery"]):
        require(state in STATES, "unknown lifecycle state")
    for field in ("sha256", "sha1"):
        if publication.get(field) or phase == "completion":
            require(publication[field] == record["candidate"][field], "published digest association differs")
    if phase == "publication":
        require(publication["state"] in {"", "pending"} and adoption["state"] in {"", "pending"}
                and adoption["recovery"] in {"", "pending", "not applicable"},
                "recorded publication or recovery prohibits automatic upload retry")
        return
    require(publication["state"] == adoption["state"] == "pass", "publication and adoption must pass")
    require(adoption["recovery"] == "not applicable", "recovery leaves adoption incomplete")
    references(publication["captures"], captures)
    references(adoption["captures"], captures)
    digest(adoption["pin_revision"], 40)
    digest(adoption["configuration_revision"], 40)


def validate(document, archive, evidence_root, release_revision, phase, metrics=None):
    """Return only the accepted SHA-256; every nonconclusive condition refuses."""
    metrics = metrics if metrics is not None else {}
    metrics["capture_reads"] = 0
    try:
        structure(document)
        require(phase in {"publication", "completion"}, "unknown validation phase")
        identity, sha1, size = hash_file(archive, metrics)
        require(identity in document["candidates"], "selected archive has no release record")
        record = document["candidates"][identity]
        captures = capture_map(record, evidence_root, metrics)
        validate_metadata(record, archive, identity, sha1, size, release_revision, captures)
        current = current_inputs(record)
        validate_inputs(current)
        results = mapping(record["results"], "results")
        require(isinstance(record["assessments"], dict) and set(record["assessments"]) <= set(CELLS),
                "unknown assessment cell")
        require(set(results) <= set(CELLS), "unknown acceptance cell")
        required = PUBLICATION if phase == "publication" else COMPLETION
        for cell, result in results.items():
            require(result.get("state") in STATES, "unknown result state: " + cell)
            if cell in INAPPLICABLE:
                require(result["state"] in {"", "pending", "not applicable"}, "inapplicable cell cannot pass")
            if result["state"] == "pass":
                text(result["run"], "producing run: " + cell)
                references(result["captures"], captures)
                result_current(cell, result, record, current, captures)
        for cell in required:
            require(results.get(cell, {}).get("state") == "pass", "required acceptance is not passing: " + cell)
        lifecycle(record, phase, captures)
        return identity
    except (KeyError, TypeError, OSError, AttributeError) as error:
        raise ValueError("missing, malformed or unavailable release evidence") from error


def render(document):
    """Render the same sanitized record in fixed cell order, with all identity data."""
    structure(document)
    lines = ["## Generated release record", "", "Source: `acceptance.tools-archive-rebuild.json`.", ""]
    for identity, record in document["candidates"].items():
        lines.extend(["### Candidate " + identity, "", "| Acceptance | State | Producing run |",
                      "| --- | --- | --- |"])
        for cell in CELLS:
            result = record.get("results", {}).get(cell, {})
            lines.append("| %s | %s | %s |" % (cell, result.get("state") or "pending", result.get("run", "")))
        lines.append("")
    lines.extend(["### Release record identities and retained references", "", "```json",
                  json.dumps(document, indent=2, ensure_ascii=True), "```", ""])
    return "\n".join(lines)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", choices=("publication", "completion", "render"))
    parser.add_argument("--record", type=Path, required=True)
    parser.add_argument("--archive", type=Path)
    parser.add_argument("--evidence-root", type=Path)
    parser.add_argument("--release-revision")
    parser.add_argument("--coordinate")
    parser.add_argument("--capture", type=Path, help="ignored local invocation capture, outside the shared record")
    args = parser.parse_args(argv)
    started = time.monotonic()
    metrics = {"interpreter": sys.executable, "version": sys.version.split()[0], "record_reads": 1,
               "capture_reads": 0, "phase": args.phase}
    try:
        require(sys.version_info >= (3, 9), "Python 3.9+ is required")
        document = load(args.record)
        if args.phase == "render":
            print(render(document), end="")
            return 0
        require(all((args.archive, args.evidence_root, args.release_revision, args.capture)),
                "archive, evidence root, release revision and local capture are required")
        require(args.capture.resolve() not in {args.record.resolve(), args.archive.resolve()},
                "local capture must not overwrite an input")
        identity = validate(document, args.archive, args.evidence_root, args.release_revision, args.phase, metrics)
        record = document["candidates"][identity]
        retained_paths = {(args.evidence_root / capture["path"]).resolve()
                          for capture in record["captures"].values()}
        require(args.capture.resolve() not in retained_paths,
                "local capture must not overwrite retained evidence")
        if args.coordinate:
            require(args.coordinate == record["publication"]["coordinate"], "selected release coordinate differs")
        metrics.update(sha256=identity, sha1=record["candidate"]["sha1"], elapsed_seconds=time.monotonic() - started)
        args.capture.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
        print(identity)
        return 0
    except (ValueError, OSError) as error:
        print("release record refused: " + str(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
