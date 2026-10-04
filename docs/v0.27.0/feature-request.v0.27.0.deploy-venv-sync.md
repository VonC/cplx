# Create the venv at deployment instead of shipping it

- Type: feature-request
- Version: v0.27.0
- Topic: deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Source draft: [Deployment venv draft](draft.v0.27.0.deploy-venv-sync.md)

## Revision introducing target-created environments

Revision of 2026-10-03: the human requires delivery through the consumer's
original deployment orchestration, unchanged, after restoring its entire
application path to the recorded baseline. AC16, AC17 and requirement Q11 add
this integration to the validated lifecycle. They preserve AC01-AC15 and the
consumer-acquisition/reusable-reconstruction boundary.

Revision of 2026-10-04: Step 8 covers the qualification environment only, where
the temporary delivery task can bootstrap before restoration. Mandatory Step 9
adds first-time and production delivery through the unchanged original contract,
after actual AC16/AC17 evidence closes Step 8. AC18, AC19 and requirement Q12
record this extension. The topic and its umbrella item remain pending until
Step 9 is validated.

Umbrella item 8 and decision D11 replace a copied application environment with
one reconstructed from the release lock on the deployment target. Item 7's
accepted toolchain archive and its publication/adoption evidence remain prerequisites.
The environment is lock-identical rather than a copy of the bytes tested by CI;
post-sync verification and a proven recovery procedure are therefore required.

As an application operator, I want deployments to create or synchronize a local
environment using the shipped toolchain Python and the application's release lock,
so application archives omit venvs while deployment remains reproducible,
verifiable, and recoverable on the supported targets.

Public cplx documents, examples, diagnostics, code, and review records use generic
application and deployment terms. Consuming-project names, archive classifiers,
installation paths, CI library entry points, private endpoints, credentials,
and build links belong to private configuration and evidence. Placeholders do
not rename existing application directories.

## Terminology for deployment-created Python venvs

A Python venv is an application's isolated Python installation directory.
The cplx toolchain means the shipped Python interpreter, supporting native
runtime libraries, and build/runtime utilities, not application Python library
dependencies. References to tools mean that toolchain. uv is the dependency
management utility used with that Python; Q10 confirms delivery with application
release inputs, separately from the toolchain archive.

A Python library referential supplies Python packages and their metadata.
A private mirror, for example an artifact-repository mirror, supplies those artifacts from
a configured private source. Availability concerns dependency downloads,
not Git staging.

A retained wheel is the exact original `.whl` artifact saved for a selected
release, Python/ABI/platform, and dependency group, with its identity and
canonical lock hash verified. Keep original wheel files and their manifest
available for post-sync comparison and recovery, not just filenames, installed
copies, URLs, or a disposable cache. For offline recovery they must already be
on the target or delivered with retained release archives; a remote service
alone is insufficient. Storage layout is left to design.

## Current behavior before the v0.27.0 deployment change

- Application packaging includes a venv; one measured environment occupied 529 MB.
- Deployment selects a project venv by recency and checks its executable, ELF
  interpreter, standard library, imports, and paths in `pyvenv.cfg` as part of
  validating a copied environment.
- CI already provisions and synchronizes an environment before packaging.
  Deployment must gain qualified uv provisioning and access to the dependency
  inputs needed for a locked reconstruction.
- A venv inside the application tree can be removed by archive mirroring with
  deletion semantics. Copy-based rollback no longer applies once it is excluded.
- The toolchain is built on RHEL and used on Debian CI. Compilation success alone does
  not establish that the reconstructed application environment runs correctly.

## Required packaging and Python venv lifecycle

1. Exclude every Python venv within the application packaging input tree.
   Identify its root by `pyvenv.cfg` and exclude the entire subtree, including
   current/stale versions, alternate names, and nested venvs; do not scan
   unrelated host paths. Preserve the release's
   `pyproject.toml`, canonical `uv.lock`, and the dependency/runtime inputs needed
   by the selected deployment and recovery mechanisms.
2. Create an absent Python venv locally on Debian 12 CI and RHEL 9.8 deployment.
   Keep and sync an existing Python venv only after interpreter validation.
   Recreate it after archive mirroring removes it. Do not transfer build or test
   venvs between hosts.
3. Preserve the application's location and naming contract, represented as
   `<application-root>/venvs/python_<version>_<project>`. Use the full actual
   toolchain-Python version, including the patch component, with the current
   normalization and project suffix. Preserve dots and convert dashes to
   underscores. For example, Python 3.13.15 and project `example` yield
   `venvs/python_3.13.15_example`.
4. Derive the exact Python venv path before checking existence. Creation,
   `UV_PROJECT_ENVIRONMENT`, sync, tests, and readiness must agree on that path.
   Do not choose the newest directory, reuse another version, rename an older
   venv to match, or create an implicit `.venv` in the controlled application flow.
   An explicit, verified alias to the canonical venv prepared by our scripts
   is not an implicit environment; it must not create a separate venv.
5. A Python version change selects its corresponding environment and creates it
   if absent. A stale lock or failed sync fails the operation, blocks readiness
   and subsequent packaging/publication, and must not report a partial
   environment as usable.

A failed in-place sync may leave the Python venv unusable. Report the failure
clearly and provide recovery through redeployment or rollback; uninterrupted
availability and preservation of the previous venv on every failure are not
required.

When the toolchain archive changes but its Python version and resulting venv
name do not, reuse the venv only after validation against the current interpreter,
prefix, locked dependencies, and runtime providers. Record the current archive
digest with fresh per-platform evidence; equal version strings are insufficient.

The invoking automation or operator must serialize changes to the same
application root. This covers two deployments syncing one venv, archive
mirroring/deletion overlapping a sync, and rollback overlapping forward
deployment. Verify that this precondition is enforced by the consuming deployment
procedure. Independent application roots may proceed independently; this topic
does not promise safe overlapping modifications to one root.

## Required toolchain Python and uv provenance

Use the absolute resolved `<tools-prefix>/python/current/bin/python3`, normally
`~/tools/python/current/bin/python3`, for creation and explicitly for uv sync.
Never select it merely through PATH, a version request, a foreign activated
environment, or a host Python executable. Disable automatic Python downloads.

Verify the resulting environment's base interpreter, base prefix, and full
version against the selected toolchain installation. Equal versions alone do not
prove interpreter identity. Missing or incompatible toolchain Python and an existing
foreign-base venv must fail clearly, without distribution or uv-managed fallback.

