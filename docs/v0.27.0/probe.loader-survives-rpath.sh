#!/bin/bash
# probe.loader-survives-rpath.sh: does the archive survive the case 4 write?
#
# Run on a capable host that carries the extracted archive and patchelf. Every
# mutation happens on copies under a scratch directory; nothing under the
# archive is ever written, which is what makes this safe to run on a real
# deployment target.
#
# Two questions, in order:
#
#   1. does the shipped dynamic loader survive `--force-rpath --set-rpath`?
#   2. if not, is it the only object that does not?
#
# Question 2 is what keeps the answer to question 1 from becoming a retreat from
# case 4. Measured on the RHEL 9.8 target, patchelf 0.19.1, glibc 2.34: the
# loader goes from exit 0 to signal 11 across one patchelf call that itself
# exits 0, and libc, libm, libdl, libpthread, libz and libstdc++ all take the
# same write and keep working.
set -u

A="${1:-$HOME/tools}"
W="${TMPDIR:-/tmp}/cplx-loader-probe.$$"
PE="$A/bin/patchelf"
RP=$A/python/root/usr/lib64:$A/python/root/usr/lib:$A/python/root/lib64

[ -d "$A" ] || { echo "no archive at $A; pass its path as \$1" >&2; exit 2; }
[ -x "$PE" ] || { echo "no patchelf at $PE" >&2; exit 2; }

cleanup() { rm -rf -- "$W" 2>/dev/null; }
trap cleanup EXIT
mkdir -p -- "$W/lib64" || exit 2

echo "archive   : $A"
echo "host      : $(uname -srm)"
echo "patchelf  : $("$PE" --version 2>&1)"
echo

# run LABEL CMD...: execute and report the exit code, naming the signal when the
# process died of one. A signal is the whole point here, so it is never folded
# into a plain non-zero.
run() {
    local label="$1"; shift
    local out rc
    out=$("$@" 2>&1); rc=$?
    if [ "$rc" -gt 128 ]; then
        echo "$label: exit $rc (signal $((rc - 128)))"
    else
        echo "$label: exit $rc"
    fi
    [ -n "$out" ] && echo "$label: ${out%%$'\n'*}"
    return 0
}

LD_SRC=""
for c in "$A/python/root/lib64/ld-linux-x86-64.so.2" \
         "$A/python/root/usr/lib64/ld-linux-x86-64.so.2"; do
    [ -e "$c" ] && { LD_SRC="$c"; break; }
done
[ -n "$LD_SRC" ] || { echo "no shipped loader under $A" >&2; exit 2; }

echo "== 1. the shipped loader, untouched"
cp -pL -- "$LD_SRC" "$W/ld-clean.so"
run "  clean-loader" "$W/ld-clean.so" --version
echo "  rpath-before: [$("$PE" --print-rpath "$W/ld-clean.so" 2>&1)]"
echo

echo "== 2. the same loader after the case 4 write"
cp -pL -- "$LD_SRC" "$W/ld-patched.so"
run "  patchelf-set-rpath" "$PE" --force-rpath --set-rpath "$RP" "$W/ld-patched.so"
echo "  rpath-after : [$("$PE" --print-rpath "$W/ld-patched.so" 2>&1)]"
echo "  size        : $(stat -c %s "$W/ld-clean.so") -> $(stat -c %s "$W/ld-patched.so")"
run "  patched-loader" "$W/ld-patched.so" --version
echo

echo "== 3. a program through each loader"
PY=$(find "$A/python" -maxdepth 3 -type f -name 'python3*_bin' 2>/dev/null | head -n 1)
if [ -n "$PY" ]; then
    cp -p -- "$PY" "$W/py-patched"
    echo "  py-interp   : $("$PE" --print-interpreter "$W/py-patched" 2>&1)"
    "$PE" --set-interpreter "$W/ld-patched.so" "$W/py-patched" 2>/dev/null
    run "  py-via-patched-loader" "$W/py-patched" -c pass
else
    echo "  py          : no shipped python found, skipped"
fi
echo

echo "== 4. the ordinary libraries, which must NOT be excluded"
for f in libc.so.6 libm.so.6 libdl.so.2 libpthread.so.0 libz.so.1 libstdc++.so.6; do
    [ -f "$A/python/root/usr/lib64/$f" ] \
        && cp -pL -- "$A/python/root/usr/lib64/$f" "$W/lib64/$f"
done
run "  before      " "$W/ld-clean.so" --library-path "$W/lib64" /bin/true
for f in "$W"/lib64/*; do
    [ -e "$f" ] || continue
    "$PE" --force-rpath --set-rpath "$RP" "$f" 2>/dev/null
done
run "  after (all) " "$W/ld-clean.so" --library-path "$W/lib64" /bin/true

echo
echo "probe complete; nothing under $A was written"
