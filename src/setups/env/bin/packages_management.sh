#!/bin/bash

get_package_name() {
    local tool
    tool=$("current_tool")
    local file
    file="${1}"
    if [[ -z ${tool} ]]; then
        tool="${1}"
        file="${2}"
    fi

    if [[ -z ${tool} ]]; then
        fatal "No tool provided or extracted from cwd '${cwd}'" 2
    fi
    if [[ -z ${file} ]]; then
        fatal "No file provided to search into packages" 3
    fi
    task "Must look for file '${file}' in '${tool}' packages"

    local pkgs_dir
    pkgs_dir="${HOME}/tools/pkgs"
    local pkg
    for pkg in "${pkgs_dir}"/*; do
        if [[ "${pkg}" =~ \.rpm$ || "${pkg}" =~ \.tar\.gz$ || "${pkg}" =~ \.xz$ ]]; then
            # info "Searching in package: '${pkg}'"
            local result
            result=$(lookup_file_in_package_archive "${file}" "${pkg}")
            if [[ -n "${result}" ]]; then
                ok "Result for '${pkg}': '${result}'"
            fi
        fi
    done
}

function has_package_extension() {
    local package_name="$1"
    if [[ -z "${package_name}" ]]; then
        fatal "has_package_extension: No package_name provided" 90
    fi
    package_name=$(basename "${package_name}")
    if [[ "${package_name}" =~ \.rpm$ || "${package_name}" =~ \.tar\.gz$ || "${package_name}" =~ \.xz$ ]]; then
        return 0
    fi
    return 1
}

function make_package_list() {
    local package_name="$1"
    if [[ -z "${package_name}" ]]; then
        fatal "make_package_list: No package_name provided" 91
    fi
    local verbose="$2"
    package_name=$(basename "${package_name}")
    local full_package_name
    full_package_name="$(get_full_package_name "${package_name}")"
    if [[ -z "${full_package_name}" ]]; then
        fatal "make_package_list: No full package name found for '${package_name}'" 94
    fi
    if ! has_package_extension "${full_package_name}"; then
        fatal "make_package_list: full_package_name '${full_package_name}' must have a known extension (.rpm, .tar.gz, .tar.xz, .xz)" 93
    fi
    local tools_pkgs
    tools_pkgs="${HOME}/tools/pkgs"
    if [[ ! -e "${tools_pkgs}/${full_package_name}" ]]; then
        fatal "make_package_list: No package found for full_package_name '${full_package_name}' in '${tools_pkgs}'" 92
    fi
    local list_file
    local base_package_name
    base_package_name="$(base_package_name "${full_package_name}" )"
    if [[ -z "${base_package_name}" ]]; then
        fatal "make_package_list: No base package name found for '${full_package_name}'" 95
    fi
    list_file="${tools_pkgs}/${base_package_name}.list"
    if [[ -f "${list_file}" ]]; then
        if [[ -n "${verbose}" ]]; then
            ok "make_package_list: List file '${list_file}' already exists"
        fi
        return 0
    fi
    if [[ "${full_package_name}" =~ \.rpm$ ]]; then
        rpm2cpio "${tools_pkgs}/${full_package_name}" | cpio -itv > "${list_file}" 2>/dev/null \
            || fatal "make_package_list: Failed to list rpm archive '${full_package_name}'" 94
    elif [[ "${full_package_name}" =~ \.tar\.gz$ ]]; then
        tar tzvf "${tools_pkgs}/${full_package_name}" > "${list_file}" \
            || fatal "make_package_list: Failed to list tar.gz archive '${full_package_name}'" 95
    elif [[ "${full_package_name}" =~ \.xz$ ]]; then
        if [[ "${full_package_name}" =~ \.tar\.xz$ ]] || file "${tools_pkgs}/${full_package_name}" | grep -q "XZ compressed data.*tar archive"; then
            tar tJvf "${tools_pkgs}/${full_package_name}" > "${list_file}" \
                || fatal "make_package_list: Failed to list tar.xz archive '${full_package_name}'" 96
        else
            # For non-tar xz files (less common case), assume zip archive behind the xz compression
            tar --xz -tzvf "${tools_pkgs}/${full_package_name}" > "${list_file}" \
                || fatal "make_package_list: Failed to list xz archive '${full_package_name}'" 97
        fi
    fi
    if [[ -n "${verbose}" ]]; then
        ok "make_package_list: List file '${list_file}' created"
    fi
}

function lookup_file_in_package_archive() {
    local search_pattern="$1"
    if [[ -z "${search_pattern}" ]]; then
        fatal "lookup_file_in_package_archive: No search pattern provided" 51
    fi
    local package_name="$2"
    if [[ -z "${package_name}" ]]; then
        fatal "lookup_file_in_package_archive: No package name provided" 53
    fi
    package_name=$(basename "${package_name}")
    local full_package_name
    full_package_name="$(get_full_package_name "${package_name}")"
    if [[ -z "${full_package_name}" ]]; then
        fatal "lookup_file_in_package_archive: No full package name found for '${package_name}'" 54
    fi
    local base_package_name
    base_package_name="$(base_package_name "${full_package_name}" )"
    if [[ -z "${base_package_name}" ]]; then
        fatal "make_package_list: No base package name found for '${full_package_name}'" 95
    fi
    local tools_pkgs
    tools_pkgs="${HOME}/tools/pkgs"
    full_list_file="${tools_pkgs}/${base_package_name}.list"

    if [[ ! -e "${full_list_file}" ]]; then
        if ! make_package_list "${full_package_name}"; then
            fatal "lookup_file_in_package_archive: Failed to create list file '${full_list_file}'" 55
        fi
    fi

    # Build the list file if it does not exist
    if [[ ! -f "${full_list_file}" || $(stat -c%s "${full_list_file}") -lt 500 ]]; then
        if [[ "$package_name" =~ \.rpm$ ]]; then
            rpm2cpio "${package_name}" | cpio -itv > "${full_list_file}" 2>/dev/null \
                || fatal "Failed to list rpm archive '${package_name}'" 50
        elif [[ "$package_name" =~ \.tar\.gz$ ]]; then
            tar tzvf "${package_name}" > "${full_list_file}" \
                || fatal "Failed to list tar.gz archive '${package_name}'" 51
        elif [[ "$package_name" =~ \.tar\.xz$ ]]; then
            tar tJvf "${package_name}" > "${full_list_file}" \
                || fatal "Failed to list xz archive '${package_name}'" 52
        elif [[ "$package_name" =~ \.xz$ ]]; then
            tar --xz -tzvf "${package_name}" > "${full_list_file}" \
                || fatal "Failed to list xz archive '${package_name}'" 52
        fi
    fi

    local result=""
    # If search_pattern has glob meta-characters then use grep,
    # otherwise compare against the basename (last field) of each line.
    if [[ "$search_pattern" == *"*"* || "$search_pattern" == *"?"* ]]; then
        result=$(grep -E "$search_pattern" "${full_list_file}" | head -n 1)
    else
        result=$(awk -v pat="$search_pattern" '$0 ~ ("/" pat "(/| )") { print $0; exit }' "${full_list_file}")
    fi

    echo "$result"
}


function current_tool() {
    local services
    get_property services
    # shellcheck disable=SC2154
    local tools
    tools="${services}"
    if [[ -z ${tools} ]]; then
        fatal "No tools retrieved for cplx" 1
    fi
    local cwd
    cwd=$(pwd -P)

    # Split the tools string into an array using comma as the delimiter
    IFS=',' read -ra tool_array <<< "${tools}"

    local tool
    # Loop over each tool in the array
    for tool in "${tool_array[@]}"; do
      # Trim any leading/trailing whitespace
      tool=$(echo "${tool}" | xargs)

      # Check if the current working directory matches the tool
      if [[ "$cwd" == */${tool}/* || "$cwd" == */${tool} ]]; then
        break
      fi
      tool=""
    done
    echo "${tool}"
}

function find_file_in_packages() {
    local file="${1}"
    if [[ -z "${file}" ]]; then
        fatal "No file provided" 101
    fi

    local pkgs_dir="${HOME}/tools/pkgs"
    local list_file
    # For each .list file under the packages directory
    for list_file in "${pkgs_dir}"/*.list; do
        # Make sure the file exists
        [[ -f "${list_file}" ]] || continue

        local archive_file
        local grep_output
        grep_output=$(grep --color=always -E "$file" "${list_file}")
        if [[ -n "${grep_output}" ]]; then
            # Print the list file only once as header
            archive_file=$(basename "${list_file%.list}")
            if [[ -e "${archive_file}.rpm" ]]; then archive_file="${archive_file}.rpm"; fi
            if [[ -e "${archive_file}.tar.gz" ]]; then archive_file="${archive_file}.tar.gz"; fi
            if [[ -e "${archive_file}.tar.xz" ]]; then archive_file="${archive_file}.tar.xz"; fi
            if [[ -e "${archive_file}.xz" ]]; then archive_file="${archive_file}.xz"; fi
            echo "${archive_file}"
            # Process each matching line: extract the portion after the first "./"
            while IFS= read -r line; do
                # Use sed to remove everything up to and including the first "./"
                local extracted
                extracted=$(echo "$line" | sed -E 's/^.*\.\///')
                echo "  ${extracted}"
            done <<< "${grep_output}"
        fi
    done
}

function is_package_installed() {
    local package_name="${1}"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided" 101
    fi
    if [[ -z "${verbose}" ]]; then
        if [[ -n "${3}" || "${2}" == "true" ]]; then verbose="true"; fi
        if [[ -n "${3}" || "${2}" == "verbose" ]]; then verbose="vv"; fi
    fi
    local full_package_name
    full_package_name=$(get_full_package_name "${package_name}")
    if [[ -z "${full_package_name}" ]]; then
        if [[ -n "${verbose}" ]]; then
            error "No package found for name '${package_name}'"
        fi
        return 1
    fi
    local tool
    tool="$(current_tool)"
    if [[ -z "${tool}" ]]; then
        if [[ -n "${verbose}" ]]; then
            error "No tool found for package '${package_name}'"
        fi
        return 1
    fi
    local missing
    local present_file
    files=$(list_files_in_package "${package_name}")
    while IFS= read -r file; do
        local full_file="${tools}/${tool}/root/${file}"
        if [[ ! -e "${full_file}" && ! -L "${full_file}" ]]; then
            missing=1
        elif [[ -f "${full_file}" ]]; then
            present_file=1
        fi
        if [[ "${verbose}" == "vv" ]]; then
            if [[ -L "${full_file}" ]]; then
                info "Symlink exists   : '${full_file}'"
            elif [[ -f "${full_file}" ]]; then
                info "File exists      : '${full_file}'"
                present_file=1
            elif [[ -d "${full_file}" ]]; then
                info "Directory exists : '${full_file}'"
            else
                warning "full_file missing: '${full_file}'"
            fi
        fi
    done <<< "$files"

    if [[ ${missing} -ne 1 ]]; then
        if [[ -n "${verbose}" ]]; then
            ok "'${package_name}' is installed. No missing file. verbose=vv for the list"
        fi
        return 0
    fi

    if [[ ${present_file} -eq 1 ]]; then
        if [[ -n "${verbose}" ]]; then
            error "'${package_name}' is NOT fully installed. Some file or folder are missing. Status 2. verbose=vv for the list"
        fi
        return 2
    fi
    if [[ -n "${verbose}" ]]; then
        error "'${package_name}' is NOT installed at all. All files are missing. verbose=vv for the list"
    fi
    return 1
}

function base_package_name() {
    local package_name
    package_name="$(basename "${1}")"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided" 171
    fi
    local base_package_name
    base_package_name="${package_name%.installed*}"
    base_package_name="${base_package_name%.list}"
    base_package_name="${base_package_name%.rpm}"
    base_package_name="${base_package_name%.tar.gz}"
    base_package_name="${base_package_name%.tar.xz}"
    base_package_name="${base_package_name%.xz}"
    echo "${base_package_name}"
}

function short_package_name() {
    local package_name
    package_name="$(basename "${1}")"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided" 171
    fi
    # Extract the core package name before the first version number
    # Use awk to split at the first dash followed by a digit
    # | awk 'BEGIN{FS="-[0-9]"; OFS="-"} {print $1}': no, too slow
    echo "${package_name%%-[0-9]*}"
}

function list_files_in_package() {
    local package_name="${1}"
    if [[ -z "${package_name}" ]]; then
        fatal "list_files_in_package: No package name provided" 111
    fi
    local full_package_name
    full_package_name="$(get_full_package_name "${package_name}")"
    if [[ -z "${full_package_name}" ]]; then
        fatal "list_files_in_package: No package found for '${package_name}'" 112
    fi
    local base_package_name
    base_package_name="$(base_package_name "${full_package_name}" )"
    local list_file
    list_file="${HOME}/tools/pkgs/${base_package_name}.list"

    if [[ ! -f "${full_list_file}" ]]; then
        if ! make_package_list "${full_package_name}"; then
            fatal "list_files_in_package: Failed to create list file '${full_list_file}'" 115
        fi
    fi
    if [[ ! -f "${list_file}" ]]; then
        fatal "No list file found for package '${full_package_name}'" 113
    fi
    awk 'BEGIN {count=0}
     # Process only lines where the last field starts with "./" and does not end with "/"
     $NF ~ /^\.\// && $NF !~ /\/$/ {
         line = $NF
         sub(/^\.\//, "", line)
         print line
         count++
         # if (count >= 100) exit
     }' "${list_file}"
}

function get_full_package_name() {
    local package_name="${1}"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided" 101
    fi
    local full_package_name
    if [[ -z ${full_package_name} ]]; then
        full_package_name="$(search_full_package_name_in_folder "${package_name}" "${HOME}/tools/pkgs")"
    fi
    local tool
    tool=$(current_tool)
    if [[ -z ${full_package_name} && -n ${tool} ]]; then
        full_package_name="$(search_full_package_name_in_folder "${package_name}" "${HOME}/tools/${tool}/pkgs")"
        if [[ -z ${full_package_name} ]]; then
            full_package_name="$(search_full_package_name_in_folder "${package_name}" "${HOME}/tools/${tool}/pkgs/removed")"
        fi
    fi
    if [[ -z ${full_package_name} ]]; then
        echo ""
        return
    fi
    # keep only the filename, not the full path. And remove any .list or .installed* extension local base
    base=$(search_pattern_for_package "$full_package_name")
    local candidates
    candidates=$(find "${HOME}/tools/pkgs" -maxdepth 1 -type f -name "${base}" | grep -v "\.list")
    local candidate
    candidate="$(printf "%s" "${candidates}"|tail -1)"
    local count
    count=$(echo "${candidates}" | grep -c '^')
    if ! is_package_built "${full_package_name}" && [ "${count}" -gt 1 ]; then
        echo "${candidates}"
        fatal "Expected one candidate file for '${base}', found ${count}" 104
    fi
    full_package_name=$(basename "${candidate}")
    echo "${full_package_name}"
}

search_pattern_for_package() {
    local package_name
    package_name="$(basename "${1}")"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided" 162
    fi
    local short_package_name
    short_package_name="$(short_package_name "${package_name}")"
    local search_pattern
    search_pattern="${short_package_name}-[0-9]*"
    echo "${search_pattern}"
}

function is_package_built() {
    local package_name
    package_name="$(basename "${1}")"
    if [[ -n "${package_name}" && "${package_name}" =~ -[0-9]{8}.[0-9]{4}. ]]; then
        return 0
    fi
    return 1
}

search_full_package_name_in_folder() {
    local package_name="${1}"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided" 102
    fi
    local folder="${2}"
    if [[ -z "${folder}" ]]; then
        fatal "No folder provided" 103
    fi
    if [[ ! -e "${folder}" ]]; then
        echo ""
        return
    fi
    local search_pattern
    search_pattern=$(search_pattern_for_package "${package_name}")
    local full_package_name
    local ext
    for ext in ".installed*" ".list" ".rpm" ".tar.gz" ".tar.xz" ".xz"; do
        full_package_name=$(find "${folder}" -maxdepth 1 -type f -name "${search_pattern}${ext}" | head -n 1)
        if [[ -n "${full_package_name}" ]]; then
            break
        fi
    done
    # If package_name includes a timestamp, it's a built package.
    # Example: openssl111-1.1.1w-20250301.0216.el7.x86_64.tar.gz
    if [[ -n "${full_package_name}" ]] && is_package_built "${full_package_name}"; then
        # Replace literal "0.el8.x86_64" with a glob pattern.
        local build_pattern
        build_pattern="$(search_pattern_for_package "${full_package_name}")"
        # info "Looking for built package in '${folder}' matching pattern '${build_pattern}'"

        # Use find with -printf to output modification time and file path,
        # sort numerically so that the oldest is first and the most recent is last,
        # then extract the file path.
        mapfile -t matches < <(find "${folder}" -maxdepth 1 -type f -name "${build_pattern}" -printf "%T@ %p\n" | sort -n | awk '{print $2}')
        if (( ${#matches[@]} == 0 )); then
            fatal "No built package found matching pattern '${build_pattern}' in '${folder}'" 100
        fi

        # Pick up the most recent found (last element after numeric sort by modification time).
        full_package_name=$(basename "${matches[-1]}")
        # ok "Using built package '${full_package_name}'"
    fi
    echo "${full_package_name}"
}

function remove_package() {
    local package_name="${1}"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided" 101
    fi
    package_name="$(short_package_name "${package_name}")"

    # Build f1_matches array using process substitution
    local f1_matches=()
    # shellcheck disable=SC2154
    while IFS='' read -r line; do
        f1_matches+=("$line")
    done < <(find "${tool_pkgs}" -maxdepth 1 -type f -name "${package_name}-[0-9]*.installed*")
    # Handle multiple matches for built packages - keep only the most recent
    if [[ ${#f1_matches[@]} -gt 1 ]]; then
        # Check if these are built packages
        if is_package_built "${f1_matches[0]}"; then
            # Find the most recent file using sorting by modification time
            local most_recent=""
            local timestamp=0
            local file_timestamp=0
            for file in "${f1_matches[@]}"; do
                file_timestamp=$(stat -c %Y "$file")
                if (( file_timestamp > timestamp )); then
                    timestamp=$file_timestamp
                    most_recent="$file"
                fi
            done

            # Delete older built packages
            for file in "${f1_matches[@]}"; do
                if [[ "$file" != "$most_recent" ]]; then
                    info "Removing older installed flag for built package: $(basename "$file")"
                    rm -f "$file"
                fi
            done

            # Update f1_matches to contain only the most recent file
            f1_matches=("${most_recent}")
        else
            # Not built packages, so this is an error
            fatal "Expected one .installed file for package '${package_name}' in '${tool_pkgs}', found ${#f1_matches[@]}" 102
        fi
    elif [[ ${#f1_matches[@]} -ne 1 ]]; then
        fatal "Expected one .installed file for package '${package_name}' in '${tool_pkgs}', none" 102
    fi
    local f1="${f1_matches[0]}"

    # Remove the .installed* extension
    local f1_basename
    f1_basename=$(basename "${f1}")
    local base="${f1_basename%%.installed*}"

    # Build f2_matches array using process substitution (supports .rpm, .tar.gz, .tar.xz or .xz)
    local f2_matches=()
    # shellcheck disable=SC2154
    while IFS='' read -r line; do
        f2_matches+=("$line")
    done < <(find "${tools_pkgs}" -maxdepth 1 -type f \( -name "${base}.rpm" -o -name "${base}.tar.gz" -o -name "${base}.tar.xz" -o -name "${base}.xz" \))
    # Handle multiple matches for built packages - keep only the most recent
    if [[ ${#f2_matches[@]} -gt 1 ]]; then
        # Check if these are built packages
        if is_package_built "${base}"; then
            # Find the most recent file using sorting by modification time
            local most_recent=""
            local timestamp=0
            local file_timestamp=0
            for file in "${f2_matches[@]}"; do
                file_timestamp=$(stat -c %Y "$file")
                if (( file_timestamp > timestamp )); then
                    timestamp=$file_timestamp
                    most_recent="$file"
                fi
            done

            # Delete older built packages
            for file in "${f2_matches[@]}"; do
                if [[ "$file" != "$most_recent" ]]; then
                    info "Removing older built package: $(basename "$file")"
                    rm -f "$file"
                fi
            done

            # Update f2_matches to contain only the most recent file
            f2_matches=("$most_recent")
        else
            # Not built packages, so this is an error
            fatal "Expected one package file for '${base}' in '${tools_pkgs}', found ${#f2_matches[@]}" 103
        fi
    elif [[ ${#f2_matches[@]} -ne 1 ]]; then
        fatal "Expected one package file for '${base}' in '${tools_pkgs}', found none" 104
    fi
    local f2="${f2_matches[0]}"

    task "Must remove files listed in '${f1}' for package '${f2}'"

    # Process lines from f1: remove only consecutive lines starting with './'
    local processing_started=0
    while IFS= read -r line; do
        if [[ "${line}" == ./* ]]; then
            processing_started=1
            # Determine the absolute path (assuming ${root} is set)
            # shellcheck disable=SC2154
            local file_to_remove="${root}/${line#./}"
            if [[ -f "${file_to_remove}" || -L "${file_to_remove}" ]]; then
                command rm "${file_to_remove}" || fatal "Failed to remove file '${file_to_remove}'" 106
                ok "Removed file '${file_to_remove}'"
                if [[ -e "${file_to_remove}.ori" ]]; then
                    command rm "${file_to_remove}.ori" || fatal "Failed to remove original file '${file_to_remove}.ori'" 108
                    ok "Also removed original file '${file_to_remove}.ori'"
                fi
                # Check for an accompanying .copied file in the same path
                local copied_file="${file_to_remove}.copied"
                if [[ -f "${copied_file}" ]]; then
                    command rm "${copied_file}" || fatal "Failed to remove copied file '${copied_file}'" 107
                    ok "Removed copied file '${copied_file}'"
                fi
            else
                warning "Skipping removal: '${file_to_remove}' is not a file or symlink or present"
            fi
        else
            # Once we start processing './' lines, stop when a different line is reached
            if (( processing_started )); then
                break
            fi
        fi
    done < "${f1}"

    # Create ${tool_pkgs}/removed folder (exit fatal on failure)
    local removed_dir="${tool_pkgs}/removed"
    mkdir -p "${removed_dir}" || fatal "Failed to create directory '${removed_dir}'" 104
    mv "${f1}" "${removed_dir}/" || fatal "Failed to move '${f1}' to '${removed_dir}'" 105
    ok "Moved '${f1}' to '${removed_dir}'"
}

_do_mirror=0
function do_mirror() { return ${_do_mirror}; }

function displayLog() {
    res=$?
    if [[ ${res} != 0 ]]; then tail -15 "${HOME}/tools/pkgs.log" >&3; fi
    /usr/bin/date >&3
}

function set_pkgs_log() {
    local DIR_tools
    DIR_tools="${HOME}/tools"
    local NOW
    NOW="$(/usr/bin/date +%Y%m%d-%H%M%S)"
    local LOGIN
    LOGIN="$(/usr/bin/id -un)"
    local log_action_name="${1}"
    if [[ -z "${log_action_name}" ]]; then
        fatal "set_pkgs_log: No log action name provided" 101
    fi

    logs="${DIR_tools}/logs"
    mkdir -p "${logs}"

    PATH_LOG="${logs}/${LOGIN}-${log_action_name}-${NOW}.pkgs.log"
    REL_PATH_LOG="logs/${LOGIN}-${log_action_name}-${NOW}.pkgs.log"
    rm -f "${DIR_tools}/pkgs.log"
    ln -nfs "${REL_PATH_LOG}" "${DIR_tools}/pkgs.log"

    info "Script Execution DIR '${DIR_tools}'"
    ok "Logging execution in '$PATH_LOG' (ln -nfs '${DIR_tools}/pkgs.log')"

    trap displayLog EXIT

    # shellcheck source=/dev/null
    source "${HOME}/echos/echoslog"
    # duplicates the current stderr (file descriptor 2) to file descriptor 3, saving the original stderr so it is used in the displayLog function).
    exec 3>&2
    # redirects standard output (stdout, file descriptor 1) to the file specified by PATH_LOG. After this, anything written to stdout goes into that log file.
    exec 1> "$PATH_LOG"
    # makes stderr (file descriptor 2) point to where stdout (file descriptor 1) currently goes—in this case, the log file.
    exec 2>&1

    set -o xtrace

}

#######################################################################
# Installs all packages defined in a tool's dependencies list file
#
# This function handles the installation of packages for a specific tool
# based on the contents of its dependencies.list file. It:
# - Validates the tool name or uses the current tool context
# - Reads the dependencies.list file line by line
# - Tracks which packages are already installed
# - Handles special '>' prefix to force reinstallation of packages
# - Provides progress reporting during installation
# - Displays a summary of the operation results
#
# The dependencies.list format:
# - One package name per line
# - Lines starting with '>' indicate forced reinstallation
# - All packages after a forced reinstall line are also reinstalled
#
# Arguments:
#   $1 - Tool name (optional, uses current tool if not provided)
#
# Returns:
#   0 on success (all necessary packages installed), non-zero on failure
#######################################################################
function install_packages_for_tool() {

    if [[ -n ${pkg_log} ]]; then
        set_pkgs_log "install_packages_for_tool"
    fi

    local tool_name="${1}"
    local exit_code=0
    local force_install=0
    local total_packages=0
    local installed_count=0

    # Determine the tool name
    if [[ -z "${tool_name}" ]]; then
        tool_name="$(current_tool)"
        if [[ -z "${tool_name}" ]]; then
            fatal "No tool name provided or determined from current directory" 401
            return 1
        fi
    elif ! _is_valid_tool_name "${tool_name}"; then
        fatal "Unknown tool name '${tool_name}'" 402
        return 1
    fi

    # Set paths
    local tool_path="${HOME}/tools/${tool_name}"
    local deps_file="${tool_path}/dependencies.list"
    local tool_pkgs="${tool_path}/pkgs"

    # Check if dependencies.list exists
    if [[ ! -f "${deps_file}" ]]; then
        fatal "Dependencies file not found: '${deps_file}'" 403
        return 1
    fi

    # Change to the tool directory
    cd "${tool_path}" || {
        fatal "Failed to change directory to '${tool_path}'" 404
        return 1
    }

    # First pass: count packages and build list of packages to install
    local packages_to_install=()

    # Read the dependencies file
    while IFS= read -r line || [[ -n "${line}" ]]; do
        # Skip empty lines and comments
        [[ -z "${line}" || "${line}" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        line=$(echo "${line}" | xargs)
        ((total_packages++))

        # Check if this package has the '>' prefix for forced reinstall
        if [[ "${line:0:1}" == ">" ]]; then
            # Remove the '>' prefix
            line="${line:1}"
            force_install=1
        fi
        # Check if this package name starts with _ (built package)
        if [[ "${line:0:1}" == "_" ]]; then
            # Remove the '_' prefix
            line="${line:1}"
        fi

        # Check if the package is already installed (unless force_install is set)
        local full_package_name
        full_package_name=$(get_full_package_name "${line}")

        if [[ -z "${full_package_name}" ]]; then
            error "No package found for name '${line}' in dependencies list"
            exit_code=1
            continue
        fi

        local base_package_name
        base_package_name="$(base_package_name "${full_package_name}")"

        # If force_install is set or package is not installed (or installed but not mirrored), add to install list
        if [[ ${force_install} -eq 1 ]] || ! is_package_flagged_as "${base_package_name}" "mirrored"; then
            packages_to_install+=("${line}")
        else
            ((installed_count++))
            ok "Package '${line}' is already installed (base_package_name='${base_package_name}')"
        fi
    done < "${deps_file}"

    # If all packages are already installed, we're done
    if [[ ${#packages_to_install[@]} -eq 0 ]]; then
        ok "All ${total_packages} packages are already installed for tool '${tool_name}'"
        return 0
    fi

    # Install the packages
    local count=1
    for package in "${packages_to_install[@]}"; do
        # Display a banner for the current package
        local banner="
╔════════════════════════════════════════════════════════════════╗
║  Installing package #${count}/${#packages_to_install[@]} for tool '${tool_name}'
║  Package: ${package}
╚════════════════════════════════════════════════════════════════╝"
        echo "${banner}"

        # Install the package
        if ! install_package_from_name "${package}"; then
            error "Failed to install package '${package}'"
            exit_code=1
        else
            ok "Successfully installed package '${package}'"
        fi

        ((count++))
    done

    # Final summary
    if [[ ${exit_code} -eq 0 ]]; then
        ok "Successfully installed all required packages for tool '${tool_name}'"
        ok "${#packages_to_install[@]} packages installed, ${installed_count} packages were already installed"
    else
        error "Failed to install some packages for tool '${tool_name}'"
        error "Please check the log for details"
    fi

    return ${exit_code}
}

function install_package_from_name() {
    local tool
    tool="$(current_tool)"
    if [[ -z "${tool}" ]]; then
        fatal "No tool to install '${1}' into: $(pwd)" 143
    fi
    tool="${HOME}/tools/${tool}"
    local tool_pkgs
    tool_pkgs="${tool}/pkgs"

    local package_name="${1}"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided to be installed in '${tool}'" 141
    fi
    local full_package_name
    full_package_name=$(get_full_package_name "${package_name}")
    if [[ -z "${full_package_name}" ]]; then
        fatal "No package found for name '${package_name}' to be installed in '${tool}'" 142
    fi

    local force
    force="false"
    if [[ "${2}" == "true" ]]; then force="true"; fi

    task "Must install package '${full_package_name}' in '${tool}'"
    local pkg_base
    pkg_base="$(base_package_name "${full_package_name}")"
    local sp
    sp="$(short_package_name "${pkg_base}")"
    sp="[${sp}] "

    local i_log
    i_log="${tool}/logs/install_package.log"
    rm -f "${i_log}"
    local m_log
    m_log="${tool}/logs/mirror_package.log"
    rm -f "${m_log}"
    if [[ "${force}" == "true" ]] || ! is_package_flagged_as "${pkg_base}" "installed" "true"; then
        ( install_tool_package "${pkg_base}" ) 2>&1 | tee -a "${i_log}"
        if is_package_flagged_as "${pkg_base}" "installed" && [[ -e "${i_log}" ]]; then
            cat "${i_log}" > "${tool_pkgs}/${pkg_base}.installed"
        else
            fatal "${sp}Unable to install '${full_package_name}'" 28
        fi
    fi
    _do_mirror=0
    if is_package_built "${pkg_base}"; then
        warning "${sp}Built package '${full_package_name}', skip mirroring"
        _do_mirror=1;
    fi
    if do_mirror; then
        if  [[ "${force}" == "true" ]] || ! is_package_flagged_as "${pkg_base}" "mirrored" "true"; then
            ( mirror_tool_package "${full_package_name}" ) 2>&1 | tee -a "${m_log}"
            if is_package_flagged_as "${pkg_base}" "mirrored" && [[ -e "${m_log}" ]]; then
                echo "${sp}-------------------">> "${tool_pkgs}/${pkg_base}.installed.mirrored"
                cat "${m_log}" >> "${tool_pkgs}/${pkg_base}.installed.mirrored"
            else
                fatal "${sp}Unable to mirror '${full_package_name}'" 29
            fi
        fi
    fi
    if [[ ! -e "${HOME}/tools/pkgs/${pkg_base}.list" ]]; then
        task "${sp}Must create list file for package '${pkg_base}'"
        make_package_list "${full_package_name}" "true"
    else
        ok "${sp}Package '${pkg_base}' already has a list file"
    fi
    post_install_tool "${package_name}"
    local pi_exit_status=$?
    info "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    info "${sp} (${package_name}) install exit status: [${pi_exit_status}]"
    info "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    return ${pi_exit_status}
}

# Update post_install_tool to use the new function
function post_install_tool() {
    local package_name="$1"
    if [[ "$package_name" =~ ^binutils-[0-9] ]]; then
        if [[ ! -e "${root}/usr/bin/ld" ]]; then
            ln -nfs "ld.bfd" "${root}/usr/bin/ld"
        fi
    fi

    # Process all pkg-config files in the package
    fix_package_pkgconfig_paths "${package_name}"

    return $?
}

# Function to process all .pc files in a package
function fix_package_pkgconfig_paths() {
    local package_name="$1"
    if [[ -z "${package_name}" ]]; then
        fatal "fix_package_pkgconfig_paths: No package name provided" 180
        return 1
    fi

    # Get full package name and base package name
    local full_package_name
    full_package_name=$(get_full_package_name "${package_name}")
    if [[ -z "${full_package_name}" ]]; then
        warning "No full package name found for '${package_name}', skipping pkg-config processing"
        return 0
    fi

    local pkg_base
    pkg_base="$(base_package_name "${full_package_name}")"
    info "Processing pkg-config files for package '${pkg_base}'"

    # Get the list of files in the package
    local files
    files=$(list_files_in_package "${package_name}")
    if [[ -z "${files}" ]]; then
        info "No files found in package '${package_name}'"
        return 0
    fi

    # Process each file, looking for .pc files
    local pc_count=0
    while IFS= read -r file; do
        if [[ "${file}" == *.pc ]]; then
            local pc_file="${root}/${file}"
            if [[ -f "${pc_file}" ]]; then
                info "Found pkg-config file: ${pc_file}"
                fix_pkgconfig_pc "${pc_file}"
                pc_count=$((pc_count + 1))
            else
                warning "Package lists .pc file but it doesn't exist at '${pc_file}'"
            fi
        fi
    done <<< "${files}"

    if [[ ${pc_count} -gt 0 ]]; then
        ok "Processed ${pc_count} pkg-config files from package '${package_name}'"
    else
        info "No pkg-config files found in package '${package_name}'"
    fi

    return 0
}

function install_tool_package() {
    # shellcheck disable=SC2154
    cd "${root}" || fatal "${sp}install_tool_package: Unable to access root '${root}'" 199

    local tool
    tool="$(current_tool)"
    if [[ -z "${tool}" ]]; then
        fatal "${sp}No tool to install '${1}' into: $(pwd)" 193
    fi
    tool="${HOME}/tools/${tool}"
    local tool_pkgs
    tool_pkgs="${tool}/pkgs"

    local package_name="${1}"
    if [[ -z "${package_name}" ]]; then
        fatal "${sp}No package name provided to be installed in '${tool}'" 141
    fi
    local full_package_name
    full_package_name=$(get_full_package_name "${1}")
    if [[ -z "${full_package_name}" ]]; then
        fatal "${sp}No package found for name '${package_name}' to be tool-installed in '${tool}'" 192
    fi

    local pkg_base
    pkg_base="$(base_package_name "${full_package_name}")"
    local flag="${tool_pkgs}/${pkg_base}.installed"
    if [[ "${full_package_name%.rpm}" != "${full_package_name}" ]]; then
        if ! rpm2cpio "${tools_pkgs}/${full_package_name}" | cpio -idmv; then fatal "Unable to install '${full_package_name}'" 2; fi
    elif [[ "${full_package_name%.tar.gz}" != "${full_package_name}" ]]; then
        if ! tar xpvf "${tools_pkgs}/${full_package_name}"; then fatal "Unable to untar gz '${full_package_name}'" 5; fi
    elif [[ "${full_package_name%.tar.xz}" != "${full_package_name}" ]]; then
        if ! tar xJvf "${tools_pkgs}/${full_package_name}"; then fatal "Unable to untar tar.xz '${full_package_name}'" 5; fi
    elif [[ "${full_package_name%.xz}" != "${full_package_name}" ]]; then
        if ! xzcat "${tools_pkgs}/${full_package_name}" > "${full_package_name%.xz,,}"; then fatal "Unable to unxz '${full_package_name}'" 4; fi
        chmod 755 "${full_package_name%.xz,,}"
    else
        fatal "${sp}unknown extension for archive '${full_package_name}'" 11
    fi
    touch "${flag}" || fatal "Unable to create flag file '${flag}'" 3
    ok "${sp}'${flag}' installed in '${root}': pwd '$(pwd)'"

}

function is_package_flagged_as() {
    local verbose=""
    if [[ -n "${3}" ]]; then verbose="true"; fi
    local tool
    tool="$(current_tool)"
    if [[ -z "${tool}" ]]; then
        fatal "${sp}No tool to install '${1}' into: $(pwd)" 183
    fi
    tool="${HOME}/tools/${tool}"

    local full_package_name
    full_package_name=$(get_full_package_name "${1}")
    if [[ -z "${full_package_name}" ]]; then
        fatal "${sp}No package found for name '${package_name}' to be flag checked in '${tool}'" 182
    fi

    local pkg_base
    pkg_base="$(base_package_name "${full_package_name}")"

    local flag_suffix="$2"
    local pattern="${pkg_base}*${flag_suffix}*"
    local tool_pkgs
    tool_pkgs="${tool}/pkgs"
    cd "${tool_pkgs}" || fatal "Unable to access tools_pkgs '${tool_pkgs}'" 181
    shopt -s nullglob
    # shellcheck disable=SC2206
    local flags=( ${pattern} )
    shopt -u nullglob
    if (( ${#flags[@]} > 0 )); then
        if [[ -n "${verbose}" ]]; then
            info "${sp}A file matching '${pattern}' already exists in '${tool_pkgs}'"
            ok "${sp}'${pkg_base}' already '${flag_suffix}' in '${tool_pkgs}'"
        fi
        return 0
    fi
    if [[ -n "${verbose}" ]]; then
        warning "No file matching '${pattern}' found in '${tool_pkgs}'"
    fi
    return 1
}

mirror_tool_package() {

    # shellcheck disable=SC2154
    cd "${root}" || fatal "mirror_tool_package: Unable to access root '${root}'" 209

    local tool
    tool="$(current_tool)"
    if [[ -z "${tool}" ]]; then
        fatal "No tool to install '${1}' into: $(pwd)" 203
    fi
    tool="${HOME}/tools/${tool}"

    local full_package_name
    full_package_name=$(get_full_package_name "${1}")
    if [[ -z "${full_package_name}" ]]; then
        fatal "No package found for name '${package_name}' to be flag checked in '${tool}'" 202
    fi

    local pkg_name="${full_package_name}"
    local pkg_file="${tools_pkgs}/${pkg_name}"
    local clean_ldd=0

    if [[ ! -e "${pkg_file}" ]]; then
        fatal "pkg_name file '${pkg_file}' not found" 1
    fi

    local pkg_base
    pkg_base=$(base_package_name "${pkg_name}")

    info "Listing contents of pkg_name '${pkg_name}':"
    if [[ "${pkg_name%.rpm}" != "${pkg_name}" ]]; then
        # Open file descriptor 8 with the command output, ensuring the while read runs in the current shell.
        exec 9< <(rpm2cpio "${pkg_file}" | cpio -itv)
        while IFS= read -r line <&9 || [ -n "$line" ]; do
            # Process each line (you can add custom processing here)
            # info "call mirror_system_executable '${line}' with clean_ldd='${clean_ldd}'"
            if ! mirror_system_executable "${line}"; then clean_ldd=1; fi
        done
        exec 9<&-
    elif [[ "${pkg_name%.tar.gz}" != "${pkg_name}" ]]; then
        tar tzvf "${pkg_file}" | while IFS= read -r line; do
            # Process each line (custom processing can be added here)
            info "${sp}tar.gz contains: ${line}"
        done
    elif [[ "${pkg_name%.tar.xz}" != "${pkg_name}" ]]; then
        tar tJvf "${pkg_file}" | while IFS= read -r line; do
            # Process each line (custom processing can be added here)
            info "${sp}tar.xz contains: ${line}"
        done
    elif [[ "${pkg_name%.xz}" != "${pkg_name}" ]]; then
        # Assuming it's a tar.xz package
        if file "${pkg_file}" | grep -qi "tar archive"; then
            tar --xz -tzvf "${pkg_file}" | while IFS= read -r line; do
                info "${sp}[tar].xz contains: ${line}"
            done
        else
            fatal "${sp}Unsupported xz archive type for pkg_name '${pkg_name}'" 1
        fi
    else
        fatal "${sp}Unknown archive extension for pkg_name '${pkg_name}'" 11
    fi

    #info "Final clean_ldd='${clean_ldd}'"
    if [[ "${clean_ldd}" != "0" ]]; then
        fatal "${sp}Some files in the package '${pkg_name}' have absolute system paths or unresolved paths" 199
    fi

    mv "${tool_pkgs}/${pkg_base}.installed" "${tool_pkgs}/${pkg_base}.installed.mirrored" || fatal "${sp}Unable to rename flag file '${pkg_base}.installed' to '${tool_pkgs}/${pkg_base}.installed.mirrored'" 12

}

mirror_system_executable() {
    local src_line="$1"
    # Remove everything before the first '/' and prepend '/' (if not already)
    local src_file="/${src_line#*/}"
    local ret=0

    # Check that src_file exists and is a regular file (not a symlink)
    if [[ -f "${src_file}" && ! -L "${src_file}" ]]; then
        # Construct the destination path by prefixing the current folder path.
        # For example, for /usr/bin/unzipsfx, it will be copied to ./usr/bin/unzipsfx
        task "Must copy '${src_file}' to mirror folder '$(pwd)'"
        local dest_file="./${src_file#/}"  # removes leading /
        local dest_dir
        dest_dir=$(dirname "${dest_file}")
        mkdir -p "${dest_dir}" || fatal "${sp}Unable to create directory '${dest_dir}'" 31

        _copy_element "${src_file}" "${dest_file}" "mirror cp"
        # Since it comes from the system, import also its ldd dependencies
        if ! check_ldd "./${src_file#/}" "${dest_dir}"; then
            warning "${sp}mirror_system_executable ret=1 after ldd import of './${src_file#/}' to '${dest_dir}'"
            ret=1;
        fi
    else
        # info "No action: '${src_file}' either does not exist, is not a regular file, or is a symlink."
        # Nothing to copy from system /usr,
        # so check only dependencies of the installed library file
        # if there are any absolute path, exit fatal
        if [[  -f "./${src_file#/}" && ! -L "./${src_file#/}" ]]; then
            warning "${sp}mirror_system_executable ret=1 after ldd check of './${src_file#/}'"
            if ! check_ldd "./${src_file#/}"; then ret=1; fi
        fi
    fi

    return ${ret}
}

_copy_element() {
    local src_file="${1}"
    local dest_file="${2}"
    local msg="${3}"

    unset LD_RUN_PATH
    unset DT_RUNPATH
    unset LD_LIBRARY_PATH

    # If source is a symlink, create a symlink at the destination
    if [[ -L "${src_file}" ]]; then
        local target
        target=$(readlink "${src_file}")

        # Create destination directory if needed
        local dest_dir
        dest_dir=$(dirname "${dest_file}")
        mkdir -p "${dest_dir}" || fatal "${sp}Unable to create directory '${dest_dir}'" 31

        # Create the symlink
        ln -sf "${target}" "${dest_file}" || fatal "${sp}[${msg}] Unable to create symlink '${dest_file}'" 34
        touch "${dest_file}.copied" || fatal "${sp}Unable to create marker file '${dest_file}.copied'" 33
        ok "${sp}[${msg}] Created symlink '${dest_file}' -> '${target}' and created marker file '${dest_file}.copied'"

        # If we want to handle the target recursively
        local target_path

        # Determine if target is absolute or relative
        if [[ "${target}" == /* ]]; then
            # Absolute path
            target_path="${target}"
        else
            # Relative path - resolve relative to the source directory
            target_path="$(dirname "${src_file}")/${target}"
        fi

        # Only proceed if target exists
        if [[ -e "${target_path}" ]]; then
            local target_dest
            target_dest="${dest_dir}/$(basename "${target}")"

            # Recursively call _copy_element for the symlink target
            _copy_element "${target_path}" "${target_dest}" "${msg} (symlink target)"
            return $?
        fi

        return 0
    fi

    # Original copy logic for regular files
    local cp_output
    cp_output=$(cp "${src_file}" "${dest_file}" 2>&1)
    rc=$?
    if [ $rc -ne 0 ]; then
        if echo "$cp_output" | grep -qi "Permission denied"; then
            warning "${sp}[${msg}] Permission denied copying '${src_file}' to '${dest_file}', skipping marker creation"
            rm -f "${dest_file}"
            rm -f "${dest_file}.copied"
            return 0
        else
            rm -f "${dest_file}"
            rm -f "${dest_file}.copied"
            fatal "${sp}[${msg}] Unable to copy '${src_file}' to '${dest_file}': ${cp_output}" 32
        fi
    fi
    # Create a dummy file to indicate the file was copied
    touch "${dest_file}.copied" || fatal "Unable to create marker file '${dest_file}.copied'" 33
    ok "${sp}[${msg}] Copied '${src_file}' to '${dest_file}' and created marker file '${dest_file}.copied'"
    return 0
}

contains_any() {
    local line="$1"
    shift
    for token in "$@"; do
        if [[ "$line" == *"$token"* ]]; then
            return 0
        fi
    done
    return 1
}

_is_regular_file() {
    local file="$1"

    # Test if the file exists, is a regular file, and is not a symlink
    if [[ -f "${file}" && ! -L "${file}" ]]; then
        return 0  # True, it is a regular file and not a symlink
    else
        return 1  # False, it's either not a file or is a symlink
    fi
}

check_ldd() {
    local file="$1"
    local dest_dir="$2"

    if [[ -z "${LD_LIBRARY_PATH}" ]]; then
        SKIP_CC1_CHECK=1
        if ! setenv; then
            fatal "check_ldd: ${sp}Unable to set environment variables (SKIP_CC1_CHECK='${SKIP_CC1_CHECK}')" 123
        fi
        unset SKIP_CC1_CHECK
    fi
    if [[ -z "${LD_LIBRARY_PATH}" ]]; then
        fatal "check_ldd: ${sp}LD_LIBRARY_PATH is empty" 124
    fi

    # If the file name includes ' -> ', treat it as a symlink and skip ldd check.
    local exclude_tokens=(" -> " " => " "share/man" "share/doc" "share/licenses")
    if contains_any "${file}" "${exclude_tokens[@]}"; then
        return 0
    fi

    # If the file extension is h, hpp, or similar, no need to run ldd
    local ext="${file##*.}"
    case "$ext" in
        h|hpp|c|so|bz2|o|a|mo|gz|1.gz|LIB|pc)
            # info "'$file' is a header file; skipping ldd check"
            return 0
            ;;
    esac
    local output ret
    # Run ldd and capture output and exit code.
    output=$(ldd "$file" 2>&1)
    ret=$?
    if [ $ret -ne 0 ]; then
        # If ldd failed because the file is not a dynamic executable, we're done.
        if echo "$output" | grep -q "not a dynamic executable"; then
            info "${sp}'$file' is not a dynamic executable: no ldd check needed"
            return 0
        else
            warning "${sp}ldd unexpectedly failed for '$file': '${output}'"
            return $ret
        fi
    fi

    # Exclude list: if a line contains any of these strings, skip further tests.
    local exclude_tokens=("libm" "libc" "libdl" "ld-linux" "linux-vdso" "liboneagentproc")
    while IFS= read -r line || [ -n "$line" ]; do
        # If the line contains a '?' character, warn about an unresolved path.
        if [[ "$line" == *"?"* ]]; then
            warning "${sp}Unresolved path in ldd output: '$line'"
            ret=1
            continue
        fi

        # If the line includes any of the exclude tokens, do nothing.
        if contains_any "$line" "${exclude_tokens[@]}"; then
            continue
        fi

        # Check for an absolute system path. We look for a slash prefixed word.
        if [[ "${line}" =~ (^|[[:space:]])(/[^[:space:]]+) ]]; then
            if [[ "${line}" =~ [[:space:]]*(/[^[:space:]]+) ]]; then
                abs_path="${BASH_REMATCH[1]}"
                if _is_regular_file "${abs_path}"; then
                    if _is_regular_file "${root}${abs_path}" || _is_regular_file "${root}/usr${abs_path}"; then
                        continue # Skip since the dest_file exists
                    elif [[ -L "${root}${abs_path}" || -L "${root}/usr${abs_path}" ]]; then
                        if [[ -z "${dest_dir}" ]]; then
                            fatal "${sp}Dependency file '${abs_path}' is mirrored by symlink in '${root}'" 121
                        else
                            error "${sp}Dependency file '${abs_path}' is mirrored by symlink in '${root}': will copy again, as file this time"
                        fi
                    else
                        # nothing do do since dest file is missing: proceed to mirror
                        # shellcheck disable=SC2269
                        abs_path="${abs_path}"
                    fi
                elif [[ -L "${abs_path}" ]]; then
                    if [[ -L "${root}${abs_path}" || -L "${root}/usr${abs_path}" ]]; then
                        continue # Skip since the dest_symlink exists
                    elif _is_regular_file "${root}${abs_path}" || _is_regular_file "${root}/usr${abs_path}"; then
                        if [[ -z "${dest_dir}" ]]; then
                            fatal "${sp}Dependency symlink '${abs_path}' is mirrored by file in '${root}'" 121
                        else
                            error "${sp}Dependency symlink '${abs_path}' is mirrored by file in '${root}': will copy again, as symlink this time"
                        fi
                    else
                        # nothing do do since dest symlink is missing: proceed to mirror
                        # shellcheck disable=SC2269
                        abs_path="${abs_path}"
                    fi
                fi
            fi
            # if abs_path starts with ${tools}; then continue
            if [[ "${abs_path}" == "${tools}"* ]]; then
                continue  # Skip if abs_path starts with ${tools}
            fi
            error "${sp}Absolute system path '${abs_path}' detected (tools='${tools}') in ldd output: '$line' for file '${file}'"
            if [[ -n "${dest_dir}" ]]; then
                local dest1_file
                dest1_file="${dest_dir}/$(basename "${abs_path}")"
                task "${sp}Must import from '${abs_path}' to1 '${dest1_file}' this '${file}' dependency (${ret})"
                _copy_element "${abs_path}" "${dest1_file}" "check_ldd cp"
                ret=$?
            else
                ret=1
            fi
        fi
    done <<< "${output}"
    if [[ ! "${ret}" == "0" ]]; then
        env|grep LD
        echo "--------------"
        ldd "$file"
    fi
    return $ret
}

#######################################################################
# Fixes paths in pkg-config (.pc) files to reference the correct sysroot
#
# When installing packages into a tool-specific root directory, pkg-config 
# files contain absolute paths pointing to system locations (/usr/lib, etc.).
# These need to be modified to point to the tool's root directory instead,
# so that when compiling against these libraries, the tool's isolated 
# environment is used rather than the host system.
#
# The function:
# 1. Identifies the tool's root directory from the .pc file path
# 2. Creates a backup of the original .pc file if it doesn't exist
# 3. Processes each line containing an absolute path assignment (=/)
# 4. Preserves the original path structure but prefixes it with the tool's root
#    e.g., "/usr/lib64" becomes "/path/to/tool/root/usr/lib64"
# 5. Preserves lines that already contain a root path
#
# Arguments:
#   $1 - Path to the pkg-config (.pc) file to process
#
# Returns:
#   0 on success, non-zero on failure
#######################################################################
function fix_pkgconfig_pc() {
    local pkg_file="${1}"
    # check it is a pc file
    if [[ "${pkg_file}" != *.pc ]]; then
        fatal "Only process *.pc file (in tool/root folder)" 173
        return 1
    fi

    # Make sure to have the full pathname of the pc file
    if [[ "${pkg_file:0:1}" != "/" ]]; then
        # Convert relative path to absolute path
        pkg_file="$(readlink -f "${pkg_file}")"
        info "Converting relative path to absolute path: ${pkg_file}"
    fi

    if [[ "${pkg_file}" != */root/* ]]; then
        fatal "This pc file must be in a tool/root subfolder" 174
        return 1
    fi

    if [[ ! -e "${pkg_file}.ori" ]]; then
        cp "${pkg_file}" "${pkg_file}.ori" || fatal "Failed to copy '${pkg_file}' to '${pkg_file}.ori'" 175
        info "Created backup of '${pkg_file}' as '${pkg_file}.ori'"
    fi

    # extract the path up to /root from pkg_file
    local root_path
    # Match everything up to and including /root/
    if [[ "${pkg_file}" =~ ^(.*\/root\/) ]]; then
        root_path="${BASH_REMATCH[1]}"
        root_path="$(readlink -f "${root_path}")/"
        info "Root path extracted: ${root_path}"
    else
        fatal "Failed to extract root path from '${pkg_file}'" 174
        return 1
    fi

    # Example of pc file: [CPLX-GIT-DEV] gitea2@cactislux801:~/tools/tool/root$ cat ./usr/lib64/pkgconfig/expat.pc
    # prefix=/usr
    # exec_prefix=/usr
    # libdir=/usr/lib64
    # includedir=/usr/include

    # Name: expat
    # Version: 2.1.0
    # Description: expat XML parser
    # URL: http://www.libexpat.org
    # Libs: -L${libdir} -lexpat
    # Cflags: -I${includedir}

    # Process the pc file with awk to modify paths
    local tmp_file="${pkg_file}.tmp"
    awk -v root="${root_path}" '
    BEGIN {
        # Store the current root - escape special characters for regex
        root_safe = root
        gsub(/[\/\.]/, "\\\\&", root_safe)
    }

    # For lines with assignment and absolute path (contains "=/")
    $0 ~ /=\// {
        # Split the line at the equals sign
        split($0, parts, /=/)
        left_part = parts[1]
        right_part = parts[2]

        # Check if path already contains any form of a root path
        if (right_part ~ "/[^/]*/root/") {
            print left_part "=" right_part
        }
        # process built-in packages path, like /home/gitea2/cplx/tools/openssl111/openssl111-1.1.1w/usr
        else if (right_part ~ "/tools/[^/]+/[^/]+") {
            # For paths with /tools/{tool}/{version}/..., extract everything after the version
            match(right_part, "/tools/[^/]+/[^/]+/(.*)", tool_parts)
            if (tool_parts[1]) {
                # Use the portion after the tool directory
                print left_part "=" root tool_parts[1]
            } else {
                # Fallback if the regex does not match correctly
                print left_part "=" root
            }
        }
        # Process with a simpler, more generic pattern that captures the whole path
        else if (right_part ~ /^\/(.*)/) {
            # Extract everything after the leading slash
            match(right_part, /^\/(.*)/, path_parts)
            rest_path = path_parts[1]

            # Keep the original path structure but prefix with root
            print left_part "=" root rest_path
        } else {
            # Any other absolute path - replace with just root
            print left_part "=" root
        }
        next
    }

    # Default action for lines not matching "=/"
    {
        print $0
    }
    ' "${pkg_file}" > "${tmp_file}"

    # Check if the AWK command was successful
    # shellcheck disable=SC2181
    if [[ $? -ne 0 ]]; then
        fatal "Failed to process pkg-config file with awk" 175
        rm -f "${tmp_file}"
        return 1
    fi

    # Check if the content has changed
    if cmp -s "${pkg_file}" "${tmp_file}"; then
        # Files are identical, no changes needed
        info "No changes needed for '${pkg_file}'"
        rm -f "${tmp_file}"
    else
        # Files differ, update the original
        mv "${tmp_file}" "${pkg_file}"
        info "Successfully updated paths in '${pkg_file}'"
    fi
    return 0
}

