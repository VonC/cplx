# Commands

<img src="../assets/logo-cplx-transparent.png" alt="" height="90" align="right">

Aliases loaded by a cplx session (`senv.bat` at the repository root, which
first runs `tools\init.bat` and the `dev_workflow` submodule init). The
session fatals without `GH` (Git home, 16/17); without a selected
`CPLX_TOOL` it still activates, with an `ERROR` reminder to run `st`.

## Windows session — pipeline

| Alias | Runs | Purpose |
| --- | --- | --- |
| `st [name]` | `tools\switchtool.bat` | select `CPLX_TOOL` (substring match) and reload the session; no argument lists the tools |
| `s [step]` | `src\setups\setup.bat` | environment + sources pipeline; optional step to repeat, `r_<step>` to reset |
| `scpe` | `setup.bat "copy.*env"` | repeat the copy-environment branch |
| `scps` | `setup.bat "copy.*source"` | repeat the copy-sources branch |
| `sp [args]` | `setup.bat packages` | package pipeline: index, download, scp, sandbox install |
| `sp p_<pkg>` | — | process one single package |
| `sp reset` | — | clear the `pkgs\<tool>\last` checkpoint |
| `sdpl` | `CPLX_FORCE_RELOAD_PACKAGES=1 setup.bat packages download_packages_list` | rebuild the package index from the mirrors |
| `i [tool] [version]` | `src\install\install.bat` | remote compile; tool/version default to `CPLX_TOOL`/`CPLX_VERSION` |
| `irc` | `install.bat --reconfigure` | same, forcing the configure phase |
| `ic` | `CPLX_INSTALL_COPY_ONLY=1 install.bat` | only scp the install scripts, no remote run |
| `at [name]` | `tools\add_tool.bat` | scaffold a new tool (gum wizard) |

## Windows session — utilities

| Alias | Runs | Purpose |
| --- | --- | --- |
| `steps <fn>` | `steps.sh` | call a step-runner function directly |
| `props <fn>` | `properties.sh` | get/set a property |
| `sfa <file>` | `steps_format_anchors.sh` | regenerate the `{#anchor}` of each step heading |
| `utm <tag>` | `tools\git\update-tag-message.bat` | rewrite or recreate an annotated tag from `version.txt` |

## Windows session — dev_workflow (build and version)

| Alias | Purpose |
| --- | --- |
| `b` / `brel` (`br`) | build; build as a release (see [Make a release](../how-to/make-a-release.md)) |
| `a` | build then run |
| `r` | run stage alone |
| `uv` / `uvr` / `uvf` | update version (snapshot / release / force changelog) |
| `uc` | regenerate `CHANGELOG.md` |
| `gv` | print the current version |
| `crel` | cancel the last release (delete tag, reset commit) |
| `fsenv` | force-reload the session |

## Linux side (after `source ~/cplx/.env`)

The remote `.env` defines the working shortcuts used over SSH; the main
ones:

| Alias / function | Purpose |
| --- | --- |
| `install_packages_for_tool <tool>` (`ipft`) | install the whole `dependencies.list` into the sandbox |
| `install_package_from_name <pkg>` (`ip`) | install one package |
| `rip` / `rap` | reinstall one / all packages |
| `lp` | list installed packages and their flags |
| `mtp` | mirror a package's system dependencies into the sandbox |
| `bash ./install <tool> <version>` | run the build phases (normally driven by `i` from Windows) |
| `~/cplx/bin/rsync.sh [-n]` | promote builds into the live `~/tools` tree |
| `~/cplx/bin/compare_file.sh <pattern>` | diff a live file against its staging counterpart |
