#!/bin/bash
# Copied-root progress checks exercise real orchestration with recorded IO.
# Fixture globals come from index_load; shell-looking expressions stay literal.
# shellcheck disable=SC1091,SC2034,SC2317,SC2154,SC2016

progress_load() {
    index_load
    info() { printf '%s\n' "$1"; }
    progress_file="$SETUP_PKGS_DIR/pkgs/python/last"
    list_path=src/setups/pkgs/python/python_rhel_9.6_x86_64.txt
    list_file="$ARCHITECTURE_CASE_ROOT/$list_path"
    printf 'alpha\nbeta\nzlib-devel\nomega\n' > "$list_file"
    printf 'cplx_path=/fixture\n' >> "$properties_file"
    printf 'cached index\n' > "$index_path"
    sync_package() { printf '%s\n' "$2" >> sync.calls; }
    install_package() { :; }; install_packages() { :; }
}

progress_seed() {
    printf 'cplx-package-progress-v1\narchitecture=%s\nlist=%s\nlast=%s\n' \
        "${2:-$architecture}" "${3:-$list_path}" "$1" > "$progress_file"
}

progress_expect_record() {
    printf 'cplx-package-progress-v1\narchitecture=%s\nlist=%s\nlast=%s\n' \
        "$architecture" "$list_path" "$1" > expected.record
    cmp expected.record "$progress_file"
    [[ -z $(find "$SETUP_PKGS_DIR/pkgs/python" -name '.cplx-progress-*' -print) ]]
}

progress_run() {
    local expected_status=$1 expected_calls=$2 status=0
    shift 2
    : > sync.calls
    # Run outside a conditional so errexit still checks the real code path.
    set +e
    (set -e; main "$@") > invocation.log 2>&1
    status=$?
    set -e
    architecture_assert_equal "$status" "$expected_status" 'progress invocation status'
    architecture_assert_equal "$(cat sync.calls)" "$expected_calls" 'synchronized entries'
}

progress_resume_matrix() {
    progress_load
    local repeat cursor expected
    for repeat in '' alpha beta zlib-devel omega absent; do
        cursor=zlib-devel
        expected=omega
        case $repeat in alpha) expected=$'beta\nzlib-devel\nomega';; beta) expected=$'zlib-devel\nomega';; esac
        progress_seed "$cursor"
        CPLX_SP_REPEAT=$repeat
        progress_run 0 "$expected"
        progress_expect_record omega
    done
    CPLX_SP_REPEAT=''
    progress_seed omega
    progress_run 0 ''
    progress_expect_record omega
    # Duplicate entries retain first-match, resume-after behavior.
    printf 'alpha\nbeta\nalpha\nomega\n' > "$list_file"
    progress_seed alpha
    progress_run 0 $'beta\nalpha\nomega'
}

progress_restart_matrix() {
    progress_load
    local state
    CPLX_SP_REPEAT=zlib-devel
    for state in missing empty legacy key list stale version fields truncated unterminated cr nul; do
        progress_seed beta
        case $state in
            missing) rm "$progress_file";;
            empty) progress_seed '';;
            legacy) printf 'beta\n' > "$progress_file";;
            key) progress_seed beta rhel_9.6_x86_64;;
            list) progress_seed beta "$architecture" src/setups/pkgs/python/old.txt;;
            stale) progress_seed absent;;
            version) sed -i 's/progress-v1/progress-v9/' "$progress_file";;
            fields) printf 'extra=value\n' >> "$progress_file";;
            truncated) printf 'cplx-package-progress-v1\narchitecture=x\n' > "$progress_file";;
            unterminated) printf '%s' "$(cat "$progress_file")" > shortened; mv shortened "$progress_file";;
            cr) progress_seed $'be\rta';;
            nul) printf '\0' >> "$progress_file";;
        esac
        progress_run 0 $'alpha\nbeta\nzlib-devel\nomega'
        progress_expect_record omega
        case $state in missing|empty) :;; *) grep -q 'Restarting' invocation.log;; esac
    done
}

progress_literal_and_lines() {
    progress_load
    local literal='$(touch should-not-exist); `touch also-not-created` ! & [a-z].*'
    printf '\r\n  # comment\r\nalpha\r\n%s\r\nzlib-devel\r\nomega' "$literal" > "$list_file"
    progress_seed "$literal"
    sed -i 's/$/\r/' "$progress_file"
    progress_run 0 $'zlib-devel\nomega'
    [[ ! -e should-not-exist && ! -e also-not-created ]]
    progress_expect_record omega
    # Do not trim package expressions, including whitespace-only active entries.
    printf '  alpha  \n \n%s\n' "$literal" > "$list_file"
    progress_seed ''
    progress_run 0 "$(printf '  alpha  \n \n%s' "$literal")"
    progress_expect_record "$literal"
    for content in '' $'# comment\n  # indented\n'; do
        printf '%s' "$content" > "$list_file"
        progress_seed beta
        progress_run 0 ''
        progress_expect_record ''
    done
}

progress_reset_and_direct() {
    progress_load
    progress_seed omega
    progress_run 0 $'alpha\nbeta\nzlib-devel\nomega' --reset-list
    progress_run 0 omega --reset-list --after-entry zlib-devel
    progress_run 0 omega --reset-list --after-entry $'zlib-devel\r'
    progress_expect_record omega
    cp "$progress_file" saved.record
    progress_run 117 '' --reset-list --after-entry absent
    cmp saved.record "$progress_file"
    grep -Fq "$list_path" invocation.log
    local args
    for args in '--package' '--after-entry' '--reset-list --after-entry' \
        '--after-entry beta' '--package item --reset-list' '--reset-list --package item' \
        '--reset-list --unknown' '--package item trailing'; do
        # Deliberately split this controlled table of option tokens.
        # shellcheck disable=SC2086
        progress_run 117 '' $args
        cmp saved.record "$progress_file"
    done
    progress_run 0 'zlib.*[0-9] !' --package 'zlib.*[0-9] !'
    cmp saved.record "$progress_file"
    # Direct mode never opens a progress path, even when it is a directory.
    rm "$progress_file"; mkdir "$progress_file"
    progress_run 0 _built --package _built
    [[ -d $progress_file ]]
}

progress_interrupt_restart() {
    progress_load
    sync_package() { exit 88; }
    progress_run 88 ''
    progress_expect_record ''
    progress_seed beta rhel_9.6_x86_64
    progress_run 88 ''
    progress_expect_record ''
    # Restore the old identity: an interrupted restart must not recover beta.
    architecture=rhel_9.6_x86_64
    sed -i 's/rhel_9.8_x86_64/rhel_9.6_x86_64/' "$properties_file"
    printf 'cached\n' > "$SETUP_PKGS_DIR/pkgs/packages_${architecture}.txt"
    sync_package() { printf '%s\n' "$2" >> sync.calls; }
    progress_run 0 $'alpha\nbeta\nzlib-devel\nomega'
    progress_expect_record omega
}

progress_sync_failure() {
    progress_load
    sync_package() {
        printf '%s\n' "$2" >> sync.calls
        [[ $2 != beta ]]
    }
    progress_run 10 $'alpha\nbeta'
    progress_expect_record alpha
    sync_package() { printf '%s\n' "$2" >> sync.calls; }
    progress_run 0 $'beta\nzlib-devel\nomega'
    progress_expect_record omega
}

progress_publication_failures() {
    progress_load
    local fault
    for fault in create write rename; do
        progress_seed beta
        cp "$progress_file" saved.record
        (
            case $fault in
                create) mktemp() { return 1; };;
                write) printf() {
                    if [[ $1 == cplx-package-progress-v1* ]]; then return 1; fi
                    # Pass through the real format except for the injected write.
                    # shellcheck disable=SC2059
                    builtin printf "$@"
                };;
                rename) mv() { return 1; };;
            esac
            progress_run 116 '' --reset-list
            cmp saved.record "$progress_file"
            [[ -z $(find "$SETUP_PKGS_DIR/pkgs/python" -name '.cplx-progress-*' -print) ]]
            ! grep -q 'All lines have been processed' invocation.log
        )
    done
    # The package may succeed while its progress publication fails.
    progress_seed beta
    mv() { return 1; }
    progress_run 116 $'zlib-devel'
    cmp saved.record "$progress_file"
    unset -f mv
    progress_run 0 $'zlib-devel\nomega'
}

progress_single_snapshot() {
    progress_load
    progress_seed alpha
    sync_package() {
        printf '%s\n' "$2" >> sync.calls
        printf 'replacement\n' > "$list_file"
    }
    progress_run 0 $'beta\nzlib-devel\nomega'
    progress_expect_record omega
}

