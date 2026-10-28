# v0.27.0 bundled SQLite implementation tracking and validation

Yes, it is implemented.

Track the five steps in the [implementation plan](plan.v0.27.0.sqlite-runtime-upgrade.md).
All five steps are implemented and checked, the Debian 12 agent run included.
The item's code review completed after three rounds, and its specification
review converged after five, so umbrella row 9 is completed.

## Step 1: Build SQLite as a cplx library tool

### Analysis of Step 1 implementation state

Yes. Step 1 has been fully implemented.

### What was implemented for Step 1

- [Library tool](../../src/install/env/sqlite/sqlite_install_functions.sh):
  pinned source identity per version, the `verify_archive` hook on the
  selected archive before extraction, the tree checks before configure and
  make, sysroot `jimsh0` bootstrap, configure line, library checks after build
  and installation, post-install link checks.
- [Installer hook](../../src/install/env/install): the optional
  `verify_archive` call on the selected archive, exit 27 before extraction.
- [Source fixtures](verify.sqlite-source.sh): seven cases on the real installer
  and tool functions.
- [Compile set](../../src/setups/pkgs/sqlite/sqlite_rhel_9.6_x86_64.txt),
  tool order in both property templates, and the `sqlite` block of
  `tools/senv.local.tpl`.
- [Complete payload removal](../../src/setups/env/bin/packages_management.sh):
  `remove_package` continues past `cpio:` notices.

Recorded validation on 2026-10-27, on the RHEL 9.8 build host:

- The archive SHA-256 and SHA3-256, the `sqlite3.c` SHA3-256 and the source id
  matched the pins. In that build the check ran inside `configure`, after the
  installer had extracted the archive, and named a fixed file rather than the
  selected one; code review round 1 found it. The only file matching the
  version in the tool's `sources/` is that canonical archive, so the build
  used it.
- Package `sqlite-3.54.1-20261027.0839.el9.x86_64.tar.gz`, SHA-256
  `c677c3a0ce7b9bed8dc980463eb46fd0af6ad4d78294cde4f8093f9c75b16d9b`.
- Library `libsqlite3.so.3.54.1`, SHA-256
  `c2f5339d6e3f7588551076a5c60347f8394e5e6124140162a8ca89fc79d26b3b`:
  SONAME `libsqlite3.so.0`, needs `libz`, `libm` and `libc`, carries
  `RUNPATH` only, needs at most `GLIBC_2.34`.
- Three faults found during the build are fixed in the committed tool: the
  `jimsh0` bootstrap compiler, the missing `-lm`, and `DT_RPATH`.
- ShellCheck at style severity is clean for the new functions; the
  mandatory shell lint floor passed on 59 tracked scripts.

Recorded validation of the round 1 correction, 2026-10-27:

- On the build host, the corrected `verify_archive` passed on the real
  selected archive before extraction (all four values), and the extracted
  tree passed the tree checks.
- `docs/v0.27.0/verify.sqlite-source.sh`: 7 cases passed natively (GNU tar
  1.34) and on Windows (GNU tar 1.35). Its archives are built with fixed member
  times, owners and order and an untimed gzip header, and a self-check proves
  equal inputs give equal bytes; the selected non-canonical archive keeps the
  pinned members, differs in its build files, and is asserted to differ from
  the canonical archive before the installer runs (review round 2, F3).
  Against the previous installer and tool file, the corrupt archive was
  extracted (exit 43 instead of 27) and the newer non-canonical archive was
  extracted, passed every check and ran its own configure (exit 199).
- The native installer fixtures, `verify.python-sqlite-build.sh` with the
  host Python, still pass all 35 cases with the hook in place.
- ShellCheck at style severity is clean on the installer, the tool file and
  the new runner; the shell lint floor passed on 60 tracked scripts.

### Feature integrity for Step 1

No existing tool changes its build. `remove_package` keeps its behavior for
payloads without notices; it now also removes the files listed after one. The
installer's `verify_archive` call runs only for a tool that defines the hook,
and SQLite is the only one.

## Step 2: Link Python to the bundled SQLite and require its exact build

### Analysis of Step 2 implementation state

Yes. Step 2 has been fully implemented.

### What was implemented for Step 2

- [Python driver](../../src/install/env/python/python_install_functions.sh):
  SQLite input stamp, reconfiguration on change, exit 26 on unreadable
  inputs, `--expected-sqlite` on every probe call.
- [Expected build](../../src/install/env/python/sqlite_expected.txt): version,
  source id and 51 compile options, without `DISABLE_DIRSYNC`.
- [Probe](../../src/install/env/python/sqlite_probe.py): 481 lines; exact-build
  comparison, provider directory check and WAL smoke check.
- [Unit tests](../../tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py):
  567 lines.
- Python's package list names `_sqlite`; the build, acceptance and fixture
  runners pass the expected build.

Recorded validation on 2026-10-27:

- The Python rebuild reported `SQLite inputs differ`, reconfigured, cleaned
  and rebuilt; `checking for stdlib extension module _sqlite3... yes`;
  package `python-3.13.15-20261027.0856.el9.x86_64.tar.gz`; `_sqlite3` needs
  `libsqlite3.so.0` through `RUNPATH`.
- The build and installed probes passed: version 3.54.1, source id, 51
  options, database round trip, WAL smoke, one mapped provider.
- `test_sqlite3 test_dbm_sqlite3` from the installed tree: 541 run, 5
  skipped, success.
- Probe unit tests: 49 of 49 on the build host with Python 3.9 (SQLite 3.34.1)
  and with the rebuilt 3.13.15 (SQLite 3.54.1); 49 on Windows with 5 symlink
  skips.
- Native installer fixtures: 35 cases passed, 3 of them new. Acceptance driver
  fixtures: 38 of 38 on the build host. The cumulative runner passed at step 4
  on Windows.

### Feature integrity for Step 2

A Python tree whose SQLite inputs are unchanged keeps its build reuse. The
previous Python package stays in the tool's package directory for rollback.

## Step 3: Document the bundled SQLite

### Analysis of Step 3 implementation state

Yes. Step 3 has been fully implemented.

### What was implemented for Step 3

- [Explanation](../../wiki/explanation/why-the-toolchain-builds-its-own-sqlite.md),
  [how-to](../../wiki/how-to/build-and-verify-the-bundled-sqlite.md) and
  [reference](../../wiki/reference/bundled-sqlite.md) pages.
- Updates to the SQLite capability and archive rebuild how-to pages, the
  sandbox-provenance explanation, the exit-code reference and the index.

No automated wiki link check exists in the suite. On 2026-10-27 every
relative link of the eight touched pages resolved on this branch.
Two updated how-to pages come from item 8's branch, as the plan's Step 3
addendum records.

## Step 4: Promote, package and qualify the archive on RHEL 9.8

### Analysis of Step 4 implementation state

Yes. Step 4 has been fully implemented.

### What was implemented for Step 4

Recorded validation on 2026-10-27:

- Promotion: the live Python is 3.13.15 with one provider,
  `libsqlite3.so.3.54.1`; the operator probe passed on the live wrapper in a
  clean environment.
- Packaging refused twice, as designed: differing loader bytes between the Git
  and Python roots, then a duplicate `libsqlite3.so.0` in the Git root from an
  orphan `sqlite-libs` payload that no ELF there needs. Item 7's runtime
  alignment checked 111 shared runtime files and replaced 44, plus 3 aliases;
  the orphan payload was removed with a backup. A Git smoke test passed.
- Third packaging: closure OK, 1255 edges over 606 subjects, 4517 version
  needs answered, 0 refused. Archive `tools.2026-10-27_093002.tar.gz`,
  544298988 bytes, SHA-256
  `470b1a5eb297b09d5d5b80b7567e2b437c1a54059989bebf9c55dd2d9ec16870`.
- Fresh relocation: install exit 0, wrapper probe passed, CPython SQLite tests
  541 run and 5 skipped with success, no loader path and no text file outside
  the prefix.
- Upgrade over the previous archive, which carried Python 3.13.9: both
  installs exit 0, the old Python is gone, the wrapper probe passed, no leak.
- Upgrade over the archive the consuming project pins,
  `tools.2026-09-18_220913.tar.gz` (SHA-256 `df7dff7d...`, Python 3.13.15
  with SQLite 3.34.1), recorded on 2026-10-28: both installs exit 0; Python's
  sandbox then holds only `libsqlite3.so.3.54.1` and its two links; the
  wrapper probe passed; a venv created before the upgrade loads the exact
  build with database and WAL checks; no loader path or text file outside
  the prefix. A verbose `test_sqlite3 test_dbm_sqlite3` run there names the
  five skips: four big-memory tests skipped without a `-M` memory limit, and
  `test_uri_windows`, which requires Windows.
- Application-style venvs, fresh and upgraded: exact identity, database and
  WAL checks passed, provider mapped inside the relocated tree.
