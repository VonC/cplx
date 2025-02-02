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
if not exist "%init_dir%\batcolors\echos.bat" (
    echo "WARN: Missing submodules"
    if not exist "%project_dir%\.gitmodules" (
      echo INFO: Executing  in %CD%' 'git submodule add -b legacy -- https://github.com/VonC/batcolors tools/batcolors'
      git config advice.addIgnoredFile false
      git submodule add -b legacy -- https://github.com/VonC/batcolors tools/batcolors
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
    call  "%init_dir%\batcolors\echos_macros.bat" export
    set "okInit=OK: Submodules initialized"
) else (
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

::##################################################
::  SET PROJECT DIRECTORY
::##################################################
for %%i in ("%~dp0..") do SET "project_dir=%%~fi"
for /f "tokens=* delims=\" %%i in ("%project_dir%") do SET "project_dir_name=%%~ni"
for /f "tokens=* delims=" %%i in ('cygpath -u "%project_dir%"') do SET "project_dir_unix=%%~i"

::##################################################
::  DEFINE ALIASES (DOSKEY MACROS)
::##################################################
doskey a=all.bat $*
doskey b=build.bat $*
doskey brel=build.bat rel $*
doskey br=build.bat rel $*
doskey d=deploy.bat $*
doskey r=run.bat $*
doskey t=test.bat $*
doskey s=setup.bat $*
doskey lsenv="%project_dir%\senv.bat" local
doskey fsenv="%project_dir%\senv.bat" force
doskey senvle="%PRGS%\vscodes\current\bin\code.cmd" "%~dp0senv.local.bat"
doskey senv="%project_dir%\senv.bat" $*
doskey psenv="%project_dir%\senv.bat" $*
doskey hsenv=%HOME%\bin\senv.bat $*
doskey hlsenv=%HOME%\bin\lsenv.bat $*
doskey usenv="%project_dir%\senv.bat" unset

doskey cdcp=cd /d "%project_dir%"
doskey cdp=cd /d "%project_dir%"

doskey gv=get-version
doskey uv="%project_dir%\tools\update-version.bat"
doskey uvr="%project_dir%\tools\update-version" rel
doskey uvf=cmd /V /C "set "FORCE_UC=1" && "%project_dir%\tools\update-version.bat" $*"
doskey uc="%project_dir%\tools\update-changelog.bat" $*
doskey crel=bash -c "git tag --sort=-creatordate | head -n 1 | xargs -I {} sh -c 'git reset $(git rev-list -n 1 {}^); git tag -d {}'"

set "CHECK_QUIET_PRJ=echo %QUIET_PRJ% | findstr /C:true >nul ||"
set "CHECK_DEBUG_PRJ=echo %DEBUG_PRJ% | findstr /C:true >nul &&"

set "filter_smudge="
for /f "tokens=* delims=" %%i in ('git config filter."changelog".smudge') do SET "filter_smudge=%%~ni"
if not defined filter_smudge (
  %_task% "Must set git config filter.changelog filter for changelog diff"
  git config filter.changelog.smudge "cat"
  git config filter.changelog.clean "sed -E 's/(## \[v.*?-SNAPSHOT unreleased\].*-).*$/\1/'"
  if errorlevel 1 (
    %_fatal% "git config filter.changelog filters failed for changelog diff" 231
  )
  %_ok% "git config filter.changelog filters set for changelog diff"
)

::  ===============================================
::  CONFIGURE LOCAL PATH MESSAGE
::  ===============================================
set "local_path="
set "local_path_msg="
if "%~1"=="local" ( set "local_path=1" )
echo "%PATH%" | findstr /C:"%init_dir%" >NUL 2>&1
if not errorlevel 1 ( set "local_path=1" && set "local_path_msg= preserved")
if defined local_path (
  set "local_path_msg= [local%local_path_msg%]"
)
if "%~1"=="force" (
  set "local_path_msg="
  set local_path=
)


::  ===============================================
::  CHECK FOR GIT.EXE IN PATH
::  ===============================================
where git.exe >NUL 2>&1
if errorlevel 1 (
  %_fatal% "git.exe not found in PATH, needed for project '%project_dir_name%'" 231
)

::  ===============================================
::  SET GIT HOME DIRECTORY
::  ===============================================
set "git_home="
setlocal enabledelayedexpansion
set "git_path="
for /f "tokens=* delims=" %%a in ('where git.exe') do (
  set "git_path=%%~dpa"
  set "git_path=!git_path:~0,-1!"
  if not "!git_path:\bin=!"=="!git_path!" (
    if "!git_path:\mingw64=!"=="!git_path!" ( goto:git_path_found )
  )
  set "git_path="
)
:git_path_found
endlocal & set "git_home=%git_path:~0,-4%"
rem echo === git_home='%git_home%'

::  ===============================================
::  SET FINAL PROJECT PATH
::  ===============================================
set "project_path=C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\"
set "project_path=%git_home%\bin;%git_home%\cmd;%git_home%\usr\bin;%git_home%\mingw64\bin;%git_home%\mingw64\libexec\git-core;%project_path%"
if exist "%USERPROFILE%\go\bin" ( set "project_path=%USERPROFILE%\go\bin;%project_path%" )
if exist "%HOME%\bin\senv.bat" ( set "project_path=%HOME%\bin;%project_path%" )
set "PATH=%project_path%"
if exist "%project_dir%\senv.local.bat" (
  %_stack_call% "%project_dir%\senv.local.bat" "%~1"
)
if defined local_path (
  set "PATH=%init_dir%;%PATH%"
)
set "PATH=%project_dir%;%PATH%"
set "git_home="


::##################################################
::  RETRIEVE OR COMPUTE PROJECT PATH
::##################################################

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

set "project_dir_name="
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

if exist "%project_dir%\senv.local.bat" (
  call:call_echos_stack & call "%project_dir%\senv.local.bat" unset
  call "%project_dir%\tools\batcolors\echos.bat" :unstack senv.bat
)

if exist "%project_dir%\tools\batcolors\echos_macros.bat" (
  call "%project_dir%\tools\batcolors\echos_macros.bat" unset
)

set "project_dir="
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
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof