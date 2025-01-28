@echo off
setlocal DisableDelayedExpansion

for %%i in ("%~dp0") do SET "install_dir=%%~fi"
call <NUL "%install_dir%\..\..\senv.bat"

%_info% "----------------------------------------"
%_info% "Install '%project_dir_name%'"
%_info% "----------------------------------------"

%_task% "Must install '%project_dir_name%' with params '%*'"

if "%SSH_CONFIG_ENTRY%" == "" (
    %_fatal% "SSH_CONFIG_ENTRY is not defined (must be an SSH alias as alias to remote Linux server where a program is compiled)" 1
)

if "%CPLX_TOOL%" == "" (
    %_fatal% "CPLX_TOOL is not defined (must be one of )" 1
)
for %%i in ("%~dp0") do SET "script_dir=%%~fi"

scp "%script_dir%/install" %SSH_CONFIG_ENTRY%:%project_path%/install
ssh %SSH_CONFIG_ENTRY% "cd %project_path% && chmod 755 ./install && bash %project_path%/install; echo $?" | tee "%install_dir%\temp.txt"
FOR /F "delims=" %%i IN (temp.txt) DO SET "lastLine=%%i"
%_info% "vvvvvvvvvvvvvvvvvvvvvvvvvvv"
%_info% "Exit status: %lastLine%"
%_info% "^^^^^^^^^^^^^^^^^^^^^^^^^^^"
scp "%SSH_CONFIG_ENTRY%:%project_path%/log" log
start /b "VSCode" "%vscodei%\bin\code.cmd" log
if not %lastLine%==0 (
    %_fatal% "Installation failed" 2
)
%_ok% "Installation executed"

goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof