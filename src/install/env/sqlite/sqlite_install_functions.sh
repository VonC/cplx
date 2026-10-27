#!/bin/bash

# SQLite is built from source because the distribution's 3.34.1 lacks the
# WAL-reset fix (3.51.3 and later). Python consumes this library through the
# `_sqlite` entry of its dependency list, so the package installs under
# usr/include and usr/lib64, where Python's configure inputs already look.

# The selected release and its source identity: the archive digests from the
# upstream download page, the amalgamation digest and source id from its change
# log. A version change replaces the five values together, and Python's
# sqlite_expected.json follows it.
function sqlite_pinned_identity() {
    # The shared driver supplies the requested version.
    # shellcheck disable=SC2154
    case ${version} in
        3.54.1)
            sqlite_archive_sha256=926ef8d3eab93fbf6e06011901273eec076b25594a4e1cdadd50c987f4f6d64e
            sqlite_archive_sha3=b6ced585c750916b1052667239a12c25a7ff34e7f06e1e6e01ecb0427657d9c4
            sqlite_amalgamation_sha3=e2b869d3003b33c942b7dd7063604fbc53553e1b66609570df39b9b7b558ee81
            sqlite_source_id='2026-10-16 14:45:20 555e07ef33f69a0957d24d8e555b702464a131d6f1607f4c3c1e4551e8e6ca76'
            ;;
        *)
            error "SQLite ${version}: no pinned source identity; record its digests before building it"
            return 2
            ;;
    esac
}

# Compare one digest with its pinned value, naming the file on refusal.
function sqlite_digest_matches() {
    local label=$1 file=$2 expected=$3 observed
    shift 3
    observed=$("$@" "$file") || { error "SQLite: cannot compute the ${label} of '${file}'"; return 2; }
    observed=${observed%% *}
    if [[ $observed != "$expected" ]]; then
        error "SQLite: ${label} of '${file}' is ${observed}, expected ${expected}"
        return 2
    fi
    ok "SQLite: ${label} of '${file}' matches"
}

# Verify the source bytes before configure and before make, so a reused tree
# is checked again. The archive is the one the dispatcher extracted.
function sqlite_verify_sources() {
    local sqlite_archive_sha256 sqlite_archive_sha3 sqlite_amalgamation_sha3 sqlite_source_id
    local archive header defined
    sqlite_pinned_identity || return $?
    # shellcheck disable=SC2154
    archive=${tool}/sources/sqlite-src-${version}.tar.gz
    [[ -f $archive ]] || { error "SQLite: missing source archive '${archive}'"; return 2; }
    sqlite_digest_matches SHA-256 "$archive" "$sqlite_archive_sha256" sha256sum || return $?
    sqlite_digest_matches SHA3-256 "$archive" "$sqlite_archive_sha3" openssl dgst -sha3-256 -r || return $?
    # shellcheck disable=SC2154
    sqlite_digest_matches "amalgamation SHA3-256" "${tool_src}/sqlite3.c" "$sqlite_amalgamation_sha3" \
        openssl dgst -sha3-256 -r || return $?
    header=${tool_src}/sqlite3.h
    defined=$(sed -n 's/^#define SQLITE_SOURCE_ID *"\(.*\)"$/\1/p' "$header")
    if [[ $defined != "$sqlite_source_id" ]]; then
        error "SQLite: '${header}' declares source id '${defined}', expected '${sqlite_source_id}'"
        return 2
    fi
}

# Check one built or installed library: the legacy SONAME every consumer links
# against, libm for the math functions, a run path the wrapper can override,
# and no GLIBC symbol version above the el9 baseline.
function sqlite_check_library() {
    local library=$1 dynamic soname newest
    dynamic=$(readelf -d "$library") || { error "SQLite: cannot read the dynamic section of '${library}'"; return 2; }
    soname=$(sed -n 's/.*(SONAME).*\[\(.*\)\]$/\1/p' <<< "$dynamic")
    if [[ $soname != libsqlite3.so.0 ]]; then
        error "SQLite: '${library}' has SONAME '${soname}', expected 'libsqlite3.so.0'"
        return 2
    fi
    if ! grep -q 'Shared library: \[libm\.so\.6\]' <<< "$dynamic"; then
        error "SQLite: '${library}' does not need libm.so.6, which its math functions call"
        return 2
    fi
    if grep -q '(RPATH)' <<< "$dynamic"; then
        error "SQLite: '${library}' has a DT_RPATH, which would outrank the wrapper's library path"
        return 2
    fi
    newest=$(readelf -W --dyn-syms "$library" | grep -o 'GLIBC_[0-9][0-9.]*' | sort -uV | tail -n 1)
    if [[ -z $newest || $(printf '%s\n' "$newest" GLIBC_2.34 | sort -V | tail -n 1) != GLIBC_2.34 ]]; then
        error "SQLite: '${library}' needs '${newest:-no GLIBC version}', above GLIBC_2.34"
        return 2
    fi
    ok "SQLite: '${library}' has SONAME libsqlite3.so.0 and needs at most ${newest}"
}

function configure() {
    sqlite_verify_sources || return $?
    task "config.log not present: reconfigure"

    # shellcheck disable=SC2154
    local cc=${root}/usr/bin/gcc
    # configure runs under Tcl and bootstraps its own jimsh0 with an unquoted
    # compiler word, which cannot carry --sysroot (and the host has no compiler
    # of its own). It tries ./jimsh0 first, so build it with the sandbox.
    if [[ ! -x jimsh0 ]]; then
        "${cc}" "--sysroot=${root}" -o jimsh0 "${tool_src}/autosetup/jimsh0.c" \
            || fatal "Unable to build the configure interpreter jimsh0 in '$(pwd)'" 199
    fi
    # DISABLE_DIRSYNC is deliberately absent: SQLite keeps the directory fsync
    # after creating or deleting a journal. The other options match the RHEL
    # provider this build replaces; --soname=legacy keeps libsqlite3.so.0.
    # configure's math probe passes without -lm (gcc inlines its ceil call),
    # so libm is named explicitly for the math SQL functions. New dtags give
    # the library a DT_RUNPATH: the Python wrapper's library path then selects
    # libz and libm inside the Python tree, not this tool's build sandbox.
    # shellcheck disable=SC2154
    local configure_cmd=( "${tool_src}/configure"
        "--prefix=${tool_prefix}/usr"
        "--libdir=${tool_prefix}/usr/lib64"
        "--soname=legacy"
        "--disable-static"
        "--disable-static-shell"
        "--disable-readline"
        "--enable-fts3" "--enable-fts4" "--enable-fts5"
        "--enable-rtree" "--enable-session" "--enable-dbstat" "--enable-column-metadata"
        "--with-tempstore=no"
        "CC=${cc}"
        "CFLAGS=${CFLAGS} -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_SECURE_DELETE"
        "LDFLAGS=${LDFLAGS} -Wl,--enable-new-dtags -lm" )

    # Display the command with its parameters.
    info "Running configure command: ${configure_cmd[*]}"

    # Execute the configure command.
    if ! "${configure_cmd[@]}"; then
        fatal "configure ERROR" 199
    fi
    # autosetup logs its checks, not the files it writes: record completion
    # with the line the default CPLX_CONFIG_DONE looks for.
    echo "creating Makefile" >> config.log || fatal "Unable to record configure completion in '$(pwd)/config.log'" 16
    ok "configure done"
}

function build() {
    sqlite_verify_sources || return $?
    if [[ ! -e libsqlite3.so ]]; then
        task "Must make all in '$(pwd)'"
        make all || fatal "Unable to make all in '$(pwd)'" 19
        ok "make all is now done in '$(pwd)'"
    else
        ok "sqlite already compiled in '$(pwd)'"
    fi
    sqlite_check_library "$(pwd)/libsqlite3.so"
}

# The installed layout is what Python's sandbox receives: one real library
# behind both linker names, and the header of the verified source.
function post_install_check() {
    local lib64 provider target defined sqlite_archive_sha256 sqlite_archive_sha3
    local sqlite_amalgamation_sha3 sqlite_source_id
    sqlite_pinned_identity || return $?
    # shellcheck disable=SC2154
    lib64=${tool_prefix}/usr/lib64
    provider=${lib64}/libsqlite3.so.${version}
    [[ -f $provider && ! -L $provider ]] || { error "SQLite installed: missing library '${provider}'"; return 2; }
    for target in "${lib64}/libsqlite3.so.0" "${lib64}/libsqlite3.so"; do
        if [[ $(readlink -e "$target") != "$(readlink -e "$provider")" ]]; then
            error "SQLite installed: '${target}' does not resolve to '${provider}'"
            return 2
        fi
    done
    if [[ -e ${lib64}/libsqlite3.so.0.8.6 ]]; then
        error "SQLite installed: legacy '${lib64}/libsqlite3.so.0.8.6' would be a second provider"
        return 2
    fi
    defined=$(sed -n 's/^#define SQLITE_SOURCE_ID *"\(.*\)"$/\1/p' "${tool_prefix}/usr/include/sqlite3.h")
    if [[ $defined != "$sqlite_source_id" ]]; then
        error "SQLite installed: header source id '${defined}', expected '${sqlite_source_id}'"
        return 2
    fi
    sqlite_check_library "$provider"
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