- `CPLX-ELF` reported 26 failed rewrites in both this and the previous
  archive: 32-bit compiler start files, relocatable objects never loaded.

### Feature integrity for Step 4

The previous archive and Python package remain available for rollback. The
development environment's venv, built on 3.13.9, must be recreated on
3.13.15; that is the consequence of the promotion the user selected.

## Step 5: Qualify the archive on the Debian 12 agent

### Analysis of Step 5 implementation state

Yes. Step 5 has been fully implemented.

The recorded candidate run covers the Debian qualification and the consuming
pipeline restoration. Review round 1 independently matched the verification
bundle digest, the original and reworded cplx trees, the candidate pins and the
restored consumer tree. Execution results below are retained writer evidence;
the reviewer did not rerun the pipeline or independently retrieve its raw log.
Review round 2 closes the earlier source-verification and missing
plan-validation declaration findings: the selected archive is checked before
extraction, and the declared command set matches the plan. Review round 3
independently checked the deterministic archive construction, distinct build
files and digest/member preconditions, closing the fixture finding. All three
review findings are closed; this operational step's verdict is unchanged.

### What was implemented for Step 5

- Verification bundle from cplx `03e776fbd7b11b84330de0dac4041ae14d7f10d3`:
  189 members, SHA-256
  `a30221021d97f523e72fc718e0e68e8027fd72c5a7c16bb52410288c47af3308`.
  The item's commits were reworded afterwards without changing a file: that
  commit's tree is the tree of `e505003`.
- The archive and the bundle were uploaded as one snapshot; the repository
  reports the archive's SHA-1 and size, and the bundle downloaded back matches
  its SHA-256.
- The consuming project's temporary pipeline commit pins the candidate.

First run on 2026-10-27, result FAILURE from two faults of the
temporary checks, not of the candidate:

- Passed: fetch and digest checks, relocation, the wrapper probe with the
  bundle's probe and expected build, `test_sqlite3 test_dbm_sqlite3`, the
  application venv creation, and in that venv the exact identity (3.54.1, its
  source id, 51 options), the database round trip and the WAL smoke check.
- The loader check counted every process of the trace, including the
  wrapper's host bash, `readlink` and `dirname`. Restricted to the interpreter
  process, the retained trace shows 20 libraries initialized, all under the
  prefix except the platform's injected monitoring library.
- The venv mapping check called `match_library` without the held reference
  mapping that binds an overlay filesystem's stat identity to its mapping
  identity, which the probe's own `assess()` passes; it reported "mapped
  backing file identity differs from disk".

Second run on 2026-10-27, with the corrected checks: SUCCESS, every
step passed on Debian 12 (bookworm), whose own `libsqlite3-0` is 3.40.1:

- Fetch with digest checks and relocation passed.
- The wrapper's operator probe passed with the bundle's probe and expected
  build: SQLite 3.54.1 and its source id, database and WAL checks, provider
  `tools/python/root/usr/lib64/libsqlite3.so.3.54.1` inside the prefix.
- `test_sqlite3 test_dbm_sqlite3`: 541 run, 5 skipped, success.
- The application venv was created and loads the same build: exact identity
  with 51 options, database round trip, WAL smoke check, and the provider
  mapping bound through the probe's held reference.
- Loader checks: the wrapper's and the venv's interpreter processes each
  initialized 20 libraries, none outside the prefix except the one
  monitoring library the pipeline already excludes.

The consuming project's restore commit then returned its pipeline file and
tools pins to their content before the candidate check.

### Architecture check for Step 5

The temporary pipeline consumes the archive and an independently pinned
verification bundle through the existing candidate flow. Step 5 introduces no
production class, dependency or layer change. No architecture issue needs to
be addressed in this step.

### Performance check for Step 5

The candidate qualification is bounded and temporary; restoring the pipeline
removes it from normal builds. No performance issue needs to be addressed in
this step.

### Unit test coverage check for Step 5

This operational step changes validation metadata only. Its CPython and venv
checks are acceptance evidence, not unit coverage. The repository declares a
shell lint floor and no Python coverage percentage gate. No unit-tested class
is changed by Step 5 or needs completion here, and it adds no unreferenced
top-level production symbol.

### Feature integrity for Step 5

The reviewed temporary pipeline returns before ordinary build and publication
stages, and the restored tree matches its pre-candidate tree. The retained
execution report records successful qualification. Round 2 changes the source
verification guard and its fixtures; the bundle's probe and expected-build
file used for this step are unchanged. The fixture correction was made and
validated, on Windows and natively, before round 3.
