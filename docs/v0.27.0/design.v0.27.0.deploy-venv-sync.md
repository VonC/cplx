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

The human amendment of 2026-10-03 adds original-orchestration delivery and
explicit recovery as AC16-AC17, with design Q10 and plan Step 8. Steps 1-7 have
recorded validation; this added consumer integration remains unimplemented and
requires a new candidate and actual execution evidence. Earlier decisions remain
settled context.

The 2026-10-04 amendment limits Step 8 to qualification and adds mandatory
Step 9 for first-time and production delivery, with AC18-AC19 and design Q11.
Step 9 execution starts only after actual AC16/AC17 closure. The topic remains
open until both added environments and their recovery boundaries are validated.

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
before directly orchestrating the mandated stages in the same Jenkinsfile.
Do not nest a second declarative pipeline or call the long-lived outer wrapper.

The human-approved workaround keeps agents local to the stages that actively
use them. Preserve the checks, stage order, audited test commands, coverage
transfer, analysis, quality gate and dry-run publication. Do not allocate a
redundant outer Python agent around the actual test agent; retain agents for
all workspace-dependent steps. In sandboxed audit closures, invoke Jenkins
steps through explicit script receivers. Copy SCM remote configuration into
maps through whitelisted getters instead of mutating private fields or using
deprecated non-whitelisted getters. Shared-library sources remain unchanged.
Successful qualification covers this direct orchestration; it does not prove
an infrastructure repair or qualify the original wrapper.

The directly orchestrated stage bodies mirror a recorded immutable library
revision. Each qualification records that revision and audits the copied bodies
against it. A library revision change requires a new audit of the copy and a
new qualification before its results can establish eligibility. Concrete
revision identities and comparison evidence remain in private integration records.

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

## Delivery through the original orchestration for v0.27.0 deploy-venv-sync

Human decision of 2026-10-03 adds consumer integration to the existing lifecycle.
The original orchestration's commands, ordering and inconsistencies are immutable
inputs. The sole operations change restores its complete application path to the
recorded baseline, preserving concurrent projects. No variable, role, template,
job, shared library, credential, network or privilege change or exception is planned.

### Fixed invocation and stable consumer code

The command module invokes a fixed relative launcher from the installation prefix,
without a shell or PATH lookup. Quoted generically, its command shapes are:

```text
nohup ./<fixed-launcher> ~/<stop-script> stop
nohup ./<fixed-launcher> ~/<start-script>
```

The declared deployment-script variable is unused. The role stops, downloads one
application archive into its literal staging filename, unpacks and copies its tree,
changes script permissions, and starts. Neither its declared URL nor port variable
provides a probe on this original standard path. Only the stop and start targets can enforce our lifecycle.

Install an executable host-Bash dispatcher at that fixed prefix name. Allow only
the literal home-relative stop argument plus exactly one stop operand, or the
literal start argument alone, and their recorded-account-home-expanded equivalents.
Reject all other arguments. Home is an argument identity, never a code location.
Use no home entrypoints, eval, PATH registration or general-shell link.

Dispatcher and targets ship in the existing application archive, but the role runs
stable versioned copies installed from a previous verified release. Store their
complete helper closure outside application, tools and staging trees. The existing
application wrapper that enters the replaceable application tree cannot alone
serve as that stable stop target. A strict installation helper checks realpaths,
ownership, modes and known managed identity before atomically switching the stable
version. A foreign existing launcher stops bootstrap for inspection. Mandatory
compatibility installation is fatal, even where ordinary convenience wrappers
retain warning-only refresh behavior. Refresh only after verified deployment
succeeds; the currently executing attempt pins its installed version.

That previous-release bootstrap describes Step 8. Step 9's narrowly guarded
first activation below installs the same verified control closure when no stable
version exists yet; it does not weaken subsequent refresh rules.

### Five-input acquisition and independent attempt control

The existing application archive remains the role's only artifact. Derive its
role URL from the selected query-free immutable asset URL plus the fixed
sort/direction suffix. Qualify identical hashes under both URL forms. Moving
version resolution, fallback sources, new transport objects and new registry
fields are excluded under the current contract.

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

Stop snapshots this selection under a short coordination lock into a durable
reservation outside staging. An active reservation excludes another attempt
across the separate stop and start processes. Start rechecks it under the existing
root deployment lock immediately before mutation. Define one lock owner across
the synchronous installer call so existing locking cannot deadlock or be bypassed.
Retain terminal failed/consumed status and require a fresh attempt for a new run.

In Step 8, stop rehashes the four inputs retained by the verified bootstrap and
fetches nothing; missing or mismatched retention refuses. General acquisition
for later Step 9 selections has stop alone fetch the four canonical inputs into
private temporary files, hashes them and atomically retains the verified bytes.
Only an exact-hash retained tools archive permits a skip; an installed version
does not. Parse the release record as ten unique allowlisted keys without shell
evaluation, and cross-check record hashes with the independent snapshot. Apply
bounded connection, transfer and total phase deadlines. Recovery/plain restart
and every start mode fetch nothing. Keep selection, attempt journal, last-working
checkpoint, logs and all recovery archives outside the role's rotating staging.

Before hold, record the delivered archive's file identity, not only content:
replacement by the same bytes must count as delivery. Record missing versus
unreadable paths distinctly and preserve enough filesystem identity to reject
ambiguity, including inode reuse or a concurrent replacement. The attempt's
last-working identity covers failures before any installer pending record exists.

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
3. For the Step 8 same-release deploy, rehash the four locally retained inputs
   against the bootstrap record without network; refuse missing or changed bytes.
   For a later Step 9 armed deploy, fetch the entry, release record, companion and tools
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
Only final success advances the last working release. Attempt use/replay prevention
is recorded independently of readiness: a failed deployment or recovery never
allows reuse of its signed identity. R16 restart closes only its own reservation.

Plain start applies these runtime and supervision checks to the current recorded
release. Recovery acquires the same root lock, uses the explicitly retained
predecessor's own entry with the existing offline rollback switch, then checks
that predecessor's identity through the plain-start gates. Both reconstruction
and historical shipped-environment predecessors remain reachable without network.
Failure before the installer or its pending record exists uses the attempt's
last-working checkpoint, not a guessed older predecessor. Recovery never changes
the original failed deployment result. Every mode keeps logs and receipts outside
staging.

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

### Runtime gate ownership and phase budgets

The consumer controller owns candidate/action/schema/URL validation and exact-byte
dry-run verification. Stable stop/start code owns target account/prefix/path/unit
identity, reservation, acquisition, mode choice, invocation and fatal propagation.
The existing deployment entry owns verified installation and retained predecessor
recovery; the existing first-start checker owns application and companion health,
revision/environment/disk/launch/no-drift checks. The hold helper owns verified
parking and release; runtime helpers own daemon identity and same-daemon observation.
Controller cleanup is scoped and cannot remove target recovery evidence. The private
mapping binds all sixteen former delivery-task responsibilities to concrete owners.

Start invokes the verified installer synchronously, carrying only verified record
values and private paths. It preserves the installer's failed-upgrade recovery
and nonzero result. Both APIs must pass while held before release. The observer
then verifies the same daemon account/PID/boot/start ticks; post-release failure
re-holds and fails. A unit restart while held must park on host sleep and cannot
replace the daemon or start the application.

Budget stop acquisition separately before downtime, hold parking within its
existing 55 seconds, bounded stop/no-survivors, held start/API verification,
hold release/observer and recovery. Reallocate the existing 600-second first-start
wrapper across the latter start phases; two additional five-minute waits cannot
fit. Use one monotonic deadline with phase caps and remaining-time propagation.
Qualification measures the chosen caps; it never silently extends an upstream
timeout. Transfer failure after successful stop leaves the durable held attempt
recoverable through the pipeline-launched original stop/start action, using the
fresh signed selection bound to the failed attempt/checkpoint. No operator is needed.

### Verification claim and fixed staging cost

