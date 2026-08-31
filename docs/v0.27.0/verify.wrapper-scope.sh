#!/bin/bash
# shellcheck disable=SC2317  # shellcheck 0.10 name for indirect functions annotated SC2329 below
# Verification harness for the v0.27.0 python-wrapper-foreign-distro effort.
#
# This is the executable oracle of
# docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md. Step 0 writes no
# production behaviour: it captures what the CURRENT wrapper does, twice, so
# every later step is judged against a measured baseline rather than against
# this plan's prose.
#
# Usage:
#   bash verify.wrapper-scope.sh [--step N] [--wrapper PATH] [--setenv PATH]
#                                [--retained PATH] [--capture PATH]
#
# Exit codes: 0 the step's objective is met, 1 at least one case failed, 2 the
# arguments are unusable, 4 this host cannot answer the step at all and no
# retained measurement was supplied, 5 every case passed but an obligation went
# unanswered and the run says which. 5 is not a softer 0: the step is not met,
# and the difference from 1 is only that the gap is in what could be asked
# rather than in what the code did.
#
# THE HOST GATE, and why it is not a way of excusing a failure. Steps 0 to 2
# measure symlink surgery. A host that cannot create a symlink cannot reproduce
# it, and running anyway produces fixture failures that look like findings about
# the wrapper and are findings about the host. So the gate is measured first,
# and a host that fails it either reads a retained measurement whose identity
# names THESE harness bytes, or exits 4 saying it could not answer. It never
# reports 0 on its own account. This is the idiom the relocation harness already
# uses for `--target-capability`: the outcome is a measurement the file carries
# rather than a constant the harness asserts.
#
# Case contract, taken from the harness this collection already reviewed:
#   * a case PLANTS its fixture and asserts the plant, so a case cannot report a
#     shape it never created;
#   * the harness's own first case is a negative control proving that an
#     UNPLANTED fixture FAILS, so a suite that blesses anything is caught;
#   * every claim about the wrapper is measured FROM ITS RUN through the shim
#     call log. Reading the wrapper's source and asserting what it says is not a
#     check, it is a restatement.
#
# THE LOG IS ASSERTED, NOT SCANNED FOR ABSENCE. A check that passes because a
# helper never appeared is the failure mode this umbrella exists to refuse, so
# every case naming a helper asserts the EXPECTED CALLS ARE PRESENT first, and
# only then asserts anything about what they observed.
#
# The shim call log is one tab-separated line per call:
#   helper <TAB> argv <TAB> LD_LIBRARY_PATH state <TAB> cwd <TAB> disposition
# The third field distinguishes `unset` from `empty` from a value, because the
# difference is the whole subject of decision W3. The disposition is one of
# `delegated`, `injected-failure` or `stub`.
#
# THE SCOPE ORACLE COVERS THE FOURTEEN POST-SOURCE HELPERS ONLY. Line 12's
# bootstrap `readlink -f` runs BEFORE `setenv` is sourced, so nothing this
# requirement controls has touched the environment it inherits. It is logged and
# delegated like every other call, and asserted separately as a delegated setup
# call, but its inherited environment is NOT part of the unset claim (decision
# P6, P9). Failing it would stop the wrapper before any guarded site is reached,
# and the run would prove nothing.

set -u

# ----------------------------------------------------------------- arguments ---
STEP=0
WRAPPER_ARG=""
SETENV_ARG=""
RETAINED_ARG=""
CAPTURE_ARG=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --step) STEP="$2"; shift 2 ;;
        # The wrapper under test. Namable because steps 3 and 5 run against an
        # extracted archive rather than against this working tree, and step 5
        # runs the retained pre-change copy as its control.
        --wrapper) WRAPPER_ARG="$2"; shift 2 ;;
        # Read and asserted byte-identical, never written.
        --setenv) SETENV_ARG="$2"; shift 2 ;;
        # The retained pre-change wrapper the step 5 control runs. Step 0
        # produces it; later steps assert its digest against a named commit.
        --retained) RETAINED_ARG="$2"; shift 2 ;;
        # The retained capture from a host that COULD answer this step. The
        # symlink behaviour this step measures is not reproducible on a host that
        # cannot create a symlink, so such a host reads a measurement from one
        # that could, exactly as the relocation harness reads
        # `--target-capability` rather than asserting a constant.
        --capture) CAPTURE_ARG="$2"; shift 2 ;;
        -h|--help) sed -n '2,57p' "$0"; exit 0 ;;
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
WRAPPER="${WRAPPER_ARG:-$here/../../src/install/env/python/bin/python}"
SETENV="${SETENV_ARG:-$here/../../src/install/env/python/bin/setenv}"
RETAINED="${RETAINED_ARG:-$here/wrapper.pre-change.verification-only}"

[ -f "$WRAPPER" ] || { echo "wrapper not found: $WRAPPER" >&2; exit 2; }
[ -f "$SETENV" ] || { echo "setenv not found: $SETENV" >&2; exit 2; }
WRAPPER=$(cd "$(dirname "$WRAPPER")" && pwd)/$(basename "$WRAPPER")
SETENV=$(cd "$(dirname "$SETENV")" && pwd)/$(basename "$SETENV")

SCRATCH="${TMPDIR:-/tmp}/cplx-wrapper-scope.$$"
failures=0
cases=0
# An obligation this run could not answer, and the exact way to answer it. Kept
# apart from the failure count because "nobody could ask" is not "the code is
# wrong", and folding it into either is how a step gets reported done on the
# strength of the questions it happened to be able to reach.
UNANSWERED=""
UNANSWERED_HOW=""
# Set when the host cannot answer the step AND no retained measurement was
# supplied. That is neither a pass nor a finding about the wrapper, so it carries
# its own exit code rather than being folded into either.
HOSTGATE_UNANSWERED=0

# shellcheck disable=SC2329  # invoked indirectly by the EXIT trap below
cleanup() { rm -rf -- "$SCRATCH" 2>/dev/null; }
trap cleanup EXIT
mkdir -p -- "$SCRATCH" || { echo "cannot create scratch $SCRATCH" >&2; exit 2; }

# ----------------------------------------------------------------- reporting ---
EXPECT_FAIL=0
CTL_REASON=""
# The detail is appended only when there IS one. Written as `PASS  %s` these
# would emit two trailing spaces on every empty-detail line, which reaches the
# retained captures and makes `git diff --cached --check` report the evidence as
# dirty.
pass() { printf '  %-44s PASS%s\n' "$1" "${2:+  $2}"; }
# In a negative control the failure IS the expected result, so it is captured
# rather than printed: a log a reader scans for FAIL must not show one the next
# line contradicts. Only the control helper sets this flag, and it always clears
# it, so no early return leaves the harness deaf to real failures.
fail() {
    if [ "$EXPECT_FAIL" -eq 1 ]; then CTL_REASON="${2:-}"; return 0; fi
    printf '  %-44s FAIL%s\n' "$1" "${2:+  $2}"
    failures=$((failures + 1))
}
chk() {
    cases=$((cases + 1))
    if [ "$2" = "$3" ]; then pass "$1" "$3"; else fail "$1" "want [$2] got [$3]"; fi
}
note() { printf '  %-44s NOTE%s\n' "$1" "${2:+  $2}"; }
section() { printf '\n== %s\n' "$1"; }

# control <name> <required-reason-prefix> <command...>
# The reason prefix is the whole point: a control demanding only a failure would
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
# yields a PATH, where command -v also resolves a shell function or an alias.
#
# The resolved path is returned through a NAMED VARIABLE rather than on stdout.
# Printing it and calling this in a command substitution would put the failure
# diagnostics into the variable and run the whole function in a subshell, so
# PREFLIGHT_OK=0 would never reach the parent and the gate could not trip. A
# check whose failure path cannot be observed is not a check.
PREFLIGHT_OK=1
PREFLIGHT_PATH=""
preflight_tool() {
    local label="$1" resolved=""
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
    if [ ! -x "$resolved" ]; then
        fail "preflight/$label" "PREFLIGHT not executable: $resolved"
        PREFLIGHT_OK=0
        return 1
    fi
    PREFLIGHT_PATH="$resolved"
    pass "preflight/$label" "$resolved"
    cases=$((cases + 1))
}

# The six helper names the wrapper invokes unqualified after the source. The
# shim set is derived from this list, so a helper added to the wrapper without
# being added here would be invisible to the oracle rather than silently
# tolerated. THE SHIM COVERAGE CASE BELOW ASSERTS THAT AGAINST THE WRAPPER'S
# COMMAND WORDS, in both directions: no unshimmed external command, and no dead
# entry in this list.
#
# An earlier revision of this comment promised that case and no such case
# existed. That is the decorative-gate shape this requirement exists to remove,
# written into the instrument built to refuse it, so the case is now real and
# this note stays as the reason it must remain real.
HELPERS=(readlink mv ln cp sed grep)

# The wrapper's own vocabulary: shell keywords, builtins, the debug function it
# defines, and `dirname`, which is external but PRE-SOURCE and therefore outside
# the scope oracle by decision P9, the same reason the bootstrap `readlink -f`
# carries no environment claim.
WRAPPER_VOCABULARY="if then else elif fi for do done while case esac in
function return exit break continue local export unset shift eval set
echo printf source cd pwd read test true false declare typeset let
dirname echo_dbg"

# Command-position words of the wrapper: the first token of a line, and any token
# introduced by a pipe, a list operator, a command substitution or a `then`,
# `do` or `else` keyword. Assignment targets are removed, since `name=value` puts
# a word in command position that is not a command.
wrapper_command_words() {
    sed -e 's/#.*$//' "$1" \
      | grep -oE '(^|[|;&]|\$\(|<\(|\bthen\b|\bdo\b|\belse\b)[[:space:]]*[a-zA-Z_][a-zA-Z0-9_.-]*' \
      | grep -oE '[a-zA-Z_][a-zA-Z0-9_.-]*$' \
      | sort -u
}

wrapper_assignment_targets() {
    sed -e 's/#.*$//' "$1" \
      | grep -oE '\b[a-zA-Z_][a-zA-Z0-9_]*=' \
      | tr -d '=' \
      | sort -u
}
declare -A REAL_TOOL=()

section "harness prerequisite preflight"
for _h in "${HELPERS[@]}" sha256sum; do
    if preflight_tool "$_h"; then
        REAL_TOOL["$_h"]="$PREFLIGHT_PATH"
    fi
done
if [ "$PREFLIGHT_OK" -ne 1 ]; then
    printf '\nOBJECTIVE NOT MET for step %s: the preflight could not resolve a tool\n' "$STEP"
    exit 1
fi
SHA256SUM_BIN="${REAL_TOOL[sha256sum]}"

digest_of() { "$SHA256SUM_BIN" "$1" | cut -d' ' -f1; }

# The harness's own identity, printed in every verdict so a retained capture
# carries the bytes that produced it. An edit here changes this value, a capture
# taken before the edit stops matching, and the substitution below refuses it.
HARNESS_SHA256=$(digest_of "${BASH_SOURCE[0]}")

# THE SUBJECT IDENTITIES, which are a different question from the harness one.
# The harness digest says which INSTRUMENT produced a capture. These say which
# FILES it measured. A capture bound only to the instrument certifies a run that
# may have been over entirely different inputs, which is the hole code review
# round 2 demonstrated with an unchanged-vocabulary wrapper whose relink target
# was broken: same command words, different behaviour, accepted.
WRAPPER_SHA256=$(digest_of "$WRAPPER")
SETENV_SHA256=$(digest_of "$SETENV")
RETAINED_SHA256=""
[ -f "$RETAINED" ] && RETAINED_SHA256=$(digest_of "$RETAINED")

# ---------------------------------------------------------- recording shims ---
# One shim per helper name, placed FIRST on PATH, each logging one line and then
# delegating to the real tool by ABSOLUTE path. Delegating by name would re-enter
# the shim through PATH and loop.
SHIM_DIR="$SCRATCH/shim"

# shellcheck disable=SC2016  # the single quotes are the point: this writes the
# shim's source, so `$LD_LIBRARY_PATH`, `$@` and `$PWD` must reach the generated
# file unexpanded and be read in the shim's own process, not in this one.
plant_shims() {
    mkdir -p -- "$SHIM_DIR"
    local h
    for h in "${HELPERS[@]}"; do
        {
            printf '#!/bin/bash\n'
            printf '# Recording shim for %s, planted by verify.wrapper-scope.sh.\n' "$h"
            printf 'if [ -z "${LD_LIBRARY_PATH+x}" ]; then _llp=unset\n'
            printf 'elif [ -z "$LD_LIBRARY_PATH" ]; then _llp=empty\n'
            printf 'else _llp="$LD_LIBRARY_PATH"; fi\n'
            printf '_argv="$*"\n'
            printf '_disp=delegated\n'
            if [ "$h" = readlink ]; then
                # The bootstrap call at line 12, recognisable by its -f flag, is
                # ALWAYS delegated and never failed (decision P6). Failing it
                # would stop the wrapper before any guarded site, and the run
                # would prove nothing.
                printf '_boot=0\n'
                printf 'for _a in "$@"; do [ "$_a" = "-f" ] && _boot=1; done\n'
                printf 'if [ "$_boot" -eq 0 ] && [ -n "${WRAPPER_SCOPE_FAIL_SUFFIX:-}" ]; then\n'
                printf '  for _a in "$@"; do\n'
                printf '    case "$_a" in *"$WRAPPER_SCOPE_FAIL_SUFFIX")\n'
                printf '      printf "%%s\\t%%s\\t%%s\\t%%s\\t%%s\\n" "%s" "$_argv" "$_llp" "$PWD" injected-failure >> "$WRAPPER_SCOPE_LOG"\n' "$h"
                printf '      exit 1 ;;\n'
                printf '    esac\n'
                printf '  done\n'
                printf 'fi\n'
                printf '[ "$_boot" -eq 1 ] && _disp=delegated-bootstrap\n'
            fi
            printf 'printf "%%s\\t%%s\\t%%s\\t%%s\\t%%s\\n" "%s" "$_argv" "$_llp" "$PWD" "$_disp" >> "$WRAPPER_SCOPE_LOG"\n' "$h"
            printf 'exec "%s" "$@"\n' "${REAL_TOOL[$h]}"
        } > "$SHIM_DIR/$h"
        chmod +x "$SHIM_DIR/$h"
    done
}

# ---------------------------------------------------------------- the fixture ---
# Shaped like a fresh deployment rather than like the source tree. The wrapper
# reads ${DIR}/current/bin/python3 and relinks it to ../../bin/python, and that
# relative target only resolves back to the wrapper when ${DIR}/current is itself
# a symlink one level down: the physical path of the link is <env>/current/bin/,
# whose ../../bin/python is <env>/bin/python. The same shape puts setenv's
# senvDIR at <env>, which is what makes its ${senvDIR}/current/bin agree with the
# wrapper's ${DIR}/current/bin.
#
# The interpreter is a recording SHELL STUB (decision Q05/E1): it keeps steps 0
# to 2 runnable on any host, which is decision P1. It is not a python and never
# runs -m venv, which is exactly why steps 3 and 5 use the real interpreter.
STUB_NAME="python3.13"

# shellcheck disable=SC2016  # as in plant_shims: this writes the stub's source,
# so its `$LD_LIBRARY_PATH`, `$*` and `$PWD` must survive unexpanded.
plant_fixture() {
    local env_dir="$1"
    mkdir -p -- "$env_dir/bin" "$env_dir/current/bin"
    cp -- "$WRAPPER" "$env_dir/bin/python"
    cp -- "$SETENV" "$env_dir/bin/setenv"
    chmod +x "$env_dir/bin/python"
    ln -nfs "../current" "$env_dir/bin/current"
    {
        printf '#!/bin/bash\n'
        printf '# Recording interpreter stub, planted by verify.wrapper-scope.sh.\n'
        printf 'if [ -z "${LD_LIBRARY_PATH+x}" ]; then _llp=unset\n'
        printf 'elif [ -z "$LD_LIBRARY_PATH" ]; then _llp=empty\n'
        printf 'else _llp="$LD_LIBRARY_PATH"; fi\n'
        printf 'printf "%%s\\t%%s\\t%%s\\t%%s\\t%%s\\n" interpreter "$*" "$_llp" "$PWD" stub >> "$WRAPPER_SCOPE_LOG"\n'
        printf 'exit 0\n'
    } > "$env_dir/current/bin/$STUB_NAME"
    chmod +x "$env_dir/current/bin/$STUB_NAME"
    ln -nfs "$STUB_NAME" "$env_dir/current/bin/python3"
}

# A case PLANTS its fixture and ASSERTS the plant, so a case cannot report a
# shape it never created. The reason prefix is FIXTURE so the negative control
# below can demand that exact refusal rather than any failure at all.
assert_fixture() {
    local name="$1" env_dir="$2" p
    for p in "$env_dir/bin/python" "$env_dir/bin/setenv" "$env_dir/bin/current" \
             "$env_dir/current/bin/$STUB_NAME" "$env_dir/current/bin/python3"; do
        if [ ! -e "$p" ]; then
            fail "$name" "FIXTURE missing: ${p#"$env_dir"/}"
            return 1
        fi
    done
    if [ "$(readlink "$env_dir/current/bin/python3")" != "$STUB_NAME" ]; then
        fail "$name" "FIXTURE python3 is not the expected symlink"
        return 1
    fi
    cases=$((cases + 1))
    pass "$name" "planted and asserted"
    return 0
}

# --------------------------------------------------------------- the run ---
# The wrapper runs with the shims FIRST on PATH and with a controlled
# environment, so a value the harness did not put there cannot reach it.
# LD_LIBRARY_PATH is deliberately NOT set by the caller: whatever the helpers
# observe after line 18 was put there by `setenv`, which is the measurement.
RUN_STATUS=0
run_wrapper() {
    local env_dir="$1" log="$2" fail_suffix="${3:-}"
    : > "$log"
    RUN_STATUS=0
    env -i \
        PATH="$SHIM_DIR:/usr/bin:/bin" \
        HOME="$env_dir" \
        WRAPPER_SCOPE_LOG="$log" \
        WRAPPER_SCOPE_FAIL_SUFFIX="$fail_suffix" \
        bash "$env_dir/bin/python" --version >>"$log.out" 2>&1 || RUN_STATUS=$?
    return 0
}

# count_calls LOG HELPER -> how many lines that helper wrote
count_calls() { grep -c "^$2	" "$1" 2>/dev/null || true; }

# The scope oracle: every POST-SOURCE HELPER call must be asserted PRESENT
# before anything is concluded from what it observed.
#
# The two setup `readlink -f` lines are excluded because they run before the
# source has exported anything (decision P9), and THE INTERPRETER IS EXCLUDED
# TOO, for the opposite reason: it is the one caller that is SUPPOSED to see the
# shipped search path, so counting it among the helpers would make the step 1
# claim unfalsifiable in the direction that matters. Helpers and interpreter are
# counted apart and asserted apart.
count_post_source() {
    grep -v "	delegated-bootstrap$" "$1" 2>/dev/null | grep -cv "^interpreter	" || true
}

# ------------------------------------------------------------------- step 0 ---
# Capture what the wrapper does today, before it changes, so every later claim
# has a before to compare against. TWO RUNS, not one, and the planted one can
# only be taken now, while the pre-change wrapper is still the file on disk.
# The part of step 0 that needs a host able to create a symlink. Kept in one
# function so the host gate below CHOOSES between running it and reading a
# retained measurement of it, instead of interleaving the two.
step0_runnable_suite() {
    plant_shims

    section "step 0 controls: the fixture and the injection must be real"

    # A control proves the fixture is real: an UNPLANTED fixture must FAIL, so a
    # later green cannot come from a tree that was never built.
    ctl_unplanted() {
        local bare="$SCRATCH/unplanted"
        mkdir -p -- "$bare"
        assert_fixture "step0/control-unplanted" "$bare"
    }
    control "step0/control/unplanted-fixture-fails" "FIXTURE" ctl_unplanted

    section "step 0 RUN A: the clean first call over a planted fixture"

    RUNA="$SCRATCH/runA"
    plant_fixture "$RUNA"
    assert_fixture "step0/runA/fixture" "$RUNA"

    LOG_A="$SCRATCH/runA.log"
    run_wrapper "$RUNA" "$LOG_A"
    chk "step0/runA/exit-status" "0" "$RUN_STATUS"

    # ASSERTED PRESENT FIRST. A log with no readlink line would otherwise let
    # every claim below pass by absence, which is the failure this whole
    # umbrella exists to refuse.
    #
    # TWO setup calls, not one. The plan names line 12's `readlink -f`; the
    # first run of this harness showed a SECOND one, at line 7 of `setenv`,
    # which runs DURING the source and therefore still before `setenv` exports
    # the search path at its own line 15. Both are `-f`, both are delegated, and
    # neither carries an environment claim (decision P6, P9). Neither is one of
    # the fourteen post-source helpers, which are the calls that follow the
    # source completing.
    chk "step0/runA/setup-readlink-delegated" "2" \
        "$(grep -c "	delegated-bootstrap$" "$LOG_A" 2>/dev/null || true)"
    chk "step0/runA/post-source-calls-present" "yes" \
        "$( [ "$(count_post_source "$LOG_A")" -gt 0 ] && echo yes || echo no )"
    chk "step0/runA/readlink-calls" "3" "$(count_calls "$LOG_A" readlink)"
    chk "step0/runA/mv-calls" "1" "$(count_calls "$LOG_A" mv)"
    chk "step0/runA/ln-calls" "5" "$(count_calls "$LOG_A" ln)"
    chk "step0/runA/interpreter-calls" "1" "$(count_calls "$LOG_A" interpreter)"

    # THE BASELINE ITSELF: what every post-source helper observed before the
    # change. On the pre-change wrapper this is the shipped search path, and
    # step 1 asserts the same count is zero.
    RUNA_POST=$(count_post_source "$LOG_A")
    RUNA_WITH_LLP=$(grep -v "	delegated-bootstrap$" "$LOG_A" | grep -v "^interpreter	" \
                    | grep -cv "	unset	" || true)
    chk "step0/runA/helpers-seeing-search-path" "$RUNA_POST" "$RUNA_WITH_LLP"
    # THE OTHER HALF, asserted rather than left implied. Step 1 makes the count
    # above fall to zero, and a change that also stopped the interpreter seeing
    # the value would satisfy that count while breaking the wrapper.
    chk "step0/runA/interpreter-sees-search-path" "yes" \
        "$( [ "$(grep "^interpreter	" "$LOG_A" | cut -f3)" = unset ] && echo no || echo yes )"
    note "step0/runA/setup-observed" \
        "$(grep "	delegated-bootstrap$" "$LOG_A" | cut -f3 | sort -u | tr '\n' ' ')(carries no claim, decision P9)"

    # The resulting tree shape, recorded rather than assumed.
    chk "step0/runA/python3-relinked-to-wrapper" "../../bin/python" \
        "$(readlink "$RUNA/current/bin/python3")"
    chk "step0/runA/interpreter-moved-aside" "yes" \
        "$( [ -f "$RUNA/current/bin/${STUB_NAME}_bin" ] && echo yes || echo no )"
    chk "step0/runA/python3_target-points-at-real" "${STUB_NAME}_bin" \
        "$(readlink "$RUNA/current/bin/python3_target")"
    chk "step0/runA/no-empty-derived-path" "no" \
        "$( [ -e "$RUNA/current/bin/_bin" ] && echo yes || echo no )"

    section "step 0 RUN B: the same fixture with a failing line-30 readlink"

    RUNB="$SCRATCH/runB"
    plant_fixture "$RUNB"
    assert_fixture "step0/runB/fixture" "$RUNB"

    LOG_B="$SCRATCH/runB.log"
    run_wrapper "$RUNB" "$LOG_B" "current/bin/python3"

    # A control proves RUN B is real: if the injected failure did not appear in
    # the shim log at the intended site, the suite FAILS rather than recording a
    # clean run as a baseline.
    ctl_injection() {
        local n
        n=$(grep -c "	injected-failure$" "$LOG_B" 2>/dev/null || true)
        if [ "$n" -ne 1 ]; then
            fail "step0/control-injection" "INJECTION not observed once, saw $n"
            return 1
        fi
        cases=$((cases + 1))
        pass "step0/control-injection" "observed once"
        return 0
    }
    ctl_injection
    ctl_injection_absent() {
        local saved_log="$LOG_B" n
        LOG_B="$SCRATCH/runA.log"
        n=$(grep -c "	injected-failure$" "$LOG_B" 2>/dev/null || true)
        LOG_B="$saved_log"
        if [ "$n" -ne 1 ]; then
            fail "step0/control-injection-absent" "INJECTION not observed once, saw $n"
            return 1
        fi
        return 0
    }
    control "step0/control/clean-run-carries-no-injection" "INJECTION" ctl_injection_absent

    # The EXACT injected call, recorded so a later step can prove which site was
    # failed rather than trusting that one was.
    INJECTED_ARGV=$(grep "	injected-failure$" "$LOG_B" | cut -f2)
    note "step0/runB/injected-call" "readlink $INJECTED_ARGV"

    # THE MANGLING the pre-change wrapper produces. Recorded as the baseline
    # step 2 compares against by name.
    chk "step0/runB/python3_target-derived-from-empty" "_bin" \
        "$(readlink "$RUNB/current/bin/python3_target" 2>/dev/null || echo MISSING)"
    chk "step0/runB/interpreter-not-moved-aside" "no" \
        "$( [ -f "$RUNB/current/bin/${STUB_NAME}_bin" ] && echo yes || echo no )"
    chk "step0/runB/interpreter-never-reached" "0" "$(count_calls "$LOG_B" interpreter)"
    # THE BASELINE'S SHARPEST FACT, and it is not what this case first asserted.
    # The run was expected to end non-zero, since line 60 execs a path derived
    # from an empty string and that file does not exist. It ends ZERO. The two
    # `if` statements after the exec both take their false branch, and a false
    # `if` with no else is a successful statement, so the wrapper's last command
    # succeeds and the caller is told the call worked.
    #
    # So the pre-change defect is SILENT: the tree is mangled, the interpreter
    # never runs, and the exit status says success. That is what step 2 flips,
    # and asserting it here means step 2 is compared against the real prior
    # behaviour rather than against the behaviour this harness assumed.
    chk "step0/runB/exit-status-is-a-silent-zero" "0" "$RUN_STATUS"

    # The mutation the guard of step 2 must stop. Recorded as a count so step 2
    # can assert it fell to zero rather than argue about it.
    RUNB_MUTATIONS=$(( $(count_calls "$LOG_B" mv) + $(count_calls "$LOG_B" ln) \
                     + $(count_calls "$LOG_B" cp) + $(count_calls "$LOG_B" sed) ))
    note "step0/runB/mutations-after-injection" "$RUNB_MUTATIONS mv/ln/cp/sed calls followed the failed readlink"
    # Joined without a trailing separator: a NOTE ending in a space reaches the
    # retained capture and makes `git diff --check` report the evidence as dirty.
    note "step0/runB/tree-shape" "$(cd "$RUNB/current/bin" && printf '%s\n' * 2>/dev/null | paste -sd' ' -)"

    section "step 0 identities: what later steps assert rather than assume"

    chk "step0/retained-copy-exists" "yes" \
        "$( [ -f "$RETAINED" ] && echo yes || echo no )"
    if [ -f "$RETAINED" ]; then
        chk "step0/retained-copy-matches-wrapper" "$(digest_of "$WRAPPER")" \
            "$(digest_of "$RETAINED")"
    fi
    note "step0/wrapper-sha256" "$(digest_of "$WRAPPER")"
    note "step0/setenv-sha256" "$(digest_of "$SETENV")"
    note "step0/wrapper-lines" "$(wc -l < "$WRAPPER" | tr -d ' ')"
}

