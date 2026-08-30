# Packaging and relocation tools

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

The scripts that turn the live tree into a portable, relocatable
package. They live in `src/setups/env/bin/`, reach the server as
`~/cplx/bin/` (setup pipeline), are promoted to `~/tools/bin/` by
`rsync.sh`, and travel inside every `tools` archive from then on.
`pkg_tools.sh` is a one-line front end that runs `pkg.sh tools`
(passing any extra arguments through), so the toolchain packages
itself with a single `pkg_tools` command. `pkg` (no extension) is the
dispatcher: `pkg <target>` runs a `pkg_<target>` overlay found in its
own folder when present, the generic `pkg.sh` otherwise, so a project
overlay like my-project's `pkg_pdfs` keeps the historical
`pkg <target>` command working.

Both source `echos` from their own directory or `../echos/`, and fall
back to plain `echo` when neither exists, so `install_pkg.sh` runs
standalone next to an archive on a foreign account.

## `pkg.sh <folder> [--add <item>]... [-- <tar args...>]`

Packages `$HOME/<folder>` into `~/pkgs/`.

| Behavior | Detail |
| --- | --- |
| archive name | `<folder>.<YYYY-MM-DD_HHMMSS>.tar.gz` |
| determinism | `tar --sort=name` + `gzip -n` (no timestamp), so identical content gives identical bytes |
| dedup | SHA1 compared with the newest `<folder>.*.sha1`; on a match the new tarball is deleted and the existing one is printed |
| `latest` link | `<folder>.latest.tar.gz` always points at the newest archive |
| exclusions | any folder named `old` |
| `tools` extra | `~/.env` and `~/.env_` are added when they exist |
| `--add <item>` | ships one extra top-level item (relative to `$HOME`) next to the folder; repeatable |
| `-- <tar args...>` | everything after the sentinel goes to tar verbatim, in order: the hook for project-specific exclusion rules (my-project's `tools/pkg_pdfs.sh` uses it) |
| stdout | the last line is the archive path (new or reused) |

Exit codes: 1 usage error (no folder, unknown option, missing `--add`
value), 2 archive creation failed.

## `install_pkg.sh <folder> [-f|--force] [-p|--prefix <dir>]`

Finds the newest `<folder>.*.tar.gz` (in the prefix, `$HOME`, and both
`pkgs/` directories), unpacks it to a staging area, mirrors it to
`<prefix>/<folder>`, then makes the tree self-contained. A
`<archive>.done` flag in `<prefix>/pkgs/` makes the install idempotent;
`--force` reinstalls. The prefix defaults to `$HOME`.

The mirror and the root file deploy each run on one of two copy engines,
chosen once before the archive is found and announced as a `Copy engine:`
line. rsync is used when `command -v rsync` resolves it; otherwise the
script falls back to `cp`, so a host without rsync installs normally.
`CPLX_INSTALL_PKG_FORCE_CP=1` forces the fallback for validation; only
that exact value does, and any other is treated as unset.

The two engines produce the same manifest when each installs into a fresh
prefix. Over a populated prefix, both remove entries the new tree no longer
carries, but they are not guaranteed to agree entry for entry: rsync may keep
an existing entry when its size and integer-second mtime match, while the
fallback empties the destination and rewrites it. They are also deliberately
**not** equivalent on a wrong-shaped destination:

| Destination | rsync | fallback |
| --- | --- | --- |
| absent, or a real directory (mirror) | mirrors; on a populated destination its quick check can retain a surviving entry | empties the destination, then mirrors |
| absent, or a real regular file (root file) | copies | copies |
| symlink to a directory (mirror) | follows it and empties the **external** target, returning 0 | refused, exit 5 |
| symlink to a regular file (root file) | replaces the link, target untouched | refused, exit 7 |
| FIFO (root file) | replaces it | refused, exit 7 |
| other special file (root file) | depends on rsync's handling of that type | refused, exit 7 |
| empty directory (root file) | replaces it with the file | refused, exit 7 |
| populated directory (root file) | fails, directory intact | refused, exit 7 |

The fallback is the stricter engine. It observes each destination without
following links and refuses anything it was not given, because its delete
and its copy would otherwise act outside the prefix it was pointed at.

The passes, in order:

| Pass | What it rewrites | Guard |
| --- | --- | --- |
| symlink re-anchor | link targets `/home/<user>/...` → `<prefix>/...`, build layout `/home/<u>/cplx/tools/` → `<prefix>/tools/` first | only links whose target starts with `/home/`; links are rewritten, never followed |
| root file deploy | every regular file at the archive root (`.env`, `.env_`, anything shipped with `pkg.sh --add`) is copied to the prefix root, then text-fixed | only files, the target folder is skipped |
| `__pycache__` clear | removes bytecode caches (they embed build paths) | regenerated on first import |
| text path fix | `/home/<user>/` anchors in every text file (shebangs, `pyvenv.cfg`, `*.pc`, activate scripts) | `grep -I` skips binaries; the new prefix is shielded behind a placeholder, so re-runs and `/home`-based prefixes are safe |
| ELF fix | `PT_INTERP` → the deployed `ld-linux-x86-64.so.2`, and the search path → the deployed library directories (python's root first), written as **`DT_RPATH`** | the rpath axis selects by population, not by the value it finds; the interpreter axis still rewrites only values containing `/home/`; skipped with a warning when patchelf is absent |
| convenience bin | `<prefix>/bin`: `echos`, `compare_file.sh` and `pkg` (the shipped dispatcher) links, `pkg_tools` and `install_pkg` wrappers | only for sources present in the tree |


### What the ELF pass writes, and to which objects

The tag written is **`DT_RPATH`**, not `DT_RUNPATH`. The difference is not
cosmetic: `DT_RUNPATH` does not apply to a library's own dependencies, so a
shipped library that pulls in another one would fall back to the system copy,
and `LD_LIBRARY_PATH` would outrank it. `DT_RPATH` applies transitively and
outranks the environment, which is what makes the prefix self-contained.

The pass sorts every walked object into one of **three populations**, and only
these are given a search path:

| Population | What it is |
| --- | --- |
| library | `ET_DYN` with no `PT_INTERP`, the shipped `.so` files |
| migration program | a program already carrying the target value under `DT_RUNPATH`, so a prefix relocated by an older version |
| fresh program | a remaining program whose search path is still builder-anchored |

Two axes are reported independently, because two guards can disagree about the
same object:

| Axis | Values |
| --- | --- |
| rpath | `rewritten`, `failed`, `already correct`, `not dynamically linked`, `excluded` |
| interpreter | `rewritten`, `failed`, `unchanged`, `not applicable` |

**What the pass leaves untouched**, and why each one:

- the shipped dynamic loader itself, the file the pass installs as every
  program's `PT_INTERP`. patchelf accepts a search path on it and reports
  success, and the loader then segfaults, taking every program with it. It is
  excluded by identity, not by name;
- every other program the archive carries that is in none of the three
  populations: the RPM-extracted tools, and the vendored `patchelf` running the
  pass. These are reported `excluded`;
- any object with no dynamic section, reported `not dynamically linked`;
- the interpreter of any object whose interpreter is already correct or is a
  system path, reported `unchanged`.
`patchelf` lookup order: `<prefix>/tools/bin/patchelf`,
`~/tools/bin/patchelf`, then `PATH`. The dynamic linker is taken from
`<prefix>/tools/python/root/lib64/`, falling back to a `find` under
`<prefix>/tools`.

Exit codes:

| Code | Condition |
| --- | --- |
| 1 | usage (no target, unknown flag, missing `--prefix` value) |
| 2 | no archive found for the target |
| 3 / 4 | extraction failed / target folder absent from the archive |
| 5 | mirror step failed, on either engine, including a destination the fallback refuses |
| 7 | root file deploy step failed, on either engine, including a destination the fallback refuses |
| 9 / 10 / 11 | staging create / clean / cleanup failed |
| 12 | text path fix failed |
| 13–16 | `<prefix>/bin` link or wrapper failed |
| 17 | symlink rewrite failed |
| 18 / 19 | prefix / `pkgs` directory creation failed |

### Host tools `install_pkg.sh` needs

Validate a candidate host or agent image against this list. It is the
whole contract: the script needs nothing else from the host, and the
archive supplies the rest.

| Group | Programs | If missing |
| --- | --- | --- |
| Shell | `bash`, and its builtins | nothing runs |
| Mandatory | `basename`, `chmod`, `cp`, `cut`, `dirname`, `find`, `grep`, `gzip`, `head`, `ln`, `mkdir`, `od`, `readlink`, `rm`, `sed`, `sort`, `tar`, `touch`, `tr`, `xargs` | the install fails |
| Optional | `rsync` | the fallback engine is used instead |
| Shipped | `patchelf` | ELF fix is skipped with a warning |

`gzip` is the entry most easily missed: no command position names it. It
is started as a subprocess by `tar -xzf`, so a scan for command tokens
alone reports a contract that a host without `gzip` will fail.

**How this inventory was produced**, recorded so a re-audit reaches the
same list rather than a shorter one:

1. Strip comments and string literals, then collect every token in
   command position, which finds the direct calls.
2. Add the subprocesses that command *options* start, which no token
   scan can see. `tar -z` is the one that matters here.
3. Remove the shell's own builtins and every function the installer defines or
   sources, so `printf`, `[`, `task` and `fatal` are not published as host
   requirements.
4. Confirm every listed program and relied-on GNU behavior on both supported
   targets.

## 👉 See also

- [Relocate an install to another prefix](../how-to/relocate-an-install-to-another-prefix.md):
  the recipe using both tools.
- [Why binaries remember the build home](../explanation/why-binaries-remember-the-build-home.md):
  why the passes exist.
- [Directory layout](directory-layout.md): where the trees sit.
