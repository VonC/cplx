#!/bin/bash
# Capture Debian's installed ELF identities or materialize its exact retained
# wheels on RHEL. The independent Python handles ZIP safety; no resolver runs.
set -euo pipefail
if [ "${1:-}" != --python ] || [ "$#" -lt 3 ] || [[ "$2" != /* ]] || [ ! -x "$2" ]; then
    printf 'Usage: tools_wheel_inventory.sh --python /absolute/python capture|materialize|describe ...\n' >&2
    exit 2
fi
python="$2"
shift 2
exec "$python" "${BASH_SOURCE[0]%/*}/tools_wheel_inventory.py" "$@"
