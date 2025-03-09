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

set "CPLX_SRC_EXT=zip"
set "CPLX_ARCH_EXT=el8.x86_64"
set "CPLX_URL="

rem set "CPLX_TOOL=python"
if "%CPLX_TOOL%" == "python" (
  set "CPLX_VERSION=v3.13.1"
  set "CPLX_URL=https://www.python.org/ftp/python/[version]/Python-[version].tgz"
  set "CPLX_CHECK_PREFIX=lib/libpython3.so"
  set "CPLX_CHECK_SRC=libpython3.so"
  set "CPLX_BIN=true"
)
rem set "CPLX_TOOL=mpdecimal"
if "%CPLX_TOOL%" == "mpdecimal" (
  set "CPLX_VERSION=2.5.1"
  set "CPLX_URL=https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-[version].tar.gz"
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=lib/libmpdec.so"
  set "CPLX_CHECK_SRC=libmpdec/libmpdec.so"
  set "CPLX_BIN="
)

if "%CPLX_TOOL%" == "openssl111" (
  set "CPLX_VERSION=1.1.1w"
  rem https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
  set "CPLX_URL=https://github.com/openssl/openssl/releases/download/OpenSSL_[version_]/openssl-[version].tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_CHECK_PREFIX=dummy"
  set "CPLX_CHECK_SRC=dummy"
  set "CPLX_BIN="
)

if "%CPLX_TOOL%" == "git" (
  set "CPLX_VERSION=2.48.1"
  rem https://github.com/git/git/archive/refs/tags/v2.48.1.zip
  set "CPLX_URL=https://github.com/git/git/archive/refs/tags/v[version].zip"
  set "CPLX_CHECK_PREFIX=lib/aa"
  set "CPLX_CHECK_SRC=lib/aa"
  set "CPLX_BIN=true"
)

if "%CPLX_TOOL%" == "openldap" (
  set "CPLX_VERSION=2.5.19"
  rem https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.5.19.tgz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_URL=https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-[version].tgz"
  set "CPLX_CHECK_PREFIX=lib/aa"
  set "CPLX_CHECK_SRC=lib/aa"
  set "CPLX_BIN="
)

if "%CPLX_TOOL%" == "curl" (
  set "CPLX_VERSION=8.12.1"
  rem https://curl.se/download/curl-8.12.1.tar.gz
  set "CPLX_SRC_EXT=tar.gz"
  set "CPLX_URL=https://curl.se/download/curl-[version].tgz"
  set "CPLX_CHECK_PREFIX=lib/aa"
  set "CPLX_CHECK_SRC=lib/aa"
  set "CPLX_BIN="
)

if "%CPLX_TOOL%" == "libpsl" (
  set "CPLX_VERSION=_tbd_libpsl"
  rem https://
  set "CPLX_URL="
  set "CPLX_CHECK_PREFIX=lib/aa"
  set "CPLX_CHECK_SRC=lib/aa"
  set "CPLX_BIN=_tbd_libpsl"
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
