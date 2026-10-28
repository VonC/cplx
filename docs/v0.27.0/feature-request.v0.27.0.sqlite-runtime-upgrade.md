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
standard-library `sqlite3` module on its RHEL 9.8 target server and in its
Debian 12 CI container image, without depending on the host's SQLite or its
patch cycle.

As the toolchain maintainer, I want every build to come from the pinned,
verified source with the expected source and configuration identity, rebuilt
Python to pick it up without stale reuse, and every stage to prove that the
loaded library has that expected identity.

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
  source id or compile options, the compiler string included, differ from the
  pinned expected build, and include a WAL smoke check.
- Python's sandbox in the packaged tools archive carries exactly one SQLite
  provider, the one `sqlite3` loads, and the relocated archive loads it on the
  consuming project's RHEL 9.8 target server and in its Debian 12 CI
  container image, from the python wrapper and from an application-style
  venv.

## Confirmed constraints for the SQLite build

These were settled with the user on 2026-10-26, from a source-backed
compatibility investigation of the exact Python 3.13.15 release archive:

- **Release**: SQLite 3.54.1, the newest stable release on that date, with the
  WAL-reset fix. CPython 3.13.15 requires 3.15.2 or later and states no upper
  bound; that absence is not proof of compatibility, which the CPython tests
  and the probes below supply. Prereleases, snapshots and the withdrawn 3.52.0
  are excluded. A later patch release is a reason to ask, not to switch: no
  automated watch exists, and moving to it is a new user decision with new
  pinned values, a new expected build and a new qualification in both
  environments, following the build how-to.
- **Source identity**: the archive's SHA-256 and SHA3-256, the `sqlite3.c`
  SHA3-256 and the `SQLITE_SOURCE_ID` are pinned per version and verified
  before extraction.
- **SONAME**: `--soname=legacy`, so the library keeps the `libsqlite3.so.0`
  name that `_sqlite3` and the closure floor rely on.
- **Options**: parity with the replaced provider is a floor: every listed
  feature stays (FTS3, FTS4, FTS5, RTREE, SESSION, DBSTAT, COLUMN_METADATA,
  FTS3_PARENTHESIS, UNLOCK_NOTIFY, SECURE_DELETE, `TEMP_STORE=1`,
  `THREADSAFE=1`), and `DISABLE_DIRSYNC` is absent. The release's newer
  default options may be present; the expected-build file pins each of them.
  Extension loading stays unavailable to Python, which is built without
  `--enable-loadable-sqlite-extensions`.
- **Toolchain**: built inside the sandbox with its compiler and `--sysroot`;
  no host package is installed or replaced.
- **Rollback**: the previous tools archive and the previous Python package
  stay available; no published coordinate is overwritten. Rollback restores
  the previous toolchain only, with SQLite 3.34.1 and its known race, and
  promises nothing about a database written under 3.54.1.

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
   file and its two links, the provider `sqlite3` loads; removing a
   distribution payload removes all of its files. The scope is Python's
   sandbox, not an inventory of every tool root.
5. **AC5 rebuild invalidation**: when the recorded header or library digest
   differs from the sandbox, or no record exists, Python's configured tree is
   retired and rebuilt; when the inputs cannot be read, the build stops with
   exit 26.
6. **AC6 probe**: the probe requires `--expected-sqlite`; a version, source id
   or option difference, the compiler string included, a second provider
   beside the expected one, a failed WAL writer or a lost row fails the
   structured outcome, whatever the exit status of a wrapper.
7. **AC7 CPython tests**: `test_sqlite3` and `test_dbm_sqlite3` run with zero
   failures and errors from the installed tree and from a relocated archive
   in both environments. The five skips are named: four big-memory tests that
   the CPython runner skips without a `-M` memory limit, and
   `test_uri_windows`, which requires Windows. A failure that matches an open
   upstream issue still fails unless the user waives it as a recorded
   exception.
8. **AC8 RHEL 9.8 target server**: the tools archive passes the closure gate;
   a fresh relocation and an upgrade over the archive the consuming project
   pins both pass the wrapper probe and an application-style venv check, a
   venv created before the upgrade included, with no loader path and no text
   file left outside the prefix.
9. **AC9 Debian 12 CI container image**: the same archive, fetched as a
   snapshot candidate with a verification bundle from an identified committed
   cplx revision, passes the wrapper probe, the CPython tests, the application
   venv check and a loader check of the interpreter processes. That check
   finds no library outside the prefix except the monitoring library the
   agent's loader configuration injects into every process, excluded and
   reported under the pipeline's existing rule; the exclusion never covers
   SQLite, Python or a library a toolchain ELF needs.
10. **AC10 documentation**: the wiki explains why the toolchain builds its own
    SQLite, how to build and verify it, and the reference values, and the
    existing SQLite how-to pages state the new prerequisite and probe input.
    It also states what the consuming application still decides: the limits
    of a rollback, `python -m sqlite3` through the toolchain wrapper as the
    inspection shell, and the attributed upstream report gh-160699.

## Debian acceptance environment for the SQLite candidate

