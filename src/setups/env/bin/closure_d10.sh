#!/bin/bash
# The D10 INTERFACE: the reading umbrella item 7 supplies, and the policy
# requirement 4 owns, joined by the one file that implements both ends.
#
# The issue settled D10 as a conditional policy and named item 7 as the supplier
# of its evidence. Neither document defined what passed between them, and Design
# Area 6 is where that interface was decided. This file is that decision in
# code, and nothing else: it takes no invariant, it ships inside no archive, and
# it produces no verdict about closure.
#
# THE EVIDENCE HAS TWO HALVES, AND THE ROUND 2 FINDING IS WHY. An earlier
# revision of the design's evidence table described only the provider that
# HAPPENS TO SHIP, and a table shaped that way cannot answer the question D10
# asks: whether a candidate generation that does NOT ship would satisfy the
# archive. So the reading carries what the archive REQUIRES, taken from its own
# objects, and what EACH CANDIDATE GENERATION PROVIDES, taken from that
# generation's own libraries. The two are read from different trees and are
# never derived from one another.
#
# THE CONSUMER SET IS THIS DESIGN'S SUBJECT SET AND NOT A CLOSURE. Every shipped
# ELF that records a `DT_NEEDED` on `libstdc++.so.6` is a consumer, taken from
# the ONE WALK `closure_elf.sh` owns. A reading that walked from the entry points
# would miss the 76 extension modules Design Area 2 measured, and would answer
# the compiler question about a minority of the archive while reporting it as
# the archive's answer.
#
# THE READING GENERATION IS RECOMPUTED, NEVER DECLARED. Which generation built
# the archive is a property of the bytes it ships, so this file derives it by
# comparing the shipped providers against the candidate providers rather than
# accepting an argument that says so. That is the same rule publication follows
# for the archive identity and the configuration digest, applied to the one
# remaining claim this interface could have been asked to take on trust: an
# option naming the generation would be a claim, and the whole of Design Area 7
# exists because a claim is not an identity.
#
# ZERO SPARE NODES IS ALLOWED. The condition is SATISFACTION, not headroom, and
# the difference is load bearing: "the margin is gone" is ambiguous between zero
# headroom and an unsupported node, and only the second is a failure. The
# measured position today, an agent serving `GLIBCXX_3.4.30` against a shipped
# GCC 11 topping out at `3.4.29`, is a PASS under this policy and not a trigger.
#
# THE RESULT FOLLOWS THE CANDIDATE CAPABILITIES AND NEVER THE SHIPPED
# GENERATION, which is the other thing an earlier version got wrong: an archive
# already carrying GCC 12 and satisfied by GCC 11 would have been scored as GCC
# 11 by the shipped bytes and as GCC 12 by the reading, and those are two
# different answers to one question.
#
# WHY AN UNREADABLE CANDIDATE IS INCONCLUSIVE RATHER THAN UNSATISFYING. A
# capability entry nobody could read defines no node, and scoring it that way
# would DEMOTE a generation for being unmeasurable. That is the mirror of the
# empty observation this whole effort refuses, so it is reported as an input
# that could not be obtained, with the exit code the checker already uses for
# one.
#
# WHAT THIS FILE IS NOT PART OF. It is not one of the five checker modules, it
# is not staged into the archive, and no shipped script sources it. The delivered
# script topology places it in cplx only, run on the build account, consumed by
# item 7. Its host tools are the checker's own and it reaches both of them
# through `closure_elf.sh` rather than directly, so the enumerated contract
# gains no row for it.
#
# Item 7 adds independently captured wheel roots. Their lock and installed ELF
# identities are checked before joining the consumer union. Archive provider
# identity is snapshotted first; wheel providers never change that snapshot.

set -u

CLOSURE_D10_DIR="${BASH_SOURCE[0]%/*}"
if [ "$CLOSURE_D10_DIR" = "${BASH_SOURCE[0]}" ]; then
    CLOSURE_D10_DIR="."
fi
# The object reader and the one walk, called rather than reimplemented. This is
# the only file it sources: the invariants, the grammar and the report answer
# questions D10 does not ask, and sourcing them would give this file a verdict
# it must not have.
# shellcheck source=/dev/null
if [ -f "$CLOSURE_D10_DIR/closure_elf.sh" ]; then
    source "$CLOSURE_D10_DIR/closure_elf.sh"
