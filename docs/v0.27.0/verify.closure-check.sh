#!/bin/bash
# shellcheck disable=SC2317  # every suite body runs only through the dispatch,
# which invokes it by name, so shellcheck reads them all as unreachable
#
# Verification harness for the v0.27.0 toolchain-runtime-closure effort.
#
# This is the executable oracle of
# docs/v0.27.0/plan.v0.27.0.toolchain-runtime-closure.md. Step 0 writes no
# production behaviour at all: it builds the instrument the seven later steps
# are judged with, declares what each of those steps needs from the host it runs
# on, and refuses rather than answering a cheaper question.
#
# SUITES THAT EXIST TODAY: step 0, the instrument itself, step 1, the declared
# candidate shape and the observed loader scope, step 2, the configuration bundle
# and its authority, and step 3, the static subject set and the derived
# membership half. Step 1 asserts three things a later reader should not have to
# reconstruct: that the five checker modules exist and no sixth
# exists, that the observed scope is `build_elf_rpath`'s own output byte for byte
# rather than a copy of its logic, and that a loader scope which could not be
# observed becomes a typed UNDETERMINED instead of an empty one. Step 2 asserts
# the asymmetry that makes the declaration mean anything: the agent checks
# INTERNAL CONSISTENCY and says so, packaging resolves the authoritative document
# from cplx, and the paired edit is accepted by the first and refused by the
# second. Step 3 asserts the rule the measurement forced: the subject set is the
# WALK of the tree and not a closure from the entry points, so a lib-dynload
# module no edge reaches is still examined and still refuses; and it MEASURES the
# cost rule from a run rather than from the source text, one walk and one index
# construction with the index built first.
#
# EVERY STEP HAS A SUITE SINCE STEP 7, and the red baseline is gone. Step 4 fills
# the floor, coherence, the two rules and aggregation; step 5 the waivers, the
# packaging gate and the publication boundary; step 6 the foreign-host half, the
# evidence grammar and its store. Step 7 is the last, and it is the only one that
# NO SINGLE HOST ANSWERS: its D10 interface cases run anywhere, and its
# acceptance is one half taken live on the machine that can take it and the other
# half required as the retained capture of the machine that took it. That is what
# `both` means in the host matrix, and it is why `--captures` exists: a run is
# green where one half was observed here and the other was observed elsewhere and
# kept, and never where a machine claims a result it cannot see.
#
# Usage:
#   bash verify.closure-check.sh [--step N] [--contract PATH] [--corpus PATH]
#                                [--shipped-dir PATH] [--ci-dir PATH]
#                                [--captures PATH]
#
# With no --step the harness runs EVERY step, each in a fresh process, and
# aggregates. That is not a convenience: the capability gate resolves tools, and
# a capability resolved for one step must not survive into another, or a step
# would inherit an answer it never asked for. One step, one process, always.
#
# Exit codes: 0 the step's objective is met, 1 at least one case failed, 2 the
# arguments are unusable, 5 an obligation went unanswered and the run says which
# and how to answer it. 5 is not a softer 0: the step is not met, and the
# difference from 1 is only that the gap is in what could be asked rather than
# in what the code did. There is no code 4 here. The two sibling harnesses split
# "this host cannot answer" (4) from "an obligation is unanswered" (5); the plan
# fixes ONE code for this effort's refusal, so a host that cannot supply a
# declared tool and a step whose suite does not exist yet report the same 5 and
# are told apart by the reason, never by the number.
#
# THE CAPABILITY GATE HAS THREE OUTCOMES AND NO FOURTH, and the third is the one
# this step exists for:
#
#   supported    resolved, and a probe OBSERVED it doing the thing it is needed
#                for. Not "the binary is on PATH".
#   unsupported  resolved, and the probe showed it cannot. A stub, a wrong
#                answer, a shell too old for associative arrays.
#   unavailable  it could not be ASKED. The command does not resolve at all.
#
# The difference between the last two is the whole point. Item 2 of this
# collection recorded a harness that inferred a capability from source text
# instead of running it, and produced a baseline that looked reasonable and was
# wrong; this repository separately recorded a tool called "not installed" across
# six review rounds while the binary was present and merely absent from one
# shell's PATH. An unavailable tool is a claim to verify, not a fact to record,
# and a gate that cannot tell "it failed" from "nobody asked" records the second
# as the first.
#
# WHY THIS HARNESS DOES NOT USE AN ASSOCIATIVE ARRAY FOR ITS OWN STATE. It has to
# RUN on a host whose Bash has none, or it cannot report `unsupported` for that
# capability: it would die on its own infrastructure and report nothing. So the
# capability records are parallel indexed arrays, and the only `declare -A` in
# this file is inside the probe, behind `eval`, where a shell that cannot parse
# it fails at run time and is measured rather than crashing the harness.
#
# Case contract, the one the two earlier harnesses of this collection
# established and this keeps:
#   * a case PLANTS its fixture and asserts the plant, so a case cannot report a
#     shape it never created;
#   * every oracle that matters carries a negative CONTROL, with the required
#     refusal reason named, so a control cannot be satisfied by a different
#     failure than the one it exists to prove;
#   * a capability is MEASURED from a run. Reading a file and asserting what it
#     says is a restatement, not a check.
#
# THE CONTROLS HERE ASSERT THE FINDING, NOT AN EXIT STATUS, and that is a
# deliberate difference from the two sibling harnesses. Their oracles are whole
# runs, so their controls run one and demand a refusal carrying a named reason.
# Every oracle in this file is a FUNCTION THAT RETURNS FINDINGS, one per line, so
# its control plants exactly one defect and asserts the finding is exactly that
# defect. A control demanding only "something was found" would be satisfied by a
# different finding than the one it exists to prove, which is the same hole the
# reason prefix closes over there.
#
# THE DISTRIBUTION IS READ FROM /etc/os-release AND NEVER FROM `uname`. The
# Debian 12 agent is a container on a RHEL kernel and every capture taken there
# carries an el9 kernel string, so a host gate keying on `uname` would call the
# agent RHEL. A host with no readable /etc/os-release is not one of the two this
# effort validates on, and the gate says so rather than proceeding.

set -u

# ----------------------------------------------------------------- arguments ---
STEP=""
CONTRACT_ARG=""
CORPUS_ARG=""
SHIPPED_DIR_ARG=""
CI_DIR_ARG=""
CAPTURES_ARG=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --step) STEP="${2:-}"; shift 2 ;;
        # The two committed inputs. Namable because the Debian job runs this
        # harness from a pipeline workspace where the delivery script places
        # them beside it under the pipeline's own layout.
        --contract) CONTRACT_ARG="${2:-}"; shift 2 ;;
        --corpus) CORPUS_ARG="${2:-}"; shift 2 ;;
        # Where the ten production scripts live once they exist. Step 0 ships
        # none, so this resolves to a directory holding no `closure_*.sh` and the
        # mechanical assertion reports zero subjects rather than inventing one.
        --shipped-dir) SHIPPED_DIR_ARG="${2:-}"; shift 2 ;;
        # Where the PIPELINE half lives, which is one script and is not under the
        # shipped directory: it is the bootstrap that PLACES that directory, so
        # it travels with the pipeline rather than with what it delivers. It is
        # namable for the same reason the two inputs above are: the Debian job
        # runs this harness from a workspace whose layout is the pipeline's.
        --ci-dir) CI_DIR_ARG="${2:-}"; shift 2 ;;
        # WHERE THE RETAINED CAPTURES LIVE, which step 7 reads and no earlier
        # step does. The two-host acceptance is answered by one host running its
        # own half and by the OTHER host's capture being present, so that
        # directory is an input to the run rather than a place the run writes.
        # It is namable for the same reason the four above are: the Debian job
        # runs this harness from a pipeline workspace, and the RHEL capture
        # travels there as a delivered file rather than beside a checkout.
        --captures) CAPTURES_ARG="${2:-}"; shift 2 ;;
        -h|--help) sed -n '4,85p' "$0"; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

# `dirname` and `basename` are deliberately not used anywhere in this file. The
# refusal cases below re-invoke this harness with a PATH stripped to the tools
# its preflight declares, and every external command used before that preflight
# would have to be added to that list to keep the child runnable. Parameter
# expansion answers both questions with no process at all, and the same reason
# is why multi-line results are folded by `oneline` rather than by `tr`.
_src="${BASH_SOURCE[0]}"
case "$_src" in
    */*) _dir="${_src%/*}" ;;
    *)   _dir="." ;;
esac
here=$(cd "$_dir" && pwd) || { echo "cannot resolve the harness directory" >&2; exit 2; }

CONTRACT="${CONTRACT_ARG:-$here/contract.closure-tools.txt}"
CORPUS="${CORPUS_ARG:-$here/fixtures.closure-corpus.txt}"
SHIPPED_DIR="${SHIPPED_DIR_ARG:-$here/../../src/setups/env/bin}"
# The pipeline half, which is one script and does not live under the shipped
# directory: it is the bootstrap that PLACES that directory, so it travels with
# the pipeline rather than with what it delivers, and a workspace that lays the
# two out differently names it rather than being guessed at.
CI_DIR="${CI_DIR_ARG:-$here/../../ci}"
# The retained host captures of this effort, defaulting to the harness's own
# directory because that is where every earlier one was retained. Step 7 READS
# the capture of the host it is not running on, and nothing here ever writes one:
# a harness that could produce the evidence it also requires would be certifying
# itself, which is the property the topology table protects one level up.
CAPTURES="${CAPTURES_ARG:-$here}"

[ -f "$CONTRACT" ] || { echo "contract not found: $CONTRACT" >&2; exit 2; }
[ -f "$CORPUS" ]   || { echo "corpus not found: $CORPUS" >&2; exit 2; }

# Steps 0 to 7 are the plan's own numbering. A value outside it is refused rather
# than defaulted: accepting one would let the verdict line report a result for a
# step that does not exist, which is a vacuous pass at exactly the level the
# later steps rely on.
if [ -n "$STEP" ]; then
    case "$STEP" in
        0|1|2|3|4|5|6|7) ;;
        *) echo "unsupported --step $STEP: this plan has steps 0 to 7." >&2
           exit 2 ;;
    esac
fi

SCRATCH="${TMPDIR:-/tmp}/cplx-closure-check.$$"
failures=0
cases=0
# An obligation this run could not answer, and the exact way to answer it. Kept
# apart from the failure count because "nobody could ask" is not "the code is
# wrong", and folding it into either is how a step gets reported done on the
# strength of the questions it happened to be able to reach.
UNANSWERED=""
UNANSWERED_HOW=""

unanswered() {
    UNANSWERED="${UNANSWERED:+$UNANSWERED, }$1"
    UNANSWERED_HOW="${UNANSWERED_HOW:+$UNANSWERED_HOW
}$2"
}

# shellcheck disable=SC2329  # invoked indirectly by the EXIT trap below
cleanup() { rm -rf -- "$SCRATCH" 2>/dev/null; }
trap cleanup EXIT

# Fold a multi-line result onto one line, in the shell rather than through `tr`.
oneline() {
    local s="${1-}"
    s="${s//$'\n'/ }"
    printf '%s' "${s% }"
}

# ----------------------------------------------------------------- reporting ---
# The detail is appended only when there IS one. Written as `PASS  %s` these
# would emit two trailing spaces on every empty-detail line, which reaches the
# retained captures and makes `git diff --cached --check` report the evidence as
# dirty.
pass() { printf '  %-46s PASS%s\n' "$1" "${2:+  $2}"; }
fail() {
    printf '  %-46s FAIL%s\n' "$1" "${2:+  $2}"
    failures=$((failures + 1))
}
chk() {
    cases=$((cases + 1))
    if [ "$2" = "$3" ]; then pass "$1" "$3"; else fail "$1" "want [$2] got [$3]"; fi
}
# The same comparison for values that are LISTS. The pass line prints a size
# rather than the value: a retained capture is read by a person, and fourteen
# absolute paths on one PASS line buries the fifty results around it. The
# assertion is unchanged, and a FAILURE still prints both values in full, folded
# onto one line, because that is the case where the detail is what you need.
chk_list() {
    cases=$((cases + 1))
    if [ "$2" = "$3" ]; then
        pass "$1" "identical: $(list_size "$3") line(s), ${#3} bytes"
    else
        fail "$1" "want [$(oneline "$2")] got [$(oneline "$3")]"
    fi
}
list_size() {
    local n=0 line
    while IFS= read -r line; do
        [ -z "$line" ] || n=$((n + 1))
    done <<< "${1-}"
    printf '%s' "$n"
}
note() { printf '  %-46s NOTE%s\n' "$1" "${2:+  $2}"; }
section() { printf '\n== %s\n' "$1"; }

# ------------------------------------------------------ prerequisite preflight ---
# The harness's OWN tools, which are not the checker's and are not this step's
# capability subjects. They are kept short on purpose: the refusal cases below
# re-invoke this file with a PATH containing exactly these, so every name added
# here widens the environment those cases run in and weakens what they prove.
#
# Resolve, check, THEN declare. A combined `readonly VAR="$(type -P x)"` yields
# the exit status of readonly rather than of the substitution, so a failed
# resolution is masked and the variable is frozen empty. shellcheck reports that
# form under SC2155.
#
# `type -P` rather than `command -v` because it searches the command path and
# yields a PATH, where `command -v` also resolves a shell function or an alias.
HARNESS_TOOLS=(sed grep sort uniq mkdir rm chmod)
HARNESS_TOOL_PATHS=()
PREFLIGHT_OK=1

preflight_tool() {
    local label="$1" resolved=""
    cases=$((cases + 1))
    resolved=$(type -P "$label" 2>/dev/null) || resolved=""
    if [ -z "$resolved" ]; then
        fail "preflight/$label" "PREFLIGHT unresolved: type -P found nothing"
        PREFLIGHT_OK=0
        HARNESS_TOOL_PATHS+=("")
        return 1
    fi
    case "$resolved" in
        /*) ;;
        *) fail "preflight/$label" "PREFLIGHT not absolute: $resolved"
           PREFLIGHT_OK=0
           HARNESS_TOOL_PATHS+=("")
           return 1 ;;
    esac
    if [ ! -x "$resolved" ]; then
        fail "preflight/$label" "PREFLIGHT not executable: $resolved"
        PREFLIGHT_OK=0
        HARNESS_TOOL_PATHS+=("")
        return 1
    fi
    HARNESS_TOOL_PATHS+=("$resolved")
    pass "preflight/$label" "$resolved"
}

# ------------------------------------------------------------ the host reading ---
HOST_ID="unknown"
HOST_VERSION="unknown"
read_host_identity() {
    local k v
    [ -r /etc/os-release ] || return 1
    while IFS='=' read -r k v; do
        v="${v%\"}"; v="${v#\"}"
        case "$k" in
            ID) HOST_ID="$v" ;;
            VERSION_ID) HOST_VERSION="$v" ;;
        esac
    done < /etc/os-release
    [ "$HOST_ID" != "unknown" ]
}

# --------------------------------------------------------- the capability gate ---
# The three-outcome probe. It prints `<state>|<detail>` on stdout and nothing
# else, because the refusal cases call it inside a command substitution under a
# different PATH and a subshell cannot report through a variable. Diagnostics go
# to stderr and are discarded there; the detail column is what a reader gets.
#
# The empty-input SHA-256, which is what a real sha256sum must answer. A stub
# that prints a plausible-looking line fails on the value rather than on the
# shape, which is the difference between measuring the tool and measuring that
# something ran.
EMPTY_SHA256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

capability_probe() {
    local key="$1" resolved="" out="" subject=""
    case "$key" in
        assoc)
            # `declare -A` is a property of the RUNNING shell, so the probe runs
            # in the running shell rather than in whatever `bash` PATH resolves
            # to: the checker modules will run here, not there. `eval` defers the
            # parse to run time, so a shell too old to parse the assignment
            # reports a run-time error inside the subshell instead of killing
            # this file at load.
            if [ -z "${BASH_VERSION:-}" ]; then
                printf 'unavailable|no BASH_VERSION: this is not a Bash shell, so the capability could not be asked\n'
                return 0
            fi
            if ( eval 'declare -A _cap=(); _cap[k]=v; [ "${_cap[k]}" = v ]' ) 2>/dev/null; then
                printf 'supported|bash %s, an associative assignment read back its own value\n' "$BASH_VERSION"
            else
                printf 'unsupported|bash %s refused an associative assignment\n' "$BASH_VERSION"
            fi
            ;;
        readelf)
            resolved=$(type -P readelf 2>/dev/null) || resolved=""
            if [ -z "$resolved" ]; then
                printf 'unavailable|type -P readelf found nothing on PATH\n'
                return 0
            fi
            # The probe reads the RUNNING SHELL'S OWN BINARY. It is an ELF on
            # every host this effort validates on, so `-d -V` is exercised
            # against a real object with a real dynamic section rather than
            # against whatever file happened to be nearby. The subject is named
            # in the detail so a reader can see what was read.
            subject="${BASH:-$resolved}"
            if LC_ALL=C "$resolved" -d -V "$subject" >/dev/null 2>&1; then
                printf 'supported|%s answered -d -V over %s\n' "$resolved" "$subject"
            else
                printf 'unsupported|%s resolved but could not read -d -V over %s\n' "$resolved" "$subject"
            fi
            ;;
        sha256sum)
            resolved=$(type -P sha256sum 2>/dev/null) || resolved=""
            if [ -z "$resolved" ]; then
                printf 'unavailable|type -P sha256sum found nothing on PATH\n'
                return 0
            fi
            out=$(printf '' | LC_ALL=C "$resolved" 2>/dev/null) || out=""
            out="${out%% *}"
            if [ "$out" = "$EMPTY_SHA256" ]; then
                printf 'supported|%s digested the empty input correctly\n' "$resolved"
            else
                printf 'unsupported|%s answered [%s] for the empty input\n' "$resolved" "${out:-nothing}"
            fi
            ;;
        *)
            # Every other declared command, which is how step 5 stays in step
            # with the contract instead of repeating a partial list. The measured
            # property for these is RESOLUTION, and the detail says so rather
            # than implying a semantic probe nobody wrote.
            resolved=$(type -P "$key" 2>/dev/null) || resolved=""
            if [ -z "$resolved" ]; then
                printf 'unavailable|type -P %s found nothing on PATH\n' "$key"
            elif [ -x "$resolved" ]; then
                printf 'supported|%s resolved and is executable (resolution only, no semantic probe)\n' "$resolved"
            else
                printf 'unsupported|%s resolved and is not executable\n' "$resolved"
            fi
            ;;
    esac
    return 0
}

CAP_KEYS=()
CAP_STATES=()
CAP_DETAILS=()

capability_record() {
    local key="$1" line=""
    line=$(capability_probe "$key")
    CAP_KEYS+=("$key")
    CAP_STATES+=("${line%%|*}")
    CAP_DETAILS+=("${line#*|}")
}

capability_state() {
    local i
    for i in "${!CAP_KEYS[@]}"; do
        if [ "${CAP_KEYS[$i]}" = "$1" ]; then printf '%s' "${CAP_STATES[$i]}"; return 0; fi
    done
    printf 'unrecorded'
}

capability_detail() {
    local i
    for i in "${!CAP_KEYS[@]}"; do
        if [ "${CAP_KEYS[$i]}" = "$1" ]; then printf '%s' "${CAP_DETAILS[$i]}"; return 0; fi
    done
    printf 'unrecorded'
}

# The one place the three-value domain is written down. A state outside it is a
# failure of the gate itself, which is the "never a pass by omission" rule: a
# probe that returned an empty string would otherwise read as an absent problem.
capability_in_domain() {
    case "$1" in
        supported|unsupported|unavailable) printf 'yes' ;;
        *) printf 'no' ;;
    esac
}

# ---------------------------------------------- what each step declares it needs ---
# The plan's host matrix, in the harness rather than in prose, so a step cannot
# be run against a host that has no business answering it. Step 5 derives its
# tail from the contract file rather than repeating a list, which is what keeps
# the matrix synchronized with the mechanically checked contract.
contract_entry_names() {
    grep -v '^#' "$CONTRACT" \
      | grep -v '^[[:space:]]*$' \
      | grep -v '^launcher|' \
      | sed -e 's/|.*$//'
}

step_tools() {
    case "$1" in
        0) printf 'readelf sha256sum assoc' ;;
        1) printf 'assoc' ;;
        2) printf 'sha256sum git assoc' ;;
        3) printf 'readelf assoc' ;;
        # sha256sum is step 4's because rule 1 compares candidates by CONTENT
        # DIGEST: the checker itself runs it, so the gate has to measure it here
        # rather than leave a mandatory invariant resting on an unprobed tool.
        4) printf 'readelf sha256sum assoc' ;;
        5) printf 'readelf assoc %s' "$(oneline "$(contract_entry_names)")" ;;
        # Step 6 drives the verification driver, the delivery script and the live
        # observer, so its declared set is the whole contract for the same reason
        # step 5's is: a step that executes a shipped script measures every tool
        # that script may reach.
        6) printf 'readelf assoc %s' "$(oneline "$(contract_entry_names)")" ;;
        7) printf 'readelf sha256sum assoc' ;;
    esac
}

step_host() {
    case "$1" in
        0|1|2|3|4|5) printf 'any-linux' ;;
        6) printf 'debian-12' ;;
        7) printf 'both' ;;
    esac
}

# The step that FILLS each suite, so a refusal names the work rather than only
# the gap. Steps 0 and 1 have a suite today; the five that follow are still the
# red baseline step 0 recorded, and each names the work that will fill it.
step_filled_by() {
    case "$1" in
        0) printf 'step 0, this one' ;;
        1) printf 'step 1, the declared candidate shape and the observed loader scope' ;;
        2) printf 'step 2, the configuration bundle and its authority' ;;
        3) printf 'step 3, the static subject set and the derived membership half' ;;
        4) printf 'step 4, the floor, coherence, rule 1, rule 2 and aggregation' ;;
        5) printf 'step 5, waivers, the packaging gate and the publication boundary' ;;
        6) printf 'step 6, the foreign-host half of the verification' ;;
        7) printf 'step 7, the acceptance on both hosts' ;;
    esac
}

step_suite_exists() {
    case "$1" in
        0|1|2|3|4|5|6|7) return 0 ;;
        *) return 1 ;;
    esac
}

# WHICH HALF OF THE TWO-HOST ACCEPTANCE THIS MACHINE ANSWERS, and which half it
# therefore owes a retained capture for. It prints the pair `<mine> <theirs>` and
# refuses on a host that is neither.
#
# THIS IS WHAT MAKES `both` ANSWERABLE WITHOUT MAKING IT CHEAP. "No single host
# answers this step" is true and it is not the same as "no run can answer it":
# each host takes its own half LIVE and requires the other half as EVIDENCE
# somebody else took, which is the only shape that can be green anywhere without
# one machine claiming a result it cannot observe. The order falls out of it and
# matches the plan's completion criteria exactly: the build host runs first and
# is unanswered for want of the Debian capture, the agent runs second with that
# capture beside it and is the run that can be green end to end.
#
# IT IS NEVER SELF-SATISFYING. The capture a host requires is the OTHER host's,
# so no run is answered by evidence it produced itself, and a capture retained
# from a run that never happened is exactly what the freshness assertion below
# is for.
step_two_host_halves() {
    case "$HOST_ID:$HOST_VERSION" in
        rhel:9*) printf 'rhel debian' ;;
        debian:12*) printf 'debian rhel' ;;
        *) return 1 ;;
    esac
}

# ------------------------------------------------------- the nine shipped scripts ---
# The delivered script topology, as a list rather than as prose, because the
# mechanical command-word assertion needs subjects and the topology is what says
# which files those are. None of them exists at step 0 and the run says so: a
# count of zero recorded is the red baseline, and a count that silently returned
# to zero later would be caught by the same line.
SHIPPED_SCRIPTS=(
    "$SHIPPED_DIR/closure_check.sh"
    "$SHIPPED_DIR/closure_config.sh"
    "$SHIPPED_DIR/closure_elf.sh"
    "$SHIPPED_DIR/closure_report.sh"
    "$SHIPPED_DIR/closure_rules.sh"
    "$SHIPPED_DIR/closure_verify.sh"
    "$SHIPPED_DIR/closure_observe_live.sh"
    "$SHIPPED_DIR/closure_publish.sh"
    "$SHIPPED_DIR/closure_d10.sh"
    "$CI_DIR/deliver-closure-tools.sh"
)

# The shipped scripts' own vocabulary: shell keywords and builtins. The two other
# things a lexical reader must not mistake for host dependencies, a function the
# file defines and an assignment target, are derived from the file itself.
#
# Every element is quoted. Unquoted, `then`, `fi`, `do`, `done` and `esac` are
# reserved words even inside an array assignment, and shellcheck reports the
# array as five malformed compound commands (SC1010).
SHIPPED_VOCABULARY=(
    'if' 'then' 'else' 'elif' 'fi' 'for' 'do' 'done' 'while' 'until'
    'case' 'esac' 'in' 'function' 'return' 'exit' 'break' 'continue'
    'local' 'export' 'unset' 'shift' 'eval' 'set' 'trap' 'echo' 'printf'
    'source' 'cd' 'pwd' 'read' 'test' 'true' 'false' 'declare' 'typeset'
    'let' 'readonly' 'command' 'exec' 'builtin' 'type' 'times' 'wait' 'kill'
    'umask' 'getopts' 'hash'
)
# `kill` joined `wait` in step 5, and for the same reason `wait` was here first:
# both are job-control BUILTINS, the interpreter rather than the host, and the
# publication transaction needs the pair. It ends a hasher that is still blocked
# on a FIFO nobody opened, which is a liveness obligation `wait` alone cannot
# meet: awaiting a participant is not the same as guaranteeing it can be awaited.

# Command-position words: the first token of a line, and any token introduced by
# a pipe, a list operator, a command substitution, or a `then`, `do` or `else`
# keyword. Assignment targets are removed separately, since `name=value` puts a
# word in command position that is not a command.
shipped_command_words() {
    sed -e 's/#.*$//' "$1" \
      | grep -oE '(^|[|;&]|\$\(|<\(|\bthen\b|\bdo\b|\belse\b)[[:space:]]*[a-zA-Z_][a-zA-Z0-9_.-]*' \
      | grep -oE '[a-zA-Z_][a-zA-Z0-9_.-]*$' \
      | sort -u
}

shipped_assignment_targets() {
    sed -e 's/#.*$//' "$1" \
      | grep -oE '\b[a-zA-Z_][a-zA-Z0-9_]*=' \
      | sed -e 's/=$//' \
      | sort -u
}

shipped_function_names() {
    sed -e 's/#.*$//' "$1" \
      | grep -oE '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)' \
      | grep -oE '[a-zA-Z_][a-zA-Z0-9_]*' \
      | sort -u
}

# The fourth thing a lexical reader must not mistake for a host dependency: a
# function a shipped script obtains by SOURCING another production script.
# `closure_check.sh` calls `build_elf_rpath` rather than reimplementing it, and
# from step 2 it calls the configuration module's parser and digest the same way.
# Those names sit in command position while being supplied by another script in
# this tree and not by the host, so they belong in neither contract.
#
# THE SET IS DERIVED FROM THE SOURCED FILE, NEVER LISTED. A hand-kept exemption
# would accept a call to a function nobody defines, which is the same hole the
# mechanical assertion exists to close. It is also SCOPED: a file gets another
# script's function names only when it NAMES that script, so the exemption cannot
# quietly widen to a script that never sources it, and a file never exempts
# itself twice.
#
# The candidate set is the installer and the five checker modules, and step 6
# widens it by NOTHING. Round 2 of its review moved the evidence record to
# `closure_report.sh`, which is already one of the five, so the two source
# relationships the step adds, the driver and publication both taking the reader
# from that module, are covered by a set that was already there. The driver
# itself is deliberately absent: no shipped script sources it, and listing it
# would grant its function names to any file that merely NAMES it, such as the
# delivery script's own manifest. An exemption earned by a list accepts a call to
# a function nobody defines, which is the hole this rule exists to close.
shipped_sourced_functions() {
    local file="$1" other module
    for other in "$SHIPPED_DIR/install_pkg.sh" "${CLOSURE_MODULES[@]}"; do
        case "$other" in
            /*) module="$other" ;;
            *) module="$SHIPPED_DIR/$other" ;;
        esac
        [ -f "$module" ] || continue
        [ "$module" != "$file" ] || continue
        # The name has to appear in CODE, not in a comment. Every module's header
        # names its callers in prose, so a comment-blind grep would have granted
        # `closure_config.sh` the checker's function names for describing who
        # sources it, and an exemption earned by a sentence is not an exemption.
        sed -e 's/#.*$//' "$file" | grep -q "${module##*/}" || continue
        shipped_function_names "$module"
    done
}

# The finding: every command-position word of <file> absent from the contract and
# from the file's own vocabulary, one per line. Empty output is the pass.
shipped_undeclared_words() {
    local file="$1" known=""
    known=$( { contract_entry_names
               printf '%s\n' "${SHIPPED_VOCABULARY[@]}"
               shipped_assignment_targets "$file"
               shipped_function_names "$file"
               shipped_sourced_functions "$file"; } | grep -v '^$' | sort -u )
    shipped_command_words "$file" | grep -Fxv -f <(printf '%s\n' "$known") || true
}

# ------------------------------------------------------------- contract reading ---
# The five-column ENTRY shape, read exactly as contract.host-tools.txt is read,
# which is the reason the two files share a shape at all: one reading rule, not
# two formats that happen to look alike.
contract_bad_entry_rows() {
    grep -v '^#' "$1" \
      | grep -v '^[[:space:]]*$' \
      | grep -v '^launcher|' \
      | grep -vE '^[^|]+\|[^|]+\|[^|]+\|[^|]+\|[^|]+$'
}

contract_bad_launcher_rows() {
    grep '^launcher|' "$1" | grep -vE '^launcher\|[^|]+\|[^|]+\|[^|]*\|[^|]*$' || true
}

contract_runs_argument_names() {
    grep -v '^#' "$1" \
      | grep -v '^launcher|' \
      | grep -E '^[^|]+\|[^|]+\|[^|]+\|yes\|' \
      | sed -e 's/|.*$//'
}

contract_launcher_owners() {
    grep '^launcher|' "$1" | sed -e 's/^launcher|[^|]*|//' -e 's/|.*$//'
}

# A `yes` entry with no launcher row is the defect this returns: the rule that
# follows a launcher into its argument cannot follow a tool nobody declared a
# launcher token for, so the tool would be permitted and its argument unread.
contract_yes_without_launcher() {
    local names owners
    names=$(contract_runs_argument_names "$1" | sort -u)
    owners=$(contract_launcher_owners "$1" | sort -u)
    printf '%s\n' "$names" | grep -v '^$' | grep -Fxv -f <(printf '%s\n' "$owners") || true
}

# --------------------------------------------------------------- corpus reading ---
corpus_declared_count() {
    grep -E '^count\|' "$1" | sed -e 's/^count|//' | grep -E '^[0-9]+$' || true
}

corpus_spec_rows() { grep -E '^spec\|' "$1" || true; }
corpus_donor_rows() { grep -E '^donor\|' "$1" || true; }
corpus_spec_count() { corpus_spec_rows "$1" | grep -c . || true; }

corpus_bad_spec_rows() {
    corpus_spec_rows "$1" \
      | grep -vE '^spec\|[^|]+\|[^|]+\|[^|]+\|[^|]+\|[^|]+\|[^|]+$' || true
}

corpus_spec_ids() { corpus_spec_rows "$1" | sed -e 's/^spec|//' -e 's/|.*$//'; }

corpus_duplicate_ids() { corpus_spec_ids "$1" | sort | uniq -d; }

corpus_donor_selectors() { corpus_donor_rows "$1" | sed -e 's/^donor|//' -e 's/|.*$//'; }

corpus_spec_donors() {
    corpus_spec_rows "$1" | sed -e 's/^spec|[^|]*|[^|]*|//' -e 's/|.*$//' | grep -v '^-$' || true
}

# A spec naming a donor selector the file does not declare would be generated
# from a donor nobody validated, which is the one thing the donor rows exist to
# prevent.
corpus_undeclared_donors() {
    local declared
    declared=$(corpus_donor_selectors "$1" | sort -u)
    corpus_spec_donors "$1" | sort -u | grep -Fxv -f <(printf '%s\n' "$declared") || true
}

# ------------------------------------------------------------- refusal reporting ---
# The one place a capability refusal is emitted, so the reason a step could not
# be answered always travels with the command that would answer it. A refusal
# with no `how` is how a run stops being actionable.
refuse_capability() {
    local key="$1" state="$2"
    case "$state" in
        unavailable)
            unanswered "the $key capability on this host" \
                       "  $key is not on PATH here; install it or re-run where it is, then repeat this call" ;;
        *)
            unanswered "the $key capability on this host" \
                       "  $key resolved but failed its probe here: $(capability_detail "$key")" ;;
    esac
}

# ------------------------------------------------- the step 0 refusal subject ---
# The first step whose suite does not exist yet, or nothing when every suite
# exists. It is DERIVED from `step_suite_exists`, the same function the dispatch
# reads, because the step 0 refusal control needs a step that still refuses and a
# written-down number stops being one the moment that step is filled.
step0_first_unfilled() {
    local n
    for n in 1 2 3 4 5 6 7; do
        if ! step_suite_exists "$n"; then printf '%s' "$n"; return 0; fi
    done
    printf ''
}

# THE REFUSAL PATH, HALF OF IT RETIRED AT STEP 7, AND THE RETIREMENT IS RECORDED
# RATHER THAN QUIET. It used to run two children over the FIRST UNFILLED STEP:
# one under a PATH stripped to the harness's own tools, refusing on the missing
# `readelf`, and one under the host's real PATH, refusing on the ABSENT SUITE
# instead. Step 7 wrote the last suite, so the second half has no subject left,
# and the derivation above said exactly that where the subject came from.
#
# A CONTROL WHOSE SHAPE NO LONGER EXISTS IS RETIRED, NOT KEPT GREEN OVER A
# SUBSTITUTE. Inventing an unfilled step to preserve the case would measure the
# fixture rather than the harness, and leaving it reporting UNANSWERED for the
# rest of this effort's life would file a finished baseline as an open question.
#
# WHAT SURVIVES IS THE HALF THAT NEVER NEEDED AN UNFILLED STEP. A step declaring
# `readelf` refuses on the tool under the stripped PATH, and the SAME step on the
# real PATH must not name a missing readelf: it reaches its suite and answers for
# its own reasons. That pair is what stopped the first case being satisfied by
# any refusal, and it is untouched by the baseline going away. The subject is
# step 3, chosen because `readelf` is the first tool it declares and its suite
# has existed since the step that wrote it.
STEP0_REFUSAL_SUBJECT=3

step0_refusal_path() {
    local shim="$1" out rc found

    # THE BASELINE IS GONE, ASSERTED RATHER THAN ASSUMED. The derivation that
    # used to choose this control's subject now answers "nothing", and that
    # answer is the finished state of the plan: a step reachable from the
    # dispatch and not from `step_suite_exists` would print here.
    chk "step0/refusal/every-step-has-a-suite" "" "$(step0_first_unfilled)"
    note "step0/refusal/subject" "step $STEP0_REFUSAL_SUBJECT, which declares readelf among its tools"

    # BOTH CHILDREN GET THIS RUN'S OWN INPUTS, and the shipped directory is the
    # one that matters. The retired version of this control ran over a step with
    # NO SUITE, so a child that could not find the shipped tree still refused for
    # the reason being measured; a subject whose suite exists RUNS, and a run
    # against a shipped directory that does not resolve fails on the missing
    # modules instead of refusing on the missing tool. Debian build 153 is where
    # that was observed: the agent lays the tree out under the pipeline's own
    # paths, the default resolved to nothing, and the child returned 1 rather
    # than 5. The parent already knows where everything is, so it says so.
    out=$(PATH="$shim" "${BASH:-bash}" "$0" --step "$STEP0_REFUSAL_SUBJECT" \
        --contract "$CONTRACT" --corpus "$CORPUS" \
        --shipped-dir "$SHIPPED_DIR" --ci-dir "$CI_DIR" 2>&1)
    rc=$?
    chk "step0/refusal/missing-tool-exit-code" "5" "$rc"
    if printf '%s' "$out" | grep -q 'readelf is not on PATH here'; then found=yes; else found=no; fi
    chk "step0/refusal/names-the-missing-command" "yes" "$found"

    # The control that stops the case above being satisfied by any refusal: the
    # SAME step, on this host's real PATH, must not name a missing readelf.
    #
    # IT ONLY MEANS ANYTHING WHERE THE HOST SUPPLIES `readelf`. Where readelf is
    # unavailable anyway both children refuse alike and a pass would say nothing
    # about the shim, so the control is not run and the obligation is reported
    # unanswered rather than recorded green. The authoring host is that case:
    # Windows carries no readelf, and an earlier revision of this control FAILED
    # there for exactly that reason, which is how the distinction came to be
    # measured instead of assumed.
    if [ "$(capability_state readelf)" != "supported" ]; then
        note "step0/refusal/two-refusals-are-distinct" \
             "not run: readelf is $(capability_state readelf) here, so both children refuse alike"
        unanswered "the distinctness of the two step $STEP0_REFUSAL_SUBJECT refusals" \
          "  re-run on a host that supplies readelf, where the shimmed child refuses on the tool and the real-PATH child reaches its suite"
        return 0
    fi
    out=$("${BASH:-bash}" "$0" --step "$STEP0_REFUSAL_SUBJECT" \
        --contract "$CONTRACT" --corpus "$CORPUS" \
        --shipped-dir "$SHIPPED_DIR" --ci-dir "$CI_DIR" 2>&1)
    if printf '%s' "$out" | grep -q 'readelf is not on PATH here'; then found=yes; else found=no; fi
    chk "step0/refusal/two-refusals-are-distinct" "no" "$found"
    # AND IT REACHED THE SUITE, which is what says the shimmed child was stopped
    # by the shim and not by something both children would have hit.
    if printf '%s' "$out" | grep -q "step $STEP0_REFUSAL_SUBJECT topology"; then found=yes; else found=no; fi
    chk "step0/refusal/the-real-path-child-reaches-its-suite" "yes" "$found"
}

# =============================================================== the step 0 suite ===
step0_suite() {
    local shim="$SCRATCH/shim" stub="$SCRATCH/stub" fix="$SCRATCH/fixture"
    local line found out rc tool path i n state detail present absent declared actual

    # --- the gate's own two outcomes, driven rather than described -------------
    #
    # A PATH holding exactly the harness's own tools and nothing else. Building
    # it from the declared list rather than by removing one entry from the live
    # PATH is what makes the removal exact: on both validation hosts `readelf`
    # and `sed` live in the same directory, so there is no directory to drop.
    section "step 0 gate controls: unavailable is not unsupported"
    mkdir -p -- "$shim" "$stub" || { fail "step0/gate/scratch" "cannot create the scratch shims"; return; }
    for i in "${!HARNESS_TOOLS[@]}"; do
        tool="${HARNESS_TOOLS[$i]}"
        path="${HARNESS_TOOL_PATHS[$i]}"
        # shellcheck disable=SC2016  # `$@` must reach the generated file unexpanded
        printf '#!/bin/sh\nexec %s "$@"\n' "$path" > "$shim/$tool"
        chmod +x "$shim/$tool"
    done
    found=""
    for tool in "${HARNESS_TOOLS[@]}"; do
        [ -x "$shim/$tool" ] || found="${found:+$found }$tool"
    done
    chk "step0/gate/shim-planted" "" "$found"

    # readelf: absent from the shim PATH, so it cannot be asked at all.
    line=$(PATH="$shim" capability_probe readelf)
    chk "step0/gate/readelf-unavailable" "unavailable" "${line%%|*}"

    # readelf: present and refusing, so it was asked and could not answer. The
    # pair is the whole point: one PATH that removes the tool and one that
    # replaces it, and two different states out of the same probe.
    printf '#!/bin/sh\nexit 1\n' > "$stub/readelf"
    chmod +x "$stub/readelf"
    line=$(PATH="$stub:$shim" capability_probe readelf)
    chk "step0/gate/readelf-unsupported" "unsupported" "${line%%|*}"

    line=$(PATH="$shim" capability_probe sha256sum)
    chk "step0/gate/sha256sum-unavailable" "unavailable" "${line%%|*}"

    # A stub answering the SHAPE of a digest line with the wrong VALUE. A gate
    # checking only that something was printed would call this supported.
    printf '#!/bin/sh\necho "%s  -"\n' \
        "0000000000000000000000000000000000000000000000000000000000000000" > "$stub/sha256sum"
    chmod +x "$stub/sha256sum"
    line=$(PATH="$stub:$shim" capability_probe sha256sum)
    chk "step0/gate/sha256sum-unsupported" "unsupported" "${line%%|*}"

    # The associative-array capability cannot be removed from PATH, so its
    # unavailable outcome is driven by removing the thing that answers it: a run
    # with no BASH_VERSION is a run under a shell that was never asked.
    line=$( unset BASH_VERSION; capability_probe assoc )
    chk "step0/gate/assoc-unavailable-without-bash" "unavailable" "${line%%|*}"

    # --- the declared capabilities of THIS step, measured ---------------------
    section "step 0 capability gate: readelf, sha256sum, declare -A"
    for tool in $(step_tools 0); do
        capability_record "$tool"
        state=$(capability_state "$tool")
        detail=$(capability_detail "$tool")
        chk "step0/capability/$tool/in-domain" "yes" "$(capability_in_domain "$state")"
        note "step0/capability/$tool" "$state: $detail"
        [ "$state" = "supported" ] || refuse_capability "$tool" "$state"
    done

    # --- the refusal path, driven through a real child process ----------------
    #
    # THE SUBJECT STEP IS DERIVED, NOT WRITTEN DOWN. This case needs a step whose
    # suite does not exist yet, and step 3 was that step until step 3 filled it:
    # a hard-coded number turns "the suite is absent" into a claim that quietly
    # becomes false, and the step that filled it fails step 0 while step 0 is not
    # what it broke. `step0_first_unfilled` asks the same function the dispatch
    # asks, so this control follows the red baseline as it recedes.
    section "step 0 refusal path: a step whose declared tool is missing"
    step0_refusal_path "$shim"

    # --- steps 1 to 7 have a declared host and a declared refusal path --------
    #
    # THE REFUSAL IS ASSERTED FOR THE STEPS THAT ARE STILL RED, AND FOR NO
    # OTHERS. Every later step must declare its tools and its host from the day
    # step 0 lands, and a step whose suite does not exist yet must refuse rather
    # than answer. Once a step is filled that refusal is gone by design, so
    # asserting it for every step would make step 0 fail on the first step that
    # succeeded. Step 0 does not judge a filled suite either: `--step N` is the
    # command that judges step N, and running it from here would only report the
    # same result under a name that hides which step produced it.
    section "step 0 red baseline: every later step declares, and the unfilled refuse"
    for n in 1 2 3 4 5 6 7; do
        chk "step0/declared/step$n/tools-not-empty" "yes" \
            "$( [ -n "$(step_tools "$n")" ] && echo yes || echo no )"
        chk "step0/declared/step$n/host-not-empty" "yes" \
            "$( [ -n "$(step_host "$n")" ] && echo yes || echo no )"
        if step_suite_exists "$n"; then
            note "step0/declared/step$n/has-a-suite" \
                 "filled by $(step_filled_by "$n"); judged by --step $n"
            continue
        fi
        out=$("${BASH:-bash}" "$0" --step "$n" --contract "$CONTRACT" --corpus "$CORPUS" 2>&1)
        rc=$?
        chk "step0/declared/step$n/refuses" "5" "$rc"
        if printf '%s' "$out" | grep -q 'OBJECTIVE NOT MET'; then found=yes; else found=no; fi
        chk "step0/declared/step$n/says-why" "yes" "$found"
    done

    # --- the host-tool contract -----------------------------------------------
    section "step 0 contract: the checker's own allowlist"
    chk "step0/contract/entry-row-shape" "" "$(oneline "$(contract_bad_entry_rows "$CONTRACT")")"
    chk "step0/contract/launcher-row-shape" "" "$(oneline "$(contract_bad_launcher_rows "$CONTRACT")")"
    chk "step0/contract/yes-owns-a-launcher" "" "$(oneline "$(contract_yes_without_launcher "$CONTRACT")")"
    # The contract is ENUMERATED, so the harness asserts the whole set rather
    # than sampling it. Round 7 of the plan review refused a version that claimed
    # this coverage while listing seven of the thirteen commands.
    #
    # FIFTEEN SINCE STEP 5, and the two it added are here rather than in the
    # step 5 suite on purpose: this line is the review gate the contract's own
    # header describes, so a command a later step needs has to be added to the
    # contract AND to this expectation, where a reader of step 0 sees it. The
    # four adapter operations are deliberately NOT among them: they are supplied
    # by the caller, not by the host, and `closure_publish.sh` carries refusing
    # defaults for all four so a run without an adapter refuses.
    chk "step0/contract/enumerated-set" \
        "bash cat chmod cp find git ln mkdir mkfifo mktemp readelf rm sha256sum tar tee" \
        "$(oneline "$(contract_entry_names | sort)")"

    mkdir -p -- "$fix" || { fail "step0/contract/fixture" "cannot create the fixture directory"; return; }
    # A four-column row must be refused on the SHAPE. Planted rather than
    # described, so the reading rule is exercised instead of restated.
    { grep -v '^#' "$CONTRACT" | grep -v '^[[:space:]]*$'
      printf 'awk|direct|-|no\n'; } > "$fix/contract-short.txt"
    chk "step0/contract/control/short-row-refused" "awk|direct|-|no" \
        "$(oneline "$(contract_bad_entry_rows "$fix/contract-short.txt")")"
    { grep -v '^#' "$CONTRACT" | grep -v '^[[:space:]]*$'
      printf 'awk|direct|-|yes|a launcher nobody declared a token for\n'; } > "$fix/contract-orphan.txt"
    chk "step0/contract/control/yes-without-launcher-refused" "awk" \
        "$(oneline "$(contract_yes_without_launcher "$fix/contract-orphan.txt")")"

    # --- the mechanical assertion, over planted subjects ----------------------
    #
    # THE ASSERTION IS MECHANICAL, NOT A LIST KEPT IN STEP BY HAND. No shipped
    # script exists yet, so the extractor is proved here on two planted files,
    # one clean and one carrying a single undeclared command. From step 1 the
    # same function runs over the real scripts and needs no new case.
    section "step 0 mechanical assertion: proved before it has a subject"
    # shellcheck disable=SC2016  # the generated fixtures must carry `$1` literally
    { printf '#!/bin/bash\n'
      printf 'emit() {\n'
      printf '    cat "$1"\n'
      printf '    find "$2" -type f\n'
      printf '}\n'
      printf 'target=/tmp\n'
      printf 'emit "$1" "$target"\n'; } > "$fix/clean.sh"
    chk "step0/mechanical/clean-script-has-no-finding" "" \
        "$(oneline "$(shipped_undeclared_words "$fix/clean.sh")")"
    # shellcheck disable=SC2016  # the generated fixtures must carry `$1` literally
    { printf '#!/bin/bash\n'
      printf 'emit() {\n'
      printf '    cat "$1"\n'
      printf '    awk "{print}" "$1"\n'
      printf '}\n'
      printf 'emit "$1"\n'; } > "$fix/dirty.sh"
    chk "step0/mechanical/undeclared-command-is-named" "awk" \
        "$(oneline "$(shipped_undeclared_words "$fix/dirty.sh")")"

    present=0
    absent=""
    for path in "${SHIPPED_SCRIPTS[@]}"; do
        if [ -f "$path" ]; then
            present=$((present + 1))
            chk "step0/mechanical/${path##*/}" "" \
                "$(oneline "$(shipped_undeclared_words "$path")")"
        else
            absent="${absent:+$absent }${path##*/}"
        fi
    done
    # TEN SINCE STEP 5, and the number is asserted rather than counted loosely
    # because it is the whole point of a fixed topology: the table names every
    # script the deployment carries, so a script added without a row is a finding
    # here rather than a surprise on a bare account. Step 5's amendment added
    # `closure_report.sh` to that table, and this is the line that agrees with it.
    chk "step0/mechanical/topology-is-ten" "10" "${#SHIPPED_SCRIPTS[@]}"
    note "step0/mechanical/shipped-present" "$present of ${#SHIPPED_SCRIPTS[@]}"
    if [ -n "$absent" ]; then note "step0/mechanical/shipped-absent" "$absent"; fi

    # --- the fixture corpus ---------------------------------------------------
    section "step 0 corpus: a truncated file is a failure, not a smaller run"
    declared=$(corpus_declared_count "$CORPUS")
    actual=$(corpus_spec_count "$CORPUS")
    chk "step0/corpus/declares-a-count" "yes" "$( [ -n "$declared" ] && echo yes || echo no )"
    chk "step0/corpus/count-matches-rows" "$declared" "$actual"
    chk "step0/corpus/spec-row-shape" "" "$(oneline "$(corpus_bad_spec_rows "$CORPUS")")"
    chk "step0/corpus/ids-are-unique" "" "$(oneline "$(corpus_duplicate_ids "$CORPUS")")"
    chk "step0/corpus/donors-are-declared" "" "$(oneline "$(corpus_undeclared_donors "$CORPUS")")"

    # The control the plan asks for by name: a corpus that lost its tail must
    # differ on the COUNT, which is the only thing that tells a truncated file
    # from a shorter one somebody meant to write.
    grep -v '^spec|scope-alias-one-file|' "$CORPUS" > "$fix/corpus-truncated.txt"
    chk "step0/corpus/control/truncated-refused" \
        "$declared/$((actual - 1))" \
        "$(corpus_declared_count "$fix/corpus-truncated.txt")/$(corpus_spec_count "$fix/corpus-truncated.txt")"
    { grep -v '^spec|' "$CORPUS"
      printf 'spec|short-row|object|shared|tools/x|needed-add:libx.so.1\n'; } > "$fix/corpus-short.txt"
    chk "step0/corpus/control/short-row-refused" \
        "spec|short-row|object|shared|tools/x|needed-add:libx.so.1" \
        "$(oneline "$(corpus_bad_spec_rows "$fix/corpus-short.txt")")"
}

# ---------------------------------------------------------- the checker modules ---
# The five modules the delivered script topology fixes, in the order the topology
# table lists them. Step 1 creates four of them and step 5 adds `closure_report.sh`,
# which the plan's amended table declares unconditionally rather than on a measured
# count; the file name that must NOT exist in any shape is named beside them,
# because "no `closure_scope.sh`" is a property of the tree rather than of a table
# nobody re-reads. The forbidden name did not change when the set grew: scope
# derivation still has a module that owns its neighbours, and the report did not.
CLOSURE_MODULES=(closure_check.sh closure_config.sh closure_elf.sh closure_report.sh closure_rules.sh)
CLOSURE_FORBIDDEN_MODULE=closure_scope.sh

# The step that FILLS each module, parallel to the array above and taken from the
# topology table's own `Filled by` column. It is here rather than re-listed at
# each step because "created empty" and "filled" are the same claim read at two
# different times: a module whose filling step has a suite must have a body, and
# every other module must still have none. Hand-listing the empty ones made step
# 1 the place a later step had to remember to edit, and a forgotten edit there
# reads as a step 1 regression rather than as the step that filled the file.
CLOSURE_MODULE_FILLED_BY=(1 2 3 5 3)

# The BODY of a module: its lines that are neither blank nor a comment. A module
# created with its contract comment and nothing else has a body of zero, and that
# is what the assertion reads. "Created empty" has to be a measured number, or a
# module quietly filled a step early is indistinguishable from one that was not.
module_body_lines() {
    grep -vE '^[[:space:]]*(#|$)' "$1" | grep -c . || true
}

# ------------------------------------------------------------- checker probing ---
# One checker run, as a CHILD PROCESS. The harness never sources the checker to
# judge a run: an exit code the checker did not produce must not be mistakable
# for one it did, and the exit code is half of what every case below asserts.
CHECKER_OUT=""
CHECKER_RC=0
run_checker() {
    CHECKER_OUT=$("${BASH:-bash}" "$@" 2>&1)
    CHECKER_RC=$?
}

# The typed lines of the last run, by their type column.
typed_lines() { printf '%s\n' "$CHECKER_OUT" | grep -E "^$1\|" || true; }
typed_count() { typed_lines "$1" | grep -c . || true; }

# The two derivations, each reached through the checker's own MAIN BOUNDARY seam
# in a child, so a syntax error in production code fails the case instead of
# killing the harness. 91 and 92 are the harness's own codes for "the seam did
# not hold", and they are distinct from anything the checker returns.
declared_shape() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        declare -F closure_scope_declared >/dev/null 2>&1 || exit 92
        shift
        closure_scope_declared "$@"
    ' _ "$SHIPPED_DIR/closure_check.sh" "$@" 2>/dev/null
}

observed_scope() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        declare -F closure_scope_observed >/dev/null 2>&1 || exit 92
        closure_scope_observed "$2" "$3" || exit 93
        printf "%s" "$CLOSURE_OBSERVED_RPATH"
    ' _ "$SHIPPED_DIR/closure_check.sh" "$1" "$2" 2>/dev/null
}

# `build_elf_rpath` itself, sourced from the installer with nothing between it
# and the harness. This is the OTHER side of the property case: the checker's
# observed scope is compared against THIS value, so a reimplementation that
# agreed today and drifted tomorrow fails the moment it drifts.
build_elf_rpath_value() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$2" >/dev/null 2>&1 || exit 91
        declare -F build_elf_rpath >/dev/null 2>&1 || exit 92
        INSTALL_PREFIX="$1"
        build_elf_rpath
    ' _ "$1" "$2" 2>/dev/null
}

# =============================================================== the step 1 suite ===
step1_suite() {
    local checker="$SHIPPED_DIR/closure_check.sh"
    local installer="$SHIPPED_DIR/install_pkg.sh"
    local tree="$SCRATCH/prefix" absent="$SCRATCH/prefix-absent" stubs="$SCRATCH/stubs"
    local module found a b ln_bin d i
    local py="python=current,python-3.13.9" gitroot="git=current"

    # --- the module set, fixed and unconditional -------------------------------
    mkdir -p -- "$stubs" || { fail "step1/scratch" "cannot create the stub directory"; return; }
    section "step 1 topology: five modules, the fifth added by step 5, no sixth"
    for module in "${CLOSURE_MODULES[@]}"; do
        chk "step1/topology/$module/exists" "yes" \
            "$( [ -f "$SHIPPED_DIR/$module" ] && echo yes || echo no )"
    done
    chk "step1/topology/no-$CLOSURE_FORBIDDEN_MODULE" "no" \
        "$( [ -f "$SHIPPED_DIR/$CLOSURE_FORBIDDEN_MODULE" ] && echo yes || echo no )"
    # A module carries a contract comment and nothing else until the step that
    # fills it, and a body afterwards. Both halves are measured, because "created
    # empty" and "filled" are the two claims the topology makes about the four,
    # and the side each module is on is read from the topology's own `Filled by`
    # column rather than from a list kept in step by hand.
    for i in "${!CLOSURE_MODULES[@]}"; do
        module="${CLOSURE_MODULES[$i]}"
        if [ ! -f "$SHIPPED_DIR/$module" ]; then
            fail "step1/topology/$module/body" "the module does not exist"
            continue
        fi
        if step_suite_exists "${CLOSURE_MODULE_FILLED_BY[$i]}"; then
            chk "step1/topology/$module/is-filled" "yes" \
                "$( [ "$(module_body_lines "$SHIPPED_DIR/$module")" -gt 0 ] && echo yes || echo no )"
        else
            chk "step1/topology/$module/body-is-empty" "0" \
                "$(module_body_lines "$SHIPPED_DIR/$module")"
        fi
    done
    if [ ! -f "$checker" ]; then
        unanswered "every step 1 case" \
          "  create src/setups/env/bin/closure_check.sh, then repeat this call"
        return
    fi
    # The same mechanical assertion step 0 proved on planted subjects, run here
    # over the real modules, so a command this step introduced without declaring
    # it is named by the step that introduced it.
    for module in "${CLOSURE_MODULES[@]}"; do
        [ -f "$SHIPPED_DIR/$module" ] || continue
        chk "step1/topology/$module/declared-commands" "" \
            "$(oneline "$(shipped_undeclared_words "$SHIPPED_DIR/$module")")"
    done
    # THE CONTROL FOR THE SOURCED-FUNCTION EXEMPTION. `build_elf_rpath` passes
    # the assertion above because `install_pkg.sh` defines it and the checker
    # sources it. That exemption must accept nothing else: a planted script that
    # sources the installer and calls a function NOBODY defines is still a
    # finding, and a script that never names the installer gets no exemption at
    # all. Without these two, the rule that lets step 1 call a production
    # function would also let a typo through.
    { printf '#!/bin/bash\n'
      printf 'source "%s"\n' "$installer"
      printf 'build_elf_rpath\n'
      printf 'cplx_never_defined\n'; } > "$stubs/sourced.sh"
    chk "step1/topology/control/exemption-is-scoped-to-the-defined" "cplx_never_defined" \
        "$(oneline "$(shipped_undeclared_words "$stubs/sourced.sh")")"
    printf '#!/bin/bash\nbuild_elf_rpath\n' > "$stubs/unsourced.sh"
    chk "step1/topology/control/no-exemption-without-the-source" "build_elf_rpath" \
        "$(oneline "$(shipped_undeclared_words "$stubs/unsourced.sh")")"

    # --- one derivation, and no copy of the installer's walk -------------------
    section "step 1 scope: derived once, observed through build_elf_rpath"
    chk "step1/observed/calls-build-elf-rpath" "yes" \
        "$(grep -qE 'build_elf_rpath' "$checker" && echo yes || echo no)"
    # The drift grep the plan fixes: the observed scope comes from the installer's
    # own function, so neither the tool-root glob nor the installer's first
    # suffix may appear in the checker at all.
    chk "step1/observed/no-reimplementation" "" \
        "$(oneline "$(grep -nE 'tools/\*/|root/usr/lib64' "$checker" || true)")"
    # UNEXPECTED is unwaivable BY CONSTRUCTION, which means no waiver code path
    # reaches it. Comments are stripped first on purpose: the property belongs in
    # the header in words, and the assertion is about code.
    chk "step1/unwaivable/no-waiver-code-path" "" \
        "$(oneline "$(sed -e 's/#.*$//' "$checker" | grep -nE 'waiv' || true)")"

    # --- the canonical tree ----------------------------------------------------
    #
    # Every declared candidate present and nothing undeclared, with `current` a
    # SYMLINK to the versioned directory beside it, which is the measured shape:
    # an alias and a version, two paths, one file.
    for d in tools/python/root/usr/lib64 tools/python/root/usr/lib \
             tools/python/root/lib64 tools/python/root/lib \
             tools/python/python-3.13.9/lib tools/python/python-3.13.9/lib64 \
             tools/git/root/usr/lib64 tools/git/root/usr/lib \
             tools/git/root/lib64 tools/git/root/lib \
             tools/git/current/lib tools/git/current/lib64; do
        mkdir -p -- "$tree/$d" || { fail "step1/scratch" "cannot plant $d"; return; }
    done
    # RESOLVED IS NOT THE SAME AS ABLE, which is the distinction the capability
    # gate makes for every other tool and which this case used to miss. On the
    # Windows authoring host `ln` resolves and `ln -s` copies instead of linking,
    # so the plant silently produced a plain directory and the case reported a
    # code FAILURE for an environment that cannot answer it. It is measured now:
    # the symlink is asserted where one was actually made, and where the tool
    # resolved and could not make one the obligation is UNANSWERED, which is not
    # a pass either and names the host that would answer it.
    ln_bin=$(type -P ln 2>/dev/null) || ln_bin=""
    if [ -n "$ln_bin" ]; then
        "$ln_bin" -s -- python-3.13.9 "$tree/tools/python/current" 2>/dev/null
    fi
    if [ -L "$tree/tools/python/current" ]; then
        chk "step1/tree/alias-planted" "yes" "yes"
    else
        rm -rf -- "$tree/tools/python/current"
        mkdir -p -- "$tree/tools/python/current/lib" "$tree/tools/python/current/lib64"
        if [ -n "$ln_bin" ]; then
            found="$ln_bin resolved and could not make one"
        else
            found="ln did not resolve at all"
        fi
        note "step1/tree/alias-planted" "no symlink here: $found; current is a plain directory"
        unanswered "the alias half of the declared subdirectory case" \
          "  re-run on a host where ln -s makes a symlink, so tools/python/current is the alias the measured tree carries"
    fi

    # THE DECLARED SHAPE TOUCHES NO FILESYSTEM, driven rather than described. The
    # same declaration is derived against a prefix that exists and carries the
    # whole tree, and against one that does not exist at all; with the prefix
    # folded out the two must be identical.
    a=$(declared_shape "$tree" "$py" "$gitroot")
    b=$(declared_shape "$absent" "$py" "$gitroot")
    chk_list "step1/declared/no-filesystem" "${a//$tree/PREFIX}" "${b//$absent/PREFIX}"
    # The control that stops the case above being vacuous: the OBSERVED side does
    # depend on the filesystem, so the two prefixes are not interchangeable and
    # the declared side's independence is a real property rather than an accident
    # of two paths that happen to answer alike.
    chk "step1/declared/control/observed-does-depend" "yes" \
        "$( [ -n "$(build_elf_rpath_value "$tree" "$installer")" ] && echo yes || echo no )"
    chk "step1/declared/control/observed-empty-without-tree" "" \
        "$(build_elf_rpath_value "$absent" "$installer")"

    # `root` is a declared immediate subdirectory of every root BY CONSTRUCTION,
    # so declaring it changes nothing, and declaring a name twice changes nothing
    # either: the dedupe preserves the first occurrence.
    chk_list "step1/declared/root-by-construction" "$a" \
        "$(declared_shape "$tree" "python=root,current,python-3.13.9" "git=root,current")"
    chk_list "step1/declared/dedupe-preserves-first" "$a" \
        "$(declared_shape "$tree" "python=current,python-3.13.9,current" "git=current,current")"
    chk "step1/declared/count" "14" "$(printf '%s\n' "$a" | grep -c .)"

    # THE PROPERTY CASE. The checker's observed scope must equal what
    # `build_elf_rpath` prints, byte for byte, because it IS that function.
    chk_list "step1/observed/equals-build-elf-rpath" \
        "$(build_elf_rpath_value "$tree" "$installer")" \
        "$(observed_scope "$tree" "$installer")"
    # On the canonical tree the two scopes agree in content AND in order, which
    # is the statement that the declared derivation follows the loader's order
    # rather than merely producing the same set.
    chk_list "step1/observed/canonical-order-matches-declared" "$a" \
        "$(observed_scope "$tree" "$installer" | sed -e 's/:/\n/g')"

    section "step 1 classification: PRESENT, ABSENT and UNEXPECTED"
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$py" --root "$gitroot"
    chk "step1/canonical/exit-code" "0" "$CHECKER_RC"
    chk "step1/canonical/present" "14" "$(typed_count PRESENT)"
    chk "step1/canonical/absent" "0" "$(typed_count ABSENT)"
    chk "step1/canonical/unexpected" "0" "$(typed_count UNEXPECTED)"
    chk "step1/canonical/undetermined" "0" "$(typed_count UNDETERMINED)"
    # The alias and the version are BOTH declared subdirectories and BOTH
    # accepted. A version-shaped declaration would have refused the first.
    chk "step1/canonical/alias-present" "PRESENT|declared|$tree/tools/python/current/lib" \
        "$(typed_lines PRESENT | grep -F "/tools/python/current/lib" | grep -v 'lib64' || true)"
    chk "step1/canonical/version-present" \
        "PRESENT|declared|$tree/tools/python/python-3.13.9/lib" \
        "$(typed_lines PRESENT | grep -F "/tools/python/python-3.13.9/lib" | grep -v 'lib64' || true)"

    # A declared candidate absent under both roots is ACCEPTED and reported.
    rm -rf -- "$tree/tools/git/root/lib64"
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$py" --root "$gitroot"
    chk "step1/absent/exit-code" "0" "$CHECKER_RC"
    chk "step1/absent/named" "ABSENT|declared|$tree/tools/git/root/lib64" \
        "$(oneline "$(typed_lines ABSENT)")"
    mkdir -p -- "$tree/tools/git/root/lib64"

    # An immediate subdirectory under a declared root that the declaration does
    # not list: refused as UNEXPECTED, naming it.
    mkdir -p -- "$tree/tools/python/cplxunexpected/lib"
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$py" --root "$gitroot"
    chk "step1/unexpected-subdir/exit-code" "1" "$CHECKER_RC"
    chk "step1/unexpected-subdir/named" \
        "UNEXPECTED|observed|$tree/tools/python/cplxunexpected/lib|subdirectory|cplxunexpected" \
        "$(oneline "$(typed_lines UNEXPECTED)")"
    # Its control: the SAME tree with that subdirectory declared is accepted, so
    # the refusal is about the DECLARATION and not about the path.
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "python=current,python-3.13.9,cplxunexpected" --root "$gitroot"
    chk "step1/unexpected-subdir/control/declared-accepted" "0" "$CHECKER_RC"
    chk "step1/unexpected-subdir/control/no-refusal" "0" "$(typed_count UNEXPECTED)"
    rm -rf -- "$tree/tools/python/cplxunexpected"

    # The measured undeclared root, with a floor member living only under it.
    mkdir -p -- "$tree/tools/old/py3.13/lib"
    printf 'not an ELF, a placeholder for the floor member\n' \
        > "$tree/tools/old/py3.13/lib/libcplxfloor.so.1"
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$py" --root "$gitroot"
    chk "step1/unexpected-root/exit-code" "1" "$CHECKER_RC"
    chk "step1/unexpected-root/named" \
        "UNEXPECTED|observed|$tree/tools/old/py3.13/lib|root|old" \
        "$(oneline "$(typed_lines UNEXPECTED)")"
    # THE TWO RESULTS ARE VISIBLY INDEPENDENT. The root is refused, and the
    # directory holding the floor member is STILL in the observed loader scope,
    # so the loader would resolve there. The refusal is the only thing stopping
    # that resolution from counting, and this case is where a reader sees both
    # facts side by side rather than inferring one from the other.
    if printf '%s' "$(observed_scope "$tree" "$installer")" \
         | grep -qF "$tree/tools/old/py3.13/lib"; then found=yes; else found=no; fi
    chk "step1/unexpected-root/member-still-in-scope" "yes" "$found"
    chk "step1/unexpected-root/member-file-is-there" "yes" \
        "$( [ -f "$tree/tools/old/py3.13/lib/libcplxfloor.so.1" ] && echo yes || echo no )"
    # Its control, the same shape as the subdirectory one: declaring the root
    # accepts the tree, so the refusal names a declaration gap and nothing else.
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$py" --root "$gitroot" --root "old=py3.13"
    chk "step1/unexpected-root/control/declared-accepted" "0" "$CHECKER_RC"
    rm -rf -- "$tree/tools/old"

    # --- UNDETERMINED, which is an input that could not be obtained ------------
    section "step 1 UNDETERMINED: a scope that could not be observed"
    # An installer that refuses AT SOURCE TIME through `fatal`, which calls
    # `exit`. Sourced in the checker's own shell that would end the run; the
    # case exists to show it does not.
    step1_write_fatal_stub "$stubs/fatal.sh"
    run_checker "$checker" --prefix "$tree" --installer "$stubs/fatal.sh" \
        --root "$py" --root "$gitroot"
    chk "step1/undetermined/fatal/exit-is-the-checkers-own" "5" "$CHECKER_RC"
    chk "step1/undetermined/fatal/reports-the-status" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'status 3' && echo yes || echo no)"
    # NEVER AN EMPTY SCOPE. A checker that treated an unobtainable scope as an
    # empty one would report all fourteen declared candidates ABSENT and exit 0,
    # which reads exactly like a tree that is merely bare.
    chk "step1/undetermined/fatal/no-absent-line" "0" "$(typed_count ABSENT)"
    chk "step1/undetermined/fatal/no-present-line" "0" "$(typed_count PRESENT)"
    chk "step1/undetermined/fatal/every-candidate-undetermined" "15" \
        "$(typed_count UNDETERMINED)"
    # THE REPORT CONTINUES TO COMPLETION. The verdict line is the proof: a run
    # that inherited the sourced `exit` would have stopped before printing it.
    chk "step1/undetermined/fatal/report-completes" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE SCOPE UNDETERMINED' && echo yes || echo no)"

    # An installer that sources cleanly and defines no build_elf_rpath.
    printf '#!/bin/bash\nCPLX_STUB_SOURCED=1\n' > "$stubs/nofunction.sh"
    run_checker "$checker" --prefix "$tree" --installer "$stubs/nofunction.sh" \
        --root "$py" --root "$gitroot"
    chk "step1/undetermined/no-function/exit-code" "5" "$CHECKER_RC"
    chk "step1/undetermined/no-function/names-it" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'defines no build_elf_rpath' && echo yes || echo no)"

    # An installer whose build_elf_rpath returns non-zero.
    printf '#!/bin/bash\nbuild_elf_rpath() { return 7; }\n' > "$stubs/failing.sh"
    run_checker "$checker" --prefix "$tree" --installer "$stubs/failing.sh" \
        --root "$py" --root "$gitroot"
    chk "step1/undetermined/failing/exit-code" "5" "$CHECKER_RC"
    chk "step1/undetermined/failing/names-the-call" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'build_elf_rpath returned non-zero' && echo yes || echo no)"

    # An installer that is not there at all.
    run_checker "$checker" --prefix "$tree" --installer "$stubs/does-not-exist.sh" \
        --root "$py" --root "$gitroot"
    chk "step1/undetermined/absent-installer/exit-code" "5" "$CHECKER_RC"
    chk "step1/undetermined/absent-installer/names-the-path" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -qF "$stubs/does-not-exist.sh" && echo yes || echo no)"

    # THE CONTROL FOR ALL FOUR: the real installer over the same tree produces no
    # UNDETERMINED at all. Without it, a checker that reported UNDETERMINED
    # unconditionally would satisfy every case above.
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$py" --root "$gitroot"
    chk "step1/undetermined/control/real-installer" "0" "$(typed_count UNDETERMINED)"

    # --- the arguments ---------------------------------------------------------
    section "step 1 arguments: a usage error is not a verdict"
    run_checker "$checker" --prefix "$tree" --installer "$installer"
    chk "step1/args/no-root-declared" "2" "$CHECKER_RC"
    run_checker "$checker" --prefix "$tree" --root "$py" --installer
    chk "step1/args/missing-operand" "2" "$CHECKER_RC"
    run_checker "$checker" --unknown
    chk "step1/args/unknown-argument" "2" "$CHECKER_RC"
}

# ---------------------------------------------- the configuration module probes ---
# Every call reaches the module through its own file, in a CHILD PROCESS. Two
# reasons, and both are load bearing here: a syntax error in production code
# fails the case instead of killing the harness, and the parsed model one case
# leaves behind cannot reach the next, so a case that passes because a previous
# one populated a global is impossible by construction.
#
# 91 and 92 are the harness's own codes for "the seam did not hold", distinct
# from anything the module returns, which is 0 or 1.
CONFIG_OUT=""
CONFIG_RC=0
config_call() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    CONFIG_OUT=$("${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        fn="$2"
        shift 2
        declare -F "$fn" >/dev/null 2>&1 || exit 92
        "$fn" "$@"
    ' _ "$SHIPPED_DIR/closure_config.sh" "$@" 2>&1)
    CONFIG_RC=$?
}

# The same call, through the module that owns the CPLX-SIDE RESOLUTION since step
# 6. `closure_config_authority_check` moved to `closure_publish.sh` when the
# grammar module needed the room, because publication is the only party that can
# resolve a path at a commit: packaging and the Debian agent both run where there
# is no checkout. The six cases below therefore source the file that owns the
# function now, and sourcing it also brings in the grammar module it sources.
authority_call() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    CONFIG_OUT=$("${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        fn="$2"
        shift 2
        declare -F "$fn" >/dev/null 2>&1 || exit 92
        "$fn" "$@"
    ' _ "$SHIPPED_DIR/closure_publish.sh" "$@" 2>&1)
    CONFIG_RC=$?
}

# The parsed model, printed from the module's own globals rather than through a
# dump function the production code would carry for the tests alone. What a case
# asserts is what a later step will read.
config_model() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        closure_config_parse "$2" >/dev/null || exit 93
        k=""
        for k in ${CLOSURE_CFG_ROOTS[@]+"${CLOSURE_CFG_ROOTS[@]}"}; do
            printf "root %s\n" "$k"
        done
        for k in ${CLOSURE_CFG_FLOOR[@]+"${!CLOSURE_CFG_FLOOR[@]}"}; do
            printf "floor %s %s\n" "$k" "${CLOSURE_CFG_FLOOR[$k]}"
        done
        for k in ${CLOSURE_CFG_FAMILY[@]+"${!CLOSURE_CFG_FAMILY[@]}"}; do
            printf "family %s %s\n" "$k" "${CLOSURE_CFG_FAMILY[$k]}"
        done
        for k in ${CLOSURE_CFG_WAIVER[@]+"${!CLOSURE_CFG_WAIVER[@]}"}; do
            printf "waiver %s %s\n" "$k" "${CLOSURE_CFG_WAIVER[$k]}"
        done
    ' _ "$SHIPPED_DIR/closure_config.sh" "$1" 2>/dev/null | sort
}

config_root_specs() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        closure_config_parse "$2" >/dev/null || exit 93
        closure_config_root_specs
    ' _ "$SHIPPED_DIR/closure_config.sh" "$1" 2>/dev/null
}

config_digest() {
    config_call closure_config_digest "$1"
    printf '%s' "$CONFIG_OUT"
}

# The valid configuration example, exactly as the plan's grammar fixes it. Every
# negative case below mutates ONE record of a copy of this file, so a refusal is
# shown to be about that record rather than about the document, and its control
# is this same file unmutated.
step2_write_valid_config() {
    { printf 'CPLX-CLOSURE/1\n'
      printf 'root|python\n'
      printf 'root|git\n'
      printf 'subdir|python|root\n'
      printf 'subdir|python|current\n'
      printf 'floor|libc.so.6|any\n'
      printf 'floor|libsqlite3.so.0|tools/python\n'
      printf 'family|binutils-bfd|libbfd-*.so|1\n'
      printf 'waiver|libsqlite3.so.0|python-sqlite-support\n'; } > "$1"
}

# The same document with ONE record replaced. The mutation is planted and then
# asserted to be present, so a case cannot report a refusal for a document it
# never wrote.
step2_mutate() {
    local base="$1" out="$2" drop="$3" add="$4"
    grep -v "^$drop\$" "$base" > "$out"
    if [ -n "$add" ]; then printf '%s\n' "$add" >> "$out"; fi
}

step2_write_envelope() {
    { printf 'CPLX-CLOSURE-ENVELOPE/1\n'
      printf 'digest|%s\n' "$2"
      printf 'source|%s|%s\n' "$3" "$4"; } > "$1"
}

# =============================================================== the step 2 suite ===
step2_suite() {
    local dir="$SCRATCH/step2" repo="$SCRATCH/step2/repo" bundle="$SCRATCH/step2/bundle"
    local committed="$SHIPPED_DIR/../closure/closure-config.txt"
    local checker="$SHIPPED_DIR/closure_check.sh"
    local installer="$SHIPPED_DIR/install_pkg.sh"
    local module="$SHIPPED_DIR/closure_config.sh"
    local git_bin="" d1 d2 commit found tree

    mkdir -p -- "$dir" "$bundle" || { fail "step2/scratch" "cannot create the scratch directory"; return; }

    # --- the module is filled, and declares every command it runs -------------
    section "step 2 topology: the configuration module has a body now"
    if [ ! -f "$module" ]; then
        fail "step2/topology/module-exists" "no closure_config.sh at $module"
        unanswered "every step 2 case" \
          "  fill src/setups/env/bin/closure_config.sh, then repeat this call"
        return
    fi
    chk "step2/topology/module-is-filled" "yes" \
        "$( [ "$(module_body_lines "$module")" -gt 0 ] && echo yes || echo no )"
    chk "step2/topology/module-declared-commands" "" \
        "$(oneline "$(shipped_undeclared_words "$module")")"
    # The checker gains the call and nothing else, so the module has to be
    # reachable from it: an unsourced module would leave the bundle unread while
    # every scope case still passed.
    chk "step2/topology/checker-sources-the-module" "yes" \
        "$(sed -e 's/#.*$//' "$checker" | grep -q 'closure_config.sh' && echo yes || echo no)"

    # --- the committed declaration --------------------------------------------
    #
    # THE DOCUMENT IN THE TREE IS A SUBJECT, not a fixture. Every other case here
    # runs against a written fixture, and this one runs against the bytes the
    # archive will carry, so a committed document that stopped parsing would fail
    # here rather than in Step 5.
    section "step 2 declaration: the committed document, read as the archive will"
    if [ ! -f "$committed" ]; then
        fail "step2/committed/exists" "no closure-config.txt at $committed"
    else
        config_call closure_config_parse "$committed"
        chk "step2/committed/parses-clean" "0|" "$CONFIG_RC|$(oneline "$CONFIG_OUT")"
        chk "step2/committed/root-specs" \
            "python=root,current,python-3.13.9 git=root" \
            "$(oneline "$(config_root_specs "$committed")")"
        # The floor, the family list and the waiver, as the issue declares them.
        # Their count is asserted rather than their whole content, so this case
        # stays about the parser while the entries stay the issue's to own.
        chk "step2/committed/floor-count" "10" \
            "$(config_model "$committed" | grep -c '^floor ')"
        chk "step2/committed/family-count" "2" \
            "$(config_model "$committed" | grep -c '^family ')"
        chk "step2/committed/waiver-is-the-declared-one" \
            "waiver libsqlite3.so.0 python-sqlite-support" \
            "$(oneline "$(config_model "$committed" | grep '^waiver ')")"
        chk "step2/committed/sqlite-location-is-constrained" \
            "floor libsqlite3.so.0 tools/python" \
            "$(oneline "$(config_model "$committed" | grep '^floor libsqlite3')")"
    fi

    # --- the grammar, accepted -------------------------------------------------
    section "step 2 grammar: the valid example, and one envelope"
    step2_write_valid_config "$dir/valid.txt"
    config_call closure_config_parse "$dir/valid.txt"
    chk "step2/valid/config-parses" "0|" "$CONFIG_RC|$(oneline "$CONFIG_OUT")"
    chk "step2/valid/root-order-is-the-loaders" "python=root,current git=" \
        "$(oneline "$(config_root_specs "$dir/valid.txt")")"
    d1=$(config_digest "$dir/valid.txt")
    step2_write_envelope "$dir/valid-env.txt" "$d1" "a/b/closure-config.txt" \
        "0123456789abcdef0123456789abcdef01234567"
    config_call closure_envelope_parse "$dir/valid-env.txt"
    chk "step2/valid/envelope-parses" "0|" "$CONFIG_RC|$(oneline "$CONFIG_OUT")"
    # A comment line and a blank line are IGNORED here, because a human authors
    # both documents. The evidence document refuses them, and that difference is
    # Step 6's to assert on its own table.
    { printf '# a human wrote this\n'; printf '\n'; cat "$dir/valid.txt"; } > "$dir/commented.txt"
    config_call closure_config_parse "$dir/commented.txt"
    chk "step2/valid/comments-and-blanks-ignored" "0|" "$CONFIG_RC|$(oneline "$CONFIG_OUT")"

    # --- the grammar, refused --------------------------------------------------
    #
    # One planted defect per case, each naming its own refusal. The control for
    # all of them is `step2/valid/config-parses` above: the same document without
    # the mutation is accepted, so every refusal below is about the record it
    # names and not about the fixture.
    section "step 2 grammar: nine refusals, each named"
    # `git` and not `python`, because dropping the first root record would make
    # the document refuse the ORDER rule and break three cross-references with
    # it, and a case planting four defects proves none of them.
    step2_refuse "$dir" field-count 'root|git' 'root|git|extra' \
        field-count "root takes 2 fields and this record has 3"
    step2_refuse "$dir" duplicate-key '' 'root|git' \
        duplicate "root: git"
    step2_refuse "$dir" duplicate-subdir-pair '' 'subdir|python|current' \
        duplicate "subdir: python current"
    step2_refuse "$dir" undeclared-root-in-subdir 'subdir|python|current' 'subdir|perl|root' \
        cross-reference "subdir-root names the undeclared root perl"
    step2_refuse "$dir" absolute-floor-location 'floor|libc.so.6|any' 'floor|libc.so.6|/usr/lib' \
        domain "location: /usr/lib"
    step2_refuse "$dir" floor-location-undeclared-root 'floor|libc.so.6|any' 'floor|libc.so.6|tools/perl' \
        cross-reference "floor-root names the undeclared root perl"
    step2_refuse "$dir" two-wildcard-glob 'family|binutils-bfd|libbfd-*.so|1' 'family|binutils-bfd|lib*bfd*.so|1' \
        domain "soname-glob: lib*bfd*.so"
    step2_refuse "$dir" leading-zero-generations 'family|binutils-bfd|libbfd-*.so|1' 'family|binutils-bfd|libbfd-*.so|01' \
        domain "generations: 01"
    step2_refuse "$dir" waiver-not-on-the-floor 'waiver|libsqlite3.so.0|python-sqlite-support' 'waiver|libnothing.so.1|python-sqlite-support' \
        cross-reference "waiver names libnothing.so.1, which the floor does not declare"
    step2_refuse "$dir" unknown-record-token '' 'mount|somewhere' \
        unknown-record "mount"
    step2_refuse "$dir" undefined-escape 'floor|libc.so.6|any' 'floor|libc%2Fso.6|any' \
        escape "%2F is not a defined escape, and only %7C and %25 are"
    # Two more the shared lexical shape owns rather than the record table.
    step2_refuse "$dir" empty-field 'floor|libc.so.6|any' 'floor||any' \
        empty-field "a record may carry no empty field"
    step2_refuse "$dir" trailing-empty-field 'root|git' 'root|git|' \
        empty-field "a record may carry no empty field"
    step2_refuse "$dir" multi-segment-subdir 'subdir|python|current' 'subdir|python|a/b' \
        domain "subdir-name: a/b"
    # Ordering is significant for `root` and for nothing else, so the one order
    # rule that exists is asserted and its absence elsewhere is asserted with it.
    { printf 'CPLX-CLOSURE/1\n'; printf 'root|git\n'; printf 'root|python\n'; } > "$dir/order.txt"
    config_call closure_config_parse "$dir/order.txt"
    chk "step2/refuse/root-order" \
        "REFUSED|2|order|the first root record must be python, and this one is git" \
        "$(oneline "$CONFIG_OUT")"
    { printf 'CPLX-CLOSURE/1\n'; printf 'root|python\n'
      printf 'floor|libc.so.6|any\n'; printf 'subdir|python|current\n'; } > "$dir/reorder.txt"
    config_call closure_config_parse "$dir/reorder.txt"
    chk "step2/refuse/control/other-records-are-order-free" "0|" \
        "$CONFIG_RC|$(oneline "$CONFIG_OUT")"
    { printf 'CPLX-CLOSURE/1\nsubdir|python|current\nroot|python\n'; } > "$dir/forward.txt"
    config_call closure_config_parse "$dir/forward.txt"
    chk "step2/forward/subdir-before-root-accepted" "0|" "$CONFIG_RC|$(oneline "$CONFIG_OUT")"
    chk "step2/forward/subdir-before-root-retained" "python=current" \
        "$(oneline "$(config_root_specs "$dir/forward.txt")")"
    { printf 'CPLX-CLOSURE/1\nsubdir|python|current\nsubdir|python|current\nroot|python\n'; } > "$dir/forward-duplicate.txt"
    config_call closure_config_parse "$dir/forward-duplicate.txt"
    chk "step2/forward/duplicate-before-root-refused" "1|REFUSED|3|duplicate|subdir: python current" \
        "$CONFIG_RC|$(oneline "$CONFIG_OUT")"
    # A version line that is not this version, and a document with none at all.
    { printf 'CPLX-CLOSURE/2\n'; printf 'root|python\n'; } > "$dir/version.txt"
    config_call closure_config_parse "$dir/version.txt"
    chk "step2/refuse/version-line" \
        "REFUSED|1|version|the first record line must be CPLX-CLOSURE/1, and this one is CPLX-CLOSURE/2" \
        "$(oneline "$CONFIG_OUT")"

    # --- decoding precedes domain validation -----------------------------------
    #
    # THE PAIR IS THE PROOF, not either half. An undefined escape is refused as an
    # escape and never reaches its domain; a DEFINED escape is decoded and then
    # refused BY THE DOMAIN, naming the decoded value. Reversing the order would
    # have made the second case refuse on the raw text, and %2F would have passed
    # a no-slash domain and become a separator afterwards.
    section "step 2 order: decode, then validate, shown by the reason"
    step2_refuse "$dir" defined-escape-reaches-the-domain 'floor|libc.so.6|any' 'floor|libc%7Cso.6|any' \
        domain "lookup-name: libc|so.6"

    # --- the digest domain -----------------------------------------------------
    section "step 2 digest: the exact committed bytes, and nothing else"
    if [ "$(capability_state sha256sum)" != "supported" ]; then
        unanswered "the digest domain cases" \
          "  re-run on a host whose sha256sum answers its probe"
    else
        d1=$(config_digest "$dir/valid.txt")
        chk "step2/digest/is-64-lowercase-hex" "yes" \
            "$(printf '%s' "$d1" | grep -qE '^[0-9a-f]{64}$' && echo yes || echo no)"
        # THE SAME BYTES THROUGH A DIFFERENT PATH ARE THE SAME DOCUMENT. The
        # domain is the content and never the location, which is what lets the
        # archive and cplx reach the same value from two different trees.
        mkdir -p -- "$dir/elsewhere"
        cp -- "$dir/valid.txt" "$dir/elsewhere/renamed.txt"
        chk "step2/digest/same-bytes-other-path" "$d1" "$(config_digest "$dir/elsewhere/renamed.txt")"
        # CRLF IS A DIFFERENT DOCUMENT. No normalisation pass exists, so a line
        # ending is content, and a party that normalised before hashing would
        # produce a value nobody else can reproduce.
        sed -e 's/$/\r/' "$dir/valid.txt" > "$dir/crlf.txt"
        d2=$(config_digest "$dir/crlf.txt")
        chk "step2/digest/crlf-is-a-different-digest" "different" \
            "$( [ "$d1" != "$d2" ] && echo different || echo same )"
        # Its control: the CRLF document is still a document, so the difference
        # above is about bytes and not about one of the two files being empty.
        chk "step2/digest/control/crlf-still-digests" "yes" \
            "$(printf '%s' "$d2" | grep -qE '^[0-9a-f]{64}$' && echo yes || echo no)"
    fi

    # --- the envelope ----------------------------------------------------------
    section "step 2 envelope: five refusals the identity half owns"
    d1=$(config_digest "$dir/valid.txt")
    commit="0123456789abcdef0123456789abcdef01234567"
    step2_write_envelope "$dir/e-upper.txt" "${d1^^}" "a/b/c.txt" "$commit"
    config_call closure_envelope_parse "$dir/e-upper.txt"
    chk "step2/envelope/uppercase-digest" "yes" \
        "$(printf '%s' "$CONFIG_OUT" | grep -q 'domain|sha256' && echo yes || echo no)"
    step2_write_envelope "$dir/e-short.txt" "$d1" "a/b/c.txt" "9f2c"
    config_call closure_envelope_parse "$dir/e-short.txt"
    chk "step2/envelope/short-commit" "REFUSED|3|domain|commit: 9f2c" \
        "$(printf '%s' "$CONFIG_OUT" | grep '^REFUSED|3|')"
    step2_write_envelope "$dir/e-branch.txt" "$d1" "a/b/c.txt" "main"
    config_call closure_envelope_parse "$dir/e-branch.txt"
    chk "step2/envelope/branch-instead-of-a-commit" "REFUSED|3|domain|commit: main" \
        "$(printf '%s' "$CONFIG_OUT" | grep '^REFUSED|3|')"
    { printf 'CPLX-CLOSURE-ENVELOPE/1\n'; printf 'digest|%s\n' "$d1"
      printf 'digest|%s\n' "$d1"; printf 'source|a/b/c.txt|%s\n' "$commit"; } > "$dir/e-two.txt"
    config_call closure_envelope_parse "$dir/e-two.txt"
    chk "step2/envelope/two-digest-records" \
        "REFUSED|0|cardinality|the envelope carries 2 digest records and must carry exactly one" \
        "$(oneline "$CONFIG_OUT")"
    { printf 'CPLX-CLOSURE-ENVELOPE/1\n'; printf 'digest|%s\n' "$d1"; } > "$dir/e-nosource.txt"
    config_call closure_envelope_parse "$dir/e-nosource.txt"
    chk "step2/envelope/missing-source-record" \
        "REFUSED|0|cardinality|the envelope carries 0 source records and must carry exactly one" \
        "$(oneline "$CONFIG_OUT")"
    # The control: the same envelope with a 40-hex commit and one of each record
    # is accepted, so the five refusals above are about what they name.
    step2_write_envelope "$dir/e-ok.txt" "$d1" "a/b/c.txt" "$commit"
    config_call closure_envelope_parse "$dir/e-ok.txt"
    chk "step2/envelope/control/valid-envelope-accepted" "0|" \
        "$CONFIG_RC|$(oneline "$CONFIG_OUT")"
    { printf 'CPLX-CLOSURE-ENVELOPE/1\ndigest|%s|\nsource|a/b/c.txt|%s\n' "$d1" "$commit"; } > "$dir/e-trailing.txt"
    config_call closure_envelope_parse "$dir/e-trailing.txt"
    chk "step2/envelope/trailing-empty-field-refused" "1" "$CONFIG_RC"
    chk "step2/envelope/trailing-empty-field-named" \
        "REFUSED|2|empty-field|a record may carry no empty field" \
        "$(printf '%s' "$CONFIG_OUT" | grep '^REFUSED|2|')"

    # --- the agent, which checks consistency and not authority -----------------
    section "step 2 agent: internal consistency, and its limit said out loud"
    cp -- "$dir/valid.txt" "$bundle/closure-config.txt"
    step2_write_envelope "$bundle/closure-envelope.txt" "$d1" "cfg/closure-config.txt" "$commit"
    config_call closure_envelope_check "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
    chk "step2/agent/consistent-bundle-accepted" "0" "$CONFIG_RC"
    chk "step2/agent/verdict-is-typed" "yes" \
        "$(printf '%s' "$CONFIG_OUT" | grep -q "^CONSISTENT|$d1|" && echo yes || echo no)"
    chk "step2/agent/verdict-states-its-limit" "yes" \
        "$(printf '%s' "$CONFIG_OUT" | grep -q 'INTERNAL CONSISTENCY ONLY' && echo yes || echo no)"
    # A document that does not hash to the digest its envelope names: refused,
    # and the refusal carries both values so a reader can see which is which.
    printf 'floor|libextra.so.1|any\n' >> "$bundle/closure-config.txt"
    config_call closure_envelope_check "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
    chk "step2/agent/corrupted-document-refused" "1" "$CONFIG_RC"
    chk "step2/agent/refusal-names-both-digests" "yes" \
        "$(printf '%s' "$CONFIG_OUT" | grep -q "and its envelope names $d1" && echo yes || echo no)"
    chk "step2/agent/refusal-still-states-the-limit" "yes" \
        "$(printf '%s' "$CONFIG_OUT" | grep -q '^INCONSISTENT|INTERNAL CONSISTENCY ONLY' && echo yes || echo no)"
    # A bundle carrying no configuration at all. Absence is not a pass, and the
    # refusal names the path rather than reporting an empty declaration.
    cp -- "$dir/valid.txt" "$bundle/closure-config.txt"
    rm -f -- "$dir/absent-config.txt"
    config_call closure_envelope_check "$dir/absent-config.txt" "$bundle/closure-envelope.txt"
    chk "step2/agent/no-configuration-at-all" "1" "$CONFIG_RC"
    chk "step2/agent/absence-names-the-path" "yes" \
        "$(printf '%s' "$CONFIG_OUT" | grep -q "absent|no configuration document at $dir/absent-config.txt" && echo yes || echo no)"
    config_call closure_envelope_check "$bundle/closure-config.txt" "$dir/absent-envelope.txt"
    chk "step2/agent/no-envelope-at-all" "1" "$CONFIG_RC"

    # --- the three parties, and the paired edit --------------------------------
    #
    # THIS IS THE POINT OF THE WHOLE AREA and it is asserted from every side that
    # exists yet. A floor entry is deleted and the document re-hashed to match its
    # own envelope: the agent ACCEPTS, because internal consistency is all it can
    # read, and packaging REFUSES, because it resolves the authoritative document
    # from cplx and compares against that.
    section "step 2 authority: the paired edit, from every side that exists"
    git_bin=$(type -P git 2>/dev/null) || git_bin=""
    if [ -z "$git_bin" ] || [ "$(capability_state git)" != "supported" ]; then
        unanswered "the packaging side of the configuration authority" \
          "  re-run on a host that supplies git, where the cplx-side resolution can be exercised"
    else
        step2_build_repo "$repo" "$dir/valid.txt" || {
            fail "step2/authority/fixture" "cannot build the fixture repository at $repo"
            return
        }
        commit=$(git -C "$repo" rev-parse HEAD 2>/dev/null)
        chk "step2/authority/fixture-commit-is-40-hex" "yes" \
            "$(printf '%s' "$commit" | grep -qE '^[0-9a-f]{40}$' && echo yes || echo no)"
        cp -- "$dir/valid.txt" "$bundle/closure-config.txt"
        step2_write_envelope "$bundle/closure-envelope.txt" "$d1" "cfg/closure-config.txt" "$commit"
        authority_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/honest-bundle-accepted" "0" "$CONFIG_RC"
        chk "step2/authority/verdict-names-the-commit" "yes" \
            "$(printf '%s' "$CONFIG_OUT" | grep -q "^AUTHORITATIVE|$d1|$commit" && echo yes || echo no)"

        # The paired edit. The floor entry and its payload would go in one edit;
        # here the entry goes and the envelope is re-hashed to match.
        step2_mutate "$dir/valid.txt" "$bundle/closure-config.txt" 'floor|libsqlite3.so.0|tools/python' ''
        step2_mutate "$bundle/closure-config.txt" "$dir/paired.txt" 'waiver|libsqlite3.so.0|python-sqlite-support' ''
        cp -- "$dir/paired.txt" "$bundle/closure-config.txt"
        d2=$(config_digest "$bundle/closure-config.txt")
        chk "step2/authority/paired-edit-planted" "different" \
            "$( [ "$d1" != "$d2" ] && echo different || echo same )"
        step2_write_envelope "$bundle/closure-envelope.txt" "$d2" "cfg/closure-config.txt" "$commit"
        config_call closure_envelope_check "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/paired-edit/agent-ACCEPTS" "0" "$CONFIG_RC"
        authority_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/paired-edit/packaging-REFUSES" "1" "$CONFIG_RC"
        chk "step2/authority/paired-edit/refusal-names-both" "yes" \
            "$(printf '%s' "$CONFIG_OUT" | grep -q "authority|the embedded document hashes to $d2 and cplx holds $d1" && echo yes || echo no)"
        note "step2/authority/paired-edit/publication-REFUSES" \
             "pending: closure_publish.sh resolves the same way at the release commit; Step 5 asserts it"

        # An authentic bundle swapped for a DIFFERENT authentic bundle. Both are
        # internally consistent, so co-location binds nothing and only the party
        # that resolves for itself can tell them apart.
        step2_write_valid_config "$dir/other.txt"
        printf 'floor|libother.so.1|any\n' >> "$dir/other.txt"
        cp -- "$dir/other.txt" "$bundle/closure-config.txt"
        d2=$(config_digest "$bundle/closure-config.txt")
        step2_write_envelope "$bundle/closure-envelope.txt" "$d2" "cfg/closure-config.txt" "$commit"
        config_call closure_envelope_check "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/authentic-swap/agent-ACCEPTS" "0" "$CONFIG_RC"
        authority_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/authentic-swap/packaging-REFUSES" "1" "$CONFIG_RC"
        note "step2/authority/authentic-swap/publication-REFUSES" \
             "pending: publication resolves the digest itself rather than reading the archive's; Step 5 asserts it"

        # A commit that does not hold that configuration at that path.
        cp -- "$dir/valid.txt" "$bundle/closure-config.txt"
        step2_write_envelope "$bundle/closure-envelope.txt" "$d1" "cfg/not-there.txt" "$commit"
        authority_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/path-absent-at-that-commit" "1" "$CONFIG_RC"
        chk "step2/authority/path-absent-names-it" "yes" \
            "$(printf '%s' "$CONFIG_OUT" | grep -q "source|$commit holds no blob at cfg/not-there.txt" && echo yes || echo no)"

        # A 40-hexadecimal value that is not a commit object. The domain accepts
        # the shape, and the resolution refuses the OBJECT, which is the half a
        # lexical check alone cannot answer.
        d2=$(git -C "$repo" rev-parse HEAD:cfg/closure-config.txt 2>/dev/null)
        step2_write_envelope "$bundle/closure-envelope.txt" "$d1" "cfg/closure-config.txt" "$d2"
        authority_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/40-hex-that-is-a-blob" "1" "$CONFIG_RC"
        chk "step2/authority/40-hex-blob-names-the-type" "yes" \
            "$(printf '%s' "$CONFIG_OUT" | grep -q "names a blob in $repo rather than a commit" && echo yes || echo no)"
        # And a branch name, which the envelope domain refuses before the
        # resolution is ever reached: packaging cannot PRODUCE such a bundle.
        step2_write_envelope "$bundle/closure-envelope.txt" "$d1" "cfg/closure-config.txt" "develop"
        authority_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/branch-refused-before-resolution" "1" "$CONFIG_RC"
        chk "step2/authority/branch-refusal-is-lexical" "yes" \
            "$(printf '%s' "$CONFIG_OUT" | grep -q 'domain|commit: develop' && echo yes || echo no)"
    fi

    # --- the checker's own gate ------------------------------------------------
    #
    # A bundle that could not be established stops the run BEFORE any invariant.
    # The assertion is the absence of every typed scope line, not the exit code
    # alone: a checker that refused and still classified would have answered a
    # question against a declaration nobody could vouch for.
    section "step 2 gate: the bundle is read before anything else runs"
    tree="$SCRATCH/step2/prefix"
    mkdir -p -- "$tree/tools/python/root/lib" "$tree/tools/git/root/lib" || true
    # THE DECLARATION THIS TREE CARRIES IS NOW ONE IT HAS TO MEET. Step 4 filled
    # the declared floor half, so the valid example's two floor members have to be
    # in the observed scope or this run refuses on the FLOOR rather than on the
    # gate the section is about. They are planted as plain files because that is
    # what a provider is, a file of that name in a provider directory, and the
    # floor asks for presence rather than for content.
    printf 'not an ELF: the floor member the gate tree carries\n' \
        > "$tree/tools/python/root/lib/libc.so.6"
    printf 'not an ELF: the floor member the gate tree carries\n' \
        > "$tree/tools/python/root/lib/libsqlite3.so.0"
    # AND THE WAIVER GOES, for the same reason the members were planted. Step 5
    # made a waiver whose member is PRESENT a stale one, and the valid example
    # waives `libsqlite3.so.0` while the line above plants it, so the unmutated
    # example would now refuse here on the WAIVER rather than on the gate this
    # section is about. Dropping the record is the smaller change than leaving
    # the member out: this tree exists to carry a declaration it MEETS, and a
    # gate section that measured an active exception would be measuring step 5.
    # The shared example keeps the record, because the step 2 cases that mutate
    # it are the ones the record is there for.
    step2_mutate "$dir/valid.txt" "$bundle/closure-config.txt" \
        'waiver|libsqlite3.so.0|python-sqlite-support' ''
    d1=$(config_digest "$bundle/closure-config.txt")
    step2_write_envelope "$bundle/closure-envelope.txt" "$d1" "cfg/closure-config.txt" \
        "0123456789abcdef0123456789abcdef01234567"
    run_checker "$checker" --prefix "$tree" --installer "$installer" --bundle "$bundle"
    chk "step2/gate/good-bundle-exit-code" "0" "$CHECKER_RC"
    chk "step2/gate/roots-came-from-the-bundle" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'source      the bundle at' && echo yes || echo no)"
    chk "step2/gate/roots-are-the-declared-ones" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'roots       python=root,current git=' && echo yes || echo no)"
    chk "step2/gate/report-states-the-limit" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'internal consistency and NOT authority' && echo yes || echo no)"
    chk "step2/gate/report-carries-the-digest" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q "digest      $d1, the sha256sum" && echo yes || echo no)"
    # Its control and the point of the section: corrupt the document and the same
    # call produces NO typed scope line at all.
    printf 'floor|libextra.so.1|any\n' >> "$bundle/closure-config.txt"
    run_checker "$checker" --prefix "$tree" --installer "$installer" --bundle "$bundle"
    chk "step2/gate/bad-bundle-exit-code" "1" "$CHECKER_RC"
    chk "step2/gate/bad-bundle-refuses-by-name" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE BUNDLE REFUSED' && echo yes || echo no)"
    chk "step2/gate/bad-bundle-ran-no-invariant" "0|0|0" \
        "$(typed_count PRESENT)|$(typed_count ABSENT)|$(typed_count UNEXPECTED)"
    # An explicit --root still wins over the bundle, which is what keeps every
    # step 1 case driving the classification from a shape the document does not
    # carry.
    # THE SAME BUNDLE THIS SECTION ESTABLISHED, restored rather than replaced by
    # the shared example: the envelope above carries the digest of the
    # waiver-stripped document, so copying the unmutated one back would refuse on
    # the digest and this case would report a bundle failure as a root-precedence
    # failure.
    step2_mutate "$dir/valid.txt" "$bundle/closure-config.txt" \
        'waiver|libsqlite3.so.0|python-sqlite-support' ''
    run_checker "$checker" --prefix "$tree" --installer "$installer" --bundle "$bundle" \
        --root "python=current"
    chk "step2/gate/explicit-root-wins" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'source      the --root arguments' && echo yes || echo no)"
    # And the two ways of declaring nothing are still a usage error rather than a
    # verdict, because a defaulted declaration would be an invented one.
    run_checker "$checker" --prefix "$tree" --installer "$installer"
    chk "step2/gate/neither-root-nor-bundle" "2" "$CHECKER_RC"
}

# One planted grammar defect, its refusal, and the control that the same document
# without it is accepted. The mutation is asserted to be IN the file before the
# parser is asked, so a case cannot report a refusal for a record it never wrote.
#
# THE LINE NUMBER IS DERIVED FROM THE PLANTED FIXTURE, never written into the
# expectation. The mutated record is always the last line, so its number is the
# file's line count; hard-coding it instead made the expectation depend on how
# many records the base document happens to carry, which is a fact about the
# fixture rather than about the refusal being asserted.
step2_refuse() {
    local dir="$1" label="$2" drop="$3" add="$4" code="$5" detail="$6"
    local file="$dir/refuse-$label.txt" n
    step2_mutate "$dir/valid.txt" "$file" "$drop" "$add"
    if ! grep -Fqx "$add" "$file"; then
        fail "step2/refuse/$label" "the mutation was not planted: $add"
        return
    fi
    n=$(grep -c '' "$file")
    config_call closure_config_parse "$file"
    chk "step2/refuse/$label" "REFUSED|$n|$code|$detail" "$(oneline "$CONFIG_OUT")"
}

# The fixture repository the cplx-side resolution reads. It is built here rather
# than pointed at cplx itself: the case needs a commit that holds a KNOWN
# document at a known path, and reading this repository's own history would make
# the case depend on what happened to be committed when it ran.
step2_build_repo() {
    local repo="$1" config="$2"
    rm -rf -- "$repo"
    mkdir -p -- "$repo/cfg" || return 1
    cp -- "$config" "$repo/cfg/closure-config.txt" || return 1
    git -C "$repo" init -q . >/dev/null 2>&1 || return 1
    git -C "$repo" config user.email closure@example.invalid >/dev/null 2>&1 || return 1
    git -C "$repo" config user.name closure >/dev/null 2>&1 || return 1
    git -C "$repo" add -A >/dev/null 2>&1 || return 1
    git -C "$repo" commit -q -m "the reviewed declaration" >/dev/null 2>&1 || return 1
    return 0
}

# The stub installer that refuses at source time, shaped like the installer's own
# `fatal`: it prints and then calls `exit`. Written through a single-quoted
# variable rather than a heredoc so the dollar-brace operands reach the file
# unexpanded, and with no `cat`, which is not one of the harness's declared
# prerequisites. `build_elf_rpath` IS defined here, and is never reached: the
# case is about a refusal during sourcing, not about a missing function, and the
# next case covers that one separately.
step1_write_fatal_stub() {
    # shellcheck disable=SC2016  # the stub's own body, expanded when the stub runs
    local body='fatal() { echo " FATAL ${2} : [stub] ${1}" >&2; exit "${2}"; }'
    { printf '#!/bin/bash\n'
      printf '%s\n' "$body"
      printf 'build_elf_rpath() { return 0; }\n'
      printf 'fatal "the sourced installer refuses" 3\n'; } > "$1"
}

# ------------------------------------------------------------ the fixture engine ---
# Q07's decision, in code: an ELF with a real dynamic section cannot be conjured
# from text, so the harness FINDS a donor on the host, VALIDATES it against the
# corpus donor row, copies it, applies the row's mutation and ASSERTS the row's
# semantic result before any case may use the object.
#
# THE ENGINE NEVER REBUILDS AN ELF. It writes a name into the reserved tail of
# the donor's own `.dynstr` and repoints one dynamic entry at that offset, which
# is why no fixture name is bounded by the length of the string it replaces. The
# corpus header states the same mechanism where the rows live.
#
# `dd` and `readelf` are the engine's own tools and are resolved HERE rather than
# in the harness preflight: the step 0 refusal cases re-invoke this file with a
# PATH holding exactly the preflight list, and every name added there widens the
# environment those cases run in. A host that cannot supply one of these reports
# UNANSWERED naming it, which is not a pass.
FIXTURE_READELF=""
FIXTURE_DD=""
# The four magic bytes, held once so no case has to spell them inline.
FIXTURE_ELF_MAGIC=$'\x7fELF'

fixture_resolve_tools() {
    FIXTURE_READELF=$(type -P readelf 2>/dev/null) || FIXTURE_READELF=""
    FIXTURE_DD=$(type -P dd 2>/dev/null) || FIXTURE_DD=""
    [ -n "$FIXTURE_READELF" ] && [ -n "$FIXTURE_DD" ]
}

# "<file-offset> <size>", both decimal, of one section, read from readelf's own
# section table rather than from the section headers by hand. The comparison is a
# string equality over the split row and not a regular expression: a section name
# carries a dot, and an expression would have to be escaped at every call site.
elf_section() {
    local file="$1" want="$2" line
    while IFS= read -r line; do
        line="${line#*]}"
        # shellcheck disable=SC2086  # readelf's own fixed columns, split on purpose
        set -- $line
        [ "${1:-}" = "$want" ] || continue
        printf '%s %s' "$(( 16#$4 ))" "$(( 16#$5 ))"
        return 0
    done <<< "$(LC_ALL=C "$FIXTURE_READELF" -S -W -- "$file" 2>/dev/null)"
    return 1
}

elf_dyn_lines() { LC_ALL=C "$FIXTURE_READELF" -d -- "$1" 2>/dev/null | grep -E '^ 0x' || true; }
elf_dyn_used()  { elf_dyn_lines "$1" | grep -c . || true; }
elf_dyn_count() { elf_dyn_lines "$1" | grep -c "($2)" || true; }

# The 0-based slot index of the first entry of that type. readelf walks the
# dynamic array in order and stops after DT_NULL, so its Nth printed entry is
# slot N and the terminator's index is where the spare slots begin.
elf_dyn_slot() {
    local file="$1" want="$2" n=0 line
    while IFS= read -r line; do
        case "$line" in
            *"($want)"*) printf '%s' "$n"; return 0 ;;
        esac
        n=$(( n + 1 ))
    done <<< "$(elf_dyn_lines "$file")"
    return 1
}

elf_needed_names() {
    LC_ALL=C "$FIXTURE_READELF" -d -- "$1" 2>/dev/null \
      | grep -E '\(NEEDED\)' | sed -e 's/^.*\[//' -e 's/\].*$//' || true
}

elf_soname() {
    LC_ALL=C "$FIXTURE_READELF" -d -- "$1" 2>/dev/null \
      | grep -E '\(SONAME\)' | sed -e 's/^.*\[//' -e 's/\].*$//' || true
}

elf_poke_u64() {
    local file="$1" off="$2" val="$3" i esc=""
    for i in 0 1 2 3 4 5 6 7; do
        esc="$esc\\x$(printf '%02x' $(( (val >> (8 * i)) & 255 )))"
    done
    # shellcheck disable=SC2059  # the escapes ARE the format string here
    printf "$esc" | "$FIXTURE_DD" of="$file" bs=1 seek="$off" conv=notrunc status=none 2>/dev/null
}

elf_poke_str() {
    printf '%s\0' "$3" | "$FIXTURE_DD" of="$1" bs=1 seek="$2" conv=notrunc status=none 2>/dev/null
}

# --- the name slots, which are MEASURED and were once assumed -----------------
#
# THE ENGINE USED TO TAKE THE LAST 256 BYTES OF `.dynstr` AS RESERVED, and round
# 1 of the step 6 review is what that cost. A reserved tail is a property of a
# DONOR and not of the format. On the Debian agent's donor the referenced
# dynamic strings sit exactly there, so a fixture name written over them left
# the donor's OWN entries pointing into the middle of it and `readelf` reported
# needs such as `.1` and `so.1`: fifteen step 3 cases and ten step 4 cases failed
# on that agent while every one of them passed on the build host, against the
# same harness bytes. A cross-distribution failure with one cause.
#
# WHAT IS ACTUALLY FREE is everything the checker cannot read. `.dynstr` holds
# the dynamic SYMBOL names as well as the names dynamic entries and version
# records point at, and nothing in this effort reads a symbol name. So the window
# is chosen by measuring the referenced strings and taking the first run between
# them that is wide enough, and a donor with no such run is not a donor.
FIXTURE_SLOT_COUNT=4
FIXTURE_SLOT_SIZE=64

# Every name a dynamic entry or a version record points at, which is the whole
# set of `.dynstr` content this effort's readers can reach.
elf_referenced_names() {
    LC_ALL=C "$FIXTURE_READELF" -d -- "$1" 2>/dev/null \
      | grep -E '\((NEEDED|SONAME|RPATH|RUNPATH)\)' | sed -e 's/^.*\[//' -e 's/\].*$//'
    LC_ALL=C "$FIXTURE_READELF" -V -W -- "$1" 2>/dev/null \
      | sed -n -e 's/.*Name: \([^ ][^ ]*\).*/\1/p' -e 's/.*File: \([^ ][^ ]*\).*/\1/p'
}

# The dynstr-relative offset of the first run of unreferenced bytes wide enough
# to hold every slot, or nothing. The table is walked as the NUL-delimited
# records it is, so each stored string's own offset is the sum of what came
# before it, and a reference into the MIDDLE of a stored string is covered by
# testing the whole string for the referenced name as a suffix.
elf_slot_base() {
    local file="$1" ds_off="" ds_size="" names="" s="" len=0 pos=0 start=1
    local need=0 hit=0 n=""
    read -r ds_off ds_size <<< "$(elf_section "$file" .dynstr)"
    if [ -z "${ds_size:-}" ]; then return 1; fi
    names=$(elf_referenced_names "$file" | grep -v '^$' | sort -u)
    if [ -z "$names" ]; then return 1; fi
    need=$(( FIXTURE_SLOT_COUNT * FIXTURE_SLOT_SIZE ))
    while IFS= read -r -d '' s; do
        len=${#s}
        hit=0
        if [ -n "$s" ]; then
            while IFS= read -r n; do
                case "$s" in *"$n") hit=1; break ;; esac
            done <<< "$names"
        fi
        if [ "$hit" -eq 1 ]; then
            start=$(( pos + len + 1 ))
        elif [ $(( pos + len + 1 - start )) -ge "$need" ]; then
            printf '%s' "$start"
            return 0
        fi
        pos=$(( pos + len + 1 ))
    done < <("$FIXTURE_DD" if="$file" bs=1 skip="$ds_off" count="$ds_size" status=none 2>/dev/null)
    return 1
}

# One span of a file, digested, so a case can say which bytes a mutation left
# alone. A count of zero or less digests nothing and prints the empty answer for
# both sides, which is the right result for a window that reaches an edge.
dynstr_span_digest() {
    local file="$1" off="$2" count="$3" out=""
    if [ "$count" -le 0 ]; then printf 'empty'; return 0; fi
    out=$("$FIXTURE_DD" if="$file" bs=1 skip="$off" count="$count" status=none 2>/dev/null \
          | sha256sum 2>/dev/null)
    printf '%s' "${out%% *}"
}

# One slot of that window, as a dynstr-relative offset. Slot 0 is the one a
# single-mutation row uses; the other three exist for the rows a later step
# fills. It is computed on a PRISTINE copy of the donor, before the first poke,
# which is why every caller reads it before it writes.
elf_name_slot() {
    local base=""
    base=$(elf_slot_base "$1") || return 1
    if [ -z "$base" ]; then return 1; fi
    printf '%s' "$(( base + $2 * FIXTURE_SLOT_SIZE ))"
}

# --- donor validation, against the corpus rows and nothing else ---------------
donor_valid_shared() {
    local f="$1" hdr ds_size dy_size used
    hdr=$(LC_ALL=C "$FIXTURE_READELF" -h -- "$f" 2>/dev/null) || return 1
    printf '%s\n' "$hdr" | grep -qE 'Class: +ELF64' || return 1
    printf '%s\n' "$hdr" | grep -q 'little endian' || return 1
    printf '%s\n' "$hdr" | grep -qE 'Type: +DYN' || return 1
    LC_ALL=C "$FIXTURE_READELF" -l -W -- "$f" 2>/dev/null | grep -q 'DYNAMIC' || return 1
    elf_dyn_slot "$f" SONAME >/dev/null 2>&1 || return 1
    [ "$(elf_dyn_count "$f" NEEDED)" -ge 1 ] || return 1
    read -r _ ds_size <<< "$(elf_section "$f" .dynstr)"
    [ -n "${ds_size:-}" ] && [ "$ds_size" -ge 512 ] || return 1
    read -r _ dy_size <<< "$(elf_section "$f" .dynamic)"
    [ -n "${dy_size:-}" ] || return 1
    used=$(elf_dyn_used "$f")
    [ "$(( dy_size / 16 - used ))" -ge 1 ] || return 1
    # STEP 4'S TWO ADDED PARTS, and they are requirements rather than hopes: a
    # version record cannot be created from text either, so a donor with no
    # version need to repoint and no second version definition to rename cannot
    # build a coherence fixture at all.
    [ "$(elf_verneed_nodes "$f")" -ge 1 ] || return 1
    elf_verdef_second "$f" >/dev/null 2>&1 || return 1
    # AND THE NAME SLOTS HAVE TO EXIST, which round 1 of the step 6 review turned
    # from an assumption into a requirement: a donor whose `.dynstr` has no run
    # of unreferenced bytes wide enough cannot carry a fixture name without
    # overwriting a string its own dynamic entries point at.
    elf_slot_base "$f" >/dev/null 2>&1 || return 1
    return 0
}

donor_valid_program() {
    local f="$1" hdr phdr
    hdr=$(LC_ALL=C "$FIXTURE_READELF" -h -- "$f" 2>/dev/null) || return 1
    printf '%s\n' "$hdr" | grep -qE 'Class: +ELF64' || return 1
    printf '%s\n' "$hdr" | grep -qE 'Type: +(DYN|EXEC)' || return 1
    phdr=$(LC_ALL=C "$FIXTURE_READELF" -l -W -- "$f" 2>/dev/null) || return 1
    printf '%s\n' "$phdr" | grep -q 'INTERP' || return 1
    printf '%s\n' "$phdr" | grep -q 'DYNAMIC' || return 1
    # The same measured requirement as the shared donor: the rows that add a need
    # to a PROGRAM write a name into its string table too.
    elf_slot_base "$f" >/dev/null 2>&1 || return 1
    return 0
}

# The first candidate that validates, over the two library layouts this effort's
# hosts use. It is bounded on purpose: a host with no valid donor must refuse in
# a moment rather than walk its whole filesystem looking for one.
donor_find_shared() {
    local c tried=0
    for c in /usr/lib64/libz.so.1 /usr/lib64/libbz2.so.1 /usr/lib64/liblzma.so.5 \
             /usr/lib64/libcap.so.2 /usr/lib64/libffi.so.8 \
             /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libbz2.so.1 \
             /lib/x86_64-linux-gnu/liblzma.so.5 /lib/x86_64-linux-gnu/libcap.so.2 \
             /usr/lib64/lib*.so.[0-9] /lib/x86_64-linux-gnu/lib*.so.[0-9]; do
        [ -f "$c" ] || continue
        tried=$(( tried + 1 ))
        [ "$tried" -le 60 ] || return 1
        if donor_valid_shared "$c"; then printf '%s' "$c"; return 0; fi
    done
    return 1
}

donor_find_program() {
    local c
    for c in /bin/cat /usr/bin/cat /bin/id /usr/bin/id "${BASH:-/bin/bash}"; do
        [ -f "$c" ] || continue
        if donor_valid_program "$c"; then printf '%s' "$c"; return 0; fi
    done
    return 1
}

# --- one corpus row, planted and asserted -------------------------------------
CORPUS_ROW_KIND=""
CORPUS_ROW_DONOR=""
CORPUS_ROW_PLACE=""
CORPUS_ROW_MUT=""
CORPUS_ROW_ASSERT=""
DONOR_SHARED=""
DONOR_PROGRAM=""
DONOR_NEED_NAMES=""

corpus_load_row() {
    local row
    row=$(grep -E "^spec\|$1\|" "$CORPUS" | sed -n 1p)
    [ -n "$row" ] || return 1
    IFS='|' read -r _ _ CORPUS_ROW_KIND CORPUS_ROW_DONOR CORPUS_ROW_PLACE \
        CORPUS_ROW_MUT CORPUS_ROW_ASSERT <<< "$row"
    return 0
}

# How many alias pairs `plant-alias-pairs` builds. The cost case sets it twice.
FIXTURE_ALIAS_PAIRS=4

# One alias pair: a versioned target carrying the soname, the soname link beside
# it, and a consumer that names the soname. The three together are what makes a
# link SELECTED, which is the only kind of link the reachability rule resolves.
fixture_alias_pair() {
    local prefix="$1" dir="$2" i="$3"
    local target="$prefix/$dir/libcplxscale$i.so.1.2.3"
    local link="$prefix/$dir/libcplxscale$i.so.1"
    local user="$prefix/tools/python/current/lib/libcplxscaleuser$i.so.1"

    fixture_copy_donor "$DONOR_SHARED" "$target" || return 1
    elf_set_string_entry "$target" SONAME "libcplxscale$i.so.1" || return 1
    rm -f -- "$link"
    ln -s -- "$target" "$link" || return 1
    fixture_copy_donor "$DONOR_SHARED" "$user" || return 1
    elf_add_needed "$user" "libcplxscale$i.so.1" || return 1
}

# The two mutations the engine performs, factored out of `fixture_plant` so the
# cost fixture builds the same objects the corpus rows describe rather than a
# second implementation of them.
elf_set_string_entry() {
    local file="$1" tag="$2" value="$3" ds_off ds_size dy_off dy_size slot idx
    read -r ds_off ds_size <<< "$(elf_section "$file" .dynstr)"
    read -r dy_off dy_size <<< "$(elf_section "$file" .dynamic)"
    if [ -z "${ds_size:-}" ] || [ -z "${dy_size:-}" ]; then return 1; fi
    slot=$(elf_name_slot "$file" 0) || return 1
    elf_poke_str "$file" $(( ds_off + slot )) "$value"
    idx=$(elf_dyn_slot "$file" "$tag") || return 1
    elf_poke_u64 "$file" $(( dy_off + idx * 16 + 8 )) "$slot"
}

elf_add_needed() {
    local file="$1" value="$2" ds_off ds_size dy_off dy_size slot idx
    read -r ds_off ds_size <<< "$(elf_section "$file" .dynstr)"
    read -r dy_off dy_size <<< "$(elf_section "$file" .dynamic)"
    if [ -z "${ds_size:-}" ] || [ -z "${dy_size:-}" ]; then return 1; fi
    slot=$(elf_name_slot "$file" 0) || return 1
    elf_poke_str "$file" $(( ds_off + slot )) "$value"
    idx=$(elf_dyn_slot "$file" NULL) || return 1
    elf_poke_u64 "$file" $(( dy_off + idx * 16 )) 1
    elf_poke_u64 "$file" $(( dy_off + idx * 16 + 8 )) "$slot"
}


# --- the version records, which Step 4's coherence cases turn on ---------------
#
# THE ENGINE STILL REBUILDS NOTHING. A version need and a version definition are
# fixed-size records pointing into `.dynstr`, exactly as a dynamic entry is, so a
# mutation writes a name into a reserved slot and repoints one field at it. What
# it cannot do is CREATE a section, which is why the shared donor now has to carry
# one version need and at least two version definitions: an object with no
# `.gnu.version_r` cannot be given one from text either.
#
# The offsets are read from readelf's own first column rather than computed, so a
# donor whose linker laid the entries out differently is followed rather than
# assumed. The one layout fact taken as fixed is `vd_aux`, the 20-byte header of
# an `Elf64_Verdef`, which every linker-produced definition carries; the row's
# assert is what catches a donor where that does not hold.
elf_poke_u16() {
    local file="$1" off="$2" val="$3" esc="" i
    for i in 0 1; do
        esc="$esc\\x$(printf '%02x' $(( (val >> (8 * i)) & 255 )))"
    done
    # shellcheck disable=SC2059  # the escapes ARE the format string here
    printf "$esc" | "$FIXTURE_DD" of="$file" bs=1 seek="$off" conv=notrunc status=none 2>/dev/null
}

elf_poke_u32() {
    local file="$1" off="$2" val="$3" esc="" i
    for i in 0 1 2 3; do
        esc="$esc\\x$(printf '%02x' $(( (val >> (8 * i)) & 255 )))"
    done
    # shellcheck disable=SC2059  # the escapes ARE the format string here
    printf "$esc" | "$FIXTURE_DD" of="$file" bs=1 seek="$off" conv=notrunc status=none 2>/dev/null
}

elf_version_block() {
    LC_ALL=C "$FIXTURE_READELF" -V -- "$1" 2>/dev/null | sed -n "/$2/,/^\$/p"
}

# The file offset of one section HEADER, which is where a section's entry count
# lives. `readelf` prints the two header-table figures and the section index, so
# the arithmetic is over values the reader gave rather than over a layout guess.
elf_shdr_offset() {
    local file="$1" want="$2" hdr shoff shent line n rest idx=""
    hdr=$(LC_ALL=C "$FIXTURE_READELF" -h -- "$file" 2>/dev/null) || return 1
    shoff=$(printf '%s\n' "$hdr" | sed -n 's/^ *Start of section headers: *\([0-9]*\).*$/\1/p')
    shent=$(printf '%s\n' "$hdr" | sed -n 's/^ *Size of section headers: *\([0-9]*\).*$/\1/p')
    [ -n "$shoff" ] && [ -n "$shent" ] || return 1
    while IFS= read -r line; do
        case "$line" in
            *'['*']'*) ;;
            *) continue ;;
        esac
        n="${line#*[}"
        n="${n%%]*}"
        n="${n// /}"
        rest="${line#*]}"
        # shellcheck disable=SC2086  # readelf's own fixed columns, split on purpose
        set -- $rest
        [ "${1:-}" = "$want" ] || continue
        idx="$n"
        break
    done <<< "$(LC_ALL=C "$FIXTURE_READELF" -S -W -- "$file" 2>/dev/null)"
    [ -n "$idx" ] || return 1
    printf '%s' "$(( shoff + idx * shent ))"
}

# `sh_info` of a version section, which is the number of entries readelf reads
# out of it. Absent section, nothing to set: a program donor carries no version
# definitions and that is not a fixture failure.
elf_set_version_count() {
    local file="$1" section="$2" count="$3" off
    off=$(elf_shdr_offset "$file" "$section") || return 0
    elf_poke_u32 "$file" $(( off + 44 )) "$count"
}

# "<verneed-offset> <first-aux-offset>", both decimal and both relative to the
# section, read from the offsets readelf prints in its first column.
elf_verneed_offsets() {
    local line tok vn="" aux=""
    while IFS= read -r line; do
        tok="${line%%:*}"
        tok="${tok// /}"
        tok="${tok#0x}"
        case "$line" in
            *'Version: '*'File: '*)
                if [ -z "$vn" ]; then vn=$(( 16#$tok )); fi ;;
            *'Name: '*)
                if [ -n "$vn" ] && [ -z "$aux" ]; then aux=$(( 16#$tok )); fi ;;
        esac
    done <<< "$(elf_version_block "$1" 'Version needs section')"
    [ -n "$vn" ] && [ -n "$aux" ] || return 1
    printf '%s %s' "$vn" "$aux"
}

# The offset of the SECOND version definition, which is the first one that is not
# the object's own BASE entry and therefore the one a mutation may rename.
elf_verdef_second() {
    local line tok n=0
    while IFS= read -r line; do
        case "$line" in
            *'Rev: '*) ;;
            *) continue ;;
        esac
        n=$(( n + 1 ))
        if [ "$n" -ne 2 ]; then continue; fi
        tok="${line%%:*}"
        tok="${tok// /}"
        tok="${tok#0x}"
        printf '%s' "$(( 16#$tok ))"
        return 0
    done <<< "$(elf_version_block "$1" 'Version definition section')"
    return 1
}

elf_verneed_nodes() {
    elf_version_block "$1" 'Version needs section' | grep -c 'Name: ' || true
}

# A DONOR COPY CARRIES ONLY THE VERSION RECORDS ITS ROW ASKS FOR, and none of the
# donor's own. THE REASON IS MEASURED: the name slots are the tail of `.dynstr`,
# and on the RHEL 9.8 donor that tail holds VERSION DEFINITION names, so writing
# slot 1 renamed two definitions and emptied a third. Step 3 never noticed because
# nothing read those names; Step 4's checker does, and an object with a definition
# whose name cannot be read is one the reader must refuse. Clearing the counts is
# what keeps a mutation from producing a subject the checker cannot read, and it
# also keeps every generated object's version records EXACTLY what its row states.
fixture_copy_donor() {
    cp -- "$1" "$2" || return 1
    chmod u+w -- "$2" || return 1
    elf_set_version_count "$2" .gnu.version_d 0
    elf_set_version_count "$2" .gnu.version_r 0
}

# The donor's own version need, repointed at one provider and one node, WITH the
# matching DT_NEEDED added. Both halves are the fixture: a version need is
# recorded against a library the object also needs, and an object demanding a node
# from a library it never names is not a shape any archive has.
#
# The record offsets are read from the DONOR rather than from the copy, because
# the copy's counts are cleared and a reader shows no entries to take an offset
# from. A poke moves no byte, so the two layouts are the same.
elf_set_verneed() {
    local file="$1" provider="$2" node="$3"
    local ds_off ds_size vr_off vr_size dy_off dy_size off vn aux slot1 slot2 idx
    read -r ds_off ds_size <<< "$(elf_section "$file" .dynstr)"
    read -r vr_off vr_size <<< "$(elf_section "$file" .gnu.version_r)"
    read -r dy_off dy_size <<< "$(elf_section "$file" .dynamic)"
    if [ -z "${ds_size:-}" ] || [ -z "${vr_size:-}" ] || [ -z "${dy_size:-}" ]; then return 1; fi
    off=$(elf_verneed_offsets "$DONOR_SHARED") || return 1
    read -r vn aux <<< "$off"
    slot1=$(elf_name_slot "$file" 1) || return 1
    slot2=$(elf_name_slot "$file" 2) || return 1
    elf_poke_str "$file" $(( ds_off + slot1 )) "$provider"
    elf_poke_str "$file" $(( ds_off + slot2 )) "$node"
    elf_poke_u32 "$file" $(( vr_off + vn + 4 )) "$slot1"
    # ONE aux, so the donor's remaining GLIBC nodes stop being demanded from a
    # provider that was never meant to define them.
    elf_poke_u16 "$file" $(( vr_off + vn + 2 )) 1
    elf_poke_u32 "$file" $(( vr_off + aux + 8 )) "$slot2"
    idx=$(elf_dyn_slot "$file" NULL) || return 1
    elf_poke_u64 "$file" $(( dy_off + idx * 16 )) 1
    elf_poke_u64 "$file" $(( dy_off + idx * 16 + 8 )) "$slot1"
    elf_set_version_count "$file" .gnu.version_r 1
}

# The donor's SECOND version definition, renamed. The first is the object's own
# BASE entry, which names the file rather than a node, so the second is the first
# one a consumer could demand. The count is set to two, so the entries behind it,
# whose names the slot write may have moved, are never read.
elf_set_verdef() {
    local file="$1" node="$2" ds_off ds_size vd_off vd_size ent slot
    read -r ds_off ds_size <<< "$(elf_section "$file" .dynstr)"
    read -r vd_off vd_size <<< "$(elf_section "$file" .gnu.version_d)"
    if [ -z "${ds_size:-}" ] || [ -z "${vd_size:-}" ]; then return 1; fi
    ent=$(elf_verdef_second "$DONOR_SHARED") || return 1
    slot=$(elf_name_slot "$file" 1) || return 1
    elf_poke_str "$file" $(( ds_off + slot )) "$node"
    elf_poke_u32 "$file" $(( vd_off + ent + 20 )) "$slot"
    elf_set_version_count "$file" .gnu.version_d 2
}

elf_verneed_demands() {
    local file="$1" provider="$2" node="$3" block
    block=$(elf_version_block "$file" 'Version needs section')
    printf '%s\n' "$block" | grep -q "File: $provider" || return 1
    printf '%s\n' "$block" | grep -q "Name: $node" || return 1
    return 0
}

elf_verdef_defines() {
    elf_version_block "$1" 'Version definition section' | grep -q "Name: $2"
}

# The harness's own digest, resolved where it is used rather than in the engine's
# preflight: step 4 declares sha256sum and its capability gate measures it, while
# step 3 neither declares nor needs it.
fixture_digest() {
    LC_ALL=C sha256sum -- "$1" 2>/dev/null | sed -e 's/ .*$//'
}

# How many lookup names `plant-multi-candidates` builds. Twenty is the measured
# archive's own count of names with more than one candidate path.
FIXTURE_MULTI_NAMES=20

# One multi-candidate name: a library under the version directory and a consumer
# that needs it. The directory alias planted beside them is what gives every one
# of these names TWO candidate paths resolving to ONE file, which is the shape
# `measurements.provider-candidates.rhel.txt` reports twenty times.
fixture_multi_candidate() {
    local prefix="$1" dir="$2" i="$3"
    local lib="$prefix/$dir/libcplxmc$i.so.1"
    local user="$prefix/$dir/libcplxmcuser$i.so.1"

    fixture_copy_donor "$DONOR_SHARED" "$lib" || return 1
    elf_set_string_entry "$lib" SONAME "libcplxmc$i.so.1" || return 1
    fixture_copy_donor "$DONOR_SHARED" "$user" || return 1
    elf_add_needed "$user" "libcplxmc$i.so.1" || return 1
}
# The entry link and the real library of the chain last built, so the assert can
# name what the shape actually produced rather than repeating its construction.
FIXTURE_CHAIN_ENTRY=""
FIXTURE_CHAIN_REAL=""

# One link chain, built whole. Every shape ends at ONE real library under
# `version/lib`, reached from an entry link in the provider directory the row
# places it in, and a consumer names the entry link's soname so an edge selects
# it. The three differ only in the path the links take to get there.
fixture_chain() {
    local prefix="$1" dir="$2" verb="$3" i prev
    local base real link user

    case "$verb" in
        plant-chain-relative) base=libcplxrel ;;
        plant-chain-updir) base=libcplxupdir ;;
        *) base=libcplxdeep ;;
    esac
    real="tools/python/version/lib/$base.so.1.2"
    FIXTURE_CHAIN_REAL="$real"
    FIXTURE_CHAIN_ENTRY="$base.so.1"
    link="$prefix/$dir/$base.so.1"
    user="$prefix/tools/python/version/lib/${base}user.so.1"

    mkdir -p -- "$prefix/tools/python/version/lib" "$prefix/$dir" || return 1
    fixture_copy_donor "$DONOR_SHARED" "$prefix/$real" || return 1
    elf_set_string_entry "$prefix/$real" SONAME "$base.so.1" || return 1
    fixture_copy_donor "$DONOR_SHARED" "$user" || return 1
    elf_add_needed "$user" "$base.so.1" || return 1

    rm -f -- "$link"
    case "$verb" in
        plant-chain-relative)
            # Out of a sibling provider directory and back down THROUGH THE
            # ALIAS, so a component INSIDE the target is itself a link. Taking
            # the target whole resolves nothing further and lands on a path the
            # walk never recorded.
            ln -s -- "../../../current/lib/$base.so.1.2" "$link" || return 1 ;;
        plant-chain-updir)
            # Up THROUGH a link directory: `..` has to apply to the directory
            # the resolution reached, not to the one the text names.
            mkdir -p -- "$prefix/tools/python/version/deep" || return 1
            rm -f -- "$prefix/tools/python/linkdir"
            ln -s -- "version/deep" "$prefix/tools/python/linkdir" || return 1
            ln -s -- "../../linkdir/../lib/$base.so.1.2" "$link" || return 1 ;;
        *)
            # Nine valid links ending at the real library, which the host
            # resolves and which a bound tighter than the kernel's would refuse.
            prev="$base.so.1.2"
            i=1
            while [ "$i" -le 9 ]; do
                rm -f -- "$prefix/tools/python/version/lib/$base.hop$i"
                ln -s -- "$prev" "$prefix/tools/python/version/lib/$base.hop$i" || return 1
                prev="$base.hop$i"
                i=$((i + 1))
            done
            ln -s -- "../../version/lib/$base.hop9" "$link" || return 1 ;;
    esac
}

# The harness's own magic-byte test, kept apart from the checker's so a case
# asserting "this is not an ELF" never asks the code under test whether it is.
fixture_is_elf() {
    local magic=""
    [ -r "$1" ] || return 1
    IFS= read -r -n 4 magic < "$1" 2>/dev/null || true
    [ "$magic" = "$FIXTURE_ELF_MAGIC" ]
}

# Plants the row named by <id> under <prefix> and prints `ok`, or the reason the
# asserted result was not observed. A row whose mutation this engine does not
# implement prints `unimplemented:<verb>` rather than planting the donor
# unchanged, because an un-mutated copy passing for a mutated one is exactly what
# the assert column exists to prevent.
fixture_plant() {
    local prefix="$1" id="$2"
    local target verb operand src ds_off ds_size dy_off dy_size slot idx name

    corpus_load_row "$id" || { printf 'no-row'; return; }
    target="$prefix/$CORPUS_ROW_PLACE"
    verb="${CORPUS_ROW_MUT%%:*}"
    operand="${CORPUS_ROW_MUT#*:}"
    [ "$operand" != "$CORPUS_ROW_MUT" ] || operand=""

    # The kind column and the mutation column are two statements about one row and
    # have to agree: a `tree` row planting an ELF, or an `object` row planting a
    # text file, is a corpus defect rather than a fixture.
    case "$CORPUS_ROW_KIND" in
        tree)
            case "$verb" in
                plant-text|plant-donor-need|symlink-to|symlink-to-donor|symlink-cycle|omit|plant-directory) ;;
                *) printf 'kind-mismatch'; return ;;
            esac ;;
        object)
            case "$verb" in
                plant-text|plant-donor-need|symlink-to|symlink-to-donor|symlink-cycle|omit|plant-directory)
                    printf 'kind-mismatch'; return ;;
            esac ;;
        *) printf 'unknown-kind'; return ;;
    esac

    case "$verb" in
        plant-text)
            mkdir -p -- "${target%/*}" || { printf 'no-directory'; return; }
            printf 'not an ELF: the %s fixture, planted from the corpus\n' "$id" > "$target" ;;
        plant-donor-need)
            mkdir -p -- "$target" || { printf 'no-directory'; return; }
            for name in $DONOR_NEED_NAMES; do
                printf 'not an ELF: the provider a donor need resolves to\n' > "$target/$name"
            done ;;
        plant-alias-pairs)
            # THE COST FIXTURE. It replicates the declared alias shape, a
            # versioned target with a soname link beside it and a consumer that
            # names the soname, at the size `FIXTURE_ALIAS_PAIRS` asks for, so
            # the alias resolution can be measured at two populations. The
            # consumers go under a provider directory of their own so the
            # planted names stay resolvable.
            mkdir -p -- "$target" "$prefix/tools/python/current/lib" \
                || { printf 'no-directory'; return; }
            src="$DONOR_SHARED"
            [ -n "$src" ] || { printf 'no-donor'; return; }
            idx=1
            while [ "$idx" -le "$FIXTURE_ALIAS_PAIRS" ]; do
                fixture_alias_pair "$prefix" "$CORPUS_ROW_PLACE" "$idx" \
                    || { printf 'pair-%s-failed' "$idx"; return; }
                idx=$((idx + 1))
            done ;;
        plant-chain-relative|plant-chain-updir|plant-chain-deep)
            # THE LINK CHAINS, each built whole because the shape is the fixture:
            # a real library, the links that reach it, and a consumer that names
            # the entry link so an edge selects it. The placement is the provider
            # directory the entry link goes in.
            src="$DONOR_SHARED"
            [ -n "$src" ] || { printf 'no-donor'; return; }
            fixture_chain "$prefix" "$CORPUS_ROW_PLACE" "$verb" \
                || { printf 'chain-not-built'; return; } ;;
        symlink-to)
            # The soname beside its versioned target, which is the ordinary
            # library layout and the one an alias rule has to survive. A host
            # where `ln -s` copies instead of linking cannot plant it, and the
            # assert below says so rather than passing over a plain copy.
            mkdir -p -- "${target%/*}" || { printf 'no-directory'; return; }
            rm -f -- "$target"
            ln -s -- "$prefix/$operand" "$target" 2>/dev/null ;;
        symlink-to-donor)
            # A provider directory entry that LEAVES THE ARCHIVE. The donor lives
            # on the host outside the prefix, so the resolution of this candidate
            # lands somewhere the archive does not own, which is coherence's
            # fourth condition and the only shape that makes it observable.
            mkdir -p -- "${target%/*}" || { printf 'no-directory'; return; }
            [ -n "$DONOR_SHARED" ] || { printf 'no-donor'; return; }
            rm -f -- "$target"
            ln -s -- "$DONOR_SHARED" "$target" 2>/dev/null ;;
        symlink-cycle)
            # Two links naming each other. Nothing resolves through them, so the
            # cycle guard is reached and the result is an UNDETERMINED with no
            # refusal anywhere, which is the one aggregation row a tree with a
            # real defect in it cannot produce.
            mkdir -p -- "${target%/*}" || { printf 'no-directory'; return; }
            rm -f -- "$target" "$prefix/$operand"
            ln -s -- "$prefix/$operand" "$target" 2>/dev/null
            ln -s -- "$target" "$prefix/$operand" 2>/dev/null ;;
        omit)
            # A directory that exists with one named file deliberately NOT in it,
            # which is what a floor member absent from the payload looks like.
            mkdir -p -- "$target" || { printf 'no-directory'; return; }
            rm -f -- "$target/$operand" ;;
        plant-directory)
            mkdir -p -- "$target" || { printf 'no-directory'; return; } ;;
        content-copy|content-differ)
            # TWO CANDIDATE PATHS FOR ONE LOOKUP NAME, identical or not. The
            # second copy carries a different soname in the `differ` case, which
            # changes the bytes without changing the file name the loader looks
            # the candidate up by.
            [ -n "$DONOR_SHARED" ] || { printf 'no-donor'; return; }
            mkdir -p -- "${target%/*}" "$prefix/${operand%/*}" \
                || { printf 'no-directory'; return; }
            fixture_copy_donor "$DONOR_SHARED" "$target" || { printf 'no-copy'; return; }
            fixture_copy_donor "$DONOR_SHARED" "$prefix/$operand" || { printf 'no-copy'; return; }
            name="${target##*/}"
            elf_set_string_entry "$target" SONAME "$name" || { printf 'no-soname'; return; }
            if [ "$verb" = "content-differ" ]; then
                elf_set_string_entry "$prefix/$operand" SONAME "cplxother-$name" \
                    || { printf 'no-soname'; return; }
            else
                elf_set_string_entry "$prefix/$operand" SONAME "$name" \
                    || { printf 'no-soname'; return; }
            fi ;;
        plant-multi-candidates)
            [ -n "$DONOR_SHARED" ] || { printf 'no-donor'; return; }
            mkdir -p -- "$target" || { printf 'no-directory'; return; }
            idx=1
            while [ "$idx" -le "$FIXTURE_MULTI_NAMES" ]; do
                fixture_multi_candidate "$prefix" "$CORPUS_ROW_PLACE" "$idx" \
                    || { printf 'name-%s-failed' "$idx"; return; }
                idx=$((idx + 1))
            done ;;
        verneed-set|verdef-set)
            [ -n "$DONOR_SHARED" ] || { printf 'no-donor'; return; }
            mkdir -p -- "${target%/*}" || { printf 'no-directory'; return; }
            fixture_copy_donor "$DONOR_SHARED" "$target" || { printf 'no-copy'; return; }
            if [ "$verb" = "verdef-set" ]; then
                elf_set_verdef "$target" "$operand" || { printf 'no-verdef'; return; }
            else
                elf_set_verneed "$target" "${operand%%:*}" "${operand#*:}" \
                    || { printf 'no-verneed'; return; }
            fi ;;
        needed-add|soname-set|interp-keep|mode-set|needed-offset-corrupt)
            if [ "$CORPUS_ROW_DONOR" = "program" ]; then src="$DONOR_PROGRAM"; else src="$DONOR_SHARED"; fi
            [ -n "$src" ] || { printf 'no-donor'; return; }
            mkdir -p -- "${target%/*}" || { printf 'no-directory'; return; }
            fixture_copy_donor "$src" "$target" || { printf 'no-copy'; return; } ;;
        *) printf 'unimplemented:%s' "$verb"; return ;;
    esac

    case "$verb" in
        needed-add|soname-set)
            read -r ds_off ds_size <<< "$(elf_section "$target" .dynstr)"
            read -r dy_off dy_size <<< "$(elf_section "$target" .dynamic)"
            if [ -z "${ds_size:-}" ] || [ -z "${dy_size:-}" ]; then
                printf 'no-sections'
                return
            fi
            slot=$(elf_name_slot "$target" 0) || { printf 'no-name-slot'; return; }
            elf_poke_str "$target" $(( ds_off + slot )) "$operand"
            if [ "$verb" = "needed-add" ]; then
                # The terminator becomes the added need, and the spare slot behind
                # it terminates the array, which is what makes this an ADD.
                idx=$(elf_dyn_slot "$target" NULL) || { printf 'no-null-slot'; return; }
                elf_poke_u64 "$target" $(( dy_off + idx * 16 )) 1
                elf_poke_u64 "$target" $(( dy_off + idx * 16 + 8 )) "$slot"
            else
                idx=$(elf_dyn_slot "$target" SONAME) || { printf 'no-soname-slot'; return; }
                elf_poke_u64 "$target" $(( dy_off + idx * 16 + 8 )) "$slot"
            fi ;;
        needed-offset-corrupt)
            # The STRING TABLE is left alone and the ENTRY is repointed past its
            # end, which is how a supported reader is made to exit 0 and print a
            # DT_NEEDED whose value it cannot resolve to a name.
            read -r dy_off dy_size <<< "$(elf_section "$target" .dynamic)"
            if [ -z "${dy_size:-}" ]; then printf 'no-sections'; return; fi
            idx=$(elf_dyn_slot "$target" NEEDED) || { printf 'no-needed-slot'; return; }
            elf_poke_u64 "$target" $(( dy_off + idx * 16 + 8 )) 9223372036854775807 ;;
        mode-set) chmod "$operand" -- "$target" ;;
    esac

    case "$CORPUS_ROW_ASSERT" in
        dt-needed-lists:*)
            name="${CORPUS_ROW_ASSERT#dt-needed-lists:}"
            if elf_needed_names "$target" | grep -Fxq "$name"; then printf 'ok'
            else printf 'need-not-listed'; fi ;;
        dt-needed-value-unreadable)
            # TWO HALVES, and the second is what makes this fixture worth having:
            # the reader must EXIT 0 over the object, so the case is about a
            # value a supported reader could not resolve rather than about a
            # reader that failed.
            if ! LC_ALL=C "$FIXTURE_READELF" -d -V -- "$target" >/dev/null 2>&1; then
                printf 'reader-refused'
            elif elf_dyn_lines "$target" | grep -E '\(NEEDED\)' | grep -qv '\['; then
                printf 'ok'
            else
                printf 'value-still-readable'
            fi ;;
        dt-soname-is:*)
            name="${CORPUS_ROW_ASSERT#dt-soname-is:}"
            if [ "$(elf_soname "$target")" = "$name" ]; then printf 'ok'
            else printf 'soname-is-%s' "$(elf_soname "$target")"; fi ;;
        pt-interp-present)
            if LC_ALL=C "$FIXTURE_READELF" -l -W -- "$target" 2>/dev/null | grep -q 'INTERP'
            then printf 'ok'; else printf 'no-interp'; fi ;;
        read-refused)
            if [ -r "$target" ]; then printf 'still-readable'; else printf 'ok'; fi ;;
        chain-resolves)
            # THE HOST'S OWN ANSWER IS THE ASSERTION. `-ef` on the entry link and
            # the real library says the two are one file, so the fixture states
            # what the resolver must reach rather than the harness assuming it.
            if [ ! -L "$target/$FIXTURE_CHAIN_ENTRY" ]; then printf 'not-a-symlink'
            elif [ "$target/$FIXTURE_CHAIN_ENTRY" -ef "$prefix/$FIXTURE_CHAIN_REAL" ]
            then printf 'ok'
            else printf 'chain-does-not-reach-the-file'; fi ;;
        alias-pairs-present)
            idx=1
            while [ "$idx" -le "$FIXTURE_ALIAS_PAIRS" ]; do
                if [ ! -L "$target/libcplxscale$idx.so.1" ] \
                   || [ ! -f "$target/libcplxscale$idx.so.1.2.3" ] \
                   || [ ! -f "$prefix/tools/python/current/lib/libcplxscaleuser$idx.so.1" ]; then
                    printf 'pair-%s-absent' "$idx"
                    return
                fi
                idx=$((idx + 1))
            done
            printf 'ok' ;;
        symlink-resolves)
            # BOTH HALVES. It has to BE a link, because a host where `ln -s`
            # copies would otherwise plant two independent files and the alias
            # case would pass over a shape it never built; and it has to resolve
            # to the same file, because a dangling link reaches nothing.
            if [ ! -L "$target" ]; then printf 'not-a-symlink'
            elif [ "$target" -ef "$prefix/$operand" ]; then printf 'ok'
            else printf 'link-does-not-resolve'; fi ;;
        magic-is-not-elf)
            if fixture_is_elf "$target"; then printf 'is-elf'; else printf 'ok'; fi ;;
        dt-verneed-demands:*)
            name="${CORPUS_ROW_ASSERT#dt-verneed-demands:}"
            if elf_verneed_demands "$target" "${name%%:*}" "${name#*:}"; then printf 'ok'
            else printf 'need-not-demanded'; fi ;;
        dt-verdef-defines:*)
            name="${CORPUS_ROW_ASSERT#dt-verdef-defines:}"
            if elf_verdef_defines "$target" "$name"; then printf 'ok'
            else printf 'node-not-defined'; fi ;;
        two-paths-differ|two-paths-identical)
            # BOTH HALVES. Two files have to exist at the two paths, or the case
            # would compare one file with nothing; and their digests have to
            # differ or match as the row says, or a mutation that silently did
            # nothing would pass for one that worked.
            if [ ! -f "$target" ] || [ ! -f "$prefix/$operand" ]; then
                printf 'one-path-missing'
            elif [ "$(fixture_digest "$target")" = "$(fixture_digest "$prefix/$operand")" ]; then
                if [ "$CORPUS_ROW_ASSERT" = "two-paths-identical" ]; then printf 'ok'
                else printf 'paths-are-identical'; fi
            elif [ "$CORPUS_ROW_ASSERT" = "two-paths-differ" ]; then printf 'ok'
            else printf 'paths-differ'; fi ;;
        symlink-leaves-archive)
            # A link, and one whose target is outside the prefix. Both halves,
            # because a host where `ln -s` copies would plant a file INSIDE the
            # archive and the case would then assert nothing.
            if [ ! -L "$target" ]; then printf 'not-a-symlink'
            elif [ ! "$target" -ef "$DONOR_SHARED" ]; then printf 'link-does-not-resolve'
            else
                case "$DONOR_SHARED" in
                    "$prefix"/*) printf 'donor-is-inside-the-prefix' ;;
                    *) printf 'ok' ;;
                esac
            fi ;;
        symlink-cycle-present)
            if [ ! -L "$target" ] || [ ! -L "$prefix/$operand" ]; then printf 'not-a-symlink'
            elif [ -e "$target" ]; then printf 'cycle-resolves'
            else printf 'ok'; fi ;;
        named-file-absent)
            if [ ! -d "$target" ]; then printf 'no-directory'
            elif [ -e "$target/$operand" ]; then printf 'file-present'
            else printf 'ok'; fi ;;
        file-present)
            if [ -f "$target" ]; then printf 'ok'; else printf 'file-absent'; fi ;;
        directory-present)
            if [ -d "$target" ]; then printf 'ok'; else printf 'directory-absent'; fi ;;
        multi-candidates-present)
            idx=1
            while [ "$idx" -le "$FIXTURE_MULTI_NAMES" ]; do
                if [ ! -f "$target/libcplxmc$idx.so.1" ] \
                   || [ ! -f "$target/libcplxmcuser$idx.so.1" ]; then
                    printf 'name-%s-absent' "$idx"
                    return
                fi
                idx=$((idx + 1))
            done
            printf 'ok' ;;
        donor-need-resolvable)
            for name in $DONOR_NEED_NAMES; do
                [ -f "$target/$name" ] || { printf 'missing-%s' "$name"; return; }
            done
            printf 'ok' ;;
        *) printf 'unimplemented-assert' ;;
    esac
}

# The value of one summary row of the last checker run, which is how a case reads
# a count without re-deriving it from the typed lines the row summarises.
report_field() {
    printf '%s\n' "$CHECKER_OUT" | grep -E "^  $1 " | sed -n 1p \
      | sed -e "s/^  $1  *//" -e 's/ .*$//'
}

# The provider index, asked of the module itself rather than of the report: the
# name-to-paths map is bounded by the archive rather than by the scope, so
# printing it whole would bury the findings a reader comes to the report for.
step3_provider_paths() {
    local dirs
    dirs=$(observed_scope "$1" "$SHIPPED_DIR/install_pkg.sh" | sed -e 's/:/\n/g')
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        declare -F closure_provider_index >/dev/null 2>&1 || exit 92
        closure_provider_index "$2"
        printf "%s" "${CLOSURE_PROVIDER_PATHS[$3]:-}"
    ' _ "$SHIPPED_DIR/closure_check.sh" "$dirs" "$2" 2>/dev/null
}

# THE COST MEASUREMENT. It counts the shell commands `closure_report_unreferenced
# _by_edge` executes over a prepared tree, with a DEBUG trap, and it is the only
# way to tell a lookup from a sweep: both answer the same, and only their growth
# differs. The trap is set around that ONE call, so the walk and the index below
# it are not counted.
step3_alias_ops() {
    local prefix="$1" dirs
    dirs=$(observed_scope "$prefix" "$SHIPPED_DIR/install_pkg.sh" | sed -e 's/:/\n/g')
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        declare -F closure_report_unreferenced_by_edge >/dev/null 2>&1 || exit 92
        closure_provider_index "$2"
        closure_subjects_walk "$3/tools" >/dev/null
        cplx_ops=0
        # `set -T` is what makes the trap enter the function at all. Without
        # functrace a DEBUG trap fires only in the calling shell, and the count
        # comes back the same at every population, which reads exactly like a
        # cost that does not grow.
        set -T
        trap "cplx_ops=\$((cplx_ops + 1))" DEBUG
        closure_report_unreferenced_by_edge >/dev/null
        trap - DEBUG
        set +T
        printf "%s" "$cplx_ops"
    ' _ "$SHIPPED_DIR/closure_check.sh" "$dirs" "$prefix" 2>/dev/null
}

# A stub directory holding `readelf` and `find`. An empty body means "pass the
# real tool through", and an empty `readelf` body with a PATH of exactly this
# directory is how the absent-reader case is built: the directory still supplies
# the walk, so the run reaches the objects and fails to READ them rather than
# failing to find them. The find body exists for the mirror case, a traversal
# that cannot be taken at all.
#
# `mktemp` and `rm` are passed through beside them, because the walk holds its
# listing in a temporary file and the absent-reader case runs under a PATH of
# exactly this directory. Without them that case refuses on the missing `mktemp`
# and never reaches the reader it exists to remove, which is a green-looking
# refusal for the wrong input.
step3_write_stub() {
    local dir="$1" body="$2" find_body="${3:-}" tool real
    rm -rf -- "$dir"
    mkdir -p -- "$dir" || return 1
    for tool in find mktemp rm; do
        real=$(type -P "$tool" 2>/dev/null) || return 1
        { printf '#!/bin/bash\n'; printf 'exec "%s" "$@"\n' "$real"; } > "$dir/$tool"
        chmod +x -- "$dir/$tool"
    done
    if [ -n "$find_body" ]; then
        { printf '#!/bin/bash\n'; printf '%s\n' "$find_body"; } > "$dir/find"
        chmod +x -- "$dir/find"
    fi
    if [ -n "$body" ]; then
        { printf '#!/bin/bash\n'; printf '%s\n' "$body"; } > "$dir/readelf"
        chmod +x -- "$dir/readelf"
    fi
}

# A reader that answers honestly under LC_ALL=C and translates its field labels
# otherwise, which is the build the pin exists for.
step3_write_translating_stub() {
    local dir="$1" real_find real_readelf
    rm -rf -- "$dir"
    mkdir -p -- "$dir" || return 1
    real_find=$(type -P find 2>/dev/null) || return 1
    real_readelf=$(type -P readelf 2>/dev/null) || return 1
    { printf '#!/bin/bash\n'; printf 'exec "%s" "$@"\n' "$real_find"; } > "$dir/find"
    # shellcheck disable=SC2016  # every printf below writes INTO the stub, and the
    # expansions belong to the stub when it runs rather than to this shell
    { printf '#!/bin/bash\n'
      printf 'out=$("%s" "$@"); rc=$?\n' "$real_readelf"
      printf 'if [ "${LC_ALL:-}" = "C" ]; then printf "%%s\\n" "$out"; exit "$rc"; fi\n'
      printf 'printf "%%s\\n" "$out" | sed -e "s/Shared library:/Bibliotheque partagee :/"'
      printf ' -e "s/Library soname:/Nom de bibliotheque :/"'
      printf ' -e "s/Dynamic section at offset/Section dynamique au decalage/"\n'
      printf 'exit "$rc"\n'; } > "$dir/readelf"
    chmod +x -- "$dir/find" "$dir/readelf"
}

# One checker run under a PATH the case states in full, so the reader the checker
# resolves is the one the case planted.
#
# THE WHOLE VALUE IS THE ARGUMENT AND NOT A PREFIX. The absent-reader case needs
# a PATH where `readelf` cannot be found at all, and a helper that prepended the
# stub directory would leave the host's own reader one entry further down: the
# case would then pass its stub over, resolve the real tool, and report a green
# for the opposite of what it exists to show.
step3_run_with_path() {
    local path_value="$1"
    shift
    CHECKER_OUT=$(PATH="$path_value" "${BASH:-bash}" "$@" 2>&1)
    CHECKER_RC=$?
}

# THE INSTRUMENTED RUN. The checker is reached through its own MAIN BOUNDARY seam
# so the provider index can be wrapped in a counting shim, and `find` and
# `readelf` are wrapped on PATH the same way. The three events land in ONE log in
# the order they happened, which is what makes "the index was built before the
# first object was read" an observation rather than a claim.
step3_instrumented() {
    local log="$1" stubs="$2"
    shift 2
    local dir="$stubs/instrumented" real_find real_readelf
    rm -rf -- "$dir"
    mkdir -p -- "$dir" || return 1
    real_find=$(type -P find 2>/dev/null) || return 1
    real_readelf=$(type -P readelf 2>/dev/null) || return 1
    { printf '#!/bin/bash\n'; printf 'printf "WALK\\n" >> "%s"\n' "$log"
      printf 'exec "%s" "$@"\n' "$real_find"; } > "$dir/find"
    { printf '#!/bin/bash\n'; printf 'printf "READ\\n" >> "%s"\n' "$log"
      printf 'exec "%s" "$@"\n' "$real_readelf"; } > "$dir/readelf"
    chmod +x -- "$dir/find" "$dir/readelf"
    : > "$log"
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    CHECKER_OUT=$(PATH="$dir:$PATH" "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        declare -F closure_provider_index >/dev/null 2>&1 || exit 92
        declare -F closure_check_main >/dev/null 2>&1 || exit 92
        log="$2"
        orig=$(declare -f closure_provider_index)
        eval "closure_provider_index_real${orig#closure_provider_index}"
        closure_provider_index() {
            printf "INDEX\n" >> "$log"
            closure_provider_index_real "$@"
        }
        shift 2
        closure_check_main "$@"
    ' _ "$SHIPPED_DIR/closure_check.sh" "$log" "$@" 2>&1)
    CHECKER_RC=$?
}

# =============================================================== the step 3 suite ===
step3_suite() {
    local checker="$SHIPPED_DIR/closure_check.sh"
    local installer="$SHIPPED_DIR/install_pkg.sh"
    local reader="$SHIPPED_DIR/closure_elf.sh"
    local rules="$SHIPPED_DIR/closure_rules.sh"
    local dir="$SCRATCH/step3" tree="$SCRATCH/step3/prefix" stubs="$SCRATCH/step3/stubs"
    local log="$SCRATCH/step3/order.log"
    local roots1="python=root,current" roots2="git=root,current"
    local id result planted_files planted_elf edges shared_needs program_needs
    local alias_ok=no small large dir_tree
    local paths line
    local donor_names donor_soname fixture_names slot_base ds_off ds_size

    mkdir -p -- "$dir" "$stubs" || { fail "step3/scratch" "cannot create the scratch directory"; return; }

    # --- the two modules are filled, and neither has taken the other's job ----
    section "step 3 topology: the reader and the rules module have a body"
    if [ ! -f "$reader" ] || [ ! -f "$rules" ]; then
        fail "step3/topology/modules-exist" "closure_elf.sh or closure_rules.sh is missing"
        unanswered "every step 3 case" \
          "  fill src/setups/env/bin/closure_elf.sh and closure_rules.sh, then repeat this call"
        return
    fi
    chk "step3/topology/reader-is-filled" "yes" \
        "$( [ "$(module_body_lines "$reader")" -gt 0 ] && echo yes || echo no )"
    chk "step3/topology/rules-is-filled" "yes" \
        "$( [ "$(module_body_lines "$rules")" -gt 0 ] && echo yes || echo no )"
    chk "step3/topology/reader-declared-commands" "" \
        "$(oneline "$(shipped_undeclared_words "$reader")")"
    chk "step3/topology/rules-declared-commands" "" \
        "$(oneline "$(shipped_undeclared_words "$rules")")"
    chk "step3/topology/checker-sources-the-reader" "yes" \
        "$(sed -e 's/#.*$//' "$checker" | grep -q 'closure_elf.sh' && echo yes || echo no)"
    chk "step3/topology/checker-sources-the-rules" "yes" \
        "$(sed -e 's/#.*$//' "$checker" | grep -q 'closure_rules.sh' && echo yes || echo no)"
    # THE BOUNDARY IS READING AGAINST DECIDING. The reader may emit no verdict and
    # the checker may emit no invariant's finding, so the two words those results
    # are printed with belong to exactly one file, and it is not either of these.
    chk "step3/topology/reader-emits-no-verdict" "" \
        "$(oneline "$(sed -e 's/#.*$//' "$reader" | grep -nE 'REFUSED\||UNREFERENCED\|' || true)")"
    chk "step3/topology/membership-not-in-checker" "" \
        "$(oneline "$(sed -e 's/#.*$//' "$checker" | grep -nE 'REFUSED\|derived|UNREFERENCED\|' || true)")"

    # --- the fixture engine ----------------------------------------------------
    section "step 3 fixtures: donors validated, every mutation asserted"
    if ! fixture_resolve_tools; then
        unanswered "the step 3 fixture generation" \
          "  readelf and dd must both resolve here; re-run on a host that supplies them"
        return
    fi
    note "step3/fixture/tools" "$FIXTURE_READELF, $FIXTURE_DD"
    DONOR_SHARED=$(donor_find_shared) || DONOR_SHARED=""
    DONOR_PROGRAM=$(donor_find_program) || DONOR_PROGRAM=""
    chk "step3/fixture/shared-donor-validated" "yes" \
        "$( [ -n "$DONOR_SHARED" ] && echo yes || echo no )"
    chk "step3/fixture/program-donor-validated" "yes" \
        "$( [ -n "$DONOR_PROGRAM" ] && echo yes || echo no )"
    if [ -z "$DONOR_SHARED" ] || [ -z "$DONOR_PROGRAM" ]; then
        unanswered "every step 3 fixture" \
          "  no host object satisfies the corpus donor rows here; re-run on the RHEL 9.8 build host or on the Debian 12 agent"
        return
    fi
    note "step3/fixture/donors" "shared $DONOR_SHARED, program $DONOR_PROGRAM"
    shared_needs=$(elf_needed_names "$DONOR_SHARED" | grep -c .)
    program_needs=$(elf_needed_names "$DONOR_PROGRAM" | grep -c .)
    DONOR_NEED_NAMES=$( { elf_needed_names "$DONOR_SHARED"; elf_needed_names "$DONOR_PROGRAM"; } \
                        | grep -v '^$' | sort -u )
    # THE CONTROL FOR EVERY MUTATION BELOW: the donor itself carries none of the
    # invented names, so a fixture that lists one was mutated rather than found.
    chk "step3/fixture/control/donor-is-clean" "" \
        "$(oneline "$(elf_needed_names "$DONOR_SHARED" | grep -E 'libcplx' || true)")"

    # --- the name slots, and the collateral a fixture must not cause -----------
    #
    # THIS PAIR IS THE DEBIAN REGRESSION. The engine took the last 256 bytes of
    # `.dynstr` as reserved, which is true of the build host's donor and false of
    # the agent's: there the referenced dynamic strings sit exactly there, so the
    # write left the donor's own entries pointing into the MIDDLE of the fixture
    # name and `readelf` reported needs such as `.1` and `so.1`. Fifteen step 3
    # cases and ten step 4 cases failed on that agent against harness bytes that
    # passed here, and nothing in the suite was measuring the cause.
    chk "step3/fixture/the-donor-has-a-measured-name-window" "yes" \
        "$( elf_slot_base "$DONOR_SHARED" >/dev/null 2>&1 && echo yes || echo no )"
    mkdir -p -- "$tree/slots" || true
    fixture_copy_donor "$DONOR_SHARED" "$tree/slots/probe.so.1"
    donor_names=$(elf_needed_names "$DONOR_SHARED" | grep -v '^$' | sort -u)
    donor_soname=$(elf_soname "$DONOR_SHARED")
    elf_add_needed "$tree/slots/probe.so.1" libcplxslotprobe.so.1
    fixture_names=$(elf_needed_names "$tree/slots/probe.so.1" | grep -v '^$' | sort -u)
    # THE ADDED NAME IS THE WHOLE DIFFERENCE. Every other need the donor carried
    # reads back unchanged, which is the property the reserved-tail assumption
    # was breaking on one distribution and only on one.
    chk "step3/fixture/the-added-need-is-listed" "yes" \
        "$(printf '%s\n' "$fixture_names" | grep -Fxq 'libcplxslotprobe.so.1' && echo yes || echo no)"
    chk "step3/fixture/no-other-need-was-changed" "" \
        "$(oneline "$(printf '%s\n' "$fixture_names" | grep -Fxv libcplxslotprobe.so.1 \
              | grep -Fxv -f <(printf '%s\n' "$donor_names") || true)")"
    chk "step3/fixture/every-donor-need-survives" "" \
        "$(oneline "$(printf '%s\n' "$donor_names" \
              | grep -Fxv -f <(printf '%s\n' "$fixture_names") || true)")"
    chk "step3/fixture/the-soname-survives" "$donor_soname" \
        "$(elf_soname "$tree/slots/probe.so.1")"
    # AND THE STRING TABLE OUTSIDE THE WINDOW IS BYTE-IDENTICAL, which is the
    # assertion that covers what a name comparison cannot see. The version
    # records step 4's coherence cases turn on index this same table, and a poke
    # that moved a byte outside the measured window would leave them pointing at
    # something else. A poke moves no byte, so the two halves either side of the
    # window are the donor's own.
    slot_base=$(elf_slot_base "$DONOR_SHARED") || slot_base=""
    read -r ds_off ds_size <<< "$(elf_section "$DONOR_SHARED" .dynstr)"
    chk "step3/fixture/the-window-was-measured" "yes" \
        "$( [ -n "$slot_base" ] && echo yes || echo no )"
    if [ -n "$slot_base" ]; then
        chk "step3/fixture/the-table-before-the-window-is-untouched" \
            "$(dynstr_span_digest "$DONOR_SHARED" "$ds_off" "$slot_base")" \
            "$(dynstr_span_digest "$tree/slots/probe.so.1" "$ds_off" "$slot_base")"
        chk "step3/fixture/the-table-after-the-window-is-untouched" \
            "$(dynstr_span_digest "$DONOR_SHARED" \
                "$(( ds_off + slot_base + FIXTURE_SLOT_COUNT * FIXTURE_SLOT_SIZE ))" \
                "$(( ds_size - slot_base - FIXTURE_SLOT_COUNT * FIXTURE_SLOT_SIZE ))")" \
            "$(dynstr_span_digest "$tree/slots/probe.so.1" \
                "$(( ds_off + slot_base + FIXTURE_SLOT_COUNT * FIXTURE_SLOT_SIZE ))" \
                "$(( ds_size - slot_base - FIXTURE_SLOT_COUNT * FIXTURE_SLOT_SIZE ))")"
    fi

    for id in subject-lib-dynload-unresolved subject-site-packages-need \
              subject-unreferenced-sound subject-second-libssl \
              subject-program-entry-point provider-first-libssl \
              subject-need-provider subject-libssl-consumer \
              provider-alias-target subject-alias-consumer \
              reader-not-an-elf provider-donor-need; do
        result=$(fixture_plant "$tree" "$id")
        chk "step3/fixture/$id" "ok" "$result"
    done
    # The soname link is planted last and judged apart, because a host where
    # `ln -s` copies cannot build the alias shape at all and must report the
    # obligation UNANSWERED rather than fail a case for its environment.
    result=$(fixture_plant "$tree" provider-alias-link)
    if [ "$result" = "not-a-symlink" ]; then
        alias_ok=no
        note "step3/fixture/provider-alias-link" "no symlink here: ln -s did not make one"
        unanswered "the SONAME alias case" \
          "  re-run on a host where ln -s makes a symlink, so a soname and its versioned target are two paths to one file"
    else
        alias_ok=yes
        chk "step3/fixture/provider-alias-link" "ok" "$result"
    fi
    planted_elf=10
    planted_files=$(( planted_elf + 1 + $(printf '%s\n' "$DONOR_NEED_NAMES" | grep -c .) ))
    # Nine objects derived from the shared donor keep its own needs, the program
    # copy keeps its own, and four rows add one name each. The soname link is not
    # a regular file, so the walk does not reach it and it carries no needs.
    edges=$(( 9 * shared_needs + 4 + program_needs ))
    note "step3/fixture/planted" "$planted_files files, $planted_elf of them ELF, $edges edges"

    # --- the subject set: every shipped ELF, none excluded ---------------------
    #
    # The measured gap this whole collection exists for: a walk from the entry
    # points reaches neither the lib-dynload module nor the site-packages wheel,
    # so a closure-based subject set reports this tree as a pass.
    section "step 3 subjects: every shipped ELF, none excluded"
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$roots1" --root "$roots2"
    chk "step3/subjects/exit-code" "1" "$CHECKER_RC"
    chk "step3/subjects/walked-every-file" "$planted_files" "$(report_field walked)"
    chk "step3/subjects/count-equals-planted" "$planted_elf" "$(report_field subjects)"
    chk "step3/subjects/none-unread" "0" "$(report_field unread)"
    chk "step3/subjects/edges-counted" "$edges" "$(report_field edges)"
    chk "step3/subjects/no-unexpected-directory" "0" "$(typed_count UNEXPECTED)"
    # THE TRAVERSAL IS AN INPUT AND IT REPORTS ITS OWN OUTCOME. A walk that ended
    # early observed no empty tree, it failed to observe one, and the difference
    # has to be readable before any count below it means anything.
    chk "step3/subjects/walk-is-complete" "complete" "$(report_field walk)"

    # --- the derived membership half ------------------------------------------
    section "step 3 membership: an unresolvable need, named with its subject"
    chk "step3/membership/one-refusal" "1" "$(report_field refused)"
    chk "step3/membership/names-subject-and-name" \
        "REFUSED|derived|$tree/tools/python/current/lib/python3.13/lib-dynload/_cplxprobe.cpython-313-x86_64-linux-gnu.so|libcplxabsent.so.1" \
        "$(oneline "$(typed_lines REFUSED | sed -e 's/|[^|]*$//')")"
    chk "step3/membership/refusal-is-final" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE MEMBERSHIP REFUSED' && echo yes || echo no)"
    # ITS CONTROL: the same tree with a file of that name in a provider directory
    # is ACCEPTED, so the refusal is about the missing provider and not about the
    # subject having been examined at all.
    printf 'not an ELF: the provider the control plants\n' \
        > "$tree/tools/git/current/lib/libcplxabsent.so.1"
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$roots1" --root "$roots2"
    chk "step3/membership/control/provider-accepted" "0" "$CHECKER_RC"
    chk "step3/membership/control/no-refusal" "0" "$(report_field refused)"

    # --- unreferenced is a finding, never an exclusion ------------------------
    section "step 3 unreferenced: reported, and still accepted"
    chk "step3/unreferenced/accepted-not-refused" "0" "$CHECKER_RC"
    chk "step3/unreferenced/orphan-is-named" \
        "UNREFERENCED-BY-EDGE|subject|$tree/tools/git/current/lib/libcplxorphan.so.1" \
        "$(oneline "$(typed_lines UNREFERENCED-BY-EDGE | grep -F 'libcplxorphan' | sed -e 's/|[^|]*$//')")"
    # THE NEGATIVE CONTROL. One subject in this tree IS reached by a DT_NEEDED
    # edge and must not appear. Without it the finding would be satisfied by a
    # function that named every subject it walked.
    chk "step3/unreferenced/control/referenced-absent" "" \
        "$(oneline "$(typed_lines UNREFERENCED-BY-EDGE | grep -F 'libcplxprovider.so.1' || true)")"
    chk "step3/unreferenced/counted" "7" "$(report_field unreferenced)"
    # AN EDGE REACHES A PATH AND NOT A NAME, which is the difference a name-keyed
    # map cannot see. `libcplxsslconsumer.so.1` names `libssl.so.3`; the copy in a
    # provider directory is what that edge resolves to, and the copy under
    # `root/usr/bin` is reached by nothing because `build_elf_rpath` never adds
    # that directory. Both halves are asserted, because a map keyed by name calls
    # BOTH reached and reports neither.
    chk "step3/unreferenced/resolved-copy-absent" "" \
        "$(oneline "$(typed_lines UNREFERENCED-BY-EDGE | grep -F "$tree/tools/python/root/usr/lib64/libssl.so.3" || true)")"
    chk "step3/unreferenced/unresolved-copy-named" \
        "UNREFERENCED-BY-EDGE|subject|$tree/tools/python/root/usr/bin/libssl.so.3" \
        "$(oneline "$(typed_lines UNREFERENCED-BY-EDGE | grep -F 'root/usr/bin/libssl.so.3' | sed -e 's/|[^|]*$//')")"
    chk "step3/unreferenced/control/the-consumer-exists" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -qF 'libcplxsslconsumer.so.1' && echo yes || echo no)"
    # THE ORDINARY LIBRARY LAYOUT, which is the shape a name-keyed alias test
    # gets wrong in the other direction. `libcplxalias.so.1` is a symlink onto
    # `libcplxalias.so.1.2.3`, a consumer names the soname, and the walk yields
    # the TARGET under its versioned name. Resolving the alias by name finds no
    # entry for that name and reports a normally loaded library as unreferenced,
    # which is a false finding on every versioned library in a real archive.
    if [ "$alias_ok" = "yes" ]; then
        chk "step3/unreferenced/alias-target-absent" "" \
            "$(oneline "$(typed_lines UNREFERENCED-BY-EDGE | grep -F 'libcplxalias.so.1.2.3' || true)")"
        # Its control: the consumer that names the soname IS in the tree and is
        # itself unreferenced, so the case above is about the alias resolving and
        # not about an edge that was never recorded.
        chk "step3/unreferenced/alias-consumer-named" "yes" \
            "$(typed_lines UNREFERENCED-BY-EDGE | grep -qF 'libcplxaliasconsumer.so.1' \
               && echo yes || echo no)"
        chk "step3/unreferenced/alias-link-not-walked" "" \
            "$(oneline "$(typed_lines UNREFERENCED-BY-EDGE | grep -F 'libcplxalias.so.1|' || true)")"
    fi

    # --- the alias resolution is a lookup, measured at two populations --------
    #
    # A RULE THAT COMPARES FILE IDENTITIES PAIR BY PAIR ANSWERS THE SAME AND
    # GROWS DIFFERENTLY, so only a run at two sizes tells them apart. Nothing in
    # the schema caps the number of aliased libraries and one soname link per
    # library is the ordinary layout, so the product of links and subjects is not
    # a constant to wave away. Quadrupling the population multiplies a linear
    # cost by about four and a product cost by about sixteen.
    section "step 3 cost: the alias resolution, measured as it grows"
    if [ "$alias_ok" != "yes" ]; then
        unanswered "the alias cost measurement" \
          "  re-run on a host where ln -s makes a symlink, so an alias population can be planted"
    else
        FIXTURE_ALIAS_PAIRS=6
        result=$(fixture_plant "$SCRATCH/step3/small" alias-scaling-population)
        chk "step3/cost/alias-population-small" "ok" "$result"
        small=$(step3_alias_ops "$SCRATCH/step3/small")
        FIXTURE_ALIAS_PAIRS=24
        result=$(fixture_plant "$SCRATCH/step3/large" alias-scaling-population)
        chk "step3/cost/alias-population-large" "ok" "$result"
        large=$(step3_alias_ops "$SCRATCH/step3/large")
        note "step3/cost/alias-operations" "$small at 6 pairs, $large at 24 pairs"
        # THE CONTROL COMES FIRST, and it is not "both counts are non-zero". A
        # counter that never entered the function returns the same number at
        # every population and satisfies any upper bound, which is exactly how
        # this measurement first passed while measuring nothing. So the count
        # must GROW with the population before its growth is judged.
        chk "step3/cost/alias-counts-are-real" "yes" \
            "$( [ "${small:-0}" -gt 0 ] && [ "${large:-0}" -gt "${small:-0}" ] && echo yes || echo no )"
        # THE CLAIM IS WORK PER ALIAS, NOT A TOTAL RATIO, because the totals
        # carry a base that is itself linear in the population and a loose ratio
        # hides the product term inside it. A rule whose cost is linear does a
        # CONSTANT amount of work per alias; a rule that sweeps does more per
        # alias as the population grows. Measured here: the lookup holds at about
        # 47 commands per pair at both sizes, and the `-ef` sweep it replaced
        # went from 55 to 81, which is what this threshold catches.
        #
        # The comparison is integer and the numbers are deterministic: this
        # counts COMMANDS over a planted tree, so a slow host cannot make it
        # fail and a fast one cannot make it pass.
        chk "step3/cost/alias-work-per-pair-is-flat" "yes" \
            "$( [ $(( 4 * ${large:-0} * 6 )) -le $(( 5 * ${small:-0} * 24 )) ] \
                && echo yes || echo no )"
        # And the answer is still right at the larger size, so the cost case
        # cannot be satisfied by a rule that stopped resolving anything.
        run_checker "$checker" --prefix "$SCRATCH/step3/large" --installer "$installer" \
            --root "$roots1" --root "$roots2"
        chk "step3/cost/alias-still-resolves-at-scale" "" \
            "$(oneline "$(typed_lines UNREFERENCED-BY-EDGE | grep -F 'libcplxscale1.so.1.2.3' || true)")"
    fi

    # --- the directory alias, which a whole-path lookup cannot resolve --------
    #
    # `tools/python/current -> version` is the alias layout this effort already
    # reads, and it puts the link in a PREFIX of the selected path rather than at
    # its end: the observed scope holds `current/lib/libcplxdir.so.1` while the
    # walk, which does not follow a symlinked directory, records the object under
    # `version/lib/libcplxdir.so.1.2.3`. Both links have to be applied, and the
    # directory one first, or a normally loaded library is reported as reachable
    # by nothing. This has its own tree because the alias must be a tool root's
    # immediate subdirectory to be in scope at all.
    section "step 3 aliases: a symlinked directory in the selected path"
    if [ "$alias_ok" != "yes" ]; then
        unanswered "the directory alias case" \
          "  re-run on a host where ln -s makes a symlink, so a directory alias can be planted"
    else
        dir_tree="$SCRATCH/step3/diralias"
        # The donor's own needs are planted here too, so the run below is
        # ACCEPTED and the alias result is read from a tree with nothing else
        # wrong in it.
        for id in dir-alias-target dir-alias-consumer dir-alias-soname \
                  dir-alias-directory provider-donor-need; do
            result=$(fixture_plant "$dir_tree" "$id")
            chk "step3/fixture/$id" "ok" "$result"
        done
        # Its control comes first: the scope really does reach the provider
        # through the alias, so the case below is about resolving that alias and
        # not about a directory nothing selects.
        paths=$(step3_provider_paths "$dir_tree" "libcplxdir.so.1")
        chk "step3/alias/selected-through-the-directory" "yes" \
            "$(printf '%s\n' "$paths" | grep -q '/current/lib/libcplxdir.so.1$' \
               && echo yes || echo no)"
        run_checker "$checker" --prefix "$dir_tree" --installer "$installer" \
            --root "python=current,version"
        chk "step3/alias/directory-alias-exit-code" "0" "$CHECKER_RC"
        chk "step3/alias/target-behind-the-alias-absent" "" \
            "$(oneline "$(typed_lines UNREFERENCED-BY-EDGE | grep -F 'libcplxdir.so.1.2.3' || true)")"
        chk "step3/alias/consumer-behind-the-alias-named" "yes" \
            "$(typed_lines UNREFERENCED-BY-EDGE | grep -qF 'libcplxdiruser.so.1' \
               && echo yes || echo no)"

        # THREE CHAINS THE KERNEL RESOLVES, so the resolver must too. Each is
        # built whole and asserts with `-ef` that the host reaches the same file,
        # which is what makes the expectation the filesystem's answer rather than
        # the harness's opinion.
        for id in chain-relative-parent chain-through-updir chain-nine-links; do
            result=$(fixture_plant "$dir_tree" "$id")
            chk "step3/fixture/$id" "ok" "$result"
        done
        run_checker "$checker" --prefix "$dir_tree" --installer "$installer" \
            --root "python=current,version,linkdir"
        chk "step3/alias/chains-exit-code" "0" "$CHECKER_RC"
        chk "step3/alias/no-chain-left-unresolved" "0" "$(report_field unresolved)"
        for id in libcplxrel libcplxupdir libcplxdeep; do
            chk "step3/alias/chain-reaches-$id" "" \
                "$(oneline "$(typed_lines UNREFERENCED-BY-EDGE | grep -F "$id.so.1.2" || true)")"
        done
        # The controls: each chain's consumer IS in the list, so the three cases
        # above are about the chain resolving and not about edges nobody made.
        for id in libcplxrel libcplxupdir libcplxdeep; do
            chk "step3/alias/chain-consumer-$id" "yes" \
                "$(typed_lines UNREFERENCED-BY-EDGE | grep -qF "${id}user.so.1" \
                   && echo yes || echo no)"
        done
    fi

    # The tree the cases below read is the one the sections above prepared.
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$roots1" --root "$roots2"

    # --- a subject is not a provider ------------------------------------------
    #
    # `build_elf_rpath` never adds `root/usr/bin`, so the second `libssl.so.3` is
    # examined like every other shipped object and resolves nothing. The FIRST one
    # exists in a provider directory, which is what stops this case passing merely
    # because the index happens to hold no such name at all.
    section "step 3 providers: shipped is not the same as resolvable"
    paths=$(step3_provider_paths "$tree" "libssl.so.3")
    chk "step3/providers/first-libssl-indexed" \
        "$tree/tools/python/root/usr/lib64/libssl.so.3" "$(oneline "$paths")"
    chk "step3/providers/second-libssl-not-indexed" "" \
        "$(oneline "$(printf '%s\n' "$paths" | grep -F 'root/usr/bin' || true)")"
    chk "step3/providers/second-libssl-is-a-subject" "yes" \
        "$(typed_lines UNREFERENCED-BY-EDGE | grep -qF "$tree/tools/python/root/usr/bin/libssl.so.3" \
           && echo yes || echo no)"
    chk "step3/providers/directories" "3" "$(report_field providers)"

    # --- one walk, one index, and the index first -----------------------------
    #
    # MEASURED FROM A RUN, never read out of the source text. A grep can show one
    # occurrence of a function name and say nothing about how many times it ran or
    # in what order, and the O(n^2) shape this forbids is exactly an index built
    # inside the object loop, which a source-text count cannot see.
    section "step 3 cost: one walk, one index, built before the first read"
    step3_instrumented "$log" "$stubs" "--prefix" "$tree" "--installer" "$installer" \
        "--root" "$roots1" "--root" "$roots2"
    chk "step3/cost/one-tree-walk" "1" "$(grep -c '^WALK$' "$log" || true)"
    chk "step3/cost/one-index-construction" "1" "$(grep -c '^INDEX$' "$log" || true)"
    chk "step3/cost/index-before-the-walk" "INDEX" "$(sed -n 1p "$log")"
    chk "step3/cost/one-read-per-object" "$planted_elf" "$(grep -c '^READ$' "$log" || true)"
    chk "step3/cost/instrumented-run-agrees" "0" "$CHECKER_RC"

    # --- the fail-closed reading rule -----------------------------------------
    #
    # AN UNAVAILABLE INPUT IS NOT A SEMANTIC REFUSAL. A refusal says the archive
    # is wrong; this says the reading could not be taken. The consequence is the
    # same where it matters, because an UNDETERMINED never counts toward a green.
    section "step 3 reader: an input that could not be obtained"
    result=$(fixture_plant "$tree" reader-unreadable-object)
    if [ "$result" = "still-readable" ]; then
        unanswered "the unreadable-object case" \
          "  this account can read a mode 000 file, so re-run as a non-root user"
    else
        chk "step3/fixture/reader-unreadable-object" "ok" "$result"
        run_checker "$checker" --prefix "$tree" --installer "$installer" \
            --root "$roots1" --root "$roots2"
        chk "step3/reader/unreadable-exit-code" "5" "$CHECKER_RC"
        chk "step3/reader/unreadable-is-undetermined" "1" "$(report_field unread)"
        chk "step3/reader/unreadable-names-the-object" \
            "UNDETERMINED|object|$tree/tools/git/current/lib/libcplxunreadable.so.1" \
            "$(oneline "$(typed_lines UNDETERMINED | sed -e 's/|[^|]*$//')")"
        chk "step3/reader/unreadable-never-a-refusal" "0" "$(report_field refused)"
        rm -f -- "$tree/tools/git/current/lib/libcplxunreadable.so.1"
    fi

    # A RECOGNIZED RECORD WHOSE VALUE CANNOT BE READ, taken with the REAL reader
    # at status 0. A DT_NEEDED whose string offset falls outside the string table
    # prints as the raw value with no brackets, so a parser matching only the
    # bracketed shape drops the entry, records the object with an empty
    # dependency set, and resolves and refuses nothing. The fixture asserts the
    # reader exited 0, so this is a value that could not be read and not a reader
    # that failed.
    section "step 3 reader: a dynamic record whose value cannot be read"
    # The baseline is taken from a run of its own rather than inherited from the
    # case above, whose fixture stays planted on a host that can read a mode 000
    # file and would move both numbers under this case without failing it.
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$roots1" --root "$roots2"
    edges=$(report_field edges)
    planted_elf=$(report_field subjects)
    result=$(fixture_plant "$tree" reader-needed-value-unreadable)
    chk "step3/fixture/reader-needed-value-unreadable" "ok" "$result"
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$roots1" --root "$roots2"
    chk "step3/reader/unreadable-value-exit-code" "5" "$CHECKER_RC"
    chk "step3/reader/unreadable-value-is-undetermined" "1" "$(report_field unread)"
    chk "step3/reader/unreadable-value-names-the-field" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'a DT_NEEDED entry carries no readable name' \
           && echo yes || echo no)"
    chk "step3/reader/unreadable-value-names-the-object" "yes" \
        "$(typed_lines UNDETERMINED | grep -qF 'libcplxbadneed.so.1' && echo yes || echo no)"
    chk "step3/reader/unreadable-value-never-a-refusal" "0" "$(report_field refused)"
    # NO PARTIAL MODEL. The refused object contributed no edge, so the count is
    # the one the clean tree produced. A parser that recorded what it could parse
    # and dropped the rest would leave a subject whose dependency set nobody can
    # vouch for, which reads exactly like an object with fewer needs.
    chk "step3/reader/unreadable-value-adds-no-edge" "$edges" "$(report_field edges)"
    chk "step3/reader/unreadable-value-is-not-a-subject" "$planted_elf" "$(report_field subjects)"
    rm -f -- "$tree/tools/git/current/lib/libcplxbadneed.so.1"

    # AN INCOMPLETE TRAVERSAL IS AN UNAVAILABLE INPUT, and it is the input a
    # green run is least able to survive: a walk that reached nothing reports an
    # empty tree, and every count below it then agrees. Three ways it happens,
    # each asserted against the same control, the complete walk above.
    section "step 3 walk: a traversal that could not be taken"
    mkdir -p -- "$tree/tools/git/current/lib/cplxlocked" || true
    cp -- "$DONOR_SHARED" "$tree/tools/git/current/lib/cplxlocked/libcplxhidden.so.1" 2>/dev/null
    chmod 000 -- "$tree/tools/git/current/lib/cplxlocked" 2>/dev/null
    if find "$tree/tools/git/current/lib/cplxlocked" -type f >/dev/null 2>&1; then
        chmod 755 -- "$tree/tools/git/current/lib/cplxlocked" 2>/dev/null
        rm -rf -- "$tree/tools/git/current/lib/cplxlocked"
        unanswered "the unreadable-subtree case" \
          "  this account can traverse a mode 000 directory, so re-run as a non-root user"
    else
        run_checker "$checker" --prefix "$tree" --installer "$installer" \
            --root "$roots1" --root "$roots2"
        chk "step3/walk/locked-subtree-exit-code" "5" "$CHECKER_RC"
        chk "step3/walk/locked-subtree-is-incomplete" "yes" \
            "$( [ "$(report_field walk)" = "complete" ] && echo no || echo yes )"
        chk "step3/walk/locked-subtree-typed" "yes" \
            "$(typed_lines UNDETERMINED | grep -q '^UNDETERMINED|traversal|' && echo yes || echo no)"
        # THE POINT OF THE CASE. Without the status the run is green: the hidden
        # object never reaches the loop, so no object result can carry it.
        chk "step3/walk/locked-subtree-not-green" "" \
            "$(oneline "$(printf '%s' "$CHECKER_OUT" | grep -F 'CLOSURE MEMBERSHIP OK' || true)")"
        chmod 755 -- "$tree/tools/git/current/lib/cplxlocked" 2>/dev/null
        rm -rf -- "$tree/tools/git/current/lib/cplxlocked"
    fi

    step3_write_stub "$stubs/nofind" "" 'exit 1'
    step3_run_with_path "$stubs/nofind:$PATH" "$checker" --prefix "$tree" \
        --installer "$installer" --root "$roots1" --root "$roots2"
    chk "step3/walk/failing-finder-exit-code" "5" "$CHECKER_RC"
    chk "step3/walk/failing-finder-typed" "yes" \
        "$(typed_lines UNDETERMINED | grep -q '^UNDETERMINED|traversal|' && echo yes || echo no)"
    chk "step3/walk/failing-finder-not-green" "" \
        "$(oneline "$(printf '%s' "$CHECKER_OUT" | grep -F 'CLOSURE MEMBERSHIP OK' || true)")"

    # And the finder that does not resolve at all, which is the mirror of the
    # absent-reader case below and must not be mistaken for an empty tree either.
    # The reader here reaches the REAL binary by its resolved path, because a
    # stub that called `readelf` under a PATH holding only itself would recurse.
    rm -rf -- "$stubs/onlyreadelf"
    mkdir -p -- "$stubs/onlyreadelf"
    { printf '#!/bin/bash\n'; printf 'exec "%s" "$@"\n' "$FIXTURE_READELF"; } \
        > "$stubs/onlyreadelf/readelf"
    chmod +x -- "$stubs/onlyreadelf/readelf"
    step3_run_with_path "$stubs/onlyreadelf" "$checker" --prefix "$tree" \
        --installer "$installer" --root "$roots1" --root "$roots2"
    chk "step3/walk/absent-finder-exit-code" "5" "$CHECKER_RC"
    chk "step3/walk/absent-finder-names-it" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'find did not resolve' && echo yes || echo no)"

    # THE CONTROL FOR ALL THREE: the same tree on the real PATH walks completely.
    run_checker "$checker" --prefix "$tree" --installer "$installer" \
        --root "$roots1" --root "$roots2"
    chk "step3/walk/control/complete-again" "complete" "$(report_field walk)"
    chk "step3/walk/control/green-again" "0" "$CHECKER_RC"

    section "step 3 reader: a reader that could not be reached"
    step3_write_stub "$stubs/absent" ""
    step3_run_with_path "$stubs/absent" "$checker" --prefix "$tree" \
        --installer "$installer" --root "$roots1" --root "$roots2"
    chk "step3/reader/absent-exit-code" "5" "$CHECKER_RC"
    chk "step3/reader/absent-names-the-input" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'readelf did not resolve' && echo yes || echo no)"

    step3_write_stub "$stubs/failing" 'exit 3'
    step3_run_with_path "$stubs/failing:$PATH" "$checker" --prefix "$tree" \
        --installer "$installer" --root "$roots1" --root "$roots2"
    chk "step3/reader/non-zero-exit-code" "5" "$CHECKER_RC"
    chk "step3/reader/non-zero-all-undetermined" "$planted_elf" "$(report_field unread)"

    step3_write_stub "$stubs/garbage" 'printf "cplx: not the output of a reader\n"'
    step3_run_with_path "$stubs/garbage:$PATH" "$checker" --prefix "$tree" \
        --installer "$installer" --root "$roots1" --root "$roots2"
    chk "step3/reader/unparsable-exit-code" "5" "$CHECKER_RC"
    chk "step3/reader/unparsable-all-undetermined" "$planted_elf" "$(report_field unread)"

    # THE LOCALE PIN, MEASURED. The parse reads readelf's own field labels, so a
    # translated build would silently yield empty needs. The stub translates
    # unless LC_ALL is C, and the checker's pin is what keeps the run identical.
    #
    # THE AMBIENT VALUE IS `POSIX`, AND THAT IS THE WHOLE TRICK. What is under
    # test is the PIN and not a translation, and the stub keys on the STRING it
    # is handed: it answers honestly for `C` and translates for anything else. A
    # French locale name would say the same thing and would make `setlocale`
    # warn into the capture on every host that does not carry it, which is a
    # message about the harness's own shell and not a result. `POSIX` resolves
    # everywhere, is not the string `C`, and so is translated by the stub: if the
    # checker did not pin, this is exactly the run that would return empty needs.
    section "step 3 reader: the locale pin, shown by a translating reader"
    step3_write_translating_stub "$stubs/translated"
    line=$(LC_ALL=POSIX "$stubs/translated/readelf" -d -- "$DONOR_SHARED" \
           | grep -c 'Shared library' || true)
    chk "step3/reader/control/stub-really-translates" "0" "$line"
    line=$(LC_ALL=C "$stubs/translated/readelf" -d -- "$DONOR_SHARED" \
           | grep -c 'Shared library' || true)
    chk "step3/reader/control/stub-is-honest-under-C" "$shared_needs" "$line"
    LC_ALL=POSIX step3_run_with_path "$stubs/translated:$PATH" "$checker" --prefix "$tree" \
        --installer "$installer" --root "$roots1" --root "$roots2"
    chk "step3/reader/pinned-locale-still-parses" "0" "$(report_field unread)"
    chk "step3/reader/pinned-locale-same-verdict" "0" "$CHECKER_RC"
}

# ------------------------------------------------------ the step 4 helpers ---
# The whole rest of one summary row, so a case can assert three counts in one
# line instead of re-deriving them from the typed results the row summarises.
# `report_field` answers the FIRST number of a row and these rows carry three.
report_row() {
    printf '%s\n' "$CHECKER_OUT" | grep -E "^  $1 " | sed -n 1p | sed -e "s/^  $1  *//"
}

# A bundle the checker will accept: the records this case needs, plus the
# envelope naming their digest. The digest comes from the module's own function,
# so a bundle is built the way packaging will build it rather than by a second
# implementation of the domain.
step4_write_bundle() {
    local dir="$1" digest
    shift
    mkdir -p -- "$dir" || return 1
    { printf 'CPLX-CLOSURE/1\n'; printf '%s\n' "$@"; } > "$dir/closure-config.txt"
    digest=$(config_digest "$dir/closure-config.txt")
    step2_write_envelope "$dir/closure-envelope.txt" "$digest" \
        "src/setups/env/closure/closure-config.txt" \
        "0123456789abcdef0123456789abcdef01234567"
}

# How many entry-point locations one document declares, asked of the module's own
# parsed model rather than counted out of the text.
step4_entry_count() {
    # shellcheck disable=SC2016  # the child Bash expands its positional arguments
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        closure_config_parse "$2" >/dev/null || exit 93
        printf "%s" "${#CLOSURE_CFG_ENTRY[@]}"
    ' _ "$SHIPPED_DIR/closure_config.sh" "$1" 2>/dev/null
}

# One planted grammar defect, refused with the reason the record table names. The
# control for every one of them is the committed document above, which parses.
step4_refuse() {
    local dir="$1" name="$2" body="$3" want="$4"
    { printf 'CPLX-CLOSURE/1\n'; printf 'root|python\n'; printf '%s\n' "$body"; } \
        > "$dir/g-$name.txt"
    config_call closure_config_parse "$dir/g-$name.txt"
    chk "step4/grammar/$name" "1|$want" "$CONFIG_RC|$(oneline "$CONFIG_OUT")"
}

step4_plant() {
    local tree="$1" id result
    shift
    for id in "$@"; do
        result=$(fixture_plant "$tree" "$id")
        chk "step4/fixture/$id" "ok" "$result"
    done
}

# Run the real checker with an unavailable digest operation in the rules module.
# Configuration hashing still runs normally. An alias-only provider needs no
# content comparison, so making this operation fail must not change its verdict.
step4_run_without_digest() {
    # shellcheck disable=SC2016  # the child Bash expands its positional arguments
    CHECKER_OUT=$("${BASH:-bash}" -c '
        source "$1" || exit 91
        shift
        closure_elf_digest() {
            printf "__UNEXPECTED_DIGEST__\n"
            return 1
        }
        closure_check_main "$@"
    ' _ "$@" 2>&1)
    CHECKER_RC=$?
}

# =============================================================== the step 4 suite ===
step4_suite() {
    local checker="$SHIPPED_DIR/closure_check.sh"
    local installer="$SHIPPED_DIR/install_pkg.sh"
    local rules="$SHIPPED_DIR/closure_rules.sh"
    local config="$SHIPPED_DIR/closure_config.sh"
    local reader="$SHIPPED_DIR/closure_elf.sh"
    local committed="$SHIPPED_DIR/../closure/closure-config.txt"
    local dir="$SCRATCH/step4"
    local floor="$dir/floor" coh="$dir/coherence" esc="$dir/escape"
    local same="$dir/same" diff="$dir/diff" pos="$dir/positive" kinds="$dir/kinds"
    local sealed="$dir/sealed"
    local fam="$dir/family" ep="$dir/entry" agg="$dir/aggregate" loop="$dir/loop"
    local id line vn lookups
    local famname permitted gencount gens dupname pa da pb db

    mkdir -p -- "$dir" || { fail "step4/scratch" "cannot create the scratch directory"; return; }

    # --- the boundary the topology draws, measured rather than described ------
    section "step 4 topology: the invariants live where the boundary puts them"
    if [ ! -f "$rules" ] || [ ! -f "$config" ] || [ ! -f "$reader" ]; then
        fail "step4/topology/modules-exist" "a checker module is missing"
        unanswered "every step 4 case" \
          "  fill the five checker modules under src/setups/env/bin, then repeat this call"
        return
    fi
    chk "step4/topology/rules-declared-commands" "" \
        "$(oneline "$(shipped_undeclared_words "$rules")")"
    chk "step4/topology/config-declared-commands" "" \
        "$(oneline "$(shipped_undeclared_words "$config")")"
    chk "step4/topology/reader-declared-commands" "" \
        "$(oneline "$(shipped_undeclared_words "$reader")")"
    # THE COMPLETION CRITERION IN CODE. One definition of the UNDETERMINED
    # producer, and no second site in this module printing that verdict, so the
    # rule that it means a missing input has one implementation.
    chk "step4/topology/undetermined-defined-once" "1" \
        "$(grep -c '^closure_result_undetermined()' "$rules")"
    chk "step4/topology/undetermined-has-no-second-producer" "1" \
        "$(sed -e 's/#.*$//' "$rules" | grep -c 'printf.*UNDETERMINED')"
    # The rules module decides and never orchestrates: no exit of its own, and the
    # checker prints no invariant's typed verdict.
    chk "step4/topology/rules-holds-no-exit" "" \
        "$(oneline "$(sed -e 's/#.*$//' "$rules" | grep -nE '(^|[;&|] *)exit( |$)' || true)")"
    chk "step4/topology/checker-holds-no-invariant-verdict" "" \
        "$(oneline "$(sed -e 's/#.*$//' "$checker" | grep -nE 'REFUSED\|(floor|coherence|duplicates|families)' || true)")"
    for id in closure_floor_check closure_coherence_check closure_rule1_duplicates \
              closure_rule2_families; do
        chk "step4/topology/checker-calls-$id" "yes" \
            "$(sed -e 's/#.*$//' "$checker" | grep -q "$id" && echo yes || echo no)"
    done
    chk "step4/topology/checker-calls-the-combined-finding" "yes" \
        "$(sed -e 's/#.*$//' "$checker" | grep -q 'closure_report_unreferenced "' && echo yes || echo no)"

    # --- the record the declaration gained ------------------------------------
    section "step 4 grammar: the entry-point record, and its four refusals"
    if [ ! -f "$committed" ]; then
        fail "step4/grammar/committed-exists" "no closure-config.txt at $committed"
    else
        config_call closure_config_parse "$committed"
        chk "step4/grammar/committed-parses" "0|" "$CONFIG_RC|$(oneline "$CONFIG_OUT")"
        chk "step4/grammar/committed-declares-entry-points" "8" \
            "$(step4_entry_count "$committed")"
    fi
    step4_refuse "$dir" undeclared-root 'entrypoint|tools/perl/bin' \
        'REFUSED|3|cross-reference|entrypoint-root names the undeclared root perl'
    step4_refuse "$dir" outside-the-tools-tree 'entrypoint|opt/python/bin' \
        'REFUSED|3|domain|entry-location: opt/python/bin'
    step4_refuse "$dir" one-segment-location 'entrypoint|tools' \
        'REFUSED|3|domain|entry-location: tools'
    step4_refuse "$dir" duplicate-location \
        "$(printf 'entrypoint|tools/python/bin\nentrypoint|tools/python/bin')" \
        'REFUSED|4|duplicate|entrypoint: tools/python/bin'

    # --- the fixture engine ---------------------------------------------------
    section "step 4 fixtures: donors validated, every mutation asserted"
    if ! fixture_resolve_tools; then
        unanswered "the step 4 fixture generation" \
          "  readelf and dd must both resolve here; re-run on a host that supplies them"
        return
    fi
    DONOR_SHARED=$(donor_find_shared) || DONOR_SHARED=""
    DONOR_PROGRAM=$(donor_find_program) || DONOR_PROGRAM=""
    chk "step4/fixture/shared-donor-validated" "yes" \
        "$( [ -n "$DONOR_SHARED" ] && echo yes || echo no )"
    chk "step4/fixture/program-donor-validated" "yes" \
        "$( [ -n "$DONOR_PROGRAM" ] && echo yes || echo no )"
    if [ -z "$DONOR_SHARED" ] || [ -z "$DONOR_PROGRAM" ]; then
        unanswered "every step 4 fixture" \
          "  no host object satisfies the corpus donor rows here; re-run on the RHEL 9.8 build host or on the Debian 12 agent"
        return
    fi
    DONOR_NEED_NAMES=$( { elf_needed_names "$DONOR_SHARED"; elf_needed_names "$DONOR_PROGRAM"; } \
                        | grep -v '^$' | sort -u )
    lookups=$(elf_needed_names "$DONOR_SHARED" | grep -c .)
    vn=$(elf_verneed_nodes "$DONOR_SHARED")
    note "step4/fixture/donors" "shared $DONOR_SHARED, $lookups needs, $vn version nodes"
    # THE CONTROL FOR THE VERSION MUTATIONS: the donor demands none of the
    # invented nodes and defines none of them, so a fixture that shows one was
    # mutated rather than found.
    chk "step4/fixture/control/donor-demands-no-cplx-node" "no" \
        "$(elf_verneed_demands "$DONOR_SHARED" libcplxprovider.so.1 CPLX_1.0 && echo yes || echo no)"
    chk "step4/fixture/control/donor-defines-no-cplx-node" "no" \
        "$(elf_verdef_defines "$DONOR_SHARED" CPLX_1.0 && echo yes || echo no)"

    # --- the declared floor half ----------------------------------------------
    #
    # THE REQUIRED-LOCATION COLUMN IS THE TEST, so the three runs below move ONE
    # thing at a time: the member absent, the member present under the wrong root,
    # and the member present under the right one.
    section "step 4 floor: the declared half, and its location column"
    step4_plant "$floor" floor-member-absent floor-member-elsewhere
    step4_write_bundle "$floor/bundle" 'root|python' 'root|git' \
        'subdir|python|current' 'subdir|git|current' \
        'floor|libcplxfloor.so.1|any' 'floor|libcplxsql.so.0|tools/python'
    run_checker "$checker" --prefix "$floor" --installer "$installer" \
        --bundle "$floor/bundle" --root python=current --root git=current
    chk "step4/floor/exit-code" "1" "$CHECKER_RC"
    chk "step4/floor/counts" "2 declared, 2 refused" "$(report_row floor)"
    chk "step4/floor/absent-member-named" "REFUSED|floor|libcplxfloor.so.1|any" \
        "$(oneline "$(typed_lines REFUSED | grep -F 'libcplxfloor' | sed -e 's/|[^|]*$//')")"
    chk "step4/floor/location-member-named" "REFUSED|floor|libcplxsql.so.0|tools/python" \
        "$(oneline "$(typed_lines REFUSED | grep -F 'libcplxsql' | sed -e 's/|[^|]*$//')")"
    chk "step4/floor/refusal-is-final" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE FLOOR REFUSED' && echo yes || echo no)"
    # THE LOCATION CONTROL. The same member, present under the root its row
    # requires, is accepted, so the refusal above is about the LOCATION and not
    # about a member the archive never carried.
    step4_plant "$floor" floor-member-present
    run_checker "$checker" --prefix "$floor" --installer "$installer" \
        --bundle "$floor/bundle" --root python=current --root git=current
    chk "step4/floor/control/location-satisfied" "2 declared, 1 refused" "$(report_row floor)"
    chk "step4/floor/control/only-the-absent-member-remains" "yes" \
        "$(typed_lines REFUSED | grep -qF 'libcplxfloor' && echo yes || echo no)"
    # AND THE PRESENCE CONTROL, planted here rather than from a row because it is
    # the same shape the row already asserts, moved one directory.
    printf 'not an ELF: the floor member the control plants\n' \
        > "$floor/tools/python/current/lib/libcplxfloor.so.1"
    run_checker "$checker" --prefix "$floor" --installer "$installer" \
        --bundle "$floor/bundle" --root python=current --root git=current
    chk "step4/floor/control/all-present-accepted" "0" "$CHECKER_RC"
    chk "step4/floor/control/none-refused" "2 declared, 0 refused" "$(report_row floor)"

    # --- an UNEXPECTED directory, with every local result still computed ------
    section "step 4 aggregation: an unexpected directory suppresses nothing"
    step4_plant "$floor" scope-unexpected-toolsubdir
    run_checker "$checker" --prefix "$floor" --installer "$installer" \
        --bundle "$floor/bundle" --root python=current --root git=current
    chk "step4/aggregation/unexpected-exit-code" "1" "$CHECKER_RC"
    chk "step4/aggregation/unexpected-counted" "1" "$(typed_count UNEXPECTED)"
    chk "step4/aggregation/floor-still-computed" "2 declared, 0 refused" "$(report_row floor)"
    chk "step4/aggregation/scope-refusal-is-named" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE SCOPE REFUSED' && echo yes || echo no)"
    rm -rf -- "$floor/tools/python/cplxextra"

    # --- provider-aware version coherence -------------------------------------
    section "step 4 coherence: the provider the object names"
    step4_plant "$coh" provider-donor-need coherence-provider-defines coherence-need-defined
    step4_write_bundle "$coh/bundle" 'root|python' 'subdir|python|root' 'subdir|python|current'
    run_checker "$checker" --prefix "$coh" --installer "$installer" \
        --bundle "$coh/bundle" --root python=root,current
    # THE POSITIVE CONTROL COMES FIRST: a need the selected provider DOES define
    # is accepted, so the refusal below is about the node and not about a rule
    # that refuses every version need it sees.
    chk "step4/coherence/control/defined-need-accepted" "0" "$CHECKER_RC"
    chk "step4/coherence/control/counts" "1 needs, 1 answered, 0 refused" \
        "$(report_row coherence)"
    step4_plant "$coh" coherence-need-undefined
    run_checker "$checker" --prefix "$coh" --installer "$installer" \
        --bundle "$coh/bundle" --root python=root,current
    chk "step4/coherence/undefined-exit-code" "1" "$CHECKER_RC"
    chk "step4/coherence/undefined-counts" "2 needs, 2 answered, 1 refused" \
        "$(report_row coherence)"
    chk "step4/coherence/refusal-names-subject-need-and-provider" \
        "REFUSED|coherence|$coh/tools/python/current/lib/libcplxconsumer.so.1|CPLX_9.9|libcplxprovider.so.1" \
        "$(oneline "$(typed_lines REFUSED | grep -F 'CPLX_9.9' | sed -e 's/|[^|]*$//')")"
    chk "step4/coherence/refusal-names-the-selected-scope" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -qF "the selected provider $coh/tools/python/current/lib/libcplxprovider.so.1 defines no such version node" \
           && echo yes || echo no)"
    chk "step4/coherence/refusal-is-final" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE COHERENCE REFUSED' && echo yes || echo no)"
    # A FLOOR MEMBER ABSENT SUPPRESSES NOTHING. The same tree with one more
    # declared member refuses on the floor AND still answers every version need.
    step4_write_bundle "$coh/bundle2" 'root|python' 'subdir|python|root' \
        'subdir|python|current' 'floor|libcplxmissing.so.1|any'
    run_checker "$checker" --prefix "$coh" --installer "$installer" \
        --bundle "$coh/bundle2" --root python=root,current
    chk "step4/aggregation/floor-absent-refuses" "1 declared, 1 refused" "$(report_row floor)"
    chk "step4/aggregation/unrelated-needs-still-answered" \
        "2 needs, 2 answered, 1 refused" "$(report_row coherence)"

    # --- every recorded need gets a result, whatever the selected file is ------
    #
    # THE THREE SHAPES A SELECTED PROVIDER CAN TAKE besides an object that defines
    # the node. Each has its own case, because a rule that answered them alike
    # would let a known non-object satisfy a version need or turn an unavailable
    # reading into a claim about the archive. The control for all three is the
    # accepted need above, which the same invariant answers on the same tree
    # shape.
    section "step 4 coherence: a known non-object, and an object defining nothing"
    step4_plant "$kinds" provider-donor-need coherence-provider-not-an-elf \
        coherence-need-non-object coherence-provider-no-definitions \
        coherence-need-no-definitions
    step4_write_bundle "$kinds/bundle" 'root|python' 'subdir|python|root' 'subdir|python|current'
    run_checker "$checker" --prefix "$kinds" --installer "$installer" \
        --bundle "$kinds/bundle" --root python=root,current
    chk "step4/coherence/kinds-exit-code" "1" "$CHECKER_RC"
    chk "step4/coherence/kinds-counts" "2 needs, 2 answered, 2 refused" "$(report_row coherence)"
    # NO NEED IS LEFT UNANSWERED, which is the property a silent skip would break
    # and which no count alone would show.
    chk "step4/coherence/kinds-every-need-answered" "yes" \
        "$( [ "$(report_field coherence)" = "2" ] && echo yes || echo no )"
    chk "step4/coherence/non-object-refused" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'is not an ELF object, so it defines no version node' \
           && echo yes || echo no)"
    chk "step4/coherence/non-object-names-the-subject" \
        "REFUSED|coherence|$kinds/tools/python/current/lib/libcplxtextuser.so.1|CPLX_1.0|libcplxtext.so.1" \
        "$(oneline "$(typed_lines REFUSED | grep -F 'libcplxtext.so.1' | sed -e 's/|[^|]*$//')")"
    chk "step4/coherence/no-definitions-refused" \
        "REFUSED|coherence|$kinds/tools/python/current/lib/libcplxbareuser.so.1|CPLX_1.0|libcplxbare.so.1" \
        "$(oneline "$(typed_lines REFUSED | grep -F 'libcplxbare.so.1' | sed -e 's/|[^|]*$//')")"
    chk "step4/coherence/kinds-no-undetermined" "0" "$(report_field results)"

    # AND THE ONE THAT IS NOT A REFUSAL. A provider whose reading could not be
    # taken defines nothing this run can state, so its need is UNDETERMINED naming
    # it rather than a claim about the archive.
    # ITS OWN TREE, so the run carries the UNDETERMINED and NOTHING ELSE: an
    # unavailable reading has to leave the run non-passing on its own, and a
    # refusal beside it would decide the exit code and hide that.
    section "step 4 coherence: a provider whose reading could not be taken"
    step4_plant "$sealed" provider-donor-need
    result=$(fixture_plant "$sealed" coherence-provider-unreadable)
    if [ "$result" = "still-readable" ]; then
        unanswered "the unreadable-provider case" \
          "  this account can read a mode 000 file, so re-run as a non-root user"
    else
        chk "step4/fixture/coherence-provider-unreadable" "ok" "$result"
        step4_plant "$sealed" coherence-need-unreadable
        step4_write_bundle "$sealed/bundle" 'root|python' 'subdir|python|root' \
            'subdir|python|current'
        run_checker "$checker" --prefix "$sealed" --installer "$installer" \
            --bundle "$sealed/bundle" --root python=root,current
        chk "step4/coherence/unreadable-exit-code" "5" "$CHECKER_RC"
        chk "step4/coherence/unreadable-no-refusal-anywhere" "" \
            "$(oneline "$(typed_lines REFUSED)")"
        chk "step4/coherence/unreadable-counts" "1 needs, 0 answered, 0 refused" \
            "$(report_row coherence)"
        chk "step4/coherence/unreadable-is-undetermined" \
            "UNDETERMINED|coherence|$sealed/tools/python/current/lib/libcplxsealeduser.so.1" \
            "$(oneline "$(typed_lines UNDETERMINED | grep -F 'libcplxsealeduser' | sed -e 's/|[^|]*$//')")"
        chk "step4/coherence/unreadable-names-the-input" "yes" \
            "$(printf '%s' "$CHECKER_OUT" | grep -q 'whose reading could not be taken' \
               && echo yes || echo no)"
        # THE UNDETERMINED IS COUNTED AS ONE, so an unavailable reading was
        # reported as a missing input rather than as a claim about the archive.
        chk "step4/coherence/unreadable-counted-as-a-result" "1" "$(report_field results)"
    fi

    # --- the fourth coherence condition, which is static like the other three --
    section "step 4 coherence: a resolution that leaves the archive"
    step4_plant "$esc" provider-donor-need provider-escapes-archive \
        coherence-resolution-leaves-archive
    step4_write_bundle "$esc/bundle" 'root|python' 'subdir|python|root' 'subdir|python|current'
    run_checker "$checker" --prefix "$esc" --installer "$installer" \
        --bundle "$esc/bundle" --root python=root,current
    chk "step4/coherence/escape-exit-code" "1" "$CHECKER_RC"
    chk "step4/coherence/escape-names-subject-need-and-provider" \
        "REFUSED|coherence|$esc/tools/python/current/lib/libcplxescape.so.1|CPLX_1.0|libcplxhostonly.so.1" \
        "$(oneline "$(typed_lines REFUSED | grep '^REFUSED|coherence|' | sed -e 's/|[^|]*$//')")"
    chk "step4/coherence/escape-names-the-outside-file" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -qF "leaves the archive and resolves to $DONOR_SHARED" \
           && echo yes || echo no)"
    # Its control: the DT_NEEDED half accepts that same candidate, because a file
    # of that name IS in the scope. The two halves answer different questions and
    # neither stands in for the other.
    chk "step4/coherence/escape-membership-still-resolves" "0" "$(report_field refused)"

    # --- rule 1, and the control that it does not over-refuse ------------------
    section "step 4 duplicates: one file from several directories is one provider"
    step4_plant "$same" provider-donor-need provider-duplicate-identical \
        subject-identical-consumer
    step4_write_bundle "$same/bundle" 'root|python' 'subdir|python|root' 'subdir|python|current'
    run_checker "$checker" --prefix "$same" --installer "$installer" \
        --bundle "$same/bundle" --root python=root,current
    chk "step4/duplicates/identical-accepted" "0" "$CHECKER_RC"
    chk "step4/duplicates/identical-counts" \
        "$(( lookups + 1 )) names, 1 multi-candidate, 0 refused" "$(report_row duplicates)"

    section "step 4 duplicates: two candidates, different content"
    step4_plant "$diff" provider-donor-need provider-duplicate-different \
        duplicate-first-defines duplicate-consumer-need
    # The first candidate was replanted over the differing copy to give it the
    # node the consumer demands, so the two paths are re-asserted to still differ
    # rather than assumed to.
    chk "step4/duplicates/two-paths-still-differ" "differ" \
        "$( [ "$(fixture_digest "$diff/tools/python/current/lib/libcplxdup.so.1")" \
             != "$(fixture_digest "$diff/tools/git/current/lib/libcplxdup.so.1")" ] \
            && echo differ || echo same )"
    step4_write_bundle "$diff/bundle" 'root|python' 'root|git' 'subdir|python|root' \
        'subdir|python|current' 'subdir|git|current'
    run_checker "$checker" --prefix "$diff" --installer "$installer" \
        --bundle "$diff/bundle" --root python=root,current --root git=current
    chk "step4/duplicates/different-exit-code" "1" "$CHECKER_RC"
    chk "step4/duplicates/different-counts" \
        "$(( lookups + 1 )) names, 1 multi-candidate, 1 refused" "$(report_row duplicates)"
    line=$(typed_lines REFUSED | grep '^REFUSED|duplicates|' | sed -n 1p)
    IFS='|' read -r _ _ dupname pa da pb db _ <<< "$line"
    chk "step4/duplicates/refusal-names-name-and-both-paths" \
        "libcplxdup.so.1|$diff/tools/python/current/lib/libcplxdup.so.1|$diff/tools/git/current/lib/libcplxdup.so.1" \
        "$dupname|$pa|$pb"
    chk "step4/duplicates/refusal-digests-differ" "differ" \
        "$( [ "$da" != "$db" ] && echo differ || echo same )"
    # THE DIGESTS ARE THE FILES'. Without this the refusal could carry any two
    # strings and the case would still pass.
    chk "step4/duplicates/refusal-digests-are-the-files" "yes" \
        "$( [ "$da" = "$(fixture_digest "$pa")" ] && [ "$db" = "$(fixture_digest "$pb")" ] \
            && echo yes || echo no )"
    chk "step4/duplicates/refusal-is-final" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE DUPLICATE REFUSED' && echo yes || echo no)"
    # THE ROUND 2 CORRECTION, ASSERTED AS THE PRESENCE OF A RESULT. Rule 1 refuses
    # this name and coherence STILL EVALUATES against the first candidate in scope
    # order, so the run carries a coherence answer beside the duplicate refusal
    # rather than one instead of the other.
    chk "step4/duplicates/coherence-still-answers" \
        "1 needs, 1 answered, 0 refused" "$(report_row coherence)"

    section "step 4 duplicates: the positive control, twenty names over one file"
    step4_plant "$pos" provider-donor-need multi-candidate-population dir-alias-directory
    step4_write_bundle "$pos/bundle" 'root|python' 'subdir|python|root' \
        'subdir|python|current' 'subdir|python|version'
    run_checker "$checker" --prefix "$pos" --installer "$installer" \
        --bundle "$pos/bundle" --root python=root,current,version
    chk "step4/duplicates/positive-control-accepted" "0" "$CHECKER_RC"
    chk "step4/duplicates/positive-control-counts" \
        "$(( lookups + 20 )) names, 20 multi-candidate, 0 refused" "$(report_row duplicates)"
    step4_run_without_digest "$checker" --prefix "$pos" --installer "$installer" \
        --bundle "$pos/bundle" --root python=root,current,version
    chk "step4/duplicates/alias-only-needs-no-digest" "0" "$CHECKER_RC"
    chk "step4/duplicates/alias-only-digest-not-called" "" \
        "$(printf '%s\n' "$CHECKER_OUT" | grep '^__UNEXPECTED_DIGEST__$' || true)"

    # --- rule 2, declared and undeclared --------------------------------------
    section "step 4 families: declared generations, and the declared blind spot"
    step4_plant "$fam" provider-donor-need family-two-generations family-two-generations-peer
    step4_write_bundle "$fam/bundle" 'root|python' 'root|git' 'subdir|python|root' \
        'subdir|git|root' 'subdir|git|current' 'family|cplx-bfd|libcplxbfd-*.so|1'
    run_checker "$checker" --prefix "$fam" --installer "$installer" \
        --bundle "$fam/bundle" --root python=root --root git=root,current
    chk "step4/families/declared-exit-code" "1" "$CHECKER_RC"
    chk "step4/families/declared-counts" "1 declared, 1 refused" "$(report_row families)"
    line=$(typed_lines REFUSED | grep '^REFUSED|families|' | sed -n 1p)
    IFS='|' read -r _ _ famname permitted gencount gens <<< "$line"
    chk "step4/families/refusal-fields" "cplx-bfd|1|2" "$famname|$permitted|$gencount"
    chk "step4/families/refusal-names-both-generations" "yes" \
        "$( printf '%s' "$gens" | grep -q 'libcplxbfd-1.1.so' \
            && printf '%s' "$gens" | grep -q 'libcplxbfd-1.2.so' && echo yes || echo no )"
    chk "step4/families/refusal-is-final" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE FAMILY REFUSED' && echo yes || echo no)"
    # THE DECLARED BLIND SPOT, asserted rather than left as silence: the same
    # pair, with no family record, is NOT EXAMINED.
    step4_write_bundle "$fam/bundle2" 'root|python' 'root|git' 'subdir|python|root' \
        'subdir|git|root' 'subdir|git|current'
    run_checker "$checker" --prefix "$fam" --installer "$installer" \
        --bundle "$fam/bundle2" --root python=root --root git=root,current
    chk "step4/families/undeclared-accepted" "0" "$CHECKER_RC"
    chk "step4/families/undeclared-not-examined" "0 declared, 0 refused" "$(report_row families)"

    # --- the entry-point half, and the finding that combines the two ----------
    section "step 4 entry points: the half a declaration supplies"
    step4_plant "$ep" provider-donor-need entry-point-program dir-alias-directory
    step4_write_bundle "$ep/bundle" 'root|python' 'subdir|python|root' \
        'subdir|python|current' 'subdir|python|version' \
        'entrypoint|tools/python/current/bin'
    run_checker "$checker" --prefix "$ep" --installer "$installer" \
        --bundle "$ep/bundle" --root python=root,current,version
    chk "step4/entrypoints/declared-accepted" "0" "$CHECKER_RC"
    # The location is declared through the ALIAS and the walk recorded the object
    # under the version directory, so this line also measures that the declared
    # location is resolved rather than compared as text.
    chk "step4/entrypoints/declared-counts" \
        "1 declared, 1 subjects named, 0 reached by neither half" "$(report_row entrypoints)"
    chk "step4/entrypoints/program-not-in-the-finding" "" \
        "$(oneline "$(typed_lines UNREFERENCED | grep -F 'cplxentry' || true)")"
    # ITS CONTROL: the EDGE half still names the same object under its own name,
    # so the case is about the declaration and not about an edge that reached it.
    chk "step4/entrypoints/edge-half-still-names-it" "yes" \
        "$(typed_lines UNREFERENCED-BY-EDGE | grep -qF 'cplxentry' && echo yes || echo no)"
    # AND THE PAIR THAT SHOWS THE DECLARATION IS READ: the same object, with the
    # record removed, IS reported by the combined finding.
    step4_write_bundle "$ep/bundle2" 'root|python' 'subdir|python|root' \
        'subdir|python|current' 'subdir|python|version'
    run_checker "$checker" --prefix "$ep" --installer "$installer" \
        --bundle "$ep/bundle2" --root python=root,current,version
    chk "step4/entrypoints/undeclared-counts" \
        "0 declared, 0 subjects named, 1 reached by neither half" "$(report_row entrypoints)"
    chk "step4/entrypoints/program-in-the-finding" \
        "UNREFERENCED|subject|$ep/tools/python/version/bin/cplxentry" \
        "$(oneline "$(typed_lines UNREFERENCED | sed -e 's/|[^|]*$//')")"
    chk "step4/entrypoints/finding-is-not-a-refusal" "0" "$CHECKER_RC"

    # --- aggregation: UNDETERMINED means one thing ----------------------------
    section "step 4 aggregation: a version need with no provider file to read"
    step4_plant "$agg" provider-donor-need coherence-need-unresolved
    step4_write_bundle "$agg/bundle" 'root|python' 'subdir|python|root' 'subdir|python|current'
    run_checker "$checker" --prefix "$agg" --installer "$installer" \
        --bundle "$agg/bundle" --root python=root,current
    chk "step4/aggregation/unresolved-exit-code" "1" "$CHECKER_RC"
    chk "step4/aggregation/the-name-is-a-refusal" "yes" \
        "$(typed_lines REFUSED | grep -q '^REFUSED|derived|.*|libcplxnoprovider.so.1|' \
           && echo yes || echo no)"
    chk "step4/aggregation/the-need-is-undetermined" \
        "UNDETERMINED|coherence|$agg/tools/python/current/lib/libcplxlost.so.1" \
        "$(oneline "$(typed_lines UNDETERMINED | sed -e 's/|[^|]*$//')")"
    chk "step4/aggregation/undetermined-names-the-provider" "yes" \
        "$(printf '%s' "$CHECKER_OUT" \
           | grep -q 'names libcplxnoprovider.so.1, which resolves nowhere' && echo yes || echo no)"
    chk "step4/aggregation/undetermined-counted" "1" "$(report_field results)"

    section "step 4 aggregation: an UNDETERMINED and no refusal is not a pass"
    step4_plant "$loop" entry-point-cycle
    step4_write_bundle "$loop/bundle" 'root|python' 'subdir|python|root' \
        'entrypoint|tools/python/loop/a'
    run_checker "$checker" --prefix "$loop" --installer "$installer" \
        --bundle "$loop/bundle" --root python=root
    chk "step4/aggregation/no-refusal-anywhere" "" "$(oneline "$(typed_lines REFUSED)")"
    chk "step4/aggregation/still-not-a-pass" "5" "$CHECKER_RC"
    chk "step4/aggregation/names-the-location-it-lacked" \
        "UNDETERMINED|entry-point|tools/python/loop/a" \
        "$(oneline "$(typed_lines UNDETERMINED | sed -e 's/|[^|]*$//')")"
    chk "step4/aggregation/verdict-is-undetermined" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE RESULTS UNDETERMINED' && echo yes || echo no)"

    # --- the verdict says what it answered ------------------------------------
    section "step 4 verdict: partial, and it names what a run answered"
    chk "step4/verdict/says-it-is-partial" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'verdict is PARTIAL' && echo yes || echo no)"
    chk "step4/verdict/names-the-bundle-state" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'bundle read yes' && echo yes || echo no)"
    run_checker "$checker" --prefix "$loop" --installer "$installer" --root python=root
    chk "step4/verdict/no-bundle-is-said-so" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'bundle read no' && echo yes || echo no)"
    # WITHOUT A DECLARATION THERE IS NO ENTRY-POINT HALF, so the combined finding
    # is not reported at all and the edge half keeps its own name. A run that
    # printed the conjunction from a set nobody declared would name a shipped
    # executable as an object nothing can load.
    chk "step4/verdict/no-bundle-no-combined-finding" "" \
        "$(oneline "$(typed_lines UNREFERENCED)")"
    chk "step4/verdict/no-bundle-no-entry-points" \
        "0 declared, 0 subjects named, 0 reached by neither half" "$(report_row entrypoints)"
}

# ------------------------------------------------------------------- step 5 ---
# THE GATE, THE WAIVERS AND THE PUBLICATION BOUNDARY. Step 4 finished the
# invariants and nothing called them: `pkg.sh` tarred with no gate in front of
# it, so every invariant implemented so far was unreachable from a real
# packaging run. This suite asserts the three things that changes.
#
# THE SELECTOR IS TESTED AT ALL FOUR CORNERS, each its own case, because they
# fail for four different reasons and one case would assert only the corner it
# planted. The two that refuse are the ones that make the selector TOTAL rather
# than optional: a flag with no contract for the payload it was given, and the
# one payload this requirement exists to gate being packaged without it.
#
# THE WAIVER MODEL IS TESTED BY THE FAILURES IT MUST ITSELF PRODUCE. An exception
# that cannot expire is a mute, so the stale case is the one that matters most:
# it plants the waived member and requires the run to refuse the WAIVER rather
# than pass the floor.
#
# PUBLICATION IS TESTED AS AN ORDER. A stripped configuration must fail at step 1
# and never reach step 4, because "no active waivers" returned by an absence is
# the failure the order exists to prevent.
#
# THE TRANSACTION IS PROVED BY WHAT IT LEAVES BEHIND ON FAILURE, not by what it
# does on success, so the stub uploader is ASKED WHAT IT HAS PUBLISHED rather
# than being trusted to have exited correctly.

# A DEPLOYED CPLX TREE, which is what the build account actually has. It is not a
# checkout and it must not be one: step 5 found that the machine running `pkg.sh`
# has no cplx repository, that cplx arrives there as copied scripts, and that the
# one stale checkout on that account would have supplied a year-old declaration
# while looking authoritative. A fixture built with `git init` would have proved
# the gate works in a situation that never occurs.
#
# The layout mirrors the repository the way the deployment does, `src/setups/env/<x>`
# arriving as `<cplx root>/<x>`, because that is how `pkg.sh` finds both `echos`
# and now the declaration.
step5_make_deployed_tree() {
    local root="$1" src="$2" module
    mkdir -p -- "$root/bin" "$root/closure" || return 1
    for module in "${CLOSURE_MODULES[@]}"; do
        cp -- "$src/$module" "$root/bin/$module" || return 1
    done
    cp -- "$src/install_pkg.sh" "$root/bin/install_pkg.sh" || return 1
    cp -- "$src/pkg.sh" "$root/bin/pkg.sh" || return 1
    cp -- "$src/pkg_tools.sh" "$root/bin/pkg_tools.sh" || return 1
    # THE DISPATCHER ITSELF, because `pkg tools` finding the overlay beside it is
    # the path the plan names and running `pkg_tools.sh` directly does not prove.
    if [ -f "$src/pkg" ]; then cp -- "$src/pkg" "$root/bin/pkg" || return 1; fi
    if [ -d "$src/../echos" ]; then cp -r -- "$src/../echos" "$root/echos"; fi
    cp -- "$src/../closure/closure-config.txt" "$root/closure/closure-config.txt" || return 1
    # THE COMMITTED ENVELOPE IS COPIED, NOT REGENERATED. It is a file in the
    # repository beside the declaration, so the fixture ships what the deployment
    # ships; a fixture that wrote its own would test a bundle nobody deploys and
    # would pass even if the committed pair disagreed.
    cp -- "$src/../closure/closure-envelope.txt" "$root/closure/closure-envelope.txt" || return 1
    return 0
}

# The envelope regenerated for the cases that need a bundle they have MUTATED,
# where the committed pair is deliberately not the subject.
step5_write_deployed_envelope() {
    local dir="$1" digest=""
    digest=$(sha256sum < "$dir/closure-config.txt") || return 1
    digest="${digest%% *}"
    { printf 'CPLX-CLOSURE-ENVELOPE/1\n'
      printf 'digest|%s\n' "$digest"
      printf 'source|%s|%s\n' "src/setups/env/closure/closure-config.txt" \
        "0123456789abcdef0123456789abcdef01234567"; } > "$dir/closure-envelope.txt"
}

# A cplx checkout for the PUBLICATION cases only. Publication is "cplx only" in
# the topology and resolves the configuration from a commit itself, so a repository
# is the right fixture there and the wrong one for the gate. Prints the commit.
step5_make_publication_repo() {
    local repo="$1" src="$2" module
    mkdir -p -- "$repo/src/setups/env/bin" "$repo/src/setups/env/closure" || return 1
    for module in "${CLOSURE_MODULES[@]}"; do
        cp -- "$src/$module" "$repo/src/setups/env/bin/$module" || return 1
    done
    cp -- "$src/install_pkg.sh" "$repo/src/setups/env/bin/install_pkg.sh" || return 1
    cp -- "$src/../closure/closure-config.txt" \
        "$repo/src/setups/env/closure/closure-config.txt" || return 1
    ( cd "$repo" || exit 1
      git init -q . >/dev/null 2>&1 || exit 1
      git config user.email harness@example.invalid
      git config user.name harness
      git add -A >/dev/null 2>&1
      git commit -q -m 'the reviewed declaration' >/dev/null 2>&1 ) || return 1
    git -C "$repo" rev-parse HEAD 2>/dev/null
}

# The stub uploader, which implements the four-operation ABI and RECORDS what it
# was asked to do. Its public objects live under one directory, so "nothing is
# public" is a directory listing rather than an exit status.
# shellcheck disable=SC2016  # every expansion below belongs to the ADAPTER this
# writes, not to the harness: the stub is a file the publication run sources, so
# `$1` is its own argument and `$CPLX_STUB_ROOT` its own variable. Expanding them
# here would bake this harness's values into a script whose whole purpose is to
# be driven by another process, which is the same intentional-literal rule the
# earlier steps' child-shell helpers carry.
step5_write_adapter() {
    local out="$1" root="$2" mode="${3:-ok}"
    { printf '#!/bin/bash\n'
      printf 'CPLX_STUB_ROOT=%s\n' "$root"
      printf 'CPLX_STUB_MODE=%s\n' "$mode"
      printf 'upload_begin() {\n'
      printf '    if [ "$CPLX_STUB_MODE" = "begin-fails" ]; then return 1; fi\n'
      printf '    mkdir -p -- "$CPLX_STUB_ROOT/stage" || return 1\n'
      printf '    printf %s >> "$CPLX_STUB_ROOT/begin.log"\n' "'begin\\n'"
      printf '    printf %s "$CPLX_STUB_ROOT/stage/object"\n' '%s'
      printf '}\n'
      printf 'upload_write() {\n'
      printf '    if [ "$CPLX_STUB_MODE" = "write-fails" ]; then dd of=/dev/null 2>/dev/null; return 1; fi\n'
      # THE STREAM IS HELD OPEN ON REQUEST, so an interruption can be delivered
      # while the transaction is DEMONSTRABLY streaming rather than at a moment
      # the harness guessed. The readiness file is written BEFORE the wait, so
      # the caller learns the phase was ENTERED rather than that time passed.
      printf '    if [ "$CPLX_STUB_MODE" = "stream-waits" ]; then\n'
      printf '        printf %s > "$CPLX_STUB_ROOT/streaming.ready"\n' "'streaming\\n'"
      printf '        while [ ! -e "$CPLX_STUB_ROOT/stream.release" ]; do sleep 0.1; done\n'
      printf '    fi\n'
      printf '    dd of="$1" 2>/dev/null\n'
      printf '}\n'
      printf 'upload_abort() {\n'
      printf '    printf %s >> "$CPLX_STUB_ROOT/abort.log"\n' "'abort\\n'"
      # THE ABORT IS HELD OPEN THE SAME WAY, and the count is appended BEFORE the
      # wait. A second entry is therefore visible even when the process never
      # leaves the first one, which is what the cleanup interruption needs: it
      # counts ENTRIES rather than completions.
      printf '    if [ "$CPLX_STUB_MODE" = "abort-waits" ]; then\n'
      printf '        printf %s > "$CPLX_STUB_ROOT/aborting.ready"\n' "'aborting\\n'"
      printf '        while [ ! -e "$CPLX_STUB_ROOT/abort.release" ]; do sleep 0.1; done\n'
      printf '    fi\n'
      printf '    if [ "$CPLX_STUB_MODE" = "abort-fails" ]; then return 1; fi\n'
      printf '    rm -f -- "$1"\n'
      printf '}\n'
      printf 'upload_commit() {\n'
      printf '    if [ "$CPLX_STUB_MODE" = "commit-fails" ]; then return 1; fi\n'
      printf '    mkdir -p -- "$CPLX_STUB_ROOT/public" || return 1\n'
      printf '    cp -- "$1" "$CPLX_STUB_ROOT/public/object"\n'
      printf '}\n'; } > "$out"
}

# What the stub has made PUBLIC, which is the only question worth asking it.
step5_public_count() {
    local root="$1"
    if [ ! -d "$root/public" ]; then printf '0'; return; fi
    find "$root/public" -type f 2>/dev/null | grep -c . || true
}

step5_abort_count() {
    local root="$1"
    if [ ! -f "$root/abort.log" ]; then printf '0'; return; fi
    grep -c . < "$root/abort.log" || true
}

# Whether a stage was ever begun, which is the difference between a failure
# BEFORE the transaction owns anything and one after. A case that only counts
# aborts cannot tell those apart: no abort is the right answer for both.
step5_begin_count() {
    local root="$1"
    if [ ! -f "$root/begin.log" ]; then printf '0'; return; fi
    grep -c . < "$root/begin.log" || true
}

# A minimal prefix tree that satisfies the committed declaration's floor, so a
# gate run over it is green for reasons this suite planted rather than by luck.
step5_make_tree() {
    local home="$1" member
    mkdir -p -- "$home/tools/python/root/lib" "$home/tools/git/root/lib" || return 1
    mkdir -p -- "$home/tools/python/current" "$home/tools/python/python-3.13.9" || return 1
    for member in libc.so.6 libpthread.so.0 libdl.so.2 librt.so.1 libutil.so.1 \
                  libstdc++.so.6 libgcc_s.so.1 libcrypto.so.3 libssl.so.3; do
        printf 'not an ELF: a planted floor member\n' > "$home/tools/python/root/lib/$member"
    done
    mkdir -p -- "$home/tools/python/root/lib" || return 1
    printf 'not an ELF: the waived member, present\n' \
        > "$home/tools/python/root/lib/libsqlite3.so.0"
    # THE PAYLOAD CARRIES ITS OWN COPY OF THE PACKAGING SCRIPTS, which is true of
    # the real account and is what makes the source-equals-destination case
    # reachable: `~/tools/bin/pkg.sh` exists there, and a gated run started from
    # it would stage into the directory it read from.
    mkdir -p -- "$home/tools/bin" || return 1
    cp -- "$SHIPPED_DIR/pkg.sh" "$home/tools/bin/pkg.sh" || return 1
    cp -- "$SHIPPED_DIR/pkg_tools.sh" "$home/tools/bin/pkg_tools.sh" || return 1
    return 0
}

# Exercise packaging ownership with a controlled checker verdict. The main gate
# cases below still run the real checker; these cases isolate filesystem effects.
step5_packaging_preservation() {
    local dir="$1" repo="$1/deploy" home="$1/home" stub="$1/stubs"
    local out="" rc=0 before="" stages="" arg=""
    step5_make_deployed_tree "$repo" "$SHIPPED_DIR" || return 1
    step5_make_tree "$home" || return 1
    mkdir -p -- "$stub" "$home/tools/root/usr/bin" || return 1
    printf '#!/bin/bash\nexit 0\n' > "$repo/bin/closure_check.sh"
    printf '#!/bin/bash\nprintf "2026-09-13_120000\\n"\n' > "$stub/date"
    chmod +x "$stub/date"
    printf 'compiler fixture\n' > "$home/tools/root/usr/bin/gcc"
    printf 'extension fixture\n' > "$home/extra.txt"

    out=$(HOME="$home" PATH="$stub:$PATH" bash "$repo/bin/pkg_tools.sh" \
        --add extra.txt -- --mtime=2026-01-01 2>&1); rc=$?
    chk "step5/packaging/first-run" "0" "$rc"
    chk "step5/packaging/reported-archive-exists" "yes" \
        "$( [ -f "$(printf '%s\n' "$out" | tail -1)" ] && echo yes || echo no )"
    chk "step5/packaging/add-reads-original-home" "extension fixture" \
        "$(tar -xOzf "$home/pkgs/tools.latest.tar.gz" extra.txt 2>/dev/null)"
    chk "step5/packaging/compiler-is-trimmed" "no" \
        "$(tar -tzf "$home/pkgs/tools.latest.tar.gz" | grep -qx 'tools/root/usr/bin/gcc' && echo yes || echo no)"
    before=$(sha256sum < "$home/pkgs/tools.latest.tar.gz")

    out=$(HOME="$home" PATH="$stub:$PATH" bash "$repo/bin/pkg_tools.sh" \
        --add extra.txt -- --mtime=2026-01-01 2>&1); rc=$?
    chk "step5/packaging/same-second-duplicate-succeeds" "0" "$rc"
    chk "step5/packaging/same-second-duplicate-preserves-latest" "$before" \
        "$(sha256sum < "$home/pkgs/tools.latest.tar.gz" 2>/dev/null)"
    chk "step5/packaging/duplicate-keeps-one-archive" "1" \
        "$(find "$home/pkgs" -maxdepth 1 -name '*.tar.gz' -type f | wc -l)"

    printf 'changed extension\n' > "$home/extra.txt"
    out=$(HOME="$home" PATH="$stub:$PATH" bash "$repo/bin/pkg_tools.sh" \
        --add extra.txt -- --mtime=2026-01-01 2>&1); rc=$?
    chk "step5/packaging/occupied-name-refuses-new-content" "2" "$rc"
    chk "step5/packaging/occupied-name-preserves-latest" "$before" \
        "$(sha256sum < "$home/pkgs/tools.latest.tar.gz" 2>/dev/null)"
    out=$(HOME="$home" bash "$repo/bin/pkg_tools.sh" --add missing.txt 2>&1); rc=$?
    chk "step5/packaging/tar-failure-refuses" "2" "$rc"
    chk "step5/packaging/tar-failure-preserves-latest" "$before" \
        "$(sha256sum < "$home/pkgs/tools.latest.tar.gz" 2>/dev/null)"
    chk "step5/packaging/failures-leave-no-partial" "0" \
        "$(find "$home/pkgs" -name '*.partial' -type f | wc -l)"

    stages=$(find "$home" -maxdepth 1 -name '.cplx-pkgstage.*' | wc -l)
    for arg in --source-root "--source-root=$home"; do
        out=$(HOME="$home" bash "$repo/bin/pkg_tools.sh" "$arg" "$home" 2>&1); rc=$?
        chk "step5/packaging/override-$arg-refuses" "3" "$rc"
    done
    chk "step5/packaging/override-creates-no-stage" "$stages" \
        "$(find "$home" -maxdepth 1 -name '.cplx-pkgstage.*' | wc -l)"
    chk "step5/packaging/override-leaves-live-gate-absent" "yes" \
        "$( [ ! -e "$home/tools/closure" ] && echo yes || echo no )"

    # After --, this token is a tar exclusion pattern, not a pkg.sh option.
    out=$(HOME="$home" bash "$repo/bin/pkg_tools.sh" -- --exclude --source-root 2>&1); rc=$?
    chk "step5/packaging/literal-tar-pattern-is-preserved" "0" "$rc"
}

step5_loader_aliases() {
    local dir="$1" home="$1/home" repo="$1/deployed" mode out rc before after
    mkdir -p -- "$repo/bin" "$home/tools/python/root/usr/lib64" \
        "$home/tools/git/root/usr/lib64" "$home/tools/git/root/lib64" || return 1
    cp -- "$SHIPPED_DIR/pkg_tools.sh" "$SHIPPED_DIR/install_pkg.sh" "$repo/bin/" || return 1
    # Inspect the stage at the packaging boundary. No tar or static gate is
    # needed to test whether preparation preserves identity and source bytes.
    cat > "$repo/bin/pkg.sh" <<'LOADER_STAGE_PROBE'
#!/bin/bash
stage="$4"
canonical="$stage/tools/python/root/usr/lib64/ld-linux-x86-64.so.2"
other="$stage/tools/git/root/usr/lib64/ld-linux-x86-64.so.2"
[ -L "$other" ] && [ "$canonical" -ef "$other" ] || exit 91
case "$(readlink "$other")" in /*) exit 92 ;; esac
[ "$canonical" -ef "$stage/tools/git/root/lib64/ld-linux-x86-64.so.2" ] || exit 93
printf 'LOADER-STAGE|preserved\n'
LOADER_STAGE_PROBE
    for mode in identical different broken escaping; do
        printf 'canonical loader bytes\n' > "$home/tools/python/root/usr/lib64/ld-linux-x86-64.so.2"
        rm -f -- "$home/tools/git/root/usr/lib64/ld-linux-x86-64.so.2"
        cp -- "$home/tools/python/root/usr/lib64/ld-linux-x86-64.so.2" \
            "$home/tools/git/root/usr/lib64/ld-linux-x86-64.so.2"
        ln -sfn ../usr/lib64/ld-linux-x86-64.so.2 "$home/tools/git/root/lib64/ld-linux-x86-64.so.2"
        case "$mode" in
            different) printf 'other bytes\n' > "$home/tools/git/root/usr/lib64/ld-linux-x86-64.so.2" ;;
            broken) rm -f -- "$home/tools/git/root/usr/lib64/ld-linux-x86-64.so.2" ;;
            escaping)
                printf 'canonical loader bytes\n' > "$dir/outside-loader"
                ln -sfn "$dir/outside-loader" "$home/tools/git/root/usr/lib64/ld-linux-x86-64.so.2" ;;
        esac
        before=$(sha256sum "$home/tools/python/root/usr/lib64/ld-linux-x86-64.so.2")
        out=$(HOME="$home" bash "$repo/bin/pkg_tools.sh" 2>&1); rc=$?
        if [ "$mode" = identical ]; then
            chk "step5/loader/$mode/preserves-relative-aliases" "0" "$rc"
            chk "step5/loader/$mode/reaches-package" yes "$(printf '%s' "$out" | grep -q '^LOADER-STAGE|preserved$' && echo yes || echo no)"
            chk "step5/loader/$mode/live-copy-stays-regular" no "$( [ -L "$home/tools/git/root/usr/lib64/ld-linux-x86-64.so.2" ] && echo yes || echo no )"
        else
            chk "step5/loader/$mode/refuses" "3" "$rc"
            chk "step5/loader/$mode/never-reaches-package" no "$(printf '%s' "$out" | grep -q '^LOADER-STAGE|' && echo yes || echo no)"
        fi
        after=$(sha256sum "$home/tools/python/root/usr/lib64/ld-linux-x86-64.so.2")
        chk "step5/loader/$mode/live-canonical-unchanged" "$before" "$after"
    done
}

step5_suite() {
    local dir="$SCRATCH/step5"
    local src="$SHIPPED_DIR"
    local report="$SHIPPED_DIR/closure_report.sh"
    local publish="$SHIPPED_DIR/closure_publish.sh"
    local pkg="$SHIPPED_DIR/pkg.sh"
    local repo="" commit="" home="" out="" rc=0 stub="" adapter="" root="" cplxrepo=""
    local before="" archive="" id="" cfg="" tool="" tp="" cleanrepo="" cleancommit="" module="" hashdigest=""

    mkdir -p -- "$dir" || { fail "step5/scratch" "cannot create the scratch directory"; return; }

    step5_packaging_preservation "$dir/packaging-preservation" \
        || fail "step5/packaging/fixture" "cannot plant the packaging fixtures"
    step5_loader_aliases "$dir/loader-aliases" \
        || fail "step5/loader/fixture" "cannot plant loader identity controls"

    # --- the amended topology --------------------------------------------------
    section "step 5 topology: the fifth module, and what it is not allowed to own"
    if [ ! -f "$report" ] || [ ! -f "$publish" ] || [ ! -f "$pkg" ]; then
        fail "step5/topology/files-exist" "a step 5 file is missing"
        unanswered "every step 5 case" \
          "  create closure_report.sh and closure_publish.sh under src/setups/env/bin, then repeat this call"
        return
    fi
    chk "step5/topology/report-declared-commands" "" \
        "$(oneline "$(shipped_undeclared_words "$report")")"
    chk "step5/topology/publish-declared-commands" "" \
        "$(oneline "$(shipped_undeclared_words "$publish")")"
    # THE REPORT OWNS NO VERDICT AND NO EXIT CODE. The move would be pointless if
    # the report module could decide what a run returns, so the assertion is
    # mechanical and it is about the CHECKER'S STATUS CODES, 2, 3 and 5, not
    # about `return 1`. A refusal helper returning 1 to its own aggregator is an
    # ordinary boolean and appears in this module by design; 2, 3 and 5 are the
    # values `closure_check.sh` hands to `pkg.sh`, and none of them may be
    # decided here.
    chk "step5/topology/report-decides-no-checker-status" "" \
        "$(oneline "$(sed -e 's/#.*$//' "$report" | grep -nE 'return [235]$' || true)")"
    # AND THE ENTRY POINT STILL HOLDS THEM, so the assertion above measures a
    # boundary rather than the absence of exit codes anywhere.
    chk "step5/topology/entry-point-still-decides-status" "yes" \
        "$(sed -e 's/#.*$//' "$SHIPPED_DIR/closure_check.sh" | grep -qE 'return 3$' && echo yes || echo no)"
    # AND THE ENTRY POINT STILL HAS NO WAIVER CODE PATH, which is the property
    # step 1 measures and step 5 is the step most likely to break, because this
    # is where waivers arrive.
    chk "step5/topology/entry-point-has-no-waiver-path" "" \
        "$(oneline "$(sed -e 's/#.*$//' "$SHIPPED_DIR/closure_check.sh" | grep -nE 'waiv' || true)")"
    # NO SIXTH MODULE, stated against the tree the way step 1 states the fifth.
    chk "step5/topology/no-closure_scope.sh" "no" \
        "$( [ -f "$SHIPPED_DIR/closure_scope.sh" ] && echo yes || echo no )"

    # THE COMMITTED PAIR MUST AGREE, which is the whole maintenance rule the
    # envelope carries. It is a file in the repository rather than something a
    # deploy step produces, so the only way it can go wrong is a declaration
    # edited without its receipt, and that is exactly what this asserts. An
    # archive shipping a receipt for bytes it does not carry would otherwise be
    # a green run.
    chk "step5/envelope/committed-pair-agrees" \
        "$(sha256sum < "$SHIPPED_DIR/../closure/closure-config.txt" | cut -d' ' -f1)" \
        "$(sed -n 's/^digest|//p' "$SHIPPED_DIR/../closure/closure-envelope.txt" | head -1)"
    chk "step5/envelope/committed-envelope-names-a-source" "yes" \
        "$(grep -qE '^source\|[^|]+\|[0-9a-f]{40}$' "$SHIPPED_DIR/../closure/closure-envelope.txt" && echo yes || echo no)"

    # --- the selector, at all four corners -------------------------------------
    section "step 5 selector: four corners, and two of them refuse"
    home="$dir/home"
    step5_make_tree "$home" || { fail "step5/selector/tree" "cannot plant the prefix tree"; return; }
    repo="$dir/cplx"
    step5_make_deployed_tree "$repo" "$src" \
        || { fail "step5/selector/deployed-tree" "cannot plant the deployed cplx tree"; return; }
    # THE FIXTURE IS NOT A CHECKOUT, and the case says so out loud, because the
    # defect this replaced was a gate that only worked inside one.
    chk "step5/selector/fixture-is-not-a-checkout" "no" \
        "$( [ -e "$repo/.git" ] && echo yes || echo no )"

    # The flag with a target that is not `tools`: no contract for that payload.
    out=$(HOME="$home" bash "$repo/bin/pkg.sh" other --closure-gate 2>&1); rc=$?
    chk "step5/selector/flag-with-other-target-refuses" "1" "$rc"
    chk "step5/selector/flag-with-other-target-says-why" "yes" \
        "$(printf '%s' "$out" | grep -q "applies to the 'tools' payload only" && echo yes || echo no)"
    # The target `tools` with no flag: the run this requirement exists to gate.
    out=$(HOME="$home" bash "$repo/bin/pkg.sh" tools 2>&1); rc=$?
    chk "step5/selector/tools-without-flag-refuses" "1" "$rc"
    chk "step5/selector/tools-without-flag-says-why" "yes" \
        "$(printf '%s' "$out" | grep -q 'requires --closure-gate' && echo yes || echo no)"
    # A RENAMED TARGET NEITHER RECEIVES THE GATE NOR STANDS IN FOR `tools`.
    out=$(HOME="$home" bash "$repo/bin/pkg.sh" tools2 2>&1); rc=$?
    chk "step5/selector/tools2-is-not-tools" "yes" \
        "$(printf '%s' "$out" | grep -q 'requires --closure-gate' && echo no || echo yes)"
    # AN UNRELATED TARGET WITH NO FLAG BEHAVES AS IT DID BEFORE THIS EFFORT and
    # never enters the branch, which a grep for the gate's own output proves.
    mkdir -p -- "$home/other" && printf 'payload\n' > "$home/other/file.txt"
    out=$(HOME="$home" bash "$repo/bin/pkg.sh" other 2>&1); rc=$?
    chk "step5/selector/unrelated-target-unchanged" "0" "$rc"
    chk "step5/selector/unrelated-target-skips-the-gate" "yes" \
        "$(printf '%s' "$out" | grep -q 'Closure gate' && echo no || echo yes)"

    # --- the gate, run rather than grepped -------------------------------------
    #
    # THE DISPATCHER IS EXECUTED. A grep for the flag in the overlay proves the
    # text contains it, which is not the same claim as the gate being reached
    # through `pkg tools`, and the reviewer was right that the weaker one was
    # standing in for the stronger.
    section "step 5 gate: staged from the deployed tree, and no repository anywhere"
    rm -f -- "$home/tools/python/root/lib/libsqlite3.so.0"
    # `pkg tools` THROUGH THE DISPATCHER, which is the path the plan names: the
    # dispatcher finds the `pkg_tools.sh` overlay beside it and execs that, and
    # the overlay adds the flag. Running the overlay directly skips the first
    # half of that and proves only the second.
    if [ -f "$repo/bin/pkg" ]; then
        out=$(HOME="$home" bash "$repo/bin/pkg" tools 2>&1); rc=$?
        chk "step5/gate/dispatcher-reaches-the-gate" "yes" \
            "$(printf '%s' "$out" | grep -q 'Closure gate' && echo yes || echo no)"
    else
        out=$(HOME="$home" bash "$repo/bin/pkg_tools.sh" 2>&1); rc=$?
        note "step5/gate/dispatcher" "no pkg dispatcher in the tree; the overlay was run directly"
    fi
    # The plan's own acceptance case: the waived member absent, the waiver
    # active, an archive produced and MARKED a validation artifact.
    chk "step5/gate/active-waiver-still-produces-an-archive" "0" "$rc"
    chk "step5/gate/active-waiver-is-marked" "yes" \
        "$(printf '%s' "$out" | grep -q 'VALIDATION ARTIFACT' && echo yes || echo no)"
    chk "step5/gate/archive-exists" "1" \
        "$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | grep -c . || true)"
    # THE STAGED FILES TRAVEL IN THE ARCHIVE, which is the contract. An earlier
    # form of these three read them from `$home/tools` instead, which was the same
    # answer only while the gate staged into the very tree it packaged. It no
    # longer does: `pkg_tools.sh` packages from a trimmed mirror, so the payload
    # copies reach the archive and the live tree is left alone. Reading the
    # archive asserts what the contract says and survives that change; reading the
    # live tree asserted a side effect and did not. The listing is taken once.
    archive=$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | head -1)
    toc=""
    [ -n "$archive" ] && toc=$(tar -tzf "$archive" 2>/dev/null)
    chk "step5/gate/declaration-in-the-archive" "yes" \
        "$(printf '%s\n' "$toc" | grep -qx 'tools/closure/closure-config.txt' && echo yes || echo no)"
    chk "step5/gate/envelope-in-the-archive" "yes" \
        "$(printf '%s\n' "$toc" | grep -qx 'tools/closure/closure-envelope.txt' && echo yes || echo no)"
    chk "step5/gate/five-payload-modules-in-the-archive" "5" \
        "$(printf '%s\n' "$toc" | grep -cE '^tools/bin/closure_[a-z0-9_]+\.sh$' || true)"
    # AND THE LIVE TREE IS NOT WRITTEN, which is the other half of the same
    # change and would otherwise go unasserted. A gate that reached the account's
    # own tools tree would be indistinguishable, from the archive alone, from one
    # that did not.
    chk "step5/gate/the-live-tree-keeps-no-gate-files" "yes" \
        "$( [ ! -e "$home/tools/closure" ] && echo yes || echo no )"

    # SOURCE AND DESTINATION MUST DIFFER. `pkg.sh` now exists inside the payload
    # too, and a gated run from that copy would read its declaration out of the
    # directory it is about to write, certifying its own output.
    out=$(HOME="$home" bash "$home/tools/bin/pkg.sh" tools --closure-gate 2>&1); rc=$?
    chk "step5/gate/inside-the-payload-refuses" "3" "$rc"
    chk "step5/gate/inside-the-payload-says-why" "yes" \
        "$(printf '%s' "$out" | grep -q 'its own destination' && echo yes || echo no)"

    # A different spelling of the payload is still the same source directory.
    # Refusal must preserve source bytes, not truncate them and then refuse.
    local alias_prefix="$dir/alias-prefix" alias_tree="$dir/alias-tree"
    local alias_source="$dir/alias-source" alias_digest=""
    mkdir -p -- "$alias_prefix/tools"
    step5_make_deployed_tree "$alias_prefix/tools" "$src" \
        || { fail "step5/alias/fixture" "cannot plant the payload source"; return; }
    ln -s "$alias_prefix/tools" "$alias_tree" \
        || { fail "step5/alias/link-fixture" "cannot create the directory alias"; return; }
    alias_digest=$(config_digest "$alias_prefix/tools/closure/closure-config.txt")
    out=$(HOME="$alias_prefix" bash "$alias_tree/bin/pkg.sh" tools --closure-gate 2>&1); rc=$?
    chk "step5/gate/payload-directory-alias-refuses" "3" "$rc"
    chk "step5/gate/payload-directory-alias-preserves-source" "$alias_digest" \
        "$(config_digest "$alias_prefix/tools/closure/closure-config.txt")"

    # Distinct roots can still share one file through a hard link. Detect that
    # before any destination is registered for failure cleanup.
    step5_make_deployed_tree "$alias_source" "$src" \
        || { fail "step5/alias/source-fixture" "cannot plant the separate source"; return; }
    rm -f -- "$alias_prefix/tools/closure/closure-config.txt"
    ln "$alias_source/closure/closure-config.txt" "$alias_prefix/tools/closure/closure-config.txt" \
        || { fail "step5/alias/hardlink-fixture" "cannot create the file alias"; return; }
    alias_digest=$(config_digest "$alias_source/closure/closure-config.txt")
    out=$(HOME="$alias_prefix" bash "$alias_source/bin/pkg.sh" tools --closure-gate 2>&1); rc=$?
    chk "step5/gate/shared-file-refuses" "3" "$rc"
    chk "step5/gate/shared-file-preserves-source" "$alias_digest" \
        "$(config_digest "$alias_source/closure/closure-config.txt")"

    # A MISSING DECLARATION REFUSES, and the gate stays keyed to the selector
    # rather than to the bundle's presence: deleting the source cannot turn it
    # off, it only makes the run refuse.
    mv -- "$repo/closure" "$repo/closure.away"
    out=$(HOME="$home" bash "$repo/bin/pkg.sh" tools --closure-gate 2>&1); rc=$?
    chk "step5/gate/absent-declaration-refuses" "3" "$rc"
    chk "step5/gate/absent-declaration-does-not-skip" "yes" \
        "$(printf '%s' "$out" | grep -q 'no closure declaration is deployed' && echo yes || echo no)"
    mv -- "$repo/closure.away" "$repo/closure"

    # A DEPLOYED ENVELOPE THAT DOES NOT DESCRIBE ITS DECLARATION REFUSES. This is
    # the whole of what this account can prove locally, so it has to prove it.
    printf 'root|tampered\n' >> "$repo/closure/closure-config.txt"
    out=$(HOME="$home" bash "$repo/bin/pkg.sh" tools --closure-gate 2>&1); rc=$?
    chk "step5/gate/envelope-mismatch-refuses" "3" "$rc"
    chk "step5/gate/envelope-mismatch-says-both-digests" "yes" \
        "$(printf '%s' "$out" | grep -q 'its envelope names' && echo yes || echo no)"
    step5_write_deployed_envelope "$repo/closure"

    # A REFUSAL LEAVES NOTHING BEHIND, and the case has to be built to mean that.
    # It is about the files THE REFUSING RUN staged, not about files an earlier
    # successful run left: those PERSIST by design, because persisting is what
    # puts them in the archive. So the destination is cleared first, and the
    # refusal is one that happens AFTER staging has written, which is the checker
    # refusing on a tree carrying an undeclared root.
    rm -rf -- "$home/tools/closure" "$home/tools/bin/closure_check.sh" \
        "$home/tools/bin/closure_config.sh" "$home/tools/bin/closure_elf.sh" \
        "$home/tools/bin/closure_report.sh" "$home/tools/bin/closure_rules.sh"
    # The refusal is a FLOOR one, and an UNWAIVED member is what makes it a
    # refusal rather than the accepted exception the run above carried. An
    # undeclared root would not do: this tree's extra directories never enter the
    # OBSERVED loader scope, so nothing would refuse and the case would pass for
    # the wrong reason.
    mv -- "$home/tools/python/root/lib/libssl.so.3" "$home/libssl.so.3.away"
    # COUNTED BEFORE AND AFTER, because this tree already holds the archive the
    # green run produced. Asserting that some archive exists would pass on the
    # earlier one; the claim is that the REFUSING run added none.
    before=$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | grep -c . || true)
    out=$(HOME="$home" bash "$repo/bin/pkg.sh" tools --closure-gate 2>&1); rc=$?
    chk "step5/gate/checker-refusal-adds-no-archive" "$before" \
        "$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | grep -c . || true)"
    chk "step5/gate/checker-refusal-refuses-the-run" "1" "$rc"
    chk "step5/gate/checker-refusal-names-the-floor" "yes" \
        "$(printf '%s' "$out" | grep -q 'CLOSURE FLOOR REFUSED' && echo yes || echo no)"
    chk "step5/gate/refusal-unstages-the-declaration" "no" \
        "$( [ -f "$home/tools/closure/closure-config.txt" ] && echo yes || echo no )"
    chk "step5/gate/refusal-unstages-every-module" "" \
        "$(oneline "$(find "$home/tools/bin" -maxdepth 1 -name 'closure_*.sh' -type f 2>/dev/null)")"

    # A COPY THAT FAILS MIDWAY REFUSES AND LEAVES NOTHING, which is a different
    # path from a missing source: the source is there, the write is what breaks.
    # A `cat` stub that exits non-zero is exactly that failure at the one place
    # staging performs it.
    rm -rf -- "$home/tools/closure"
    mkdir -p -- "$dir/copyfail" || true
    printf '#!/bin/bash\nexit 1\n' > "$dir/copyfail/cat"
    chmod +x "$dir/copyfail/cat"
    out=$(PATH="$dir/copyfail:$PATH" HOME="$home" bash "$repo/bin/pkg.sh" tools --closure-gate 2>&1)
    rc=$?
    chk "step5/gate/failed-copy-refuses" "3" "$rc"
    chk "step5/gate/failed-copy-unstages" "no" \
        "$( [ -f "$home/tools/closure/closure-config.txt" ] && echo yes || echo no )"

    # A STAGED BUNDLE THAT ENDS UP EMPTY refuses too, and this is the assertion
    # that the gate checks what it produced rather than assuming the copy worked.
    # The stub succeeds and writes nothing, which is the shape a truncated write
    # leaves behind.
    mkdir -p -- "$dir/emptycopy" || true
    printf '#!/bin/bash\nexit 0\n' > "$dir/emptycopy/cat"
    chmod +x "$dir/emptycopy/cat"
    out=$(PATH="$dir/emptycopy:$PATH" HOME="$home" bash "$repo/bin/pkg.sh" tools --closure-gate 2>&1)
    rc=$?
    chk "step5/gate/empty-staged-bundle-refuses" "3" "$rc"
    chk "step5/gate/empty-staged-bundle-unstages" "no" \
        "$( [ -f "$home/tools/closure/closure-config.txt" ] && echo yes || echo no )"

    # A PARTIAL WRITE IS NOT AN IMMEDIATE FAILURE, and it is the failure the
    # byte verification exists for: the copy produces SOME bytes and then stops,
    # so a destination that merely exists is not evidence and only comparing it
    # against a second read of the source catches it.
    rm -rf -- "$home/tools/closure"
    before=$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | grep -c . || true)
    mkdir -p -- "$dir/partial" || true
    printf '#!/bin/bash\nprintf %s\nexit 1\n' "'truncated'" > "$dir/partial/cat"
    chmod +x "$dir/partial/cat"
    out=$(PATH="$dir/partial:$PATH" HOME="$home" bash "$repo/bin/pkg.sh" tools --closure-gate 2>&1)
    rc=$?
    chk "step5/gate/partial-write-refuses" "3" "$rc"
    chk "step5/gate/partial-write-adds-no-archive" "$before" \
        "$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | grep -c . || true)"
    chk "step5/gate/partial-write-unstages-completely" "" \
        "$(oneline "$(find "$home/tools/closure" "$home/tools/bin" -maxdepth 1 \( -name 'closure-*.txt' -o -name 'closure_*.sh' \) -type f 2>/dev/null)")"

    # A COMPLETED BUNDLE REMOVED BEFORE THE CHECK. Staging succeeded and the
    # gate's own emptiness test passed, so this is the window between them and
    # the checker call. The stub `bash` deletes the staged declaration and then
    # runs the real checker, which is the only way to land inside that window
    # from outside the process.
    # THE FLOOR IS RESTORED FIRST, and that restoration is the difference
    # between this case and one that cannot fail. The earlier floor-refusal
    # fixture had moved `libssl.so.3` away, so a run here refused on the FLOOR
    # whatever the deletion stub did: every assertion passed with the stub doing
    # nothing at all. With the member back, the only thing that can refuse this
    # run is the removal under test.
    mv -- "$home/libssl.so.3.away" "$home/tools/python/root/lib/libssl.so.3"
    rm -rf -- "$home/tools/closure"
    before=$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | grep -c . || true)
    mkdir -p -- "$dir/racebin" || true
    { printf '#!/bin/bash\n'
      printf 'rm -f -- "%s/tools/closure/closure-config.txt"\n' "$home"
      printf 'exec /bin/bash "$@"\n'; } > "$dir/racebin/bash"
    chmod +x "$dir/racebin/bash"
    out=$(PATH="$dir/racebin:$PATH" HOME="$home" bash "$repo/bin/pkg.sh" tools --closure-gate 2>&1)
    rc=$?
    chk "step5/gate/bundle-removed-before-check-refuses" "1" "$rc"
    # THE DIAGNOSTIC IS THE ASSERTION. A non-zero status is what every refusal
    # in this section returns, so it identifies none of them; the checker
    # refusing on a bundle it cannot establish is what this case is about.
    chk "step5/gate/bundle-removed-names-the-bundle" "yes" \
        "$(printf '%s' "$out" | grep -q 'CLOSURE BUNDLE REFUSED' && echo yes || echo no)"
    chk "step5/gate/bundle-removed-adds-no-archive" "$before" \
        "$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | grep -c . || true)"
    chk "step5/gate/bundle-removed-unstages-completely" "" \
        "$(oneline "$(find "$home/tools/closure" "$home/tools/bin" -maxdepth 1 \( -name 'closure-*.txt' -o -name 'closure_*.sh' \) -type f 2>/dev/null)")"
    # THE CONTROL: the same run with a stub that deletes NOTHING must succeed,
    # which is what proves the three assertions above depend on the removal
    # rather than on anything the fixture left behind.
    rm -rf -- "$home/tools/closure"
    { printf '#!/bin/bash\n'; printf 'exec /bin/bash "$@"\n'; } > "$dir/racebin/bash"
    chmod +x "$dir/racebin/bash"
    out=$(PATH="$dir/racebin:$PATH" HOME="$home" bash "$repo/bin/pkg.sh" tools --closure-gate 2>&1)
    chk "step5/gate/bundle-removed-control-passes-the-gate" "yes" \
        "$(printf '%s' "$out" | grep -q 'CLOSURE BUNDLE REFUSED' && echo no || echo yes)"

    # --- what the gate must not have changed for everyone else -----------------
    #
    # THE CRITERION THIS ANSWERS IS A REGRESSION ONE. Step 5 is the first thing
    # in this effort to modify `pkg.sh`, so the behaviour every other caller
    # depends on has to be shown intact ON A TARGET THAT NEVER ENTERS THE GATE.
    section "step 5 preservation: --add, the passthrough and the SHA1 deduplication"
    mkdir -p -- "$home/extra" && printf 'an extra item\n' > "$home/extra/thing.txt"
    printf 'excluded\n' > "$home/other/skipme.txt"
    out=$(HOME="$home" bash "$repo/bin/pkg.sh" other --add extra -- --exclude=skipme.txt 2>&1)
    rc=$?
    chk "step5/preserve/add-and-passthrough-succeed" "0" "$rc"
    archive=$(printf '%s' "$out" | grep -oE '[^ ]*other\.[0-9_-]+\.tar\.gz' | tail -1)
    if [ -z "$archive" ]; then
        archive=$(find "$home/pkgs" -name 'other.*.tar.gz' -type f 2>/dev/null | sort | tail -1)
    fi
    chk "step5/preserve/add-ships-the-extra-item" "yes" \
        "$(tar -tzf "$archive" 2>/dev/null | grep -q '^extra/' && echo yes || echo no)"
    chk "step5/preserve/passthrough-applied-the-exclusion" "yes" \
        "$(tar -tzf "$archive" 2>/dev/null | grep -q 'skipme.txt' && echo no || echo yes)"
    # THE SAME CONTENT TWICE IS ONE ARCHIVE. The second run computes the same
    # SHA1, deletes its own tarball and names the first, which is the behaviour
    # a consuming project relies on to avoid a pile of identical archives.
    #
    # THE SECOND IS SPACED BY A SECOND ON PURPOSE. `pkg.sh` names archives by a
    # timestamp resolved to the second, so two runs inside one second target the
    # SAME filename: the second overwrites the first and then deduplicates the
    # only copy away. That is the tool's own naming granularity rather than
    # anything this step introduced, and a case that ran both in one second
    # would be asserting against it rather than against deduplication.
    sleep 1
    before=$(find "$home/pkgs" -name 'other.*.tar.gz' -type f 2>/dev/null | grep -c . || true)
    out=$(HOME="$home" bash "$repo/bin/pkg.sh" other --add extra -- --exclude=skipme.txt 2>&1)
    chk "step5/preserve/duplicate-is-deduplicated" "$before" \
        "$(find "$home/pkgs" -name 'other.*.tar.gz' -type f 2>/dev/null | grep -c . || true)"
    chk "step5/preserve/duplicate-says-so" "yes" \
        "$(printf '%s' "$out" | grep -q 'Duplicate detected' && echo yes || echo no)"
    # THE `latest` SYMLINK POINTS AT THE RETAINED ARCHIVE, which is the half of
    # deduplication a consuming project actually follows: it is not enough that
    # the duplicate went away, the surviving name has to be the one reachable.
    #
    # THE TARGET IS COMPARED, not merely the link's existence. A tree that
    # already held an earlier archive satisfies `-e` whatever deduplication did,
    # so that assertion would have passed without the retained object being the
    # one linked.
    archive=$(find "$home/pkgs" -name 'other.*.tar.gz' -type f 2>/dev/null | sort | tail -1)
    chk "step5/preserve/latest-resolves-to-the-retained-archive" \
        "$(sha256sum < "$archive" | cut -d' ' -f1)" \
        "$(sha256sum < "$home/pkgs/other.latest.tar.gz" 2>/dev/null | cut -d' ' -f1)"

    # A SOURCE MUTATED DURING THE COPY yields a digest describing the COMPLETED
    # COPY, never the source. The stub appends a byte on every read, so the copy
    # promotion captured differs from the file the caller named, and the identity
    # must describe what was captured: certifying the source would certify bytes
    # that no longer exist anywhere.
    root="$dir/mutate"
    rm -rf -- "$root"
    mkdir -p -- "$root/staging" "$root/fakebin" || true
    chmod 700 "$root/staging"
    printf 'the source bytes\n' > "$root/candidate.bin"
    # shellcheck disable=SC2016  # the stub's own expansions
    { printf '#!/bin/bash\n'
      printf '/bin/cat "$@"\n'
      printf 'printf %s\n' "'m'"; } > "$root/fakebin/cat"
    chmod +x "$root/fakebin/cat"
    got=$( ( set +u
        # shellcheck disable=SC2030  # local to this subshell on purpose: the stub
        # must be visible to the production code sourced below and to nothing else.
        PATH="$root/fakebin:$PATH"
        # shellcheck source=/dev/null
        . "$publish"
        # shellcheck disable=SC2034  # read by the sourced production module
        CLOSURE_PUBLISH_STAGING="$root/staging"
        closure_publish_promote "$root/candidate.bin" "$root/staging" >/dev/null 2>&1 || exit 1
        printf '%s %s' "$CLOSURE_PUBLISH_IDENTITY" "$CLOSURE_PUBLISH_PROMOTED" ) 2>/dev/null )
    want=$(sha256sum < "$root/candidate.bin"); want="${want%% *}"
    chk "step5/promote/mutation-identity-is-not-the-source" "yes" \
        "$( [ -n "${got%% *}" ] && [ "${got%% *}" != "$want" ] && echo yes || echo no )"
    chk "step5/promote/mutation-identity-describes-the-copy" "yes" \
        "$( [ -f "${got#* }" ] && [ "$(sha256sum < "${got#* }" | cut -d' ' -f1)" = "${got%% *}" ] && echo yes || echo no )"

    # --- the waiver outcomes ---------------------------------------------------
    #
    # The committed declaration waives `libsqlite3.so.0`, so the three outcomes
    # are reached by moving ONE thing at a time: the member present makes the
    # waiver stale, the member absent makes it active, and a waiver naming
    # something the floor does not carry is unknown.
    section "step 5 waivers: unknown, stale, and the exception that stands"
    # THE GATE SECTION ABOVE REMOVED THE WAIVED MEMBER to reach its active-waiver
    # case, and the stale case needs it back. Replanting here rather than
    # depending on section order is the difference between a suite that asserts
    # what it planted and one that inherits whatever ran before it.
    printf 'not an ELF: the waived member, present again\n' \
        > "$home/tools/python/root/lib/libsqlite3.so.0"
    root="$dir/waiver"
    mkdir -p -- "$root/bundle" || true
    cp -- "$src/../closure/closure-config.txt" "$root/bundle/closure-config.txt"
    step2_write_envelope "$root/bundle/closure-envelope.txt" \
        "$(config_digest "$root/bundle/closure-config.txt")" \
        "src/setups/env/closure/closure-config.txt" \
        "0123456789abcdef0123456789abcdef01234567"
    # STALE: the member the waiver names is present, so the exception has
    # already expired and the run refuses the waiver rather than passing.
    run_checker "$SHIPPED_DIR/closure_check.sh" --prefix "$home" \
        --installer "$SHIPPED_DIR/install_pkg.sh" --bundle "$root/bundle"
    chk "step5/waiver/stale-exit-code" "1" "$CHECKER_RC"
    chk "step5/waiver/stale-is-named" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'REFUSED|waiver|libsqlite3.so.0|python-sqlite-support|stale' && echo yes || echo no)"
    chk "step5/waiver/stale-counts" "1 declared, 0 active, 1 refused" \
        "$(printf '%s' "$CHECKER_OUT" | sed -n 's/^  waivers      //p')"
    # ACTIVE: remove the member and the same declaration carries the run.
    rm -f -- "$home/tools/python/root/lib/libsqlite3.so.0"
    run_checker "$SHIPPED_DIR/closure_check.sh" --prefix "$home" \
        --installer "$SHIPPED_DIR/install_pkg.sh" --bundle "$root/bundle"
    chk "step5/waiver/active-exit-code" "3" "$CHECKER_RC"
    chk "step5/waiver/active-is-named" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'WAIVED|waiver|libsqlite3.so.0|python-sqlite-support|active' && echo yes || echo no)"
    chk "step5/waiver/active-says-validation-artifact" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'CLOSURE VALIDATION ARTIFACT' && echo yes || echo no)"
    chk "step5/waiver/active-refuses-no-floor-member" "yes" \
        "$(printf '%s' "$CHECKER_OUT" | grep -q 'REFUSED|floor|libsqlite3.so.0' && echo no || echo yes)"
    chk "step5/waiver/active-counts" "1 declared, 1 active, 0 refused" \
        "$(printf '%s' "$CHECKER_OUT" | sed -n 's/^  waivers      //p')"
    # UNKNOWN IS REACHED THROUGH THE MODEL, NOT THROUGH A BUNDLE, and that is a
    # statement about the design rather than a convenience. The configuration's
    # own cross-reference refuses a waiver the floor does not declare at PARSE
    # time, which step 2 already asserts, so no bundle that passes the envelope
    # check can carry one. The validation below still exists because the two
    # checks protect different things: the parse-time one protects the DOCUMENT,
    # and this one protects the RUN, so a model reaching a checker some other way
    # cannot get a free exception out of it. Driving it directly is the only way
    # to reach that guard, and a case that went through a bundle would be
    # asserting the parser twice and this rule never.
    # shellcheck disable=SC2034  # the model below is planted for the PRODUCTION
    # functions sourced inside the subshell to read, so every consumer of these
    # names is one file over and invisible to a per-file reader.
    step5_waiver_call() {
        WAIVER_OUT=$( ( set +u
            # shellcheck source=/dev/null
            source "$SHIPPED_DIR/closure_config.sh"
            # shellcheck source=/dev/null
            source "$SHIPPED_DIR/closure_elf.sh"
            # shellcheck source=/dev/null
            source "$SHIPPED_DIR/closure_rules.sh"
            CLOSURE_CFG_FLOOR=()
            CLOSURE_CFG_WAIVER=()
            CLOSURE_PROVIDER_PATHS=()
            CLOSURE_CFG_FLOOR["libc.so.6"]="any"
            CLOSURE_CFG_WAIVER["$1"]="some-owner"
            closure_waiver_validate "$2" ) 2>&1 )
    }
    step5_waiver_call "libnothing.so.9" "$home"
    chk "step5/waiver/unknown-is-named" "yes" \
        "$(printf '%s' "$WAIVER_OUT" | grep -q 'REFUSED|waiver|libnothing.so.9|some-owner|unknown' && echo yes || echo no)"
    # A WAIVER CANNOT NAME A TOOL ROOT, and this is the case that shows the code
    # has no rule for roots at all. `python` is a declared root and not a floor
    # member, so it is UNKNOWN by the FIRST rule rather than by a rule written
    # for roots, which is what keeps the unexpected-root refusal unwaivable
    # without a second subject type the design refused to add.
    step5_waiver_call "python" "$home"
    chk "step5/waiver/root-is-unknown-not-special" "yes" \
        "$(printf '%s' "$WAIVER_OUT" | grep -q 'REFUSED|waiver|python|some-owner|unknown' && echo yes || echo no)"

    # --- the promotion order ---------------------------------------------------
    section "step 5 promotion: the gate refuses to act on a path it was shown"
    root="$dir/promote"
    mkdir -p -- "$root/staging" || true
    chmod 700 "$root/staging"
    printf 'candidate bytes\n' > "$root/candidate.bin"
    publish_call() {
        PUBLISH_OUT=$( ( set +u
            # shellcheck source=/dev/null
            source "$publish"
            CLOSURE_PUBLISH_STAGING="$1"
            shift
            "$@" ) 2>&1 )
        PUBLISH_RC=$?
    }
    publish_call "$root/staging" closure_publish_promote "$root/candidate.bin" "$root/staging"
    chk "step5/promote/first-promotion-succeeds" "0" "$PUBLISH_RC"
    # A PRE-EXISTING DESTINATION REFUSES RATHER THAN OVERWRITING, which is the
    # whole reason the promotion links instead of renaming.
    publish_call "$root/staging" closure_publish_promote "$root/candidate.bin" "$root/staging"
    chk "step5/promote/pre-existing-destination-refuses" "1" "$PUBLISH_RC"
    chk "step5/promote/pre-existing-says-why" "yes" \
        "$(printf '%s' "$PUBLISH_OUT" | grep -q 'never overwritten' && echo yes || echo no)"
    # A GROUP-WRITABLE STAGING ROOT REFUSES BEFORE ANY COPY RUNS.
    mkdir -p -- "$root/loose" || true
    chmod 770 "$root/loose"
    publish_call "$root/loose" closure_publish_promote "$root/candidate.bin" "$root/loose"
    chk "step5/promote/group-writable-root-refuses" "1" "$PUBLISH_RC"
    chk "step5/promote/group-writable-copies-nothing" "" \
        "$(oneline "$(find "$root/loose" -type f 2>/dev/null)")"
    # A SYMLINKED STAGING ROOT IS REFUSED.
    ln -s "$root/staging" "$root/linked" 2>/dev/null || true
    publish_call "$root/linked" closure_publish_promote "$root/candidate.bin" "$root/linked"
    chk "step5/promote/symlinked-root-refuses" "1" "$PUBLISH_RC"

    # A destination directory (or a symlink to one) is still an EXISTING
    # destination, not permission for ln to create a link inside it.
    local promoted_digest=""
    promoted_digest=$(sha256sum < "$root/candidate.bin")
    promoted_digest="${promoted_digest%% *}"
    mkdir -p -- "$root/directory/$promoted_digest" "$root/symlink" "$root/other"
    chmod 700 "$root/directory" "$root/symlink"
    publish_call "$root/directory" closure_publish_promote \
        "$root/candidate.bin" "$root/directory"
    chk "step5/promote/directory-destination-refuses" "1" "$PUBLISH_RC"
    chk "step5/promote/directory-destination-untouched" "" \
        "$(oneline "$(find "$root/directory/$promoted_digest" -type f)")"
    ln -s "$root/other" "$root/symlink/$promoted_digest"
    publish_call "$root/symlink" closure_publish_promote \
        "$root/candidate.bin" "$root/symlink"
    chk "step5/promote/symlink-destination-refuses" "1" "$PUBLISH_RC"
    chk "step5/promote/symlink-target-untouched" "" \
        "$(oneline "$(find "$root/other" -type f)")"

    # A failed permission query is an unknown permission, never a protected root.
    step5_failed_permission_query() {
        find() { return 1; }
        closure_publish_promote "$1" "$2"
    }
    publish_call "$root/staging" step5_failed_permission_query \
        "$root/candidate.bin" "$root/staging"
    chk "step5/promote/permission-query-failure-refuses" "1" "$PUBLISH_RC"
    chk "step5/promote/permission-query-failure-reason" "yes" \
        "$(printf '%s' "$PUBLISH_OUT" | grep -q 'permissions could not be checked' && echo yes || echo no)"

    # THE PUBLICATION REPOSITORY IS BUILT HERE, before the cases that drive the
    # real entry point, because `closure_publish_main` resolves a configuration
    # from a commit and both the instance cases and the publication order cases
    # need one.
    cplxrepo="$dir/cplxrepo"
    commit=$(step5_make_publication_repo "$cplxrepo" "$src")
    if [ -z "$commit" ]; then
        unanswered "the step 5 publication and instance cases" \
          "  publication resolves from a cplx commit and this host supplies no git; install it or re-run where it is"
        return
    fi
    chk "step5/publication/repo-commit-is-a-sha" "40" "${#commit}"

    # --- the transactional handoff ---------------------------------------------
    #
    # A transaction is proved by its failure paths, so every case below asks the
    # stub WHAT IT HAS PUBLISHED rather than reading an exit status.
    section "step 5 handoff: four operations, and nothing public on any failure"
    # shellcheck disable=SC2034  # the staging root and the descriptor are read by
    # the production module sourced inside the subshell: the descriptor by the
    # `cat <&` that is the whole point of the handoff.
    step5_handoff() {
        local mode="$1" expected="$2" name="$3"
        stub="$dir/stub.$name"
        rm -rf -- "$stub"
        mkdir -p -- "$stub/staging" || return
        chmod 700 "$stub/staging"
        adapter="$stub/adapter.sh"
        step5_write_adapter "$adapter" "$stub" "$mode"
        printf 'the archive bytes\n' > "$stub/archive.bin"
        # EVERY HANDOFF CASE IS BOUNDED, not only the two that plant a failing
        # command on PATH. Round 4 of the review found this helper running
        # unbounded while the round's own assessment claimed each case was
        # `timeout -k` bounded with scratch postconditions, which was wrong about
        # the cases that go through here. A liveness claim is only as good as its
        # weakest runner, so the bound belongs in the shared helper.
        # shellcheck disable=SC2016  # the body belongs to the bounded child shell
        HANDOFF_OUT=$(timeout -k 5 20 "${BASH:-bash}" -c '
            set +u
            . "$1"
            . "$2"
            CLOSURE_PUBLISH_STAGING="$3"
            exec {CPLX_CLOSURE_ARCHIVE_FD}< "$4"
            closure_publish_upload "$5"
        ' _ "$publish" "$adapter" "$stub/staging" "$stub/archive.bin" "$expected" 2>&1)
        HANDOFF_RC=$?
    }

    # THE POSTCONDITIONS EVERY FAILING CASE OWES, asserted per case rather than
    # once at the end. Checking scratch only after the last fixture says nothing
    # about the ones before it, which is the second half of the same finding.
    step5_handoff_refused() {
        local name="$1" aborts="$2"
        chk "step5/handoff/$name-refuses-promptly" "1" "$HANDOFF_RC"
        chk "step5/handoff/$name-publishes-nothing" "0" "$(step5_public_count "$stub")"
        chk "step5/handoff/$name-aborts-expected-times" "$aborts" "$(step5_abort_count "$stub")"
        chk "step5/handoff/$name-removes-scratch" "" \
            "$(oneline "$(find "$stub/staging" -maxdepth 1 -name '.pub.*' -type d 2>/dev/null)")"
    }
    local want="" got=""
    want=$(printf 'the archive bytes\n' | sha256sum); want="${want%% *}"
    # The happy path: the stub accepts, hashes and streams one read, and commits.
    step5_handoff ok "$want" commits
    chk "step5/handoff/commit-succeeds" "0" "$HANDOFF_RC"
    chk "step5/handoff/one-object-is-public" "1" "$(step5_public_count "$stub")"
    chk "step5/handoff/no-abort-on-success" "0" "$(step5_abort_count "$stub")"
    # A WRONG EXPECTED DIGEST ABORTS AND NOTHING IS PUBLIC.
    step5_handoff ok "0000000000000000000000000000000000000000000000000000000000000000" mismatch
    step5_handoff_refused digest-mismatch 1
    # `upload_write` FAILING is carried out of the pipeline rather than hidden by
    # the last stage's status, which is what `pipefail` is in the flow for.
    step5_handoff write-fails "$want" writefails
    step5_handoff_refused write-failure 1
    # A COMMIT FAILURE leaves nothing public, because the committed flag is still
    # 0 when the trap runs.
    step5_handoff commit-fails "$want" commitfails
    step5_handoff_refused commit-failure 1
    # AN `upload_begin` FAILURE stages nothing, and NO ABORT IS ATTEMPTED,
    # because no stage exists to abort.
    step5_handoff begin-fails "$want" beginfails
    step5_handoff_refused begin-failure 0
    # AN ABORT FAILURE still refuses, and names the stage on stderr so an
    # operator can find what may persist. Its scratch postcondition is the same
    # as the others: a failing abort does not excuse a retained scratch.
    step5_handoff abort-fails "0000000000000000000000000000000000000000000000000000000000000000" abortfails
    step5_handoff_refused abort-failure 1
    chk "step5/handoff/abort-failure-names-the-stage" "yes" \
        "$(printf '%s' "$HANDOFF_OUT" | grep -q 'may persist' && echo yes || echo no)"

    # A WRITER THAT NEVER ARRIVES MUST NOT HANG THE RUN, which is a LIVENESS
    # claim and needs a bounded case to be one. The hasher blocks in its own
    # open until something opens the FIFO for writing, so a `tee` that fails
    # immediately used to leave this process waiting for a writer that would
    # never exist. The assertion is that the run ENDS, and `timeout` reporting
    # 124 is what failure looks like here.
    stub="$dir/stub.teefails"
    rm -rf -- "$stub"
    mkdir -p -- "$stub/staging" "$stub/fakebin" || true
    chmod 700 "$stub/staging"
    adapter="$stub/adapter.sh"
    step5_write_adapter "$adapter" "$stub" ok
    printf 'the archive bytes\n' > "$stub/archive.bin"
    printf '#!/bin/bash\nexit 1\n' > "$stub/fakebin/tee"
    chmod +x "$stub/fakebin/tee"
    if ! command -v timeout >/dev/null 2>&1; then
        fail "step5/handoff/bounded-runner" "timeout is required for the liveness case"
        return
    fi
    # shellcheck disable=SC2016  # the body belongs to the bounded child shell:
    # its `$1`..`$5` are the arguments passed after `_`, and expanding them here
    # would bake this harness's values into the process being measured.
    timeout -k 1 20 "${BASH:-bash}" -c '
        set +u
        . "$1"
        . "$2"
        PATH="$3:$PATH"
        CLOSURE_PUBLISH_STAGING="$4"
        exec {CPLX_CLOSURE_ARCHIVE_FD}< "$5"
        closure_publish_upload 0000000000000000000000000000000000000000000000000000000000000000
    ' _ "$publish" "$adapter" "$stub/fakebin" "$stub/staging" "$stub/archive.bin" \
        > /dev/null 2>&1
    rc=$?
    chk "step5/handoff/writer-never-arrives-refuses-promptly" "1" "$rc"
    chk "step5/handoff/writer-never-arrives-aborts-once" "1" "$(step5_abort_count "$stub")"
    chk "step5/handoff/writer-never-arrives-removes-scratch" "" \
        "$(oneline "$(find "$stub/staging" -maxdepth 1 -name '.pub.*' -type d 2>/dev/null)")"
    chk "step5/handoff/writer-never-arrives-publishes-nothing" "0" "$(step5_public_count "$stub")"

    # THE DESCRIPTOR BINDS THE CHECKS AND THE UPLOAD TO ONE INODE. The promoted
    # name is inside a directory this account owns, so it can be unlinked and
    # replaced after promotion; what must not change is what an already-open
    # descriptor reads. This is the property that makes checked bytes and
    # uploaded bytes the same file rather than the same path.
    root="$dir/instance"
    mkdir -p -- "$root/staging" || true
    chmod 700 "$root/staging"
    printf 'the original archive bytes\n' > "$root/candidate.bin"
    want=$(sha256sum < "$root/candidate.bin"); want="${want%% *}"
    # shellcheck disable=SC2034,SC2016  # the staging root is read by the
    # production module sourced inside the subshell, and the single-quoted body
    # of the bounded child above belongs to that child rather than to this file.
    got=$( ( set +u
        # shellcheck source=/dev/null
        . "$publish"
        CLOSURE_PUBLISH_STAGING="$root/staging"
        closure_publish_promote "$root/candidate.bin" "$root/staging" >/dev/null 2>&1 || exit 1
        exec {fd}< "$CLOSURE_PUBLISH_PROMOTED"
        # The name is replaced AFTER the open, which is exactly the window the
        # pathname-based version left open between checking and uploading.
        rm -f -- "$CLOSURE_PUBLISH_PROMOTED"
        printf 'entirely different bytes\n' > "$CLOSURE_PUBLISH_PROMOTED"
        sha256sum < "/dev/fd/$fd" ) 2>/dev/null )
    got="${got%% *}"
    chk "step5/instance/open-descriptor-survives-replacement" "$want" "$got"

    # AND AN IN-PLACE WRITE IS CAUGHT, which the descriptor alone does not stop.
    # `/dev/fd/N` returns to the same INODE rather than to a frozen copy, so an
    # A-to-B-to-A sequence could let the checks read B while the upload hashed A.
    # The snapshot the checks run against is refused unless it hashes to the
    # identity, so the two halves are bound to one value rather than to one path.
    # IT DRIVES `closure_publish_main`, AND THAT IS THE POINT OF THE CASE. An
    # earlier version recreated the snapshot copy and the comparison inside the
    # harness, so it asserted that the harness could compute a digest: deleting
    # the production guard would have left it passing. A regression case that
    # survives the removal of the thing it guards is not a regression case.
    #
    # The mutation is injected where the production code reads, by putting a
    # `cat` earlier on PATH that appends a byte. Promotion hashes the completed
    # copy, so the identity is the digest of what promotion captured; the
    # snapshot read then goes through the stub again and yields different bytes,
    # which is an in-place change from the guard's point of view. WITHOUT the
    # guard the run proceeds into step 1 on bytes the identity does not describe,
    # and the last assertion below is what fails in that case.
    root="$dir/inplace"
    rm -rf -- "$root"
    mkdir -p -- "$root/staging" "$root/results" "$root/fakebin" || true
    chmod 700 "$root/staging"
    printf 'the original archive bytes\n' > "$root/candidate.bin"
    # shellcheck disable=SC2016  # `$real` and `$@` belong to the stub being
    # written, not to this harness: expanding them here would bake this file's
    # values into a script the production code is about to invoke.
    { printf '#!/bin/bash\n'
      printf 'real=/bin/cat\n'
      printf '"$real" "$@"\n'
      printf 'printf %s\n' "'x'"; } > "$root/fakebin/cat"
    chmod +x "$root/fakebin/cat"
    # shellcheck disable=SC2031  # scoped to this command on purpose: the stub
    # applies to the run under test and to nothing else.
    out=$(PATH="$root/fakebin:$PATH" timeout 60 bash "$publish" \
        --archive "$root/candidate.bin" --commit "$commit" --repo "$cplxrepo" \
        --results "$root/results" --staging-root "$root/staging" 2>&1); rc=$?
    chk "step5/instance/in-place-write-refuses" "1" "$rc"
    chk "step5/instance/in-place-write-refused-at-step-0" "yes" \
        "$(printf '%s' "$out" | grep -q 'REFUSED at step 0' && echo yes || echo no)"
    # THE DIAGNOSTIC NAMES THE CHANGE, which is what distinguishes this refusal
    # from every other step 0 refusal and is what would stop being printed if the
    # guard were removed.
    chk "step5/instance/in-place-write-names-the-change" "yes" \
        "$(printf '%s' "$out" | grep -q 'changed under its own identity' && echo yes || echo no)"

    # DESCRIPTOR VERSUS PATHNAME, PROVED BY WHAT WAS PUBLISHED. Hashing
    # `/dev/fd/N` in the harness shows that a descriptor survives replacement; it
    # cannot show that the PRODUCTION UPLOADER reads that descriptor rather than
    # reopening the promoted name. Only the bytes the stub received can say that,
    # so this case replaces the name after the open and then compares what the
    # uploader made public against the ORIGINAL content.
    stub="$dir/stub.replaced"
    rm -rf -- "$stub"
    mkdir -p -- "$stub/staging" || true
    chmod 700 "$stub/staging"
    adapter="$stub/adapter.sh"
    step5_write_adapter "$adapter" "$stub" ok
    printf 'the original archive bytes\n' > "$stub/archive.bin"
    want=$(sha256sum < "$stub/archive.bin"); want="${want%% *}"
    # shellcheck disable=SC2016  # the body belongs to the bounded child shell
    HANDOFF_OUT=$(timeout -k 5 20 "${BASH:-bash}" -c '
        set +u
        . "$1"
        . "$2"
        CLOSURE_PUBLISH_STAGING="$3"
        closure_publish_promote "$4" "$3" >/dev/null 2>&1 || exit 1
        exec {CPLX_CLOSURE_ARCHIVE_FD}< "$CLOSURE_PUBLISH_PROMOTED"
        rm -f -- "$CLOSURE_PUBLISH_PROMOTED"
        printf "an entirely different archive\n" > "$CLOSURE_PUBLISH_PROMOTED"
        closure_publish_upload "$5"
    ' _ "$publish" "$adapter" "$stub/staging" "$stub/archive.bin" "$want" 2>&1)
    HANDOFF_RC=$?
    chk "step5/instance/upload-after-replacement-succeeds" "0" "$HANDOFF_RC"
    chk "step5/instance/published-bytes-are-the-original" "$want" \
        "$(sha256sum < "$stub/public/object" 2>/dev/null | cut -d' ' -f1)"
    # AND THE REPLACEMENT IS REALLY THERE, so the case cannot pass because the
    # replacement silently failed to happen.
    chk "step5/instance/the-name-really-was-replaced" "yes" \
        "$( [ "$(find "$stub/staging" -maxdepth 1 -type f ! -name '.*' -exec sha256sum {} + 2>/dev/null | cut -d' ' -f1 | grep -c "^$want$" || true)" = "0" ] && echo yes || echo no )"

    # A `cat` FAILURE IS THE TWIN OF THE `tee` ONE, and it is a separate case
    # because `pipefail` is what makes either visible: without it the captured
    # status carries only the last stage of the pipeline.
    stub="$dir/stub.catfails"
    rm -rf -- "$stub"
    mkdir -p -- "$stub/staging" "$stub/fakebin" || true
    chmod 700 "$stub/staging"
    adapter="$stub/adapter.sh"
    step5_write_adapter "$adapter" "$stub" ok
    printf 'the archive bytes\n' > "$stub/archive.bin"
    printf '#!/bin/bash\nexit 1\n' > "$stub/fakebin/cat"
    chmod +x "$stub/fakebin/cat"
    # THE FAILING STAGE IS ISOLATED. The stub adapter writes with `dd`, so a
    # `cat` that fails takes down the pipeline's FIRST stage and nothing else;
    # an adapter that also used `cat` would have failed two stages at once and
    # the case could not say which one it measured.
    #
    # THE EXPECTED DIGEST IS THE REAL ONE, so the refusal cannot come from a
    # mismatch this case planted rather than from the failure it is about.
    want=$(sha256sum < "$stub/archive.bin"); want="${want%% *}"
    # shellcheck disable=SC2016  # the body belongs to the bounded child shell.
    timeout -k 5 20 "${BASH:-bash}" -c '
        set +u
        . "$1"
        . "$2"
        PATH="$3:$PATH"
        CLOSURE_PUBLISH_STAGING="$4"
        exec {CPLX_CLOSURE_ARCHIVE_FD}< "$5"
        closure_publish_upload "$6"
    ' _ "$publish" "$adapter" "$stub/fakebin" "$stub/staging" "$stub/archive.bin" "$want" \
        > /dev/null 2>&1
    rc=$?
    chk "step5/handoff/cat-failure-refuses-promptly" "1" "$rc"
    chk "step5/handoff/cat-failure-aborts-once" "1" "$(step5_abort_count "$stub")"
    chk "step5/handoff/cat-failure-removes-scratch" "" \
        "$(oneline "$(find "$stub/staging" -maxdepth 1 -name '.pub.*' -type d 2>/dev/null)")"
    chk "step5/handoff/cat-failure-publishes-nothing" "0" "$(step5_public_count "$stub")"


    # ONE SHAPE, FIVE FAILURES. Each plants a failing stub for one command the
    # transaction depends on, earlier on PATH, and every case asserts the same
    # postconditions: the run ends within a bound, refuses, publishes nothing.
    # They differ in WHERE the failure lands, which is the whole point: preflight
    # refuses before a stage exists, and the later ones refuse after one does.
    # EACH CASE STATES ITS OWN LIFECYCLE, because termination and no public
    # object are the same answer for every failure and therefore distinguish
    # none of them. What differs is WHERE the failure lands: `chmod` runs before
    # `upload_begin`, so nothing is ever staged and nothing may be aborted;
    # everything after it owns a stage and must abort exactly once and leave no
    # scratch behind.
    step5_stub_failure() {
        local tool="$1" name="$2" begins="$3" aborts="$4" body="${5:-exit 1}"
        stub="$dir/stub.$name"
        rm -rf -- "$stub"
        mkdir -p -- "$stub/staging" "$stub/fakebin" || return
        chmod 700 "$stub/staging"
        adapter="$stub/adapter.sh"
        step5_write_adapter "$adapter" "$stub" ok
        printf 'the archive bytes\n' > "$stub/archive.bin"
        printf '#!/bin/bash\n%s\n' "$body" > "$stub/fakebin/$tool"
        chmod +x "$stub/fakebin/$tool"
        want=$(sha256sum < "$stub/archive.bin"); want="${want%% *}"
        # shellcheck disable=SC2016  # the body belongs to the bounded child shell
        HANDOFF_OUT=$(timeout -k 5 20 "${BASH:-bash}" -c '
            set +u
            . "$1"
            . "$2"
            PATH="$3:$PATH"
            CLOSURE_PUBLISH_STAGING="$4"
            exec {CPLX_CLOSURE_ARCHIVE_FD}< "$5"
            closure_publish_upload "$6"
        ' _ "$publish" "$adapter" "$stub/fakebin" "$stub/staging" "$stub/archive.bin" "$want" 2>&1)
        HANDOFF_RC=$?
        chk "step5/handoff/$name-terminates" "yes" \
            "$( [ "$HANDOFF_RC" -ne 124 ] && echo yes || echo no )"
        chk "step5/handoff/$name-refuses" "1" "$HANDOFF_RC"
        chk "step5/handoff/$name-publishes-nothing" "0" "$(step5_public_count "$stub")"
        chk "step5/handoff/$name-stages-as-expected" "$begins" "$(step5_begin_count "$stub")"
        chk "step5/handoff/$name-aborts-as-expected" "$aborts" "$(step5_abort_count "$stub")"
        chk "step5/handoff/$name-removes-scratch" "" \
            "$(oneline "$(find "$stub/staging" -maxdepth 1 -name '.pub.*' -type d 2>/dev/null)")"
    }

    # PREFLIGHT, AND THE PARTICIPANT IS ISOLATED. An earlier version pointed PATH
    # at a nonexistent directory, which removed `mktemp` along with the intended
    # participant: `mktemp -d` then failed before a stage existed and the case's
    # three assertions all passed WITHOUT the preflight loop being involved at
    # all. Removing every tool proves nothing about a loop that checks for one.
    #
    # So the fixture keeps every command the transaction needs and withholds
    # exactly one, `tee`, by building a directory of links to the real tools and
    # pointing PATH at it alone. The diagnostic naming that command is what
    # separates this from any other early failure.
    stub="$dir/stub.preflight"
    rm -rf -- "$stub"
    mkdir -p -- "$stub/staging" "$stub/onlybin" || true
    chmod 700 "$stub/staging"
    adapter="$stub/adapter.sh"
    step5_write_adapter "$adapter" "$stub" ok
    printf 'the archive bytes\n' > "$stub/archive.bin"
    for tool in cat mkfifo sha256sum mktemp chmod rm dd find ln; do
        tp=$(command -v "$tool" 2>/dev/null) || continue
        ln -s -- "$tp" "$stub/onlybin/$tool" 2>/dev/null || true
    done
    want=$(sha256sum < "$stub/archive.bin"); want="${want%% *}"
    # shellcheck disable=SC2016  # the body belongs to the bounded child shell
    HANDOFF_OUT=$(timeout -k 5 20 "${BASH:-bash}" -c '
        set +u
        . "$1"
        . "$2"
        PATH="$3"
        CLOSURE_PUBLISH_STAGING="$4"
        exec {CPLX_CLOSURE_ARCHIVE_FD}< "$5"
        closure_publish_upload "$6"
    ' _ "$publish" "$adapter" "$stub/onlybin" "$stub/staging" "$stub/archive.bin" "$want" 2>&1)
    HANDOFF_RC=$?
    chk "step5/handoff/preflight-refuses" "1" "$HANDOFF_RC"
    # THE DIAGNOSTIC NAMES THE MISSING COMMAND, which is the assertion that
    # cannot pass without the preflight loop: every other early failure refuses
    # for a different reason and says so.
    chk "step5/handoff/preflight-names-the-missing-command" "yes" \
        "$(printf '%s' "$HANDOFF_OUT" | grep -q 'the transaction needs tee' && echo yes || echo no)"
    chk "step5/handoff/preflight-stages-nothing" "0" "$(step5_begin_count "$stub")"
    chk "step5/handoff/preflight-leaves-no-scratch" "" \
        "$(oneline "$(find "$stub/staging" -maxdepth 1 -name '.pub.*' -type d 2>/dev/null)")"
    chk "step5/handoff/preflight-publishes-nothing" "0" "$(step5_public_count "$stub")"

    # SETUP AND PARTICIPANT FAILURES, each with the lifecycle its position
    # implies: `chmod` runs before `upload_begin`, the rest after it.
    step5_stub_failure chmod chmod-fails 0 0
    step5_stub_failure mkfifo mkfifo-fails 1 1
    # A HASHER THAT FAILS is not the same as one that hangs: this one exits, and
    # the comparison must still refuse rather than accept an absent digest.
    # THE STUB MUST DRAIN THE FIFO BEFORE FAILING, or it is not the case it
    # claims. A hasher that exits immediately never opens the FIFO for reading,
    # so `tee` fails on a pipe with no reader and the refusal comes from the
    # PIPELINE rather than from the hasher branch: the assertions pass and the
    # branch under test never runs. Reading stdin to the end first is what makes
    # the failure the hasher's own.
    # AND IT EMITS THE CORRECT DIGEST WHILE FAILING, which is the only way this
    # case tests what it names. Production checks the digest file for CONTENT
    # before it tests the awaited status, so a stub that drains and prints
    # nothing refuses through the empty-file branch and the status capture is
    # never consulted: the case would pass unchanged if `hash_rc` were ignored
    # entirely. Emitting the RIGHT digest removes every other reason to refuse
    # and leaves the awaited status as the only one.
    hashdigest=$(printf 'the archive bytes\n' | sha256sum); hashdigest="${hashdigest%% *}"
    step5_stub_failure sha256sum hasher-fails 1 1 \
        "cat > /dev/null; printf '%s  -\\n' $hashdigest; exit 1"
    # AN EMPTY DIGEST RESULT is checked for CONTENT before it is read, so the run
    # refuses rather than comparing an empty string to the identity.
    # THE SAME DRAIN, and then a clean exit that writes nothing: the digest file
    # exists and is EMPTY, which is the branch that checks for content before
    # reading rather than comparing an empty string to the identity.
    step5_stub_failure sha256sum empty-digest 1 1 'cat > /dev/null; exit 0'
    chk "step5/handoff/empty-digest-names-the-read-back" "yes" \
        "$(printf '%s' "$HANDOFF_OUT" | grep -q 'digest could not be read back' && echo yes || echo no)"
    # SCRATCH REMOVAL FAILING DOES NOT CHANGE THE VERDICT, and this case is
    # deliberately NOT run through the helper above, because the helper asserts a
    # refusal and a refusal is the wrong answer here. The design is explicit:
    # local cleanup is an operator concern and the publication verdict does not
    # depend on it, so a run whose only failure is `rm` COMMITS, stays exit 0,
    # leaves its object public, and names the retained path on stderr. Asserting
    # a refusal would have encoded the opposite rule.
    stub="$dir/stub.rmfails"
    rm -rf -- "$stub"
    mkdir -p -- "$stub/staging" "$stub/fakebin" || true
    chmod 700 "$stub/staging"
    adapter="$stub/adapter.sh"
    step5_write_adapter "$adapter" "$stub" ok
    printf 'the archive bytes\n' > "$stub/archive.bin"
    printf '#!/bin/bash\nexit 1\n' > "$stub/fakebin/rm"
    chmod +x "$stub/fakebin/rm"
    want=$(sha256sum < "$stub/archive.bin"); want="${want%% *}"
    # shellcheck disable=SC2016  # the body belongs to the bounded child shell
    HANDOFF_OUT=$(timeout -k 5 20 "${BASH:-bash}" -c '
        set +u
        . "$1"
        . "$2"
        PATH="$3:$PATH"
        CLOSURE_PUBLISH_STAGING="$4"
        exec {CPLX_CLOSURE_ARCHIVE_FD}< "$5"
        closure_publish_upload "$6"
    ' _ "$publish" "$adapter" "$stub/fakebin" "$stub/staging" "$stub/archive.bin" "$want" 2>&1)
    HANDOFF_RC=$?
    chk "step5/handoff/scratch-removal-failure-keeps-the-verdict" "0" "$HANDOFF_RC"
    chk "step5/handoff/scratch-removal-failure-still-published" "1" "$(step5_public_count "$stub")"
    chk "step5/handoff/scratch-removal-failure-names-the-path" "yes" \
        "$(printf '%s' "$HANDOFF_OUT" | grep -q 'NOT removed' && echo yes || echo no)"

    # A CANDIDATE PATHNAME OFFERED WHERE THE DESCRIPTOR BELONGS, and the oracle
    # is what the stub made PUBLIC rather than the exit status. The expected
    # digest handed in is the REAL digest of the file that pathname names, so an
    # implementation that quietly reopened the name would stream those bytes,
    # match the identity, commit, and leave one public object. "Nothing public
    # while the expected digest is correct" is therefore an assertion the
    # pathname-reopening version cannot pass, which "it refused" is not: every
    # refusal in this section shares that status.
    stub="$dir/stub.pathname"
    rm -rf -- "$stub"
    mkdir -p -- "$stub/staging" || true
    chmod 700 "$stub/staging"
    adapter="$stub/adapter.sh"
    step5_write_adapter "$adapter" "$stub" ok
    printf 'the archive bytes\n' > "$stub/archive.bin"
    want=$(sha256sum < "$stub/archive.bin"); want="${want%% *}"
    # shellcheck disable=SC2016  # the body belongs to the bounded child shell:
    # `$4` is the PATHNAME this case puts where a descriptor number belongs, and
    # the production module is what has to refuse it.
    HANDOFF_OUT=$(timeout -k 5 20 "${BASH:-bash}" -c '
        set +u
        . "$1"
        . "$2"
        CLOSURE_PUBLISH_STAGING="$3"
        CPLX_CLOSURE_ARCHIVE_FD="$4"
        closure_publish_upload "$5"
    ' _ "$publish" "$adapter" "$stub/staging" "$stub/archive.bin" "$want" 2>&1)
    HANDOFF_RC=$?
    chk "step5/handoff/pathname-terminates" "yes" \
        "$( [ "$HANDOFF_RC" -ne 124 ] && echo yes || echo no )"
    chk "step5/handoff/pathname-refuses" "1" "$HANDOFF_RC"
    chk "step5/handoff/pathname-publishes-nothing" "0" "$(step5_public_count "$stub")"
    chk "step5/handoff/pathname-stages-once" "1" "$(step5_begin_count "$stub")"
    chk "step5/handoff/pathname-aborts-once" "1" "$(step5_abort_count "$stub")"
    chk "step5/handoff/pathname-removes-scratch" "" \
        "$(oneline "$(find "$stub/staging" -maxdepth 1 -name '.pub.*' -type d 2>/dev/null)")"
    # AND THE REFUSAL IS THE TRANSACTION'S OWN, at step 4, rather than a shell
    # error that ended the run before a stage ever existed.
    chk "step5/handoff/pathname-refuses-at-step-4" "yes" \
        "$(printf '%s' "$HANDOFF_OUT" | grep -q 'REFUSED at step 4' && echo yes || echo no)"

    # THE CONTROL FOR IT: same fixture, same file, same expected digest, same
    # stub, and a REAL descriptor. It commits and publishes exactly those bytes.
    # Without this pair the refusal above could come from anything in the
    # fixture rather than from the substitution the case is named for.
    stub="$dir/stub.descriptor-control"
    rm -rf -- "$stub"
    mkdir -p -- "$stub/staging" || true
    chmod 700 "$stub/staging"
    adapter="$stub/adapter.sh"
    step5_write_adapter "$adapter" "$stub" ok
    printf 'the archive bytes\n' > "$stub/archive.bin"
    want=$(sha256sum < "$stub/archive.bin"); want="${want%% *}"
    # shellcheck disable=SC2016  # the body belongs to the bounded child shell
    HANDOFF_OUT=$(timeout -k 5 20 "${BASH:-bash}" -c '
        set +u
        . "$1"
        . "$2"
        CLOSURE_PUBLISH_STAGING="$3"
        exec {CPLX_CLOSURE_ARCHIVE_FD}< "$4"
        closure_publish_upload "$5"
    ' _ "$publish" "$adapter" "$stub/staging" "$stub/archive.bin" "$want" 2>&1)
    HANDOFF_RC=$?
    chk "step5/handoff/descriptor-control-commits" "0" "$HANDOFF_RC"
    chk "step5/handoff/descriptor-control-publishes-the-bytes" "$want" \
        "$(sha256sum < "$stub/public/object" 2>/dev/null | cut -d' ' -f1)"

    # --- a real signal, and the cleanup it cannot enter twice --------------------
    #
    # EVERY FAILURE PLANTED ABOVE IS A COMMAND EXITING NON-ZERO. A signal is a
    # different shape: it arrives asynchronously, it reaches `cat`, `tee` and the
    # uploader subshell as well as the shell that traps it, and the cleanup it
    # triggers can itself be interrupted. Nothing above measures any of that, so
    # the trap block and the single-entry cleanup were the only part of this
    # transaction with no case behind them.
    #
    # THE SIGNAL IS SYNCHRONISED WITH A PHASE, NOT WITH A CLOCK. The stub writes
    # a readiness file on ENTRY to the phase under test and then waits there, so
    # the signal is delivered while the run is demonstrably inside that phase. A
    # `sleep` in the harness would deliver it wherever the machine happened to
    # be, and the case would measure load rather than behaviour.
    #
    # THE SIGNAL GOES TO A PROCESS GROUP, which is what Ctrl-C does and is the
    # only delivery that reaches the pipeline as well as the shell that traps it.
    # Signalling the shell alone proves nothing here: bash defers a trap until
    # the foreground command completes, so the pipeline would run to the end and
    # the transaction would commit before the trap was ever consulted. `setsid`
    # gives the run its own process group, so the group IS the run: `timeout`
    # stays outside it and keeps its bound over a case that kills a group.
    section "step 5 signals: an interruption, and the cleanup it cannot enter twice"
    step5_signal_wait() {
        local marker="$1" i=0
        while [ ! -e "$marker" ] && [ "$i" -lt 300 ]; do sleep 0.1; i=$((i + 1)); done
        [ -e "$marker" ]
    }
    # One runner for both interruption cases. It records the phase it reached,
    # because "the signal was delivered somewhere" and "the signal was delivered
    # in the stream" are different claims and only the second one is the case.
    step5_signal_run() {
        local name="$1" mode="$2" expected="$3" marker="$4" release="$5"
        local pid="" i=0
        stub="$dir/stub.$name"
        rm -rf -- "$stub"
        mkdir -p -- "$stub/staging" || return
        chmod 700 "$stub/staging"
        adapter="$stub/adapter.sh"
        step5_write_adapter "$adapter" "$stub" "$mode"
        printf 'the archive bytes\n' > "$stub/archive.bin"
        if [ "$expected" = real ]; then
            expected=$(sha256sum < "$stub/archive.bin"); expected="${expected%% *}"
        fi
        # shellcheck disable=SC2016  # the body belongs to the bounded child
        # shell. `$$` is ITS pid, and `setsid` has made that pid its own process
        # group, which is the value this case signals.
        timeout -k 5 30 setsid --wait "${BASH:-bash}" -c '
            set +u
            . "$1"
            . "$2"
            CLOSURE_PUBLISH_STAGING="$3"
            printf "%s\n" "$$" > "$6"
            exec {CPLX_CLOSURE_ARCHIVE_FD}< "$4"
            closure_publish_upload "$5"
        ' _ "$publish" "$adapter" "$stub/staging" "$stub/archive.bin" "$expected" \
            "$stub/child.pid" > "$stub/out.log" 2>&1 &
        SIGNAL_RUNNER=$!
        if step5_signal_wait "$stub/$marker"; then
            SIGNAL_PHASE=reached
            pid=$(cat "$stub/child.pid" 2>/dev/null)
            kill -INT -"$pid" 2>/dev/null || true
            while kill -0 "$pid" 2>/dev/null && [ "$i" -lt 30 ]; do
                sleep 0.1; i=$((i + 1))
            done
        else
            SIGNAL_PHASE=missed
        fi
        # THE RELEASE IS A SAFETY VALVE AND NOT A TIMING ASSUMPTION. The phase
        # was reached by observation and the signal has already been sent; this
        # only guarantees that a run the signal FAILED to end still finishes and
        # fails loudly rather than sitting on the bound. On a passing run the
        # process is gone before it is written, so it decides nothing.
        : > "$stub/$release"
        wait "$SIGNAL_RUNNER"; SIGNAL_RC=$?
    }

    if ! command -v setsid >/dev/null 2>&1; then
        fail "step5/signal/group-runner" "setsid is required for the two interruption cases"
    else
        # AN INTERRUPTION DURING THE STREAM. The stub announces that
        # `upload_write` has been entered and holds the pipeline open there, so
        # the group signal lands with bytes in flight rather than before or
        # after. The trap converts it into `exit 130`, the EXIT trap aborts the
        # one stage that exists, and nothing is public.
        step5_signal_run stream-interrupted stream-waits real \
            streaming.ready stream.release
        chk "step5/signal/stream-reaches-the-stream" "reached" "$SIGNAL_PHASE"
        chk "step5/signal/stream-terminates" "yes" \
            "$( [ "$SIGNAL_RC" -ne 124 ] && echo yes || echo no )"
        chk "step5/signal/stream-exits-130" "130" "$SIGNAL_RC"
        chk "step5/signal/stream-publishes-nothing" "0" "$(step5_public_count "$stub")"
        chk "step5/signal/stream-had-a-stage-to-abort" "1" "$(step5_begin_count "$stub")"
        chk "step5/signal/stream-aborts-exactly-once" "1" "$(step5_abort_count "$stub")"
        chk "step5/signal/stream-removes-scratch" "" \
            "$(oneline "$(find "$stub/staging" -maxdepth 1 -name '.pub.*' -type d 2>/dev/null)")"

        # A SIGNAL DURING CLEANUP. A wrong expected digest refuses at step 4, the
        # EXIT trap enters `closure_publish_cleanup`, and the stub announces that
        # `upload_abort` has been entered and waits there. The group signal
        # arrives inside that abort.
        #
        # THE ORACLE IS THE ABORT COUNT AND NOT THE EXIT STATUS, which is the
        # plan's own wording for this case: cleanup resets EXIT, INT, TERM and
        # HUP on entry, so the second signal ends the process, and every failure
        # in this section already shares a status. What distinguishes a
        # single-entry cleanup from a re-entrant one is that `upload_abort` was
        # entered ONCE, and the stub appends its count before it waits so a
        # second entry would be visible even though the first never returns.
        #
        # THE SCRATCH IS ASSERTED PRESENT HERE, and that is the honest statement
        # of its lifetime on this one path rather than an exception carved out
        # for convenience: the process was killed inside the abort, so the
        # removal that follows the abort never ran. The stage object the stub
        # was told to destroy is still there for the same reason, and that is
        # what proves the signal landed in the cleanup rather than beside it.
        step5_signal_run cleanup-interrupted abort-waits \
            0000000000000000000000000000000000000000000000000000000000000000 \
            aborting.ready abort.release
        chk "step5/signal/cleanup-reaches-the-abort" "reached" "$SIGNAL_PHASE"
        chk "step5/signal/cleanup-terminates" "yes" \
            "$( [ "$SIGNAL_RC" -ne 124 ] && echo yes || echo no )"
        chk "step5/signal/cleanup-refused-before-the-abort" "yes" \
            "$(grep -q 'REFUSED at step 4' "$stub/out.log" && echo yes || echo no)"
        chk "step5/signal/cleanup-aborts-exactly-once" "1" "$(step5_abort_count "$stub")"
        chk "step5/signal/cleanup-publishes-nothing" "0" "$(step5_public_count "$stub")"
        chk "step5/signal/cleanup-ended-inside-the-abort" "yes" \
            "$( [ -e "$stub/stage/object" ] && echo yes || echo no )"
        chk "step5/signal/cleanup-keeps-the-scratch-it-died-in" "yes" \
            "$( [ -n "$(find "$stub/staging" -maxdepth 1 -name '.pub.*' -type d 2>/dev/null)" ] \
                && echo yes || echo no )"
        note "step5/signal/cleanup-status" "$SIGNAL_RC"
    fi
    # --- publication as an ORDER ------------------------------------------------
    #
    # PUBLICATION KEEPS ITS REPOSITORY, and the contrast with the gate above is
    # the point rather than an inconsistency. The topology puts `closure_publish.sh`
    # in cplx only: it runs where the repository is, so resolving a configuration
    # out of a commit is something it can actually do. Packaging runs on an
    # account that has no repository, which is why the gate above stages from a
    # deployed tree. One effort, two sides of that line, and only packaging was
    # ever on the wrong one.
    section "step 5 publication: the order is the assertion, not the set"
    root="$dir/publication"
    mkdir -p -- "$root/staging" "$root/results" || true
    chmod 700 "$root/staging"
    # An archive whose bundle was stripped must fail at STEP 1, before the waiver
    # question is ever asked. The assertion is the step NUMBER in the refusal.
    mkdir -p -- "$root/tree/tools/closure" || true
    printf 'nothing useful\n' > "$root/tree/tools/placeholder"
    tar -czf "$root/stripped.tar.gz" -C "$root/tree" tools 2>/dev/null
    out=$(bash "$publish" --archive "$root/stripped.tar.gz" --commit "$commit" \
        --repo "$cplxrepo" --results "$root/results" --staging-root "$root/staging" 2>&1); rc=$?
    chk "step5/publication/stripped-bundle-refuses" "1" "$rc"
    chk "step5/publication/stripped-fails-at-step-1" "yes" \
        "$(printf '%s' "$out" | grep -q 'REFUSED at step 1' && echo yes || echo no)"
    chk "step5/publication/stripped-never-reaches-the-waiver-question" "yes" \
        "$(printf '%s' "$out" | grep -q 'REFUSED at step 4' && echo no || echo yes)"
    # AN ARCHIVE WHOSE COMPARISON NEVER RAN is refused at step 2, and the
    # refusal names the identity publication computed rather than one it read.
    rm -rf -- "$root/tree"
    mkdir -p -- "$root/tree/tools/closure" || true
    cp -- "$cplxrepo/src/setups/env/closure/closure-config.txt" "$root/tree/tools/closure/closure-config.txt"
    step2_write_envelope "$root/tree/tools/closure/closure-envelope.txt" \
        "$(config_digest "$root/tree/tools/closure/closure-config.txt")" \
        "src/setups/env/closure/closure-config.txt" "$commit"
    tar -czf "$root/candidate.tar.gz" -C "$root/tree" tools 2>/dev/null
    out=$(bash "$publish" --archive "$root/candidate.tar.gz" --commit "$commit" \
        --repo "$cplxrepo" --results "$root/results" --staging-root "$root/staging" 2>&1); rc=$?
    chk "step5/publication/no-comparison-refuses" "1" "$rc"
    chk "step5/publication/no-comparison-fails-at-step-2" "yes" \
        "$(printf '%s' "$out" | grep -q 'REFUSED at step 2' && echo yes || echo no)"
    chk "step5/publication/step-2-names-the-computed-identity" "yes" \
        "$(printf '%s' "$out" | grep -q 'keyed to archive identity' && echo yes || echo no)"

    # Keeping the envelope while stripping or changing its document must fail
    # at step 1 too. A valid envelope alone proves nothing about carried bytes.
    printf '\n# changed after the envelope was written\n' \
        >> "$root/tree/tools/closure/closure-config.txt"
    tar -czf "$root/changed-config.tar.gz" -C "$root/tree" tools
    out=$(bash "$publish" --archive "$root/changed-config.tar.gz" --commit "$commit" \
        --repo "$cplxrepo" --results "$root/results" --staging-root "$root/staging" 2>&1); rc=$?
    chk "step5/publication/changed-config-refuses" "1" "$rc"
    chk "step5/publication/changed-config-fails-at-step-1" "yes" \
        "$(printf '%s' "$out" | grep -q 'REFUSED at step 1' && echo yes || echo no)"
    rm -f -- "$root/tree/tools/closure/closure-config.txt"
    tar -czf "$root/missing-config.tar.gz" -C "$root/tree" tools
    out=$(bash "$publish" --archive "$root/missing-config.tar.gz" --commit "$commit" \
        --repo "$cplxrepo" --results "$root/results" --staging-root "$root/staging" 2>&1); rc=$?
    chk "step5/publication/missing-config-refuses" "1" "$rc"
    chk "step5/publication/missing-config-fails-at-step-1" "yes" \
        "$(printf '%s' "$out" | grep -q 'REFUSED at step 1' && echo yes || echo no)"

    # Isolate the final adapter gate: even after all checks pass, absence of an
    # uploader cannot report a committed publication.
    # shellcheck disable=SC2034  # these fixture globals are read by the sourced publication entry point
    # THE IDENTITY MUST BE THE REAL DIGEST, or this case never reaches the branch
    # it names. A literal placeholder is rejected by the snapshot guard at step 0,
    # so both assertions below would pass while the missing-adapter path stayed
    # unexecuted: a refusal is not evidence of the refusal you meant.
    step5_missing_adapter() {
        local real=""
        real=$(sha256sum -- "$1"); real="${real%% *}"
        closure_publish_promote() {
            CLOSURE_PUBLISH_PROMOTED="$1"
            CLOSURE_PUBLISH_IDENTITY="$real"
        }
        closure_publish_step1() { CLOSURE_PUBLISH_CONFIG_DIGEST="checked-policy"; }
        closure_publish_step2() { return 0; }
        closure_publish_step34() { return 0; }
        closure_publish_main --archive "$1" --commit "$2" --repo "$3" \
            --results "$4" --staging-root "$5"
    }
    publish_call "$root/staging" step5_missing_adapter \
        "$root/candidate.tar.gz" "$commit" "$cplxrepo" "$root/results" "$root/staging"
    chk "step5/publication/no-adapter-refuses-after-checks" "1" "$PUBLISH_RC"
    # THE STEP NUMBER IS THE ASSERTION. Step 4 is the missing-adapter branch, and
    # naming it is what distinguishes this from the step 0 refusal the previous
    # version of this case was actually measuring.
    chk "step5/publication/no-adapter-refuses-at-step-4" "yes" \
        "$(printf '%s' "$PUBLISH_OUT" | grep -q 'REFUSED at step 4' && echo yes || echo no)"
    chk "step5/publication/no-adapter-reached-the-adapter-gate" "yes" \
        "$(printf '%s' "$PUBLISH_OUT" | grep -q 'REFUSED at step 0' && echo no || echo yes)"
    chk "step5/publication/no-adapter-never-reports-success" "yes" \
        "$(printf '%s' "$PUBLISH_OUT" | grep -q 'CLOSURE PUBLICATION OK' && echo no || echo yes)"

    # --- the gate and the boundary, end to end --------------------------------
    #
    # THE TWO HALVES MEET HERE. Everything above tests the gate or publication
    # alone; this takes the archive the GATE actually produced, with an active
    # waiver carried through it, and hands it to publication. The claim the whole
    # step exists for is that such an archive is producible and NOT publishable,
    # and only this case can make it.
    section "step 5 end to end: a gated archive with an active waiver is refused"
    # THE CASE PRODUCES ITS OWN ARCHIVE rather than taking whichever one is
    # newest. Reading the last archive made this case depend on the order of
    # every fixture above it: a later case that packaged again silently changed
    # what was being published, and the refusal then came from somewhere other
    # than the waiver. The state is planted here and the gate is run here.
    # AND THE DEPLOYED DECLARATION IS RESTORED FIRST. The envelope-mismatch case
    # above tampers with it and then regenerates a matching envelope, which
    # leaves the deployed tree self-consistent but NOT what cplx holds. A gated
    # archive built from it is refused by publication at STEP 1, correctly and
    # for a reason that has nothing to do with waivers, and the case would be
    # measuring that instead of the boundary it names.
    cp -- "$src/../closure/closure-config.txt" "$repo/closure/closure-config.txt"
    cp -- "$src/../closure/closure-envelope.txt" "$repo/closure/closure-envelope.txt"
    rm -f -- "$home/tools/python/root/lib/libsqlite3.so.0"
    rm -rf -- "$home/tools/closure"
    HOME="$home" bash "$repo/bin/pkg.sh" tools --closure-gate > /dev/null 2>&1
    archive=$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f -newer "$home/tools/bin/closure_check.sh" 2>/dev/null | sort | tail -1)
    if [ -z "$archive" ]; then
        archive=$(find "$home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | sort | tail -1)
    fi
    if [ -z "$archive" ]; then
        fail "step5/e2e/archive-exists" "the gate produced no archive to publish"
    else
        root="$dir/e2e"
        rm -rf -- "$root"
        mkdir -p -- "$root/staging" "$root/results" || true
        chmod 700 "$root/staging"
        # The verification result publication requires at step 2, keyed to the
        # identity IT computes and naming the configuration IT resolved. Written
        # here because verification is step 6's subject, not this step's.
        id=$(sha256sum -- "$archive" | cut -d' ' -f1)
        cfg=$(config_digest "$cplxrepo/src/setups/env/closure/closure-config.txt")
        evidence_document "$root/results/$id" "$id" "$cfg"
        out=$(bash "$publish" --archive "$archive" --commit "$commit" \
            --repo "$cplxrepo" --results "$root/results" \
            --staging-root "$root/staging" 2>&1); rc=$?
        chk "step5/e2e/gated-archive-is-refused" "1" "$rc"
        # STEP 4 IS THE ASSERTION. Refusing earlier would mean the archive failed
        # for a reason that has nothing to do with the waiver, and the case would
        # be green while proving nothing about the boundary it names.
        chk "step5/e2e/refused-at-the-waiver-step" "yes" \
            "$(printf '%s' "$out" | grep -q 'REFUSED at step 4' && echo yes || echo no)"
        chk "step5/e2e/refusal-names-the-validation-artifact" "yes" \
            "$(printf '%s' "$out" | grep -q 'validation artifact' && echo yes || echo no)"
        chk "step5/e2e/no-mode-permits-it" "yes" \
            "$(printf '%s' "$out" | grep -q 'no mode or flag permits' && echo yes || echo no)"
    fi

    # A PUBLICATION THAT SUCCEEDS, through the real entry point and a stub
    # uploader. Every other publication case here is a refusal, and a boundary
    # that only ever refuses is indistinguishable from one that refuses
    # everything. This is the case that says the five steps can be satisfied.
    #
    # IT NEEDS A DECLARATION WITH NO WAIVER, because the committed one waives a
    # member: present, the waiver is stale and refuses; absent, it is active and
    # the archive is a validation artifact. Neither is a clean pass, so the
    # fixture commits a waiver-free declaration and the archive carries it.
    root="$dir/success"
    rm -rf -- "$root"
    mkdir -p -- "$root/staging" "$root/results" "$root/tree" || true
    chmod 700 "$root/staging"
    cleanrepo="$dir/cleanrepo"
    mkdir -p -- "$cleanrepo/src/setups/env/bin" "$cleanrepo/src/setups/env/closure" || true
    for module in "${CLOSURE_MODULES[@]}"; do
        cp -- "$src/$module" "$cleanrepo/src/setups/env/bin/$module"
    done
    cp -- "$src/install_pkg.sh" "$cleanrepo/src/setups/env/bin/install_pkg.sh"
    grep -v '^waiver|' "$src/../closure/closure-config.txt" \
        > "$cleanrepo/src/setups/env/closure/closure-config.txt"
    ( cd "$cleanrepo" || exit 1
      git init -q . >/dev/null 2>&1
      git config user.email harness@example.invalid
      git config user.name harness
      git add -A >/dev/null 2>&1
      git commit -q -m 'a declaration with no waiver' >/dev/null 2>&1 ) || true
    cleancommit=$(git -C "$cleanrepo" rev-parse HEAD 2>/dev/null)
    # The tree the archive carries: the same one the gate checked, with the
    # previously waived member present so nothing is absent and nothing is
    # excused.
    cp -r -- "$home/tools" "$root/tree/tools" 2>/dev/null
    printf 'not an ELF: present, so nothing needs waiving\n' \
        > "$root/tree/tools/python/root/lib/libsqlite3.so.0"
    rm -rf -- "$root/tree/tools/closure"
    mkdir -p -- "$root/tree/tools/closure" || true
    cp -- "$cleanrepo/src/setups/env/closure/closure-config.txt" \
        "$root/tree/tools/closure/closure-config.txt"
    step2_write_envelope "$root/tree/tools/closure/closure-envelope.txt" \
        "$(config_digest "$root/tree/tools/closure/closure-config.txt")" \
        "src/setups/env/closure/closure-config.txt" "$cleancommit"
    tar -czf "$root/candidate.tar.gz" -C "$root/tree" tools 2>/dev/null
    id=$(sha256sum -- "$root/candidate.tar.gz" | cut -d' ' -f1)
    cfg=$(config_digest "$cleanrepo/src/setups/env/closure/closure-config.txt")
    evidence_document "$root/results/$id" "$id" "$cfg"
    stub="$dir/stub.success"
    rm -rf -- "$stub"
    mkdir -p -- "$stub" || true
    adapter="$stub/adapter.sh"
    step5_write_adapter "$adapter" "$stub" ok
    out=$(timeout -k 5 120 bash "$publish" --archive "$root/candidate.tar.gz" \
        --commit "$cleancommit" --repo "$cleanrepo" --results "$root/results" \
        --staging-root "$root/staging" --adapter "$adapter" 2>&1)
    rc=$?
    chk "step5/e2e/clean-publication-succeeds" "0" "$rc"
    chk "step5/e2e/clean-publication-says-so" "yes" \
        "$(printf '%s' "$out" | grep -q 'CLOSURE PUBLICATION OK' && echo yes || echo no)"
    chk "step5/e2e/one-object-is-public" "1" "$(step5_public_count "$stub")"
    # THE PUBLIC BYTES ARE THE ARCHIVE'S, asserted by digest rather than by the
    # uploader's exit status. This is the property the whole descriptor and
    # snapshot machinery exists to deliver, and it is the only case that can
    # check it, because it is the only one that publishes anything.
    chk "step5/e2e/public-bytes-are-the-archive" "$id" \
        "$(sha256sum < "$stub/public/object" 2>/dev/null | cut -d' ' -f1)"
}
# ============================================================== the run, one step ===

# ============================================================== the step 6 suite ===
# THE FOREIGN-HOST HALF. Step 5 left publication's step 2 reading a record this
# harness wrote; step 6 supplies the producer, so the same gate is now driven by
# evidence a real run emitted rather than by a fixture that agreed with it.
#
# THE SUITE RUNS ANYWHERE AND ONLY THE DEBIAN AGENT ANSWERS IT. `step_host` gates
# step 6 to debian-12, so a run elsewhere records every case it can and still
# reports UNANSWERED with exit 5: the cases below are portable, and the OBLIGATION
# is not.

# The evidence document as a fixture, which is what publication's step 2 needs and
# what several cases below mutate one record of. It is the SMALLEST document the
# shared reader accepts, and its verdict is derived here the same way the reader
# derives it, so a fixture cannot assert a verdict its own records deny.
evidence_document() {
    local out="$1" id="$2" cfg="$3" post="${4:-present}" verdict=PASS
    if [ "$post" != "present" ]; then verdict=DIVERGENT; fi
    { printf 'CPLX-CLOSURE-EVIDENCE/1\n'
      printf 'archive|%s\n' "$id"
      printf 'config|%s\n' "$cfg"
      printf 'pre|%s|%s\n' 'tools/python/root/lib' present
      printf 'post|%s|%s\n' 'tools/python/root/lib' "$post"
      printf 'verdict|%s\n' "$verdict"; } > "$out"
}

# One call into the verification module, sourced rather than executed, which is
# the seam its main boundary exists for. The reader and the emitter are both
# driven this way so a case measures the function it names and not a whole run.
verify_call() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    VERIFY_OUT=$("${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        fn="$2"
        shift 2
        declare -F "$fn" >/dev/null 2>&1 || exit 92
        "$fn" "$@"
    ' _ "$SHIPPED_DIR/closure_verify.sh" "$@" 2>&1)
    VERIFY_RC=$?
}

# The parsed model, printed from the module's own globals for the same reason the
# configuration suite prints them: what a case asserts is what publication reads.
verify_model() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        closure_evidence_parse "$2" >/dev/null 2>&1 || exit 93
        printf "%s|%s|%s\n" "$CLOSURE_EVI_ARCHIVE" "$CLOSURE_EVI_CONFIG" "$CLOSURE_EVI_VERDICT"
    ' _ "$SHIPPED_DIR/closure_verify.sh" "$1" 2>/dev/null
}

# A fixture cplx checkout holding the eight authoritative scripts and the
# committed declaration, which is what the delivery script resolves from and what
# publication resolves its policy from. Prints the commit.
step6_make_repo() {
    local repo="$1" src="$2" name=""
    mkdir -p -- "$repo/src/setups/env/bin" "$repo/src/setups/env/closure" || return 1
    for name in "${CLOSURE_MODULES[@]}" closure_verify.sh closure_observe_live.sh \
                install_pkg.sh pkg.sh pkg_tools.sh; do
        cp -- "$src/$name" "$repo/src/setups/env/bin/$name" || return 1
    done
    cp -- "$src/../closure/closure-config.txt" \
        "$repo/src/setups/env/closure/closure-config.txt" || return 1
    cp -- "$src/../closure/closure-envelope.txt" \
        "$repo/src/setups/env/closure/closure-envelope.txt" || return 1
    ( cd "$repo" || exit 1
      git init -q . >/dev/null 2>&1 || exit 1
      git config user.email harness@example.invalid
      git config user.name harness
      git add -A >/dev/null 2>&1
      git commit -q -m 'the reviewed tools' >/dev/null 2>&1 ) || return 1
    git -C "$repo" rev-parse HEAD 2>/dev/null
}

# ONE PUBLICATION, ONE FRESH STAGING ROOT, and the reason is a property of the
# gate rather than tidiness. Publication promotes the candidate to a
# digest-derived name with a link that FAILS IF THE NAME EXISTS, which is its
# no-overwrite guarantee; a staging root reused across cases therefore makes the
# second publication of one archive refuse at STEP 0, and every case after it
# would be measuring that refusal instead of its own.
step6_publish() {
    local publish="$1" archive="$2" commit="$3" repo="$4" results="$5" stage="$6"
    rm -rf -- "$stage"
    mkdir -p -- "$stage" || return 1
    chmod 700 "$stage"
    bash "$publish" --archive "$archive" --commit "$commit" --repo "$repo" \
        --results "$results" --staging-root "$stage" 2>&1
}

# A process filesystem of the shape the observer reads: one numbered directory
# carrying `comm`, `cmdline` and `maps`. Planting it is what lets the
# empty-inventory refusal be asserted without arranging a process that must not
# exist, which is not something a test can arrange.
step6_plant_proc() {
    local root="$1" pid="$2" comm="$3" argv0="$4"
    shift 4
    local mapping=""
    mkdir -p -- "$root/$pid" || return 1
    printf '%s\n' "$comm" > "$root/$pid/comm"
    printf '%s\0-c\0pass\0' "$argv0" > "$root/$pid/cmdline"
    : > "$root/$pid/maps"
    for mapping in "$@"; do
        printf '55d0-55e0 r-xp 00000000 08:01 1 %s\n' "$mapping" >> "$root/$pid/maps"
    done
    printf '7ffd-7ffe rw-p 00000000 00:00 0 [stack]\n' >> "$root/$pid/maps"
    printf '7ffe-7fff r--p 00000000 00:00 0 \n' >> "$root/$pid/maps"
    return 0
}

# The declared root specifications, read from a configuration document by the
# module that owns the grammar. The comparison cases below measure both sides
# against the COMMITTED declaration rather than against a list this suite wrote,
# so a declaration change moves the fixture with it.
config_specs() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        closure_config_parse "$2" >/dev/null 2>&1 || exit 93
        closure_config_root_specs
    ' _ "$SHIPPED_DIR/closure_config.sh" "$1" 2>/dev/null
}

# One side of the comparison, through the driver's own function and the checker's
# own derivations. The child sources both, which is what `closure_verify_load`
# does in a real run: a side computed any other way would be this suite's
# arithmetic rather than the production answer.
verify_side() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        # shellcheck disable=SC1090
        source "$2" >/dev/null 2>&1 || exit 92
        shift 2
        closure_verify_side "$@"
    ' _ "$SHIPPED_DIR/closure_verify.sh" "$SHIPPED_DIR/closure_check.sh" "$@" 2>/dev/null
}

verify_verdict() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        closure_verify_verdict "$2" "$3"
    ' _ "$SHIPPED_DIR/closure_verify.sh" "$1" "$2" 2>/dev/null
}

# TWO EMITTERS, INTERLEAVED AT THE ONE POINT THAT MATTERS, and the schedule is
# the whole case rather than scenery. Round 6 of the step 6 review found the
# earlier attempt running them SEQUENTIALLY: the second call then saw a canonical
# name that was already there, which is the ordinary conflict and not the race.
# The race is a run that starts with NO canonical name and finds one when it
# links, and only a run that reaches its link late can be in it.
#
# The synchronisation point is `cat`, because that is what fills the temporary
# file: the shim lets the real copy finish, then runs a second REAL emitter to
# create the canonical result, and returns. The first emitter therefore arrives
# at its link with the name taken, exactly as a concurrent writer would leave it.
# The `mktemp` shim then fails conflict allocations attempted AFTER that write,
# which is the operation a store that reserves late must perform and a store that
# reserves first never reaches. That difference is what makes this a regression
# rather than a description.
#
# Prints four lines: the differing emitter's status, the number of retained files
# whose bytes ARE the differing document, and the two consumer statuses.
verify_interleave() {
    # shellcheck disable=SC2016  # the shims are the CHILD shell's own text
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        # shellcheck disable=SC1090
        source "$2" >/dev/null 2>&1 || exit 92
        root="$3"; identity="$4"; pass="$5"; divergent="$6"; mode="$7"
        CLOSURE_PUBLISH_IDENTITY="$identity"
        CLOSURE_PUBLISH_CONFIG_DIGEST="$8"
        after_write=no
        cat() {
            command cat "$@" || return $?
            after_write=yes
            if [ ! -e "$root/$identity" ]; then
                ( unset -f cat mktemp; closure_evidence_emit "$root" "$identity" "$pass" ) >&2
            fi
        }
        if [ "$mode" = inject ]; then
            mktemp() {
                case "${*: -1}" in
                    *.conflict.*) if [ "$after_write" = yes ]; then return 1; fi ;;
                esac
                command mktemp "$@"
            }
        fi
        closure_evidence_emit "$root" "$identity" "$divergent" >/dev/null 2>&1
        printf "differing_emit_rc=%s\n" "$?"
        unset -f cat mktemp
        retained=0
        while IFS= read -r path; do
            if [ "$(sha256sum -- "$path" | sed -e "s/ .*$//")" \
               = "$(sha256sum -- "$divergent" | sed -e "s/ .*$//")" ]; then
                retained=$((retained + 1))
            fi
        done < <(find "$root" -maxdepth 1 -type f)
        printf "exact_differing_copies=%s\n" "$retained"
        closure_publish_step2 unused "$root" >/dev/null 2>&1
        printf "publication_step2_rc=%s\n" "$?"
        closure_evidence_emit "$root" "$identity" "$pass" >/dev/null 2>&1
        printf "agreeing_rerun_rc=%s\n" "$?"
    ' _ "$SHIPPED_DIR/closure_verify.sh" "$SHIPPED_DIR/closure_publish.sh" "$@" 2>/dev/null
}

verify_payload() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        closure_verify_payload "$2" "$3" "$4"
    ' _ "$SHIPPED_DIR/closure_verify.sh" "$1" "$2" "$3" 2>/dev/null
}

step6_suite() {
    local dir="$SCRATCH/step6"
    local src="$SHIPPED_DIR"
    local verify="$SHIPPED_DIR/closure_verify.sh"
    local observe="$SHIPPED_DIR/closure_observe_live.sh"
    local deliver="$CI_DIR/deliver-closure-tools.sh"
    local publish="$SHIPPED_DIR/closure_publish.sh"
    local repo="" commit="" id="" cfg="" out="" rc=0 root="" ws="" name=""
    local d1="" d2="" blob=""
    local step6_specs=() side_a="" side_b="" side_c=""
    local e2e_out="" e2e_rc=0 e2e_pub=""

    rm -rf -- "$dir"
    mkdir -p -- "$dir" || return

    # --- the third grammar table ------------------------------------------------
    #
    # THE READER IS THE CONTRACT, and these cases are the contract's own tests. A
    # document publication accepts is one this reader accepted, so every refusal
    # below is a refusal publication inherits without a line of its own.
    section "step 6 evidence grammar: a machine writes it, so it refuses what a person would leave"
    cfg=$(config_digest "$src/../closure/closure-config.txt")
    id=$(printf 'a candidate archive\n' | sha256sum); id="${id%% *}"

    evidence_document "$dir/good.txt" "$id" "$cfg"
    verify_call closure_evidence_parse "$dir/good.txt"
    chk "step6/grammar/well-formed-parses" "0" "$VERIFY_RC"
    chk "step6/grammar/model-carries-both-identities-and-the-verdict" "$id|$cfg|PASS" \
        "$(verify_model "$dir/good.txt")"

    # A DOCUMENT THAT ASSERTS WHAT ITS RECORDS DENY. This is the case the derived
    # verdict exists for: an emitter cannot claim PASS over a divergent pair, and
    # publication never has to check the pair itself.
    evidence_document "$dir/lie.txt" "$id" "$cfg" absent
    sed -e 's/^verdict|DIVERGENT$/verdict|PASS/' "$dir/lie.txt" > "$dir/lie2.txt"
    verify_call closure_evidence_parse "$dir/lie2.txt"
    chk "step6/grammar/asserted-pass-over-a-divergence-refuses" "1" "$VERIFY_RC"
    chk "step6/grammar/refusal-names-the-derivation" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'asserts PASS and its own records derive DIVERGENT' && echo yes || echo no)"
    # And the honest DIVERGENT document parses, so the refusal above is about the
    # contradiction rather than about divergence being unrepresentable.
    verify_call closure_evidence_parse "$dir/lie.txt"
    chk "step6/grammar/honest-divergence-parses" "0" "$VERIFY_RC"

    # AN UNEXPECTED RECORD ALSO FORCES A NON-PASS, which is the second half of the
    # derivation and the one a pair-only comparison would have missed.
    evidence_document "$dir/unexp.txt" "$id" "$cfg"
    printf 'unexpected|%s|%s\n' post 'tools/old/py3.13' >> "$dir/unexp.txt"
    verify_call closure_evidence_parse "$dir/unexp.txt"
    chk "step6/grammar/unexpected-under-a-pass-refuses" "1" "$VERIFY_RC"
    sed -e 's/^verdict|PASS$/verdict|DIVERGENT/' "$dir/unexp.txt" > "$dir/unexp2.txt"
    verify_call closure_evidence_parse "$dir/unexp2.txt"
    chk "step6/grammar/unexpected-under-a-divergent-parses" "0" "$VERIFY_RC"

    # THE TWO LINES THE OTHER GRAMMARS IGNORE. A person edits a configuration and
    # an envelope; only a machine writes this one, and one observation must have
    # exactly one byte sequence.
    { printf 'CPLX-CLOSURE-EVIDENCE/1\n'; printf '\n'; } > "$dir/blank.txt"
    sed -e '1d' "$dir/good.txt" >> "$dir/blank.txt"
    verify_call closure_evidence_parse "$dir/blank.txt"
    chk "step6/grammar/blank-line-refuses" "1" "$VERIFY_RC"
    chk "step6/grammar/blank-line-says-why" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'leaves no blank line' && echo yes || echo no)"
    { printf 'CPLX-CLOSURE-EVIDENCE/1\n'; printf '# edited by hand\n'; } > "$dir/comment.txt"
    sed -e '1d' "$dir/good.txt" >> "$dir/comment.txt"
    verify_call closure_evidence_parse "$dir/comment.txt"
    chk "step6/grammar/comment-refuses" "1" "$VERIFY_RC"
    chk "step6/grammar/comment-says-why" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'leaves no comment' && echo yes || echo no)"

    # THE FIXED ORDER. Reordered records parse to the same model and are not the
    # same bytes, which is the whole of what canonical means for this document.
    { sed -n '1,3p' "$dir/good.txt"
      sed -n '5p' "$dir/good.txt"
      sed -n '4p' "$dir/good.txt"
      sed -n '6p' "$dir/good.txt"; } > "$dir/reordered.txt"
    verify_call closure_evidence_parse "$dir/reordered.txt"
    chk "step6/grammar/reordered-records-refuse" "1" "$VERIFY_RC"
    chk "step6/grammar/reordered-names-the-order" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'cannot follow' && echo yes || echo no)"

    # The shared lexical shape, inherited rather than reimplemented: an unknown
    # token, a wrong field count and an out-of-domain value each refuse.
    evidence_document "$dir/unknown.txt" "$id" "$cfg"
    printf 'observation|%s\n' 'tools/python/root/lib' >> "$dir/unknown.txt"
    verify_call closure_evidence_parse "$dir/unknown.txt"
    chk "step6/grammar/unknown-record-refuses" "1" "$VERIFY_RC"
    chk "step6/grammar/unknown-record-names-the-token" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'unknown-record|observation' && echo yes || echo no)"
    sed -e 's@^pre|tools/python/root/lib|present$@pre|tools/python/root/lib@' \
        "$dir/good.txt" > "$dir/short.txt"
    verify_call closure_evidence_parse "$dir/short.txt"
    chk "step6/grammar/wrong-field-count-refuses" "1" "$VERIFY_RC"
    sed -e 's@|present$@|maybe@' "$dir/good.txt" > "$dir/domain.txt"
    verify_call closure_evidence_parse "$dir/domain.txt"
    chk "step6/grammar/presence-domain-refuses" "1" "$VERIFY_RC"
    chk "step6/grammar/presence-domain-names-it" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'domain|presence: maybe' && echo yes || echo no)"
    sed -e 's/^verdict|PASS$/verdict|MAYBE/' "$dir/good.txt" > "$dir/verdictdomain.txt"
    verify_call closure_evidence_parse "$dir/verdictdomain.txt"
    chk "step6/grammar/verdict-domain-refuses" "1" "$VERIFY_RC"
    evidence_document "$dir/side.txt" "$id" "$cfg"
    sed -e 's/^verdict|PASS$/verdict|DIVERGENT/' "$dir/side.txt" > "$dir/side2.txt"
    printf 'unexpected|%s|%s\n' during 'tools/old/py3.13' >> "$dir/side2.txt"
    verify_call closure_evidence_parse "$dir/side2.txt"
    chk "step6/grammar/side-domain-refuses" "1" "$VERIFY_RC"

    # CARDINALITY AND PAIRING, the two shapes a well-formed record set can still
    # take and be no description of one comparison.
    evidence_document "$dir/twice.txt" "$id" "$cfg"
    sed -e "2a archive|$id" "$dir/twice.txt" > "$dir/twice2.txt"
    verify_call closure_evidence_parse "$dir/twice2.txt"
    chk "step6/grammar/two-archive-records-refuse" "1" "$VERIFY_RC"
    sed -e '/^verdict|/d' "$dir/good.txt" > "$dir/noverdict.txt"
    verify_call closure_evidence_parse "$dir/noverdict.txt"
    chk "step6/grammar/no-verdict-refuses" "1" "$VERIFY_RC"
    sed -e '/^post|/d' "$dir/good.txt" > "$dir/nopost.txt"
    verify_call closure_evidence_parse "$dir/nopost.txt"
    chk "step6/grammar/unpaired-sides-refuse" "1" "$VERIFY_RC"
    chk "step6/grammar/unpaired-names-the-counts" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q '1 pre records and 0 post records' && echo yes || echo no)"
    sed -e '1d' "$dir/good.txt" > "$dir/noversion.txt"
    verify_call closure_evidence_parse "$dir/noversion.txt"
    chk "step6/grammar/missing-version-line-refuses" "1" "$VERIFY_RC"

    # --- the pipeline delivery --------------------------------------------------
    #
    # THE BOOTSTRAP CANNOT BE DELIVERED BY WHAT IT DELIVERS, so this script runs
    # from the cplx checkout the pipeline already has and reads nothing from the
    # candidate. Its refusals are what stop a job running a mixture of two commits.
    section "step 6 delivery: the authoritative copies, or none of them"
    repo="$dir/repo"
    commit=$(step6_make_repo "$repo" "$src")
    if [ -z "$commit" ]; then
        fail "step6/delivery/fixture" "cannot build the fixture repository at $repo"
    else
        ws="$dir/ws"
        out=$(bash "$deliver" --repo "$repo" --commit "$commit" --into "$ws" 2>&1); rc=$?
        chk "step6/delivery/complete-delivery-succeeds" "0" "$rc"
        chk "step6/delivery/every-name-is-present" "8" \
            "$(find "$ws" -maxdepth 1 -type f -name '*.sh' 2>/dev/null | grep -c . || true)"
        chk "step6/delivery/verdict-names-the-commit" "yes" \
            "$(printf '%s' "$out" | grep -q "^DELIVERY|COMPLETE|$commit" && echo yes || echo no)"
        # THE DELIVERED BYTES ARE THE COMMIT'S BYTES, which is the property the
        # whole authority argument rests on and the one a manifest alone does not
        # give: a manifest of what was written proves nothing about where it came
        # from.
        blob=$(git -C "$repo" cat-file blob "$commit:src/setups/env/bin/closure_check.sh" | sha256sum)
        chk "step6/delivery/bytes-are-the-commits" "${blob%% *}" \
            "$(sha256sum -- "$ws/closure_check.sh" | sed -e 's/ .*$//')"

        # A REFERENCE WHOSE CONTENT CAN CHANGE is refused before a byte is
        # written, so two jobs claiming one delivery cannot run different bytes.
        rm -rf -- "$dir/ws-branch"
        out=$(bash "$deliver" --repo "$repo" --commit master --into "$dir/ws-branch" 2>&1); rc=$?
        chk "step6/delivery/a-branch-refuses" "1" "$rc"
        chk "step6/delivery/a-branch-writes-nothing" "" \
            "$(oneline "$(find "$dir/ws-branch" -type f 2>/dev/null)")"
        d1=$(git -C "$repo" rev-parse "$commit:src/setups/env/bin/closure_check.sh" 2>/dev/null)
        rm -rf -- "$dir/ws-blob"
        out=$(bash "$deliver" --repo "$repo" --commit "$d1" --into "$dir/ws-blob" 2>&1); rc=$?
        chk "step6/delivery/a-40-hex-blob-refuses" "1" "$rc"
        chk "step6/delivery/blob-refusal-names-the-type" "yes" \
            "$(printf '%s' "$out" | grep -q 'names a blob' && echo yes || echo no)"

        # A PARTIAL DELIVERY IS NOT A DELIVERY. The workspace is complete or empty
        # and never a mixture, because a job that found four of eight would run
        # them and produce evidence under two commits.
        ( cd "$repo" && git rm -q src/setups/env/bin/closure_elf.sh >/dev/null 2>&1 \
          && git commit -q -m 'drop one' >/dev/null 2>&1 ) || true
        d2=$(git -C "$repo" rev-parse HEAD 2>/dev/null)
        rm -rf -- "$dir/ws-partial"
        out=$(bash "$deliver" --repo "$repo" --commit "$d2" --into "$dir/ws-partial" 2>&1); rc=$?
        chk "step6/delivery/a-missing-blob-refuses" "1" "$rc"
        chk "step6/delivery/a-missing-blob-names-it" "yes" \
            "$(printf '%s' "$out" | grep -q 'holds no blob at src/setups/env/bin/closure_elf.sh' && echo yes || echo no)"
        # THE ASSERTION THAT MAKES THIS CASE ITS OWN: two names were written
        # before the failure and neither survives it.
        chk "step6/delivery/a-missing-blob-withdraws-what-it-wrote" "" \
            "$(oneline "$(find "$dir/ws-partial" -type f 2>/dev/null)")"
        ( cd "$repo" && git revert -q --no-edit HEAD >/dev/null 2>&1 ) || true
    fi
    rm -rf -- "$dir/nonrepo"; mkdir -p -- "$dir/nonrepo"
    out=$(bash "$deliver" --repo "$dir/nonrepo" --commit "$commit" --into "$dir/ws-none" 2>&1); rc=$?
    chk "step6/delivery/a-non-checkout-refuses" "1" "$rc"
    chk "step6/delivery/non-checkout-says-there-is-no-other-source" "yes" \
        "$(printf '%s' "$out" | grep -q 'no other source' && echo yes || echo no)"

    # --- the live observer ------------------------------------------------------
    #
    # THE HALF NO STATIC READ CAN ANSWER, and the one develop#20 got wrong: a
    # trace that inventoried nothing reported "no host library loaded", which is
    # true of an empty observation and reads as a pass.
    section "step 6 live observer: an empty inventory is not a pass"
    root="$dir/proc-clean"
    step6_plant_proc "$root" 4242 python3 /opt/tools/python/current/bin/python3 \
        /opt/tools/python/root/lib/libc.so.6 /opt/tools/python/current/bin/python3
    out=$(bash "$observe" --process python3 --prefix /opt --proc "$root" 2>&1); rc=$?
    chk "step6/live/clean-inventory-is-conclusive" "0" "$rc"
    chk "step6/live/it-names-the-process-it-inventoried" "yes" \
        "$(printf '%s' "$out" | grep -q '^PROCESS|4242|python3' && echo yes || echo no)"
    chk "step6/live/shipped-objects-are-classified" "2" \
        "$(printf '%s' "$out" | grep -c '|shipped$' || true)"
    chk "step6/live/pseudo-and-anonymous-mappings-are-not-objects" "0" \
        "$(printf '%s' "$out" | grep -c 'OBJECT|4242|\[' || true)"

    root="$dir/proc-host"
    step6_plant_proc "$root" 77 python3 /opt/tools/python/current/bin/python3 \
        /opt/tools/python/root/lib/libc.so.6 /usr/lib/x86_64-linux-gnu/libssl.so.3
    out=$(bash "$observe" --process python3 --prefix /opt --proc "$root" 2>&1); rc=$?
    chk "step6/live/a-host-object-refuses" "1" "$rc"
    chk "step6/live/the-refusal-counts-them" "yes" \
        "$(printf '%s' "$out" | grep -q 'map 1 object(s) from outside /opt' && echo yes || echo no)"

    # THE PREFIX TEST IS A PREFIX TEST. A host path that merely contains the
    # prefix as text is a host path, and reading it as shipped would hide exactly
    # the fallback this observation exists to find.
    root="$dir/proc-lookalike"
    step6_plant_proc "$root" 78 python3 /opt/tools/python/current/bin/python3 \
        /var/backup/opt/tools/python/root/lib/libc.so.6
    out=$(bash "$observe" --process python3 --prefix /opt --proc "$root" 2>&1); rc=$?
    chk "step6/live/a-lookalike-path-is-a-host-object" "1" "$rc"

    # The owner excludes Dynatrace monitoring on every host, independently of
    # its installed version. The raw external count and each mapping survive;
    # only recognized monitoring is removed from the fallback verdict.
    local agent_path="" host_path=""
    root="$dir/proc-monitoring"
    for agent_path in \
        /opt/dynatrace/oneagent/agent/bin/1.343/linux-x86-64/liboneagentproc.so \
        /opt/dynatrace/oneagent/agent/bin/next/linux-x86-64/liboneagentaudit.so \
        /usr/lib64/liboneagentproc.so /lib64/liboneagentproc.so \
        /usr/lib/x86_64-linux-gnu/liboneagentaudit.so \
        '/opt/dynatrace/oneagent/agent/bin/old/linux-x86-64/liboneagentproc.so (deleted)'; do
        step6_plant_proc "$root" 85 python3 /srv/candidate/bin/python3 \
            /srv/candidate/bin/python3 "$agent_path" "$agent_path"
        out=$(bash "$observe" --process python3 --prefix /srv/candidate --proc "$root" 2>&1); rc=$?
        chk "step6/live/dynatrace/recognized-monitoring-is-excluded" "0" "$rc"
        chk "step6/live/dynatrace/mapping-remains-visible" "yes" \
            "$(printf '%s\n' "$out" | grep -Fqx "OBJECT|85|$agent_path|excluded-dynatrace" && echo yes || echo no)"
        chk "step6/live/dynatrace/raw-host-count-is-not-hidden" "yes" \
            "$(printf '%s\n' "$out" | grep -qx 'HOSTS|85|1' && echo yes || echo no)"
        chk "step6/live/dynatrace/exclusion-is-counted-once" "yes" \
            "$(printf '%s\n' "$out" | grep -qx 'EXCLUDED|85|dynatrace|1' && echo yes || echo no)"
        chk "step6/live/dynatrace/no-in-scope-fallback" "yes" \
            "$(printf '%s\n' "$out" | grep -qx 'FALLBACKS|85|0' && echo yes || echo no)"
    done
    for host_path in /lib64/libc.so.6 /lib64/ld-linux-x86-64.so.2 \
        /usr/lib/libpython3.13.so /usr/lib64/libm.so.6 /lib64/libgcc_s.so.1 \
        /tmp/liboneagentproc.so /opt/dynatrace/oneagent/agent/libc.so.6 \
        /opt/dynatrace/oneagent/../other/liboneagentproc.so \
        /opt/dynatrace/oneagent-lookalike/agent/liboneagentproc.so; do
        step6_plant_proc "$root" 85 python3 /srv/candidate/bin/python3 \
            /srv/candidate/bin/python3 /usr/lib64/liboneagentproc.so "$host_path"
        out=$(bash "$observe" --process python3 --prefix /srv/candidate --proc "$root" 2>&1); rc=$?
        chk "step6/live/dynatrace/another-host-object-still-refuses" "1" "$rc"
        chk "step6/live/dynatrace/refused-object-remains-visible" "yes" \
            "$(printf '%s\n' "$out" | grep -Fqx "OBJECT|85|$host_path|host" && echo yes || echo no)"
    done
    step6_plant_proc "$root" 85 python3 /srv/candidate/bin/python3 \
        /usr/lib64/liboneagentproc.so
    out=$(bash "$observe" --process python3 --prefix /srv/candidate --proc "$root" 2>&1); rc=$?
    chk "step6/live/dynatrace/monitoring-alone-is-inconclusive" "4" "$rc"

    # THE REFUSAL THIS FILE EXISTS FOR, and it has its own exit code so a caller
    # cannot read it as either outcome.
    root="$dir/proc-empty"
    step6_plant_proc "$root" 79 bash /bin/bash /lib/x86_64-linux-gnu/libc.so.6
    out=$(bash "$observe" --process python3 --prefix /opt --proc "$root" 2>&1); rc=$?
    chk "step6/live/an-empty-inventory-is-inconclusive" "4" "$rc"
    chk "step6/live/it-is-neither-a-pass-nor-a-refusal" "yes" \
        "$(printf '%s' "$out" | grep -q '^LIVE|INCONCLUSIVE|' && echo yes || echo no)"
    chk "step6/live/it-never-says-nothing-was-found" "yes" \
        "$(printf '%s' "$out" | grep -q 'CONCLUSIVE|0 process' && echo no || echo yes)"

    # AN EMPTY MAPPING TABLE IS NOT AN INVENTORY, and round 1 of this review
    # reproduced it reading as a clean one. A matched process whose `maps` is
    # readable and EMPTY is what an exited or zombie process leaves: it mapped
    # nothing observable, which is not the claim "it mapped no host object", and
    # the two must not share an exit code.
    root="$dir/proc-emptymaps"
    step6_plant_proc "$root" 81 python3 /opt/tools/python/current/bin/python3
    : > "$root/81/maps"
    out=$(bash "$observe" --process python3 --prefix /opt --proc "$root" 2>&1); rc=$?
    chk "step6/live/an-empty-mapping-table-is-inconclusive" "4" "$rc"
    chk "step6/live/an-empty-mapping-table-is-never-conclusive" "no" \
        "$(printf '%s' "$out" | grep -q '^LIVE|CONCLUSIVE|' && echo yes || echo no)"
    chk "step6/live/the-unusable-process-is-named" "yes" \
        "$(printf '%s' "$out" | grep -q '^UNUSABLE|81|' && echo yes || echo no)"

    # A READ THAT FAILS IS NOT AN EMPTY READING EITHER, which is the second half
    # of the same finding: the collection ran in a process substitution whose
    # completion this loop could not observe, so a mapping table that disappeared
    # under the read ended the loop exactly as a full inventory did.
    root="$dir/proc-unreadable"
    step6_plant_proc "$root" 82 python3 /opt/tools/python/current/bin/python3 \
        /opt/tools/python/root/lib/libc.so.6
    rm -f -- "$root/82/maps"
    mkdir -p -- "$root/82/maps"
    out=$(bash "$observe" --process python3 --prefix /opt --proc "$root" 2>&1); rc=$?
    chk "step6/live/an-unreadable-mapping-table-is-inconclusive" "4" "$rc"
    chk "step6/live/the-failed-collection-is-named" "yes" \
        "$(printf '%s' "$out" | grep -q '^UNUSABLE|82|' && echo yes || echo no)"

    # THE COUNT IS OF USABLE INVENTORIES, and the control says so from the other
    # side: one readable process beside one empty one is ONE inventory, and the
    # run is conclusive on the strength of the one that could be read.
    root="$dir/proc-mixed"
    step6_plant_proc "$root" 83 python3 /opt/tools/python/current/bin/python3 \
        /opt/tools/python/root/lib/libc.so.6
    step6_plant_proc "$root" 84 python3 /opt/tools/python/current/bin/python3
    : > "$root/84/maps"
    out=$(bash "$observe" --process python3 --prefix /opt --proc "$root" 2>&1); rc=$?
    chk "step6/live/control/one-usable-inventory-is-conclusive" "0" "$rc"
    chk "step6/live/control/the-count-excludes-the-unusable-one" "yes" \
        "$(printf '%s' "$out" | grep -q '^LIVE|CONCLUSIVE|1 process' && echo yes || echo no)"

    # `comm` IS TRUNCATED BY THE KERNEL at fifteen characters, so a longer name is
    # findable only through argv[0] and a reader with one source would miss it.
    root="$dir/proc-long"
    step6_plant_proc "$root" 80 'closure-verifi' /opt/tools/bin/closure-verification-driver \
        /opt/tools/python/root/lib/libc.so.6
    out=$(bash "$observe" --process closure-verification-driver --prefix /opt --proc "$root" 2>&1); rc=$?
    chk "step6/live/a-truncated-comm-is-found-through-argv0" "0" "$rc"

    # --- the results root, and what may occupy a canonical name -----------------
    #
    # THE ROOT IS VALIDATED BEFORE ANY WRITE, and each failure is a refusal rather
    # than a warning: a result written into a directory another account can
    # replace is not evidence about anything.
    section "step 6 evidence storage: validated before a byte, and never overwritten"
    root="$dir/store"
    mkdir -p -- "$root/real" "$root/loose" "$root/other" || true
    chmod 0755 "$root/real"
    chmod 0775 "$root/loose"
    chmod 0757 "$root/other"
    ln -s -- "$root/real" "$root/link" 2>/dev/null
    printf 'not a directory\n' > "$root/file"
    evidence_document "$dir/store-body.txt" "$id" "$cfg"

    verify_call closure_evidence_emit "$root/link" "$id" "$dir/store-body.txt"
    chk "step6/storage/a-symlink-root-refuses" "1" "$VERIFY_RC"
    chk "step6/storage/symlink-refusal-is-about-the-symlink" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'is a symlink' && echo yes || echo no)"
    # AND IT WROTE NOTHING THROUGH THE LINK, which is the half the exit status
    # does not carry: a refusal that had already created the file would have
    # placed evidence exactly where the symlink pointed.
    chk "step6/storage/a-symlink-root-writes-nothing" "" \
        "$(oneline "$(find "$root/real" -type f 2>/dev/null)")"
    verify_call closure_evidence_emit "$root/file" "$id" "$dir/store-body.txt"
    chk "step6/storage/a-file-root-refuses" "1" "$VERIFY_RC"
    verify_call closure_evidence_emit "$root/loose" "$id" "$dir/store-body.txt"
    chk "step6/storage/a-group-writable-root-refuses" "1" "$VERIFY_RC"
    chk "step6/storage/group-writable-refusal-says-why" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'writable by group or other' && echo yes || echo no)"
    verify_call closure_evidence_emit "$root/other" "$id" "$dir/store-body.txt"
    chk "step6/storage/an-other-writable-root-refuses" "1" "$VERIFY_RC"
    verify_call closure_evidence_emit "$root/absent" "$id" "$dir/store-body.txt"
    chk "step6/storage/an-absent-root-refuses" "1" "$VERIFY_RC"

    # THE HAPPY PATH, and the bytes at the canonical name are the bytes handed in.
    verify_call closure_evidence_emit "$root/real" "$id" "$dir/store-body.txt"
    chk "step6/storage/a-good-root-writes-the-canonical-name" "0" "$VERIFY_RC"
    chk "step6/storage/it-says-what-it-wrote" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q "^EVIDENCE|WRITTEN|$root/real/$id\$" && echo yes || echo no)"
    chk "step6/storage/the-stored-bytes-are-the-document" \
        "$(sha256sum -- "$dir/store-body.txt" | sed -e 's/ .*$//')" \
        "$(sha256sum -- "$root/real/$id" 2>/dev/null | sed -e 's/ .*$//')"
    # NO TEMPORARY SURVIVES A SUCCESS, so a results root never accumulates the
    # half-written files the promotion exists to keep out of the canonical name.
    chk "step6/storage/no-temporary-is-left-behind" "" \
        "$(oneline "$(find "$root/real" -maxdepth 1 -name '.evidence.*' 2>/dev/null)")"

    # THREE OUTCOMES WHEN THE NAME IS TAKEN, and only the first two are success.
    verify_call closure_evidence_emit "$root/real" "$id" "$dir/store-body.txt"
    chk "step6/storage/an-identical-rerun-is-idempotent" "0" "$VERIFY_RC"
    chk "step6/storage/idempotent-says-so" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q '^EVIDENCE|IDEMPOTENT|' && echo yes || echo no)"
    evidence_document "$dir/store-other.txt" "$id" "$cfg" absent
    verify_call closure_evidence_emit "$root/real" "$id" "$dir/store-other.txt"
    chk "step6/storage/a-different-result-refuses" "1" "$VERIFY_RC"
    chk "step6/storage/it-is-retained-under-a-conflict-name" "1" \
        "$(find "$root/real" -maxdepth 1 -name "$id.conflict.*" 2>/dev/null | grep -c . || true)"
    # AND THE CANONICAL FILE IS UNTOUCHED, which is what "nothing is ever silently
    # overwritten" means and what the exit status alone would not say.
    chk "step6/storage/the-canonical-file-is-unchanged" \
        "$(sha256sum -- "$dir/store-body.txt" | sed -e 's/ .*$//')" \
        "$(sha256sum -- "$root/real/$id" 2>/dev/null | sed -e 's/ .*$//')"
    chk "step6/storage/the-conflict-stops-the-run" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'which one is wrong is a human decision' && echo yes || echo no)"

    # AND IT KEEPS STOPPING, which is the half round 1 of this review found
    # missing. The retained conflict is UNRESOLVED evidence, so the very next run
    # that agrees with the canonical file is not entitled to the idempotent zero:
    # agreeing with one of two answers does not decide which of them is wrong.
    verify_call closure_evidence_emit "$root/real" "$id" "$dir/store-body.txt"
    chk "step6/storage/an-agreeing-rerun-under-a-conflict-refuses" "1" "$VERIFY_RC"
    chk "step6/storage/the-agreeing-rerun-is-not-idempotent" "no" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q '^EVIDENCE|IDEMPOTENT|' && echo yes || echo no)"
    chk "step6/storage/the-agreeing-rerun-says-what-is-unresolved" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q 'a rerun that agrees with one of the two' && echo yes || echo no)"

    # A SECOND DIFFERING RESULT IS RETAINED BESIDE THE FIRST, and this is the case
    # a timestamp alone loses: both conflicts are produced inside the same second
    # here, so a name carrying only that second would have made the second `ln`
    # fail and DROPPED the evidence the recovery rule exists to keep.
    evidence_document "$dir/store-third.txt" "$id" \
        "$(printf 'a third policy\n' | sha256sum | sed -e 's/ .*$//')"
    verify_call closure_evidence_emit "$root/real" "$id" "$dir/store-third.txt"
    chk "step6/storage/a-second-different-result-also-refuses" "1" "$VERIFY_RC"
    chk "step6/storage/both-conflicts-are-retained" "2" \
        "$(find "$root/real" -maxdepth 1 -name "$id.conflict.*" 2>/dev/null | grep -c . || true)"
    chk "step6/storage/the-second-conflict-is-reported-at-its-name" "yes" \
        "$(printf '%s' "$VERIFY_OUT" | grep -q "^EVIDENCE|CONFLICT|$root/real/$id.conflict." && echo yes || echo no)"
    # THE CANONICAL FILE IS STILL THE FIRST RESULT after both conflicts, which is
    # what "nothing is ever silently overwritten" means across more than one.
    chk "step6/storage/the-canonical-file-survives-both" \
        "$(sha256sum -- "$dir/store-body.txt" | sed -e 's/ .*$//')" \
        "$(sha256sum -- "$root/real/$id" 2>/dev/null | sed -e 's/ .*$//')"

    # THE SHARED READER REFUSES THE SAME STATE, which is what carries the stop
    # into publication: the reader is the one gate both consumers pass through, so
    # a record with a conflict beside it is not evidence to either of them.
    chk "step6/storage/the-reader-refuses-a-conflicted-record" "" \
        "$(verify_model "$root/real/$id")"

    # A PARTIAL WRITE LEAVES NOTHING AT THE CANONICAL NAME, and the rerun after it
    # SUCCEEDS. The second half is the point: a no-overwrite rule on its own would
    # have let one transient failure make an archive unverifiable forever.
    mkdir -p -- "$root/partial" || true
    chmod 0755 "$root/partial"
    d2=$(printf 'a second candidate\n' | sha256sum); d2="${d2%% *}"
    verify_call closure_evidence_emit "$root/partial" "$d2" "$dir/no-such-body.txt"
    chk "step6/storage/an-unreadable-body-refuses" "1" "$VERIFY_RC"
    chk "step6/storage/a-partial-write-leaves-no-canonical-name" "no" \
        "$( [ -e "$root/partial/$d2" ] && echo yes || echo no )"
    verify_call closure_evidence_emit "$root/partial" "$d2" "$dir/store-body.txt"
    chk "step6/storage/a-rerun-after-a-partial-write-succeeds" "0" "$VERIFY_RC"

    # --- the driver, and the ordering the bootstrap rests on --------------------
    section "step 6 driver: the delivery comes first, and there is no fallback"
    root="$dir/drive"
    mkdir -p -- "$root/results" "$root/empty-ws" || true
    chmod 0755 "$root/results"
    # AN ABSENT DELIVERY REFUSES BEFORE THE ARCHIVE IS OPENED, and the archive
    # named here DOES NOT EXIST: a run that opened it first would refuse for that
    # reason instead, so the refusal text is what proves the order.
    out=$(bash "$verify" --archive "$root/no-such-archive.tar.gz" --prefix "$root/prefix" \
        --results "$root/results" --tools "$root/empty-ws" --target tools 2>&1); rc=$?
    chk "step6/driver/an-absent-delivery-refuses" "1" "$rc"
    chk "step6/driver/it-names-what-the-pipeline-did-not-deliver" "yes" \
        "$(printf '%s' "$out" | grep -q 'the pipeline delivered no closure_check.sh' && echo yes || echo no)"
    chk "step6/driver/it-refuses-before-it-opens-the-archive" "yes" \
        "$(printf '%s' "$out" | grep -q 'cannot be read' && echo no || echo yes)"
    chk "step6/driver/it-offers-no-fallback-to-the-candidate" "yes" \
        "$(printf '%s' "$out" | grep -q 'no copy inside the candidate may stand in' && echo yes || echo no)"

    # WITH THE DELIVERY PRESENT, an unreadable archive refuses and names THAT
    # input. The pair is the ordering assertion: the same run, two inputs, and
    # which one is reported says which was read first.
    if [ -d "$dir/ws" ]; then
        out=$(bash "$verify" --archive "$root/no-such-archive.tar.gz" --prefix "$root/prefix" \
            --results "$root/results" --tools "$dir/ws" --target tools 2>&1); rc=$?
        chk "step6/driver/an-unreadable-archive-refuses" "1" "$rc"
        chk "step6/driver/it-names-the-missing-archive" "yes" \
            "$(printf '%s' "$out" | grep -q 'cannot be read' && echo yes || echo no)"
        chk "step6/driver/the-delivery-was-reported-present-first" "yes" \
            "$(printf '%s' "$out" | grep -q '^DELIVERY|PRESENT|' && echo yes || echo no)"
    else
        fail "step6/driver/delivery-fixture" "the delivery fixture at $dir/ws was not built"
    fi

    # --- the comparison, both directions ----------------------------------------
    #
    # THE TWO DIVERGENCES DIFFER ONLY IN WHICH SIDE IS MISSING, and both must be
    # present: a build-account claim would have passed the second, which is the
    # whole reason the build side is derived from the archive.
    section "step 6 comparison: a directory on one side only, in both directions"
    root="$dir/compare"
    mkdir -p -- "$root/in-archive/tools/python/root/lib" || true
    mkdir -p -- "$root/in-archive/tools/python/current/lib" || true
    mkdir -p -- "$root/in-archive/tools/git/root/lib" || true
    mkdir -p -- "$root/installed/tools/python/root/lib" || true
    mkdir -p -- "$root/installed/tools/python/current/lib" || true
    # The declared shape both sides are measured against, from the committed
    # declaration rather than from a list this suite invented.
    step6_specs=()
    while IFS= read -r name; do
        if [ -n "$name" ]; then step6_specs+=("$name"); fi
    done < <(config_specs "$src/../closure/closure-config.txt")

    if [ "${#step6_specs[@]}" -eq 0 ]; then
        fail "step6/compare/specs" "the committed declaration yielded no root specification"
    else
        side_a=$(verify_side "$root/in-archive" "$src/install_pkg.sh" "${step6_specs[@]}")
        side_b=$(verify_side "$root/installed" "$src/install_pkg.sh" "${step6_specs[@]}")
        chk "step6/compare/the-archive-side-sees-the-directory" "yes" \
            "$(printf '%s' "$side_a" | grep -q '^presence|tools/git/root/lib|present$' && echo yes || echo no)"
        chk "step6/compare/the-installed-side-does-not" "yes" \
            "$(printf '%s' "$side_b" | grep -q '^presence|tools/git/root/lib|absent$' && echo yes || echo no)"
        chk "step6/compare/present-in-the-archive-and-absent-installed-is-DIVERGENT" "DIVERGENT" \
            "$(verify_verdict "$side_a" "$side_b")"
        # THE OTHER DIRECTION, which a transported packaging claim would have
        # reported as present on both sides.
        chk "step6/compare/present-installed-and-absent-in-the-archive-is-DIVERGENT" "DIVERGENT" \
            "$(verify_verdict "$side_b" "$side_a")"
        # AND THE CONTROL: one side against itself is a PASS, so DIVERGENT above
        # is about the difference rather than about the comparison always failing.
        chk "step6/compare/one-side-against-itself-passes" "PASS" \
            "$(verify_verdict "$side_a" "$side_a")"
        # AN UNEXPECTED ROOT FORCES DIVERGENT TOO, which is the second input to
        # the derivation and the one a pair-only comparison would have missed.
        mkdir -p -- "$root/installed/tools/old/py3.13/lib" || true
        side_c=$(verify_side "$root/installed" "$src/install_pkg.sh" "${step6_specs[@]}")
        chk "step6/compare/an-undeclared-root-is-unexpected" "yes" \
            "$(printf '%s' "$side_c" | grep -q '^unexpected|tools/old/py3.13/lib$' && echo yes || echo no)"
        chk "step6/compare/an-unexpected-finding-is-DIVERGENT" "DIVERGENT" \
            "$(verify_verdict "$side_c" "$side_c")"

        # THE ARCHIVE SIDE, FROM A REAL ARCHIVE, and round 1 of this review found
        # why two hand-made directory trees could not have caught it.
        # `tools/python/current` is a SYMLINKED DIRECTORY, which `tar -t` lists by
        # name with no trailing slash, so the pass that turns entries into
        # directories contributed its PARENT and dropped the alias. The installed
        # tree resolves `current/lib`; the skeleton reported it absent; and an
        # archive whose committed declaration names that alias was DIVERGENT for a
        # difference that is not there.
        root="$dir/alias"
        rm -rf -- "$root"
        # THE ALIAS TARGET IS A DECLARED ROOT, and it has to be: an undeclared
        # directory is an unexpected finding on both sides and would make the
        # comparison DIVERGENT for a reason that has nothing to do with the
        # alias. The name comes from the committed declaration.
        mkdir -p -- "$root/tree/tools/python/python-3.13.9/lib" \
            "$root/tree/tools/python/root/lib" "$root/tree/tools/git/root/lib" \
            "$root/work" || true
        ln -s -- python-3.13.9 "$root/tree/tools/python/current"
        tar -czf "$root/archive.tar.gz" -C "$root/tree" tools 2>/dev/null
        verify_call closure_verify_skeleton "$root/archive.tar.gz" "$root/work"
        chk "step6/compare/the-skeleton-is-derived-from-a-real-archive" "0" "$VERIFY_RC"
        chk "step6/compare/the-directory-alias-is-reconstructed" "yes" \
            "$( [ -L "$root/work/tree/tools/python/current" ] && echo yes || echo no )"
        chk "step6/compare/the-alias-resolves-as-it-does-installed" "yes" \
            "$( [ -d "$root/work/tree/tools/python/current/lib" ] && echo yes || echo no )"
        # AND THE COMPARISON THAT MATTERS: the skeleton against the tree the
        # archive was made from, through the SAME derivation both sides use. A
        # supported archive compares equal to itself, which is the property the
        # missing alias was breaking.
        side_a=$(verify_side "$root/work/tree" "$src/install_pkg.sh" "${step6_specs[@]}")
        side_b=$(verify_side "$root/tree" "$src/install_pkg.sh" "${step6_specs[@]}")
        chk "step6/compare/the-alias-is-present-on-the-archive-side" "yes" \
            "$(printf '%s' "$side_a" | grep -q '^presence|tools/python/current/lib|present$' && echo yes || echo no)"
        chk "step6/compare/a-supported-alias-is-not-a-divergence" "PASS" \
            "$(verify_verdict "$side_a" "$side_b")"
        # TWO SPELLINGS OF ONE DIRECTORY MUST NOT BE TWO VERDICTS, which round 2
        # of this review found them to be. The archive-side test refused every
        # target holding `..`, so the ordinary `../python/python-3.13.9` spelling
        # of the same alias was dropped from the skeleton while the installed tree
        # resolved it, and a supported archive read DIVERGENT. What matters is
        # CONTAINMENT, so the link's own depth is counted and the target walked
        # from there.
        rm -rf -- "$root/rel"
        mkdir -p -- "$root/rel/tree/tools/python/python-3.13.9/lib" \
            "$root/rel/tree/tools/python/root/lib" "$root/rel/tree/tools/git/root/lib" \
            "$root/rel/work" || true
        ln -s -- ../python/python-3.13.9 "$root/rel/tree/tools/python/current"
        tar -czf "$root/rel/archive.tar.gz" -C "$root/rel/tree" tools 2>/dev/null
        verify_call closure_verify_skeleton "$root/rel/archive.tar.gz" "$root/rel/work"
        chk "step6/compare/a-parent-relative-alias-is-reconstructed" "yes" \
            "$( [ -L "$root/rel/work/tree/tools/python/current" ] && echo yes || echo no )"
        chk "step6/compare/a-parent-relative-alias-resolves" "yes" \
            "$( [ -d "$root/rel/work/tree/tools/python/current/lib" ] && echo yes || echo no )"
        side_c=$(verify_side "$root/rel/work/tree" "$src/install_pkg.sh" "${step6_specs[@]}")
        chk "step6/compare/the-two-spellings-observe-alike" \
            "$(oneline "$(printf '%s' "$side_a" | grep '^presence|' || true)")" \
            "$(oneline "$(printf '%s' "$side_c" | grep '^presence|' || true)")"
        chk "step6/compare/a-parent-relative-alias-is-not-a-divergence" "PASS" \
            "$(verify_verdict "$side_c" \
                "$(verify_side "$root/rel/tree" "$src/install_pkg.sh" "${step6_specs[@]}")")"
        # THE CONTAINMENT CONTROL: a target that leaves the archive is refused,
        # so the repair is about resolving `..` rather than about permitting it.
        verify_call closure_verify_contained tools/python/current ../../../etc
        chk "step6/compare/control/an-escaping-target-is-refused" "1" "$VERIFY_RC"
        verify_call closure_verify_contained tools/python/current /etc/passwd
        chk "step6/compare/control/an-absolute-target-is-refused" "1" "$VERIFY_RC"
        verify_call closure_verify_contained tools/python/current ../python/python-3.13.9
        chk "step6/compare/control/a-contained-target-is-accepted" "0" "$VERIFY_RC"

        # THE CONTROL, so the alias handling cannot pass by accepting everything:
        # the same archive against a tree where the alias TARGET was removed is
        # still DIVERGENT, because the difference is then real.
        rm -rf -- "$root/tree/tools/python/python-3.13.9"
        side_c=$(verify_side "$root/tree" "$src/install_pkg.sh" "${step6_specs[@]}")
        chk "step6/compare/control/a-broken-alias-is-still-DIVERGENT" "DIVERGENT" \
            "$(verify_verdict "$side_a" "$side_c")"
    fi

    # --- publication, driven by a producer rather than by a fixture -------------
    #
    # STEP 5 ASSERTED THIS GATE AGAINST A RECORD THIS HARNESS WROTE. Here the same
    # gate reads a document the shared reader accepts, so the two failures Design
    # Area 7 says fall out of the identity binding are asserted against evidence
    # rather than against an agreement between two halves of one test.
    section "step 6 publication: the identity binding, against a real evidence document"
    root="$dir/pub"
    mkdir -p -- "$root/staging" "$root/results" "$root/tree/tools/closure" || true
    chmod 700 "$root/staging"
    chmod 0755 "$root/results"
    if [ -z "$commit" ]; then
        fail "step6/publication/fixture" "no fixture commit to publish against"
    else
        cp -- "$src/../closure/closure-config.txt" "$root/tree/tools/closure/closure-config.txt"
        step2_write_envelope "$root/tree/tools/closure/closure-envelope.txt" \
            "$(config_digest "$root/tree/tools/closure/closure-config.txt")" \
            "src/setups/env/closure/closure-config.txt" "$commit"
        tar -czf "$root/a.tar.gz" -C "$root/tree" tools 2>/dev/null
        printf 'a second archive\n' > "$root/tree/tools/marker.txt"
        tar -czf "$root/b.tar.gz" -C "$root/tree" tools 2>/dev/null
        d1=$(sha256sum -- "$root/a.tar.gz" | sed -e 's/ .*$//')
        d2=$(sha256sum -- "$root/b.tar.gz" | sed -e 's/ .*$//')
        cfg=$(config_digest "$repo/src/setups/env/closure/closure-config.txt")
        evidence_document "$root/results/$d1" "$d1" "$cfg"

        # A VALID PASSING RESULT FOR ARCHIVE A, SUPPLIED WITH ARCHIVE B. The
        # result is well formed and describes the wrong bytes, which publication
        # can tell because it computes the identity itself.
        out=$(step6_publish "$publish" "$root/b.tar.gz" "$commit" "$repo" \
            "$root/results" "$root/stage1"); rc=$?
        chk "step6/publication/a-result-for-another-archive-refuses" "1" "$rc"
        chk "step6/publication/it-refuses-at-step-2" "yes" \
            "$(printf '%s' "$out" | grep -q 'REFUSED at step 2' && echo yes || echo no)"
        chk "step6/publication/it-names-the-identity-it-computed" "yes" \
            "$(printf '%s' "$out" | grep -q "keyed to archive identity $d2" && echo yes || echo no)"

        # THE SAME REFUSAL FROM THE OTHER DIRECTION: the archive is modified after
        # verification, so it hashes to a value no result names. One rule, two
        # failures, which is what Design Area 7 says falls out of the binding.
        #
        # THE MODIFICATION KEEPS THE ARCHIVE VALID. Appending bytes to the file
        # would have made it unreadable, and publication would then refuse at
        # step 1 for that reason while this case claimed to measure step 2. So
        # the file at the same path is REPLACED by a well-formed archive with
        # different content, which is what "modified after verification" means to
        # anyone who would do it.
        printf 'a third revision\n' > "$root/tree/tools/revision.txt"
        tar -czf "$root/a.tar.gz" -C "$root/tree" tools 2>/dev/null
        out=$(step6_publish "$publish" "$root/a.tar.gz" "$commit" "$repo" \
            "$root/results" "$root/stage2"); rc=$?
        chk "step6/publication/an-archive-modified-after-verification-refuses" "1" "$rc"
        chk "step6/publication/the-modified-archive-refuses-at-step-2" "yes" \
            "$(printf '%s' "$out" | grep -q 'REFUSED at step 2' && echo yes || echo no)"

        # A DOCUMENT KEYED TO THE RIGHT ARCHIVE UNDER THE WRONG POLICY is refused
        # too, and this is the third row of the table rather than a repetition:
        # the comparison was taken under a declaration publication did not resolve.
        rm -rf -- "$root/results2"; mkdir -p -- "$root/results2"; chmod 0755 "$root/results2"
        evidence_document "$root/results2/$d2" "$d2" \
            "0000000000000000000000000000000000000000000000000000000000000000"
        out=$(step6_publish "$publish" "$root/b.tar.gz" "$commit" "$repo" \
            "$root/results2" "$root/stage3"); rc=$?
        chk "step6/publication/a-result-under-another-policy-refuses" "1" "$rc"
        chk "step6/publication/the-policy-refusal-names-both-digests" "yes" \
            "$(printf '%s' "$out" | grep -q 'taken under configuration' && echo yes || echo no)"

        # A DIVERGENT RESULT KEYED TO THE EXACT ARCHIVE is refused as well, which
        # is what makes step 2 a check on the VERDICT and not only on the key.
        rm -rf -- "$root/results3"; mkdir -p -- "$root/results3"; chmod 0755 "$root/results3"
        evidence_document "$root/results3/$d2" "$d2" "$cfg" absent
        out=$(step6_publish "$publish" "$root/b.tar.gz" "$commit" "$repo" \
            "$root/results3" "$root/stage4"); rc=$?
        chk "step6/publication/a-divergent-result-refuses" "1" "$rc"
        chk "step6/publication/the-divergent-refusal-names-the-verdict" "yes" \
            "$(printf '%s' "$out" | grep -q "is 'DIVERGENT' rather than PASS" && echo yes || echo no)"

        # AND THE ONE THAT PROCEEDS. A present, passing result keyed to the exact
        # archive under the exact policy takes publication PAST step 2, which is
        # the only property step 2 asserts. It then refuses at step 3 or 4 on this
        # fixture, and asserting THAT is what says step 2 was satisfied rather
        # than skipped.
        rm -rf -- "$root/results4"; mkdir -p -- "$root/results4"; chmod 0755 "$root/results4"
        evidence_document "$root/results4/$d2" "$d2" "$cfg"
        out=$(step6_publish "$publish" "$root/b.tar.gz" "$commit" "$repo" \
            "$root/results4" "$root/stage5"); rc=$?
        chk "step6/publication/a-matching-result-passes-step-2" "yes" \
            "$(printf '%s' "$out" | grep -q 'REFUSED at step 2' && echo no || echo yes)"
        chk "step6/publication/it-reaches-a-later-step" "yes" \
            "$(printf '%s' "$out" | grep -qE 'REFUSED at step (3|4)' && echo yes || echo no)"

        # THE CONFLICT STOPS PUBLICATION, AND IT IS THE PRODUCER THAT CREATES IT.
        # Round 1 of this review reproduced the whole path in the other order: a
        # valid PASS was published past step 2 while a DIVERGENT result for the
        # same identity was retained beside it, because step 2 opened the keyed
        # path and asked nothing about what the emitter had left next to it. The
        # case drives the REAL emitter for both documents rather than planting a
        # conflict file, so what publication meets is what a run produces.
        rm -rf -- "$root/results5"; mkdir -p -- "$root/results5"; chmod 0755 "$root/results5"
        evidence_document "$root/pass.txt" "$d2" "$cfg"
        evidence_document "$root/divergent.txt" "$d2" "$cfg" absent
        verify_call closure_evidence_emit "$root/results5" "$d2" "$root/pass.txt"
        chk "step6/publication/the-producer-writes-the-passing-result" "0" "$VERIFY_RC"
        verify_call closure_evidence_emit "$root/results5" "$d2" "$root/divergent.txt"
        chk "step6/publication/the-producer-retains-the-conflict" "1" "$VERIFY_RC"
        out=$(step6_publish "$publish" "$root/b.tar.gz" "$commit" "$repo" \
            "$root/results5" "$root/stage6"); rc=$?
        chk "step6/publication/a-retained-conflict-refuses" "1" "$rc"
        chk "step6/publication/the-conflict-refusal-is-at-step-2" "yes" \
            "$(printf '%s' "$out" | grep -q 'REFUSED at step 2' && echo yes || echo no)"
        chk "step6/publication/the-conflict-refusal-names-the-human-decision" "yes" \
            "$(printf '%s' "$out" | grep -q 'which of the two is wrong is a human decision' && echo yes || echo no)"

        # AND THE RERUN AFTER IT STILL DOES NOT PUBLISH. An identical verification
        # rerun writes no new document and returns non-zero, so nothing has
        # changed on disk and the second publication attempt refuses for the same
        # reason: only a human removing one of the two results resolves this.
        verify_call closure_evidence_emit "$root/results5" "$d2" "$root/pass.txt"
        chk "step6/publication/the-rerun-before-it-refuses-too" "1" "$VERIFY_RC"
        out=$(step6_publish "$publish" "$root/b.tar.gz" "$commit" "$repo" \
            "$root/results5" "$root/stage7"); rc=$?
        chk "step6/publication/the-rerun-does-not-unblock-publication" "1" "$rc"

        # THE DISAGREEMENT IS AT ITS FINAL NAME BEFORE IT EXISTS, which is what
        # four review rounds converged on. While the conflict name was created
        # LAST, some operation could always fail after a differing document
        # existed, and the reader then saw nothing under the archive key. So the
        # temporary file is reserved under the conflict prefix as soon as the
        # canonical name is known to be taken, and a conflict is never promoted,
        # copied or renamed afterwards.
        rm -rf -- "$root/results6" "$root/shim"
        mkdir -p -- "$root/results6" "$root/shim" || true
        chmod 0755 "$root/results6"
        evidence_document "$root/pass6.txt" "$d2" "$cfg"
        evidence_document "$root/divergent6.txt" "$d2" "$cfg" absent
        verify_call closure_evidence_emit "$root/results6" "$d2" "$root/pass6.txt"
        chk "step6/publication/the-canonical-result-is-written-first" "0" "$VERIFY_RC"
        # AND IT LEAVES NO CONFLICT NAME BEHIND. Every document is written under
        # the conflict name it MIGHT need, because asking whether the canonical
        # name is taken is itself the window a concurrent writer slips through.
        # The placeholder is dropped once the link has made the canonical name a
        # second name for the same bytes, so an ordinary write ends with exactly
        # one file.
        chk "step6/publication/a-first-write-leaves-no-conflict" "0" \
            "$(find "$root/results6" -maxdepth 1 -name "$d2.conflict.*" 2>/dev/null | grep -c . || true)"
        chk "step6/publication/a-first-write-leaves-one-result" "1" \
            "$(find "$root/results6" -maxdepth 1 -type f 2>/dev/null | grep -c . || true)"
        verify_call closure_evidence_emit "$root/results6" "$d2" "$root/divergent6.txt"
        chk "step6/publication/a-differing-result-refuses" "1" "$VERIFY_RC"
        chk "step6/publication/it-is-reported-at-its-conflict-name" "yes" \
            "$(printf '%s' "$VERIFY_OUT" | grep -q "^EVIDENCE|CONFLICT|$root/results6/$d2.conflict." && echo yes || echo no)"
        chk "step6/publication/exactly-one-conflict-is-beside-it" "1" \
            "$(find "$root/results6" -maxdepth 1 -name "$d2.conflict.*" 2>/dev/null | grep -c . || true)"
        # THE RETAINED BYTES ARE THE DIFFERING DOCUMENT, digested rather than
        # counted, so an empty or truncated survivor fails this case.
        chk "step6/publication/the-conflict-holds-the-differing-document" \
            "$(sha256sum -- "$root/divergent6.txt" | sed -e 's/ .*$//')" \
            "$(sha256sum -- "$(find "$root/results6" -maxdepth 1 -name "$d2.conflict.*" 2>/dev/null | sed -n 1p)" 2>/dev/null | sed -e 's/ .*$//')"
        chk "step6/publication/no-anonymous-document-is-left" "0" \
            "$(find "$root/results6" -maxdepth 1 -name '.evidence.*' 2>/dev/null | grep -c . || true)"
        out=$(step6_publish "$publish" "$root/b.tar.gz" "$commit" "$repo" \
            "$root/results6" "$root/stage9"); rc=$?
        chk "step6/publication/the-retained-conflict-stops-publication-here-too" "1" "$rc"
        verify_call closure_evidence_emit "$root/results6" "$d2" "$root/pass6.txt"
        chk "step6/publication/and-the-agreeing-rerun-refuses" "1" "$VERIFY_RC"

        # A THIRD DIFFERING RESULT GETS ITS OWN NAME, which is the prior-conflict
        # case: an earlier run's conflict cannot stand in for this one, because
        # this one reserved a name of its own before it wrote a byte.
        evidence_document "$root/third6.txt" "$d2" \
            "$(printf 'a third policy for the store\n' | sha256sum | sed -e 's/ .*$//')"
        verify_call closure_evidence_emit "$root/results6" "$d2" "$root/third6.txt"
        chk "step6/publication/a-third-result-refuses-too" "1" "$VERIFY_RC"
        chk "step6/publication/both-conflicts-are-kept" "2" \
            "$(find "$root/results6" -maxdepth 1 -name "$d2.conflict.*" 2>/dev/null | grep -c . || true)"

        # A CONCURRENT FIRST WRITER TAKES THE CANONICAL NAME WHILE THIS RUN IS
        # WRITING, which is the ordering an occupancy check cannot see coming and
        # the one the round 5 store had a fallback for. Two REAL emitters are
        # interleaved at the point that decides it, the fill of the temporary
        # file, and the injection fails conflict allocations attempted AFTER that
        # fill: a store that reserves late must make one there and a store that
        # reserved first never does. Round 6 of the review is why this is a
        # schedule rather than two sequential calls, which observe an existing
        # canonical name and never enter the race at all.
        rm -rf -- "$root/results8"; mkdir -p -- "$root/results8"; chmod 0700 "$root/results8"
        out=$(verify_interleave "$root/results8" "$d2" "$root/pass6.txt" \
            "$root/divergent6.txt" inject "$cfg")
        chk "step6/publication/the-race-loser-refuses" "differing_emit_rc=1" \
            "$(printf '%s' "$out" | grep '^differing_emit_rc=' || true)"
        chk "step6/publication/the-race-loser-keeps-its-document" "exact_differing_copies=1" \
            "$(printf '%s' "$out" | grep '^exact_differing_copies=' || true)"
        chk "step6/publication/the-race-loser-stops-publication" "publication_step2_rc=1" \
            "$(printf '%s' "$out" | grep '^publication_step2_rc=' || true)"
        chk "step6/publication/the-race-loser-stops-the-agreeing-rerun" "agreeing_rerun_rc=1" \
            "$(printf '%s' "$out" | grep '^agreeing_rerun_rc=' || true)"

        # THE SAME SCHEDULE WITHOUT THE INJECTION, which is the control that
        # keeps the case about the allocation rather than about the interleaving:
        # the loser still refuses and still stops both consumers.
        rm -rf -- "$root/results9"; mkdir -p -- "$root/results9"; chmod 0700 "$root/results9"
        out=$(verify_interleave "$root/results9" "$d2" "$root/pass6.txt" \
            "$root/divergent6.txt" control "$cfg")
        chk "step6/publication/control/the-race-loser-refuses" "differing_emit_rc=1" \
            "$(printf '%s' "$out" | grep '^differing_emit_rc=' || true)"
        chk "step6/publication/control/it-keeps-its-document" "exact_differing_copies=1" \
            "$(printf '%s' "$out" | grep '^exact_differing_copies=' || true)"
        chk "step6/publication/control/both-consumers-refuse" "1 1" \
            "$(printf '%s %s' \
                "$(printf '%s' "$out" | sed -n 's/^publication_step2_rc=//p')" \
                "$(printf '%s' "$out" | sed -n 's/^agreeing_rerun_rc=//p')")"

        # A RESERVATION THAT CANNOT BE MADE WRITES NO DIFFERING DOCUMENT AT ALL,
        # which is what closes the last shape of this finding rather than
        # arguing about where orphaned bytes should live. The injection fails
        # `mktemp` for a conflict template only, so the canonical write and
        # every other temporary file in the run still work. The run refuses, and
        # the store holds exactly what it held before: no anonymous document, no
        # conflict name, and the canonical result untouched.
        # shellcheck disable=SC2016  # the guard is the SHIM script's own text
        { printf '#!/bin/bash\n'
          printf 'for a in "$@"; do case "$a" in *.conflict.*) exit 1 ;; esac; done\n'
          printf 'exec %s "$@"\n' "$(type -P mktemp)"; } > "$root/shim/mktemp"
        chmod 0755 "$root/shim/mktemp"
        rm -rf -- "$root/results7"; mkdir -p -- "$root/results7"; chmod 0755 "$root/results7"
        verify_call closure_evidence_emit "$root/results7" "$d2" "$root/pass6.txt"
        chk "step6/publication/the-second-store-has-its-canonical-result" "0" "$VERIFY_RC"
        # shellcheck disable=SC2031  # the CHILD shell is where this PATH belongs
        PATH="$root/shim:$PATH" verify_call closure_evidence_emit "$root/results7" "$d2" \
            "$root/divergent6.txt"
        chk "step6/publication/an-unreservable-conflict-refuses" "1" "$VERIFY_RC"
        chk "step6/publication/nothing-differing-was-written" "0" \
            "$(find "$root/results7" -maxdepth 1 \( -name '.evidence.*' -o -name "$d2.conflict.*" \) 2>/dev/null | grep -c . || true)"
        chk "step6/publication/the-canonical-result-is-untouched" \
            "$(sha256sum -- "$root/pass6.txt" | sed -e 's/ .*$//')" \
            "$(sha256sum -- "$root/results7/$d2" 2>/dev/null | sed -e 's/ .*$//')"
        # AND THE STORE STILL WORKS ONCE THE INJECTION IS GONE, so the refusal
        # above is about the reservation and not about the fixture.
        verify_call closure_evidence_emit "$root/results7" "$d2" "$root/divergent6.txt"
        chk "step6/publication/control/the-unblocked-retry-retains-it" "1" "$VERIFY_RC"
        chk "step6/publication/control/and-then-publication-stops" "1" \
            "$(find "$root/results7" -maxdepth 1 -name "$d2.conflict.*" 2>/dev/null | grep -c . || true)"

        # THE CONTROL, and it is the one that makes the gate more than a name
        # test: with the conflict REMOVED, the same canonical result publishes
        # past step 2 exactly as it did before. The stop is the unresolved pair,
        # not the suffix.
        find "$root/results5" -maxdepth 1 -name "$d2.conflict.*" -delete 2>/dev/null
        out=$(step6_publish "$publish" "$root/b.tar.gz" "$commit" "$repo" \
            "$root/results5" "$root/stage8"); rc=$?
        chk "step6/publication/control/a-resolved-conflict-passes-step-2" "yes" \
            "$(printf '%s' "$out" | grep -q 'REFUSED at step 2' && echo no || echo yes)"
    fi

    # --- the payload comparison, and the archive that never gets to judge itself -
    #
    # Q12 IS CATEGORICAL. The embedded copies are compared and REPORTED, and never
    # executed to produce evidence, including when they are byte-identical:
    # equality makes two files equivalent and does not make a candidate-supplied
    # script an independent judge.
    section "step 6 payload: compared, reported, and never executed"
    root="$dir/payload"
    rm -rf -- "$root"
    mkdir -p -- "$root/archive/tools/bin" "$root/archive/tools/closure" || true
    for name in "${CLOSURE_MODULES[@]}"; do
        cp -- "$src/$name" "$root/archive/tools/bin/$name"
    done
    cp -- "$src/../closure/closure-config.txt" "$root/archive/tools/closure/closure-config.txt"
    cp -- "$src/../closure/closure-envelope.txt" "$root/archive/tools/closure/closure-envelope.txt"
    tar -czf "$root/identical.tar.gz" -C "$root/archive" tools 2>/dev/null
    if [ -d "$dir/ws" ]; then
        out=$(verify_payload "$root/identical.tar.gz" "$dir/ws" "$root/scratch1")
        chk "step6/payload/identical-copies-are-reported-identical" "5" \
            "$(printf '%s' "$out" | grep -c '|identical$' || true)"
        chk "step6/payload/no-difference-is-summarised" "yes" \
            "$(printf '%s' "$out" | grep -q '^PAYLOAD|SUMMARY|0$' && echo yes || echo no)"

        # A COPY THAT DIFFERS is a payload property and not a refusal: the run
        # still produces its evidence, from the WORKSPACE copy.
        printf '\n# an edit nobody reviewed\n' >> "$root/archive/tools/bin/closure_rules.sh"
        tar -czf "$root/different.tar.gz" -C "$root/archive" tools 2>/dev/null
        out=$(verify_payload "$root/different.tar.gz" "$dir/ws" "$root/scratch2")
        chk "step6/payload/an-edited-copy-is-reported-different" "yes" \
            "$(printf '%s' "$out" | grep -q '^PAYLOAD|closure_rules.sh|differs$' && echo yes || echo no)"
        chk "step6/payload/the-others-are-still-identical" "4" \
            "$(printf '%s' "$out" | grep -c '|identical$' || true)"
        chk "step6/payload/the-difference-is-summarised" "yes" \
            "$(printf '%s' "$out" | grep -q '^PAYLOAD|SUMMARY|1$' && echo yes || echo no)"

        # AN ABSENT COPY is reported rather than assumed, so an archive that ships
        # no payload is distinguishable from one whose payload agrees.
        rm -f -- "$root/archive/tools/bin/closure_elf.sh"
        tar -czf "$root/absent.tar.gz" -C "$root/archive" tools 2>/dev/null
        out=$(verify_payload "$root/absent.tar.gz" "$dir/ws" "$root/scratch3")
        chk "step6/payload/an-absent-copy-is-reported-absent" "yes" \
            "$(printf '%s' "$out" | grep -q '^PAYLOAD|closure_elf.sh|absent$' && echo yes || echo no)"

        # THE ORACLE FOR "NEVER EXECUTED", and it is the only one that can fail
        # for the right reason. An embedded copy that would leave a mark if it
        # ran is planted, the comparison is performed, and the mark is asked for:
        # a comparison that quietly executed what it compared would leave it.
        rm -rf -- "$root/archive/tools/bin"; mkdir -p -- "$root/archive/tools/bin"
        for name in "${CLOSURE_MODULES[@]}"; do
            printf '#!/bin/bash\nprintf x > %s\n' "$root/EXECUTED" > "$root/archive/tools/bin/$name"
        done
        tar -czf "$root/marked.tar.gz" -C "$root/archive" tools 2>/dev/null
        out=$(verify_payload "$root/marked.tar.gz" "$dir/ws" "$root/scratch4")
        chk "step6/payload/a-planted-copy-is-reported-different" "5" \
            "$(printf '%s' "$out" | grep -c '|differs$' || true)"
        chk "step6/payload/and-it-was-never-executed" "no" \
            "$( [ -e "$root/EXECUTED" ] && echo yes || echo no )"
    else
        fail "step6/payload/delivery-fixture" "the delivery fixture at $dir/ws was not built"
    fi

    # --- the whole driver, once, over an archive the gate produced --------------
    #
    # EVERY CASE ABOVE DRIVES ONE HALF. This one runs the file the Debian job runs,
    # over an archive packaging actually made, into a prefix the installer
    # actually fills, and it is the only case that can say the halves compose.
    section "step 6 end to end: one archive, two observations, one artifact"
    root="$dir/e2e"
    rm -rf -- "$root"
    mkdir -p -- "$root/home" "$root/prefix" "$root/results" || true
    chmod 0755 "$root/results"
    if ! step5_make_tree "$root/home"; then
        fail "step6/e2e/fixture" "cannot build the payload tree at $root/home"
    elif ! step5_make_deployed_tree "$root/home/cplx" "$src"; then
        fail "step6/e2e/deployed" "cannot deploy the checker beside the payload"
    else
        rm -f -- "$root/home/tools/python/root/lib/libsqlite3.so.0"
        rm -rf -- "$root/home/tools/closure"
        # THE DEPLOYED ENVELOPE NAMES THE FIXTURE COMMIT, so the publication
        # cases below can resolve the declaration this archive carries. The
        # committed envelope names a cplx commit this suite has no checkout of,
        # and publication would refuse at STEP 1 for that reason while a case
        # claiming to measure step 2 read the refusal as its own.
        step2_write_envelope "$root/home/cplx/closure/closure-envelope.txt" \
            "$(config_digest "$root/home/cplx/closure/closure-config.txt")" \
            "src/setups/env/closure/closure-config.txt" "$commit"
        HOME="$root/home" bash "$root/home/cplx/bin/pkg.sh" tools --closure-gate \
            > "$root/pkg.log" 2>&1
        out=$(find "$root/home/pkgs" -name 'tools.*.tar.gz' -type f 2>/dev/null | sort | tail -1)
        if [ -z "$out" ]; then
            fail "step6/e2e/archive-exists" "the gate produced no archive to verify"
        elif [ ! -d "$dir/ws" ]; then
            fail "step6/e2e/delivery" "the delivery fixture at $dir/ws was not built"
        else
            id=$(sha256sum -- "$out" | sed -e 's/ .*$//')
            # HOME IS THE FIXTURE'S, and it is not tidiness. The installer
            # discovers `<target>.*.tar.gz` across the prefix, its package
            # directory, HOME and HOME/pkgs, so a run that inherited the real
            # account's HOME would be asking a question about whatever archives
            # that account happens to hold.
            e2e_out=$(HOME="$root/home" bash "$verify" --archive "$out" --prefix "$root/prefix" \
                --results "$root/results" --tools "$dir/ws" --target tools 2>&1)
            e2e_rc=$?
            chk "step6/e2e/the-delivery-is-reported-present" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^DELIVERY|PRESENT|' && echo yes || echo no)"
            chk "step6/e2e/the-identity-is-the-archive-file" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q "^ARCHIVE|$out|$id\$" && echo yes || echo no)"
            chk "step6/e2e/an-artifact-was-written" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^EVIDENCE|WRITTEN|' && echo yes || echo no)"
            chk "step6/e2e/it-is-keyed-by-the-identity" "yes" \
                "$( [ -f "$root/results/$id" ] && echo yes || echo no )"
            # THE ARTIFACT SATISFIES ITS OWN CONTRACT, read back by the shared
            # reader rather than by this suite: a producer whose output its own
            # parser refuses is the defect this asserts against.
            verify_call closure_evidence_parse "$root/results/$id"
            chk "step6/e2e/the-artifact-parses" "0" "$VERIFY_RC"
            chk "step6/e2e/it-names-this-archive-and-nothing-else" "yes" \
                "$(verify_model "$root/results/$id" | grep -q "^$id|" && echo yes || echo no)"
            # NO PROCESS WAS NAMED, so the live half is INCONCLUSIVE and the RUN
            # is not a pass. That is the develop#20 rule applied to the driver:
            # a reading nobody took never counts toward a green.
            chk "step6/e2e/an-unnamed-process-is-inconclusive" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^LIVE|INCONCLUSIVE|' && echo yes || echo no)"
            chk "step6/e2e/an-inconclusive-live-half-is-not-a-pass" "yes" \
                "$( [ "$e2e_rc" -ne 0 ] && echo yes || echo no )"
            # THE COMPARISON PASSES, which is this case's own subject: the
            # skeleton the archive describes and the tree the installer produced
            # carry the same declared candidate directories.
            chk "step6/e2e/the-comparison-passes" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^COMPARISON|PASS$' && echo yes || echo no)"
            # AND THE STATIC HALF REFUSES, which is a property of this FIXTURE
            # rather than a gap. The tree above has its waived floor member
            # removed so the archive is the one step 5 publishes against, and a
            # checker that passed over it would be the finding. Asserting the
            # refusal is what stops this case reading a green from a half it
            # never looked at.
            chk "step6/e2e/the-static-half-refuses-on-this-fixture" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^STATIC|REFUSED$' && echo yes || echo no)"
            chk "step6/e2e/the-payload-copies-agree" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^PAYLOAD|SUMMARY|0$' && echo yes || echo no)"
            # A SECOND RUN OVER THE SAME ARCHIVE IS IDEMPOTENT, which is the
            # occupancy rule reached through the driver rather than through the
            # emitter alone.
            e2e_out=$(HOME="$root/home" bash "$verify" --archive "$out" --prefix "$root/prefix" \
                --results "$root/results" --tools "$dir/ws" --target tools 2>&1)
            chk "step6/e2e/a-second-run-is-idempotent" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^EVIDENCE|IDEMPOTENT|' && echo yes || echo no)"

            # --- the archive the installer actually installed --------------------
            #
            # THE INSTALLER IS ASKED FOR A TARGET AND NOT FOR A FILE, and round 1
            # of this review measured what that costs. It keeps the NEWEST
            # `<target>.*.tar.gz` across the prefix, its package directory, HOME
            # and HOME/pkgs, so a competing future-dated archive is installed
            # instead of the copy this run placed, and the post-install
            # observation then belongs to bytes nothing here digested. The
            # installer's interface is frozen and no argument selects a file, so
            # the driver checks the selection on both sides of the call.
            printf 'a competing candidate\n' > "$root/home/tools/competitor.txt"
            mkdir -p -- "$root/home/pkgs" "$root/results-sel" || true
            chmod 0755 "$root/results-sel"
            tar -czf "$root/home/pkgs/tools.2099-01-01_000000.tar.gz" \
                -C "$root/home" tools 2>/dev/null
            touch -d '2099-01-01 00:00:00' \
                "$root/home/pkgs/tools.2099-01-01_000000.tar.gz" 2>/dev/null
            e2e_out=$(HOME="$root/home" bash "$verify" --archive "$out" --prefix "$root/prefix-sel" \
                --results "$root/results-sel" --tools "$dir/ws" --target tools 2>&1)
            e2e_rc=$?
            chk "step6/e2e/a-competing-newer-archive-refuses" "1" "$e2e_rc"
            chk "step6/e2e/it-names-the-archive-that-would-win" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q 'which is newer than the candidate' && echo yes || echo no)"
            chk "step6/e2e/it-refuses-before-it-installs-anything" "no" \
                "$( [ -d "$root/prefix-sel/tools" ] && echo yes || echo no )"
            chk "step6/e2e/no-result-is-emitted-for-an-unselected-candidate" "no" \
                "$( [ -e "$root/results-sel/$id" ] && echo yes || echo no )"

            # THE CONTROL: with the competitor removed the same run installs and
            # compares, so the refusal above is about the competing archive and
            # not about the fresh prefix.
            rm -f -- "$root/home/pkgs/tools.2099-01-01_000000.tar.gz"
            e2e_out=$(HOME="$root/home" bash "$verify" --archive "$out" --prefix "$root/prefix-sel" \
                --results "$root/results-sel" --tools "$dir/ws" --target tools 2>&1)
            chk "step6/e2e/control/the-candidate-alone-installs" "yes" \
                "$( [ -d "$root/prefix-sel/tools" ] && echo yes || echo no )"
            chk "step6/e2e/control/the-comparison-is-reached" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^COMPARISON|PASS$' && echo yes || echo no)"

            # A RERUN MUST REALLY INSTALL, which the done marker was quietly
            # deciding. The installer SKIPS an archive whose marker exists and
            # exits 0 without unpacking, so the observation taken afterwards
            # describes whatever tree was already there. The marker is planted
            # under a FRESH prefix, where a skipped install leaves no tree at all.
            mkdir -p -- "$root/prefix-marker/pkgs" "$root/results-marker" || true
            chmod 0755 "$root/results-marker"
            : > "$root/prefix-marker/pkgs/tools.verify-${id:0:12}.done"
            e2e_out=$(HOME="$root/home" bash "$verify" --archive "$out" --prefix "$root/prefix-marker" \
                --results "$root/results-marker" --tools "$dir/ws" --target tools 2>&1)
            chk "step6/e2e/a-stale-done-marker-does-not-skip-the-install" "yes" \
                "$( [ -d "$root/prefix-marker/tools" ] && echo yes || echo no )"
            chk "step6/e2e/the-comparison-is-taken-over-a-real-install" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^COMPARISON|PASS$' && echo yes || echo no)"

            # AND A REMOVAL THAT FAILED IS NOT A REMOVAL, which round 2 of this
            # review reproduced with real filesystem permissions and the real
            # installer. A package directory that refuses the unlink still lets
            # the candidate file be OVERWRITTEN, so the copy succeeds, the stale
            # marker survives, the installer skips, and the check after the call
            # then reads that same stale marker as proof of an install this run
            # never made. The tree left behind is the older one, and the run was
            # emitting a PASS artifact keyed to the candidate over it.
            rm -rf -- "$root/prefix-stale"
            mkdir -p -- "$root/prefix-stale/pkgs" "$root/prefix-stale/tools/stale" \
                "$root/results-stale" || true
            chmod 0755 "$root/results-stale"
            cp -- "$out" "$root/prefix-stale/pkgs/tools.verify-${id:0:12}.tar.gz"
            : > "$root/prefix-stale/pkgs/tools.verify-${id:0:12}.done"
            chmod 0555 "$root/prefix-stale/pkgs"
            e2e_out=$(HOME="$root/home" bash "$verify" --archive "$out" --prefix "$root/prefix-stale" \
                --results "$root/results-stale" --tools "$dir/ws" --target tools 2>&1)
            e2e_rc=$?
            chmod 0755 "$root/prefix-stale/pkgs"
            chk "step6/e2e/an-unremovable-stale-marker-refuses" "1" "$e2e_rc"
            chk "step6/e2e/the-refusal-names-the-marker-it-could-not-remove" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q 'could not be removed' && echo yes || echo no)"
            chk "step6/e2e/no-comparison-is-reported-over-a-skipped-install" "no" \
                "$(printf '%s' "$e2e_out" | grep -q '^COMPARISON|' && echo yes || echo no)"
            chk "step6/e2e/no-artifact-is-emitted-over-a-skipped-install" "no" \
                "$( [ -e "$root/results-stale/$id" ] && echo yes || echo no )"
            chk "step6/e2e/the-older-tree-was-left-alone" "yes" \
                "$( [ -d "$root/prefix-stale/tools/stale" ] && echo yes || echo no )"
            # THE CONTROL CHANGES ONE THING, the directory's writability, so the
            # refusal above is about the removal and not about the fixture.
            e2e_out=$(HOME="$root/home" bash "$verify" --archive "$out" --prefix "$root/prefix-stale" \
                --results "$root/results-stale" --tools "$dir/ws" --target tools 2>&1)
            chk "step6/e2e/control/a-writable-package-directory-installs" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q '^COMPARISON|PASS$' && echo yes || echo no)"
            chk "step6/e2e/control/and-then-the-artifact-is-written" "yes" \
                "$( [ -e "$root/results-stale/$id" ] && echo yes || echo no )"

            # AND THE GATE ON THE OTHER SIDE OF THE CALL, which the pre-check
            # cannot reach on its own: an installer that returns success without
            # having processed this candidate leaves no marker for it, and the
            # driver refuses rather than observing a tree it cannot attribute.
            # The stand-in SOURCES the real installer, so the scope derivation on
            # both sides is still the installer's own `build_elf_rpath`; only the
            # execution path is replaced, because a tie in modification time or a
            # race is the only way the real one reaches this state and neither is
            # something a case can arrange.
            rm -rf -- "$root/ws-shim"
            mkdir -p -- "$root/ws-shim" "$root/results-shim" || true
            chmod 0755 "$root/results-shim"
            cp -- "$dir/ws"/* "$root/ws-shim/" 2>/dev/null
            { printf '#!/bin/bash\n'
              printf '# shellcheck source=/dev/null\n'
              printf 'source "%s" || exit 1\n' "$dir/ws/install_pkg.sh"
              # shellcheck disable=SC2016  # the guard is the CHILD script's
              printf 'if [ "${BASH_SOURCE[0]}" != "$0" ]; then return 0; fi\n'
              printf 'mkdir -p -- "%s/tools"\n' "$root/prefix-shim"
              printf 'exit 0\n'; } > "$root/ws-shim/install_pkg.sh"
            chmod 0755 "$root/ws-shim/install_pkg.sh"
            e2e_out=$(HOME="$root/home" bash "$verify" --archive "$out" --prefix "$root/prefix-shim" \
                --results "$root/results-shim" --tools "$root/ws-shim" --target tools 2>&1)
            e2e_rc=$?
            chk "step6/e2e/an-installer-that-installed-something-else-refuses" "1" "$e2e_rc"
            chk "step6/e2e/the-refusal-names-the-missing-marker" "yes" \
                "$(printf '%s' "$e2e_out" | grep -q 'installed some other tools archive' && echo yes || echo no)"
            chk "step6/e2e/no-artifact-is-emitted-for-an-unattributable-tree" "no" \
                "$( [ -e "$root/results-shim/$id" ] && echo yes || echo no )"

            # PUBLICATION, DRIVEN BY THE ARTIFACT THIS RUN EMITTED. Every other
            # publication case in this suite hands the gate a document the
            # harness wrote, which is the shape step 5 already had and the shape
            # step 6 exists to replace. This is the pair that closes the loop:
            # one side WROTE the result and the other READS it, and neither was
            # built to agree with the other.
            #
            # THE ASSERTION IS THAT STEP 2 IS PASSED, not that publication
            # succeeds. This archive is a validation artifact by construction,
            # its waived floor member having been removed above, so the run
            # refuses later. Reading a green here would be reading the wrong
            # thing; reading WHICH STEP refused is what says step 2 was
            # satisfied rather than skipped.
            e2e_pub=$(step6_publish "$publish" "$out" "$commit" "$repo" \
                "$root/results" "$root/stage-produced")
            chk "step6/e2e/a-produced-artifact-passes-step-2" "yes" \
                "$(printf '%s' "$e2e_pub" | grep -q 'REFUSED at step 2' && echo no || echo yes)"
            chk "step6/e2e/publication-then-reaches-a-later-step" "yes" \
                "$(printf '%s' "$e2e_pub" | grep -qE 'REFUSED at step (3|4)' && echo yes || echo no)"

            # AND THE SAME ARTIFACT WITH A DIFFERENT ARCHIVE IS REFUSED, which is
            # the identity binding read from the other side: the result names
            # these bytes and publication computes those. Archive B carries the
            # same bundle, so its refusal at STEP 2 rather than at step 1 is what
            # proves the declaration resolved and the IDENTITY is what failed.
            printf 'a second candidate\n' > "$root/home/tools/marker.txt"
            tar -czf "$root/other.tar.gz" -C "$root/home" tools 2>/dev/null
            e2e_pub=$(step6_publish "$publish" "$root/other.tar.gz" "$commit" "$repo" \
                "$root/results" "$root/stage-other")
            chk "step6/e2e/another-archive-is-not-described-by-it" "yes" \
                "$(printf '%s' "$e2e_pub" | grep -q 'REFUSED at step 2' && echo yes || echo no)"
            chk "step6/e2e/the-refusal-names-the-computed-identity" "yes" \
                "$(printf '%s' "$e2e_pub" | grep -q "keyed to archive identity $(sha256sum -- "$root/other.tar.gz" | sed -e 's/ .*$//')" && echo yes || echo no)"
        fi
    fi
}


# ============================================================== the step 7 suite ===
# THE LAST STEP THAT ADDS PRODUCTION CODE, and the one where the surface is read
# against the ISSUE'S ACCEPTANCE rather than against its own step. It has two
# halves answering to different things:
#
#   THE D10 INTERFACE, which is host-independent. The policy is a comparison over
#   two capability entries and a required-node set, so its nine cases are asked
#   anywhere, and its evidence half is asked over planted ELF fixtures the same
#   way steps 3 and 4 ask theirs.
#
#   THE ACCEPTANCE, which is not. A positive result on the distribution the
#   defect exists on, plus the packaging run on the build account, and neither
#   host can take the other's half. `step_host` gates this step to `both` and the
#   host gate resolves which half THIS machine answers; the suite then requires
#   the other half as a RETAINED CAPTURE, so a run is green only where one half
#   was taken live and the other was taken by somebody else and kept.
#
# WHY THE POLICY CASES PLANT A MODEL RATHER THAN A TOOLCHAIN. The nine rows of
# the design's D10 table are about a comparison between two CAPABILITY ENTRIES,
# and asking them from real GCC 11 and GCC 12 installations would make the case
# set depend on which toolsets a host happens to carry: the row that needs a node
# NEITHER generation defines could then never be asked at all, since that is not
# a shape a real pair of libraries takes. So the model is planted, every plant is
# asserted before it is judged, and the EVIDENCE half beside them is what proves
# a real reading produces the same model.

# One call into the D10 module over a planted model, sourced rather than
# executed, which is the seam its main boundary exists for. The plant is a
# snippet of assignments run in the same child shell, so a case measures the
# function it names over a shape it created in the same process.
d10_run() {
    local plant="$1" fn="$2"
    shift 2
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    D10_OUT=$("${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        eval "$2" || exit 94
        fn="$3"
        shift 3
        declare -F "$fn" >/dev/null 2>&1 || exit 92
        "$fn" "$@"
    ' _ "$SHIPPED_DIR/closure_d10.sh" "$plant" "$fn" "$@" 2>&1)
    D10_RC=$?
}

# The planted model, written as the assignments the module's own reset leaves
# behind. `required` and `defines` are space-separated keys of exactly the shape
# the module stores them in, so a case that plants a key the module would never
# produce is visible in the case rather than buried in a builder.
d10_plant() {
    local reading="$1" consumers="$2" required="$3" defines="$4" key i=0
    printf 'closure_d10_reset;'
    printf 'CLOSURE_D10_READING=%s;' "$reading"
    printf 'CLOSURE_D10_CANDIDATES=(gcc-11 gcc-12);'
    while [ "$i" -lt "$consumers" ]; do
        printf 'CLOSURE_D10_CONSUMERS+=(consumer-%s.so);' "$i"
        i=$((i + 1))
    done
    for key in $required; do
        printf 'CLOSURE_D10_SEEN["%s"]=1;CLOSURE_D10_REQUIRED+=("%s");' "$key" "$key"
    done
    for key in $defines; do
        printf 'CLOSURE_D10_DEFINES["%s"]=1;' "$key"
    done
}

# The planted model read back from the module's own globals, so a case asserts
# its plant took before it judges the answer. A case that reported a shape it
# never created is the one failure a policy suite cannot catch from its verdict,
# because a wrong model still produces a plausible-looking result.
#
# IT PRINTS FROM THE HARNESS AND NOT FROM THE MODULE. A production file does not
# grow a function whose only caller is a test, so the four fields are read here
# through the same sourcing seam every other case uses.
d10_model() {
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        eval "$2" || exit 94
        printf "%s|%s|%s|%s" "$CLOSURE_D10_READING" \
            "${#CLOSURE_D10_CONSUMERS[@]}" "${#CLOSURE_D10_REQUIRED[@]}" \
            "${CLOSURE_D10_CANDIDATES[*]}"
    ' _ "$SHIPPED_DIR/closure_d10.sh" "$1" 2>/dev/null
}

# The two candidate directories and the archive tree the EVIDENCE half is read
# from. Each provider is a donor copy carrying exactly the records its role
# needs: a soname in name slot 0 so the archive-side lookup finds it, and one
# version DEFINITION in slot 1. A consumer carries a version NEED in slots 1 and
# 2, with the matching DT_NEEDED the setter adds, so the two roles never collide
# over a slot and no file is given both.
step7_provider() {
    local path="$1" soname="$2" node="$3"
    mkdir -p -- "${path%/*}" || return 1
    fixture_copy_donor "$DONOR_SHARED" "$path" || return 1
    elf_set_string_entry "$path" SONAME "$soname" || return 1
    elf_set_verdef "$path" "$node" || return 1
}

step7_consumer() {
    local path="$1" provider="$2" node="$3"
    mkdir -p -- "${path%/*}" || return 1
    fixture_copy_donor "$DONOR_SHARED" "$path" || return 1
    elf_set_verneed "$path" "$provider" "$node" || return 1
}

# One field of the PRINTED reading, taken from the reading itself rather than
# from the module's globals: what a person reads in a retained capture and what a
# case asserts have to be the same text, or the capture is a second rendering
# nobody checked.
step7_reading_field() {
    printf '%s\n' "$1" | grep -E "^  $2 " | sed -e "s/^  $2  *//" -e 's/[[:space:]]*$//'
}

# THE NEGATIVE-CONTROL INVENTORY: the issue's nine independently refusable
# invariants plus the four this design adds, each paired with the case name that
# refuses it. The waiver row names two cases, because the issue's fixture for it
# is "an unknown waiver, AND a stale one" and one of them would leave the other
# unasserted.
#
# THEY ARE LOOKED UP IN THIS HARNESS'S OWN TEXT rather than restated, so the
# obligation survives its own suites: a control renamed or deleted in step 3, 4,
# 5 or 6 is a finding HERE, which is what a per-invariant obligation has to mean
# once the controls belong to somebody else's step.
STEP7_CONTROLS=(
    "declared floor|step4/floor/absent-member-named"
    "floor location|step4/floor/location-member-named"
    "derived closure|step3/membership/names-subject-and-name"
    "provider version need|step4/coherence/refusal-names-subject-need-and-provider"
    "no host fallback|step6/live/a-host-object-refuses"
    "duplicate provider, rule 1|step4/duplicates/refusal-names-name-and-both-paths"
    "declared family generation, rule 2|step4/families/refusal-names-both-generations"
    "waiver contract|step5/waiver/unknown-is-named step5/waiver/stale-is-named"
    "trace conclusiveness|step6/live/an-empty-inventory-is-inconclusive"
    "an unexpected directory or root|step1/unexpected-root/named"
    "a divergent presence comparison|step6/publication/a-divergent-result-refuses"
    "a configuration digest publication did not resolve|step5/publication/changed-config-refuses"
    "a coherence answer surviving a rule 1 refusal|step4/duplicates/coherence-still-answers"
)

# The case name a control claims, looked up in this file AS A QUOTED CASE NAME.
# The quotes are what keep the inventory from satisfying itself: an entry above
# writes `"<invariant>|<case>"`, so the case name there is never preceded by a
# quote of its own and never matches this pattern.
step7_control_exists() {
    local name="$1"
    grep -qF "\"$name\"" "$0"
}

# The retained capture of the OTHER host, and what makes it evidence rather than
# a file with the right name. It names its host, it carries a date, and it shows
# THAT HOST'S OWN HALF PASSING: a capture of a run that refused is a record of a
# refusal, and reading it as the other half being answered is the "unavailable is
# not negative" mistake taken in reverse.
#
# IT ASKS FOR THE HALF AND NOT FOR THE STEP, and that distinction is the whole
# reason this function exists rather than a grep for the verdict line. Requiring
# the other capture to report the STEP met deadlocks the pair by construction:
# whichever host runs first is unanswered for want of the second capture, so its
# own capture never carries that line, so the second host rejects it and is
# unanswered too, and no order of runs ever escapes. Asking for the half that
# host could actually take is both weaker and correct, and it is what makes the
# plan's own completion criteria reachable: the build host answers its half and
# stays unanswered on the pair, the agent then answers its half with that capture
# beside it and is green end to end.
#
# AND THE FIRST VERSION OF THIS GATE PASSED ON A CAPTURE THAT PROVED NOTHING,
# WHICH IS MEASURED RATHER THAN FEARED. It grepped the capture for the sentence
# `OBJECTIVE MET for step 7`, and a retained capture CONTAINS THIS HARNESS'S OWN
# DIAGNOSTIC TEXT: the unanswered message below names the string it is looking
# for, the capture records that message, and the next run matched its own
# instructions. Debian build 152 is where that PASS was observed, over a RHEL
# capture whose step 7 was unanswered.
#
# So the pattern is a CASE RESULT LINE and not prose: a name, whitespace, then
# the literal uppercase PASS this file prints for a case and nothing else does.
# The diagnostic below deliberately says "passing" in lower case for the same
# reason, so a capture carrying the instruction cannot satisfy the instruction.
step7_capture_answers() {
    local path="$1" host="$2" expected="${3:-}" snapshot sha digest rc=1
    [ -f "$path" ] || return 1
    sha=$(type -P sha256sum) || return 1
    snapshot=$(mktemp "$SCRATCH/step7-capture.XXXXXX") || return 1
    # Hash and inspect the same retained bytes, even if the source path is
    # replaced between checks. Record refused captures as well as passing ones.
    if ! cp -- "$path" "$snapshot" || ! digest=$("$sha" < "$snapshot"); then
        rm -f -- "$snapshot"
        return 1
    fi
    note "step7/acceptance/$host-capture-sha256" "${digest%% *} from $path"
    if grep -qi "^Target: .*$host" "$snapshot" \
       && grep -qE '^Captured: .*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' "$snapshot" \
       && grep -qE "step7/acceptance/$host-half +PASS" "$snapshot" \
       && { [ -z "$expected" ] || grep -qE "^  step7/acceptance/candidate-sha256 +NOTE  $expected$" "$snapshot"; }; then
        rc=0
    fi
    rm -f -- "$snapshot"
    return "$rc"
}

# The prefix this account really packages or installs under, which is the
# acceptance's subject and is NEVER a fixture. It is RESOLVED rather than
# assumed: an account with no such tree is a host that cannot answer its own
# half, and saying so is the difference between an acceptance and a rehearsal.
step7_real_prefix() {
    local candidate
    for candidate in "${CPLX_ACCEPTANCE_PREFIX:-}" "${HOME:-}"; do
        [ -n "$candidate" ] || continue
        if [ -d "$candidate/tools" ]; then printf '%s' "$candidate"; return 0; fi
    done
    return 1
}

# THE REAL PACKAGED ARCHIVE, which is the Debian half's subject and is a
# different thing from the tree the RHEL half judges. `pkg.sh` writes
# `<folder>.<timestamp>.tar.gz` under `~/pkgs/` and keeps `<folder>.latest.tar.gz`
# pointing at the newest, so the latest link is what an acceptance names. An
# account with none has no artifact to verify, and that is the honest answer
# rather than a fixture stood in for one.
step7_real_archive() {
    local candidate
    if [ -n "${CPLX_ACCEPTANCE_ARCHIVE:-}" ]; then
        [ -r "$CPLX_ACCEPTANCE_ARCHIVE" ] || return 1
        printf '%s' "$CPLX_ACCEPTANCE_ARCHIVE"
        return 0
    fi
    for candidate in "${CPLX_ACCEPTANCE_ARCHIVE:-}" "${HOME:-}/pkgs/tools.latest.tar.gz"; do
        case "$candidate" in ''|'/pkgs/tools.latest.tar.gz') continue ;; esac
        if [ -r "$candidate" ]; then printf '%s' "$candidate"; return 0; fi
    done
    return 1
}

# THERE IS NO PROCESS-NAME HELPER ANY MORE, and its absence is the point rather
# driver is the AUTHORITATIVE one delivered beside this harness and never a copy
# out of the candidate, which is the whole of what the topology's trust boundary
# means here.

# Live controls call the authoritative observer over the same installed
# candidate with isolated process inputs. They do not invoke installation.
# Step 6 retains the independent reinstall, marker and corruption controls.
step7_observe_control() {
    "${BASH:-bash}" "$SHIPPED_DIR/closure_observe_live.sh" \
        --prefix "$1" --process "$2" --proc "$3" 2>&1
}

step7_verify_archive() {
    local archive="$1" root="$2" process="$3" proc="${4:-/proc}"
    rm -rf -- "$root"
    mkdir -p -- "$root/prefix" "$root/results" || return 1
    "${BASH:-bash}" "$SHIPPED_DIR/closure_verify.sh" --archive "$archive" \
        --prefix "$root/prefix" --results "$root/results" \
        --tools "$SHIPPED_DIR" --target tools \
        --process "$process" --proc "$proc" 2>&1
}

# Q15 accepts only a fully determined report with no refusal. Exit 3 is
# permitted solely for the one active sqlite waiver; it never certifies release.
step7_q15_accepts() {
    local rc="$1" report="$2" waived
    case "$rc" in 0|3) ;; *) return 1 ;; esac
    printf '%s\n' "$report" | grep -qE '^  unexpected +0$' || return 1
    printf '%s\n' "$report" | grep -qE '^  undetermined +0$' || return 1
    printf '%s\n' "$report" | grep -qE '^  refused +0 unresolvable DT_NEEDED$' || return 1
    if printf '%s\n' "$report" | grep -qE '^(REFUSED|UNDETERMINED|UNEXPECTED)\||[1-9][0-9]* refused'; then
        return 1
    fi
    waived=$(printf '%s\n' "$report" | grep '^WAIVED|' || true)
    if [ "$rc" -eq 0 ]; then [ -z "$waived" ]; return; fi
    [ "$(printf '%s\n' "$waived" | wc -l)" -eq 1 ] || return 1
    case "$waived" in 'WAIVED|waiver|libsqlite3.so.0|python-sqlite-support|active:'*) ;; *) return 1 ;; esac
    printf '%s\n' "$report" | grep -qE '^  waivers +1 declared, 1 active, 0 refused$'
}

# The interpreter INSIDE the candidate installation, which is the only one whose
# mapped objects can be under the candidate prefix. A host interpreter maps its
# own libraries from outside and the observer refuses it, correctly.
step7_candidate_interpreter() {
    local prefix="$1" elf_only="${2:-no}" candidate resolved magic python_root
    python_root=$(readlink -f -- "$prefix/tools/python") || return 1
    # The application provisions its venv with the relocated ELF directly.
    # The shipped shell wrapper bootstraps links with host helpers and cannot
    # be used on Debian while it exports the bundled glibc search path.
    for candidate in "$prefix"/tools/python/current/bin/python3*_bin \
                     "$prefix"/tools/python/current/bin/python3 \
                     "$prefix"/tools/python/root/usr/bin/python3; do
        [ -f "$candidate" ] || continue
        [ -x "$candidate" ] || continue
        resolved=$(readlink -f -- "$candidate") || continue
        case "$resolved" in "$python_root"/*) ;; *) continue ;; esac
        magic=""
        IFS= read -r -N 4 magic < "$resolved" || continue
        [ "$magic" = $'\177ELF' ] || continue
        printf '%s' "$resolved"
        return 0
    done
    [ "$elf_only" = yes ] && return 1
    # Wrapper-shaped fixtures still exercise descendant ownership and cleanup;
    # real archive acceptance requires the ELF branch above.
    for candidate in "$prefix"/tools/python/current/bin/python3 \
                     "$prefix"/tools/python/root/usr/bin/python3 \
                     "$prefix"/tools/python/current/bin/python; do
        if [ -x "$candidate" ]; then printf '%s' "$candidate"; return 0; fi
    done
    return 1
}

# THE LIVE HALF, TAKEN AGAINST A PROCESS THIS BRANCH CREATED FROM THE CANDIDATE,
# and round 2 of the step 7 review is why it exists at all. The branch used to
# pass the process NAME into `closure_verify.sh`, which installs and observes in
# ONE call: at observation time no process from the candidate had been started,
# so the conclusive answer was unreachable by construction. A name alone selects
# nothing, and any host process answering to it maps its libraries from outside
# the candidate and is refused, which is the observer being right.
#
# THE ATTRIBUTION IS THE ARGV0 AND NOT THE COMMAND NAME. Several interpreters
# called `python3` may run on an agent, and the observer matches `comm` OR the
# basename of `argv0`. Launching the candidate's own interpreter under a unique
# argv0 is what makes the inventory provably about THIS installation rather than
# about whatever else answers to the same name.
#
# THERE IS NO OPERATOR-NAMED ALTERNATIVE ANY MORE. Round 5 removed it: it
# returned the observer output with no OWNED record, so the acceptance failed
# three assertions on it and the mode could never produce a passing half.
#
# It prints the observer's WHOLE output, the `PROCESS`, `OBJECT`, `HOSTS` and
# `LIVE` records alike, because round 2 also found the branch retaining summary
# verdicts where the issue asks for the trace itself.
# The parent of one process, read from `/proc/<pid>/status` rather than from
# `stat`, whose second field is a command name that may itself contain spaces
# and brackets and would shift every field after it.
# THE READABILITY TEST COMES FIRST, and it is not decoration. Scanning `/proc`
# races every process that exits during the scan, and a redirect from a file
# that vanished prints the shell's own diagnostic no matter what the compound
# command redirects: the Debian agent filled its capture with
# `/proc/<pid>/status: No such file or directory` for pids that had simply gone.
# A process that disappeared has no parent to report, which is a `return 1` and
# not a message.
step7_parent_of() {
    local key value
    [ -r "/proc/$1/status" ] || return 1
    while IFS=: read -r key value; do
        if [ "$key" = "PPid" ]; then printf '%s' "${value//[[:space:]]/}"; return 0; fi
    done < "/proc/$1/status" 2>/dev/null
    return 1
}

# IS THIS PID STILL A RUNNING PROCESS, as opposed to absent or a zombie. The
# distinction is not pedantry here and the Debian agent is what established it.
#
# A killed orphan is reparented to PID 1 and stays in `/proc` as a ZOMBIE until
# something reaps it. In a container whose PID 1 is the job's own command rather
# than an init that reaps, nothing ever does, so a directory test waits forever
# for a disappearance that will not happen. The build host, with a real init,
# reaped within milliseconds and passed the same test.
#
# A zombie holds no memory, maps nothing and runs nothing. For the only question
# this harness asks, whether it leaked a live process, a zombie is gone.
step7_process_live() {
    local key value state=""
    [ -n "${1:-}" ] || return 1
    [ -r "/proc/$1/status" ] || return 1
    while IFS=: read -r key value; do
        if [ "$key" = "State" ]; then state="${value//[[:space:]]/}"; break; fi
    done < "/proc/$1/status" 2>/dev/null
    case "$state" in Z*) return 1 ;; esac
    return 0
}

# ONE FIELD OF `/proc/<pid>/stat`, READ WITHOUT A TOOL. The `comm` field is
# parenthesised and may itself contain spaces and a closing parenthesis, so the
# split is on the LAST `) ` in the line; nothing after `comm` can contain that
# sequence. Field 1 of the remainder is the state, 2 is the parent and 3 is the
# process group.
step7_stat_field() {
    local pid="$1" index="$2" line rest
    [ -r "/proc/$pid/stat" ] || return 1
    read -r line < "/proc/$pid/stat" || return 1
    rest="${line##*') '}"
    [ "$rest" != "$line" ] || return 1
    # shellcheck disable=SC2206  # the remainder is fixed-format numeric fields
    local -a fields=($rest)
    printf '%s' "${fields[$((index - 1))]:-}"
}

# EVERY PROCESS THIS HELPER LAUNCHED, FOUND BY THE LAUNCH ITSELF rather than by
# anything about the path it was launched from. ROUND 6 IS WHY THE MECHANISM
# CHANGED AGAIN, and the reviewer's reproduction is the whole argument: a venv
# entry point is a SHELL WRAPPER that runs the real interpreter by its ABSOLUTE
# CANDIDATE PATH, so the child's command line carries the candidate and never
# the venv, and a scan over the venv path found nothing while a candidate-mapped
# child of this helper's own launch was still running. A wrapper's path is not
# inherited by its child; two other things are.
#
# THE PROCESS GROUP IS THE PRIMARY RULE. The launch is made with job control on,
# so the launched process becomes a group leader and its group id IS its pid.
# Every descendant inherits that group id, across `exec`, across the parent's
# exit and across reparenting to PID 1, because a process group outlives the
# process that created it. Nothing else on the machine can be in it: the id is
# a pid this helper has just been given.
#
# THE ENVIRONMENT NONCE IS THE SECOND RULE, and it exists because the first one
# has one escape: a child that calls `setsid` or `setpgid` leaves the group. The
# launch carries a variable no other process has, `exec` preserves the
# environment, and `/proc/<pid>/environ` is readable for this account's own
# processes. A child that leaves the group still carries it.
#
# Both are properties of the LAUNCH. Neither depends on a path appearing in an
# argument, which is the assumption round 6 destroyed. The helper's own shell
# and PID 1 are never owned, whatever they report.
step7_owned_processes() {
    local pgid="$1" nonce="${2:-}" entry pid
    [ -n "$pgid" ] || return 0
    for entry in /proc/[0-9]*; do
        pid="${entry##*/}"
        [ "$pid" = "$$" ] && continue
        [ "$pid" = "1" ] && continue
        if [ "$(step7_stat_field "$pid" 3 2>/dev/null)" = "$pgid" ]; then
            printf '%s\n' "$pid"
            continue
        fi
        [ -n "$nonce" ] || continue
        [ -r "$entry/environ" ] || continue
        if grep -qzxF "CPLX_STEP7_OWNER=$nonce" "$entry/environ" 2>/dev/null; then
            printf '%s\n' "$pid"
        fi
    done
}

# WAIT FOR A PID TO STOP BEING A RUNNING PROCESS, bounded. A kill is a request
# and not an event, so the target stays listed until it has exited, and this
# waits for that rather than assuming it.
step7_await_gone() {
    local pid="$1" i=0
    [ -n "$pid" ] || return 0
    while [ "$i" -lt 100 ]; do
        step7_process_live "$pid" || return 0
        i=$((i + 1))
        sleep 0.05
    done
    return 1
}

# The interpreter process the wrapper actually launched. ROUND 3 OF THE REVIEW
# FOUND WHY THIS IS NEEDED: the project entry point is a SHELL WRAPPER that runs
# the real binary as a CHILD, so `exec -a` renames the wrapper and the name never
# reaches the interpreter, the observer misses the process, and a kill aimed at
# the wrapper leaves its child running.
step7_child_interpreter() {
    local parent="$1" entry pid
    for entry in /proc/[0-9]*; do
        pid="${entry##*/}"
        if [ "$(step7_parent_of "$pid")" = "$parent" ]; then printf '%s' "$pid"; return 0; fi
    done
    return 1
}

# WHETHER A PROCESS HAS MAPPED ANYTHING FROM THE CANDIDATE YET, read from the
# CONTENT of its mapping table. Round 3 found the previous test unable to
# succeed at all: Linux reports `/proc/<pid>/maps` with size zero even while its
# contents are readable, so `[ -s ]` was false forever and every launch waited
# out the whole deadline.
step7_maps_candidate() {
    local pid="$1" prefix="$2" line
    while IFS= read -r line; do
        case "$line" in *" $prefix"/*) return 0 ;; esac
    done < "/proc/$pid/maps" 2>/dev/null
    return 1
}

# THE LIVE HALF, TAKEN AGAINST A REAL VENV PROCESS OF THE CANDIDATE, with the
# attribution carried by PID OWNERSHIP rather than by a name this harness hopes
# is unique. Round 3 established both halves of that: the wrapper loses a
# renamed argv0, and selecting a process by NAME can match one nobody here
# started.

#
# So the branch creates a venv from the candidate interpreter, launches a
# process through the VENV entry point, finds the interpreter child the wrapper
# spawned, waits until that child has mapped something from the candidate, and
# observes. The caller is given the owned pid on a `OWNED|` line so it can
# require that the trace inventoried THAT process and not another answering to
# the same name.
#
# CLEANUP IS OF THE OWNED CHILD FIRST AND THE WRAPPER SECOND, because killing a
# wrapper does not reap what it launched.
step7_candidate_live_evidence() {
    local prefix="$1" root="${2:-$SCRATCH/step7/venv}"
    local interp="" pid="" child="" out="" rc=0 i=0 log="" comm="" owner=""
    local nonce="" proc="" binding="${3:-no}" program='import time; time.sleep(300)'
    if ! interp=$(step7_candidate_interpreter "$prefix" "$binding"); then
        printf 'LIVE|INCONCLUSIVE|no interpreter inside the candidate installation at %s, so no venv process could be started from it\n' "$prefix"
        return 1
    fi
    rm -rf -- "$root"
    mkdir -p -- "${root%/*}" || return 1
    log="${root}.log"
    # Use the candidate ELF's venv API, without running the shipped wrapper or
    # its entry-point rewriting post-hook. This creates ordinary links to the
    # candidate ELF, as the consuming application's venv does. No pip is needed
    # by this process, and no candidate-supplied helper judges the live result.
    if ! env -u VIRTUAL_ENV LC_ALL=C "$interp" -c \
        'import sys, venv; venv.EnvBuilder(with_pip=False, symlinks=True).create(sys.argv[1])' \
        "$root" > "$log" 2>&1; then
        printf 'LIVE|INCONCLUSIVE|the candidate interpreter could not create a venv at %s; launch diagnostics: %s\n' \
            "$root" "$(oneline "$(tail -3 "$log" 2>/dev/null)")"
        return 1
    fi
    if [ ! -x "$root/bin/python3" ]; then
        printf 'LIVE|INCONCLUSIVE|the venv at %s carries no python3 entry point; launch diagnostics: %s\n' \
            "$root" "$(oneline "$(tail -3 "$log" 2>/dev/null)")"
        return 1
    fi
    if [ "$binding" = yes ]; then
        program='import os, sys, time
real = os.path.realpath
venv, candidate = map(real, sys.argv[1:3])
base = real(sys.base_prefix)
exe = real(getattr(sys, "_base_executable", ""))
assert real(sys.prefix) == venv, "application venv prefix mismatch"
assert base.startswith(candidate + "/tools/"), "base prefix outside candidate"
assert exe.startswith(candidate + "/tools/"), "base executable outside candidate"
print("VENV|" + venv + "|" + base + "|" + exe, flush=True)
time.sleep(300)'
    fi
    # THE LAUNCH IS WHAT OWNERSHIP IS TAKEN FROM, so the launch is made to carry
    # two marks that survive everything the wrapper can do. `set -m` makes the
    # launched process a PROCESS GROUP LEADER, so its group id is its own pid
    # and every descendant inherits it; the nonce goes into the ENVIRONMENT,
    # which `exec` preserves and which a child that leaves the group still has.
    # Job control is turned off again immediately: it is needed for the
    # `setpgid` the shell performs at fork and for nothing else here.
    nonce="cplx-step7-$$-${RANDOM}-${RANDOM}"
    set -m
    LC_ALL=C CPLX_STEP7_OWNER="$nonce" "$root/bin/python3" -c "$program" "$root" "$prefix" > "$log" 2>&1 &
    pid=$!
    set +m
    # THE OWNED PROCESS IS WHICHEVER OF THE TWO SHAPES THIS ENTRY POINT TAKES,
    # and measuring it beat assuming it. The project entry point is a shell
    # wrapper, so the interpreter can be a CHILD of what was launched; a venv
    # entry point that resolves straight to the binary IS the interpreter, with
    # no child at all. The RHEL deployed tree turned out to be the second shape,
    # and an earlier version of this loop required the first and timed out on a
    # process that was already mapping the candidate.
    #
    # OWNERSHIP IS ESTABLISHED BEFORE LIVENESS IS TESTED, and round 5 is why the
    # order is stated rather than incidental. The previous loop asked whether
    # the launched process was still alive FIRST, so a wrapper that exited
    # before its child had been discovered left `child` empty, and the child was
    # by then beyond any `PPid` scan's reach.
    #
    # THE SEARCH IS OVER THE LAUNCH AND NOT OVER A PATH, and round 6 is why: a
    # venv wrapper starts the real interpreter by its ABSOLUTE CANDIDATE PATH,
    # so the child's command line carries the candidate and never the venv, and
    # a scan over the venv path missed a candidate-mapped child of this very
    # launch. The launched pid and any descendant are both candidates now, and
    # neither depends on the wrapper still being there to be asked.
    while [ "$i" -lt 150 ]; do
        if [ -z "$child" ]; then
            for owner in $(step7_owned_processes "$pid" "$nonce"); do
                if step7_maps_candidate "$owner" "$prefix"; then child="$owner"; break; fi
            done
        fi
        [ -n "$child" ] && break
        # The deadline ends when nothing this helper launched is running any
        # more, not merely when the launched pid has gone: a wrapper may exit
        # the instant its child is up, and that child is the subject.
        if ! step7_process_live "$pid" && [ -z "$(step7_owned_processes "$pid" "$nonce")" ]; then
            break
        fi
        i=$((i + 1))
        sleep 0.1
    done
    # EVERY EXIT FROM HERE REAPS WHAT THIS HELPER STARTED, and round 4 found the
    # two paths that did not. A wrapper's child outlives the wrapper, so a
    # refusal that killed only the launched pid left an interpreter running for
    # the rest of the suite; and an early wrapper exit can still have left a
    # child behind. `step7_reap` is the one place that decides it, so a later
    # exit added here cannot forget.
    # THE LAUNCHED PROCESS GOING AWAY IS ONLY A REFUSAL WHEN NOTHING IT STARTED
    # SURVIVED IT. A wrapper that exits the instant its child is up has done its
    # job, and the child is the subject; refusing on the wrapper alone would have
    # thrown away the very process the acceptance is about.
    if [ -z "$child" ] && ! step7_process_live "$pid"; then
        printf 'LIVE|INCONCLUSIVE|the venv process exited before anything of it could be observed; launch diagnostics: %s\n' \
            "$(oneline "$(tail -3 "$log" 2>/dev/null)")"
        step7_reap "$pid" "$child" "$pid" "$nonce"
        return 1
    fi
    if [ -z "$child" ] || ! step7_maps_candidate "$child" "$prefix"; then
        printf 'LIVE|INCONCLUSIVE|no process this launch started had mapped anything under %s within the deadline; launch diagnostics: %s\n' \
            "$prefix" "$(oneline "$(tail -3 "$log" 2>/dev/null)")"
        step7_reap "$pid" "$child" "$pid" "$nonce"
        return 1
    fi
    if [ "$binding" = yes ]; then
        i=0
        while [ "$i" -lt 50 ] && ! grep -q '^VENV|' "$log"; do
            step7_process_live "$child" || break
            i=$((i + 1)); sleep 0.1
        done
        if ! grep '^VENV|' "$log"; then
            printf 'LIVE|INCONCLUSIVE|application venv ancestry was not proved: %s\n' "$(oneline "$(tail -3 "$log")")"
            step7_reap "$pid" "$child" "$pid" "$nonce"
            return 1
        fi
    fi
    # The name the observer is asked for is the one the OWNED child actually
    # carries, read from it rather than assumed.
    comm=""
    if [ -r "/proc/$child/comm" ]; then read -r comm < "/proc/$child/comm" || comm=""; fi
    printf 'OWNED|%s|%s\n' "$child" "${comm:-unknown}"
    # Restrict the observer's process view to this launch's owned PID. Another
    # interpreter with the same comm cannot supply or contaminate its trace.
    if ! proc=$(mktemp -d "${root}.proc.XXXXXXXX") \
        || ! ln -s -- "/proc/$child" "$proc/$child"; then
        step7_reap "$pid" "$child" "$pid" "$nonce"
        printf 'LIVE|INCONCLUSIVE|could not isolate the owned process inventory\n'
        return 1
    fi
    out=$("${BASH:-bash}" "$SHIPPED_DIR/closure_observe_live.sh" \
        --process "${comm:-unknown}" --prefix "$prefix" --proc "$proc" 2>&1)
    rc=$?
    step7_reap "$pid" "$child" "$pid" "$nonce"
    rm -rf -- "$proc"
    printf '%s\n' "$out"
    return "$rc"
}

# THE ONE PLACE THIS HELPER GIVES BACK WHAT IT TOOK. The owned child goes first
# and the launched process second, because killing a wrapper does not reap what
# it launched; where the two are the same pid the second kill is a no-op, which
# is correct rather than a special case, and an empty child is simply skipped.
# `wait` is only ever called on the pid this shell actually started, since it is
# the only one it can reap.
step7_reap() {
    local pid="$1" child="${2:-}" pgid="${3:-}" nonce="${4:-}" p rc=0
    local survivors=""
    if [ -n "$child" ] && [ "$child" != "$pid" ]; then kill "$child" 2>/dev/null; fi
    if [ -n "$pid" ]; then
        kill "$pid" 2>/dev/null
        wait "$pid" 2>/dev/null
    fi
    # AND EVERY REMAINING PROCESS OF THE LAUNCH, whether or not this helper ever
    # discovered it. Round 5 found the gap: a wrapper that exits before
    # discovery leaves a child no `PPid` scan can attribute. Round 6 found that
    # closing it over the VENV PATH closed it only for a child whose arguments
    # happened to carry that path, which an ordinary wrapper's child does not.
    # The sweep is now over the process group and the environment nonce, which
    # are properties of the launch itself.
    if [ -n "$pgid" ]; then
        survivors=$(step7_owned_processes "$pgid" "$nonce")
        for p in $survivors; do kill "$p" 2>/dev/null; done
    fi
    # REAPED MEANS GONE, not signalled. `wait` settles only the pid this shell
    # started; a reparented child is cleaned up by init on its own schedule, and
    # where nothing reaps, a zombie counts as gone.
    if [ -n "$child" ] && [ "$child" != "$pid" ]; then
        step7_await_gone "$child" || rc=1
    fi
    for p in $survivors; do
        step7_await_gone "$p" || rc=1
    done
    return "$rc"
}

# THE LISTING OVER THE WHOLE SCOPE, retained rather than summarised. `STATIC|PASS`
# is a verdict about a listing and is not the listing, which round 2 found the
# branch substituting for it. This is the observed loader scope of the installed
# candidate, derived by the installer's own `build_elf_rpath` through the
# checker's seam, one directory per line.
step7_scope_listing() {
    local scope=""
    scope=$(observed_scope "$1" "$SHIPPED_DIR/install_pkg.sh") || return 1
    printf '%s\n' "$scope" | sed -e 's/:/\n/g'
}

# THE LISTING OVER THE WHOLE PROVIDER SET, which is what the design asks for and
# what a directory list is not. Round 4 found the branch retaining scope
# BOUNDARIES and calling them the listing: `STATIC|PASS` beside a handful of
# directory names says nothing about which providers those directories hold, so
# an archive shipping an empty scope would have satisfied it.
#
# This enumerates the scope through the checker's OWN provider index, the same
# one the membership invariant resolves against, and prints one
# `PROVIDER|<name>|<paths>` record per lookup name. The index is built once for
# the whole scope rather than once per name, so the listing costs one
# enumeration and not one per provider.
#
# IT FAILS RATHER THAN PRINTING NOTHING when the index could not be built or
# came back empty, because an inventory nobody could take must not read as a
# scope that holds no providers.
step7_provider_listing() {
    local dirs=""
    dirs=$(step7_scope_listing "$1") || return 1
    [ -n "$dirs" ] || return 1
    # shellcheck disable=SC2016  # the script is the CHILD shell's and expands there
    "${BASH:-bash}" -c '
        set -u
        # shellcheck disable=SC1090
        source "$1" >/dev/null 2>&1 || exit 91
        declare -F closure_provider_index >/dev/null 2>&1 || exit 92
        closure_provider_index "$2"
        if [ "${#CLOSURE_PROVIDER_PATHS[@]}" -eq 0 ]; then exit 93; fi
        for name in "${!CLOSURE_PROVIDER_PATHS[@]}"; do
            printf "PROVIDER|%s|%s\n" "$name" \
                "$(printf "%s" "${CLOSURE_PROVIDER_PATHS[$name]}" | grep -c .)"
        done
    ' _ "$SHIPPED_DIR/closure_check.sh" "$dirs" 2>/dev/null
}

# THE DEBIAN HALF OF THE ACCEPTANCE, which is the archive question and not the
# tree question. The issue fixes three things it must report and this branch
# asserts all three: the PACKAGED ARCHIVE resolves, reported from a listing over
# the whole scope AND a live trace that names the venv process it inventoried.
#
# IT DRIVES THE AUTHORITATIVE VERIFIER rather than repeating it. `closure_verify.sh`
# already computes the archive identity, takes the pre-install and installed
# observations, compares them, runs the static checker over the installed tree
# and invokes the live observer; re-implementing any of that here would make the
# acceptance measure a second implementation. The copy it drives is the one
# delivered beside this harness, never one out of the candidate, which is the
# trust boundary the topology draws.
#
# THE IDENTITY IS RECOMPUTED AND NOT READ. The driver prints the identity it
# derived; this branch digests the same file itself and requires the two to
# agree, for the reason publication computes rather than reads one.
step7_debian_half() {
    local archive="" root="$SCRATCH/step7/accept" process="" out="" rc=0
    local identity="" reported="" proc="$SCRATCH/step7/proc-empty"
    local failures_before="$failures" listing="" live="" lrc=0 owned=""
    local listing_rc=0 outside="" providers="" providers_taken=yes
    local static_observation="" static_report="" static_rc=""

    # THIS BRANCH OWNS THE PROCESS, ALWAYS, and round 5 removed the alternative
    # rather than repairing it. An operator-named process selected a mode that
    # returned the observer's output with no OWNED record, while the acceptance
    # requires OWNED and that pid's PROCESS, OBJECT and HOSTS records: an
    # otherwise conclusive external reading failed three assertions and the mode
    # could never produce a passing half.
    #
    # Repairing it would have meant proving a named process is a process of THIS
    # candidate, which is attribution by measurement and is exactly what starting
    # the venv already does. Keeping it would have meant accepting a trace by
    # process name alone, which rounds 3 and 4 established as the defect. So the
    # mode is gone, with the public claims that described it.
    # The name below is the DRIVER's, for the three controls that plant a
    # process filesystem and drive `closure_verify.sh` over it. The acceptance's
    # own live reading is taken separately, against a process this branch starts
    # and owns by pid, and it needs no name from here.
    process=python3
    note "step7/acceptance/live-process" "started from the candidate venv by this branch, owned by pid"
    if ! archive=$(step7_real_archive); then
        unanswered "the debian half of the step 7 acceptance" \
          "  no packaged archive on this account; packaging must produce one first, then set CPLX_ACCEPTANCE_ARCHIVE to it, or place it at \$HOME/pkgs/tools.latest.tar.gz, and run this step again here. The archive is the subject: a run pointed at an installed prefix instead would answer the build host's question on the wrong machine"
        return
    fi
    note "step7/acceptance/real-archive" "$archive"

    out=$(step7_verify_archive "$archive" "$root" "")
    rc=$?
    static_observation="$out"
    note "step7/acceptance/verify-exit" "$rc"
    while IFS= read -r line; do
        [ -z "$line" ] || note "step7/acceptance/verify" "$line"
    done <<< "$(printf '%s\n' "$out" \
        | grep -E '^(ARCHIVE|DELIVERY|STATIC|LIVE|COMPARISON|PAYLOAD\|SUMMARY|VERIFICATION REFUSED)' || true)"

    # THE IDENTITY, RECOMPUTED HERE AND REQUIRED TO AGREE.
    identity=$(sha256sum -- "$archive" 2>/dev/null | sed -e 's/ .*$//')
    note "step7/acceptance/candidate-sha256" "$identity"
    reported=$(printf '%s\n' "$out" | grep -m1 '^ARCHIVE|' | sed -e 's/^.*|//')
    chk "step7/acceptance/archive-identity-is-recomputed" "$identity" "$reported"

    # THE THREE REPORTS THE ISSUE ASKS FOR, each asserted on its own.
    static_rc=$(printf '%s\n' "$out" | sed -n 's/^STATIC-EXIT|//p')
    static_report=$(printf '%s\n' "$out" | sed -n 's/^STATIC-REPORT|//p')
    chk "step7/acceptance/the-static-listing-passes" "yes" \
        "$(step7_q15_accepts "$static_rc" "$static_report" && echo yes || echo no)"
    while IFS= read -r line; do
        [ -z "$line" ] || note "step7/acceptance/static-report" "$line"
    done <<< "$static_report"
    chk "step7/acceptance/the-two-observations-agree" "yes" \
        "$(printf '%s' "$out" | grep -q '^COMPARISON|PASS' && echo yes || echo no)"
    # THE WHOLE-SCOPE LISTING, RETAINED AS A LISTING. The driver's `STATIC|PASS`
    # is a verdict about one; this is the observed loader scope of the installed
    # candidate, one directory per line, and every directory must fall under the
    # candidate prefix, because a scope reaching outside it is the host fallback
    # this acceptance exists to refuse.
    listing=$(step7_scope_listing "$root/prefix")
    listing_rc=$?
    chk "step7/acceptance/the-scope-listing-was-observed" "0" "$listing_rc"
    chk "step7/acceptance/the-scope-listing-is-not-empty" "yes" \
        "$( [ -n "$listing" ] && echo yes || echo no )"
    note "step7/acceptance/scope-directories" "$(list_size "$listing") directory(ies)"
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        note "step7/acceptance/scope" "$line"
        case "$line" in
            "$root/prefix/"*) ;;
            *) outside+="$line"$'\n' ;;
        esac
    done <<< "$listing"
    chk "step7/acceptance/every-scope-directory-is-inside-the-candidate" "" \
        "$(oneline "$outside")"

    # AND THE PROVIDERS THOSE DIRECTORIES HOLD, which is the listing the design
    # asks for and which round 4 found missing. The boundaries above say where
    # the loader may look; this says what it would FIND there, one record per
    # lookup name, taken through the checker's own provider index so the
    # acceptance and the membership invariant read the same inventory.
    providers=$(step7_provider_listing "$root/prefix") || providers=""
    if [ -z "$providers" ]; then
        # AN UNTAKEN LISTING BLOCKS THE HALF, and it has to be tracked rather
        # than left to the failure count: `unanswered` records an obligation and
        # raises no failure, so without this flag a scope whose inventory could
        # not be taken passed the half on an empty answer. That is the same
        # shape as every other empty observation this acceptance refuses.
        providers_taken=no
        unanswered "the whole-provider listing for the debian half" \
          "  the provider index over the candidate could not be built or returned no lookup name, so the listing this acceptance owes was not taken. An inventory nobody could take is not a scope that holds no providers"
    else
        note "step7/acceptance/providers" "$(list_size "$providers") lookup name(s) over the whole scope"
        while IFS= read -r line; do
            [ -z "$line" ] || note "step7/acceptance/provider" "$line"
        done <<< "$providers"
        chk "step7/acceptance/every-provider-record-is-well-formed" "" \
            "$(oneline "$(printf '%s\n' "$providers" | grep -v '^$' | grep -vE '^PROVIDER\|[^|]+\|[0-9]+$' || true)")"
    fi

    # THE LIVE TRACE, TAKEN AGAINST A PROCESS STARTED FROM THE CANDIDATE and
    # retained as the trace rather than as its verdict.
    live=$(step7_candidate_live_evidence "$root/prefix" "$root/prefix/pdfs/closure-acceptance/venvs/python" yes)
    lrc=$?
    note "step7/acceptance/live-exit" "$lrc"
    while IFS= read -r line; do
        [ -z "$line" ] || note "step7/acceptance/live" "$line"
    done <<< "$(printf '%s\n' "$live" \
        | grep -E '^(VENV|PROCESS|OBJECT|HOSTS|EXCLUDED|FALLBACKS|UNUSABLE|LIVE)\|' || true)"
    chk "step7/acceptance/the-live-trace-is-conclusive" "yes" \
        "$(printf '%s' "$live" | grep -q '^LIVE|CONCLUSIVE' && echo yes || echo no)"
    # IT NAMES THE PROCESS IT INVENTORIED, by a PROCESS record carrying a pid,
    # and not only by repeating the name it was asked for. A summary naming the
    # wanted name proves nothing about what was found.
    chk "step7/acceptance/the-trace-names-the-process-it-inventoried" "yes" \
        "$(printf '%s' "$live" | grep -qE '^PROCESS\|[0-9]+\|' && echo yes || echo no)"
    # AND EVERY PART OF THE READING IS ABOUT THE PROCESS THIS BRANCH OWNS.
    #
    # ROUND 4 OF THE REVIEW FOUND WHY THAT SENTENCE HAS TO COVER MORE THAN THE
    # PROCESS RECORD. The previous version required `PROCESS` for the owned pid
    # and then accepted an `OBJECT` record for ANY pid, so a reading where the
    # owned process was UNUSABLE and a DIFFERENT process supplied the usable
    # objects and the zero-host result passed. The observer emits exactly that
    # shape: `PROCESS` is printed before the collection is attempted, and an
    # unreadable one becomes `UNUSABLE` after it. A conclusive verdict earned by
    # somebody else's process is the same substitution this acceptance refuses
    # everywhere else, one level down.
    #
    # So the owned pid must be named, must carry objects, must NOT be the
    # unusable one, and must be the pid the zero-host result is stated for. The
    # OWNED record itself is retained in the trace above, so a reader of the
    # capture can check the binding rather than trust it.
    owned=$(printf '%s\n' "$live" | grep -m1 '^OWNED|' | cut -d'|' -f2)
    note "step7/acceptance/live-owned" "$(oneline "$(printf '%s\n' "$live" | grep -m1 '^OWNED|')")"
    chk "step7/acceptance/the-trace-inventoried-the-owned-process" "yes" \
        "$( [ -n "$owned" ] && printf '%s' "$live" | grep -qE "^PROCESS\|$owned\|" && echo yes || echo no )"
    chk "step7/acceptance/the-owned-process-carries-objects" "yes" \
        "$( [ -n "$owned" ] && printf '%s' "$live" | grep -qE "^OBJECT\|$owned\|" && echo yes || echo no )"
    chk "step7/acceptance/the-owned-process-is-not-unusable" "no" \
        "$( [ -n "$owned" ] && printf '%s' "$live" | grep -qE "^UNUSABLE\|$owned\|" && echo yes || echo no )"
    chk "step7/acceptance/the-owned-process-maps-no-in-scope-host-object" "yes" \
        "$( [ -n "$owned" ] && printf '%s' "$live" | grep -qE "^FALLBACKS\|$owned\|0$" && echo yes || echo no )"
    chk "step7/acceptance/the-trace-inventoried-objects" "yes" \
        "$(printf '%s' "$live" | grep -qE '^OBJECT\|[0-9]+\|' && echo yes || echo no)"

    # --- the controls this branch owes, at this branch's own level ------------
    #
    # Step 6 proves each of these against the driver over a fixture archive.
    # They are asked AGAIN here because the finding they answer is about THIS
    # branch: it used to pass on a static success alone, so a control that lives
    # only one suite away does not stop that from happening again.

    # A STATIC SUCCESS ALONE MUST NOT PASS. The same archive with no live
    # reading taken leaves the run inconclusive, so the live half is load
    # bearing rather than decorative.
    out="$static_observation"
    chk "step7/acceptance/control/no-live-reading-is-not-a-pass" "yes" \
        "$(printf '%s' "$out" | grep -q '^LIVE|INCONCLUSIVE' && echo yes || echo no)"

    # AN EMPTY TRACE MUST NOT PASS. A process filesystem holding nothing the
    # name matches inventories nothing, and nothing observed is never "no host
    # library loaded".
    rm -rf -- "$proc"; mkdir -p -- "$proc"
    out=$(step7_observe_control "$root/prefix" "$process" "$proc")
    rc=$?
    chk "step7/acceptance/control/empty-trace-exit" "4" "$rc"
    chk "step7/acceptance/control/an-empty-trace-is-not-a-pass" "yes" \
        "$(printf '%s' "$out" | grep -q '^LIVE|INCONCLUSIVE' && echo yes || echo no)"

    # A HOST-LOADED OBJECT MUST REFUSE. Planted rather than arranged, because a
    # real process mapping a host library is not something a test may create on
    # the machine it runs on.
    rm -rf -- "$proc"
    step7_plant_host_proc "$proc" "$process"
    out=$(step7_observe_control "$root/prefix" "$process" "$proc")
    rc=$?
    chk "step7/acceptance/control/host-object-exit" "1" "$rc"
    chk "step7/acceptance/control/a-host-object-refuses" "yes" \
        "$(printf '%s' "$out" | grep -q '^LIVE|REFUSED' && echo yes || echo no)"

    # THE DECISION IS THIS BRANCH'S OWN ASSERTIONS AND NO LONGER THE DRIVER'S
    # EXIT CODE, and the change follows from taking the live half here. The
    # driver returns non-zero whenever ITS live reading was not conclusive, and
    # from round 3 that reading is always inconclusive by design: the process
    # this acceptance inventories is started AFTER the driver has installed,
    # which is the only order in which a process from the candidate can exist.
    # Keeping the old gate would make the half unpassable for the same reason
    # the old branch made it unreachable.
    #
    # So the half passes when the driver's ARCHIVE, STATIC and COMPARISON
    # records answered, this branch's live trace was conclusive over a process it
    # attributed to the candidate, the scope listing was taken, and no assertion
    # or control above failed. Every one of those is a `chk` already counted, so
    # the comparison below is over the failure count rather than over a second
    # reading of the same evidence.
    if [ "$failures" -eq "$failures_before" ] && [ "$lrc" -eq 0 ] \
       && [ "$providers_taken" = yes ]; then
        cases=$((cases + 1))
        pass "step7/acceptance/debian-half" "the packaged archive resolves with no host fallback"
        return
    fi
    unanswered "the debian half of the step 7 acceptance" \
      "  an acceptance assertion or control above failed, or the live observation returned $lrc over a process this branch attributed to the candidate; the lines above name which observation did not answer. The driver's own exit status is deliberately not the gate here, because its live reading is taken before any candidate process exists"
}

# A process filesystem whose one process maps an object from OUTSIDE the
# installed prefix, which is the shape the live half must refuse. It reuses step
# 6's planter so the two suites cannot drift on what a process looks like.
step7_plant_host_proc() {
    local root="$1" name="$2"
    mkdir -p -- "$root" || return 1
    step6_plant_proc "$root" 4242 "$name" "/usr/bin/$name" \
        "/lib/x86_64-linux-gnu/libc.so.6"
}

# Exercise the acceptance decision without requiring a packaged production tree.
# Only the verifier report is planted; the real branch and its assertions run.
# The caller's command substitution contains overrides and observations.
step7_debian_branch_probe() {
    local scenario="$1" failures=0 cases=0
    local probe_archive="$SCRATCH/step7/branch-archive" digest=""
    printf 'acceptance decision fixture\n' > "$probe_archive"
    digest=$(sha256sum < "$probe_archive"); digest="${digest%% *}"
    step7_real_archive() { printf '%s' "$probe_archive"; }
    # THE THREE HELPERS ROUND 3 ADDED ARE STUBBED HERE TOO, for the reason this
    # probe exists at all: it drives the branch's DECISION over a modelled
    # report, and a decision input the model does not supply would send the
    # probe looking for a real installation. The live evidence is modelled in
    # the shape the observer emits, records and verdict alike, so the scenarios
    # still separate a conclusive trace from an empty one and from a refused
    # one.
    step7_scope_listing() {
        case "$scenario" in
            sibling-scope) printf '%s/prefix-other/lib\n' "$SCRATCH/step7/accept"; return 0 ;;
        esac
        printf '%s/prefix/tools/python/root/lib\n' "$SCRATCH/step7/accept"
        if [ "$scenario" = mixed-scope ]; then printf '/usr/lib64\n'; fi
        if [ "$scenario" = failed-scope ]; then return 1; fi
        return 0
    }
    # THE PROVIDER INVENTORY, modelled in the shape the index emits. The
    # `no-providers` scenario is what the round 4 finding is about: a scope whose
    # inventory could not be taken must be reported as untaken rather than read
    # as a scope that holds no providers.
    step7_provider_listing() {
        case "$scenario" in
            no-providers) return 1 ;;
            malformed-providers) printf 'PROVIDER|libz.so.1\n'; return 0 ;;
        esac
        printf 'PROVIDER|libz.so.1|1\nPROVIDER|libpython3.13.so.1.0|1\n'
        return 0
    }
    step7_candidate_live_evidence() {
        case "$scenario" in
            static-only) printf 'LIVE|INCONCLUSIVE|no process\n'; return 1 ;;
            empty-trace) printf 'LIVE|INCONCLUSIVE|empty trace\n'; return 1 ;;
            host-object)
                printf 'OWNED|4242|python3\n'
                printf 'PROCESS|4242|python3\nOBJECT|4242|/lib/libc.so.6|host\nHOSTS|4242|1\nFALLBACKS|4242|1\n'
                printf 'LIVE|REFUSED|host object\n'; return 1 ;;
            # A CONCLUSIVE TRACE OF SOMEBODY ELSE'S PROCESS. The observer
            # inventoried a process answering to the name and it is not the one
            # this branch launched, which on an agent running several
            # interpreters is the likely shape rather than the unlucky one.
            unowned-trace)
                printf 'OWNED|4242|python3\n'
                printf 'PROCESS|9999|python3\nOBJECT|9999|%s/prefix/tools/python/root/lib/libpython3.so|shipped\n' \
                    "$SCRATCH/step7/accept"
                printf 'HOSTS|9999|0\nFALLBACKS|9999|0\nLIVE|CONCLUSIVE|1 process(es) named python3 map no host object\n'
                return 0 ;;
            # THE SHAPE ROUND 4 BUILT TO DEFEAT THE PREVIOUS ASSERTIONS, kept as
            # a model because it is the one the real observer can actually emit:
            # the owned process is NAMED and then turns out to be UNUSABLE, and a
            # different process supplies the objects and the zero-host result.
            # A branch that asked only for `PROCESS` of the owned pid and an
            # `OBJECT` of any pid passed this.
            unusable-owner)
                printf 'OWNED|4242|python3\n'
                printf 'PROCESS|4242|python3\nUNUSABLE|4242|its mapped objects could not be read\n'
                printf 'PROCESS|9999|python3\nOBJECT|9999|%s/prefix/tools/python/root/lib/libpython3.so|shipped\n' \
                    "$SCRATCH/step7/accept"
                printf 'HOSTS|9999|0\nFALLBACKS|9999|0\nLIVE|CONCLUSIVE|1 process(es) named python3 map no host object\n'
                return 0 ;;
            # THE OWNED PROCESS INVENTORIED, AND MAPPING A HOST OBJECT. The
            # verdict line is conclusive for the run as a whole; the owned pid's
            # own host count is not zero, and that is what must decide it.
            owner-maps-host)
                printf 'OWNED|4242|python3\n'
                printf 'PROCESS|4242|python3\nOBJECT|4242|/lib/libc.so.6|host\nHOSTS|4242|1\nFALLBACKS|4242|1\n'
                printf 'LIVE|CONCLUSIVE|1 process(es) named python3 map no host object\n'
                return 0 ;;
        esac
        printf 'OWNED|4242|python3\n'
        printf 'PROCESS|4242|python3\nOBJECT|4242|%s/prefix/tools/python/root/lib/libpython3.so|shipped\n' \
            "$SCRATCH/step7/accept"
        printf 'HOSTS|4242|0\nFALLBACKS|4242|0\nLIVE|CONCLUSIVE|1 process(es) named python3 map no host object\n'
        return 0
    }
    step7_verify_archive() {
        case "$2" in
            *-nolive)
                if [ "$scenario" = bad-control ]; then
                    printf 'LIVE|CONCLUSIVE|unexpected control pass\n'; return 0
                fi
                printf 'LIVE|INCONCLUSIVE|no process\n'; return 1 ;;
            *-empty) printf 'LIVE|INCONCLUSIVE|empty trace\n'; return 1 ;;
            *-host) printf 'LIVE|REFUSED|host object\n'; return 1 ;;
        esac
        if [ "$scenario" = bad-identity ]; then
            printf 'ARCHIVE|fixture|wrong-digest\n'
        else
            printf 'ARCHIVE|fixture|%s\n' "$digest"
        fi
        printf 'STATIC|PASS\nCOMPARISON|PASS\nSTATIC-EXIT|0\n'
        printf 'STATIC-REPORT|  unexpected   0\nSTATIC-REPORT|  undetermined 0\n'
        printf 'STATIC-REPORT|  refused      0 unresolvable DT_NEEDED\n'
        case "$scenario" in
            static-only) return 0 ;;
            empty-trace) printf 'LIVE|INCONCLUSIVE|no process\n'; return 1 ;;
            host-object) printf 'LIVE|REFUSED|host object\n'; return 1 ;;
        esac
        if [ "$scenario" = bad-control ]; then
            printf 'LIVE|CONCLUSIVE|unexpected control pass\n'
        else
            printf 'LIVE|INCONCLUSIVE|no process requested\n'
        fi
        return 0
    }
    step7_debian_half
    printf 'BRANCH_FAILURES|%s\n' "$failures"
}

step7_suite() {
    local dir="$SCRATCH/step7"
    local d10="$SHIPPED_DIR/closure_d10.sh"
    local checker="$SHIPPED_DIR/closure_check.sh"
    local bundle="$SHIPPED_DIR/../closure"
    local tree="" cand11="" cand12="" plant="" reading="" out="" rc=0
    local halves="" mine="" theirs="" capture="" prefix="" name="" entry=""
    local missing="" line="" reason="" multi="" rpid="" rchild="" i=0 clean=""

    rm -rf -- "$dir"
    mkdir -p -- "$dir" || { fail "step7/scratch" "cannot create the scratch directory"; return; }
    tree="$dir/archive"
    cand11="$dir/cand/gcc-11"
    cand12="$dir/cand/gcc-12"

    # --- the topology, one row later than step 5's ---------------------------
    #
    # `closure_d10.sh` is the tenth production script and the second that lives
    # in cplx only. The two properties that make it that are ASSERTED rather than
    # described: it is not staged into an archive, and no shipped script sources
    # it. A module the checker could source would be a module inside the trust
    # boundary, and this one decides a packaging question rather than a closure
    # one.
    section "step 7 topology: the tenth script, in cplx only"
    chk "step7/topology/d10-exists" "yes" "$( [ -f "$d10" ] && echo yes || echo no )"
    chk "step7/topology/no-shipped-script-sources-it" "" \
        "$(oneline "$(grep -l 'closure_d10' "$SHIPPED_DIR"/closure_check.sh \
            "$SHIPPED_DIR"/closure_config.sh "$SHIPPED_DIR"/closure_elf.sh \
            "$SHIPPED_DIR"/closure_report.sh "$SHIPPED_DIR"/closure_rules.sh \
            "$SHIPPED_DIR"/closure_verify.sh "$SHIPPED_DIR"/closure_publish.sh \
            "$SHIPPED_DIR"/closure_observe_live.sh 2>/dev/null || true)")"
    chk "step7/topology/it-is-not-staged-into-the-archive" "" \
        "$(oneline "$(grep -n 'closure_d10' "$SHIPPED_DIR/pkg.sh" 2>/dev/null || true)")"
    # It reaches its two host tools THROUGH the reader module, which is why the
    # enumerated contract gains no row for this step. The assertion is over its
    # own text, because that is where a direct call would appear.
    chk "step7/topology/it-calls-no-host-tool-directly" "" \
        "$(oneline "$(sed -e 's/#.*$//' "$d10" \
            | grep -oE '(^|[|;&]|\$\()[[:space:]]*(readelf|sha256sum|find|tar)[[:space:]]' || true)")"

    # --- the D10 policy: the design's nine rows ------------------------------
    section "step 7 D10 policy: the lowest satisfying candidate, zero spare nodes"

    # ROW 1. The GCC 11 entry defines every required node, so the policy returns
    # GCC 11, and no spare node is required of it.
    plant=$(d10_plant gcc-11 3 \
        "libstdc++.so.6|GLIBCXX_3.4.29 libstdc++.so.6|CXXABI_1.3.13 libgcc_s.so.1|GCC_3.0" \
        "gcc-11|libstdc++.so.6|GLIBCXX_3.4.29 gcc-11|libstdc++.so.6|CXXABI_1.3.13 gcc-11|libgcc_s.so.1|GCC_3.0 gcc-12|libstdc++.so.6|GLIBCXX_3.4.29 gcc-12|libstdc++.so.6|CXXABI_1.3.13 gcc-12|libgcc_s.so.1|GCC_3.0")
    chk "step7/policy/plant/gcc-11-satisfies" "gcc-11|3|3|gcc-11 gcc-12" "$(d10_model "$plant")"
    d10_run "$plant" closure_d10_policy
    chk "step7/policy/gcc-11-satisfies/rc" "0" "$D10_RC"
    chk "step7/policy/gcc-11-satisfies/returns-the-lowest" "D10 POLICY: gcc-11" \
        "$(printf '%s\n' "$D10_OUT" | sed -n '1p')"
    chk "step7/policy/gcc-11-satisfies/asks-no-re-read" "no" \
        "$(printf '%s' "$D10_OUT" | grep -q 'RE-READ REQUIRED' && echo yes || echo no)"

    # ROW 2. It does not, and the GCC 12 entry does. The reading was taken under
    # GCC 11, so the returned candidate differs from it and a re-read is owed.
    plant=$(d10_plant gcc-11 3 \
        "libstdc++.so.6|GLIBCXX_3.4.30" \
        "gcc-11|libstdc++.so.6|GLIBCXX_3.4.29 gcc-12|libstdc++.so.6|GLIBCXX_3.4.30")
    chk "step7/policy/plant/only-gcc-12-satisfies" "gcc-11|3|1|gcc-11 gcc-12" "$(d10_model "$plant")"
    d10_run "$plant" closure_d10_policy
    chk "step7/policy/only-gcc-12-satisfies/rc" "0" "$D10_RC"
    chk "step7/policy/only-gcc-12-satisfies/returns-gcc-12" "D10 POLICY: gcc-12" \
        "$(printf '%s\n' "$D10_OUT" | sed -n '1p')"
    chk "step7/policy/only-gcc-12-satisfies/asks-a-re-read" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'RE-READ REQUIRED: the reading was taken under gcc-11' && echo yes || echo no)"

    # ROW 7. THE RESULT FOLLOWS THE CANDIDATE CAPABILITIES AND NEVER THE SHIPPED
    # GENERATION. The reading was taken under GCC 12 and GCC 11 satisfies, so the
    # answer is GCC 11: an earlier version of this policy scored the archive by
    # the bytes it already carried, which answers a different question.
    plant=$(d10_plant gcc-12 2 \
        "libstdc++.so.6|GLIBCXX_3.4.29" \
        "gcc-11|libstdc++.so.6|GLIBCXX_3.4.29 gcc-12|libstdc++.so.6|GLIBCXX_3.4.29")
    chk "step7/policy/plant/read-under-gcc-12" "gcc-12|2|1|gcc-11 gcc-12" "$(d10_model "$plant")"
    d10_run "$plant" closure_d10_policy
    chk "step7/policy/read-under-gcc-12/returns-gcc-11" "D10 POLICY: gcc-11" \
        "$(printf '%s\n' "$D10_OUT" | sed -n '1p')"
    chk "step7/policy/read-under-gcc-12/asks-a-re-read" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'RE-READ REQUIRED: the reading was taken under gcc-12' && echo yes || echo no)"

    # ROW 8. A required node neither capability entry defines. This is the third
    # result an earlier reading of D10 left out, and it is a FAILURE rather than
    # the closer generation.
    plant=$(d10_plant gcc-11 2 \
        "libstdc++.so.6|GLIBCXX_3.4.29 libstdc++.so.6|GLIBCXX_3.4.31" \
        "gcc-11|libstdc++.so.6|GLIBCXX_3.4.29 gcc-12|libstdc++.so.6|GLIBCXX_3.4.29 gcc-12|libstdc++.so.6|GLIBCXX_3.4.30")
    chk "step7/policy/plant/neither-defines-a-node" "gcc-11|2|2|gcc-11 gcc-12" "$(d10_model "$plant")"
    d10_run "$plant" closure_d10_policy
    chk "step7/policy/neither-defines-a-node/rc" "1" "$D10_RC"
    chk "step7/policy/neither-defines-a-node/returns-neither" "D10 POLICY: NEITHER" \
        "$(printf '%s\n' "$D10_OUT" | sed -n '1p')"
    # AND IT NAMES THE NODE, which is what makes a NEITHER actionable. Beside it
    # the control that gives the naming its meaning: the node that IS defined
    # must not also be reported as undefined.
    chk "step7/policy/neither-defines-a-node/names-it" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'no candidate generation defines libstdc++.so.6|GLIBCXX_3.4.31' && echo yes || echo no)"
    chk "step7/policy/neither-defines-a-node/control/names-only-it" "no" \
        "$(printf '%s' "$D10_OUT" | grep -q 'defines libstdc++.so.6|GLIBCXX_3.4.29' && echo yes || echo no)"
    chk "step7/policy/neither-defines-a-node/says-packaging-fails" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'packaging FAILS' && echo yes || echo no)"

    # ROW 9. A consumer set of zero in an archive that ships a libstdc++. It is
    # reported INCONCLUSIVE and never as a satisfied condition, which is the same
    # refusal the live trace makes of an inventory that found nothing.
    #
    # THE ORDER IS THE POINT. Every candidate satisfies an empty requirement set
    # vacuously, so a policy asking the satisfaction question first would return
    # the lowest generation out of an empty observation and be indistinguishable
    # from a real pass.
    plant=$(d10_plant gcc-11 0 "" \
        "gcc-11|libstdc++.so.6|GLIBCXX_3.4.29 gcc-12|libstdc++.so.6|GLIBCXX_3.4.30")
    chk "step7/policy/plant/zero-consumers" "gcc-11|0|0|gcc-11 gcc-12" "$(d10_model "$plant")"
    d10_run "$plant" closure_d10_policy
    chk "step7/policy/zero-consumers/rc" "5" "$D10_RC"
    chk "step7/policy/zero-consumers/is-inconclusive" "D10 POLICY: INCONCLUSIVE" \
        "$(printf '%s\n' "$D10_OUT" | sed -n '1p')"
    chk "step7/policy/zero-consumers/says-why" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'empty observation and never a satisfied condition' && echo yes || echo no)"
    # THE CONTROL FOR IT, and it is what makes the case above mean something: the
    # same capability entries with ONE consumer and no required node do not
    # report inconclusive. The refusal is about an empty CONSUMER set and not
    # about an empty requirement set.
    plant=$(d10_plant gcc-11 1 "" \
        "gcc-11|libstdc++.so.6|GLIBCXX_3.4.29 gcc-12|libstdc++.so.6|GLIBCXX_3.4.30")
    d10_run "$plant" closure_d10_policy
    chk "step7/policy/zero-consumers/control/one-consumer-answers" "0" "$D10_RC"

    # AN UNREADABLE CAPABILITY ENTRY IS INCONCLUSIVE AND NEVER UNSATISFYING,
    # which is the mirror of the row above: scoring an unmeasured generation as
    # not satisfying demotes it for being unmeasurable, and the lowest satisfying
    # candidate would then depend on which trees happened to be readable.
    # The plant already ends in its own separator, so the two assignments follow
    # it directly: an added one would close an empty statement and the eval
    # refuses that before the module is ever reached.
    plant="$(d10_plant gcc-11 2 "libstdc++.so.6|GLIBCXX_3.4.29" \
        "gcc-12|libstdc++.so.6|GLIBCXX_3.4.29")CLOSURE_D10_UNREAD=1;CLOSURE_D10_REASON=planted"
    d10_run "$plant" closure_d10_policy
    chk "step7/policy/unreadable-candidate/rc" "5" "$D10_RC"
    chk "step7/policy/unreadable-candidate/is-inconclusive" "D10 POLICY: INCONCLUSIVE" \
        "$(printf '%s\n' "$D10_OUT" | sed -n '1p')"
    chk "step7/policy/unreadable-candidate/does-not-demote" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'an unmeasured generation is not an unsatisfying one' && echo yes || echo no)"

    # NO CANDIDATE AT ALL is the third inconclusive shape: a reading declaring
    # nothing to choose between has not answered the question either.
    plant='closure_d10_reset;CLOSURE_D10_READING=gcc-11;CLOSURE_D10_CONSUMERS+=(a.so)'
    d10_run "$plant" closure_d10_policy
    chk "step7/policy/no-candidate/rc" "5" "$D10_RC"
    chk "step7/policy/no-candidate/says-why" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'nothing to choose between' && echo yes || echo no)"

    # --- the re-read rule: rows 3 to 6 ---------------------------------------
    section "step 7 D10 convergence: the second evaluation must return the same candidate"
    plant=$(d10_plant gcc-12 1 "" "")

    # ROW 3. The second reading returns GCC 12 again, which is the convergence
    # the re-read exists to establish.
    d10_run "$plant" closure_d10_converge gcc-12 gcc-12
    chk "step7/converge/same-candidate/rc" "0" "$D10_RC"
    chk "step7/converge/same-candidate/settles" "D10 CONVERGENCE: SETTLED at gcc-12" \
        "$(printf '%s\n' "$D10_OUT" | sed -n '1p')"
    # A SETTLED RESULT OFFERS NO FURTHER READING, which is the other half of "no
    # third iteration": the sentence belongs to the failure and not to the pass.
    chk "step7/converge/same-candidate/control/no-iteration-language" "no" \
        "$(printf '%s' "$D10_OUT" | grep -q 'no third iteration' && echo yes || echo no)"

    # ROW 4. A HIGHER second result: the requirement set grew with the
    # generation.
    d10_run "$plant" closure_d10_converge gcc-11 gcc-12
    chk "step7/converge/higher/rc" "1" "$D10_RC"
    chk "step7/converge/higher/is-non-convergent" "D10 CONVERGENCE: NON-CONVERGENT" \
        "$(printf '%s\n' "$D10_OUT" | sed -n '1p')"
    chk "step7/converge/higher/names-the-direction" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'the HIGHER candidate gcc-12 where the first returned gcc-11' && echo yes || echo no)"
    chk "step7/converge/higher/no-third-iteration" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'there is no third iteration' && echo yes || echo no)"

    # ROW 5. A LOWER second result: the first reading overstated what the archive
    # needs. It is a separate case from the row above because it fails for a
    # different reason, and one case would assert only the direction it planted.
    d10_run "$plant" closure_d10_converge gcc-12 gcc-11
    chk "step7/converge/lower/rc" "1" "$D10_RC"
    chk "step7/converge/lower/names-the-direction" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'the LOWER candidate gcc-11 where the first returned gcc-12' && echo yes || echo no)"

    # ROW 6. NEITHER satisfies on the second reading: the rebuild moved the
    # requirements out of range.
    d10_run "$plant" closure_d10_converge gcc-12 NEITHER
    chk "step7/converge/neither/rc" "1" "$D10_RC"
    chk "step7/converge/neither/names-the-reason" "yes" \
        "$(printf '%s' "$D10_OUT" | grep -q 'satisfies NEITHER candidate, so the rebuild moved the requirements out of range' && echo yes || echo no)"

    # Equality is convergence only for a candidate, never for two failures or
    # two labels absent from the reading's capability entries.
    for name in NEITHER INCONCLUSIVE undeclared; do
        d10_run "$plant" closure_d10_converge "$name" "$name"
        chk "step7/converge/equal-$name/refuses" "1" "$D10_RC"
    done

    # --- the evidence half, over real objects --------------------------------
    #
    # The rows above ask the policy about a model. This asks whether a real
    # reading produces that model, which is the only thing binding the two ends
    # of the interface together.
    section "step 7 D10 evidence: the consumer set is the subject set, and the generation is recomputed"
    # THE ENGINE IS RESOLVED BEFORE A DONOR IS LOOKED FOR, in that order and for
    # the reason step 3 established: a host with no `readelf` cannot validate a
    # donor either, and reporting the donor as the missing thing would name the
    # second symptom rather than the first input.
    DONOR_SHARED=""
    if ! fixture_resolve_tools; then
        unanswered "the step 7 evidence half" \
          "  readelf and dd must both resolve here; run this step on the RHEL 9.8 build host and on the Debian 12 agent"
    else
        note "step7/fixture/tools" "$FIXTURE_READELF, $FIXTURE_DD"
        DONOR_SHARED=$(donor_find_shared) || DONOR_SHARED=""
        chk "step7/fixture/donor-found" "yes" \
            "$( [ -n "$DONOR_SHARED" ] && echo yes || echo no )"
        if [ -z "$DONOR_SHARED" ]; then
            unanswered "the step 7 evidence half" \
              "  no ELF donor on this host validates against the corpus rows; run this step on the RHEL 9.8 build host and on the Debian 12 agent"
        fi
    fi
    if [ -n "$DONOR_SHARED" ]; then
        note "step7/fixture/donor" "$DONOR_SHARED"
        # The archive: two providers, and a consumer NO ENTRY POINT REACHES. The
        # last part is the whole reason the consumer set is bound to this
        # design's subject rule. A reading that walked from the entry points
        # would not see this file, and would answer the compiler question about
        # the rest of the archive while reporting it as the archive's answer.
        step7_provider "$tree/tools/gcc/lib/libstdc++.so.6.0.29" libstdc++.so.6 GLIBCXX_3.4.29
        chk "step7/evidence/plant/shipped-libstdc++" "yes" \
            "$(elf_verdef_defines "$tree/tools/gcc/lib/libstdc++.so.6.0.29" GLIBCXX_3.4.29 && echo yes || echo no)"
        step7_provider "$tree/tools/gcc/lib/libgcc_s.so.1.1" libgcc_s.so.1 GCC_3.0
        chk "step7/evidence/plant/shipped-libgcc_s" "libgcc_s.so.1" \
            "$(elf_soname "$tree/tools/gcc/lib/libgcc_s.so.1.1")"
        step7_consumer "$tree/tools/python/lib/lib-dynload/_unreached.so" \
            libstdc++.so.6 GLIBCXX_3.4.29
        chk "step7/evidence/plant/consumer-demands-the-node" "yes" \
            "$(elf_verneed_demands "$tree/tools/python/lib/lib-dynload/_unreached.so" \
                libstdc++.so.6 GLIBCXX_3.4.29 && echo yes || echo no)"
        chk "step7/evidence/plant/consumer-needs-the-library" "yes" \
            "$(elf_needed_names "$tree/tools/python/lib/lib-dynload/_unreached.so" \
                | grep -Fxq libstdc++.so.6 && echo yes || echo no)"

        # THE GCC 11 CANDIDATE IS THE ARCHIVE'S OWN PROVIDERS, byte for byte, so
        # the reading generation must resolve to it. They are COPIES of the
        # shipped files rather than second mutations of the donor: recomputation
        # compares bytes, and two files built by the same mutations are not
        # guaranteed to be the same bytes.
        mkdir -p -- "$cand11" "$cand12"
        cp -- "$tree/tools/gcc/lib/libstdc++.so.6.0.29" "$cand11/libstdc++.so.6"
        cp -- "$tree/tools/gcc/lib/libgcc_s.so.1.1" "$cand11/libgcc_s.so.1"
        step7_provider "$cand12/libstdc++.so.6" libstdc++.so.6 GLIBCXX_3.4.30
        step7_provider "$cand12/libgcc_s.so.1" libgcc_s.so.1 GCC_3.0
        chk "step7/evidence/plant/gcc-12-defines-a-higher-node" "yes" \
            "$(elf_verdef_defines "$cand12/libstdc++.so.6" GLIBCXX_3.4.30 && echo yes || echo no)"

        d10_run "" closure_d10_evidence "$tree" "gcc-11=$cand11" "gcc-12=$cand12"
        reading="$D10_OUT"
        chk "step7/evidence/reading-is-taken" "0" "$D10_RC"
        chk "step7/evidence/the-unreached-module-is-a-consumer" "1 of 3 shipped objects" \
            "$(step7_reading_field "$reading" consumers)"
        chk "step7/evidence/required-nodes" "1" \
            "$(step7_reading_field "$reading" 'required nodes')"
        chk "step7/evidence/the-required-node-is-named" "yes" \
            "$(printf '%s' "$reading" | grep -q 'require libstdc++.so.6|GLIBCXX_3.4.29' && echo yes || echo no)"
        # THE READING GENERATION IS RECOMPUTED. The GCC 11 entry is the shipped
        # bytes, so the derivation resolves to it with nothing having declared
        # it.
        chk "step7/evidence/generation-is-recomputed" "gcc-11" \
            "$(step7_reading_field "$reading" 'reading generation')"
        # AND THE POLICY OVER THAT REAL READING RETURNS THE LOWEST SATISFYING
        # CANDIDATE, which is the two ends of the interface meeting: no model was
        # planted for this one.
        d10_run "" closure_d10_main --root "$tree" \
            --candidate "gcc-11=$cand11" --candidate "gcc-12=$cand12"
        chk "step7/evidence/policy-over-a-real-reading/rc" "0" "$D10_RC"
        chk "step7/evidence/policy-over-a-real-reading/returns-gcc-11" "yes" \
            "$(printf '%s' "$D10_OUT" | grep -q '^D10 POLICY: gcc-11$' && echo yes || echo no)"
        chk "step7/evidence/policy-over-a-real-reading/asks-no-re-read" "no" \
            "$(printf '%s' "$D10_OUT" | grep -q 'RE-READ REQUIRED' && echo yes || echo no)"

        # A second call in one shell must observe only the new archive. The
        # first call is required to pass, so an initialization failure cannot
        # stand in for the empty second observation.
        mkdir -p -- "$dir/empty"
        # shellcheck disable=SC2016  # expanded by d10_run's child shell
        plant='review_two_readings() {
            closure_d10_main --root "$1" --candidate "$3" --candidate "$4" || return 93
            closure_d10_main --root "$2" --candidate "$3" --candidate "$4"
        }'
        d10_run "$plant" review_two_readings "$tree" "$dir/empty" \
            "gcc-11=$cand11" "gcc-12=$cand12"
        chk "step7/evidence/second-empty-reading/is-inconclusive" "5" "$D10_RC"
        chk "step7/evidence/second-empty-reading/has-no-stale-subjects" "yes" \
            "$(printf '%s' "$D10_OUT" | grep -q 'consumers *0 of 0 shipped objects' && echo yes || echo no)"

        # A readable consumer beside an unreadable ELF is a partial observation,
        # not evidence that the readable consumer is the whole requirement set.
        printf '\177ELFbroken' > "$tree/broken.so"
        d10_run "" closure_d10_main --root "$tree" \
            --candidate "gcc-11=$cand11" --candidate "gcc-12=$cand12"
        chk "step7/evidence/unread-object/is-inconclusive" "5" "$D10_RC"
        chk "step7/evidence/unread-object/names-incomplete-archive" "yes" \
            "$(printf '%s' "$D10_OUT" | grep -q 'archive reading is incomplete: 1 unread object' && echo yes || echo no)"
        rm -f -- "$tree/broken.so"

        # Even a find that prints all subjects and then fails cannot certify
        # that the traversal was complete. Keep real find's output for the
        # positive consumer, and change only its completion status.
        mkdir -p -- "$dir/failed-find"
        { printf '#!/bin/bash\n'; printf '%q "$@"\nexit 1\n' "$(type -P find)"; } \
            > "$dir/failed-find/find"
        chmod +x "$dir/failed-find/find"
        # shellcheck disable=SC2016  # PATH changes only in the child shell
        plant='review_failed_walk() { PATH="$1:$PATH"; shift; closure_d10_main "$@"; }'
        d10_run "$plant" review_failed_walk "$dir/failed-find" --root "$tree" \
            --candidate "gcc-11=$cand11" --candidate "gcc-12=$cand12"
        chk "step7/evidence/incomplete-walk/is-inconclusive" "5" "$D10_RC"
        chk "step7/evidence/incomplete-walk/names-incomplete-archive" "yes" \
            "$(printf '%s' "$D10_OUT" | grep -q 'archive reading is incomplete: 0 unread object' && echo yes || echo no)"

        # THE CONTROL FOR THE RECOMPUTATION: a candidate whose bytes are NOT the
        # archive's leaves the reading generation unknown, and an unknown one
        # always owes a re-read. A derivation that took a label from an argument
        # rather than from bytes would answer gcc-11 here too.
        cp -- "$cand12/libstdc++.so.6" "$cand11/libstdc++.so.6"
        d10_run "" closure_d10_evidence "$tree" "gcc-11=$cand11" "gcc-12=$cand12"
        chk "step7/evidence/control/mixed-bytes-are-unknown" "unknown" \
            "$(step7_reading_field "$D10_OUT" 'reading generation')"
        # Neither candidate now defines the consumer's node. Supplying a prior
        # NEITHER must preserve failure rather than turn equal tokens into 0.
        d10_run "" closure_d10_main --root "$tree" \
            --candidate "gcc-11=$cand11" --candidate "gcc-12=$cand12" --previous NEITHER
        chk "step7/evidence/neither-twice/preserves-cli-failure" "1" "$D10_RC"
    fi

    # --- the acceptance -------------------------------------------------------
    section "step 7 acceptance: the positive control, the inventory, and the two halves"

    local q15_clean=$'  unexpected 0\n  undetermined 0\n  refused 0 unresolvable DT_NEEDED'
    local q15_waived="$q15_clean"$'\n  waivers 1 declared, 1 active, 0 refused\nWAIVED|waiver|libsqlite3.so.0|python-sqlite-support|active: absent'
    chk "step7/q15/clean-is-accepted" yes "$(step7_q15_accepts 0 "$q15_clean" && echo yes || echo no)"
    chk "step7/q15/sole-sqlite-waiver-is-accepted" yes "$(step7_q15_accepts 3 "$q15_waived" && echo yes || echo no)"
    chk "step7/q15/missing-report-refuses" no "$(step7_q15_accepts 3 '' && echo yes || echo no)"
    chk "step7/q15/other-waiver-refuses" no "$(step7_q15_accepts 3 "${q15_waived//libsqlite3.so.0/libother.so.0}" && echo yes || echo no)"
    chk "step7/q15/stale-waiver-refuses" no "$(step7_q15_accepts 3 "$q15_waived"$'\nREFUSED|waiver|stale' && echo yes || echo no)"
    chk "step7/q15/undetermined-refuses" no "$(step7_q15_accepts 3 "$q15_waived"$'\nUNDETERMINED|object|broken' && echo yes || echo no)"
    chk "step7/q15/duplicate-refusal-refuses" no "$(step7_q15_accepts 3 "$q15_waived"$'\n  duplicates 1 refused' && echo yes || echo no)"

    printf 'Target: debian\nCaptured: 2026-09-11\nstep7/acceptance/debian-half PASS\n' \
        > "$dir/capture-input.txt"
    out=$(step7_capture_answers "$dir/capture-input.txt" debian)
    rc=$?
    chk "step7/capture/passing-half-is-accepted" "0" "$rc"
    chk "step7/capture/missing-archive-identity-refuses" no "$(step7_capture_answers "$dir/capture-input.txt" debian abc >/dev/null && echo yes || echo no)"
    printf '  step7/acceptance/candidate-sha256 NOTE  abc\n' >> "$dir/capture-input.txt"
    chk "step7/capture/same-archive-is-accepted" yes "$(step7_capture_answers "$dir/capture-input.txt" debian abc >/dev/null && echo yes || echo no)"
    chk "step7/capture/different-archive-refuses" no "$(step7_capture_answers "$dir/capture-input.txt" debian def >/dev/null && echo yes || echo no)"
    out=$(step7_capture_answers "$dir/capture-input.txt" debian)
    reading=$(sha256sum < "$dir/capture-input.txt")
    chk "step7/capture/records-the-bytes-inspected" "yes" \
        "$(printf '%s' "$out" | grep -Fq "${reading%% *}" && echo yes || echo no)"
    printf 'Target: debian\nCaptured: 2026-09-11\nstep7/acceptance/debian-half FAIL\n' \
        > "$dir/capture-input.txt"
    out=$(step7_capture_answers "$dir/capture-input.txt" debian)
    rc=$?
    chk "step7/capture/refusing-half-is-refused" "1" "$rc"
    reading=$(sha256sum < "$dir/capture-input.txt")
    chk "step7/capture/refusal-records-the-replacement-bytes" "yes" \
        "$(printf '%s' "$out" | grep -Fq "${reading%% *}" && echo yes || echo no)"

    # Read the real helper's colon-joined source over two actual directories.
    # The branch models below already supply lines, so they cannot catch a
    # missing conversion at the observed_scope seam.
    tree="$dir/scope-listing"
    mkdir -p "$tree/tools/python/root/lib64" "$tree/tools/python/root/lib"
    chk_list "step7/acceptance/scope-listing-separates-directories" \
        "$tree/tools/python/root/lib64"$'\n'"$tree/tools/python/root/lib" \
        "$(step7_scope_listing "$tree")"

    # THE REAL HELPER, EXERCISED RATHER THAN MODELLED. Round 3 asked for this by
    # name: the report models below drive the branch's DECISION, and a decision
    # driven entirely over stubs says nothing about whether a venv is created,
    # whether the wrapper's interpreter child is found, or whether its mappings
    # are ever read. Both cases here call `step7_candidate_live_evidence` itself.
    #
    # THE REFUSAL PATH RUNS ANYWHERE. A prefix with no interpreter must produce
    # the typed INCONCLUSIVE rather than an empty answer or a whole deadline.
    mkdir -p -- "$dir/noint/tools"
    live=$(step7_candidate_live_evidence "$dir/noint" "$dir/noint-venv")
    chk "step7/live-helper/no-interpreter-is-inconclusive" "yes" \
        "$(printf '%s' "$live" | grep -q '^LIVE|INCONCLUSIVE|no interpreter inside the candidate' && echo yes || echo no)"

    # A real acceptance must bypass a broken wrapper and refuse a raw-binary
    # link that escapes the selected installation.
    tree="$dir/interpreter-selection"
    mkdir -p "$tree/tools/python/current/bin"
    printf '#!/bin/sh\nexit 99\n' > "$tree/tools/python/current/bin/python3"
    chmod +x "$tree/tools/python/current/bin/python3"
    chk "step7/live-helper/selection/refuses-wrapper-for-real-acceptance" "no" \
        "$(step7_candidate_interpreter "$tree" yes >/dev/null && echo yes || echo no)"
    cp -- "$(command -v sleep)" "$tree/tools/python/current/bin/python3.13_bin"
    chk "step7/live-helper/selection/chooses-contained-elf-before-wrapper" \
        "$(readlink -f "$tree/tools/python/current/bin/python3.13_bin")" \
        "$(step7_candidate_interpreter "$tree" yes)"
    rm -- "$tree/tools/python/current/bin/python3.13_bin"
    ln -s -- "$(command -v sleep)" "$tree/tools/python/current/bin/python3.13_bin"
    chk "step7/live-helper/selection/refuses-escaping-elf" "no" \
        "$(step7_candidate_interpreter "$tree" yes >/dev/null && echo yes || echo no)"

    # THE WRAPPER TIMEOUT PATH, EXERCISED RATHER THAN REASONED ABOUT. Round 4
    # found the refusal paths killing only the launched process while a child
    # they had already identified kept running. The direct-interpreter case
    # cannot cover it, because there the two pids are the same. This plants the
    # shape the project entry point actually has: a wrapper that outlives its
    # own launch and a child that never maps the candidate, so the deadline is
    # reached with a child to reap.
    mkdir -p -- "$dir/reap"
    { printf '#!/bin/bash\n'; printf 'sleep 30 &\n'; printf 'wait\n'; } > "$dir/reap/wrapper.sh"
    chmod +x "$dir/reap/wrapper.sh"
    "$dir/reap/wrapper.sh" >/dev/null 2>&1 &
    rpid=$!
    rchild=""
    i=0
    while [ "$i" -lt 50 ]; do
        rchild=$(step7_child_interpreter "$rpid") || rchild=""
        [ -n "$rchild" ] && break
        i=$((i + 1)); sleep 0.1
    done
    chk "step7/live-helper/reap/the-fixture-has-a-child" "yes" \
        "$( [ -n "$rchild" ] && echo yes || echo no )"
    step7_reap "$rpid" "$rchild"
    chk "step7/live-helper/reap/the-child-is-gone" "no" \
        "$( [ -n "$rchild" ] && step7_process_live "$rchild" && echo yes || echo no )"
    chk "step7/live-helper/reap/the-wrapper-is-gone" "no" \
        "$( step7_process_live "$rpid" && echo yes || echo no )"
    # THE UNMARKED WRAPPER CHILD, WHICH IS THE SHAPE THE PROJECT ACTUALLY
    # SHIPS. Round 6 found the round 5 ownership rule reading a path out of the
    # child's ARGUMENTS, and a venv entry point puts none there: it starts the
    # real interpreter by its ABSOLUTE CANDIDATE PATH, so the child's command
    # line names the candidate and never the venv. The reviewer's reproduction
    # is planted here in the same shape, and it is not a refusal case: the
    # child maps the candidate, so a helper that owns its own launch must FIND
    # it, name it on the `OWNED` record and reach a typed verdict. Before the
    # repair this exact plant answered "the venv process exited before anything
    # of it could be observed" while that child was still running.
    mkdir -p -- "$dir/unmarked/tools/python/current/bin"
    cp -- "$(command -v sleep)" "$dir/unmarked/tools/python/current/bin/real-interpreter"
    cat > "$dir/unmarked/tools/python/current/bin/python3" <<'UNMARKED'
#!/bin/bash
[ "${1:-}" = "-c" ] && [ -n "${3:-}" ] || exit 1
real="${0%/*}/real-interpreter"
mkdir -p -- "$3/bin" || exit 1
set -- "$1" "$2" "$(cd -- "$3" && pwd -P)"
cat > "$3/bin/python3" <<WRAPPER
#!/bin/bash
"$real" 60 > /dev/null 2>&1 &
echo \$! > "$3/started.pid"
exit 0
WRAPPER
chmod +x "$3/bin/python3" || exit 1
exit 0
UNMARKED
    chmod +x "$dir/unmarked/tools/python/current/bin/python3"
    live=$(step7_candidate_live_evidence "$dir/unmarked" "$dir/unmarked-venv")
    rpid=$(cat "$dir/unmarked-venv/started.pid" 2>/dev/null) || rpid=""
    chk "step7/live-helper/unmarked-child/the-plant-left-a-child" "yes" \
        "$( [ -n "$rpid" ] && echo yes || echo no )"
    # The shape is asserted rather than described: the entry point the plant
    # wrote starts the CANDIDATE path, so the child carries no venv marker of
    # any kind and only the launch can identify it.
    chk "step7/live-helper/unmarked-child/the-wrapper-starts-a-candidate-path" "yes" \
        "$( grep -Fq "\"$dir/unmarked/tools/python/current/bin/real-interpreter\" 60" \
             "$dir/unmarked-venv/bin/python3" && echo yes || echo no )"
    chk "step7/live-helper/unmarked-child/is-owned-by-the-helper" "yes" \
        "$(printf '%s' "$live" | grep -Fq "OWNED|${rpid:-none}|" && echo yes || echo no)"
    chk "step7/live-helper/unmarked-child/reaches-a-typed-verdict" "yes" \
        "$(printf '%s' "$live" | grep -qE '^LIVE\|(PASS|REFUSED|INCONCLUSIVE)\|' && echo yes || echo no)"
    chk "step7/live-helper/unmarked-child/the-child-was-reaped" "no" \
        "$( [ -n "$rpid" ] && step7_process_live "$rpid" && echo yes || echo no )"

    # THE EARLY-EXIT PATH, THROUGH THE ACTUAL HELPER. Round 5 found the reap
    # control above unable to reach it: it hands `step7_reap` a child it has
    # ALREADY discovered, while the defect was a launch that exits BEFORE
    # discovery, leaving a live process the helper can no longer name. Nothing
    # here is stubbed: the plant is a candidate interpreter, and
    # `step7_candidate_live_evidence` itself creates the venv, launches it,
    # loses the launched process and has to recover.
    #
    # THE SURVIVOR IS OUTSIDE THE CANDIDATE and, like the case above, carries no
    # venv marker: it is a copy of a host tool under this suite's own scratch,
    # started by absolute path. It maps nothing under the candidate, so no
    # observation is possible and the helper must refuse; nothing but the
    # process group and the environment nonce can find it afterwards.
    #
    # THE CONTROL RECORDS ITS OWN SURVIVOR so it cannot pass vacuously. A plant
    # that launched nothing fails the run rather than passing quietly. That pid
    # sleeps for a minute and the helper takes about fifteen seconds, so finding
    # it gone afterwards means something killed it.
    #
    # IT ALSO SPENDS THE HELPER'S WHOLE DEADLINE, so the bounded wait is
    # exercised here as well and ends in a typed answer rather than in a hang.
    mkdir -p -- "$dir/earlyexit/tools/python/current/bin" "$dir/earlyexit-tool"
    cp -- "$(command -v sleep)" "$dir/earlyexit-tool/sleeper"
    printf '%s\n' "$dir/earlyexit-tool/sleeper" \
        > "$dir/earlyexit/tools/python/current/bin/sleeper.path"
    cat > "$dir/earlyexit/tools/python/current/bin/python3" <<'EARLYEXIT'
#!/bin/bash
[ "${1:-}" = "-c" ] && [ -n "${3:-}" ] || exit 1
read -r sleeper < "${0%/*}/sleeper.path" || exit 1
mkdir -p -- "$3/bin" || exit 1
set -- "$1" "$2" "$(cd -- "$3" && pwd -P)"
cat > "$3/bin/python3" <<WRAPPER
#!/bin/bash
"$sleeper" 60 > /dev/null 2>&1 &
echo \$! > "$3/started.pid"
exit 0
WRAPPER
chmod +x "$3/bin/python3" || exit 1
exit 0
EARLYEXIT
    chmod +x "$dir/earlyexit/tools/python/current/bin/python3"
    live=$(step7_candidate_live_evidence "$dir/earlyexit" "$dir/earlyexit-venv")
    rpid=$(cat "$dir/earlyexit-venv/started.pid" 2>/dev/null) || rpid=""
    chk "step7/live-helper/early-exit/is-inconclusive" "yes" \
        "$(printf '%s' "$live" | grep -q '^LIVE|INCONCLUSIVE|' && echo yes || echo no)"
    chk "step7/live-helper/early-exit/the-plant-left-a-survivor" "yes" \
        "$( [ -n "$rpid" ] && echo yes || echo no )"
    chk "step7/live-helper/early-exit/the-survivor-was-reaped" "no" \
        "$( [ -n "$rpid" ] && step7_process_live "$rpid" && echo yes || echo no )"

    # THE SUCCESS PATH RUNS WHERE A DEPLOYED TREE EXISTS, over that tree as the
    # candidate prefix. It is NOT the packaged archive and does not stand in for
    # it; what it establishes is that the helper's own machinery works end to
    # end: a venv is created from the shipped interpreter, the wrapper's child is
    # found, its mappings are read, the observer inventories THAT pid, and the
    # child is reaped. Without it the helper would reach a real archive never
    # having run once.
    if live=$(step7_real_prefix) && step7_candidate_interpreter "$live" >/dev/null 2>&1; then
        live=$(step7_candidate_live_evidence "$live" "$dir/realvenv")
        owned=$(printf '%s\n' "$live" | grep -m1 '^OWNED|' | cut -d'|' -f2)
        note "step7/live-helper/owned" "$(oneline "$(printf '%s\n' "$live" | grep -m1 '^OWNED|')")"
        note "step7/live-helper/verdict" "$(oneline "$(printf '%s\n' "$live" | grep -m1 '^LIVE|')")"
        chk "step7/live-helper/it-launched-and-owned-an-interpreter" "yes" \
            "$( [ -n "$owned" ] && echo yes || echo no )"
        chk "step7/live-helper/the-observer-inventoried-that-pid" "yes" \
            "$( [ -n "$owned" ] && printf '%s' "$live" | grep -qE "^PROCESS\|$owned\|" && echo yes || echo no )"
        chk "step7/live-helper/it-reached-a-typed-verdict" "yes" \
            "$(printf '%s' "$live" | grep -qE '^LIVE\|(CONCLUSIVE|REFUSED|INCONCLUSIVE)\|' && echo yes || echo no)"
        chk "step7/live-helper/the-owned-child-was-reaped" "no" \
            "$( [ -n "$owned" ] && step7_process_live "$owned" && echo yes || echo no )"
    else
        note "step7/live-helper/success-path" "no deployed tree with a candidate interpreter here, so the helper's success path was not exercised"
    fi

    # These branch controls run on both hosts even when no real archive exists.
    for name in good bad-identity static-only empty-trace host-object bad-control \
        mixed-scope sibling-scope failed-scope unowned-trace unusable-owner \
        owner-maps-host no-providers malformed-providers; do
        out=$(step7_debian_branch_probe "$name")
        # THE TWO EXPECTATIONS ARE NOT ALWAYS THE SAME, and separating them is
        # the point rather than a convenience. A scenario can be refused by a
        # failed ASSERTION or by an UNANSWERED OBLIGATION, and those are
        # different states this effort keeps apart everywhere else. Only `good`
        # passes the half; `no-providers` refuses it with every assertion still
        # clean, because an inventory nobody could take raises an obligation
        # rather than a finding; every other scenario refuses it by failing an
        # assertion that names what was wrong.
        case "$name" in
            good)         entry=yes; clean=yes ;;
            no-providers) entry=no;  clean=yes ;;
            *)            entry=no;  clean=no ;;
        esac
        chk "step7/acceptance-branch/$name/half-marker" "$entry" \
            "$(printf '%s' "$out" | grep -qE 'step7/acceptance/debian-half +PASS' && echo yes || echo no)"
        chk "step7/acceptance-branch/$name/assertions-clean" "$clean" \
            "$(printf '%s' "$out" | grep -q '^BRANCH_FAILURES|0$' && echo yes || echo no)"
    done

    # THE POSITIVE CONTROL, which is a control rather than a formality: 20 of the
    # 54 needed names have more than one candidate path in the scope and all 20
    # resolve to one file, so a rule 1 that refused the same-file case would
    # refuse the current archive twenty times over. Step 4 plants that shape and
    # asserts it; the acceptance asserts the CASE EXISTS and that it is asked
    # over twenty names, because re-planting it here would measure a second
    # fixture rather than the one the gate is judged on.
    chk "step7/acceptance/positive-control-exists" "yes" \
        "$(step7_control_exists "step4/duplicates/positive-control-accepted" && echo yes || echo no)"
    chk "step7/acceptance/positive-control-counts-the-names" "yes" \
        "$(step7_control_exists "step4/duplicates/positive-control-counts" && echo yes || echo no)"
    chk "step7/acceptance/positive-control-name-count" "20" "$FIXTURE_MULTI_NAMES"

    # ONE NEGATIVE CONTROL PER INDEPENDENTLY REFUSABLE INVARIANT: the issue's
    # nine plus the four this design adds. The inventory is checked against this
    # harness's own text rather than asserted, so a control renamed or deleted in
    # an earlier suite is a finding here.
    missing=""
    for entry in "${STEP7_CONTROLS[@]}"; do
        for name in ${entry#*|}; do
            if ! step7_control_exists "$name"; then
                missing="${missing:+$missing }${entry%%|*}:$name"
            fi
        done
    done
    chk "step7/acceptance/thirteen-invariants-declared" "13" "${#STEP7_CONTROLS[@]}"
    chk "step7/acceptance/every-invariant-has-a-control" "" "$(oneline "$missing")"

    # THE TWO HALVES. This host takes its own live and requires the other's
    # capture. The host gate already resolved which is which, so a machine that
    # is neither never reaches here with a half to take.
    if ! halves=$(step_two_host_halves); then
        note "step7/acceptance/halves" "this host answers neither half"
        return
    fi
    mine="${halves%% *}"
    theirs="${halves##* }"
    capture="$CAPTURES/verify.closure.step7.$theirs.txt"
    note "step7/acceptance/this-host" "$mine live, $theirs from $capture"

    local acceptance_archive="" acceptance_identity=""
    if acceptance_archive=$(step7_real_archive); then
        acceptance_identity=$(sha256sum -- "$acceptance_archive" | sed -e 's/ .*$//')
    fi
    if [ -n "$acceptance_identity" ] && step7_capture_answers "$capture" "$theirs" "$acceptance_identity"; then
        cases=$((cases + 1))
        pass "step7/acceptance/$theirs-capture" "retained, and its own half passed there"
    else
        unanswered "the $theirs half of the step 7 acceptance" \
          "  no capture at $capture that names $theirs, carries a date and shows step7/acceptance/$theirs-half passing; run this step on that host and retain its output there"
    fi

    # THE TWO LIVE HALVES ARE DIFFERENT QUESTIONS, AND ROUND 1 OF THIS STEP'S
    # REVIEW IS WHY THEY ARE NOW SEPARATE BRANCHES. The previous version ran the
    # same static check for whichever host it was on and marked the half passed
    # when the checker succeeded over an installed prefix. That answers the RHEL
    # question and it does NOT answer the Debian one: the foreign-host criterion
    # is that the PACKAGED ARCHIVE resolves with no host fallback, reported from
    # a listing over the whole scope AND a live trace naming the venv process it
    # inventoried. A statically closed prefix satisfies none of those three, so
    # the branch could have passed without the archive ever being read.
    #
    #   the RHEL half   the packaging check over the real tree this account
    #                   packages, plus the real archive's own rule 1 result
    #   the DEBIAN half the authoritative verifier over a real packaged archive:
    #                   its identity, the two observations, the static check and
    #                   the live trace, with controls at this branch's own level
    if [ "$mine" = "debian" ]; then
        step7_debian_half
        return
    fi

    # THE RHEL HALF, over the REAL tree this account packages. A fixture here
    # would be a rehearsal: the acceptance is a positive result on the
    # distribution the defect exists on, and the tree is what carries it.
    if [ -z "$acceptance_archive" ]; then
        unanswered "the $mine half of the step 7 acceptance" \
          "  no candidate archive is available; set CPLX_ACCEPTANCE_ARCHIVE to the final packaged bytes"
        return
    fi
    prefix="$SCRATCH/step7/rhel-candidate"
    mkdir -p -- "$prefix" || return 1
    if ! tar -xzf "$acceptance_archive" -C "$prefix"; then
        unanswered "the $mine half of the step 7 acceptance" "  the candidate archive could not be extracted"
        return
    fi
    note "step7/acceptance/candidate-sha256" "$acceptance_identity"
    note "step7/acceptance/real-prefix" "$prefix"
    out=$("${BASH:-bash}" "$checker" --prefix "$prefix" \
        --installer "$SHIPPED_DIR/install_pkg.sh" --bundle "$bundle" 2>&1)
    rc=$?
    note "step7/acceptance/checker-exit" "$rc"
    # EVERY REFUSAL IT PRODUCES IS NAMED IN THE CAPTURE, whatever the verdict: a
    # refusal that was counted and not named is a finding nobody can act on. The
    # SCOPE half is included by name, since an undeclared directory is reported
    # as an UNEXPECTED observation rather than as a REFUSED invariant, and it is
    # the one this acceptance most needs a reader to see.
    while IFS= read -r line; do
        [ -z "$line" ] || note "step7/acceptance/refusal" "$line"
    done <<< "$out"

    # RULE 1 OVER THE REAL UNMODIFIED ARCHIVE, which the fixture inventory does
    # not evidence and cannot. Step 4's positive control plants twenty names and
    # proves the rule does not over-refuse on a shape this harness built; the
    # issue asks for the same property over the tree that actually ships, where
    # the multi-candidate count is whatever the payload happens to carry. The
    # assertion is therefore on the REFUSAL count with a non-zero multi-candidate
    # count beside it: zero refusals over zero multi-candidate names would be a
    # vacuous pass, and naming both numbers is what tells them apart.
    line=$(printf '%s\n' "$out" | grep -E '^  duplicates ' | sed -e 's/^  duplicates *//')
    if [ -n "$line" ]; then
        note "step7/acceptance/real-duplicates" "$line"
        multi=$(printf '%s' "$line" | sed -e 's/^.*names, *//' -e 's/ multi-candidate.*$//')
        chk "step7/acceptance/real-archive-rule-1-refuses-nothing" "yes" \
            "$(case "$line" in *' 0 refused') echo yes ;; *) echo no ;; esac)"
        chk "step7/acceptance/real-archive-multi-candidate-names" "yes" \
            "$( [ "${multi:-0}" -gt 0 ] 2>/dev/null && echo yes || echo no )"
    else
        unanswered "the real archive's rule 1 result" \
          "  the checker printed no duplicates summary line over $prefix, so the positive control could not be read from this run"
    fi

    if step7_q15_accepts "$rc" "$out"; then
        cases=$((cases + 1)); pass "step7/acceptance/$mine-half" "the candidate satisfies Q15 over $prefix"
        return
    fi
    # A REFUSING TREE IS NOT A FAILING HARNESS, and telling the two apart is the
    # whole of what this branch does. The gate refusing a tree that is genuinely
    # not closed is the gate WORKING; the acceptance is unanswered until the tree
    # it judges is repaired, and the repair belongs to whoever owns the cause.
    # Naming only one cause when several are present would send an operator to
    # move a directory and leave them believing the rest was clean.
    reason=""
    if printf '%s' "$out" | grep -q '^CLOSURE SCOPE REFUSED'; then
        # THE OPERATOR PREREQUISITE, NAMED RATHER THAN PERFORMED. No script in
        # this effort removes a directory on a live account on its own authority.
        reason="an OPERATOR lists each UNEXPECTED directory above on this account, confirms it is a superseded root and not a live one, MOVES it out of the tools tree to a retained location on the same account and records where, then re-runs this step. No script in this effort removes one, and a deletion taken instead of a move is a decision recorded explicitly before the acceptance runs"
    fi
    if printf '%s' "$out" | grep -qE '^CLOSURE (MEMBERSHIP|FAMILY|COHERENCE|DUPLICATE|FLOOR) REFUSED'; then
        reason="${reason:+$reason; AND }the payload itself is not closed: the refusals above are names the archive would carry and not resolve, which is the rebuild umbrella item 7 owns rather than anything an operator can move"
    fi
    if [ -z "$reason" ]; then
        reason="the checker returned $rc and named no refusal class this suite knows; read the capture above"
    fi
    unanswered "the $mine half of the step 7 acceptance" "  $reason"
}
run_one_step() {
    local step="$1" tool state host sha sha_state k halves

    printf '=== verify.closure-check, v0.27.0 toolchain-runtime-closure, step %s ===\n' "$step"

    section "harness prerequisite preflight"
    for tool in "${HARNESS_TOOLS[@]}"; do
        preflight_tool "$tool" || true
    done
    if [ "$PREFLIGHT_OK" -ne 1 ]; then
        printf '\nOBJECTIVE NOT MET for step %s: the preflight could not resolve a tool\n' "$step"
        exit 1
    fi
    mkdir -p -- "$SCRATCH" || { echo "cannot create scratch $SCRATCH" >&2; exit 2; }

    section "host gate: $(step_host "$step")"
    if read_host_identity; then
        note "host/identity" "$HOST_ID $HOST_VERSION"
    else
        note "host/identity" "no readable /etc/os-release"
    fi
    host=$(step_host "$step")
    case "$host" in
        any-linux)
            if [ "$HOST_ID" = "unknown" ]; then
                unanswered "the host identity" \
                  "  /etc/os-release is not readable here, so this is not one of the two hosts this effort validates on; re-run on the RHEL 9.8 build host or on the Debian 12 agent"
            else
                cases=$((cases + 1)); pass "host/any-linux" "$HOST_ID $HOST_VERSION"
            fi ;;
        debian-12)
            case "$HOST_ID:$HOST_VERSION" in
                debian:12*) cases=$((cases + 1)); pass "host/debian-12" "$HOST_ID $HOST_VERSION" ;;
                *) unanswered "the Debian 12 half of step $step" \
                     "  this host is [$HOST_ID $HOST_VERSION]; run this step on the Debian 12 agent through ci/Jenkinsfile.diagnostics" ;;
            esac ;;
        both)
            # ONE HALF LIVE, THE OTHER HALF AS RETAINED EVIDENCE. A host that is
            # neither of the two cannot take either half and says so; a host that
            # is one of them passes the gate and its suite is then responsible
            # for requiring the capture of the other.
            if halves=$(step_two_host_halves); then
                cases=$((cases + 1)); pass "host/both" "$HOST_ID $HOST_VERSION answers the ${halves%% *} half"
            else
                unanswered "the two-host acceptance of step $step" \
                  "  this host is [$HOST_ID $HOST_VERSION]; run this step on the RHEL 9.8 build host and on the Debian 12 agent, and retain both captures"
            fi ;;
    esac

    # The declared capabilities are measured for EVERY step, before its suite, so
    # a step never runs half a case set against a tool it cannot use. Step 0
    # measures them a second time inside its own suite, because there the states
    # are the subject rather than the prerequisite.
    if [ "$step" != "0" ]; then
        section "capability gate: $(step_tools "$step")"
        for tool in $(step_tools "$step"); do
            capability_record "$tool"
            state=$(capability_state "$tool")
            chk "capability/$tool/in-domain" "yes" "$(capability_in_domain "$state")"
            note "capability/$tool" "$state: $(capability_detail "$tool")"
            [ "$state" = "supported" ] || refuse_capability "$tool" "$state"
        done
    fi

    if step_suite_exists "$step"; then
        # One suite per step, dispatched by number. The list and
        # `step_suite_exists` are extended together: a suite reachable from one
        # and not from the other would either never run or refuse while existing.
        case "$step" in
            0) step0_suite ;;
            1) step1_suite ;;
            2) step2_suite ;;
            3) step3_suite ;;
            4) step4_suite ;;
            5) step5_suite ;;
            6) step6_suite ;;
            7) step7_suite ;;
        esac
    else
        section "step $step suite"
        note "step$step/suite" "not implemented yet"
        unanswered "the step $step case suite" \
          "  no suite exists for step $step yet; it is written by $(step_filled_by "$step")"
    fi

    printf '\n== verdict\n'
    printf '  step        %s\n' "$step"
    printf '  cases       %s\n' "$cases"
    printf '  failures    %s\n' "$failures"
    printf '  host        %s %s\n' "$HOST_ID" "$HOST_VERSION"
    printf '  bash        %s\n' "${BASH_VERSION:-none}"
    printf '  contract    %s\n' "$CONTRACT"
    printf '  corpus      %s\n' "$CORPUS"
    printf '  shipped-dir %s\n' "$SHIPPED_DIR"
    # The identities, printed so a retained capture carries the bytes that
    # produced it and the bytes it measured. They are computed only where the
    # sha256sum capability answers its probe: a digest taken with a tool the gate
    # would call unsupported is a number with no meaning.
    #
    # THE PROBE RUNS FOR EVERY STEP AND IS NOT ONE OF ANY STEP'S DECLARED TOOLS.
    # The digests identify the bytes that ran, which is a property of the capture
    # rather than of the step, so a step that never digests anything must not
    # refuse over the tool, and a capture from such a step must still be able to
    # name itself. Reading the recorded state instead would have printed nothing
    # for every step but step 0, which declares sha256sum for its own reasons.
    sha_state="$(capability_probe sha256sum)"
    if [ "${sha_state%%|*}" = "supported" ]; then
        sha=$(type -P sha256sum)
        printf '  harness      %s\n' "$("$sha" "${BASH_SOURCE[0]}" | sed -e 's/ .*$//')"
        printf '  contract-sha %s\n' "$("$sha" "$CONTRACT" | sed -e 's/ .*$//')"
        printf '  corpus-sha   %s\n' "$("$sha" "$CORPUS" | sed -e 's/ .*$//')"
    else
        printf '  harness      unavailable: the sha256sum probe answered %s here\n' \
            "${sha_state%%|*}"
    fi
    for k in "${!CAP_KEYS[@]}"; do
        printf '  capability   %s=%s\n' "${CAP_KEYS[$k]}" "${CAP_STATES[$k]}"
    done
    if [ -n "$UNANSWERED" ]; then printf '  unanswered  %s\n' "$UNANSWERED"; fi

    # THREE outcomes, not two. A failure is a finding about the code and wins,
    # since that is the thing to act on; an obligation nobody could answer is
    # neither a pass nor a code failure. Answering the cheaper question and
    # reporting the step done is what these exist to prevent.
    if [ "$failures" -ne 0 ]; then
        printf '\nOBJECTIVE NOT MET for step %s: %s failure(s)\n' "$step" "$failures"
        exit 1
    fi
    if [ -n "$UNANSWERED" ]; then
        printf '\nOBJECTIVE NOT MET for step %s: unanswered: %s\n' "$step" "$UNANSWERED"
        printf '%s\n' "$UNANSWERED_HOW"
        exit 5
    fi
    printf '\nOBJECTIVE MET for step %s\n' "$step"
    exit 0
}

# ============================================================ the run, every step ===
# One step, one process. A capability resolved in one step must not survive into
# another, and the only way to guarantee that in a shell is a new process, so the
# full run re-invokes this file rather than looping over the suites in place.
run_every_step() {
    local n rc worst=0 line
    printf '=== verify.closure-check, v0.27.0 toolchain-runtime-closure, every step ===\n'
    for n in 0 1 2 3 4 5 6 7; do
        "${BASH:-bash}" "$0" --step "$n" --contract "$CONTRACT" --corpus "$CORPUS" \
            --shipped-dir "$SHIPPED_DIR" --ci-dir "$CI_DIR" --captures "$CAPTURES" \
            > "$SCRATCH/step$n.out" 2>&1
        rc=$?
        line=$(sed -n '$p' "$SCRATCH/step$n.out")
        printf '  step %s  exit %s  %s\n' "$n" "$rc" "$line"
        # A failure outranks an unanswered obligation, which outranks a pass: the
        # aggregate reports the thing to act on rather than the last thing that
        # happened.
        case "$rc" in
            0) ;;
            5) if [ "$worst" -eq 0 ]; then worst=5; fi ;;
            *) worst="$rc" ;;
        esac
    done
    printf '\n=== aggregate: exit %s\n' "$worst"
    exit "$worst"
}

if [ -n "$STEP" ]; then
    run_one_step "$STEP"
else
    mkdir -p -- "$SCRATCH" || { echo "cannot create scratch $SCRATCH" >&2; exit 2; }
    run_every_step
fi
