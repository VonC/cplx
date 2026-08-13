#!/bin/bash
# Verification harness for the v0.27.0 rsync-cp-fallback effort.
#
# This is Step 0 of docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md. It writes no
# installer code. It builds the executable oracle every later step is judged
# against, and captures what the CURRENT installer does, so each step has a
# measured baseline rather than a described one.
#
# Usage:
#   bash verify.install-pkg.sh [--step N] [--installer PATH] [--scratch DIR]
#
# Everything below the marker is byte-identical to the consuming project's copy,
# tools/installer_verify_step0.sh, and the header prints the digest of that
# shared body so the claim is checkable rather than asserted. Only this comment
# block differs between the two files.

# ---8<--- shared body: identical in both repository copies from this line ---
#
# Case contract (plan Q07). Every case:
#   * names a FIXTURE oracle, applied before anything runs, so a case cannot
#     report a shape it never planted. A failed `mkfifo` or `ln -s` is a case
#     failure, not a silently different case;
#   * DECLARES the installer and archive it intends to exercise, and the harness
#     asserts the resolved values against those declarations. Recording an
#     identity is not asserting it: a recorded value still lets a case exercise
#     the wrong copy and pass. The asserted pair is printed with every case, the
#     archive as a logical root plus name, since one basename can exist under
#     more than one searched root;
#   * asserts a phase-specific diagnostic together with the exit code, so a right
#     code from the wrong phase fails;
#   * names a POST-STATE oracle, which run_case applies itself.
# Both oracles are mandatory arguments. An unnamed or unknown one is a failure,
# so neither a status-only pass nor an unplanted fixture is reachable.
#
# Hermetic archive selection. install_pkg.sh searches FOUR roots for the newest
# tools.*.tar.gz: the prefix, its pkgs directory, $HOME and $HOME/pkgs. Every
# case runs with HOME pinned to a scratch directory and resolves across the same
# four roots, so the archive the harness asserts is the archive the installer
# consumes.
#
# Negative controls, so a harness that blesses anything is caught:
#   watchdog     a deliberate blocker must be reported as a timeout
#   exit-only    a substitute returning the expected status while changing no
#                state must be refused BY THE ORACLE A REAL CASE USES, so it
#                travels the whole of run_case rather than a private check
#   wrong-arch   a decoy archive must fail the ARCHIVE-identity assertion
#   omitted-root a decoy in a root a shortened resolver would ignore must fail
#                the same assertion, which is what exposes that omission
#   wrong-inst   a present second installer copy must fail the INSTALLER-identity
#                assertion, and specifically on the value rather than on absence
#   fixture-shape a regular file planted where a case declares a symlink must be
#                refused by the fixture oracle, on the shape and not downstream
#   encoder      a name whose hex holds a, c and e must survive encoding
# Each control states the exact reason it requires, so a control cannot be
# satisfied by a different failure than the one it exists to prove.
#
# Baseline, captured not asserted-as-timeout. The current installer has no path
# that blocks: with rsync absent it exits 5 in the mirror phase and never reaches
# the root-file site; with rsync present the root-file step uses rsync, which
# replaces both a FIFO and a symlink promptly with exit 0.
#
# Target identity. D-fb, R-rs and R-fb are the plan's matrix cells, and a cell is
# claimed only when the environment AND the installer can produce it, with the
# engine then asserted from the run's own trace. The pre-change Debian result is
# NOT D-fb: that cell means the fallback engine was selected and ran, and this
# installer has no fallback, so the run is reported as Debian/no-rsync/no-engine,
# the state expected to become D-fb once the engine exists.

set -u

STEP=0
INSTALLER=""
SCRATCH_PARENT="${TMPDIR:-/tmp}"
TIMEOUT_S=20

while [ $# -gt 0 ]; do
    case "$1" in
        --step)      STEP="$2"; shift 2 ;;
        --installer) INSTALLER="$2"; shift 2 ;;
        --scratch)   SCRATCH_PARENT="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

# Only step 0 has a case suite. Accepting any other value would let the verdict
# line report success for a step whose cases do not exist, which is a vacuous
# pass at exactly the level later steps are meant to rely on. When a later step
# adds a suite, extend this dispatch and the SUITES record below together.
case "$STEP" in
    0|1|2|3) ;;
    *) echo "unsupported --step $STEP: steps 0 to 3 have case suites today." >&2
       echo "Add its suite and extend the dispatch before requesting it." >&2
       exit 2 ;;
esac
SUITES=""
suite() { SUITES="${SUITES:+$SUITES }$1"; }

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# Default resolution, in the order a host is likely to have one: this
# repository's own source, then the prefix a pipeline extracted, then a deployed
# copy, then a sibling checkout. This uses the real HOME on purpose, because it
# is finding the installer rather than running it; every case then runs with HOME
# pinned inside scratch.
if [ -z "$INSTALLER" ]; then
    for cand in \
        "$here/../../src/setups/env/bin/install_pkg.sh" \
        "${PREFIX:-}/bootstrap/bin/install_pkg.sh" \
        "$HOME/tools/bin/install_pkg.sh" \
        "$here/../../cplx/src/setups/env/bin/install_pkg.sh"; do
        [ -f "$cand" ] && { INSTALLER="$cand"; break; }
    done
fi
[ -n "$INSTALLER" ] || { echo "no installer found; pass --installer PATH" >&2; exit 2; }
[ -f "$INSTALLER" ] || { echo "installer not found: $INSTALLER" >&2; exit 2; }
INSTALLER=$(cd "$(dirname "$INSTALLER")" && pwd)/$(basename "$INSTALLER")

SCRATCH="${SCRATCH_PARENT%/}/cplx-verify.$$"
failures=0
cases=0

cleanup() { rm -rf -- "$SCRATCH" 2>/dev/null; }
trap cleanup EXIT
mkdir -p -- "$SCRATCH" || { echo "cannot create scratch under $SCRATCH_PARENT" >&2; exit 2; }

# The installer's two home search roots, pinned inside scratch. Nothing the
# harness asserts then depends on what happens to sit in the real home.
CASE_HOME="$SCRATCH/home"
mkdir -p -- "$CASE_HOME/pkgs"

# ---------------------------------------------------------------- reporting ---
EXPECT_FAIL=0
CONTROL_ACTIVE=0
CTL_REASON=""
pass() { printf '  %-34s PASS  %s\n' "$1" "${2:-}"; }
# In a negative control the failure IS the expected result, so it is captured
# rather than printed. A log that a reader scans for FAIL must not show one that
# the next line contradicts. Only the control helper sets these flags, and it
# always clears them, so no early return can leave the harness deaf to failures.
fail() {
    if [ "$EXPECT_FAIL" -eq 1 ]; then CTL_REASON="${2:-}"; return 0; fi
    printf '  %-34s FAIL  %s\n' "$1" "${2:-}"
    failures=$((failures + 1))
}
chk()  { cases=$((cases + 1)); if [ "$2" = "$3" ]; then pass "$1" "$3"; else fail "$1" "want [$2] got [$3]"; fi; }

# control <name> <required-reason-prefix> <command...>
# The reason prefix is the whole point: a control that only demanded "INSTALLER"
# would be satisfied by a missing fixture rather than by the identity mismatch it
# exists to prove. Inner case counting is rolled back so a control is exactly one
# case either way.
control() {
    local name="$1" want="$2"; shift 2
    local saved="$cases"
    EXPECT_FAIL=1; CONTROL_ACTIVE=1; CTL_REASON=""
    "$@" >/dev/null 2>&1
    EXPECT_FAIL=0; CONTROL_ACTIVE=0
    cases=$((saved + 1))
    case "$CTL_REASON" in
        "$want"*) pass "$name" "refused on [$want], as designed" ;;
        "")       fail "$name" "passed, so that oracle is not asserted" ;;
        *)        fail "$name" "refused for the wrong reason: $CTL_REASON" ;;
    esac
}

# ------------------------------------------------------------------ encoder ---
# Delete-complement: it can only ever keep hex digits, so it cannot repeat the
# defect where a whitespace-looking set deleted the digits a, c and e.
enc() { printf '%s' "$1" | od -An -v -tx1 | tr -dc '0-9a-f'; }

short_sha() { sha256sum -- "$1" 2>/dev/null | cut -c1-12; }

# The digest of the shared body, from the marker line to EOF. Both repository
# copies produce the same value, which is what makes "the copies are in step" a
# reproducible statement rather than a claim in prose. The whole-file digest
# stays too: it pins a capture to one exact file, and cannot compare the copies
# because their header comments differ by design.
body_digest() {
    local f="$1" n
    n=$(grep -n '^# ---8<--- shared body' -- "$f" 2>/dev/null | head -n 1 | cut -d: -f1)
    [ -n "$n" ] || { printf 'no-marker'; return; }
    tail -n +"$n" -- "$f" | sha256sum | cut -d' ' -f1
}

# ---------------------------------------------------------------- preflight ---
# Two things, kept in one list because both must hold before any case runs, and
# named separately here because they are true for different reasons.
#
# Every external command the harness itself runs, including the ones implied by
# an option rather than named in a command position, and including `bash`, which
# run_case looks up on PATH to invoke the installer. An earlier version claimed
# to list every external command while quietly excepting that child `bash`.
#
# Plus the plan's five verification-only additions, which must be present on
# every target before any case: timeout, stat, sha256sum, mkfifo and diff. Only
# `diff` is not invoked at step 0: it is the manifest comparison's tool, and the
# target capture is the promised evidence that the acceptance gate in step 5 will
# have it. Asserting it here is the point of asserting it at all.
#
# Missing any of them stops the run before the first case, rather than becoming
# a red line in a verdict a reader reaches after twenty others.
HARNESS_TOOLS="basename bash cp cut date diff dirname find grep gzip head ln ls \
mkdir mkfifo od readlink rm sha256sum sort stat tail tar timeout touch tr uname wc"

preflight() {
    echo "--- preflight"
    local missing="" p t
    for t in $HARNESS_TOOLS; do
        p=$(command -v "$t" 2>/dev/null)
        [ -n "$p" ] || missing="${missing:+$missing }$t"
    done
    cases=$((cases + 1))
    if [ -n "$missing" ]; then
        fail "preflight commands" "MISSING: $missing"
        return 1
    fi
    pass "preflight commands" "all $(printf '%s\n' $HARNESS_TOOLS | wc -l | tr -d ' ') present"

    : > "$SCRATCH/.pf"
    local m; m=$(stat -c '%.9Y' -- "$SCRATCH/.pf" 2>&1)
    rm -f -- "$SCRATCH/.pf"
    cases=$((cases + 1))
    case "$m" in
        *.*) pass "preflight stat fractional" "$m" ;;
        *)   fail "preflight stat fractional" "no fractional field: $m"; return 1 ;;
    esac

    # A run that claims a target identity must be able to produce it. Refusing
    # here is the difference between evidence and a mislabelled log.
    cases=$((cases + 1))
    if [ "$COMBINATION_OK" -eq 1 ]; then
        pass "preflight combination" "$COMBINATION, engine asserted below"
    elif [ "$COMBINATION_CLAIMS_TARGET" -eq 1 ]; then
        fail "preflight combination" "$COMBINATION_WHY"
        return 1
    else
        pass "preflight combination" "self-test, not target evidence"
    fi
    return 0
}

# ------------------------------------------------------- synthetic archive ---
# Plan Q02: synthetic for steps 0 to 4, the real published archive for Step 5.
# It carries the shapes the acceptance names: a SONAME symlink, a linked rpath
# directory, a hidden entry, and the two archive root files.
build_archive() {
    local out="$1" build="$SCRATCH/build"
    rm -rf -- "$build"; mkdir -p "$build/tools/root/usr/lib64" "$build/tools/bin"
    printf 'payload\n'            > "$build/tools/root/usr/lib64/libgcc_s-11-20240719.so.1"
    ln -s libgcc_s-11-20240719.so.1 "$build/tools/root/usr/lib64/libgcc_s.so.1"
    ln -s usr/lib64                 "$build/tools/root/lib64"
    printf 'binary\n'             > "$build/tools/bin/patchelf"
    printf 'hidden\n'             > "$build/tools/.hidden-entry"
    printf 'export A=1\n'         > "$build/.env"
    printf 'export B=2\n'         > "$build/.env_"
    ( cd "$build" && tar --sort=name -cf - tools .env .env_ 2>/dev/null | gzip -n > "$out" )
}

# The installer picks the newest tools.*.tar.gz across the prefix, its pkgs
# directory, $HOME and $HOME/pkgs (install_pkg.sh line 393). All four roots are
# resolved here, under the same pinned HOME the case runs with.
resolve_archive() {
    local prefix="$1"
    find "$prefix" "$prefix/pkgs" "$CASE_HOME" "$CASE_HOME/pkgs" \
        -maxdepth 1 -type f -name 'tools.*.tar.gz' \
        -printf '%T@ %p\n' 2>/dev/null | sort -unr | head -n 1 | cut -d' ' -f2-
}

# Which of the four roots won, as a stable logical name. A basename alone cannot
# say that, and the same name can sit under more than one searched root.
archive_identity() {
    local prefix="$1" path="$2" name
    [ -n "$path" ] || { printf '(none resolved)'; return; }
    name=$(basename -- "$path")
    case "$path" in
        "$prefix/pkgs/"*)    printf 'PREFIX/pkgs/%s' "$name" ;;
        "$prefix/"*)         printf 'PREFIX/%s' "$name" ;;
        "$CASE_HOME/pkgs/"*) printf 'HOME/pkgs/%s' "$name" ;;
        "$CASE_HOME/"*)      printf 'HOME/%s' "$name" ;;
        *)                   printf 'OUTSIDE:%s' "$path" ;;
    esac
}

new_prefix() {
    local p="$SCRATCH/$1"; rm -rf -- "$p"; mkdir -p "$p/pkgs"; printf '%s' "$p"
}

# ----------------------------------------------------------- fixture oracle ---
# What the case claims to have planted, verified before the installer runs.
# FIXTURE_SEEN carries the human-readable shape into the retained output.
FIXTURE_SEEN=""
assert_fixture() {
    local spec="$1" name="$2" prefix="$3" declared_archive="$4"
    FIXTURE_SEEN=""
    if [ ! -d "$prefix" ]; then fail "$name" "FIXTURE: prefix missing"; return 1; fi
    if [ ! -d "$prefix/pkgs" ]; then fail "$name" "FIXTURE: prefix has no pkgs directory"; return 1; fi
    case "$spec" in
        fresh)
            if [ -e "$prefix/tools" ]; then fail "$name" "FIXTURE fresh: tools already exists"; return 1; fi
            if [ -e "$prefix/.env" ] || [ -e "$prefix/.env_" ]; then
                fail "$name" "FIXTURE fresh: an archive root file is already present"; return 1; fi
            FIXTURE_SEEN="fresh prefix, no tools and no root files"
            ;;
        fifo:*)
            local rel="${spec#fifo:}"
            if [ ! -p "$prefix/$rel" ]; then
                fail "$name" "FIXTURE fifo: $rel is not a FIFO (creation failed or wrong type)"; return 1; fi
            FIXTURE_SEEN="$rel is a FIFO"
            ;;
        symlink:*)
            # Declared and assigned separately: `local a=x b=${a}` expands every
            # word before the builtin assigns any of them, so b would see an
            # unset a. With set -u that is an abort rather than a wrong value.
            local body rel want got
            body="${spec#symlink:}"
            rel="${body%%=*}"
            want="${body#*=}"
            if [ ! -L "$prefix/$rel" ]; then
                fail "$name" "FIXTURE symlink: $rel is not a symlink (ln -s failed or wrong type)"; return 1; fi
            got=$(readlink -n -- "$prefix/$rel")
            if [ "$got" != "$want" ]; then
                fail "$name" "FIXTURE symlink: $rel points at [$got], expected [$want]"; return 1; fi
            if [ ! -f "$want" ]; then
                fail "$name" "FIXTURE symlink: the external target [$want] is not a regular file"; return 1; fi
            FIXTURE_SEEN="$rel is a symlink onto an external regular file"
            ;;
        decoy-newer:*)
            local decoy="${spec#decoy-newer:}" dm am
            if [ ! -f "$decoy" ]; then fail "$name" "FIXTURE decoy: [$decoy] is absent"; return 1; fi
            if [ ! -f "$declared_archive" ]; then
                fail "$name" "FIXTURE decoy: the declared archive [$declared_archive] is absent"; return 1; fi
            dm=$(stat -c '%Y' -- "$decoy" 2>/dev/null)
            am=$(stat -c '%Y' -- "$declared_archive" 2>/dev/null)
            if [ -z "$dm" ] || [ -z "$am" ] || [ "$dm" -le "$am" ]; then
                fail "$name" "FIXTURE decoy: [$decoy] is not newer than the declared archive"; return 1; fi
            FIXTURE_SEEN="a newer decoy archive exists at $(archive_identity "$prefix" "$decoy")"
            ;;
        dest-file:*)
            local rel="${spec#dest-file:}"
            if [ -L "$prefix/$rel" ] || [ ! -f "$prefix/$rel" ]; then
                fail "$name" "FIXTURE dest-file: $rel is not a plain regular file"; return 1; fi
            # Neutral on purpose: this oracle serves both the mirror, where a
            # regular file is the wrong shape, and the root-file deploy, where it
            # is an accepted one. The case name carries which is meant, and
            # retained evidence must not label an accepted shape as erroneous.
            FIXTURE_SEEN="$rel is a regular file"
            ;;
        dest-symlink-dir:*)
            local body2 rel2 want2 got2
            body2="${spec#dest-symlink-dir:}"
            rel2="${body2%%=*}"
            want2="${body2#*=}"
            if [ ! -L "$prefix/$rel2" ]; then
                fail "$name" "FIXTURE dest-symlink-dir: $rel2 is not a symlink"; return 1; fi
            got2=$(readlink -n -- "$prefix/$rel2")
            if [ "$got2" != "$want2" ]; then
                fail "$name" "FIXTURE dest-symlink-dir: $rel2 points at [$got2], expected [$want2]"; return 1; fi
            if [ ! -d "$want2" ]; then
                fail "$name" "FIXTURE dest-symlink-dir: the external target [$want2] is not a directory"; return 1; fi
            FIXTURE_SEEN="$rel2 is a symlink onto an external directory"
            ;;
        dest-dir:*)
            local rel4="${spec#dest-dir:}"
            if [ -L "$prefix/$rel4" ] || [ ! -d "$prefix/$rel4" ]; then
                fail "$name" "FIXTURE dest-dir: $rel4 is not a real directory"; return 1; fi
            FIXTURE_SEEN="$rel4 is a directory where a regular file is expected"
            ;;
        populated:*)
            local body3 rel3 marker3
            body3="${spec#populated:}"
            rel3="${body3%%=*}"
            marker3="${body3#*=}"
            if [ -L "$prefix/$rel3" ] || [ ! -d "$prefix/$rel3" ]; then
                fail "$name" "FIXTURE populated: $rel3 is not a real directory"; return 1; fi
            if [ ! -e "$prefix/$rel3/$marker3" ]; then
                fail "$name" "FIXTURE populated: the stale marker $marker3 is absent from $rel3"; return 1; fi
            FIXTURE_SEEN="$rel3 is a populated real directory holding the stale entry $marker3"
            ;;
        installer-copy:*)
            local copy="${spec#installer-copy:}" canon
            if [ ! -f "$copy" ]; then
                fail "$name" "FIXTURE installer-copy: [$copy] is absent, so the control would prove absence rather than identity"; return 1; fi
            canon=$(cd "$(dirname "$copy")" && pwd)/$(basename "$copy")
            if [ "$canon" = "$INSTALLER" ]; then
                fail "$name" "FIXTURE installer-copy: [$copy] is the installer under test, not a second copy"; return 1; fi
            if [ "$(sha256sum -- "$copy" | cut -d' ' -f1)" != "$(sha256sum -- "$INSTALLER" | cut -d' ' -f1)" ]; then
                fail "$name" "FIXTURE installer-copy: [$copy] is not a copy of the installer under test"; return 1; fi
            FIXTURE_SEEN="a present second installer copy at another path"
            ;;
        *)
            fail "$name" "FIXTURE: case named no known oracle [$spec]"; return 1 ;;
    esac
    return 0
}

# --------------------------------------------------------- post-state oracle ---
# The one place a deployment is judged. Real cases and the exit-only control go
# through it, so proving the control also proves the cases.
assert_post_state() {
    local oracle="$1" name="$2" prefix="$3"
    case "$oracle" in
        installed)
            if [ ! -d "$prefix/tools" ] || [ -z "$(ls -A "$prefix/tools" 2>/dev/null)" ]; then
                fail "$name" "POST-STATE: tools tree absent or empty"; return 1; fi
            if [ ! -f "$prefix/tools/bin/patchelf" ]; then
                fail "$name" "POST-STATE: payload file missing from the tree"; return 1; fi
            if [ ! -L "$prefix/tools/root/usr/lib64/libgcc_s.so.1" ]; then
                fail "$name" "POST-STATE: canary SONAME symlink is not a link"; return 1; fi
            if [ ! -f "$prefix/.env" ] || [ ! -f "$prefix/.env_" ]; then
                fail "$name" "POST-STATE: archive root files not deployed"; return 1; fi
            ;;
        mirrored-not-deployed)
            # Step 2's intermediate state on a host without rsync: the mirror
            # now completes with the fallback, and the root-file site still
            # calls rsync unconditionally, so it fails. A tree with no root
            # files is the correct outcome here and becomes wrong at step 3.
            if [ ! -d "$prefix/tools" ] || [ -z "$(ls -A "$prefix/tools" 2>/dev/null)" ]; then
                fail "$name" "POST-STATE: tools tree absent or empty, so the mirror did not complete"; return 1; fi
            if [ ! -f "$prefix/tools/bin/patchelf" ]; then
                fail "$name" "POST-STATE: payload file missing from the mirrored tree"; return 1; fi
            if [ ! -L "$prefix/tools/root/usr/lib64/libgcc_s.so.1" ]; then
                fail "$name" "POST-STATE: canary SONAME symlink is not a link after the fallback mirror"; return 1; fi
            if [ -f "$prefix/.env" ] || [ -f "$prefix/.env_" ]; then
                fail "$name" "POST-STATE: archive root files deployed, but the root-file site cannot work without rsync yet"; return 1; fi
            ;;
        mirrored-only)
            # The mirror completed and the run then failed at the root-file
            # site. Deliberately says nothing about the root files themselves:
            # step 3's refusal cases each assert their own destination shape,
            # which differs per case, so folding it in here would weaken it to
            # whatever all of them share.
            if [ ! -d "$prefix/tools" ] || [ -z "$(ls -A "$prefix/tools" 2>/dev/null)" ]; then
                fail "$name" "POST-STATE: tools tree absent or empty, so the mirror did not complete"; return 1; fi
            if [ ! -L "$prefix/tools/root/usr/lib64/libgcc_s.so.1" ]; then
                fail "$name" "POST-STATE: canary SONAME symlink is not a link after the mirror"; return 1; fi
            ;;
        staging-retained)
            if ! ls -d "$prefix/pkgs"/tools.*/ >/dev/null 2>&1; then
                fail "$name" "POST-STATE: staging absent, the recovery claim is unproven"; return 1; fi
            ;;
        not-deployed)
            if [ -d "$prefix/tools" ] && [ -n "$(ls -A "$prefix/tools" 2>/dev/null)" ]; then
                fail "$name" "POST-STATE: tools was populated despite the failure"; return 1; fi
            if ! ls -d "$prefix/pkgs"/tools.*/ >/dev/null 2>&1; then
                fail "$name" "POST-STATE: staging absent, the recovery claim is unproven"; return 1; fi
            ;;
        *)
            fail "$name" "POST-STATE: case named no known oracle [$oracle]"; return 1 ;;
    esac
    return 0
}

# Which engine actually OPERATED, read from the run's own output rather than from
# the environment that requested it. rsync -v always opens with its file list,
# which is an operation banner: it is printed by the transfer, not by a decision
# to transfer.
#
# `none` is not the absence of the rsync banner alone: that would prove only
# that rsync did not run, which is also true of a successful fallback. It
# additionally requires a failed run, so the claim is that NO engine ran, which
# is what the pre-change no-rsync baseline actually shows.
#
# There is deliberately no `fallback` expectation here, and no recognition of a
# fallback marker. An earlier version guessed at Step 1's wording, and the guess
# was unsafe in the direction that matters: the plan has Step 1 emit a SELECTION
# line before archive discovery while both rsync call sites stay unchanged, so on
# a no-rsync host that line can say fallback and the same run still die at the
# unchanged mirror. Recognising it would have reported "engine fallback, read
# from the run trace" for a run in which no copy engine ran, making a guessed
# phrase stronger evidence than the event it describes. Step 0 asserts only the
# states it can measure today. When Step 1 defines its trace, that belongs in a
# separately named SELECTION assertion, and proof that the selected engine copied
# stays with the operation and post-state cases.
# The SELECTION trace, deliberately a different function from assert_engine and
# deliberately never used to conclude that anything copied.
#
# Step 1 emits one `Copy engine:` line before archive discovery, and step 1 alone
# changes no call site, so a run can select cp and still operate rsync. That
# divergence is real at this step and the suite records it rather than hiding it.
# Reading a selection line as proof of a copy is exactly the conflation that was
# removed from assert_engine, and keeping the two apart is what stops it coming
# back once the trace exists.
assert_selection() {
    local name="$1" log="$2" want="$3" want_detail="$4"
    cases=$((cases + 1))
    if [ -z "$log" ] || [ ! -f "$log" ]; then
        fail "$name" "SELECTION: no run log, so the case it belongs to never ran"; return 1; fi
    local count line
    count=$(grep -c 'Copy engine:' "$log" 2>/dev/null)
    if [ "${count:-0}" -eq 0 ]; then
        fail "$name" "SELECTION: no 'Copy engine:' line in the run trace"; return 1; fi
    if [ "$count" -ne 1 ]; then
        fail "$name" "SELECTION: expected exactly one trace line, found $count"; return 1; fi
    line=$(grep -m1 'Copy engine:' "$log")
    case "$line" in
        *"Copy engine: $want"*) ;;
        *) fail "$name" "SELECTION: want [$want], trace reads [$line]"; return 1 ;;
    esac
    if [ -n "$want_detail" ] && ! printf '%s' "$line" | grep -qE "$want_detail"; then
        fail "$name" "SELECTION: engine $want but detail does not match /$want_detail/: [$line]"
        return 1
    fi
    # Design Q06: announced BEFORE archive discovery, so a run that dies during
    # discovery or extraction has still said which engine it would have used.
    #
    # The discovery marker is REQUIRED, not merely compared when present. An
    # earlier version skipped the comparison if the marker was absent and still
    # printed "announced before discovery", so a trace with nothing to order
    # against produced the same passing message as a correctly ordered one. An
    # ordering oracle that concludes from absence orders nothing.
    local sel_at disc_at disc_count
    disc_count=$(grep -c 'Searching for latest' "$log" 2>/dev/null)
    if [ "${disc_count:-0}" -ne 1 ]; then
        fail "$name" "SELECTION: archive discovery marker: want exactly 1, found ${disc_count:-0}, so there is nothing to order against"
        return 1
    fi
    sel_at=$(grep -n 'Copy engine:' "$log" | head -n 1 | cut -d: -f1)
    disc_at=$(grep -n 'Searching for latest' "$log" | head -n 1 | cut -d: -f1)
    if [ "$sel_at" -ge "$disc_at" ]; then
        fail "$name" "SELECTION: trace at line $sel_at, not before archive discovery at line $disc_at"
        return 1
    fi
    pass "$name" "selected $want, announced before discovery (a selection, not a copy)"
}

