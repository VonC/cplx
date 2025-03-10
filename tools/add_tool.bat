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
call <NUL "%add_tool_dir%\..\senv.bat"
for %%i in ("%~dp0..") do SET "cplx_dir=%%~fi"
for %%i in ("%~dp0..\src") do SET "src_dir=%%~fi"
for /f "tokens=* delims=" %%a in ('cygpath -u "%src_dir%"') do (
    SET "src_dir_unix=%%~a"
)

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

call:update_tool_properties

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
echo   set "CPLX_URL=_tbd_%CPLX_TOOL_NEW%"
echo   set "CPLX_SRC_EXT=zip"
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
rem echo grep -E "CPLX_TOOL.*%CPLX_TOOL_NEW%" "%cplx_dir%\senv.local.bat" ^>nul 2^>^&1
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

::------------------------------------------------------------------------------
:: Tool Configuration Validation Functions
::------------------------------------------------------------------------------
:: The following sections validate and complete tool configuration by checking
:: required variables and prompting for missing information. These validation
:: steps ensure a properly configured tool before integration.
::------------------------------------------------------------------------------

::------------------------------------------------------------------------------
:: Binary Type Validation
::------------------------------------------------------------------------------
:: Determines if the tool is a binary executable or a library by checking
:: configuration or prompting the user for selection. This affects how the
:: tool is built and integrated into the environment.
::------------------------------------------------------------------------------
:check_cplx_bin
if not defined CPLX_BIN (
  %_ok% "CPLX_BIN is a lib: not defined for '%CPLX_TOOL_NEW%'"
  goto:check_cplx_url
)
if not "%CPLX_BIN:_tbd_=%"=="%CPLX_BIN%" (
  %_task% "Must ask if '%CPLX_TOOL_NEW%' is binary or lib"
  "%gum%" style --foreground 45 "Step: Determine if '%CPLX_TOOL_NEW%' is a binary or library"
  for /f "tokens=*" %%a in ('%gum% choose "Binary (executable)" "Library (linked)"') do (
    if "%%a"=="Binary (executable)" (
      set "CPLX_BIN=true"
      "%gum%" style --foreground 82 "✓ Configured '%CPLX_TOOL_NEW%' as binary"
    ) else (
      set "CPLX_BIN="
      "%gum%" style --foreground 82 "✓ Configured '%CPLX_TOOL_NEW%' as library"
    )
  )
  call:update_senv_local_variable "CPLX_BIN" "!CPLX_BIN!"
) else (
  %_ok% "CPLX_BIN is defined as '!CPLX_BIN!'"
)

::------------------------------------------------------------------------------
:: URL Validation
::------------------------------------------------------------------------------
:: Validates that a source URL is provided for the tool or prompts the user
:: to enter one. The URL is essential for downloading source code during the
:: build process.
::------------------------------------------------------------------------------
:check_cplx_url
if not defined CPLX_URL (
  %_fatal% "CPLX_URL is not defined for '%CPLX_TOOL_NEW%'" 121
)
if "%CPLX_URL:_tbd_=%"=="%CPLX_URL%" (
  %_ok% "CPLX_URL is defined as '!CPLX_URL!'"
  goto:check_cplx_url_extension
)
%_task% "Must ask for '%CPLX_TOOL_NEW%' URL"
"%gum%" style --foreground 45 "Step: Provide the URL for '%CPLX_TOOL_NEW%'" --bold
for /f "tokens=*" %%a in ('%gum% input --placeholder "Tool URL"') do (
  set "CPLX_URL=%%a"
)
call:update_senv_local_variable "CPLX_URL" "!CPLX_URL!"

::------------------------------------------------------------------------------
:: Source Archive Format Detection
::------------------------------------------------------------------------------
:: Analyzes the tool's URL to automatically detect the appropriate archive format
:: (tar.gz or zip) or prompts the user to select one if detection fails. This
:: ensures the build process uses the correct extraction method for source files.
::
:: This functionality improves user experience by reducing manual configuration
:: while providing fallback options when automatic detection isn't possible.
::------------------------------------------------------------------------------
:check_cplx_url_extension
rem if URL extension is .tgz or .tar.gz, then call:update_senv_local_variable "CPLX_SRC_EXT" "tar.gz" "zip"

:: Auto-detect source extension from URL
"%gum%" style --foreground 45 "Checking URL extension to determine source format..."
if "!CPLX_URL!" NEQ "" (
  :: Check if URL contains .tar.gz or .tgz extension
  echo "!CPLX_URL!" | findstr /i /c:".tar.gz" /c:".tgz" >nul
  if not errorlevel 1 (
    "%gum%" style --foreground 82 "✓ Detected tar.gz format from URL"
    if "%CPLX_SRC_EXT%"=="tar.gz" (
      "%gum%" style --foreground 82 "✓ Confirmed tar.gz format from URL already in pace"
    )
    call:update_senv_local_variable "CPLX_SRC_EXT" "tar.gz" "zip"
  ) else (
    :: Check if URL contains .zip extension
    echo "!CPLX_URL!" | findstr /i /c:".zip" >nul
    if not errorlevel 1 (
      "%gum%" style --foreground 82 "✓ Confirmed zip format from URL"
    ) else (
      :: Ask user for extension if not detected
      "%gum%" style --foreground 226 "! Could not auto-detect source format from URL"
      "%gum%" style --foreground 45 "Step: Select source archive format for '%CPLX_TOOL_NEW%'"
      for /f "tokens=*" %%a in ('%gum% choose "tar.gz" "zip"') do (
        set "CPLX_SRC_EXT=%%a"
        "%gum%" style --foreground 82 "✓ Using !CPLX_SRC_EXT! format for source archives"
        call:update_senv_local_variable "CPLX_SRC_EXT" "!CPLX_SRC_EXT!" "zip"
      )
    )
  )
)

::------------------------------------------------------------------------------
:: Version Validation
::------------------------------------------------------------------------------
:: Ensures the tool has a properly defined version number by checking for
:: existing version information or prompting the user to provide it. Version
:: information is critical for proper source download and build operations.
::
:: Accurate version tracking allows for reproducible builds and proper dependency
:: management across the development environment.
::------------------------------------------------------------------------------
:check_cplx_version
if not defined CPLX_VERSION (
  %_fatal% "CPLX_VERSION is not defined for '%CPLX_TOOL_NEW%'" 121
)
if "%CPLX_VERSION:_tbd_=%"=="%CPLX_VERSION%" (
  %_ok% "CPLX_VERSION is defined as '!CPLX_VERSION!'"
  goto:update_cplx_url_version_placeholder
)
%_task% "Must ask for '%CPLX_TOOL_NEW%' version"
"%gum%" style --foreground 45 "Step: Provide the URL for '%CPLX_TOOL_NEW%'" --bold
for /f "tokens=*" %%a in ('%gum% input --placeholder "Tool version"') do (
  set "CPLX_VERSION=%%a"
)
call:update_senv_local_variable "CPLX_VERSION" "!CPLX_VERSION!"

::------------------------------------------------------------------------------
:: URL Version Placeholder Substitution
::------------------------------------------------------------------------------
:: Replaces explicit version numbers in URLs with a [version] placeholder to
:: create more flexible URL templates. This enables the build system to
:: dynamically substitute version numbers when downloading source files.
::
:: This templating approach simplifies future version upgrades and maintains
:: consistent URL patterns across different tools and versions.
::------------------------------------------------------------------------------
:update_cplx_url_version_placeholder
if not "!CPLX_URL:%CPLX_VERSION%=!"=="!CPLX_URL!" (
  %_warning% "CPLX_URL includes '%CPLX_VERSION%' (!CPLX_VERSION!)"
  set "CPLX_URL=!CPLX_URL:%CPLX_VERSION%=[version]!"
  %_info% "Set CPLX_URL to !CPLX_URL!"
  call:update_senv_local_variable "CPLX_URL" "!CPLX_URL!" "https://.*/%CPLX_TOOL_NEW%/.*$"
  goto:check_install_folders
) else (
  %_ok% "CPLX_URL does not include '%CPLX_VERSION%' (!CPLX_VERSION!)"
)

:end_game
echo ----------------
set cplx
endlocal & set "CPLX_TOOL_NEW=%CPLX_TOOL_NEW%"
goto:eof

::------------------------------------------------------------------------------
:: Tool Properties Update Function
::------------------------------------------------------------------------------
:: Coordinates updates to multiple property files to register the new tool in
:: various configuration locations. This ensures the tool is properly integrated
:: into build processes and deployment pipelines.
::
:: This function acts as a coordinator for the more specific property file
:: update operations, maintaining a consistent tool registration pattern.
::------------------------------------------------------------------------------
:update_tool_properties
call:update_tool_properties_file "services" "%src_dir_unix%/setups/setup.properties"
call:update_tool_properties_file "tools_to_recompile" "%src_dir_unix%/setups/setup.properties"
call:update_tool_properties_file "services" "%src_dir_unix%/setups/setup.tpl.properties"
call:update_tool_properties_file "tools_to_recompile" "%src_dir_unix%/setups/setup.tpl.properties"
call:update_tool_properties_file "services" "%src_dir_unix%/setups/env/cplx.properties"
call:update_tool_properties_file "services" "%src_dir_unix%/setups/env/cplx.tpl.properties"
goto:eof

::----- Subfunctions ---------------------------------------------------------

::------------------------------------------------------------------------------
:: Environment Variable Update Function
::------------------------------------------------------------------------------
:: Updates specific tool variables in both the local and template configuration
:: files to maintain consistency across the environment. This ensures changes
:: made through the wizard are properly persisted and available for future
:: tool operations.
::
:: Parameters:
::   %~1 - Variable name to update (e.g., "CPLX_BIN", "CPLX_URL")
::   %~2 - New value to set for the variable
::------------------------------------------------------------------------------
:update_senv_local_variable
set "variable=%~1"
set "value=%~2"
set "placeholder=%~3"

if not defined placeholder ( set "placeholder=_tbd_%CPLX_TOOL_NEW%" )

sed -i "s,%variable%=%placeholder%,%variable%=%value%," "%cplx_dir%\senv.local.bat"
if errorlevel 1 (
  %_fatal% "Issue during setting %variable% in '%cplx_dir%\senv.local.bat'" 122
) else (
  %_ok% "Set %variable% in '%cplx_dir%\senv.local.bat' to '%value%'"
)
sed -i "s,%variable%=%placeholder%,%variable%=%value%," "%add_tool_dir%\senv.local.tpl"
if errorlevel 1 (
  %_fatal% "Issue during setting %variable% in '%add_tool_dir%\senv.local.tpl'" 123
) else (
  %_ok% "Set %variable% in '%add_tool_dir%\senv.local.tpl' to '%value%'"
)
goto:eof

::- Property File Update Helper
::-
::- Updates a specific property in a properties file with the new tool name.
::- This function handles checking if the tool already exists in the property
::- and adds it only if needed, avoiding redundant entries.
::-
::- Parameters:
::-   %~1 - Property key to update (e.g., "services", "tools_to_recompile")
::-   %~2 - Unix-style path to the properties file
::-
:update_tool_properties_file
setlocal EnableDelayedExpansion
set "key=%~1"
set "unix_file=%~2"
%_task% "Must check property '%key%' from '%unix_file%'"
for /f "tokens=* delims=" %%a in ('bash -c "source "${src_dir_unix}/utils/properties.sh"; properties_file="${unix_file}"; export properties_file; get_property %key%; export key; printf "%%s" ${%key%}"') do (
    SET "cplx_key=%%~a"
    SET "cplx_key_with_comma=,%%~a,"
)
if not "!cplx_key_with_comma:,%CPLX_TOOL_NEW%,=!" == "!cplx_key_with_comma!" (
    %_ok% "cplx_key '%cplx_key%' includes '%CPLX_TOOL_NEW%' (!CPLX_TOOL_NEW!)"
    rem echo __%cplx_key_with_comma:,!CPLX_TOOL_NEW!,=%__
    goto:eof
)
%_warning% "cplx_key '%cplx_key%' does not include '%CPLX_TOOL_NEW%' (!CPLX_TOOL_NEW!)"
rem echo ko: __%cplx_key_with_comma:,CPLX_TOOL_NEW%,=%__
rem echo vs: __%cplx_key_with_comma%__
if not defined cplx_key (
    set "cplx_key=%CPLX_TOOL_NEW%"
) else (
    set "cplx_key=%cplx_key%,%CPLX_TOOL_NEW%"
)
%_task% "Must add '%CPLX_TOOL_NEW%' to '%key%' in '%unix_file%', cplx_key='%cplx_key%'"
for /f "tokens=* delims=" %%a in ('bash -c "source "${src_dir_unix}/utils/properties.sh"; properties_file="${unix_file}"; export properties_file; set_property %key% "!cplx_key!"; echo $?"') do (
    SET "cplx_key_res=%%a"
)
if not "%cplx_key_res%" == "0" (
    %_fatal% "Issue during setting '%key%' in '%unix_file%' (cplx_key_res='%cplx_key_res%')" 65
) else (
    %_ok% "Set '%key%' in '%unix_file%' to '%cplx_key%'"
)
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