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
   repoints `sources/current`, and the phases run. The `current` symlink
   of the install prefix moves to `git-2.52.0`; the previous version
   stays on disk until you prune it.

## ✅ Check

A new `git-2.52.0-<timestamp>.<arch>.tar.gz` exists in the remote
`tools/git/`, and `tools/git/current` points at `git-2.52.0`.

Related:
[Promote a build into the live tree](promote-a-build-into-the-live-tree.md)
to put the new version in service and drop the old one.
