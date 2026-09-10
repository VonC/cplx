#!/bin/bash
#
# closure_verify.sh -- the verification driver of the v0.27.0 runtime-closure
# effort, created by Step 6. It runs on the DEBIAN JOB, from the pipeline
# workspace and never from inside the candidate archive, and it is the first
# actor holding BOTH sides of the comparison Design Area 1 defines.
#
# WHAT IT DOES, IN THE ORDER THAT MATTERS:
#
#   0. require the pipeline delivery, BEFORE the archive is opened. A job that
#      cannot obtain the authoritative copies refuses and never falls back to a
#      copy inside the candidate: reading the archive must come second, which is
#      the whole bootstrap argument.
#   1. compute the archive identity, the SHA-256 of the candidate file's bytes.
#   2. derive the PRE-INSTALL observation from the archive's table of contents.
#   3. install through `install_pkg.sh` as any operator would, with no argument
#      this file invented, then derive the INSTALLED observation and compare.
#   4. compare the archive's embedded checker copies against the authoritative
#      ones byte for byte, and REPORT that as a payload property.
#   5. run the static checker on the installed tree, and the live observer.
#   6. emit ONE evidence artifact, keyed by the identity from step 1.
#
# ONE DERIVATION, TWO SIDES, AND NOTHING REIMPLEMENTED. Both observations go
# through `closure_scope_declared`, `closure_scope_observed` and
# `closure_scope_classify` from the authoritative `closure_check.sh`, and the
# observed loader scope on either side is the INSTALLER'S OWN `build_elf_rpath`,
# called rather than copied. The archive side gets a tree by recreating the
# archive's DIRECTORY SKELETON from its table of contents: empty directories, no
# file extracted, one pass over the index. `build_elf_rpath` only tests whether a
# directory exists, so a skeleton answers it exactly as the unpacked tree would.
#
# THE EVIDENCE RECORD AND ITS STORE DO NOT LIVE HERE, AND THE REVIEW IS WHY. The
# grammar table was written here because the grammar module had no room, which
# made publication source the DRIVER to obtain a reader; round 2 gave the record
# to `closure_report.sh`, the module that owns how a run's outcome is rendered,
# and round 3 gave it the STORE for the same reason: the reader, the conflict
# lookup and both consumers were already there and only the writer was here. This
# file calls `closure_evidence_emit` and reads its own document back through
# `closure_evidence_parse`; `closure_publish.sh` takes that reader alone. The
# shared-reader rule protects that ONE reader exists; the topology decides which
# module holds it.
#
# It is EXECUTED by the Debian job and never sourced by another shipped script,
# which the main boundary at the end still exists for: the harness drives one
# refusal at a time against it without running a verification.
# EVERY LITERAL IN A TYPED LINE IS AN ARGUMENT and never text after a bar in a
# format string, because the harness reads a bar as a command-position introducer
# and would report such a word as an undeclared host dependency.

set -u

CLOSURE_VERIFY_DIR="${BASH_SOURCE[0]%/*}"
if [ "$CLOSURE_VERIFY_DIR" = "${BASH_SOURCE[0]}" ]; then
    CLOSURE_VERIFY_DIR="."
fi
# shellcheck source=/dev/null
if ! declare -F closure_config_parse >/dev/null 2>&1; then
    if [ -f "$CLOSURE_VERIFY_DIR/closure_config.sh" ]; then
        source "$CLOSURE_VERIFY_DIR/closure_config.sh"
    fi
fi
# The evidence contract, taken from the module that owns it. This file WRITES the
# document and reads it back through the same parser publication uses, which is
# what "one reader" means: the emitter has no private interpretation of its own
# output. The guard is the configuration module's, for the same reason.
# shellcheck source=/dev/null
if ! declare -F closure_evidence_parse >/dev/null 2>&1; then
    if [ -f "$CLOSURE_VERIFY_DIR/closure_report.sh" ]; then
        source "$CLOSURE_VERIFY_DIR/closure_report.sh"
    fi
fi

CLOSURE_VERIFY_USAGE="Usage: closure_verify.sh --archive PATH --prefix DIR --results DIR --tools DIR --target NAME [--process NAME] [--proc DIR]"

# The authoritative set the pipeline must have placed: the delivery script's list
# read from the other end, quoted element by element for the same reason the typed
# lines below carry no bare literal.
CLOSURE_VERIFY_DELIVERED=(
    'closure_check.sh' 'closure_config.sh' 'closure_elf.sh' 'closure_report.sh'
    'closure_rules.sh' 'closure_observe_live.sh' 'install_pkg.sh'
)

# The five modules the archive carries under tools/bin as PAYLOAD, compared and
# never executed: Q12 is categorical, and equality makes two files equivalent
# without making a candidate-supplied script an independent judge.
CLOSURE_VERIFY_PAYLOAD=(
    'closure_check.sh' 'closure_config.sh' 'closure_elf.sh' 'closure_report.sh'
    'closure_rules.sh'
)

# ---------------------------------------------------------------- the refusals ---
# THE VERIFICATION PATH'S OWN VOICE. The evidence STORE prints the same prefix
# from the module that owns the record, so an operator reads one kind of refusal
# whichever half produced it.
closure_verify_refuse() {
    printf 'VERIFICATION REFUSED: %s\n' "$1" >&2
}

# ------------------------------------------------------------- the observations ---
# THE DELIVERY, REQUIRED BEFORE THE ARCHIVE IS OPENED. It is the first thing the
# driver does and it names what is missing. There is deliberately no fallback: a
# copy inside the candidate is payload under examination, never evidence.
closure_verify_delivery() {
    local tools="$1" name="" missing=""
    for name in "${CLOSURE_VERIFY_DELIVERED[@]}"; do
        if [ ! -r "$tools/$name" ]; then missing="${missing:+$missing }$name"; fi
    done
    if [ -n "$missing" ]; then
        closure_verify_refuse "the pipeline delivered no $missing in $tools, and no copy inside the candidate may stand in"
        return 1
    fi
    printf 'DELIVERY|%s|%s\n' PRESENT "$tools"
    return 0
}

# The checker, sourced only when the driver is going to observe: a publication
# that took the evidence reader alone must not acquire the four invariants.
closure_verify_load() {
    local tools="$1"
    # shellcheck source=/dev/null
    source "$tools/closure_check.sh" || return 1
    declare -F closure_scope_declared >/dev/null 2>&1 || return 1
    return 0
}

# THE ARCHIVE THAT WOULD WIN THE INSTALLER'S OWN SELECTION, if any. The installer
# keeps the newest `<target>.*.tar.gz` by modification time over the prefix, its
# package directory, HOME and HOME/pkgs; this names the first one strictly newer
# than the copy this run placed. It STEERS NOTHING: the answer is a refusal with
# the competitor's path in it, so the driver never installs a candidate it cannot
# claim the installed tree came from.
closure_verify_competing() {
    local target="$1" prefix="$2" mine="$3"
    local home="${HOME:-$prefix}" line=""
    while IFS= read -r line; do
        if [ -n "$line" ]; then printf '%s' "$line"; return 0; fi
    done < <(find "$prefix" "$prefix/pkgs" "$home" "$home/pkgs" -maxdepth 1 -type f \
        -name "$target.*.tar.gz" -newer "$mine" -print 2>/dev/null)
    return 0
}

# The identity, over the candidate FILE and never over an unpacked tree. It does
# not exist until the tar is closed, which is why the evidence carrying it is
# external to the archive.
closure_verify_identity() {
    local archive="$1" out=""
    out=$(sha256sum -- "$archive" 2>/dev/null) || return 1
    if [ -z "$out" ]; then return 1; fi
    printf '%s' "${out%% *}"
}

# DOES THIS LINK STAY INSIDE THE ARCHIVE, resolved from where the link itself
# sits. Round 2 of the step 6 review found the earlier test rejecting every target
# holding `..`, which drops the ordinary spelling `../python/python-3.13.9` of an
# alias whose equivalent `python-3.13.9` was accepted: the same directory, two
# spellings, two verdicts, and the installed tree resolves both. CONTAINMENT is
# what matters and not the presence of a parent component, so the link's own
# depth is counted and the target walked from there. A step above the archive
# root refuses, and an absolute target is outside by definition.
# The link's own directory carries no `..`, the entry test having refused one, so
# joining it to the target and walking once answers both halves.
closure_verify_contained() {
    local entry="$1" target="$2" part="" depth=0 dir="" parts=()
    case "$target" in /*) return 1 ;; esac
    dir="${entry%/*}"
    if [ "$dir" = "$entry" ]; then dir=""; fi
    IFS='/' read -r -a parts <<< "$dir/$target"
    for part in "${parts[@]}"; do
        case "$part" in
            ''|'.') ;;
            '..') depth=$((depth - 1)); if [ "$depth" -lt 0 ]; then return 1; fi ;;
            *) depth=$((depth + 1)) ;;
        esac
    done
    return 0
}

# THE ARCHIVE'S DIRECTORY SKELETON, from its table of contents and nothing else:
# empty directories, no file extracted, one pass over the index, so the archive
# side can be measured by the SAME derivations the installed side uses. An entry
# ending in a slash is a directory and any other contributes its parent chain, so
# an archive written without directory entries yields the same skeleton.
closure_verify_skeleton() {
    local archive="$1" into="$2" entry="" dir="" mode="" target=""
    local field1="" field2="" field3="" field4=""
    if ! tar -tzf "$archive" > "$into/toc.txt" 2>/dev/null; then
        closure_verify_refuse "the candidate archive $archive could not be read for its table of contents"
        return 1
    fi
    if [ ! -s "$into/toc.txt" ]; then
        closure_verify_refuse "the candidate archive $archive lists no entry"
        return 1
    fi
    mkdir -p -- "$into/tree" || return 1
    while IFS= read -r entry; do
        entry="${entry#./}"
        case "$entry" in
            */) dir="${entry%/}" ;;
            *) dir="${entry%/*}"; if [ "$dir" = "$entry" ]; then dir=""; fi ;;
        esac
        case "$dir" in
            ''|/*|*..*) continue ;;
        esac
        mkdir -p -- "$into/tree/$dir" || return 1
    done < "$into/toc.txt"

    # THE DIRECTORY ALIASES, WHICH THE FIRST PASS CANNOT CARRY. A symlinked
    # directory such as `tools/python/current` is listed by NAME with no trailing
    # slash, so the loop above contributes its parent and drops the alias itself.
    # `build_elf_rpath` then finds `current/lib` absent on the archive side and
    # present under the installed tree, and a supported archive whose policy
    # DECLARES that alias is reported DIVERGENT for a difference that is not
    # there. The link records live in the verbose index alone, which is why this
    # is a second pass over the index and still no unpacking.
    if ! tar -tvzf "$archive" > "$into/links.txt" 2>/dev/null; then
        closure_verify_refuse "the candidate archive $archive could not be read for its link records"
        return 1
    fi
    # The four fields between the mode and the name are named and never read, for
    # the reason the live observer names its five: only one variable per leading
    # field leaves the name whole.
    # shellcheck disable=SC2034  # read to consume the record shape, not for use
    while read -r mode field1 field2 field3 field4 entry; do
        case "$mode" in 'l'*) ;; *) continue ;; esac
        target="${entry#* -> }"
        entry="${entry%% -> *}"
        entry="${entry#./}"
        case "$entry" in ''|/*|*..*) continue ;; esac
        if [ -z "$target" ] || ! closure_verify_contained "$entry" "$target"; then
            continue
        fi
        dir="${entry%/*}"
        if [ "$dir" != "$entry" ]; then mkdir -p -- "$into/tree/$dir" || return 1; fi
        # A real entry of the same name WINS: an archive carrying both is
        # describing a directory, and the skeleton must not replace it.
        if [ ! -e "$into/tree/$entry" ] && [ ! -L "$into/tree/$entry" ]; then
            ln -s -- "$target" "$into/tree/$entry" 2>/dev/null || true
        fi
    done < "$into/links.txt"
    return 0
}

# ONE SIDE OF THE COMPARISON, and the same function answers both: one presence
# line per declared candidate directory and one unexpected line per observed
# loader directory the declaration does not carry. Nothing here re-derives a scope.
closure_verify_side() {
    local prefix="$1" installer="$2"
    shift 2
    local declared="" observed="" results="" line="" kind="" path=""

    declared=$(closure_scope_declared "$prefix" "$@")
    if ! closure_scope_observed "$prefix" "$installer"; then
        closure_verify_refuse "the loader scope under $prefix could not be observed: $CLOSURE_OBSERVED_REASON"
        return 1
    fi
    observed=$(closure_scope_observed_lines "$CLOSURE_OBSERVED_RPATH")
    results=$(closure_scope_classify "$prefix" "$declared" "$observed" "$@")
    while IFS= read -r line; do
        if [ -z "$line" ]; then continue; fi
        kind="${line%%|*}"
        path="${line#*|*|}"
        path="${path%%|*}"
        path="${path#"$prefix"/}"
        case "$kind" in
            'PRESENT') printf 'presence|%s|%s\n' "$path" present ;;
            'ABSENT') printf 'presence|%s|%s\n' "$path" absent ;;
            'UNEXPECTED') printf 'unexpected|%s\n' "$path" ;;
        esac
    done <<< "$results"
    return 0
}

# THE PAYLOAD COMPARISON, WHICH AUTHORISES NOTHING. The embedded copies are
# extracted to a scratch directory, digested against the authoritative ones, and
# the result REPORTED. Q12 is categorical: an embedded copy is never executed to
# produce evidence, identical included, because equality makes two files
# equivalent without making a candidate-supplied script an independent judge.
closure_verify_payload() {
    local archive="$1" tools="$2" into="$3" name="" mine="" theirs="" differs=0

    mkdir -p -- "$into" || return 1
    for name in "${CLOSURE_VERIFY_PAYLOAD[@]}"; do
        if ! tar -xzf "$archive" -C "$into" "tools/bin/$name" 2>/dev/null; then
            printf 'PAYLOAD|%s|%s\n' "$name" absent
            differs=$((differs + 1))
            continue
        fi
        mine=$(sha256sum -- "$into/tools/bin/$name" 2>/dev/null); mine="${mine%% *}"
        theirs=$(sha256sum -- "$tools/$name" 2>/dev/null); theirs="${theirs%% *}"
        if [ -n "$mine" ] && [ "$mine" = "$theirs" ]; then
            printf 'PAYLOAD|%s|%s\n' "$name" identical
        else
            printf 'PAYLOAD|%s|%s\n' "$name" differs
            differs=$((differs + 1))
        fi
    done
    printf 'PAYLOAD|%s|%s\n' SUMMARY "$differs"
    return 0
}

# One side's presence lines, in order, with the type token stripped. Both the
# document builder and the verdict below read a side through this, so neither
# reads a shape the other does not.
closure_verify_presence() {
    local line=""
    while IFS= read -r line; do
        case "$line" in 'presence|'*) printf '%s\n' "${line#presence|}" ;; esac
    done <<< "$1"
}

# THE VERDICT THIS RUN'S OWN RECORDS DERIVE, so an emitter cannot write a document
# its own parser refuses. Both sides come from one derivation over one declaration
# and are the SAME SEQUENCE when nothing diverged, so comparing them whole is
# stricter than pairwise: a missing, extra or reordered entry fails it too.
closure_verify_verdict() {
    local pre="$1" post="$2"
    case "$pre$post" in *'unexpected|'*) printf 'DIVERGENT'; return 0 ;; esac
    if [ "$(closure_verify_presence "$pre")" = "$(closure_verify_presence "$post")" ]; then
        printf 'PASS'
    else
        printf 'DIVERGENT'
    fi
    return 0
}

# The document, in the record order the grammar fixes, read back by the shared
# reader before anything is promoted: a run whose document its own contract
# refuses stops here rather than storing it.
closure_verify_document() {
    local identity="$1" cfgdigest="$2" pre="$3" post="$4" line=""
    printf '%s\n' "$CLOSURE_EVIDENCE_VERSION"
    printf 'archive|%s\n' "$identity"
    printf 'config|%s\n' "$cfgdigest"
    while IFS= read -r line; do
        printf 'pre|%s\n' "$line"
    done <<< "$(closure_verify_presence "$pre")"
    while IFS= read -r line; do
        printf 'post|%s\n' "$line"
    done <<< "$(closure_verify_presence "$post")"
    printf 'verdict|%s\n' "$(closure_verify_verdict "$pre" "$post")"
    while IFS= read -r line; do
        case "$line" in
            'unexpected|'*) printf 'unexpected|%s|%s\n' pre "${line#unexpected|}" ;;
        esac
    done <<< "$pre"
    while IFS= read -r line; do
        case "$line" in
            'unexpected|'*) printf 'unexpected|%s|%s\n' post "${line#unexpected|}" ;;
        esac
    done <<< "$post"
}

# The policy the observations are taken under, read from the candidate. The agent
# has no cplx, so it establishes INTERNAL CONSISTENCY and says so; only
# publication resolves the authoritative document and catches a paired edit.
closure_verify_bundle() {
    local archive="$1" work="$2"
    mkdir -p -- "$work/bundle" || return 1
    if ! tar -xzf "$archive" -C "$work/bundle" --strip-components=2 \
        "$CLOSURE_BUNDLE_DIR/$CLOSURE_CONFIG_BASENAME" \
        "$CLOSURE_BUNDLE_DIR/$CLOSURE_ENVELOPE_BASENAME" 2>/dev/null; then
        closure_verify_refuse "the candidate archive carries no configuration bundle at $CLOSURE_BUNDLE_DIR"
        return 1
    fi
    if ! closure_envelope_check "$work/bundle/$CLOSURE_CONFIG_BASENAME" \
        "$work/bundle/$CLOSURE_ENVELOPE_BASENAME"; then
        closure_verify_refuse "the candidate bundle is not internally consistent"
        return 1
    fi
    if ! closure_config_parse "$work/bundle/$CLOSURE_CONFIG_BASENAME" >/dev/null; then
        closure_verify_refuse "the candidate configuration could not be parsed"
        return 1
    fi
    return 0
}

# ------------------------------------------------------------------ the driver ---
closure_verify_main() {
    local archive="" prefix="" results="" tools="" target="" process="" proc="/proc"
    local work="" identity="" cfgdigest="" doc="" line="" rc=0 verdict=""
    local specs=() pre="" post="" candidate="" marker="" competing=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --archive) archive="${2:-}"; shift 2 || return 2 ;;
            --prefix) prefix="${2:-}"; shift 2 || return 2 ;;
            --results) results="${2:-}"; shift 2 || return 2 ;;
            --tools) tools="${2:-}"; shift 2 || return 2 ;;
            --target) target="${2:-}"; shift 2 || return 2 ;;
            --process) process="${2:-}"; shift 2 || return 2 ;;
            --proc) proc="${2:-}"; shift 2 || return 2 ;;
            *) closure_verify_refuse "$CLOSURE_VERIFY_USAGE"; return 2 ;;
        esac
    done
    if [ -z "$archive" ] || [ -z "$prefix" ] || [ -z "$results" ] \
       || [ -z "$tools" ] || [ -z "$target" ]; then
        closure_verify_refuse "$CLOSURE_VERIFY_USAGE"
        return 2
    fi
    prefix="${prefix%/}"

    # STEP 0, AND IT IS FIRST FOR THE REASON THE WHOLE TOPOLOGY RESTS ON.
    closure_verify_delivery "$tools" || return 1
    if ! closure_verify_load "$tools"; then
        closure_verify_refuse "the delivered checker in $tools could not be loaded"
        return 1
    fi
    if [ ! -r "$archive" ]; then
        closure_verify_refuse "the candidate archive $archive cannot be read"
        return 1
    fi
    work=$(mktemp -d) || {
        closure_verify_refuse "no writable work directory"
        return 1
    }
    identity=$(closure_verify_identity "$archive")
    if [ -z "$identity" ]; then
        closure_verify_refuse "the candidate archive $archive could not be digested"
        rm -rf -- "$work"
        return 1
    fi
    printf 'ARCHIVE|%s|%s\n' "$archive" "$identity"

    if ! closure_verify_bundle "$archive" "$work"; then
        rm -rf -- "$work"
        return 1
    fi
    cfgdigest=$(closure_config_digest "$work/bundle/$CLOSURE_CONFIG_BASENAME")
    while IFS= read -r line; do
        if [ -n "$line" ]; then specs+=("$line"); fi
    done < <(closure_config_root_specs)

    # STEPS 2 AND 3: the two observations, with the install between them.
    if ! closure_verify_skeleton "$archive" "$work"; then
        rm -rf -- "$work"
        return 1
    fi
    pre=$(closure_verify_side "$work/tree" "$tools/install_pkg.sh" "${specs[@]}") || {
        rm -rf -- "$work"
        return 1
    }
    mkdir -p -- "$prefix/pkgs" || return 1
    candidate="$prefix/pkgs/$target.verify-${identity:0:12}.tar.gz"
    marker="$prefix/pkgs/$target.verify-${identity:0:12}.done"
    if ! cp -- "$archive" "$candidate"; then
        closure_verify_refuse "the candidate could not be placed where the installer discovers it"
        rm -rf -- "$work"
        return 1
    fi
    # THE INSTALLER IS NOT ASKED FOR A FILE, IT IS ASKED FOR A TARGET, and round 1
    # of the step 6 review found what that costs. It discovers `<target>.*.tar.gz`
    # across the prefix, its package directory, HOME and HOME/pkgs and keeps the
    # NEWEST by modification time, so a competing archive dated after this copy is
    # installed instead and the post-install observation then belongs to bytes
    # this run never digested. Its interface is frozen and no argument selects a
    # file, so selection is CHECKED on both sides of the call rather than steered:
    # a competitor newer than the candidate refuses here, and the marker the
    # installer writes for the archive it actually processed is required below.
    competing=$(closure_verify_competing "$target" "$prefix" "$candidate")
    if [ -n "$competing" ]; then
        closure_verify_refuse "the installer would discover $competing, which is newer than the candidate copied to $candidate"
        rm -rf -- "$work"
        return 1
    fi
    # A RERUN MUST REALLY INSTALL, AND THE REMOVAL IS CHECKED. The installer skips
    # an archive whose done marker exists, exiting 0 without unpacking, and the
    # observation after that skip describes the tree an earlier run left. Round 2
    # of the step 6 review found what an UNCHECKED removal costs: a package
    # directory that refuses the unlink while still letting the candidate file be
    # overwritten leaves the stale marker, the installer skips, and the check
    # after the call accepts THAT marker as proof of an install this run never made.
    rm -f -- "$marker" 2>/dev/null
    if [ -e "$marker" ]; then
        closure_verify_refuse "the stale done marker $marker could not be removed, so the installer would skip this candidate and the tree could not be attributed to it"
        rm -rf -- "$work"
        return 1
    fi
    if ! bash "$tools/install_pkg.sh" "$target" --prefix "$prefix" > "$work/install.log" 2>&1; then
        closure_verify_refuse "the installation of $target under $prefix failed"
        rm -rf -- "$work"
        return 1
    fi
    if [ ! -f "$marker" ]; then
        closure_verify_refuse "the installer completed without writing $marker, so it installed some other $target archive and the installed tree is not this candidate"
        rm -rf -- "$work"
        return 1
    fi
    post=$(closure_verify_side "$prefix" "$tools/install_pkg.sh" "${specs[@]}") || {
        rm -rf -- "$work"
        return 1
    }

    # STEP 4, reported and never acted on.
    closure_verify_payload "$archive" "$tools" "$work/payload"

    # STEP 5, the two readings. Neither decides the artifact's verdict, which is
    # the comparison alone; both decide this RUN's status, because a static
    # refusal or an inconclusive trace is not a verified archive.
    bash "$tools/closure_check.sh" --prefix "$prefix" \
        --installer "$tools/install_pkg.sh" --bundle "$prefix/$CLOSURE_BUNDLE_DIR" \
        > "$work/check.out" 2>&1 || rc=1
    if [ "$rc" -eq 0 ]; then
        printf 'STATIC|%s\n' PASS
    else
        printf 'STATIC|%s\n' REFUSED
    fi
    if [ -n "$process" ]; then
        bash "$tools/closure_observe_live.sh" --process "$process" --prefix "$prefix" \
            --proc "$proc" > "$work/live.out" 2>&1 || rc=1
        while IFS= read -r line; do
            case "$line" in 'LIVE|'*) printf '%s\n' "$line" ;; esac
        done < "$work/live.out"
    else
        printf 'LIVE|%s|%s\n' INCONCLUSIVE 'no process was named, so no live reading was taken'
        rc=1
    fi

    # STEP 6: the one artifact, read back by its own contract before promotion.
    doc="$work/evidence.txt"
    closure_verify_document "$identity" "$cfgdigest" "$pre" "$post" > "$doc"
    if ! closure_evidence_parse "$doc" > "$work/parse.out" 2>&1; then
        closure_verify_refuse "the evidence document this run produced does not satisfy its own grammar"
        cat -- "$work/parse.out"
        rm -rf -- "$work"
        return 1
    fi
    verdict="$CLOSURE_EVI_VERDICT"
    printf 'COMPARISON|%s\n' "$verdict"
    if ! closure_evidence_emit "$results" "$identity" "$doc"; then
        rm -rf -- "$work"
        return 1
    fi
    rm -rf -- "$work"
    if [ "$verdict" != "PASS" ]; then return 1; fi
    return "$rc"
}

# --- MAIN BOUNDARY ---
# Everything above is definitions; everything below verifies. Sourcing this file
# defines its functions and verifies nothing, which is what lets publication take
# `closure_evidence_parse` without acquiring the driver.
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    return 0
fi

closure_verify_main "$@"
