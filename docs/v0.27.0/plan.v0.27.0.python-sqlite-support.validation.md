# v0.27.0 Python SQLite support implementation tracking and validation

No, it is not implemented.

Track the four steps in the [implementation plan](plan.v0.27.0.python-sqlite-support.md).
Step 1 is implemented and checked. Steps 2-4 and candidate acceptance remain pending.

## File-based IO cost clarification for SQLite validation

Check one bounded temporary database operation and one maps read per probe,
linear parsing with identity deduplication, independently supplied paths and
one structured result. Preserve existing build reuse and closure inventories.
Archive digest checks belong at transfer boundaries; fixture tests must not
walk or hash live RPM caches. Record actual timings without invented limits.

## Step 1: Implement the shared probe and establish acceptance prerequisites

### Analysis of Step 1 implementation state

Yes. Step 1 has been fully implemented.

The standalone probe, focused tests and cumulative runner are present. All 33
unit tests passed on RHEL, including the three symlink cases unavailable on the
Windows authoring account. A real Linux provider fixture passed and a different
expected backing file failed. The prerequisite assessment records every
unavailable acceptance facility as blocking Step 4, as this step permits.

### Goal for Step 1

Provide one standard-library database/provider probe and establish the exact
isolation, source anchoring and Debian runtime/copy prerequisites for acceptance.

### Step 1 improvement expectations

- Detect wrong, absent, escaped, deleted or ambiguous provider identities.
- Share database and identity rules across the three explicit stages.
- Confirm the separate anchor-compatible home first and establish the Debian route, or retain blockers.
- Verify the source module link and mapped build `libpython` identities.

### What was implemented for Step 1

- [Shared probe](../../src/install/env/python/sqlite_probe.py): 274 lines; explicit build, installed and operator stages; independently supplied roots; source module-link and mapped `libpython` checks; canonical path and device/inode comparison; one maps snapshot; one persistent temporary database round trip; structured success, failure and inconclusive results.
- [Focused unit tests](../../tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py): 393 lines plus four empty test package markers; database lifecycle and cleanup, mapping permutations and duplicate costs, escaped paths, identity refusals, source/installed boundaries and CLI status checks.
- [Cumulative runner](verify.python-sqlite.sh): 68 lines; mandatory shell lint, explicit effort Bash syntax and ShellCheck, Python syntax and standard-library unit tests with a caller-selected authoring interpreter.
- [Prerequisite and probe evidence](acceptance.python-sqlite-support.md): 143 lines; read-only preflight before implementation, profile hashes and relocation analysis, missing isolated home and Debian route, exact probe digest, Linux fixture commands and observed results. Access handles remain in ignored notes.

Recorded validation on 2026-09-15: `cmd /d /c a.sqlite-check.cmd`, using the
plan's same-process setup and cumulative `--step 1` command, exited 0 under
Git Bash 5.3.9 and Python 3.13.9. The mandatory 57-script floor and explicit
new-runner checks passed; 30 unit tests passed and 3 symlink cases skipped
for unavailable Windows privilege (0.532 seconds; runner phase 0.623 seconds).
The documented RHEL command ran all 33 tests under Python 3.9.25 without skips
in 0.261 seconds. The real probe returned 0 for the copied provider and 2 for
the different-file control; the positive duration was 0 at one-second
resolution. These are mechanism checks, not candidate acceptance.

### New types or classes introduced for Step 1

`ProbeError` carries the failed or inconclusive outcome to the JSON boundary.
`ProbeArguments` adapts argument errors to that same boundary. Both live in
the standalone probe. `SqliteProbeTests` owns temporary test fixtures; its
local `Connection` adapter records the real database commit/close lifecycle.
No production package or external dependency was introduced.

### Architecture check for Step 1

The probe is an infrastructure adapter with separate parsing, filesystem
identity, database and result functions. It imports only the standard library;
SQLite imports occur within assessment so failures remain structured. Expected
roots come from callers, and synthetic observations enter only through tests.
No business layer imports technical helpers or acquires a wrong dependency.
The Python files are below the 550-line safe-band boundary and 650-line ceiling.
The review found an unreachable ambiguity branch; the corrected matcher now
collects identities before classifying multiple providers as inconclusive.
Only a wrong provider remains failed, independent of mapping order.
No architecture, responsibility or file-size issue needs fixing.

### Performance check for Step 1