fi

CLOSURE_D10_USAGE="Usage: closure_d10.sh --root DIR --candidate GEN=DIR [--candidate GEN=DIR]... [--previous RESULT] [--wheel-root DIR ... --wheel-lock FILE --wheel-python /absolute/python]"

# The two providers the policy is about, and the namespaces each answers for.
# They are named once here rather than at each test site, because the pairing is
# the decision: libstdc++ provides BOTH `GLIBCXX_` and `CXXABI_`, and `libgcc_s`
# is checked separately against its own `GCC_` needs.
CLOSURE_D10_STDCXX="libstdc++.so.6"
CLOSURE_D10_GCC_S="libgcc_s.so.1"

# The three non-generation results, as tokens rather than as sentences, so a
# caller compares a value instead of matching prose.
CLOSURE_D10_NEITHER="NEITHER"
CLOSURE_D10_INCONCLUSIVE="INCONCLUSIVE"

# ---------------------------------------------------------------- the model ---
# The four fields of the design's evidence table, in the shape each is asked in.
# `CLOSURE_D10_CANDIDATES` is ORDERED, LOWEST FIRST, and that order is the whole
# of what "the lowest satisfying candidate" means here: nothing in a generation
# label tells a shell that 11 precedes 12, so the caller's argument order is the
# ordering, and `closure_d10_converge` reads the same list to say whether a
# second result was higher or lower.
CLOSURE_D10_READING=""
CLOSURE_D10_CANDIDATES=()
CLOSURE_D10_CONSUMERS=()
CLOSURE_D10_REQUIRED=()
CLOSURE_D10_UNREAD=0
CLOSURE_D10_RESULT=""
CLOSURE_D10_REASON=""
declare -A CLOSURE_D10_SEEN=()
declare -A CLOSURE_D10_DEFINES=()
declare -A CLOSURE_D10_IDENTITY=()
declare -A CLOSURE_D10_ORIGIN=()
declare -A CLOSURE_D10_DIGEST=()
CLOSURE_D10_WHEEL_ROOTS=()
CLOSURE_D10_WHEEL_LOCK=""
CLOSURE_D10_WHEEL_PYTHON=""
CLOSURE_D10_WHEEL_WALKS=0

# THE ARCHIVE'S OWN SIDE, TAKEN BEFORE ANY CANDIDATE IS READ, and held here
# rather than re-derived later. `closure_elf_read` appends to the reader's
# subject list whatever it is pointed at, so reading a candidate's providers
# would put files that are NOT in the archive into the set every count and every
# lookup below is stated over. Snapshotting is what keeps the two scopes apart,
# which is the same separation Design Area 1 makes between a declared shape and
# an observed one: two readings taken from two trees, never merged.
CLOSURE_D10_SUBJECTS=0
declare -A CLOSURE_D10_SHIPPED=()

closure_d10_reset() {
    CLOSURE_D10_READING=""
    CLOSURE_D10_CANDIDATES=()
    CLOSURE_D10_CONSUMERS=()
    CLOSURE_D10_REQUIRED=()
    CLOSURE_D10_UNREAD=0
    CLOSURE_D10_RESULT=""
    CLOSURE_D10_REASON=""
    CLOSURE_D10_SUBJECTS=0
    CLOSURE_D10_SEEN=()
    CLOSURE_D10_DEFINES=()
    CLOSURE_D10_IDENTITY=()
    CLOSURE_D10_SHIPPED=()
    CLOSURE_D10_ORIGIN=()
    CLOSURE_D10_DIGEST=()
    CLOSURE_D10_WHEEL_WALKS=0
}

# One required node, recorded ONCE and in first-seen order. Several consumers
# demanding one node is the ordinary shape and it is one requirement, so the set
# is deduplicated here rather than at comparison time: the policy walks it once
# per candidate, and a list carrying a node per consumer would make that walk
# grow with the archive instead of with the requirement.
closure_d10_requires() {
    local key="$1|$2"
    if [ -n "${CLOSURE_D10_SEEN[$key]:-}" ]; then return 0; fi
    CLOSURE_D10_SEEN["$key"]=1
    CLOSURE_D10_REQUIRED+=("$key")
}

