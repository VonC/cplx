#!/bin/bash
# Process fixtures for the adapter, eligibility entry and inherited publication gate.
set -euo pipefail
python="" app=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --python) python="${2:?--python needs a path}"; shift 2 ;;
        --app-repo) app="${2:?--app-repo needs a path}"; shift 2 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done
[[ "$python" = /* && -x "$python" && "$app" = /* && -d "$app/tools" ]] || {
    printf 'Explicit absolute --python and --app-repo paths are required\n' >&2; exit 2;
}
[[ $(uname -s) = Linux ]] || { printf 'Native Linux is required\n' >&2; exit 5; }
root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd)
export TOOLS_TEST_APP="$app"
cd "$root"
"$python" -B -m unittest tests.unit.tools_release_transport.test_tools_release_transport.test_tools_release_transport_tdd -v
"$python" -B -m unittest tests.unit.tools_release_record.test_tools_release_record.test_release_publication_tdd -v
