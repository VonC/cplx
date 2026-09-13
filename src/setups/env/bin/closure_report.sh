#!/bin/bash
# The closure checker's REPORT, in both of the forms a run's outcome is written
# in: the human summary a reader gets, and the machine EVIDENCE RECORD a second
# program reads back, together with the store that record is kept in.
#
# This is the fifth module of the delivered script topology, and the only one
# added after Step 1. The topology table in
# `docs/v0.27.0/plan.v0.27.0.toolchain-runtime-closure.md` fixes what it owns:
# the summary block, the partial verdict, the refusal lines, the closing lines,
# and since the Step 6 review the `CPLX-CLOSURE-EVIDENCE/1` grammar with its
# single reader and the store that holds it. It owns NO VERDICT AND NO EXIT CODE.
# `closure_check.sh` still decides what a run returns, because that exit code is
# the checker's contract with `pkg.sh` and moving it would move the gate itself.
#
# WHY THIS FILE EXISTS AT ALL, since the plan spent three steps saying a fifth
# module was the wrong answer to a full one. The rule it was saying that under
# is that a module at the 650-line ceiling moves a responsibility to the module
# that ALREADY OWNS ITS NEIGHBOURS, and that rule has an answer for every
# responsibility here except this one. Scope derivation belongs with the run
# order that consumes it. The object reader belongs with the provider index it
# builds. An invariant belongs with the other invariants. The report belongs
# with none of them: it is formatting over counters that `closure_elf.sh`,
# `closure_rules.sh` and `closure_config.sh` all produce, so it is downstream of
# every module and a neighbour of none. Two code-review rounds reached that
# conclusion independently and left the decision with the plan, which is where a
# topology change belongs; Step 5 is where the plan made it.
#
# WHAT ROUND 3 FORBADE AND THIS IS NOT. The finding was a module set a
# MEASUREMENT could still change: files created only if a budget required them.
# The amended table decides five modules unconditionally, before this step wrote
# a line, and `closure_scope.sh` remains forbidden in any shape. A sixth module
# is not available to a later step that finds itself full.
#
# THE MOVE PRINTS THE SAME BYTES. Every function below came out of
# `closure_check.sh` unchanged in what it emits, which is what lets the step 0
# to step 4 suites stay green across a topology change: an output difference
# here is a defect, never an expected consequence of the move.
#
# WHAT IS PASSED AND WHAT IS READ, because the difference is load bearing and
# not a matter of taste. The invariant counters are read from the rules module's
# globals through `${VAR:-0}`, which is correct and `set -u` safe: that module
# initialises every one of them to 0 at file scope, so a phase that did not run
# and a module that is not there both read 0, which is what the row means.
#
# THE WALK COUNTERS ARE PASSED, and reading them here would be a defect.
# `closure_elf.sh` initialises `CLOSURE_ELF_WALK_STATE` to `complete` at file
# scope, because that is the right default for a walk that is ABOUT to run. A
# run whose scope could not be obtained never starts the walk at all, and
# `closure_check.sh` holds `not run` for it. A report that read the global would
# print `complete` for a walk that never happened, which is the one sentence
# this file must never print. So the caller passes what it holds.
#
# `CLOSURE_PROVIDER_DIRS` is passed for a second reason: it is an ARRAY that
# only exists when `closure_elf.sh` was found, and `${#ARR[@]}` on an unset
# array is an unbound-variable error under the `set -u` the checker runs with.

# THE LEXER, TAKEN FROM THE MODULE THAT OWNS IT. The summary half needs nothing
# from the configuration module; the evidence half at the end of this file is
# written against its refusal, count and domain helpers and its stream reader.
# `closure_check.sh` sources that module before this one and the guard is then a
# no-op, which is what makes this file usable by the verification driver and by
# publication without either of them ordering two sources by hand.
CLOSURE_REPORT_DIR="${BASH_SOURCE[0]%/*}"
if [ "$CLOSURE_REPORT_DIR" = "${BASH_SOURCE[0]}" ]; then
    CLOSURE_REPORT_DIR="."
fi
# shellcheck source=/dev/null
if ! declare -F closure_stream_read >/dev/null 2>&1; then
    if [ -f "$CLOSURE_REPORT_DIR/closure_config.sh" ]; then
        source "$CLOSURE_REPORT_DIR/closure_config.sh"
    fi
fi

# Lines in a newline-separated list, counted in the shell because `wc` is not on
# this effort's contract. An empty list is zero, not the one empty line a naive
# count would report.
closure_report_line_count() {
    local n=0 line
    while IFS= read -r line; do
        if [ -n "$line" ]; then n=$((n + 1)); fi
    done <<< "${1-}"
    printf '%s' "$n"
}

# The declared roots and the typed results, printed before the subject phase
# runs so a reader sees what the run was asked about before what it found.
closure_report_roots() {
    printf '\n== declared roots\n'
    printf '  roots       %s\n' "$1"
    printf '  source      %s\n' "$2"
    printf '\n== typed results\n'
    printf '%s\n' "$3"
}

# The summary is one table printed by three functions, split where the table
# itself changes subject: what the run was asked about, what the walk found, and
# what the invariants decided. Splitting it further would let a caller print
# half a group; keeping it in one would take sixteen positional arguments.

# The scope rows, which are the checker's own classification.
#
# Arguments: declared observed present absent unexpected undetermined
closure_report_summary_open() {
    printf '\n== summary\n'
    printf '  declared     %s\n' "$1"
    printf '  observed     %s\n' "$2"
    printf '  present      %s\n' "$3"
    printf '  absent       %s\n' "$4"
    printf '  unexpected   %s\n' "$5"
    printf '  undetermined %s\n' "$6"
}

# The walk rows. Every value is passed, for the two reasons the header gives.
#
# Arguments: providers walk walked subjects unread edges refused unreferenced
#            unresolved
closure_report_summary_walk() {
    printf '  providers    %s directories, %s names\n' "$1" \
        "${CLOSURE_PROVIDER_NAMES:-0}"
    printf '  walk         %s\n' "$2"
    printf '  walked       %s files\n' "$3"
    printf '  subjects     %s ELF objects\n' "$4"
    printf '  unread       %s objects, reported UNDETERMINED\n' "$5"
    printf '  edges        %s DT_NEEDED edges\n' "$6"
    printf '  refused      %s unresolvable DT_NEEDED\n' "$7"
    printf '  unreferenced %s subjects no edge resolves to\n' "$8"
    printf '  unresolved   %s link chains, reported UNDETERMINED\n' "$9"
}

# The invariant rows and the partial verdict. These counters are read rather
# than passed: the rules module initialises all of them to 0 at file scope, so
# an absent module and a phase that did not run read the same 0 the row means.
#
# Arguments: bundle-read
closure_report_summary_invariants() {
    # THE FLOOR ROW DID NOT CHANGE SHAPE WHEN WAIVERS ARRIVED, and that is
    # deliberate rather than incidental. A member carried by a waiver is absent
    # and unrefused, which the waiver row below states under its own subject; a
    # third column here would have said the same number twice and moved five
    # step 4 assertions to say it.
    printf '  floor        %s declared, %s refused\n' "${CLOSURE_RULES_FLOOR:-0}" "${CLOSURE_RULES_FLOOR_REFUSED:-0}"
    printf '  waivers      %s declared, %s active, %s refused\n' "${CLOSURE_RULES_WAIVERS:-0}" "${CLOSURE_RULES_WAIVED:-0}" "${CLOSURE_RULES_WAIVER_REFUSED:-0}"
    printf '  coherence    %s needs, %s answered, %s refused\n' "${CLOSURE_RULES_NEEDS:-0}" "${CLOSURE_RULES_ANSWERED:-0}" "${CLOSURE_RULES_COHERENCE_REFUSED:-0}"
    printf '  duplicates   %s names, %s multi-candidate, %s refused\n' "${CLOSURE_RULES_LOOKUPS:-0}" "${CLOSURE_RULES_MULTI:-0}" "${CLOSURE_RULES_RULE1_REFUSED:-0}"
    printf '  families     %s declared, %s refused\n' "${CLOSURE_RULES_FAMILIES:-0}" "${CLOSURE_RULES_RULE2_REFUSED:-0}"
    printf '  entrypoints  %s declared, %s subjects named, %s reached by neither half\n' "${CLOSURE_RULES_ENTRYPOINTS:-0}" "${CLOSURE_RULES_ENTRYSUBJECTS:-0}" "${CLOSURE_RULES_UNREACHABLE:-0}"
    printf '  results      %s UNDETERMINED from the invariants\n' "${CLOSURE_RULES_UNDETERMINED:-0}"
    # Said on every run, green ones included, and it names what a run ANSWERED so
    # a declaration nobody read cannot read as an invariant nobody failed. No
    # claim is made about runtime host fallback, which only a running process can
    # show.
    printf '  verdict is PARTIAL: scope, membership in both halves, coherence,\n'
    printf '  duplicate providers and declared families, with the declared halves\n'
    printf '  answered only where a bundle supplied them: bundle read %s\n' "$1"
}

# One refusal line per invariant that refused, and non-zero so the caller can
# accumulate. The wording is this file's because the report is, and the
# invariants themselves print their typed results and no verdict.
closure_report_refused() {
    if [ "$2" -eq 0 ]; then return 0; fi
    printf '\nCLOSURE %s REFUSED: %s: %s\n' "$1" "$3" "$2"
    return 1
}

# EVERY REFUSAL IS PRINTED, not the first one. Each invariant is independent, so
# a reader repairing an archive should see all of them rather than one per run.
# The return is the aggregate: non-zero when anything refused, and the CALLER
# turns that into the exit code, because the exit code is not this file's.
#
# Arguments: the two counts the checker owns, its own scope refusals and the
# derived membership half; the other four are read from the rules module.
closure_report_refusals() {
    local verdict=0
    closure_report_refused SCOPE "$1" 'undeclared directories in the observed loader scope' || verdict=1
    closure_report_refused MEMBERSHIP "$2" 'DT_NEEDED names resolving nowhere in the observed loader scope' || verdict=1
    closure_report_refused FLOOR "${CLOSURE_RULES_FLOOR_REFUSED:-0}" 'declared floor members absent or outside their required location' || verdict=1
    closure_report_refused COHERENCE "${CLOSURE_RULES_COHERENCE_REFUSED:-0}" 'version needs the selected provider does not satisfy' || verdict=1
    closure_report_refused DUPLICATE "${CLOSURE_RULES_RULE1_REFUSED:-0}" 'lookup names whose candidates hold different content' || verdict=1
    closure_report_refused FAMILY "${CLOSURE_RULES_RULE2_REFUSED:-0}" 'declared families over their permitted generation count' || verdict=1
    closure_report_refused WAIVER "${CLOSURE_RULES_WAIVER_REFUSED:-0}" 'waivers that are unknown to the declared floor or whose removal condition is already met' || verdict=1
    return "$verdict"
}

# The line a run prints when it refused nothing and an exception carried it. It
# is NOT a pass and it is not a refusal: the archive such a run gates is a
# VALIDATION ARTIFACT, and the boundary that acts on that is publication, which
# refuses it with no mode and no flag that permits one.
closure_report_exceptions() {
    printf '\nCLOSURE VALIDATION ARTIFACT: %s active waiver(s) carried this run, so the archive it gates is not publishable\n' \
        "$1"
}

# One UNDETERMINED line, named by its kind. The caller decides that a run is
# undetermined and what it returns; this prints the sentence that says which
# question stayed open.
closure_report_undetermined() {
    printf '\nCLOSURE %s UNDETERMINED: %s\n' "$1" "$2"
}

# The closing lines of a run that refused nothing and left nothing open. The
# membership and invariant lines are printed only where the subject phase ran,
# because a line naming zero edges over zero subjects would read as a checked
# tree rather than as a phase that never started.
#
# Arguments: declared present absent subjects-ran edges subjects unreferenced
closure_report_ok() {
    printf '\nCLOSURE SCOPE OK: %s declared, %s present, %s absent, nothing undeclared\n' \
        "$1" "$2" "$3"
    if [ "$4" -eq 1 ]; then
        printf 'CLOSURE MEMBERSHIP OK: %s edges over %s subjects all resolve, %s reached by no edge\n' \
            "$5" "$6" "$7"
        printf 'CLOSURE INVARIANTS OK: %s floor members, %s version needs answered, %s multi-candidate names, %s families\n' \
            "${CLOSURE_RULES_FLOOR:-0}" "${CLOSURE_RULES_ANSWERED:-0}" "${CLOSURE_RULES_MULTI:-0}" "${CLOSURE_RULES_FAMILIES:-0}"
    fi
}

# ============================================================================
# THE EVIDENCE RECORD, WHICH IS THIS MODULE'S SECOND SUBJECT AND THE SAME ONE.
# The topology table gives the report module how a run's outcome is RENDERED,
# and the evidence document is exactly that in a machine grammar rather than a
# human one: the same counters, fixed into one byte sequence a second program
# can read back. Step 6 wrote it into `closure_verify.sh` because the grammar
# module was full, which left publication sourcing the DRIVER to obtain a
# reader; round 2 of the step 6 review found that stale against the topology
# text and the plan moved the responsibility here rather than restating it.
#
# THE MODULE STILL OWNS NO VERDICT. `closure_evidence_parse` DERIVES one from
# the records it just read and compares it against the one the document
# asserts, which is a grammar rule and not a decision: a document whose verdict
# contradicts its own observations is refused, and what a RUN returns stays
# with `closure_check.sh` and `closure_verify.sh` exactly as before.
#
# IT NEEDS THE LEXER, so a caller that has not sourced `closure_config.sh`
# first gets nothing from these functions. `closure_check.sh` sources the
# configuration module before this one, and the two new callers, the
# verification driver and publication, do the same.
CLOSURE_EVIDENCE_VERSION="CPLX-CLOSURE-EVIDENCE/1"

# --------------------------------------------------------- the evidence records ---
# THE THIRD TABLE, and the only one a MACHINE writes rather than a person, which
# is why it refuses the blank lines and comment lines the other two ignore: one
# observation must have exactly one byte sequence, so comparing two evidence
# documents compares meaning rather than formatting.
#
# THE VERDICT IS DERIVED HERE AND NEVER TRUSTED. A document whose `verdict`
# contradicts its own paired observations, or asserts PASS over an unexpected
# finding, is refused before publication reads a field of it. An emitter cannot
# assert a verdict its own records deny, which is what lets step 2 of the
# publication order treat this document as evidence rather than as a claim.
#
# `post` MIRRORS `pre`, path for path and in order. The declared shape is derived
# once and walked in the loader order on both sides, so a missing, extra or
# reordered pair describes two different shapes with nothing left to compare.
#
# THE MODEL IS DECLARED BY ITS RESET AND NOWHERE ELSE. `closure_evidence_parse`
# resets before it reads and nothing reads the model earlier, so the only name
# that has to exist first is the associative one: assigning to it while unset
# would create an INDEXED array and the duplicate test would stop working.
declare -A CLOSURE_EVI_SEEN=()

# The pre-install half: one record per declared candidate directory, in the order
# the shape derivation emits, the loader order and not an alphabet.
closure_evi_pre() {
    local n="$1" path="$2" state="$3"
    if [ -n "${CLOSURE_EVI_SEEN[$path]:-}" ]; then
        closure_cfg_refuse "$n" duplicate "pre names $path twice"
        return 0
    fi
    CLOSURE_EVI_SEEN["$path"]=1
    CLOSURE_EVI_PATHS+=("$path")
    CLOSURE_EVI_STATES+=("$state")
}

# The installed half, checked against the pre half AT ITS POSITION. A divergence
# is COUNTED here rather than decided: the verdict is one derivation over all of
# them, taken once the whole document has been read.
closure_evi_post() {
    local n="$1" path="$2" state="$3" i="$CLOSURE_EVI_POSTS"
    CLOSURE_EVI_POSTS=$((CLOSURE_EVI_POSTS + 1))
    if [ "$i" -ge "${#CLOSURE_EVI_PATHS[@]}" ]; then
        closure_cfg_refuse "$n" pairing "post names $path and pre declares no such position"
    elif [ "${CLOSURE_EVI_PATHS[$i]}" != "$path" ]; then
        closure_cfg_refuse "$n" pairing "post names $path where pre names ${CLOSURE_EVI_PATHS[$i]}"
    elif [ "${CLOSURE_EVI_STATES[$i]}" != "$state" ]; then
        CLOSURE_EVI_DIVERGENT=$((CLOSURE_EVI_DIVERGENT + 1))
    fi
}

# The record table, and where the FIXED ORDER is enforced: a token stage may not
# go backwards, so archive, config, every pre, every post, verdict and every
# unexpected is the one shape this document has. Interleaved records parse to the
# same model and are not the same bytes, which is what canonical means here.
closure_evi_record() {
    local n="$1" count="$2" token="${CLOSURE_LEX_FIELDS[0]}" stage=0
    case "$token" in
        'archive') stage=1 ;;
        'config') stage=2 ;;
        'pre') stage=3 ;;
        'post') stage=4 ;;
        'verdict') stage=5 ;;
        'unexpected') stage=6 ;;
        *) closure_cfg_refuse "$n" unknown-record "$token"; return 0 ;;
    esac
    if [ "$stage" -lt "$CLOSURE_EVI_STAGE" ]; then
        closure_cfg_refuse "$n" order "$token cannot follow $CLOSURE_EVI_LAST"
        return 0
    fi
    CLOSURE_EVI_STAGE="$stage"
    CLOSURE_EVI_LAST="$token"
    case "$token" in
        'archive'|'config')
            closure_cfg_count "$n" "$token" 2 "$count" || return 0
            closure_cfg_domain "$n" "$token" sha256 "${CLOSURE_LEX_FIELDS[1]}" || return 0
            if [ "$token" = "archive" ]; then
                CLOSURE_EVI_ARCHIVE="${CLOSURE_LEX_FIELDS[1]}"
                CLOSURE_EVI_ARCHIVES=$((CLOSURE_EVI_ARCHIVES + 1))
            else
                CLOSURE_EVI_CONFIG="${CLOSURE_LEX_FIELDS[1]}"
                CLOSURE_EVI_CONFIGS=$((CLOSURE_EVI_CONFIGS + 1))
            fi ;;
        'pre'|'post')
            closure_cfg_count "$n" "$token" 3 "$count" || return 0
            closure_cfg_domain "$n" candidate repo-path "${CLOSURE_LEX_FIELDS[1]}" || return 0
            closure_cfg_domain "$n" presence presence "${CLOSURE_LEX_FIELDS[2]}" || return 0
            if [ "$token" = "pre" ]; then
                closure_evi_pre "$n" "${CLOSURE_LEX_FIELDS[1]}" "${CLOSURE_LEX_FIELDS[2]}"
            else
                closure_evi_post "$n" "${CLOSURE_LEX_FIELDS[1]}" "${CLOSURE_LEX_FIELDS[2]}"
            fi ;;
        'verdict')
            closure_cfg_count "$n" verdict 2 "$count" || return 0
            closure_cfg_domain "$n" verdict verdict "${CLOSURE_LEX_FIELDS[1]}" || return 0
            CLOSURE_EVI_VERDICT="${CLOSURE_LEX_FIELDS[1]}"
            CLOSURE_EVI_VERDICTS=$((CLOSURE_EVI_VERDICTS + 1)) ;;
        'unexpected')
            closure_cfg_count "$n" unexpected 3 "$count" || return 0
            closure_cfg_domain "$n" side side "${CLOSURE_LEX_FIELDS[1]}" || return 0
            closure_cfg_domain "$n" candidate repo-path "${CLOSURE_LEX_FIELDS[2]}" || return 0
            CLOSURE_EVI_UNEXPECTED=$((CLOSURE_EVI_UNEXPECTED + 1)) ;;
    esac
}

closure_evidence_reset() {
    CLOSURE_CFG_BAD=0
    # The two fields publication reads and this file never does: the whole of what
    # step 2 of the publication order asks a parsed document for.
    # shellcheck disable=SC2034  # read by closure_publish.sh through this reader
    CLOSURE_EVI_ARCHIVE=""
    # shellcheck disable=SC2034  # read by closure_publish.sh through this reader
    CLOSURE_EVI_CONFIG=""
    CLOSURE_EVI_VERDICT=""
    CLOSURE_EVI_ARCHIVES=0
    CLOSURE_EVI_CONFIGS=0
    CLOSURE_EVI_VERDICTS=0
    CLOSURE_EVI_UNEXPECTED=0
    CLOSURE_EVI_DIVERGENT=0
    CLOSURE_EVI_STAGE=0
    CLOSURE_EVI_LAST=""
    CLOSURE_EVI_POSTS=0
    CLOSURE_EVI_PATHS=()
    CLOSURE_EVI_STATES=()
    CLOSURE_EVI_SEEN=()
}

# THE CONFLICT NAMES ONE IDENTITY PRODUCES, derived from the keyed path and never
# found by scanning the results root: the root is not searched, and no location is
# derived from where the archive sits. A retained conflict means two DIFFERENT
# results exist for one set of bytes, and the rule the emitter promotes under says
# which one is wrong is a human decision.
closure_evidence_conflicts() {
    local canonical="$1" path=""
    for path in "$canonical".conflict.*; do
        if [ -e "$path" ]; then printf '%s\n' "$path"; fi
    done
}

# THE ONLY READER OF THE EVIDENCE CONTRACT, shared by the emitter and by the
# publication step that consumes it: two readers would be two interpretations of
# one file, the drift Q01 refuses one level down. The derivation is the last thing
# it does, and it is why a self-contradictory document returns non-zero: PASS
# requires every paired observation to agree AND no unexpected finding.
#
# AN UNRESOLVED CONFLICT IS REFUSED BEFORE A FIELD IS READ, and it belongs to the
# reader because the reader is the ONE gate both consumers pass through. A record
# beside which a differing result is retained is not evidence about its archive:
# it is two answers, and reading either one as the answer is the silent
# overwrite the promotion rule exists to prevent. Round 1 of the step 6 review
# found publication proceeding past exactly that.
closure_evidence_parse() {
    local derived="PASS"
    closure_evidence_reset
    if [ -n "$(closure_evidence_conflicts "$1")" ]; then
        closure_cfg_refuse 0 conflict "a differing verification result is retained beside $1, and which of the two is wrong is a human decision"
        return 1
    fi
    closure_stream_read "$1" "$CLOSURE_EVIDENCE_VERSION" evidence "evidence document"
    if [ "$CLOSURE_EVI_ARCHIVES" -ne 1 ] || [ "$CLOSURE_EVI_CONFIGS" -ne 1 ]; then
        closure_cfg_refuse 0 cardinality "the document carries $CLOSURE_EVI_ARCHIVES archive and $CLOSURE_EVI_CONFIGS config records, and must carry exactly one of each"
    fi
    if [ "$CLOSURE_EVI_VERDICTS" -ne 1 ]; then
        closure_cfg_refuse 0 cardinality "the document carries $CLOSURE_EVI_VERDICTS verdict records and must carry exactly one"
    fi
    if [ "${#CLOSURE_EVI_PATHS[@]}" -eq 0 ]; then
        closure_cfg_refuse 0 cardinality "the document observes no declared candidate directory on either side"
    fi
    if [ "$CLOSURE_EVI_POSTS" -ne "${#CLOSURE_EVI_PATHS[@]}" ]; then
        closure_cfg_refuse 0 pairing "the document carries ${#CLOSURE_EVI_PATHS[@]} pre records and $CLOSURE_EVI_POSTS post records"
    fi
    if [ "$CLOSURE_EVI_DIVERGENT" -ne 0 ] || [ "$CLOSURE_EVI_UNEXPECTED" -ne 0 ]; then
        derived="DIVERGENT"
    fi
    if [ "$CLOSURE_CFG_BAD" -eq 0 ] && [ "$CLOSURE_EVI_VERDICT" != "$derived" ]; then
        closure_cfg_refuse 0 verdict "the document asserts $CLOSURE_EVI_VERDICT and its own records derive $derived"
    fi
    [ "$CLOSURE_CFG_BAD" -eq 0 ]
}

# THE STORE THE RECORD LIVES IN, moved here by round 3 of the Step 6 review under
# the rule that put the record here in round 2: a module that would exceed the
# ceiling moves a responsibility to the module that already owns its neighbours,
# and this store's neighbours are all here. `closure_evidence_parse` reads what it
# writes, `closure_evidence_conflicts` derives the names it creates, and both of
# its CONSUMERS, the publication gate and the driver's own read-back, already
# reach this module. Only the writer was in the driver.
#
# THE DRIVER STILL DECIDES WHAT A RUN RETURNS. This module owns no verdict and no
# exit code, here as everywhere else: the store answers whether a document was
# retained, and the driver answers what that means for the run.
closure_evidence_refuse() {
    printf 'VERIFICATION REFUSED: %s\n' "$1" >&2
}

# The digest of one file, which the store asks twice: once to compare a rerun
# against the canonical result, and once to check that a retained conflict came
# out whole before the only other copy is removed.
closure_evidence_digest() {
    local out=""
    out=$(sha256sum -- "$1" 2>/dev/null) || return 1
    printf '%s' "${out%% *}"
}
# ------------------------------------------------------- the evidence store ---

# VALIDATED BEFORE ANY WRITE, and every failure is a refusal rather than a
# warning. The symlink test is FIRST, because a symlink to a good directory passes
# every later test while putting the evidence somewhere else; ownership and the
# group-and-other write bits stop another account replacing a promoted result. The
# permission question uses `find`, on this effort's contract, and not `stat`.
closure_evidence_root_check() {
    local root="$1"
    if [ -L "$root" ]; then
        closure_evidence_refuse "the results root $root is a symlink"
        return 1
    fi
    if [ ! -d "$root" ]; then
        closure_evidence_refuse "the results root $root is not a directory"
        return 1
    fi
    if [ ! -O "$root" ]; then
        closure_evidence_refuse "the results root $root is not owned by the running user"
        return 1
    fi
    if [ -n "$(find "$root" -maxdepth 0 -perm /022 2>/dev/null)" ]; then
        closure_evidence_refuse "the results root $root is writable by group or other"
        return 1
    fi
    return 0
}

# ONLY A COMPLETE RESULT EVER OCCUPIES THE CANONICAL PATH. The document is written
# to an exclusively created temporary file in the SAME directory and promoted by a
# no-overwrite link, so a crashed write leaves nothing at the canonical name and a
# rerun proceeds. The no-overwrite rule alone would have made one transient
# failure leave an archive unverifiable forever.
#
# THREE OUTCOMES WHEN THE NAME IS TAKEN, not one. A byte-identical result is
# IDEMPOTENT: a rerun that agrees with itself changed nothing. A DIFFERENT result
# is retained beside the canonical file under a timestamped conflict name and
# STOPS the run, because two different results for one set of bytes means one is
# wrong and which one is a human decision. Nothing is silently overwritten.
closure_evidence_emit() {
    local root="$1" identity="$2" body="$3"
    local canonical="$root/$identity" tmp="" mine="" theirs="" stamp=""

    closure_evidence_root_check "$root" || return 1
    printf -v stamp '%(%Y%m%dT%H%M%S)T' -1
    # THE DOCUMENT IS WRITTEN UNDER THE CONFLICT NAME IT MIGHT NEED, always and
    # without asking first whether the canonical name is taken. Five review
    # rounds converged on this one line. While the conflict name was created
    # after the bytes, SOME operation could always fail once a differing document
    # existed, and the reader then saw nothing under the archive key: one shape
    # deleted the bytes, one kept them where the lookup does not read, one kept
    # them whole and anonymous, and the last asked the occupancy question first
    # and lost the answer to a concurrent writer. Asking that question at all is
    # what leaves a window, so it is not asked.
    #
    # WHAT THIS COSTS is a conflict-named file that exists for the length of one
    # link on the ordinary path, and a crash inside that window leaves a name a
    # human must clear. That direction is deliberate: a crash that leaves a STOP
    # is recoverable, and a crash that leaves a missed stop publishes an archive
    # whose verification disagreed. The canonical rule is untouched, because the
    # canonical name is still only ever occupied by a complete result.
    tmp=$(mktemp "$canonical.conflict.$stamp.XXXXXXXX" 2>/dev/null) || tmp=""
    if [ -z "$tmp" ]; then
        closure_evidence_refuse "no exclusive temporary file could be created in $root"
        return 1
    fi
    if ! cat -- "$body" > "$tmp"; then
        rm -f -- "$tmp"
        closure_evidence_refuse "the evidence document could not be written in $root"
        return 1
    fi
    chmod 0444 -- "$tmp" 2>/dev/null
    # LINK, NEVER RENAME, and -T for the reason publication uses it: `ln` fails if
    # the name exists, which IS the no-overwrite guarantee, and -T refuses a
    # directory or a symlink to one rather than linking inside it. The link makes
    # the canonical name a second name for these same bytes, so removing the
    # conflict name afterwards keeps the result and drops only the placeholder.
    if ln -T -- "$tmp" "$canonical" 2>/dev/null; then
        rm -f -- "$tmp"
        printf 'EVIDENCE|%s|%s\n' WRITTEN "$canonical"
        return 0
    fi
    mine=$(closure_evidence_digest "$tmp")
    theirs=$(closure_evidence_digest "$canonical")
    if [ -n "$mine" ] && [ "$mine" = "$theirs" ]; then
        # THE PLACEHOLDER GOES FIRST, so this run's own name is not read as the
        # disagreement it was holding a place for.
        rm -f -- "$tmp"
        # AN UNRESOLVED CONFLICT STOPS THE AGREEING RERUN TOO, and round 1 of the
        # step 6 review is why. A rerun that matches the canonical file was
        # reporting IDEMPOTENT and returning 0 while two different results for
        # these bytes were still on disk: agreeing with one of two answers is not
        # resolving them, and the recovery rule is a human's.
        if [ -n "$(closure_evidence_conflicts "$canonical")" ]; then
            closure_evidence_refuse "a differing result is retained beside $canonical, and a rerun that agrees with one of the two does not resolve them"
            return 1
        fi
        printf 'EVIDENCE|%s|%s\n' IDEMPOTENT "$canonical"
        return 0
    fi
    # A DIFFERENT RESULT, ALREADY AT ITS NAME AND NEVER MOVED TO GET THERE. This
    # is reached whether the canonical result was there before this run started
    # or a concurrent writer won it in between, and neither case has an operation
    # left that could lose the disagreement.
    printf 'EVIDENCE|%s|%s\n' CONFLICT "$tmp"
    closure_evidence_refuse "a different result already exists for identity $identity, and which one is wrong is a human decision"
    return 1
}
