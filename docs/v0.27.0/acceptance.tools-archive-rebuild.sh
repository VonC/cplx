#!/bin/bash
# Platform acceptance driver for the identified final tools archive (Step 6 of
# plan.v0.27.0.tools-archive-rebuild.md).
#
# Every subcommand takes EXPLICIT PINS: the archive digest, the independently
# delivered verification bundle digest and the cplx source revision. Nothing is
# discovered from a "latest" file, a branch or a directory listing, and a wrong
# identity refuses before any probe runs. Every probe writes a raw capture under
# the owned run home and a cell file naming pass, fail or inconclusive; a cell
# that never ran stays PENDING in the summary and can never read as a pass.
#
#   rhel      run the required RHEL cells (PA1, PA2, PA3 build/deploy, PA4, PA5,
#             PA6, PA10, PA11 and the AR3 archive-content assertions) into a new
#             run home under /home, with the installer, closure checker and
#             SQLite acceptance driver taken from the verified bundle.
#   debian    read one retained candidate build of the actual Jenkins agent (its
#             archived evidence tree and console) into the same cell grammar.
#   d10       take one D10 reading with the bounded rebuild policy: a first
#             reading may demand one rebuild, the second must settle, and a
#             third iteration is refused.
#   summarize turn the cell files of a run home into one sanitized JSON record
#             with digested raw captures; the exit code is the verdict.
#   bundle-check
#             verify a bundle's manifest and source revision before extraction,
#             the consumer's half of the check deliver-closure-tools.sh made.
#
# Exit codes: 0 every required cell passes; 1 at least one cell fails; 2 the
# arguments or identities are unusable; 3 (d10) one rebuild is required;
# 5 a required cell is inconclusive or still pending.
set -euo pipefail

ACCEPT_SCHEMA="tools-archive-rebuild-acceptance/1"
ACCEPT_RHEL_CELLS="AR3 PA1:rhel PA2:rhel PA3:rhel-build PA3:rhel-deploy PA4:rhel PA5:rhel PA6:rhel PA10:rhel PA11:rhel"
ACCEPT_DEBIAN_CELLS="PA1:debian PA2:debian PA3:debian PA4:debian PA5:debian PA6:debian PA7:debian PA8:debian PA9:debian"

refuse() { printf 'acceptance: %s\n' "$*" >&2; exit 2; }
hex64() { [[ ${1:-} =~ ^[0-9a-f]{64}$ ]]; }
hex40() { [[ ${1:-} =~ ^[0-9a-f]{40}$ ]]; }
digest_of() { local out; out=$(sha256sum -- "$1"); printf '%s\n' "${out%% *}"; }
absolute_file() { [[ ${1:-} == /* && -f $1 && ! -L $1 ]]; }
independent_python() {
    [[ ${1:-} == /* && -x $1 ]] || refuse "an absolute independent Python 3.9+ is required"
    "$1" -c 'import sys; assert sys.version_info >= (3, 9)' 2>/dev/null || refuse "independent Python 3.9+ required: $1"
}

# ------------------------------------------------------------ run home cells ---
# A cell is one file of key=value lines. The identity lines bind every result to
# the pinned archive and run, so a cell copied from another run cannot summarize.
cell_write() {
    local cell=$1 state=$2 reason=$3 capture
    shift 3
    [[ $state =~ ^(pass|fail|inconclusive)$ ]]
    {
        printf 'cell=%s\nstate=%s\nreason=%s\narchive_sha256=%s\nrun=%s\n' \
            "$cell" "$state" "$reason" "$ACCEPT_ARCHIVE_SHA256" "$ACCEPT_RUN"
        for capture in "$@"; do printf 'capture=%s\n' "$capture"; done
    } > "$ACCEPT_HOME/cells/$cell"
    printf 'CELL|%s|%s|%s\n' "$cell" "$state" "$reason"
}

# capture NAME COMMAND...: one raw log and one exit file per probe, never a
# verdict. Returns the command's status so the caller decides the cell.
capture() {
    local name=$1 code=0
    shift
    "$@" > "$ACCEPT_HOME/raw/$name.log" 2>&1 || code=$?
    printf '%s\n' "$code" > "$ACCEPT_HOME/raw/$name.exit"
    return "$code"
}

# The structured half of one installer run, read from its retained log: the
# CPLX-ELF/1 trailer counters, the case population and the case assigned to the
# interpreter ELF. Written beside the log as JSON by the independent Python.
elf_summary() {
    local name=$1
    "$ACCEPT_PYTHON" - "$ACCEPT_HOME/raw/$name.log" "$ACCEPT_HOME/raw/$name.elf.json" <<'PY'
import json
import re
import sys
from pathlib import Path
log, out = Path(sys.argv[1]), Path(sys.argv[2])
summary = {"state": "", "reason": "", "counters": {}, "cases": {str(n): 0 for n in range(1, 8)},
           "python_case": "", "python_path": "", "records": 0, "trailers": 0}
for line in log.read_text(errors="replace").splitlines():
    if line.startswith("CPLX-ELF/1 obj "):
        fields = dict(part.split("=", 1) for part in line.split()[2:])
        summary["records"] += 1
        summary["cases"][fields["case"]] = summary["cases"].get(fields["case"], 0) + 1
        path = bytes.fromhex(fields["path"]).decode(errors="replace")
        if re.fullmatch(r"python/python-3\.13\.\d+/bin/python3\.13(_bin)?", path):
            summary["python_case"], summary["python_path"] = fields["case"], path
    elif line.startswith("CPLX-ELF/1 end "):
        fields = dict(part.split("=", 1) for part in line.split()[2:])
        summary["trailers"] += 1
        summary["state"], summary["reason"] = fields.pop("state"), fields.pop("reason")
        summary["counters"] = {key: int(value) for key, value in fields.items()}
out.write_text(json.dumps(summary, indent=2) + "\n")
PY
}

elf_field() { "$ACCEPT_PYTHON" -c 'import json,sys; d=json.load(open(sys.argv[1])); print(eval(sys.argv[2], {}, {"d": d}))' "$ACCEPT_HOME/raw/$1.elf.json" "$2"; }

# ---------------------------------------------------------------- bundle-check ---
# The consumer's reading: regular members below src/ and acceptance/ only, a
# revision file naming the pinned commit and a manifest covering every other
# regular member exactly. Extracts into DEST only after every check passes.
bundle_check() {
    local bundle=$1 expected=$2 revision=$3 dest=$4 entry kind listed present scratch
    absolute_file "$bundle" || refuse "bundle must be an absolute regular file: $bundle"
    hex64 "$expected" || refuse "bundle digest pin must be 64 hex characters"
    hex40 "$revision" || refuse "source revision pin must be 40 hex characters"
    [[ ! -e $dest ]] || refuse "bundle destination already exists: $dest"
    [[ $(digest_of "$bundle") == "$expected" ]] || refuse "bundle digest differs from its pin"
    scratch=$(mktemp -d "${TMPDIR:-/tmp}/tools-bundle-check.XXXXXXXX")
    tar -tzvf "$bundle" > "$scratch/members"
    while IFS= read -r entry; do
        kind=${entry:0:1}; entry=${entry##* }; entry=${entry%/}
        [[ $kind == - || $kind == d ]] || { rm -rf -- "$scratch"; refuse "non-regular bundle member: $entry"; }
        [[ $entry == src || $entry == acceptance || $entry == src/* || $entry == acceptance/* ]] || { rm -rf -- "$scratch"; refuse "bundle member outside src/ and acceptance/: $entry"; }
        [[ /$entry/ != *'/../'* && /$entry/ != *'/./'* && /$entry/ != *'//'* ]] || { rm -rf -- "$scratch"; refuse "unsafe bundle member: $entry"; }
    done < "$scratch/members"
    mkdir -- "$scratch/tree"
    tar -xzf "$bundle" -C "$scratch/tree"
    [[ -f $scratch/tree/acceptance/verification.sha256 && -f $scratch/tree/acceptance/source-revision.txt ]] \
        || { rm -rf -- "$scratch"; refuse "bundle carries no manifest or source revision"; }
    [[ $(cat "$scratch/tree/acceptance/source-revision.txt") == "$revision" ]] \
        || { rm -rf -- "$scratch"; refuse "bundle source revision differs from its pin"; }
    (cd "$scratch/tree" && sha256sum --strict --check acceptance/verification.sha256 > /dev/null) \
        || { rm -rf -- "$scratch"; refuse "bundle manifest does not cover its exact bytes"; }
    listed=$(grep -c . "$scratch/tree/acceptance/verification.sha256")
    present=$(find "$scratch/tree/src" "$scratch/tree/acceptance" -type f ! -name verification.sha256 | grep -c .)
    [[ $listed == "$present" ]] || { rm -rf -- "$scratch"; refuse "bundle manifest lists $listed members for $present files"; }
    mkdir -p -- "$(dirname -- "$dest")"
    mv -- "$scratch/tree" "$dest"
    rm -rf -- "$scratch"
    printf 'BUNDLE-CHECK|%s|%s|%s\n' "$revision" "$present" "$dest"
}

# ------------------------------------------------------------------------ rhel ---
rhel_usage() {
    cat >&2 <<'USAGE'
usage: acceptance.tools-archive-rebuild.sh rhel --run ID --home DIR --python /abs/python
         --archive FILE --archive-sha256 HEX --bundle FILE --bundle-sha256 HEX --revision HEX
         --pdfs FILE --deploy-script FILE --deploy-script-sha256 HEX
         --previous-installer FILE --previous-installer-sha256 HEX
         [--build-evidence FILE] [--sqlite-parser /usr/bin/python3] [--live-root PATH]...
USAGE
    exit 2
}

rhel_main() {
    local run="" home="" python="" archive="" archive_sha="" bundle="" bundle_sha="" revision=""
    local pdfs="" deploy="" deploy_sha="" previous="" previous_sha="" build_evidence="" parser=/usr/bin/python3
    local -a live=()
    while (($#)); do
        (($# >= 2)) || rhel_usage
        case $1 in
            --run) run=$2 ;; --home) home=$2 ;; --python) python=$2 ;;
            --archive) archive=$2 ;; --archive-sha256) archive_sha=$2 ;;
            --bundle) bundle=$2 ;; --bundle-sha256) bundle_sha=$2 ;; --revision) revision=$2 ;;
            --pdfs) pdfs=$2 ;; --deploy-script) deploy=$2 ;; --deploy-script-sha256) deploy_sha=$2 ;;
            --previous-installer) previous=$2 ;; --previous-installer-sha256) previous_sha=$2 ;;
            --build-evidence) build_evidence=$2 ;; --sqlite-parser) parser=$2 ;; --live-root) live+=("$2") ;;
            *) rhel_usage ;;
        esac
        shift 2
    done
    [[ -n $run && -n $home && -n $python && -n $archive && -n $bundle && -n $pdfs && -n $deploy && -n $previous ]] || rhel_usage
    [[ $run =~ ^[A-Za-z0-9][A-Za-z0-9._-]{3,80}$ ]] || refuse "run identity must be a plain token: $run"
    [[ $home == /home/*/* && $home != *'/../'* ]] || refuse "the run home must be a new directory below /home/<account>/: $home"
    [[ ! -e $home ]] || refuse "the run home already exists: $home"
    independent_python "$python"
    if ! hex64 "$archive_sha" || ! hex64 "$bundle_sha" || ! hex40 "$revision" || ! hex64 "$deploy_sha" || ! hex64 "$previous_sha"; then
        refuse "archive, bundle, deploy-script and previous-installer digests and the revision must be hex pins"
    fi
    local pinned
    for pinned in "$archive" "$bundle" "$pdfs" "$deploy" "$previous"; do absolute_file "$pinned" || refuse "absolute regular file required: $pinned"; done
    [[ $archive == */tools.[0-9]*.tar.gz && $pdfs == */pdfs.[0-9]*.tar.gz ]] || refuse "explicit timestamped tools and pdfs archives are required"
    [[ $(digest_of "$archive") == "$archive_sha" ]] || refuse "archive digest differs from its pin"
    [[ $(digest_of "$deploy") == "$deploy_sha" ]] || refuse "deploy script digest differs from its pin"
    [[ $(digest_of "$previous") == "$previous_sha" ]] || refuse "previous installer digest differs from its pin"
    [[ -z $build_evidence ]] || absolute_file "$build_evidence" || refuse "build evidence must be an absolute regular file: $build_evidence"
    [[ $parser == /* && -x $parser ]] || refuse "absolute SQLite JSON parser required"
    ((${#live[@]})) || live=("$HOME/cplx" "$HOME/tools" "$HOME/pkgs" "$HOME/.env" "$HOME/.env_" "$HOME/.profile")

    ACCEPT_RUN=$run ACCEPT_HOME=$home ACCEPT_PYTHON=$python ACCEPT_ARCHIVE_SHA256=$archive_sha
    export ACCEPT_RUN ACCEPT_HOME ACCEPT_PYTHON ACCEPT_ARCHIVE_SHA256
    mkdir -p -- "$home/cells" "$home/raw" "$home/inputs" "$home/prefixes"
    local started=$SECONDS name=${archive##*/} pdfs_name=${pdfs##*/}
    printf 'run=%s\nrole=rhel\nschema=%s\narchive=%s\narchive_sha256=%s\nbundle_sha256=%s\nrevision=%s\npdfs=%s\npdfs_sha256=%s\ndeploy_script_sha256=%s\nprevious_installer_sha256=%s\nstarted_utc=%s\n' \
        "$run" "$ACCEPT_SCHEMA" "$name" "$archive_sha" "$bundle_sha" "$revision" "$pdfs_name" "$(digest_of "$pdfs")" \
        "$deploy_sha" "$previous_sha" "$(date -u +%FT%TZ)" > "$home/inputs/pins"
    # The transferred bytes are re-digested from the copy the probes will read,
    # so a copy that drifted from the pin is caught before any prefix exists.
    cp -- "$archive" "$home/inputs/$name"
    [[ $(digest_of "$home/inputs/$name") == "$archive_sha" ]] || refuse "the copied archive differs from its pin"
    printf '%s\n' "$archive_sha" > "$home/inputs/transfer.sha256"
    cp -- "$pdfs" "$home/inputs/$pdfs_name"
    cp -- "$deploy" "$home/inputs/deploy_pkgs.sh"
    cp -- "$previous" "$home/inputs/install_pkg.previous.sh"
    {
        cat /etc/os-release
        printf 'kernel=%s\nbash=%s\nrsync=%s\n' "$(uname -r)" "$BASH_VERSION" "$(command -v rsync || echo absent)"
    } > "$home/raw/environment.txt"
    bundle_check "$bundle" "$bundle_sha" "$revision" "$home/verification" > "$home/raw/bundle-check.log"
    local installer=$home/verification/src/setups/env/bin/install_pkg.sh
    local checker=$home/verification/src/setups/env/bin/closure_check.sh
    chmod 0755 -- "$installer" "$checker" "$home/inputs/install_pkg.previous.sh" "$home/inputs/deploy_pkgs.sh"

    rhel_fresh_prefix "$installer" "$checker"
    rhel_home_states "$installer"
    rhel_deployment
    rhel_sqlite_roles "$bundle" "$bundle_sha" "$revision" "$parser" "$build_evidence" "${live[@]}"
    printf 'elapsed_seconds=%s\nended_utc=%s\n' "$((SECONDS - started))" "$(date -u +%FT%TZ)" >> "$home/inputs/pins"
    summarize_main --home "$home" --python "$python" --role rhel --out "$home/results.json"
}

# PA1 (fresh relocation, then a --force reinstall over the same prefix), PA2,
# the deploy-role import half of PA3, PA4 and PA5, all over one prefix that the
# installer relocated with an explicit --prefix and HOME pinned to it.
rhel_fresh_prefix() {
    local installer=$1 checker=$2 prefix=$ACCEPT_HOME/prefixes/fresh name state reason
    mkdir -p -- "$prefix/pkgs"
    cp -- "$ACCEPT_HOME/inputs/"tools.*.tar.gz "$prefix/pkgs/"
    state=pass reason="fresh relocation completed and the forced reinstall reproduced it"
    if ! capture install-fresh env HOME="$prefix" bash "$installer" tools --prefix "$prefix"; then
        state=fail reason="fresh relocation exited $(cat "$ACCEPT_HOME/raw/install-fresh.exit")"
    fi
    elf_summary install-fresh
    [[ $(elf_field install-fresh 'd["state"] + " " + d["reason"]') == "completed none" ]] || { state=fail; reason="fresh relocation trailer is not a completed pass"; }
    (($(elf_field install-fresh 'd["counters"].get("r-rewritten", 0)') > 0)) || { state=fail; reason="fresh relocation rewrote no rpath"; }
    # A forced reinstall re-extracts the archive and mirrors its pristine bytes
    # before the pass, so it must reproduce the fresh relocation exactly; the
    # pass run again over the result must then find every object already
    # correct. Both halves are AR3's force-reinstall assertion.
    local force=pass
    if [[ $state == pass ]]; then
        if capture install-force env HOME="$prefix" bash "$installer" tools --force --prefix "$prefix"; then
            elf_summary install-force
            [[ $(elf_field install-force 'd["state"] + " " + d["reason"]') == "completed none" ]] || { state=fail; reason="forced reinstall trailer is not a completed pass"; }
            [[ $(elf_field install-force 'd["counters"]') == $(elf_field install-fresh 'd["counters"]') ]] \
                || { state=fail; reason="forced reinstall did not reproduce the fresh relocation counters"; }
            [[ $(elf_field install-force 'd["counters"].get("mig-failed", -1)') == 0 ]] || { state=fail; reason="forced reinstall reported a failed migration"; }
        else
            state=fail reason="forced reinstall exited $(cat "$ACCEPT_HOME/raw/install-force.exit")"
        fi
        capture pass-after-force bash "${BASH_SOURCE[0]}" probe elf-pass "$installer" "$prefix" || force=fail
        elf_summary pass-after-force
        [[ $(elf_field pass-after-force 'd["counters"].get("r-rewritten", -1)') == 0 && $(elf_field pass-after-force 'd["python_case"]') == 3 ]] || force=fail
    else
        force=fail
    fi
    cell_write PA1:rhel "$state" "$reason" raw/install-fresh.log raw/install-fresh.elf.json raw/install-force.log raw/install-force.elf.json
    printf 'force_reinstall=%s\n' "$force" > "$ACCEPT_HOME/raw/ar3-force.txt"

    # PA2: the wrapper's FIRST call performs its one-time relink, so both calls
    # are retained and the relinked layout is asserted after the first.
    state=pass reason="wrapper first and second calls answered 3.13"
    capture wrapper-first env HOME="$prefix" "$prefix/tools/python/bin/python" --version || { state=fail; reason="wrapper first call exited $(cat "$ACCEPT_HOME/raw/wrapper-first.exit")"; }
    grep -q '^Python 3\.13\.' "$ACCEPT_HOME/raw/wrapper-first.log" || { state=fail; reason="wrapper first call printed no 3.13 version"; }
    [[ $(readlink "$prefix/tools/python/bin/current/bin/python3" 2>/dev/null) == ../../bin/python ]] || { state=fail; reason="first call left python3 unlinked from the wrapper"; }
    capture wrapper-second env HOME="$prefix" "$prefix/tools/python/bin/python" --version || { state=fail; reason="wrapper second call exited $(cat "$ACCEPT_HOME/raw/wrapper-second.exit")"; }
    grep -q '^Python 3\.13\.' "$ACCEPT_HOME/raw/wrapper-second.log" || { state=fail; reason="wrapper second call printed no 3.13 version"; }
    cell_write PA2:rhel "$state" "$reason" raw/wrapper-first.log raw/wrapper-second.log

    # PA3 deploy role, import half; the SQLite acceptance role run joins later.
    state=pass reason="ssl, zlib and sqlite3 import through the relocated wrapper"
    capture imports-deploy env HOME="$prefix" "$prefix/tools/python/bin/python" -c 'import ssl, zlib, sqlite3, sys; print(sys.version.split()[0]); print(ssl.OPENSSL_VERSION); print(zlib.ZLIB_RUNTIME_VERSION); print(sqlite3.sqlite_version); print(sqlite3.connect(":memory:").execute("select 1").fetchone()[0])' \
        || { state=fail; reason="imports exited $(cat "$ACCEPT_HOME/raw/imports-deploy.exit")"; }
    printf '%s\n' "$state" > "$ACCEPT_HOME/raw/pa3-deploy-imports.state"
    printf '%s\n' "$reason" > "$ACCEPT_HOME/raw/pa3-deploy-imports.reason"

    # PA4: the wrapper and the ELF behind it.
    state=pass reason="toolchain git wrapper and executable answer --version"
    capture git-wrapper env HOME="$prefix" "$prefix/tools/git/bin/git" --version || { state=fail; reason="git wrapper exited $(cat "$ACCEPT_HOME/raw/git-wrapper.exit")"; }
    capture git-elf env HOME="$prefix" GIT_EXEC_PATH="$prefix/tools/git/current/libexec/git-core" "$prefix/tools/git/current/bin/git" --version || { state=fail; reason="git executable exited $(cat "$ACCEPT_HOME/raw/git-elf.exit")"; }
    if ! grep -q '^git version ' "$ACCEPT_HOME/raw/git-wrapper.log" || ! grep -q '^git version ' "$ACCEPT_HOME/raw/git-elf.log"; then
        state=fail reason="git printed no version"
    fi
    cell_write PA4:rhel "$state" "$reason" raw/git-wrapper.log raw/git-elf.log

    # PA5: version-node coherence and provider family checks are the inherited
    # closure checker's, run by the delivered copy over the relocated prefix.
    state=pass reason="closure checker accepts the relocated prefix"
    if ! capture closure-check env HOME="$prefix" bash "$checker" --prefix "$prefix" --installer "$installer" --bundle "$prefix/tools/closure"; then
        case $(cat "$ACCEPT_HOME/raw/closure-check.exit") in
            5) state=inconclusive reason="closure checker could not obtain an input" ;;
            *) state=fail reason="closure checker refused, exit $(cat "$ACCEPT_HOME/raw/closure-check.exit")" ;;
        esac
    fi
    cell_write PA5:rhel "$state" "$reason" raw/closure-check.log

    # Runtime identities of the shipped providers, bound into the record.
    local resolved
    for name in python/root/lib64/ld-linux-x86-64.so.2 python/root/usr/lib64/libsqlite3.so.0 python/root/usr/lib64/libstdc++.so.6 python/root/usr/lib64/libc.so.6; do
        resolved=$(readlink -f -- "$prefix/tools/$name" || true)
        if [[ -n $resolved && -f $resolved ]]; then
            printf '%s=%s\n' "${name##*/}" "$(digest_of "$resolved")"
        else
            printf '%s=missing\n' "${name##*/}"
        fi
    done > "$ACCEPT_HOME/raw/runtime.txt"
    printf 'python=%s\n' "$(sed -n 's/^Python //p' "$ACCEPT_HOME/raw/wrapper-second.log" | head -1)" >> "$ACCEPT_HOME/raw/runtime.txt"
}

