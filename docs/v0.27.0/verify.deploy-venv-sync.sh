#!/bin/bash
# Cumulative fixture checks; target runtime qualification has its own entry.
set -euo pipefail
step='' python='' app=''
while (($#)); do
    case "$1" in
        --step) step=${2:?}; shift 2 ;;
        --python) python=${2:?}; shift 2 ;;
        --app-repo) app=${2:?}; shift 2 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done
[[ ( "$step" == 1 || "$step" == 2 ) && "$python" == /* && -x "$python" && "$app" == /* && -d "$app/tools" ]] || {
    echo 'Required: --step 1|2 --python /absolute/python (3.11+) --app-repo /absolute/consumer' >&2; exit 2;
}
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.."
status=0
"$python" -c 'raise SystemExit(23)' || status=$?
[[ "$status" == 23 ]] || { echo 'Interpreter masks failing exit codes; select the real Python executable' >&2; exit 2; }
export TOOLS_TEST_APP="$app"
"$python" -c 'import sys; assert sys.version_info >= (3, 11); print(sys.version)'
# Run fixtures first so the test-first missing implementation has an explicit verdict.
"$python" -B -m unittest discover -s tests/unit/deploy_venv_sync -t . -p 'test_*_*.py' -v
bash src/utils/lint_shell.sh
scripts=(docs/v0.27.0/verify.deploy-venv-sync.sh docs/v0.27.0/acceptance.deploy-venv-sync.sh)
for script in "${scripts[@]}"; do bash -n "$script"; done
shellcheck "${scripts[@]}"
if [[ "$step" == 2 ]]; then
    bash docs/v0.27.0/verify.tools-release-d10.sh --python "$python"
fi
"$python" -B -m unittest discover -s tests/unit -t . -p 'test_*_*.py' -v
"$python" - src/setups/env/bin tests/unit/deploy_venv_sync <<'PY'
import ast
from pathlib import Path
import sys
for root in map(Path, sys.argv[1:]):
    for path in root.rglob('*.py'):
        text = path.read_text(encoding='utf-8')
        if path.name.startswith('deploy_venv_') or 'deploy_venv_sync' in path.parts:
            assert len(text.splitlines()) <= 650, str(path)
            ast.parse(text, filename=str(path))
print('PASS syntax and 650 physical-line ceiling')
PY
