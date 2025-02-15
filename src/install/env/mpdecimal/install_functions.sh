#!/bin/bash

function configure() {
    task "config.log not present: reconfigure"

    # Build the configure command as an array
    local configure_cmd=( "${tool_src}/configure"
                          "--prefix=${tool_prefix}"
                          "--with-openssl=${root}/usr"
                          "--with-openssl-rpath=${root}/usr/lib64"
                          "--enable-shared=yes"
                          "--enable-cxx=no" )

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
    local target
    target="lib"
    if [[ ! -e "libmpdec/sixstep.o" ]]; then
        task "Must make '${target}' in '$(pwd)' (avoid libcxx which needs g++)"
        #make -d v=1 -d DEVELOPER=1 all || fatal "Unable to make all in '$(pwd)'" 19
        make ${target} || fatal "Unable to make '${target}' in '$(pwd)'" 19
        ok "make '${target}' is now done in '$(pwd)'"
    else
        ok "mpdecimal already compiled in '$(pwd)'"
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
    if [[ -e mpdecimal ]]; then
        rm mpdecimal || fatal "Unable to remove mpdecimal in '$(pwd)'" 5
    fi
    ok "Clean done"
}

function install() {
    if [[ ! -e "${tool_prefix}" ]]; then
        mkdir -p "${tool_prefix}" || fatal "Unable to create '${tool_prefix}'" 17
        info "Created '${tool_prefix}': install 'mpdecimal' needed"
    fi
    # check if "${tool_prefix}/lib/libmpdec.so" exists, and if it is newer than "${tool_src}/libmpdec/libmpdec.so": if so, _must_install=1
    if [[ -e "${tool_prefix}/lib/libmpdec.so" ]]; then
        if [[ "${tool_prefix}/lib/libmpdec.so" -nt "${tool_src}/libmpdec/libmpdec.so" ]]; then
            ok "No need to install 'mpdecimal' in '${tool_prefix}': lib/libmpdec.so newer than '${tool_src}/libmpdec/libmpdec.so'"
            return 0
        else
            info "lib/libmpdec.so is older than '${tool_src}/libmpdec/libmpdec.so': install 'mpdecimal' in '${tool_prefix}'"
        fi
    else
        info "No lib/libmpdec.so in '${tool_prefix}': install 'mpdecimal' in '${tool_prefix}'"
    fi
    task "Must install 'mpdecimal' in '${tool_prefix}'"
    make install || fatal "Unable to make install in '${tool_prefix}'" 19
    ok "make install is now done in '${tool_prefix}'"
}

function archive() {
    local archive_name
    local archive_name_prefix
    archive_name_prefix=$(basename "${tool_prefix}")
    if [[ -z "${archive_name_prefix}" ]]; then
        warning "No current symlink in '${tool_prefix}', no archive"
        return 1
    fi
    get_property CPLX_ARCH_EXT
    if [[ -z "${CPLX_ARCH_EXT}" ]]; then
        fatal "No CPLX_ARCH_EXT defined (like 'el8.x86_64'), unable to archive 'mpdecimal'" 18
    fi
    archive_name="${archive_name_prefix}-0.${CPLX_ARCH_EXT}.tar.gz"
    # shellcheck disable=SC2154
    if [[ -e "${tool}/${archive_name}" ]]; then
        if [[ "${tool}/${archive_name}" -nt "${tool_prefix}/lib/libmpdec.so" ]]; then
            ok "No need to archive 'mpdecimal' in '${archive_name}': archive newer than lib/libmpdec.so"
            return 0
        else
            info "Archive '${archive_name}' is older than lib/libmpdec.so: archive 'mpdecimal' in '${archive_name}'"
        fi
    else
        info "No archive '${archive_name}' in '${tool}': archive 'mpdecimal' in '${archive_name}'"
    fi
    task "Must archive 'mpdecimal' in '${archive_name}'"
    tar czf "${tool}/${archive_name}" -C "${tool_prefix}" . || fatal "Unable to archive 'mpdecimal' in '${archive_name}'" 19
    ok "Archive is now done in '${archive_name}'"
}