@echo off

for %%i in ("%~dp0") do SET "run_dir=%%~fi"
call <NUL "%run_dir%\senv.bat"

%_info% "----------------------------------------"
%_info% "Run the project '%project_dir_name%'"
%_info% "----------------------------------------"

setlocal enabledelayedexpansion
set "params="
set "sp="
:loop
if "%~1"=="" goto end
    set "params=!params!!sp!%1"
    shift
    set "sp= "
    goto loop
)
:end
endlocal & set "params=%params%"
%_info% "params='%params%' for run"

%_task% "Start run of '%project_dir_name%' with params '%params%'"
set "file=%project_dir_name%-%version%"
set "cmd=echo%params% %file%"
%_info% cmd='%cmd%'

call <NUL :rrun
if not errorlevel 1 (
  %_ok% "project '%project_dir_name%' run successful"
) else (
  call:unset_run
  call "%~dp0tools\batcolors\echos.bat" :fatal "project '%project_dir_name%' run FAILED, code '%ERRORLEVEL%'" 3
)
call:unset_run
goto:eof

:rrun
%_info% "cmd='%cmd%' params '%params%'"
call <NUL %cmd% %params%
REM https://stackoverflow.com/questions/29887088/java-program-exit-with-code-130
set "err=%ERRORLEVEL%"
if "%err%" == "130" (
  %_warning% "Maven project interrupted by signal"
) else (
  REM Restore the original ERRORLEVEL if it is not 130
  exit /b %err%
)
goto:eof

:unset_run
set "cmd="
set "params="
set "sp="
set "file="
call "%run_dir%\senv.bat" unset
set "run_dir="
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof