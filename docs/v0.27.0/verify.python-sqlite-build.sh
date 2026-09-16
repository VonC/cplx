#!/bin/bash
# Exercise complete copied installers; every side effect stays in owned fixtures.
set -euo pipefail
[[ $# == 2 && $1 == --python ]] || { echo 'usage: --python /absolute/python' >&2; exit 2; }
author_python=$2
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
owned=$(mktemp -d "${TMPDIR:-/tmp}/cplx-sqlite-build.XXXXXXXX")
passed=0
trap 'status=$?; if ((status == 0)); then rm -rf -- "${owned:?}"; else echo "Fixtures retained: $owned" >&2; fi' EXIT
case $(uname -s) in
    MINGW*|MSYS*|CYGWIN*)
        "$author_python" -B "$repo/docs/v0.27.0/verify.python-sqlite-launcher.py" "$repo" "$owned"
        echo 'Native Linux process fixtures separately required (real symlinks).'
        exit 0
        ;;
esac

prepare() {
    case_name=$1
    fixture=$owned/$case_name
    export FIXTURE=$fixture
    export FIXTURE_FAMILY=el9.x86_64 PROBE_FAIL=none MAKE_FAIL=none CALLBACK_FAIL=0
    export PYTHONPATH=$fixture/inherited-modules
    mkdir -p "$fixture/tools/python/sources/3.13.15" "$fixture/bin" "$fixture/echos"
    cp "$repo/src/install/env/install" "$fixture/tools/install"
    cp "$repo/src/install/env/install_functions.sh" "$fixture/tools/install_functions.sh"
    cp "$repo/src/install/env/python/python_install_functions.sh" "$fixture/tools/python/"
    cp "$repo/src/install/env/python/sqlite_probe.py" "$fixture/tools/python/"
    : > "$fixture/cplx.properties"
    : > "$fixture/tools/python/sources/python-src-3.13.15.tar.gz"
    : > "$fixture/events"
    printf 'previous archive\n' > "$fixture/package"
    printf 'unrelated sandbox\n' > "$fixture/sentinel"
    source_dir=$fixture/tools/python/sources/3.13.15
    prefix=$fixture/tools/python/python-3.13.15
    mkdir -p "$source_dir/Modules" "$source_dir/build/lib.linux-x86_64-3.13"
    mkdir -p "$fixture/tools/python/root/usr/lib64" "$prefix/bin" "$prefix/lib/python3.13/lib-dynload"
    ln -s python-old "$fixture/tools/python/current"
    cat > "$fixture/echos/echos" <<'SH'
info() { printf '%s\n' "$*"; }
ok() { info "$@"; }
task() { info "$@"; }
warning() { info "$@"; }
error() { info "$@" >&2; }
fatal() { error "$1"; exit "${2:-1}"; }
SH
    cp "$fixture/echos/echos" "$fixture/echos/echoslog"
    cat > "$fixture/bin/properties.sh" <<'SH'
get_property() {
    case $1 in
        services) services=python ;;
        CPLX_ARCH_EXT) CPLX_ARCH_EXT=$FIXTURE_FAMILY ;;
        CPLX_CONFIG_DONE) CPLX_CONFIG_DONE='configure: exit 0 config.log' ;;
        CPLX_BIN) CPLX_BIN=true ;;
        *) return 91 ;;
    esac
}
SH
    cat > "$fixture/.env" <<'SH'
# Synthetic setup: the production profile and shared setenv never execute.
export HOME=$FIXTURE
export PATH=$FIXTURE/bin:$PATH
source "$FIXTURE/tools/install_functions.sh"
setenv() {
    export tool_name=$1 version=$2 tool=$FIXTURE/tools/$1
    export tool_src=$tool/sources/current tool_prefix=$tool/$1-$2 root=$tool/root
    export CPLX_ARCH_EXT=$FIXTURE_FAMILY
    export LD_LIBRARY_PATH=$root/usr/lib64:$tool_prefix/lib
    export LD_RUN_PATH=$LD_LIBRARY_PATH
    export CPLX_CHECK_SRC=libpython3.so CPLX_CHECK_PREFIX=lib/libpython3.so
}
package() { echo package >> "$FIXTURE/events"; echo candidate > "$FIXTURE/package"; }
deploy() { echo deploy >> "$FIXTURE/events"; }
SH
    cat > "$fixture/bin/make" <<'SH'
#!/bin/bash
set -eu
[[ $(pwd -P) == "$FIXTURE/tools/python/sources/3.13.15" ]] || exit 92
echo "make-$1" >> "$FIXTURE/events"
[[ $MAKE_FAIL != "$1" ]] || exit 43
case $1 in
    clean) rm -f python pybuilddir.txt git-add ;;
    all)
        cp "$FIXTURE/interpreter" python
        printf 'build/lib.linux-x86_64-3.13' > pybuilddir.txt
        touch libpython3.so libpython3.13.so.1.0
        ;;
    install)
        cp "$FIXTURE/interpreter" "$tool_prefix/bin/python3.13"
        ln -sfn python3.13 "$tool_prefix/bin/python3"
        cp libpython3.so "$tool_prefix/lib/libpython3.so"
        ;;
    *) exit 93 ;;
esac
SH
    cat > "$source_dir/configure" <<'SH'
#!/bin/bash
set -eu
echo configure >> "$FIXTURE/events"
if [[ $FIXTURE_FAMILY == el9.x86_64 ]]; then
    [[ $LIBSQLITE3_CFLAGS == "-I${root}/usr/include" ]] || exit 94
    [[ $LIBSQLITE3_LIBS == "-L${root}/usr/lib64 -lsqlite3" ]] || exit 95
else
    [[ ! ${LIBSQLITE3_CFLAGS+x} && ! ${LIBSQLITE3_LIBS+x} ]] || exit 96
fi
[[ $LIBMPDEC_CFLAGS == "-I${root}/include "* ]] || exit 97
printf '%s\n' "$@" > "$FIXTURE/configure-args"
echo 'configure: exit 0' > config.log
SH
    cat > "$fixture/interpreter" <<'SH'
#!/bin/bash
# Command recorder, never a provider-acceptance substitute.
set -eu
[[ $1 == -I && $2 == -S && $3 == -B ]] || exit 98
shift 3
[[ $1 == "$FIXTURE/tools/python/sqlite_probe.py" || $1 == "$FIXTURE/tools/tool/sqlite_probe.py" ]] || exit 99
shift
declare -A args
while (($#)); do args[$1]=$2; shift 2; done
stage=${args[--stage]}
echo "probe-$stage" >> "$FIXTURE/events"
[[ ${args[--expected-python-root]} == "$FIXTURE/tools/python" ]] || exit 100
[[ ${args[--expected-provider]} == "$FIXTURE/tools/python/root/usr/lib64/libsqlite3.so.0" ]] || exit 101
[[ -d ${args[--scratch-dir]} && ${args[--scratch-dir]} == "$FIXTURE/tools/python/"* ]] || exit 102
if [[ $stage == build ]]; then
    [[ $LD_PRELOAD == "${args[--expected-libpython]}" ]] || exit 109
    [[ $LD_LIBRARY_PATH == "$FIXTURE/tools/python/sources/3.13.15:"* ]] || exit 103
    [[ $LD_LIBRARY_PATH == *"$root/usr/lib64:$tool_prefix/lib" ]] || exit 104
    [[ ${args[--expected-extension-root]} == "$FIXTURE/tools/python/sources/3.13.15/build/lib.linux-x86_64-3.13" ]] || exit 105
    [[ ${args[--expected-libpython]} == "$FIXTURE/tools/python/sources/3.13.15/libpython3.13.so.1.0" ]] || exit 106
else
    [[ ! ${LD_PRELOAD+x} ]] || exit 110
    [[ ${args[--expected-extension-root]} == "$FIXTURE/tools/python/python-3.13.15/lib/python3.13/lib-dynload" ]] || exit 107
    [[ $LD_LIBRARY_PATH == "$root/usr/lib64:$tool_prefix/lib" ]] || exit 108
fi
[[ $PROBE_FAIL != "$stage" ]] || { echo 'synthetic capability failure' >&2; exit 42; }
echo '{"outcome":"passed","fixture":true}'
SH
    chmod +x "$fixture/bin/make" "$fixture/interpreter" "$source_dir/configure"
    cp "$fixture/interpreter" "$source_dir/python"
    cp "$fixture/interpreter" "$prefix/bin/python3.13"
    ln -s python3.13 "$prefix/bin/python3"
    # Keep the configured Makefile references literal in this fixture.
    # shellcheck disable=SC2016
    printf 'VERSION=3.13\nABIFLAGS=\nLDVERSION=$(VERSION)$(ABIFLAGS)\nLDLIBRARY=libpython$(LDVERSION).so\nabs_builddir=%s\n' "$source_dir" > "$source_dir/Makefile"
    : > "$source_dir/pyconfig.h"
    : > "$source_dir/config.status"
    : > "$source_dir/libpython3.13.so.1.0"
    ln -s libpython3.13.so.1.0 "$source_dir/libpython3.13.so"
    : > "$source_dir/libpython3.so"
    printf 'configure: exit 0\n' > "$source_dir/config.log"
    printf 'build/lib.linux-x86_64-3.13' > "$source_dir/pybuilddir.txt"
}

run_case() {
    local expected=$1 expected_events=$2 status=0
    shift 2
    bash "$fixture/tools/install" python 3.13.15 "$@" > "$fixture/process.log" 2>&1 || status=$?
    [[ $status == "$expected" ]] || { echo "$case_name: expected $expected, got $status" >&2; tail -20 "$fixture/process.log" >&2; exit 1; }
    local events
    events=$(paste -sd, "$fixture/events")
    [[ $events == "$expected_events" ]] || { echo "$case_name: events=$events, expected=$expected_events" >&2; exit 1; }
    [[ $(cat "$fixture/sentinel") == 'unrelated sandbox' ]] || exit 1
    if ((status)); then
        [[ $(readlink "$fixture/tools/python/current") == python-old && $(cat "$fixture/package") == 'previous archive' ]] || exit 1
    else
        [[ $(readlink "$fixture/tools/python/current") == python-3.13.15 && $(cat "$fixture/package") == candidate ]] || exit 1
    fi
    passed=$((passed+1))
    printf 'PASS %s\n' "$case_name"
}

prepare reused-python
run_case 0 probe-build,make-install,probe-installed,package
prepare fresh
rm "$source_dir/python" "$source_dir/config.log"
run_case 0 configure,make-clean,make-all,probe-build,make-install,probe-installed,package
grep -Fx -- "--prefix=$fixture/tools/python/python-3.13.15" "$fixture/configure-args" >/dev/null
prepare reused-git-add
touch "$source_dir/git-add"
run_case 0 probe-build,make-install,probe-installed,package
prepare makefile-maintenance
touch -t 203001010000 "$source_dir/Makefile"
run_case 0 probe-build,make-install,probe-installed,package
prepare source-failure
PROBE_FAIL=build
run_case 42 probe-build
prepare installed-failure
PROBE_FAIL=installed
run_case 42 probe-build,make-install,probe-installed
prepare timestamp-reuse
touch -t 203001010000 "$prefix/lib/libpython3.so"
run_case 0 probe-build,probe-installed,package
prepare timestamp-reuse-failure
touch -t 203001010000 "$prefix/lib/libpython3.so"
PROBE_FAIL=installed
run_case 42 probe-build,probe-installed
prepare reconfigure
run_case 0 configure,make-clean,make-all,probe-build,make-install,probe-installed,package --reconfigure
prepare other-family
FIXTURE_FAMILY=el8.x86_64
rm "$source_dir/config.log" "$fixture/tools/python/sqlite_probe.py"
run_case 0 configure,make-clean,make-all,make-install,package
prepare missing-probe
rm "$fixture/tools/python/sqlite_probe.py"
run_case 2 ''
for variant in missing placeholder multiline absolute escape stale wrong-version missing-directory stale-config missing-config escaped-directory missing-library wrong-executable missing-executable; do
    prepare "build-$variant"
    case $variant in
        missing) rm "$source_dir/pybuilddir.txt" ;;
        placeholder) echo none > "$source_dir/pybuilddir.txt" ;;
        multiline) printf 'build/lib.linux-x86_64-3.13\nextra\n' > "$source_dir/pybuilddir.txt" ;;
        absolute) echo "$source_dir/build/lib.linux-x86_64-3.13" > "$source_dir/pybuilddir.txt" ;;
        escape) echo ../../outside > "$source_dir/pybuilddir.txt" ;;
        stale) echo build/lib.linux-x86_64-3.12 > "$source_dir/pybuilddir.txt" ;;
        wrong-version) sed -i 's/VERSION=3.13/VERSION=3.12/' "$source_dir/Makefile" ;;
        missing-directory) rmdir "$source_dir/build/lib.linux-x86_64-3.13" ;;
        stale-config) touch -t 203001010000 "$source_dir/config.status" ;;
        missing-config) rm "$source_dir/config.status" ;;
        escaped-directory)
            rmdir "$source_dir/build/lib.linux-x86_64-3.13"
            mkdir "$fixture/wrong-generated"
            ln -s "$fixture/wrong-generated" "$source_dir/build/lib.linux-x86_64-3.13"
            ;;
        missing-library) rm "$source_dir/libpython3.13.so.1.0" ;;
        wrong-executable) rm "$source_dir/python"; ln -s "$prefix/bin/python3.13" "$source_dir/python" ;;
        missing-executable) rm "$source_dir/python"; touch "$source_dir/git-add" ;;
    esac
    run_case 2 ''
