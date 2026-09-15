#!/bin/bash
# Index lifecycle and consumer fixtures use copied roots and injected IO. The
# cumulative runner owns live-tree preservation even when these cases fail.
# shellcheck source-path=SCRIPTDIR
# Runtime sources, nameref results and injected callbacks are checked together.
# shellcheck disable=SC1091,SC2034,SC2317

index_load() {
    source "$ARCHITECTURE_CASE_ROOT/src/setups/setup_packages.sh" fixture
    info() { :; }; ok() { :; }; task() { :; }; warning() { :; }; error() { :; }
    fatal() { printf '%s\n' "$1" >&2; exit "$2"; }
    architecture=rhel_9.8_x86_64
    CPLX_TOOL=python
    CPLX_RELOAD_PACKAGES=''
    CPLX_FORCE_RELOAD_PACKAGES=''
    CPLX_SP_REPEAT=''
    properties_file="$SETUP_PKGS_DIR/setup.properties"
    steps_file="$SETUP_PKGS_DIR/steps.md"
    declare -gA package_context=()
    declare -ga package_urls=()
    package_metadata_context "$architecture" "$SETUP_PKGS_DIR" package_context
    index_path=${package_context[index_path]}
    step_done() { printf 'done\n' >> completion.calls; }
}

index_guard_matrix() {
    index_load
    local availability checkpoint flags route expected actual cases=0
    # Real orchestration, synthetic generation: each cell starts a new context.
    resolve_package_mirrors() { package_context[mirror_source]=fixture; printf 'mirrors\n' >> mirror.calls; }
    package_index_generate() { printf 'generated\n' >> generation.calls; printf 'new\n' > "$1"; }
    download_package() { :; }; scp_package() { :; }
    find_package_in_arch() { printf -v "$3" '%s' 'item-1.x86_64.rpm'; }
    for availability in absent empty nonempty; do
        for checkpoint in absent present; do for flags in neither reload force both; do
            for route in ordinary direct; do
                package_metadata_context "$architecture" "$SETUP_PKGS_DIR" package_context
                rm -f -- "$index_path" generation.calls mirror.calls completion.calls
                case $availability in empty) : > "$index_path";; nonempty) printf 'old\n' > "$index_path";; esac
                printf '%s\n' "$checkpoint" > "$steps_file"
                step_is_done() { [[ $(< "$steps_file") == present ]]; }
                CPLX_RELOAD_PACKAGES=''; CPLX_FORCE_RELOAD_PACKAGES=''
                [[ $flags != reload && $flags != both ]] || CPLX_RELOAD_PACKAGES=1
                [[ $flags != force && $flags != both ]] || CPLX_FORCE_RELOAD_PACKAGES=1
                if [[ $route == ordinary ]]; then download_packages_list "$architecture"; fi
                sync_package "$architecture" item
                sync_package "$architecture" item
                expected=1
                [[ $availability != nonempty || $flags != neither ]] || expected=0
                actual=0; [[ ! -f generation.calls ]] || actual=$(wc -l < generation.calls)
                architecture_assert_equal "$actual" "$expected" "$availability/$checkpoint/$flags/$route generations"
                actual=0; [[ ! -f mirror.calls ]] || actual=$(wc -l < mirror.calls)
                architecture_assert_equal "$actual" "$expected" 'one resolution per requested generation'
                cases=$((cases + 1))
            done
        done; done
    done
    architecture_assert_equal "$cases" 48 'index guard cross product'
}

index_direct_built_and_empty() {
    index_load
    resolve_package_mirrors() { return 98; }
    sync_package "$architecture" _built
    [[ ! -e $index_path && ! -e completion.calls ]]
    # An authoritative empty ordinary list still prepares the detected index.
    : > "$SETUP_PKGS_DIR/pkgs/python/python_${architecture}.txt"
    resolve_package_mirrors() { package_context[mirror_source]=fixture; }
    package_index_generate() { printf 'generated\n' > "$1"; }
    sync_packages() { :; }; install_packages() { :; }
    main
    [[ -s $index_path && -s completion.calls ]]
}

index_lookup_read_only() {
    index_load
    local status=0 found=''
    (find_package_in_arch "$architecture" item found) 2> lookup.log || status=$?
    [[ $status != 0 && ! -e $index_path ]]
    [[ $(< lookup.log) == *"$index_path"* ]]
}

index_html_fixture() {
    local i
    for ((i=0; i<50; i++)); do printf '<!-- padding -->\n'; done
    printf '<a href="alpha-1.x86_64.rpm">one</a>\n'
    printf '<a href="alpha-2.x86_64.rpm">two</a>\n'
    printf "<a href='single-1.noarch.rpm'>single</a>\n"
    printf '<a href="/absolute-1.x86_64.rpm">excluded</a>\n'
}

index_seed_mirrors() {
    printf 'architecture=%s\ncplx_path=/fixture\nrhel_9_7_x86_64_pkgs_url=https://first.invalid, https://second.invalid\n' \
        "$architecture" > "$properties_file"
    curl() { index_html_fixture; }
}

index_generation_publication() {
    index_load
    index_seed_mirrors
    # An empty, valid mirror listing must not discard another URL's packages.
    curl() {
        if [[ $2 == https://second.invalid ]]; then printf '<!-- empty -->\n%.0s' {1..50}; else index_html_fixture; fi
    }
    task() { printf '%s\n' "$1" >> generation.log; }
    ok() { [[ -s $index_path ]] && printf '%s\n' "$1" >> generation.log; }
    printf 'old\n' > "$index_path"
    CPLX_RELOAD_PACKAGES=1
    download_packages_list "$architecture" 2> listing.log
    architecture_assert_equal "$(< "$index_path")" 'alpha-2.x86_64.rpm' 'established first-success extraction and last-entry aggregation'
    architecture_assert_equal "${package_context[detected_key]}" "$architecture" 'index stays detected-key'
    architecture_assert_equal "${package_context[mirror_key]}" rhel_9.7_x86_64 'independent mirror fallback'
    [[ -z $(find "$SETUP_PKGS_DIR/pkgs" -maxdepth 1 -name '.cplx-index-*' -print) ]]
    [[ -s completion.calls ]]
    [[ $(< listing.log) == *'Warning:'*'https://second.invalid'* ]]
    [[ $(< generation.log) == *'rhel_9_7_x86_64_pkgs_url'*'(2 URLs)'* ]]
    [[ $(< generation.log) == *"Published index '$index_path' (1 packages)"* ]]
    download_packages_list "$architecture"
    architecture_assert_equal "$(wc -l < generation.log)" 2 'report generation only, never guard reuse'
}

index_generation_failures() {
    index_load
    index_seed_mirrors
    local failure status
    for failure in fetch short no_match extraction masked_extraction aggregate final_aggregate empty sibling sibling_write rename completion; do
        printf 'old bytes\n' > "$index_path"
        cp "$index_path" before.index
        rm -f completion.calls
        status=0
        (
            CPLX_RELOAD_PACKAGES=1
            case $failure in
                fetch) curl() { index_html_fixture; return 22; };;
                short) curl() { printf '<!-- short -->\n'; };;
                no_match) curl() { printf '<!-- empty -->\n%.0s' {1..50}; };;
                extraction) grep() { return 2; };;
                masked_extraction) grep() { [[ $1 != -oP ]] || return 2; command grep "$@"; };;
                aggregate) awk() { printf 'partial\n'; return 1; };;
                final_aggregate) package_index_aggregate() {
                    [[ $# == 1 ]] || { printf 'partial\n'; return 1; }
                    printf 'alpha-2.x86_64.rpm\n'
                };;
                empty) awk() { :; };;
                sibling) mktemp() { [[ $* == *'.tmp'* ]] && return 1; command mktemp "$@"; };;
                sibling_write) package_index_write_candidate() { return 1; };;
                rename) mv() { return 1; };;
                completion) step_done() { return 1; };;
            esac
            download_packages_list "$architecture"
            printf 'incorrect continuation\n' > continued
        ) 2> failure.log || status=$?
        [[ $status != 0 && ! -e continued && -s failure.log ]]
        [[ $failure != no_match ]] || architecture_assert_equal "$status" 112 'all empty listings fail at final index'
        if [[ $failure == completion ]]; then
            [[ $(< "$index_path") == alpha* ]]
            architecture_assert_equal "$status" 6 'completion failure boundary'
        else
            cmp before.index "$index_path"
        fi
        [[ ! -e completion.calls ]]
        [[ -z $(find "$SETUP_PKGS_DIR/pkgs" -maxdepth 1 -name '.cplx-index-*' -print) ]]
        # Fresh invocation without reload can reuse whichever valid index remains.
        package_metadata_context "$architecture" "$SETUP_PKGS_DIR" package_context
        download_packages_list "$architecture"
    done
}

index_terminal_downloads() {
    index_load
    index_seed_mirrors
    # Cached-index lookup does not need mirrors; an actual missing RPM does.
    printf 'item-1.x86_64.rpm\n' > "$index_path"
    scp_package() { :; }; install_package() { :; }
    curl() {
        local output='' url='' argument
        while (( $# )); do
            argument=$1; shift
            case $argument in -o) output=$1; shift;; -H) shift;; https://*) url=$argument;; esac
        done
        [[ $output == "$ARCHITECTURE_CASE_ROOT/"* ]] || return 96
        printf '%s\n' "$url" >> download.calls
        if [[ $url == https://first.invalid/* ]]; then printf 'partial' > "$output"; return 22; fi
        [[ $url == https://second.invalid/* ]] || return 97
        head -c 10000 /dev/zero > "$output"
    }
    main --package item
    architecture_assert_equal "$(wc -l < download.calls)" 2 'direct main ordered actual download'
    [[ -s $SETUP_PKGS_DIR/pkgs/$architecture/item-1.x86_64.rpm ]]
    # A final failure cannot trigger selection of a different minor/property.
    printf 'rhel_9_6_x86_64_pkgs_url=https://forbidden.invalid\n' >> "$properties_file"
    local status=0
    curl() {
        [[ $* != *forbidden.invalid* ]] || return 96
        printf 'failed\n' >> failed.calls
        return 22
    }
    (download_package "$architecture" missing-1.x86_64.rpm) 2> failed.log || status=$?
    architecture_assert_equal "$status" 11 'final retrieval failure retained'
    architecture_assert_equal "$(wc -l < failed.calls)" 2 'no additional minor retrieval'
    [[ $(< failed.log) == *second.invalid* ]]
    # A normal direct request can reuse an exact index but fails at its first
    # network need when active mirrors are absent. Built requests bypass both.
    : > "$properties_file"
    printf 'architecture=%s\n' "$architecture" > "$properties_file"
    status=0
    (main --package unavailable) 2> absent.log || status=$?
    [[ $status != 0 ]]
    [[ $(< absent.log) == *'No package matching'* ]]
    printf 'uncached-1.x86_64.rpm\n' > "$index_path"
    status=0
    (main --package uncached) 2> absent.log || status=$?
    architecture_assert_equal "$status" 114 'missing mirror failure at actual network need'
    main --package _built
}

index_pinned_mirrors_and_cache() {
    index_load
    index_seed_mirrors
    local reads=0 calls=0
    package_metadata_read() { reads=$((reads + 1)); local -n out=$2; out=$(cat "$1"); }
    download_packages_list "$architecture"
    printf 'rhel_9_8_x86_64_pkgs_url=https://changed.invalid\n' > "$properties_file"
    try_download_package() {
        calls=$((calls + 1))
        printf '%s\n' "$3" >> retry.calls
        [[ $3 == https://second.invalid/* ]]
    }
    download_package "$architecture" item-1.x86_64.rpm
    download_package "$architecture" other-1.x86_64.rpm
    architecture_assert_equal "$reads" 1 'one pinned active-property read'
    architecture_assert_equal "$calls" 4 'ordered retries reuse mirror selection'
    [[ $(< retry.calls) != *changed.invalid* ]]
    # No index lookup or cached RPM reuse should resolve missing mirrors.
    package_metadata_context "$architecture" "$SETUP_PKGS_DIR" package_context
    : > "$properties_file"
    mkdir -p "$SETUP_PKGS_DIR/pkgs/$architecture"
    head -c 10000 /dev/zero > "$SETUP_PKGS_DIR/pkgs/$architecture/cached-1.x86_64.rpm"
    download_packages_list "$architecture"
    download_package "$architecture" cached-1.x86_64.rpm
    architecture_assert_equal "$reads" 1 'offline index and cache reuse'
}

index_selected_list_copy() {
    index_load
    index_seed_mirrors
    printf '_selected\n' > "$SETUP_PKGS_DIR/pkgs/python/python_rhel_9.6_x86_64.txt"
    # Real list selection/synchronization/copy; only remote transport is stubbed.
    scp() {
        [[ $1 == "$ARCHITECTURE_CASE_ROOT/"* ]] || return 96
        if [[ $2 == */dependencies.list ]]; then printf '%s\n' "$1" > copied.path; fi
    }
    SSH_CONFIG_ENTRY=fixture
    install_packages() { setup_remote_install full_install; }
    main
    architecture_assert_equal "$(< copied.path)" "$SETUP_PKGS_DIR/pkgs/python/python_rhel_9.6_x86_64.txt" 'copy selected source'
    architecture_assert_equal "$(tail -n 1 "$SETUP_PKGS_DIR/pkgs/python/last")" last=_selected 'synchronize selected source'
}

index_windows_held_destination() {
    case $(uname -s) in MINGW*|MSYS*) ;; *) echo 'Windows held-destination check is separately required'; return 0;; esac
    index_load
    index_seed_mirrors
    printf 'old held bytes\n' > "$index_path"
    cp "$index_path" before.index
    cat > hold.ps1 <<'POWERSHELL'
param([string]$Target, [string]$Ready, [string]$Release)
$ErrorActionPreference = 'Stop'
$handle = [IO.File]::Open($Target, 'Open', 'Read', 'Read')
try {
    [IO.File]::WriteAllText($Ready, 'ready')
    $deadline = [DateTime]::UtcNow.AddSeconds(45)
    while (-not [IO.File]::Exists($Release)) {
        if ([DateTime]::UtcNow -gt $deadline) { throw 'release handshake timed out' }
        Start-Sleep -Milliseconds 100
    }
} finally { $handle.Dispose() }
POWERSHELL
    powershell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass \
        -File "$(cygpath -w "$PWD/hold.ps1")" -Target "$(cygpath -w "$index_path")" \
        -Ready "$(cygpath -w "$PWD/ready")" -Release "$(cygpath -w "$PWD/release")" > holder.log 2>&1 &
    local holder=$! deadline=$((SECONDS + 20)) status=0
    trap 'touch release; wait "$holder" || true' EXIT
    while [[ ! -f ready ]]; do
        (( SECONDS < deadline )) || { cat holder.log; return 1; }
        sleep 0.1
    done
    (CPLX_RELOAD_PACKAGES=1; download_packages_list "$architecture") 2> held.log || status=$?
    architecture_assert_equal "$status" 115 'held destination really rejects replacement'
    cmp before.index "$index_path"
    [[ ! -e completion.calls ]]
    touch release
    wait "$holder"
    trap - EXIT
    CPLX_RELOAD_PACKAGES=1
    download_packages_list "$architecture"
    [[ $(< "$index_path") == alpha* ]]
}

architecture_index_suite() {
    local name
    for name in guard_matrix direct_built_and_empty lookup_read_only generation_publication \
        generation_failures pinned_mirrors_and_cache terminal_downloads selected_list_copy; do
        architecture_run_case "index_$name"
    done
    case $(uname -s) in
        MINGW*|MSYS*) architecture_run_case index_windows_held_destination;;
        *) echo 'NOT RUN: Windows held-destination check is separately required';;
    esac
}
