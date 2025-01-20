#!/bin/bash
# shellcheck source-path=SCRIPTDIR

SETUP_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# echo "SETUP_DIR='${SETUP_DIR}'"
source "${SETUP_DIR}/../echos/echos"
source "${SETUP_DIR}/../utils/properties.sh"
source "${SETUP_DIR}/../utils/steps.sh"

main() {
    steps_file="${SETUP_DIR}/steps.md"
    properties_file="${SETUP_DIR}/setup.properties"
    validate-the-ssh-connection "$@"
    scp-env "$@"
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

