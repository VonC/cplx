@echo off

for %%i in ("%~dp0") do SET "PRJ_DIR=%%~fi"
set "PRJ_DIR=%PRJ_DIR:~0,-1%"
for %%i in ("%PRJ_DIR%") do SET "PRJ_DIR_NAME=%%~nxi"

if defined NO_MORE_SENV_%PRJ_DIR_NAME% ( goto:eof )

call "%PRJ_DIR%\tools\init.bat" "%~1"

doskey steps=bash -c "./steps.sh %1"
doskey props=bash -c "./properties.sh %1"
doskey sfa=bash -c "%PRJ_DIR_unix%/src/utils/steps_format_anchors.sh $1"
doskey i="%PRJ_DIR%/src/install/install.bat" $*
doskey irc="%PRJ_DIR%/src/install/install.bat" --reconfigure $*
doskey s="%PRJ_DIR%/src/setups/setup.bat" $*
doskey sp="%PRJ_DIR%/src/setups/setup.bat" packages $*
doskey scpe="%PRJ_DIR%/src/setups/setup.bat" "copy.*env" $*
doskey scps="%PRJ_DIR%/src/setups/setup.bat" "copy.*source" $*
doskey sdpl=cmd /V /C "set CPLX_FORCE_RELOAD_PACKAGES=1 && "%PRJ_DIR%/src/setups/setup.bat" packages "download_packages_list" $*"
doskey ic=cmd /V /C "set CPLX_INSTALL_COPY_ONLY=1 && "%PRJ_DIR%/src/install/install.bat""
doskey at="%PRJ_DIR%/tools/add_tool.bat" $*
doskey utm="%PRJ_DIR%/tools/git/update-tag-message.bat" $*

doskey st="%PRJ_DIR%/tools/switchtool.bat" $*

if "%~1"=="unset" (
  call:unset_senv
  goto:eof
)
%_unstack% senv.bat

if not defined GH (
  %_fatal% "GH must be define to reference Git HOME installation folder" 16
)
if not exist "%GH%\bin\git.exe" (
  %_fatal% "Git not found at '%GH%\bin\git.exe" 17
)

::  ===============================================
::  SET FINAL PROJECT PATH
::  ===============================================
set "project_path=C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\"
set "project_path=%GH%\bin;%GH%\cmd;%GH%\usr\bin;%GH%\mingw64\bin;%GH%\mingw64\libexec\git-core;%project_path%"
if exist "%USERPROFILE%\go\bin" ( set "project_path=%USERPROFILE%\go\bin;%project_path%" )
if exist "%HOME%\bin\senv.bat" ( set "project_path=%HOME%\bin;%project_path%" )
set "PATH=%project_path%"
if exist "%PRJ_DIR%\senv.local.bat" (
  %_stack_call% "%PRJ_DIR%\senv.local.bat" "%~1"
)
if defined local_path (
  set "PATH=%init_dir%;%PATH%"
)
set "PATH=%PRJ_DIR%;%PATH%"

if not defined QUIET_PRJ (  %_info% "project PATH '%PATH%'" )
if not defined QUIET_PRJ ( %_ok% "project '%PRJ_DIR_name%' senv activated%local_path_msg%: PRJ_DIR='%PRJ_DIR%', for tool '%CPLX_TOOL%'" )
if not defined CPLX_TOOL ( %_fatal% "CPLX_TOOL must be set: use 'st my_tool' to define it" 42 )
grep -q remove_done_markers "%PRJ_DIR%\.git\config" || git -C "%PRJ_DIR%" config --local "diff.remove_done_markers.textconv" "sed -E 's/\s+\(done: ✅\)//g'"

set "NO_MORE_SENV_%PRJ_DIR_NAME%=true"
goto:eof

::##################################################
::  UNSET PROJECT VARIABLES IF REQUESTED
::##################################################
:unset_senv
rem already done by line 3: `call %~dp0tools\init.bat "%~1"`
rem call "%PRJ_DIR%\tools\init.bat" unset
doskey sfa=
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%PRJ_DIR%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof
