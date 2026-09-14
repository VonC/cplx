#!/bin/bash
# Package setup pins selected metadata in the current invocation, prepares only
# the detected-key index, and copies the same list it synchronizes. Sourcing
# exposes functions for isolated verification without running setup.
# shellcheck source-path=SCRIPTDIR

SETUP_PKGS_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# echo "SETUP_PKGS_DIR='${SETUP_PKGS_DIR}'"
# shellcheck disable=SC1091
source "${SETUP_PKGS_DIR}/../echos/echos"
# shellcheck disable=SC1091
source "${SETUP_PKGS_DIR}/../utils/properties.sh"
source "${SETUP_PKGS_DIR}/../utils/steps.sh"
# shellcheck disable=SC1091
source "${SETUP_PKGS_DIR}/package_metadata.sh"
# shellcheck disable=SC1091
source "${SETUP_PKGS_DIR}/package_index.sh"
# SRC_DIR="$( cd "$( dirname "${SETUP_PKGS_DIR}" )" && pwd )"

main() {
    steps_file="${SETUP_PKGS_DIR}/steps.md"
    properties_file="${SETUP_PKGS_DIR}/setup.properties"

    # Add explicit logging about steps file
    info "Using steps file: '${steps_file}'"

    get_property architecture
    if [[ -z "${architecture}" ]]; then
        fatal "architecture not found in file '${properties_file}'" 8
    fi
    if [[ -z "${CPLX_TOOL}" ]]; then
        fatal "CPLX_TOOL not defined'" 12
    fi
    local -A package_context=() list_selection=()
    local -a package_urls=() diagnostics=()
    package_metadata_context "$architecture" "$SETUP_PKGS_DIR" package_context
    rm -f "${SETUP_PKGS_DIR}/pkgs.log"

    # Check if a specific package name was provided
    if [[ "${1:-}" == "--package" && -n "${2:-}" ]]; then
        # Direct package sync requested
        info "Direct package sync requested for package: '$2'"
        sync_package "${architecture}" "$2"
        install_package "$2"
    else
        # Regular flow
        if ! package_metadata_list "$SETUP_PKGS_DIR/pkgs" "$CPLX_TOOL" "$architecture" list_selection diagnostics; then
            fatal "Package list metadata for $architecture: ${diagnostics[*]}" 114
        fi
        package_context[list_source]=${list_selection[source]}
        package_context[list_path]="src/setups/pkgs/$CPLX_TOOL/${list_selection[source]##*/}"
        download_packages_list "${architecture}"
        sync_packages "${architecture}"
        install_packages
    fi
}

resolve_package_mirrors() {
    local -a diagnostics=()
    if ! package_metadata_pin_mirrors "$properties_file" package_context package_urls diagnostics; then
        fatal "Package mirror metadata for ${package_context[detected_key]}: ${diagnostics[*]}" 114
    fi
}

download_packages_list() {
    if package_index_available "${package_context[index_path]}" "${package_context[refresh_served]}" \
        "${CPLX_RELOAD_PACKAGES:-}" "${CPLX_FORCE_RELOAD_PACKAGES:-}"; then
        return 0
    fi
    resolve_package_mirrors
    task "Generating index '${package_context[index_path]}' from '${package_context[mirror_source]}' (${#package_urls[@]} URLs)"
    local status
    if package_index_generate "${package_context[index_path]}" "${package_context[detected_key]}" package_urls; then
        package_context[refresh_served]=1
        ok "Published index '${package_context[index_path]}' ($(wc -l < "${package_context[index_path]}") packages)"
    else
        status=$?
        fatal "Package index generation failed for ${package_context[detected_key]} (${package_context[index_path]})" "$status"
    fi
    if ! step_done download_packages_list; then
        fatal "Could not mark download_packages_list as done" 6
    fi
}

sync_packages() {
    local arch="$1"
    local pkgs_tool_dir="${SETUP_PKGS_DIR}/pkgs/${CPLX_TOOL}"
    local packages_for_tools="${package_context[list_source]}"
    if [[ ! -e "${packages_for_tools}" ]]; then
        fatal "File '${packages_for_tools}' not found" 9
    fi
    ok "Processing File '${packages_for_tools}'"

    last_value=""
    if [ -f "${pkgs_tool_dir}/last" ]; then
        last_value=$(cat "${pkgs_tool_dir}/last")
    fi

    process=0
    # If last_value is empty, start processing immediately.
    [ -z "$last_value" ] && process=1

    if ! get_property cplx_path; then
        fatal "cplx_path not found in file '${properties_file}'" 101
    fi

    # Before the while loop, initialize the array (if not already declared)
    skipped=()

    # Open the file on file descriptor 8
    exec 8<"${packages_for_tools}"
    while IFS= read -r line <&8 || [ -n "$line" ]; do
        # Trim leading spaces for checking
        trimmed_line="${line#"${line%%[![:space:]]*}"}"
        if [[ "$trimmed_line" == \#* ]]; then
            info "Skipping commented line: '${trimmed_line}'"
            continue
        fi
        if [[ "${line}" == "" ]]; then continue; fi
        # If we have not yet reached the last processed value, check for it.
        if [ "$process" -eq 0 ]; then
            if [[ "$line" == "$last_value" || "$line" == "${CPLX_SP_REPEAT}" ]]; then
                ok "Resuming processing after line: '${line}'"
                process=1
                # Clear the array if needed.
                skipped=()
            else
                # Instead of displaying, store the line in the array.
                skipped+=("$line")
            fi
            continue
        fi

        # Process the line (actual processing logic goes here)
        task "Must process line: '${line}'"
        if ! sync_package "${arch}" "${line}"; then
            fatal "Failed to process line: '${line}'" 10
        else
            ok "Line '${line}' processed successfully in '${packages_for_tools}'"
            # Update the 'last' file with the current processed value.
            echo "${line}" >"${pkgs_tool_dir}/last"
        fi
        process=1

    done
    # Close file descriptor 8.
    exec 8<&-
    if [ "$process" -eq 0 ]; then
        warning "All lines have already been processed."
    else
        ok "All lines have been processed."
    fi
}

sync_package() {
    local arch="$1"
    if [[ -z "${arch}" ]]; then
        fatal "sync_package: arch must be provided (rhel_7.9_x86_64, centos_8_x86_64, ...)" 224
    fi
    local pkg_name="$2"
    if [[ -z "${pkg_name}" ]]; then
        fatal "sync_package: pkg_name must be provided" 225
    fi

    local found_pkg=""
    if [[ "${pkg_name}" =~ ^[[:space:]]*_ ]]; then
        warning "No need to search built package '${pkg_name}' in a pkg archive list"
        found_pkg="${pkg_name}"
    else
        download_packages_list "${arch}"
        find_package_in_arch "${arch}" "${pkg_name}" "found_pkg"
    fi
    if [[ -z "${found_pkg}" ]]; then
        fatal "sync_package: found_pkg not found for pkg_name '${pkg_name}'" 227
    fi

    if [[ "${found_pkg}" != _* ]]; then
        download_package "${arch}" "${found_pkg}"
        scp_package "${arch}" "${found_pkg}"
    else
        ok "Package '${found_pkg}' is a remote built package: no download or scp needed"
    fi
}

find_package_in_arch() {
    local arch="$1"
    local pkg_name="$2"
    local packages_file="${SETUP_PKGS_DIR}/pkgs/packages_${arch}.txt"
    local pkg_res_var_name="$3"

    if [[ ! -f "${packages_file}" || ! -s "${packages_file}" ]]; then
        fatal "Package index '${packages_file}' is missing or empty; prepare the exact index before lookup" 201
    fi

    # Escape any unescaped plus signs
    local escaped_pkg_name
    escaped_pkg_name=$(echo "$pkg_name" | sed -E 's/(^|[^\\])\+/\1\\+/g')

    task "Must find package: '${escaped_pkg_name}' in file '${packages_file}'"
    local matches count found_pkg_in_arch
    # Grep for lines starting with pkg_name followed by a dash and a digit
    matches=$(grep -E "^_?${escaped_pkg_name}-[0-9]" "${packages_file}")
    count=$(echo "$matches" | awk 'NF {count++} END {print count+0}')

    if [[ "$count" -eq 0 ]]; then
        fatal "No package matching '${escaped_pkg_name}' found in ${packages_file}" 301
    elif [[ "$count" -gt 1 ]]; then
        fatal "Multiple packages matching '${escaped_pkg_name}' found in ${packages_file}" 302
    fi

    found_pkg_in_arch=$(echo "$matches" | head -n1)
    ok "Found package: '${found_pkg_in_arch}'"

    eval "${pkg_res_var_name}=\"${found_pkg_in_arch}\""
}

try_download_package() {
    local arch="$1"
    local pkg_name="$2"
    local url="$3"
    local should_fatal="${4:-0}" # 0 = error (don't fatal), 1 = fatal on failure

    if [[ ! -e "${SETUP_PKGS_DIR}/pkgs/${arch}" ]]; then
        if ! mkdir -p "${SETUP_PKGS_DIR}/pkgs/${arch}"; then
            fatal "Failed to create directory '${SETUP_PKGS_DIR}/pkgs/${arch}'" 202
        fi
    fi

    local package_file_name="${SETUP_PKGS_DIR}/pkgs/${arch}/${pkg_name}"
    local min_pkg_size=9
    local package_file_size_limit=$((min_pkg_size * 1024)) # 9KB

    info "Attempting download: url='${url}' for arch='${arch}' and package '${pkg_name}'"
    # Avoid any 403 from Cloudflare (protecting, for instance, vault.centos.org) by adding headers
    curl_headers=(
        -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"
        -H "Accept-Encoding: gzip, deflate"
        -H "Accept-Language: en-US,en;q=0.5"
        -H "Connection: keep-alive"
        -H 'Sec-Ch-Ua: "Chromium";v="128", "Not;A=Brand";v="24", "Brave";v="128"'
        -H "Sec-Ch-Ua-Mobile: ?0"
        -H 'Sec-Ch-Ua-Platform: "Windows"'
        -H "Sec-Fetch-Dest: document"
        -H "Sec-Fetch-Mode: navigate"
        -H "Sec-Fetch-Site: none"
        -H "Sec-Fetch-User: ?1"
        -H "Sec-Gpc: 1"
        -H "Upgrade-Insecure-Requests: 1"
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
    )
    if ! curl -kLs "${curl_headers[@]}" -o "${package_file_name}" "$url"; then
        if [[ "${should_fatal}" -eq 1 ]]; then
            fatal "Failed to download package '${package_file_name}' from '${url}'" 11
        else
            error "Failed to download package '${package_file_name}' from '${url}'"
            return 1
        fi
    else
        local file_size
        file_size=$(stat -c%s "${package_file_name}")
        if [ "$file_size" -lt "${package_file_size_limit}" ]; then
            rm -f "${package_file_name}"
            if [[ "${should_fatal}" -eq 1 ]]; then
                fatal "Downloaded package '${package_file_name}' is only ${file_size} bytes (<${min_pkg_size}KB), something went wrong" 2
            else
                error "Downloaded package '${package_file_name}' is only ${file_size} bytes (<${min_pkg_size}KB), something went wrong"
                return 1
            fi
        fi
        ok "Package '${pkg_name}' downloaded successfully to '${SETUP_PKGS_DIR}/pkgs/${arch}'"
        return 0
    fi
}

download_package() {
    local arch="$1"
    local pkg_name="$2"

    local package_file_name="${SETUP_PKGS_DIR}/pkgs/${arch}/${pkg_name}"
    local package_file_size
    package_file_size=$(stat -c%s "${package_file_name}" 2>/dev/null || echo 0)
    local min_pkg_size=9
    local package_file_size_limit=$((min_pkg_size * 1024)) # 9KB

    # Check if package already exists and is valid
    if [[ -e "${package_file_name}" ]]; then
        if [[ "${package_file_size}" -lt "${package_file_size_limit}" ]]; then
            mv "${package_file_name}" "${package_file_name}._to_delete"
            echo "File renamed to ${package_file_name}._to_delete because its size is ${package_file_size} bytes."
            fatal "Package '${package_file_name}' is only ${package_file_size} bytes (<${min_pkg_size}KB), something went wrong" 4
        fi
        ok "Package '${pkg_name}' already downloaded in '${SETUP_PKGS_DIR}/pkgs/${arch}'"
        return 0
    fi

    # Resolve once at first network need, retaining the selected ordered value.
    resolve_package_mirrors
    local i last_url_index=$((${#package_urls[@]} - 1))

    for i in "${!package_urls[@]}"; do
        local url="${package_urls[$i]%/}/${pkg_name}"

        # Replace [l] with the first letter of pkg_name in lowercase
        if [[ "$url" == *"[l]"* ]]; then
            local first_letter="${pkg_name:0:1}"
            first_letter="${first_letter,,}" # Convert to lowercase
            url="${url//\[l\]/$first_letter}"
        fi

        # Check if this is the last URL to try
        if [[ $i -eq $last_url_index ]]; then
            # Last URL - fatal on failure
            if try_download_package "${arch}" "${pkg_name}" "${url}" 1; then
                return 0
            fi
            fatal "No URLs worked for downloading package '${pkg_name}'" 3
        else
            # Not the last URL - just error on failure and try the next URL
            if try_download_package "${arch}" "${pkg_name}" "${url}" 0; then
                return 0 # Download succeeded, exit the loop
            fi
            # If we reach here, the download failed but we'll try the next URL
            warning "Failed with URL $((i+1))/${#package_urls[@]}, trying next mirror..."
        fi
    done

    # This should never be reached as the last URL will either succeed or fatal
    fatal "No URLs worked for downloading package '${pkg_name}'" 3
}

scp_package() {

    local arch="$1"
    local pkg_name="$2"

    local local_pkg="${SETUP_PKGS_DIR}/pkgs/${arch}/${pkg_name}"

    if [[ -z "${cplx_path}" ]]; then
        if ! get_property cplx_path; then
            fatal "cplx_path not found in file '${properties_file}'" 101
        fi
    fi
    # Test if pkg_name exists on the remote host at ${cplx_path}/tools/pkgs/
    remote_pkg="${cplx_path}/tools/pkgs/${pkg_name}"
    # shellcheck disable=SC2029
    if ssh "${SSH_CONFIG_ENTRY}" "test -e '${remote_pkg}'"; then
        info "Package '${pkg_name}' already exists at ${SSH_CONFIG_ENTRY}:${remote_pkg}"
    else
        task "Must copy package '${pkg_name}' to ${SSH_CONFIG_ENTRY}:${remote_pkg}"
        if ! scp "${local_pkg}" "${SSH_CONFIG_ENTRY}:${remote_pkg}"; then
            fatal "Failed to copy package '${pkg_name}' to ${SSH_CONFIG_ENTRY}:${remote_pkg}" 802
        else
            ok "Package '${pkg_name}' copied successfully to ${SSH_CONFIG_ENTRY}:${remote_pkg}"
        fi
    fi

}

# Add a new helper function to handle common setup and teardown operations
setup_remote_install() {
    if ! get_property cplx_path; then
        fatal "cplx_path not found in file '${properties_file}'" 101
    fi
    local remote_bin="${cplx_path}/bin/"
    task "Must copy 'packages_management.sh' script to ${SSH_CONFIG_ENTRY}:${remote_bin}"
    if ! scp "${SETUP_PKGS_DIR}/env/bin/packages_management.sh" "${SSH_CONFIG_ENTRY}:${remote_bin}"; then
        fatal "Failed to copy 'packages_management.sh' to ${SSH_CONFIG_ENTRY}:${remote_bin}" 902
    else
        ok "Script 'packages_management.sh' copied successfully to ${SSH_CONFIG_ENTRY}:${remote_bin}"
    fi

    # Copy dependencies list for regular install_packages (not needed for single package install)
    if [[ "$1" != "single_package" ]]; then
        local dep_list="${package_context[list_source]}"
        task "Must copy '${dep_list}' script to ${SSH_CONFIG_ENTRY}:${cplx_path}/tools/${CPLX_TOOL}/"
        if ! scp "${dep_list}" "${SSH_CONFIG_ENTRY}:${cplx_path}/tools/${CPLX_TOOL}/dependencies.list"; then
            fatal "Failed to copy '${dep_list}' to '${SSH_CONFIG_ENTRY}:${cplx_path}/tools/${CPLX_TOOL}/'" 902
        else
            ok "List '${dep_list}' copied successfully to '${SSH_CONFIG_ENTRY}:${cplx_path}/tools/${CPLX_TOOL}/dependencies.list'"
        fi
    fi
}

process_install_result() {
    # Get the last line from temp.txt as exit status
    lastLine=$(tail -n 1 "${SETUP_PKGS_DIR}/temp.pkgs.txt")
    info "vvvvvvvvvvvvvvvvvvvvvvvvvvv"
    info "Exit pkgs status: $lastLine"
    info "^^^^^^^^^^^^^^^^^^^^^^^^^^^"

    if [[ "${lastLine}" != "253" ]]; then
        # Copy the remote log file locally
        # shellcheck disable=SC2029
        if ssh "${SSH_CONFIG_ENTRY}" "cat ${cplx_path}/tools/pkgs.log" >>"${SETUP_PKGS_DIR}/pkgs.log"; then
            ok "Remote ('${SSH_CONFIG_ENTRY}') log file 'pkgs.log' appended successfully to '${SETUP_PKGS_DIR}/pkgs.log'"
        else
            warning "Failed to access remote ('${SSH_CONFIG_ENTRY}') log file or to open 'pkgs.log' file at '${SETUP_PKGS_DIR}'"
        fi
    fi

    if [ "${lastLine}" != "0" ]; then
        tail -n 10 "${SETUP_PKGS_DIR}/temp.pkgs.txt"
        fatal "Installation package failed" 5
    fi

    ok "Installation completed successfully"
}

install_package() {
    local package_name="$1"
    if [[ -z "${package_name}" ]]; then
        fatal "install_package: package_name must be provided" 901
    fi

    # Setup remote environment
    setup_remote_install "single_package"

    # Execute SSH command for single package installation
    set -x
    # shellcheck disable=SC2029
    ssh "${SSH_CONFIG_ENTRY}" "cd ${cplx_path}/tools/${CPLX_TOOL} && chmod 755 ${cplx_path}/bin/packages_management.sh && bash -c \"source ${cplx_path}/.env; pkg_log=1; install_package_from_name \\\"${package_name}\\\"\"; exit_status=\$?; echo \${exit_status}" | tee "${SETUP_PKGS_DIR}/temp.pkgs.txt"
    set +x

    # Process the installation result
    process_install_result
}

install_packages() {
    # Setup remote environment
    setup_remote_install "full_install"

    # Execute SSH command for full package installation
    set -x
    # shellcheck disable=SC2029
    ssh "${SSH_CONFIG_ENTRY}" "cd ${cplx_path}/tools/${CPLX_TOOL} && chmod 755 ${cplx_path}/bin/packages_management.sh && bash -c \"source ${cplx_path}/.env; pkg_log=1; install_packages_for_tool \\\"${CPLX_TOOL}\\\"\"; exit_status=\$?; echo \${exit_status}" | tee "${SETUP_PKGS_DIR}/temp.pkgs.txt"
    set +x

    # Process the installation result
    process_install_result
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
