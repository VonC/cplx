#!/bin/bash
#
# closure_config.sh -- the configuration module of the v0.27.0 runtime-closure
# checker. Created at Step 1 with its contract comment and a body of zero lines,
# because the module set of this effort is FIXED AND UNCONDITIONAL and a topology
# that could still gain a module is not a contract. FILLED HERE BY STEP 2 with
# the four responsibilities that topology gives it. STEP 4 ADDS ONE RECORD to the
# table below, `entrypoint`, because Q13 makes the declared entry-point set
# configuration and it belongs in the one parser every party uses.
#
# THIS MODULE OWNS, AND IS THE ONLY PLACE THAT MAY OWN:
#
#   closure_config_parse           the ONE grammar parser every party uses. An
#                                  exact-byte digest makes two parties agree on
#                                  the bytes and not on their meaning, so the
#                                  grammar is a separate contract from the digest
#                                  and both are required. Unknown and duplicate
#                                  records fail closed.
#   closure_config_digest          SHA-256 over the configuration document's
#                                  exact committed bytes, never over parsed
#                                  content, so a party that cannot parse the
#                                  format can still reproduce the value.
#   closure_envelope_check         the agent-side check, which is INTERNAL
#                                  CONSISTENCY and not authority, and whose
#                                  output states that limit itself.
#
# THE CPLX-SIDE RESOLUTION IS NOT HERE, AND STEP 6 IS WHY IT LEFT. It moved to
# closure_publish.sh, because the rule for a module at the ceiling is to move a
# responsibility to the module that already owns its neighbours, and publication
# owns that one outright: the design settles that only publication can resolve a
# path at a commit, since packaging runs on an account with no checkout and the
# Debian agent has no checkout either. The move also takes `git` off the
# dependency surface of the copies the archive carries, which could never have
# used it.
#
# It is SOURCED by closure_check.sh and by closure_publish.sh, and never
# executed. Keeping it apart from the invariants is what lets publication reuse
# the parser and the digest without pulling in the four archive rules.
#
# THE THREE PARTIES ARE ASYMMETRIC, AND THAT ASYMMETRY IS THE REQUIREMENT. What
# each party can establish is stated where its check is, so this file says it
# once: `closure_envelope_check` for the Debian agent, which has no cplx, and
# `closure_config_authority_check` for packaging and publication, which resolve
# the authoritative document themselves.
#
# THE DIGEST DOMAIN IS THE DOCUMENT'S EXACT COMMITTED BYTES. It covers the
# configuration document and NEVER the envelope, so it cannot cover itself, and
# the README beside the data states the domain in full where the data lives.
#
# ONE LEXER, AND A RECORD TABLE PER DOCUMENT. The shared shape is a version line
# first, one record per line, fields separated by a vertical bar, no empty field,
# %7C for a literal bar and %25 for a literal percent, any other percent sequence
# a refusal, an unknown record token a refusal, and a known token with the wrong
# field count a refusal. Two tables live here; the third, CPLX-CLOSURE-EVIDENCE/1,
# is Step 6's and adds a table rather than a parser, and it REFUSES the blank and
# comment lines these two ignore, because only a machine writes it.
#
# THE THIRD TABLE DOES NOT LIVE HERE, AND THE REASON IS MEASURED RATHER THAN
# argued. Written in this file's style it is 164 lines, which puts this module at
# 762 against a 650 deployment ceiling, and no other module has that much room.
# It sits in closure_verify.sh, which both of its readers can reach: the emitter
# IS that file, and closure_publish.sh sources it for the reader alone. What the
# rule protects is that ONE reader exists, not which file holds it. The evidence
# document is also the one grammar of the three that no copy inside the archive
# ever reads, so keeping it out of the payload costs the payload nothing.
#
# DECODING PRECEDES DOMAIN VALIDATION, and the order is a rule rather than an
# implementation accident: validating first would let %2F pass a no-slash domain
# and become a separator afterwards. The observable consequence is the REFUSAL
# REASON: %2F is refused as an undefined escape and never reaches its domain,
# while the defined %7C is decoded and then refused BY THE DOMAIN.
#
# WHY THIS FILE SPAWNS ALMOST NO PROCESS. Every command a shipped script depends
# on the host to supply has to be declared in contract.closure-tools.txt, and the
# harness extracts every command-position word from this file and fails on any
# word absent from it. The parser is therefore pure Bash: no grep, no sed, no tr,
# no wc. For the same reading rule every word-initial case pattern below is
# quoted: unquoted, it sits in command position for that lexical reader and would
# be reported as a host dependency nobody declared.

# ---------------------------------------------------------------- fixed names ---
CLOSURE_CONFIG_VERSION="CPLX-CLOSURE/1"
CLOSURE_ENVELOPE_VERSION="CPLX-CLOSURE-ENVELOPE/1"

# The archive path Q04 fixes for the bundle, and the two basenames inside it,
# declared here rather than at each caller so the staging Step 5 adds, the
# checker's reader and the verification driver cannot drift apart.
# shellcheck disable=SC2034  # read by closure_check.sh and by Step 5's staging
CLOSURE_BUNDLE_DIR="tools/closure"
# shellcheck disable=SC2034  # read by closure_check.sh and by Step 5's staging
CLOSURE_CONFIG_BASENAME="closure-config.txt"
# shellcheck disable=SC2034  # read by closure_check.sh and by Step 5's staging
CLOSURE_ENVELOPE_BASENAME="closure-envelope.txt"

# The one statement of what an agent-side pass does and does not mean, travelling
# with every consistency verdict: a limit stated at one caller and omitted at
# another is a limit nobody can rely on.
CLOSURE_CONSISTENCY_LIMIT="INTERNAL CONSISTENCY ONLY: a host with no cplx access cannot tell an authentic bundle from the reviewed one"

# The lexical domains, one exact expression each, so a one-segment root name and
# a two-wildcard glob are decidable rather than a matter of reading. They are
# variables because a quoted pattern is matched literally by the shell.
CLOSURE_RE_SEGMENT='^[A-Za-z0-9._+-]{1,64}$'
CLOSURE_RE_LOOKUP='^[A-Za-z0-9._+-]{1,128}$'
CLOSURE_RE_LOWER='^[a-z0-9-]{1,64}$'
CLOSURE_RE_GENERATIONS='^[1-9][0-9]{0,2}$'
CLOSURE_RE_SHA256='^[0-9a-f]{64}$'
CLOSURE_RE_COMMIT='^[0-9a-f]{40}$'

# ------------------------------------------------------------ the parsed model ---
# CLOSURE_CFG_ROOTS is ordered, because the root order is the loader's order and
# the only ordering this grammar makes significant. CLOSURE_CFG_SUBDIRS maps a
# root to the comma-fenced list of its declared immediate subdirectories, of the
# shape ,root,current, so a membership test is one pattern match; a root with no
# subdir record holds a single comma, which is a DECLARED root with an empty list
# and not an undeclared one, and that difference is what the cross-reference pass
# reads. CLOSURE_CFG_XREF holds the cross-references, collected as the records are
# read and resolved once the whole document is, which is what closure_cfg_cross_refs
# explains where it applies them.
# CLOSURE_CFG_ENTRY is Step 4's addition, the DECLARED ENTRY-POINT SET of design
# Q13, keyed by location because order carries no meaning here: entry points are
# a set, and `root` is the one ordering this grammar makes significant.
CLOSURE_CFG_ROOTS=()
CLOSURE_CFG_XREF=()
CLOSURE_CFG_BAD=0
declare -A CLOSURE_CFG_ENTRY=()
declare -A CLOSURE_CFG_SUBDIRS=()
declare -A CLOSURE_CFG_FLOOR=()
declare -A CLOSURE_CFG_FAMILY=()
declare -A CLOSURE_CFG_FAMILY_GEN=()
declare -A CLOSURE_CFG_WAIVER=()

# The identity envelope, which is NOT covered by the digest it carries.
CLOSURE_ENVELOPE_DIGEST=""
CLOSURE_ENVELOPE_PATH=""
CLOSURE_ENVELOPE_COMMIT=""
CLOSURE_ENV_DIGESTS=0
CLOSURE_ENV_SOURCES=0

# ------------------------------------------------------------------- the lexer ---
CLOSURE_LEX_VALUE=""
CLOSURE_LEX_BAD=""
CLOSURE_LEX_FIELDS=()
CLOSURE_LEX_ERROR=""
CLOSURE_LEX_DETAIL=""

# Decodes one raw field into CLOSURE_LEX_VALUE. Returns non-zero on an undefined
# escape, leaving the offending sequence in CLOSURE_LEX_BAD. The result travels
# through a global rather than through stdout because a command substitution
# would run this in a subshell and lose CLOSURE_LEX_BAD with it.
closure_lex_decode() {
    local rest="$1" out="" ch two
    CLOSURE_LEX_VALUE=""
    CLOSURE_LEX_BAD=""
    case "$rest" in
        *%*) ;;
        *) CLOSURE_LEX_VALUE="$rest"; return 0 ;;
    esac
    while [ -n "$rest" ]; do
        ch="${rest:0:1}"
        if [ "$ch" != "%" ]; then
            out="$out$ch"
            rest="${rest:1}"
            continue
        fi
        two="${rest:1:2}"
        case "$two" in
            7C) out="$out|"; rest="${rest:3}" ;;
            25) out="$out%"; rest="${rest:3}" ;;
            *) CLOSURE_LEX_BAD="%$two"; return 1 ;;
        esac
    done
    CLOSURE_LEX_VALUE="$out"
    return 0
}

# Splits one record line into CLOSURE_LEX_FIELDS, decoded. Returns non-zero with
# CLOSURE_LEX_ERROR and CLOSURE_LEX_DETAIL set, on an empty field or an undefined
# escape, which are the two refusals belonging to the shared lexical shape rather
# than to any one record table.
closure_lex_record() {
    local line="$1" part
    local raw=()
    CLOSURE_LEX_FIELDS=()
    CLOSURE_LEX_ERROR=""
    CLOSURE_LEX_DETAIL=""
    # read -a discards a final empty field; reject it before splitting.
    case "$line" in
        *'|')
            CLOSURE_LEX_ERROR="empty-field"
            CLOSURE_LEX_DETAIL="a record may carry no empty field"
            return 1 ;;
    esac
    IFS='|' read -r -a raw <<< "$line"
    for part in ${raw[@]+"${raw[@]}"}; do
        if [ -z "$part" ]; then
            CLOSURE_LEX_ERROR="empty-field"
            CLOSURE_LEX_DETAIL="a record may carry no empty field"
            return 1
        fi
        if ! closure_lex_decode "$part"; then
            CLOSURE_LEX_ERROR="escape"
            CLOSURE_LEX_DETAIL="$CLOSURE_LEX_BAD is not a defined escape, and only %7C and %25 are"
            return 1
        fi
        CLOSURE_LEX_FIELDS+=("$CLOSURE_LEX_VALUE")
    done
    return 0
}

# One DECODED value against one lexical domain. Every placeholder of the three
# grammars resolves to one of these, so a domain is decided here and nowhere else.
closure_lex_domain() {
    local kind="$1" value="$2" stripped stars rest part count
    case "$kind" in
        'segment')
            [[ $value =~ $CLOSURE_RE_SEGMENT ]] || return 1
            case "$value" in .|..) return 1 ;; esac
            ;;
        'lookup') [[ $value =~ $CLOSURE_RE_LOOKUP ]] || return 1 ;;
        'lower') [[ $value =~ $CLOSURE_RE_LOWER ]] || return 1 ;;
        'generations') [[ $value =~ $CLOSURE_RE_GENERATIONS ]] || return 1 ;;
        'sha256') [[ $value =~ $CLOSURE_RE_SHA256 ]] || return 1 ;;
        'commit') [[ $value =~ $CLOSURE_RE_COMMIT ]] || return 1 ;;
        # The three closed enumerations of the evidence table. They are decided
        # HERE with every other domain rather than beside the table that uses
        # them, because a domain decided at its call site is a domain each new
        # caller gets to reinterpret.
        'presence') case "$value" in 'present'|'absent') ;; *) return 1 ;; esac ;;
        'verdict') case "$value" in 'PASS'|'DIVERGENT') ;; *) return 1 ;; esac ;;
        'side') case "$value" in 'pre'|'post') ;; *) return 1 ;; esac ;;
        'glob')
            stripped="${value//\*/}"
            stars=$(( ${#value} - ${#stripped} ))
            [ "$stars" -le 1 ] || return 1
            [ -n "$stripped" ] || return 1
            [[ $stripped =~ $CLOSURE_RE_LOOKUP ]] || return 1
            ;;
        'location')
            if [ "$value" = "any" ]; then return 0; fi
            case "$value" in
                'tools/'*) ;;
                *) return 1 ;;
            esac
            closure_lex_domain segment "${value#tools/}" || return 1
            ;;
        'repo-path')
            case "$value" in
                /*) return 1 ;;
                */) return 1 ;;
            esac
            count=0
            rest="$value"
            while [ -n "$rest" ]; do
                part="${rest%%/*}"
                if [ "$part" = "$rest" ]; then rest=""; else rest="${rest#*/}"; fi
                closure_lex_domain segment "$part" || return 1
                count=$((count + 1))
            done
            [ "$count" -ge 2 ] || return 1
            [ "$count" -le 8 ] || return 1
            ;;
        *) return 1 ;;
    esac
    return 0
}

# -------------------------------------------------------------------- refusals ---
# One refusal, one line, four fields: the literal REFUSED, the line number, a
# stable code and a detail. Line 0 is a refusal about the document as a whole
# rather than about one of its records.
closure_cfg_refuse() {
    printf '%s|%s|%s|%s\n' REFUSED "$1" "$2" "$3"
    CLOSURE_CFG_BAD=1
}

closure_cfg_count() {
    local n="$1" token="$2" want="$3" got="$4"
    if [ "$got" -eq "$want" ]; then return 0; fi
    closure_cfg_refuse "$n" field-count "$token takes $want fields and this record has $got"
    return 1
}

closure_cfg_domain() {
    local n="$1" placeholder="$2" kind="$3" value="$4"
    if closure_lex_domain "$kind" "$value"; then return 0; fi
    closure_cfg_refuse "$n" domain "$placeholder: $value"
    return 1
}

# --------------------------------------------------------- the one stream reader ---
# The shared lexical shape, read once for every document that has it. The table
# argument selects the record table rather than naming a function to call: an
# assembled command name is exactly the shape the host-tool contract calls its
# known lexical limit, so the dispatch stays visible to a reader of this text.
closure_stream_read() {
    local file="$1" version="$2" table="$3" noun="$4"
    local n=0 line stripped seen_version=0

    if [ ! -f "$file" ]; then
        closure_cfg_refuse 0 absent "no $noun at $file"
        return 1
    fi
    while IFS= read -r line || [ -n "$line" ]; do
        n=$((n + 1))
        stripped="${line//[[:space:]]/}"
        # THE EVIDENCE DOCUMENT REFUSES WHAT THE OTHER TWO IGNORE. A person edits
        # a configuration and an envelope, so a blank line and a comment are
        # courtesies there; only a machine writes evidence, and one observation
        # must have exactly one byte sequence for a byte comparison to compare
        # meaning. So the same reader is strict for one table and lenient for two.
        if [ -z "$stripped" ]; then
            if [ "$table" = "evidence" ]; then
                closure_cfg_refuse "$n" blank-line "a machine writes this document and leaves no blank line in it"
            fi
            continue
        fi
        case "$line" in
            '#'*)
                if [ "$table" = "evidence" ]; then
                    closure_cfg_refuse "$n" comment "a machine writes this document and leaves no comment in it"
                fi
                continue ;;
        esac
        if [ "$seen_version" -eq 0 ]; then
            seen_version=1
            if [ "$line" != "$version" ]; then
                closure_cfg_refuse "$n" version "the first record line must be $version, and this one is $line"
            fi
            continue
        fi
        if ! closure_lex_record "$line"; then
            closure_cfg_refuse "$n" "$CLOSURE_LEX_ERROR" "$CLOSURE_LEX_DETAIL"
            continue
        fi
        case "$table" in
            'config') closure_cfg_record "$n" "${#CLOSURE_LEX_FIELDS[@]}" ;;
            'envelope') closure_env_record "$n" "${#CLOSURE_LEX_FIELDS[@]}" ;;
            # Defined by closure_verify.sh, which sources this file. The arm is
            # here because the dispatch is the reader's, and a caller that has
            # not loaded the third table reaches it only by naming it.
            'evidence') closure_evi_record "$n" "${#CLOSURE_LEX_FIELDS[@]}" ;;
        esac
    done < "$file"
    if [ "$seen_version" -eq 0 ]; then
        closure_cfg_refuse 0 version "the document declares no $version version line"
    fi
    return 0
}

