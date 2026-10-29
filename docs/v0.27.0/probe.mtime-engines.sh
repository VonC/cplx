#!/bin/bash
# Does a fractional source mtime survive each copy engine, in the exact forms
# the v0.27.0 design specifies?
#
# Round 4 plan review rejected the claim that "rsync -a transfers whole seconds
# only" as unmeasured and as conflating two distinct behaviours:
#
#   * rsync 3.1.0 added synchronization of nanosecond modification times, so a
#     transfer can preserve a fractional mtime;
#   * the default quick check (--modify-window=0) compares integer seconds when
#     deciding whether an EXISTING destination file needs transferring at all.
#
# Fresh copy and populated-destination skip are therefore separate cases. This
# probe measures both, on the supported target, with a source whose mtime has a
# known non-zero fractional component.
#
# Read-only apart from one scratch directory it creates and removes. It never
# touches a deployment prefix.
#
# Usage:  bash probe.mtime-engines.sh [scratch-parent]
#
# Retain the output as measurements.mtime-engines.<target>.txt.

set -u

scratch_parent="${1:-$HOME}"
scratch="${scratch_parent%/}/.cplx-mtime.$$"
cleanup() { rm -rf -- "$scratch" 2>/dev/null; }
trap cleanup EXIT
mkdir -p -- "$scratch" || { echo "cannot create scratch under $scratch_parent"; exit 2; }

m() { stat -c '%.9Y' -- "$1" 2>&1; }
frac() { local v; v=$(m "$1"); echo "${v##*.}"; }

echo "=== probe.mtime-engines, v0.27.0 rsync-cp-fallback ==="
echo "date      : $(date -u '+%Y-%m-%dT%H:%M:%SZ') (UTC)"
echo "uname     : $(uname -srm)"
echo "os-release: $( . /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-unknown}" )"
echo "coreutils : $(stat --version 2>/dev/null | head -1)"
echo "rsync     : $(rsync --version 2>/dev/null | head -1)"
echo "filesystem: $(df -PT -- "$scratch" 2>/dev/null | tail -1)"
echo

# A source tree whose file carries a known non-zero fractional mtime.
mkdir -p "$scratch/src"
printf 'payload\n' > "$scratch/src/f"
touch -d '2026-01-02 03:04:05.123456789' -- "$scratch/src/f" 2>/dev/null || {
    echo "touch cannot set a fractional mtime here; probe cannot run"; exit 2; }
src_m=$(m "$scratch/src/f")
echo "source mtime           : $src_m"
case "${src_m##*.}" in
    000000000) echo "source fraction is zero; the filesystem dropped it, probe is void"; exit 2 ;;
esac
echo

echo "=== case 1  fresh mirror, both engines ==="
mkdir -p "$scratch/dst_rsync"
rsync -av --delete "$scratch/src/" "$scratch/dst_rsync/" >/dev/null 2>&1
echo "rsync fresh mirror     : $(m "$scratch/dst_rsync/f")"

mkdir -p "$scratch/dst_cp"
rm -rf -- "${scratch:?}/dst_cp"/* 2>/dev/null
cp -a "$scratch/src/." "$scratch/dst_cp/"
echo "cp -a src/. fresh      : $(m "$scratch/dst_cp/f")"
echo

echo "=== case 2  fresh root-file deploy, both engines ==="
mkdir -p "$scratch/pfx_rsync" "$scratch/pfx_cp"
rsync -av "$scratch/src/f" "$scratch/pfx_rsync/" >/dev/null 2>&1
echo "rsync root-file        : $(m "$scratch/pfx_rsync/f")"
cp -a --remove-destination "$scratch/src/f" "$scratch/pfx_cp/f"
echo "cp -a --remove-dest    : $(m "$scratch/pfx_cp/f")"
echo

echo "=== case 3  populated destination, same size and integer second,"
echo "===         different fraction: does the rsync quick check skip it? ==="
mkdir -p "$scratch/dst_pop"
printf 'payload\n' > "$scratch/dst_pop/f"          # same size, same bytes
touch -d '2026-01-02 03:04:05.987654321' -- "$scratch/dst_pop/f"
echo "destination before     : $(m "$scratch/dst_pop/f")"
rsync -av --delete "$scratch/src/" "$scratch/dst_pop/" >/dev/null 2>&1
after=$(m "$scratch/dst_pop/f")
echo "destination after rsync: $after"
if [ "$after" = "$src_m" ]; then
    echo "verdict                : rsync updated it to the source mtime (no skip)"
elif [ "${after%%.*}" = "${src_m%%.*}" ] && [ "$(frac "$scratch/dst_pop/f")" != "${src_m##*.}" ]; then
    echo "verdict                : SKIPPED, destination kept its own fraction"
    echo "                         (integer seconds equal, fractions differ)"
else
    echo "verdict                : changed to something else, inspect above"
fi

mkdir -p "$scratch/dst_pop_cp"
printf 'payload\n' > "$scratch/dst_pop_cp/f"
touch -d '2026-01-02 03:04:05.987654321' -- "$scratch/dst_pop_cp/f"
rm -rf -- "${scratch:?}/dst_pop_cp"/* 2>/dev/null
cp -a "$scratch/src/." "$scratch/dst_pop_cp/"
echo "fallback same case     : $(m "$scratch/dst_pop_cp/f")"
echo "                         (the fallback empties first, so no skip is possible)"
echo

echo "=== case 4  archive evidence: fractional mtimes in an extracted staging tree ==="
echo "Run separately against a real extracted staging tree; this is the archive"
echo "side of the question and is not a substitute for the engine cases above:"
echo "  find <staging> -printf '%p\\0' | while IFS= read -r -d '' p; do \\"
echo "    case \"\$(stat -c '%.9Y' -- \"\$p\")\" in *.000000000) ;; *) echo \"\$p\";; esac; done"
echo "Any path printed is an entry whose mtime carries a non-zero fraction."
echo

echo "=== READING ==="
echo "If cases 1 and 2 show both engines reproducing the source fraction, the"
echo "manifest keeps full precision and the whole-second claim is simply wrong."
echo "If case 3 shows a skip, that is a quick-check behaviour on a populated"
echo "destination, not transfer truncation, and it belongs to the redeployment"
echo "scope rather than to the fresh equivalence comparison."
