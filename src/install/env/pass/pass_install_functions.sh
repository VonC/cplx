#!/bin/bash

function configure() {
    info "No config for pass"
    echo "creating Makefile" > config.log
    ok "configure done"
}

function build() {
    # shellcheck disable=SC2154
    PREFIX="${tool_prefix}"
    export PREFIX
    if [[ ! -e git-add && ! -e ${CPLX_TOOL} ]]; then
        task "Must make in '$(pwd)'"
        make || fatal "Unable to make in '$(pwd)'" 19
        ok "make is now done in '$(pwd)'"
    else
        ok "${CPLX_TOOL} already compiled in '$(pwd)'"
    fi
}

function clean() {
    # shellcheck disable=SC2154
    PREFIX="${tool_prefix}"
    export PREFIX
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