# --------------------------------------------------- the configuration records ---
closure_cfg_record() {
    local n="$1" count="$2" token="${CLOSURE_LEX_FIELDS[0]}"
    case "$token" in
        'root') closure_cfg_root "$n" "$count" ;;
        'subdir') closure_cfg_subdir "$n" "$count" ;;
        'floor') closure_cfg_floor "$n" "$count" ;;
        'family') closure_cfg_family "$n" "$count" ;;
        'waiver') closure_cfg_waiver "$n" "$count" ;;
        'entrypoint') closure_cfg_entrypoint "$n" "$count" ;;
        *) closure_cfg_refuse "$n" unknown-record "$token" ;;
    esac
}

closure_cfg_root() {
    local n="$1" count="$2" name
    closure_cfg_count "$n" root 2 "$count" || return 0
    name="${CLOSURE_LEX_FIELDS[1]}"
    closure_cfg_domain "$n" root-name segment "$name" || return 0
    if [ -n "${CLOSURE_CFG_SUBDIRS[$name]:-}" ]; then
        closure_cfg_refuse "$n" duplicate "root: $name"
        return 0
    fi
    if [ "${#CLOSURE_CFG_ROOTS[@]}" -eq 0 ] && [ "$name" != "python" ]; then
        closure_cfg_refuse "$n" order "the first root record must be python, and this one is $name"
        return 0
    fi
    CLOSURE_CFG_ROOTS+=("$name")
    CLOSURE_CFG_SUBDIRS["$name"]=","
}

closure_cfg_subdir() {
    local n="$1" count="$2" root sub
    closure_cfg_count "$n" subdir 3 "$count" || return 0
    root="${CLOSURE_LEX_FIELDS[1]}"
    sub="${CLOSURE_LEX_FIELDS[2]}"
    closure_cfg_domain "$n" root-name segment "$root" || return 0
    closure_cfg_domain "$n" subdir-name segment "$sub" || return 0
    CLOSURE_CFG_XREF+=("$n subdir-root $root $sub")
}

# Apply subdirectories after roots have been read, preserving forward references.
closure_cfg_add_subdir() {
    local n="$1" root="$2" sub="$3"
    # The comma-fenced list is the ONE record of what a root declares, so the
    # duplicate test is a membership test on it rather than a second map that
    # could disagree with it. An undeclared root holds nothing to test against.
    if [ -z "${CLOSURE_CFG_SUBDIRS[$root]:-}" ]; then return 0; fi
    case "${CLOSURE_CFG_SUBDIRS[$root]}" in
        *",$sub,"*)
            closure_cfg_refuse "$n" duplicate "subdir: $root $sub"
            return 0 ;;
    esac
    CLOSURE_CFG_SUBDIRS["$root"]="${CLOSURE_CFG_SUBDIRS[$root]}$sub,"
}

closure_cfg_floor() {
    local n="$1" count="$2" name location
    closure_cfg_count "$n" floor 3 "$count" || return 0
    name="${CLOSURE_LEX_FIELDS[1]}"
    location="${CLOSURE_LEX_FIELDS[2]}"
    closure_cfg_domain "$n" lookup-name lookup "$name" || return 0
    closure_cfg_domain "$n" location location "$location" || return 0
    if [ -n "${CLOSURE_CFG_FLOOR[$name]:-}" ]; then
        closure_cfg_refuse "$n" duplicate "floor: $name"
        return 0
    fi
    CLOSURE_CFG_FLOOR["$name"]="$location"
    if [ "$location" != "any" ]; then
        CLOSURE_CFG_XREF+=("$n floor-root ${location#tools/}")
    fi
}

