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

Validate bootstrap and sync using an empty cache with public Python library referential access
unavailable. Shipping digest-pinned wheels and syncing offline remains an option
within D11. Source transport, uv provisioning, and recovery-input retention must
be specified before implementation; this requirement does not silently choose
between a reachable private mirror and retained offline inputs.

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
canonical lock without compiling dependencies. For the first transition, Q05
now proposes redeploying the predecessor archive, including its shipped venv,
using its own deployment procedure. Lock-based reconstruction would apply from
the second venv-free release onward. This first-transition proposal still awaits
human confirmation; the offline recovery guarantee itself is confirmed.

Offline rollback does not silently settle forward deployment: Q09 asks whether
a new release must also install with every referential/mirror/artifact service
unreachable or may require a reachable private mirror. Resolve Q09 before
implementation. Q10 confirms qualified uv delivery with application release
inputs, preserving the toolchain archive.

## Acceptance criteria for deployment-created environments

| ID | Required result and evidence |
| --- | --- |
| AC01 | Archive inspection covers current/stale, alternate-name, and nested Python venvs identified by `pyvenv.cfg` throughout packaging inputs; all are excluded and release metadata/reconstruction inputs remain present. |
| AC02 | Archive-only installation on both supported platforms, without a pre-existing application venv or target Git checkout, provisions uv, creates the named venv, performs locked sync, and passes readiness without developer-environment assumptions. |
| AC03 | Host Python earlier on PATH does not override toolchain Python. Missing/incompatible toolchain Python and a foreign-base existing venv fail clearly. Base executable, prefix, and full version are verified. |
| AC04 | Valid existing venvs sync successfully; repeated sync succeeds; mirroring-induced removal causes recreation. Multiple version directories do not affect exact selection, and a toolchain-Python version change uses the correctly named environment. |
| AC05 | Both targets use the same canonical release lock, qualified uv, explicit groups, and valid marker selections. A stale lock or failed sync prevents readiness and subsequent packaging/publication. |
| AC06 | Bootstrap and effective-source locked sync succeed with empty caches and public Python library referential access unavailable, including deployment without Git. Any source mapping preserves canonical dependency/artifact identities and hashes. |
| AC07 | Inventory rejects missing/mismatched/extra distributions against target-selected lock identities and hashes; installed wheel ELFs equal original retained wheel binaries. Deliberate ELF modification blocks readiness. No wheel ELF rewriting or loss of required `$ORIGIN` paths occurs; complete non-ELF file-byte coverage is not claimed. |
| AC08 | Runtime checks and heavy-wheel imports pass on both platforms. Debian has conclusive live trace evidence and no host fallback for ABI-critical libraries. RHEL providers follow item 7's validation matrix and operator readiness succeeds. |
| AC09 | Debian application acceptance runs on the exact identified RHEL-built toolchain archive; platform, interpreter, lock, and artifact provenance accompany the results. |
| AC10a | Phase 2 environment equivalence and evidence: our scripts create phase 2's local named venv with toolchain Python from phase 1's toolchain archive digest, canonical lock and groups; no copied phase 1 venv or library-created replacement is accepted. Phase 1's effective dependency selection equals the selection the library's unqualified sync applies, so that sync neither adds nor removes distributions. Record and compare checkout revisions, archive/lock digests, groups, interpreter/base-prefix provenance and selected inventories with phase 1, including phase 2 inventory before/after library Python commands and the local venv path. Any phase 2 uv version is allowed if inventory stays unchanged and dependency commands succeed. |
| AC10b | Build sequencing and failure propagation: one Jenkinsfile/job/build runs blocking validation and packaging before unchanged mandated stages. Phase 1 failure prevents phase 2; either phase's failure fails the build. Revision mismatch, dependency drift, wrong interpreter, missing equivalence evidence, or a failed dependency/test command fails validation even when the library masks it. A branch update between checkouts requires a new build and is reported as a revision mismatch, not a product failure. Artifacts/evidence remain attributable to their phase and phase 1 archives stay unchanged. Unresolved compatibility blocks completion. |
| AC11 | Actual Debian CI evidence shows no Maven deployment invocation or release-artifact upload from either phase, while required checks, quality gates, and independent packaging execute. |
| AC12 | RHEL rollback restores the preceding release to readiness with every Python library referential, mirror, and remote artifact service unreachable, using target-local or archive-delivered retained inputs. A venv-free predecessor is reconstructed from its lock. For the first transition, Q05 proposes redeployment of the predecessor's shipped venv by its own procedure, pending confirmation. Compilation or current service availability alone is insufficient evidence. |
| AC13 | Public effort artifacts and review content contain no private application/library identifiers, infrastructure paths, endpoints, credentials, or job links. |
| AC14 | Deployment/CI venv sync and recovery install compatible prebuilt dependency wheels without source builds. An unavailable compatible wheel fails clearly and blocks readiness. The application project itself is not built or installed during dependency sync. Independent application packaging and RHEL toolchain compilation are distinct. |
| AC15 | A same-Python-version toolchain replacement permits venv reuse only with current interpreter/prefix, lock and runtime validation plus fresh archive-digest evidence. Consuming automation/operator procedures enforce serialization for overlapping sync, mirroring, deployment, and rollback on the same application root. |

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

