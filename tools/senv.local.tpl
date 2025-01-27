@echo off


if "%~1"=="unset" (
  call:unset_senv
  goto:eof
)

rem set "ECHOS_STACK=true"
rem ...
::##################################################
::  SET PROJECT VARIABLES
::##################################################
set SSH_CONFIG_ENTRY=centos8
doskey s="%project_dir%\src\setups\setup.bat" $*
set "CPLX_REPEAT_STEP="
rem set "CPLX_REPEAT_STEP=transfer-env-to-the-remote-project-folder"
set "CPLX_RESET_STEP="
rem set "CPLX_RESET_STEP=copy_the_sources"
set "CPLX_TOOL=python"
set "CPLX_TOOL_RC="
rem set "CPLX_TOOL_RC=1"

goto:eof


::##################################################
::  UNSET PROJECT VARIABLES IF REQUESTED
::##################################################
:unset_senv
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof