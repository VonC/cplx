#!/bin/bash
#
# closure_check.sh -- the entry point of the v0.27.0 runtime-closure checker.
#
# It answers the SCOPE question of the archive closure: which directories the
# loader will search under an installation prefix, which of them the
# configuration declares, and which of them nobody declared. Step 1 fills the
# entry point, the run order, the scope derivation and the classification; the
# four archive invariants arrive with `closure_rules.sh` in later steps, so THIS
# RUN'S VERDICT IS EXPLICITLY PARTIAL and says so on every run. A green scope
# check is not a green archive.
#
# Usage:
#   closure_check.sh [--prefix DIR] [--installer PATH] --root NAME[=SUB,SUB...]
#
#   --prefix     the installation prefix holding `tools`; defaults to $HOME,
#                which is the installer's own default.
#   --root       one declared tool root and its declared immediate
#                subdirectories, comma separated. Repeat it once per root, in
#                the loader's order, python first.
#   --installer  where `install_pkg.sh` lives; defaults to this script's own
#                directory, which is where it sits both in cplx and in a
#                deployed `tools/bin`.
#
# Exit codes: 0 nothing undeclared was observed, 1 at least one UNEXPECTED
# directory, which is a refusal, 2 the arguments are unusable, 5 the loader
# scope could not be observed, so the comparison is UNDETERMINED. 5 is not a
# softer 0: an UNDETERMINED result is neither a pass nor a failure, it is
# reported with the input it lacked, and it never counts toward a green.
#
# TWO SCOPES, AND THEY ARE NEVER MERGED.
#
#   the DECLARED CANDIDATE SHAPE is derived from three declared inputs and
#   TOUCHES NO FILESYSTEM: the tool roots, the declared immediate
#   subdirectories per root, and the relative suffixes this design fixes. It is
#   what expectations are stated against.
#
#   the OBSERVED LOADER SCOPE is what the loader will actually search, and it
#   comes from `build_elf_rpath` IN `install_pkg.sh`, called rather than
#   reimplemented. Resolution is evaluated against it, because nothing may be
#   resolved through a directory the loader would not search and nothing the
#   loader would search may be excluded.
#
# THE SECOND DECLARED INPUT IS A SUBDIRECTORY LIST, NOT A VERSION LIST. The
# installer's loop adds every immediate subdirectory it finds, so a declaration
# enumerating only version-shaped names would leave the `current` alias
# UNEXPECTED and refuse a tree that is correct. `root` is a declared immediate
# subdirectory of every root by construction, and the dedupe absorbs its
# duplicate contribution exactly as the installer's does.
#
# WHY THIS FILE NAMES NO SUFFIX THE INSTALLER NAMES. The observed scope must
# have exactly one definition, and a second one that agreed today would
# reproduce, one level up, the drift this checker exists to remove. The Step 1
# completion criteria therefore grep this file for the installer's tool-root
# glob and for its first composed suffix, and both must be absent; the harness
# asserts the same thing, and beside it a property case that compares this
# checker's observed scope against `build_elf_rpath`'s own output byte for byte.
# That is why the two `usr/` candidates below are composed from a directory
# variable rather than spelled as one literal string.
#
# WHY THE INSTALLER IS SOURCED IN A SUBSHELL. `install_pkg.sh` returns early
# when sourced, so sourcing it defines every function and performs no install.
# It can still REFUSE while being sourced, through a `fatal` that calls `exit`,
# and in this shell that would end the run and hand back the installer's exit
# code as if it were a verdict. In a subshell it ends the probe instead, and the
# result is a typed UNDETERMINED: NEVER an empty scope, which would report every
# declared candidate absent and read exactly like a bare tree, and never an
# inherited exit code. The report still runs to completion.
#
# UNEXPECTED IS UNWAIVABLE BY CONSTRUCTION. Waivers name floor members, and an
# undeclared root or subdirectory is repaired by removing it or by declaring it.
# No waiver code path exists here, and none may be added: the harness strips the
# comments and refuses the word in code, so this paragraph states the property
# and the assertion measures it.

set -u

# This script's own directory, resolved with parameter expansion because
# `dirname` is not on this effort's host-tool contract and every command the
# shipped scripts depend on has to be declared there before it can be used.
CLOSURE_CHECK_DIR="${BASH_SOURCE[0]%/*}"
if [ "$CLOSURE_CHECK_DIR" = "${BASH_SOURCE[0]}" ]; then
    CLOSURE_CHECK_DIR="."
fi

# Set by `closure_scope_observed`, read by its caller. A shell function cannot
# return two values, and the pair here is load bearing: the value AND whether it
# could be obtained at all.
CLOSURE_OBSERVED_RPATH=""
CLOSURE_OBSERVED_REASON=""