# Discover one deployed project and one venv; never choose between candidates.
deployed_venv() {
    local prefix=$1 path
    local -a projects=() venvs=()
    for path in "$prefix"/pdfs/*; do
        [[ ! -d $path ]] || projects+=("$path")
    done
    ((${#projects[@]} == 1)) || return 1
    for path in "${projects[0]}"/venvs/python_*; do
        [[ ! -f $path/pyvenv.cfg ]] || venvs+=("$path")
    done
    ((${#venvs[@]} == 1)) || return 1
    printf '%s\n' "${venvs[0]}"
}

# The operator probes re-enter this file under `env -i`, so the sourced files
# see exactly the environment an operator's fresh shell would.
probe_main() {
    # An operator shell has no errexit or nounset, and the sourced files rely
    # on that (an `unalias` of an absent alias, an unset USER); the probe must
    # observe them as an operator would rather than die on the first such line.
    set +eu
    case ${1:-} in
        senv)
            cd -- "$2"
            # shellcheck disable=SC1091
            source ./senv
            printf 'HOME=%s\n' "$HOME"
            command -v as python git
            python --version
            git --version ;;
        dotenv)
            # shellcheck disable=SC1091
            source "$HOME/.env"
            command -v python git
            python --version
            git --version ;;
        uv-audit)
            export HOME=$2 UV_PROJECT_ENVIRONMENT=$3 UV_PYTHON=$4 UV_OFFLINE=1 UV_NO_PROGRESS=1
            cd -- "$3/../.." || return 1
            "$3/bin/uv" --version
            "$3/bin/uv" sync --locked --offline --dry-run ;;
        deployed-venv) deployed_venv "$2" ;;
        elf-pass)
            # The relocation pass alone over an already deployed tree, the way
            # item 2's harness runs it: the installer's source guard defines its
            # functions without extracting anything, so the walk observes the
            # tree as it stands rather than a freshly mirrored copy of the archive.
            export HOME=$3 INSTALL_PREFIX=$3
            # shellcheck disable=SC1090
            source "$2"
            fix_elf_paths "$3/tools" ;;
        *) refuse "unknown probe: ${1:-}" ;;
    esac
}

# AR3: the three $HOME states and migration positivity, each on a prefix that
# IS the account-style default (no --prefix, HOME pinned): a first relocation
# classifies the interpreter as a fresh program (case 6); a prefix relocated by
# the v0.26.0 installer then walked by this installer classifies it as a
# migration (case 5) with a positive checked figure equal to the case 5
# population and zero failures; the next run over that prefix finds it already
# correct (case 3) and rewrites nothing.
rhel_home_states() {
    local installer=$1 fresh=$ACCEPT_HOME/prefixes/home migrate=$ACCEPT_HOME/prefixes/migrate
    local previous=$ACCEPT_HOME/inputs/install_pkg.previous.sh state=pass reason="three HOME states and migration positivity hold" checked case5
    mkdir -p -- "$fresh/pkgs" "$migrate/pkgs"
    cp -- "$ACCEPT_HOME/inputs/"tools.*.tar.gz "$fresh/pkgs/"
    cp -- "$ACCEPT_HOME/inputs/"tools.*.tar.gz "$migrate/pkgs/"
    capture home-fresh env HOME="$fresh" bash "$installer" tools || { state=fail; reason="HOME state 1 install exited $(cat "$ACCEPT_HOME/raw/home-fresh.exit")"; }
    elf_summary home-fresh
    [[ $(elf_field home-fresh 'd["python_case"]') == 6 ]] || { state=fail; reason="HOME state 1 did not classify the interpreter as a fresh program"; }
    [[ $(elf_field home-fresh 'd["counters"].get("mig-checked", -1)') == 0 ]] || { state=fail; reason="HOME state 1 checked a migration on a fresh tree"; }

    # States 2 and 3 are the pass alone over the v0.26.0-relocated tree: a
    # reinstall would mirror pristine archive bytes first and never meet the
    # predecessor's search-path value the migration branch recognizes.
    capture home-previous env HOME="$migrate" bash "$previous" tools || { state=fail; reason="v0.26.0 installer exited $(cat "$ACCEPT_HOME/raw/home-previous.exit")"; }
    capture pass-migrate bash "${BASH_SOURCE[0]}" probe elf-pass "$installer" "$migrate" || { state=fail; reason="migration pass exited $(cat "$ACCEPT_HOME/raw/pass-migrate.exit")"; }
    elf_summary pass-migrate
    [[ $(elf_field pass-migrate 'd["python_case"]') == 5 ]] || { state=fail; reason="HOME state 2 did not classify the interpreter as a migration"; }
    checked=$(elf_field pass-migrate 'd["counters"].get("mig-checked", -1)')
    case5=$(elf_field pass-migrate 'd["cases"]["5"]')
    ((checked > 0 && checked == case5)) || { state=fail; reason="migration checked $checked objects for a case 5 population of $case5"; }
    [[ $(elf_field pass-migrate 'd["counters"].get("mig-failed", -1)') == 0 ]] || { state=fail; reason="migration reported a failed object"; }

    capture pass-again bash "${BASH_SOURCE[0]}" probe elf-pass "$installer" "$migrate" || { state=fail; reason="HOME state 3 pass exited $(cat "$ACCEPT_HOME/raw/pass-again.exit")"; }
    elf_summary pass-again
    [[ $(elf_field pass-again 'd["python_case"]') == 3 ]] || { state=fail; reason="HOME state 3 did not find the interpreter already correct"; }
    [[ $(elf_field pass-again 'd["counters"].get("r-rewritten", -1)') == 0 ]] || { state=fail; reason="HOME state 3 rewrote an rpath"; }
    [[ $(cat "$ACCEPT_HOME/raw/ar3-force.txt") == force_reinstall=pass ]] || { state=fail; reason="forced reinstall over the fresh prefix did not reproduce and settle"; }
    cell_write AR3 "$state" "$reason" raw/home-fresh.log raw/home-fresh.elf.json raw/home-previous.log \
        raw/pass-migrate.log raw/pass-migrate.elf.json raw/pass-again.log raw/pass-again.elf.json \
        raw/install-force.elf.json raw/pass-after-force.log raw/pass-after-force.elf.json
}

# PA10 (deploy_pkgs.sh end to end with its readiness checks, then again with
# --force over the existing prefix, which is PA1's redeploy obligation), PA6
# (the deployed venv audited against the lock offline, then the heavy wheels
# imported) and PA11 (operator senv and .env sourcing) over one deployment.
rhel_deployment() {
    local prefix=$ACCEPT_HOME/prefixes/deploy deploy=$ACCEPT_HOME/inputs/deploy_pkgs.sh state reason venv interpreter
    mkdir -p -- "$prefix/pkgs"
    cp -- "$ACCEPT_HOME/inputs/"pdfs.*.tar.gz "$prefix/pkgs/"
    cp -- "$ACCEPT_HOME/inputs/"tools.*.tar.gz "$prefix/pkgs/"
    state=pass reason="deployment and forced redeployment passed every readiness check"
    # MAIL_TO empty skips the automatic log mail; the log stays in the prefix.
    capture deploy-fresh env HOME="$prefix" MAIL_TO= bash "$deploy" "$prefix" || { state=fail; reason="deployment exited $(cat "$ACCEPT_HOME/raw/deploy-fresh.exit")"; }
    grep -q 'All readiness checks passed' "$ACCEPT_HOME/raw/deploy-fresh.log" || { state=fail; reason="deployment did not report every readiness check passed"; }
    capture deploy-force env HOME="$prefix" MAIL_TO= bash "$deploy" "$prefix" --force || { state=fail; reason="forced redeployment exited $(cat "$ACCEPT_HOME/raw/deploy-force.exit")"; }
    grep -q 'All readiness checks passed' "$ACCEPT_HOME/raw/deploy-force.log" || { state=fail; reason="forced redeployment did not report every readiness check passed"; }
    cp -- "$prefix"/deploy.*.log "$ACCEPT_HOME/raw/" 2>/dev/null || true
    cell_write PA10:rhel "$state" "$reason" raw/deploy-fresh.log raw/deploy-force.log
    if [[ $state == pass ]]; then
        cell_write PA1:rhel-redeploy pass "deploy_pkgs.sh --force redeployed over the existing prefix" raw/deploy-force.log
    else
        cell_write PA1:rhel-redeploy fail "$reason" raw/deploy-force.log
    fi

    # PA6 on RHEL: no index is reachable from the deployment target, so the
    # deployed venv is audited against the lock offline, in a dry run that
    # cannot rewrite it, before the heavy wheels are imported from it. An audit
    # the host cannot answer, or a venv the pdfs archive built under another
    # patch release, is recorded as inconclusive and never as a pass.
    state=pass reason="deployed venv matches the lock offline and imports the heavy wheels"
    venv=$(deployed_venv "$prefix") || venv=''
    interpreter=$(find "$prefix/tools/python/current/bin" -maxdepth 1 -name 'python3*_bin' -type f | head -n 1)
    [[ -n $interpreter ]] || interpreter=$(find "$prefix/tools/python/current/bin" -maxdepth 1 -name 'python3.1[0-9]' -type f | head -n 1)
    if [[ -z $venv || -z $interpreter || ! -x $venv/bin/uv ]]; then
        state=inconclusive reason="no unique deployed project and venv, uv or toolchain interpreter to audit"
    else
        if ! capture uv-sync bash "${BASH_SOURCE[0]}" probe uv-audit "$prefix" "$venv" "$interpreter"; then
            if grep -qiE 'offline|network|download|cache|No solution' "$ACCEPT_HOME/raw/uv-sync.log"; then
                state=inconclusive reason="offline lock audit could not be answered on this host"
            else
                state=fail reason="uv sync --locked --offline --dry-run exited $(cat "$ACCEPT_HOME/raw/uv-sync.exit")"
            fi
        elif grep -qE 'Would (install|remove|replace|create|update)' "$ACCEPT_HOME/raw/uv-sync.log"; then
            state=inconclusive reason="deployed venv differs from the lock under the candidate interpreter"
        fi
        if ! capture imports-wheels env HOME="$prefix" "$venv/bin/python" -I -c 'import sys, pymupdf, pikepdf; print(sys.version.split()[0], sys._base_executable); print(pymupdf.__version__, pikepdf.__version__)'; then
            state=fail reason="pymupdf/pikepdf import exited $(cat "$ACCEPT_HOME/raw/imports-wheels.exit")"
        fi
        # The relocated wheel ELF's own search path, retained beside the import
        # result: a bundled provider is found through an ORIGIN-relative entry,
        # so its absence after relocation names the cause of a failed import.
        capture wheel-rpath find "$venv/lib" -path '*/pymupdf/_extra*.so' -exec readelf -d {} \; || true
        if [[ $state == fail ]] && grep -qE 'R(UN)?PATH' "$ACCEPT_HOME/raw/wheel-rpath.log" && ! grep -q 'ORIGIN' "$ACCEPT_HOME/raw/wheel-rpath.log"; then
            reason="$reason; the relocated wheel ELF search path carries no ORIGIN entry"
        fi
    fi
    cell_write PA6:rhel "$state" "$reason" raw/uv-sync.log raw/imports-wheels.log raw/wheel-rpath.log

    # The toolchain exposes its interpreter on the operator PATH as the
    # `python` wrapper and its git as the `git` wrapper; both must resolve
    # inside the prefix from senv and from the .env chain alike.
    state=pass reason="senv anchors HOME and .env exposes the prefix toolchain"
    capture senv env -i HOME="$HOME" TERM=dumb PATH=/usr/bin:/bin bash "${BASH_SOURCE[0]}" probe senv "$prefix" \
        || { state=fail; reason="senv sourcing exited $(cat "$ACCEPT_HOME/raw/senv.exit")"; }
    if ! grep -qx "HOME=$prefix" "$ACCEPT_HOME/raw/senv.log" || ! grep -q "^$prefix/.*/python$" "$ACCEPT_HOME/raw/senv.log" || ! grep -q "^$prefix/.*/git$" "$ACCEPT_HOME/raw/senv.log"; then
        state=fail reason="senv did not resolve HOME, python and git inside the prefix"
    fi
    capture dotenv env -i HOME="$prefix" TERM=dumb PATH=/usr/bin:/bin bash "${BASH_SOURCE[0]}" probe dotenv \
        || { state=fail; reason=".env sourcing exited $(cat "$ACCEPT_HOME/raw/dotenv.exit")"; }
    if ! grep -q "^$prefix/.*/python$" "$ACCEPT_HOME/raw/dotenv.log" || ! grep -q "^$prefix/.*/git$" "$ACCEPT_HOME/raw/dotenv.log" || ! grep -q '^Python 3\.13\.' "$ACCEPT_HOME/raw/dotenv.log"; then
        state=fail reason=".env did not resolve python and git inside the prefix"
    fi
    cell_write PA11:rhel "$state" "$reason" raw/senv.log raw/dotenv.log
}