**Verification claim: no unchecked byte is installed or run, and any mismatch
fails the deployment.** The fixed role downloads with certificate checks disabled
and unpacks before start, but executes nothing from that archive. Our scripts
never execute its unpacked tree or staging executables. They install only from
the privately copied, independently hashed downloaded archive and verified retained
inputs. Mismatch restarts the last working release and returns nonzero.
Retained recovery inputs, selection, reservation and journals live outside the
role's rotating staging tree. This does not claim that unchecked bytes never
reach the server.

Required tests prove that neither the role's unpacked tree nor a staged executable
is invoked, including archive members bearing lifecycle-script names. The start
target copies the retained downloaded file into its private attempt, hashes the
copy against the independent snapshot, and uses only that copy. Reject an archive
that changes during copying. Mismatch restores the checkpoint and returns nonzero.

The fixed staging loop rotates by basename per unpacked directory/top-level file,
then copies the whole tree and changes permissions per matching script in all
staging trees. The reference archive has 549 directories, 3,085 files, approximately
47 MB packed/81 MB unpacked, about 550 two-operation rotations and 86 permission
operations per tree including the previous tree. This occurs while stopped and held.
Measure actual job timeout, the 60-minute pipeline envelope, acceptable outage and
disk for downloaded/unpacked/current/previous copies plus our retained inputs.
Check mode skips the download and did not exercise this cost. Failure to fit stops
before restoration and is reported to the human; no alternative transport is planned.

### Evidence gates and ordered cutover

Step 8 tests one qualification deployment through the restored, unchanged original
orchestration. Its dispatcher, stable stop/start and control folders are installed
by the existing temporary delivery in Part C before restoration. No Step 8 action
depends on a maintenance shell or either Step 9 operator route; operations-team
involvement is only normal review of the agreed restoration PR.

Prerequisites include loaded source/project/execution environment, fixed defaults,
unit/closure identity, account-specific repository/shared-folder access and host
utilities. Before C, our development account on the qualification host gathers
network/client/shared-folder read-write evidence and replays filesystem staging
on the same disks. This is preliminary host evidence; application-account C probes
are final because proxy and permissions may differ. Return C receipts through
shared logs and console. Retained or separately authorized check-console timing
supplies per-task orchestration overhead multiplied by remote operation count.
Budget at least twice the sum of measured filesystem cost and evidenced overhead,
plus twice incremental disk demand beyond retained data. No replay measures the
orchestration itself. Missing timings or account receipts leave the gate open.

Qualify a new immutable candidate through the complete build and affected target
workflow, including release N's public key/verifier. C installs the closure/key
through existing delivery and returns probe, retention and activation receipts;
it arms nothing. D verifies these receipts and prepares the shared-drive signing
handoff; the human signs each actual attempt near its authorized launch. Normal
path-only restoration begins with fast-forward-only pull, preserves concurrent
ancestors and proves baseline equality, then checks the loaded restored revision
before switching our pipeline payload. Check mode verifies five controller bytes
and separately traverses the original check job without arming or consuming any
selection. Commands/downloads are skipped; directory creation may occur.

G redeploys C's same release with fresh signed authority each time, preserving the
older predecessor index and same-release checkpoint. H independently checks both
endpoints and shared receipts for revision, environment, account and same-daemon
unit observation. I uses a fresh signed recovery selection plus pipeline terminal
job proof and local lock/no-live-process proof before the original stop/start-only
action recovers offline. Native staging rollback is rejected. Failed recovery
requires another fresh signature for the same failed attempt/checkpoint, not an
older predecessor. Successful G creates no lingering conditional recovery; failed
external H uses an unsigned checked restart of the same installed release,
never rollback, retaining H's failure. Every operational phase has its own human
authorization. Step 8 has no operator fallback. Missing evidence stops, reboot
remains untested/nonblocking, and lost local configuration is a separate concern.

### Settled round 8 selection and outside-launch decisions

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

R17's bounded bootstrap count and non-expiring single-use authority are superseded
by a fresh signed selection per attempt. P29 separates selection identity from
reservation and success. Reserve the authenticated bytes atomically before hold;
prevent simultaneous reuse, retain spent identities on failure/interruption, and
admit only a new selection for retry/recovery. At an identified R16 start without
delivery, release the restart reservation and leave forward authority unused.
Expiry is checked on each new admission; an admitted reservation uses its bounded
monotonic execution deadline, not a renewed or ignored expiry. Q35/Q41 specify
atomic persistence and interruption fixtures. No new action parameter is added.

## First-time and production flows for v0.27.0 deploy-venv-sync

Human decision of 2026-10-04 extends the consumer integration after Step 8's
qualification-only AC16/AC17 closure. The original contract remains fixed in
each environment. No Step 9 role, variable, template, job, service-unit, access
or other operations change is planned. Missing prerequisites stop the rollout.

### Independently verified scripts-only bootstrap

Bootstrap is a separate, one-time target session before the environment's first
original-path deployment, never a pipeline step. The named responsible operator
works logged in as the application account on the target through the selected
existing access route described below. The original stop precedes delivery, and
delivery only unpacks into staging, so that path cannot install its first dispatcher.

Bind the selected registered, published application's exact archive to its source
and registry SHA-256 independently of target staging. Transfer that archive and
its independently bound digest/profile outside staging and replaced trees, verify
the whole archive on the target, then safely extract only the installation helper
and complete stable closure. Validate allowed members and their digests before
invoking any extracted code. No new published object is needed. The plan records
the archive transfer and command/receipt allocation as implementation questions.
No executable obtained solely from the target staging tree may bootstrap itself.
No application, tools tree or application environment is installed by this route.
Host Bash and the qualified host utilities suffice for control installation.

The helper prepares an immutable version and may first-activate it only under
the root lock, with no existing stable version, current pointer, foreign launcher
or unresolved attempt. Incomplete managed preparation may be reconciled only
against its verified bootstrap receipt; an ambiguous state fails closed.
Verify the complete closure, publish and verify its version pointer, then publish
the dispatcher last by atomic rename. A concurrent original-path stop before the
dispatcher exists fails at the role's stop task, leaving the historical runtime
untouched or the prefix empty; afterward it reaches the complete closure.
Retain a bootstrap receipt binding environment evidence, source archive, member
hashes, installed paths and the responsible operator.
That receipt proves control installation only, never application readiness.
For existing managed versions, maintenance still prepares only; activation
continues to require the normal final runtime and same-daemon success receipt.

The session orders guarded first activation, historical retention where needed
and dedicated non-dispatch inspection receipts. It installs the public key and
host-utility verifier without arming. Fresh signing on the shared drive is a
separate step for each real attempt after bootstrap; check traversal never arms.
Incomplete receipt-bound sessions resume only under the root lock. Premature
original deployment fails at missing dispatcher or incomplete-bootstrap gate
before lifecycle mutation. After completed bootstrap, missing signed authority
follows R19 ordinary admission only where lifecycle state permits. An empty prefix
has no working checkpoint, so no fictional restart or installation is allowed.
Later successful deployments activate their own stable closure without repeating
bootstrap.

This follows the human's preferred scripts-only direction. A full application
maintenance deployment is not silently substituted. If evidence makes this
route infeasible, report the design choice to the human before implementation
or rollout, with alternatives and their trade-offs.

Empty-prefix hooks option (i) is selected. On an independently evidenced empty,
inactive prefix, verified bootstrap installs hold-aware hooks with deployment
hold set before any unit execution. No application or tools installation occurs.
On an installed or running release, bootstrap leaves runtime, staging and unit
start/pre-start hooks untouched; historical bridging belongs only to the first
approved stop under hold. Unit configuration remains unchanged in all cases.

### Selected bootstrap access and shared-drive arming

Route (b) is selected for production and any new environment: an operations-team
operator runs our exact self-verifying commands as the application account once
for bootstrap. Route (a) is unavailable in production. This is an operator action,
not an access, privilege, unit, role, template or job change. Record the named
operator, existing account/host access and separately authorized session. Later
arming uses the human's workstation and shared drive, with no recurring operator
or pipeline shell access. Development rehearsals use our existing development
account and need no operations operator; Step 8 uses current delivery and original
pipeline actions and has no operator prerequisite or fallback.

The shared-drive trust and replay rules above apply in both qualification and
production. The production tree uses its own evidenced filesystem folder. No
private key reaches target or pipeline, and no verification key is downloaded on
first use. Replacement public keys can enter only through independently verified
closure updates. Q38 option A was confirmed on 2026-10-05: release N freezes
primary and offline backup public keys. Before B, document independent backup
custody/recovery and verified rotation/revocation; qualify the loss and rotation
fixtures before freezing release N. Never weaken signatures when a key is lost.

### Evidence-bound environment identity and runtime profiles

Keep one private, strict, non-executable environment profile and evidence receipt
for each target. Bind its digest into the independent selection and bootstrap
receipt. Record host, account, account home, real scripts/staging paths, loaded
unit user/start/pre-start identity, runtime endpoints, environment label and
existing managed job/template/source identity. The development replay profile
explicitly binds its development account/prefix and no-unit scope; qualification
and production reject it even if their unit is missing. Read observations through existing
authorized access; never copy qualification values into another environment.
Validate the account, folders, permissions and unit before installing control
scripts. Provisioning is pre-existing evidence, not an action this plan requests.

The current-format profile keeps every Step 8 revision, environment, disk/launch,
drift, component and same-daemon gate. A historical profile is explicitly bound
to verified predecessor bytes and observed supported interfaces. It combines
those health/environment responses with independent installed-file, tools,
launch/account and process-identity evidence. Missing modern API fields cannot
choose historical mode. If the available evidence cannot establish historical
identity and health, production remains blocked. Document unavailable fields
honestly; do not invent equivalent API coverage.

### Empty-prefix installation and no-predecessor failure states

An explicit first-install selection includes the evidenced empty-prefix state;
missing metadata alone never implies emptiness. Bootstrap is already complete.
Stop validates profile/unit and reservation, fetches the four exact pinned inputs,
records archive identity and an explicit no-predecessor checkpoint, then enters
or preserves the hold, parks the unit and proves there is nothing to stop.
Unexpected runtime files, a survivor or recovery metadata refuses first install.

After role delivery, deploy start uses the unchanged mode table, pinned stable
stop-only recheck, private archive verification, root lock and synchronous entry.
The entry follows its first-install path with no historical capture and a typed
no-target recovery value. All modern held runtime and supervision gates still
apply. Only full success creates the first last-working checkpoint and activates
the successful release's stable version.

Refusal before installer entry installs nothing; it cannot restart or roll back
an absent predecessor. Once held, failure remains held and non-ready. A fetch or
identity failure before hold preserves the evidenced empty/inactive state rather
than claiming an application is running. After installer entry, preserve failed
attempt, pending state and diagnostics; partial files are never treated as an
installed checkpoint. Explicit recovery with a no-target marker refuses held.
Plain start on an empty or failed first installation refuses, with no download.

A fresh first-install retry requires its own authorization, selection and proven
terminal ownership. Under the root lock, reconcile the prior pending/partial
state through the installer's dedicated first-install retry path, preserving its
evidence and removing or replacing only attempt-owned paths identified in its
journal. Unknown files or processes block retry. No generic directory deletion,
invented last-working identity or fallback to an older index entry is allowed.
If the installer completed but first readiness failed, an installer-written
current index is provisional for this first-install attempt, not a last-working
checkpoint. The same receipt-bound retry reconciliation handles that exact
index state without inventing a predecessor or retaining the release as its own
predecessor; an unassociated index fails closed.
If a later retry fails after installer entry and its pending recovery names that
provisional release, the typed checkpoint rule refuses recovery: the first-install
checkpoint still has no predecessor. The attempt stays held and nonzero, with
no restart or rollback.
Rehearsal must cover both preinstaller and partial-install failures and retry.

### Production historical retention and refusal or recovery checks

Before any production upgrade, inspect the actual installed historical release,
tools pairing, staging archives and completion markers read-only under separate
authorization. Validate complete bytes and provenance rather than trusting a
marker name or newest timestamp. Preserve any existing qualified retention.
The earlier isolated predecessor pairing is evidence only for that pairing.

If suitable staging inputs are absent, use existing maintenance access to retain
the exact historical application, its shipped environment, tools and own entry
from independently verified available archives. Bind the archive hashes and
historical runtime profile to observed installed identity. Prepare the existing
historical retention layout atomically outside staging under the root lock;
validate it with the same reader used by offline recovery. This explicit route
does not fabricate completion markers or rebuild archives from a live tree.
Ambiguous installed identity, unavailable exact archives or mismatched tools
blocks production. Include staging names used by the historical entry in the
existing collision gate.

Before deployment, rehearsal proves this exact retained pair upgrades and
recovers offline, with its own retained entry, on a production-like prefix.
Stable stop records the historical checkpoint before any mutation. Refusal or
failure before installer entry restarts that checkpoint with historical checks
and no rollback switch. After installer entry, recovery validates the typed
pending target against that checkpoint; the historical marker is valid only
with verified historical retention. No-target still refuses held. Repeat recovery
after restoration but failed health checks must not move to another predecessor.
Fixtures and read-only production evidence support historical unit/bridge safety;
development replay cannot prove parking or same-daemon observation. Those gates
remain mandatory at their first real production execution.

### Production approval, freshness and execution order

The consumer pipeline selects an already existing managed production job/template
whose loaded restored playbook is evidenced. Production uses only published,
qualified release coordinates, checked in both controller selection and target
reservation. Exact URLs and hashes remain bound throughout; approval waiting
never causes latest resolution or replacement candidate selection.

The unchanged operations approval precedes stop and can wait two hours. Before
arming, budget the full approval wait plus bounded controller/queue/dispatch,
deployment, verification and safety margins. Evidence must show that existing
outer job limits permit that envelope; only our pipeline's timeout is adapted.
Give the selection a bounded admission window covering this whole pre-stop wait,
then recheck expiry and profile identity when stop reserves it. Queue overrun or
late approval causes refusal before hold and requires fresh explicit arming.
The reservation then uses the Step 8 monotonic execution deadline, not the shorter
transfer expiry. No stop, hold or target prefetch belongs to the approval wait.

Check mode keeps the two existing verdicts and never arms. Treat production's
approval task as part of the immutable traversal: inspect its actual check-mode
behavior before authorizing that traversal, and never claim it runs target gates.
Approval timeout or cancellation requires proof of job termination before a
replacement run; neither alone authorizes a competing selection or recovery.

Order execution after Step 8 as environment evidence, consumer implementation
and new candidate qualification, empty-prefix rehearsal, exact historical
upgrade-and-rollback rehearsal, then production bootstrap/arming/check/real run
and external verification under their separate authorizations. Production real
execution also retains the operations pilot approval. Failure uses the qualified original stop/start recovery path with a fresh signed
checkpoint-bound selection and retained offline inputs, without an operator or
operations edit. Topic completion requires actual
AC18/AC19 evidence; the umbrella item remains pending meanwhile.

### Selected development replay and its evidence limits

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
| Original delivery with exact selected bytes | Four inputs verified before stop, application copy independently verified at start, synchronous installer and every former gate fatal | AC16 |
| Wrong candidate or a newer valid snapshot | Refuse installation; restore last working with checks and retain failed verdict | AC16, AC17 |
| Missing dispatcher or foreign existing launcher | Bootstrap/qualification fails before restoration; never replace foreign code implicitly | AC16 |
| Literal and expanded home arguments; unexpected arguments | Both specified forms dispatch to fixed stable targets; every other shape fails without executing it | AC16 |
| Delivery without matching deploy intent, deploy without delivery, recovery with delivery, unreadable/ambiguous state | Each refusal row installs nothing, attempts checked last-working restoration and exits nonzero; failed restart remains held | AC16, AC17 |
| Deployment-only stable stop recheck | Idempotent quiescence check uses the attempt-pinned stable closure, preserves reservation/archive baseline/checkpoint, fetches nothing and fails held before installation; ordinary start/recovery omit it | AC16 |
| Identical-byte archive redelivery | File replacement counts as delivery; no accidental plain-start classification | AC16 |
| Entry, record, companion or tools fetch/hash failure at stop | Application stays running; no hold or stop and no later role download | AC16 |
| Exact tools archive already retained versus installed version only | Reuse only the verified retained archive; same installed version still requires the archive | AC16, AC12 |
| Unit restart attempted while held | Verified unit remains parked and cannot replace the script-started daemon | AC16 |
| Role transfer or staging failure after stop | Fresh signed recovery for the failed attempt/checkpoint, pipeline job-terminal plus local terminal proof, offline restoration and original failure retained | AC16, AC17 |
| Canonical application URL and fixed rewritten form | Same expected SHA-256; no latest or moving-version fallback | AC16 |
| Dry run | Exact-byte controller verification and original check traversal recorded separately; no arming, no target-execution claim, possible directory creation disclosed | AC16 |
| Failure before installer entry/pending state | Attempt checkpoint restores exact last working release, without guessing an older predecessor | AC17 |
| Wrong unit identity, hold/parking failure or post-release observer mismatch | Fail at the owning gate; pre-stop hold failure releases/restores supervision, post-release failure re-holds | AC16, AC17 |
| Unpacked or staging scripts bearing lifecycle names | Never executed; only stable code and independently verified private inputs are used | AC16 |
| Native staging rollback or missing recovery inputs | Native action rejected; no network substitution for retained predecessor inputs | AC17 |
| Both predecessor formats with services unreachable | Explicit stable recovery restores predecessor with its own entry and identity checks; deployment failure persists | AC12, AC17 |
| Existing staging loop and inherited defaults | Actual timing, disk and defaults fit unchanged contract before restoration; unmet bound stops rollout | AC16 |
| Scripts-only first activation with no application | Independently verified complete closure, existing provisioning and empty managed-control state permit one atomic activation; no application readiness claim | AC18, AC19 |
| Existing stable version, foreign dispatcher or partial bootstrap | Normal refresh rules remain; foreign/ambiguous state refuses, interrupted preparation requires exact receipt reconciliation | AC18 |
| Original-path stop concurrent with first activation | Before dispatcher publication, fail at stop without runtime mutation; after verified closure/pointer and final atomic dispatcher publication, use the complete closure | AC18, AC19 |
| Historical unit restart between bootstrap and approved stop | Unchanged start/pre-start hooks run the historical runtime; only the first approved hold entry installs evidenced hook bridges | AC19 |
| Empty-prefix stop and deploy start | Four inputs verified before hold, no survivors, explicit no-predecessor checkpoint and verified first install; full modern runtime gates | AC18 |
| No-predecessor refusal, partial failure and fresh retry | No restart/rollback fiction; failed/held non-ready state, preserved evidence, terminal proof and attempt-owned reconciliation before new selection | AC18 |
| Failed retry names a provisional release as recovery target | Typed no-predecessor checkpoint rejects it; held nonzero failure with no restart/rollback | AC18 |
| Selected development replay without a unit | Exact task/baseline/argv/staging trace closes the rehearsed filesystem/lifecycle cases together with Step 8 managed proof; no managed orchestration or unit claim. Fixtures and route (b) production unit reads back first real production hook/bridge execution | AC18, AC19 |
| Production identity or access differs from qualification | Per-environment profile and observed unit/job/arming/repository evidence gate execution without change requests | AC19 |
| Missing historical staging archives or markers | Explicit exact-pair retention and production-like offline rehearsal precede upgrade; no fabricated marker or isolated-pair substitution | AC19 |
| Historical runtime lacks modern API fields | Explicit byte-bound historical profile with supported health and independent identity evidence; modern checks never downgrade | AC19 |
| Full approval wait, stale admission or snapshot coordinate | Existing approval stays before stop; bounded budget covers the wait, stale selections and snapshots fail before hold | AC19 |
| Production deployment or restored-runtime failure | Same-checkpoint offline recovery remains reachable, unknown survivors fail held and failed deployment stays failed | AC19 |

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
| Q10 | Human decision on 2026-10-03: preserve the original fixed orchestration; stable prefix dispatcher and targets absorb its commands, stop acquires four pinned inputs, start repeats the stable stop-only checks in deploy mode, installs only the independently verified application copy and enforces all lifecycle gates. | Delivery through the original orchestration; AC16-AC17; requirement Q11; plan Q10 | A new bundled transport object, native staging rollback as recovery, any orchestration-side change, account-home entrypoints or a general-shell launcher. |
| Q11 | Human direction on 2026-10-04: add scripts-only bootstrap through existing maintenance access with narrowly guarded first activation, explicit no-predecessor flows, per-environment evidence and exact historical retention/recovery profiles. Production keeps its approval wait, release-only contract and separately authorized rehearsals/execution. | First-time and production flows; AC18-AC19; requirement Q12; plan Step 9 | Temporary-task bootstrap outside qualification, silent full-application bootstrap, inferred first-install state, fabricated historical markers, qualification identity copied to production or any operations-side change. |
| Q12 | Human decisions at round 8 on 2026-10-04 supersede round 6 bootstrap arming: Step 8 remains operator-free, C installs closure/key/probes/receipts only, every G attempt/retry and I recovery uses a fresh short-lived shared-drive signature. R16 A restarts/checks the working release, releases its reservation and leaves pending forward selection unused. | Signed selection; Step 8 cutover; AC16-AC17; requirement Q13 | Bootstrap retry counts, non-expiring authority, reusable conditional recovery, operator fallback or inferred control of outside launches. |
| Q13 | Human decision 3 at round 8 on 2026-10-04 selects the human workstation key and fixed per-environment shared-drive delivery, exact five hashes/URLs, environment, single-use attempt/expiry and checkpoint-bound recovery. Release N ships public key/host-utility verifier, qualified in B and installed in C. Plan Q37-Q41 consolidate verifier evidence, offline backup trust, replay and envelope persistence; qualification evidence remains required. | Selection authentication; Step 9 arming; requirement Q14; Q37-Q40 | Artifact-repository arming objects, latest resolution, application-Python verifier, recurring operator arming or first-use fetched trust. |
| Q14 | Human decisions 4-6 at round 8 on 2026-10-04 select development replay on the qualification host, explicit DEV-only no-unit profile, option (i) hold-aware hooks under initial hold on empty prefixes, and one-time route (b) bootstrap for production/new environments. Installed/running bootstrap leaves hooks untouched. | First-time and production design; AC18-AC19; requirement Q16 | Claiming DEV proves managed/unit behavior, operations operator for DEV, repeated bootstrap/arming access, route (a) production or silent no-unit fallback. |
| Q15 | Human Part A addition at round 8 on 2026-10-04 uses development-account host network/client/share evidence and same-disk filesystem replay plus per-task orchestration overhead times operation count; C application-account probes remain final. | Cutover prerequisite budget; requirement Q16; plan A/Q19 | Treating developer proxy/permission evidence as application-account proof or filesystem replay as total orchestration timing. |
| Q16 | Human confirms R19 on 2026-10-05: ordinary admission has local exclusion/identity/checkpoint but no signed deployment reservation or share reread. Unauthorized delivery restores/checks and fails without installing; failed/held recovery gates remain. | Stop/start flows; confirmed admission; requirement Q17 | Signed restart payload or an impossible pre-lifecycle refusal guarantee for indistinguishable argv. |
| Q17 | Human selects Q38 A on 2026-10-05: verified closure carries primary and offline backup public keys, with independent custody and verified rotation/revocation. Fresh signing never bypasses replay, expiry or checkpoint checks. | Confirmed trust; shared-drive arming; requirement Q18; plan Q38 | Unevidenced trust rebootstrap as primary key-loss recovery or treating backup signing as automatic primary revocation. |

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
