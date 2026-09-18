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
#
# THE ACCEPTANCE BUNDLE, added by Step 6 of the tools-archive-rebuild effort.
# The candidate qualification chain on the agent and the RHEL acceptance driver
# both consume the SAME independently delivered controls: every tracked file
# under `src/` at the commit, plus the SQLite, installer, relocation and wrapper
# harnesses and the platform acceptance driver under `acceptance/`. The bundle
# carries `acceptance/source-revision.txt` naming the commit and
# `acceptance/verification.sha256` covering every other regular member, which is
# the manifest the consuming project's bundle adapter checks before extraction.
# THE MANIFEST IS CHECKED ON BOTH SIDES: after writing the archive this script
# reads it back as a stranger would, extracts it into a private directory and
# verifies every member against the manifest it carries, so the digest it prints
# names bytes that have already passed the consumer's own check once. The
# controls stay OUTSIDE the candidate archive; nothing here reads the archive.

set -u

DELIVER_USAGE="Usage: deliver-closure-tools.sh --repo DIR --commit SHA (--into DIR | --bundle FILE)"

# The authoritative set, in one list. The five checker modules, the verification
# driver, the live observer, and the installer whose function the checker calls.
DELIVER_NAMES=(
    'closure_check.sh' 'closure_config.sh' 'closure_elf.sh' 'closure_report.sh'
    'closure_rules.sh' 'closure_verify.sh' 'closure_observe_live.sh'
    'install_pkg.sh'
)

DELIVER_SOURCE_DIR="src/setups/env/bin"
DELIVER_RE_COMMIT='^[0-9a-f]{40}$'

# The acceptance controls composed under `acceptance/` in the bundle: the item 6
# SQLite acceptance driver and its helpers, the installer, relocation and wrapper
# harnesses, the archive oracle the relocation acceptance reads, and the item 7
# platform acceptance driver itself. Every name is a path below docs/v0.27.0 at
# the delivered commit; a name absent from the commit refuses the whole bundle.
DELIVER_ACCEPTANCE_DIR="docs/v0.27.0"
DELIVER_ACCEPTANCE=(
    'acceptance.python-sqlite-capture.sh' 'acceptance.python-sqlite-deploy.sh'
    'acceptance.python-sqlite-namespace.sh' 'acceptance.python-sqlite-report.sh'
    'acceptance.python-sqlite-support.sh' 'acceptance.tools-archive-rebuild.sh'
    'verify.install-pkg.sh' 'verify.relocation-rpath.sh'
    'verify.wrapper-scope.sh' 'verify.wrapper-accept.sh'
    'inventory.tools-archive-rebuild.txt'
)
DELIVER_BUNDLE_MANIFEST="acceptance/verification.sha256"
DELIVER_BUNDLE_REVISION="acceptance/source-revision.txt"

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

# The shared preflight: a checkout, an immutable commit reference, and a commit
# object behind it. Sets DELIVER_KIND for the refusal message.
deliver_check_source() {
    local repo="$1" commit="$2" kind=""
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
    return 0
}

