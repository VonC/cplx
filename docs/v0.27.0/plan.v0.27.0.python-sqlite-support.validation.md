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

Yes. Step 2 has been fully implemented.

The selected family now checks source and installed SQLite capability on fresh
and reused output. The shared driver stops before packaging and installed
selector advancement on callback failure. Native Linux process fixtures and
the copied Windows launcher establish ordering and failure propagation.

### Goal for Step 2

Require SQLite capability for the declared RHEL 9 x86_64 family after build or
reuse and after install or reuse, before packaging and selector advancement.

### Step 2 improvement expectations

- Reject stale source and installed output with actionable stage diagnostics.
- Validate `pybuilddir.txt`, module backing files and source library precedence.
- Preserve other target families and tools without a callback.
- Prove explicit reconfigure order and nonzero propagation through the driver.

### What was implemented for Step 2

`python_install_functions.sh` owns the `el9.x86_64` predicate, explicit
`LIBSQLITE3_*` configure inputs and both calls to the existing shared probe.
The source check validates the pinned Makefile substitutions, configuration
outputs, generated module directory and configured shared-library backing.
It places the canonical source directory first in `LD_LIBRARY_PATH` and uses
`-I -S -B` to ignore inherited module overrides, skip site hooks and avoid
bytecode writes. The installed check requires the requested version's
`bin/python3.13` and passes its exact `lib/python3.13/lib-dynload` boundary.
Both checks retain interpreter diagnostics and return their nonzero status.

The optional `post_install_check` callback in the shared driver runs after
successful install, including timestamp reuse, and before package. The
existing final installed-selector update remains after every successful stage.
Generic tools without the callback retain their sequence.

The pinned `python-src-3.13.15.tar.gz` was inspected directly, with SHA-256
`c28d9d213c09b5b5ab2c29812950e12f746999e099b82894231be954b26baed9`.
Its `patchlevel.h` identifies 3.13.15, `sysconfig/__main__.py` writes the
generated directory, `Makefile.pre.in` links modules back to `Modules/`, and
Linux configure sets source-first `RUNSHARED`. Staleness compares
`config.status` and `pyconfig.h`: shared setup rewrites Makefile `EXTLIBS`
during ordinary reuse, so Makefile modification time is not a stale-build
signal. The literal build configuration is still checked independently.

Validation on 2026-09-15:

- `cmd /d /c a.sqlite-check.cmd` ran the cumulative `--step 2` runner under Git Bash 5.3.9 and authoring Python 3.13.9; exit 0. The tracked 57-script lint floor, explicit effort Bash checks and Python syntax checks passed. The unchanged probe suite ran 33 tests: 30 passed, with three host symlink-privilege skips; unit execution took 0.634 seconds, 0.730 seconds including loading.
- The Windows fixture copied the complete `src/install/install.bat`, substituted dependency commands and ran actual CMD. Remote statuses 0, 42, 4 and 199 produced launcher statuses 0, 5, 55 and 5. The test also checked log-copy and editor-stub ordering.
- `cmd /d /c a.sqlite-step2-linux.cmd` transferred the exact source and harness bytes to owned RHEL scratch and ran `bash docs/v0.27.0/verify.python-sqlite-build.sh --python /usr/bin/python3`; exit 0, all 32 cases passed. The retained raw result is `a.sqlite-step2-linux.raw.txt`; native fixture elapsed time was not separately measured.
- Native cases cover fresh compile, both build reuse branches, installed timestamp reuse, each probe failure, absent material, malformed/stale/escaping build directories, configuration mismatch, missing/incorrect executable and library paths, explicit reconfigure order, preceding stage failures, and generic callback presence/success/failure. Every case checks the unrelated sentinel and the installed selector/package result.
- The first valid test-first run reported missing source and installed probe events. A later fixture exposed the Makefile maintenance false rejection, which was corrected before the final pass. Windows runs the CMD portion; real-symlink Bash process cases require native Linux. The unchanged Step 1 probe's 33-case RHEL result still covers its three Windows-skipped cases.
- `git diff --check` and both planned `rg` checks passed. No compiler or candidate build was started by these process fixtures.

Final Linux material SHA-256 values:

