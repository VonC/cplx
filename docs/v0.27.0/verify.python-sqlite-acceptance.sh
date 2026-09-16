#!/bin/bash
# Recording fixtures exercise acceptance refusals; they never certify a candidate.
set -euo pipefail
[[ ${1:-} == --python && -n ${2:-} ]] || exit 2
author_python=$2
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
driver=$here/acceptance.python-sqlite-support.sh
[[ -f $driver ]] || { echo 'FAIL: acceptance driver is missing' >&2; exit 1; }
# shellcheck source=/dev/null
source "$driver"
scratch_parent=$(cd "${TMPDIR:-/tmp}" && pwd -P)
work=$(mktemp -d "$scratch_parent/cplx-sqlite-capture.XXXXXXXX")
work=$(cd "$work" && pwd -P)
trap '[[ $work == "$scratch_parent/"cplx-sqlite-capture.* && $work != "$scratch_parent" ]] && rm -rf -- "$work"' EXIT
mkdir -p "$work/owned" "$work/live"
printf original > "$work/live/payload"
printf stable > "$work/owned/sentinel"
count=0
check() { "$@" || { echo "FAIL: $*" >&2; exit 1; }; count=$((count + 1)); }
refuses() { if ("$@") > "$work/refusal.log" 2>&1; then return 1; fi; }
check refuses bash "$driver" preflight
check refuses bash "$driver" preflight --role build --home "$work/owned"
check refuses sqlite_anchor "$work/owned" build
check sqlite_inside "$work/owned" "$work/owned/sentinel"
check refuses sqlite_inside "$work/owned" "$work/live/payload"
ln -s "$work/live/payload" "$work/owned/escape"
if [[ -L $work/owned/escape ]]; then
    check refuses sqlite_boundary "$work/owned"
else
    echo 'SKIP: native symlink boundary fixture requires Linux or Windows symlink privilege'
fi
rm "$work/owned/escape"
ln "$work/live/payload" "$work/owned/hardlink"
check refuses sqlite_boundary "$work/owned"
rm "$work/owned/hardlink"
touch "$work/owned/.profile"
check refuses sqlite_profile "$work/owned"
rm "$work/owned/.profile"
check sqlite_profile "$work/owned"
sqlite_manifest "$work/live" > "$work/before"
check sqlite_manifest_equal "$work/before" "$work/before"
# Same size and restored timestamps must still reveal a live content change.
touch -r "$work/live/payload" "$work/stamp"
printf modified > "$work/live/payload"
touch -r "$work/stamp" "$work/live/payload"
sqlite_manifest "$work/live" > "$work/after"
check refuses sqlite_manifest_equal "$work/before" "$work/after"
mkdir "$work/owned/pkgs"
printf archive > "$work/owned/pkgs/tools.one.tar.gz"
archive=$work/owned/pkgs/tools.one.tar.gz
digest=$(sqlite_digest "$archive")
check sqlite_archive "$work/owned" "$archive" "$digest"
check refuses sqlite_archive "$work/owned" "$archive" "${digest/a/b}bad"
cp "$archive" "$work/owned/pkgs/tools.two.tar.gz"
check refuses sqlite_archive "$work/owned" "$archive" "$digest"
rm "$work/owned/pkgs/tools.two.tar.gz"
ln -s tools.one.tar.gz "$work/owned/pkgs/tools.latest.tar.gz"
if [[ -L $work/owned/pkgs/tools.latest.tar.gz ]]; then
    check sqlite_archive "$work/owned" "$archive" "$digest"
    rm "$work/owned/pkgs/tools.latest.tar.gz"
    ln -s "$work/live/payload" "$work/owned/pkgs/tools.latest.tar.gz"
    check refuses sqlite_archive "$work/owned" "$archive" "$digest"
else
    echo 'SKIP: packaging alias fixtures require native symlinks'
fi
rm "$work/owned/pkgs/tools.latest.tar.gz"
mkdir -p "$work/owned/tools/python/python-3.13.15/lib/python3.13/lib-dynload" \
    "$work/owned/tools/python/root/usr/lib64" "$work/owned/tools/python/bin"
python_root=$work/owned/tools/python
extension_root=$python_root/python-3.13.15/lib/python3.13/lib-dynload
provider=$python_root/root/usr/lib64/libsqlite3.so.0
touch "$provider" "$extension_root/_sqlite3.so" "$python_root/bin/python"
"$author_python" -B - "$work/result.json" "$python_root" "$extension_root" "$provider" <<'PY'
import json
from pathlib import Path
import sys
output, root, extension, provider = sys.argv[1:]
Path(output).write_text(json.dumps(dict(stage="operator", python_version="3.13.15 fixture",
    outcome="passed", database="passed", executable=root + "/bin/python",
    extension=dict(path=extension + "/_sqlite3.so", import_path=extension + "/_sqlite3.so"),
    provider=dict(path=provider, identity=[1, 2, 3]))))
PY
check sqlite_result "$author_python" "$work/result.json" operator "$python_root" "$extension_root" "$provider"
ln -s ../python-3.13.15 "$python_root/bin/current"
if [[ -L $python_root/bin/current ]]; then
    "$author_python" -B - "$work/result.json" "$work/alias.json" "$python_root" <<'PY'
import json
from pathlib import Path
import sys
record = json.loads(Path(sys.argv[1]).read_text())
record['extension']['import_path'] = sys.argv[3] + '/bin/current/lib/python3.13/lib-dynload/_sqlite3.so'
Path(sys.argv[2]).write_text(json.dumps(record))
PY
    check sqlite_result "$author_python" "$work/alias.json" operator "$python_root" "$extension_root" "$provider"
fi
check refuses sqlite_result "$author_python" "$work/result.json" operator "$work/live" "$extension_root" "$provider"
printf 'wrapper says success\n' > "$work/missing.json"
check refuses sqlite_result "$author_python" "$work/missing.json" operator "$python_root" "$extension_root" "$provider"
printf '{"outcome":"passed"}\n' > "$work/incomplete.json"
check refuses sqlite_result "$author_python" "$work/incomplete.json" operator "$python_root" "$extension_root" "$provider"
check refuses sqlite_roles "$author_python" "$work" "$digest"
# A failed command must retain its status and always compare live preservation.
mkdir "$work/capture"
cp "$work/after" "$work/capture/live.before"
printf '%s\n' "$work/live" > "$work/capture/live.roots"
cat > "$work/owned/recording" <<'SH'
#!/bin/bash
printf '%s\n' "$*"
exit 7
SH
chmod +x "$work/owned/recording"
check refuses sqlite_capture "$work/owned" "$work/capture" probe "$work/owned/recording" --stage operator
check test -f "$work/capture/live.after"
check test -f "$work/capture/failed"
check grep -q 'exit=7' "$work/capture/probe.command"
# The child's HOME is explicit and inherited shell/library injections disappear.
cat > "$work/owned/environment" <<'SH'
#!/bin/bash
[[ $HOME == "$1" && ! ${BASH_ENV+x} && ! ${LD_LIBRARY_PATH+x} && ! ${PYTHONPATH+x} ]]
SH
chmod +x "$work/owned/environment"
check sqlite_capture "$work/owned" "$work/capture" environment "$work/owned/environment" "$work/owned"
check refuses sqlite_capture "$work/owned" "$work/capture" wrong-home "$work/owned/environment" "$work/live"
# Operator wrapper diagnostics remain available without corrupting probe JSON.
cat > "$work/owned/operator" <<'SH'
#!/bin/bash
printf 'DIR=fixture\n' >&2
printf '{"outcome":"passed"}\n'
SH
chmod +x "$work/owned/operator"
check sqlite_capture "$work/owned" "$work/capture" operator "$work/owned/operator"
check grep -qx '{"outcome":"passed"}' "$work/capture/operator.log"
check grep -qx 'DIR=fixture' "$work/capture/operator.stderr"
# An external change on the failure path invalidates preservation even with a saved mtime.
printf changed > "$work/live/payload"
rm "$work/capture/preservation"
check refuses sqlite_capture "$work/owned" "$work/capture" failure-after-change "$work/owned/recording"
check test ! -e "$work/capture/preservation"
# Internal payload hardlinks are allowed; only links outside the owned tree fail.
ln "$work/owned/sentinel" "$work/owned/internal-link"
check sqlite_boundary "$work/owned"
rm "$work/owned/internal-link"
# Execute the actual CLI state machine in an isolated fixture process. Only host
# allocation/OS observations are replaced; production has no bypass switches.
state_machine() (
    set -euo pipefail
    local fixture=$work/role${1:+-$1} control path item hash parser=$author_python
    if command -v cygpath >/dev/null; then parser=$(cygpath -u "$parser"); fi
    mkdir -p "$fixture"/{cplx/{bin,echos,closure,tools/python},tools/python/{bin,root/usr/lib64,python-3.13.15/lib/python3.13/lib-dynload},pkgs,evidence}
    for control in .env .env_ scalars cplx/.env cplx/.env_user cplx/.env_init cplx/cplx.properties \
        cplx/rsync_include.txt cplx/rsync_exclude.txt cplx/tools/install cplx/tools/install_functions.sh \
        cplx/tools/python/python_install_functions.sh cplx/tools/python/sqlite_probe.py; do
        printf '# recording fixture\n' > "$fixture/$control"
    done
    printf 'printf "recorded deployment\\n"\n' > "$fixture/cplx/bin/install_pkg.sh"
    printf 'fixture' > "$fixture/pkgs/tools.fixture.tar.gz"
    hash=$(sqlite_digest "$fixture/pkgs/tools.fixture.tar.gz")
    touch "$fixture/tools/python/root/usr/lib64/libsqlite3.so.0" \
        "$fixture/tools/python/python-3.13.15/lib/python3.13/lib-dynload/_sqlite3.so"
    "$author_python" -B - "$work/result.json" "$fixture" "$fixture/result.json" <<'PY'
import json
from pathlib import Path
import sys
original, root, target = sys.argv[1:]
record = json.loads(Path(original).read_text())
record['executable'] = root + '/tools/python/bin/python'
record['extension']['path'] = root + '/tools/python/python-3.13.15/lib/python3.13/lib-dynload/_sqlite3.so'
record['extension']['import_path'] = record['extension']['path']
record['provider']['path'] = root + '/tools/python/root/usr/lib64/libsqlite3.so.0'
Path(target).write_text(json.dumps(record))
PY
    # The emitted child, not this fixture generator, expands HOME.
    # shellcheck disable=SC2016
    { printf '#!/bin/bash\n[[ $HOME == %q ]] || exit 9\n' "$fixture";
      printf 'cat %q\n' "$fixture/result.json"; } > "$fixture/tools/python/bin/python"
    chmod +x "$fixture/tools/python/bin/python"
    for item in .env .env_ scalars cplx; do
        while IFS= read -r -d '' path; do
            printf '%s  %s\n' "$(sqlite_digest "$path")" "${path#"$fixture/"}"
        done < <(find "$fixture/$item" -type f -print0)
    done > "$fixture/audit"
    # Called by the sourced production phase function through Bash dynamic scope.
    # shellcheck disable=SC2317
    sqlite_anchor() { [[ $1 == "$fixture" && $2 == rhel ]]; }
    # shellcheck disable=SC2317
    sqlite_host() { printf 'fixture, no candidate OS observation\n' > "$2/os-release"; }
    local -a args=(--home "$fixture" --role rhel --evidence "$fixture/evidence" --parser "$parser"
        --audit "$fixture/audit" --audit-sha256 "$(sqlite_digest "$fixture/audit")" --settings "$fixture/scalars"
        --revision 0000000000000000000000000000000000000000 --live-root "$work/live"
        --probe "$fixture/cplx/tools/python/sqlite_probe.py" --archive "$fixture/pkgs/tools.fixture.tar.gz" --sha256 "$hash"
        --expected-python-root "$fixture/tools/python" --expected-extension-root "$fixture/tools/python/python-3.13.15/lib/python3.13/lib-dynload"
        --expected-provider "$fixture/tools/python/root/usr/lib64/libsqlite3.so.0")
    [[ -e $work/profile || -L $work/profile ]] || ln -s "$work/live/payload" "$work/profile"
    if [[ -L $work/profile ]]; then args+=(--live-root "$work/profile"); fi
    for item in preflight deploy probe; do
        if [[ ${1:-} == failed && $item == probe ]]; then
            printf '{"outcome":"failed"}\n' > "$fixture/result.json"
        fi
        sqlite_main "$item" "${args[@]}"
    done
    test -f "$fixture/evidence/role.json"
    test -f "$fixture/evidence/preservation"
)
# Do not put state_machine in check's conditional: production uses set -e.
trap 'cat "$work/state-machine.log" >&2' ERR
state_machine > "$work/state-machine.log" 2>&1
trap - ERR
count=$((count + 1))
# Let the real set-e phase fail outside a conditional, then inspect its EXIT
# capture after function-local variables have unwound.
set +e
state_machine failed > "$work/failed-state-machine.log" 2>&1
status=$?
set -e
check test "$status" = 2
check grep -qx 'phase=probe exit=2' "$work/role-failed/evidence/failed"
check grep -qx passed "$work/role-failed/evidence/preservation"
printf 'SQLite acceptance fixture checks passed: %s (no candidate acceptance)\n' "$count"