Provision qualified uv in the toolchain installation before sync, using toolchain
Python and its pip explicitly if needed, without system pip or administrator
installation. This install location does not decide which archive delivers uv.
For deployment and recovery, select exactly the artifact pinned by that
application release, whatever its install location. A shared installation must
not silently supply another release's uv. Phase 2's uv exception below does
not relax deployment or recovery provenance.
Q10 confirms digest-pinned uv delivered with the application release, preserving
the qualified toolchain archive unchanged. Select the latest stable uv at release
qualification, then freeze its exact version and artifact digest for that release,
including recovery; deployment must not resolve a floating latest version.
The latest stable release checked on 2026-09-22 is
[uv 0.12.17](https://github.com/astral-sh/uv/releases/tag/0.12.17).
Align the consuming tooling lock with the selected version and qualify the exact
artifact and delivery/bootstrap on both targets. Recheck latest stable when
qualification begins; a later version requires fresh qualification.
Deployment excludes the application's `tooling` group; CI declares its required
test dependencies and installs them through the lock, without a subsequent
unpinned installation in the controlled application venv.

## Required release lock and dependency source behavior

Both platforms run `uv sync --locked` from the application's release metadata.
Preserve the same canonical release lock and do not silently update resolution.
Platform-specific selections already expressed by lock markers and explicit
dependency groups are allowed; identical lock identity does not require identical
installed package sets on different platforms.

Public examples use PyPI (`https://pypi.org/simple`) or neutral placeholders.
Private consumers configure their Python library referential and authentication outside public cplx
artifacts, including for uv provisioning. Their deployments must not require
public Python library referential access. A Python library referential setting alone is not evidence that registry and
locked artifact URLs use the intended source.

A consuming-project clean/smudge filter is an option, not a selected public
mechanism. Any source mapping must preserve versions, dependency graph, markers,
artifact identities, and hashes, and prove a stable canonical/transport round
trip. Simple hostname substitution is not assumed to match an artifact layout.
Archive deployment must work without Git filters or a Git checkout on the target.
Materialize a valid effective lock and configuration before sync, retain its
verifiable relationship to the canonical lock, and do not bypass lock consistency.

After the consumer supplies the complete required files locally, validate cplx
bootstrap and locked reconstruction with empty caches and all remote artifact
services unavailable. Source transport, uv provisioning and recovery retention
must preserve this boundary; consumer acquisition precedes it.

Install Python library dependencies from compatible, prebuilt wheels on both
targets. Never fall back to building a dependency from source during venv
creation, synchronization, or recovery. A missing compatible wheel fails clearly
and blocks readiness. `--locked` establishes lock consistency but does not by
itself prohibit source builds; enforce and validate the no-build requirement
separately. The application project itself is not built or installed during
this dependency sync, for example by declaring it a non-packaged project;
only its dependencies are installed. Independent application packaging and
separate RHEL toolchain compilation remain distinct operations.

## Required wheel integrity and runtime readiness

Compare installed distributions with the canonical release lock's selected
identities and artifact hashes for the target platform and dependency groups.
Reject missing, mismatched, and extra distributions; a marker-excluded package
is not missing and a permitted platform difference is not drift. Compare each
installed wheel ELF with its corresponding binary in the original retained
wheel, using item 7's inventory helper. This does not promise byte verification
of every installed Python/data file.

Create the Python venv at its final path. Verify its Python links, generated
script shebangs, and configuration; no copied-venv relocation should normally
be necessary. Link or text-script path changes do not alter wheel library ELF
bytes. Do not apply blanket ELF rewriting even within `venv/bin`; wheel-supplied
ELFs there remain subject to the same integrity requirement.

Preserve the exclusion of every venv tree identified by `pyvenv.cfg` from ELF
relocation. Do not rewrite wheel ELFs or remove their `$ORIGIN` paths. Carry
forward the shared, versioned runtime setup with shipped library directories
first in `LD_LIBRARY_PATH`, without relying on an account-private runtime file.
Interpreter RPATH alone is insufficient evidence of provider selection when a
wheel has its own RUNPATH.

Replace relocation-specific checks for copied venvs with checks appropriate to
target-created environments while retaining executable, interpreter, standard
library, and import health checks. Import heavy-wheel consumers on both targets
without per-wheel patching and qualify actual loaded providers. Debian evidence
includes an ABI listing and a conclusive live trace of venv Python, with no
missing version nodes or host fallback for ABI-critical libraries. An empty
trace is inconclusive. RHEL includes end-to-end readiness and operator setup;
qualify its providers according to item 7's validation matrix, without extending
Debian's no-host-fallback or live-trace requirement to RHEL.

## Required RHEL-to-Debian execution evidence

Build the toolchain on RHEL and deploy that exact archive on Debian for application
acceptance tests. Identify it by digest and versions, without substituting a
Debian rebuild. Reuse the qualified item 7 archive if this implementation does
not change its contents, preserving the earlier acceptance/adoption evidence.

RHEL validation exercises archive installation, local environment reconstruction,
application readiness, and rollback. Debian validation exercises actual
application acceptance tests and ABI/provider checks. Local/static checks and
RHEL compilation alone are insufficient substitutes for these executions.

For each platform retain OS/architecture, toolchain archive digest, Python and uv
versions, resolved base interpreter, venv path, canonical lock digest, selected
groups, and execution results. Sanitize private infrastructure details in public
reports while retaining exact operational evidence privately.

## Required single-build CI sequence without publication

Use one consuming-application Jenkinsfile, one Jenkins job, and one build of
that job. Phase 1 is our blocking application validation and packaging.
Phase 2 preserves the mandated shared-library sequence of CI stages, orchestrated
directly by the same Jenkinsfile in the same build after phase 1 succeeds. It is not
another job, a downstream build, or another Jenkinsfile; it may allocate
different agents and workspaces.

First execute blocking toolchain provisioning/relocation, named-venv locked sync, runtime and
ABI/provider checks, application acceptance tests, coverage checks, and independent
packaging. Archive evidence and preserve the application's build metadata.

Only after successful preliminary validation, release its agent allocation and
execute the mandated sequence of CI stages, preserving its conformity checks and
quality gates. Do not modify that shared library or create a second job. A
preliminary failure must fail the build and prevent the second CI phase from
starting; a later failure must leave the whole build failed.

The human-approved orchestration workaround scopes agents to the stages that
use them. Preserve stage order, the audited test body, coverage transfer, analysis,
quality checks and dry-run publication. Do not restore the long-lived outer
tools allocation or a redundant outer Python allocation around the actual test
agent. Workspace-dependent steps still require an agent. Qualification of this
orchestration does not establish an infrastructure fix or qualify the original
shared-library wrapper.

Make agent, workspace, and working-directory boundaries explicit. Prior shell
activation, files, and absolute venv paths cannot be assumed to carry into a
different agent. The second CI phase's dependency operations and coverage reports
are separate from the blocking application validation. They must not alter its
validated package or substitute for its evidence.

"Same environment" across the two CI phases means toolchain Python and locked
dependencies, not the same venv files. Phase 2 runs on freshly provisioned,
one-shot agents with their own checkout. Before the mandated test stage's
Python commands run, our application scripts must build a local, full-version
named venv on that test agent from the same toolchain archive digest, canonical
lock, and dependency groups as phase 1, using toolchain Python. The consuming
Jenkinsfile and a tracked application script provide the integration; the
mechanism belongs to design and shared-library sources remain unchanged.

Do not copy the phase 1 venv to phase 2. Do not let the library's own commands
create a replacement or implicit project venv, including one based on another
interpreter. Its dependency, activation, and test commands must use the venv
prepared by our scripts. An explicit, verified alias to that canonical venv
is not the implicit environment forbidden by lifecycle rule 4.

Phase 1's effective dependency selection must equal the selection the library's
unqualified sync applies, so that sync neither adds nor removes distributions.
Preserve the canonical
lock, no-build rule, configured sources, and runtime setup. Phase 2 may use any
uv version provided the before/after evidence proves the selected locked
inventory is unchanged and every dependency command succeeds. Record the
version actually used; exact equality with the qualified uv version is not
required in phase 2. Deployment and recovery still require release-pinned uv.

Record the phase 2 checkout revision and compare it with phase 1's, because
a fresh branch-tip checkout can differ from the earlier checkout. A revision
mismatch fails validation. A mismatch caused by a branch update between the
two checkouts is reported as such and requires a new build; it is not treated
as a product failure or silently accepted. Compare toolchain archive digest, canonical lock
digest, dependency groups, and selected package inventory with phase 1.
Capture phase 2's inventory before and after the library's Python commands.
Record the executing agent, resolved interpreter and base prefix, full Python
version, and local venv path; verify their provenance against the selected
toolchain rather than requiring equal absolute paths across agents.

Any dependency drift, wrong interpreter, failed library dependency command, or
missing comparison evidence fails validation even if the library masks the
failure. `pyvenv.cfg` contributes interpreter evidence but does not select the
venv for commands. Preserve phase 1's archived artifacts, coverage evidence,
cleanup, and the two-phase order; phase 2 reconstruction does not replace the
blocking phase 1 checks.

Phase 2 evidence does not establish application runtime parity. Establish its
success from commands actually executed and their results, not its overall
Jenkins status alone. A masked command failure is failed or inconclusive and
cannot count as successful topic validation.

Disable Maven deployment commands and release-artifact uploads in both phases.
Keep packaging independent of publication. A dry-run setting is acceptable only
when actual executed commands establish these semantics. Compatibility measures
must not hide failures or weaken dependency validation. Unresolved compatibility
leaves combined validation incomplete, without authorizing library changes.

Library entry points, repository identities, compatibility details, and job links
remain in private integration records. The public contract and validation report
must state the generic outcomes and any remaining gaps truthfully.

## Required recovery from the preceding release

Recovery means restoring the immediately preceding application release to
readiness after an unsuccessful deployment. Prove rollback on RHEL with every
Python library referential, mirror, and remote artifact service unreachable,
using only inputs already on the target or delivered with retained release
archives. Retain its qualified uv, compatible toolchain/runtime inputs, canonical
lock and dependency wheels as required by that release's recovery procedure.
Neither withdrawn artifacts nor a service outage may prevent this recovery.

For venv-free predecessors, reconstruct the Python venv from that release's
canonical lock without compiling dependencies. For the first transition,
redeploy the predecessor archive, including its shipped venv, using its own
deployment procedure. Lock-based reconstruction applies from the second
venv-free release onward. Both recovery forms must pass the offline readiness
test on the target.

After local delivery, cplx reconstruction must succeed without downloads, a target
Git checkout or previously cached packages. Deliver qualified uv with application
release inputs, preserving the toolchain archive. The consumer's earlier delivery
phase is outside this offline execution guarantee.

## Consumer delivery and offline reconstruction boundary

The consumer supplies the locations of the required files on the target machine,
together with their recorded versions and checksums. cplx verifies and uses those
files. The consumer decides how to obtain them. Acquisition, transport,
authentication and download policy belong to the consumer before invoking cplx;
they are outside the reusable cplx interface.

Required local inputs include the application archive and release record,
toolchain archive, qualified uv, dependency wheels, canonical metadata and
reconstruction helpers. A matching installed toolchain does not remove the
requirement to retain archives needed for reconstruction and predecessor recovery.

| Supplied information | Purpose |
| --- | --- |
| Path to the tools archive | Locate the archive already supplied on the target machine. |
| Required tools version and archive SHA-256 | Verify the exact qualified archive, rather than another file with a similar name. |
| Path to the reconstruction companion and its SHA-256 | Locate and verify the supplied helpers, uv, wheels and metadata. |
| Application release record | Associate these inputs with the application release being deployed. |

Versions and checksums identify files; they are not credentials. The complete
release manifest also binds the application and entry script as applicable.

Empty caches means installation tools cannot rely on packages left by an earlier
run. Explicitly retained release archives and wheels remain available: they are
required inputs, not disposable caches.

No target Git checkout means the deployment server need not clone the application
repository or execute Git filters to obtain dependency information. The supplied
release contains that information.

Remote artifact services are denied during cplx reconstruction to demonstrate
that the supplied files suffice. Consumer acquisition beforehand may use remote
services. Offline predecessor recovery still requires the complete retained set
and never depends on fetching missing recovery inputs.

## Required delivery through the consumer's unchanged orchestration

Human decision of 2026-10-03: conform to the orchestration exactly as it exists.
Its commands, order, variable inconsistencies and behavior are inputs, never
change requests. Restore the whole application path in the operations repository
to the recorded baseline while preserving concurrent changes elsewhere. This
path-only restoration is the only operations change. No role, template, job,
shared-library, access, network or privilege exception belongs to this effort.
The reusable reconstruction contract and consumer-owned acquisition boundary
remain unchanged.

| Finding | Required behavior or evidence |
| --- | --- |
| 1. Existing application archive | The role delivers the candidate's exact existing application archive only. Step 8 stop rehashes the four bootstrap-retained inputs with no fetch. Later Step 9 acquisition verifies entry, record, companion and tools before lifecycle change; tools reuse requires a retained exact-hash archive. Store them outside staging. No new transport bundle, registry field or publication is authorized; Selections are signed on the existing shared drive, with no artifact-repository publication. |
| 2. URL rewrite | Derive the role URL from the query-free immutable application asset plus the fixed sort/direction suffix, and prove byte equality. Consumer fetches use the four canonical URLs directly. Never resolve latest or a moving version. |
| 3. Unused deploy variable | Only stop and start execute consumer code. Start calls the verified entry synchronously and propagates its result. |
| 4. Prefix dispatcher | One executable host-Bash dispatcher at the fixed prefix-relative launcher accepts only the two specified argument shapes in expanded or literal home form. Home is only an argument check. No home files, PATH registration, general-shell link or eval. Stable versioned targets from previously verified application bytes survive replaced trees; strict ownership, realpath, mode and atomic installation are mandatory. Foreign existing launcher blocks bootstrap. |
| 5. Bootstrap ordering | New immutable candidate through the unchanged current five-input delivery installs the dispatcher and targets before restoration. Switch the source-controlled consumer payload only when the restored source is loaded; no real run with mismatched payload and source. |
| 6. Independent selection | Every attempt, retry and recovery requires a fresh short-lived human-signed selection on the existing shared drive. Stop verifies it with release N's stable public key before mutation, binds all five exact hashes/URLs and target identity, and refuses replay or mismatch. Part C installs trust and retention only, with no arming. |
| 7. Consumer gates | Assign all sixteen former delivery-task responsibilities to consumer code, each with nonzero failure. Held daemon-first start verifies both local APIs, exact revision/environment, disk/launch agreement and no drift, then releases hold and verifies same-daemon supervision. Re-hold on post-release failure. Rebudget the wrapper rather than putting two further five-minute checks inside its existing 600 seconds. |
| 8. Separate processes | Durable attempt reservation and short coordination lock span stop and start. Recheck reservation under the existing root deployment lock before install or recovery, excluding competing mutations. |
| 9. Check mode | Verify exact published bytes on the controller and use the original check job type without arming. Downloads and command tasks are skipped but directory creation may occur. Report controller verification and check traversal separately, with target execution untested. |
| 10. Explicit recovery | Reject native staging rollback. Each recovery has a fresh signed selection bound to the failed attempt and checkpoint. Our pipeline proves the previous job terminal; stop proves root-lock availability and no live attempt-owned process. No Step 8 operator channel. Both offline predecessor formats and failure before installer/pending state remain covered. |
| 11. Verification claim | No unchecked byte is installed or run, and any mismatch fails the deployment. The design rules below establish this claim despite staging before verification. |
| 12. Prerequisite evidence | Before C, our development account on the qualification host records host network/client and shared-folder read/write evidence. C application-account probes remain final authority for account-specific access/proxy, unit and closure, returned through shared logs. Retained check console supplies defaults and per-task orchestration overhead. Accept both tilde forms. Missing evidence blocks restoration. |
| 13. Staging cost | Replay exact filesystem staging on the same disks with current/previous trees. Add evidenced per-task orchestration overhead times remote operation count and conservative elapsed/disk headroom. The reference archive has 549 directories, 3,085 files, 47 MB packed/81 MB unpacked, about 550 two-operation rotations and 86 permission operations per tree. Fit existing job/pipeline/outage/disk bounds before C and remeasure G. Replay alone does not measure orchestration cost. |

### Stop flow under the fixed contract

Stop and start receive the same arguments for deployment and restart actions.
They derive operation type from a durable selection snapshot and file identity,
never from an action argument, newest file, timestamp alone or missing marker.

1. Verify host, non-root application account, real installation prefix and
   loaded service unit identity, including its user, start and pre-start commands.
2. Under a short coordination lock, validate and snapshot a signed deploy or
   recovery selection into an attempt reservation outside staging. Reject live
   conflicts and preserve failed/held recovery gates. Missing or invalid selection
   records the condition and admits ordinary stop only, with local exclusion,
   archive identity and checkpoint, no signed reservation and no share reread.
3. For Step 8's same-release deploy, rehash all four bootstrap-retained inputs
   without network, refusing missing or changed bytes. For later Step 9 deploy,
   fetch the entry, release record, companion and tools
   archive from the four exact canonical URLs before stopping anything.
   Reuse tools only when a retained archive hashes to the exact expected value.
   Bound transfers, reject fallback sources, check every digest, parse the
   release record as ten unique allowlisted keys without sourcing it, and
   cross-check its identities with the independent snapshot. Plain restart and
   recovery fetch nothing.
4. Record the delivered-archive path's file identity, sufficient to detect
   replacement with identical bytes, and the exact last working release.
5. Enter the existing cooperative deployment hold outside replaced trees,
   preserve the unit hook bridges, signal only verified unit members and
   confirm its parked host-sleep state within the existing 55-second bound.
   No root, unit edit or service-manager stop is involved.
6. Stop the application stack and script-started daemon within their bounds,
   confirm no survivors and return success.

Failures in items 1-4 return nonzero before role download, preserving the incoming
application and hold state. On a fresh running entry, failure entering or parking
the hold releases only the newly introduced hold, verifies restored supervision
and returns nonzero. An already held/stopped entry preserves its hold on failure.
Failure after stopping retains a failed attempt and requires bounded recovery.

### Start flow and deterministic operation selection

The start target downloads nothing. It reads the stop snapshot and compares the
current delivered-archive identity with the recorded pre-delivery identity.

| Stop snapshot | Archive delivered since stop | Mode |
| --- | --- | --- |
| Valid reserved deploy, matching | Yes | Deploy |
| Ordinary stop, no signed deploy/recovery reservation | No | Unsigned checked restart |
| Ordinary stop, no signed deploy/recovery reservation | Yes | Install nothing; checked checkpoint restoration and nonzero |
| Valid reserved recovery | No | Typed recovery, even if no installer call is needed |
| Valid reserved deploy | No | R16 checked restart; forward selection remains pending and unused |
| Reserved selection mismatches delivery, or recovery has delivery | Yes | Refuse installation; checked checkpoint restoration and nonzero |
| Missing local lifecycle record, unreadable or ambiguous archive identity, or unresolved competing state | Any | Refuse safely; never infer ordinary start |

Refusal installs nothing. A locally recorded ordinary stop permits checked
restoration of its working checkpoint even without a signed deployment reservation.
Unauthorized delivery always returns nonzero, including after successful service
restoration. A reserved attempt whose bytes or mode fail checks similarly attempts
its recorded checked last-working restoration and fails. Failed restoration keeps
the hold. Missing or ambiguous local lifecycle/checkpoint evidence refuses safely;
ordinary restart never bypasses failed/held or unresolved-attempt recovery gates.

Human clarification on 2026-10-03: after identifying a matching deploy mode,
start first repeats the bounded stop-only checks using the attempt's already
verified stable code. Under the root lock, recheck reservation and host/account/
prefix/unit identity, maintain the cooperative hold, stop any verified survivors
idempotently and confirm quiescence before proceeding. This does not repeat input
fetches, create a new reservation, recapture the pre-delivery archive identity,
change the last-working checkpoint or consume the selection. It runs no code
from the newly staged archive. Failure installs nothing, retains the failed held
attempt and returns nonzero. Plain start, recovery and refusal do not perform
this additional deployment-only stop. New stop behavior becomes active only after
successful stable-version refresh, for the next operation.

Deploy copies the exact retained downloaded application archive into a private
attempt directory, verifies that copy against the snapshot, and ignores the
role's unpacked tree. Rehash the other four retained inputs at use. With the
existing root deployment lock still held, recheck the reservation and invoke the verified
entry synchronously using only validated input paths and record values.
Preserve its nonzero result after its own failed-upgrade recovery.

Start the daemon first while held. Require both local APIs to confirm health,
exact revision and environment, disk/launch agreement, no stale or drifted
state, and running service components. Record daemon account, PID, boot identity
and start ticks. Release the hold only after these checks; then require the unit
to observe that same daemon. A post-release failure re-holds and fails.
Only final success advances the last working release. Selection replay protection
records attempted/consumed identities independently of success; every failed forward
attempt or recovery needs a fresh signed selection to retry. R16's completed
restart leaves the forward selection unused and closes its own reservation.

Plain start applies these runtime and supervision checks to the current recorded
release. Recovery acquires the same root lock, uses the explicitly retained
predecessor's own entry with the existing offline rollback switch, then checks
that predecessor's identity through the plain-start gates. Both reconstruction
and historical shipped-environment predecessors remain reachable without network.
Failure before the installer or its pending record exists uses the attempt's
last-working checkpoint, not a guessed older predecessor. Recovery never changes
the original failed deployment result. Every mode keeps logs and receipts outside
staging.

### Former delivery-task responsibility coverage

All sixteen responsibilities require explicit consumer owners and fatal outcomes:
managed target/action/schema/revision identity; five exact asset kinds and allowed
URLs/digests; staging ownership and safe paths; controller and target byte
verification; strict ten-key record cross-check; expected versions/profile/selection
and validated installer inputs; private attempt staging; loaded service user and
command identity; cooperative-hold capability; held fully stopped installation;
installer status and bounded diagnostics; first-start status; application health,
environment and exact launch/disk revision; companion-service health and running
components; hold release and same-daemon observation; and scoped controller
cleanup preserving target recovery evidence.

### Verification and rollout boundaries under the fixed contract

**Verification claim: no unchecked byte is installed or run, and any mismatch
fails the deployment.** The fixed role downloads with certificate checks disabled
and unpacks before start, but executes nothing from that archive. Our scripts
never execute its unpacked tree or staging executables. They install only from
the privately copied, independently hashed downloaded archive and verified retained
inputs. Mismatch restarts the last working release and returns nonzero.
Retained recovery inputs, selection, reservation and journals live outside the
role's rotating staging tree. This does not claim that unchecked bytes never
reach the server.

A new candidate repeats the complete two-phase build and affected exact-byte
qualification. Reuse older evidence only for demonstrably unchanged components.
Step 8 tests one same-release qualification deployment through restored original
orchestration. Current temporary delivery installs release N's verified stable
closure/key and supplies probes and retention/activation receipts. Normal path-only
restoration preserves concurrent history and loaded-source/payload agreement.
Controller byte verification and original check traversal report separate verdicts.
After a fresh signed selection, our pipeline launches the real original action;
independent external checks bind both endpoints, revision, environment, account,
absent hold and unit observation of the script-started daemon.

Bootstrap, restoration and every operational phase require separate execution
authorization. Shared logs, pipeline console and endpoints carry evidence with no
Step 8 maintenance/operator route. Recovery uses fresh signed authority plus
pipeline job-terminal and target lock/process proof; all inputs remain offline.
After successful G but failed external H, an unsigned ordinary checked restart
of the same release preserves the external failure and performs no rollback.
Unknown job/process state blocks recovery. Reboot remains untested/nonblocking;
healthy APIs do not prove lost local configuration reconciled. No real original-path
success is claimed by this specification.

Human decisions at round 8 on 2026-10-04 select shared-drive signed selection
for every forward attempt, retry and recovery. The human signs on their corporate
workstation with their own key and writes to a fixed per-environment filesystem
folder on the existing shared drive. Stop reads and snapshots it before lifecycle
mutation, verifying the signature with the public key in its pinned verified
stable closure. The key and host-utility verifier ship in release N, qualified
in Step 8 B and installed in C; neither requires application Python. Each selection
binds operation, exact five canonical URLs and SHA-256 values, environment/account,
profile, unique attempt identity and short expiry chosen when signed. Recovery
also binds the failed attempt and exact checkpoint. Consumed identities remain
outside staging. Missing or invalid selection grants no deployment or recovery
authority. Under confirmed R19, stop records the condition and admits ordinary
stop only when lifecycle safety permits; it retains local exclusion, archive
identity and checkpoint without signed reservation or a later share reread.
Unchanged delivery takes unsigned checked restart; unauthorized delivery installs
nothing, restores the checked working release and fails. Failed/held or unresolved
states cannot bypass recovery. Check mode reads no target selection and never
arms or consumes one.

No arming object is published to the artifact repository. The fixed filesystem
location does not resolve artifacts; all five input URLs remain immutable and
latest fallback remains forbidden. Part C installs closure/key, probes and
retention/activation receipts only, with no forward or recovery arming. Each
later attempt receives a newly signed selection, including recovery retries.
No bootstrap count, non-expiring authority or conditional recovery authorization
survives this decision. The human selected the offline backup key on 2026-10-05:
release N trusts primary and independently held backup public keys. Evidence and
qualify one host verifier; never infer a key format or fetch trust on first use.

R16 option A is selected: a stop/start-only launch with a valid pending forward
selection restarts the last working release using its own reservation, full held
runtime and supervision checks. Unchanged delivered-file identity at start
distinguishes that launch because the original forward role never calls start
after failed delivery. Leave the forward selection pending and unused, release
only the restart reservation, receipt its result and return the checks' status.
This applies to outside launches too; our pipeline does not control all launches.
Unreadable identity refuses. A failed restart retains its evidenced held state
and diagnostics without converting the forward selection into recovery authority.
Ordinary unsigned restart and this R16 path omit deployment-only stop recheck.

### Confirmed restart admission and backup trust on 2026-10-05

The human confirms R19: ordinary restart requires no signature. The fixed stop
argv is identical for forward deployment and ordinary restart. Missing, unreadable
or unavailable shared selection, or expired, consumed, wrong-target, bad-signature,
partial or malformed input, is receipted and admits ordinary stop only, subject
to the normal lifecycle safety gates. Record local exclusion, delivered-file
identity and the working checkpoint without reserving signed deployment authority.
Do not reread the share during that ordinary run.

With no delivery, start checks and restarts the working release and returns the
checks' status. With delivery but no valid signed reservation, start installs
nothing, restores the working checkpoint with the full checks and returns nonzero.
The human accepts that an unsigned forward launch can cause downtime before
start refuses installation. This supersedes the literal pre-lifecycle refusal
rule for invalid selection. Failed, held or unresolved-attempt states still
require their checkpoint-bound recovery and cannot be bypassed by ordinary restart.
A valid pending forward selection with unchanged delivery takes R16, releases
only its reservation and leaves forward authority unused; expiry is checked on
later admission. A valid recovery remains typed recovery even with no installer
call. Failed external H after successful G uses unsigned checked restart of the
same working release, with no rollback and the earlier failure preserved.

The human selects Q38 option A: release N's verified stable closure trusts the
primary public key and a second offline backup public key. Backup private-key
custody must be independent of the primary key's loss condition. Before Part B,
document backup recovery, verified closure rotation/revocation and continued
attempt-ID, expiry and checkpoint enforcement. Backup signing issues fresh
authorized attempts; it provides no unsigned bypass and does not automatically
revoke a compromised primary key. Revocation requires a verified closure update.
Qualify primary unavailable, backup unavailable, unauthorized key and interrupted
rotation fixtures. Q37 still requires public-format and host-utility evidence
before qualifying one verifier. This decision creates, exports or installs no key.

## Required first-time and production delivery after qualification

Human decision of 2026-10-04: first-time installation and production deployment
belong to mandatory Step 9, after Step 8 proves AC16 and AC17 in the qualification
environment. Neither environment can use the temporary delivery task. Conform
to the original commands, ordering and behavior exactly as they exist. Request
no variable, role, template, job or operations change for Step 9.

Before the original role's first stop in a new environment, the one-time
scripts-only bootstrap installs the dispatcher and complete stable closure from
the exact registered published archive. Independently verify its whole digest
before safe allowlisted extraction and member verification, then first-activate
under the root lock with dispatcher last. No existing stable/foreign/damaged state
may be relabeled as first activation. Existing versions retain normal
verified-success activation. Prepare verified historical retention where needed;
dedicated non-dispatch inspection receipts prove completion. Interrupted bootstrap
refuses premature lifecycle use until its receipt-bound preparation is complete.
Arming is a separate fresh shared-drive signature after bootstrap, never part of
the session. Later successful deployments refresh stable scripts without repeating
first activation.

Route (b) is selected for production and any new environment: an operations-team
operator runs our exact self-verifying commands as the application account once
for bootstrap. Route (a) is unavailable in production. This is an operator action,
not an access, privilege, unit, role, template or job change. Record the named
operator, existing account/host access and separately authorized session. Later
arming uses the human's workstation and shared drive, with no recurring operator
or pipeline shell access. Development rehearsals use our existing development
account and need no operations operator; Step 8 uses current delivery and original
pipeline actions and has no operator prerequisite or fallback.

Empty-prefix hooks option (i) is selected. On an independently evidenced empty,
inactive prefix, verified bootstrap installs hold-aware hooks with deployment
hold set before any unit execution. No application or tools installation occurs.
On an installed or running release, bootstrap leaves runtime, staging and unit
start/pre-start hooks untouched; historical bridging belongs only to the first
approved stop under hold. Unit configuration remains unchanged in all cases.

For first-time delivery, prove that no application is installed or running and
record explicitly that there is no last working release or recovery target. Stop
must succeed with nothing to stop after the normal input and identity gates.
Deploy start must recognize the selected delivery on an empty prefix and use the
installer's first-install path. A refusal installs nothing and cannot attempt a
fictional restart. A failed installation leaves a failed, held, non-ready state
with evidence and verified inputs retained; no rollback success may be claimed.
An explicitly authorized fresh retry must remain possible after terminal-process
proof and safe reconciliation. An absent or ambiguous predecessor never silently
selects first-install behavior.

The application account, scripts and staging folders, and service unit with the
required identity must already be provisioned. They are evidence gates, never
requests for operations changes. The same applies separately in production to
the managed job and template that run the restored production playbook, target
artifact-repository access and existing access to the production application
account for the one-time route (b) bootstrap. Unit identity must be observed for
qualification and production; only the development replay permits no unit.

Production starts from its actual historical shipped-environment release.
Inspect its retained archives and completion markers read-only before upgrading.
If they are absent or unsuitable, establish and verify complete retention of
that exact historical release before proceeding, without inventing successful
installation markers or substituting the pair used in an earlier isolated test.
Refusal and recovery health checks must match the historical runtime interfaces
and independently prove the selected predecessor's identity. Missing modern
fields must not silently downgrade a modern candidate's checks.

Production deploys only published, qualified release coordinates. The original
approval step can wait up to two hours for the operations pilot before our stop;
the consumer pipeline budget and selection freshness must include that wait.
Approval expiry or absent approval must not begin the stop. All earlier input,
serialization, hold, verification and offline-recovery guarantees continue.

The selected rehearsal venue is our development installation under our own
development account on the qualification host. Both empty-prefix and historical
upgrade/offline-rollback rehearsals use a replay script, never the orchestration
tool. Each replay operation identifies its original role task and audited baseline:
exact stop/start argv through the prefix dispatcher, literal download filename,
unpack, per-directory rename rotation, staging copy and permission changes. Exercise
literal and expanded HOME forms, and use direct argv without an intermediate shell
where the role uses none. Confine paths and lifecycle activity to the development
installation; preserve its prior state and authorize preparation/restoration.

This installation has no service unit. Its explicit development-only no-unit
profile is refused for qualification and production, never selected because a
unit query fails. Replay does not prove managed orchestration, hold parking or
same-daemon supervision. Step 8 G proves running-release unit behavior on the real
qualification managed path. Unit-related first-install hooks and historical hook
bridging first execute for real in production, supported beforehand by fixtures
and read-only production unit evidence obtained through route (b). AC18/AC19 accept
the development replays together with Step 8's managed run with these limits.
Use retained exact historical archives on that host, independently verify their
pairing against production evidence, and never relabel an earlier isolated tools
pair as production's pair.

## Acceptance criteria for deployment-created environments

| ID | Required result and evidence |
| --- | --- |
| AC01 | Archive inspection covers current/stale, alternate-name, and nested Python venvs identified by `pyvenv.cfg` throughout packaging inputs; all are excluded and release metadata/reconstruction inputs remain present. |
| AC02 | From complete locally supplied release archives and inputs, installation on both supported platforms provisions the supplied uv, creates the named venv, performs locked sync and passes readiness without a pre-existing application venv, target application Git checkout or developer-environment assumptions. Consumer acquisition precedes this check. |
| AC03 | Host Python earlier on PATH does not override toolchain Python. Missing/incompatible toolchain Python and a foreign-base existing venv fail clearly. Base executable, prefix, and full version are verified. |
| AC04 | Valid existing venvs sync successfully; repeated sync succeeds; mirroring-induced removal causes recreation. Multiple version directories do not affect exact selection, and a toolchain-Python version change uses the correctly named environment. |
| AC05 | Both targets use the same canonical release lock, qualified uv, explicit groups, and valid marker selections. A stale lock or failed sync prevents readiness and subsequent packaging/publication. A failed in-place sync reports the failure and permits recovery by redeployment or rollback; the old venv need not remain usable throughout. |
| AC06 | After the consumer has supplied the required release files locally, cplx must reconstruct the Python environment and pass readiness checks without downloading anything, cloning a repository, or relying on previously cached packages. Missing or invalid inputs must cause a clear failure before deployment changes begin. Source mapping preserves canonical dependency/artifact identities and hashes. |
| AC07 | Inventory rejects missing/mismatched/extra distributions against target-selected lock identities and hashes; installed wheel ELFs equal original retained wheel binaries. Deliberate ELF modification blocks readiness. No wheel ELF rewriting or loss of required `$ORIGIN` paths occurs; complete non-ELF file-byte coverage is not claimed. |
| AC08 | Runtime checks and heavy-wheel imports pass on both platforms. Debian has conclusive live trace evidence and no host fallback for ABI-critical libraries. RHEL providers follow item 7's validation matrix and operator readiness succeeds. |
| AC09 | Debian application acceptance runs on the exact identified RHEL-built toolchain archive; platform, interpreter, lock, and artifact provenance accompany the results. |
| AC10a | Phase 2 environment equivalence and evidence: our scripts create phase 2's local named venv with toolchain Python from phase 1's toolchain archive digest, canonical lock and groups; no copied phase 1 venv or library-created replacement is accepted. Phase 1's effective dependency selection equals the selection the library's unqualified sync applies, so that sync neither adds nor removes distributions. Record and compare checkout revisions, archive/lock digests, groups, interpreter/base-prefix provenance and selected inventories with phase 1, including phase 2 inventory before/after library Python commands and the local venv path. Any phase 2 uv version is allowed if inventory stays unchanged and dependency commands succeed. |
| AC10b | Build sequencing and failure propagation: one Jenkinsfile/job/build runs blocking validation and packaging before direct orchestration of the preserved mandated stages. Phase 1 failure prevents phase 2; either phase's failure fails the build. Revision mismatch, dependency drift, wrong interpreter, missing equivalence evidence, or a failed dependency/test command fails validation even when the library masks it. A branch update between checkouts requires a new build and is reported as a revision mismatch, not a product failure. Artifacts/evidence remain attributable to their phase and phase 1 archives stay unchanged. Unresolved compatibility blocks completion. |
| AC11 | Actual Debian CI evidence shows no Maven deployment invocation or release-artifact upload from either phase, while required checks, quality gates, and independent packaging execute. |
| AC12 | RHEL rollback restores the preceding release to readiness with every Python library referential, mirror, and remote artifact service unreachable, using target-local or archive-delivered retained inputs. A venv-free predecessor is reconstructed from its lock. For the first transition, redeploy the predecessor's shipped venv by its own procedure. Compilation or current service availability alone is insufficient evidence. |
| AC13 | Public effort artifacts and review content contain no private application/library identifiers, infrastructure paths, endpoints, credentials, or job links. |
| AC14 | Deployment/CI venv sync and recovery install compatible prebuilt dependency wheels without source builds. An unavailable compatible wheel fails clearly and blocks readiness. The application project itself is not built or installed during dependency sync. Independent application packaging and RHEL toolchain compilation are distinct. |
| AC15 | A same-Python-version toolchain replacement permits venv reuse only with current interpreter/prefix, lock and runtime validation plus fresh archive-digest evidence. Consuming automation/operator procedures enforce serialization for overlapping sync, mirroring, deployment, and rollback on the same application root. |
| AC16 | One actual same-release qualification deployment uses the original role archive and independently signed selection with five exact hashes/URLs, four locally rehashed inputs and zero stop fetches. B qualifies primary/backup public keys and the verifier; C installs them without arming. R19 ordinary admission and unauthorized-delivery refusal retain all safety gates. Fresh signed selections govern every G attempt/retry; R16 checked restart preserves unused forward intent. Fatal stable gates, deployment-only stop recheck, runtime/same-daemon proof, baseline equality and concurrent history all pass. Shared logs/console and both external endpoints bind revision/environment/account. Controller-byte and check-traversal verdicts stay separate. |
| AC17 | Each recovery has fresh signed authority bound to the failed attempt/checkpoint, including retries and role transfer failure before start. Pipeline job-terminal and stop local lock/process proof admit typed offline recovery of both predecessor formats with held runtime/supervision checks. G failure returns to its same-release checkpoint. No operator or Ansible change is required; failure stays failed and missing recovery authority cannot bypass failed/held-state gates. R19 admits ordinary restart only from a safe state, and unauthorized delivery never installs. |
| AC18 | After AC16/AC17 closure, separately authorized empty-prefix replay in our development installation on the qualification host proves verified scripts-only bootstrap, guarded activation, exact original task/argv/staging replay, first install, no-predecessor failure and fresh signed retry. Accept replay plus Step 8's managed run with explicit limits: development has no unit and proves no hold/parking/supervision or managed orchestration; its no-unit profile is rejected in qualification/production. Option (i) hooks first execute with a real unit in production, backed by fixtures and route (b) unit evidence. New environments use route (b) once for bootstrap, never recurring operator arming. |
| AC19 | After AC16/AC17 and AC18, the separately authorized development replay proves historical upgrade/offline rollback from retained exact archives whose pairing is verified against production evidence. Accept replay plus Step 8's managed running-release unit proof, explicitly excluding production historical bridging and first-install unit proof from replay. Fixtures and read-only route (b) production unit evidence back those first real production executions. Actual authorized production uses route (b) bootstrap once, fresh shared-drive signed selections, qualified release coordinates, existing managed job/template and unchanged pilot approval. Approval-aware expiry/budgets, all runtime/same-daemon checks and both external endpoints must pass; the topic remains pending until this actual evidence closes. |

## Requirement clarifications

The human confirmed consolidation after round 4, including option A for Q02,
Q05, and Q09. The later human-approved plan-review amendment narrows requirement
Q09 to the explicit consumer-delivery/cplx-reconstruction boundary above, preserving
the original decision as history. All ten questions are settled; private integration
mechanisms remain outside this public requirement. Plan Q09 records this boundary;
design Q09 remains the separate, unchanged operator-publication decision.

| Question | Decision and reason | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | A: prove preceding-release recovery with all remote services unreachable; a service outage must not prevent recovery. | Required recovery from the preceding release; AC12 | Testing only the usual mirror outage or relying on remote retained inputs. |
| Q02 | A: require clear sync failure and recoverability, without uninterrupted availability; in-place sync can leave the venv unusable. | Required packaging and Python venv lifecycle; AC05 | Requiring every failed sync to preserve the previous venv unchanged and usable. |
| Q03 | A: reject extra distributions and compare installed wheel ELFs with original retained wheels; path adjustments to scripts or links do not justify changing wheel binaries. | Required wheel integrity and runtime readiness; AC07 | Blanket venv relocation, wheel ELF rewriting, or claiming complete non-ELF byte coverage. |
| Q04 | A: permit same-version venv reuse only after current interpreter, prefix, lock, runtime, and archive-digest validation; a version string alone is insufficient. | Required packaging and Python venv lifecycle; AC15 | Unconditional reuse on equal Python versions or mandatory recreation for every archive change. |
| Q05 | A: recover the first transition using the predecessor's shipped venv and its own procedure; subsequent venv-free predecessors use lock reconstruction. This supports historical releases without inventing missing inputs. | Required recovery from the preceding release; AC12 | Requiring historical lock reconstruction before the first venv-free release. |
| Q06 | A: reconstruct phase 2's named venv with our scripts from the same toolchain archive, lock, and effective dependency selection; compare provenance, revisions, and before/after inventories. Fresh agents require equivalence evidence. | Required single-build CI sequence without publication; AC10a and AC10b | Copied phase 1 files, same-storage demands, library-created replacement venvs, or an exact phase 2 uv-version demand despite proven unchanged dependencies. |
| Q07 | A: exclude every Python venv under packaging inputs using its pyvenv.cfg boundary; current, stale, alternate-name, and nested venvs all count. | Required packaging and Python venv lifecycle; AC01 | Excluding only the selected or conventionally named venv. |
| Q08 | A: consuming automation or operators enforce serialization per application root; this covers competing sync, mirroring/deletion, and rollback/deployment. | Required packaging and Python venv lifecycle; AC15 | Supporting overlapping mutations to the same root in this feature. |
| Q09 | A originally required offline forward deployment. Human-approved amendment: cplx reconstruction starts with complete locally supplied files and remains offline with empty caches; the consumer owns earlier acquisition/delivery. Offline predecessor recovery retains its complete-input guarantee. | Consumer delivery and offline reconstruction boundary; AC02 and AC06 | Downloads or cache/Git dependencies during cplx reconstruction; fetching missing predecessor inputs during recovery. |
| Q10 | B: deliver uv with application release inputs, preserving the qualified toolchain archive. Qualify the latest stable version, then freeze its version and digest for deployment and recovery regardless of install location. | Required toolchain Python and uv provenance; AC05; AC10a | Repacking the toolchain only to deliver uv, floating latest at deployment, or silently substituting another release's uv. |
| Q11 | Human decision on 2026-10-03: use the consumer's original orchestration exactly as it exists; only restore the whole application path to its recorded baseline. Consumer code absorbs its command shapes, staging order, URL rewriting and unused deploy variable, performs all gates, and supplies explicit offline recovery. The follow-up clarification adds a deployment-only stable stop recheck without refetch or resnapshot. | Required delivery through the consumer's unchanged orchestration; AC16-AC17; design Q10; plan Q10 | Keeping the temporary delivery task; any orchestration-side edit or exception request, including changing script variables to another application's convention; native staging rollback as recovery; an in-package manifest as selection proof. |
| Q12 | Human decision on 2026-10-04: Step 8 is qualification-only; mandatory Step 9 adds first-time and production delivery after actual AC16/AC17 closure. Bootstrap through existing maintenance access, explicitly handle no predecessor, prove historical retention and compatible recovery, and satisfy production approval/release/access gates and separate rehearsals. | Required first-time and production delivery; AC18-AC19; design Q11; plan Step 9 | Declaring the topic complete at Step 8; using the removed temporary task elsewhere; any operations-side change request; assuming qualification identity or isolated historical evidence proves production readiness. |
| Q13 | Human round 6 direction retained except round 8 supersession on 2026-10-04: Step 8 is operator-free; C installs stable closure/key and probes with no arming. Fresh signed selections authorize every G attempt/retry/recovery; pipeline and local terminal proof remain required. | AC16-AC17; design Q12; Step 8 A-I | Bootstrap-recorded non-expiring authority, retry count, operator arming/terminalization and inferred evidence. |
| Q14 | Human round 8 decision on 2026-10-04: signed selections on the existing shared drive, human key on corporate workstation, stable public key/verifier in release N. Short expiry per attempt, durable replay refusal, recovery checkpoint binding. | AC16-AC19; design Q13; plan Q37-Q41 | Artifact-repository arming objects, floating artifact resolution, unsigned deployment/recovery or first-use trust; offline backup trust is confirmed below. |
| Q15 | Human round 8 decisions on 2026-10-04: R16 option A preserves pending forward selection during checked stop/start; decision 2 requires fresh signed authority for every attempt and recovery. | Stop/start mode table; AC16-AC17 | Consuming forward intent on an identified restart or carrying recovery authority across retries. |
| Q16 | Human round 8 decisions on 2026-10-04: development replay venue and no-unit limits, option (i) empty-prefix hooks, route (b) once for production/new-environment bootstrap, and Step 8 A host evidence plus filesystem/remote-overhead budget. | AC18-AC19; Step 8 A; Step 9 | Managed-unit claims from development replay, blanket no-hook-write rule on empty prefixes, recurring operator arming. |
| Q17 | Human R19 decision on 2026-10-05: ordinary restart needs no signature; invalid selection admits ordinary stop subject to safety, and unauthorized delivery restores/checks the working release and fails without installation. The human accepts possible downtime before refusal. | Stop/start flows; confirmed admission; AC16-AC17 | Signed ordinary restart or promising pre-lifecycle refusal with indistinguishable stop argv. |
| Q18 | Human Q38 decision on 2026-10-05: release N trusts primary and independently held offline backup public keys. Document custody/recovery and verified rotation/revocation before B, preserving fresh identity/expiry/checkpoint checks. | Confirmed backup trust; AC16-AC19; design Q17; plan Q38 | Relying on unevidenced trust rebootstrap in every environment or unsigned key-loss recovery. |

All requirement questions and the R19/Q38 human choices are consolidated. Trust
implementation and real execution evidence remain required before their gates.

## File-based IO cost clarification for deployment-created environments

Read the explicitly selected release manifest/index and referenced metadata
directly; do not discover state through documentation/history or unrelated
directory scans. Reuse parsed identity maps within a phase and walk only declared
archive/inventory roots. Retain required streaming hashes, integrity-boundary
checks and complete offline inputs. This batch workflow has no new latency SLO;
record phase timings without weakening byte-identity or readiness checks.

## Scope and source references for topic 8

- [Canonical child draft](draft.v0.27.0.deploy-venv-sync.md): confirmed behavior,
  examples, and privacy boundary for this requirement.
- [Umbrella topic 8 and D11](draft.v0.27.0.debian-agent-tools.md): archive exclusion,
  lock identity, inventory reuse, runtime preservation, naming, and rollback.
- [Item 7 requirement](feature-request.v0.27.0.tools-archive-rebuild.md): accepted
  toolchain archive, wheel inventory/ELF comparison, and runtime qualification inputs.

Application-specific code references remain in private integration instructions.
Earlier toolchain publication, unrelated CI workaround cleanup, and coverage
restoration remain separately tracked; preservation of current checks is required
here. Python 3.14 is outside this cycle. No runtime implementation or content
filter configuration is changed by writing this requirement.
