# Why the toolchain builds its own SQLite

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

Python's `sqlite3` module is a thin layer: the database engine is the
`libsqlite3.so.0` the interpreter loads at run time. For a long time the
distribution's copy was good enough, and two package names in Python's
dependency list brought it into the sandbox
([Where a sandbox file comes from](where-a-sandbox-file-comes-from.md),
route 1). This page explains why that stopped being true, and why each
choice in the replacement build is the way it is.

## The version the distribution cannot give

RHEL 9 ships SQLite 3.34.1. Every SQLite from 3.7.0 through 3.51.2 carries
a rare database corruption race in write-ahead logging, the *WAL-reset*
bug: two connections on the same file, in different threads or processes,
with a write or a checkpoint at the same instant. It was fixed in 3.51.3
and later, with backports to 3.50.7 and 3.44.6 only.

A distribution package can carry a backport under its old version number,
so the version alone proves nothing either way. What settles it is
evidence of the fix, and none exists for the 3.34.1 packages. An
application that keeps its state in SQLite with WAL and several processes
is exactly the workload the bug needs, so the archive has to ship a
release that contains the fix.

That moves SQLite from route 1 to route 3: the distribution's version is
too old for the software we actually want, so the library becomes a cplx
tool of its own, `sqlite`, consumed by Python as `_sqlite`
([The build order](the-build-order.md)).

## Choosing the release

The selected release is the newest stable one at the time of the choice,
not the fix floor: 3.51.3 is where the bug ends, not where the fixes end.
Prereleases and development snapshots are never candidates.

The exact Python source sets the only hard bound. CPython 3.13 requires
SQLite 3.15.2 or later and states no maximum, which is the absence of a
stated limit, not a proof that every release is safe. That is why the
selection is followed by the Python test suite and the probe on the real
build, rather than trusted on paper.

## What the build keeps from the distribution

The replacement must look like the library it replaces from Python's side:

- **The SONAME.** Python's `_sqlite3` and the archive's closure gate both
  name `libsqlite3.so.0`. SQLite's current build system sets no SONAME at
  all unless asked, so the build passes `--soname=legacy`.
- **The features.** The RHEL build enables FTS3/4/5, R-Tree, sessions with
  the pre-update hook, `dbstat`, column metadata, unlock notification,
  secure delete and file-backed temporary tables. The replacement keeps
  every one of them, and serialized thread safety (`THREADSAFE=1`, DB-API
  level 3).
- **The dependencies.** The library needs `libm`, `libz` and `libc`, as
  the RHEL one does.

## What it deliberately does not keep

RHEL compiles with `DISABLE_DIRSYNC`: SQLite then skips the fsync of the
directory after it creates or deletes a journal file. That saves a system
call and can lose a journal's directory entry on power loss. The bundled
build leaves the option out and keeps SQLite's default, because the reason
for shipping a new SQLite at all is durability.

## Why the expected build is pinned

A version string is not enough to know what was loaded: two builds of
3.54.1 can differ in every option. The library itself can say what it is,
through `sqlite_version()`, `sqlite_source_id()` and
`PRAGMA compile_options`, and the checkout pins those three answers in
`src/install/env/python/sqlite_expected.txt`. The Python probe asks the
loaded library and refuses anything else, at build time, after
installation, and after relocation on any host.

The pin is a reviewed file, not an observation of the archive under test:
a wrong library shipped together with a matching wrong expectation would
otherwise certify itself. It even names the compiler, so a change of the
sandbox gcc shows up as a deliberate edit.

## Why the old provider has to leave, not just be shadowed

Unpacking the new library over Python's sandbox is not enough. The RPM
payload left a real `libsqlite3.so.0.8.6` behind, and SQLite's own
`make install` even rewrites a file of that name into a link when it finds
one. A second real library in the shipped tree is a second provider that
another loader search, or a later relink, could select. So the RPMs are
removed from Python's list, their payloads are removed from the sandbox,
and the probe refuses any second `libsqlite3.so*` file beside the provider.

Removing them from the list also closes the refresh path: a later `sp`
cannot unpack the 3.34.1 payload again, and the mirroring pass never copies
host files over a cplx-built package.

## Why the link carries a run path, not an rpath

Like every cplx build, the library records the build home's library
directories. As a `DT_RPATH` they would outrank the wrapper's library path
and could resolve `libz` from the SQLite tool's own sandbox instead of the
Python tree. The library is linked with new dtags, so it records a
`DT_RUNPATH` that the wrapper's path overrides, the same correction the
`_sqlite3` extension already needed
([Why binaries remember the build home](why-binaries-remember-the-build-home.md)).

## What this does not prove

A passing probe and a WAL smoke test establish the runtime prerequisite:
the right engine is loaded, it commits, checkpoints and reopens under
concurrent writers. They do not qualify an application's own locking,
crash recovery, disk-full behavior or durability; the consuming
application still owns those tests.

## What the consuming application still decides

**Rollback.** Going back to the previous tools archive restores the
previous toolchain only, with its SQLite 3.34.1, the WAL-reset race and
the older feature set. It promises nothing about a database written under
3.54.1: many stay readable by 3.34.1, but one whose schema uses a newer
feature, such as a `STRICT` table, may not. Whether its data must stay
compatible with the older release is the application's decision.

**Inspecting a database.** The toolchain ships the library, not the
`sqlite3` command. `python -m sqlite3 <file>`, run through the toolchain's
python wrapper, opens a shell on the bundled 3.54.1. The host's `sqlite3`
on RHEL 9 is 3.34.1, with the WAL-reset race: never write with it to a live
database beside the application. The Python shell permits writes as well,
so it is no read-only or concurrency guarantee either.

**Upstream reports.** The build keeps `THREADSAFE=1`, so Python reports
`sqlite3.threadsafety` 3. An open CPython issue, gh-160699, reports a crash
when several threads execute on one shared connection. It describes
CPython 3.15.1 with SQLite 3.53.4, confirmed on CPython 3.14.9 with
SQLite 3.53.1, both on Windows 11; whether it applies to CPython 3.13.15
on Linux with SQLite 3.54.1 is unverified. The default
`check_same_thread=True` refuses that sharing, and the reporters avoid it
with one connection per thread.

## 👉 Where to look next

- [Build and verify the bundled SQLite](../how-to/build-and-verify-the-bundled-sqlite.md):
  the steps.
- [Check Python SQLite capability](../how-to/check-python-sqlite-capability.md):
  the probe at each stage.
- [Bundled SQLite](../reference/bundled-sqlite.md): the selected release,
  its digests, configure line and compile options.
