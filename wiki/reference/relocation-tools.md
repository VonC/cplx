# Packaging and relocation tools

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

The scripts that turn the live tree into a portable, relocatable
package. They live in `src/setups/env/bin/`, reach the server as
`~/cplx/bin/` (setup pipeline), are promoted to `~/tools/bin/` by
`rsync.sh`, and travel inside every `tools` archive from then on.
`pkg_tools.sh` is the only way to package the toolchain: it builds a
trimmed private stage and runs `pkg.sh tools --closure-gate` over it
([below](#pkg_toolssh-the-build-only-stage)). `pkg` (no extension) is the
dispatcher: `pkg <target>` runs a `pkg_<target>` overlay found in its
own folder when present, the generic `pkg.sh` otherwise, so a project
overlay like my-project's `pkg_app` keeps the historical
`pkg <target>` command working.

Both source `echos` from their own directory or `../echos/`, and fall
back to plain `echo` when neither exists, so `install_pkg.sh` runs
standalone next to an archive on a foreign account.

## `pkg.sh <folder> [--closure-gate] [--source-root <dir>] [--add <item>]... [-- <tar args...>]`

Packages `$HOME/<folder>` (or `<dir>/<folder>`) into `~/pkgs/`.

| Behavior | Detail |
| --- | --- |
| archive name | `<folder>.<YYYY-MM-DD_HHMMSS>.tar.gz` |
| determinism | `tar --sort=name` + `gzip -n` (no timestamp), so identical content gives identical bytes |
| dedup | SHA1 compared with the newest `<folder>.*.sha1`; on a match the new tarball is deleted and the existing one is printed |
| `latest` link | `<folder>.latest.tar.gz` always points at the newest archive |
| exclusions | any folder named `old` |
| `tools` extra | `~/.env` and `~/.env_` are added when they exist |
| `--add <item>` | ships one extra top-level item (relative to `$HOME`) next to the folder; repeatable |
| `-- <tar args...>` | everything after the sentinel goes to tar verbatim, in order: the hook for project-specific exclusion rules (my-project's `tools/pkg_app.sh` uses it) |
| `--source-root <dir>` | reads the packaged folder from `<dir>/<folder>`; the archive path, the `latest` link, the digest history and every `--add` item stay anchored at `$HOME` |
| `--closure-gate` | runs the [runtime closure checker](toolchain-runtime-closure.md) before tar; required for `tools`, refused for any other folder |
| stdout | the last line is the archive path (new or reused) |

With `--closure-gate`, the deployed declaration (`~/cplx/closure/`) is
checked against its envelope and staged into the packaged tree at
`<folder>/closure/`, and the five checker modules are copied into
`<folder>/bin/` as payload. The checker then
judges the tree tar is about to read. A refusal unstages everything and
produces no archive; a run carried by an accepted waiver (checker exit 3)
produces an archive that is a validation artifact, which publication refuses.

Exit codes: 1 usage error (no folder, unknown option, missing `--add`
value, `tools` without `--closure-gate` or the flag with another folder,
`--source-root` naming no directory), 2 archive creation failed, 3 the
gate could not stage or verify its inputs (no declaration deployed, an
envelope that disagrees, a `pkg.sh` running from inside the payload it
packages); any other code is the checker's own refusal status.

## `pkg_tools.sh`: the build-only stage

`pkg_tools.sh [<pkg.sh args>...]` must run from the deployed cplx tree
(`~/cplx/bin/`); a copy inside `~/tools` refuses with exit 3. The
`<prefix>/bin/pkg_tools` command that `install_pkg.sh` installs runs that
deployed copy, so an account without `~/cplx/bin/pkg_tools.sh` gets no such
command. The script packages a stage, never the live tree, so the gate and
tar read the same trimmed set:

1. **Stage**: a hardlink mirror (`cp -al`) of `~/tools` in a fresh
   `~/.cplx-pkgstage.XXXXXXXX`. A symlink at a write boundary (`tools`,
   `tools/bin`, `tools/closure`, `tools/python`, `tools/python/root`) is
   refused. The gate's destinations are unlinked from the stage first, so
   no write reaches a live file through a shared inode.
2. **Trim** the build-only payload inside the tools' sandbox `root/` trees
   (the live tree keeps all of it): the Python compiler probe
   `tools/python/root/a.out`; every `*/root/usr/libexec/gcc` tree;
   every ELF under `*/root/usr/bin` or `*/root/usr/lib64` that records a
   `DT_NEEDED` on `libbfd` or `libopcodes`; the `libbfd*`, `libopcodes*`
   and `libctf*` libraries; the compiler drivers and helpers (`gcc`, `cc`,
   `c++`, `g++`, `cpp`, `cc1`, `cc1plus`, `lto1`, `lto-dump`, `gcov*`,
   `libmpc`, `libmpfr`, `libdebuginfod-*`, `gresource`, `readelf`,
   `elfedit`). The loader and `libc`, `libm`, `libpthread`, `libdl`,
   `librt` are protected by name.
3. **Loader identity**: every other `ld-linux-x86-64.so.2` must be
   byte-identical to the one `install_pkg.sh` selects, and becomes a
   relative symlink to it (one `LOADER-ALIAS|...` line each); differing
   bytes refuse.
4. **Package**: `pkg.sh tools --closure-gate --source-root <stage>`, with
   the caller's arguments appended. A caller's own `--source-root` is
   refused (exit 3). Success removes the stage; a failure keeps it as
   diagnostic material and returns `pkg.sh`'s status.

## `install_pkg.sh <folder> [-f|--force] [-p|--prefix <dir>] [--archive <absolute-file>]`

Finds the newest `<folder>.*.tar.gz` (in the prefix, `$HOME`, and both
`pkgs/` directories), unpacks it to a staging area, mirrors it to
`<prefix>/<folder>`, then makes the tree self-contained. A
`<archive>.done` flag in `<prefix>/pkgs/` makes the install idempotent;
`--force` reinstalls. The prefix defaults to `$HOME`.

`--archive` replaces the discovery with one explicitly selected file, so a
newer archive lying in a searched directory cannot be installed instead of
the one that was verified. The value must be an absolute path to a regular
file (not a symlink) whose name matches `<folder>.*.tar.gz`; anything else
exits 2 before extraction.

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
| venv exclusion | nothing: every directory holding a `pyvenv.cfg` is pruned from the ELF walk and logged as `Venv tree excluded from the ELF pass: <path>` | the symlink and text passes still relocate a shipped venv's `bin/python` link and `pyvenv.cfg` |
| convenience bin | `<prefix>/bin`: `echos`, `compare_file.sh` and `pkg` (the shipped dispatcher) links, an `install_pkg` wrapper, and a `pkg_tools` wrapper onto the installing account's `~/cplx/bin/pkg_tools.sh` (never the payload copy, which refuses) | only for sources present: in the tree, or in `~/cplx/bin` for `pkg_tools` |

### What the ELF pass writes, and to which objects

The tag written is **`DT_RPATH`**, not `DT_RUNPATH`. The difference is not
cosmetic: `DT_RUNPATH` does not apply to a library's own dependencies, so a
shipped library that pulls in another one would fall back to the system copy,
and `LD_LIBRARY_PATH` would outrank it. `DT_RPATH` applies transitively and
outranks the environment, which is what makes the shipped toolchain resolve
inside its own prefix.

That reach stops at one boundary. The loader ignores every `DT_RPATH`, its
own and its loaders', for a lookup made on behalf of an object that carries
a `DT_RUNPATH`. Many wheel extensions do (an `$ORIGIN` entry pointing at the
libraries bundled beside them), so their other needs, such as
`libstdc++.so.6`, skip the interpreter's `DT_RPATH` and are searched in
`LD_LIBRARY_PATH`, then that `DT_RUNPATH`, then the host cache. The prefix
alone is therefore not self-contained for a venv: the consumer has to give
its runtime commands a search path that lists the shipped directories first
([Why binaries remember the build home](../explanation/why-binaries-remember-the-build-home.md#where-dt_rpath-stops-wheels-with-their-own-runpath)).

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
  system path, reported `unchanged`;
- every venv tree (a directory holding `pyvenv.cfg`), which is never walked
  at all. A wheel object carries no builder path, and its `$ORIGIN` entry is
  the only way it finds the providers bundled beside it: rewriting it as a
  library replaced that entry and broke the heavy wheels on a deployment
  target. Each pruned tree is named in the log.

`patchelf` lookup order: `<prefix>/tools/bin/patchelf`,
`~/tools/bin/patchelf`, then `PATH`. The dynamic linker is taken from
`<prefix>/tools/python/root/lib64/` or `root/usr/lib64/`, falling back to a
`find -L` under `<prefix>/tools`.

### CPLX-ELF/1 install records

The ELF pass prints machine-readable records on standard output, beside the
human lines, so a retained install capture can be asserted on without a file
written into the prefix. One `obj` record per walked ELF, then exactly one
`end` record, on every path:

```text
CPLX-ELF/1 obj case=<1-7> rpath=<disposition> interp=<disposition> path=<hex>
CPLX-ELF/1 end state=<state> reason=<reason> walked=<n> r-rewritten=<n> r-failed=<n> r-already-correct=<n> r-not-dynamic=<n> r-excluded=<n> i-rewritten=<n> i-failed=<n> i-unchanged=<n> i-not-applicable=<n> mig-checked=<n> mig-failed=<n>
```

| Field | Values |
| --- | --- |
| `case` | the population, first match wins: 1 observation failed or ambiguous, 2 no dynamic section, 3 already correct, 4 library, 5 migration program, 6 fresh program, 7 excluded (including the loader) |
| `rpath` | `rewritten`, `failed`, `already-correct`, `not-dynamic`, `excluded` |
| `interp` | `rewritten`, `failed`, `unchanged`, `not-applicable` |
| `path` | the object's path relative to the walked root, as lowercase hex of its raw bytes (a Linux name need not be UTF-8) |
| `state` / `reason` | `completed` / `none`, or `skipped` / `patchelf-absent` with every counter at 0 |

The pairing exists because a skipped pass and a completed walk of an empty
tree both emit zero `obj` records. The case is the object's population and
never changes with the outcome: a failed write keeps its case and records
`failed`. A reader locates fields by name, and rejects an unknown marker
version rather than guessing.

Exit codes:

| Code | Condition |
| --- | --- |
| 1 | usage (no target, unknown flag, missing `--prefix` or `--archive` value) |
| 2 | no archive found for the target, or an `--archive` that is relative, not a regular file, or not named `<folder>.*.tar.gz` |
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
- [Runtime closure checker](toolchain-runtime-closure.md): the gate
  `--closure-gate` runs.
- [Rebuild and publish the tools archive](../how-to/rebuild-and-publish-the-tools-archive.md):
  `pkg_tools.sh` in the release sequence.
- [Directory layout](directory-layout.md): where the trees sit.
