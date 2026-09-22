# Design v0.27.0 -- Deployment-created Python environments

Reference requirement: [feature-request.v0.27.0.deploy-venv-sync.md](feature-request.v0.27.0.deploy-venv-sync.md)

## Context and scope for v0.27.0 deploy-venv-sync

The application release carries dependency reconstruction inputs instead of a
copied Python venv. Debian 12 CI and RHEL 9.8 deployment create environments at
their final paths using the accepted RHEL-built toolchain. The canonical lock
defines dependency identity; platform markers and declared groups define each
selected inventory. Reconstruction requires runtime evidence on both targets.

This design covers archive exclusion, offline release inputs, exact interpreter
and venv selection, locked synchronization, readiness, preceding-release recovery,
and the required two-phase CI build. It preserves item 7's accepted toolchain
archive and evidence. Python 3.14, unrelated CI cleanup, toolchain republication,
and uninterrupted service during failed in-place sync remain outside this topic.

Public components accept generic application configuration. Application names,
private paths, endpoints, library entry points, compatibility details and build
links remain in private integration records. Existing application directories
are preserved; examples do not rename them. The proposals below require design
review and execution qualification; they are not implementation evidence.

## Confirmed technical facts for v0.27.0 deploy-venv-sync

- [install_pkg.sh](../../src/setups/env/bin/install_pkg.sh) discovers
  `pyvenv.cfg` boundaries and excludes those trees from its ELF relocation pass.
  Its text and symlink relocation behavior still supports historical copied
  environments. New environments can be created after archive installation.
- [tools_wheel_inventory.py](../../src/setups/env/bin/tools_wheel_inventory.py)
  captures original wheel hashes and ELF members, compares the installed ELF
  set, and materializes retained ELF subjects. Its inventory is bound to a lock
  digest. It does not resolve the lock's target/group selection or prove the
  complete installed distribution set: those are additional responsibilities.
- [closure_observe_live.sh](../../src/setups/env/bin/closure_observe_live.sh)
  distinguishes usable observations from inconclusive empty inventories.
  Existing closure and item 7 acceptance evidence remain the runtime baseline.
- Inspected consuming-application provisioning already exposes separate fetch,
  relocation, staging, venv and venv-path operations. It selects toolchain Python,
  disables Python downloads, synchronizes through a transport lock and records
  wheel evidence. Its uv bootstrap currently fetches an unpinned artifact, so it
  is not the required offline release bootstrap.
- Inspected application deployment selects a venv by recency and includes
  Git-based restoration. Both assumptions must be removed from the new
  archive-only reconstruction path. The application already has lock transport
  filtering and validation; these can inform adapters but cannot be required on
  a deployment target without Git.
- Current application acceptance has blocking test, coverage and runtime evidence
  operations. The mandated second CI phase has separate agent/workspace and
  command-result boundaries. A prior activation or workspace cannot provision it.

The last three observations describe private source inspection; operational
references and integration mechanics are retained privately.

## Current and target lifecycle for v0.27.0 deploy-venv-sync

Current flow: CI provisions and tests a venv, packaging carries it, and deployment
relocates and checks the copied tree. Archive mirroring can remove local venvs.

Target flow:

```text
CI validation (one Jenkinsfile, one build; both publishers disabled):
  phase 1: tools/venv -> blocking checks -> application archive + bundle
  -> archive candidate bytes/evidence -> release preliminary agent
  -> mandated pipeline: fresh agent, our tools Python + equivalent named venv
  -> combined validation verdict (no deployment or release publication)
release qualification: CI verdict + required Debian/RHEL/offline evidence
  -> separate publication run promotes qualified archive + bundle by digest
  -> release repository manifest -> complete local retained release inputs
serialized deployment -> preflight inputs -> mirror/install archives
  -> resolve toolchain Python and exact venv path
  -> validate existing venv or create absent venv at final path
  -> locked wheel-only sync -> inventory/ELF/runtime checks -> ready
failure -> not ready -> redeploy or restore preceding release -> verify readiness
```

The mutation boundary starts before archive mirroring and ends after readiness
or failure recording. The consuming automation owns exclusive access to the
application root for that entire interval, including rollback. An enforced
deployment lock or an equivalent serialized job is a precondition; an operator
note alone is not proof. Independent roots may proceed independently.

## Release inputs and retention for v0.27.0 deploy-venv-sync

### Release reconstruction bundle

Deliver a digest-addressed companion bundle with the application release. Treat
both as one logical delivery: missing or mismatched inputs fail preflight before
destructive mirroring. A versioned manifest binds:

| Input | Binding and purpose |
| --- | --- |
| Application | Release identity, application archive digest and source revision |
| Dependency metadata | Canonical `pyproject.toml` and `uv.lock` digests, relevant workspace/configuration inputs |
| Toolchain | Accepted archive digest, full Python version and supported target identities |
| uv | Qualified exact version, original artifact digest, static linkage and supported platform; derived identity only for a qualified fallback |
| Dependency selection | Target OS/architecture, Python/ABI tags, markers, extras and effective groups |
| Original wheels | Normalized distribution identity, version, filename, canonical lock hash and bundle path |
| Source transport | Mapping format/version, canonical identity and effective-lock verification rules |
| Runtime evidence | References/digests for qualified selection and provider evidence |

The bundle contains the original wheel files, qualified uv artifact and source
metadata sufficient to reconstruct each supported selection. Include CI's test
selection and deployment's selection separately; deployment excludes `tooling`.
No dependency sdist or build tool can substitute for a missing compatible wheel.
The application project is not installed by dependency sync.

Store retained bundles and predecessor archives outside the application subtree
subject to mirroring. Preserve at least the current and immediately preceding
release's complete inputs, including their compatible toolchain/runtime archives.
Retention is independent of uv caches. Shared storage may deduplicate immutable
objects by digest, but deletion must respect references from retained releases.
Local rollback inputs must be complete before advancing the retained predecessor.

### Qualification, publication and local delivery

Phase 1 of the validation build produces both the venv-free application archive
and its reconstruction bundle, freezes their digests, and archives the exact
candidate bytes with their manifests. CI artifact archiving preserves candidates;
it is not release publication. The mandated pipeline is phase 2 of that same
validation build, solely for CI validation. Neither phase deploys the application
or invokes a release publisher. A successful combined build alone does not
replace the required RHEL readiness, offline reconstruction and rollback evidence.

Candidate retention must survive later validation builds until promotion or
explicit abandonment. A latest-build-only CI artifact policy cannot provide this.
Prefer marking the named source build as kept in CI, exempting its archived pair
from routine discarding; use a durable candidate store only when that protection
is unavailable.
Before phase 1 cleanup, copy the verified pair and manifests to a durable,
access-controlled candidate store if CI retention cannot protect that named build.
This store is an internal qualification handoff, not the release repository or a
deployable release announcement; validation still invokes no release publisher.
The candidate-store copy uses neither a Maven deployment command nor the release
repository. Evidence distinguishes this handoff from release uploads and preserves
the validation build's no-deployment and no-release-upload guarantees.
Index candidates by source build, revision and archive/bundle digests. Never
replace a pending candidate with a later build's bytes. Failure to retain the pair
blocks qualification; candidate loss blocks promotion.

Qualification delivery retrieves the exact candidate pair from that protected
store or retained source build, checks both digests and copies the inputs to the
RHEL qualification target's local retained store before remote access is denied.
RHEL readiness, offline reconstruction and rollback evidence identify those exact
candidate digests and the toolchain digest; rollback also identifies the retained
predecessor pair, or its historical archive for the first transition. Publication
rejects evidence for different bytes even when its revision matches. Evidence
produced after candidate assembly is a separate digest-bound qualification record;
do not mutate the frozen bundle to insert later results. The final release manifest
references the candidate pair and completed qualification record.

After qualification, a separate, explicitly authorized publication run retrieves
the retained candidate pair and checks its digests, revision and complete
qualification evidence. It publishes those exact bytes without rebuilding them.
Preserve the existing application's artifact coordinates and publisher semantics;
publish the companion bundle under associated immutable release coordinates in
the configured release artifact repository. A release manifest binds the two
coordinates and digests, the accepted toolchain archive and qualification evidence.
Publish the objects before making this manifest available as a deployable release.
Partial publication is not a complete release, and retries must verify identical
bytes rather than overwrite an existing identity with different content.

The publication run is separate from the two-phase validation build; it is not
another phase/job replacing the mandated pipeline. Only its application release
publisher is enabled. The mandated pipeline's publisher remains disabled and
does not provide the application release path. Candidate expiry blocks promotion;
rebuilding is not evidence of byte identity. If a publication run must regenerate
the pair from the same source revision, pin all reconstruction inputs, record
the new digests and qualify those bytes through the same validation and target
checks before publication. A matching revision alone never transfers qualification.

Confirmed execution boundary (Q09): an operator-run publication outside CI uses
the existing application publisher, with controlled credentials and reproducible
inputs. Record the source build, candidate digests, qualification record and
publication receipts. This adds no Jenkins job or bypass mode to validation.
The mandated pipeline runs only in the preceding validation build; operator
publication and deployment do not invoke it. This design decision does not
authorize an actual publication.

Repository retention protects the complete current and preceding release pairs
and referenced toolchain inputs independently of CI build retention. Before
deployment, delivery downloads and verifies the complete pair and required
toolchain into release-specific local storage outside the mirrored application
tree. Offline preflight and rollback consume that local store, not the repository
or a CI workspace. The predecessor remains retained until the new release is ready
and the rollback-retention boundary can safely advance. Missing inputs block
deployment before mutation; repository availability is not an offline guarantee.

