@echo off
set "M2_HOME="
setlocal enabledelayedexpansion
rem goto:clean_path

for %%i in ("%~dp0.") do SET "script_dir=%%~fi"
for %%i in ("%script_dir%\..") do ( set "senv_dir=%%~fi" )
call %script_dir%\batcolors\echos_macros.bat

for /f "tokens=2 delims==" %%i in ('type "src\setups\setup.properties" ^| findstr /i /c:"tools_to_recompile"') do set "tools=%%i"

if "%1"=="" (
  %_info% "Current tool CPLX_TOOL='%CPLX_TOOL%', tools='%tools%'"
  exit /b 0
)

rem tools=git,python,mpdecimal,openssl111
rem Replace commas with spaces to iterate on each tool individually.
set "tools=%tools:,= %"
set "tool="
for %%i in (%tools%) do (
  set "tool=%%i"
  %_info% "Tool: '%%i' '!tool! vs. '!tool:%~1=!' (%~1)"
  if not "!tool:%~1=!"=="!tool!" (
    %_info% "Switching to tool '!tool!'"
    set "CPLX_TOOL=!tool!"
    %_info% "Current tool CPLX_TOOL='!CPLX_TOOL!'"
    goto:break
  )
)
:break
endlocal & set "CPLX_TOOL=%CPLX_TOOL%"
goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof