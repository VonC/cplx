#!/bin/bash
# Cumulative architecture checks run against copied fixtures, with live-tree
# preservation checked on every exit, including a failing or fatal test case.
set -euo pipefail
# shellcheck source-path=SCRIPTDIR
VERIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$VERIFY_DIR/../.." && pwd)"
cd "$REPO_ROOT"
if [[ $# != 2 || $1 != --step || ! $2 =~ ^[1-4]$ ]]; then
    echo 'Usage: verify.architecture-fallback.sh --step 1..4' >&2
    exit 2
fi
if [[ $2 != 1 ]]; then
    echo "Step $2 verification is not implemented yet" >&2
    exit 2
fi
START_SECONDS=$SECONDS
VERIFY_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/cplx-architecture.XXXXXXXX")
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

# Run the repository's mandatory tracked-script floor before effort checks.
bash src/utils/lint_shell.sh
scripts=(docs/v0.27.0/verify.architecture-fallback.sh
    docs/v0.27.0/verify.architecture-metadata.sh)
if [[ -f src/setups/package_metadata.sh ]]; then
    scripts+=(src/setups/package_metadata.sh)
fi
for script in "${scripts[@]}"; do bash -n "$script"; done
shellcheck "${scripts[@]}"
# Checked explicitly above; the Windows ShellCheck binary cannot resolve the
# Git Bash runtime source directory.
# shellcheck disable=SC1091
source "$VERIFY_DIR/verify.architecture-metadata.sh"
architecture_metadata_suite