# The DEPLOY site's own operation trace, and a separate function on purpose.
#
# assert_engine stays mirror-scoped, which is what the step 2 handoff required,
# so reading it for a deploy assertion would prove only that the MIRROR used cp.
# On a host with rsync that is exactly step 2's behaviour, cp at the mirror then
# rsync at the root-file site, and it is precisely what a step 3 assertion has to
# be able to reject. The marker count matters too: a tools archive carries two
# root files, so one stray occurrence must not satisfy a contract expecting two.
assert_deploy_engine() {
    local name="$1" log="$2" want_count="$3"
    cases=$((cases + 1))
    if [ -z "$log" ] || [ ! -f "$log" ]; then
        fail "$name" "DEPLOY ENGINE: no run log, so the case it belongs to never ran"; return 1; fi
    local seen_count
    seen_count=$(grep -c 'Deploy engine cp:' "$log" 2>/dev/null)
    seen_count=${seen_count:-0}
    if [ "$seen_count" -eq 0 ]; then
        fail "$name" "DEPLOY ENGINE: want cp, but no 'Deploy engine cp:' trace, so the deploy site did not run the fallback"
        return 1
    fi
    if [ -n "$want_count" ] && [ "$seen_count" -ne "$want_count" ]; then
        fail "$name" "DEPLOY ENGINE: want $want_count cp deploys, the trace shows $seen_count"
        return 1
    fi
    pass "$name" "deploy engine cp operated on ${want_count:-$seen_count} root files, read from the run trace"
}

assert_engine() {
    local name="$1" log="$2" want="$3" case_exit="$4"
    cases=$((cases + 1))
    if [ -z "$log" ] || [ ! -f "$log" ]; then
        fail "$name" "engine: no run log, so the case it belongs to never ran"; return 1; fi
    local seen="none"
    grep -q 'sending incremental file list' "$log" 2>/dev/null && seen="rsync"
    # The cp marker is emitted only by the mirror helper, so it takes precedence
    # over the rsync banner. At step 2 the root-file site still calls rsync
    # unconditionally, so a forced run prints that banner from the LATER site
    # while the mirror ran cp. Reading the banner alone would name the wrong
    # engine for the site this assertion is about.
    grep -q 'Mirror engine cp:' "$log" 2>/dev/null && seen="cp"
    case "$want" in
        rsync|cp)
            if [ "$seen" = "$want" ]; then pass "$name" "engine $seen operated, read from the run trace"
            else fail "$name" "engine: want $want, the trace shows $seen"; fi ;;
        none)
            if [ "$seen" != "none" ]; then
                fail "$name" "engine: expected none, the trace shows $seen"
            elif [ "$case_exit" = "0" ]; then
                fail "$name" "engine: no engine trace, yet the run succeeded, so something copied untraced"
            else
                pass "$name" "no engine ran: no trace and the run failed at exit $case_exit"
            fi ;;
        *) fail "$name" "engine: unknown expectation [$want]" ;;
    esac
}

# ---------------------------------------------------------- the case runner ---
# run_case <name> <prefix> <declared-installer> <declared-archive> <expect-exit>
#          <expect-phase-regex> <fixture-oracle> <post-state-oracle>
#          [canonical-installer]
# Both oracles are mandatory and applied here, so no caller can produce a case
# that checks status alone or reports an unplanted shape. Case-specific extras
# are asserted by the caller AFTER this returns, on top of the oracles rather
# than instead of them.
CASE_EXIT=0
CASE_LOG=""
run_case() {
    local name="$1" prefix="$2" want_inst="$3" want_arch="$4" want_exit="$5"
    local want_phase="$6" fixture="${7:-}" oracle="${8:-}" canonical="${9:-$INSTALLER}"
    cases=$((cases + 1))
    # Cleared on entry, so a case that fails before running the installer leaves
    # no log rather than the PREVIOUS case's. Every assert_engine and
    # assert_selection call reads CASE_LOG after a run_case that may have failed
    # early, and a stale log there would have them assert against the wrong run
    # and quite possibly pass.
    CASE_LOG=""
    CASE_EXIT=-1

    if [ -z "$fixture" ]; then fail "$name" "FIXTURE: case named no oracle"; return 1; fi
    if [ -z "$oracle" ];  then fail "$name" "POST-STATE: case named no oracle"; return 1; fi

    # The canonical-installer override exists so a negative control can be
    # declared as its own installer and still travel this whole function. Outside
    # a control it would be an escape hatch from the very gate below, so it is
    # refused there.
    if [ "$canonical" != "$INSTALLER" ] && [ "$CONTROL_ACTIVE" -ne 1 ]; then
        fail "$name" "INSTALLER identity: only a negative control may override the canonical installer"
        return 1
    fi

    # 1. fixture precondition, exact rather than "the prefix exists"
    assert_fixture "$fixture" "$name" "$prefix" "$want_arch" || return 1

    # 2. identity, declared then asserted, across all four installer search roots
    local got_arch; got_arch=$(resolve_archive "$prefix")
    if [ "$got_arch" != "$want_arch" ]; then
        fail "$name" "ARCHIVE identity: want [$(archive_identity "$prefix" "$want_arch")] resolved [$(archive_identity "$prefix" "$got_arch")]"
        return 1
    fi
    if [ ! -f "$want_inst" ]; then
        fail "$name" "INSTALLER identity: declared path absent [$want_inst]"
        return 1
    fi
    local got_inst; got_inst=$(cd "$(dirname "$want_inst")" && pwd)/$(basename "$want_inst")
    # Both sides are canonicalised the same way, so the comparison is between
    # two files and not between two spellings of one path.
    local want_canon="$canonical"
    [ -f "$want_canon" ] && want_canon=$(cd "$(dirname "$want_canon")" && pwd)/$(basename "$want_canon")
    if [ "$got_inst" != "$want_canon" ]; then
        fail "$name" "INSTALLER identity: want [$want_canon] declared [$got_inst]"
        return 1
    fi
    local ident="installer $(short_sha "$got_inst")  archive $(archive_identity "$prefix" "$got_arch")"
    local fixture_seen="$FIXTURE_SEEN"

    # 3. run under the watchdog, with HOME pinned, capturing status and output.
    # CASE_FORCE_CP distinguishes three states a case may need: unset, set and
    # empty, and set to a value. An empty value is not the same as unset to the
    # code under test, and the plan names both, so the harness must be able to
    # produce both rather than collapse them.
    CASE_LOG="$SCRATCH/$name.log"
    if [ -n "${CASE_FORCE_CP+set}" ]; then
        HOME="$CASE_HOME" CPLX_INSTALL_PKG_FORCE_CP="$CASE_FORCE_CP" \
            timeout "$TIMEOUT_S" bash "$want_inst" tools --prefix "$prefix" \
            > "$CASE_LOG" 2>&1
    else
        HOME="$CASE_HOME" timeout "$TIMEOUT_S" bash "$want_inst" tools --prefix "$prefix" \
            > "$CASE_LOG" 2>&1
    fi
    CASE_EXIT=$?

    if [ "$CASE_EXIT" != "$want_exit" ]; then
        fail "$name" "exit: want $want_exit got $CASE_EXIT"
        return 1
    fi
    # 4. phase-specific diagnostic, so a right code from the wrong phase fails
    if [ -n "$want_phase" ] && ! grep -qE "$want_phase" "$CASE_LOG"; then
        fail "$name" "phase: no line matching /$want_phase/ (exit $CASE_EXIT)"
        return 1
    fi
    # 5. post-state, never optional
    assert_post_state "$oracle" "$name" "$prefix" || return 1

    pass "$name" "exit $CASE_EXIT"
    printf '      fixture   %s\n' "$fixture_seen"
    printf '      identity  %s\n' "$ident"
    return 0
}

# ------------------------------------------------------------- matrix label ---
have_rsync=no; command -v rsync >/dev/null 2>&1 && have_rsync=yes
force_cp="${CPLX_INSTALL_PKG_FORCE_CP:-}"
# Whether the installer under test can select a fallback engine at all, read
# from the installer rather than assumed from the step number.
installer_has_fallback=no
grep -q 'CPLX_INSTALL_PKG_FORCE_CP' "$INSTALLER" 2>/dev/null && installer_has_fallback=yes
os_id=$( . /etc/os-release 2>/dev/null && echo "${ID:-unknown}" )
[ -n "$os_id" ] || os_id="unknown"

COMBINATION=""
COMBINATION_OK=0
COMBINATION_CLAIMS_TARGET=0
COMBINATION_WHY=""
COMBINATION_NOTE=""
WANT_ENGINE=""
# The identity a run may claim advances with the suite, so a later step defines
# its own contract instead of inheriting an earlier step's rules by accident.
# Step 0's rules refuse a fallback-capable installer, which was right while the
# harness could witness no fallback. Applied unchanged to step 1 they refused the
# step 1 candidate on both supported targets, before any case ran, because the
# candidate contains the override token. A developer host hid that, since an
# unsupported host is a self-test either way.
#
# Two things stay refused at every step: a global forced override, which would
# make the whole run measure one requested mode rather than the selection logic,
# and a host and tool shape the target matrix does not contain.
if [ "$STEP" -ge 1 ]; then
    # Steps 1 and 2 run CANDIDATE suites. Neither is a matrix cell: one run
    # exercises six selections and, from step 2, both engines at the mirror, so
    # no single engine cell describes it. The label carries the highest suite so
    # a capture cannot be mistaken for the one below it.
    if   [ "$STEP" -ge 3 ]; then SUITE_TAG="step3-candidate"
    elif [ "$STEP" -ge 2 ]; then SUITE_TAG="step2-candidate"
    else                         SUITE_TAG="step1-candidate"; fi
    case "$os_id" in
        debian)
            COMBINATION_CLAIMS_TARGET=1
            if [ "$force_cp" = "1" ]; then
                COMBINATION_WHY="a global forced override would fix every case's engine; the suite sets the override per case instead"
            elif [ "$have_rsync" = yes ]; then
                COMBINATION_WHY="Debian with rsync present is not a shape the target matrix contains"
            else
                COMBINATION="$SUITE_TAG/Debian/no-rsync"; COMBINATION_OK=1; WANT_ENGINE="none"
                if [ "$STEP" -ge 3 ]; then
                    COMBINATION_NOTE="a step 3 candidate suite. Both sites now branch, so this run exercises the D-fb matrix cell end to end: the fallback is the only engine and the install completes. The per-case operation assertions remain the authority for which engine ran where."
                elif [ "$STEP" -ge 2 ]; then
                    COMBINATION_NOTE="a step 2 candidate suite, NOT a matrix cell: the fallback now completes the mirror here, and the run dies at the root-file site until step 3."
                else
                    COMBINATION_NOTE="a step 1 selection suite, NOT a matrix cell: it exercises six selections, and the unchanged rsync site still fails with no engine operating."
                fi
            fi ;;
        rhel|centos|rocky|almalinux)
            COMBINATION_CLAIMS_TARGET=1
            if [ "$force_cp" = "1" ]; then
                COMBINATION_WHY="a global forced override would fix every case's engine; the suite sets the override per case instead"
            elif [ "$have_rsync" = no ]; then
                COMBINATION_WHY="RHEL without rsync is not a shape the target matrix contains"
            else
                COMBINATION="$SUITE_TAG/RHEL/rsync"; COMBINATION_OK=1; WANT_ENGINE="rsync"
                if [ "$STEP" -ge 3 ]; then
                    COMBINATION_NOTE="a step 3 candidate suite, NOT one matrix cell: one cumulative run exercises R-rs without the override and R-fb under it, at both transfer sites. The per-case operation assertions remain the authority for which engine ran where."
                elif [ "$STEP" -ge 2 ]; then
                    COMBINATION_NOTE="a step 2 candidate suite, NOT a matrix cell: it exercises both engines at the mirror, the fallback under the override and rsync without it."
                else
                    COMBINATION_NOTE="a step 1 selection suite, NOT a matrix cell: it exercises six selections plus the forced divergence, where cp is selected and rsync still operates."
                fi
            fi ;;
        *)
            COMBINATION_WHY="$os_id is not a supported target" ;;
    esac
else
    # Step 0 recognises exactly two states, and both are states it can measure:
    # rsync operating, and nothing operating. It infers no fallback cell, because
    # it cannot witness one, and refuses an installer able to select one.
    case "$os_id" in
        debian)
            COMBINATION_CLAIMS_TARGET=1
            if [ "$force_cp" = "1" ]; then
                COMBINATION_WHY="forced fallback requested; step 0 cannot witness a fallback engine, so it refuses to label the run"
            elif [ "$have_rsync" = yes ]; then
                COMBINATION_WHY="Debian with rsync present is neither the no-rsync baseline nor the D-fb cell"
            elif [ "$installer_has_fallback" = yes ]; then
                COMBINATION_WHY="this installer can select a fallback engine, which step 0 has no assertion for; run it at --step 1, whose suite does"
            else
                COMBINATION="Debian/no-rsync/no-engine"; COMBINATION_OK=1; WANT_ENGINE="none"
                COMBINATION_NOTE="pre-change baseline, NOT the D-fb cell: this installer has no fallback engine, so no engine can run. This is the state expected to become D-fb once one exists."
            fi ;;
        rhel|centos|rocky|almalinux)
            COMBINATION_CLAIMS_TARGET=1
            if [ "$force_cp" = "1" ]; then
                COMBINATION_WHY="R-fb is a fallback cell, and step 0 can witness no fallback engine; it refuses the label rather than infer it"
            elif [ "$have_rsync" = no ]; then
                COMBINATION_WHY="RHEL without rsync is not the R-rs cell, and no matrix cell covers it"
            elif [ "$installer_has_fallback" = yes ]; then
                COMBINATION_WHY="this installer can select a fallback engine, which step 0 has no assertion for; run it at --step 1, whose suite does"
            else
                COMBINATION="R-rs"; COMBINATION_OK=1; WANT_ENGINE="rsync"
            fi ;;
        *)
            COMBINATION_WHY="$os_id is not a supported target" ;;
    esac
fi

# ------------------------------------------------------------------- report ---
echo "=== verify.install-pkg, v0.27.0 rsync-cp-fallback, step $STEP ==="
echo "date      : $(date -u '+%Y-%m-%dT%H:%M:%SZ') (UTC)"
# The harness body itself. The whole-file digest pins a capture to one exact
# file; the shared-body digest is equal in both repository copies and is what
# makes "the copies are in step" checkable from the evidence alone.
echo "harness   : $(basename -- "${BASH_SOURCE[0]}")"
echo "  sha256  : $(sha256sum -- "${BASH_SOURCE[0]}" 2>/dev/null | cut -d' ' -f1)"
echo "  body    : $(body_digest "${BASH_SOURCE[0]}")"
echo "uname     : $(uname -srm)"
echo "installer : $INSTALLER"
# Which script was measured, not just where it sat. A path proves nothing about
# content: the first RHEL baseline ran against a deployed copy dated months
# before this branch, and the retained output could not have shown that.
echo "  sha256  : $(sha256sum -- "$INSTALLER" 2>/dev/null | cut -d' ' -f1)"
echo "  lines   : $(wc -l < "$INSTALLER" 2>/dev/null | tr -d ' ')"
echo "  fallback: $installer_has_fallback (CPLX_INSTALL_PKG_FORCE_CP support)"
echo "rsync     : $have_rsync"
if [ "$COMBINATION_OK" -eq 1 ]; then
    echo "identity  : $COMBINATION, requested; the engine is asserted from the run trace below"
    [ -n "$COMBINATION_NOTE" ] && echo "            $COMBINATION_NOTE"
else
    echo "identity  : none, this run is NOT target evidence"
    echo "            $COMBINATION_WHY"
fi
echo "home      : $CASE_HOME (pinned, so archive selection is hermetic)"
echo "scratch   : $SCRATCH"
echo

# Preflight is a gate, not a case group: a missing dependency or a mislabelled
# target makes every later line meaningless, so nothing runs after it fails.
if ! preflight; then
    echo
    echo "=== VERDICT ==="
    echo "preflight failed: the harness cannot run here, so no case was executed."
    echo "Fix the dependency or the target identity above and re-run."
    exit 2
fi
suite "preflight"
echo

# ------------------------------------------------------- negative controls ---
echo "--- negative controls"

# encoder: the defect this guards deleted the hex digits a, c and e.
chk "control encoder" "6a6c6e" "$(enc 'jln')"

# watchdog: a deliberate blocker, invoked directly rather than through the
# installer, must be reported as a timeout. This is what makes "promptly" in
# Step 3 a falsifiable claim.
mkfifo "$SCRATCH/blocker.fifo" 2>/dev/null
cases=$((cases + 1))
if [ ! -p "$SCRATCH/blocker.fifo" ]; then
    fail "control watchdog" "FIXTURE: cannot create a FIFO fixture here"
else
    printf 'x\n' > "$SCRATCH/blocker.src"
    timeout 2 cp -a "$SCRATCH/blocker.src" "$SCRATCH/blocker.fifo" >/dev/null 2>&1
    wd=$?
    if [ "$wd" -eq 124 ]; then pass "control watchdog" "blocked, killed at 2s"
    else fail "control watchdog" "expected timeout 124, got $wd"; fi
fi

arch_prefix=$(new_prefix ctl)
build_archive "$arch_prefix/pkgs/tools.2026-08-11_000000.tar.gz"
good_archive=$(resolve_archive "$arch_prefix")

# wrong archive: a decoy that is newer wins the installer's own selection, so
# the resolved archive differs from the declared one and identity must fail.
decoy_prefix_archive="$arch_prefix/pkgs/tools.2026-08-12_000000.tar.gz"
build_archive "$decoy_prefix_archive"
touch -d '2030-01-01 00:00:00' "$decoy_prefix_archive" 2>/dev/null
control "control wrong-archive" "ARCHIVE identity: want" \
    run_case "wrong-archive" "$arch_prefix" "$INSTALLER" "$good_archive" 0 "" \
             "decoy-newer:$decoy_prefix_archive" installed
rm -f -- "$decoy_prefix_archive"

# omitted root: the same decoy planted in $HOME/pkgs, a root the installer
# searches and an earlier resolver here did not. A harness blind to that root
# approves the declared archive while the installer consumes the decoy, so this
# control is the one that fails if the four roots are ever shortened again.
decoy_home_archive="$CASE_HOME/pkgs/tools.2026-08-12_000000.tar.gz"
build_archive "$decoy_home_archive"
touch -d '2030-01-01 00:00:00' "$decoy_home_archive" 2>/dev/null
control "control omitted-root" "ARCHIVE identity: want" \
    run_case "omitted-root" "$arch_prefix" "$INSTALLER" "$good_archive" 0 "" \
             "decoy-newer:$decoy_home_archive" installed
rm -f -- "$decoy_home_archive"

# wrong installer: a PRESENT second copy at another path must fail INSTALLER
# identity on the value. Demanding the exact reason matters: a failed copy would
# otherwise satisfy this control through "declared path absent", proving that an
# absent file is absent rather than that identity is asserted.
cp -a "$INSTALLER" "$SCRATCH/install_pkg.copy.sh"
control "control wrong-installer" "INSTALLER identity: want" \
    run_case "wrong-installer" "$arch_prefix" "$SCRATCH/install_pkg.copy.sh" "$good_archive" 0 "" \
             "installer-copy:$SCRATCH/install_pkg.copy.sh" installed

# exit-only: a substitute that returns the expected status while changing no
# state must be refused. It is declared as its own canonical installer so it
# clears identity and travels the WHOLE of run_case, and it must then be caught
# by assert_post_state, the same oracle every real case is judged by.
exitonly=$(new_prefix exitonly)
build_archive "$exitonly/pkgs/tools.2026-08-11_000000.tar.gz"
exitonly_archive=$(resolve_archive "$exitonly")
printf '#!/bin/bash\nexit 0\n' > "$SCRATCH/exit-only.sh"
control "control exit-only" "POST-STATE" \
    run_case "exit-only" "$exitonly" "$SCRATCH/exit-only.sh" "$exitonly_archive" 0 "" \
             fresh installed "$SCRATCH/exit-only.sh"

# fixture shape: a case declares an exact symlink fixture, and a plain regular
# file is planted instead. The oracle must refuse it, and specifically on the
# shape rather than on anything downstream.
#
# This control runs on both targets on purpose. The oracle interprets the setup
# that every behavioural conclusion rests on, so an error in it could accept a
# false declaration on both targets while every ordinary case stayed green. A
# developer-host incident diagnoses that once; only a retained control
# recalibrates it on the evidence being approved.
fixctl=$(new_prefix fixture-ctl)
build_archive "$fixctl/pkgs/tools.2026-08-11_000000.tar.gz"
fixctl_archive=$(resolve_archive "$fixctl")
mkdir -p "$SCRATCH/external"
printf 'DECOY TARGET\n' > "$SCRATCH/external/fixctl.target"
printf 'a regular file, not a link\n' > "$fixctl/.env"
control "control fixture-shape" "FIXTURE symlink:" \
    run_case "fixture-shape" "$fixctl" "$INSTALLER" "$fixctl_archive" 0 "" \
             "symlink:.env=$SCRATCH/external/fixctl.target" installed
suite "controls"
echo

# ------------------------------------------------------- baseline capture ---
echo "--- baseline of the CURRENT installer"
base=$(new_prefix baseline)
build_archive "$base/pkgs/tools.2026-08-11_000000.tar.gz"
base_archive=$(resolve_archive "$base")

if [ "$have_rsync" = yes ]; then
    echo "  (rsync present: the mirror succeeds today, so the baseline is a"
    echo "   working install, and the root-file shapes are rsync's behaviour)"
    run_case "baseline fresh install" "$base" "$INSTALLER" "$base_archive" 0 \
             'Installation successful' fresh installed
    assert_engine "baseline engine" "$CASE_LOG" "${WANT_ENGINE:-rsync}" "$CASE_EXIT"

    # Root-file FIFO, plan step 0 baseline 2. The destination .env is a FIFO;
    # rsync replaces it and returns 0. The watchdog is the promptness proof:
    # a blocking engine would come back as 124 and fail the expected 0, which
    # is exactly what the calibrated control shows cp -a does to a FIFO.
    fifo=$(new_prefix rootfile-fifo)
    build_archive "$fifo/pkgs/tools.2026-08-11_000000.tar.gz"
    fifo_archive=$(resolve_archive "$fifo")
    mkfifo "$fifo/.env" 2>/dev/null
    run_case "baseline root-file FIFO" "$fifo" "$INSTALLER" "$fifo_archive" 0 \
             "Deploying '\.env'" "fifo:.env" installed
    cases=$((cases + 1))
    if [ -p "$fifo/.env" ]; then
        fail "baseline FIFO replaced" "destination is still a FIFO"
    elif [ -f "$fifo/.env" ] && grep -q 'export A=1' "$fifo/.env" 2>/dev/null; then
        pass "baseline FIFO replaced" "regular file carrying the archive content"
    else
        fail "baseline FIFO replaced" "not a regular file with the archive content"
    fi

    # Root-file symlink to a regular file OUTSIDE the prefix, plan step 0
    # baseline 3. rsync replaces the link itself; the external target must be
    # byte- and mtime-identical afterwards, which is the guarantee Step 3 has
    # to preserve when the fallback engine takes over.
    link=$(new_prefix rootfile-symlink)
    build_archive "$link/pkgs/tools.2026-08-11_000000.tar.gz"
    link_archive=$(resolve_archive "$link")
    mkdir -p "$SCRATCH/external"
    ext="$SCRATCH/external/env.target"
    printf 'EXTERNAL\n' > "$ext"
    touch -d '2020-02-02 02:02:02' "$ext" 2>/dev/null
    ext_before="$(sha256sum -- "$ext" | cut -d' ' -f1) $(stat -c '%.9Y' -- "$ext")"
    ln -s "$ext" "$link/.env" 2>/dev/null
    run_case "baseline root-file symlink" "$link" "$INSTALLER" "$link_archive" 0 \
             "Deploying '\.env'" "symlink:.env=$ext" installed
    cases=$((cases + 1))
    if [ -L "$link/.env" ]; then
        fail "baseline symlink replaced" "destination is still a symlink"
    elif grep -q 'export A=1' "$link/.env" 2>/dev/null; then
        pass "baseline symlink replaced" "regular file carrying the archive content"
    else
        fail "baseline symlink replaced" "not a regular file with the archive content"
    fi
    cases=$((cases + 1))
    ext_after="$(sha256sum -- "$ext" | cut -d' ' -f1) $(stat -c '%.9Y' -- "$ext")"
    if [ "$ext_before" = "$ext_after" ]; then
        pass "baseline external target intact" "content and mtime unchanged"
    else
        fail "baseline external target intact" "changed: [$ext_before] -> [$ext_after]"
    fi
    suite "baseline-rsync"
else
    if [ "$STEP" -ge 3 ]; then
        # Both sites now branch, so a host with no rsync installs end to end.
        # This case has moved twice: exit 5 at the mirror at step 0, which was
        # the Q19 defect written down; exit 7 at the root-file site at step 2,
        # the honest intermediate; and exit 0 here, the defect gone. Each move
        # re-pointed the assertion rather than deleting it, which is what keeps
        # the sequence readable.
        echo "  (no rsync, step 3: both sites branch, so the install completes"
        echo "   on the fallback engine alone)"
        run_case "baseline no-rsync mirror" "$base" "$INSTALLER" "$base_archive" 0 \
                 'Installation successful' fresh installed
        assert_engine "baseline engine" "$CASE_LOG" cp "$CASE_EXIT"
    elif [ "$STEP" -ge 2 ]; then
        # The Q19 defect is gone from the mirror as of step 2, so the case that
        # recorded it changes rather than disappears. The run now gets past the
        # mirror on the fallback and dies at the root-file site, which still
        # calls rsync unconditionally until step 3. Exit 7, not 5, and a tree
        # that is mirrored but has no root files.
        echo "  (no rsync, step 2: the mirror now completes on the fallback and"
        echo "   the run dies at the root-file site instead, which step 3 fixes)"
        run_case "baseline no-rsync mirror" "$base" "$INSTALLER" "$base_archive" 7 \
                 "Rsync \(\.env" fresh mirrored-not-deployed
        assert_engine "baseline engine" "$CASE_LOG" cp "$CASE_EXIT"
    else
        echo "  (no rsync: the mirror phase dies, which is the Q19 defect itself,"
        echo "   and the root-file site is never reached, so its two shapes have"
        echo "   no baseline on this target by construction)"
        run_case "baseline no-rsync mirror" "$base" "$INSTALLER" "$base_archive" 5 \
                 'Rsync \(main\) failed|rsync' fresh not-deployed
        assert_engine "baseline engine" "$CASE_LOG" "${WANT_ENGINE:-none}" "$CASE_EXIT"
    fi
    suite "baseline-no-rsync"
fi
echo

