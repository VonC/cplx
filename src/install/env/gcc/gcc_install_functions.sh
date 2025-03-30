#!/bin/bash

function gcc_setenv() {
    # shellcheck disable=SC2154
    # export CPPFLAGS="${CPPFLAGS} -I${tool_src}/gcc/ginclude"
    export CPPFLAGS="${CPPFLAGS} -I${root}/usr/lib/gcc/x86_64-redhat-linux/4.8.2/include"

    # shellcheck disable=SC2154
    # LDFLAGS="${LDFLAGS} -L${root}/usr/lib/gcc/x86_64-redhat-linux/4.8.2 -L${root}/usr/libexec/gcc/x86_64-redhat-linux/4.8.2"
    export LDFLAGS
}

function configure() {
    task "config.log not present: reconfigure"

    if [[ ! -e configure ]]; then
        task "Must make configure in '$(pwd)'"
        make configure || fatal "Unable to make configure in '$(pwd)'" 15
        ok "'configure' is now created in '$(pwd)'"
    else
        ok "'configure' is present in '$(pwd)'"
    fi
    
    # Build the configure command as an array
    local configure_cmd=( 
        "${tool_src}/configure" \
        "--disable-multilib" \
        "--prefix=${tool_prefix}" \
    )

    sed -i "s,ssldir/lib\",ssldir/lib64\",g" configure || fatal "Unable to update 'configure' ssldir/lib to ssldir/lib64 in '$(pwd)'" 16

    # Display the command with its parameters.
    info "Running configure command: ${configure_cmd[*]}"

    objdir=$(readlink -f "${tool_src}/../build")

    mkdir -p "${objdir}" || fatal "Unable to create build directory '${objdir}'" 17
    cd "${objdir}" || fatal "Unable to change to build directory '${objdir}'" 18
    rm -f "${tool_src}/config.log"

    # Execute the configure command.
    if ! "${configure_cmd[@]}"; then
        fatal "configure ERROR" 199
    fi
    echo "creating Makefile" >> "${tool_src}/config.log"
    ln -nfs "${tool_src}/config.log" "${objdir}/config.log"
    ok "configure done"
}

function build() {

    objdir=$(readlink -f "${tool_src}/../build")
    cd "${objdir}" || fatal "Unable to change to build directory '${objdir}'" 180

    # Find all Makefiles that have a CPPFLAGS line with -I flags, then add the gcc include path if not already present
    # 1. Find all Makefiles in the current directory structure
    # 2. Filter for those containing "CPPFLAGS = -I"
    # 3. For each matching file, check if it already has the include path
    # 4. If not present, append the gcc include path to the CPPFLAGS line
    # shellcheck disable=SC2038
    find . -name Makefile | xargs grep -l "^CPPFLAGS = -I" | xargs -I {} sh -c 'grep -q "/usr/lib/gcc/x86_64-redhat-linux/4.8.2/include" {} || sed -i "/CPPFLAGS = -I/s,$, -I /usr/lib/gcc/x86_64-redhat-linux/4.8.2/include," {}'

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
    rm -Rf host-x86_64-unknown-linux-gnu
    rm -Rf build-x86_64-unknown-linux-gnu
    ok "Clean done"
}
