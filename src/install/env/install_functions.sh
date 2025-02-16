#!/bin/bash

function setenv() {

    export tools="${HOME}/tools"
    export tool="${tools}/tool"
    tool_prefix="$(readlink -f "${tool}/current")"
    export tool_prefix
    export tool_src="${tool}/sources/current"
    export root="${tool}/root"

    export LD_LIBRARY_PATH="${root}/usr/lib64:${root}/usr/lib:${root}/lib64:${root}/lib:${tool_prefix}/usr/lib64:${tool_prefix}/lib64:${tool_prefix}/usr/lib:${tool_prefix}/lib"

    export PKG_CONFIG_PATH="${tool_prefix}/usr/lib64/pkgconfig"
    if [[ -e "${tool_prefix}/bin" ]]; then
        # Wrap PATH in colons for the check so that boundaries are properly detected,
        # even if PATH does not end with a colon.
        if [[ ":$PATH:" != *":${tool_prefix}/bin:"* ]]; then
            export PATH="${PATH}:${tool_prefix}/bin"
        fi
    fi

    export AUTOM4TE="${root}/usr/bin/autom4te"
    export PERLLIB="${PERLLIB}:${root}/usr/share/autoconf:${root}/usr/lib64/perl5/vendor_perl"
    export AUTOM4TE_CFG="${root}/usr/share/autoconf/autom4te.cfg"
    export autom4te_perllibdir="${root}/usr/share/autoconf"
    export AC_MACRODIR="${root}/usr/share/autoconf"
    if [[ -e "${root}/usr/share/autoconf/autom4te.cfg" ]]; then
        sed -i "s,prepend-include.*,prepend-include '${root}/usr/share/autoconf',g" "${root}/usr/share/autoconf/autom4te.cfg" || fatal "unable to update '${root}/usr/share/autoconf/autom4te.cfg' prepend-include directive" 17
    fi
    export COMPILER_PATH=""
    update_xxpath "COMPILER_PATH" "cc1"
    export COMPILER_PATH

    # export LD_LIBRARY_PATH=""
    # update_xxpath "LD_LIBRARY_PATH" "libmpc.so.?"
    # update_xxpath "LD_LIBRARY_PATH" "libmpfr.so.?"
    # update_xxpath "LD_LIBRARY_PATH" "crti.o"
    # update_xxpath "LD_LIBRARY_PATH" "libopcodes*"
    # update_xxpath "LD_LIBRARY_PATH" "libSegFault.so"
    # update_xxpath "LD_LIBRARY_PATH" "ld-2.17.so"
    export LD_LIBRARY_PATH
    export LIBRARY_PATH="${LD_LIBRARY_PATH}"
    export LD_RUN_PATH="${LD_LIBRARY_PATH}"
    export DT_RUNPATH="${LD_LIBRARY_PATH}"
    export GCC_PATH="${root}"
    export CPPFLAGS="-I${GCC_PATH}/usr/include"

    local ldpaths
    update_xxpath "ldpaths" "libc_nonshared.a"
    #local ldlinpath
    #update_xxpath "ldlinpath" "ld-linux-x86-64.so.2"
    export CFLAGS="-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=${root} -fPIC -O -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2"
    export ZLIB_PATH="${root}/usr"
    export CURLDIR="${root}/usr"
    export OPENSSLDIR="${root}/usr"
    export OPENSSL_LDFLAGS="-L${root}/usr/lib64"
    export LIBPCREDIR="${root}/usr"
    #export LDFLAGS="-L$CURLDIR/lib64 -L$OPENSSLDIR/lib64 -L$LIBPCREDIR/lib64 -L${ldpaths}"
    #export LDFLAGS="-L${ldpaths} -L${root}/lib64 -nodefaultlibs -Wl,--export-dynamic,--dynamic-linker=${ldlinpath}/ld-linux-x86-64.so.2"
    # https://stackoverflow.com/questions/6562403/i-dont-understand-wl-rpath-wl
    export LDFLAGS="-L${ldpaths} -L${root}/usr/lib64 -L${root}/usr/lib -L${root}/lib64 -L${root}/lib -L${root}/usr/lib/gcc/x86_64-redhat-linux/8 -nodefaultlibs -Wl,-rpath,${ldpaths}:${root}/usr/lib64:${root}/usr/lib:${root}/lib64:${root}/lib -Wl,--export-dynamic -lc_nonshared -ldl -lgcc_s -lc -lm -lc_nonshared -lpthread -B${root} -B${root}/usr -B${root}/usr/lib64 -B${root}/usr/lib -B${root}/lib64 -B${root}/lib --sysroot=${root}"
    #export LIBS="-lc -ldl -l:libc_nonshared.a -lc_nonshared -lc"
    #export LIBS="-lc_nonshared -lc -lc_nonshared -lm"
    export LIBS="-Wl,-rpath,${ldpaths}:${root}/lib64:${root}/lib:${root}/usr/lib64:${root}/usr/lib -Wl,--export-dynamic -lc_nonshared -ldl -lc -lm -lc_nonshared -lpthread"

    local elibs
    elibs="-lm -lc -lpthread"
    if [[ -e "${tool_src}/Makefile" ]]; then
        sed -i "s/^EXTLIBS =.*\?$/EXTLIBS = ${elibs}/g" "${tool_src}/Makefile" || fatal "Unable to update '${tool_src}/Makefile' EXTLIBS with '${elibs}' in '$(pwd)'" 18 # -lintl
        info "Makefile EXTLIBS updated with '${elibs}'"
    fi

    if [[ ! -e "${tool}/install_functions.sh" ]]; then
        fatal "Missing '${tool}/install_functions.sh' file" 20
    fi
    source "${tool}/install_functions.sh" || fatal "Unable to source '${tool}/install_functions.sh'" 21
    if ! declare -f configure &>/dev/null; then
        fatal "Missing 'configure' function in '${tool}/install_functions.sh'" 22
    fi
    if ! declare -f clean &>/dev/null; then
        fatal "Missing 'clean' function in '${tool}/install_functions.sh'" 23
    fi
    if ! declare -f build &>/dev/null; then
        fatal "Missing 'build' function in '${tool}/install_functions.sh'" 24
    fi
}

#-------------------------------------------------------------------------
# Function: update_xxpath
#
# Purpose:
#   This function updates an environment (or shell) variable that holds a series of
#   colon-separated paths (e.g., LD_LIBRARY_PATH or COMPILER_PATH). It does so by:
#
#   1. Searching the directory "${root}" for a file matching a given search
#      pattern (query).
#   2. Extracting the directory that contains this file.
#   3. Prepending that directory to the specified variable, provided it is not already
#      included.
#
#   By ensuring the required directory is at the beginning of the variable, tools like
#   gcc or ld can find the necessary files during compilation/linking.
#
# Why use `printf -v`?
#   'printf -v' is used for its ability to directly format and assign a string to a variable.
#   This method is safer than using command substitution because it avoids issues with word
#   splitting and preserves the exact string structure, without spawning a separate subshell.
#-------------------------------------------------------------------------
function update_xxpath() {
    # The first argument is the name of the variable (e.g., LD_LIBRARY_PATH) to update.
    local name
    name="${1}"

    # The second argument is the pattern (query) used to find the desired file (e.g., "cc1").
    local query
    query="${2}"

    # Search for a file matching the query under "${root}". If not found, call fatal.
    local libp
    libp="$(find "${root}" -name "${query}" || fatal "${query} missing for '${name}' in '${root}'" 41)"

    # Extract the directory part of the found file’s path.
    libp="$(dirname "${libp}")"

    # Retrieve the current value of the variable referenced by name using indirect expansion.
    avalue="${!name}"

    # Check if the variable already starts with the directory (libp).
    # Parameter expansion here strips libp plus a trailing colon if present.
    # If the stripped value is not equal to the original, libp is already prepended.
    if [[ "${avalue#"${libp}":}" != "${avalue}" ]]; then
        return 0
    fi

    # Also, if the whole variable exactly equals libp, no update is necessary.
    if [[ "${avalue}" == "${libp}" ]]; then
        return 0
    fi

    # If the variable is empty, simply assign the new directory.
    if [[ "${avalue}" == "" ]]; then
        # 'printf -v' is used here to directly assign the formatted string to the variable named in $name.
        # This avoids additional commands that might cause word splitting or subshell execution.
        printf -v "$name" "%s" "${libp}"
    else
        # Otherwise, prepend the new directory (libp) to the existing paths, separated by a colon.
        printf -v "$name" "%s:%s" "${libp}" "${!name}"
    fi

    # Note: The export of the variable is left to the caller if needed.
}