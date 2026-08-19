#!/bin/bash
# Verification harness for the v0.27.0 relocation-force-rpath effort.
#
# This is the executable oracle of
# docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md. Step 0 writes no
# production behaviour: it captures what the CURRENT installer does, so every
# later step is judged against a measured baseline rather than against the
# plan's prose.
#
# Usage:
#   bash verify.relocation-rpath.sh [--step N] [--installer PATH] [--prefix DIR]
#                                   [--patchelf PATH]
#
# It is deliberately NOT an extension of verify.install-pkg.sh (plan Q01): that
# file carries a shared-body marker declaring everything below one line
# byte-identical to the consuming project's copy, so adding cases here would
# either sit outside the marker, splitting that file's identity, or owe a
# cross-repo update on every change. What is duplicated here is scaffolding
# rather than judgement.
#
# Case contract, taken from the harness this collection already reviewed:
#   * a case PLANTS its fixture and asserts the plant, so a case cannot report a
#     shape it never created;
#   * a case DECLARES the installer and prefix it intends to exercise, and the
#     harness asserts the resolved values against those declarations. Recording
#     an identity is not asserting it: a recorded value still lets a case
#     exercise the wrong copy and pass;
#   * the harness's own first case is a negative control proving that an
#     unplanted fixture FAILS, so a suite that blesses anything is caught.
#
# The prerequisite preflight (plan Q03) runs at the START of every invocation,
# before the installer is sourced and before any case-specific environment
# mutation, so nothing a case arranges can influence what it resolves. Each
# --step N run is a FRESH PROCESS: a path resolved in the --step 0 run cannot
# survive into the --step 1 run, so every dependent step reruns the preflight
# rather than inheriting a value.

set -u

# ----------------------------------------------------------------- arguments ---
STEP=0
INSTALLER=""
INSTALLER_ARG=""
PREFIX_ARG=""
PATCHELF_ARG=""
TARGET_CAPABILITY_FILE=""
REPRESENTATIVE_CAPABILITY_FILE=""
TARGET_IS_EXACT=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --step) STEP="$2"; shift 2 ;;
        --installer) INSTALLER="$2"; INSTALLER_ARG="$2"; shift 2 ;;
        --prefix) PREFIX_ARG="$2"; shift 2 ;;
        # The agent that can run this step ships patchelf inside the extracted
        # prefix rather than on PATH, so it must be namable.
        --patchelf) PATCHELF_ARG="$2"; shift 2 ;;
        # The exact-target capability is measured, never assumed: either this run
        # IS on the target, or it reads a retained measurement from one.
        --target-capability) TARGET_CAPABILITY_FILE="$2"; shift 2 ;;
        # The plan's provisional branch: version-pinned RHEL 9 or UBI 9 evidence
        # where the exact target cannot be reached. It opens the branch and
        # records the debt; it does not discharge it.
        --representative-capability) REPRESENTATIVE_CAPABILITY_FILE="$2"; shift 2 ;;
        --target-is-exact) TARGET_IS_EXACT=1; shift ;;
        -h|--help) sed -n '2,35p' "$0"; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

# Only step 0 has a case suite today. Accepting any other value would let the
# verdict line report success for a step whose cases do not exist, which is a
# vacuous pass at exactly the level later steps rely on. Extend this dispatch
# and the suite together.
case "$STEP" in
    0) ;;
    *) echo "unsupported --step $STEP: only step 0 has a case suite today." >&2
       echo "Add its suite and extend this dispatch before requesting it." >&2
       exit 2 ;;
esac

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -z "$INSTALLER" ]; then
    for cand in \
        "$here/../../src/setups/env/bin/install_pkg.sh" \
        "$HOME/tools/bin/install_pkg.sh" \
        "$here/../../cplx/src/setups/env/bin/install_pkg.sh"; do
        [ -f "$cand" ] && { INSTALLER="$cand"; break; }
    done
fi
[ -n "$INSTALLER" ] || { echo "no installer found; pass --installer PATH" >&2; exit 2; }
[ -f "$INSTALLER" ] || { echo "installer not found: $INSTALLER" >&2; exit 2; }
INSTALLER=$(cd "$(dirname "$INSTALLER")" && pwd)/$(basename "$INSTALLER")

SCRATCH="${TMPDIR:-/tmp}/cplx-relocation-verify.$$"
failures=0
cases=0

# shellcheck disable=SC2329  # invoked indirectly by the EXIT trap below
cleanup() { rm -rf -- "$SCRATCH" 2>/dev/null; }
trap cleanup EXIT
mkdir -p -- "$SCRATCH" || { echo "cannot create scratch $SCRATCH" >&2; exit 2; }

PREFIX="${PREFIX_ARG:-$SCRATCH/prefix}"
mkdir -p -- "$PREFIX"

# ----------------------------------------------------------------- reporting ---
EXPECT_FAIL=0
CTL_REASON=""
pass() { printf '  %-40s PASS  %s\n' "$1" "${2:-}"; }
# In a negative control the failure IS the expected result, so it is captured
# rather than printed: a log a reader scans for FAIL must not show one the next
# line contradicts. Only the control helper sets this flag, and it always clears
# it, so no early return leaves the harness deaf to real failures.
fail() {
    if [ "$EXPECT_FAIL" -eq 1 ]; then CTL_REASON="${2:-}"; return 0; fi
    printf '  %-40s FAIL  %s\n' "$1" "${2:-}"
    failures=$((failures + 1))
}
chk() {
    cases=$((cases + 1))
    if [ "$2" = "$3" ]; then pass "$1" "$3"; else fail "$1" "want [$2] got [$3]"; fi
}
note() { printf '  %-40s NOTE  %s\n' "$1" "${2:-}"; }
section() { printf '\n== %s\n' "$1"; }

# control <name> <required-reason-prefix> <command...>
# The reason prefix is the whole point: a control demanding only "FIXTURE" would
# be satisfied by a different failure than the one it exists to prove. Inner
# case counting is rolled back so a control is exactly one case either way.
control() {
    local name="$1" want="$2"; shift 2
    local saved="$cases"
    EXPECT_FAIL=1; CTL_REASON=""
    "$@" >/dev/null 2>&1
    EXPECT_FAIL=0
    cases=$((saved + 1))
    case "$CTL_REASON" in
        "$want"*) pass "$name" "refused on [$want], as designed" ;;
        "")       fail "$name" "passed, so that oracle is not asserted" ;;
        *)        fail "$name" "refused for the wrong reason: $CTL_REASON" ;;
    esac
}

# ------------------------------------------------------ prerequisite preflight ---
# Resolve, check, THEN declare. A combined readonly VAR="$(type -P x)" yields the
# exit status of readonly rather than of the substitution, so a failed resolution
# is masked and the variable is frozen empty: no error, and an unusable pin that
# cannot be reassigned. shellcheck reports that form under SC2155.
#
# type -P is used rather than command -v because it searches the command path and
# yields a PATH, where command -v also resolves a shell function or an alias of
# that name.
#
# The resolved path is returned through a NAMED VARIABLE rather than on stdout.
# An earlier version printed it and was called in a command substitution, which
# put the failure diagnostics into the variable and ran the whole function in a
# subshell, so PREFLIGHT_OK=0 never reached the parent and the gate could not
# trip. A check whose failure path cannot be observed is not a check.
PREFLIGHT_OK=1
PREFLIGHT_PATH=""
preflight_tool() {
    local label="$1" probe="$2" resolved=""
    PREFLIGHT_PATH=""
    resolved=$(type -P "$label" 2>/dev/null) || resolved=""
    if [ -z "$resolved" ]; then
        fail "preflight/$label" "PREFLIGHT unresolved: type -P found nothing"
        PREFLIGHT_OK=0
        return 1
    fi
    case "$resolved" in
        /*) ;;
        *) fail "preflight/$label" "PREFLIGHT not absolute: $resolved"
           PREFLIGHT_OK=0
           return 1 ;;
    esac
    if [ ! -f "$resolved" ]; then
        fail "preflight/$label" "PREFLIGHT not a regular file: $resolved"
        PREFLIGHT_OK=0
        return 1
    fi
    if [ ! -x "$resolved" ]; then
        fail "preflight/$label" "PREFLIGHT not executable: $resolved"
        PREFLIGHT_OK=0
        return 1
    fi
    if ! "$resolved" "$probe" >/dev/null 2>&1; then
        fail "preflight/$label" "PREFLIGHT interface check failed: $resolved $probe"
        PREFLIGHT_OK=0
        return 1
    fi
    PREFLIGHT_PATH="$resolved"
    pass "preflight/$label" "$resolved"
    cases=$((cases + 1))
}

section "harness prerequisite preflight"
if preflight_tool readelf --version; then
    readonly READELF_BIN="$PREFLIGHT_PATH"
else
    READELF_BIN=""
fi
if preflight_tool sha256sum --version; then
    readonly SHA256SUM_BIN="$PREFLIGHT_PATH"
else
    SHA256SUM_BIN=""
fi

# The gate is recorded here and ENFORCED before the baseline, not here. An
# earlier version exited 3 immediately, which made the claim that the
# host-independent cases "run anywhere" false: on a host without `readelf` no
# case ran at all. The gate is still incomplete and the run still ends non-zero;
# what changes is that the cases which need neither prerequisite are allowed to
# report first, so a host missing one tool still learns whether the seam and the
# host-tool contract hold.
#
# The two cases that DO need a prerequisite are skipped explicitly rather than
# run against an empty pin: the installer digest needs sha256sum, and every
# baseline case needs readelf.
if [ "$PREFLIGHT_OK" -ne 1 ]; then
    printf '\n  %-40s NOTE  gate incomplete; host-independent cases still run\n' "preflight/gate"
fi

# ------------------------------------------------------------ capability gate ---
# declare -A is an interpreter capability rather than a new external program, so
# the installer's host-tool contract is unaffected. The check has THREE outcomes:
# "we could not ask" is not an answer, and treating it as unsupported would
# revise the plan away from the safer carrier on the strength of a machine
# nobody could log into.
section "capability gate: declare -A"
LOCAL_BASH="${BASH_VERSION:-unknown}"
if ( declare -A _cap_probe 2>/dev/null && _cap_probe[k]=v && [ "${_cap_probe[k]}" = "v" ] ); then
    ASSOC_LOCAL=supported
else
    ASSOC_LOCAL=unsupported
fi
chk "assoc-array/local" "supported" "$ASSOC_LOCAL"
note "assoc-array/local-bash" "$LOCAL_BASH"

# ONE production path for capability evidence, used by the real evidence and by
# every negative case.
#
# capability_verdict FILE IDENTITY_PATTERN -> one token on stdout, no side
# effects: ok | absent | duplicate | identity | capability | unavailable |
# malformed | bash. The first failing condition wins, in the order a reader would
# check them: the file must exist, must not disagree with itself, must name a
# target the caller expects, must carry a usable outcome, and must record the
# interpreter it was measured on.
#
# The identity pattern is a parameter because the plan admits two kinds of
# evidence with different identities: the EXACT target, RHEL 9.8, and the
# representative version-pinned RHEL 9 or UBI 9 image that opens the provisional
# branch. One parser, two patterns, rather than two parsers.
EXPECT_TARGET_EXACT='^Red Hat Enterprise Linux 9\.8([^0-9.].*)?$'
EXPECT_TARGET_REPRESENTATIVE='^(Red Hat Enterprise Linux|Red Hat Universal Base Image|UBI) 9\.[0-9]+([^0-9.].*)?$'

capability_verdict() {
    local file="$1" pattern="$2" fld n tid cap tbash
    [ -f "$file" ] || { printf 'absent'; return; }
    for fld in target declare-A bash; do
        n=$(grep -cE "^$fld:" "$file")
        [ "$n" -le 1 ] || { printf 'duplicate'; return; }
    done
    tid=$(grep -m1 '^target:' "$file" | cut -d: -f2- | sed 's/^ *//; s/ *$//')
    cap=$(grep -m1 '^declare-A:' "$file" | cut -d: -f2- | tr -d ' ')
    tbash=$(grep -m1 '^bash:' "$file" | cut -d: -f2- | sed 's/^ *//; s/ *$//')
    printf '%s' "$tid" | grep -qE "$pattern" || { printf 'identity'; return; }
    case "$cap" in
        supported)   ;;
        unsupported) printf 'capability'; return ;;
        unavailable) printf 'unavailable'; return ;;
        *)           printf 'malformed'; return ;;
    esac
    [ -n "$tbash" ] || { printf 'bash'; return; }
    printf 'ok'
}

# Which evidence a run has, decided in one function so both the ordinary paths
# and the two that carry no file are directly callable by a case.
#
# capability_source EXACT_FILE REPRESENTATIVE_FILE -> "<kind> <verdict>"
#   exact ...          an exact-target file was named
#   representative ... only a representative file was named
#   blocked none       neither was named
#
# `blocked` is the correction this round makes. The previous version treated
# "no evidence at all" as a NOTE and let the run continue, so an otherwise
# capable Debian run could report OBJECTIVE MET while knowing nothing about the
# target. The plan says the opposite: unavailable records Step 0 as BLOCKED
# unless representative version-pinned evidence is captured instead. Silence
# about the target is not a benign outcome, it is the branch that stops the step.
capability_source() {
    local exact="$1" repr="$2"
    if [ -n "$exact" ]; then
        printf 'exact %s' "$(capability_verdict "$exact" "$EXPECT_TARGET_EXACT")"
    elif [ -n "$repr" ]; then
        printf 'representative %s' "$(capability_verdict "$repr" "$EXPECT_TARGET_REPRESENTATIVE")"
    else
        printf 'blocked none'
    fi
}

# The negative cases, routed through the production functions above. Each crafts
# a file and asserts the exact verdict it must draw, so a change to the parser is
# a change to what these observe.
cap_probe="$SCRATCH/cap-probe.txt"
while IFS='|' read -r want body; do
    [ -n "$want" ] || continue
    printf '%b' "$body" > "$cap_probe"
    got=$(capability_verdict "$cap_probe" "$EXPECT_TARGET_EXACT")
    chk "target-capability/$want" "$want" "$got"
done <<'CAPCASES'
identity|target: Debian GNU/Linux 12 (bookworm)\ndeclare-A: supported\nbash: 5.2.15\n
identity|target: Red Hat Enterprise Linux 9.80 (not 9.8)\ndeclare-A: supported\nbash: 5.1.8\n
identity|target: Red Hat Enterprise Linux 9.7 (Plow)\ndeclare-A: supported\nbash: 5.1.8\n
capability|target: Red Hat Enterprise Linux 9.8 (Plow)\ndeclare-A: unsupported\nbash: 5.1.8\n
unavailable|target: Red Hat Enterprise Linux 9.8 (Plow)\ndeclare-A: unavailable\nbash: 5.1.8\n
malformed|target: Red Hat Enterprise Linux 9.8 (Plow)\ndeclare-A:\nbash: 5.1.8\n
bash|target: Red Hat Enterprise Linux 9.8 (Plow)\ndeclare-A: supported\nbash:\n
duplicate|target: Red Hat Enterprise Linux 9.8 (Plow)\ndeclare-A: supported\ndeclare-A: unsupported\nbash: 5.1.8\n
ok|target: Red Hat Enterprise Linux 9.8 (Plow)\ndeclare-A: supported\nbash: 5.1.8\n
CAPCASES
rm -f "$cap_probe"

# A named-but-missing file is `absent`, and it is a case rather than a branch
# nobody exercises: a caller pointing at a path that does not exist must be told
# so, not treated as having supplied nothing.
chk "target-capability/absent" "absent" \
    "$(capability_verdict "$SCRATCH/no-such-capability-file.txt" "$EXPECT_TARGET_EXACT")"

# The three source branches, including the two that carry no file at all.
chk "target-source/none-is-blocked" "blocked none" "$(capability_source "" "")"
repr_probe="$SCRATCH/repr-probe.txt"
printf 'target: Red Hat Universal Base Image 9.4\ndeclare-A: supported\nbash: 5.1.8\n' > "$repr_probe"
chk "target-source/representative" "representative ok" "$(capability_source "" "$repr_probe")"
printf 'target: Debian GNU/Linux 12\ndeclare-A: supported\nbash: 5.2.15\n' > "$repr_probe"
chk "target-source/representative-identity" "representative identity" \
    "$(capability_source "" "$repr_probe")"
rm -f "$repr_probe"

# The outcome for this run, drawn through those same functions.
if [ "$TARGET_IS_EXACT" -eq 1 ]; then
    # The flag is a claim about this host, so it is written out and read back
    # through the production verdict rather than believed.
    here_cap="$SCRATCH/here-capability.txt"
    # shellcheck disable=SC1091  # /etc/os-release exists on the target, not on the authoring host
    printf 'target: %s\ndeclare-A: %s\nbash: %s\n' \
        "$(. /etc/os-release 2>/dev/null && printf '%s' "$PRETTY_NAME")" \
        "$ASSOC_LOCAL" "$LOCAL_BASH" > "$here_cap"
    TARGET_EVIDENCE="$here_cap"
    target_kind="exact"
    target_verdict=$(capability_verdict "$here_cap" "$EXPECT_TARGET_EXACT")
    target_src="measured here"
else
    read -r target_kind target_verdict <<<"$(capability_source "$TARGET_CAPABILITY_FILE" "$REPRESENTATIVE_CAPABILITY_FILE")"
    case "$target_kind" in
        exact)          TARGET_EVIDENCE="$TARGET_CAPABILITY_FILE"; target_src="retained exact capture" ;;
        representative) TARGET_EVIDENCE="$REPRESENTATIVE_CAPABILITY_FILE"; target_src="representative capture" ;;
        *)              TARGET_EVIDENCE=""; target_src="no capability evidence" ;;
    esac
fi

if [ "$target_kind" = "exact" ] && [ "$target_verdict" = "ok" ]; then
    ASSOC_TARGET=supported
    pass "assoc-array/exact-target" "supported ($target_src)"
    cases=$((cases + 1))
elif [ "$target_kind" = "representative" ] && [ "$target_verdict" = "ok" ]; then
    # The plan's provisional branch: representative pinned evidence justifies
    # writing the carrier and does not satisfy the exact-target requirement, so
    # the debt is recorded here rather than discharged.
    ASSOC_TARGET=provisional
    pass "assoc-array/exact-target" "provisional on representative evidence ($target_src)"
    cases=$((cases + 1))
    note "assoc-array/exact-target-debt" "exact-target confirmation is due at Step 6"
elif [ "$target_verdict" = "capability" ]; then
    ASSOC_TARGET=unsupported
    fail "assoc-array/exact-target" \
        "unsupported on the target: STOP and revise the plan, per Q05 ($target_src)"
    cases=$((cases + 1))
elif [ "$target_kind" = "blocked" ]; then
    ASSOC_TARGET=blocked
    fail "assoc-array/exact-target" \
        "Step 0 is BLOCKED: no exact-target evidence and no representative evidence. Pass --target-capability or --representative-capability"
    cases=$((cases + 1))
else
    ASSOC_TARGET=rejected
    fail "assoc-array/exact-target" \
        "evidence refused on [$target_verdict] ($target_src)"
    cases=$((cases + 1))
fi

if [ -n "$TARGET_EVIDENCE" ] && [ -f "$TARGET_EVIDENCE" ]; then
    note "assoc-array/exact-target-id" \
        "$(grep -m1 '^target:' "$TARGET_EVIDENCE" | cut -d: -f2- | sed 's/^ *//')"
    note "assoc-array/exact-target-bash" \
        "$(grep -m1 '^bash:' "$TARGET_EVIDENCE" | cut -d: -f2- | sed 's/^ *//')"
fi

# -------------------------------------------------------------- step 0 cases ---
section "step 0: seam"

# Negative control. The harness's own first case must fail when its fixture is
# not planted, otherwise every later PASS is worth nothing.
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
unplanted_case() {
    local marker="$SCRATCH/never-planted/marker"
    if [ ! -f "$marker" ]; then
        fail "fixture-guard" "FIXTURE absent: $marker was never planted"
        return 1
    fi
    pass "fixture-guard" "planted"
}
control "control/unplanted-fixture" "FIXTURE" unplanted_case

# Declared identity, asserted rather than recorded. A recorded value still lets
# a case exercise the wrong copy and pass.
#
# When --installer names a copy, the DECLARATION is that argument and the
# assertion is that resolution did not wander from it. An earlier version
# hardcoded this repository's own layout, `$here/../../src/setups/env/bin`, and
# on a host where that directory does not exist the `cd` failed and the expected
# value silently became the string "/install_pkg.sh". A check whose expected
# value is manufactured by a failure is not a check.
if [ -n "$INSTALLER_ARG" ]; then
    DECLARED_INSTALLER=$(cd "$(dirname "$INSTALLER_ARG")" 2>/dev/null && pwd)/$(basename "$INSTALLER_ARG")
    chk "identity/installer" "$DECLARED_INSTALLER" "$INSTALLER"
    note "identity/declared-by" "--installer argument"
else
    DECLARED_DIR=$(cd "$here/../../src/setups/env/bin" 2>/dev/null && pwd) || DECLARED_DIR=""
    if [ -n "$DECLARED_DIR" ]; then
        chk "identity/installer" "$DECLARED_DIR/install_pkg.sh" "$INSTALLER"
        note "identity/declared-by" "default in-tree resolution"
    else
        fail "identity/installer" "no --installer given and the in-tree default does not exist"
        cases=$((cases + 1))
    fi
fi
if [ -n "${SHA256SUM_BIN:-}" ]; then
    note "identity/installer-digest" "$("$SHA256SUM_BIN" -- "$INSTALLER" | cut -c1-12)"
else
    note "identity/installer-digest" "skipped: sha256sum did not resolve"
fi

# Sourcing defines the functions and performs no install. The prefix is counted
# before and after: an install would create pkgs/ beneath it.
#
# The installer is sourced from an ISOLATED COPY in scratch, never in place.
# `install_pkg.sh` resolves its `echos` helper relative to its own directory,
# "$INSTALL_PKG_DIR/echos" then "$INSTALL_PKG_DIR/../echos/echos", and falls back
# to built-in message functions when neither exists. Sourcing it where the caller
# happens to keep it therefore lets ANY file named `echos` beside it join the
# test. On the CI agent that is exactly what happened: the candidate sat in a
# tools directory that contains an unrelated project's `echos`, which was sourced
# instead of the fallbacks and took the probe down with it, and four downstream
# cases failed for a reason that had nothing to do with the installer.
#
# An isolated copy also reproduces the shape the requirement cares about: the
# script copied next to an archive on a bare account, running alone. The resolved
# helper is recorded either way, so the evidence says which one was in play
# rather than leaving it to be inferred.
ISOLATED_DIR="$SCRATCH/isolated"
mkdir -p -- "$ISOLATED_DIR"
ISOLATED_INSTALLER="$ISOLATED_DIR/install_pkg.sh"
cp -- "$INSTALLER" "$ISOLATED_INSTALLER"
if [ -f "$ISOLATED_DIR/echos" ]; then
    note "seam/echos-resolved" "$ISOLATED_DIR/echos"
else
    note "seam/echos-resolved" "none; the installer's built-in fallbacks are used"
fi

before_entries=$(find "$PREFIX" -mindepth 1 | wc -l | tr -d ' ')
source_probe=$(
    bash -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1
        rc=$?
        missing=""
        for fn in usage select_copy_engine find_patchelf find_dynamic_linker \
                  build_elf_rpath fix_elf_paths sed_escape_replacement \
                  sed_escape_pattern; do
            declare -F "$fn" >/dev/null 2>&1 || missing="${missing:+$missing,}$fn"
        done
        printf "PROBE|%s|%s" "$rc" "$missing"
    ' _ "$ISOLATED_INSTALLER" 2>/dev/null
)
after_entries=$(find "$PREFIX" -mindepth 1 | wc -l | tr -d ' ')

# The probe must be shown to have RUN before its values are read. An earlier
# version derived both values by stripping a delimiter, so a probe that died
# before printing anything yielded an empty status and an empty missing-list,
# and the missing-list then compared equal to the expected empty string. That is
# a vacuous pass: it reported every production function defined on a run where
# nothing was ever asked. The PROBE sentinel is what makes the difference
# observable.
case "$source_probe" in
    PROBE\|*)
        pass "seam/probe-ran" "sentinel present"
        cases=$((cases + 1))
        source_rest="${source_probe#PROBE|}"
        source_rc="${source_rest%%|*}"
        source_missing="${source_rest#*|}"
        chk "seam/source-returns-zero" "0" "$source_rc"
        chk "seam/no-install-on-source" "$before_entries" "$after_entries"
        # The harness asserts every production function it intends to call is
        # defined, so a function accidentally left below the main boundary is a
        # loud failure rather than a silent absence.
        chk "seam/functions-defined" "" "$source_missing"
        SOURCE_OK=1
        ;;
    *)
        fail "seam/probe-ran" "the probe produced no sentinel: it died before reporting"
        cases=$((cases + 1))
        SOURCE_OK=0
        ;;
esac

# The boundary and its guard exist where the plan puts them: after every
# definition and before the argument parsing that begins the main flow.
# The guard SPECIFICALLY, not any mention of BASH_SOURCE. The installer has a
# legitimate BASH_SOURCE[0] use at line 19 for INSTALL_PKG_DIR, and matching the
# first occurrence made this assertion PASS against that line: a false pass,
# which is worse than a missing check because it reports the property as held.
guard_line=$(grep -n 'MAIN BOUNDARY' "$INSTALLER" | head -1 | cut -d: -f1)
# shellcheck disable=SC2016  # the literal ${BASH_SOURCE[0]} is installer text to match
guard_test_line=$(grep -cE '^if \[ "\$\{BASH_SOURCE\[0\]\}" != "\$0" \]; then$' "$INSTALLER")
chk "seam/guard-present" "1" "$guard_test_line"
parse_line=$(grep -n '^# --- 1. Argument Parsing ---' "$INSTALLER" | head -1 | cut -d: -f1)
usage_def_line=$(grep -n '^usage() {' "$INSTALLER" | head -1 | cut -d: -f1)
sce_def_line=$(grep -n '^select_copy_engine() {' "$INSTALLER" | head -1 | cut -d: -f1)
if [ -n "$guard_line" ] && [ -n "$parse_line" ] && [ "$guard_line" -lt "$parse_line" ]; then
    pass "seam/guard-precedes-main" "guard $guard_line, main $parse_line"
else
    fail "seam/guard-precedes-main" "guard [$guard_line] main [$parse_line]"
fi
cases=$((cases + 1))
if [ -n "$usage_def_line" ] && [ "$usage_def_line" -lt "$guard_line" ] \
   && [ -n "$sce_def_line" ] && [ "$sce_def_line" -lt "$guard_line" ]; then
    pass "seam/definitions-above-boundary" "usage $usage_def_line, engine $sce_def_line"
else
    fail "seam/definitions-above-boundary" "usage [$usage_def_line] engine [$sce_def_line]"
fi
cases=$((cases + 1))

# Executing the installer is unchanged by the rearrangement. With no argument it
# must still refuse on the usage path, which is the one flow calling a function
# whose definition moved.
exec_out=$(bash "$INSTALLER" 2>&1); exec_rc=$?
chk "seam/execute-still-refuses" "1" "$exec_rc"
case "$exec_out" in
    *"Usage:"*) pass "seam/execute-usage-path" "usage reached from the main flow" ;;
    *) fail "seam/execute-usage-path" "no usage diagnostic: $exec_out" ;;
esac
cases=$((cases + 1))

section "step 0: host-tool contract"

# ------------------------------------------------------------- host-tool rule ---
# One rule, replacing the two the previous round carried. The property is that no
# forbidden tool is INVOKED by the installer, and an invocation is a name in
# COMMAND POSITION: at the start of a command, or after a pipe, a separator, a
# subshell opener or a control keyword. A name anywhere else is an argument or a
# path fragment.
#
# Command position is matched instead of adjacency, because the adjacency form
# the previous round used excluded any name touching a slash and therefore let
# `/usr/bin/python` and `./readelf` through. Matching position rejects those and
# still ignores `"$INSTALL_PREFIX/tools/python/root/lib64/..."`, which is an
# argument, and the `# python first ...` comment, which is not code.
HOST_TOOLS='readelf|sha256sum|stat|wc|awk|perl|python'
host_tool_invocations() {
    grep -vE '^[[:space:]]*#' "$1" \
    | grep -oE "(^|[;&|(]|&&|\|\||\\\$\(|\`|[[:space:]](then|else|do|elif)[[:space:]])[[:space:]]*(\./|/)?([[:alnum:]_./-]*/)?($HOST_TOOLS)([[:space:]]|$|;|\)|\|)" \
    | wc -l | tr -d ' '
}
host_tool_hits=$(host_tool_invocations "$INSTALLER")
chk "host-tool/no-invocations" "0" "$host_tool_hits"

# Negative cases. A rule that only ever returns zero proves nothing, so it is
# shown to REJECT each shape the contract forbids. The last two are the shapes
# the previous round's adjacency rule let through, which is why they are here by
# name rather than as a general "path-qualified" gesture.
#
# The shapes are read from a heredoc rather than written as a quoted list: they
# contain the quoting the rule exists to parse, and embedding them in the script
# would make this file's own quoting the thing under test.
ht_probe="$SCRATCH/host-tool-probe.sh"
ht_reject="$SCRATCH/host-tool-reject.txt"
cat > "$ht_reject" <<'REJECT'
python -c pass
/usr/bin/python -c pass
./readelf -d x
foo | awk '{print}'
value=$(sha256sum x)
if true; then wc -l x; fi
REJECT
while IFS= read -r shape; do
    [ -n "$shape" ] || continue
    { printf '#!/bin/bash\n'; printf '%s\n' "$shape"; } > "$ht_probe"
    got=$(host_tool_invocations "$ht_probe")
    if [ "$got" -ge 1 ]; then
        pass "host-tool/rejects" "$shape"
    else
        fail "host-tool/rejects" "let through: $shape"
    fi
    cases=$((cases + 1))
done < "$ht_reject"

# And it must NOT reject the benign shapes the installer legitimately contains,
# or it would be unusable and would invite being loosened, which is the move the
# plan forbids.
ht_allow="$SCRATCH/host-tool-allow.txt"
cat > "$ht_allow" <<'ALLOW'
    candidate="$INSTALL_PREFIX/tools/python/root/lib64/ld-linux-x86-64.so.2"
for tool_dir in "$INSTALL_PREFIX/tools/python" "$P"/tools/*/; do
ALLOW
while IFS= read -r shape; do
    [ -n "$shape" ] || continue
    { printf '#!/bin/bash\n'; printf '%s\n' "$shape"; } > "$ht_probe"
    got=$(host_tool_invocations "$ht_probe")
    if [ "$got" -eq 0 ]; then
        pass "host-tool/allows-path-argument" "argument, not a command"
    else
        fail "host-tool/allows-path-argument" "wrongly rejected: $shape"
    fi
    cases=$((cases + 1))
done < "$ht_allow"

# ------------------------------------------------- host capability for the step ---
# A step this host CANNOT run must say so distinctly, and must not be reported as
# a code failure or quietly answered by something cheaper. Step 0's baseline is a
# real relocation run over a real ELF, so it needs an ELF-capable host with
# patchelf and binutils. The authoring host and the validation host are not
# necessarily the same machine, which the plan does not currently say.
#
# An earlier version of this harness had no such gate, and the consequence was
# exactly what the gate exists to prevent: unable to run the production pass, it
# inferred the baseline from the installer's SOURCE TEXT, greping for
# `--force-rpath` to decide the tag and for the `Fixed` format string to decide
# the report. Step 0 exists so later steps are judged against a measurement
# rather than a description, and that version captured the description.
#
# patchelf is resolved the way `find_patchelf` resolves it, read from lines 301
# to 314: the prefix first, then the home tools directory, then the command path.
# The first version of this gate used `type -P patchelf` alone, and that is wrong
# for the target it exists to enable: a CI agent ships patchelf INSIDE the
# extracted prefix and never on PATH, so a PATH-only gate would have refused the
# baseline on the one host able to run it. Resolving as production resolves is
# also the honest form, since the pass under test will resolve it that way.
HOST_OK=1
HOST_WHY=""
PATCHELF_BIN=""
resolve_patchelf() {
    local cand
    if [ -n "$PATCHELF_ARG" ]; then
        [ -x "$PATCHELF_ARG" ] && { PATCHELF_BIN="$PATCHELF_ARG"; return 0; }
        return 1
    fi
    for cand in "${PREFIX_ARG:-}/tools/bin/patchelf" "$HOME/tools/bin/patchelf"; do
        [ -x "$cand" ] && { PATCHELF_BIN="$cand"; return 0; }
    done
    cand=$(type -P patchelf 2>/dev/null) || cand=""
    [ -n "$cand" ] && { PATCHELF_BIN="$cand"; return 0; }
    return 1
}

section "host capability for step $STEP"
# The prerequisite gate is enforced here, before any baseline case, since every
# one of them needs readelf. A host that failed the preflight cannot answer the
# baseline whatever its patchelf situation.
if [ "$PREFLIGHT_OK" -ne 1 ]; then
    HOST_OK=0
    HOST_WHY="${HOST_WHY:+$HOST_WHY, }an unresolved harness prerequisite"
fi
if ! resolve_patchelf; then
    HOST_OK=0
    HOST_WHY="${HOST_WHY:+$HOST_WHY, }patchelf (prefix, home tools, or command path)"
fi
case "$(uname -s 2>/dev/null)" in
    Linux) ;;
    *) HOST_OK=0
       HOST_WHY="${HOST_WHY:+$HOST_WHY, }a Linux host (this is $(uname -s 2>/dev/null))" ;;
esac
if [ "$HOST_OK" -eq 1 ]; then
    pass "host/can-run-step-$STEP" "patchelf $PATCHELF_BIN on a Linux host"
    cases=$((cases + 1))
else
    printf '  %-40s SKIP  missing: %s\n' "host/can-run-step-$STEP" "$HOST_WHY"
fi

# -------------------------------------------------------------------- baseline ---
# The current pass writes DT_RUNPATH and reports one mixed count. Both are
# MEASURED from a real run, never read out of the installer's source.
section "step 0: baseline capture"

if [ "$HOST_OK" -ne 1 ]; then
    printf '\nHOST CANNOT SATISFY STEP %s\n' "$STEP"
    printf 'Missing: %s\n' "$HOST_WHY"
    printf '\nThe seam cases above ran and their result stands. The baseline did\n'
    printf 'NOT run, and no substitute was accepted: reading the tag out of the\n'
    printf 'installer source or counting a planted text file would answer a\n'
    printf 'different question than the one Step 0 asks. Run this harness on the\n'
    printf 'Debian 12 agent, where patchelf and binutils resolve.\n'
    printf '\n== verdict\n'
    printf '  step        %s\n' "$STEP"
    printf '  cases       %s\n' "$cases"
    printf '  failures    %s\n' "$failures"
    printf '  baseline    NOT RUN (host cannot satisfy)\n'
    printf '\nOBJECTIVE NOT MET for step %s: baseline not captured on this host\n' "$STEP"
    exit 4
fi

# A real dynamically linked ELF with a builder-anchored search path. No compiler
# is needed: a shipped system object is copied and given the anchored value with
# patchelf, which is the same tool the pass itself uses to rewrite it.
BASELINE_PREFIX="$SCRATCH/baseline-prefix"
# A realistic tool layout, because `build_elf_rpath` derives the target search
# path from directories that must EXIST: it walks "$INSTALL_PREFIX/tools/*/" and
# keeps only root/usr/lib64, root/usr/lib, root/lib, root/lib64 and per-version
# lib directories it finds. A prefix holding only tools/bin yields an empty
# search path, and `fix_elf_paths` then skips the rpath write entirely under its
# `[ -n "$new_rpath" ]` guard. The baseline would have run the pass and measured
# a skipped write while reporting a successful run.
mkdir -p -- "$BASELINE_PREFIX/tools/python/root/usr/lib64"
mkdir -p -- "$BASELINE_PREFIX/tools/bin"
# The pass resolves its own patchelf through `find_patchelf`, whose FIRST
# surface is "$INSTALL_PREFIX/tools/bin/patchelf". Planting the resolved binary
# there makes the production resolution run for real on its ordinary surface,
# rather than being bypassed or depending on the harness host having it on PATH.
if ! cp -- "$PATCHELF_BIN" "$BASELINE_PREFIX/tools/bin/patchelf" 2>/dev/null; then
    ln -s -- "$PATCHELF_BIN" "$BASELINE_PREFIX/tools/bin/patchelf" 2>/dev/null
fi
BASELINE_ELF="$BASELINE_PREFIX/tools/bin/anchored"
BASELINE_DONOR=""
for donor in /bin/true /usr/bin/true /bin/echo; do
    [ -f "$donor" ] && { BASELINE_DONOR="$donor"; break; }
done
if [ -z "$BASELINE_DONOR" ]; then
    fail "baseline/fixture" "FIXTURE absent: no donor ELF found"
else
    cp -- "$BASELINE_DONOR" "$BASELINE_ELF"
    chmod u+w -- "$BASELINE_ELF"
    if ! "$PATCHELF_BIN" --set-rpath "/home/builder/prefix/lib" "$BASELINE_ELF" 2>/dev/null; then
        fail "baseline/fixture" "FIXTURE absent: patchelf could not anchor the donor"
    fi
fi
# The fixture is ASSERTED, not assumed: the object must really carry a
# builder-anchored search path before the pass runs, or the baseline would be
# measuring an object the case never created.
planted_value=$("$PATCHELF_BIN" --print-rpath "$BASELINE_ELF" 2>/dev/null)
chk "baseline/fixture-anchored" "/home/builder/prefix/lib" "$planted_value"
planted_tag=$("$READELF_BIN" -d "$BASELINE_ELF" 2>/dev/null | grep -cE '\(RUNPATH\)')
chk "baseline/fixture-tag-before" "1" "$planted_tag"

# The baseline cannot run if the installer could not be sourced, and saying so is
# more useful than letting every case below fail with a bare 127. SOURCE_OK
# carries that verdict down from the seam probe.
if [ "$SOURCE_OK" -ne 1 ]; then
    fail "baseline/prerequisite" "not attempted: the installer could not be sourced"
    cases=$((cases + 1))
fi

# Both probes below source the ISOLATED copy, for the same reason the seam probe
# does: the caller's copy may sit beside a foreign `echos`, and on the CI agent
# it did. Sourcing $INSTALLER here while the seam probe used the isolated copy
# was a half-applied fix, and it left these two cases failing with a bare 127.
# The computed target search path must be NON-EMPTY before the pass runs. This is
# the precondition the fixture layout exists to satisfy, and asserting it is what
# stops the baseline silently measuring a skipped write: with an empty value
# `fix_elf_paths` performs no rpath rewrite at all and still reports a Fixed
# line, which would look like a successful run of a pass that did nothing. The
# production function is called directly, through the seam.
target_rpath=$(
    bash -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1
        INSTALL_PREFIX="$2"
        build_elf_rpath
    ' _ "$ISOLATED_INSTALLER" "$BASELINE_PREFIX"
)
if [ -n "$target_rpath" ]; then
    pass "baseline/target-rpath-computed" "$target_rpath"
else
    fail "baseline/target-rpath-computed" "empty: the pass would skip every write"
fi
cases=$((cases + 1))

# Invoke the PRODUCTION relocation path, reachable because of the seam this step
# adds, and capture what it emits.
baseline_run=$(
    bash -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1
        INSTALL_PREFIX="$2"
        fix_elf_paths "$2" 2>&1
    ' _ "$ISOLATED_INSTALLER" "$BASELINE_PREFIX"
)
baseline_rc=$?
chk "baseline/production-pass-ran" "0" "$baseline_rc"

# The emitted mixed count, read from the RUN's output.
baseline_fixed=$(printf '%s\n' "$baseline_run" \
    | grep -oE 'Fixed [0-9]+ ELF interpreter/rpath value\(s\)' | head -1)
if [ -n "$baseline_fixed" ]; then
    pass "baseline/mixed-count-emitted" "$baseline_fixed"
else
    fail "baseline/mixed-count-emitted" "no Fixed line in the run output"
fi
cases=$((cases + 1))
note "baseline/mixed-count-meaning" "one figure over two axes; replaced at Step 4"
# The rpath VALUE, which is the measurement this baseline exists to take and
# which nothing above it establishes. Round 3 proved a production call returned
# zero and reported one aggregate mutation, then checked only that the donor
# still carried DT_RUNPATH, the tag it was planted with. That leaves the whole
# claim resting on a count: the one reported mutation could have belonged to any
# other walked ELF, and the donor's value could be untouched.
#
# So the value is asserted in both directions. It must EQUAL the computed target,
# and it must NO LONGER equal the planted builder-anchored value. Either alone is
# weaker than it looks: equality alone would pass if the target and the planted
# value ever coincided, and inequality alone would pass on any corruption.
value_after=$("$PATCHELF_BIN" --print-rpath "$BASELINE_ELF" 2>/dev/null)
if [ "$baseline_rc" -eq 0 ] && [ -n "$baseline_fixed" ]; then
    chk "baseline/rpath-value-rewritten" "$target_rpath" "$value_after"
    if [ "$value_after" != "/home/builder/prefix/lib" ]; then
        pass "baseline/rpath-value-no-longer-planted" "left /home/builder/prefix/lib"
    else
        fail "baseline/rpath-value-no-longer-planted" "still the planted value: the pass did not touch this object"
    fi
    cases=$((cases + 1))
else
    fail "baseline/rpath-value-rewritten" \
        "not asserted: the pass did not run (value is $value_after)"
    cases=$((cases + 1))
fi

# The tag the pass actually wrote, inspected INDEPENDENTLY with readelf rather
# than inferred from the installer's arguments.
#
# GATED on the pass having run, and that gate is the point. The fixture is
# planted with DT_RUNPATH, and the current pass is expected to leave DT_RUNPATH,
# so the expected value and the untouched fixture's value are the SAME STRING.
# Reading the tag after a pass that never ran therefore passes, reporting a
# measurement of behaviour that did not happen. That is exactly what the first
# CI run produced: the pass exited 127, nothing was rewritten, and this case
# reported PASS DT_RUNPATH. An assertion whose expected value is indistinguish-
# able from its own precondition has to be gated on the action in between.
after_runpath=$("$READELF_BIN" -d "$BASELINE_ELF" 2>/dev/null | grep -cE '\(RUNPATH\)')
after_rpath=$("$READELF_BIN" -d "$BASELINE_ELF" 2>/dev/null | grep -cE '\(RPATH\)')
if [ "$after_runpath" -ge 1 ] && [ "$after_rpath" -eq 0 ]; then
    observed_tag="DT_RUNPATH"
elif [ "$after_rpath" -ge 1 ] && [ "$after_runpath" -eq 0 ]; then
    observed_tag="DT_RPATH"
else
    observed_tag="ambiguous(rpath=$after_rpath,runpath=$after_runpath)"
fi
if [ "$baseline_rc" -eq 0 ] && [ -n "$baseline_fixed" ]; then
    chk "baseline/tag-written" "DT_RUNPATH" "$observed_tag"
    note "baseline/tag-source" "readelf -d after the pass ran, not installer text"
else
    fail "baseline/tag-written" \
        "not asserted: the pass did not run, so this would read the fixture's own tag ($observed_tag)"
    cases=$((cases + 1))
fi

# The objects the walk really saw, from the run rather than from a find of the
# harness's own planting.
baseline_objects=$(find "$BASELINE_PREFIX" -type f -size +4c | wc -l | tr -d ' ')
note "baseline/objects-walked" "$baseline_objects"
note "baseline/donor" "$BASELINE_DONOR"

installer_lines=$(wc -l < "$INSTALLER" | tr -d ' ')
note "baseline/installer-lines" "$installer_lines"

# ------------------------------------------------------------------- verdict ---
printf '\n== verdict\n'
printf '  step        %s\n' "$STEP"
printf '  cases       %s\n' "$cases"
printf '  failures    %s\n' "$failures"
printf '  installer   %s\n' "$INSTALLER"
printf '  readelf     %s\n' "$READELF_BIN"
printf '  sha256sum   %s\n' "$SHA256SUM_BIN"
printf '  assoc local %s (bash %s)\n' "$ASSOC_LOCAL" "$LOCAL_BASH"
printf '  assoc rhel  %s\n' "$ASSOC_TARGET"

if [ "$failures" -eq 0 ]; then
    printf '\nOBJECTIVE MET for step %s\n' "$STEP"
    exit 0
fi
printf '\nOBJECTIVE NOT MET for step %s: %s failure(s)\n' "$STEP" "$failures"
exit 1
