# Implementation plan v0.27.0: deployment-created Python environments

Implement the consolidated [design](design.v0.27.0.deploy-venv-sync.md) and
[requirement](feature-request.v0.27.0.deploy-venv-sync.md), beside their
[canonical draft](draft.v0.27.0.deploy-venv-sync.md) in `docs/v0.27.0/`.
The numbered steps cover reusable cplx behavior and required consuming integration.
This plan introduces implementation tasks, not new design decisions or evidence
that execution has already succeeded.

## Ordered goals for v0.27.0 deploy-venv-sync

| Step | Goal |
| --- | --- |
| 1 | Qualify release inputs and locked offline transport |
| 2 | Verify complete dependency selection and wheel ELF identity |
| 3 | Implement exact-path reconstruction and readiness |
| 3b | Probe the mandated pipeline on actual agents, non-qualifying |
| 4 | Package without venvs and wire retained deployment recovery |
| 5 | Integrate and qualify the single-build CI sequence |
| 6 | Implement operator promotion and immutable release binding |
| 7 | Complete exact-candidate target acceptance and rollout |

Steps preserve the dependencies below. Independently runnable cplx tasks may
progress while private integration evidence remains pending; mixed steps remain
partially complete until all their required evidence exists.
Step 1's real uv/transport probes precede production
lifecycle work. Step 5 retains the candidate that Step 7 qualifies. Step 6
implements and tests the publication gate before Step 7 exercises real promotion.
Step 7 qualifies the candidate before enabling the operator's publication action.
Step 3b moves Step 5's first non-qualifying actual-agent probe forward so that
mandated-pipeline incompatibilities surface before Steps 4 and 5 depend on it.
Its part A may run while Step 3 is in progress; part B follows Step 3.
Step 3b qualifies nothing and never gates Step 3 or Step 4 completion.
If Step 6 changes a helper included in Step 5's frozen companion, produce a new
candidate through the complete Step 5 build before Step 7 qualification; never
patch a frozen companion or reuse qualification for different helper bytes.
Neither validation phase publishes or deploys. No compilation, toolchain archive
republication, Python 3.14 work or unrelated CI cleanup belongs in this effort.

## Confirmed implementation and test-tree facts

The source is Linux Bash automation with standalone Python helpers under
`src/setups/env/bin/`. New helpers are scripts loaded by path, not a new Python
package: no production `__init__.py` is needed. New metadata helpers use the
selected shipped Python's standard library; the legacy wheel helper keeps its
Python 3.9+ compatibility. The helper bootstrap cannot depend on the venv it
is meant to construct.

The existing `tests/unit/` tree contains SQLite, release-record and
release-transport suites, with empty package markers and standard-library
unittest fixtures. Native effort harnesses run them using an explicit interpreter.
There is no cplx `pyproject.toml` or local `GROUNDHOG.md`.
`.review-validation` still says no tests tree exists; that comment is stale,
but its declared mandatory Bash lint floor remains valid.
The consuming application has its own configured full coverage/testmon workflow.

`pkg.sh` accepts caller exclusions and additional archive roots; consumer
packaging remains the application integration point. `install_pkg.sh` already
excludes pyvenv.cfg roots from ELF relocation. The wheel helper's current
`installed_name` accepts purelib/platlib but rejects wheel script ELF mappings.
Its installed-root traversal is site-packages-only. The new complete distribution
selection check must not be mistaken for an existing helper capability.

### Physical line baselines measured on 2026-09-22

Counts include blank lines, using ReadAllLines.Length, equivalent to the shared
big-file gate's physical line iteration. Recount before each implementation step.
The write-plans policy sets a 650-line ceiling for Python in this effort; the
shared launcher's unconfigured default is 700 and is not evidence that cplx has
a configured 650-line gate. Enforce 650 explicitly in the native effort harness.

| Existing file | Lines | Planned use |
| --- | --- | --- |
| `src/setups/env/bin/tools_wheel_inventory.py` | 258 | Step 2 compatible extension; below 550, safe |
| `src/setups/env/bin/tools_wheel_inventory.sh` | 11 | Reuse without edits |
| `src/setups/env/bin/pkg.sh` | 452 | Consumer exclusion interface, reused |
| `src/setups/env/bin/install_pkg.sh` | 1334 | Reused relocation boundary; Bash, no Python ceiling |
| `src/setups/env/bin/closure_observe_live.sh` | 232 | Reused conclusive trace boundary |
| `ci/deliver-closure-tools.sh` | 314 | Reused tool delivery; accepted archive unchanged |
| `tests/__init__.py`, `tests/unit/__init__.py` | 0 each | Existing package markers, retained |
| `.review-validation` | 21 | Existing mandatory gate, no effort-specific additions |
| `docs/v0.27.0/verify.tools-release-d10.sh` | 218 | Reused wheel-helper compatibility regression |
| `docs/v0.27.0/verify.install-pkg.sh` | 2181 | Reused installer regression |
| `docs/v0.27.0/verify.tools-archive-rebuild.sh` | 107 | Existing cumulative-harness pattern, retained |
| `docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md` | 389 | Planning IO clarification only |
| `docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md` | 504 | Planning IO clarification only |
| `docs/v0.27.0/draft.v0.27.0.deploy-venv-sync.md` | 391 | Scope reference, no edit |

All new files have baseline 0; later steps recount files created by earlier steps.
Every new Python module/test/package marker is below 550 at baseline, safe to
extend, with a 650-line ceiling. No existing Python mutation target is in the
550-650 risk band or above 650. Avoid growth at 550-650; split by responsibility
only when needed to stay at or below 650. Estimates are advisory, never additional
completion gates. Shell, Groovy, lock and Markdown sizes do not trigger Python
splits. Keep transport validation, selection and release eligibility separate;
split tests by those behaviors if their individual files would exceed 650.

### Consuming integration file mapping

`consumer:Pxx` denotes one concrete file recorded in the required private local
handoff. These handles are not literal repository paths or newly named application
directories. Re-read that handoff in any worktree before implementation; each step
requires its mapped private work and evidence as well as the public files.
Do not pass the handoff itself to public review artifacts.

| Handle | File responsibility | Baseline lines | Planned update |
| --- | --- | --- | --- |
| P01 | Existing toolchain/venv provisioner | 329 | Steps 1-3 and 5 |
| P02 | Existing uv bootstrap | 48 | Step 1 |
| P03 | Existing transport validator (Python) | 109 | Step 1, safe band, ceiling 650 |
| P04 | Existing canonical project metadata | 297 | Step 1 qualified tooling pin/groups |
| P05 | Existing canonical lock | 1337 | Step 1 qualified pin; generated by lock tooling |
| P06 | Existing acceptance runner | 43 | Steps 2 and 5 |
| P07 | Existing deployment entry | 608 | Steps 3-4 |
| P08 | Existing packaging overlay | 79 | Step 4 |
| P09 | Existing assembly configuration | 51 | Step 4 |
| P10 | Existing unique Jenkinsfile | 326 | Step 3b probe mode; Step 5 |
| P11 | New tracked command-shell adapter | 0 | Step 3b probe draft; Step 5 |
| P12 | Existing phase 1 test-framework observer (Python) | 154 | Step 5 reuse unchanged; preserve strict policy |
| P13 | Existing test evidence reader (Python) | 137 | Step 5, safe band, ceiling 650 |
| P14 | New operator promotion wrapper | 0 | Step 6 |
| P15 | Existing workstation publisher | 395 | Step 6 |
| P16 | Existing independent toolchain version pin | 1 | Step 1 reads and preserves accepted identity |
| P17 | Generated release input file | 0 | Steps 1 and 4 generate; never hand-edit |
| P18 | Existing deployment automation task | 77 | Step 4 delivery and invocation |
| P19 | Existing deployment artifact defaults | 30 | Step 4 companion/input-file coordinates |
| P20 | Existing private deployment reference | 189 | Steps 4 and 7 document and qualify |
| P21 | New dedicated phase 2 test-framework observer (Python) | 0 | Step 5, safe band, ceiling 650; Q05 decision |

