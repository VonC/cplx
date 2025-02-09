#!/bin/bash

function configure() {
    task "config.log not present: reconfigure"
    if ! "${tool_src}/configure" --prefix="${tool_bin}" --with-openssl="${tool_bin}/usr" --with-openssl-rpath="${tool_bin}/usr/lib64" --enable-shared=yes; then
        fatal "configure ERROR" 3
    fi
    ok "configure done"
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

function setenv() {

    export tools="${HOME}/tools/$1"
    export tool_bin="${tools}/python-$2"
    export tool_src="${tools}/sources/current"
    export root="${HOME}/tools/root"

    export LD_LIBRARY_PATH="${root}/usr/lib64:${root}/usr/lib:${root}/lib64:${tool_bin}/usr/lib64:${tool_bin}/lib64"
    export PKG_CONFIG_PATH="${tool_bin}/usr/lib64/pkgconfig"
}
