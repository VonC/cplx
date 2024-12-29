@echo off
::********************************************************************
:: Script Name:  get-version.bat
:: Description:  Retrieves or initializes the project version.
::
:: Parameters:   None
::
:: Usage:        get-version.bat
::
:: Returns:      Sets the 'project_version' variable.
::********************************************************************

setlocal enableextensions enabledelayedexpansion

::  ===============================================
::  INITIALIZE PROJECT VARIABLE AND PATH
::  ===============================================
set "QUIET_PRJ=true"
call <NUL "%~dp0..\senv.bat"
set "QUIET_PRJ="

::  ===============================================
::  CHECK IF VERSION FILE EXISTS
::  ===============================================
if not exist "%project_dir%\version.txt" (
  ::  ===============================================
  ::  INITIALIZE DEFAULT VERSION
  ::  ===============================================
  set "project_version=0.1.0-SNAPSHOT"
  echo !project_version!>"%project_dir%\version.txt"
  goto:eof
)

::  ===============================================
::  READ VERSION FROM FILE
::  ===============================================
for /f "usebackq tokens=* delims=" %%i in ("%project_dir%\version.txt") do SET "project_version=%%i"
endlocal & set "project_version=%project_version%"
goto:eof