#!/bin/bash
# Native target probe, with locally delivered inputs and a fresh owned venv/cache.
set -euo pipefail
step='' tools='' app='' manifest='' profile='' evidence='' python=''
installed='' wheels='' venv='' selection_profile=''
while (($#)); do
    case "$1" in
        --step) step=${2:?}; shift 2 ;;
        --tools-prefix) tools=${2:?}; shift 2 ;;
        --application-root) app=${2:?}; shift 2 ;;
        --manifest) manifest=${2:?}; shift 2 ;;
        --profile) profile=${2:?}; shift 2 ;;
        --selection-profile) selection_profile=${2:?}; shift 2 ;;
        --evidence-root) evidence=${2:?}; shift 2 ;;
        --python) python=${2:?}; shift 2 ;;
        --installed-root) installed=${2:?}; shift 2 ;;
        --wheel-dir) wheels=${2:?}; shift 2 ;;
        --venv-root) venv=${2:?}; shift 2 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done
[[ ( "$step" == 1 || "$step" == 2 ) && $(uname -s) == Linux ]] || {
    echo 'Step 1 or 2 requires native Linux' >&2; exit 2;
}
for value in "$tools" "$app" "$manifest" "$profile" "$evidence"; do
    [[ "$value" == /* ]] || { echo 'Explicit absolute input paths required' >&2; exit 2; }
done
[[ -d "$tools" && -d "$app" && -f "$manifest" && -f "$profile" ]] || exit 2
# The caller chooses the actual shipped interpreter, never newest-directory discovery.
[[ "$python" == "$tools/"* && -x "$python" ]] || {
    echo 'Supply --python with the selected toolchain executable under --tools-prefix' >&2; exit 2;
}
root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd)
if [[ "$step" == 2 ]]; then
    [[ "$selection_profile" == /* && -f "$selection_profile" ]] || {
        echo 'Step 2 requires an absolute --selection-profile' >&2; exit 2;
    }
    for value in "$installed" "$wheels" "$venv"; do
        [[ "$value" == /* ]] || { echo 'Step 2 requires absolute installed, wheel and venv roots' >&2; exit 2; }
    done
    [[ -d "$installed" && -d "$wheels" && -d "$venv" ]] || exit 2
    mkdir -p -- "$evidence"
    "$python" -I "$root/src/setups/env/bin/deploy_venv_inputs.py" verify \
        --manifest "$manifest" --root "${manifest%/*}" \
        > "$evidence/release-inputs.txt"
    "$python" -I "$root/src/setups/env/bin/tools_wheel_inventory.py" capture \
        --lock "${manifest%/*}/metadata/uv.lock" --wheel-dir "$wheels" \
        --installed-root "$installed" --venv-root "$venv" --profile "$selection_profile" \
        --output "$evidence/wheel-inventory.json"
    "$python" -I "$root/src/setups/env/bin/deploy_venv_selection.py" \
        --lock "${manifest%/*}/metadata/uv.lock" \
        --project "${manifest%/*}/metadata/pyproject.toml" --profile "$selection_profile" \
        --wheel-dir "$wheels" --installed-root "$installed" \
        --inventory "$evidence/wheel-inventory.json" --manifest "$manifest" \
        --target-profile "$profile" \
        > "$evidence/selection.json"
    exit 0
fi
exec "$python" -I "$root/src/setups/env/bin/deploy_venv_transport.py" probe \
    --manifest "$manifest" --root "${manifest%/*}" --tools-prefix "$tools" \
    --application-root "$app" --profile "$profile" --evidence-root "$evidence"
