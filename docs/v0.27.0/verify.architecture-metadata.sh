#!/bin/bash
# Behavioral selector/adapters matrix. The runner provides isolated roots,
# denied-network stubs, assertion helpers and unconditional preservation checks.
# shellcheck source-path=SCRIPTDIR
# Fixtures supply sources at runtime. Nameref outputs and injected IO functions
# are consumed by the helper, which is checked separately by the runner.
# shellcheck disable=SC1091,SC2034,SC2317

metadata_load() {
    # shellcheck source=../../src/setups/package_metadata.sh
    source "$ARCHITECTURE_CASE_ROOT/src/setups/package_metadata.sh"
}

metadata_exact_and_lists() {
    metadata_load
    local -A result=()
    local -a diagnostics=()
    local root="$ARCHITECTURE_CASE_ROOT/src/setups/pkgs" content
    printf 'fallback\n' > "$root/python/python_rhel_9.6_x86_64.txt"
    for content in '' '# deliberately no packages' 'exact'; do
        printf '%s' "$content" > "$root/python/python_rhel_9.8_x86_64.txt"
        package_metadata_list "$root" python rhel_9.8_x86_64 result diagnostics
        architecture_assert_equal "${result[selected_key]}" rhel_9.8_x86_64 'exact list authority'
        architecture_assert_equal "${result[fallback]}" false 'exact flag'
    done
    rm "$root/python/python_rhel_9.8_x86_64.txt"
    package_metadata_list "$root" python rhel_9.8_x86_64 result diagnostics 2> selection.log
    [[ $(< selection.log) == *'list: rhel_9.8_x86_64 -> '*python_rhel_9.6_x86_64.txt* ]]
    architecture_assert_equal "${result[source]}" "$root/python/python_rhel_9.6_x86_64.txt" 'original source'
    architecture_assert_equal "${result[requested_key]}" rhel_9.8_x86_64 'detected key retained'
    architecture_assert_equal "${result[fallback]}" true 'fallback flag'
    # A malformed exact key is still an exact lookup, never a parse failure.
    : > "$root/python/python_custom.txt"
    package_metadata_list "$root" python custom result diagnostics
    architecture_assert_equal "${result[selected_key]}" custom 'unparsed exact key'
    # Indexes and lists of other tools cannot enter the candidate inventory.
    rm "$root/python/python_rhel_9.6_x86_64.txt"
    : > "$root/python/packages_rhel_9.6_x86_64.txt"
    : > "$root/python/git_rhel_9.6_x86_64.txt"
    if package_metadata_list "$root" python rhel_9.8_x86_64 result diagnostics; then return 1; fi
    [[ ${diagnostics[*]} == *'no eligible'* ]]
}

metadata_order_permutations() {
    metadata_load
    local -A result=()
    local -a keys=() sources=() diagnostics=()
    local a b c requested expected count=0
    for requested in rhel_9.8_x86_64 rhel_9.5_x86_64 rhel_9.11_x86_64; do
        case $requested in
            rhel_9.11_*) expected=rhel_9.10_x86_64 ;;
            *) expected=rhel_9.6_x86_64 ;;
        esac
        for a in 6 9 10; do for b in 6 9 10; do for c in 6 9 10; do
            [[ $a != "$b" && $a != "$c" && $b != "$c" ]] || continue
            keys=("rhel_9.${a}_x86_64" "rhel_9.${b}_x86_64" "rhel_9.${c}_x86_64")
            sources=(one two three)
            package_metadata_select "$requested" list keys sources result diagnostics > selector.out
            [[ ! -s selector.out ]]
            architecture_assert_equal "${result[selected_key]}" "$expected" 'permutation ordering'
            count=$((count + 1))
        done; done; done
    done
    architecture_assert_equal "$count" 18 'all permutations executed'
    # Equal candidate numeric minors get a stable literal-key tie break.
    for a in 0 1; do
        if [[ $a == 0 ]]; then keys=(rhel_9.6_x86_64 rhel_09.06_x86_64)
        else keys=(rhel_09.06_x86_64 rhel_9.6_x86_64); fi
        sources=(one two)
        package_metadata_select rhel_9.8_x86_64 list keys sources result diagnostics
        architecture_assert_equal "${result[selected_key]}" rhel_09.06_x86_64 'stable numeric tie'
    done
}

metadata_boundaries() {
    metadata_load
    local -A result=()
    local -a keys=(centos_9.6_x86_64 rhel_8.6_x86_64 rhel_9.6_x86
        rhel_9_x86_64 rhel_9.bad_x86_64 rhel_09.08_x86_64)
    local -a sources=(distribution major machine major-only malformed equal) diagnostics=()
    if package_metadata_select rhel_9.8_x86_64 list keys sources result diagnostics; then return 1; fi
    local reason
    for reason in distribution major machine 'numeric major.minor' 'equal numeric minor' 'no eligible'; do
        [[ ${diagnostics[*]} == *"$reason"* ]]
    done
    [[ ${diagnostics[*]} == *rhel_9.8_x86_64* && ${diagnostics[*]} == *list* ]]
    keys=(centos_8_x86_64); sources=(major-only)
    package_metadata_select centos_8_x86_64 mirror keys sources result diagnostics
    architecture_assert_equal "${result[fallback]}" false 'major-only exact'
    if package_metadata_select centos_8.1_x86_64 mirror keys sources result diagnostics; then return 1; fi
    keys=(centos_8.1_x86_64)
    if package_metadata_select centos_8_x86_64 mirror keys sources result diagnostics; then return 1; fi
    # Long numeric components must not overflow Bash arithmetic.
    keys=(rhel_9.999999999999999999999999_x86_64 rhel_9.10_x86_64)
    sources=(huge ten)
    package_metadata_select rhel_9.9_x86_64 list keys sources result diagnostics
    architecture_assert_equal "${result[selected_key]}" rhel_9.10_x86_64 'large integer comparison'
}

metadata_mirrors() {
    metadata_load
    local -A result=()
    local -a diagnostics=() urls=()
    local file="$ARCHITECTURE_CASE_ROOT/src/setups/setup.properties"
    printf '%s\n' \
        '# rhel_9_8_x86_64_pkgs_url=commented' \
        ' rhel_9_8_x86_64_pkgs_url =    ' \
        'rhel_9_8_x86_64_pkgs_url=ignored-second-exact' \
        'rhel_9_6_x86_64_pkgs_url= https://one.invalid/?a=b,https://two.invalid/ ' \
        'rhel_9_6_x86_64_pkgs_url=ignored-second-fallback' \
        'rhel_9_9_x86_64_pkgs_url=higher' \
        'architecture=rhel_9.8_x86_64' > "$file"
    printf 'rhel_9_8_x86_64_pkgs_url=template-is-not-active\n' > "${file/setup.properties/setup.tpl.properties}"
    package_metadata_mirror "$file" rhel_9.8_x86_64 result diagnostics urls
    architecture_assert_equal "${result[selected_key]}" rhel_9.6_x86_64 'empty first exact is absent'
    architecture_assert_equal "${result[source]}" rhel_9_6_x86_64_pkgs_url 'literal property identity'
    architecture_assert_equal "${result[value]}" 'https://one.invalid/?a=b,https://two.invalid/' 'first trimmed value'
    architecture_assert_equal "${urls[*]}" 'https://one.invalid/?a=b https://two.invalid/' 'ordered URLs'
    # The adapter is literal; invalid URL text is left to download validation.
    # shellcheck disable=SC2016
    printf 'rhel_9_8_x86_64_pkgs_url= $(touch escaped);"not a URL"\r\n' > "$file"
    package_metadata_mirror "$file" rhel_9.8_x86_64 result diagnostics urls
    # shellcheck disable=SC2016
    architecture_assert_equal "${result[value]}" '$(touch escaped);"not a URL"' 'literal property value'
    [[ ! -e escaped ]]
    # The existing reader never addresses a dotted spelling, so neither may this.
    printf '%s\n' 'rhel_9.8_x86_64_pkgs_url=dotted' 'rhel_9_8_x86_64_pkgs_url=canonical' > "$file"
    package_metadata_mirror "$file" rhel_9.8_x86_64 result diagnostics urls
    architecture_assert_equal "${result[source]}" rhel_9_8_x86_64_pkgs_url 'dotted spelling cannot shadow'
    printf '%s\n' 'rhel_9.8_x86_64_pkgs_url=dotted' 'rhel_9_6_x86_64_pkgs_url=six' > "$file"
    package_metadata_mirror "$file" rhel_9.8_x86_64 result diagnostics urls
    architecture_assert_equal "${result[selected_key]}" rhel_9.6_x86_64 'dotted-only exact is absent'
    printf 'centos_8_x86_64_pkgs_url=major-only\n' > "$file"
    package_metadata_mirror "$file" centos_8_x86_64 result diagnostics urls
    architecture_assert_equal "${result[source]}" centos_8_x86_64_pkgs_url 'major-only property'
    : > "$file"
    if package_metadata_mirror "$file" rhel_9.8_x86_64 result diagnostics urls; then return 1; fi
    architecture_assert_equal "${#urls[@]}" 0 'failure clears prior URLs'
}