# Reading a retained capture instead of running the suite. The authority is NOT
# that a file exists and says the right words: it is that the capture names THESE
# harness bytes. A capture produced by a different harness, or by this one before
# an edit, no longer matches and the substitution fails, which is what stops a
# stale green from outliving the code it described.
# THE IDENTITY CHECK, and the only reason the substitution is worth having. The
# reason prefix is CAPTUREID so the control below can demand that exact refusal
# rather than any failure at all.
assert_capture_identity() {
    local name="$1" file="$2" got
    got=$(grep -m1 '^  harness     ' "$file" | awk '{print $2}')
    if [ "$got" != "$HARNESS_SHA256" ]; then
        fail "$name" "CAPTUREID capture names [$got], this harness is [$HARNESS_SHA256]"
        return 1
    fi
    cases=$((cases + 1))
    pass "$name" "$got"
    return 0
}

# A control proving the identity check can FAIL. Without it the check that makes
# a retained measurement admissible would itself be unasserted, which is the
# decorative-gate shape this requirement has now corrected at six levels. The
# mutated copy differs from the real capture in exactly the digest line.
ctl_stale_capture() {
    local stale="$SCRATCH/stale-capture.txt"
    sed 's/^\(  harness     \).*/\10000000000000000000000000000000000000000000000000000000000000000/' \
        "$CAPTURE_ARG" > "$stale"
    assert_capture_identity "step0/control-stale-capture" "$stale"
}

# THE SUBJECT BINDING, and the reason the harness digest alone was not enough.
# A capture certifies the behaviour of three exact files. Reading it while the
# files on disk are different ones accepts a claim nobody made about them. Round
# 2 of code review proved that concretely: a wrapper with the same command
# vocabulary and a deliberately broken relink target passed the substitution
# path with OBJECTIVE MET, because nothing compared it to what the capture had
# actually measured.
#
# The reason prefix is SUBJECTID so the three controls below can each demand that
# exact refusal rather than any failure at all.
capture_field() { grep -m1 "^  $2 " "$1" | awk '{print $2}'; }

assert_subject_identity() {
    local name="$1" file="$2" label="$3" field="$4" live="$5" recorded
    recorded=$(capture_field "$file" "$field")
    if [ -z "$recorded" ]; then
        fail "$name" "SUBJECTID capture records no $label digest"
        return 1
    fi
    if [ "$recorded" != "$live" ]; then
        fail "$name" "SUBJECTID $label recorded [$recorded], live is [$live]"
        return 1
    fi
    cases=$((cases + 1))
    pass "$name" "$recorded"
    return 0
}

assert_all_subjects() {
    local file="$1" prefix="$2" rc=0
    assert_subject_identity "$prefix/wrapper" "$file" wrapper "wrapper-sha" \
        "$WRAPPER_SHA256" || rc=1
    assert_subject_identity "$prefix/setenv" "$file" setenv "setenv-sha" \
        "$SETENV_SHA256" || rc=1
    assert_subject_identity "$prefix/retained" "$file" retained "retained-sha" \
        "$RETAINED_SHA256" || rc=1
    return "$rc"
}

# The three controls the round 2 answer named, each substituting one real input
# for a mutated one and requiring the refusal. The wrapper control is the
# important one: its copy keeps the SAME COMMAND VOCABULARY and breaks only the
# relink target, so it is exactly the file that passed before this binding
# existed, and the coverage case alone would still accept it.
ctl_subject_wrapper() {
    local broken="$SCRATCH/broken-wrapper"
    sed 's#\.\./\.\./bin/python#../../bin/NOT-THE-WRAPPER#g' "$WRAPPER" > "$broken"
    local saved="$WRAPPER_SHA256"
    WRAPPER_SHA256=$(digest_of "$broken")
    assert_subject_identity "step0/control-subject-wrapper" "$CAPTURE_ARG" \
        wrapper "wrapper-sha" "$WRAPPER_SHA256"
    local rc=$?
    WRAPPER_SHA256="$saved"
    return "$rc"
}

ctl_subject_setenv() {
    local other="$SCRATCH/other-setenv"
    { cat "$SETENV"; printf '# a mismatched setenv\n'; } > "$other"
    local saved="$SETENV_SHA256"
    SETENV_SHA256=$(digest_of "$other")
    assert_subject_identity "step0/control-subject-setenv" "$CAPTURE_ARG" \
        setenv "setenv-sha" "$SETENV_SHA256"
    local rc=$?
    SETENV_SHA256="$saved"
    return "$rc"
}

ctl_subject_retained() {
    local other="$SCRATCH/other-retained"
    { cat "$RETAINED"; printf '# a mismatched retained wrapper\n'; } > "$other"
    local saved="$RETAINED_SHA256"
    RETAINED_SHA256=$(digest_of "$other")
    assert_subject_identity "step0/control-subject-retained" "$CAPTURE_ARG" \
        retained "retained-sha" "$RETAINED_SHA256"
    local rc=$?
    RETAINED_SHA256="$saved"
    return "$rc"
}

step0_capture_substitution() {
    section "step 0 retained measurement: this host cannot answer, so it reads one"

    # NOT a failure, and the distinction is the point. Nobody asked the question
    # here, so there is no answer to be wrong. Counting it as a finding would
    # blame the wrapper for the host, which is exactly what the seven fixture
    # failures of the previous revision did.
    if [ -z "$CAPTURE_ARG" ]; then
        note "step0/capture/required" \
             "no --capture supplied, so this host answers nothing about the wrapper"
        return 1
    fi
    if [ ! -f "$CAPTURE_ARG" ]; then
        fail "step0/capture/exists" "HOSTGATE capture not found: $CAPTURE_ARG"
        cases=$((cases + 1))
        return 1
    fi
    cases=$((cases + 1))
    pass "step0/capture/exists" "$CAPTURE_ARG"

    assert_capture_identity "step0/capture/names-this-harness" "$CAPTURE_ARG"
    control "step0/control/stale-capture-refused" "CAPTUREID" ctl_stale_capture

    # The instrument is bound above; these bind the SUBJECT. Both are needed:
    # the first says which harness measured, the second says what it measured.
    assert_all_subjects "$CAPTURE_ARG" "step0/capture/subject"
    control "step0/control/broken-wrapper-refused" "SUBJECTID" ctl_subject_wrapper
    control "step0/control/mismatched-setenv-refused" "SUBJECTID" ctl_subject_setenv
    control "step0/control/mismatched-retained-refused" "SUBJECTID" ctl_subject_retained

    chk "step0/capture/verdict-line" "OBJECTIVE MET for step 0" \
        "$(grep -m1 '^OBJECTIVE ' "$CAPTURE_ARG")"
    chk "step0/capture/failures" "0" \
        "$(grep -m1 '^  failures    ' "$CAPTURE_ARG" | awk '{print $2}')"
    chk "step0/capture/cases-present" "yes" \
        "$( [ "$(grep -m1 '^  cases       ' "$CAPTURE_ARG" | awk '{print $2}')" -gt 0 ] \
            2>/dev/null && echo yes || echo no )"
    note "step0/capture/taken-on" \
        "$(grep -m1 '^Target:' "$CAPTURE_ARG" | cut -c9- | cut -c1-60)"
    return 0
}

