# Tools archive rebuild acceptance v0.27.0

## Step 1 result: private streaming with mandatory commit verification

Status on 2026-09-17: **Step 1 implemented and validation passed**.
The live backend kept an unfinished chunked upload invisible, exposed its exact
bytes after the request completed, and refused a different-byte collision.
Cancelling an unfinished request left the public path absent. A second
experiment deliberately discarded the commit response: the client had no
acknowledgement, but an independent GET found the complete asset. Both committed
probe assets were deleted and their absence confirmed.

These observations supersede the earlier assumption that a separate staging API
was the only route. The user authorized an amendment to the owning publication
contract: a missing or unusable commit response requires exact-asset read-back
and SHA-256 verification. The application adapter, durable recovery receipt,
failure fixtures and cumulative runner now implement that contract. The tools
entry refuses before remote work until Step 2 binds accepted release evidence.
No actual tools archive was rebuilt or released.

The [Step 1 plan](plan.v0.27.0.tools-archive-rebuild.md#step-1-demonstrate-the-real-publication-transaction)
says: "Stop this step if the inherited transaction cannot be achieved and
resolve the owning design". The owning design and plan now resolve
commit-outcome reporting through the mandatory check described below.

## Inspected sources and inherited failure behavior

| Input | Inspected revision or path |
| --- | --- |
| cplx | `134c270c0b65b5e5c544ac021e8055896f1f25ac` |
| Consuming application | `64a59cb98d77724627dc747bc13d3bb5050404e7` |
| Publication contract | `src/setups/env/bin/closure_publish.sh`, amended failure diagnostics |
| Application entry | `app:tools/publish_pdf_nexus.sh`, old tools path refused before remote work |
| Application PC helper | `app:tools/publish_pdf_nexus_from_pc.sh`, separate existing upload path |

Both working trees were clean at initial inspection. The application branch
was five commits ahead of its tracking branch. Implementation changes are
separate working-tree changes based on the exact revisions above.

The gate passes stdin to `upload_write`, compares its SHA-256, then invokes
`upload_commit`. It previously claimed every commit error left nothing public.
It now retains the attempt for reconciliation and refuses retry/adoption when
commit is unconfirmed. Cleanup invokes the adapter, whose durable receipt
distinguishes an unfinished upload from remote commit intent. A local committed
flag alone cannot establish absence after response loss.

## Earlier read-only backend discovery

The [preflight capture](evidence.tools-archive-rebuild.backend-preflight.txt)
retains six authenticated requests, UTC times, HTTP statuses, durations and
body hashes. They used the existing Maven release-server entry and normal HTTPS
certificate validation. Private hostnames and credentials are omitted.

| Observation | Result and limit |
| --- | --- |
| Live service identity | `Nexus/3.18.0-01 (OSS)` |
| Swagger | HTTP 200; no staging, tag or promotion paths; anonymous and authenticated response hashes matched |
| Repository listing | `releases` is hosted `maven2`; anonymous visibility cannot prove absence of private repositories |
| Authenticated script listing | HTTP 403; custom transaction scripts could not be discovered with this account |
| Staging move route, GET and OPTIONS | HTTP 404; neither request attempted promotion |
| Exact first probe-version search | HTTP 200, zero assets, no continuation token |

Sonatype's [staging documentation](https://help.sonatype.com/en/staging.html)
describes the separate Pro staging feature. Its absence did not rule out the
request-stream mechanism subsequently examined.

## Matching-version source investigation

The public source tag `release-3.18.0-01` resolves to annotated tag object
`c8def60197614186fa30a83753bf146395009d54`. Source hashes are indexed in the
[streaming evidence](evidence.tools-archive-rebuild.stream-probe.json).
In [MavenFacetImpl.java](https://github.com/sonatype/nexus-public/blob/release-3.18.0-01/plugins/nexus-repository-maven/src/main/java/org/sonatype/nexus/repository/maven/internal/MavenFacetImpl.java),
`put` first creates a temporary blob from the request payload, then invokes a
transactional `doPut`. This suggested withholding the terminating HTTP chunk.
It is an inference from matching public source, not proof of the deployed
binary or a supported durable staging API. Component upload source was also
inspected; no multipart/POM transaction guarantee is claimed from that review.

## Live probe observations and cleanup

The user authorized the existing private project group and artifact in
`releases`, with a dedicated probe version and the `tools` classifier. Resolve
actual identifiers from existing application configuration. The diagnostic used
versions `probe-20260917-001` and `probe-20260917-002`; neither is an intended
tools release. Every initial write began with an exact-path HEAD 404 check.

The payload was a harmless 29-byte gzip of an empty tar archive, SHA-256
`e88209825c45ba955b3923b755e433584e58c7c955f413a9a5f62cfb22a2b839`.
The PowerShell diagnostic used certificate-verified TLS, HTTP/1.1 chunked PUT,
existing Maven credentials and 20-second network timeouts. No credentials were
printed or stored in captures. No POM or Maven metadata upload was issued.

| Experiment | Observed result |
| --- | --- |
| Unfinished request, first version | HTTP 100; HEAD 404 after headers and after the data chunk, before the terminating chunk |
| Abort before termination | Connection reset without the terminating chunk; subsequent HEAD 404 |
| Ordinary commit, first version | Another absent-path check, a new request and the terminating chunk; final HTTP 201 |
| Committed byte identity | GET 200; length and SHA-256 matched the sent payload |
| Immutable collision | Different valid gzip bytes refused with HTTP 400; GET retained the original digest |
| Ordinary cleanup | GET proved ownership by digest; DELETE 204; HEAD 404 |
| Lost response, second version | Request completed; connection reset when a response became readable, without reading its status or body |
| Independent check after response loss | GET 200 returned the original digest despite the uploader lacking acknowledgement |
| Lost-response cleanup | GET proved ownership by digest; DELETE 204; HEAD 404 |
| Final independent cleanup check | Both versions: tools and POM HEAD 404; exact-version search HTTP 200, zero assets and no continuation token |

All three diagnostic invocations exited 0: their observations were collected,
not Step 1 accepted. Response loss was deliberate fault injection, not an
observed spontaneous outage. Read-back was available and resolved the outcome
in this experiment. The contract must also cover unavailable read-back or
interruption before resolution. The collision request included `If-None-Match:
*`; HTTP 400 alone does not establish which server check rejected it.

Visibility observations used the configured account at the exact path. They do
not prove anonymous access rules, concurrent-client isolation, POM atomicity,
large-archive behavior or deletion of internal temporary blobs. The account
could read, create and delete these probe assets; its full privilege inventory
remains undiscovered. The open TLS request supplied provisional state, with no
server-issued durable stage handle.

The [sanitized streaming record](evidence.tools-archive-rebuild.stream-probe.json)
retains every observation with UTC time and duration. Ignored originals are
`a.tools-backend.stream-abort-observations.json`,
`a.tools-backend.stream-commit-observations.json`,
`a.tools-backend.stream-lost-response-observations.json`, and the parameterized
`a.probe-tools-stream.ps1`. The final check is retained locally as
`a.tools-backend.final-cleanup-observations.json` and
`a.final-tools-probe-check.ps1`. Source captures use `a.nexus-*.java`. Ignored
originals are not durable release evidence; their sanitized record is retained
here.

## Accepted response-loss resolution, 2026-09-17

Preserve descriptor-bound streaming, the pre-commit digest comparison, private
visibility before commit and immutable publication. Amend the owning closure
design/plan and this effort's design/plan to distinguish three commit outcomes.
The user requires an automatic check whenever publication lacks a proper commit
response. This check is part of commit completion, not an optional operator step:

1. Confirmed commit: retain expected digest and remote identity, then proceed.
2. Confirmed refusal before publication: abort the unfinished stage and establish
   that no candidate became public.
3. Missing or unusable commit response: immediately read the exact immutable
   coordinate and compare the downloaded bytes with the expected SHA-256.
   Matching bytes
   may resolve the attempt as committed. Absence alone does not prove that an
   in-flight request can no longer commit. Never claim nothing is public merely
   because acknowledgement was lost. An unavailable check, absent asset or
   different digest leaves the attempt unresolved: retain its identity and
   diagnostics and block adoption and automatic re-publication. Later recovery
   repeats this read-only check; it never starts a second upload.

This resolution is implemented by `app:tools/tools_release_adapter.sh`, with
separate Python 3.9 stdlib HTTP and durable-state helpers. `upload_write` accepts
stdin only and forwards chunks through one open HTTPS request. No archive copy,
POM upload, search-based confirmation or production DELETE operation is used.
Before sending the terminating chunk, the worker fsyncs commit intent and the
stream's SHA-256. A valid successful response or matching read-back returns 0;
an inconclusive check returns 3 and retains `UNKNOWN`. The closure gate treats
every nonzero result as refusal. An interrupted caller can recover through the
same receipt without publishing again. Abort after commit intent never deletes
the asset or reports that nothing is public.

## Configuration and recovery

The release account supplies `NEXUS_URL`, `NEXUS_REPO`, `GROUP`, `ARTIFACT`,
`VERSION` and `REPO_ID`. The adapter reads the matching server from
`MAVEN_SETTINGS` (default `~/.m2/settings.xml`); credentials remain out of
arguments, captures and receipts. Native Linux and Python 3.9 or later are
required; `TOOLS_RELEASE_PYTHON` selects an explicit interpreter. The tested
service requires normal trusted TLS and resolved Maven credentials. Encrypted
Maven placeholders and snapshot publication are refused.

Retain the private account-owned `TOOLS_RELEASE_STATE_DIR` (default
`~/.local/state/tools-release`). It contains one coordinate-keyed attempt with
exact target, stream digest, phase and worker diagnostics, but no archive bytes
or backend credentials. All invocations for the coordinate must reuse it.
Existing unresolved or committed receipts refuse automatic `begin` retries.
After an uncertain outcome, run the read-only recovery command using the exact
handle named by the diagnostic:

```bash
bash tools/tools_release_adapter.sh reconcile /absolute/retained/handle
```

Exit 0 confirms publication; exit 3 retains uncertainty. A 404, wrong digest,
unavailable GET or unusable local credential configuration never authorizes a
second upload. Correct the failed observation and reconcile the same receipt.
Release eligibility and adoption remain owned by subsequent plan steps.

## Implemented HTTP helper against the live backend

The [adapter HTTP capture](evidence.tools-archive-rebuild.adapter-http-probe.json)
records ten successful observations on `probe-20260917-003`: exact-path initial
absence, private write, abort/absence, second private write, acknowledged commit,
the helper's exact GET/SHA-256 match, different-byte collision refusal, original
digest preservation, ownership-verified cleanup and final absence. It records
the helper's source hash at probe time. The later exception-handling amendment
only makes malformed local settings an inconclusive read-back.

The 29-byte empty tar gzip had SHA-256
`a1b1b81d3d1afdb8fe119b002318c12c20934713b9754a40f702adb18a2540b9`.
The live HTTP helper ran with existing local Maven configuration. Credentials
were not copied to the Linux fixture host. Complete adapter/worker/gate process
tests run on native Linux against an isolated TLS repository. Together these
exercise the actual backend HTTP mechanism and the Linux coordination contract;
they are not a claim that the whole worker ran against the live backend.

## Validation

The initial missing-adapter fixture failed before implementation. The final
native Linux cumulative run exited 0 in 33 seconds on RHEL 9.8, Bash 5.1.8 and
independent `/usr/bin/python3` 3.9.25. The
[validation capture](evidence.tools-archive-rebuild.validation.txt) retains the
output and LF-normalized implementation hashes. It includes:

- Shell lint for 57 tracked scripts, explicit new-script syntax/ShellCheck and
  Python compilation.
- Fifteen process integration tests in 11.244 seconds: private abort, valid and
  lost/malformed/error replies, unknown/recovery outcomes, immutable collisions,
  partial writes, digest refusal, pre-commit signal cleanup, abort diagnostics,
  old tools entry refusal and ordinary fresh/identical/different/snapshot
  publication. Recovery also covers malformed credential configuration and a
  killed commit caller after the backend has committed, without a second PUT.
- Twenty-five current SQLite declaration checks and 254 inherited closure
  publication checks, with zero failures. The inherited suite uses its exact
  historical declaration pair as documented in the fixture README. An earlier
  run exposed 15 already-documented retired-waiver expectations and one lexical
  diagnostic fixture mismatch; the diagnostic was corrected and the historical
  input selector made explicit. The current declaration remains unchanged.

The application's mandatory `ghog day` completed with exit 0 on 2026-09-17 at
08:42:25 +02:00: authoring checks 84.4 seconds, affected tests 3m 51.6s, full
tests 4m 17.7s, zero failures, three warnings, eight expected failures, 100%
coverage, zero duration outliers and zero exclusions. Its coverage source is
`src/pdfss`; the new release helpers are outside that scope. Their evidence is
the process integration suite, not a claimed unit coverage percentage. Each
production helper's top-level symbols is reached by its CLI or sibling helper.
The finite outcome matrix does not require a property-testing dependency.

The existing application SQLite mapping diagnostic also required a small
typing/platform cleanup to pass the mandatory Windows authoring gate. It keeps
its native Linux device/inode observations and JSON output. This prerequisite
fix does not qualify any candidate or change the later SQLite acceptance work.
A native Python 3.9 smoke invocation exited 0, returned the SQLite query value
42, and retained matching path/descriptor device and inode observations.

Final physical lines: HTTP helper 168, state helper 354, SQLite diagnostic 68,
integration test 404; each Python file is below 650. Shell files: adapter 22,
application publisher 320, closure gate 655, focused runner 19, cumulative
runner 40. Streaming and hashing are linear in bytes with bounded buffers;
receipt operations address one coordinate directly. No new sorting or all-pairs
scan is introduced. Actual release publication and adoption remain pending
later steps.

## Step 2 release evidence contract

The [versioned sidecar](acceptance.tools-archive-rebuild.json) has no identified
candidate yet. Its pending template is deliberately outside `candidates`: no
synthetic digest or fixture pass can qualify a release. Step 1's retained captures
are indexed under `preparation`; they do not certify a future archive.

Use `src/setups/env/bin/tools_release_record.py` with an explicitly selected,
independent Python 3.9 or later. `publication` returns one accepted SHA-256;
`completion` additionally requires confirmed publication and adoption. Both
refuse incomplete records, unretained or damaged captures and stale identities.
`render --record <record>` produces the generated section below.

For an identified candidate, copy the template under its actual SHA-256 key and
fill every record area from retained observations. Capture paths are relative to
the explicit evidence root; use `versioned` or `retained`, an immutable capture
identity and its exact byte SHA-256. Retain raw evidence outside ignored scratch
files. Shared identities use sanitized role labels; account paths and interpreter
paths belong only in the ignored local invocation capture.

Each result names its producing run, captures and original `inputs`: `archive`,
`application`, `pipeline`, `lock`, exact filename-to-digest `wheels`, and the full
`runtime` environment map. The current snapshot is derived from the candidate,
consumers and environments. To retain an unaffected result after changes, its
assessment must name `decision: unaffected`, a reason, captures, and the exact
`previous_inputs` and `current_inputs`. The old result keeps its run and inputs.
Wheel or lock changes always need fresh D10, ABI and application acceptance.

Required RHEL SQLite results are split into `PA3:rhel-build` and
`PA3:rhel-deploy`; other RHEL cells use `:rhel`. RHEL PA7-PA9 are optional and
Debian PA10-PA11 are inapplicable. RA5 and RA8 have separate `:publication` and
`:adoption` portions; RA6 is completion-only. `backend` retains the actual adapter
capability proof. Unknown IDs or states refuse. Empty states mean pending.

D10 contains one reading, or the permitted rebuild and second reading. Every
reading names exact wheel consumers, required nodes and both GCC provider
identities/capability conclusions. The lowest satisfying generation must match
the final packaged generation. Authority keeps source commit, declaration digest
and release revision distinct; a renewal also requires `renewal_proof` captures.

The application entry takes an explicit timestamped archive, `--version`,
`--release-record`, `--evidence-root`, `--cplx-repo`, `--release-revision`,
`--closure-results` and `--validator-capture`. Set `TOOLS_RELEASE_PYTHON` to the
independent interpreter and pass `--with-tools --yes` for an unattended release.
The validator receives the selected coordinate and stores the interpreter
path/version, phase time, record/capture read counts and SHA-1/SHA-256 association
in the local capture. The publisher supplies its accepted SHA-256 to the closure
gate; `CPLX_TOOLS_RELEASE=1` makes an omitted guard a refusal. The gate compares
the promoted identity before loading an adapter and retains all inherited
authority, snapshot, waiver and streamed-byte checks. Ordinary application
publication retains its existing Maven path.

An unresolved or already recorded publication cannot invoke another upload.
Completion requires exact published digests and successful adoption with pin and
configuration revisions; a recovered prior configuration leaves this item
incomplete. Real release qualification, publication and adoption belong to the
later plan steps.

## Step 2 validation evidence

The [Step 2 capture](evidence.tools-archive-rebuild.step2-validation.txt) records
the final LF source hashes and native cumulative run: exit 0 in 44 seconds on
RHEL 9.8 with independent system Python 3.9.25. Shell lint and compilation passed;
16 validator tests took 3.602 seconds, 15 inherited adapter/publication tests
took 13.197 seconds, and six new release-entry tests took 1.200 seconds.
The 25 current SQLite checks and 254 frozen publication checks also passed.
The frozen suite retains the historical input pair described in Step 1.

The new entry tests keep promotion, descriptor handling and streaming real,
while substituting the separately tested closure-content checks. They prove
archive replacement, ineligible records, empty validation output and a missing
gate guard cannot even load the spy adapter. Positive cases prove exact-byte
streaming and compatibility for existing gate callers. Ordinary application
release and snapshot behavior remains covered by the inherited process tests.

An independent Windows Python 3.13.9 run passed all 16 validator tests and
measured 100% statement coverage of `tools_release_record.py`: 276 statements,
zero missing. Finite generated mutations cover every mandatory cell, state and
metadata area without an additional property-testing dependency. Capture tests
check integrity, retention, direct read counts and protection from log overwrite.
RA5's adoption evidence includes the normal-pin retrieval confirmation.

The application's forced `ghog day` walk ended on 2026-09-17 at 10:33:54 +02:00
with `state=done`, exit 0: check 2m 30.4s, affected selection 9.8s and full suite
4m 21.5s (6040 collected). The full verdict reports zero failures, three warnings,
eight expected failures, 100% coverage, zero duration outliers and zero exclusions.
Its coverage scope is `src/pdfss`; the validator's separately measured coverage
and native process fixtures establish the tools changes.

Physical Python lines are 369 for the validator, 332 for its unit tests and 148
for the publication process tests, below the 650-line ceiling. The record is read
once, explicitly referenced captures are hashed once per resolved path, and the
archive is hashed with bounded 1 MiB buffers. The fixed acceptance matrix and
digest maps add no sorting, history scan or all-pairs traversal. No timing gate
was added. The pending record still certifies no candidate or actual release.

## Generated release record

Source: `acceptance.tools-archive-rebuild.json`.

### Release record identities and retained references

```json
{
  "schema_version": 1,
  "preparation": {
    "state": "pending",
    "reason": "Final candidate is not built or qualified; Step 1 capability only",
    "cplx_revision": "66de88c2b2d8259fb8b67d161823745e7d0b7685",
    "application_revision": "7a2c1c1650a1252e9e73c4dbc9dfe73bcf5d8b87",
    "validator": {
      "identity": "independent-rhel-system-python",
      "version": "3.9.25",
      "independent": true
    },
    "captures": {
      "backend-preflight": {
        "identity": "backend-preflight-20260917",
        "path": "evidence.tools-archive-rebuild.backend-preflight.txt",
        "sha256": "a214a297205d8a50438e16de240933370f7bff7c93ea8d1deb47a8c7063c08f1",
        "retention": "versioned"
      },
      "stream-probe": {
        "identity": "stream-probe-20260917",
        "path": "evidence.tools-archive-rebuild.stream-probe.json",
        "sha256": "d7faa04202d0b69f0f0ea36c0dc25be3be2d52af665849a1dc5c5603e4e000b5",
        "retention": "versioned"
      },
      "adapter-http": {
        "identity": "adapter-http-20260917",
        "path": "evidence.tools-archive-rebuild.adapter-http-probe.json",
        "sha256": "1979d008787626659e67a5e5dbe4b8ec0e52e826283cf5e345ff96cad40c435b",
        "retention": "versioned"
      },
      "step1-validation": {
        "identity": "step1-validation-20260917",
        "path": "evidence.tools-archive-rebuild.validation.txt",
        "sha256": "5acd6af885fb9eab2d119b4c6b53b24eac46d739d4f832b3b147029d721bef3c",
        "retention": "versioned"
      }
    }
  },
  "candidates": {},
  "pending_candidate": {
    "candidate": {
      "filename": null,
      "size": null,
      "sha256": null,
      "sha1": null,
      "python": null,
      "payloads": {},
      "regression": {
        "date": null,
        "decision": null,
        "sources": []
      }
    },
    "authority": {
      "source_commit": null,
      "declaration_sha256": null,
      "release_revision": null,
      "renewed": null,
      "captures": []
    },
    "consumers": {
      "application_revision": null,
      "pipeline_revision": null,
      "lock_sha256": null,
      "wheels": {},
      "venv_base": null
    },
    "environments": {
      "debian": {
        "run": null,
        "os": null,
        "image": null,
        "container": null,
        "runtime": {},
        "transfer_sha256": null
      },
      "rhel-build": {
        "run": null,
        "os": null,
        "image": null,
        "container": null,
        "runtime": {},
        "transfer_sha256": null
      },
      "rhel-deploy": {
        "run": null,
        "os": null,
        "image": null,
        "container": null,
        "runtime": {},
        "transfer_sha256": null
      }
    },
    "validator": {
      "identity": null,
      "version": null,
      "independent": true
    },
    "captures": {},
    "results": {
      "AR1": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "AR2": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "AR3": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "AR4": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA1:debian": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA1:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA2:debian": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA2:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA3:debian": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA4:debian": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA4:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA5:debian": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA5:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA6:debian": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA6:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA7:debian": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA7:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA8:debian": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA8:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA9:debian": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA9:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA10:debian": {
        "state": "not applicable",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA10:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA11:debian": {
        "state": "not applicable",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA11:rhel": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA3:rhel-build": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "PA3:rhel-deploy": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA1": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA2": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA3": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA4": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA5:publication": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA7": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA8:publication": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "backend": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA5:adoption": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA6": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      },
      "RA8:adoption": {
        "state": "pending",
        "run": null,
        "captures": [],
        "inputs": {}
      }
    },
    "d10": {
      "packaged_generation": null,
      "selected_generation": null,
      "readings": []
    },
    "assessments": {},
    "publication": {
      "coordinate": null,
      "state": "pending",
      "sha256": null,
      "sha1": null,
      "captures": []
    },
    "adoption": {
      "state": "pending",
      "recovery": "pending",
      "captures": [],
      "pin_revision": null,
      "configuration_revision": null
    }
  }
}
```
