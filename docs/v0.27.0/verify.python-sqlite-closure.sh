#!/bin/bash
# Check candidate scope, the static SQLite floor and exact declaration identity.
# Empty provider files exercise the static name/location rule only. They are not
# ELF or dynamic SQLite acceptance evidence; Step 4 supplies that evidence.
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
config_path=src/setups/env/closure/closure-config.txt
declaration="$repo/$config_path"
fixtures_only=0
while (($#)); do
    case $1 in
        --fixtures-only) fixtures_only=1; shift ;;
        --declaration)
            (($# >= 2)) || { echo 'missing declaration path' >&2; exit 2; }
            declaration=$2; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done
if [[ $declaration != "$repo/$config_path" && $fixtures_only != 1 ]]; then
    echo '--declaration requires --fixtures-only; the repository pair is not checked' >&2
    exit 2
fi
shipped="$repo/src/setups/env/bin"
# shellcheck source=/dev/null
source "$shipped/closure_check.sh"
# shellcheck source=/dev/null
source "$shipped/closure_publish.sh"
scratch=$(mktemp -d "${TMPDIR:-/tmp}/cplx-sqlite-closure.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
cases=0
started=$SECONDS
check() {
    local name=$1
    shift
    if ! "$@"; then echo "FAIL: $name" >&2; exit 1; fi
    cases=$((cases + 1))
    printf 'PASS: %s\n' "$name"
}
contains() { [[ $1 == *"$2"* ]]; }
refuses() {
    local reason=$1 out rc=0
    shift
    out=$("$@" 2>&1) || rc=$?
    [[ $rc != 0 && $out == *"$reason"* ]] || {
        printf 'expected refusal containing %s; got status %s: %s\n' "$reason" "$rc" "$out" >&2
        return 1
    }
}
check 'candidate declaration parses' closure_config_parse "$declaration"
mapfile -t specs < <(closure_config_root_specs)
check 'Python candidate and root order' test "${specs[*]}" \
    = 'python=root,current,python-3.13.15 git=root'
check 'SQLite floor remains in Python' test "${CLOSURE_CFG_FLOOR[libsqlite3.so.0]}" = tools/python
check 'candidate carries no active waiver' test "${#CLOSURE_CFG_WAIVER[@]}" = 0

prefix="$scratch/prefix"
python_lib="$prefix/tools/python/root/usr/lib64"
git_lib="$prefix/tools/git/root/usr/lib64"
mkdir -p "$python_lib" "$git_lib" "$prefix/tools/python/current/lib" \
    "$prefix/tools/python/python-3.13.15/lib"
declared=$(closure_scope_declared "$prefix" "${specs[@]}")
check 'installer observes candidate fixture' closure_scope_observed "$prefix" "$shipped/install_pkg.sh"
observed=$(closure_scope_observed_lines "$CLOSURE_OBSERVED_RPATH")
scope=$(closure_scope_classify "$prefix" "$declared" "$observed" "${specs[@]}")
check 'root is present' contains "$scope" "PRESENT|declared|$python_lib"
check 'current is present' contains "$scope" "PRESENT|declared|$prefix/tools/python/current/lib"
check '3.13.15 is present' contains "$scope" "PRESENT|declared|$prefix/tools/python/python-3.13.15/lib"
check 'candidate scope has no unexpected directory' test "${scope#*UNEXPECTED|}" = "$scope"
mkdir -p "$prefix/tools/python/python-3.13.9/lib"
check 'installer observes retained old version' closure_scope_observed "$prefix" "$shipped/install_pkg.sh"
observed=$(closure_scope_observed_lines "$CLOSURE_OBSERVED_RPATH")
scope=$(closure_scope_classify "$prefix" "$declared" "$observed" "${specs[@]}")
check 'retained 3.13.9 is unexpected' contains "$scope" \
    "UNEXPECTED|observed|$prefix/tools/python/python-3.13.9/lib|subdirectory|python-3.13.9"

# Plant all other floor names so each negative case has exactly one defect.
for member in "${!CLOSURE_CFG_FLOOR[@]}"; do : > "$python_lib/$member"; done
index_providers() {
    CLOSURE_PROVIDER_PATHS=()
    # shellcheck disable=SC2034  # reset the state read by closure_provider_index
    CLOSURE_PROVIDER_DIRS=()
    # shellcheck disable=SC2034  # reset the state read by closure_provider_index
    CLOSURE_PROVIDER_NAMES=0
    closure_provider_index "$observed"
}
index_providers
floor=$(closure_floor_check "$prefix")
check 'complete static floor is accepted' test "$floor" = ''
rm -- "$python_lib/libsqlite3.so.0"
index_providers
floor=$(closure_floor_check "$prefix")
check 'missing SQLite is refused' contains "$floor" 'REFUSED|floor|libsqlite3.so.0|tools/python|'
: > "$git_lib/libsqlite3.so.0"
index_providers
check 'Git-only SQLite fixture is indexed' test "${CLOSURE_PROVIDER_PATHS[libsqlite3.so.0]}" = "$git_lib/libsqlite3.so.0"
floor=$(closure_floor_check "$prefix")
check 'Git-only SQLite is refused' contains "$floor" 'REFUSED|floor|libsqlite3.so.0|tools/python|'
: > "$python_lib/libsqlite3.so.0"
index_providers
cp "$declaration" "$scratch/stale.txt"
printf 'waiver|libsqlite3.so.0|python-sqlite-support\n' >> "$scratch/stale.txt"
check 'stale waiver fixture parses' closure_config_parse "$scratch/stale.txt"
floor=$(closure_floor_check "$prefix")
check 'present SQLite makes its waiver stale' contains "$floor" \
    'REFUSED|waiver|libsqlite3.so.0|python-sqlite-support|stale:'

# Synthetic commits belong only to this disposable fixture repository. The real
# source snapshot and its approval are separate from these identity controls.
fixture_repo="$scratch/source"
mkdir -p "$fixture_repo/$(dirname -- "$config_path")"
git init -q --template= "$fixture_repo"
fixture_git() {
    git -C "$fixture_repo" -c user.name='SQLite fixture' \
        -c user.email=sqlite-fixture@example.invalid -c commit.gpgsign=false "$@"
}
cp "$declaration" "$fixture_repo/$config_path"
fixture_git add -- "$config_path"
fixture_git commit -qm 'test: record exact declaration bytes'
source_sha=$(fixture_git rev-parse HEAD)
fixture_git cat-file blob "$source_sha:$config_path" > "$scratch/source.txt"
check 'source blob preserves declaration bytes' cmp -s "$declaration" "$scratch/source.txt"
digest=$(closure_config_digest "$scratch/source.txt")
write_envelope() {
    printf 'CPLX-CLOSURE-ENVELOPE/1\ndigest|%s\nsource|%s|%s\n' "$digest" "$config_path" "$1" > "$2"
}
write_envelope "$source_sha" "$scratch/envelope.txt"
check 'exact fixture pair is internally consistent' closure_envelope_check "$declaration" "$scratch/envelope.txt"
check 'exact fixture source is authoritative' closure_config_authority_check \
    "$fixture_repo" "$declaration" "$scratch/envelope.txt"
cp "$declaration" "$scratch/altered.txt"
printf '# changed bytes\n' >> "$scratch/altered.txt"
check 'altered declaration with unchanged envelope refuses' refuses 'REFUSED|0|digest|' \
    closure_envelope_check "$scratch/altered.txt" "$scratch/envelope.txt"
awk '{printf "%s\r\n", $0}' "$declaration" > "$scratch/crlf.txt"
check 'CRLF changes the exact digest' test "$(closure_config_digest "$scratch/crlf.txt")" != "$digest"
check 'CRLF with unchanged envelope refuses' refuses 'INCONSISTENT|' \
    closure_envelope_check "$scratch/crlf.txt" "$scratch/envelope.txt"
cp "$scratch/altered.txt" "$fixture_repo/$config_path"
fixture_git add -- "$config_path"
fixture_git commit -qm 'test: change source blob'
write_envelope "$(fixture_git rev-parse HEAD)" "$scratch/changed-source.txt"
check 'changed-source pair remains internally consistent' closure_envelope_check \
    "$declaration" "$scratch/changed-source.txt"
check 'changed source blob is refused by authority' refuses 'REFUSED|0|authority|' \
    closure_config_authority_check "$fixture_repo" "$declaration" "$scratch/changed-source.txt"

if ((fixtures_only)); then
    echo 'FIXTURES ONLY: repository envelope and real source ancestry remain unchecked.'
else
    check 'repository pair is internally consistent' closure_envelope_check \
        "$declaration" "$repo/src/setups/env/closure/closure-envelope.txt"
    check 'repository source bytes are authoritative' closure_config_authority_check \
        "$repo" "$declaration" "$repo/src/setups/env/closure/closure-envelope.txt"
fi
printf 'SQLite closure: %s checks passed in %s seconds\n' "$cases" "$((SECONDS - started))"
