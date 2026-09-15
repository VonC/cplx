#!/bin/bash
# Cumulative architecture checks run against copied fixtures, with live-tree
# preservation checked on every exit, including a failing or fatal test case.
# Step 4 adds entry-point cases: the real setup_packages.sh process runs with
# recording transport stubs, so fallback, generation, progress and remote list
# copying are observed end to end without reaching a network or a host.
set -euo pipefail
# shellcheck source-path=SCRIPTDIR
VERIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$VERIFY_DIR/../.." && pwd)"
cd "$REPO_ROOT"
if [[ $# != 2 || $1 != --step || ! $2 =~ ^[1-4]$ ]]; then
    echo 'Usage: verify.architecture-fallback.sh --step 1..4' >&2
    exit 2
fi
VERIFY_STEP=$2
START_SECONDS=$SECONDS
VERIFY_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/cplx-architecture.XXXXXXXX")
# Use the drive path on Git Bash: a child shell can expand /tmp to /c/Users/...
# while the parent retains the mount alias, defeating lexical containment checks.
case $(uname -s) in
    MINGW*|MSYS*)
        VERIFY_ROOT=$(cygpath -alm "$VERIFY_ROOT")
        VERIFY_ROOT=${VERIFY_ROOT,}
        VERIFY_ROOT="/${VERIFY_ROOT/:/}"
        ;;
esac
export VERIFY_ROOT

architecture_manifest() {
    local destination=$1
    git status --porcelain --ignored -- src/setups > "$destination.status"
    # Hash metadata and explicit transient targets, including ignored files;
    # cache RPMs get only a path/size/timestamp inventory, never content reads.
    find src/setups -type f \( -name '*.sh' -o -name '*.bat' -o -name '*.cmd' \
        -o -name '*.properties' -o -name 'steps*.md' -o -name '*.txt' \
        -o -name last -o -name '*.log' -o -name '*.tmp' -o -name '*.bak' \) \
        ! -name '*.rpm' -print0 | sort -z > "$destination.paths"
    xargs -0 -r sha256sum < "$destination.paths" > "$destination.content"
    find src/setups/pkgs -type f -name '*.rpm' -printf '%p\t%s\t%T@\n' |
        LC_ALL=C sort > "$destination.cache"
}

architecture_preserved() {
    local suffix failed=0
    architecture_manifest "$VERIFY_ROOT/after"
    for suffix in status paths content cache; do
        if ! cmp -s "$VERIFY_ROOT/before.$suffix" "$VERIFY_ROOT/after.$suffix"; then
            echo "FAIL: live setup $suffix changed" >&2
            failed=1
        fi
    done
    return "$failed"
}

architecture_finish() {
    local result=$?
    trap - EXIT
    if architecture_preserved; then
        echo 'PASS: live setup metadata/status/cache inventory preserved'
    else
        result=1
    fi
    # Only the mktemp-owned absolute fixture path may be recursively removed.
    if [[ $VERIFY_ROOT == /*/cplx-architecture.* && -d $VERIFY_ROOT ]]; then
        rm -rf -- "$VERIFY_ROOT"
    else
        echo 'FAIL: unexpected fixture cleanup path' >&2
        result=1
    fi
    echo "Architecture gate: exit=$result elapsed=$((SECONDS - START_SECONDS))s"
    exit "$result"
}
architecture_manifest "$VERIFY_ROOT/before"
trap architecture_finish EXIT

architecture_fixture() {
    local target=$1 name
    [[ $target == "$VERIFY_ROOT/"* ]] || return 1
    mkdir -p "$target/src/"{setups/pkgs/python,utils,echos} "$target/bin"
    cp "$REPO_ROOT/src/setups/setup_packages.sh" "$target/src/setups/"
    if [[ -f $REPO_ROOT/src/setups/package_metadata.sh ]]; then
        cp "$REPO_ROOT/src/setups/package_metadata.sh" "$target/src/setups/"
    fi
    if [[ -f $REPO_ROOT/src/setups/package_index.sh ]]; then
        cp "$REPO_ROOT/src/setups/package_index.sh" "$target/src/setups/"
    fi
    if [[ -f $REPO_ROOT/src/setups/package_progress.sh ]]; then
        cp "$REPO_ROOT/src/setups/package_progress.sh" "$target/src/setups/"
    fi
    cp "$REPO_ROOT/src/utils/"{properties,steps}.sh "$target/src/utils/"
    cp "$REPO_ROOT/src/echos/echos" "$target/src/echos/"
    printf 'architecture=rhel_9.8_x86_64\n' > "$target/src/setups/setup.properties"
    printf '# Synthetic steps\n' > "$target/src/setups/steps.md"
    : > "$target/network.calls"
    # Step 1 declares no external calls, so reject all calls and all output
    # paths before the stub can write anything except its fixture call log.
    for name in ssh scp curl; do
        cat > "$target/bin/$name" <<'STUB'
#!/bin/bash
[[ ${ARCHITECTURE_CASE_ROOT:-} == "$VERIFY_ROOT/"* ]] || exit 96
printf '%s\n' "$0 $*" >> "$ARCHITECTURE_CASE_ROOT/network.calls"
echo 'Unexpected network call in metadata fixture' >&2
exit 97
STUB
        chmod +x "$target/bin/$name"
    done
}

architecture_assert_equal() {
    if [[ $1 != "$2" ]]; then
        printf 'FAIL: %s: expected <%s>, got <%s>\n' "$3" "$2" "$1" >&2
        return 1
    fi
}

architecture_run_case() {
    local name=$1 expected=${2:-0} result=0
    local target="$VERIFY_ROOT/$name"
    architecture_fixture "$target"
    # Do not put the case function in an if/|| condition: that would suppress
    # errexit inside the entire case and silently discard failed assertions.
    set +e
    (
        set -e
        export ARCHITECTURE_CASE_ROOT=$target
        export PATH="$target/bin:$PATH"
        cd "$target"
        "$name"
    ) > "$target/case.log" 2>&1
    result=$?
    set -e
    if [[ $result != "$expected" || -s $target/network.calls ]]; then
        cat "$target/case.log" >&2
        echo "FAIL: $name exit=$result expected=$expected" >&2
        return 1
    fi
    echo "PASS: $name"
}

# Real curated lists (never an exact 9.8 copy), the tracked steps file with its
# completion marker, 9.6 mirrors plus lower/higher decoys and a decoy 9.6 index.
# Stubs replace only transport and record calls; all local paths stay in the case.
architecture_entry_stage() {
    local tool list
    mkdir -p src/setups/env/bin src/setups/pkgs/git remote listings
    : > src/setups/env/bin/packages_management.sh
    sed -E 's/\(#download_packages_list\)( \(done: ✅\))?/(#download_packages_list) (done: ✅)/' \
        "$REPO_ROOT/src/setups/steps.md" > src/setups/steps.md
    for tool in python git; do
        for list in "$REPO_ROOT/src/setups/pkgs/$tool/${tool}_"*.txt; do
            [[ $list == *_rhel_9.8_* ]] || cp "$list" "src/setups/pkgs/$tool/"
        done
    done
    printf '%s\n' architecture=rhel_9.8_x86_64 cplx_path=/fixture/target \
        rhel_9_4_x86_64_pkgs_url=https://decoy.fixture/lower/ \
        'rhel_9_6_x86_64_pkgs_url=https://base.fixture/Packages/, https://stream.fixture/Packages/' \
        rhel_9_9_x86_64_pkgs_url=https://decoy.fixture/higher/ > src/setups/setup.properties
    printf 'decoy-9.6-1.0-1.el9.x86_64.rpm\n' > src/setups/pkgs/packages_rhel_9.6_x86_64.txt
    {
        printf '<!-- padding -->\n%.0s' {1..50}
        cat src/setups/pkgs/{python,git}/*_rhel_9.6_x86_64.txt | tr -d '\r' |
            grep -vE '^[[:space:]]*(#|$)' | sed 's/\\+/+/g' | sort -u |
            sed 's/.*/<a href="&-1.0-1.el9.x86_64.rpm">&<\/a>/'
    } > listings/base
    { printf '<!-- padding -->\n%.0s' {1..50}; printf '<a href="stream-only-1.0-1.el9.noarch.rpm">s</a>\n'; } > listings/stream
    cat > bin/curl <<'STUB'
#!/bin/bash
root=$ARCHITECTURE_CASE_ROOT output='' url=''
[[ $root == "$VERIFY_ROOT/"* ]] || exit 96
while (( $# )); do
    case $1 in -o) output=$2; shift;; -H) shift;; https://*) url=$1;; esac
    shift
done
case $url in
    https://base.fixture/*|https://stream.fixture/*|https://exact.fixture/*) ;;
    *) printf 'forbidden %s\n' "$url" >> "$root/remote.calls"; exit 96;;
esac
if [[ -z $output ]]; then
    printf 'listing %s\n' "$url" >> "$root/remote.calls"
    case $url in https://stream.fixture/*) cat "$root/listings/stream";; *) cat "$root/listings/base";; esac
    exit 0
fi
[[ $output == "$root/"* ]] || { printf 'Rejected curl output path: <%s> (root <%s>)\n' "$output" "$root" >&2; exit 96; }
printf 'download %s\n' "$url" >> "$root/remote.calls"
[[ ! -e $root/downloads.fail ]] || exit 22
head -c 10000 /dev/zero > "$output"
STUB
    cat > bin/ssh <<'STUB'
#!/bin/bash
root=$ARCHITECTURE_CASE_ROOT
[[ $root == "$VERIFY_ROOT/"* && $1 == fixture ]] || exit 96
case $2 in
    "test -e '/fixture/target/tools/pkgs/"*"'") name=${2##*/}; [[ -e $root/remote/${name%\'} ]];;
    *install_packages_for_tool*) printf 'install %s\n' "$CPLX_TOOL" >> "$root/remote.calls"; echo 0;;
    'cat /fixture/target/tools/pkgs.log') echo 'fixture remote log';;
    *) exit 97;;
esac
STUB
    cat > bin/scp <<'STUB'
#!/bin/bash
root=$ARCHITECTURE_CASE_ROOT
[[ $root == "$VERIFY_ROOT/"* && $1 == "$root/"* && $2 == fixture:/fixture/target/* ]] || exit 96
printf 'scp %s\n' "${2#fixture:}" >> "$root/remote.calls"
cp "$1" "$root/remote/${2##*/}"
STUB
    chmod +x bin/curl bin/ssh bin/scp
}

architecture_entry_run() {
    local expected=$1 status=0
    : > remote.calls
    set +e
    CPLX_TOOL=$2 SSH_CONFIG_ENTRY=fixture CPLX_SP_REPEAT='' CPLX_RELOAD_PACKAGES='' \
        CPLX_FORCE_RELOAD_PACKAGES='' bash src/setups/setup_packages.sh > entry.log 2>&1
    status=$?
    set -e
    if [[ $status != "$expected" ]]; then tail -n 20 entry.log >&2; fi
    architecture_assert_equal "$status" "$expected" "$2 entry-point status"
    architecture_refute '^forbidden' remote.calls
}

architecture_refute() {
    if grep -Eq "$1" "$2"; then
        printf 'FAIL: unexpected <%s> in %s\n' "$1" "$2" >&2
        return 1
    fi
}

