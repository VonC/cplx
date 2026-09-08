#!/bin/bash
#
# closure_elf.sh -- the object reader of the v0.27.0 runtime-closure checker.
# Created at Step 1 with this contract and nothing else, because the module set
# of this effort is FIXED AND UNCONDITIONAL and a topology that could still gain
# a module is not a contract. FILLED HERE BY STEP 3 with the two responsibilities
# that topology gives it, and with nothing else. STEP 4 ADDS ONE RECORD TO THE
# READ, the version DEFINITIONS, because coherence asks what a selected provider
# defines and the one invocation already prints it.
#
# THIS MODULE OWNS, AND IS THE ONLY PLACE THAT MAY OWN:
#
#   the object reader      one `readelf -d -V` per shipped ELF, answering the
#                          dynamic entries, the version needs and the version
#                          definitions together. Four invariants asking
#                          separately would fork 2512 times where 628 suffice.
#   the provider index     the provider directories enumerated ONCE into a
#                          name-to-paths map, so resolving a DT_NEEDED name is a
#                          hash lookup and not a directory scan per name. The
#                          index is built OUTSIDE the object loop; built inside
#                          it, the walk would be O(n^2), which is the one shape
#                          this effort's complexity bound forbids.
#
# IT HAS NO VERDICT OF ITS OWN. It reads objects and answers questions about
# them; whether an answer is a refusal belongs to `closure_rules.sh`, which owns
# all four invariants. A reader that started refusing would put one invariant in
# two files.
#
# It is SOURCED by `closure_check.sh` and never executed.
#
# THE SUBJECT SET IS THE WALK, NOT A CLOSURE FROM THE ENTRY POINTS, and the
# reason is measured rather than argued. A transitive walk from 185 entry points
# reaches 176 names and misses 395 of the 628 shipped ELFs, among them the 76
# CPython extension modules under `lib-dynload` and the 28 under `site-packages`
# whose failures motivated this whole collection: the interpreter opens those by
# path at import time and no shipped object declares any of them. So every ELF in
# the tree is a subject, however it is loaded, and an object nothing reaches is
# REPORTED unreferenced rather than excluded from examination.
#
# ONE WALK, AND THE INDEX BEFORE IT. `closure_provider_index` is called first and
# `closure_subjects_walk` once, and every per-object fact any invariant needs is
# collected in that single pass and held in associative arrays keyed by path. An
# invariant that finds itself wanting a second walk has found a plan defect. The
# index is built by GLOBBING the provider directories rather than by walking
# them, which is what keeps the whole run at exactly one `find`.
#
# WHY THE PARSE IS PURE BASH BESIDE `find` AND `readelf`. Every command a shipped
# script depends on the host to supply has to be declared in
# `contract.closure-tools.txt`, and the harness extracts every command-position
# word from this file and fails on any word absent from it. So there is no grep,
# no sed, no od and no wc here: the two declared tools do the reading and the
# shell does the parsing.
#
# WHY `LC_ALL=C` IS PINNED ON EVERY INVOCATION. The parse reads `readelf`'s own
# field labels, `Shared library:` and `Library soname:` and `File:` among them. A
# translated build on a host whose locale differs from the one this was written
# on would print different labels, and the parse would then return EMPTY needs
# for an object that has them, which reads exactly like a closed object. The pin
# is per invocation rather than a global assignment, so nothing this module does
# changes the locale of the run around it.
#
# WHAT A READING FAILURE IS, AND WHAT IT IS NOT. A `readelf` that is absent,
# non-zero, or produces output the parser cannot read is an UNAVAILABLE INPUT, so
# its typed result is UNDETERMINED naming the object and the input it lacked. It
# is NOT a semantic REFUSAL: a refusal says the archive is wrong, and this says
# the reading could not be taken. The consequence is identical where it matters,
# because an UNDETERMINED never counts toward a green and the aggregate run is
# non-passing, which makes publication impossible. UNANSWERED with exit 5 stays a
# HARNESS outcome for a host that cannot execute a case, and is never produced
# here.

# ------------------------------------------------------------------ the model ---
# Built once per process. The run order is index, then walk, then the invariants,
# and the checker's MAIN BOUNDARY means a second run is a second process, so
# there is no reset: a model that could be emptied halfway would be a second
# state nobody reads.
#
# CLOSURE_ELF_PATHS is ordered, because the report follows the walk's own order
# and a reader comparing two captures should not have to sort them first.
CLOSURE_ELF_PATHS=()
CLOSURE_ELF_WALKED=0
CLOSURE_ELF_SUBJECTS=0
CLOSURE_ELF_UNREAD=0
CLOSURE_ELF_EDGES=0
CLOSURE_PROVIDER_DIRS=()
CLOSURE_PROVIDER_NAMES=0
CLOSURE_ELF_READER=""

# The walk's own outcome, which is a SEPARATE INPUT from any object's. `complete`
# means the traversal reached every file under the root; anything else is the
# reason it did not, and it makes the run non-passing on its own. A walk that
# silently ended early would report an empty tree, and an empty observation
# reading as a pass is the failure shape this whole effort refuses.
CLOSURE_ELF_WALK_STATE="complete"

# Set by the parser when it refuses an output, read by its caller so the typed
# UNDETERMINED names the field that could not be read rather than the object
# alone.
CLOSURE_ELF_PARSE_REASON=""

# The last bracketed value `closure_elf_bracketed` extracted.
CLOSURE_ELF_VALUE=""

# Keyed by object path. NEEDED holds the DT_NEEDED names separated by newlines,
# VERNEED holds one `provider|node` per line, VERDEF one defined node per line,
# all empty when the object records none. The version records are collected HERE,
# in the one read, and consumed by the coherence invariant Step 4 fills:
# collecting them later would mean reading every object twice.
#
# BOTH SIDES OF COHERENCE COME OUT OF THE SAME INVOCATION. Step 3 needed only the
# needs, and Step 4 asks whether the SELECTED PROVIDER defines the node it is
# asked for, which is a fact about that provider's own definitions. Reading them
# when the question is asked would mean one `readelf` per version need instead of
# one per object, which is the shape the cost rule forbids; `readelf -d -V`
# already prints the definition section beside the need section, so the record is
# free here and unobtainable anywhere else.
declare -A CLOSURE_ELF_SONAME=()
declare -A CLOSURE_ELF_NEEDED=()
declare -A CLOSURE_ELF_VERNEED=()
declare -A CLOSURE_ELF_VERDEF=()

# WHAT THE WALK DETERMINED ABOUT EVERY FILE IT REACHED, keyed by path: `object`
# read whole, `not-elf` positively identified as not one, `unread` reached and
# not readable. A path absent from this map was never reached at all.
#
# THE THREE ARE NOT INTERCHANGEABLE TO AN INVARIANT ASKING ABOUT A SELECTED
# PROVIDER. A known non-object defines no version node, which is a fact and a
# refusal; a file whose reading could not be taken defines nothing this run can
# state, which is an UNDETERMINED. Without the record an invariant can only tell
# "not in the model", and it would have to answer both with one verdict.
declare -A CLOSURE_ELF_KIND=()

# name -> the provider paths holding a file of that name, in scope order, one per
# line. The map is the whole point of the index: membership resolution is a
# lookup in it and never a scan of the directories.
declare -A CLOSURE_PROVIDER_PATHS=()

# link path -> the path it names, normalised against the link's own directory.
# THE ONE WALK RECORDS THIS, which is what makes resolving an alias a lookup. A
# soname link and its target do not share a name, `libz.so.1 -> libz.so.1.2.11`
# being the ordinary shape, so an alias cannot be resolved by name; and resolving
# it by comparing file identities costs one comparison per link and subject pair,
# which is the product bound this effort's complexity clarification forbids.
# `find` already knows where each link points, and it is asked in the same
# invocation that lists the subjects.
declare -A CLOSURE_LINK_TARGET=()

# The four magic bytes, held once rather than spelled at the test site.
CLOSURE_ELF_MAGIC=$'\x7fELF'

# ---------------------------------------------------------- the provider index ---
# Takes the observed loader scope as one directory per line and enumerates each
# directory ONCE, in scope order, into the name-to-paths map. Nothing is read
# from the files: a provider is a NAME at a PATH here, and what the bytes say is
# the business of the invariants that ask for them.
#
# The enumeration is a glob and not a walk, so the whole run keeps exactly one
# `find`. A directory that does not exist yields the unmatched pattern, which
# fails the file test and contributes nothing, which is the same answer the
# loader gives it.
closure_provider_index() {
    local rest="$1" dir path name

    while [ -n "$rest" ]; do
        dir="${rest%%$'\n'*}"
        if [ "$dir" = "$rest" ]; then rest=""; else rest="${rest#*$'\n'}"; fi
        if [ -z "$dir" ]; then continue; fi
        CLOSURE_PROVIDER_DIRS+=("$dir")
        for path in "$dir"/*; do
            if [ ! -f "$path" ]; then continue; fi
            name="${path##*/}"
            if [ -z "${CLOSURE_PROVIDER_PATHS[$name]:-}" ]; then
                CLOSURE_PROVIDER_PATHS["$name"]="$path"
                CLOSURE_PROVIDER_NAMES=$((CLOSURE_PROVIDER_NAMES + 1))
            else
                CLOSURE_PROVIDER_PATHS["$name"]="${CLOSURE_PROVIDER_PATHS[$name]}"$'\n'"$path"
            fi
        done
    done
}

# ------------------------------------------------------------- the object test ---
# The four magic bytes, read with the shell itself because `od` and `head` are
# not on this effort's host-tool contract. `read -n 4` stops at a newline, which
# the ELF magic does not contain, so a file whose first bytes are those four is
# identified and every other file answers no.
closure_elf_is_object() {
    local magic=""
    IFS= read -r -n 4 magic < "$1" 2>/dev/null || true
    [ "$magic" = "$CLOSURE_ELF_MAGIC" ]
}

# ---------------------------------------------------------- the reading failure ---
# THE FAIL-CLOSED PRODUCTION RULE, TYPED CORRECTLY. It prints the typed
# UNDETERMINED line and counts it, and it is deliberately not a refusal: the
# object is named, the input that was not there is named, and the aggregate run
# is left non-passing by the count rather than by a verdict this module has no
# business reaching.
closure_read_failed() {
    printf '%s|%s|%s|%s\n' UNDETERMINED object "$1" "$2"
    CLOSURE_ELF_KIND["$1"]=unread
    CLOSURE_ELF_UNREAD=$((CLOSURE_ELF_UNREAD + 1))
}

# ----------------------------------------------------------------- the parsing ---
# The value `readelf` prints in brackets for a string-valued dynamic entry, or
# non-zero when there is none to read. THE ABSENCE IS THE POINT: a `DT_NEEDED`
# whose string offset falls outside the string table is printed by a supported
# reader, at status 0, as the raw value with no brackets at all. Matching only
# the bracketed shape silently drops that entry, and an object whose dependency
# could not be read then resolves nothing and refuses nothing.
closure_elf_bracketed() {
    local line="$1" value
    CLOSURE_ELF_VALUE=""
    case "$line" in
        *'['*']'*) ;;
        *) return 1 ;;
    esac
    value="${line##*\[}"
    value="${value%%\]*}"
    if [ -z "$value" ]; then return 1; fi
    CLOSURE_ELF_VALUE="$value"
    return 0
}

# One `readelf -d -V` output, turned into the three records this effort needs.
# The dynamic half is read from the bracketed name `readelf` prints for a string
# entry; the version half tracks which version section it is inside, because
# `Name:` appears in the definitions and in the needs and only the needs carry a
# provider to resolve against.
#
# A RECOGNIZED RECORD WHOSE VALUE CANNOT BE READ REFUSES THE WHOLE OBJECT, and
# the model is committed only once the output is read to the end. Recording the
# entries that did parse and dropping the one that did not would leave a subject
# in the inventory with a dependency set nobody can vouch for, which reads
# exactly like an object that genuinely declares fewer needs. So the counters are
# local until the commit: a refused output leaves no partial edge count behind.
#
# Returns non-zero with CLOSURE_ELF_PARSE_REASON set, naming the field that could
# not be read, or the absence of any dynamic section statement, which is the
# shape a reader that answered in another language, or did not answer at all,
# produces.
#
# shellcheck disable=SC2034  # the three records are written here and read by
# closure_rules.sh, which closure_check.sh sources beside this file; shellcheck
# reads one file at a time and cannot see the reader on the other side.
closure_elf_parse() {
    local path="$1" text="$2"
    local line section="" file="" node="" shape=0 value=""
    local soname="" needed="" verneed="" verdef="" edges=0

    CLOSURE_ELF_PARSE_REASON=""
    # READ THE OUTPUT ONCE, LINE BY LINE. Slicing the remaining text with
    # `${rest#*...}` copies what is left on every iteration, which is quadratic
    # in the SIZE of one reader's output: the version symbols section of a large
    # object runs to hundreds of lines. The shell's own reader walks it once.
    while IFS= read -r line; do
        case "$line" in
            *'Dynamic section at offset'*|*'There is no dynamic section'*) shape=1 ;;
        esac
        case "$line" in
            *'Version needs section'*) section=needs; continue ;;
            *'Version definition section'*) section=defs; continue ;;
            *'Version symbols section'*) section=syms; continue ;;
        esac
        case "$line" in
            *'(NEEDED)'*)
                if ! closure_elf_bracketed "$line"; then
                    CLOSURE_ELF_PARSE_REASON='a DT_NEEDED entry carries no readable name'
                    return 1
                fi
                needed="${needed:+$needed$'\n'}$CLOSURE_ELF_VALUE"
                edges=$((edges + 1))
                continue ;;
            *'(SONAME)'*)
                if ! closure_elf_bracketed "$line"; then
                    CLOSURE_ELF_PARSE_REASON='the DT_SONAME entry carries no readable name'
                    return 1
                fi
                soname="$CLOSURE_ELF_VALUE"
                continue ;;
        esac
        # THE DEFINITION SECTION IS READ IN ITS OWN BRANCH, because `Name:`
        # appears in both halves and only the needs half carries a provider to
        # resolve against. A definition entry's continuation line names a PARENT
        # rather than a node and carries no `Name:`, so the version tree collapses
        # to the node list this checker compares against, which is what the
        # coherence question asks for.
        if [ "$section" = "defs" ]; then
            case "$line" in
                *'Name: '*)
                    node="${line#*Name: }"
                    node="${node%% *}"
                    if [ -z "$node" ]; then
                        CLOSURE_ELF_PARSE_REASON='a version definition carries no readable node name'
                        return 1
                    fi
                    verdef="${verdef:+$verdef$'\n'}$node" ;;
            esac
            continue
        fi
        if [ "$section" != "needs" ]; then continue; fi
        case "$line" in
            *'File: '*)
                value="${line#*File: }"
                value="${value%% *}"
                if [ -z "$value" ]; then
                    CLOSURE_ELF_PARSE_REASON='a version need names no readable provider file'
                    return 1
                fi
                file="$value"
                continue ;;
            *'Name: '*)
                node="${line#*Name: }"
                node="${node%% *}"
                if [ -z "$node" ]; then
                    CLOSURE_ELF_PARSE_REASON='a version need carries no readable node name'
                    return 1
                fi
                if [ -n "$file" ]; then
                    verneed="${verneed:+$verneed$'\n'}$file|$node"
                fi
                continue ;;
        esac
    done <<< "$text"

    if [ "$shape" -ne 1 ]; then
        CLOSURE_ELF_PARSE_REASON='the output carries no dynamic section statement'
        return 1
    fi
    CLOSURE_ELF_SONAME["$path"]="$soname"
    CLOSURE_ELF_NEEDED["$path"]="$needed"
    CLOSURE_ELF_VERNEED["$path"]="$verneed"
    CLOSURE_ELF_VERDEF["$path"]="$verdef"
    CLOSURE_ELF_EDGES=$((CLOSURE_ELF_EDGES + edges))
    return 0
}

# One object, one reader invocation. The reader is resolved once by the walk, so
# an absent `readelf` is named as the missing input rather than discovered 628
# times as a non-zero status.
closure_elf_read() {
    local path="$1" text="" rc=0

    if [ -z "$CLOSURE_ELF_READER" ]; then
        closure_read_failed "$path" 'readelf did not resolve on PATH, so no object could be read'
        return 1
    fi
    text=$(LC_ALL=C readelf -d -V -- "$path" 2>/dev/null)
    rc=$?
    if [ "$rc" -ne 0 ]; then
        closure_read_failed "$path" "readelf returned $rc over this object"
        return 1
    fi
    if ! closure_elf_parse "$path" "$text"; then
        closure_read_failed "$path" "readelf output this parser cannot read: $CLOSURE_ELF_PARSE_REASON"
        return 1
    fi
    CLOSURE_ELF_PATHS+=("$path")
    CLOSURE_ELF_KIND["$path"]=object
    CLOSURE_ELF_SUBJECTS=$((CLOSURE_ELF_SUBJECTS + 1))
    return 0
}

# ------------------------------------------------------------- the walk itself ---
# THE TRAVERSAL IS AN INPUT LIKE ANY OTHER. A walk that could not reach every
# file did not observe an empty tree, it failed to observe one, and the two are
# told apart here rather than left to whoever reads the counts. The typed result
# is UNDETERMINED naming the root and what the traversal could not do, and it
# makes the run non-passing on its own.
#
# This is not hypothetical and it is not only a stub's behaviour: a directory the
# account cannot read holds its shipped objects out of the listing while `find`
# exits non-zero, and a run that ignored that status printed a green membership
# result over an archive it never opened.
#
# shellcheck disable=SC2034  # the state is written here and read by
# closure_check.sh, which sources this file; shellcheck reads one file at a time
# and cannot see the reader on the other side.
closure_walk_failed() {
    CLOSURE_ELF_WALK_STATE="$2"
    printf '%s|%s|%s|%s\n' UNDETERMINED traversal "$1" "$2"
}

# --------------------------------------------------------------- the one walk ---
# ONE `find` over the tree, and the only one in this checker. Symlinked
# directories are not followed, so an alias such as `current` pointing at a
# version directory yields each shipped file once rather than twice: the two
# paths are two ways to the same object, and a subject is an object.
#
# The listing goes through a temporary file rather than a process substitution,
# because a process substitution discards the exit status of the command inside
# it and that status is the ONLY thing that distinguishes an empty tree from a
# traversal that stopped early. It stays ONE `find` invocation, which is what the
# cost rule bounds; where its output is held is not part of that bound.
#
# A file that cannot be READ is UNDETERMINED and not "not an ELF": whether it is
# an object is exactly what could not be determined, and answering the cheaper
# question would drop it from the subject set for lacking a permission.
# THE TARGET IS RECORDED RAW, exactly as the link carries it, and it is NOT
# joined or reduced here. Reducing `..` before the components before it have been
# expanded is wrong: `..` applies to the directory the resolution actually
# REACHED, and a component earlier in the path may itself be a link that moves
# that directory somewhere else. `providers/x -> ../linkdir/../lib/y` with
# `linkdir` a link is exactly that shape, and reducing it lexically lands
# somewhere the file is not. The resolution belongs to whoever walks the path,
# which is `closure_rules_physical`, and it needs the raw text to do it.

# shellcheck disable=SC2034  # the link map is written here and read by
# closure_rules.sh, which closure_check.sh sources beside this file; shellcheck
# reads one file at a time and cannot see the reader on the other side.
closure_subjects_walk() {
    local root="$1" path listing="" errors="" rc=0 detail="" line link=""

    CLOSURE_ELF_READER=""
    if command -v readelf >/dev/null 2>&1; then CLOSURE_ELF_READER="readelf"; fi

    if [ ! -d "$root" ]; then return 0; fi
    if ! command -v find >/dev/null 2>&1; then
        closure_walk_failed "$root" 'find did not resolve on PATH, so the tree was never walked'
        return 1
    fi
    listing=$(mktemp) || {
        closure_walk_failed "$root" 'no writable temporary file for the walk listing'
        return 1
    }
    errors=$(mktemp) || {
        rm -f -- "$listing"
        closure_walk_failed "$root" 'no writable temporary file for the walk diagnostics'
        return 1
    }
    # ONE INVOCATION, TWO ANSWERS. The regular files are the subjects; the
    # symlinks and where they point are what makes an alias resolvable by lookup
    # later. Each field is printed on its own line, because a path may carry a
    # space and a shared separator would split it.
    find "$root" \( -type f -printf 'F %p\n' \) -o \
                 \( -type l -printf 'L %p\nT %l\n' \) > "$listing" 2> "$errors"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        # The first diagnostic line, so the refusal names the directory rather
        # than only the status. `read` is the shell's own, because the host-tool
        # contract carries no line reader.
        IFS= read -r detail < "$errors" || detail=""
        closure_walk_failed "$root" \
            "find returned $rc, so the walk is incomplete: ${detail:-no diagnostic}"
    fi
    rm -f -- "$errors"

    # WHAT THE WALK DID REACH IS STILL READ. Suppression follows data
    # availability alone, so an incomplete traversal does not throw away the
    # objects it did list; it stops the run counting as a pass.
    while IFS= read -r line; do
        case "$line" in
            'L '*) link="${line#L }"; continue ;;
            'T '*)
                if [ -n "$link" ]; then
                    CLOSURE_LINK_TARGET["$link"]="${line#T }"
                    link=""
                fi
                continue ;;
            'F '*) path="${line#F }" ;;
            *) continue ;;
        esac
        # `walked` counts the FILES the walk reached, which is what every count
        # below it is stated against. A link is a second path to a file already
        # counted, not a second file.
        CLOSURE_ELF_WALKED=$((CLOSURE_ELF_WALKED + 1))
        if [ ! -r "$path" ]; then
            closure_read_failed "$path" 'the file could not be opened for reading here'
            continue
        fi
        if ! closure_elf_is_object "$path"; then
            CLOSURE_ELF_KIND["$path"]=not-elf
            continue
        fi
        closure_elf_read "$path" || true
    done < "$listing"
    rm -f -- "$listing"
}
