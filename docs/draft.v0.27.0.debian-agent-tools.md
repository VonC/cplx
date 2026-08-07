# Draft: a tools set compatible with the Jenkins Debian agent and the RHEL 9.8 target

- Type: collection (feature-requests and issues)
- Draft role: umbrella

Source of every finding referenced here:
`../my-project/docs/jenkins_build.md` (the PDFS Jenkins build discovery,
builds develop#2 through develop#19 on 2026-08-06 and 2026-08-07) and
the cplx sources named per item. The Qn identifiers below are the open questions of that
document; this draft turns its "durable fix, in cplx" notes into one
work list for the next tools archive.

## Why one tools archive must now serve two distributions

The tools archive (Python 3.13.9, git, patchelf, `pkg.sh`,
`install_pkg.sh`, published by hand as `PDF-9.13.4-tools.tar.gz`) was
built on and for RHEL. The next archive lives in a three-machine chain:

- the build account, on a RHEL 9.8 deployment server, where cplx
  compiles against sandbox RPMs pulled from the CentOS 9 Stream
  mirrors (the list files are named `rhel_9.6`, the mirrors behind
  them roll forward); build and deployment now share the same OS;
- the deployment targets: RHEL 9.8 servers (kernel
  `5.14.0-687.24.1.el9_8`, glibc 2.34 family), where everything works
  today and must keep working unchanged;
- the CI agent: throwaway Docker containers on Jenkins, Debian 12
  (bookworm) userland, glibc 2.36, where the discovery pipeline
  relocates the archive to run tests, package and publish.

One asymmetry worth recording, visible in any `ldd` on the RHEL
servers: they inject `/lib64/liboneagentproc.so` (the monitoring
agent) into every process through the system preload, the CI container
does not. The RHEL side is therefore the less isolated of the two, and
a host-built library lands inside the relocated toolchain's processes
there. It works today and constrains how far the shipped glibc may
drift from the servers'.

RHEL 9 minors share the glibc 2.34 base but backport symbols under
newer version tags (develop#14: the current RHEL `libgcc_s` demands the
`GLIBC_2.35` node, which the 9.13.4 archive's libc never defined).
With build and deployment now on the same 9.8, the remaining drift is
between the rolled stream RPM set and the archive itself; the rule
stays coherence: the shipped root must be one snapshot in which every
version node a shipped library demands is defined by the shipped libc.

The relocation contract itself holds on the foreign distribution: after
the `install_pkg.sh` patchelf pass (interpreter and rpath re-anchored,
404 values), the toolchain git 2.52.0 and the python ELF
`python3.13_bin` run fine on Debian. Every failure met by the discovery
sits in the margins of that contract: wrapper scripts calling host
coreutils, a python built without a module the tests need, library
resolution falling back on the host cache, and one host tool
(`rsync`) assumed present. Fixing those margins in cplx makes the
archive distribution-agnostic without touching the build model
(native RHEL build, relocation at install time).

## Defect inventory from the discovery runs

| Q | Defect | Evidence | Interim in the pipeline |
| --- | --- | --- | --- |
| Q20 | The python wrapper exports `LD_LIBRARY_PATH` then calls host `readlink`/`mv`/`ln`, which bind the shipped RHEL libc and die on `GLIBC_PRIVATE` | develop#3, wrapper line 60 mangled exec target | uv drives the `python3*_bin` ELF directly via `UV_PYTHON` |
| Q24 | The toolchain python has no `_sqlite3`: the sandbox never held `sqlite-devel`, so the extension was never compiled (and no `libsqlite3` ships either) | develop#7 `ModuleNotFoundError: _sqlite3`, develop#19 root listing | walk runs `--no-cov -p no:pytest-testmon`, coverage gate suspended, coverage-importing suites skipif-guarded |
| Q26 | The shipped root misses `libgcc_s`, and the wheels' own rpath hides the root (the four glibc stubs and libstdc++ ship but stay unreachable), so manylinux extensions resolve Debian's copies against the RHEL libc | develop#10 pymupdf, develop#12 ld.so assertion, develop#13 `GLIBC_2.36` via libstdc++, develop#15 pikepdf grafted libjpeg | `--replace-needed` onto `libc.so.6` plus a `--force-rpath` append of the root on every venv wheel; publish gated on a green walk |
| Q19 | `install_pkg.sh` hard-requires `rsync`, absent from the agent image | develop#2 exit 5 at the mirror phase | rsync stand-in shim written by the pipeline |

## Agent baseline measured by the develop#19 probes

develop#19 (2026-08-07) is the first fully green build-test-publish run
on the agent: 5883 tests passed (29 skipped, 9 xfailed), the walk took
1m26s against the 20-minute budget, and the snapshot published. Every
remaining defect is carried by the pipeline interims, which this
rebuild removes. The run also shipped the two ABI probes, whose
measured baseline feeds the work items:

- Debian 12 agent identity: libc6 `2.36-9+deb12u10`, libgcc-s1 and
  libstdc++6 `12.2.0-14+deb12u1`, libsqlite3-0 `3.40.1`, zlib1g
  `1.2.13`; host ceilings `GLIBC_2.36` (libc) and `GLIBC_2.35`
  (libgcc_s).
- The contract probe flags 72 ELFs, in three classes. First, lone root
  libraries resolving libc host-side: partly the known root-object
  simulation artifact, but also a sign the relocation rpath pass does
  not cover every shipped library (work item 3); the same listing
  proves the four glibc stubs and `libstdc++` ship in the root, while
  `libgcc_s` and `libsqlite3` do not. Second, every C++ and
  rust wheel (watchfiles, greenlet, numpy, pymupdf, pydantic_core)
  resolves root libc through the appended rpath (the append works) but
  takes Debian's `libgcc_s`, whose `GLIBC_2.35` reference the archive
  libc cannot satisfy: harmless at runtime today, and exactly what the
  closure removes. Third, one real archive fact: the root ships
  OpenSSL `3.5.1`, whose libssl demands `OPENSSL_3.x` version nodes
  only its sibling libcrypto serves, and the root accumulates package
  generations (two libbfd builds side by side).

## Work item 1 (Q20): harden the python wrapper against foreign coreutils

Files: `src/install/env/python/bin/python` (the wrapper deployed as
`tools/python/bin/python`, reached through the
`tools/python/current/bin/python3` symlink) and
`src/install/env/python/bin/setenv` (line 15 exports `LD_LIBRARY_PATH`
toward `root/usr/lib64` and the shipped library directories).

Mechanism: the wrapper sources `setenv` at line 18, then performs its
first-run surgery (lines 30 to 56: `readlink` on the `python3` symlink,
`mv` of the real binary to `<name>_bin`, `ln` of the wrapper in its
place) and its venv post-processing (lines 65 to 89: `readlink`, `ln`,
`cp`, `sed`, `grep`). With `LD_LIBRARY_PATH` already exported, every
one of those host binaries loads the shipped RHEL libc. On RHEL host
tools and shipped libraries are ABI-compatible, so nothing shows; on
Debian they die on `undefined symbol: _dl_readonly_area, version
GLIBC_PRIVATE`, `readlink` answers empty, and the wrapper computes a
mangled exec target.

Fix direction (keeps `setenv` unchanged for interactive operators):

- in the wrapper, right after sourcing `setenv`, save then unset
  `LD_LIBRARY_PATH`;
- run all helper commands (both the first-run surgery and the venv
  post-processing) without it;
- restore it only on the final interpreter call (lines 59 to 63), where
  the patched ELF needs the shipped libraries for itself and for the
  wheel extensions it will dlopen (see work item 3).

Alternatives, kept for the record: `env -u LD_LIBRARY_PATH <cmd>` on
each helper call, or bash builtins where they exist. The save/unset/
restore form touches one place instead of every call site, which is why
it is preferred.

Acceptance for this item: on a Debian 12 container, a fresh relocation
followed by `tools/python/current/bin/python3 --version` answers the
toolchain version through the wrapper, first call included (the
first-run surgery is the code path that died). Behavior on the RHEL
build account and targets is unchanged.

## Work item 2 (Q24): build the toolchain python with sqlite

Files: `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt` (the python
sandbox package list: no sqlite entry today, which is why configure
never saw the headers) and
`src/install/env/python/python_install_functions.sh` (the configure
call).

### Why the server's own libsqlite3 does not help

Three separate things carry the same name, and only the first two
matter here:

- `sqlite3.h` plus the `libsqlite3.so` linker symlink (RPM
  `sqlite-devel`): needed at build time. Without the header, CPython's
  configure marks the module missing and the build simply skips it.
- `libsqlite3.so.0` (RPM `sqlite-libs`): needed at run time by the
  compiled `_sqlite3` extension.
- the sqlite CLI (RPM `sqlite`): not needed at all.

The RHEL 9.8 build server does carry `/usr/lib64/libsqlite3.so.0`, as
the `find` shows, but that is the runtime file only, and the build
cannot use host paths anyway: `install_functions.sh` compiles with
`--sysroot=${root}` in `CFLAGS`, `-I${root}/usr/include` in `CPPFLAGS`,
and `-Wl,--sysroot=${root}` plus explicit `-L${root}/...` in `LDFLAGS`,
so every header and library comes from the tool's sandbox root, never
from `/usr`. That isolation is the whole point of the build model
([Why recompile](../wiki/explanation/why-recompile.md)): a toolchain
linked against the host would drag host versions into the archive.

What is needed is those two payloads unpacked inside the python
sandbox root. Both packages already sit in the global RHEL 9.6 list
(`src/setups/pkgs/packages_rhel_9.6_x86_64.txt` lines 4873 to 4875:
`sqlite-3.34.1-8.el9`, `sqlite-devel-3.34.1-8.el9`,
`sqlite-libs-3.34.1-8.el9`), only the per-tool python list misses them.

### Three ways to fill a sandbox gap, and which one fits sqlite (D7)

cplx never installs anything on the server: no admin rights, no
package touched, nothing outside `~/cplx`. A library reaches a tool's
sandbox in one of three ways, and all three respect that rule.

1. **Copy the file from the server's `/usr`** into
   `tools/<tool>/root/usr`. Cheapest when the server already has what
   is needed, and the pattern the `tools-patch` archive used to serve
   `libstdc++` to the CI agent. It cannot serve this build: a compile
   needs `sqlite3.h` and the `libsqlite3.so` linker symlink, and the
   server carries neither (only `libsqlite3.so.0` and its
   `.so.0.8.6` target). There is nothing to copy.
2. **Extract the package payload into the sandbox**, the existing cplx
   machinery and the one this item uses: a name in the per-tool list,
   the Windows side downloads the RPM from the CentOS 9 Stream
   mirrors, `setup.sh` ships it to the server, and
   `packages_management.sh` runs `rpm2cpio | cpio -idmv` from inside
   `~/cplx/tools/python/root`. It is an unprivileged unpack of the
   payload, not an installation: no `dnf`, no root, no system file
   written, and the tool's mirror pass then verifies that nothing
   resolves outside the sandbox. This is how zlib, libffi, ncurses,
   readline, gdbm, bz2, xz and libuuid already got there.
3. **Rebuild the library from source** as a cplx tool, for what the
   distribution cannot provide acceptably: openssl 3.5 against RHEL's
   3.0 branch, mpdecimal for CPython 3.13, git, python itself.

sqlite belongs to the second class today. RHEL 9's 3.34.1 with its
backports clears CPython's 3.15.2 floor by a wide margin and covers
everything coverage and pytest-testmon need, so nothing forces a
source build, while that route would add a tool entry, its
`senv.local` block, its install functions, a version to track, and a
build-order dependency ahead of python, on the critical path of a
rebuild whose purpose is to unblock CI. The door stays open: the
per-tool lists already accept `_`-prefixed built packages (the
commented `# _mpdecimal` entry) and `packages_management.sh`
recognizes a built package by its timestamped name.

Autonomy does not discriminate between the routes: it comes from
shipping `libsqlite3.so.0` inside the archive root, which all three
require, and neither the build (sysroot) nor the deployed tree (own
root plus rpath) ever reads the server's copy. Either way sqlite stays
a leaf: its only needs are libc, libm and libz, all three already in
the shipped root, so the closure gains exactly one file.

### Why the running python cannot gain sqlite without a rebuild

`_sqlite3` is a compiled extension
(`_sqlite3.cpython-313-x86_64-linux-gnu.so` under `lib-dynload`), not a
pure-python module: having the shared library present cannot conjure
it. The pipeline error is `ModuleNotFoundError: No module named
'_sqlite3'`, which says the extension file does not exist; a built
extension whose library was missing would instead fail at dlopen with
`ImportError: libsqlite3.so.0: cannot open shared object file`. Only a
rebuild produces the file, and the develop#19 root listing confirms
both gaps: neither `libsqlite3` nor any `_sqlite3` extension ships
today.

### Steps

1. Discriminating check on the build account, in a senv shell:
   `python3 -c 'import sqlite3'`, and
   `ls ~/cplx/tools/python/root/usr/include/sqlite3.h
   ~/cplx/tools/python/root/usr/lib64/libsqlite3*`. Expected before the
   fix: `ModuleNotFoundError` and no such files, which confirms the
   sandbox never had sqlite (rather than a lost library at runtime).
2. Add `sqlite-devel` and `sqlite-libs` to the python sandbox package
   list (the CLI `sqlite` is optional) and re-run the package setup, so
   the sandbox root gains `usr/include/sqlite3.h`, the
   `libsqlite3.so` symlink and `libsqlite3.so.0`. The deployment
   server itself carries only `libsqlite3.so.0` and its
   `.so.0.8.6` target (checked on the build account, 2026-08-07): no
   header, no linker symlink, no `sqlite3.pc`, so `sqlite-devel` is
   genuinely absent there and nothing local could have served the
   build even without the sysroot isolation.
3. Make the detection explicit rather than hoping for auto-detection.
   CPython 3.13 resolves sqlite through
   `PKG_CHECK_MODULES([LIBSQLITE3], [sqlite3 >= 3.15.2])`, and
   pre-setting both variables skips the pkg-config probe entirely, so
   add to the `configure` array of
   `python_install_functions.sh`, next to the existing `LIBMPDEC_*`
   pair it mirrors:

   ```sh
   "LIBSQLITE3_CFLAGS=-I${root}/usr/include" \
   "LIBSQLITE3_LIBS=-L${root}/usr/lib64 -lsqlite3" \
   ```

   Add `--enable-loadable-sqlite-extensions` only if the application
   ever needs loadable sqlite extensions; the stdlib module does not.
   The pkg-config route is the trap to avoid: the shipped `sqlite3.pc`
   carries `prefix=/usr`, so pkg-config would answer `-L/usr/lib64`
   and link the toolchain against the host library (add
   `PKG_CONFIG_SYSROOT_DIR=${root}` if that route is ever preferred).
4. Rebuild python and read the configure output: the line
   `checking for stdlib extension module _sqlite3` must answer `yes`,
   not `missing`, and `_sqlite3` must be absent from the
   necessary-bits-not-found summary at the end of the build.
5. Make sure `libsqlite3.so.0` ships inside the archive root
   (`tools/python/root/usr/lib64`), not only in the build sandbox: on
   RHEL the deployed tree could still borrow the host copy from
   `/usr/lib64` and hide the gap, while Debian's multiarch layout
   never would. This belongs to the runtime closure of work item 3.

Acceptance for this item: `python3 -c 'import sqlite3'` passes on the
build account, on a Debian 12 container after relocation, and on the
RHEL target after deployment. Downstream this restores the PDFS
coverage gate and pytest-testmon (their interims are listed in the
cleanup section).

## Work item 3 (Q26): ship the runtime closure and make it resolvable

Since glibc 2.34, `libpthread`, `libdl`, `librt` and `libutil` are
merged into libc, and the distribution ships tiny compat stubs for
binaries that still declare them. manylinux wheel extensions declare
those stubs as `DT_NEEDED` (pymupdf, develop#10), and their C++ ones
need `libstdc++.so.6` with its `libgcc_s.so.1` companion (pymupdf's
`_extra`, develop#13). Whatever the loader cannot resolve from the
shipped root it fetches from the host `ld.so.cache`: on Debian that
mixes glibc 2.36 objects into the RHEL 2.34 process and dies
(`GLIBC_ABI_DT_RELR`, `GLIBC_2.36 not found`). RHEL targets never see
it: their cache serves compatible copies.

Three sub-tasks:

1. Ship the runtime closure in `tools/python/root/usr/lib64`. The
   develop#19 root listing settles who is already there: the four
   stubs (`libpthread.so.0`, `libdl.so.2`, `librt.so.1`,
   `libutil.so.1`) and `libstdc++.so.6.0.29` ship; `libgcc_s.so.1` and
   `libsqlite3.so.0` do not. `libgcc` is already in the python sandbox
   list, so its library is dropped somewhere between RPM extraction
   and packaging: find that spot rather than copying the file in by
   hand; `libsqlite3` arrives with the work item 2 list entries. Add a
   packaging-time closure check listing the required members so a
   future drop cannot ship silently.
2. Keep the snapshot coherent (the develop#14 lesson): the published
   9.13.4 libc lacks the `GLIBC_2.35` version node that the current
   RHEL `libgcc_s` demands, while the live build-account root has it:
   the archive had diverged from the tree it was packaged from. At
   rebuild time, refresh the sandbox RPMs (the stream mirrors roll),
   build against that one set, and check that every version node
   demanded by a shipped library is defined by the shipped libc. The
   rule covers whole library families, not only glibc: ship consistent
   pairs (develop#19: the root's libssl `3.5.1` demands `OPENSSL_3.x`
   nodes only its sibling libcrypto serves), and prune superseded
   generations at packaging (the 9.13.4 root carries two libbfd
   builds).
3. Make the root resolvable for dlopen'd wheels: D3 is settled by
   evidence. auditwheel writes classic `DT_RPATH` into wheel extensions
   precisely because RPATH propagates down the loading chain
   (develop#15: pikepdf's bundled libqpdf finds its grafted libjpeg
   only under RPATH semantics; a converted `DT_RUNPATH` broke it). The
   relocation pass of `install_pkg.sh` (line 316, `--set-rpath`) must
   therefore add `--force-rpath`: with `DT_RPATH` on the python ELF,
   the loader consults it for every object of the process, wheels
   included, and the CI per-wheel append loop becomes unnecessary.
   Extend the pass to every shipped library, not only the executables:
   the develop#19 probe saw lone root libraries fall back on the host
   cache, and a library-wide rpath makes the contract probe exact.

Acceptance for this item: on a Debian 12 container, `uv sync` then
`python -c 'import pymupdf, pikepdf'` in the project venv succeeds with
no patchelf pass on any wheel (pikepdf exercises the grafted-library
chain), and the ABI probe of the validation matrix reports no missing
version node and no host fallback on an ABI-critical library; on RHEL,
deployments behave as before.

## Work item 5: the architecture key follows the server minor

Correction, 2026-08-07. An earlier version of this draft dismissed the
`rhel_9.6` naming of the package lists as cosmetic, on the grounds that
the mirrors behind them roll with CentOS 9 Stream. That was wrong, and
it blocks the rebuild.

`setup.sh` recomputes the architecture from the server on every
connection step (`source /etc/os-release; printf "%s_%s_%s" $ID
$VERSION_ID $(uname -m)`) and writes it back into the properties, so on
the 9.8 build account the key is `rhel_9.8_x86_64`. Every
distribution-specific artifact is named after it, with no fallback:
`setup_packages.sh` builds the per-tool list name as
`${CPLX_TOOL}_${architecture}.txt` and fatals 902 when the file is
missing, the package index is `packages_<arch>.txt`, and the mirror URLs
live under an `<arch>_pkgs_url` property. The repository carried
`centos_8`, `rhel_7.9` and `rhel_9.6` variants only, so the next package
run would have failed before reading the sqlite lines added for the
python build.

Two halves, both needed:

1. **Unblock now**, by giving the current key its file set: copy the
   python and git dependency lists to `rhel_9.8_x86_64` names, add the
   `rhel_9_8_x86_64_pkgs_url` property (same rolling 9-stream mirrors),
   and regenerate the index with `sdpl`. Done on 2026-08-07 in this
   cycle, since the rebuild cannot proceed without it.
2. **Stop the churn**, by teaching cplx to fall back on the closest
   minor of the same major when no file matches the exact key, saying
   so in its output. The exact key stays authoritative when a file
   exists, so a genuinely divergent distribution can still have its
   own list, and a server upgraded from 9.8 to 9.9 stops needing a copy
   pass. This is requirement 5 of the collection; once it lands the
   duplicated `rhel_9.8` copies can be deleted in favour of one file
   per major.

The mechanism, the recovery and the inventory of everything the key
names are documented in the wiki
([The architecture key](../wiki/explanation/the-architecture-key.md),
[Survive a server OS upgrade](../wiki/how-to/survive-a-server-os-upgrade.md),
[Package list formats](../wiki/reference/package-list-formats.md)).

## Work item 4 (Q19): give install_pkg.sh a fallback without rsync

File: `src/setups/env/bin/install_pkg.sh`, two call sites:

- line 454, mirror mode: `rsync -av --delete "$SOURCE_PATH/"
  "$DEST_PATH/"`;
- line 469, root files (`.env`, `.env_`): `rsync -av "$root_file"
  "$INSTALL_PREFIX/"`.

The pipeline's shim (plain recursive copy, options ignored) is exact
only because CI installs into a fresh empty prefix. The in-script
fallback must keep the real semantics for RHEL redeployments into an
existing prefix:

- mirror mode fallback: when `rsync` is absent, empty the destination
  (`rm -rf` of its content, not of the directory) then `cp -a` the
  source content; that reproduces `--delete` for the whole-tree case
  this script actually uses;
- root file fallback: plain `cp -a`.

Detect `rsync` once (`command -v`), log which engine runs, and prefer
rsync whenever present so the build account path stays byte-identical.
This item removes the shim from the PDFS pipeline; asking the CICD
team to add rsync and procps to the agent image remains a parallel
track and does not block this draft.

## Rebuild, validation and publication of the new archive

Build sequence, on the RHEL 9.8 build account (a deployment server):

1. Land work items 1 to 4 in cplx, refresh the sandbox RPMs, then
   rebuild python (item 2 forces the rebuild; the stream mirrors having
   rolled since 9.13.4, the refresh also enforces the coherence rule of
   work item 3). Git does not need a rebuild. Raise the interpreter in
   the same pass (D5, version note below): one line,
   `CPLX_VERSION`, since `CPLX_URL` already carries the `[version]`
   placeholder. Pin it explicitly rather than leaving it unset, or the
   `python_repository` tag lookup now resolves to 3.14.x, which the
   consuming project forbids (`requires-python = ">=3.13, <3.14"`,
   `uv.lock` on `==3.13.*`).

### Which 3.13.x to build (D5)

Checked on 2026-08-07. The toolchain sits on 3.13.9 (14 Oct 2025); the
line has since reached 3.13.15 (5 Aug 2026), through .10, .11, .12,
.13 and .14. Maintenance releases carry no new features by CPython
policy, so the whole gain is roughly 1400 bugfixes plus the security
set of 3.13.11 (CVE-2025-12084, a `http.client` denial of service and
a `http.server` virtual-memory denial of service).

- **Never 3.13.10**: 3.13.11 was expedited three days later to repair
  three regressions it introduced, among them segmentation faults and
  assertion failures in `insertdict` and exceptions in
  `multiprocessing` while a running program is upgraded.
- **3.13.14 (10 Jun 2026) is the pick, decided**: two months of field
  exposure, against a 3.13.15 that is days old. The .10 episode is the
  precedent, a maintenance release that shipped segmentation faults and
  needed an emergency successor. Re-check 3.13.15 shortly before the
  rebuild starts: if no regression report has appeared by then, take it
  instead, since it adds roughly 400 further bugfixes.
- Timing argues for taking the bump now: 3.13 leaves its bugfix phase
  around October 2026 (two years after release, then security-only
  until the October 2029 end of life), so a rebuild landing late in
  that window captures nearly the whole bugfix stream the line will
  ever get.

No official package would provide any of this, on either machine.

On the RHEL 9.8 servers the platform interpreter is Python 3.9 and
stays 3.9 for the whole life of RHEL 9: the build account answers
`Python 3.9.25`, and `/usr` carries `bin/python3.9`, `lib/python3.9`,
`lib64/python3.9` and `include/python3.9`, nothing else (checked
2026-08-07). Newer interpreters exist for RHEL 9 only as optional
application streams an administrator would have to install alongside
that one: 3.11, 3.12, and 3.14 added in 9.8. Red Hat skipped 3.13
entirely, as it had skipped 3.10, so no RHEL package will ever carry
the line this project requires; EPEL 9 has 3.13 but community-
maintained; and installing any stream needs root, which the build
account does not have. On the Debian 12 agent the ceiling is 3.11.2,
Debian's 3.13 starting only with Debian 13.

Compiling therefore stays the only way to hold a chosen 3.13 patch
level on both machines. The full matrix, with a checkable source per
row, is in
[Python versions by distribution](../wiki/reference/python-versions-by-distribution.md).

### Looking past 3.13: what 3.14 would bring (D8)

The consuming project pins `requires-python = ">=3.13, <3.14"` today,
but that pin exists to keep one line under test, not to forbid 3.14
forever, so the question deserves an answer rather than a dismissal.
Upstream 3.14 is at 3.14.7 (5 Aug 2026), stays in its bugfix phase
until about October 2027 and dies in October 2030, a full year of
maintenance beyond 3.13 on both counts. Red Hat's feature summary is
[What's new in Python 3.14](https://developers.redhat.com/articles/2026/07/11/whats-new-in-python-3-14).

Matched against what the application actually uses, three items stand
out and the rest is noise:

- **deferred annotation evaluation (PEP 649/749)** is the best fit:
  annotations stop being evaluated at definition time, which trims
  import cost in a code base whose modules are overwhelmingly typed
  and which carries `from __future__ import annotations` almost
  everywhere. That boilerplate becomes removable.
- **asyncio introspection** targets exactly the failure class the
  project already instruments by hand: it registers a faulthandler on
  SIGUSR1 to dump threads, and its brownout work measures how long the
  service takes to stop and recover. Being able to inspect a live
  event loop complements both.
- **free-threading, now officially supported (PEP 779)** is the one
  with real upside and real cost, detailed below.

The remaining novelties (template strings, `compression.zstd`,
`uuid6/7/8`, subinterpreters through `concurrent.interpreters`) do not
map onto anything the application does today; subinterpreters would be
an alternative to its shared-memory and detached-process job isolation,
which is a redesign rather than an upgrade.

#### What "free-threading is gated" actually means

Three distinct gates, and the first one has largely opened since the
question was last looked at.

1. **The wheels.** A free-threaded interpreter carries its own ABI, so
   every compiled dependency needs a wheel tagged `cp314t` instead of
   `cp314`. Checked on 2026-08-07, the two PDF engines now publish
   them: pymupdf 1.28.2 (6 Aug 2026) and pikepdf 10.11.0 (31 Jul 2026),
   both `manylinux_2_28` x86_64, which the toolchain's glibc 2.34
   satisfies; cryptography, pydantic-core, psutil, uvloop, httptools
   and numpy publish free-threaded releases too. This gate is
   essentially open, which was not true a year ago.
2. **The silent revert.** An extension module that does not declare the
   `Py_mod_gil` slot makes the interpreter re-enable the GIL when that
   module is imported, with a warning. A single lagging dependency
   therefore restores serialized execution while everything still looks
   healthy, so the state has to be asserted at runtime with
   `sys._is_gil_enabled()` rather than assumed. Forcing `PYTHON_GIL=0`
   suppresses the safety net instead of fixing the cause.
3. **The application's own thread safety.** Removing the GIL removes
   the incidental atomicity it lent to check-then-act sequences. The
   consuming project mixes `threading` primitives with the event loop
   in five modules, so those need an audit and the suite needs a run
   under the free-threaded build to surface races the GIL was hiding.
   This is the real cost, and it belongs to the application, not to
   cplx.

For cplx the consequence is narrower: free-threaded and classic builds
cannot share an installation, so supporting it means building and
shipping a *second* interpreter, not changing the existing one. Red
Hat placing its own free-threaded package in a separate repository
(CodeReady Linux Builder) does not constrain us, since the interpreter
is compiled here anyway; it only shows that distributions still treat
that build as a specialty item. The consuming project keeps the full
analysis in its own wiki
(`docs/wiki/explanation/why-python-3-13-and-what-3-14-would-bring.md`).

The strategic argument is stronger than the feature list. Python 3.14
is the only line RHEL 9 offers that could ever *replace* a compiled
interpreter: its application stream is supported through May 2029,
while 3.13 will never exist as a RHEL package. Moving the application
to 3.14 is therefore the only path that could one day retire the
Python build from cplx altogether, leaving only git. That path still
requires an administrator to install the stream, and it does not help
the Debian agent at all, so it changes nothing for this rebuild.

Decision D8: stay on 3.13 for this cycle, since the archive must match
the pin the application enforces today, and revisit 3.14 at the next
cycle, when 3.13 leaves its bugfix phase (around October 2026) and the
free-threaded wheel situation is clearer.
2. Refresh the live tree and package with `pkg_tools`
   (`src/setups/env/bin/pkg_tools.sh`, front end of `pkg.sh tools`),
   producing `~/pkgs/tools.<stamp>.tar.gz` with `.env`, `.env_` and the
   relocation scripts included.

Validation matrix, before any publication:

| Check | Debian 12 container | RHEL 9.8 (build account or deployment target) |
| --- | --- | --- |
| `install_pkg.sh` relocation, no shim | required | required (redeploy over an existing prefix) |
| Wrapper `python3 --version`, first call | required | required |
| `import ssl, zlib, sqlite3` | required | required |
| Toolchain `git --version` | required | required |
| Version-node coherence: every demand of a shipped library defined by the shipped libc | required | required |
| `uv sync` then `import pymupdf, pikepdf`, no wheel patching | required | required |
| ABI probe: shipped loader `--list` over toolchain ELFs and venv wheels, no `not found`, no host-resolved ABI-critical library | required | not applicable (host copies are compatible) |
| `pytest` with coverage and testmon active | required | optional (Windows dev flow covers it) |
| `deploy_pkgs.sh` end to end with readiness checks | not applicable | required |
| Operator flow (`senv`, `.env` sourcing) | not applicable | required |

The Debian side can run in any plain `debian:12` container holding the
archive and nothing else; the discovery pipeline itself is the final
integration test once the archive is published.

Publication: the tools archive is hand-published to the corporate Nexus
`releases` repository (hosted, no overwrite) via my-project's
`tools/publish_pdf_nexus.sh --with-tools`, under
`com/company/PDF/<version>` with the `tools` classifier. A new pinned
version is therefore mandatory (9.13.4 cannot be rebuilt). Which Maven
version hosts it is decision D1.

The pin travels in the my-project repo, not in a Jenkins job parameter
(none is configurable there): `tools/tools.version` holds the one
version line and the Jenkinsfile reads it at pipeline start. Packaging
stays version-less on purpose: the Maven coordinate is a publication
concern, so `pkg_tools` keeps the same timestamp naming as `pkg_pdfs`
(the installer discovery and the pipeline fetch only need the
`tools.*.tar.gz` shape), and the version appears exactly twice:

1. `publish_pdf_nexus.sh --with-tools --version <version>` publishes
   the newest local tools archive under the Maven coordinate;
2. raising `tools/tools.version` in my-project is the single recorded
   edit that flips the pipeline to the new archive (the sha1 printed at
   publication maps a local archive back to its Nexus version whenever
   traceability is needed).

## Cleanups unlocked in my-project once the archive lands

Tracked on the my-project side (its Jenkinsfile and docs carry the
markers), listed here so the effort has a definition of done:

- raise `tools/tools.version` to the new pinned version (the pipeline
  reads the pin from that file, there is no Jenkinsfile constant);
- delete every `Q26 INTERIM, REMOVE` block (the venv patchelf loop with
  its `--force-rpath` append, the dormant tools-patch fetch, and their
  probes); the build-test-publish stage order stays untouched: it is
  the permanent gate since the 2026-08-06 redesign, not an interim;
- restore the coverage gate: drop `--no-cov` and
  `-p no:pytest-testmon` from the walk (the degraded
  `conftest_coverage` import and the Q24 skipif-guarded suites
  self-enable once sqlite exists);
- drop the rsync shim from the relocate stage (work item 4 replaces
  it);
- flip the walk-stage ABI contract probe from informative to blocking:
  with the closure shipped and the library-wide rpath, the expected
  flag count is zero (develop#19 baseline: 72 informative flags);
- optionally retire the `python3*_bin` bypass and `UV_PYTHON` aiming at
  the raw ELF, if the hardened wrapper proves usable by uv; keeping the
  ELF path is also acceptable, the bypass is then a convention rather
  than a workaround.

## Out of scope for this tools set

- Q17, a one-line `requirements.txt` pinning uv: a my-project file,
  not a cplx one.
- The ubi9 (RHEL-flavored) agent image: rejected in the discovery
  record; this draft is the counter-bet, making the archive
  distribution-agnostic instead.
- Agent image additions (rsync, procps, corporate CA in the image JVM):
  CICD-team track, useful but not blocking once items 1 to 4 land.
Nothing about the architecture key: that turned out to be in scope, see
the correction below.

## Decisions to take before or during this effort

| # | Decision | Options | Leaning |
| --- | --- | --- | --- |
| D1 | Maven version hosting the new tools archive | (a) the next application release version, published at release time; (b) a dedicated intermediate version so CI switches without waiting for a release | decided: (a); the archive rides the next application release, so CI keeps the 9.13.4 archive and its interims until that release publishes |
| D2 | Wrapper strategy for `LD_LIBRARY_PATH` | (a) save/unset around helpers, restore on the exec; (b) `env -u` per call site; (c) builtins where possible | (a) |
| D3 | Stub resolution for dlopen'd wheels | (a) `patchelf --force-rpath` in the relocation pass; (b) keep `DT_RUNPATH` plus explicit `LD_LIBRARY_PATH` in CI and in the wrapper exec | resolved: (a); develop#15 proved wheels and their grafted libraries need RPATH semantics; RHEL harmlessness is checked by the validation matrix |
| D4 | How install_pkg.sh stops needing the host rsync | (a) in-script cp fallback; (b) ship the rsync payload in the archive like patchelf; (c) both; (d) wait for the agent image | decided: (a). It leaves the installer needing only POSIX tools, while (b) would drag rsync's libpopt, libzstd, liblz4 and libcrypto onto a foreign distribution, the failure class of Q26. Compiling rsync in cplx is impossible here: a cplx-built binary carries a `/home/<builder>` interpreter and rsync must run before the pass that repairs it. Asking the CICD team for rsync stays a parallel, non-blocking track |
| D5 | Batch a Python 3.13.x refresh with the sqlite rebuild | (a) yes, one rebuild serves both; (b) no, minimal change | decided: (a) on **3.13.14**, never 3.13.10; re-check 3.13.15 for regression reports just before the rebuild and take it if clean |
| D8 | When to consider Python 3.14 | (a) now, widening the application pin; (b) next cycle; (c) never, stay on 3.13 to its end of life | (b): 3.13 must serve this rebuild (the application pins it), but 3.14 gains a year of maintenance, fits the annotation-heavy code through PEP 649, and is the only line RHEL 9 could ever provide as a package |
| D7 | sqlite provenance for the python build | (a) copy from the server's `/usr`; (b) `sqlite-devel` and `sqlite-libs` payloads extracted into the python sandbox from the per-tool list; (c) sqlite rebuilt from source as a cplx tool | (b): (a) is impossible (the server has no header and no linker symlink), (b) is one list line in the same class as zlib and libffi, (c) only for a newer sqlite or independence from the RHEL patch cycle |
| D6 | cplx release carrying this effort | (a) fold into the current 0.26.0 cycle; (b) dedicated next cycle | (b): v0.26.0 shipped on 2026-08-06, this effort opens the v0.27.0 cycle |
| D9 | Architecture key across server minors | (a) copy the file set at every minor upgrade; (b) key on the major only; (c) exact match first, then the closest minor of the same major, logged | decided: (a) now to unblock the rebuild, then (c) as requirement 5. (b) is rejected: it would lose the ability to describe a distribution whose minor really diverges |

## List of feature-requests and issues to create

| Order | Type | Key title | Slug | Status | Requirement | Validation plan |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Issue | Install without the host rsync | `rsync-cp-fallback` | pending | - | - |
| 2 | Issue | Relocate with RPATH so wheels resolve inside the prefix | `relocation-force-rpath` | pending | - | - |
| 3 | Issue | Keep the python wrapper working on a foreign distribution | `python-wrapper-foreign-distro` | pending | - | - |
| 4 | Issue | Ship a complete runtime closure in the archive | `toolchain-runtime-closure` | pending | - | - |
| 5 | Feature-request | Resolve the architecture key across server minors | `architecture-minor-fallback` | pending | - | - |
| 6 | Feature-request | Build the toolchain python with sqlite | `python-sqlite-support` | pending | - | - |
| 7 | Feature-request | Rebuild, validate and publish the tools archive | `tools-archive-rebuild` | pending | - | - |

### Requirement details for the umbrella

#### 1. Install without the host rsync

Type: Issue. Slug: `rsync-cp-fallback`. Regroups work item 4 (Q19) and
decision D4.

`install_pkg.sh` calls `rsync` at two sites, the mirror-mode sync of
the staging tree and the copy of each archive root file, and dies with
exit 5 where the binary is absent, which is the case on the CI agent
image. The fix detects `rsync` once, keeps using it when present so the
build account path stays byte-identical, and otherwise falls back to a
`cp` mirror that preserves the `--delete` semantics for redeployments
over an existing prefix (empty the destination content, then `cp -a`),
with a plain `cp -a` for root files. It must log which engine ran.

First because it is the most independent change in the collection: one
file, no rebuild, no packaging, verifiable against the existing
published archive, and it retires a workaround that currently lives in
the consuming project's pipeline. D4 also rejected shipping an rsync
binary in the archive, so nothing here depends on the packaging items.

Depends on: nothing.

#### 2. Relocate with RPATH so wheels resolve inside the prefix

Type: Issue. Slug: `relocation-force-rpath`. Regroups sub-task 3 of work
item 3 (Q26) and decision D3.

The relocation pass sets `--set-rpath`, which writes `DT_RUNPATH` on a
modern ELF. A runpath applies only to the direct needs of the object
carrying it, so it never reaches a library that a wheel extension
dlopens, nor the libraries auditwheel grafts inside a wheel: this cost
pikepdf its bundled libjpeg when the CI interim converted the wheel's
own `DT_RPATH`. Passing `--force-rpath` restores RPATH semantics, which
propagate down the whole loading chain, and the pass must cover every
shipped library rather than executables alone, since the develop#19
probe caught lone root libraries falling back on the host cache.

Second because it is the other change confined to `install_pkg.sh`,
needs no rebuild either, and can be proved against the current archive
by re-running the relocation and reading `readelf -d`. Landing it
before the packaging and build items means the definitive rebuild is
validated with the final relocation semantics already in place.

Depends on: nothing (adjacent to item 1 only because both edit the same
file).

#### 3. Keep the python wrapper working on a foreign distribution

Type: Issue. Slug: `python-wrapper-foreign-distro`. Regroups work item 1
(Q20) and decision D2.

`src/install/env/python/bin/python` sources `setenv`, which exports
`LD_LIBRARY_PATH` toward the shipped RHEL libraries, and then calls
host `readlink`, `mv`, `ln`, `cp`, `sed` and `grep` for its first-run
surgery and its venv post-processing. On RHEL the host tools and the
shipped libraries are ABI-compatible so nothing shows; on Debian they
die on `undefined symbol: _dl_readonly_area, version GLIBC_PRIVATE`,
`readlink` returns empty and the wrapper computes a mangled exec
target. D2 chose to save and unset `LD_LIBRARY_PATH` right after
sourcing `setenv`, run every helper without it, and restore it only for
the final interpreter call, which needs the shipped libraries for
itself and for the extensions it will dlopen. `setenv` stays untouched
for interactive operators.

Third because it is independent of both the installer and the build,
and its acceptance (a first call to `tools/python/current/bin/python3`
answering the version on a Debian container, the first-run surgery
being the code path that died) needs only a redeployed env tree.

Depends on: nothing.

#### 4. Ship a complete runtime closure in the archive

Type: Issue. Slug: `toolchain-runtime-closure`. Regroups sub-tasks 1 and
2 of work item 3 (Q26).

The develop#19 listing settled what the shipped root contains: the four
glibc compat stubs and `libstdc++.so.6.0.29` are there, `libgcc_s.so.1`
is not, although `libgcc` sits in the python sandbox list, so the
library is lost between payload extraction and packaging. The fix finds
and repairs that spot rather than copying the file in by hand, and adds
a packaging-time closure check listing the members the archive must
carry, so a future drop cannot ship silently. The same item carries the
coherence rule that develop#14 taught: the shipped root must be one
snapshot where every version node a shipped library demands is defined
by the shipped libc, which extends to library families (the root's
libssl 3.5.1 wanting `OPENSSL_3.x` nodes only its sibling libcrypto
serves) and to pruning superseded generations (two libbfd builds side
by side today).

Fourth because it is a packaging fix that can be validated by
repackaging the current tree, without recompiling anything, and doing
it before the expensive rebuild means that rebuild produces a complete
archive on the first attempt instead of forcing a second packaging
round.

Depends on: items 1 and 2 only through the delivery order; technically
independent.

#### 5. Resolve the architecture key across server minors

Type: Feature-request. Slug: `architecture-minor-fallback`. Regroups
work item 5 and decision D9.

Every distribution-specific artifact is named after the architecture
key, which `setup.sh` recomputes from the server and which carries the
minor version. A minor upgrade therefore invalidates the whole file set
at once, with a fatal 902 as the only warning, although RHEL 9 minors
share package names and the mirrors cplx scrapes for them are rolling
9-stream directories that ignore minors entirely. The 9.8 copies made
on 2026-08-07 unblocked the rebuild; this item removes the need to
repeat them.

The rule (D9): resolve the exact key first, so a genuinely divergent
distribution keeps its own list; when no file matches, select the
closest available minor of the same major and same machine, and log
which file was chosen so the substitution is never silent. It applies
to the three lookups that carry the key, the per-tool list, the package
index and the `<arch>_pkgs_url` property. Acceptance: with only
`rhel_9.6` files present, a server reporting `rhel_9.8_x86_64` resolves
them and says so, while a `rhel_9.8` file, when present, still wins.

Fifth because the sqlite item that follows cannot be validated until
the architecture resolves on the 9.8 build account, and because the
copies that unblock it today are the churn this removes. Once it lands,
the duplicated `rhel_9.8` lists can go, leaving one file per major.

Depends on: nothing technically; placed here because item 6 needs a
resolving key.

#### 6. Build the toolchain python with sqlite

Type: Feature-request. Slug: `python-sqlite-support`. Regroups work item
2 (Q24) and decision D7.

The toolchain interpreter has no `_sqlite3`: the python sandbox list
never carried sqlite, so configure never saw `sqlite3.h` and the
extension was never compiled, which is why the consuming project's CI
still runs its test walk without coverage and with its coverage-
importing suites guarded. D7 chose the payload route, the same class as
zlib and libffi, since the server carries only the runtime library and
no header, and RHEL 9's sqlite clears CPython's minimum by a wide
margin. The item adds `sqlite-libs` and `sqlite-devel` to the per-tool
list (already staged), makes detection explicit with
`LIBSQLITE3_CFLAGS` and `LIBSQLITE3_LIBS` in the configure call, next
to the `LIBMPDEC_*` pair it mirrors, rather than trusting pkg-config,
whose shipped `sqlite3.pc` carries `prefix=/usr` and would link the
toolchain against the host library. Acceptance is the configure line
answering `yes` for the `_sqlite3` stdlib extension and `import
sqlite3` succeeding on the build account, on a Debian container after
relocation and on a RHEL target after deployment.

Sixth because it is the first item requiring a full interpreter
recompile, because the closure check defined in item 4 gains
`libsqlite3.so.0` as a required member here, and because its package
step needs the architecture key of item 5 to resolve.

Depends on: items 4 and 5.

#### 7. Rebuild, validate and publish the tools archive

Type: Feature-request. Slug: `tools-archive-rebuild`. Regroups the
rebuild, validation and publication section, with decisions D5 and D1.

The integration item, where the five preceding changes become one
artifact. It refreshes the sandbox payloads (the stream mirrors have
rolled since 9.13.4, and the refresh is what enforces the coherence
rule of item 4), rebuilds the interpreter on Python 3.13.14 (D5, never
3.13.10, with 3.13.15 to be re-checked for regression reports just
before the rebuild), packages with `pkg_tools`, and runs the validation
matrix on both distributions: relocation without any shim, the wrapper
answering on its first call, `import ssl, zlib, sqlite3`, the toolchain
git, version-node coherence, `uv sync` then importing the heavy wheels
with no per-wheel patching, and the ABI probe showing no missing node
and no host fallback. Publication follows D1: the archive rides the
next application release version, which means the consuming project
keeps the current archive and its interims until that release, so the
requirement must state that schedule coupling rather than assume an
immediate switch.

Last because every other item is one of its inputs and because the
publication is irreversible: the releases repository forbids
redeploying a version.

Depends on: items 1 to 6.

### Out of the collection

The cleanups in the consuming project (raising its `tools/tools.version`
pin, deleting the `Q26 INTERIM` blocks, restoring the coverage gate,
dropping the pipeline rsync shim) live in another repository and are
tracked there; they become possible once item 6 publishes. The move to
Python 3.14 (D8) belongs to a later cycle.
