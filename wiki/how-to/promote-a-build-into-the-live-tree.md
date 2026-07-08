# How to promote a build into the live tree

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

Goal: a tool compiled fine in the cplx staging area on the server; make it
the version users actually run, and retire the old one.

On the server, cplx builds under its own tree (`~/cplx/tools/...`, the
`cplx_path`), while sessions consume a separate live tree (`~/tools`).
Promotion is a controlled rsync from one to the other.

## 📋 Steps

1. On the server, preview what would move:

   ```bash
   ~/cplx/bin/rsync.sh --dry-run
   ```

   The script syncs the paths listed in `~/cplx/rsync_include.txt`
   (minus `rsync_exclude.txt`), and — for versioned tools like `git` and
   `python` — reads each `current` symlink to exclude and then delete
   every *other* version directory: promoting 2.52.0 is also what removes
   2.51.0 from the live tree.

2. Run it for real:

   ```bash
   ~/cplx/bin/rsync.sh
   ```

3. Verify a sensitive file made it across unchanged:

   ```bash
   ~/cplx/bin/compare_file.sh gitconfig$
   ```

   The pattern must match exactly one file on each side (`$` suffix for
   an exact name, `/` in the pattern to match on paths); the script shows
   both files and a word-level `git diff --no-index`.

4. Users pick the tool up through its wrappers: `tools/<tool>/bin/<tool>`
   sources the neighboring `setenv` (PATH, `LD_LIBRARY_PATH`, man pages)
   and execs `../current/bin/<tool>`. Nothing to rebuild on their side —
   the `current` symlink is the switch.

## ✅ Check

`~/tools/git/current` points at the new version, the old version
directory is gone from `~/tools/git/`, and `git --version` from a user
session answers with the new number.

Related: [Directory layout](../reference/directory-layout.md),
[The build order](../explanation/the-build-order.md),
[Relocate an install to another prefix](relocate-an-install-to-another-prefix.md)
(the live tree is what `pkg.sh` packages for other accounts).
