#!/bin/bash
# shellcheck source-path=SCRIPTDIR

SETUP_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# echo "SETUP_DIR='${SETUP_DIR}'"
source "${SETUP_DIR}/../echos/echos"
source "${SETUP_DIR}/../utils/properties.sh"
source "${SETUP_DIR}/../utils/steps.sh"
SRC_DIR="$( cd "$( dirname "${SETUP_DIR}" )" && pwd )"

main() {
    steps_file="${SETUP_DIR}/steps.md"
    properties_file="${SETUP_DIR}/setup.properties"
    if [[ -n "${CPLX_REPEAT_STEP}" ]]; then
        info "CPLX_REPEAT_STEP is set to '${CPLX_REPEAT_STEP}': repeat those steps"
        task "Must repeat '${CPLX_REPEAT_STEP}'"
        if ! repeat_step "${CPLX_REPEAT_STEP}"; then
            fatal "Could not repeat '${CPLX_REPEAT_STEP}'" 111
        fi
        ok "Repeated '${CPLX_REPEAT_STEP}'"
    else
        info "CPLX_REPEAT_STEP is not set: no step to repeat"
    fi
    validate-the-ssh-connection "$@"
    scp-env "$@"
}

scp-env() {
    if step_is_done "copy-the-environment"; then
        ok "copy-the-environment is already done"
        return 0
    fi

    if step_is_done "create-the-remote-project-folder"; then
        ok "project_path '${project_path}' already created on '${hostname}'"
    else
        task "Must create remote project directory: ${hostname}/${project_path}"
        # shellcheck disable=SC2029
        ssh "${SSH_CONFIG_ENTRY}" "mkdir -p \"${project_path}/echos\"" || fatal "Could not create remote directory" 11
        if ! step_done "create-the-remote-project-folder"; then
            fatal "Could not mark create-the-remote-project-folder as done" 6
        fi
        ok "Remote directory '${project_path}' created on '${hostname}'"
    fi

    if step_is_done "transfer-env-to-the-remote-project-folder"; then
        ok "transfer-env-to-the-remote-project-folder is already done"
    else
        task "Must copy the environment to ${hostname}/${project_path}"
        set -o pipefail
        # Normalize any repeated slashes:
        normalized_path="$(echo "${SETUP_DIR}/env" | tr -s '/')"
        # Count the slashes to determine the number of components:
        component_count="$(echo "${normalized_path}" | grep -o '/' | wc -l)"
        normalized_path="$(echo "${SRC_DIR}/utils" | tr -s '/')"
        component_count_utils="$(echo "${normalized_path}" | grep -o '/' | wc -l)"

        # shellcheck disable=SC2029
        ( tar cvf - "${SETUP_DIR}/env/" | ssh "${SSH_CONFIG_ENTRY}" "tar xpvf - -C \"${project_path}\" --strip-components=${component_count}" ) || fatal "Could not copy environment" 11
        # shellcheck disable=SC2029
        ( tar cvf - "${SRC_DIR}/utils" | ssh "${SSH_CONFIG_ENTRY}" "tar xpvf - -C \"${project_path}/bin\" --strip-components=${component_count_utils}" ) || fatal "Could not copy utils environment" 12
        # shellcheck disable=SC2029
        ( tar cvf - "${SRC_DIR}/echos" | ssh "${SSH_CONFIG_ENTRY}" "tar xpvf - -C \"${project_path}/echos\" --strip-components=${component_count_utils}" ) || fatal "Could not copy echos environment" 13
        if ! step_done "transfer-env-to-the-remote-project-folder"; then
            fatal "Could not mark transfer-env-to-the-remote-project-folder as done" 6
        fi
        ok "Local env transferred to the Remote directory '${project_path}' on '${hostname}'"
    fi
    if ! step_done "transfer-env-to-the-remote-project-folder"; then
        fatal "Could not mark transfer-env-to-the-remote-project-folder as done" 6
    fi
    ok "copy-the-environment is done"
}

validate-the-ssh-connection() {
    if step_is_done "validate-the-ssh-connection"; then
        get_properties "SSH_CONFIG_ENTRY,hostname,project_path"
        ok "validate-the-ssh-connection is already done"
        info "SSH_CONFIG_ENTRY='${SSH_CONFIG_ENTRY}', hostname='${hostname}', project_path='${project_path}'"
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
        found && \$0 ~ (\"# \" host \"_cd\") {
        sub(\".*# \" host \"_cd[[:space:]]+\", \"\", \$0)
        sub(/[[:space:]]+\$/, \"\", \$0)
        print
        exit
        }
    ' ~/.ssh/config
    )\""

    # Access it via an intermediate variable
    eval "project_path=\"\${cd_${SSH_CONFIG_ENTRY}}\""

    if [[ -z "${project_path}" ]]; then
        fatal "No 'cd_${SSH_CONFIG_ENTRY}' found in SSH config under 'Host ${SSH_CONFIG_ENTRY}'" 4
    fi
    ok "Found cd_${SSH_CONFIG_ENTRY}='${project_path}'"
    set_property "SSH_CONFIG_ENTRY" "${SSH_CONFIG_ENTRY}"
    set_property "hostname" "${hostname}"
    set_property "project_path" "${project_path}"
    if ! step_done "validate-the-ssh-connection"; then
        fatal "Could not mark validate-the-ssh-connection as done" 5
    fi
    ok "validate-the-ssh-connection is done"
}

main "$@"