metadata_read_failures() {
    metadata_load
    local -A result=()
    local -a diagnostics=() urls=()
    local root="$ARCHITECTURE_CASE_ROOT/src/setups/pkgs"
    : > "$root/python/python_rhel_9.8_x86_64.txt"
    : > "$root/python/python_rhel_9.6_x86_64.txt"
    # Inject the IO boundary failure so root and Windows cannot bypass it.
    package_metadata_read() { return 1; }
    if package_metadata_list "$root" python rhel_9.8_x86_64 result diagnostics; then return 1; fi
    [[ ${diagnostics[*]} == *'cannot read'* && ${diagnostics[*]} == *rhel_9.8_x86_64* ]]
    if package_metadata_mirror "$ARCHITECTURE_CASE_ROOT/src/setups/setup.properties" rhel_9.8_x86_64 result diagnostics urls; then return 1; fi
    [[ ${diagnostics[*]} == *'cannot read'* ]]
    metadata_load
    rm "$root/python/python_rhel_9.8_x86_64.txt"
    mkdir "$root/python/python_rhel_9.8_x86_64.txt"
    if package_metadata_list "$root" python rhel_9.8_x86_64 result diagnostics; then return 1; fi
    [[ ${diagnostics[*]} == *'cannot read'* ]]
}

metadata_bounded_reads() {
    metadata_load
    local -A result=()
    local -a diagnostics=() urls=()
    local file="$ARCHITECTURE_CASE_ROOT/src/setups/setup.properties" read_count=0
    printf 'rhel_9_6_x86_64_pkgs_url=first\nrhel_9_6_x86_64_pkgs_url=second\n' > "$file"
    package_metadata_read() {
        read_count=$((read_count + 1))
        local -n read_output=$2
        read_output=$(cat -- "$1")
    }
    package_metadata_mirror "$file" rhel_9.8_x86_64 result diagnostics urls
    architecture_assert_equal "$read_count" 1 'one active properties read'
    : > "$ARCHITECTURE_CASE_ROOT/src/setups/pkgs/python/python_rhel_9.6_x86_64.txt"
    package_metadata_list "$ARCHITECTURE_CASE_ROOT/src/setups/pkgs" python rhel_9.8_x86_64 result diagnostics
    architecture_assert_equal "$read_count" 2 'only chosen list read'
}

metadata_source_guard() {
    local before after
    before=$(find src -type f -exec sha256sum {} + | LC_ALL=C sort)
    # Legacy logging functions tolerate unset optional arguments without -u.
    set +u
    # shellcheck source=../../src/setups/setup_packages.sh
    source "$ARCHITECTURE_CASE_ROOT/src/setups/setup_packages.sh"
    set -u
    metadata_load
    after=$(find src -type f -exec sha256sum {} + | LC_ALL=C sort)
    architecture_assert_equal "$after" "$before" 'source made no persistent changes'
    architecture_assert_equal "$SETUP_PKGS_DIR" "$ARCHITECTURE_CASE_ROOT/src/setups" 'copied source path'
    declare -F package_metadata_select >/dev/null
}

metadata_fatal_exit() {
    # The legacy logger's caller uses post-increment, so match ordinary setup's
    # non-errexit execution while exercising the actual fatal process boundary.
    set +eu
    # shellcheck source=../../src/echos/echos
    source "$ARCHITECTURE_CASE_ROOT/src/echos/echos"
    fatal 'Deliberate fixture process exit' 87
}

architecture_metadata_suite() {
    local name
    for name in metadata_exact_and_lists metadata_order_permutations metadata_boundaries \
        metadata_mirrors metadata_read_failures metadata_bounded_reads metadata_source_guard; do
        architecture_run_case "$name"
    done
    architecture_run_case metadata_fatal_exit 87
    architecture_preserved
    echo 'PASS: preservation checked after fatal fixture exit'
}
