#!/bin/bash

function configure() {
    task "config.log not present: reconfigure"

    if [[ ! -e configure ]]; then
        task "Must make configure in '$(pwd)'"
        make configure || fatal "Unable to make configure in '$(pwd)'" 15
        ok "'configure' is now created in '$(pwd)'"
    else
        ok "'configure' is present in '$(pwd)'"
    fi

    # shellcheck disable=SC2154
    LDFLAGS="${LDFLAGS} -L${root}/usr/lib/gcc/x86_64-redhat-linux/4.8.5"
    
    # Build the configure command as an array
    local configure_cmd=( 
        "${tool_src}/configure" \
        "--prefix=${tool_prefix}" \
        "--with-openssl=${root}/usr" \
        "--with-libsecret" \
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
        task "Must make all in '$(pwd)' (CPLX_CHECK_SRC='${CPLX_CHECK_SRC}' is missing in '$(pwd)')"
        make all || fatal "Unable to make in '$(pwd)'" 19
        ok "make all is now done in '$(pwd)'"
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
