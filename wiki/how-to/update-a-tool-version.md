# How to update a tool version

<img src="../assets/logo-cplx-download-transparent.png" alt="" height="90" align="right">

Goal: rebuild an existing tool at a newer upstream version, for example
git 2.51.0 → 2.52.0.

## 📋 Steps

1. Edit the tool's block in `senv.local.bat` (and mirror the change in
   `tools\senv.local.tpl` if it should become the committed default):

   ```bat
   if "%CPLX_TOOL%"=="git" (
       set "CPLX_VERSION=2.52.0"
   )
   ```

   `CPLX_URL` normally needs no edit: it contains the `[version]`
   placeholder (`[version_]`/`[_version]` variants turn dots into
   underscores for upstreams that name archives that way).

   Tools with a `<tool>_repository` property (like
   `python_repository=python/cpython`) can even leave `CPLX_VERSION`
   unset: `setup.sh` asks the GitHub API for the latest clean tag
   (alphas/betas rejected, `rc` only on request).

2. Reload the session for the new value, then repeat the source steps
   (downloads and transfers are otherwise skipped as already done):

   ```cmd
   st git
   scps      &:: repeat the "copy the sources" branch of steps.md
   ```

   The new archive lands in `src\setups\sources\` (anything under 9 KB is
   rejected as an HTML error page) and is `scp`ed to the remote
   `tools/git/sources/`.

3. Build:

   ```cmd
   i
   ```

   On the server, the dispatcher extracts into `sources/2.52.0/`,
   repoints `sources/current`, and the phases run. Leftover sibling
   archives (a `2.52.0-rc2` next to the final `2.52.0`) are fine: the
   install warns and uses the most recently changed one.

   The install prefix is derived from the version you asked for, so the
   build lands in a new `git-2.52.0/` directory and the previous version
   is not touched. The `current` symlink of the install prefix moves to
   `git-2.52.0` **only after the install succeeds**; the previous version
   stays on disk until you prune it.

   That ordering is deliberate. `current` is what
   [Promote a build into the live tree](promote-a-build-into-the-live-tree.md)
   reads to decide which version to ship, *and* what it uses to delete
   every other version from the live tree. A symlink moved before the
   build, or moved by a build that then failed, would promote a
   half-written directory and delete the working one. A failed build
   therefore changes nothing: `current` still points at the previous
   version, and re-running is safe.

## ✅ Check

A new `git-2.52.0-<timestamp>.<arch>.tar.gz` exists in the remote
`tools/git/`, and `tools/git/current` points at `git-2.52.0`.

If `current` still points at the old version, the install did not reach
its end: read `src\install\install.log` rather than moving the symlink by
hand, since the new directory may be incomplete.

## ⚠️ Do not move the prefix symlink yourself

It is tempting, when a build fails late, to point `current` at the new
directory and promote anyway. That skips the one check that stands
between a partial build and the live tree. If a build really must be
adopted despite a late failure, verify the prefix has the tool's
`CPLX_CHECK_PREFIX` file first (`lib/libpython3.so` for Python), which is
the same file the install itself tests.

Related:
[Promote a build into the live tree](promote-a-build-into-the-live-tree.md)
to put the new version in service and drop the old one.
