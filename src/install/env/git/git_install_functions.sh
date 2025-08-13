#!/bin/bash

function git_setenv() {
    # shellcheck disable=SC2154
    export M4="${root}/usr/bin/m4"
    info "M4 is set '${M4}' for autom4te to use it"
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

    # shellcheck disable=SC2154
    LDFLAGS="${LDFLAGS} -L${root}/usr/lib/gcc/x86_64-redhat-linux/4.8.5"

    # Build the configure command as an array
    local configure_cmd=(
        "${tool_src}/configure"
        "--prefix=${tool_prefix}"
        "--with-openssl=${root}/usr"
        "--with-libsecret"
    )

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
    get_property CPLX_CHECK_SRC
    if [[ -z ${CPLX_CHECK_SRC} ]]; then
        fatal "CPLX_CHECK_SRC is not set" 20
    fi
    if [[ ! -e "${CPLX_CHECK_SRC}" ]]; then
        task "Must make all in '$(pwd)' (CPLX_CHECK_SRC='${CPLX_CHECK_SRC}' is missing in '$(pwd)')"
        make all || fatal "Unable to make in '$(pwd)'" 19
        ok "make all is now done in '$(pwd)'"
    else
        ok "${CPLX_TOOL} already compiled in '$(pwd)' (CPLX_CHECK_SRC='${CPLX_CHECK_SRC}' is there)"
    fi
    pre_build_doc
    cd "${tool_src}/Documentation" || fatal "git build: Unable to access '${tool_src}/Documentation'" 163
    make || fatal "Unable to make (doc) in '$(pwd)'" 21
    make install || fatal "Unable to install (doc) in '$(pwd)'" 22
}

function pre_build_doc() {
    if [[ -e "${tool_src}/Documentation/pre_build_done" ]]; then
        ok "pre_build_doc already done, nothing to do"
        return 0
    fi
    nb_imports=$(grep -nRHE "import.*http://" "${tool_src}/Documentation"/** 2>/dev/null | wc -l)
    if [[ ${nb_imports} == 0 ]]; then
        ok "pre_build_doc: All Documentation imports paths already changed to '${root}/usr/share/sgml/docbook/current/'"
    else
        task "pre_build_doc: Must update '${nb_imports}' paths in '${tool_src}/Documentation'"
        files=$(grep -nRHE "import.*http://" "${tool_src}/Documentation"/** 2>/dev/null | awk -F : '{print $1;}' | sort -n | uniq)
        update_import_ko=0
        update_import_ok=0
        while IFS= read -r file; do
            if ! sed -i "s,http:.*/current/,${root}/usr/share/sgml/docbook/current/,g" "${file}"; then
                error "pre_build_doc: issue when updating import path to '${root}/usr/share/sgml/docbook/current/' for file '${file}'"
                ((update_import_ko++))
            else
                ((update_import_ok++))
            fi
        done <<<"${files}"
        if [[ ${update_import_ko} != 0 ]]; then
            fatal "pre_build_doc: issue for '${update_import_ko}' file(s) when updating import path to '${root}/usr/share/sgml/docbook/current/'" 153
        fi
        ok "pre_build_doc: all '${update_import_ok}' file(s) successfully updated import path to '${root}/usr/share/sgml/docbook/current/'"
    fi
    task "pre_build_doc: Must update Documentation/Makefile manpage-cmd to reference local xmlto man"
    if ! sed -i "s,^manpage-cmd = \(.*) \).*man ,manpage-cmd = \1--skip-validation ${root}/usr/share/xmlto/format/docbook/man ,g" "${tool_src}/Documentation/Makefile"; then
        fatal "pre_build_doc: Unable to update Documentation/Makefile manpage-cmd to reference local xmlto man" 158
    fi
    ok "pre_build_doc: Documentation/Makefile manpage-cmd updated successfully to reference local xmlto man"
    touch "${tool_src}/Documentation/pre_build_done"
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
