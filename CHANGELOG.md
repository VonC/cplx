# Changelog cplx

`cplx` aims to recompile Linux tools self-contained build or a static build environment, using `LD_LIBRARY_PATH`, and ignoring `/usr/lib` and `/usr/local/lib`

By using our own static libraries, compatible with the RHEL server version, we can get tools with the most up-to-date features and security patches. And we are no longer depending on the server system updates.

## [v0.8.0] - 2025-02-10 - First installation step, configure works

Copy of the installation scripts.
Execution of a first installation step (unarchive source file, configure and make clean)
Check the installation log are copied back to the PC and opened in IDE

- A step can be reset.
- `cdp` is an alias to cd back to the project root folder.
- changelog is cleanup (no more double date before title)
- `sp` alias triggers a download, scp and unarchive of a rpm package from python_centos_8_x86_64.txt
- `i` alias triggers the scp of `install`, and `install_functions.sh`, launching the installation process

### 🚀 Features

- *(utils)* Add step reset functionality
- *(install)* Add installation scripts
- *(install)* Add installation scripts
- *(setup)* Make setup properties private
- *(setup)* Improve setup.bat error handling
- *(bat)* Senv.bat adds `hlsenv` alias
- *(install)* Installation script first implem.
- *(setups)* Rename project_path to cplx_path
- *(tools)* Add `CPLX_VERSION` to `senv.local.tpl`
- *(install)* Improve Windows installer
- *(install)* Add properties file loading
- *(setup)* Enhance setup.bat aliases
- *(setups)* Retrieve remote host architecture
- *(utils)* Enhance steps.sh with repeat/reset
- *(setup)* Improve setup.bat script
- *(setups,pkgs)* Add CentOS 8 packages list
- *(setup)* Add Python packages for CentOS 8
- *(setup)* Add CentOS and RHEL package URLs
- *(setup)* Add RHEL 7.9 x86_64 packages list
- *(setup)* Package synchronization reads pkgs file
- *(setup)* Add Python RHEL 7.9 x86_64 packages
- *(setup)* Start package synchronization code
- Update RHEL 7.9 x86_64 packages list
- *(setup)* Add package download functionality
- *(setup)* Add scp functionality for packages
- *(echos)* Add caller function to echoslog
- *(setup)* Add install_package script and integration
- *(setup)* Add CentOS/RHEL x86_64 packages folders
- *(setup)* Add .keep file for `root` tools directory
- *(setup)* Improve package installation
- *(setup)* Package installation mirroring and flag
- *(install)* Improve log file management
- Improve packages synchronization
- *(install)* Defined tools/tool symlink
- *(install)* Detects unclean ldd when inst package
- *(install)* Add config.log to local log file
- *(setup)* Add CPLX_SP_REPEAT env var to repeat
- *(setup)* Add install package post step
- *(install)* Enhance Python environment setup
- *(env)* Add alias to tail config log

### 🐛 Bug Fixes

- *(tools)* Remove date from changelog entries
- *(bat)* Change cdc alias to cdp or cdcp
- *(setup)* Project path from SSH config
- *(bat)* Build.bat is quiet after build.
- *(bat)* Move setup.properties copy logic in `senv.bat`
- *(install)* Install_functions.sh add quotes around variables
- *(install)* Get services
- *(install)* Get install tee output last line
- *(install)* Use install_functions.sh for tool installation
- *(install)* Improve archive detection in installer
- *(setup)* Improve architecture detection in setup.sh
- *(setup)* Use external URL for packages
- *(setup)* Improve package URL extraction
- *(setup)* Improve package URL extraction robustness
- *(python)* Remove unnecessary make commands
- *(setup)* Handle missing package URL property
- *(setups)* Correct setup.bat path handling
- *(setup)* Improve package download URL
- *(setup)* Add headers to avoid curl 403 errors
- *(setup)* Remove VSCode automatic opening
- *(setup.bat)* Improve error handling and logs display
- *(install)* Bat improve remote installation logging
- *(install)* Handle unzip/tar extraction failures
- Add root/usr/bin to PATH if missing
- Adjust LD_LIBRARY_PATH for python installation
- *(setup)* Delete pkgs.log before any call
- *(install)* Handle missing Makefile in clean
- *(install)* Handle config.log errors
- *(install)* Update aliases in .env file
- *(setups)* Add libdl to the ldd exclude list
- *(setup)* Add missing packages for gcc
- *(install)* Make sure to fail on ldd warning
- *(setup)* Improve ldd check in package installer
- *(install)* Add glibc-devel to Python CentOS 8 setup
- *(install)* Display parameters
- *(setup)* Adjust PATH environment variable in .env
- *(install)* Improve Python install logging
- *(setup)* Handle `.pc` files in ldd check
- *(install)* Avoid error in Python installation

### 🚜 Refactor

- *(setup)* Split copy_the_sources step

### 📚 Documentation

- *(md)* Add installation and complete setup steps
- *(md)* Add download packages list step

### ⚙️ Miscellaneous Tasks

- *(md)* CHANGELOG updated, trimmed and formatted
- *(bat)* Run.bat format loop
- *(git)* Add 'last' to .gitignore entries
- *(install)* Add missing packages for CentOS 8
- *(md)* Document build issues on CentOS 8
- *(setup)* Add openssl-devel dependency

### Fix

- *(bat)* Add trace logging to install and setup bat
- *(install)* Improve error handling in install script
- Add cpp package for CentOS 8

### Refactor

- *(bat)* Simplify senv.bat and init.bat

## [v0.7.0] - 2025-01-26 -- Download, then SCP tool sources to the remote server

Check `CPLX_TOOL` environment variable against declared services
Get the latest sources (with `-rc`, if `CPLX_TOOL_RC` is set), download and scp them.
Local `env` folder includes the right tree sources for the tools (python, git)

`src/setup/steps.md` steps ID have been updated to match their titles, using the alias `sfa`

### 🚀 Features

- *(setup)* Check services/tools to setup script
- *(setup)* Setup.sh scp sources
- *(setup)* Env keep `tools/sources` folder

### 🐛 Bug Fixes

- *(setup)* Update steps IDs to match their titles

## [v0.6.0] - 2025-01-26 -- SCP to remote host, senv updates, steps tests

`scp` all files needed for an `sshe` (I.e, "SSH Extended", an `senv` utility `ssh` wrapper) session.
- Include all rc files like a `.env` and `.vimrc`
- Include `get_env.sh` and `get_service_name.sh` in `bin/` to get the environment (dev,qal, ...) and service name (cplx, git_cpl, python_cpl, depending on where you are in the tree)

On senv updates, tools aliases (uv, uc and crel) are available even outside lsenv (no need to add `tools` to the `PATH`).
`senv.bat` and `init.bat` or `update-version.bat` no longer change the `cwd` (current working directory)

`steps` tests are using more expressive anchor names, enforced by the `sfa` alias, for `bash -c "./steps_format_anchors.sh $1"`

### 🚀 Features

- *(tools)* Cliff.toml skip CHANGELOG updates entries
- *(setup)* Initial files for env to scp
- *(bat)* Senv.bat add CHANGELOG.md content filter driver
- *(bat)* Tools aliases available outside lsenv
- *(bat)* Add senvle alias for local senv edit
- *(setup)* Robust environment transfer with tar
- *(utils)* Implement step management functions
- *(setup)* Repeat setup steps if CPLX_REPEAT_STEP is set
- *(setup)* Env Dynamically determine service in PS1
- *(env)* Add `tools_to_recompile` property
- *(setup)* Add `services` to properties file
- *(setup)* Enhance `.env` setup with properties and dynamic service
- *(setup)* Add env and service name retrieval scripts
- *(utils)* Improve repeat step handling
- *(tools)* Add setup shortcut and repeat step var

### 🐛 Bug Fixes

- *(tools)* Avoid adding description
- *(bat)* Senv.bat avoid ok msg on filter.changelog
- *(bat)* Avoid any cd on senv and init
- *(tools)* Update-changelog.bat avoid cd
- *(bat)* Remove old alias, ignore RELFORCE
- *(setup)* Setup.bat use _fatal properly
- *(setup)* Set `HOME` variable in `.env` file
- *(setup)* Move `gitconfig` to `.gitconfig` standard
- *(setup)* Copy `utils` and `echos` to remote server
- *(utils)* Improve step management and testing
- *(utils)* Improve steps management script and tests

## [v0.5.0] - 2025-01-21 -- CHANGELOG and tag updates with new version.txt format

Add `tools/git` script folder, to update old tag annotated messages: they not only includes the version and release title, but also the release description.
A `git tag -n v.0.4.0` will show all those informations.
Make sure `update-changelog.[bat/sh]` is able to regenerate the CHANGELOG.md from a given tag, not just from the last tag.
Update the CHANGELOG.md accordingly

### 🚀 Features

- *(tools)* Update-changelog.sh is able to regenerate CHANGELOG.md from a tag
- *(tools)* Update-tag-message updated tag annotation message
- *(tools)* Update-changelog.sh make_new_release means release header
- *(tools)* Update-version.bat release tag with date
- *(tools/git)* Update-tag-message.sh use date

### 🐛 Bug Fixes

- *(tools)* Update-version.bat fix multi-line release description
- *(bat)* T_build.bat echo fatal call path was incorrect
- *(tools)* Get-version.bat detects SNAPSHOT
- *(tools)* Update-version.bat git cmd must use -C
- *(tools)* Update-version.bat update version pattern
- *(tools)* Update-version.bat tag with version.txt
- *(tools)* Update-version.bat restore version
- *(tools)* Update-changelog.sh managed 'latest'
- *(tools)* Update-changelog.sh restore $1 in awk
- *(tools)* No need for double-quotes with date
- *(tools)* Update-version.bat avoid creating tag twice

### 📚 Documentation

- *(setup)* Describe SCP step

### ⚙️ Miscellaneous Tasks

- *(tools)* Remote old updateChangelog.sh
- *(git)* Update version.txt to include 0.5.0-SNAPSHOT release description
- *(git)* Version.txt update release goal

## [v0.4.0] - 2025-01-19 -- First step check SSH connexion, `update-changelog.sh` refactor

This first steps also uses the next properties and step features: the goal is to describe/document the steps in `src/setups/steps.md`, and to avoid making that step if the properties are already set (and memorize in `src/setups/setup.properties`).

This release also refactors the `CHANGELOG.md` generation, using `version.txt` both for the version and the release title/documentation.

### 🚀 Features

- *(bat)* Senv.bat add s alias for setup.bat
- *(bat)* Senv.bat add cdc to go back to project root folder
- *(echos)* Echoslog display exit status on fatal message
- *(echos)* Display script name as prefix on echos messages
- *(utils)* Steps and properties file management
- *(setup)* First step check SSH connexion
- *(tools)* Update-changelog(.bat/.sh) generate CHANGELOG.md
- *(alias)* Add uc local alias for update-changelog.bat
- *(tools)* Get-version.bat should also set project title and release notes
- *(tools)* Update-version.bat set or restore version and title in version.txt
- *(tools)* Update-version.bat use new version-title format with version.txt on SNAPSHOT

### 🐛 Bug Fixes

- *(tools)* Update-version.bat make sure to update changelog when doing a release
- *(tools)* Cliff.toml also skip chore commit for setting new release tag
- *(tools)* Update-changelog.sh clean up tmp files
- *(tools)* Get-version.bat now works
- *(bat)* Senv.bat unset project_version/title/release_notes
- *(tools)* Update-changelog.sh test range array size

### 📚 Documentation

- *(version)* Add version title and description in version.txt
- *(tools)* Cliff.toml add header for cplx project, with commit message on tags
- *(md)* CHANGELOG.md regenerated with more doc
- *(version)* Typo in release description
- *(md)* CHANGELOG.md updated

### ⚙️ Miscellaneous Tasks

- *(shell)* Add .shellcheckrc for external file directive
- *(git)* Ignore bak files

## [v0.3.0] - 2025-01-10 -- Setup initialization

Put in place the skeleton of a setup script (called by `build.bat`), which will executed multiple steps.
Since those are bash scripts, add an `echos` for colored log headers in bash.

### 🚀 Features

- *(bat)* Build.bat calls src\setups\setup.bat, fix exit status
- *(tools)* Senv.local.tpl declare SSH_CONFIG_ENTRY
- *(src)* Add Linux echos
- *(setups)* Add bat and sh scripts for setup

## [v0.2.0] - 2025-01-10 -- Refactor, use improved batcolors, with prefix, stack and multi-lines

A `call_echos_stack` in a script enable batcolors to print the script name.
Init.bat no longer calls/depends on senv.bat.
No more CHANGELOG update while in SNAPSHOT build.

### 🚀 Features

- *(tools)* Use batcolors with stacks
- *(bat)* Senv.bat stack before calling init.bat
- *(bat)* Senv.bat stack declares :call_echos_stack needed by batcolors stack
- *(tools)* Init.bat declares :call_echos_stack needed by batcolors stack
- *(tools)* Update-version.bat declares :call_echos_stack needed by batcolors stack
- *(bat)* Build.bat declares :call_echos_stack needed by batcolors stack
- *(bat)* Build.bat stack before calling senv, update-version or get-version
- *(tools)* Update-version.bat removes all [%~nx0] from _xx echos macros calls
- *(tools)* Init.bat no longer calls/depends on senv.bat
- *(bat)* Senv.bat is no longer called from init.bat, but calls it
- *(bat)* Senv.bat adds ^%USERPROFILE^%\go\bin to PATH if found
- *(bat)* Set CURRENT_SCRIPT when ECHOS_STACK not set in call_echos_stack
- *(bat)* Externalize release version management and changelog to tools/t_build.bat
- *(bat)* Senv.bat calls a senv.local.bat if exists
- *(bat)* Senv.local.tpl template for senv.local.bat (which remains private)
- *(tools)* No more CHANGELOG update while in SNAPSHOT build
- *(tools)* Reference new batcolors with prefix, callstack and pre/post macros
- *(bat)* Senv.bat adds uvf for forcing changelog check in update-version: FORCE_UC
- *(tools)* Update-version.bat does not stop if SNAPSHOT and FORCE_UC set
- *(bat)* Senv.bat add brel/br aliases for making release

### 🐛 Bug Fixes

- *(bat)* Build.bat additional cleanup
- *(bat)* Senv.bat extra space on local message
- *(tools)* Update-version.bat does not create snap on clean rel with 0 additional commit
- *(bat)* Senv.bat empty stack if not done already
- *(bat)* Senv.bat stack makes sure batcolors is unset last
- *(bat)* Build.bat trim build_dir trailing /
- *(tools)* Update-version.bat makes sure errorlevel is 0 before updating version.txt
- *(bat)* Senv.bat, init.bat cannot use CHECK_QUIET_PRJ macro with _xx echos macros
- *(bat)* Senv.bat unstack senv.bat after call to init.bat
- *(bat)* Senv.bat does not activate (ECHOS_STACK) stack by default
- *(tools)* UpdateChangelog.bat removes any nx0
- *(tools)* UpdateChangelog.bat add call_echos_stack
- *(bat)* Senv.bat fix unset, calls init.bat unset
- *(tools)* UpdateChangelog.bat specified working directory for git-cliff
- *(bat)* Build.bat silent mode for senv after a build (before post-processing)
- *(tools)* T_build.bat reset QUIET_PRJ on unset
- *(bat)* Add rem for other commands to add
- *(tools)* Migrate senv.local.tpl to tools
- *(tools)* Update-version.bat uses _post batcolors echos macro
- *(bat)* Senv.bat reset more variables in unset
- *(bat)* All.bat restore all_dir variable unset by build or run
- *(bat)* Senv.bat unset do not rely on possibly unset vars
- *(bat)* All.bat add missing eof after :unset function

### ⚙️ Miscellaneous Tasks

- *(git)* Ignore temp/tmp files
- *(git)* Update batcolors submodule SHA1 reference
- *(git)* Ignore temp file, generated by updateChangelog.bat
- *(git)* Update batcolors

## [v0.1.0] - 2024-12-31 -- Initial project template

Initial `senv.bat` with its aliases.
Focus on build.bat, which calls update-version.bat.

### 🚀 Features

- *(bat)* Senv/init/all/build/run
- *(bat)* Senv.bat prepare msg for local path preserved or set
- *(bat)* Senv.bat records path to path.ini between lsenv/fsenv
- *(bat)* Senv.bat set CHECK_QUIET_PRJ and CHECK_DEBUG_PRJ macros
- *(bat)* Senv.bat and init.bat use CHECK_QUIET_PRJ macro for quiet senv activation
- *(tools)* Get-version.bat initializes version.txt and set project_version
- *(tools)* UpdateChangelog.bat first implementation
- *(tools)* Update-version.bat calls updateChangelog.bat
- *(bat)* Build.bat calls update-version.bat
- *(bat)* Build.bat passes rel to update-version.bat
- *(tools)* Update-version.bat no more build check, if release always build
- *(tools)* Update-version.bat writes PRJ_REL_TITLE (if set) to CHANGELOG.md
- *(tools)* UpdateChangelog.bat uses PRJ_REL_TITLE (if set) as relTitle
- *(bat)* Build.bat creates a target/artifact-version file, fails if param prj_error
- *(bat)* Senv.bat add crel alias to cancel last release, only with lsenv (local)
- *(tools)* Update-version.bat no longer call build.bat
- *(bat)* Build.bat calls update-version, detect failed release and cancel it

### 🐛 Bug Fixes

- *(bat)* Senv.bat rsenv (restore) must delete path.ini
- *(bat)* Senv.bat removes Nexus-based aliases
- *(tools)* Init.bat does not define CHECK_DEBUG_x macro, senv.bat does
- *(bat)* Senv.bat references updateChangelog.bat only with local active (tools added to PATH)
- *(tools)* UpdateChangelog.bat must reference ../senv.bat
- *(bat)* Senv.bat reset additional env vars
- *(tools)* Update-version.bat errors and set has_been_called_from_update when called_from_build
- *(bat)* Build.bat restore senv before processing failed update-version
- *(bat)* Build.bat include build_msg in its banner
- *(tools)* Update-version.bat only restore version.txt, leave CHANGELOG.md untouched
- *(tools)* Update-version.bat reset_pre_release also delete tag after reset to previous commit
- *(tools)* Update-version check then generate CHANGELOG.md, even when it does not exist
- *(bat)* Build.bat fix params, set PRJ_REL_TITLE
- *(bat)* Make sure PRJ_REL_TITLE is reset
- *(tools)* Update-version.bat remove jar reference in fatal msg
- *(bat)* Build.bat skip params if called from update, parse and print params otherwise
- *(bat)* Build.bat must restore echos for params

### ⚙️ Miscellaneous Tasks

- *(vscode)* Workspace and settings
- *(git)* Attributes and ignore rules
- *(bat)* Add github.com/VonC/batcolors to tools\batcolors
- *(git)* Ignore path.ini generated by senv.bat for old(ori) PATH and project PATH
- *(tools)* Get-version.bat documentation
- *(tools)* Add comments to update-version.bat and updateChangelog.bat
- *(bat)* Build.bat documentation
- *(git)* Ignore old and ori extensions, old/ and tmp/ folders
- *(bat)* Build.bat add usage example using aliases
- *(git)* Ignore target/ folder
