# Implementation plan v0.27.0: qualify and release the rebuilt tools archive

Implement the approved [requirement](feature-request.v0.27.0.tools-archive-rebuild.md)
and [design](design.v0.27.0.tools-archive-rebuild.md) for item 7 of the
[Debian agent tools umbrella](draft.v0.27.0.debian-agent-tools.md).
This plan assigns implementation and evidence work; it does not claim a build,
backend capability, successful qualification or publication already exists.

## Ordered goals and release boundaries

| Step | Goal | Completion boundary |
| --- | --- | --- |
| 1 | Implement and demonstrate the application publication adapter | Real backend private staging and atomic visibility demonstrated before refresh/build work |
| 2 | Validate durable release evidence and bind it to publication | Ineligible evidence cannot invoke an uploader; eligible digest is the digest checked and streamed |
| 3 | Measure the exact Debian wheel consumers in D10 | Agent wheel identities and measured RHEL subjects match; inherited selection/convergence preserved |
| 4 | Qualify the candidate through the main Jenkins chain | Candidate provisioning, full coverage/testmon walk and blocking ABI checks wired and tested |
| 5 | Refresh, rebuild and package an identified candidate | Python choice, SQLite, archive cleanup and declaration authority recorded |
| 6 | Complete candidate acceptance on RHEL and actual Debian | Every required pre-publication cell conclusive for the candidate and consuming inputs |
| 7 | Publish, adopt and verify recovery behavior | Immutable artifact retrieved through the normal release pin and required adoption accepted |

Steps 2-4 can be prepared without a costly build, but Step 5 cannot start until
Step 1's real-backend proof passes. Step 6 may return to Step 5 for the single
permitted D10 rebuild. Step 7 cannot start publication until the release record
and inherited closure gate pass. Recovery keeps item 7 incomplete.

Python 3.14, free-threading, a Git rebuild, host package installation, new agent
images, changing the uv pin and the separate rsync follow-up remain outside
this plan. The application coverage threshold remains its current 100%.

## Confirmed code and test-tree facts

Paths without a prefix belong to cplx. `app:` denotes the consuming myproject
repository; changes there are separate commits with exact revisions retained
in the cplx acceptance record. Inspect its working tree and instructions again
before implementation; do not overwrite unrelated application changes.

The cplx `.review-validation` floor is `bash src/utils/lint_shell.sh`.
Its current Python test tree is `tests/unit/sqlite_probe/test_sqlite_probe/`,
using the standard library unittest runner through `verify.python-sqlite.sh`.
There is no cplx pytest/groundhog configuration. Application tests live under
`src/pdfss/tests/`; its pyproject enables pytest-cov with a 100% gate and includes
pytest-testmon. The Jenkinsfile currently disables both. Its comment confirms
the ghog launcher is Windows-only; the native Debian pipeline owns its full
pytest command. These are distinct execution environments.

The existing ABI method in `app:ci/Jenkinsfile.diagnostics` scans a limited
inventory and ends with `exit 0`; changing that final exit alone is insufficient.
The implementation must cover the declared toolchain scope, wheel inventory,
missing version nodes, outside providers and inconclusive observations.
The existing D10 reader separates archive consumers from candidate providers;
preserve that separation when adding wheel roots.

### Physical line baselines and responsibility boundaries

Counts include blank lines and were read from the working trees on 2026-09-16.
Recount immediately before implementation. The 650-line policy below applies
to Python files, not to Bash, Groovy, package lists or Markdown.

| Existing implementation file | Lines | Planned use |
| --- | --- | --- |
| `src/setups/env/bin/closure_publish.sh` | 650 | Step 2: expected release digest guard |
| `src/setups/env/bin/closure_d10.sh` | 524 | Step 3: wheel consumer roots |
| `src/setups/env/bin/closure_elf.sh` | 607 | Existing reader, reused without planned edits |
| `src/setups/env/bin/pkg_tools.sh` | 270 | Step 5: targeted stage cleanup |
| `src/setups/env/bin/pkg.sh` | 452 | Existing gated packager, reused |
| `src/setups/env/bin/install_pkg.sh` | 1308 | Step 6 (decided 2026-09-18): the ELF pass excludes venv trees; otherwise reused |
| `src/install/env/python/python_install_functions.sh` | 176 | Existing SQLite build/probe path, reused |
| `src/install/env/python/sqlite_probe.py` | 337 | Existing probe; safe band, 650-line ceiling, no planned growth |
| `src/setups/env/closure/closure-config.txt` | 33 | Step 5: conditional authorized renewal |
| `src/setups/env/closure/closure-envelope.txt` | 3 | Step 5: conditional paired renewal |
| `src/setups/env/closure/README.md` | 179 | Step 5: conditional authority documentation |
| `src/setups/pkgs/packages_rhel_9.8_x86_64.txt` | 5898 | Resolved refresh input, not manually edited output |
| `ci/deliver-closure-tools.sh` | 128 | Step 6: acceptance bundle composition |
| `app:tools/publish_pdf_nexus.sh` | 318 | Steps 1-2: adapter entry and release gates |
| `app:Jenkinsfile` | 360 | Step 4: main candidate/full-test flow |
| `app:ci/Jenkinsfile.relocation` | 47 | Step 4: remove interim patch call |
| `app:ci/Jenkinsfile.diagnostics` | 1114 | Step 4: delegate blocking ABI work |
| `app:ci/provision_toolchain.sh` | 371 | Step 4: candidate selection, remove interims |
| `app:tools/sqlite_candidate_capture.sh` | 81 | Step 4: share transport while preserving diagnostic behavior |
| `app:tools/tools.version` | 1 | Step 7: published pin |
| `app:tools/publish.mode` | 1 | Steps 4 and 7: explicit upload suppression/restoration |
| `app:pyproject.toml` | 284 | Existing threshold and plugin configuration, reused |
| `app:tools/deploy_pkgs.sh` | 608 | Existing deployment/readiness entry, reused |

| Existing check or evidence file | Lines | Planned use |
| --- | --- | --- |
| `docs/v0.27.0/verify.closure-check.sh` | 9136 | Run inherited gates; add new cases in focused harnesses |
| `docs/v0.27.0/verify.relocation-rpath.sh` | 6662 | Step 5: retire exact ownership entries only |
| `docs/v0.27.0/verify.install-pkg.sh` | 2181 | Reuse installer regression checks |
| `docs/v0.27.0/verify.wrapper-scope.sh` | 1556 | Reuse scope checks |
| `docs/v0.27.0/verify.wrapper-accept.sh` | 861 | Reuse wrapper checks |
| `docs/v0.27.0/verify.python-sqlite.sh` | 78 | Reuse cumulative SQLite checks |
| `docs/v0.27.0/acceptance.python-sqlite-support.sh` | 276 | Reuse acceptance controls |
| `docs/v0.27.0/acceptance.python-sqlite-deploy.sh` | 63 | Reuse independent delivery and role probes |
| `tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py` | 483 | Existing regression suite; safe band, 650-line ceiling, no planned growth |
| `tests/__init__.py`, `tests/unit/__init__.py` | 0 each | Existing empty package markers, reused |
| `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.validation.md` | 2618 | Read item 2 handoff evidence; do not rewrite history |
| `docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md` | 411 | Settled acceptance contract before IO clarification |
| `docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md` | 330 | Settled design before IO clarification |
| `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md` | 1193 | Step 7 completion evidence, after implementation-check |

All new files listed below have baseline 0. New Python files are safe to extend
up to the repository ceiling of 650 physical lines each; there is no tighter
mandatory estimate. Split record parsing/evidence validation from rendering if
the validator reaches that ceiling; split tests by publication eligibility and
adoption/invalidation responsibilities. There is no existing Python file above
650 in the planned mutation set. CLI modules under `bin` are loaded by path,
not made into import packages; no artificial production `__init__.py` is needed.

## File-based IO cost clarification

Read the selected archive-indexed release record directly; do not scan document
history or raw-capture directories to discover state. Resolve explicit evidence
references once per validation phase and reuse the collected identity map.
Retain required artifact hashing, ELF inventories and gate snapshots; reducing
IO must not remove byte-identity or completeness checks. Walk each declared
subject root once per measurement phase, keep provider and consumer inventories
separate, and stream publication bytes through the existing gate.

This is a batch release workflow, not a metadata-loading response path. Work is
linear in explicitly supplied evidence and artifact bytes, apart from existing
deterministic inventory sorting. No new repeated all-pairs scans are needed.
Record phase timings and invocation counts. No Step 0 timeout/xfail gate is
needed: no new latency SLO is specified, and native build/network variability
would not be a useful unit-test deadline. Existing CI timeouts remain enforced.

## Shared execution command checklist and ready-to-run commands

For every step, count affected files before/after, add the listed failing cases
first, implement, run focused checks, then the cumulative workflow. Preserve
first actionable failures and fix before repeating; no unchanged expensive
build loops. Recheck shell/platform, clean fixture boundaries and app revisions.
Use `rg -n` on only step files for the patterns named below and inspect matches.
Record elapsed time, exit status, behavior coverage and real platform evidence.
No measured Python coverage percentage is claimed without a measurement.

Count on Windows with `[IO.File]::ReadAllLines(<resolved-path>).Length`, or on
Linux with `awk 'END { print NR }' <file>`. Any Python file exceeding 650 must be
split before completion. Advisory estimate variance below the ceiling is merely
recorded. Bash/Groovy extraction is by responsibility, not a Python line gate.

Create the cplx cumulative entry point in Step 1 and extend it in subsequent
steps. Its native Linux invocation is:

```bash
bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step N --python /absolute/authoring/python --app-repo /absolute/app/checkout
```

For Step 4 or later, also pass `--capture-python /absolute/application-venv/python`.
This explicit venv interpreter supplies `packaging` and `tomllib` for the
application wheel-capture import and its fixtures only. Independent checks
continue to use the selected authoring Python; no global `PYTHONPATH` is needed.

The runner first executes `bash src/utils/lint_shell.sh`, then Bash syntax and
ShellCheck for new harnesses, stdlib Python compile/unittest checks when added,
and the cumulative affected fixture suites. It composes the inherited closure,
relocation, wrapper and SQLite checks using their documented selectors. Record
the exact selectors in the runner rather than inventing new flags for existing
scripts. Step 1 introduces the runner before any later test depends on it.
Require the explicit application checkout from Step 1 for adapter tests; never
silently skip another repository's affected contracts when it is unavailable.
Run Linux ELF/symlink tests on native Linux; Git Bash authoring syntax checks
do not establish runtime acceptance. Fixtures use isolated owned copies, never
source a real `.env`, trigger SSH, compile payloads or change a live installation.

This adapts the standard ghog plan to cplx's declared Bash floor. Do not add an
unconfigured cplx pytest gate, call `check.bat` directly, or add effort-specific
commands to `.review-validation`. In the application Windows authoring tree,
use its self-locating `ghog.bat day` via CMD (and its documented detached/status
mode for long runs); fix-and-walk until the objective is met. The actual Debian
Jenkins acceptance is the existing native full-test stage, with plugins active,
the existing coverage threshold and full selection, not the Windows wrapper.

The fixture runner returning zero never substitutes for required backend,
RHEL or Jenkins runs. Missing real access/evidence leaves the owning step
incomplete. Do not weaken a gate to close a step.

## Step 1. Demonstrate the real publication transaction

### Step 1 analysis and intent

The current application tools upload uses a pathname, public POM preflight and
post-upload SHA-1. Implement the already selected four-operation adapter and
prove its actual repository capability before costly refresh work. Preserve
ordinary pdfs publication and immutable-coordinate behavior. Complexity stays
one stage and one streamed object per transaction; backend details are discovered
from the deployed service, not assumed from its product name.

### Step 1 implementation

Files:

- `app:tools/tools_release_adapter.sh` (new, to be created).
- `app:tools/publish_pdf_nexus.sh` (existing, to be updated).
- `docs/v0.27.0/verify.tools-archive-rebuild.sh` (new, to be created).
- `docs/v0.27.0/verify.tools-release-publish.sh` (new, to be created).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.md` (new, to be created).

Tests first: a private fake backend asserts begin/write/abort/commit order,
stdin-only consumption, no public POM/tools asset on refusal, partial write,
digest failure, interruption, abort failure diagnostics and immutable collision.
Exercise the existing closure publication contract with the application adapter;
mock tests establish mechanics, not real backend capability. Table-driven cases
cover the finite transaction states; no new PBT dependency is justified.

Implement `upload_begin`, `upload_write`, `upload_abort`, `upload_commit` with
the inherited signatures. Inspect the deployed backend API and applicable
permissions; demonstrate private visibility, abort and atomic commit using a
designated capability probe outside the intended release coordinate. Retain
its identifiers, permissions scope, observations and cleanup evidence. Never
use the next tools release coordinate as a disposable test. Stop this step if
the inherited transaction cannot be achieved and resolve the owning design;
no local-buffer/public-upload approximation qualifies. Until Step 2 wiring is
complete, the tools entry must refuse release rather than use its old path.

Completion: real capability proof and failing-path fixtures pass, while the
normal application publisher retains its existing behavior. Record facts in the
acceptance view; Step 2 will index their retained captures in the sidecar.

### Step 1 addendums

The frozen closure Step 5 suite depends on the retired SQLite waiver. Reuse the
prior SQLite effort's documented historical-control method: retain the exact
declaration/envelope pair from `3a1d1135a3e627b74d134db24694121e70ea6b14`, verify
their hashes, and run current scripts in an owned copy through `--shipped-dir`.
Also run `verify.python-sqlite-closure.sh --fixtures-only` for the current floor.
Keep historical regression evidence separate from candidate acceptance; do not
restore a production waiver or rewrite the frozen harness to force a pass.

The user approved mandatory commit-response verification on 2026-09-17.
Implement the owning-design resolution: persist commit intent and stream digest,
then read the exact asset and compare SHA-256 whenever the response is missing
or unusable. A match succeeds; an inconclusive check returns 3 and retains an
unknown attempt that blocks adoption and automatic upload retry. Recovery is
read-only reconciliation, including cleanup interrupted after commit intent.
Add fixtures for lost and malformed replies, committed bytes despite an error,
unavailable GET, 404 after response loss, mismatched bytes, retry refusal and
later reconciliation. No search result, HEAD or POM substitutes for this check.

The application adapter may use Python 3.9 stdlib helpers for authenticated TLS,
streaming, process coordination and durable attempt receipts. Keep transport and
state responsibilities separate, add no runtime dependencies, and cap each new
Python file at 650 physical lines. The cplx gate changes in Step 1 only to report
unresolved outcomes truthfully; Step 2 still owns eligibility-record wiring.

- Line budget checkpoint: existing app publisher 318; all new files 0; no Python mutation, 650-line Python ceiling remains applicable to any added Python.
- Execute the shared checklist/runner at `--step 1`; search `upload_`, `deploy-file` and POM preflight placement.
- Full workflow readiness: fixtures can run immediately; real capability needs the actual backend and scoped probe coordinate.
- Time-gated status: incomplete until the real proof passes; capture transaction durations, no new timing threshold.

## Step 2. Validate and bind the durable release record

### Step 2 analysis and intent

Compose existing evidence without changing closure result grammar. The cplx
validator must distinguish publication eligibility from later adoption and
refuse missing, stale or mismatched results. Bind its accepted SHA-256 to the
closure gate's promoted identity so a pathname switch between the two checks
cannot publish another closure-valid but unqualified archive.

### Step 2 implementation

Files:

- `src/setups/env/bin/tools_release_record.py` (new, to be created).
- `src/setups/env/bin/closure_publish.sh` (existing, to be updated).
- `tests/unit/tools_release_record/__init__.py` (new, to be created).
- `tests/unit/tools_release_record/test_tools_release_record/__init__.py` (new, to be created).
- `tests/unit/tools_release_record/test_tools_release_record/test_tools_release_record_tdd.py` (new, to be created).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.json` (new, to be created).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.md` (existing after Step 1, to be updated).
- `docs/v0.27.0/verify.tools-archive-rebuild.sh` (existing after Step 1, to be updated).
- `docs/v0.27.0/verify.tools-release-publish.sh` (existing after Step 1, to be updated).
- `app:tools/publish_pdf_nexus.sh` (existing, to be updated).

Use stdlib JSON for the versioned sidecar, indexed by archive SHA-256. Provide
explicit CLI phases for publication and completion, plus a deterministic human
view rendered from the same record. Pass explicit archive, record, evidence
root and release revision inputs. The validator and its tests must support
Python 3.9 or later, including the build account's system Python 3.9.25. Run
them with an explicitly identified, independently supplied interpreter, never
the candidate being qualified. Record that interpreter's path/version in the
local capture and its sanitized identity in the release record. Populate the
record area fields and state values specified in the design. Require known
acceptance IDs and mandatory matrix cells; reject duplicate keys, contradictory
identities, unknown result states and absent/damaged referenced captures.

Tests first: pending/fail/inconclusive required cells, allowed optional cells,
pre/post-publication separation, changed archive, changed wheel/lock/pipeline
inputs, reasoned unaffected-result retention, capture hash mismatch, unavailable
raw evidence, sanitization and deterministic view. Add finite generated mutations
of valid records using unittest, without adding a PBT package. Reuse existing
package markers; load the CLI by path in its test leaf.

Require an explicit expected SHA-256 in the tools release invocation of
`closure_publish.sh`. Compare it with the promoted identity before any adapter
load/call; retain descriptor, snapshot, stream-digest, waiver and authority
checks. Keep existing gate callers compatible when this optional guard is not
supplied, but the application release entry must always supply it from successful
record validation. Test archive replacement, mismatched eligibility and an
absent expected digest at the tools release entry (including an empty validator
result or an omitted guard in its gate invocation). Each must refuse with a spy
adapter proving zero calls; compatibility for other callers is a separate
positive test. Do not place POM or tools preflight ahead of
these checks. Keep SHA-1 publication association alongside SHA-256.

Completion: incomplete records block the real tools entry, publication checks
do not require future adoption, and completion checks do require it. The record
initially records pending candidate cells; fixtures are never real pass evidence.

### Step 2 addendums

- Line budget checkpoint: closure publisher 650 Bash lines, app publisher 318 baseline; new Python validator/test/markers 0, safe band, ceiling 650 each. Split validation from rendering and tests by lifecycle if necessary.
- Execute shared checklist/runner at `--step 2`; search `expected`, `sha256`, `upload_`, `pending` and actual tools-entry call order.
- Full workflow readiness: stdlib unit checks on independently supplied Python 3.9 or later, including the 3.9 floor, plus Step 1 transaction fixtures; never use the candidate interpreter. Source identity and capture access must be explicit.
- Time-gated status: measure record/reference reads and ensure no directory-history discovery; no timeout xfails.

## Step 3. Include the agent's exact wheel artifacts in D10

### Step 3 analysis and intent

Extend measurement input only. Preserve the D10 lowest-satisfying generation
policy, zero headroom and bounded second reading. Exact Debian-resolved wheel
bytes are measured on RHEL, without a host-specific dependency re-resolution.
One subject inventory per supplied root prevents repeated directory walks.

### Step 3 implementation

Files:

- `src/setups/env/bin/closure_d10.sh` (existing, to be updated).
- `src/setups/env/bin/tools_wheel_inventory.sh` (new, to be created).
- `docs/v0.27.0/verify.tools-release-d10.sh` (new, to be created).
- `docs/v0.27.0/verify.tools-archive-rebuild.sh` (existing after Step 1, to be updated).

Tests first: no-wheel legacy invocation, wheel-only extra demands, archive and
wheel duplicate needs, matching/extraneous/missing ELF subjects, corrupt wheel,
lock mismatch, unsafe archive member, unreadable consumer or provider, empty
relevant set, mixed providers, zero headroom, neither candidate, and second
reading equal/lower/higher/neither. Use tiny controlled ELF fixtures and existing
reader seams; keep new cases out of the 9136-line closure harness. Deterministic
permutations of subject order check set semantics without a new PBT dependency.

Add repeatable wheel consumer roots to the D10 CLI. Capture archive reading
generation before visiting wheel roots or candidate provider roots. Aggregate
GLIBCXX/CXXABI and separate GCC requirements from the full consumer union,
then evaluate actual GCC 11 and 12 capabilities. Keep origin/path/digest
provenance for every consumer in the result.

The wheel inventory helper records lock digest, wheel filenames/digests and
installed ELF paths/digests on Debian. Retain the exact artifacts used by sync;
when retrieval is needed, retrieve those identities without resolving anew.
On RHEL, verify before extraction into a private owned directory and match the
measured ELF inventory to the agent's installed inventory. Reject unsafe members
and mismatch; do not accept a transported demand list instead of wheel bytes.
Step 4 supplies live inputs; Step 6 proves the final set.

Completion: wheel demands can change the selected generation and every missing
or mismatched input is inconclusive; old archive-only callers keep their behavior.

### Step 3 addendums

- Line budget checkpoint: D10 524 Bash lines; new helper/harness 0; no Python mutation, 650-line ceiling applies if Python is introduced.
- Execute shared checklist/runner at `--step 3`; search consumer/provider array ownership and `--previous` paths.
- Full workflow readiness: fixtures now; real wheel artifacts arrive from Step 4 and final candidate runs in Step 6.
- Time-gated status: record walk/read counts and D10 elapsed time; no new hard deadline.

## Step 4. Wire candidate qualification into the main application chain

### Step 4 analysis and intent

Use item 6 archive-copy transport in the runtime that actually provisions,
syncs, tests and packages the application. Remove the temporary compatibility
workarounds and make ABI/trace evidence conclusive and blocking. Preserve the
independent SQLite diagnostic and ordinary release-pin provisioning.

### Step 4 implementation

Files:

- `app:Jenkinsfile` (existing, to be updated).
- `app:ci/Jenkinsfile.relocation` (existing, to be updated).
- `app:ci/Jenkinsfile.diagnostics` (existing, to be updated).
- `app:ci/provision_toolchain.sh` (existing, to be updated).
- `app:ci/tools_candidate.sh` (new, to be created).
- `app:ci/tools_abi_acceptance.sh` (new, to be created).
- `app:tools/sqlite_candidate_capture.sh` (existing, to be updated).
- `app:tools/publish.mode` (existing, to be updated).
- `docs/v0.27.0/verify.tools-release-agent.sh` (new, to be created).
- `docs/v0.27.0/verify.tools-archive-rebuild.sh` (existing after Step 1, to be updated).

Tests first: release-pin mode, complete candidate pins, partial/conflicting
inputs, digest failure, upload suppression, shared interpreter through every
stage, whole-scope ABI inventory, missing versions, outside providers, aliases,
recognized monitoring, empty inventory and unusable direct-venv traces. Cover
no-tests-selected and missing coverage output as failures of acceptance.
Use isolated shell fixtures and an explicit app checkout argument to the cplx
runner; a missing checkout is a failure for these tests, never a silent skip.

Extract the existing diagnostic's pinned archive/bundle transfer primitive into
`ci/tools_candidate.sh`, and call it from the diagnostic and main provisioning.
Keep independent verifier manifest/revision checks. Candidate mode requires
explicit `off`, complete unambiguous pins and verified bytes before extraction;
wire the same selected prefix through relocation, sync, package, test and ABI.
Use the Step 3 helper to retain exact resolved wheel artifacts and installed
inventory. Retain actual container/image identity without printing credentials.

Remove the rsync shim, dormant tools-patch fetch, `patch-wheels` implementation
and its Groovy/Jenkins calls. Keep a raw-Python/UV_PYTHON bypass only if its
removal is not established safe by wrapper-to-uv acceptance. Extract the ABI
method into the focused shell entry; the Groovy method propagates its status.
Cover the entire declared toolchain resolution scope plus venv wheel ELFs,
preserving virtual-kernel/loader accounting, visible excluded OneAgent objects,
and refusal for other outside-prefix runtime providers. No monitoring provenance
or digest condition is added. Keep raw direct-venv LD_DEBUG traces as evidence.

Remove `--no-cov` and `-p no:pytest-testmon`. Force a full acceptance selection
while both plugins are active; use pytest-testmon's supported full-selection
mode for the installed version and verify collected/executed counts. Keep the
100% threshold, retain coverage output, and prove SQLite-guarded suites executed.
Incremental testmon state cannot certify the candidate. Later routine testmon
selection remains available. Candidate and first post-pin runs keep uploads off.

Completion: fixture negatives block and pipeline wiring consistently selects
the intended prefix. Step 6 owns the actual-agent run, final PA9 and platform
acceptance, batching these against the final archive instead of requiring an
additional full run of an older archive before Step 5.
Step 4's transport and selection fixtures reduce the risk of discovering basic
pipeline wiring defects only during Step 6; live environment defects can still
first appear in the final native acceptance run.

### Step 4 addendums

- Line budget checkpoint: Jenkins 360, relocation 47, diagnostics 1114, provisioner 371, diagnostic capture 81, mode 1; new files 0. Extract ABI responsibility from Groovy; no Python growth or artificial 650-line Groovy limit.
- Execute shared checklist/runner at `--step 4` with explicit app checkout; run the application authoring ghog workflow. Search `Q26`, `tools-patch`, `patchVenvElves`, `--no-cov`, `no:pytest-testmon` and ABI unconditional-success paths in active code.
- Full workflow readiness: native fixtures plus actual Jenkins access, independently pinned verifier and retained wheel artifacts.
- Time-gated status: retain current Jenkins stage timeouts; report full test duration/count/coverage and plugin identities.

## Step 5. Refresh, rebuild and package the candidate

### Step 5 analysis and intent

Use completed items 1-6 rather than replacing their mechanisms. Build Python
with SQLite and refresh the sandbox from item 5's resolved package/index inputs,
then clean the private package stage. Do not alter the live build tree merely
to make archive checks pass. Preserve closure authority across the final source
history and independently delivered checker bundle.

### Step 5 implementation

Files:

- `src/setups/env/bin/pkg_tools.sh` (existing, to be updated).
- `docs/v0.27.0/verify.relocation-rpath.sh` (existing, to be updated).
- `docs/v0.27.0/verify.tools-release-package.sh` (new, to be created).
- `docs/v0.27.0/verify.tools-archive-rebuild.sh` (existing after Step 1, to be updated).
- `src/setups/env/closure/closure-config.txt` (existing, to be updated only if renewal is required).
- `src/setups/env/closure/closure-envelope.txt` (existing, to be updated only with that renewal).
- `src/setups/env/closure/README.md` (existing, to be updated only with that renewal).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.json` (existing after Step 2, to be updated).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.md` (existing after Step 1, to be updated).

Tests first: private stage removes `tools/python/root/a.out`, preserves protected
loaders/providers, leaves the live tree intact, and the same trimmed inventory
reaches gate and tar. Read item 2 Step 4's literal `STEP4_ARCHIVE_DEFECTS` register
and discharge every object with its named owner. Remove only resolved entries;
test exact equality in both directions and planted stale/unowned residuals.
New regression cases live in the focused harness; only literal register updates
belong in the large inherited relocation harness.

After Step 1 passes, perform the dated upstream regression check required by
RA1: choose 3.13.15 unless a relevant blocking regression conclusively justifies
3.13.14. Inconclusive findings do not select a fallback. Set `CPLX_VERSION`
explicitly and record sources/date. Use the existing RHEL refresh/build entries
and resolved architecture index; no host installs, automatic latest-tag choice
or Git rebuild. Retain exact commands, inputs and output identities.

Use the existing SQLite build acceptance and same-process file-backed probe.
Re-run all inherited closure/packaging checks. Package through `pkg_tools.sh`
and retain timestamped name, size, SHA-1 and SHA-256. Keep source-envelope commit,
declaration digest and final publishing revision distinct. The current source
authority is `13c80d572ba7bda91728806ad7dc11c53629a506`, retained by merge
`5f8d4d67ca549bb74e3bcbb798124d628c3d0619`; verify reachability from the actual
publishing checkout. If declaration changes, execute the complete
[item 6 Step 3 contract](plan.v0.27.0.python-sqlite-support.md#step-3-bind-the-candidate-layout-to-its-closure-declaration),
including authorization, exact source snapshot, paired delivery, retention merge
and fresh single-branch clone proof. A digest edit alone never renews authority.

Completion: identified archive, conclusive Python/build SQLite result, AR1/AR2/AR4
cleanup and resolved declaration authority. Step 6 still owns runtime acceptance.

### Step 5 addendums

- Line budget checkpoint: package script 270, relocation harness 6662, declaration/envelope/README 33/3/179; new harness 0; existing SQLite Python 337 reused, safe band and ceiling 650 if a necessary fix is scoped later.
- Execute shared checklist/runner at `--step 5`; search `a.out`, `STEP4_ARCHIVE_DEFECTS`, `--closure-gate` and source-envelope references.
- Full workflow readiness: Step 1 real proof, RHEL build access, resolved payloads, upstream regression decision and authority inputs available.
- Time-gated status: retain refresh/build/package durations; no repeated clean builds or cache deletion without a diagnosed need.

## Step 6. Complete pre-publication platform acceptance

### Step 6 analysis and intent

Qualify the exact archive on the required RHEL roles and actual Debian agent.
Compose existing probes, retain conclusive evidence and invalidate affected
results on changed inputs. Fixture success and item 6's older diagnostic result
cannot fill the final archive's cells.

### Step 6 implementation

Files:

- `ci/deliver-closure-tools.sh` (existing, to be updated).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.sh` (new, to be created).
- `docs/v0.27.0/acceptance.tools-runtime-rhel.sh` (new: deployed runtime qualification).
- `docs/v0.27.0/verify.tools-release-acceptance.sh` (new, to be created).
- `docs/v0.27.0/fixtures.tools-release-agent.py` (existing, to be updated:
  align the pytest double and session-finish call with the current application).
