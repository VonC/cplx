#!/bin/bash

# Keep target policy with Python, using the driver's declared build family.
function python_sqlite_required() {
    [[ ${CPLX_ARCH_EXT:-} == el9.x86_64 ]]
}

# Check the selected build/prefix with the shared probe before packaging.
# Expectations come from the caller's tree and configured source artifacts.
function python_check_sqlite() {
    local stage=$1 python_tree source_tree prefix_tree executable extension_dir
    local provider probe libpython scratch status record line key value
    local -a records probe_args
    local -A config=()
    python_tree=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
    probe=$python_tree/sqlite_probe.py
    provider=$python_tree/root/usr/lib64/libsqlite3.so.0
    scratch=$python_tree/logs
    # The shared driver supplies these stage inputs.
    # shellcheck disable=SC2154
    info "SQLite stage=${stage}, Python ${version}, source=${tool_src}, prefix=${tool_prefix}, provider=${provider}"
    [[ -f $probe && -d $scratch ]] || {
        error "SQLite ${stage}: missing shared probe '${probe}' or scratch '${scratch}'"
        return 2
    }
    probe_args=(--stage "$stage" --expected-python-root "$python_tree"
        --expected-provider "$provider" --scratch-dir "$scratch")
    if [[ $stage == build ]]; then
        source_tree=$(readlink -e "$tool_src")
        [[ -d $source_tree && $source_tree == "$python_tree/sources/"* ]] || {
            error "SQLite build: source tree escapes '${python_tree}/sources'"
            return 2
        }
        executable=$source_tree/python
        [[ -f $executable && -x $executable && $(readlink -e "$executable") == "$executable" ]] || {
            error "SQLite build: expected compiled executable '${executable}'"
            return 2
        }
        [[ -f $source_tree/Makefile && -f $source_tree/pyconfig.h && -f $source_tree/config.status && -f $source_tree/pybuilddir.txt ]] || {
            error "SQLite build: missing Makefile, pyconfig.h, config.status or pybuilddir.txt in '${source_tree}'"
            return 2
        }
        # Read selected literal assignments, never evaluate Makefile contents.
        while IFS= read -r line; do
            if [[ $line =~ ^(VERSION|ABIFLAGS|LDVERSION|LDLIBRARY|abs_builddir)=[[:space:]]*(.*)$ ]]; then
                key=${BASH_REMATCH[1]}
                value=${BASH_REMATCH[2]}
                value=${value%"${value##*[![:space:]]}"}
                [[ ! ${config[$key]+set} ]] || { error "SQLite build: duplicate ${key}"; return 2; }
                config[$key]=$value
            fi
        done < "$source_tree/Makefile"
        # These are the pinned 3.13 Linux shared-build substitutions. Debug and
        # free-threaded builds are not selected by this configure invocation.
        # Makefile substitutions are compared literally, not executed by Bash.
        # shellcheck disable=SC2016
        if [[ ${config[VERSION]:-} != 3.13 || ${config[ABIFLAGS]-missing} != '' ||
              ${config[LDVERSION]:-} != '$(VERSION)$(ABIFLAGS)' ||
              ${config[LDLIBRARY]:-} != 'libpython$(LDVERSION).so' ||
              $(readlink -e "${config[abs_builddir]:-}") != "$source_tree" ]]; then
            error "SQLite build: source configuration does not match the selected Python 3.13 shared build"
            return 2
        fi
        mapfile -t records < "$source_tree/pybuilddir.txt"
        record=${records[0]:-}
        # Shared setenv rewrites EXTLIBS in Makefile on each reuse. Compare
        # configure outputs instead, so that maintenance is not mistaken for
        # reconfiguration requiring a newly generated module directory.
        if [[ ${#records[@]} != 1 || $record != build/lib.linux-x86_64-3.13 ||
              $source_tree/pybuilddir.txt -ot $source_tree/config.status ||
              $source_tree/pybuilddir.txt -ot $source_tree/pyconfig.h ]]; then
            error "SQLite build: missing, stale or inconsistent pybuilddir.txt in '${source_tree}'"
            return 2
        fi
        extension_dir=$(readlink -e "$source_tree/$record")
        libpython=$(readlink -e "$source_tree/libpython3.13.so")
        if [[ ! -d $extension_dir || $extension_dir != "$source_tree/$record" ||
              ! -f $libpython || ${libpython%/*} != "$source_tree" ]]; then
            error "SQLite build: missing or escaped generated directory '${source_tree}/${record}' or configured libpython3.13.so"
            return 2
        fi
        probe_args+=(--expected-extension-root "$extension_dir" --expected-libpython "$libpython")
        # DT_RPATH can select an old installed libpython before LD_LIBRARY_PATH.
        # Preload only this validated source library for the build probe; its
        # mapped identity is still checked independently. The installed and
        # operator checks receive no added preload. -I ignores inherited Python
        # module overrides, while -S and -B avoid site hooks and bytecode writes.
        LD_PRELOAD="$libpython" \
        LD_LIBRARY_PATH="$source_tree${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
            "$executable" -I -S -B "$probe" "${probe_args[@]}"
        status=$?
    else
        prefix_tree=$(readlink -e "$tool_prefix")
        executable=$(readlink -e "$tool_prefix/bin/python3")
        extension_dir=$prefix_tree/lib/python3.13/lib-dynload
        if [[ $prefix_tree != "$python_tree/python-${version}" ||
              $executable != "$prefix_tree/bin/python3.13" || ! -f $executable || ! -x $executable ]]; then
            error "SQLite installed: expected '${python_tree}/python-${version}/bin/python3.13', reached '${executable}'"
            return 2
        fi
        probe_args+=(--expected-extension-root "$extension_dir")
        "$executable" -I -S -B "$probe" "${probe_args[@]}"
        status=$?
    fi
    if ((status)); then
        error "SQLite ${stage}: Python ${version} capability failed (${status}); expected extension '${extension_dir}', provider '${provider}'"
    fi
    return "$status"
}

function configure() {
    task "config.log not present: reconfigure"

    # Build the configure command as an array
    local configure_cmd=( env \
        "LIBMPDEC_CFLAGS=-I${root}/include -DCONFIG_64=1 -DANSI=1 -DHAVE_UINT128_T=1" \
        "LIBMPDEC_LIBS=-L${root}/lib -lmpdec -L${root}/lib64 -lm -L${root}/usr/lib/gcc/x86_64-redhat-linux/8 -lgcc_s " )
    if python_sqlite_required; then
        # The shared build flags emit DT_RPATH. SQLite needs DT_RUNPATH so the
        # normal wrapper's shipped library path wins after rsync promotion,
        # while the original sandbox remains available on the build account.
        configure_cmd+=( "LIBSQLITE3_CFLAGS=-I${root}/usr/include"
            "LIBSQLITE3_LIBS=-L${root}/usr/lib64 -Wl,--enable-new-dtags -lsqlite3" )
    fi
    configure_cmd+=( \
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
    if python_sqlite_required; then
        python_check_sqlite build || return $?
    fi
}

function post_install_check() {
    if python_sqlite_required; then
        python_check_sqlite installed || return $?
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
    rm -f python || fatal "Unable to remove python in '$(pwd)'" 5
    ok "Clean done"
}
