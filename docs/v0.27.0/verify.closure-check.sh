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
# reconstruct: that the four checker modules were created together and no fifth
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
# construction with the index built first. Steps 4 to 7 are still the red
# baseline, and each refusal names the step that will fill it.
#
# Usage:
#   bash verify.closure-check.sh [--step N] [--contract PATH] [--corpus PATH]
#                                [--shipped-dir PATH]
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

while [ "$#" -gt 0 ]; do
    case "$1" in
        --step) STEP="${2:-}"; shift 2 ;;
        # The two committed inputs. Namable because the Debian job runs this
        # harness from a pipeline workspace where the delivery script places
        # them beside it under the pipeline's own layout.
        --contract) CONTRACT_ARG="${2:-}"; shift 2 ;;
        --corpus) CORPUS_ARG="${2:-}"; shift 2 ;;
        # Where the nine production scripts live once they exist. Step 0 ships
        # none, so this resolves to a directory holding no `closure_*.sh` and the
        # mechanical assertion reports zero subjects rather than inventing one.
        --shipped-dir) SHIPPED_DIR_ARG="${2:-}"; shift 2 ;;
        -h|--help) sed -n '4,77p' "$0"; exit 0 ;;
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
        6) printf 'readelf sha256sum assoc' ;;
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
        0|1|2|3|4) return 0 ;;
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
    "$SHIPPED_DIR/closure_rules.sh"
    "$SHIPPED_DIR/closure_verify.sh"
    "$SHIPPED_DIR/closure_observe_live.sh"
    "$SHIPPED_DIR/closure_publish.sh"
    "$SHIPPED_DIR/closure_d10.sh"
    "$here/../../ci/deliver-closure-tools.sh"
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
    'let' 'readonly' 'command' 'exec' 'builtin' 'type' 'times' 'wait'
    'umask' 'getopts' 'hash'
)

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
# The candidate set is the installer plus the four checker modules, which is the
# whole of what a shipped script here may source. Widening it later means adding
# a source relationship the topology does not have.
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

