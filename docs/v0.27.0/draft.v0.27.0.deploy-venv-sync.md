# Create the venv at deployment instead of shipping it

- Type: feature-request
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Target version: v0.27.0
- Slug: deploy-venv-sync

## Selected umbrella item

| Order | Type | Key title | Slug | Status | Requirement | Validation plan |
| --- | --- | --- | --- | --- | --- | --- |
| 8 | Feature-request | Create the venv at deployment instead of shipping it | `deploy-venv-sync` | pending | - | - |

This item regroups D11 and deployment changes, following completed item 7,
`tools-archive-rebuild`. Preserve its toolchain archive and acceptance/adoption evidence.

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

## Generic application contract

Use generic application, archive, project, and deployment terms in public
cplx documents, code, examples, and diagnostics. Application names, archive
classifiers, installation directories, private Python library referential mirror endpoints, and credentials
belong to consuming-project configuration. Placeholders do not rename existing
application directories.

The archive currently includes a copied venv; one measured environment occupied
529 MB. Deployment checks its Python executable, ELF interpreter, standard
library, `ssl`/`zlib` imports, and paths in `pyvenv.cfg`. Replace checks specific
to relocation while retaining runtime health checks and adding lock verification.

Exclude every Python venv within the application packaging input tree. Identify
its root by `pyvenv.cfg` and exclude the entire subtree, including current/stale
versions, alternate names, and nested venvs; do not scan unrelated host paths.
Debian 12 CI and RHEL 9.8 deployment both provision uv, create an absent Python
venv, and sync from the application's
release lock. CI tests before packaging but does not ship its venv.

## Cross-platform artifact and execution contract

Compile the toolchain on RHEL and deploy the exact resulting archive on
Debian for application acceptance tests. Record its digest and toolchain component versions;
do not substitute a Debian rebuild. Reuse the existing qualified archive when
this implementation does not change its contents, retaining item 7's evidence.

Create application environments independently on each target using the shipped
Python and the naming contract below. Do not transfer a RHEL build environment
or a Debian test venv between hosts. RHEL validation must exercise archive
installation, environment reconstruction, application readiness, and rollback;
successful compilation alone does not establish deployment correctness.

For each platform, retain OS and architecture, toolchain archive digest, Python and
uv versions, resolved base interpreter, venv path, canonical release-lock digest,
selected dependency groups, and execution results. Keep private host identities,
paths, job links, and configuration in private evidence; use generic paths or
placeholders in public reports. Local/static checks cannot replace execution on
the actual RHEL and Debian targets.

## Toolchain-installed Python and uv

Both paths must use `<tools-prefix>/python/current/bin/python3`, normally
`~/tools/python/current/bin/python3`. Resolve it to an absolute path. Do not
select Python through bare command names, PATH ordering, an activated foreign
venv, or a version request alone.

Use this interpreter to create the venv and explicitly select it for uv sync.
Disable automatic Python downloads. Verify the environment's base interpreter,
base prefix, and version against the toolchain installation; version equality alone
is insufficient. Missing/incompatible toolchain Python or an existing venv backed
by another interpreter must fail clearly, without falling back to distribution
Python or a uv-managed copy.

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

## Python venv lifecycle

Preserve the application's existing location and naming contract, expressed
here as `<application-root>/venvs/python_<version>_<project>`. Reuse the
application's current naming logic, including its existing normalization and
project suffix. The version must be the full version of the selected toolchain
Python actually used to create and run the environment, including the patch
component. Preserve dots in the version and the existing conversion of dashes
to underscores: Python 3.13.15 for a generic project named `example` gives
`venvs/python_3.13.15_example`.

Derive this exact path before checking whether the venv exists. Use the same
path for creation, `UV_PROJECT_ENVIRONMENT`, synchronization, and readiness
checks on both CI and deployment. Do not select the newest directory, reuse
another Python version's venv, or create an implicit `.venv`. When the selected
toolchain Python version changes, derive its corresponding name and create that
environment if absent; do not rename an older environment to make it match.
An explicit, verified alias to that canonical venv is not an implicit `.venv`;
it must not create a separate environment.

