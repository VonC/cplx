# How to check Python SQLite capability

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

Goal: prove that the toolchain Python answers `import sqlite3` with its
own compiled `_sqlite3` and the `libsqlite3.so.0` the archive ships, at
build time, after installation and after relocation, and know what a
failed check leaves in place.

Background: three things share the name. `sqlite-devel` (the header and
the `libsqlite3.so` linker symlink) is needed to compile the extension,
`sqlite-libs` (`libsqlite3.so.0`) to run it, and the CLI not at all. The
build never reads the server's `/usr` (it compiles with `--sysroot`), and
the archive never relies on a host copy: on another distribution that copy
is a foreign library ([One archive, two distributions](../explanation/one-archive-two-distributions.md)).

## Prerequisites

- The Python sandbox list carries `sqlite-libs` and `sqlite-devel`
  (`src/setups/pkgs/python/python_rhel_9.6_x86_64.txt`, which a 9.8
  server reaches through the minor fallback).
- The declared build family is `CPLX_ARCH_EXT=el9.x86_64`. The SQLite
  configure inputs and checks apply only there; other families build as
  before.

## 📋 Steps

1. Unpack the payloads into the Python sandbox:

   ```cmd
   st python
   sp
   ```

   Then, on the server, `ls ~/cplx/tools/python/root/usr/include/sqlite3.h
   ~/cplx/tools/python/root/usr/lib64/libsqlite3.so*` lists the header, the
   linker symlink and `libsqlite3.so.0`.

2. Rebuild. For an already populated tree use `irc` (configure, forced
   clean, build); for a new Python version, set it and run `i`
   ([Update a tool version](update-a-tool-version.md)). The configure call
   passes `LIBSQLITE3_CFLAGS=-I${root}/usr/include` and
   `LIBSQLITE3_LIBS=-L${root}/usr/lib64 -Wl,--enable-new-dtags -lsqlite3`
   instead of trusting pkg-config, whose `sqlite3.pc` says `prefix=/usr`.
   The new-dtags flag gives the extension a `DT_RUNPATH`, so after
   promotion the wrapper's library path selects the promoted copy rather
   than the build sandbox. In the build log, expect
   `checking for stdlib extension module _sqlite3... yes`.

3. Read the two automatic checks in the build log
   (`src\install\install.log` on Windows). Each runs the shared probe
   `sqlite_probe.py` and prints one JSON line:
   - `stage=build`, inside `build()` after compiling or reusing: the source
     tree's `python`, its generated extension directory and its own
     `libpython3.13.so`, preloaded for that one command;
   - `stage=installed`, in the [`post_install_check()` hook](../reference/tool-contract.md#optional-hooks):
     `python-<version>/bin/python3.13` and its `lib-dynload`, even when the
     install itself was skipped as up to date.

4. Package with `~/cplx/bin/pkg_tools.sh`. The closure declaration's floor
   `floor|libsqlite3.so.0|tools/python` refuses an archive whose Python
   root lacks the library.

5. After relocating the archive (on any host), run the operator check
   through the wrapper, with no library override of your own:

   ```bash
   P=<prefix>/tools/python
   mkdir -p <scratch>
   "$P/bin/python" -I -S -B <path>/sqlite_probe.py --stage operator \
       --expected-python-root "$P" \
       --expected-extension-root "$P/python-<version>/lib/python3.13/lib-dynload" \
       --expected-provider "$P/root/usr/lib64/libsqlite3.so.0" \
       --scratch-dir <scratch>
   ```

   The probe sits at `~/cplx/tools/python/sqlite_probe.py` on the build
   account, and at `src/install/env/python/sqlite_probe.py` in a
   [verification bundle](validate-a-change-on-a-foreign-ci-agent.md).

## ✅ Check

The quick test is `"$P/current/bin/python3" -c 'import sqlite3'`. The
probe goes further: it commits a row to a file-backed database, closes it,
reopens it and reads the row back, then reads `/proc/self/maps` once and
requires the loaded `libsqlite3` to be the expected file, by path and by
file identity, inside the expected Python root.

| Field | Meaning |
| --- | --- |
| `outcome` | `passed` (exit 0), `failed` or `inconclusive` (exit 2) |
| `extension` | where `_sqlite3` was imported from, and its backing file |
| `database` | `passed`, `failed` or `not-run` |
| `provider` | the mapped `libsqlite3` path and identity (and `libpython` at the build stage) |
| `error` | the first rule that refused |

`failed` means a rule was broken: the extension came from outside the
expected tree, the loaded provider is a host or another tool's copy, or
the row did not survive the reopen. `inconclusive` means the observation
could not be made (a path unavailable, no mapping seen, two identities for
one library) and is never read as a pass.

## What a failure leaves in place

- A failed build or installed check stops the run before `package()`, and
  the install prefix's `current` symlink is not advanced, so promotion
  keeps shipping the previous version. The new version directory is not
  rolled back and may hold a partial install: repair, then rebuild.
- A floor refusal at packaging writes no archive and removes what the gate
  staged. The live tree is untouched, since `pkg_tools.sh` packages a
  private stage.

## 👉 See also

- [Rebuild and publish the tools archive](rebuild-and-publish-the-tools-archive.md):
  SQLite acceptance repeated on the final archive.
- [Tool contract](../reference/tool-contract.md): the `post_install_check()`
  hook.
- [Runtime closure checker](../reference/toolchain-runtime-closure.md):
  the floor and its declaration.
