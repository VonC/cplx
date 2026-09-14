#!/bin/bash
# Read-only curated metadata resolution. Callers supply named Bash arrays:
# select REQUEST KIND KEYS SOURCES RESULT DIAGNOSTICS
# list ROOT TOOL REQUEST RESULT DIAGNOSTICS
# mirror ACTIVE_PROPERTIES REQUEST RESULT DIAGNOSTICS URLS
# RESULT is associative; other arrays are indexed. Names beginning _pm_ are
# reserved for implementation locals. No source-time IO or consumer setup runs.
# Nameref outputs/inventories are used indirectly by the calling functions.
# shellcheck disable=SC2034

package_metadata_number() {
    local -n _pm_number_output=$2
    _pm_number_output=${1#"${1%%[!0]*}"}
    _pm_number_output=${_pm_number_output:-0}
}

package_metadata_parse() {
    local -n _pm_parse_output=$2
    _pm_parse_output=()
    [[ $1 =~ ^([^_]+)_([0-9]+)\.([0-9]+)_(.+)$ ]] || return 1
    _pm_parse_output=("${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}")
    package_metadata_number "${_pm_parse_output[1]}" '_pm_parse_output[1]'
    package_metadata_number "${_pm_parse_output[2]}" '_pm_parse_output[2]'
}

# Compare normalized decimal integers without octal interpretation or overflow.
package_metadata_compare() {
    local LC_ALL=C
    local -n _pm_compare_output=$3
    _pm_compare_output=0
    if (( ${#1} < ${#2} )) || { (( ${#1} == ${#2} )) && [[ $1 < $2 ]]; }; then
        _pm_compare_output=-1
    elif [[ $1 != "$2" ]]; then
        _pm_compare_output=1
    fi
}

package_metadata_select() {
    local _pm_request=$1 _pm_kind=$2 LC_ALL=C
    local -n _pm_keys=$3 _pm_sources=$4 _pm_result=$5 _pm_diagnostics=$6
    local -a _pm_requested_parts=() _pm_candidate_parts=()
    local _pm_i _pm_reason _pm_relation _pm_compare
    local _pm_lower=-1 _pm_higher=-1 _pm_chosen=-1 _pm_lower_minor=0 _pm_higher_minor=0
    _pm_result=([requested_key]="$_pm_request" [kind]="$_pm_kind")
    _pm_diagnostics=()
    # Exact identity precedes parsing, including legacy major-only names.
    for _pm_i in "${!_pm_keys[@]}"; do
        if [[ ${_pm_keys[_pm_i]} == "$_pm_request" ]]; then
            _pm_result['selected_key']=$_pm_request
            _pm_result['source']=${_pm_sources[_pm_i]}
            _pm_result['fallback']=false
            return 0
        fi
    done
    if ! package_metadata_parse "$_pm_request" _pm_requested_parts; then
        _pm_diagnostics+=("$_pm_kind $_pm_request: fallback requires numeric major.minor; considered: ${_pm_sources[*]}")
        return 1
    fi
    for _pm_i in "${!_pm_keys[@]}"; do
        _pm_reason=''
        if ! package_metadata_parse "${_pm_keys[_pm_i]}" _pm_candidate_parts; then
            _pm_reason='excluded: requires numeric major.minor'
        elif [[ ${_pm_candidate_parts[0]} != "${_pm_requested_parts[0]}" ]]; then
            _pm_reason='excluded: different distribution'
        elif [[ ${_pm_candidate_parts[1]} != "${_pm_requested_parts[1]}" ]]; then
            _pm_reason='excluded: different major'
        elif [[ ${_pm_candidate_parts[3]} != "${_pm_requested_parts[3]}" ]]; then
            _pm_reason='excluded: different whole machine'
        else
            package_metadata_compare "${_pm_candidate_parts[2]}" "${_pm_requested_parts[2]}" _pm_relation
            if (( _pm_relation == 0 )); then
                _pm_reason='excluded: equal numeric minor'
            elif (( _pm_relation < 0 )); then
                _pm_reason='eligible lower minor'
                package_metadata_compare "${_pm_candidate_parts[2]}" "$_pm_lower_minor" _pm_compare
                if (( _pm_lower < 0 || _pm_compare > 0 )) ||
                    { (( _pm_compare == 0 )) && [[ ${_pm_keys[_pm_i]} < ${_pm_keys[_pm_lower]} ]]; }; then
                    _pm_lower=$_pm_i
                    _pm_lower_minor=${_pm_candidate_parts[2]}
                fi
            else
                _pm_reason='eligible higher minor'
                package_metadata_compare "${_pm_candidate_parts[2]}" "$_pm_higher_minor" _pm_compare
                if (( _pm_higher < 0 || _pm_compare < 0 )) ||
                    { (( _pm_compare == 0 )) && [[ ${_pm_keys[_pm_i]} < ${_pm_keys[_pm_higher]} ]]; }; then
                    _pm_higher=$_pm_i
                    _pm_higher_minor=${_pm_candidate_parts[2]}
                fi
            fi
        fi
        _pm_diagnostics+=("${_pm_sources[_pm_i]} (${_pm_keys[_pm_i]}): $_pm_reason")
    done
    if (( _pm_lower >= 0 )); then _pm_chosen=$_pm_lower; else _pm_chosen=$_pm_higher; fi
    if (( _pm_chosen < 0 )); then
        _pm_diagnostics+=("$_pm_kind $_pm_request: no eligible source within distribution=${_pm_requested_parts[0]} major=${_pm_requested_parts[1]} machine=${_pm_requested_parts[3]}")
        return 1
    fi
    # Numeric ties use literal identity in C order, independent of inventory order.
    _pm_result['selected_key']=${_pm_keys[_pm_chosen]}
    _pm_result['source']=${_pm_sources[_pm_chosen]}
    _pm_result['fallback']=true
}

# Single injectable read boundary: failed reads never become missing candidates.
package_metadata_read() {
    local -n _pm_read_output=$2
    _pm_read_output=''
    [[ -f $1 && -r $1 ]] || return 1
    _pm_read_output=$(cat -- "$1")
}

package_metadata_report() {
    local -n _pm_report_result=$1
    if [[ ${_pm_report_result[fallback]} == true ]]; then
        printf 'Package metadata %s: %s -> %s\n' "${_pm_report_result[kind]}" \
            "${_pm_report_result[requested_key]}" "${_pm_report_result[source]}" >&2
    fi
}

package_metadata_list() {
    local _pm_root=$1 _pm_tool=$2 _pm_list_request=$3
    local -n _pm_list_result=$4 _pm_list_diagnostics=$5
    local -a _pm_list_keys=() _pm_list_sources=()
    local _pm_path _pm_name _pm_contents
    _pm_path="$_pm_root/$_pm_tool/${_pm_tool}_${_pm_list_request}.txt"
    if [[ -e $_pm_path || -L $_pm_path ]]; then
        _pm_list_keys=("$_pm_list_request")
        _pm_list_sources=("$_pm_path")
    else
        # Exactly one relevant-directory inventory; indexes cannot match.
        for _pm_path in "$_pm_root/$_pm_tool/${_pm_tool}_"*.txt; do
            [[ -e $_pm_path || -L $_pm_path ]] || continue
            _pm_name=${_pm_path##*/}
            _pm_name=${_pm_name#"${_pm_tool}_"}
            _pm_list_keys+=("${_pm_name%.txt}")
            _pm_list_sources+=("$_pm_path")
        done
    fi
    package_metadata_select "$_pm_list_request" list _pm_list_keys _pm_list_sources "$4" "$5" || return 1
    if ! package_metadata_read "${_pm_list_result[source]}" _pm_contents; then
        _pm_list_diagnostics+=("list $_pm_list_request: cannot read present source ${_pm_list_result[source]}")
        _pm_list_result=([requested_key]="$_pm_list_request" [kind]=list)
        return 1
    fi
    package_metadata_report "$4"
}

package_metadata_trim() {
    local -n _pm_trim_output=$2
    _pm_trim_output=${1#"${1%%[![:space:]]*}"}
    _pm_trim_output=${_pm_trim_output%"${_pm_trim_output##*[![:space:]]}"}
}

package_metadata_mirror() {
    local _pm_file=$1 _pm_mirror_request=$2
    local -n _pm_mirror_result=$3 _pm_mirror_diagnostics=$4 _pm_urls=$5
    local -A _pm_values=()
    local -a _pm_mirror_keys=() _pm_mirror_sources=() _pm_absent=()
    local _pm_text _pm_line _pm_property _pm_value _pm_arch
    _pm_urls=()
    _pm_mirror_result=([requested_key]="$_pm_mirror_request" [kind]=mirror)
    _pm_mirror_diagnostics=()
    if ! package_metadata_read "$_pm_file" _pm_text; then
        _pm_mirror_diagnostics+=("mirror $_pm_mirror_request: cannot read active properties $_pm_file")
        return 1
    fi
    while IFS= read -r _pm_line; do
        [[ $_pm_line == *=* ]] || continue
        package_metadata_trim "${_pm_line%%=*}" _pm_property
        [[ $_pm_property =~ ^[a-zA-Z0-9_.-]+_pkgs_url$ ]] || continue
        _pm_arch=${_pm_property%_pkgs_url}
        # Keep the existing reader's addressing: it replaces the request's first
        # dot, so a dotted spelling is never a definition. Only the numeric
        # version boundary of other names changes; x86_64 stays whole.
        if [[ $_pm_arch == "${_pm_mirror_request/./_}" ]]; then
            _pm_arch=$_pm_mirror_request
        elif [[ $_pm_arch =~ ^([^_]+)_([0-9]+)_([0-9]+)_(.+)$ ]]; then
            _pm_arch="${BASH_REMATCH[1]}_${BASH_REMATCH[2]}.${BASH_REMATCH[3]}_${BASH_REMATCH[4]}"
        elif [[ $_pm_arch == *.* ]]; then
            continue
        fi
        [[ ${_pm_values[$_pm_property]+present} ]] && continue
        package_metadata_trim "${_pm_line#*=}" _pm_value
        _pm_values[$_pm_property]=$_pm_value
        if [[ -z $_pm_value ]]; then
            _pm_absent+=("$_pm_property: absent: first trimmed value is empty")
            continue
        fi
        _pm_mirror_keys+=("$_pm_arch")
        _pm_mirror_sources+=("$_pm_property")
    done <<< "$_pm_text"
    if ! package_metadata_select "$_pm_mirror_request" mirror _pm_mirror_keys _pm_mirror_sources "$3" "$4"; then
        _pm_mirror_diagnostics+=("${_pm_absent[@]}")
        return 1
    fi
    _pm_mirror_diagnostics+=("${_pm_absent[@]}")
    _pm_mirror_result['value']=${_pm_values[${_pm_mirror_result[source]}]}
    IFS=, read -r -a _pm_urls <<< "${_pm_mirror_result[value]}"
    package_metadata_report "$3"
}
