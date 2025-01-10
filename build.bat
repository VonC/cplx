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
::    build.bat rel "rel_title=Release Title"
::    build.bat prj_error: fail the build (for testing)
::
::    With aliases b or brel:
::    b a b "cc dd" "rel_title=my title" "ee ff" gg    # no release made, rel missing
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

call "%build_dir%\tools\t_build.bat" :pre-processing %*

::  ===============================================
::  BUILD PROJECT
::  ===============================================
%_stack_call% "%project_dir%\tools\get-version.bat"
%_info% "----------------------------------------"
%_info% "Build the project '%project_dir_name%', version '%project_version%'"
%_info% "----------------------------------------"

mkdir "%project_dir%\target" 2>NUL
del /F /Q "%project_dir%\target\*.*" 2>NUL

%_task% "Start build of '%project_dir_name%' with build_params '%build_params_echos%'"
set "cmd=%build_dir%\src\setups\setup.bat"
%_info% "%cmd:"=＂%"
set "QUIET_PRJ=true"
call <NUL %cmd% %build_params%
set "build_status=%ERRORLEVEL%"
set "QUIET_PRJ=true"
call "%build_dir%\tools\t_build.bat" :post-processing %build_status%
call:build_unset
goto:eof


::##################################################
::  CLEANUP
::##################################################

:build_unset
set "cmd="
call "%build_dir%\senv.bat" unset
call "%build_dir%\tools\t_build.bat" :build_unset
set "build_dir="
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof