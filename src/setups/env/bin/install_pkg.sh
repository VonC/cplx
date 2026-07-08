#!/bin/bash

# Canonical cplx copy of the relocating installer: unpacks the latest
# <target>.*.tar.gz produced by pkg.sh into an installation prefix, then
# makes the tree self-contained there — symlink targets, text files, ELF
# interpreter (PT_INTERP) and rpath are re-anchored from the build
# account's /home/<user> to the prefix. Run it from any account: it only
# needs the archive, this script, and the patchelf shipped in the tools
# archive.
# my-project keeps a temporary application-specific variant
# (tools/install_pkg.sh) until it consumes this one: see my-project
# docs/pkg-tools-migration-to-cplx.md.

# echos sits next to this script (standalone copy next to the archives) or
# one level up (~/cplx/bin + ~/cplx/echos, ~/tools/bin + ~/tools/echos).
INSTALL_PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for install_pkg_echos in "${INSTALL_PKG_DIR}/echos" "${INSTALL_PKG_DIR}/../echos/echos"; do
    if [ -f "${install_pkg_echos}" ]; then
        # shellcheck disable=SC1090
        source "${install_pkg_echos}"
        break
    fi
done
if ! command -v task >/dev/null 2>&1; then
    task()    { echo " Task=>: [install_pkg.sh] $1"; }
    info()    { echo " Info  : [install_pkg.sh] $1"; }
    ok()      { echo " Ok    : [install_pkg.sh] $1"; }
    warning() { echo " Warn  : [install_pkg.sh] $1"; }
    error()   { echo " Error : [install_pkg.sh] $1" >&2; }
    fatal()   { echo " FATAL ${2} : [install_pkg.sh] $1" >&2; exit "${2}"; }
fi

# ================= CONFIGURATION =================
# Installation prefix: the directory holding 'tools', 'bin' and 'pkgs'.
# Defaults to $HOME (historical same-account layout). Pass -p/--prefix for a
# relocated install, e.g. --prefix /project/middleware1/refer/upipdfs
INSTALL_PREFIX="$HOME"
# Resolved after argument parsing: $INSTALL_PREFIX/pkgs
PKG_DIR=""
# sed-escaped copies of INSTALL_PREFIX, safe in replacement and pattern position
PREFIX_SED=""
PREFIX_SED_PAT=""
# =================================================

sed_escape_replacement() {
    printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

sed_escape_pattern() {
    printf '%s' "$1" | sed -e 's/[][\\.*^$|]/\\&/g'
}

install_bin_link() {
    local link_name="$1"
    local source_path="$2"
    local bin_dir="$INSTALL_PREFIX/bin"
    local link_path="$bin_dir/$link_name"

    if [ ! -e "$source_path" ]; then
        return 1
    fi

    if ! mkdir -p "$bin_dir"; then
        fatal "Error: Failed to create '$bin_dir'." 13
    fi

    task "Installing '$link_path' -> '$source_path'"
    if ! ln -sfn "$source_path" "$link_path"; then
        fatal "Error: Failed to create '$link_path'." 14
    fi
    return 0
}

install_bin_wrapper() {
    local wrapper_name="$1"
    local target_path="$2"
    local bin_dir="$INSTALL_PREFIX/bin"
    local wrapper_path="$bin_dir/$wrapper_name"

    if [ ! -f "$target_path" ]; then
        return 1
    fi

    if ! mkdir -p "$bin_dir"; then
        fatal "Error: Failed to create '$bin_dir'." 13
    fi

    task "Installing '$wrapper_path' wrapper for '$target_path'"
    if ! {
        printf '%s\n' '#!/bin/bash'
        printf 'exec bash %q "$@"\n' "$target_path"
    } > "$wrapper_path"; then
        fatal "Error: Failed to write '$wrapper_path'." 15
    fi
    if ! chmod +x "$wrapper_path"; then
        fatal "Error: Failed to make '$wrapper_path' executable." 16
    fi
    return 0
}

install_optional_bin_entries() {
    local installed=0

    install_bin_link "echos" "$INSTALL_PREFIX/tools/echos/echos" && installed=1
    install_bin_link "compare_file.sh" "$INSTALL_PREFIX/tools/bin/compare_file.sh" && installed=1
    install_bin_wrapper "pkg" "$INSTALL_PREFIX/tools/bin/pkg.sh" && installed=1
    install_bin_wrapper "install_pkg" "$INSTALL_PREFIX/tools/bin/install_pkg.sh" && installed=1

    if [ "$installed" -eq 1 ]; then
        ok "Convenience commands installed in '$INSTALL_PREFIX/bin'."
    else
        warning "No known convenience commands were available to install in '$INSTALL_PREFIX/bin'."
    fi
}

fix_home_symlink_targets() {
    local root_path="$1"
    local fixed=0
    local link_path
    local old_target
    local new_target

    if [ ! -d "$root_path" ]; then
        return 0
    fi

    # The /. suffix on the find root descends through a symlinked root
    # directory; symlinks inside the tree are still visited as links,
    # never followed (find default -P behavior).
    while IFS= read -r -d '' link_path; do
        old_target="$(readlink "$link_path")"
        # Already re-anchored (matters when the prefix itself is under /home)
        case "$old_target" in
            "$INSTALL_PREFIX"/*) continue ;;
        esac
        # The build tree lives under /home/<builder>/cplx/tools; the deployed
        # tree is <prefix>/tools. Map the build layout first, then any other
        # /home/<user> anchor to the installation prefix.
        new_target="$(printf '%s\n' "$old_target" | sed \
            -e "s|^/home/[^/]*/cplx/tools/|${PREFIX_SED}/tools/|" \
            -e "s|^/home/[^/]*/|${PREFIX_SED}/|")"

        if [ "$new_target" = "$old_target" ]; then
            continue
        fi

        task "Fixing symlink '$link_path' -> '$new_target'"
        if ! ln -sfn "$new_target" "$link_path"; then
            fatal "Error: Failed to rewrite symlink '$link_path'." 17
        fi
        fixed=$((fixed + 1))
    done < <(find "$root_path/." -type l -lname '/home/*' -print0 2>/dev/null)

    if [ "$fixed" -gt 0 ]; then
        ok "Fixed $fixed absolute home symlink target(s) under '$root_path'."
    fi
}

fix_text_paths() {
    local root_path="$1"

    if [ ! -e "$root_path" ]; then
        return 0
    fi

    task "Fixing hard-coded /home/<user> paths in text files under '$root_path'..."
    # -I skips binary files (ELF, .pyc, git objects); -r does not follow
    # symlinks, so sed -i never replaces a link with a regular file.
    # Every rule writes the \x01 placeholder instead of the literal prefix,
    # restored by the last rule only. This keeps the rules from re-matching
    # each other's output and keeps the pass idempotent even when the
    # prefix itself lives under /home.
    if ! grep -rlIZ --exclude-dir=__pycache__ -- "/home/[^/]*/" "$root_path" 2>/dev/null \
        | xargs -0 -r sed -i \
            -e "s|${PREFIX_SED_PAT}/|\x01|g" \
            -e "s|/home/[^/]*/cplx/tools/|\x01tools/|g" \
            -e "s|/home/[^/]*/|\x01|g" \
            -e "s|\x01|${PREFIX_SED}/|g"; then
        fatal "Error: Text path fix failed under '$root_path'" 12
    fi
    ok "Text paths fixed under '$root_path'."
}

clear_pycache() {
    local root_path="$1"

    if [ ! -d "$root_path" ]; then
        return 0
    fi

    task "Clearing __pycache__ directories under '$root_path'..."
    # Bytecode caches embed the build account's absolute paths; Python
    # regenerates them from the .py sources on first import, so removing
    # them is safe and only costs one slower first start.
    if ! find "$root_path/." -type d -name '__pycache__' -prune -exec rm -rf {} + 2>/dev/null; then
        warning "Some __pycache__ directories could not be removed under '$root_path'."
    fi
    ok "__pycache__ cleared (bytecode is regenerated on first import)."
}

find_patchelf() {
    local candidate
    for candidate in "$INSTALL_PREFIX/tools/bin/patchelf" "$HOME/tools/bin/patchelf"; do
        if [ -x "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    if command -v patchelf >/dev/null 2>&1; then
        command -v patchelf
        return 0
    fi
    return 1
}

find_dynamic_linker() {
    local candidate
    for candidate in \
        "$INSTALL_PREFIX/tools/python/root/lib64/ld-linux-x86-64.so.2" \
        "$INSTALL_PREFIX/tools/python/root/usr/lib64/ld-linux-x86-64.so.2"; do
        if [ -e "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    find -L "$INSTALL_PREFIX/tools" -name 'ld-linux-x86-64.so.2' 2>/dev/null | head -n 1
}

build_elf_rpath() {
    local dirs=()
    local tool_dir
    local ver_dir
    local sub

    # python first so its root libraries win over other tool roots
    for tool_dir in "$INSTALL_PREFIX/tools/python" "$INSTALL_PREFIX"/tools/*/; do
        tool_dir="${tool_dir%/}"
        [ -d "$tool_dir" ] || continue
        for sub in root/usr/lib64 root/usr/lib root/lib64 root/lib; do
            [ -d "$tool_dir/$sub" ] && dirs+=("$tool_dir/$sub")
        done
        for ver_dir in "$tool_dir"/*/; do
            ver_dir="${ver_dir%/}"
            for sub in lib lib64; do
                [ -d "$ver_dir/$sub" ] && dirs+=("$ver_dir/$sub")
            done
        done
    done

    # dedupe while preserving order
    local joined=""
    local dir
    for dir in "${dirs[@]}"; do
        case ":${joined}:" in
            *":${dir}:"*) ;;
            *) joined="${joined:+$joined:}$dir" ;;
        esac
    done
    printf '%s\n' "$joined"
}

fix_elf_paths() {
    local root_path="$1"

    if [ ! -d "$root_path" ]; then
        return 0
    fi

    local patchelf_bin
    if ! patchelf_bin=$(find_patchelf); then
        warning "patchelf not found (expected in '$INSTALL_PREFIX/tools/bin'): ELF interpreter/rpath fix skipped."
        warning "Binaries still referencing /home/<builder> will only run where that directory is readable."
        return 0
    fi

    local new_interp
    new_interp=$(find_dynamic_linker)
    if [ -z "$new_interp" ]; then
        warning "No ld-linux-x86-64.so.2 found under '$INSTALL_PREFIX/tools': ELF interpreters left unchanged."
    fi

    local new_rpath
    new_rpath=$(build_elf_rpath)
    if [ -z "$new_rpath" ]; then
        warning "No library directories found under '$INSTALL_PREFIX/tools': ELF rpaths left unchanged."
    fi

    task "Fixing ELF interpreter and rpath under '$root_path' (patchelf: $patchelf_bin)..."
    info "New interpreter: ${new_interp:-<unchanged>}"
    info "New rpath      : ${new_rpath:-<unchanged>}"

    local fixed=0
    local file_path
    local magic
    local old_value
    while IFS= read -r -d '' file_path; do
        magic=$(head -c 4 "$file_path" 2>/dev/null | od -An -tx1 | tr -d ' \n')
        [ "$magic" = "7f454c46" ] || continue

        # Only rewrite values still anchored in a /home/<user> directory, so
        # the pass is idempotent and system-linked binaries are left alone.
        if [ -n "$new_rpath" ]; then
            old_value=$("$patchelf_bin" --print-rpath "$file_path" 2>/dev/null) || old_value=""
            if [[ "$old_value" == */home/* ]]; then
                if "$patchelf_bin" --set-rpath "$new_rpath" "$file_path"; then
                    fixed=$((fixed + 1))
                else
                    warning "Unable to set rpath on '$file_path'"
                fi
            fi
        fi

        if [ -n "$new_interp" ]; then
            old_value=$("$patchelf_bin" --print-interpreter "$file_path" 2>/dev/null) || old_value=""
            if [[ "$old_value" == */home/* ]] && [ "$old_value" != "$new_interp" ]; then
                if "$patchelf_bin" --set-interpreter "$new_interp" "$file_path"; then
                    fixed=$((fixed + 1))
                else
                    warning "Unable to set interpreter on '$file_path'"
                fi
            fi
        fi
    done < <(find "$root_path/." \( -name '.git' -o -name '__pycache__' \) -prune -o -type f -size +4c -print0 2>/dev/null)

    ok "Fixed $fixed ELF interpreter/rpath value(s) under '$root_path'."
}

# --- 1. Argument Parsing ---
FORCE=0
TARGET=""

usage() {
    fatal "Usage: $0 <target-folder> [-f|--force] [-p|--prefix <dir>]" 1
}

# Parse args
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--force) FORCE=1 ;;
        -p|--prefix)
            if [ -z "$2" ]; then
                error "Error: --prefix requires a directory argument."
                usage
            fi
            INSTALL_PREFIX="$2"
            shift
            ;;
        -*) error "Unknown parameter: $1"; usage ;;
        *)
            if [ -n "$TARGET" ]; then
                error "Error: only one target folder can be given ('$TARGET' and '$1')."
                usage
            fi
            TARGET="$1"
            ;;
    esac
    shift
done

if [ -z "$TARGET" ]; then
    error "Error: Target folder is required (e.g. tools)."
    usage
fi

INSTALL_PREFIX="${INSTALL_PREFIX%/}"
if [ ! -d "$INSTALL_PREFIX" ] && ! mkdir -p "$INSTALL_PREFIX"; then
    fatal "Error: Installation prefix '$INSTALL_PREFIX' does not exist and cannot be created." 18
fi
PREFIX_SED=$(sed_escape_replacement "$INSTALL_PREFIX")
PREFIX_SED_PAT=$(sed_escape_pattern "$INSTALL_PREFIX")
PKG_DIR="$INSTALL_PREFIX/pkgs"
if ! mkdir -p "$PKG_DIR"; then
    fatal "Error: Failed to create '$PKG_DIR'." 19
fi
info "Installation prefix: $INSTALL_PREFIX"

# --- 2. Find the Most Recent Archive ---
# We look in the prefix, $HOME and both pkgs directories for files like
# target.*.tar.gz, and keep the newest by modification time.
task "Searching for latest $TARGET archive..."

LATEST_ARCHIVE=$(find "$INSTALL_PREFIX" "$PKG_DIR" "$HOME" "$HOME/pkgs" -maxdepth 1 -type f -name "${TARGET}.*.tar.gz" -printf '%T@ %p\n' 2>/dev/null | sort -unr | head -n 1 | cut -d' ' -f2-)

if [ -z "$LATEST_ARCHIVE" ]; then
    fatal "Error: No archive found for '$TARGET' in $INSTALL_PREFIX, $HOME or $PKG_DIR" 2
fi

info "Found: $LATEST_ARCHIVE"

# Extract the basename without extension (e.g., tools.2026-01-05_120000)
FILENAME=$(basename "$LATEST_ARCHIVE")
BASE_NAME="${FILENAME%%.tar.gz}"

# Define the "Done" flag file path
DONE_FLAG="$PKG_DIR/${BASE_NAME}.done"

# --- 3. Check if Already Installed ---
if [ -f "$DONE_FLAG" ] && [ "$FORCE" -eq 0 ]; then
    warning "Skipping: $BASE_NAME is already installed."
    info "Use -f or --force to reinstall."
    install_optional_bin_entries
    exit 0
fi

if [ "$FORCE" -eq 1 ] && [ -f "$DONE_FLAG" ]; then
    warning "Force mode enabled. Reinstalling..."
fi

# --- 4. Unzip to Staging Area ---
STAGING_DIR="$PKG_DIR/$BASE_NAME"

# Clean up any previous partial staging attempt
if [ -d "$STAGING_DIR" ]; then
    task "Cleaning old staging area..."
    if ! rm -rf "$STAGING_DIR"; then
        fatal "Error: Failed to clean old staging area." 10
    fi
fi

if ! mkdir -p "$STAGING_DIR"; then
    fatal "Error: Failed to create staging directory." 9
fi

task "Extracting to $STAGING_DIR..."
# -C extracts INTO the staging dir
if ! tar -xzf "$LATEST_ARCHIVE" -C "$STAGING_DIR"; then
    fatal "Error: Extraction failed." 3
fi

# --- 5. Rsync (Mirror Mode) ---
# The source is inside the staging dir (e.g., <prefix>/pkgs/tools.xxx/tools/)
SOURCE_PATH="$STAGING_DIR/$TARGET"
DEST_PATH="$INSTALL_PREFIX/$TARGET"

if [ ! -d "$SOURCE_PATH" ]; then
    fatal "Error: Expected folder '$TARGET' not found inside archive." 4
fi

task "Syncing to $DEST_PATH (Mirror Mode)..."
# -a: Archive mode (perms, times, etc.)
# -v: Verbose
# --delete: Delete files in DEST that are not in SOURCE
if ! rsync -av --delete "$SOURCE_PATH/" "$DEST_PATH/"; then
    fatal "Error: Rsync (main) failed." 5
fi
fix_home_symlink_targets "$DEST_PATH"

# --- 6. Sync distinct config files (.env, .env_) ---
# These files are extracted to the root of STAGING_DIR, outside the TARGET folder.

# Check for '.env' (tools target)
if [ -f "$STAGING_DIR/.env" ]; then
    task "Deploying '.env' to $INSTALL_PREFIX..."
    if ! rsync -av "$STAGING_DIR/.env" "$INSTALL_PREFIX/"; then
        fatal "Error: Rsync (.env) failed." 7
    fi
    fix_text_paths "$INSTALL_PREFIX/.env"
fi

# Check for '.env_' (tools target)
if [ -f "$STAGING_DIR/.env_" ]; then
    task "Deploying '.env_' to $INSTALL_PREFIX..."
    if ! rsync -av "$STAGING_DIR/.env_" "$INSTALL_PREFIX/"; then
        fatal "Error: Rsync (.env_) failed." 8
    fi
    fix_text_paths "$INSTALL_PREFIX/.env_"
fi

# --- 6b. Clear stale bytecode caches ---
# Old __pycache__ entries keep the build account's paths in their metadata
# and would show up in a /home/<builder> audit; Python rebuilds them.
clear_pycache "$DEST_PATH"

# --- 6c. Fix hardcoded paths in text files ---
# Replace /home/<any_user>/ anchors with the installation prefix in every
# text file of the deployed tree (pyvenv.cfg, pkgconfig *.pc, shebangs,
# activate scripts, run configs). Binary files are skipped by grep -I.
fix_text_paths "$DEST_PATH"

# --- 6d. Fix hardcoded paths in ELF binaries ---
# The cplx toolchain bakes the build account's dynamic linker (PT_INTERP)
# and library rpath into every binary; the kernel resolves PT_INTERP before
# any environment variable applies, so it must be rewritten on disk.
fix_elf_paths "$DEST_PATH"

# --- 6e. Install convenience commands in <prefix>/bin when their sources are present ---
install_optional_bin_entries

# --- 7. Finalize ---
ok "Installation successful."
touch "$DONE_FLAG"

# Optional: Clean up staging folder to save space (comment out if you want to keep it)
task "Cleaning up staging area '$STAGING_DIR'..."
if ! rm -rf "$STAGING_DIR"; then
    fatal "Error: Cleaning up staging area '$STAGING_DIR'" 11
fi
ok "Done."
