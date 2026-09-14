#!/bin/bash
# Exact-index IO: assemble in owned siblings, check every required command,
# then replace the detected-key file. Sourcing performs no work. Callers own
# mirror selection, invocation refresh state and completion reporting.
# Names beginning _pi_ are reserved for implementation locals.

package_index_available() {
    [[ -f $1 && -s $1 ]] && { [[ $2 == 1 ]] || [[ -z $3 && -z $4 ]]; }
}

# Preserve the existing last-entry-per-prefix aggregation and sorted output.
package_index_aggregate() {
    awk -F'-[0-9]' '{
        if ($0 !~ /^\//) {  # Ignore entries starting with /
            prefix = $1;     # Extract the common prefix (everything before -[0-9])
            map[prefix] = $0;  # Store the latest entry for each prefix
        }
    }
    END {
        # Sort the prefixes alphabetically
        n = asorti(map, sorted_prefixes);
        for (i = 1; i <= n; i++) {
            print map[sorted_prefixes[i]];  # Print the latest entry for each prefix
        }
    }' "$@"
}

package_index_extract() {
    local -a _pi_codes=()
    local _pi_code _pi_no_match=0
    # Capture all component statuses: pipefail alone can hide an early error
    # behind a later grep's ordinary no-match status.
    eval "$1"'; _pi_codes=("${PIPESTATUS[@]}")'
    for _pi_code in "${_pi_codes[@]}"; do
        (( _pi_code <= 1 )) || return 2
        (( _pi_code == 0 )) || _pi_no_match=1
    done
    return "$_pi_no_match"
}

package_index_listing() (
    # pipefail is local to this process; command failures cannot masquerade as
    # a valid extraction merely because the final filter succeeded.
    set -o pipefail
    local _pi_url=$1 _pi_output=$2 _pi_raw=$3 _pi_html _pi_lines _pi_text _pi_pipeline _pi_status
    if ! _pi_html=$(curl -kLs "$_pi_url"); then
        printf 'Failed to fetch package listing: %s\n' "$_pi_url" >&2
        return 113
    fi
    _pi_lines=$(printf '%s\n' "$_pi_html" | wc -l) || return 111
    if (( _pi_lines < 50 )); then
        printf 'HTML content has only %s lines (<50): %s\n' "$_pi_lines" "$_pi_url" >&2
        return 113
    fi
    # Try the established extraction forms in order, keeping the first match.
    local -a _pi_pipelines=(
        'grep -oP '\''<tr class="(even|odd)">.*?<a href="\K[^"]+'\'' | grep -v "^\.\./$" | grep -E "(x86_64|noarch)"'
        'grep -oP '\''<a href="\K[^"]*(x86_64|noarch)[^"]*'\'' | grep -v "^../$"'
        'grep -oP '\''<a href="\K[^"]+'\'' | grep -E "(x86_64|noarch)"'
        # Single-quoted hrefs are needed for vault listings that carry packages
        # absent from the double-quoted mirrors. \x27 keeps the quote outside
        # shell quoting while preserving the established alternate extraction.
        'grep -oP '\''<a href=\x27\K[^\x27]+'\'' | grep -E "(x86_64|noarch)"'
    )
    _pi_text=''
    for _pi_pipeline in "${_pi_pipelines[@]}"; do
        # Only these fixed pipeline strings are evaluated, never listing text.
        if _pi_text=$(printf '%s\n' "$_pi_html" | package_index_extract "$_pi_pipeline"); then
            [[ -z $_pi_text ]] || break
        else
            _pi_status=$?
            if (( _pi_status > 1 )); then
                printf 'Failed to extract package listing: %s\n' "$_pi_url" >&2
                return 111
            fi
        fi
    done
    if [[ -z $_pi_text ]]; then
        printf 'Warning: No package URLs extracted from listing: %s; skipping\n' "$_pi_url" >&2
        return 0
    fi
    if ! printf '%s\n' "$_pi_text" > "$_pi_raw"; then
        printf 'Cannot write extracted listing: %s\n' "$_pi_raw" >&2
        return 115
    fi
    if ! package_index_aggregate "$_pi_raw" > "$_pi_output"; then
        printf 'Failed to aggregate package listing: %s\n' "$_pi_url" >&2
        return 111
    fi
)

package_index_write_candidate() {
    local _pi_destination=$1
    shift
    package_index_aggregate "$@" > "$_pi_destination"
}

package_index_generate() (
    local _pi_index=$1 _pi_arch=$2 _pi_parent _pi_scratch='' _pi_candidate=''
    local -n _pi_urls=$3
    local -a _pi_results=()
    local _pi_i _pi_url _pi_status
    _pi_parent=${_pi_index%/*}
    # mktemp creates only paths under this already-existing package directory.
    # The EXIT handler owns exactly those returned paths, including on failure.
    # Invoked by the EXIT trap in this generation subshell.
    # shellcheck disable=SC2317
    package_index_cleanup() {
        if [[ -n $_pi_candidate && $_pi_candidate == "$_pi_parent/.cplx-index-"*.tmp ]]; then
            rm -f -- "$_pi_candidate"
        fi
        if [[ -n $_pi_scratch && $_pi_scratch == "$_pi_parent/.cplx-index-"* ]]; then
            rm -rf -- "$_pi_scratch"
        fi
    }
    trap package_index_cleanup EXIT
    if ! _pi_scratch=$(mktemp -d "$_pi_parent/.cplx-index-${_pi_arch}.XXXXXXXX"); then
        printf 'Cannot create index scratch for %s\n' "$_pi_index" >&2
        return 115
    fi
    if ! _pi_candidate=$(mktemp "$_pi_parent/.cplx-index-${_pi_arch}.XXXXXXXX.tmp"); then
        printf 'Cannot create index candidate for %s\n' "$_pi_index" >&2
        return 115
    fi
    for _pi_i in "${!_pi_urls[@]}"; do
        _pi_url=${_pi_urls[_pi_i]}
        if package_index_listing "$_pi_url" "$_pi_scratch/url_${_pi_i}.txt" "$_pi_scratch/raw_${_pi_i}"; then
            if [[ -f $_pi_scratch/url_${_pi_i}.txt ]]; then
                _pi_results+=("$_pi_scratch/url_${_pi_i}.txt")
            fi
        else
            _pi_status=$?
            return "$_pi_status"
        fi
    done
    if (( ${#_pi_results[@]} == 0 )); then
        printf 'No package listings for %s\n' "$_pi_index" >&2
        return 112
    fi
    if ! package_index_write_candidate "$_pi_candidate" "${_pi_results[@]}"; then
        printf 'Failed to assemble package index: %s\n' "$_pi_index" >&2
        return 111
    fi
    if [[ ! -s $_pi_candidate ]]; then
        printf 'No packages were found for index: %s\n' "$_pi_index" >&2
        return 112
    fi
    if [[ -d $_pi_index ]] || ! mv -fT -- "$_pi_candidate" "$_pi_index"; then
        printf 'Failed to publish package index: %s\n' "$_pi_index" >&2
        return 115
    fi
)
