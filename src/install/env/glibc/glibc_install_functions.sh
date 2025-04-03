#!/bin/bash

function glibc_setenv() {
    # shellcheck disable=SC1091
    # shellcheck disable=SC2154
    source "${tools}/update_path_variables.sh"
    if ! declare -f update_path_variable >/dev/null 2>&1; then
        fatal "No path var function present" 117
    fi
    # shellcheck disable=SC2154
    if [[ ! -e "${tools}/gcc/bin/gcc" ]]; then
        fatal "No gcc present at '${tools}/gcc/bin'" 118
    fi
    # shellcheck disable=SC2154
    update_path_variable "PATH" "${tools}/gcc/bin"
    info "glibc: PATH update with gcc/bin: '${PATH}'"
    export COMPILER_PATH="${tools}/gcc/bin"
    info "glibc: COMPILER_PATH update with gcc/bin: '${COMPILER_PATH}'"

    # shellcheck disable=SC2154
    if [[ ! -e "${tools}/make4/current/bin/make" ]]; then
        fatal "No make 4.x present at '${tools}/make4/current/bin'" 118
    fi

    # shellcheck disable=SC2154
    update_path_variable "PATH" "${tools}/make4/current/bin"
    info "glibc: PATH update with make4/current/bin: '${PATH}'"

    # Avoid the error:'bison: /usr/share/bison/m4sugar/m4sugar.m4: cannot open: No such file or directory'
    # shellcheck disable=SC2154
    export BISON_PKGDATADIR="${root}/usr/share/bison"

    # -g enables debug symbols, and -O2 is a standard optimization level often used with it.
    export CFLAGS="${CFLAGS} -g -O2"
    export CPPFLAGS="${CPPFLAGS} -g -O2"
    export CXXFLAGS="${CXXFLAGS} -g -O2" # Add CXXFLAGS too

    unset LD_LIBRARY_PATH

    # Save the original LDFLAGS for logging
    local original_ldflags="${LDFLAGS}"

    # Use sed-like pattern replacement to remove -Wl,-rpath=... up to the next -Wl
    # This handles both single-line and multi-line LDFLAGS with proper spacing
    LDFLAGS=$(echo "${LDFLAGS}" | sed -E 's/-Wl,-rpath=[^ ]* *(-Wl)/\1/g')
    LDFLAGS=$(echo "${LDFLAGS}" | sed -E 's/  */ /g')

    # no need for -lgcc_s -ldl -lpthread -lc -lm -lc_nonshared: they would be not found
    unset LIBS

    # Log the change
    info "Removed -Wl,-rpath from LDFLAGS"
    info "Original LDFLAGS: '${original_ldflags}'"
    info "Modified LDFLAGS: '${LDFLAGS}'"
}

function configure() {
    task "config.log not present: reconfigure"

    # shellcheck disable=SC2154
    objdir=$(readlink -f "${tool_src}/../build")

    mkdir -p "${objdir}" || fatal "Unable to create build directory '${objdir}'" 17
    cd "${objdir}" || fatal "Unable to change to build directory '${objdir}'" 18

    # shellcheck disable=SC2154
    if [[ ! -e "${tool_src}/configure" ]]; then
        task "Must make configure from '$(pwd)' for sources in '${tool_src}'"
        make configure || fatal "Unable to make configure in '$(pwd)'" 15
        ok "'configure' is now created in '${tool_src}'"
    else
        ok "'configure' is present in '${tool_src}'"
    fi
    
    # Build the configure command as an array
    local configure_cmd=( 
        "${tool_src}/configure" \
        "--prefix=${tool_prefix}" \
    )

    # sed -i "s,ssldir/lib\",ssldir/lib64\",g" configure || fatal "Unable to update 'configure' ssldir/lib to ssldir/lib64 in '$(pwd)'" 16

    # Display the command with its parameters.
    task "Must run configure command: ${configure_cmd[*]} from pwd '$(pwd)', should be objdir '${objdir}'"
    info "PATH='${PATH}'"
    info "which gcc=$(which gcc), gcc version: $(gcc --version)"

    rm -f "${tool_src}/config.log"
    ln "${objdir}/config.log" -nfs "${tool_src}/config.log"
    # Execute the configure command.
    if ! "${configure_cmd[@]}"; then
        fatal "configure ERROR" 199
    fi
    echo "creating Makefile" >> "${objdir}/config.log"
    ok "configure done"
}

function build() {

    objdir=$(readlink -f "${tool_src}/../build")
    cd "${objdir}" || fatal "Unable to change to build directory '${objdir}'" 180

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
