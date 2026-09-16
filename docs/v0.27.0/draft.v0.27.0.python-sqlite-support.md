# Build the toolchain python with sqlite

- Type: feature-request
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Target version: v0.27.0
- Slug: python-sqlite-support

## Selected umbrella entry

| Order | Type | Key title | Slug | Status | Requirement | Validation plan |
| --- | --- | --- | --- | --- | --- | --- |
| 6 | Feature-request | Build the toolchain python with sqlite | `python-sqlite-support` | completed | `docs/v0.27.0/feature-request.v0.27.0.python-sqlite-support.md` | `docs/v0.27.0/plan.v0.27.0.python-sqlite-support.validation.md` |

Regroups work item 2 (Q24) and decision D7. Depends on umbrella items 4
(`toolchain-runtime-closure`) and 5 (`architecture-minor-fallback`). Both are
completed in the umbrella and their validation plans.

## Requirement detail inherited from item 6

The toolchain interpreter has no `_sqlite3`: the python sandbox list never
carried sqlite, so configure never saw `sqlite3.h` and the extension was never
compiled, which is why the consuming project's CI still runs its test walk
without coverage and with its coverage-importing suites guarded. D7 chose the
payload route, the same class as zlib and libffi, since the server carries only
the runtime library and no header, and RHEL 9's sqlite clears CPython's minimum
by a wide margin. The item adds `sqlite-libs` and `sqlite-devel` to the per-tool
list, makes detection explicit with `LIBSQLITE3_CFLAGS` and `LIBSQLITE3_LIBS`
in the configure call, next to the `LIBMPDEC_*` pair it mirrors, rather than
trusting pkg-config, whose shipped `sqlite3.pc` carries `prefix=/usr` and would
link the toolchain against the host library. Acceptance is the configure line
answering `yes` for the `_sqlite3` stdlib extension and `import sqlite3`
succeeding on the build account, on a Debian container after relocation and
on a RHEL target after deployment.

Sixth because it is the first item requiring a full interpreter recompile,
because the closure check defined in item 4 enforces `libsqlite3.so.0` as a
required member once its waiver is removed here, and because its package step
needs the architecture key of item 5 to resolve.

The umbrella's "already staged" package-list note records earlier preparation.
At this continuation, `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt`
already contains both SQLite packages in the clean integration tree. The
configure array in `src/install/env/python/python_install_functions.sh`
contains `LIBMPDEC_*` but no `LIBSQLITE3_*` settings. Keep the existing package
entries and complete the remaining integration.

## Environment and evidence for Q24

The archive is built on a RHEL 9.8 deployment server using sandbox RPM payloads
from the rolling CentOS 9 Stream mirrors. It must serve both RHEL 9.8 targets
(glibc 2.34 family) and Jenkins Debian 12 containers (glibc 2.36), with
relocation at installation time. The host identities and evidence boundaries
are recorded in [reference.environments.md](reference.environments.md).

The umbrella attributes Q24 to the consuming project's Jenkins discovery:
develop#7 failed with `ModuleNotFoundError: No module named '_sqlite3'`.
A search of the live build-account toolchain on 2026-08-08 also found no
`libsqlite3.so.0` under `tools/*/root`. These are two separate missing files:

- `_sqlite3.cpython-313-x86_64-linux-gnu.so` under Python's `lib-dynload`, the
  compiled extension produced by rebuilding CPython;
- `libsqlite3.so.0`, the runtime library that the extension loads.

Adding the library alone cannot create the extension. An existing extension
with a missing library would instead fail with
`ImportError: libsqlite3.so.0: cannot open shared object file`.

The original evidence comes from `../../my-project/docs/jenkins_build.md`,
as recorded by the umbrella. Historical observations above describe that
archive; they are not a new measurement of the live server during this draft.

## Work item 2: supply the sandbox payloads and build the extension

Relevant files:

- `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt`, the retained Python
  dependency list used through item 5's architecture resolution;
- `src/install/env/python/python_install_functions.sh`, the configure call;
- `src/setups/pkgs/packages_rhel_9.6_x86_64.txt`, the historical global index
  cited by the umbrella, already listing `sqlite-3.34.1-8.el9`,
  `sqlite-devel-3.34.1-8.el9` and `sqlite-libs-3.34.1-8.el9`.

### Build inputs and runtime payload are distinct

`sqlite-devel` supplies `sqlite3.h` and the `libsqlite3.so` linker symlink;
`sqlite-libs` supplies `libsqlite3.so.0` for runtime. The `sqlite` CLI is not
required for the stdlib module.

The build server was checked on 2026-08-07: `/usr/lib64` carried only
`libsqlite3.so.0` and its `.so.0.8.6` target, with no header, linker symlink or
`sqlite3.pc`. Its runtime copy cannot supply the missing development inputs.
The build also deliberately avoids host paths: `install_functions.sh` uses
`--sysroot=${root}` in `CFLAGS`, `-I${root}/usr/include` in `CPPFLAGS`, and
`-Wl,--sysroot=${root}` plus sandbox `-L` paths in `LDFLAGS`. This isolation
preserves the build model described in
[Why recompile](../../wiki/explanation/why-recompile.md).

### D7: extract the distribution payloads into the sandbox

cplx works without administrator rights and writes nothing outside
`~/cplx` on the server. The selected route adds the per-tool package names,
downloads their RPMs on Windows, transfers them through `setup.sh`, and uses
`packages_management.sh` to run `rpm2cpio | cpio -idmv` inside
`~/cplx/tools/python/root`. This is an unprivileged extraction, with no `dnf`
or system package installation. The mirror pass verifies sandbox resolution.
It is the existing route for zlib, libffi, ncurses, readline, gdbm, bz2, xz
and libuuid.

D7 considered two other routes:

- Copying host `/usr` files cannot provide the absent header and linker
  symlink, even though copying a runtime file served an earlier tools patch.
- Building SQLite from source remains possible if a newer SQLite or
  independence from the RHEL patch cycle is later needed. It would add a tool
  entry, `senv.local` settings, install functions, a tracked version and a
  build-order dependency. The `_`-prefixed built-package mechanism already
  exists, illustrated by the commented `# _mpdecimal` entry.

The umbrella selects the RPM route because RHEL 9's SQLite 3.34.1 with
backports clears CPython's SQLite 3.15.2 minimum and covers coverage and
pytest-testmon's needs. It records SQLite's runtime needs as libc, libm and
libz, already shipped. Every route would still have to ship `libsqlite3.so.0`
inside the archive and preserve sandbox and deployed-prefix resolution.

### Build and packaging steps inherited from Q24

1. Check the build-account state in a `senv` shell with
   `python3 -c 'import sqlite3'` and inspect
   `~/cplx/tools/python/root/usr/include/sqlite3.h` and
   `~/cplx/tools/python/root/usr/lib64/libsqlite3*`. The historical baseline
   was a missing module and absent sandbox files; retain fresh observations
   when implementation runs these checks.
2. Retain `sqlite-devel` and `sqlite-libs` in the Python list and rerun package
   setup so the sandbox contains the header, linker symlink and runtime
   library. The SQLite CLI remains optional. Use the completed architecture
   resolver for the detected RHEL 9.8 key and its generated index.
3. Make CPython detection explicit beside the existing `LIBMPDEC_*` pair:

   ```sh
   "LIBSQLITE3_CFLAGS=-I${root}/usr/include" \
   "LIBSQLITE3_LIBS=-L${root}/usr/lib64 -lsqlite3" \
   ```

   CPython 3.13 probes with
   `PKG_CHECK_MODULES([LIBSQLITE3], [sqlite3 >= 3.15.2])`; setting both
   variables bypasses that pkg-config probe. The umbrella warns that the
   shipped `sqlite3.pc` has `prefix=/usr`; using it without a sysroot can
   produce `-L/usr/lib64`. If that alternative is later chosen, it needs
   `PKG_CONFIG_SYSROOT_DIR=${root}`. Add
   `--enable-loadable-sqlite-extensions` only if the application needs
   loadable SQLite extensions; stdlib SQLite support does not require it.
4. Rebuild Python. The configure line
   `checking for stdlib extension module _sqlite3` must answer `yes`, and
   `_sqlite3` must be absent from the final necessary-bits-not-found summary.
5. Carry `libsqlite3.so.0` into the archive under
   `tools/python/root/usr/lib64`, together with the compiled extension.
   A build-sandbox-only library does not satisfy this requirement. Use the
   existing closure check to enforce its continued presence after packaging.

## Cross-requirement contract with item 4

[The runtime-closure requirement](issue.v0.27.0.toolchain-runtime-closure.md)
already declares `libsqlite3.so.0` on the required-member floor with a
`tools/python` location constraint. Its one named SQLite waiver is owned by
this item. Remove that waiver, retaining the floor entry, when:

> a file named `libsqlite3.so.0` is present under `tools/python` in the
> resolution scope.

This is the floor entry's own location test. The archive has one ordered
resolution scope composed by the installer across tool roots; a copy only
under `tools/git` does not satisfy the Python location constraint. Packaging
fails if the waiver remains after its removal condition is satisfied. The
condition depends on the payload, not on whether a document says this item
is completed.

## Acceptance and handoff boundary

The configure result must confirm `_sqlite3`, and
`python3 -c 'import sqlite3'` must succeed on the RHEL build account, in a
Debian 12 container after relocation, and on a RHEL target after deployment.
Both the compiled extension and its shipped runtime dependency are required;
success using a host SQLite library does not establish archive autonomy.
The closure floor and removal of the satisfied waiver preserve that contract.

Item 6 owns SQLite integration and its focused rebuild and acceptance evidence.
Item 7 (`tools-archive-rebuild`) owns the final sandbox refresh, Python patch
version decision under D5, archive rebuild, complete cross-distribution matrix
and release publication. It refuses release publication while any closure
waiver is active. This draft inherits the Python 3.13 line constraint; the
application pins `>=3.13, <3.14`, and moving to 3.14 belongs to a later cycle.

The consuming project's coverage gate and pytest-testmon can be restored after
it adopts the resulting tools archive: remove `--no-cov` and
`-p no:pytest-testmon`, while the degraded `conftest_coverage` import and Q24
skip guards self-enable once SQLite is available. Those pipeline changes and
the tools-version pin belong to the consuming repository and its release
handoff. Wrapper hardening, relocation, architecture fallback and the closure
checker remain the preceding items' responsibilities.
