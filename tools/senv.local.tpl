@echo off


if "%~1"=="unset" (
  call:unset_senv
  goto:eof
)

rem set "ECHOS_STACK=true"
rem ...
goto:eof


::##################################################
::  UNSET PROJECT VARIABLES IF REQUESTED
::##################################################
:unset_senv
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof