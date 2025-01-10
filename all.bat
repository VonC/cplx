@echo off

if "%1" == "rel" ( 
    set "barg=rel"
    shift
)

for %%i in ("%~dp0") do SET "all_dir=%%~fi"

call <NUL "%all_dir%\build.bat" %barg% %*
if errorlevel 1 (
    call:unset_all
    exit /b 1
)

for %%i in ("%~dp0") do SET "all_dir=%%~fi"
call "%all_dir%\senv.bat"
%_task% "Start project '%project_dir_name%' run"
call <NUL "%all_dir%\run.bat" %*
if errorlevel 1 (
    call:unset_all
    exit /b 1
)
call:unset_all
goto:eof

:unset_all
for %%i in ("%~dp0") do SET "all_dir=%%~fi"
call "%all_dir%\senv.bat" unset
set "all_dir="
set "barg="

:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof