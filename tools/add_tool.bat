@echo off
::==============================================================================
:: Tool Configuration Wizard
::==============================================================================
:: This script facilitates the addition and configuration of new development 
:: tools within the CPLX environment. It provides an interactive wizard that 
:: guides the user through tool setup and ensures proper integration with the
:: environment configuration files (senv.local.tpl and senv.local.bat).
::
:: The wizard handles:
:: - Tool name selection/validation
:: - Configuration template creation
:: - Updating configuration files
:: - Extracting and setting tool-specific variables
::==============================================================================

for %%i in ("%~dp0") do SET "add_tool_dir=%%~fi"
set "add_tool_dir=%add_tool_dir:~0,-1%"
for %%i in ("%~dp0..") do SET "cplx_dir=%%~fi"

call :main
goto:eof

::------------------------------------------------------------------------------
:: Main Process Function
::------------------------------------------------------------------------------
:: Orchestrates the overall tool addition process by coordinating the wizard
:: flow, from initial setup through configuration generation and application.
::
:: This function manages state transitions and ensures all configuration steps
:: complete successfully or exit gracefully on failure.
::------------------------------------------------------------------------------
:main
%_info% "Processing new tool addition"
if not exist "%PRGS%\gums\current\gum.exe" (
  %_fatal% "gum.exe is not installed in '%PRGS%\gums\current'" 21
)
set "gum=%PRGS%\gums\current\gum.exe"
:: Style the header
"%gum%" style --foreground 212 "🧰 Tool Configuration Wizard" --bold --underline

setlocal EnableDelayedExpansion
:: Step 1: Tool name selection
if not defined CPLX_TOOL_NEW (
    "%gum%" style --foreground 45 "Step 1: Name a new tool (CPLX_TOOL_NEW is empty)"
    "%gum%" style --foreground 254 "Enter new tool name:"
    for /f "tokens=*" %%a in ('%gum% input --placeholder "Tool name"') do (
      set "_raw_input=%%a"
      echo __%_raw_input%__
      for /f "tokens=*" %%b in ('echo !_raw_input! ^| awk "{gsub(/^[[:space:]]+|[[:space:]]+$/, \"\"); print}"') do (
        set "CPLX_TOOL_NEW=%%b"
      )
    )

    if "!CPLX_TOOL_NEW!"=="" (
        "%gum%" style --foreground 196 "Tool selection cancelled"
        exit /b 1
    )
) else (
    call:gum_echo --foreground 45 "Using existing tool: '" --foreground 226 "!CPLX_TOOL_NEW!" --foreground 45 "'"
)

rem echo grep -E "CPLX_TOOL.*%CPLX_TOOL_NEW%" "%add_tool_dir%\senv.local.tpl" ^>nul 2^>^&1
grep -E "CPLX_TOOL.*%CPLX_TOOL_NEW%" "%add_tool_dir%\senv.local.tpl" >nul 2>&1
if not errorlevel 1 (
  "%gum%" style --foreground 82 "✓ '%add_tool_dir%\senv.local.tpl' already includes a '%CPLX_TOOL_NEW%' section"
  goto:update_senv_local
)
(
echo if "%%CPLX_TOOL%%" == "%CPLX_TOOL_NEW%" ^(
echo   set "CPLX_VERSION=_tbd_%CPLX_TOOL_NEW%"
echo   rem https://
echo   set "CPLX_URL=%CPLX_URL%"
echo   set "CPLX_CHECK_PREFIX=lib/aa"
echo   set "CPLX_CHECK_SRC=lib/aa"
echo   set "CPLX_BIN=_tbd_%CPLX_TOOL_NEW%"
echo ^)
) >"%add_tool_dir%\senv.local.tpl.tmp"

call:update_conf_file "%add_tool_dir%\senv.local.tpl" "%add_tool_dir%\senv.local.tpl.tmp"

::------------------------------------------------------------------------------
:: Update Local Environment Configuration
::------------------------------------------------------------------------------
:: Ensures the local environment configuration file (senv.local.bat) includes
:: the newly created tool configuration. This maintains consistency between
:: template and actual environment settings.
::------------------------------------------------------------------------------
:update_senv_local
echo grep -E "CPLX_TOOL.*%CPLX_TOOL_NEW%" "%cplx_dir%\senv.local.bat" ^>nul 2^>^&1
grep -E "CPLX_TOOL.*%CPLX_TOOL_NEW%" "%cplx_dir%\senv.local.bat" >nul 2>&1
if not errorlevel 1 (
  "%gum%" style --foreground 82 "✓ '%cplx_dir%\senv.local.bat' already includes a '%CPLX_TOOL_NEW%' section"
  goto:check_tool_section
)
call:update_conf_file "%cplx_dir%\senv.local.bat" "%add_tool_dir%\senv.local.tpl.tmp"

::------------------------------------------------------------------------------
:: Tool Section Validation
::------------------------------------------------------------------------------
:: Verifies that the tool's configuration is properly added and extracts any
:: existing variables to ensure they're applied correctly to the environment.
::------------------------------------------------------------------------------
:check_tool_section
rem set cplx
for /f "tokens=*" %%a in ('type "%cplx_dir%\senv.local.bat"') do (
    set "line=%%a"
    if defined CPLX_TOOL_FOUND (
        if "!line!"==")" ( goto:end_loop_senv_local )
        if not "!line:set =!"=="!line!" (
          !line!
        )
    )
    if "!line:libpsl=!" neq "!line!" (
        set "CPLX_TOOL_FOUND=true"
    )
)
:end_loop_senv_local
set cplx
endlocal & set "CPLX_TOOL_NEW=%CPLX_TOOL_NEW%"
goto:eof


::------------------------------------------------------------------------------
:: Configuration File Update Function
::------------------------------------------------------------------------------
:: Updates the specified configuration file with new tool settings by inserting
:: content at the appropriate location. This function maintains file structure
:: while ensuring new content is properly integrated.
::
:: Parameters:
::   %~1 - Target configuration file path
::   %~2 - File containing the content to insert
::------------------------------------------------------------------------------
:update_conf_file
set "conf_file=%~1"
set "conf_file_to_insert=%~2"
:: Extract dirname and basename of conf_file
for %%i in ("%conf_file%") do set "conf_basename=%%~nxi"
for %%i in ("%conf_file%") do set "conf_dirname=%%~dpi"
set "conf_dirname=%conf_dirname:~0,-1%"

:: Insert the new tool configuration before the second goto:eof in '%conf_file%'
"%gum%" style --foreground 45 "Inserting new tool configuration in '%conf_file%'..."

:: Create temporary file for the operation
set "temp_output=%conf_dirname%\merged.tmp"
rm -f "%temp_output%" >nul 2>&1

:: Use GNU awk to insert content before the second goto:eof
set "conf_dirname_esc=%conf_dirname:\=/%"
set "conf_file_to_insert_esc=%conf_file_to_insert:\=/%"
set "cat_exe=%PRGS%/gits/current/usr/bin/cat.exe"
set "cat_exe=%cat_exe:\=/%"
gawk "BEGIN {gotoCount = 0} {if ($0 ~ /goto:eof/ && gotoCount == 1) {system(\"%cat_exe% \\\"%conf_file_to_insert_esc%\\\"\");print \"\"}; print $0; if ($0 ~ /goto:eof/) {gotoCount++}}" "%conf_file%" > "%temp_output%"
:: Check if the operation was successful
if exist "%temp_output%" (
    copy /Y "%temp_output%" "%conf_file%" >nul
    del "%temp_output%"
    "%gum%" style --foreground 82 "✓ Tool configuration added successfully to '%conf_basename%'"
) else (
    "%gum%" style --foreground 196 "× Failed to update configuration fil '%conf_basename%'"
    exit /b 1
)
"%gum%" style --foreground 82 "✓ '%conf_basename%' updated with '%CPLX_TOOL_NEW%' section"

goto:eof


::----- Utility Functions -----------------------------------------------------

::------------------------------------------------------------------------------
:: Pretty Print Function
::------------------------------------------------------------------------------
:: Provides visually consistent and attractive output for the wizard interface
:: by handling color formatting and multi-segment text display. This centralizes
:: styling logic for a more maintainable user interface.
::
:: Accepts gum style parameters to properly format and display text segments
:: with varying colors and styles while maintaining a single-line output.
::------------------------------------------------------------------------------
:gum_echo
setlocal EnableDelayedExpansion
set "cmd=%gum% style"
set "output_count=0"

::----- Subfunctions ---------------------------------------------------------

::- Process arguments and build output array for joined display
:gum_echo_loop
set "arg=%~1"
rem echo %arg%
if "%arg%"=="" goto :gum_echo_end
set "first_two=!arg:~0,2!"
if "!first_two!"=="--" (
    set "cmd=!cmd! !arg!"
    shift
    set "arg2=%~2"
    set "cmd=!cmd! !arg2!"
) else (
    set "cmd=!cmd! ^"!arg!^""
    :: Execute the command and capture output
    set /a "output_count+=1"
    for /f "tokens=*" %%o in ('!cmd!') do (
        set "output_array[!output_count!]=%%o"
    )
    :: Reset command to gum style
    set "cmd=%gum% style"
)
shift
goto :gum_echo_loop
:gum_echo_end

:: Show all stored commands
rem echo Total commands: !output_count!
rem for /L %%i in (1,1,!output_count!) do (
rem     echo Command %%i: __!output_array[%%i]!__
rem )

:: Build gum join command with all output array elements
set "join_cmd=%gum% join --horizontal"
for /L %%i in (1,1,!output_count!) do (
    set "join_cmd=!join_cmd! ^"!output_array[%%i]!^""
)

:: Execute the join command to display all elements horizontally
rem echo Joined output: !join_cmd!
rem @echo on
call !join_cmd!
rem @echo off

endlocal
goto:eof

::------------------------------------------------------------------------------
:: Debug Stack Trace Helper
::------------------------------------------------------------------------------
:: Provides enhanced debugging capabilities by generating stack traces when
:: errors occur, but only if debugging is enabled. This helps troubleshoot
:: issues without affecting normal operation.
::------------------------------------------------------------------------------
:call_echos_stack
if not defined ECHOS_STACK ( set "CURRENT_SCRIPT=%~nx0" & goto:eof ) else ( call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0 )
goto:eof