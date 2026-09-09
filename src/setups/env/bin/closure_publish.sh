#!/bin/bash
# The publication boundary: the last thing that can refuse an archive, and the
# only thing that makes the gate mean UNPUBLISHABLE WHILE INCOMPLETE rather than
# merely reported.
#
# PUBLICATION TAKES NO POLICY AND NO EVIDENCE FROM THE ARCHIVE. It resolves the
# configuration from cplx at the release commit and it computes the archive's
# identity itself. Everything the candidate carries is a claim to check, never a
# fact to read, which is the whole of why this file exists beside a gate that
# already ran: the gate ran on the build account, against the tree it was about
# to tar, and neither of those is the file being published.
#
# THE FIVE STEPS ARE AN ORDER, NOT A SET, and step 1 is why. A stripped, weakened
# or swapped configuration fails BEFORE the waiver question is ever asked, so "no
# active waivers" is never returned by an absence:
#
#   0. compute the archive identity, the SHA-256 of the completed file's exact
#      bytes, over the file itself and never over an unpacked tree;
#   1. resolve the authoritative configuration from cplx at the release commit
#      and require the archive's envelope digest to equal that document's;
#   2. require a verification result KEYED TO THE IDENTITY FROM STEP 0, naming
#      that same configuration digest, present and passing;
#   3. re-run the static checker over this archive's contents against the
#      configuration PUBLICATION RESOLVED, not the one the archive carries;
#   4. refuse if any validated waiver is active, with no mode and no flag that
#      permits one.
#
# STEP 0 IS WHY STEP 2 IS A CHECK RATHER THAN A LOOKUP. Two different identities
# are needed and they are different kinds: the CONFIGURATION digest names
# reusable policy bytes and is the same across every archive built under that
# policy, so it cannot bind evidence to an artifact; the ARCHIVE identity does,
# and publication computes it rather than reading it.
#
# It sources `closure_config.sh` alone. Publication needs the parser, the digest
# and the cplx-side resolution and needs none of the invariants, which is the
# module boundary paying for itself: the checker re-run in step 3 is a CHILD
# PROCESS, so the verdict it returns is one this file could not have produced.

set -u

CLOSURE_PUBLISH_DIR="${BASH_SOURCE[0]%/*}"
if [ "$CLOSURE_PUBLISH_DIR" = "${BASH_SOURCE[0]}" ]; then
    CLOSURE_PUBLISH_DIR="."
fi
# shellcheck source=/dev/null
if [ -f "$CLOSURE_PUBLISH_DIR/closure_config.sh" ]; then
    source "$CLOSURE_PUBLISH_DIR/closure_config.sh"
fi

CLOSURE_PUBLISH_USAGE="Usage: closure_publish.sh --archive PATH --commit SHA --repo DIR --results DIR [--staging-root DIR] [--adapter FILE]"

# ------------------------------------------------------------- the adapter ABI ---
# THE FOUR OPERATIONS ARE THIS EFFORT'S ADAPTER ABI, and these are their default
# implementations: they refuse. An adapter sourced by the run overrides all four,
# so a publication with no adapter REFUSES rather than reaching an undefined
# command, and adding a fifth operation later means declaring it here rather than
# discovering it at a call site.
#
# They are defined here rather than declared in the host-tool contract because
# they are not host tools. The contract enumerates what a shipped script depends
# on the HOST to supply; these are supplied by the CALLER, and umbrella item 7
# owns the real one. Where an uploader cannot be invoked this way, this plan does
# not claim the checked-byte property rather than assuming it.
upload_begin() {
    printf 'closure_publish: no uploader adapter is loaded, so no stage can be created\n' >&2
    return 1
}
upload_write() {
    cat > /dev/null
    printf 'closure_publish: no uploader adapter is loaded, so nothing is written\n' >&2
    return 1
}
upload_abort() {
    printf 'closure_publish: no uploader adapter is loaded, so there is nothing to abort\n' >&2
    return 1
}
upload_commit() {
    printf 'closure_publish: no uploader adapter is loaded, so nothing is made public\n' >&2
    return 1
}

# The identity of the file being published, and the value everything else is
# keyed to. It is taken from the FILE, because an identity taken from an unpacked
# tree would name something nobody publishes.
CLOSURE_PUBLISH_IDENTITY=""
closure_publish_identity() {
    local out=""
    out=$(sha256sum -- "$1" 2>/dev/null) || return 1
    CLOSURE_PUBLISH_IDENTITY="${out%% *}"
    [ -n "$CLOSURE_PUBLISH_IDENTITY" ]
}

closure_publish_refuse() {
    printf 'CLOSURE PUBLICATION REFUSED at step %s: %s\n' "$1" "$2" >&2
    return 1
}

# --------------------------------------------------------- the promoted file ---
# THE GATE REFUSES TO ACT ON A PATH IT WAS MERELY SHOWN, and the order below is
# exact because a digest-derived name is not immutable by itself. The owner of a
# 0700 directory can still modify, unlink or replace a file inside it after the
# name is returned, so the name is never what travels.
#
#   1. create a regular temporary file EXCLUSIVELY inside a staging root this
#      gate owns, mode 0700, refused if it is a symlink, not a directory, or
#      writable by group or other;
#   2. copy the candidate into that temporary file;
#   3. compute the SHA-256 of the COMPLETED COPY, never of the source, so a
#      source mutated during the copy cannot be certified;
#   4. promote the copy atomically and WITHOUT OVERWRITE to its digest-derived
#      name by linking it, which fails if the name exists, then unlink the
#      temporary name;
#   5. open that promoted file once, read-only, and use THAT INSTANCE for the
#      five steps and for the handoff.
closure_publish_staging_ok() {
    local root="$1" loose=""
    if [ -L "$root" ]; then
        closure_publish_refuse 0 "the staging root $root is a symlink"
        return 1
    fi
    if [ ! -d "$root" ]; then
        closure_publish_refuse 0 "the staging root $root is not a directory"
        return 1
    fi
    # ASKED OF THE DIRECTORY ITSELF, with `find` rather than `stat`, because
    # `find` is on this effort's contract and `stat` is not, and the question is
    # a permission PREDICATE rather than a mode to print: this account owns
    # the directory and its mode is exactly 0700. A failed query refuses too.
    if [ ! -O "$root" ]; then
        closure_publish_refuse 0 "the staging root $root is not owned by this account"
        return 1
    fi
    loose=$(find "$root" -maxdepth 0 ! -perm 0700 2>/dev/null) || {
        closure_publish_refuse 0 "the staging root permissions could not be checked"
        return 1
    }
    if [ -n "$loose" ]; then
        closure_publish_refuse 0 "the staging root $root must have mode 0700"
        return 1
    fi
    return 0
}

CLOSURE_PUBLISH_PROMOTED=""
closure_publish_promote() {
    local candidate="$1" root="$2" tmp="" digest=""

    closure_publish_staging_ok "$root" || return 1
    tmp=$(mktemp "$root/.cand.XXXXXXXX") || {
        closure_publish_refuse 0 "no exclusive temporary file could be created in $root"
        return 1
    }
    if ! cat -- "$candidate" > "$tmp"; then
        rm -f -- "$tmp"
        closure_publish_refuse 0 "the candidate could not be copied into the staging root"
        return 1
    fi
    # THE COMPLETED COPY IS WHAT IS HASHED. A source mutated during the copy
    # yields a digest describing what was actually captured, which is the only
    # value the later steps can honestly be keyed to.
    digest=$(sha256sum -- "$tmp" 2>/dev/null) || digest=""
    digest="${digest%% *}"
    if [ -z "$digest" ]; then
        rm -f -- "$tmp"
        closure_publish_refuse 0 "the staged copy could not be digested"
        return 1
    fi
    CLOSURE_PUBLISH_PROMOTED="$root/$digest"
    # LINK, NEVER RENAME: `ln` fails if the name exists, and that failure is the
    # no-overwrite guarantee. -T also refuses a directory or a symlink to one;
    # neither may be treated as a directory to create the link inside.
    if ! ln -T -- "$tmp" "$CLOSURE_PUBLISH_PROMOTED" 2>/dev/null; then
        rm -f -- "$tmp"
        CLOSURE_PUBLISH_PROMOTED=""
        closure_publish_refuse 0 "the promoted name already exists and is never overwritten"
        return 1
    fi
    rm -f -- "$tmp"
    CLOSURE_PUBLISH_IDENTITY="$digest"
    return 0
}

# ------------------------------------------------------------- the five steps ---
# Step 1: the archive's own envelope must name the digest of the document cplx
# holds at the release commit. The comparison is against what PUBLICATION
# resolved, so a stripped or swapped bundle fails here, first, and ahead of every
# question a weakened declaration would otherwise answer favourably.
closure_publish_step1() {
    local archive="$1" repo="$2" commit="$3" work="$4" resolved="" carried=""

    if ! closure_config_resolve_commit "$repo" \
        "src/setups/env/closure/closure-config.txt" "$commit" "$work/authoritative.txt"; then
        closure_publish_refuse 1 "the authoritative configuration could not be resolved from cplx at $commit"
        return 1
    fi
    resolved=$(closure_config_digest "$work/authoritative.txt")
    if [ -z "$resolved" ]; then
        closure_publish_refuse 1 "the authoritative configuration could not be digested"
        return 1
    fi
    if ! tar -xzf "$archive" -C "$work/tree" 2>/dev/null; then
        closure_publish_refuse 1 "the candidate archive could not be read"
        return 1
    fi
    if [ ! -f "$work/tree/tools/closure/closure-envelope.txt" ]; then
        closure_publish_refuse 1 "the archive carries no configuration envelope, and its absence is refused here rather than treated as nothing to check"
        return 1
    fi
    if ! closure_envelope_check "$work/tree/tools/closure/closure-config.txt" \
        "$work/tree/tools/closure/closure-envelope.txt"; then
        closure_publish_refuse 1 "the archive's configuration bundle is absent or inconsistent"
        return 1
    fi
    carried="$CLOSURE_ENVELOPE_DIGEST"
    if [ "$carried" != "$resolved" ]; then
        closure_publish_refuse 1 "the archive's envelope names $carried and cplx at $commit resolves to $resolved"
        return 1
    fi
    CLOSURE_PUBLISH_CONFIG_DIGEST="$resolved"
    return 0
}

# Step 2: the verification result, KEYED TO THE IDENTITY STEP 0 COMPUTED. A
# result that exists for some archive is not evidence about this one, so the
# lookup is by that identity and the record must also name the configuration
# digest publication resolved.
closure_publish_step2() {
    local results="$1" record="$2/$CLOSURE_PUBLISH_IDENTITY" state="" cfg="" line=""

    if [ ! -f "$record" ]; then
        closure_publish_refuse 2 "no verification result is keyed to archive identity $CLOSURE_PUBLISH_IDENTITY"
        return 1
    fi
    # READ IN THE SHELL, for the reason the line counter upstream is: `grep` is
    # not on this effort's contract, and a record of two fields does not need a
    # process to read it. The first occurrence of each field wins, so a record
    # that repeats one cannot change the answer by appending to itself.
    while IFS= read -r line; do
        case "$line" in
            'state|'*) [ -n "$state" ] || state="${line#state|}" ;;
            'configuration|'*) [ -n "$cfg" ] || cfg="${line#configuration|}" ;;
        esac
    done < "$record"
    if [ "$cfg" != "$CLOSURE_PUBLISH_CONFIG_DIGEST" ]; then
        closure_publish_refuse 2 "the verification result was taken under configuration ${cfg:-none} and publication resolved $CLOSURE_PUBLISH_CONFIG_DIGEST"
        return 1
    fi
    if [ "$state" != "passing" ]; then
        closure_publish_refuse 2 "the verification result for this archive is '${state:-absent}' rather than passing"
        return 1
    fi
    return 0
}

# Steps 3 and 4: the static re-check over THIS archive's contents against the
# configuration publication resolved, and the waiver refusal. They are one call
# because the checker answers both: status 3 is its "carried by an accepted
# exception" result, and publication turns exactly that into a refusal.
closure_publish_step34() {
    local work="$1" repo="$2" rc=0

    mkdir -p -- "$work/policy" || return 1
    cp -- "$work/authoritative.txt" "$work/policy/closure-config.txt" || return 1
    { printf 'CPLX-CLOSURE-ENVELOPE/1\n'
      printf 'digest|%s\n' "$CLOSURE_PUBLISH_CONFIG_DIGEST"
      printf 'source|%s|%s\n' "src/setups/env/closure/closure-config.txt" "$CLOSURE_PUBLISH_COMMIT"
    } > "$work/policy/closure-envelope.txt" || return 1

    bash "$repo/src/setups/env/bin/closure_check.sh" --prefix "$work/tree" \
        --installer "$repo/src/setups/env/bin/install_pkg.sh" \
        --bundle "$work/policy" > "$work/recheck.out" 2>&1 || rc=$?
    case "$rc" in
        0) return 0 ;;
        3)
            closure_publish_refuse 4 "an active waiver makes this archive a validation artifact, and no mode or flag permits publishing one"
            return 1 ;;
        *)
            closure_publish_refuse 3 "the static re-check over this archive refused with status $rc"
            return 1 ;;
    esac
}

CLOSURE_PUBLISH_CONFIG_DIGEST=""
CLOSURE_PUBLISH_COMMIT=""

# ---------------------------------------------------------------- the handoff ---
# THE HANDOFF IS A DESCRIPTOR, NEVER A PATHNAME. Returning the promoted name and
# exiting hands back the time-of-check gap the promotion just closed: a 0700
# directory and a digest-derived basename do not stop the owner modifying,
# unlinking or replacing the file afterwards. So this gate keeps the open
# descriptor and INVOKES the uploader, which reads THAT DESCRIPTOR and reopens
# nothing.
#
# THE UPLOAD IS TRANSACTIONAL, AND THAT IS WHAT MAKES THE ONE-READ DESIGN SAFE. A
# single pass hands bytes over before the digest is known, and a non-zero exit
# cannot retract a public upload. So the adapter has four operations:
# `upload_begin` creates an object that IS NOT PUBLICLY VISIBLE and prints its
# handle, `upload_write` consumes stdin into it, `upload_abort` destroys it
# leaving nothing public, and `upload_commit` makes it public atomically. THOSE
# FOUR NAMES ARE THIS EFFORT'S ADAPTER ABI. Umbrella item 7 keeps whatever public
# API it has and supplies an adapter with these semantics; this plan does not
# impose its names on item 7's surface, and where an uploader cannot be invoked
# this way the property is NOT claimed rather than assumed.
closure_publish_upload() {
    local expected="$1" scratch="" fifo="" seen=""
    local hasher="" pipe_rc=0 hash_rc=0 digest="" tool=""

    # EVERY TRANSACTION COMMAND IS PREFLIGHTED BEFORE transaction scratch or a
    # remote stage exists, so an absent command cannot strand either one.
    for tool in cat tee mkfifo sha256sum mktemp chmod rm; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            closure_publish_refuse 4 "the transaction needs $tool and this host does not resolve it"
            return 1
        fi
    done

    scratch=$(mktemp -d "$CLOSURE_PUBLISH_STAGING/.pub.XXXXXXXX") || {
        closure_publish_refuse 4 "no transaction scratch could be created"
        return 1
    }
    CLOSURE_PUBLISH_SCRATCH="$scratch"
    CLOSURE_PUBLISH_STAGE=""
    CLOSURE_PUBLISH_COMMITTED=0
    # THE TRAP IS ARMED AS SOON AS SCRATCH EXISTS, not after `upload_begin`: a
    # `chmod` or `upload_begin` failure must still remove the directory. The
    # stage handle starts empty and the trap aborts only when it is non-empty, so
    # arming early cannot abort a stage that was never created. CLEANUP IS
    # SINGLE-ENTRY, so a signal arriving during cleanup cannot call
    # `upload_abort` twice.
    trap closure_publish_cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP

    if ! chmod 700 "$scratch"; then
        closure_publish_refuse 4 "the transaction scratch could not be protected"
        return 1
    fi
    fifo="$scratch/hash.fifo"
    seen="$scratch/hash.out"
    CLOSURE_PUBLISH_STAGE=$(upload_begin) || {
        CLOSURE_PUBLISH_STAGE=""
        closure_publish_refuse 4 "the uploader could not begin a non-public stage"
        return 1
    }

    if ! mkfifo "$fifo"; then
        closure_publish_refuse 4 "the hashing FIFO could not be created"
        return 1
    fi
    sha256sum > "$seen" < "$fifo" &
    hasher=$!
    CLOSURE_PUBLISH_HASHER="$hasher"

    # `set -o pipefail` IS IN THE FLOW and not in the prose about it: without it
    # the captured status carries only the last command's, so a `cat` or `tee`
    # failure would be invisible while this file claimed otherwise.
    set -o pipefail
    cat <&"${CPLX_CLOSURE_ARCHIVE_FD}" | tee "$fifo" | upload_write "$CLOSURE_PUBLISH_STAGE" \
        || pipe_rc=$?
    # THE HASHER MUST TERMINATE EVEN WHEN NOTHING EVER WROTE TO THE FIFO, which
    # is the liveness hole the first version of this flow had. `sha256sum <
    # "$fifo"` blocks in its OPEN until a writer arrives, so a `tee` that failed
    # before opening the FIFO left this process waiting for a writer that will
    # never exist, and the run hung instead of refusing. Awaiting a participant
    # is not the same as guaranteeing it can be awaited.
    #
    # So a failed pipeline ends the hasher rather than waiting on it. The kill is
    # unconditional on that path and its own failure is ignored: a hasher that
    # already exited is exactly the case where there is nothing to kill.
    if [ "$pipe_rc" -ne 0 ]; then
        kill "$hasher" 2>/dev/null || true
    fi
    wait "$hasher" || hash_rc=$?
    CLOSURE_PUBLISH_HASHER=""
    # The digest file is checked for CONTENT before it is read, so an empty or
    # unreadable result refuses rather than comparing an empty string.
    if [ ! -s "$seen" ]; then
        closure_publish_refuse 4 "the streamed digest could not be read back"
        return 1
    fi
    if ! read -r digest _ < "$seen"; then
        closure_publish_refuse 4 "the streamed digest could not be read back"
        return 1
    fi

    # AWAIT ALL, COMPARE, THEN COMMIT. Statuses are captured through
    # or-assignments rather than bare commands, so an enclosing `errexit` cannot
    # kill the run before the values are read.
    if [ "$pipe_rc" -ne 0 ] || [ "$hash_rc" -ne 0 ] || [ "$digest" != "$expected" ]; then
        closure_publish_refuse 4 "the streamed bytes differ from the promoted archive, so nothing is published"
        return 1
    fi

    if ! upload_commit "$CLOSURE_PUBLISH_STAGE"; then
        closure_publish_refuse 4 "the uploader could not commit, so nothing is public"
        return 1
    fi
    # The committed flag FLIPS ONLY AFTER `upload_commit` RETURNS 0, so every
    # other exit path, a signal and a commit failure included, aborts the stage.
    CLOSURE_PUBLISH_COMMITTED=1
    return 0
}

