# CPLX variables

<img src="../assets/logo-cplx-transparent.png" alt="" height="90" align="right">

The variables that drive a build, and where each one is defined.

## Session prerequisites (`senv.local.bat`, machine-local, not committed)

| Variable | Meaning |
| --- | --- |
| `GH` | Git-for-Windows home; the session PATH is rebuilt from it (fatal 16/17 when wrong) |
| `SSH_CONFIG_ENTRY` | SSH alias of the Linux build server (`~/.ssh/config` Host) |
| `CPLX_TOOL` | the tool being worked on; set by `st` (non-fatal `ERROR` at activation when unset; `s`/`i` refuse to run without it) |
| `CPLX_REPEAT_STEP` / `CPLX_RESET_STEP` | step(s) to re-run on every `s` |
| `CPLX_ARCH_EXT` | package suffix produced on the server, e.g. `el9.x86_64` |
| `CPLX_SRC_EXT` | default source archive extension (`tar.gz`, `tar.xz`, `zip`) |

## Per-tool block (`senv.local.bat`, template `tools\senv.local.tpl`)

One `if "%CPLX_TOOL%"=="<tool>"` block per tool:

| Variable | Meaning |
| --- | --- |
| `CPLX_VERSION` | version to download and build |
| `CPLX_URL` | download URL; `[version]` placeholder, `[version_]`/`[_version]` for dots-to-underscores |
| `CPLX_CHECK_SRC` | file that proves `make` succeeded, relative to the source/build tree (git: `git-add`) |
| `CPLX_CHECK_PREFIX` | its installed counterpart, relative to the prefix (git: `libexec/git-core/git-add`); same basename as `CPLX_CHECK_SRC` (fatal 59 otherwise) |
| `CPLX_BIN` | `true` = executable tool: gets wrappers, is not deployed to `tools/pkgs`; empty = library: deployed for other tools to consume |
| `CPLX_CONFIG_DONE` | proof that configure finished: `default` (greps `creating Makefile$` in `config.log`) or `<pattern> <file>` (git: `configure: exit 0 config.log`) |

## Pipeline switches (set for one command)

| Variable | Effect |
| --- | --- |
| `CPLX_INSTALL_COPY_ONLY` | `install.bat` stops after copying the scripts (`ic`) |
| `CPLX_RELOAD_PACKAGES` / `CPLX_FORCE_RELOAD_PACKAGES` | either requests one detected-index refresh per invocation despite a done marker (`sdpl` sets the force flag) |
| `CPLX_SP_REPEAT` | with a valid nonempty list cursor, resume after the first active entry matching the cursor or this value; ineffective with empty/restarted progress |

## Server-side switches (Linux, set for one command)

| Variable | Read by | Effect |
| --- | --- | --- |
| `CPLX_INSTALL_PKG_FORCE_CP` | `install_pkg.sh` | exactly `1` forces the `cp` copy engine even where rsync exists, announced as `Copy engine: cp (forced by CPLX_INSTALL_PKG_FORCE_CP=1)`; any other value is treated as unset. A validation surface, not an operating mode |
| `CPLX_TOOLS_RELEASE` | `closure_publish.sh` | exactly `1` makes `--expected-sha256` mandatory, so a tools release cannot publish without the SHA-256 its release record accepted |

`CPLX_TOOLCHAIN_LD_LIBRARY_PATH` is not a switch: the
[Python wrapper](python-wrapper.md) sets it to hold the library path it
removed from its own environment, and nothing reads it from outside.

## Properties (files, shared by both machines)

`src\setups\setup.properties` (template `.tpl`): `services` and
`tools_to_recompile` (ordered comma lists of tools), `<tool>_repository`
(GitHub repo for tag lookup), `SSH_CONFIG_ENTRY`, `hostname`, `cplx_path`
(remote working folder, parsed from the `#<alias>_cd` SSH-config
comment), `architecture` (detected, e.g. `rhel_9.6_x86_64`), and
`<architecture>_pkgs_url` mirror lists.

The detected `architecture` continues to name the generated index and RPM
cache. Curated lists and active mirror properties are selected independently:
exact, highest lower minor, then lowest higher minor of the same distribution,
major and machine. A missing/empty detected index is regenerated even without
reload flags. Selected mirrors are resolved lazily and fixed for the invocation;
the template is not merged into an existing active properties file.

`src\setups\env\cplx.properties` (template `.tpl`): the subset shipped to
the server: `services`, `CPLX_ARCH_EXT`, `CPLX_CHECK_PREFIX`,
`CPLX_CHECK_SRC`, `CPLX_BIN`, `CPLX_CONFIG_DONE`, plus host/path/arch.

Read and written by `src\utils\properties.sh` (`get_property`,
`set_property`), format `key=value`, `#` comments.
