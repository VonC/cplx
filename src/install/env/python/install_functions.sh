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
    rm python || fatal "Unable to remove python in '$(pwd)'" 5
    ok "Clean done"
}

function install() {
    if [[ ! -e "${tool_prefix}" ]]; then
        mkdir -p "${tool_prefix}" || fatal "Unable to create '${tool_prefix}'" 17
        # shellcheck disable=SC2154
        info "Created '${tool_prefix}': install '${tool_name}' needed"
    fi
    # check if "${tool_prefix}/lib/libpython3.so" exists, and if it is newer than "${tool_src}/libmpdec/libpython3.so": if so, _must_install=1
    local file_check_prefix
    local file_check_src
    file_check_prefix="lib/libpython3.so"
    file_check_src="libpython3.so"
    if [[ -e "${tool_prefix}/${file_check_prefix}" ]]; then
        if [[ "${tool_prefix}/${file_check_prefix}" -nt "${tool_src}/${file_check_src}" ]]; then
            ok "No need to install '${tool_name}' in '${tool_prefix}': '${file_check_prefix}' newer than '${tool_src}/${file_check_src}'"
            return 0
        else
            info "'${file_check_prefix}' is older than '${tool_src}/${file_check_src}': install '${tool_name}' in '${tool_prefix}'"
        fi
    else
        info "No '${file_check_prefix}' in '${tool_prefix}': install '${tool_name}' in '${tool_prefix}'"
    fi
    task "Must cleanup '${tool_prefix}' first:"
    rm -Rf "${tool_prefix:?}/*" || fatal "Unable to remove '${tool_prefix} content'" 18
    task "Must install '${tool_name}' in '${tool_prefix}'"
    make install || fatal "Unable to make install in '${tool_prefix}'" 19
    ok "make install is now done in '${tool_prefix}'"
}


function package() {
    local package_name
    local package_name_prefix
    package_name_prefix=$(basename "${tool_prefix}")
    if [[ -z "${package_name_prefix}" ]]; then
        warning "No current symlink in '${tool_prefix}', no package"
        return 1
    fi
    get_property CPLX_ARCH_EXT
    if [[ -z "${CPLX_ARCH_EXT}" ]]; then
        fatal "No CPLX_ARCH_EXT defined (like 'el8.x86_64'), unable to package '${tool_name}'" 18
    fi
    package_name="${package_name_prefix}-0.${CPLX_ARCH_EXT}.tar.gz"

    local file_check_prefix
    file_check_prefix="lib/libpython3.so"
    # shellcheck disable=SC2154
    if [[ -e "${tool}/${package_name}" ]]; then
        if [[ "${tool}/${package_name}" -nt "${tool_prefix}/${file_check_prefix}" ]]; then
            ok "No need to package '${tool_name}' in '${package_name}': package newer than '${file_check_prefix}'"
            return 0
        else
            info "Package '${package_name}' is older than '${file_check_prefix}': package '${tool_name}' in '${package_name}'"
        fi
    else
        info "No package '${package_name}' in '${tool}': package '${tool_name}' in '${package_name}'"
    fi
    task "Must package '${tool_name}' in '${package_name}'"
    tar czf "${tool}/${package_name}" -C "${tool_prefix}" . || fatal "Unable to package '${tool_name}' in '${package_name}'" 19
    ok "Package is now done in '${package_name}'"
}