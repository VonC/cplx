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

Step 2 introduced the [versioned sidecar](acceptance.tools-archive-rebuild.json)
with a pending template outside `candidates`. Step 5 now adds the actual archive
identity below. Synthetic digests and fixture passes cannot qualify a release.
Step 1's captures remain under `preparation` as historical capability evidence.

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
was added. Step 2 established the evidence mechanism; actual candidate evidence
is recorded separately in Step 5 below.

## Step 5 candidate and build evidence

The isolated RHEL build produced `tools.2026-09-17_222857.tar.gz` (545310257 bytes), SHA-256
`d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1`, SHA-1 `ac9927522895ff4541c6c45b1c48954f28e08c97`. The exact archive is retained with its raw
captures on the build host. The [candidate capture](evidence.tools-archive-rebuild.step5-candidate.json)
binds the archive to build and installed SQLite results, operator probes,
commands, durations, preservation comparisons and archive assertions.

The [dated Python selection](evidence.tools-archive-rebuild.python-selection.md)
selects 3.13.15 after the upstream regression check. The
[input capture](evidence.tools-archive-rebuild.step5-inputs.json) records the
official source archive, 81 distinct RPM hashes and all 106 curated dependency
rows resolved through the existing RHEL 9.8 index and RHEL 9.6 list fallback.
The existing refresh, superseded-version cleanup, reconfiguration, promotion
and package entries ran in an owned namespace; Git was reused. No host package
installation or Git rebuild occurred.

Refresh retained its diagnosed refusals: exhausted temporary space, a missing
selected-tool context during Git mirroring, and the OpenSSL configuration link
reintroduced by its RPM. The successful continuation used owned temporary space,
the installer's normal selected-tool link, and the already accepted exact copy
of the host's immutable FIPS configuration into the owned tree. The 54 completed
Python refresh rows were reused. Existing extraction may retain newer files;
RPM identities describe inputs, not byte provenance for every installed object.
The measured runtime comparison checked 126 shared paths and
aligned 2 Git paths to the refreshed Python tree, preserving
previous bytes in the raw capture. This repeats the existing coherent-runtime
preparation and changes no live installation.

The first build entry stopped before compilation after loading the previous Git
selection. Its failed capture and successful live comparison are retained. The
continuation explicitly selected Python before invoking the unchanged installer.

The unchanged SQLite acceptance driver proved a fresh `--reconfigure` build,
`MODULE__SQLITE3_STATE=yes`, and conclusive source-build, installed and promoted
operator probes. Each probe commits, closes, reopens and reads a file-backed
database in the same process that checks the mapped SQLite provider identity;
the build probe also verifies mapped libpython. Selected source/RPM payloads,
Git executable sentinels and the project sentinel were preserved. Live trees,
environment files and profile passed both before/after comparisons.

The private package stage removes only `tools/python/root/a.out`. Parent-link
boundaries and a directory at that exact path refuse packaging; terminal links
are unlinked safely. The inherited relocation harness changes only its discharged
literal ownership register. The [focused regression harness](verify.tools-release-package.sh)
passed seven package cases and five ownership controls, including stale and
unowned residuals. Full native cumulative validation passed as recorded in the
[validation capture](evidence.tools-archive-rebuild.step5-validation.txt).

Actual archive checks passed 539 cases with zero failures, including AR1, AR2
and AR4: no unrecorded selected program,
no residual handoff member, and no stale ownership entry. The
[archive oracle](inventory.tools-archive-rebuild.txt) was frozen before inspecting
the candidate. It retains item 2's program list with the planned Python version
substitution; historical library rows satisfy the inherited parser contract and
do not certify the refreshed archive's complete library inventory. The loader and
Python launch checks passed on the exact extracted archive. The real package
closure gate ran on the trimmed stage before tar creation.

The [authority capture](evidence.tools-archive-rebuild.step5-authority.txt)
verifies source commit `13c80d572ba7bda91728806ad7dc11c53629a506`, retention merge
`5f8d4d67ca549bb74e3bcbb798124d628c3d0619` and declaration digest
`63a955f8bded96f6a469764c625e9653c0988abe03ebd8192fc541f802d9d5aa`.
No declaration renewal was needed. Build base
`6ed601008162f0527d289758005f7e16cffaf806` and the hashed Step 5 source overlay
are recorded separately from the future publishing revision, which remains unset.

Raw evidence is retained outside ignored workspace scratch in
`step5-raw-captures.tar.gz`, SHA-256 `7a06c17d136b0b6055cba861d4e4f220264ebf12a497a0a8e27e851aafb5d1bf`, beside the copied candidate.
It includes the exact private invocation paths, original probes, complete logs,
file inventories, input payloads and refused attempts. The versioned capture sanitizes
account paths while preserving raw hashes and producing-run identity; the local
retention mapping remains private.

Only AR1, AR2, AR4 and RA1 are recorded as passing here. All required platform
acceptance, full multi-role RA2, D10, wheel/lock identities, publication and
adoption remain pending. The result input snapshots preserve those unknown
values explicitly. Step 6 must bind its exact consumer/runtime inputs and
reassess or rerun affected cells; this record cannot authorize publication.

## Generated release record

Source: `acceptance.tools-archive-rebuild.json`.

### Candidate d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1

| Acceptance | State | Producing run |
| --- | --- | --- |
| AR1 | pass | tools-archive-rebuild-step5-20260917-rhel-build |
| AR2 | pass | tools-archive-rebuild-step5-20260917-rhel-build |
| AR3 | pending | None |
| AR4 | pass | tools-archive-rebuild-step5-20260917-rhel-build |
| PA1:debian | pending | None |
| PA1:rhel | pending | None |
| PA2:debian | pending | None |
| PA2:rhel | pending | None |
| PA3:debian | pending | None |
| PA4:debian | pending | None |
| PA4:rhel | pending | None |
| PA5:debian | pending | None |
| PA5:rhel | pending | None |
| PA6:debian | pending | None |
| PA6:rhel | pending | None |
| PA7:debian | pending | None |
| PA7:rhel | pending | None |
| PA8:debian | pending | None |
| PA8:rhel | pending | None |
| PA9:debian | pending | None |
| PA9:rhel | pending | None |
| PA10:debian | not applicable | None |
| PA10:rhel | pending | None |
| PA11:debian | not applicable | None |
| PA11:rhel | pending | None |
| PA3:rhel-build | pending | None |
| PA3:rhel-deploy | pending | None |
| RA1 | pass | tools-archive-rebuild-step5-20260917-rhel-build |
| RA2 | pending | None |
| RA3 | pending | None |
| RA4 | pending | None |
| RA5:publication | pending | None |
| RA7 | pending | None |
| RA8:publication | pending | None |
| backend | pending | None |
| RA5:adoption | pending | None |
| RA6 | pending | None |
| RA8:adoption | pending | None |

### Release record identities and retained references

```json
{
  "schema_version": 1,
  "preparation": {
    "state": "pending",
    "reason": "Historical Step 1 capability; Step 5 candidate is identified, with Step 6 runtime qualification and publication still pending",
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
  "candidates": {
    "d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1": {
      "candidate": {
        "filename": "tools.2026-09-17_222857.tar.gz",
        "size": 545310257,
        "sha256": "d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1",
        "sha1": "ac9927522895ff4541c6c45b1c48954f28e08c97",
        "python": "3.13.15",
        "payloads": {
          "make-4.3-8.el9.x86_64.rpm": "3f6a7886f17d9bf4266d507e8f93a3e6164cb3444429517da6cfcacf041a08a4",
          "zlib-1.2.11-41.el9.x86_64.rpm": "370951ea635bc16313f21ac2823ec815147ed1124b74865a34c54e94e4db9602",
          "zlib-devel-1.2.11-41.el9.x86_64.rpm": "f41f5fc4a53f5b84e06b815dd3402847eb0415bf74bfb77ce490d9920fab91b4",
          "gmp-6.2.0-13.el9.x86_64.rpm": "b6d592895ccc0fcad6106cd41800cd9d68e5384c418e53a2c3ff2ac8c8b15a33",
          "libzstd-1.5.5-1.el9.x86_64.rpm": "3439a7437a4b47ef4b6efbcd8c5862180fb281dd956d70a4ffe3764fd8d997dd",
          "gcc-11.5.0-15.el9.x86_64.rpm": "99e891f10bc6497834668940313d2e8c7fdba72547499d5be8a6ec6fceabf878",
          "cpp-11.5.0-15.el9.x86_64.rpm": "1c1e4c8785b647ea94981f83c20ffe23d660e6a2b6ba88841a180dd1de102102",
          "libmpc-1.2.1-4.el9.x86_64.rpm": "207e758fadd4779cb11b91a78446f098d0a95b782f30a24c0e998fe08e2561df",
          "libgcc-11.5.0-15.el9.x86_64.rpm": "522e07f3a8a09a6d5c9174340031d3002d319d4f6ecad8a483d30d68f02fc36d",
          "glibc-2.34-276.el9.x86_64.rpm": "d426507e84b3c89b464b5e4149c8137d8b21facbc25ef0c56e7e342048853e8b",
          "libstdc++-11.5.0-15.el9.x86_64.rpm": "aef7b17304d056eb7cbd07ecf8cb75e10de85b010b15905d3127d06bdf045ffe",
          "binutils-2.35.2-72.el9.x86_64.rpm": "6f9b078ceaae9d8f4b87158b1fa911efe08e54287513232def5730d125b25900",
          "glibc-devel-2.34-276.el9.x86_64.rpm": "2d670b03a572998c4004da93741085370694e186525dea16e2d9367b67d8fb32",
          "glibc-headers-2.34-276.el9.x86_64.rpm": "e9acc9fe7ead2449403aff40e760ddf2b4f69260ac882fb24e7b8a05de9d780f",
          "kernel-headers-5.14.0-737.el9.x86_64.rpm": "c7d0a45580c58744421ac1c9b23855a80d493f5298ce90e4014308fc9c31d9b8",
          "ncurses-devel-6.2-12.20210508.el9.x86_64.rpm": "b8cadf3cfef76ce367666cf45303f648a1780c8ef381176fd1365fe74026dc35",
          "openssl-libs-3.5.7-3.el9.x86_64.rpm": "a9f646a8992864ce82fd8ce8140c9e118a2b7e17c64fc085949ae777566f7ff3",
          "openssl-3.5.7-3.el9.x86_64.rpm": "3ec16bd697b1e8925ffb3577dafc6a69732f14016fd0921a9395ce9d9f2bc0fe",
          "openssl-devel-3.5.7-3.el9.x86_64.rpm": "462fa61fd55922e4eaf0834dd206f79e876f4a045b33f69f24c9260919da3891",
          "openssl-pkcs11-0.4.11-9.el9.x86_64.rpm": "5dee50eca9c7768d1d8579e7b78f400e6b2f75262b0a8f064ee9633fab6b16c1",
          "openssl-perl-3.5.7-3.el9.x86_64.rpm": "a5b1afa5749ad5e7c6583c8fa0440ce23a78c43283381030d86689609ac0b801",
          "bzip2-libs-1.0.8-11.el9.x86_64.rpm": "e1f4ca1a16276a6ede5f67cab8d8d2920b98531419af7498f5fded85835e0fca",
          "bzip2-1.0.8-11.el9.x86_64.rpm": "27de96d7fb8285910bdd240cf6c6a842863b9a01d20b25874f5d121a16239441",
          "bzip2-devel-1.0.8-11.el9.x86_64.rpm": "4395fefd067ebca746021d6f76fa9beaa07f890bd8cbd23d84db4e9f3f786b86",
          "libffi-3.4.2-8.el9.x86_64.rpm": "110d5008364a65b38b832949970886fdccb97762b0cdb257571cc0c84182d7d0",
          "libffi-devel-3.4.2-8.el9.x86_64.rpm": "39464cd83d7779bfbcadabe14a46bd8e8d90f7a73500e9d0481c8b1d9ce5dbdf",
          "ncurses-6.2-12.20210508.el9.x86_64.rpm": "7f23a7c5b57d3a5bf58ba306a5863073026aeaa468ce39c417a34dd3fd79a013",
          "ncurses-libs-6.2-12.20210508.el9.x86_64.rpm": "7b396883232158d4f9a6977bcd72b5e6f7fa6bc34a51030379833d4c0d24ab6f",
          "gdbm-libs-1.23-1.el9.x86_64.rpm": "cada66331cc07a4f8a0701fc1ad13c346913a0d6f913e35c0257a68b6a1e6ce0",
          "gdbm-devel-1.23-1.el9.x86_64.rpm": "2b692995878dd17d2072f85db626cce5b9014670122705e3b8f7dbc3a41a212b",
          "libgpg-error-1.42-5.el9.x86_64.rpm": "a1883804c376f737109f4dff06077d1912b90150a732d11be7bc5b3b67e512fe",
          "libgpg-error-devel-1.42-5.el9.x86_64.rpm": "7b19450714eef8b6c85ff2ace6d26921a05e8a6f5181dba76d5c26d9ade96823",
          "libgcrypt-1.10.0-13.el9.x86_64.rpm": "71026b5a461fc0c4777db81a529dea0f9205f74c175bbdfbc0f5bab8475d05c9",
          "libgcrypt-devel-1.10.0-13.el9.x86_64.rpm": "86aea1605c9f3c8d5e11d25faeaab513618cad1fcfec1d6ebab1ea4bf6b1a861",
          "libxml2-2.9.13-16.el9.x86_64.rpm": "66a9bffc0993810538f3532a1964d56e7a073c128a9dbe8e394bbe56cd29f5d6",
          "libxml2-devel-2.9.13-16.el9.x86_64.rpm": "6d1f30f41f76a7b318f9aaef59dee0870d0101a57faafd0ca588954a68945e4b",
          "xz-5.2.5-8.el9.x86_64.rpm": "159f0d11b5a78efa493b478b0c2df7ef42a54a9710b32dba9f94dd73eb333481",
          "xz-devel-5.2.5-8.el9.x86_64.rpm": "b04077515f5bea9a46adaf85a5217cec0f7eaa2a1286c5147310aedfc57bf94f",
          "xz-libs-5.2.5-8.el9.x86_64.rpm": "ff3c88297d75c51a5f8e9d2d69f8ad1eaf8347e20920b4335a3e0fc53269ad28",
          "libxslt-1.1.34-16.el9.x86_64.rpm": "7695356471d253e2017cf4b3aa56e1d00cca841950bdf01c6963fc6a9e3162dc",
          "libtool-ltdl-2.4.6-46.el9.x86_64.rpm": "a04d5a4ccd83b8903e2d7fe76208f57636a6ed07f20e0d350a2b1075c15a2147",
          "gnutls-3.8.10-8.el9.x86_64.rpm": "7995375d84e6592cdba3d94ba01e47f5607aecb2ff73b7af67a756def78e8a31",
          "p11-kit-0.26.4-1.el9.x86_64.rpm": "185c0ee8f5470fe94b492f11c1e0c1674be3051062e906cdd32473a5ff8db045",
          "p11-kit-devel-0.26.4-1.el9.x86_64.rpm": "15f734762be6b78244453f4ad0bd5758a8620f4eec4a8b5e18b8fb0845a31477",
          "p11-kit-trust-0.26.4-1.el9.x86_64.rpm": "8dc277e3855df15bf2db2e8acd03e08311cd565152fa958ac75cbb862f98ebe1",
          "libtasn1-4.16.0-10.el9.x86_64.rpm": "05f75ceb9f083ec511756eb9ed4078368c56ad55a6fe0abb819b8948e50b0d90",
          "nettle-3.10.1-1.el9.x86_64.rpm": "aa28996450c98399099cfcc0fb722723b5821edff27cff53288e1c0298a98190",
          "libidn2-2.3.0-7.el9.x86_64.rpm": "f7fa1ad2fcd86beea5d4d965994c21dc98f47871faff14f73940190c754ab244",
          "libuuid-2.37.4-27.el9.x86_64.rpm": "2e340e7920662e24867f38f624b199102384f9142010a0d10223ee5acc31a0d5",
          "libuuid-devel-2.37.4-27.el9.x86_64.rpm": "bb70205ddb96e05974cac56652c2158948839097a1b5b3ffdee321ec900d41f6",
          "readline-8.1-4.el9.x86_64.rpm": "49945472925286ad89b0575657b43f9224777e36b442f0c88df67f0b61e26aee",
          "readline-devel-8.1-4.el9.x86_64.rpm": "9587d558de77fe136d93aa449b1eb31e2afb56328fa04cd3bb7291f28c0d0876",
          "sqlite-libs-3.34.1-11.el9.x86_64.rpm": "dfdc4f315ec0723e6c2687f810bcc5a9d3cb83f4d73496734645123bd5a6f3d4",
          "sqlite-devel-3.34.1-11.el9.x86_64.rpm": "6c7f364e6c25c427c83619b851df26bd96d917e3c0d58b4dfa9416a72e744259",
          "unzip-6.0-59.el9.x86_64.rpm": "84afb7b45bb59601ec32a3bc89ce2df71f296dc90bacae650582951b25c303e4",
          "glibc-common-2.34-276.el9.x86_64.rpm": "30bcfae00ae8128416a96a2df6ff4c986cce05d9ffb29d1b9e39b6c8b460ce40",
          "libcurl-7.76.1-43.el9.x86_64.rpm": "f346e10b0fb6174716c52e9f09994888df1a38f34d033a2c01d5156c470cfdad",
          "libcurl-devel-7.76.1-43.el9.x86_64.rpm": "74e035e96c17c2e3cd9045c594b6bbf6347d2070ea66680e321ca945ed721fbd",
          "expat-2.5.0-7.el9.x86_64.rpm": "91f7f3ca1a349fefc44a35229bdb9796a6fec6b717591ee537059039b2c68024",
          "expat-devel-2.5.0-7.el9.x86_64.rpm": "03da46a24f3a206fb0ceb202d196842ea8ddf23f857b6ce16ff741db10bf9e8c",
          "libxcrypt-4.4.18-3.el9.x86_64.rpm": "97e88678b420f619a44608fff30062086aa1dd6931ecbd54f21bba005ff1de1a",
          "libxcrypt-devel-4.4.18-3.el9.x86_64.rpm": "162461e5f31f94907c91815370b545844cc9d33b1311e0063e23ae427241d1e0",
          "libcom_err-1.46.5-8.el9.x86_64.rpm": "ef43794f39d49b69e12506722e432a497e7f96038e26cab2c34476aad4b3d413",
          "libcom_err-devel-1.46.5-8.el9.x86_64.rpm": "2f305bb2283ce2b5d39e52a4a362150b764b8082d63fdbcb3d553b0282d1cb6d",
          "m4-1.4.19-1.el9.x86_64.rpm": "42683a7130bb3f7052d785dbe10ca285b391f934f98fc649c9e8b754112bdba3",
          "autoconf271-2.71-8.el9.noarch.rpm": "831e80c3abc6742e4a1298197f8ab47bbae4b1708aac4825d83e652f5e08559e",
          "perl-File-Compare-1.100.600-483.el9.noarch.rpm": "ab670ad4fb9bd69072af6435799b18c5aa1d75614cdf3cb97703813d57165085",
          "perl-File-Copy-2.34-483.el9.noarch.rpm": "5562614522645bad82222badd06fdcc0b41f52048147affa71350fcea25b38f7",
          "asciidoc-9.1.0-3.el9.noarch.rpm": "8ffc5da843e050d6b825e3a8c6d8f85da552b2569da2e4f61468e7f531d89688",
          "docbook-style-xsl-1.79.2-16.el9.noarch.rpm": "d61504dec1e351ffea978a7e38494b06bb70716d7c20d1e4e8269e618dc6b0c3",
          "docbook-dtds-1.0-79.el9.noarch.rpm": "cf2a325450a11d4ccd8b7e4f33d37da7ac446c14b1ec195667aaa7275ebaa38d",
          "xmlto-0.0.28-17.el9.x86_64.rpm": "a24de83373d07692432d4698e28a268302bad2dd8a54966d886f507b85c6b5a0",
          "glib2-2.68.4-21.el9.x86_64.rpm": "14d17524b3ebb78f5bd090092c870ef2ff22c9e7e6e76be61bef586dd6e41a9a",
          "elfutils-libelf-0.195-1.el9.x86_64.rpm": "a40d7e70ab22bd27d37ce9bbc6be25aceaee9cdc4dc9989863d6ed8bd3fe6727",
          "glib2-devel-2.68.4-21.el9.x86_64.rpm": "5848fddf9b3a5eb9affd99ad16733ad0ed3fb7edde619ee4f6c8a7241a8b9775",
          "libassuan-2.5.5-3.el9.x86_64.rpm": "3f7ab80145768029619033b31406a9aeef8c8f0d42a0c94ad464d8a3405e12b0",
          "libmount-2.37.4-27.el9.x86_64.rpm": "c9a9db91ef7911a1a88b2716cbde213c2a627f0d8ac5444438b03808afbabfdf",
          "libmount-devel-2.37.4-27.el9.x86_64.rpm": "9ae45227ea082b27fa9784628d3126cb093bf7ec1c8e5427d25e2313e9fa1350",
          "libsecret-0.20.4-4.el9.x86_64.rpm": "6bc2db2e95a95c1e0be74c7edfe021d450293353b98d81678b61ac6b1b2bf886",
          "libsecret-devel-0.20.4-4.el9.x86_64.rpm": "204a40008d581ce233d2b2883c23ede763b12e65e18de299290b1a7e3ce7aee3",
          "pinentry-tty-1.1.1-8.el9.x86_64.rpm": "1a5efaac607981f743f172ceebd3563e19b4a5e7fbdda4821fdb3ee4f18ef362",
          "python-src-3.13.15.tar.gz": "c28d9d213c09b5b5ab2c29812950e12f746999e099b82894231be954b26baed9"
        },
        "regression": {
          "date": "2026-09-17",
          "decision": "clean",
          "sources": [
            "python-selection"
          ]
        }
      },
      "authority": {
        "source_commit": "13c80d572ba7bda91728806ad7dc11c53629a506",
        "declaration_sha256": "63a955f8bded96f6a469764c625e9653c0988abe03ebd8192fc541f802d9d5aa",
        "release_revision": null,
        "renewed": false,
        "captures": [
          "step5-authority",
          "step5-candidate"
        ]
      },
      "consumers": {
        "application_revision": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
        "pipeline_revision": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
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
          "run": "tools-archive-rebuild-step5-20260917-rhel-build",
          "os": "RHEL 9.8 x86_64",
          "image": null,
          "container": null,
          "runtime": {
            "python": "3.13.15",
            "sqlite_provider_sha256": "007322505ff5177c820251b31612a9e4c2e6e4c78a5ad62df81d92ba329d65ff"
          },
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
        "identity": "independent-rhel-system-python",
        "version": "3.9.25",
        "independent": true
      },
      "captures": {
        "python-selection": {
          "identity": "python-selection-20260917",
          "path": "evidence.tools-archive-rebuild.python-selection.md",
          "sha256": "5863e78fe8a7b7ef476fb95ba131018ce2ef1af9c22d803a7512950070b517f0",
          "retention": "versioned"
        },
        "step5-authority": {
          "identity": "step5-authority-20260917",
          "path": "evidence.tools-archive-rebuild.step5-authority.txt",
          "sha256": "c1bf941f922321b02431ff124288cc5497e8dc120e5600fe389ed06c564e9d65",
          "retention": "versioned"
        },
        "step5-inputs": {
          "identity": "step5-inputs-20260917",
          "path": "evidence.tools-archive-rebuild.step5-inputs.json",
          "sha256": "14e3c52ec320ca21e6c67b849bab66d6ffb96d05d320e8815d6c4e8c29aad675",
          "retention": "versioned"
        },
        "step5-validation": {
          "identity": "step5-validation-20260917",
          "path": "evidence.tools-archive-rebuild.step5-validation.txt",
          "sha256": "e00c3be405c4dadd1e87d13f9c44e305a41af53b0aa824cf067868c8169c6b50",
          "retention": "versioned"
        },
        "step5-candidate": {
          "identity": "step5-candidate-20260917",
          "path": "evidence.tools-archive-rebuild.step5-candidate.json",
          "sha256": "7fb03becc9d73c850c093f5aa6c04886922dc58a27a659fa89d29b00b8acf693",
          "retention": "versioned"
        },
        "step5-oracle": {
          "identity": "step5-oracle-20260917",
          "path": "inventory.tools-archive-rebuild.txt",
          "sha256": "f19f9cdc6c856a3697addb705f09e67103f8c9802a44761d6e189b865a9c8db8",
          "retention": "versioned"
        }
      },
      "results": {
        "AR1": {
          "state": "pass",
          "run": "tools-archive-rebuild-step5-20260917-rhel-build",
          "captures": [
            "step5-candidate",
            "step5-oracle",
            "step5-validation"
          ],
          "inputs": {
            "archive": "d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1",
            "application": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
            "pipeline": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
            "lock": null,
            "wheels": {},
            "runtime": {
              "debian": {
                "run": null,
                "os": null,
                "image": null,
                "container": null,
                "runtime": {},
                "transfer_sha256": null
              },
              "rhel-build": {
                "run": "tools-archive-rebuild-step5-20260917-rhel-build",
                "os": "RHEL 9.8 x86_64",
                "image": null,
                "container": null,
                "runtime": {
                  "python": "3.13.15",
                  "sqlite_provider_sha256": "007322505ff5177c820251b31612a9e4c2e6e4c78a5ad62df81d92ba329d65ff"
                },
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
            }
          }
        },
        "AR2": {
          "state": "pass",
          "run": "tools-archive-rebuild-step5-20260917-rhel-build",
          "captures": [
            "step5-candidate",
            "step5-oracle",
            "step5-validation"
          ],
          "inputs": {
            "archive": "d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1",
            "application": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
            "pipeline": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
            "lock": null,
            "wheels": {},
            "runtime": {
              "debian": {
                "run": null,
                "os": null,
                "image": null,
                "container": null,
                "runtime": {},
                "transfer_sha256": null
              },
              "rhel-build": {
                "run": "tools-archive-rebuild-step5-20260917-rhel-build",
                "os": "RHEL 9.8 x86_64",
                "image": null,
                "container": null,
                "runtime": {
                  "python": "3.13.15",
                  "sqlite_provider_sha256": "007322505ff5177c820251b31612a9e4c2e6e4c78a5ad62df81d92ba329d65ff"
                },
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
            }
          }
        },
        "AR3": {
          "state": "pending",
          "run": null,
          "captures": [],
          "inputs": {}
        },
        "AR4": {
          "state": "pass",
          "run": "tools-archive-rebuild-step5-20260917-rhel-build",
          "captures": [
            "step5-candidate",
            "step5-oracle",
            "step5-validation"
          ],
          "inputs": {
            "archive": "d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1",
            "application": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
            "pipeline": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
            "lock": null,
            "wheels": {},
            "runtime": {
              "debian": {
                "run": null,
                "os": null,
                "image": null,
                "container": null,
                "runtime": {},
                "transfer_sha256": null
              },
              "rhel-build": {
                "run": "tools-archive-rebuild-step5-20260917-rhel-build",
                "os": "RHEL 9.8 x86_64",
                "image": null,
                "container": null,
                "runtime": {
                  "python": "3.13.15",
                  "sqlite_provider_sha256": "007322505ff5177c820251b31612a9e4c2e6e4c78a5ad62df81d92ba329d65ff"
                },
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
            }
          }
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
          "state": "pass",
          "run": "tools-archive-rebuild-step5-20260917-rhel-build",
          "captures": [
            "python-selection",
            "step5-inputs",
            "step5-candidate"
          ],
          "inputs": {
            "archive": "d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1",
            "application": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
            "pipeline": "ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0",
            "lock": null,
            "wheels": {},
            "runtime": {
              "debian": {
                "run": null,
                "os": null,
                "image": null,
                "container": null,
                "runtime": {},
                "transfer_sha256": null
              },
              "rhel-build": {
                "run": "tools-archive-rebuild-step5-20260917-rhel-build",
                "os": "RHEL 9.8 x86_64",
                "image": null,
                "container": null,
                "runtime": {
                  "python": "3.13.15",
                  "sqlite_provider_sha256": "007322505ff5177c820251b31612a9e4c2e6e4c78a5ad62df81d92ba329d65ff"
                },
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
            }
          }
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
  },
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
