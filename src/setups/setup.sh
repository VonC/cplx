#!/bin/bash
# shellcheck source-path=CPLX_DIR
# shellcheck disable=SC1091

SETUP_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
SRC_DIR="$( cd "$( dirname "${SETUP_DIR}" )" && pwd )"
INST_DIR="${SRC_DIR}/install"
# echo "SETUP_DIR='${SETUP_DIR}'"
source "${SRC_DIR}/echos/echos"
source "${SRC_DIR}/utils/properties.sh"
source "${SRC_DIR}/utils/steps.sh"

main() {
    steps_file="${SETUP_DIR}/steps.md"
    properties_file="${SETUP_DIR}/setup.properties"
    if [[ -n "${CPLX_REPEAT_STEP}" ]]; then
        info "CPLX_REPEAT_STEP is set to '${CPLX_REPEAT_STEP}': repeat that step"
        task "Must repeat '${CPLX_REPEAT_STEP}'"
        if ! repeat_step "${CPLX_REPEAT_STEP}"; then
            fatal "Could not repeat '${CPLX_REPEAT_STEP}'" 111
        fi
        ok "Repeated '${CPLX_REPEAT_STEP}' (steps file: '${steps_file}')"
    else
        info "CPLX_REPEAT_STEP is not set: no step to repeat"
    fi
    if [[ -n "${CPLX_RESET_STEP}" ]]; then
        info "CPLX_RESET_STEP is set to '${CPLX_RESET_STEP}': reset that step and all subsequent steps"
        task "Must reset '${CPLX_RESET_STEP}'"
        if ! reset_step "${CPLX_RESET_STEP}"; then
            fatal "Could not reset '${CPLX_RESET_STEP}'" 111
        fi
        ok "Reset '${CPLX_RESET_STEP}' (steps file: '${steps_file}')"
    else
        info "CPLX_RESET_STEP is not set: no step to repeat"
    fi
    get_property tools_to_recompile
    if [[ -z "${tools_to_recompile}" ]]; then
        fatal "tools_to_recompile not found in file '${properties_file}'" 1
    fi
    if [[ -z "${CPLX_TOOL}" ]]; then
        fatal "CPLX_TOOL not found in file '${properties_file}': must be one of '${tools_to_recompile}'" 2
    fi
    tools_names="$(echo "${tools_to_recompile}" | tr ',' ' ')"
    for tool_name in ${tools_names}; do
        if [[ "${tool_name}" == "${CPLX_TOOL}" ]]; then
            ok "CPLX_TOOL='${CPLX_TOOL}' is in the list of services ('${tools_to_recompile}')"
            break
        fi
        tool_name=""
    done
    if [[ -z "${tool_name}" ]]; then
        fatal "CPLX_TOOL='${CPLX_TOOL}' is not in the list of services: '${tools_to_recompile}'" 3
    fi
    validate_the_ssh_connection "$@"
    get_the_version
    copy_the_environment "$@"
    copy_the_sources "$@"
}

copy_the_environment() {
    if step_is_done "copy_the_environment"; then
        ok "copy_the_environment is already done"
        return 0
    fi

    if [[ -z "${CPLX_TOOL}" ]]; then
        fatal "CPLX_TOOL not defined" 121
    fi
    if [[ -z "${CPLX_VERSION}" ]]; then
        fatal "CPLX_VERSION not defined" 122
    fi

    if step_is_done "create_the_remote_project_folder"; then
        ok "cplx_path '${cplx_path}' already created on '${hostname}'"
    else
        task "Must create remote project directory: ${hostname}/${cplx_path}"
        # shellcheck disable=SC2029
        ssh "${SSH_CONFIG_ENTRY}" "mkdir -p \"${cplx_path}/echos\"" || fatal "Could not create remote directory" 11
        if ! step_done "create_the_remote_project_folder"; then
            fatal "Could not mark create_the_remote_project_folder as done" 6
        fi
        ok "Remote directory '${cplx_path}' created on '${hostname}'"
    fi

    if step_is_done "transfer_env_to_the_remote_project_folder"; then
        ok "transfer_env_to_the_remote_project_folder is already done"
    else
        task "Must copy the environment to ${hostname}/${cplx_path}"
        set -o pipefail
        # Normalize any repeated slashes:
        normalized_path="$(echo "${SETUP_DIR}/env" | tr -s '/')"
        # Count the slashes to determine the number of components:
        component_count="$(echo "${normalized_path}" | grep -o '/' | wc -l)"
        normalized_path="$(echo "${SRC_DIR}/utils" | tr -s '/')"
        component_count_utils="$(echo "${normalized_path}" | grep -o '/' | wc -l)"

        # shellcheck disable=SC2029
        ( tar cvf - "${SETUP_DIR}/env/" | ssh "${SSH_CONFIG_ENTRY}" "tar xpvf - -C \"${cplx_path}\" --strip-components=${component_count}" ) || fatal "Could not copy environment" 11
        # shellcheck disable=SC2029
        ( tar cvf - "${SRC_DIR}/utils" | ssh "${SSH_CONFIG_ENTRY}" "tar xpvf - -C \"${cplx_path}/bin\" --strip-components=${component_count_utils}" ) || fatal "Could not copy utils environment" 12
        # shellcheck disable=SC2029
        ( tar cvf - "${SRC_DIR}/echos" | ssh "${SSH_CONFIG_ENTRY}" "tar xpvf - -C \"${cplx_path}/echos\" --strip-components=${component_count_utils}" ) || fatal "Could not copy echos environment" 13
        # shellcheck disable=SC2029
        ( tar cvf - "${INST_DIR}/env" | ssh "${SSH_CONFIG_ENTRY}" "tar xpvf - -C \"${cplx_path}/tools\" --strip-components=${component_count}" ) || fatal "Could not copy install environment" 19
        task "Must execute setup on the remote server '${SSH_CONFIG_ENTRY}'"
        # shellcheck disable=SC2029
        res=$(ssh "${SSH_CONFIG_ENTRY}" "cd ${cplx_path}/tools && chmod 755 ./setup && bash ./setup \"${CPLX_TOOL}\" \"${CPLX_VERSION}\"; exit_status=\$?; echo \${exit_status}" | tee "${SETUP_DIR}\setup.log" | tail -1)
        if [[ ${res} -ne 0 ]]; then
            fatal "Could not execute setup on the remote server '${SSH_CONFIG_ENTRY}'" 14
        fi
        if ! step_done "transfer_env_to_the_remote_project_folder"; then
            fatal "Could not mark transfer_env_to_the_remote_project_folder as done" 6
        fi
        ok "Local env transferred to the Remote directory '${cplx_path}' on '${SSH_CONFIG_ENTRY}'"
    fi
    if ! step_is_done "copy_the_environment"; then
        fatal "copy_the_environment should be done done" 6
    fi
    ok "copy_the_environment is done"
}

validate_the_ssh_connection() {
    if step_is_done "validate_the_ssh_connection"; then
        get_properties "SSH_CONFIG_ENTRY,hostname,cplx_path"
        ok "validate_the_ssh_connection is already done"
        info "SSH_CONFIG_ENTRY='${SSH_CONFIG_ENTRY}', hostname='${hostname}', cplx_path='${cplx_path}'"
        return 0
    fi
    info "SSH_CONFIG_ENTRY='${SSH_CONFIG_ENTRY}'"
    if [[ -z "${SSH_CONFIG_ENTRY}" ]]; then
        fatal "SSH_CONFIG_ENTRY is not defined (must be an SSH alias to remote Linux server where a program is compiled)" 1
    fi
    task "Must get the hostname from SSH config"
    hostname=$(awk 'BEGIN {IGNORECASE=1} /^Host\s+'"${SSH_CONFIG_ENTRY}"'$/ {found=1; next} found && $1 == "Hostname" {print $2; exit}' ~/.ssh/config)
    if [[ -z "${hostname}" ]]; then
        fatal "Hostname not found in SSH config for '${SSH_CONFIG_ENTRY}'" 2
    fi
    ok "Hostname is '${hostname}'"
    task "Must check if ${hostname} is reachable through ssh"
    if ! ssh -q "${SSH_CONFIG_ENTRY}" exit; then
        fatal "Cannot reach '${hostname}' through SSH" 3
    fi
    ok "Can reach '${hostname}' through SSH"

    # Capture the ${SSH_CONFIG_ENTRY}_cd definition from the config
    eval "cd_${SSH_CONFIG_ENTRY}=\"\$(
    awk -v host=\"${SSH_CONFIG_ENTRY}\" '
        BEGIN {IGNORECASE=1}
        \$0 ~ \"^Host[[:space:]]+\" host \"\$\" {found=1; next}
        found && /^[[:space:]]*\$/ {exit}
        found && \$0 ~ (\"#\" host \"_cd\") {
        sub(\".*#\" host \"_cd[[:space:]]+\", \"\", \$0)
        sub(/[[:space:]]+\$/, \"\", \$0)
        print
        exit
        }
    ' ~/.ssh/config
    )\""

    # Access it via an intermediate variable
    eval "cplx_path=\"\${cd_${SSH_CONFIG_ENTRY}}\""
    # shellcheck disable=SC2001
    cplx_path="$(echo "$cplx_path" | sed 's/^[[:space:]]*//')"

    if [[ -z "${cplx_path}" ]]; then
        fatal "No 'cd_${SSH_CONFIG_ENTRY}' found in SSH config under 'Host ${SSH_CONFIG_ENTRY}'" 4
    fi
    ok "Found cd_${SSH_CONFIG_ENTRY}='${cplx_path}'"
    set_property "SSH_CONFIG_ENTRY" "${SSH_CONFIG_ENTRY}"
    set_property "hostname" "${hostname}"
    set_property "cplx_path" "${cplx_path}"
    # shellcheck disable=SC2029
    # shellcheck disable=SC2140
    architecture="$(ssh "${SSH_CONFIG_ENTRY}" 'source /etc/os-release; printf "%s_%s_%s" $ID $VERSION_ID $(uname -m)')"
    architecture="${architecture// /_}"
    if [[ -z "${architecture}" ]]; then
        fatal "Could not get the architecture from the remote server" 55
    fi
    if ! set_property "architecture" "${architecture}"; then
        fatal "Could not set the architecture in the properties file" 56
    fi
    if ! step_done "validate_the_ssh_connection"; then
        fatal "Could not mark validate_the_ssh_connection as done" 5
    fi
    ok "validate_the_ssh_connection is done"
}

copy_the_sources() {

    if step_is_done "copy_the_sources"; then
        ok "'copy_the_sources' is already done for tool '${CPLX_TOOL}'"
        return 0
    fi

    get_the_version
    download_sources
    transfer_the_sources_to_the_remote_project_folder

    if ! step_done "copy_the_sources"; then
        fatal "Could not mark 'copy_the_sources' as done" 50
    fi
    ok "'copy_the_sources' is done"
}

transfer_the_sources_to_the_remote_project_folder() {
    if step_is_done "transfer_the_sources_to_the_remote_project_folder"; then
        ok "transfer_the_sources_to_the_remote_project_folder already copied to ${SSH_CONFIG_ENTRY} for tool '${CPLX_TOOL}'"
        return 0
    fi
    sources="${SETUP_DIR}/sources/${CPLX_TOOL}"
    src_ext=$(get_resource_extension)
    # shellcheck disable=SC2012
    filepath="$(ls -1rt "${sources}/${CPLX_TOOL}-src-"*".${src_ext}" | tail -1)"
    #file=$(find "${sources}" -type f -name "${CPLX_TOOL}-src-*.${src_ext}" -printf '%T@ %p\0' | sort -z -n | tail -z -n1 | cut -z -d' ' -f2-)
    filename=$(basename "${filepath}")
    
    # shellcheck disable=SC2029
    if ssh "${SSH_CONFIG_ENTRY}" "[ -e \"${cplx_path}/tools/${CPLX_TOOL}/sources/${filename}\" ]"; then
        ok "Sources '${filename}' already copied for tool '${CPLX_TOOL}' to ${SSH_CONFIG_ENTRY}:${cplx_path}/tools/${CPLX_TOOL}/sources/"
    else
        task "Must copy sources '${filename}' for tool '${CPLX_TOOL}'"
        if ! scp "${filepath}" "${SSH_CONFIG_ENTRY}:${cplx_path}/tools/${CPLX_TOOL}/sources/"; then
            fatal "Could not copy sources '${filename}' for tool '${CPLX_TOOL}' to ${SSH_CONFIG_ENTRY}:${cplx_path}/tools/${CPLX_TOOL}/sources/" 42
        fi
        ok "Sources '${filename}' copied for tool '${CPLX_TOOL}' to ${SSH_CONFIG_ENTRY}:${cplx_path}/tools/${CPLX_TOOL}/sources/"
    fi
    if ! step_done "transfer_the_sources_to_the_remote_project_folder"; then
        fatal "Could not mark 'transfer_the_sources_to_the_remote_project_folder' as done" 60
    fi
    ok "'transfer_the_sources_to_the_remote_project_folder' is done"
}

get_the_version() {
    if step_is_done "get_the_version"; then
        if [[ -z "${CPLX_VERSION}" ]]; then
            fatal "get_the_version is done but CPLX_VERSION is not defined" 31
        fi
        version="${CPLX_VERSION}"
        ok "'get_the_version' already fetched for tool '${CPLX_TOOL}': '${CPLX_VERSION}'"
        return 0
    fi
    if [[ -n "${CPLX_VERSION}" ]]; then
        version="${CPLX_VERSION}"
        ok "Version '${version}' already defined for tool '${CPLX_TOOL}' by CPLX_VERSION variable"
        return 0
    fi
    task "Must fetch the latest tag for tool: ${CPLX_TOOL}/${cplx_path}"
    if ! get_property "${CPLX_TOOL}_repository"; then
        fatal "Could not get the GitHub repository for tool '${CPLX_TOOL}'" 30
    fi
    repository=$(eval "echo \"\${${CPLX_TOOL}_repository}\"")
    info "Repository for tool '${CPLX_TOOL}' is '${repository}'"

    set -o pipefail
    gh=$(cygpath -u "${PRGS}/ghs/current/gh.exe")
    if [[ ! -e "${gh}" ]]; then gh="$(cygpath -u "${PRGS}/ghs/gh-cli/bin/gh.exe")"; fi
    if [[ ! -e "${gh}" ]]; then fatal "GitHub gh CLI not found in '$(cygpath -u "${PRGS}/ghs")'" 39; fi
    url=$("${gh}" api "repos/${repository}/tags" --jq ".[] | {name, zipball_url}" | awk -v "rc=false" -f "${SETUP_DIR}/zipball_url.awk")
    if [[ -z "${url}" ]]; then
        fatal "Could not get the latest tag for tool '${CPLX_TOOL}'" 40
    fi
    version=$(echo "${url}" | awk -F/ '{print $(NF)}')
    CPLX_VERSION="${version}"
    info "Latest tag for tool '${CPLX_TOOL}' is '${version}'"

    if ! step_done "get_the_version"; then
        fatal "Could not mark 'get_the_version' as done" 61
    fi
    ok "'get_the_version' is done"
}

function get_resource_extension() {
    if [[ -z "${CPLX_SRC_EXT}" ]]; then
        echo "zip"
        return 0
    fi
    echo "${CPLX_SRC_EXT}"
}

download_sources() {
    if [[ ${version} == "" ]]; then version="${CPLX_VERSION}"; fi
    if [[ ${version} == "" ]]; then
        fatal "download_sources: version should be defined at this point" 42
    fi

    if [[ -z "${url}" && -z "${CPLX_URL}" ]]; then
        fatal "URL not defined for tool '${CPLX_TOOL}': set CPLX_URL in senv.local.bat" 43
    fi

    if [[ -n "${CPLX_URL}" ]]; then
        url="${CPLX_URL}"
        url="${url//\[version\]/${version}}"
        info "Set URL to CPLX_URL, using CPLX_VERSION to replace any '[version]': '${url}'"
    fi

    url_ext=$(get_resource_extension)

    sources="${SETUP_DIR}/sources/${CPLX_TOOL}"
    mkdir -p "${sources}"
    if [[ -e "${sources}/${CPLX_TOOL}-src-${version}.${url_ext}" ]]; then
        ok "Sources '${version}' already fetched for tool '${CPLX_TOOL}'"
    else
        task "Must fetch sources for tool '${CPLX_TOOL}'"
        if ! curl -kL -o "${sources}/${CPLX_TOOL}-src-${version}.${url_ext}" "${url}"; then
            fatal "Could not fetch sources for tool '${CPLX_TOOL}' at url '${url}'" 41
        fi
        ok "Sources fetched for tool '${CPLX_TOOL}' at version '${version}'"
    fi
    if ! step_done "download_sources"; then
        fatal "Could not mark 'download_sources' as done" 62
    fi
    ok "'download_sources' is done"
}

main "$@"

