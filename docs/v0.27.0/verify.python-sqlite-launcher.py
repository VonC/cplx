"""Run the complete copied Windows launcher with synthetic external commands.

Only dependency command names are replaced in the copy. The production remote
status parser and failure branches run in actual CMD, without SSH or editor IO.
This process fixture has no provider-acceptance or unit-coverage role.
"""
from pathlib import Path
import os
import re
import subprocess
import sys


def write_batch(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(content.replace('\r\n', '\n').replace('\n', '\r\n').encode())


def check_launcher(repo, owned):
    original = (repo / 'src/install/install.bat').read_text()
    for remote_status, expected_status in ((0, 0), (42, 5), (4, 55), (199, 5)):
        fixture = owned / f'cmd-{remote_status}'
        fixture.mkdir()
        launcher = fixture / 'src/install/install.bat'
        content = original.replace('bash -c ', 'call "%FIXTURE%\\properties.cmd" ')
        content, scp_count = re.subn(r'(?m)^([ \t]*)scp ', lambda match: match[1] + 'call "%FIXTURE%\\stub.cmd" scp ', content)
        content, ssh_count = re.subn(r'(?m)^([ \t]*)ssh ', lambda match: match[1] + 'call "%FIXTURE%\\remote.cmd" ', content)
        assert (scp_count, ssh_count) == (3, 1)
        editor = '"%PRGS%\\vscodes\\current\\Code.exe" "%PRGS%\\vscodes\\current\\resources\\app\\out\\cli.js" "%install_dir%\\install.log"'
        assert content.count(editor) == 1
        content = content.replace(editor, 'call "%FIXTURE%\\stub.cmd" editor')
        focus = 'powershell -NoProfile -ExecutionPolicy Bypass -File "%install_dir%\\..\\utils\\alt_tab.ps1"'
        assert content.count(focus) == 1
        content = content.replace(focus, 'call "%FIXTURE%\\stub.cmd" focus')
        assert not re.search(r'(?m)^[ \t]*(scp|ssh|bash|powershell) ', content)
        assert content.count('call "%FIXTURE%\\properties.cmd"') == 2
        write_batch(launcher, content)
        write_batch(fixture / 'senv.bat', r'''@echo off
set "_info=echo"
set "_ok=echo"
set "_task=echo"
set "_fatal=call "%FIXTURE%\fatal.cmd""
set "SSH_CONFIG_ENTRY=fixture-only"
set "CPLX_TOOL=python"
set "CPLX_VERSION=3.13.15"
set "CPLX_INSTALL_COPY_ONLY="
exit /b 0
''')
        write_batch(fixture / 'fatal.cmd', '@echo off\nexit %~2\n')
        write_batch(fixture / 'properties.cmd', r'''@echo off
if exist "%FIXTURE%\properties-called" (
    echo /fixture
) else (
    type nul > "%FIXTURE%\properties-called"
    echo python
)
exit /b 0
''')
        write_batch(fixture / 'stub.cmd', r'''@echo off
echo %~1>>"%FIXTURE%\events"
if "%~1"=="scp" (
    type nul > "%FIXTURE%\src\install\install.log"
    type nul > "%FIXTURE%\src\install\temp_config.log"
)
exit /b 0
''')
        write_batch(fixture / 'remote.cmd', f'@echo off\necho remote fixture output\necho {remote_status}\nexit /b 0\n')
        environment = os.environ.copy()
        environment['FIXTURE'] = str(fixture)
        environment.pop('BASH_ENV', None)
        result = subprocess.run(
            [environment.get('COMSPEC', 'cmd.exe'), '/d', '/c', str(launcher), 'python', '3.13.15'],
            cwd=fixture, env=environment, capture_output=True, text=True, timeout=30)
        (fixture / 'process.log').write_text(result.stdout + result.stderr)
        assert result.returncode == expected_status, (
            f'CMD remote={remote_status}: expected {expected_status}, got {result.returncode}\n'
            + result.stdout[-3000:] + result.stderr[-1000:])
        status_file = launcher.parent / 'temp.txt'
        assert status_file.read_text().splitlines()[-1] == str(remote_status)
        events = (fixture / 'events').read_text().splitlines()
        expected_events = ['scp'] if remote_status == 4 else ['scp', 'scp']
        if remote_status == 199:
            expected_events += ['scp']
        if remote_status != 4:
            expected_events += ['editor', 'focus']
        assert events == expected_events, events
        print(f'PASS CMD remote={remote_status}, launcher exit={result.returncode}', flush=True)


if __name__ == '__main__':
    if os.name != 'nt':
        raise SystemExit('This fixture requires actual Windows CMD.')
    check_launcher(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve())