# PA3 on both RHEL roles. The deploy role repeats item 6's acceptance driver
# from the verified bundle over its own private home. The build role was
# exercised by the build itself inside its private namespace, so its evidence is
# the retained Step 5 capture: it is verified here against the pinned archive
# (every probe stage passed over the same provider bytes) rather than re-probed
# from outside the namespace the tree was built in; without it the cell is
# inconclusive.
rhel_sqlite_roles() {
    local bundle=$1 bundle_sha=$2 revision=$3 parser=$4 build_evidence=$5 state reason home=$ACCEPT_HOME/sqlite/home
    shift 5
    local -a roots=("$@")
    local -a args=()
    local root
    for root in "${roots[@]}"; do [[ -e $root || -L $root ]] && args+=(--live-root "$root"); done
    [[ -L $HOME/.profile ]] && args+=(--live-root "$(readlink -e "$HOME/.profile")")
    mkdir -p -- "$home"
    state=$(cat "$ACCEPT_HOME/raw/pa3-deploy-imports.state") reason=$(cat "$ACCEPT_HOME/raw/pa3-deploy-imports.reason")
    if ! capture sqlite-deploy bash "$ACCEPT_HOME/verification/acceptance/acceptance.python-sqlite-deploy.sh" rhel "$home" \
            "$bundle" "$bundle_sha" "$ACCEPT_HOME/inputs/"tools.*.tar.gz "$ACCEPT_ARCHIVE_SHA256" "$revision" "$parser" "${args[@]}"; then
        state=fail reason="SQLite deploy-role acceptance exited $(cat "$ACCEPT_HOME/raw/sqlite-deploy.exit")"
    fi
    if [[ -f $home/evidence/role.json && -f $home/evidence/operator.json ]]; then
        cp -- "$home/evidence/role.json" "$ACCEPT_HOME/raw/sqlite-role.json"
        cp -- "$home/evidence/operator.json" "$ACCEPT_HOME/raw/sqlite-operator.json"
        "$ACCEPT_PYTHON" - "$ACCEPT_HOME/raw/sqlite-role.json" "$ACCEPT_HOME/raw/sqlite-operator.json" "$ACCEPT_ARCHIVE_SHA256" <<'PY' \
            || { state=fail; reason="SQLite deploy-role evidence is not a passed role over the pinned archive"; }
import json, sys
role, operator = (json.load(open(path)) for path in sys.argv[1:3])
assert role["role"] == "rhel" and role["sha256"] == sys.argv[3] and role["preservation"] == "passed"
assert operator["outcome"] == "passed" and operator["database"] == "passed"
PY
    elif [[ $state == pass ]]; then
        state=inconclusive reason="SQLite deploy-role evidence was not produced"
    fi
    cell_write PA3:rhel-deploy "$state" "$reason" raw/imports-deploy.log raw/sqlite-deploy.log raw/sqlite-role.json raw/sqlite-operator.json

    if [[ -z $build_evidence ]]; then
        cell_write PA3:rhel-build inconclusive "no retained build-role capture was named"
        return 0
    fi
    cp -- "$build_evidence" "$ACCEPT_HOME/raw/build-role.json"
    state=pass reason="retained build-role capture passed every probe stage over the pinned archive"
    if ! capture build-role "$ACCEPT_PYTHON" - "$ACCEPT_HOME/raw/build-role.json" "$ACCEPT_ARCHIVE_SHA256" "$ACCEPT_HOME/raw/build-provider.txt" <<'PY'
import json
import sys
record = json.load(open(sys.argv[1]))
assert record["candidate"]["sha256"] == sys.argv[2], "build capture names another archive"
probes = record["probes"]
assert {"build", "installed", "operator"} <= set(probes), "build capture lacks a probe stage"
providers = set()
for stage, probe in probes.items():
    assert probe["result"]["outcome"] == "passed" and probe["result"]["database"] == "passed", stage
    providers.add(probe["provider_file"]["sha256"])
assert len(providers) == 1, "probe stages observed different SQLite providers"
open(sys.argv[3], "w").write("build_provider=%s\nbuild_run=%s\n" % (providers.pop(), record["run"]))
print("build-role stages: " + " ".join(sorted(probes)))
PY
    then
        state=fail reason="retained build-role capture does not pass over the pinned archive"
    fi
    cell_write PA3:rhel-build "$state" "$reason" raw/build-role.json raw/build-role.log raw/build-provider.txt
}

