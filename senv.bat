@echo off

::##################################################
::  DEFINE ALIASES (DOSKEY MACROS)
::##################################################
doskey a=all.bat $*
doskey b=build.bat $*
doskey d=deploy.bat $*
doskey r=run.bat $*
doskey t=test.bat $
doskey lsenv=%~dp0senv.bat local
doskey senv=%~dp0senv.bat $*
doskey psenv=%~dp0senv.bat $*
doskey hsenv=%HOME%\bin\senv.bat $*
doskey fsenv=%~dp0senv.bat force
doskey usenv=%~dp0senv.bat unset
doskey rsenv=%~dp0senv.bat restore
doskey u=updateChangelog.bat $*
doskey uf=cmd /V /C "set "RELFORCE=1" && updateChangelog.bat $*"

set "CHECK_QUIET_PRJ=echo %QUIET_PRJ% | findstr /C:true >nul ||"
set "CHECK_DEBUG_PRJ=echo %DEBUG_PRJ% | findstr /C:true >nul &&"


::##################################################
::  SET PROJECT DIRECTORY
::##################################################
for %%i in ("%~dp0") do SET "project_dir=%%~fi"
set "project_dir=%project_dir:~0,-1%"
cd "%project_dir%" || echo "unable to cd to '%project_dir%'"&& exit /b 1
for /f "tokens=* delims=\" %%i in ("%project_dir%") do SET "project_dir_name=%%~ni"

if "%~1"=="unset" (
  call:unset_senv
  goto:eof
)
if "%~1"=="restore" (
  call:unset_senv restore
  goto:eof
)

::##################################################
::  CALL BATCOLORS SCRIPT IF IT EXISTS
::##################################################
if exist "%project_dir%\tools\batcolors\echos_macros.bat" (
    call "%project_dir%\tools\batcolors\echos_macros.bat" export
)

::##################################################
::  SET PATH
::##################################################
call:set_path

::  ===============================================
::  DETERMINE LOCAL PATH
::  ===============================================
set "local_path="
set "local_path_msg="
set "force_project_path="
if "%~1"=="local" ( set "local_path=1" )
where get-version >NUL 2>&1
if not errorlevel 1 ( set "local_path=1" && set "local_path_msg= preserved")
if "%~1"=="force" ( set "local_path=" && set "local_path_msg=" && set "force_project_path=1" )
if defined local_path (
  set "local_path_msg=[local%local_path_msg%]"
)

::  ===============================================
::  CONFIGURE LOCAL PATH
::  ===============================================
if defined local_path (
  where get-version >NUL 2>&1
  if errorlevel 1 (
    set "PATH=%project_dir%\tools;%PATH%"
  )
  doskey gv=get-version
  doskey uv=update-version
  doskey uvr=update-version rel
)

::  ===============================================
::  UNSET LOCAL PATH
::  ===============================================
if not defined local_path (
  call:set_path
  doskey gv=
  doskey uv=
  doskey uvr=
)
set "local_path="

call:call_init

if not defined called_from_init (
  %_info% "project PATH '%PATH%'"
  if not "%PATH%"=="%project_path%" ( call:update_project_path_ini )
  %_ok% "project '%project_dir_name%' senv activated%local_path_msg%: project_dir='%project_dir%'"
)
set "called_from_init="
goto:eof

::##################################################
::  CALL INIT SCRIPT IF NOT CALLED FROM INIT
::##################################################
:call_init
if not defined called_from_init (
  set "called_from_env=1"
  call "%project_dir%\tools\init.bat" %~1
  set "called_from_init="
)
goto:eof

::##################################################
::  RETRIEVE OR COMPUTE PROJECT PATH
::##################################################
:set_path

::  ===============================================
::  CREATE PATH.INI IF IT DOES NOT EXIST
::  ===============================================
if not exist "%project_dir%\tools\path.ini" (
  echo [path]>"%project_dir%\tools\path.ini"
  echo   ori=%PATH%>>"%project_dir%\tools\path.ini"
)

if defined force_project_path ( goto:skip_read_path_ini )
call:read_path_ini project
if defined project_path (
  set "PATH=%project_path%"
  goto:eof
)

:skip_read_path_ini
set "force_project_path="
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
if exist "%HOME%\bin\senv.bat" ( set "project_path=%HOME%\bin;%project_path%" )
set "project_path=%project_dir%;%project_path%"
set "PATH=%project_path%"
call:update_project_path_ini
set "git_home="
%_info% "project_path(ini)='%project_path%'"
set "project_path="
goto:eof

::##################################################
::  UPDATE PROJECT PATH IN PATH.INI
::##################################################
:update_project_path_ini
findstr /R /C:"^  project=" "%project_dir%\tools\path.ini" >NUL 2>&1
if errorlevel 1 (
  echo record to ini
  echo   project=%PATH%>>"%project_dir%\tools\path.ini"
) else (
  sed.exe -i "s,^  project=.*,  project=%PATH:\=\\\\%,g" "%project_dir%\tools\path.ini"
  if errorlevel 1 (
    %_fatal% "sed.exe failed to update path.ini with PATH '%PATH%" 231
  )
  echo sed ok
)
goto:eof

::##################################################
::  READ PROJECT or ORI PATH FROM PATH.INI
::##################################################
:read_path_ini
set "project_path="
setlocal enabledelayedexpansion
for /f "usebackq tokens=1,2 delims==" %%a in ("%project_dir%\tools\path.ini") do (
  set "project_key=%%a"
  set "project_key=!project_key: =!"
  if "!project_key!"=="%~1%" (
    set "project_path=%%b"
    goto:project_path_found
  )
)
:project_path_found
set "project_key="
endlocal & set "project_path=%project_path%"
goto:eof


::##################################################
::  UNSET PROJECT VARIABLES IF REQUESTED
::##################################################
:unset_senv
if exist "%project_dir%\tools\batcolors\echos_macros.bat" (
  call "%project_dir%\tools\batcolors\echos_macros.bat" unset
)
call:call_init unset

if "%~1"=="restore" (
  call:read_path_ini ori
)

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

if "%~1"=="restore" (
  doskey a=
  doskey ast=
  doskey b=
  doskey bst=
  doskey d=
  doskey r=
  doskey t=
  doskey lsenv=
  doskey senv=
  doskey psenv=
  doskey hsenv=
  doskey fsenv=
  doskey usenv=
  doskey rsenv=
  doskey u=
  doskey uf=
  if exist "%HOME%\bin\senv.bat" ( call "%HOME%\bin\senv.bat" )
  if defined project_path (
    set "PATH=%project_path%"
  )
  del /Q /F "%project_dir%\tools\path.ini"
)
set "project_path="
set "project_dir="
set "CHECK_DEBUG_PRJ="
set "CHECK_QUIET_PRJ="

goto:eof