| File | SHA-256 |
| --- | --- |
| `python_install_functions.sh` | `006ff0788dc02903d226f8df6b4f500f106775420da1424206b038e5ac528ad8` |
| `src/install/env/install` | `def70ac222b11845f6be117974f86e2af4344ac8f5b4a19842b7a74110247d27` |
| `verify.python-sqlite-build.sh` | `09f071728f8c572feb68fbb7cea0dff0c19742cce3d9e37ce3e0619e2746dc18` |

### New types or classes introduced for Step 2

No production class or public type was added. The Bash helpers own Python
policy and probe invocation. The 93-line Python CMD process fixture is
verification material, separate from the production probe and unit suite.

### Architecture check for Step 2

Python-specific configuration and path validation remain in Python support.
The shared driver knows only the optional callback and its status. The probe
retains the common database and provider rules; no host-Python dependency or
new domain-layer dependency was introduced. Fixtures copy complete scripts
and use synthetic setup without sourcing production profiles.

Physical lines changed from 51 to 169 for Python Bash support, 406 to 416 for
the shared driver, and 68 to 70 for the cumulative runner. The new Bash
harness has 269 lines; the new Python process fixture has 93, below the 550
review band and 650 ceiling. The production probe remains 274 lines and its
unit module 393. No architecture or file-size issue needs addressing.

### Performance check for Step 2

The selected build adds one source probe and one installed probe. Each retains
Step 1's fixed database operation and single linear mapping observation.
Configuration parsing scans the Makefile once with a fixed set of keys;
path checks resolve named inputs without walking the tool tree. There is no
new sorting or quadratic work. Source checks do not automatically reconfigure,
clean or compile. No performance issue needs addressing.

### Unit test coverage check for Step 2

The repository's gate measures Bash lint, with no Python coverage percentage.
Step 2 changes Bash orchestration and adds process fixtures; it adds no
unit-tested class. Existing probe tests cover generated links backed by
`Modules/`, installed-extension escapes, library identity mismatch/missing
observations and provider refusal. The new CMD fixture's `check_launcher`
entry calls `write_batch`; both functions are exercised by the cumulative
runner. No unit-tested class introduced by this step needs completion, and
no new top-level symbol is unreferenced.

### Feature integrity for Step 2

Other target families retain the existing configure inputs and skip the
SQLite gates. Tools without a callback preserve the shared sequence.
Failures preserve the installed `current` selector and package output;
source selection still follows the existing driver behavior. The explicit
reconfigure route remains the only cleanup trigger. This does not promise
rollback of internal files in an already selected prefix.

The new native and CMD cases use owned copies and command stubs. They prove
caller contracts, not a compiled 3.13.15 candidate's capability. Step 4 still
owns the real populated-tree rebuild and three-environment acceptance, with
the previously recorded environment prerequisites unresolved. Existing
features and reporting remain intact.

## Step 3: Bind the candidate layout to its closure declaration

### Analysis of Step 3 implementation state

Yes. Step 3 has been fully implemented.

The declaration, matching envelope, source snapshot and focused fixtures passed
review and the human-authorized grouped commit gate. The later authorized
retention merge preserved the complete reviewed tree. A fresh single-branch
clone resolves the retained source and passes consistency and authority checks.
The recorded ancestry and clone evidence completes Step 3's post-commit work;
Step 4's built-candidate acceptance remains separate.

### Goal for Step 3

Declare only the approved Python version shape, remove the satisfied SQLite
waiver and retain a byte-consistent envelope anchored to real source bytes.

### Step 3 improvement expectations

- Accept the 3.13.15 layout with Python root/current and the SQLite floor.
- Preserve missing/misplaced payload, stale waiver and undeclared-version refusals.
- Resolve the envelope's real source commit without a publication operation.
- Check auxiliary-operation authorization, active hooks, blob digest and ancestry.

### What was implemented for Step 3

The declaration replaces only `python-3.13.9` with `python-3.13.15` and removes
the SQLite waiver. Python `root` and `current`, the SQLite floor at
`tools/python`, other floor entries, families, entry points and ordering remain
unchanged. The three-line envelope names the real source blob and its digest.

The human approved the prepared auxiliary operations on 2026-09-16 with
"OK, approved, go ahead". The source commit was created in a separate clean
linked worktree. Its parent is the pinned implementation HEAD, its only changed
path is `src/setups/env/closure/closure-config.txt`, and its blob matches the
approved LF UTF-8 bytes, including comments and final newline.

| Source identity | Value |
| --- | --- |
| Source commit | `13c80d572ba7bda91728806ad7dc11c53629a506` |
| Source parent | `3a1d1135a3e627b74d134db24694121e70ea6b14` |
| Declaration SHA-256 | `63a955f8bded96f6a469764c625e9653c0988abe03ebd8192fc541f802d9d5aa` |
| Envelope SHA-256 | `f849a4ce2a4bd53d30297f19708431222b1b1b9168fc32ec599066e9fc38b236` |
| New fixture SHA-256 | `fa1cbadbe392a4d61921a5973c262ddfab95dab2dad3a7b01e4f26835dd4944d` |

The existing `pre-commit` and `commit-msg` dispatchers ran successfully, with
their sensitive-content children and the same shared and local replacement
rules. Their inventories and all four file hashes stayed unchanged. The
ignored creation and hook evidence is retained in `a.sqlite-source-create.log`,
`a.sqlite-source-commit.log` and `a.sqlite-source-hooks-before.txt`.
The temporary `pre-merge-commit` called `git hook run pre-commit` during the
retention merge, preserving the existing hook chain. Git also ran `commit-msg`.
Only that temporary hook was removed after verification; the original hook
inventory and all four file hashes remained unchanged.

The closure README records the source identity, exact blob extraction and
envelope regeneration commands, direct consistency/authority checks, ownership
and item 7 handoff obligations. The new 156-line
`verify.python-sqlite-closure.sh` exercises candidate scope, retained 3.13.9,
missing and Git-only SQLite, stale waiver, changed declaration bytes, CRLF,
changed source blob and valid exact source identity. Its 25 isolated controls
are followed by two checks of the real repository pair. The existing 70-line
cumulative runner already invokes and lints this file for `--step 3`, so no
further runner edit was needed.

Verification on 2026-09-16:

- `cmd /d /c a.sqlite-check.cmd` ran the cumulative runner with `--step 3` and the explicit shared authoring Python 3.13.9. Git Bash 5.3.9 passed the 57-script tracked lint gate, effort Bash syntax and ShellCheck, 33 probe tests with three Linux-only skips, four CMD launcher boundary cases, and all 27 closure checks in 19 seconds. Evidence: `a.sqlite-step3-cumulative-windows.log`.
- Native RHEL 9.8, Bash 5.1.8 and Git 2.52.0 ran the exact new fixture bytes against the real source commit from a transferred Git bundle. All 27 closure checks passed in under one second. Direct consistency and authority calls resolved the source above without publication. Evidence: `a.sqlite-step3-regressions-linux.log`.
- Native RHEL also ran all 33 probe unit tests without skips in 0.252 seconds and all 32 Bash build-process cases. The Windows run covers the separate CMD portion. Evidence: `a.sqlite-step3-controls-linux.log`.
- The unchanged historical `verify.closure-check.sh --step 2` and `--step 5` suites ran once against the new pair with `contract.closure-tools.txt` and `fixtures.closure-corpus.txt`. Step 2 reported 2 failures out of 91 cases: its hardcoded 3.13.9 root and SQLite-waiver assertions. Step 5 reported 15 failures out of 250 reached cases: its gate, waiver and archive expectations require the removed waiver and old version tree. These current-pair runs did not pass; their complete results are in `a.sqlite-step3-legacy2.log` and `a.sqlite-step3-legacy5.log`.
- To isolate that historical-input dependency, a separate copy of `src/setups/env` received only the declaration and envelope blobs from the pinned parent. Running the same suites with `--shipped-dir <historical-copy>/bin` then passed 91/91 and 254/254 cases in 2 and 8 seconds. All scripts, harness, contract and corpus stayed identical; four downstream archive cases became reachable. These are historical regression controls, not candidate acceptance. Evidence: `a.sqlite-step3-historical2.log`, `a.sqlite-step3-historical5.log` and `a.sqlite-step3-controls-linux.log`.

The historical harness SHA-256 is
`c36a86ee7f53f0b545fb6f5de4a6fae57e4904d6181f56ea5a5be1acc4970b37`;
its corpus SHA-256 is
`74f2259ebbadacca971e6aeafca544efc806605e4dffc29307498a60f8608472`.
The 9,136-line historical harness was not edited.

The human selected `Commit` after the independent review. The grouped commits
are `8335008` (reviewed bundle, including the tracked fixture), `7230fea`
(validation) and `ced51c4` (review transcript). The sensitive-content hook
blocked one absolute local path in the transcript; rendering that command path
relative to the repository allowed the hook to pass without a bypass.

Post-commit retention verification on 2026-09-16:

| Retention identity | Value |
| --- | --- |
| Reviewed first parent | `ced51c4600a321295de091fa6d0152018de89904` |
| Retention merge | `5f8d4d67ca549bb74e3bcbb798124d628c3d0619` |
| Source second parent | `13c80d572ba7bda91728806ad7dc11c53629a506` |
| Tree before and after merge | `ac3f0249da80b3afb7387a11a2ae6199da9c4cdd` |

The implementation worktree was clean, including untracked files, before and
after `git merge -s ours --no-ff`. Its two parents and identical tree IDs were
verified directly. The trace records the temporary merge hook calling the
existing `pre-commit` dispatcher, followed by Git's `commit-msg` invocation.

`git clone --no-local --single-branch --branch python-sqlite-support` created
the fresh `a.sqlite-source-clone` at the merge above. Its sole remote branch
and fetch refspec name `python-sqlite-support`; no source branch was fetched.
The source commit exists there as an ancestor, its declaration blob has the
recorded digest, and direct `closure_envelope_check` and
`closure_config_authority_check` calls pass. Both original and clone worktrees
were clean at verification. The source ref/worktree remain retained locally.

Evidence: `a.sqlite-source-merge.log`, `a.sqlite-source-clone.log`,
`a.sqlite-source-retain-proof.log`, `a.sqlite-retention-evidence.txt` and
`a.sqlite-retention-hooks-before.txt` / `a.sqlite-retention-hooks-after.txt`.
No push or publication has run.

### New types or classes introduced for Step 3

None. The fixture's `check`, `contains`, `refuses`, `index_providers`,
`fixture_git` and `write_envelope` helpers are each called by its top-level
cases. Production checker functions and formats are unchanged.

### Architecture check for Step 3

This step changes declarative configuration and documentation, with fixtures
calling the existing closure functions. It adds no production layer dependency
or new policy path. No DDD-Hexagonal boundary is changed. The declaration is
33 lines, envelope 3, README 179 and new fixture 156, below its 220-line target
and the repository review band. The cumulative runner remains 70 lines.
No architecture or file-size issue needs addressing.

### Performance check for Step 3

No production computation changes. Fixture work has fixed case counts and
linear scans over the existing declaration/provider inputs; its source Git
repositories are disposable. There is no new sorting or quadratic algorithm.
No performance issue needs addressing.

### Unit test coverage check for Step 3

The configured repository gate measures Bash lint, not a Python coverage
percentage. This step changes no unit-tested class. Its new Bash fixture is
explicitly syntax-checked, linted and executed by the cumulative runner;
each top-level helper is exercised. All existing 33 probe unit cases passed
on RHEL, including the three Windows-skipped cases. No unit-tested class
needs completion, and no new top-level symbol is unreferenced.

### Feature integrity for Step 3

The SQLite floor and refusal rules remain intact: missing SQLite and a provider
only under Git still fail, and a retained 3.13.9 directory is unexpected.
The isolated historical controls confirm existing waiver and publication
behavior with their original inputs. The new fixtures certify static names,
locations and exact source identity; they do not certify a built candidate's
dynamic capability. Step 4 still owns that acceptance on all three roles.

The historical `verify.closure-check.sh` Step 2 and Step 5 expectations are
pinned to the previous declaration, so they report the recorded failures on the
current pair until they are refreshed. That refresh belongs to the harness's
owning item, item 4, or to item 7 when it renews the pair; this effort must not
edit that harness. Schedule it there rather than leaving the suites red without
an owner.

The auxiliary source snapshot retains the previous envelope. It is not a
delivery bundle, and an all-ancestor traversal can encounter that intermediate
pair after retention. Item 7 must distinguish this source revision from its
final candidate cplx revision and retain the recorded merge/clone evidence. Any
declaration change requires a renewed pair and final-archive acceptance.

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