# ---------------------------------------------------------------------- debian ---
# One retained candidate build of the actual agent, read into cells. The build
# is never re-run here: a missing capture leaves its cell pending, a refused
# capture fails it, and an identity that differs from the pins refuses.
debian_main() {
    local evidence="" run="" archive_sha="" bundle_sha="" revision="" python="" out="" app="" app_revision=""
    while (($#)); do
        (($# >= 2)) || refuse "debian options come in pairs"
        case $1 in
            --evidence) evidence=$2 ;; --run) run=$2 ;; --archive-sha256) archive_sha=$2 ;;
            --bundle-sha256) bundle_sha=$2 ;; --revision) revision=$2 ;; --python) python=$2 ;;
            --out) out=$2 ;; --app-repo) app=$2 ;; --application-revision) app_revision=$2 ;;
            *) refuse "unknown debian option: $1" ;;
        esac
        shift 2
    done
    [[ -d $evidence && -n $run && -n $out ]] || refuse "usage: debian --evidence DIR --run ID --archive-sha256 HEX --bundle-sha256 HEX --revision HEX --python /abs/python --out DIR [--app-repo DIR --application-revision HEX]"
    if ! hex64 "$archive_sha" || ! hex64 "$bundle_sha" || ! hex40 "$revision"; then
        refuse "archive, bundle and revision pins must be hex"
    fi
    [[ -z $app_revision ]] || hex40 "$app_revision" || refuse "application revision must be 40 hex characters"
    [[ -z $app || -d $app/ci ]] || refuse "application checkout must hold ci/: $app"
    independent_python "$python"
    [[ ! -e $out ]] || refuse "output directory already exists: $out"
    ACCEPT_RUN=$run ACCEPT_HOME=$out ACCEPT_PYTHON=$python ACCEPT_ARCHIVE_SHA256=$archive_sha
    export ACCEPT_RUN ACCEPT_HOME ACCEPT_PYTHON ACCEPT_ARCHIVE_SHA256
    mkdir -p -- "$out/cells" "$out/raw" "$out/inputs"
    printf 'run=%s\nrole=debian\nschema=%s\narchive_sha256=%s\nbundle_sha256=%s\nrevision=%s\nstarted_utc=%s\n' \
        "$run" "$ACCEPT_SCHEMA" "$archive_sha" "$bundle_sha" "$revision" "$(date -u +%FT%TZ)" > "$out/inputs/pins"
    "$python" - "$evidence" "$out" "$archive_sha" "$bundle_sha" "$revision" "$run" "$app" "$app_revision" <<'PY'
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tarfile
from pathlib import Path

evidence, out = Path(sys.argv[1]), Path(sys.argv[2])
archive_sha, bundle_sha, revision, run, app, app_revision = sys.argv[3:9]
raw = out / "raw"
captures = {}


def keep(name, source):
    """Copy one retained capture into the run home so the summary digests it."""
    if source is None or not source.exists():
        return None
    target = raw / name
    if source.is_dir():
        shutil.copytree(source, target)
    else:
        shutil.copy2(source, target)
    captures[name] = target
    return target


def cell(name, state, reason, *names):
    (out / "cells" / name).write_text(
        "cell=%s\nstate=%s\nreason=%s\narchive_sha256=%s\nrun=%s\n" % (name, state, reason, archive_sha, run)
        + "".join("capture=raw/%s\n" % item for item in names if item in captures))
    print("CELL|%s|%s|%s" % (name, state, reason))


def text_of(path):
    return path.read_text(errors="replace") if path is not None and path.is_file() else ""


def refuse(message):
    print("acceptance: " + message, file=sys.stderr)
    sys.exit(2)


tree = evidence / "a.evidence"
console = keep("console.txt", evidence / "console.txt")
identity = keep("identity", tree / "identity")
if identity is None or console is None:
    refuse("the evidence set needs console.txt and a.evidence/identity")
pins = dict(line.split("=", 1) for line in text_of(identity).splitlines() if "=" in line)
if (pins.get("revision"), pins.get("archive_sha256"), pins.get("bundle_sha256")) != (revision, archive_sha, bundle_sha):
    refuse("the build's identity differs from the pinned archive, bundle or revision")
runtime = keep("runtime.txt", tree / "runtime.txt")
fields = dict(line.split("=", 1) for line in text_of(runtime).splitlines() if "=" in line)
environment = {"build": fields.get("build", ""), "os": fields.get("PRETTY_NAME", "").strip('"'),
               "image": fields.get("image", ""), "container": fields.get("container", ""), "kernel": ""}
keep("verification.sha256", tree / "verification.sha256")
log = text_of(console)

trailer = re.search(r"^CPLX-ELF/1 end state=(\S+) reason=(\S+)", log, re.M)
if trailer is None:
    if "toolchain source: candidate" in log:
        cell("PA1:debian", "inconclusive", "no relocation trailer in the console", "console.txt")
elif trailer.group(1) != "completed" or "RSYNC_SHIM" in log or "rsync shim" in log:
    cell("PA1:debian", "fail", "relocation trailer %s/%s or a shim marker" % trailer.groups(), "console.txt")
elif "toolchain source: candidate" not in log:
    cell("PA1:debian", "fail", "the build did not select the candidate source", "console.txt")
else:
    cell("PA1:debian", "pass", "candidate relocated without a shim, trailer completed", "console.txt")

accept = keep("verify-wrapper-accept.debian.txt", tree / "verify-wrapper-accept.debian.txt")
verdict = text_of(accept)
if "OBJECTIVE MET for step 5 (accept)" in verdict:
    cell("PA2:debian", "pass", "wrapper first-call acceptance met", "verify-wrapper-accept.debian.txt")
elif "OBJECTIVE NOT MET" in verdict:
    cell("PA2:debian", "fail", "wrapper first-call acceptance not met", "verify-wrapper-accept.debian.txt")
elif accept is not None:
    cell("PA2:debian", "inconclusive", "wrapper acceptance could not answer on the agent", "verify-wrapper-accept.debian.txt")

sqlite = tree / "sqlite-candidate.debian.tar.gz"
if sqlite.is_file():
    keep("sqlite-candidate.debian.tar.gz", sqlite)
    try:
        with tarfile.open(sqlite, "r:gz") as bundle:
            role = json.load(bundle.extractfile("evidence/role.json"))
            operator = json.load(bundle.extractfile("evidence/operator.json"))
        good = (role["role"] == "debian" and role["sha256"] == archive_sha and role["preservation"] == "passed"
                and operator["outcome"] == "passed" and operator["database"] == "passed")
    except (KeyError, TypeError, ValueError, tarfile.TarError, OSError):
        good = False
    cell("PA3:debian", "pass" if good else "fail", "SQLite acceptance role over the pinned archive" if good else
         "SQLite acceptance role did not pass over the pinned archive", "sqlite-candidate.debian.tar.gz")

if re.search(r"^toolchain python ELF: .*\n(?:.*\n)*?git version \d", log, re.M):
    cell("PA4:debian", "pass", "toolchain git answered --version after relocation", "console.txt")
elif "toolchain python ELF:" in log:
    cell("PA4:debian", "fail", "toolchain git printed no version after relocation", "console.txt")

closure = keep("abi-closure.txt", tree / "abi-closure.txt")
abi = keep("abi", tree / "abi")
abi_pass = re.search(r"^ABI PASS: subjects=(\d+) dynamic=(\d+) flags=0", log, re.M)
abi_fail = re.search(r"^ABI INCONCLUSIVE/FAIL: (.*)$", log, re.M)
if abi_pass and closure is not None:
    cell("PA5:debian", "pass", "closure checker and whole-scope ABI listing accepted", "abi-closure.txt", "abi")
    cell("PA7:debian", "pass", "loader listing over %s subjects, %s dynamic, zero flags" % abi_pass.groups(), "abi", "console.txt")
elif abi_fail:
    reason = abi_fail.group(1)
    state = "inconclusive" if re.search(r"trace|unavailable|empty|no dynamic", reason) else "fail"
    cell("PA5:debian", state, reason, "abi-closure.txt", "abi", "console.txt")
    cell("PA7:debian", state, reason, "abi", "console.txt")
elif closure is not None:
    cell("PA5:debian", "inconclusive", "closure output retained without an ABI verdict", "abi-closure.txt")

imports = text_of(abi / "imports.txt") if abi else ""
if "wheels load" in imports and re.search(r"^venv_base=", log, re.M) and "uv sync --locked" in log:
    cell("PA6:debian", "pass", "uv sync --locked then pymupdf and pikepdf imported from the candidate venv", "abi", "console.txt")
elif abi is not None:
    cell("PA6:debian", "fail", "heavy wheel imports or the locked sync are not evidenced", "abi", "console.txt")

traces = list(abi.glob("ld-debug.*")) if abi else []
if abi_pass and len(traces) == 1 and traces[0].stat().st_size > 0:
    cell("PA8:debian", "pass", "one direct-venv LD_DEBUG trace retained with zero host flags", "abi")
elif abi is not None:
    unusable = len(traces) != 1 or traces[0].stat().st_size == 0
    unanswered = abi_fail is not None and re.search(r"trace|unavailable|empty|no dynamic", abi_fail.group(1)) is not None
    cell("PA8:debian", "inconclusive" if unusable or unanswered else "fail",
         "%d direct-venv trace(s) retained; %s" % (len(traces), abi_fail.group(1) if abi_fail else "no ABI verdict"), "abi")

walks = sorted(tree.glob("test-walk.*"))
summary = re.search(r"^Full acceptance PASS: collected=(\d+) executed=(\d+) setup_skipped=(\d+); coverage=100%", log, re.M)
if walks:
    walk = keep("test-walk", walks[-1])
    report, coverage = walk / "tests.json", walk / "coverage.xml"
    if not (report.is_file() and coverage.is_file()):
        cell("PA9:debian", "inconclusive", "test walk retained without tests.json and coverage.xml", "test-walk")
    elif summary is None:
        cell("PA9:debian", "fail", "the full acceptance walk did not report PASS", "test-walk", "console.txt")
    elif app:
        checked = subprocess.run([sys.executable, str(Path(app) / "ci/tools_test_evidence.py"), str(report), str(coverage)],
                                 capture_output=True, text=True, check=False)
        (raw / "test-evidence-check.txt").write_text(checked.stdout + checked.stderr)
        captures["test-evidence-check.txt"] = raw / "test-evidence-check.txt"
        cell("PA9:debian", "pass" if checked.returncode == 0 else "fail",
             "full selection, SQLite-guarded suites and 100%% coverage re-validated" if checked.returncode == 0
             else "independent test evidence check refused", "test-walk", "console.txt", "test-evidence-check.txt")
    else:
        cell("PA9:debian", "inconclusive", "no application checkout to re-validate the test evidence", "test-walk", "console.txt")

consumers = {"lock_sha256": "", "wheels": {}, "venv_base": ""}
wheels = tree / "wheels.tar.gz"
if wheels.is_file():
    keep("wheels.tar.gz", wheels)
    with tarfile.open(wheels, "r:gz") as bundle:
        names = bundle.getnames()
        lock = bundle.extractfile("uv.lock") if "uv.lock" in names else None
        inventory = bundle.extractfile("inventory.json") if "inventory.json" in names else None
        if lock is not None:
            consumers["lock_sha256"] = hashlib.sha256(lock.read()).hexdigest()
        if inventory is not None:
            for wheel in json.load(inventory).get("wheels", []):
                consumers["wheels"][wheel["filename"]] = wheel["sha256"]
base = re.search(r"^venv_base=(\S+)", log, re.M)
consumers["venv_base"] = base.group(1) if base else ""
if app and app_revision and consumers["lock_sha256"]:
    shown = subprocess.run(["git", "-C", app, "show", app_revision + ":uv.lock"], capture_output=True, check=False)
    if shown.returncode != 0 or hashlib.sha256(shown.stdout).hexdigest() != consumers["lock_sha256"]:
        refuse("the build's uv.lock differs from the application revision " + app_revision)
(out / "inputs" / "consumers.json").write_text(json.dumps(consumers, indent=2, sort_keys=True) + "\n")
(out / "raw" / "environment.txt").write_text("".join("%s=%s\n" % item for item in environment.items()))
PY
    summarize_main --home "$out" --python "$python" --role debian --out "$out/results.json"
}

# ------------------------------------------------------------------------- d10 ---
# One reading of the inherited D10 policy over the archive tree and, when the
# agent's wheels are materialized, their exact ELF consumers. The first reading
# may demand ONE rebuild (exit 3); the second reading runs with --previous and
# must settle on the same generation; a third reading is refused.
d10_main() {
    local out="" python="" root="" reader="" previous="" number=1 code=0 selected generation
    local -a args=()
    while (($#)); do
        (($# >= 2)) || refuse "d10 options come in pairs"
        case $1 in
            --out) out=$2 ;; --python) python=$2 ;; --reader) reader=$2 ;; --root) root=$2 ;;
            --candidate|--wheel-root|--wheel-lock|--wheel-python) args+=("$1" "$2") ;;
            *) refuse "unknown d10 option: $1" ;;
        esac
        shift 2
    done
    [[ -n $out && -d $root && -f $reader ]] || refuse "usage: d10 --out DIR --python /abs/python --reader closure_d10.sh --root DIR --candidate GEN=DIR... [--wheel-root DIR --wheel-lock FILE --wheel-python /abs/python]"
    independent_python "$python"
    mkdir -p -- "$out"
    [[ ! -f $out/reading-2.json ]] || refuse "two readings exist already and there is no third iteration"
    if [[ -f $out/reading-1.json ]]; then
        number=2
        previous=$("$python" -c 'import json,sys; print(json.load(open(sys.argv[1]))["selected_generation"])' "$out/reading-1.json")
        [[ $previous =~ ^1[12]$ ]] || refuse "the first reading selected no generation, so no re-reading is due"
        args+=(--previous "$previous")
    fi
    bash "$reader" --root "$root" "${args[@]}" > "$out/reading-$number.log" 2>&1 || code=$?
    "$python" - "$out/reading-$number.log" "$out/reading-$number.json" "$number" "$code" <<'PY'
import json
import re
import sys
from pathlib import Path
log, out, number, code = Path(sys.argv[1]).read_text(errors="replace"), Path(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
reading = {"reading": number, "exit": code, "generation": None, "selected_generation": None,
           "consumers": {}, "required_nodes": [], "providers": {}, "settled": None}
generation = re.search(r"^  reading generation  (\S+)", log, re.M)
if generation and generation.group(1).isdigit():
    reading["generation"] = int(generation.group(1))
policy = re.search(r"^D10 POLICY: (\S+)", log, re.M)
if policy and policy.group(1).isdigit():
    reading["selected_generation"] = int(policy.group(1))
for match in re.finditer(r"^  consumer wheel:(\S+) wheel-sha256=([0-9a-f]{64}) installed=\S+ \S+ sha256=", log, re.M):
    reading["consumers"][match.group(1)] = match.group(2)
reading["required_nodes"] = sorted(set(re.findall(r"^  require (\S+)", log, re.M)))
defines = set(re.findall(r"^  defines (\S+)", log, re.M))
for gen, provider, digest in re.findall(r"^  candidate (\d+) (\S+) (\S+)", log, re.M):
    entry = reading["providers"].setdefault(gen, {"identity": "", "satisfies": None})
    entry["identity"] = (entry["identity"] + ";" if entry["identity"] else "") + provider + "=" + digest
for gen, entry in reading["providers"].items():
    unread = "unread" in entry["identity"]
    entry["satisfies"] = None if unread or not reading["required_nodes"] else all(
        gen + "|" + node in defines for node in reading["required_nodes"])
if "D10 CONVERGENCE: SETTLED" in log:
    reading["settled"] = True
elif "D10 CONVERGENCE: NON-CONVERGENT" in log:
    reading["settled"] = False
out.write_text(json.dumps(reading, indent=2, sort_keys=True) + "\n")
PY
    generation=$("$python" -c 'import json,sys; print(json.load(open(sys.argv[1]))["generation"])' "$out/reading-$number.json")
    selected=$("$python" -c 'import json,sys; print(json.load(open(sys.argv[1]))["selected_generation"])' "$out/reading-$number.json")
    grep -E '^D10 (POLICY|CONVERGENCE|elapsed)' "$out/reading-$number.log" || true
    printf 'D10 READING %s: generation=%s selected=%s exit=%s\n' "$number" "$generation" "$selected" "$code"
    if ((code == 5)); then printf 'D10 INCONCLUSIVE\n'; return 5; fi
    if ((code != 0)); then printf 'D10 REFUSED\n'; return 1; fi
    if ((number == 1)) && [[ $selected != "$generation" ]]; then
        printf 'D10 REBUILD REQUIRED: rebuild with %s and read again\n' "$selected"
        return 3
    fi
    printf 'D10 CONVERGED at %s\n' "$selected"
}

# ------------------------------------------------------------------- summarize ---
# The verdict of a run home. Every required cell of the role must be present,
# bound to the pinned archive and run, and passing; captures are digested from
# the raw files the cells name. Paths in the record are relative to the home.
summarize_main() {
    local home="" python="" role="" out=""
    while (($#)); do
        (($# >= 2)) || refuse "summarize options come in pairs"
        case $1 in
            --home) home=$2 ;; --python) python=$2 ;; --role) role=$2 ;; --out) out=$2 ;;
            *) refuse "unknown summarize option: $1" ;;
        esac
        shift 2
    done
    [[ -d $home/cells && -f $home/inputs/pins && $role =~ ^(rhel|debian)$ && -n $out ]] || refuse "usage: summarize --home DIR --python /abs/python --role rhel|debian --out FILE"
    independent_python "$python"
    local required=$ACCEPT_RHEL_CELLS
    [[ $role == rhel ]] || required=$ACCEPT_DEBIAN_CELLS
    "$python" - "$home" "$role" "$out" "$ACCEPT_SCHEMA" "$required" "$HOME" <<'PY'
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

home, role, out, schema, required, account = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3]), sys.argv[4], sys.argv[5].split(), sys.argv[6]
pins = dict(line.split("=", 1) for line in (home / "inputs/pins").read_text().splitlines() if "=" in line)
if pins.get("role") != role or pins.get("schema") != schema:
    print("acceptance: the run home was produced for another role or schema", file=sys.stderr)
    sys.exit(2)
transfer = home / "inputs/transfer.sha256"
if transfer.is_file() and transfer.read_text().strip() != pins["archive_sha256"]:
    print("acceptance: the transferred archive digest differs from the pin", file=sys.stderr)
    sys.exit(2)


def sanitize(value):
    return value.replace(str(home), "<run-home>").replace(account, "<owned-home>")


def digest(path):
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


cells, captures = {}, {}
for path in sorted((home / "cells").iterdir()):
    fields = {}
    names = []
    for line in path.read_text().splitlines():
        key, _, value = line.partition("=")
        if key == "capture":
            names.append(value)
        else:
            fields[key] = value
    if fields.get("archive_sha256") != pins["archive_sha256"] or fields.get("run") != pins["run"] or fields.get("cell") != path.name:
        print("acceptance: cell %s is bound to another archive, run or name" % path.name, file=sys.stderr)
        sys.exit(2)
    if fields.get("state") not in ("pass", "fail", "inconclusive"):
        print("acceptance: cell %s carries an unknown state" % path.name, file=sys.stderr)
        sys.exit(2)
    kept = []
    for name in names:
        target = home / name
        if not target.exists():
            continue
        files = sorted(item for item in target.rglob("*") if item.is_file()) if target.is_dir() else [target]
        for item in files:
            relative = item.relative_to(home).as_posix()
            captures.setdefault(relative, {"sha256": digest(item), "size": item.stat().st_size})
            kept.append(relative)
    if fields["state"] == "pass" and not kept:
        fields["state"], fields["reason"] = "inconclusive", "pass recorded without any retained capture"
    cells[path.name] = {"state": fields["state"], "reason": sanitize(fields.get("reason", "")), "captures": kept}
missing = [name for name in required if name not in cells]
for name in missing:
    cells[name] = {"state": "pending", "reason": "not executed in this run", "captures": []}
states = {name: cells[name]["state"] for name in required}
if any(state == "fail" for state in states.values()):
    verdict, code = "fail", 1
elif all(state == "pass" for state in states.values()):
    verdict, code = "pass", 0
else:
    verdict, code = "incomplete", 5
environment = {}
for line in (home / "raw/environment.txt").read_text().splitlines() if (home / "raw/environment.txt").is_file() else []:
    key, _, value = line.partition("=")
    environment[key] = sanitize(value.strip('"'))
runtime = {}
for name in ("raw/runtime.txt", "raw/build-provider.txt"):
    if (home / name).is_file():
        for line in (home / name).read_text().splitlines():
            key, _, value = line.partition("=")
            runtime[key] = value
consumers = json.loads((home / "inputs/consumers.json").read_text()) if (home / "inputs/consumers.json").is_file() else {}
record = {"schema": schema, "role": role, "run": pins["run"], "verdict": verdict,
          "recorded_utc": datetime.now(timezone.utc).isoformat(),
          "pins": {key: pins[key] for key in ("archive", "archive_sha256", "bundle_sha256", "revision", "pdfs", "pdfs_sha256",
                                              "deploy_script_sha256", "previous_installer_sha256") if key in pins},
          "transfer_sha256": transfer.read_text().strip() if transfer.is_file() else "",
          "environment": environment, "runtime": runtime, "consumers": consumers,
          "elapsed_seconds": int(pins.get("elapsed_seconds", "0") or 0),
          "required": required, "missing": missing, "cells": cells, "captures": captures}
out.write_text(json.dumps(record, indent=2, sort_keys=True) + "\n")
print("SUMMARY|%s|%s|%s|%d cells|%d missing" % (role, pins["run"], verdict, len(cells), len(missing)))
sys.exit(code)
PY
}

# ------------------------------------------------------------------------ main ---
main() {
    local command=${1:-}
    shift || true
    case $command in
        rhel) rhel_main "$@" ;;
        debian) debian_main "$@" ;;
        d10) d10_main "$@" ;;
        summarize) summarize_main "$@" ;;
        probe) probe_main "$@" ;;
        bundle-check) (($# == 4)) || refuse "usage: bundle-check BUNDLE SHA256 REVISION DEST"; bundle_check "$@" ;;
        *) sed -n '2,29p' "${BASH_SOURCE[0]}" >&2; exit 2 ;;
    esac
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
