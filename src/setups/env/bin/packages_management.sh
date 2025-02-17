#!/bin/bash

get_package_name() {
    local services
    get_property services
    # shellcheck disable=SC2154
    local tools
    tools="${services}"
    if [[ -z ${tools} ]]; then
        error "No tools retrieved for cplx"; return 1
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

    local file
    file="${1}"
    if [[ -z ${tool} ]]; then
        tool="${1}"
        file="${2}"
    fi

    if [[ -z ${tool} ]]; then
        error "No tool provided or extracted from cwd '${cwd}'"; return 2
    fi
    if [[ -z ${file} ]]; then
        error "No file provided to search into packages"; return 3
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
            rpm2cpio "${package_name}" | cpio -itv > "${full_list_file}" \
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