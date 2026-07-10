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
PKG_USAGE="Usage: $0 <folder_name> [--add <item>]... [-- <tar args...>]"
TARGET_FOLDER=""
EXTRA_ITEMS=()
EXTRA_TAR_PARAMS=()
while [ "$#" -gt 0 ]; do
    case "$1" in
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

# If TARGET_FOLDER is "tools", also ship the home-level env files when
# they exist, so the target account gets a working session after install.
# Application-specific target rules (extra exclusions, extra files) belong
# to the consuming project's own packaging, not here.
if [ "$TARGET_FOLDER" == "tools" ]; then
    for extra_env_file in .env .env_; do
        if [ -e "$HOME/$extra_env_file" ]; then
            task "Target is 'tools', adding $extra_env_file to archive list"
            ITEMS_TO_ARCHIVE+=("$extra_env_file")
        fi
    done
fi

# Apply the caller's extension arguments: extra items first, then the
# verbatim tar rules (appended after the default exclusions, so the
# caller's --no-wildcards-match-slash toggles keep their relative order).
for extra_item in "${EXTRA_ITEMS[@]}"; do
    task "Adding requested extra item to archive list: $extra_item"
    ITEMS_TO_ARCHIVE+=("$extra_item")
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
task "Creating candidate archive..."
if ! tar --sort=name "${EXCLUDE_PARAMS[@]}" -C "$HOME" -cf - "${ITEMS_TO_ARCHIVE[@]}" | gzip -n > "$TAR_PATH"; then
    fatal "Failed to create archive." 2
fi

# 3. Compute SHA1
NEW_SHA1=$(sha1sum "$TAR_PATH" | awk '{print $1}')
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
    # 1. Delete the new, redundant tarball
    rm "$TAR_PATH"

    # 2. Print the filename of the *previous* archive
    EXISTING_TAR="${LAST_SHA_FILE%.sha1}.tar.gz"
    warning "Duplicate detected. Using existing archive: $EXISTING_TAR"
    echo "$EXISTING_TAR"

else
    # -- NEW CONTENT DETECTED --
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
