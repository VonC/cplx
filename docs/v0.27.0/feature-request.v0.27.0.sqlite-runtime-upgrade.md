# Build the bundled SQLite from source

- Type: feature-request
- Version: v0.27.0
- Topic: sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Test group: whole suite

## User story for the bundled SQLite

As the maintainer of a project that runs on the cplx toolchain python, I want
that python to load a current, identified SQLite build that carries the
WAL-reset corruption fix, so that the project can keep persistent data in the
standard-library `sqlite3` module on every supported target without depending
on the host's SQLite or its patch cycle.

As the toolchain maintainer, I want the build to be reproducible from verified
source, rebuilt Python to pick it up without stale reuse, and every stage to
prove that the loaded library is that exact build.

## Current SQLite provider entering item 9

Item 6 delivered `_sqlite3` by unpacking the distribution's `sqlite-libs` and
`sqlite-devel` payloads into Python's sandbox (D7 (b)):

- The provider is SQLite 3.34.1 from the el9 package, shipped as
  `tools/python/root/usr/lib64/libsqlite3.so.0.8.6` with its
  `libsqlite3.so.0` link, and floored by item 4's closure declaration.
- Its compile options are the distribution's, including `DISABLE_DIRSYNC`:
  SQLite then skips the directory sync after creating or deleting a journal.
- SQLite's WAL page documents a WAL-reset corruption race present from 3.7.0
  through 3.51.2, fixed in 3.51.3 and backported to 3.50.7 and 3.44.6. No
  backport was evidenced for the el9 3.34.1 package, and a vendor version
  number cannot prove one.
- Updating the host package would not change the provider: the toolchain
  python loads its own copy under the prefix, on RHEL as on the Debian agent,
  whose system SQLite the toolchain never uses.

A consuming project has since selected the standard-library `sqlite3` module
for persistent storage, so the bundled provider must change before that
project adopts it.

## Expected behavior of the bundled SQLite

- cplx builds SQLite as a library tool named `sqlite`, through the standard
  tool flow, from the newest stable upstream release selected by D12: 3.54.1.
- Python lists `_sqlite` in its package list and receives the deployed
  `sqlite` package in its sandbox; the two distribution payloads are gone from
  the list and from the sandbox.
- A change to the SQLite header or library in Python's sandbox forces a clean
  reconfiguration and rebuild of Python.
- The build, installed and operator probes reject any SQLite whose version,
  source id or compile options differ from the pinned expected build, and
  include a WAL smoke check.
- The packaged tools archive carries exactly one SQLite provider, and the
  relocated archive loads it on RHEL 9.8 and on the Debian 12 agent, from the
  python wrapper and from an application-style venv.

## Confirmed constraints for the SQLite build

These were settled with the user on 2026-10-26, from a source-backed
compatibility investigation of the exact Python 3.13.15 release archive:

- **Release**: SQLite 3.54.1, the newest stable release on that date, with the
  WAL-reset fix. CPython 3.13.15 requires 3.15.2 or later and states no upper
  bound; that absence is not proof of compatibility, which the CPython tests
  and the probes below supply. Prereleases, snapshots and the withdrawn 3.52.0
  are excluded. A later patch release is a reason to ask, not to switch.
- **Source identity**: the archive's SHA-256 and SHA3-256, the `sqlite3.c`
  SHA3-256 and the `SQLITE_SOURCE_ID` are pinned per version and verified
  before extraction.
- **SONAME**: `--soname=legacy`, so the library keeps the `libsqlite3.so.0`
  name that `_sqlite3` and the closure floor rely on.
- **Options**: parity with the replaced provider (FTS3, FTS4, FTS5, RTREE,
  SESSION, DBSTAT, COLUMN_METADATA, FTS3_PARENTHESIS, UNLOCK_NOTIFY,
  SECURE_DELETE, `TEMP_STORE=1`, `THREADSAFE=1`), without
  `DISABLE_DIRSYNC`. Extension loading stays unavailable to Python, which is
  built without `--enable-loadable-sqlite-extensions`.
- **Toolchain**: built inside the sandbox with its compiler and `--sysroot`;
  no host package is installed or replaced.
- **Rollback**: the previous tools archive and the previous Python package
  stay available; no published coordinate is overwritten.

## Acceptance criteria for the bundled SQLite

1. **AC1 source identity**: the `sqlite` build refuses an archive whose four
   pinned values differ, and refuses a version that has no pinned values. It
   checks the exact archive the installer selected before extracting
   anything from it, and checks a reused extracted tree again before
   configure and make.
