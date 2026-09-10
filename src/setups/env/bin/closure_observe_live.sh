#!/bin/bash
#
# closure_observe_live.sh -- the live observer of the v0.27.0 runtime-closure
# effort, created by Step 6. It runs on the FOREIGN HOST ALONE, because a process
# is the only thing that can demonstrate the absence of a host fallback, and no
# static read of any tree can answer that question.
#
# THIS FILE OWNS, AND IS THE ONLY PLACE THAT MAY OWN, the live half of the two
# readings Design Area 5 requires. The other half is a LISTING over the whole
# provider set, and the static checker owns that one. Neither is conclusive
# alone: a listing says what could be resolved, and a trace says what was.
#
# AN EMPTY INVENTORY IS NOT A PASS, AND THIS FILE EXISTS BECAUSE IT ONCE WAS. A
# trace that inventoried no process reported "no host library loaded" in
# develop#20, a sentence that is true of an empty observation and reads as a
# clean result. So the observer NAMES the process it inventoried, and a run that
# named none is INCONCLUSIVE with its own exit code rather than a quiet zero.
#
# IT SPAWNS NOTHING. Every fact it needs is a file under the process filesystem,
# read by the shell itself: the command name in `comm`, the argument vector in
# `cmdline`, and the mapped objects in `maps`. That is not an optimisation. Every
# command a shipped script depends on the host to supply has to be declared in
# contract.closure-tools.txt, and a tool the observer does not use is a tool the
# foreign host does not have to have.
#
# WHAT COUNTS AS A HOST OBJECT. Anything mapped from outside the installed tree,
# which is what the shipped objects were relocated to avoid: the loader was given
# an rpath into the tree and a shipped interpreter, so a resolved
# `/usr/lib/x86_64-linux-gnu/...` is the fallback this effort exists to detect.
# Kernel pseudo-mappings and anonymous regions carry no path and are not objects.
#
# THE PROCESS FILESYSTEM IS AN ARGUMENT, defaulting to /proc. A live reading on
# the agent takes the default; the harness plants a directory of the same shape,
# which is what lets the empty-inventory refusal be asserted without arranging a
# process that does not exist. The root is data either way, and reading it from a
# parameter is what stops the observer being untestable off the agent.
#
# It is EXECUTED by closure_verify.sh, never sourced, and it reports through
# typed lines and an exit code rather than through a verdict of its own.

set -u

CLOSURE_LIVE_USAGE="Usage: closure_observe_live.sh --process NAME --prefix DIR [--proc DIR]"

# The three outcomes, stated once. 0 is the only conclusive pass; 1 is a
# conclusive refusal, which is a host object in a live inventory; 4 is
# INCONCLUSIVE and is neither, which is the distinction develop#20 did not have.
CLOSURE_LIVE_OK=0
CLOSURE_LIVE_HOST=1
CLOSURE_LIVE_USAGE_RC=2
CLOSURE_LIVE_INCONCLUSIVE=4

closure_live_refuse() {
    printf 'closure_observe_live: %s\n' "$1" >&2
}

# One process name, matched against `comm` and against the basename of argv[0].
# `comm` is truncated to fifteen characters by the kernel, so a longer name would
# never match there and the second reading is what makes it findable at all.
closure_live_matches() {
    local dir="$1" want="$2" comm="" argv0=""

    if [ -r "$dir/comm" ]; then
        read -r comm < "$dir/comm" || comm=""
    fi
    if [ "$comm" = "$want" ]; then return 0; fi
    if [ -r "$dir/cmdline" ]; then
        IFS= read -r -d '' argv0 < "$dir/cmdline" || argv0="${argv0:-}"
    fi
    argv0="${argv0##*/}"
    if [ -n "$argv0" ] && [ "$argv0" = "$want" ]; then return 0; fi
    return 1
}

# The mapped objects of one process, one typed line each, deduplicated, followed
# by that process's host count. A mapping has no path when it is anonymous and a
# bracketed pseudo-name when the kernel supplies one; neither is an object this
# observation is about.
#
# The prefix test is a PREFIX test on the installed tree and not a substring
# search: a host path that merely contains the prefix as text elsewhere is a host
# path, and reading it as shipped would hide exactly the fallback being looked
# for.
#
# IT REPORTS WHETHER IT COLLECTED ANYTHING, and round 1 of the step 6 review is
# why. A readable but EMPTY `maps`, which is what an exited or zombie process
# leaves, produced a host count of zero and read as a clean inventory. A mapping
# table with no object in it is not an observation of a process that mapped
# nothing; it is a process that could not be observed, and the two must not share
# an exit code.
closure_live_objects() {
    local dir="$1" pid="$2" prefix="$3" path="" kind="" hosts=0 objects=0
    # The five leading fields of a maps record are named and never read. They are
    # there to REACH the sixth: a path may contain spaces, and only `read` with
    # one variable per leading field leaves the remainder whole. Splitting the
    # line by hand would truncate exactly the paths worth reporting.
    local range perms offset dev inode
    declare -A seen=()

    # shellcheck disable=SC2034  # read to consume the record shape, not for use
    while read -r range perms offset dev inode path; do
        if [ -z "${path:-}" ]; then continue; fi
        case "$path" in
            '['*) continue ;;
            /*) ;;
            *) continue ;;
        esac
        if [ -n "${seen[$path]:-}" ]; then continue; fi
        seen["$path"]=1
        kind=host
        case "$path" in
            "$prefix"/*) kind=shipped ;;
        esac
        if [ "$kind" = "host" ]; then hosts=$((hosts + 1)); fi
        objects=$((objects + 1))
        printf 'OBJECT|%s|%s|%s\n' "$pid" "$path" "$kind"
    done < "$dir/maps" || return 1
    if [ "$objects" -eq 0 ]; then return 1; fi
    printf 'HOSTS|%s|%s\n' "$pid" "$hosts"
    return 0
}

closure_live_main() {
    local want="" prefix="" proc="/proc"
    local pid="" entry="" comm="" inventoried=0 hosts=0 line="" collected=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --process) want="${2:-}"; shift 2 || return "$CLOSURE_LIVE_USAGE_RC" ;;
            --prefix) prefix="${2:-}"; shift 2 || return "$CLOSURE_LIVE_USAGE_RC" ;;
            --proc) proc="${2:-}"; shift 2 || return "$CLOSURE_LIVE_USAGE_RC" ;;
            *) closure_live_refuse "$CLOSURE_LIVE_USAGE"; return "$CLOSURE_LIVE_USAGE_RC" ;;
        esac
    done
    if [ -z "$want" ] || [ -z "$prefix" ] || [ -z "$proc" ]; then
        closure_live_refuse "$CLOSURE_LIVE_USAGE"
        return "$CLOSURE_LIVE_USAGE_RC"
    fi
    prefix="${prefix%/}"

    for entry in "$proc"/[0-9]*; do
        pid="${entry##*/}"
        if [ ! -r "$entry/maps" ]; then continue; fi
        if ! closure_live_matches "$entry" "$want"; then continue; fi
        comm=""
        if [ -r "$entry/comm" ]; then read -r comm < "$entry/comm" || comm=""; fi
        printf 'PROCESS|%s|%s\n' "$pid" "${comm:-unknown}"
        # THE COLLECTION IS CHECKED, AND THAT IS WHY IT IS A COMMAND SUBSTITUTION.
        # A process substitution's own completion is not observable from this
        # loop: a `maps` that disappeared under the read, or one holding no
        # record at all, ended the loop exactly as a full inventory does. Only a
        # collection that SUCCEEDED counts towards the inventory, so a matched
        # process nobody could read leaves the run inconclusive rather than
        # clean.
        if ! collected=$(closure_live_objects "$entry" "$pid" "$prefix"); then
            printf 'UNUSABLE|%s|%s\n' "$pid" \
                "its mapped objects could not be read, so no inventory was taken for it"
            continue
        fi
        inventoried=$((inventoried + 1))
        while IFS= read -r line; do
            printf '%s\n' "$line"
            case "$line" in
                'HOSTS|'*) hosts=$((hosts + "${line##*|}")) ;;
            esac
        done <<< "$collected"
    done

    # THE REFUSAL THAT IS THE POINT OF THIS FILE. Nothing was inventoried, so
    # there is no observation to read, and an observation nobody took must never
    # be reported as one that found nothing.
    if [ "$inventoried" -eq 0 ]; then
        printf 'LIVE|%s|%s\n' INCONCLUSIVE \
            "no usable inventory was collected for a process named $want, so nothing was observed"
        return "$CLOSURE_LIVE_INCONCLUSIVE"
    fi
    if [ "$hosts" -ne 0 ]; then
        printf 'LIVE|%s|%s\n' REFUSED \
            "$inventoried process(es) named $want map $hosts object(s) from outside $prefix"
        return "$CLOSURE_LIVE_HOST"
    fi
    printf 'LIVE|%s|%s\n' CONCLUSIVE \
        "$inventoried process(es) named $want map no object from outside $prefix"
    return "$CLOSURE_LIVE_OK"
}

# --- MAIN BOUNDARY ---
# Everything above is definitions; everything below observes. Sourcing this file
# defines its functions and observes nothing, which is the seam the harness uses
# to drive one reading at a time against a planted process-filesystem fixture.
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    return 0
fi

closure_live_main "$@"
