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
are preserved; examples do not rename them. The decisions below were consolidated
after round 4 review and human confirmation. Execution qualification remains
required; these decisions are not implementation evidence.

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
The consuming adapter supplies an explicit serialization attestation; integration
validation must demonstrate exclusion across mirroring, sync and rollback.

## Release inputs and retention for v0.27.0 deploy-venv-sync

### Consumer-supplied local inputs and offline execution

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

The human-approved requirement Q09 amendment defines this starting boundary.
Plan Q09 records its implementation consequences. Design Q09 still concerns
operator publication outside CI and is unchanged.

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

Confirmed publication execution boundary (design Q09): an operator-run publication outside CI uses
the existing application publisher, with controlled credentials and reproducible
inputs. Record the source build, candidate digests, qualification record and
publication receipts. This adds no Jenkins job or bypass mode to validation.
The mandated pipeline runs only in the preceding validation build; operator
publication and deployment do not invoke it. This design decision does not
authorize an actual publication.

Repository retention protects the complete current and preceding release pairs
and referenced toolchain inputs independently of CI build retention. Before
cplx invocation, the consumer supplies the complete pair and required toolchain
in release-specific local storage outside the mirrored application tree. cplx
verifies the files and their recorded identities before mutation; the consumer
owns how they reached that storage. Offline preflight and rollback consume that local store, not the repository
or a CI workspace. The predecessor remains retained until the new release is ready
and the rollback-retention boundary can safely advance. Missing inputs block
deployment before mutation; repository availability is not an offline guarantee.

### Offline source transport

Selected transport: qualify filesystem-backed registry/artifact locations in the
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
The local transport is a selected design, not a claim that an arbitrary rewritten
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
identity differs, phase 2 fails. Offline cplx reconstruction starts after consumer
delivery and recovery uses retained bundles; this CI acquisition path does not
relax either execution contract.

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

## Design decisions for v0.27.0 deploy-venv-sync

Human-authorized consolidation settles Q01 to Q09 after review round 4.
Scenario 1 is Q09 option C: operator-run publication outside CI. The selected
design retains all execution qualification gates and introduces no new questions.

| Question | Decision and rationale | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | B: Qualify filesystem transport first to avoid a server; retain loopback only as a qualified fallback with identical lock/integrity guarantees. | Offline source transport | Loopback as the default; unverified lock rewriting or frozen sync. |
| Q02 | A: Deliver a required digest-bound companion bundle, allowing independent retention and deduplication with complete-delivery preflight. | Release reconstruction bundle | Embedding all reconstruction inputs in each application archive. |
| Q03 | B: Qualify an unmodified static uv artifact first for one provenance identity; record separately hashed adaptation only if qualification requires it. | Qualified uv bootstrap | Target-specific adaptation as the default or conflating original and derived digests. |
| Q04 | A: Compose complete selection verification with the existing ELF helper, binding both reports to the same lock/profile/wheels and extending ELF scope compatibly. | Inventory and runtime boundaries | Replacing the established helper contract with an incompatible unified format. |
| Q05 | A: Require consumer serialization attestation plus demonstrated exclusion across the entire mutation interval, preserving the consumer's enforcement responsibility. | Current and target lifecycle; Packaging and recovery boundaries | Moving all archive and lifecycle locking into a new reusable lock owner; operator notes alone. |
| Q06 | A: Observe dependency command status and independent test-framework results with expected start/completion records and deliberate-failure qualification. | Two-phase CI integration | Inventory, coverage or an exit hook alone as proof of successful masked commands. |
| Q07 | A: Acquire existing phase 2 inputs from configured services and verify phase 1 toolchain/profile/wheel digests without prior-workspace access. | Two-phase CI integration | Depending on an unproven transfer of phase 1's bundle into the mandated agent. |
| Q08 | A: Promote the exact qualified candidate pair, protecting retention and binding all qualification evidence to its digests. | Qualification, publication and local delivery | Treating same-revision rebuilt bytes as qualified automatically; rebuild remains possible only with fresh qualification. |
| Q09 | C: Use a reproducible operator publication run outside CI, preserving the single mandated validation build and publishing only its qualified bytes. | Qualification, publication and local delivery; Two-phase CI integration | A publication-only mode of the same job or a separate publication job; neither is needed for the confirmed scenario. |

## File-based IO cost clarification for deployment reconstruction

Read the explicitly selected release manifest/index and referenced metadata
directly; do not discover state through documentation/history or unrelated
directory scans. Reuse parsed identity maps within a phase and walk only declared
archive/inventory roots. Retain required streaming hashes, integrity-boundary
checks and complete offline inputs. This batch workflow has no new latency SLO;
record phase timings without weakening byte-identity or readiness checks.

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
