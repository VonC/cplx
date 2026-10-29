#!/bin/bash
# Validate the three retained role records and extract measured phase timings.
set -euo pipefail
[[ $# == 2 && -x $1 && -d $2 ]] || { echo 'usage: report ABSOLUTE_PYTHON ROLE_EVIDENCE_ROOT' >&2; exit 2; }
parser=$1 evidence=$(readlink -e "$2")
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=docs/v0.27.0/acceptance.python-sqlite-capture.sh
source "$here/acceptance.python-sqlite-capture.sh"
digest=$(cat "$evidence/build/archive.sha256")
[[ $digest =~ ^[0-9a-f]{64}$ ]]
sqlite_roles "$parser" "$evidence" "$digest"
"$parser" -I -S -B - "$evidence" "$digest" <<'PY'
import json
from pathlib import Path
import sys

root, digest = Path(sys.argv[1]), sys.argv[2]
timeline = []
for line in (root / 'build/build.timeline').read_text().splitlines():
    stamp, text = line.split('\t', 1)
    timeline.append((float(stamp), text))
timings = {}
for name, begin, end in (
    ('configure', 'Running configure command:', 'configure done'),
    ('compile', 'Must make all in', 'make all is now done'),
    ('install', "Must install 'python' in", 'install: make install is now done'),
):
    starts = [stamp for stamp, text in timeline if begin in text]
    ends = [stamp for stamp, text in timeline if end in text]
    assert len(starts) == len(ends) == 1, f'missing or duplicate {name} milestone'
    assert ends[0] >= starts[0], f'reversed {name} milestones'
    timings[name] = round(ends[0] - starts[0], 6)
for role in ('build', 'rhel', 'debian'):
    for command in (root / role).glob('*.command'):
        records = dict(line.split('=', 1) for line in command.read_text().splitlines()
                       if line.startswith(('exit=', 'elapsed_seconds=')))
        assert records.get('exit') == '0', f'failed command: {command}'
        timings[f'{role}.{command.stem}'] = int(records['elapsed_seconds'])
print(json.dumps(dict(sha256=digest, roles=['build', 'rhel', 'debian'],
                     elapsed_seconds=timings), sort_keys=True, indent=2))
PY
