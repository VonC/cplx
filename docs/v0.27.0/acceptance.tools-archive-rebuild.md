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
