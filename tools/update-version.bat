@echo off
setlocal enableextensions enabledelayedexpansion

::********************************************************************
:: Script Name:  update-version.bat
:: Description:  Updates the project version and handles Git operations.
::
:: Parameters:
::    rel - Force a release version
::
:: Environment Variables:
::    UV_FORCE_REL - Force a release version
::    PRJ_REL_TITLE - Title for the release in CHANGELOG.md
::
:: Usage:
::    update-version.bat
::
:: Return Value: 0 - Success, 1 - Error, or set the 'xxx' variable.
::********************************************************************

::##################################################
::  INITIAL SETUP
::##################################################
for %%i in ("%~dp0") do SET "update-version_dir=%%~fi"
set "QUIET_PRJ=true"
call <NUL "%update-version_dir%\..\senv.bat"
set "QUIET_PRJ="

::##################################################
::  GET PROJECT VERSION
::##################################################
%_task% "[%~nx0] Must get version from '%project_dir%\version.txt'"
set "project_version="
call "%update-version_dir%\%get-version.bat"
if not defined project_version (
  %_fatal% "[%~nx0] Unable to find version from '%project_dir%\version.txt'" 11
)
set "version=%project_version%"
%_ok% "[%~nx0] version '%version%' found in '%project_dir%\version.txt'"
set "version_release=%version:-SNAPSHOT=%"

if not "%version_release%"=="%version%" (
  set "is_snapshot=1"
  set "is_release="
) else (
  set "is_snapshot="
  set "is_release=1"
)
%_info% "[%~nx0] is_snapshot='%is_snapshot%', is_release='%is_release%', version_release='%version_release%'"

::##################################################
::  GIT DESCRIBE AND STATUS
::##################################################
for /f %%i in ('git -C "%project_dir%" describe --long --tags --dirty --always') do set git_describe=%%i
for /f %%i in ('git describe --tags^^^ --abbrev^=0 2^>NUL') do set "git_tag=%%i"
set "is_dirty="
if not "%git_describe:-dirty=%" == "%git_describe%" ( set "is_dirty=1" )

for /f %%i in ('bash -c "cygpath '%project_dir%'"') do set "project_path=%%i"
%_info% "project_path '%project_path%' from project_dir='%project_dir%'"

%_task% "[%~nx0] Must check if Git repository is dirty"
set "is_dirty_files="
set "is_dirty_src="
for /f "tokens=2" %%i in ('git status --porcelain') do (
    if not "%%i"=="" (
        if not "%%i"=="version.txt" (
            if not "%%i"=="CHANGELOG.md" (
                set "is_dirty_files=true"
                set "file=,%%i"
                if not "!file:,src/=!"=="!file!" (
                  set "is_dirty_src=true"
                  set "file=!file:,=!"
                )
            )
        )
    )
)

%_info% "[%~nx0] git_describe='%git_describe%', git_tag='%git_tag%'"
%_info% "[%~nx0] is_dirty='%is_dirty%', is_dirty_files='%is_dirty_files%'"
%_info% "[%~nx0] is_dirty_src='%is_dirty_src%', src_file_max_timestamp='%src_file_max_timestamp%'"

::##################################################
::  CHECK IF RELEASE IS NEEDED
::##################################################
if not defined git_tag (
  %_warning% "[%~nx0] No release tag ever set, so Git tag is 'v0.0.0', Git repo considered snapshot"
  set "git_tag=v0.0.0"
  set "git_is_snapshot=1"
  set "git_is_release="
  for /f %%i in ('git -C "%project_dir%" rev-list --count HEAD') do set commit_count=%%i
  if "!commit_count!"=="0" (
    %_info% "[%~nx0] No commit ever done in this repository with no history or tag"
    set "commit_count="
  ) else (
    %_info% "[%~nx0] '!commit_count!' commit(s) done in this repository with no tag"
  )
) else (
  for /f "tokens=2 delims=-" %%j in ("%git_describe%") do set commit_count=%%j
  %_info% "[%~nx0] commit_count='!commit_count!' since last Git tag '%git_tag%'"
  if "!commit_count!"=="0" (
    set "git_is_snapshot="
    set "git_is_release=1"
    %_info% "[%~nx0] No Git commit since last tag means Git repo is 'release'"
  ) else (
    set "git_is_snapshot=1"
    set "git_is_release="
    %_info% "[%~nx0] '!commit_count!' Git commit since last tag means Git repo is 'snapshot'"
  )
)
if defined is_dirty (
  if defined git_is_release (
    if "%commit_count%"=="0" (
      %_ok% "[%~nx0] Git dirty state, but no new commit: still considered release"
      goto:post_dirty_check
    ) else (
      %_warning% "[%~nx0] Git dirty state, but new commit done, so Git repo is no longer 'release'"
    )
  ) else (
      %_ok% "[%~nx0] Git dirty state, and snapshot"
  )
  %_info% "[%~nx0] Git dirty state means Git repo is 'snapshot' anyway"
  set "git_is_snapshot=1"
  set "git_is_release="
)
:post_dirty_check
if "%~1"=="rel" (
  if defined git_is_release (
    %_ok% "No release needed: current commit already at v'%version_release%'"
    goto:eof
  )
  call:make_new_release
  goto:eof
)
call:make_new_snapshot
goto:eof

::##################################################
::  MAKE NEW SNAPSHOT
::##################################################
:make_new_snapshot
%_info% "[%~nx0] [make_new_snapshot]: Check if new snapshot has to be made"

if defined is_snapshot (
  %_ok% "No need for new snapshot: current version '%version%' is already a SNAPSHOT one"
  call:check_update-changelog "snapshot version '%version%'"
  goto:eof
)

set "askForNewSnapshot="
if defined is_release ( 
  if defined commit_count (
    if not "%commit_count%"=="0" (
      set "askForNewSnapshot=%commit_count% new commits"
    )
  )
)

if defined is_release (
  if defined is_dirty (
    if not defined askForNewSnapshot (
      set "askForNewSnapshot=dirty"
    ) else (
        set "askForNewSnapshot=%askForNewSnapshot%, dirty"
    )
  )
)

if not defined askForNewSnapshot (
  %_ok% "No need for new snapshot: current version '%version%' is a RELEASE one without local modification or new commit"
  goto:eof
)

%_warning% "New modifications detected since last release '%version%' (%askForNewSnapshot%)"
git diff --cached --quiet
if errorlevel 1 (
    %_fatal% "Please commit or stash or reset your indexed/staged changes first, to allow version.txt modification and individual commit" 111
)
%_task% "Specify the new SNAPSHOT version to do"
FOR /F "tokens=1,2,3 delims=." %%i in ("%version%") do (
    set maj=%%i
    set min=%%j
    set fix=%%k
)
echo Major='!maj!', Minor='!min!', Fix='!fix!'
set nfix=!fix!
set /A nfix+=1
ECHO 1. Fix   update: !maj!.!min!.!nfix!-SNAPSHOT
set nmin=!min!
set /A nmin+=1
ECHO 2. Minor update: !maj!.!nmin!.0-SNAPSHOT
set nmaj=!maj!
set /A nmaj+=1
ECHO 3. Major update: !nmaj!.0.0-SNAPSHOT
choice /C 123 /M "Select the new snapshot version you want to make next"
set c=!errorlevel!
echo Choice '!c!'

if "!c!" == "1" ( set "appver=!maj!.!min!.!nfix!-SNAPSHOT" )
if "!c!" == "2" ( set "appver=!maj!.!nmin!.0-SNAPSHOT" )
if "!c!" == "3" ( set "appver=!nmaj!.0.0-SNAPSHOT" )

echo %appver%> "%project_dir%\version.txt"
if errorlevel 1 (
  %_fatal% "Unable to set %appver% in '%project_dir%\version.txt'" 256
)

git add -- "%project_dir%\version.txt"
if errorlevel 1 ( call:restore-version
    %_fatal% "ERROR unable to add version.txt" 112 )