## Open questions for the v0.27.0 deployment venv feature request

Q01, Q03, Q04, Q06, Q07, Q08, and Q10 record human-confirmed answers and remain
here for review traceability until authorized consolidation. After round 2,
the human clarified Q06 again after round 3: same environment means toolchain
Python and locked dependencies, reconstructed locally by our scripts in phase 2,
not shared venv files;
Q10 selects the latest stable uv at qualification, pinned for each release.
Q02, Q05, and Q09 remain proposals requiring human confirmation. Reviewer
agreement does not replace that confirmation.

### Q01: Must rollback work with Python library referentials and mirrors unavailable?

Confirmed: recovery means returning the immediately preceding application
release to readiness after an unsuccessful deployment. An unavailable Python
library referential or mirror means dependency downloads cannot reach it.
The recovery test also makes every remote artifact service unreachable.

#### BBQ for Q01

A barbecue reserve must work while all shops are closed. The reserve is the
retained release inputs; shops are Python library referentials, mirrors, and
artifact services.

#### Options for Q01

- Option A: Require rollback using only inputs already on the target or delivered with retained release archives, including qualified uv.
  - pro: Removes service availability and artifact withdrawal as recovery dependencies.
  - con: Requires a complete, verified recovery set.
- Option B: Permit rollback to depend on a reachable retained-artifact service.
  - pro: Allows centralized storage without complete target-local inputs.
  - con: Rollback can fail during network or service outages.

#### Recommended option for Q01

Option A: The human confirmed offline rollback; make the outage test cover every remote
source, not just the usual mirror.

#### Answer to Q01: option A

Human-confirmed option A. AC12 requires preceding-release readiness with every
Python library referential, mirror, and artifact service unreachable. Q05
separately addresses the first transition's recovery procedure.

### Q02: What remains usable after an in-place Python venv sync fails?

A failed sync blocks readiness. Clarify whether the old Python venv must remain
unchanged or may require recovery.

#### BBQ for Q02

Replacing a barbecue's gas supply can leave it unusable until a spare is fitted.
The replacement is sync, and fitting the spare is redeployment or rollback.

#### Options for Q02

- Option A: Require clear failure and recoverability without uninterrupted-service guarantees.
  - pro: Matches keep-and-sync behavior.
  - con: The venv may be unusable until recovery.
- Option B: Keep the previous venv unchanged and usable on every failure.
  - pro: Provides stronger continuity.
  - con: Adds a transactional availability requirement.

#### Recommended option for Q02

Option A: Keep failure handling and proven recovery without promising zero downtime.

#### Answer to Q02: option A

Proposed option A: failed sync reports failure and blocks readiness; the Python
venv may be unusable afterwards. Recovery is successful redeployment of the
same or preceding release, not a guarantee of an unchanged prior venv.

### Q03: Which package identities and installed wheel bytes must match?

The human confirmed selected package identity checks and wheel ELF equality.
Retained wheels are the exact original saved .whl files, verified against the
canonical lock hashes and kept with their release/platform/group manifest.
Installed copies, URLs, or an expendable cache alone are not retained originals.

#### BBQ for Q03

A menu and sealed ingredient packets provide two references for a barbecue.
The menu is the selected lock; sealed packets are original retained wheels;
checking the grill parts represents ELF byte comparison.

#### Options for Q03

- Option A: Reject missing/mismatched/extra distributions against target-selected lock identities and hashes; compare installed wheel ELFs to original retained wheel binaries.
  - pro: Detects package-set drift and binary rewriting with explicit reference artifacts.
  - con: Does not verify every installed non-ELF file byte.
- Option B: Also verify every installed Python/data file with generated-file exceptions.
  - pro: Covers more post-install modifications.
  - con: Adds a broader integrity system.

#### Recommended option for Q03

Option A: The human agreed to package identity and ELF verification, with the retained
reference defined. Marker-based platform/group differences are not drift.

#### Answer to Q03: option A

Human-confirmed option A. Extra means a distribution absent from the selected
lock set. Do not relocate wheel libraries, including wheel ELFs in venv/bin.
Create the venv at its final path and verify links/shebangs; text or symlink
adjustments do not change wheel ELF library bytes.

### Q04: May a Python venv be reused when the toolchain archive changes but Python's version does not?

The toolchain archive contains the shipped Python interpreter, supporting
native runtime libraries, and utilities; it does not mean application Python
library dependencies. A replacement archive can retain the same Python version
and thus the same named venv path.

#### BBQ for Q04

Two fuel bottles may share a label but contain different batches. The label is
the Python version, the batch is the toolchain archive digest, and the appliance
check is current interpreter and runtime validation.

#### Options for Q04

- Option A: Allow reuse only after current interpreter/prefix validation, locked sync, and readiness, recording the current archive digest.
  - pro: Preserves valid existing venvs with fresh provenance.
  - con: Requires checking the actual replacement toolchain.
- Option B: Recreate the Python venv for every changed toolchain archive digest.
  - pro: Gives a simple replacement rule.
  - con: Discards potentially valid venvs.

#### Recommended option for Q04

Option A: The human confirmed reuse with validation tied to the current toolchain.

#### Answer to Q04: option A

Human-confirmed option A. Record fresh per-platform evidence against the current
toolchain archive digest. Application Python library dependencies use compatible
prebuilt wheels only; source rebuilding during sync/recovery is forbidden and
a missing compatible wheel fails clearly. --locked alone does not enforce this.

### Q05: How should rollback cross the first venv-free release boundary?

The preceding release may have shipped its Python venv and never retained
inputs for lock-based reconstruction. Round 1 recommended using the recovery
procedure that predecessor actually supports.

#### BBQ for Q05

Yesterday's barbecue meal can be restored from a prepared reserve even when
future meals use recipes. The prepared reserve is the predecessor archive with
its venv; the recipe is a venv-free release's lock.

#### Options for Q05

- Option A: For the first transition, redeploy the predecessor archive with its shipped venv using its own procedure; reconstruct from locks from the second venv-free release onward.
  - pro: Uses the predecessor's supported recovery path and proves it on target.
  - con: Requires two recovery forms during one transition.
- Option B: Require lock reconstruction of the predecessor before the first venv-free release.
  - pro: Uses one recovery form immediately.
  - con: Can require historical inputs never retained and block adoption without a safety gain.

#### Recommended option for Q05

Option A: Accept the reviewer's revised recommendation; preserve confirmed offline
recovery without retroactively requiring missing historical inputs.

#### Answer to Q05: option A

Proposed option A, awaiting human confirmation. AC12 names this first-transition
proposal explicitly. Its target readiness test must still succeed with all
Python library referentials, mirrors, and remote artifact services unreachable.

### Q06: What must the mandated phase 2 Python environment share with phase 1?

The human decision of 2026-09-22 supersedes the round 3 same-files wording.
Phase 2's fresh test agent has its own checkout and cannot access phase 1's
venv files. "Same environment" means toolchain Python and locked dependencies.

#### BBQ for Q06

Two kitchens use the same verified ingredients and recipe to prepare equivalent
meals. The ingredients are the toolchain archive and selected dependency wheels;
the recipe is the canonical lock and groups. They do not transport the first meal.

#### Options for Q06

- Option A: Our scripts create a local named venv in phase 2 before the library's Python commands, using the same toolchain archive digest, canonical lock and groups as phase 1.
  - pro: Preserves interpreter and dependency equivalence on fresh agents without copying venvs.
  - con: Requires reconstruction and comparison evidence from the actual phase 2 test agent.
- Option B: Require phase 2 to use phase 1's exact venv files and storage.
  - pro: Would establish physical continuity.
  - con: Superseded by the human decision and incompatible with the confirmed fresh-agent execution.

#### Recommended option for Q06

Option A: Apply the human's clarified meaning of same environment. No same-storage
question or invariant is required. Keep the two-phase order and phase 1 artifacts.

#### Answer to Q06: option A

Human-confirmed option A. The library's dependency, activation and test commands
must use the venv prepared by our scripts, never a copied phase 1 venv or a
replacement created by the library's own commands. A verified explicit alias
to the canonical named venv is not the implicit environment forbidden by
lifecycle rule 4.

Compare archive digest, canonical lock digest, groups, selected inventory and
checkout revision with phase 1. Record phase 2's resolved interpreter, base
prefix and venv path. Capture selected inventory before and after the library's
Python commands. Phase 1's effective dependency selection must equal the
selection the library's unqualified sync applies, so that sync neither adds
nor removes distributions. Any uv version
is acceptable in phase 2 if the locked inventory remains unchanged and its
dependency commands succeed. Dependency drift, revision mismatch, or failed
dependency commands fail validation even when masked by the library.

Deployment and recovery still use the release-pinned uv exactly. Integration
uses the consuming Jenkinsfile and a tracked application script; the private
mechanism belongs to design, with shared-library sources unchanged.

### Q07: Must packaging exclude every Python venv found within its input tree?

Identify a Python venv root by its pyvenv.cfg, then exclude that entire subtree.
This covers current/stale version directories, alternate names, and nested venvs
within packaging inputs; it does not search unrelated host directories.

#### BBQ for Q07

Removing one cooler from a delivery leaves a spare cooler behind. The delivery
is the packaging input tree; the coolers are separately identified Python venvs.

#### Options for Q07

- Option A: Yes: exclude every Python venv identified by pyvenv.cfg throughout packaging inputs.
  - pro: Keeps packaging and relocation exclusions consistent.
  - con: Requires scanning all packaging inputs for that marker.
- Option B: Exclude only the conventionally named application venv directory.
  - pro: Narrows the exclusion rule.
  - con: Can ship stale, alternate-name, or nested venvs.

#### Recommended option for Q07

Option A: The human explicitly answered yes to the broader packaging exclusion.

#### Answer to Q07: option A

Human-confirmed option A. Validate current, stale, alternate-name, and nested
Python venv cases. Use the same pyvenv.cfg boundary as relocation exclusion.

### Q08: Must changes to one application installation run one at a time?

Scenarios are two deployments syncing the same Python venv, archive mirroring
or deletion overlapping sync, and rollback overlapping forward deployment.
These modify the same application root. Independent roots remain independent.

#### BBQ for Q08

Two cooks changing one grill's fuel supply need a one-cook rule. The cooks are
deployment invocations and the grill is the shared application installation.

#### Options for Q08

- Option A: Require the invoking automation/operator to enforce serialization per application root.
  - pro: Makes the rare overlap cases explicit without adding concurrent deployment support.
  - con: The consuming deployment procedure must enforce the rule.
- Option B: Guarantee safe overlapping operations within this feature.
  - pro: Supports overlapping invocations.
  - con: Adds concurrency behavior and failure cases beyond this topic.

#### Recommended option for Q08

Option A: The human confirmed serialization; verify the deployment precondition rather
than assuming simultaneous operations never happen.

#### Answer to Q08: option A