### Offline source transport

Proposed transport: qualify filesystem-backed registry/artifact locations in the
retained bundle first, addressed through `file:` URLs in an effective lock and
matching source configuration. This avoids a listening socket and server lifetime.
It is not enough to supply a wheel directory while leaving remote locked URLs
unchanged. If the qualified uv cannot accept this representation under `--locked`,
qualify a release-scoped static referential on loopback as the fallback. That
server serves only packaged metadata and original wheel bytes, with no remote
proxying or redirects. Both transports must work with an empty uv cache and every
remote referential, mirror and artifact service unavailable.

Derive an effective lock and matching source configuration from immutable
canonical metadata in a disposable metadata workspace. A structured validator
permits only registry/artifact location changes described by the manifest;
versions, dependencies, markers, groups, artifact identities and hashes must be
unchanged. Resolve every selected artifact to a retained original wheel.
Reject unmapped URLs, path escapes, ambiguous artifact matches and changed hashes.
Preserve the canonical lock byte-for-byte and record both digests and the mapping.
Validate the canonical/transport round trip before sync and afterwards.

Both transports require the same identity-preserving effective-lock contract.
The local transport is a proposed design, not a claim that an arbitrary rewritten
lock is accepted by uv. Qualification must establish `--locked` consistency with
the effective project configuration on both targets. Never substitute `--frozen`
or an independent requirements installation to make this pass. If the qualified
uv cannot support this transport, return to design review before implementation
proceeds with a replacement beyond the qualified fallback.

Remote access is denied during qualification. For the filesystem transport,
qualify uv's offline mode; for the HTTP fallback, allow loopback and do not use
uv's network-disabling offline switch. A fresh
operation-owned cache demonstrates independence from prior cache contents.
Private mirror mappings are used only while assembling/qualifying release inputs;
validate that acquisition, including uv, with public access unavailable. Private
configuration supplies the actual source and authentication; no credentials enter
the bundle, public metadata or evidence. Git filters are optional acquisition
adapters and play no part in target deployment.

### Qualified uv bootstrap

At release qualification select the latest stable uv and freeze its exact artifact
and version for that release. Do not resolve latest on the target. Deliver uv
with application inputs without repacking the accepted toolchain archive. Install
it under a release-specific location in the toolchain installation, select its
absolute executable, and verify the digest/version before use. Bootstrap through
the selected toolchain Python and its pip if needed, using only local delivered
inputs; never use system pip or an administrator installation.

