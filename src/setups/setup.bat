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
bash -c "$(cygpath -u '%setup_dir%')setup.sh %*"