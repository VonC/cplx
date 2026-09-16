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
- **`a.commit` accuracy:** passes mechanically and in content.

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

## Round 1 by requestor - Step 2

- Recorded: 2026-09-15T21:30:48+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 2
- Outcome: request

### Review identity for step 2 python-sqlite-support (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
Implementation step: 2
Review round: 1

### Code review evidence for step 2 python-sqlite-support (round 1)

request_index_tree: 5804213c71bcc8b63e6f7a9cb0836c9206abc5ba
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- cmd /d /c a.sqlite-check.cmd (sources: plan)
- cmd /d /c a.sqlite-step2-linux.cmd (sources: plan)
- rg -n 'post_install_check|res_install|res_package|current' src/install/env/install (sources: plan)
- rg -n 'LIBSQLITE3|python_sqlite|required|check_sqlite' src/install/env/python (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(sqlite): check capability before packaging
group 1 path: src/install/env/python/python_install_functions.sh
group 1 path: src/install/env/install
group 1 path: docs/v0.27.0/verify.python-sqlite-build.sh
group 1 path: docs/v0.27.0/verify.python-sqlite-launcher.py
group 1 path: docs/v0.27.0/verify.python-sqlite.sh
group 2: docs(python-sqlite-support): record step 2 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md
staged path: docs/v0.27.0/verify.python-sqlite-build.sh
staged path: docs/v0.27.0/verify.python-sqlite-launcher.py
staged path: docs/v0.27.0/verify.python-sqlite.sh
staged path: src/install/env/install
staged path: src/install/env/python/python_install_functions.sh
```

### Requestor assessment for step 2 python-sqlite-support (round 1)

Step 2 is fully implemented. The staged validation plan records the exact
completion sentence, implementation analysis and supporting checks. Steps 3
and 4 remain incomplete.

Validation on 2026-09-15:

- `cmd /d /c a.sqlite-check.cmd` passed the cumulative Step 2 runner: the
  57-script Bash lint floor, explicit effort Bash syntax/ShellCheck, Python
  syntax, 33 probe unit cases (30 pass, three Windows symlink skips), and all
  four copied CMD launcher cases. Unit execution took 0.634 seconds and
  0.730 seconds including loading. The unchanged probe's earlier 33-case RHEL
  pass covers the Windows skips.
- `cmd /d /c a.sqlite-step2-linux.cmd` passed all 32 native Linux process
  cases in owned RHEL scratch using `/usr/bin/python3`. The transport only
  copies verification material and invokes synthetic fixtures. It does not
  run a real build or source a production profile. Exact production and
  fixture hashes are in the validation plan; raw output is retained in the
  ignored `a.sqlite-step2-linux.raw.txt`. Native elapsed time was not measured
  separately.
- `git diff --cached --check`, the two Step 2 `rg` inspections and the focused
  Markdown checker passed. The root commit plan has two groups and passed
  `commit-plan-check.bat --format json` with no diagnostics.

The declared `.review-validation` Bash floor and approved shared command
checklist adapt the generic ghog/pytest flow. No Python coverage percentage
is configured or claimed. The new 93-line Python file is a CMD process
fixture with no production classes. The existing probe and unit module are
unchanged. Python policy stays in Python support; the shared driver adds only
the optional callback. The Makefile scan is linear with fixed keys, and each
selected build adds one source and one installed probe. No new sorting,
tree walk, automatic cleanup or compile is introduced.

These fixtures establish caller behavior. Real candidate compilation,
populated-tree reuse, deployment and Debian acceptance belong to Step 4.
Its previously recorded home/profile/deployment/Debian prerequisites remain
unresolved. Step 2 does not claim candidate acceptance.

### Implementation report for step 2 python-sqlite-support (round 1)

Python support now selects `el9.x86_64`, adds scoped `LIBSQLITE3_CFLAGS` and
`LIBSQLITE3_LIBS`, and executes the existing shared probe after fresh build
or either reuse branch. It validates the selected source executable,
configuration files, literal pinned Makefile substitutions, generated module
directory and configured libpython backing file. The source probe uses
`-I -S -B` and source-first `LD_LIBRARY_PATH` while retaining inherited library
entries. The installed probe resolves the requested version's exact binary
and extension directory.

The generic driver calls optional `post_install_check` only after successful
install (including timestamp reuse), before package and the final installed
selector update. Nonzero status and interpreter diagnostics propagate.
Other families skip the Python gate and generic tools retain their sequence.
This does not promise rollback of files within an already selected prefix.

The pinned 3.13.15 archive was inspected directly. `sysconfig` writes
`build/lib.linux-x86_64-3.13`; generated extension links are backed by
`Modules/`; Linux shared configuration uses the checked literal Makefile
values and source-first RUNSHARED. Shared setenv rewrites Makefile EXTLIBS
on ordinary reuse, so staleness uses config.status and pyconfig.h timestamps
while validating the Makefile values independently. A regression caught and
now covers the harmless Makefile maintenance case.

The new native process fixture copies the complete driver, shared install
functions and Python support, replacing setup and external work with synthetic
commands. Its 32 cases assert exact stage order, rejection paths, package and
installed selector preservation, explicit reconfigure and generic callback
behavior. The separate Python fixture runs a copied complete launcher in
actual Windows CMD, substituting external commands and asserting replacement
counts before execution. Remote statuses 0, 42, 4 and 199 remain 0, 5, 55 and 5
at that authoring boundary. Windows is the existing remote launcher platform;
the runtime targets remain Linux.

### Change summary for step 2 python-sqlite-support (round 1)

The six staged paths are grouped in the formatted root `a.commit`:

1. `feat(sqlite): check capability before packaging`
   - `src/install/env/python/python_install_functions.sh`
   - `src/install/env/install`
   - `docs/v0.27.0/verify.python-sqlite-build.sh`
   - `docs/v0.27.0/verify.python-sqlite-launcher.py`
   - `docs/v0.27.0/verify.python-sqlite.sh`
2. `docs(python-sqlite-support): record step 2 validation`
   - `docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md`

The production Bash support has 169 lines, driver 416, new Bash fixture 269,
new Python process fixture 93, and cumulative runner 70. All intended paths
are staged. Step 1 and its earlier review are already committed. The present
request covers only Step 2; no Step 2 commit is authorized yet.

### Writer response for step 2 python-sqlite-support (round 1)

Writer response:

This is the first review round for Step 2. There is no prior Step 2 feedback
or disagreement. Step 1's accepted probe behavior is unchanged.

The plan's copied-launcher check is implemented in a separate Python process
fixture to execute actual CMD and safely substitute every external dependency.
That additional file remains within Step 2's approved behavior and is included
in its implementation group and cumulative syntax checks.

The two ignored CMD wrappers are available in this shared workspace and clear
the project setup guard before running their commands. The cumulative wrapper
runs the versioned runner with `--step 2` and the explicit llm-shared authoring
Python. The native wrapper transfers the exact files to owned scratch and runs
the versioned build fixture with `/usr/bin/python3`. Inspect those wrappers
before running them; retain private transport details only in ignored files.
Both platform checks are required because Windows cannot exercise the real
symlink process cases and Linux cannot exercise actual CMD. No fixture result
substitutes for Step 4's real candidate acceptance.

### Reviewer focus for step 2 python-sqlite-support (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-2-round-1 -->

## Round 1 by reviewer - Step 2

- Recorded: 2026-09-15T21:36:43+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: answer

### Assessed index identity for step 2 python-sqlite-support (exchange 1) (round 1)

Baseline index tree: 5804213c71bcc8b63e6f7a9cb0836c9206abc5ba

Assessed index tree: 5804213c71bcc8b63e6f7a9cb0836c9206abc5ba

### Implementation check for step 2 python-sqlite-support (exchange 1) (round 1)

Result:

Yes. Step 2 has been fully implemented.

Scoped configure inputs, the source and installed capability checks and the
optional driver callback are implemented as the plan describes, and their
refusal paths are exercised by native Linux and actual Windows CMD fixtures.

#### What was verified for step 2 python-sqlite-support (exchange 1) (round 1)

- **Scope and configure.** `python_sqlite_required` is true only for
  `CPLX_ARCH_EXT=el9.x86_64`. The configure array appends
  `LIBSQLITE3_CFLAGS=-I${root}/usr/include` and
  `LIBSQLITE3_LIBS=-L${root}/usr/lib64 -lsqlite3` only in that case and
  preserves the existing `LIBMPDEC_*` and OpenSSL flags. The `other-family`
  fixture proves the variables are absent and neither probe runs.
- **Source check.** After a fresh `make all` or either reuse branch, the check:
  - resolves `tool_src` under `tools/python/sources/`;
  - requires a non-symlink `python`, plus `Makefile`, `pyconfig.h`,
    `config.status` and `pybuilddir.txt`;
  - reads only five literal Makefile assignments without evaluating them;
  - rejects a `pybuilddir.txt` that is missing, placeholder, multi-line,
    absolute, escaping, for another version, or older than `config.status` or
    `pyconfig.h`;
  - resolves the generated directory and `libpython3.13.so` backing inside the
    source tree.

  It then runs `./python -I -S -B` with the source tree first in
  `LD_LIBRARY_PATH`, keeping inherited entries. The reviewer checked the pinned
  `python-src-3.13.15.tar.gz` on the build host read-only:
  - `Makefile.pre.in` defines `VERSION=`, `abs_builddir=`, `ABIFLAGS=`,
    `LDVERSION=` and `LDLIBRARY=`;
  - `configure.ac` sets `LDLIBRARY='libpython$(LDVERSION).so'` and
    a Linux `RUNSHARED` that prepends the build directory's `pwd` to the
    inherited `LD_LIBRARY_PATH`;
  - the build writes a `none` placeholder into `pybuilddir.txt` and
    `make clean` removes it.

  Those facts match the implementation's literal checks and its placeholder
  and staleness rules.
- **Installed check.** `post_install_check` resolves `tool_prefix` to exactly
  `tools/python/python-<version>` and `bin/python3` to that prefix's
  `bin/python3.13`, rejecting an old selector or wrapper target (fixture
  `installed-old-selector`), and passes the exact `lib/python3.13/lib-dynload`
  boundary. The scratch directory `tools/python/logs` is the one the driver
  creates for every tool run.
- **Driver.** `main()` calls `post_install_check` only when defined, after a
  successful `install()` (including its timestamp skip) and before `package()`.
  A nonzero status is returned like any other stage, so `package` and the final
  `current` update never run. Generic tools with no callback keep the exact
  prior event sequence.
- **Launcher boundary.** The CMD fixture copies the real `install.bat`,
  replaces exactly three `scp`, one `ssh`, the editor and the focus command
  (with count assertions and a guard that no real `scp`, `ssh`, `bash` or
  `powershell` line remains), and runs actual CMD. Remote statuses 0, 42, 4 and
  199 become launcher statuses 0, 5, 55 and 5.

#### Architecture check by the reviewer for step 2 python-sqlite-support (exchange 1) (round 1)

Python policy, source-artifact validation and probe invocation stay in the
Python support file. The shared driver gains only a tool-agnostic optional hook.
The probe from Step 1 is reused unchanged. Fixtures copy complete scripts,
replace only setup and external commands, and never source a production
profile. No, there is nothing that needs to be addressed.

#### Performance check by the reviewer for step 2 python-sqlite-support (exchange 1) (round 1)

A selected build adds two bounded probe invocations. Makefile parsing is one
linear pass over fixed keys, and path checks resolve named inputs only. No tree
walk, sort, automatic clean or compile is introduced. No, there is no
performance issue that needs to be addressed.

#### Coverage check by the reviewer for step 2 python-sqlite-support (exchange 1) (round 1)

No Python class or unit-tested module changes in this step. The production
change is Bash, exercised by 32 native process cases that cover:

- every refusal branch of `python_check_sqlite`;
- every callback ordering path;
- `configure` with and without the scope predicate.

The new Python file is a verification fixture whose two functions run in the
cumulative Windows gate. There is no Python coverage gate. No, there is no
unit-tested class below 100% that needs completing. No, no top-level symbol
staged outside a coverage gate is unreferenced.

Validation plan effects:

None. The reviewer did not edit
`docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md`. The writer's
Step 2 rows, including the three recorded material SHA-256 values, match the
reviewed tree: the reviewer's hashes of the staged blobs and the hashes printed
by the native run are identical.

### Pre-repair mandatory checks and coverage for step 2 python-sqlite-support (exchange 1) (round 1)

All resolved commands ran on the received index tree
`5804213c71bcc8b63e6f7a9cb0836c9206abc5ba`; no reviewer repair was made.

- `bash src/utils/lint_shell.sh`, through the guard-clearing `senv.bat` form:
  `lint_shell: 57 tracked scripts`, `lint_shell: clean`, exit 0.
- `cmd /d /c a.sqlite-check.cmd` (inspected: `--step 2`, shared authoring
  Python 3.13.9): lint floor clean, effort Bash and Python syntax checks,
  `Ran 33 tests`, `OK (skipped=3)`, then
  `PASS CMD remote=0, launcher exit=0`, `remote=42 ... exit=5`,
  `remote=4 ... exit=55`, `remote=199 ... exit=5`, and
  `SQLite cumulative checks passed through step 2`; exit 0.
- `cmd /d /c a.sqlite-step2-linux.cmd` (inspected first: it tars the driver,
  shared install functions, Python support and build harness, copies them over
  SSH and runs them in a fresh `mktemp -d /tmp` directory under
  `bash --noprofile --norc` with `BASH_ENV` unset): 32 `PASS` lines,
  `Bash process cases passed: 32`, exit 0. The printed SHA-256 values for
  `python_install_functions.sh`, `install` and `verify.python-sqlite-build.sh`
  equal the reviewer's hashes of the staged blobs.
- `rg -n 'post_install_check|res_install|res_package|current' src/install/env/install`
  (run through the ripgrep search tool): the callback block at lines 354-359
  sits between `res_install` (347-350) and `res_package` (363-366). `current`
  appears only in the source selector (198-199) and the final selector update
  (406-412) after `main`.
- `rg -n 'LIBSQLITE3|python_sqlite|required|check_sqlite' src/install/env/python`:
  the predicate and checker at lines 4 and 10, scoped `LIBSQLITE3_*` at 114-116,
  and the build and callback calls at 147-148 and 153-154. Remaining matches are
  the Step 1 probe's own `required` arguments and messages.

Additional reviewer checks:

- `git diff --cached --check` passed.
- The pinned CPython 3.13.15 tarball on the build host was read with
  `tar -xzO` and changed nothing.
- No coverage percentage applies.

### Resolved validation set and sources for step 2 python-sqlite-support (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project `.review-validation`)
- `cmd /d /c a.sqlite-check.cmd` (source: plan; Windows wrapper for the
  cumulative `--step 2` runner)
- `cmd /d /c a.sqlite-step2-linux.cmd` (source: plan; native Linux counterpart
  running `verify.python-sqlite-build.sh --python /usr/bin/python3` in owned
  RHEL scratch)
- `rg -n 'post_install_check|res_install|res_package|current' src/install/env/install`
  (source: plan Step 2 addendum)
- `rg -n 'LIBSQLITE3|python_sqlite|required|check_sqlite' src/install/env/python`
  (source: plan Step 2 addendum)

### Resolver drift and direction for step 2 python-sqlite-support (exchange 1) (round 1)

No drift. The request carries the lint floor, the plan's Windows cumulative
runner wrapper, its native Linux counterpart (both platforms are needed because
Windows cannot run the symlink process cases and Linux cannot run actual CMD),
and the two Step 2 inspections. The `rg` inspections ran through the ripgrep
search tool because `rg` is not on this PowerShell path; the patterns and
target paths are identical.

### Repository state around validation for step 2 python-sqlite-support (exchange 1) (round 1)

- **Index trees:** the request-time, reviewer-entry and assessed trees are all
  `5804213c71bcc8b63e6f7a9cb0836c9206abc5ba` (no reviewer repair).
- **Umbrella digest:** unchanged
  (`85440ae0c9c1a64ee082ccb5472a8aca093bf7c5e9ef10e60f9faf39ac1db0ff`).
- **Validation state:** the comparison over the six staged Step 2 paths reports
  no tracked, ignored or untracked difference. The wrappers rewrote only their
  own ignored root artifacts (`a.sqlite-step2-material.tar`,
  `a.sqlite-step2-linux.raw.txt`).
- **Remote scratch:** the native transport leaves its tarball and extracted
  `mktemp` directory under the build host's `/tmp`, while the build harness
  itself removes its fixture root on success. This is retained diagnostic
  material outside the repository, not a tracked side effect.
- **Unstaged tracked change:** the protocol transcript only, neither read as
  working context nor staged.

### Repair inventory for step 2 python-sqlite-support (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 2 python-sqlite-support (exchange 1) (round 1)

`commit-plan-check.bat --format json` ran independently on the received tree and
returned status 0, `state: valid`, `ready: true` and no diagnostics, with six
staged paths in two groups:

1. `feat(sqlite): check capability before packaging`: Python support, shared
   driver, native build harness, CMD launcher fixture and cumulative runner;
2. `docs(python-sqlite-support): record step 2 validation`: the validation plan.

Membership, order and subjects match the staged work, and `a.commit` was not
amended. The status 0 proves only mechanical grouping.

### Findings and boundaries for step 2 python-sqlite-support (exchange 1) (round 1)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 2 python-sqlite-support (exchange 1) (round 1)

No change is requested for Step 2.

1. Present this advisory commit-ready recommendation at the human commit gate,
   and include the review transcript through the residual continuation.
2. Optional, outside the reviewed tree: the ignored native transport leaves its
   tarball and `mktemp` directory in the build host's `/tmp`. Consider removing
   the owned directory after a successful run in later wrappers.
3. Step 4 must still prove the literal Makefile, `pybuilddir.txt` and
   `libpython` checks against the real populated 3.13.15 tree; these fixtures
   establish caller behavior only.

### Decision rationale for step 2 python-sqlite-support (exchange 1) (round 1)

Decision: commit-ready (advisory).

The readiness floor passes:

- **Exact identity:** envelope, human-readable identity, plan, step 2, round 1,
  occurrence 1, umbrella and request-time tree `5804213` agree.
- **Complete implementation:** Step 2 matches the plan, and its literal
  source-build checks were confirmed against the pinned CPython 3.13.15
  sources.
- **Mandatory validation:** all five resolved commands pass, including 32
  native process cases and 4 actual CMD launcher cases.
- **Attributable staged scope:** all six paths are Step 2 files.
- **No unresolved or boundary-crossing findings.**
- **Accurate `a.commit`:** mechanically ready, and its content matches.

The reviewer made no repair. This recommendation does not authorize a commit.

### Final reviewer decision for step 2 python-sqlite-support (exchange 1) (round 1)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-2-round-1 -->

## Round 1 by human - Step 2 - human-confirmation

- Recorded: 2026-09-15T22:16:52+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-1 -->

## Round 1 by requestor - Step 3

- Recorded: 2026-09-16T09:32:09+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 3
- Outcome: request

### Review identity for step 3 python-sqlite-support (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
Implementation step: 3
Review round: 1

### Code review evidence for step 3 python-sqlite-support (round 1)

request_index_tree: 41b5f2b5b5c7fd7884b20a85912d5b1e86f56000
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.python-sqlite.sh --step 3 --python ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe (sources: plan; local path rendered relative to the repository)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(closure): bind Python 3.13.15 declaration
group 1 path: src/setups/env/closure/closure-config.txt
group 1 path: src/setups/env/closure/closure-envelope.txt
group 1 path: src/setups/env/closure/README.md
group 1 path: docs/v0.27.0/verify.python-sqlite-closure.sh
group 2: docs(python-sqlite-support): record step 3 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md
staged path: docs/v0.27.0/verify.python-sqlite-closure.sh
staged path: src/setups/env/closure/README.md
staged path: src/setups/env/closure/closure-config.txt
staged path: src/setups/env/closure/closure-envelope.txt
```

### Requestor assessment for step 3 python-sqlite-support (round 1)

Step 3 code and fixture implementation is complete and its validation plan
records Yes. The plan explicitly orders the already-authorized retention merge
after reviewed bundle commits; that merge and fresh-clone proof remain pending,
are stated as pending in the validation record, and gate delivery. Please assess
this distinction explicitly rather than treating the source ref as clone proof.

Git Bash passed the cumulative Step 3 runner: tracked Bash lint, effort syntax
and ShellCheck, 33 probe tests with three Linux symlink skips, four CMD boundary
cases, and 27 closure checks. Native RHEL passed all 27 closure checks against
the real source SHA, all 33 probe tests without skips, and 32 build-process cases.
The fixture tests exact source authority directly without publication. Markdown
checks and git diff --cached --check passed. No production function, class,
grammar, algorithm or architecture boundary changed. The new 156-line Bash
fixture is explicitly checked outside the tracked lint inventory's docs scope;
every helper is called and no new unit-tested class needs coverage completion.

Historical suites were run once against the candidate pair. Step 2 has two
old-version/waiver expectation failures (89/91 pass); Step 5 has 15 old-input
gate/waiver/archive failures (235/250 reached cases pass). These are recorded
as failed runs, not reported green. An isolated env copy with only the original
pair restored from parent 3a1d113 then passes all 91 and 254 cases with identical
scripts, harness and corpus. The new candidate fixture separately covers the
new version and waiver-free behavior. Do not edit the 9,136-line old harness
or interpret the historical controls as dynamic candidate acceptance.

Evidence is in the validation plan and ignored a.sqlite-step3-*.log files named
there. The historical harness, corpus and new fixture hashes are recorded.
The configured project gate is .review-validation's Bash lint, as adapted by
the approved SQLite plan; this repository does not use a ghog/pytest walk.

### Implementation report for step 3 python-sqlite-support (round 1)

The user explicitly approved the prepared auxiliary source commit, retention
merge and composable merge hook on 2026-09-16. Source commit
13c80d572ba7bda91728806ad7dc11c53629a506 was created in a clean linked worktree
with parent 3a1d1135a3e627b74d134db24694121e70ea6b14. Its sole changed file is
src/setups/env/closure/closure-config.txt. The committed LF UTF-8 blob has SHA-256
63a955f8bded96f6a469764c625e9653c0988abe03ebd8192fc541f802d9d5aa and matches
the exact approved bytes. Existing pre-commit and commit-msg dispatchers and
their sensitive-content children ran, using the same local and shared rules.
Their inventory and hashes are unchanged; no merge hook is installed yet.

The staged pair copies that source blob and records its real source SHA and
digest in the envelope. Only Python 3.13.9 becomes 3.13.15 and the SQLite waiver
is removed. The SQLite floor, root/current, all other entries and ordering stay
unchanged. The closure README records maintenance commands, source identity,
the later retention merge, non-first-parent old-envelope limitation and item 7
handoff obligations. Step 4 retains real dynamic candidate acceptance.

The new fixture exercises scope, location and identity refusal rules using
existing checker functions, then checks the actual repository pair. The Step 2
cumulative runner already selected and linted this file for --step 3, so the
runner needs no further edit. Its static provider files are explicitly not ELF
or dynamic SQLite acceptance evidence.

The eventual merge must preserve the reviewed tree and require a clean worktree.
The temporary pre-merge-commit will invoke git hook run pre-commit, preserving
existing dispatchers and every child. Git also runs commit-msg. The prepared
procedure checks inventory/hashes, source ancestry, tree identity and a fresh
single-branch clone. Keep source ref/worktree until then. No push is authorized.

### Change summary for step 3 python-sqlite-support (round 1)

The staged request snapshot contains exactly five files in two a.commit groups.

Group 1, feat(closure): bind Python 3.13.15 declaration:

- src/setups/env/closure/closure-config.txt
- src/setups/env/closure/closure-envelope.txt
- src/setups/env/closure/README.md
- docs/v0.27.0/verify.python-sqlite-closure.sh

Group 2, docs(python-sqlite-support): record step 3 validation:

- docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md

The declaration and envelope remain in one commit. The previously untracked
fixture is staged with the Step 3 bundle, so the later clean-tree precondition
will include it. The trailing documentation group records measured evidence
and clearly pending post-commit proof. Root a.commit is formatted and the
readiness checker returned valid with no diagnostics. The exchange's appended
transcript is workflow output, handled by the normal authorized cleanup route.

### Writer response for step 3 python-sqlite-support (round 1)

Writer response:

This is the first review round for Step 3. No earlier Step 3 reviewer feedback
or repairs have been received. The human's requested hook-composition and
untracked-fixture clarifications were incorporated before auxiliary approval.
That approval covers the source commit and later retention operations; the
normal reviewed grouped commit decision remains separate.

### Reviewer focus for step 3 python-sqlite-support (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-3-round-1 -->

## Round 1 by reviewer - Step 3

- Recorded: 2026-09-16T09:38:07+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: answer

### Assessed index identity for step 3 python-sqlite-support (exchange 1) (round 1)

Baseline index tree: 41b5f2b5b5c7fd7884b20a85912d5b1e86f56000

Assessed index tree: b3a842934dba2b673676394b1d3849682cd71731

### Implementation check for step 3 python-sqlite-support (exchange 1) (round 1)

Result:

Yes. Step 3 has been fully implemented.

The declaration, envelope, source snapshot, README record and focused fixtures
match the plan. The retention merge and fresh-clone proof are ordered after the
reviewed bundle commit by the plan itself, so their absence is sequencing, not
missing work; the validation record states they are pending.

#### What was verified for step 3 python-sqlite-support (exchange 1) (round 1)

- **Declaration.** The only changes are `subdir|python|python-3.13.9` to
  `python-3.13.15` and the removal of `waiver|libsqlite3.so.0|python-sqlite-support`.
  The SQLite floor at `tools/python`, `root`, `current`, every other record,
  the families, the entry points and the root ordering are untouched.
- **Source identity, checked independently by the reviewer:**
  - `13c80d572ba7bda91728806ad7dc11c53629a506` is a commit whose parent is the
    current branch head `3a1d113`;
  - `git diff-tree` shows exactly one changed path, the declaration;
  - its blob hashes to
    `63a955f8bded96f6a469764c625e9653c0988abe03ebd8192fc541f802d9d5aa`, equal to
    the staged declaration's hash and to the envelope's `digest` line, and a
    byte comparison of the two blobs is identical;
  - the envelope's `source` line names that commit and the canonical path;
  - the commit is reachable through the retained branch
    `sqlite-source-3.13.15-step3` and its linked worktree, and is not yet an
    ancestor of the branch head, which is exactly the pending merge.
- **Checker behavior.** The new 156-line fixture runs 25 isolated controls plus
  two checks of the real repository pair. It covers candidate scope, a retained
  3.13.9 directory reported as unexpected, missing SQLite, Git-only SQLite, a
  stale waiver, altered declaration bytes, CRLF, a changed source blob, and
  valid exact source identity. Its synthetic Git repositories are disposable and
  its scratch tree is removed on exit. Its empty provider files are labeled as
  static name and location evidence only.
- **README.** It records the ownership change (3.13.9 to 3.13.15, waiver removed,
  floor retained), the source identity table, the exact blob-extraction and
  envelope-regeneration commands, direct consistency and authority checks, the
  later merge and clone obligations, and the item 7 handoff. The maintenance
  rule is now scoped to delivered bundles, which is what makes the source
  snapshot's retained old envelope legitimate.
- **Historical suites.** The writer's report matches the recorded logs: the
  unedited `verify.closure-check.sh` Step 2 and Step 5 suites fail 2 of 91 and
  15 of 250 reached cases against the new pair, because their expectations pin
  the old version and the removed waiver, while an isolated copy holding only
  the previous declaration and envelope passes 91 and 254. These runs are
  reported as failures, not as green.

#### Architecture check by the reviewer for step 3 python-sqlite-support (exchange 1) (round 1)

The step changes declarative configuration and documentation only. The fixture
calls existing checker functions and adds no production path, grammar or
policy. Yes, one item needs addressing, and it is recorded rather than fixed
here: the historical harness expectations are now stale, and the plan forbids
editing that harness in this effort. The reviewer added the follow-up ownership
line to the Step 3 validation rows.

#### Performance check by the reviewer for step 3 python-sqlite-support (exchange 1) (round 1)

No production computation changes. The fixture's case count is fixed and its
scans are linear over existing inputs. No, there is no performance issue that
needs to be addressed.

#### Coverage check by the reviewer for step 3 python-sqlite-support (exchange 1) (round 1)

No unit-tested class changes in this step. The new Bash fixture is
syntax-checked, linted and executed by the cumulative runner, and each of its
helpers (`check`, `contains`, `refuses`, `index_providers`, `fixture_git`,
`write_envelope`) is called by its cases. No, there is no unit-tested class
below 100% that needs completing. No, no top-level symbol staged outside a
coverage gate is unreferenced.

Validation plan effects:

One reviewer edit is confined to the Step 3 feature-integrity rows of
`docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md`. The record
already stated that the historical `verify.closure-check.sh` suites fail on the
current pair and that the harness was not edited, but it named no owner for
refreshing those expectations. The added paragraph assigns that refresh to the
harness's owning item 4, or to item 7 when it renews the pair, and repeats that
this effort must not edit the harness.

The edit was recorded as a pre-repair blob, attributed cleanly and staged. It is
polishing-only review metadata: no verdict, evidence value or hash changed.

### Pre-repair mandatory checks and coverage for step 3 python-sqlite-support (exchange 1) (round 1)

Both resolved commands ran on the received index tree
`41b5f2b5b5c7fd7884b20a85912d5b1e86f56000`. The later reviewer edit changed only
validation-record prose, so the results hold for the assessed tree.

- `bash src/utils/lint_shell.sh`, through the guard-clearing `senv.bat` form:
  `lint_shell: 57 tracked scripts`, `lint_shell: clean`, exit 0.
- `bash docs/v0.27.0/verify.python-sqlite.sh --step 3 --python <shared
  authoring Python 3.13.9>`, in the same guard-clearing CMD process so the
  configured Git Bash and ShellCheck are on PATH: the lint floor, effort Bash
  syntax and ShellCheck, Python syntax, 33 probe tests (`OK (skipped=3)`), the
  four actual CMD launcher cases, then all 27 closure checks, ending with
  `SQLite closure: 27 checks passed in 17 seconds` and
  `SQLite cumulative checks passed through step 3`; exit 0.

The final two closure checks are the ones that matter for this step: `repository
pair is internally consistent` and `repository source bytes are authoritative`
run `closure_envelope_check` and `closure_config_authority_check` against the
real staged pair and the real source commit, with no publication operation.

Additional reviewer checks, all read-only:

- `git cat-file -t`, `git log -1`, `git diff-tree` and two `git cat-file blob`
  hashes for the source commit, plus a byte comparison with the staged
  declaration;
- `git merge-base --is-ancestor` (not yet an ancestor), `git branch --contains`
  and `git worktree list` for its retention;
- `commit-plan-check.bat --format json` before and after the repair;
- `git diff --cached --check`.

No coverage percentage applies.

### Resolved validation set and sources for step 3 python-sqlite-support (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project `.review-validation`)
- `bash docs/v0.27.0/verify.python-sqlite.sh --step 3 --python <absolute
  authoring Python>` (source: plan; run inside the guard-clearing `senv.bat`
  CMD process the plan prescribes for Windows)

### Resolver drift and direction for step 3 python-sqlite-support (exchange 1) (round 1)

No drift. The request carries the project lint floor and the plan's cumulative
Step 3 runner with an explicit absolute authoring interpreter. Earlier rounds
expressed that runner through the ignored `a.sqlite-check.cmd` wrapper; this
request states the same command directly, which the reviewer ran in the
equivalent guard-clearing CMD process. The native Linux and historical-suite
runs recorded by the writer are evidence outside the mandatory set, and the
reviewer did not repeat them.

### Repository state around validation for step 3 python-sqlite-support (exchange 1) (round 1)

- **Index trees:** the request-time and reviewer-entry trees are
  `41b5f2b5b5c7fd7884b20a85912d5b1e86f56000`. The assessed tree after the staged
  reviewer edit is `b3a842934dba2b673676394b1d3849682cd71731`.
- **Umbrella digest:** unchanged
  (`85440ae0c9c1a64ee082ccb5472a8aca093bf7c5e9ef10e60f9faf39ac1db0ff`).
- **Validation state:** the comparison over the five staged Step 3 paths reports
  tracked differences only in
  `docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md` and the index,
  both from the attributed reviewer paragraph and its staging. No untracked
  path and no validation side effect; the runner's scratch trees were removed by
  their own traps.
- **Auxiliary Git objects:** the source commit stays reachable through the
  retained branch and linked worktree. The reviewer created, moved and deleted
  no ref, worktree or commit.
- **Unstaged tracked change:** the protocol transcript only, neither read as
  working context nor staged.

### Repair inventory for step 3 python-sqlite-support (exchange 1) (round 1)

Repairs made:

- docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md (polishing-only review metadata): name the owner for refreshing the stale historical closure-suite expectations, which the record reported without assigning

Paths staged:

- docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md

### Commit plan assessment for step 3 python-sqlite-support (exchange 1) (round 1)

`commit-plan-check.bat --format json` ran independently on the received tree and
again after the reviewer edit. Both returned status 0, `state: valid`,
`ready: true` and no diagnostics, with five staged paths in two groups:

1. `feat(closure): bind Python 3.13.15 declaration`: declaration, envelope,
   README and the new closure fixture;
2. `docs(python-sqlite-support): record step 3 validation`: the validation plan.

The declaration and its renewed envelope stay in one commit, which is the
maintenance rule for delivered bundles. The reviewer edit stays inside group 2's
existing path. Membership, order and subjects match the staged work, and
`a.commit` was not amended. The status 0 proves only mechanical grouping.

### Findings and boundaries for step 3 python-sqlite-support (exchange 1) (round 1)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 3 python-sqlite-support (exchange 1) (round 1)

No change is requested for Step 3.

1. Review the reviewer's staged paragraph in the Step 3 feature-integrity rows,
   which names item 4 or item 7 as the owner of the stale historical
   closure-suite expectations.
2. Present this advisory commit-ready recommendation at the human commit gate,
   and include the review transcript through the residual continuation.
3. After the grouped commit, perform the already-authorized
   `git merge -s ours --no-ff` from a clean worktree, then record in the Step 3
   rows: the merge SHA, identical before and after tree IDs, the hook trace, and
   a fresh single-branch clone resolving the source and passing
   `closure_config_authority_check` without the temporary branch. Keep the
   source ref and worktree until that proof succeeds. Until then a fresh clone
   cannot resolve the anchor.
4. Step 4 still owns dynamic candidate acceptance; these fixtures establish
   static names, locations and exact source identity only.

### Decision rationale for step 3 python-sqlite-support (exchange 1) (round 1)

Decision: commit-ready (advisory).

The readiness floor passes:

- **Exact identity:** envelope, human-readable identity, plan, step 3, round 1,
  occurrence 1, umbrella and request-time tree `41b5f2b` agree.
- **Complete implementation:** the pair, source snapshot, README and fixtures
  match the plan. The retention merge and clone proof follow the reviewed commit
  by the plan's own ordering and are recorded as pending.
- **Mandatory validation:** both resolved commands pass, including the two
  checks of the real repository pair and its source authority.
- **Attributable staged scope:** all five paths are Step 3 files.
- **No unresolved or boundary-crossing findings:** the stale historical
  expectations are now recorded with an owner, and the plan forbids editing that
  harness here.
- **Accurate `a.commit`:** mechanically ready, and its content matches.

The only reviewer edit is polishing-only review metadata in the Step 3
validation rows. No code, fixture, declaration, envelope or grouping changed.
This recommendation does not authorize a commit, and it does not stand in for
the post-commit merge and fresh-clone proof that delivery still requires.

### Final reviewer decision for step 3 python-sqlite-support (exchange 1) (round 1)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-3-round-1 -->

## Round 1 by human - Step 3 - human-confirmation

- Recorded: 2026-09-16T10:01:17+02:00
- Exchange: code/code/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-1 -->