The Debian 12 agent of the consuming project's pipeline runs the check. The
archive under test and the verification bundle are fetched by digest from a
snapshot repository; the probe and its expected-build file come from the
bundle, never from the archive under test. Publication stays off for the run,
and the temporary pipeline change is removed once the run is green.

The consuming project adopts the archive and the verification bundle as one
digest-pinned pair. The bundle comes from an identified committed cplx
revision, a documented tree-equivalent revision allowed, and the previous
release's bundle need not verify the new archive.

## Delivery boundary of the bundled SQLite

- This item establishes the runtime prerequisite only. The consuming project
  still qualifies its own filesystem locking, concurrent reads, writes and
  checkpoints, process-kill recovery, disk-full behavior, reclamation and
  durability. A version check or a WAL smoke check is not that proof.
- The item completes at the candidate qualified in both environments.
  Publishing the archive under a release coordinate and adopting it in the
  consuming project keep their own authorization gates, and use those
  qualified bytes, matched by digest; a rebuilt archive is a new candidate
  that needs its own qualification in both environments.
- The toolchain ships the SQLite library only, no `sqlite3` command; an
  operator inspects a database with `python -m sqlite3` through the
  toolchain's python wrapper, never with the host's `sqlite3` 3.34.1.
- The build keeps `THREADSAFE=1`; the open upstream report gh-160699 is
  documented as unverified for this runtime, not investigated here.
- The item returns to the umbrella integration branch through the normal
  topic return. Two how-to pages it updates were introduced on item 8's
  branch, so their part of the documentation follows item 8 there.

## Requirement clarifications

- The implementation preceded this requirement under an urgent request. The
  requirement, plan and validation plan record the settled decisions and
  their evidence. A specification review ran afterwards, over five rounds;
  the user decided its fifteen questions on 2026-10-27, and the table below
  records where each decision is integrated.
- Every claim is narrowed to the consuming project's two environments: its
  RHEL 9.8 target server and its Debian 12 CI container image. Other build
  targets keep their current behavior and are not claimed.
- The WAL smoke check proves the provider's basic WAL behavior under
  concurrent writers, not the consuming project's workload.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | A1: the two environments only; other hosts meeting the closure floor are expected to work but not claimed | User story, expected behavior, AC8, AC9 | A2 every Linux target cplx builds; A3 any host meeting the closure floor |
| Q02 | B1: every build comes from the pinned, verified source with the expected source and configuration identity; no byte identity, second build or source retention | User story | B2 byte-identical rebuilds; B3 a retained source copy |
| Q03 | C1: parity is a floor; newer release defaults may be present and are pinned; `DISABLE_DIRSYNC` absent | Confirmed constraints (options) | C2 the replaced provider's exact feature set |
| Q04 | D1: every reported option is compared, the compiler string included; a compiler change is a reviewed edit and a new qualification | Expected behavior, AC6 | D2 ignore the `COMPILER` line; D3 compare the parity options only |
| Q05 | E2: one provider in Python's sandbox, the one `sqlite3` loads; no archive-wide inventory | Expected behavior, AC4 | E1 one physical file across the archive; E3 one content identity across the archive |
| Q06 | F1: zero failures and errors; the five skips named; the Debian run covered by documented same-archive equivalence; an upstream failure needs a recorded waiver | AC7 | F2 any number of unnamed skips; F3 accept failures matching upstream issues |
| Q07 | G1: the Debian loader check excludes only the host-injected monitoring library, under the existing reported rule, never SQLite, Python or a toolchain dependency | AC9 | G2 run only where nothing is injected; G3 exclude any library but SQLite |
| Q08 | H1: the upgrade starts from the archive the consuming project pins, `tools.2026-09-18_220913.tar.gz`, SHA-256 `df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87`, qualified on 2026-10-28 | AC8 | H2 the last archive built; H3 every archive since item 6 |
| Q09 | I1: rollback restores the previous toolchain only and promises nothing about data written under 3.54.1 | Confirmed constraints (rollback), AC10 | I2 prove readability under 3.34.1; I3 no rollback after writes |
| Q10 | J1: archive and verification bundle adopted as one digest-pinned pair, the bundle from an identified revision | Debian acceptance environment, AC9 | J2 the previous bundle verifies the new archive; J3 the archive carries its own expectation; J4 a strict same-commit pair |
| Q11 | K1: no automated watch; a later release is a user decision with new pins, expected build and qualification | Confirmed constraints (release) | K2 a build-time upstream check; K3 a scheduled job |
| Q12 | L1: the item completes at the qualified candidate; publication and adoption use those bytes, matched by digest | Delivery boundary | L2 completion at publication; L3 completion at adoption |
| Q13 | M1: the library only; `python -m sqlite3` through the wrapper is the inspection shell | Delivery boundary, AC10 | M2 ship a `sqlite3` shell; M3 no guidance |
| Q14 | N1: a missing input record counts as changed and forces the rebuild; exit 26 kept | AC5 | N2 write the record and reuse the tree |
| Q15 | O1: a bounded, attributed note on gh-160699, applicability unverified; `THREADSAFE=1` kept | Delivery boundary, AC10 | O2 an applicability study; O3 no mention |

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
