#!/bin/bash
# shellcheck disable=SC2317  # every ctl_* body runs only through `control`,
# which invokes it by name, so shellcheck reads them all as unreachable
#
# Step 5 acceptance instrument for the v0.27.0 python-wrapper-foreign-distro
# effort.
#
# WHY THIS IS A SECOND FILE AND NOT A FIFTH SUITE IN THE HARNESS. Step 4 FROZE
# docs/v0.27.0/verify.wrapper-scope.sh and step 4b published its identity, so
# step 5's own criteria forbid editing it: a change there would invalidate the
# manifest the pipeline copy is checked against. The frozen harness dispatches
# steps 0 to 3 and its step 3 suite asserts `rhel 9.8` as its target, so it
# cannot answer this step at all. The acceptance therefore lives beside it,
# reads it, and never writes it.
#
# Usage:
#   bash verify.wrapper-accept.sh --mode accept
#        --fixed-tree PATH --control-tree PATH --throwaway PATH
#        --archive-tree PATH --scratch PATH --run-identity ID
#        [--fixed PATH] [--control PATH]
#
#   bash verify.wrapper-accept.sh --mode identity
#        [--manifest PATH] [--harness PATH] [--fixed PATH] [--control PATH]
#        [--capture PATH]
#
# THE TWO MODES ANSWER THE TWO HALVES OF THE STEP, and neither can answer the
# other's:
#
#   accept    runs on the Debian 12 CI agent, the only distribution the defect
#             exists on. Two freshly deployed trees in one run, the fixed
#             wrapper in one and the retained pre-change wrapper in the other,
#             so a pass cannot be told apart from a pass on a host where the
#             defect never fires.
#
#   identity  runs HERE, in this repository, and needs git. It verifies the
#             manifest's freeze_commit, harness_path and file_sha256 against the
#             canonical harness, and both wrappers against the commits they came
#             from. This is the half a PAIRED pipeline edit cannot restate: the
#             agent has no cplx history, so a copy and its manifest edited in one
#             pipeline commit agree with each other and with nothing else.
#
# THE TWO TREES ARE DEPLOYED BY THE CALLER, NOT HERE, and that is decision Q05's
# companion rule which step 3 already states: a harness that deployed its own
# subject would be measuring an installer run rather than a wrapper, and the
# deployment recipe belongs to the operations note rather than to an oracle.
#
# THAT THEY WERE DEPLOYED AND NOT COPIED IS MEASURED, NOT PROMISED. Code review
# round 1 of this step found the first version materializing two `cp -a` copies
# of one already-deployed tree, which the criterion does not permit and which no
# case here could then have caught. The installer rewrites every ELF to live
# under the prefix it deploys into, so a freshly deployed tree carries its OWN
# root in the interpreter's run path and a copy carries the root it was copied
# from. That difference is the oracle, and it has a control that must FAIL.
#
# Exit codes: 0 the mode's objective is met, 1 at least one case failed, 2 the
# arguments are unusable, 4 this host cannot answer the mode at all. There is no
# softer outcome: a host that cannot answer says so rather than reporting 0 on
# its own account.
#
# Case contract, the one the frozen harness established and this keeps:
#   * a case PLANTS its fixture and asserts the plant, so a case cannot report a
#     shape it never created;
#   * every oracle that matters carries a negative CONTROL that must FAIL, with
#     the required refusal reason named, so a control cannot be satisfied by a
#     different failure than the one it exists to prove;
#   * every claim about the wrapper is measured FROM ITS RUN. Reading its source
#     and asserting what it says is a restatement, not a check.
#
# THE CONTROL'S PROVENANCE IS CHECKED, NOT PRINTED (decision P7). The expected
# commit, path and digest of both wrappers are literals below, they travel with
# this file, and the accept mode verifies them BEFORE the control runs. Those
# commits existed before the copies were made, so they carry no self-reference
# problem. Printing a digest for a reader would defer the comparison instead of
# making it, which is the shape decision Q07 rejected.

set -u

# ----------------------------------------------------------------- arguments ---
MODE=""
FIXED_TREE_ARG=""
CONTROL_TREE_ARG=""
THROWAWAY_ARG=""
ARCHIVE_TREE_ARG=""
SCRATCH_ARG=""
RUN_IDENTITY_ARG=""
FIXED_ARG=""
CONTROL_ARG=""
MANIFEST_ARG=""
HARNESS_ARG=""
CAPTURE_ARG=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --mode) MODE="$2"; shift 2 ;;
        # accept only. The two python env roots the caller freshly deployed for
        # this run, the throwaway root that holds both and that the caller
        # creates and removes, the build's extracted archive which must be left
        # exactly as the later pipeline stages will consume it, this
        # instrument's own working directory, and the run identity the capture
        # cites in its evidence rather than only in its header.
        --fixed-tree) FIXED_TREE_ARG="$2"; shift 2 ;;
        --control-tree) CONTROL_TREE_ARG="$2"; shift 2 ;;
        --throwaway) THROWAWAY_ARG="$2"; shift 2 ;;
        --archive-tree) ARCHIVE_TREE_ARG="$2"; shift 2 ;;
        --scratch) SCRATCH_ARG="$2"; shift 2 ;;
        --run-identity) RUN_IDENTITY_ARG="$2"; shift 2 ;;
        # Both modes. The two wrapper bodies, named because the agent holds
        # verification-only copies under different names and no cplx history.
        --fixed) FIXED_ARG="$2"; shift 2 ;;
        --control) CONTROL_ARG="$2"; shift 2 ;;
        # identity only. The step 4b manifest, the frozen harness it describes,
        # and the retained agent capture to admit as evidence.
        --manifest) MANIFEST_ARG="$2"; shift 2 ;;
        --harness) HARNESS_ARG="$2"; shift 2 ;;
        --capture) CAPTURE_ARG="$2"; shift 2 ;;
        -h|--help) sed -n '4,74p' "$0"; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

case "$MODE" in
    accept|identity) ;;
    *) echo "--mode must be 'accept' or 'identity', got [$MODE]" >&2
       echo "accept runs on the Debian agent; identity runs in this repository." >&2
       exit 2 ;;
esac

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
FIXED="${FIXED_ARG:-$here/../../src/install/env/python/bin/python}"
CONTROL="${CONTROL_ARG:-$here/wrapper.pre-change.verification-only}"
MANIFEST="${MANIFEST_ARG:-$here/verify.wrapper-scope.manifest.txt}"
HARNESS="${HARNESS_ARG:-$here/verify.wrapper-scope.sh}"

[ -f "$FIXED" ]   || { echo "fixed wrapper not found: $FIXED" >&2; exit 2; }
[ -f "$CONTROL" ] || { echo "control wrapper not found: $CONTROL" >&2; exit 2; }

# ------------------------------------------------------------- the provenance ---
# The literals the accept mode verifies before it runs anything, and the
# identity mode verifies against git. They are the whole of decision P7: a
# retained copy whose provenance is unchecked proves only that some file was
# read, which is the finding code review round 2 of this effort demonstrated.
CONTROL_COMMIT="a665f4fc201095a31e9e88b8ad51e2a0075d74fa"
CONTROL_PATH="src/install/env/python/bin/python"
CONTROL_SHA256="88c4e0d22207b387b6b0d24542ba5301164e01f6cc698c02945722493b7f5706"

FIXED_COMMIT="c5764088b4c2d682794cbafc2dfb471f107e8bcd"
FIXED_PATH="src/install/env/python/bin/python"
FIXED_SHA256="7213dfe03d0870ca1111a44a50145b9a39e987afe409893688d48e8925616c58"

# ----------------------------------------------------------------- reporting ---
cases=0
failures=0
EXPECT_FAIL=0
CTL_REASON=""

# The detail is appended only when there IS one: `PASS  %s` with an empty detail
# emits two trailing spaces on every such line, which reaches the retained
# capture and makes `git diff --cached --check` report the evidence as dirty.
pass() { printf '  %-46s PASS%s\n' "$1" "${2:+  $2}"; }
# In a negative control the failure IS the expected result, so it is captured
# rather than printed: a log a reader scans for FAIL must not show one the next
# line contradicts. Only the control helper sets this flag, and it always clears
# it, so no early return leaves this suite deaf to a real failure.
fail() {
    if [ "$EXPECT_FAIL" -eq 1 ]; then CTL_REASON="${2:-}"; return 0; fi
    printf '  %-46s FAIL%s\n' "$1" "${2:+  $2}"
    failures=$((failures + 1))
}
chk() {
    cases=$((cases + 1))
    if [ "$2" = "$3" ]; then pass "$1" "$3"; else fail "$1" "want [$2] got [$3]"; fi
}
note() { printf '  %-46s NOTE%s\n' "$1" "${2:+  $2}"; }
section() { printf '\n== %s\n' "$1"; }

# control <name> <required-reason-prefix> <command...>
# The reason prefix is the point: a control demanding only a failure would be
# satisfied by a different failure than the one it exists to prove. Inner case
# counting is rolled back so a control is exactly one case either way.
control() {
    local name="$1" want="$2"; shift 2
    local saved="$cases"
    EXPECT_FAIL=1; CTL_REASON=""
    "$@" >/dev/null 2>&1
    EXPECT_FAIL=0
    cases=$((saved + 1))
    case "$CTL_REASON" in
        "$want"*) pass "$name" "refused on [$want], as designed" ;;
        "")       fail "$name" "passed, so that oracle is not asserted" ;;
        *)        fail "$name" "refused for the wrong reason: $CTL_REASON" ;;
    esac
}

# ------------------------------------------------------ prerequisite preflight ---
# Resolve, check, THEN declare. A combined `readonly VAR="$(type -P x)"` yields
# the exit status of readonly rather than of the substitution, so a failed
# resolution is masked and the variable is frozen empty: shellcheck reports that
# form under SC2155.
#
# The resolved path is returned through a NAMED VARIABLE rather than on stdout,
# so the gate can trip: printing it and calling this in a command substitution
# would run the whole function in a subshell and PREFLIGHT_OK=0 would never
# reach the parent. A check whose failure path cannot be observed is not a check.
PREFLIGHT_OK=1
PREFLIGHT_PATH=""
preflight_tool() {
    local label="$1" resolved=""
    PREFLIGHT_PATH=""
    resolved=$(type -P "$label" 2>/dev/null) || resolved=""
    if [ -z "$resolved" ]; then
        fail "preflight/$label" "PREFLIGHT unresolved: type -P found nothing"
        PREFLIGHT_OK=0
        return 1
    fi
    if [ ! -x "$resolved" ]; then
        fail "preflight/$label" "PREFLIGHT not executable: $resolved"
        PREFLIGHT_OK=0
        return 1
    fi
    PREFLIGHT_PATH="$resolved"
    pass "preflight/$label" "$resolved"
    cases=$((cases + 1))
}

section "acceptance prerequisite preflight"
SHA256SUM_BIN=""
TOOLS=(sha256sum cp rm readlink od head)
# `readelf` reads the deployed interpreter's run path, which is how this
# instrument tells a freshly deployed tree from a copied one. The identity mode
# reads no ELF and needs git instead.
[ "$MODE" = "accept" ] && TOOLS+=(readelf)
[ "$MODE" = "identity" ] && TOOLS+=(git)
for _t in "${TOOLS[@]}"; do
    if preflight_tool "$_t" && [ "$_t" = "sha256sum" ]; then
        SHA256SUM_BIN="$PREFLIGHT_PATH"
    fi
done
if [ "$PREFLIGHT_OK" -ne 1 ]; then
    printf '\nOBJECTIVE NOT MET for step 5 (%s): the preflight could not resolve a tool\n' "$MODE"
    exit 1
fi

digest_of() { "$SHA256SUM_BIN" "$1" | cut -d' ' -f1; }

# This file's own identity, printed in the verdict so a retained capture carries
# the bytes that produced it. The identity mode asserts the value an agent
# capture recorded against the canonical file here, which is how a capture taken
# by a copy is bound to the original.
ACCEPT_SHA256=$(digest_of "${BASH_SOURCE[0]}")
FIXED_ACTUAL=$(digest_of "$FIXED")
CONTROL_ACTUAL=$(digest_of "$CONTROL")

# --------------------------------------------------------- the provenance gate ---
# assert_provenance <name> <label> <expected> <actual>
# Named as a function rather than written inline at each site because the
# CONTROL below has to run the SAME code against mutated bytes. A gate whose
# control exercises a copy of it proves the copy.
assert_provenance() {
    local name="$1" label="$2" want="$3" got="$4"
    if [ "$want" != "$got" ]; then
        fail "$name" "PROVENANCE $label names [$want], these bytes are [$got]"
        return 1
    fi
    cases=$((cases + 1))
    pass "$name" "$got"
    return 0
}

ctl_wrong_control_bytes() {
    local mutated="$SCRATCH/mutated-control-wrapper"
    { cat "$CONTROL"; echo '# an edit no named commit describes'; } > "$mutated"
    assert_provenance "step5/control-wrapper/bytes" "$CONTROL_COMMIT:$CONTROL_PATH" \
        "$CONTROL_SHA256" "$(digest_of "$mutated")"
}

# ==============================================================================
# accept: the Debian acceptance
# ==============================================================================

# A stable text signature of the two directories the wrapper's surgery touches,
# used before and after to say the build's extracted archive was left alone.
# Symlink targets are part of it: the whole defect is a symlink rewritten from an
# empty string, so a signature that compared names only would call the mangling
# no change.
tree_signature() {
    local root="$1" d f
    for d in bin current/bin; do
        [ -d "$root/$d" ] || { printf '%s ABSENT\n' "$d"; continue; }
        for f in "$root/$d"/*; do
            [ -e "$f" ] || [ -L "$f" ] || continue
            if [ -L "$f" ]; then
                printf '%s -> %s\n' "${f#"$root"/}" "$(readlink "$f")"
            else
                printf '%s\n' "${f#"$root"/}"
            fi
        done
    done | sort
}

# The entry names of one directory, on one line. `ls` is not used: shellcheck
# reports it under SC2012 and a glob loop answers the same question without
# parsing an output format.
dir_names() {
    local d="$1" f out=""
    for f in "$d"/*; do
        [ -e "$f" ] || [ -L "$f" ] || continue
        out="${out:+$out }${f##*/}"
    done
    printf '%s\n' "$out"
}

is_an_elf() {
    [ -f "$1" ] || { echo no; return 0; }
    head -c 4 "$1" 2>/dev/null | od -An -tx1 | tr -d ' \n' \
        | grep -q '^7f454c46' && echo yes || echo no
}

# The real interpreter of a deployed tree, read the way the wrapper reads it:
# through `python3_target`, which a deployed tree ships already pointing at the
# real binary.
interpreter_of() {
    local tree="$1" target
    target=$(readlink "$tree/current/bin/python3_target" 2>/dev/null) || return 1
    [ -n "$target" ] || return 1
    printf '%s\n' "$tree/current/bin/$target"
}

# The run path the installer wrote into an ELF. RPATH and RUNPATH are the same
# question here and `readelf` labels them `rpath` and `runpath`, so one
# expression reads either.
rpath_of() {
    readelf -d "$1" 2>/dev/null \
        | sed -n 's/.*Library r\(un\)\?path: \[\(.*\)\]/\2/p' | head -1
}

# assert_deployed_for_root <name> <tree> <claimed-root>
# THE ORACLE THAT TELLS A DEPLOYMENT FROM A COPY, and the finding of code review
# round 1 in one function. The installer rewrites every ELF to live under the
# prefix it deploys into, so a tree deployed into <claimed-root> carries that
# root in its interpreter's run path, and a `cp -a` of a tree deployed elsewhere
# carries the other root instead. A copy is therefore refused by the same code
# that admits a deployment, rather than by a promise in a comment.
assert_deployed_for_root() {
    local name="$1" tree="$2" root="$3" interp rp
    interp=$(interpreter_of "$tree") || {
        fail "$name" "DEPLOYED no python3_target in $tree, so no interpreter to read"
        return 1
    }
    rp=$(rpath_of "$interp")
    if [ -z "$rp" ]; then
        fail "$name" "DEPLOYED the interpreter of $tree carries no run path to read"
        return 1
    fi
    case ":$rp:" in
        *":$root/"*) ;;
        *) fail "$name" "DEPLOYED run path names [$rp], not a deployment into [$root]"
           return 1 ;;
    esac
    cases=$((cases + 1))
    pass "$name" "run path names its own root"
    return 0
}

# The control for that oracle. It hands the FIXED tree to the predicate while
# claiming the CONTROL tree's root, which is exactly the shape a copy has: a
# real tree whose ELFs were written for somewhere else. If this passes, the
# oracle would admit a copy and the finding it exists to close is still open.
ctl_tree_deployed_elsewhere() {
    assert_deployed_for_root "step5/tree/deployed-for-its-own-root" \
        "$FIXED_TREE_ARG" "$CONTROL_TREE_ARG"
}

# assert_tree_planted <name> <root>
# The plant assertion, and the reason it is a function: the negative control
# runs it against an UNPLANTED directory and requires the refusal. Without that
# control a suite that blesses anything would report a green over a tree it
# never built, which is the failure mode this whole umbrella exists to refuse.
assert_tree_planted() {
    local name="$1" root="$2" missing=""
    local want="bin/python bin/setenv current/bin/python3"
    local p
    for p in $want; do
        [ -e "$root/$p" ] || [ -L "$root/$p" ] || missing="${missing:+$missing }$p"
    done
    if [ -n "$missing" ]; then
        fail "$name" "FIXTURE missing from the deployed tree: $missing"
        return 1
    fi
    cases=$((cases + 1))
    pass "$name" "deployed and asserted"
    return 0
}

ctl_unplanted_tree() {
    local empty="$SCRATCH/unplanted"
    mkdir -p -- "$empty"
    assert_tree_planted "step5/tree/planted" "$empty"
}

# One first call through a deployed tree, with three deliberate choices in its
# environment:
#
#   HOME is pinned to the scratch root so that anything the interpreter or its
#   startup writes there lands under the one root this step claims every write
#   lands under, rather than in the build account's home. Neither the wrapper nor
#   `setenv` reads HOME itself; the pin is about the claim, not about them.
#
#   LD_LIBRARY_PATH and VIRTUAL_ENV are cleared FROM THE CALLER, so the run
#   measures what the wrapper does with them rather than what the build left
#   behind. An inherited VIRTUAL_ENV would send the call down the other exec arm
#   entirely.
#
#   P_DBG is set so the wrapper's own debug trace names the paths it derives.
#   That trace is the whole observable of the control on this distribution: the
#   helpers die, so the mangling shows as the path the wrapper COMPUTED rather
#   than as a file it managed to create.
CALL_STATUS=0
first_call() {
    local tree="$1" out="$2"
    CALL_STATUS=0
    ( cd "$SCRATCH" \
      && env -u LD_LIBRARY_PATH -u VIRTUAL_ENV HOME="$SCRATCH" P_DBG=1 \
             "$tree/bin/python" --version ) > "$out" 2>&1 || CALL_STATUS=$?
    return 0
}

answers_a_version() {
    grep -qE '^Python 3\.[0-9]+\.[0-9]+' "$1" && echo yes || echo no
}

