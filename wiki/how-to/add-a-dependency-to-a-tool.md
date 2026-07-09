# How to add a dependency to a tool

<img src="../assets/logo-cplx-download-transparent.png" alt="" height="90" align="right">

Goal: a tool fails to configure or link because a package is missing on
the server; add that package to the tool's dependency list and install it
into the tool's sandbox.

There is no yum and no automatic dependency resolution: each tool has a
hand-curated, ordered list in
`src\setups\pkgs\<tool>\<tool>_<architecture>.txt`, installed top to
bottom into `tools/<tool>/root/` on the server.

## 📋 Steps

1. Identify the package from the error. A missing header maps to a
   `-devel` or `-headers` RPM: the table in
   [Diagnose a failed configure](diagnose-a-failed-configure.md) covers
   the usual suspects (`stdio.h` → `glibc-headers`,
   `openssl/ssl.h` → `openssl-devel`, ...).

2. Add its *short name* (no version, no `.rpm`) to the tool's list, in
   the right position (order matters, dependencies first):

   ```text
   zlib
   zlib-devel
   ```

   Three prefixes change the meaning of a line:

   - `#` comment / disabled line,
   - `_` a package *built by another cplx tool* (for example
     `_openssl111`, `_curl`): taken from the remote `tools/pkgs/`
     tarballs, never downloaded,
   - `>` force this line and every following one to reinstall.

3. Install just that package (download, scp, unpack into the sandbox):

   ```cmd
   sp p_zlib-devel
   ```

   or re-run the whole list (the `pkgs\<tool>\last` checkpoint makes it
   resume where it stopped):

   ```cmd
   sp
   ```

4. Retry the build, forcing a fresh configure since the environment
   changed:

   ```cmd
   irc
   ```

## ✅ Check

On the server, the package left its flags in `tools/<tool>/pkgs/`:
`<package>.installed.mirrored` and `<package>.list` (its file inventory).
The configure error about the missing header is gone.

Related: [Package list formats](../reference/package-list-formats.md),
[The sandbox root](../explanation/the-sandbox-root.md).