- `docs/v0.27.0/verify.tools-archive-rebuild.sh` (existing after Step 1, to be updated).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.json` (existing after Step 2, to be updated).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.md` (existing after Step 1, to be updated).
- `src/setups/env/bin/install_pkg.sh` (existing, to be updated: the ELF pass
  excludes venv trees, decided 2026-09-18 after PA6 failed on RHEL).

Tests first: acceptance driver receives explicit archive/verifier/revision pins,
captures fail/inconclusive statuses, refuses missing cells and wrong identities,
retains raw evidence and never turns a skipped required role into pass. Exercise
invalidation and one permitted D10 rebuild with controlled fixtures. A venv
tree fixture proves the ELF pass leaves a wheel object's `$ORIGIN` search path
untouched while still rewriting a library outside the venv.
Deployment discovery must reject absent or ambiguous project/venv directories.
Import the independent application helpers with the selected Python 3.9+
interpreter as well as compiling them, so evaluated annotations are checked.
The ABI, test-evidence and candidate-bundle helpers remain independent.
The wheel-capture helper is application-venv code: import it and run the
wheel-selection fixtures with the explicit `--capture-python` interpreter,
in isolated mode with its installed `packaging` and `tomllib` dependencies.
Keep the other agent fixtures on the independent interpreter in isolated mode.
The application's independent readers need postponed annotations;
retain their source revision and any uncommitted repair digests with validation.

