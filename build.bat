@echo off

for %%i in ("%~dp0") do SET "build_dir=%%~fi"

if defined called_from_update-version ( set "QUIET_PRJ=true" )
call <NUL "%build_dir%\senv.bat"
set "QUIET_PRJ="

setlocal enabledelayedexpansion
set "params="
set "params-uv="
set "sp="
set "sp-uv="
:loop
if "%~1"=="" goto end
if "%~1"=="rel" (
    set "params-uv=!params-uv!!sp-uv!%1"
    set "sp-uv= "
) else (
    set "params=!params!!sp!%1"
    set "sp= "
)
shift
goto loop
:end
endlocal & set "params=%params%" & set "params-uv=%params-uv%"
%_info% "Params for build: '%params%'"
%_info% "Params for update-version (rel for 'make release'): '%params-uv%'"

set "build_msg="
set "failed_update-version="
if not defined called_from_update-version (
  set "has_been_called_from_update-version="
  set "called_from_build=true"
  call "%build_dir%\tools\update-version.bat" %params-uv%
  if errorlevel 1 (
    set "failed_update-version=true"
  )
  set "QUIET_PRJ=true"
  call <NUL "%build_dir%\senv.bat"
  set "QUIET_PRJ="
) else (
  %_info% "Build Called from update-version"
  set "build_msg= (from update-version)"
)
set "called_from_update-version="

if defined has_been_called_from_update-version (
  %_ok% "Build already called from update-version, no need to build twice"
  set "has_been_called_from_update-version="
  call:build_unset
  goto:eof
)

if defined failed_update-version (
  call:build_unset
  call "%~dp0tools\batcolors\echos.bat" :fatal "update-version FAILED, code '%ERRORLEVEL%'" 3
  goto:eof
)

%_info% "----------------------------------------"
%_info% "Build the project '%project_dir_name%'%build_msg%"
%_info% "----------------------------------------"
set "build_msg="

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
set "params-uv="
set "SKIP_LOCAL="
call "%build_dir%\senv.bat" unset
set "build_dir="
goto:eof