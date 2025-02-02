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

for %%i in ("%~dp0") do SET "install_dir=%%~fi"
set "install_dir=%install_dir:~0,-1%"
for %%i in ("%~dp0..") do SET "src_dir=%%~fi"

for /f "tokens=* delims=" %%a in ('cygpath -u "%install_dir%"') do (
    SET "install_dir_unix=%%~a"
)
for /f "tokens=* delims=" %%a in ('cygpath -u "%src_dir%"') do (
    SET "src_dir_unix=%%~a"
)

for /f "tokens=* delims=" %%a in ('bash -c "source "${src_dir_unix}/utils/properties.sh"; properties_file="${src_dir_unix}/setups/setup.properties"; export properties_file; get_property services; export services; printf "%%s" $services"') do (
    SET "cplx_services=%%~a"
)
if not defined cplx_services (
    %_fatal% "cplx_services is not defined in '%src_dir_unix%/utils/properties'" 1
)

if "%CPLX_TOOL%" == "" ( set "CPLX_TOOL=%~1" )
if "%CPLX_TOOL%" == "" (
    %_fatal% "CPLX_TOOL is not defined (must be one of '%cplx_services%')" 2
)
if "%CPLX_VERSION%" == "" ( set "CPLX_VERSION=%~2" )
if "%CPLX_VERSION%" == "" (
    %_fatal% "CPLX_VERSION is not defined (must be one of '%cplx_services%')" 3
)

rem echo "install_dir_unix='%install_dir_unix%', src_dir_unix='%src_dir_unix%'"
for /f "tokens=* delims=" %%a in ('bash -c "source "${src_dir_unix}/utils/properties.sh"; properties_file="${src_dir_unix}/setups/setup.properties"; export properties_file; get_property cplx_path; export cplx_path; printf "%%s" $cplx_path"') do (
    SET "cplx_path=%%~a"
)
if not defined cplx_path (
    %_fatal% "cplx_path is not defined in '%src_dir_unix%/utils/properties'" 4
)

scp -r "%install_dir_unix%/env/." %SSH_CONFIG_ENTRY%:%cplx_path%/tools/
ssh %SSH_CONFIG_ENTRY% "cd %cplx_path%/tools && chmod 755 ./install && bash ./install %CPLX_TOOL% %CPLX_VERSION%; echo $?" | tee "%install_dir%\temp.txt"
FOR /F "delims=" %%i IN ("%install_dir%\temp.txt") DO SET "lastLine=%%i"
%_info% "vvvvvvvvvvvvvvvvvvvvvvvvvvv"
%_info% "Exit status: %lastLine%"
%_info% "^^^^^^^^^^^^^^^^^^^^^^^^^^^"
scp "%SSH_CONFIG_ENTRY%:%cplx_path%/tools/python/log" "%install_dir_unix%/log"
if not errorlevel 1 (
    start /b "VSCode" "%PRGS%\vscodes\current\bin\code.cmd" "%install_dir%\log"
) else (
    %_warning% "Failed to open log file at '%install_dir%'"
)
if not %lastLine%==0 ( tail -10 "%install_dir%\temp.txt" && %_fatal% "Installation failed" 5 )
%_ok% "Installation executed"

goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof