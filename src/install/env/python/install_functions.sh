#!/bin/bash

function configure() {
    task "config.log not present: reconfigure"

    # Build the configure command as an array
    local configure_cmd=( "${tool_src}/configure"
                          "--prefix=${tool_bin}"
                          "--with-openssl=${root}/usr"
                          "--with-openssl-rpath=${root}/usr/lib64"
                          "--enable-shared=yes" )

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

function setenv() {

    if [[ "$2" == "" ]]; then error "setenv() must be called with tool + version, i.e, 'python v3.13.1'"; return 1; fi
    export tools="${HOME}/tools/python"
    export tool_bin="${tools}/python-$2"
    ln -fs "${tool_bin}" "${tools}/current"
    export tool_src="${tools}/sources/current"
    export root="${HOME}/tools/root"

    export LD_LIBRARY_PATH="${root}/usr/lib64:${root}/usr/lib:${root}/lib64:${tool_bin}/usr/lib64:${tool_bin}/lib64:${tool_bin}/lib"

    export PKG_CONFIG_PATH="${tool_bin}/usr/lib64/pkgconfig"
    if [[ -e "${tool_bin}/bin" ]]; then
        if [[ "${PATH#*"${tool_bin}"/bin}" == "${PATH}" ]]; then
            export PATH="${PATH}:${tool_bin}/bin"
        fi
        python_exe=$(find "${tool_bin}/bin" -maxdepth 1 -type f -executable \
            -name 'python[0-9]*.[0-9][0-9]' 2>/dev/null | head -n 1)
        if [[ -n "${python_exe}" ]]; then
            ln -sf "${python_exe}" "${tool_bin}/bin/python"
            info "Created symlink: python -> $(basename "${python_exe}")"
        else
            warning "No versioned python executable found in ${tool_bin}"
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
    export LDFLAGS="-L${ldpaths} -L${root}/lib64 -nodefaultlibs -Wl,-rpath,${ldpaths}:${root}/lib64 -Wl,--export-dynamic -lc_nonshared -ldl -lgcc -lc -lm -lc_nonshared -lpthread -B${root}/usr  -B${root} -B${root}/usr/lib64 --sysroot=${root}"
    #export LIBS="-lc -ldl -l:libc_nonshared.a -lc_nonshared -lc"
    #export LIBS="-lc_nonshared -lc -lc_nonshared -lm"
    export LIBS="-Wl,-rpath,${ldpaths}:${root}/lib64 -Wl,--export-dynamic -lc_nonshared -ldl -lc -lm -lc_nonshared -lpthread"

    local elibs
    elibs="-lm -lc -lpthread"
    if [[ -e "${tool_src}/Makefile" ]]; then
        sed -i "s/^EXTLIBS =.*\?$/EXTLIBS = ${elibs}/g" "${tool_src}/Makefile" || fatal "Unable to update '${tool_src}/Makefile' EXTLIBS with '${elibs}' in '$(pwd)'" 18 # -lintl
        info "Makefile EXTLIBS updated with '${elibs}'"
    fi

    # To avoid the error:
    # configure:28229: error: --with-openssl-rpath "/home/vonc/cplx/tools/python/python-v3.13.1/usr/lib64" is not a directory
    mkdir -p "${tool_bin}/usr/lib64"
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