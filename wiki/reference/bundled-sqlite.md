# Bundled SQLite

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

The SQLite library the toolchain builds from source and ships inside the
Python tree. Why it exists:
[Why the toolchain builds its own SQLite](../explanation/why-the-toolchain-builds-its-own-sqlite.md).

## Selected release

| Field | Value |
| --- | --- |
| Version | 3.54.1 (2026-10-16) |
| Source | `https://sqlite.org/2026/sqlite-autoconf-3540100.tar.gz` |
| Local name | `src\setups\sources\sqlite\sqlite-src-3.54.1.tar.gz` |
| Size | 3332984 bytes |
| SHA-256 | `926ef8d3eab93fbf6e06011901273eec076b25594a4e1cdadd50c987f4f6d64e` |
| SHA3-256 | `b6ced585c750916b1052667239a12c25a7ff34e7f06e1e6e01ecb0427657d9c4` (the download page's value) |
| `sqlite3.c` SHA3-256 | `e2b869d3003b33c942b7dd7063604fbc53553e1b66609570df39b9b7b558ee81` (the change log's value) |
| `SQLITE_SOURCE_ID` | `2026-10-16 14:45:20 555e07ef33f69a0957d24d8e555b702464a131d6f1607f4c3c1e4551e8e6ca76` |

`sqlite_install_functions.sh` pins these values per version. Its
`verify_archive` hook checks all four on the exact archive the installer
selected, before anything is extracted from it; `configure` and `make` check
that archive and the extracted tree again, since a reused tree is not
re-extracted. A version without pinned values refuses to build.

## Tool registration

| Item | Value |
| --- | --- |
| Tool | `sqlite`, a library (`CPLX_BIN` empty), listed before `python` |
| `CPLX_CHECK_SRC` / `CPLX_CHECK_PREFIX` | `libsqlite3.so` / `usr/lib64/libsqlite3.so` |
| `CPLX_CONFIG_DONE` | `default` (`configure()` appends the marker line itself) |
| Sandbox list | `src\setups\pkgs\sqlite\sqlite_rhel_9.6_x86_64.txt` (9.8 by minor fallback): the el9 compile set |
| Consumer entry | `_sqlite` in `src\setups\pkgs\python\python_rhel_9.6_x86_64.txt`, replacing `sqlite-libs` and `sqlite-devel` |
| Package | `sqlite-3.54.1-<YYYYMMDD.HHMM>.el9.x86_64.tar.gz`, deployed to `tools/pkgs/` |

## Configure line

Run from the extracted source with the sandbox compiler
(`<root>` is the tool sandbox, `<prefix>` the install prefix):

```text
configure --prefix=<prefix>/usr --libdir=<prefix>/usr/lib64
    --soname=legacy --disable-static --disable-static-shell --disable-readline
    --enable-fts3 --enable-fts4 --enable-fts5 --enable-rtree --enable-session
    --enable-dbstat --enable-column-metadata --with-tempstore=no
    CC=<root>/usr/bin/gcc
    CFLAGS="<cplx CFLAGS> -DSQLITE_ENABLE_FTS3_PARENTHESIS
            -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_SECURE_DELETE"
    LDFLAGS="<cplx LDFLAGS> -Wl,--enable-new-dtags -lm"
```

| Choice | Reason |
| --- | --- |
| `jimsh0` built first with `<root>/usr/bin/gcc --sysroot=<root>` | `configure` bootstraps it with an unquoted compiler word that cannot carry `--sysroot`, and tries `./jimsh0` first |
| `--soname=legacy` | the default sets no SONAME; consumers need `libsqlite3.so.0` |
| `--disable-static-shell` | the CLI links the shared library instead of a second engine copy |
| `-lm` | the math SQL functions need `libm`, and `configure`'s probe misses it (gcc inlines `ceil`) |
| `-Wl,--enable-new-dtags` | a `DT_RUNPATH` the Python wrapper's library path overrides |
| no `DISABLE_DIRSYNC` | keeps the directory fsync after journal creation and deletion |

## Installed layout

The package holds, relative to its prefix, what Python's sandbox receives:

| Path | Kind |
| --- | --- |
| `usr/lib64/libsqlite3.so.3.54.1` | the one real library |
| `usr/lib64/libsqlite3.so.0`, `usr/lib64/libsqlite3.so` | links to it |
| `usr/include/sqlite3.h`, `usr/include/sqlite3ext.h` | headers for Python's `_sqlite3` |
| `usr/lib64/pkgconfig/sqlite3.pc` | not used by Python, which passes explicit flags |
| `usr/bin/sqlite3`, `usr/share/man/man1/sqlite3.1` | the CLI, linked to the library above |

Dynamic section of the library: `NEEDED` `libz.so.1`, `libm.so.6`,
`libc.so.6`; `SONAME` `libsqlite3.so.0`; a `RUNPATH`, no `RPATH`; no
symbol version above `GLIBC_2.34`.

## Checks in the build

| Where | Check | Refusal |
| --- | --- | --- |
| installer, `sqlite` `verify_archive` hook | on the selected archive, before extraction: its SHA-256 and SHA3-256, then the amalgamation SHA3-256 and header source id read from its members | exit 27, nothing extracted |
| `sqlite` `configure()` and `build()` | the selected archive's SHA-256 and SHA3-256 again, the extracted tree's amalgamation SHA3-256 and header source id | status 2 |
| `sqlite` `build()` and `post_install_check()` | SONAME, `libm.so.6` needed, no `DT_RPATH`, `GLIBC_2.34` ceiling | status 2 |
| `sqlite` `post_install_check()` | both links reach `libsqlite3.so.<version>`, no `libsqlite3.so.0.8.6`, installed header source id | status 2 |
| `python_setenv()` | the SQLite header and library a configured tree was built against (`sources/current/cplx-sqlite-inputs.txt`) | `config.log` retired, so the driver reconfigures, cleans and rebuilds; fatal 26 if the inputs are missing |
| Python probe, every stage | version, source id and exact compile options of the loaded library against `sqlite_expected.txt`; no second `libsqlite3.so*` file beside the provider; multi-process WAL with `synchronous=FULL`, checkpoint and reopen | `failed`, exit 2 |

## Compile options

`PRAGMA compile_options` of the selected build, as pinned in
`src/install/env/python/sqlite_expected.txt`:

```text
ATOMIC_INTRINSICS=1
COMPILER=gcc-11.5.0 20240719 (Red Hat 11.5.0-15)
DEFAULT_AUTOVACUUM
DEFAULT_CACHE_SIZE=-2000
DEFAULT_FILE_FORMAT=4
DEFAULT_JOURNAL_SIZE_LIMIT=-1
DEFAULT_MMAP_SIZE=0
DEFAULT_PAGE_SIZE=4096
DEFAULT_PCACHE_INITSZ=20
DEFAULT_RECURSIVE_TRIGGERS
DEFAULT_SECTOR_SIZE=4096
DEFAULT_SYNCHRONOUS=2
DEFAULT_WAL_AUTOCHECKPOINT=1000
DEFAULT_WAL_SYNCHRONOUS=2
DEFAULT_WORKER_THREADS=0
DIRECT_OVERFLOW_READ
ENABLE_COLUMN_METADATA
ENABLE_DBSTAT_VTAB
ENABLE_FTS3
ENABLE_FTS3_PARENTHESIS
ENABLE_FTS4
ENABLE_FTS5
ENABLE_MATH_FUNCTIONS
ENABLE_PERCENTILE
ENABLE_PREUPDATE_HOOK
ENABLE_RTREE
ENABLE_SESSION
ENABLE_UNLOCK_NOTIFY
MALLOC_SOFT_LIMIT=1024
MAX_ATTACHED=10
MAX_COLUMN=2000
MAX_COMPOUND_SELECT=500
MAX_DEFAULT_PAGE_SIZE=8192
MAX_EXPR_DEPTH=1000
MAX_FUNCTION_ARG=1000
MAX_LENGTH=1000000000
MAX_LIKE_PATTERN_LENGTH=50000
MAX_MMAP_SIZE=0x7fff0000
MAX_PAGE_COUNT=0xfffffffe
MAX_PAGE_SIZE=65536
MAX_SCHEMA=10000000
MAX_SQL_LENGTH=1000000000
MAX_TRIGGER_DEPTH=1000
MAX_VARIABLE_NUMBER=32766
MAX_VDBE_OP=250000000
MAX_WORKER_THREADS=8
MUTEX_PTHREADS
SECURE_DELETE
SYSTEM_MALLOC
TEMP_STORE=1
THREADSAFE=1
```

Compared with the replaced RHEL 3.34.1 list: `DISABLE_DIRSYNC` is
deliberately absent; `ENABLE_JSON1` and `HAVE_ISNAN` no longer appear
because current releases build JSON in and no longer report that probe.

## Expected-build file format

`sqlite_expected.txt`, read by `sqlite_probe.py --expected-sqlite`:

| Line | Meaning |
| --- | --- |
| `version=<x.y.z>` | exactly once: `sqlite3.sqlite_version` |
| `source_id=<id>` | exactly once: `SELECT sqlite_source_id()` |
| `compile_option=<option>` | once per option, at least one: the whole `PRAGMA compile_options` set |
| `#...` or blank | ignored |

Any other line, a repeated key or option, or surrounding whitespace in a
value refuses the file.

## 👉 See also

- [Build and verify the bundled SQLite](../how-to/build-and-verify-the-bundled-sqlite.md)
- [Check Python SQLite capability](../how-to/check-python-sqlite-capability.md)
- [Tool contract](tool-contract.md)