architecture_progress_suite() {
    local name
    for name in resume_matrix restart_matrix literal_and_lines reset_and_direct \
        interrupt_restart sync_failure publication_failures single_snapshot; do
        architecture_run_case "progress_$name"
    done
    echo 'REQUIRED SEPARATELY: real Windows verify.architecture-launcher.cmd'
}

# The CMD harness owns the driver process. These modes only prepare/assert its
# copied endpoints; they never interpret the launcher's arguments on its behalf.
progress_launcher_fixture() {
    set -euo pipefail
    local mode=$1 root repo name=${3:-} command='' expected='' endpoint
    root=$(cygpath -u "$2")
    [[ $root == /*/cplx-architecture-launcher-* && -d $root ]] || return 96
    case $mode in
        --launcher-clean) rm -rf -- "$root"; return;;
        --launcher-stage)
            repo=$(cygpath -u "$3")
            mkdir -p "$root/src/"{setups,utils}
            cp "$repo/src/setups/setup.bat" "$root/src/setups/"
            cat > "$root/senv.bat" <<'ENV'
@echo off
set "project_dir_name=fixture"
set "project_dir_unix=%~dp0"
set "SSH_CONFIG_ENTRY=fixture"
set "CPLX_TOOL=python"
set "_pre=rem"
set "_post=rem"
set "_info=rem"
set "_task=rem"
set "_ok=rem"
set "_fatal=rem"
exit /b 0
ENV
            for endpoint in setups/setup_packages.sh setups/setup.sh utils/steps.sh; do
                cat > "$root/src/$endpoint" <<'ENDPOINT'
#!/bin/bash
root=$(cygpath -u "$launcher_fixture")
endpoint=$(basename "$(cygpath -u "$0")")
printf '%s\n' "$endpoint" "$#" >> "$root/argv"
if (( $# )); then printf '%s\n' "$@" >> "$root/argv"; fi
[[ $endpoint != steps.sh ]] || exit "${launcher_helper_status:-0}"
[[ ${CPLX_FORCE_RELOAD_PACKAGES:-} != 1 ]] || printf 'force=1\n' >> "$root/argv"
exit "${launcher_endpoint_status:-0}"
ENDPOINT
            done
            return;;
    esac
    case $name in
        reset|bash_failure) command='packages reset'; expected=$'setup_packages.sh\n1\n--reset-list';;
        after) command='packages reset zlib-devel'; expected=$'setup_packages.sh\n3\n--reset-list\n--after-entry\nzlib-devel';;
        direct) command='packages p_zlib-devel'; expected=$'setup_packages.sh\n2\n--package\nzlib-devel';;
        conflict) command='packages p_zlib-devel reset';;
        repeat) command=copy_the_sources; expected=$'steps.sh\n2\nrepeat_or_reset_step\ncopy_the_sources\nsetup.sh\n0';;
        reset_step) command=r_copy_the_sources; expected=$'steps.sh\n2\nrepeat_or_reset_step\nr_copy_the_sources\nsetup.sh\n0';;
        sdpl|helper_failure)
            command='packages download_packages_list'
            expected=$'steps.sh\n2\nrepeat_or_reset_step\ndownload_packages_list'
            [[ $name != sdpl ]] || expected+=$'\nsetup_packages.sh\n0\nforce=1';;
        literal|literal_after)
            endpoint='lib.*[0-9] ! & (x) $HOME `literal` %CPLX_TOOL% ^'
            command="packages \"p_$endpoint\""
            expected=$'setup_packages.sh\n2\n--package\n'"$endpoint"
            if [[ $name == literal_after ]]; then
                command="packages reset \"$endpoint\""
                expected=$'setup_packages.sh\n3\n--reset-list\n--after-entry\n'"$endpoint"
            fi;;
        *) return 2;;
    esac
    case $mode in
        --launcher-driver)
            : > "$root/argv"
            command=${command//%/%%}
            printf '@echo off\r\nsetlocal DisableDelayedExpansion\r\n"%%launcher_fixture%%\\src\\setups\\setup.bat" %s\r\n' \
                "$command" > "$root/driver.cmd";;
        --launcher-check)
            [[ $(cat "$root/argv") == "$expected" ]] || {
                printf 'FAIL: CMD %s expected <%s>, received <%s>\n' "$name" "$expected" "$(cat "$root/argv")" >&2
                return 1
            }
            [[ ! -e $root/src/setups/pkgs && ! -e $root/src/setups/pkgs.log && ! -e $root/src/setups/setup.log ]];;
        *) return 2;;
    esac
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    progress_launcher_fixture "$@"
fi
