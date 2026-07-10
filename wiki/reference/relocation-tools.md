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
`<prefix>/<folder>` (`rsync --delete`), then makes the tree
self-contained. A `<archive>.done` flag in `<prefix>/pkgs/` makes the
install idempotent; `--force` reinstalls. The prefix defaults to `$HOME`.

The passes, in order:

| Pass | What it rewrites | Guard |
| --- | --- | --- |
| symlink re-anchor | link targets `/home/<user>/...` → `<prefix>/...`, build layout `/home/<u>/cplx/tools/` → `<prefix>/tools/` first | only links whose target starts with `/home/`; links are rewritten, never followed |
| root file deploy | every regular file at the archive root (`.env`, `.env_`, anything shipped with `pkg.sh --add`) is copied to the prefix root, then text-fixed | only files, the target folder is skipped |
| `__pycache__` clear | removes bytecode caches (they embed build paths) | regenerated on first import |
| text path fix | `/home/<user>/` anchors in every text file (shebangs, `pyvenv.cfg`, `*.pc`, activate scripts) | `grep -I` skips binaries; the new prefix is shielded behind a placeholder, so re-runs and `/home`-based prefixes are safe |
| ELF fix | `PT_INTERP` → the deployed `ld-linux-x86-64.so.2`, rpath → the deployed library directories (python's root first) | `patchelf` only rewrites values still containing `/home/`; skipped with a warning when patchelf is absent |
| convenience bin | `<prefix>/bin`: `echos`, `compare_file.sh` and `pkg` (the shipped dispatcher) links, `pkg_tools` and `install_pkg` wrappers | only for sources present in the tree |

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
| 5 | main rsync failed |
| 7 | root file deploy failed |
| 9 / 10 / 11 | staging create / clean / cleanup failed |
| 12 | text path fix failed |
| 13–16 | `<prefix>/bin` link or wrapper failed |
| 17 | symlink rewrite failed |
| 18 / 19 | prefix / `pkgs` directory creation failed |

## 👉 See also

- [Relocate an install to another prefix](../how-to/relocate-an-install-to-another-prefix.md):
  the recipe using both tools.
- [Why binaries remember the build home](../explanation/why-binaries-remember-the-build-home.md):
  why the passes exist.
- [Directory layout](directory-layout.md): where the trees sit.
