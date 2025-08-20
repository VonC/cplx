@echo off

for %%i in ("%~dp0") do SET "init_dir=%%~fi"
set "init_dir=%init_dir:~0,-1%"

REM https://stackoverflow.com/questions/57131654/using-utf-8-encoding-chcp-65001-in-command-prompt-windows-powershell-window
REM But should still work in Windows terminal (https://www.microsoft.com/p/windows-terminal/9n0dx20hk701, https://github.com/microsoft/terminal)
REM https://github.com/microsoft/terminal/blob/4a243f044572146e18e0051badb1b5b3f3c28ac8/src/tools/ansi-color/README.md?plain=1#L20-L22
REM https://github.com/microsoft/terminal/blob/4a243f044572146e18e0051badb1b5b3f3c28ac8/src/tools/ansi-color/ansi-color.cmd#L400-L448
REM For emojis support:
chcp 65001 >nul

if "%~1"=="unset" (
  call:unset_init
  goto:eof
)

set "okInit="

if not exist "%init_dir%\dev_workflow\init.bat" (
    echo WARN: Missing dev_workflow submodules
    if not exist "%init_dir%\..\.gitmodules" (
      echo INFO: Executing  in %CD%' 'git submodule add -b main -- https://github.com/VonC/senv_dev_workflow tools/dev_workflow'
      git -C "%init_dir%\.." config advice.addIgnoredFile false
      git -C "%init_dir%\.." submodule add -b main -- https://github.com/VonC/senv_dev_workflow tools/dev_workflow
      if errorlevel 1 (
          echo FATAL: Submodule batcolors not properly added
          call:iExitBatch 6
      )
    ) else (
      echo INFO: Executing 'git submodule update --init in %CD%'
      git submodule update --init
      if errorlevel 1 (
          echo FATAL: Submodules not properly initialized
          call:iExitBatch 6
      )
    )
    call "%init_dir%\dev_workflow\init.bat" "%~1"
    call  "%init_dir%\batcolors\echos_macros.bat" export
    set "okInit=OK: Submodules initialized"
) else (
  call "%init_dir%\dev_workflow\init.bat" "%~1"
  call  "%init_dir%\batcolors\echos_macros.bat" export
  set "okInit=Submodule already initialized"
)
if not defined okInit (
  echo FATAL: Submodules not properly initialized
  call:iExitBatch 6
)
if defined okInit (
  if not defined QUIET_PRJ ( %_ok% "%okInit%" )
  set "okInit="
)
goto:eof

:iExitBatch - Cleanly exit batch processing, regardless how many CALLs
@echo off
if not exist "%temp%\ExitBatchYes.txt" call :ibuildYes
call :iCtrlC <"%temp%\ExitBatchYes.txt" 1>nul 2>&1
:iCtrlC
cmd /c exit -1073741510%1
goto:eof

:ibuildYes - Establish a Yes file for the language used by the OS
pushd "%temp%"
set "yes="
if exist ExitBatchYes.txt (
  del ExitBatchYes.txt
)
copy nul ExitBatchYes.txt >nul
for /f "delims=(/ tokens=2" %%Y in (
  '"copy /-y nul ExitBatchYes.txt <nul"'
) do if not defined yes set "yes=%%Y"
echo %yes%>ExitBatchYes.txt
popd
exit /b

:unset_init
set "okInit="
set "init_dir="

set "PRJ_DIR_name="
set "local_path="
set "project_key="
set "git_home="
set "git_path="
set "batdir="
set "called_from_init="
set "called_from_env="
set "ccd="
set "err="
set "local_path_msg="
set "all_dir="

doskey ast=
doskey br=
doskey brel=
doskey bst=
doskey lsenv=
doskey senvle=
doskey senv=
doskey usenv=
doskey steps=
doskey props=
doskey uv=
doskey uvf=
doskey uc=
doskey gv=
doskey uvr=
doskey crel=

set "project_path="
set "CHECK_DEBUG_PRJ="
set "CHECK_QUIET_PRJ="
set "PRJ_REL_TITLE="
set "ECHOS_STACK="
set "echos_stack_emptied="

if exist "%PRJ_DIR%\senv.local.bat" (
  call:call_echos_stack & call "%PRJ_DIR%\senv.local.bat" unset
  call "%PRJ_DIR%\tools\batcolors\echos.bat" :unstack senv.bat
)

if exist "%PRJ_DIR%\tools\batcolors\echos_macros.bat" (
  call "%PRJ_DIR%\tools\batcolors\echos_macros.bat" unset
)

set "PRJ_DIR="
set "version="
set "version_release="
set "update-version_dir="
set "project_version="
set "is_dirty="
set "is_dirty_files="
set "is_snapshot="
set "git_describe="
set "git_is_snapshot="
set "git_is_release="
set "git_tag="
set "commit_count="
set "FORCE_UC="
set "REL_FORCE="
set "RELFORCE="
set "project_version="
set "project_title="
set "project_release_notes="
set "QUIET_PRJ="

goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%PRJ_DIR%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof
