@echo off
setlocal DisableDelayedExpansion
for %%I in ("%~dp0..\..") do set "launcher_repo=%%~fI"
if not exist "%GH%\bin\bash.exe" call <NUL "%launcher_repo%\senv.bat"
if not exist "%GH%\bin\bash.exe" exit /b 2
set "launcher_bash=%GH%\bin\bash.exe"
set "launcher_root=%TEMP%\cplx-architecture-launcher-%RANDOM%-%RANDOM%"
if exist "%launcher_root%" exit /b 2
mkdir "%launcher_root%"
if errorlevel 1 exit /b 2
set "launcher_fixture=%launcher_root%"
"%launcher_bash%" "%~dp0verify.architecture-progress.sh" --launcher-stage "%launcher_root%" "%launcher_repo%"
if errorlevel 1 goto:failed
set "PATH=%GH%\bin;%PATH%"

call:case reset 0
if errorlevel 1 goto:failed
call:case after 0
if errorlevel 1 goto:failed
call:case direct 0
if errorlevel 1 goto:failed
call:case conflict 119
if errorlevel 1 goto:failed
call:case repeat 0
if errorlevel 1 goto:failed
call:case reset_step 0
if errorlevel 1 goto:failed
set "CPLX_FORCE_RELOAD_PACKAGES=1"
call:case sdpl 0
if errorlevel 1 goto:failed
set "CPLX_FORCE_RELOAD_PACKAGES="
call:case literal 0
if errorlevel 1 goto:failed
call:case literal_after 0
if errorlevel 1 goto:failed
set "launcher_endpoint_status=116"
call:case bash_failure 119
if errorlevel 1 goto:failed
set "launcher_endpoint_status="
set "launcher_helper_status=3"
call:case helper_failure 119
if errorlevel 1 goto:failed
set "launcher_helper_status="
echo PASS: real CMD launcher arguments, step helpers, reset and failure boundaries
set "launcher_result=0"
goto:cleanup

:case
set "launcher_case=%~1"
set "launcher_expected=%~2"
REM The generated driver owns each literal command, avoiding CALL re-expansion.
"%launcher_bash%" "%~dp0verify.architecture-progress.sh" --launcher-driver "%launcher_root%" "%launcher_case%"
if errorlevel 1 exit /b 1
cmd /d /c "%launcher_root%\driver.cmd" > "%launcher_root%\case.log" 2>&1
set "launcher_actual=%errorlevel%"
if not "%launcher_actual%"=="%launcher_expected%" (
    type "%launcher_root%\case.log"
    echo FAIL: %launcher_case% exit=%launcher_actual% expected=%launcher_expected%
    exit /b 1
)
"%launcher_bash%" "%~dp0verify.architecture-progress.sh" --launcher-check "%launcher_root%" "%launcher_case%"
if errorlevel 1 exit /b 1
echo PASS: CMD %launcher_case%
exit /b 0

:failed
set "launcher_result=1"
:cleanup
REM Bash validates the owned absolute fixture path before recursive removal.
"%launcher_bash%" "%~dp0verify.architecture-progress.sh" --launcher-clean "%launcher_root%"
if errorlevel 1 exit /b 1
exit /b %launcher_result%