#######################################################################
# Lists packages according to the specified tool name
#
# When no tool name is provided, it uses the current tool or lists 
# global packages from ${HOME}/tools/pkgs if no current tool is detected.
#
# When a tool name is provided, it lists installed or removed packages
# for that specific tool, depending on the packages_installed or 
# packages_removed environment variables.
#
# Output format:
#   [global]      : [short_name] [full_name] - For packages in global repository
#   [tool_name]   : [short_name] [full_name] - For installed packages
#   [tool_name][r]: [short_name] [full_name] - For removed packages
#
# Globals:
#   packages_installed - If set, lists only installed packages (default)
#   packages_removed   - If set, lists only removed packages
#
# Arguments:
#   $1 - Optional tool name
#
# Returns:
#   0 on success, non-zero on failure
#######################################################################
function list_packages() {
    local tool_name="${1}"
    local exit_code=0

    # If tool name is empty, set it to current tool
    if [[ -z "${tool_name}" ]]; then
        tool_name="$(current_tool)"
    fi

    # If tool name is still empty
    if [[ -z "${tool_name}" ]]; then
        # If qualifiers are defined and tool is empty, exit with error
        if [[ -n "${packages_installed}" || -n "${packages_removed}" ]]; then
            fatal "You need to specify a tool to list installed or removed packages" 201
            return 1
        fi

        # List packages from ~/pkgs, excluding *.list files
        # info "Listing packages in ${HOME}/tools/pkgs"
        find "${HOME}/tools/pkgs" -maxdepth 1 -type f ! -name "*.list" ! -name "*.installed*" ! -name "*.keep" | while read -r pkg_file; do
            _echo_from_pkg_file "global" "${pkg_file}"
        done
        return 0
    fi

    # Validate tool name against services property
    local services
    get_property services
    # Split the services string into an array using comma as delimiter
    IFS=',' read -ra tool_array <<< "${services}"
    local tool_valid=0
    for t in "${tool_array[@]}"; do
        t=$(echo "${t}" | xargs)  # Trim whitespace
        if [[ "${t}" == "${tool_name}" ]]; then
            tool_valid=1
            break
        fi
    done

    if [[ ${tool_valid} -eq 0 ]]; then
        fatal "Unknown tool name '${tool_name}'" 202
        return 1
    fi

    local tool_path="${HOME}/tools/${tool_name}"

    # List installed packages
    if [[ -n "${packages_removed}" ]]; then
        if [[ -d "${tool_path}/pkgs/removed" ]]; then
            # info "Listing removed packages for tool '${tool_name}'"
            find "${tool_path}/pkgs/removed" -maxdepth 1 -name "*.installed*" | while read -r pkg_file; do
                _echo_from_pkg_file "${tool_name}[r]" "${pkg_file}"
            done
        fi
    else
        # info "Listing installed packages for tool '${tool_name}'"
        find "${tool_path}/pkgs" -maxdepth 1 -name "*.installed*" | while read -r pkg_file; do
            _echo_from_pkg_file "${tool_name}" "${pkg_file}"
        done
    fi

    return ${exit_code}
}

_echo_from_pkg_file() {
    local type="${1}"
    local pkg_file="${2}"
    local full_package_name
    full_package_name="$(base_package_name "$(basename "${pkg_file}")")"
    local short_package_name
    short_package_name="$(short_package_name "${full_package_name}")"
    echo "${type}: ${short_package_name} ${full_package_name}"
}

#######################################################################
# Reinstalls a package for a specific tool
#
# This function handles package reinstallation by first removing any existing
# installation and then performing a clean install. This is useful when:
# - A package's files are corrupted or inconsistent
# - A newer version of the same package needs to be installed
# - Configuration needs to be reset to default
# - Dependencies have changed and need to be updated
#
# The function:
# 1. Validates the tool name or uses the current tool context
# 2. Removes any existing installation of the package
# 3. Installs a fresh copy of the package with forced install flag
# 4. Cleans up any files from the removed packages folder
# 5. Processes any post-install configurations and pkg-config files
#
# Arguments:
#   $1 - Tool name or package name if $2 is empty
#   $2 - Package name (optional if $1 is package name)
#
# Returns:
#   0 on success, non-zero on failure
#######################################################################
function reinstall_package() {
    local tool_name="${1}"
    local package_name="${2}"
    local current_tool
    current_tool="$(current_tool)"

    if [[ -z "${tool_name}" ]]; then
        fatal "No tool name provided or determined from current directory" 301
        return 1
    fi

    if ! _is_valid_tool_name "${tool_name}"; then
        if [[ -n "${package_name}" ]]; then
            fatal "Unknown tool name '${tool_name}'" 302
            return 1
        fi
        tool_name="${current_tool}"
        if [[ -z "${tool_name}" ]]; then
            fatal "No tool name provided or determined from current directory" 311
            return 1
        fi
        package_name="${1}"
    elif [[ -z "${package_name}" ]]; then
        if [[ "${tool_name}" != "${current_tool}" ]]; then
            tool_name="${current_tool}"
            package_name="${1}"
        else
            fatal "No package name provided for reinstallation (already in tool '${current_tool}')" 302
            return 1
        fi
    fi

    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided for reinstallation" 302
        return 1
    fi

    task "Reinstalling package '${package_name}' for tool '${tool_name}'"

    # Get the full package name
    local full_package_name
    full_package_name=$(get_full_package_name "${package_name}")
    if [[ -z "${full_package_name}" ]]; then
        fatal "No package found for name '${package_name}' to be reinstalled in '${tool_name}'" 304
        return 1
    fi

    local base_package_name
    base_package_name="$(base_package_name "${full_package_name}")"

    # First remove the package if it's installed
    local tool_path="${HOME}/tools/${tool_name}"
    local installed_flag="${tool_path}/pkgs/${base_package_name}.installed"
    local mirrored_flag="${tool_path}/pkgs/${base_package_name}.installed.mirrored"

    if [[ -f "${installed_flag}" || -f "${mirrored_flag}" ]]; then
        info "Removing existing installation of '${base_package_name}'"
        if ! remove_package "${base_package_name}"; then
            error "Failed to remove package '${base_package_name}'"
            return 1
        fi
    fi

    # Check if the package is in the removed folder
    local removed_dir="${tool_path}/pkgs/removed"
    local was_removed=0
    if [[ -d "${removed_dir}" ]] && find "${removed_dir}" -maxdepth 1 -name "${base_package_name}.installed*" | grep -q .; then
        was_removed=1
        info "Package '${base_package_name}' found in removed folder, will clean up after reinstall"
    fi

    # Install the package
    info "Installing package '${base_package_name}'"
    install_package_from_name "${package_name}" "true" || {
        error "Failed to install package '${base_package_name}'"
        return 1
    }

    # If the package was previously in the removed folder, clean it up
    if [[ ${was_removed} -eq 1 ]]; then
        info "Cleaning up previously removed package '${base_package_name}'"
        rm -f "${removed_dir}/${base_package_name}.installed"*
        ok "Removed '${base_package_name}' from the removed folder"
    fi

    ok "Successfully reinstalled package '${base_package_name}' for tool '${tool_name}'"
    return 0
}