# THE NAMESPACE FILTER, which is the comparison the issue fixed. A node is a D10
# requirement only where the provider and the namespace agree: `GLIBCXX_` and
# `CXXABI_` against libstdc++, `GCC_` against libgcc_s. Anything else recorded by
# a consumer is a need about some other library and no business of this policy.
# THE NAMESPACES ARE A TABLE RATHER THAN CASE PATTERNS, which is worth a line
# because it is not a matter of taste. A bare `GLIBCXX_*` pattern sits in
# COMMAND POSITION to the mechanical host-tool assertion, which reads the first
# token of a line and of every `|` alternative, so the shipped-word check would
# report `GLIBCXX_` and `CXXABI_` as undeclared commands. Held as values and
# matched through a variable, the same rule reads them as data, which is what
# they are: the pairing of a provider with the namespaces it answers for.
CLOSURE_D10_NS_STDCXX="GLIBCXX_ CXXABI_"
CLOSURE_D10_NS_GCC_S="GCC_"

closure_d10_in_scope() {
    local prefixes="" ns
    case "$1" in
        "$CLOSURE_D10_STDCXX") prefixes="$CLOSURE_D10_NS_STDCXX" ;;
        "$CLOSURE_D10_GCC_S") prefixes="$CLOSURE_D10_NS_GCC_S" ;;
        *) return 1 ;;
    esac
    for ns in $prefixes; do
        case "$2" in "$ns"*) return 0 ;; esac
    done
    return 1
}

# THE SHIPPED PROVIDERS, RECORDED BY SONAME, which is how a provider in the
# archive is found without resolving a link. The walk records regular files, so
# `libstdc++.so.6` in the tree is a link and the subject is the real
# `libstdc++.so.6.0.29` beside it: the two share no name and DO share the soname
# the object itself records.
#
# It runs once, over the pristine subject list, and stores a DIGEST rather than a
# path. A path would have to be re-read after the candidates were, and by then
# the reader's list holds files from another tree.
closure_d10_snapshot() {
    local path soname
    CLOSURE_D10_SUBJECTS="${#CLOSURE_ELF_PATHS[@]}"
    for path in ${CLOSURE_ELF_PATHS[@]+"${CLOSURE_ELF_PATHS[@]}"}; do
        soname="${CLOSURE_ELF_SONAME[$path]:-}"
        case "$soname" in
            "$CLOSURE_D10_STDCXX"|"$CLOSURE_D10_GCC_S") ;;
            *) continue ;;
        esac
        if [ -n "${CLOSURE_D10_SHIPPED[$soname]:-}" ]; then continue; fi
        if closure_elf_digest "$path"; then
            CLOSURE_D10_SHIPPED["$soname"]="$CLOSURE_ELF_DIGEST_RESULT"
        fi
    done
}

# One candidate generation's capability entry: its identity and the nodes each of
# its two providers defines. The identity is the DIGEST of the provider file the
# entry was read from, for the same reason every other identity in this effort is
# a digest: a label says which generation somebody meant, and a digest says which
# bytes were measured.
#
# A provider that could not be read raises the UNREAD count and defines nothing.
# The caller reports that as inconclusive rather than letting an unmeasurable
# generation lose on an empty entry.
closure_d10_capability() {
    local gen="$1" dir="$2" provider path node
    for provider in "$CLOSURE_D10_STDCXX" "$CLOSURE_D10_GCC_S"; do
        path="$dir/$provider"
        if [ ! -f "$path" ] || ! closure_elf_read "$path"; then
            CLOSURE_D10_UNREAD=$((CLOSURE_D10_UNREAD + 1))
            CLOSURE_D10_REASON="${CLOSURE_D10_REASON:+$CLOSURE_D10_REASON; }the $gen $provider at $path could not be read"
            continue
        fi
        if closure_elf_digest "$path"; then
            CLOSURE_D10_IDENTITY["$gen|$provider"]="$CLOSURE_ELF_DIGEST_RESULT"
        else
            CLOSURE_D10_UNREAD=$((CLOSURE_D10_UNREAD + 1))
            CLOSURE_D10_REASON="${CLOSURE_D10_REASON:+$CLOSURE_D10_REASON; }the $gen $provider at $path could not be digested"
            continue
        fi
        while IFS= read -r node; do
            if [ -n "$node" ]; then CLOSURE_D10_DEFINES["$gen|$provider|$node"]=1; fi
        done <<< "${CLOSURE_ELF_VERDEF[$path]:-}"
    done
}

