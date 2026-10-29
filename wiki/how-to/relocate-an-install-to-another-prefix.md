# How to relocate an install to another prefix

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

Goal: run the packaged tools on an account or directory that has no
access to the build account's home: another user's `$HOME`, or a shared
prefix like `/project/<team>/refer/<app>`.

Background: compiled binaries hard-code the build home in their
interpreter, rpath and configuration files
([Why binaries remember the build home](../explanation/why-binaries-remember-the-build-home.md)).
The pair `pkg.sh` / `install_pkg.sh` (shipped by the setup pipeline into
`~/cplx/bin`, promoted to `~/tools/bin`) packages the live tree and
re-anchors every one of those paths at unpack time.

## Prerequisites

- The `tools` archive must ship `tools/bin/patchelf`. On the build
  account, download the **static** binary once from the
  [patchelf releases](https://github.com/NixOS/patchelf/releases)
  (`patchelf-<version>-x86_64.tar.gz`; `pip download patchelf` yields the
  same standalone binary when GitHub is unreachable), unpack it under
  `~/tools/patchelf/root/`, then symlink it:

  ```bash
  ln -s ../patchelf/root/bin/patchelf ~/tools/bin/patchelf
  ```

  A static binary runs on any x86_64 Linux, whatever the state of the
  deployed toolchain. It is deliberately **not** a cplx-compiled tool: it
  must work before anything is relocated.
- The archive and `install_pkg.sh` (plus, optionally, its `echos`
  sibling for colored output) are readable from the target account.

## 📋 Steps

1. On the build account, package the live tree from the deployed cplx
   tree:

   ```bash
   ~/cplx/bin/pkg_tools.sh
   ```

   It trims a private stage of `~/tools` and runs the closure gate before
   tar; a bare `pkg.sh tools` refuses, and so does a copy run from inside
   `~/tools` ([Packaging and relocation tools](../reference/relocation-tools.md#pkg_toolssh-the-build-only-stage)).
   The script prints the archive path; an unchanged tree reuses the
   previous archive (SHA1 dedup) and `~/pkgs/tools.latest.tar.gz` always
   points at the newest one.

2. From the target account, stage the artifacts:

   ```bash
   mkdir -p <prefix>/pkgs
   cp "$(readlink -f /home/<builder>/pkgs/tools.latest.tar.gz)" <prefix>/pkgs/
   cp /home/<builder>/tools/bin/install_pkg.sh <prefix>/
   ```

3. Install with the prefix:

   ```bash
   cd <prefix>
   bash install_pkg.sh tools --prefix <prefix>
   ```

   Omit `--prefix` for the historical same-account layout (it defaults
   to `$HOME`). After the mirror (rsync, or `cp` on a host without it),
   the script re-anchors symlinks, clears `__pycache__`, rewrites text
   paths, patches every ELF interpreter and rpath outside venv trees, and
   installs convenience commands in `<prefix>/bin`. Re-running is safe
   (`--force` to reinstall an already-deployed archive), even for a prefix
   that itself lives under `/home`.

   When you verified a specific archive (by its SHA-256, for instance),
   install exactly that file rather than the newest one found:

   ```bash
   bash install_pkg.sh tools --prefix <prefix> \
       --archive <prefix>/pkgs/tools.<stamp>.tar.gz
   ```

   The path must be absolute and name a regular `tools.*.tar.gz` file;
   otherwise the script exits 2 before extracting anything.

4. To rehearse a future `$HOME` deployment from another account, override
   `HOME` for the install commands instead of passing `--prefix`:

   ```bash
   export HOME=/home/<account>/rehearsal
   mkdir -p "$HOME/pkgs"      # drop the archive here
   cd "$HOME" && bash install_pkg.sh tools
   ```

## ✅ Check

Run from the target account, with `<prefix>` substituted:

```bash
BIN=<prefix>/tools/git/current/bin/git    # any relocated binary
LIB=<prefix>/tools/python/root/usr/lib64/libstdc++.so.6.0.29  # any shipped library
readelf -l "$BIN" | grep -A2 INTERP       # interpreter inside <prefix>
readelf -d "$BIN" | grep RPATH            # RPATH exactly: RUNPATH here is a v0.26 tree
readelf -d "$LIB" | grep RPATH            # libraries carry it too, not only programs
ldd "$BIN"                                # every line resolves in <prefix>
grep -RHI /home/<builder>/ <prefix>/tools # must print nothing
```

The tag matters. Grepping for `RPATH|RUNPATH` accepts either and therefore
proves nothing about which one is present, and a tree still carrying
`DT_RUNPATH` has not been relocated by this version. Expect `RPATH` and no
`RUNPATH` line at all.

The library check is not redundant with the program check. `DT_RPATH` applies
to a library's own dependencies where `DT_RUNPATH` does not, so a shipped
library without it would resolve its dependencies against the system while the
programs above it looked correct.

For a relocated Python, the test that exercises loader and rpath at once
is an import: `<prefix>/tools/python/current/bin/python -c "import ssl,
zlib; print('ok')"`. Include `sqlite3` in it: an archive built since v0.27.0
must answer `import sqlite3` with its own `libsqlite3.so.0`, which ships under
`tools/python/root/usr/lib64` ([Check Python SQLite capability](check-python-sqlite-capability.md)).

If the archive or the prefix carries a venv, the install log names it once
per tree with `Venv tree excluded from the ELF pass: <path>`. Expect the
single `CPLX-ELF/1 end` line to read `state=completed reason=none` with
`r-failed=0` and `i-failed=0`: the installer only warns about a failed
write, so the counters are where it shows. A `state=skipped reason=patchelf-absent` line
means no ELF was relocated at all.

From an account that can still read the build home, absence of failure
proves nothing; observe instead: `LD_DEBUG=libs <binary> 2>&1 | grep
<builder>` and `strace -f -e trace=execve,openat <binary>` must show no
`/home/<builder>` access.

## 👉 See also

- [Packaging and relocation tools](../reference/relocation-tools.md):
  flags, passes and exit codes.
- [Promote a build into the live tree](promote-a-build-into-the-live-tree.md):
  what `pkg.sh` packages.
- [Validate a change on a foreign CI agent](validate-a-change-on-a-foreign-ci-agent.md):
  the same relocation, proved on another distribution.
