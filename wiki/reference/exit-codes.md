# Exit codes and fatal conditions

<img src="../assets/logo-cplx-transparent.png" alt="" height="90" align="right">

Confirmed error behavior of the main scripts. All fatal messages go
through the `batcolors`/`echos` `%_fatal%` macro, which prints in red and
exits with the given code.

## `senv.bat` (session activation)

| Code | Condition |
| --- | --- |
| 16 | `GH` (Git home) not defined |
| 17 | `%GH%\bin\git.exe` not found |

A missing `CPLX_TOOL` is not fatal: the session still activates and only
prints a red `ERROR` reminder (`use 'st my_tool' to define it`). The
tool-dependent commands refuse on their own until `st` is run: `s` and
`i` fatal 2, and `sp` (including `sp reset`) fatals 12.

The packaging pair `pkg.sh` / `install_pkg.sh` has its own codes, listed
with the tools in
[Packaging and relocation tools](relocation-tools.md).

## `switchtool.bat` (`st`)

| Code | Condition |
| --- | --- |
| 18 | could not create `setup.properties` from `setup.tpl.properties` |

A missing `src\setups\setup.properties` (git-ignored, machine-local) is
not fatal: `st` recreates it from the committed template with a warning,
and the placeholders at its end still need real server values before
`s`/`sp`/`i`.

## `install.bat` (Windows, `i` / `irc` / `ic`)

| Code | Condition |
| --- | --- |
| 1 | `SSH_CONFIG_ENTRY` not defined, or `services` unreadable |
| 2 / 3 | `CPLX_TOOL` / `CPLX_VERSION` neither in the environment nor as argument |
| 4 | `cplx_path` property missing |
| 65 | scp of the install scripts failed |
| 55 | remote pre-installation steps failed (remote status 4) |
| 56 / 57 / 58 | pulling back `log` / `config.log` / appending it failed |
| 132 | could not open `install.log` in VS Code |
| 5 | remote installation returned non-zero |

## `install` dispatcher + `install_functions.sh` (Linux)

| Code | Condition |
| --- | --- |
| 1 | no source archive matching the version in `sources/` |
| 2 | `<tool>_install_functions.sh` missing |
| 22 / 23 / 24 | `configure` / `clean` / `build` function not defined |
| 25 | no `ld-linux-x86-64.so*` found in the sandbox (`SKIP_CC1_CHECK` bypasses) |
| 199 | configure failed (convention; triggers the `config.log` pull-back) |
| 19 | build (`make`) failed (convention) |
| 4 | clean failed (convention) |
| 193 | `CPLX_CHECK_SRC` artifact missing at install time |
| 211 | `CPLX_CONFIG_DONE` not defined |

## `setup.bat` / `setup.sh` / `setup_packages.sh`

| Code | Condition |
| --- | --- |
| 1 | `SSH_CONFIG_ENTRY` not defined |
| 12 | `setup_packages.sh`: `CPLX_TOOL` unset |
| 59 | `CPLX_CHECK_PREFIX` and `CPLX_CHECK_SRC` basenames differ |
| 111 | `setup.sh`: `CPLX_REPEAT_STEP` or `CPLX_RESET_STEP` could not be applied; `setup_packages.sh`: index listing extraction or aggregation failed |
| 112 | package index empty after scraping every mirror |
| 113 | mirror listing fetch failed or answered fewer than 50 lines (error page) |
| 114 | curated metadata unreadable or no eligible list/mirror definition; selection stays within distribution, major and machine |
| 115 | index scratch/candidate creation, writing or atomic publication failed |
| 116 | atomic package-progress publication failed |
| 117 | invalid package/reset arguments or reset entry absent from the selected active list; no progress change |
| 201 | lookup attempted without a nonempty detected-architecture index |
| 301 / 302 | package short name matched nothing / several entries in the index |
| 5 | remote package installation returned non-zero |
| 119 | `setup.bat`: session activation, argument parsing, the step repeat/reset helper or the Bash script failed |

Codes above are the fatal identifiers printed by the scripts. Bash process
statuses above 255 wrap modulo 256 (301 and 302 appear as 45 and 46).
From CMD, `setup.bat` (`s`, `sp`, `sdpl`) prints the Bash identifier, then
exits 119 whenever `setup.sh` or `setup_packages.sh` fails. It also exits 119
before any setup work for arguments other than none, one step name,
`packages [<step>]`, `packages p_<pkg>` or `packages reset [<entry>]`.
A failed refresh preserves the previous index bytes but fails the current run.
Missing or ambiguous RPMs and exhausted download URLs do not cause another
minor selection. Missing/empty list progress is normal; legacy, mismatched or
stale progress restarts rather than raising a fatal error.

## `packages_management.sh` (Linux sandbox installer)

| Code | Condition |
| --- | --- |
| 121 / 124 / 199 | a mirrored binary still depends on system paths outside the sandbox, or `ldd` could not resolve a library |

## `add_tool.bat`

| Code | Condition |
| --- | --- |
| 21 | `gum.exe` not found under `%PRGS%\gums\current` |
| 121 | `CPLX_URL` still undefined after the prompt |
| 65 / 122 / 123 / 131 | scaffolding file operations failed |

## `update-version.bat` (dev_workflow)

| Code | Condition |
| --- | --- |
| 111 | user/commit step failed |
| 118 | release refused on a dirty tree (`UV_FORCE_REL` overrides) |
| 344 | the release tag already exists |

## `tools\init.bat`

| Code | Condition |
| --- | --- |
| 6 / 7 | `dev_workflow` submodule init / update failed |
