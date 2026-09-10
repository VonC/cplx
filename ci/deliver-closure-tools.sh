#!/bin/bash
#
# deliver-closure-tools.sh -- the pipeline step that PLACES the authoritative
# closure tools in the Debian job's workspace, created by Step 6 of the v0.27.0
# toolchain-runtime-closure effort.
#
# IT IS THE BOOTSTRAP, WHICH IS WHY IT CANNOT BE DELIVERED BY WHAT IT DELIVERS.
# Every other script of this effort that produces evidence arrives in the
# workspace because this one put it there, so this file runs from the cplx
# checkout the pipeline already has, and it reads nothing from the candidate
# archive. Round 2 of the design review found the defect the first topology
# carried: staging the verifier inside the candidate and then running it against
# that candidate makes the archive certify itself, and it has no bootstrap
# either, because Step 6 must read the archive BEFORE installing it.
#
# A PARTIAL DELIVERY IS NOT A DELIVERY. A workspace holding four of eight
# authoritative copies is worse than an empty one: the job would find the file it
# looked for, run it, and produce evidence under a mixture of two commits. So a
# single failure removes everything this run wrote and refuses, and the job that
# follows refuses in turn rather than falling back to a copy it found inside the
# archive.
#
# THE SOURCE IS A PATH AT A COMMIT, never a branch and never a tag. A reference
# whose content can change under a fixed name would let two jobs claiming the
# same delivery run different bytes, which is the drift Design Area 3 removes on
# the configuration side and this file removes on the executable side.
#
# WHY THE INSTALLER IS IN THE SET. The checker derives the OBSERVED loader scope
# by calling the installer's own `build_elf_rpath` rather than reimplementing it,
# so on the agent the installer is an input to a reading and not merely the thing
# that unpacks. Taking it from the candidate would let the archive define the
# scope it is then measured against, which is the same self-certification the
# topology refuses everywhere else.

set -u

DELIVER_USAGE="Usage: deliver-closure-tools.sh --repo DIR --commit SHA --into DIR"

# The authoritative set, in one list. The five checker modules, the verification
# driver, the live observer, and the installer whose function the checker calls.
DELIVER_NAMES=(
    'closure_check.sh' 'closure_config.sh' 'closure_elf.sh' 'closure_report.sh'
    'closure_rules.sh' 'closure_verify.sh' 'closure_observe_live.sh'
    'install_pkg.sh'
)

DELIVER_SOURCE_DIR="src/setups/env/bin"
DELIVER_RE_COMMIT='^[0-9a-f]{40}$'

deliver_refuse() {
    printf 'deliver-closure-tools: %s\n' "$1" >&2
}

# Everything this run wrote, removed. Called on every refusal after the first
# byte lands, so the workspace is either complete or empty and never a mixture.
deliver_withdraw() {
    local into="$1" name=""
    for name in "${DELIVER_NAMES[@]}"; do
        rm -f -- "$into/$name"
    done
}

deliver_main() {
    local repo="" commit="" into="" name="" kind="" digest=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --repo) repo="${2:-}"; shift 2 || return 2 ;;
            --commit) commit="${2:-}"; shift 2 || return 2 ;;
            --into) into="${2:-}"; shift 2 || return 2 ;;
            *) deliver_refuse "$DELIVER_USAGE"; return 2 ;;
        esac
    done
    if [ -z "$repo" ] || [ -z "$commit" ] || [ -z "$into" ]; then
        deliver_refuse "$DELIVER_USAGE"
        return 2
    fi
    if [ ! -d "$repo/.git" ] && [ ! -f "$repo/.git" ]; then
        deliver_refuse "no cplx checkout at $repo, and the delivery has no other source"
        return 1
    fi
    if [[ ! $commit =~ $DELIVER_RE_COMMIT ]]; then
        deliver_refuse "the delivery names $commit, and only a 40-character commit SHA is immutable"
        return 1
    fi
    kind=$(git -C "$repo" cat-file -t "$commit" 2>/dev/null)
    if [ "$kind" != "commit" ]; then
        deliver_refuse "$commit names a ${kind:-missing object} in $repo rather than a commit"
        return 1
    fi
    if ! mkdir -p -- "$into"; then
        deliver_refuse "the workspace directory $into could not be created"
        return 1
    fi

    for name in "${DELIVER_NAMES[@]}"; do
        if ! git -C "$repo" cat-file blob "$commit:$DELIVER_SOURCE_DIR/$name" > "$into/$name" 2>/dev/null; then
            deliver_refuse "$commit holds no blob at $DELIVER_SOURCE_DIR/$name"
            deliver_withdraw "$into"
            return 1
        fi
        if ! chmod 0755 -- "$into/$name"; then
            deliver_refuse "the delivered $name could not be made executable"
            deliver_withdraw "$into"
            return 1
        fi
        digest=$(sha256sum -- "$into/$name" 2>/dev/null) || digest=""
        if [ -z "$digest" ]; then
            deliver_refuse "the delivered $name could not be digested"
            deliver_withdraw "$into"
            return 1
        fi
        printf 'DELIVERED|%s|%s\n' "$name" "${digest%% *}"
    done

    printf 'DELIVERY|%s|%s|%s\n' COMPLETE "$commit" "$into"
    return 0
}

# --- MAIN BOUNDARY ---
# Everything above is definitions; everything below delivers. Sourcing this file
# defines its functions and writes nothing, which is the seam the harness uses to
# drive one refusal at a time without a workspace to clean up after.
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    return 0
fi

deliver_main "$@"