Qualify an unmodified fully statically linked Linux uv artifact first, retaining
one executable provenance identity across both targets. Such artifacts are
published according to [uv platform support](https://docs.astral.sh/uv/reference/policies/platforms/).
Verify actual linkage and execution with the shipped runtime environment on both
targets; availability of a static build is not qualification evidence.

Only if that artifact proves unsuitable, qualify target-specific adaptation as
the fallback. If adaptation is necessary, retain the original
artifact and separately bind the derived executable, transformation and runtime
qualification to the release. Never confuse a modified executable's digest with
the delivered artifact digest. This tooling boundary does not permit changes to
application dependency wheel ELFs. Recovery selects the predecessor's uv, even
when another release has installed a newer copy in the same tools prefix.

## Environment identity and synchronization for v0.27.0 deploy-venv-sync

The lifecycle interface takes an absolute application root, project naming
suffix, tools prefix, release manifest and explicit selection profile. It returns
the exact venv path plus evidence and a success/failure status. It does not infer
release identity from the newest directory or the ambient shell environment.

Resolve `<tools-prefix>/python/current/bin/python3` to the actual shipped
interpreter and query its full version. Cross-check the installed toolchain
identity and archive digest. Derive
`<application-root>/venvs/python_<full-version>_<project>`, preserving dots and
converting dashes to underscores according to the application's existing
contract. The declared toolchain directory version must agree with the executable.

| Existing state | Required action |
| --- | --- |
| Exact path absent, including removal by mirroring | Create there using the absolute selected interpreter |
| Exact path is a valid toolchain-based venv | Validate base executable, prefix and version, then sync |
| Exact path is foreign, malformed or points outside its expected location | Fail clearly; no fallback or automatic adoption |
| Other Python versions exist | Ignore them for selection; preserve them unless a separate retention procedure owns cleanup |
| Toolchain digest changed at equal Python version | Revalidate current interpreter identity and repeat lock/runtime qualification before readiness |

Creation, sync, tests and readiness use this one computed path. Set explicit
`UV_PYTHON`, `UV_PROJECT_ENVIRONMENT` and disabled Python downloads for sync;
do not trust PATH or a foreign activation. Verify the resulting base executable
and prefix rather than accepting an equal version string or `pyvenv.cfg` alone.

Run qualified uv with locked consistency, no source builds, no application-project
installation and the selected groups against the effective release metadata.
The canonical metadata must also be qualified as current before transport.
Reject ambient configuration that changes dependency selection or sources.
Use original wheels and an operation-owned cache, not cached source-built wheels.

Readiness is an operation result tied to release, interpreter, toolchain digest,
lock and selected inventory. Invalidate any previous success result before
mutation. A partial sync, stale lock, missing wheel or failed check leaves the
root not ready; cleanup must preserve the primary failure and diagnostics.
No atomic venv swap is promised. Failed in-place synchronization is recoverable
by redeployment or rollback and may interrupt availability.

## Inventory and runtime boundaries for v0.27.0 deploy-venv-sync

Compute expected distributions from the canonical lock and the declared target
selection. Compare normalized names and versions with installed metadata,
rejecting missing, changed and extra distributions. Bind each selected wheel to
its canonical lock hash and retained bytes. Marker-excluded packages are not
missing, and legitimate platform selections need not be identical across OSes.

Reuse item 7's wheel helper for retained-wheel hashing and installed ELF
comparison, with a separate complete distribution-selection check. Ensure the
installed ELF scope includes wheel-supplied executables under venv `bin`, as well
as library locations; an inspection limited to site-packages cannot establish
that guarantee. Preserve the helper's existing capture/materialize contract or
extend it compatibly; do not claim it already covers these added responsibilities.

All venv trees remain excluded from generic ELF rewriting. New venvs are created
at their final paths; validate interpreter links, generated shebangs and
configuration without blanket relocation. No wheel ELF, including one under
`bin`, may be patched. Preserve wheel `$ORIGIN` paths.

Reuse the shared versioned runtime setup, putting shipped library directories
first for application runtime commands. Keep host utility execution outside
incompatible runtime-library exports. Validate executables, interpreter, stdlib,
imports and heavy-wheel consumers on both targets. Debian requires ABI listings
and a conclusive live trace with no ABI-critical host fallback. RHEL follows
item 7's provider matrix and end-to-end operator readiness; Debian's stricter
trace condition is not imposed on RHEL. Non-ELF installed file-byte equivalence
is not claimed.

## Packaging and recovery boundaries for v0.27.0 deploy-venv-sync

Discover every `pyvenv.cfg` inside the packaging input tree and exclude its parent
subtree before assembling the archive. This covers stale, alternate-name and
nested environments without scanning unrelated host directories. Archive
inspection verifies the result and the presence of canonical release metadata
and reconstruction inputs. Packaging traversal must not dereference an alias
and thereby reintroduce a venv. Preserve application archive coordinates and
metadata; packaging remains independent of publication.

The new deployment path verifies and uses delivered metadata directly, without
Git restoration or a smudge filter. After installing/mirroring application and
toolchain archives, it reconstructs the venv and performs readiness. Keeping a
local venv through mirroring is an optimization, never a prerequisite.

Rollback acquires the same root serialization boundary, selects the immediately
preceding release explicitly and checks its retained inputs before mutation.
For a venv-free predecessor, restore its application/toolchain inputs and
reconstruct with its uv, lock, wheels and selection. For the first transition,
redeploy the predecessor's archive with its shipped venv using its historical
procedure. Do not force modern reconstruction onto a release lacking those
inputs. Both paths require actual offline RHEL readiness evidence.

## Two-phase CI integration for v0.27.0 deploy-venv-sync

One application Jenkinsfile orchestrates one job/build. A scripted preliminary
allocation runs existing application provisioning, cplx verification, runtime
checks, acceptance tests, coverage validation, venv-free packaging and reconstruction
bundle assembly. Archive its evidence and exact candidate pair and preserve its coverage artifacts before
cleanup. Failure blocks entry into the mandated phase. Release this allocation
before calling the unchanged mandated pipeline; do not nest a second declarative
pipeline or hold an outer agent while the library acquires its own agents.

The application-owned integration provides a tracked adapter that runs on the
second phase's actual test agent after checkout and before its Python commands.
It invokes existing provisioning scripts to reconstruct a local named venv from
phase 1's toolchain archive digest, canonical lock and effective groups. Agent
paths may differ. Compare checkout revisions; a changed branch tip requires a
new build, reported as a revision mismatch. No phase 1 venv is copied.

Phase 1's effective selection equals the selection that the mandated phase's
unqualified sync applies, including defaults, so that sync neither adds nor
removes distributions. Explicit provenance controls and, where necessary,
a verified alias make dependency, activation and test commands select the
prepared environment. No replacement environment, command shim or subsequent
unpinned dependency installation is accepted. The adapter's private mechanism
and compatibility controls remain in private integration records.

The adapter must establish this environment inside the actual Python-command
shell, after that agent's checkout and before any dependency or test command.
Build-scoped configuration locates the adapter in that agent's own checkout;
qualification must prove propagation and execution there. Prior shell activation
and a configured Python version label do not select an interpreter. Limit the
adapter to the intended step, prevent recursive initialization by child shells,
and fail the step if initialization or required observation does not complete.

Export `UV_PYTHON` as the resolved shipped Python and `UV_PROJECT_ENVIRONMENT`
as the absolute named venv, with Python downloads disabled and qualified locked/
no-build controls. Set `VIRTUAL_ENV` to that venv and place its real executables
first on `PATH`, followed by the selected toolchain tool directories. Load the
shipped runtime setup for Python/application commands. Verify the resolved Python,
uv, pip-facing installation target and test runner, not just variable values.
Any fixed activation path used by the mandated commands must resolve through a
verified alias to this named venv in their actual working directory, including
after activation; it must never create or select another environment. Compatibility
inputs for a mandatory installation command must make it a verified successful
no-op, with no additional dependencies or change to the locked inventory.

Record interpreter/base prefix, venv prefix, executable paths, toolchain identity
and complete inventory at the dependency and test execution boundaries. Deliberate
wrong-host-Python and foreign-activation cases must still use the shipped Python
and prepared venv; a foreign existing target must fail. Prove runtime/tool selection
after the mandated activation as well as before it. These are actual-agent
acceptance gates, not claims that environment variables alone establish compatibility.

Phase 2 obtains the already available toolchain archive and original wheels from
the configured private mirror and artifact service. It verifies the archive
against phase 1's recorded digest and each selected wheel against the canonical
lock and phase 1's selected wheel manifest. It uses the release bundle's CI
selection profile. Phase 1 records the toolchain archive digest, canonical lock
digest, selection profile digest and selected wheel manifest digest in its
archived evidence. The consuming Jenkinsfile passes them to the phase 2 adapter
as build-scoped, non-secret values; no credential travels this way. The
manifest/profile can be regenerated from the identical checkout and compared
with those digests. It does not assume access to phase 1's workspace or upload its
newly tested package to make inputs reachable. If an input is unavailable or its
identity differs, phase 2 fails. Offline forward deployment and recovery still
use delivered bundles; this CI acquisition path does not relax their contract.

Capture complete selected inventory and interpreter provenance before and after
the mandated Python commands, compare them with phase 1, and record the actual
uv version. Phase 2 may use another uv version only when its dependency commands
succeed without inventory drift. Keep the canonical lock, no-build rule, sources
and runtime setup intact. This exception does not apply to deployment/recovery.

Command outcomes need independent, fail-closed evidence when the library masks
failures. An unchanged inventory or a coverage file alone does not prove that
sync, installation or tests succeeded. The integration must observe each required
command's real status and require fresh, attributable test/coverage evidence.
Use shell-level error observation installed before the mandated commands to
record dependency failures outside conditional constructs. For test commands
whose shell status is discarded, the test framework records its own session
result independently. Bind both observations to the actual command/session,
revision and venv. Require expected start/completion records so an observer that
never ran cannot imply success.
Missing observation, masked failure, drift or wrong interpreter fails combined
validation. Shell exit hooks alone are not assumed to capture failures inside
commands whose status is explicitly discarded; the private adapter must prove
both observation boundaries on the actual agent, including deliberate failures.
Any command form neither boundary observes blocks
completion without authorizing shared-library changes.

Preserve conformity checks, quality gates and separate report provenance.
No later checkout or dependency command may replace phase 1's tested artifact
or coverage evidence. Archive failure diagnostics in finally handling, without
cleanup changing the original verdict. Disable both publishers in validation builds; executed-command
evidence must show no Maven deployment invocation or release-artifact upload.
Effective settings must survive job-parameter overrides. Static settings alone
are not proof, and phase 2 evidence does not establish application runtime parity.

## Acceptance cases and evidence for v0.27.0 deploy-venv-sync

| Case | Required outcome | Requirement |
| --- | --- | --- |
| Current, stale, nested and alternate-name venvs in packaging inputs | None enters the archive, including through aliases; metadata remains | AC01 |
| Archive-only target, no Git, empty caches and remote access denied | Delivered uv and wheel inputs support locked reconstruction and readiness | AC02, AC06, AC14 |
| Wrong host Python, foreign activation or foreign-base existing venv | Exact tools interpreter wins; foreign existing target fails | AC03 |
| Repeated sync, multiple versions or mirroring removal | Exact path is reused or recreated; recency has no effect | AC04 |
| Stale lock, missing wheel or interrupted sync | Not ready; no subsequent packaging/publication; redeploy/rollback available | AC05, AC14 |
| Extra distribution, mismatched wheel or modified wheel ELF | Inventory/integrity gate fails | AC07 |
| Same Python version with a new tools archive | Fresh interpreter, archive, lock and runtime evidence required | AC15 |
| Debian execution of the accepted RHEL-built archive | Actual acceptance, ABI and conclusive provider evidence retained | AC08, AC09 |
| Fresh second CI agent | Locally reconstructed equivalent environment and successful observed commands | AC10a |
| Revision drift, masked command failure or missing evidence | Failed validation; phase 1 failure prevents phase 2 | AC10b |
| Validation build with parameter overrides | Both publishers disabled, required packaging/checks still executed | AC11 |
| Publication after complete qualification | Exact qualified archive/bundle digests published together; rebuilt bytes require qualification | AC01, AC11, AC14 |
| Qualification evidence identifies other candidate digests | Promotion refused even at the same source revision | Design-level release case; no single criterion |
| A later validation build runs while a candidate awaits qualification | Pending candidate remains protected until promotion or explicit abandonment | Design-level release case; no single criterion |
| Release repository unavailable during rollback | Locally retained predecessor bundle, archive and tools suffice, independently of CI retention | AC12, AC14 |
| Offline preceding-release rollback, including first transition | Original release restored to RHEL readiness | AC12 |
| Competing mirror, sync or rollback on one root | Consuming serialization prevents overlapping mutation | AC15 |
| Public design and evidence | Generic identifiers only; private operational evidence retained separately | AC13 |

Each execution record binds OS/architecture, source revision, toolchain digest,
resolved interpreter/base prefix/full version, uv artifact/version, canonical and
effective lock digests, selection, venv path, wheel/inventory digests and command
results. CI records additionally identify phase and executing agent privately.
Public reports contain sanitized outcomes and remaining gaps. Local/static checks
cannot close Debian Jenkins or RHEL readiness/rollback acceptance.

## Supporting references for v0.27.0 deploy-venv-sync

- [Item 7 design](design.v0.27.0.tools-archive-rebuild.md) and
  [validation plan](plan.v0.27.0.tools-archive-rebuild.validation.md): accepted
  archive, wheel integrity and runtime qualification baseline.
- [uv locking and syncing](https://docs.astral.sh/uv/concepts/projects/sync/):
  locked consistency differs from frozen synchronization.
- [uv command reference](https://docs.astral.sh/uv/reference/cli/): no-build,
  project-installation and network controls must be qualified together.
- [uv cache behavior](https://docs.astral.sh/uv/concepts/cache/): caches are an
  optimization, not the retained original-wheel delivery contract.

## Open questions for the v0.27.0 deploy-venv-sync design

Q09 is human-confirmed. The other answers remain review recommendations pending
consolidation.

### Q01: Offline source transport

Should the release use a loopback static referential, or a filesystem-only transport? Either must pass locked consistency with empty caches and all remote services unavailable.

#### BBQ for Q01

The pantry can serve ingredients through a counter or directly from labeled boxes. In this picture: the pantry is the retained bundle, the counter is the loopback referential, and labeled boxes are filesystem artifact locations.

#### Options for Q01

- Option A: Qualify a loopback static referential as proposed.
  - Pro: Preserves registry-style artifact locations without remote access.
  - Con: Adds server lifetime, port and effective-lock configuration concerns.
- Option B: Qualify filesystem-backed locations first, keeping loopback as a fallback.
  - Pro: Avoids listening sockets and server lifecycle.
  - Con: Needs the same effective lock and matching source configuration as A; the qualified uv must accept filesystem locations under locked consistency.

#### Recommended option for Q01

Option B: Avoid server lifetime and listening sockets when the qualified uv accepts local filesystem locations. Both choices retain the same identity validator and locked-consistency gate; loopback is a fallback only after filesystem qualification fails.

#### Answer to Q01: option B

Option B: Qualify filesystem transport first; use the loopback fallback only with equivalent identity and empty-cache evidence on both targets.

### Q02: Release bundle delivery

Should reconstruction inputs be a digest-bound companion archive or embedded in the application archive?

#### BBQ for Q02

A meal kit can include its pantry box or travel with a separately labeled box. In this picture: the meal kit is the application archive, the pantry box is the reconstruction bundle, and its label is the digest binding.

#### Options for Q02

- Option A: Keep a required companion archive bound by the release manifest.
  - Pro: Allows independent retention and deduplication while preserving existing application archive contents.
  - Con: Delivery must enforce that both parts are present before mutation.
- Option B: Embed the bundle in the application archive.
  - Pro: Makes completeness easier to enforce through one delivered object.
  - Con: Increases repeated archive transfer and couples dependency retention to application packaging.

#### Recommended option for Q02

Option A: Require a complete logical delivery and reject missing companions before mirroring, avoiding reliance on disposable caches.

#### Answer to Q02: option A

Option A: Require a complete logical delivery and reject missing companions before mirroring, avoiding reliance on disposable caches.

### Q03: uv executable provenance

How should target-specific uv adaptation coexist with the release-pinned original artifact?

#### BBQ for Q03

A sealed ingredient may need preparation before serving. In this picture: the sealed ingredient is the original uv artifact, preparation is runtime adaptation, and the served portion is the derived executable.

#### Options for Q03

- Option A: Permit a separately hashed derived executable with recorded transformation and qualification.
  - Pro: Accommodates the existing cross-distribution runtime boundary without changing the accepted toolchain archive.
  - Con: Requires two provenance identities and target-specific evidence.
- Option B: Qualify an unmodified fully statically linked uv artifact first, with adaptation only as a fallback.
  - Pro: Simplifies provenance and recovery verification.
  - Con: May require selecting a different qualified artifact or bootstrap strategy if runtime compatibility fails.

#### Recommended option for Q03

Option B: A qualified static artifact keeps one executable identity and avoids runtime adaptation. Verify linkage and actual execution on both targets; if unsuitable, qualify A with original and derived hashes separately.

#### Answer to Q03: option B

Option B: Record static linkage and the artifact digest in the manifest, retaining the explicit adaptation fallback only if qualification demonstrates a need.

### Q04: Inventory verification ownership

Should complete distribution selection and all installed ELF locations share one expanded inventory helper, or compose with the existing helper?

#### BBQ for Q04

The guest list and food inspection answer different questions. In this picture: the guest list is selected distribution membership, food inspection is wheel ELF verification, and the event report is combined readiness evidence.

#### Options for Q04

- Option A: Compose a selection verifier with the existing ELF helper, extending ELF scope compatibly where needed.
  - Pro: Preserves item 7's established evidence contract and makes the added responsibility explicit.
  - Con: Requires a shared identity binding so two reports cannot describe different selections.
- Option B: Replace the helper contract with one unified inventory format and verifier.
  - Pro: Offers one complete inventory entry point.
  - Con: Expands migration and regression scope for existing item 7 callers and evidence.

#### Recommended option for Q04

Option A: Bind both reports to the same canonical lock, profile and wheel manifest while retaining existing consumers.

#### Answer to Q04: option A

Option A: Bind both reports to the same canonical lock, profile and wheel manifest while retaining existing consumers.

### Q05: Serialization interface

How should consuming deployment procedures demonstrate exclusive ownership of an application root?

#### BBQ for Q05

Only one cook can rearrange a shared preparation bench at a time. In this picture: the cook is a deployment or rollback operation, the bench is the application root, and exclusive use is mutation serialization.

#### Options for Q05

- Option A: Require an explicit serialization attestation from the consuming adapter and verify exclusion in integration.
  - Pro: Works with existing CI scheduling or operator locking without imposing one cross-platform locking implementation.
  - Con: The adapter must demonstrate enforcement across mirror, sync and rollback rather than merely claim it.
- Option B: Make the reusable lifecycle own a per-root lock spanning archive installation and readiness.
  - Pro: Provides a uniform locking contract to callers.
  - Con: Requires integrating every existing mutation entry point and managing lock lifetime across them.

#### Recommended option for Q05

Option A: Keep enforcement with the consumer as the requirement specifies, but make its boundary and verification part of the interface.

#### Answer to Q05: option A

Option A: Keep enforcement with the consumer as the requirement specifies, but make its boundary and verification part of the interface.

### Q06: CI command outcome evidence

Which evidence boundary should the application adapter establish for commands whose failures the unchanged library masks?

#### BBQ for Q06

A clean table does not prove every dish was cooked successfully. In this picture: the clean table is an unchanged dependency inventory, each dish is a library command, and the service record is its independently observed result.

#### Options for Q06

- Option A: Require command-status observation plus fresh attributable test evidence, with unresolved observation blocking acceptance.
  - Pro: Distinguishes successful commands from masked failures and preserves the unchanged-library constraint.
  - Con: The private adapter must prove its instrumentation catches the actual masked command forms.
- Option B: Rely on isolated fresh output artifacts and postconditions as the primary evidence, qualifying their completeness for each command.
  - Pro: May avoid fragile shell instrumentation.
  - Con: Inventory and coverage artifacts alone cannot prove dependency/test exit status, so this route may be unable to satisfy acceptance.

#### Recommended option for Q06

Option A: Combine shell-level error observation for dependency commands outside conditional constructs with a test-framework session result for tests whose shell status is discarded. Require fresh start/completion evidence and deliberate-failure qualification on the actual agent. Any unobserved command form blocks acceptance.

#### Answer to Q06: option A

Option A: The two complementary observation boundaries address both dependency failures and discarded test status, without treating an exit hook or unchanged inventory as proof. Each boundary records its own start and completion, so an observer that never ran cannot imply success. Qualification remains mandatory.

### Q07: Phase 2 input sources

How does the application adapter obtain identical toolchain and wheel inputs on
the fresh mandated test agent, without assuming phase 1 workspace access?

#### BBQ for Q07

A second kitchen can order the same sealed ingredients or receive the first
kitchen's unopened supplies. In this picture: the kitchens are the CI agents,
sealed ingredients are digest-verified archives and wheels, and the order list
is the release bundle's CI selection profile.

#### Options for Q07

- Option A: Acquire existing inputs from configured private mirror/artifact services and verify them against phase 1 digests and canonical wheel hashes.
  - Pro: Works from the adapter's own shell without accessing the earlier workspace or uploading the tested package.
  - Con: CI requires those services to retain the exact inputs; unavailable artifacts fail the build.
- Option B: Transfer phase 1's reconstruction bundle through a supported publication-free CI artifact mechanism.
  - Pro: Reuses exactly the retained bytes and avoids a second mirror acquisition.
  - Con: Requires a proven transfer into the library-owned agent that its shell adapter may not expose.

#### Recommended option for Q07

Option A: Use the same bundle CI selection, verify its profile and wheel manifest
digests against phase 1, and check the toolchain archive and canonical wheel
hashes. Regenerated manifests must match the recorded digest. No new release
artifact upload is required. Offline deployment and recovery still use bundles.

#### Answer to Q07: option A

Option A: Existing services provide the fresh agent's inputs while digest checks
establish identity. Missing or mismatched inputs fail; prior workspace access is
never assumed.

### Q08: Qualified release publication

Should publication promote the validation build's exact archive and bundle, or
rebuild them from the qualified source revision?

#### BBQ for Q08

A tested meal kit can be shipped sealed or assembled again from the same recipe.
In this picture: the sealed kit is the qualified archive/bundle pair, the recipe
is the source revision, and inspection is qualification of the actual bytes.

#### Options for Q08

- Option A: Promote the exact digest-verified candidate pair in a separate publication run.
  - Pro: Preserves qualification identity and keeps release publishing disabled throughout validation.
  - Con: Requires reliable candidate retention and retrieval until promotion.
- Option B: Build a new pair from the same revision in a publication run and qualify those bytes before publishing.
  - Pro: Fits release systems that cannot promote archived candidates directly.
  - Con: Repeats qualification; identical source alone cannot establish identical artifacts.

#### Recommended option for Q08

Option A: Publish the qualified bytes and their binding manifest to the release
repository, retaining complete current/predecessor inputs there and locally for
offline rollback. Option B is a fallback only with fresh qualification of its
actual digests. The mandated pipeline remains CI validation, not deployment.

#### Answer to Q08: option A

Option A: Prefer promotion of the exact qualified pair; candidate loss blocks
promotion rather than silently authorizing a same-revision rebuild as equivalent.
Pending candidates survive later builds until promotion or explicit abandonment,
and qualification evidence must bind to the exact archive/bundle digests.

### Q09: Publication execution boundary

Where should the authorized publication run execute while preserving the single
Jenkinsfile/job/build validation sequence and its mandated pipeline?

#### BBQ for Q09

The inspected meal kit still needs a dispatcher. In this picture: inspection is
the complete validation sequence, the dispatcher is the publication runner, and
the sealed kit is the retained candidate pair.

#### Options for Q09

- Option A: An explicitly authorized publication mode of the same Jenkins job.
  - Pro: Preserves one job and its existing publisher credential boundary.
  - Con: Requires confirmation that the mandate permits a build without validation phases, plus fail-closed mode selection.
- Option B: A separate publication job consuming qualified candidates.
  - Pro: Separates validation permissions from publication permissions.
  - Con: Adds a job and requires authorization relative to the one-job constraint.
- Option C: Operator-run publication outside CI through the existing application publisher.
  - Pro: Preserves every validation build's mandated flow without an additional Jenkins job or an assumed exception.
  - Con: Requires a reproducible runner with controlled credentials and durable publication evidence.

#### Recommended option for Q09

Option C: Use the existing publisher from an explicitly authorized operator run,
with the same digest/evidence gate and manifest-last publication contract. Record
source build, candidate digests, qualification record and publication receipts;
credentials remain in the authorized runner, outside bundles and evidence. Options
A/B require confirmation that their CI execution model is permitted.

#### Answer to Q09: option C

Option C: confirmed by the user on 2026-09-22 as scenario 1, operator-run
publication outside CI. The single validation build still runs both phases with
its publishers disabled. Operator publication consumes its qualified bytes and
does not rerun the mandated pipeline. Deployment does not invoke that pipeline.
This design decision does not authorize an actual publication.
