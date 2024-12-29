@echo off
setlocal enableextensions enabledelayedexpansion

set "QUIET_PRJ=true"
call <NUL "%~dp0..\senv.bat"
set "QUIET_PRJ="

if not exist "%project_dir%\version.txt" (
  set "project_version=0.1.0-SNAPSHOT"
  echo !project_version!>"%project_dir%\version.txt"
  goto:eof
)
@echo on
for /f "usebackq tokens=* delims=" %%i in ("%project_dir%\version.txt") do SET "project_version=%%i"
endlocal & set "project_version=%project_version%"
goto:eof