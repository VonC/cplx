#!/bin/bash

function setenv() {

    export tools="${HOME}/tools"
    export tool="${tools}/tool"
    tool_prefix="$(readlink -f "${tool}/current")"
    export tool_prefix
    export tool_src="${tool}/sources/current"
    export root="${tool}/root"

    update_path "${root}/usr/bin"
    update_path "${root}/bin"

    # --- Library Paths ---
    # Use a single LD_LIBRARY_PATH, consistently constructed.
    export LD_LIBRARY_PATH="${root}/usr/lib64:${root}/usr/lib:${root}/lib64:${root}/lib:${tool_prefix}/usr/lib64:${tool_prefix}/lib64:${tool_prefix}/usr/lib:${tool_prefix}/lib"
    export LIBRARY_PATH="${LD_LIBRARY_PATH}"
    export LD_RUN_PATH="${LD_LIBRARY_PATH}"
    export DT_RUNPATH="${LD_LIBRARY_PATH}"

    # --- pkg-config ---
    export PKG_CONFIG_PATH="${tool_prefix}/usr/lib64/pkgconfig:${tool_prefix}/lib/pkgconfig:${root}/usr/lib64/pkgconfig:${root}/lib/pkgconfig"

    # --- PATH (for binaries) ---
    if [[ -e "${tool_prefix}/bin" ]]; then
        # Wrap PATH in colons for the check so that boundaries are properly detected,
        # even if PATH does not end with a colon.
        if [[ ":$PATH:" != *":${tool_prefix}/bin:"* ]]; then
            export PATH="${PATH}:${tool_prefix}/bin"
        fi
    fi

    # --- autotools/autoconf ---
    export AUTOCONF="${root}/usr/bin/autoconf"
    export AUTOHEADER="${root}/usr/bin/autoheader"
    export AUTOMAKE="${root}/usr/bin/automake"
    export AUTOM4TE="${root}/usr/bin/autom4te"
    export PERLLIB="${PERLLIB}:${root}/usr/share/autoconf:${root}/usr/lib64/perl5/vendor_perl:${root}/usr/share/perl5:${root}/usr/share/perl5/vendor_perl:${root}/usr/share/automake-1.13"
    export AUTOM4TE_CFG="${root}/usr/share/autoconf/autom4te.cfg"
    export autom4te_perllibdir="${root}/usr/share/autoconf"
    export AC_MACRODIR="${root}/usr/share/autoconf"
    if [[ -e "${root}/usr/share/autoconf/autom4te.cfg" ]]; then
        sed -i "s,prepend-include.*,prepend-include '${root}/usr/share/autoconf',g" "${root}/usr/share/autoconf/autom4te.cfg" || fatal "unable to update '${root}/usr/share/autoconf/autom4te.cfg' prepend-include directive" 17
    fi

    # --- Compiler Paths ---
    # COMPILER_PATH is often used for include paths, not library paths.
    # Only look for cc1 if cpp package is installed
    if [[ -e "${root}/usr/bin/cpp" ]]; then
        local cc1_path
        cc1_path=$(find "${root}" -name "cc1" 2>/dev/null | head -n 1) # Find the FIRST cc1, handle not found. 2>/dev/null suppresses errors
        if [[ -n "$cc1_path" ]]; then
            COMPILER_PATH=$(dirname "$cc1_path")
            export COMPILER_PATH
        else
            fatal "cc1 not found in '${root}'" 18
        fi
    else
        info "Skipping cc1 check as cpp package is not installed"
    fi

    # --- Flags ---
    export GCC_PATH="${root}"
    export CPPFLAGS="-I${GCC_PATH}/usr/include -I${GCC_PATH}/include" # Include paths for the preprocessor.

    # CFLAGS: Correctly set sysroot, PIC, and optimization.
    export CFLAGS="-DOPENSSL_NO_KRB5 -DUSE_CURL_MULTI --sysroot=${root} -fPIC -O2 -U_FORTIFY_SOURCE -m64 -march=x86-64 -msse4.2" # Use -O2 for optimization

    # --- Dynamic Linker (Important!) ---
    local dynamic_linker
    dynamic_linker=$(find "${root}/lib64" -name 'ld-linux-x86-64.so*' -print 2>/dev/null | head -n1)
    if [[ -z "${dynamic_linker}" ]]; then
        dynamic_linker=$(find "${root}/usr" -name 'ld-linux-x86-64.so*' -print 2>/dev/null | head -n1)
    fi
    # shellcheck disable=SC2154
    if [[ -z "${SKIP_CC1_CHECK}" && -z "${dynamic_linker}" && "${tool_name}" != "glibc" ]]; then
        fatal "Unable to find dynamic linker in '${root}/lib64' (SKIP_CC1_CHECK not set)" 25
    fi
    if [[ -n "${dynamic_linker}" ]]; then
        dynamic_linker="-Wl,--dynamic-linker=${dynamic_linker}"
    fi

    # --- LDFLAGS (Crucial) ---
    # Construct LDFLAGS carefully.
    # https://stackoverflow.com/questions/6562403/i-dont-understand-wl-rpath-wl
    export LDFLAGS="-Wl,--sysroot=${root} \
                    -Wl,-rpath=${LD_LIBRARY_PATH} \
                    ${dynamic_linker} \
                    -Wl,--export-dynamic \
                    -L${root}/usr/lib64 -L${root}/usr/lib -L${root}/lib64 -L${root}/lib"
    # -lssl -lcrypto"
    # -Wl,-verbose"
    # Standard lib directories.
    # No -nodefaultlibs needed with a proper sysroot.
    # -B options are generally not needed when using --sysroot.

    # -lssl -lcrypto *MUST* be at the END of LIBS (or LDFLAGS, if that's where libs get added).
    export LIBS="-lgcc_s -ldl -lpthread -lc -lm -lc_nonshared" # Correct order, explicit libs.

    export ZLIB_PATH="${root}/usr"
    export CURLDIR="${root}"
    export OPENSSLDIR="${root}/usr"
    export OPENSSL_LDFLAGS="-L${root}/usr/lib64"
    export LIBPCREDIR="${root}/usr"

    # --- Makefile modification
    local elibs
    elibs="-lm -lc -lpthread"
    if [[ -e "${tool_src}/Makefile" ]]; then
        sed -i "s/^EXTLIBS =.*\?$/EXTLIBS = ${elibs}/g" "${tool_src}/Makefile" || fatal "Unable to update '${tool_src}/Makefile' EXTLIBS with '${elibs}' in '$(pwd)'" 18 # -lintl
        info "Makefile EXTLIBS updated with '${elibs}'"
    fi

    # --- Source tool-specific install functions ---
    # shellcheck disable=SC2154
    if [[ ! -e "${tool}/${tool_name}_install_functions.sh" ]]; then
        fatal "Missing '${tool}/${tool_name}_install_functions.sh' file" 20
    fi
    # shellcheck disable=SC1090
    # shellcheck disable=SC2154
    source "${tool}/${tool_name}_install_functions.sh" || fatal "Unable to source '${tool}/${tool_name}_install_functions.sh'" 21
    if ! declare -f configure &>/dev/null; then
        fatal "Missing 'configure' function in '${tool}/${tool_name}_install_functions.sh'" 22
    fi
    if ! declare -f clean &>/dev/null; then
        fatal "Missing 'clean' function in '${tool}/${tool_name}_install_functions.sh'" 23
    fi
    if ! declare -f build &>/dev/null; then
        fatal "Missing 'build' function in '${tool}/${tool_name}_install_functions.sh'" 24
    fi

    if declare -f "${tool_name}_setenv" &>/dev/null; then
        "${tool_name}_setenv"
    fi

    info "Final CPPFLAGS = '${CPPFLAGS}'"
    info "Final LDFLAGS  = '${LDFLAGS}'"
}

function update_path() {
    local folder
    folder="${1}"
    # Wrap PATH in colons for the check so that boundaries are properly detected,
    # even if PATH does not end with a colon.
    if [[ ":$PATH:" != *":${folder}:"* ]]; then
        export PATH="${PATH}:${folder}"
        info "Added '${folder}' to PATH (ii)."
    else
        ok "'${folder}' is already in the PATH (ii)."
    fi
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

    if [[ -z "${CPLX_CHECK_PREFIX}" ]]; then
        fatal "No CPLX_CHECK_PREFIX defined (element in installation directory), unable to install '${tool_name}'" 18
    fi

    if [[ -z "${CPLX_CHECK_SRC}" ]]; then
        fatal "No CPLX_CHECK_SRC defined (element in source directory), unable to install '${tool_name}'" 18
    fi

    file_check_prefix="${CPLX_CHECK_PREFIX}"
    file_check_src="${tool_src}/${CPLX_CHECK_SRC}"
    if [[ -e "${tool_src}/../build/${CPLX_CHECK_SRC}" ]]; then
        file_check_src=$(readlink -f "${tool_src}/../build/${CPLX_CHECK_SRC}")
    fi
    if [[ ! -e "${file_check_src}" ]]; then
        fatal "No '${file_check_src}'" 193
    fi
    if [[ -e "${tool_prefix}/${file_check_prefix}" ]]; then
        if [[ "${tool_prefix}/${file_check_prefix}" -nt "${file_check_src}" ]]; then
            ok "No need to install '${tool_name}' in '${tool_prefix}': '${file_check_prefix}' newer than '${file_check_src}'"
            return 0
        else
            info "'${file_check_prefix}' is older than '${file_check_src}': install '${tool_name}' in '${tool_prefix}'"
        fi
    else
        info "No '${file_check_prefix}' in '${tool_prefix}': install '${tool_name}' in '${tool_prefix}'"
    fi
    task "Must cleanup '${tool_prefix}' first:"
    # fatal "Stop before cleanup and install" 125
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
    if [[ -z "${CPLX_ARCH_EXT}" ]]; then
        fatal "No CPLX_ARCH_EXT defined (like 'el8.x86_64'), unable to package '${tool_name}'" 28
    fi

    # Store the function output in a variable
    package_name=$(find_package)
    find_pkg_status=$? # Capture the return code right after calling the function
    if [[ $find_pkg_status -ne 0 ]]; then
        package_name="${package_name_prefix}-$(date +'%Y%m%d.%H%M').${CPLX_ARCH_EXT}.tar.gz"
    fi
    if [[ -z "${CPLX_CHECK_PREFIX}" ]]; then
        fatal "No CPLX_CHECK_PREFIX defined (element in installation directory), unable to install '${tool_name}'" 18
    fi
    local file_check_prefix
    file_check_prefix="${CPLX_CHECK_PREFIX}"
    # shellcheck disable=SC2154
    if [[ -e "${tool}/${package_name}" ]]; then
        if [[ "${tool}/${package_name}" -nt "${tool_prefix}/${file_check_prefix}" ]]; then
            ok "No need to package '${tool_name}' in '${package_name}': package newer than '${file_check_prefix}'"
            return 0
        else
            info "Package '${package_name}' is older than '${file_check_prefix}': package '${tool_name}' in '${package_name}'"
            package_name="${package_name_prefix}-$(date +'%Y%m%d.%H%M').${CPLX_ARCH_EXT}.tar.gz"
        fi
    else
        info "No package '${package_name}' in '${tool}': package '${tool_name}' in '${package_name}'"
    fi
    task "Must package '${tool_name}' in '${package_name}'"
    tar czf "${tool}/${package_name}" -C "${tool_prefix}" . || fatal "Unable to package '${tool_name}' in '${package_name}'" 191
    ok "Package is now done in '${package_name}'"
}

function find_package() {
    local package_name_prefix
    package_name_prefix=$(basename "${tool_prefix}")

    if [[ -z "${package_name_prefix}" ]]; then
        warning "No current symlink in '${tool_prefix}', cannot find package"
        return 1
    fi

    if [[ -z "${CPLX_ARCH_EXT}" ]]; then
        fatal "No CPLX_ARCH_EXT defined (like 'el8.x86_64'), unable to find package for '${tool_name}'" 28
    fi

    # Find the most recent package matching the pattern
    local latest_package
    latest_package=$(find "${tool}/" -maxdepth 1 -type f -name "${package_name_prefix}-*.${CPLX_ARCH_EXT}.tar.gz" | sort -r | head -n 1)

    if [[ -z "${latest_package}" ]]; then
        warning "No package found for '${package_name_prefix}' with extension '${CPLX_ARCH_EXT}' in '${tool}'"
        return 1
    fi

    # Extract just the filename from the full path
    local package_name
    package_name=$(basename "${latest_package}")
    echo "${package_name}"
    return 0
}

function deploy() {
    # Make sure the destination directory exists
    local pkgs_dir="${HOME}/tools/pkgs"
    mkdir -p "${pkgs_dir}" || fatal "Unable to create directory '${pkgs_dir}'" 30

    # Find the latest package
    local latest_package
    latest_package=$(find_package)
    find_pkg_status=$? # Capture the return code

    if [[ $find_pkg_status -ne 0 ]]; then
        fatal "No package found for deployment" 31
    fi

    # Extract just the filename from the full path
    local package_name
    package_name=$(basename "${latest_package}")
    local dest_file="${pkgs_dir}/${package_name}"
    latest_package="${tool}/${package_name}"

    # Check if the package is already in the destination directory
    if [[ -e "${dest_file}" ]]; then
        # Compare file sizes and modification times for a basic equality check
        if [[ "${dest_file}" -nt "${latest_package}" ]]; then
            ok "A more recent package '${package_name}' already exists in '${pkgs_dir}'"
            return 0
        else
            # Files exist with same name but are different - create a new version
            info "'${package_name}' found in '${pkgs_dir}' is older, updating it"
        fi
    fi

    # Copy the package to the destination
    task "Deploying package '${package_name}' to '${pkgs_dir}'"
    cp "${latest_package}" "${dest_file}" || fatal "Failed to copy '${package_name}' to '${pkgs_dir}'" 32
    ok "Package '${package_name}' successfully deployed to '${pkgs_dir}'"

    return 0
}