P11, P14 and P21 are new source files; P17 is new generated output. P12 is reused
without a phase mode or weaker assertions. P16 is an
existing read-only input unless a separately qualified toolchain changes its pin.
Other listed existing mutation targets are to be updated by their owning steps. Exact private test filenames, package markers and additional
read-only baseline references are recorded locally. Source/library revisions
inspected during planning are not claims about the revision loaded by Jenkins.
Preserve the consumer's pre-existing uncommitted work.

## Consumer delivery and cplx reconstruction responsibilities

The human approved the requirement AC02/AC06 and requirement Q09 amendment:
cplx starts with complete local release inputs, verifies them and reconstructs
offline. Plan Q09 records that responsibility boundary; design Q09 remains the
unchanged operator-publication decision. This resolves the round 2 contract
conflict. It does not claim implementation or integration validation.

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

The consuming automation supplies the separately published entry script, release
record and companion before invocation. Their delivery does not imply the new
cplx helpers already exist in the accepted toolchain archive. Concrete acquisition
mechanisms and their qualification remain in the private mapping.

Freeze the independently evolving tools version and SHA-256 from the consumer's
pin into each candidate release record. cplx verifies the supplied archive against
that record, never a mutable checkout, application version or newest timestamp.
Its reusable commands do not fetch missing inputs; they fail before mutation.

Q08 confirms carrying the new helpers inside the already required reconstruction
companion, with an explicit member manifest and immutable cplx source revision.
The reviewer accepted option B in round 2; the human confirmed it at consolidation.
Step 1 implements member
binding/assembly using minimal fixtures; Step 3 implements target bootstrap and
dispatch; Step 4 assembles the complete production helper closure from a pinned
cplx commit, including later modules before freezing a candidate. Include
deploy_venv.sh, deploy_venv_inputs.py, deploy_venv_transport.py,
deploy_venv_selection.py, deploy_venv_archive.py, deploy_venv_release.py,
tools_wheel_inventory.py and any wrappers/runtime support they actually call.
Reject missing members or unlisted executable dependencies. Source locations
under src/ are authoring locations, not a promise of toolchain inclusion.

The independently delivered release input file binds the application archive,
entry script and companion digests, tools version/coordinate/digest and helper
revision/member-manifest digest. It is generated output, not manually edited or
executed as shell code. Avoid circular hashes: the outer record binds the final
archive and companion; their inner records bind their own inputs and members,
not the enclosing archive's digest. The existing consumer bootstrap verifies the
companion with host utilities before safe extraction into release-specific
storage; it cannot call an undelivered helper or depend on the venv being created.
Use a versioned UTF-8 key=value format for this small outer bootstrap record,
with fixed allowed keys and validated version, coordinate and digest values.
Parse it with Bash read and explicit cases; reject duplicates, missing keys and
malformed values, and never source or eval it. This does not require host Python
or a JSON utility. Keep structured inner/member manifests in their existing format.
After verified tools installation, invoke helpers by absolute delivered path with
the shipped Python/runtime. Never fall back to an installed or PATH helper.

Step 4 extends the consumer automation to copy the release input file and companion
alongside the existing application/script delivery. The companion carries the
qualified uv, wheels, metadata/transport inputs and helper closure. The consumer
also supplies the exact tools archive before cplx preflight; acquisition details
remain private and are tested as a separate integration responsibility.
No dependency, helper, uv or source fetch is permitted during reconstruction,
and no acquisition is permitted during rollback. Step 5 uses the same helper
identity on actual CI agents, verifying local immutable-source assembly or exact
artifact acquisition without requiring the preceding workspace. Step 6 promotes
the frozen entry script and companion with their binding record; it never derives
them from a newer checkout. Step 7 qualifies the real delivery and rollback paths.
Retain entry scripts, records, helper payloads and tools for current/predecessor
releases outside the mirrored tree. Historical first-transition recovery retains
its original script/archive path without manufacturing modern metadata.

## File-based IO cost clarification for deploy-venv-sync

Read the explicitly selected release manifest/index and referenced metadata directly.
Do not discover release state by scanning documentation, CI history or unrelated
directories. Reuse parsed metadata and identity maps within each phase; walk only
declared archive/inventory roots. Stream required artifact hashes and retain
before/after integrity checks. Offline inputs and diagnostics must survive
cleanup. This is a batch workflow: required wheel, archive and ELF IO remains
proportional to selected inputs, with existing deterministic sorting retained.

The metadata-loading phase is a small selected-index read, not a history scan.
Do not trade away byte checks to reduce IO. Share a phase's verified maps,
but repeat verification at mutation/transfer boundaries where identity can change.
Time and count acquisitions, tree walks and bytes hashed separately.

## Shared execution command checklist for all seven steps

1. Read the step, current code/test tree, private mapping and current Git state.
2. Count every involved file before edits, including blank lines; treat absent new files as baseline 0.
3. Add the step's failing tests before its behavior, then implement only that behavior.
4. Run the focused fixture checks through the cumulative native effort harness; application development checks use groundhog.
5. Run the step's bounded rg inspection and the mandatory Bash lint floor.
6. Run the appropriate full workflow below, stopping on its first non-green result.
7. Recount all involved Python files; split above 650 and record advisory estimate variance without inventing a tighter gate.
8. Save command/identity/timing evidence and the private integration result before declaring completion.

### Ready-to-run command forms and platform boundaries

Resolve the shared launcher's absolute location from its loaded instruction,
not a shell alias. On the configured consuming Windows checkout, one
`ghog day` walk owns check, affected tests and the full coverage pass:

```text
cmd /d /c "<resolved-llm-shared>/bin/ghog.bat day > a.ghog.log 2>&1"
```

Use `day --detach` without redirection for a long survivor run, then the
launcher's `status` command; never start another live walk. Follow its exit code
and read only the relevant log tail. Repeat fix-and-walk until the objective.
Use `ghog single <actual-step-test-files>` only when the walk's failure branch
calls for a focused check. Do not plan standalone check.bat or pytest commands.

cplx's existing native harness model is the explicit repository-specific
equivalent; do not pretend an unconfigured `ghog day` produces cplx coverage.
The new cumulative harness runs syntax, ShellCheck, the new and inherited unittest
suites and the explicit 650-line scan, failing immediately on any failed check.
It accepts `--step N` and includes all prior step fixtures.
On Debian/RHEL use native Linux Bash, never Git Bash for ELF/runtime qualification:

```bash
bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 1 --python /absolute/authoring/python --app-repo /absolute/consumer
bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 1 --python /absolute/tools/python/bin/python3 --tools-prefix /absolute/tools --application-root /absolute/application --manifest /absolute/release/manifest.json --profile /absolute/release/profile.json --evidence-root /absolute/evidence
```

Substitute the current step and actual qualified input paths. Step 1 acceptance
performs the transport/bootstrap probe; steps 2-6 extend relevant integration
cases; step 7 executes the complete target matrix. The consumer's native existing
acceptance script remains the single owner of its CI test/coverage invocation.
Do not translate the Windows groundhog wrapper into Linux or introduce direct
pytest invocations in these plan commands.

On the authoring host, count files and inspect whitespace with:

```powershell
[System.IO.File]::ReadAllLines('src/setups/env/bin/tools_wheel_inventory.py').Length
git diff --check
```

Use ReadAllLines for the physical-line gate, including blank lines.
Run the step rg command against source, not across unrelated private files.
The native harness must also enforce physical lines, including blanks.
Review integration must retain `.review-validation` and explicitly add both new
effort harnesses to syntax/ShellCheck validation; docs harnesses are outside
the repository-wide tracked-shell lint scope.

### Performance-gate assessment for this batch workflow

No Step 0 timeout/xfail gate is needed: no responsiveness SLO or numerical time
target was specified, and network/agent duration does not establish correctness.
Use deterministic invocation/scan-count assertions and recorded phase durations.
Do not mark missing offline reconstruction or actual-agent qualification xfail.
Retain existing CI timeout and coverage requirements.

## Numbered implementation steps for deploy-venv-sync

### Step 1. Qualify release inputs and locked offline transport

#### Step 1 analysis and intent

The existing bootstrap fetches uv and the current transport handles private acquisition, not disconnected reconstruction. Implement design sections Release inputs and retention, Offline source transport and Qualified uv bootstrap, with decisions Q01-Q03. Qualify the selected file transport first and the already approved loopback fallback only if necessary. Do not continue on an unqualified lock rewrite.

Expected outcome: Deliver and qualify the reconstruction bundle and release-pinned uv before depending on them in deployment.
Complexity impact: operate on explicit inputs and shared per-phase identity maps;
avoid repeated discovery and preserve necessary integrity-boundary rereads.
Feature preservation includes accepted toolchain bytes, runtime guarantees,
existing checks and the consumer's directory/artifact contracts.

#### Step 1 implementation

Files involved:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (existing, to be updated by implementation-check for this step).
- `src/setups/env/bin/deploy_venv_inputs.py` (new, to be created).
- `src/setups/env/bin/deploy_venv_transport.py` (new, to be created).
- `src/setups/env/bin/deploy_venv_probe.py` (new, native qualification and restricted local server).
- `docs/v0.27.0/verify.deploy-venv-sync.sh` (new, to be created).
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh` (new, to be created).
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_release_inputs/__init__.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py` (new, to be created).
- `tests/unit/deploy_venv_sync/__init__.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py` and its empty `__init__.py` (new, native prerequisite and HTTP boundary tests).

P01-P05, P16-P17: provisioning, bootstrap, transport validator, canonical project/lock inputs, existing tools pin and generated release input record. Existing sizes and new private test paths are in the local mapping.
P02 delegates checked original-artifact acquisition to a new standard-library
Python helper (baseline 0, ceiling 650); its concrete path and test references
remain in the private mapping. The consumer's frozen native probe snapshot has
explicit digest/syntax checks and native acceptance, separate from its normal
application formatting, typing and complexity checks.
Reuse existing test parent markers unchanged; new leaf markers above are empty.
Read-only reused dependencies and their baselines are in the shared table.

Tests first: Missing/conflicting tools pins; absent/changed helper members; unsafe extraction paths; manifest self-reference rejection; independent application/tools versions; manifest omissions, corrupt wheels/uv, source drift, stale lock, malicious/ambiguous paths, workspace input omissions and missing compatible wheels fail. Generate transport round-trip permutations and identity-changing mutations in the PBT module using deterministic standard-library generators. Real target tests must demonstrate no remote access or cache dependence.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Implement manifest loading, explicit input paths, SHA-256 verification and bundle assembly in deploy_venv_inputs.py. Bind application archive/source, canonical metadata and workspace configuration, toolchain/full Python, uv artifact, target profiles, wheel identities, transport map and existing runtime evidence. Extend the schema with independent tools version/coordinate/SHA-256, deployment entry identity and helper revision/member inventory; implement non-circular inner/outer records and fixture helper assembly as described in the delivery clarification. Later target qualification stays in a separate record and never mutates the frozen bundle.
2. Implement deploy_venv_transport.py to build a disposable effective metadata workspace from canonical inputs, rewrite only mapped locations structurally, and validate dependency/version/marker/group/artifact/hash identity before and after sync. Reject path escapes, ambiguous wheel matches, unmapped URLs and changed canonical bytes. Use the selected toolchain Python with tomllib; do not add a parser dependency to the older independent wheel helper.
3. Acquire original wheels and latest stable uv at qualification through configured sources with public access denied. Freeze version/digest, align the consuming tooling lock, and qualify unmodified static uv on Debian 12 and RHEL 9.8 with the shipped runtime. Only the design-authorized adaptation fallback may change uv bytes, with distinct provenance; preserve item 7's accepted archive.
4. Create the cumulative native harness and acceptance entry with explicit --step, --python, --tools-prefix, --application-root, --manifest, --profile and --evidence-root inputs as applicable. The acceptance entry's step 1 probe constructs only an operation-owned fixture environment to prove actual uv --locked consistency and wheel-only sync. Run with empty cache and remote access denied, without installing the fixture project. Exercise file transport using uv offline mode; loopback fallback allows loopback but denies remote access.
5. Update consumer provisioning, uv bootstrap, canonical dependency metadata and transport validator through private mapped files P01-P05. Record which private source mapping was used after resolving the handoff's source discrepancy; carry no endpoint or credential into public bundles. Keep Git-based acquisition optional; the target probe uses delivered metadata only.

Completion criteria: Both supported targets prove the delivered uv executes and the selected transport supports locked/no-build/no-project-install synchronization. If neither designed transport works, stop for design review; static schema tests cannot complete this step.
Pass the Shared execution command checklist and the applicable Ready-to-run
command forms, including the consumer groundhog objective for consumer changes
and native target checks where specified. Test fixture success cannot substitute
for a named actual-agent or backend completion criterion.

#### Step 1 addendums

Complete these four checkpoints in order; the validation plan records their verdicts:

1. Retain native manifest-driven locked synchronization evidence on Debian 12 and
   RHEL 9.8, including isolation, empty caches and negative cases.
2. Complete consumer P01-P05 changes and tests, preserve the independent P16
   tools pin, and bind the P17 fixture record. Production record generation remains Step 4.
3. Audit manifest, bundle and transport completeness; close missing-input,
   workspace and compatible-wheel negatives; pass cumulative native checks and
   the consumer groundhog objective, and record final line counts.
4. Run implementation-check, prepare grouped changes, and publish Step 1 code
   review round 1 when review mode is enabled.

Line-budget checkpoint:

- [x] `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: existing planning document; recount before/after; no Python ceiling.
- [x] `src/setups/env/bin/deploy_venv_inputs.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [x] `src/setups/env/bin/deploy_venv_transport.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [x] `src/setups/env/bin/deploy_venv_probe.py`: baseline 0; native qualification responsibility separated from structural transport; Python ceiling 650; recount before/after.
- [x] `tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py` and its empty `__init__.py`: baseline 0; Python ceiling 650; recount before/after.
- [x] `docs/v0.27.0/verify.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [x] `docs/v0.27.0/acceptance.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [x] `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [x] `tests/unit/deploy_venv_sync/test_release_inputs/__init__.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [x] `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [x] `tests/unit/deploy_venv_sync/__init__.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [x] Recount the step's private mapped files; P03/P12/P13 and all new Python tests are safe at baseline, ceiling 650.
- [x] If a Python file enters 550-650, avoid growth where practical; split only above 650. Separate manifest/transport, inventory mapping, or test cases by responsibility.

Full workflow timing run readiness: use the shared native cumulative harness
with `--step 1`, the corresponding acceptance mode and the consumer
`ghog day` walk. Record duration, commands and input identities.
Time-gated status: no new timeout/xfail gate; missing required execution stays incomplete.

Step inspection: `rg -n 'locked|no.build|offline|sha256|transport' src/setups/env/bin/deploy_venv_*.py`.

### Step 2. Verify complete dependency selection and wheel ELF identity

#### Step 2 analysis and intent

The existing ELF helper does not resolve target/group selection and explicitly rejects .data scripts ELF members. Follow design Q04: add a separate complete-selection check and extend the existing helper compatibly, preserving capture/materialize/describe consumers.

Expected outcome: Compare complete installed distributions and all wheel ELF locations against the same canonical lock, target profile and retained original wheels.
Complexity impact: operate on explicit inputs and shared per-phase identity maps;
avoid repeated discovery and preserve necessary integrity-boundary rereads.
Feature preservation includes accepted toolchain bytes, runtime guarantees,
existing checks and the consumer's directory/artifact contracts.

#### Step 2 implementation

Files involved:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (existing, to be updated by implementation-check for this step).
- `src/setups/env/bin/deploy_venv_selection.py` (new, to be created).
- `src/setups/env/bin/tools_wheel_inventory.py` (existing, to be updated).
- `docs/v0.27.0/verify.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_tdd.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_selection_integrity/__init__.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_pbt.py` (new, to be created).

P01 and P06: consuming provisioning and acceptance scripts must save and compare the complete profile/wheel identities.
Reuse existing test parent markers unchanged; new leaf markers above are empty.
Read-only reused dependencies and their baselines are in the shared table.

Tests first: Missing/extra/normalized-duplicate distributions, different platform markers, default versus explicit groups, wrong tags, hash substitution, .data/scripts ELF relocation, changed bin ELF and duplicate installed destinations. Generated permutation/mutation properties cover selection order independence and rejection of identity changes without a new testing dependency.
Capture the independent qualified-uv selection oracle with its uv version,
toolchain digest, profile and source revision; retain that provenance when
refreshing fixtures so expected selection never merely mirrors the implementation.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Implement deploy_venv_selection.py to consume a qualified explicit selection from canonical lock metadata and profile, normalize distribution identity, resolve markers/extras/effective groups, validate selected wheel tags/hashes, and compare the exact installed distribution set. Record selected profile and wheel-manifest digests. Reject missing, extra and mismatched distributions without treating marker-excluded distributions as missing.
2. Extend tools_wheel_inventory.py with an opt-in venv-aware installed mapping covering wheel-supplied ELF executables under bin plus library locations. Preserve the existing schema-1 site-packages-only interface and capture/materialize/describe behavior for item 7 callers. Distinguish generated interpreter links/scripts from wheel ELF subjects; do not weaken existing unsafe-path, symlink, collision or hash checks.
3. Compose separate distribution and ELF reports bound to the same canonical lock, profile and original wheel files. Retain every original wheel and compare wheel ELF bytes including $ORIGIN-bearing payloads; do not assert all non-ELF file bytes are identical.
4. Extend the native harness with old-interface regressions and new bin-ELF cases. Reuse the existing D10 harness unchanged as a compatibility regression and keep ABI interpretation owned by the existing closure readers.

Completion criteria: Old helper clients still pass, and complete selection plus ELF checks reject each deliberate drift in both library and bin locations. Runtime provider qualification remains a later acceptance gate.
Pass the Shared execution command checklist and the applicable Ready-to-run
command forms, including the consumer groundhog objective for consumer changes
and native target checks where specified. Test fixture success cannot substitute
for a named actual-agent or backend completion criterion.

#### Step 2 addendums

Line-budget checkpoint:

- [ ] `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: existing planning document; recount before/after; no Python ceiling.
- [ ] `src/setups/env/bin/deploy_venv_selection.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `src/setups/env/bin/tools_wheel_inventory.py`: baseline 258; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `docs/v0.27.0/verify.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `docs/v0.27.0/acceptance.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_tdd.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_selection_integrity/__init__.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_pbt.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] Recount the step's private mapped files; P03/P12/P13 and all new Python tests are safe at baseline, ceiling 650.
- [ ] If a Python file enters 550-650, avoid growth where practical; split only above 650. Separate manifest/transport, inventory mapping, or test cases by responsibility.

Full workflow timing run readiness: use the shared native cumulative harness
with `--step 2`, the corresponding acceptance mode and the consumer
`ghog day` walk. Record duration, commands and input identities.
Time-gated status: no new timeout/xfail gate; missing required execution stays incomplete.

Step inspection: `rg -n 'installed|scripts|schema|profile|marker' src/setups/env/bin/tools_wheel_inventory.py src/setups/env/bin/deploy_venv_selection.py`.

### Step 3. Implement exact-path reconstruction and readiness

#### Step 3 analysis and intent

Recency and ambient activation cannot select the environment. Implement Environment identity and synchronization and the runtime boundaries without changing the confirmed naming or serialization responsibilities.

Expected outcome: Create or synchronize only the full-version named environment using the selected shipped interpreter and qualified local inputs.
Complexity impact: operate on explicit inputs and shared per-phase identity maps;
avoid repeated discovery and preserve necessary integrity-boundary rereads.
Feature preservation includes accepted toolchain bytes, runtime guarantees,
existing checks and the consumer's directory/artifact contracts.

#### Step 3 implementation

Files involved:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (existing, to be updated by implementation-check for this step).
- `src/setups/env/bin/deploy_venv.sh` (new, to be created).
- `docs/v0.27.0/verify.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py` (new, to be created).

P01, P07: provisioning and deployment adapters. Full serialization and target readiness are exercised again in steps 4 and 7.
Reuse existing test parent markers unchanged; new leaf markers above are empty.
Read-only reused dependencies and their baselines are in the shared table.

Tests first: Empty target with no new helpers in the accepted tools archive; corrupt/incomplete helper payload; wrong helper first on PATH; invocation from verified delivered paths; absent/repeated/mirror-removed targets; wrong host Python first on PATH; foreign activation; multiple versions; foreign-base same-version target; escaping symlink; stale lock; missing wheels; interruption; failed post-sync checks; changed toolchain at equal Python version. Use a finite state matrix instead of another PBT dependency.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Implement deploy_venv.sh as a Linux Bash entry receiving the absolute application root, project suffix, tools prefix, release manifest, explicit profile and consumer serialization attestation. Resolve python/current/bin/python3 to its actual shipped executable, query full version, verify toolchain digest and directory version, and return the exact computed venv path plus operation evidence.
2. Validate an existing target's base executable, prefix, full version and expected path before reuse. Reject foreign, malformed or escaping targets. Create an absent target at its final path with the absolute shipped interpreter; ignore other versions. Revalidate equal-version environments when the toolchain digest changes.
3. Select the release's absolute verified uv; disable Python downloads and ambient source/selection overrides. Set UV_PYTHON and UV_PROJECT_ENVIRONMENT explicitly, then perform locked wheel-only sync without installing the application project. Use the effective metadata workspace and transport qualified in step 1.
4. Invalidate prior readiness before mutation. Require complete inventory, original wheel ELF, interpreter links/shebangs/stdlib/import and runtime checks before writing fresh success. Bind evidence to operation/release/toolchain/lock/profile identities. Preserve first failure and diagnostics on sync interruption or cleanup errors.
5. Use the shared shipped runtime setup for Python/application commands and keep host archive/network utilities outside incompatible runtime exports. Require the consuming enforcement token before entry; the consumer retains serialization from before archive mirroring through failure/readiness and rollback.
6. Implement the consumer bootstrap verification and absolute-path helper dispatch described in the delivery clarification, initially against step-local fixtures. Verify bundle digest before safe extraction without invoking its Python helpers or an application venv. Wire consumer P01 and P07 to the helper, replacing recency selection and the new path's Git restoration while preserving historical recovery. Do not change install_pkg.sh's existing exclusion or rewrite any new venv ELF.

Completion criteria: The returned exact path is used for creation, sync, tests and readiness; every failure leaves the operation not ready. Native fixture integration verifies runtime-boundary handling and consumer serialization attestation.
Pass the Shared execution command checklist and the applicable Ready-to-run
command forms, including the consumer groundhog objective for consumer changes
and native target checks where specified. Test fixture success cannot substitute
for a named actual-agent or backend completion criterion.

#### Step 3 addendums

Line-budget checkpoint:

- [ ] `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: existing planning document; recount before/after; no Python ceiling.
- [ ] `src/setups/env/bin/deploy_venv.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `docs/v0.27.0/verify.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `docs/v0.27.0/acceptance.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] Recount the step's private mapped files; P03/P12/P13 and all new Python tests are safe at baseline, ceiling 650.
- [ ] If a Python file enters 550-650, avoid growth where practical; split only above 650. Separate manifest/transport, inventory mapping, or test cases by responsibility.

Full workflow timing run readiness: use the shared native cumulative harness
with `--step 3`, the corresponding acceptance mode and the consumer
`ghog day` walk. Record duration, commands and input identities.
Time-gated status: no new timeout/xfail gate; missing required execution stays incomplete.

Step inspection: `rg -n 'UV_PYTHON|UV_PROJECT_ENVIRONMENT|readiness|pyvenv|base' src/setups/env/bin/deploy_venv.sh`.

### Step 3b. Probe the mandated pipeline on actual agents, non-qualifying

#### Step 3b analysis and intent

Step 5 depends on the unchanged mandated shared-library pipeline accepting
the application-owned adapter on its own agents. Nothing has exercised that
pipeline for this consumer yet, and its command forms are the ones the
design's Two-phase CI integration section singles out: implicit environment
creation, a mandatory installation command, discarded test status and an
enabled publication stage. Discovering an incompatibility in Step 5, after
Step 4 has frozen the candidate shape, would cost a full repackaging cycle.

This step is the non-qualifying actual-agent probe that Step 5 item 2 already
required, moved forward. It adds no design decision: it observes, on actual
agents, the facts the Step 5 adapter is built on, and records them privately.
Shared-library sources remain unchanged. The step is labelled `3b` so that
Step 3's review exchange keeps its identity; nothing depends on the label.

Expected outcome: A recorded, reproducible probe build of the one consuming
Jenkinsfile that reaches the mandated pipeline with publication disabled,
and a private list of the adapter hook point, agent allocation, checkout
revision, command forms and publication controls that Step 5 must handle.
Complexity impact: probe output is a bounded record per build; no tree walks
beyond the named workspaces.
Feature preservation: the consumer's default CI mode, its phase 1 checks and
its publication behavior outside the probe mode stay byte-for-byte unchanged.

#### Step 3b implementation

Files involved:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (existing, to be updated by implementation-check for this step).

P10 and P11 only: a probe mode or probe branch of the consuming Jenkinsfile,
and a draft of the tracked adapter. The concrete library entry point, its
configuration keys, agent labels, branch and job coordinates, and the exact
observation commands are in the private local handoff for this step; re-read
it before implementation and never copy its terms into public files.
No cplx source file changes in this step.

Tests first: Before the first probe build, write the private list of expected
observations and of the deliberate failure the probe must see. A probe build
whose record lacks an expected observation is incomplete, not green.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Part A, may start while Step 3 is in progress. Add a probe mode to P10 that
   runs a minimal phase 1 (existing provisioning only), releases its agent,
   then calls the mandated pipeline once in the same build. The default mode
   keeps its current behavior. Disable publication through the library's own
   configuration and record the effective value the library resolved, not only
   the value passed; a probe build that reaches a publication command fails.
2. In part A, the P11 draft only observes: it proves whether a build-scoped
   hook reaches the actual Python-command shell on the mandated test agent,
   after that agent's checkout and before its first dependency command. Record
   agent identity, working directory, checked-out revision against the build's
   revision, the interpreter and uv each library command resolves, the
   environment each creates or selects, and each command's real exit status.
   Include one deliberately failing test to show whether its status is masked.
3. Part B, after Step 3's exact-path helper and P01 wiring are committed:
   extend the P11 draft to reconstruct the named venv on the mandated test
   agent through P01 and to place it ahead of the library's commands. Record
   whether the library's environment and installation commands then select it
   without drift, and which ones do not.
4. Record every result, including failures, in the private handoff and a
   sanitized one-line outcome per observation in the validation plan. Each
   unhandled command form becomes a named input to Step 5 items 2, 4 and 6.
   An incompatibility never authorizes a shared-library change.
5. Keep P10 and P11 probe changes in their own commits, outside Step 3's
   reviewed batch. Push them to the remote the CI server builds before
   triggering a probe build.

Completion criteria: At least one probe build of each part ran on actual agents
with publication proven not invoked, and every expected observation is
recorded, whether it succeeded or failed. Step 3b qualifies no candidate,
proves no AC row and cannot complete Step 5. Its failures are findings, not
reasons to stop Steps 3 or 4.

#### Step 3b addendums

Line-budget checkpoint:

- [ ] `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: existing planning document; recount before/after; no Python ceiling.
- [ ] Recount P10 and P11 before and after; P11 is Bash, no Python ceiling. Any new Python probe helper follows the 650 ceiling.

Full workflow timing run readiness: record each probe build's duration, the
mandated pipeline's stage durations and agent wait times privately.
Time-gated status: no timeout/xfail gate; a probe build that did not run leaves
the step incomplete.

Step inspection: none in cplx sources; the private handoff names the P10/P11
inspection command.

### Step 4. Package without venvs and wire retained deployment recovery

#### Step 4 analysis and intent

Application packaging currently delegates to the general packager, while archive mirroring may remove venvs. Implement Packaging and recovery boundaries using an application adapter so the accepted toolchain packaging behavior is preserved.

Expected outcome: Produce venv-free application archives and support serialized offline reconstruction and both predecessor recovery paths. Reusable cplx results and consumer integration results are recorded separately under the completion rules below.
Complexity impact: operate on explicit inputs and shared per-phase identity maps;
avoid repeated discovery and preserve necessary integrity-boundary rereads.
Feature preservation includes accepted toolchain bytes, runtime guarantees,
existing checks and the consumer's directory/artifact contracts.

#### Step 4 implementation

Files involved:

- `src/setups/env/bin/deploy_venv_inputs.py` (existing, to be updated; created in Step 1, current baseline 0).
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (existing, to be updated by implementation-check for this step).
- `src/setups/env/bin/deploy_venv_archive.py` (new, to be created).
- `src/setups/env/bin/deploy_venv_release.py` (new, to be created).
- `docs/v0.27.0/verify.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_archive_recovery/__init__.py` (new, to be created).

P07-P09, P16-P20: deployment, packaging/assembly, pinned toolchain input, generated release record, automation task/defaults and private operator documentation. Add private adapter tests alongside the existing test tree as mapped locally.
Reuse existing test parent markers unchanged; new leaf markers above are empty.
Read-only reused dependencies and their baselines are in the shared table.

Tests first: Supplied tools archive with an independently evolving version; missing, truncated or wrong-digest local inputs fail before mutation with no fetch attempt; unrelated newer archive ignored; missing release record; helper/script digest mismatch; retained predecessor helper selection; current, stale, nested, alternate-name and aliased venvs; archive extra roots; intact metadata; symlink/dereference abuse; missing bundle/toolchain/predecessor before mirror; offline rollback for both predecessor formats; competing mutation and failed-readiness retention. Finite archive/path and lifecycle fixtures suffice. Consumer acquisition cases remain in the private integration checklist.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Implement deploy_venv_archive.py to discover pyvenv.cfg boundaries once within explicitly supplied packaging roots, produce exclusions safely for the existing packaging interface, and inspect the resulting archive. Include all consumer extra roots. Refuse unsafe traversal/dereference combinations that could reintroduce venv content; retain canonical metadata and required release inputs.
2. Wire the consuming packaging overlay and its assembly path (P08-P09) so both archive production routes use the exclusion rule and post-archive verification. Keep archive coordinates and independent packaging behavior. Reuse pkg.sh without changing the accepted tools archive path.
3. Complete deploy_venv_inputs.py helper assembly from the pinned cplx commit, bind every delivered member and runtime support dependency, and generate P17 with the independent tools pin and exact entry/companion identity. Make missing helper delivery fail before candidate freeze. Implement deploy_venv_release.py with preflight/qualification/publication-input validation responsibilities: verify complete application/bundle/toolchain bindings and explicit current/predecessor references before mutation. At this step wire local delivery/retention and recovery validation; publication eligibility is completed in step 6.
4. Implement the local-input contract and consuming handoff through P07/P18-P20: supplied entry script, release record, companion and tools archive must match their recorded versions/checksums before invocation and mutation. Consumer acquisition is separately owned and tested through the private mapping. Maintain serialization across mirroring, install, reconstruction and readiness. Retain complete current/predecessor inputs outside the mirrored tree independently of CI and uv caches; do not advance predecessor protection until safe.
5. Implement venv-free rollback using the predecessor's retained entry script, release record, helper payload, archive, toolchain, uv, canonical lock, wheels and profile, with no network attempt. Keep the existing historical archive procedure for the first transition, including its shipped venv, without requiring missing modern metadata. Verify readiness through the applicable path.
6. Extend acceptance fixtures with competing deployment/sync/rollback processes and a controlled mirror deletion. Prove no overlapping mutation on one root and allow independent roots. Keep installer relocation exclusions intact through its existing regression harness.