# FAILURE POSTCONDITIONS ARE STATED, so a caller always knows what exists.
# `upload_begin` failing leaves nothing staged and nothing public; `upload_abort`
# succeeding leaves nothing public and no retained stage, and failing leaves a
# stage that MAY persist, named on stderr, with the run still refusing. IF THE
# SCRATCH REMOVAL ITSELF FAILS the path is named and the verdict is unchanged:
# local cleanup is an operator concern and publication does not depend on it.
closure_publish_cleanup() {
    local rc=$?
    trap - EXIT INT TERM HUP
    # THE HASHER IS ENDED BEFORE ANYTHING ELSE, for the same reason the failed
    # pipeline ends it: an interruption can arrive while it is still blocked on a
    # FIFO nobody opened, and a cleanup that then removed the FIFO and waited
    # would hang in the handler.
    if [ -n "${CLOSURE_PUBLISH_HASHER:-}" ]; then
        kill "$CLOSURE_PUBLISH_HASHER" 2>/dev/null || true
        wait "$CLOSURE_PUBLISH_HASHER" 2>/dev/null || true
        CLOSURE_PUBLISH_HASHER=""
    fi
    if [ -n "${CLOSURE_PUBLISH_STAGE:-}" ] && [ "${CLOSURE_PUBLISH_COMMITTED:-0}" -eq 0 ]; then
        upload_abort "$CLOSURE_PUBLISH_STAGE" \
            || printf 'abort FAILED, stage %s may persist\n' "$CLOSURE_PUBLISH_STAGE" >&2
    fi
    if [ -n "${CLOSURE_PUBLISH_SCRATCH:-}" ]; then
        rm -rf -- "$CLOSURE_PUBLISH_SCRATCH" \
            || printf 'scratch %s NOT removed\n' "$CLOSURE_PUBLISH_SCRATCH" >&2
    fi
    return "$rc"
}

