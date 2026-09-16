#!/bin/bash
# Explicit, resumable candidate capture. Fixtures are never candidate acceptance.
# Each role needs an already prepared, independently copied and audited home.

sqlite_driver_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=docs/v0.27.0/acceptance.python-sqlite-capture.sh
source "$sqlite_driver_dir/acceptance.python-sqlite-capture.sh"

# SC2094: an early refusal removes its temporary inventory, never rewrites it.
# shellcheck disable=SC2094
sqlite_audit() {
    local home=$1 audit=$2 expected=$3 settings=$4 digest relative line key value path
    local -A audited=()
    [[ $(sqlite_digest "$audit") == "$expected" ]] || { sqlite_fail 'audit digest changed'; return; }
    # Audit is data: SHA-256, two spaces, home-relative path; never source it.
    while IFS= read -r line; do
        digest=${line%% *}; relative=${line#*  }
        [[ $digest =~ ^[0-9a-f]{64}$ && $relative != /* && $relative != "$line" && -n $relative &&
           /$relative/ != *'/../'* && /$relative/ != *'/./'* && $relative != *\\* ]] || return 2
        path=$home/$relative
        # The caller has checked every symlink/hardlink in this owned home.
        [[ -f $path ]] || { sqlite_fail "missing audited control: $relative"; return; }
        audited[$relative]=1
    done < "$audit"
    (cd "$home" && sha256sum --strict --check "$audit" > /dev/null) || { sqlite_fail 'audited controls changed'; return; }
    for path in "$home/.env" "$home/.env_" "$settings"; do
        [[ ${audited[${path#"$home/"}]:-} == 1 ]] || { sqlite_fail "unaudited control: $path"; return; }
    done
    # Include every copied control file, not only direct .env source statements.
    local listing
    listing=$(mktemp) || return
    find "$home/cplx/bin" "$home/cplx/echos" "$home/cplx/closure" \
        -type f -print0 > "$listing" || { rm -f "$listing"; return 2; }
    for path in "$home/cplx/.env" "$home/cplx/.env_user" "$home/cplx/.env_init" \
        "$home/cplx/cplx.properties" "$home/cplx/rsync_include.txt" "$home/cplx/rsync_exclude.txt" \
        "$home/cplx/tools/install" "$home/cplx/tools/install_functions.sh" \
        "$home/cplx/tools/python/python_install_functions.sh" "$home/cplx/tools/python/sqlite_probe.py"; do
        printf '%s\0' "$path" >> "$listing"
    done
    while IFS= read -r -d '' path; do
        if [[ ${audited[${path#"$home/"}]:-} != 1 ]]; then
            rm -f "$listing"; sqlite_fail "unaudited control: $path"; return
        fi
    done < "$listing"
    rm -f "$listing"
    sqlite_scalars=()
    while IFS= read -r line; do
        [[ -n $line && $line != '#'* ]] || continue
        key=${line%%=*}; value=${line#*=}
        # Path-valued configuration belongs in the audited owned files. No eval.
        [[ $key =~ ^(USER|LOGNAME|TERM|CPLX_BIN|CPLX_ARCH_EXT|tool_name|service|environment)$ &&
           $value =~ ^[a-zA-Z0-9_.:-]+$ ]] || { sqlite_fail "unsupported scalar: $key"; return; }
        sqlite_scalars+=("$key=$value")
    done < "$settings"
}
sqlite_list_manifest() {
    local home=$1 list=$2 path
    local -a paths=()
    while IFS= read -r path; do
        [[ -n $path && -f $path ]] || return 2
        sqlite_inside "$home" "$path" || return
        paths+=("$path")
    done < "$list"
    ((${#paths[@]})) || return 2
    sqlite_manifest "${paths[@]}"
}
sqlite_host() {
    local role=$1 evidence=$2 image=$3 container=$4
    cp /etc/os-release "$evidence/os-release"
    if [[ $role == debian ]]; then
        if ! grep -qx 'ID=debian' "$evidence/os-release" ||
           ! grep -qx 'VERSION_ID="12"' "$evidence/os-release" ||
           [[ ! $image =~ ^sha256:[0-9a-f]{64}$ || ! $container =~ ^[0-9a-f]{12,64}$ ]]; then
            sqlite_fail 'Debian 12 image/container identity missing'; return
        fi
        printf 'image=%s\ncontainer=%s\n' "$image" "$container" > "$evidence/container"
    else
        if ! grep -Eq '^ID="?rhel"?$' "$evidence/os-release" ||
           ! grep -qx 'VERSION_ID="9.8"' "$evidence/os-release"; then
            sqlite_fail 'RHEL 9.8 required'; return
        fi
    fi
}
sqlite_operator() {
    local home=$1 evidence=$2 parser=$3 probe=$4 root=$5 extension=$6 provider=$7
    [[ $(readlink -e "$root") == "$(readlink -e "$home/tools/python")" &&
       $(readlink -e "$extension") == "$(readlink -e "$home/tools/python/python-3.13.15/lib/python3.13/lib-dynload")" &&
       $(readlink -e "$provider") == "$(readlink -e "$home/tools/python/root/usr/lib64/libsqlite3.so.0")" ]] || {
        sqlite_fail 'operator expectations differ from the independently specified layout'; return;
    }
    sqlite_inside "$home" "$probe" || return
    mkdir -p "$evidence/scratch"
    sqlite_capture "$home" "$evidence" operator "$home/tools/python/bin/python" -I -S -B "$probe" \
        --stage operator --expected-python-root "$root" --expected-extension-root "$extension" \
        --expected-provider "$provider" --scratch-dir "$evidence/scratch" || return
    # A wrapper banner mixed into stdout is not a structured probe success.
    cp "$evidence/operator.log" "$evidence/operator.json"
    sqlite_result "$parser" "$evidence/operator.json" operator "$root" "$extension" "$provider"
}
sqlite_build_records() {
    local parser=$1 evidence=$2 home=$3 source=$4 stage
    cp -- "$home/cplx/tools/python/log" "$evidence/build.full.log" || return
    "$parser" -I -S -B - "$evidence" <<'PY' || return
import json
from pathlib import Path
import sys

root = Path(sys.argv[1])
records = {}
for line in (root / 'build.full.log').read_text(errors='replace').splitlines():
    if line.startswith('{'):
        record = json.loads(line)
        if record.get('stage') in ('build', 'installed'):
            assert record['stage'] not in records, 'duplicate stage result'
            records[record['stage']] = line
for stage in ('build', 'installed'):
    (root / (stage + '.json')).write_text(records[stage] + '\n')
PY
    for stage in 'configure done' 'Must make clean' 'Clean done' 'Must make all in' 'make all is now done'; do
        grep -Fq "$stage" "$evidence/build.full.log" || { sqlite_fail "missing rebuild evidence: $stage"; return; }
    done
    # Autoconf config.log writes the check and its result on separate lines.
    grep -Fq 'checking for stdlib extension module _sqlite3' "$source/config.log" || return 2
    grep -qx 'MODULE__SQLITE3_STATE=yes' "$source/config.log" || return 2
    grep -Fq -- "--prefix=$home/cplx/tools/python/python-3.13.15" "$evidence/build.full.log" || return 2
    sqlite_result "$parser" "$evidence/build.json" build "$home/cplx/tools/python" \
        "$source/build/lib.linux-x86_64-3.13" "$home/cplx/tools/python/root/usr/lib64/libsqlite3.so.0" || return
    sqlite_result "$parser" "$evidence/installed.json" installed "$home/cplx/tools/python" \
        "$home/cplx/tools/python/python-3.13.15/lib/python3.13/lib-dynload" \
        "$home/cplx/tools/python/root/usr/lib64/libsqlite3.so.0"
}
sqlite_phase_finish() {
    local phase=$1 evidence=$2 status=$3
    if ((status)); then
        printf 'phase=%s exit=%s\n' "$phase" "$status" > "$evidence/failed"
        if [[ -f $evidence/live.before && ! -f $evidence/live.after ]]; then sqlite_preservation "$evidence" || true; fi
    fi
}
sqlite_main() (
    set -euo pipefail
    local phase=${1:-} key home role evidence path status archive digest
    [[ $phase =~ ^(preflight|build|assemble|deploy|probe)$ ]] || { sqlite_fail 'phase: preflight|build|assemble|deploy|probe'; exit 2; }
    shift
    local -A opt=()
    local -a live=()
    while (($#)); do
        (($# >= 2)) || { sqlite_fail "missing value: $1"; exit 2; }
        key=${1#--}
        case $key in
            live-root) live+=("$2");;
            home|role|evidence|parser|audit|audit-sha256|settings|source|sentinels|payloads|revision|archive|sha256|probe|expected-python-root|expected-extension-root|expected-provider|image-digest|container-id)
                [[ ! ${opt[$key]+present} ]] || { sqlite_fail "duplicate option: $1"; exit 2; }
                opt[$key]=$2;;
            *) sqlite_fail "unknown option: $1"; exit 2;;
        esac
        shift 2
    done
    for key in home role evidence parser audit audit-sha256 settings revision probe expected-python-root expected-extension-root expected-provider; do
        [[ -n ${opt[$key]:-} ]] || { sqlite_fail "required: --$key"; exit 2; }
    done
    home=${opt[home]}; role=${opt[role]}; evidence=${opt[evidence]}
    [[ $role =~ ^(build|rhel|debian)$ && ${opt[revision]} =~ ^[0-9a-f]{40}$ && ${opt[audit-sha256]} =~ ^[0-9a-f]{64}$ ]] || exit 2
    sqlite_anchor "$home" "$role"
    sqlite_inside "$home" "$evidence"
    [[ -d $evidence && ! -L $evidence && $(readlink -e "$evidence") == "$evidence" ]] || exit 2
    # Failure reporting itself must not follow a diagnostic link into live state.
    sqlite_boundary "$evidence"
    # From this point failures retain diagnostics and close the live comparison.
    # Bind arguments now: function-local variables can be gone when EXIT fires.
    # shellcheck disable=SC2064
    trap "$(printf 'sqlite_phase_finish %q %q "$?"' "$phase" "$evidence")" EXIT
    [[ ! -e $evidence/failed && ! -e $evidence/role.json ]] || { sqlite_fail 'capture already failed or finalized; inspect retained evidence'; exit 2; }
    sqlite_profile "$home"
    sqlite_boundary "$home"
    ((${#live[@]})) || { sqlite_fail 'explicit live preservation roots required'; exit 2; }
    for path in "${live[@]}"; do
        # A live control may itself be a symlink (for example .profile).
        # Inventory that link without following it; its target can be named as
        # an additional live root when content preservation is required.
        [[ $path == /* && ( -d $path || -f $path || -L $path ) &&
           $(readlink -e "$(dirname "$path")") == "$(dirname "$path")" && $path != / &&
           $path != "$home" && $path != "$home/"* && $home != "$path/"* ]] || { sqlite_fail "overlapping live/owned root: $path"; exit 2; }
    done
    for key in audit settings probe; do sqlite_inside "$home" "${opt[$key]}"; done
    [[ ${opt[parser]} == /* && -x ${opt[parser]} ]] || { sqlite_fail 'absolute JSON parser required'; exit 2; }
    sqlite_audit "$home" "${opt[audit]}" "${opt[audit-sha256]}" "${opt[settings]}"
    printf 'phase=%s role=%s home=%s evidence=%s\n' "$phase" "$role" "$home" "$evidence"
    for key in parser audit settings probe expected-python-root expected-extension-root expected-provider; do
        printf '%s=%s\n' "$key" "$(readlink -m "${opt[$key]}")"
    done > "$evidence/$phase.paths"
    if [[ $phase == preflight ]]; then
        [[ ! -e $evidence/preflight.done && ! -e $evidence/live.before ]] || exit 2
        for path in cplx tools pkgs; do [[ -d $home/$path && ! -L $home/$path ]]; done
        sqlite_host "$role" "$evidence" "${opt[image-digest]:-}" "${opt[container-id]:-}"
        printf '%s\n' "${live[@]}" > "$evidence/live.roots"
        sqlite_manifest "${live[@]}" > "$evidence/live.before"
        printf '%s\n' "$home" "$role" "${opt[revision]}" > "$evidence/context"
        printf 'absent\n' > "$evidence/profile"
        printf '%s\n' "${sqlite_scalars[@]}" > "$evidence/scalars"
    else
        [[ -f $evidence/preflight.done ]] || { sqlite_fail 'preflight required'; exit 2; }
        cmp -s "$evidence/context" <(printf '%s\n' "$home" "$role" "${opt[revision]}")
        cmp -s "$evidence/live.roots" <(printf '%s\n' "${live[@]}")
        [[ ! -e $evidence/$phase.started ]] || { sqlite_fail "phase already attempted: $phase"; exit 2; }
    fi
    # A deployment can replace .env and .env_; the next phase needs their reviewed audit.
    cp "${opt[audit]}" "$evidence/$phase.audit"
    printf '%s\n' "${opt[audit-sha256]}" > "$evidence/$phase.audit.sha256"
    date -u +%FT%TZ > "$evidence/$phase.started"
    case $phase in
        preflight) ;;
        build)
            [[ $role == build && -n ${opt[source]:-} && -n ${opt[sentinels]:-} && -n ${opt[payloads]:-} ]] || exit 2
            sqlite_inside "$home/cplx/tools/python/sources" "${opt[source]}"
            [[ -x ${opt[source]}/python ]]
            grep -q 'creating Makefile$' "${opt[source]}/config.log"
            sqlite_list_manifest "$home" "${opt[sentinels]}" > "$evidence/sentinels.before"
            sqlite_list_manifest "$home" "${opt[payloads]}" > "$evidence/payloads.before"
            # Confirm the unchanged installer's one-segment home relocation rule.
            grep -Fq 'HOME_ANCHOR="/ho""me/"' "$home/cplx/bin/install_pkg.sh"
            grep -Fq 'HOME_ANCHOR}[^/]*/cplx/tools/' "$home/cplx/bin/install_pkg.sh"
            sqlite_capture "$home" "$evidence" build bash "$home/cplx/tools/install" python 3.13.15 --reconfigure
            sqlite_build_records "${opt[parser]}" "$evidence" "$home" "${opt[source]}"
            sqlite_list_manifest "$home" "${opt[sentinels]}" > "$evidence/sentinels.after"
            sqlite_list_manifest "$home" "${opt[payloads]}" > "$evidence/payloads.after"
            sqlite_manifest_equal "$evidence/sentinels.before" "$evidence/sentinels.after"
            sqlite_manifest_equal "$evidence/payloads.before" "$evidence/payloads.after"
            ;;
        assemble)
            [[ $role == build && -f $evidence/build.done ]]
            # No candidate may predate this one-time packaging invocation.
            for path in "$home"/tools.*.tar.gz "$home"/pkgs/tools.*.tar.gz; do [[ ! -e $path && ! -L $path ]]; done
            sqlite_capture "$home" "$evidence" promotion-dry-run bash "$home/cplx/bin/rsync.sh" --dry-run
            sqlite_boundary "$home"
            sqlite_capture "$home" "$evidence" promotion bash "$home/cplx/bin/rsync.sh"
            sqlite_operator "$home" "$evidence" "${opt[parser]}" "${opt[probe]}" "${opt[expected-python-root]}" "${opt[expected-extension-root]}" "${opt[expected-provider]}"
            for path in log stderr timeline command json; do
                cp "$evidence/operator.$path" "$evidence/promoted-operator.$path"
            done
            sqlite_capture "$home" "$evidence" package bash "$home/cplx/bin/pkg_tools.sh"
            local -a archives=()
            for path in "$home"/pkgs/tools.*.tar.gz; do
                [[ ! -f $path || -L $path ]] || archives+=("$path")
            done
            [[ ${#archives[@]} == 1 && -f ${archives[0]} ]]
            archive=${archives[0]}; digest=$(sqlite_digest "$archive")
            sqlite_archive "$home" "$archive" "$digest"
            printf '%s\n' "$archive" > "$evidence/archive.path"
            printf '%s\n' "$digest" > "$evidence/archive.sha256"
            { printf 'filename=%s\nsha256=%s\nsize=%s\nrevision=%s\npython=3.13.15\n' "${archive##*/}" "$digest" "$(stat -c %s "$archive")" "${opt[revision]}";
              cat "$home/cplx/closure/closure-envelope.txt"; } > "$evidence/candidate"
            ;;
        deploy)
            [[ $role != build && -n ${opt[archive]:-} && -n ${opt[sha256]:-} ]]
            sqlite_archive "$home" "${opt[archive]}" "${opt[sha256]}"
            printf '%s\n' "${opt[archive]}" > "$evidence/archive.path"
            printf '%s\n' "${opt[sha256]}" > "$evidence/archive.sha256"
            sqlite_capture "$home" "$evidence" relocation bash "$home/cplx/bin/install_pkg.sh" tools --prefix "$home"
            sqlite_archive "$home" "${opt[archive]}" "${opt[sha256]}"
            ;;
        probe)
            if [[ $role == build ]]; then [[ -f $evidence/assemble.done ]]; else [[ -f $evidence/deploy.done ]]; fi
            archive=$(cat "$evidence/archive.path"); digest=$(cat "$evidence/archive.sha256")
            sqlite_archive "$home" "$archive" "$digest"
            sqlite_operator "$home" "$evidence" "${opt[parser]}" "${opt[probe]}" "${opt[expected-python-root]}" "${opt[expected-extension-root]}" "${opt[expected-provider]}"
            sqlite_boundary "$home"
            sqlite_preservation "$evidence"
            printf '{"role":"%s","sha256":"%s","probe_sha256":"%s","preservation":"passed"}\n' \
                "$role" "$digest" "$(sqlite_digest "$evidence/operator.json")" > "$evidence/role.json"
            ;;
    esac
    date -u +%FT%TZ > "$evidence/$phase.done"
    printf 'Capture phase passed: %s (%s); all three roles still require evidence review.\n' "$phase" "$role"
)

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then sqlite_main "$@"; fi
