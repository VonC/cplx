#!/bin/bash

set -o pipefail

# Convenience front end over the canonical pkg.sh for the toolchain
# itself: packages the live tree ~/tools into ~/pkgs (pkg.sh adds
# ~/.env and ~/.env_ for the tools target). The counterpart of
# my-project's tools/pkg_pdfs.sh, producing the archive that ships
# the toolchain together with these relocation scripts.
# Extra arguments are passed through to pkg.sh, for example:
#   pkg_tools -- --exclude=tools/scratch
#
# IT ALSO APPLIES THE BUILD-ONLY TRIM, and does so by packaging from a staged
# tree rather than by handing tar a list of exclusions. The reason is a coupling
# that exclusions cannot satisfy: pkg.sh runs the closure gate with
# `--prefix "$HOME"`, over the live tree, while tar writes what its own
# `--exclude` rules leave. Trim only the tar and the gate judges a tree nobody
# ships; trim only the gate and the archive carries payload nothing judged. A
# staged tree is read by both, so the gate and the archive see one set.
#
# The stage is a HARDLINK mirror: unlinking a hardlink removes a name, not the
# live file. Directory symlinks at write boundaries are refused below. The build account
# therefore keeps every compiler and binutils component it builds with, which is
# why the trim is not expressed in the per-tool package lists under
# `src/setups/pkgs/`: the same list populates the sandbox the tool is BUILT in.
#
# THE LIVE TREE IS NEVER WRITTEN, and that claim is now literal. The gate stages
# its declaration, its envelope and its five payload module copies into the tree
# it is about to package, which is the mirror, so they reach the archive and
# leave `$HOME/tools` alone. Earlier drafts of this file put them back into the
# live tree to satisfy an assertion that read them there; the assertion now reads
# them from the archive, which is where the contract always meant them to be.
# The Python compiler probe root/a.out is also removed from this private stage;
# its parent directories are checked before unlinking so a copied directory
# symlink cannot redirect that cleanup into the live build tree.

PKG_TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ ! -f "${PKG_TOOLS_DIR}/pkg.sh" ]; then
    echo " FATAL 1 : [pkg_tools.sh] pkg.sh not found next to this script (${PKG_TOOLS_DIR})" >&2
    exit 1
fi

if [ -z "${HOME:-}" ] || [ ! -d "$HOME" ]; then
    echo " FATAL 1 : [pkg_tools.sh] HOME is unset or is not a directory, and the stage is derived from it" >&2
    exit 1
fi
pkg_tools_fatal() {
    echo " FATAL ${2:-1} : [pkg_tools.sh] ${1}" >&2
    exit "${2:-1}"
}

# THE SOURCE ROOT IS THIS SCRIPT'S AND A CALLER MAY NOT REPLACE IT. Caller
# arguments are appended after the flag and `pkg.sh` takes the last value, so
# `pkg tools -- --source-root $HOME` would point the gate back at the live tree:
# the gate would stage its declaration and its module copies over the account's
# own, and the archive would carry the build-only payload the mirror removes.
#
# Check only pkg.sh options, before creating any stage. An --add value and
# everything after -- belong to the caller, even if they spell --source-root.
# Inspect a copy so pkg.sh still receives the original argument sequence.
pkg_tools_skip_value=0
for pkg_tools_arg in ${1+"$@"}; do
    if [ "$pkg_tools_skip_value" -eq 1 ]; then
        pkg_tools_skip_value=0
        continue
    fi
    case "$pkg_tools_arg" in
        --) break ;;
        --add) pkg_tools_skip_value=1 ;;
        --source-root|--source-root=*)
            pkg_tools_fatal "the packaging source is owned by this script and cannot be replaced by a caller: remove $pkg_tools_arg." 3 ;;
    esac
done

# Resolve the source boundary before creating the packaging child's stage.
# A staged destination must not let a payload-local copy certify itself.
PKG_TOOLS_HOME=$(cd -- "$HOME" && pwd -P) \
    || pkg_tools_fatal "HOME could not be resolved." 3
case "$PKG_TOOLS_DIR/" in
    "$PKG_TOOLS_HOME/tools/"*)
        pkg_tools_fatal "the packaging source is inside the tools payload; run from the deployed cplx tree." 3 ;;
esac

# cp -a preserves directory symlinks. Unlinking a child through one would reach
# the live tree even though the other regular files are independent hardlinks.
for pkg_tools_write_root in "$HOME/tools" "$HOME/tools/bin" "$HOME/tools/closure" \
    "$HOME/tools/python" "$HOME/tools/python/root"; do
    [ ! -L "$pkg_tools_write_root" ] \
        || pkg_tools_fatal "refusing a symlink at a staging write boundary: $pkg_tools_write_root." 3
done

# Own a fresh directory for this invocation. Never delete a previous run's
# stage or an operator's data at a fixed pathname.
PKG_TOOLS_STAGE=$(mktemp -d "$PKG_TOOLS_HOME/.cplx-pkgstage.XXXXXXXX") \
    || pkg_tools_fatal "a private packaging stage could not be created." 3

# THE LOADER AND THE C LIBRARY ARE UNTRIMMABLE BY NAME, checked on every
# candidate before any rule is allowed to select it. A derivation that reached
# one of these would not fail loudly; it would produce an archive that cannot
# start a process, which is the one outcome no later gate can report usefully.
pkg_tools_is_protected() {
    case "${1##*/}" in
        ld-linux*|ld-2.*|ld.so*) return 0 ;;
        libc.so*|libc-*|libm.so*|libm-*) return 0 ;;
        libpthread*|libdl*|librt*) return 0 ;;
    esac
    return 1
}

# Rule (b) of the retained measurement, DERIVED AND NOT TRANSCRIBED: an ELF is
# build-only when it records a DT_NEEDED on libbfd or libopcodes. The provider
# need not still be present for this to read, because the need is recorded in
# the consumer's own dynamic section.
pkg_tools_links_binutils() {
    readelf -d "$1" 2>/dev/null \
        | grep -q 'Shared library: \[\(libbfd\|libopcodes\)'
}

# The four rules of docs/v0.27.0/measurements.build-only-payload.rhel.txt,
# applied to the stage. Order is deliberate: (b) reads dynamic sections and runs
# before (c) removes the libraries those sections name, so the scan never
# depends on what an earlier rule already deleted.
pkg_tools_trim_stage() {
    local root="$1" candidate name
    [ -d "$root/tools" ] || pkg_tools_fatal "the stage has no tools tree at $root/tools." 3

    # The literal residual owned by tools-archive-rebuild is a compiler probe,
    # not a runtime provider. Unlink exactly this staged name, including when
    # it aliases a protected provider; never recursively remove an unexpected
    # directory and never follow it. Other a.out names remain unadjudicated.
    rm -f -- "$root/tools/python/root/a.out" \
        || pkg_tools_fatal "the staged Python compiler probe could not be removed." 3

    # (a) the GCC internals trees
    find "$root/tools" -type d -path '*/root/usr/libexec/gcc' -prune \
        -exec rm -rf -- {} + 2>/dev/null

    # (b) every ELF under */root/usr/bin or */root/usr/lib64 linking binutils
    while IFS= read -r -d '' candidate; do
        pkg_tools_is_protected "$candidate" && continue
        if pkg_tools_links_binutils "$candidate"; then
            rm -f -- "$candidate"
        fi
    done < <(find "$root/tools" -type f \
        \( -path '*/root/usr/bin/*' -o -path '*/root/usr/lib64/*' \) -print0)

    # (c) the binutils libraries themselves
    while IFS= read -r -d '' candidate; do
        pkg_tools_is_protected "$candidate" || rm -f -- "$candidate"
    done < <(find "$root/tools" -type f -path '*/root/*' \
        \( -name 'libbfd*' -o -name 'libopcodes*' -o -name 'libctf*' \) -print0)

    # (d) the compiler drivers and the GCC helpers
    while IFS= read -r -d '' candidate; do
        pkg_tools_is_protected "$candidate" && continue
        name="${candidate##*/}"
        case "$name" in
            gcc|cc|c++|g++|cpp|cc1|cc1plus|lto1|lto-dump) rm -f -- "$candidate" ;;
            gcov|gcov-*) rm -f -- "$candidate" ;;
            libmpc.so*|libmpfr.so*|libdebuginfod-*) rm -f -- "$candidate" ;;
            gresource|readelf|elfedit) rm -f -- "$candidate" ;;
        esac
    done < <(find "$root/tools" -type f -path '*/root/*' -print0)
}

# The stage carries ONE thing, the subject tree. It does not carry `pkgs`, and it
# does not carry the home-level env files: `pkg.sh --source-root` reads the
# subject from here and everything else from the caller's own `$HOME`, so the
# candidate path, the `latest` pointer, the digest history and any `--add` input
# stay the caller's. A stage that mirrored them would be answering questions the
# source tree has no business answering.
pkg_tools_build_stage() {
    local root="$1" boundary
    cp -al -- "$HOME/tools" "$root/tools" \
        || pkg_tools_fatal "the hardlink mirror of $HOME/tools could not be made." 3
    for boundary in "$root/tools" "$root/tools/bin" "$root/tools/closure" \
        "$root/tools/python" "$root/tools/python/root"; do
        [ ! -L "$boundary" ] \
            || pkg_tools_fatal "refusing a copied symlink at a staging write boundary: $boundary." 3
    done
    pkg_tools_unlink_gate_targets "$root"
}

# THE ONE HAZARD A HARDLINK MIRROR CARRIES: a write THROUGH a staged name
# reaches the live file behind it, because the two are one inode. The gate
# stages its declaration and its payload module copies into the tree it is about
# to package, so those destinations are removed from the stage first. Removing a
# hardlink is the safe half of the same property: it drops a name and leaves the
# file, so the live tree keeps whatever it had.
pkg_tools_unlink_gate_targets() {
    local root="$1"
    rm -rf -- "$root/tools/closure"
    rm -f -- "$root"/tools/bin/closure_*.sh
}

# Q12 preserves all loader names but gives identical copies one identity.
# The unchanged installer's -ef exclusion then protects each alias. Only the
# owned stage is changed; unlinking its hardlink cannot modify the live bytes.
pkg_tools_canonicalize_loader() {
    local root="$1" selected canonical candidate resolved digest relative parent inventory
    local -a copies=()
    local -A seen=()
    selected=$(
        # shellcheck source=src/setups/env/bin/install_pkg.sh
        source "$PKG_TOOLS_DIR/install_pkg.sh"
        INSTALL_PREFIX="$root"
        find_dynamic_linker
    ) || pkg_tools_fatal "the installer-selected loader could not be determined." 3
    [ -n "$selected" ] || return 0
    canonical=$(readlink -e -- "$selected") \
        || pkg_tools_fatal "the selected loader is missing or broken: $selected." 3
    case "$canonical" in "$root/tools/"*) ;; *) pkg_tools_fatal "the selected loader escapes the stage." 3 ;; esac
    digest=$(sha256sum -- "$canonical") || pkg_tools_fatal "the selected loader could not be hashed." 3
    digest="${digest%% *}"
    inventory="$root/loader-candidates"
    find "$root/tools" -name 'ld-linux-x86-64.so.2' -print0 > "$inventory" \
        || pkg_tools_fatal "the loader inventory is incomplete." 3
    # Preflight every lookup path before replacing a single regular file.
    while IFS= read -r -d '' candidate; do
        resolved=$(readlink -e -- "$candidate") \
            || pkg_tools_fatal "a loader path is missing or broken: $candidate." 3
        case "$resolved" in "$root/tools/"*) ;; *) pkg_tools_fatal "a loader path escapes the stage: $candidate." 3 ;; esac
        cmp -s -- "$canonical" "$resolved" \
            || pkg_tools_fatal "loader bytes differ: $candidate; no provider selection is permitted." 3
        if [ "$resolved" != "$canonical" ] && [ -z "${seen[$resolved]:-}" ]; then
            copies+=("$resolved")
            seen["$resolved"]=1
        fi
    done < "$inventory"
    for candidate in "${copies[@]}"; do
        relative="${canonical#"$root/"}"
        parent="${candidate%/*}"
        while [ "$parent" != "$root" ]; do
            relative="../$relative"
            parent="${parent%/*}"
        done
        if ! rm -f -- "$candidate" || ! ln -s -- "$relative" "$candidate"; then
            pkg_tools_fatal "the loader alias could not be preserved: $candidate." 3
        fi
        printf 'LOADER-ALIAS|%s|%s|%s\n' "${candidate#"$root/"}" "$relative" "$digest"
    done
}

pkg_tools_build_stage "$PKG_TOOLS_STAGE"
pkg_tools_trim_stage "$PKG_TOOLS_STAGE"
pkg_tools_canonicalize_loader "$PKG_TOOLS_STAGE"

# THE ONE IN-SCOPE CALLER, so this is where the gate is switched on. `pkg.sh`
# refuses the `tools` target without the flag, which makes this line the only
# way to package the toolchain from this repository and stops the gate being
# quietly omitted for the one run it exists for. A consuming project that
# packages `tools` through its own overlay starts refusing until it adopts the
# flag, which is the intended handoff rather than a silent break.
#
# `--source-root` MOVES THE SUBJECT AND NOTHING ELSE, which is why it replaced an
# earlier attempt that rebound HOME for this call. Rebinding HOME moved the
# subject and silently took four public behaviours with it: the archive path
# pkg.sh prints, the `tools.latest.tar.gz` pointer it maintains, the prior
# digests it compares a new candidate against, and the meaning of an `--add`
# path. The flag points the gate's `--prefix` and tar's first `-C` at the trimmed
# mirror while the caller's home keeps answering for everything else.
bash "${PKG_TOOLS_DIR}/pkg.sh" tools --closure-gate \
    --source-root "$PKG_TOOLS_STAGE" "$@"
PKG_TOOLS_RC=$?

# Failed tar output is diagnostic material in this invocation's private stage,
# never a candidate to promote into the account's package directory.
if [ "$PKG_TOOLS_RC" -ne 0 ]; then
    exit "$PKG_TOOLS_RC"
fi

# NOTHING IS PROMOTED, because nothing was diverted. pkg.sh wrote the candidate,
# its digest and its `latest` pointer straight into the caller's own `~/pkgs`, so
# there is no second copy to move and no window in which the printed path names a
# file that is not there yet.
#
# The mirror is this invocation's alone and costs only its directory entries, so
# a successful run takes it away. A failed run leaves it, because its partial tar
# output is the diagnostic material the early exit above preserved.
rm -rf -- "$PKG_TOOLS_STAGE"

exit "$PKG_TOOLS_RC"
