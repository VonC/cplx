#!/bin/bash

function configure() {
    task "config.log not present: reconfigure"

    # Build the configure command as an array
    local configure_cmd=( env \
        "LIBMPDEC_CFLAGS=-I${root}/include -DCONFIG_64=1 -DANSI=1 -DHAVE_UINT128_T=1" \
        "LIBMPDEC_LIBS=-L${root}/lib -lmpdec -L${root}/lib64 -lm -L${root}/usr/lib/gcc/x86_64-redhat-linux/8 -lgcc_s " \
        "${tool_src}/configure" \
        "--prefix=${tool_prefix}" \
        "--with-openssl=${root}/usr" \
        "--with-openssl-rpath=${root}/usr/lib64" \
        "--enable-shared=yes" \
        "--with-system-libmpdec=yes" )

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
    if [[ ! -e git-add && ! -e python ]]; then
        task "Must make all in '$(pwd)'"
        #make -d v=1 -d DEVELOPER=1 all || fatal "Unable to make all in '$(pwd)'" 19
        make all || fatal "Unable to make all in '$(pwd)'" 19
        ok "make all is now done in '$(pwd)'"
    else
        ok "python already compiled in '$(pwd)'"
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
    rm -f python || fatal "Unable to remove python in '$(pwd)'" 5
    ok "Clean done"
}