Create an absent venv; keep and sync an existing one that passes interpreter
validation. Archive mirroring with deletion semantics removes an unshipped venv
inside the application tree, so deployment recreates and syncs it afterwards.

Validate fresh installation, repeated sync, recreation after archive mirroring,
and a toolchain-Python version change on both platforms. A stale lock or failed sync
must fail the operation, prevent readiness, and block subsequent packaging or
publication. A partially prepared environment must not be reported as usable.

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

## Release lock and configurable sources

The application supplies `pyproject.toml` and `uv.lock`; this effort does not
introduce an application-specific lock into cplx. D11 requires the same release
lock, rather than a copy of CI's environment. Deployment must not silently
update dependency resolution.

Require `uv sync --locked` on both platforms. Preserve the canonical release
lock while allowing platform-specific dependency selections already expressed
by its markers. Record CI test groups and deployment groups explicitly; the
same lock does not require identical installed packages on different platforms.

Public examples use PyPI (`https://pypi.org/simple`) or neutral placeholders.
Private deployments use consuming-project Python library referential and authentication configuration,
including for uv provisioning. They must not require public Python library referential access or
put private endpoints in public cplx files.

A lock can record registry identities and individual artifact URLs. Changing a
Python library referential setting alone does not prove that locked downloads use the corporate
mirror. Validate effective sources and hashes using the qualified uv version
with an empty cache and public Python library referential access unavailable.

A consuming-project clean/smudge filter may preserve public URLs in Git and
materialise private URLs locally. It is an option to validate, not an installed
or selected mechanism. It must cover registry and artifact URLs, preserve
versions, graph, markers, and hashes, and prove a stable round trip. Simple
hostname substitution is not assumed to match the mirror's artifact layout.

Archive deployment must work without Git filters running on the target.
Materialise the effective lock and matching configuration before sync and retain
its verifiable relationship to the canonical release lock. Prove locked sync;
do not bypass consistency checks to accept an invalid rewritten lock. The exact
mapping mechanism remains for design.

Forward deployment requires digest-pinned release-delivered inputs sufficient
for bootstrap and locked sync with empty caches and all remote package and
artifact services unreachable. The chosen source mechanism must also support
previous-release recovery.

A failed in-place sync may leave the Python venv unusable. Report failure
clearly and provide recovery through redeployment or rollback; uninterrupted
availability and preservation of the previous venv on every failure are not
required.

Install Python library dependencies from compatible, prebuilt wheels on both
targets. Never fall back to building a dependency from source during venv
creation, synchronization, or recovery. A missing compatible wheel fails clearly
and blocks readiness. `--locked` establishes lock consistency but does not by
itself prohibit source builds; enforce and validate the no-build requirement
separately. The application project itself is not built or installed during
this dependency sync, for example by declaring it a non-packaged project;
only its dependencies are installed. Independent application packaging and
separate RHEL toolchain compilation remain distinct operations.

## Wheel integrity, runtime, and recovery

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

Keep venv trees identified by `pyvenv.cfg` excluded from ELF relocation.
Preserve wheel bytes and `$ORIGIN` paths. Carry forward the shared, versioned
runtime setup with shipped library directories first in `LD_LIBRARY_PATH`,
without relying on an account-private runtime file. A wheel's RUNPATH means
interpreter RPATH alone does not establish correct provider selection.

Import the heavy-wheel consumers on both distributions without patching wheels,
and qualify actual providers. Debian acceptance includes the ABI listing and
a conclusive live trace of venv Python, with no missing version nodes or host
fallback for ABI-critical libraries; an empty trace is inconclusive. RHEL
acceptance includes end-to-end readiness and operator environment setup;
qualify RHEL providers according to item 7's validation matrix rather than
extending Debian's no-host-fallback and live-trace requirement to RHEL.

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

Forward deployment must also succeed with every Python library referential,
mirror, and remote artifact service unreachable, using digest-pinned inputs
delivered with the release. Prove this with empty caches. A reachable private
mirror is not a deployment prerequisite. Deliver qualified uv with application
release inputs, preserving the toolchain archive.

## Debian CI integration without publication

Use one consuming-application Jenkinsfile, one Jenkins job, and one build of
that job. Phase 1 is our blocking application validation and packaging.
Phase 2 is the unchanged mandated shared-library sequence of CI stages called
by the same Jenkinsfile in the same build after phase 1 succeeds. It is not
another job, a downstream build, or another Jenkinsfile; it may allocate
different agents and workspaces.

First run blocking application preparation, toolchain provisioning and relocation, Python venv
synchronization, runtime and ABI/provider verification, acceptance tests,
coverage checks, and independent packaging. Retain diagnostic evidence. Only
after success, release the preliminary agent allocation and invoke the unchanged
mandated shared-library sequence of CI stages, preserving its conformity checks and quality gates.
Do not modify the shared library or split the flow into a second job.

Failures in phase 1 must fail the build and prevent phase 2's shared-library
stages from starting. Failures in phase 2 must leave the overall build
failed. Keep agent, workspace, and working-directory handling explicit; prior
activation, files, and venv paths do not automatically carry into another agent.

The blocking application phase uses the same toolchain-Python selection, full-version
venv naming, locked-sync, and configured-source guarantees as deployment. Install
its test dependencies through the declared dependency contract; do not follow
its locked sync with an independent unpinned dependency installation.

Treat the second CI phase's workspace, dependency operations, and coverage reports
as separate from the preliminary validation. They must not alter the previously
validated package or substitute for the blocking checks. Retain the provenance
of both phases' evidence. Compatibility measures must neither conceal failures
nor weaken dependency validation. Unresolved incompatibilities leave combined
validation incomplete; they do not authorize changes to the mandated library.

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

Keep packaging independent of publication and preserve the application's build
metadata. A validation build must execute all preparation, verification, test,
quality, and packaging steps while suppressing Maven deployment commands and
release-artifact uploads. A dry-run setting is acceptable only when its effective
behavior satisfies this contract; prove which commands and stages actually ran.

The coordinated integration and a real Debian CI run are part of this topic's
completion evidence. Keep repository identities, library entry points, job links,
and corporate configuration in private integration records. Public specifications,
plans, and validation reports retain the generic contract and truthful results
or remaining gaps. Local/static checks do not substitute for the CI run.

## Original orchestration decision on 2026-10-03

Delivery must use the consumer's original deployment orchestration unchanged.
Its command shapes, variable inconsistencies, URL rewriting, stop-before-download
order, staging operations and probes are fixed inputs. Restore the entire
application path in the operations repository to its recorded pre-change baseline,
preserving other projects and their concurrent commits. That path-only restoration
is the sole operations change; roles, template, job configuration, shared library,
credentials, network and privileges admit no change or exception request.

The role delivers the selected candidate's existing application archive only.
Our stop target obtains the four other pinned inputs before stopping anything;
a fetch or digest failure leaves the application running. Retain the tools
archive even when tools of the same version are installed. Start downloads nothing
and invokes the verified installer itself because the declared deploy entry is
unused by this role. No new transport artifact or publication field is added.

A strict executable prefix dispatcher accepts only the fixed stop/start argument
forms, both literal and expanded home forms. Home validates the argument only:
there are no home-directory entrypoints and no general-shell substitute. Stable,
versioned targets installed by a previous verified deployment remain outside all
replaced trees. The new candidate bootstraps these through the current temporary
delivery path before restoration; the consumer pipeline changes payload only
after the restored orchestration source is loaded.

The stop flow verifies host/account/prefix/unit, snapshots independently armed
deploy/recovery intent under coordination, verifies the four inputs (Step 8
rehashes bootstrap retention with no fetch; Step 9 acquisition is separately scoped),
records delivered-file identity and last-working release, engages and parks the
cooperative hold, then stops stack and daemon. Early failures leave service
untouched; hold-entry failure releases it. The start flow combines that snapshot
and actual file replacement: matching deploy plus delivery installs, no intent
plus no delivery plain-starts, recovery plus no delivery recovers; all other or
ambiguous combinations refuse. Refusal restores the last working service if
possible but still fails the attempted deployment. Identical-byte redelivery
counts as a delivery.

