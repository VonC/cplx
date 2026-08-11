#!/bin/bash
# Probe for the v0.27.0 rsync-cp-fallback equivalence manifest recipe.
#
#   C1  Does `stat -c '%.9Y'` carry usable sub-second mtime on the filesystem
#       the acceptance will actually use? A format that prints nine zeros is
#       as useless as one that errors, so C1 checks the format AND the
#       resolution.
#   C2  Are the five verification-only commands present?
#   C3  Do the exact forms the recipe specifies behave as specified here?
#
# Every C2 and C3 assertion feeds the exit status, so Step 0 can reuse this as
# a gate rather than reading its prose. Round 4 review found the first version
# exiting 0 with "C1 usable" while C2 printed MISSING and C3 printed FAIL.
#
# Read-only apart from one scratch directory it creates and removes.
#
# Usage:  bash probe.manifest-forms.sh [scratch-parent]
#
# Pass the parent of the deployment prefix when $HOME sits on a different
# filesystem from where the archive is installed: C1 is a property of the
# filesystem, not of the host.
#
# Retain the output as measurements.manifest-forms.<target>.txt.

set -u

scratch_parent="${1:-$HOME}"
scratch="${scratch_parent%/}/.cplx-probe.$$"
failures=0

cleanup() { rm -rf -- "$scratch" 2>/dev/null; }
trap cleanup EXIT

# chk <label> <expected> <actual>
chk() {
    if [ "$2" = "$3" ]; then
        printf '%-28s: OK   (%s)\n' "$1" "$3"
    else
        printf '%-28s: FAIL (want %s, got %s)\n' "$1" "$2" "$3"
        failures=$((failures + 1))
    fi
}

note_fail() {
    printf '%-28s: FAIL (%s)\n' "$1" "$2"
    failures=$((failures + 1))
}

mkdir -p -- "$scratch" || { echo "cannot create scratch under $scratch_parent"; exit 2; }

echo "=== probe.manifest-forms, v0.27.0 rsync-cp-fallback ==="
echo "date        : $(date -u '+%Y-%m-%dT%H:%M:%SZ') (UTC)"
echo "uname       : $(uname -srm)"
echo "os-release  : $( . /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-unknown}" )"
echo "coreutils   : $(stat --version 2>/dev/null | head -1)"
echo "scratch     : $scratch"
echo "filesystem  : $(df -PT -- "$scratch" 2>/dev/null | tail -1)"
echo

# ------------------------------------------------------------------------- C1
echo "--- C1  stat fractional mtime, format and resolution"
: > "$scratch/a"; : > "$scratch/b"
a=$(stat -c '%.9Y' -- "$scratch/a" 2>&1)
b=$(stat -c '%.9Y' -- "$scratch/b" 2>&1)
echo "a           : $a"
echo "b           : $b"
case "$a" in
    *.*) printf '%-28s: OK\n' "C1 fractional format" ;;
    *)   note_fail "C1 fractional format" "no fractional field" ;;
esac
if [ "$a" != "$b" ]; then
    printf '%-28s: OK   (two files differ)\n' "C1 resolution"
else
    sleep 0.01 2>/dev/null || sleep 1
    : > "$scratch/c"
    c=$(stat -c '%.9Y' -- "$scratch/c" 2>&1)
    echo "c after gap : $c"
    case "${a##*.}${c##*.}" in
        *[1-9]*) printf '%-28s: OK   (sub-second digits vary)\n' "C1 resolution" ;;
        *)       note_fail "C1 resolution" "whole-second granularity only" ;;
    esac
fi
echo "combined    : $(stat -c '%s|%a|%.9Y|%u|%g' -- "$scratch/a" 2>&1)"
echo

# ------------------------------------------------------------------------- C2
echo "--- C2  verification-only commands"
for t in timeout stat sha256sum diff mkfifo; do
    p=$(command -v "$t" 2>/dev/null)
    if [ -n "$p" ]; then printf '%-28s: OK   (%s)\n' "C2 $t" "$p"
    else note_fail "C2 $t" "MISSING"; fi
done
echo

# ------------------------------------------------------------------------- C3
echo "--- C3  exact forms the recipe specifies"
enc() { printf '%s' "$1" | od -An -v -tx1 | tr -dc '0-9a-f'; }

chk "C3 encoder jln" "6a6c6e" "$(enc 'jln')"

printf 'hello' > "$scratch/h"
d=$(sha256sum -z -- "$scratch/h" 2>/dev/null | head -c 64)
chk "C3 digest length" "64" "${#d}"
chk "C3 digest value" \
    "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824" "$d"

# Symlink target ending in a newline: the case that detects trailing-newline
# stripping, which a plain target cannot. Built without command substitution.
nl_target=$(printf 'tgt\n_'); nl_target="${nl_target%_}"
if ln -s -- "$nl_target" "$scratch/lnl" 2>/dev/null; then
    # exactly the recipe's pipeline: readlink -n piped straight into the encoder
    got=$(readlink -n -- "$scratch/lnl" | od -An -v -tx1 | tr -dc '0-9a-f')
    chk "C3 readlink -n newline" "7467740a" "$got"
else
    note_fail "C3 readlink -n newline" "could not create the symlink fixture"
fi

awkward=$(printf 'odd name\twith\nnewline_'); awkward="${awkward%_}"
if : > "$scratch/$awkward" 2>/dev/null; then
    n=0
    while IFS= read -r -d '' rel; do
        [ -n "$rel" ] && n=$((n + 1))
    done < <(find "$scratch" -mindepth 1 -printf '%P\0')
    if [ "$n" -ge 1 ]; then printf '%-28s: OK   (%s entries)\n' "C3 NUL enumeration" "$n"
    else note_fail "C3 NUL enumeration" "no entries enumerated"; fi
    case "$(enc "$awkward")" in
        *0a*) printf '%-28s: OK\n' "C3 awkward name encodes" ;;
        *)    note_fail "C3 awkward name encodes" "newline byte absent from hex" ;;
    esac
else
    note_fail "C3 awkward fixture" "could not create the awkward-name fixture"
fi

printf 'b\na\n' > "$scratch/s"
if LC_ALL=C sort -o "$scratch/s" "$scratch/s"; then
    chk "C3 sort -o" "a b" "$(tr '\n' ' ' < "$scratch/s" | sed 's/ $//')"
else
    note_fail "C3 sort -o" "sort failed"
fi

printf 'zzz\n' | grep -Eril -f - -- "$scratch" >/dev/null 2>&1
chk "C3 grep -f - status" "1" "$?"
echo

# ---------------------------------------------------------------------- verdict
echo "=== VERDICT ==="
if [ "$failures" -eq 0 ]; then
    echo "All C1, C2 and C3 assertions passed on this target."
    exit 0
fi
echo "$failures assertion(s) FAILED. The manifest recipe or its tool set does not"
echo "hold on this target as written. Report this output before acceptance."
exit 1
