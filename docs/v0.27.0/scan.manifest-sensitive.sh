#!/bin/bash
# Decoder-aware sensitive-content scan for retained equivalence manifests.
#
# The manifests encode the entry path (field 1) and the symlink target (field 9)
# as lowercase hex. That encoding is reversible, so the repository's raw-text
# sensitive gate cannot see inside it: a protected term in a path would pass the
# gate and still be recoverable by anyone who decodes the field. This script
# decodes both fields and scans the decoded text, which is the check the encoding
# makes necessary.
#
# Usage:
#   bash scan.manifest-sensitive.sh <manifest> [<manifest>...]
#
# Terms come from the repository's effective replacement rules, which are
# machine-local and git-ignored. There is deliberately NO built-in fallback list:
# this repository is public, so a hardcoded list would publish the very terms it
# exists to keep out, and a guessed list would let the scan report clean against
# rules it does not have. A missing rules file is a refusal, not a weaker scan.
set -uo pipefail

RULES="a.sensitive.replacements.effective.local.txt"
TERMS=""
root=$(cd -- "$(dirname -- "$0")/../.." && pwd)
if [ -f "$root/$RULES" ]; then
    # Each rule reads [regex:]<pattern>==><replacement>; only the pattern is a
    # term. The `regex:` prefix and the inline `(?i)` flag must both come off:
    # left on, every term becomes the literal string "regex:(?i)<term>", which
    # matches nothing, and the scan reports clean on a manifest that carries the
    # term. That is exactly what this scanner ran as before it was calibrated.
    TERMS=$(sed 's/==>.*//' "$root/$RULES" | tr -d '\r' \
            | sed 's/^regex://; s/(?i)//g' | grep -v '^[[:space:]]*$')
    echo "rules   : $root/$RULES ($(printf '%s\n' "$TERMS" | wc -l | tr -d ' ') terms)"
else
    echo "REFUSED : $root/$RULES is absent, so there is nothing to scan against." >&2
    echo "          Scanning with a guessed list would report clean against rules" >&2
    echo "          this run does not have." >&2
    exit 2
fi
if [ -z "$TERMS" ]; then
    echo "REFUSED : the rules file yielded no terms, so the scan would pass on anything." >&2
    exit 2
fi

# --self-test calibrates this scanner in both directions before it is trusted,
# and does it WITHOUT a protected value anywhere in this repository: the planted
# term is taken from the machine-local rules at run time, hex-encoded into a
# throwaway manifest, and deleted. A scan that has never been made to fail is not
# evidence, and this one did report clean on a planted term until it was fixed:
# the rules carry a `regex:` prefix and an inline `(?i)`, and leaving those in
# place made every term a literal that matched nothing.
if [ "${1:-}" = "--self-test" ]; then
    tmp=$(mktemp -d)
    trap 'rm -rf -- "$tmp"' EXIT
    term=$(printf '%s\n' "$TERMS" | grep -m1 '^[A-Za-z][A-Za-z0-9]*$') || term=""
    if [ -z "$term" ]; then
        echo "REFUSED : no plain-literal term in the rules to calibrate with." >&2
        exit 2
    fi
    hex=$(printf '%s/probe' "$term" | od -An -tx1 | tr -d ' \n')
    printf '%s\tf\t10\t644\t1000.000000000\t1\t1\taaa\t-\n' "$hex" > "$tmp/planted.txt"
    printf '%s\tf\t10\t644\t1000.000000000\t1\t1\taaa\t-\n' "$(printf 'tools/bin/ok' | od -An -tx1 | tr -d ' \n')" > "$tmp/clean.txt"
    self=0
    if "$0" "$tmp/planted.txt" >/dev/null 2>&1; then
        echo "SELF-TEST FAIL: a planted term was reported clean." >&2
        self=1
    else
        echo "self-test: planted term rejected, as designed"
    fi
    if "$0" "$tmp/clean.txt" >/dev/null 2>&1; then
        echo "self-test: clean manifest accepted, as designed"
    else
        echo "SELF-TEST FAIL: a clean manifest was rejected." >&2
        self=1
    fi
    exit "$self"
fi

# A scan with nothing to scan is a refusal, not a pass. Called with no arguments
# this printed the rules count and exited 0, so a caller that lost its file list
# to a glob or a variable typo got a clean status having inspected nothing.
if [ "$#" -eq 0 ]; then
    echo "REFUSED : no manifest given, so nothing was scanned." >&2
    echo "          Usage: bash scan.manifest-sensitive.sh <manifest> [<manifest>...]" >&2
    exit 2
fi

status=0
for m in "$@"; do
    if [ ! -f "$m" ]; then
        echo "MISSING : $m" >&2
        status=2
        continue
    fi
    # Decode fields 1 and 9 with a byte table, which needs no gawk extension and
    # so behaves the same on both supported targets and on a developer host.
    decoded=$(LC_ALL=C awk -F'\t' '
        BEGIN { for (i = 0; i < 256; i++) t[sprintf("%02x", i)] = sprintf("%c", i) }
        function dec(h,   s, j) {
            if (h == "-" || h == "ROOT" || h == "") return ""
            s = ""
            for (j = 1; j <= length(h); j += 2) s = s t[substr(h, j, 2)]
            return s
        }
        { p = dec($1); g = dec($9); if (p != "") print p; if (g != "") print g }
    ' "$m")
    hits=$(printf '%s\n' "$decoded" | grep -inE "$(printf '%s' "$TERMS" | paste -sd'|' -)" || true)
    entries=$(wc -l < "$m" | tr -d ' ')
    if [ -n "$hits" ]; then
        # Counts and line numbers only. Printing the matching decoded text would
        # republish the protected value into a terminal, a CI log or a retained
        # capture at the exact moment the gate caught it, which is the opposite
        # of what this scan is for. The line number locates it; decoding that one
        # field by hand is a deliberate act.
        echo "FAIL    : $m ($entries entries) carries protected terms once decoded."
        echo "          $(printf '%s\n' "$hits" | wc -l | tr -d ' ') decoded strings match, at decoded lines:"
        printf '%s\n' "$hits" | cut -d: -f1 | paste -sd',' - | fold -w 68 | sed 's/^/          /'
        status=1
    else
        echo "clean   : $m ($entries entries, $(printf '%s\n' "$decoded" | wc -l | tr -d ' ') decoded path and target strings)"
    fi
done
exit "$status"
