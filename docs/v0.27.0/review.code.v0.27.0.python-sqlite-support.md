# Code review transcript for v0.27.0

- Exchange: code/code/v0.27.0/python-sqlite-support
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor - Step 1

- Recorded: 2026-09-15T20:37:53+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 1
- Outcome: request

### Review identity for step 1 python-sqlite-support (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
Implementation step: 1
Review round: 1

### Code review evidence for step 1 python-sqlite-support (round 1)

request_index_tree: 7f8c2ddf3f9b7398b5e0602c9bcad305c56b6c3c
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- cmd /d /c a.sqlite-check.cmd (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(sqlite): add shared provider probe
group 1 path: src/install/env/python/sqlite_probe.py
group 1 path: tests/__init__.py
group 1 path: tests/unit/__init__.py
group 1 path: tests/unit/sqlite_probe/__init__.py
group 1 path: tests/unit/sqlite_probe/test_sqlite_probe/__init__.py
group 1 path: tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py
group 1 path: docs/v0.27.0/verify.python-sqlite.sh
group 1 path: docs/v0.27.0/acceptance.python-sqlite-support.md
group 2: docs(python-sqlite-support): record step 1 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md
staged path: docs/v0.27.0/acceptance.python-sqlite-support.md
staged path: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md
staged path: docs/v0.27.0/verify.python-sqlite.sh
staged path: src/install/env/python/sqlite_probe.py
staged path: tests/__init__.py
staged path: tests/unit/__init__.py
staged path: tests/unit/sqlite_probe/__init__.py
staged path: tests/unit/sqlite_probe/test_sqlite_probe/__init__.py
staged path: tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py
```

### Requestor assessment for step 1 python-sqlite-support (round 1)

Step 1 is fully implemented under its stated completion rule. The exact Step 1
validation section records Yes; Steps 2-4 remain unstarted. Acceptance facilities
may be explicitly blocked at this step. The preflight happened before probe
implementation and found no separate compatible home or confirmed Debian route.

Validation: the plan's ignored Windows setup wrapper ran cumulative --step 1
under Git Bash 5.3.9 and shared Python 3.13.9, exit 0. Mandatory lint covered
57 tracked scripts. Explicit new-harness syntax/ShellCheck and Python compile
passed. Unit results: 20 passed and 3 Windows symlink-privilege skips, 0.473s;
runner phase 0.549s. On RHEL Python 3.9.25 all 23 passed with no skips, 0.208s.
The controlled copied-provider Linux fixture passed exit 0 and rejected a
different expected file with exit 2 after database success. Scratch was empty
after both. The positive duration was 0 with one-second resolution.

The acceptance document records exact probe SHA-256, source material, commands,
prerequisites and limits. No candidate Python 3.13.15 build, packaging, closure,
relocation, operator acceptance or item 7 acceptance is claimed.

Static implementation check: standalone infrastructure functions, stdlib-only
dependencies, 266-line production and 316-line test files below policy bands;
linear maps parse and deduplicated observations; no tree hashing or new build.
Every production top-level symbol is reached by tests or production calls.
There is no Python coverage percentage gate in this repository. The confirmed
plan adapts ghog/pytest to the .review-validation Bash floor plus the cumulative
runner, and reports behavioral cases rather than an invented percentage.
No architecture, performance, test-scope or existing-feature gap identified.

Focused Markdown checks for acceptance and validation passed. Staged
git diff --check and commit-plan-check --format json passed. Please review
the exact staged Step 1, including fail-closed identity logic and its tests.

### Implementation report for step 1 python-sqlite-support (round 1)

The new standalone sqlite_probe.py accepts explicit build/installed/operator
stage, enclosing Python tool root, exact extension directory, shipped provider
and existing scratch directory. Build also requires configured libpython.
It checks canonical executable/extension bounds, source Modules backing and
generated link spelling, commits and reopens one owned file database, then
reads /proc/self/maps once. Relevant mappings must match expected canonical
path and device/inode, with duplicate segment deduplication and fail-closed
handling of missing, deleted, unreadable, escaped and competing identities.
Build libpython is checked from the same map observation.

ProbeError and ProbeArguments preserve one JSON result and nonzero failures.
Imports of SQLite happen inside assessment. Tests use fixture observations
internally; no production CLI override can substitute maps or import results.
The cumulative runner applies the mandatory floor, explicit effort Bash checks,
Python compile and focused unittest suite under the selected authoring Python.
New package markers make the focused suite importable on Python 3.9 and 3.13.

The acceptance record captures read-only preflight, relocation constraints,
profile entry hashes, missing isolated-home/Debian facilities and live Linux
mechanism evidence. Existing installation and closure files are untouched.

### Change summary for step 1 python-sqlite-support (round 1)

The staged inventory contains nine paths, covered exactly once by a.commit.

Group 1, feat(sqlite): add shared provider probe:

- src/install/env/python/sqlite_probe.py
- `tests/__init__.py`
- `tests/unit/__init__.py`
- `tests/unit/sqlite_probe/__init__.py`
- `tests/unit/sqlite_probe/test_sqlite_probe/__init__.py`
- tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py
- docs/v0.27.0/verify.python-sqlite.sh
- docs/v0.27.0/acceptance.python-sqlite-support.md

Group 2, docs(python-sqlite-support): record step 1 validation:

- docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md

The trailing validation group records the Step 1 Yes result separately from
behavior and tests. The formatted root a.commit passed the readiness checker.

### Writer response for step 1 python-sqlite-support (round 1)

Writer response:

This is the first implementation review of Step 1. No earlier implementation
feedback or reviewer repair is pending, and there is no disagreement.
The six design and six plan decisions have been consolidated and committed.
The requirement correction is already committed. The owning H2 isolation
decision remains unchanged; missing compatible home is recorded as blocking
Step 4. Windows is the authoring/launcher environment, not a runtime target.

For reviewer validation on this Windows workspace, the existing ignored
a.sqlite-check.cmd is the concrete same-process setup wrapper specified by
the plan. It clears the inherited setup guard, runs senv.bat once and selects
configured Git Bash with an explicit authoring Python. Use that wrapper for
the cumulative addition. The mandatory lint command is also run by it.
Raw remote mechanism evidence remains in ignored a.sqlite-linux-check.raw.txt;
the acceptance document contains the sanitized reproducible recipe. No remote
operation, build, live staging or candidate acceptance is required by this review.

### Reviewer focus for step 1 python-sqlite-support (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-1-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `C:/Users/vonc/git/cplx/.reviews/a.review-active.code.code.v0.27.0.python-sqlite-support.md`
- `C:/Users/vonc/git/cplx/.reviews/a.review-requested.code.v0.27.0.python-sqlite-support.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer - Step 1

- Recorded: 2026-09-15T20:45:23+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: answer

### Assessed index identity for step 1 python-sqlite-support (exchange 1) (round 1)

Baseline index tree: 7f8c2ddf3f9b7398b5e0602c9bcad305c56b6c3c

Assessed index tree: 7f8c2ddf3f9b7398b5e0602c9bcad305c56b6c3c

### Implementation check for step 1 python-sqlite-support (exchange 1) (round 1)

Result:

No. Step 1 has NOT been fully implemented.

The probe, the focused tests, the cumulative runner and the prerequisite
assessment are present and behave correctly on Windows and RHEL. However,
several fail-closed rules that Step 1 adds have no unit test, and one refusal
branch is unreachable. The new standalone file therefore does not meet the
per-file unit coverage expectation that the validation rows claim is satisfied.

#### What was verified for step 1 python-sqlite-support (exchange 1) (round 1)

- **Probe contract.** `sqlite_probe.py` takes explicit `build`, `installed` and
  `operator` stages, independent roots, the shipped provider and caller scratch.
  `--expected-libpython` is required for `build`. It imports `_sqlite3` and
  `sqlite3` inside `assess()`, so an import failure still produces one JSON
  result, and `main()` returns 2 for failed or inconclusive outcomes. There is
  no CLI override for maps or imports.
- **Evidence rules.**
  - Paths are canonicalized with component containment (`is_relative_to`).
  - The provider must match both path and device/inode after opening the
    backing file; deleted mappings, missing or unreadable files and a missing
    load are refused.
  - `/proc/self/maps` is read once, after both connections close; duplicate
    segments are deduplicated.
  - The build stage checks the generated import path, a `Modules/` backing
    file and the mapped `libpython` from the same snapshot.
- **Plan conformance.** The inputs, stage rules, test-first cases and
  standard-library-only constraint match Step 1 as consolidated. The unit test
  loads the standalone probe by file path. The runner applies the lint floor,
  explicit `bash -n` and ShellCheck, a syntax compile and the focused suite
  under an explicit absolute authoring interpreter.
- **Prerequisite assessment.** The acceptance record reports a read-only
  preflight before implementation: no second anchor-compatible `/home` entry,
  no container runtime, no Debian copy route. It records these as Step 4
  blockers without proposing live staging or anchor changes. Its design link
  anchor exists. No account or host detail beyond sanitized hashes is recorded.

#### Untested fail-closed branches in the probe for step 1 python-sqlite-support (exchange 1) (round 1)

Static reading of `sqlite_probe.py` against the 23 tests shows these refusal
paths are never exercised:

- the build-stage check that the source executable sits beside the declared
  `libpython` (`executable.parent != build_root`), which is the rule stopping a
  different interpreter from passing as the source build;
- a declared `libpython` whose directory lies outside the Python root, and an
  extension root outside that build directory;
- a missing `Modules/` directory, and an extension backing that is not a
  regular file;
- `directory()` given an existing non-directory (for example a file as
  `--scratch-dir`);
- `file_identity()` on a non-regular backing path;
- `device_numbers()` without `os.major` (on Windows the tests patch this
  function away).

#### Unreachable ambiguity branch for step 1 python-sqlite-support (exchange 1) (round 1)

In `match_library`, every observed identity is compared with the expected one
and any difference raises "unexpected provider" before it can be stored. So
`len(identities) != 1` ("ambiguous ... inconclusive") can never be true. The
design says "ambiguous provider identity is inconclusive". Today, a process that
maps both the expected `libsqlite3` and another copy reports `failed`, not
`inconclusive`. Both refuse a pass, but the code does not implement the
classification its own branch and the design describe.

#### Architecture check by the reviewer for step 1 python-sqlite-support (exchange 1) (round 1)

The probe is a self-contained infrastructure adapter using only the standard
library. Parsing, identity, database and result emission are separate
functions, and expected roots always come from callers. Items that need
addressing: the dead ambiguity branch above and its design classification.
Yes, there is something that needs to be addressed.

#### Performance check by the reviewer for step 1 python-sqlite-support (exchange 1) (round 1)

Map parsing is linear. Relevant records are deduplicated before any `open` or
`fstat`, and the test bounds identity reads to two for 100 duplicate segments.
The database holds one row, and no tree scan or hashing is added. No, there is
no performance issue that needs to be addressed.

#### Coverage check by the reviewer for step 1 python-sqlite-support (exchange 1) (round 1)

The repository has no Python coverage gate (`.review-validation` measures only
the Bash lint floor), so the evidence is static. `sqlite_probe.py` has a
dedicated unit module under `tests/unit/sqlite_probe/test_sqlite_probe/`, and
every top-level function and both classes are referenced. The branches listed
above are not exercised, and one is unreachable. Yes, there is a unit-tested
class file below 100% that needs completing. No, no top-level symbol staged
outside a coverage gate is unreferenced.

#### Missing work for Step 1 for step 1 python-sqlite-support (exchange 1) (round 1)

- Add unit cases for the build-stage executable-not-beside-`libpython`
  refusal, a `libpython` directory outside the Python root, an extension root
  outside the build directory, a missing `Modules/` directory and a non-regular
  extension backing. None needs a symlink, so all can run on Windows.
- Add unit cases for `directory()` on a file, `file_identity()` on a
  non-regular path, and `device_numbers()` when `os.major` is unavailable.
- Resolve the unreachable `len(identities) != 1` branch. Preferred: classify
  "expected provider mapped together with another `libsqlite3` backing file" as
  `inconclusive`, as the design states, and keep `failed` when only a wrong
  provider is mapped, with a test for each. Alternatively, remove the branch and
  record that a competing provider is a failure.
- Update the Step 1 validation rows, coverage sentence and test count after the
  additions.

Validation plan effects:

None. The reviewer did not edit
`docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md`. The writer's
Step 1 rows state Yes and "No incomplete unit-tested class requiring additional
work", which this assessment does not support; the writer owns that correction
together with the missing work.

### Pre-repair mandatory checks and coverage for step 1 python-sqlite-support (exchange 1) (round 1)

All resolved commands ran on the received index tree
`7f8c2ddf3f9b7398b5e0602c9bcad305c56b6c3c`; no reviewer repair was made.

- `bash src/utils/lint_shell.sh`, through the guard-clearing `senv.bat` form:
  `lint_shell: 57 tracked scripts`, `lint_shell: clean`, exit 0.
- `cmd /d /c a.sqlite-check.cmd` (inspected first: guard clear, `call <NUL
  senv.bat`, configured Git Bash, `--step 1` with the shared authoring Python
  3.13.9): lint floor clean, then `Ran 23 tests`, `OK (skipped=3)` (the three
  symlink cases), and `SQLite cumulative checks passed through step 1`, exit 0.

An additional independent check covered the three Windows-skipped cases. The
staged `sqlite_probe.py` and `tests/` were extracted from the index into an
owned `mktemp -d /tmp` directory on the RHEL 9.8 host. There,
`/usr/bin/python3 -B -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd`
ran 23 tests, all OK with no skips (0.190 s). The directory was then removed.

No coverage percentage applies: the repository has no Python coverage gate.
The static branch review is reported in the implementation check.

### Resolved validation set and sources for step 1 python-sqlite-support (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project `.review-validation`)
- `cmd /d /c a.sqlite-check.cmd` (source: plan; the plan's ignored
  same-process Windows wrapper around
  `bash docs/v0.27.0/verify.python-sqlite.sh --step 1 --python <absolute>`)

### Resolver drift and direction for step 1 python-sqlite-support (exchange 1) (round 1)

No drift. The current resolver yields the `.review-validation` lint floor plus
the plan's Step 1 cumulative runner, which the plan tells Windows authors to
run through the ignored `a.sqlite-check.cmd` wrapper. The request carries the
same two commands. The native Linux runner form is the plan's counterpart for a
prepared Linux environment. The reviewer's RHEL unit run is extra evidence, not
a resolved command.

### Repository state around validation for step 1 python-sqlite-support (exchange 1) (round 1)

- **Index trees:** the request-time, reviewer-entry and assessed trees are all
  `7f8c2ddf3f9b7398b5e0602c9bcad305c56b6c3c` (no reviewer repair).
- **Umbrella digest:** unchanged
  (`85440ae0c9c1a64ee082ccb5472a8aca093bf7c5e9ef10e60f9faf39ac1db0ff`).
- **Validation state:** the comparison over the nine staged Step 1 paths
  reports no tracked, ignored or untracked difference. The wrapper, lint and
  unit runs left no tracked side effect.
- **Untracked:** only the protocol-created transcript
  `docs/v0.27.0/review.code.v0.27.0.python-sqlite-support.md`, neither read as
  working context nor staged.

### Repair inventory for step 1 python-sqlite-support (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 1 python-sqlite-support (exchange 1) (round 1)

`commit-plan-check.bat --format json` ran independently on the received tree and
returned status 0, `state: valid`, `ready: true` and no diagnostics, with nine
staged paths in two groups:

1. `feat(sqlite): add shared provider probe`: probe, four test package markers,
   the unit module, the cumulative runner and the acceptance record;
2. `docs(python-sqlite-support): record step 1 validation`: the validation plan.

Membership, order and subjects match the staged work. `a.commit` was not
amended. The missing tests belong in group 1 and the corrected validation rows
stay in group 2, so the grouping should survive the requested rework. The
status 0 proves only mechanical grouping.

### Findings and boundaries for step 1 python-sqlite-support (exchange 1) (round 1)

Unresolved findings:

- Untested fail-closed probe rules: sqlite_probe.py has no unit case for the build-stage executable-not-beside-libpython refusal, a libpython directory outside the Python root, an extension root outside the build directory, a missing Modules directory, a non-regular extension backing, directory() on a file, file_identity() on a non-regular path, or device_numbers() without os.major, so the new file is below its per-file unit coverage expectation while the validation rows claim none is missing.
- Unreachable ambiguity branch: match_library raises "unexpected provider" on any identity differing from the expected one, so len(identities) != 1 can never be true; the design classifies ambiguous provider identity as inconclusive, but a process mapping both the expected and another libsqlite3 currently reports failed.

Boundary-crossing work: None.

### Writer instructions for step 1 python-sqlite-support (exchange 1) (round 1)

1. In `tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py`, add
   non-symlink cases (so they also run on the Windows authoring host) for:
   - a build stage whose `sys.executable` is not in the declared `libpython`
     directory (failed before maps are read);
   - a `--expected-libpython` outside `--expected-python-root`;
   - an extension root outside the build directory;
   - a missing `Modules/` directory;
   - an extension path that is a directory (non-regular backing);
   - `--scratch-dir` pointing to a file;
   - `file_identity()` on a directory;
   - `device_numbers()` with `os.major` absent (inconclusive).
2. In `src/install/env/python/sqlite_probe.py`, resolve the unreachable
   `len(identities) != 1` branch in `match_library`. Preferred, to match the
   design: collect all relevant identities, report `inconclusive` when the
   expected provider is mapped together with another `libsqlite3` backing file,
   and keep `failed` when only a wrong provider is mapped. Add one test for
   each. If you instead remove the branch, state in the validation rows why a
   competing provider is a failure.
3. Rerun `cmd /d /c a.sqlite-check.cmd` and the documented RHEL unit command
   (all tests with no skips), and refresh the recorded probe SHA-256 if the
   probe changes.
4. Update the Step 1 validation rows: test counts, line counts, the coverage
   sentence and the architecture check. Keep group membership in `a.commit`
   (probe and tests in group 1, validation in group 2), rerun
   `commit-plan-check.bat --format json`, and publish the next round.
5. Optional, outside Step 1's rows: the document-level first line of the
   validation plan reads `No, it is not implemented` without the final period
   the template expects.

### Decision rationale for step 1 python-sqlite-support (exchange 1) (round 1)

Decision: changes-requested.

Readiness floor:

- **Exact identity:** passes. The envelope, human-readable identity, plan,
  step 1, round 1, occurrence 1, umbrella and request-time tree `7f8c2dd`
  agree.
- **Complete implementation:** fails on test completeness. The probe behaves
  correctly, but eight fail-closed branches are untested and one refusal
  branch is unreachable.
- **Mandatory validation:** both resolved commands pass. The reviewer's
  independent RHEL run also passes all 23 tests with no skips.
- **Attributable staged scope:** passes. All nine paths are Step 1 files.
- **Unresolved findings:** two (untested branches, unreachable ambiguity
  branch).
- __`a.commit` accuracy:__ passes mechanically and in content.

The reviewer made no repair. The missing tests are unambiguous, but the
preferred fix for the unreachable branch changes the probe's
failed/inconclusive classification, which the writer should own. Writing both
together avoids two authors editing the same test module in one round. The
work is local and small, and needs no host acceptance. This answer is advisory
and does not authorize a commit.

### Final reviewer decision for step 1 python-sqlite-support (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-1-round-1 -->

## Round 2 by requestor - Step 1

- Recorded: 2026-09-15T20:49:24+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: request

### Review identity for step 1 python-sqlite-support (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
Implementation step: 1
Review round: 2

### Code review evidence for step 1 python-sqlite-support (round 2)

request_index_tree: 2727671b79c0100af44108fa38870765a597b87d
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- cmd /d /c a.sqlite-check.cmd (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(sqlite): add shared provider probe
group 1 path: src/install/env/python/sqlite_probe.py
group 1 path: tests/__init__.py
group 1 path: tests/unit/__init__.py
group 1 path: tests/unit/sqlite_probe/__init__.py
group 1 path: tests/unit/sqlite_probe/test_sqlite_probe/__init__.py
group 1 path: tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py
group 1 path: docs/v0.27.0/verify.python-sqlite.sh
group 1 path: docs/v0.27.0/acceptance.python-sqlite-support.md
group 2: docs(python-sqlite-support): record step 1 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md
staged path: docs/v0.27.0/acceptance.python-sqlite-support.md
staged path: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md
staged path: docs/v0.27.0/verify.python-sqlite.sh
staged path: src/install/env/python/sqlite_probe.py
staged path: tests/__init__.py
staged path: tests/unit/__init__.py
staged path: tests/unit/sqlite_probe/__init__.py
staged path: tests/unit/sqlite_probe/test_sqlite_probe/__init__.py
staged path: tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py
```

### Requestor assessment for step 1 python-sqlite-support (round 2)

Step 1 is fully implemented under its stated completion rule. The exact Step 1
validation section records Yes; Steps 2-4 remain unstarted. Acceptance facilities
may be explicitly blocked at this step. The preflight happened before probe
implementation and found no separate compatible home or confirmed Debian route.

Validation: the plan's ignored Windows setup wrapper ran cumulative --step 1
under Git Bash 5.3.9 and shared Python 3.13.9, exit 0. Mandatory lint covered
57 tracked scripts. Explicit new-harness syntax/ShellCheck and Python compile
passed. After the accepted round 1 fixes: 30 passed and 3 Windows
symlink-privilege skips, 0.532s; runner phase 0.623s. On RHEL Python 3.9.25 all
33 passed with no skips, 0.261s.
The controlled copied-provider Linux fixture passed exit 0 and rejected a
different expected file with exit 2 after database success. Scratch was empty
after both. The positive duration was 0 with one-second resolution.

The acceptance document records exact probe SHA-256, source material, commands,
prerequisites and limits. No candidate Python 3.13.15 build, packaging, closure,
relocation, operator acceptance or item 7 acceptance is claimed.

Static implementation check: standalone infrastructure functions, stdlib-only
dependencies, 274-line production and 393-line test files below policy bands;
linear maps parse and deduplicated observations; no tree hashing or new build.
Every production top-level symbol is reached by tests or production calls.
There is no Python coverage percentage gate in this repository. The confirmed
plan adapts ghog/pytest to the .review-validation Bash floor plus the cumulative
runner, and reports behavioral cases rather than an invented percentage.
No architecture, performance, test-scope or existing-feature gap identified.

Focused Markdown checks for acceptance and validation passed. Staged
git diff --check and commit-plan-check --format json passed. Please review
the exact staged Step 1, including fail-closed identity logic and its tests.
The round 1 implementation-check gaps are now addressed: all eight listed
refusals have explicit tests, and multiple providers are classified before
single wrong-provider failures. The dead ambiguity branch is now reachable.

### Implementation report for step 1 python-sqlite-support (round 2)

The new standalone sqlite_probe.py accepts explicit build/installed/operator
stage, enclosing Python tool root, exact extension directory, shipped provider
and existing scratch directory. Build also requires configured libpython.
It checks canonical executable/extension bounds, source Modules backing and
generated link spelling, commits and reopens one owned file database, then
reads /proc/self/maps once. Relevant mappings must match expected canonical
path and device/inode, with duplicate segment deduplication and fail-closed
handling of missing, deleted, unreadable, escaped and competing identities.
Build libpython is checked from the same map observation.

Round 2 collects the relevant backing identities before raising a deferred
wrong-provider error. Two identities are inconclusive in either mapping order;
only the wrong provider is failed. Ten added tests cover that distinction and
all round 1 refusal gaps without symlinks. Non-regular descriptor metadata is
simulated without opening a blocking FIFO. The true device_numbers function is
retained at import so its unavailable-os.major branch runs on Windows too.

ProbeError and ProbeArguments preserve one JSON result and nonzero failures.
Imports of SQLite happen inside assessment. Tests use fixture observations
internally; no production CLI override can substitute maps or import results.
The cumulative runner applies the mandatory floor, explicit effort Bash checks,
Python compile and focused unittest suite under the selected authoring Python.
New package markers make the focused suite importable on Python 3.9 and 3.13.

The acceptance record captures read-only preflight, relocation constraints,
profile entry hashes, missing isolated-home/Debian facilities and live Linux
mechanism evidence. Existing installation and closure files are untouched.

### Change summary for step 1 python-sqlite-support (round 2)

The staged inventory contains nine paths, covered exactly once by a.commit.

Group 1, feat(sqlite): add shared provider probe:

- src/install/env/python/sqlite_probe.py
- `tests/__init__.py`
- `tests/unit/__init__.py`
- `tests/unit/sqlite_probe/__init__.py`
- `tests/unit/sqlite_probe/test_sqlite_probe/__init__.py`
- tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py
- docs/v0.27.0/verify.python-sqlite.sh
- docs/v0.27.0/acceptance.python-sqlite-support.md

Group 2, docs(python-sqlite-support): record step 1 validation:

- docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md

The trailing validation group records the Step 1 Yes result separately from
behavior and tests. The formatted root a.commit passed the readiness checker.

### Writer response for step 1 python-sqlite-support (round 2)

Writer response:

Round 1 feedback is accepted in full; the reviewer made no repair, and there
is no disagreement. The writer added all requested refusal cases and explicit
tests distinguishing ambiguous providers from a single wrong provider. The
ambiguity test first failed with the old implementation, then passed after the
matcher change. Both provider mapping orders are exercised.

The cumulative Windows run passed all 33 cases with the same three symlink
skips. The RHEL unit run passed all 33 with no skips, and the actual Linux
copied-provider fixture and different-file control passed again. Acceptance
evidence now records the new probe digest and fresh fixture identity.
The validation rows reflect counts, line sizes, classification and added test
coverage; their Yes verdict follows this completed rework. The document-level
pending sentence also gained the template's final period.

Reviewed work changed substantively in the probe and tests. Four paths were
updated and staged: probe, unit tests, acceptance record and validation plan.
a.commit boundaries and subjects are unchanged; its unit-count detail was
corrected from 23 to 33. Focused Markdown, staged whitespace and commit-plan
checks passed. Please assess these repairs and the full exact Step 1.

The six design and six plan decisions have been consolidated and committed.
The requirement correction is already committed. The owning H2 isolation
decision remains unchanged; missing compatible home is recorded as blocking
Step 4. Windows is the authoring/launcher environment, not a runtime target.

For reviewer validation on this Windows workspace, the existing ignored
a.sqlite-check.cmd is the concrete same-process setup wrapper specified by
the plan. It clears the inherited setup guard, runs senv.bat once and selects
configured Git Bash with an explicit authoring Python. Use that wrapper for
the cumulative addition. The mandatory lint command is also run by it.
Raw remote mechanism evidence remains in ignored a.sqlite-linux-check.raw.txt;
the acceptance document contains the sanitized reproducible recipe. No remote
operation, build, live staging or candidate acceptance is required by this review.

### Reviewer focus for step 1 python-sqlite-support (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-1-round-2 -->

## Round 2 by reviewer - Step 1

- Recorded: 2026-09-15T20:53:52+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: answer

### Assessed index identity for step 1 python-sqlite-support (exchange 1) (round 2)

Baseline index tree: 2727671b79c0100af44108fa38870765a597b87d

Assessed index tree: 2727671b79c0100af44108fa38870765a597b87d

### Implementation check for step 1 python-sqlite-support (exchange 1) (round 2)

Result:

Yes. Step 1 has been fully implemented.

Both round 1 findings are resolved. The probe and its tests now cover every
refusal rule the reviewer listed, and the provider ambiguity branch is
reachable with the design's classification.

#### Round 2 delta verified for step 1 python-sqlite-support (exchange 1) (round 2)

`git diff 7f8c2dd 2727671` changes four paths: the probe, its unit module, the
acceptance record and the validation plan.

- **Matcher.** `match_library` now observes every relevant mapping before
  classifying:
  - more than one backing identity is `inconclusive` ("ambiguous ... backing
    identities");
  - otherwise a deferred wrong-provider or escape error is `failed`;
  - otherwise a missing expected mapping is `inconclusive`.

  Unreadable, deleted or mismatched backing files still raise immediately
  through `mapping_identity`. The design's "ambiguous provider identity is
  inconclusive" now holds in both mapping orders, and a single wrong provider
  remains a failure.
- **Ten new tests, none needing symlinks:**
  - the build executable not beside the declared `libpython`;
  - a `libpython` directory outside the Python root;
  - a generated extension root outside the build directory;
  - a missing `Modules/`;
  - a directory as extension backing;
  - a file as scratch;
  - non-regular backing (a directory, plus a mocked non-regular `fstat` that
    avoids opening a FIFO);
  - `device_numbers` without `os.major`, calling the unpatched function kept at
    import;
  - expected plus competing provider in both orders;
  - only a wrong provider.

  Each asserts the outcome, the message and, where relevant, that maps were
  never read.
- **Records.** The acceptance record's probe SHA-256 `6df1bdf...` equals the
  reviewer's hash of the staged blob. The validation rows now report 274 and 393
  lines and 33 tests, and the document-level line has its final period.

#### Architecture check by the reviewer for step 1 python-sqlite-support (exchange 1) (round 2)

The probe stays a standalone standard-library infrastructure adapter. The
matcher change keeps classification in one function, and expected roots still
come only from callers. No, there is nothing that needs to be addressed.

#### Performance check by the reviewer for step 1 python-sqlite-support (exchange 1) (round 2)

Collecting identities before classifying keeps the single linear pass with
deduplicated backing reads; the duplicate-segment bound test still passes. No,
there is no performance issue that needs to be addressed.

#### Coverage check by the reviewer for step 1 python-sqlite-support (exchange 1) (round 2)

There is no Python coverage gate, so the check is static. Every raise site in
`sqlite_probe.py` is now exercised by a dedicated test, directly or through
`assess()` or `main()`, except two guard calls into the already tested
`require_inside` helper:

- the installed or build extension root lying outside the Python root;
- a `Modules` directory that resolves outside the build directory, which needs
  a symlink.

Both reuse a helper whose refusal is tested many times, and neither adds a
branch of its own logic. The reviewer does not treat them as incomplete work.
No, there is no unit-tested class below 100% that needs completing. No, no
top-level symbol staged outside a coverage gate is unreferenced.

Validation plan effects:

None. The reviewer did not edit
`docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md`. The writer's
Step 1 rows (Yes, 33 tests, 274 and 393 lines, the matcher correction in the
architecture check and the added cases in the coverage check) match the
reviewed tree.

### Pre-repair mandatory checks and coverage for step 1 python-sqlite-support (exchange 1) (round 2)

All resolved commands ran on the received index tree
`2727671b79c0100af44108fa38870765a597b87d`; no reviewer repair was made.

- `bash src/utils/lint_shell.sh`, through the guard-clearing `senv.bat` form:
  `lint_shell: 57 tracked scripts`, `lint_shell: clean`, exit 0.
- `cmd /d /c a.sqlite-check.cmd` (unchanged wrapper: guard clear,
  `call <NUL senv.bat`, configured Git Bash, `--step 1` with authoring Python
  3.13.9): lint floor clean, `Ran 33 tests`, `OK (skipped=3)` (the three symlink
  cases), `SQLite cumulative checks passed through step 1`, exit 0.

An additional independent Linux run covered the three Windows-skipped cases.
The staged probe and `tests/` were extracted from the index into an owned
`mktemp -d /tmp` directory on the RHEL 9.8 host. There,
`/usr/bin/python3 -B -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd`
ran 33 tests, all OK with no skips (0.277 s). The directory was removed.

The staged probe blob and the working file both hash to
`6df1bdf704afae1bfa7dbe965eec0262fb6feac421583caba6fda58c4a6c308f`, the digest
recorded in the acceptance document. No coverage percentage applies.

### Resolved validation set and sources for step 1 python-sqlite-support (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (source: project `.review-validation`)
- `cmd /d /c a.sqlite-check.cmd` (source: plan; the plan's ignored
  same-process Windows wrapper around
  `bash docs/v0.27.0/verify.python-sqlite.sh --step 1 --python <absolute>`)

### Resolver drift and direction for step 1 python-sqlite-support (exchange 1) (round 2)

No drift. The request carries the same two commands the current resolver yields
from `.review-validation` and the plan's Step 1 Windows runner form. The
reviewer's RHEL unit run is extra evidence, not a resolved command.

### Repository state around validation for step 1 python-sqlite-support (exchange 1) (round 2)

- **Index trees:** the request-time, reviewer-entry and assessed trees are all
  `2727671b79c0100af44108fa38870765a597b87d` (no reviewer repair).
- **Umbrella digest:** unchanged
  (`85440ae0c9c1a64ee082ccb5472a8aca093bf7c5e9ef10e60f9faf39ac1db0ff`).
- **Validation state:** the comparison over the nine staged Step 1 paths
  reports no tracked, ignored or untracked difference.
- **Untracked:** only the protocol-created transcript
  `docs/v0.27.0/review.code.v0.27.0.python-sqlite-support.md`, neither read as
  working context nor staged.

### Repair inventory for step 1 python-sqlite-support (exchange 1) (round 2)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 1 python-sqlite-support (exchange 1) (round 2)

`commit-plan-check.bat --format json` ran independently on the received tree and
returned status 0, `state: valid`, `ready: true` and no diagnostics, with nine
staged paths in two groups:

1. `feat(sqlite): add shared provider probe`: probe, four test package markers,
   the unit module, the cumulative runner and the acceptance record;
2. `docs(python-sqlite-support): record step 1 validation`: the validation plan.

The round 2 changes stay inside those memberships, and the group 1 body now
states 33 tests. Membership, order and subjects remain accurate, and `a.commit`
was not amended. The status 0 proves only mechanical grouping.

### Findings and boundaries for step 1 python-sqlite-support (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 1 python-sqlite-support (exchange 1) (round 2)

No change is requested for Step 1.

1. Present this advisory commit-ready recommendation at the human commit gate,
   and include the review transcript through the residual continuation.
2. Keep the recorded Step 4 blockers visible: no directly anchored isolated
   home, no Debian runtime or copy route, no deployment target.
3. When Step 2 wires the probe, reuse the staged probe bytes and digest recorded
   in the acceptance document, as the plan requires.

### Decision rationale for step 1 python-sqlite-support (exchange 1) (round 2)

Decision: commit-ready (advisory).

The readiness floor passes:

- **Exact identity:** envelope, human-readable identity, plan, step 1, round 2,
  occurrence 1, umbrella and request-time tree `2727671` agree.
- **Complete implementation:** Step 1 matches the plan, and both round 1
  findings are resolved.
- **Mandatory validation:** both resolved commands pass (33 tests with three
  Windows symlink skips). The reviewer's independent RHEL run passes all 33
  with no skips.
- **Attributable staged scope:** all nine paths are Step 1 files.
- **No unresolved or boundary-crossing findings.**
- **Accurate `a.commit`:** mechanically ready, and its content matches.

The reviewer made no repair in this round. The recommendation does not
authorize a commit.

### Final reviewer decision for step 1 python-sqlite-support (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-1-round-2 -->

## Round 2 by human - Step 1 - human-confirmation

- Recorded: 2026-09-15T21:01:35+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
