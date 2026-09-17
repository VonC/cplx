#!/bin/bash
# Cumulative native Linux checks through main-chain qualification in Step 4.
# Explicit app checkout and independent Python 3.9+ are required.
set -euo pipefail
step="" python="" app=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --step) step="${2:?--step needs a number}"; shift 2 ;;
        --python) python="${2:?--python needs a path}"; shift 2 ;;
        --app-repo) app="${2:?--app-repo needs a path}"; shift 2 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done
[[ "$step" =~ ^[1234]$ && "$python" = /* && -x "$python" && "$app" = /* && -d "$app/tools" ]] || {
    printf 'Required: --step 1|2|3|4 --python /absolute/python --app-repo /absolute/checkout\n' >&2; exit 2;
}
root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd)
cd "$root"
"$python" -c 'import sys; print("Independent interpreter:", sys.executable, sys.version); assert sys.version_info >= (3, 9)'
bash src/utils/lint_shell.sh
scripts=(docs/v0.27.0/verify.tools-archive-rebuild.sh docs/v0.27.0/verify.tools-release-publish.sh
    "$app/tools/tools_release_adapter.sh" "$app/tools/publish_pdf_nexus.sh")
if [ "$step" -ge 3 ]; then
    scripts+=(src/setups/env/bin/closure_d10.sh src/setups/env/bin/tools_wheel_inventory.sh
        docs/v0.27.0/verify.tools-release-d10.sh)
fi
if [ "$step" -ge 4 ]; then
    scripts+=(docs/v0.27.0/verify.tools-release-agent.sh "$app/ci/tools_candidate.sh"
        "$app/ci/tools_abi_acceptance.sh" "$app/ci/tools_test_acceptance.sh"
        "$app/ci/tools_agent_identity.sh" "$app/ci/provision_toolchain.sh"
        "$app/tools/sqlite_candidate_capture.sh")
fi
for script in "${scripts[@]}"; do bash -n "$script"; done
shellcheck --external-sources --source-path="$app" "${scripts[@]}"
"$python" -m py_compile "$app/tools/tools_release_http.py" "$app/tools/tools_release_transport.py"
if [ "$step" -ge 2 ]; then
    "$python" -m py_compile src/setups/env/bin/tools_release_record.py
    "$python" -B -m unittest tests.unit.tools_release_record.test_tools_release_record.test_tools_release_record_tdd -v
fi
if [ "$step" -ge 3 ]; then
    "$python" -m py_compile src/setups/env/bin/tools_wheel_inventory.py
    bash docs/v0.27.0/verify.tools-release-d10.sh --python "$python"
fi
if [ "$step" -ge 4 ]; then
    "$python" -m py_compile "$app"/ci/tools_*.py docs/v0.27.0/fixtures.tools-release-agent.py
    bash docs/v0.27.0/verify.tools-release-agent.sh --python "$python" --app-repo "$app"
fi
bash docs/v0.27.0/verify.tools-release-publish.sh --python "$python" --app-repo "$app"
# The current declaration deliberately retired the old SQLite waiver. Preserve
# that floor, then exercise the frozen publication suite with its original pair
# and CURRENT scripts. These are historical controls, not candidate acceptance.
bash docs/v0.27.0/verify.python-sqlite-closure.sh --fixtures-only
fixtures="$root/docs/v0.27.0/fixtures.tools-release-publish"
(cd "$fixtures" && sha256sum -c <<'DIGESTS'
d1a487b529c3ea1f2a6abac0fda90061f6a5d61a7e4a0d2b52be9f109aeeade1  closure-config.txt
0c203280c48e5eee64fa74f6b1c6781e8be9a82cc202d1b40c728cf4e1aa87b9  closure-envelope.txt
DIGESTS
)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/tools-publish-historical.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
cp -a src/setups/env/. "$scratch/"
cp "$fixtures/closure-config.txt" "$fixtures/closure-envelope.txt" "$scratch/closure/"
printf 'Historical closure input pair, current implementation scripts\n'
bash docs/v0.27.0/verify.closure-check.sh --step 5 --shipped-dir "$scratch/bin"
