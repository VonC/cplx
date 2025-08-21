#!/bin/bash

# A script to find and compare corresponding files between two directories.
#
# Usage: ./compare_files.sh <pattern>
# Example (wildcard name):  ./compare_files.sh gpg-res
# Example (exact name):     ./compare_files.sh gpg-restart$
# Example (wildcard path):  ./compare_files.sh certs/gpg-res
# Example (exact path):     ./compare_files.sh certs/gpg-restart$

# --- Script Configuration ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipelines return the exit status of the last command to exit with a non-zero status.
set -o pipefail

# --- Define Base Directories ---
# Define the directories to operate on. Using $HOME ensures it's user-specific.
TOOLS_DIR="$HOME/tools"
CPLX_DIR="$HOME/cplx"

# --- Input Validation ---
# Check if exactly one argument is provided.
if [[ $# -ne 1 ]]; then
    echo "Error: Invalid number of arguments." >&2
    echo "Usage: $0 <pattern>" >&2
    exit 1
fi

SEARCH_PATTERN="$1"
FIND_PREDICATE="" # Will be -name or -path
FIND_ARG=""
SEARCH_DISPLAY_TEXT=""
IS_EXACT_MATCH=false

# --- Determine search type (name vs. path, wildcard vs. exact) ---

# First, check if the user wants an exact match by looking for a '$' suffix.
if [[ "$SEARCH_PATTERN" == *\$ ]]; then
    IS_EXACT_MATCH=true
    SEARCH_PATTERN="${SEARCH_PATTERN%\$}" # Remove the trailing '$' for the actual search
fi

# Next, determine if the pattern is a path (contains '/') or a simple name.
if [[ "$SEARCH_PATTERN" == */* ]]; then
    # It's a path pattern. The search will be relative to TOOLS_DIR.
    FIND_PREDICATE="-path"
    if [[ "$IS_EXACT_MATCH" == true ]]; then
        FIND_ARG="*/$SEARCH_PATTERN"
        SEARCH_DISPLAY_TEXT="exact path ending in '$SEARCH_PATTERN'"
    else
        FIND_ARG="*/${SEARCH_PATTERN}*"
        SEARCH_DISPLAY_TEXT="path pattern '*${SEARCH_PATTERN}*'"
    fi
else
    # It's a simple name pattern.
    FIND_PREDICATE="-name"
    if [[ "$IS_EXACT_MATCH" == true ]]; then
        FIND_ARG="$SEARCH_PATTERN"
        SEARCH_DISPLAY_TEXT="exact filename '$SEARCH_PATTERN'"
    else
        FIND_ARG="${SEARCH_PATTERN}*"
        SEARCH_DISPLAY_TEXT="filename pattern '${SEARCH_PATTERN}*'"
    fi
fi

echo -e "\xF0\x9F\x94\x8D Searching for $SEARCH_DISPLAY_TEXT..."
echo

# --- Step 1: Find the file in the 'tools' directory ---
echo "--- Searching in '$TOOLS_DIR' ---"

# Use 'find' with the dynamically determined predicate (-name or -path) and argument.
mapfile -t tool_files < <(find "$TOOLS_DIR" -type f "$FIND_PREDICATE" "$FIND_ARG")

# Get the number of elements in the array.
tool_file_count=${#tool_files[@]}

if [[ $tool_file_count -eq 0 ]]; then
    echo -e "\xE2\x9D\x8C Error: No file matching $SEARCH_DISPLAY_TEXT found in '$TOOLS_DIR'." >&2
    exit 1
elif [[ $tool_file_count -gt 1 ]]; then
    echo -e "\xE2\x9D\x8C Error: Multiple files matching $SEARCH_DISPLAY_TEXT found in '$TOOLS_DIR'. Please be more specific." >&2
    printf "   Found: %s\n" "${tool_files[@]}" >&2
    exit 1
fi

# If we reach here, exactly one file was found.
tool_file="${tool_files[0]}"
echo -e "\xE2\x9C\x85 Found one match: $tool_file"
echo

# --- Step 2: Determine the relative path ---
# Use shell parameter expansion to remove the TOOLS_DIR prefix, leaving the relative path.
relative_path="${tool_file#"${TOOLS_DIR}"/}"
echo "   Determined relative path: '$relative_path'"
echo

# --- Step 3: Find the corresponding file in the 'cplx' directory ---
echo "--- Searching for '$relative_path' in '$CPLX_DIR' ---"

# Search for a file that has the exact same relative path structure under the CPLX_DIR.
mapfile -t cplx_files < <(find "$CPLX_DIR" -type f -path "*/$relative_path")

cplx_file_count=${#cplx_files[@]}

if [[ $cplx_file_count -eq 0 ]]; then
    echo -e "\xE2\x9D\x8C Error: No file with the relative path '$relative_path' was found in '$CPLX_DIR'." >&2
    exit 1
elif [[ $cplx_file_count -gt 1 ]]; then
    echo -e "\xE2\x9D\x8C Error: Multiple files with the relative path '$relative_path' were found in '$CPLX_DIR'." >&2
    printf "   Found: %s\n" "${cplx_files[@]}" >&2
    exit 1
fi

# If we reach here, exactly one corresponding file was found.
cplx_file="${cplx_files[0]}"
echo -e "\xE2\x9C\x85 Found one match: $cplx_file"
echo

# --- Step 4: List details and perform the diff ---
echo "--- Comparing the two files ---"
echo

echo "Running: ls -alrth '$tool_file' '$cplx_file'"
ls -alrth "$tool_file" "$cplx_file"
echo
echo "--------------------------------------------------"

echo "Running: git diff -w --no-index --color-words=. '$tool_file' '$cplx_file'"
# git diff exits with 1 if differences are found. With 'set -e', this would stop the script.
# We run it in a subshell and use '|| true' to ensure the script continues regardless of the outcome.
(git diff -w --no-index --color-words=. "$tool_file" "$cplx_file") || true

echo
echo -e "\xE2\x9C\x85 Comparison complete."
