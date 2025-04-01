#!/bin/bash

function make4_setenv() {
    # shellcheck disable=SC1091
    # shellcheck disable=SC2154
    source "${tools}/update_path_variables.sh"
    if ! declare -f update_path_variable >/dev/null 2>&1; then
        fatal "No path var function present" 117
    fi
    # shellcheck disable=SC2154
    if [[ ! -e "${tools}/automake116/current/bin/automake" ]]; then
        fatal "No automake116 present at" 118
    fi
    # shellcheck disable=SC2154
    update_path_variable "PATH" "${tools}/automake116/current/bin"
    info "make4: PATH update with automake116/current/bin: '${PATH}'"
    # shellcheck disable=SC2154
    update_path_variable "PERLLIB" "${tools}/automake116/current/share/automake-1.16"
    info "make4: PATH update with automake116/current/share/automake-1.16: '${PERLLIB}'"

    # shellcheck disable=SC2154
    if ! grep "${tools}" "${root}/usr/bin/autopoint" >/dev/null 2>&1; then
        task "make4_setenv: must patch autopoint /usr"
        if ! sed -i "s,/usr,${tools}/tool/root/usr,g" "${root}/usr/bin/autopoint"; then
            fatal "make4_setenv: unable to patch autopoint" 119
        else
            ok "make4_setenv: autopoint patched"
        fi
    else
        ok "make4_setenv: autopoint already patched"
    fi
}

function configure() {
    task "config.log not present: reconfigure"

    if [[ ! -e configure ]]; then
        task "Must make configure in '$(pwd)': bootstrap"
        # shellcheck disable=SC2154
        "${tool_src}/bootstrap" || fatal "Unable to bootstrap in '$(pwd)'" 15
        ok "'configure' is now created in '$(pwd)'"
    else
        ok "'configure' is present in '$(pwd)'"
    fi
    
    # Build the configure command as an array
    local configure_cmd=( 
        "${tool_src}/configure" \
        "--prefix=${tool_prefix}" \
        "--with-guile=no" \
    )

    sed -i "s,ssldir/lib\",ssldir/lib64\",g" configure || fatal "Unable to update 'configure' ssldir/lib to ssldir/lib64 in '$(pwd)'" 16

    # Display the command with its parameters.
    info "Running configure command: ${configure_cmd[*]}"

    # Execute the configure command.
    if ! "${configure_cmd[@]}"; then
        fatal "configure ERROR" 199
    fi
    ok "configure done"
}

function build() {
    get_property CPLX_CHECK_SRC
    if [[ -z ${CPLX_CHECK_SRC} ]]; then
        fatal "CPLX_CHECK_SRC is not set" 20
    fi
    if [[ ! -e "${CPLX_CHECK_SRC}" ]]; then
        task "Must make in '$(pwd)' (CPLX_CHECK_SRC='${CPLX_CHECK_SRC}' is missing in '$(pwd)')"
        make || fatal "Unable to make in '$(pwd)'" 19
        ok "make is now done in '$(pwd)'"
    else
        ok "${CPLX_TOOL} already compiled in '$(pwd)' (CPLX_CHECK_SRC='${CPLX_CHECK_SRC}' is there)"
    fi
}

function clean() {
    if [[ ! -e Makefile ]]; then
        ok "Skip clean, no Makefile in '$(pwd)'"
        return 0
    fi
    task "Must make clean"
    if ! make clean; then
        fatal "clean ERROR" 4
    fi
    ok "Clean done"
}
