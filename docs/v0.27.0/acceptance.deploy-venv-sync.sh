#!/bin/bash
# Native target probe, or explicit isolated operator-backend acceptance for step 6.
set -euo pipefail
step='' tools='' app='' manifest='' profile='' evidence='' python=''
installed='' wheels='' venv='' selection_profile=''
helper='' runtime='' attestation='' project=''
record='' companion='' application_archive='' tools_archive='' entry=''
ci_evidence='' coverage=''
operator='' candidate='' qualification='' release_config=''
archive_required=()
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
        --helper) helper=${2:?}; shift 2 ;;
        --runtime-setup) runtime=${2:?}; shift 2 ;;
        --serialization-attestation) attestation=${2:?}; shift 2 ;;
        --project) project=${2:?}; shift 2 ;;
        --release-record) record=${2:?}; shift 2 ;;
        --companion) companion=${2:?}; shift 2 ;;
        --application-archive) application_archive=${2:?}; shift 2 ;;
        --tools-archive) tools_archive=${2:?}; shift 2 ;;
        --entry) entry=${2:?}; shift 2 ;;
        --ci-evidence) ci_evidence=${2:?}; shift 2 ;;
        --coverage) coverage=${2:?}; shift 2 ;;
        --operator) operator=${2:?}; shift 2 ;;
        --candidate-manifest) candidate=${2:?}; shift 2 ;;
        --qualification-record) qualification=${2:?}; shift 2 ;;
        --release-config) release_config=${2:?}; shift 2 ;;
        --required-archive-member) archive_required+=("${2:?}"); shift 2 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done
if [[ "$step" == 6 ]]; then
    for value in "$operator" "$candidate" "$qualification" "$release_config"; do
        [[ "$value" == /* && -f "$value" && ! -L "$value" ]] || {
            echo 'Step 6 requires explicit operator, candidate, qualification and private configuration files' >&2; exit 2;
        }
    done
    [[ "$evidence" == /* && "$python" == /* && -x "$python" ]] || {
        echo 'Step 6 requires explicit evidence root and operator Python' >&2; exit 2;
    }
    # The consumer checks its isolated test scope and runs real backend failures/retries.
    exec bash "$operator" --candidate-manifest "$candidate" \
        --qualification-record "$qualification" --release-config "$release_config" \
        --evidence-root "$evidence" --python "$python" --backend-self-test
fi
[[ ( "$step" == 1 || "$step" == 2 || "$step" == 3 || "$step" == 4 || "$step" == 5 ) && $(uname -s) == Linux ]] || {
    echo 'Step 1, 2, 3, 4 or 5 requires native Linux' >&2; exit 2;
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
if [[ "$step" == 3 || "$step" == 4 || "$step" == 5 ]]; then
    for value in "$selection_profile" "$helper" "$runtime" "$attestation"; do
        [[ "$value" == /* && -f "$value" ]] || {
            echo 'Step 3 requires absolute delivered selection, helper, runtime and attestation files' >&2; exit 2;
        }
    done
    [[ -n "$project" ]] || { echo 'Step 3 requires --project' >&2; exit 2; }
    if [[ "$step" == 4 || "$step" == 5 ]]; then
        ((${#archive_required[@]})) || {
            echo 'Step 4 requires at least one --required-archive-member' >&2; exit 2;
        }
        for value in "$record" "$companion" "$application_archive" "$tools_archive" "$entry"; do
            [[ "$value" == /* && -f "$value" && ! -L "$value" ]] || {
                echo 'Step 4 requires five absolute regular release inputs' >&2; exit 2;
            }
        done
        "$python" -I "$root/src/setups/env/bin/deploy_venv_release.py" qualify \
            --record "$record" --application "$application_archive" \
            --tools "$tools_archive" --entry "$entry" --companion "$companion"
        if [[ "$step" == 5 ]]; then
            [[ "$ci_evidence" == /* && -f "$ci_evidence" && "$coverage" == /* && -f "$coverage" ]] || {
                echo 'Step 5 requires absolute combined-CI evidence and phase 1 coverage inputs' >&2; exit 2;
            }
            "$python" -I "$root/src/setups/env/bin/deploy_venv_release.py" ci-check \
                --record "$record" --application "$application_archive" \
                --tools "$tools_archive" --entry "$entry" --companion "$companion" \
                --evidence "$ci_evidence" --coverage "$coverage"
        fi
        "$python" -I "$root/src/setups/env/bin/deploy_venv_archive.py" inspect \
            --archive "$application_archive" \
            "${archive_required[@]/#/--required=}"
    fi
    exec bash "$root/src/setups/env/bin/deploy_venv.sh" \
        --application-root "$app" --project "$project" --tools-prefix "$tools" \
        --manifest "$manifest" --profile "$profile" \
        --selection-profile "$selection_profile" --helper "$helper" \
        --runtime-setup "$runtime" --serialization-attestation "$attestation" \
        --evidence-root "$evidence"
fi
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
