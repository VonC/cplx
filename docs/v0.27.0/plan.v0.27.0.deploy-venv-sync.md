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
| 8 | Deliver through the consumer's original orchestration, unchanged |
| 9 | Deliver first-time and production installations through the unchanged original orchestration |

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

Step 8 builds on Step 7's qualified lifecycle. Its changed consumer components
need a new immutable candidate through the complete Step 5 build and Step 7
qualification; qualification never carries to different bytes. Reused evidence
requires recorded comparisons showing the relevant components unchanged.
The 2026-10-03 amendment adds consumer integration, without rewriting Steps 1-7.

Human decision of 2026-10-04: Step 8 is limited to the qualification environment
that can still bootstrap through the temporary delivery task before restoration.
It covers neither first-time installation nor production deployment. Mandatory
Step 9 starts only after actual AC16/AC17 evidence closes Step 8 and owns AC18/AC19.
The topic and umbrella item 8 remain pending until Step 9 is validated. Changed
Step 9 bytes require their own complete build, qualification and release binding;
Step 8 success never qualifies different bytes.

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

## Shared execution command checklist for the implementation steps

Steps 8-9 execution override, human decisions of 2026-10-03 and 2026-10-04: local consumer
validation is limited to `ghog check` and `ghog affected`, with permission before
each run. The historical `ghog day`, `ghog single`, full-suite and `check.bat`
instructions below and in earlier decisions do not authorize them for Steps 8-9.
Native CI/target qualification remains separately authorized execution. This
planning task runs no tests or implementation validation.

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

Expected outcome: Run blocking application validation first and directly orchestrate the preserved mandated stages second, with truthful command outcomes and protected candidate bytes.
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

Tests first: Public synthetic evidence tests reject revision/profile/toolchain drift, stale/incomplete observations, independent dependency and test failures, missing archive pair, overwritten candidate identity and a phase 1 coverage report whose digest or revision differs from the candidate's. Private actual-agent acceptance also covers wrong host Python/Git, foreign activation/base, missing/multiple venvs, parameter override attempts and fresh/reused workspaces.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Update the single consuming Jenkinsfile (P10) to run scripted blocking tool provision, environment verification, acceptance/coverage and archive/bundle assembly first. Freeze and archive the exact candidate pair, manifests and phase 1 evidence; preserve diagnostics in finally handling and release the preliminary node before directly orchestrating the mandated stages once in that same build. Preserve checks, stage order, the audited test body, coverage transfer, analysis, quality and dry-run publication. Scope agents to active stages, retaining workspace contexts while omitting the long-lived outer tools allocation and redundant outer Python allocation. Preserve sandbox-safe script receivers and getter-copied SCM maps. Bind the copied stage bodies to the immutable library revision they mirror and record that revision in each qualification. A library revision change requires a new audit of the copy and a new qualification; retain concrete revision identities in private integration records.
2. Complete the tracked application-owned adapter P11 at the accepted private path, starting from Step 3b's draft and recorded observations. Repeat the Step 3b probe only if the adapter, the loaded library revision or the agent allocation changed since. Then scope initialization to the actual Python-command step after checkout, disable recursive initialization, and fail if required initialization is incomplete.
3. Obtain or assemble the exact helper set from the pinned cplx revision and compare its member manifest with phase 1 before execution; record actual helper paths and reject drift or absent delivery. Reconstruct an equivalent local named venv from the same toolchain archive digest, canonical lock and exact effective selection including defaults. Fetch existing toolchain/wheels from configured services; verify phase 1 toolchain/profile/wheel-manifest digests passed as non-secret build inputs. Reject revision or provenance drift and never require the phase 1 workspace.
4. Set explicit Python/venv/download/locked/no-build controls, real executable PATH, VIRTUAL_ENV and shipped runtime setup in the actual command shell. Verify fixed activation aliases and successful compatibility installation as a no-op before and after activation. Record the actual uv version and reject dependency drift; the qualified exception for another phase 2 uv never applies to deployment.
5. Select shipped Git for application-controlled operations after provisioning and exercise an actual operation. Record Jenkins bootstrap checkout provenance separately: adapter initialization cannot select a Git executable for an already completed checkout or unrelated agent.
6. Implement shell-level dependency failure observation plus independently loaded test-framework start/completion/session outcome records in dedicated phase 2 module P21; reuse only phase-neutral validation through P13, leaving phase 1 observer P12 unchanged. Require fresh operation identifiers, command statuses, interpreter/installation target and before/after inventory evidence. Prove sync/install failures, deliberately failing tests and missing/disabled observation fail the combined build even when outer commands mask status.
7. Disable both publishers effectively despite parameter overrides; prove no deployment command or release upload executed. Preserve conformity/quality/report behavior, phase 1 artifact and coverage identity, and fresh/reused-workspace configuration compatibility. A phase 1 failure prevents entry into phase 2; a phase 2 failure fails combined validation.
8. Extend deploy_venv_release.py with the shared combined-CI eligibility validator used by the public evidence fixtures and private adapter: reject stale/incomplete outcomes and mismatched candidate, helper, tools or profile identity. Protect each named pending candidate build from discarding until promotion/abandonment; if unavailable, copy verified bytes before cleanup to the approved durable non-release candidate store. Index source build/revision/pair digests and prove a later build cannot replace a pending candidate.
9. Decide phase 2's test scope by diagnosis, in this order (human decision of
   2026-09-25, recorded under Implementation decisions):
   1. Diagnose first. Let the mandated test command run the complete suite on
      the reconstructed named venv, with the mandated analysis stage at its
      default scope, the repository root. Record the test agent's processor
      count and quota, the suite duration, whether the later mandated stages
      start, and any lost allocation.
   2. Investigate each cause found. Try consumer-side remedies that leave the
      shared library unchanged, such as options passed through the test
      command's option variable. Record each attempt and its result.
   3. If a remedied build completes every mandated stage, keep the complete
      suite in phase 2 and the default analysis scope.
   4. Only if the complete suite is confirmed unable to finish within the
      mandated pipeline, with its cause recorded, switch phase 2 to a declared,
      tracked smoke selection. It proves that the mandated test command runs in
      the named venv on the shipped interpreter. The mandated analysis stage
      then receives phase 1's coverage report for the same revision, with its
      scope set to the application source. Phase 1 keeps the complete suite and
      its full coverage gate as the blocking check.

   The eligibility validator of item 8 rejects a phase 1 coverage report whose
   digest or revision differs from the candidate's. Deliberate failure modes stay
   probe-only and must fail the combined build under either scope.

Completion criteria: Actual Debian agents execute both phases with preserved acceptance/coverage and conclusive ABI/provider evidence, truthful failures and no release publication. Candidate retention survives a later build. Phase 2's test scope follows item 9 and the later human-approved exclusions recorded below; no smoke fallback is implied. Remove temporary probe selections and launcher code before a later successful default build, retaining the approved direct orchestration and sandbox corrections. A probe or static Jenkinsfile inspection cannot complete this step. This workaround does not fix infrastructure or qualify the original wrapper.
Pass the Shared execution command checklist and applicable native target checks.
For this step, the later human instruction limits local consumer validation to
`check.bat`; local groundhog, full-suite and test-duration gates are deferred.
Actual Jenkins tests, coverage and quality gates remain enabled. Test fixture
success cannot substitute for a named actual-agent or backend completion criterion.

#### Step 5 addendums

Line-budget checkpoint:

- [x] `src/setups/env/bin/deploy_venv_release.py`: baseline 0; recount Step 4 implementation; Python ceiling 650.
- [x] `consumer:P21`: baseline 0, new standalone Python script, no production package marker; ceiling 650; private CI adapter tests own its phase-specific failure cases.
- [x] `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: existing planning document; recount before/after; no Python ceiling.
- [x] `docs/v0.27.0/verify.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [x] `docs/v0.27.0/acceptance.deploy-venv-sync.sh`: baseline 0; non-Python, Python ceiling not applicable; recount before/after.
- [x] `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [x] `tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
- [x] Recount the step's private mapped files; P03/P12/P13 and all new Python tests are safe at baseline, ceiling 650.
- [x] If a Python file enters 550-650, avoid growth where practical; split only above 650. Separate manifest/transport, inventory mapping, or test cases by responsibility.

Line counts after qualification: shared release helper 365; dedicated phase 2
observer 105; evidence unit test 238; empty package marker 0; verification
script 45; acceptance script 116; validation document 982
(820 before this check). The retained private inventory covers every mapped
file; no affected Python file exceeds 650 physical lines.

Full workflow timing run readiness: use the shared native cumulative harness
with `--step 5` and the corresponding acceptance mode. Local consumer validation
is `check.bat` only under the human deferral; retain actual Jenkins validation
and record its duration, commands and input identities.
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
- `src/setups/env/bin/deploy_venv_release.py` (existing, reused unchanged for release and CI identity validation).
- `src/setups/env/bin/deploy_venv_publication.py` (new, to be created for operator eligibility and publication).
- `docs/v0.27.0/verify.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh` (existing, to be updated; created in an earlier step, current baseline 0).
- `tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py` (new, to be created).
- `tests/unit/deploy_venv_sync/test_release_promotion/__init__.py` (new, to be created).

P14-P15: new operator wrapper and existing workstation publisher, with private release test package. No new Jenkins job or validation bypass mode.
Reuse existing test parent markers unchanged; new leaf markers above are empty.
Read-only reused dependencies and their baselines are in the shared table.
Publication is a separate operator module so the target-delivered helper closure
does not depend on operator-only code.

Tests first: Same-revision different bytes; wrong candidate qualification; expired/missing candidate; incomplete phase verdicts; partial upload; failed manifest exposure; identical retry; conflicting remote digest; predecessor retention; no-build/no-deploy execution boundary. Use a finite mutation matrix and backend failure injection, not mocked success as publication proof.

Classes and behavior (prefer focused script functions; no new class hierarchy):

1. Implement deploy_venv_publication.py, reusing deploy_venv_release.py unchanged, to validate successful combined CI plus completed Debian/RHEL/offline/readiness/rollback qualification records against the exact application, bundle, toolchain and predecessor digests. Provide its operator-only publication-check command. Wrong bytes at the same revision, candidate loss, missing evidence or incomplete records block the publisher before upload.
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
- [ ] `src/setups/env/bin/deploy_venv_release.py`: existing dependency reused unchanged; below 550, safe; Python ceiling 650; recount before/after.
- [ ] `src/setups/env/bin/deploy_venv_publication.py`: baseline 0; below 550, safe; Python ceiling 650; recount before/after.
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

### Step 8. Deliver through the consumer's original orchestration, unchanged

#### Step 8 analysis and intent

Extend Step 7's qualified lifecycle with AC16 forward delivery and AC17 explicit
offline recovery through the consumer's fixed role contract. This is plan Step 8,
not umbrella item 8. Requirement Q11 and design Q10 are settled human direction.

Scope clarification on 2026-10-04: only the qualification environment is covered
here, because its temporary delivery task can bootstrap before restoration.
First-time installation and production deployment are excluded from Step 8 and
move to mandatory Step 9 after this step's actual AC16/AC17 closure. The settled
Step 8 stop/start, activation, recovery and evidence rules remain intact.

Human round 6 scope retained with round 8 amendments on 2026-10-04: test a
deployment through the restored,
unchanged original orchestration on qualification. Part C's existing temporary
delivery installs the dispatcher, stable targets and control folders first. Every
Step 8 application-account lifecycle action uses that delivery path before
restoration or our pipeline's original forward/stop-start actions afterward.
C installs trust/probes/receipts only; each later attempt/recovery is freshly
signed through the shared drive. A uses our own development account for
preliminary host evidence and staging-only replay. No maintenance shell or operator
route is a prerequisite or fallback. Operations-team involvement is limited to
normal review of the agreed restoration PR. Evidence returns through existing
shared logs, pipeline console and two external endpoints; missing evidence is a
human gate. Operator routes and the separate bootstrap session belong to Step 9.

Expected outcome: the entire application path in the operations repository equals
its recorded original baseline; consumer scripts absorb its commands and order,
enforce every former delivery-task gate and recover without orchestration changes.
The claim is: no unchecked byte is installed or run, and any mismatch fails the
deployment. Unchecked download/unpacking is not a weakened guarantee: consumer
code ignores that tree and installs only the independently verified private copy.

Complexity impact: metadata operations address one selected candidate/attempt,
hashes stream over the five selected inputs, and no history scan selects a release.
The immutable role's whole-tree staging loop is measured separately while held.
Preserve accepted tools, offline reconstruction, both predecessor formats and every
AC01-AC15 gate. No reusable cplx runtime or acceptance-driver change is planned.
cplx deliverables for this step are documentation and evidence binding.

#### Step 8 implementation

Files involved:

- `docs/v0.27.0/draft.v0.27.0.deploy-venv-sync.md`,
  `docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md` and
  `docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md`: existing amended context.
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md` and
  `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: tasks and actual
  evidence accounting; preserve all previous implementation records.
- `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`: item 8 remains pending
  until the expanded topic is validated; preserve its document cells.
- Private P07 (existing entry, 996 lines), P20 (existing deployment reference,
  219), P22 (consumer deployment pipeline, 75), P23 (first-start checks, 177),
  P24 (wrapper refresh, 156), P25 (cooperative hold, 173), P26 (runtime helpers,
  277): update at the responsibilities below.
- New P27 strict dispatcher, P28 strict compatibility installer, P29 shared
  selection/reservation/acquisition contract helper, P30 controller candidate
  validator/selection renderer, P31 stable stop target, P32 stable start/recovery
  target: baseline 0 each; private mapping gives paths and separation reasons.
- New P33 empty test leaf marker and P34-P36 dispatcher, lifecycle and acquisition
  tests, baseline 0 each. Reuse existing parent markers and recovery fixtures.
- New versioned P43 replay helper, baseline 0: Step 8 A staging-only measurement;
  Step 9 expands to the two lifecycle replays after AC16/AC17. Q39 fixes its path in the private mapping.
- New P37 immutable candidate registry file, baseline 0; use the existing schema.
  Do not edit earlier candidate records or add a transport field.
- Existing P38 daemon-ownership helper, 57 lines: include in the verified stable
  closure and resolve it relative to that closure; private mapping records its
  source and the application-runtime dependency graph.

Private P10 and publication/assembly helpers remain unchanged; the existing build
packages the added application files. P18/P19 are historical drafted integration
sources, not the original executing contract, and have no Step 8 edits. Read-only
cplx acceptance drivers retain their Step 7 scope; consumer evidence closes the
new acceptance cases without adding a new reusable runtime requirement.

Tests first: P34-P36 exercise subprocess behavior, not source-string assertions.
Invoke the exact argument vectors with a controlled working directory in native
Linux fixtures; never run the role on the workstation/target as a unit test.
Cover both allowed home forms, surplus/foreign arguments, foreign/missing launcher,
unsafe paths/modes, the stable control operations listed below with replaced trees
absent, and atomic refresh. Use non-terminal streams with ignored hangup behavior,
assert no hangup output file, and anchor the application HOME to the verified prefix;
never locate dispatcher code through incoming HOME.
Cover every mode row, same-byte replacement, unreadable identities,
stale/consumed/wrong/newer selections, concurrent attempts and root-lock recheck.
Independently mutate each fetched digest and record key, simulate bounded HTTP
failures, exact retained tools reuse and installed-version-only misses.
Assert failures before hold leave the running application untouched. Test unit
restart while held, hold failure with supervision restored, no survivors, every
runtime/observer failure, role transfer failure and offline recovery before
installer entry. Assert no staging executable runs and every failed gate is nonzero.
Also repeat deployment-only stop rechecks with no surviving process and with a
verified survivor; prove stable-version identity, unchanged reservation/archive
baseline/checkpoint, zero network, single lock ownership and failure before install.
Assert ordinary start and recovery never take that extra path. Include its deadline
in timing tests. These fixtures support implementation; actual AC16/AC17 closing
evidence is separate.

P35's case-to-gate map also covers every attempt-state transition below, the
pipeline-launched transfer-failure recovery route, same-release checkpoint/index behavior, the
archive-derived staging non-collision invariant, and park-before-stop requalification.
Add handled fetch failure followed immediately by a fresh same-candidate selection,
without maintenance terminalization; repeated bound recovery after rollback success
but failed runtime checks, including same-release redeployment; and preinstaller
recovery with zero rollback calls. Verify pending-target mismatch and absent-pending
identity mismatch refuse held. P34/P35 also cover all bridge paths below: missing
record, previous-boot record, live recorded daemon and hold.
P35 covers bound recovery to the historical predecessor format through the pending
marker, and a no-target marker refused held.
P35 also covers successful G leaving no conditional recovery, failed external H
followed by an unsigned checked restart, and fresh signed recovery after failed G.
Add outside-pipeline stop/start launches before and after restoration and fresh
signed retry/recovery, expiry and replay cases against the settled R16/R17 rules.
P34 tests bootstrap activation only after complete runtime success, failed-bootstrap
non-activation, no activation by wrapper refresh alone, and immutable pinned versions.

#### Step 8 round 8 decision and evidence gate ledger

Human decisions on 2026-10-04 settle R16 option A and fresh signed selections for
every attempt, retry and recovery. They supersede bootstrap-recorded arming,
non-expiring authority and pre-recorded retry counts. Operator-free refers to
application-account maintenance access; the human signs on their workstation.

| Gate | Selected behavior and evidence required |
| --- | --- |
| A before C | Development-account host network/client/shared-folder read-write evidence; same-disk filesystem replay cost plus per-task overhead from retained or separately authorized check-console timings times remote operation count. Application-account C probes remain final. |
| Before B, backup trust (R20/Q38) | Human selected option A on 2026-10-05: primary and offline backup public keys in release N. Document independent custody, recovery and verified rotation/revocation before B; qualify failure fixtures before freezing bytes. Evidence Q37 tooling and Q40 layout before immutable qualification. |
| R19 restart admission | Human confirmed restart-independent admission on 2026-10-05 and accepts possible downtime from an unsigned forward launch. Ordinary stop keeps local safety state without signed reservation; delivered unauthorized bytes never install and start returns nonzero after checked restoration. |
| C bootstrap | Install verified closure/key, probes and retention/activation receipts only. No arming. |
| D selection handoff | Validate C receipts and the candidate-bound signing handoff. Human supplies a fresh, short-lived signed selection for each actual G attempt and I recovery, outside staging on the existing shared drive. |
| G outside stop/start | R16 A preserves the forward selection unused, checks/restarts the working release, releases its own reservation and returns the checked status. P22 controls only our launches. |
| I failure/retry | Fresh signed recovery binds failed attempt/checkpoint; terminal job and local lock/process proof still required. Each retry has a new ID and expiry, never authority inherited from recovery success. |

Classes and behavior (focused script functions; no new class hierarchy):

1. **Part A, prerequisites and evidence.** Read the exact original source and
   evidence; record loaded source revision, project and execution environment.
   Define required dispatcher/closure, unit and repository/client evidence here;
   collect target read-only probes inside Part C's verified bootstrap and return
   their receipts through existing shared logs. Probe application-account DNS,
   route/proxy, anonymous exact-URL reads and the usable HTTP client there.
   Obtain inherited configuration URL, properties-path and remote-copy defaults
   from pipeline console evidence of original check-mode traversal, using retained
   evidence before E and reconfirming at F. If retained evidence is insufficient,
   report the prerequisite gap before restoration; never request operator access.
   A specifies C's probes and is not a requirement to have C's results before C.
   Record tilde behavior without blocking on either
   accepted form. Inventory the real application archive and time the fixed
   staging operations with current/previous trees: per-directory/top-level
   basename rotations, whole-tree copy and per-script permission operations.
   Record actual job timeout, 60-minute pipeline envelope, acceptable outage and
   disk budget including archive, expanded tree, previous copies and retained
   inputs. Read-only or separately authorized evidence only.
   No exact-workload execution receipt exists. Before C, under separate
   authorization, our development account on the qualification host records
   network route/client capability and shared-folder read/write evidence.
   The same-disk replay measures filesystem cost only for the exact candidate,
   matching current/previous staging populations, OS/filesystem behavior and
   permissions, with audited task/baseline mapping. Do not run the orchestration
   tool. Use a bounded staging-only replay mode for A; Step 9 lifecycle rehearsals
   still wait for AC16/AC17. Q39 fixes this shared replay helper's private path mapping.
   Record filesystem elapsed T, incremental disk D and remote operation count N.
   Obtain per-task orchestration overhead O from retained or separately authorized
   original check-console timing, accounting for skipped-task limits and operation
   classes. Missing usable overhead evidence leaves the gate open. Budget at least
   `2 * (T + N * O)`, using per-class sums where overhead differs, and `2 * D` extra
   headroom beyond retained data; record how overhead avoids double counting.
   Fit the recorded job/pipeline/outage/disk limits. Recheck actual G against the
   same caps. The reference is 549 directories, 3,085 files, about 550 two-operation
   rotations and 86 permission changes per tree, 47 MB packed/81 MB unpacked.
   C repeats repository/client/shared-folder probes as the application account;
   those receipts are final because account proxy settings and permissions differ.
   Exit: pre-C safety and measured staging budget pass before C; C receipts and
   retained check-default evidence close remaining gates before E. These reads
   and replay are not authorized now and require no application-account shell
   or operations operator.

   Stop: any unresolved gate remains open; any dependency on an operations-side
   change is reported before restoration, never negotiated as an exception.

2. **Part B, consumer implementation and new-candidate qualification.** Implement
   P27-P32 and extend P07/P22-P26 with the fixed contract. Keep all sixteen former
   task checks in their consumer owners as mapped privately, with fatal status.
   P27 accepts exactly the literal/expanded stop-plus-stop-operand or start-only
   shapes; P28 installs a complete stable versioned closure outside replaced trees
   from verified application bytes, checks ownership/mode/realpath, rejects foreign
   launchers and separates immutable preparation from activation. P24 invokes
   mandatory preparation strictly, separate from convenience warnings; P07 prepares
   it through the current five-input path. Pin the running attempt's code version.
   Original-path activation belongs to P32 after held runtime success, hold release
   and same-daemon observation. Bootstrap activation belongs to P23 after those same
   complete checks in Part C, where P32 never runs. Manual/maintenance installs only
   prepare; neither P07 install success nor P24 refresh grants activation. P28 checks
   the path-specific success receipt, atomically renames the managed dispatcher and
   switches the version pointer under the lock. Never alter/delete pinned versions;
   a failed activation remains a failed attempt with the previous version usable.
   Derive the manifest from the transitive source/exec graph and enforce the stable
   versus application-runtime boundary described below, including P38.

   P30 validates the unchanged registry and exact controller downloads, then
   renders the canonical signing payload from the candidate. P29 verifies host-only
   signatures using release N's primary or offline backup public key; B qualifies both keys and verifier,
   their complete stable closure and missing/invalid/expired/replayed refusal. P22 preserves
   managed configuration, rejects native rollback, keeps the current payload for
   bootstrap and switches only at Part E. Its future original payload passes the
   exact immutable application URL with the fixed sort/direction suffix and the
   meaningful original variables. Remove delivery-task-only variables there;
   retain their information in consumer validation/selection, never as an
   orchestration parameterization. Dry run verifies all five published bytes,
   uses the original check job type, never arms, and reports two separate verdicts.

   P31 stop sequence is mandatory: verify host/non-root account/real prefix/loaded
   unit user and start/pre-start identity; under short coordination validate and
   snapshot valid signed deploy/recovery selection, rejecting live conflicts using
   the state table below. Missing or invalid selection receipts ordinary stop with
   local exclusion/archive identity/checkpoint, no signed reservation and no share
   reread; failed/held recovery gates remain mandatory. For Step 8 deploy rehash all four
   local retained inputs bound to C's controller-verified record, fetching nothing.
   Preserve the separately scoped exact-URL acquisition implementation/fixtures for
   Step 9; they cannot authorize a different-release selection in Step 8;
   verify every digest and ten unique allowlisted record keys without sourcing;
   record delivered-file identity and last-working release; enter and park the
   cooperative deployment hold within 55 seconds, preserving hook bridges and
   signaling only verified unit members; then bounded stack/daemon stop and
   no-survivor confirmation. No root, unit edit or service-manager stop.
   P25/P26 explicitly move parking before stack/daemon stop, replacing their current
   park-after-stop order. This changes Step 7's qualified lifecycle and requires new
   exact-byte qualification, including up to 55 seconds parked with the app running.
   Failure before hold preserves the incoming application state. On a fresh running
   entry, hold/park failure releases only the newly introduced hold, verifies restored
   supervision and fails. On an already held/stopped entry, hold/park is idempotent,
   there is nothing to stop, and any failure preserves the hold; never claim the
   application remained running. Later failure retains failed held state for recovery.
   P31 terminalizes each handled failure before returning nonzero, after its owned
   child processes have exited and under coordination. The fixed orchestration runs
   nothing further on the host after a failed stop; its unnotified handlers only
   remove a controller work path. Record the actual running or held state as below.

   P32 start downloads nothing and selects the mode from the durable snapshot and
   recorded versus current archive file identity, never recency/timestamp alone:

   | Stop snapshot | Archive delivered since stop | Mode |
   | --- | --- | --- |
   | Valid reserved deploy, matching | Yes | Deploy |
   | Ordinary stop, no signed deploy/recovery reservation | No | Unsigned checked restart |
   | Ordinary stop, no signed deploy/recovery reservation | Yes | Install nothing; checked checkpoint restoration and nonzero |
   | Valid reserved recovery | No | Typed recovery, even if no installer call is needed |
   | Valid reserved deploy | No | R16 checked restart; forward selection remains pending and unused |
   | Reserved selection mismatches delivery, or recovery has delivery | Yes | Refuse installation; checked checkpoint restoration and nonzero |
   | Missing local lifecycle record, unreadable or ambiguous archive identity, or unresolved competing state | Any | Refuse safely; never infer ordinary start |

   Missing or invalid selection permits ordinary stop only when lifecycle safety
   allows. Its start never rereads the share: unchanged delivery checks/restarts
   the checkpoint and returns check status; unauthorized delivery installs nothing,
   restores the checked checkpoint and returns nonzero. Failed/held or unresolved
   attempts still require their bound recovery. R16's valid forward selection with
   unchanged delivery uses its own reservation, checks the working release while
   held, releases only that reservation and leaves forward authority unused.
   Neither restart performs the deployment-only stop recheck. Reserved delivery/
   mode refusal similarly attempts checked last-working restoration and always
   fails; failed restoration stays held. Missing/ambiguous local lifecycle or
   checkpoint evidence refuses safely. For matching deploy mode,
   P32 first acquires the root lock and rechecks the reservation, then invokes
   P31's shared bounded stop-only primitive from the attempt-pinned stable closure.
   Revalidate host/account/prefix/unit, maintain hold/parking and idempotently stop
   verified survivors; confirm quiescence. Do not rerun prefetch/reservation setup,
   reset archive baseline/checkpoint, consume intent or acquire the same lock twice.
   Failure retains the failed held attempt, installs nothing and returns nonzero.
   Plain start, recovery and refusal omit this extra deployment-only recheck.
   Deploy then privately copies the
   role-retained downloaded archive, verifies the copy against selection, ignores
   the unpacked tree and rehashes the four retained inputs. Under the root lock,
   recheck the reservation and synchronously invoke only the verified entry with
   validated record values/private paths. Implement explicit lock ownership without
   deadlock or an unverified lock-bypass flag. Preserve installer nonzero status
   after its local snapshot restoration, retaining installer pending state for
   explicit bound recovery. The forward entry does not invoke rollback itself.
   P23 starts daemon first while held and
   verifies both local APIs, exact revision/environment, disk/launch agreement,
   clean/no-drift state and running components. Then release hold, prove the unit
   observes the same account/PID/boot/start-ticks daemon, and only then mark the
   attempt successful and advance last-working. Record single-use selection spend
   independently of success, including failed/interrupted use and the R16 exception. Re-hold on post-release failure. Plain start checks
   the current recorded release identically. Attempt-bound recovery under the same
   root lock selects its action from persisted installer state and the exact attempt
   checkpoint. With a pending record, validate its association and recovery value
   against the attempt checkpoint: a release identity must equal a release checkpoint;
   the installer's historical-predecessor marker is accepted only when the checkpoint
   is the retained historical predecessor; its no-target marker refuses held.
   Complete that check before invoking the verified offline rollback entry.
   That entry follows the pending target and invokes its retained entry. With no
   pending record and installed identity equal to the checkpoint, call no installer;
   run only held plain-start checks against the checkpoint. Any other or unreadable
   state refuses held. Preinstaller failure uses checked checkpoint restart and
   never calls the rollback switch. An attempt-bound recovery must never reach the
   no-pending index-predecessor branch, including after an earlier rollback succeeded
   but runtime checks failed. Intentional rollback to a prior successful release
   remains a separate explicit selection bound to a consumed checkpoint.
   Keep every log/receipt/control record outside rotating staging.

   Rebudget the deployment-only stable stop recheck, held start, diagnostics,
   both APIs, release and observation within
   the existing 600-second wrapper, with one overall deadline and per-phase caps.
   Preserve 90-second lifecycle bounds, 5-second unit queries and 55-second park
   while measuring the remaining allocation; do not append two five-minute waits.
   Stop retained-input verification has its own bounded pre-downtime budget;
   separately scoped acquisition remains bounded too. Installation and
   recovery fit the outer execution envelope with measured margin.

   Test: all fixture cases above plus the full design AC16/AC17 matrix; compare
   canonical and role URL hashes, reject moving resolution, and deny network in
   both predecessor recoveries. Prove the stable control operations and safe
   survivor handling below when application/tools trees are damaged and before
   installer pending state exists. Measure each gate's
   failure timing and original-status preservation. Implement locally only with
   separately authorized `ghog check` and `ghog affected`; no other local
   consumer validation command is authorized.
   Build a new immutable candidate through the complete Step 5 sequence and Step 7
   exact-byte qualification. Reuse evidence only after recorded unchanged-component
   comparisons, never for changed bytes. P37 binds that candidate; P20 documents
   the executing original path and no longer presents historical draft sources
   as the running roles.
   Exit: new qualified bytes, complete fixtures/negative evidence, all sixteen
   owners, acceptable deadlines, retained offline recovery and strict bootstrap
   are reviewable. Stop on failed qualification, unresolved file/lock ownership,
   missing bytes or any need for orchestration/publication-schema changes.

3. **Part C, bootstrap through current delivery.** Obtain separate explicit human
   authorization at execution time. Deploy the new candidate through the unchanged
   current temporary delivery path and five-input payload. Its verified P07/P28
   prepares the prefix dispatcher and stable targets; P23 activates them only
   after complete held readiness, release and same-daemon observation succeed.
   P30's controller-checked five-input binding reaches P07 through the existing
   payload. P07/P29 retain the verified release record and four other input
   identities outside staging. P23/P28 install release N's public key/verifier
   and supply A's before/after closure, unit, repository/client and shared-folder
   probes. Emit candidate/checkpoint, retention and activation receipts, with no
   forward selection, recovery authority or retry count. P30/P22 validate returned
   shared-log/console receipts before E. Account-specific shared-folder reads and
   proxy behavior are final authority; development-account evidence is preliminary.
   Pre-C staging budget and qualified attempt-state fixtures remain prerequisites.
   Failed bootstrap cannot activate prepared code. No operator session is needed.

   Test cold exact-argv invocation and stable closure ownership/identity outside
   replaced trees; verify healthy runtime and complete predecessor retention.
   Exit: bootstrap and recovery-entry evidence bound to candidate/installed version.
   Stop on missing/foreign launcher or failed install; do not restore the path.
   This proves bootstrap only, never original-path deployment.

4. **Part D, verify trust installation and signing handoff.** Check C's closure,
   public-key/verifier, probes, retained five-input record and same-release
   checkpoint receipts before E. There is no arming in C or target arming session.
   P30 renders exact canonical five hashes/URLs, operation, environment/profile,
   fresh attempt ID and short expiry for the human's workstation signature. The
   human writes the signed selection to the fixed per-environment shared-drive
   folder near each separately authorized real launch, after check mode where
   scheduled. Stop authenticates and snapshots it under coordination before
   mutation; consumed/attempted IDs remain outside staging. Check mode neither
   creates nor consumes selections. Target missing/unreadable/unsigned/expired/
   consumed/mismatched input grants no deployment authority and follows R19's
   ordinary admission and unauthorized-delivery refusal. Q37-Q41 are consolidated:
   backup trust is selected; utility/format and concrete folder evidence must be
   recorded before immutable qualification.
   Every G attempt/retry and I recovery gets its own signed ID and expiry;
   recovery also binds failed attempt and checkpoint. Stop rehashes four local
   retained inputs without fetch; later role archive must match the signed record.
   R16 A leaves forward authority unused after identified stop/start, with complete
   held runtime/supervision checks, its own reservation released and status receipted.
   No bootstrap retry count or reusable recovery authorization exists. After G
   success, failed H uses unsigned checked restart of the same working release.
   Test signature/key/member tampering, missing share, partial writes, clock/expiry,
   replay across cleanup/reboot, concurrent reservations, interrupted finalization,
   R16 success/failure, wrong/newer archives and both offline recoveries. A new
   recovery signature needs shared-drive delivery but never an artifact download.
   Exit: checked trust/retention receipts and reviewable signing procedure before E;
   actual fresh selection verified at each launch/admission. Missing evidence blocks.

5. **Part E, restore source and switch payload.** Obtain separate explicit human
   authorization for the normal operations-repository PR workflow. Fast-forward-only
   pull first; restore the entire application path from the recorded baseline,
   including deleting later additions; prove a path-only diff and retain concurrent
   commits as ancestors. No reset, force push, branch-wide revert or other-project
   edit. After normal merge, prove the baseline-to-remote-master application-path
   diff is empty and record the exact restored source loaded by orchestration.
   Only then switch P22 to the original-path payload, preserving job configuration.
   Test whole-path equality, ancestor preservation and loaded-source/payload match.
   Exit: these proofs and switch recorded. Stop on new conflicts, nonempty equality
   diff, mismatched/unknown loaded revision or pipeline/source disagreement;
   submit no real run until resolved within the authorized path-only scope.

