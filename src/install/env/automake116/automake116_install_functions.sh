#!/bin/bash

function glibc_setenv() {
    # shellcheck disable=SC1091
    # shellcheck disable=SC2154
    source "${tools}/update_path_variables.sh"
    if ! declare -f update_path_variable >/dev/null 2>&1; then
        fatal "No path var function present" 117
    fi
    
    # Update .autom4te.cfg to include our autoconf path
    # shellcheck disable=SC2154
    local autom4te_cfg="${tool_src}/.autom4te.cfg"
    # shellcheck disable=SC2154
    local autoconf_path="${root}/usr/share/autoconf"
    local section_start="begin-language: \"Autoconf-without-aclocal-m4\""
    local section_end="end-language: \"Autoconf-without-aclocal-m4\""
    local args_line="args: --prepend-include ${autoconf_path}"
    
    # Check if the file exists
    if [[ -f "${autom4te_cfg}" ]]; then
        # Check if the section is already present
        if ! grep -q "prepend-include" "${autom4te_cfg}"; then
            task "Adding autoconf include path to ${autom4te_cfg}"
            # Append the section to the file
            cat >> "${autom4te_cfg}" << EOF
${section_start}
${args_line}
${section_end}
EOF
            ok "Updated ${autom4te_cfg} with autoconf include path"
        else
            ok "${autom4te_cfg} already contains the required prepend-include configuration"
        fi
    else
        fatal "${autom4te_cfg} not found" 118
    fi
}

function configure() {
    task "config.log not present: reconfigure"

    if [[ ! -e configure ]]; then
        task "Must make configure in '$(pwd)': bootstrap"
        "${tool_src}/bootstrap" || fatal "Unable to bootstrap in '$(pwd)'" 15
        ok "'configure' is now created in '$(pwd)'"
    else
        ok "'configure' is present in '$(pwd)'"
    fi
    
    # Build the configure command as an array
    local configure_cmd=( 
        "${tool_src}/configure" \
        "--prefix=${tool_prefix}" \
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
