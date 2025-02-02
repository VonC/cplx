#!/bin/bash
# shellcheck source-path=SCRIPTDIR

SETUP_PKGS_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# echo "SETUP_PKGS_DIR='${SETUP_PKGS_DIR}'"
source "${SETUP_PKGS_DIR}/../echos/echos"
source "${SETUP_PKGS_DIR}/../utils/properties.sh"
source "${SETUP_PKGS_DIR}/../utils/steps.sh"
# SRC_DIR="$( cd "$( dirname "${SETUP_PKGS_DIR}" )" && pwd )"

main() {
    properties_file="${SETUP_PKGS_DIR}/setup.properties"
    get_property architecture
    if [[ -z "${architecture}" ]]; then
        fatal "architecture not found in file '${properties_file}'" 1
    fi
}

main "$@"