deliver_into() {
    local repo="$1" commit="$2" into="$3" name="" digest=""
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

# The consumer's reading of a bundle, performed here on the bytes just written.
# Only regular files and directories below `src/` or `acceptance/`, a revision
# file naming the commit, and a manifest that covers every other regular member
# exactly: one missing, extra or altered member refuses.
deliver_bundle_check() {
    local bundle="$1" commit="$2" check="$3" entry="" kind="" listed=0 present=0
    if ! tar -tzvf "$bundle" > "$check/members" 2>/dev/null; then
        deliver_refuse "the bundle $bundle could not be listed"
        return 1
    fi
    while IFS= read -r entry; do
        kind="${entry:0:1}"
        entry="${entry##* }"
        entry="${entry%/}"
        case "$kind" in
            -|d) ;;
            *) deliver_refuse "the bundle carries a non-regular member: $entry"; return 1 ;;
        esac
        case "$entry" in
            src|acceptance|src/*|acceptance/*) ;;
            *) deliver_refuse "the bundle carries a member outside src/ and acceptance/: $entry"; return 1 ;;
        esac
        case "/$entry/" in
            */../*|*/./*|*//*) deliver_refuse "the bundle carries an unsafe member path: $entry"; return 1 ;;
        esac
    done < "$check/members"
    if ! mkdir -- "$check/tree" || ! tar -xzf "$bundle" -C "$check/tree" 2>/dev/null; then
        deliver_refuse "the bundle $bundle could not be extracted for its own check"
        return 1
    fi
    if [ ! -f "$check/tree/$DELIVER_BUNDLE_MANIFEST" ] || [ ! -f "$check/tree/$DELIVER_BUNDLE_REVISION" ]; then
        deliver_refuse "the bundle carries no manifest and revision under acceptance/"
        return 1
    fi
    if [ "$(cat "$check/tree/$DELIVER_BUNDLE_REVISION")" != "$commit" ]; then
        deliver_refuse "the bundle names another source revision than $commit"
        return 1
    fi
    if ! (cd "$check/tree" && sha256sum --strict --check "$DELIVER_BUNDLE_MANIFEST" > /dev/null 2>&1); then
        deliver_refuse "the bundle manifest does not cover its exact bytes"
        return 1
    fi
    listed=$(grep -c . "$check/tree/$DELIVER_BUNDLE_MANIFEST")
    present=$(find "$check/tree/src" "$check/tree/acceptance" -type f ! -path "$check/tree/$DELIVER_BUNDLE_MANIFEST" | grep -c .)
    if [ "$listed" -ne "$present" ]; then
        deliver_refuse "the bundle manifest lists $listed members for $present regular files"
        return 1
    fi
    printf 'BUNDLE-CHECK|%s|%s\n' "$commit" "$present"
    return 0
}

deliver_bundle() {
    local repo="$1" commit="$2" bundle="$3" name="" stage="" digest="" stamp=""
    local paths=()
    case "$bundle" in
        *.tar.gz) ;;
        *) deliver_refuse "the bundle path must end in .tar.gz: $bundle"; return 1 ;;
    esac
    if [ -e "$bundle" ]; then
        deliver_refuse "the bundle destination already exists: $bundle"
        return 1
    fi
    stage=$(mktemp -d "${TMPDIR:-/tmp}/deliver-bundle.XXXXXXXX") || {
        deliver_refuse "no private staging directory could be created"; return 1; }
    for name in "${DELIVER_ACCEPTANCE[@]}"; do
        if ! git -C "$repo" cat-file -e "$commit:$DELIVER_ACCEPTANCE_DIR/$name" 2>/dev/null; then
            deliver_refuse "$commit holds no blob at $DELIVER_ACCEPTANCE_DIR/$name"
            rm -rf -- "$stage"
            return 1
        fi
        paths+=("$DELIVER_ACCEPTANCE_DIR/$name")
    done
    for name in "${DELIVER_NAMES[@]}"; do
        if ! git -C "$repo" cat-file -e "$commit:$DELIVER_SOURCE_DIR/$name" 2>/dev/null; then
            deliver_refuse "$commit holds no blob at $DELIVER_SOURCE_DIR/$name"
            rm -rf -- "$stage"
            return 1
        fi
    done
    mkdir -- "$stage/tree" "$stage/check"
    # git archive writes the commit's exact blobs and modes; nothing is read
    # from the working tree, so an edited checkout cannot leak into the bundle.
    if ! git -C "$repo" archive --format=tar "$commit" src "${paths[@]}" | tar -xf - -C "$stage/tree"; then
        deliver_refuse "$commit could not be archived from $repo"
        rm -rf -- "$stage"
        return 1
    fi
    mkdir -- "$stage/tree/acceptance"
    for name in "${DELIVER_ACCEPTANCE[@]}"; do
        mv -- "$stage/tree/$DELIVER_ACCEPTANCE_DIR/$name" "$stage/tree/acceptance/$name"
    done
    rm -rf -- "$stage/tree/docs"
    if find "$stage/tree" -mindepth 1 ! -type f ! -type d -print -quit | grep -q .; then
        deliver_refuse "$commit carries a link or special file below src/, which the bundle cannot carry"
        rm -rf -- "$stage"
        return 1
    fi
    printf '%s\n' "$commit" > "$stage/tree/$DELIVER_BUNDLE_REVISION"
    # The manifest covers every regular member but itself, in one fixed order,
    # in the two-space form the consuming adapter parses.
    if ! (cd "$stage/tree" && find src acceptance -type f -print0 | LC_ALL=C sort -z \
            | xargs -0 sha256sum -- > "$stage/manifest"); then
        deliver_refuse "the bundle members could not be digested"
        rm -rf -- "$stage"
        return 1
    fi
    mv -- "$stage/manifest" "$stage/tree/$DELIVER_BUNDLE_MANIFEST"
    # Deterministic bytes: fixed owner, the commit's own timestamp, sorted
    # members and an unstamped gzip, so the same commit composes the same digest.
    stamp=$(git -C "$repo" log -1 --format=%ct "$commit")
    if ! tar -C "$stage/tree" --owner=0 --group=0 --numeric-owner --mtime="@$stamp" \
            --sort=name -cf - src acceptance | gzip -n > "$bundle"; then
        deliver_refuse "the bundle $bundle could not be written"
        rm -f -- "$bundle"
        rm -rf -- "$stage"
        return 1
    fi
    if ! deliver_bundle_check "$bundle" "$commit" "$stage/check"; then
        rm -f -- "$bundle"
        rm -rf -- "$stage"
        return 1
    fi
    digest=$(sha256sum -- "$bundle" 2>/dev/null) || digest=""
    rm -rf -- "$stage"
    if [ -z "$digest" ]; then
        deliver_refuse "the bundle $bundle could not be digested"
        rm -f -- "$bundle"
        return 1
    fi
    printf 'BUNDLE|%s|%s|%s|%s\n' COMPLETE "$commit" "${digest%% *}" "$bundle"
    return 0
}

deliver_main() {
    local repo="" commit="" into="" bundle=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --repo) repo="${2:-}"; shift 2 || return 2 ;;
            --commit) commit="${2:-}"; shift 2 || return 2 ;;
            --into) into="${2:-}"; shift 2 || return 2 ;;
            --bundle) bundle="${2:-}"; shift 2 || return 2 ;;
            *) deliver_refuse "$DELIVER_USAGE"; return 2 ;;
        esac
    done
    if [ -z "$repo" ] || [ -z "$commit" ] || { [ -z "$into" ] && [ -z "$bundle" ]; } \
        || { [ -n "$into" ] && [ -n "$bundle" ]; }; then
        deliver_refuse "$DELIVER_USAGE"
        return 2
    fi
    deliver_check_source "$repo" "$commit" || return 1
    if [ -n "$bundle" ]; then
        deliver_bundle "$repo" "$commit" "$bundle"
        return
    fi
    deliver_into "$repo" "$commit" "$into"
}

# --- MAIN BOUNDARY ---
# Everything above is definitions; everything below delivers. Sourcing this file
# defines its functions and writes nothing, which is the seam the harness uses to
# drive one refusal at a time without a workspace to clean up after.
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    return 0
fi

deliver_main "$@"