6. **Part F, original check mode.** Obtain separate explicit human authorization.
   P22 verifies all five exact published bytes and the application URL equivalence,
   never arms, then invokes original check mode. Record skipped commands/downloads
   and any work-directory creation separately from controller verification.
   No target command executes or consumes any shared-drive selection in check mode;
   Part C has recorded no deployment or recovery authority. Capture inherited
   defaults from the console and compare them with Part A's evidence.
   Test failure propagation from either phase and absence of a new armed attempt.
   Exit: both verdicts and exact loaded identities recorded, runtime still untested.
   Stop on either failure; check success cannot authorize or qualify a real run.

7. **Part G, one real run.** Obtain separate explicit human authorization for the
   exact candidate bootstrapped in C and one original-path forward action launched
   by P22. The human signs a fresh attempt/expiry and writes it through the shared
   drive for this launch. Every authorized retry repeats that signing step with a
   new identity; no operator arming session or pre-recorded count applies.
   This is a same-release redeployment: preserve its existing predecessor index,
   never make it its own predecessor, and bind the attempt's last-working checkpoint
   to that same release. Failure recovers to that checkpoint, not an older index entry.
   Confirm all
   prior gates, clean terminal state and payload/source agreement. Record stop
   retained-input rehash with zero fetches and reservation, hold/park/stop, role transfer/staging cost, start
   mode, stable stop recheck, private copy/digests, synchronous install,
   both runtime APIs, hold release
   and same-daemon supervision, status and receipts.
   Remeasure actual staging duration and peak disk through retained task timing and
   consumer-script probes returned through existing shared logs/console, against
   Part A's fixed caps. P31 records the
   pre-staging time; P32 refuses installation on an exceeded elapsed cap at entry.
   Missing disk evidence or an exceeded disk/timing cap prevents AC16 completion
   and any next rollout; retain the failure and enter separately authorized I.
   Observation must not change the role or its configuration.
   Test the actual path against the exact qualified bytes and measured envelope.
   Exit: successful complete evidence pending independent verification.
   Stop on any nonzero/mismatch/timeout; preserve original failure and use Part I
   only after its separate authorization and terminal remote-process evidence.

8. **Part H, independent external verification.** Obtain separate explicit human
   authorization. Verify both external endpoints independently of pipeline output:
   expected revision, target environment, application account, hold absent and
   unit watching the same script-started daemon, with stable boot/start identity.
   Correlate independently read external responses with script-generated identity
   and unit receipts in shared logs/console. No target session supplies missing
   fields; an unobtainable field leaves the acceptance gate open for the human.
   Test external health/identity against the selected record and internal receipt.
   Exit: AC16 evidence bound to this actual original run. Stop on inconsistency,
   record failure and follow Part I; healthy APIs do not reconcile lost local
   configuration. Reboot remains UNTESTED and NONBLOCKING.

9. **Part I, failure recovery runbook.** Obtain separate explicit human authorization
   at recovery time. P22 proves the original orchestration job terminal before
   launching its original stop/start-only action. P31 itself verifies root-lock
   availability and absence of attempt-owned live processes under coordination,
   then records terminalization and admits a fresh signed recovery selection bound
   to the failed attempt and checkpoint. Each recovery retry has another signed
   ID/expiry, even after rollback succeeded but runtime checks failed. Cancellation
   or elapsed time alone is insufficient. Qualify the composed pipeline/local-proof
   route before E; no operator fallback. Missing/invalid recovery authority cannot
   bypass the failed/held or unresolved-attempt state gates and leaves them intact.
   Recovery fetches no artifact. For successful G followed by failed H, use unsigned
   checked restart of the same working release, retaining H's failure with no rollback.
   No conditional recovery authority survives success or failure. Keep receipts
   deliverable from the stable closure before application recovery; native staging
   rollback is rejected. A spent selection can never authorize another attempt.

   Before-installer failure uses the attempt checkpoint even with no pending
   record and calls no rollback entry. After-installer recovery follows the explicit
   pending/checkpoint decision above; repeated recovery cannot fall through to an
   older index predecessor. Preserve local snapshot handling and the original return code.
   Test both offline predecessor formats through the new stable entry, including
   role-download/staging failure that never called start. Apply identical held
   runtime and observer checks to the recovered identity.
   Exit: separate recovery verdict and receipts, original deployment still failed.
   Stop if terminal ownership is ambiguous or recovery fails; retain hold/evidence
   and report. Never restore the temporary task or alter orchestration to recover.

#### Confirmed restart admission and backup trust on 2026-10-05

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

#### Step 8 consolidated helper, identity and signing details

Q11-Q22 fix the six-file P27-P32 split, P23 runtime ownership and P38 closure
membership. P28 prepares immutable versions separately from activation; P32 owns
original-path activation and P23 owns bootstrap activation after complete final
success. P07/P24 and manual installs prepare only. P34 uses direct argv subprocess
fixtures with literal/expanded home forms, prefix cwd, verified ownership/modes
and explicit prefix HOME before runtime commands. Preserve ignored hangup and
non-terminal streams without a hangup output file; fake only lifecycle boundaries.

P29 retains a same-filesystem inode identity anchor outside rotating staging,
with owner/path/type and metadata/content mutation checks. Reproduce deletion
of the previous tree, rename, recursive copy and identical single-file copy.
Cover absent-before delivery, identical bytes, inode reuse, in-place change and
unreadable identity. Refuse cross-filesystem anchors or unsupported guarantees;
cleanup needs terminalization proof that no old start can use the anchor.

For Step 9 acquisition, pin one evidenced host HTTP client executable and its
capabilities, with a trust store covering the repository certificate. No silent
client, URL or TLS fallback is allowed. P36 covers redirect/HTTP failure, truncation,
timeout, exact canonical URL/hash, tools-hash reuse and retained-store mutation.
Step 8 G uses four retained inputs and zero fetches. P32/P07 reuse the existing
inherited lock descriptor and held-flag contract; the flag alone never proves
ownership. P35 covers competing attempts, stale reservations, nested recovery and
child failure, holding exclusion through synchronous installation and finalization.
Use one measured monotonic wrapper deadline, not independent nominal timeout sums.

Q34 assigns C coordination to P07, closure/key/unit/client/share and activation
receipts to P23/P28, and retained record/checkpoint receipts without arming to P29.
P30 validates the returned candidate/trust binding and P22 blocks E on missing
evidence. Receipt emission remains usable without damaged application code.
A's preliminary development probes and staging/overhead budget precede C;
C's application-account observations and retained check defaults close before E.

Q35-Q37 and Q40-Q41 assign one transition authority to P29. P30 renders canonical,
non-executable signing bytes with explicit version and operation domain, binding
five exact URLs/hashes, environment/profile, attempt ID/expiry and the applicable
checkpoint. Before freezing release N, evidence public-key formats/fingerprints
and available host utilities, then qualify one allowlisted verifier/algorithm.
Trust keys come only from the verified closure, never from the selection.
P35/P36 reject duplicate fields, malformed signatures, encoding or byte changes,
unsupported/downgraded algorithms, wrong keys and missing utility capability.
Keep private keys off the target, pipeline and evidence.

Use a fixed per-environment ready envelope, atomically published after temporary
writing, with private archived receipts separate. P29 bounds size and validates
path/type/ownership, verifies a stable snapshot, then copies authenticated bytes
into local coordination outside staging. Record exact folders, permissions,
retention and shared-filesystem publication semantics privately before immutable
qualification. Only the workstation must publish; separately evidence target
read and receipt-write capabilities. Never resolve by filename or modification
time. Partial/missing/unreadable envelopes follow R19 ordinary admission, not
deployment authority; ordinary mode never rereads the share.

Before signed lifecycle use, verify and durably reserve the identity under
coordination, blocking a second admission while pending. Once forward delivery
or recovery use is identified, persist spent state even on failure; unknown
interrupted use cannot be replayed. Local reserved/spent IDs survive shared-file
replacement, cleanup and reboot. Only identified R16 unchanged delivery may
release its own reservation and leave the forward ID unused, including checked
restart failure with a held-state receipt. Success advances working release
separately. Ordinary mode has local lifecycle state without signed reservation.
P35/P41 cover crashes before/after each persistence write, concurrent readers,
reboot/cleanup, late start and fresh recovery bound to failed attempt/checkpoint.

Q36 fixtures compose P22 terminal-job proof with P31/P29 local lock/process proof:
cover job-terminal/process-live and the inverse, cancellation-only evidence,
delayed start, transfer failure without P32, interrupted installer, checkpoint
mismatch and repeat recovery after rollback success but runtime failure. Include
R16 before/after restoration, every R19 invalid-selection category followed by
unchanged/delivered start, both local offline recovery formats and shared/console
receipts. Successful G followed by failed H uses unsigned checked restart with no
rollback and keeps H failed. These fixtures cannot close actual AC17.

Q38's selected backup key must be independently recoverable. P20 documents its
custody and use, replacement/revocation through a newly verified closure, and
unchanged replay/expiry/checkpoint controls before B. P28's manifest binds both
public keys. P35/P36 qualify primary unavailable, backup unavailable, unauthorized
key and interrupted rotation without creating or exporting real keys. Backup
signing does not revoke a compromised primary key automatically.

#### Step 8 stable control closure and runtime dependencies

P28's explicit manifest covers P27-P29, P31/P32, P23-P26 and P38, with member
hashes, interpreter/host-utility dependencies and every source/exec edge. P30 runs
on the controller and is not a target dependency. Code paths used before recovery
must not source the prefix environment or enter either replaceable tree.

| Operation or dependency crossing | Implementation boundary and required outcome |
| --- | --- |
| Dispatch, selection, reservation, archive identity, locks and retained-entry invocation | P27/P29/P31/P32 use the pinned closure, verified host utilities and retained inputs only; absence of application/tools trees cannot block these control operations. |
| Hold enter/park/release and same-daemon observation | P25 resolves P38 beside itself. Its stable hook bridges test hold first, then validate and observe the recorded daemon through P38 without loading the application environment. With no record or a previous-boot record, preserve today's exec of the installed runtime watcher and pre-start hook, including arguments; the bridge loads no environment. Held state parks as today. P24 preserves these bridges; no bridge may require an application-tree helper merely to hold or observe. P34/P35 prove all four paths and that the fallback cannot block the first unit start after boot; actual reboot stays untested/nonblocking. |
| P26 stop loading the prefix environment and calling the application wrapper | This is an explicit installed-runtime boundary. Anchor HOME first and validate installed identity. With missing/damaged runtime code, never execute it; use the verified-survivor procedure below or fail held. |
| P23 environment, application start and diagnostic collection | Application runtime is required after verified installation/recovery. Use explicit verified runtime paths for diagnostic helpers and their dependencies, not an assumed sibling inside the closure. Missing/damaged runtime fails held and cannot produce activation or readiness. |
| P23 convenience refresh | Resolve P24/P28 through the closure; preparation is strict and cannot activate on its own. |
| Optional evidence delivery helpers | Resolve only validated installed-runtime helpers after runtime is available; absence keeps local evidence and must not block control-plane recovery or change a failure into success. |

Before recovery invokes the retained entry's fully-stopped gate, P25 confirms
parking and P26 scans for survivors using host utilities alone. For each survivor
eligible for a bounded signal, require a retained identity receipt and revalidate
account, boot, PID, start ticks and installation/process role immediately before
signaling. Never signal a guessed PID from a name or broad account match. Record
identities when processes are started/observed and before stop. An unrecorded or
ambiguous survivor, failed signal or unresolved runtime dependency remains held
with a nonzero result and evidence; do not invoke the installer. When all survivors
are safely stopped or absent, re-scan and invoke the verified retained entry.
P35 proves this route with removed trees, PID reuse, missing receipts and failed
signals. The claim is survival of these stable control operations and safe offline
recovery when quiescence is proven, not successful application start from damaged
runtime code. Requirement Q11/design Q10 remain unchanged.

#### Step 8 durable attempt transitions and transfer-failure routes

P29 owns one strict state table shared by P31/P32 and exercised by P35. Every
transition checks identity and the coordination lock; installation/recovery also
holds the existing root lock. A fresh attempt has a new selection identity, even
when its candidate equals the failed attempt's candidate. Preserve earlier evidence.

| Persisted state before a new stop | Accepted new stop and next state |
| --- | --- |
| No attempt | Valid fresh deploy/recovery reserves signed authority; recovery also needs its retained checkpoint and failed-attempt binding. Missing/invalid selection admits ordinary stop with local exclusion, archive baseline and checkpoint, no signed reservation or share reread. All lifecycle safety gates apply. |
| Reserved | Refuse a new stop while any owning job/process may be active. After proven terminal interruption, record failure before installer with the evidenced running/held state and use that row. |
| Held and stopped, awaiting start | Original matching start may proceed. Refuse a new stop until job and remote-process terminal evidence proves start cannot still arrive, then record failed and held before installer. |
| Installing | Refuse every competing stop/start. After proven process termination, record failed and held after installer and retain the installer's pending/recovery evidence. |
| Failed before hold, application running | P31's handled failure is self-terminalized. Accept a fresh deploy, including the same candidate, or an unsigned plain restart without maintenance-channel terminalization or recovery. Preserve the running application and never invent a hold. |
| Failed and held before installer | A fresh deploy may supersede it, including retrying the same candidate, with recorded terminal proof and the exact old last-working checkpoint. Accept P31's self-terminal receipt for handled stop failures. A freshly signed recovery bound to this failure restarts the checkpoint with no rollback call. Refuse plain restart and all other inputs. |
| Failed and held after installer | Accept only freshly signed recovery bound to this failure and its installer state, after terminal-owner proof. Validate pending association and recovery value against the attempt checkpoint before rollback: a release identity must equal a release checkpoint; the historical-predecessor marker requires the retained historical checkpoint; the no-target marker refuses held. With no pending record, allow only an already installed checkpoint and held runtime checks without an installer call. Otherwise refuse held. Refuse fresh deploy and plain restart until recovery completes. |
| Consumed | Permit a fresh signed deploy or unsigned plain restart; explicit rollback needs a fresh recovery selection bound to the retained successful checkpoint. Reject reused consumed selections. |
| Recovered | Preserve the original failure and separate recovery success; permit a fresh signed deploy or unsigned plain restart. Any later recovery requires its own valid checkpoint and fresh selection. |

A successful normal stop records held/stopped. Start durably records installing
immediately before invoking the entry, then successful only after all final gates.
The table's Consumed row means a successfully completed forward attempt; signed
selection spend is separate and also survives failures.
An interrupted installing state is conservatively after-installer failure. A failed
plain restart that never installed remains failed-before-installer. P31 terminalizes
its own handled failures while holding coordination, after all owned children exit:
before hold with the application running, record the running-failure row; after hold,
record the held-failure row. An already held entry stays held even if acquisition
fails. A safely unwound new hold with verified restored supervision records running
failure. Preserve the actual incoming/restored state; never invent a hold or claim
an unverified running state. P35 proves immediate fresh retry after fetch failure.

For killed/interrupted reserved/installing processes and held/stopped awaiting
start, P22 first retains proof that the preceding orchestration job is terminal.
Only then may it launch the authorized original stop/start-only recovery action.
P31/P29 check local terminal proof themselves: root lock free, no attempt-owned
process alive, identities unambiguous. They bind that receipt to the stored Part G
attempt before transition. The target does not claim to read controller job state
from fixed arguments; P22 owns that separate launch gate. Unknown job state blocks
launch; unknown local state refuses held. Tests prove both gates together exclude
an old start, including job-terminal/process-live and process-dead/job-live cases.
No maintenance-channel terminalization exists in Step 8. Handled stop failures
retain their self-terminal receipts. Terminalization never changes the original
result. Stop on an already held,
stopped installation preserves that hold, parks idempotently and stops nothing.
Park failure there never releases the hold. Preserve the checkpoint when a fresh
attempt supersedes a failure; only its new archive baseline and selection are new.

Validate signature, unspent identity and short expiry on every signed deploy/recovery
admission, including recovery retries. Ordinary mode has no signed reservation. Reserve immutable authenticated bytes under coordination outside
staging. Q35/Q41 distinguish the signed selection ID, local reservation and success:
failed/interrupted forward use must remain spent; only identified R16 stop/start
releases its reservation while leaving forward authority unused. Recheck expiry
on later admission of that pending selection. Bind an admitted reservation to a
monotonic deadline covering measured staging, start/recovery and outer job limit;
do not reapply the shorter transfer expiry at start. Exceeded deadline fails held.

Cleanup removes the hard-link anchor only at proven terminalization/finalization,
after recording its identity and ensuring no old start can still use it.

P35 covers pipeline job-terminal gating, local terminal proof in the next original
stop, and bound recovery through its paired start, including transfer failure
before start was ever called. Fresh shared-drive signatures cover real retries
after restoration without application-account access. Route (b) is Step 9's
one-time production/new-environment bootstrap only. None can collide with an old running
process or turn the original failure green.

#### Step 8 shared staging non-collision invariant

Retention, independent selection, reservations, checkpoints and journals stay
outside staging. P07 and historical entries still use staging for legacy archive
selection, completion markers and recovery copies. Do not remove those existing
recovery paths. For every real candidate, derive the role's rename/write name set
from all unpacked directory basenames at every depth, all top-level members, the
literal download name and generated previous-version names. Prove it disjoint
from every staging name used by P07 and each retained historical entry; also prove
none of the role's written names matches their archive/marker selection patterns.
Include pre-populated staging and symlink/type refusals. P35 generates this check
from the actual member list for each candidate and both predecessor formats;
a collision blocks qualification before bootstrap/restoration. No blanket claim
that the installer never uses staging is made.

Completion criteria: AC16 and AC17 close only on actual authorized execution
through these paths, bound to exact immutable bytes and independently observed
identity. Fixtures, static inspection, check mode, bootstrap through the temporary
task, and prior Step 7 success do not close them. All thirteen findings have the
tasks/tests/exits above; every former delivery-task responsibility has a fatal owner.
Whole-path baseline equality and concurrent-project ancestry remain mandatory.
Parts C and E-I each require separate explicit human authorization at execution
time; this plan grants none. Unclosed prerequisites leave Step 8 incomplete.

This completion establishes qualification-environment delivery and recovery only.
It closes neither first-time installation nor production deployment and cannot
complete the topic or its umbrella item. Those require Step 9 and AC18/AC19.

#### Step 8 addendums

Line-budget checkpoint:

- [ ] Recount the six public Markdown documents above before/after; no Python ceiling.
- [ ] Recount P07/P20/P22-P26 against 996/219/75/177/156/173/277 lines respectively.
  They are non-Python; keep separate responsibilities rather than growing P07
  into dispatcher, acquisition and runtime verification at once.
- [ ] P27-P32 begin at 0; P30 is Python, below 550 at baseline, ceiling 650.
  The five shell files have no Python ceiling; maintain a clear stable helper closure.
- [ ] P33-P36 start at 0, Python safe band with ceiling 650; split fixture groups
  by dispatcher, lifecycle and acquisition responsibility if any exceeds 650.
  P33 remains an empty package marker.
- [ ] P37 starts at 0, non-Python; registry schema stays unchanged.
- [ ] P38 starts at 57, non-Python; recount closure members and classify every
  source/exec edge, with no unlisted pre-recovery dependency.
- [ ] At 550-650 Python lines avoid growth where practical; split only above 650.
  Candidate parsing versus controller byte verification is P30's first split point;
  do not pre-create speculative files.

Full workflow timing run readiness: record separately pre-stop acquisition,
hold/stop, immutable role staging, verified install, held APIs, release/observer,
and failed-attempt recovery. Gate on measured upstream budgets and accepted outage.
Use only authorized `ghog check`/`ghog affected` locally; repeat the existing
complete Step 5 and Step 7 candidate workflow under its execution authorization.
No new reusable acceptance-driver mode is planned.
Time-gated status: existing limits and measured staging fit are hard rollout gates;
no new arbitrary timeout/xfail waiver and no static substitute for runtime evidence.

Step inspection: read mapped P07/P22-P32 and P34-P38 against every mode/owner/gate;
inspect generic AC16/AC17 evidence bindings in the validation plan. Do not run
a broader test command or target probe as an inspection shortcut.

### Step 9. Deliver first-time and production installations through unchanged orchestration

#### Step 9 analysis and intent

Implement requirement Q12/AC18-AC19 and design Q11 only after Step 8 has actual
AC16/AC17 closing evidence. Step 8 remains qualification-only. This mandatory
step removes dependence on the temporary delivery task for a new environment
and for production's historical shipped-environment release. Conform to each
original contract without any variable, role, template, job or operations change.

Expected outcome: independently verified scripts-only bootstrap enables the
first original stop, empty-prefix delivery handles an absent predecessor honestly,
and production upgrades its actual historical pair with a proven offline recovery
route. Existing provisioning, unit identity, managed pipeline/template, repository
access and arming access are environment-specific evidence gates. No fixture or
qualification-environment result substitutes for the two required rehearsals
and actual production execution. The topic and umbrella remain pending until then.

Complexity impact: control preparation and historical retention stream hashes
over explicitly selected files. Profile and attempt operations address one
environment/attempt, never scan history to choose a release. Reuse Step 8 locks,
closure, acquisition and runtime owners. No reusable cplx runtime or acceptance
driver change is planned; cplx deliverables are documentation and evidence binding.

#### Step 9 selected development replay venue

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

#### Step 9 one-time bootstrap and signed arming gates

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

Bootstrap precedes an environment's first original-path deployment, outside its
pipeline. Transfer the registered published archive plus independently bound
digest/profile into a private work area outside staging/replaced trees. Verify
the whole archive before safe allowlisted extraction, and every closure member
before execution. P30 prepares the instructions; P28 first-activates under the
root lock with verified pointer and dispatcher published last. P39 prepares exact
historical retention where needed. P28/P39/P29 non-dispatch inspections receipt
completion without installing an application or arming. On a verified empty prefix
only, P28/P25 also install initial hold-aware hooks with hold set.

Receipt-bound interruption can resume the same verified phase under the lock;
unknown state refuses. Before dispatcher publication the original stop fails;
afterward incomplete-bootstrap state refuses before mutation, including unchanged
staging. P40 covers every cut point. After completion, each fresh signature is a
separate workstation/shared-drive action, checked by P30/P22 before launch and
P29/P31 at admission. Later successful deployment activates its own stable version;
never repeat first activation. Recovery uses the same fresh-signature mechanism.