Completion criteria: Archive inspections find no packaged application venv and both local recovery paths work with remote services denied and empty caches in the controlled integration fixture. Actual RHEL qualification remains step 7.
Pass the Shared execution command checklist and the applicable Ready-to-run
command forms, including the consumer groundhog objective for consumer changes
and native target checks where specified. Test fixture success cannot substitute
for a named actual-agent or backend completion criterion.

#### Step 4 addendums

Line-budget checkpoint:

- [ ] `src/setups/env/bin/deploy_venv_inputs.py`: baseline 0; recount Step 1 implementation; Python ceiling 650.
- [ ] `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: existing planning document; recount before/after; no Python ceiling.
- [ ] `src/setups/env/bin/deploy_venv_archive.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `src/setups/env/bin/deploy_venv_release.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `docs/v0.27.0/verify.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `docs/v0.27.0/acceptance.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_archive_recovery/__init__.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] Recount the step's private mapped files; P03/P12/P13 and all new Python tests are safe at baseline, ceiling 650.
- [ ] If a Python file enters 550-650, avoid growth where practical; split only above 650. Separate manifest/transport, inventory mapping, or test cases by responsibility.

Full workflow timing run readiness: use the shared native cumulative harness
with `--step 4`, the corresponding acceptance mode and the consumer
`ghog day` walk. Record duration, commands and input identities.
Time-gated status: no new timeout/xfail gate; missing required execution stays incomplete.

Step inspection: `rg -n 'pyvenv|preflight|predecessor|retention|manifest' src/setups/env/bin/deploy_venv_archive.py src/setups/env/bin/deploy_venv_release.py`.

### Step 5. Integrate and qualify the single-build CI sequence

#### Step 5 analysis and intent

A separate agent cannot inherit the first phase's files or shell environment. Implement design Q06-Q07 and Two-phase CI integration through the application-owned adapter; shared-library sources remain unchanged.

Expected outcome: Run blocking application validation first and the unchanged mandated pipeline second, with truthful command outcomes and protected candidate bytes.
Complexity impact: operate on explicit inputs and shared per-phase identity maps;
avoid repeated discovery and preserve necessary integrity-boundary rereads.
Feature preservation includes accepted toolchain bytes, runtime guarantees,
existing checks and the consumer's directory/artifact contracts.

#### Step 5 implementation

Files involved:

- `src/setups/env/bin/deploy_venv_release.py` (existing, to be updated; created in Step 4, current baseline 0; Q03 decision).
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (existing, to be updated by implementation-check for this step).
- `docs/v0.27.0/verify.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py` (new, to be created).

P06, P10-P11, P13 and new P21 plus private CI adapter tests; reuse P12 unchanged. Exact Jenkins/library revisions, job/build/agent evidence and command mechanics stay private; public records state sanitized outcomes.
Reuse existing test parent markers unchanged; new leaf markers above are empty.
Read-only reused dependencies and their baselines are in the shared table.

Tests first: Public synthetic evidence tests reject revision/profile/toolchain drift, stale/incomplete observations, independent dependency and test failures, missing archive pair and overwritten candidate identity. Private actual-agent acceptance also covers wrong host Python/Git, foreign activation/base, missing/multiple venvs, parameter override attempts and fresh/reused workspaces.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Update the single consuming Jenkinsfile (P10) to run scripted blocking tool provision, environment verification, acceptance/coverage and archive/bundle assembly first. Freeze and archive the exact candidate pair, manifests and phase 1 evidence; preserve diagnostics in finally handling and release the preliminary node before calling the mandated pipeline once in that same build.
2. Complete the tracked application-owned adapter P11 at the accepted private path, starting from Step 3b's draft and recorded observations. Repeat the Step 3b probe only if the adapter, the loaded library revision or the agent allocation changed since. Then scope initialization to the actual Python-command step after checkout, disable recursive initialization, and fail if required initialization is incomplete.
3. Obtain or assemble the exact helper set from the pinned cplx revision and compare its member manifest with phase 1 before execution; record actual helper paths and reject drift or absent delivery. Reconstruct an equivalent local named venv from the same toolchain archive digest, canonical lock and exact effective selection including defaults. Fetch existing toolchain/wheels from configured services; verify phase 1 toolchain/profile/wheel-manifest digests passed as non-secret build inputs. Reject revision or provenance drift and never require the phase 1 workspace.
4. Set explicit Python/venv/download/locked/no-build controls, real executable PATH, VIRTUAL_ENV and shipped runtime setup in the actual command shell. Verify fixed activation aliases and successful compatibility installation as a no-op before and after activation. Record the actual uv version and reject dependency drift; the qualified exception for another phase 2 uv never applies to deployment.
5. Select shipped Git for application-controlled operations after provisioning and exercise an actual operation. Record Jenkins bootstrap checkout provenance separately: adapter initialization cannot select a Git executable for an already completed checkout or unrelated agent.
6. Implement shell-level dependency failure observation plus independently loaded test-framework start/completion/session outcome records in dedicated phase 2 module P21; reuse only phase-neutral validation through P13, leaving phase 1 observer P12 unchanged. Require fresh operation identifiers, command statuses, interpreter/installation target and before/after inventory evidence. Prove sync/install failures, deliberately failing tests and missing/disabled observation fail the combined build even when outer commands mask status.
7. Disable both publishers effectively despite parameter overrides; prove no deployment command or release upload executed. Preserve conformity/quality/report behavior, phase 1 artifact and coverage identity, and fresh/reused-workspace configuration compatibility. A phase 1 failure prevents entry into phase 2; a phase 2 failure fails combined validation.
8. Extend deploy_venv_release.py with the shared combined-CI eligibility validator used by the public evidence fixtures and private adapter: reject stale/incomplete outcomes and mismatched candidate, helper, tools or profile identity. Protect each named pending candidate build from discarding until promotion/abandonment; if unavailable, copy verified bytes before cleanup to the approved durable non-release candidate store. Index source build/revision/pair digests and prove a later build cannot replace a pending candidate.

Completion criteria: Actual Debian agents execute both phases with preserved acceptance/coverage and conclusive ABI/provider evidence, truthful failures and no release publication. Candidate retention survives a later build. A probe or static Jenkinsfile inspection cannot complete this step.
Pass the Shared execution command checklist and the applicable Ready-to-run
command forms, including the consumer groundhog objective for consumer changes
and native target checks where specified. Test fixture success cannot substitute
for a named actual-agent or backend completion criterion.

#### Step 5 addendums

Line-budget checkpoint:

- [ ] `src/setups/env/bin/deploy_venv_release.py`: baseline 0; recount Step 4 implementation; Python ceiling 650.
- [ ] `consumer:P21`: baseline 0, new standalone Python script, no production package marker; ceiling 650; private CI adapter tests own its phase-specific failure cases.
- [ ] `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: existing planning document; recount before/after; no Python ceiling.
- [ ] `docs/v0.27.0/verify.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `docs/v0.27.0/acceptance.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] Recount the step's private mapped files; P03/P12/P13 and all new Python tests are safe at baseline, ceiling 650.
- [ ] If a Python file enters 550-650, avoid growth where practical; split only above 650. Separate manifest/transport, inventory mapping, or test cases by responsibility.

Full workflow timing run readiness: use the shared native cumulative harness
with `--step 5`, the corresponding acceptance mode and the consumer
`ghog day` walk. Record duration, commands and input identities.
Time-gated status: no new timeout/xfail gate; missing required execution stays incomplete.

