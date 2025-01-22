@echo off

for %%i in ("%~dp0") do SET "init_dir=%%~fi"
set "init_dir=%init_dir:~0,-1%"

REM https://stackoverflow.com/questions/57131654/using-utf-8-encoding-chcp-65001-in-command-prompt-windows-powershell-window
REM But should still work in Windows terminal (https://www.microsoft.com/p/windows-terminal/9n0dx20hk701, https://github.com/microsoft/terminal)
REM https://github.com/microsoft/terminal/blob/4a243f044572146e18e0051badb1b5b3f3c28ac8/src/tools/ansi-color/README.md?plain=1#L20-L22
REM https://github.com/microsoft/terminal/blob/4a243f044572146e18e0051badb1b5b3f3c28ac8/src/tools/ansi-color/ansi-color.cmd#L400-L448
REM For emojis support:
chcp 65001 >nul

if "%~1"=="unset" (
  call:unset_init
  goto:eof
)

set "okInit="
if not exist "%init_dir%\batcolors\echos.bat" (
    echo "WARN: Missing submodules"
    if not exist "%project_dir%\.gitmodules" (
      echo INFO: Executing  in %CD%' 'git submodule add -b legacy -- https://github.com/VonC/batcolors tools/batcolors'
      git config advice.addIgnoredFile false
      git submodule add -b legacy -- https://github.com/VonC/batcolors tools/batcolors
      if errorlevel 1 (
          echo FATAL: Submodule batcolors not properly added
          call:iExitBatch 6
      )
    ) else (
      echo INFO: Executing 'git submodule update --init in %CD%'
      git submodule update --init
      if errorlevel 1 (
          echo FATAL: Submodules not properly initialized
          call:iExitBatch 6
      )
    )
    call  "%init_dir%\batcolors\echos_macros.bat" export
    set "okInit=OK: Submodules initialized"
) else (
  call  "%init_dir%\batcolors\echos_macros.bat" export
  set "okInit=Submodule already initialized"
)
if not defined okInit (
  echo FATAL: Submodules not properly initialized
  call:iExitBatch 6
)
if defined okInit (
  if not defined QUIET_PRJ ( %_ok% "%okInit%" )
  set "okInit="
)

goto:eof

:iExitBatch - Cleanly exit batch processing, regardless how many CALLs
@echo off
if not exist "%temp%\ExitBatchYes.txt" call :ibuildYes
call :iCtrlC <"%temp%\ExitBatchYes.txt" 1>nul 2>&1
:iCtrlC
cmd /c exit -1073741510%1
goto:eof

:ibuildYes - Establish a Yes file for the language used by the OS
pushd "%temp%"
set "yes="
if exist ExitBatchYes.txt (
  del ExitBatchYes.txt
)
copy nul ExitBatchYes.txt >nul
for /f "delims=(/ tokens=2" %%Y in (
  '"copy /-y nul ExitBatchYes.txt <nul"'
) do if not defined yes set "yes=%%Y"
echo %yes%>ExitBatchYes.txt
popd
exit /b

:unset_init
set "okInit="
set "init_dir="
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof