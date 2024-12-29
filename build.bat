@echo off

for %%i in ("%~dp0") do SET "build_dir=%%~fi"
call <NUL "%build_dir%\senv.bat"

%_info% "----------------------------------------"
%_info% "Build the project '%project_dir_name%'"
%_info% "----------------------------------------"

set "params=%*"
%_info% "Params for build: '%params%'"

if not defined called_from_update-version (
  call "%build_dir%\tools\update-version.bat"
)
set "called_from_update-version="

%_task% "Start build of '%project_dir_name%' with params '%params%'"
set "cmd=echo%params% build"
%_info% "%cmd%"
call <NUL %cmd%
if not errorlevel 1 (
  %_ok% "project '%project_dir_name%' build successful"
) else (
  call:build_unset
  call "%~dp0tools\batcolors\echos.bat" :fatal "project '%project_dir_name%' build FAILED, code '%ERRORLEVEL%'" 3
)

:build_unset
set "cmd="
set "params="
set "SKIP_LOCAL="
call "%build_dir%\senv.bat" unset
set "build_dir="
rem goto:eof