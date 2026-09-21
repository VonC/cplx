#!/bin/bash
# Native RHEL deployed-venv qualification. Host commands keep the host environment;
# only application interpreter commands enter the application's shared runtime.
set -euo pipefail
[[ $# == 6 ]] || { echo 'usage: tools-runtime-rhel PREFIX VENV PYTHON INPUTS OUT READER_PYTHON' >&2; exit 2; }
prefix=$1 venv=$2 python=$3 inputs=$4 out=$5 reader=$6
project=$(cd "$venv/../.." && pwd)
mkdir -p "$out"
unset LD_LIBRARY_PATH PYTHONPATH
export HOME=$prefix UV_OFFLINE=1 UV_PYTHON_DOWNLOADS=never UV_NO_PROGRESS=1
export UV_PROJECT_ENVIRONMENT=$venv UV_PYTHON=$python
export UV_CACHE_DIR=$out/uv-cache
export PATH="$prefix/tools/git/current/bin:/usr/bin:/bin"
git="$prefix/tools/git/current/bin/git"

# Verify every executed application helper against the retained source commit
# before sourcing it. The packaged tree must be clean, not merely have that HEAD.
"$reader" -I - "$inputs" "$project" "$git" "$out" <<'PY'
import hashlib, json, pathlib, subprocess, sys
inputs, project, git, out = map(pathlib.Path, sys.argv[1:])
metadata = json.loads((inputs / 'runtime-inputs.json').read_text())
revision = metadata['application_revision']
assert subprocess.check_output([str(git), '-C', str(project), 'rev-parse', 'HEAD']).decode().strip() == revision
assert not subprocess.check_output([str(git), '-C', str(project), 'diff', '--name-only', revision, '--']).strip()
bindings = {}
for name in ['tools/runtime_env.sh', 'ci/tools_abi_scan.py', 'src/pdfss/core/host_runtime.py']:
    data = subprocess.check_output([str(git), '-C', str(project), 'show', revision + ':' + name])
    assert (project / name).read_bytes() == data, name
    bindings[name] = hashlib.sha256(data).hexdigest()
for name, expected in metadata['files'].items():
    assert pathlib.PurePosixPath(name).name == name
    assert hashlib.sha256((inputs / name).read_bytes()).hexdigest() == expected, name
assert hashlib.sha256((project / 'uv.lock').read_bytes()).hexdigest() == metadata['lock_sha256']
(out / 'source-bindings.json').write_text(json.dumps({'revision': revision, 'helpers': bindings, 'inputs': metadata}, indent=2) + '\n')
print('SOURCE AND OFFLINE INPUT BINDINGS PASS')
PY
# shellcheck disable=SC1091
source "$project/tools/runtime_env.sh" "$prefix"
"$python" -I -c 'import sys; assert sys.version_info[:3] == (3,13,15); print(sys.version); print(sys.executable)'
"$python" -m venv "$prefix/uvtool"
"$prefix/uvtool/bin/python" -m pip --version
uvwheel=$("$reader" -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["uv_wheel"])' "$inputs/runtime-inputs.json")
"$prefix/uvtool/bin/python" -m pip install --no-index --no-deps "$inputs/$uvwheel"
uv=$prefix/uvtool/bin/uv
patchelf=$prefix/tools/bin/patchelf
loader=$("$patchelf" --print-interpreter "$python")
[[ $loader == "$prefix"/tools/* ]] || { echo 'Python loader outside shipped tools' >&2; exit 1; }
libraries=$(pdfss_runtime_library_path "$prefix")
"$patchelf" --set-interpreter "$loader" --force-rpath --set-rpath "$libraries" "$uv"
"$patchelf" --print-interpreter "$uv" > "$out/uv-interpreter.txt"
"$patchelf" --print-rpath "$uv" > "$out/uv-rpath.txt"
"$loader" --list "$uv" > "$out/uv-providers.txt" 2>&1
"$python" -I - "$project" "$prefix" "$out" <<'PY'
import pathlib, sys
sys.path.insert(0, sys.argv[1])
from ci.tools_abi_scan import validate_list
prefix, out = map(pathlib.Path, sys.argv[2:])
rows = validate_list((out / 'uv-providers.txt').read_text(), prefix / 'tools', prefix / 'uvtool')
(out / 'uv-provider-rows.txt').write_text('\n'.join(rows) + '\n')
PY
"$uv" --version
sha256sum "$uv" > "$out/uv-sha256.txt"
cd "$project"
"$uv" sync --locked --offline --no-group tooling --dry-run > "$out/uv-sync.txt" 2>&1
cat "$out/uv-sync.txt"
if grep -qE 'Would (install|remove|replace|create|update)' "$out/uv-sync.txt"; then
    echo 'Deployed environment differs from the Q07 lock scope' >&2
    exit 1
fi

# Compare every installed ELF with the exact agent wheel inventory before and
# after the live trace. This check never patches a wheel or permits an extra ELF.
check_wheels() {
    "$reader" -I - "$inputs" "$project" "$venv" <<'PY'
import hashlib, json, os, pathlib, sys
inputs, project, venv = map(pathlib.Path, sys.argv[1:])
inventory = json.loads((inputs / 'inventory.json').read_text())
assert hashlib.sha256((project / 'uv.lock').read_bytes()).hexdigest() == inventory['lock_sha256']
sites = list(venv.glob('lib/python*/site-packages'))
assert len(sites) == 1
site = sites[0]
expected = {e['installed']: e['sha256'] for w in inventory['wheels'] for e in w['elfs']}
actual = {}
for folder, dirs, files in os.walk(site):
    assert not any((pathlib.Path(folder) / d).is_symlink() for d in dirs)
    for name in files:
        path = pathlib.Path(folder) / name
        assert not path.is_symlink(), str(path)
        with path.open('rb') as stream:
            if stream.read(4) != b'\x7fELF':
                continue
        actual[path.relative_to(site).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
assert actual == expected, 'agent and deployed wheel ELF inventories differ'
print('WHEEL BYTE EQUALITY PASS wheels=%d ELFs=%d' % (len(inventory['wheels']), len(actual)))
PY
}
check_wheels
"$python" "$project/ci/tools_abi_scan.py" "$prefix" "$venv" "$out/abi"
# Real host children cross before exec; shipped children keep their runtime.
pdfss_runtime_run "$venv/bin/python" -I - "$project" "$prefix" <<'PY'
import os, pathlib, subprocess, sys
sys.path.insert(0, str(pathlib.Path(sys.argv[1]) / 'src'))
from pdfss.core.host_runtime import host_environment
prefix = pathlib.Path(sys.argv[2])
assert os.environ.get('LD_LIBRARY_PATH') == os.environ['PDFSS_RUNTIME_LIB_PATH']
env = host_environment()
result = subprocess.run(['/bin/sh', '-c', 'readlink /proc/self/exe; command -v git; git --version'], env=env, text=True, capture_output=True)
assert result.returncode == 0, (result.stdout, result.stderr)
assert str(prefix / 'tools/git/current/bin/git') in result.stdout
print(result.stdout)
subprocess.run([sys.executable, '-I', '-c', 'import pymupdf,pikepdf; print("SHIPPED CHILD IMPORT PASS")'], check=True)
print('HOST CHILD BOUNDARY PASS')
PY
check_wheels
printf 'RHEL DEPLOYED RUNTIME PASS\n'
