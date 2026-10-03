# v0.27.0 deploy-venv-sync implementation tracking and validation

Yes, it is implemented.

All steps of the [implementation plan](plan.v0.27.0.deploy-venv-sync.md)
are implemented and validated, including the separately recorded actual
consumer integration. Step 3b retains its non-qualifying probe status; final
qualification and rollout are established by Steps 5-7. Step 7 closed on
2026-10-03 after authorized release publication, normal retrieval and offline
deployment and recovery. Each step states its evidence scope explicitly.

## File-based IO cost clarification for deploy-venv-sync implementation

Read the explicitly selected release manifest/index and referenced metadata directly.
Do not discover release state by scanning documentation, CI history or unrelated
directories. Reuse parsed metadata and identity maps within each phase; walk only
declared archive/inventory roots. Stream required artifact hashes and retain
before/after integrity checks. Offline inputs and diagnostics must survive
cleanup. This is a batch workflow: required wheel, archive and ELF IO remains
proportional to selected inputs, with existing deterministic sorting retained.

## Validation boundaries for deploy-venv-sync

Use the plan's per-step file list, physical-line baseline and shared execution
checklist. Apply the 650-line ceiling to Python, including blanks, and record
phase timings and scan counts without inventing an elapsed-time SLO.
New scripts and standard-library unit fixtures follow cplx's native harness;
configured consuming-project checks use groundhog. Native CI and actual Debian/
RHEL/backend acceptance retain their separate execution evidence requirements.

Keep public outcomes generic. The private local mapping supplies concrete
consumer files, revisions, build/agent/operator identities and receipts.
Every qualifying result must identify the exact candidate pair, toolchain,
canonical/effective locks, profile, wheels and predecessor as applicable.
A passing fixture is not evidence that the corresponding target case executed.

## Step 1. Qualify release inputs and locked offline transport

### Analysis of Step 1 implementation state

Yes. Step 1 has been fully implemented.

Manifest-driven qualification passed on Debian 12 and RHEL 9.8 with the same
original static uv 0.12.17 and accepted tools archive, using shipped Python
3.13.15. Consumer acquisition/provisioning and tooling-lock changes are complete;
cumulative native checks and the consumer groundhog objective passed. Concrete
private revisions, build identities, receipts and source comparison remain in
the required local integration handoff. Review round 1 found an unusable-loopback
precondition gap; the writer fixed it and repeated the cumulative native checks
before requesting round 2.

### Goal for Step 1

Deliver and qualify the reconstruction bundle and release-pinned uv before depending on them in deployment.

### Step 1 improvement expectations

Check the independent tools version/digest and helper member schema, non-circular generated records and missing/tampered fixture payload rejection.
Review this validation file as a per-step update target; keep unchecked evidence fields empty until implementation-check runs.

Both supported targets prove the delivered uv executes and the selected transport supports locked/no-build/no-project-install synchronization. If neither designed transport works, stop for design review; static schema tests cannot complete this step.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 1

`deploy_venv_inputs.py` verifies explicit local inputs, independent application
and tools identities, immutable helper revisions, wheel hashes and workspace
metadata closure. It assembles and verifies a companion with an exact regular-file
inventory and generates the non-circular outer bootstrap record. Duplicate JSON
keys, unsafe or duplicate members, symlinks, changed bytes and overwrites fail.

`deploy_venv_transport.py` creates a new effective metadata workspace and changes
only mapped location values. Structural inverse comparison and canonical byte
checks preserve dependency, version, group, marker and artifact identities before
and after synchronization. Documentation URLs remain unchanged.

`deploy_venv_probe.py` checks the explicit interpreter, profile, uv version/static
linkage and current network namespace. It binds and connects a loopback socket
before attempting transports, rejecting an unusable loopback as an environment
error rather than a design failure. It attempts a real file Simple index with
`--offline` first, then the approved allowlisted loopback fallback. Every sync
has its own empty cache and environment and uses `--locked --no-build`, explicit
Python, disabled Python downloads and no project/workspace installation.

Both targets passed the loopback path; the file attempt exited 1. Missing wheels
and stale locks exited 1, and incompatible wheels exited 2. Retained diagnostics
confirm absence of a usable binary distribution for the incompatible-wheel case.
Only loopback was present and external connection failed with ENETUNREACH.
The installed fixture inventory was packaging 25.0. Complete application
selection and wheel ELF equivalence remain Step 2 responsibilities.

Consumer P01-P05 now use the confirmed acquisition source and digest-pinned
original uv, preserve P16, and exercise the P17 fixture record. The production
bootstrap verifies the original wheel and executable before installation;
canonical lock regeneration changes only the tooling pin. Frozen qualification
sources have explicit digest and Python syntax checks, plus native execution.
Production P17 assembly remains Step 4.

| Validation evidence and scope | Result |
| --- | --- |
| Native cumulative `verify.deploy-venv-sync.sh --step 1`, with explicit Python and consumer root | After round 1 repair: 108 tests, 23.583 seconds; syntax, mandatory Bash lint, ShellCheck and 650-line scan passed |
| Debian manifest acceptance | Passed, 8.595 seconds; isolated locked loopback sync and all three negative cases |
| RHEL manifest acceptance | Passed, 9.480 seconds; isolated locked loopback sync and all three negative cases |
| Focused consumer CI execution | Passed in 10 minutes 27 seconds, including production uv acquisition and archived manifest evidence |
| Consumer `ghog day` | Static checks, affected suite and full suite passed; full stage 5 minutes 46.4 seconds, 6544 collected, fail=0, warn=8, xfail=8, cov=100, outliers=0, excluded=0 |
| Step source inspection and `git diff --check` | Passed |

The plan records the runnable native command forms. Exact substituted commands,
canonical/effective inputs and raw logs are retained privately. Qualification
does not invoke the later single-build CI sequence or publish a release.

The two new regression tests failed before the repair and passed afterwards:
bind/connect failures report an unusable namespace, while a real loopback socket
connection succeeds. The Debian/RHEL acceptance and consumer results above
predate this precondition-only repair. They were independently confirmed in
round 1 and were not rerun: synchronization behavior and qualified inputs are
unchanged. The consumer's frozen qualification snapshot remains at that tested
revision. No fresh platform qualification is claimed for the repaired helper.

Physical counts include blank lines. New public files have baseline 0:

| File | Final lines |
| --- | --- |
| `deploy_venv_inputs.py` | 282 |
| `deploy_venv_transport.py` | 186 |
| `deploy_venv_probe.py` | 315 |
| `test_release_inputs_tdd.py` | 276 |
| `test_release_inputs_pbt.py` | 25 |
| `test_native_probe_tdd.py` | 99 |
| Three new package markers | 0 each |
| Native verification shell entry | 40 |
| Native acceptance shell entry | 31 |

Private counts: P01 329, P02 23, its new Python delegate 118, P03 116, P04 301,
P05 1337 and unchanged P16 1. New consumer test modules are 71 and 30 lines.
All involved Python files are below 550 and the enforced 650-line ceiling.
The validation document baseline was 343 lines; its final count is recorded
with the check evidence. Shell, lock and documentation sizes have no Python gate.

### New types or classes introduced for Step 1

Public helpers use focused functions. The probe's nested HTTP handler serves only
declared files and generated pages and is disposed with its server/thread.
The consumer bootstrap adds a restricted redirect handler and Simple-page link
parser; neither enters application domain code. Unit fixtures introduce release
input, transport, generated-property and probe test cases.

### Architecture check for Step 1

Manifest verification, transport rewriting and native qualification have separate
modules. The transport dispatch loads the delivered probe lazily; the probe
reuses transport preparation without import-time execution. Shell entries only
validate explicit arguments and invoke shipped Python. Consumer acquisition
stays outside reusable cplx reconstruction; no domain layer imports these tools.
Helpers are delivered by explicit path rather than discovered through PATH.
No architecture or file-size issue needs addressing.

### Performance check for Step 1

Identity maps and metadata visitors process their declared inputs linearly.
Archive hashing and transfer are streamed, with deliberate repeated checks at
transfer boundaries. Generated Simple pages cost the size of the declared
registry/package output, without searching history or unrelated trees. No new
sorting or pairwise dependency comparison was introduced. Native timings above
include synchronization and negative cases; they are observations, not an SLO.
No performance issue needs addressing.

### Unit test coverage check for Step 1

The unit fixtures cover independent pins, missing/corrupt inputs, duplicate keys,
safe extraction, exact member closure, workspace/local-source metadata, wheel
identity, transport inverse preservation, documentation URLs, unsafe mappings,
source drift, native prerequisites and allowlisted GET/HEAD behavior. Generated
tests exercise 24 transport permutations and identity-changing mutations.

The consumer's 100% coverage result measures only its configured application
source root. It does not measure the standalone CI scripts, frozen fixtures or
cplx helpers. No percentage is claimed for those files. Static reference review
finds every public top-level helper used by another helper, its CLI guard or
unit fixtures; the probe is reached through the transport dispatch. Consumer
bootstrap functions/classes are referenced by its acquisition entry or tests,
and transport functions by its CLI/tests. Real platform acceptance additionally
executes acquisition and sync, without being counted as unit coverage.

No measured unit-tested class below 100% needs completing. No top-level symbol
in the unmeasured implementation files is unreferenced.

### Feature integrity for Step 1

The independently accepted tools archive and pin remain unchanged. Existing
wheel/installer behavior and reporting interfaces were not modified. Cumulative
tests retain earlier release and transport checks. Canonical metadata remains
immutable, and evidence is separate from frozen release inputs. The consumer's
unrelated local changes were preserved. Later deployment naming, readiness,
recovery, publication and complete-candidate qualification remain unimplemented
under Steps 2-7, not implicit claims of this Step 1 result.

## Step 2. Verify complete dependency selection and wheel ELF identity

### Analysis of Step 2 implementation state

Yes. Step 2 has been fully implemented.

The qualified selection is checked against the canonical lock, target profile,
retained wheel hashes and installed distributions. The compatible wheel inventory
checks ELF files in site-packages and wheel-provided bin locations. Native target
tests and acceptance, the inherited compatibility regression, and the consuming
application's full CI test and coverage run passed. Runtime provider qualification
belongs to a later step.

### Goal for Step 2

Compare complete installed distributions and all wheel ELF locations against the same canonical lock, target profile and retained original wheels.

### Step 2 improvement expectations

Capture fixture provenance: qualified uv version, toolchain digest, selected profile and source revision; refreshed oracles must remain traceable.
Review this validation file as a per-step update target; keep unchecked evidence fields empty until implementation-check runs.

Old helper clients still pass, and complete selection plus ELF checks reject each deliberate drift in both library and bin locations. Runtime provider qualification remains a later acceptance gate.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 2

- `deploy_venv_selection.py` validates qualified uv selection provenance,
  marker/group/extra closure, wheel identity and tags, and the exact installed
  distribution set. It emits lock, project, toolchain, profile and wheel-manifest
  digests.
- `tools_wheel_inventory.py` adds opt-in schema 2 capture for wheel ELF files in
  site-packages and `bin`, while retaining the schema 1 capture, materialize
  and describe interface. It checks original wheel and installed ELF hashes,
  collisions and unsafe paths.
- The native acceptance script composes the separate selection and ELF reports
  against one lock and profile. The cumulative verifier includes Step 2 tests
  and the unchanged compatibility regression. Unit fixtures cover deliberate
  selection and ELF drift, including generated mutations.
- The consuming application's provisioning and acceptance path retains the
  qualified selection and original wheel identities. Its full CI test and
  coverage run and native target fixture acceptance passed with publication off.
- Two inherited native-Linux integration test classes now skip on Windows;
  their Linux execution remains covered by the cumulative native harness.

### New types or classes introduced for Step 2

No production class or type was introduced. The new selection module uses
focused functions and a JSON profile; the inventory retains its function-based
interface.

### Architecture check for Step 2

Selection and ELF inventory remain separate command-line helpers. Their JSON
identity binding keeps the domain decision independent of the consuming
application's shell adapters. No incorrect layer import or misplaced behavior
was found. Nothing needs fixing.

### Performance check for Step 2

Selection uses identity maps and one installed-distribution walk. ELF capture
streams each retained wheel and walks the declared installed roots once;
hashing work scales with required input bytes. Tag expansion and deterministic
sorting have bounded selection-size cost. No performance issue needs addressing.

### Unit test coverage check for Step 2

The new production helpers are function-based, so no unit-tested production
class has a per-class coverage target. Focused TDD and generated-mutation tests
exercise selection, profile binding, installed metadata and library/bin ELF
checks; inherited tests exercise schema 1 clients. The cplx native unittest
harness has no configured coverage percentage gate for these helper files, so
the consuming application's passing coverage gate is not attributed to them.
Static reference inspection found every new top-level helper used by its own
module or its tests. No unit-tested class below 100% needs completing. No
top-level symbol outside a coverage gate is unreferenced.

### Feature integrity for Step 2

The independent qualified-uv profile records uv version, toolchain digest,
source revision, target markers, effective groups and wheel hashes. Selection
rejects missing, extra, duplicate, wrong-version, wrong-tag and hash-drifted
distributions while respecting excluded markers. Schema 2 rejects changed
site-packages and bin ELF files and duplicate destinations; schema 1 clients
and the existing compatibility regression still pass. The native cumulative
harness passed on the target OS, and the consuming application's full CI run
passed its tests and coverage with release publication disabled. The local
cplx groundhog walk passed affected and full tests but had no configured
coverage-total line; the native cumulative harness is the cplx repository's
specified equivalent. The consuming application's duration-only groundhog
exception was accepted for Step 2 only and does not extend to later steps.

## Analysis of Step 2 Implementation

Step 2 now binds one explicit qualified dependency selection and every retained
original wheel to the installed distributions and ELF subjects. The new
selection helper validates lock closure and installation identity; the opt-in
inventory extension verifies wheel ELF identity in both library and bin
locations. The native verifier and acceptance entry cover the new path while
preserving existing helper behavior. There are no new production classes.

## Step 3. Implement exact-path reconstruction and readiness

### Analysis of Step 3 implementation state

Yes. Step 3 has been fully implemented.

The exact-path lifecycle and consumer P01/P07 wiring pass the Step 3 native
verifier, direct acceptance with a console-script wheel on first and repeated
targets, and the record-backed companion path. The finite state matrix covers
the selection, target and failure boundaries, including an early Bash failure
after a previous ready record and a foreign venv interpreter link.

### Goal for Step 3

Create or synchronize only the full-version named environment using the selected shipped interpreter and qualified local inputs.

### Step 3 improvement expectations

Check bootstrap on a target without new helpers installed: verify before extraction, use absolute delivered paths, reject PATH fallback and absent/corrupt members.
Review this validation file as a per-step update target; keep unchecked evidence fields empty until implementation-check runs.

The returned exact path is used for creation, sync, tests and readiness; every failure leaves the operation not ready. Native fixture integration verifies runtime-boundary handling and consumer serialization attestation.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 3

The Linux entry selects the shipped interpreter by absolute path, derives one
full-version venv path, validates or creates only that target, verifies the
qualified local inputs, runs the release's absolute uv with ambient selection
disabled, and records operation-bound readiness or the first failure. The
consumer P01 and P07 paths verify the delivered bundle, dispatch the entry by
absolute path, use its returned `VENV`, and retain the application-root
serialization boundary across mirroring, reconstruction and readiness. P01 and
P07 each reread the ten-key release record at their own integrity boundary;
their grammars agree. The native verifier and acceptance mode now cover Step 3.

The RHEL 9.8 target passed the cumulative `--step 3` verifier with 189 total
unit cases. Direct acceptance used the shipped runtime with host/PATH/activation
decoys and an offline wheel that installs `bin/pygmentize`: first and repeated
runs each recorded two installed distributions and the exact venv Python
shebang. The P07 record-backed companion path repeated that result and passed
all 11 readiness checks. The earlier historical no-record recovery path also
passed. The full-mode Debian 12 agent build 198 passed Provision, Package and
Test with publication skipped; its acceptance reported 100% configured source
coverage. P01/P07 bytes did not change during review repair, so that agent
build was not repeated. The consumer `ghog day --force` passed 6,546 tests
with 100% configured source coverage and no duration outliers. Exact input
identities, commands and artifacts are retained privately under AC13.

### New types or classes introduced for Step 3

No new production class or type. The lifecycle is a focused Bash entry with
embedded Python functions. The unit fixture is split into two modules by
responsibility, with the original 11 cases and 21 additional matrix cases.

### Architecture check for Step 3

The consumer retains archive and lock ownership; the cplx entry performs only
the verified venv lifecycle and delegates selection, transport and inventory
to the existing helpers. No application domain layer imports a deployment
adapter. The shipped runtime boundary is explicit, and host archive utilities
stay outside its exports. No architecture fix is needed.

### Performance check for Step 3

The path is computed from one shipped interpreter and one release identity.
Declared inputs and inventories are walked once per phase; rereads occur at
separate integrity boundaries. No new quadratic or sorting-driven discovery
path was found. The named host runs completed without a new timing gate.
No performance fix is needed.

### Unit test coverage check for Step 3

The original 11 lifecycle unit cases cover exact naming, suffix escape,
target symlink and foreign base, wrong prefix and version, selection flags,
ambient environment sanitizing, command failure logs, readiness revocation
and serialization attestation. The 21 matrix cases cover symlinked venv Python
with an accepted console shebang; foreign shebang, configuration home and
stdlib; matching and foreign `bin/python3` links; equal-version toolchain
change; zero or several shipped Python
candidates; directory and running-interpreter mismatch; unbound profile and
metadata drift; source preparation and final inventory checks; stale lock,
missing or corrupt wheel, interrupted or failed sync and failed post-sync
check; repeat and mirror-removed targets; parent escape; and the Bash shipped
Python selection and an early Bash failure after an earlier ready record. The
matrix stubs command execution for finite failure rows. The RHEL cumulative
native harness passed all 189 unit cases. The consumer's
100% gate measures only configured application source (`src/pdfss`), not these
Bash entries, embedded Python, or P01/P07. The real target acceptance reached
the console-script branch. No production class is below a class-level coverage
target, and no top-level symbol outside the configured gate is unreferenced.
No unit-tested class below 100% needs completing. No top-level symbol outside
the configured coverage gate is unreferenced.

### Feature integrity for Step 3

The record-backed path intentionally omits Git restoration: Step 3 item 6
requires replacing the new path's Git restoration, and the design's
"Packaging and recovery boundaries" states that delivered metadata is used
directly without Git restoration or a smudge filter. The historical no-record
path still restores tracked content and checks repository cleanliness on the
RHEL target. The consumer's directory, artifact and readiness contracts passed
the Debian 12 agent build. ShellCheck passed for the edited script. The cplx
`ghog day` wrapper passed its check step, then stopped at its non-applicable
pytest step because this repository has no pytest project configuration; no
cplx coverage result is claimed. The plan names the native cumulative harness
as its repository-specific equivalent, and that harness passed on the target.

## Analysis of Step 3 Implementation

Step 3 now reconstructs one manifest-bound full-version venv using the shipped
Python and qualified offline wheels. The entry invalidates any earlier ready
record before handing off to the lifecycle, verifies all venv interpreter
links and console-script shebangs, and retains operation-specific evidence.
The consumer keeps archive and lock ownership and uses the exact returned
`VENV` throughout readiness. The native verifier, unit matrix and real target
acceptance cover creation, reuse, console scripts and failure boundaries.
There are no new production classes.

## Step 3b. Probe the mandated pipeline on actual agents, non-qualifying

### Analysis of Step 3b implementation state

Yes. Step 3b has been fully implemented.

Probe builds 201 (part A) and 205 (part B) ran on actual agents, reached the
mandated pipeline and proved publication was not invoked. Part B found that
P01 could not reconstruct the named venv on the test agent, so its commands ran
against an implicit environment. These are non-qualifying findings for Step 5.
Default-mode build 206 exposed a probe-switch regression before any stage;
after P10 was restored byte-for-byte, build 207 succeeded with the same stage
names and statuses as pre-probe build 198, including publication skipped.

### Goal for Step 3b

Reach the mandated pipeline from the one consuming Jenkinsfile on actual agents, with publication disabled, and record the facts the Step 5 adapter is built on.

### Step 3b improvement expectations

Check that the default CI mode and its publication behavior are unchanged, that the probe build proves no publication command ran, and that the recorded publication setting is the value the library resolved.
Check that part A records hook propagation, agent identity, working directory, checkout revision against the build revision, resolved interpreter and uv, created or selected environments, and real exit statuses including one deliberate test failure.
Check that part B, after Step 3, records whether the venv reconstructed through P01 is selected by the library's commands without drift.
Review this validation file as a per-step update target; keep unchecked evidence fields empty until implementation-check runs.

At least one probe build of each part ran on actual agents and every expected observation is recorded, successful or not. Step 3b qualifies no candidate, proves no AC row and cannot complete Step 5.
Review the plan's file-by-file changes and its mapped private obligations.
Public entries stay sanitized; exact builds, agents, library revision and command mechanics stay in the private handoff.
Record each observation handed to Step 5, with its sanitized outcome, under "What was implemented for Step 3b".

### What was implemented for Step 3b

- P10 and P11 probe changes were committed separately in the consumer and
  pushed to its CI remote before each build. The dedicated probe branch retains
  the pipeline call; P10's default path was restored byte-for-byte after the
  probes, and the deliberate failing test was removed from the default branch.
- Part A build 201 and part B build 205 each ran the preliminary provisioning
  allocation followed by one mandated pipeline call in the same build.
- Both builds recorded the loaded pipeline revision, actual agent identities,
  stage durations and final result; allocation waits were not reported.
- In both builds the test-agent checkout matched the build revision, and P11
  ran once in the workspace root after checkout and before dependency commands.
  It did not initialize outside the test step or again in child shells.
- Part A recorded the host interpreter and tool version, an implicit project
  environment, synchronization status 0 and fixed activation status 0.
- Part A recorded requirements installation status 2 because its input was
  absent, and the deliberate test failure status 1 masked to shell status 0.
- Part B verified that its independently fetched toolchain archive matched the
  digest passed from phase 1, but P01 preparation exited 127 because a fixed
  host interpreter path was unavailable on the nested test agent.
- Part B recorded that the Step 4 reconstruction companion was not yet
  available (release-path status 2), so no named venv or verified alias was
  prepared and zero drift against that environment could not be demonstrated.
- Without reconstruction, part B synchronization status 0 selected the host
  interpreter and created an implicit project environment; fixed activation
  status 0 then selected that environment and changed the resolved tool version.
- Part B requirements installation returned 0 against the implicit environment
  and left its 80-package inventory unchanged; this does not establish a no-op
  against the required named venv.
- Part B's 12 focused unit tests passed, but the whole-project coverage gate
  made the real test command exit 1; the mandated command masked it to shell
  status 0, and the final build result was SUCCESS.
- In both builds the effective publication-disabled setting was confirmed,
  the job had no overriding publication parameter, a distinct POM was generated,
  and the deployment command was explicitly skipped and never invoked.
- Default-mode build 206 failed before any stage because the fallback switch
  changed declarative execution. P10 was repaired to its pre-probe bytes;
  build 207 then succeeded with the same ordered stage names and statuses as
  pre-probe build 198, including the consumer's own publication stage skipped.
  No publication command ran in either default-mode check.
- Full console, stage and archived P11 records are retained privately for both
  builds. The failed preparation, implicit environment and masked test status
  are explicit inputs to Step 5 items 2, 4 and 6; no shared-library source
  changed. Step 3b qualifies no candidate and proves no acceptance criterion.

### New types or classes introduced for Step 3b

None. P10 and P11 are consuming scripts; the deliberate failure is a
probe-only test, with no new production class.

### Architecture check for Step 3b

The probe keeps orchestration in P10 and test-shell observation in P11. It
adds no cplx source dependency or domain-layer import. The observational
fallback is confined to probe mode; Step 5 must fail closed when preparation
or outcome observation fails. No Step 3b architecture fix is needed.

### Performance check for Step 3b

P11 writes one bounded record per build from named command boundaries. The
complete probes took 354.376 and 313.791 seconds; their stage durations are
retained privately. No new project-tree scan or quadratic operation was added.
No Step 3b performance fix is needed.

### Unit test coverage check for Step 3b

No cplx production class or Python symbol was changed. The consumer's
configured coverage gate measures its application source, excluding P10, P11
and the probe-only failing test. The focused 12 tests in build 205 passed, but
19.31% whole-project coverage missed its 100% gate; that is a masked-command
finding, not a coverage pass. The cplx groundhog walk passed its check phase
and stopped at the non-applicable pytest phase because cplx is not configured
as a pytest project. No unit-tested class below 100% needs completing for
Step 3b. No top-level symbol outside the gate is unreferenced.

### Feature integrity for Step 3b

The consumer's original full-mode P10 bytes were restored after build 206
showed that the probe switch broke declarative execution. Build 207 succeeded
with the same ordered stage names and statuses as pre-probe build 198, including
the consumer's own publication stage skipped. That stage was absent from probe
mode. Both complete probe builds confirmed the mandated publication stage
skipped deployment, while their final results and masked command failures were
recorded separately. The broader consumer suite did not pass in the additional
part B run because browser prerequisites were unavailable; Step 5 retains the
full-suite and truthful-failure gates.

## Analysis of Step 3b Implementation

Step 3b made the consuming pipeline and adapter observable on actual agents.
Both parts ran in one build each with publication disabled, and their private
records cover the hook, revision, command statuses, agent allocation and final
results. Part B established a precise incompatibility with the named-venv
reconstruction path; it did not qualify an environment. The first default-mode
check found a regression, which was repaired and verified by build 207 against
the pre-probe stage sequence. No cplx source or shared-library file changed.

## Step 4. Package without venvs and wire retained deployment recovery

### Analysis of Step 4 implementation state

Yes. Step 4 has been fully implemented.

The application archives exclude discovered venv roots. Complete release
inputs, including every required helper, qualify before mutation and are
retained outside the mirror for offline recovery. The RHEL 9.8 target passed
the cumulative verifier and acceptance after the round 1 repairs. Debian 12
agent build 210 proved the unchanged packaging bytes in the default pipeline.

### Goal for Step 4

Produce venv-free application archives and support serialized offline reconstruction and both predecessor recovery paths. Consumer acquisition is separately tracked.

### Step 4 improvement expectations

Apply the human-approved consumer delivery/cplx reconstruction boundary. Verify complete local files before mutation and reject missing or invalid inputs without fetching. Run cplx with remote services denied from entry, empty disposable caches and no target Git checkout. Record independently validated cplx work separately from pending consumer acquisition/integration evidence; a mixed step and the overall topic remain incomplete until their required integration evidence exists.

Check production helper assembly and supplied script/record/companion/tools identities. Test independent application/tools versions, missing/truncated/wrong-digest local inputs rejected without fetching before mutation, and retained predecessor helpers/tools with no network. Consumer acquisition cases are maintained privately.

Archive inspections find no packaged application venv and both local recovery paths work with remote services denied and empty caches in the controlled integration fixture. Actual RHEL qualification remains step 7.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 4

- `deploy_venv_archive.py` discovers `pyvenv.cfg` roots once in declared
  packaging roots, supplies exclusions to the existing packager, rejects unsafe
  tar rules and inspects the completed archive. The consumer's packaging and
  assembly routes use the same discovery and retain their archive coordinates.
- `deploy_venv_inputs.py` assembles helpers and runtime support from a pinned
  cplx revision. Its non-circular release record identifies the entry script,
  companion and independent tools archive with exact checksums. Production
  verification requires the full helper closure even when the entry helper is
  omitted from a candidate manifest.
- `deploy_venv_release.py` validates complete local inputs, publishes a record
  only after qualification, and selects current or predecessor inputs. The
  consumer owns staging of immutable retained copies. Readiness gates
  promotion, and an explicit application archive prefix keeps retention names
  independent of application naming.
- `install_pkg.sh` accepts an explicit absolute archive path for the retained
  installer. The Step 4 rule to ignore unrelated newer archives requires this
  option, and the shipped installer is part of the complete helper closure.
- The consuming deployment route validates supplied files before mutation,
  keeps one root lock through mirroring, install, reconstruction and readiness,
  and reconstructs from retained inputs after mirror deletion. It also retains
  the historical first-transition path with its shipped venv and no modern
  record requirement. Consumer changes were committed separately.
- The cumulative native verifier passed on the RHEL 9.8 target with 210 broader
  tests, shell lint, tools release gate and line/syntax ceilings. Acceptance
  passed after the repairs with host interpreter and PATH decoys. Controlled runs refused missing,
  truncated and wrong-digest inputs before mutation without fetches; exercised
  modern and historical offline rollback, mirror deletion, competing root
  operations and independent roots; and passed the 63-case installer regression.
- Debian 12 agent build 210 succeeded on the packaging bytes, which the review
  repairs did not change, with
  publication disabled. Its default-mode stage sequence matched build 207;
  its package and assembly member lists matched at 3,529 entries with no
  `pyvenv.cfg`. All 1,406 archived evidence entries were captured.

### New types or classes introduced for Step 4

No class hierarchy was added. The new scripts provide focused functions for
archive discovery and inspection, release-input qualification, retention and
CLI dispatch. The existing input helper gained pinned helper assembly and
release-record generation.

### Architecture check for Step 4

Packaging, release-input validation and retention remain separate script
boundaries. The consumer orchestrates acquisition, installation and readiness;
cplx validates supplied local inputs and performs reconstruction. No business
layer was made dependent on a platform adapter. No Step 4 architecture fix is
needed.

### Performance check for Step 4

Venv discovery walks only explicitly supplied roots once, then shares the
result with exclusions and the assembly descriptor. Archive inspection and
hashing are linear in selected input size; retention reads only referenced
records. No repeated repository or release-history scan was added. No Step 4
performance fix is needed.

### Unit test coverage check for Step 4

The archive/recovery and release-input unit folders exercise the new helper
functions through discovery, unsafe-path, record, companion, retention and
rollback cases. The focused Windows run passed 11 archive cases with two
Linux-only cases skipped, and 30 release-input cases; the native cumulative
verifier exercised the Linux path. There are no new classes with a class-file
coverage target. cplx is not configured as a pytest project: its groundhog
check passed, then stopped at the expected non-applicable pytest phase. The
consumer's 100% configured gate measures application source only and excludes
the changed deployment and packaging scripts; their exercise is established
by the focused and native checks, not by that percentage. No unit-tested class
below 100% needs completing. No top-level symbol outside the gate is
unreferenced. The pinned helper staging and exact installer archive selection
now have focused cases, including the Linux installer path on the target.

### Feature integrity for Step 4

The accepted tools archive and installer relocation exclusions remain intact.
The consumer's default pipeline file stayed byte-identical to build 207's
baseline. Build 210 succeeded with publication off and the same stage names
and statuses; Package and Test passed and Publish was not executed. Release
inputs are retained independently of mirrored application files and CI or uv
caches. Missing local inputs do not trigger a fetch or advance predecessor
protection. Publication eligibility remains Step 6 and actual target
qualification remains Step 7.

## Analysis of Step 4 Implementation

Step 4 packages the application without any venv and gives deployment a
complete, locally verifiable set of release inputs:

- The archive helper discovers venv boundaries once in the declared packaging
  roots. It feeds literal exclusions to the existing packager and to the
  assembly descriptor, then rejects any produced archive that still carries a
  venv.
- The input helper stages the complete helper and runtime closure from one
  exact revision and requires that closure on every production path. It
  writes the non-circular release record.
- The release helper checks the record and every supplied file before
  mutation, and publishes a record only after qualifying it. It reads the
  explicit current or predecessor inputs and promotes a candidate only after
  readiness.
- The installer accepts one exact archive, so an unrelated newer archive
  cannot be selected.

The consumer owns retained staging and its root lock. No class hierarchy was
added; the new helpers are focused script functions.

## Step 5. Integrate and qualify the single-build CI sequence

### Analysis of Step 5 implementation state

Yes. Step 5 has been fully implemented.

The repaired eligibility validator passes native verification and acceptance.
Actual agents qualify all four deliberate failures under the approved direct
orchestration, followed by a fully captured successful default build. Its exact
source, immutable library, ABI, phase outcomes and analysis are qualified.
Every frozen original-candidate byte matches the approved immutable index after
that later success. Runtime, workspace and actual publication-refusal evidence
remains retained. Steps 6 and 7 and the overall effort remain incomplete.

### Goal for Step 5

Run blocking application validation first and directly orchestrate the preserved
mandated stages second, with truthful command outcomes and protected candidate
bytes.

### Step 5 improvement expectations

Check deploy_venv_release.py as a Step 5 implementation/line-budget target.
Prove actual agents use the same pinned helper member identity and reject
missing or changed helper delivery. Check dedicated phase 2 observer P21 and
its negative tests; phase 1 observer P12 remains unchanged and only
phase-neutral validation is shared through P13. Review this validation file as
a per-step update target; keep unchecked evidence fields empty until
implementation-check runs.

Check phase 2's test scope against plan item 9. A complete-suite diagnosis with
the default analysis scope comes first, with its recorded cause and remedy
attempts. A switch to the declared smoke selection, phase 1's coverage report
and the application-source analysis scope is acceptable only after that
diagnosis confirms the failure. The later human amendments retain the approved
browser and CI/tooling exclusions, the repository analysis source root and
stage-local direct orchestration; they do not select the smoke fallback. The
phase 1 coverage report fed to analysis must match the candidate's digest and
revision. Local consumer validation is `check.bat` only under the human
amendment; actual Jenkins tests, application coverage and quality checks remain
mandatory.

Actual Debian agents execute both phases with preserved acceptance/coverage,
conclusive ABI/provider evidence, truthful failures under the qualifying
orchestration and no release publication. Candidate retention survives a later
successful default build. A probe or static Jenkinsfile inspection cannot
complete this step. Review the plan's file-by-file changes and its mapped
private obligations. Use
`tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py` and the
step's native integration/acceptance cases.

### What was implemented for Step 5

- `src/setups/env/bin/deploy_venv_release.py` adds combined-CI eligibility
  validation and the `ci-check` entry point. It rejects ambiguous JSON,
  incomplete or stale outcomes, candidate/revision/helper/tool/profile drift,
  foreign coverage, altered inventory, failed dependency commands and absent,
  mistyped or failed test-session observations. Schema version 1 requires an
  integer, rejecting booleans and floating-point lookalikes. It verifies the exact existing
  application, toolchain, entry-script and companion inputs before eligibility.
- `verify.deploy-venv-sync.sh` and `acceptance.deploy-venv-sync.sh` accept
  Step 5. Verification retains the cumulative unit, shell, syntax and physical
  line-budget gates. Acceptance adds explicit combined-CI and coverage inputs
  to the existing delivered-toolchain reconstruction contract.
- The new `test_ci_evidence` unit module exercises positive eligibility and
  rejection of stale, incomplete, mistyped, failed or mismatched evidence.
  The existing release-input fixture now supplies the selection profile in
  the companion bundle; its other contracts remain unchanged.
- The consumer directly preserves the mandated checks, ordered stages, audited
  test body, coverage transfer, analysis, quality and dry-run publication.
  Agents own the stages that use their workspaces. Explicit script receivers
  and getter-copied SCM configuration preserve sandbox compatibility without
  private SCM mutation or a deprecated submodule getter.
- The actual command-shell adapter reconstructs the named venv from pinned
  delivered inputs, records provenance and before/after inventories, selects
  shipped tools for application-controlled work and validates independent
  framework observations. Bootstrap checkout provenance remains separate.
- Retained negative executions cover real sync/install failures, a masked
  failing test, disabled observation and foreign-base refusal before mutation.
  Actual runtime cases cover wrong ambient Python/Git, absent and multiple
  venvs, repeated retained targets, and fresh/reused generated configuration.
- A consumer-only launcher exercised the publication-override guard in its
  actual child build. The launcher and child outcomes were captured and
  recursion was prevented. Temporary selections and launcher code were then
  removed, preserving the approved architecture and test/analysis settings.
- Complete default-build evidence passes the shared eligibility validator.
  Every frozen byte of the original qualified candidate matches the approved
  immutable index after that later successful build. The non-release store
  retains the pending candidate until explicit promotion or abandonment.

### New types or classes introduced for Step 5

`CiEvidenceTest` is a new `unittest.TestCase` in the public unit-test tree.
The production change adds focused functions to the existing release helper;
the consumer's phase 2 observer is a dedicated script module. No production
class hierarchy or new domain abstraction is introduced.

### Architecture check for Step 5

Release-input validation stays in the existing technical helper boundary.
The application owns its shell adapter and Jenkins orchestration; shared
library sources remain unchanged. The phase 2 observer records framework
outcomes independently without weakening phase 1 policy. No domain class
imports a transport, CI or filesystem adapter, and no business-layer dependency
is introduced.

The approved orchestration retains workspace agents while releasing idle outer
allocations. This qualifies the consumer implementation; it does not establish
an infrastructure repair or qualify the original shared-library wrapper.

The release helper has 365 physical lines, its new evidence test has 238, and
the empty package marker has zero. The dedicated consumer observer has 105
lines. All affected Python files remain at or below 650 lines; the private
inventory records the other mapped files. The verification and acceptance
scripts have 45 and 116 lines respectively. The validation document is a
non-Python reporting artifact.

The copied stage bodies are bound to a recorded immutable library revision.
Each qualification records it; a library revision change requires a new copy
audit and qualification. The private source audit compares the ordered stages,
checks, audited commands, coverage transfer and publication controls against
that immutable revision, recording the explicitly approved agent and sandbox
changes separately.

No architecture, layer or file-size issue needs addressing.

### Performance check for Step 5

The new evidence checks use fixed section/key comparisons and linear scans of
the explicit profile and artifact inputs. Hashing and archive validation scale
with input bytes at required integrity boundaries; they introduce no quadratic
search or new sorting step. Phase identities reuse explicit maps and retained
observations. Native cumulative verification completed without a new timeout
or expected-failure gate. Actual CI durations and agent CPU observations are
retained privately; the human-deferred local consumer duration gate is not
reported as executed.

No performance issue needs addressing.

### Unit test coverage check for Step 5

The public evidence tests sit under
`tests/unit/deploy_venv_sync/test_ci_evidence/` and exercise the new shared
validator through positive and mutation cases, including strict boolean and
integer session outcomes. Existing release-input tests cover the reused
archive and binding checks. The cumulative native verification passed
225 tests against the repaired implementation, with its preceding
failing cases retained. This count describes the executed verification scope,
not a unit-only coverage percentage.

cplx has no configured Python coverage gate. The consumer's 100% gate measures
its configured application source scope; CI helpers lie outside that scope.
No percentage is inferred for either shared helpers or consumer CI modules.
Static inspection includes module-level references and framework hook
registration: every top-level symbol in an affected unmeasured implementation
module is referenced by its package or tests. Unchanged phase 1 observer P12
is outside the changed-symbol assessment. Actual fault executions supplement
the dedicated phase 2 observer unit tests without becoming coverage claims.

Static reading now maps every added rejection statement to a unit mutation:
duplicate JSON keys; wrong object shapes or key sets; strictly typed schema;
failed build, phase, analysis or quality; unsafe publication status; malformed
profile digest; candidate and phase identity drift; changed before/after
inventories; missing, changed or symlinked coverage; and mistyped dependency or
session outcomes. The schema mutations failed before the strict-integer repair
and pass after it. These are behavioral rejection cases, not a measured
coverage percentage.

No unit-test gap in the changed implementation needs completing. No top-level
symbol in an affected unmeasured implementation module is unreferenced.

### Feature integrity for Step 5

Both actual-agent phases and every required later stage succeed under the
approved defaults. The configured blocking phase 1 suite and coverage remain
in place; phase 2 keeps the explicitly approved exclusions and the analysis
root stays at the repository root. No smoke fallback or phase 1 coverage
substitution is claimed. ABI/provider inspection, heavy-library imports,
delivered-helper identity, dependency inventory and shipped-runtime selection
remain conclusive in the retained private evidence.

Actual sync and install failures, a masked failing test and disabled observation
each failed combined validation under the qualifying direct orchestration.
The exact source and immutable loaded library are recorded for each case;
later analysis, quality and publication stages were not entered. Publication
remains disabled, and an actual override attempt is refused. Full consoles and
artifacts survive acquisition retries. The restored default source tree exactly
matches the accepted pre-probe tree. After its successful build, every frozen
original-candidate file remains byte-identical to the approved immutable index.
The stage-local workaround preserves reporting and audit behavior without
claiming infrastructure stability. Operator promotion and final target rollout
remain the work of Steps 6 and 7. Review submission and the human cplx commit
gate remain workflow gates after this implementation check.

## Analysis of Step 5 Implementation

Step 5 makes combined validation attributable to one exact candidate. The shared
release helper checks both CI phases, delivered input identities, independent
test-session outcomes, dependency inventories and phase 1 coverage before
declaring eligibility. Native verification and acceptance expose that contract.

The consumer adapter reconstructs the pinned environment in the actual command
shell and refuses failed commands or missing observations. Direct orchestration
preserves the mandated checks, ordered stages, audited test body, coverage,
analysis, quality and dry-run publication with stage-local workspace agents.
Actual controlled failures, restored defaults, runtime cases and immutable
retention establish the planned behavior without qualifying the original wrapper.

The new `CiEvidenceTest` class exercises eligibility and its rejection paths.
Production changes use focused helper functions and a dedicated phase 2 observer;
they introduce no production class hierarchy. The architecture, performance,
unit exercise and feature-integrity assessments above have no remaining Step 5
implementation gap. Independent review and human commit approval remain pending.

## Step 6. Implement operator promotion and immutable release binding

### Analysis of Step 6 implementation state

Yes. Step 6 has been fully implemented.

The separate operator command checks exact candidate qualification, preserves
the existing publisher's artifact semantics, verifies retained inputs and
publishes the binding last, and five actual backend cases passed with verified
cleanup. Operator eligibility has its own command outside the delivered helper
closure. The plan lists that module and its line budget. The expanded native
suite exercises the publication safety boundaries and isolated command entry.

### Goal for Step 6

Provide the separate operator command that validates and publishes the exact qualified candidate pair through the existing application publisher.

### Step 6 improvement expectations

Publish the exact application, entry script and helper-bearing companion before
their generated binding record. Reject mixed versions, incomplete qualification,
partial releases and changed local bytes before announcement. Preserve current
and predecessor inputs independently of CI retention. Private P14/P15 own the
operator environment, credentials, repository coordinates and existing transport.

### What was implemented for Step 6

- **Eligibility**: `deploy_venv_publication.py publication-check` is an
  operator-only command, reusing the unchanged release helper. Strict documents bind retained,
  unexpired candidates to successful combined CI and six complete qualification
  results: both target families, offline, readiness and both rollback forms.
  Every result identifies the same candidate and predecessors and hashes its
  nonempty evidence. Same-revision replacement bytes remain ineligible.
- **Publication**: explicit role coordinates bind every file digest. Validated
  identities survive the copy boundary; frozen byte copies are checked before
  transport. Full remote readback checks retained tools and predecessors, rejects
  conflicts, and verifies uploaded objects before the final binding. Equal-byte
  retries retain the same binding without additional uploads.
- **Private operator integration**: P14 wraps P15 using existing controlled
  credentials and deploy-file transport. Exact-byte staging under the requested
  extension preserves older publisher behavior for role-named local inputs.
  Repository-bound backend receipts survive authorized test cleanup; actual
  current and predecessor retention is checked on each publication.
- **Execution entry points**: `verify.deploy-venv-sync.sh --step 6` extends the
  cumulative native gate. `acceptance.deploy-venv-sync.sh --step 6` invokes the
  explicit private operator with isolated backend test configuration. Neither
  path adds a build, deployment, validation bypass or pipeline invocation.
- **Local and native evidence**: the cplx groundhog walk completed with exit 9
  for its non-pytest layout, followed by 248 native tests in 33.265 seconds,
  syntax, ShellCheck and line-budget checks. The fresh consumer walk passed its
  static checks, affected tests and full 6,662-test suite: no failures, eight
  expected failures, measured coverage 100%, and no duration outliers. Its full
  phase took 10 minutes 45.8 seconds. Freshness and terminal status were checked.
- **Actual backend evidence**: complete publication, interrupted pair recovery,
  failed binding recovery, conflicting bytes and missing retained inputs all
  passed through the existing publisher. A direct conflicting deployment was
  rejected and original bytes remained intact. Five owned test components were
  deleted; all 240 associated asset URLs and all five component reads then
  returned absent. The retention case created no component. Execution plus
  cleanup took 937.836 seconds. Private receipts retain the exact identities,
  host, shell, credential source, commands and observations.
- **Evidence limits**: the selected snapshot backend allowed overwrite at an
  exact timestamped coordinate. Immutable acceptance therefore used disposable
  release coordinates after deletion capability was proven, as authorized.
  Repository administration policy was not visible to the configured account;
  the report records actual write/read behavior rather than unseen settings.

Measured physical line counts, including markers and private integration files:

| File or mapped responsibility | Before | After |
| --- | --- | --- |
| `deploy_venv_release.py` (reused unchanged) | 365 | 365 |
| `deploy_venv_publication.py` | 0 | 249 |
| `test_release_promotion_tdd.py` | 0 | 350 |
| New public / private test leaf markers | 0 / 0 | 0 / 8 |
| `verify.deploy-venv-sync.sh` | 45 | 45 |
| `acceptance.deploy-venv-sync.sh` | 116 | 135 |
| P14 operator adapter / backend acceptance | 0 / 0 | 286 / 165 |
| P14 shell entry / focused tests | 0 / 0 | 14 / 128 |
| P15 existing publisher | 395 | 410 |
| Existing consumer value-object property test | 319 | 322 |
| Implementation plan | 1017 | 1021 |
| This validation document | 982 | 1126 |

Every changed Python implementation and new test module is below the 550-line
advisory threshold and the 650-line ceiling. This validation document is not
subject to the Python ceiling; its physical size was recounted for the check.

### New types or classes introduced for Step 6

No production class hierarchy was introduced. Focused functions implement
eligibility, predecessor binding, coordinate validation and publication through
the `digest`/`upload` transport port. P14 supplies that port and the real backend
acceptance adapter. `ReleasePromotionTest` provides the finite mutation and
failure-injection cases; the private operator tests use parameterized functions.

### Architecture check for Step 6

The public helper owns qualification and publication order without credentials,
network clients or consumer names. The private adapter owns authenticated reads,
repository observations and the existing publisher invocation. No domain layer
imports these operator adapters. Runtime reconstruction and consumer delivery
remain separate responsibilities. Splitting publication from the release helper
keeps both files below their budget without a new abstraction hierarchy.

The publication module imports the unchanged release helper. Target-delivered
code has no dependency on the operator module, and the delivered helper closure
is unchanged. The private operator already selects that publication module;
the acceptance entry retains its existing delegation to the private operator.

No, there is no architecture issue that needs addressing for Step 6.

### Performance check for Step 6

Processing walks explicit files and fixed role maps. Hashing and freezing cost
O(n) in the selected bytes; required integrity-boundary rereads remain explicit.
Dictionary lookups avoid repeated discovery. Deterministic JSON sorting operates
only on fixed schema and role keys, not an unbounded discovered collection.
No new O(n squared) or input-dependent O(n log n) path was introduced.

The consumer duration gate identified one affected property whose generation
cost was reduced using its existing smaller sample budget, preserving strategies
and assertions. The final complete walk had no duration outliers. Backend time
includes real transport and cleanup, not a fixture-only timing claim.

No, there is no performance issue that needs addressing for Step 6.

### Unit test coverage check for Step 6

The public suite exercises 23 test methods with finite mutations covering
identity, expiry, missing files, incomplete CI and qualification, coordinate
aliasing, source changes, retention, false upload success, retry and conflict.
Seventeen private cases cover coordinate policy, exact publisher arguments,
four destination extensions and historical receipt acceptance after cleanup.
The cases are deterministic enumerations; no new property-based generator is
needed for these operator rules. Both new test leaf packages include markers.

The consumer coverage gate measures its application source root and reports
100%; tests and standalone operator tools are outside that reported scope.
cplx's native unittest gate reports execution, not a coverage percentage.
No new or changed production class file is introduced by these function-based
helpers. The existing value-object class exercised by the adjusted property
remains inside the consumer's measured scope. Every top-level helper symbol
outside the coverage gate is referenced by a test or its own implementation
package, including the acceptance and CLI entry points.

Additional mutations cover snapshot coordinates in multiple cases, missing
objects in an already announced release, corrupt manifest readback, empty
evidence with a matching digest, timezone-less expiry, relative and actual
symlinked evidence roots, and non-path inputs. Early refusals prove zero upload;
manifest readback failure proves no success receipt is emitted. The isolated
operator command is exercised with both valid and incomplete qualification.
The native Linux gate executes the real symlink case; only the supplementary
Windows run skips it. All 248 native tests passed without skips.

No, there is no unit-tested class below its required coverage needing work.
No, there is no unreferenced top-level symbol in the changed standalone helpers.

### Feature integrity for Step 6

Existing deployment, packaging, CI validation and publisher entry paths remain
intact. Backend tests used only dedicated disposable coordinates; accepted
toolchain and production artifacts were preserved. The new private shell entry
passes syntax and ShellCheck; the existing publisher's six diagnostics match
its baseline exactly, with no new diagnostic introduced by the added branch.
Receipts retain byte identities, failures and cleanup evidence locally.

The bundled release helper is byte-identical to its prior committed version.
Step 6 therefore does not require rebuilding the candidate to change its helper
closure. Step 7 must still verify and fully qualify the selected exact candidate;
any changed candidate inputs require renewed qualification. Retained candidates
must not be edited in place. Synthetic backend fixtures establish publication
behavior only and do not qualify a real candidate's target runtime.

No existing feature or reporting capability is impaired by Step 6.

## Analysis of Step 6 Implementation

The implementation provides exact-candidate operator promotion through the
existing consumer publisher. A focused operator module validates combined CI,
target and rollback identities, freezes their bytes and verifies retained tools
and predecessors before publishing objects and their binding in that order.
Its command entry stays outside the unchanged target helper closure. No new
production class hierarchy was introduced; the test class supplies the finite
mutation and failure-injection matrix. Native, consumer and live backend
evidence close Step 6, including verified disposal of all backend test artifacts.
Final target qualification and production promotion remain Step 7.

## Step 7. Complete exact-candidate target acceptance and rollout

### Analysis of Step 7 implementation state

Yes. Step 7 has been fully implemented.

The reusable implementation and the actual consumer integration have matching
execution evidence. The qualified nonpublishing candidate was promoted through
the unchanged outside-CI operator, retrieved through the normal release path,
and used for both offline predecessor recovery sequences. All 27 acceptance
rows are backed by digest-bound evidence within their documented execution or
unchanged-component reuse scopes. Cleaned consumer delivery and independent
service supervision also passed. Reboot remains untested and nonblocking by
human decision.

### Goal for Step 7

Qualify the retained candidate on both targets, then complete authorized promotion, offline reconstruction and recovery with matching evidence. Consumer integration qualification is separately tracked.

### Step 7 improvement expectations

Apply the human-approved consumer delivery/cplx reconstruction boundary. Verify complete local files before mutation and reject missing or invalid inputs without fetching. Run cplx with remote services denied from entry, empty disposable caches and no target Git checkout. Record independently validated cplx work separately from pending consumer acquisition/integration evidence; a mixed step and the overall topic remain incomplete until their required integration evidence exists.

Require actual cplx offline reconstruction and rollback from complete locally supplied inputs, retaining predecessor script/helpers/tools. Record real consumer delivery/invocation evidence separately. Documentation or vendored role inspection is not a live qualification result.

Every AC01-AC15 and design-level retention/promotion case has matching conclusive execution evidence, private obligations included. No production release is announced until its pair and qualification binding are complete.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_acceptance_evidence/test_acceptance_evidence_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 7

- `acceptance_deploy_venv_sync.py` drives 27 explicit acceptance cases through
  subprocess adapters. It requires fresh completion observations, matching
  candidate and predecessor identities, nonempty digest-checked evidence and
  explicit negative readiness assertions. Fixture success is kept separate
  from native qualification.
- `acceptance.deploy-venv-sync.sh` and `verify.deploy-venv-sync.sh` wire the
  driver and its focused unit tests into the native cumulative checks.
  `acceptance.deploy-venv-sync.md` documents local inputs, adapter contracts,
  native execution and the publication boundary without private endpoints.
- `deploy_venv_release.py` exposes explicit CI observation for published
  evidence while preserving strict nonpublishing eligibility for promotion.
  Unit cases prove that default eligibility still rejects published evidence.
- The refreshed cumulative native run passed 264 checks, shell syntax,
  ShellCheck and the Python line ceiling; no changed Python file exceeds
  650 lines. Focused driver tests also passed on the authoring host. They
  assert exact preflight refusal reasons and successful native summaries for
  both nonpublishing and explicitly published candidates. A successful subset
  remains incomplete and lists the other 26 cases.
- Actual native lifecycle evidence covers reconstruction, repeat sync, mirror
  recreation, missing inputs, invalid environments, lock/wheel/distribution
  drift, interrupted sync, binary tampering and changed toolchain identity.
  Debian and RHEL observations include shipped runtime providers, original
  wheel ELF bytes and dynamic paths, readiness and root serialization.
- Both predecessor formats passed offline recovery after deliberate failure
  and after successful upgrade using the repaired consumer entry. Installed
  predecessor entry bytes match the observed baseline. The historical
  compatibility exception accepts only two original comment-path relocations.
- The official consumer deployment passed startup, revision and independent
  lifecycle observation. Reboot testing is explicitly untested and nonblocking
  by human decision; it is not used as evidence of lifecycle correctness.
- A separate nonpublishing candidate passed strict combined CI, repository
  nonpublication comparison, packaging/source-impact audit, Debian runtime and
  rejection of mismatched qualification. Earlier negative controls are reused
  only under explicit unchanged-component comparisons. Its exact native
  runtime, serialization and both rollback sequences passed; independent
  capture rehashed 11,934 files. Original provider-failure observations remain
  explicitly bounded reuse, separate from fresh candidate execution.
  Candidate retention across a later build is privately recorded.
- The final qualification record binds combined CI, Debian, RHEL, offline
  reconstruction, readiness and both predecessor recovery formats. The
  unchanged operator accepted its exact candidate and predecessor identities.
  The later authorized publication used those same qualified bytes.
- The immutable tools archive is published and independently verified. All
  eight retained predecessor objects have full-byte repository readback and
  matching digests. Each predecessor retains its own entry, application and
  tools, plus its reconstruction inputs where applicable.
- The qualified timestamped snapshot was published, retrieved with matching
  digests and used for actual offline recovery. The consumer already pins the
  immutable tools version, URL and digest. No toolchain-acquisition redesign
  or replacement of the accepted archive was needed.
- After renewed human authorization, the original operator published the
  qualified immutable application release. It verified every retained and
  uploaded object by full-byte readback before publishing the final binding.
  Normal release retrieval verified the same binding and all object digests.
- The normally retrieved inputs passed ten native phases with remote services
  denied before installation: baseline, deliberate failed upgrade, recovery,
  successful upgrade and successful-upgrade rollback for both predecessor
  formats. Independent capture rehashed the native evidence; the final
  acceptance map connects qualification, publication, retrieval and recovery.
- The consumer registry pins the five normally retrieved release inputs by
  immutable coordinate and digest. The delivery pipeline and deployment
  assertions accept exact release labels as well as timestamped snapshots;
  consumer registration is committed and pushed, and deployment compatibility
  is merged. Focused consumer and contract checks passed.
- Temporary consumer diagnostics were removed through committed delivery
  changes. Structural comparison preserved every other delivery task, and
  the cleaned official check-mode run verified all five input digests. The
  subsequent real deployment passed startup and both revision checks. Both
  service APIs returned healthy matching revisions without drift; independent
  observation confirmed the service unit watches the same script-started
  daemon with the administrative hold removed. The minimal acquisition,
  startup and revision checks remain in the consumer's deployment adapter;
  shared deployment-library sources are unchanged.
- Merged temporary diagnostic branches were removed locally and remotely
  after exact ancestry checks and creation of a verified recovery bundle.
  All worktree commits and file status were preserved. Reconciliation and
  cleanup are complete, with historical diagnostics retained privately.

### New types or classes introduced for Step 7

The integration driver uses focused functions and explicit dictionaries. It
adds no production class hierarchy. The new unit-test class owns subprocess
fixtures for the acceptance evidence contract.

### Architecture check for Step 7

The driver owns orchestration and evidence validation; consumer adapters own
acquisition, credentials, backend transport and application lifecycle commands.
The shared release helper remains independent of those adapters. The explicit
published-observation API does not relax promotion eligibility. No DDD or
ports/adapters boundary violation was found. There is no architecture issue
that needs addressing.

### Performance check for Step 7

File hashing streams bytes with bounded memory. Identity/evidence maps use
linear traversal; deterministic reporting sorts bounded collections. Rehashes
at capture, qualification and publication boundaries intentionally detect
changed inputs. No new quadratic computation was found. There is no
performance issue that needs addressing.

### Unit test coverage check for Step 7

The unit tests under `tests/unit/deploy_venv_sync/test_acceptance_evidence/`
exercise fresh success, subprocess failure, stale/missing evidence, mutated
identity, tampered files and incomplete negative observations. Existing CI
evidence unit tests exercise the added published-observation API and retain
strict default rejection.

No configured project coverage percentage measures these cplx scripts; the
consumer application's coverage gate does not measure them. This check makes
no cplx percentage claim and did not rerun tests to infer one. Static inspection
found references for every added top-level symbol, including `case()` called
at module import to construct `CASES`. No production class below 100% coverage
was identified as needing completion. No top-level symbol is unreferenced.

### Feature integrity for Step 7

Accepted toolchain bytes, original wheel bytes, canonical metadata and helper
provenance remain bound to retained identities. Existing strict CI eligibility
is preserved, and published CI observations are explicit. Negative outcomes
remain failures and historical results retain their original candidate
identity. Deployment and rollback evidence includes the consumer repair;
earlier failed attempts remain retained. Publication and post-retrieval
execution now close the remaining rollout gates. Historical observations retain
their stated scope rather than being presented as new candidate executions.

## Analysis of Step 7 Implementation

Step 7 completes the exact-candidate lifecycle from protected CI inputs to
authorized immutable publication and repository-independent recovery. The
acceptance driver invokes explicit consumer adapters, rejects stale or altered
observations and separates fixtures from target qualification. Its focused
unit tests and the cumulative native checks passed. The observation API keeps
published CI evidence distinct from nonpublishing promotion eligibility.

The final operational proof includes both target runtimes, consumer delivery,
retention, wrong-qualification rejection and release retrieval followed by both
offline predecessor recoveries. Earlier negative controls are reused only where
recorded source comparisons establish unchanged affected components. Private
receipts preserve exact identities and execution details; public outcomes remain
generic. No required Step 7 work remains unimplemented.