Human-confirmed option A. Verify the consuming automation/operator procedure
prevents overlapping sync, mirroring/deletion, and rollback/forward deployment
against one application root. Separate installations may run independently.

### Q09: Must forward deployment also work without Python library referentials or mirrors?

Offline preceding-release recovery is confirmed by Q01. This does not establish
whether a new release may depend on a reachable private mirror. Resolve target
reachability as a requirement before selecting source transport in design.

#### BBQ for Q09

A reserve meal for yesterday does not ensure tomorrow's ingredients are already
at the barbecue. Yesterday's reserve is rollback inputs; tomorrow's delivery is
the new release; the shop is the Python library referential or its mirror.

#### Options for Q09

- Option A: Require new-release deployment with every referential, mirror, and remote artifact service unreachable, using digest-pinned inputs delivered with the release.
  - pro: Aligns forward installation and offline recovery prerequisites.
  - con: Requires complete release deliveries for each supported target.
- Option B: Allow a reachable private mirror as a documented, verified forward-deployment prerequisite.
  - pro: Allows downloading new-release wheels during deployment.
  - con: Forward deployment depends on service availability. Downloaded wheels must still be kept as retained originals for post-sync comparison and as the next rollback's inputs.

#### Recommended option for Q09

Option A: Recommend self-contained new-release inputs, consistent with confirmed offline
recovery. This remains a proposal, not an inferred reachability guarantee.

#### Answer to Q09: option A

Proposed option A. Test empty-cache forward deployment with all remote package
and artifact services unreachable. Only human confirmation can choose this over
a documented reachable-mirror prerequisite; both choices prohibit source builds.

### Q10: Which release delivers qualified uv, and which version must be qualified?

The toolchain archive means cplx's shipped Python/runtime/utilities archive.
Putting uv inside changes its digest and requires a new release plus repeated
item 7 acceptance. Prior relocation evidence cites uv 0.12.17; the consuming
release tooling lock pins 0.11.19. A dependency utility and application Python
libraries are distinct, even when that utility is pinned in a tooling group.

#### BBQ for Q10

A barbecue lighter can arrive in the grill crate or with the meal ingredients.
The grill crate is the toolchain archive, the lighter is qualified uv, and the
meal delivery is the application release's retained inputs.

#### Options for Q10

- Option A: Deliver uv inside a new toolchain archive and repeat item 7 qualification.
  - pro: Makes uv part of one toolchain delivery.
  - con: Changes the qualified archive and adds release/acceptance scope.
- Option B: Select the latest stable uv at release qualification, deliver its exact digest-pinned artifact with application release inputs, and install explicitly using toolchain Python, retaining the current toolchain archive.
  - pro: Supports offline recovery and preserves item 7's exact archive.
  - con: Requires separate uv delivery/bootstrap evidence on both targets.

- Option C (not admissible under confirmed Q01): Obtain uv from a Python library referential or mirror during deployment, with no retained local recovery copy.
  - pro: Avoids delivering uv with a release archive.
  - con: Cannot satisfy confirmed Q01 and is not an admissible choice under the agreed recovery guarantee.

#### Recommended option for Q10

Option B: The human confirmed application delivery and requested the most recent
version. Select latest stable at qualification, align the consuming tooling lock,
and qualify the exact delivered artifact and bootstrap on both targets. Prior
relocation evidence alone does not prove the new delivery path.

#### Answer to Q10: option B

Human-confirmed option B. The latest stable release checked on 2026-09-22 is
[uv 0.12.17](https://github.com/astral-sh/uv/releases/tag/0.12.17).
Recheck when qualification begins and use the latest stable then; freeze that
version and artifact digest for the release and its recovery. Do not upgrade
implicitly during deployment or rollback. Align the tooling lock while preserving
canonical public URLs. Install under the toolchain prefix using its explicit
Python/pip where required. Deployment and recovery must select the exact
release-pinned uv artifact regardless of install location; a shared installation
must not silently serve another release's uv. Retain it locally under Q01.
Phase 2 may use any uv version subject to Q06's unchanged-inventory and successful
dependency-command evidence; this exception does not apply to deployment/recovery.
