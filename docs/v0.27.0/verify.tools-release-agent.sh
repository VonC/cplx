#!/bin/bash
# Native fixtures for main-chain candidate transport, ABI and full-test evidence.
# All inputs live in an owned scratch tree; no real environment or agent is used.
set -euo pipefail
python='' app='' capture_python=''
while [ "$#" -gt 0 ]; do
    case "$1" in
        --python) python=${2:?}; shift 2 ;;
        --app-repo) app=${2:?}; shift 2 ;;
        --capture-python) capture_python=${2:?}; shift 2 ;;
        *) exit 2 ;;
    esac
done
[[ $python = /* && -x $python && $app = /* && -d $app/ci ]] || exit 2
[[ $capture_python = /* && -x $capture_python ]] || {
    printf 'Required: --capture-python /absolute/application-venv/python\n' >&2; exit 2;
}
# This helper executes inside the application's synchronized venv in CI.
# Require its dependencies there, without polluting the independent checks.
"$capture_python" -I - <<'PY'
import packaging
import sys
import tomllib

assert sys.prefix != sys.base_prefix, "capture interpreter must be a venv"
print("Capture interpreter:", sys.executable, sys.version)
print("Capture dependency:", packaging.__version__, packaging.__file__)
PY
root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/tools-agent-fixtures.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
mkdir -p "$scratch/app/tools" "$scratch/bin"
cp -a "$app/ci" "$scratch/app/"
printf 'off\n' > "$scratch/app/tools/publish.mode"
printf '9.13.4\n' > "$scratch/app/tools/tools.version"
export WORKSPACE=$scratch/app PREFIX=$scratch/app/prefix
export TOOLS_AUTHORING_PYTHON=$python
export CA_BUNDLE=$scratch/fixture-ca
touch "$CA_BUNDLE"
cases=0
expect() {
    local wanted=$1 label=$2 code=0
    shift 2
    "$@" > "$scratch/$label.log" 2>&1 || code=$?
    if [[ $wanted == pass && $code != 0 || $wanted == fail && $code == 0 ]]; then
        printf 'FAIL %s exit=%s\n' "$label" "$code"
        tail -n 30 "$scratch/$label.log"
        exit 1
    fi
    printf 'PASS %s\n' "$label"
    cases=$((cases + 1))
}
select_mode() { bash "$WORKSPACE/ci/tools_candidate.sh" select; }
sqlite_pin() (
    # shellcheck source=/dev/null
    source "$WORKSPACE/ci/tools_candidate.sh"
    PUBLISH_MODE=snapshot tools_candidate_read "$WORKSPACE/tools/tools.candidate" sqlite
)
expect pass release-pin select_mode
grep -qx release "$scratch/release-pin.log"
expect fail release-venv-needs-verifier bash "$WORKSPACE/ci/provision_toolchain.sh" venv
grep -Fq 'Release provisioning requires tools/tools.verification' "$scratch/release-venv-needs-verifier.log"
[[ ! -e $PREFIX ]]
expect fail release-preflight-needs-verifier bash "$WORKSPACE/ci/tools_candidate.sh" preflight
grep -Fq 'tools/tools.verification' "$scratch/release-preflight-needs-verifier.log"
printf 'archive_url=https://fixture/archive\n' > "$WORKSPACE/tools/tools.candidate"
expect fail partial-candidate select_mode
sha=$(printf bytes | sha256sum); sha=${sha%% *}
revision=1111111111111111111111111111111111111111
cat > "$WORKSPACE/tools/tools.candidate" <<EOF
archive_url=https://fixture/archive
archive_sha256=$sha
bundle_url=https://fixture/bundle
bundle_sha256=$sha
revision=$revision
EOF
expect pass complete-candidate select_mode
grep -qx candidate "$scratch/complete-candidate.log"
expect fail uploads-on env PUBLISH_MODE=snapshot bash "$WORKSPACE/ci/tools_candidate.sh" select
expect fail legacy-conflict env TOOLS_VALIDATION_SHA256="$sha" bash "$WORKSPACE/ci/tools_candidate.sh" select
touch "$WORKSPACE/tools/tools.verification"
expect fail verifier-conflict select_mode
rm "$WORKSPACE/tools/tools.verification"
cp "$WORKSPACE/tools/tools.candidate" "$scratch/pin"
printf 'revision=%s\n' "$revision" >> "$WORKSPACE/tools/tools.candidate"
expect fail duplicate-pin select_mode
cp "$scratch/pin" "$WORKSPACE/tools/tools.candidate"
printf 'snapshot\n' > "$WORKSPACE/tools/publish.mode"
expect fail tracked-uploads-on env PUBLISH_MODE=off bash "$WORKSPACE/ci/tools_candidate.sh" select
expect pass sqlite-diagnostic-with-uploads sqlite_pin
printf 'off\n' > "$WORKSPACE/tools/publish.mode"

# Independent bundle extraction refuses traversal, links and identity drift.
"$python" - "$scratch" "$root" <<'PY'
import hashlib, io, pathlib, sys, tarfile
scratch, root = map(pathlib.Path, sys.argv[1:])
files = {"src/setups/env/bin/probe.sh": b"echo verified\n",
         "acceptance/source-revision.txt": b"1" * 40 + b"\n"}
manifest = "".join(hashlib.sha256(value).hexdigest() + "  " + name + "\n"
                   for name, value in files.items())
files["acceptance/verification.sha256"] = manifest.encode()
for kind in ("bundle", "unsafe", "bad-manifest", "bad-revision", "link", "legacy"):
    members = dict(files)
    if kind == "unsafe": members["../escape"] = b"unsafe"
    if kind == "bad-manifest": members["src/setups/env/bin/probe.sh"] = b"changed"
    if kind == "bad-revision": members["acceptance/source-revision.txt"] = b"2" * 40 + b"\n"
    if kind == "legacy": del members["acceptance/verification.sha256"]
    with tarfile.open(scratch / (kind + ".tar.gz"), "w:gz") as tar:
        for name, value in members.items():
            info = tarfile.TarInfo(name); info.size = len(value)
            tar.addfile(info, io.BytesIO(value))
        if kind == "link":
            info = tarfile.TarInfo("src/link"); info.type = tarfile.SYMTYPE; info.linkname = "/tmp"
            tar.addfile(info)
PY
bundle() { "$python" "$WORKSPACE/ci/tools_candidate_bundle.py" "$scratch/$1.tar.gz" "$scratch/$1-out" "$revision"; }
expect pass bundle-manifest bundle bundle
for kind in unsafe bad-manifest bad-revision link; do expect fail "$kind" bundle "$kind"; done
expect fail main-refuses-legacy bundle legacy
expect pass sqlite-legacy-bundle "$python" "$WORKSPACE/ci/tools_candidate_bundle.py" \
    "$scratch/legacy.tar.gz" "$scratch/legacy-out" "$revision" sqlite
[[ -f $scratch/legacy-out/acceptance/verification.sha256 ]]
cat > "$scratch/bin/curl" <<'CURL'
#!/bin/bash
while [ "$#" -gt 0 ]; do
    case "$1" in -o) output=$2; shift 2 ;; https://*) url=$1; shift ;; *) shift ;; esac
done
case "$url" in
    */archive) cp "$FIXTURE_ARCHIVE" "$output" ;;
    */bundle) cp "$FIXTURE_BUNDLE" "$output" ;;
    *) exit 2 ;;
esac
CURL
chmod +x "$scratch/bin/curl"
printf archive > "$scratch/archive.tar.gz"
export FIXTURE_ARCHIVE=$scratch/archive.tar.gz FIXTURE_BUNDLE=$scratch/bundle.tar.gz
expect fail digest-before-extraction env PATH="$scratch/bin:$PATH" \
    bash "$WORKSPACE/ci/tools_candidate.sh" fetch "$scratch/download"
[[ ! -e $scratch/download/verification ]]
grep -q 'FAILED' "$scratch/digest-before-extraction.log"
archive_sha=$(sha256sum "$FIXTURE_ARCHIVE"); archive_sha=${archive_sha%% *}
bundle_sha=$(sha256sum "$FIXTURE_BUNDLE"); bundle_sha=${bundle_sha%% *}
sed -e "s/^archive_sha256=.*/archive_sha256=$archive_sha/" \
    -e "s/^bundle_sha256=.*/bundle_sha256=$bundle_sha/" "$scratch/pin" > "$WORKSPACE/tools/tools.candidate"
expect pass verified-transport env PATH="$scratch/bin:$PATH" \
    bash "$WORKSPACE/ci/tools_candidate.sh" fetch "$scratch/verified"
[[ -f $scratch/verified/verification/src/setups/env/bin/probe.sh ]]
expect fail occupied-transport env PATH="$scratch/bin:$PATH" \
    bash "$WORKSPACE/ci/tools_candidate.sh" fetch "$scratch/verified"
mv "$WORKSPACE/tools/tools.candidate" "$scratch/candidate-pin"
grep -E '^(bundle_url|bundle_sha256|revision)=' "$scratch/candidate-pin" > "$WORKSPACE/tools/tools.verification"
expect pass verifier-release-select select_mode
expect pass verifier-release-preflight bash "$WORKSPACE/ci/tools_candidate.sh" preflight
expect pass verifier-release-fetch env PATH="$scratch/bin:$PATH" \
    bash "$WORKSPACE/ci/tools_candidate.sh" verification "$scratch/release-controls"
[[ ! -e $scratch/release-controls/archive.tar.gz ]]
rm "$WORKSPACE/tools/tools.verification"
mv "$scratch/candidate-pin" "$WORKSPACE/tools/tools.candidate"

# Execute the same transport/provision entry point Jenkins uses. Docker and
# HTTP are controlled boundaries; all identity and checksum logic stays real.
cat > "$scratch/bin/docker" <<'DOCKER'
#!/bin/bash
[[ $1 == inspect && $2 == --format && $3 == '{{.Image}}' && $4 == "$DOCKER_CONTAINER_ID" ]] || exit 2
printf 'sha256:%064d\n' 1
DOCKER
chmod +x "$scratch/bin/docker"
export DOCKER_CONTAINER_ID=123456789abc
expect pass provision-fetch env PATH="$scratch/bin:$PATH" bash "$WORKSPACE/ci/provision_toolchain.sh" fetch
cmp "$FIXTURE_ARCHIVE" "$PREFIX/pkgs/tools.9.13.4.tar.gz"
grep -q '^image=sha256:' "$WORKSPACE/a.evidence/runtime.txt"
# shellcheck source=/dev/null
source "$WORKSPACE/ci/tools_candidate.sh"
expect pass independent-controls tools_verification_path
printf changed >> "$PREFIX/candidate/verification/src/setups/env/bin/probe.sh"
expect fail changed-controls tools_verification_path
expect fail missing-interpreter tools_python_path
mkdir -p "$PREFIX/tools/python/python-3.13.15/bin"
ln -s python-3.13.15 "$PREFIX/tools/python/current"
touch "$PREFIX/tools/python/current/bin/python3.13_bin"
chmod +x "$PREFIX/tools/python/current/bin/python3.13_bin"
expect pass one-interpreter tools_python_path
expect pass same-venv bash "$WORKSPACE/ci/provision_toolchain.sh" venv-path
venv=$(cat "$scratch/same-venv.log")
[[ $venv == "$PREFIX/pdfs/"* ]]
venv=${venv#"$PREFIX/pdfs/"}
[[ $venv =~ ^([^/]+)/venvs/python_3\.13\.15_([^/]+)$ ]]
[[ ${BASH_REMATCH[1]} == "${BASH_REMATCH[2]}" ]]
touch "$PREFIX/tools/python/current/bin/python3.14_bin"
chmod +x "$PREFIX/tools/python/current/bin/python3.14_bin"
expect fail ambiguous-interpreter tools_python_path
printf changed >> "$PREFIX/pkgs/tools.9.13.4.tar.gz"
expect fail changed-archive-before-relocate bash "$WORKSPACE/ci/provision_toolchain.sh" relocate
grep -q FAILED "$scratch/changed-archive-before-relocate.log"
[[ ! -e $PREFIX/bootstrap ]]
expect fail missing-image env DOCKER_CONTAINER_ID=invalid bash "$WORKSPACE/ci/tools_agent_identity.sh" "$scratch/missing-identity.txt"

# The parser fixtures exercise real provider paths and preserve raw observations.
# Application hooks use Python 3.10+ annotation syntax. Exercise their actual
# sources with the explicit application interpreter, not the bare reader's 3.9.
"$capture_python" -I "$root/docs/v0.27.0/fixtures.tools-release-agent.py" "$app" "$scratch"
"$capture_python" -I "$root/docs/v0.27.0/fixtures.tools-release-agent.py" "$app" "$scratch" --wheels

# Groovy owns orchestration; these assertions cover its exact shell entry points.
"$python" - "$app" <<'PY'
from pathlib import Path
import sys
app = Path(sys.argv[1])
jenkins = (app / "Jenkinsfile").read_text()
provision = (app / "ci/provision_toolchain.sh").read_text()
relocation = (app / "ci/Jenkinsfile.relocation").read_text()
diagnostics = (app / "ci/Jenkinsfile.diagnostics").read_text()
for retired in ("patchVenvElves", "patch-wheels", "tools-patch", "RSYNC_SHIM", "--no-cov", "no:pytest-testmon"):
    assert retired not in jenkins + provision + relocation, retired
assert "tools_test_acceptance.sh" in jenkins
assert 'tools_candidate.sh" preflight' in jenkins
assert "env.TOOLS_SOURCE != 'candidate'" in jenkins
assert "tools_candidate.sh" in provision and "--locked" in provision
assert "tools_wheel_capture.py" in provision and "tools_wheel_inventory.sh" in provision
assert "--wheel-dir" in provision and "--installed-root" in provision
abi = diagnostics.split("def abiContract()", 1)[1]
assert "tools_abi_acceptance.sh" in abi and "exit 0" not in abi
walk = (app / "ci/tools_test_acceptance.sh").read_text()
assert 'pdfss_runtime_run "$UV_PROJECT_ENVIRONMENT/bin/python" -m pytest' in walk
assert "uv run" not in walk
print("PASS main-chain-wiring")
PY
printf 'Agent shell fixtures: %s cases passed; parser and wiring fixtures passed\n' "$cases"
