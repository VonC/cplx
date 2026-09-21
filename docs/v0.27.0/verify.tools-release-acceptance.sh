#!/bin/bash
# Step 6 fixtures for the platform acceptance driver and the bundle composition.
# Every input lives in an owned scratch tree; no archive is relocated, no host
# environment is read and no result here is candidate acceptance evidence.
#
# Covered: the bundle is composed from a commit and verified from its own bytes
# on both sides (composer and consumer, including the consuming project's bundle
# adapter); the driver refuses missing pins, wrong identities, an occupied or
# misplaced run home and cells bound to another archive; fail and inconclusive
# statuses are kept as recorded; a required cell that never ran stays pending;
# a pass without a retained capture cannot summarize as a pass; the Debian
# evidence reader maps a retained build to cells and refuses a foreign identity
# or a drifted lock; and the D10 wrapper allows exactly one rebuild.
set -euo pipefail
python='' app=''
while [ "$#" -gt 0 ]; do
    case "$1" in
        --python) python=${2:?--python needs a path}; shift 2 ;;
        --app-repo) app=${2:?--app-repo needs a path}; shift 2 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done
[[ $python = /* && -x $python && $app = /* && -d $app/ci ]] || {
    printf 'Explicit absolute --python and --app-repo paths are required\n' >&2; exit 2;
}
[[ $(uname -s) = Linux ]] || { printf 'Native Linux is required\n' >&2; exit 5; }
root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd)
driver=$root/docs/v0.27.0/acceptance.tools-archive-rebuild.sh
deliver=$root/ci/deliver-closure-tools.sh
scratch=$(mktemp -d "${TMPDIR:-/tmp}/tools-acceptance.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
export GIT_AUTHOR_NAME=fixture GIT_AUTHOR_EMAIL=fixture@example.invalid
export GIT_COMMITTER_NAME=fixture GIT_COMMITTER_EMAIL=fixture@example.invalid
cases=0
expect() {
    local wanted=$1 label=$2 code=0
    shift 2
    "$@" > "$scratch/$label.log" 2>&1 || code=$?
    if [[ $code != "$wanted" ]]; then
        printf 'FAIL %s exit=%s wanted=%s\n' "$label" "$code" "$wanted"
        tail -n 30 "$scratch/$label.log"
        exit 1
    fi
    printf 'PASS %s\n' "$label"
    cases=$((cases + 1))
}
said() { grep -q -- "$2" "$scratch/$1.log" || { printf 'FAIL %s: expected %s\n' "$1" "$2"; cat "$scratch/$1.log"; exit 1; }; }
sha() { local out; out=$(sha256sum -- "$1"); printf '%s' "${out%% *}"; }
zeros=0000000000000000000000000000000000000000
hexes=0000000000000000000000000000000000000000000000000000000000000000

# --- deployment discovery refuses absent or ambiguous projects and venvs -----
deployfix=$scratch/deployment
expect 1 deployed-project-missing bash "$driver" probe deployed-venv "$deployfix"
mkdir -p "$deployfix/pdfs/my-project/venvs"
expect 1 deployed-venv-missing bash "$driver" probe deployed-venv "$deployfix"
venv=$deployfix/pdfs/my-project/venvs/python_3.13_my-project
mkdir -p "$venv/bin"
touch "$venv/pyvenv.cfg"
expect 0 deployed-venv-unique bash "$driver" probe deployed-venv "$deployfix"
[[ $(cat "$scratch/deployed-venv-unique.log") == "$venv" ]]
cat > "$venv/bin/uv" <<'UV'
#!/bin/bash
[[ $PWD == "$HOME/pdfs/my-project" && $UV_OFFLINE == 1 ]]
UV
chmod +x "$venv/bin/uv"
expect 0 deployed-uv-project bash "$driver" probe uv-audit "$deployfix" "$venv" "$python"
mkdir -p "$deployfix/pdfs/my-project/venvs/python_3.12_my-project"
touch "$deployfix/pdfs/my-project/venvs/python_3.12_my-project/pyvenv.cfg"
expect 1 deployed-venv-ambiguous bash "$driver" probe deployed-venv "$deployfix"
rm "$deployfix/pdfs/my-project/venvs/python_3.12_my-project/pyvenv.cfg"
mkdir "$deployfix/pdfs/another-project"
expect 1 deployed-project-ambiguous bash "$driver" probe deployed-venv "$deployfix"

# --- bundle composition: a commit in, a manifest-checked archive out ----------
repo=$scratch/repo
mkdir -p "$repo/src/setups/env/bin" "$repo/src/setups/env/closure" "$repo/src/utils" "$repo/docs/v0.27.0"
cp "$root"/src/setups/env/bin/*.sh "$repo/src/setups/env/bin/"
cp "$root"/src/setups/env/closure/closure-{config,envelope}.txt "$repo/src/setups/env/closure/"
cp "$root/src/utils/lint_shell.sh" "$repo/src/utils/"
for name in acceptance.python-sqlite-capture.sh acceptance.python-sqlite-deploy.sh \
    acceptance.python-sqlite-namespace.sh acceptance.python-sqlite-report.sh \
    acceptance.python-sqlite-support.sh acceptance.tools-archive-rebuild.sh \
    verify.install-pkg.sh verify.relocation-rpath.sh verify.wrapper-scope.sh \
    verify.wrapper-accept.sh inventory.tools-archive-rebuild.txt; do
    cp "$root/docs/v0.27.0/$name" "$repo/docs/v0.27.0/"
done
git -C "$repo" init -q
git -C "$repo" add -A
git -C "$repo" commit -q -m 'fixture controls'
commit=$(git -C "$repo" rev-parse HEAD)
expect 0 bundle-compose bash "$deliver" --repo "$repo" --commit "$commit" --bundle "$scratch/bundle.tar.gz"
said bundle-compose "^BUNDLE-CHECK|$commit|"
said bundle-compose "^BUNDLE|COMPLETE|$commit|"
bundle_sha=$(sha "$scratch/bundle.tar.gz")
expect 0 bundle-deterministic bash "$deliver" --repo "$repo" --commit "$commit" --bundle "$scratch/bundle-again.tar.gz"
[[ $(sha "$scratch/bundle-again.tar.gz") == "$bundle_sha" ]]
# Windows defaults to binary markers; force that producer behavior on Linux.
mkdir "$scratch/binary-sha"
real_sha=$(command -v sha256sum)
printf '#!/bin/bash\nreal_sha=%q\n' "$real_sha" > "$scratch/binary-sha/sha256sum"
cat >> "$scratch/binary-sha/sha256sum" <<'SHA'
for arg; do
    if [[ $arg == --check ]]; then exec "$real_sha" "$@"; fi
done
exec "$real_sha" --binary "$@"
SHA
chmod +x "$scratch/binary-sha/sha256sum"
expect 0 bundle-binary-manifest env PATH="$scratch/binary-sha:$PATH" bash "$deliver" --repo "$repo" --commit "$commit" --bundle "$scratch/binary.tar.gz"
[[ $(sha "$scratch/binary.tar.gz") == "$bundle_sha" ]]
expect 2 bundle-and-into-refuse bash "$deliver" --repo "$repo" --commit "$commit" --bundle "$scratch/x.tar.gz" --into "$scratch/x"
expect 1 bundle-occupied bash "$deliver" --repo "$repo" --commit "$commit" --bundle "$scratch/bundle.tar.gz"
expect 1 bundle-branch bash "$deliver" --repo "$repo" --commit master --bundle "$scratch/branch.tar.gz"
[[ ! -e $scratch/branch.tar.gz ]]
tar -tzf "$scratch/bundle.tar.gz" > "$scratch/bundle.members"
grep -qx 'acceptance/acceptance.tools-archive-rebuild.sh' "$scratch/bundle.members"
grep -qx 'src/setups/env/bin/install_pkg.sh' "$scratch/bundle.members"
if grep -q '^docs/' "$scratch/bundle.members"; then printf 'FAIL: the bundle carries docs/ members\n'; exit 1; fi
# The consumer's side: this repository's check and the application's adapter.
expect 0 bundle-check bash "$driver" bundle-check "$scratch/bundle.tar.gz" "$bundle_sha" "$commit" "$scratch/verified"
[[ -f $scratch/verified/acceptance/verification.sha256 && -x $scratch/verified/src/setups/env/bin/install_pkg.sh ]]
expect 2 bundle-check-occupied bash "$driver" bundle-check "$scratch/bundle.tar.gz" "$bundle_sha" "$commit" "$scratch/verified"
expect 2 bundle-check-wrong-digest bash "$driver" bundle-check "$scratch/bundle.tar.gz" "$hexes" "$commit" "$scratch/verified2"
expect 2 bundle-check-wrong-revision bash "$driver" bundle-check "$scratch/bundle.tar.gz" "$bundle_sha" "$zeros" "$scratch/verified2"
[[ ! -e $scratch/verified2 ]]
expect 0 app-adapter-accepts "$python" "$app/ci/tools_candidate_bundle.py" "$scratch/bundle.tar.gz" "$scratch/app-verified" "$commit"
said app-adapter-accepts '^verification_files='
expect 2 app-adapter-revision "$python" "$app/ci/tools_candidate_bundle.py" "$scratch/bundle.tar.gz" "$scratch/app-verified2" "$zeros"
mkdir "$scratch/tamper"
tar -xzf "$scratch/bundle.tar.gz" -C "$scratch/tamper"
printf '# tampered\n' >> "$scratch/tamper/src/setups/env/bin/install_pkg.sh"
tar -czf "$scratch/tampered.tar.gz" -C "$scratch/tamper" src acceptance
expect 2 bundle-check-tampered bash "$driver" bundle-check "$scratch/tampered.tar.gz" "$(sha "$scratch/tampered.tar.gz")" "$commit" "$scratch/verified3"
said bundle-check-tampered 'manifest does not cover'
expect 2 app-adapter-tampered "$python" "$app/ci/tools_candidate_bundle.py" "$scratch/tampered.tar.gz" "$scratch/app-verified3" "$commit"
git -C "$repo" rm -q docs/v0.27.0/verify.wrapper-accept.sh
git -C "$repo" commit -q -m 'drop one control'
expect 1 bundle-missing-control bash "$deliver" --repo "$repo" --commit "$(git -C "$repo" rev-parse HEAD)" --bundle "$scratch/missing.tar.gz"
said bundle-missing-control 'holds no blob at docs/v0.27.0/verify.wrapper-accept.sh'
[[ ! -e $scratch/missing.tar.gz ]]
git -C "$repo" revert --no-edit HEAD > /dev/null
ln -s closure_check.sh "$repo/src/setups/env/bin/alias.sh"
git -C "$repo" add -A
git -C "$repo" commit -q -m 'a link below src'
expect 1 bundle-link-refuses bash "$deliver" --repo "$repo" --commit "$(git -C "$repo" rev-parse HEAD)" --bundle "$scratch/link.tar.gz"
said bundle-link-refuses 'link or special file'
[[ ! -e $scratch/link.tar.gz ]]

# --- the driver's pins: nothing runs before every identity is checked -------
fake=$scratch/fake
mkdir -p "$fake"
printf 'archive\n' > "$fake/tools.2026-01-01_000000.tar.gz"
printf 'pdfs\n' > "$fake/pdfs.2026-01-01_000000.tar.gz"
printf '#!/bin/bash\nexit 0\n' > "$fake/deploy_pkgs.sh"
printf '#!/bin/bash\nexit 0\n' > "$fake/install_pkg.old.sh"
archive_sha=$(sha "$fake/tools.2026-01-01_000000.tar.gz")
home=/home/$(id -un)/tools-acceptance-fixture-$$
pins=(--run fixture-run --home "$home" --python "$python" --archive "$fake/tools.2026-01-01_000000.tar.gz"
    --archive-sha256 "$archive_sha" --bundle "$scratch/bundle.tar.gz" --bundle-sha256 "$bundle_sha"
    --revision "$commit" --pdfs "$fake/pdfs.2026-01-01_000000.tar.gz" --deploy-script "$fake/deploy_pkgs.sh"
    --deploy-script-sha256 "$(sha "$fake/deploy_pkgs.sh")" --previous-installer "$fake/install_pkg.old.sh"
    --previous-installer-sha256 "$(sha "$fake/install_pkg.old.sh")")
rhel() { bash "$driver" rhel "$@"; }
expect 2 rhel-no-pins rhel --run fixture-run
expect 2 rhel-wrong-archive rhel "${pins[@]}" --archive-sha256 "$hexes"
said rhel-wrong-archive 'archive digest differs from its pin'
expect 2 rhel-wrong-deploy rhel "${pins[@]}" --deploy-script-sha256 "$hexes"
expect 2 rhel-wrong-previous rhel "${pins[@]}" --previous-installer-sha256 "$hexes"
# TMPDIR may itself live below /home; use a literal outside that boundary.
expect 2 rhel-home-outside rhel "${pins[@]}" --home "/var/tmp/tools-acceptance-outside-$$"
said rhel-home-outside 'below /home'
expect 2 rhel-home-occupied rhel "${pins[@]}" --home "/home/$(id -un)"
expect 2 rhel-bad-run rhel "${pins[@]}" --run 'not a token'
expect 2 rhel-latest-archive rhel "${pins[@]}" --archive "$scratch/bundle.tar.gz" --archive-sha256 "$bundle_sha"
said rhel-latest-archive 'timestamped'
[[ ! -e $home ]]

# --- summarize: cells are read, never re-decided ----------------------------
run_home() {
    local name=$1 role=$2 dir=$scratch/run-$1
    mkdir -p "$dir/cells" "$dir/raw" "$dir/inputs"
    printf 'run=fixture-run\nrole=%s\nschema=tools-archive-rebuild-acceptance/1\narchive=tools.2026-01-01_000000.tar.gz\narchive_sha256=%s\nbundle_sha256=%s\nrevision=%s\nelapsed_seconds=7\n' \
        "$role" "$archive_sha" "$bundle_sha" "$commit" > "$dir/inputs/pins"
    printf '%s\n' "$archive_sha" > "$dir/inputs/transfer.sha256"
    printf 'PRETTY_NAME="Fixture OS"\nkernel=0.0\n' > "$dir/raw/environment.txt"
    printf 'observation\n' > "$dir/raw/probe.log"
    printf '%s' "$dir"
}
cell() { # DIR CELL STATE ARCHIVE [CAPTURE...]
    local dir=$1 name=$2 state=$3 identity=$4 capture
    shift 4
    { printf 'cell=%s\nstate=%s\nreason=fixture\narchive_sha256=%s\nrun=fixture-run\n' "$name" "$state" "$identity"
      for capture in "$@"; do printf 'capture=%s\n' "$capture"; done; } > "$dir/cells/$name"
}
rhel_cells=(AR3 PA1:rhel PA2:rhel PA3:rhel-build PA3:rhel-deploy PA4:rhel PA5:rhel PA6:rhel PA10:rhel PA11:rhel)
dir=$(run_home all-pass rhel)
for name in "${rhel_cells[@]}"; do cell "$dir" "$name" pass "$archive_sha" raw/probe.log; done
summarize() { bash "$driver" summarize --home "$1" --python "$python" --role "$2" --out "$1/results.json"; }
expect 0 summarize-all-pass summarize "$dir" rhel
said summarize-all-pass '^SUMMARY|rhel|fixture-run|pass|10 cells|0 missing'
"$python" - "$dir/results.json" "$archive_sha" "$(sha "$dir/raw/probe.log")" <<'PY'
import json, sys
record = json.load(open(sys.argv[1]))
assert record["verdict"] == "pass" and record["missing"] == [] and record["pins"]["archive_sha256"] == sys.argv[2]
assert record["captures"]["raw/probe.log"]["sha256"] == sys.argv[3] and record["elapsed_seconds"] == 7
assert all(cell["state"] == "pass" and cell["captures"] == ["raw/probe.log"] for cell in record["cells"].values())
assert record["environment"]["PRETTY_NAME"] == "Fixture OS" and record["environment"]["kernel"] == "0.0"
assert not any(cell["reason"].startswith("/") for cell in record["cells"].values())
PY
dir=$(run_home one-fail rhel)
for name in "${rhel_cells[@]}"; do cell "$dir" "$name" pass "$archive_sha" raw/probe.log; done
cell "$dir" PA5:rhel fail "$archive_sha" raw/probe.log
expect 1 summarize-one-fail summarize "$dir" rhel
said summarize-one-fail '|fail|'
dir=$(run_home inconclusive rhel)
for name in "${rhel_cells[@]}"; do cell "$dir" "$name" pass "$archive_sha" raw/probe.log; done
cell "$dir" PA6:rhel inconclusive "$archive_sha" raw/probe.log
expect 5 summarize-inconclusive summarize "$dir" rhel
said summarize-inconclusive '|incomplete|'
dir=$(run_home skipped rhel)
for name in "${rhel_cells[@]}"; do [[ $name == PA10:rhel ]] || cell "$dir" "$name" pass "$archive_sha" raw/probe.log; done
expect 5 summarize-skipped-role summarize "$dir" rhel
said summarize-skipped-role '|incomplete|10 cells|1 missing'
"$python" -c 'import json,sys; r=json.load(open(sys.argv[1])); assert r["cells"]["PA10:rhel"]["state"]=="pending" and r["missing"]==["PA10:rhel"]' "$dir/results.json"
dir=$(run_home no-capture rhel)
for name in "${rhel_cells[@]}"; do cell "$dir" "$name" pass "$archive_sha" raw/probe.log; done
cell "$dir" PA2:rhel pass "$archive_sha"
expect 5 summarize-pass-without-capture summarize "$dir" rhel
"$python" -c 'import json,sys; r=json.load(open(sys.argv[1])); assert r["cells"]["PA2:rhel"]["state"]=="inconclusive"' "$dir/results.json"
dir=$(run_home foreign rhel)
for name in "${rhel_cells[@]}"; do cell "$dir" "$name" pass "$archive_sha" raw/probe.log; done
cell "$dir" AR3 pass "$hexes" raw/probe.log
expect 2 summarize-foreign-archive summarize "$dir" rhel
said summarize-foreign-archive 'bound to another archive'
dir=$(run_home drifted rhel)
for name in "${rhel_cells[@]}"; do cell "$dir" "$name" pass "$archive_sha" raw/probe.log; done
printf '%s\n' "$hexes" > "$dir/inputs/transfer.sha256"
expect 2 summarize-drifted-transfer summarize "$dir" rhel
dir=$(run_home unknown-state rhel)
for name in "${rhel_cells[@]}"; do cell "$dir" "$name" pass "$archive_sha" raw/probe.log; done
cell "$dir" PA4:rhel skipped "$archive_sha" raw/probe.log
expect 2 summarize-unknown-state summarize "$dir" rhel
dir=$(run_home wrong-role rhel)
expect 2 summarize-wrong-role summarize "$dir" debian

# --- the Debian evidence reader ----------------------------------------------
app_revision=$(git -C "$app" rev-parse HEAD)
evidence() { # NAME: a complete retained build, then callers remove pieces
    local dir=$scratch/evidence-$1 tree
    tree=$dir/a.evidence
    mkdir -p "$tree/abi" "$tree/test-walk.fixture" "$dir/wheels" "$dir/sqlite/evidence"
    cat > "$dir/console.txt" <<CONSOLE
publish mode from tools/publish.mode: off
toolchain source: candidate
CPLX-ELF/1 obj case=6 rpath=rewritten interp=rewritten path=70
CPLX-ELF/1 end state=completed reason=none walked=1 r-rewritten=1 r-failed=0 r-already-correct=0 r-not-dynamic=0 r-excluded=0 i-rewritten=1 i-failed=0 i-unchanged=0 i-not-applicable=0 mig-checked=0 mig-failed=0
toolchain python ELF: prefix/tools/python/current/bin/python3.13_bin
Python 3.13.15
imports ok
git version 2.52.0
uv sync --locked
venv_base=prefix/tools/python/current/bin/python3.13_bin
ABI PASS: subjects=3 dynamic=2 flags=0
Full acceptance PASS: collected=4 executed=4 setup_skipped=0; coverage=100%
CONSOLE
    printf 'revision=%s\narchive_sha256=%s\nbundle_sha256=%s\n' "$commit" "$archive_sha" "$bundle_sha" > "$tree/identity"
    printf 'build=207\nnode=agent\nPRETTY_NAME="Debian GNU/Linux 12 (bookworm)"\ncontainer=0123456789ab\nimage=sha256:%s\n' "$hexes" > "$tree/runtime.txt"
    printf '%s  src/x\n' "$hexes" > "$tree/verification.sha256"
    printf 'closure PASS\n' > "$tree/abi-closure.txt"
    printf 'wheels load\n' > "$tree/abi/imports.txt"
    printf 'provider|x\n' > "$tree/abi/providers.txt"
    printf 'trace\n' > "$tree/abi/ld-debug.1234"
    printf 'OBJECTIVE MET for step 5 (accept)\n' > "$tree/verify-wrapper-accept.debian.txt"
    "$python" - "$tree/test-walk.fixture" <<'PY'
import json, sys
from pathlib import Path
out = Path(sys.argv[1])
guarded = {name: {"collected": 2, "passed": 2, "skipped": 0} for name in
           ("test_conftest_mocks_coverage_repairs_tdd.py", "test_conftest_mocks_batch_recovery_tdd.py")}
(out / "tests.json").write_text(json.dumps({"exit": 0, "collected": 4, "executed": 4, "deselected": 0, "setup_skipped": 0,
    "skipped": [], "plugins": {"pytest-cov": "6", "pytest-testmon": "2"}, "testmon": {"collect": True, "select": False},
    "python": {}, "guarded": guarded}))
(out / "coverage.xml").write_text('<coverage lines-valid="10" lines-covered="10" line-rate="1"></coverage>\n')
PY
    git -C "$app" show "$app_revision:uv.lock" > "$dir/wheels/uv.lock"
    printf '{"wheels": [{"filename": "native-1-py3-none-linux_x86_64.whl", "sha256": "%s", "elfs": []}]}\n' "$hexes" > "$dir/wheels/inventory.json"
    tar -czf "$tree/wheels.tar.gz" -C "$dir/wheels" uv.lock inventory.json
    printf '{"role": "debian", "sha256": "%s", "preservation": "passed", "probe_sha256": "%s"}\n' "$archive_sha" "$hexes" > "$dir/sqlite/evidence/role.json"
    printf '{"outcome": "passed", "database": "passed"}\n' > "$dir/sqlite/evidence/operator.json"
    tar -czf "$tree/sqlite-candidate.debian.tar.gz" -C "$dir/sqlite" evidence
    printf '%s' "$dir"
}
debian() { # NAME EVIDENCE [EXTRA...]
    local name=$1 dir=$2
    shift 2
    bash "$driver" debian --evidence "$dir" --run "build-207" --archive-sha256 "$archive_sha" --bundle-sha256 "$bundle_sha" \
        --revision "$commit" --python "$python" --out "$scratch/debian-$name" --app-repo "$app" --application-revision "$app_revision" "$@"
}
dir=$(evidence complete)
expect 0 debian-complete debian complete "$dir"
said debian-complete '^SUMMARY|debian|build-207|pass|9 cells|0 missing'
"$python" - "$scratch/debian-complete/results.json" "$hexes" "$app_revision" <<'PY'
import hashlib, json, sys
from pathlib import Path
record = json.load(open(sys.argv[1]))
assert record["environment"]["image"] == "sha256:" + sys.argv[2] and record["environment"]["build"] == "207"
assert record["consumers"]["wheels"] == {"native-1-py3-none-linux_x86_64.whl": sys.argv[2]}
assert len(record["consumers"]["lock_sha256"]) == 64 and record["consumers"]["venv_base"].endswith("python3.13_bin")
assert record["cells"]["PA9:debian"]["captures"] and "raw/test-evidence-check.txt" in record["captures"]
raw = Path(sys.argv[1]).parent / "raw"
binding = json.loads((raw / "test-evidence-validator.json").read_text())
assert binding == {"application_revision": sys.argv[3], "path": "ci/tools_test_evidence.py",
                   "sha256": hashlib.sha256((raw / "tools_test_evidence.py").read_bytes()).hexdigest()}
assert "raw/tools_test_evidence.py" in record["captures"]
assert "raw/test-evidence-validator.json" in record["captures"]
PY
dir=$(evidence validator-identity)
expect 2 debian-validator-no-revision debian validator-no-revision "$dir" --application-revision ""
said debian-validator-no-revision 'application revision is required'
expect 2 debian-validator-unknown-revision debian validator-unknown-revision "$dir" --application-revision "$commit"
said debian-validator-unknown-revision 'validator differs from or is unavailable'
# A checkout with the right objects but changed validator bytes must refuse
# before executing the substitute. Never alter the supplied application.
foreign_app=$scratch/foreign-app
mkdir -p "$foreign_app/ci"
printf 'gitdir: %s\n' "$(git -C "$app" rev-parse --absolute-git-dir)" > "$foreign_app/.git"
printf 'raise RuntimeError("UNPINNED VALIDATOR EXECUTED")\n' > "$foreign_app/ci/tools_test_evidence.py"
expect 2 debian-validator-drift debian validator-drift "$dir" --app-repo "$foreign_app"
said debian-validator-drift 'validator differs from or is unavailable'
if grep -q 'UNPINNED VALIDATOR EXECUTED' "$scratch/debian-validator-drift.log"; then
    printf 'FAIL: unpinned validator was executed\n' >&2; exit 1
fi
rm "$foreign_app/ci/tools_test_evidence.py"
expect 2 debian-validator-missing debian validator-missing "$dir" --app-repo "$foreign_app"
said debian-validator-missing 'validator differs from or is unavailable'

dir=$(evidence missing-sync-marker)
sed -i '/^uv sync --locked$/d' "$dir/console.txt"
expect 5 debian-missing-sync-marker debian missing-sync-marker "$dir"
said debian-missing-sync-marker 'CELL|PA6:debian|inconclusive|'
printf 'TOOLS-LOCKED-SYNC/1 state=passed\n' >> "$dir/console.txt"
expect 0 debian-stable-sync-marker debian stable-sync-marker "$dir"
printf 'TOOLS-LOCKED-SYNC/1 state=failed\n' >> "$dir/console.txt"
expect 1 debian-failed-sync debian failed-sync "$dir"
said debian-failed-sync 'CELL|PA6:debian|fail|'

dir=$(evidence missing-import)
printf '' > "$dir/a.evidence/abi/imports.txt"
expect 5 debian-missing-import debian missing-import "$dir"
said debian-missing-import 'CELL|PA6:debian|inconclusive|'
printf 'ImportError: fixture unresolved provider\n' > "$dir/a.evidence/abi/imports.txt"
expect 1 debian-failed-import debian failed-import "$dir"
said debian-failed-import 'CELL|PA6:debian|fail|'

dir=$(evidence browser-scope)
sed -i 's/Full acceptance PASS: collected=4 executed=4 setup_skipped=0;/Acceptance PASS over all tests except the browser cases (stealth-gate Q01): collected=4 executed=4 setup_skipped=0 excluded=1;/' "$dir/console.txt"
"$python" - "$dir/a.evidence/test-walk.fixture/tests.json" <<'PY'
import json, sys
from pathlib import Path
path = Path(sys.argv[1])
record = json.loads(path.read_text())
record.update(markexpr="not browser", deselected=1, excluded=[{"nodeid": "test_browser.py::test_page", "marker": "browser"}])
path.write_text(json.dumps(record))
PY
expect 0 debian-browser-scope debian browser-scope "$dir"
said debian-browser-scope 'not browser evidence'
sed -i 's/collected=4/collected=5/' "$dir/console.txt"
expect 1 debian-browser-count-mismatch debian browser-count-mismatch "$dir"
sed -i 's/collected=5/collected=4/;s/ except the browser cases (stealth-gate Q01)//' "$dir/console.txt"
expect 1 debian-browser-scope-mismatch debian browser-scope-mismatch "$dir"
sed -i 's/PASS over all tests:/PASS over all tests except the browser cases (stealth-gate Q01):/' "$dir/console.txt"
for defect in missing-node duplicate-node wrong-marker wrong-expression; do
    "$python" - "$dir/a.evidence/test-walk.fixture/tests.json" "$defect" <<'PY'
import json, sys
from pathlib import Path
path, defect = Path(sys.argv[1]), sys.argv[2]
record = json.loads(path.read_text())
record.update(markexpr="not browser", deselected=1, excluded=[{"nodeid": "test_browser.py::test_page", "marker": "browser"}])
if defect == "missing-node":
    record["excluded"][0]["nodeid"] = ""
elif defect == "duplicate-node":
    record["excluded"] *= 2
    record["deselected"] = 2
elif defect == "wrong-marker":
    record["excluded"][0]["marker"] = ""
else:
    record["markexpr"] = "not slow"
path.write_text(json.dumps(record))
PY
    expect 1 "debian-browser-$defect" debian "browser-$defect" "$dir"
    said "debian-browser-$defect" 'CELL|PA9:debian|fail|'
done

dir=$(evidence timestamped)
sed -i 's/^/[2026-09-19T14:05:16.123Z] /' "$dir/console.txt"
expect 0 debian-timestamped debian timestamped "$dir"
said debian-timestamped '^SUMMARY|debian|build-207|pass|9 cells|0 missing'
cmp "$dir/console.txt" "$scratch/debian-timestamped/raw/console.txt"
dir=$(evidence dangling-count)
sed -i 's/dynamic=2 flags=0/dynamic=2 dangling-links=488 flags=0/' "$dir/console.txt"
expect 0 debian-dangling-count debian dangling-count "$dir"
said debian-dangling-count '^SUMMARY|debian|build-207|pass|9 cells|0 missing'
sed -i 's/flags=0/flags=01/' "$dir/console.txt"
expect 1 debian-malformed-abi-pass debian malformed-abi-pass "$dir"
dir=$(evidence availability-runtime-counts)
sed -i 's/dynamic=2 flags=0/dynamic=2 availability-rows=8 runtime-rows=3 dangling-links=488 flags=0/' "$dir/console.txt"
expect 0 debian-availability-runtime-counts debian availability-runtime-counts "$dir"
said debian-availability-runtime-counts '^SUMMARY|debian|build-207|pass|9 cells|0 missing'
sed -i 's/runtime-rows=3/runtime-rows=0/' "$dir/console.txt"
expect 1 debian-no-runtime-providers debian no-runtime-providers "$dir"

dir=$(evidence unqualified-system-object)
printf 'system-interpreter-object|venv/node|/lib64/ld-linux-x86-64.so.2\n' >> "$dir/a.evidence/abi/providers.txt"
expect 5 debian-unqualified-system-object debian unqualified-system-object "$dir"
said debian-unqualified-system-object 'CELL|PA7:debian|inconclusive|system-loader objects'

dir=$(evidence mapped-system-object)
printf 'system-interpreter-object|venv/node|/lib64/ld-linux-x86-64.so.2\navailability|/prefix/tools/libc.so.6\n' >> "$dir/a.evidence/abi/providers.txt"
printf 'venv/node\n' > "$dir/a.evidence/abi/inventory.txt"
printf 'libc.so.6 => /prefix/tools/libc.so.6 (0x1)\n' > "$dir/a.evidence/abi/0.list.txt"
expect 0 debian-mapped-system-object debian mapped-system-object "$dir"
printf 'excluded-monitoring|/opt/dynatrace/oneagent/agent/bin/current/linux-x86-64/liboneagentproc.so\n' >> "$dir/a.evidence/abi/providers.txt"
printf '/opt/dynatrace/oneagent/agent/bin/current/linux-x86-64/liboneagentproc.so (0x2)\n' >> "$dir/a.evidence/abi/0.list.txt"
expect 0 debian-mapped-system-monitoring debian mapped-system-monitoring "$dir"
printf 'excluded-monitoring|/lib/libc.so.6\n' >> "$dir/a.evidence/abi/providers.txt"
printf '/lib/libc.so.6 (0x3)\n' >> "$dir/a.evidence/abi/0.list.txt"
expect 5 debian-false-monitoring-provider debian false-monitoring-provider "$dir"
sed -i '\|^/lib/libc.so.6 |d' "$dir/a.evidence/abi/0.list.txt"
sed -i '/^availability|/d' "$dir/a.evidence/abi/providers.txt"
expect 5 debian-unbound-system-map debian unbound-system-map "$dir"
printf 'availability|/prefix/tools/libc.so.6\n' >> "$dir/a.evidence/abi/providers.txt"
printf 'libc.so.6 => not found\n' > "$dir/a.evidence/abi/0.list.txt"
expect 5 debian-failed-system-map debian failed-system-map "$dir"

dir=$(evidence system-map-alias)
printf 'system-interpreter-object|venv/node|/lib64/ld-linux-x86-64.so.2\navailability|/prefix/tools/libc-2.34.so\nmap-alias|/prefix/tools/libc.so.6|/prefix/tools/libc-2.34.so\n' > "$dir/a.evidence/abi/providers.txt"
printf 'venv/node\n' > "$dir/a.evidence/abi/inventory.txt"
printf 'libc.so.6 => /prefix/tools/libc.so.6 (0x1)\n' > "$dir/a.evidence/abi/0.list.txt"
expect 0 debian-system-map-alias debian system-map-alias "$dir"
sed -i 's|map-alias.*|map-alias\|/prefix/tools/libc.so.6\|/lib/libc.so.6|' "$dir/a.evidence/abi/providers.txt"
expect 5 debian-system-map-host-alias debian system-map-host-alias "$dir"
printf 'map-alias|/prefix/tools/libc.so.6|/prefix/tools/libc-2.34.so\n' >> "$dir/a.evidence/abi/providers.txt"
expect 5 debian-system-map-conflicting-alias debian system-map-conflicting-alias "$dir"
printf 'map-alias|/prefix/tools/broken\n' >> "$dir/a.evidence/abi/providers.txt"
expect 5 debian-system-map-malformed-alias debian system-map-malformed-alias "$dir"

dir=$(evidence timestamped-failure)
sed -i 's/^/[2026-09-19T10:20:30.123Z] /' "$dir/console.txt"
sed -i 's/ABI PASS:.*/ABI INCONCLUSIVE\/FAIL: outside provider: \/usr\/lib\/libstdc++.so.6/' "$dir/console.txt"
expect 1 debian-timestamped-fail debian timestamped-fail "$dir"

dir=$(evidence foreign)
printf 'revision=%s\narchive_sha256=%s\nbundle_sha256=%s\n' "$commit" "$hexes" "$bundle_sha" > "$dir/a.evidence/identity"
expect 2 debian-foreign-identity debian foreign "$dir"
said debian-foreign-identity 'differs from the pinned'
dir=$(evidence drifted-lock)
printf 'drift\n' >> "$dir/wheels/uv.lock"
tar -czf "$dir/a.evidence/wheels.tar.gz" -C "$dir/wheels" uv.lock inventory.json
expect 2 debian-drifted-lock debian drifted-lock "$dir"
said debian-drifted-lock 'uv.lock differs'
dir=$(evidence no-abi)
rm -r "$dir/a.evidence/abi" "$dir/a.evidence/abi-closure.txt"
sed -i '/^ABI PASS/d' "$dir/console.txt"
expect 5 debian-missing-abi debian no-abi "$dir"
said debian-missing-abi '|incomplete|9 cells|4 missing'
dir=$(evidence abi-fail)
sed -i 's/^ABI PASS.*/ABI INCONCLUSIVE\/FAIL: outside provider: \/usr\/lib\/libstdc++.so.6/' "$dir/console.txt"
expect 1 debian-abi-fail debian abi-fail "$dir"
"$python" -c 'import json,sys; r=json.load(open(sys.argv[1])); assert r["cells"]["PA7:debian"]["state"]=="fail" and r["cells"]["PA5:debian"]["state"]=="fail"' "$scratch/debian-abi-fail/results.json"
dir=$(evidence abi-trace)
sed -i 's/^ABI PASS.*/ABI INCONCLUSIVE\/FAIL: expected one direct-venv process trace/' "$dir/console.txt"
expect 5 debian-abi-inconclusive debian abi-trace "$dir"
"$python" -c 'import json,sys; r=json.load(open(sys.argv[1])); assert r["cells"]["PA8:debian"]["state"]=="inconclusive" and r["cells"]["PA7:debian"]["state"]=="inconclusive"' "$scratch/debian-abi-trace/results.json"
dir=$(evidence wrapper-fail)
printf 'OBJECTIVE NOT MET for step 5 (accept): 1 failure(s)\n' > "$dir/a.evidence/verify-wrapper-accept.debian.txt"
expect 1 debian-wrapper-fail debian wrapper-fail "$dir"
dir=$(evidence no-sqlite)
rm "$dir/a.evidence/sqlite-candidate.debian.tar.gz"
expect 5 debian-no-sqlite debian no-sqlite "$dir"
"$python" -c 'import json,sys; r=json.load(open(sys.argv[1])); assert r["cells"]["PA3:debian"]["state"]=="pending"' "$scratch/debian-no-sqlite/results.json"
dir=$(evidence tests-refused)
sed -i 's/^Full acceptance PASS.*/Test acceptance refused: SQLite-guarded suite did not execute fully/' "$dir/console.txt"
expect 1 debian-tests-refused debian tests-refused "$dir"
dir=$(evidence guarded-skipped)
"$python" - "$dir/a.evidence/test-walk.fixture/tests.json" <<'PY'
import json, sys
path = sys.argv[1]
record = json.load(open(path))
record["guarded"]["test_conftest_mocks_batch_recovery_tdd.py"] = {"collected": 2, "passed": 0, "skipped": 2}
json.dump(record, open(path, "w"))
PY
expect 1 debian-guarded-skipped debian guarded-skipped "$dir"
said debian-guarded-skipped 'CELL|PA9:debian|fail|'
dir=$(evidence no-walk)
rm -r "$dir/a.evidence/test-walk.fixture"
expect 5 debian-no-walk debian no-walk "$dir"
"$python" -c 'import json,sys; r=json.load(open(sys.argv[1])); assert r["cells"]["PA9:debian"]["state"]=="pending"' "$scratch/debian-no-walk/results.json"
dir=$(evidence shim)
sed -i 's/^toolchain source: candidate/toolchain source: candidate\nRSYNC_SHIM=1/' "$dir/console.txt"
expect 1 debian-shim debian shim "$dir"
said debian-shim 'CELL|PA1:debian|fail|'

# --- D10: one reading, at most one rebuild, never a third iteration ----------
command -v gcc > /dev/null || { printf 'FAIL: gcc is required for the D10 provider fixtures\n' >&2; exit 1; }
d10=$scratch/d10
mkdir -p "$d10/archive" "$d10/gcc11" "$d10/gcc12" "$d10/installed" "$d10/wheels"
cd "$d10"
printf 'fixture lock\n' > uv.lock
printf 'int cxx(void) { return 1; } int abi(void) { return 1; }\n' > cxx.c
printf 'int unwind(void) { return 1; }\n' > gcc.c
printf 'extern int cxx(void); extern int abi(void); extern int unwind(void); int use(void) { return cxx()+abi()+unwind(); }\n' > consumer.c
for generation in 11 12; do
    node=29
    [[ $generation == 11 ]] || node=30
    printf 'GLIBCXX_3.4.29 { }; GLIBCXX_3.4.%s { global: cxx; }; CXXABI_1.3 { global: abi; };\n' "$node" > cxx.map
    [[ $generation != 11 ]] || printf 'GLIBCXX_3.4.29 { global: cxx; }; CXXABI_1.3 { global: abi; };\n' > cxx.map
    printf 'GCC_3.0 { global: unwind; };\n' > gcc.map
    gcc -nostdlib -shared -fPIC cxx.c -Wl,-soname,libstdc++.so.6 -Wl,--version-script=cxx.map -o "gcc$generation/libstdc++.so.6"
    gcc -nostdlib -shared -fPIC gcc.c -Wl,-soname,libgcc_s.so.1 -Wl,--version-script=gcc.map -o "gcc$generation/libgcc_s.so.1"
    gcc -nostdlib -shared -fPIC consumer.c -L"gcc$generation" -Wl,--no-as-needed -l:libstdc++.so.6 -l:libgcc_s.so.1 -o "consumer$generation.so"
done
cp gcc11/* archive/
cp consumer11.so archive/extension.so
cp consumer12.so installed/native.so
"$python" - <<'PY'
import zipfile
with zipfile.ZipFile('wheels/native-1-py3-none-linux_x86_64.whl', 'w') as wheel:
    wheel.write('installed/native.so', 'native.so')
    wheel.writestr('native-1.dist-info/METADATA', 'Name: native\nVersion: 1\n')
PY
inventory=$root/src/setups/env/bin/tools_wheel_inventory.sh
bash "$inventory" --python "$python" capture --lock uv.lock --wheel-dir wheels --installed-root installed --output inventory.json > /dev/null
bash "$inventory" --python "$python" materialize --lock uv.lock --wheel-dir wheels --inventory inventory.json --destination materialized > /dev/null
cd "$root"
reader=$root/src/setups/env/bin/closure_d10.sh
d10_read() { bash "$driver" d10 --out "$1" --python "$python" --reader "$reader" --root "$d10/archive" --candidate "11=$d10/gcc11" --candidate "12=$d10/gcc12" "${@:2}"; }
wheel_args=(--wheel-root "$d10/materialized" --wheel-lock "$d10/uv.lock" --wheel-python "$python")
expect 0 d10-archive-only d10_read "$d10/read-archive"
said d10-archive-only 'D10 CONVERGED at 11'
expect 3 d10-rebuild-required d10_read "$d10/read-rebuild" "${wheel_args[@]}"
said d10-rebuild-required 'D10 REBUILD REQUIRED: rebuild with 12'
"$python" -c 'import json,sys; r=json.load(open(sys.argv[1])); assert r["generation"]==11 and r["selected_generation"]==12 and r["providers"]["11"]["satisfies"] is False and r["providers"]["12"]["satisfies"] is True and len(r["consumers"])==1 and r["required_nodes"]' "$d10/read-rebuild/reading-1.json"
cp "$d10"/gcc12/* "$d10/archive/"
expect 0 d10-second-reading-settles d10_read "$d10/read-rebuild" "${wheel_args[@]}"
said d10-second-reading-settles 'D10 CONVERGED at 12'
"$python" -c 'import json,sys; r=json.load(open(sys.argv[1])); assert r["generation"]==12 and r["selected_generation"]==12 and r["settled"] is True' "$d10/read-rebuild/reading-2.json"
expect 2 d10-no-third-iteration d10_read "$d10/read-rebuild" "${wheel_args[@]}"
said d10-no-third-iteration 'no third iteration'
cp "$d10"/gcc11/* "$d10/archive/"
expect 1 d10-non-convergent d10_read "$d10/read-archive" "${wheel_args[@]}"
said d10-non-convergent 'NON-CONVERGENT'
expect 5 d10-inconclusive d10_read "$d10/read-inconclusive" --wheel-root "$d10/absent" --wheel-lock "$d10/uv.lock" --wheel-python "$python"
said d10-inconclusive 'D10 INCONCLUSIVE'

# --- the ELF pass excludes a venv tree ---------------------------------------
# A wheel object's search path is ORIGIN-relative and carries no builder
# anchor, so the relocation pass must leave it untouched (bytes, tag and
# value) and record nothing for it, while a library outside the venv under
# the same root is still rewritten to the target directories.
installer=$root/src/setups/env/bin/install_pkg.sh
venvfix=$scratch/venv-pass
site=prefix/pdfs/app/venvs/python_3.13.15_app/lib/python3.13/site-packages/pkg
mkdir -p "$venvfix/prefix/tools/bin" "$venvfix/prefix/tools/python/root/usr/lib64" \
    "$venvfix/prefix/tools/python/root/lib64" "$venvfix/prefix/pdfs/app/lib" "$venvfix/$site"
patchelf_bin=$(command -v patchelf || true)
[[ -n $patchelf_bin ]] || patchelf_bin=$HOME/tools/bin/patchelf
[[ -x $patchelf_bin ]] || { printf 'FAIL: patchelf is required for the venv-pass fixture\n' >&2; exit 1; }
cp "$patchelf_bin" "$venvfix/prefix/tools/bin/patchelf"
cp -L /lib64/ld-linux-x86-64.so.2 "$venvfix/prefix/tools/python/root/lib64/"
cd "$venvfix"
printf 'int bundled(void) { return 1; }\n' > bundled.c
printf 'extern int bundled(void); int ext(void) { return bundled(); }\n' > ext.c
printf 'int app(void) { return 1; }\n' > app.c
gcc -nostdlib -shared -fPIC bundled.c -Wl,-soname,libbundled.so -o "$site/libbundled.so"
gcc -nostdlib -shared -fPIC ext.c -L"$site" -l:libbundled.so -Wl,--enable-new-dtags -Wl,-rpath,"\$ORIGIN" -o "$site/_ext.so"
gcc -nostdlib -shared -fPIC app.c -Wl,--disable-new-dtags -Wl,-rpath,/home/builder/tools/python/root/usr/lib64 -o prefix/pdfs/app/lib/libapp.so
printf 'home = /home/builder/tools/python/current/bin\nversion = 3.13.15\n' > prefix/pdfs/app/venvs/python_3.13.15_app/pyvenv.cfg
cp "$site/_ext.so" ext.before
cp "$site/libbundled.so" bundled.before
cat > pass.sh <<'PASS'
#!/bin/bash
export HOME=$1 INSTALL_PREFIX=$1
# shellcheck disable=SC1090
source "$2"
fix_elf_paths "$1/pdfs"
PASS
expect 0 venv-pass-runs bash pass.sh "$venvfix/prefix" "$installer"
cmp ext.before "$site/_ext.so"
cmp bundled.before "$site/libbundled.so"
readelf -d "$site/_ext.so" | grep -q 'RUNPATH.*ORIGIN'
readelf -d prefix/pdfs/app/lib/libapp.so | grep -q "RPATH.*$venvfix/prefix/tools/python/root/usr/lib64"
said venv-pass-runs 'CPLX-ELF/1 end state=completed reason=none walked=1 r-rewritten=1 '
[[ $(grep -c '^CPLX-ELF/1 obj ' "$scratch/venv-pass-runs.log") == 1 ]]
said venv-pass-runs '^CPLX-ELF/1 obj case=4 rpath=rewritten interp=not-applicable '
cases=$((cases + 1))
printf 'PASS venv-pass-excludes-venv-tree\n'
cd "$root"
printf 'PASS tools-release-acceptance: %s cases\n' "$cases"
