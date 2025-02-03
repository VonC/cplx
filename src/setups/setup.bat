@echo off

setlocal enabledelayedexpansion

for %%i in ("%~dp0") do SET "setup_dir=%%~fi"
call <NUL "%setup_dir%\..\..\senv.bat"

%_info% "----------------------------------------"
%_info% "Setup '%project_dir_name%'"
%_info% "----------------------------------------"

%_task% "Must setup '%project_dir_name%' with params '%*'"

if "%SSH_CONFIG_ENTRY%" == "" (
    %_fatal% "SSH_CONFIG_ENTRY is not defined (must be an SSH alias as alias to remote Linux server where a program is compiled)" 1
)
set "setup_prg=setup.sh"
if "%~1"=="packages" (
    set "setup_prg=setup_packages.sh"
    shift
)

if not "%~1"=="" (
    bash.exe -c "steps_file="%project_dir_unix%/src/setups/steps.md"; export steps_file; "%project_dir_unix%/src/utils/steps.sh" repeat_or_reset_step %~1"
    if errorlevel 1 (
        %_fatal% "Unable to repeat or reset step '%~1'" 119
    )
)
    
bash -c "steps_file="%project_dir_unix%/src/setups/steps.md"; export steps_file; $(cygpath -u '%setup_dir%')%setup_prg% %*"
if errorlevel 1 (
    %_error% "Issue when calling '%setup_dir%\%setup_prg%'"
    exit /b 119
)
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof