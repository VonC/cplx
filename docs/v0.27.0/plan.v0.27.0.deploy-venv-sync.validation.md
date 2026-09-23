# v0.27.0 deploy-venv-sync implementation tracking and validation

No, it is not implemented.

Steps 1 and 2 of the [implementation plan](plan.v0.27.0.deploy-venv-sync.md)
were checked on 2026-09-23. Steps 3-7 remain pending. Each step includes its
mapped private integration obligations; these checks do not validate the full
lifecycle.

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

Not started. Step 3 is not implemented because its planned code, integration
and execution evidence have not been produced or checked.

### Goal for Step 3

Create or synchronize only the full-version named environment using the selected shipped interpreter and qualified local inputs.

### Step 3 improvement expectations

Check bootstrap on a target without new helpers installed: verify before extraction, use absolute delivered paths, reject PATH fallback and absent/corrupt members.
Review this validation file as a per-step update target; keep unchecked evidence fields empty until implementation-check runs.

The returned exact path is used for creation, sync, tests and readiness; every failure leaves the operation not ready. Native fixture integration verifies runtime-boundary handling and consumer serialization attestation.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 3

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 3

_(empty — no check has taken place yet.)_.

### Architecture check for Step 3

_(empty — no check has taken place yet.)_.

### Performance check for Step 3

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 3

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 3

_(empty — no check has taken place yet.)_.

## Step 4. Package without venvs and wire retained deployment recovery

### Analysis of Step 4 implementation state

Not started. Step 4 is not implemented because its planned code, integration
and execution evidence have not been produced or checked.

### Goal for Step 4

Produce venv-free application archives and support serialized offline reconstruction and both predecessor recovery paths. Consumer acquisition is separately tracked.

### Step 4 improvement expectations

Apply the human-approved consumer delivery/cplx reconstruction boundary. Verify complete local files before mutation and reject missing or invalid inputs without fetching. Run cplx with remote services denied from entry, empty disposable caches and no target Git checkout. Record independently validated cplx work separately from pending consumer acquisition/integration evidence; a mixed step and the overall topic remain incomplete until their required integration evidence exists.

Check production helper assembly and supplied script/record/companion/tools identities. Test independent application/tools versions, missing/truncated/wrong-digest local inputs rejected without fetching before mutation, and retained predecessor helpers/tools with no network. Consumer acquisition cases are maintained privately.

Archive inspections find no packaged application venv and both local recovery paths work with remote services denied and empty caches in the controlled integration fixture. Actual RHEL qualification remains step 7.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 4

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 4

_(empty — no check has taken place yet.)_.

### Architecture check for Step 4

_(empty — no check has taken place yet.)_.

### Performance check for Step 4

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 4

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 4

_(empty — no check has taken place yet.)_.

## Step 5. Integrate and qualify the single-build CI sequence

### Analysis of Step 5 implementation state

Not started. Step 5 is not implemented because its planned code, integration
and execution evidence have not been produced or checked.

### Goal for Step 5

Run blocking application validation first and the unchanged mandated pipeline second, with truthful command outcomes and protected candidate bytes.

### Step 5 improvement expectations

Check deploy_venv_release.py as a Step 5 implementation/line-budget target. Prove actual agents use the same pinned helper member identity and reject missing or changed helper delivery.
Check dedicated phase 2 observer P21 and its negative tests; phase 1 observer P12 remains unchanged and only phase-neutral validation is shared through P13.
Review this validation file as a per-step update target; keep unchecked evidence fields empty until implementation-check runs.

Actual Debian agents execute both phases with preserved acceptance/coverage and conclusive ABI/provider evidence, truthful failures and no release publication. Candidate retention survives a later build. A probe or static Jenkinsfile inspection cannot complete this step.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 5

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 5

_(empty — no check has taken place yet.)_.

### Architecture check for Step 5

_(empty — no check has taken place yet.)_.

### Performance check for Step 5

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 5

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 5

_(empty — no check has taken place yet.)_.

## Step 6. Implement operator promotion and immutable release binding

### Analysis of Step 6 implementation state

Not started. Step 6 is not implemented because its planned code, integration
and execution evidence have not been produced or checked.

### Goal for Step 6

Provide the separate operator command that validates and publishes the exact qualified candidate pair through the existing application publisher.

### Step 6 improvement expectations

Check publication of the exact qualified entry script and helper-bearing companion before exposing their generated binding record. Reject mixed versions, partial release sets and newer-checkout substitutions.
Review this validation file as a per-step update target; keep unchecked evidence fields empty until implementation-check runs.

The reproducible command and backend integration prove eligibility guards and immutable pair/manifest behavior with preserved publisher semantics. The operator host/interface and credential source are recorded privately before execution. Production publication remains gated by step 7.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 6

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 6

_(empty — no check has taken place yet.)_.

### Architecture check for Step 6

_(empty — no check has taken place yet.)_.

### Performance check for Step 6

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 6

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 6

_(empty — no check has taken place yet.)_.

## Step 7. Complete exact-candidate target acceptance and rollout

### Analysis of Step 7 implementation state

Not started. Step 7 is not implemented because its planned code, integration
and execution evidence have not been produced or checked.

### Goal for Step 7

Qualify the retained candidate on both targets, then complete authorized promotion, offline reconstruction and recovery with matching evidence. Consumer integration qualification is separately tracked.

### Step 7 improvement expectations

Apply the human-approved consumer delivery/cplx reconstruction boundary. Verify complete local files before mutation and reject missing or invalid inputs without fetching. Run cplx with remote services denied from entry, empty disposable caches and no target Git checkout. Record independently validated cplx work separately from pending consumer acquisition/integration evidence; a mixed step and the overall topic remain incomplete until their required integration evidence exists.

Require actual cplx offline reconstruction and rollback from complete locally supplied inputs, retaining predecessor script/helpers/tools. Record real consumer delivery/invocation evidence separately. Documentation or vendored role inspection is not a live qualification result.

Every AC01-AC15 and design-level retention/promotion case has matching conclusive execution evidence, private obligations included. No production release is announced until its pair and qualification binding are complete.
Review the plan's file-by-file changes and its mapped private obligations.
Use `tests/unit/deploy_venv_sync/test_acceptance_evidence/test_acceptance_evidence_tdd.py` and the step's native integration/acceptance cases.

### What was implemented for Step 7

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 7

_(empty — no check has taken place yet.)_.

### Architecture check for Step 7

_(empty — no check has taken place yet.)_.

### Performance check for Step 7

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 7

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 7

_(empty — no check has taken place yet.)_.