The installer ships inside the archive, so its correction makes the accepted
Step 5 candidate a failed one: return to Step 5 for a single repackage of the
unchanged payloads with the corrected installer, record the new candidate
identity, repeat AR1, AR2 and AR4, then repeat the affected RHEL cells.

Compose independently delivered verification controls and the existing SQLite,
installer, relocation and wrapper harnesses. Keep controls outside the candidate
and check bundle manifest on both sides. Preserve private scratch namespaces,
transfer hashes and sanitized tracked reports; keep raw captures with durable
identities and digests. Record exact commands/run IDs in the structured record.

Run required AR1-AR4, including migration positivity/case 5 equality, all three
HOME states and force reinstall against the packaged inventory. Run PA1-PA6 on
both required platforms: installer without rsync shim, first/later wrapper,
ssl/zlib/sqlite and file-backed same-process acceptance, git, provider/version
coherence and unpatched pymupdf/pikepdf sync. Run required Debian PA7-PA9:
whole-scope loader ABI, usable direct-venv traces, full coverage/testmon walk
with SQLite suites executed. Record RHEL PA10 readiness/deploy/redeploy and
PA11 operator senv/.env behavior. Optional RHEL downstream cells remain marked
optional; inherited closure checks always apply.

For the human-selected deployment scope (2026-09-19), prepare the shipped
venv with `--no-group tooling`, use uv from the tools installation for RHEL
PA6, and repeat affected RHEL acceptance before D10. Retain the earlier
tooling-inclusive capture as history, without claiming it accepts this venv.
Bind the deployed application helpers and offline inputs before executing them.
Bootstrap uv with shipped Python and its own pip, relocate uv, and retain its
provider map. Check deployed wheel ELF byte equality against the agent inventory,
run the application's shared-runtime import trace, and exercise a real host
child launched with the environment composed in its shipped Python parent.
Retain those detailed captures alongside the deployment result. Keep host
utilities outside the shipped library environment.

Materialize the Step 4 agent's exact wheels on RHEL and run Step 3 D10 against
both actual provider candidates. If generation changes, rebuild once, create a
new candidate identity and repeat affected acceptance, including a second D10
reading that must select exactly the rebuilt generation. Otherwise stop as
non-convergent. Changes in app/lock/wheels/pipeline/runtime require an impact
assessment and repeated affected checks; preserve unchanged results with their
original identities and explicit reasons, never relabel an old run.

Completion: release validator publication phase passes every pre-publication
obligation, including actual Jenkins PA9, final source authority and Step 1
backend proof. Future adoption cells remain pending by design.

Keep a private publication coordinate out of versioned evidence when the
repository's sensitive-content rule requires it. Retain the actual preflight
privately and bind it by digest; the public record uses an explicit opaque
coordinate reference, never a substitute upload target. Before native
eligibility validation, materialize only that field in a private execution
record, prove every other value equal, and retain both record digests and the
actual-coordinate validation result. Publication must use that resolved record
and revalidate it; a reference alone cannot authorize an upload.

### Step 6 addendums

- Line budget checkpoint: delivery script 128; new driver/harness 0; record/view baseline 0 at plan creation. No Python growth; ceiling 650 applies to any necessary validator extension.
- Execute shared checklist/runner at `--step 6`, then real platform driver; inspect `pending`, `inconclusive`, `not applicable`, digest bindings and D10 reading counts.
- Full workflow readiness: final archive plus real RHEL/Debian access, exact wheel artifacts and independently delivered controls.
- Time-gated status: report phase durations and existing pipeline timeout outcomes; missing evidence is incomplete acceptance.

## Step 7. Publish, adopt and close with integration evidence

### Step 7 analysis and intent