architecture_entry_fallback() {
    architecture_entry_stage
    local tool list active final name seen=''
    # AC1 starts with neither minor's index and only the retained active mirror.
    rm src/setups/pkgs/packages_rhel_9.6_x86_64.txt
    sed -i '/^rhel_9_[49]_x86_64_pkgs_url=/d' src/setups/setup.properties
    cp src/setups/setup.properties properties.before
    for tool in python git; do
        list=src/setups/pkgs/$tool/${tool}_rhel_9.6_x86_64.txt
        active=$(tr -d '\r' < "$list" | grep -vE '^[[:space:]]*(#|$)')
        final=${active##*$'\n'}
        # Legacy one-line state at the final active entry, as the host retains.
        printf '%s\n' "$final" > "src/setups/pkgs/$tool/last"
        architecture_entry_run 0 "$tool"
        [[ $(< entry.log) == *"Package metadata list: rhel_9.8_x86_64 -> "*"/$list"* ]]
        grep -Fq 'Package metadata mirror: rhel_9.8_x86_64 -> rhel_9_6_x86_64_pkgs_url' entry.log
        grep -Fq "Restarting '$list' at first active entry: legacy or malformed progress" entry.log
        architecture_assert_equal "$(grep -c 'processed successfully' entry.log)" "$(wc -l <<< "$active")" "$tool active entries"
        # The detected-key RPM cache is shared: Git downloads only what Python did not.
        architecture_assert_equal "$(grep -c '^download https://base.fixture/' remote.calls)" \
            "$(sort -u <<< "$active" | comm -13 <(sort -u <<< "$seen") - | wc -l)" "$tool uncached downloads"
        seen+=$active$'\n'
        for name in zlib-devel libcom_err libxslt elfutils-libelf; do
            if grep -Fxq "$name" "$list"; then grep -Fq "Line '$name' processed successfully" entry.log; fi
        done
        cmp "$list" remote/dependencies.list
        printf 'cplx-package-progress-v1\narchitecture=rhel_9.8_x86_64\nlist=%s\nlast=%s\n' "$list" "$final" |
            cmp - "src/setups/pkgs/$tool/last"
        architecture_assert_equal "$(grep -c "^install $tool\$" remote.calls)" 1 "$tool remote installation"
        if [[ $tool == python ]]; then
            [[ ! -e src/setups/pkgs/packages_rhel_9.6_x86_64.txt ]]
            # A later unrelated snapshot must remain untouched by Git's reuse.
            printf 'decoy-9.6-1.0-1.el9.x86_64.rpm\n' > src/setups/pkgs/packages_rhel_9.6_x86_64.txt
            cp src/setups/pkgs/packages_rhel_9.6_x86_64.txt decoy.before
        fi
    done
    # Python generated the detected-key index; Git reused it without listings.
    architecture_assert_equal "$(grep -c '^listing ' remote.calls)" 0 'index generated once'
    grep -Fxq zlib-devel-1.0-1.el9.x86_64.rpm src/setups/pkgs/packages_rhel_9.8_x86_64.txt
    grep -Fxq stream-only-1.0-1.el9.noarch.rpm src/setups/pkgs/packages_rhel_9.8_x86_64.txt
    cmp decoy.before src/setups/pkgs/packages_rhel_9.6_x86_64.txt
    cmp properties.before src/setups/setup.properties
}

architecture_entry_resume() {
    architecture_entry_stage
    local cursor
    architecture_entry_run 0 python
    architecture_assert_equal "$(grep -c '^listing ' remote.calls)" 2 'first run lists both selected URLs'
    cursor=$(tr -d '\r' < src/setups/pkgs/python/python_rhel_9.6_x86_64.txt | grep -vE '^[[:space:]]*(#|$)' | tail -n 4 | head -n 1)
    sed -i "s/^last=.*/last=$cursor/" src/setups/pkgs/python/last
    architecture_entry_run 0 python
    grep -Fq "Resuming processing after line: '$cursor'" entry.log
    architecture_assert_equal "$(grep -c 'processed successfully' entry.log)" 3 'same identity resumes after cursor'
    architecture_refute '^(listing|download) |^scp .*\.rpm$' remote.calls
    architecture_refute 'Restarting|Package metadata mirror' entry.log
    grep -q '^install python$' remote.calls
}

architecture_entry_exact_override() {
    architecture_entry_stage
    local list=src/setups/pkgs/python/python_rhel_9.8_x86_64.txt
    printf 'zlib-devel\nsqlite-devel\n' > "$list"
    printf 'rhel_9_8_x86_64_pkgs_url=https://exact.fixture/Packages/\n' >> src/setups/setup.properties
    architecture_entry_run 0 python
    architecture_refute 'Package metadata' entry.log
    cmp "$list" remote/dependencies.list
    grep -Fxq "list=$list" src/setups/pkgs/python/last
    architecture_assert_equal "$(grep -c 'processed successfully' entry.log)" 2 'distinct exact list wins'
    architecture_refute '^(listing|download) https://(base|stream)' remote.calls
    grep -q '^download https://exact.fixture/' remote.calls
}

architecture_entry_terminal_failures() {
    architecture_entry_stage
    local list=src/setups/pkgs/python/python_rhel_9.6_x86_64.txt
    printf 'zlib-devel\nabsent-package\n' > "$list"
    # fatal 301 reaches the process boundary as 301 modulo 256.
    architecture_entry_run 45 python
    grep -Fq "No package matching 'absent-package'" entry.log
    grep -Fxq last=zlib-devel src/setups/pkgs/python/last
    architecture_refute '^install ' remote.calls
    printf 'sqlite-devel\n' > "$list"
    touch downloads.fail
    architecture_entry_run 11 python
    architecture_assert_equal "$(grep -c '^download ' remote.calls)" 2 'ordered retries, no other minor'
    grep -Fq 'Failed to download package' entry.log
    architecture_refute '^install |^listing ' remote.calls
    architecture_refute 'Installation completed|All lines have been processed' entry.log
}

# Real RHEL acceptance exposed a literal wildcard in this existing Git hook.
# Exercise directory copying and path rewriting without extracting an RPM.
architecture_entry_autoconf_hook() {
    # shellcheck disable=SC1091
    source "$REPO_ROOT/src/setups/env/bin/packages_management.sh"
    root="$PWD/autoconf root"
    mkdir -p "$root/opt/rh/autoconf271/bin" "$root/opt/rh/autoconf271/share" \
        "$root/usr/bin" "$root/etc/asciidoc"
    printf '%s\n' '#!/bin/sh' 'prefix=/opt/rh/autoconf271' > "$root/opt/rh/autoconf271/bin/autoconf"
    cp "$root/opt/rh/autoconf271/bin/autoconf" "$root/opt/rh/autoconf271/bin/autoreconf"
    printf 'support data\n' > "$root/opt/rh/autoconf271/share/support"
    : > "$root/etc/asciidoc/docbook45.conf"
    task() { :; }
    ok() { :; }
    error() { printf '%s\n' "$*" >&2; }
    fatal() { printf '%s\n' "$1" >&2; exit "$2"; }
    local result
    # Use the production caller's shell contract for the existing hook counters.
    set +e
    post_install_autoconf271
    result=$?
    set -e
    architecture_assert_equal "$result" 0 'autoconf post-install status'
    grep -Fxq "prefix=$root/usr" "$root/usr/bin/autoconf"
    grep -Fxq "prefix=$root/usr" "$root/usr/bin/autoreconf"
    cmp "$root/opt/rh/autoconf271/share/support" "$root/usr/share/support"
    cp "$root/usr/bin/autoconf" autoconf.before
    set +e
    post_install_autoconf271
    result=$?
    set -e
    architecture_assert_equal "$result" 0 'autoconf post-install reuse status'
    cmp autoconf.before "$root/usr/bin/autoconf"
}

architecture_entry_suite() {
    local name
    for name in fallback resume exact_override terminal_failures autoconf_hook; do
        architecture_run_case "architecture_entry_$name"
    done
}

# Run the repository's mandatory tracked-script floor before effort checks.
bash src/utils/lint_shell.sh
scripts=(docs/v0.27.0/verify.architecture-fallback.sh
    docs/v0.27.0/verify.architecture-metadata.sh)
if [[ -f src/setups/package_metadata.sh ]]; then
    scripts+=(src/setups/package_metadata.sh)
fi
if (( VERIFY_STEP >= 2 )); then
    scripts+=(docs/v0.27.0/verify.architecture-index.sh)
    if [[ -f src/setups/package_index.sh ]]; then
        scripts+=(src/setups/package_index.sh)
    fi
fi
if (( VERIFY_STEP >= 3 )); then
    scripts+=(docs/v0.27.0/verify.architecture-progress.sh)
    if [[ -f src/setups/package_progress.sh ]]; then
        scripts+=(src/setups/package_progress.sh)
    fi
fi
for script in "${scripts[@]}"; do bash -n "$script"; done
shellcheck "${scripts[@]}"
# Checked explicitly above; the Windows ShellCheck binary cannot resolve the
# Git Bash runtime source directory.
# shellcheck disable=SC1091
source "$VERIFY_DIR/verify.architecture-metadata.sh"
architecture_metadata_suite
if (( VERIFY_STEP >= 2 )); then
    # shellcheck disable=SC1091
    source "$VERIFY_DIR/verify.architecture-index.sh"
    architecture_index_suite
fi
if (( VERIFY_STEP >= 3 )); then
    # shellcheck disable=SC1091
    source "$VERIFY_DIR/verify.architecture-progress.sh"
    architecture_progress_suite
fi
if (( VERIFY_STEP >= 4 )); then
    architecture_entry_suite
fi
