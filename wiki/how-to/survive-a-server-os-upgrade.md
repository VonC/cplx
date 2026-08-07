# How to survive a server OS upgrade

<img src="../assets/logo-cplx-bridge-transparent.png" alt="" height="90" align="right">

Goal: the build server was upgraded (RHEL 9.6 to 9.8, say), and the
next `s` or `sp` now fails or aims at files that do not exist. Restore a
working supply chain in a few minutes.

Symptom: a run stops on `Failed to copy '<tool>_rhel_9.8_x86_64.txt'`
(fatal 902), or the package index cannot be found, right after the
connection step reported a new architecture. Why this happens is
[The architecture key](../explanation/the-architecture-key.md); nothing
is broken in the installed tree, only in what feeds new builds.

## 📋 Steps

1. Confirm the new key, and note the old one:

   ```cmd
   grep architecture src\setups\setup.properties
   ```

   The property was already overwritten by the connection step, so it
   holds the new value, for example `rhel_9.8_x86_64`. The old file set
   still carries the previous one in its names.

2. Give the new key its mirrors, in `src\setups\setup.properties` (and
   in `tools\senv.local.tpl`'s companion `setup.tpl.properties` when the
   value should become the committed default). Within one major release
   the URLs are the same as the previous minor, since the mirrors are
   rolling:

   ```properties
   rhel_9_8_x86_64_pkgs_url=https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/,https://mirror.stream.centos.org/9-stream/AppStream/x86_64/os/Packages/
   ```

3. Copy each per-tool dependency list to the new key. Only the tools
   you actually build need one:

   ```cmd
   copy src\setups\pkgs\python\python_rhel_9.6_x86_64.txt src\setups\pkgs\python\python_rhel_9.8_x86_64.txt
   copy src\setups\pkgs\git\git_rhel_9.6_x86_64.txt src\setups\pkgs\git\git_rhel_9.8_x86_64.txt
   ```

   Keep the old files: they document the previous server and cost
   nothing.

4. Rebuild the package index for the new key:

   ```cmd
   sdpl
   ```

   This scrapes the mirrors again and writes
   `src\setups\pkgs\packages_rhel_9.8_x86_64.txt`. It is a generated
   file, tracked in git like its predecessor.

5. Resume the normal flow:

   ```cmd
   sp
   i
   ```

## ✅ Check

`sp` copies `<tool>_rhel_9.8_x86_64.txt` to the server as
`dependencies.list` and installs from it, and
`packages_rhel_9.8_x86_64.txt` exists and is thousands of lines long.

## ⚠️ Two traps

- **Do not hand-edit the architecture property back** to the old value
  to avoid the work. The connection step recomputes it on the next run
  and your edit disappears, or worse it survives long enough to build
  against lists that no longer describe the machine.
- **A major upgrade is not this recipe.** Going from RHEL 8 to RHEL 9
  changes package names, not just the key: start from
  [Target a new Linux server](../tutorials/03-target-a-new-linux-server.md)
  and expect to adjust the lists as builds complain.

Related: [Add or fix a package mirror](add-or-fix-a-package-mirror.md)
when a mirror in the new list misbehaves, and
[Package list formats](../reference/package-list-formats.md) for every
artifact the key names.
