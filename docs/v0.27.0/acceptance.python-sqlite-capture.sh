#!/bin/bash
# Capture primitives shared by the candidate driver and recording-only fixtures.
# No commands run when sourced. Live manifests include file contents, not just metadata.
declare -a sqlite_scalars=()

sqlite_fail() { printf 'SQLite acceptance: %s\n' "$*" >&2; return 2; }
sqlite_digest() { local value; value=$(sha256sum < "$1") || return; printf '%s\n' "${value%% *}"; }
sqlite_inside() {
    local root path
    root=$(readlink -e -- "$1") && path=$(readlink -m -- "$2") || return
    [[ $root != / && $path == "$root/"* ]] || sqlite_fail "path outside owned root: $2"
}
sqlite_anchor() {
    [[ $1 == /* && $1 != / && -d $1 && -O $1 && -w $1 && -x $1 && ! -L $1 &&
       $(readlink -e -- "$1") == "$1" ]] || { sqlite_fail "unverified home: $1"; return; }
    [[ $2 != build || $1 =~ ^/home/[^/]+$ ]] || sqlite_fail 'build home must be directly under /home'
}
sqlite_profile() {
    [[ ! -e $1/.profile && ! -L $1/.profile ]] || sqlite_fail "profile present in $1"
}
# SC2094: early refusal unlinks the invocation's temporary inventory.
# shellcheck disable=SC2094
sqlite_boundary() {
    local root listing path identity links kind status=0
    local -A counts=() totals=()
    root=$(readlink -e -- "$1") || return
    [[ $root != / ]] || return 2
    listing=$(mktemp -d) || return
    # Ordinary files/directories need no per-entry work. Resolve links in
    # batches, so large copied toolchains do not spawn a process per link.
    if ! find "$root" ! -type d ! \( -type f -links 1 \) \
        -printf '%y\0%p\0%D:%i\0%n\0' > "$listing/entries"; then rm -rf -- "$listing"; return 2; fi
    : > "$listing/links"
    while IFS= read -r -d '' kind && IFS= read -r -d '' path &&
          IFS= read -r -d '' identity && IFS= read -r -d '' links; do
        if [[ $kind == l ]]; then
            printf '%s\0' "$path" >> "$listing/links"
        elif [[ $kind == f && $links != 1 ]]; then
            counts[$identity]=$(( ${counts[$identity]:-0} + 1 ))
            totals[$identity]=$links
        elif [[ $kind != f && $kind != d ]]; then
            rm -rf -- "$listing"; sqlite_fail "special file in owned layout: $path"; return
        fi
    done < "$listing/entries"
    xargs -0 -r readlink -m -z -- < "$listing/links" > "$listing/resolved" || status=$?
    if ((status)); then rm -rf -- "$listing"; return "$status"; fi
    while IFS= read -r -d '' path; do
        if [[ $path != "$root/"* ]]; then
            rm -rf -- "$listing"; sqlite_fail "link outside owned root: $path"; return
        fi
    done < "$listing/resolved"
    rm -rf -- "$listing"
    for identity in "${!counts[@]}"; do
        [[ ${counts[$identity]} == "${totals[$identity]}" ]] || {
            sqlite_fail "hardlink outside owned layout: $identity"; return;
        }
    done
}
# shellcheck disable=SC2094
sqlite_manifest() {
    local inventory path metadata content kind record status=0
    local -A digests=()
    inventory=$(mktemp -d) || return
    # One traversal and batched hashing avoid several processes per live file.
    # NUL records preserve names containing whitespace or newlines.
    if ! find "$@" -printf '%p\0%y|%s|%T@|%m|%l\0' > "$inventory/entries"; then
        rm -rf -- "$inventory"; return 2
    fi
    while IFS= read -r -d '' path && IFS= read -r -d '' metadata; do
        [[ $metadata != f\|* ]] || printf '%s\0' "$path"
    done < "$inventory/entries" > "$inventory/files"
    xargs -0 -r sha256sum --binary --zero -- < "$inventory/files" > "$inventory/hashes" || status=$?
    if ((status)); then rm -rf -- "$inventory"; return "$status"; fi
    while IFS= read -r -d '' record; do
        digests[${record:66}]=${record:0:64}
    done < "$inventory/hashes"
    while IFS= read -r -d '' path && IFS= read -r -d '' metadata; do
        kind=${metadata%%|*}; content=-
        if [[ $kind == f ]]; then
            content=${digests[$path]:-}
            if [[ ! $content =~ ^[0-9a-f]{64}$ ]]; then status=2; break; fi
        fi
        printf '%s\0%s|%s\0' "$path" "$metadata" "$content"
    done < "$inventory/entries"
    rm -rf -- "$inventory"
    return "$status"
}
sqlite_manifest_equal() {
    local path value count=0
    local -A records=()
    while IFS= read -r -d '' path; do
        IFS= read -r -d '' value || return 2
        [[ ! ${records[$path]+present} ]] || return 2
        records[$path]=$value
    done < "$1"
    ((${#records[@]})) || return 2
    while IFS= read -r -d '' path; do
        IFS= read -r -d '' value || return 2
        [[ ${records[$path]-missing} == "$value" ]] || { sqlite_fail "preservation mismatch: $path"; return; }
        unset 'records[$path]'
        count=$((count + 1))
    done < "$2"
    ((count > 0 && ${#records[@]} == 0)) || sqlite_fail 'preservation inventory differs'
}
sqlite_preservation() {
    local evidence=$1
    local -a roots=()
    [[ -f $evidence/live.before && -f $evidence/live.roots ]] || return 2
    mapfile -t roots < "$evidence/live.roots"
    ((${#roots[@]})) || return 2
    sqlite_manifest "${roots[@]}" > "$evidence/live.after" || return
    sqlite_manifest_equal "$evidence/live.before" "$evidence/live.after" || return
    printf 'passed\n' > "$evidence/preservation"
}
sqlite_capture() {
    local home=$1 evidence=$2 label=$3 status=0 started ended
    shift 3
    started=$(date +%s)
    : > "$evidence/$label.timeline"
    { printf 'HOME=%q BASH_ENV=unset ' "$home"; printf '%q ' "$@"; printf '\n'; } > "$evidence/$label.command"
    # env -i also excludes inherited loader/Python overrides and exported functions.
    (set -o pipefail
        sqlite_exec() {
            env -i HOME="$home" PATH=/usr/local/bin:/usr/bin:/bin LANG=C LC_ALL=C "${sqlite_scalars[@]}" "$@"
        }
        # The normal wrapper writes diagnostics to stderr. Keep probe stdout
        # as one JSON document, without suppressing or parsing away diagnostics.
        if [[ $label == operator ]]; then sqlite_exec "$@" 2> "$evidence/$label.stderr"
        else sqlite_exec "$@" 2>&1
        fi | while IFS= read -r line || [[ -n $line ]]; do
                printf '%s\n' "$line"
                printf '%s\t%s\n' "${EPOCHREALTIME:-$SECONDS}" "$line" >> "$evidence/$label.timeline"
            done
    ) > "$evidence/$label.log" || status=$?
    ended=$(date +%s)
    printf 'exit=%s\nelapsed_seconds=%s\n' "$status" "$((ended - started))" >> "$evidence/$label.command"
    if ((status)); then
        printf '%s exit=%s\n' "$label" "$status" > "$evidence/failed"
        sqlite_preservation "$evidence" || return 2
    fi
    return "$status"
}
sqlite_archive() {
    local home=$1 archive=$2 expected=$3 file
    local -a files=()
    sqlite_inside "$home" "$archive" || return
    [[ -f $archive && ! -L $archive && $expected =~ ^[0-9a-f]{64}$ ]] || return 2
    for file in "$home"/tools.*.tar.gz "$home"/pkgs/tools.*.tar.gz; do
        [[ -e $file || -L $file ]] || continue
        # pkg.sh also creates this exact alias. It is one candidate only when
        # the alias resolves to the independently named regular archive.
        if [[ $file == "$home/pkgs/tools.latest.tar.gz" && -L $file &&
              $(readlink -e "$file") == "$(readlink -e "$archive")" ]]; then continue; fi
        [[ -f $file && ! -L $file ]] || { sqlite_fail "nonregular candidate: $file"; return; }
        files+=("$file")
    done
    [[ ${#files[@]} == 1 && $(readlink -e "${files[0]}") == "$(readlink -e "$archive")" &&
       $(sqlite_digest "$archive") == "$expected" ]] || sqlite_fail 'ambiguous candidate or SHA-256 mismatch'
}
sqlite_result() {
    local parser=$1
    shift
    "$parser" -I -S -B - "$@" <<'PY'
import json
from pathlib import Path
import sys

try:
    filename, stage, root, extension, provider = sys.argv[1:]
    result = json.loads(Path(filename).read_text())
    assert result['stage'] == stage
    assert result['outcome'] == 'passed' and result['database'] == 'passed'
    assert result['python_version'].split()[0] == '3.13.15'
    def inside(value, expected):
        path = Path(value).resolve(strict=True)
        base = Path(expected).resolve(strict=True)
        return path != base and base in path.parents
    assert inside(result['executable'], root)
    imported = Path(result['extension']['import_path'])
    assert imported.parent.resolve(strict=True) == Path(extension).resolve(strict=True)
    backing = Path(result['extension']['path']).resolve(strict=True)
    assert imported.resolve(strict=True) == backing
    if stage == 'build':
        source = Path(extension).resolve(strict=True).parent.parent
        assert backing.parent == source / 'Modules'
    else:
        assert inside(backing, extension)
    actual = result['provider']
    assert Path(actual['path']).resolve(strict=True) == Path(provider).resolve(strict=True)
    identity = actual['identity']
    assert len(identity) == 3 and all(type(value) is int and value >= 0 for value in identity)
except (AssertionError, KeyError, OSError, ValueError, TypeError) as error:
    print(f'invalid candidate probe: {type(error).__name__}: {error}', file=sys.stderr)
    sys.exit(2)
PY
}
sqlite_roles() {
    local parser=$1 evidence=$2 digest=$3
    "$parser" -I -S -B - "$evidence" "$digest" <<'PY'
import json
from pathlib import Path
import sys

try:
    root, digest = Path(sys.argv[1]), sys.argv[2]
    for role in ('build', 'rhel', 'debian'):
        record = json.loads((root / role / 'role.json').read_text())
        assert record['role'] == role and record['sha256'] == digest
        assert record['preservation'] == 'passed'
        assert record['probe_sha256'] == __import__('hashlib').sha256(
            (root / role / 'operator.json').read_bytes()).hexdigest()
        result = json.loads((root / role / 'operator.json').read_text())
        assert result['outcome'] == 'passed' and result['database'] == 'passed'
    # Role files are evidence to review, not signatures or a replacement for raw captures.
except (AssertionError, KeyError, OSError, ValueError, TypeError) as error:
    print(f'incomplete candidate roles: {type(error).__name__}: {error}', file=sys.stderr)
    sys.exit(2)
PY
}
