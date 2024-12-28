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
call "%all_dir%\senv.bat" unset
set "all_dir="
set "barg="
