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
goto:eof


::##################################################
::  UNSET PROJECT VARIABLES IF REQUESTED
::##################################################
:unset_senv
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof