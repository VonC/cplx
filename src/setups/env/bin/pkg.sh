#!/bin/bash

set -o pipefail

# Canonical cplx copy of the packaging tool: archives one folder of the
# account (typically the live tree 'tools') into a deterministic tarball
# under ~/pkgs, deduplicated by SHA1, with a '<target>.latest.tar.gz'
# symlink. The matching relocating installer is install_pkg.sh.
# Consuming projects add their target rules through --add and the --
# tar passthrough (my-project does in its tools/pkg_pdfs.sh overlay:
# see my-project docs/pkg-tools-migration-to-cplx.md).

# echos sits next to this script (standalone copy) or one level up
# (~/cplx/bin + ~/cplx/echos, and ~/tools/bin + ~/tools/echos after rsync.sh).
PKG_SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for pkg_sh_echos in "${PKG_SH_DIR}/echos" "${PKG_SH_DIR}/../echos/echos"; do
    if [ -f "${pkg_sh_echos}" ]; then
        # shellcheck disable=SC1090
        source "${pkg_sh_echos}"
        break
    fi
done
if ! command -v task >/dev/null 2>&1; then
    task()    { echo " Task=>: [pkg.sh] $1"; }
    info()    { echo " Info  : [pkg.sh] $1"; }
    ok()      { echo " Ok    : [pkg.sh] $1"; }
    warning() { echo " Warn  : [pkg.sh] $1"; }
    error()   { echo " Error : [pkg.sh] $1" >&2; }
    fatal()   { echo " FATAL ${2} : [pkg.sh] $1" >&2; exit "${2}"; }
fi

# ================= CONFIGURATION =================
# Arguments: <folder_name> [--add <item>]... [-- <tar args...>]
# The folder inside $HOME to package comes first. Each --add ships one
# extra top-level item (a path relative to $HOME) next to it in the
# archive. Everything after the -- sentinel is passed to tar verbatim,
# in order, so a consuming project can inject its own exclusion rules
# without forking this script (my-project does: see its
# tools/pkg_pdfs.sh overlay).
PKG_USAGE="Usage: $0 <folder_name> [--closure-gate] [--source-root <dir>] [--add <item>]... [-- <tar args...>]"
TARGET_FOLDER=""
EXTRA_ITEMS=()
EXTRA_TAR_PARAMS=()
CLOSURE_GATE=0
# WHERE THE PACKAGED TREE IS READ FROM, which is NOT where the run writes, reads
# its history or resolves its extra items. Those stay anchored at $HOME, because
# they are this command's public interface: the path it prints, the `latest`
# pointer it maintains, the digests it compares against and the `--add` inputs a
# caller names are all the caller's, not the source tree's. Only the subject
# moves. Defaulting to $HOME makes an unflagged run byte-identical to before.
PKG_SOURCE_ROOT="$HOME"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --closure-gate)
            CLOSURE_GATE=1
            ;;
        --source-root)
            if [ -z "$2" ]; then
                fatal "--source-root requires a directory argument. $PKG_USAGE" 1
            fi
            if [ ! -d "$2" ]; then
                fatal "--source-root names no directory: $2. $PKG_USAGE" 1
            fi
            PKG_SOURCE_ROOT="$2"
            shift
            ;;
        --add)
            if [ -z "$2" ]; then
                fatal "--add requires an item argument. $PKG_USAGE" 1
            fi
            EXTRA_ITEMS+=("$2")
            shift
            ;;
        --)
            shift
            EXTRA_TAR_PARAMS=("$@")
            break
            ;;
        -*)
            fatal "Unknown option: $1. $PKG_USAGE" 1
            ;;
        *)
            if [ -n "$TARGET_FOLDER" ]; then
                fatal "Only one folder can be packaged ('$TARGET_FOLDER' and '$1'). $PKG_USAGE" 1
            fi
            TARGET_FOLDER="$1"
            ;;
    esac
    shift
done
if [ -z "$TARGET_FOLDER" ]; then
    fatal "$PKG_USAGE" 1
fi

# THE SELECTOR IS TOTAL, WHICH IS WHY THERE ARE TWO REFUSALS AND NOT ONE. The
# gate is entered when and only when `--closure-gate` is present, and both
# corners where the flag and the target disagree are errors rather than
# defaults:
#
#   the flag with any other target has NO CONTRACT. This gate stages a
#   configuration that declares the toolchain's roots, floor and entry points;
#   applied to another payload it would judge that payload against a
#   declaration written for this one.
#
#   the target `tools` WITHOUT the flag is the run this requirement exists to
#   gate, and letting it through by omission is exactly the failure the flag was
#   chosen to make impossible. A quietly ungated toolchain archive is
#   indistinguishable from a checked one once it leaves this account.
#
# Every other target with no flag behaves as it did before this effort and never
# reaches the branch, which is the property `verify.install-pkg.sh` still holds.
if [ "$CLOSURE_GATE" -eq 1 ] && [ "$TARGET_FOLDER" != "tools" ]; then
    fatal "--closure-gate applies to the 'tools' payload only, and this run packages '$TARGET_FOLDER'. $PKG_USAGE" 1
fi
if [ "$CLOSURE_GATE" -eq 0 ] && [ "$TARGET_FOLDER" = "tools" ]; then
    fatal "packaging 'tools' requires --closure-gate: an ungated toolchain archive is not producible here. $PKG_USAGE" 1
fi

# Destination for packages
PKG_DIR="$HOME/pkgs"

# Default exclusion params (matches any folder named "old")
EXCLUDE_PARAMS=("--exclude=old")
# =================================================

task "Starting package process for folder: $TARGET_FOLDER"

# Ensure package directory exists
mkdir -p "$PKG_DIR"

# 1. Define Names
# We use a variable for the current time to label the files
NOW=$(date +"%Y-%m-%d_%H%M%S")
TAR_NAME="${TARGET_FOLDER}.${NOW}.tar.gz"
SHA_NAME="${TARGET_FOLDER}.${NOW}.sha1"

TAR_PATH="${PKG_DIR}/${TAR_NAME}"
SHA_PATH="${PKG_DIR}/${SHA_NAME}"

# 2. Create the Archive (Deterministic + Exclude)
# Prepare items to archive
ITEMS_TO_ARCHIVE=("$TARGET_FOLDER")
# The caller's own items, which are read from $HOME even when the subject tree is
# read from elsewhere. `tar` takes a second `-C`, so both roots are honoured in
# one archive and an `--add` path keeps meaning what the caller meant by it.
HOME_ITEMS=()

# If TARGET_FOLDER is "tools", also ship the home-level env files when
# they exist, so the target account gets a working session after install.
# Application-specific target rules (extra exclusions, extra files) belong
# to the consuming project's own packaging, not here.
if [ "$TARGET_FOLDER" == "tools" ]; then
    for extra_env_file in .env .env_; do
        if [ -e "$HOME/$extra_env_file" ]; then
            task "Target is 'tools', adding $extra_env_file to archive list"
            HOME_ITEMS+=("$extra_env_file")
        fi
    done
fi

# Apply the caller's extension arguments: extra items first, then the
# verbatim tar rules (appended after the default exclusions, so the
# caller's --no-wildcards-match-slash toggles keep their relative order).
for extra_item in "${EXTRA_ITEMS[@]}"; do
    task "Adding requested extra item to archive list: $extra_item"
    HOME_ITEMS+=("$extra_item")
done
if [ "${#EXTRA_TAR_PARAMS[@]}" -gt 0 ]; then
    task "Applying ${#EXTRA_TAR_PARAMS[@]} caller-provided tar argument(s)"
    EXCLUDE_PARAMS+=("${EXTRA_TAR_PARAMS[@]}")
fi

# -C "$HOME"                   : Jump to home so we archive relative path '$TARGET_FOLDER/'
# "${EXCLUDE_PARAMS[@]}"       : Applies exclusion patterns
# --sort=name                  : Ensures consistent file ordering for hash stability
# -cf -                        : Output to stdout (pipe) instead of a file
# gzip -n                      : Compresses without timestamp for hash stability
# ================= THE CLOSURE GATE =================
# Staging, checking and refusing, in that order and before any tar runs.
#
# THE GATE IS KEYED TO THE SELECTOR, NEVER TO THE BUNDLE'S PRESENCE. Once the
# branch is entered, a missing source file, a failed copy or an absent staged
# bundle is a REFUSAL, never a reason to skip the check. Deleting the bundle
# cannot turn the gate off, which is the hole a bundle-presence trigger leaves.
#
# THE SOURCE IS THE DEPLOYED CPLX TREE, AND THIS ACCOUNT RESOLVES NOTHING.
# An earlier version of this gate read every staged byte out of a Git commit,
# on the reasoning that a dirty working tree must not ship a declaration nobody
# reviewed. THE PREMISE WAS FALSE ON THE ONLY MACHINE THAT RUNS THIS: cplx
# arrives on the build account as copied scripts, not as a clone; neither
# `~/cplx/bin` nor `~/tools/bin` is inside a repository; and the one checkout
# that happens to sit on that account is a year stale, so resolving from it
# would have staged an old declaration while calling it authoritative.
#
# This file has never known anything about Git and does not learn now. The
# envelope is a COMMITTED FILE beside the declaration, so nothing produces it on
# the way here and nothing resolves a commit at deploy time. What this account
# can prove locally is that the document and its envelope agree, which is
# exactly what the agent proves and no more: a declaration and an envelope
# edited TOGETHER are self-consistent and this gate ACCEPTS them. The binding
# that catches that lives in publication, which resolves the configuration
# itself and runs where cplx is.
#
# The declaration is found the way `echos` already is, one level up from this
# script's own directory, because the deployed tree mirrors the repository:
# `src/setups/env/<x>` arrives as `<cplx root>/<x>`.
CLOSURE_SELF_DIR="${BASH_SOURCE[0]%/*}"
if [ "$CLOSURE_SELF_DIR" = "${BASH_SOURCE[0]}" ]; then
    CLOSURE_SELF_DIR="."
fi
CLOSURE_PAYLOAD_MODULES=(closure_check.sh closure_config.sh closure_elf.sh \
    closure_report.sh closure_rules.sh)

# One staged file, copied and then VERIFIED AGAINST ITS SOURCE. The verification
# is a SECOND READ OF THE SOURCE compared with the destination, not a re-hash of
# what was just written: what it has to catch is a truncated or partial write,
# and a file compared with itself catches nothing.
closure_stage_one() {
    local src="$1" dest="$2" want="" got=""
    if [ ! -f "$src" ]; then
        fatal "closure gate: $src is not in the deployed cplx tree, so it cannot be staged." 3
    fi
    if ! cat -- "$src" > "$dest"; then
        fatal "closure gate: $src could not be staged to $dest." 3
    fi
    want=$(sha256sum < "$src") || want=""
    got=$(sha256sum < "$dest") || got=""
    if [ -z "$want" ] || [ "$want" != "$got" ]; then
        fatal "closure gate: the staged copy of $src does not match its source." 3
    fi
}

# The digest the deployed envelope names, read in the shell because this file
# depends on no parser and needs one field. The first `digest` record wins, so
# an envelope that repeats the field cannot change the answer by appending.
closure_envelope_digest() {
    local envelope="$1" line="" found=""
    while IFS= read -r line; do
        case "$line" in
            'digest|'*) [ -n "$found" ] || found="${line#digest|}" ;;
        esac
    done < "$envelope"
    printf '%s' "$found"
}

closure_gate_run() {
    local root="" srcdir="" target="" stage="" bindir="" module="" rc=0
    local named="" computed=""
    root=$(cd -- "$CLOSURE_SELF_DIR/.." 2>/dev/null && pwd -P) || root=""
    if [ -z "$root" ]; then
        fatal "closure gate: the cplx tree above $CLOSURE_SELF_DIR could not be resolved." 3
    fi
    # THE SOURCE AND THE DESTINATION MUST DIFFER, and this is asked FIRST. This
    # script exists both in the deployed cplx tree and again inside the tools tree
    # it packages, so a gated run started from the copy INSIDE the payload would
    # read its declaration out of a payload it is packaging. That is not a
    # misconfiguration to warn about: it is a run certifying its own output.
    #
    # It is asked before the declaration exists, because it is a question about
    # WHERE THIS SCRIPT IS and not about what happens to be deployed beside it.
    # Asking it second made the refusal depend on a previous run having left a
    # declaration in the payload: remove that leftover and the same defective
    # invocation came back with "no declaration here", which sends an operator to
    # deploy one rather than to stop running from inside the payload.
    #
    # BOTH DESTINATIONS COUNT. `--source-root` can point the write somewhere other
    # than the caller's home, so a payload copy is refused whether it would write
    # into the source root's tree or into the caller's own.
    for target in "$PKG_SOURCE_ROOT/$TARGET_FOLDER" "$HOME/$TARGET_FOLDER"; do
        target=$(cd -- "$target" 2>/dev/null && pwd -P) || continue
        if [ "$root" = "$target" ]; then
            fatal "closure gate: this pkg.sh lives inside '$TARGET_FOLDER', so its source is its own destination; run the gated packaging from the deployed cplx tree." 3
        fi
    done

    srcdir="$root/closure"
    if [ ! -d "$srcdir" ]; then
        fatal "closure gate: no closure declaration is deployed at $srcdir, and the gate does not run without one." 3
    fi

    stage="$PKG_SOURCE_ROOT/$TARGET_FOLDER/closure"
    bindir="$PKG_SOURCE_ROOT/$TARGET_FOLDER/bin"

    # THE ENVELOPE IS VERIFIED, NOT WRITTEN. It is committed beside the
    # declaration and travels with it; this account digests the document and
    # requires the envelope to name that digest. That is a self-consistency
    # check and not an authority one.
    if [ ! -f "$srcdir/closure-config.txt" ] || [ ! -f "$srcdir/closure-envelope.txt" ]; then
        fatal "closure gate: the deployed bundle at $srcdir is missing its declaration or its envelope." 3
    fi
    named=$(closure_envelope_digest "$srcdir/closure-envelope.txt")
    computed=$(sha256sum < "$srcdir/closure-config.txt") || computed=""
    computed="${computed%% *}"
    if [ -z "$named" ] || [ -z "$computed" ] || [ "$named" != "$computed" ]; then
        fatal "closure gate: the deployed declaration hashes to ${computed:-nothing} and its envelope names ${named:-nothing}." 3
    fi

    mkdir -p -- "$stage" "$bindir" \
        || fatal "closure gate: cannot create the staging directories under $HOME/$TARGET_FOLDER." 3
    # Reject aliases before registering cleanup paths: unlinking a destination
    # reached through a directory symlink could otherwise remove a source file.
    for module in closure-config.txt closure-envelope.txt; do
        if [ "$srcdir/$module" -ef "$stage/$module" ]; then
            fatal "closure gate: source and destination name the same bundle file: $module." 3
        fi
    done
    for module in "${CLOSURE_PAYLOAD_MODULES[@]}"; do
        if [ "$CLOSURE_SELF_DIR/$module" -ef "$bindir/$module" ]; then
            fatal "closure gate: source and destination name the same module: $module." 3
        fi
    done
    CLOSURE_STAGED=("$stage/closure-config.txt" "$stage/closure-envelope.txt")
    for module in "${CLOSURE_PAYLOAD_MODULES[@]}"; do
        CLOSURE_STAGED+=("$bindir/$module")
    done

    task "Closure gate: staging the deployed declaration from $srcdir"
    closure_stage_one "$srcdir/closure-config.txt" "$stage/closure-config.txt"
    closure_stage_one "$srcdir/closure-envelope.txt" "$stage/closure-envelope.txt"

    # THE PAYLOAD COPIES, AND THEY ARE PAYLOAD. An operator debugging an
    # installed tree can read them; nothing executes them to produce evidence,
    # including when they are byte-identical to the authoritative copies. The
    # checker run below is the deployed cplx tree's, not one of these.
    for module in "${CLOSURE_PAYLOAD_MODULES[@]}"; do
        closure_stage_one "$CLOSURE_SELF_DIR/$module" "$bindir/$module"
    done

    if [ ! -s "$stage/closure-config.txt" ] || [ ! -s "$stage/closure-envelope.txt" ]; then
        fatal "closure gate: the staged bundle is absent or empty after staging." 3
    fi

    task "Closure gate: checking the tree the archive would carry"
    bash "$CLOSURE_SELF_DIR/closure_check.sh" --prefix "$PKG_SOURCE_ROOT" \
        --installer "$CLOSURE_SELF_DIR/install_pkg.sh" \
        --bundle "$stage" || rc=$?
    case "$rc" in
        0) task "Closure gate: the tree is closed, packaging continues" ;;
        3)
            # NOT A PASS AND NOT A REFUSAL. The archive is produced and it is a
            # VALIDATION ARTIFACT; the boundary that acts on that is publication,
            # which refuses it with no mode and no flag that permits one. Saying
            # so here is a report, not permission.
            task "Closure gate: an accepted exception carried this run, so the archive is a VALIDATION ARTIFACT and is not publishable"
            ;;
        *)
            closure_gate_unstage
            fatal "closure gate: the checker refused with status $rc, so no archive is produced." "$rc"
            ;;
    esac
}