Step inspection: `rg -n 'phase|observation|candidate|revision|inventory' tests/unit/deploy_venv_sync/test_ci_evidence docs/v0.27.0/acceptance.deploy-venv-sync.sh`.

### Step 6. Implement operator promotion and immutable release binding

#### Step 6 analysis and intent

Scenario 1 is settled: operator publication outside CI, without rebuilding or invoking the mandated pipeline. Implement Qualification, publication and local delivery, design decisions Q08-Q09, preserving the existing artifact semantics. Plan Q09 records the separate human-approved consumer-delivery boundary.

Expected outcome: Provide the separate operator command that validates and publishes the exact qualified candidate pair through the existing application publisher.
Complexity impact: operate on explicit inputs and shared per-phase identity maps;
avoid repeated discovery and preserve necessary integrity-boundary rereads.
Feature preservation includes accepted toolchain bytes, runtime guarantees,
existing checks and the consumer's directory/artifact contracts.

#### Step 6 implementation

Files involved:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (existing, to be updated by implementation-check for this step).
- `src/setups/env/bin/deploy_venv_release.py` (existing, to be updated; created in an earlier step, current baseline 0).
- `docs/v0.27.0/verify.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_release_promotion/__init__.py` (new, to be created).

P14-P15: new operator wrapper and existing workstation publisher, with private release test package. No new Jenkins job or validation bypass mode.
Reuse existing test parent markers unchanged; new leaf markers above are empty.
Read-only reused dependencies and their baselines are in the shared table.

Tests first: Same-revision different bytes; wrong candidate qualification; expired/missing candidate; incomplete phase verdicts; partial upload; failed manifest exposure; identical retry; conflicting remote digest; predecessor retention; no-build/no-deploy execution boundary. Use a finite mutation matrix and backend failure injection, not mocked success as publication proof.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Extend deploy_venv_release.py to validate successful combined CI plus completed Debian/RHEL/offline/readiness/rollback qualification records against the exact application, bundle, toolchain and predecessor digests. Wrong bytes at the same revision, candidate loss, missing evidence or incomplete records block the publisher before upload.
2. Implement the private operator wrapper P14 around existing publisher P15 on the approved workstation/release host. Use immutable candidate identity and explicit qualification/configuration paths; controlled credentials come from the existing private credential mechanism and never from bundle/build evidence. Preserve the existing publisher's deploy-file artifact semantics and coordinates.
3. Publish the immutable archive, separately delivered entry script and helper-bearing companion under associated coordinates, verify all bytes and receipts, then expose the generated binding release input file/manifest referencing the separate completed qualification record. Test partial failure and retry: an incomplete pair is never announced, equal-byte retries are safe, and different bytes cannot overwrite identity.
4. Reject automatic rebuild, deployment or mandated-pipeline invocation from the operator path. Regenerated bytes require full new qualification. Retain complete current/predecessor pairs and toolchains in the release repository independently of CI retention, with local delivery verified separately.
5. Add controlled backend integration tests through the acceptance entry, using isolated non-release test coordinates. Preparing this command or tests does not authorize a production publication; step 7's authorized release action follows exact-byte qualification.

Completion criteria: The reproducible command and backend integration prove eligibility guards and immutable pair/manifest behavior with preserved publisher semantics. The operator host/interface and credential source are recorded privately before execution. Production publication remains gated by step 7.
Pass the Shared execution command checklist and the applicable Ready-to-run
command forms, including the consumer groundhog objective for consumer changes
and native target checks where specified. Test fixture success cannot substitute
for a named actual-agent or backend completion criterion.

#### Step 6 addendums

Line-budget checkpoint:

- [ ] `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: existing planning document; recount before/after; no Python ceiling.
- [ ] `src/setups/env/bin/deploy_venv_release.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `docs/v0.27.0/verify.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `docs/v0.27.0/acceptance.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_release_promotion/__init__.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] Recount the step's private mapped files; P03/P12/P13 and all new Python tests are safe at baseline, ceiling 650.
- [ ] If a Python file enters 550-650, avoid growth where practical; split only above 650. Separate manifest/transport, inventory mapping, or test cases by responsibility.

Full workflow timing run readiness: use the shared native cumulative harness
with `--step 6`, the corresponding acceptance mode and the consumer
`ghog day` walk. Record duration, commands and input identities.
Time-gated status: no new timeout/xfail gate; missing required execution stays incomplete.

Step inspection: `rg -n 'qualification|sha256|publication|predecessor|candidate' src/setups/env/bin/deploy_venv_release.py`.

### Step 7. Complete exact-candidate target acceptance and rollout

#### Step 7 analysis and intent

Only actual execution closes the topic. Exercise every design acceptance row and AC01-AC15 against exact candidate bytes; retain item 7's accepted toolchain and keep private implementation work in the completion boundary.

Expected outcome: Qualify the retained candidate on both targets, then complete authorized promotion, offline reconstruction and recovery with matching evidence. Record reusable cplx evidence independently from consumer integration evidence; the combined topic still requires both.
Complexity impact: operate on explicit inputs and shared per-phase identity maps;
avoid repeated discovery and preserve necessary integrity-boundary rereads.
Feature preservation includes accepted toolchain bytes, runtime guarantees,
existing checks and the consumer's directory/artifact contracts.

#### Step 7 implementation

Files involved:

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `docs/v0.27.0/verify.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `docs/v0.27.0/acceptance.deploy-venv-sync.md` (new, to be created).
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (existing, to be updated; created by this planning pass).
- `tests/unit/deploy_venv_sync/test_acceptance_evidence/test_acceptance_evidence_tdd.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_acceptance_evidence/__init__.py` (new, to be created).

All P01-P21 plus private qualification records. Preserve both phase report provenance and exact executing-agent identities; publicly disclose only sanitized verdicts and remaining gaps.
Reuse existing test parent markers unchanged; new leaf markers above are empty.
Read-only reused dependencies and their baselines are in the shared table.

Tests first: Missing or invalid local tools/input files fail before mutation with no fetch attempt; valid complete inputs reconstruct with remote services denied from cplx entry. All design acceptance rows, with larger-than-unit execution of packaging -> candidate retention -> two-phase CI -> exact-byte RHEL qualification -> eligible promotion -> local deployment -> offline recovery. Include negative observation and publication controls, and verify normal commands rather than stand-in successes.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Complete the acceptance harness as an integration driver around real reusable commands and consuming adapters, not source-text assertions. Include subprocess fixtures for local failure paths and explicit native-target mode for actual toolchain/runtime/backend evidence. Add sanitized operator instructions and evidence references in acceptance.deploy-venv-sync.md.
2. Retrieve the protected candidate pair and bound script/input record produced by the successful combined CI build. Supply those exact bytes and tools archive locally in the non-release qualification location. Deny remote services before invoking cplx. Execute bootstrap and reconstruction with empty caches and no target Git checkout/filter, readiness, repeat sync, mirror removal/recreation, both predecessor rollback paths and root serialization contention. Separately qualify the actual consumer delivery/invocation path; keep its acquisition evidence in private records, without using it as a prerequisite for independent cplx tests.
3. Exercise fresh/existing/foreign-base environments, equal Python with changed archive identity, stale locks, missing wheels, partial sync, extra distributions, bin ELF tampering and provider failures. Verify original wheel ELF bytes and $ORIGIN remain unchanged, and failed operations remain not ready.
4. Require Debian executable/interpreter/stdlib/import/heavy-wheel checks, ABI listings and conclusive live provider traces without ABI-critical host fallback. Apply item 7's RHEL provider matrix and end-to-end operator readiness separately. Empty traces and static settings are not successful execution evidence.
5. Bind all target results to frozen candidate/toolchain/profile/wheel/lock digests, exact revisions and predecessor identity in a separate qualification record. Verify wrong-digest evidence blocks promotion. Rerun affected qualification whenever candidate bytes or qualified inputs change.
6. After complete qualification and explicit publication authorization, run the operator command once for those bytes, record receipts, and verify normal release retrieval into local retained storage. Exercise deployment and rollback with repository services unavailable. If authorization/access is absent, leave those cells and this step incomplete, with precise missing execution evidence.
7. Update the validation plan with evidence through implementation-check only after execution. Keep generic public outcomes and private exact-path/build/operator records synchronized. The final implementation check may then update the umbrella row under its own workflow; planning does not mark it completed.

Completion criteria: Every AC01-AC15 and design-level retention/promotion case has matching conclusive execution evidence, private obligations included. No production release is announced until its pair and qualification binding are complete.
Pass the Shared execution command checklist and the applicable Ready-to-run
command forms, including the consumer groundhog objective for consumer changes
and native target checks where specified. Test fixture success cannot substitute
for a named actual-agent or backend completion criterion.

#### Step 7 addendums

Line-budget checkpoint:

- [ ] `docs/v0.27.0/acceptance.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `docs/v0.27.0/verify.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `docs/v0.27.0/acceptance.deploy-venv-sync.md`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [ ] `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: existing planning document; recount before/after; no Python ceiling.
- [ ] `tests/unit/deploy_venv_sync/test_acceptance_evidence/test_acceptance_evidence_tdd.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `tests/unit/deploy_venv_sync/test_acceptance_evidence/__init__.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [ ] Recount the step's private mapped files; P03/P12/P13 and all new Python tests are safe at baseline, ceiling 650.
- [ ] If a Python file enters 550-650, avoid growth where practical; split only above 650. Separate manifest/transport, inventory mapping, or test cases by responsibility.

