#!/bin/bash
# Native target probe, with locally delivered inputs and a fresh owned venv/cache.
set -euo pipefail
step='' tools='' app='' manifest='' profile='' evidence='' python=''
while (($#)); do
    case "$1" in
        --step) step=${2:?}; shift 2 ;;
        --tools-prefix) tools=${2:?}; shift 2 ;;
        --application-root) app=${2:?}; shift 2 ;;
        --manifest) manifest=${2:?}; shift 2 ;;
        --profile) profile=${2:?}; shift 2 ;;
        --evidence-root) evidence=${2:?}; shift 2 ;;
        --python) python=${2:?}; shift 2 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done
[[ "$step" == 1 && $(uname -s) == Linux ]] || {
    echo 'Step 1 requires native Linux' >&2; exit 2;
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
exec "$python" -I "$root/src/setups/env/bin/deploy_venv_transport.py" probe \
    --manifest "$manifest" --root "${manifest%/*}" --tools-prefix "$tools" \
    --application-root "$app" --profile "$profile" --evidence-root "$evidence"
