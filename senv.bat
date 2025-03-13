@echo off

call %~dp0tools\init.bat "%~1"
doskey steps=bash -c "./steps.sh %1"
doskey props=bash -c "./properties.sh %1"
doskey sfa=bash -c "%project_dir_unix%/src/utils/steps_format_anchors.sh $1"
doskey i="%project_dir%/src/install/install.bat" $*
doskey s="%project_dir%/src/setups/setup.bat" $*
doskey sp="%project_dir%/src/setups/setup.bat" packages $*
doskey scpe="%project_dir%/src/setups/setup.bat" "copy.*env" $*
doskey ic=cmd /V /C "set CPLX_INSTALL_COPY_ONLY=1 && "%project_dir%/src/install/install.bat""
doskey at="%project_dir%/tools/add_tool.bat" $*
doskey utm="%project_dir%/tools/git/update-tag-message.bat" $*

doskey st="%project_dir%/tools/switchtool.bat" $*

if "%~1"=="unset" (
  call:unset_senv
  goto:eof
)
%_unstack% senv.bat

if not defined QUIET_PRJ (  %_info% "project PATH '%PATH%'" )
if not defined QUIET_PRJ ( %_ok% "project '%project_dir_name%' senv activated%local_path_msg%: project_dir='%project_dir%', for tool '%CPLX_TOOL%'" )
grep -q remove_done_markers "%project_dir%\.git\config" || git -C "%project_dir%" config --local "diff.remove_done_markers.textconv" "sed -E 's/\s+\(done: ✅\)//g'"
goto:eof

::##################################################
::  UNSET PROJECT VARIABLES IF REQUESTED
::##################################################
:unset_senv
rem already done by line 3: `call %~dp0tools\init.bat "%~1"`
rem call "%project_dir%\tools\init.bat" unset
doskey sfa=
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof