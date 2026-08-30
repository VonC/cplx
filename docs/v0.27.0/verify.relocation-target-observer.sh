#!/usr/bin/env bash
# Step 1 observer cross-check on the deployment target.
#
# The observer is the PRODUCTION function, reached by sourcing the installer
# through the Step 0 seam. It is checked against the target's OWN readelf, an
# oracle that shares none of the observer's beliefs about where a field lives.
# No patchelf is needed: elf_observe is the structural read, and the target
# ships no patchelf by design.
#
# An object the observer calls inconclusive is a FAILURE here, not an exclusion.
# The corpus is real system objects that readelf parses, so every one of them
# has a right answer, and a run that quietly drops the ones without a comparison
# would report agreement while knowing nothing about them.
set -u
INSTALLER="$1"

echo "===== BEGIN CPLX-RELOCATION-STEP1-TARGET ====="
echo "bash        $BASH_VERSION"
echo "od          $(od --version | head -1)"
echo "readelf     $(readelf --version | head -1)"
echo "patchelf    $(command -v patchelf || echo 'absent (shipped by the installer, not the host)')"
echo "installer   sha256 $(sha256sum "$INSTALLER" | cut -d' ' -f1)"
echo

# The seam: sourcing must define the observer and perform no install.
# shellcheck disable=SC1090
. "$INSTALLER" >/dev/null 2>&1
rc=$?
printf '%-34s %s\n' "seam/source-rc" "$rc"
for fn in elf_obs_clear elf_obs_inconclusive elf_read_le elf_observe elf_probe; do
    if declare -F "$fn" >/dev/null 2>&1; then printf '%-34s %s\n' "seam/defined-$fn" "yes"
    else printf '%-34s %s\n' "seam/defined-$fn" "NO"; fi
done
if declare -p CPLX_ELF_OBS 2>/dev/null | grep -q 'declare -A'; then
    printf '%-34s %s\n' "seam/assoc-array" "supported"
else
    printf '%-34s %s\n' "seam/assoc-array" "NOT SUPPORTED"
fi
echo

fails=0
agree=0
total=0

# The size contract, exercised rather than assumed: SIZE must be the size of the
# bytes the observer will read, which for a symlink is the TARGET's size.
resolved_size() { find -L "$1" -maxdepth 0 -printf '%s\n' 2>/dev/null; }

# readelf as the independent oracle for each observed field.
oracle() {
    local f="$1" h ph kind dyn interp tag rp rup
    h=$(readelf -h "$f" 2>/dev/null) || { echo "unparsable"; return; }
    case "$(printf '%s' "$h" | sed -n 's/.*Type: *\([A-Z]*\).*/\1/p' | head -1)" in
        EXEC) kind="exec" ;;
        DYN)  kind="dyn" ;;
        *)    kind="unsupported" ;;
    esac
    ph=$(readelf -l "$f" 2>/dev/null)
    if printf '%s' "$ph" | grep -q 'DYNAMIC'; then dyn=yes; else dyn=no; fi
    if printf '%s' "$ph" | grep -q 'INTERP'; then interp=yes; else interp=no; fi
    rp=$(readelf -d "$f" 2>/dev/null | grep -c '(RPATH)')
    rup=$(readelf -d "$f" 2>/dev/null | grep -c '(RUNPATH)')
    if [ $(( rp + rup )) -gt 1 ]; then tag=ambiguous
    elif [ "$rp" -eq 1 ]; then tag=rpath
    elif [ "$rup" -eq 1 ]; then tag=runpath
    else tag=none; fi
    echo "$kind|$dyn|$interp|$tag"
}

observe_one() {
    local f="$1" sz o obs link=""
    sz=$(resolved_size "$f")
    if [ -z "$sz" ]; then
        printf 'FAIL          %-32s no size\n' "$(basename "$f")"
        fails=$(( fails + 1 ))
        return 0
    fi
    if [ -L "$f" ]; then link=" (symlink, resolved size)"; fi
    elf_observe "$f" "$sz"
    total=$(( total + 1 ))
    o=$(oracle "$f")
    if [ "${CPLX_ELF_OBS[structural_status]}" != "ok" ]; then
        fails=$(( fails + 1 ))
        printf 'FAIL          %-32s inconclusive, but readelf reads it as %s\n' \
            "$(basename "$f")" "$o"
        return 0
    fi
    obs="${CPLX_ELF_OBS[elf_kind]}|${CPLX_ELF_OBS[has_dynamic]}|${CPLX_ELF_OBS[has_interp]}|${CPLX_ELF_OBS[tag_state]}"
    if [ "$o" = "$obs" ]; then
        agree=$(( agree + 1 ))
        printf 'agree         %-32s %s%s\n' "$(basename "$f")" "$obs" "$link"
    else
        fails=$(( fails + 1 ))
        printf 'DISAGREE      %-32s observer=%s readelf=%s\n' "$(basename "$f")" "$obs" "$o"
    fi
}

echo "--- production observer vs the target own readelf ---"
while IFS= read -r f; do
    [ -e "$f" ] || continue
    head -c 4 "$f" 2>/dev/null | od -An -tx1 -v | tr -d '[:space:]' | grep -q '^7f454c46$' || continue
    observe_one "$f"
done <<'CORPUS'
/bin/true
/bin/bash
/bin/od
/bin/find
/usr/bin/ssh
/usr/lib64/libz.so.1
/usr/lib64/libc.so.6
/usr/lib64/libtinfo.so.6
/usr/lib64/ld-linux-x86-64.so.2
/usr/lib64/libcrypto.so.3
CORPUS

echo
echo "--- the size contract: a link own size is not the size of what is read ---"
# Naming the hazard rather than only avoiding it: handed the unresolved size, the
# observer must reject, because it was told the object is too short for a header.
sym=""
for c in /usr/lib64/libz.so.1 /usr/lib64/libtinfo.so.6 /usr/lib64/libcrypto.so.3; do
    if [ -L "$c" ]; then sym="$c"; break; fi
done
if [ -n "$sym" ]; then
    ls_sz=$(find "$sym" -maxdepth 0 -printf '%s\n')
    rs_sz=$(resolved_size "$sym")
    printf '%-34s link=%s resolved=%s\n' "size/link-vs-resolved" "$ls_sz" "$rs_sz"
    elf_observe "$sym" "$ls_sz"
    printf '%-34s %s (correct: it was told %s bytes)\n' "size/unresolved-rejected" \
        "${CPLX_ELF_OBS[structural_status]}" "$ls_sz"
    if [ "${CPLX_ELF_OBS[structural_status]}" != "inconclusive" ]; then fails=$(( fails + 1 )); fi
    elf_observe "$sym" "$rs_sz"
    printf '%-34s %s\n' "size/resolved-accepted" "${CPLX_ELF_OBS[structural_status]}"
    if [ "${CPLX_ELF_OBS[structural_status]}" != "ok" ]; then fails=$(( fails + 1 )); fi
else
    echo "size/no-symlink-available          (hazard not exercised on this target)"
    fails=$(( fails + 1 ))
fi

echo
echo "--- the walk that will feed it never yields a symlink ---"
# Load-bearing today: -type f is why the unresolved size cannot reach the
# observer from production. Asserted here so it cannot be dropped silently.
if grep -q -- '-type f -size +4c -print0' "$INSTALLER"; then
    printf '%-34s %s\n' "walk/type-f-present" "yes"
else
    printf '%-34s %s\n' "walk/type-f-present" "NO"
    fails=$(( fails + 1 ))
fi
if grep -qE 'find -L "[$]root_path' "$INSTALLER"; then
    printf '%-34s %s\n' "walk/no-follow" "NO (walk follows symlinks)"
    fails=$(( fails + 1 ))
else
    printf '%-34s %s\n' "walk/no-follow" "yes"
fi

echo
echo "--- rejection: a non-ELF and a truncated ELF must both be inconclusive ---"
t=$(mktemp -d)
printf 'not an elf at all, but long enough to be read\n' > "$t/plain"
head -c 32 /bin/true > "$t/trunc"
for r in "$t/plain" "$t/trunc"; do
    elf_obs_clear
    elf_observe "$r" "$(resolved_size "$r")"
    printf 'reject %-10s structural=%-13s kind=[%s] rpath_probe=%s interp_probe=%s\n' \
        "$(basename "$r")" "${CPLX_ELF_OBS[structural_status]}" \
        "${CPLX_ELF_OBS[elf_kind]}" "${CPLX_ELF_OBS[rpath_probe_status]}" \
        "${CPLX_ELF_OBS[interp_probe_status]}"
    if [ "${CPLX_ELF_OBS[structural_status]}" != "inconclusive" ]; then fails=$(( fails + 1 )); fi
done

echo
echo "--- clearing rule: neither direction carries residue ---"
elf_observe "$t/plain" 45
elf_observe /bin/bash "$(resolved_size /bin/bash)"
printf '%-34s structural=%s kind=%s tag=%s\n' "clear/reject-then-good" \
    "${CPLX_ELF_OBS[structural_status]}" "${CPLX_ELF_OBS[elf_kind]}" "${CPLX_ELF_OBS[tag_state]}"
if [ "${CPLX_ELF_OBS[structural_status]}" != "ok" ]; then fails=$(( fails + 1 )); fi
elf_observe "$t/plain" 45
printf '%-34s structural=%s kind=[%s] tag=[%s]\n' "clear/good-then-reject" \
    "${CPLX_ELF_OBS[structural_status]}" "${CPLX_ELF_OBS[elf_kind]}" "${CPLX_ELF_OBS[tag_state]}"
if [ -n "${CPLX_ELF_OBS[elf_kind]}" ]; then fails=$(( fails + 1 )); fi
rm -rf "$t"

echo
echo "totals: observed $total, agree $agree, failures $fails"
if [ "$fails" -eq 0 ] && [ "$agree" -ge 8 ]; then
    echo "result: OBSERVER_AGREES_WITH_TARGET_READELF"
else
    echo "result: FAILURES"
fi
echo "===== END CPLX-RELOCATION-STEP1-TARGET ====="