accept_suite() {
    section "step 5 identity: which run, which agent, which shell"

    # CITED IN THE EVIDENCE rather than only in the header, the idiom step 3
    # established: the throwaway root has to carry the run identity, so a
    # capture cannot report a run it did not measure. The distribution is read
    # from /etc/os-release and never from `uname`, which names the RHEL host
    # kernel this Debian container shares.
    note "step5/identity/run" "$RUN_IDENTITY_ARG"
    chk "step5/identity/throwaway-carries-run-id" "yes" \
        "$(case "$THROWAWAY_ARG" in *"$RUN_IDENTITY_ARG"*) echo yes ;; *) echo no ;; esac)"
    # shellcheck disable=SC1091  # /etc/os-release exists on the host that can
    # answer this step; the guarded expansions carry the case where it is not.
    chk "step5/identity/target" "debian 12" \
        "$( . /etc/os-release 2>/dev/null; echo "${ID:-unknown} ${VERSION_ID:-unknown}" )"
    note "step5/identity/kernel" "$(uname -r)   # the RHEL host kernel, shared by the container"
    note "step5/identity/glibc" "$(ldd --version 2>/dev/null | head -1)"
    note "step5/identity/bash" "$BASH_VERSION"

    section "step 5 provenance: both wrappers, before either of them runs"

    # THE GATE THE CONTROL DEPENDS ON. A control whose bytes nobody checked
    # cannot distinguish the defect from a broken copy, which is why option B1
    # was rejected: a reconstructed pre-change wrapper fails for reasons
    # indistinguishable from the one it should show.
    note "step5/control-wrapper/named-commit" "$CONTROL_COMMIT"
    note "step5/control-wrapper/named-path" "$CONTROL_PATH"
    assert_provenance "step5/control-wrapper/bytes" "$CONTROL_COMMIT:$CONTROL_PATH" \
        "$CONTROL_SHA256" "$CONTROL_ACTUAL" || PROVENANCE_OK=0
    note "step5/fixed-wrapper/named-commit" "$FIXED_COMMIT"
    assert_provenance "step5/fixed-wrapper/bytes" "$FIXED_COMMIT:$FIXED_PATH" \
        "$FIXED_SHA256" "$FIXED_ACTUAL" || PROVENANCE_OK=0
    control "step5/control/wrong-control-bytes-refused" "PROVENANCE" \
        ctl_wrong_control_bytes

    if [ "$PROVENANCE_OK" -ne 1 ]; then
        note "step5/provenance/why-nothing-ran" \
             "a wrapper body does not match the commit it is bound to, so neither tree was run"
        return 0
    fi

    section "step 5 two freshly deployed trees, both created for this run"

    # FRESH DEPLOYMENTS, NOT COPIES, and asserted rather than described. Code
    # review round 1 found the first version copying one deployed tree twice,
    # which the completion criterion does not permit. Each tree's interpreter
    # must carry ITS OWN root in its run path, which only the installer writing
    # that tree produces.
    assert_tree_planted "step5/fixed/tree-deployed" "$FIXED_TREE_ARG"
    assert_tree_planted "step5/control/tree-deployed" "$CONTROL_TREE_ARG"
    control "step5/control/unplanted-tree-refused" "FIXTURE" ctl_unplanted_tree
    note "step5/fixed/interpreter-run-path" "$(rpath_of "$(interpreter_of "$FIXED_TREE_ARG")")"
    assert_deployed_for_root "step5/fixed/deployed-for-its-own-root" \
        "$FIXED_TREE_ARG" "$FIXED_TREE_ARG"
    assert_deployed_for_root "step5/control/deployed-for-its-own-root" \
        "$CONTROL_TREE_ARG" "$CONTROL_TREE_ARG"
    control "step5/control/tree-deployed-elsewhere-refused" "DEPLOYED" \
        ctl_tree_deployed_elsewhere

    # ISOLATED FROM EACH OTHER AND FROM THE ARCHIVE. Three distinct inodes says
    # the two trees and the build's archive are three separate files rather than
    # names for one, so the control's surgery cannot reach either of the others.
    chk "step5/trees/are-independent" "3" \
        "$( { stat -c %i "$ARCHIVE_TREE_ARG/bin/python" "$FIXED_TREE_ARG/bin/python" \
                         "$CONTROL_TREE_ARG/bin/python" 2>/dev/null; } \
            | sort -u | grep -c . )"
    # EVERY WRITE UNDER ONE THROWAWAY ROOT, which the caller creates and removes.
    chk "step5/trees/fixed-under-the-throwaway-root" "yes" \
        "$(case "$FIXED_TREE_ARG/" in "$THROWAWAY_ARG"/*) echo yes ;; *) echo no ;; esac)"
    chk "step5/trees/control-under-the-throwaway-root" "yes" \
        "$(case "$CONTROL_TREE_ARG/" in "$THROWAWAY_ARG"/*) echo yes ;; *) echo no ;; esac)"
    chk "step5/trees/archive-outside-the-throwaway-root" "yes" \
        "$(case "$ARCHIVE_TREE_ARG/" in "$THROWAWAY_ARG"/*) echo no ;; *) echo yes ;; esac)"
    chk "step5/scratch/under-the-throwaway-root" "yes" \
        "$(case "$SCRATCH/" in "$THROWAWAY_ARG"/*) echo yes ;; *) echo no ;; esac)"

    section "step 5 the build's extracted archive, recorded before anything runs"

    note "step5/archive/path" "$ARCHIVE_TREE_ARG"
    ARCHIVE_WRAPPER_BEFORE=$(digest_of "$ARCHIVE_TREE_ARG/bin/python")
    # RECORDED, NOT ASSERTED. The published archive predates the fix, so the
    # wrapper it ships may well BE the retained pre-change body; asserting the
    # archive wrapper is neither of the two under test would fail on a tree that
    # is exactly what this step expects to find.
    note "step5/archive/wrapper-sha256" "$ARCHIVE_WRAPPER_BEFORE"
    note "step5/archive/wrapper-is-the-pre-change-body" \
         "$( [ "$ARCHIVE_WRAPPER_BEFORE" = "$CONTROL_SHA256" ] && echo yes || echo no )"
    ARCHIVE_BEFORE=$(tree_signature "$ARCHIVE_TREE_ARG")

    section "step 5 the wrapper under test, installed into each tree"

    cp "$FIXED" "$FIXED_TREE_ARG/bin/python"
    cp "$CONTROL" "$CONTROL_TREE_ARG/bin/python"
    chmod +x "$FIXED_TREE_ARG/bin/python" "$CONTROL_TREE_ARG/bin/python"
    # THE WRAPPER UNDER TEST IS THE ONE IN THE TREE, asserted by digest. Without
    # this the step could measure the wrapper the archive carries and report the
    # change working while the change was never installed.
    chk "step5/fixed/tree-carries-the-fixed-wrapper" "$FIXED_SHA256" \
        "$(digest_of "$FIXED_TREE_ARG/bin/python")"
    chk "step5/control/tree-carries-the-retained-wrapper" "$CONTROL_SHA256" \
        "$(digest_of "$CONTROL_TREE_ARG/bin/python")"
    # `setenv` is the file that exports the shipped search path, so a tree whose
    # deployment lost it would fail the control for the wrong reason.
    chk "step5/fixed/setenv-present" "yes" \
        "$( [ -f "$FIXED_TREE_ARG/bin/setenv" ] && echo yes || echo no )"
    chk "step5/control/setenv-present" "yes" \
        "$( [ -f "$CONTROL_TREE_ARG/bin/setenv" ] && echo yes || echo no )"

    section "step 5 THE ACCEPTANCE: the first call over the fixed tree"

    local fixed_out="$SCRATCH/fixed-first-call.out"
    first_call "$FIXED_TREE_ARG" "$fixed_out"
    FIXED_ANSWERS=$(answers_a_version "$fixed_out")
    chk "step5/fixed/exit-status" "0" "$CALL_STATUS"
    chk "step5/fixed/answers-a-version" "yes" "$FIXED_ANSWERS"
    note "step5/fixed/version" "$(grep -m1 -E '^Python ' "$fixed_out" || true)"
    # The end shape the plan names, read back from the tree the call left.
    chk "step5/fixed/python3-is-the-wrapper" "../../bin/python" \
        "$(readlink "$FIXED_TREE_ARG/current/bin/python3" 2>/dev/null)"
    FIXED_TARGET=$(readlink "$FIXED_TREE_ARG/current/bin/python3_target" 2>/dev/null)
    note "step5/fixed/python3_target-name" "$FIXED_TARGET"
    chk "step5/fixed/python3_target-not-derived-from-empty" "no" \
        "$( [ "$FIXED_TARGET" = "_bin" ] && echo yes || echo no )"
    chk "step5/fixed/real-interpreter-beside-it" "yes" \
        "$( [ -f "$FIXED_TREE_ARG/current/bin/$FIXED_TARGET" ] && echo yes || echo no )"
    # THE REAL ARCHIVE INTERPRETER, not a stub. Steps 0 to 2 measure a recording
    # shell stub; this asserts an ELF, which is what makes the answer above an
    # answer from the toolchain rather than from a fixture.
    chk "step5/fixed/real-interpreter-is-an-elf" "yes" \
        "$(is_an_elf "$FIXED_TREE_ARG/current/bin/$FIXED_TARGET")"
    chk "step5/fixed/no-empty-derived-path" "no" \
        "$( [ -e "$FIXED_TREE_ARG/current/bin/_bin" ] && echo yes || echo no )"
    chk "step5/fixed/no-empty-derived-path-in-the-run" "no" \
        "$(grep -q 'current/bin/_bin' "$fixed_out" && echo yes || echo no)"

    section "step 5 THE CONTROL: the same call over the pre-change wrapper"

    local control_out="$SCRATCH/control-first-call.out"
    first_call "$CONTROL_TREE_ARG" "$control_out"
    CONTROL_ANSWERS=$(answers_a_version "$control_out")
    CONTROL_STATUS="$CALL_STATUS"
    chk "step5/control/answers-a-version" "no" "$CONTROL_ANSWERS"
    # THE MANGLING, and what form it takes on THIS distribution. Step 0 run B
    # planted a failing readlink on a host whose other helpers worked, so `_bin`
    # appeared there as a symlink target. Here every post-source helper binds the
    # shipped libc and dies, so nothing is created at all and the mangling shows
    # as the path the wrapper DERIVED from an empty read. Both are the same
    # defect, and step 0's own capture already recorded `current/bin/_bin` as a
    # dangling referent rather than as a file.
    chk "step5/control/derives-the-empty-path" "yes" \
        "$(grep -q 'current/bin/_bin' "$control_out" && echo yes || echo no)"
    chk "step5/control/interpreter-never-reached" "no" "$CONTROL_ANSWERS"
    note "step5/control/exit-status" "$CONTROL_STATUS"
    note "step5/control/matches-step0-silent-zero" \
         "$( [ "$CONTROL_STATUS" = "0" ] && echo yes || echo "no, this run exited $CONTROL_STATUS" )"
    note "step5/control/first-helper-failure" \
         "$(grep -m1 -iE 'glibc|version .* not found|relocation error|symbol lookup' "$control_out" || echo none-recorded)"
    # The quote is excluded from the match because the wrapper's own debug trace
    # quotes the path it derived, and a recorded value that carries the quoting
    # of the line it came from is a transcript rather than a path.
    note "step5/control/derived-exec-path" \
         "$(grep -m1 -oE "[^ ']*current/bin/_bin" "$control_out" || echo none-recorded)"
    note "step5/control/tree-shape" "$(dir_names "$CONTROL_TREE_ARG/current/bin")"
    note "step5/fixed/tree-shape" "$(dir_names "$FIXED_TREE_ARG/current/bin")"

    section "step 5 the discriminator, which is the whole point of the step"

    # THIS IS THE CASE THE STEP EXISTS FOR. Either half alone proves nothing: a
    # fixed tree that answers could be answering on a host where the defect
    # never fires, and a control that mangles could be mangling for a reason the
    # fix does not address. The two together, in one run on one agent, are the
    # only measurement that tells a working fix from a plausible one.
    chk "step5/acceptance/fixed-answers-and-control-does-not" "yes:no" \
        "$FIXED_ANSWERS:$CONTROL_ANSWERS"

    section "step 5 the extracted archive, left as the later stages consume it"

    chk "step5/archive/signature-unchanged" "yes" \
        "$( [ "$ARCHIVE_BEFORE" = "$(tree_signature "$ARCHIVE_TREE_ARG")" ] && echo yes || echo no )"
    chk "step5/archive/wrapper-unchanged" "$ARCHIVE_WRAPPER_BEFORE" \
        "$(digest_of "$ARCHIVE_TREE_ARG/bin/python")"
    note "step5/throwaway/root" "$THROWAWAY_ARG"
    note "step5/throwaway/size" "$(du -sh "$THROWAWAY_ARG" 2>/dev/null | cut -f1)"
}

# ==============================================================================
# identity: the comparison the agent cannot make
# ==============================================================================

# THE MANIFEST CHECK, and the only reason the manifest is worth having. It is a
# function because the CONTROL below runs it against a mutated manifest and
# requires the refusal: a gate nobody has seen fail is a gate nobody has seen,
# and that finding is one of the six this effort's rounds kept producing.
assert_manifest_identity() {
    local name="$1" file="$2" freeze hpath expected got
    freeze=$(awk '$1 == "freeze_commit" { print $2 }' "$file")
    hpath=$(awk '$1 == "harness_path" { print $2 }' "$file")
    expected=$(awk '$1 == "file_sha256" { print $2 }' "$file")
    if [ -z "$freeze" ] || [ -z "$hpath" ] || [ -z "$expected" ]; then
        fail "$name" "MANIFEST incomplete: freeze_commit, harness_path and file_sha256 are all required"
        return 1
    fi
    got=$(git show "$freeze:$hpath" 2>/dev/null | "$SHA256SUM_BIN" | cut -d' ' -f1)
    if [ "$got" != "$expected" ]; then
        fail "$name" "MANIFEST says [$expected], $freeze:$hpath is [$got]"
        return 1
    fi
    cases=$((cases + 1))
    pass "$name" "$got"
    return 0
}

ctl_mutated_manifest() {
    local mutated="$SCRATCH/mutated-manifest.txt"
    sed 's/^\(file_sha256 \).*/\10000000000000000000000000000000000000000000000000000000000000000/' \
        "$MANIFEST" > "$mutated"
    assert_manifest_identity "identity/manifest/harness-at-freeze-commit" "$mutated"
}

# The capture check. A capture is admitted as evidence only when the digests it
# records name the files this repository holds, which is the second half the
# frozen harness's own capture binding taught this effort: bound to its
# instrument only, a capture certifies a run over inputs nobody compared.
assert_capture_identity() {
    local name="$1" file="$2" field="$3" want="$4" got
    # EVERY occurrence, collapsed. A retained capture carries more than one
    # verdict block: the acceptance run and, beside it, the control run on the
    # host where the defect cannot fire, which is what makes the acceptance mean
    # anything. Reading only the first would let a second block name a different
    # instrument unnoticed, and reading them concatenated would fail on a file
    # where they agree. Collapsed, agreement yields the one value and any
    # disagreement yields a compound one that cannot match.
    got=$(awk -v f="$field" '$1 == f { print $2 }' "$file" \
          | sort -u | tr '\n' ' ' | sed 's/ $//')
    if [ "$got" != "$want" ]; then
        fail "$name" "CAPTUREID capture's $field is [$got], this repository holds [$want]"
        return 1
    fi
    cases=$((cases + 1))
    pass "$name" "$got"
    return 0
}

ctl_mutated_capture() {
    local mutated="$SCRATCH/mutated-capture.txt"
    # THE LEADING WHITESPACE IS NOT COSMETIC. A capture writes its verdict block
    # indented, so an anchored `^accept-script-sha256` matched nothing and this
    # control mutated NOTHING: the "mutated" copy was byte-identical, the gate
    # accepted it, and the control reported that the oracle was not asserted.
    # It was written that way and this run found it, which is the whole reason a
    # gate carries a control at all.
    sed 's/^\([[:space:]]*accept-script-sha256 \).*/\10000000000000000000000000000000000000000000000000000000000000000/' \
        "$CAPTURE_ARG" > "$mutated"
    assert_capture_identity "identity/capture/accept-script" "$mutated" \
        "accept-script-sha256" "$ACCEPT_SHA256"
}

identity_suite() {
    section "step 5 identity: the manifest against the canonical harness"

    # THE HALF A PAIRED PIPELINE EDIT CANNOT RESTATE. The agent has no cplx
    # history, so its copy and its manifest copy edited in one commit agree with
    # each other and with nothing else. This comparison is performed in a
    # repository that edit cannot reach, which is decision P10 and the reason
    # option G1 was rejected.
    note "identity/manifest/path" "$MANIFEST"
    note "identity/manifest/freeze-commit" \
         "$(awk '$1 == "freeze_commit" { print $2 }' "$MANIFEST")"
    note "identity/manifest/harness-path" \
         "$(awk '$1 == "harness_path" { print $2 }' "$MANIFEST")"
    assert_manifest_identity "identity/manifest/harness-at-freeze-commit" "$MANIFEST"
    control "identity/control/mutated-manifest-refused" "MANIFEST" ctl_mutated_manifest
    # The working tree's harness must still BE the frozen one. The check above
    # says the freeze commit holds those bytes; this says the file a reader runs
    # today is the same file, so step 5 has not modified the harness.
    chk "identity/harness/canonical-file-is-still-frozen" \
        "$(awk '$1 == "file_sha256" { print $2 }' "$MANIFEST")" \
        "$(digest_of "$HARNESS")"

    section "step 5 identity: both wrappers against the commits they came from"

    assert_provenance "identity/control-wrapper/at-named-commit" \
        "$CONTROL_COMMIT:$CONTROL_PATH" "$CONTROL_SHA256" \
        "$(git show "$CONTROL_COMMIT:$CONTROL_PATH" 2>/dev/null | "$SHA256SUM_BIN" | cut -d' ' -f1)"
    assert_provenance "identity/control-wrapper/retained-copy" \
        "$CONTROL_COMMIT:$CONTROL_PATH" "$CONTROL_SHA256" "$CONTROL_ACTUAL"
    assert_provenance "identity/fixed-wrapper/at-named-commit" \
        "$FIXED_COMMIT:$FIXED_PATH" "$FIXED_SHA256" \
        "$(git show "$FIXED_COMMIT:$FIXED_PATH" 2>/dev/null | "$SHA256SUM_BIN" | cut -d' ' -f1)"
    assert_provenance "identity/fixed-wrapper/live-file" \
        "$FIXED_COMMIT:$FIXED_PATH" "$FIXED_SHA256" "$FIXED_ACTUAL"
    control "identity/control/wrong-control-bytes-refused" "PROVENANCE" \
        ctl_wrong_control_bytes

    section "step 5 identity: the retained capture, before it is accepted"

    if [ -z "$CAPTURE_ARG" ]; then
        note "identity/capture/none-supplied" \
             "no --capture given, so nothing was admitted as evidence by this run"
        return 0
    fi
    [ -f "$CAPTURE_ARG" ] || { fail "identity/capture/present" "not found: $CAPTURE_ARG"; return 0; }
    note "identity/capture/path" "$CAPTURE_ARG"
    assert_capture_identity "identity/capture/accept-script" "$CAPTURE_ARG" \
        "accept-script-sha256" "$ACCEPT_SHA256"
    assert_capture_identity "identity/capture/fixed-wrapper" "$CAPTURE_ARG" \
        "fixed-wrapper-sha256" "$FIXED_SHA256"
    assert_capture_identity "identity/capture/control-wrapper" "$CAPTURE_ARG" \
        "control-wrapper-sha256" "$CONTROL_SHA256"
    control "identity/control/mutated-capture-refused" "CAPTUREID" ctl_mutated_capture
    chk "identity/capture/reports-the-objective-met" "1" \
        "$(grep -c '^OBJECTIVE MET for step 5 (accept)' "$CAPTURE_ARG" || true)"
    chk "identity/capture/reports-the-discriminator" "1" \
        "$(grep -c 'step5/acceptance/fixed-answers-and-control-does-not *PASS' "$CAPTURE_ARG" || true)"
    # THE FRESH-DEPLOYMENT EVIDENCE, admitted here and not only on the agent.
    # Code review round 1 of this step accepted a capture that proved copies, so
    # the capture must now carry both deployment cases and the control that
    # refuses a tree deployed elsewhere.
    #
    # ASKED AS THREE PRESENCE QUESTIONS AND NOT AS ONE COUNT. The first form
    # counted every line naming those cases and expected three, which the
    # capture's own header broke by naming them in its prose, and which would
    # have broken again on any file carrying a different number of measured
    # blocks. A count over free text is not an oracle. Each case is asked for by
    # name, matched only where a PASS follows it, so prose cannot answer for a
    # measurement and a second block cannot make the answer wrong.
    chk "identity/capture/reports-the-fixed-tree-deployed" "yes" \
        "$(grep -qE 'step5/fixed/deployed-for-its-own-root +PASS' "$CAPTURE_ARG" \
           && echo yes || echo no)"
    chk "identity/capture/reports-the-control-tree-deployed" "yes" \
        "$(grep -qE 'step5/control/deployed-for-its-own-root +PASS' "$CAPTURE_ARG" \
           && echo yes || echo no)"
    chk "identity/capture/reports-a-copy-refused" "yes" \
        "$(grep -qE 'step5/control/tree-deployed-elsewhere-refused +PASS' "$CAPTURE_ARG" \
           && echo yes || echo no)"
}

# ==============================================================================
# the run
# ==============================================================================

SCRATCH=""
PROVENANCE_OK=1
ARCHIVE_BEFORE=""
ARCHIVE_WRAPPER_BEFORE=""
FIXED_ANSWERS=""
CONTROL_ANSWERS=""
CONTROL_STATUS=""
FIXED_TARGET=""
HOSTGATE_UNANSWERED=0
OWN_SCRATCH=0

cleanup() { [ "$OWN_SCRATCH" -eq 1 ] && [ -n "$SCRATCH" ] && rm -rf -- "$SCRATCH" 2>/dev/null; }

if [ "$MODE" = "accept" ]; then
    # THE HOST GATE for the acceptance, and it asks for more than a POSIX shell.
    # What this mode cannot reproduce is TWO FRESH DEPLOYMENTS of the archive on
    # a foreign distribution. It does not make them itself, by the same rule
    # step 3 states: a harness that deployed its own subject would be measuring
    # an installer run rather than a wrapper. A host that is handed none answers
    # nothing here, and says so rather than reporting 0 on its own account.
    section "step 5 host gate: are two deployed trees named for this run"

    HAVE_TREES=0
    if [ -n "$FIXED_TREE_ARG" ] && [ -d "$FIXED_TREE_ARG" ] \
       && [ -n "$CONTROL_TREE_ARG" ] && [ -d "$CONTROL_TREE_ARG" ] \
       && [ -n "$ARCHIVE_TREE_ARG" ] && [ -d "$ARCHIVE_TREE_ARG" ] \
       && [ -n "$THROWAWAY_ARG" ] && [ -n "$SCRATCH_ARG" ] \
       && [ -n "$RUN_IDENTITY_ARG" ]; then
        HAVE_TREES=1
    fi
    cases=$((cases + 1))
    pass "step5/host/deployments-supplied" \
        "$( [ "$HAVE_TREES" -eq 1 ] && echo yes || echo no )"

    if [ "$HAVE_TREES" -eq 1 ]; then
        SCRATCH="$SCRATCH_ARG"
        mkdir -p -- "$SCRATCH" || { echo "cannot create scratch: $SCRATCH" >&2; exit 2; }
        accept_suite
    else
        note "step5/host/why" \
             "no deployed trees supplied, so the foreign-distribution first call is not reproducible here"
        HOSTGATE_UNANSWERED=1
    fi
else
    # The identity mode needs no deployment and no symlink: it compares digests
    # against git, which is exactly why it belongs on the authoring host and not
    # on the agent. Its scratch is its own, so it removes it.
    SCRATCH=$(mktemp -d 2>/dev/null) || SCRATCH="${TMPDIR:-/tmp}/cplx-wrapper-accept-identity.$$"
    mkdir -p -- "$SCRATCH"
    OWN_SCRATCH=1
    trap cleanup EXIT
    if [ ! -f "$MANIFEST" ]; then
        echo "manifest not found: $MANIFEST" >&2
        exit 2
    fi
    if [ ! -f "$HARNESS" ]; then
        echo "harness not found: $HARNESS" >&2
        exit 2
    fi
    identity_suite
fi

printf '\n== verdict\n'
printf '  mode        %s\n' "$MODE"
printf '  cases       %s\n' "$cases"
printf '  failures    %s\n' "$failures"
printf '  accept-script-sha256 %s\n' "$ACCEPT_SHA256"
printf '  fixed-wrapper-sha256 %s\n' "$FIXED_ACTUAL"
printf '  control-wrapper-sha256 %s\n' "$CONTROL_ACTUAL"
[ "$MODE" = "identity" ] && printf '  harness-sha256 %s\n' "$(digest_of "$HARNESS")"
[ -n "$FIXED_TREE_ARG" ] && printf '  fixed-tree   %s\n' "$FIXED_TREE_ARG"
[ -n "$CONTROL_TREE_ARG" ] && printf '  control-tree %s\n' "$CONTROL_TREE_ARG"
[ -n "$ARCHIVE_TREE_ARG" ] && printf '  archive-tree %s\n' "$ARCHIVE_TREE_ARG"
[ -n "$RUN_IDENTITY_ARG" ] && printf '  run-identity %s\n' "$RUN_IDENTITY_ARG"
printf '  bash        %s\n' "${BASH_VERSION}"

if [ "$failures" -ne 0 ]; then
    printf '\nOBJECTIVE NOT MET for step 5 (%s): %s failure(s)\n' "$MODE" "$failures"
    exit 1
fi
if [ "$HOSTGATE_UNANSWERED" -ne 0 ]; then
    printf '\nOBJECTIVE NOT ANSWERABLE HERE for step 5 (%s)\n' "$MODE"
    printf 'No freshly deployed trees were supplied, so the first call this step\n'
    printf 'measures is not reproducible on this host. Deploy two trees from the\n'
    printf 'archive and re-run with --fixed-tree, --control-tree, --throwaway,\n'
    printf '--archive-tree, --scratch and --run-identity.\n'
    exit 4
fi
printf '\nOBJECTIVE MET for step 5 (%s)\n' "$MODE"
exit 0