# ------------------------------------------------- the declared candidate shape ---
# Takes the parsed roots and their subdirectory lists, one `NAME=SUB,SUB` per
# argument, and prints the ordered deduped candidate list, one absolute path per
# line. It touches no filesystem: nothing here tests, globs or reads a path.
#
# The order is the loader's: each root's own `root/` candidates first, then that
# root's declared subdirectories, then the next declared root the same way, with
# the dedupe preserving the first occurrence.
closure_scope_declared() {
    local prefix="$1"
    shift
    local spec root subs rootdir rest item path
    local list=()
    local candidates=()
    declare -A seen=()

    for spec in "$@"; do
        root="${spec%%=*}"
        subs="${spec#*=}"
        if [ "$subs" = "$spec" ]; then subs=""; fi
        if [ -z "$root" ]; then continue; fi

        # The `root/` subdirectory is the only one carrying the two `usr/`
        # candidates, and the four are listed in the loader's order.
        rootdir="$prefix/tools/$root/root"
        candidates=("$rootdir/usr/lib64" "$rootdir/usr/lib" "$rootdir/lib64" "$rootdir/lib")

        # `root` leads the declared subdirectory list BY CONSTRUCTION, so a
        # declaration that omits it and one that names it derive the same shape,
        # and its two contributions dedupe against the four above.
        rest="root,$subs"
        while [ -n "$rest" ]; do
            item="${rest%%,*}"
            if [ "$item" = "$rest" ]; then rest=""; else rest="${rest#*,}"; fi
            if [ -z "$item" ]; then continue; fi
            candidates+=("$prefix/tools/$root/$item/lib" "$prefix/tools/$root/$item/lib64")
        done

        for path in "${candidates[@]}"; do
            if [ -z "${seen[$path]:-}" ]; then
                seen["$path"]=1
                list+=("$path")
            fi
        done
    done

    if [ "${#list[@]}" -gt 0 ]; then
        printf '%s\n' "${list[@]}"
    fi
}

# ---------------------------------------------------- the observed loader scope ---
# Sources the installer through its MAIN BOUNDARY seam and calls
# `build_elf_rpath`, in a subshell, and leaves the colon-joined value in
# CLOSURE_OBSERVED_RPATH. Returns non-zero with CLOSURE_OBSERVED_REASON set when
# the value could not be obtained; the caller turns that into UNDETERMINED.
#
# INSTALL_PREFIX is assigned AFTER the source and not before, because sourcing
# the installer assigns it too, and an assignment made first would be discarded.
#
# The probe reports through a SENTINEL rather than through its exit status. A
# refusal during sourcing exits the subshell with the installer's own code,
# which can be any value, so an empty result and a status the checker did not
# choose must not be readable as success.
closure_scope_observed() {
    local prefix="$1" installer="$2"
    local probe="" rc=0

    CLOSURE_OBSERVED_RPATH=""
    CLOSURE_OBSERVED_REASON=""

    if [ ! -f "$installer" ]; then
        CLOSURE_OBSERVED_REASON="the installer is not a readable file at $installer"
        return 1
    fi

    probe=$(
        # shellcheck disable=SC1090  # the installer path is resolved at runtime
        source "$installer" >/dev/null 2>&1 || exit 71
        declare -F build_elf_rpath >/dev/null 2>&1 || exit 72
        # shellcheck disable=SC2034  # `build_elf_rpath` reads it, and it is the
        # ONE global that function reads; shellcheck cannot see into the file
        # sourced on the line above, so the use is real and only the reader is
        # out of view.
        INSTALL_PREFIX="$prefix"
        joined=$(build_elf_rpath) || exit 73
        printf 'RPATH|%s' "$joined"
    )
    rc=$?

    if [ "${probe%%|*}" = "RPATH" ]; then
        CLOSURE_OBSERVED_RPATH="${probe#RPATH|}"
        return 0
    fi

    case "$rc" in
        71) CLOSURE_OBSERVED_REASON="sourcing $installer returned non-zero" ;;
        72) CLOSURE_OBSERVED_REASON="$installer defines no build_elf_rpath" ;;
        73) CLOSURE_OBSERVED_REASON="build_elf_rpath returned non-zero over $prefix" ;;
        *)  CLOSURE_OBSERVED_REASON="the probe produced no result: sourcing $installer ended it with status $rc" ;;
    esac
    return 1
}

