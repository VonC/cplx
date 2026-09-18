#!/bin/bash
# Step 5 regressions: private-stage cleanup, real gate/tar inventory agreement,
# and the inherited residual register's exact ownership accounting.
# The checker observation seam records inputs; full closure runs separately in
# the cumulative runner. These fixtures are not candidate acceptance evidence.
set -euo pipefail
root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/tools-release-package.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
mkdir -p "$scratch/source/bin" "$scratch/source/closure"
cp "$root"/src/setups/env/bin/*.sh "$scratch/source/bin/"
cp "$root"/src/setups/env/closure/closure-{config,envelope}.txt "$scratch/source/closure/"
cat > "$scratch/source/bin/closure_check.sh" <<'CHECKER'
#!/bin/bash
set -euo pipefail
[[ $1 == --prefix && $2 != "$HOME" && $2 == "$HOME"/.cplx-pkgstage.* ]]
[[ ! -e $2/tools/python/root/a.out && ! -L $2/tools/python/root/a.out ]]
cp -a -- "$2/tools" "$FIXTURE_OUTPUT/gated"
printf '%s\n' "$2" > "$FIXTURE_OUTPUT/gate.prefix"
CHECKER

package_case() (
    set -euo pipefail
    local mode=$1 base=$scratch/$1 file status=0
    mkdir -p "$base/home/tools/python/root/"{lib64,usr/lib64,usr/bin} \
        "$base/home/tools/git/root/lib64" "$base/output" "$base/unpacked"
    export HOME=$base/home FIXTURE_OUTPUT=$base/output
    # Real loader bytes exercise the unchanged installer's selected identity.
    cp -L /lib64/ld-linux-x86-64.so.2 "$HOME/tools/python/root/lib64/"
    cp "$HOME/tools/python/root/lib64/ld-linux-x86-64.so.2" "$HOME/tools/git/root/lib64/"
    for file in libc.so.6 libm.so.6 libpthread.so.0 libdl.so.2 librt.so.1 \
        libsqlite3.so.0 libssl.so.3 libcrypto.so.3; do
        printf 'protected provider %s\n' "$file" > "$HOME/tools/python/root/usr/lib64/$file"
    done
    ln -s libsqlite3.so.0 "$HOME/tools/python/root/usr/lib64/libsqlite3.so"
    printf 'compiler\n' > "$HOME/tools/python/root/usr/bin/gcc"
    printf 'unrelated name\n' > "$HOME/tools/git/root/a.out"
    printf 'environment\n' > "$HOME/.env"
    case "$mode" in
        regular) cp /bin/true "$HOME/tools/python/root/a.out" ;;
        absent) ;;
        symlink) ln -s usr/lib64/libsqlite3.so.0 "$HOME/tools/python/root/a.out" ;;
        hardlink) ln "$HOME/tools/python/root/usr/lib64/libsqlite3.so.0" "$HOME/tools/python/root/a.out" ;;
        directory) mkdir "$HOME/tools/python/root/a.out"; printf 'keep\n' > "$HOME/tools/python/root/a.out/sentinel" ;;
        python-link)
            mv "$HOME/tools/python" "$base/python"
            ln -s "$base/python" "$HOME/tools/python"
            cp /bin/true "$base/python/root/a.out" ;;
        root-link)
            mv "$HOME/tools/python/root" "$base/python-root"
            ln -s "$base/python-root" "$HOME/tools/python/root"
            cp /bin/true "$base/python-root/a.out" ;;
        *) exit 2 ;;
    esac
    cp -a "$HOME/tools" "$base/live.before"
    for file in python python-root; do
        [[ ! -d $base/$file ]] || cp -a "$base/$file" "$base/$file.before"
    done
    bash "$scratch/source/bin/pkg_tools.sh" > "$base/package.log" 2>&1 || status=$?
    diff -r --no-dereference "$base/live.before" "$HOME/tools"
    for file in python python-root; do
        [[ ! -d $base/$file.before ]] || diff -r --no-dereference "$base/$file.before" "$base/$file"
    done
    case "$mode" in
        directory|python-link|root-link)
            [[ $status -ne 0 && ! -e $FIXTURE_OUTPUT/gate.prefix ]]
            [[ ! -d $HOME/pkgs || -z $(find "$HOME/pkgs" -name '*.tar.gz' -print -quit) ]]
            ;;
        *)
            if ((status)); then cat "$base/package.log"; return "$status"; fi
            [[ -f $FIXTURE_OUTPUT/gate.prefix && -L $HOME/pkgs/tools.latest.tar.gz ]]
            tar -xzf "$HOME/pkgs/tools.latest.tar.gz" -C "$base/unpacked"
            diff -r --no-dereference "$FIXTURE_OUTPUT/gated" "$base/unpacked/tools"
            cmp "$HOME/.env" "$base/unpacked/.env"
            [[ ! -e $base/unpacked/tools/python/root/a.out && ! -L $base/unpacked/tools/python/root/a.out ]]
            [[ ! -e $base/unpacked/tools/python/root/usr/bin/gcc ]]
            cmp "$HOME/tools/git/root/a.out" "$base/unpacked/tools/git/root/a.out"
            for file in "$HOME"/tools/python/root/usr/lib64/*; do
                cmp "$file" "$base/unpacked/tools/python/root/usr/lib64/${file##*/}"
            done
            cmp "$HOME/tools/python/root/lib64/ld-linux-x86-64.so.2" \
                "$base/unpacked/tools/python/root/lib64/ld-linux-x86-64.so.2"
            [[ $base/unpacked/tools/git/root/lib64/ld-linux-x86-64.so.2 \
                -ef $base/unpacked/tools/python/root/lib64/ld-linux-x86-64.so.2 ]]
            [[ ! -e $(cat "$FIXTURE_OUTPUT/gate.prefix") ]]
            ;;
    esac
    printf 'PASS package/%s: preserved live bytes and boundaries\n' "$mode"
)
for mode in regular absent symlink hardlink directory python-link root-link; do
    package_case "$mode"
done

# Load only the literal register and four named, unchanged harness functions.
# The boundary fixtures supply reconciled observations, while the production
# bookkeeping decides stale, owned and unadjudicated cases. Do not source the
# whole acceptance harness: it would run its independent environment preflight.
inherited=$root/docs/v0.27.0/verify.relocation-rpath.sh
sed -n '/^STEP4_ARCHIVE_DEFECTS=/,/^$/p' "$inherited" > "$scratch/register.sh"
for function in step4_defect_owner step4_residual_suite step4_field step4_hex_to_path; do
    awk -v name="$function" '$0 == name "() {" {emit=1} emit {print} emit && /^}$/ {exit}' \
        "$inherited" >> "$scratch/register.sh"
done
# shellcheck disable=SC1090,SC1091
source "$scratch/register.sh"
[[ -z $STEP4_ARCHIVE_DEFECTS ]] || { printf 'FAIL: unresolved production residual register\n' >&2; exit 1; }
for function in step4_defect_owner step4_residual_suite step4_field step4_hex_to_path; do
    declare -F "$function" > /dev/null
done

# Boundary callbacks are invoked by the extracted production functions.
# shellcheck disable=SC2317
register_case() (
    set -euo pipefail
    local mode=$1 fixture_selected='' failures=0
    # Globals consumed by the extracted, unchanged harness functions.
    # shellcheck disable=SC2034
    local SCRATCH=$scratch/register-$1 STEP2_INV_LIBS='' STEP2_INV_GITS='' STEP2_INV_PYTHON='bin/python' cases=0
    mkdir -p "$SCRATCH/prefix"
    case "$mode" in
        clean) STEP4_ARCHIVE_DEFECTS='' ;;
        stale) STEP4_ARCHIVE_DEFECTS='tools/python/root/a.out|fixture owner' ;;
        unowned) STEP4_ARCHIVE_DEFECTS=''; fixture_selected='tools/python/root/unowned.out' ;;
        owned) STEP4_ARCHIVE_DEFECTS='tools/python/root/a.out|fixture owner'; fixture_selected='tools/python/root/a.out' ;;
        replaced) STEP4_ARCHIVE_DEFECTS='tools/python/root/a.out|fixture owner'; fixture_selected='tools/python/root/unowned.out' ;;
        *) exit 2 ;;
    esac
    section() { :; }
    note() { printf 'NOTE %s %s\n' "$1" "$2"; }
    pass() { printf 'PASS %s %s\n' "$1" "$2"; }
    fail() { failures=$((failures+1)); printf 'FAIL %s %s\n' "$1" "$2"; }
    step2_inventory_oracle() { :; }
    step2_in_set() { return 1; }
    step3_read_capture() { :; }
    step4_runs_after() { :; }
    step4_pass() {
        printf 'CPLX-ELF/1 fixture\n'
        if [[ -n $fixture_selected ]]; then
            printf 'CPLX-ELF/1 obj path=%s case=6\n' "$(printf '%s' "$fixture_selected" | od -An -v -tx1 | tr -d ' \n')"
        fi
    }
    step4_residual_suite "$SCRATCH/prefix" fixture-oracle > "$SCRATCH/report"
    case "$mode" in
        clean) [[ $failures == 0 ]]; grep -q 'assertion: none' "$SCRATCH/report" ;;
        stale) [[ $failures == 1 ]]; grep -q 'FAIL step4/residual-register-stale' "$SCRATCH/report" ;;
        unowned) [[ $failures == 0 ]]; grep -q 'unadjudicated: tools/python/root/unowned.out' "$SCRATCH/report" ;;
        owned) [[ $failures == 0 ]]; grep -q 'owned by fixture owner' "$SCRATCH/report" ;;
        replaced)
            [[ $failures == 1 ]]
            grep -q 'FAIL step4/residual-register-stale' "$SCRATCH/report"
            grep -q 'unadjudicated: tools/python/root/unowned.out' "$SCRATCH/report" ;;
    esac
    # Unowned cases remain explicit Step 6 findings; they must never be
    # interpreted as an empty, discharged residual population by the caller.
    printf 'PASS register/%s: exact inherited ownership result\n' "$mode"
)
for mode in clean stale unowned owned replaced; do register_case "$mode"; done
printf 'PASS tools-release-package: 7 package cases, 5 register controls\n'
