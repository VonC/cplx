#!/bin/bash
# Exercise the real installer and the real SQLite tool functions on synthetic
# source archives: the selected archive is verified before anything is
# extracted, and a reused tree is checked again before configure.
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
owned=$(mktemp -d "${TMPDIR:-/tmp}/cplx-sqlite-source.XXXXXXXX")
passed=0
trap 'status=$?; if ((status == 0)); then rm -rf -- "${owned:?}"; else echo "Fixtures retained: $owned" >&2; fi' EXIT
# A fixture-only release: the real pin table does not know it.
version=9.99.1

# Write one autoconf-shaped archive whose configure only records its run. The
# optional fourth argument changes the build files only. Member times, owners
# and order are fixed and gzip stores no time, so equal inputs give equal
# bytes and only the content can tell two archives apart.
make_archive() {
    local out=$1 amalgamation=$2 source_id=$3 build_note=${4:-} work
    work=$(mktemp -d "$owned/archive.XXXXXXXX")
    mkdir -p "$work/sqlite-autoconf-fixture"
    printf '%s\n' "$amalgamation" > "$work/sqlite-autoconf-fixture/sqlite3.c"
    printf '#define SQLITE_SOURCE_ID      "%s"\n' "$source_id" > "$work/sqlite-autoconf-fixture/sqlite3.h"
    cat > "$work/sqlite-autoconf-fixture/configure" <<'SH'
#!/bin/bash
echo configure >> "$FIXTURE/events"
exit 77
SH
    [[ -z $build_note ]] || printf '# %s\n' "$build_note" >> "$work/sqlite-autoconf-fixture/configure"
    chmod 755 "$work/sqlite-autoconf-fixture/configure"
    chmod 644 "$work/sqlite-autoconf-fixture/sqlite3.c" "$work/sqlite-autoconf-fixture/sqlite3.h"
    tar --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner -cf - -C "$work" sqlite-autoconf-fixture \
        | gzip -n > "$out"
}

canonical=$owned/canonical.tar.gz
make_archive "$canonical" 'fixture amalgamation' 'fixture source id'
# The normalization holds: rebuilding the same inputs gives the same bytes.
make_archive "$owned/canonical-again.tar.gz" 'fixture amalgamation' 'fixture source id'
cmp -s "$canonical" "$owned/canonical-again.tar.gz" || { echo 'fixture archives are not deterministic' >&2; exit 1; }
canonical_sha256=$(sha256sum "$canonical" | cut -d' ' -f1)
canonical_sha3=$(openssl dgst -sha3-256 -r "$canonical" | cut -d' ' -f1)
amalgamation_sha3=$(printf 'fixture amalgamation\n' | openssl dgst -sha3-256 -r | cut -d' ' -f1)

# Build one fixture home around copies of the real installer and tool file.
# pins=real keeps the production pin table; otherwise the fixture version is
# pinned to the canonical archive, with an optional wrong member value.
prepare() {
    case_name=$1
    local pins=$2
    fixture=$owned/$case_name
    export FIXTURE=$fixture
    sources=$fixture/tools/sqlite/sources
    mkdir -p "$sources" "$fixture/bin" "$fixture/echos" "$fixture/tools/sqlite/root/usr/bin"
    cp "$repo/src/install/env/install" "$fixture/tools/install"
    cp "$repo/src/install/env/install_functions.sh" "$fixture/tools/install_functions.sh"
    cp "$repo/src/install/env/sqlite/sqlite_install_functions.sh" "$fixture/tools/sqlite/"
    : > "$fixture/cplx.properties"
    : > "$fixture/events"
    if [[ $pins != real ]]; then
        local member=$amalgamation_sha3 source_id='fixture source id'
        [[ $pins != wrong-amalgamation ]] || member=${amalgamation_sha3/?/0}
        [[ $pins != wrong-source-id ]] || source_id='another source id'
        [[ $member != "$amalgamation_sha3" || $pins != wrong-amalgamation ]] || member=${amalgamation_sha3/?/1}
        cat >> "$fixture/tools/sqlite/sqlite_install_functions.sh" <<SH
# Fixture pin table: the verification functions above stay the real ones.
function sqlite_pinned_identity() {
    case \${version} in
        $version)
            sqlite_archive_sha256=$canonical_sha256
            sqlite_archive_sha3=$canonical_sha3
            sqlite_amalgamation_sha3=$member
            sqlite_source_id='$source_id'
            ;;
        *) error "SQLite \${version}: no pinned source identity"; return 2 ;;
    esac
}
SH
    fi
    cat > "$fixture/echos/echos" <<'SH'
info() { printf '%s\n' "$*"; }
ok() { info "$@"; }
task() { info "$@"; }
warning() { info "$@"; }
error() { info "$@" >&2; }
fatal() { error "$1"; exit "${2:-1}"; }
SH
    cp "$fixture/echos/echos" "$fixture/echos/echoslog"
    cat > "$fixture/bin/properties.sh" <<'SH'
get_property() {
    case $1 in
        services) services=sqlite ;;
        CPLX_CONFIG_DONE) CPLX_CONFIG_DONE=default ;;
        CPLX_BIN) CPLX_BIN= ;;
        *) return 91 ;;
    esac
}
SH
    cat > "$fixture/.env" <<'SH'
# Synthetic setup: the production profile and shared setenv never execute.
export HOME=$FIXTURE
source "$FIXTURE/tools/install_functions.sh"
setenv() {
    export tool_name=$1 version=$2 tool=$FIXTURE/tools/$1
    export tool_src=$tool/sources/current tool_prefix=$tool/$1-$2 root=$tool/root
}
SH
    # The sandbox compiler only builds the configure interpreter here.
    cat > "$fixture/tools/sqlite/root/usr/bin/gcc" <<'SH'
#!/bin/bash
echo gcc >> "$FIXTURE/events"
while (($#)); do [[ $1 == -o ]] && { printf '#!/bin/bash\n' > "$2"; chmod +x "$2"; }; shift; done
SH
    chmod +x "$fixture/tools/sqlite/root/usr/bin/gcc"
}

run_case() {
    local expected=$1 expected_events=$2 expected_text=$3 status=0 events
    bash "$fixture/tools/install" sqlite "$version" > "$fixture/process.log" 2>&1 || status=$?
    # The installer logs into the tool's logs folder once it gets that far.
    cat "$fixture"/tools/sqlite/logs/*.log >> "$fixture/process.log" 2>/dev/null || true
    [[ $status == "$expected" ]] || { echo "$case_name: expected $expected, got $status" >&2; tail -20 "$fixture/process.log" >&2; exit 1; }
    events=$(paste -sd, "$fixture/events")
    [[ $events == "$expected_events" ]] || { echo "$case_name: events=$events, expected=$expected_events" >&2; exit 1; }
    grep -Fq -- "$expected_text" "$fixture/process.log" \
        || { echo "$case_name: '$expected_text' not reported" >&2; tail -20 "$fixture/process.log" >&2; exit 1; }
    passed=$((passed+1))
    printf 'PASS %s\n' "$case_name"
}

# Refusals happen before extraction: no folder, no configure.
refused_before_extraction() {
    [[ ! -e $sources/$version ]] || { echo "$case_name: '$sources/$version' was extracted" >&2; exit 1; }
}

prepare corrupt-archive pinned
printf 'not an archive\n' > "$sources/sqlite-src-$version.tar.gz"
run_case 27 '' "SHA-256 of '$sources/sqlite-src-$version.tar.gz'"
refused_before_extraction

prepare unknown-version real
cp "$canonical" "$sources/sqlite-src-$version.tar.gz"
run_case 27 '' "SQLite $version: no pinned source identity"
refused_before_extraction

# The installer selects the newest matching archive: the canonical file next
# to it would pass, so only checking the selected one refuses this. The
# selected archive keeps the pinned members and differs in its build files.
prepare non-canonical-selected pinned
cp "$canonical" "$sources/sqlite-src-$version.tar.gz"
other=$sources/sqlite-other-$version.tar.gz
make_archive "$other" 'fixture amalgamation' 'fixture source id' 'different build files'
[[ $(sha256sum < "$other") != $(sha256sum < "$canonical") ]] \
    || { echo "$case_name: the selected archive equals the canonical one" >&2; exit 1; }
for member in sqlite3.c sqlite3.h; do
    cmp -s <(tar -xzOf "$other" "sqlite-autoconf-fixture/$member") <(tar -xzOf "$canonical" "sqlite-autoconf-fixture/$member") \
        || { echo "$case_name: '$member' differs from the canonical archive" >&2; exit 1; }
done
touch -d '2001-01-01' "$sources/sqlite-src-$version.tar.gz"
run_case 27 '' "SHA-256 of '$other'"
refused_before_extraction

prepare wrong-amalgamation wrong-amalgamation
cp "$canonical" "$sources/sqlite-src-$version.tar.gz"
run_case 27 '' 'amalgamation SHA3-256 of'
refused_before_extraction

prepare wrong-source-id wrong-source-id
cp "$canonical" "$sources/sqlite-src-$version.tar.gz"
run_case 27 '' "declares source id 'fixture source id', expected 'another source id'"
refused_before_extraction

# The verified archive is extracted and reaches configure, whose fixture exits 77.
prepare canonical-accepted pinned
cp "$canonical" "$sources/sqlite-src-$version.tar.gz"
run_case 199 gcc,configure "amalgamation SHA3-256 of 'sqlite-autoconf-fixture/sqlite3.c' matches"
[[ -f $sources/$version/sqlite3.c ]] || { echo "$case_name: nothing extracted" >&2; exit 1; }

# A reused extraction folder is not re-extracted: its tree is checked before configure.
prepare reused-tree-tampered pinned
cp "$canonical" "$sources/sqlite-src-$version.tar.gz"
mkdir -p "$sources/$version"
tar -xzf "$canonical" -C "$sources/$version" --strip-components=1
printf 'tampered amalgamation\n' > "$sources/$version/sqlite3.c"
run_case 2 '' "amalgamation SHA3-256 of '$sources/current/sqlite3.c'"

printf 'SQLite source verification cases passed: %s\n' "$passed"
