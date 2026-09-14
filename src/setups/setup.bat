@echo off

setlocal DisableDelayedExpansion

for %%i in ("%~dp0") do SET "setup_dir=%%~fi"
set "setup_dir=%setup_dir:~0,-1%"
call <NUL "%setup_dir%\..\..\senv.bat"
if errorlevel 1 exit /b 119
setlocal DisableDelayedExpansion

%_pre%  "----------------------------------------"
%_post% "----------------------------------------"
%_info% "Setup '%project_dir_name%'"

%_task% "Must setup '%project_dir_name%'"

if "%SSH_CONFIG_ENTRY%" == "" (
    %_fatal% "SSH_CONFIG_ENTRY is not defined (must be an SSH alias as alias to remote Linux server where a program is compiled)" 1
    exit /b 1
)
set "setup_prg=setup.sh"
set "pkg_param="
set "reset_package="
set "after_entry="
set "step_param="
if not "%~1"=="packages" goto:parse_step
set "setup_prg=setup_packages.sh"
shift
if "%~1"=="" goto:parsed
if "%~1"=="reset" goto:parse_reset
set "pkg_param=%~1"
if not "%pkg_param:~0,2%"=="p_" goto:package_step
REM Consume the direct package expression once, with delayed expansion disabled.
set "pkg_param=%pkg_param:~2%"
if not defined pkg_param goto:invalid_arguments
shift
if not "%~1"=="" goto:invalid_arguments
goto:parsed

:parse_reset
set "reset_package=1"
shift
if "%~1"=="" goto:parsed
set "after_entry=%~1"
shift
if not "%~1"=="" goto:invalid_arguments
goto:parsed

:package_step
set "pkg_param="
:parse_step
set "step_param=%~1"
if "%~1"=="" goto:parsed
shift
if not "%~1"=="" goto:invalid_arguments

:parsed
set "steps_file=%project_dir_unix%/src/setups/steps.md"
if not defined step_param goto:run_setup
REM Preserve generic repeat/reset, including sdpl and packages download_packages_list.
bash.exe "%setup_dir%\..\utils\steps.sh" repeat_or_reset_step "%step_param%"
if errorlevel 1 (
    %_fatal% "Unable to repeat or reset step (r_xxx means reset, xxx means repeat)" 119
    exit /b 119
)

:run_setup

if exist "%setup_dir%\pkgs.log" ( del /q "%setup_dir%\pkgs.log" )
if exist "%setup_dir%\setup.log" ( del /q "%setup_dir%\setup.log" )

REM Direct argv preserves literal package expressions without another shell parse.
if defined pkg_param goto:run_package
if defined after_entry goto:run_after_entry
if defined reset_package goto:run_reset
bash.exe "%setup_dir%\%setup_prg%"
goto:setup_result
:run_package
bash.exe "%setup_dir%\%setup_prg%" --package "%pkg_param%"
goto:setup_result
:run_after_entry
bash.exe "%setup_dir%\%setup_prg%" --reset-list --after-entry "%after_entry%"
goto:setup_result
:run_reset
bash.exe "%setup_dir%\%setup_prg%" --reset-list

:setup_result
if errorlevel 1 (
    call:display_logs
    %_fatal% "Issue when calling '%setup_dir%\%setup_prg%'" 119
    exit /b 119
)
%_ok% "Setup '%project_dir_name%' done"
call:display_logs
goto:eof

:invalid_arguments
%_fatal% "Invalid setup arguments: use packages p_name, packages reset [entry], or one step name" 119
exit /b 119

:display_logs
set "flog="
if exist "%setup_dir%\pkgs.log" ( set "flog=%setup_dir%\pkgs.log" )
if exist "%setup_dir%\setup.log" ( set "flog=%setup_dir%\setup.log" )
if defined flog (
    %_task% "Must display '%flog%'"
    set VSCODE_DEV=
    set ELECTRON_RUN_AS_NODE=1
    rem cmd /C start /B "C:\Users\vonc\prgs\vscodes\current\bin\code.cmd" "%flog%"
    "%PRGS%\vscodes\current\Code.exe" "%PRGS%\vscodes\current\resources\app\out\cli.js" "%flog%"
    if errorlevel 1 (
        %_fatal% "Unable to display '%flog%'" 122
    )
    %_ok% "Display '%flog%' done"
    powershell -NoProfile -ExecutionPolicy Bypass -File "%setup_dir%\..\utils\alt_tab.ps1"
)
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof
