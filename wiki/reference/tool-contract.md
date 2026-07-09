# Tool contract

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

What a tool must provide to be buildable by the dispatcher
(`src\install\env\install` on the server). Scaffolding all of it is
`add_tool.bat`'s job; this page is the exact contract.

## Files

| Path | Role |
| --- | --- |
| `src\install\env\<tool>\<tool>_install_functions.sh` | the build functions (from `tool_install_functions.tpl.sh`) |
| `src\setups\pkgs\<tool>\<tool>_<arch>.txt` | dependency list per architecture |
| block in `senv.local.bat` + `tools\senv.local.tpl` | `CPLX_*` values ([CPLX variables](cplx-variables.md)) |
| `<tool>` in `services` and `tools_to_recompile` properties | registration (6 properties files, kept in lockstep) |

## Required functions

Checked by the shared `setenv()`; missing → fatal 22/23/24.

| Function | Default (template) behavior | Conventional fatal code |
| --- | --- | --- |
| `configure()` | `make configure` if needed, then `./configure --prefix=${tool_prefix}` | 199 (triggers the `config.log` pull-back) |
| `build()` | `make`, guarded by a sentinel file | 19 |
| `clean()` | `make clean` when a `Makefile` exists | 4 |

## Optional hook

`<tool>_setenv()`: called at the end of the shared `setenv()` to bend
the environment: `git_setenv` sets `M4`; `glibc_setenv` and `gcc_setenv`
swap in the freshly built make/gcc and neutralize rpath flags;
`make4_setenv` wires `automake116` in.

## Inherited: do not redefine

`install()`, `package()`, `find_package()`, `deploy()` come from
`install_functions.sh`:

- `install()` wipes `${tool_prefix}` and runs `make install`, skipped
  when `CPLX_CHECK_PREFIX` is newer than `CPLX_CHECK_SRC`,
- `package()` tars the prefix into
  `<prefix>-<YYYYMMDD.HHMM>.<CPLX_ARCH_EXT>.tar.gz`,
- `deploy()` copies the package to the shared `tools/pkgs/`, only for
  libraries (`CPLX_BIN` empty).

## The build environment they run in

`setenv()` exports, among others: `tool`, `tool_prefix`
(`<tool>/current`), `tool_src` (`sources/current`), `root` (the sandbox),
`CFLAGS` (`--sysroot=${root} -fPIC -O2 -m64 -march=x86-64 -msse4.2 ...`),
`LDFLAGS` (sysroot, rpath, explicit dynamic linker from the sandbox),
`LIBS` (`-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared`),
`PKG_CONFIG_PATH`, and the autotools binaries from `${root}/usr/bin`.

## Marker semantics

| Marker | Question it answers |
| --- | --- |
| `CPLX_CONFIG_DONE` | "did configure finish?": `default` = `creating Makefile$` in `config.log`; else `<grep-pattern> <file>` |
| `CPLX_CHECK_SRC` | "did the build produce its artifact?" (fatal 193 at install time when absent) |
| `CPLX_CHECK_PREFIX` | "is it installed, and newer than the build?" |

Escape hatches for non-autotools tools: `pass` has no configure and
writes `echo "creating Makefile" > config.log` itself; `glibc` and `gcc`
build out-of-tree in `sources/build` and append the same line manually.
