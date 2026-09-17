#!/bin/bash
# Native Linux contract tests: exact wheel bytes, installed ELF equality and
# D10's unchanged lowest-satisfying/second-reading policy. No host resolution.
set -euo pipefail
python="${2:-}"
[[ "${1:-}" = --python && "$python" = /* && -x "$python" ]] || exit 2
root=$(cd -- "${BASH_SOURCE[0]%/*}/../.." && pwd)
helper="$root/src/setups/env/bin/tools_wheel_inventory.sh"
d10="$root/src/setups/env/bin/closure_d10.sh"
scratch=$(mktemp -d "${TMPDIR:-/tmp}/tools-d10.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
cd "$scratch"
mkdir archive gcc11 gcc12 installed wheels
printf 'fixture lock\n' > uv.lock
printf 'int cxx(void) { return 1; } int abi(void) { return 1; }\n' > cxx.c
printf 'int unwind(void) { return 1; }\n' > gcc.c
printf 'extern int cxx(void); extern int abi(void); extern int unwind(void); int use(void) { return cxx()+abi()+unwind(); }\n' > consumer.c
for generation in 11 12; do
    node=29
    [ "$generation" = 11 ] || node=30
    printf 'GLIBCXX_3.4.29 { }; GLIBCXX_3.4.%s { global: cxx; }; CXXABI_1.3 { global: abi; };\n' "$node" > cxx.map
    [ "$generation" != 11 ] || printf 'GLIBCXX_3.4.29 { global: cxx; }; CXXABI_1.3 { global: abi; };\n' > cxx.map
    printf 'GCC_3.0 { global: unwind; };\n' > gcc.map
    gcc -nostdlib -shared -fPIC cxx.c -Wl,-soname,libstdc++.so.6 -Wl,--version-script=cxx.map -o "gcc$generation/libstdc++.so.6"
    gcc -nostdlib -shared -fPIC gcc.c -Wl,-soname,libgcc_s.so.1 -Wl,--version-script=gcc.map -o "gcc$generation/libgcc_s.so.1"
    gcc -nostdlib -shared -fPIC consumer.c -L"gcc$generation" -Wl,--no-as-needed -l:libstdc++.so.6 -l:libgcc_s.so.1 -o "consumer$generation.so"
done
cp gcc11/* archive/
cp consumer11.so archive/extension.so
cp consumer12.so installed/native.so
"$python" - <<'PY'
import zipfile
with zipfile.ZipFile('wheels/native-1-py3-none-linux_x86_64.whl', 'w') as wheel:
    wheel.write('installed/native.so', 'native.so')
    wheel.writestr('native-1.dist-info/METADATA', 'Name: native\nVersion: 1\n')
PY
cases=0
expect() {
    local name="$1" expected="$2" pattern="$3" code=0
    shift 3
    "$@" > result.log 2>&1 || code=$?
    if [ "$code" != "$expected" ] || ! grep -q -- "$pattern" result.log; then
        printf 'FAIL %s: exit %s, expected %s, pattern %s\n' "$name" "$code" "$expected" "$pattern"
        cat result.log
        exit 1
    fi
    cases=$((cases + 1))
    printf 'PASS %s\n' "$name"
}
inventory() { bash "$helper" --python "$python" "$@"; }
measure() { bash "$d10" --root "$scratch/archive" --candidate "11=$scratch/gcc11" --candidate "12=$scratch/gcc12" "$@"; }
wheel_measure() { measure --wheel-root "$scratch/materialized" --wheel-lock "$scratch/uv.lock" --wheel-python "$python" "$@"; }
expect legacy 0 'D10 POLICY: 11' measure
expect zero-headroom 0 'zero spare nodes required' measure
expect capture 0 'wheel inventory: captured' inventory capture --lock uv.lock --wheel-dir wheels --installed-root installed --output inventory.json
expect materialize 0 'wheel inventory: materialized' inventory materialize --lock uv.lock --wheel-dir wheels --inventory inventory.json --destination materialized
# Count real reader/tool calls at the process boundary for the union reading.
export D10_READ_LOG="$scratch/readelf.log" D10_WALK_LOG="$scratch/find.log"
# These exported functions are invoked by closure_elf in the child Bash.
# shellcheck disable=SC2317
readelf() { printf '%s\n' "$*" >> "$D10_READ_LOG"; command readelf "$@"; }
# shellcheck disable=SC2317
find() { printf '%s\n' "$*" >> "$D10_WALK_LOG"; command find "$@"; }
export -f readelf find
expect wheel-demands 0 'D10 POLICY: 12' wheel_measure
unset -f readelf find
mapfile -t reads < "$D10_READ_LOG"
mapfile -t walks < "$D10_WALK_LOG"
[ "${#reads[@]}" -eq 8 ] && [ "${#walks[@]}" -eq 2 ]
declare -A seen_reads=()
for entry in "${reads[@]}"; do
    [ -z "${seen_reads[$entry]:-}" ]
    seen_reads["$entry"]=1
done
printf 'Measured union: walks=%s readelf=%s (archive=3 wheel=1 candidates=4); ' "${#walks[@]}" "${#reads[@]}"
grep 'D10 elapsed' result.log
grep -q 'reading generation  11' result.log
grep -q 'consumer wheel:.*native.*sha256=' result.log
grep -q 'walks archive=1 wheels=1' result.log
grep -q 'require libstdc++.so.6|CXXABI_1.3' result.log
grep -q 'require libgcc_s.so.1|GCC_3.0' result.log
grep -q 'required nodes      4' result.log
expect duplicate-root-walk 0 'walks archive=1 wheels=1' wheel_measure --wheel-root "$scratch/materialized"
printf 'mixed identity' >> archive/libgcc_s.so.1
expect mixed-providers 0 'reading generation  unknown' wheel_measure
cp gcc11/libgcc_s.so.1 archive/libgcc_s.so.1
printf '\177ELFbroken' > archive/broken.so
expect unread-consumer 5 'archive reading is incomplete' wheel_measure
rm archive/broken.so
cp gcc12/* archive/
expect same-second-reading 0 'SETTLED at 12' wheel_measure --previous 12
cp gcc11/* archive/
expect higher-second-reading 1 'HIGHER candidate 12' wheel_measure --previous 11
expect lower-second-reading 1 'LOWER candidate 11' measure --previous 12
expect missing-root 5 'INCONCLUSIVE' measure --wheel-root "$scratch/absent" --wheel-lock uv.lock --wheel-python "$python"
cp uv.lock original.lock
printf 'changed\n' >> uv.lock
expect wrong-lock 5 'INCONCLUSIVE' wheel_measure
expect materialize-lock-mismatch 5 'lock digest' inventory materialize --lock uv.lock --wheel-dir wheels --inventory inventory.json --destination wrong-lock
mv original.lock uv.lock
cp consumer11.so materialized/subjects/native-1-py3-none-linux_x86_64.whl/extra.so
expect extraneous-elf 5 'INCONCLUSIVE' wheel_measure
rm materialized/subjects/native-1-py3-none-linux_x86_64.whl/extra.so
mv materialized/subjects/native-1-py3-none-linux_x86_64.whl/native.so saved.so
expect missing-elf 5 'INCONCLUSIVE' wheel_measure
cp consumer11.so materialized/subjects/native-1-py3-none-linux_x86_64.whl/native.so
expect changed-elf 5 'INCONCLUSIVE' wheel_measure
mv saved.so materialized/subjects/native-1-py3-none-linux_x86_64.whl/native.so
cp installed/native.so installed/extra.so
expect extra-installed 5 'ELF inventory' inventory capture --lock uv.lock --wheel-dir wheels --installed-root installed --output bad.json
rm installed/extra.so
mv installed/native.so saved.so
expect missing-installed 5 'ELF inventory' inventory capture --lock uv.lock --wheel-dir wheels --installed-root installed --output bad.json
mv saved.so installed/native.so
cp wheels/*.whl original.whl
printf 'corrupt' >> wheels/native-1-py3-none-linux_x86_64.whl
expect changed-wheel 5 'wheel digest' inventory materialize --lock uv.lock --wheel-dir wheels --inventory inventory.json --destination corrupt
[ ! -e corrupt ]
mv original.whl wheels/native-1-py3-none-linux_x86_64.whl
"$python" - <<'PY'
import zipfile
with zipfile.ZipFile('wheels/unsafe.whl', 'w') as wheel:
    wheel.writestr('../escape.so', b'\x7fELFbad')
PY
expect unsafe-member 5 'unsafe wheel member' inventory capture --lock uv.lock --wheel-dir wheels --installed-root installed --output bad.json
rm wheels/unsafe.whl
printf 'not a zip' > wheels/corrupt.whl
expect corrupt-wheel 5 'INCONCLUSIVE' inventory capture --lock uv.lock --wheel-dir wheels --installed-root installed --output bad.json
rm wheels/corrupt.whl
# Unsafe ZIP variants use both capture and materialization. The expected
# inventory digest is correct, proving member safety is independently checked.
for mutation in absolute backslash symlink duplicate collision; do
    "$python" - "$mutation" <<'PY'
import hashlib
import json
import sys
import warnings
import zipfile
warnings.simplefilter('ignore', UserWarning)
mode = sys.argv[1]
with zipfile.ZipFile('wheels/bad.whl', 'w') as wheel:
    if mode == 'absolute':
        wheel.writestr('/escape.so', b'bad')
    elif mode == 'backslash':
        wheel.writestr('..\\escape.so', b'bad')
    elif mode == 'symlink':
        info = zipfile.ZipInfo('link')
        info.external_attr = 0o120777 << 16
        wheel.writestr(info, '../escape')
    elif mode == 'duplicate':
        wheel.writestr('name', b'one')
        wheel.writestr('name', b'two')
    else:
        wheel.writestr('name/child', b'one')
        wheel.writestr('name', b'two')
data = json.load(open('inventory.json'))
data['wheels'] = [{'filename': 'bad.whl', 'sha256': hashlib.sha256(open('wheels/bad.whl', 'rb').read()).hexdigest(), 'elfs': []}]
with open('bad-inventory.json', 'w') as output:
    json.dump(data, output)
PY
    expect "unsafe-$mutation-capture" 5 'INCONCLUSIVE' inventory capture --lock uv.lock --wheel-dir wheels --installed-root installed --output bad.json
    expect "unsafe-$mutation-extract" 5 'INCONCLUSIVE' inventory materialize --lock uv.lock --wheel-dir wheels --inventory bad-inventory.json --destination unsafe-materialized
    [ ! -e unsafe-materialized ]
done
rm wheels/bad.whl
expect occupied-destination 5 'INCONCLUSIVE' inventory materialize --lock uv.lock --wheel-dir wheels --inventory inventory.json --destination materialized
expect preserved-destination 0 'D10 POLICY: 12' wheel_measure
mv wheels/native-1-py3-none-linux_x86_64.whl original.whl
expect missing-wheel 5 'wheel unavailable' inventory materialize --lock uv.lock --wheel-dir wheels --inventory inventory.json --destination missing-wheel
mv original.whl wheels/native-1-py3-none-linux_x86_64.whl
# A second wheel repeats the archive's demands and uses wheel data relocation.
mkdir -p installed/pkg
cp consumer11.so installed/pkg/duplicate.so
"$python" - <<'PY'
import zipfile
with zipfile.ZipFile('wheels/duplicate.whl', 'w') as wheel:
    wheel.write('installed/pkg/duplicate.so', 'duplicate.data/platlib/pkg/duplicate.so')
PY
expect relocated-capture 0 'captured' inventory capture --lock uv.lock --wheel-dir wheels --installed-root installed --output union.json
expect relocated-materialize 0 'materialized' inventory materialize --lock uv.lock --wheel-dir wheels --inventory union.json --destination union
expect duplicate-demands 0 'required nodes      4' measure --wheel-root "$scratch/union" --wheel-lock uv.lock --wheel-python "$python"
"$python" - <<'PY'
import json
data = json.load(open('union.json'))
data['wheels'].reverse()
with open('reversed.json', 'w') as output:
    json.dump(data, output)
PY
expect permuted-materialize 0 'materialized' inventory materialize --lock uv.lock --wheel-dir wheels --inventory reversed.json --destination reversed
expect permuted-demands 0 'D10 POLICY: 12' measure --wheel-root "$scratch/reversed" --wheel-lock uv.lock --wheel-python "$python"
expect multiple-roots 0 'walks archive=1 wheels=2' wheel_measure --wheel-root "$scratch/reversed"
cp materialized/inventory.json manifest.json
printf '{invalid' > materialized/inventory.json
expect malformed-inventory 5 'INCONCLUSIVE' wheel_measure
mv manifest.json materialized/inventory.json
ln -s native.so materialized/subjects/native-1-py3-none-linux_x86_64.whl/alias.so
expect subject-symlink 5 'INCONCLUSIVE' wheel_measure
rm materialized/subjects/native-1-py3-none-linux_x86_64.whl/alias.so
# GCC-only demands belong to the extended union independently of libstdc++.
printf 'extern int unwind(void); int use(void) { return unwind(); }\n' > unwind.c
printf 'GCC_4.0 { global: unwind; };\n' > unwind.map
gcc -nostdlib -shared -fPIC gcc.c -Wl,-soname,libgcc_s.so.1 -Wl,--version-script=unwind.map -o unwind-provider.so
gcc -nostdlib -shared -fPIC unwind.c -Wl,--no-as-needed -L. -l:unwind-provider.so -o archive/unwind-only.so
expect gcc-only-demand 1 'no candidate generation defines libgcc_s.so.1|GCC_4.0' wheel_measure
rm archive/unwind-only.so
# Remove the only capability supplying the wheel's higher node.
cp gcc12/libstdc++.so.6 provider.so
cp gcc11/libstdc++.so.6 gcc12/libstdc++.so.6
expect neither 1 'D10 POLICY: NEITHER' wheel_measure
expect neither-second-reading 1 'NON-CONVERGENT' wheel_measure --previous 12
mv provider.so gcc12/libstdc++.so.6
mv gcc11/libstdc++.so.6 provider.so
expect unread-provider 5 'INCONCLUSIVE' wheel_measure
mv provider.so gcc11/libstdc++.so.6
rm archive/extension.so
expect empty-legacy 5 'INCONCLUSIVE' measure
expect wheel-only 0 'D10 POLICY: 12' wheel_measure
printf 'D10 fixtures: %s cases passed\n' "$cases"
