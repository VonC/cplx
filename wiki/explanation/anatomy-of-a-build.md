# Anatomy of a build

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

What actually happens between typing `i` on Windows and finding a
`.tar.gz` on the server. The dispatcher (`tools/install`) and the shared
library (`install_functions.sh`) run a fixed phase sequence; the tool
only customizes the middle.

## The sequence

```text
setenv → [configure] → [clean] → build → install → package → [deploy]
```

- **setenv** builds the entire compilation environment from the sandbox
  ([The sandbox root](the-sandbox-root.md)): sysroot flags, rpaths, the
  sandbox's dynamic linker, autotools from `root/usr/bin`. It also
  verifies the [tool contract](../reference/tool-contract.md) and calls
  the optional `<tool>_setenv()` hook.
- **configure** runs only when needed: `CPLX_CONFIG_DONE` describes the
  proof of a finished configure (by default, `creating Makefile$` in
  `config.log`). `irc` (`--reconfigure`) forces it.
- **build / install** are guarded by the two check markers:
  `CPLX_CHECK_SRC` (the artifact `make` must produce) and
  `CPLX_CHECK_PREFIX` (its installed copy). Timestamps decide: an
  install newer than the build is skipped entirely.
- **package** tars the install prefix into
  `<tool>-<version>-<timestamp>.<arch>.tar.gz`. The prefix is archived
  *relative to itself*, so it can be unpacked anywhere.
- **deploy** copies the package to the shared `tools/pkgs/`, but only
  for libraries. That is the entire meaning of `CPLX_BIN`: binaries are
  consumed through wrappers, libraries are consumed by other builds
  ([The build order](the-build-order.md)).

## Everything is evidence-based

The pipeline never remembers "I did this"; it looks for artifacts:
a grep in `config.log`, a file timestamp in the prefix, an existing
package newer than the build. This is what makes `i` safely re-runnable
after any failure: each phase re-decides from what is actually on
disk. It also means the markers must be truthful: a wrong
`CPLX_CHECK_SRC` makes cplx skip a build that never happened.

## Failure is designed to travel back

Every remote run writes a timestamped log under `logs/`, symlinked as
`log`, which Windows pulls back and opens after each run. Configure
failures use a conventional exit code (199) that makes `install.bat`
additionally fetch `config.log` and append it to the local
`install.log`: the diagnosis material arrives without ever opening a
shell on the server
([Diagnose a failed configure](../how-to/diagnose-a-failed-configure.md)).

## 👉 Where to look next

- [Tool contract](../reference/tool-contract.md): the functions and
  markers a tool provides.
- The long version, with every linker war story: `src/install/doc.md`.
