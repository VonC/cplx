# Changelog cplx

`cplx` aims to recompile Linux tools self-contained build or a static build environment, using `LD_LIBRARY_PATH`, and ignoring `/usr/lib` and `/usr/local/lib`

By using our own static libraries, compatible with the RHEL server version, we can get tools with the most up-to-date features and security patches. And we are no longer depending on the server system updates.

## [v0.11.0] - 2025-02-17 - Build Python with mpdecimal, add archive

Check if mpdecimal help for the Python decimal module
Add a package step to include all runtime dependencies and python wrapper script

### 🚀 Features

- *(install)* Rename archive to package in install scripts
- Enhance senv.bat with tool info
- Add mpdecimal package (remotely built: '_' prefix)
- *(env)* Add tools packages paths to `.env` file
- *(env)* Add alias to navigate to tool pkgs
- *(env)* Improve vimrc configuration with line #
- *(setup)* Support remote package installation
- *(env)* Compute tool name to `.env` file
- *(install)* Add install and package functions
- Get CPLX properties and add checks
- *(setup)* Setup.sh add arch and checks var to props
- Rename `cplx.properties` to `cplx.tpl.properties`
- *(setup)* Add `cplx.properties` to `.gitignore`
- *(setup)* Setup.sh creates cplx.properties
- *(setup)* Add `CPLX_BIN` property and `bin` directory
- Add Python 3 wrapper scripts
- *(setup)* Add root symlink in tool setup
- *(setup)* Create symbolic link for python.1 man page
- *(install)* CentOS 8 setup and doc
- Add mpdecimal package for RHEL 7.9 x86_64
- *(env)* Add `rgp` function to `.env` file

### 🐛 Bug Fixes

- *(setup)* Improve package extension handling
- *(setup)* Remove debug messages for skipped pkg
- *(setyp)* Improve package installation flags
- *(install)* Link libmpdec and correct LDFLAGS
- *(nev)* Enhance fd function in .env file
- *(setup)* Always create `cplx.properties`
- *(setups)* Improve ldd check in install_package
- *(install)* Add CPLUS_INCLUDE_PATH to setenv script
- *(setup)* Simplify service name retrieval
- *(setup)* Get_service_name.sh service name detection
- *(setup)* Escape special characters in package names
- *(env)* Enhance senv.bat to remove done markers
- *(setup)* Use realpath for cwd in packages_management.sh
- *(mpdecimal)* Add missing dependencies for RHEL 7.9

### ⚙️ Miscellaneous Tasks

- *(docs)* Correct `-lgcc` to `-lgcc_s` in doc
- *(doc)* Address python test failures on Linux
- *(doc)* Python expoitation with pip upgrade

### Fix

- *(setup)* Add checks vars for Python and mpdecimal
- *(setup)* Setup.sh update `cplx.properties`

### Refactor

- `pkgs_dir` is actually `tools_pkgs`
- *(setup)* Rename archive to package
- *(setup)* Mutualize install and package functions

## [v0.10.0] - 2025-02-15 - Refactor, compile, and archive mpdecimal

Refactor: root is now per tool, not common to tools
mpdecimal: needed for Python to import _decimal module
archive: a tar.gz of the tool installed

Note: opening logs with VSCode no longer steam the focus of the current Windows which initiated the setup or installation.

### 🚀 Features

- *(env)* Add senvi alias for install functions
- *(install)* Improve Python environment setup
- *(env)* Add cdttc alias for current tool directory
- *(setups)* Improve install packages logging
- Remove env/tools and its unused .keep files
- Add mpdecimal and openssl to services to build
- *(setup)* Add setup script for remote server
- *(setup)* Get_the_latest_tag split in two steps
- Add download URL (CPLX_URL) in senv.local.bat
- *(setup)* Split get_the_latest_tag in two steps
- *(env)* Add mpdecimal and openssl services
- *(setup)* Improve setup.bat log display
- *(setup)* Improve setup.sh script, call remote setup
- *(install)* Create config symlink 'sources/current'
- Add steps.md to .gitattributes
- *(setup)* Add packages management script
- *(setup)* Enhance .env with package management
- *(setup)* .env source echos and install functions
- *(setup)* Improve directory structure for tools
- *(setup)* Setup script now adds install dir
- *(install)* Simplify current symlink update
- *(setup)* Add missing packages for CentOS 8 mpdecimal
- *(setup)* Support various source archive extensions
- *(env)* Add rg and rgi aliases
- *(bat)* Add scpe doskey command to senv.bat
- *(install)* Add make install, with mpdecimal
- *(tools)* Add `CPLX_ARCH_EXT` to `senv.local.tpl`
- *(install)* Add mpdecimal archive step

### 🐛 Bug Fixes

- *(python)* Adjust setenv error handling
- *(install)* Correct OpenSSL paths in Python installation
- *(install)* Missing Python deps for RHEL7 and CentOS8
- *(python)* Adjust OpenSSL paths and deps for CentOS 8
- *(install)* Update install docs and package lists
- *(setup)* Improve pkgs log file handling
- *(install)* Remove unnecessary symlink 'current'
- *(setup)* Add `tool/root`, check `CPLX_VERSION`
- *(setup)* Improve package lookup
- *(setup)* Setup_packages.sh update last one when OK
- *(setup)* Packages are logged and installed per tool
- *(install)* Adjust current symlink path for src
- *(setup)* Correct symbolic link path for ld
- Correct alias cds definition
- *(setups)* Add missing mpdecimal deps on CentOS 8
- *(install)* Enhance `LD_LIBRARY_PATH` and `LDFLAGS`
- *(install)* Correct installation prefix for tools
- *(mpdecimal)* Disable C++ support during build
- *(mpdecimal)* Improve mpdecimal build and clean

### 🚜 Refactor

- *(install)* Install_functions at tools level

### ⚙️ Miscellaneous Tasks

- *(md)* Start install section
- *(install)* Typo on comment
- *(doc)* Add mpdecimal source URL
- *(git)* Improve steps.md handling in Git attributes
- *(typo)* Correct hostname message in setup script
- *(doc)* Update version.txt

### Feat

- Setup.bat log display restore focus to window
- *(install)* Restore window focus after VSCode launch

### Fix

- *(src)* Use ln -nfs for symlinks
- *(setup)* .env shellchecks updates
- *(setup)* .env corrects root path
- *(setup)* Improve error handling in packages_management.sh

### Refactor

- *(setup)* Move setup file and improve structure

## [v0.9.0] - 2025-02-12 - Compile Python

Now that the install script works, and configure Python,
generating a Makefile, the goal is to compile it.  
It does, but cannot use hashlib based on openssl, 
because CentOS/RHEL 7 use an old 1.0.2, instead of 1.1.1+

### 🚀 Features

- *(setup)* Skip commented lines in package list
- Prepare repeat/done steps test
- *(steps)* Improve step done management steps.sh
- *(install)* Add build step to installation
- *(env)* Add useful aliases to `.env`
- *(setup)* Add alternative RHEL 7.9 package URLs
- *(bin)* Add alias command wrapper
- *(steps)* Add steps_list and steps_list_one_step
- *(bin)* Improve alias command output, using color
- *(install)* Improve install script option parsing
- *(install)* Process options --clean and --configure
- *(env)* Add `fd` function to `.env` file
- *(env)* Improve file search functions
- *(env)* Symbol lookup, find and grep finctions

### 🐛 Bug Fixes

- *(build)* Improve build.bat and senv.bat unset
- *(install)* Improve config.log check
- Install package do not fail on 'cp perm denied'
- *(python)* Add missing dependencies for RHEL 7.9
- *(install)* Fix CPLX_VERSION error msg install.bat
- Setenv() must have a version
- *(env)* Remove `export -f` from shell functions
- Remove unnecessary sys folder creation
- *(utils)* Steps.sh tests reset from the same file
- *(steps)* Exit early if steps_list_one_step fails
- *(setup)* Adjust bash command quote on step rep
- *(env)* Update alias command references
- *(install)* Add SSE4.2 flags to CFLAGS
- *(install)* Update `LDFLAGS` to include `-lgcc`
- *(install)* Pass all args to remote install script
- *(install)* Remove python after clean
- *(install)* Extend reconfigure options
- *(install)* Add bz2 pkgs for Python build RHEL 7.9
- *(install)* Ignore liboneagentproc in ldd check
- *(setup_packages)* Display skipped lines when resuming processing
- *(python)* Add missing dependencies for xmlsec1
- *(install)* Document liboneagentproc and openssl_hashlib

### 🚜 Refactor

- *(build)* Simplify cleanup routine

### 📚 Documentation

- *(md)* Compilation issues on RHEL 7.9
- Avoid cSpell on doc and CentOS packages details

### ⚙️ Miscellaneous Tasks

- *(md)* Non-blocking error __umodti3
- *(md)* Add modules to activate
- *(md)* Add LDFLAGS possible new options for compiler-rt
- *(setup)* Diable Code Spell Checker on pkgs list
- *(md)* Add doc on stdatomic.h
- *(md)* Add doc on bz2

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