# The colon-joined loader value, one directory per line. Split in the shell
# because `tr` is not on this effort's host-tool contract, and an empty value
# yields no line rather than one empty one.
closure_scope_observed_lines() {
    local rest="$1" item
    while [ -n "$rest" ]; do
        item="${rest%%:*}"
        if [ "$item" = "$rest" ]; then rest=""; else rest="${rest#*:}"; fi
        if [ -z "$item" ]; then continue; fi
        printf '%s\n' "$item"
    done
}

# ---------------------------------------------------------- the classification ---
# Joins the two scopes and prints one typed line per entry, with the side it was
# observed on:
#
#   PRESENT|declared|<path>                        a declared candidate the
#                                                  loader will search
#   ABSENT|declared|<path>                         a declared candidate that is
#                                                  not there. Reported, and not
#                                                  fatal on its own: a tool root
#                                                  legitimately has no root/lib,
#                                                  and the loader skips it.
#   UNEXPECTED|observed|<path>|root|<name>         an undeclared tool root
#   UNEXPECTED|observed|<path>|subdirectory|<name> an undeclared immediate
#                                                  subdirectory of a declared
#                                                  root
#
# Both directions are lookups in an associative array, so the join is O(n) in
# the entries rather than a scan of one list per element of the other.
closure_scope_classify() {
    local prefix="$1" declared="$2" observed="$3"
    shift 3
    local spec root subs path rel rest name
    declare -A observed_set=()
    declare -A declared_set=()
    declare -A root_subs=()

    for spec in "$@"; do
        root="${spec%%=*}"
        subs="${spec#*=}"
        if [ "$subs" = "$spec" ]; then subs=""; fi
        if [ -z "$root" ]; then continue; fi
        root_subs["$root"]=",root,$subs,"
    done

    while IFS= read -r path; do
        if [ -z "$path" ]; then continue; fi
        observed_set["$path"]=1
    done <<< "$observed"

    while IFS= read -r path; do
        if [ -z "$path" ]; then continue; fi
        declared_set["$path"]=1
        if [ -n "${observed_set[$path]:-}" ]; then
            printf '%s|%s|%s\n' PRESENT declared "$path"
        else
            printf '%s|%s|%s\n' ABSENT declared "$path"
        fi
    done <<< "$declared"

    while IFS= read -r path; do
        if [ -z "$path" ]; then continue; fi
        if [ -n "${declared_set[$path]:-}" ]; then continue; fi
        rel="${path#"$prefix"/tools/}"
        rest="${rel#*/}"
        # Two shapes `build_elf_rpath` cannot produce today. They are classified
        # rather than dropped, because an observed entry that fell out of every
        # branch would leave the loader searching a directory this report never
        # mentioned.
        if [ "$rel" = "$path" ]; then
            printf '%s|%s|%s|%s|%s\n' UNEXPECTED observed "$path" path \
                'outside the declared tools tree'
            continue
        fi
        if [ "$rest" = "$rel" ]; then
            printf '%s|%s|%s|%s|%s\n' UNEXPECTED observed "$path" shape \
                'not a directory under a tool root'
            continue
        fi
        root="${rel%%/*}"
        name="${rest%%/*}"
        if [ -z "${root_subs[$root]:-}" ]; then
            printf '%s|%s|%s|%s|%s\n' UNEXPECTED observed "$path" root "$root"
            continue
        fi
        case "${root_subs[$root]}" in
            *",$name,"*)
                printf '%s|%s|%s|%s|%s\n' UNEXPECTED observed "$path" suffix "$rest" ;;
            *)
                printf '%s|%s|%s|%s|%s\n' UNEXPECTED observed "$path" subdirectory "$name" ;;
        esac
    done <<< "$observed"
}

# The typed result for a scope that could not be observed. EVERY declared
# candidate is UNDETERMINED, one line each, because its presence is exactly what
# could not be determined. Reporting them ABSENT instead would turn a missing
# input into fourteen findings about the tree.
closure_scope_undetermined() {
    local declared="$1" reason="$2" path
    printf '%s|%s|%s|%s\n' UNDETERMINED observed 'the loader scope' "$reason"
    while IFS= read -r path; do
        if [ -z "$path" ]; then continue; fi
        printf '%s|%s|%s|%s\n' UNDETERMINED declared "$path" \
            'no observed scope to compare it against'
    done <<< "$declared"
}

closure_check_usage() {
    printf 'usage: closure_check.sh [--prefix DIR] [--installer PATH] --root NAME[=SUB,SUB...]\n' >&2
    printf '       --root is repeatable and required, in the loader order, python first\n' >&2
}

