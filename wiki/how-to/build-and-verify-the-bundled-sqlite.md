# How to build and verify the bundled SQLite

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

Goal: build the selected SQLite release as the cplx tool `sqlite`, put it in
place of any distribution SQLite in Python's sandbox, rebuild Python against
it, and prove that every stage loads that exact build. The same steps
select a newer SQLite release later.

Background:
[Why the toolchain builds its own SQLite](../explanation/why-the-toolchain-builds-its-own-sqlite.md).
Exact values: [Bundled SQLite](../reference/bundled-sqlite.md).

## Prerequisites

- A working cplx session for the el9 build family
  (`CPLX_ARCH_EXT=el9.x86_64`).
- The release to build, checked on `https://sqlite.org/download.html`:
  the newest stable release, never a prerelease or a snapshot.

## 📋 Steps

1. **Pin the release** (only when changing it). Set `CPLX_VERSION` and
   `CPLX_URL` in the `sqlite` block of `senv.local.bat` and
   `tools\senv.local.tpl`; the archive name encodes 3.X.Y as `3XXYY00`
   under the release year. Add the version's four values to
   `sqlite_pinned_identity()` in
   `src\install\env\sqlite\sqlite_install_functions.sh`: the archive
   SHA-256 you compute, the SHA3-256 from the download page, the
   `sqlite3.c` SHA3-256 and the source id from the change log. Compare
   them on a downloaded copy before committing them.

2. **Build the library.**

   ```cmd
   st sqlite
   scpe
   scps
   sp
   i
   ```

   `scpe` pushes the tool's `CPLX_*` values and creates its tree on the
   server; `scps` downloads and transfers the source archive; `sp` unpacks
   the compile set into the `sqlite` sandbox. `i` verifies the source
   bytes, configures, builds, installs, checks the result and deploys
   `sqlite-<version>-<timestamp>.el9.x86_64.tar.gz` to `tools/pkgs/`.

   `st` reloads `senv.local.bat`; an uncommented `set "CPLX_TOOL=..."`
   line in that file wins over it, so keep that line commented while
   switching.

3. **Record the expected build.** On the server, read what the installed
   library reports, through its CLI, which links that library:

   ```bash
   cd ~/cplx/tools/sqlite
   LD_LIBRARY_PATH=$PWD/sqlite-<version>/usr/lib64:$PWD/root/usr/lib64 \
       sqlite-<version>/usr/bin/sqlite3 :memory: \
       'select sqlite_version(); select sqlite_source_id(); pragma compile_options;'
   ```

   Review every option against the configure line, then write the version,
   the source id and one `compile_option=` line per option to
   `src\install\env\python\sqlite_expected.txt`
   ([format](../reference/bundled-sqlite.md#expected-build-file-format)).
   `DISABLE_DIRSYNC` must not appear.

4. **Retire a distribution SQLite from Python's sandbox** (once, when the
   sandbox still holds `sqlite-libs` or `sqlite-devel`). Switch to Python,
   push its values, then remove both payloads on the server:

   ```cmd
   st python
   scpe
   ```

   ```bash
   cd ~/cplx/tools/python
   bash -c 'source ~/cplx/.env; remove_package sqlite-libs && remove_package sqlite-devel'
   ls root/usr/lib64/libsqlite3* root/usr/include/sqlite3*.h   # nothing left
   ```

   Both flags move to `pkgs/removed/`. Python's list names `_sqlite`
   instead of the two packages, so no later `sp` brings them back.

5. **Unpack the library into Python's sandbox, then rebuild Python.**

   ```cmd
   sp
   i
   ```

   `sp` installs the deployed `_sqlite` package into `tools/python/root`.
   `i` notices that the sandbox's SQLite header or library differs from the
   ones the configured tree was built against, retires its `config.log`,
   then reconfigures, cleans and rebuilds; `irc` forces the same path.
   Expect `checking for stdlib extension module _sqlite3... yes`, then the
   build and installed probe lines.

6. **Run the SQLite tests of the rebuilt interpreter** on the server, with
   the installed tree's own library path:

   ```bash
   P=~/cplx/tools/python
   LD_LIBRARY_PATH=$P/root/usr/lib64 $P/python-<python>/bin/python3.13 \
       -m test test_sqlite3 test_dbm_sqlite3
   ```

7. Promote, package and qualify as for any toolchain change:
   [Rebuild and publish the tools archive](rebuild-and-publish-the-tools-archive.md).
   Run the operator probe of
   [Check Python SQLite capability](check-python-sqlite-capability.md)
   on each relocated copy.

## ✅ Check

- The `sqlite` build log shows the three source digests and the source id
  matching, then `SONAME libsqlite3.so.0 and needs at most GLIBC_2.34`
  for the built and the installed library.
- `tools/python/root/usr/lib64` holds one real `libsqlite3.so.<version>`
  and the two links to it, nothing else named `libsqlite3.so*`.
- Every probe line reports `"outcome": "passed"`, `"wal": "passed"` and a
  `sqlite` record equal to `sqlite_expected.txt`.

## ⚠️ When a check refuses

| Refusal | Meaning and fix |
| --- | --- |
| `no pinned source identity` | step 1 was skipped for this version |
| a digest or source id differs | the archive is not the selected release: download it again, never update the pin to match it |
| exit 27, `failed its verification: nothing extracted` | the archive the installer selected, the newest file in `sources/` matching the version, failed one of the four checks before extraction: remove any other matching file, download again, never update the pin |
| `SONAME ...`, `libm.so.6`, `DT_RPATH` | the configure line was changed; restore it |
| probe: `SQLite version/source_id ... differs` | Python loaded another library: look for a host or leftover copy |
| probe: `compile options differ` | the build or the pin changed; review which one is right before editing anything |
| probe: `second SQLite provider` | an old real `libsqlite3.so*` file is still in the sandbox: step 4 |
| packaging: `CLOSURE DUPLICATE REFUSED` naming `libsqlite3.so.0` | another tool's sandbox (`tools/git/root`, say) still holds a distribution copy; when no ELF there needs it, remove that payload as in step 4, promote again and repackage |

## 👉 See also

- [Add a new tool to cplx](../tutorials/02-add-a-new-tool.md): the tool
  model the `sqlite` tool follows.
- [Exit codes](../reference/exit-codes.md).