# ------------------------------------------------------------ the entry point ---
closure_publish_main() {
    local archive="" commit="" repo="" results="" adapter="" work="" rc=0 snapshot=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --archive|--commit|--repo|--results|--staging-root|--adapter)
                if [ "$#" -lt 2 ]; then
                    printf 'closure_publish: missing operand for %s\n' "$1" >&2
                    printf '%s\n' "$CLOSURE_PUBLISH_USAGE" >&2
                    return 2
                fi
                case "$1" in
                    --archive) archive="$2" ;;
                    --commit) commit="$2" ;;
                    --repo) repo="$2" ;;
                    --results) results="$2" ;;
                    --staging-root) CLOSURE_PUBLISH_STAGING="$2" ;;
                    --adapter) adapter="$2" ;;
                esac
                shift 2 ;;
            -h|--help) printf '%s\n' "$CLOSURE_PUBLISH_USAGE"; return 0 ;;
            *)
                printf 'closure_publish: unknown argument: %s\n' "$1" >&2
                printf '%s\n' "$CLOSURE_PUBLISH_USAGE" >&2
                return 2 ;;
        esac
    done
    if [ -z "$archive" ] || [ -z "$commit" ] || [ -z "$repo" ] || [ -z "$results" ]; then
        printf '%s\n' "$CLOSURE_PUBLISH_USAGE" >&2
        return 2
    fi
    CLOSURE_PUBLISH_COMMIT="$commit"

    # STEP 0, and it runs over the PROMOTED file rather than the candidate the
    # caller named, because the candidate is a path this gate was merely shown.
    closure_publish_promote "$archive" "$CLOSURE_PUBLISH_STAGING" || return 1

    # THE DESCRIPTOR IS OPENED HERE, BEFORE THE CHECKS, AND EVERYTHING AFTER
    # BINDS TO IT. An earlier version opened it only for the handoff and let
    # steps 1 to 4 read the promoted PATHNAME, which put the time-of-check gap
    # straight back: the owner of the staging directory can unlink that name and
    # put a different file there between the check and the upload, so the bytes
    # that were examined and the bytes that were sent were only presumed to be
    # the same file.
    #
    # `/dev/fd/N` is what makes one descriptor serve both. Opening it for a
    # regular file yields a NEW open file description on THE SAME INODE, with its
    # own offset, so each step reads the archive from the beginning while none of
    # them resolves the pathname again. Replacing or unlinking the promoted name
    # after this point changes nothing any step sees.
    if ! exec {CPLX_CLOSURE_ARCHIVE_FD}< "$CLOSURE_PUBLISH_PROMOTED"; then
        closure_publish_refuse 0 "the promoted archive could not be opened"
        return 1
    fi
    CLOSURE_PUBLISH_INSTANCE="/dev/fd/$CPLX_CLOSURE_ARCHIVE_FD"

    work=$(mktemp -d "$CLOSURE_PUBLISH_STAGING/.work.XXXXXXXX") || return 1
    mkdir -p -- "$work/tree" || return 1

    # THE CHECKS READ A SNAPSHOT WHOSE DIGEST IS THE IDENTITY, which is what an
    # open descriptor alone does not give. The descriptor stops the promoted NAME
    # being replaced; it does not stop an IN-PLACE WRITE to the same inode, so an
    # A-to-B-to-A sequence could let the checks read B while the upload hashed A.
    # Both halves are now bound to one value: this snapshot is taken in a single
    # read and refused unless it hashes to the identity, and the upload compares
    # its own streamed digest to that same identity. Two things equal to the same
    # digest are equal to each other.
    #
    # The snapshot is read through `/dev/fd/N`, a fresh open on the same inode, so
    # the original descriptor keeps its offset at zero for the upload.
    if ! cat -- "$CLOSURE_PUBLISH_INSTANCE" > "$work/candidate"; then
        rm -rf -- "$work"
        exec {CPLX_CLOSURE_ARCHIVE_FD}<&-
        closure_publish_refuse 0 "the promoted archive could not be read"
        return 1
    fi
    snapshot=$(sha256sum -- "$work/candidate" 2>/dev/null) || snapshot=""
    snapshot="${snapshot%% *}"
    if [ "$snapshot" != "$CLOSURE_PUBLISH_IDENTITY" ]; then
        rm -rf -- "$work"
        exec {CPLX_CLOSURE_ARCHIVE_FD}<&-
        closure_publish_refuse 0 "the promoted archive changed under its own identity: it now hashes to ${snapshot:-nothing}"
        return 1
    fi

    closure_publish_step1 "$work/candidate" "$repo" "$commit" "$work" || rc=1
    if [ "$rc" -eq 0 ]; then closure_publish_step2 "$results" "$results" || rc=1; fi
    if [ "$rc" -eq 0 ]; then closure_publish_step34 "$work" "$repo" || rc=1; fi
    if [ "$rc" -ne 0 ]; then
        rm -rf -- "$work"
        exec {CPLX_CLOSURE_ARCHIVE_FD}<&-
        return 1
    fi

    if [ -z "$adapter" ]; then
        rm -rf -- "$work"
        exec {CPLX_CLOSURE_ARCHIVE_FD}<&-
        closure_publish_refuse 4 "no uploader adapter is loaded, so publication cannot commit"
        return 1
    fi
    # THE FIVE STEPS PASSED, and the uploader reads THE SAME DESCRIPTOR they were
    # checked through. It was opened before step 1 and is not reopened here,
    # which is the whole of the one-read guarantee: the checked bytes and the
    # uploaded bytes are the same inode by construction rather than by timing.
    # shellcheck source=/dev/null
    if ! source "$adapter"; then
        rm -rf -- "$work"
        exec {CPLX_CLOSURE_ARCHIVE_FD}<&-
        return 1
    fi
    closure_publish_upload "$CLOSURE_PUBLISH_IDENTITY" || rc=1
    exec {CPLX_CLOSURE_ARCHIVE_FD}<&-
    rm -rf -- "$work"
    if [ "$rc" -ne 0 ]; then return 1; fi
    printf 'CLOSURE PUBLICATION OK: archive identity %s under configuration %s\n' \
        "$CLOSURE_PUBLISH_IDENTITY" "$CLOSURE_PUBLISH_CONFIG_DIGEST"
    return 0
}

CLOSURE_PUBLISH_STAGING="${CLOSURE_PUBLISH_STAGING:-${TMPDIR:-/tmp}/cplx-publish}"
CLOSURE_PUBLISH_SCRATCH=""
CLOSURE_PUBLISH_STAGE=""
CLOSURE_PUBLISH_COMMITTED=0
CLOSURE_PUBLISH_HASHER=""
CLOSURE_PUBLISH_INSTANCE=""

# --- MAIN BOUNDARY ---
# Everything above is definitions; everything below publishes. Sourcing this file
# defines its functions and publishes nothing, which is the seam the harness uses
# to drive one step at a time against a stub uploader.
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    return 0
fi

closure_publish_main "$@"