# A REFUSAL LEAVES NOTHING BEHIND, so a later run cannot inherit a bundle it did
# not stage and then be judged against it.
closure_gate_unstage() {
    local staged
    for staged in ${CLOSURE_STAGED[@]+"${CLOSURE_STAGED[@]}"}; do
        rm -f -- "$staged"
    done
}

CLOSURE_STAGED=()
TAR_PARTIAL=""
pkg_cleanup() {
    local rc=$?
    if [ -n "$TAR_PARTIAL" ]; then rm -f -- "$TAR_PARTIAL"; fi
    if [ "$rc" -ne 0 ] && [ "$CLOSURE_GATE" -eq 1 ]; then
        closure_gate_unstage
    fi
}
trap pkg_cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
if [ "$CLOSURE_GATE" -eq 1 ]; then
    # Include source, write and verification failures, all of which may exit
    # through fatal before the checker is reached. Register destinations before
    # writing them so even a partially written module is removed.
    closure_gate_run
fi
# ====================================================

# Own a private temporary file on the destination filesystem. EXIT removes only
# this invocation's file, including failures during compression or hashing.
# Compare the digest before promotion: replacing a same-second archive and then
# deleting it as a duplicate would leave latest pointing at a missing file.
TAR_PARTIAL=$(mktemp "${TAR_PATH}.XXXXXXXX.partial") \
    || fatal "Failed to create a private archive candidate." 2
task "Creating candidate archive..."
if ! tar --sort=name "${EXCLUDE_PARAMS[@]}" \
        -C "$PKG_SOURCE_ROOT" "${ITEMS_TO_ARCHIVE[@]}" \
        ${HOME_ITEMS[0]+-C "$HOME"} ${HOME_ITEMS[0]+"${HOME_ITEMS[@]}"} \
        -cf - | gzip -n > "$TAR_PARTIAL"; then
    fatal "Failed to create archive." 2
fi

# 3. Compute SHA1
NEW_SHA1=$(sha1sum "$TAR_PARTIAL" | awk '{print $1}') \
    || fatal "Failed to digest the archive candidate." 2
info "Computed SHA1: $NEW_SHA1"

# 4. Find the most recent SHA1 file
# We look for files named ${TARGET_FOLDER}.*.sha1 and keep the newest by mtime.
LAST_SHA_FILE=
for SHA_FILE in "$PKG_DIR"/"$TARGET_FOLDER".*.sha1; do
    [ -e "$SHA_FILE" ] || continue

    if [ -z "$LAST_SHA_FILE" ] || [ "$SHA_FILE" -nt "$LAST_SHA_FILE" ]; then
        LAST_SHA_FILE="$SHA_FILE"
    fi
done

IS_DUPLICATE=0

if [ -f "$LAST_SHA_FILE" ]; then
    OLD_SHA1=$(cat "$LAST_SHA_FILE")

    # Compare the hashes
    if [ "$NEW_SHA1" == "$OLD_SHA1" ]; then
        IS_DUPLICATE=1
    fi
fi

# 5. Final Logic
if [ "$IS_DUPLICATE" -eq 1 ]; then
    # -- DUPLICATE DETECTED --
    # 1. EXIT removes the private duplicate, preserving the existing archive.

    # 2. Print the filename of the *previous* archive
    EXISTING_TAR="${LAST_SHA_FILE%.sha1}.tar.gz"
    warning "Duplicate detected. Using existing archive: $EXISTING_TAR"
    echo "$EXISTING_TAR"

else
    # -- NEW CONTENT DETECTED --
    # Atomically claim an unused final name without replacing another run's
    # archive. Both names are on the same filesystem; EXIT unlinks the temporary
    # name. A timestamp collision fails with existing archives/latest intact.
    if ! ln -T -- "$TAR_PARTIAL" "$TAR_PATH"; then
        fatal "Archive name already exists or cannot be created: $TAR_PATH; retry with a new timestamp." 2
    fi
    # 1. Save the new SHA1 to a file
    echo "$NEW_SHA1" > "$SHA_PATH"

    # 2. Create/Update 'latest' symlink
    LATEST_LINK="${PKG_DIR}/${TARGET_FOLDER}.latest.tar.gz"
    task "Updating symlink: $LATEST_LINK -> $TAR_NAME"
    ln -sf "$TAR_NAME" "$LATEST_LINK"

    # 3. Print the filename of the *new* archive
    ok "New content detected. Created archive: $TAR_PATH"
    echo "$TAR_PATH"
fi