# THE REFUSAL PATH, over the step the line above names. Two children of this same
# file: one under a PATH stripped to the harness's own tools, which must refuse on
# the missing `readelf`, and one under the host's real PATH, which must refuse on
# the ABSENT SUITE instead. The pair is the point: a harness that printed the
# missing-tool sentence unconditionally would satisfy the first alone.
step0_refusal_path() {
    local shim="$1" out rc found unfilled

    unfilled=$(step0_first_unfilled)
    if [ -z "$unfilled" ]; then
        note "step0/refusal/subject" "every suite exists, so nothing can carry the absent-suite half"
        unanswered "the step 0 refusal path" \
          "  every step now has a suite, so this control has no subject left; retire it with the red baseline it measures"
        return 0
    fi
    note "step0/refusal/subject" "step $unfilled, the first whose suite does not exist yet"

    out=$(PATH="$shim" "${BASH:-bash}" "$0" --step "$unfilled" --contract "$CONTRACT" --corpus "$CORPUS" 2>&1)
    rc=$?
    chk "step0/refusal/missing-tool-exit-code" "5" "$rc"
    if printf '%s' "$out" | grep -q 'readelf is not on PATH here'; then found=yes; else found=no; fi
    chk "step0/refusal/names-the-missing-command" "yes" "$found"

    # The control that stops the case above being satisfied by any refusal: the
    # SAME step, on this host's real PATH, must refuse for a DIFFERENT reason and
    # must not name a missing readelf.
    #
    # IT ONLY MEANS ANYTHING WHERE THE HOST SUPPLIES `readelf`. On a host where
    # readelf is unavailable anyway, both children refuse for the same reason and
    # a pass would say nothing about the shim, so the control is not run and the
    # obligation is reported unanswered rather than recorded green. The authoring
    # host is that case: Windows carries no readelf, and an earlier revision of
    # this control FAILED there for exactly this reason, which is how the
    # distinction came to be measured rather than assumed.
    out=$("${BASH:-bash}" "$0" --step "$unfilled" --contract "$CONTRACT" --corpus "$CORPUS" 2>&1)
    rc=$?
    chk "step0/refusal/suite-absent-exit-code" "5" "$rc"
    if [ "$(capability_state readelf)" != "supported" ]; then
        note "step0/refusal/two-refusals-are-distinct" \
             "not run: readelf is $(capability_state readelf) here, so both children refuse alike"
        unanswered "the distinctness of the two step $unfilled refusals" \
          "  re-run on a host that supplies readelf, where the shimmed child refuses on the tool and the real-PATH child refuses on the absent suite"
        return 0
    fi
    if printf '%s' "$out" | grep -q 'readelf is not on PATH here'; then found=yes; else found=no; fi
    chk "step0/refusal/two-refusals-are-distinct" "no" "$found"
    if printf '%s' "$out" | grep -q "no suite exists for step $unfilled yet"; then found=yes; else found=no; fi
    chk "step0/refusal/suite-absent-names-the-step" "yes" "$found"
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
    chk "step0/contract/enumerated-set" \
        "cat chmod cp find git ln mkfifo mktemp readelf rm sha256sum tar tee" \
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
    chk "step0/mechanical/topology-is-nine" "9" "${#SHIPPED_SCRIPTS[@]}"
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
# The four modules the delivered script topology fixes, in the order the topology
# table lists them. Step 1 creates all four; the file name that must NOT exist in
# any shape is named beside them, because "no fifth module" is a property of the
# tree rather than of a table nobody re-reads.
CLOSURE_MODULES=(closure_check.sh closure_config.sh closure_elf.sh closure_rules.sh)
CLOSURE_FORBIDDEN_MODULE=closure_scope.sh

# The step that FILLS each module, parallel to the array above and taken from the
# topology table's own `Filled by` column. It is here rather than re-listed at
# each step because "created empty" and "filled" are the same claim read at two
# different times: a module whose filling step has a suite must have a body, and
# every other module must still have none. Hand-listing the empty ones made step
# 1 the place a later step had to remember to edit, and a forgotten edit there
# reads as a step 1 regression rather than as the step that filled the file.
CLOSURE_MODULE_FILLED_BY=(1 2 3 3)

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
    section "step 1 topology: four modules, created together, no fifth"
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
        config_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
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
        config_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
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
        config_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/authentic-swap/packaging-REFUSES" "1" "$CONFIG_RC"
        note "step2/authority/authentic-swap/publication-REFUSES" \
             "pending: publication resolves the digest itself rather than reading the archive's; Step 5 asserts it"

        # A commit that does not hold that configuration at that path.
        cp -- "$dir/valid.txt" "$bundle/closure-config.txt"
        step2_write_envelope "$bundle/closure-envelope.txt" "$d1" "cfg/not-there.txt" "$commit"
        config_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/path-absent-at-that-commit" "1" "$CONFIG_RC"
        chk "step2/authority/path-absent-names-it" "yes" \
            "$(printf '%s' "$CONFIG_OUT" | grep -q "source|$commit holds no blob at cfg/not-there.txt" && echo yes || echo no)"

        # A 40-hexadecimal value that is not a commit object. The domain accepts
        # the shape, and the resolution refuses the OBJECT, which is the half a
        # lexical check alone cannot answer.
        d2=$(git -C "$repo" rev-parse HEAD:cfg/closure-config.txt 2>/dev/null)
        step2_write_envelope "$bundle/closure-envelope.txt" "$d1" "cfg/closure-config.txt" "$d2"
        config_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
        chk "step2/authority/40-hex-that-is-a-blob" "1" "$CONFIG_RC"
        chk "step2/authority/40-hex-blob-names-the-type" "yes" \
            "$(printf '%s' "$CONFIG_OUT" | grep -q "names a blob in $repo rather than a commit" && echo yes || echo no)"
        # And a branch name, which the envelope domain refuses before the
        # resolution is ever reached: packaging cannot PRODUCE such a bundle.
        step2_write_envelope "$bundle/closure-envelope.txt" "$d1" "cfg/closure-config.txt" "develop"
        config_call closure_config_authority_check "$repo" "$bundle/closure-config.txt" "$bundle/closure-envelope.txt"
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
    cp -- "$dir/valid.txt" "$bundle/closure-config.txt"
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
    cp -- "$dir/valid.txt" "$bundle/closure-config.txt"
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

# The four 64-byte name slots in the reserved tail of `.dynstr`, as a dynstr-
# relative offset. Slot 0 is the one a single-mutation row uses; the other three
# exist for the rows a later step fills.
elf_name_slot() { printf '%s' "$(( $1 - 256 + $2 * 64 ))"; }

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
    slot=$(elf_name_slot "$ds_size" 0)
    elf_poke_str "$file" $(( ds_off + slot )) "$value"
    idx=$(elf_dyn_slot "$file" "$tag") || return 1
    elf_poke_u64 "$file" $(( dy_off + idx * 16 + 8 )) "$slot"
}

elf_add_needed() {
    local file="$1" value="$2" ds_off ds_size dy_off dy_size slot idx
    read -r ds_off ds_size <<< "$(elf_section "$file" .dynstr)"
    read -r dy_off dy_size <<< "$(elf_section "$file" .dynamic)"
    if [ -z "${ds_size:-}" ] || [ -z "${dy_size:-}" ]; then return 1; fi
    slot=$(elf_name_slot "$ds_size" 0)
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
    slot1=$(elf_name_slot "$ds_size" 1)
    slot2=$(elf_name_slot "$ds_size" 2)
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
    slot=$(elf_name_slot "$ds_size" 1)
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
            slot=$(elf_name_slot "$ds_size" 0)
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
        closure_rules_digest() {
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
          "  fill the four checker modules under src/setups/env/bin, then repeat this call"
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
# ============================================================== the run, one step ===
run_one_step() {
    local step="$1" tool state host sha sha_state k

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
            unanswered "the two-host acceptance of step $step" \
              "  no single host answers this step; run it on the RHEL 9.8 build host and on the Debian 12 agent, and retain both captures" ;;
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
            --shipped-dir "$SHIPPED_DIR" > "$SCRATCH/step$n.out" 2>&1
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