# WHICH GENERATION BUILT THIS ARCHIVE, derived rather than declared. Both
# providers must match one candidate entry: a tree carrying one generation's
# libstdc++ beside another's libgcc_s is a MIXED build and no candidate describes
# it, so the answer is `unknown` and the re-read rule then applies, which is the
# safe direction. It prints the label and never refuses: an unknown reading
# generation is a fact the policy handles, not an error.
closure_d10_reading_generation() {
    local gen cxx gcc
    cxx="${CLOSURE_D10_SHIPPED[$CLOSURE_D10_STDCXX]:-}"
    gcc="${CLOSURE_D10_SHIPPED[$CLOSURE_D10_GCC_S]:-}"
    if [ -z "$cxx" ] || [ -z "$gcc" ]; then printf 'unknown'; return 0; fi
    for gen in ${CLOSURE_D10_CANDIDATES[@]+"${CLOSURE_D10_CANDIDATES[@]}"}; do
        if [ "${CLOSURE_D10_IDENTITY[$gen|$CLOSURE_D10_STDCXX]:-}" = "$cxx" ] \
           && [ "${CLOSURE_D10_IDENTITY[$gen|$CLOSURE_D10_GCC_S]:-}" = "$gcc" ]; then
            printf '%s' "$gen"
            return 0
        fi
    done
    printf 'unknown'
}

# ------------------------------------------------------------- the reading ---
# THE FOUR-FIELD READING of the design's evidence table: the reading generation,
# the consumer set, the required nodes, and one capability entry per candidate
# generation.
#
# THE ORDER IS THE SEPARATION AND NOT A PREFERENCE. The archive is walked, then
# everything the ARCHIVE answers is taken while the reader's subject list still
# holds the archive alone, and only then are the candidate trees read. Reading a
# candidate first would append files from another tree to that list, and every
# count and lookup below would be stated over a set that is no longer the
# archive. The reading generation comes last because it is the one field derived
# from BOTH halves.
closure_d10_evidence() {
    local root="$1" spec gen dir line provider key
    shift
    closure_d10_reset

    # Each reading owns a fresh reader model, including its path and digest
    # caches. Re-source the reader's initialization rather than retaining the
    # previous archive or its candidate providers in this reading's subject set.
    # shellcheck source=/dev/null
    if ! source "$CLOSURE_D10_DIR/closure_elf.sh"; then
        CLOSURE_D10_UNREAD=1
        CLOSURE_D10_REASON="the object reader could not be initialized"
        return 5
    fi
    closure_subjects_walk "$root"
    if [ ! -d "$root" ]; then CLOSURE_ELF_WALK_STATE=missing; fi
    if [ "$CLOSURE_ELF_UNREAD" -ne 0 ] || [ "$CLOSURE_ELF_WALK_STATE" != complete ]; then
        CLOSURE_D10_UNREAD=1
        CLOSURE_D10_REASON="the archive reading is incomplete: $CLOSURE_ELF_UNREAD unread object(s), walk: $CLOSURE_ELF_WALK_STATE"
    fi
    closure_d10_snapshot

    # The consumer set and the requirements it records, in one pass over the
    # subjects the walk already read. Nothing is read from disk here: both halves
    # come out of the single `readelf` invocation each object already had.
    closure_d10_consumers 0 "${#CLOSURE_ELF_PATHS[@]}" archive
    for dir in ${CLOSURE_D10_WHEEL_ROOTS[@]+"${CLOSURE_D10_WHEEL_ROOTS[@]}"}; do
        closure_d10_wheel_root "$dir"
    done

    for spec in "$@"; do
        gen="${spec%%=*}"
        dir="${spec#*=}"
        if [ "$gen" = "$spec" ] || [ -z "$gen" ] || [ -z "$dir" ]; then
            CLOSURE_D10_REASON="${CLOSURE_D10_REASON:+$CLOSURE_D10_REASON; }the candidate [$spec] is not of the form GEN=DIR"
            CLOSURE_D10_UNREAD=$((CLOSURE_D10_UNREAD + 1))
            continue
        fi
        CLOSURE_D10_CANDIDATES+=("$gen")
        closure_d10_capability "$gen" "$dir"
    done

    CLOSURE_D10_READING=$(closure_d10_reading_generation)

    printf 'D10 READING\n'
    printf '  reading generation  %s\n' "$CLOSURE_D10_READING"
    if [ "${#CLOSURE_D10_WHEEL_ROOTS[@]}" -eq 0 ]; then
        printf '  consumers           %s of %s shipped objects\n' \
            "${#CLOSURE_D10_CONSUMERS[@]}" "$CLOSURE_D10_SUBJECTS"
    else
        printf '  consumers           %s; archive objects %s\n' \
            "${#CLOSURE_D10_CONSUMERS[@]}" "$CLOSURE_D10_SUBJECTS"
    fi
    printf '  walks archive=1 wheels=%s\n' "$CLOSURE_D10_WHEEL_WALKS"
    printf '  required nodes      %s\n' "${#CLOSURE_D10_REQUIRED[@]}"
    for line in ${CLOSURE_D10_CONSUMERS[@]+"${CLOSURE_D10_CONSUMERS[@]}"}; do
        printf '  consumer %s %s sha256=%s\n' "${CLOSURE_D10_ORIGIN[$line]}" "$line" "${CLOSURE_D10_DIGEST[$line]:-unread}"
    done
    for gen in ${CLOSURE_D10_CANDIDATES[@]+"${CLOSURE_D10_CANDIDATES[@]}"}; do
        for provider in "$CLOSURE_D10_STDCXX" "$CLOSURE_D10_GCC_S"; do
            printf '  candidate %s %s %s\n' "$gen" "$provider" \
                "${CLOSURE_D10_IDENTITY[$gen|$provider]:-unread}"
        done
    done
    for line in ${CLOSURE_D10_REQUIRED[@]+"${CLOSURE_D10_REQUIRED[@]}"}; do
        printf '  require %s\n' "$line"
    done
    for key in "${!CLOSURE_D10_DEFINES[@]}"; do printf '  defines %s\n' "$key"; done
}

# Visit only this walk's slice. Later provider reads append to the reader model,
# but cannot enter the consumer union or alter its already captured provenance.
closure_d10_consumers() {
    local first="$1" last="$2" origin="$3" i path need line provider node
    for ((i=first; i<last; i++)); do
        path="${CLOSURE_ELF_PATHS[$i]}"
        need=0
        while IFS= read -r line; do
            if [ "$line" = "$CLOSURE_D10_STDCXX" ]; then need=1; fi
            # The extended union also carries independent unwind consumers.
            # Archive-only calls retain the inherited libstdc++ subject rule.
            if [ "${#CLOSURE_D10_WHEEL_ROOTS[@]}" -gt 0 ] && [ "$line" = "$CLOSURE_D10_GCC_S" ]; then need=1; fi
        done <<< "${CLOSURE_ELF_NEEDED[$path]:-}"
        if [ "$need" -eq 0 ]; then continue; fi
        CLOSURE_D10_CONSUMERS+=("$path")
        CLOSURE_D10_ORIGIN["$path"]="${CLOSURE_D10_ORIGIN[$path]:-$origin}"
        if closure_elf_digest "$path"; then
            CLOSURE_D10_DIGEST["$path"]="$CLOSURE_ELF_DIGEST_RESULT"
        else
            closure_d10_incomplete "consumer digest unavailable: $path"
        fi
        while IFS= read -r line; do
            if [ -z "$line" ]; then continue; fi
            provider="${line%%|*}"
            node="${line#*|}"
            if closure_d10_in_scope "$provider" "$node"; then
                closure_d10_requires "$provider" "$node"
            fi
        done <<< "${CLOSURE_ELF_VERNEED[$path]:-}"
    done
}

closure_d10_incomplete() {
    CLOSURE_D10_UNREAD=$((CLOSURE_D10_UNREAD + 1))
    CLOSURE_D10_REASON="${CLOSURE_D10_REASON:+$CLOSURE_D10_REASON; }$1"
}

# Describe supplies paths and byte identities, never interpreted ABI demands.
# One closure walk discovers the actual subjects; set equality catches extra,
# absent and unreadable objects before the ordinary D10 policy can succeed.
closure_d10_wheel_root() {
    local root="$1" rows rel sha wheel wheel_sha installed path i first last link
    local -A expected=() origins=() observed=()
    rows=$(bash "$CLOSURE_D10_DIR/tools_wheel_inventory.sh" --python "$CLOSURE_D10_WHEEL_PYTHON" \
        describe --root "$root" --lock "$CLOSURE_D10_WHEEL_LOCK") || {
        closure_d10_incomplete "wheel inventory unavailable: $root"; return 0;
    }
    while IFS=$'\t' read -r rel sha wheel wheel_sha installed; do
        [ -n "$rel" ] || continue
        path="$root/subjects/$rel"
        expected["$path"]="$sha"
        origins["$path"]="wheel:$wheel wheel-sha256=$wheel_sha installed=$installed"
    done <<< "$rows"
    first="${#CLOSURE_ELF_PATHS[@]}"
    CLOSURE_D10_WHEEL_WALKS=$((CLOSURE_D10_WHEEL_WALKS + 1))
    # D10 does not resolve links. Keep this map local to the current wheel walk
    # so rejecting wheel links never rescans all earlier roots' link maps.
    CLOSURE_LINK_TARGET=()
    closure_subjects_walk "$root/subjects"
    last="${#CLOSURE_ELF_PATHS[@]}"
    if [ ! -d "$root/subjects" ] || [ -L "$root/subjects" ] || \
       [ "$CLOSURE_ELF_UNREAD" -ne 0 ] || [ "$CLOSURE_ELF_WALK_STATE" != complete ]; then
        closure_d10_incomplete "wheel subject walk incomplete: $root"
    fi
    for link in "${!CLOSURE_LINK_TARGET[@]}"; do
        if [[ "$link" = "$root/subjects/"* ]]; then closure_d10_incomplete "wheel subject symlink: $link"; fi
    done
    for ((i=first; i<last; i++)); do
        path="${CLOSURE_ELF_PATHS[$i]}"
        observed["$path"]=1
        if [ -z "${expected[$path]:-}" ] || ! closure_elf_digest "$path" || \
           [ "$CLOSURE_ELF_DIGEST_RESULT" != "${expected[$path]}" ]; then
            closure_d10_incomplete "wheel ELF identity mismatch: $path"
        fi
        CLOSURE_D10_ORIGIN["$path"]="${origins[$path]:-wheel:unidentified}"
    done
    for path in "${!expected[@]}"; do
        if [ -z "${observed[$path]:-}" ]; then closure_d10_incomplete "wheel ELF missing: $path"; fi
    done
    closure_d10_consumers "$first" "$last" wheel
}

# -------------------------------------------------------------- the policy ---
# One candidate against the whole requirement set, with NO SPARE NODE REQUIRED
# and none permitted to be missing. It answers about the entry alone, so the
# generation that happens to ship has no weight here.
closure_d10_satisfies() {
    local gen="$1" key
    for key in ${CLOSURE_D10_REQUIRED[@]+"${CLOSURE_D10_REQUIRED[@]}"}; do
        if [ -z "${CLOSURE_D10_DEFINES[$gen|$key]:-}" ]; then return 1; fi
    done
    return 0
}

# THE LOWEST SATISFYING CANDIDATE, OR THE FAILURE. Three outcomes and no fourth:
# a generation, NEITHER when no capability entry defines every required node, and
# INCONCLUSIVE when the evidence could not answer on its own terms.
#
# The inconclusive tests come FIRST, and the order is the point rather than
# tidiness: a consumer set of zero satisfies every candidate vacuously, so a
# policy that asked the satisfaction question first would return the lowest
# generation from an empty observation. That is the exact failure shape the live
# trace already refuses one level down, and it is refused the same way here.
#
# 0 a candidate satisfies, 1 neither does, 5 the evidence could not answer. The
# codes are the checker's own, not a new vocabulary: 5 already means an input
# could not be obtained everywhere else in this effort.
closure_d10_policy() {
    local gen
    CLOSURE_D10_RESULT=""
    if [ "${#CLOSURE_D10_CANDIDATES[@]}" -eq 0 ]; then
        CLOSURE_D10_RESULT="$CLOSURE_D10_INCONCLUSIVE"
        printf 'D10 POLICY: %s\n' "$CLOSURE_D10_INCONCLUSIVE"
        printf '  the reading declares no candidate generation, so there is nothing to choose between\n'
        return 5
    fi
    if [ "$CLOSURE_D10_UNREAD" -ne 0 ]; then
        CLOSURE_D10_RESULT="$CLOSURE_D10_INCONCLUSIVE"
        printf 'D10 POLICY: %s\n' "$CLOSURE_D10_INCONCLUSIVE"
        printf '  %s input(s) could not be read, and an unmeasured generation is not an unsatisfying one: %s\n' \
            "$CLOSURE_D10_UNREAD" "$CLOSURE_D10_REASON"
        return 5
    fi
    if [ "${#CLOSURE_D10_CONSUMERS[@]}" -eq 0 ]; then
        CLOSURE_D10_RESULT="$CLOSURE_D10_INCONCLUSIVE"
        printf 'D10 POLICY: %s\n' "$CLOSURE_D10_INCONCLUSIVE"
        printf '  the reading found no consumer of %s, which is an empty observation and never a satisfied condition\n' \
            "$CLOSURE_D10_STDCXX"
        return 5
    fi
    for gen in "${CLOSURE_D10_CANDIDATES[@]}"; do
        if closure_d10_satisfies "$gen"; then
            CLOSURE_D10_RESULT="$gen"
            printf 'D10 POLICY: %s\n' "$gen"
            printf '  the lowest candidate defining every one of the %s required node(s), with zero spare nodes required\n' \
                "${#CLOSURE_D10_REQUIRED[@]}"
            if [ "$gen" != "$CLOSURE_D10_READING" ]; then
                printf '  RE-READ REQUIRED: the reading was taken under %s, so item 7 rebuilds with %s and evaluates again\n' \
                    "$CLOSURE_D10_READING" "$gen"
            fi
            return 0
        fi
    done
    CLOSURE_D10_RESULT="$CLOSURE_D10_NEITHER"
    printf 'D10 POLICY: %s\n' "$CLOSURE_D10_NEITHER"
    closure_d10_undefined
    printf '  packaging FAILS: the policy selects between generations and never takes the closer one\n'
    return 1
}

# Every required node no candidate entry defines, which is what makes a NEITHER
# actionable rather than only final.
closure_d10_undefined() {
    local key gen defined
    for key in ${CLOSURE_D10_REQUIRED[@]+"${CLOSURE_D10_REQUIRED[@]}"}; do
        defined=0
        for gen in ${CLOSURE_D10_CANDIDATES[@]+"${CLOSURE_D10_CANDIDATES[@]}"}; do
            if [ -n "${CLOSURE_D10_DEFINES[$gen|$key]:-}" ]; then defined=1; fi
        done
        if [ "$defined" -eq 0 ]; then
            printf '  no candidate generation defines %s\n' "$key"
        fi
    done
}

# --------------------------------------------------------- the re-read rule ---
# THE SECOND EVALUATION MUST RETURN EXACTLY THE SAME CANDIDATE, and every other
# result is non-convergent. The three ways to differ are named separately because
# they say three different things: a HIGHER second result means the requirement
# set grew with the generation, a LOWER one means the first reading overstated
# what the archive needs, and NEITHER means the rebuild moved the requirements
# out of range. All three say the evidence is unstable under the build it
# describes, which is a finding to report rather than a search to continue.
#
# THERE IS NO THIRD ITERATION, so this function never returns "read again".
closure_d10_position() {
    local want="$1" gen i=0
    for gen in ${CLOSURE_D10_CANDIDATES[@]+"${CLOSURE_D10_CANDIDATES[@]}"}; do
        if [ "$gen" = "$want" ]; then printf '%s' "$i"; return 0; fi
        i=$((i + 1))
    done
    return 1
}

closure_d10_converge() {
    local first="$1" second="$2" a b
    if [ "$first" = "$second" ] && closure_d10_position "$second" >/dev/null; then
        printf 'D10 CONVERGENCE: SETTLED at %s\n' "$second"
        return 0
    fi
    printf 'D10 CONVERGENCE: NON-CONVERGENT\n'
    if [ "$second" = "$CLOSURE_D10_NEITHER" ]; then
        printf '  the second evaluation satisfies NEITHER candidate, so the rebuild moved the requirements out of range\n'
    elif [ "$second" = "$CLOSURE_D10_INCONCLUSIVE" ] || [ "$first" = "$CLOSURE_D10_INCONCLUSIVE" ]; then
        printf '  an evaluation was inconclusive, so there is no pair of results to compare\n'
    elif a=$(closure_d10_position "$first") && b=$(closure_d10_position "$second"); then
        if [ "$b" -gt "$a" ]; then
            printf '  the second evaluation returned the HIGHER candidate %s where the first returned %s, so the requirement set grew with the generation\n' \
                "$second" "$first"
        else
            printf '  the second evaluation returned the LOWER candidate %s where the first returned %s, so the first reading overstated what the archive needs\n' \
                "$second" "$first"
        fi
    else
        printf '  a result names a generation this reading declares no candidate for: first %s, second %s\n' \
            "$first" "$second"
    fi
    printf '  packaging FAILS: there is no third iteration\n'
    return 1
}

