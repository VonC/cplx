# Build the bundled SQLite from source

- Type: feature-request
- Test group: whole suite
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Target version: v0.27.0
- Slug: sqlite-runtime-upgrade

## Selected umbrella entry

| Order | Type | Key title | Slug | Status | Requirement | Validation plan |
| --- | --- | --- | --- | --- | --- | --- |
| 9 | Feature-request | Build the bundled SQLite from source | `sqlite-runtime-upgrade` | pending | - | - |

Regroups decision D12, which supersedes the payload route of D7, and the
probe extension that proves its result. Depends on umbrella items 4
(`toolchain-runtime-closure`), 6 (`python-sqlite-support`) and 7
(`tools-archive-rebuild`), all completed. It does not depend on item 8
(`deploy-venv-sync`).

This child was written in place on the existing `sqlite-runtime-upgrade`
branch, which already held the implementation; no `new_draft` branch was
created.

## Requirement detail inherited from item 9

Item 6 gave the toolchain python a `_sqlite3` linked against the
distribution's `sqlite-libs` payload, SQLite 3.34.1 on el9. That release
predates the WAL-reset corruption fix SQLite documents on its WAL page, and
updating the host package would not reach it: the toolchain loads its own
copy under the prefix. Once a consuming project selected the standard-library
`sqlite3` module for persistent storage, the bundled provider had to change.

The item builds the newest stable upstream release, 3.54.1, as the cplx
library tool `sqlite`: the third of the three ways to fill a sandbox gap, which
D7 kept for "a newer sqlite". Python consumes it through a `_sqlite` line in its
package list, in place of the two distribution payloads. The rules the work
settled:

- The source archive is checked before extraction against four pinned
  values: its SHA-256 and SHA3-256, the amalgamation's SHA3-256 and the source
  id. A version with no pinned values is refused.
- `--soname=legacy` keeps `libsqlite3.so.0` as the SONAME that item 4's
  closure floor and the `DT_NEEDED` of `_sqlite3` name; the autoconf build
  sets none by default.
- The compile options keep parity with the replaced provider and leave out
  `DISABLE_DIRSYNC`. The 51 options the built library reports are pinned in
  an expected-build file next to the probe.
- The library carries `DT_RUNPATH`, never `DT_RPATH`, links `libm`
  explicitly and needs no `GLIBC_` node above 2.34.
- A changed SQLite header or library retires Python's configured tree, so
  `_sqlite3` never keeps the previous headers through build reuse.
- A removed distribution payload is removed completely, so no stale
  `libsqlite3.so.0.8.6` survives in the sandbox to be packaged.
- The probe compares the loaded version, source id and compile options with
  the expected-build file, refuses a second real `libsqlite3.so*` beside the
  provider, and runs a WAL smoke check on a disposable database: three writer
  processes at `synchronous=FULL`, passive then truncating checkpoints, a
  reopen and an integrity check.

## Decision inherited from the umbrella

| # | Decision | Options | Leaning |
| --- | --- | --- | --- |
| D12 | SQLite release the toolchain python links | (a) keep D7 (b), the distribution's `sqlite-libs` payload, 3.34.1 on el9; (b) build the newest stable upstream release from source as the cplx library tool `sqlite`, D7 (c) | decided: (b) with **3.54.1**, on 2026-10-26. The build keeps the replaced provider's compile options, keeps `libsqlite3.so.0` through `--soname=legacy`, and leaves out `DISABLE_DIRSYNC`. A later patch release is a reason to ask, not to switch silently |

## Order and process

The row is ninth because it arrived after the split, not because it needs
item 8. The implementation came first, under an urgent request; its
requirement, plan and validation plan were written afterwards, and no
specification review ran. The candidate archive passed on the Debian 12 agent
on 2026-10-27; the item stays pending until its code review completes.

## Acceptance inherited from item 9

On RHEL 9.8 and on the Debian 12 agent, the relocated archive's wrapper and an
application-style venv load the bundled 3.54.1, with identity, WAL smoke and
mapped-provider checks passing; CPython's `test_sqlite3` and
`test_dbm_sqlite3` pass from the shipped tree; nothing loads from outside the
prefix; and an upgrade over the previous archive leaves one provider. The
consuming project's own locking, crash-recovery, disk-full and durability
qualification stays outside this item.
