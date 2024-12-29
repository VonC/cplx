@echo off
setlocal enableextensions enabledelayedexpansion

set "QUIET_PRJ=true"
call <NUL "%~dp0senv.bat"
set "QUIET_PRJ="

call "%project_dir%\tools\get-version.bat"

rem echo fatal is '%_fatal%', with batdir='%batdir%' and project_dir '%project_dir%'

: This makeRelease.bat Windows script complete the %project_dir%\CHANGELOG.md with a title and changes.
: The title is X.Y.Z[-rcR] (with X, Y, Z and R digits, the -rcR is optional)

::: First task: check that %1 respects the pattern vX.Y.Z[-rcR] (Linux command acceptable in this bat script), or use the one from version.txt
set "relVersion=%~1"
set "relTitleParam=%~2"

: Check if argument matches the pattern vX.Y.Z[-rcR]
: echo %~1| findstr /R "^^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*^$" >nul
echo %relVersion%| grep -Eq "^^v[0-9]+\.[0-9]+\.[0-9]+(-[rR][cC][0-9]+)?$"
IF not ERRORLEVEL 1 (
    for %%i in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=v" "w=W" "x=X" "y=Y" "z=Z") do call set "relVersion=%%relVersion:%%~i%%"
    set "relVersion=!relVersion:v=!"
    %_ok% "[%~nx0] Version 'v!relVersion!' from first argument is valid."
    set "relVersionFile=%project_version%"
    for %%i in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=v" "w=W" "x=X" "y=Y" "z=Z") do call set "relVersionFile=%%relVersionFile:%%~i%%"
    set "relVersionFile=!relVersionFile:v=!"
    set "relVersionFile=!relVersionFile:-SNAPSHOT=!"
    if not "!relVersion!" == "!relVersionFile!" (
        %_warning% "[%~nx0] Version 'v!relVersion!' from first argument is different from the one in version.txt: 'v!relVersionFile!'"
        %_task% "[%~nx0] Must update version.txt with that new version 'v!relVersion!'"
        rem echo !relVersion!-SNAPSHOT > "%project_dir%\version.txt"
        %_ok% "[%~nx0] Version 'v!relVersion!' updated in version.txt"
    )
    set "relVersion=v!relVersion!"
    goto:CheckRelease
)
if "%relVersion%" == "latest" ( goto:relVersion_is_project_version )
%_fatal% "[%~nx0] Version '%relVersion%' from first argument does not follow the pattern X.Y.Z[-rcR]" 279
:relVersion_is_project_version
set "relVersion=%project_version%"
for %%i in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=v" "w=W" "x=X" "y=Y" "z=Z") do call set "relVersion=%%relVersion:%%~i%%"
set "relVersion=%relVersion:-SNAPSHOT=%"
set "relVersion=%relVersion:v=%"
echo %relVersion%| grep -Eq "^^[0-9]+\.[0-9]+\.[0-9]+(-[rR][cC][0-9]+)?$"
IF ERRORLEVEL 1 (
    %_fatal% "[%~nx0] Version '!relVersion!' from version.txt does not follow the pattern X.Y.Z[-rcR]" 280
)
set "relVersion=v%relVersion%"
%_ok% "[%~nx0] Version '%relVersion%' from version.txt is valid."

:CheckRelease
::: Second task: extract the title of the release from %project_dir%\CHANGELOG.md
rem %_fatal% "Stop at :CheckRelease" 1
: Unless forced, a '## vX.Y.Z[-rcC] - ...' means the release is already written: exit
set "overwriteRel=false"
grep -Eq "## %relVersion% - " "%project_dir%\CHANGELOG.md" >NUL 2>NUL
if not errorlevel 1 (
    %_ok% "[%~nx0] Release '%relVersion%' already written in '%project_dir%\CHANGELOG.md'."
    if not "%RELFORCE%" == "" (
        %_task% "[%~nx0] Must rewrite release '%relVersion%' in '%project_dir%\CHANGELOG.md'"
        set "overwriteRel=true"
        goto:extractTitle
    )
    %_info% "[%~nx0] To overwrite the release, set RELFORCE=1"
    grep -E "## %relVersion% - " "%project_dir%\CHANGELOG.md"
    del /F /Q "%project_dir%\CHANGELOG.tmp.md" 2>NUL
    goto:eof
)

%_info% "[%~nx0] Release '%relVersion%' not already written in '%project_dir%\CHANGELOG.md'"

:extractTitle
: extract title written in advance in CHANGELOG.md
for /f "tokens=*" %%i in ('grep -E "%relVersion%\b" "%project_dir%\CHANGELOG.md" 2^>NUL') do ( set "relTitle=%%i" )
%_info% "[%~nx0] relTitle='%relTitle%'"
if "%relTitle%" == "" ( goto:compareTitle )
del /F /Q "%project_dir%\temp" 2>NUL
echo %relTitle%| sed "s/.*%relVersion%[ \t:,_-]\+//g">"%project_dir%\temp"
for /f "tokens=*" %%i in ('type "%project_dir%\temp"') do ( set "relTitle=%%i" )
%CHECK_DEBUG_PRJ% cat "%project_dir%\temp"
%CHECK_DEBUG_PRJ% echo relTitle='%relTitle%'
del /F /Q "%project_dir%\temp" 2>NUL
echo %relTitle%| sed "s/^2.*:[ \t:,_-]//g">"%project_dir%\temp"
for /f "tokens=*" %%i in ('type "%project_dir%\temp"') do ( set "relTitle=%%i" )
%CHECK_DEBUG_PRJ% cat "%project_dir%\temp"
%CHECK_DEBUG_PRJ% echo relTitle='%relTitle%'
del /F /Q "%project_dir%\temp" 2>NUL
if "%overwriteRel%" == "true" (
    echo %relTitle%| sed "s/.*\?:[ \t:,_-]\+//g">"%project_dir%\temp"
    for /f "tokens=*" %%i in ('type "%project_dir%\temp"') do ( set "relTitle=%%i" )
)
%_info% "[%~nx0] relTitle1='%relTitle%'"
:compareTitle
: compare extracted title from CHANGELOG.md with second parameter
if "%relTitle%" == "" (
    : There was not title from CHANGELOG, so the second parameter *must* be there:
    if "%relTitleParam%" == "" (
        %_fatal% "[%~nx0] No title found for '%relVersion%' in '%project_dir%\CHANGELOG.md', you need to provide one as second parameter of updateChangelog.bat" 282
    ) else (
        set "relTitle=%relTitleParam%"
        %_ok% "[%~nx0] Release title from second parameter: '!relTitle!'"
    )
) else (
    : there was a title from CHANGELOG: it must be the same as the second parameter, if present
    if not "%relTitleParam%" == "" (
        if not "%relTitle%" == "%relTitleParam%" (
            if "%RELFORCE%" == "" (
                %_error% "[%~nx0] Title '%relTitleParam%' provided for '%relVersion%' in '%project_dir%\CHANGELOG.md' is different from the one extracted '%relTitle%'"
                %_fatal% "[%~nx0] Edit changelog or do not pass a title as second parameter of updateChangelog.bat" 283
            ) else (
                %_info% "[%~nx0] Update title from '%relTitle%' to '%relTitleParam%' for '%relVersion%'"
                set "relTitle=%relTitleParam%"
            )
        )
    )
    : (if not second parameter, then we simply keep the title extracted from CHANGELOG)
    %_ok% "[%~nx0] Release title from1 CHANGELOG.md: '!relTitle!'"
)

::: Third task: Generate a temporary changelog for that new release version
set "GIT_CLIFF_CONFIG=%project_dir%\tools\cliff.toml"
set "gcliff=%PRGS%\git-cliffs\current\git-cliff.exe"
rem echo gcliff='%gcliff%'
%gcliff% -u -s all > "%project_dir%\CHANGELOG.tmp.md"
if errorlevel 1 (
    %_fatal% "[%~nx0] Error while generating temporary changelog for '%relVersion%'" 281
)
: source for conventional commit emojis
: https://gist.github.com/parmentf/359667bf23e08a1bd8241fbf47ecdef0 (emojis)
: https://gitmoji.dev/
: Add missing emojis not supported by git-cliff (alias gcliff): https://github.com/orhun/git-cliff/blob/a5a85298f3fe280ad2de85bb19c338aeb24bfb33/cliff.toml#L79-L95
sed -i "s/### Build/### 🔨 Build/g" "%project_dir%\CHANGELOG.tmp.md"
sed -i "s/### Wip/### 🚧 Wip/g" "%project_dir%\CHANGELOG.tmp.md"

::: Fourth task: check if "Features" are present. 
:   That means new major version (for v1.x.y or more) or new minor version (for v0.y.z)
set "hasFeatures=false"
grep -Eq "### .* Features" "%project_dir%\CHANGELOG.tmp.md"
if not errorlevel 1 (
    set "hasFeatures=true"
    %_info% "[%~nx0] Feature(s) detected for '%relVersion%'"
) else (
    %_info% "[%~nx0] No Feature detected for '%relVersion%'"
)

: Extract major, minor and fix number from relVersion, to check if they are coherent with the presence (or not) of features

FOR /F "tokens=1,2,3 delims=." %%i in ("%relVersion%") do (
    set maj=%%i
    set min=%%j
    set fix=%%k
)
set "maj=%maj:v=%"
%CHECK_DEBUG_PRJ% echo Major='%maj%', Minor='%min%', Fix='%fix%'
set /a "minPlusOne=%min% + 1"
set /a "majPlusOne=%maj% + 1"

if not "%hasFeatures%" == "true" (
    %_info% "[%~nx0] No new features present in this release: '%relVersion%' is valid"
    goto:features_ok
)
if "%hasFeatures%" == "true" (
    if "%maj%" == "0" (
        if "%fix%" == "0" (
            %_info% "[%~nx0] New features: '%relVersion%' is compatible for a v0"
        ) else (
            %_fatal% "[%~nx0] New features means v0.%minPlusOne%.0: update version.txt, or pass a compatible version, not '%relVersion%'" 284
        )
    ) else (
        if "%fix%" == "0" (
            %_info% "[%~nx0] New features: '%relVersion%' is compatible for a v1+"
        ) else (
            %_fatal% "[%~nx0] New features means v%majPlusOne%.0.0: update version.txt, or pass a compatible version, not '%relVersion%'" 284
        )
    )
)

:features_ok
::: Fifth task: update and insert tmp changelog into the actual CHANGELOG.md
: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7.4&viewFallbackFrom=powershell-7.1
: https://www.reddit.com/r/PowerShell/comments/ssc6eq/force_english_in_getdate/
%CHECK_DEBUG_PRJ% echo 0------------
%+@% for /f "tokens=*" %%a in ('C:\Windows\System32\WindowsPowershell\v1.0\powershell -ExecutionPolicy Bypass -File "%project_dir%\tools\get_day_index.ps1"') do set relDate=%%a

rem echo "s/## \[unreleased\]/## %relVersion% - %relDate%: %relTitle%/g" "%project_dir%\CHANGELOG.tmp.md"
rem sed -i "s/## \[unreleased\]/## %relVersion% - %relDate%: %relTitle%/g" "%project_dir%\CHANGELOG.tmp.md"
rem echo awk "{gsub(/## \[unreleased\]/, \"## %relVersion% - %relDate%: %relTitle%\"); print}" "%project_dir%\CHANGELOG.tmp.md" > temp && move /y temp "%project_dir%\CHANGELOG.tmp.md"
rem awk "!/## \[unreleased\]/ {print} /## \[unreleased\]/ {print \"## %relVersion% - %relDate%: %relTitle%\"}" "%project_dir%\CHANGELOG.tmp.md" > temp && move /y temp "%project_dir%\CHANGELOG.tmp.md" 2> NUL 1>NUL
rem awk "!/## \[unreleased\]/" "%project_dir%\CHANGELOG.tmp.md" > temp && move /y temp "%project_dir%\CHANGELOG.tmp.md" 2> NUL 1>NUL

rem awk -v relVersion="%relVersion%" "BEGIN {RS='## v[0-9]+\\.[0-9]+\\.[0-9]+(-rc[0-9]+)?\\b'; ORS=''}; $0 ~ relVersion { system('cat CHANGELOG.tmp.md'); next }; {print '## v' $0}" CHANGELOG.md > temp
rem awk -v relVersion="%relVersion%" "BEGIN {RS=\"## v[0-9]+\\\\.[0-9]+\\\\.[0-9]+(-rc[0-9]+)?\\b\"; ORS=\"\"}; $0 ~ relVersion { system(\"echo CHANGELOG.tmp.md\"); next }" CHANGELOG.md > temp
rem @echo on
%CHECK_DEBUG_PRJ% echo 1------------
del /F /Q "%project_dir%\temp" 2>NUL
set "skip=1"
>"%project_dir%\temp" (
    for /f "delims=" %%i in ('findstr /n "^" "%project_dir%\CHANGELOG.tmp.md"') do (
        set "line=%%i"
        rem echo line='!line!'
        setlocal enabledelayedexpansion
        set "line=!line:*:=!"
        if not defined line echo(!line!
        if defined line (
            rem echo skip='!skip!' for line='!line!'
            if not "!skip!"=="1" (
                echo(!line!
            )
        )
        endlocal & set "skip=0"
    )
)
move /y temp "%project_dir%\CHANGELOG.tmp.md" 2> NUL 1>NUL
%CHECK_DEBUG_PRJ% echo 2------------
for /f "tokens=*" %%i in ('where bash.exe^|grep gits^|grep -v usr') do ( set "bashExe=%%i" )
echo bashExe='%bashExe%'
"%bashExe%" "%project_dir%\tools\updateChangelog.sh" "%relVersion%" "%relTitle%"
if errorlevel 1 (
    %_fatal% "[%~nx0] Error while updating temporary changelog for '%relVersion%'" 285
)
%CHECK_DEBUG_PRJ% echo 2b------------
goto:done
del /F /Q "%project_dir%\temp" 2>NUL
del /F /Q "%project_dir%\found" 2>NUL
del /F /Q "%project_dir%\added" 2>NUL
REM From https://stackoverflow.com/questions/38723595/preserve-empty-lines-in-a-text-file-while-using-batch-for-f
>"%project_dir%\temp" (
  for /f "delims=" %%i in ('findstr /n "^" "%project_dir%\CHANGELOG.md"') do (
      set "line=%%i"
      setlocal enabledelayedexpansion
      set "line=!line:*:=!"
      if not defined line echo(!line!
      rem echo "found='!found!', line='!line!'"
      if defined line (
        if not exist "%project_dir%\found" (
            rem echo echo %%a ^| findstr /b /r "## %relVersion%[^a-zA-Z0-9-]" 1^>nul
            echo !line! | findstr /b /r "##[^#]%relVersion%[^a-zA-Z0-9-]" 1>nul
            if errorlevel 1 (
                echo(!line!
            ) else (
                echo(## %relVersion% - %relDate%: %relTitle%
                type "%project_dir%\CHANGELOG.tmp.md"
                touch "%project_dir%\found"
                touch "%project_dir%\added"
            )
        ) else (
            echo !line! | findstr /b /c:"## " 1>nul
            if not errorlevel 1 (
                echo(!line!
                del /F /Q "%project_dir%\found" 2>NUL
            )
        )
      )
      endlocal
  )
)
%CHECK_DEBUG_PRJ% echo 3------------
del /F /Q "%project_dir%\found" 2>NUL
if not exist "%project_dir%\added" (
    echo.>>"%project_dir%\temp"
    echo ## %relVersion% - %relDate%: %relTitle%>>"%project_dir%\temp"
    type "%project_dir%\CHANGELOG.tmp.md">>"%project_dir%\temp"
)
del /F /Q "%project_dir%\added" 2>NUL
move /y temp "%project_dir%\CHANGELOG.md" 2> NUL 1>NUL
sed -i 's/\r$//' "%project_dir%\CHANGELOG.md"
sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "%project_dir%\CHANGELOG.md" > "%project_dir%\temp.md" && move /y "%project_dir%\temp.md" "%project_dir%\CHANGELOG.md"
:done
%_ok% "[%~nx0] CHANGELOG.md updated with '%relVersion%'"
del /F /Q "%project_dir%\CHANGELOG.tmp.md" 2>NUL
git diff -- CHANGELOG.md
goto:eof