# ----------------------------------------------------------------- the run ---
closure_d10_main() {
    local root="" previous="" rc=0 started=$SECONDS
    local candidates=()
    local -A roots=()
    CLOSURE_D10_WHEEL_ROOTS=()
    CLOSURE_D10_WHEEL_LOCK=""
    CLOSURE_D10_WHEEL_PYTHON=""

    while [ "$#" -gt 0 ]; do
        if [ "$#" -lt 2 ]; then printf '%s\n' "$CLOSURE_D10_USAGE" >&2; return 2; fi
        case "$1" in
            --root) root="${2:-}"; shift 2 ;;
            --candidate) candidates+=("${2:-}"); shift 2 ;;
            --previous) previous="${2:-}"; shift 2 ;;
            --wheel-root)
                if [ -z "${2:-}" ]; then return 2; fi
                if [ -z "${roots[$2]:-}" ]; then CLOSURE_D10_WHEEL_ROOTS+=("$2"); roots["$2"]=1; fi
                shift 2 ;;
            --wheel-lock) CLOSURE_D10_WHEEL_LOCK="$2"; shift 2 ;;
            --wheel-python) CLOSURE_D10_WHEEL_PYTHON="$2"; shift 2 ;;
            *) printf '%s\n' "$CLOSURE_D10_USAGE" >&2; return 2 ;;
        esac
    done
    if [ -z "$root" ] || [ "${#candidates[@]}" -eq 0 ]; then
        printf '%s\n' "$CLOSURE_D10_USAGE" >&2
        return 2
    fi
    # THE READER IS AN INPUT, AND ITS ABSENCE IS SAID RATHER THAN DISCOVERED. A
    # run without `closure_elf.sh` beside this file would otherwise reach an
    # undefined walk and report a reading over an empty tree, which is the empty
    # observation this policy refuses when it comes from anywhere else.
    if ! declare -F closure_subjects_walk >/dev/null 2>&1; then
        printf 'closure_d10: no closure_elf.sh beside %s, so no object could be read\n' \
            "$CLOSURE_D10_DIR" >&2
        return 5
    fi

    closure_d10_evidence "$root" "${candidates[@]}"
    closure_d10_policy
    rc=$?
    # THE CONVERGENCE RULE APPLIES TO THE SECOND RUN AND ONLY THERE. A first run
    # names what item 7 must do next; a run given the first result is the
    # re-evaluation, and its exit code becomes the convergence verdict, because a
    # second reading that satisfies is still a failure when it does not agree
    # with the first.
    #
    # AN INCONCLUSIVE RE-EVALUATION KEEPS ITS OWN CODE, and that exception is the
    # rule this whole effort applies everywhere else. Convergence still has
    # nothing to compare and the line below says so, but the reason is an input
    # that could not be obtained rather than a requirement set that moved, and
    # reporting it as 1 would file an unanswered question as a decided refusal.
    if [ -n "$previous" ]; then
        if [ "$rc" -eq 5 ]; then
            closure_d10_converge "$previous" "$CLOSURE_D10_RESULT" || true
        else
            closure_d10_converge "$previous" "$CLOSURE_D10_RESULT"
            rc=$?
        fi
    fi
    printf 'D10 elapsed=%ss\n' "$((SECONDS-started))"
    return "$rc"
}

# --- MAIN BOUNDARY ---
# Everything above is definitions; everything below runs a reading. Sourcing this
# file defines its functions and runs nothing, which is the seam the verification
# harness drives: it plants a model and calls the policy directly, so the nine
# interface cases are answered without a GCC toolchain of either generation being
# installed on the host that asks them.
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    return 0
fi

closure_d10_main "$@"
