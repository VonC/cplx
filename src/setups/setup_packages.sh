#!/bin/bash
# shellcheck source-path=SCRIPTDIR

SETUP_PKGS_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# echo "SETUP_PKGS_DIR='${SETUP_PKGS_DIR}'"
source "${SETUP_PKGS_DIR}/../echos/echos"
source "${SETUP_PKGS_DIR}/../utils/properties.sh"
source "${SETUP_PKGS_DIR}/../utils/steps.sh"
# SRC_DIR="$( cd "$( dirname "${SETUP_PKGS_DIR}" )" && pwd )"

main() {
    steps_file="${SETUP_PKGS_DIR}/steps.md"
    properties_file="${SETUP_PKGS_DIR}/setup.properties"
    get_property architecture
    if [[ -z "${architecture}" ]]; then
        fatal "architecture not found in file '${properties_file}'" 1
    fi
    download_packages_list "${architecture}"
}

download_packages_list() {
    if step_is_done "download_packages_list"; then
        ok "download_packages_list is already done"
        return 0
    fi
    local arch="$1"
    local packages_file="${SETUP_PKGS_DIR}/pkgs/packages_${arch}.txt"
    if [[ -f "${packages_file}" ]]; then
        if [[ -z "${CPLX_RELOAD_PACKAGES}" ]]; then
            ok "File '${packages_file}' already downloaded"
            return 0
        fi
        task "Must refresh/reload File '${packages_file}' (CPLX_RELOAD_PACKAGES env var set)"
    fi

    # URL of the HTML page
    pkgs_url_name="${arch/\./_}_pkgs_url"
    get_property "${pkgs_url_name}"
    url=${!pkgs_url_name}
    info "url='${url}' for arch='${arch}'"

    # Fetch the HTML content using curl
    html_content=$(curl -s "$url")

    # Extract URLs from the table rows using grep and sed
    set -o pipefail
    echo "$html_content" | grep -oP '<tr class="(even|odd)">.*?<a href="\K[^"]+' | if ! grep -v '^\.\./$' | grep 'x86_64' > "${SETUP_PKGS_DIR}/pkgs/urls.txt"; then
        fatal "Failed to extract URLs from the HTML content" 118
    fi

    # Process the URLs to keep only the last entry for each common prefix
    awk -F'-[0-9]' '{
        if ($0 !~ /^\//) {  # Ignore entries starting with /
            prefix = $1;        # Extract the common prefix (everything before -[0-9])
            map[prefix] = $0;   # Store the latest entry for each prefix
        }
    }
    END {
        # Sort the prefixes alphabetically
        n = asorti(map, sorted_prefixes);
        for (i = 1; i <= n; i++) {
            print map[sorted_prefixes[i]]; # Print the latest entry for each prefix
        }
    }' "${SETUP_PKGS_DIR}/pkgs/urls.txt" > "${SETUP_PKGS_DIR}/pkgs/packages_${arch}.txt"
    # shellcheck disable=SC2181
    if [[ $? -ne 0 ]]; then
        fatal "Failed to process the URLs" 119
    fi

    # Print the result
    if ! step_done "download_packages_list"; then
        fatal "Could not mark download_packages_list as done" 6
    fi
    ok "Filtered URLs saved to '${SETUP_PKGS_DIR}/pkgs/packages_${arch}.txt'"
}

sync_packages() {
    packages_for_tools="${SETUP_PKGS_DIR}/pkgs/${CPLX_TOOL}_${arch}.txt"
    if [[ ! -e "${packages_for_tools}" ]]; then
        fatal "File '${packages_for_tools}' not found" 1
    fi
    ok "Processing File '${packages_for_tools}'"
}
main "$@"