# --------------------------------------------------- step 1: engine selection ---
# Plan step 1: the engine is resolved once, before archive discovery, from
# `command -v rsync` and the override, and announced as a selection.
#
# Every case here asserts the SELECTION line only. Step 1 changes no call site,
# so on a host with rsync a forced-fallback run still mirrors with rsync, and the
# suite asserts that divergence explicitly rather than letting the selection line
# imply a copy. Steps 2 and 3 close it, and their cases are what will show the
# fallback actually copying.
if [ "$STEP" -ge 1 ]; then
    echo "--- step 1: engine selection (a selection trace, not proof of a copy)"

    # The ordering oracle's two controls, retained on both targets, and two named
    # controls rather than one composite so each failure reason is checked
    # independently and each counts once.
    #
    # They calibrate different things, and an earlier version had only the first.
    # That one proves the oracle cannot infer ordering from an absent marker,
    # which is marker PRESENCE. The branch that implements Q06, that a selection
    # announced after archive discovery must be refused, had never executed: the
    # six real cases show a correctly ordered trace passing, and no trace in
    # existence is ordered wrongly, because no installer emits one. Leaving the
    # only rejection branch of this step's own guarantee to code inspection is
    # the assurance class the plan's Q07 treats as a complement to instrumented
    # controls rather than a replacement for them.

    # 1. No discovery marker at all: there is nothing to order against.
    printf 'Info  : [install_pkg.sh] Copy engine: rsync (/usr/bin/rsync)\n' \
        > "$SCRATCH/selection-no-discovery.log"
    printf 'Info  : [install_pkg.sh] Installation prefix: /nowhere\n' \
        >> "$SCRATCH/selection-no-discovery.log"
    control "control selection-no-discovery" "SELECTION: archive discovery marker" \
        assert_selection "selection-no-discovery" "$SCRATCH/selection-no-discovery.log" rsync ""

    # 2. Exactly one discovery marker and one otherwise-valid selection line, in
    # the wrong order. Well formed in every respect except the one Q06 requires.
    printf 'Task=>: [install_pkg.sh] Searching for latest tools archive...\n' \
        > "$SCRATCH/selection-out-of-order.log"
    printf 'Info  : [install_pkg.sh] Copy engine: rsync (/usr/bin/rsync)\n' \
        >> "$SCRATCH/selection-out-of-order.log"
    control "control selection-out-of-order" "SELECTION: trace at line" \
        assert_selection "selection-out-of-order" "$SCRATCH/selection-out-of-order.log" rsync ""

    # What a selection case is expected to do after selecting is a property of
    # the step, not of step 1: from step 2 the fallback completes the mirror, so
    # a no-rsync host stops at the root-file site instead of the mirror. The
    # selection assertions below are unchanged either way, which is the point.
    if [ "$have_rsync" = yes ] || [ "$STEP" -ge 3 ]; then
        sel_exit=0; sel_phase='Installation successful'; sel_post=installed
    elif [ "$STEP" -ge 2 ]; then
        sel_exit=7; sel_phase="Rsync \(\.env"; sel_post=mirrored-not-deployed
    else
        sel_exit=5; sel_phase='Rsync \(main\) failed|rsync'; sel_post=not-deployed
    fi

    sel_n=0
    # The literal token `unset` is this loop's sentinel for "do not set the
    # variable at all", which the plan distinguishes from setting it empty.
    for sel_spec in unset 1 0 yes true ""; do
        sel_n=$((sel_n + 1))
        sel_prefix=$(new_prefix "sel$sel_n")
        build_archive "$sel_prefix/pkgs/tools.2026-08-11_000000.tar.gz"
        sel_archive=$(resolve_archive "$sel_prefix")

        if [ "$sel_spec" = "unset" ]; then
            unset CASE_FORCE_CP; sel_label="override unset"
        elif [ -z "$sel_spec" ]; then
            CASE_FORCE_CP=""; sel_label="override empty"
        else
            CASE_FORCE_CP="$sel_spec"; sel_label="override $sel_spec"
        fi

        # Only the exact value 1 forces the fallback. Everything else, including
        # the truthy-looking yes and true, behaves as unset: the consumers are
        # scripts, so tolerant parsing would be a liability rather than a
        # convenience.
        if [ "$sel_spec" = "1" ]; then
            sel_engine="cp"; sel_detail="forced by CPLX_INSTALL_PKG_FORCE_CP=1"
        elif [ "$have_rsync" = yes ]; then
            sel_engine="rsync"; sel_detail="rsync \(/.*rsync\)"
        else
            sel_engine="cp"; sel_detail="rsync not found on PATH"
        fi

        run_case "step1 $sel_label" "$sel_prefix" "$INSTALLER" "$sel_archive" \
                 "$sel_exit" "$sel_phase" fresh "$sel_post"
        assert_selection "step1 $sel_label trace" "$CASE_LOG" "$sel_engine" "$sel_detail"

        # The divergence, asserted where it exists rather than described. With
        # rsync present and the fallback forced, step 1 selects cp and still
        # operates rsync, because neither call site has changed yet. Recording
        # it here means step 2 has something to show a transition against.
        if [ "$sel_spec" = "1" ] && [ "$have_rsync" = yes ]; then
            if [ "$STEP" -ge 2 ]; then
                # The transition this case exists to mark, re-pointed rather
                # than deleted: step 2 branches the mirror, so a forced
                # selection now operates cp where step 1 still operated rsync.
                assert_engine "step1 forced now operates cp" "$CASE_LOG" cp "$CASE_EXIT"
            else
                assert_engine "step1 forced still operates rsync" "$CASE_LOG" rsync "$CASE_EXIT"
            fi
        fi
    done
    unset CASE_FORCE_CP
    suite "step1-selection"
    echo
fi

# ------------------------------------------------ step 2: the mirror fallback ---
# Plan step 2: branch the mirror on the verdict; on the fallback path observe the
# destination without following symlinks, refuse anything neither absent nor a
# real directory, then empty and copy.
#
# The fallback is reached naturally where rsync is absent and by the override
# where it is present, so both targets exercise the same engine here.
if [ "$STEP" -ge 2 ]; then
    echo "--- step 2: the mirror fallback and its destination boundary"

    # Where rsync exists the fallback needs forcing; where it does not, it is
    # the only engine. Either way these cases run the cp mirror.
    if [ "$have_rsync" = yes ]; then
        CASE_FORCE_CP=1
    else
        unset CASE_FORCE_CP
    fi
    if [ "$have_rsync" = yes ] || [ "$STEP" -ge 3 ]; then
        # Either rsync deploys the root files, or from step 3 the fallback does.
        s2_exit=0; s2_phase='Installation successful'; s2_post=installed
    else
        # No rsync and before step 3, so the root-file site still fails.
        s2_exit=7; s2_phase="Rsync \(\.env"; s2_post=mirrored-not-deployed
    fi

    # 1. Fresh prefix on the fallback: the mirror completes and the canary
    # SONAME symlink survives as a link, which the post-state oracle asserts.
    s2a=$(new_prefix step2-fresh)
    build_archive "$s2a/pkgs/tools.2026-08-11_000000.tar.gz"
    s2a_archive=$(resolve_archive "$s2a")
    run_case "step2 fallback fresh" "$s2a" "$INSTALLER" "$s2a_archive" \
             "$s2_exit" "$s2_phase" fresh "$s2_post"
    assert_engine "step2 fresh engine" "$CASE_LOG" cp "$CASE_EXIT"
    cases=$((cases + 1))
    if [ -f "$s2a/tools/.hidden-entry" ]; then
        pass "step2 hidden entry carried" "cp -a src/. carried the hidden entry"
    else
        fail "step2 hidden entry carried" "the archive's hidden entry is missing from the tree"
    fi

    # 2. Redeployment over a populated destination holding a stale hidden entry.
    # The entry is hidden on purpose: a copy form that depended on the caller's
    # globbing would leave it behind, and it would be invisible in a listing.
    s2b=$(new_prefix step2-redeploy)
    build_archive "$s2b/pkgs/tools.2026-08-11_000000.tar.gz"
    s2b_archive=$(resolve_archive "$s2b")
    mkdir -p "$s2b/tools/stale-dir"
    printf 'stale\n' > "$s2b/tools/.stale-hidden"
    printf 'stale\n' > "$s2b/tools/stale-visible"
    run_case "step2 fallback redeploy" "$s2b" "$INSTALLER" "$s2b_archive" \
             "$s2_exit" "$s2_phase" "populated:tools=.stale-hidden" "$s2_post"
    cases=$((cases + 1))
    if [ -e "$s2b/tools/.stale-hidden" ] || [ -e "$s2b/tools/stale-visible" ] \
       || [ -e "$s2b/tools/stale-dir" ]; then
        fail "step2 stale entries removed" "a stale entry survived the mirror"
    else
        pass "step2 stale entries removed" "hidden, visible and directory entries all gone"
    fi

    # 3. The boundary: a destination that is a regular file. Refused before any
    # delete, on both engines, with the reworded exit-5 diagnostic.
    s2c=$(new_prefix step2-destfile)
    build_archive "$s2c/pkgs/tools.2026-08-11_000000.tar.gz"
    s2c_archive=$(resolve_archive "$s2c")
    printf 'not a tree\n' > "$s2c/tools"
    s2c_before=$(sha256sum -- "$s2c/tools" | cut -d' ' -f1)
    run_case "step2 dest regular file" "$s2c" "$INSTALLER" "$s2c_archive" 5 \
             "mirror step \(engine cp\): destination .* is not a directory" \
             "dest-file:tools" staging-retained
    cases=$((cases + 1))
    if [ -f "$s2c/tools" ] && [ "$(sha256sum -- "$s2c/tools" | cut -d' ' -f1)" = "$s2c_before" ]; then
        pass "step2 dest file untouched" "refused before any delete"
    else
        fail "step2 dest file untouched" "the destination was modified despite the refusal"
    fi

    # 4. The boundary's sharpest shape: a destination that is a symlink to an
    # external directory. Measured to make the rsync path empty that external
    # target and still return 0, so the fallback refuses it outright.
    s2d=$(new_prefix step2-destlink)
    build_archive "$s2d/pkgs/tools.2026-08-11_000000.tar.gz"
    s2d_archive=$(resolve_archive "$s2d")
    s2d_ext="$SCRATCH/external-tree"
    rm -rf -- "$s2d_ext"; mkdir -p "$s2d_ext"
    printf 'precious\n' > "$s2d_ext/do-not-delete"
    printf 'precious\n' > "$s2d_ext/.hidden-precious"
    ln -s "$s2d_ext" "$s2d/tools" 2>/dev/null
    run_case "step2 dest symlink to dir" "$s2d" "$INSTALLER" "$s2d_archive" 5 \
             "mirror step \(engine cp\): destination .* is a symlink" \
             "dest-symlink-dir:tools=$s2d_ext" staging-retained
    cases=$((cases + 1))
    if [ -f "$s2d_ext/do-not-delete" ] && [ -f "$s2d_ext/.hidden-precious" ]; then
        pass "step2 external target intact" "nothing outside the prefix was deleted"
    else
        fail "step2 external target intact" "the external target lost entries"
    fi

    # 5. The same fixture on the rsync engine, where one exists, so the reworded
    # exit-5 diagnostic is asserted on BOTH engines rather than only the new one.
    if [ "$have_rsync" = yes ]; then
        unset CASE_FORCE_CP
        s2e=$(new_prefix step2-destfile-rsync)
        build_archive "$s2e/pkgs/tools.2026-08-11_000000.tar.gz"
        s2e_archive=$(resolve_archive "$s2e")
        printf 'not a tree\n' > "$s2e/tools"
        run_case "step2 rsync dest regular file" "$s2e" "$INSTALLER" "$s2e_archive" 5 \
                 "mirror step \(engine rsync\) failed" "dest-file:tools" staging-retained
        CASE_FORCE_CP=1
    fi

    unset CASE_FORCE_CP
    suite "step2-mirror"
    echo