Production map parsing and matching are linear in the snapshot size. A set
deduplicates relevant entries before backing-file observation; 100 duplicate
segments require at most two identity reads, including the expected file.
The database contains one fixed record and owns only its temporary directory.
The tests assert one maps read after both database connections close. There
is no payload hashing, tool-tree discovery or extra build in this step. The
24 fixed test permutations add no superlinear production computation. Timings
are observations with their resolution recorded, without an invented threshold.
No performance issue needs addressing.

### Unit test coverage check for Step 1

The repository's `.review-validation` measures the Bash lint floor; it defines
no Python coverage gate. The confirmed plan uses standard-library unit tests
and behavioral evidence, so no percentage is claimed for the new Python files.
The unit module sits under `tests/unit/sqlite_probe/test_sqlite_probe/` and
exercises the two production classes and all top-level functions directly or
through `assess()` and `main()`. It covers persistence, cleanup on failure,
map order and duplicate counts, malformed/unavailable observations, path
escaping and symlinks, competing/stale identities, source-library boundaries,
import failures and nonzero structured outcomes. The review additions exercise
the source executable/library relationship, library and generated-root escape,
missing `Modules/`, non-regular extension/provider backing, a file as scratch,
unavailable Linux device identity and both competing-provider map orders.
These ten added tests require no symlink privilege. Module-level file loading
reaches the standalone script without requiring a production package.
Static review found no incomplete unit-tested class requiring additional work;
100% coverage has not been measured. No top-level production symbol is unreferenced.

### Feature integrity for Step 1

This additive step does not yet wire the build driver or change configure,
reuse, packaging, relocation, selectors or closure declarations. Those changes
belong to Steps 2 and 3. The controlled Linux fixture used copied system
material within owned scratch paths and preserved host files. Its temporary
database directories were removed after both outcomes. No existing feature
or reporting capability was impaired. Step 4 remains blocked by the recorded
isolated-home, profile-chain, deployment-target and Debian runtime/copy
prerequisites; no candidate or final item 7 acceptance is claimed.

## Step 2: Enforce SQLite capability before Python packaging

### Analysis of Step 2 implementation state

Not started. Step 2 is not implemented because scoped configure inputs,
source/installed checks and the optional driver callback have not been added.

### Goal for Step 2

Require SQLite capability for the declared RHEL 9 x86_64 family after build or
reuse and after install or reuse, before packaging and selector advancement.

### Step 2 improvement expectations

- Reject stale source and installed output with actionable stage diagnostics.
- Validate `pybuilddir.txt`, module backing files and source library precedence.
- Preserve other target families and tools without a callback.
- Prove explicit reconfigure order and nonzero propagation through the driver.

### What was implemented for Step 2

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 2

_(empty — no check has taken place yet.)_.

### Architecture check for Step 2

_(empty — no check has taken place yet.)_.

### Performance check for Step 2

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 2

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 2

_(empty — no check has taken place yet.)_.

## Step 3: Bind the candidate layout to its closure declaration

### Analysis of Step 3 implementation state

Not started. Step 3 is not implemented because the candidate declaration,
renewed envelope and exact-source/refusal checks have not been delivered.

### Goal for Step 3

Declare only the approved Python version shape, remove the satisfied SQLite
waiver and retain a byte-consistent envelope anchored to real source bytes.

### Step 3 improvement expectations

- Accept the 3.13.15 layout with Python root/current and the SQLite floor.
- Preserve missing/misplaced payload, stale waiver and undeclared-version refusals.
- Resolve the envelope's real source commit without a publication operation.
- Check auxiliary-operation authorization, active hooks, blob digest and ancestry.

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

## Step 4: Prove one candidate on the three required environment roles

### Analysis of Step 4 implementation state

Not started. Step 4 is not implemented because no candidate has been rebuilt,
packaged or accepted under this plan on the three required environment roles.

### Goal for Step 4

Establish populated-tree rebuild, isolated assembly/deployment and same-process
SQLite provider success for one identified archive, with live-tree preservation.

### Step 4 improvement expectations

- Retain separate build-account, Debian 12 and RHEL deployment evidence.
- Tie all results to the same candidate and closure/source identities.
- Record the absent isolated `.profile`, audited inputs and full content manifests.
- Leave missing prerequisites or environment evidence incomplete.
- Give item 7 reproducible commands to repeat on its final refreshed archive.

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
