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
| `CPLX_RELOAD_PACKAGES` / `CPLX_FORCE_RELOAD_PACKAGES` | refresh / rebuild the package index (`sdpl`) |
| `CPLX_SP_REPEAT` | re-process a given package during `sync_packages` |

## Properties (files, shared by both machines)

`src\setups\setup.properties` (template `.tpl`): `services` and
`tools_to_recompile` (ordered comma lists of tools), `<tool>_repository`
(GitHub repo for tag lookup), `SSH_CONFIG_ENTRY`, `hostname`, `cplx_path`
(remote working folder, parsed from the `#<alias>_cd` SSH-config
comment), `architecture` (detected, e.g. `rhel_9.6_x86_64`), and
`<architecture>_pkgs_url` mirror lists.

`src\setups\env\cplx.properties` (template `.tpl`): the subset shipped to
the server — `services`, `CPLX_ARCH_EXT`, `CPLX_CHECK_PREFIX`,
`CPLX_CHECK_SRC`, `CPLX_BIN`, `CPLX_CONFIG_DONE`, plus host/path/arch.

Read and written by `src\utils\properties.sh` (`get_property`,
`set_property`), format `key=value`, `#` comments.
