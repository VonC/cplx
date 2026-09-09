#!/bin/bash
# The closure checker's REPORT, and nothing else.
#
# This is the fifth module of the delivered script topology, and the only one
# added after Step 1. The topology table in
# `docs/v0.27.0/plan.v0.27.0.toolchain-runtime-closure.md` fixes what it owns:
# the summary block, the partial verdict, the refusal lines and the closing
# lines. It owns NO VERDICT AND NO EXIT CODE. `closure_check.sh` still decides
# what a run returns, because that exit code is the checker's contract with
# `pkg.sh` and moving it would move the gate itself.
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
