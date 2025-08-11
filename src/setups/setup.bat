@echo off

setlocal enabledelayedexpansion

for %%i in ("%~dp0") do SET "setup_dir=%%~fi"
set "setup_dir=%setup_dir:~0,-1%"
call <NUL "%setup_dir%\..\..\senv.bat"

%_pre%  "----------------------------------------"
%_post% "----------------------------------------"
%_info% "Setup '%project_dir_name%'"

%_task% "Must setup '%project_dir_name%' with params '%*'"

if "%SSH_CONFIG_ENTRY%" == "" (
    %_fatal% "SSH_CONFIG_ENTRY is not defined (must be an SSH alias as alias to remote Linux server where a program is compiled)" 1
)
set "setup_prg=setup.sh"
if "%~1"=="packages" (
    set "setup_prg=setup_packages.sh"
    shift
)

if not "%setup_prg%"=="setup_packages.sh" goto:_not_setup_packages
if "%~1"=="" goto:_not_setup_packages

REM If the first argument starts with 'p_', it is a package name to pass to setup_packages.sh
echo.%~1 | findstr /b "p_" >nul
if not errorlevel 1 (
    set "pkg_param=%~1"
    REM Extract everything after the first two characters (p_)
    set "pkg_param=!pkg_param:~2!"
    %_info% "Package parameter detected: '!pkg_param!'"
    shift
)
if "%~1"=="" goto:_not_setup_packages
set reset_package=
if "%~1"=="reset" (
    %_task% "Must reset sync package"
    if not defined CPLX_TOOL ( fatal "CPLX_TOOL is not defined: Cannot reset last package setup list without a tool defined" 42 )
    del /f "%setup_dir%\pkgs\%CPLX_TOOL%\last" 2>NUL
    set reset_package=true
    shift
)
if "%~1"=="" goto:_not_setup_packages
if not defined reset_package ( "fatal: unknown set package param '%~1'. Only possible after the reset command: 'setup package reset xxx'" 43 )
%_task% "Must reset last processed setup package to '%~1' in last file '%setup_dir%\pkgs\%CPLX_TOOL%\last'"
echo %~1>"%setup_dir%\pkgs\%CPLX_TOOL%\last"
if errorlevel 1 (
    fatal "Unable to reset last processed setup package to '%~1' in last file '%setup_dir%\pkgs\%CPLX_TOOL%\last'" 44
)
%_ok% "Last processed setup package to '%~1' reset successfully in last file '%setup_dir%\pkgs\%CPLX_TOOL%\last'"

:_not_setup_packages
if not "%~1"=="" (
    bash.exe -c "steps_file="%project_dir_unix%/src/setups/steps.md"; export steps_file; "%project_dir_unix%/src/utils/steps.sh" repeat_or_reset_step %~1"
    if errorlevel 1 (
        %_fatal% "Unable to repeat or reset step '%~1' (r_xxx means reset, xxx means repeat)" 119
    )
)

if exist "%setup_dir%\pkgs.log" ( del /q "%setup_dir%\pkgs.log" )
if exist "%setup_dir%\setup.log" ( del /q "%setup_dir%\setup.log" )

REM Call bash with appropriate parameters based on whether a package was specified
if defined pkg_param (
    bash -c "steps_file="%project_dir_unix%/src/setups/steps.md"; export steps_file; $(cygpath -u '%setup_dir%')/%setup_prg% --package \"%pkg_param%\" %*"
) else (
    bash -c "steps_file="%project_dir_unix%/src/setups/steps.md"; export steps_file; $(cygpath -u '%setup_dir%')/%setup_prg% %*"
)

if errorlevel 1 (
    call:display_logs
    %_fatal% "Issue when calling '%setup_dir%\%setup_prg%'" 119
)
%_ok% "Setup '%project_dir_name%' done"
call:display_logs
goto:eof

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
