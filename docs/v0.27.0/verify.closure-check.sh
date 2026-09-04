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
# the gap. Step 0 is the only one with a suite today, which is the red baseline
# this step exists to record.
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
        0) return 0 ;;
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

# The finding: every command-position word of <file> absent from the contract and
# from the file's own vocabulary, one per line. Empty output is the pass.
shipped_undeclared_words() {
    local file="$1" known=""
    known=$( { contract_entry_names
               printf '%s\n' "${SHIPPED_VOCABULARY[@]}"
               shipped_assignment_targets "$file"
               shipped_function_names "$file"; } | grep -v '^$' | sort -u )
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
    section "step 0 red baseline: every later step declares and refuses"
    for n in 1 2 3 4 5 6 7; do
        chk "step0/declared/step$n/tools-not-empty" "yes" \
            "$( [ -n "$(step_tools "$n")" ] && echo yes || echo no )"
        chk "step0/declared/step$n/host-not-empty" "yes" \
            "$( [ -n "$(step_host "$n")" ] && echo yes || echo no )"
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

# ============================================================== the run, one step ===
run_one_step() {
    local step="$1" tool state host sha k

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
        step0_suite
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
    # sha256sum capability was measured supported: a digest taken with a tool the
    # gate just called unsupported would be a number with no meaning.
    if [ "$(capability_state sha256sum)" = "supported" ]; then
        sha=$(type -P sha256sum)
        printf '  harness      %s\n' "$("$sha" "${BASH_SOURCE[0]}" | sed -e 's/ .*$//')"
        printf '  contract-sha %s\n' "$("$sha" "$CONTRACT" | sed -e 's/ .*$//')"
        printf '  corpus-sha   %s\n' "$("$sha" "$CORPUS" | sed -e 's/ .*$//')"
    else
        printf '  harness      unavailable: the sha256sum capability is %s here\n' \
            "$(capability_state sha256sum)"
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
