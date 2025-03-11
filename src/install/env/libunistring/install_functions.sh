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

    # In case they appear separately or in different order
    LDFLAGS="${LDFLAGS//-lssl/}"
    LDFLAGS="${LDFLAGS//-lcrypto/}"

    # Clean up any double spaces that might have been created
    LDFLAGS="${LDFLAGS//  / }"

    # Export the new LDFLAGS
    export LDFLAGS
    
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
    if [[ ! -e "lib/libunistring.la" ]]; then
        task "Must make in '$(pwd)'"
        make || fatal "Unable to make in '$(pwd)'" 19
        ok "make is now done in '$(pwd)'"
    else
        ok "${CPLX_TOOL} already compiled in '$(pwd)'"
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
