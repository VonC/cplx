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
# candidate shape and the observed loader scope, and step 2, the configuration
# bundle and its authority. Step 1 asserts three things a later reader should not
# have to reconstruct: that the four checker modules were created together and no
# fifth exists, that the observed scope is `build_elf_rpath`'s own output byte for
# byte rather than a copy of its logic, and that a loader scope which could not be
# observed becomes a typed UNDETERMINED instead of an empty one. Step 2 asserts
# the asymmetry that makes the declaration mean anything: the agent checks
# INTERNAL CONSISTENCY and says so, packaging resolves the authoritative document
# from cplx, and the paired edit is accepted by the first and refused by the
# second. Steps 3 to 7 are still the red baseline, and each refusal names the step
# that will fill it.
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
        -h|--help) sed -n '4,72p' "$0"; exit 0 ;;
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
        4) printf 'readelf assoc' ;;
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
        0|1|2) return 0 ;;
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
    section "step 0 refusal path: a step whose declared tool is missing"
    out=$(PATH="$shim" "${BASH:-bash}" "$0" --step 3 --contract "$CONTRACT" --corpus "$CORPUS" 2>&1)
    rc=$?
    chk "step0/refusal/missing-tool-exit-code" "5" "$rc"
    if printf '%s' "$out" | grep -q 'readelf is not on PATH here'; then found=yes; else found=no; fi
    chk "step0/refusal/names-the-missing-command" "yes" "$found"
    # The control that stops the case above being satisfied by any refusal: the
    # SAME step, on this host's real PATH, must refuse for a DIFFERENT reason and
    # must not name a missing readelf. Without it, a harness that always printed
    # the sentence would pass both.
    #
    # IT ONLY MEANS ANYTHING WHERE THE HOST SUPPLIES `readelf`. On a host where
    # readelf is unavailable anyway, both children refuse for the same reason and
    # a pass would say nothing about the shim, so the control is not run and the
    # obligation is reported unanswered rather than recorded green. The authoring
    # host is that case: Windows carries no readelf, and an earlier revision of
    # this control FAILED there for exactly this reason, which is how the
    # distinction below came to be measured rather than assumed.
    out=$("${BASH:-bash}" "$0" --step 3 --contract "$CONTRACT" --corpus "$CORPUS" 2>&1)
    rc=$?
    chk "step0/refusal/suite-absent-exit-code" "5" "$rc"
    if [ "$(capability_state readelf)" = "supported" ]; then
        if printf '%s' "$out" | grep -q 'readelf is not on PATH here'; then found=yes; else found=no; fi
        chk "step0/refusal/two-refusals-are-distinct" "no" "$found"
        if printf '%s' "$out" | grep -q 'no suite exists for step 3 yet'; then found=yes; else found=no; fi
        chk "step0/refusal/suite-absent-names-the-step" "yes" "$found"
    else
        note "step0/refusal/two-refusals-are-distinct" \
             "not run: readelf is $(capability_state readelf) here, so both children refuse alike"
        unanswered "the distinctness of the two step 3 refusals" \
          "  re-run on a host that supplies readelf, where the shimmed child refuses on the tool and the real-PATH child refuses on the absent suite"
    fi

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
    local body='fatal() { echo " FATAL ${2} : [stub] ${1}" >&2; exit "${2}"; }'
    { printf '#!/bin/bash\n'
      printf '%s\n' "$body"
      printf 'build_elf_rpath() { return 0; }\n'
      printf 'fatal "the sourced installer refuses" 3\n'; } > "$1"
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