2. **AC2 library shape**: the built and the installed library have SONAME
   `libsqlite3.so.0`, need `libm.so.6`, carry `DT_RUNPATH` and no `DT_RPATH`,
   and need no `GLIBC_` node above 2.34. Both links reach
   `libsqlite3.so.3.54.1`; no `libsqlite3.so.0.8.6` remains.
3. **AC3 compile options**: the expected-build file lists the 51 options the
   library reports; the parity options are present and `DISABLE_DIRSYNC` is
   absent.
4. **AC4 single provider**: Python's sandbox holds one real `libsqlite3.so*`
   file and its two links; removing a distribution payload removes all of its
   files.
5. **AC5 rebuild invalidation**: when the recorded header or library digest
   differs from the sandbox, Python's configured tree is retired and rebuilt;
   when the inputs cannot be read, the build stops with exit 26.
6. **AC6 probe**: the probe requires `--expected-sqlite`; a version, source id
   or option difference, a second provider beside the expected one, a failed
   WAL writer or a lost row fails the structured outcome, whatever the exit
   status of a wrapper.
7. **AC7 CPython tests**: `test_sqlite3` and `test_dbm_sqlite3` pass from the
   installed tree and from a relocated archive.
8. **AC8 RHEL archive**: the tools archive passes the closure gate; a fresh
   relocation and an upgrade over the previous archive both pass the wrapper
   probe and an application-style venv check, with no loader path and no text
   file left outside the prefix.
9. **AC9 Debian agent**: the same archive, fetched as a snapshot candidate with
   a verification bundle from a committed cplx revision, passes the wrapper
   probe, the CPython tests, a loader check that initializes nothing outside
   the prefix, and the application venv check on the Debian 12 agent.
10. **AC10 documentation**: the wiki explains why the toolchain builds its own
    SQLite, how to build and verify it, and the reference values, and the
    existing SQLite how-to pages state the new prerequisite and probe input.

## Debian acceptance environment for the SQLite candidate

The Debian 12 agent of the consuming project's pipeline runs the check. The
archive under test and the verification bundle are fetched by digest from a
snapshot repository; the probe and its expected-build file come from the
bundle, never from the archive under test. Publication stays off for the run,
and the temporary pipeline change is removed once the run is green.

## Delivery boundary of the bundled SQLite

- This item establishes the runtime prerequisite only. The consuming project
  still qualifies its own filesystem locking, concurrent reads, writes and
  checkpoints, process-kill recovery, disk-full behavior, reclamation and
  durability. A version check or a WAL smoke check is not that proof.
- Publishing the archive under a release coordinate and adopting it in the
  consuming project keep their own authorization gates.
- The item returns to the umbrella integration branch through the normal
  topic return. Two how-to pages it updates were introduced on item 8's
  branch, so their part of the documentation follows item 8 there.

## Requirement clarifications

- The implementation preceded this requirement under an urgent request. The
  requirement, plan and validation plan record the settled decisions and
  their evidence; no specification review ran.
- The WAL smoke check proves the provider's basic WAL behavior under
  concurrent writers, not the consuming project's workload.

## Code and evidence references for the bundled SQLite

- `src/install/env/sqlite/sqlite_install_functions.sh`: source checks,
  configure line, library checks.
- `src/setups/pkgs/sqlite/sqlite_rhel_9.6_x86_64.txt`: the compile set.
- `src/setups/env/bin/packages_management.sh`: complete payload removal.
- `src/install/env/python/python_install_functions.sh`: SQLite input stamp
  and reconfiguration.
- `src/install/env/python/sqlite_probe.py` and
  `src/install/env/python/sqlite_expected.txt`: the probe and its expected
  build.
- `tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py`.
- `docs/v0.27.0/verify.python-sqlite-build.sh`,
  `docs/v0.27.0/acceptance.python-sqlite-support.sh` and
  `docs/v0.27.0/verify.python-sqlite-acceptance.sh`.
- `wiki/explanation/why-the-toolchain-builds-its-own-sqlite.md`,
  `wiki/how-to/build-and-verify-the-bundled-sqlite.md` and
  `wiki/reference/bundled-sqlite.md`.
- [Implementation plan](plan.v0.27.0.sqlite-runtime-upgrade.md) and
  [validation plan](plan.v0.27.0.sqlite-runtime-upgrade.validation.md).
