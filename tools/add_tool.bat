@echo off

for %%i in ("%~dp0") do SET "add_tool_dir=%%~fi"
set "add_tool_dir=%add_tool_dir:~0,-1%"

goto:eof

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof