#!/bin/bash
#
# closure_rules.sh -- the invariants of the v0.27.0 runtime-closure checker.
# Created at Step 1 with this contract and nothing else. STEP 3 STARTS FILLING IT
# with the derived membership half and the unreferenced-by-edge half beside it,
# Step 4 adds the other three invariants and the aggregation, and Step 5 adds the
# waiver outcomes.
#
# THIS MODULE OWNS ALL FOUR INVARIANTS, THE DERIVED MEMBERSHIP HALF INCLUDED:
#
#   membership   in two halves that cannot substitute for each other. The
#                derived half lands HERE and not in `closure_check.sh`:
#                membership is an invariant, so it lives where the other three
#                do, and `closure_check.sh` gains the call and nothing else.
#   coherence    version needs resolved through the provider the object names.
#                It STILL EVALUATES when rule 1 refuses, against the first
#                candidate in scope order, because loader selection is
#                deterministic and refusing the ambiguity is not a reason to
#                throw away a real result.
#   rule 1       duplicate providers, in the loader's terms.
#   rule 2       declared family generations, in terms nothing in the file can
#                supply, which is why the family list is declared configuration.
#
# IT ALSO OWNS THE TWO OUTCOMES THAT ARE NOT PASS OR FAIL:
#
#   the waiver outcomes   a waiver is an exception with an expiry condition and
#                         never a mute. Its subjects are FLOOR MEMBERS ONLY: an
#                         UNEXPECTED directory or root is UNWAIVABLE, and no
#                         code path here may reach one.
#   UNDETERMINED          reserved for ONE thing, an input that could not be
#                         obtained. It is neither a pass nor a failure, it is
#                         reported with the input it lacked, and it never counts
#                         toward a green. Suppression follows data availability
#                         alone, never the presence of another refusal.
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

# ------------------------------------------------------ the derived membership ---
# THE DERIVED HALF of the membership invariant: every `DT_NEEDED` name recorded
# by every static subject must resolve to a file in the provider directories. It
# is one hash lookup per name against the index the reader built before the walk,
# which is the shape that keeps the run linear; resolving by scanning the
# provider directories inside this loop is the O(n^2) form the complexity bound
# refuses.
#
# THE DECLARED HALF IS NOT HERE AND IS NOT A SUBSTITUTE FOR THIS ONE. Only the
# floor can see a member dropped from the payload AND from its consumers in one
# edit, which is the shape the missing `libsqlite3.so.0` has; Step 4 adds it, and
# neither result stands in for the other.
#
# A miss names BOTH the subject and the name, because "something is missing" sent
# to whoever has to repair it is not an actionable result. Nothing is pruned: the
# rule refuses and says what it refused, and the repair is a payload or
# configuration change made deliberately.
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
# entry point AND by no DT_NEEDED edge". RUNTIME ENTRY POINTS are DECLARED data:
# the interpreter, the shipped executables and the declared dynamically loaded
# locations. NO STEP OF THIS PLAN SCHEDULES THAT DECLARATION, so this function
# answers the EDGE half only and says so in the name of the result it prints,
# `UNREFERENCED-BY-EDGE`. It is deliberately not named for the design's finding:
# a reader who takes this list for that finding would read a shipped executable,
# which is an entry point by definition, as an object nothing can load. The
# missing input is a plan-level obligation recorded in the validation record, not
# a caveat this function can settle.
CLOSURE_RULES_UNREFERENCED=0

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
    declare -A reached=()

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
            reached["$selected"]=1
            # And the file that path names, which is what the loader ends up
            # with. The resolution covers a symlinked directory component as
            # well as a symlinked final name, because the observed scope may
            # reach a provider through an alias directory while the walk
            # recorded it under the physical one.
            if closure_rules_physical "$selected"; then
                reached["$CLOSURE_RULES_PHYSICAL_RESULT"]=1
            else
                printf '%s|%s|%s|%s\n' UNDETERMINED resolution "$selected" \
                    'the link chain did not resolve within the cycle guard, so the file it names is unknown'
                CLOSURE_RULES_UNRESOLVED=$((CLOSURE_RULES_UNRESOLVED + 1))
            fi
        done
    done

    for path in ${CLOSURE_ELF_PATHS[@]+"${CLOSURE_ELF_PATHS[@]}"}; do
        if [ -n "${reached[$path]:-}" ]; then continue; fi
        printf '%s|%s|%s|%s\n' UNREFERENCED-BY-EDGE subject "$path" \
            'no DT_NEEDED edge in the archive resolves to this path'
        CLOSURE_RULES_UNREFERENCED=$((CLOSURE_RULES_UNREFERENCED + 1))
    done
}