Human clarification on 2026-10-03: a matching deployment first repeats the
idempotent stop-only checks through the attempt's verified stable scripts,
under the root lock and existing hold. It fetches nothing and preserves the
selection, archive baseline and checkpoint. Failure prevents installation and
returns nonzero with the attempt held. Plain start and recovery omit this
additional stop; newly delivered stop improvements apply only after successful
stable-version refresh for the next operation.

All former delivery-task checks move to consumer scripts or the consumer pipeline.
Installation rechecks the attempt under the root lock; held daemon-first start
verifies both local APIs, exact revision/environment and disk/launch agreement
before releasing hold and checking same-daemon supervision. Failures propagate
nonzero and post-release failures re-hold. Explicit offline recovery preserves
both predecessor formats, including failure before installer entry, and keeps the
original failed deployment failed. Generic staging rollback is rejected.

**Verification claim: no unchecked byte is installed or run, and any mismatch
fails the deployment.** The fixed role downloads with certificate checks disabled
and unpacks before start, but executes nothing from that archive. Our scripts
never execute its unpacked tree or staging executables. They install only from
the privately copied, independently hashed downloaded archive and verified retained
inputs. Mismatch restarts the last working release and returns nonzero.
Retained recovery inputs, selection, reservation and journals live outside the
role's rotating staging tree. This does not claim that unchecked bytes never
reach the server.

Plan Step 8, distinct from umbrella item 8, owns this added integration.
Exact loaded source/environment, bootstrap-bound selection receipts, anonymous
target reads of all exact URLs, dispatcher state, inherited defaults and staging
time/disk cost are prerequisites. The application-tree staging loop runs while
held and must fit the existing job and downtime budgets. An unmet prerequisite
stops before restoration; it never authorizes an operations-side change.
Controller byte verification and the role's check traversal are separate dry-run
outcomes; check mode may create a work directory and proves no target execution.
Reboot remains untested and nonblocking; health does not establish restoration of
previously lost local configuration.

## First-time and production scope decision on 2026-10-04

Step 8 covers only the qualification environment that can bootstrap through the
temporary delivery task before source restoration. It proves AC16/AC17 there;
first-time installation and production deployment move to mandatory Step 9.
Step 9 starts only after those actual evidence gates close, and the topic and
umbrella item remain pending until AC18/AC19 are validated.

Human decisions at round 8 on 2026-10-04 keep Step 8 operator-free. Existing
delivery installs the stable closure, public key, verifier and probes/receipts,
with no arming. The human signs every attempt, retry and recovery with a fresh
ID and short expiry through a fixed shared-drive folder; recovery also binds the
failed attempt/checkpoint. Under confirmed R19, missing/invalid authority grants
ordinary stop only where safe; unauthorized delivery installs nothing and fails
after checked restoration. Failed/held recovery gates remain mandatory.
R16 A leaves forward selection pending on outside stop/start, restarts/checks the
working release, releases its own reservation and returns the checks' status.
Pipeline original actions plus local terminal checks recover without an operator.
Part A adds development-account host network/client/share evidence and same-disk
filesystem replay timing plus evidenced orchestration overhead; C application-
account probes remain final. Only normal restoration-PR review involves operations.

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

The original orchestration stays unchanged. Step 9 first activation is allowed
only with no stable version, verified published archive/closure and dispatcher
published last. Bootstrap inspects receipts without invoking stop/start; it
prepares historical retention where required and never arms. Later deployments
use successful-release activation. Empty-prefix failure never invents a
predecessor, restart or rollback; it preserves safe non-ready state and an
explicit freshly signed retry route. Plan Q37-Q41 now consolidate one evidenced
verifier, offline backup trust, the versioned replay helper and atomic ready
envelope. Exact tooling/layout and execution evidence remain qualification gates.

Production starts from its actual historical shipped-environment release.
Prove exact retained recovery inputs, per-environment unit identity, compatible
historical health checks, existing managed routing, repository reachability and
arming access. Missing provisioning is an evidence gate, never a change request.
Use qualified published release coordinates and budget the unchanged two-hour
operations approval before stop. Separately authorized first-time and historical
upgrade/offline-rollback rehearsals precede an independently authorized production
run, which also requires the operations pilot's approval. No execution is
authorized by this planning amendment.

## Acceptance and boundaries

- Apply the original orchestration decision of 2026-10-03 through plan Step 8;
  preserve AC01-AC15 and add forward delivery AC16 and explicit recovery AC17.
- Limit Step 8 to qualification; add mandatory Step 9 and AC18/AC19 for first-time
  and production delivery after actual AC16/AC17 closure, keeping the topic pending.
- In Step 9, bootstrap scripts only through the selected existing access route, distinguish absent
  predecessor from missing evidence, and prove actual historical retention and
  production-specific identity, access, approval and release gates.
- Verify all five pinned inputs, rehash Step 8's four retained inputs before stopping, keep stable
  dispatch/selection/recovery outside staging, and enforce the stop/start mode table.
- In deploy mode only, repeat stable stop-only checks before installation without
  replacing attempt evidence or executing newly staged scripts.
- Bootstrap before the path-only restoration; gate execution on returned receipts,
  exact loaded source, staging cost and separately authorized operational phases.
- No unchecked byte is installed or run, and any mismatch fails the deployment.
  Controller verification and original check traversal are separate dry-run results.

- Archives exclude all Python venv trees identified by `pyvenv.cfg` within
  packaging inputs; CI and deployment create/sync them using prebuilt dependency
  wheels only. Missing compatible wheels fail without compiling dependencies.
- Debian acceptance uses the exact RHEL-built toolchain archive, identified by its
  digest. Environments are created locally on each target; no venv is transferred.
- Host Python earlier on PATH cannot override toolchain Python. Missing toolchain
  Python and foreign-base venvs fail clearly.
- Valid existing venvs sync; redeployment recreates removed ones in place.
- Venv naming matches the application's existing convention and the actual
  toolchain Python's full version on both distributions. With multiple versioned
  venvs present, only the exact matching path is selected; a Python version
  change creates its correctly named venv when absent.
- Deployment excludes the application's `tooling` group and uses qualified uv
  installed under the toolchain prefix.
- Both platforms pass locked sync from the same canonical release lock, with
  explicit dependency groups and marker-based platform selections. Stale locks
  and sync failures block readiness and subsequent packaging/publication.
- Effective-source sync passes with an empty cache and public Python library
  referential access unavailable, including archive deployment without Git.
  Any source mapping preserves dependency and artifact identities. Forward
  deployment also passes with every referential, mirror, and remote artifact
  service unreachable, using digest-pinned release-delivered inputs.
- Public effort artifacts contain no private application names or endpoints.
- One Jenkinsfile/build executes blocking application checks and independent
  packaging before the unchanged mandated shared-library sequence of CI stages. A preliminary failure
  prevents phase 2 from starting; either phase's failure fails the build.
  Existing application build metadata and validated artifacts are preserved.
  Actual Debian CI evidence confirms that Maven deployment commands and
  release-artifact uploads were skipped in both phases.
- Inventory, retained runtime checks, unchanged wheel ELFs, and actual providers
  pass on both distributions.
- Actual RHEL archive installation, reconstruction, readiness, and rollback to
  the previous release succeed. Platform and artifact provenance accompany
  the execution evidence; compilation success alone is insufficient.

Earlier toolchain publication, unrelated CI workaround cleanup, and coverage restoration
remain separately tracked; preserving current checks in the CI integration is
required here. Python 3.14 is outside this cycle. This draft changes no
runtime implementation or content-filter configuration.

### Consolidated admission and trust direction on 2026-10-05

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