Publish only the accepted bytes, then separately prove normal release retrieval
and main-chain use. Retain prior working configuration for recovery. Publication
and adoption are observable actions, not inferred from passing local tests.

### Step 7 implementation

Files:

- `app:tools/tools.version` (existing, to be updated).
- `app:tools/publish.mode` (existing, to be updated).
- `docs/v0.27.0/verify.tools-release-acceptance.sh` (existing after Step 6, to be updated).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.json` (existing after Step 2, to be updated).
- `docs/v0.27.0/acceptance.tools-archive-rebuild.md` (existing after Step 1, to be updated).
- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md` (existing, to be updated by implementation-check).
- `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md` (existing, to be updated only on final completion).

Tests first: full fixture integration from eligible record through streamed
transaction to recorded published identity, normal-pin retrieval and completion
gate. Negatives cover changed archive, existing different immutable asset,
candidate override surviving adoption, attempted upload before accepted adoption,
and recovery restoring an incompatible pin/configuration pair.

Retain the prior pin plus compatible application configuration/interims. Invoke
the existing manual `--with-tools --version <next-release>` tools-only entry
with the explicit accepted timestamped archive and exact record/authority inputs.
No intermediate Maven tools artifact, public POM preflight or later latest-file
reselection is allowed. Validate eligibility immediately before the inherited
transaction and associate published SHA-1 with accepted SHA-256. Retain actual
visibility/retrieval evidence; never overwrite an immutable coordinate.

Disable candidate inputs, update the normal release pin and keep publish.mode
off. On the actual Debian agent, prove download digest, startup pin, selected
interpreter and the complete integration/ABI/test chain. Record deployment and
adoption evidence required by RA5/RA6/RA8. If relevant inputs changed, repeat the
affected acceptance first. Restore snapshot uploads only after accepted adoption.

Exercise recovery in controlled integration fixtures and retain a reviewable
real recovery procedure. If actual adoption fails, execute it: restore and
verify the prior pin/configuration combination with uploads off before allowing
uploads to resume. Leave item 7 incomplete; retain the failed immutable artifact
and use a new eligible version for a fix. Do not deliberately break a healthy
release solely to manufacture a production rollback result.

Completion requires the validator completion phase, actual published-pin
integration success and all required obligations. Run implementation-check;
only then mark umbrella item 7 completed with requirement/validation evidence
paths. Fixtures, capability proof and documentation alone cannot complete it.

### Step 7 addendums

- Line budget checkpoint: app pin/mode 1 each, umbrella 1193 baseline, validation skeleton newly written; previous new files baseline 0. Recount any touched Python; ceiling 650, no additional mandatory target.
- Execute shared checklist/runner at `--step 7`; search candidate overrides, snapshot restoration, archive identities and completion state. Run real normal-pin integration acceptance in addition to fixtures.
- Full workflow readiness: Step 6 publication eligibility, real transactional adapter, immutable release coordinate and prior working configuration retained.
- Time-gated status: record transaction/retrieval/adoption/recovery durations and existing CI timeout results; do not poll healthy long runs merely for status.

## Implementation decisions for tools-archive-rebuild

All four reviewed implementation questions are settled with option A. The
approved requirement, design and seven-step order remain the basis for execution.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | Use a stdlib JSON CLI with separate publication/completion phases, a deterministic view and unittest mutations. Support Python 3.9 or later through an explicitly identified independent interpreter, never the candidate. This checks duplicate keys, identities and lifecycle states without a new package dependency. | [Step 2](#step-2-validate-and-bind-the-durable-release-record) | Bash plus an external JSON command adds an executable prerequisite and makes state/identity validation harder to test. |
| Q02 | Keep focused contract fixtures in cplx and require an explicit application checkout from Step 1. One cumulative runner checks both repositories at recorded revisions; a missing checkout fails instead of silently reducing coverage. | [Shared command checklist](#shared-execution-command-checklist-and-ready-to-run-commands), [Step 1](#step-1-demonstrate-the-real-publication-transaction) and [Step 4](#step-4-wire-candidate-qualification-into-the-main-application-chain) | An application-owned runner called from cplx adds a second harness interface and coordination between evolving runners. |
| Q03 | Complete fixture/wiring checks in Step 4 and full native Debian/RHEL qualification in Step 6 against the final archive. Shared final identities avoid a mandatory additional full run of an older candidate; Step 4 transport/selection fixtures reduce basic wiring risk before live acceptance. | [Step 4](#step-4-wire-candidate-qualification-into-the-main-application-chain) and [Step 6](#step-6-complete-pre-publication-platform-acceptance) | An actual-agent rehearsal in Step 4 could detect live defects sooner, but needs a separately identified older candidate and cannot replace final acceptance. |
| Q04 | Extract the ABI probe into `app:ci/tools_abi_acceptance.sh` and leave a small Groovy caller that propagates its status. Direct fixtures cover inventory, monitoring exclusions and inconclusive failures before a pipeline run. | [Step 4](#step-4-wire-candidate-qualification-into-the-main-application-chain) | Expanding the existing embedded method avoids a new file but makes direct testing harder and grows the 1114-line diagnostics file. No Python line limit applies to Groovy. |
