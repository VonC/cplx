#!/bin/bash
# Cumulative SQLite checks; authoring Python never stands in for candidate Python.
set -euo pipefail

step=1
author_python=
while (($#)); do
    case $1 in
        --step|--python)
            (($# >= 2)) || { echo "missing value for $1" >&2; exit 2; }
            if [[ $1 == --step ]]; then step=$2; else author_python=$2; fi
            shift 2
            ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done
[[ $step =~ ^[1-4]$ && -n $author_python ]] || {
    echo "usage: verify.python-sqlite.sh --step 1..4 --python /absolute/python" >&2
    exit 2
}
case $author_python in
    /*|[A-Za-z]:[\\/]*) ;;
    *) echo "authoring Python must be an explicit absolute path" >&2; exit 2 ;;
esac

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$repo"
printf 'SQLite verification: step=%s shell=%s\n' "$step" "$BASH_VERSION"
bash src/utils/lint_shell.sh

harnesses=(docs/v0.27.0/verify.python-sqlite.sh)
if ((step >= 2)); then harnesses+=(docs/v0.27.0/verify.python-sqlite-build.sh); fi
if ((step >= 3)); then harnesses+=(docs/v0.27.0/verify.python-sqlite-closure.sh); fi
if ((step >= 4)); then harnesses+=(docs/v0.27.0/acceptance.python-sqlite-support.sh); fi
for harness in "${harnesses[@]}"; do
    [[ -f $harness ]] || { echo "step material missing: $harness" >&2; exit 2; }
    bash -n "$harness"
    shellcheck "$harness"
done

"$author_python" -B - <<'PY'
import importlib.util
from pathlib import Path
import sqlite3
import sys
import time
import unittest

print(f"Authoring interpreter: {sys.executable}; {sys.version}", flush=True)
assert sys.version_info >= (3, 9), "Python 3.9 or later is required"
files = [Path("src/install/env/python/sqlite_probe.py")]
files.extend(Path("tests/unit/sqlite_probe").rglob("*.py"))
for path in files:
    compile(path.read_bytes(), str(path), "exec")
start = time.perf_counter()
suite = unittest.defaultTestLoader.loadTestsFromName(
    "tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd")
result = unittest.TextTestRunner(verbosity=2).run(suite)
print(f"Unit elapsed seconds: {time.perf_counter() - start:.3f}", flush=True)
if result.skipped:
    print("Linux symlink cases remain required; authoring skips are not acceptance.")
sys.exit(0 if result.wasSuccessful() else 1)
PY

if ((step >= 2)); then bash docs/v0.27.0/verify.python-sqlite-build.sh --python "$author_python"; fi
if ((step >= 3)); then bash docs/v0.27.0/verify.python-sqlite-closure.sh; fi
if ((step >= 4)); then bash docs/v0.27.0/acceptance.python-sqlite-support.sh --check-prerequisites; fi
echo "SQLite cumulative checks passed through step $step"