| Bootstrap, rehearsal and arming gate | Selected route and remaining evidence |
| --- | --- |
| Part C first-install replay | Development installation/account on qualification host; separately authorized confined empty-prefix preparation/restoration, verified closure and explicit no-unit profile. No operations operator. |
| Part D historical replay | Same venue; retained exact historical archives, production pairing evidence, authorized preparation/restoration, offline recovery and explicit no-unit limits. |
| Part F production bootstrap | Route (b) once: named operations operator, existing application-account access, exact self-verifying archive/closure/retention commands and receipts. Route (a) unavailable. |
| New environment bootstrap | Route (b) once with environment-specific identity/provisioning evidence; do not request access or configuration changes. |
| Every deploy, retry and recovery | Human signature through fixed environment folder on shared drive, verified with release N's public key. Fresh ID/short expiry, exact five inputs and checkpoint binding, durable replay prevention. No recurring operator access. |
| Trust and implementation evidence | Q37-Q41 are consolidated: one evidenced verifier, offline backup key, versioned P43 replay, atomic ready envelope and durable reservation/spend. Exact formats, fingerprints, folders and publication semantics require evidence before immutable qualification; no policy choice remains open. |
| Unit evidence and accepted limits | DEV replay proves neither managed orchestration nor unit behavior. Step 8 G proves running-release managed unit behavior. Fixtures plus route (b) read-only production unit evidence support first real production hook/bridge execution. |

Concrete hosts/accounts/shares, commands and receipts stay private. A chosen route
is planning direction, never a receipt proving access or authorization to execute.

#### Step 9 implementation

Files involved:

- Versioned P43 replay helper, baseline 0 before Step 8: extend the qualified
  staging-only mode with confined development lifecycle replay after AC16/AC17.
  Q39 records its selected path privately; record its actual post-Step 8 size before growth.

- The same six public effort documents listed in Step 8, with the umbrella row
  remaining pending; preserve all Steps 1-8 records and earlier acceptance rows.
- P07 installer: explicit first-install retry reconciliation and validation of
  prepared historical retention; leave both existing offline recovery formats.
- P20 deployment reference and P22 consumer deployment pipeline: environment
  evidence gates, approved managed routing, release-only production selection,
  approval-aware timeout/admission and separate execution/recovery runbooks.
- P23/P25/P26/P38: explicitly bound historical runtime checks and observed unit,
  hold/bridge, survivor and same-daemon handling; preserve modern gates.
- P27-P32: reuse dispatcher, strict installation, state/profile, controller,
  stop and start owners. P28 adds only the guarded first-activation entry;
  P29 owns explicit empty/no-predecessor states and validated profile binding.
- New P39 historical-retention helper, baseline 0: verify and prepare the
  installer's existing historical layout from independently approved archives.
  Keep acquisition/bootstrap policy out of the already large P07.
- Existing P33 marker and P34-P36 fixtures: preserve Step 8 regression coverage.
  Add P40 bootstrap/profile, P41 empty-install/retry and P42 production/historical
  test leaves, baseline 0 each, beside them; reuse parent markers and fixtures.
- P37 pattern: new immutable candidate registry entries in the existing schema,
  one per newly qualified candidate. Environment profiles and concrete receipts
  remain private; do not put hosts or job identities in public configuration.

Recount all existing consumer files after Step 8 rather than treating its planned
baseline as the new size. P39-P43 paths and source facts are in the private mapping;
Q39 selects the versioned P43 helper there before implementation.
Publication/assembly owners remain unchanged unless a demonstrated omission is
reported before scope expansion. No operations repository is a Step 9 edit target.

Tests first: retain all Step 8 subprocess fixtures and add behavioral cases for
verified scripts-only bootstrap without an application/toolchain, first activation
guard races, foreign/corrupt pointers, receipt-bound interrupted preparation and
prepare-only behavior when a stable version exists. Test empty-prefix stop,
same-byte delivery, first-install success, prefetch/refusal/installer/start failures,
explicit no-target recovery refusal and safe fresh retry after each terminal state.
Mutate profile fields, types, duplicate keys and digest bindings; P23's historical
profile is accepted only for the exact retained identity. Verify bootstrap extraction
rejects unsafe paths, links, special entries and member mismatch before any
extracted executable runs, with no new publication object.
Include successful installer exit/index promotion followed by failed first
runtime readiness: the index is provisional until full first-install success,
never a last-working checkpoint or its own predecessor.
P40 covers an original-path stop before the closure exists, between verified
pointer publication and dispatcher publication, and after dispatcher publication.
It also proves that a unit restart between historical bootstrap and the first
approved stop still uses unchanged historical hooks/runtime, then that the first
stop bridges only the hooks evidenced in that environment's profile. P41 covers
a later retry failing after installer entry with recovery naming the provisional
release: typed recovery refuses against the no-predecessor checkpoint, held and
nonzero, with no restart or rollback.
Assert no historical restart is invoked when absent and no modern gate silently
falls back to the historical profile. Cover mismatched per-environment unit/profile,
snapshot rejection, full approval wait, queue expiry, cancellation and unchanged
candidate identity. Rehearse verified historical retention both with and without
staging archives/markers, missing exact archives, wrong tools pairing and corrupted
retention. Actual rehearsals below are separate evidence, never fixture claims.

Classes and behavior (existing owners and focused script functions):

1. Part A, dependency and environment evidence. Verify Step 8 AC16/AC17 evidence
   before beginning Step 9 implementation or execution. For each new/production
   environment, prepare a private gate ledger for pre-existing account, home,
   scripts/staging folders, permissions, host utilities, unit user/start/pre-start,
   runtime interfaces, fixed vars/source identity, inherited defaults, managed
   job/template, target repository/shared-folder access and one-time route (b)
   bootstrap identity. Separately authorized read-only production evidence must
   observe actual historical archives/markers, installed pairing and unit hooks.
   DEV C/D use the selected development venue and explicit no-unit profile; record
   confined preparation/restoration authority and retained historical archives.
   Exit: evidence-bound profiles, exact historical inventory and known rehearsal
   limits. Missing access, provisioning, identity or routing blocks its gate,
   without a request to change operations. Step 8 already qualifies/installs the
   public key and signature verifier; Step 9 reuses them for different releases.

2. Part B, consumer implementation and immutable qualification. Extend P30/P29
   to render/parse the strict private profile and its digest in the independent
   selection, without changing the release record or registry schema. P22 selects
   only evidence-backed existing managed routing and rejects snapshots for
   production before invocation; P31 repeats the release/profile gate at reservation.
   P30 prepares the release-bound archive transfer and exact self-verifying
   session instructions; P28/P39/P29 supply the checked phases and non-dispatch
   inspections. P29 gates incomplete bootstrap separately from signed admission, and P22 requires
   the checked receipts. Q31-Q33 allocate these implementation details.
   P28's standalone verified entry prepares the full host-Bash closure and performs
   guarded first activation under the root lock, with receipt-bound interruption
   recovery. Verify the complete closure, publish and verify its version pointer,
   then publish the dispatcher last by atomic rename. A concurrent original-path
   stop before dispatcher publication fails at the role's stop task with the
   historical runtime untouched or the prefix still empty; afterward it reaches
   the complete closure. On a running historical installation, bootstrap writes
   only the stable closure, version pointer, dispatcher and consumer control
   folders; unit start/pre-start hook paths remain untouched until the first
   approved stop enters the deployment hold and installs the hook bridges.
   Existing activation rules are unchanged for an installed stable version.
   On verified empty/inactive prefixes implement option (i): install hold-aware
   hooks with the initial hold set. Fixture unexpected unit restart and every
   publication cut point; retain no-hook-write on installed/running releases.
   P23 and P25/P26 use explicitly selected modern/historical profiles.
   P39 safely extracts the unique original entry from the verified historical
   archives, prepares existing retention atomically under the root lock, validates
   using P07's reader and never creates synthetic completion markers. Implement the empty-prefix
   table below in P29/P31/P32 and P07's journal-based retry, with no guessed cleanup.
   Run only separately authorized `ghog check` and `ghog affected` locally.
   Build and qualify changed bytes through the full established candidate workflow;
   production consumes only its qualified, published release binding. Exit: all
   fixture mappings pass and exact candidate/evidence identities are frozen.
   Stop on failure, changed bytes or an unresolved runtime/profile dependency.
3. Part C, separately authorized development first-time replay. After AC16/AC17,
   prepare an evidenced empty prefix inside our development installation on the
   qualification host, preserving/restoring its own prior state. Do not disturb
   qualification. Verify the published archive, guarded scripts-only bootstrap,
   hold-aware hook placement under option (i), dispatcher-last publication and
   non-dispatch receipts. No operations operator; use our development account.
   Sign each real replay attempt/retry freshly through its development folder.
   P43 replays the task-mapped exact stop/download/unpack/rotation/copy/permissions/
   start sequence without Ansible, testing literal and expanded HOME argv and
   avoiding an intermediate shell where the original uses none. Exercise empty
   stop, five-input gates, first install, refusal/partial failure/no-target states
   and safe fresh retry. The explicit DEV no-unit profile makes unit checks
   inapplicable and labels the evidence accordingly; it never reports them passed.
   Fixtures and route (b) read-only production evidence back first-install unit
   hooks, whose first real unit execution is production. Exit: AC18 replay evidence
   plus Step 8 managed running-release proof, with these accepted limits. Stop on
   unknown state, boundary escape, unsafe retry or missing required runtime evidence.
4. Part D, separately authorized development historical replay. Use the same
   confined venue/account and exact retained historical archives, verifying the
   application/tools pairing against production evidence before claiming AC19
   historical coverage. Preserve the development restoration inputs. Verify any
   existing stable receipt instead of repeating bootstrap. Prepare P39 retention
   both with and without staging markers, never fabricating markers. Human signs
   each upgrade/recovery/retry selection with failed-attempt/checkpoint binding.
   P43 replays original task/argv/staging behavior, upgrade and offline rollback,
   including failure before entry, typed pending recovery, repeat checks after
   rollback success/runtime failure and intentional successful-upgrade rollback.
   Artifact services are denied after inputs are local; shared-drive signed
   control remains available. Record supported historical APIs and independent
   identity; modern checks cannot downgrade. DEV has no unit: historical bridge,
   parking and same-daemon behavior are fixture/production-evidence gates until
   their first real production execution. Exit: exact-pair replay and offline
   recovery with honest limits and preserved failed verdict. Stop if pairing,
   identity or local recovery is unproven, or any operations change is needed.

5. Part E, production readiness and bounded approval. Revalidate production
   evidence under separately authorized access. P22 budgets the unchanged
   two-hour approval plus bounded queue/dispatch, measured stop/staging/start,
   external verification and safety margin. Use one validated timing record with
   numeric caps in the private profile and prove its sum fits existing outer limits; change
   only our pipeline timeout. P30 renders a target-bound selection for the human to sign with enough
   admission lifetime for that bounded pre-stop envelope; P31 rechecks it at
   reservation. Use a fresh monotonic execution deadline thereafter. Test the
   full approval wait virtually and qualify actual timing later; no workstation
   two-hour sleep is a test. Establish production repository access and arming
   channel separately. Inspect the immutable approval task's check-mode behavior
   and scope before any separately authorized check traversal. Exit: AC18 and
   Part D passed, exact release-only candidate, budgets, historical retention,
   authorized actors and recovery procedure ready. Stop on any stale/unclosed gate.
6. Part F, separately authorized production bootstrap and delivery. Route (b) is
   selected once: the evidenced named operations operator runs our exact
   self-verifying commands as the application account in a separate session.
   Verify the registered archive, safely extract/reverify the closure/key/verifier,
   first-activate with dispatcher last, prepare exact historical retention and
   inspect receipts without dispatcher stop/start. Installed/running release,
   staging and hooks remain untouched until the first pilot-approved stop enters
   hold and bridges its evidenced hooks. No application install or arming occurs
   in bootstrap. Interrupted preparation blocks launch until receipt-bound repair.
   Later deployments never repeat bootstrap or require operator arming. Human
   signs each attempt/retry/recovery on the workstation, using the production
   shared-drive folder and newly chosen short expiry. P22 gates exact existing
   managed routing, release-only inputs and receipts; stop rechecks signature,
   profile, expiry and replay state. Dry run remains unarmed with separate
   controller/traversal verdicts. Real production requires separate human
   authorization and unchanged pilot approval. Expired/cancelled approval never
   reaches stop. P22 refuses expired signing descriptors; if expiry is discovered
   at target admission, R19 applies: no deployment reservation or installation,
   ordinary stop only where state permits, and delivery fails after checked
   restoration. URLs/hashes stay fixed.
   First real historical hook bridging is production, backed by fixtures and
   route (b) unit evidence, with all fatal modern runtime and unit gates enforced.
   Exit: actual production plus independent external evidence for both endpoints,
   release/revision/environment/account, absent hold and same script-started daemon.
   Stop on mismatch; successful orchestration alone cannot close AC19.

