#!/bin/bash
#
# closure_rules.sh -- the invariants of the v0.27.0 runtime-closure checker.
# Created at Step 1 with this contract and nothing else. STEP 3 STARTED FILLING IT
# with the derived membership half and the unreferenced-by-edge half beside it,
# STEP 4 ADDS THE OTHER THREE INVARIANTS, the declared floor beside the derived
# half, the aggregation rule and the entry-point half of the unreferenced finding,
# and Step 5 adds the waiver outcomes.
#
# THIS MODULE OWNS ALL FOUR INVARIANTS, THE DERIVED MEMBERSHIP HALF INCLUDED:
# membership in its two halves, the derived one and the declared floor; coherence;
# rule 1 over duplicate providers; and rule 2 over declared family generations.
# Each states its own contract where its code is. They land HERE and not in
# `closure_check.sh` because an invariant lives where the other three do, and the
# checker gains the calls and nothing else.
#
# IT ALSO OWNS THE TWO OUTCOMES THAT ARE NOT PASS OR FAIL:
#
#   the waiver outcomes   a waiver is an exception with an expiry condition and
#                         never a mute. Its subjects are FLOOR MEMBERS ONLY: an
#                         UNEXPECTED directory or root is UNWAIVABLE, and no
#                         code path here may reach one.
#   UNDETERMINED          reserved for ONE thing, an input that could not be
#                         obtained, reported with the input it lacked and never
#                         counting toward a green. Suppression follows data
#                         availability alone, never another refusal.
#
# It is SOURCED by `closure_check.sh` and never executed.
#
# WHY IT READS THE READER'S MODEL RATHER THAN CALLING INTO IT. `closure_elf.sh`
# leaves the walk and the index in associative arrays keyed by path and by name,
# and the invariants read those arrays directly. The alternative, calling reader
# functions from here, would make this file name that module and take on its
# vocabulary, which is precisely the boundary the topology draws: the reader
# reads and this file decides. The arrays are declared THERE and are in scope
# here because `closure_check.sh` sources both at file scope, in that order.

# -------------------------------------------------- the one UNDETERMINED site ---
# THE ONE PLACE THIS MODULE PRODUCES AN UNDETERMINED, so the rule that it means an
# input could not be obtained has one implementation; a second producer would let
# whoever added it decide what the word covers. IT IS NOT A SOFTER REFUSAL: a
# refusal says the archive is wrong, this says the reading could not be taken, and
# the run is left non-passing by the COUNT rather than by a verdict about the
# archive.
CLOSURE_RULES_UNDETERMINED=0

closure_result_undetermined() {
    printf '%s|%s|%s|%s\n' UNDETERMINED "$1" "$2" "$3"
    CLOSURE_RULES_UNDETERMINED=$((CLOSURE_RULES_UNDETERMINED + 1))
}

# ------------------------------------------------------ the derived membership ---
# THE DERIVED HALF of the membership invariant: every `DT_NEEDED` name recorded
# by every static subject must resolve to a file in the provider directories. It
# is one hash lookup per name against the index the reader built before the walk,
# which is the shape that keeps the run linear; resolving by scanning the
# provider directories inside this loop is the O(n^2) form the complexity bound
# refuses.
#
# THE DECLARED HALF IS BESIDE IT, NOT A SUBSTITUTE FOR IT. Only the floor, which
# Step 4 adds below, sees a member dropped from the payload AND from its consumers
# in one edit, the shape the missing `libsqlite3.so.0` has, and neither result
# stands in for the other.
#
# A miss names BOTH the subject and the name, because "something is missing" sent
# to whoever has to repair it is not an actionable result. Nothing is pruned: the
# rule refuses and says what it refused, and the repair is a deliberate change.
CLOSURE_RULES_REFUSED=0

closure_membership_derived() {
    local path rest name

    CLOSURE_RULES_REFUSED=0
    for path in ${CLOSURE_ELF_PATHS[@]+"${CLOSURE_ELF_PATHS[@]}"}; do
        rest="${CLOSURE_ELF_NEEDED[$path]:-}"
        while [ -n "$rest" ]; do
            name="${rest%%$'\n'*}"
            if [ "$name" = "$rest" ]; then rest=""; else rest="${rest#*$'\n'}"; fi
            if [ -z "$name" ]; then continue; fi
            if [ -n "${CLOSURE_PROVIDER_PATHS[$name]:-}" ]; then continue; fi
            printf '%s|%s|%s|%s|%s\n' REFUSED derived "$path" "$name" \
                'no provider directory in the observed loader scope holds a file of that name'
            CLOSURE_RULES_REFUSED=$((CLOSURE_RULES_REFUSED + 1))
        done
    done
}

# ------------------------------------------------- the unreferenced-by-edge half ---
# A SEPARATE FINDING, AND NEVER AN EXCLUSION. An unreferenced shipped ELF is
# still a subject: it is examined like every other object, and its being
# unreferenced is reported beside the result rather than instead of it. "The
# archive ships something nothing can load" is worth saying, and it is not a
# reason to stop checking the thing.
#
# AN EDGE REACHES A PATH, NOT A NAME, and the difference is the whole reason this
# is computed from the provider index rather than from the names alone. A
# `DT_NEEDED` name resolves through the observed scope to ONE file, the first
# candidate in scope order, because that is what the loader takes. A second file
# of the same name outside the provider directories is reached by nothing: the
# design's own case is a second `libssl.so.3` under `root/usr/bin`, which
# `build_elf_rpath` never adds, and a name-keyed reachability map would have
# called it reached because a consumer names its sibling.
#
# AN ALIAS IS ONE FILE THROUGH TWO PATHS, so a selected provider that is a
# symlink onto a subject reaches that subject. THE TWO PATHS DO NOT SHARE A NAME:
# the ordinary library layout is `libz.so.1 -> libz.so.1.2.11`, a consumer names
# the soname, the index selects the symlink, and the walk yields the real target
# under its versioned name. Looking the alias up by the subject's own basename
# therefore finds nothing and reports a loaded library as unreferenced, which is
# a false finding on every versioned library in the archive.
#
# THE RESOLUTION IS A LOOKUP, and it is a lookup because the ONE WALK already
# recorded where every link points. Comparing file identities instead costs one
# comparison per link and subject pair, which is the product bound this effort's
# complexity clarification forbids and which grows with the archive: nothing in
# the schema or the code caps the number of aliased libraries, and one link per
# library is the ordinary layout rather than an exceptional one.
#
# A link may name another link, so the chase is bounded. THE BOUND IS A CYCLE
# GUARD AND NOT A POLICY: nothing in this plan says how deep a valid chain may
# be, and a chain of nine links resolves perfectly well on the supported host, so
# the limit is set where the kernel sets its own rather than at a number this
# effort invented. A chase that exceeds it is UNRESOLVED and is reported as such;
# it is not silently cached as though the last hop were the answer.
#
# WHAT THIS HALF IS, AND WHAT IT IS NOT. The design's finding is "reached by no
# entry point AND by no DT_NEEDED edge", and this function answers the EDGE term
# alone, which is why the result carries its own name, `UNREFERENCED-BY-EDGE`. A
# reader who took this list for the design's finding would read a shipped
# executable, which is an entry point by definition, as an object nothing can
# load. Step 4 supplies the other term and reports the conjunction below.
CLOSURE_RULES_UNREFERENCED=0

# The paths the edges reach, at MODULE SCOPE because the combined finding needs
# this same set and recomputing it would be a second sweep over the edges. There
# is no reset, for the reason the reader has none: one run is one process.
declare -A CLOSURE_RULES_REACHED=()

# The kernel's own SYMLOOP_MAX, so a chain a loader resolves this checker also
# resolves, and a cycle still terminates.
CLOSURE_RULES_LINK_HOPS=40
CLOSURE_RULES_PARTS=()
CLOSURE_RULES_UNRESOLVED=0

# The PHYSICAL path of a selected provider, which is the path the walk recorded
# for that file. Two things stand between the two, and only resolving both makes
# the reachability answer right:
#
#   a DIRECTORY component may be a link. `tools/python/current -> python-3.13.9`
#   is the alias layout this effort already reads, and the observed loader scope
#   holds `current/lib` while the walk, which does not follow a symlinked
#   directory, records the object under `python-3.13.9/lib`. A lookup of the
#   whole selected path cannot apply a link that sits in a PREFIX of it.
#   the FINAL component may be a link, the `libz.so.1 -> libz.so.1.2.11` soname
#   shape, which is the same resolution applied at the end of the walk.
#
# So the path is rebuilt one component at a time and each prefix is resolved
# while the link map names it, which handles both in one pass and in the right
# order: a directory link has to be applied before the name inside it means
# anything.
#
# The result is CACHED by input path. The distinct selected paths are bounded by
# the distinct DT_NEEDED names, and each is resolved once however many edges
# choose it, so this stays a lookup rather than the subject sweep it replaced.
declare -A CLOSURE_RULES_PHYSICAL=()
CLOSURE_RULES_PHYSICAL_RESULT=""

closure_rules_split() {
    local rest="$1" part
    CLOSURE_RULES_PARTS=()
    while [ -n "$rest" ]; do
        part="${rest%%/*}"
        if [ "$part" = "$rest" ]; then rest=""; else rest="${rest#*/}"; fi
        if [ -n "$part" ]; then CLOSURE_RULES_PARTS+=("$part"); fi
    done
}