set "relVersion=%appver:-SNAPSHOT=%"
grep -Eq "## %relVersion% - " "%project_dir%\CHANGELOG.md" >NUL 2>NUL
if not errorlevel 1 (
  %_ok% "'%project_dir%\CHANGELOG.md' now has '%relVersion%'"
  goto:add_changelog_with_title
)
if defined PRJ_REL_TITLE (
  set "title=%PRJ_REL_TITLE%"
  %_ok% "Using PRJ_REL_TITLE='%title%' for '%relVersion%'"
  goto:update_changelog_with_title
)

%_task% "Must enter title for CHANGELOG.md next release '%relVersion%' (PRJ_REL_TITLE not set)"
set /p "title=Enter title for '%relVersion%': "
if "!title!"=="" ( %_fatal% "Empty title for '%relVersion%'" 311 )

:update_changelog_with_title
echo.>> "%project_dir%\CHANGELOG.md"
echo ## %relVersion% - !title!>> "%project_dir%\CHANGELOG.md"
%_ok% "'%project_dir%\CHANGELOG.md' now has '%relVersion%' title '!title!'"

:add_changelog_with_title
git add -- "%project_dir%\CHANGELOG.md"
if errorlevel 1 ( call:restore-version
    %_fatal% "ERROR unable to add CHANGELOG.md" 122 )

git commit -m "chore(release): prepare for new '!appver!' from previous release '%VERSION%'"
if errorlevel 1 ( call:restore-version
    %_fatal% "ERROR unable to commit version.txt" 113 )

%_ok% "[%~nx0] [make_new_snapshot]: all done, new snapshot version '%appver%' set"
goto:eof

::##################################################
::  RESTORE VERSION
::##################################################
:restore-version
%_task% "[%~nx0] Must restore version.txt (to '%project_version%')"
echo %project_version%> "%project_dir%\version.txt"
if errorlevel 1 (
  %_fatal% "Unable to restore %project_version% in '%project_dir%\version.txt'" 256
)
goto:eof

::##################################################
::  MAKE NEW RELEASE
::##################################################
:make_new_release
if defined UV_FORCE_REL (
  if defined is_dirty_files (
    %_warning% "[%~nx0] [make_new_release] Repository is not clean, but 'UV_FORCE_REL' is set"
    git status --porcelain | grep -v version.txt | grep -v CHANGELOG.md
    goto:make_new_release_check
  )
)
set "confirm=y"
if defined is_dirty_files (
  set "confirm=N"
  %_warning% "[%~nx0] [make_new_release] Repository is not clean (and 'UV_FORCE_REL' is not set):"
  git status --porcelain | grep -v version.txt | grep -v CHANGELOG.md
  set /p "confirm=Do you want to make a release? (y/N): "
) else (
  %_ok% "[%~nx0] [make_new_release] Repository is clean. Proceed with release."
)
if /i "!confirm!" neq "y" (
  %_error% "[%~nx0] [make_new_release] No release made, since Git repository status is dirty."
  goto:eof
)
:make_new_release_check
if defined is_release (
  if defined git_is_release (
    if "%git_tag%"==v"%version%" (
      %_fatal% "[%~nx0] [make_new_release] version.txt version '%version%' already release, identical to last Git tag '%git_tag%': no new release needed" 22
  ) else if "%git_tag%"==v"%version%" (
      %_fatal% "[%~nx0] [make_new_release] The next version.txt release version '%version%' cannot be the same as the last Git tag '%git_tag%'" 23
    )
  )
)
if defined is_snapshot (
  if "%git_tag%"==v"%version_release%" (
    %_fatal% "[%~nx0] [make_new_release] version.txt next release version '%version_release%' cannot be the same as the last Git tag '%git_tag%'" 31
  )
  %_task% "[%~nx0] Must update version.txt from '%version%' to '%version_release%'"
  echo %version_release%> "%project_dir%\version.txt"
  if errorlevel 1 (
    %_fatal% "[%~nx0] [make_new_release] Unable to update version.txt from '%version%' to '%version_release%'" 32
  )
  %_ok% "[%~nx0] [make_new_release] version.txt updated from '%version%' to '%version_release%'"
) else (
  %_ok% "[%~nx0] [make_new_release] version.txt already at release revision '%version%'"
)
call:check_update-changelog "release version '%version_release%'"

%_task% "[%~nx0] Must reset Git repository, add version.txt and CHANGELOG and commit"
git -C "%project_dir%" reset
if errorlevel 1 ( %_fatal% "[%~nx0] Unable to reset index of '%project_dir%'" 211 )
git -C "%project_dir%" add "version.txt"
if errorlevel 1 ( %_fatal% "[%~nx0] Unable add version.txt to index of '%project_dir%'" 212 )
git -C "%project_dir%" add "CHANGELOG.md"
if errorlevel 1 ( %_fatal% "[%~nx0] Unable add CHANGELOG.md to index of '%project_dir%'" 213 )
git -C "%project_dir%" commit -m "chore(release): set new 'v%version_release%' from previous release '%git_tag%'"
if errorlevel 1 ( %_fatal% "[%~nx0] Unable commit version.txt/CHANGELOG.md to index of '%project_dir%'" 214 )
%_ok% "[%~nx0] Git repository reset, version.txt and CHANGELOG.md added to index and committed"

::##################################################
::  CREATE GIT TAG
::##################################################
%_task% "[%~nx0] Must check if git tag 'v%version_release%' is needed"
set "existing_tag="
for /f %%i in ('git tag -l "v%version_release%"') do set "existing_tag=%%i"
if defined existing_tag (
  %_fatal% "[%~nx0] Git tag 'v%version_release%' already exists" 344
)
%_task% "[%~nx0] Creating git tag 'v%version_release%'"
git tag -m "v%version_release%" "v%version_release%"
if errorlevel 1 (
  %_fatal% "[%~nx0] Unable to create git tag 'v%version_release%'" 343
)
%_ok% "[%~nx0] Git tag 'v%version_release%' created"

goto:eof

::##################################################
::  CHECK IF CHANGELOG NEEDS TO BE UPDATED
::##################################################
:check_update-changelog
if not exist "%project_dir%\CHANGELOG.md" (
  %_info% "[%~nx0] [update-changelog] No CHANGELOG.md found in '%project_dir%'"
  call:generate-changelog %1
  goto:eof
)
for /f %%i in ('bash -c "cygpath '%project_dir%\CHANGELOG.md'"') do set "changelog_path=%%i"
for /f %%i in ('bash -c "date +%%s -r "%changelog_path%""') do set "changelog_timestamp=%%i"
if not defined changelog_timestamp (
  %_fatal% "[%~nx0] [update-changelog] Unable to get CHANGELOG.md timestamp" 34
)
%_info% "[%~nx0] [update-changelog] changelog_timestamp='%changelog_timestamp%'"
for /f %%i in ('bash -c "git -C "%project_path%" log -1 --format=%%ct"') do set "git_last_commit_timestamp=%%i"
%_info% "[%~nx0] [update-changelog] git_last_commit_timestamp='%git_last_commit_timestamp%'"
if %git_last_commit_timestamp% gtr %changelog_timestamp% (
  %_info% "[%~nx0] [update-changelog] Last commit timestamp '%git_last_commit_timestamp%' is greater than CHANGELOG.md timestamp '%changelog_timestamp%'"
  goto:generate-changelog %1
  goto:eof
) else (
  %_info% "[%~nx0] [update-changelog] Last commit timestamp '%git_last_commit_timestamp%' is older than CHANGELOG.md timestamp '%changelog_timestamp%'"
  %_ok% "[%~nx0] [update-changelog] no need to update/refresh CHANGELOG.md"
)
goto:eof

::##################################################
::  (RE-)GENERATE CHANGELOG
::##################################################
:generate-changelog
%_task% "[%~nx0] [update-changelog] Must update/refresh CHANGELOG.md for %~1"
set "RELFORCE=1"
call "%project_dir%\tools\updateChangelog.bat" latest
if errorlevel 1 (
  set "RELFORCE="
  %_fatal% "[%~nx0] Unable to update '%project_dir%\CHANGELOG.md'" 129
)
set "RELFORCE="
%_ok% "[%~nx0] '%project_dir%\CHANGELOG.md' updated/refreshed"
goto:eof

:call_echos_stack
call "%project_dir%\tools\batcolors\echos.bat" :stack %~nx0
goto:eof