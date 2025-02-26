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

function lookup_file_in_package_archive() {
    local search_pattern="$1"
    local package_name="$2"
    local list_file

    # Determine list_file based on known archive extensions
    if [[ "$package_name" =~ \.rpm$ ]]; then
        list_file="${package_name%.rpm}.list"
    elif [[ "$package_name" =~ \.tar\.gz$ ]]; then
        list_file="${package_name%.tar.gz}.list"
    elif [[ "$package_name" =~ \.xz$ ]]; then
        list_file="${package_name%.xz}.list"
    else
        fatal "Unsupported package extension for '${package_name}'" 99
    fi

    local full_list_file="${list_file}"

    # Build the list file if it does not exist
    if [[ ! -f "${full_list_file}" || $(stat -c%s "${full_list_file}") -lt 500 ]]; then
        if [[ "$package_name" =~ \.rpm$ ]]; then
            rpm2cpio "${package_name}" | cpio -itv > "${full_list_file}" 2>/dev/null \
                || fatal "Failed to list rpm archive '${package_name}'" 50
        elif [[ "$package_name" =~ \.tar\.gz$ ]]; then
            tar tzvf "${package_name}" > "${full_list_file}" \
                || fatal "Failed to list tar.gz archive '${package_name}'" 51
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
    local full_package_name
    full_package_name=$(get_full_package_name "${package_name}")
    if [[ -z "${full_package_name}" ]]; then
        return 1
    fi
    local tool
    tool="$(current_tool)"
    if [[ -z "${tool}" ]]; then
        return 1
    fi
    local missing
    local present_file
    files=$(list_package "${package_name}")
    while IFS= read -r file; do
        local full_file="${tools}/${tool}/root/${file}"
        if [[ ! -e "${full_file}" && ! -L "${full_file}" ]]; then
            missing=1
        elif [[ -f "${full_file}" ]]; then
            present_file=1
        fi
    done <<< "$files"

    if [[ ${missing} -ne 1 ]]; then
        return 0
    fi

    if [[ ${present_file} -eq 1 ]]; then
        return 2
    fi
    return 1
}

function list_package() {
    local package_name="${1}"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided" 111
    fi
    local full_package_name
    full_package_name="$(get_full_package_name "${package_name}")"
    if [[ -z "${full_package_name}" ]]; then
        fatal "No package found for '${package_name}'" 112
    fi
    local base_package_name
    base_package_name="${full_package_name}"
    base_package_name="${base_package_name%.tar.gz}"
    base_package_name="${base_package_name%.rpm}"
    base_package_name="${base_package_name%.xz}"
    local list_file
    list_file="${HOME}/tools/pkgs/${base_package_name}.list"
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
    local tool
    tool=$(current_tool)
    if [[ -n ${tool} ]]; then
        full_package_name="$(search_full_package_name_in_folder "${package_name}" "${HOME}/tools/${tool}/pkgs")"
    fi
    if [[ -z ${full_package_name} ]]; then
        full_package_name="$(search_full_package_name_in_folder "${package_name}" "${HOME}/tools/${tool}/pkgs/removed")"
    fi
    if [[ -z ${full_package_name} ]]; then
        full_package_name="$(search_full_package_name_in_folder "${package_name}" "${HOME}/tools/pkgs")"
    fi
    if [[ -z ${full_package_name} ]]; then
        echo ""
        return
    fi
    # keep only the filename, not the full path. And remove any .list or .installed* extension local base
    base=$(basename "$full_package_name")
    base="${base%%.list}"
    base="${base%%.installed*}"
    local candidates
    candidates=$(find "${HOME}/tools/pkgs" -maxdepth 1 -type f -name "${base}.*" | grep -v "\.list")
    local count
    count=$(echo "${candidates}" | grep -c '^')
    if [ "$count" -gt 1 ]; then
        fatal "Expected one candidate file for '${base}', found ${count}" 104
    fi
    full_package_name=$(basename "${candidates}")
    echo "${full_package_name}"
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
    local full_package_name
    full_package_name=$(find "${folder}" -maxdepth 1 -type f -name "${package_name}-[0-9]*.installed*" | head -n 1)
    if [[ -z "${full_package_name}" ]]; then
        full_package_name=$(find "${folder}" -maxdepth 1 -type f -name "${package_name}-[0-9]*.list" | head -n 1)
    fi
    echo "${full_package_name}"
}

function remove_package() {
    local package_name="${1}"
    if [[ -z "${package_name}" ]]; then
        fatal "No package name provided" 101
    fi

    # Build f1_matches array using process substitution
    local f1_matches=()
    # shellcheck disable=SC2154
    while IFS='' read -r line; do
        f1_matches+=("$line")
    done < <(find "${tool_pkgs}" -maxdepth 1 -type f -name "${package_name}-[0-9]*.installed*")
    if [[ ${#f1_matches[@]} -ne 1 ]]; then
        fatal "Expected one .installed file for package '${package_name}' in '${tool_pkgs}', found ${#f1_matches[@]}" 102
    fi
    local f1="${f1_matches[0]}"

    # Remove the .installed* extension
    local f1_basename
    f1_basename=$(basename "${f1}")
    local base="${f1_basename%%.installed*}"

    # Build f2_matches array using process substitution (supports .rpm, .tar.gz, or .xz)
    local f2_matches=()
    # shellcheck disable=SC2154
    while IFS='' read -r line; do
        f2_matches+=("$line")
    done < <(find "${tools_pkgs}" -maxdepth 1 -type f \( -name "${base}.rpm" -o -name "${base}.tar.gz" -o -name "${base}.xz" \))
    if [[ ${#f2_matches[@]} -ne 1 ]]; then
        fatal "Expected one package file for '${base}' in '${tools_pkgs}', found ${#f2_matches[@]}" 103
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
            if [[ -e "${file_to_remove}" || -L "${file_to_remove}" ]]; then
                command rm "${file_to_remove}" || fatal "Failed to remove file '${file_to_remove}'" 106
                ok "Removed file '${file_to_remove}'"
                # Check for an accompanying .copied file in the same path
                local copied_file="${file_to_remove}.copied"
                if [[ -f "${copied_file}" ]]; then
                    command rm "${copied_file}" || fatal "Failed to remove copied file '${copied_file}'" 107
                    ok "Removed copied file '${copied_file}'"
                fi
            else
                warning "File '${file_to_remove}' is missing"
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