closure_rules_physical() {
    local path="$1" out="" part target steps=0 head=0
    local pending=()

    CLOSURE_RULES_PHYSICAL_RESULT=""
    if [ -n "${CLOSURE_RULES_PHYSICAL[$path]:-}" ]; then
        CLOSURE_RULES_PHYSICAL_RESULT="${CLOSURE_RULES_PHYSICAL[$path]}"
        return 0
    fi
    closure_rules_split "$path"
    pending=(${CLOSURE_RULES_PARTS[@]+"${CLOSURE_RULES_PARTS[@]}"})

    # A HEAD INDEX rather than a shift, because rebuilding the queue for every
    # component would make walking a path quadratic in its own length.
    while [ "$head" -lt "${#pending[@]}" ]; do
        part="${pending[$head]}"
        head=$((head + 1))
        case "$part" in
            '.') continue ;;
            '..')
                # UP FROM WHERE THE RESOLUTION ACTUALLY IS, which is why the raw
                # target is kept: a component before this one may have been a
                # link that moved the directory `..` climbs out of.
                out="${out%/*}"
                continue ;;
        esac
        target="${CLOSURE_LINK_TARGET[$out/$part]:-}"
        if [ -z "$target" ]; then
            out="$out/$part"
            continue
        fi
        steps=$((steps + 1))
        if [ "$steps" -gt "$CLOSURE_RULES_LINK_HOPS" ]; then
            # UNRESOLVED, AND NOTHING IS CACHED. A partially chased path is not
            # the physical one, and storing it would answer later lookups with a
            # location the file is not at.
            return 1
        fi
        # The target's OWN components go back into the queue rather than being
        # taken whole, because any of them may be a link too. An absolute target
        # restarts the resolution from the root, which is what a link to an
        # absolute path means.
        closure_rules_split "$target"
        case "$target" in
            /*) out="" ;;
        esac
        pending=(${CLOSURE_RULES_PARTS[@]+"${CLOSURE_RULES_PARTS[@]}"} ${pending[@]+"${pending[@]:head}"})
        head=0
    done

    CLOSURE_RULES_PHYSICAL["$path"]="$out"
    CLOSURE_RULES_PHYSICAL_RESULT="$out"
    return 0
}

closure_report_unreferenced_by_edge() {
    local path rest name selected

    CLOSURE_RULES_UNREFERENCED=0
    CLOSURE_RULES_UNRESOLVED=0
    for path in ${CLOSURE_ELF_PATHS[@]+"${CLOSURE_ELF_PATHS[@]}"}; do
        rest="${CLOSURE_ELF_NEEDED[$path]:-}"
        while [ -n "$rest" ]; do
            name="${rest%%$'\n'*}"
            if [ "$name" = "$rest" ]; then rest=""; else rest="${rest#*$'\n'}"; fi
            if [ -z "$name" ]; then continue; fi
            selected="${CLOSURE_PROVIDER_PATHS[$name]:-}"
            if [ -z "$selected" ]; then continue; fi
            # Scope order is the loader's order, so the first candidate is the
            # one it takes and the only one this edge reaches.
            selected="${selected%%$'\n'*}"
            CLOSURE_RULES_REACHED["$selected"]=1
            # And the file that path names, which is what the loader ends up
            # with. The resolution covers a symlinked directory component as
            # well as a symlinked final name, because the observed scope may
            # reach a provider through an alias directory while the walk
            # recorded it under the physical one.
            if closure_rules_physical "$selected"; then
                CLOSURE_RULES_REACHED["$CLOSURE_RULES_PHYSICAL_RESULT"]=1
            else
                closure_result_undetermined resolution "$selected" \
                    'the link chain did not resolve within the cycle guard, so the file it names is unknown'
                CLOSURE_RULES_UNRESOLVED=$((CLOSURE_RULES_UNRESOLVED + 1))
            fi
        done
    done

    for path in ${CLOSURE_ELF_PATHS[@]+"${CLOSURE_ELF_PATHS[@]}"}; do
        if [ -n "${CLOSURE_RULES_REACHED[$path]:-}" ]; then continue; fi
        printf '%s|%s|%s|%s\n' UNREFERENCED-BY-EDGE subject "$path" \
            'no DT_NEEDED edge in the archive resolves to this path'
        CLOSURE_RULES_UNREFERENCED=$((CLOSURE_RULES_UNREFERENCED + 1))
    done
}

# ------------------------------------------------------- the declared floor half ---
# THE DECLARED HALF of membership, and the half only a declaration can supply. THE
# REQUIRED-LOCATION COLUMN IS THE TEST: `any` asks for presence anywhere in the
# observed scope, because resolution is what the floor protects, and `tools/<root>`
# asks for a candidate under that root, because a member whose only copy lives under
# another tool's root makes one payload depend on the other's. Step 5's waiver
# removal condition and umbrella item 6 read this same test. ONLY THIS HALF SEES A
# MEMBER DROPPED FROM THE PAYLOAD AND FROM ITS CONSUMERS IN ONE EDIT, and a run that
# read NO declaration has no floor and reports nothing, which the verdict states.
CLOSURE_RULES_FLOOR=0
CLOSURE_RULES_FLOOR_REFUSED=0

closure_floor_check() {
    local prefix="$1" name location path found

    CLOSURE_RULES_FLOOR=0
    CLOSURE_RULES_FLOOR_REFUSED=0
    for name in ${CLOSURE_CFG_FLOOR[@]+"${!CLOSURE_CFG_FLOOR[@]}"}; do
        CLOSURE_RULES_FLOOR=$((CLOSURE_RULES_FLOOR + 1))
        location="${CLOSURE_CFG_FLOOR[$name]}"
        found=0
        while IFS= read -r path; do
            if [ -z "$path" ]; then continue; fi
            if [ "$location" = "any" ]; then found=1; break; fi
            case "$path" in
                "$prefix/$location/"*) found=1; break ;;
            esac
        done <<< "${CLOSURE_PROVIDER_PATHS[$name]:-}"
        if [ "$found" -eq 1 ]; then continue; fi
        printf '%s|%s|%s|%s|%s\n' REFUSED floor "$name" "$location" \
            'no candidate of that name in the observed loader scope satisfies the required location'
        CLOSURE_RULES_FLOOR_REFUSED=$((CLOSURE_RULES_FLOOR_REFUSED + 1))
    done
}

# ------------------------------------------------------------ version coherence ---
# PROVIDER-AWARE, the correction the requirement makes to its own earlier libc-only
# wording: `GLIBCXX_` and `CXXABI_` nodes are defined by libstdc++ and `OPENSSL_`
# nodes by libcrypto, so the provider is the one the OBJECT names in its
# `DT_VERNEED` file entry. FOUR CONDITIONS, ALL STATIC, so this answers on the
# build account and on the agent alike: the provider name resolves in scope order,
# the first candidate is selected because the loader takes it, the resolution must
# stay INSIDE the archive, and the selected object must define the node. Only a
# RUNNING process shows a fallback to the host cache, and that is the live
# observer's subject.
#
# EVERY RECORDED NEED GETS A RESULT, which the walk's own classification of the
# selected file makes possible without one half judging on the other's evidence. A
# KNOWN NON-OBJECT defines no version node, a fact and so a refusal, while the
# derived half's acceptance of that name answers a different question about a FILE.
# A file whose reading could not be taken is an UNDETERMINED naming it. Silence for
# either would let an unanswered need leave the aggregate green, so the needs
# COUNTED and the needs ANSWERED are both reported.
CLOSURE_RULES_NEEDS=0
CLOSURE_RULES_ANSWERED=0
CLOSURE_RULES_COHERENCE_REFUSED=0

# A provider's defined nodes, indexed on first use and cached, so the membership
# test is one lookup rather than a scan of that provider's whole definition list per
# need. Indexing is one pass over the providers the run actually consults.
declare -A CLOSURE_RULES_DEFINED=()
declare -A CLOSURE_RULES_INDEXED=()

closure_rules_index_defs() {
    local path="$1" node
    if [ -n "${CLOSURE_RULES_INDEXED[$path]:-}" ]; then return 0; fi
    CLOSURE_RULES_INDEXED["$path"]=1
    # Read once: slicing the remaining list per node copies a quadratic total.
    while IFS= read -r node; do
        if [ -z "$node" ]; then continue; fi
        CLOSURE_RULES_DEFINED["$path|$node"]=1
    done <<< "${CLOSURE_ELF_VERDEF[$path]:-}"
}

closure_coherence_refuse() {
    printf '%s|%s|%s|%s|%s|%s\n' REFUSED coherence "$1" "$2" "$3" "$4"
    CLOSURE_RULES_ANSWERED=$((CLOSURE_RULES_ANSWERED + 1))
    CLOSURE_RULES_COHERENCE_REFUSED=$((CLOSURE_RULES_COHERENCE_REFUSED + 1))
}

closure_coherence_check() {
    local root="$1" path entry provider node selected physical

    CLOSURE_RULES_NEEDS=0
    CLOSURE_RULES_ANSWERED=0
    CLOSURE_RULES_COHERENCE_REFUSED=0
    for path in ${CLOSURE_ELF_PATHS[@]+"${CLOSURE_ELF_PATHS[@]}"}; do
        while IFS= read -r entry; do
            if [ -z "$entry" ]; then continue; fi
            provider="${entry%%|*}"
            node="${entry#*|}"
            CLOSURE_RULES_NEEDS=$((CLOSURE_RULES_NEEDS + 1))
            selected="${CLOSURE_PROVIDER_PATHS[$provider]:-}"
            if [ -z "$selected" ]; then
                # The aggregation rule's first row: the NAME is the derived
                # half's refusal, and the needs recorded against it are
                # UNDETERMINED, because there is no provider file to read.
                closure_result_undetermined coherence "$path" \
                    "the version need $node names $provider, which resolves nowhere in the observed loader scope"
                continue
            fi
            selected="${selected%%$'\n'*}"
            if ! closure_rules_physical "$selected"; then
                closure_result_undetermined coherence "$path" \
                    "the version need $node names $provider at $selected, whose link chain did not resolve within the cycle guard"
                continue
            fi
            physical="$CLOSURE_RULES_PHYSICAL_RESULT"
            case "$physical" in
                "$root"/*) ;;
                *)
                    closure_coherence_refuse "$path" "$node" "$provider" \
                        "the selected provider $selected leaves the archive and resolves to $physical"
                    continue ;;
            esac
            case "${CLOSURE_ELF_KIND[$physical]:-}" in
                'object') ;;
                'not-elf')
                    closure_coherence_refuse "$path" "$node" "$provider" \
                        "the selected provider $selected is not an ELF object, so it defines no version node"
                    continue ;;
                *)
                    closure_result_undetermined coherence "$path" \
                        "the version need $node names $provider at $selected, whose reading could not be taken"
                    continue ;;
            esac
            closure_rules_index_defs "$physical"
            if [ -n "${CLOSURE_RULES_DEFINED[$physical|$node]:-}" ]; then
                CLOSURE_RULES_ANSWERED=$((CLOSURE_RULES_ANSWERED + 1))
                continue
            fi
            closure_coherence_refuse "$path" "$node" "$provider" \
                "the selected provider $selected defines no such version node"
        done <<< "${CLOSURE_ELF_VERNEED[$path]:-}"
    done
}

# ---------------------------------------------------------- rule 1, duplicates ---
# DUPLICATE PROVIDERS IN THE LOADER'S TERMS, which is what makes this rule right
# where a SONAME grouping was wrong. For a `DT_NEEDED` entry the loader searches
# each scope directory in order for a file of that EXACT NAME, so a differently
# named object carrying the same internal soname is not a candidate for any lookup:
# the measured archive has 95 repeated sonames and only 20 lookup names with more
# than one candidate.
#
# ONE FILE FROM SEVERAL DIRECTORIES IS ONE PROVIDER. Candidates are resolved
# through their links first and compared by CONTENT DIGEST only where the resolved
# targets actually differ, which is why the measured archive PASSES on all twenty
# of its multi-candidate names: the positive control a rule that over-refused would
# fail and nothing else would. DIFFERENT CONTENT IS A REFUSAL, because scope order
# alone would decide which the loader takes, and it names both paths and both
# digests because "there is a duplicate" is not actionable. THE COST IS BOUNDED BY
# THE NAMES, NOT BY THE OBJECTS: each lookup name is examined once and a digest is
# taken once per distinct file and cached.
CLOSURE_RULES_LOOKUPS=0
CLOSURE_RULES_MULTI=0
CLOSURE_RULES_RULE1_REFUSED=0
declare -A CLOSURE_RULES_DIGEST=()
CLOSURE_RULES_DIGEST_RESULT=""

# The digest of one file, cached by path. It travels through a global because a
# command substitution would run this in a subshell and lose the cache with it.
closure_rules_digest() {
    local out=""
    CLOSURE_RULES_DIGEST_RESULT="${CLOSURE_RULES_DIGEST[$1]:-}"
    if [ -n "$CLOSURE_RULES_DIGEST_RESULT" ]; then return 0; fi
    out=$(sha256sum -- "$1" 2>/dev/null) || return 1
    out="${out%% *}"
    if [ -z "$out" ]; then return 1; fi
    CLOSURE_RULES_DIGEST["$1"]="$out"
    CLOSURE_RULES_DIGEST_RESULT="$out"
    return 0
}

# One lookup name, its candidates collected in scope order and reduced to DISTINCT
# RESOLVED TARGETS before any digest is taken.
closure_rule1_name() {
    local name="$1" path physical count=0
    local entry first="" first_digest=""
    local order=()
    declare -A seen=()
    while IFS= read -r path; do
        if [ -z "$path" ]; then continue; fi
        count=$((count + 1))
        if ! closure_rules_physical "$path"; then
            closure_result_undetermined duplicates "$name" \
                "the candidate $path did not resolve within the cycle guard, so its content could not be compared"
            return 0
        fi
        physical="$CLOSURE_RULES_PHYSICAL_RESULT"
        # A SET AND AN ORDER, not a string scanned per candidate: one lookup, and
        # the report keeps scope order.
        if [ -n "${seen[$physical]:-}" ]; then continue; fi
        seen["$physical"]=1
        order+=("$physical|$path")
    done <<< "${CLOSURE_PROVIDER_PATHS[$name]:-}"
    if [ "$count" -lt 2 ]; then return 0; fi
    CLOSURE_RULES_MULTI=$((CLOSURE_RULES_MULTI + 1))
    # ONE FILE THROUGH SEVERAL PATHS IS ONE PROVIDER, so a name whose candidates
    # reduce to one target needs no digest and cannot be turned UNDETERMINED by one.
    if [ "${#order[@]}" -lt 2 ]; then return 0; fi
    for entry in "${order[@]}"; do
        physical="${entry%%|*}"
        path="${entry#*|}"
        if ! closure_rules_digest "$physical"; then
            closure_result_undetermined duplicates "$name" \
                "the candidate $path resolves to $physical, whose content digest could not be taken here"
            return 0
        fi
        if [ -z "$first" ]; then
            first="$path"
            first_digest="$CLOSURE_RULES_DIGEST_RESULT"
            continue
        fi
        if [ "$CLOSURE_RULES_DIGEST_RESULT" = "$first_digest" ]; then continue; fi
        printf '%s|%s|%s|%s|%s|%s|%s|%s\n' REFUSED duplicates "$name" \
            "$first" "$first_digest" "$path" "$CLOSURE_RULES_DIGEST_RESULT" \
            'two candidate paths for one lookup name hold different content'
        CLOSURE_RULES_RULE1_REFUSED=$((CLOSURE_RULES_RULE1_REFUSED + 1))
        return 0
    done
    return 0
}

closure_rule1_duplicates() {
    local path name
    declare -A seen=()

    CLOSURE_RULES_LOOKUPS=0
    CLOSURE_RULES_MULTI=0
    CLOSURE_RULES_RULE1_REFUSED=0
    for path in ${CLOSURE_ELF_PATHS[@]+"${CLOSURE_ELF_PATHS[@]}"}; do
        while IFS= read -r name; do
            if [ -z "$name" ]; then continue; fi
            if [ -n "${seen[$name]:-}" ]; then continue; fi
            seen["$name"]=1
            CLOSURE_RULES_LOOKUPS=$((CLOSURE_RULES_LOOKUPS + 1))
            closure_rule1_name "$name"
        done <<< "${CLOSURE_ELF_NEEDED[$path]:-}"
    done
}

# ------------------------------------------------------------ rule 2, families ---
# DECLARED FAMILY GENERATIONS, in terms nothing in the file can supply. Two objects
# with different SONAMEs may be two generations of one family and no ELF field says
# so, which is why the family list is declared configuration and why this is a
# SECOND rule rather than an exception inside rule 1: the measured `libbfd` pair
# carries two different FILENAMES, so no lookup name ever has both as candidates
# and rule 1 is silent on them by construction. AN UNDECLARED FAMILY IS NOT
# EXAMINED, a deliberate blind spot taken over a filename heuristic the
# measurements show would be wrong in both directions.
#
# THE COST IS THE DECLARED FAMILIES TIMES THE SUBJECTS, and the first factor is
# configuration a human writes. A glob cannot be hashed, so no index can replace
# the match, and the loops exchanged give the same product.
CLOSURE_RULES_FAMILIES=0
CLOSURE_RULES_RULE2_REFUSED=0

closure_rule2_families() {
    local key family glob path soname permitted gen count entry
    local order=()
    declare -A seen=()
    declare -A gens=()

    CLOSURE_RULES_FAMILIES=0
    CLOSURE_RULES_RULE2_REFUSED=0
    for key in ${CLOSURE_CFG_FAMILY[@]+"${!CLOSURE_CFG_FAMILY[@]}"}; do
        family="${key%% *}"
        glob="${key#* }"
        for path in ${CLOSURE_ELF_PATHS[@]+"${CLOSURE_ELF_PATHS[@]}"}; do
            soname="${CLOSURE_ELF_SONAME[$path]:-}"
            if [ -z "$soname" ]; then continue; fi
            # shellcheck disable=SC2254  # the declared glob IS the pattern here
            case "$soname" in
                $glob) ;;
                *) continue ;;
            esac
            # ONE SET FOR THE WHOLE PASS, keyed by family and soname, so a
            # generation is recognized in one lookup rather than by a scan.
            if [ -n "${seen[$family|$soname]:-}" ]; then continue; fi
            seen["$family|$soname"]=1
            order+=("$family|$soname")
            gens["$family"]=$(( ${gens[$family]:-0} + 1 ))
        done
    done

    for family in ${CLOSURE_CFG_FAMILY_GEN[@]+"${!CLOSURE_CFG_FAMILY_GEN[@]}"}; do
        CLOSURE_RULES_FAMILIES=$((CLOSURE_RULES_FAMILIES + 1))
        permitted="${CLOSURE_CFG_FAMILY_GEN[$family]}"
        count="${gens[$family]:-0}"
        if [ "$count" -le "$permitted" ]; then continue; fi
        # Named only where a family refuses, walking the ordered record once.
        gen=""
        for entry in ${order[@]+"${order[@]}"}; do
            if [ "${entry%%|*}" != "$family" ]; then continue; fi
            gen="${gen:+$gen,}${entry#*|}"
        done
        printf '%s|%s|%s|%s|%s|%s\n' REFUSED families "$family" "$permitted" "$count" "$gen"
        CLOSURE_RULES_RULE2_REFUSED=$((CLOSURE_RULES_RULE2_REFUSED + 1))
    done
}

# --------------------------------------- the entry-point half, and the finding ---
# THE OTHER HALF OF THE UNREFERENCED FINDING, and the result that combines them.
# Design Q13 splits the finding because its two terms have different inputs: the
# EDGE half comes from the edges the walk collected, the ENTRY-POINT half from the
# DECLARED ENTRY-POINT SET, which is configuration. A DECLARATION READ IS THE
# PRECONDITION, and an empty set is not a substitute: the conjunction taken from a
# set nobody declared would name a shipped executable, which is an entry point by
# definition, as an object nothing can load. A run given no bundle reports the edge
# half under its own name and stops there, which is what Step 3 does.
#
# THE DECLARATION IS IN THE ARCHIVE'S TERMS AND THE WALK RECORDS PHYSICAL PATHS, so
# a location is resolved through the link map before the two are compared:
# `tools/python/current/bin` is the shipped layout and `current` is a link. The cost
# is the declared locations times the subjects, the first a short declared list.
CLOSURE_RULES_ENTRYPOINTS=0
CLOSURE_RULES_ENTRYSUBJECTS=0
CLOSURE_RULES_UNREACHABLE=0
CLOSURE_RULES_ENTRY_DIRS=""

closure_rules_is_entry() {
    local path="$1" dir
    while IFS= read -r dir; do
        if [ -z "$dir" ]; then continue; fi
        if [ "$path" = "$dir" ]; then return 0; fi
        case "$path" in
            "$dir"/*) return 0 ;;
        esac
    done <<< "$CLOSURE_RULES_ENTRY_DIRS"
    return 1
}

closure_report_unreferenced() {
    local declared="$1" prefix="$2" location path

    CLOSURE_RULES_ENTRYPOINTS=0
    CLOSURE_RULES_ENTRYSUBJECTS=0
    CLOSURE_RULES_UNREACHABLE=0
    CLOSURE_RULES_ENTRY_DIRS=""
    if [ "$declared" != "yes" ]; then return 0; fi

    for location in ${CLOSURE_CFG_ENTRY[@]+"${!CLOSURE_CFG_ENTRY[@]}"}; do
        CLOSURE_RULES_ENTRYPOINTS=$((CLOSURE_RULES_ENTRYPOINTS + 1))
        if ! closure_rules_physical "$prefix/$location"; then
            closure_result_undetermined entry-point "$location" \
                'the declared entry-point location did not resolve within the cycle guard'
            continue
        fi
        CLOSURE_RULES_ENTRY_DIRS="$CLOSURE_RULES_ENTRY_DIRS$CLOSURE_RULES_PHYSICAL_RESULT"$'\n'
    done

    for path in ${CLOSURE_ELF_PATHS[@]+"${CLOSURE_ELF_PATHS[@]}"}; do
        if closure_rules_is_entry "$path"; then
            CLOSURE_RULES_ENTRYSUBJECTS=$((CLOSURE_RULES_ENTRYSUBJECTS + 1))
            continue
        fi
        if [ -n "${CLOSURE_RULES_REACHED[$path]:-}" ]; then continue; fi
        printf '%s|%s|%s|%s\n' UNREFERENCED subject "$path" \
            'no declared entry point is this object and no DT_NEEDED edge resolves to it'
        CLOSURE_RULES_UNREACHABLE=$((CLOSURE_RULES_UNREACHABLE + 1))
    done
}
