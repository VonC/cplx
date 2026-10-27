# v0.27.0 bundled SQLite implementation tracking and validation

No, it is not implemented.

Track the five steps in the [implementation plan](plan.v0.27.0.sqlite-runtime-upgrade.md).
Step 1 is recorded below with its evidence; each later step gets its own
validation record. The item's code review has not run, so the umbrella row
stays pending until it completes.

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