if [ "$STEP" -eq 0 ]; then
    # THE SHIM COVERAGE CASE, made executable. It reads the wrapper's source,
    # which every other case refuses to do, and that is correct here: the
    # question is which command names the file CONTAINS, not what one run
    # happened to reach. A run-derived answer would report only the helpers that
    # particular path exercised and call the rest absent.
    section "step 0 shim coverage: the helper list against the wrapper"

    _known=$( { printf '%s\n' "${HELPERS[@]}"
                printf '%s\n' "$WRAPPER_VOCABULARY" | tr ' ' '\n'
                wrapper_assignment_targets "$WRAPPER"; } | sort -u | grep -v '^$' )
    _found=$(wrapper_command_words "$WRAPPER")
    chk "step0/coverage/no-unshimmed-command" "" \
        "$(comm -23 <(printf '%s\n' "$_found") <(printf '%s\n' "$_known") | tr '\n' ' ' | sed 's/ $//')"
    chk "step0/coverage/no-dead-shim-entry" "" \
        "$(comm -13 <(printf '%s\n' "$_found") <(printf '%s\n' "${HELPERS[@]}" | sort -u) | tr '\n' ' ' | sed 's/ $//')"

    # The host gate. Measured, never assumed: the probe creates a symlink and
    # reads it back, so a host whose `ln -s` silently copies is caught as surely
    # as one that refuses outright.
    section "step 0 host gate: can this host reproduce the symlink surgery"

    HOST_CAN_SYMLINK=0
    _probe="$SCRATCH/symlink-probe"
    mkdir -p -- "$_probe"
    if ln -s target "$_probe/link" 2>/dev/null \
       && [ -L "$_probe/link" ] \
       && [ "$(readlink "$_probe/link" 2>/dev/null)" = target ]; then
        HOST_CAN_SYMLINK=1
    fi
    cases=$((cases + 1))
    pass "step0/host/symlink-capable" "$( [ "$HOST_CAN_SYMLINK" -eq 1 ] && echo yes || echo no )"

    if [ "$HOST_CAN_SYMLINK" -eq 1 ]; then
        step0_runnable_suite
        # A capture supplied on a capable host is still checked, so the two can
        # never drift apart unnoticed.
        if [ -n "$CAPTURE_ARG" ]; then
            section "step 0 retained capture, cross-checked on a capable host"
            assert_capture_identity "step0/capture/names-this-harness" "$CAPTURE_ARG"
            control "step0/control/stale-capture-refused" "CAPTUREID" ctl_stale_capture
            assert_all_subjects "$CAPTURE_ARG" "step0/capture/subject"
            control "step0/control/broken-wrapper-refused" "SUBJECTID" ctl_subject_wrapper
            control "step0/control/mismatched-setenv-refused" "SUBJECTID" ctl_subject_setenv
            control "step0/control/mismatched-retained-refused" "SUBJECTID" ctl_subject_retained
        fi
    else
        note "step0/host/why" "no symlink support, so the surgery this step measures is not reproducible here"
        step0_capture_substitution || HOSTGATE_UNANSWERED=1
    fi
fi

printf '\n== verdict\n'
printf '  step        %s\n' "$STEP"
printf '  cases       %s\n' "$cases"
printf '  failures    %s\n' "$failures"
printf '  wrapper     %s\n' "$WRAPPER"
printf '  setenv      %s\n' "$SETENV"
printf '  retained    %s\n' "$RETAINED"
printf '  harness     %s\n' "$HARNESS_SHA256"
printf '  wrapper-sha  %s\n' "$WRAPPER_SHA256"
printf '  setenv-sha   %s\n' "$SETENV_SHA256"
printf '  retained-sha %s\n' "$RETAINED_SHA256"
printf '  bash        %s\n' "${BASH_VERSION}"
[ -n "$UNANSWERED" ] && printf '  unanswered  %s\n' "$UNANSWERED"

# THREE outcomes, not two. A failure is a finding about the code and wins, since
# that is the thing to act on; an obligation nobody could answer is neither a
# pass nor a code failure. Answering the cheaper question and reporting the step
# done is what these exist to prevent.
if [ "$failures" -ne 0 ]; then
    printf '\nOBJECTIVE NOT MET for step %s: %s failure(s)\n' "$STEP" "$failures"
    exit 1
fi
if [ "$HOSTGATE_UNANSWERED" -ne 0 ]; then
    printf '\nOBJECTIVE NOT ANSWERABLE HERE for step %s\n' "$STEP"
    printf 'This host cannot create a symlink, so the surgery this step measures\n'
    printf 'is not reproducible on it. Re-run on a POSIX host, or pass the\n'
    printf 'retained measurement with --capture <path>.\n'
    exit 4
fi
if [ -n "$UNANSWERED" ]; then
    printf '\nOBJECTIVE NOT MET for step %s: unanswered: %s\n' "$STEP" "$UNANSWERED"
    printf '%s\n' "$UNANSWERED_HOW"
    exit 5
fi
printf '\nOBJECTIVE MET for step %s\n' "$STEP"
exit 0
