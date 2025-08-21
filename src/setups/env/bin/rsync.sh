#!/bin/bash

# Initialize flags
DRY_RUN=false
DEBUG=false

# Process all command line arguments
for arg in "$@"; do
    case $arg in
        --dry-run|-n)
            DRY_RUN=true
            ;;
        --debug|-d)
            DEBUG=true
            ;;
        *)
            echo -e "\xE2\x9D\x8C Error: Unknown parameter '$arg'"
            echo "Usage: $0 [--dry-run|-n] [--debug|-d]"
            exit 1
            ;;
    esac
done

# Show status of modes if enabled
if [ "$DRY_RUN" = true ]; then
    echo -e "\xF0\x9F\x94\x8D Running in DRY-RUN mode - no files will be changed"
fi

if [ "$DEBUG" = true ]; then
    echo -e "\xF0\x9F\x90\x9B Running in DEBUG mode - additional information will be shown"
fi

# Function to determine current version from a symlink
get_current_version() {
    local dir="$1"
    local link_name="$2"
    
    if [ -L "${dir}/${link_name}" ]; then
        local current
        current=$(readlink "${dir}/${link_name}")
        # Extract just the directory name
        basename "${current}"
    else
        echo ""
    fi
}

# Function to delete version directories, keeping only the current one
delete_version_dirs() {
    local base_dir="$1"
    local prefix="$2"
    local current_version="$3"
    local dry_run="$4"
    
    echo -e "\xF0\x9F\x97\x91 Handling ${prefix}* directories..."
    
    if [ -z "$current_version" ]; then
        echo -e "\xE2\x9A\xA0 Warning: No current version found for ${prefix}, skipping deletion"
        return
    fi
    
    # Check if base directory exists
    if [ ! -d "$base_dir" ]; then
        echo -e "\xE2\x9A\xA0 Warning: Directory $base_dir does not exist, skipping"
        return
    fi
    
    # Use nullglob to handle case when no matches are found
    shopt -s nullglob
    local dirs=("${base_dir}/${prefix}"*)
    shopt -u nullglob
    
    # Check if any directories were found
    if [ ${#dirs[@]} -eq 0 ]; then
        echo -e "\xE2\x9A\xA0 No ${prefix}* directories found in $base_dir"
        return
    fi
    
    for dir in "${dirs[@]}"; do
        if [ "$DEBUG" = true ]; then
          echo -e "\xF0\x9F\x97\x91 Considering folder '${dir}'" 
        fi
        if [ -d "$dir" ]; then
            base_dir_name=$(basename "$dir")
            if [ "${base_dir_name}" != "${current_version}" ]; then
                if [ "$dry_run" = true ]; then
                    echo -e "\xF0\x9F\x97\x91 Would delete: $dir"
                else
                    echo -e "\xF0\x9F\x97\x91 Deleting: $dir"
                    rm -rf "$dir"
                fi
            fi
        fi
    done
}

# Determine current versions
GIT_DIR="${HOME}/cplx/tools/git"
PYTHON_DIR="${HOME}/cplx/tools/python"

CURRENT_GIT=$(get_current_version "$GIT_DIR" "current")
CURRENT_PYTHON=$(get_current_version "$PYTHON_DIR" "current")

if [ -n "$CURRENT_GIT" ]; then
    echo -e "\xE2\x9C\x93 Current git version is: ${CURRENT_GIT}"
else
    echo -e "\xE2\x9A\xA0 Warning: git 'current' symlink not found"
    exit 1
fi

if [ -n "$CURRENT_PYTHON" ]; then
    echo -e "\xE2\x9C\x93 Current python version is: ${CURRENT_PYTHON}"
else
    echo -e "\xE2\x9A\xA0 Warning: python 'current' symlink not found"
    exit 1
fi

# Path to temporary exclude file
TMP_EXCLUDE="${HOME}/cplx/rsync_exclude.tmp"

# Create a temporary exclude file without the git-.*/ and python-.*/ lines
grep -v -E 'git-.*\/|python-.*\/' "${HOME}/cplx/rsync_exclude.txt" > "$TMP_EXCLUDE"

# Add specific exclusions for all git-2.* directories except the one pointed to by 'current'
for dir in "${HOME}"/cplx/tools/git/git-*; do
    if [ -d "$dir" ]; then
        base_dir=$(basename "$dir")
        if [ "${base_dir}" != "${CURRENT_GIT}" ]; then
            echo "${base_dir}/" >> "$TMP_EXCLUDE"
        fi
    fi
done

# Add specific exclusions for all python-* directories except the one pointed to by 'current'
for dir in "${HOME}"/cplx/tools/python/python-*; do
    if [ -d "$dir" ]; then
        base_dir=$(basename "$dir")
        if [ "${base_dir}" != "${CURRENT_PYTHON}" ]; then
            echo "${base_dir}/" >> "$TMP_EXCLUDE"
        fi
    fi
done

# Debug: Display temporary exclude file and diff
if [ "$DEBUG" = true ]; then
    echo -e "\xF0\x9F\x93\x84 Content of temporary exclude file:"
    echo "--------------------------------"
    cat "$TMP_EXCLUDE"
    echo "--------------------------------"
    
    echo -e "\xF0\x9F\x94\x8E Diff between original and temporary exclude files:"
    echo "--------------------------------"
    diff -u "${HOME}/cplx/rsync_exclude.txt" "$TMP_EXCLUDE" || true
    echo "--------------------------------"
fi

# Set up rsync options
RSYNC_OPTS="-arvR --delete --files-from=\"${HOME}/cplx/rsync_include.txt\" --exclude-from=\"$TMP_EXCLUDE\" \"${HOME}/\" \"${HOME}/tools/\""

# Add dry-run option if requested
if [ "$DRY_RUN" = true ]; then
    RSYNC_OPTS="-n $RSYNC_OPTS"
    echo -e "\xE2\x84\xB9 Dry run - showing what would be transferred:"
fi

# Run rsync with the constructed options
if [ "$DEBUG" = true ]; then
    echo -e "\xF0\x9F\x9A\x80 Executing command: rsync $RSYNC_OPTS"
fi
eval rsync "${RSYNC_OPTS}"

# Handle deletions of specific version directories
delete_version_dirs "${HOME}/tools/git" "git-" "$CURRENT_GIT" "$DRY_RUN"
delete_version_dirs "${HOME}/tools/python" "python-" "$CURRENT_PYTHON" "$DRY_RUN"

# Clean up (only if not in debug mode)
if [ "$DEBUG" = false ]; then
    rm "$TMP_EXCLUDE"
else
    echo -e "\xF0\x9F\x93\x8C Keeping temporary file: $TMP_EXCLUDE"
fi