7. Part G, production failure and completion. Preserve terminal job/process proof,
   failed attempt, inputs and diagnostics. Before installer entry, restore the
   historical checkpoint without rollback; after entry, validate the typed pending
   recovery target and use its retained entry offline under the root lock. Run
   the bound historical health/identity checks, release hold only after readiness
   and verify same-daemon observation. A failed restore stays held and nonzero.
   Even if the role never reaches start, use a fresh signed recovery selection
   with the proven pipeline original stop/start action and local terminal proof.
   Each recovery retry is newly signed; no operator recovery access is required.
   Recovery requires its own authorization and never clears the failed production
   verdict. Exit: bind actual AC18/AC19 evidence and retained recovery readiness in
   the validation plan; only then may the topic and umbrella item complete.

#### Step 9 empty-prefix transition extension

This explicit first-install extension applies only to an independently evidenced
empty prefix with the scripts-only bootstrap already present. It does not change
Step 8's running/held checkpoint table or typed no-target refusal for recovery.

| State and trigger | Required result and owner |
| --- | --- |
| Verified empty/inactive, fresh first-install deploy | P31 validates all identities and four inputs, records no predecessor, holds/parks and proves no survivors; stop succeeds without runtime code. |
| Empty, pre-hold fetch/identity failure | P31 records terminal failure and preserves actual empty/inactive state; no claim of running application and no restart or rollback. |
| Held empty, delivered archive with matching deploy | P32 performs pinned stable stop recheck, verifies all five inputs and calls P07's first-install path; full modern runtime gates precede consumption. |
| Held empty, refusal or failure before installer | No installation/restart/rollback; fail held and retain no-predecessor checkpoint. Fresh selected deploy requires terminal proof. |
| Failed first install after entry, no-target pending value | Retain journal, partial state and held failure. Explicit recovery refuses; ordinary start and an unqualified competing deploy refuse. |
| Installer succeeded but first readiness failed | Keep the no-predecessor attempt and held failure; any installer-written current index remains provisional. Only receipt-bound retry reconciliation may handle it, never a guessed recovery or self-predecessor. |
| Later retry fails after installer entry with pending recovery naming the provisional release | P41 proves bound recovery refuses under the typed checkpoint rule because no predecessor exists. Remain held and nonzero; no restart or rollback runs. |
| Fresh authorized first-install retry after terminal proof | P07 reconciles only prior attempt-owned paths/state under the root lock with P29 transition checks. Archive previous evidence, preserve no predecessor and begin a new selected attempt; unknown paths/processes refuse. |
| Full first-install readiness and same-daemon observation | Consume attempt, establish first last-working checkpoint and activate successful stable version; subsequent operations use Step 8's ordinary rules. |

Completion criteria: AC18 development first-install replay, exact historical-pair
upgrade/offline-rollback replay and actual AC19 production/external evidence are
mandatory after AC16/AC17. Bind authorizations, exact bytes, development no-unit
limits, Step 8 managed unit proof, and fixture/read-only production evidence for
first real unit-hook/bridge execution. Route (b) bootstrap needs actual receipts;
Q11-Q41 are consolidated, including backup trust and the versioned replay helper.
Tooling, concrete layout and operational evidence gates still require proof. No operations change, check traversal or fixture replaces a required
execution. Topic and umbrella remain pending until Step 9 is validated.

#### Step 9 addendums

Line-budget checkpoint:

- [ ] Recount all modified P07/P20/P22-P32/P38 after Step 8 and before editing.
  Keep P07 an installer; P39 owns archive-retention preparation.
- [ ] P39 begins at 0, shell; keep a single focused responsibility and include
  it in a verified maintenance helper manifest, outside runtime dispatch unless
  an explicit dependency is documented.
- [ ] P40-P42 begin at 0, Python; split bootstrap/profile, empty retry and
  production/recovery fixtures before any exceeds 650 lines. At 550-650 avoid
  growth where practical. P30 retains its existing split rule above 650.
- [ ] Recount public documents and update private file handles/evidence paths;
  preserve every earlier implementation record and registry schema.

Full workflow timing readiness: measure bootstrap separately from deployment,
record production approval/queue allowance separately from outage, then reuse
measured acquisition/hold/stop/staging/install/API/observer/recovery phase caps.
Prove admission expiry, execution deadline and existing job limits compose without
extending any operations limit. Local validation remains permission-bound
`ghog check`/`ghog affected`; each rehearsal, target read, bootstrap, arming, check,
production run, external verification and recovery needs its stated authorization.
This plan and its review authorize none of those actions.

Step inspection: check P07/P20/P22-P32/P38-P42 against the state table, per-environment
gate ledger and AC18/AC19 mapping. Missing actual evidence leaves the step not
implemented. Record unresolved design alternatives for the human; do not settle
them through plan implementation questions.

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
| AC02 archive-only installation | 1, 3, 4, 5, 7, 8 | Complete locally supplied application, script, release record, tools archive and companion (uv/wheels/metadata/transport/helpers); bootstrap on both platforms without an existing application venv or target Git checkout. Consumer acquisition is separately validated. |
| AC03-AC05 exact environment and locked sync | 1, 3, 5, 7 | Exact interpreter/environment selection, repeat/recreated venvs, canonical lock and selected groups; deliberate drift blocks readiness. |
| AC06 offline cplx reconstruction | 1, 3, 4, 7 | Deny remote services after local delivery and before cplx invocation; empty disposable caches, no target Git checkout, complete verified local inputs. Missing or invalid input fails before mutation without fetching; complete inputs reconstruct and pass readiness. |
| AC07 wheel and distribution integrity | 2, 7 | Complete inventory and library/bin ELF comparisons |
| AC08-AC09 cross-platform runtime | 5, 7 | Debian ABI/live providers; RHEL applicable readiness matrix |
| AC10a-AC10b equivalent CI and truthful outcomes | 5, 7 | Actual-agent before/after provenance and deliberate failures |
| AC11 validation without publication | 5, 7 | Executed-command evidence in both phases, override attempts |
| AC12 predecessor recovery | 4, 7, 8 | Both offline rollback paths; predecessor script, helper payload, input record and tools binding; no network or current-helper fallback |
| AC13 public/private separation | Every step, including 8 | Sanitized public files and separate private mapping/evidence |
| AC14 prebuilt dependency wheels | 1, 3, 5, 7 | Compatible prebuilt wheels only; missing compatible wheel blocks readiness, no dependency source build, and no application build/install during dependency sync. |
| Design retained inputs and complete delivery | 1, 4, 6, 7, 8 | Complete local inputs before reconstruction and repository-independent predecessor recovery. |
| AC15 serialization and changed toolchain identity | 3, 4, 7, 8 | Competing mutations excluded and equal-version revalidation |
| Design Q08-Q09 candidate/promotion boundaries | 5, 6, 7 | Retention across later builds, exact-candidate qualification, immutable promotion |
| AC16 original forward delivery | 8 | Actual same-release original-path deployment; fresh signed selection, four-input local rehash, all fatal checks, R16 restart preservation, baseline/source/ancestry proof, separate dry-run verdicts and shared/console/external evidence. |
| AC17 original-path explicit recovery | 8 | Fresh signed failed-attempt/checkpoint recovery on every try, both offline formats, preinstaller failure, pipeline/local terminal proof, held runtime/supervision and original failure retained. |
| AC18 first-time delivery | 9, after 8 | Selected development replay with exact task/argv/staging trace, verified scripts-only bootstrap, option (i) hooks, no-predecessor failures and signed retry. Accept with Step 8 managed run; DEV proves no unit behavior. Fixtures and route (b) production unit evidence back first real hooks in production. |
| AC19 production delivery | 9, after 8 | Exact retained historical-pair development replay/offline rollback plus Step 8 managed proof, with stated no-unit/replay limits. Route (b) bootstrap once, fresh shared-drive signatures, existing release-only approval-aware managed production and external same-daemon evidence. Historical bridges first execute for real in production. |

Private implementation and execution evidence are mandatory completion inputs.
If target access, observation compatibility, candidate retention, operator setup
or publication authorization is missing, record the specific open gate and
leave its step incomplete. No local lint, unit test, probe or Jenkins success
label alone establishes the full acceptance result.

The 2026-10-03 accounting amendment preserves the recorded Step 1-7 validation
and adds Step 8 as not started. Earlier planning-time status statements are
historical. AC16/AC17 remain open until their own actual execution evidence exists.

The 2026-10-04 amendment limits those rows to qualification and adds mandatory
Step 9 as not started. AC18/AC19 cannot close before AC16/AC17 and their own
actual evidence. AC02, AC12, AC13, AC15 and retained-input obligations also apply
to Step 9. Keep umbrella item 8 pending until the entire expanded topic is validated.

## Implementation decisions

Human consolidation on 2026-10-05 settles Q11-Q41 option A after round 10.
R19 confirms restart-independent admission with the stated unauthorized-launch
downtime tradeoff. Q38 confirms an independently held offline backup signing key,
whose public key joins the primary in release N. R20's pre-B documentation and
trust qualification gates remain. No follow-up planning question remains;
Steps 8 and 9 remain unimplemented and unvalidated.

Human-authorized consolidation after review round 3 confirms Q01-Q07 option A
and Q08-Q09 option B. Their implementation tasks and evidence gates are integrated
below and in the named sections. At that original consolidation, implementation
and real integration qualification had not started. Steps 1-7 are now completed
with their retained evidence; the later Steps 8-9 remain pending.

Human-requested amendment on 2026-09-24, before Step 3 started: move Step 5's
non-qualifying actual-agent probe forward as Step 3b, so that the mandated
pipeline runs on actual agents as early as possible. It reorders an existing
task; it changes no design decision, no acceptance row and no step's completion
criteria other than Step 5 item 2 reusing its results.

Human decision on 2026-09-25, before Step 5 started: phase 2's test scope is
settled by diagnosis, as Step 5 item 9 orders it. The probes found the complete
suite several times slower inside the mandated test command than in phase 1,
and the mandated pipeline lost its outer allocation before its later stages.
The complete suite is tried first, with the mandated analysis stage at its
default scope. A declared smoke selection, phase 1's coverage report and an
application-source analysis scope replace it only if that failure is confirmed
and its cause recorded. The decision keeps the two-phase order, the blocking
phase 1 full-suite coverage gate, the shared library unchanged and every
acceptance row as written. Under the smoke selection, the mandated analysis
stage no longer reviews files outside the application source.

Later human amendments for Step 5 preserve the complete configured blocking
phase 1 suite and its coverage gate, while excluding the approved browser and
CI/tooling cases from phase 2 and excluding CI/tooling sources from analysis.
The analysis source root remains the repository root; this is not the smoke
fallback. The approved test and analysis configuration remains in place when
temporary probes are cleared.

