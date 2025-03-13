#!/bin/bash

function configure() {
    task "config.log not present: reconfigure"
    unset OPENSSL_LDFLAGS
    # https://wiki.openssl.org/index.php/Compilation_and_Installation#PREFIX_and_OPENSSLDIR

    #./Configure --prefix=/home/gitea2/cplx/tools/tool/root/usr --openssldir=/home/gitea2/cplx/tools/tool/root/usr/ssl --libdir=lib64 no-shared no-zlib no-async -DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2 linux-x86_64 -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared
    # Since LIBS seems ignored on ld steps...

    # Build the configure command as an array
    local configure_cmd=( "${tool_src}/config"
                          "--prefix=${tool_prefix}/usr"
                          "--openssldir=${tool_prefix}/usr"
                          "--libdir=lib64"
                          "shared"
                          "-v"
                          "-lgcc_s"
                          "-ldl"
                          "-lpthread"
                          "-lc"
                          "-lm"
                          "-lc_nonshared"
                        )


    # sed -i "s,ssldir/lib\",ssldir/lib64\",g" configure || fatal "Unable to update 'configure' ssldir/lib to ssldir/lib64 in '$(pwd)'" 16

    # Display the command with its parameters.
    # shellcheck disable=SC2154
    info "Running configure command for '${tool_name}': ${configure_cmd[*]}"
    rm -f "${tool_src}/Makefile" || fatal "${tool_name}: Unable to remove Makefile in '${tool_src}'" 16
    # Execute the configure command.
    if ! "${configure_cmd[@]}"; then
        fatal "configure ERROR" 199
    fi
    ok "configure done for '${tool_name}'"
}

function build() {
    unset OPENSSL_LDFLAGS
    local target
    target=""
    if [[ ! -e "libmpdec/sixstep.o" ]]; then
        task "Must make '${target}' in '$(pwd)' (avoid libcxx which needs g++)"
        #make -d v=1 -d DEVELOPER=1 all || fatal "Unable to make all in '$(pwd)'" 19
        if [[ -n "${target}" ]]; then
            make "${target}" || fatal "Unable to make '${target}' in '$(pwd)'" 19
        else
            make || fatal "Unable to make '${target}' in '$(pwd)'" 199
        fi
        ok "make '${target}' is now done in '$(pwd)'"
    else
        # shellcheck disable=SC2154
        ok "${tool_name} already compiled in '$(pwd)'"
    fi
}

function clean() {
    unset OPENSSL_LDFLAGS
    if [[ ! -e Makefile ]]; then
        ok "Skip clean, no Makefile in '$(pwd)'"
        return 0
    fi
    task "Must make clean"
    if ! make clean; then
        fatal "clean ERROR" 4
    fi
    if [[ -e xxx ]]; then
        rm xxx || fatal "Unable to remove xxx in '$(pwd)'" 5
    fi
    ok "Clean done"
}
