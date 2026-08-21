#!/bin/bash

# Canonical cplx copy of the relocating installer: unpacks the latest
# <target>.*.tar.gz produced by pkg.sh into an installation prefix, then
# makes the tree self-contained there — symlink targets, text files, ELF
# interpreter (PT_INTERP) and rpath are re-anchored from the build
# account's /home/<user> to the prefix. Run it from any account.
# It needs the archive, this script, the patchelf shipped in the tools
# archive, and a short list of host programs. That list is recorded, with
# the method that produced it, under "Host tools install_pkg.sh needs" in
# wiki/reference/relocation-tools.md. rsync is optional there: without it
# the script falls back to cp at both transfer sites.
# Application-specific install steps (extra bin entries) belong to the
# consuming project's own deployment script (my-project does them in
# tools/deploy_pkgs.sh: see my-project docs/pkg-tools-migration-to-cplx.md).

# echos sits next to this script (standalone copy next to the archives) or
# one level up (~/cplx/bin + ~/cplx/echos, ~/tools/bin + ~/tools/echos).
INSTALL_PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for install_pkg_echos in "${INSTALL_PKG_DIR}/echos" "${INSTALL_PKG_DIR}/../echos/echos"; do
    if [ -f "${install_pkg_echos}" ]; then
        # shellcheck disable=SC1090
        source "${install_pkg_echos}"
        break
    fi
done
if ! command -v task >/dev/null 2>&1; then
    task()    { echo " Task=>: [install_pkg.sh] $1"; }
    info()    { echo " Info  : [install_pkg.sh] $1"; }
    ok()      { echo " Ok    : [install_pkg.sh] $1"; }
    warning() { echo " Warn  : [install_pkg.sh] $1"; }
    error()   { echo " Error : [install_pkg.sh] $1" >&2; }
    fatal()   { echo " FATAL ${2} : [install_pkg.sh] $1" >&2; exit "${2}"; }
fi

# ================= CONFIGURATION =================
# Installation prefix: the directory holding 'tools', 'bin' and 'pkgs'.
# Defaults to $HOME (historical same-account layout). Pass -p/--prefix for a
# relocated install, e.g. --prefix /project/middleware1/refer/deploy-group
INSTALL_PREFIX="$HOME"
# Resolved after argument parsing: $INSTALL_PREFIX/pkgs
PKG_DIR=""
# sed-escaped copies of INSTALL_PREFIX, safe in replacement and pattern position
PREFIX_SED=""
PREFIX_SED_PAT=""
# The copy engine, 'rsync' or 'cp', and the resolved rsync path when selected.
# Decided once by select_copy_engine and reused by every transfer site.
COPY_ENGINE=""
COPY_ENGINE_RSYNC=""
# Validation override, a test surface rather than an operating mode: only the
# exact value 1 forces the fallback, anything else behaves as unset.
CPLX_INSTALL_PKG_FORCE_CP="${CPLX_INSTALL_PKG_FORCE_CP:-}"
# =================================================

# The home anchor of every rewrite pattern, composed at runtime: a
# literal '/home/' followed by more path in this script's own lines
# would itself be rewritten by fix_text_paths when this file sits
# inside a deployed tree, corrupting the deployed copy (its sed rules
# and find patterns would then only match the installation prefix).
HOME_ANCHOR="/ho""me/"

sed_escape_replacement() {
    printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

sed_escape_pattern() {
    printf '%s' "$1" | sed -e 's/[][\\.*^$|]/\\&/g'
}

install_bin_link() {
    local link_name="$1"
    local source_path="$2"
    local bin_dir="$INSTALL_PREFIX/bin"
    local link_path="$bin_dir/$link_name"

    if [ ! -e "$source_path" ]; then
        return 1
    fi

    if ! mkdir -p "$bin_dir"; then
        fatal "Error: Failed to create '$bin_dir'." 13
    fi

    task "Installing '$link_path' -> '$source_path'"
    if ! ln -sfn "$source_path" "$link_path"; then
        fatal "Error: Failed to create '$link_path'." 14
    fi
    return 0
}

install_bin_wrapper() {
    local wrapper_name="$1"
    local target_path="$2"
    local bin_dir="$INSTALL_PREFIX/bin"
    local wrapper_path="$bin_dir/$wrapper_name"

    if [ ! -f "$target_path" ]; then
        return 1
    fi

    if ! mkdir -p "$bin_dir"; then
        fatal "Error: Failed to create '$bin_dir'." 13
    fi

    task "Installing '$wrapper_path' wrapper for '$target_path'"
    if ! {
        printf '%s\n' '#!/bin/bash'
        printf 'exec bash %q "$@"\n' "$target_path"
    } > "$wrapper_path"; then
        fatal "Error: Failed to write '$wrapper_path'." 15
    fi
    if ! chmod +x "$wrapper_path"; then
        fatal "Error: Failed to make '$wrapper_path' executable." 16
    fi
    return 0
}

install_optional_bin_entries() {
    local installed=0

    install_bin_link "echos" "$INSTALL_PREFIX/tools/echos/echos" && installed=1
    install_bin_link "compare_file.sh" "$INSTALL_PREFIX/tools/bin/compare_file.sh" && installed=1
    # A symlink, not a wrapper: the dispatcher routes 'pkg <target>' to
    # a pkg_<target> overlay found in its calling directory, so $0 must
    # stay in <prefix>/bin where the overlays are linked.
    install_bin_link "pkg" "$INSTALL_PREFIX/tools/bin/pkg" && installed=1
    install_bin_wrapper "pkg_tools" "$INSTALL_PREFIX/tools/bin/pkg_tools.sh" && installed=1
    install_bin_wrapper "install_pkg" "$INSTALL_PREFIX/tools/bin/install_pkg.sh" && installed=1

    if [ "$installed" -eq 1 ]; then
        ok "Convenience commands installed in '$INSTALL_PREFIX/bin'."
    else
        warning "No known convenience commands were available to install in '$INSTALL_PREFIX/bin'."
    fi
}

fix_home_symlink_targets() {
    local root_path="$1"
    local fixed=0
    local link_path
    local old_target
    local new_target

    if [ ! -d "$root_path" ]; then
        return 0
    fi

    # The /. suffix on the find root descends through a symlinked root
    # directory; symlinks inside the tree are still visited as links,
    # never followed (find default -P behavior).
    while IFS= read -r -d '' link_path; do
        old_target="$(readlink "$link_path")"
        # Already re-anchored (matters when the prefix itself is under /home)
        case "$old_target" in
            "$INSTALL_PREFIX"/*) continue ;;
        esac
        # The build tree lives under /home/<builder>/cplx/tools; the deployed
        # tree is <prefix>/tools. Map the build layout first, then any other
        # /home/<user> anchor to the installation prefix.
        new_target="$(printf '%s\n' "$old_target" | sed \
            -e "s|^${HOME_ANCHOR}[^/]*/cplx/tools/|${PREFIX_SED}/tools/|" \
            -e "s|^${HOME_ANCHOR}[^/]*/|${PREFIX_SED}/|")"

        if [ "$new_target" = "$old_target" ]; then
            continue
        fi

        task "Fixing symlink '$link_path' -> '$new_target'"
        if ! ln -sfn "$new_target" "$link_path"; then
            fatal "Error: Failed to rewrite symlink '$link_path'." 17
        fi
        fixed=$((fixed + 1))
    done < <(find "$root_path/." -type l -lname "${HOME_ANCHOR}*" -print0 2>/dev/null)

    if [ "$fixed" -gt 0 ]; then
        ok "Fixed $fixed absolute home symlink target(s) under '$root_path'."
    fi
}

fix_text_paths() {
    local root_path="$1"

    if [ ! -e "$root_path" ]; then
        return 0
    fi

    task "Fixing hard-coded /home/<user> paths in text files under '$root_path'..."
    # -I skips binary files (ELF, .pyc, git objects); -r does not follow
    # symlinks, so sed -i never replaces a link with a regular file.
    # Every rule writes the \x01 placeholder instead of the literal prefix,
    # restored by the last rule only. This keeps the rules from re-matching
    # each other's output and keeps the pass idempotent even when the
    # prefix itself lives under /home.
    if ! grep -rlIZ --exclude-dir=__pycache__ -- "${HOME_ANCHOR}[^/]*/" "$root_path" 2>/dev/null \
        | xargs -0 -r sed -i \
            -e "s|${PREFIX_SED_PAT}/|\x01|g" \
            -e "s|${HOME_ANCHOR}[^/]*/cplx/tools/|\x01tools/|g" \
            -e "s|${HOME_ANCHOR}[^/]*/|\x01|g" \
            -e "s|\x01|${PREFIX_SED}/|g"; then
        fatal "Error: Text path fix failed under '$root_path'" 12
    fi
    ok "Text paths fixed under '$root_path'."
}

clear_pycache() {
    local root_path="$1"

    if [ ! -d "$root_path" ]; then
        return 0
    fi

    task "Clearing __pycache__ directories under '$root_path'..."
    # Bytecode caches embed the build account's absolute paths; Python
    # regenerates them from the .py sources on first import, so removing
    # them is safe and only costs one slower first start.
    if ! find "$root_path/." -type d -name '__pycache__' -prune -exec rm -rf {} + 2>/dev/null; then
        warning "Some __pycache__ directories could not be removed under '$root_path'."
    fi
    ok "__pycache__ cleared (bytecode is regenerated on first import)."
}

# The mirror's delete semantics without rsync, for the only case this script
# uses: a whole tree onto a whole tree. Emptying the destination content then
# copying the source content is equivalent for that case; no partial-tree,
# filter or exclusion behaviour is in scope, because no call site uses one.
mirror_tree_cp() {
    local src="$1" dst="$2"

    # The boundary, applied before anything is removed, because this delete is
    # recursive and unbounded if pointed at the wrong place. -L is tested first
    # and no test here follows a link: a symlink of any kind is refused,
    # including a symlink to a directory, the shape measured to make the rsync
    # path empty an EXTERNAL target and still return 0. The new engine is the
    # stricter one.
    if [ -L "$dst" ]; then
        fatal "Error: mirror step (engine cp): destination '$dst' is a symlink; refusing to empty it." 5
    fi
    if [ -e "$dst" ] && [ ! -d "$dst" ]; then
        fatal "Error: mirror step (engine cp): destination '$dst' is not a directory." 5
    fi

    task "Mirror engine cp: emptying and copying into '$dst'..."
    if [ -e "$dst" ]; then
        # The content, not the directory itself, so the directory object and any
        # mount-point boundary on it are retained. This says nothing about its
        # metadata: the copy form below deliberately gives the transfer root the
        # source's attributes, so no ACL on the destination is preserved, and
        # ACLs are outside the parity manifest either way.
        if ! find "$dst" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +; then
            fatal "Error: mirror step (engine cp): could not empty '$dst'." 5
        fi
    elif ! mkdir -p -- "$dst"; then
        fatal "Error: mirror step (engine cp): could not create '$dst'." 5
    fi

    # `src/.` is load-bearing: it gives the transfer root the source mode and
    # mtime, matching the other engine's treatment of its transfer root, and it
    # carries hidden entries without depending on the caller's globbing. Both
    # trees hold hidden entries, and skipping them would leave stale hidden
    # files behind on a redeployment.
    if ! cp -a "$src/." "$dst/"; then
        fatal "Error: mirror step (engine cp): copy into '$dst' failed." 5
    fi
    ok "Mirror complete (engine cp)."
}

# Deploys one archive root file without rsync. Deliberately separate from the
# mirror helper and sharing nothing with it but the engine verdict: this
# operation has no delete semantics, so the mirror's destructive boundary must
# not be reachable from here, nor this one's rules from there.
deploy_root_file_cp() {
    local src="$1" dst="$2" name="$3"

    # A safety rule, not a tidiness one. Measured on coreutils 8.32 and 9.1, this
    # engine has two hazards the rsync path does not: onto a symlink to a regular
    # file, `cp -a` FOLLOWS the link, overwrites the external target and returns
    # 0, so the install reports success while the operator's file is gone; onto a
    # FIFO it blocks, so an unattended install waits forever instead of failing.
    #
    # -L is tested first and nothing here follows a link, which is the
    # load-bearing detail: a following predicate would classify a symlink to a
    # regular file as an acceptable regular file and keep the exact overwrite
    # this rule removes. Two shapes are accepted, absent and real regular file;
    # everything else is refused BEFORE cp runs, which is what stops the block.
    if [ -L "$dst" ]; then
        fatal "Error: deploy step (engine cp): '$name' destination is a symlink; refusing to copy through it." 7
    fi
    if [ -e "$dst" ] && [ ! -f "$dst" ]; then
        fatal "Error: deploy step (engine cp): '$name' destination is not a regular file." 7
    fi

    task "Deploy engine cp: '$name' into '$INSTALL_PREFIX'..."
    # --remove-destination is static defence in depth, not a concurrency claim:
    # the preflight and the copy are separated in time and nothing here says
    # otherwise.
    if ! cp -a --remove-destination "$src" "$dst"; then
        fatal "Error: deploy step (engine cp): '$name' copy failed." 7
    fi
}

# --- ELF observation (v0.27.0 relocation-force-rpath, Design Area 1) ---
#
# One structural read per walked ELF, producing a normalized named tuple. The
# tuple is ONE FIXED GLOBAL associative array, named once and shared by the
# observer, the classifier and the controlled tests. Fixed and global rather
# than passed: Bash cannot pass an associative array by value, so a per-call
# container would mean passing its name and dereferencing through a nameref,
# which is a second interpreter capability beyond the one the plan gates.
#
# The clearing rule is a single operation in a single place, because "the other
# fields are not touched" is how a previous object's reading survives into the
# next loop iteration and is read as this object's evidence.
declare -A CPLX_ELF_OBS

# Every key the tuple carries. Named once so the clear and the fill cannot
# disagree about the field set.
CPLX_ELF_OBS_KEYS="structural_status elf_kind has_dynamic has_interp tag_state \
rpath_probe_status rpath_value interp_probe_status interp_value"

# elf_obs_clear: empty every field in one operation. `absent` is a value rather
# than an unset key, because an unset key expands to the empty string and would
# be indistinguishable from a probe that answered with nothing.
elf_obs_clear() {
    local k
    for k in $CPLX_ELF_OBS_KEYS; do
        CPLX_ELF_OBS["$k"]=""
    done
}

# elf_obs_inconclusive: the fully defined structural-failure tuple. Every other
# field is cleared, both probe statuses are blocked, and both probe values are
# absent. This is the ONLY fault that blocks both axes.
elf_obs_inconclusive() {
    elf_obs_clear
    CPLX_ELF_OBS[structural_status]="inconclusive"
    CPLX_ELF_OBS[rpath_probe_status]="blocked"
    CPLX_ELF_OBS[interp_probe_status]="blocked"
    CPLX_ELF_OBS[rpath_value]="absent"
    CPLX_ELF_OBS[interp_value]="absent"
    return 0
}

# elf_read_le: read WIDTH bytes at OFFSET from FILE as a little-endian unsigned
# integer. `od` is already in the audited host-tool contract; nothing else is.
#
# ELF64 offsets and sizes are UNSIGNED 64-bit; Bash arithmetic is SIGNED 64-bit.
# A field with its top bit set therefore decodes to a negative number, and a
# caller that validated an extent by adding two of them would accept an object
# whose segment starts past the end of the file: 0xFFFFFFFFFFFFFFF0 reads as -16,
# and -16 + 8 is less than any size. That is not a hypothetical rounding concern,
# it is a malformed object finishing with `structural_status: ok`.
#
# So this function fails on any value it cannot represent faithfully. Everything
# this domain reads, offsets, sizes and counts, is bounded by a real file size,
# so a field at or above 2^63 is malformed rather than merely large, and the
# caller's existing "read failed" path is exactly the right response.
elf_read_le() {
    local file="$1" offset="$2" width="$3" bytes i v=0
    bytes=$(od -An -tx1 -v -j "$offset" -N "$width" "$file" 2>/dev/null | tr -d '[:space:]')
    [ "${#bytes}" -eq $((width * 2)) ] || { printf ''; return 1; }
    for (( i = width - 1; i >= 0; i-- )); do
        v=$(( (v << 8) + 0x${bytes:i*2:2} ))
    done
    # v is the low 64 bits read as signed, so v < 0 holds exactly when the true
    # unsigned value is at or above 2^63. Values below that are decoded exactly.
    [ "$v" -lt 0 ] && { printf ''; return 1; }
    printf '%s' "$v"

}
# elf_observe FILE SIZE: fill CPLX_ELF_OBS for one object.
#
# The size comes from the caller rather than from a stat, because the audited
# host-tool contract carries neither `stat` nor `wc`. It is a CALLER OBLIGATION,
# not something the walk supplies today: the walk currently emits `-print0` and
# no size, so whichever step wires the observer in must extend it to emit the
# size beside the path.
#
# The obligation is exact: SIZE must be the size of the bytes this function will
# READ, which is the size after symlink resolution. `find -printf '%s'` without
# `-L` reports the LINK's own size, a dozen-odd bytes, and every symlinked
# library is then rejected here as too short to hold a header. The walk is safe
# from that today only because `-type f` never yields a symlink; that is
# load-bearing, so a walk that ever gains `-L` or `-type l` must resolve the
# size too.
#
# Identification and whole-header presence are validated UNCONDITIONALLY. The
# program-header checks apply only when e_phnum is nonzero, because a file with
# no program header table is a valid shape: there is no entry whose size must
# equal the ELF64 program header size, and requiring it would reject a
# well-formed relocatable object.
elf_observe() {
    local file="$1" size="$2"
    local magic ei_class ei_data ei_version e_type e_machine
    local e_phoff e_phentsize e_phnum
    local i off p_type p_offset p_filesz
    local dyn_off dyn_size d_tag entry seen_rpath=0 seen_runpath=0

    elf_obs_clear

    # --- identification, four parts ---
    magic=$(od -An -tx1 -v -N 4 "$file" 2>/dev/null | tr -d '[:space:]')
    [ "$magic" = "7f454c46" ] || { elf_obs_inconclusive; return 0; }
    # The whole 64-byte ELF64 header must be present: a file long enough for the
    # four magic bytes the walk filters on may still be shorter than the header
    # this function reads.
    [ "$size" -ge 64 ] || { elf_obs_inconclusive; return 0; }
    ei_class=$(elf_read_le "$file" 4 1)   || { elf_obs_inconclusive; return 0; }
    ei_data=$(elf_read_le "$file" 5 1)    || { elf_obs_inconclusive; return 0; }
    ei_version=$(elf_read_le "$file" 6 1) || { elf_obs_inconclusive; return 0; }
    [ "$ei_class" = "2" ]   || { elf_obs_inconclusive; return 0; }  # ELFCLASS64
    [ "$ei_data" = "1" ]    || { elf_obs_inconclusive; return 0; }  # ELFDATA2LSB
    [ "$ei_version" = "1" ] || { elf_obs_inconclusive; return 0; }  # EV_CURRENT

    e_machine=$(elf_read_le "$file" 18 2) || { elf_obs_inconclusive; return 0; }
    [ "$e_machine" = "62" ] || { elf_obs_inconclusive; return 0; }  # EM_X86_64

    e_type=$(elf_read_le "$file" 16 2) || { elf_obs_inconclusive; return 0; }
    e_phnum=$(elf_read_le "$file" 56 2) || { elf_obs_inconclusive; return 0; }
    # PN_XNUM: the extended count lives in the section header table, which is
    # outside this domain, so it is inconclusive rather than followed.
    [ "$e_phnum" != "65535" ] || { elf_obs_inconclusive; return 0; }

    case "$e_type" in
        2) CPLX_ELF_OBS[elf_kind]="exec" ;;
        3) CPLX_ELF_OBS[elf_kind]="dyn" ;;
        *) CPLX_ELF_OBS[elf_kind]="unsupported" ;;
    esac
    CPLX_ELF_OBS[has_dynamic]="no"
    CPLX_ELF_OBS[has_interp]="no"
    CPLX_ELF_OBS[tag_state]="none"

    if [ "$e_phnum" -gt 0 ]; then
        e_phentsize=$(elf_read_le "$file" 54 2) || { elf_obs_inconclusive; return 0; }
        e_phoff=$(elf_read_le "$file" 32 8)     || { elf_obs_inconclusive; return 0; }
        # ELF64 fixes Elf64_Phdr at 56 bytes.
        [ "$e_phentsize" = "56" ] || { elf_obs_inconclusive; return 0; }
        # Every extent is checked against the REMAINING file, never by adding an
        # offset to a size. Two values that each pass `elf_read_le` can still sum
        # past 2^63 and come back negative, and a negative total satisfies any
        # `-le "$size"`. Subtracting cannot overflow here, because the left side
        # is proved to lie within the file before it is used.
        [ "$e_phoff" -le "$size" ] || { elf_obs_inconclusive; return 0; }
        [ $(( e_phnum * e_phentsize )) -le $(( size - e_phoff )) ] \
            || { elf_obs_inconclusive; return 0; }

        for (( i = 0; i < e_phnum; i++ )); do
            off=$(( e_phoff + i * e_phentsize ))
            p_type=$(elf_read_le "$file" "$off" 4)             || { elf_obs_inconclusive; return 0; }
            p_offset=$(elf_read_le "$file" $(( off + 8 )) 8)   || { elf_obs_inconclusive; return 0; }
            p_filesz=$(elf_read_le "$file" $(( off + 32 )) 8)  || { elf_obs_inconclusive; return 0; }
            [ "$p_offset" -le "$size" ] || { elf_obs_inconclusive; return 0; }
            [ "$p_filesz" -le $(( size - p_offset )) ] || { elf_obs_inconclusive; return 0; }
            case "$p_type" in
                2) CPLX_ELF_OBS[has_dynamic]="yes"; dyn_off="$p_offset"; dyn_size="$p_filesz" ;;
                3) CPLX_ELF_OBS[has_interp]="yes" ;;
            esac
        done

        if [ "${CPLX_ELF_OBS[has_dynamic]}" = "yes" ]; then
            # Elf64_Dyn is d_tag plus d_un, two eight-byte members, so the entry
            # size is 16 by layout rather than by a stored field. A segment whose
            # extent is not a whole number of entries is rejected.
            [ $(( dyn_size % 16 )) -eq 0 ] || { elf_obs_inconclusive; return 0; }
            entry=0
            while :; do
                [ $(( entry * 16 )) -lt "$dyn_size" ] || { elf_obs_inconclusive; return 0; }
                d_tag=$(elf_read_le "$file" $(( dyn_off + entry * 16 )) 8) \
                    || { elf_obs_inconclusive; return 0; }
                case "$d_tag" in
                    0)  break ;;              # DT_NULL terminates the array
                    15) seen_rpath=$(( seen_rpath + 1 )) ;;   # DT_RPATH
                    29) seen_runpath=$(( seen_runpath + 1 )) ;;  # DT_RUNPATH
                esac
                entry=$(( entry + 1 ))
            done
            if [ $(( seen_rpath + seen_runpath )) -gt 1 ]; then
                CPLX_ELF_OBS[tag_state]="ambiguous"
            elif [ "$seen_rpath" -eq 1 ]; then
                CPLX_ELF_OBS[tag_state]="rpath"
            elif [ "$seen_runpath" -eq 1 ]; then
                CPLX_ELF_OBS[tag_state]="runpath"
            fi
        fi
    fi

    CPLX_ELF_OBS[structural_status]="ok"
    # Probe statuses are set by the probe step. Structure fixes only the two
    # `skipped` producers, and those are its ONLY producers: skipped always means
    # "this object has nothing to read", never "we did not look".
    CPLX_ELF_OBS[rpath_probe_status]=""
    CPLX_ELF_OBS[interp_probe_status]=""
    CPLX_ELF_OBS[rpath_value]="absent"
    CPLX_ELF_OBS[interp_value]="absent"
    return 0
}

# elf_probe FILE PATCHELF: run the two probes over an already-observed object.
# Separate from elf_observe because the structural read is eager and only the
# probes short-circuit, and only on evidence.
elf_probe() {
    local file="$1" patchelf_bin="$2" out
    if [ "${CPLX_ELF_OBS[structural_status]}" != "ok" ]; then
        CPLX_ELF_OBS[rpath_probe_status]="blocked"
        CPLX_ELF_OBS[interp_probe_status]="blocked"
        return 0
    fi
    if [ "${CPLX_ELF_OBS[has_dynamic]}" = "no" ]; then
        CPLX_ELF_OBS[rpath_probe_status]="skipped"
    elif out=$("$patchelf_bin" --print-rpath "$file" 2>/dev/null); then
        CPLX_ELF_OBS[rpath_probe_status]="ok"
        CPLX_ELF_OBS[rpath_value]="$out"
    else
        CPLX_ELF_OBS[rpath_probe_status]="failed"
    fi
    if [ "${CPLX_ELF_OBS[has_interp]}" = "no" ]; then
        CPLX_ELF_OBS[interp_probe_status]="skipped"
    elif out=$("$patchelf_bin" --print-interpreter "$file" 2>/dev/null); then
        CPLX_ELF_OBS[interp_probe_status]="ok"
        CPLX_ELF_OBS[interp_value]="$out"
    else
        CPLX_ELF_OBS[interp_probe_status]="failed"
    fi
    return 0
}

find_patchelf() {
    local candidate
    for candidate in "$INSTALL_PREFIX/tools/bin/patchelf" "$HOME/tools/bin/patchelf"; do
        if [ -x "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    if command -v patchelf >/dev/null 2>&1; then
        command -v patchelf
        return 0
    fi
    return 1
}

find_dynamic_linker() {
    local candidate
    for candidate in \
        "$INSTALL_PREFIX/tools/python/root/lib64/ld-linux-x86-64.so.2" \
        "$INSTALL_PREFIX/tools/python/root/usr/lib64/ld-linux-x86-64.so.2"; do
        if [ -e "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    find -L "$INSTALL_PREFIX/tools" -name 'ld-linux-x86-64.so.2' 2>/dev/null | head -n 1
}

build_elf_rpath() {
    local dirs=()
    local tool_dir
    local ver_dir
    local sub

    # python first so its root libraries win over other tool roots
    for tool_dir in "$INSTALL_PREFIX/tools/python" "$INSTALL_PREFIX"/tools/*/; do
        tool_dir="${tool_dir%/}"
        [ -d "$tool_dir" ] || continue
        for sub in root/usr/lib64 root/usr/lib root/lib64 root/lib; do
            [ -d "$tool_dir/$sub" ] && dirs+=("$tool_dir/$sub")
        done
        for ver_dir in "$tool_dir"/*/; do
            ver_dir="${ver_dir%/}"
            for sub in lib lib64; do
                [ -d "$ver_dir/$sub" ] && dirs+=("$ver_dir/$sub")
            done
        done
    done

    # dedupe while preserving order
    local joined=""
    local dir
    for dir in "${dirs[@]}"; do
        case ":${joined}:" in
            *":${dir}:"*) ;;
            *) joined="${joined:+$joined:}$dir" ;;
        esac
    done
    printf '%s\n' "$joined"
}

fix_elf_paths() {
    local root_path="$1"

    if [ ! -d "$root_path" ]; then
        return 0
    fi

    local patchelf_bin
    if ! patchelf_bin=$(find_patchelf); then
        warning "patchelf not found (expected in '$INSTALL_PREFIX/tools/bin'): ELF interpreter/rpath fix skipped."
        warning "Binaries still referencing /home/<builder> will only run where that directory is readable."
        return 0
    fi

    local new_interp
    new_interp=$(find_dynamic_linker)
    if [ -z "$new_interp" ]; then
        warning "No ld-linux-x86-64.so.2 found under '$INSTALL_PREFIX/tools': ELF interpreters left unchanged."
    fi

    local new_rpath
    new_rpath=$(build_elf_rpath)
    if [ -z "$new_rpath" ]; then
        warning "No library directories found under '$INSTALL_PREFIX/tools': ELF rpaths left unchanged."
    fi

    task "Fixing ELF interpreter and rpath under '$root_path' (patchelf: $patchelf_bin)..."
    info "New interpreter: ${new_interp:-<unchanged>}"
    info "New rpath      : ${new_rpath:-<unchanged>}"

    local fixed=0
    local file_path
    local magic
    local old_value
    while IFS= read -r -d '' file_path; do
        magic=$(head -c 4 "$file_path" 2>/dev/null | od -An -tx1 | tr -d ' \n')
        [ "$magic" = "7f454c46" ] || continue

        # Only rewrite values still anchored in a /home/<user> directory, so
        # the pass is idempotent and system-linked binaries are left alone.
        if [ -n "$new_rpath" ]; then
            old_value=$("$patchelf_bin" --print-rpath "$file_path" 2>/dev/null) || old_value=""
            if [[ "$old_value" == */home/* ]]; then
                if "$patchelf_bin" --set-rpath "$new_rpath" "$file_path"; then
                    fixed=$((fixed + 1))
                else
                    warning "Unable to set rpath on '$file_path'"
                fi
            fi
        fi

        if [ -n "$new_interp" ]; then
            old_value=$("$patchelf_bin" --print-interpreter "$file_path" 2>/dev/null) || old_value=""
            if [[ "$old_value" == */home/* ]] && [ "$old_value" != "$new_interp" ]; then
                if "$patchelf_bin" --set-interpreter "$new_interp" "$file_path"; then
                    fixed=$((fixed + 1))
                else
                    warning "Unable to set interpreter on '$file_path'"
                fi
            fi
        fi
    done < <(find "$root_path/." \( -name '.git' -o -name '__pycache__' \) -prune -o -type f -size +4c -print0 2>/dev/null)

    ok "Fixed $fixed ELF interpreter/rpath value(s) under '$root_path'."
}

# --- 0b. Definitions the main flow calls ---
# usage and select_copy_engine are defined here, above the main boundary,
# rather than beside their call sites below it. Their call sites are
# unchanged; only the definitions moved. A definition above its call site
# changes nothing about an executed run, and it is what lets the file be
# sourced with every production function defined: a guard placed after
# these definitions in their old positions would have sat after the flow
# it was meant to precede.

usage() {
    fatal "Usage: $0 <target-folder> [-f|--force] [-p|--prefix <dir>]" 1
}

# --- 1b. Select the copy engine ---
# Here, before archive discovery, and announced as a SELECTION rather than an
# action: a run that dies during discovery or extraction has still said which
# engine it would have copied with. Absence of rsync selects the fallback; a
# present rsync that FAILS does not, since that is a real error about the tree,
# the permissions or the disk. The resolved path is printed because command -v
# finds a stand-in shim as readily as a real rsync, and a shim that ignores
# --delete would otherwise degrade the mirror invisibly.
select_copy_engine() {
    COPY_ENGINE_RSYNC="$(command -v rsync 2>/dev/null)"
    if [ "$CPLX_INSTALL_PKG_FORCE_CP" = "1" ]; then
        COPY_ENGINE="cp"
        info "Copy engine: cp (forced by CPLX_INSTALL_PKG_FORCE_CP=1)"
    elif [ -n "$COPY_ENGINE_RSYNC" ]; then
        COPY_ENGINE="rsync"
        info "Copy engine: rsync ($COPY_ENGINE_RSYNC)"
    else
        COPY_ENGINE="cp"
        info "Copy engine: cp (rsync not found on PATH)"
    fi
}

# --- MAIN BOUNDARY ---
# Everything above is definitions; everything below runs an install.
#
# Sourcing this file defines its functions and performs no install, so the
# verification harness can call the production functions themselves rather
# than a copy. Executing it is unchanged: BASH_SOURCE[0] equals $0 there,
# so the guard is a no-op on the deployed path.
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    return 0
fi

# --- 1. Argument Parsing ---
FORCE=0
TARGET=""

# Parse args
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--force) FORCE=1 ;;
        -p|--prefix)
            if [ -z "$2" ]; then
                error "Error: --prefix requires a directory argument."
                usage
            fi
            INSTALL_PREFIX="$2"
            shift
            ;;
        -*) error "Unknown parameter: $1"; usage ;;
        *)
            if [ -n "$TARGET" ]; then
                error "Error: only one target folder can be given ('$TARGET' and '$1')."
                usage
            fi
            TARGET="$1"
            ;;
    esac
    shift
done

if [ -z "$TARGET" ]; then
    error "Error: Target folder is required (e.g. tools)."
    usage
fi

INSTALL_PREFIX="${INSTALL_PREFIX%/}"
if [ ! -d "$INSTALL_PREFIX" ] && ! mkdir -p "$INSTALL_PREFIX"; then
    fatal "Error: Installation prefix '$INSTALL_PREFIX' does not exist and cannot be created." 18
fi
PREFIX_SED=$(sed_escape_replacement "$INSTALL_PREFIX")
PREFIX_SED_PAT=$(sed_escape_pattern "$INSTALL_PREFIX")
PKG_DIR="$INSTALL_PREFIX/pkgs"
if ! mkdir -p "$PKG_DIR"; then
    fatal "Error: Failed to create '$PKG_DIR'." 19
fi
info "Installation prefix: $INSTALL_PREFIX"

# --- 1b. Select the copy engine ---
# Defined above the main boundary; called here, where it always was, before
# archive discovery.
select_copy_engine

# --- 2. Find the Most Recent Archive ---
# We look in the prefix, $HOME and both pkgs directories for files like
# target.*.tar.gz, and keep the newest by modification time.
task "Searching for latest $TARGET archive..."

LATEST_ARCHIVE=$(find "$INSTALL_PREFIX" "$PKG_DIR" "$HOME" "$HOME/pkgs" -maxdepth 1 -type f -name "${TARGET}.*.tar.gz" -printf '%T@ %p\n' 2>/dev/null | sort -unr | head -n 1 | cut -d' ' -f2-)

if [ -z "$LATEST_ARCHIVE" ]; then
    fatal "Error: No archive found for '$TARGET' in $INSTALL_PREFIX, $HOME or $PKG_DIR" 2
fi

info "Found: $LATEST_ARCHIVE"

# Extract the basename without extension (e.g., tools.2026-01-05_120000)
FILENAME=$(basename "$LATEST_ARCHIVE")
BASE_NAME="${FILENAME%%.tar.gz}"

# Define the "Done" flag file path
DONE_FLAG="$PKG_DIR/${BASE_NAME}.done"

# --- 3. Check if Already Installed ---
if [ -f "$DONE_FLAG" ] && [ "$FORCE" -eq 0 ]; then
    warning "Skipping: $BASE_NAME is already installed."
    info "Use -f or --force to reinstall."
    install_optional_bin_entries
    exit 0
fi

if [ "$FORCE" -eq 1 ] && [ -f "$DONE_FLAG" ]; then
    warning "Force mode enabled. Reinstalling..."
fi

# --- 4. Unzip to Staging Area ---
STAGING_DIR="$PKG_DIR/$BASE_NAME"

# Clean up any previous partial staging attempt
if [ -d "$STAGING_DIR" ]; then
    task "Cleaning old staging area..."
    if ! rm -rf "$STAGING_DIR"; then
        fatal "Error: Failed to clean old staging area." 10
    fi
fi

if ! mkdir -p "$STAGING_DIR"; then
    fatal "Error: Failed to create staging directory." 9
fi

task "Extracting to $STAGING_DIR..."
# -C extracts INTO the staging dir
if ! tar -xzf "$LATEST_ARCHIVE" -C "$STAGING_DIR"; then
    fatal "Error: Extraction failed." 3
fi

# --- 5. Mirror the tree ---
# The source is inside the staging dir (e.g., <prefix>/pkgs/tools.xxx/tools/)
SOURCE_PATH="$STAGING_DIR/$TARGET"
DEST_PATH="$INSTALL_PREFIX/$TARGET"

if [ ! -d "$SOURCE_PATH" ]; then
    fatal "Error: Expected folder '$TARGET' not found inside archive." 4
fi

task "Syncing to $DEST_PATH (Mirror Mode)..."
if [ "$COPY_ENGINE" = "rsync" ]; then
    # -a: Archive mode (perms, times, etc.)
    # -v: Verbose
    # --delete: Delete files in DEST that are not in SOURCE
    if ! rsync -av --delete "$SOURCE_PATH/" "$DEST_PATH/"; then
        fatal "Error: mirror step (engine rsync) failed." 5
    fi
else
    mirror_tree_cp "$SOURCE_PATH" "$DEST_PATH"
fi
fix_home_symlink_targets "$DEST_PATH"

# --- 6. Deploy the archive's root-level files ---
# pkg.sh ships extra top-level items next to the target folder in the
# archive (.env and .env_ for a tools target, anything passed through
# its --add option, like my-project's senv). Every regular file found
# at the staging root is deployed to the prefix and re-anchored.
shopt -s dotglob nullglob
for root_file in "$STAGING_DIR"/*; do
    [ -f "$root_file" ] || continue
    root_file_name="$(basename "$root_file")"
    task "Deploying '$root_file_name' to $INSTALL_PREFIX..."
    if [ "$COPY_ENGINE" = "rsync" ]; then
        if ! rsync -av "$root_file" "$INSTALL_PREFIX/"; then
            fatal "Error: deploy step (engine rsync) failed for '$root_file_name'." 7
        fi
    else
        deploy_root_file_cp "$root_file" "$INSTALL_PREFIX/$root_file_name" "$root_file_name"
    fi
    fix_text_paths "$INSTALL_PREFIX/$root_file_name"
done
shopt -u dotglob nullglob

# --- 6b. Clear stale bytecode caches ---
# Old __pycache__ entries keep the build account's paths in their metadata
# and would show up in a /home/<builder> audit; Python rebuilds them.
clear_pycache "$DEST_PATH"

# --- 6c. Fix hardcoded paths in text files ---
# Replace /home/<any_user>/ anchors with the installation prefix in every
# text file of the deployed tree (pyvenv.cfg, pkgconfig *.pc, shebangs,
# activate scripts, run configs). Binary files are skipped by grep -I.
fix_text_paths "$DEST_PATH"

# --- 6d. Fix hardcoded paths in ELF binaries ---
# The cplx toolchain bakes the build account's dynamic linker (PT_INTERP)
# and library rpath into every binary; the kernel resolves PT_INTERP before
# any environment variable applies, so it must be rewritten on disk.
fix_elf_paths "$DEST_PATH"

# --- 6e. Install convenience commands in <prefix>/bin when their sources are present ---
install_optional_bin_entries

# --- 7. Finalize ---
ok "Installation successful."
touch "$DONE_FLAG"

# Optional: Clean up staging folder to save space (comment out if you want to keep it)
task "Cleaning up staging area '$STAGING_DIR'..."
if ! rm -rf "$STAGING_DIR"; then
    fatal "Error: Cleaning up staging area '$STAGING_DIR'" 11
fi
ok "Done."
