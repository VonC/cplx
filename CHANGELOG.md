# Changelog cplx

`cplx` aims to recompile Linux tools self-contained build or a static build environment, using `LD_LIBRARY_PATH`, and ignoring `/usr/lib` and `/usr/local/lib`

By using our own static libraries, compatible with the RHEL server version, we can get tools with the most up-to-date features and security patches. And we are no longer depending on the server system updates.

## [v0.23.0] - 2025-04-04 - make and glibc compilations;

Following the incomplete compilation of glib (2.28 instead of 2.17 on RHEL 7.x, for running nodes 18), I need a make 4.x instead of 3.x.

Glibc compile, but does not install. Error or core dump on elf/sln.

### 🚀 Features

- *(make4)* Add GNU Make 4
- *(setups)* Add automake116 to the supported tools
- *(setup)* Use multiple URLs for package download
- *(install)* Introduce glibc wrapper scripts

### 🐛 Bug Fixes

- *(install)* Allow cleanup/install
- *(install)* Resolve bootstrap and automake issues
- *(env)* Check for glibc and make4 availability
- *(install)* Update return codes for errors
- *(install)* Enhance glibc build environment setup
- *(env)* CPLX_BIN means tool uses its name
- *(install)* Dynamic linker setting now conditional
- *(glibc)* Remove unnecessary linker flags
- *(packages)* Fix verbose parameter handling
- *(setups)* Update glibc packages for RHEL 7.9

### ⚙️ Miscellaneous Tasks

- *(setups)* Update CentOS 7.9 packages URLs
- *(setups)* Add libgcc and patchelf dependencies

## [v0.22.0] - 2025-04-01 -- Glibc, GCC and flex compilations

I need a more recent glibc than the one provided by the system (2.17 for RHEL 7.x), for running recent version of nodes.
But, to compile glibc 2.28, I need a gcc 4.9.4. Of course, RHEL has 4.8.5, so I also need a more recent GCC and flex.

This release has successfully recompiled gcc (using flex2, a more recent version of flex), and has produced wrapper scripts for all gcc-related command, so that gcc can be used by other tools (like the compilation of glibc) without setting the new gcc PATH and LD_LIBRARY_PATH: the wrapper scripts do that for you.

But glibc is still not compilable. Next step: compiling make 4.x (instead of the make 3.x provided by RHEL 7.x)

.env comes with install-related aliases (configure, build, install, package, deploy), and an alias to copy a tool source code (scps), complementing the existing scpe for environment setup files.

### 🚀 Features

- *(env)* Add scps alias to copy source files
- *(cplx)* Add glibc, gcc and flex2 to cplx services
- *(flex)* Add install scripts for flex
- *(install)* Add helper aliases for build process
- *(install)* Add `tool_version` to environment
- *(tools)* Add glibc to senv.local.tpl (wip)
- *(tools)* Add GCC 4.9.4 support
- *(install)* Call tool setenv if exists
- *(install)* Add `--force` to create_wrappers.py
- *(setups)* Add update_path_variables helper script

### 🐛 Bug Fixes

- *(install)* Correctly check for out-of-tree build
- *(install)* Update `ld_library_path` gcc `setenv`
- *(install)* Improve wrapper script usability
- *(install)* Correctly quote executable path in wrapper
- *(install)* Use absolute path for in gcc wrapper
- *(install)* Source echos and path update scripts
- *(install)* Gcc installation: ensure cc1 is in PATH
- *(glibc)* Correct glibc build process

### 🚜 Refactor

- *(install)* Env, improve install alias

### ⚙️ Miscellaneous Tasks

- *(git)* Update .gitignore, ignore `t/` folder
- *(aliases)* Add alias for build sources directory
- *(install)* Improve install script logging

### 🔨 Build

- *(packages)* Add missing TeX Live packages

## [v0.21.0] - 2025-03-24 -- Git cred helper and ssh wrapper

Test if GCM - Git Credential Manager can be used as is (no recompilation): no.

I tried:

- pass (using a trusted gpg2 key, with passphrase pre-registered to the
  `gpg-agent`: works with pinentry-curses, provided `GPG_TTY` is set to `$(tty)`)
- https://github.com/languitar/pass-git-helper, a python script, which uses a
 `~/.config/pass-git-helper/git-pass-mapping.ini`, but only matches `host`,
 not `user@host`

So implement a Git credential helper using GPG2 only (not pass), and it works
just fine: `src\install\env\git\bin\git-pass-helper.sh`.
It will create and trust a GPG2, with passphrase, said passphrase acting as a
local password. It will help encrypt a remote Git repository server token forced
the SSH GIT_LOGIN identified user.
(through an SSH forced command script, as described next)

Add an SSH wrapper which will set:
- `GIT_LOGIN` (from the `.ssh/authorized_keys` forced command parameter of
`./tools/git/bin/sshwrapper.sh`)
- `GIT_AUTHOR_NAME` and `GIT_AUTHOR_EMAIL`
  (from `./tools/git/bin/sshgitwrapper.local`)
- `GIT_COMMITTER_NAME` and `GIT_COMMITTER_EMAIL`
(in `./tools/git/bin/sshwrapper.sh`, after sourcing `sshgitwrapper.local`)

An sshe cplxgit will work, with a local PC `~/.ssh/config` of:

```
Host cplxgit
  Hostname cactislux801.prod.lux.ca-indosuez.com
  User gitea2
  IdentityFile ~/.ssh/cplxgit
  PreferredAuthentications publickey
  LogLevel ERROR
  #cplxgit_cd forced
```

The `#cplxgit_cd forced` will make the `sshe.bat` to open an SSH shell, and the
remote SSH forced command `sshwrapper.sh` will make the appropriate `cd` +
`source .env` (as well as set the GIT variables).

### 🚀 Features

- *(install)* Add gpg-restart script
- *(install)* Add git credential helper using `pass`
- *(install)* Use GIT_LOGIN for pass-git-helper
- *(setups)* Update git credential helper

### 🐛 Bug Fixes

- *(setups)* Set `GPG_TTY` and extend `PATH`
- *(install)* Update gpg-agent to use pinentry-curses
- *(install)* Sshwrapper must source `.env`
- *(install)* Improve GPG key generation and storage
- *(install)* Ensure gpg key has ultimate trust
- Git-pass-helper parsing fix
- *(install)* `git-pass-helper` use GPG2, not `pass`
- *(install)* Sshwrapper sourcing `.env` and init file
- *(install)* SSH set committer email and name

### ⚙️ Miscellaneous Tasks

- *(version)* Typos
- *(git)* Ignore PDF files

## [v0.20.0] - 2025-03-19 - libgpg-error

Needed by pinentry

### 🚀 Features

- *(libgpg-error)* Add libgpg-error service

## [v0.19.0] - 2025-03-19 - pinentry

Needed for GPG2 operation.  
Used by pass (the password storage utility)

### 🚀 Features

- *(pinentry)* Add pinentry tool support

### 🐛 Bug Fixes

- *(install)* Update environment variables for autotools

## [v0.18.0] - 2025-03-19 - Pass (password store) and GPG2

Needed for https://github.com/languitar/pass-git-helper
Goal is to store HTTPS credential encrypted.
Install everything to configure cplx own gpg2 keyring/secret-keyring
But it still need a pinentry-tty

### 🚀 Features

- *(pass)* Add pass (password store) tool support
- *(install)* Add support for tar.xz archives
- *(install)* Configure GNUPGHOME
- *(setups)* Add scripts and config for GPG key

### 🐛 Bug Fixes

- *(install)* Handle other build systems
- *(install)* Simplify pass install

### ⚙️ Miscellaneous Tasks

- *(git)* .gitignore includes `tar.xz` and `xz`
- *(packages)* Add cpp package to RHEL 7.9 setup

## [v0.16.0] - 2025-03-17 - libsecret, pkgconfig pc file and pkgs reinstall

* Where to store credentials?

  I have added the dependencies for libsecret and glib2 to work, and
  `~/tools/tool/sources/2.48.1/git-2.48.1/contrib/credential/libsecret$ make`: works

  But it does require a D-BUS session (which needs an X11 $DISPLAY
  and either a gnome-keyring or a KDE kwallet. So no vault backend for now.

* pkgconfig pc files are correctly updated during pkg installation process.

* you now can re-install all packages for a given tool: remove + install back.

### 🚀 Features

- *(install)* Add `short_package_name()` improve log
- *(setups)* Add force option to install packages cmd
- *(install)* Post-install updates pkg-config paths
- *(env)* Add alias for fix_package_pkgconfig_paths
- *(setups)* Build Git with libsecret
- *(install)* List installed/removed packages
- *(packages)* Rename lp to list_files_in_package
- *(install)* Reinstall pkg and reinstall all pkgs

### 🐛 Bug Fixes

- `pkg-config` path and `.pc` files
- *(setups)* Vim fix backspace
- *(setups)* Enhance pkgconfig path resolution
- *(install)* `remove_package` handles `.ori` files
- *(install)* Backup pkgconfig files before modification
- *(install)* Fix_pkgconfig_pc simplify path fixing
- *(install)* Multiple built packages during removal
- *(install)* Reinstall_package handle missing pkg name
- *(install)* Handle built-in packages in pkg-config
- *(install)* Handle root built-in pkg-config paths

### 🚜 Refactor

- *(env)* Rename lfpi to lfip, add rp and rap aliases

### ⚙️ Miscellaneous Tasks

- *(src)* Format comment

## [v0.15.0] - 2025-03-14 - curl dependencies compil, Git and openssl3

Start with libpsl and its own dependencies (libidn2, libunistring).  
Then install openldap, curl, libpsl and libunistring in Git: it works, and 
`git-remote-https` is finally compiled.
Test also openssl3 (3.4.1) not yet included in Git.

Notes:
* Refactor the `install_functions.sh` to include the name of the tool in their
  name: easier to distinguish them.
* `CPLX_CONFIG_DONE` helps grep a string in a file (by default,
  'Creating Makefile' in '`config.log`') to better determine if a re-configure
  is needed.
* PATH now includes also `root/bin`, not just `root/usr/bin`.
* A built package is now deployed to tools/pkgs automatically, when `CPLX_BIN` 
  is not 'true'. `find_package` knows to select the most recent package when it
  is a built one (as opposed to system ones, which should be unique)
* The alias `utm` allows to update a past tag, or recreate a missing one with,
  as message, the content of the version.txt at that past commit.  
  The script is `tools/git/update-tag-message(.bat/.sh)`.

### 🚀 Features

- *(setup)* Add libunistring
- *(install)* Implement package search and deploy
- *(install)* Deploy cplx-bin conditionally
- *(setups)* Add libidn2
- *(install)* Update PATH in install script
- *(install)* Add CPLX_CONFIG_DONE property
- *(install)* Add openssl3 support
- *(tools)* `utm` alias for update tag message script

### 🐛 Bug Fixes

- *(tools)* Pass tool name to add_tool.bat
- *(tools)* Correct libunistring check prefix
- *(setup)* Add cpp dependency for libunistring pkgs
- *(install)* Correctly link libunistring with cc1
- *(setup)* Handle empty CPLX_BIN variable
- *(install)* Configure and build template process
- *(install)* Update PERLLIB for perl modules
- *(tools)* Correctly place version query in add_tool
- *(install)* Add missing include path
- *(install)* Fix libpsl build on RHEL 7.9
- *(install)* Resolve curl build issues on RHEL7.9
- *(setups)* Correct Git dependencies and tools checks
- *(setups)* Openldap, correct openssl111 pkg name
- *(setups)* Update PATH env var
- *(install)* Build Git process reliability
- *(install)* Do not impose `-lssl`/`-lcrypto`
- *(install)* Openssl111 reconfigure message
- *(changelog)* Description message for range

### 🚜 Refactor

- *(install)* Rename tools install fct scripts

### ⚙️ Miscellaneous Tasks

- *(vscode)* Enable spell checking for plain text files

## [v0.14.0] - 2025-03-10 -- Openldap compilation, add_tool script

Since ldap uses openssl, it needs to use the right version of openssl
Openldap will need many dependencies to be recompiled, so we need to add many additional tools.
The add_tool script is used to add the necessary tools to the build environment.

### 🚀 Features

- Add and compile openldap to supported services
- *(curl)* Add curl installation scripts
- *(tools)* Add `add_tool` script
- *(tools)* Add interactive tool setup
- *(tools)* Add libpsl to senv.local.tpl
- *(setup)* Add libpsl to setup and env properties
- *(tools)* Update tool properties
- *(tools)* Handle binary/lib for new tools
- *(tools)* Add_tool manages source URL
- *(tools)* Enhance add_tool script with format detection
- *(install)* Add tool install scripts
- *(install)* Add configure, build, and clean functions
- *(tools)* Refactor resource creation in add_tool.bat

### 🐛 Bug Fixes

- *(setup)* Validate downloaded source size
- *(tool)* Set en var from tool section in add_tool.bat
- Handle CPLX_URL version placeholder

### 📚 Documentation

- *(tools)* Add_tool.bat comments

## [v0.13.0] - 2025-03-06 - Git compilation

Generate Makefile for the Git compilation
Compile Git.  
Still fails to include curl, so no git-remote-https generated.

### 🚀 Features

- *(setup)* Add git to senv.local.tpl
- *(setup)* Add Git installation support
- *(git)* Add Git compilation support
- *(git)* Implement Git wrappers
- *(install)* Add ic alias, CPLX_INSTALL_COPY_ONLY
- *(install)* Add git wrapper script
- *(install)* Handle system executables and symlinks
- *(setup)* Add `mtp` alias to mirror tool packages
- Improve linking of OpenSSL libraries

### 🐛 Bug Fixes

- *(install)* Add git dependencies for RHEL 7.9
- *(scripts)* Correct ffip alias definition
- *(install)* Remove unnecessary python removal
- *(setup)* Handle packages with underscore prefix
- *(git)* Improve git log alias
- *(install)* Correct library loading and linking
- *(install)* Remove unknown Git configuration options
- *(env)* Correctly handle return code of check_ldd
- *(openssl111)* Add zlib and cpp dependencies
- *(setup)* Update fnm alias

### 📚 Documentation

- *(md)* Add SSL documentation

### ⚙️ Miscellaneous Tasks

- *(git)* Bump version to 0.13.0-SNAPSHOT
- *(install)* Update sshgitwrapper local template

### 🔨 Build

- Add curl dependencies for Git on RHEL 7.9

## [v0.12.0] - 2025-03-04 - Compile OpenSSL 1.1.1w needed for Python on RHEL 7.9

Add openssl111 as a tool to compile
Upgrade python wrapper scripts to better handle venv (which copies its own set of python executables)
Add many functions to `packages_management.sh`, including the `install_package_from_name()` function, which means the `install_package` script is now obsolete, and removed.

### 🚀 Features

- *(setup)* Update OpenSSL tool name in props
- *(setup)* Add OpenSSL 1.1.1w support in props tpl
- *(setup)* Improve remote package handling
- *(setup)* Add package removal function
- Add aliases for package management
- *(setup)* Python wrapper script with symlinks
- *(setup)* Improve venv handling in python launcher
- *(tools)* Introduce command to get current tool name
- *(bin)* Add `get_full_package_name` command
- *(bin)* Add `lp` alias and `list_package` func
- Implement find_file_in_packages function
- *(bin)* Add `is_package_installed` function
- *(bin)* Add alias to install package from name
- *(bin)* Implement pkg mirroring and instal logging
- *(tools)* Add switchtool
- *(bin)* Add package list creation and check extension
- *(bin)* Implement logging for pkg mgt script
- *(packages)* Improve package installation check

### 🐛 Bug Fixes

- *(setup)* Improve CPLX URL handling in setup.sh
- *(build)* Correct OpenSSL linking order and libraries
- *(setup)* Add missing deps for Python on RHEL 7.9
- *(setup)* Ensure python3 exists before using
- *(python)* Remove obsolete openssl packages
- *(setup)* Error management in get_package_name
- *(setup)* Handle incomplete package downloads
- *(packages)* Fix partial installation detection
- *(bin)* Correctly handle file removal
- *(bin)* Handle multiple package candidate files
- *(env)* Use debug variable in aliases
- *(packages)* Handle built packages correctly
- *(openssl)* Use /usr prefix and lib64 for openssl 1.1.1
- *(bin)* Package naming now includes timestamp
- *(bin)* Improve built package detection
- *(bin)* Mirroring failed for built packages
- *(install)* Fix package name format
- *(bin)* Handle multiple /built/ package candidates
- *(bin)* Handle package lookup and flag checking
- *(bin)* Package management install means root folder
- *(setup)* Setup_packages handle small corrupted pkg
- *(setup)* Improve package installation process
- *(setup)* Openssl variables
- *(setup)* Handle remote built packages correctly
- *(setup)* `base_package_name` to extract base name
- *(setup)* Setup_packages.sh fix package size check
- *(pkgs)* Correct packages for Python RHEL 7.9
- *(python)* Disable UUID generation in Python build
- *(env)* Handle multiple arguments in aliases
- *(env)* Pass verbose var to `is_package_installed`
- *(python)* Remove uuid dependency on RHEL 7.9
- *(instal)* Python build fix uuid
- *(setup)* Remove install_package script
- *(bin)* Handle pre-installed package list

### 🚜 Refactor

- *(bin)* Improve package searching
- *(bin)* Extract `base_package_name` function
- *(bin)* Improve built package detection

### ⚙️ Miscellaneous Tasks

- *(md)* Markdown lint of doc.md
- *(tools)* Fix submodule initialization check
- *(bin)* Fix indentation in install_package
- *(setup)* Update python installation script
- *(git)* Update `.gitignore`

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