fi

# ------------------------------------------- step 3: the root-file fallback ---
# Plan step 3: branch the root-file loop on the verdict; on the fallback path
# observe the destination without following symlinks, accept only an absent
# destination or a real regular file, and copy with --remove-destination.
#
# M2 measured the two hazards this preflight exists for, and they belong to the
# fallback engine rather than to a distribution: onto a symlink to a regular
# file `cp -a` follows the link, overwrites the external target and returns 0;
# onto a FIFO it blocks. The first is silent data loss reported as success, the
# second is an unattended install waiting forever.
if [ "$STEP" -ge 3 ]; then
    echo "--- step 3: the root-file deploy and its non-following preflight"

    if [ "$have_rsync" = yes ]; then CASE_FORCE_CP=1; else unset CASE_FORCE_CP; fi

    # 1. Both accepted shapes, in one run: .env absent and .env_ present as a
    # real regular file. The install completes and both carry archive content.
    s3a=$(new_prefix step3-accept)
    build_archive "$s3a/pkgs/tools.2026-08-11_000000.tar.gz"
    s3a_archive=$(resolve_archive "$s3a")
    printf 'stale root file\n' > "$s3a/.env_"
    run_case "step3 deploy accepted shapes" "$s3a" "$INSTALLER" "$s3a_archive" 0 \
             'Installation successful' "dest-file:.env_" installed
    # Both root files, and read from the DEPLOY trace rather than the mirror's:
    # the archive carries .env and .env_, so the fallback must have deployed
    # exactly two.
    assert_deploy_engine "step3 accepted deploy engine" "$CASE_LOG" 2
    cases=$((cases + 1))
    if grep -q 'export A=1' "$s3a/.env" 2>/dev/null \
       && grep -q 'export B=2' "$s3a/.env_" 2>/dev/null; then
        pass "step3 both root files deployed" "absent and present destinations both carry archive content"
    else
        fail "step3 both root files deployed" "a root file is missing or stale"
    fi

    # 2. The overwrite hazard: a destination that is a symlink to a regular file
    # OUTSIDE the prefix. Refused at exit 7, the link left as a link, and the
    # external target byte-identical including mtime. Without the non-following
    # observation this run would have reported success while destroying it.
    s3b=$(new_prefix step3-symlink)
    build_archive "$s3b/pkgs/tools.2026-08-11_000000.tar.gz"
    s3b_archive=$(resolve_archive "$s3b")
    mkdir -p "$SCRATCH/external"
    s3b_ext="$SCRATCH/external/rootfile.target"
    printf 'PRECIOUS\n' > "$s3b_ext"
    touch -d '2020-02-02 02:02:02' "$s3b_ext" 2>/dev/null
    s3b_before="$(sha256sum -- "$s3b_ext" | cut -d' ' -f1) $(stat -c '%.9Y' -- "$s3b_ext")"
    ln -s "$s3b_ext" "$s3b/.env" 2>/dev/null
    run_case "step3 dest symlink to file" "$s3b" "$INSTALLER" "$s3b_archive" 7 \
             "deploy step \(engine cp\): '\.env' destination is a symlink" \
             "symlink:.env=$s3b_ext" mirrored-only
    s3b_log="$CASE_LOG"
    cases=$((cases + 1))
    if [ -L "$s3b/.env" ]; then
        pass "step3 symlink left intact" "the link itself was not replaced"
    else
        fail "step3 symlink left intact" "the destination symlink was replaced"
    fi
    cases=$((cases + 1))
    if [ "$s3b_before" = "$(sha256sum -- "$s3b_ext" | cut -d' ' -f1) $(stat -c '%.9Y' -- "$s3b_ext")" ]; then
        pass "step3 external target intact" "content and mtime unchanged, so nothing copied through the link"
    else
        fail "step3 external target intact" "the external target was overwritten through the link"
    fi

    # 3. The block hazard, and the Step 0 gate closing. A FIFO destination was
    # measured making this engine wait forever; the preflight must refuse it
    # before cp runs. run_case's watchdog is what makes "promptly" falsifiable:
    # a blocking engine returns 124 and fails the expected 7.
    s3c=$(new_prefix step3-fifo)
    build_archive "$s3c/pkgs/tools.2026-08-11_000000.tar.gz"
    s3c_archive=$(resolve_archive "$s3c")
    mkfifo "$s3c/.env" 2>/dev/null
    run_case "step3 dest FIFO refused promptly" "$s3c" "$INSTALLER" "$s3c_archive" 7 \
             "deploy step \(engine cp\): '\.env' destination is not a regular file" \
             "fifo:.env" mirrored-only
    cases=$((cases + 1))
    if [ -p "$s3c/.env" ]; then
        pass "step3 FIFO left intact" "refused before any copy, so the FIFO survives"
    else
        fail "step3 FIFO left intact" "the FIFO was replaced or removed"
    fi

    # 4. Directory destinations, empty and populated, both refused at exit 7.
    s3d=$(new_prefix step3-emptydir)
    build_archive "$s3d/pkgs/tools.2026-08-11_000000.tar.gz"
    s3d_archive=$(resolve_archive "$s3d")
    mkdir -p "$s3d/.env"
    run_case "step3 dest empty directory" "$s3d" "$INSTALLER" "$s3d_archive" 7 \
             "deploy step \(engine cp\): '\.env' destination is not a regular file" \
             "dest-dir:.env" mirrored-only

    s3e=$(new_prefix step3-populateddir)
    build_archive "$s3e/pkgs/tools.2026-08-11_000000.tar.gz"
    s3e_archive=$(resolve_archive "$s3e")
    mkdir -p "$s3e/.env"
    printf 'inside\n' > "$s3e/.env/occupant"
    run_case "step3 dest populated directory" "$s3e" "$INSTALLER" "$s3e_archive" 7 \
             "deploy step \(engine cp\): '\.env' destination is not a regular file" \
             "dest-dir:.env" mirrored-only
    cases=$((cases + 1))
    if [ -f "$s3e/.env/occupant" ]; then
        pass "step3 directory content intact" "refused without touching what was inside"
    else
        fail "step3 directory content intact" "the directory's content was disturbed"
    fi

    # 5. A preflight refusal must be distinguishable from a copy failure. Both
    # exit 7, so the code alone cannot tell them apart; the diagnostics must.
    cases=$((cases + 1))
    if [ -z "$s3b_log" ] || [ ! -f "$s3b_log" ]; then
        fail "step3 refusal distinguishable" "the symlink case never ran, so there is no refusal to read"
    elif grep -q "destination is a symlink" "$s3b_log" 2>/dev/null \
         && ! grep -q "copy failed" "$s3b_log" 2>/dev/null; then
        pass "step3 refusal distinguishable" "the preflight names the shape, not a failed copy"
    else
        fail "step3 refusal distinguishable" "a preflight refusal reads like a copy failure"
    fi

    # 6. The same refusal shapes on the rsync engine, where one exists. rsync
    # replaces a symlink destination and leaves its target alone, which is the
    # asymmetry the design keeps deliberately, so this asserts the engines
    # DIFFER here rather than that they agree.
    if [ "$have_rsync" = yes ]; then
        unset CASE_FORCE_CP
        s3f=$(new_prefix step3-symlink-rsync)
        build_archive "$s3f/pkgs/tools.2026-08-11_000000.tar.gz"
        s3f_archive=$(resolve_archive "$s3f")
        s3f_ext="$SCRATCH/external/rootfile.rsync.target"
        printf 'PRECIOUS\n' > "$s3f_ext"
        s3f_before=$(sha256sum -- "$s3f_ext" | cut -d' ' -f1)
        ln -s "$s3f_ext" "$s3f/.env" 2>/dev/null
        run_case "step3 rsync dest symlink to file" "$s3f" "$INSTALLER" "$s3f_archive" 0 \
                 'Installation successful' "symlink:.env=$s3f_ext" installed
        cases=$((cases + 1))
        if [ ! -L "$s3f/.env" ] \
           && [ "$(sha256sum -- "$s3f_ext" | cut -d' ' -f1)" = "$s3f_before" ]; then
            pass "step3 rsync replaced the link" "link replaced, external target untouched: the documented asymmetry"
        else
            fail "step3 rsync replaced the link" "rsync did not behave as the design records"
        fi
        CASE_FORCE_CP=1
    fi

    unset CASE_FORCE_CP
    suite "step3-rootfile"
    echo
fi

# ------------------------------------------------------------------ verdict ---
echo "=== VERDICT ==="
echo "suites    : ${SUITES:-none}"
echo "cases: $cases, failures: $failures"
# The verdict names the suites that actually ran. It must never rest on the
# requested step label alone, which is a number a caller chose rather than
# evidence of anything.
case "$SUITES" in
    *baseline*) ;;
    *) echo "Step $STEP: no baseline suite ran, so this run proves nothing about the installer."
       exit 1 ;;
esac
if [ "$failures" -eq 0 ]; then
    echo "Step $STEP: every assertion and every negative control behaved as designed."
    exit 0
fi
echo "Step $STEP: $failures assertion(s) failed. The harness or the installer does"
echo "not behave as this step records. Fix before relying on later steps."
exit 1
