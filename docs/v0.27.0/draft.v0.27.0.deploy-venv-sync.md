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

## Acceptance and boundaries

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
