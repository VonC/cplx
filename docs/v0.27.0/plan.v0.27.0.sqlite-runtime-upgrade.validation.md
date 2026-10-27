# v0.27.0 bundled SQLite implementation tracking and validation

No, it is not implemented.

Track the five steps in the [implementation plan](plan.v0.27.0.sqlite-runtime-upgrade.md).
Steps 1 to 4 are recorded below with their evidence; each later step gets its
own validation record. The item's code review has not run, so the umbrella
row stays pending until it completes.

## Step 1: Build SQLite as a cplx library tool

### Analysis of Step 1 implementation state

Yes. Step 1 has been fully implemented.

### What was implemented for Step 1

- [Library tool](../../src/install/env/sqlite/sqlite_install_functions.sh):
  189 lines; pinned source identity per version, source checks before
  extraction, sysroot `jimsh0` bootstrap, configure line, library checks after
  build and installation, post-install link checks.
- [Compile set](../../src/setups/pkgs/sqlite/sqlite_rhel_9.6_x86_64.txt),
  tool order in both property templates, and the `sqlite` block of
  `tools/senv.local.tpl`.
- [Complete payload removal](../../src/setups/env/bin/packages_management.sh):
  `remove_package` continues past `cpio:` notices.

Recorded validation on 2026-10-27, on the RHEL 9.8 build host:

- The archive SHA-256 and SHA3-256, the `sqlite3.c` SHA3-256 and the source id
  matched the pins before extraction.
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

### Feature integrity for Step 1

No existing tool changes its build. `remove_package` keeps its behavior for
payloads without notices; it now also removes the files listed after one.

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
- Application-style venvs, fresh and upgraded: exact identity, database and
  WAL checks passed, provider mapped inside the relocated tree.
- `CPLX-ELF` reported 26 failed rewrites in both this and the previous
  archive: 32-bit compiler start files, relocatable objects never loaded.

### Feature integrity for Step 4

The previous archive and Python package remain available for rollback. The
development environment's venv, built on 3.13.9, must be recreated on
3.13.15; that is the consequence of the promotion the user selected.