#######################################################################
# Reinstalls all packages for a specific tool
#
# This function performs a complete refresh of all packages installed for
# a tool by reinstalling them one by one. This is useful when:
# - Upgrading or changing the tool's environment
# - Fixing consistency issues across multiple packages
# - Ensuring all post-install configurations are properly applied
# - Rebuilding a tool environment after system changes
#
# The function:
# 1. Validates the tool name or uses the current tool context
# 2. Gets a list of all currently installed packages for the tool
# 3. Processes each package sequentially through the reinstall_package function
# 4. Tracks successful and failed reinstallations
# 5. Provides a summary of the operation results
#
# Arguments:
#   $1 - Tool name (optional, uses current tool if not provided)
#
# Returns:
#   0 on success (all packages reinstalled), non-zero if any package fails
#######################################################################
function reinstall_all_packages() {
    local tool_name="${1}"
    local exit_code=0
    local reinstall_count=0
    local failed_count=0

    if [[ -z "${tool_name}" ]]; then
        tool_name="$(current_tool)"
        if [[ -z "${tool_name}" ]]; then
            fatal "No tool name provided or determined from current directory" 311
            return 1
        fi
    elif ! _is_valid_tool_name "${tool_name}"; then
        fatal "Unknown tool name '${tool_name}'" 312
        return 1
    fi

    task "Reinstalling all packages for tool '${tool_name}'"

    # Get a list of all installed packages for the tool
    # Use list_packages and parse its output format "tool_name: short_name full_package_name"
    local packages_output
    packages_output=$(list_packages "${tool_name}")

    # Process each package
    while IFS= read -r line; do
        # Skip empty lines
        [[ -z "${line}" ]] && continue

        # Extract the full package name (third field)
        local full_package_name
        full_package_name=$(echo "${line}" | awk '{print $3}')

        if [[ -n "${full_package_name}" ]]; then
            info "Reinstalling package '${full_package_name}'"

            # Call reinstall_package function
            if reinstall_package "${tool_name}" "${full_package_name}"; then
                ((reinstall_count++))
                ok "Package '${full_package_name}' reinstalled successfully"
            else
                ((failed_count++))
                error "Failed to reinstall package '${full_package_name}'"
                exit_code=1
            fi
        fi
    done <<< "${packages_output}"

    # Summary
    if [[ ${reinstall_count} -gt 0 ]]; then
        ok "Successfully reinstalled ${reinstall_count} packages for tool '${tool_name}'"
    else
        warning "No packages were reinstalled for tool '${tool_name}'"
    fi

    if [[ ${failed_count} -gt 0 ]]; then
        error "Failed to reinstall ${failed_count} packages for tool '${tool_name}'"
        exit_code=1
    fi

    return ${exit_code}
}

#######################################################################
# Validates if a string is a recognized tool name
#
# This helper function checks if the provided string matches one of the
# registered tool names in the system configuration. It's used to:
# - Ensure operations target valid tool environments
# - Prevent script errors when working with non-existent tools
# - Standardize tool name validation across multiple functions
#
# The function:
# 1. Retrieves the list of configured services/tools from properties
# 2. Splits the comma-separated list into individual tool names
# 3. Compares the provided name against each known tool name
# 4. Returns success (0) on match, failure (1) otherwise
#
# Arguments:
#   $1 - Tool name string to validate
#
# Returns:
#   0 if tool name is valid, 1 otherwise
#######################################################################
_is_valid_tool_name() {
    local services
    get_property services
    IFS=',' read -ra tool_array <<< "${services}"
    for t in "${tool_array[@]}"; do
        t=$(echo "${t}" | xargs)  # Trim whitespace
        if [[ "${t}" == "${tool_name}" ]]; then
            return 0
        fi
    done
    return 1
}
