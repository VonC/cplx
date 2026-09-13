@echo off
setlocal EnableExtensions DisableDelayedExpansion

pushd "%~dp0"
if errorlevel 1 exit /b 2

rem Refresh the project environment even when a caller inherited its guard.
for %%i in ("%CD%") do set "NO_MORE_SENV_%%~nxi="
call <NUL "%~dp0senv.bat"
set "check_exit=%ERRORLEVEL%"
if not "%check_exit%"=="0" goto :check_done

rem Use Git Bash explicitly; a Windows PATH may also expose WSL's bash.exe.
if not exist "%GH%\bin\bash.exe" (
    echo ERROR: Git Bash is unavailable in the project environment. >&2
    set "check_exit=2"
    goto :check_done
)

"%GH%\bin\bash.exe" src/utils/lint_shell.sh
rem Capture outside a block, then preserve the status across cleanup.
set "check_exit=%ERRORLEVEL%"

:check_done
popd
endlocal & exit /b %check_exit%
