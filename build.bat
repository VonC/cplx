@echo off

::********************************************************************
:: Script Name:  build.bat
:: Description:  Builds the project and handles version updates.
::
:: Parameters:
::    %1 - Build parameters (e.g., rel, rel_title)
::
:: Usage:
::    build.bat rel
::    build.bat rel_title "Release Title"
::    build.bat prj_error: fail the build (for testing)
::
::    With aliases b or brel:
::    b rel
::    brel "rel_title=Initial project template"
::    brel a "e f" "rel_title=Initial project template" "g t h"
::    b a rel "e f" "rel_title=Initial project template" "g t h"
::    b a rel "e f" prj_error "rel_title=Initial project template" "g t h"
::
:: Return Value: 0 - Success, 1 - Error
::********************************************************************

::  ===============================================
::  INITIAL SETUP
::  ===============================================
for %%i in ("%~dp0") do SET "build_dir=%%~fi"
set "build_dir=%build_dir:~0,-1%"

call <NUL "%build_dir%\senv.bat"

::  ===============================================
::  PARSE PARAMETERS
::  ===============================================
setlocal enabledelayedexpansion
set "build_params="
set "build_params-uv="
set "sp="
set "sp-uv="
set "PRJ_REL_TITLE="
set "build_must_fail="
:loop
if "%~1"=="" goto:end
if "%~1"=="rel" (
    set "build_params-uv=!build_params-uv!!sp-uv!^"%~1^""
    set "sp-uv= "
) else (
    set "a_param=%~1"
    if "!a_param:rel_title=!" neq "!a_param!" (
      set "PRJ_REL_TITLE=!a_param:rel_title=!"
      set "PRJ_REL_TITLE=!PRJ_REL_TITLE:~1!"
      goto:continue
    )
    if "!a_param!"=="prj_error" (
      set "build_must_fail=fail"
      goto:continue
    )
    set "build_params=!build_params!!sp!^"%~1^""
    set "sp= "
)
:continue
shift
goto loop
:end
endlocal & set "build_params=%build_params%" & set "build_params-uv=%build_params-uv%" & set "PRJ_REL_TITLE=%PRJ_REL_TITLE%" & set "build_must_fail=%build_must_fail%"

set "build_params_echos="
if not defined build_params ( goto:build_params-uv_echos )
setlocal enabledelayedexpansion
  set "build_params_echos=%build_params:"=‟%"
endlocal & set "build_params_echos=%build_params_echos%"

:build_params-uv_echos
set "build_params-uv_echos="
if not defined build_params-uv ( goto:info_params )
  setlocal enabledelayedexpansion
  set "build_params-uv_echos=%build_params-uv:"=‟%"
endlocal & set "build_params-uv_echos=%build_params-uv_echos%"

:info_params
%_info% "build_params for build: '%build_params_echos%'"
%_info% "build_params for update-version (rel for 'make release'): '%build_params-uv_echos%'"
if defined PRJ_REL_TITLE (
  %_info% "Release title PRJ_REL_TITLE: '%PRJ_REL_TITLE%'"
)

::  ===============================================
::  UPDATE VERSION
::  ===============================================
call "%build_dir%\tools\update-version.bat" %build_params-uv%
if errorlevel 1 (
  call:build_unset
  call "%~dp0tools\batcolors\echos.bat" :fatal "update-version FAILED, code '%ERRORLEVEL%'" 3
  goto:eof
)
set "QUIET_PRJ=true"
call <NUL "%build_dir%\senv.bat"
set "QUIET_PRJ="

::  ===============================================
::  BUILD PROJECT
::  ===============================================
call "%project_dir%\tools\get-version.bat"
%_info% "----------------------------------------"
%_info% "Build the project '%project_dir_name%', version '%project_version%'"
%_info% "----------------------------------------"

mkdir "%project_dir%\target" 2>NUL
del /F /Q "%project_dir%\target\*.*" 2>NUL

%_task% "Start build of '%project_dir_name%' with build_params '%build_params_echos%'"
set "cmd=%build_must_fail%echo %build_params% build"
%_info% "%cmd:"=＂%"
call <NUL %cmd%> "%project_dir%\target\%project_dir_name%-%project_version%"
if not errorlevel 1 (
  %_ok% "project '%project_dir_name%' build successful"
  call:build_unset
) else (
  %_error% "project '%project_dir_name%' build FAILED for version '%project_version%'"
  call:has_a_release_just_been_made
  if defined a_release_has_just_been_made (
    set "a_release_has_just_been_made="
    call:reset_pre_release
  )
  call:build_unset
  call "%~dp0tools\batcolors\echos.bat" :fatal "project '%project_dir_name%' build FAILED, code '%ERRORLEVEL%'" 3
)
goto:eof

::##################################################
::  CHECK IF A RELEASE HAS JUST BEEN MADE
::##################################################
:has_a_release_just_been_made
set "a_release_has_just_been_made="

for /f "delims=" %%i in ('git tag --points-at HEAD') do (
    if "%%i"=="v%project_version%" (
        set "a_release_has_just_been_made=true"
        %_info% "[%~nx0] A release has just been made"
        goto:eof
    )
)
%_info% "[%~nx0] No release has been made"
goto:eof


::##################################################
::  RESET PRE-RELEASE BECAUSE BUILD FAILED
::##################################################
:reset_pre_release
%_task% "[%~nx0] Must reset pre-release state (build failed): git reset, git tag -d 'v%project_version%'"
git -C "%project_dir%" reset @~1
if errorlevel 1 ( %_fatal% "[%~nx0] Unable to reset hard to previous commit of '%project_dir%'" 311 )
%_ok% "[%~nx0] Git repository reset to previous commit"
git -C "%project_dir%" tag -d "v%project_version%"
if errorlevel 1 ( %_fatal% "[%~nx0] Unable to delete git tag 'v%project_version%' of '%project_dir%'" 312 )
%_ok% "[%~nx0] Git tag 'v%project_version%' deleted"
goto:eof


::##################################################
::  CLEANUP
::##################################################

:build_unset
set "cmd="
set "build_params="
set "build_params-uv="
set "SKIP_LOCAL="
call "%build_dir%\senv.bat" unset
set "build_dir="
set "PRJ_REL_TITLE="
set "build_must_fail="
set "called_from_build="
set "build_params_echos="
set "build_params-uv_echos="
set "params-uv="
set "a_release_has_just_been_made="
goto:eof