Full workflow timing run readiness: use the shared native cumulative harness
with `--step 7`, the corresponding acceptance mode and the consumer
`ghog day` walk. Record duration, commands and input identities.
Time-gated status: no new timeout/xfail gate; missing required execution stays incomplete.

Step inspection: `rg -n 'AC[0-9]|offline|rollback|publication|qualification' docs/v0.27.0/acceptance.deploy-venv-sync.md`.

## Rollout evidence and completion accounting

Record reusable cplx implementation/validation separately from consuming
integration validation within each relevant step. Independently verified cplx
work can be marked complete while consumer integration remains pending; a mixed
step stays partially complete until both are demonstrated. Consumer acquisition
does not block independent reusable tasks. Missing actual consumer, CI or target
evidence still prevents whole-topic completion and any promotion that requires it.
Do not replace required Debian/RHEL runtime, two-phase CI or offline recovery
checks with fixtures. Keep exact private evidence in the handoff and publish only
sanitized results. All implementation statuses remain not started in this review.

| Acceptance scope | Owning steps | Required closing evidence |
| --- | --- | --- |
| AC01 packaging and metadata | 1, 4, 7 | Actual archive inspection, exact bundle binding |
| AC02 archive-only installation | 1, 3, 4, 5, 7 | Complete locally supplied application, script, release record, tools archive and companion (uv/wheels/metadata/transport/helpers); bootstrap on both platforms without an existing application venv or target Git checkout. Consumer acquisition is separately validated. |
| AC03-AC05 exact environment and locked sync | 1, 3, 5, 7 | Exact interpreter/environment selection, repeat/recreated venvs, canonical lock and selected groups; deliberate drift blocks readiness. |
| AC06 offline cplx reconstruction | 1, 3, 4, 7 | Deny remote services after local delivery and before cplx invocation; empty disposable caches, no target Git checkout, complete verified local inputs. Missing or invalid input fails before mutation without fetching; complete inputs reconstruct and pass readiness. |
| AC07 wheel and distribution integrity | 2, 7 | Complete inventory and library/bin ELF comparisons |
| AC08-AC09 cross-platform runtime | 5, 7 | Debian ABI/live providers; RHEL applicable readiness matrix |
| AC10a-AC10b equivalent CI and truthful outcomes | 5, 7 | Actual-agent before/after provenance and deliberate failures |
| AC11 validation without publication | 5, 7 | Executed-command evidence in both phases, override attempts |
| AC12 predecessor recovery | 4, 7 | Both offline rollback paths; predecessor script, helper payload, input record and tools binding; no network or current-helper fallback |
| AC13 public/private separation | Every step | Sanitized public files and separate private mapping/evidence |
| AC14 prebuilt dependency wheels | 1, 3, 5, 7 | Compatible prebuilt wheels only; missing compatible wheel blocks readiness, no dependency source build, and no application build/install during dependency sync. |
| Design retained inputs and complete delivery | 1, 4, 6, 7 | Complete local inputs before reconstruction and repository-independent predecessor recovery. |
| AC15 serialization and changed toolchain identity | 3, 4, 7 | Competing mutations excluded and equal-version revalidation |
| Design Q08-Q09 candidate/promotion boundaries | 5, 6, 7 | Retention across later builds, exact-candidate qualification, immutable promotion |

Private implementation and execution evidence are mandatory completion inputs.
If target access, observation compatibility, candidate retention, operator setup
or publication authorization is missing, record the specific open gate and
leave its step incomplete. No local lint, unit test, probe or Jenkins success
label alone establishes the full acceptance result.

## Implementation decisions

Human-authorized consolidation after review round 3 confirms Q01-Q07 option A
and Q08-Q09 option B. Their implementation tasks and evidence gates are integrated
below and in the named sections. No follow-up planning question remains.
Implementation and real integration qualification have not started.

Human-requested amendment on 2026-09-24, before Step 3 started: move Step 5's
non-qualifying actual-agent probe forward as Step 3b, so that the mandated
pipeline runs on actual agents as early as possible. It reorders an existing
task; it changes no design decision, no acceptance row and no step's completion
criteria other than Step 5 item 2 reusing its results.

| Question | Decision and reason | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | A: Use the native cumulative cplx harness and the consumer's configured groundhog walk; report their actual scope without inventing coverage. | Shared execution command checklist; per-step command forms | Adding unrelated cplx pytest/coverage configuration. |
| Q02 | A: Run a minimal real-tool transport/bootstrap probe early to expose compatibility failures; it cannot qualify the final candidate. | Step 1; Step 7 | Deferring all real transport checks until final acceptance. |
| Q03 | A: Extend deploy_venv_release.py in Step 5 so public evidence fixtures exercise the same eligibility validator used for promotion. Private tests establish real observation. | Step 5; Step 6 | Keeping all CI evidence tests private and postponing the shared contract tests. |
| Q04 | A: Combine qualified-uv selection fixtures with compact handcrafted cases and generated mutations for an independent inventory oracle. | Step 2 | Relying only on handcrafted graphs or the new parser's own output. |
| Q05 | A: Add dedicated phase 2 observer P21 and share only phase-neutral validation through P13, preserving phase 1 observer P12 unchanged. | Step 5 | Adding phase dispatch that could weaken the existing observer policy. |
| Q06 | A: Inspect real tar output for supported roots, unusual names and dereference attempts; reject unsafe invocations. | Step 4 | Testing only generated exclusion lists and ordinary archive paths. |
| Q07 | A: Record actual operator host, shell, arguments and credential provisioning privately before live backend implementation; generic eligibility tests may proceed independently. | Step 6 | Deferring runner assumptions until final rollout or reopening the outside-CI publication decision. |
| Q08 | B: Deliver the explicit helper closure in the required reconstruction companion, with pinned source identity, member verification, separate entry script/input record and predecessor retention. This closes delivery without rebuilding tools. | Consumer delivery and cplx reconstruction responsibilities; Steps 1, 3-7 | Another helper artifact or republication of the accepted toolchain archive. |
| Q09 | B: Consumer supplies complete local files and recorded identities; cplx verifies and reconstructs offline. Independently verified cplx work may progress while required private integration remains pending. | Consumer delivery and cplx reconstruction responsibilities; Steps 4 and 7; Rollout | Making cplx prescribe consumer acquisition or treating missing integration evidence as whole-topic completion. |
