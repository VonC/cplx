# Create the venv at deployment instead of shipping it

- Type: feature-request
- Version: v0.27.0
- Topic: deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Source draft: [Deployment venv draft](draft.v0.27.0.deploy-venv-sync.md)

## Revision introducing target-created environments

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
Phase 2 is the unchanged mandated shared-library sequence of CI stages called
by the same Jenkinsfile in the same build after phase 1 succeeds. It is not
another job, a downstream build, or another Jenkinsfile; it may allocate
different agents and workspaces.

First execute blocking toolchain provisioning/relocation, named-venv locked sync, runtime and
ABI/provider checks, application acceptance tests, coverage checks, and independent
packaging. Archive evidence and preserve the application's build metadata.

Only after successful preliminary validation, release its agent allocation and
invoke the unchanged mandated shared-library sequence of CI stages, preserving its conformity checks and
quality gates. Do not modify that shared library or create a second job. A
preliminary failure must fail the build and prevent the second CI phase from
starting; a later failure must leave the whole build failed.

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
| AC10b | Build sequencing and failure propagation: one Jenkinsfile/job/build runs blocking validation and packaging before unchanged mandated stages. Phase 1 failure prevents phase 2; either phase's failure fails the build. Revision mismatch, dependency drift, wrong interpreter, missing equivalence evidence, or a failed dependency/test command fails validation even when the library masks it. A branch update between checkouts requires a new build and is reported as a revision mismatch, not a product failure. Artifacts/evidence remain attributable to their phase and phase 1 archives stay unchanged. Unresolved compatibility blocks completion. |
| AC11 | Actual Debian CI evidence shows no Maven deployment invocation or release-artifact upload from either phase, while required checks, quality gates, and independent packaging execute. |
| AC12 | RHEL rollback restores the preceding release to readiness with every Python library referential, mirror, and remote artifact service unreachable, using target-local or archive-delivered retained inputs. A venv-free predecessor is reconstructed from its lock. For the first transition, redeploy the predecessor's shipped venv by its own procedure. Compilation or current service availability alone is insufficient evidence. |
| AC13 | Public effort artifacts and review content contain no private application/library identifiers, infrastructure paths, endpoints, credentials, or job links. |
| AC14 | Deployment/CI venv sync and recovery install compatible prebuilt dependency wheels without source builds. An unavailable compatible wheel fails clearly and blocks readiness. The application project itself is not built or installed during dependency sync. Independent application packaging and RHEL toolchain compilation are distinct. |
| AC15 | A same-Python-version toolchain replacement permits venv reuse only with current interpreter/prefix, lock and runtime validation plus fresh archive-digest evidence. Consuming automation/operator procedures enforce serialization for overlapping sync, mirroring, deployment, and rollback on the same application root. |

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
