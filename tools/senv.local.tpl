@echo off


if "%~1"=="unset" (
  call:unset_senv
  goto:eof
)

rem set "ECHOS_STACK=true"
rem ...
rem Keep local senv dev in PATH if needed
rem bash -c "echo ${PATH} | grep -q \"$(cygpath -u "${PRGS}/senv/bin")\""
rem if errorlevel 1 ( set "PATH=%PATH%;%PRGS%\senv\bin" )
::##################################################
::  SET PROJECT VARIABLES
::##################################################
set SSH_CONFIG_ENTRY=centos8
doskey s="%project_dir%\src\setups\setup.bat" $*
set "CPLX_REPEAT_STEP="
rem set "CPLX_REPEAT_STEP=transfer_env_to_the_remote_project_folder"
set "CPLX_REPEAT_STEP=validate_the_ssh_connection"
set "CPLX_RESET_STEP="
set "CPLX_TOOL_RC="
rem set CPLX_TOOL_RC=1
rem set "CPLX_RESET_STEP=copy_the_sources"

set "CPLX_SRC_EXT=tar.gz"
set "CPLX_ARCH_EXT=el8.x86_64"
set "CPLX_ARCH_EXT=el9.x86_64"
set "CPLX_URL="

rem set "CPLX_TOOL=python"
if "%CPLX_TOOL%" == "python" (
  set "CPLX_VERSION=3.13.6"
  set "CPLX_URL=https://www.python.org/ftp/python/[version]/Python-[version].tgz"
  set "CPLX_CHECK_PREFIX=lib/libpython3.so"
  set "CPLX_CHECK_SRC=libpython3.so"
  set "CPLX_BIN=true"
  set "CPLX_CONFIG_DONE=default"
)
rem set "CPLX_TOOL=mpdecimal"
if "%CPLX_TOOL%" == "mpdecimal" (
  set "CPLX_VERSION=2.5.1"
  set "CPLX_URL=https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-[version].tar.gz"
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=lib/libmpdec.so"
  set "CPLX_CHECK_SRC=libmpdec/libmpdec.so"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "openssl111" (
  set "CPLX_VERSION=1.1.1w"
  rem https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
  set "CPLX_URL=https://github.com/openssl/openssl/releases/download/OpenSSL_[version_]/openssl-[version].tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=usr/lib64/libssl.so.1.1"
  set "CPLX_CHECK_SRC=libssl.so.1.1"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "git" (
  set "CPLX_VERSION=2.50.1"
  rem https://github.com/git/git/archive/refs/tags/v2.48.1.zip
  set "CPLX_URL=https://github.com/git/git/archive/refs/tags/v[version].zip"
  set "CPLX_CHECK_PREFIX=libexec/git-core/git-add"
  set "CPLX_CHECK_SRC=git-add"
  set "CPLX_BIN=true"
  set "CPLX_CONFIG_DONE=configure: exit 0 config.log"
)

if "%CPLX_TOOL%" == "openldap" (
  set "CPLX_VERSION=2.5.19"
  rem https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.5.19.tgz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_URL=https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-[version].tgz"
  set "CPLX_CHECK_PREFIX=lib/libldap.la"
  set "CPLX_CHECK_SRC=libraries/libldap/libldap.la"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "curl" (
  set "CPLX_VERSION=8.12.1"
  rem https://curl.se/download/curl-8.12.1.tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_URL=https://curl.se/download/curl-[version].tgz"
  set "CPLX_CHECK_PREFIX=lib/libcurl.la"
  set "CPLX_CHECK_SRC=lib/libcurl.la"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "libpsl" (
  set "CPLX_VERSION=0.21.5"
  rem https://
  set "CPLX_URL=https://github.com/rockdaboot/libpsl/releases/download/[version]/libpsl-[version].tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=lib/libpsl.la"
  set "CPLX_CHECK_SRC=lib/libpsl.la"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "libunistring" (
  set "CPLX_VERSION=1.3"
  rem https://
  set "CPLX_URL=https://mirror.team-cymru.com/gnu/libunistring/libunistring-[version].tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=lib/libunistring.la"
  set "CPLX_CHECK_SRC=lib/libunistring.la"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "libidn2" (
  set "CPLX_VERSION=2.3.7"
  rem https://
  set "CPLX_URL=https://mirror.team-cymru.com/gnu/libidn/libidn2-2.3.7.tar.gz"
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=lib/libidn2.la"
  set "CPLX_CHECK_SRC=lib/libidn2.la"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "openssl3" (
  set "CPLX_VERSION=3.4.1"
  rem https://
  set "CPLX_URL=https://github.com/openssl/openssl/releases/download/openssl-3.4.1/openssl-3.4.1.tar.gz"
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=usr/lib64/libssl.so"
  set "CPLX_CHECK_SRC=libssl.so"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=LIBS=apps/libapps.a Makefile"
)

if "%CPLX_TOOL%" == "pass" (
  set "CPLX_VERSION=1.7.4"
  rem https://
  set "CPLX_URL=https://git.zx2c4.com/password-store/snapshot/password-store-1.7.4.tar.xz"
  set "CPLX_SRC_EXT=tar.xz"
  set "CPLX_CHECK_PREFIX=share/man/man1/pass.1"
  set "CPLX_CHECK_SRC=man/pass.1"
  set "CPLX_BIN=true"
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "pinentry" (
  set "CPLX_VERSION=1.3.1"
  rem https://
  set "CPLX_URL=https://github.com/gpg/pinentry/archive/refs/tags/pinentry-[version].tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=lib/aa"
  set "CPLX_CHECK_SRC=lib/aa"
  set "CPLX_BIN=true"
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "libgpg-error" (
  set "CPLX_VERSION=1.51"
  rem https://
  set "CPLX_URL=https://github.com/gpg/libgpg-error/archive/refs/tags/libgpg-error-[version].tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=lib/aa"
  set "CPLX_CHECK_SRC=lib/aa"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "glibc" (
  set "CPLX_VERSION=2.28"
  rem https://
  set "CPLX_URL=https://github.com/bminor/glibc/archive/refs/tags/glibc-[version].tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=usr/bin/pldd"
  set "CPLX_CHECK_SRC=elf/pldd"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "gcc" (
  set "CPLX_VERSION=4.9.4"
  rem https://
  set "CPLX_URL=https://github.com/gcc-mirror/gcc/archive/refs/tags/releases/gcc-[version].tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=lib64/libatomic.la"
  set "CPLX_CHECK_SRC=x86_64-unknown-linux-gnu/libatomic/libatomic.la"
  set "CPLX_BIN=true"
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "flex2" (
  set "CPLX_VERSION=2.5.39"
  rem https://
  set "CPLX_URL=https://github.com/westes/flex/releases/download/flex-[version]/flex-[version].tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=lib/aa"
  set "CPLX_CHECK_SRC=lib/aa"
  set "CPLX_BIN="
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "make4" (
  set "CPLX_VERSION=4.2.93"
  rem https://
  set "CPLX_URL=https://github.com/mirror/make/archive/refs/tags/4.2.93.tar.gz"
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=bin/make"
  set "CPLX_CHECK_SRC=make"
  set "CPLX_BIN=true"
  set "CPLX_CONFIG_DONE=default"
)

if "%CPLX_TOOL%" == "automake116" (
  set "CPLX_VERSION=1.16.1"
  rem https://
  set "CPLX_URL=https://github.com/autotools-mirror/automake/archive/refs/tags/v1.16.1.tar.gz"
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=bin/automake"
  set "CPLX_CHECK_SRC=bin/automake"
  set "CPLX_BIN=true"
  set "CPLX_CONFIG_DONE=default"
)

goto:eof


::##################################################
::  UNSET PROJECT VARIABLES IF REQUESTED
::##################################################
:unset_senv
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof
