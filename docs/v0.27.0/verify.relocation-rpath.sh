#!/bin/bash
# shellcheck disable=SC2317  # shellcheck 0.10 name for indirect functions annotated SC2329 below
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
# Exit codes: 0 the step's objective is met, 1 at least one case failed, 2 the
# arguments are unusable, 3 reserved, 4 this host cannot answer the step at all,
# 5 every case passed but an obligation went unanswered and the run says which.
# 5 is not a softer 0: the step is not met, and the difference from 1 is only
# that the gap is in what could be asked rather than in what the code did.
#
# Step 2 adds the ordered classifier's cases. Its controlled tuples need nothing
# but the interpreter, its producer-to-consumer bridge needs the ELF host every
# step from 0 on already needs, and its inventory check needs an extracted
# archive named with --prefix.
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
HOST_TOOL_CONTRACT_ARG=""
INVENTORY_ARG=""
CORPUS_ARG=""

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
        # The allowlist half of the host-tool rule: committed vocabulary data.
        --host-tool-contract) HOST_TOOL_CONTRACT_ARG="$2"; shift 2 ;;
        # The CPLX-ELF/1 contract corpus, committed test data. Namable for the
        # same reason the host-tool contract is: an agent carries it under a
        # verification-only name beside the harness rather than at its own.
        --corpus) CORPUS_ARG="$2"; shift 2 ;;
        # The recorded develop#24 inventory: the Step 2 selected-set oracle.
        --inventory) INVENTORY_ARG="$2"; shift 2 ;;
        -h|--help) sed -n '2,45p' "$0"; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

# Only steps 0, 1, 2 and 3 have case suites today. Accepting any other value would
# let the verdict line report success for a step whose cases do not exist, which
# is a vacuous pass at exactly the level later steps rely on. Extend this
# dispatch and the suite together.
case "$STEP" in
    0|1|2|3) ;;
    *) echo "unsupported --step $STEP: steps 0, 1, 2 and 3 have case suites today." >&2
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

HOST_TOOL_CONTRACT="${HOST_TOOL_CONTRACT_ARG:-$here/contract.host-tools.txt}"
INVENTORY="${INVENTORY_ARG:-$here/inventory.develop-24.txt}"

SCRATCH="${TMPDIR:-/tmp}/cplx-relocation-verify.$$"
failures=0
cases=0
# An obligation this run could not answer, and the exact way to answer it. Kept
# apart from the failure count because "nobody could ask" is not "the code is
# wrong", and folding it into either is how a step gets reported done on the
# strength of the questions it happened to be able to reach.
UNANSWERED=""
UNANSWERED_HOW=""

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

# ------------------------------------------------------------ allowlist rule ---
# The other half of the host-tool contract, and the half that was once a READING
# rather than a rule: the plan asked that "a read of the diff confirms only od,
# head, find and the shipped patchelf". A denylist cannot enforce an allowlist,
# because a tool on neither list is exactly what it fails to see, and that is not
# hypothetical: the first Step 1 observer read bytes with `dd`, ShellCheck was
# clean, `host-tool/no-invocations` passed, and a tool outside the contract
# shipped.
#
# The permitted vocabulary is decided by the plan and split three ways:
#
#   keywords and builtins  the interpreter, not the host. The deployment
#                          contract pins the interpreter, so these add no host
#                          dependency and are permitted without being listed.
#   functions              read FROM the installer, not listed, so a renamed
#                          function cannot silently leave the vocabulary.
#   external commands      the vocabulary proper, committed as plain data in
#                          contract.host-tools.txt and required to match in
#                          BOTH directions.
#
# The launcher table lives in that same file rather than here, so adding a tool
# that runs its argument cannot be done without declaring how it does so.

# A backslash continuation is one command, not two. Done in Bash rather than in
# sed or awk because both need the escape written twice and both got it wrong
# here first: awk's /\\$/ is a regex literal meaning "a dollar sign".
hc_join() {
    local line acc=""
    while IFS= read -r line; do
        case "$line" in
            *\\) acc="$acc${line%\\}" ;;
            *)   printf '%s%s\n' "$acc" "$line"; acc="" ;;
        esac
    done < "$1"
    [ -n "$acc" ] && printf '%s\n' "$acc"
    return 0
}

# The contract carries two kinds of row. Reading them apart, once, keeps every
# consumer from having to know the difference.
hc_contract_entries() {
    awk -F'|' '/^[[:alnum:]]/ && $1 != "launcher" { print }' "$1"
}
hc_contract_launchers() {
    awk -F'|' '$1 == "launcher" { print }' "$1"
}

# Every word in command position. Comments are not code and arithmetic is not a
# command context, so both are neutralised first. A command substitution IS a
# command context even inside a double-quoted string, so it is hoisted onto its
# own line BEFORE quoted text is blanked: blanking first hid `$(readlink ...)`
# and would have hidden any future dependency written the same way.
#
# `)` is NOT an opener. Three attempts to make it one all failed: bare, it read
# `$(basename x)suffix` as a command `suffix`; blank-delimited, it hid `a)cmd`,
# which is valid Bash; deleting the first close on a hoisted line fixed both at
# one level of nesting and broke at two.
#
# Counting closes was the wrong instinct, because the ambiguity is not about
# depth. `)` has two meanings and only one is a command position: the end of a
# `case` PATTERN. That meaning is recognised directly and rewritten to `;`,
# leaving `)` with no opener role, so a close of any construct at any depth opens
# nothing by construction.
#
# The pattern class admits `$`, escaped parens and extglob groups, because a
# `case` pattern is not required to be a literal word: `$pat)`, `\))` and
# `@(a|b))` are all valid arms, and each hid the command behind it. Escaped
# parens and extglob groups are substituted out first so they cannot be read as
# real parentheses. `(` and `)` themselves stay excluded, which is what keeps
# `$(basename x)suffix` from matching.
#
# Block terminators are excluded before that, since `esac)`, `fi)`, `done)` and
# `})` end a construct inside a substitution rather than a pattern.
#
# Keywords that INTRODUCE a command are transparent. `grep -o` yields
# non-overlapping matches, so an opener followed by a keyword consumed the
# keyword as its command word and left the real command with no opener of its
# own: `if true; then cmd; fi` reported `if then fi` and never `cmd`.
#
# A leading redirection is skipped, attached or spaced: `>/dev/null cmd` and
# `> /dev/null cmd` are both a command with a redirection in front of it.
#
# `{` opens a group only when a blank follows. That one IS exact rather than
# narrowing: `{` is a reserved word, a reserved word must be delimited, and
# `{ls; }` is a Bash syntax error rather than a call to `ls`.
#
# `(` opens a subshell, but `=(` opens an ARRAY. `arr=(one two three)` is three
# words, not a command called `one`, so the array form is neutralised first.
hc_command_words() {
    # shellcheck disable=SC2016  # the sed patterns are literal `$((` and `$(`
    hc_join "$1" \
    | sed -e 's/#.*$//' -e 's/((.*))/_ARITH_/g' -e 's/\$((/_ARITH_/g' -e 's/=([^)]*)/=_ARR_/g' \
    | sed -e 's/\$(/\n$(/g' -e 's/`/\n`/g' \
    | sed -e "s/'[^']*'/_STR_/g" -e 's/"[^"]*"/_STR_/g' \
    | sed -E -e 's/\\[()]/_ESCP_/g' \
             -e 's/[@!?+*]\([^()]*\)/_EXTG_/g' \
             -e 's/(esac|fi|done|\})[[:space:]]*\)/\1 /g' \
             -e 's/(^|[;&]|[[:space:]]in[[:space:]])([[:space:]]*[^();&]*)\)/\1\2;/g' \
    | grep -oE "(^|[;&|(!]|&&|\|\||\\\$\(|\`|\{[[:space:]]|[[:space:]](then|else|do|elif)[[:space:]])[[:space:]]*(![[:space:]]*)?((if|then|else|elif|do|while|until|time|coproc)[[:space:]]+)*([0-9]*[<>]+[[:space:]]*[^[:space:];|]*[[:space:]]+)*([[:alnum:]_]+=[^[:space:];|&]*[[:space:]]+)*[[:alnum:]_./-]+[[:space:]=[+]?" \
    | sed -e 's/[[:space:]]*$//' \
    | grep -vE '[=[+]$' \
    | grep -oE '[[:alnum:]_./-]+$'
}

# The launcher option semantics, written ONCE and shared by the two functions
# that need them. They were duplicated before, which is how two copies of a rule
# drift apart while both look right in isolation.
#
# An operand can be REQUIRED or OPTIONAL, and the difference decides whether the
# NEXT word belongs to the option or is the command. GNU `xargs -E eof-str`
# requires its operand and takes the next word; `xargs --eof[=eof-str]` and
# `xargs -e[eof-str]` accept an OPTIONAL one that must be attached, so
# `xargs --eof cmd` runs `cmd` and an earlier version of this table swallowed it.
# Optionality is spelled with a `?` suffix in the contract, on a short letter or
# a long name.
# shellcheck disable=SC2016  # this is an awk program, not a shell expansion
HC_LAUNCHER_AWK='
    function hc_load(table,    n, rows, r, f, spec, i, c) {
        n = split(table, rows, "\n")
        for (r = 1; r <= n; r++) {
            if (rows[r] == "") continue
            split(rows[r], f, "\t")
            islauncher[f[1]] = 1
            spec = f[2]
            for (i = 1; i <= length(spec); i++) {
                c = substr(spec, i, 1)
                if (substr(spec, i + 1, 1) == "?") { shortopt[f[1], c] = "optional"; i++ }
                else                                 shortopt[f[1], c] = "required"
            }
            n2 = split(f[3], longs, ",")
            for (i = 1; i <= n2; i++) {
                if (longs[i] == "") continue
                if (longs[i] ~ /\?$/) longopt[f[1], substr(longs[i], 1, length(longs[i]) - 1)] = "optional"
                else                  longopt[f[1], longs[i]] = "required"
            }
        }
    }
    function hc_operand_is_next(launcher, word,    i, c, name) {
        if (word ~ /^--/) {
            name = substr(word, 3)
            if (name ~ /=/) return 0
            return (longopt[launcher, name] == "required")
        }
        for (i = 2; i <= length(word); i++) {
            c = substr(word, i, 1)
            if (shortopt[launcher, c] == "optional") return 0
            if (shortopt[launcher, c] == "required") {
                if (i < length(word)) return 0
                return 1
            }
        }
        return 0
    }
    function hc_target(launcher, i,    j) {
        for (j = i + 1; j <= NF; j++) {
            if ($j ~ /^-/) {
                if (hc_operand_is_next(launcher, $j)) j++
                continue
            }
            return j
        }
        return 0
    }
'

hc_launcher_table() {
    hc_contract_launchers "$1" | awk -F'|' '{printf "%s\t%s\t%s\n", $2, $4, $5}'
}

# Commands the shell never sees in command position, because another command
# launches them. `find -exec NAME` runs NAME; so do `command NAME`, `exec NAME`
# and `xargs NAME`. Omitting `-exec` once hid `rm`, which the installer reaches
# no other way, and the same argument applies to the rest: a host dependency
# introduced through a permitted launcher is still a host dependency, and the
# launcher's own presence in the vocabulary says nothing about what it runs.
#
# Short options CLUSTER, so the letters are walked rather than the word measured:
# an earlier version treated any word longer than two characters as carrying its
# own operand, and `xargs -rP 4 cmd` selected `4`.
hc_launcher_words() {
    hc_join "$1" \
    | sed -e 's/#.*$//' \
    | sed -e "s/'[^']*'/_STR_/g" -e 's/"[^"]*"/_STR_/g' \
    | awk -v table="$(hc_launcher_table "$2")" "$HC_LAUNCHER_AWK"'
        BEGIN { hc_load(table) }
        {
            for (i = 1; i <= NF; i++) {
                if (!($i in islauncher)) continue
                t = hc_target($i, i)
                if (t == 0) continue
                if ($t !~ /^[A-Za-z0-9_.\/-]+$/) continue
                print $t
            }
        }'
}

# The fail-closed boundary. Everything above is lexical, so a command the shell
# only assembles at run time cannot be read. Those forms are REFUSED rather than
# guessed at, because stating them in prose let a later step add one while the
# gate kept reporting zero.
#
#   `eval`, in any command position, found through the command-word extraction
#   so `if eval "$p"` and `VAR=1 eval "$p"` are covered by the positions that
#   machinery already understands.
#
#   `eval` reached through a DISPATCHER. `command eval "$p"` and
#   `builtin eval "$p"` both run eval, and neither puts `eval` in a position the
#   command-word extraction sees. `builtin` is not a host-tool launcher and
#   never will be, since it can only reach builtins, but it can reach THIS one,
#   so the boundary knows about it even though the vocabulary does not.
#
#   A declared launcher whose operand is computed, found by walking the same
#   option semantics the launcher extraction uses, so `command -v "$x"` and
#   `xargs -rP 4 "$x"` are covered rather than only the bare form.
#
# Strings are NOT blanked here: a single-quoted literal target is not computed,
# and blanking would make it indistinguishable from one that is.
hc_unsupported_forms() {
    local file="$1" contract="$2"
    hc_command_words "$file" | grep -qxF 'eval' \
        && printf 'eval in command position\n'
    hc_join "$file" | sed -e 's/#.*$//' \
    | awk -v table="$(hc_launcher_table "$contract")" "$HC_LAUNCHER_AWK"'
        BEGIN {
            hc_load(table)
            # Dispatchers that can reach the `eval` BUILTIN. These are not
            # host-tool launchers and are not read from the contract, because
            # the contract describes HOST tools and these reach an interpreter
            # facility instead.
            #
            # `exec` is NOT among them, and an earlier version of this list said
            # it was. `exec eval "$p"` does not run eval: exec replaces the shell
            # with an EXTERNAL program of that name, there is none, and the shell
            # exits 127. That was measured, not reasoned about, after the claim
            # had already shipped once as prose.
            dispatch["command"] = 1
            dispatch["builtin"] = 1
        }
        # A dispatcher takes flags before its command word, and `--` ends them.
        # `builtin -- eval "$p"` runs eval, and taking the word straight after
        # the dispatcher found `--` and stopped. Neither dispatcher has an
        # option that takes an operand, so skipping every `-`-prefixed word is
        # exact here rather than approximate.
        function hc_dispatch_target(i,    j) {
            for (j = i + 1; j <= NF; j++) {
                if ($j ~ /^-/) continue
                return j
            }
            return 0
        }
        {
            for (i = 1; i <= NF; i++) {
                if ($i in dispatch) {
                    t = hc_dispatch_target(i)
                    if (t > 0 && $t == "eval") {
                        print "eval reached through " $i
                        continue
                    }
                }
                if (!($i in islauncher)) continue
                t = hc_target($i, i)
                if (t == 0) continue
                if ($t ~ /[$`]/) print "computed launcher target: " $i " " $t
            }
        }'
    return 0
}
# The contract's own consistency rules, each as a FUNCTION rather than as an
# expression written inline at its one call site. That shape is what lets the
# controls below exercise the real rule against a mutated contract instead of a
# second copy of it: the previous round claimed such controls and they did not
# exist, which is a claim outrunning the code in the document that keeps naming
# that failure.
hc_dup_entries() {
    hc_contract_entries "$1" | cut -d'|' -f1 | sort | uniq -d
}
hc_dup_launchers() {
    hc_contract_launchers "$1" | cut -d'|' -f2 | sort | uniq -d
}
hc_unanswered_entries() {
    hc_contract_entries "$1" | awk -F'|' '$4 != "yes" && $4 != "no" { print $1 }'
}
# A launcher whose owner is permitted by nothing is a rule following a tool the
# installer is not allowed to use.
hc_unowned_launchers() {
    local contract="$1" _l tok own _s _lg
    while IFS='|' read -r _l tok own _s _lg; do
        [ -n "$tok" ] || continue
        hc_contract_entries "$contract" | cut -d'|' -f1 | grep -qxF "$own" && continue
        # shellcheck disable=SC2086  # the split into words is the point here
        printf '%s\n' $HC_BUILTINS | grep -qxF "$own" && continue
        printf '%s\n' "$tok"
    done < <(hc_contract_launchers "$contract")
}
# An entry that SAYS it runs an argument must own at least one launcher row.
# This is the direction that used to rest on a curated list.
hc_undeclared_runners() {
    local contract="$1" name _f _r runs _w
    while IFS='|' read -r name _f _r runs _w; do
        [ -n "$name" ] || continue
        [ "$runs" = "yes" ] || continue
        hc_contract_launchers "$contract" | cut -d'|' -f3 | grep -qxF "$name" \
            || printf '%s\n' "$name"
    done < <(hc_contract_entries "$contract")
}

hc_file_functions() {
    hc_join "$1" | grep -oE '^[[:space:]]*[[:alnum:]_]+[[:space:]]*\(\)' | grep -oE '[[:alnum:]_]+'
}

HC_KEYWORDS='if then else elif fi for while until do done case esac in function select time coproc'
# Builtins add no host dependency: they are the interpreter, whose version the
# deployment contract already pins. The list is bash's own.
HC_BUILTINS='. : [ alias bg bind break builtin caller cd command compgen complete compopt continue declare dirs disown echo enable eval exec exit export false fc fg getopts hash help history jobs kill let local logout mapfile popd printf pushd pwd read readarray readonly return set shift shopt source suspend test times trap true type typeset ulimit umask unalias unset wait'

# Words the installer uses that the contract does not name. This is the check
# the denylist could not be.
hc_unlisted() {
    local file="$1" contract="$2" w base name
    declare -A known=()
    for w in $HC_KEYWORDS $HC_BUILTINS; do known["$w"]=1; done
    while IFS= read -r w; do [ -n "$w" ] && known["$w"]=1; done < <(hc_file_functions "$file")
    while IFS='|' read -r name _f _r _y; do
        [ -n "$name" ] && known["$name"]=1
    done < <(hc_contract_entries "$contract")
    { hc_command_words "$file"; hc_launcher_words "$file" "$contract"; } | sort -u | while IFS= read -r w; do
        [ -n "$w" ] || continue
        case "$w" in _STR_*|_ARITH_*|_ARR_*|_ESCP_*|_EXTG_*|-*|[0-9]*) continue ;; esac
        base="${w##*/}"
        [ -n "${known[$w]:-}" ] && continue
        [ -n "${known[$base]:-}" ] && continue
        printf '%s\n' "$w"
    done
}

# Entries the contract names that the installer does not use. Without this the
# file could accumulate permissions nobody needs, and a future dependency would
# find itself already allowed.
hc_unused() {
    local file="$1" contract="$2" name form used
    used=$({ hc_command_words "$file"; hc_launcher_words "$file" "$contract"; } | sed -e 's#.*/##' | sort -u)
    while IFS='|' read -r name form _r _y; do
        [ -n "$name" ] || continue
        # An indirect entry is invoked through a variable and cannot appear in
        # command position by construction. Its resolver is asserted instead.
        [ "$form" = "indirect" ] && continue
        printf '%s\n' "$used" | grep -qxF "$name" || printf '%s\n' "$name"
    done < <(hc_contract_entries "$contract")
}

# The allowlist corpus is affordable on Linux and nowhere else, so the host is
# checked the same way patchelf and readelf are checked: by platform, before the
# work rather than after it.
#
# It is not the gate that is slow, it is fork(). Each of the eighty-three shapes
# writes a probe and runs `hc_unlisted | sed | grep`, and hc_unlisted itself
# spends a dozen more subprocesses on the file; call it fifteen hundred spawns
# for the corpus. Linux answers all of it in 4.5 seconds, measured on the Debian
# agent at step 2 of build 92. Cygwin emulates fork() in user space and answers
# in over five minutes, which is to say it does not answer: the run was killed at
# its bound having never reached the step's own cases. That is a 70x gap in the
# platform, not a slow machine.
#
# A host that cannot afford it says so through the third outcome rather than
# skipping quietly or timing out. UNANSWERED and exit 5 exist for exactly this,
# and the inventory check was their only user until now: "nobody could ask this
# here" is neither a pass nor a code failure. Reporting it as unanswered is what
# stops a fast local run from reading as a clean one.
#
# Coverage is unchanged where it counts. CI is Linux, so the corpus runs there on
# every step of every build, which is where the gate has to hold.
HOST_TOOL_AFFORDABLE=1
case "$(uname -s 2>/dev/null)" in
    Linux) ;;
    *) HOST_TOOL_AFFORDABLE=0 ;;
esac

# A missing contract and an unaffordable host are different answers and must stay
# different: the first is a defect, the second is a question this platform cannot
# ask. Collapsing them into one condition made an absent-file FAIL fire on a host
# whose contract was present and readable, which is the opposite of what the
# third outcome is for.
if [ -f "$HOST_TOOL_CONTRACT" ] && [ "$HOST_TOOL_AFFORDABLE" -ne 1 ]; then
    note "host-tool/contract" "$HOST_TOOL_CONTRACT"
    printf '  %-40s SKIP  %s\n' "host-tool/corpus" \
        "needs a Linux host (this is $(uname -s 2>/dev/null)); fork cost makes it unanswerable here"
    UNANSWERED="${UNANSWERED:+$UNANSWERED, }the host-tool allowlist corpus"
    UNANSWERED_HOW="$UNANSWERED_HOW
  the allowlist corpus proves the host-tool rule can report and can stay silent,
  over eighty-three planted shapes. It costs about 4.5 seconds on Linux and does
  not complete on this platform, where fork is emulated. Run
  bash docs/v0.27.0/verify.relocation-rpath.sh --step $STEP on the Linux
  validation host to answer it."
elif [ -f "$HOST_TOOL_CONTRACT" ]; then
    note "host-tool/contract" "$HOST_TOOL_CONTRACT"

    # The contract is data the rule depends on, so it is validated before it is
    # trusted: a row short of a column is a row whose meaning cannot be read.
    hc_rows=$(hc_contract_entries "$HOST_TOOL_CONTRACT" | wc -l | tr -d ' ')
    chk "host-tool/contract-nonempty" "yes" "$([ "$hc_rows" -gt 0 ] && echo yes || echo no)"
    hc_badcols=$(awk -F'|' '/^[[:alnum:]]/ && NF != 5' "$HOST_TOOL_CONTRACT" | wc -l | tr -d ' ')
    chk "host-tool/contract-columns" "0" "$hc_badcols"
    hc_badform=$(hc_contract_entries "$HOST_TOOL_CONTRACT" \
        | awk -F'|' '$2 != "direct" && $2 != "indirect"' | wc -l | tr -d ' ')
    chk "host-tool/contract-form-values" "0" "$hc_badform"
    # Every entry must ANSWER whether it runs one of its arguments. There is no
    # default, because a default is how a tool gets permitted without anyone
    # deciding whether the rule has to follow it.
    hc_badruns=$(hc_unanswered_entries "$HOST_TOOL_CONTRACT" | grep -c . || true)
    chk "host-tool/contract-runs-argument-answered" "0" "$hc_badruns"

    # No name may appear twice. A duplicated entry can answer `runs-argument`
    # both ways, and every consumer reads whichever row it reaches first, so the
    # contract would be self-contradicting while each individual check passed.
    hc_dupe_n=$(hc_dup_entries "$HOST_TOOL_CONTRACT" | grep -c . || true)
    chk "host-tool/contract-entries-unique" "0" "$hc_dupe_n"
    hc_dupl_n=$(hc_dup_launchers "$HOST_TOOL_CONTRACT" | grep -c . || true)
    chk "host-tool/launcher-tokens-unique" "0" "$hc_dupl_n"

    # The loophole this closes: `indirect` exempts an entry from the unused
    # check, so without this an entry could be marked indirect to silence the
    # check. Naming a resolver that must really be defined makes that cost more
    # than telling the truth.
    hc_badres=0
    while IFS='|' read -r hcn hcf hcr _hcy; do
        [ -n "$hcn" ] || continue
        if [ "$hcf" = "indirect" ]; then
            hc_file_functions "$INSTALLER" | grep -qxF "$hcr" || hc_badres=$((hc_badres + 1))
        elif [ "$hcr" != "-" ]; then
            hc_badres=$((hc_badres + 1))
        fi
    done < <(hc_contract_entries "$HOST_TOOL_CONTRACT")
    chk "host-tool/contract-indirect-resolver" "0" "$hc_badres"

    # The launcher table, and its coupling to the vocabulary, in both
    # directions. The reverse direction used to run off a curated list of
    # commands "known to run their argument", which made the coupling only as
    # complete as my recall: a tool outside that list could be permitted and left
    # unfollowed, and the control only ever proved one remembered entry.
    #
    # There is no list now. Every ENTRY answers the question itself, in its own
    # `runs-argument` column, with no default. So the reverse coupling is total
    # over the contract rather than over what someone remembered: a tool cannot
    # be permitted without deciding whether the rule has to follow it, and the
    # decision is reviewed where the tool is.
    hc_launchers=$(hc_contract_launchers "$HOST_TOOL_CONTRACT" | wc -l | tr -d ' ')
    chk "host-tool/launcher-table-nonempty" "yes" \
        "$([ "$hc_launchers" -gt 0 ] && echo yes || echo no)"

    # Forward: every launcher's OWNER must itself be permitted, as an entry or
    # as a shell builtin.
    hc_badlaunch_names=$(hc_unowned_launchers "$HOST_TOOL_CONTRACT")
    hc_badlaunch=$(printf '%s' "$hc_badlaunch_names" | grep -c . || true)
    [ -n "$hc_badlaunch_names" ] && note "host-tool/unowned-launchers" \
        "$(printf '%s' "$hc_badlaunch_names" | tr '\n' ' ')"
    chk "host-tool/launcher-is-permitted" "0" "$hc_badlaunch"

    # Reverse: every entry that SAYS it runs an argument must own at least one
    # launcher row. This is the direction that used to rest on a curated list.
    hc_undeclared_names=$(hc_undeclared_runners "$HOST_TOOL_CONTRACT")
    hc_undeclared=$(printf '%s' "$hc_undeclared_names" | grep -c . || true)
    [ -n "$hc_undeclared_names" ] && note "host-tool/undeclared-launchers" \
        "$(printf '%s' "$hc_undeclared_names" | tr '\n' ' ')"
    chk "host-tool/runs-argument-entries-declared" "0" "$hc_undeclared"

    # The controls. Each mutates a copy of the REAL contract and runs the REAL
    # rule over it, so a rule that has stopped detecting anything fails here
    # rather than passing on a clean file. The previous round asserted that
    # these existed; they did not, and "the check reports zero" is not evidence
    # that the check can report anything else.
    hc_mut="$SCRATCH/contract-mutations"
    mkdir -p -- "$hc_mut"
    awk -F'|' '/^sed\|/{print "sed|direct|-|yes|a contradicting duplicate"} {print}' \
        "$HOST_TOOL_CONTRACT" > "$hc_mut/dup-entry.txt"
    awk -F'|' '/^launcher\|xargs\|/{print "launcher|xargs|xargs|a|"} {print}' \
        "$HOST_TOOL_CONTRACT" > "$hc_mut/dup-launcher.txt"
    awk -F'|' '/^tr\|/{print "zzquiet|direct|-|maybe|an entry that answers neither"} {print}' \
        "$HOST_TOOL_CONTRACT" > "$hc_mut/unanswered.txt"
    awk -F'|' '/^xargs\|/{print "zzrunner|direct|-|yes|says yes, owns no launcher row"} {print}' \
        "$HOST_TOOL_CONTRACT" > "$hc_mut/undeclared.txt"
    awk -F'|' '/^launcher\|xargs\|/{print "launcher|zztok|zzowner||"} {print}' \
        "$HOST_TOOL_CONTRACT" > "$hc_mut/unowned.txt"

    hc_control() {
        local name="$1" fn="$2" file="$3" want="$4" got
        got=$("$fn" "$file" | grep -c . || true)
        if [ "$got" -ge 1 ] && [ "$got" -eq "$want" ]; then
            pass "host-tool/control-$name" "the rule reports $got on the mutated contract"
        else
            fail "host-tool/control-$name" "want $want, got $got"
        fi
        cases=$((cases + 1))
    }
    hc_control "duplicate-entry"     hc_dup_entries        "$hc_mut/dup-entry.txt"    1
    hc_control "duplicate-launcher"  hc_dup_launchers      "$hc_mut/dup-launcher.txt" 1
    hc_control "unanswered-entry"    hc_unanswered_entries "$hc_mut/unanswered.txt"   1
    hc_control "undeclared-runner"   hc_undeclared_runners "$hc_mut/undeclared.txt"   1
    hc_control "unowned-launcher"    hc_unowned_launchers  "$hc_mut/unowned.txt"      1

    # And each rule must report NOTHING on the real contract, which is the other
    # half of the same claim: a rule that always reports something is no more
    # useful than one that never does.
    hc_control_clean() {
        local name="$1" fn="$2" got
        got=$("$fn" "$HOST_TOOL_CONTRACT" | grep -c . || true)
        if [ "$got" -eq 0 ]; then
            pass "host-tool/control-clean-$name" "silent on the real contract"
        else
            fail "host-tool/control-clean-$name" "reported $got on the real contract"
        fi
        cases=$((cases + 1))
    }
    hc_control_clean "duplicate-entry"    hc_dup_entries
    hc_control_clean "duplicate-launcher" hc_dup_launchers
    hc_control_clean "unanswered-entry"   hc_unanswered_entries
    hc_control_clean "undeclared-runner"  hc_undeclared_runners
    hc_control_clean "unowned-launcher"   hc_unowned_launchers

    # The fail-closed boundary, consumed rather than described. A form the rule
    # cannot read must stop the gate, not pass through it.
    hc_unsupported=$(hc_unsupported_forms "$INSTALLER" "$HOST_TOOL_CONTRACT" | grep -c . || true)
    if [ "$hc_unsupported" -ne 0 ]; then
        note "host-tool/unsupported-lines" "$(hc_unsupported_forms "$INSTALLER" "$HOST_TOOL_CONTRACT" | tr '\n' ' ')"
    fi
    chk "host-tool/no-unsupported-forms" "0" "$hc_unsupported"

    hc_unlisted_out=$(hc_unlisted "$INSTALLER" "$HOST_TOOL_CONTRACT")
    hc_unlisted_n=$(printf '%s' "$hc_unlisted_out" | grep -c . || true)
    if [ "$hc_unlisted_n" -ne 0 ]; then
        note "host-tool/unlisted-words" "$(printf '%s' "$hc_unlisted_out" | tr '\n' ' ')"
    fi
    chk "host-tool/allowlist-unlisted" "0" "$hc_unlisted_n"

    hc_unused_out=$(hc_unused "$INSTALLER" "$HOST_TOOL_CONTRACT")
    hc_unused_n=$(printf '%s' "$hc_unused_out" | grep -c . || true)
    if [ "$hc_unused_n" -ne 0 ]; then
        note "host-tool/unused-entries" "$(printf '%s' "$hc_unused_out" | tr '\n' ' ')"
    fi
    chk "host-tool/contract-unused" "0" "$hc_unused_n"

    # Negative cases. A rule reporting zero over one file proves nothing about
    # what it would catch, so it is shown to REJECT every shape a new dependency
    # can take.
    #
    # Each case requires the EXACT planted token. Accepting "some unlisted word"
    # let the extractor and the oracle be wrong together: `xargs -P 4 zzunlisted`
    # returned `4`, which is unlisted, so the case passed while the rule was
    # reading the option's operand instead of the command.
    hc_probe="$SCRATCH/allowlist-probe.sh"
    hc_rejects="$SCRATCH/allowlist-reject.txt"
    cat > "$hc_rejects" <<'HCREJECT'
zzunlisted -x
if ! zzunlisted -x; then :; fi
foo | zzunlisted -x
/usr/bin/zzunlisted -x
value="$(zzunlisted -x)"
find . -exec zzunlisted {} +
find . -execdir zzunlisted {} +
if true; then zzunlisted -x; fi
while :; do zzunlisted -x; done
if true; then :; else zzunlisted -x; fi
if zzunlisted -q; then :; fi
until zzunlisted; do :; done
coproc zzunlisted -x
case "$x" in $pat) zzunlisted -x ;; esac
case "$x" in a) zzunlisted -x ;; esac
case "$x" in a)zzunlisted -x ;; esac
{ zzunlisted -x; }
VAR=1 zzunlisted -x
VAR=1 OTHER=2 zzunlisted -x
>/dev/null zzunlisted -x
> /dev/null zzunlisted -x
foo &>/dev/null zzunlisted
command zzunlisted -x
command -v zzunlisted
exec zzunlisted -x
exec -a myname zzunlisted -x
echo a | xargs zzunlisted
echo a | xargs -0 -r zzunlisted -i
echo a | xargs -P 4 zzunlisted
echo a | xargs -I {} zzunlisted {}
echo a | xargs -n1 zzunlisted
echo a | xargs --max-procs 4 zzunlisted
echo a | xargs -rP 4 zzunlisted
exec -ca name zzunlisted
echo a | xargs -0rn1 zzunlisted
echo a | xargs --eof zzunlisted
echo a | xargs -e zzunlisted
echo a | xargs -E eofstr zzunlisted
echo a | xargs --replace zzunlisted
echo a | xargs --max-args 3 zzunlisted
HCREJECT
    while IFS= read -r hcshape; do
        [ -n "$hcshape" ] || continue
        { printf '#!/bin/bash\n'; printf '%s\n' "$hcshape"; } > "$hc_probe"
        if hc_unlisted "$hc_probe" "$HOST_TOOL_CONTRACT" | sed -e 's#.*/##' | grep -qxF 'zzunlisted'; then
            pass "host-tool/allowlist-rejects" "$hcshape"
        else
            fail "host-tool/allowlist-rejects" \
                "did not name zzunlisted [$(hc_unlisted "$hc_probe" "$HOST_TOOL_CONTRACT" | tr '\n' ' ')] in: $hcshape"
        fi
        cases=$((cases + 1))
    done < "$hc_rejects"

    # The escaped and extglob arms are kept out of the loop because the loop
    # writes one line per probe and these need `extglob` enabled at PARSE time,
    # which is a property of the file rather than of the line.
    hc_eprobe="$SCRATCH/allowlist-extglob.sh"
    hc_eshapes="$SCRATCH/allowlist-extglob.txt"
    cat > "$hc_eshapes" <<'HCEXT'
case "$x" in \)) zzunlisted -x ;; esac
case "$x" in @(a|b)) zzunlisted -x ;; esac
case "$x" in +(y)) zzunlisted -x ;; esac
case "$x" in !(z)) zzunlisted -x ;; esac
HCEXT
    while IFS= read -r hcshape; do
        [ -n "$hcshape" ] || continue
        { printf '#!/bin/bash\n'; printf 'shopt -s extglob\n'; printf '%s\n' "$hcshape"; } > "$hc_eprobe"
        if bash -O extglob -n "$hc_eprobe" 2>/dev/null; then
            if hc_unlisted "$hc_eprobe" "$HOST_TOOL_CONTRACT" | sed -e 's#.*/##' | grep -qxF 'zzunlisted'; then
                pass "host-tool/allowlist-rejects-extglob" "$hcshape"
            else
                fail "host-tool/allowlist-rejects-extglob" "did not name zzunlisted in: $hcshape"
            fi
        else
            fail "host-tool/allowlist-rejects-extglob" "FIXTURE does not parse: $hcshape"
        fi
        cases=$((cases + 1))
    done < "$hc_eshapes"

    # And it must NOT reject what the vocabulary permits. This side is checked
    # one shape per case, not as one pass over a file of shapes, because the
    # aggregate form is how a false positive hid: a single verdict over eight
    # shapes says only that something was wrong, and the shape that mattered,
    # `${value}`, was not among them at all.
    hc_allows="$SCRATCH/allowlist-allow.txt"
    cat > "$hc_allows" <<'HCALLOW'
sed -e 's/a/b/' file
local x="$INSTALL_PREFIX/tools/python/root/lib64/ld-linux-x86-64.so.2"
myfun() { :; }; myfun arg
printf '%s' "$x"
case "$engine" in rsync) rsync -av a b ;; esac
{ printf '%s' "$x"; }
LC_ALL=C sort file
plain_assignment=value
plain_assignment=${value}
prefixed=${HOME}/tools
concatenated=$(basename x)suffix
dotted=$(dirname y).bak
arr=(one two three)
arr+=(four five)
quoted="${k}literal"
defaulted=${g:-defaultword}
stripped=${i#prefixword}
nested=$(basename $(dirname x))suffix
deeper=$(basename $(dirname $(readlink y)))tail
casein=$(case $x in p)head -c 4 q ;; esac)more
ifin=$(if true; then od -c a; fi)tailone
whilein=$(while :; do tr a b; done)tailtwo
groupin=$( { sort z; } )tailthree
lookup=$(command -v rsync)
piped=$(echo a | xargs -0 -r sed -i -e s/a/b/)
replaced=$(echo a | xargs -I {} sed -i -e s/a/b/ {})
parallel=$(echo a | xargs -P 4 sed -i -e s/a/b/)
named=$(exec -a alias sed -e s/a/b/ f)
clustered=$(echo a | xargs -rP 4 sed -i -e s/a/b/)
execclust=$(exec -ca alias sed -e s/a/b/ f)
builtin cd /tmp
HCALLOW
    while IFS= read -r hcshape; do
        [ -n "$hcshape" ] || continue
        { printf '#!/bin/bash\n'; printf '%s\n' "$hcshape"; } > "$hc_probe"
        hc_allow_out=$(hc_unlisted "$hc_probe" "$HOST_TOOL_CONTRACT")
        if [ -z "$hc_allow_out" ]; then
            pass "host-tool/allowlist-allows" "$hcshape"
        else
            fail "host-tool/allowlist-allows" \
                "wrongly named [$(printf '%s' "$hc_allow_out" | tr '\n' ' ')] in: $hcshape"
        fi
        cases=$((cases + 1))
    done < "$hc_allows"

    # The shape this rule was once blind to, kept as its own witness because it
    # was briefly documented as an accepted hole. `a)cmd` is valid Bash and calls
    # `cmd`, so a rule that cannot see it is fail-open, and asserting the
    # invisibility as a PASS made the gap look like a decision.
    # shellcheck disable=SC2016  # the probe text is shell source, not an expansion
    { printf '#!/bin/bash\n'; printf 'case "$x" in a)zzunlisted -x ;; esac\n'; } > "$hc_probe"
    if hc_unlisted "$hc_probe" "$HOST_TOOL_CONTRACT" | sed -e 's#.*/##' | grep -qxF 'zzunlisted'; then
        pass "host-tool/unspaced-case-arm-is-seen" "a)cmd names the unlisted command"
    else
        fail "host-tool/unspaced-case-arm-is-seen" "FAIL-OPEN: a)cmd hides an unlisted external"
    fi
    cases=$((cases + 1))

    # And the false positive that removing the blank requirement could have
    # reintroduced. These two move in opposite directions, so they are asserted
    # together: seeing `a)cmd` must not cost seeing `suffix`.
    # shellcheck disable=SC2016  # the probe text is shell source, not an expansion
    { printf '#!/bin/bash\n'; printf 'concatenated=$(basename x)suffix\n'; } > "$hc_probe"
    if [ -z "$(hc_unlisted "$hc_probe" "$HOST_TOOL_CONTRACT")" ]; then
        pass "host-tool/substitution-close-is-not-an-opener" "\$(basename x)suffix is one word"
    else
        fail "host-tool/substitution-close-is-not-an-opener" \
            "wrongly named [$(hc_unlisted "$hc_probe" "$HOST_TOOL_CONTRACT" | tr '\n' ' ')]"
    fi
    cases=$((cases + 1))

    # The boundary must fire, not merely exist, and it must fire on the
    # COMPOSED forms rather than only the bare ones. An earlier version matched
    # `eval` and a computed target only at the start of a command, so
    # `if eval "$p"` and `command -v "$x"` walked past it while the gate
    # reported zero. `eval` is now found through the command-word extraction, so
    # every keyword and prefix position it already understands applies; the
    # computed target is found by walking the same declared option semantics the
    # launcher extraction uses, so an optioned launcher is covered too.
    hc_bshapes="$SCRATCH/boundary-shapes.txt"
    cat > "$hc_bshapes" <<'HCBOUND'
eval "zzunlisted -x"
if eval "$payload"; then :; fi
VAR=1 eval "$payload"
command "$launcher_target" -x
command -v "$launcher_target"
xargs -0 "$launcher_target"
echo a | xargs -rP 4 "$launcher_target"
exec -a alias "$launcher_target"
command eval "$payload"
builtin eval "$payload"
builtin -- eval "$payload"
command -- eval "$payload"
command -p eval "$payload"
HCBOUND
    while IFS= read -r hcshape; do
        [ -n "$hcshape" ] || continue
        { printf '#!/bin/bash\n'; printf '%s\n' "$hcshape"; } > "$hc_probe"
        if [ "$(hc_unsupported_forms "$hc_probe" "$HOST_TOOL_CONTRACT" | grep -c .)" -ge 1 ]; then
            pass "host-tool/boundary-fires" "$hcshape"
        else
            fail "host-tool/boundary-fires" "passed the boundary silently: $hcshape"
        fi
        cases=$((cases + 1))
    done < "$hc_bshapes"

    # And it must NOT fire on a literal target, or the boundary would refuse
    # every file that uses a launcher at all.
    { printf '#!/bin/bash\n'; printf 'echo a | xargs -0 -r sed -i -e s/a/b/\n'; } > "$hc_probe"
    if [ "$(hc_unsupported_forms "$hc_probe" "$HOST_TOOL_CONTRACT" | grep -c .)" -eq 0 ]; then
        pass "host-tool/boundary-allows-literal-target" "a literal launcher target is readable"
    else
        fail "host-tool/boundary-allows-literal-target" "wrongly refused a literal target"
    fi
    cases=$((cases + 1))

    # The two halves are independent and both are kept. A harness-only tool must
    # fail the denylist by name, and it would ALSO be unlisted here; proving the
    # denylist still fires stops this rule from quietly replacing it.
    { printf '#!/bin/bash\n'; printf 'readelf -d x\n'; } > "$hc_probe"
    hc_deny_hits=$(host_tool_invocations "$hc_probe")
    hc_allow_hits=$(hc_unlisted "$hc_probe" "$HOST_TOOL_CONTRACT" | grep -c . || true)
    if [ "$hc_deny_hits" -ge 1 ] && [ "$hc_allow_hits" -ge 1 ]; then
        pass "host-tool/both-halves-fire" "readelf caught by name and by vocabulary"
    else
        fail "host-tool/both-halves-fire" "deny=$hc_deny_hits allow=$hc_allow_hits"
    fi
    cases=$((cases + 1))

    # The regression this rule exists for, reproduced rather than described.
    # The real installer is copied and the observer's byte read is rewritten
    # back to the `dd` form that actually shipped. The denylist must still pass,
    # because `dd` is not one of the harness-only tools it names, and the
    # allowlist must fail and NAME it.
    hc_dd="$SCRATCH/dd-regression.sh"
    # shellcheck disable=SC2016  # the sed pattern is the installer's literal text
    sed -e 's|bytes=$(od -An -tx1 -v -j "$offset" -N "$width" "$file" 2>/dev/null|bytes=$(dd if="$file" bs=1 skip="$offset" count="$width" 2>/dev/null \| od -An -tx1 -v|' \
        "$INSTALLER" > "$hc_dd"
    if grep -q 'dd if=' "$hc_dd"; then
        hc_dd_deny=$(host_tool_invocations "$hc_dd")
        hc_dd_words=$(hc_unlisted "$hc_dd" "$HOST_TOOL_CONTRACT")
        if [ "$hc_dd_deny" -eq 0 ] && printf '%s\n' "$hc_dd_words" | grep -qxF 'dd'; then
            pass "host-tool/dd-regression" "denylist blind, allowlist names dd"
        else
            fail "host-tool/dd-regression" "deny=$hc_dd_deny words=$(printf '%s' "$hc_dd_words" | tr '\n' ' ')"
        fi
    else
        # The plant is asserted, so the case cannot report a shape it never made.
        fail "host-tool/dd-regression" "FIXTURE not planted: the observer read did not match"
    fi
    cases=$((cases + 1))
else
    fail "host-tool/contract" "MISSING: $HOST_TOOL_CONTRACT"
    cases=$((cases + 1))
fi

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

# ==================================================================== step 3 ===
# The CPLX-ELF/1 report contract, proved from BOTH ENDS before anything depends
# on it, so the step that changes behaviour carries only the wiring.
#
# Nothing here runs during an install and nothing here needs a capable host: the
# formatter is driven with constructed dispositions exactly as step 2 drives the
# classifier with constructed tuples, and the reader is driven with literals.
# So this suite sits BEFORE the baseline gate and answers on any host with bash.
#
# THE READER LIVES HERE, NEVER IN THE INSTALLER. It consumes a retained capture,
# so a parser in the file that must deploy standalone would add a call surface
# no install executes, to the file whose size is this effort's live constraint.
# The malformed-capture constructors live beside it for the same reason: they
# are validation inputs, and nothing in the installer knows how to build a
# broken capture.

CORPUS="${CORPUS_ARG:-$here/contract.cplx-elf-1.txt}"
# The frozen bytes, recorded in ledger.cplx-elf-1.md BEFORE either end was
# compared against them. Checked here so a corpus edited to make a red suite
# green is caught by the suite it was edited to satisfy.
CORPUS_FROZEN_BLOB="64a3173cebf84add5c7c40020a50e93390df32b2"

STEP3_REASON=""

# step3_vectors CLASS: the corpus lines of one class, without the class field.
step3_vectors() {
    grep "^$1|" "$CORPUS" 2>/dev/null | cut -d'|' -f2-
}

# step3_unescape SPEC DEST: decode the corpus raw-spec escapes to real bytes,
# into STEP3_SPEC. Named and decimal escapes on purpose, so a corpus input is
# never written in the encoding under test.
#
# The result is returned in a GLOBAL rather than printed, because one vector's
# raw input ends in a newline and command substitution strips trailing newlines.
# Printing it would silently drop the byte that vector exists to prove survives.
STEP3_SPEC=""
step3_unescape() {
    local spec="$1" dest="$2" out
    out="${spec//%DEST%/$dest}"
    out="${out//%SP%/ }"
    out="${out//%B255%/$'\xff'}"
    # Last, because it introduces the byte that terminates a line.
    out="${out//%NL%/$'\n'}"
    STEP3_SPEC="$out"
}

# step3_read_capture CAPTURE: THE RETAINED-OUTPUT READER.
#
# Accepts a whole capture, which is the install output, so lines carrying no
# marker are the human `echos` half and are ignored. A line carrying an UNKNOWN
# marker is rejected instead: ignoring it would be guessing that the run it
# describes is irrelevant.
#
# Sets STEP3_REASON to a distinguishable token and returns 1 on refusal, or
# clears it and returns 0. Fields are located BY NAME: nothing here depends on
# the order the formatter happens to emit.
step3_read_capture() {
    local capture="$1"
    local line rest kind pair name value seen
    local objs=0 trailers=0 case5=0
    local r_rewritten=0 r_failed=0 r_already=0 r_notdyn=0 r_excluded=0
    local i_rewritten=0 i_failed=0 i_unchanged=0 i_notapp=0
    local t_state="" t_reason="" t_walked=""
    local t_r_rewritten="" t_r_failed="" t_r_already="" t_r_notdyn="" t_r_excluded=""
    local t_i_rewritten="" t_i_failed="" t_i_unchanged="" t_i_notapp=""
    local t_mig_checked="" t_mig_failed=""
    local c_case="" c_rpath="" c_interp="" c_path=""
    STEP3_REASON=""

    while IFS= read -r line; do
        case "$line" in
            "CPLX-ELF/1 "*) rest="${line#CPLX-ELF/1 }" ;;
            "CPLX-ELF/"*)   STEP3_REASON="marker"; return 1 ;;
            *)              continue ;;
        esac
        kind="${rest%% *}"
        rest="${rest#* }"
        case "$kind" in
            obj|end) ;;
            *) STEP3_REASON="kind"; return 1 ;;
        esac
        # The trailer TERMINATES the capture, so nothing may follow it. Checked
        # here rather than by counting afterwards, because the shape this closes
        # is `obj end obj`, whose figures can reconcile across all three records
        # while being a second run that lost its own trailer. Arithmetic would
        # admit it; position does not.
        if [ "$trailers" -ne 0 ]; then
            STEP3_REASON="trailer"; return 1
        fi

        seen=""
        c_case=""; c_rpath=""; c_interp=""; c_path=""
        t_state=""; t_reason=""; t_walked=""
        t_r_rewritten=""; t_r_failed=""; t_r_already=""; t_r_notdyn=""; t_r_excluded=""
        t_i_rewritten=""; t_i_failed=""; t_i_unchanged=""; t_i_notapp=""
        t_mig_checked=""; t_mig_failed=""

        for pair in $rest; do
            # A bare word can only come from a value that contained a space, and
            # the grammar's tokens are space-free precisely so that cannot be
            # mistaken for a field.
            case "$pair" in
                *=*) ;;
                *) STEP3_REASON="token"; return 1 ;;
            esac
            name="${pair%%=*}"
            value="${pair#*=}"
            case " $seen " in
                *" $name "*) STEP3_REASON="duplicate"; return 1 ;;
            esac
            seen="$seen $name"
            case "$kind:$name" in
                obj:case)   c_case="$value" ;;
                obj:rpath)  c_rpath="$value" ;;
                obj:interp) c_interp="$value" ;;
                obj:path)   c_path="$value" ;;
                end:state)  t_state="$value" ;;
                end:reason) t_reason="$value" ;;
                end:walked) t_walked="$value" ;;
                end:r-rewritten)      t_r_rewritten="$value" ;;
                end:r-failed)         t_r_failed="$value" ;;
                end:r-already-correct) t_r_already="$value" ;;
                end:r-not-dynamic)    t_r_notdyn="$value" ;;
                end:r-excluded)       t_r_excluded="$value" ;;
                end:i-rewritten)      t_i_rewritten="$value" ;;
                end:i-failed)         t_i_failed="$value" ;;
                end:i-unchanged)      t_i_unchanged="$value" ;;
                end:i-not-applicable) t_i_notapp="$value" ;;
                end:mig-checked)      t_mig_checked="$value" ;;
                end:mig-failed)       t_mig_failed="$value" ;;
                *) STEP3_REASON="unknown"; return 1 ;;
            esac
        done

        if [ "$kind" = "obj" ]; then
            case " $seen " in
                *" case "*) ;; *) STEP3_REASON="missing"; return 1 ;;
            esac
            case " $seen " in
                *" rpath "*) ;; *) STEP3_REASON="missing"; return 1 ;;
            esac
            case " $seen " in
                *" interp "*) ;; *) STEP3_REASON="missing"; return 1 ;;
            esac
            case " $seen " in
                *" path "*) ;; *) STEP3_REASON="missing"; return 1 ;;
            esac
            case "$c_case" in [1-7]) ;; *) STEP3_REASON="case"; return 1 ;; esac
            case "$c_rpath" in
                rewritten)      r_rewritten=$((r_rewritten + 1)) ;;
                failed)         r_failed=$((r_failed + 1)) ;;
                already-correct) r_already=$((r_already + 1)) ;;
                not-dynamic)    r_notdyn=$((r_notdyn + 1)) ;;
                excluded)       r_excluded=$((r_excluded + 1)) ;;
                *) STEP3_REASON="token"; return 1 ;;
            esac
            case "$c_interp" in
                rewritten)      i_rewritten=$((i_rewritten + 1)) ;;
                failed)         i_failed=$((i_failed + 1)) ;;
                unchanged)      i_unchanged=$((i_unchanged + 1)) ;;
                not-applicable) i_notapp=$((i_notapp + 1)) ;;
                *) STEP3_REASON="token"; return 1 ;;
            esac
            # Non-empty, even length, lowercase hex only.
            case "$c_path" in
                ""|*[!0-9a-f]*) STEP3_REASON="path"; return 1 ;;
            esac
            if [ $(( ${#c_path} % 2 )) -ne 0 ]; then
                STEP3_REASON="path"; return 1
            fi
            # A decoded value may not begin with `/` or `./`: 2f is `/`, 2e2f is
            # `./`. Tested on the encoded form so nothing has to be decoded to
            # find out.
            case "$c_path" in
                2f*|2e2f*) STEP3_REASON="path"; return 1 ;;
            esac
            objs=$((objs + 1))
            [ "$c_case" = "5" ] && case5=$((case5 + 1))
        else
            trailers=$((trailers + 1))
            for name in state reason walked r-rewritten r-failed r-already-correct \
                r-not-dynamic r-excluded i-rewritten i-failed i-unchanged \
                i-not-applicable mig-checked mig-failed; do
                case " $seen " in
                    *" $name "*) ;; *) STEP3_REASON="missing"; return 1 ;;
                esac
            done
            case "$t_state $t_reason" in
                "completed none"|"skipped patchelf-absent") ;;
                *) STEP3_REASON="pairing"; return 1 ;;
            esac
            for value in "$t_walked" "$t_r_rewritten" "$t_r_failed" "$t_r_already" \
                "$t_r_notdyn" "$t_r_excluded" "$t_i_rewritten" "$t_i_failed" \
                "$t_i_unchanged" "$t_i_notapp" "$t_mig_checked" "$t_mig_failed"; do
                case "$value" in
                    ""|*[!0-9]*) STEP3_REASON="number"; return 1 ;;
                esac
            done
        fi
    done <<< "$capture"

    # Exactly one trailer. None is a truncated capture; two is two runs
    # concatenated. Either way the recipe knows not to assert on it.
    if [ "$trailers" -ne 1 ]; then
        STEP3_REASON="trailer"; return 1
    fi
    # A skipped pass that reported counts would be describing work it did not do.
    if [ "$t_state" = "skipped" ]; then
        if [ "$objs" -ne 0 ]; then STEP3_REASON="skipped"; return 1; fi
        for value in "$t_walked" "$t_r_rewritten" "$t_r_failed" "$t_r_already" \
            "$t_r_notdyn" "$t_r_excluded" "$t_i_rewritten" "$t_i_failed" \
            "$t_i_unchanged" "$t_i_notapp" "$t_mig_checked" "$t_mig_failed"; do
            [ "$value" = "0" ] || { STEP3_REASON="skipped"; return 1; }
        done
    fi
    [ "$t_walked" = "$objs" ] || { STEP3_REASON="walked"; return 1; }
    # Per category, not by sum. A capture of 388 failed records with a trailer
    # claiming 388 rewritten satisfies both sums and every category is wrong.
    [ "$t_r_rewritten" = "$r_rewritten" ] || { STEP3_REASON="per-token"; return 1; }
    [ "$t_r_failed" = "$r_failed" ]       || { STEP3_REASON="per-token"; return 1; }
    [ "$t_r_already" = "$r_already" ]     || { STEP3_REASON="per-token"; return 1; }
    [ "$t_r_notdyn" = "$r_notdyn" ]       || { STEP3_REASON="per-token"; return 1; }
    [ "$t_r_excluded" = "$r_excluded" ]   || { STEP3_REASON="per-token"; return 1; }
    [ "$t_i_rewritten" = "$i_rewritten" ] || { STEP3_REASON="per-token"; return 1; }
    [ "$t_i_failed" = "$i_failed" ]       || { STEP3_REASON="per-token"; return 1; }
    [ "$t_i_unchanged" = "$i_unchanged" ] || { STEP3_REASON="per-token"; return 1; }
    [ "$t_i_notapp" = "$i_notapp" ]       || { STEP3_REASON="per-token"; return 1; }
    [ "$t_mig_checked" = "$case5" ] || { STEP3_REASON="migration"; return 1; }
    [ "$t_mig_failed" -le "$t_mig_checked" ] || { STEP3_REASON="migration"; return 1; }
    return 0
}

# step3_capture_from_vector VECTOR: the constructors. A corpus capture packs its
# records with `;;` so one vector is one line; this expands them back to the
# newline-separated stream a real capture is.
step3_capture_from_vector() {
    printf '%s' "${1//;;/$'\n'}"
}

step3_suite() {
    local id record raw expect got reason spec dest line class n
    dest="/tmp/cplx-step3-dest"

    section "step 3: the corpus is the frozen witness"

    if [ ! -f "$CORPUS" ]; then
        fail "corpus/present" "CORPUS absent: $CORPUS"
        cases=$((cases + 1))
        return 0
    fi
    note "corpus/path" "$CORPUS"
    pass "corpus/present" "$(step3_vectors canonical-obj | grep -c .) canonical obj vectors"
    cases=$((cases + 1))

    # The corpus outranks both implementations, so a suite made green by editing
    # it would be the one failure this design cannot otherwise see.
    got=$(git hash-object "$CORPUS" 2>/dev/null || echo unavailable)
    chk "corpus/frozen-bytes" "$CORPUS_FROZEN_BLOB" "$got"
    cases=$((cases + 1))

    # Three declared classes. A two-class corpus would file a lawful permutation
    # as malformed input, which is the mistake the third class exists to stop.
    for class in canonical-obj canonical-end reader-valid rejected path \
        capture-valid capture-reject; do
        n=$(step3_vectors "$class" | grep -c .)
        if [ "$n" -gt 0 ]; then
            pass "corpus/class-$class" "$n vectors"
        else
            fail "corpus/class-$class" "CORPUS class is empty"
        fi
        cases=$((cases + 1))
    done

    section "step 3: the formatter emits the canonical bytes"

    if declare -F emit_cplx_elf_v1_record >/dev/null 2>&1; then
        pass "step3/formatter-defined" "emit_cplx_elf_v1_record"
    else
        fail "step3/formatter-defined" "SEAM the formatter did not survive sourcing"
    fi
    cases=$((cases + 1))

    # Byte for byte against the CANONICAL class only. The formatter is never
    # required to emit the permutations, so comparing against them would be
    # asserting a freedom rather than an obligation.
    while IFS='|' read -r id record; do
        [ -n "$id" ] || continue
        raw=$(step3_vectors path | awk -F'|' -v i="$id" '$1 == i {print $2}')
        [ -n "$raw" ] || continue
        step3_unescape "$raw" "$dest"
        got=$(emit_cplx_elf_v1_record obj \
            "$(printf '%s' "$record" | sed 's/.*case=\([0-9]\).*/\1/')" \
            "$(printf '%s' "$record" | sed 's/.*rpath=\([a-z-]*\).*/\1/')" \
            "$(printf '%s' "$record" | sed 's/.*interp=\([a-z-]*\).*/\1/')" \
            "$dest/${STEP3_SPEC#"$dest/"}" "$dest" 2>/dev/null)
        chk "formatter/canonical-$id" "$record" "$got"
        cases=$((cases + 1))
    done <<< "$(step3_vectors canonical-obj)"

    # Every path vector's expected hex, including the adjacent pair straddling
    # the measured od wrap boundary, where a lost byte or an injected separator
    # would appear and nowhere else.
    while IFS='|' read -r id raw expect; do
        [ -n "$id" ] || continue
        step3_unescape "$raw" "$dest"
        got=$(emit_cplx_elf_v1_record obj 5 failed unchanged \
            "$dest/${STEP3_SPEC#"$dest/"}" "$dest" 2>/dev/null)
        got="${got##*path=}"
        chk "formatter/path-$id" "$expect" "$got"
        cases=$((cases + 1))
    done <<< "$(step3_vectors path)"

    while IFS='|' read -r id record; do
        [ -n "$id" ] || continue
        case "$id" in
            completed-design-sample)
                got=$(emit_cplx_elf_v1_record end completed none 1 0 1 0 0 0 0 0 1 0 1 0) ;;
            skipped)
                got=$(emit_cplx_elf_v1_record end skipped patchelf-absent 0 0 0 0 0 0 0 0 0 0 0 0) ;;
            *) continue ;;
        esac
        chk "formatter/canonical-end-$id" "$record" "$got"
        cases=$((cases + 1))
    done <<< "$(step3_vectors canonical-end)"

    # The formatter refuses what the grammar forbids rather than emitting it.
    for spec in "obj 8 failed unchanged $dest/a $dest" \
        "obj 5 bogus unchanged $dest/a $dest" \
        "obj 5 failed bogus $dest/a $dest" \
        "end completed patchelf-absent 0 0 0 0 0 0 0 0 0 0 0 0" \
        "end skipped none 0 0 0 0 0 0 0 0 0 0 0 0" \
        "end skipped patchelf-absent 0 1 0 0 0 0 0 0 0 0 0 0"; do
        # shellcheck disable=SC2086  # deliberate word split: the row IS the argv
        if emit_cplx_elf_v1_record $spec >/dev/null 2>&1; then
            fail "formatter/refuses" "FORMATTER emitted a forbidden record: $spec"
        else
            pass "formatter/refuses" "$spec"
        fi
        cases=$((cases + 1))
    done

    section "step 3: the reader accepts what the grammar allows"

    # Canonical records, each as a one-record capture with its matching trailer.
    while IFS='|' read -r id record; do
        [ -n "$id" ] || continue
        if step3_read_capture "$record"; then
            fail "reader/needs-trailer-$id" "READER accepted a capture with no trailer"
        else
            if [ "$STEP3_REASON" = "trailer" ]; then
                pass "reader/needs-trailer-$id" "trailer"
            else
                fail "reader/needs-trailer-$id" "READER wrong reason: $STEP3_REASON"
            fi
        fi
        cases=$((cases + 1))
    done <<< "$(step3_vectors canonical-obj)"

    # The permutations are what test name-based field resolution. A strictly
    # positional reader passes every canonical and every rejected vector, and
    # fails only here.
    while IFS='|' read -r id record; do
        [ -n "$id" ] || continue
        # A lone obj record is a capture with no trailer, so the permuted obj
        # vectors are given the trailer that reconciles with them. Skipping them
        # instead would skip the only vectors that test obj field resolution.
        case "$id" in
            obj-permuted)
                record="$record"$'\n'"CPLX-ELF/1 end state=completed reason=none walked=1 r-rewritten=0 r-failed=1 r-already-correct=0 r-not-dynamic=0 r-excluded=0 i-rewritten=0 i-failed=0 i-unchanged=1 i-not-applicable=0 mig-checked=1 mig-failed=0" ;;
            obj-permuted-2)
                record="$record"$'\n'"CPLX-ELF/1 end state=completed reason=none walked=1 r-rewritten=0 r-failed=0 r-already-correct=0 r-not-dynamic=0 r-excluded=1 i-rewritten=0 i-failed=0 i-unchanged=0 i-not-applicable=1 mig-checked=0 mig-failed=0" ;;
            # The permuted COMPLETED trailer reconciles against one record, so
            # it needs that record to be a lawful capture. Feeding it alone
            # would test reconciliation, which is not what this class is for.
            end-permuted)
                record="CPLX-ELF/1 obj case=5 rpath=failed interp=unchanged path=6c69622f666f6f2e736f"$'\n'"$record" ;;
        esac
        if step3_read_capture "$record"; then
            pass "reader/permuted-$id" "fields located by name"
        else
            fail "reader/permuted-$id" "READER rejected a lawful permutation: $STEP3_REASON"
        fi
        cases=$((cases + 1))
    done <<< "$(step3_vectors reader-valid)"

    section "step 3: the reader refuses what it must"

    while IFS='|' read -r id reason record; do
        [ -n "$id" ] || continue
        if step3_read_capture "$record"; then
            fail "reader/rejects-$id" "READER accepted a malformed record"
        elif [ "$STEP3_REASON" = "$reason" ]; then
            pass "reader/rejects-$id" "$reason"
        else
            fail "reader/rejects-$id" "READER reason $STEP3_REASON, expected $reason"
        fi
        cases=$((cases + 1))
    done <<< "$(step3_vectors rejected)"

    section "step 3: reconciliation is categorical"

    while IFS='|' read -r id record; do
        [ -n "$id" ] || continue
        if step3_read_capture "$(step3_capture_from_vector "$record")"; then
            pass "reader/capture-$id" "accepted"
        else
            fail "reader/capture-$id" "READER rejected a lawful capture: $STEP3_REASON"
        fi
        cases=$((cases + 1))
    done <<< "$(step3_vectors capture-valid)"

    while IFS='|' read -r id reason record; do
        [ -n "$id" ] || continue
        if step3_read_capture "$(step3_capture_from_vector "$record")"; then
            fail "reader/capture-rejects-$id" "READER accepted an inconsistent capture"
        elif [ "$STEP3_REASON" = "$reason" ]; then
            pass "reader/capture-rejects-$id" "$reason"
        else
            fail "reader/capture-rejects-$id" "READER reason $STEP3_REASON, expected $reason"
        fi
        cases=$((cases + 1))
    done <<< "$(step3_vectors capture-reject)"

    section "step 3: the two ends agree"

    # The round trip is checked as well, but it is the corpus that makes their
    # agreement mean correctness: two ends written by the same hand can drift
    # together while still carrying the marker.
    got=$(
        emit_cplx_elf_v1_record obj 5 failed unchanged "$dest/lib/foo.so" "$dest"
        emit_cplx_elf_v1_record end completed none 1 0 1 0 0 0 0 0 1 0 1 0
    )
    if step3_read_capture "$got"; then
        pass "step3/round-trip" "the reader accepts what the formatter emits"
    else
        fail "step3/round-trip" "ROUNDTRIP the reader refused the formatter: $STEP3_REASON"
    fi
    cases=$((cases + 1))

    section "step 3: the formatter has no production call site"

    # The whole argument of this step is that nothing a deployment can see
    # changes, and an identifier search is only as good as the identifier. The
    # name is reserved in the plan and forbidden in comments and message
    # literals here, so every occurrence is a definition or a call. Step 3
    # expects exactly one: the definition.
    n=$(grep -c '\bemit_cplx_elf_v1_record\b' "$INSTALLER" 2>/dev/null || true)
    chk "step3/formatter-uncalled" "1" "$n"
    cases=$((cases + 1))

    # The reader is in this harness and must not have leaked into the file that
    # has to deploy standalone.
    n=$(grep -c '\bstep3_read_capture\b' "$INSTALLER" 2>/dev/null || true)
    chk "step3/reader-absent-from-installer" "0" "$n"
    cases=$((cases + 1))
}

# Step 3 needs no baseline and no capable host: nothing it checks runs during an
# install, so the capture below would prove nothing about it while demanding
# patchelf and a Linux kernel it never uses. Running the suite HERE, ahead of the
# host gate, is what lets step 3 answer on the authoring host rather than report
# unanswered for capability it does not need.
if [ "$STEP" = "3" ]; then
    # The formatter is PRODUCTION code, reached by sourcing the installer through
    # the seam step 0 opened, so the cases exercise it rather than a copy.
    # shellcheck disable=SC1090
    source "$ISOLATED_INSTALLER" >/dev/null 2>&1
    # Step 0's preflight runs for every invocation and resolves readelf and the
    # target capability, which Step 3 never uses: it reads literals and drives a
    # formatter. On a host without those, Step 0's cases fail above and steps 1
    # and 2 absorb them into their host gate, which Step 3 skips.
    #
    # So the verdict is scoped to the cases Step 3 OWNS, and the inherited ones
    # are named rather than discounted. Reporting the total would fail Step 3 for
    # capability its criteria do not mention; hiding the inherited failures would
    # be the count-driven change this effort has refused since Step 0. Both
    # figures are printed, and only the owned one decides.
    step3_inherited_failures="$failures"
    step3_first_case=$((cases + 1))
    step3_suite
    step3_own_failures=$((failures - step3_inherited_failures))
    printf '\n== verdict\n'
    printf '  step        %s\n' "$STEP"
    printf '  cases       %s\n' "$((cases - step3_first_case + 1))"
    printf '  failures    %s\n' "$step3_own_failures"
    printf '  corpus      %s\n' "$CORPUS"
    printf '  installer   %s\n' "$INSTALLER"
    if [ "$step3_inherited_failures" -ne 0 ]; then
        printf '  inherited   %s step 0 preflight failure(s), not step 3 criteria\n' \
            "$step3_inherited_failures"
        printf '              this host cannot answer step 0; step 3 does not ask it to\n'
    fi
    if [ "$step3_own_failures" -ne 0 ]; then
        printf '\nOBJECTIVE NOT MET for step %s: %s failure(s)\n' "$STEP" "$step3_own_failures"
        exit 1
    fi
    printf '\nOBJECTIVE MET for step %s\n' "$STEP"
    exit 0
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


# ============================================================== step 1 cases ===
# The observer's guard-complete fixture matrix.
#
# Fixtures are generated into scratch from committed recipes, so nothing binary
# enters the repository and what is reviewed is the recipe rather than a blob.
# Every fixture is validated by a SEMANTIC oracle before the observer sees it,
# sourced independently of the observer: validation-only `readelf` where it can
# express the state, and the manifest where it cannot, for the deliberately
# malformed shapes no tool will name.

# elf_size FILE: the figure the production walk supplies beside the path. `find`
# is already in the audited host-tool contract; `stat` and `wc` are not, and the
# harness uses the same source the walk does so the observer is exercised with
# the input it will really receive.
elf_size() { find "$1" -maxdepth 0 -printf '%s\n' 2>/dev/null; }

# elf_poke FILE OFFSET HEXBYTES: write raw bytes at a byte offset. This is
# harness-side fixture construction, not installer code.
elf_poke() {
    local file="$1" offset="$2" hex="$3" i esc=""
    for (( i = 0; i < ${#hex}; i += 2 )); do esc="$esc\\x${hex:i:2}"; done
    printf '%b' "$esc" | dd of="$file" bs=1 seek="$offset" conv=notrunc 2>/dev/null
}

# le_hex VALUE WIDTH: little-endian hex for a mutation that depends on the base's
# own measurements, such as an offset past the end of the file.
le_hex() {
    local v="$1" w="$2" i out=""
    for (( i = 0; i < w; i++ )); do
        out="$out$(printf '%02x' $(( (v >> (8 * i)) & 0xff )))"
    done
    printf '%s' "$out"
}

# Locate one program-header entry by p_type. The returned value is the FILE
# offset of the entry, not a virtual address. Fixture construction uses the
# production reader for byte decoding but does not reuse any observer verdict.
elf_find_phdr() {
    local file="$1" want="$2" phoff phentsize phnum i off got
    phoff=$(elf_read_le "$file" 32 8) || return 1
    phentsize=$(elf_read_le "$file" 54 2) || return 1
    phnum=$(elf_read_le "$file" 56 2) || return 1
    for (( i = 0; i < phnum; i++ )); do
        off=$(( phoff + i * phentsize ))
        got=$(elf_read_le "$file" "$off" 4) || return 1
        if [ "$got" = "$want" ]; then printf '%s' "$off"; return 0; fi
    done
    return 1
}

# Locate one dynamic entry by d_tag. OCCURRENCE is one-based so duplicate tags
# can be addressed without assuming their order in the donor.
elf_find_dyn_entry() {
    local file="$1" want="$2" occurrence="${3:-1}"
    local dynph dynoff dynsize count=0 off tag
    dynph=$(elf_find_phdr "$file" 2) || return 1
    dynoff=$(elf_read_le "$file" $(( dynph + 8 )) 8) || return 1
    dynsize=$(elf_read_le "$file" $(( dynph + 32 )) 8) || return 1
    for (( off = dynoff; off < dynoff + dynsize; off += 16 )); do
        tag=$(elf_read_le "$file" "$off" 8) || return 1
        if [ "$tag" = "$want" ]; then
            count=$((count + 1))
            if [ "$count" -eq "$occurrence" ]; then printf '%s' "$off"; return 0; fi
        fi
    done
    return 1
}

# Remove one program-header entry, compacting the table and decrementing
# e_phnum. G02 and G03 are therefore the recipes the plan names, rather than a
# donor substitution or a PT_NULL relabel that merely looks absent to readelf.
elf_remove_phdr() {
    local file="$1" want="$2" phoff phentsize phnum target i src dst bytes zeros=""
    phoff=$(elf_read_le "$file" 32 8) || return 1
    phentsize=$(elf_read_le "$file" 54 2) || return 1
    phnum=$(elf_read_le "$file" 56 2) || return 1
    [ "$phentsize" = "56" ] || return 1
    target=$(elf_find_phdr "$file" "$want") || return 1
    for (( i = (target - phoff) / phentsize; i < phnum - 1; i++ )); do
        dst=$(( phoff + i * phentsize ))
        src=$(( dst + phentsize ))
        bytes=$(od -An -tx1 -v -j "$src" -N "$phentsize" "$file" | tr -d '[:space:]')
        [ "${#bytes}" -eq $(( phentsize * 2 )) ] || return 1
        elf_poke "$file" "$dst" "$bytes"
    done
    for (( i = 0; i < phentsize; i++ )); do zeros="${zeros}00"; done
    elf_poke "$file" $(( phoff + (phnum - 1) * phentsize )) "$zeros"
    elf_poke "$file" 56 "$(le_hex $(( phnum - 1 )) 2)"
}

# Add one dynamic tag before the existing terminator while reusing a lawful
# string-table index. A second DT_NULL must already be available so the recipe
# never manufactures an unterminated list.
elf_add_dyn_tag_reusing_value() {
    local file="$1" tag="$2" source_tag="$3" source null_entry spare value
    source=$(elf_find_dyn_entry "$file" "$source_tag") || return 1
    value=$(elf_read_le "$file" $(( source + 8 )) 8) || return 1
    null_entry=$(elf_find_dyn_entry "$file" 0 1) || return 1
    spare=$(elf_find_dyn_entry "$file" 0 2) || return 1
    [ "$spare" -eq $(( null_entry + 16 )) ] || return 1
    elf_poke "$file" "$null_entry" "$(le_hex "$tag" 8)"
    elf_poke "$file" $(( null_entry + 8 )) "$(le_hex "$value" 8)"
}

# Convert DT_STRTAB's virtual address to its file offset by finding the PT_LOAD
# segment that carries it. This is fixture construction only; the observer does
# not need the string table to classify tags.
elf_dynstr_offset() {
    local file="$1" strent straddr phoff phentsize phnum i off ptype
    local poffset pvaddr pfilesz
    strent=$(elf_find_dyn_entry "$file" 5) || return 1
    straddr=$(elf_read_le "$file" $(( strent + 8 )) 8) || return 1
    phoff=$(elf_read_le "$file" 32 8) || return 1
    phentsize=$(elf_read_le "$file" 54 2) || return 1
    phnum=$(elf_read_le "$file" 56 2) || return 1
    for (( i = 0; i < phnum; i++ )); do
        off=$(( phoff + i * phentsize ))
        ptype=$(elf_read_le "$file" "$off" 4) || return 1
        [ "$ptype" = "1" ] || continue
        poffset=$(elf_read_le "$file" $(( off + 8 )) 8) || return 1
        pvaddr=$(elf_read_le "$file" $(( off + 16 )) 8) || return 1
        pfilesz=$(elf_read_le "$file" $(( off + 32 )) 8) || return 1
        if [ "$straddr" -ge "$pvaddr" ] && [ "$straddr" -lt $(( pvaddr + pfilesz )) ]; then
            printf '%s' $(( poffset + straddr - pvaddr ))
            return 0
        fi
    done
    return 1
}

# Build two distinct search-path strings and two dynamic tags. patchelf creates
# the first entry and allocates one combined string; the recipe splits that
# string at the colon, then turns the first spare DT_NULL into the second tag.
elf_make_two_search_tags() {
    local file="$1" first_tag="$2" second_tag="$3" first="$4" second="$5"
    local mode="$6" first_entry first_index strtab split second_entry spare
    if [ "$mode" = "rpath" ]; then
        "$PATCHELF_BIN" --force-rpath --set-rpath "$first:$second" "$file" 2>/dev/null || return 1
    else
        "$PATCHELF_BIN" --set-rpath "$first:$second" "$file" 2>/dev/null || return 1
    fi
    first_entry=$(elf_find_dyn_entry "$file" "$first_tag") || return 1
    first_index=$(elf_read_le "$file" $(( first_entry + 8 )) 8) || return 1
    strtab=$(elf_dynstr_offset "$file") || return 1
    split=$(( strtab + first_index + ${#first} ))
    elf_poke "$file" "$split" "00"
    second_entry=$(elf_find_dyn_entry "$file" 0) || return 1
    spare=$(elf_find_dyn_entry "$file" 0 2) || return 1
    [ "$spare" -eq $(( second_entry + 16 )) ] || return 1
    elf_poke "$file" "$second_entry" "$(le_hex "$second_tag" 8)"
    elf_poke "$file" $(( second_entry + 8 )) "$(le_hex $(( first_index + ${#first} + 1 )) 8)"
}

# ------------------------------------------------------------ fixture planting ---
# The donor, the lawful base and the twenty-five recipes, extracted from Step 1's
# suite so Step 2's bridge plants the SAME fixture rather than a second one
# written to the same description. A bridge whose subjects were re-cut here would
# compare the classifier against a copy of the producer's inputs, which is the
# drift it exists to detect.
FIXTURE_DONOR=""

# A hand-assembled ELF would be a second implementation of the format, which the
# plan already refused for the parser. The lawful bases are shipped system
# objects, varied with patchelf, and each is validated by `readelf` before use.
resolve_fixture_donor() {
    local d
    for d in /bin/true /usr/bin/true /bin/echo; do
        [ -f "$d" ] && { FIXTURE_DONOR="$d"; return 0; }
    done
    return 1
}

# G01, the lawful base: a program with PT_INTERP, PT_LOAD and PT_DYNAMIC and no
# search-path tag.
#
# The donor is whatever the distribution ships, and on Debian 12 /bin/true is a
# PIE, so its e_type is ET_DYN. The base NORMALISES e_type to ET_EXEC rather than
# inheriting it, so the fixture set does not silently change meaning with the
# donor: F01 is exec because it was made exec, and F02 is dyn because one
# mutation made it so. An earlier version inherited the donor and expected exec,
# and the run said dyn.
plant_fixture_base() {
    local out="$1" donor="$2"
    cp -- "$donor" "$out" || return 1
    chmod u+w -- "$out" || return 1
    "$PATCHELF_BIN" --remove-rpath "$out" 2>/dev/null
    elf_poke "$out" 16 "0200"
    return 0
}

# plant_fixture ID RECIPE OUT BASE DONOR: cut one fixture from the base.
#
# A recipe that cannot be cut REPORTS and returns non-zero, so the caller skips
# that row rather than asserting against a file it never planted.
plant_fixture() {
    local id="$1" recipe="$2" f="$3" G01="$4" donor_prog="$5"
    local ph dynph dynoff dynsize off tag nulls
    case "$recipe" in
        prog)        cp -- "$G01" "$f" ;;
        pie)         cp -- "$G01" "$f"; elf_poke "$f" 16 "0300" ;;
        rel)         cp -- "$G01" "$f"; elf_poke "$f" 16 "0100"; elf_poke "$f" 56 "0000" ;;
        lib)         cp -- "$G01" "$f"
                     elf_poke "$f" 16 "0300"
                     elf_remove_phdr "$f" 3 \
                         || { fail "$id/recipe" "G02 could not remove PT_INTERP"; return 1; } ;;
        # patchelf runs on the UNNORMALISED donor and e_type is set after: it
        # rewrites segments, and asking it to work on a PIE layout that has
        # been relabelled ET_EXEC makes it decline silently, which the first
        # run showed as a tag_state of none on both tag fixtures.
        rpath)       cp -- "$donor_prog" "$f"; chmod u+w -- "$f"
                     "$PATCHELF_BIN" --force-rpath --set-rpath '/opt/cplx-probe/lib' "$f" 2>/dev/null
                     elf_poke "$f" 16 "0200" ;;
        runpath)     cp -- "$donor_prog" "$f"; chmod u+w -- "$f"
                     "$PATCHELF_BIN" --force-rpath --set-rpath '/opt/cplx-probe/lib' "$f" 2>/dev/null
                     off=$(elf_find_dyn_entry "$f" 15) \
                         || { fail "$id/recipe" "M03 DT_RPATH not found"; return 1; }
                     elf_poke "$f" "$off" "$(le_hex 29 8)"
                     elf_poke "$f" 16 "0200" ;;
        nodynamic)   cp -- "$G01" "$f"
                     elf_remove_phdr "$f" 2 \
                         || { fail "$id/recipe" "G03 could not remove PT_DYNAMIC"; return 1; } ;;
        notabletag)  cp -- "$G01" "$f"
                     elf_add_dyn_tag_reusing_value "$f" 14 1 \
                         || { fail "$id/recipe" "G04 could not add DT_SONAME before DT_NULL"; return 1; } ;;
        bothtags)    cp -- "$donor_prog" "$f"; chmod u+w -- "$f"
                     elf_make_two_search_tags "$f" 29 15 \
                         '/opt/cplx-probe/runpath' '/opt/cplx-probe/rpath' runpath \
                         || { fail "$id/recipe" "G07 could not create distinct RPATH and RUNPATH"; return 1; }
                     elf_poke "$f" 16 "0200" ;;
        duplicatetag) cp -- "$donor_prog" "$f"; chmod u+w -- "$f"
                     elf_make_two_search_tags "$f" 15 15 \
                         '/opt/cplx-probe/rpath-a' '/opt/cplx-probe/rpath-b' rpath \
                         || { fail "$id/recipe" "G08 could not create two distinct RPATH entries"; return 1; }
                     elf_poke "$f" 16 "0200" ;;
        notable)     cp -- "$G01" "$f"; elf_poke "$f" 56 "0000" ;;
        badmagic)    cp -- "$G01" "$f"; elf_poke "$f" 0 "7f454c47" ;;
        badversion)  cp -- "$G01" "$f"; elf_poke "$f" 6 "00" ;;
        elf32)       cp -- "$G01" "$f"; elf_poke "$f" 4 "01" ;;
        bigendian)   cp -- "$G01" "$f"; elf_poke "$f" 5 "02" ;;
        badmachine)  cp -- "$G01" "$f"; elf_poke "$f" 18 "b700" ;;
        pnxnum)      cp -- "$G01" "$f"; elf_poke "$f" 56 "ffff" ;;
        shortfile)   head -c 32 "$G01" > "$f" ;;
        badphentsize) cp -- "$G01" "$f"; elf_poke "$f" 54 "2000" ;;
        tablepast)   cp -- "$G01" "$f"; elf_poke "$f" 32 "$(le_hex $(( $(elf_size "$G01") + 16 )) 8)" ;;
        # M17: the unsigned value 2^64-16, written as literal bytes because
        # no Bash integer can hold it. That is the point of the fixture.
        offsetwrap)  cp -- "$G01" "$f"
                     ph=$(elf_find_phdr "$f" 1) || { fail "$id/recipe" "M17 PT_LOAD not found"; return 1; }
                     elf_poke "$f" $(( ph + 8 )) "f0ffffffffffffff" ;;
        # M18: both extents at 2^62. Each decodes exactly, so the
        # representability guard cannot refuse this one; only their sum
        # overflows. Measured both ways: the pre-fix observer reports `ok`
        # for this object and the fixed one reports `inconclusive`.
        extentwrap)  cp -- "$G01" "$f"
                     ph=$(elf_find_phdr "$f" 1) || { fail "$id/recipe" "M18 PT_LOAD not found"; return 1; }
                     elf_poke "$f" $(( ph + 8 )) "$(le_hex $(( 1 << 62 )) 8)"
                     elf_poke "$f" $(( ph + 32 )) "$(le_hex $(( 1 << 62 )) 8)" ;;
        segmentpast) cp -- "$G01" "$f"
                     ph=$(elf_find_phdr "$f" 1) || { fail "$id/recipe" "M12/M13 PT_LOAD not found"; return 1; }
                     elf_poke "$f" $(( ph + 8 )) "$(le_hex $(( $(elf_size "$f") + 16 )) 8)"
                     elf_poke "$f" $(( ph + 32 )) "$(le_hex 1 8)" ;;
        dynodd)      cp -- "$G01" "$f"
                     dynph=$(elf_find_phdr "$f" 2) || { fail "$id/recipe" "M14 PT_DYNAMIC not found"; return 1; }
                     dynoff=$(elf_read_le "$f" $(( dynph + 8 )) 8)
                     dynsize=$(elf_read_le "$f" $(( dynph + 32 )) 8)
                     [ $(( dynoff + dynsize + 8 )) -le "$(elf_size "$f")" ] \
                         || { fail "$id/recipe" "M14 donor has no eight-byte dynamic slack"; return 1; }
                     elf_poke "$f" $(( dynph + 32 )) "$(le_hex $(( dynsize + 8 )) 8)" ;;
        nonull)      cp -- "$G01" "$f"
                     dynph=$(elf_find_phdr "$f" 2) || { fail "$id/recipe" "M15 PT_DYNAMIC not found"; return 1; }
                     dynoff=$(elf_read_le "$f" $(( dynph + 8 )) 8)
                     dynsize=$(elf_read_le "$f" $(( dynph + 32 )) 8)
                     nulls=0
                     for (( off = dynoff; off < dynoff + dynsize; off += 16 )); do
                         tag=$(elf_read_le "$f" "$off" 8) || break
                         if [ "$tag" = "0" ]; then elf_poke "$f" "$off" "$(le_hex 1 8)"; nulls=$((nulls + 1)); fi
                     done
                     [ "$nulls" -gt 0 ] || { fail "$id/recipe" "M15 donor has no DT_NULL"; return 1; } ;;
        *) fail "$id/recipe" "unknown recipe [$recipe]"; return 1 ;;
    esac
    [ -f "$f" ] || { fail "$id/fixture" "FIXTURE absent: $f was not planted"; return 1; }
    return 0
}

# plant_patchelf_double ID DIR: write a patchelf stand-in that fails one probe.
#
# The double DELEGATES every call it does not fail to the shipped tool, so the
# surviving axis is answered by the real binary rather than by a stand-in that
# would make the surviving value meaningless.
plant_patchelf_double() {
    local pid="$1" dir="$2" flag
    case "$pid" in
        D01) flag="--print-rpath" ;;
        D02) flag="--print-interpreter" ;;
        *) return 1 ;;
    esac
    mkdir -p -- "$dir" || return 1
    cat > "$dir/patchelf" <<DOUBLE
#!/bin/bash
[ "\$1" = "$flag" ] && exit 1
exec "$PATCHELF_BIN" "\$@"
DOUBLE
    chmod +x -- "$dir/patchelf" || return 1
    return 0
}


step1_manifest() {
    cat <<'MANIFEST'
M00|e_type|16|2|little|from the donor|02 00|elf(5) Elf64_Ehdr.e_type: the base is normalised to ET_EXEC=2
M01|e_type|16|2|little|02 00|03 00|elf(5) Elf64_Ehdr.e_type: ET_EXEC=2, ET_DYN=3
M02|e_type|16|2|little|02 00|01 00|elf(5) Elf64_Ehdr.e_type: ET_REL=1
M03|search-path d_tag|dynamic entry offset|8|little|0f 00 00 00 00 00 00 00|1d 00 00 00 00 00 00 00|LSB dynamic section: DT_RPATH=15 and DT_RUNPATH=29
M04|e_ident[0..3]|0|4|n/a|7f 45 4c 46|7f 45 4c 47|elf(5) e_ident four-byte signature
M05|e_ident[EI_VERSION]|6|1|n/a|01|00|elf(5) EI_VERSION must be EV_CURRENT=1
M06|e_ident[EI_CLASS]|4|1|n/a|02|01|elf(5) ELFCLASS64=2, ELFCLASS32=1
M07|e_ident[EI_DATA]|5|1|n/a|01|02|elf(5) ELFDATA2LSB=1, ELFDATA2MSB=2
M08|e_machine|18|2|little|3e 00|b7 00|elf(5) EM_X86_64=62, EM_AARCH64=183
M09|e_phnum|56|2|little|from the base|ff ff|elf(5) PN_XNUM=0xffff escapes to the section header table
M10|e_phentsize|54|2|little|38 00|20 00|ELF64 fixes Elf64_Phdr at 56 bytes
M11|e_phoff|32|8|little|from the base|file size plus 16|elf(5) Elf64_Ehdr.e_phoff
M12|PT_LOAD p_offset|entry + 8|8|little|from the base|file size plus 16|elf(5) Elf64_Phdr.p_offset and the segment extent must stay inside the file
M13|PT_LOAD p_filesz|entry + 32|8|little|from the base|01 00 00 00 00 00 00 00|elf(5) Elf64_Phdr.p_filesz and the segment extent must stay inside the file
M14|PT_DYNAMIC p_filesz|entry + 32|8|little|from the base|base value plus 8|LSB Elf64_Dyn is two eight-byte members, so the extent must be a multiple of 16
M15|terminating d_tag|dynamic entry offset|8|little|00 00 00 00 00 00 00 00|01 00 00 00 00 00 00 00|LSB DT_NULL terminates the dynamic array and DT_NEEDED does not
M16|e_phnum|56|2|little|from the base|00 00|elf(5) a zero count is lawful and means no table
M17|PT_LOAD p_offset|entry + 8|8|little|from the base|f0 ff ff ff ff ff ff ff|elf(5) Elf64_Phdr.p_offset is UNSIGNED 64-bit; 2^64-16 is representable there and not in signed shell arithmetic
M18|PT_LOAD p_offset and p_filesz|entry + 8 and entry + 32|8 each|little|from the base|00 00 00 00 00 00 00 40 each|each is 2^62 and decodes exactly; only their SUM passes 2^63 and comes back negative
MANIFEST
}

# Independent semantic checks for the seven recipes added to close the fixture
# matrix. These inspect the constructed bytes or readelf's report before the
# production observer is called, so a bad recipe cannot be blessed by a matching
# observer mistake.
step1_missing_fixture_oracle() {
    local id="$1" file="$2" size="$3" g01="$4" out kind roff rsize idx phoff poff
    case "$id" in
        F04)
            out=$("$READELF_BIN" -l "$file" 2>/dev/null)
            chk "$id/oracle-no-dynamic" "0" "$(printf '%s\n' "$out" | grep -c 'DYNAMIC')"
            ;;
        F05)
            out=$("$READELF_BIN" -d "$file" 2>/dev/null)
            chk "$id/oracle-soname" "1" "$(printf '%s\n' "$out" | grep -c '(SONAME)')"
            chk "$id/oracle-no-search-tag" "0" "$(printf '%s\n' "$out" | grep -Ec '\((RPATH|RUNPATH)\)')"
            ;;
        F10)
            out=$("$READELF_BIN" -d "$file" 2>/dev/null)
            chk "$id/oracle-rpath" "1" "$(printf '%s\n' "$out" | grep -c '(RPATH)')"
            chk "$id/oracle-runpath" "1" "$(printf '%s\n' "$out" | grep -c '(RUNPATH)')"
            ;;
        F11)
            out=$("$READELF_BIN" -d "$file" 2>/dev/null)
            chk "$id/oracle-two-rpaths" "2" "$(printf '%s\n' "$out" | grep -c '(RPATH)')"
            ;;
        F21)
            out=0
            while read -r kind roff _ _ rsize _; do
                [ "$kind" = "LOAD" ] || continue
                [ $(( roff + rsize )) -gt "$size" ] && out=$((out + 1))
            done < <("$READELF_BIN" -lW "$file" 2>/dev/null | sed -n '/^  LOAD/p')
            chk "$id/oracle-segment-past-file" "1" "$out"
            ;;
        F22)
            out=""
            while read -r kind roff _ _ rsize _; do
                [ "$kind" = "DYNAMIC" ] || continue
                out=$(( rsize % 16 ))
            done < <("$READELF_BIN" -lW "$file" 2>/dev/null | sed -n '/^  DYNAMIC/p')
            chk "$id/oracle-dynamic-size-remainder" "8" "$out"
            ;;
        F24|F25)
            # These two are deliberately malformed in a way readelf may simply
            # refuse to describe, so the oracle is the MANIFEST: the planted
            # bytes, read raw with `od`.
            #
            # The location is derived independently of the recipe. The recipe
            # found the entry with `elf_find_phdr`, which decodes the header with
            # the production reader; if that locator were wrong, poking and
            # reading at the same wrong place would agree and the fixture would
            # be blessed by the mistake it should expose. So the offset here
            # comes from readelf's own report of the UNMUTATED base: the table
            # start, and the index of the first LOAD among the entries it lists
            # in order.
            phoff=$("$READELF_BIN" -h "$g01" 2>/dev/null \
                | sed -n 's/.*Start of program headers: *\([0-9]*\).*/\1/p')
            idx=$("$READELF_BIN" -lW "$g01" 2>/dev/null \
                | awk '/^  [A-Z_]+ +0x/ { if ($1 == "LOAD" && !seen) { print n; seen = 1 } n++ }')
            if [ -z "$phoff" ] || [ -z "$idx" ]; then
                fail "$id/oracle-locate" "readelf did not describe the base's program header table"
                return 0
            fi
            poff=$(( phoff + idx * 56 ))
            note "$id/oracle-entry" "table at $phoff, first LOAD is entry $idx, so entry at $poff"
            if [ "$id" = "F24" ]; then
                out=$(od -An -tx1 -v -j $(( poff + 8 )) -N 8 "$file" 2>/dev/null | tr -d '[:space:]')
                chk "$id/oracle-planted-p_offset" "f0ffffffffffffff" "$out"
                # And the base does NOT already carry it, so the fixture is a
                # change rather than a coincidence.
                out=$(od -An -tx1 -v -j $(( poff + 8 )) -N 8 "$g01" 2>/dev/null | tr -d '[:space:]')
                if [ "$out" = "f0ffffffffffffff" ]; then
                    fail "$id/oracle-base-differs" "the base already carries the planted value"
                else
                    pass "$id/oracle-base-differs" "base p_offset is $out"
                fi
                cases=$((cases + 1))
            else
                # Both extents carry 2^62. Each on its own is a value the reader
                # accepts, which is what makes this fixture reach the extent
                # computation rather than being refused a step earlier like F24.
                chk "$id/oracle-planted-p_offset" "0000000000000040" \
                    "$(od -An -tx1 -v -j $(( poff + 8 )) -N 8 "$file" 2>/dev/null | tr -d '[:space:]')"
                chk "$id/oracle-planted-p_filesz" "0000000000000040" \
                    "$(od -An -tx1 -v -j $(( poff + 32 )) -N 8 "$file" 2>/dev/null | tr -d '[:space:]')"
                # Each planted value must be representable on its own, or this
                # fixture would be exercising F24's guard under a second name.
                if [ $(( 1 << 62 )) -gt 0 ]; then
                    pass "$id/oracle-each-value-representable" "2^62 decodes to $(( 1 << 62 ))"
                else
                    fail "$id/oracle-each-value-representable" "2^62 is not representable here"
                fi
                cases=$((cases + 1))
                # And their sum is not, which is the whole point.
                if [ $(( (1 << 62) + (1 << 62) )) -lt 0 ]; then
                    pass "$id/oracle-sum-overflows" "2^62 + 2^62 reads as $(( (1 << 62) + (1 << 62) ))"
                else
                    fail "$id/oracle-sum-overflows" "the sum did not overflow, so this fixture proves nothing"
                fi
                cases=$((cases + 1))
                out=$(od -An -tx1 -v -j $(( poff + 8 )) -N 8 "$g01" 2>/dev/null | tr -d '[:space:]')
                if [ "$out" = "0000000000000040" ]; then
                    fail "$id/oracle-base-differs" "the base already carries the planted value"
                else
                    pass "$id/oracle-base-differs" "base p_offset is $out"
                fi
                cases=$((cases + 1))
            fi
            ;;
        F23)
            out=$("$READELF_BIN" -dW "$file" 2>/dev/null || true)
            chk "$id/oracle-no-dt-null" "0" "$(printf '%s\n' "$out" | grep -c '(NULL)')"
            ;;
    esac
}

step1_suite() {
    local base="$SCRATCH/fixtures" expected_ids actual_ids
    mkdir -p -- "$base"

    section "step 1: the manifest and its anchors"

    # The manifest is auditable rather than merely called golden: every entry
    # records field, offset, width, byte order, original bytes, replacement bytes
    # and an exact specification citation.
    local mfile="$base/manifest.txt"
    step1_manifest > "$mfile"
    chk "manifest/columns-complete" "0" "$(awk -F'|' 'NF != 8' "$mfile" | wc -l | tr -d ' ')"
    chk "manifest/every-entry-cited" "0" "$(awk -F'|' '$8 ~ /^ *$/' "$mfile" | wc -l | tr -d ' ')"
    note "manifest/entries" "$(grep -c '^M' "$mfile")"

    # ------------------------------------------------------------- the donors ---
    local donor_prog=""
    if ! resolve_fixture_donor; then
        fail "step1/donors" "FIXTURE absent: no program donor on this host"
        return 1
    fi
    donor_prog="$FIXTURE_DONOR"
    note "step1/donor-program" "$donor_prog"

    section "step 1: layout confirmation"

    # G01, the lawful base: a program with PT_INTERP, PT_LOAD and PT_DYNAMIC, no
    # search-path tag, and e_type normalised to ET_EXEC. The recipe and the
    # reason it normalises rather than inherits live with the planting helpers,
    # since Step 2's bridge cuts its subjects from the same base.
    local G01="$base/G01.elf"
    if ! plant_fixture_base "$G01" "$donor_prog"; then
        fail "step1/base" "FIXTURE absent: the lawful base could not be cut"
        return 1
    fi

    # Layout confirmation, over the whole object: the base is emitted at the
    # manifest's own offsets and `readelf` must then report the intended value for
    # every field the manifest names. A manifest entry at the wrong offset puts
    # the value where readelf does not look, so either the parse fails or a
    # reported value disagrees.
    local rh
    if rh=$("$READELF_BIN" -h "$G01" 2>/dev/null); then
        pass "layout/base-parses" "readelf -h accepts the lawful base"
    else
        fail "layout/base-parses" "readelf rejected the base"
        return 1
    fi
    cases=$((cases + 1))
    chk "layout/class-reported"   "1" "$(printf '%s\n' "$rh" | grep -c 'ELF64')"
    chk "layout/data-reported"    "1" "$(printf '%s\n' "$rh" | grep -c "little endian")"
    chk "layout/machine-reported" "1" "$(printf '%s\n' "$rh" | grep -ci 'X86-64')"

    # Per-entry value cross-check: the bytes at each stated range, decoded at the
    # stated width and byte order, equal the number readelf reports for that
    # field. This is per-entry evidence that layout confirmation gives only in
    # aggregate.
    local b_phentsize r_phentsize b_phnum r_phnum
    b_phentsize=$(( 0x$(od -An -tx1 -v -j 54 -N 1 "$G01" | tr -d '[:space:]') ))
    r_phentsize=$(printf '%s\n' "$rh" | sed -n 's/.*Size of program headers: *\([0-9]*\).*/\1/p')
    chk "layout/phentsize-bytes-vs-readelf" "$r_phentsize" "$b_phentsize"
    b_phnum=$(( 0x$(od -An -tx1 -v -j 56 -N 1 "$G01" | tr -d '[:space:]') ))
    r_phnum=$(printf '%s\n' "$rh" | sed -n 's/.*Number of program headers: *\([0-9]*\).*/\1/p')
    chk "layout/phnum-bytes-vs-readelf" "$r_phnum" "$b_phnum"

    # Alternate pair, where this fixture set provides one: two lawful bases that
    # readelf reports as differing in exactly one field differ in bytes at exactly
    # that field's range. Provided for e_type; every other entry rests on layout
    # confirmation and the per-entry value check.
    local G01B="$base/G01-pie.elf"
    cp -- "$G01" "$G01B" && elf_poke "$G01B" 16 "0300"
    local diffcount
    diffcount=$(cmp -l "$G01" "$G01B" 2>/dev/null | wc -l | tr -d ' ')
    chk "layout/alternate-pair-e_type-single-range" "1" "$diffcount"
    chk "layout/alternate-pair-readelf-differs" "1" \
        "$("$READELF_BIN" -h "$G01B" 2>/dev/null | grep -c 'DYN')"

    section "step 1: the fixture matrix"

    # id | recipe | structural fields | both probe statuses and values | guard
    # Every row is a COMPLETE tuple. `@empty@` is distinct from `absent`, which
    # is exactly why the production tuple stores the latter as a value.
    local fixture_row fixture_columns
    local id recipe xstat xkind xdyn xint xtag xrstat xrval xistat xival guard f sz
    while IFS= read -r fixture_row; do
        [ -n "$fixture_row" ] || continue
        fixture_columns=$(awk -F'|' '{ print NF }' <<<"$fixture_row")
        IFS='|' read -r id recipe xstat xkind xdyn xint xtag xrstat xrval xistat xival guard \
            <<<"$fixture_row"
        chk "$id/fixture-columns" "12" "$fixture_columns"
        f="$base/$id.elf"
        plant_fixture "$id" "$recipe" "$f" "$G01" "$donor_prog" || continue

        sz=$(elf_size "$f")
        step1_missing_fixture_oracle "$id" "$f" "$sz" "$G01"
        elf_observe "$f" "$sz"
        elf_probe "$f" "$PATCHELF_BIN"
        chk "$id/structural_status" "$xstat" "${CPLX_ELF_OBS[structural_status]}"
        if [ "$xstat" = "ok" ]; then
            chk "$id/elf_kind"    "$xkind" "${CPLX_ELF_OBS[elf_kind]}"
            chk "$id/has_dynamic" "$xdyn"  "${CPLX_ELF_OBS[has_dynamic]}"
            chk "$id/has_interp"  "$xint"  "${CPLX_ELF_OBS[has_interp]}"
            chk "$id/tag_state"   "$xtag"  "${CPLX_ELF_OBS[tag_state]}"
        else
            # The structural-failure tuple is fully defined rather than left as
            # "the other fields are not touched", which is how a previous
            # object's reading survives into the next iteration.
            chk "$id/cleared-elf_kind"  "" "${CPLX_ELF_OBS[elf_kind]}"
            chk "$id/cleared-has_dyn"   "" "${CPLX_ELF_OBS[has_dynamic]}"
            chk "$id/cleared-tag_state" "" "${CPLX_ELF_OBS[tag_state]}"
        fi
        # The freeze bootstrap, kept because a later step may meet another value
        # no specification predicts. Its cost is honest: on the run that uses it
        # the expectation IS the observation, so that one comparison proves
        # nothing. It is a way to LEARN a literal, never a way to assert one, and
        # `fixtures/all-values-frozen` below asserts that no row is still in that
        # state now.
        if [ "$xrval" = "@freeze@" ]; then
            if [ "$id" != "F11" ] || [ -z "${CPLX_ELF_OBS[rpath_value]}" ]; then
                fail "$id/freeze" "only F11 may freeze a first-run, non-empty probe value"
            fi
            xrval="${CPLX_ELF_OBS[rpath_value]}"
            note "$id/freeze-vacuous" "this comparison is expectation:=observation, not an assertion"
        elif [ "$xrval" = "@empty@" ]; then
            xrval=""
        fi
        chk "$id/rpath_probe_status" "$xrstat" "${CPLX_ELF_OBS[rpath_probe_status]}"
        chk "$id/rpath_value"        "$xrval"  "${CPLX_ELF_OBS[rpath_value]}"
        chk "$id/interp_probe_status" "$xistat" "${CPLX_ELF_OBS[interp_probe_status]}"
        chk "$id/interp_value"        "$xival"  "${CPLX_ELF_OBS[interp_value]}"
        if [ "$id" = "F11" ]; then
            note "F11/duplicate-rpath-frozen" \
                "$xrval under $("$PATCHELF_BIN" --version 2>/dev/null | head -n 1)"
        fi
        note "$id/guard" "$guard"
        FIXTURE_PATHS="$FIXTURE_PATHS $id:$f"
    done <<'FIXTURES'
F01|prog|ok|exec|yes|yes|none|ok|@empty@|ok|/lib64/ld-linux-x86-64.so.2|the lawful base, no guard rejects
F02|pie|ok|dyn|yes|yes|none|ok|@empty@|ok|/lib64/ld-linux-x86-64.so.2|e_type reported as DYN
F03|lib|ok|dyn|yes|no|none|ok|@empty@|skipped|absent|a library: ET_DYN with no PT_INTERP
F04|nodynamic|ok|exec|no|yes|none|skipped|absent|ok|/lib64/ld-linux-x86-64.so.2|no PT_DYNAMIC, so the rpath probe is structurally inapplicable
F05|notabletag|ok|exec|yes|yes|none|ok|@empty@|ok|/lib64/ld-linux-x86-64.so.2|a SONAME passes the dynamic scan without becoming a search-path tag
F06|rpath|ok|exec|yes|yes|rpath|ok|/opt/cplx-probe/lib|ok|/lib64/ld-linux-x86-64.so.2|the dynamic scan, DT_RPATH
F07|runpath|ok|exec|yes|yes|runpath|ok|/opt/cplx-probe/lib|ok|/lib64/ld-linux-x86-64.so.2|the dynamic scan, DT_RUNPATH
F08|notable|ok|exec|no|no|none|skipped|absent|skipped|absent|e_phnum zero: the table-dependent guards do not apply
F09|rel|ok|unsupported|no|no|none|skipped|absent|skipped|absent|ET_REL, the only shape giving elf_kind unsupported
F10|bothtags|ok|exec|yes|yes|ambiguous|ok|/opt/cplx-probe/runpath|ok|/lib64/ld-linux-x86-64.so.2|both search-path tags, with RUNPATH preferred by patchelf
F11|duplicatetag|ok|exec|yes|yes|ambiguous|ok|/opt/cplx-probe/rpath-b|ok|/lib64/ld-linux-x86-64.so.2|two RPATH tags; the value is the FROZEN literal measured under patchelf 0.19.1
F12|badmagic|inconclusive|||||blocked|absent|blocked|absent|identification, magic
F13|badversion|inconclusive|||||blocked|absent|blocked|absent|identification, version
F14|elf32|inconclusive|||||blocked|absent|blocked|absent|identification, class
F15|bigendian|inconclusive|||||blocked|absent|blocked|absent|identification, data encoding
F16|badmachine|inconclusive|||||blocked|absent|blocked|absent|domain, e_machine
F17|pnxnum|inconclusive|||||blocked|absent|blocked|absent|e_phnum in ordinary form
F18|shortfile|inconclusive|||||blocked|absent|blocked|absent|whole-header presence
F19|badphentsize|inconclusive|||||blocked|absent|blocked|absent|program header entry size
F20|tablepast|inconclusive|||||blocked|absent|blocked|absent|table bounds
F21|segmentpast|inconclusive|||||blocked|absent|blocked|absent|segment bounds
F22|dynodd|inconclusive|||||blocked|absent|blocked|absent|dynamic entry sizing
F23|nonull|inconclusive|||||blocked|absent|blocked|absent|dynamic list termination
F24|offsetwrap|inconclusive|||||blocked|absent|blocked|absent|integer representability: a segment offset at 2^64-16 must be refused, not wrapped
F25|extentwrap|inconclusive|||||blocked|absent|blocked|absent|extent arithmetic: a representable size whose extent overflows when added
FIXTURES

    # Every expected value in the matrix is now a literal. This is the case that
    # makes "the freeze happened" a fact rather than a claim: an unfrozen row
    # compares the observation against itself and passes whatever the observer
    # produced, so the suite would stay green while asserting nothing about that
    # field. F11's literal was measured once, under patchelf 0.19.1, and is
    # recorded beside it; if a future patchelf resolves duplicate DT_RPATH tags
    # the other way, this must FAIL rather than quietly re-learn the new value.
    #
    # The rows are read from the heredoc REGION, and only the FIRST one. Two
    # earlier forms of this reader were wrong, both silently:
    #   * matching the bare `F##|` prefix also matched the probe-witness table
    #     below, which uses the same prefix with five columns instead of twelve,
    #     so a twenty-three row table counted thirty-one and `$9` was read from
    #     the wrong lines;
    #   * a `sed` range then re-opened on THIS function's own delimiter text and
    #     ran to end of file, giving thirty-one again for a different reason.
    # Hence the exit on the first close, and the anchored opener.
    fixture_rows() {
        awk '/^FIXTURES$/ { if (inblk) exit }
             inblk && /^F[0-9][0-9][|]/ { print }
             /^ *done <<.FIXTURES.$/ { inblk = 1 }' "${BASH_SOURCE[0]}"
    }
    unfrozen=$(fixture_rows | awk -F'|' '$9 == "@freeze@" || $11 == "@freeze@"' | wc -l | tr -d ' ')
    chk "fixtures/all-values-frozen" "0" "$unfrozen"

    # And the reader is proved to see exactly the rows it should, so a pattern
    # matching nothing, or matching too much, cannot report zero unfrozen rows
    # and look like success.
    chk "fixtures/table-readable" "25" "$(fixture_rows | wc -l | tr -d ' ')"

    # Set equality on the ids, not just a count. A count of twenty-five is
    # satisfied by a table with `F07` written twice and `F19` missing, and the
    # duplicate would silently run one guard twice while another ran not at all.
    expected_ids=$(for n in $(seq -w 1 25); do printf 'F%s\n' "$n"; done)
    actual_ids=$(fixture_rows | cut -d'|' -f1 | sort)
    if [ "$expected_ids" = "$actual_ids" ]; then
        pass "fixtures/ids-are-F01-to-F25" "no gap, no duplicate"
    else
        fail "fixtures/ids-are-F01-to-F25" \
            "missing [$(comm -23 <(printf '%s\n' "$expected_ids") <(printf '%s\n' "$actual_ids") | tr '\n' ' ')] unexpected [$(comm -13 <(printf '%s\n' "$expected_ids") <(printf '%s\n' "$actual_ids") | tr '\n' ' ')]"
    fi
    cases=$((cases + 1))
    section "step 1: the clearing rule"


    # The rule exists because a shell loop is where "not touched" becomes a
    # previous object's reading read as this one's evidence. Observing a good
    # object straight after a rejected one must leave nothing of the rejection.
    elf_observe "$base/F12.elf" "$(elf_size "$base/F12.elf")"
    chk "clearing/rejected-first" "inconclusive" "${CPLX_ELF_OBS[structural_status]}"
    elf_observe "$base/F06.elf" "$(elf_size "$base/F06.elf")"
    chk "clearing/good-after-rejected-status"    "ok"    "${CPLX_ELF_OBS[structural_status]}"
    chk "clearing/good-after-rejected-tag"       "rpath" "${CPLX_ELF_OBS[tag_state]}"
    chk "clearing/good-after-rejected-kind"      "exec"  "${CPLX_ELF_OBS[elf_kind]}"
    # And the converse: a rejected object straight after a good one carries none
    # of the good one's fields.
    elf_observe "$base/F12.elf" "$(elf_size "$base/F12.elf")"
    chk "clearing/rejected-after-good-kind"      "" "${CPLX_ELF_OBS[elf_kind]}"
    chk "clearing/rejected-after-good-tag"       "" "${CPLX_ELF_OBS[tag_state]}"
    chk "clearing/rejected-after-good-rpath-val" "absent" "${CPLX_ELF_OBS[rpath_value]}"

    section "step 1: probe witnesses"

    # Every behaviour the design and the classifier rely on has a NAMED witness
    # with its literal value. Coverage is categorical: honest failures elsewhere
    # do not substitute for one missing success.
    local pid ppath pstat pval istat
    while IFS='|' read -r pid want_rstat want_rval want_istat obligation; do
        [ -n "$pid" ] || continue
        ppath="$base/$pid.elf"
        elf_observe "$ppath" "$(elf_size "$ppath")"
        elf_probe "$ppath" "$PATCHELF_BIN"
        pstat="${CPLX_ELF_OBS[rpath_probe_status]}"
        pval="${CPLX_ELF_OBS[rpath_value]}"
        istat="${CPLX_ELF_OBS[interp_probe_status]}"
        chk "$pid/rpath_probe_status"  "$want_rstat" "$pstat"
        chk "$pid/interp_probe_status" "$want_istat" "$istat"
        [ "$want_rval" = "-" ] || chk "$pid/rpath_value" "$want_rval" "$pval"
        note "$pid/obligation" "$obligation"
    done <<'PROBES'
F01|ok||ok|an applicable no-tag rpath probe answers with an empty value
F06|ok|/opt/cplx-probe/lib|ok|DT_RPATH answers with its stored value
F07|ok|/opt/cplx-probe/lib|ok|DT_RUNPATH answers with its stored value, one query serving both tags
F10|ok|/opt/cplx-probe/runpath|ok|with both tags present patchelf prefers the DT_RUNPATH value
F04|skipped|-|ok|structure proves the rpath probe inapplicable
F03|ok|-|skipped|structure proves the interpreter probe inapplicable
F08|skipped|-|skipped|structure proves both probes inapplicable
F12|blocked|absent|blocked|an inconclusive structure blocks both axes
PROBES

    section "step 1: axis-local probe faults"

    # D01 and D02 are producer witnesses at this step and nowhere else: they run
    # the production probe with a controlled patchelf double so the fault is
    # produced deliberately rather than hoped for. Each is bounded in its own
    # subshell with a private command-search directory, and the shipped tool's
    # identity is re-established afterwards.
    local d_dir shipped_digest after_digest
    shipped_digest=$("$SHA256SUM_BIN" -- "$PATCHELF_BIN" | cut -d' ' -f1)
    for pid in D01 D02; do
        d_dir="$SCRATCH/double.$pid"
        plant_patchelf_double "$pid" "$d_dir" \
            || { fail "$pid/double" "FIXTURE absent: the $pid double could not be written"; continue; }
        (
            elf_observe "$base/F01.elf" "$(elf_size "$base/F01.elf")"
            elf_probe "$base/F01.elf" "$d_dir/patchelf"
            printf '%s|%s|%s|%s' \
                "${CPLX_ELF_OBS[rpath_probe_status]}" "${CPLX_ELF_OBS[rpath_value]}" \
                "${CPLX_ELF_OBS[interp_probe_status]}" "${CPLX_ELF_OBS[interp_value]}"
        ) > "$SCRATCH/$pid.out"
        rm -rf -- "$d_dir"
        IFS='|' read -r pstat pval istat ival < "$SCRATCH/$pid.out"
        if [ "$pid" = "D01" ]; then
            chk "D01/rpath_probe_status"  "failed" "$pstat"
            chk "D01/rpath_value_absent"  "absent" "$pval"
            chk "D01/interp_survives"     "ok"     "$istat"
            [ -n "$ival" ] && note "D01/interp_value" "$ival"
        else
            chk "D02/interp_probe_status" "failed" "$istat"
            chk "D02/rpath_survives"      "ok"     "$pstat"
        fi
    done
    # The shipped tool is unchanged, which is what makes the surviving-axis
    # values above evidence about the shipped binary rather than about a double.
    after_digest=$("$SHA256SUM_BIN" -- "$PATCHELF_BIN" | cut -d' ' -f1)
    chk "doubles/shipped-identity-restored" "$shipped_digest" "$after_digest"
}

# --------------------------------------------------------------- step 2 suite ---
# Step 2 is the ordered classifier: a decision over the Step 1 tuple, callable
# without running an install. Three layers answer three different questions and
# none of them stands in for another:
#
#   controlled rows  every case, every ordering and both $HOME overlaps, driven
#                    by tuples this file builds. Each is a COMPLETE,
#                    contract-valid tuple, checked before it is classified.
#   the bridge       real Step 1 observations crossing the seam, so the
#                    controlled inputs are shown to conform to what the producer
#                    actually emits. A controlled tuple and a controlled double
#                    are not counted as evidence for both production and
#                    consumption.
#   the inventory    the classifier over a real archive tree, where the selected
#                    set is the one the plan states once.

# The two targets every controlled row is judged against, and the value the
# Step 1 tag recipes plant. They are literals, and their SHAPES are asserted
# rather than assumed: the overlap rows exist because a $HOME target carries the
# same builder anchor the fresh-population test looks for, so a T_HOME that had
# lost it would leave those rows proving nothing at all.
STEP2_T_OUT="/opt/cplx/tools/python/root/usr/lib64:/opt/cplx/tools/git/root/usr/lib64"
STEP2_T_HOME="/home/builder/tools/python/root/usr/lib64:/home/builder/tools/git/root/usr/lib64"
STEP2_T_PROBE="/opt/cplx-probe/lib"
STEP2_ELF_MAGIC=$'\x7fELF'

# The tuple's field set, stated HERE rather than read from the installer's own
# CPLX_ELF_OBS_KEYS. Two independent statements compared by one case is what
# makes the exact-key-set rule an assertion; building the rows out of
# production's list would compare that list with itself.
STEP2_ROW_FIELDS="structural_status elf_kind has_dynamic has_interp tag_state \
rpath_probe_status rpath_value interp_probe_status interp_value"

# The case each controlled row produced, so the bridge can require agreement
# with a row rather than with a second copy of its expectation.
declare -A STEP2_CASE_OF=()

STEP2_LIT=""
# The row tokens, expanded on load. `@empty@` is the empty string and is
# distinct from `absent`, which is a value the tuple stores; the target tokens
# let a row say "this value IS the target" instead of repeating a long literal
# that would then have to match by eye.
step2_literal() {
    case "$1" in
        @empty@)   STEP2_LIT="" ;;
        @t-out@)   STEP2_LIT="$STEP2_T_OUT" ;;
        @t-home@)  STEP2_LIT="$STEP2_T_HOME" ;;
        @t-probe@) STEP2_LIT="$STEP2_T_PROBE" ;;
        *)         STEP2_LIT="$1" ;;
    esac
}

# step2_load_row FIELD...: clear the tuple, then populate it from one row.
#
# The array is cleared by REMOVING its keys rather than by writing empty strings
# into them. Writing empties would make "the row forgot this field" and "the row
# meant it empty" indistinguishable, which is the whole reason the exact-key-set
# rule exists in a shell: an unset associative-array key expands to the empty
# string at the point of use, so the classifier would branch on a value nobody
# wrote.
step2_load_row() {
    local k
    for k in "${!CPLX_ELF_OBS[@]}"; do
        unset "CPLX_ELF_OBS[$k]"
    done
    # shellcheck disable=SC2086  # the field list is deliberately word-split
    for k in $STEP2_ROW_FIELDS; do
        [ "$#" -gt 0 ] || return 0
        step2_literal "$1"
        CPLX_ELF_OBS["$k"]="$STEP2_LIT"
        shift
    done
    return 0
}

# step2_tuple_invariants NAME: the tuple contract, checked BEFORE the classifier
# is invoked, so a malformed row fails as a defective TEST rather than as a
# classifier result.
#
# The reason always begins with `TUPLE`, which is what lets a negative control
# require that exact refusal instead of being satisfied by any failure at all.
#
# The rules are the design's own: one structural status with a closed
# vocabulary, a fully defined structural-failure tuple, two independent probe
# statuses whose `skipped` has exactly two producers and no third, and a value
# that is `absent` unless its own probe answered.
step2_tuple_invariants() {
    local name="$1" expected actual missing extra
    local ss kind dyn itp tag rs rv is iv
    # shellcheck disable=SC2086  # the field list is deliberately word-split
    expected=$(printf '%s\n' $STEP2_ROW_FIELDS | sort)
    actual=$(printf '%s\n' "${!CPLX_ELF_OBS[@]}" | sort)
    if [ "$expected" != "$actual" ]; then
        missing=$(comm -23 <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") | tr '\n' ' ')
        extra=$(comm -13 <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") | tr '\n' ' ')
        fail "$name" "TUPLE key set: missing [$missing] unexpected [$extra]"
        return 1
    fi
    ss="${CPLX_ELF_OBS[structural_status]}"
    kind="${CPLX_ELF_OBS[elf_kind]}"
    dyn="${CPLX_ELF_OBS[has_dynamic]}"
    itp="${CPLX_ELF_OBS[has_interp]}"
    tag="${CPLX_ELF_OBS[tag_state]}"
    rs="${CPLX_ELF_OBS[rpath_probe_status]}"
    rv="${CPLX_ELF_OBS[rpath_value]}"
    is="${CPLX_ELF_OBS[interp_probe_status]}"
    iv="${CPLX_ELF_OBS[interp_value]}"

    case "$ss" in
        ok|inconclusive) ;;
        *) fail "$name" "TUPLE structural_status [$ss] is outside its vocabulary"; return 1 ;;
    esac

    # The structural-failure tuple is fully defined rather than left as "the
    # other fields are not touched": that is how a previous object's reading
    # survives into the next loop iteration and is read as this one's evidence.
    if [ "$ss" = "inconclusive" ]; then
        if [ -n "$kind$dyn$itp$tag" ]; then
            fail "$name" "TUPLE inconclusive leaves a structural field set: kind [$kind] dynamic [$dyn] interp [$itp] tag [$tag]"
            return 1
        fi
        if [ "$rs" != "blocked" ] || [ "$is" != "blocked" ]; then
            fail "$name" "TUPLE inconclusive must block both axes: rpath [$rs] interp [$is]"
            return 1
        fi
        if [ "$rv" != "absent" ] || [ "$iv" != "absent" ]; then
            fail "$name" "TUPLE inconclusive must leave both values absent: rpath [$rv] interp [$iv]"
            return 1
        fi
        return 0
    fi

    case "$kind" in
        exec|dyn|unsupported) ;;
        *) fail "$name" "TUPLE elf_kind [$kind] is outside its vocabulary"; return 1 ;;
    esac
    case "$dyn" in
        yes|no) ;;
        *) fail "$name" "TUPLE has_dynamic [$dyn] is not yes or no"; return 1 ;;
    esac
    case "$itp" in
        yes|no) ;;
        *) fail "$name" "TUPLE has_interp [$itp] is not yes or no"; return 1 ;;
    esac
    case "$tag" in
        none|rpath|runpath|ambiguous) ;;
        *) fail "$name" "TUPLE tag_state [$tag] is outside its vocabulary"; return 1 ;;
    esac
    if [ "$tag" != "none" ] && [ "$dyn" != "yes" ]; then
        fail "$name" "TUPLE a search-path tag needs a dynamic section: tag [$tag] has_dynamic [$dyn]"
        return 1
    fi
    # `blocked` has ONE producer and it is the structural failure handled above,
    # so a successful observation carrying it is a broken tuple rather than a
    # fourth probe state.
    case "$rs" in
        ok|skipped|failed) ;;
        *) fail "$name" "TUPLE rpath_probe_status [$rs] cannot follow a successful observation"; return 1 ;;
    esac
    case "$is" in
        ok|skipped|failed) ;;
        *) fail "$name" "TUPLE interp_probe_status [$is] cannot follow a successful observation"; return 1 ;;
    esac
    # `skipped` has exactly two producers, one per axis, and nothing else may
    # set it: it always means "this object has nothing to read", never "we did
    # not look". Both directions are checked, so neither a missing skip nor an
    # unearned one passes.
    if [ "$dyn" = "no" ] && [ "$rs" != "skipped" ]; then
        fail "$name" "TUPLE no dynamic section must skip the rpath probe, not [$rs]"
        return 1
    fi
    if [ "$dyn" = "yes" ] && [ "$rs" = "skipped" ]; then
        fail "$name" "TUPLE the rpath probe is skipped without its producer: has_dynamic [$dyn]"
        return 1
    fi
    if [ "$itp" = "no" ] && [ "$is" != "skipped" ]; then
        fail "$name" "TUPLE no interpreter must skip the interpreter probe, not [$is]"
        return 1
    fi
    if [ "$itp" = "yes" ] && [ "$is" = "skipped" ]; then
        fail "$name" "TUPLE the interpreter probe is skipped without its producer: has_interp [$itp]"
        return 1
    fi
    # A value exists exactly when its own probe answered. `absent` is a value
    # rather than an unset key precisely so this is checkable.
    if [ "$rs" = "ok" ] && [ "$rv" = "absent" ]; then
        fail "$name" "TUPLE an answering rpath probe has no value"
        return 1
    fi
    if [ "$rs" != "ok" ] && [ "$rv" != "absent" ]; then
        fail "$name" "TUPLE rpath_value [$rv] survives a probe that did not answer: [$rs]"
        return 1
    fi
    if [ "$is" = "ok" ] && [ "$iv" = "absent" ]; then
        fail "$name" "TUPLE an answering interpreter probe has no value"
        return 1
    fi
    if [ "$is" != "ok" ] && [ "$iv" != "absent" ]; then
        fail "$name" "TUPLE interp_value [$iv] survives a probe that did not answer: [$is]"
        return 1
    fi
    return 0
}

# The controlled rows, in a function rather than inline, so the loop that runs
# them and the cases that audit the table read the SAME text. Step 1 scraped its
# own source with awk because its rows were inline, and two versions of that
# reader were silently wrong before the third worked.
#
# Thirteen columns: the id, the nine tuple fields in their fixed order, the
# target the row is judged against, the expected case, and what the row fixes.
# Every row is a complete tuple: no field is omitted on the grounds that the
# case under test does not read it.
step2_rows() {
    cat <<'ROWS'
C01|inconclusive|@empty@|@empty@|@empty@|@empty@|blocked|absent|blocked|absent|@t-out@|1|case 1: the structural-failure tuple, the one fault that blocks both axes
C02|ok|exec|no|yes|none|skipped|absent|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|2|case 2: no PT_DYNAMIC, so there is no search path to set
C03|ok|exec|yes|yes|rpath|ok|@t-out@|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|3|case 3: the exact target under DT_RPATH is already correct
C04|ok|dyn|yes|no|none|ok|@empty@|skipped|absent|@t-out@|4|case 4: ET_DYN with no PT_INTERP is the library population
C05|ok|exec|yes|yes|runpath|ok|@t-out@|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|5|case 5: the exact target under DT_RUNPATH is a migration
C06|ok|exec|yes|yes|none|ok|/home/builder/cplx/tools/python/root/usr/lib64|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|6|case 6: a builder-anchored program on a prefix outside the home tree
C07|ok|exec|yes|yes|rpath|ok|/usr/lib64/mysql|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|7|case 7: an RPM-extracted program with a distribution rpath
C08|ok|exec|yes|yes|runpath|ok|@t-home@|ok|/lib64/ld-linux-x86-64.so.2|@t-home@|5|the first $HOME overlap: a v0.26.0 tuple under a home prefix is a migration, not a fresh relocation
C09|ok|exec|yes|yes|rpath|ok|@t-home@|ok|/lib64/ld-linux-x86-64.so.2|@t-home@|3|the second $HOME overlap: a this-version tuple under a home prefix is already correct, not a rewrite
C10|ok|exec|yes|yes|rpath|ok|/opt/vendor/lib|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|7|a successful DT_RPATH observation that is neither the target nor builder-anchored
C11|ok|exec|yes|yes|runpath|ok|/opt/vendor/lib|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|7|a successful DT_RUNPATH observation that is neither the target nor builder-anchored
C12|ok|exec|yes|yes|runpath|ok|/home/builder/cplx/tools/lib64|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|6|a builder-anchored DT_RUNPATH program is fresh, since case 5 tests the value and not the tag alone
C13|ok|exec|yes|yes|ambiguous|ok|/opt/cplx-probe/runpath|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|1|ambiguity is a successful observation and still fails the rpath axis closed
C14|ok|dyn|yes|no|ambiguous|ok|/opt/cplx-probe/runpath|skipped|absent|@t-out@|1|case 1 precedes case 4: an ambiguous library is not selected
C15|ok|exec|no|no|none|skipped|absent|skipped|absent|@t-out@|2|both skipped producers at once, the e_phnum-zero shape
C16|ok|exec|yes|yes|none|failed|absent|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|1|the rpath-axis-local fault, with the interpreter axis surviving with its value
C17|ok|exec|yes|yes|none|ok|@empty@|failed|absent|@t-out@|7|the interpreter-axis-local fault, with the rpath axis surviving and answering from its own value
C18|ok|dyn|yes|no|rpath|ok|@t-out@|skipped|absent|@t-out@|3|case 3 precedes case 4: an already-correct library is not rewritten again
C19|ok|dyn|yes|no|runpath|ok|@t-out@|skipped|absent|@t-out@|4|case 4 precedes case 5: a target-valued DT_RUNPATH on a library is the library population
C20|ok|dyn|yes|no|none|ok|/home/builder/cplx/tools/lib|skipped|absent|@t-out@|4|case 4 precedes case 6: a builder-anchored library is the library population
C21|ok|unsupported|yes|no|none|ok|/opt/vendor/lib|skipped|absent|@t-out@|7|an unsupported kind is not the ET_DYN library population
C22|ok|unsupported|yes|no|none|ok|/home/builder/cplx/tools/lib|skipped|absent|@t-out@|7|an unsupported kind is not a program, so the builder anchor of case 6 does not reach it
C23|ok|exec|yes|yes|rpath|ok|/home/builder/cplx/tools/python/root/usr/lib64|ok|/lib64/ld-linux-x86-64.so.2|@t-out@|6|a builder-anchored DT_RPATH program is fresh, since case 3 tests the value and not the tag alone
C24|ok|unsupported|yes|no|runpath|ok|@t-out@|skipped|absent|@t-out@|7|an unsupported kind is not a program, so the exact target under DT_RUNPATH does not make it a migration
ROWS
}

# The negative controls. Each mutates ONE contract-valid tuple and requires the
# invariant checker to refuse it on a `TUPLE` reason. Without these the checker
# could have quietly stopped detecting anything and every row would still pass.
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_valid_row() {
    step2_load_row ok exec yes yes none ok @empty@ ok /lib64/ld-linux-x86-64.so.2
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_missing_key() {
    step2_ctl_valid_row
    unset "CPLX_ELF_OBS[interp_probe_status]"
    step2_tuple_invariants "ctl/missing-key"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_extra_key() {
    step2_ctl_valid_row
    # shellcheck disable=SC2154  # deliberately plants an extra associative-array key
    CPLX_ELF_OBS[rpath_tag_state]="rpath"
    step2_tuple_invariants "ctl/extra-key"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_blocked_beside_ok() {
    step2_ctl_valid_row
    CPLX_ELF_OBS[rpath_probe_status]="blocked"
    CPLX_ELF_OBS[rpath_value]="absent"
    step2_tuple_invariants "ctl/blocked-beside-ok"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_unearned_skip() {
    step2_ctl_valid_row
    CPLX_ELF_OBS[rpath_probe_status]="skipped"
    CPLX_ELF_OBS[rpath_value]="absent"
    step2_tuple_invariants "ctl/unearned-skip"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_missing_skip() {
    step2_ctl_valid_row
    CPLX_ELF_OBS[has_dynamic]="no"
    step2_tuple_invariants "ctl/missing-skip"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_value_without_answer() {
    step2_ctl_valid_row
    CPLX_ELF_OBS[interp_probe_status]="failed"
    step2_tuple_invariants "ctl/value-without-answer"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_surviving_field() {
    step2_load_row inconclusive exec @empty@ @empty@ @empty@ blocked absent blocked absent
    step2_tuple_invariants "ctl/surviving-field"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_tag_without_dynamic() {
    step2_load_row ok exec no yes rpath skipped absent ok /lib64/ld-linux-x86-64.so.2
    step2_tuple_invariants "ctl/tag-without-dynamic"
}

step2_controlled_suite() {
    local row cols id ss kind dyn itp tag rs rv is iv tgt want guard
    local prod harness expected_ids actual_ids n

    section "step 2: the tuple contract"

    # Production's key list and this file's, compared once. Everything else in
    # this suite rests on the two agreeing, and neither is derived from the
    # other.
    # shellcheck disable=SC2086  # both lists are deliberately word-split
    prod=$(printf '%s\n' $CPLX_ELF_OBS_KEYS | sort | tr '\n' ' ')
    # shellcheck disable=SC2086  # both lists are deliberately word-split
    harness=$(printf '%s\n' $STEP2_ROW_FIELDS | sort | tr '\n' ' ')
    chk "tuple/key-set-agrees-with-production" "$prod" "$harness"

    # The overlap rows are only evidence if the two targets have the shapes they
    # are named for. A T_HOME without a builder anchor would make C08 and C09
    # ordinary rows proving nothing about precedence, and the suite would stay
    # green while the property went untested.
    case "$STEP2_T_HOME" in
        */home/*) pass "targets/home-target-is-anchored" "$STEP2_T_HOME" ;;
        *) fail "targets/home-target-is-anchored" "the home target carries no builder anchor, so the overlap rows prove nothing" ;;
    esac
    cases=$((cases + 1))
    case "$STEP2_T_OUT" in
        */home/*) fail "targets/outside-target-is-not-anchored" "the outside target carries a builder anchor" ;;
        *) pass "targets/outside-target-is-not-anchored" "$STEP2_T_OUT" ;;
    esac
    cases=$((cases + 1))
    if [ "$STEP2_T_OUT" != "$STEP2_T_HOME" ]; then
        pass "targets/differ" "two distinct targets"
    else
        fail "targets/differ" "the two targets are the same string"
    fi
    cases=$((cases + 1))

    section "step 2: the invariant checker refuses"

    control "control/tuple-missing-key"        "TUPLE" step2_ctl_missing_key
    control "control/tuple-extra-key"          "TUPLE" step2_ctl_extra_key
    control "control/tuple-blocked-beside-ok"  "TUPLE" step2_ctl_blocked_beside_ok
    control "control/tuple-unearned-skip"      "TUPLE" step2_ctl_unearned_skip
    control "control/tuple-missing-skip"       "TUPLE" step2_ctl_missing_skip
    control "control/tuple-value-no-answer"    "TUPLE" step2_ctl_value_without_answer
    control "control/tuple-surviving-field"    "TUPLE" step2_ctl_surviving_field
    control "control/tuple-tag-no-dynamic"     "TUPLE" step2_ctl_tag_without_dynamic

    section "step 2: the ordered classifier over controlled tuples"

    while IFS= read -r row; do
        [ -n "$row" ] || continue
        cols=$(awk -F'|' '{ print NF }' <<<"$row")
        IFS='|' read -r id ss kind dyn itp tag rs rv is iv tgt want guard <<<"$row"
        chk "$id/row-columns" "13" "$cols"
        step2_load_row "$ss" "$kind" "$dyn" "$itp" "$tag" "$rs" "$rv" "$is" "$iv"
        if ! step2_tuple_invariants "$id/tuple"; then
            cases=$((cases + 1))
            continue
        fi
        pass "$id/tuple" "complete and contract-valid"
        cases=$((cases + 1))
        step2_literal "$tgt"
        elf_classify "$STEP2_LIT"
        chk "$id/case" "$want" "$CPLX_ELF_CASE"
        STEP2_CASE_OF["$id"]="$CPLX_ELF_CASE"
        note "$id/guard" "$guard"
    done < <(step2_rows)

    section "step 2: the row table audits itself"

    # A count of twenty-four is satisfied by a table with one row written twice
    # and another missing, and the duplicate would silently exercise one
    # ordering twice while another ran not at all.
    chk "rows/row-count" "24" "$(step2_rows | grep -c .)"
    expected_ids=$(for n in $(seq -w 1 24); do printf 'C%s\n' "$n"; done)
    actual_ids=$(step2_rows | cut -d'|' -f1 | sort)
    if [ "$expected_ids" = "$actual_ids" ]; then
        pass "rows/ids-are-C01-to-C24" "no gap, no duplicate"
    else
        fail "rows/ids-are-C01-to-C24" \
            "missing [$(comm -23 <(printf '%s\n' "$expected_ids") <(printf '%s\n' "$actual_ids") | tr '\n' ' ')] unexpected [$(comm -13 <(printf '%s\n' "$expected_ids") <(printf '%s\n' "$actual_ids") | tr '\n' ' ')]"
    fi
    cases=$((cases + 1))

    # Every case reachable, and every row GROUP the plan names present, asserted
    # over the table rather than claimed in a comment. A group that lost its last
    # row would otherwise leave the suite green and the property untested.
    for n in 1 2 3 4 5 6 7; do
        chk "rows/case-$n-expected-somewhere" "yes" \
            "$(step2_rows | awk -F'|' -v c="$n" '$12 == c { f = 1 } END { print (f ? "yes" : "no") }')"
    done
    chk "rows/home-overlaps" "2" \
        "$(step2_rows | awk -F'|' '$11 == "@t-home@"' | grep -c .)"
    chk "rows/successful-tag-rpath" "yes" \
        "$(step2_rows | awk -F'|' '$6 == "rpath" { f = 1 } END { print (f ? "yes" : "no") }')"
    chk "rows/successful-tag-runpath" "yes" \
        "$(step2_rows | awk -F'|' '$6 == "runpath" { f = 1 } END { print (f ? "yes" : "no") }')"
    chk "rows/ambiguity" "yes" \
        "$(step2_rows | awk -F'|' '$6 == "ambiguous" { f = 1 } END { print (f ? "yes" : "no") }')"
    chk "rows/structural-inconclusive" "yes" \
        "$(step2_rows | awk -F'|' '$2 == "inconclusive" { f = 1 } END { print (f ? "yes" : "no") }')"
    chk "rows/skipped-producer-rpath" "yes" \
        "$(step2_rows | awk -F'|' '$4 == "no" && $7 == "skipped" { f = 1 } END { print (f ? "yes" : "no") }')"
    chk "rows/skipped-producer-interp" "yes" \
        "$(step2_rows | awk -F'|' '$5 == "no" && $9 == "skipped" { f = 1 } END { print (f ? "yes" : "no") }')"
    # The pair a four-token checklist does not require: each axis failing ALONE,
    # with the other axis answering and keeping its value.
    chk "rows/axis-local-rpath-failure" "yes" \
        "$(step2_rows | awk -F'|' '$7 == "failed" && $9 == "ok" && $10 != "absent" { f = 1 } END { print (f ? "yes" : "no") }')"
    chk "rows/axis-local-interp-failure" "yes" \
        "$(step2_rows | awk -F'|' '$9 == "failed" && $7 == "ok" && $8 != "absent" { f = 1 } END { print (f ? "yes" : "no") }')"
    # The two program-boundary exclusions, kept as their own group so neither
    # can be deleted with the suite still green. Cases 5 and 6 are program
    # populations, so an unsupported kind reaches case 7 whichever of their two
    # values it carries.
    chk "rows/unsupported-is-not-a-fresh-program" "yes" \
        "$(step2_rows | awk -F'|' '$3 == "unsupported" && $8 ~ /\/home\// && $12 == 7 { f = 1 } END { print (f ? "yes" : "no") }')"
    chk "rows/unsupported-is-not-a-migration" "yes" \
        "$(step2_rows | awk -F'|' '$3 == "unsupported" && $6 == "runpath" && $8 == $11 && $12 == 7 { f = 1 } END { print (f ? "yes" : "no") }')"
    return 0
}

# The producer-to-consumer bridge. Step 1 proves a tuple is PRODUCED and the
# rows above prove one is CONSUMED; neither shows that the controlled inputs
# conform to the contract the producer actually emits, and that is the gap
# neither layer can see alone.
#
# So representative real Step 1 observations cross the seam. Each is named by
# its Step 1 fixture id and planted by the SAME recipe, each carries the
# complete surviving-axis value, and each must land on the case its named
# controlled row produced. A disagreement means the rows have drifted from the
# contract, which is exactly what nothing else here would notice.
#
# Seven columns: the bridge id, the Step 1 subject, the double to probe it with
# or `-`, the target, the expected case, the controlled row it must agree with,
# and what the crossing establishes.
step2_bridge_rows() {
    cat <<'BROWS'
B01|F03|-|@t-out@|4|C04|a library, ET_DYN with no PT_INTERP
B02|F04|-|@t-out@|2|C02|no PT_DYNAMIC, so the rpath probe is structurally inapplicable
B03|F06|-|@t-probe@|3|C03|DT_RPATH holding exactly the target value
B04|F06|-|@t-out@|7|C10|the same DT_RPATH object against a target it does not hold
B05|F07|-|@t-probe@|5|C05|DT_RUNPATH holding exactly the target value
B06|F07|-|@t-out@|7|C11|the same DT_RUNPATH object against a target it does not hold
B07|F10|-|@t-out@|1|C13|both search-path tags, an ambiguity that fails the rpath axis closed
B08|F16|-|@t-out@|1|C01|a structural rejection, outside the supported domain
B09|F01|D01|@t-out@|1|C16|the rpath probe fault, with the interpreter axis surviving
B10|F01|D02|@t-out@|7|C17|the interpreter probe fault, with the rpath axis surviving
BROWS
}

step2_bridge_suite() {
    local base="$SCRATCH/bridge" G01 fid frec planted=0 planted_ids=""
    local row bid subject dbl tgt want twin why f sz d_dir
    local shipped_digest after_digest twin_case

    section "step 2: the producer-to-consumer bridge"

    mkdir -p -- "$base"
    if ! resolve_fixture_donor; then
        fail "bridge/donor" "FIXTURE absent: no program donor on this host"
        cases=$((cases + 1))
        return 1
    fi
    note "bridge/donor-program" "$FIXTURE_DONOR"
    G01="$base/G01.elf"
    if ! plant_fixture_base "$G01" "$FIXTURE_DONOR"; then
        fail "bridge/base" "FIXTURE absent: the lawful base could not be cut"
        cases=$((cases + 1))
        return 1
    fi
    shipped_digest=$("$SHA256SUM_BIN" -- "$PATCHELF_BIN" | cut -d' ' -f1)

    # Every distinct subject the rows name, planted once by the Step 1 recipe of
    # that id. The recipes are not restated here: they are the same function.
    while IFS='|' read -r fid frec; do
        [ -n "$fid" ] || continue
        plant_fixture "$fid" "$frec" "$base/$fid.elf" "$G01" "$FIXTURE_DONOR" || continue
        planted=$((planted + 1))
        planted_ids="$planted_ids $fid"
    done <<'BFIX'
F01|prog
F03|lib
F04|nodynamic
F06|rpath
F07|runpath
F10|bothtags
F16|badmachine
BFIX
    chk "bridge/subjects-planted" "7" "$planted"

    while IFS= read -r row; do
        [ -n "$row" ] || continue
        IFS='|' read -r bid subject dbl tgt want twin why <<<"$row"
        f="$base/$subject.elf"
        # A subject whose recipe FAILED leaves a half-cut file behind, so file
        # existence is not the test: the row is skipped on the planting record
        # instead, and says so, rather than reporting a case mismatch whose real
        # cause was two sections earlier.
        case " $planted_ids " in
            *" $subject "*) ;;
            *) fail "$bid/fixture" "FIXTURE absent: $subject was not planted"
               cases=$((cases + 1))
               continue ;;
        esac
        sz=$(elf_size "$f")
        step2_literal "$tgt"
        tgt="$STEP2_LIT"
        if [ "$dbl" = "-" ]; then
            elf_observe "$f" "$sz"
            elf_probe "$f" "$PATCHELF_BIN"
        else
            # The double is passed to the production probe BY PATH, which is how
            # elf_probe takes its tool, so no command search is involved and the
            # fault is produced deliberately rather than hoped for. Step 1 ran
            # the same doubles inside a subshell; here the tuple has to survive
            # into the classifier, so the isolation is the explicit path instead.
            d_dir="$SCRATCH/double.$bid"
            if ! plant_patchelf_double "$dbl" "$d_dir"; then
                fail "$bid/double" "FIXTURE absent: the $dbl double could not be written"
                cases=$((cases + 1))
                continue
            fi
            elf_observe "$f" "$sz"
            elf_probe "$f" "$d_dir/patchelf"
            rm -rf -- "$d_dir"
        fi
        # The producer's own tuple, held to the SAME contract the controlled
        # rows are held to. This is the conformance half of the bridge: a row
        # set that had drifted into a shape the observer cannot emit fails here
        # rather than passing quietly on both sides of the seam.
        if ! step2_tuple_invariants "$bid/producer-tuple"; then
            cases=$((cases + 1))
            continue
        fi
        pass "$bid/producer-tuple" "$subject observed into a contract-valid tuple"
        cases=$((cases + 1))
        elf_classify "$tgt"
        chk "$bid/case" "$want" "$CPLX_ELF_CASE"
        twin_case="${STEP2_CASE_OF[$twin]:-}"
        if [ -z "$twin_case" ]; then
            fail "$bid/agrees-with-$twin" "the controlled row $twin produced no case to agree with"
            cases=$((cases + 1))
        else
            chk "$bid/agrees-with-$twin" "$twin_case" "$CPLX_ELF_CASE"
        fi
        note "$bid/crossing" "$subject: $why"
    done < <(step2_bridge_rows)

    # The shipped tool is unchanged, which is what makes the surviving-axis
    # values above evidence about the shipped binary rather than about a double.
    after_digest=$("$SHA256SUM_BIN" -- "$PATCHELF_BIN" | cut -d' ' -f1)
    chk "bridge/shipped-identity-restored" "$shipped_digest" "$after_digest"

    # Both producer faults crossed, and both target comparisons exercised in
    # both directions, asserted over the table so a deleted row is a failure
    # rather than a silently narrower bridge.
    chk "bridge/row-count" "10" "$(step2_bridge_rows | grep -c .)"
    chk "bridge/probe-faults" "2" "$(step2_bridge_rows | awk -F'|' '$3 != "-"' | grep -c .)"
    chk "bridge/target-matches" "2" "$(step2_bridge_rows | awk -F'|' '$4 == "@t-probe@"' | grep -c .)"
    return 0
}

# The inventory check: the classifier over a real archive tree, with no install.
# That is what the step exists to make possible, and Step 6's acceptance reuses
# it.
#
# The oracle is READ, never derived. Review round 2 showed what deriving costs:
# a missing expected git object, an unrecorded one, an already-converted library
# set and a residual program answering case 1 all pass a rule stated over the
# tree being checked. Round 3 then showed that reading half an oracle is its own
# defect: the record was accepted at any size, and a walked library the record
# did not name was skipped without a word, so the comparison ran one way only.
#
# Both directions are collected now, and the collected state is asserted by a
# function the controls call as well, so a rule that has quietly stopped
# detecting anything fails a control rather than passing on a clean tree.
#
# What each population owes:
#
#   the flagged libraries    exactly the recorded set, walked and case 4.
#                            Case 3 is refused: it is the state of a tree this
#                            version already converted, which is not the tree
#                            the criterion names.
#   every walked library     case 4, whether or not the record names it. This is
#                            the walk-to-record direction with the meaning the
#                            measurement supports, and it is where this file
#                            departs from round 3's instruction. See below.
#   the python program       the recorded path, walked and selected, by name.
#   the git programs         the recorded paths as a SET against the objects
#                            walked under the recorded git roots, so a missing
#                            member and an unrecorded member each fail.
#   every other program      case 7 exactly, not merely "not selected".
#
# THE ONE DEPARTURE, stated where it lives rather than in a round summary.
# Round 3 asked that an unrecorded WALKED library fail. It does not, and the
# measurement is why: develop#24 reports "110 of 388 still flagged, all of them
# toolchain libraries probed in isolation, 55 per root and none from the venv".
# The 110 are the FLAGGED subset, not the archive's library population, so the
# venv and lib-dynload libraries are unrecorded by construction and equality
# would fail on every one of them. What the finding was actually protecting,
# that a walked library may not be silently skipped, is kept in full: every
# walked library must answer case 4, and the unrecorded ones are counted and
# named in the output.

# The develop#24 figure, from the probe run of 2026-08-08: 110 flagged of 388
# inventoried ELFs. The record must hold exactly this many distinct library
# paths, so a truncated or padded record fails the reader rather than the tree.
STEP2_INV_LIB_COUNT=110

STEP2_INV_LIBS=""
STEP2_INV_GITS=""
STEP2_INV_PYTHON=""
STEP2_INV_WHY=""

# step2_inventory_oracle FILE: read the recorded inventory into three sets.
#
# Rows are `population|path`, `#` starts a comment, and the populations are
# closed. A row this reader cannot classify fails the oracle rather than being
# skipped, since a typo would otherwise shrink the expected set in silence, and
# the library count and its distinctness are checked here rather than left to
# whoever writes the file.
step2_inventory_oracle() {
    local file="$1" pop path bad="" n distinct
    STEP2_INV_LIBS=""; STEP2_INV_GITS=""; STEP2_INV_PYTHON=""; STEP2_INV_WHY=""
    while IFS='|' read -r pop path; do
        case "$pop" in ''|\#*) continue ;; esac
        case "$pop" in
            library) STEP2_INV_LIBS="$STEP2_INV_LIBS $path" ;;
            git)     STEP2_INV_GITS="$STEP2_INV_GITS $path" ;;
            python)  STEP2_INV_PYTHON="$path" ;;
            *)       bad="$bad $pop" ;;
        esac
    done < "$file"
    if [ -n "$bad" ]; then
        STEP2_INV_WHY="ORACLE unknown population(s):$bad"
        return 1
    fi
    if [ -z "$STEP2_INV_PYTHON" ]; then
        STEP2_INV_WHY="ORACLE no python row"
        return 1
    fi
    if [ -z "$STEP2_INV_GITS" ]; then
        STEP2_INV_WHY="ORACLE no git row"
        return 1
    fi
    n=$(printf '%s' "$STEP2_INV_LIBS" | wc -w)
    if [ "$n" -ne "$STEP2_INV_LIB_COUNT" ]; then
        STEP2_INV_WHY="ORACLE library count is $n, and the develop#24 record holds $STEP2_INV_LIB_COUNT"
        return 1
    fi
    # shellcheck disable=SC2086  # word splitting is required to count distinct oracle members
    distinct=$(printf '%s\n' $STEP2_INV_LIBS | sort -u | wc -l)
    if [ "$distinct" -ne "$n" ]; then
        STEP2_INV_WHY="ORACLE library paths are not distinct: $n rows, $distinct paths"
        return 1
    fi
    return 0
}

# step2_in_set NEEDLE HAYSTACK: whole-word membership over a space-separated
# list. Written out because a substring test would make `bin/git` match
# `bin/git-shell` and quietly accept an object nobody recorded.
step2_in_set() {
    case " $2 " in
        *" $1 "*) return 0 ;;
    esac
    return 1
}

# step2_missing_members RECORDED SEEN: the recorded members the walk did not
# find, space separated and empty when there are none.
step2_missing_members() {
    local p out=""
    # shellcheck disable=SC2086  # both lists are deliberately word-split
    for p in $1; do
        step2_in_set "$p" "$2" || out="$out $p"
    done
    printf '%s' "$out"
}

# The collected walk state, in globals rather than in locals, so the controls
# below drive the SAME assertion function the walk drives. A control that
# exercised a second copy of these rules would prove nothing about the gate.
STEP2_INV_SEEN_LIBS=""
STEP2_INV_WALKED_LIBS=""
STEP2_INV_LIB_BAD=""
STEP2_INV_WALKED_LIB_BAD=""
STEP2_INV_SEEN_GITS=""
STEP2_INV_GIT_BAD=""
STEP2_INV_OTHER_BAD=""
STEP2_INV_OTHER_UNCLASSIFIED=""
STEP2_INV_OTHERS=0
STEP2_INV_PYTHON_SEEN=0
STEP2_INV_PYTHON_CASE=""

step2_inventory_reset() {
    STEP2_INV_SEEN_LIBS=""
    STEP2_INV_WALKED_LIBS=""
    STEP2_INV_LIB_BAD=""
    STEP2_INV_WALKED_LIB_BAD=""
    STEP2_INV_SEEN_GITS=""
    STEP2_INV_GIT_BAD=""
    STEP2_INV_OTHER_BAD=""
    STEP2_INV_OTHER_UNCLASSIFIED=""
    STEP2_INV_OTHERS=0
    STEP2_INV_NONPROGRAMS=0
    STEP2_INV_NONPROGRAM_IDS=""
    STEP2_INV_PYTHON_SEEN=0
    STEP2_INV_PYTHON_CASE=""
}

# step2_inventory_assert: judge the collected state against the recorded oracle.
#
# Every reason begins with `INVENTORY`, which is what lets a negative control
# require this exact refusal rather than being satisfied by any failure. The
# `chk` helper is deliberately not used for the judgements a control binds to:
# its "want [] got [...]" reason cannot carry a token a control can name.
step2_inventory_assert() {
    local missing_libs missing_gits unrecorded n
    missing_libs=$(step2_missing_members "$STEP2_INV_LIBS" "$STEP2_INV_SEEN_LIBS")
    missing_gits=$(step2_missing_members "$STEP2_INV_GITS" "$STEP2_INV_SEEN_GITS")
    unrecorded=$(step2_missing_members "$STEP2_INV_WALKED_LIBS" "$STEP2_INV_LIBS")

    if [ -z "$missing_libs" ]; then
        pass "inventory/recorded-libraries-present" "$(printf '%s' "$STEP2_INV_LIBS" | wc -w) recorded, all walked"
    else
        fail "inventory/recorded-libraries-present" "INVENTORY recorded but not walked:$missing_libs"
    fi
    cases=$((cases + 1))

    if [ -z "$STEP2_INV_LIB_BAD" ]; then
        pass "inventory/recorded-libraries-case-4" "every recorded library is the library population"
    else
        fail "inventory/recorded-libraries-case-4" "INVENTORY recorded library not case 4:$STEP2_INV_LIB_BAD"
    fi
    cases=$((cases + 1))

    # The walk-to-record direction. Every library the walk found is judged,
    # recorded or not, which is what stops one being skipped in silence.
    if [ -z "$STEP2_INV_WALKED_LIB_BAD" ]; then
        pass "inventory/walked-libraries-case-4" "$(printf '%s' "$STEP2_INV_WALKED_LIBS" | wc -w) walked, all case 4"
    else
        fail "inventory/walked-libraries-case-4" "INVENTORY walked library not case 4:$STEP2_INV_WALKED_LIB_BAD"
    fi
    cases=$((cases + 1))

    # Reported rather than failed, and the reason is measured: develop#24 flagged
    # 110 of 388, "55 per root and none from the venv", so the archive's library
    # population is larger than the recorded set by construction.
    n=$(printf '%s' "$unrecorded" | wc -w)
    note "inventory/unrecorded-libraries" "$n walked libraries the record does not name${unrecorded:+ ->$unrecorded}"

    if [ "$STEP2_INV_PYTHON_SEEN" -eq 1 ]; then
        pass "inventory/python-present-by-name" "$STEP2_INV_PYTHON"
    else
        fail "inventory/python-present-by-name" "INVENTORY the recorded python object was not walked: $STEP2_INV_PYTHON"
    fi
    cases=$((cases + 1))
    case "$STEP2_INV_PYTHON_CASE" in
        3|5|6) pass "inventory/python-selected" "case $STEP2_INV_PYTHON_CASE" ;;
        "")    fail "inventory/python-selected" "INVENTORY the python object was not classified" ;;
        *)     fail "inventory/python-selected" "INVENTORY the python object is excluded, case $STEP2_INV_PYTHON_CASE" ;;
    esac
    cases=$((cases + 1))

    if [ -z "$missing_gits" ]; then
        pass "inventory/recorded-git-objects-present" "$(printf '%s' "$STEP2_INV_GITS" | wc -w) recorded, all walked"
    else
        fail "inventory/recorded-git-objects-present" "INVENTORY recorded but not walked:$missing_gits"
    fi
    cases=$((cases + 1))

    if [ -z "$STEP2_INV_GIT_BAD" ]; then
        pass "inventory/git-objects-exact" "no unrecorded member, none unselected"
    else
        fail "inventory/git-objects-exact" "INVENTORY git population:$STEP2_INV_GIT_BAD"
    fi
    cases=$((cases + 1))

    # What Step 2 owns: the classifier answered for every residual program. An
    # object the pass could not place is a defect in the thing under test.
    if [ -z "$STEP2_INV_OTHER_UNCLASSIFIED" ]; then
        pass "inventory/other-programs-classified" "$STEP2_INV_OTHERS classified"
    else
        fail "inventory/other-programs-classified" "INVENTORY residual program unclassified:$STEP2_INV_OTHER_UNCLASSIFIED"
    fi
    cases=$((cases + 1))

    # What Step 2 no longer owns. Before reading 2 this was a Step 2 failure, and
    # leaving it that way made a MANDATORY Step 2 command exit 1 for a criterion
    # the plan had just moved elsewhere: the harness would have contradicted the
    # plan it validates. The residual is still named in full, because Steps 4 and
    # 6 inherit it and a finding nobody can see is a finding nobody will fix.
    # Reported either way, and deliberately never a verdict here: a line that
    # passes on one archive and is silent on another would move the Step 2 case
    # count with the contents of a tarball, which is precisely the count-driven
    # coupling this effort has refused since Step 0.
    if [ -z "$STEP2_INV_OTHER_BAD" ]; then
        note "inventory/other-programs-case-7" \
            "$STEP2_INV_OTHERS residual programs, all case 7"
    else
        note "inventory/other-programs-case-7" \
            "not case 7, asserted by Steps 4 and 6 rather than here:$STEP2_INV_OTHER_BAD"
    fi
    return 0
}

# Decide whether one walked object belongs to the residual PROGRAM population.
# A function rather than an inline test, for the reason round 5 made the same
# change one rule over: a decision the walk makes inline cannot be controlled,
# and an exclusion nobody can exercise is how a population quietly empties.
#
# Only ET_EXEC and ET_DYN are programs. The observer maps every other e_type to
# `unsupported`, and clears the field entirely when the header could not be
# read, so both the relocatable objects and the structurally rejected ones fall
# out here rather than being asked for a case they can never answer.
step2_inventory_is_program() {
    case "$1" in
        exec|dyn) return 0 ;;
        *)        return 1 ;;
    esac
}

# Record one non-library program against the populations named by the oracle.
# The real inventory walk and the round-4 regression controls both enter here,
# so neither side can decide population identity from a path prefix before the
# other observes it.
step2_inventory_record_program() {
    local rel="$1" case_number="$2"

    if [ "$rel" = "$STEP2_INV_PYTHON" ]; then
        STEP2_INV_PYTHON_SEEN=1
        STEP2_INV_PYTHON_CASE="$case_number"
        return 0
    fi
    if step2_in_set "$rel" "$STEP2_INV_GITS"; then
        STEP2_INV_SEEN_GITS="$STEP2_INV_SEEN_GITS $rel"
        note "inventory/git-object" "$rel case $case_number"
        case "$case_number" in
            3|5|6) ;;
            *) STEP2_INV_GIT_BAD="$STEP2_INV_GIT_BAD $rel:not-selected-case$case_number" ;;
        esac
        return 0
    fi

    # Location is NOT population identity, and the same mistake one directory
    # over cost round 4. The recorded paths define the git population; anything
    # the record does not name is residual, whatever tree it sits in, and must
    # receive a case.
    STEP2_INV_OTHERS=$((STEP2_INV_OTHERS + 1))
    # Two different questions, kept apart because Step 2 owns only one of them.
    # An unclassified residual is a CLASSIFIER defect: the pass was asked for a
    # case and produced none, which is what this step exists to prove cannot
    # happen. A residual that classifies as something other than 7 is a statement
    # about what the archive CONTAINS, and the reading-2 revision moved that to
    # Steps 4 and 6, which assert it unqualified.
    if [ -z "$case_number" ]; then
        STEP2_INV_OTHER_UNCLASSIFIED="$STEP2_INV_OTHER_UNCLASSIFIED $rel"
    elif [ "$case_number" != "7" ]; then
        STEP2_INV_OTHER_BAD="$STEP2_INV_OTHER_BAD $rel:case$case_number"
    fi
    return 0
}

step2_inventory_suite() {
    local root="${1%/}" oracle="$2" target saved_prefix
    local size path rel magic recorded_lib is_lib
    local walked=0 unreadable=0 unreadable_ids=""

    section "step 2: the develop#24 inventory"

    note "inventory/root" "$root"
    note "inventory/oracle" "$oracle"
    if ! step2_inventory_oracle "$oracle"; then
        fail "inventory/oracle-readable" "$STEP2_INV_WHY"
        cases=$((cases + 1))
        return 1
    fi
    pass "inventory/oracle-readable" \
        "$STEP2_INV_LIB_COUNT libraries, $(printf '%s' "$STEP2_INV_GITS" | wc -w) git objects, one python program"
    cases=$((cases + 1))
    note "inventory/oracle-python" "$STEP2_INV_PYTHON"

    # The target is the production one, computed by the production builder under
    # the declared prefix. A target invented here would make every case 3 and
    # case 5 answer below a statement about this file rather than about the tree.
    saved_prefix="$INSTALL_PREFIX"
    INSTALL_PREFIX="$root"
    target=$(build_elf_rpath)
    INSTALL_PREFIX="$saved_prefix"
    note "inventory/target" "${target:-<empty>}"
    if [ -z "$target" ]; then
        fail "inventory/target-computed" "build_elf_rpath found no library directory under $root/tools"
        cases=$((cases + 1))
        return 1
    fi
    pass "inventory/target-computed" "the production builder answered under this prefix"
    cases=$((cases + 1))

    step2_inventory_reset

    # The walk production performs, with the size emitted beside the path, which
    # is the caller obligation elf_observe states. The magic test is production's
    # own, with a fork-free prefilter in front of it: most of an archive tree is
    # not ELF, and one process per file to learn that would cost more than the
    # whole check.
    while IFS= read -r -d '' size && IFS= read -r -d '' path; do
        magic=""
        IFS= read -r -N 4 magic < "$path" 2>/dev/null
        [ "$magic" = "$STEP2_ELF_MAGIC" ] || continue
        magic=$(od -An -tx1 -v -N 4 "$path" 2>/dev/null | tr -d '[:space:]')
        [ "$magic" = "7f454c46" ] || continue
        walked=$((walked + 1))
        elf_observe "$path" "$size"
        elf_probe "$path" "$PATCHELF_BIN"
        elf_classify "$target"
        rel="${path#"$root/./"}"
        if [ "$CPLX_ELF_CASE" = "1" ]; then
            unreadable=$((unreadable + 1))
            unreadable_ids="$unreadable_ids $rel"
        fi

        # Membership and structure are decided separately, and BOTH are recorded
        # when both hold. A recorded library that the header walk cannot read is
        # still a recorded library and still owes case 4; a walked library the
        # record does not name is still judged. Deciding one from the other is
        # how round 3's silent skip happened.
        recorded_lib=0
        step2_in_set "$rel" "$STEP2_INV_LIBS" && recorded_lib=1
        is_lib=0
        if [ "${CPLX_ELF_OBS[structural_status]}" = "ok" ] \
           && [ "${CPLX_ELF_OBS[has_dynamic]}" = "yes" ] \
           && [ "${CPLX_ELF_OBS[elf_kind]}" = "dyn" ] \
           && [ "${CPLX_ELF_OBS[has_interp]}" = "no" ]; then
            is_lib=1
        fi
        if [ "$recorded_lib" -eq 1 ]; then
            STEP2_INV_SEEN_LIBS="$STEP2_INV_SEEN_LIBS $rel"
            [ "$CPLX_ELF_CASE" = "4" ] \
                || STEP2_INV_LIB_BAD="$STEP2_INV_LIB_BAD $rel:case$CPLX_ELF_CASE"
        fi
        if [ "$is_lib" -eq 1 ]; then
            STEP2_INV_WALKED_LIBS="$STEP2_INV_WALKED_LIBS $rel"
            [ "$CPLX_ELF_CASE" = "4" ] \
                || STEP2_INV_WALKED_LIB_BAD="$STEP2_INV_WALKED_LIB_BAD $rel:case$CPLX_ELF_CASE"
        fi
        if [ "$recorded_lib" -eq 1 ] || [ "$is_lib" -eq 1 ]; then
            continue
        fi

        # The criterion is about every other archive PROGRAM, and an ELF file is
        # not automatically one. The archive ships relocatable objects and a
        # static archive beside its programs: crt1.o, crti.o, GCC's crtbegin.o
        # and crtend.o, the crtprec and crtoffload set, the sanitizer preinit
        # objects, libmcheck.a and python.o. None carries a PT_DYNAMIC, so none
        # can be given a search path and the pass would never rewrite one.
        # Demanding case 7 of them asks a question the pass never asks, and
        # build 91 answered it the only way it could: 78 of them on case 2, or
        # case 1 for the 32-bit ones the ELF64 reader rejects.
        #
        # They are EXCLUDED here and never passed. Dropping them silently is the
        # failure this whole check exists to refuse, since a preservation rule
        # is satisfied most easily by a population nobody looked at, so the
        # count and the names are reported below.
        #
        # A structurally unreadable object is excluded for the same reason and
        # stays counted as case 1 above: it cannot be judged as a program when
        # its header could not be read at all.
        if ! step2_inventory_is_program "${CPLX_ELF_OBS[elf_kind]}"; then
            STEP2_INV_NONPROGRAMS=$((STEP2_INV_NONPROGRAMS + 1))
            STEP2_INV_NONPROGRAM_IDS="$STEP2_INV_NONPROGRAM_IDS $rel"
            continue
        fi

        step2_inventory_record_program "$rel" "$CPLX_ELF_CASE"
    done < <(find "$root/." \( -name '.git' -o -name '__pycache__' \) -prune -o \
             -type f -size +4c -printf '%s\0%p\0' 2>/dev/null)

    note "inventory/walked" "$walked ELF objects"
    note "inventory/develop24-baseline" "develop#24 flagged $STEP2_INV_LIB_COUNT libraries out of 388 inventoried ELFs"
    note "inventory/case-1-objects" "$unreadable${unreadable_ids:+ ->$unreadable_ids}"
    note "inventory/non-programs" \
        "$STEP2_INV_NONPROGRAMS not exec and not dyn, so outside the residual program rule${STEP2_INV_NONPROGRAM_IDS:+ ->$STEP2_INV_NONPROGRAM_IDS}"
    if [ "$walked" -gt 0 ]; then
        pass "inventory/walked-nonzero" "$walked"
    else
        fail "inventory/walked-nonzero" "no ELF object under $root, so nothing was classified"
    fi
    cases=$((cases + 1))

    step2_inventory_assert
    return 0
}

# The inventory controls. Each drives the SAME reader or the SAME assertion
# function the walk drives, with one deliberate defect and everything else
# clean, so exactly one judgement fails and a control can require its exact
# reason. Without these the whole layer could quietly stop detecting anything
# and the run would look identical on a tree nobody could check anyway.
#
# The 110 synthetic library rows below are CONTROL INPUT, not a stand-in for the
# develop#24 record: they exist to make a well-formed oracle so one field at a
# time can be broken. The real check still refuses to run without the real
# record.
STEP2_CTL_ORACLE=""
step2_ctl_write_oracle() {
    local n="$1" dup="$2" i
    STEP2_CTL_ORACLE="$SCRATCH/ctl-inventory.txt"
    : > "$STEP2_CTL_ORACLE"
    for (( i = 0; i < n; i++ )); do
        printf 'library|tools/python/root/usr/lib64/libctl%03d.so.1\n' "$i" >> "$STEP2_CTL_ORACLE"
    done
    [ "$dup" = "dup" ] && printf 'library|tools/python/root/usr/lib64/libctl000.so.1\n' >> "$STEP2_CTL_ORACLE"
    printf 'python|tools/python/current/bin/python3.13_bin\n' >> "$STEP2_CTL_ORACLE"
    printf 'git|tools/git/root/usr/bin/git\n' >> "$STEP2_CTL_ORACLE"
    return 0
}

# A clean collected state over that oracle: every recorded member walked, every
# library case 4, python selected, no unrecorded git member, no residual defect.
step2_ctl_clean_state() {
    step2_inventory_oracle "$STEP2_CTL_ORACLE" || return 1
    step2_inventory_reset
    STEP2_INV_SEEN_LIBS="$STEP2_INV_LIBS"
    STEP2_INV_WALKED_LIBS="$STEP2_INV_LIBS"
    STEP2_INV_SEEN_GITS="$STEP2_INV_GITS"
    STEP2_INV_PYTHON_SEEN=1
    STEP2_INV_PYTHON_CASE=6
    return 0
}

# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_short_record() {
    step2_ctl_write_oracle 109 ""
    step2_inventory_oracle "$STEP2_CTL_ORACLE" && return 0
    fail "ctl/short-record" "$STEP2_INV_WHY"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_long_record() {
    step2_ctl_write_oracle 111 ""
    step2_inventory_oracle "$STEP2_CTL_ORACLE" && return 0
    fail "ctl/long-record" "$STEP2_INV_WHY"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_duplicate_record() {
    step2_ctl_write_oracle 109 "dup"
    step2_inventory_oracle "$STEP2_CTL_ORACLE" && return 0
    fail "ctl/duplicate-record" "$STEP2_INV_WHY"
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_missing_library() {
    step2_ctl_write_oracle 110 ""
    step2_ctl_clean_state || return 1
    STEP2_INV_SEEN_LIBS="${STEP2_INV_SEEN_LIBS# tools/python/root/usr/lib64/libctl000.so.1}"
    step2_inventory_assert
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_walked_library_not_case_4() {
    step2_ctl_write_oracle 110 ""
    step2_ctl_clean_state || return 1
    STEP2_INV_WALKED_LIBS="$STEP2_INV_WALKED_LIBS tools/python/root/usr/lib64/libextra.so.1"
    STEP2_INV_WALKED_LIB_BAD=" tools/python/root/usr/lib64/libextra.so.1:case7"
    step2_inventory_assert
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_recorded_library_not_case_4() {
    step2_ctl_write_oracle 110 ""
    step2_ctl_clean_state || return 1
    STEP2_INV_LIB_BAD=" tools/python/root/usr/lib64/libctl000.so.1:case3"
    step2_inventory_assert
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_missing_git() {
    step2_ctl_write_oracle 110 ""
    step2_ctl_clean_state || return 1
    STEP2_INV_SEEN_GITS=""
    step2_inventory_assert
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_recorded_git_not_selected() {
    step2_ctl_write_oracle 110 ""
    step2_ctl_clean_state || return 1
    STEP2_INV_GIT_BAD=" tools/git/root/usr/bin/git:not-selected-case7"
    step2_inventory_assert
}
# The pair round 4 asked for, over the SAME unrecorded path under the git tree.
# Location decides nothing now: at case 7 it is an ordinary residual program and
# the rules must stay silent; in a selected case it enlarges the selected set and
# must fail. The first is a positive control, so it is written out rather than
# run through the refusal helper.
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_python_excluded() {
    step2_ctl_write_oracle 110 ""
    step2_ctl_clean_state || return 1
    STEP2_INV_PYTHON_CASE=7
    step2_inventory_assert
}
# shellcheck disable=SC2329  # invoked indirectly, as the control helper's command
step2_ctl_inv_residual_unclassified() {
    step2_ctl_write_oracle 110 ""
    step2_ctl_clean_state || return 1
    STEP2_INV_OTHER_UNCLASSIFIED=" tools/patchelf/root/bin/patchelf"
    step2_inventory_assert
}

# step2_ctl_silent NAME WHY: require the assertion function to say nothing about
# the state the caller has just arranged. The counterpart of `control`, which
# requires a refusal: a rule that reports on everything is no more useful than
# one that reports on nothing, and only the pair tells a working rule from
# either failure.
step2_ctl_silent() {
    local name="$1" why="$2" before="$failures"
    step2_inventory_assert
    if [ "$failures" -eq "$before" ]; then
        pass "$name" "$why"
    else
        failures="$before"
        fail "$name" "the rules reported on a state they should accept: $why"
    fi
    cases=$((cases + 1))
    return 0
}

step2_inventory_controls() {
    local kind ctl_git_tree_path
    section "step 2: the inventory oracle refuses"

    control "control/inventory-short-record"      "ORACLE"    step2_ctl_inv_short_record
    control "control/inventory-long-record"       "ORACLE"    step2_ctl_inv_long_record
    control "control/inventory-duplicate-record"  "ORACLE"    step2_ctl_inv_duplicate_record
    control "control/inventory-missing-library"   "INVENTORY" step2_ctl_inv_missing_library
    control "control/inventory-walked-lib-case"   "INVENTORY" step2_ctl_inv_walked_library_not_case_4
    control "control/inventory-recorded-lib-case" "INVENTORY" step2_ctl_inv_recorded_library_not_case_4
    control "control/inventory-missing-git"       "INVENTORY" step2_ctl_inv_missing_git
    control "control/inventory-git-not-selected"  "INVENTORY" step2_ctl_inv_recorded_git_not_selected
    control "control/inventory-python-excluded"   "INVENTORY" step2_ctl_inv_python_excluded
    control "control/inventory-residual-unclassified" "INVENTORY" step2_ctl_inv_residual_unclassified

    # Round 4's lesson, restated now that reading 2 moved the case-7 verdict to
    # Steps 4 and 6. This half used to require a refusal, and that refusal was
    # the case-7 assertion, so it left with it. Retiring the control with the
    # verdict would have retired the lesson too, and the lesson is the expensive
    # one: LOCATION IS NOT POPULATION IDENTITY. So the claim is asserted directly
    # instead of inferred from a complaint. An unrecorded path under the git tree
    # is counted as residual and never joins the git population, whatever case it
    # carries.
    ctl_git_tree_path="tools/git/root/usr/libexec/git-core/git-http"
    step2_ctl_write_oracle 110 ""
    if step2_ctl_clean_state; then
        step2_inventory_record_program "$ctl_git_tree_path" 6
        # The clean state seeds SEEN_GITS with the whole recorded population, so
        # the claim is about the PLANTED path only: it must have raised the
        # residual count and must not have joined the git population. Asserting
        # an empty SEEN_GITS instead would be asserting the fixture, not the rule.
        if [ "$STEP2_INV_OTHERS" = "1" ] \
            && ! step2_in_set "$ctl_git_tree_path" "$STEP2_INV_SEEN_GITS" \
            && [ -z "$STEP2_INV_GIT_BAD" ]; then
            pass "control/inventory-git-tree-selected" \
                "residual, not a git member, at a selected case"
        else
            fail "control/inventory-git-tree-selected" \
                "INVENTORY location decided population: others=$STEP2_INV_OTHERS planted=$ctl_git_tree_path bad=$STEP2_INV_GIT_BAD"
        fi
        cases=$((cases + 1))
    else
        fail "control/inventory-git-tree-selected" "the control oracle did not read back"
        cases=$((cases + 1))
    fi

    # The positive half of the round 4 pair: the same unrecorded path under the
    # git tree, at case 7, must be an ordinary residual program and draw no
    # complaint. Written out rather than run through the refusal helper, because
    # what it requires is silence.
    step2_ctl_write_oracle 110 ""
    if step2_ctl_clean_state; then
        step2_inventory_record_program \
            "tools/git/root/usr/libexec/git-core/git-http" 7
        step2_ctl_silent "control/inventory-git-tree-case-7" \
            "an unrecorded case 7 program under the git tree is residual, not a defect"
    else
        fail "control/inventory-git-tree-case-7" "the control oracle did not read back"
        cases=$((cases + 1))
    fi

    # The boundary reading 2 drew, made executable. A residual that classifies as
    # something OTHER than 7 must now be reported and accepted here, because the
    # blocking assertion moved to Steps 4 and 6. Without this control the harness
    # could drift back to failing it and nothing would catch the contradiction
    # until a mandatory command exited 1 against a plan that had moved on.
    step2_ctl_write_oracle 110 ""
    if step2_ctl_clean_state; then
        step2_inventory_record_program "tools/python/root/a.out" 5
        step2_ctl_silent "control/inventory-residual-not-case-7" \
            "a residual that is not case 7 is reported here and asserted by Steps 4 and 6"
    else
        fail "control/inventory-residual-not-case-7" "the control oracle did not read back"
        cases=$((cases + 1))
    fi

    # The other half of the same claim: on a clean state the rules stay silent.
    step2_ctl_write_oracle 110 ""
    if step2_ctl_clean_state; then
        step2_ctl_silent "control/inventory-clean-state" "silent on a well-formed state"
    else
        fail "control/inventory-clean-state" "the control oracle did not read back"
        cases=$((cases + 1))
    fi

    # The residual population's own boundary, controlled in both directions,
    # because an exclusion is the one kind of rule that passes by shrinking what
    # it looks at. The first pair says what must fall out, the second says what
    # must NOT: if this ever excluded a program, the preservation criterion
    # would go green over a population it stopped examining.
    section "step 2: the residual population boundary"

    for kind in unsupported ""; do
        if step2_inventory_is_program "$kind"; then
            fail "control/non-program-excluded" \
                "a ${kind:-cleared} kind was taken for a program"
        else
            pass "control/non-program-excluded" \
                "a ${kind:-cleared} kind is not a residual program"
        fi
        cases=$((cases + 1))
    done
    for kind in exec dyn; do
        if step2_inventory_is_program "$kind"; then
            pass "control/program-not-excluded" "a $kind object is still judged"
        else
            fail "control/program-not-excluded" \
                "a $kind object was excluded from the residual population"
        fi
        cases=$((cases + 1))
    done
    return 0
}

# ------------------------------------------------------------------ step 1 ---
# The observer is a PRODUCTION function, reached by sourcing the installer
# through the seam Step 0 opened, so the tests exercise it rather than a copy.
if [ "$STEP" = "1" ]; then
    if [ "$HOST_OK" -ne 1 ]; then
        printf '\nHOST CANNOT SATISFY STEP %s\n' "$STEP"
        printf 'Missing: %s\n' "$HOST_WHY"
        printf '\nStep 1 observes real ELF objects and probes them with patchelf.\n'
        printf 'No substitute was accepted. Run this on the Linux validation host.\n'
        printf '\nOBJECTIVE NOT MET for step %s: fixtures not observable here\n' "$STEP"
        exit 4
    fi
    FIXTURE_PATHS=""
    # shellcheck disable=SC1090
    source "$ISOLATED_INSTALLER" >/dev/null 2>&1
    if declare -F elf_observe >/dev/null 2>&1; then
        pass "step1/observer-defined" "elf_observe, elf_probe, elf_obs_clear"
        cases=$((cases + 1))
        step1_suite
    else
        fail "step1/observer-defined" "elf_observe is not defined after sourcing"
        cases=$((cases + 1))
    fi
fi

# ------------------------------------------------------------------ step 2 ---
# The classifier is a PRODUCTION function, reached through the same seam, and it
# is exercised here WITHOUT running an install. That is not a convenience: it is
# what makes the inventory check below, and Step 6's acceptance, possible at all.
#
# No host gate of its own. The baseline above already refused a host that cannot
# observe a real ELF, so by the time this runs a Linux host, patchelf, readelf
# and sha256sum are established facts rather than assumptions. What can still be
# missing is the archive tree, and that has its own answer below.
if [ "$STEP" = "2" ]; then
    # shellcheck disable=SC1090
    source "$ISOLATED_INSTALLER" >/dev/null 2>&1
    if declare -F elf_classify >/dev/null 2>&1; then
        pass "step2/classifier-defined" "elf_classify"
        cases=$((cases + 1))
        step2_controlled_suite
        step2_bridge_suite
        # The inventory controls run on ANY host that reaches step 2: they drive
        # the reader and the assertion function directly, so the rules are proved
        # able to report and to stay silent whether or not an archive is here.
        step2_inventory_controls
        # The inventory needs TWO things a run is not obliged to have: the
        # recorded develop#24 oracle and the extracted archive it describes.
        # Either one absent leaves the criterion UNANSWERED rather than answered
        # from whatever the tree holds, which is the weakening this check exists
        # to refuse. It gets its own exit code and the run says what to pass.
        if [ -f "$INVENTORY" ] && [ -d "$PREFIX/tools" ]; then
            step2_inventory_suite "$PREFIX" "$INVENTORY"
        else
            printf '  %-40s SKIP  oracle [%s] tree [%s]\n' "step2/inventory" \
                "$([ -f "$INVENTORY" ] && echo present || echo absent)" \
                "$([ -d "$PREFIX/tools" ] && echo present || echo absent)"
            UNANSWERED="${UNANSWERED:+$UNANSWERED, }the develop#24 inventory check"
            UNANSWERED_HOW="$UNANSWERED_HOW
  the inventory check compares a recorded oracle against a real archive tree.
  Record the develop#24 selected set as docs/v0.27.0/inventory.develop-24.txt,
  rows of population|path with populations library, python and git, or name it
  with --inventory; and rerun with --prefix <the extracted prefix>. It is not
  derived from the tree: a derived set passes with a member missing."
        fi
    else
        fail "step2/classifier-defined" "elf_classify is not defined after sourcing"
        cases=$((cases + 1))
    fi
fi

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
[ -n "$UNANSWERED" ] && printf '  unanswered  %s\n' "$UNANSWERED"

# Three outcomes, not two. A failure is a finding about the code and wins, since
# that is the thing to act on; an obligation nobody could answer is neither a
# pass nor a code failure, so it carries its own exit code rather than being
# folded into either. Answering the cheaper question and reporting the step done
# is what the third outcome exists to prevent.
if [ "$failures" -ne 0 ]; then
    printf '\nOBJECTIVE NOT MET for step %s: %s failure(s)\n' "$STEP" "$failures"
    exit 1
fi
if [ -n "$UNANSWERED" ]; then
    printf '\nOBJECTIVE NOT MET for step %s: unanswered: %s\n' "$STEP" "$UNANSWERED"
    printf '%s\n' "$UNANSWERED_HOW"
    exit 5
fi
printf '\nOBJECTIVE MET for step %s\n' "$STEP"
exit 0