done
prepare installed-old-selector
touch -t 203001010000 "$prefix/lib/libpython3.so"
rm "$prefix/bin/python3"
ln -s "$source_dir/python" "$prefix/bin/python3"
run_case 2 probe-build
prepare previous-install-failure
MAKE_FAIL=install
run_case 19 probe-build,make-install
prepare previous-build-failure
rm "$source_dir/python"
MAKE_FAIL=all
run_case 19 make-all

# Generic tool fixtures keep the complete driver and shared install operation.
for variant in absent success failure prior-failure; do
    prepare "generic-$variant"
    cat > "$fixture/tools/python/python_install_functions.sh" <<'SH'
configure() { return 0; }
clean() { return 0; }
build() { echo generic-build >> "$FIXTURE/events"; }
SH
    if [[ $variant != absent ]]; then
        cat >> "$fixture/tools/python/python_install_functions.sh" <<'SH'
post_install_check() { echo callback >> "$FIXTURE/events"; return "$CALLBACK_FAIL"; }
SH
    fi
    case $variant in
        absent) run_case 0 generic-build,make-install,package ;;
        success) run_case 0 generic-build,make-install,callback,package ;;
        failure) CALLBACK_FAIL=47; run_case 47 generic-build,make-install,callback ;;
        prior-failure) MAKE_FAIL=install; run_case 19 generic-build,make-install ;;
    esac
done

printf 'Bash process cases passed: %s\n' "$passed"
case $(uname -s) in
    MINGW*|MSYS*|CYGWIN*)
        "$author_python" -B "$repo/docs/v0.27.0/verify.python-sqlite-launcher.py" "$repo" "$owned"
        ;;
    *) echo 'Windows CMD launcher check separately required on Windows.' ;;
esac