closure_cfg_family() {
    local n="$1" count="$2" name glob generations key
    closure_cfg_count "$n" family 4 "$count" || return 0
    name="${CLOSURE_LEX_FIELDS[1]}"
    glob="${CLOSURE_LEX_FIELDS[2]}"
    generations="${CLOSURE_LEX_FIELDS[3]}"
    closure_cfg_domain "$n" family-name lower "$name" || return 0
    closure_cfg_domain "$n" soname-glob glob "$glob" || return 0
    closure_cfg_domain "$n" generations generations "$generations" || return 0
    key="$name $glob"
    if [ -n "${CLOSURE_CFG_FAMILY[$key]:-}" ]; then
        closure_cfg_refuse "$n" duplicate "family: $key"
        return 0
    fi
    if [ -n "${CLOSURE_CFG_FAMILY_GEN[$name]:-}" ] &&
       [ "${CLOSURE_CFG_FAMILY_GEN[$name]}" != "$generations" ]; then
        closure_cfg_refuse "$n" family-generations "$name carries ${CLOSURE_CFG_FAMILY_GEN[$name]} in one record and $generations in another"
        return 0
    fi
    CLOSURE_CFG_FAMILY["$key"]="$generations"
    CLOSURE_CFG_FAMILY_GEN["$name"]="$generations"
}

closure_cfg_waiver() {
    local n="$1" count="$2" member owner
    closure_cfg_count "$n" waiver 3 "$count" || return 0
    member="${CLOSURE_LEX_FIELDS[1]}"
    owner="${CLOSURE_LEX_FIELDS[2]}"
    closure_cfg_domain "$n" lookup-name lookup "$member" || return 0
    closure_cfg_domain "$n" owning-requirement lower "$owner" || return 0
    if [ -n "${CLOSURE_CFG_WAIVER[$member]:-}" ]; then
        closure_cfg_refuse "$n" duplicate "waiver: $member"
        return 0
    fi
    CLOSURE_CFG_WAIVER["$member"]="$owner"
    CLOSURE_CFG_XREF+=("$n waiver-member $member")
}

# THE DECLARED ENTRY-POINT SET, added by Step 4 under design Q13. One record names
# one LOCATION relative to the archive whose shipped ELF objects are entry points:
# the interpreter, the shipped executable directories, and the dynamically loaded
# locations the interpreter opens by path. IT IS DECLARED AND NEVER DERIVED, for
# the reason the subject rule already gives: the loading mechanism at issue leaves
# no static trace, so a heuristic over `PT_INTERP`, a file name or a permission bit
# would be wrong in both directions. The location is a `repo-path` under a DECLARED
# tool root, so a typo fails closed rather than naming a location nothing is under.
closure_cfg_entrypoint() {
    local n="$1" count="$2" location root
    closure_cfg_count "$n" entrypoint 2 "$count" || return 0
    location="${CLOSURE_LEX_FIELDS[1]}"
    closure_cfg_domain "$n" entry-location repo-path "$location" || return 0
    root="${location#tools/}"
    if [ "$root" = "$location" ]; then
        closure_cfg_refuse "$n" domain "entry-location: $location"
        return 0
    fi
    if [ -n "${CLOSURE_CFG_ENTRY[$location]:-}" ]; then
        closure_cfg_refuse "$n" duplicate "entrypoint: $location"
        return 0
    fi
    CLOSURE_CFG_ENTRY["$location"]=1
    CLOSURE_CFG_XREF+=("$n entrypoint-root ${root%%/*}")
}

# The cross-references, validated once the whole document is read. A subdir, a
# floor location other than `any` and an entry-point location each name a declared
# root, and a waiver names a member the floor declares. An unknown waiver is a
# refusal here rather than a silent exception, which is the contract the issue
# states: waivers name FLOOR MEMBERS ONLY.
closure_cfg_cross_refs() {
    local entry n kind value sub
    for entry in ${CLOSURE_CFG_XREF[@]+"${CLOSURE_CFG_XREF[@]}"}; do
        read -r n kind value sub <<< "$entry"
        case "$kind" in
            'subdir-root'|'floor-root'|'entrypoint-root')
                if [ -z "${CLOSURE_CFG_SUBDIRS[$value]:-}" ]; then
                    closure_cfg_refuse "$n" cross-reference "$kind names the undeclared root $value"
                elif [ "$kind" = "subdir-root" ]; then
                    closure_cfg_add_subdir "$n" "$value" "$sub"
                fi ;;
            'waiver-member')
                if [ -z "${CLOSURE_CFG_FLOOR[$value]:-}" ]; then
                    closure_cfg_refuse "$n" cross-reference "waiver names $value, which the floor does not declare"
                fi ;;
        esac
    done
}

# The parsed model, emptied. Keys are unset one by one rather than through a global
# redeclaration, which inside a function would make the array local to it.
closure_config_reset() {
    local k
    for k in ${CLOSURE_CFG_SUBDIRS[@]+"${!CLOSURE_CFG_SUBDIRS[@]}"}; do unset "CLOSURE_CFG_SUBDIRS[$k]"; done
    for k in ${CLOSURE_CFG_FLOOR[@]+"${!CLOSURE_CFG_FLOOR[@]}"}; do unset "CLOSURE_CFG_FLOOR[$k]"; done
    for k in ${CLOSURE_CFG_FAMILY[@]+"${!CLOSURE_CFG_FAMILY[@]}"}; do unset "CLOSURE_CFG_FAMILY[$k]"; done
    for k in ${CLOSURE_CFG_FAMILY_GEN[@]+"${!CLOSURE_CFG_FAMILY_GEN[@]}"}; do unset "CLOSURE_CFG_FAMILY_GEN[$k]"; done
    for k in ${CLOSURE_CFG_WAIVER[@]+"${!CLOSURE_CFG_WAIVER[@]}"}; do unset "CLOSURE_CFG_WAIVER[$k]"; done
    for k in ${CLOSURE_CFG_ENTRY[@]+"${!CLOSURE_CFG_ENTRY[@]}"}; do unset "CLOSURE_CFG_ENTRY[$k]"; done
    CLOSURE_CFG_ROOTS=()
    CLOSURE_CFG_XREF=()
    CLOSURE_CFG_BAD=0
}

# THE ONE PARSER, and the one every party uses. It prints a refusal per line and
# nothing at all when the document is clean, sets the parsed model, and returns
# non-zero when it refused. Unknown records, wrong field counts, duplicate keys,
# an out-of-order root record and an unresolved cross-reference all fail closed.
closure_config_parse() {
    closure_config_reset
    closure_stream_read "$1" "$CLOSURE_CONFIG_VERSION" config "configuration document"
    closure_cfg_cross_refs
    [ "$CLOSURE_CFG_BAD" -eq 0 ]
}

# The declared roots and their subdirectory lists, in the same NAME=SUB,SUB shape
# closure_check.sh already takes, which is what makes the committed declaration the
# source of the declared candidate shape rather than a document nothing reads.
closure_config_root_specs() {
    local root subs
    for root in ${CLOSURE_CFG_ROOTS[@]+"${CLOSURE_CFG_ROOTS[@]}"}; do
        subs="${CLOSURE_CFG_SUBDIRS[$root]}"
        subs="${subs#,}"
        subs="${subs%,}"
        printf '%s=%s\n' "$root" "$subs"
    done
}

# ------------------------------------------------------------------ the digest ---
# SHA-256 over the document's bytes on disk, never over parsed content. Printed
# bare, so the value is the digest and not the two-column line the tool emits.
closure_config_digest() {
    local file="$1" out=""
    if [ ! -f "$file" ]; then return 1; fi
    out=$(sha256sum -- "$file" 2>/dev/null) || return 1
    if [ -z "$out" ]; then return 1; fi
    printf '%s' "${out%% *}"
}

# ---------------------------------------------------------------- the envelope ---
# The second bundle part, outside the digest it carries. Exactly one digest
# record and exactly one source record, so a missing or repeated record refuses;
# the commit domain is 40 lowercase hexadecimal characters, so a short SHA, a
# branch and a tag all refuse at parse time and packaging cannot produce a bundle
# naming a reference whose content can change under it.
closure_env_record() {
    local n="$1" count="$2" token="${CLOSURE_LEX_FIELDS[0]}"
    case "$token" in
        'digest')
            closure_cfg_count "$n" digest 2 "$count" || return 0
            closure_cfg_domain "$n" sha256 sha256 "${CLOSURE_LEX_FIELDS[1]}" || return 0
            CLOSURE_ENV_DIGESTS=$((CLOSURE_ENV_DIGESTS + 1))
            CLOSURE_ENVELOPE_DIGEST="${CLOSURE_LEX_FIELDS[1]}" ;;
        'source')
            closure_cfg_count "$n" source 3 "$count" || return 0
            closure_cfg_domain "$n" repo-path repo-path "${CLOSURE_LEX_FIELDS[1]}" || return 0
            closure_cfg_domain "$n" commit commit "${CLOSURE_LEX_FIELDS[2]}" || return 0
            CLOSURE_ENV_SOURCES=$((CLOSURE_ENV_SOURCES + 1))
            CLOSURE_ENVELOPE_PATH="${CLOSURE_LEX_FIELDS[1]}"
            CLOSURE_ENVELOPE_COMMIT="${CLOSURE_LEX_FIELDS[2]}" ;;
        *) closure_cfg_refuse "$n" unknown-record "$token" ;;
    esac
}

closure_envelope_parse() {
    CLOSURE_CFG_BAD=0
    CLOSURE_ENVELOPE_DIGEST=""
    # The path and the commit are parsed here and read one module away, by the
    # cplx-side resolution Step 6 moved into closure_publish.sh. They stay in the
    # envelope model because they are what the envelope SAYS; who acts on them is
    # a separate question, and only publication can.
    # shellcheck disable=SC2034  # read by closure_publish.sh after the move
    CLOSURE_ENVELOPE_PATH=""
    # shellcheck disable=SC2034  # read by closure_publish.sh after the move
    CLOSURE_ENVELOPE_COMMIT=""
    CLOSURE_ENV_DIGESTS=0
    CLOSURE_ENV_SOURCES=0
    closure_stream_read "$1" "$CLOSURE_ENVELOPE_VERSION" envelope "identity envelope"
    if [ "$CLOSURE_ENV_DIGESTS" -ne 1 ]; then
        closure_cfg_refuse 0 cardinality "the envelope carries $CLOSURE_ENV_DIGESTS digest records and must carry exactly one"
    fi
    if [ "$CLOSURE_ENV_SOURCES" -ne 1 ]; then
        closure_cfg_refuse 0 cardinality "the envelope carries $CLOSURE_ENV_SOURCES source records and must carry exactly one"
    fi
    [ "$CLOSURE_CFG_BAD" -eq 0 ]
}

# THE AGENT'S CHECK, and the whole of what a host without cplx can establish: the
# embedded document parses, and it hashes to the digest its envelope names. An
# absent, substituted or corrupted bundle refuses here, before any invariant
# runs. A paired edit does NOT, and neither does an authentic-but-wrong bundle,
# so the verdict carries its own limit on every line it prints.
closure_envelope_check() {
    local config="$1" envelope="$2" computed="" bad=0

    if ! closure_envelope_parse "$envelope"; then bad=1; fi
    if ! closure_config_parse "$config"; then bad=1; fi
    if [ "$bad" -eq 0 ]; then
        computed=$(closure_config_digest "$config")
        if [ -z "$computed" ]; then
            closure_cfg_refuse 0 digest "the configuration document at $config could not be digested here"
            bad=1
        elif [ "$computed" != "$CLOSURE_ENVELOPE_DIGEST" ]; then
            closure_cfg_refuse 0 digest "the embedded document hashes to $computed and its envelope names $CLOSURE_ENVELOPE_DIGEST"
            bad=1
        fi
    fi
    if [ "$bad" -ne 0 ]; then
        printf '%s|%s\n' INCONSISTENT "$CLOSURE_CONSISTENCY_LIMIT"
        return 1
    fi
    printf '%s|%s|%s\n' CONSISTENT "$computed" "$CLOSURE_CONSISTENCY_LIMIT"
    return 0
}