Human direction on 2026-09-29, reaffirmed on 2026-09-30, authorizes direct
consumer orchestration of the mandated stage behavior after recurring outer
agent disconnections. Preserve the working stage-local architecture, audited
tests, coverage transfer, analysis, quality and dry-run publication, including
the validated sandbox corrections. Do not restore the original outer wrapper.
This changes orchestration only and makes no infrastructure-repair claim.
The same direction limits local consumer validation to `check.bat`, deferring
local full-suite and duration gates while retaining actual Jenkins validation.
Original qualified candidate bytes must survive the later successful default
build in the human-approved immutable non-release store.

Human decision on 2026-10-03: requirement Q11 and design Q10 require the consumer's
original orchestration unchanged. Restore only its whole application path to the
recorded baseline and preserve concurrent projects. Consumer code absorbs its
fixed commands, one-archive staging and unused deploy variable; stop verifies four
pinned inputs before lifecycle changes, start enforces deterministic mode and all
fatal runtime gates, and explicit recovery stays offline. Add plan Step 8 parts
A-I, AC16-AC17 and the new candidate/qualification obligation. The original-path
real run remains unproven. Local consumer checks are only `ghog check` and
`ghog affected`, each with prior permission; no operational authorization is
conferred by this plan. The same-day follow-up confirms an idempotent stop-only
recheck at deployment start using the attempt-pinned verified stable scripts,
without refetching, resnapshotting or changing ordinary start/recovery.
Earlier source/validation decisions remain history.

Human decision on 2026-10-04, at the plan's round 3 convergence gate: revise and
review again. Preserve the covered typed pending-recovery wording and every
settled Step 8 behavior, but make its qualification-only scope explicit. Add
mandatory Step 9 after actual AC16/AC17 closure, implementing requirement Q12 and
design Q11 for first-time and production delivery. Scripts-only bootstrap uses
existing maintenance access; first activation is narrowly guarded. First-install
absence, actual historical retention, production approval/release/identity/access
gates and separately authorized rehearsals precede production. No operations
change or execution authority follows from this amendment. New questions Q23-Q30
cover implementation allocation and evidence sequencing only.

Earlier round 5/6 access, venue and arming alternatives are superseded by the
human's round 8 decisions on 2026-10-04. R1-R15 and Q11-Q36 remain except for
explicitly superseded assumptions. R16 option A preserves forward selection on
checked outside stop/start. Decision 2 replaces all bootstrap arming/counts with
fresh signatures for every attempt/retry/recovery; decision 3 selects shared-drive
delivery with the human's workstation key and public-key/verifier in release N.
Part C installs trust, probes and receipts only. Decision 4 selects development
replay on the qualification host, with no service unit and honest evidence limits.
Option (i) permits verified empty-prefix hold-aware hooks under initial hold;
installed/running bootstrap still changes no hooks. Route (b) is the one-time
production/new-environment bootstrap, never recurring arming. Step 8 A adds
development-account host evidence and same-disk filesystem timing plus evidenced
per-task orchestration overhead times remote operation count; C application-account
probes are final. Q37-Q41 were raised for implementation consolidation; the
2026-10-05 decisions below settle them, including the offline backup key.
No implementation or execution is authorized by these document amendments.

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
| Q10 | Human decision on 2026-10-03: implement the settled original-orchestration contract only on the consumer side, with new immutable qualification, bootstrap before source restoration, loaded-source/payload agreement and separately authorized execution. | Requirement Q11; design Q10; Step 8 A-I; AC16-AC17 | Orchestration changes or exception requests; a new transport object; home entrypoints/general shell; native staging rollback; reusing qualification for changed bytes. |
| Q11 | A: Keep six focused P27-P32 helpers, P23 runtime checks and P38 in the verified closure to preserve clear execution boundaries. | Step 8 B; stable control closure | Merging installer/controller responsibilities into dispatcher/pipeline; transport bundle. |
| Q12 | A: P28 separates immutable preparation and activation; P32 activates original delivery and P23 bootstrap only after full success. P07/P24/manual installs prepare only. | Step 8 B/C; closure | Duplicated copy/activate owners or changing a pinned version. |
| Q13 | A: P34 invokes direct argv in native subprocess fixtures with controlled HOME/cwd/modes and nohup semantics, testing actual dispatch effects. | Step 8 tests; consolidated helper details | Shell command strings that alter the fixed invocation. |
| Q14 | A: Use the A/B/C/E dependency ledger: safety, measured timing and state fixtures before C; C supplies application-account probes before E. | Step 8 A/C; gate ledger | Requiring C results before B/C or treating fixtures as execution proof. |
| Q15 | A: Retain a same-filesystem inode anchor with path/type/owner and mutation checks to distinguish identical-byte redelivery through rotations. | Step 8 identity details; terminal cleanup | Device/inode/metadata alone without an anchor; SHA or time alone. |
| Q16 | A: Pin one evidenced HTTP client and TLS trust; enforce exact URLs/hashes and no fallback. Step 8 uses local retention without fetching. | Step 8 acquisition details; Step 9 B | Choosing curl/wget dynamically or silently weakening TLS. |
| Q17 | A: Reuse the verified inherited lock descriptor and held flag through installation/readiness; a flag alone is invalid. | Step 8 B; consolidated lock details | Moving exclusion entirely into P07 or adding a lock bypass. |
| Q18 | A: Measure one monotonic 600-second budget, preserving 90/5/55-second caps and separately bounded acquisition; requalify park-before-stop. | Step 8 B timing; tests | Independent timeout sums with no overall deadline. |
| Q19 | A: P43 measures task-traced same-disk T/D/N plus evidenced per-task overhead O; budget at least `2 * (T + N * O)` and `2 * D` headroom. | Step 8 A; gate ledger | Filesystem timing alone with an unexplained multiplier. |
| Q20 | A: P34-P36 verify observable failures, all modes/states/owners and both offline recoveries; obey source budgets and separately permitted ghog checks. | Step 8 tests/addendums | One growing acceptance module or source-string assertions. |
| Q21 | A: P29 owns transitions; P31 self-terminalizes handled failures. Interrupted runs require P22 job-terminal and P31/P29 local terminal proof; R19 permits safe unsigned restart. | Step 8 durable attempt transitions; I | Separate transition authorities or maintenance terminalization. |
| Q22 | A: G redeploys C's exact release without a self-predecessor. Typed recovery follows the attempt checkpoint; absent pending plus matching installed identity runs checks only. | Step 8 B/G/I | A second candidate for G or falling through to an older index predecessor. |
| Q23 | A: P28 adds guarded first activation with verified pointer before dispatcher; empty hooks use option (i), historical hooks wait for approved hold. | Step 9 bootstrap gates; B | A separate maintenance bootstrap adapter or early hook replacement. |
| Q24 | A: P29 records no predecessor and P07 reconciles journal-owned paths for fresh retries; provisional first-install identity is never a working checkpoint. | Step 9 empty-prefix transitions | A parallel state adapter or fictional restart/rollback. |
| Q25 | A: P39 verifies the exact production archive pair and unique original entry, then atomically prepares existing historical retention without fake markers. | Step 9 B/D/F | Growing P07 with acquisition/bootstrap policy or reusing an unproven historical pair. |
| Q26 | A: P30 renders the profile, P29 parses/binds it, P23 enforces exact modern/historical identity. Explicit DEV no-unit mode never follows a failed unit query. | Step 9 profiles; tests/B | Another profile helper or silent downgrade of modern checks. |
| Q27 | A: Use one validated timing record for approval, queue/dispatch, execution and margin; signed expiry includes approval allowance with no auto-renewal. | Step 9 E/F; controlled-clock fixtures | Scattered timing constants or a real two-hour test sleep. |
| Q28 | A: P30's verified route/release descriptor feeds P22; P31 repeats target gates. Only an evidenced existing production route and release inputs are accepted. | Step 9 A/B/E/F | Putting all validation in P22 or creating operations routing. |
| Q29 | A: Add focused P40-P42 leaves, reuse P33 and existing fixtures, recount after Step 8 and enforce source budgets with honest evidence labels. | Step 9 tests/addendums | Growing P34-P36 until oversized or treating DEV as managed proof. |
| Q30 | A: Keep separate C/D replay receipts, Step 8 managed proof, fixture/unit evidence and F production proof; Step 9 follows actual AC16/AC17. | Step 9 C-G; rollout accounting | One aggregate rehearsal flag or early topic completion. |
| Q31 | A: Transfer the registered application archive plus independent digest/profile instructions; verify before safe allowlisted extraction and P28 closure recheck. | Step 9 bootstrap/B/C/F | A separately transferred extracted closure or a new publication object. |
| Q32 | A: Use existing owners and phase receipts, publish dispatcher last, block incomplete bootstrap and resume only receipt-bound work under lock. | Step 9 bootstrap/B; interruption fixtures | Another coordinator, bootstrap arming or repeated first activation. |
| Q33 | A: P30 renders canonical signing instructions, P22 checks receipts/descriptor and P29/P31 admit signed authority. R19 governs missing/invalid selection. | Steps 8 D and 9 arming/F | Manual acknowledgment alone, target-shell arming or recurring operator access. |
| Q34 | A: P07 coordinates C, P23/P28 own probes/activation, P29 owns checkpoint/retention, P30/P22 validate returned evidence; A/C have distinct gates. | Step 8 A/C; consolidated receipts | All probes in P07, one opaque verdict or an operator fallback. |
| Q35 | A: Separate reservation, spent identity and success under P29. Every deploy/retry/recovery is fresh; R16 preserves unused forward ID and failed H uses unsigned restart. | Step 8 D/I; durable transitions | Separate consumed files per script or reusable conditional recovery. |
| Q36 | A: Compose terminal-job and local lock/process proof with interruption fixtures, both offline formats and R19 outcomes; fixtures cannot close AC17. | Step 8 tests/I; consolidated failure cases | Source inspection plus P32-only rollback tests. |
| Q37 | A: Evidence public-key formats and host utilities, then qualify one verifier over canonical versioned non-executable bytes using closure-trusted keys only. | Step 8 B; consolidated signing details | Selection-chosen verifier formats or invented algorithm without evidence. |
| Q38 | A: Human selected offline backup key on 2026-10-05. Release N trusts both public keys; independent custody and verified rotation/revocation preserve all attempt controls. | Confirmed trust; Step 8 B/C; validation | Trust rebootstrap as the primary loss strategy without a proven independent route in every environment. |
| Q39 | A: Use one versioned consumer P43 replay helper, with its exact path fixed privately before implementation; Step 8 is staging-only, Step 9 adds confined lifecycle replay. | Step 8 A; Step 9 venue/C/D; private mapping | An ignored private replay script or running the orchestration tool. |
| Q40 | A: Use an atomic per-environment ready envelope and stable local verified snapshot; evidence filesystem/permission semantics and retain local replay IDs across cleanup/reboot. | Step 8 D; consolidated envelope details | Split payload/signature publication or latest/time-based selection. |
| Q41 | A: Durably reserve before signed lifecycle use, persist spend for failed/unknown use and keep success separate. Only identified R16 releases unused forward authority; R19 ordinary mode has no signed reservation. | Step 8 durable transitions; persistence fixtures | Consumption only after readiness or unsigned bypass of failed/held recovery. |
| Round 8 human direction | On 2026-10-04, select R16 A, fresh shared-drive human signatures for every attempt/recovery, release N key/verifier, development replay with no-unit limits, option (i) empty hooks, route (b) bootstrap once and Part A evidence/cost additions. | Requirement Q13-Q16; design Q12-Q15; Steps 8/9; Q37-Q41 | Bootstrap arming/count, recurring operator arming, artifact-repository arming publication, inferred managed/unit proof from DEV. |