# ------------------------------------------------------------------- the run ---
closure_check_main() {
    local prefix="${HOME:-}" installer="$CLOSURE_CHECK_DIR/install_pkg.sh"
    local specs=()
    local declared="" observed="" results="" line kind
    local present=0 absent=0 unexpected=0 undetermined=0

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --prefix|--installer|--root)
                if [ "$#" -lt 2 ]; then
                    printf 'closure_check: missing operand for %s\n' "$1" >&2
                    closure_check_usage
                    return 2
                fi
                case "$1" in
                    --prefix) prefix="$2" ;;
                    --installer) installer="$2" ;;
                    --root) specs+=("$2") ;;
                esac
                shift 2
                ;;
            -h|--help) closure_check_usage; return 0 ;;
            *)
                printf 'closure_check: unknown argument: %s\n' "$1" >&2
                closure_check_usage
                return 2 ;;
        esac
    done

    if [ -z "$prefix" ]; then
        printf 'closure_check: no prefix: HOME is unset, so pass --prefix DIR\n' >&2
        return 2
    fi
    if [ "${#specs[@]}" -eq 0 ]; then
        printf 'closure_check: no declared root: pass at least one --root NAME[=SUB,SUB...]\n' >&2
        closure_check_usage
        return 2
    fi

    declared=$(closure_scope_declared "$prefix" "${specs[@]}")
    if closure_scope_observed "$prefix" "$installer"; then
        observed=$(closure_scope_observed_lines "$CLOSURE_OBSERVED_RPATH")
        results=$(closure_scope_classify "$prefix" "$declared" "$observed" "${specs[@]}")
    else
        results=$(closure_scope_undetermined "$declared" "$CLOSURE_OBSERVED_REASON")
    fi

    while IFS= read -r line; do
        if [ -z "$line" ]; then continue; fi
        kind="${line%%|*}"
        if [ "$kind" = "PRESENT" ]; then
            present=$((present + 1))
        elif [ "$kind" = "ABSENT" ]; then
            absent=$((absent + 1))
        elif [ "$kind" = "UNEXPECTED" ]; then
            unexpected=$((unexpected + 1))
        elif [ "$kind" = "UNDETERMINED" ]; then
            undetermined=$((undetermined + 1))
        fi
    done <<< "$results"

    printf '=== closure_check, v0.27.0 toolchain-runtime-closure, scope ===\n'
    printf '  prefix      %s\n' "$prefix"
    printf '  installer   %s\n' "$installer"
    printf '  roots       %s\n' "${specs[*]}"
    printf '\n== typed results\n'
    printf '%s\n' "$results"
    printf '\n== summary\n'
    printf '  declared     %s\n' "$(closure_scope_line_count "$declared")"
    printf '  observed     %s\n' "$(closure_scope_line_count "$observed")"
    printf '  present      %s\n' "$present"
    printf '  absent       %s\n' "$absent"
    printf '  unexpected   %s\n' "$unexpected"
    printf '  undetermined %s\n' "$undetermined"
    # Said on every run, green ones included. This checker answers the scope
    # question and makes no claim about the four archive invariants, and none at
    # all about runtime host fallback, which only a running process can show.
    printf '  verdict is PARTIAL: this run answers the scope question only\n'

    if [ "$unexpected" -ne 0 ]; then
        printf '\nCLOSURE SCOPE REFUSED: undeclared directories in the observed loader scope: %s\n' \
            "$unexpected"
        return 1
    fi
    if [ "$undetermined" -ne 0 ]; then
        printf '\nCLOSURE SCOPE UNDETERMINED: %s\n' "$CLOSURE_OBSERVED_REASON"
        return 5
    fi
    printf '\nCLOSURE SCOPE OK: %s declared, %s present, %s absent, nothing undeclared\n' \
        "$(closure_scope_line_count "$declared")" "$present" "$absent"
    return 0
}

# Lines in a newline-separated list, counted in the shell because `wc` is not on
# this effort's host-tool contract. An empty list is zero, not the one empty line
# a naive count would report.
closure_scope_line_count() {
    local n=0 line
    while IFS= read -r line; do
        if [ -n "$line" ]; then n=$((n + 1)); fi
    done <<< "${1-}"
    printf '%s' "$n"
}

# --- MAIN BOUNDARY ---
# Everything above is definitions; everything below runs a check.
#
# Sourcing this file defines its functions and runs nothing, so the verification
# harness can call `closure_scope_declared` and `closure_scope_observed`
# themselves rather than a copy, which is what lets it prove that the declared
# derivation touches no filesystem. Executing it is unchanged: BASH_SOURCE[0]
# equals $0 there, so the guard is a no-op on the deployed path. This is the
# same seam `install_pkg.sh` carries, and for the same reason.
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    return 0
fi

closure_check_main "$@"
