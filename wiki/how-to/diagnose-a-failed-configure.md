# How to diagnose a failed configure

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

Goal: turn a remote `configure` failure (exit code 199) into the missing
package or flag it actually is.

When configure fails, `install.bat` already did the collecting for you:
it pulls the remote build log *and appends the remote `config.log`* to
`src\install\install.log`, then opens it in VS Code.

## 📋 Steps

1. Jump to the end of `install.log`: the section after
   `"Config.log from remote server"` is the real `config.log`. Search
   upward for `error:` — the first one is usually the honest one.

2. Map a missing header to its RPM and add it to the tool's list (see
   [Add a dependency to a tool](add-a-dependency-to-a-tool.md)):

   | Missing | Package to add |
   | --- | --- |
   | `stdio.h`, `crt1.o` | `glibc-headers`, `glibc-devel` |
   | `libc_nonshared.a` | `glibc-devel` |
   | `linux/limits.h` | `kernel-headers` |
   | `openssl/ssl.h` | `openssl-devel` (or the built `_openssl111`/`_openssl3`) |
   | `ncursesw/panel.h` | `ncurses-devel` |
   | C++ `climits`, `stdlib.h` | `libstdc++-devel` |

3. Undefined symbols at link time are flag problems, not package
   problems, and the fix belongs in the tool's install functions:

   - `__popcountdi2`, `__umodti3`: needs `-march=x86-64 -msse4.2` and
     `-lgcc_s` — already in the shared `setenv()` CFLAGS/LIBS; check the
     tool did not override them,
   - `fflush@@GLIBC_2.2.5` or "DSO missing from command line": the
     `LIBS` list (`-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared`) did not
     reach the link line; OpenSSL famously ignores `LIBS`, which is why
     `openssl111_install_functions.sh` passes them to `./Configure`
     directly,
   - library order matters with `-nodefaultlibs`: `-lc -lpthread` must
     come *after* `-lssl -lcrypto`.

4. Re-run with a forced reconfigure (the marker in `CPLX_CONFIG_DONE`
   would otherwise declare configure already done):

   ```cmd
   irc
   ```

## ✅ Check

The next `install.log` moves past configure — a wrong `CPLX_CONFIG_DONE`
marker shows up here as a build that "succeeds" configure while
`config.log` still ends in an error.

Related: [Tool contract](../reference/tool-contract.md),
[Anatomy of a build](../explanation/anatomy-of-a-build.md); the full war
stories live in `src/install/doc.md`.
