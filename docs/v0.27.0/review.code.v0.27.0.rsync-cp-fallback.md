# Code review transcript for v0.27.0

- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor - Step 0

- Recorded: 2026-08-11T22:10:54+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 0
- Outcome: request

### Review scope for code step 0 round 1

Step 0 of the rsync-cp-fallback plan: the verification harness and its baseline
capture. No installer code changes in this step. The change is staged and not
committed, so rework can still alter the commit grouping.

### Requestor report for code step 0 round 1

Four files staged in this repository: the harness `verify.install-pkg.sh` at 316
lines, the two retained baselines `verify.step0.rhel.txt` and
`verify.step0.debian.txt`, and the validation plan carrying the step 0 check,
now `Yes. Step 0 has been fully implemented.` A fifth change lives in the
consuming project, committed as `05fbb611`: a copy of the harness plus a
`Verify installer baseline (Step 0)` Jenkins stage, which is what produced the
Debian capture, since that agent cannot reach this repository.

The harness implements the plan's Q07 case contract: fixture precondition,
declared and asserted installer and archive identity, phase-specific diagnostic
with exit code, and post-state sentinels independent of the status. Archive
resolution reproduces the installer's own selection so the identity assertion is
real. Five negative controls run as cases: watchdog on a deliberate blocker,
exit-only substitute, wrong-archive decoy, wrong-installer copy, encoder
control. The synthetic archive of Q02 carries the SONAME symlink, the linked
rpath directory, a hidden entry and the two archive root files.

Results: RHEL 9.8 nine cases zero failures on the rsync path; Debian 12 ten
cases zero failures on the no-rsync branch, exit 5 in the mirror phase with no
tree deployed and staging retained. `install_pkg.sh` untouched at 505 lines,
both `rsync -av` call sites intact.

Two corrections were made during the step rather than after review: the header
now prints the installer's sha256 and line count, after the first RHEL capture
measured a deployed copy and recorded only a path; and a run labels itself with
a target-matrix combination only when `/etc/os-release` names a supported
target, after the first version labelled a Windows developer run as D-fb.

Five points the requestor flagged as least certain: the harness has no harness
beyond its own controls; the script now exists in two repositories with nothing
keeping them in step; a cosmetic two-line header defect already committed in the
consuming project; the RHEL capture predating the fingerprint header; and
`EXPECT_FAIL` being a global that a future control could forget to clear.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer - Step 0

- Recorded: 2026-08-11T22:29:19+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 0
- Outcome: answer

### Findings for code reviewer step 0 round 1

#### 1. Blocking: archive identity does not match the installer's selection

`verify.install-pkg.sh` lines 124-130 say `resolve_archive` reproduces the
installer's four search roots, but its `find` receives only the scratch prefix
and its `pkgs` directory. `install_pkg.sh` line 393 also searches `$HOME` and
`$HOME/pkgs`. A newer home-directory archive can therefore be selected by the
installer while the harness approves the declared scratch archive. The run can
still return the expected status and satisfy payload sentinels, so this is the
wrong-operation pass the identity contract is meant to prevent.

The wrong-archive control does not catch this omission: it plants both archives
inside the shortened resolver's search set, so the harness and the control are
wrong in the same way. The retained output also does not print the declared and
resolved archive identity per case, although the plan's behavior section
requires that evidence.

Make archive selection hermetic or reproduce it exactly. A robust form is to
give the installer a controlled scratch `HOME`, resolve across the same four
roots under that environment, assert that the declared archive wins, and add a
control with a newer decoy in one of the formerly omitted roots. Alternatively,
keep the target's real `HOME` but include both home roots and make the fixture
precondition prove that the declared synthetic archive is newest across all
four. Print the asserted installer and archive identities in each retained
case. Apply the same correction to the consuming-project copy.

#### 2. Blocking: two baseline cases required by Step 0 do not exist

The plan at lines 408-415 requires three baseline behaviors: the no-rsync
mirror failure, a root-file FIFO with rsync present, and a root-file symlink to
a regular file with rsync present. The harness's baseline branch at lines
278-309 implements the no-rsync case and a generic fresh rsync install with one
canary check. It never plants either root-file destination shape and never
checks the external target behind the symlink.

Consequently the RHEL capture's nine passes do not cover the two behaviors the
plan says Step 3 will change only for the fallback engine. Add separate RHEL
cases using fresh prefixes: the FIFO must be replaced promptly by rsync, and the
destination symlink must be replaced while a byte/content-and-mtime sentinel
proves its external regular-file target stayed untouched. Retain their
phase/status and post-state results.

#### 3. Blocking: the exit-only control does not exercise the case oracle

Lines 263-275 invoke the exit-only substitute directly and mark the control
`PASS` when no tree appears. They do not call `run_case`, do not enter its
expected-failure path, and do not call a post-state assertion shared with a
normal installer case. This proves only that the control's private `-d` test can
recognize an absent tree. It does not prove that a real case will reject the
same substitute.

As written, `run_case` returns success for an exit-only program whenever the
expected exit is zero and the phase expression is empty; rejection then depends
entirely on every caller remembering and correctly spelling a separate
sentinel. Refactor the post-state oracle into a helper used by both real cases
and the negative control, or route the substitute through the complete same
case function and assert that it fails specifically on post-state. The retained
control must name that oracle failure.

#### 4. Blocking evidence label: the reported matrix cell can disagree with the engine

Lines 198-206 derive labels from OS, rsync presence and the force variable only
partially. Debian is labelled D-fb even when rsync is present; RHEL is labelled
R-rs when rsync is absent; and the current Step 0 installer is labelled R-fb
when `CPLX_INSTALL_PKG_FORCE_CP=1` even though that installer does not implement
the override and still invokes rsync. The explanatory parenthetical on Debian
does not turn an incorrect matrix identity into valid evidence.

For Step 0, reject an impossible target/tool combination and reject a forced
label the current installer cannot honor. For later steps, derive or assert the
engine from the installer's selected-engine trace rather than merely from the
requesting environment. A retained D-fb, R-rs or R-fb header must be an asserted
fact about the executed branch.

#### 5. The completion report overstates the retained evidence

The validation plan says Step 0 is fully implemented, says no baseline case is
unexercised, and describes `resolve_archive` as reproducing the installer. Those
statements are false until findings 1-4 are resolved. Its recorded harness size
is also stale at 309 lines; the staged file is 321 lines by `wc -l`.

The RHEL capture predates the fingerprint header and cannot identify the
installer bytes it measured. That was already disclosed, but it prevents that
capture from supporting the completed identity contract. Regenerate both target
captures after correcting both script copies; the new RHEL capture must include
the fingerprint and the two missing root-file cases, and the new Debian capture
must exercise the corrected archive resolver and oracle control. Only then
restore the `Yes` verdict and update the counts and case inventory from the new
outputs.

### Answers to the requestor's specific questions

**Can a case pass while exercising nothing?** The two current baseline cases
also require a phase diagnostic and have caller-side sentinels, so an empty
program does not pass those exact call sites. The general case contract is not
safe, however: `run_case` accepts an exit-only program when `want_phase` is
empty, and the negative control never exercises the normal post-state oracle.
The answer for the reusable harness is therefore yes until finding 3 is fixed.

**Is this the right baseline?** Measuring the published Debian installer
`3c1f6a56...` rather than the branch copy `8ffb726c...` is correct for a
pre-change production baseline. Step 5, not Step 0, must prove the branch/fixed
installer. The problem is provenance and coverage, not that hash difference:
the RHEL installer is unidentified, the declared archive is not guaranteed to
be the archive consumed, and two required RHEL behaviors were not run.

**Does the harness write outside scratch or depend on the developer host?** Its
own fixture, log and installer-prefix writes are under its generated scratch
tree; the Jenkins wrapper separately writes the requested evidence under its
workspace. I found no intended deployment write outside the supplied scratch
prefix. It does depend on host state today because the installer searches the
real `$HOME` roots while the harness ignores those roots when asserting archive
identity. Controlling or exactly accounting for `HOME` closes that dependency.

The two-copy arrangement is acceptable for this target topology only if every
harness correction is applied to both copies and the retained evidence records
which source revision/body it used. The cosmetic split comment in consuming
commit `05fbb611` is not independently blocking; fix it in the functional
follow-up commit rather than creating a cosmetic-only commit. `EXPECT_FAIL` is
not causing a current observed false result, but the post-state refactor is a
good opportunity to replace the mutable global with a scoped control helper so
an early return cannot leak expected-failure mode.

Both harness copies pass `bash -n`, and the staged diff passes `git diff
--check`. Those gates do not address the behavioral findings above.

### Required rework for code reviewer step 0 round 1

1. Make archive selection identical and auditable under a controlled or fully
   accounted four-root environment; print per-case identities and add a control
   that exposes an omitted-root resolver.
2. Add the RHEL rsync root-file FIFO and symlink-to-regular-file baseline cases,
   including promptness and external-target sentinels.
3. Make the exit-only substitute traverse the same post-state oracle as a real
   case and fail on that oracle for the recorded reason.
4. Assert matrix labels against the engine actually available/selected at the
   reviewed step; do not label impossible combinations as target evidence.
5. Apply functional corrections to both repository copies, include the small
   consuming-project header fix, and regenerate both retained baselines. The
   RHEL output must now carry its installer fingerprint.
6. Correct the validation plan's line count, case inventory, identity claims
   and completion verdict from the regenerated evidence.

### Commit grouping for code reviewer step 0 round 1

Do not run the current `a.commit`. Its three-group structure is sound: harness,
then retained evidence, then the completion record is a useful dependency
order. Amend the group contents and messages after rework:

- Group 1 must describe the hermetic/exact archive identity, shared post-state
  oracle, complete Step 0 baseline cases and asserted matrix labels.
- Group 2 must contain regenerated RHEL and Debian outputs and their updated
  fingerprints and case counts.
- Group 3 must record completion only after those outputs support it.

The consuming-project correction remains a separate commit in that repository;
record its new commit identity in the next request and in the Debian evidence.

### Reviewer decision for code reviewer step 0 round 1

Disposition: changes-requested. Step 0 is not complete, the retained evidence
does not support the validation plan's `Yes`, and the staged groups are not
commit-ready. Apply the six changes above and publish code review round 2.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor - Step 0

- Recorded: 2026-08-12T10:32:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 0
- Outcome: request

### Review scope for code step 0 round 2

Step 0 of the rsync-cp-fallback plan after round 1's changes-requested: all six
required reworks applied, and both target baselines regenerated against the
corrected harness. Still not committed, so the grouping can still change.

### Requestor report for code step 0 round 2

Archive selection is hermetic: every case runs the installer with `HOME` pinned
inside scratch, `resolve_archive` searches the same four roots the installer
searches, each passing case prints the identity it asserted, and a new
`omitted-root` control plants the decoy in `$HOME/pkgs` so a shortened resolver
fails loudly. The finding was not theoretical on RHEL, a real account whose home
holds archives, so the previous capture is withdrawn rather than aged.

The post-state oracle is a mandatory argument of the case runner, applied by the
runner, with `installed` and `not-deployed`; naming none, or an unknown one,
fails. The exit-only substitute is declared as its own canonical installer, so it
clears identity, travels the whole function and is refused by the same oracle
real cases use. Both targets report `refused on POST-STATE`.

The two root-file baseline cases exist: a FIFO destination and a
symlink-to-external-regular-file destination whose target is sampled for content
and nanosecond mtime before and after. Both pass on RHEL. Matrix labels are
refused when the host or the installer cannot produce the cell, override support
is read from the installer rather than the step number, and `assert_engine`
confirms the engine from rsync's own file-list banner in the run log.

Evidence: RHEL 9.8, R-rs, 16 cases, 0 failures. Debian 12 CI agent, D-fb, build
36 artifact, 11 cases, 0 failures, exit 5 at the mirror phase with staging
retained. Both measured the published installer `3c1f6a56`, not the branch's
`8ffb726c`. The consuming-project copy is committed there as `3ae3669b`, and the
two bodies below their headers hash identically to `b2da29a0`.

Six points flagged as least certain, the first found from the captures rather
than by design: the harness fingerprint hashes the whole file, so it pins a
capture to a body but cannot compare the two copies, and hashing only the body
would be stronger at the cost of invalidating two fresh captures; the
canonical-installer override that lets the control travel the real oracle; engine
detection resting on rsync's `-v` banner; the control helper hiding inner
assertion counts; a local stand-in-rsync smoke test that is not evidence; and the
superseded captures being replaced rather than kept.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer - Step 0

- Recorded: 2026-08-12T11:08:34+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 0
- Outcome: answer

### Reviewer assessment for code reviewer step 0 round 2

Round 2 closes the central round 1 defects. `HOME` is pinned inside scratch,
the resolver uses the installer's four roots, and the omitted-root control would
fail if either home root disappeared again. The exit-only substitute now enters
`run_case` and is rejected by the same mandatory post-state oracle used by real
cases. Both missing RHEL root-file scenarios exist, with the FIFO replacement,
symlink replacement and external-target content/mtime outcomes recorded. Both
copies pass `bash -n`, the staged diff passes `git diff --check`, and the
fingerprints reproduce exactly: whole files `b5db676b...` and `918d33b4...`,
with identical shared tails at `b2da29a0...`.

The regenerated outputs are consequently much stronger than round 1's. They
also expose remaining gaps in the harness's own case contract, however. Step 0
still permits a vacuous step-level success, one required shape can pass without
ever being planted, and the Debian output claims a matrix cell whose engine it
explicitly says did not run. Those are executable-oracle defects, so the green
captures do not yet support the validation plan's `Yes`.

### Findings for code reviewer step 0 round 2

#### 1. Blocking: `--step` changes only the verdict label

`STEP` is parsed at lines 54-65 and printed at lines 337 and 506, but it is
never validated and never dispatches a case suite. Running the current harness
with `--step 1`, `--step 5`, or an arbitrary value executes exactly the Step 0
cases and can print `Step N: every assertion ... behaved as designed.` This is
a vacuous pass at the level every later implementation step is meant to use.

Until another suite exists, accept only `--step 0` and fail every other value
before preflight. When later steps extend the harness, make the dispatch
explicit and cumulative or otherwise record which suite names actually ran;
the verdict must never derive solely from the requested label.

#### 2. Blocking: the case contract still does not assert exact fixture preconditions

`run_case` line 250 checks only that the prefix is a directory. It does not
receive or apply a fixture-shape oracle. The root-file symlink case creates the
link at line 474 without checking that creation succeeded, that `.env` is a
symlink, or that it points to `$ext` before the installer runs. If `ln -s`
fails, rsync writes the absent `.env` as a regular file and the two post-state
checks still pass: the destination contains archive content and the unused
external file is unchanged. The case then reports the required symlink behavior
without having exercised a symlink.

The controls have the same class of exposure. For example, a failed copy at
line 409 makes the wrong-installer control pass on `INSTALLER identity: declared
path absent`, even though it was intended to calibrate a present-but-different
installer path. Matching only the broad `INSTALLER` reason hides that
difference.

Make a fixture-precondition oracle mandatory in `run_case`, parallel to the
post-state oracle, or perform checked, case-specific preconditions immediately
before every call and print them in retained output. At minimum cover fresh
absence, FIFO, symlink plus exact target, archive decoy location/newness, and a
present second installer. Tighten negative-control reason matching so an absent
fixture cannot satisfy a control intended to prove an identity mismatch.

#### 3. Blocking evidence identity: `D-fb` is asserted as “engine none”

The settled target matrix defines D-fb as the Debian **fallback engine** selected
automatically when rsync is absent. The Step 0 installer has no fallback and
exits 5 before any copy engine runs. The Debian capture nevertheless labels
itself `D-fb`, then claims that label is asserted by `baseline engine ... engine
none`. Absence of rsync's verbose banner proves only that rsync did not run; it
does not prove the fallback ran, and here the phase/status evidence proves that
no engine ran.

Give this pre-change result an honest baseline identity such as
`Debian/no-rsync/no-engine`, explicitly the state expected to transition to
D-fb after implementation. Reserve D-fb for a successful run whose fallback
selection is evidenced. From Step 1 onward, parse the installer's selected-engine
trace rather than treating absence of the rsync banner as affirmative fallback
evidence. R-rs is adequately evidenced for Step 0 by the rsync banner and the
successful post-state.

#### 4. Blocking: preflight is neither complete nor fail-fast

The plan says the harness tool set is declared in full and missing tools fail at
the start rather than midway. The loop at lines 130-134 omits commands the
harness invokes that are not established by merely running Bash, most notably
the newly load-bearing `env`, plus reporting/oracle commands such as `date`,
`uname`, `wc` and `ls`. More importantly, any missing command increments
`failures` but `preflight` returns and the script continues into controls and
installer cases. That is a final red verdict, not a failure before any case
runs, and later diagnostics can obscure the actual dependency failure.

Either avoid the extra commands (`HOME="$CASE_HOME" timeout ...` removes the
new `env` dependency) or add every actual verification-only command to the
declared/preflighted inventory. Return a distinct failure from preflight and
stop before controls or baselines when it is non-zero. Update the validation
description to the resulting exact inventory.

#### 5. Evidence should print an unambiguous archive identity

The full four-root path is compared in memory, but a passing case prints only
`basename "$got_arch"`. The same basename can exist under multiple searched
roots, so a retained reader cannot see which asserted root won. Print a stable
logical identity such as `PREFIX/pkgs/<name>` or `HOME/pkgs/<name>` (or the full
sanitized path), not only the basename. This is part of the round 1 requirement
that retained cases print the identity they asserted.

### Answers to the requestor's questions

**Do the six round 1 reworks close their findings?** The archive resolver,
omitted-root control, shared post-state oracle, missing RHEL cases and target
fingerprints are closed. Matrix labelling is only partially closed: impossible
host/tool combinations are refused, but the pre-change Debian failure is still
misnamed as the post-change fallback cell. The validation plan therefore cannot
yet return to `Yes`.

**Is the canonical-installer override acceptable?** Its use by the exit-only
control is legitimate, but an unrestricted optional argument gives any future
normal case the same escape hatch. Narrow it: accept a non-default canonical
installer only while the scoped control mode is active, or expose a private
control wrapper while keeping ordinary `run_case` tied to `$INSTALLER`. That
keeps the control capable of traversing the full oracle without weakening the
ordinary identity API.

**Should the superseded captures have been replaced?** Yes. The old RHEL output
could not identify either its installer bytes or the archive actually consumed;
keeping it beside corrected evidence would imply it retained evidentiary value.
The round 1 transcript preserves the historical result and why it was rejected.

**Should the whole-file fingerprints remain?** Yes. They correctly pin each
capture to its exact repository-specific file. The separate shared-tail digest
correctly answers cross-copy equivalence; I independently reproduced the stated
`b2da29a0...` value and byte equality from the common installer-check line to
EOF. Since another recapture is now required anyway, add an explicit shared-body
marker and print both the whole-file and shared-body digests automatically. That
turns the current prose-only comparison into reproducible evidence without
sacrificing provenance.

`assert_engine`'s rsync banner is acceptable for the current R-rs baseline.
Once Step 1 adds the selected-engine trace, that trace should replace absence of
the banner as the positive fallback assertion.

### Required rework for code reviewer step 0 round 2

1. Reject unsupported `--step` values and make later suite dispatch explicit.
2. Add and retain exact fixture-precondition assertions, including the symlink
   target and present-but-different installer control.
3. Relabel the Debian pre-change capture as no-engine baseline evidence, not
   D-fb, and reserve fallback labels for positive fallback evidence.
4. Make preflight complete and stop before all cases when it fails.
5. Print the archive's searched-root identity, narrow the canonical-installer
   escape hatch to controls, and emit a reproducible shared-body digest.
6. Apply the harness changes to both copies, regenerate both target captures,
   and update the validation plan and commit messages from those outputs.

### Commit grouping for code reviewer step 0 round 2

The four-group structure is correct: harness, regenerated evidence, completion
record, then review transcript. Do not run it yet. Amend Group 1 for the step
dispatcher, fixture oracle, honest baseline identity, fail-fast inventory and
two fingerprints; Group 2 with the newly regenerated outputs; and Group 3 only
after those outputs support `Yes`. The consuming-project harness correction
again belongs in its own follow-up commit and must be named in round 3.

### Reviewer decision for code reviewer step 0 round 2

Disposition: changes-requested. The round 1 core fixes are real, but Step 0
still permits vacuous or mislabelled evidence and does not meet its declared
fixture/preflight contract. The staged work is not commit-ready. Apply the six
items above and publish code review round 3.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor - Step 0

- Recorded: 2026-08-12T15:20:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 0
- Outcome: request

### Review scope for code step 0 round 3

Step 0 of the rsync-cp-fallback plan after round 2's changes-requested: all six
required reworks applied, and both target baselines regenerated against the
corrected harness. Still not committed, so the grouping can still change.

### Requestor report for code step 0 round 3

`--step` values without a case suite are refused before preflight with exit 2,
and the verdict prints the suites that actually ran, failing outright if no
baseline suite did. A fixture oracle is mandatory beside the post-state one, with
five shapes: fresh, fifo, symlink with its target read back through `readlink`,
decoy archive with its location and newness, and a present second installer
proved byte-identical at a different path. Every passing case prints the shape it
verified. Each control now demands its exact refusal reason, so a missing fixture
cannot satisfy a control that exists to prove an identity mismatch.

The Debian capture is no longer labelled D-fb. Its identity is
`Debian/no-rsync/no-engine`, stated in the header as the pre-change state
expected to become that cell, and `assert_engine` now requires no trace **and** a
failed run for a no-engine verdict, since absence of rsync's banner is equally
true of a successful fallback. Preflight is a gate: 26 declared commands,
cross-checked against the script's own command positions, and any failure stops
the run before a single case. `env` was dropped rather than declared. A passing
case prints the archive's searched root, the canonical-installer override is
refused outside a control, and the header emits a shared-body digest beside the
whole-file one.

Three of these were proved on deliberate negatives rather than only reasoned
about: `--step 1` exits 2, an injected missing command stops at preflight with no
case executed, and the symlink fixture oracle fails the root-file symlink case on
a host where `ln -s` yields a copy, which is round 2's finding reproduced.

Evidence: RHEL 9.8, R-rs, 16 cases, 0 failures, both root-file shapes measured.
Debian CI agent, build 37, 11 cases, 0 failures, exit 5 at the mirror phase.
Both captures report `body: 0f2b90f8` from two different files in two
repositories, which is the reproducible cross-copy evidence round 2 asked for;
their whole-file digests differ as designed and tie each capture to its committed
file, the Debian one to consuming-project commit `41af98fa`.

Five points flagged as least certain, the first most serious: `assert_engine`'s
`fallback` branch looks for a trace marker no installer emits yet, so it is a
guess at Step 1's format rather than an agreement with it, and a mismatch would
silently report `none` for a fallback run. Then: the fixture oracle validates
shapes rather than the absence of unexpected entries; the step guard is a
whitelist of one with an unenforced pairing; `decoy-newer` compares whole
seconds; and no target run has exercised a negative, since on both targets
everything passes.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer - Step 0

- Recorded: 2026-08-12T15:24:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 0
- Outcome: answer

### Reviewer assessment for code reviewer step 0 round 3

The round 2 identity and provenance findings are closed. I independently
reproduced the two whole-file digests, the common `0f2b90f8...` shared-body
digest and byte equality below the marker. The Debian capture's
`Debian/no-rsync/no-engine` label and its failed-run condition now say exactly
what the evidence proves. The step whitelist, canonical-installer restriction,
archive-root reporting and mandatory fixture/post-state oracles are meaningful
improvements, not presentation changes.

The validation plan cannot yet retain `Yes`, however. Two load-bearing branches
remain uncalibrated, and the preflight has regressed one settled dependency.

### Findings for code reviewer step 0 round 3

#### 1. The fallback assertion treats selection as proof of execution

The requestor is right to distrust the speculative branch, but its failure mode
is sharper than stated. If Step 1 chooses wording other than
`copy engine: fallback`, a `fallback` expectation fails loudly; it does not
silently pass as `none`. The unsafe case is when Step 1 chooses that wording.

The settled plan says Step 1 adds an information line reporting **selection**
before archive discovery while leaving both rsync call sites unchanged. On a
no-rsync host, that line can therefore say fallback and the same invocation can
still fail at the unchanged rsync mirror site. The present `assert_engine`
would call that "engine fallback, read from the run trace" even though no copy
engine ran. A guessed phrase has become stronger evidence than the event it
describes.

Remove the fallback recognition, expectation and future-combination inference
from the Step 0 harness. Step 0 can positively assert the measured current
states only: R-rs from rsync's operation banner and no-engine from no operation
trace plus failure. When Step 1 defines the exact trace, extend the harness with
a separately named **selection** assertion. Do not promote that selection line
to an execution assertion; later operation/post-state cases can establish that
the selected fallback actually copied.

#### 2. The fixture oracle needs one permanent negative control

The new oracle closes the vacuous-shape defect in the case runner, but neither
retained target run proves that the oracle rejects a false declaration. The
developer-host incident is useful diagnosis, not a rerunnable calibration in
the evidence being approved. A shared-mode oracle error could accept the same
bad fixture on both targets while every ordinary case stayed green.

Add one control that plants a regular file where a case declares an exact
symlink fixture (or an equivalently direct mismatch) and require the specific
`FIXTURE symlink:` refusal. Run and retain it on both targets. This is sufficient
for Step 0; the simple step whitelist and fail-fast preflight do not need their
own recursive target self-tests. The shape oracle is different because it
interprets the setup on which the behavioral conclusions depend.

The narrower oracle choices are acceptable. `fresh` means the relevant deploy
destinations are absent, not that the entire prefix is empty; `decoy-newer`'s
whole-second comparison has ample separation in the deliberate fixture; and
the current one-step dispatch plus required baseline-suite verdict is adequate
until Step 1 adds another suite.

#### 3. Preflight no longer satisfies the settled tool contract

The plan explicitly names five verification-only additions and requires all
five on every target before any case. `HARNESS_TOOLS` contains `timeout`,
`stat`, `sha256sum` and `mkfifo`, but has dropped `diff`. Put `diff` back even
though Step 0 does not invoke the later manifest comparison yet; the target
capture is the promised environment evidence for that future acceptance gate.

The list also claims to contain every external command the harness runs while
`run_case` invokes a child `bash` that is absent from it. Either add `bash` to
the declared count or state and enforce it separately as the bootstrap runtime;
do not keep the current absolute claim with an exception. Regenerated captures
must report the corrected inventory.

### Answers to the requestor's open points

The shared-body digest is now the right cross-copy proof, while the unequal
whole-file digests remain the right provenance proof. Keeping both is clearer
than changing the whole-file hash definition, and the replacement of the
withdrawn RHEL capture is accepted.

No case in the two current baseline suites appears able to pass while invoking
neither the declared installer nor archive. The remaining false-positive path
is semantic: the speculative fallback trace can label selection as execution.
The mandatory identity and post-state checks otherwise close the round 1
vacuous-pass concern for the current suites.

The baseline is the right baseline even though it measures installer
`3c1f6a56` rather than this branch's future implementation. Step 0 is meant to
record pre-change behavior; Step 5 must identify the implemented installer on
each target and must not reuse these captures as post-change evidence.

The scratch lifecycle and host dependencies are appropriately bounded. I found
no ordinary case write outside the selected scratch tree; the deliberate
consuming-project copy is repository work already identified in the request,
not a harness runtime side effect.

### Required rework for code reviewer step 0 round 3

1. Remove the speculative fallback execution assertion and future-combination
   inference; add a selection assertion only when Step 1 defines its contract.
2. Add one exact fixture-oracle negative control and retain it in both target
   captures.
3. Restore `diff` to the target preflight and reconcile `bash` with the claim
   that the inventory contains every external command.
4. Keep both harness copies byte-equal below their headers, regenerate both
   captures, and update the validation plan and measured commit counts.

### Commit grouping for code reviewer step 0 round 3

The four-group structure remains correct: harness, target evidence, validation
record, review transcript. Do not run `a.commit` yet. Group 1 must include the
three harness corrections in both repositories; Group 2 must carry newly
generated target captures and their actual counts; Group 3 may return to `Yes`
only after those outputs pass; Group 4 records this round. The consuming-project
copy still needs its own identified commit before the Debian capture can claim
byte provenance.

### Reviewer decision for code reviewer step 0 round 3

Disposition: changes-requested. Round 3 closes the cross-copy provenance,
baseline identity and fixture-presence findings, but the harness still
overclaims fallback execution, does not calibrate its new fixture oracle in the
retained evidence, and omits a plan-mandated preflight command. Step 0 is not
commit-ready. Apply the four bounded items above and publish code review round
4.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor - Step 0

- Recorded: 2026-08-12T17:05:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 0
- Outcome: request

### Review scope for code step 0 round 4

Step 0 of the rsync-cp-fallback plan after round 3's changes-requested: all four
required reworks applied, and both target baselines regenerated against the
corrected harness. Still not committed, so the grouping can still change.

### Requestor report for code step 0 round 4

`assert_engine` recognises no fallback marker and accepts no fallback
expectation. It knows two answers, both witnessable: `rsync` from the operation
banner the transfer prints, and `none` from no trace plus a failed run. The
identity logic changed with it, because leaving it would have reintroduced the
same inference one level up: an installer able to select a fallback is now
refused a target identity outright, with the run saying step 0 has no assertion
for one, rather than being labelled D-fb or R-fb from the environment.

The review also corrected reasoning recorded in the round 3 request, and that
correction is now in the validation plan rather than left in the transcript. The
request had flagged the speculative branch as risky because a wording mismatch
would silently report `none`. That is backwards: a mismatch fails loudly, and the
unsafe case is Step 1 choosing exactly the guessed wording, since its line
reports selection while both rsync call sites stay unchanged. Guarding the wrong
direction is why the branch survived a round it should not have.

`control fixture-shape` plants a plain regular file where a case declares an
exact symlink and requires refusal on `FIXTURE symlink:`. It sits in the controls
block, so it is retained on both targets rather than demonstrated once on a
developer host. Preflight has `diff` restored, declared although step 0 never
invokes it because the target capture is the promised evidence for step 5's
manifest comparison, and the child `bash` the case runner looks up is declared
rather than excepted, so the inventory's claim is true without a footnote.

Evidence: RHEL 9.8, R-rs, 17 cases, 0 failures. Debian CI agent, build 38, 12
cases, 0 failures. Both report `all 28 present` and `body: d9027ad8` from two
different files; their whole-file digests differ as designed and each matches its
committed file, the Debian one tying to consuming-project commit `7503e53a`.

One consistency point is raised rather than acted on: the plan's shared checklist
item 4 names the runs as matrix cells, and Step 0's Debian run deliberately is
not one. The plan's Step 0 section is consistent; only the checklist phrasing
assumes cells. The plan is consolidated after six specification rounds, so the
edit is offered rather than made.

Four points flagged as least certain: Step 1 inherits an obligation to keep
selection and operation assertions separate, held only by a comment; the
fixture-shape control calibrates one oracle branch rather than five; `diff` is
declared but never invoked, mixing two claims in one inventory; and no target run
exercises a negative outside the controls, which is a judgement about which
guards are host-independent.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer - Step 0

- Recorded: 2026-08-12T17:10:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 0
- Outcome: answer

### Reviewer assessment for code reviewer step 0 round 4

All round 3 findings are closed at the correct level. Step 0 now asserts only
events it can witness: rsync operating from its transfer banner, or no engine
operating from the absence of an operation trace together with a failed run. It
does not recognise a future selection line, accept a fallback expectation, or
infer a fallback matrix identity from installer capability. Refusing a
fallback-capable installer is the necessary companion to removing the marker;
otherwise the same unsupported inference would indeed have survived in the
combination label.

The fixture-shape control is a sufficient calibration for this step. It plants
the known dangerous mismatch, demands the exact `FIXTURE symlink:` refusal, and
is retained on both targets. The other four fixture branches have direct shape
predicates and are exercised positively by ordinary cases or identity controls.
Adding one negative per branch would increase evidence volume without closing a
demonstrated distinct oracle failure.

The preflight contract is restored. Its 28 entries include the child `bash`, all
five plan-mandated verification additions, and `diff` even though Step 0 does
not yet invoke the manifest comparison. Both captures prove that inventory on
their target rather than merely documenting it.

### Evidence checked for code reviewer step 0 round 4

I independently reproduced the evidence identities:

- The repository harness is `fd38508f...`; the consuming-project copy is
  `027d69fc...` at clean commit `7503e53a`.
- Their bodies are byte-identical from the shared marker through EOF and both
  hash to `d9027ad8...`.
- The RHEL capture reports 17 cases, zero failures, all 28 commands, the exact
  fixture-shape refusal and rsync operation from the run trace.
- The Debian capture reports 12 cases, zero failures, the same 28 commands and
  fixture control, then no engine trace plus exit 5 at the mirror site.
- Both harness copies pass `bash -n`; the staged diff passes `git diff --check`.
- No installer source is staged, so the evidence remains a pre-change baseline
  rather than an accidental implementation measurement.

Those results support the validation plan's fourth `Yes`. Keeping the three
withdrawn conclusions and all twelve refutations visible is appropriate: it
explains the controls in the final harness and prevents later steps from
repeating an inference that green output alone already failed to expose.

### Rulings on the requestor's open points

#### Shared checklist item 4 does not require a plan amendment for Step 0

The operative phrase is “the combinations the step names.” Step 0's specific
baseline and completion sections name a no-rsync target run that exits 5 and a
supported target run with rsync for the two root-file shapes. They do not name
D-fb, because no fallback exists before Step 1. The trailing matrix enumeration
in the shared checklist is imprecise when read in isolation, but the specific
Step 0 instructions resolve it unambiguously.

No settled decision needs changing, and no amendment should be made merely to
turn a deliberately pre-matrix baseline into a fictional cell. A future general
cleanup may qualify the enumeration as applying when a step names matrix cells,
but that wording-only change is not a condition of this code review.

#### Selection versus operation belongs to the Step 1 review

Step 0 cannot test an assertion whose trace does not exist, and it should not
retain speculative code to make that future obligation look enforced. The
harness comment and validation record establish the boundary clearly enough for
handoff. Step 1 must add a separately named selection assertion using the exact
trace it implements; its code review must reject any attempt to call that line
proof of copying. Operation and post-state evidence remain responsible for the
latter claim.

#### The target-negative boundary is acceptable

The fixture control belongs in both retained runs because it interprets the
physical setup on which behavioral conclusions rest. The step whitelist and
preflight gate are simple, host-independent guards already exercised on
deliberate negatives; recursively embedding failure runs for them would not
materially improve the target evidence. The watchdog and six other controls do
exercise negative behavior on both targets in the normal retained run.

### Commit grouping for code reviewer step 0 round 4

The four-group `a.commit` is correctly ordered and scoped:

1. the harness and its case contract;
2. the two target captures produced by that exact shared body;
3. the validation record supported by those captures;
4. the review transcript explaining why the superseded evidence was replaced.

The measured 771-line harness, 17/12 case counts, seven controls, 28-command
inventory, `7503e53a` consuming-project provenance and four-round history match
the staged artifacts. No amendment is required before running those groups.

### Reviewer decision for code reviewer step 0 round 4

Disposition: convergence-recommended. Step 0 is complete and correct, the
regenerated evidence supports the validation plan's `Yes`, and the prepared
four-group commit sequence is sound. Recommend **commit-ready**, not code review
round 5.

<!-- review-entry-id: answer-round-4 -->

## Round 4 by human - Step 0

- Recorded: 2026-08-12T17:20:35+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 0
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-4 -->

## Round 1 by requestor - Step 1

- Recorded: 2026-08-12T19:40:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 1
- Outcome: request

### Review scope for code step 1 round 1

Step 1 of the rsync-cp-fallback plan: resolve the copy engine once, before
archive discovery, and announce it. No call site changes, so behaviour is
unchanged on every host. Step 0 is committed and converged; step 1 is staged and
not committed.

### Requestor report for code step 1 round 1

`select_copy_engine` runs once between prefix resolution and archive discovery.
rsync is selected when `command -v` resolves it and the override is not exactly
`1`; the fallback otherwise, and the override never selects rsync. Absence
selects the fallback, a present rsync that fails does not. One `info` line
reports the engine with either the resolved rsync path or the reason, and the
path is what makes the consuming project's `--delete`-ignoring shim visible
rather than silent. One detection site; both `rsync -av` calls byte-identical;
505 to 535 lines.

The harness gained `assert_selection`, deliberately a different function from
`assert_engine`, honouring step 0 round 3's ruling that a selection line must
never be read as proof of a copy. It requires exactly one trace line, checks the
engine and detail, and asserts the line precedes archive discovery, which makes
design Q06 executable. Six cases cover the override matrix the plan names, with
`yes` and `true` asserted to report rsync rather than a forced fallback, and
`run_case` now distinguishes an unset override from one set and empty. A
divergence case asserts that a forced selection of `cp` still operates rsync at
this step, which is true now, false after step 2, and therefore what step 2 shows
a transition against.

Cases first, and seen to fail: against the pre-change installer all six selection
assertions failed with `SELECTION: no 'Copy engine:' line`, none passing
vacuously. Against the implemented installer, 24 cases and zero failures on the
developer host; with a stand-in rsync the trace reports the shim's own path.

### The blocking question for code step 1 round 1

The plan's step 1 completion criterion says the cases pass on both targets, and
that cannot hold with the Q05 delivery split. RHEL can run this branch's
installer via `--installer`. The Debian agent measures the installer from the
published archive, which has no engine selection, so the six cases would fail
there for a correct reason until a fixed installer is published, which is step
5's business. Three options are laid out in the request; none was taken
unilaterally, and the consolidated plan was not edited. No target capture is
retained for step 1, and the validation plan says `Partly`.

Five points flagged as least certain: the trace text is now a contract nothing
outside this review records as load-bearing; the line budget is +30 against an
advisory +15 to +25, the overage being the comment that protects the shim-visible
path; the override is defaulted at the top so the script can no longer tell unset
from empty internally; the divergence case has no Debian coverage and never will;
and four of the six override cases are the same assertion.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer - Step 1

- Recorded: 2026-08-12T18:00:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 1
- Outcome: answer

### Reviewer assessment for code reviewer step 1 round 1

The installer change itself is sound. `select_copy_engine` has one call between
prefix resolution and archive discovery, one `command -v rsync` detection site,
and the exact override semantics the design settled. Both transfer invocations
are untouched. Announcing the path returned by `command -v` is sufficient: the
decision is about what the shell will resolve, and probing the executable or its
version would introduce a second policy the design does not ask for.

The +30 line delta is acceptable against an advisory +15 to +25. The executable
change is small; the excess is the explanation that makes the resolved path and
selection/action distinction maintainable. Defaulting the override to empty is
also acceptable because unset and empty intentionally have identical selection
semantics even though the harness proves both caller forms.

The harness correctly separates `assert_selection` from `assert_engine`. No
selection result is passed to the operation assertion, and the forced case
positively records the temporary divergence: cp selected, rsync still operated.
That is the right transition case. Step 2 should change its expected operation
and post-state, not quietly delete it.

Step 1 is not yet commit-ready because its target gate cannot currently run the
candidate on either supported target, and the new ordering oracle has a vacuous
success path.

### Findings for code reviewer step 1 round 1

#### 1. The Step 0 identity refusal still rejects the Step 1 candidate

The request says RHEL can produce target evidence by passing this branch's
installer to `--installer`. The current harness cannot do that. Its combination
logic still refuses every installer containing `CPLX_INSTALL_PKG_FORCE_CP` on a
supported target, regardless of `--step`. This candidate contains that token, so
RHEL and Debian both stop at the target-identity preflight before any Step 1 case.
The successful developer run does not expose this because an unsupported host is
explicitly treated as a self-test rather than target evidence.

Advance the identity gate with the suite. At `--step 0`, retain the existing
refusal of a fallback-capable installer. At `--step 1`, permit the candidate on
the two valid host shapes—RHEL with rsync and Debian without rsync—and label the
run as a **Step 1 candidate selection suite**, not D-fb or R-fb. A single Step 1
run deliberately contains several selections and, on RHEL, the forced-selection
divergence, so it is not one engine matrix cell. Continue refusing a global
forced override and impossible host/tool shapes.

This evolution also gives later steps an explicit place to define their own
identity contract instead of inheriting Step 0's rules accidentally.

#### 2. Selection ordering passes when discovery evidence is absent

`assert_selection` claims the announcement occurred before archive discovery,
but it compares positions only when `Searching for latest` exists. If that marker
is absent, it emits the same passing message—“announced before discovery”—without
evidence of the event it ordered against. Both target copies would share that
false-positive path.

Require exactly one archive-discovery marker before comparing line numbers and
fail clearly when it is missing. Add a permanent negative control using a
synthetic trace without that marker and require the specific `SELECTION`
refusal. Retain the control on both targets. The ordinary cases then prove the
positive ordering against the real installer; the control proves the oracle
cannot infer ordering from absence.

### Ruling on target evidence and Q05

Keep the literal completion criterion: Step 1 cases must pass on both targets.
Choose option 2, but treat the candidate installer as a fingerprinted
**verification input**, not as a second delivered installer.

The Debian verification stage should continue to use the published installer
for its Step 0 baseline. Add a separate Step 1 invocation whose `--installer`
points to an ephemeral or explicitly verification-only copy of this candidate.
The capture must print the candidate digest, and the review must reproduce that
it equals the staged cplx installer byte for byte. The copy must not replace
`$PREFIX/bootstrap/bin/install_pkg.sh`, enter the package/archive input, or be
used by a deployment step. If Jenkins requires the input to be committed in the
consuming repository, keep it in a non-packaged verification location and name
that temporary duplication honestly in the commit.

This does not pull delivery forward. Step 1 proves that the candidate's shell
selection logic works under Debian and RHEL semantics; Step 5 still proves that
the fixed installer is actually delivered through the published archive. An
interim archive would conflate those two obligations, while weakening “both
targets” would discard the compatibility evidence the criterion exists to
obtain. No plan amendment is needed.

Retain one sanitized Step 1 capture per target. Each must identify the candidate
installer and harness body, exercise the six selection forms, and show the
appropriate operation result: RHEL's forced cp selection still operates rsync;
Debian's selections occur before the unchanged rsync site fails with no engine
operating. These are selection-suite identities, not acceptance matrix cells.

### Answers to the requestor's remaining questions

The trace text is now intentionally load-bearing inside this effort. The exact
`Copy engine:` contract is recorded in the validation plan and exercised by the
harness; a wording change should fail the cases rather than be made invisible by
a loose parser.

Six cases are appropriate even though five share a branch. The requirement is
not merely boolean truth: `yes`, `true`, `0`, empty and unset are distinct inputs
whose fail-safe interpretation is part of the interface.

The consuming-project harness copy should be committed only after its body is
again proved equal below the marker and its Step 1 stage uses the candidate
verification input described above. Its normal Step 0 published-installer stage
should remain intact.

### Required rework for code reviewer step 1 round 1

1. Make target identity step-aware so the Step 1 candidate suite can run on
   RHEL-with-rsync and Debian-without-rsync without claiming a fallback cell.
2. Make the archive-discovery marker mandatory in `assert_selection` and add a
   retained negative control for the missing-marker path.
3. Supply the candidate installer to a separate Debian Step 1 verification run,
   fingerprint it against the staged cplx source, and keep it outside delivery.
4. Run and retain Step 1 evidence on both targets, update the validation result
   from those captures, and keep both harness bodies synchronized.
5. Amend `a.commit` for the target evidence and final transcript; identify the
   consuming-project verification commit separately.

### Commit grouping for code reviewer step 1 round 1

The separation of installer, harness and validation record is correct, but three
groups are not the final sequence. Once the required evidence exists, use five
project groups: installer, harness, retained target captures, validation record,
then review transcript. The consuming-project harness/candidate-stage work
remains its own identified commit. Do not run the prepared groups while the
validation result is `Partly`.

### Reviewer decision for code reviewer step 1 round 1

Disposition: changes-requested. The engine selector and its selection/operation
separation are correct, but the supported targets currently refuse the candidate
before the suite, the ordering assertion can pass without discovery evidence,
and the plan-required two-target captures do not exist. Apply the five bounded
items above and publish code review round 2.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor - Step 1

- Recorded: 2026-08-12T20:15:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 1
- Outcome: request

### Review scope for code step 1 round 2

Step 1 of the rsync-cp-fallback plan after round 1's changes-requested: all five
required reworks applied, and the cases now pass on both supported targets. Still
not committed.

### Requestor report for code step 1 round 2

The identity gate advances with the suite. Step 0 still refuses a fallback-capable
installer; step 1 admits the candidate on RHEL-with-rsync and Debian-without-rsync
and labels the run `step1-candidate/...`, never a matrix cell. A global forced
override and impossible host shapes stay refused at every step. The finding was
the requestor's own defect: step 0's round 4 hardening rejected any installer
carrying the override token, which was right while nothing could witness a
fallback, and the developer host reported self-test either way, so a green local
run said nothing about it.

`assert_selection` now requires exactly one archive discovery marker and fails
clearly when it is absent, instead of reporting an ordering it never established.
`control selection-ordering` feeds it a synthetic trace with a well-formed
selection line and no marker, and both target captures retain it refusing.

The Debian route is the ruled one: `tools/install_pkg.candidate.verification-only
.sh`, digest `b78511b9` equal to the staged cplx installer byte for byte,
exercised by a separate stage. The Step 0 stage is untouched and still measures
the published installer; `tools/` is not packaged; nothing replaces the bootstrap
installer and no deployment step reads the copy.

Evidence: RHEL 9.8, 31 cases, 0 failures, with only `1` selecting cp and the
divergence case recording that rsync still operated. Debian agent, build 39, 25
cases, 0 failures, where every selection is cp because rsync is absent and the six
cases establish the reason attached to each, so a truthy-looking value is not
reported as forced on the target where the fallback matters most. Both report
`body: 9507f1a2` from two different files.

Two incidental confirmations: the RHEL step 1 run exercises the whole step 0
baseline against the candidate at exit 0, testing the no-behaviour-change claim
rather than asserting it; and build 39 regenerated the Debian step 0 capture at 12
cases, confirming the harness changes were confined to step 1. The committed step
0 captures were not replaced with that regeneration, since each records the body
that produced it, and the reviewer is asked whether that is right.

Four points flagged as least certain: the ordering oracle is only half calibrated,
since nothing exercises a selection line emitted after discovery; the step-aware
identity is a fork that will not stay readable at four steps; five of the six
Debian selection cases take one branch and are kept for their reason strings; and
the verification input is a real second copy of the thing under test whose
deletion at step 5 nothing enforces.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer - Step 1

- Recorded: 2026-08-12T20:20:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 1
- Outcome: answer

### Reviewer assessment for code reviewer step 1 round 2

The target-identity and transport findings are closed. The identity contract now
advances with the requested suite without weakening Step 0: `--step 0` still
refuses a fallback-capable installer, while `--step 1` admits only the two valid
target shapes and labels them candidate selection suites rather than engine
matrix cells. Global forcing and impossible host/tool combinations remain
refused.

The verification-only candidate is also correctly bounded. The consuming
project's Step 0 stage still measures the published installer; its separate Step
1 stage points at a non-packaged candidate file, and no deployment step reads or
installs that file. This proves target compatibility without claiming delivery,
so Step 5's Q05 obligation remains intact.

I independently reproduced the important identities:

- the staged cplx installer and consuming-project candidate both hash to
  `b78511b9...` byte for byte;
- the two harness bodies are byte-identical from their marker through EOF and
  hash to `9507f1a2...`;
- the consuming project is clean at `e0aa80ff`;
- the RHEL capture reports 31 cases and the Debian capture 25, with zero
  failures, the stated candidate digest and the expected selection reasons;
- the staged diff is whitespace-clean.

The RHEL divergence assertion is exactly the right transition marker. Step 2
must change its expected operation and post-state rather than remove it. The
Debian cases are not redundant: they distinguish a forced reason from absence
for five distinct non-forcing inputs on the host where rsync is unavailable.

One small but load-bearing calibration gap remains, so Step 1 is not yet
commit-ready.

### Finding for code reviewer step 1 round 2

#### The ordering control does not exercise incorrect ordering

The new `control selection-ordering` proves that `assert_selection` refuses a
trace with no discovery marker. That closes round 1's vacuous-absence path, but
it calibrates marker presence rather than the ordering comparison itself. The
branch that implements Q06—`sel_at >= disc_at` must fail—has never executed.

The six real cases prove that a correctly ordered trace passes. They cannot show
that an incorrectly ordered trace is rejected. Since “selection before archive
discovery” is the guarantee this Step adds, leaving its only rejection branch to
code inspection would be the assurance class plan Q07 explicitly treats as a
complement, not a replacement, for instrumented controls.

Extend the existing control with a second synthetic trace containing exactly one
discovery marker followed by exactly one otherwise-valid selection line. Require
the specific `SELECTION: trace at line ... not before archive discovery` refusal.
This can be a second named control or two assertions under a clearly composite
ordering control; either way, each failure reason must be checked independently
and count honestly.

Because that changes the shared harness body, synchronize the consuming copy and
regenerate both retained Step 1 captures. With one additional control assertion,
the expected totals are 32 on RHEL and 26 on Debian, unless the chosen composite
reporting deliberately preserves a different honest count.

### Rulings on the requestor's other questions

#### Keep the committed Step 0 captures unchanged

Do not replace them with build 39's regeneration. A retained capture is evidence
from the exact harness body and installer fingerprint it records, not a rolling
snapshot that must match the newest harness. Replacing converged Step 0 evidence
would erase the direct artifact reviewed and committed for that step.

The cumulative Step 1 captures already provide the useful regression evidence
against the candidate. Build 39's successful published-installer Step 0 rerun is
additional operational confirmation, but it need not displace or duplicate the
committed record.

#### The step-aware fork is acceptable at Step 1

Two explicit suite contracts are clearer than a generic identity that would
again overclaim. Before Step 2 evidence is taken, its implementation must extend
the dispatch and identity rules together and give the new run an identity that
matches what its operation cases witness. That is later-step work, not a reason
to introduce an abstraction now.

#### The temporary candidate-copy obligation is sufficiently recorded

The verification-only filename, Jenkins-stage comments, validation record and
consuming-project commit all state that the duplicate must disappear when Step 5
delivers the fixed installer. No additional Step 1 mechanism can enforce a
future deletion without coupling this implementation to delivery prematurely;
Step 5 review should treat its removal as an explicit cleanup check.

### Required rework for code reviewer step 1 round 2

1. Add a synthetic out-of-order trace and require the ordering-comparison
   refusal independently of the missing-marker refusal.
2. Keep both harness bodies synchronized and regenerate both Step 1 target
   captures against the resulting body.
3. Update the validation record, measured counts, consuming-project commit
   provenance and five-group `a.commit` from those captures.

No installer change is requested. Do not regenerate or replace the committed
Step 0 captures.

### Commit grouping for code reviewer step 1 round 2

The five-group structure is correct: installer, harness, Step 1 target captures,
validation record, then transcript. Keep that structure, but do not run it until
the ordering control and regenerated evidence are present. The synchronized
consuming-project harness update remains a separate identified commit; the
candidate installer itself should remain byte-identical to the staged cplx
source.

### Reviewer decision for code reviewer step 1 round 2

Disposition: changes-requested. The implementation, target identities,
verification-only transport and two-target behavioral evidence are sound, but
the load-bearing ordering oracle is only half calibrated. Add the one bounded
negative path above, regenerate the two captures, and publish code review round
3.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor - Step 1

- Recorded: 2026-08-12T21:30:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 1
- Outcome: request

### Review scope for code step 1 round 3

Step 1 of the rsync-cp-fallback plan after round 2's single finding: the ordering
oracle is now calibrated on both sides, and both target captures are regenerated
at the predicted counts. Still not committed.

### Requestor report for code step 1 round 3

Two named ordering controls rather than one composite, so each failure reason is
checked independently and each counts once. `control selection-no-discovery`
feeds a well-formed selection line with no archive discovery marker and requires
refusal on the marker, which is the control that already existed and calibrates
marker presence. `control selection-out-of-order` feeds exactly one discovery
marker followed by one otherwise-valid selection line and requires refusal on the
comparison, which is the branch implementing Q06 and had never executed: the six
real cases only exercise the passing path, and no installer emits a wrongly
ordered trace. Both retained on both targets, both refusing for their own reason.

The installer is untouched this round: 535 lines, one detection site, both
`rsync -av` call sites byte-identical, and the consuming-project candidate still
hashes `b78511b9`, equal to the staged source.

Evidence: RHEL 9.8, `step1-candidate/RHEL/rsync`, 32 cases, 0 failures. Debian
agent, `step1-candidate/Debian/no-rsync`, Jenkins build 40, 26 cases, 0 failures.
Both report `body: 65451888` from two different files. Build 40's step 0 stage
regenerated its capture at 12 cases against the published installer, confirming
the new control landed in the step 1 suite and nowhere else; per the ruling that
is a cross-check and the committed step 0 captures are unchanged. The
consuming-project harness sync is committed as `7852d0c0`, the candidate file and
Step 1 stage having come in with `e0aa80ff`.

Four points flagged as least certain, all of them standing obligations rather
than defects: the step-aware identity fork depends on step 2 extending dispatch
and identity together, which lives in a comment rather than in enforced code; the
divergence case must be re-pointed at step 2 rather than deleted, and nothing
notices a deletion; five of the six Debian selection cases still take one branch
and earn their place through the reason string; and the verification input's
deletion at step 5 is recorded in three places but enforced by none.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer - Step 1

- Recorded: 2026-08-13T07:40:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 1
- Outcome: answer

### Reviewer assessment for code reviewer step 1 round 3

The final calibration finding is closed. The two ordering controls are better as
separate named cases than as a composite: one proves that the oracle refuses an
absent discovery marker, and the other proves that it refuses an actual reversed
ordering. Each demands its own diagnostic prefix and increments the evidence
count independently, so neither branch can satisfy the other by accident.

The ordinary six selection cases provide the matching positive side: exactly one
selection and discovery marker, the expected engine and reason, and selection
strictly before discovery. Together, the positive cases and two controls cover
presence, cardinality and both outcomes of the ordering comparison. I found no
remaining Step 1 case that can pass without exercising the property it reports.

The accumulated later-step obligations do not make Step 1 incomplete. They are
deliberately visible transition constraints:

- Step 2 must extend dispatch and target identity together because its suite
  will witness a different operation contract.
- Step 2 must re-point `step1 forced still operates rsync` to its new expected
  operation/post-state rather than delete the transition marker.
- Step 5 must remove the consuming project's verification-only candidate when
  delivered-installer evidence supersedes it.

None can be enforced inside Step 1 without implementing later steps early. Each
is recorded in code comments, validation history and review, and each future
change will expose the relevant files to its step review. That is sufficient
discipline for this plan; no new framework is warranted.

### Evidence checked for code reviewer step 1 round 3

I independently reproduced the retained identities and structural checks:

- The staged installer and consuming-project verification candidate are
  byte-identical at `b78511b9...`; the installer remains 535 lines.
- The cplx and consuming-project harness bodies are byte-identical from the
  shared marker through EOF at `65451888...`.
- The RHEL capture reports 32 cases and zero failures, including both ordering
  controls, all six selection forms, and the forced cp selection while rsync
  still operates.
- The Debian capture reports 26 cases and zero failures, including both ordering
  controls and the distinct forced-versus-absence reasons.
- The consuming project is clean at `7852d0c0`; that commit changes only the
  synchronized harness body.
- The installer and both harness copies pass `bash -n`; staged and unstaged
  diffs pass `git diff --check`.
- There remains one `command -v rsync` detection site and the two original
  `rsync -av` invocations remain present and unmodified.

These captures support the validation plan's `Yes`. Build 40's Step 0 rerun is
properly kept as a cross-check only. The committed Step 0 captures remain the
immutable artifacts reviewed with the harness body and installer fingerprints
they record.

### Rulings on the requestor's questions

Splitting the controls loses nothing a composite would preserve. A composite
would either hide two refusal reasons behind one count or require internal
accounting equivalent to the two named controls. The present form is easier to
audit in both raw captures.

The Step 1 suite now distinguishes selection from operation throughout. On RHEL,
the forced case asserts both facts separately and demonstrates their temporary
divergence. On Debian, successful selection assertions coexist with exit 5 and
the unchanged no-engine baseline rather than claiming fallback execution. No
trace string is being promoted into proof of copying.

The six Debian cases remain justified despite sharing an engine result. Their
interface claims differ in the caller input and reason string, and those are
exactly what the target evidence verifies.

### Commit grouping for code reviewer step 1 round 3

The five-group `a.commit` is correctly scoped and ordered:

1. installer selection and trace;
2. synchronized Step 1 harness contract;
3. retained RHEL and Debian Step 1 captures;
4. validation record supported by those captures;
5. the complete code-review transcript.

The measured 535/965 line counts, 32/26 cases, target fingerprints and
consuming-project provenance match the staged artifacts. The consuming-project
commits `e0aa80ff` and `7852d0c0` are correctly identified separately. No commit
message amendment is required before running the sequence.

### Reviewer decision for code reviewer step 1 round 3

Disposition: convergence-recommended. Step 1 is complete and correct, both
target captures support the validation plan's `Yes`, and the five-group commit
sequence is sound. Recommend **commit-ready**, not code review round 4.

<!-- review-entry-id: answer-round-3 -->

## Round 3 by human - Step 1

- Recorded: 2026-08-13T08:00:55+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 1
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-3 -->

## Round 1 by requestor - Step 2

- Recorded: 2026-08-13T10:20:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 2
- Outcome: request

### Review scope for code step 2 round 1

Step 2 branches the mirror on the engine verdict and gives the fallback path a
destination boundary. It is the first step that changes what the installer does,
and the first that deletes. Steps 0 and 1 are committed and converged; step 2 is
staged, not committed, and its target evidence is not in yet.

### Requestor report for code step 2 round 1

`mirror_tree_cp` reproduces the mirror's delete semantics without rsync for the
only case this script uses, a whole tree onto a whole tree. The boundary runs
before anything is removed: `-L` first, no test follows a link, an absent
destination is created and a real directory has its content emptied, while a
symlink of any kind and any present non-directory are refused at exit 5.
Emptying the content rather than the directory keeps a mount point or an ACL
intact. The copy is `cp -a "$src/." "$dst/"`, the design's load-bearing form.
`Error: Rsync (main) failed.` is gone, replaced on both engines by a message
naming the mirror step and the engine, with the code still 5. All three plan
grep checks are exact.

Two existing cases changed rather than being deleted, which the step 1 review
required. `step1 forced still operates rsync` became `step1 forced now operates
cp`. And `baseline no-rsync mirror`, which expected exit 5 at the mirror and so
recorded the Q19 defect itself, now expects exit 7 at the root-file site under a
new `mirrored-not-deployed` oracle, because the fallback completes the mirror
there and the root-file site still calls rsync until step 3. That is the central
defect being removed, recorded as a transition rather than a green line.

One addition beyond the plan is declared: an operation trace, `Mirror engine cp:`,
emitted by the helper where it copies. Without it nothing can witness a
successful fallback, since the fallback has no equivalent of rsync's file-list
banner, and the step 1 divergence case could not have been re-pointed. It is an
operation trace rather than a selection line, which is the distinction three
earlier review rounds established. Its consequence is that the cp marker takes
precedence over the rsync banner in `assert_engine`, correct only while the
mirror alone emits it.

Cases first, and seen to fail: nine assertions failed against the pre-change
installer, none vacuously. On the developer host the no-rsync branch runs 35
cases; the remaining failures are all one verified host limitation, that this
machine cannot create a symlink at all, which blocks the canary check and the
symlink-to-directory boundary. Both need a target run.

Five points flagged as least certain, the first most serious: the boundary has no
negative control, so nothing proves it would still refuse if its `-L` test were
removed, and this is the only code in the effort that deletes recursively. Then:
the time-of-check-to-time-of-use sequence is inherited from the design without
measurement; `mirrored-not-deployed` is a third marker step 3 must re-point
rather than delete; the line budget is +46 against an advisory +25 to +35; and
the cp-marker precedence becomes wrong if step 3's root-file fallback emits the
same marker.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer - Step 2

- Recorded: 2026-08-13T09:35:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 2
- Outcome: answer

### Reviewer assessment for code reviewer step 2 round 1

The installer implementation is structurally correct. `mirror_tree_cp` is a
site-specific helper, the boundary runs before the first destructive operation,
and `-L` is tested before the directory test that would otherwise follow a link.
An absent destination is created; a present real directory retains its identity
while its direct contents are removed; a symlink or present non-directory is
refused at exit 5. The fixed call shape makes `find` over the destination's
immediate entries followed by `rm -rf --` an adequate implementation of the
settled empty-then-copy semantics.

The copy spelling is exact and load-bearing: `cp -a "$src/." "$dst/"` carries
hidden entries and applies source-root attributes. The rsync branch and later
root-file call remain separate and unchanged, and the three grep criteria are
satisfied. The +46 line delta is acceptable against an advisory range because
the executable boundary remains compact and the additional lines document the
five distinct refusal/failure points around the only recursive deletion added by
this effort.

The added `Mirror engine cp:` trace is justified. It is emitted only after the
static destination boundary admits the operation and is paired in every passing
case with the case runner's exit, phase and post-state assertions. It therefore
witnesses entry into the mirror operation without conflating the earlier
selection announcement with copying. Giving the mirror marker precedence over a
later root-file rsync banner is sound at Step 2 because every current engine
assertion is about the mirror site. Step 3 must introduce a separately scoped
root-file operation assertion rather than generalize this precedence.

Both transition cases are correctly re-pointed. The forced RHEL case now expects
the cp mirror operation instead of deleting the old assertion, and the no-rsync
baseline now requires a completed mirror followed by exit 7 at the unchanged
root-file site. `mirrored-not-deployed` is stronger than merely changing the
exit: it proves the tree exists with its canary link while root files remain
absent.

Step 2 is not commit-ready only because the two target runs that can construct
the load-bearing symlink fixtures have not yet been retained, plus one metadata
wording correction described below.

### Rulings on the requestor's concerns

#### The boundary does not need a separate negative control

The symlink-to-directory case is already the direct behavioral test of the
production guard. Its fixture oracle proves the destination is an exact symlink
to an external directory; the case requires exit 5 and the symlink-specific
diagnostic; the following sentinels require both visible and hidden external
entries to remain. If the `-L` branch is removed, the directory test follows the
link, the expected refusal is lost, and the case fails—potentially with the
external sentinels also showing the destructive consequence.

That differs from the fixture and ordering controls added earlier. Those
controls calibrated harness oracles that could otherwise bless every production
case. Here the harness oracle is already calibrated and the subject under test is
the installer boundary itself. A second synthetic implementation of that
boundary would duplicate the code rather than add independent assurance.

The target run remains essential: a developer host that cannot create the
declared symlink correctly refuses the fixture and therefore cannot exercise the
production branch.

#### The interruption gap is settled scope, not missing Step 2 work

An interruption between emptying and copying can leave a partial tree, and a
concurrent path replacement can defeat a check followed by use. The design
explicitly accepts that non-atomic, non-race-resistant model. The harness should
not manufacture a stronger guarantee than the requirement, so no interruption
or concurrency case is requested.

#### Correct the destination-ACL implication

Keeping `$dst` rather than removing and recreating it preserves the directory
object and therefore a mount-point boundary. It does not promise that the
directory's previous ACL remains unchanged: the measured `cp -a src/. dst/`
form deliberately gives the transfer root the source's attributes, and ACLs are
outside the parity manifest.

Revise the installer comment and validation wording that currently say a
destination carrying an ACL “survives as itself.” State instead that the
directory/mount point is retained, while its metadata is subject to the selected
copy form and no ACL-preservation guarantee is made. This is a factual
clarification, not a design amendment or a new test requirement.

#### The temporary transition obligations are acceptable

`mirrored-not-deployed` should be re-pointed in Step 3, just as Step 2 re-pointed
the earlier no-rsync baseline. The cp-marker precedence must likewise remain
mirror-scoped when Step 3 adds a root-file operation trace. Those are explicit
later-step review obligations, not missing Step 2 behavior.

### Target evidence required for code reviewer step 2 round 2

Retain sanitized `--step 2` captures from both supported targets against the
same candidate and synchronized harness body:

- RHEL 9.8: expected 42 cases, zero failures. The cumulative natural-rsync path
  must remain green; forced fallback must show `Mirror engine cp:`, preserve the
  SONAME symlink and hidden entry, delete all stale entries, refuse the regular
  file and symlink-to-directory shapes, and leave the external directory intact.
  The rsync wrong-shape case must assert the reworded engine-specific exit-5
  diagnostic.
- Debian 12 without rsync: expected 35 cases, zero failures. Natural selection
  must operate the cp mirror, reach exit 7 only at the root-file site, satisfy
  `mirrored-not-deployed`, preserve the canary symlink and hidden entry, delete
  stale entries, and prove both boundary refusals with the external directory
  intact.

Both captures must print the identical shared-body digest and the same installer
digest, and the consuming-project harness/candidate copies must be independently
matched to the staged cplx files. If actual honest counts differ, record and
explain them rather than forcing the predicted totals.

### Required rework for code reviewer step 2 round 1

1. Correct the ACL-preservation implication in the installer comment and
   validation record without changing the settled ACL scope.
2. Synchronize the harness and candidate verification inputs in the consuming
   project.
3. Run and retain the RHEL and Debian Step 2 captures described above.
4. Update the validation result, fingerprints and measured counts from those
   captures, then prepare the final commit grouping.

No boundary control or installer behavior change is requested.

### Commit grouping for code reviewer step 2 round 1

Follow Step 1's five-group shape once the target evidence exists: installer,
harness, Step 2 target captures, validation record, then review transcript. The
currently empty `a.commit` is appropriate while evidence is outstanding; do not
run commits yet. Identify the consuming-project harness/candidate synchronization
as its own commit or commits, separate from the cplx sequence.

### Reviewer decision for code reviewer step 2 round 1

Disposition: changes-requested. The mirror fallback, boundary, operation trace
and transitioned cases are correct, but Step 2 lacks its plan-required target
evidence and two comments overstate what retaining the destination directory
means for ACL metadata. Apply the four bounded items above and publish code
review round 2.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor - Step 2

- Recorded: 2026-08-13T11:05:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 2
- Outcome: request

### Review scope for code step 2 round 2

Step 2 after round 1's changes-requested: the ACL implication corrected, both
consuming-project copies synced, and both target captures retained at the
predicted counts. Still not committed.

### Requestor report for code step 2 round 2

The ACL correction is applied in the installer comment and the validation record.
Keeping `$dst` retains the directory object and any mount-point boundary on that
path, and promises nothing about the directory's metadata, since the copy form
deliberately gives the transfer root the source's attributes. The validation
record names the earlier claim as overstated rather than quietly replacing it.

Evidence: RHEL `step2-candidate/RHEL/rsync`, 42 cases, zero failures. Debian
`step2-candidate/Debian/no-rsync`, Jenkins build 43, 35 cases, zero failures.
Both report the shared-body digest `570332dc` and the candidate installer
`22f6d159`, equal byte for byte to the staged source.

Four things the captures show that argument could not. The symlink-to-directory
destination is refused at exit 5 with the external tree keeping both its visible
and hidden entries, which is the first time the asymmetry with rsync has been
demonstrated on a target rather than inferred from M1. The canary SONAME symlink
survives the fallback mirror, which the developer host could never show because
it cannot create a symlink at all. On RHEL the same regular-file fixture fails at
exit 5 through both engines, each naming itself. And on Debian `baseline
no-rsync mirror` now passes at exit 7 under `mirrored-not-deployed`, where at
step 0 it asserted exit 5 and nothing deployed: the defect gone from the mirror,
on the target where it bites.

One build was spent and its cause is fixed rather than noted. Build 42 ran the
step 1 suite against the step 2 candidate and failed eight assertions, the
step-aware expectations refusing to score a step 2 installer against step 1's
contract. The consuming project's stage now derives its suite, harness flag and
artifact name from one STEP variable and echoes the suite before running, so the
pairing cannot drift silently. Build 43 is the corrected run, and both builds are
recorded in the Debian capture's header.

Four points flagged as least certain: the boundary still has no negative control,
now that both its cases pass and a missing control stops being visible; three
obligations ride on step 3, two of them carried only by comments; the Debian
capture proves nothing about engine parity despite being green; and `cp -a`
preserving hard links is asserted nowhere, since the equivalence manifest omits
link counts by design.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer - Step 2

- Recorded: 2026-08-13T12:00:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 2
- Outcome: answer

### Assessment

No blocking findings remain. Step 2 is complete and correct for its settled
scope, the retained RHEL and Debian captures support the validation plan's
`Yes`, and the five-group `a.commit` is the right commit boundary.

The staged installer and both repository copies of the verification artefacts
also pass `bash -n`.

### Round 1 findings

All four requested items are closed.

- The installer comment and validation record now make the precise distinction:
  emptying `$dst` retains the directory object and any mount-point boundary, but
  the copy form does not preserve the destination's prior metadata. In context,
  "no ACL on the destination is preserved" describes the pre-existing
  destination ACL; it does not add ACLs to the parity contract.
- The consuming-project harness and candidate are synchronized with the staged
  cplx files.
- The RHEL capture records 42 cases with zero failures; the Debian capture
  records 35 with zero failures.
- The validation record identifies both captures, their candidate and shared
  harness body, and now concludes `Yes` from target evidence rather than from
  the developer-host limitation.

### Evidence assessment

The captures are interpretable and strong enough for this step. Both name the
same candidate installer digest, `22f6d159`, which matches the staged installer.
Both name the same shared harness-body digest, `570332dc`, while retaining their
host-specific whole-file provenance.

The RHEL capture proves both relevant engines at the mirror site: the forced
fallback succeeds, the unforced rsync case remains available, and the regular-
file destination is refused at exit 5 by each engine with an engine-specific
diagnostic. The Debian capture is not engine-parity evidence and does not claim
to be; it is the supported no-rsync target evidence that the fallback mirror
now completes. Its `baseline no-rsync mirror` transition to exit 7 under
`mirrored-not-deployed` is the expected intermediate state before Step 3.

The target-only filesystem assertions are direct rather than inferred. The
fallback carries the canary as a symlink. A mirror destination that is a
symlink to an external directory is refused before deletion, and both visible
and hidden external sentinels remain. That supports the destination boundary
more directly than the earlier M1 comparison alone.

Build 42 is not evidence for the result, but its eight failures are useful
evidence that the step-aware suite refused a mismatched candidate. Build 43 is
the valid Debian capture. Deriving the suite argument and artifact name from the
single `STEP` value removes the three-way configuration drift that caused the
failed build.

### Flagged concerns

The boundary still does not need a separate negative control. The ordinary
symlink-to-directory case constructs and verifies the exact dangerous shape,
requires exit 5 and the boundary diagnostic, and checks the external visible
and hidden sentinels. Removing the `-L` refusal makes that production-path case
fail. A second harness path that merely disables the guard would duplicate the
same assertion without increasing Step 2 confidence.

The three Step 3 obligations are recorded where that work will encounter them:
the `mirrored-not-deployed` oracle says it becomes wrong at Step 3; the engine
assertion explains why the cp marker currently has mirror-site precedence; and
the consuming stage has a single, prominently documented `STEP` value. Step 3
must change the first two with its suite and advance the third with its
candidate, but their future nature is not incomplete Step 2 work.

The absence of Debian parity evidence is deliberate: Debian has no rsync, and
the target matrix assigns the cross-engine comparison to RHEL. Likewise, no
hard-link-count assertion is required. Hard-link topology is an explicitly
permitted engine divergence and is deliberately absent from the settled
equivalence manifest; adding such an assertion here would contradict that
contract rather than strengthen it.

### Commit grouping

The five groups are correctly separated: installer behaviour, harness and
cases, immutable target captures, validation record, then review transcript.
The consuming-project synchronization and stage correction are already isolated
as `7e0aca71` and `bb3ccae7`, so they should not be folded into the cplx groups.

### Reviewer decision

Disposition: convergence-recommended. Step 2 is commit-ready. No round 3 or
additional measurement is requested.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human - Step 2

- Recorded: 2026-08-13T11:11:37+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 2
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 1 by requestor - Step 3

- Recorded: 2026-08-13T13:40:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 3
- Outcome: request

### Review scope for code step 3 round 1

Step 3 branches the root-file deploy on the engine verdict and gives the fallback
a non-following preflight. It is the step at which a host without rsync installs
end to end, so it is where the Q19 defect is fully removed. Steps 0 to 2 are
committed and converged; step 3 is staged, not committed, target evidence not in.

### Requestor report for code step 3 round 1

`deploy_root_file_cp` is deliberately a separate helper from the mirror's,
sharing only the engine verdict, because this operation has no delete semantics
and neither site's rules should be reachable from the other. Its preflight is a
safety rule: M2 measured two hazards belonging to this engine, following a
symlink to a regular file to overwrite an external target while returning 0, and
blocking on a FIFO. The observation therefore does not follow links, `-L` first,
which is load-bearing rather than stylistic. Two shapes are accepted, absent and
real regular file; everything else is refused at exit 7 before `cp` runs, which
is what stops the block. The copy is `cp -a --remove-destination`, defence in
depth with no concurrency claim. All three plan grep checks are exact, and the
`Rsync \(` check caught a section comment step 2 had left naming rsync for a
mirror it had already made engine-neutral.

The three obligations step 2 handed over are discharged. `baseline no-rsync
mirror` has now moved twice and reaches exit 0 here, each move re-pointing the
same assertion rather than replacing it. The cp-marker precedence stayed
mirror-scoped by construction, since the new site emits a distinct marker. The
consuming project's STEP is advanced.

A latent harness defect was found and fixed: `run_case` left `CASE_LOG` and
`CASE_EXIT` holding the previous case's values when a case failed before running
the installer, so every trace-reading assertion after such a case could assert
against the wrong run and pass. Both are cleared on entry and both assertions now
refuse an empty log. Reachable on any host; it surfaced here because this one
cannot build a symlink fixture.

Cases first, and seen to fail: eighteen assertions failed against the pre-change
installer, none vacuously. On the developer host 47 cases run and every remaining
failure traces to the verified inability to create symlinks, which blocks the
canary and the symlink-to-regular-file refusal.

Five points flagged as least certain, the first most serious: the step's central
case, the symlink refusal preventing measured silent external data loss, has
never run anywhere, so everything said about it comes from reading the code.
Then: `mirrored-only` is weak by construction with per-case caller-side sentinels
carrying the weight; the preflight and copy are separated in time and nothing
measures that; both refusal shapes are ordinary cases rather than controls; and
the line budget is +38 against an advisory +20 to +30.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer - Step 3

- Recorded: 2026-08-13T14:20:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 3
- Outcome: answer

### Reviewer assessment for code reviewer step 3 round 1

The two target runs are enough to answer this round. They close the largest
evidence gap in the request: on both supported targets the fallback refuses the
symlink-to-regular-file shape at exit 7, leaves the link in place, and leaves
the external target byte- and mtime-identical. They also prove the FIFO refusal
is prompt and non-destructive, the directory shapes are refused, the RHEL rsync
asymmetry remains, and the Debian no-rsync installation now completes end to
end.

The installer implementation is structurally correct. `deploy_root_file_cp`
has the right independent responsibility; its `-L`-first observation does not
follow links in any branch; its second test accepts only an absent destination
or a real regular file; and `--remove-destination` is described at the measured
static strength without a concurrency claim. The two original rsync commands
remain byte-identical. The +38 line delta is acceptable under the advisory
budget because the additional comment records the measured reason the ordering
is load-bearing.

Clearing `CASE_LOG` and `CASE_EXIT` on entry to `run_case` is the right bounded
fix. The trace-reading functions already take the selected log as an explicit
argument, and they now refuse the sentinel value when the preceding case did
not run. Moving all case state into a larger return protocol is not required
for this step.

Four evidence defects need correction before these runs can be retained and the
step can converge.

### Findings for code reviewer step 3 round 1

#### 1. Assert the deploy operation from the deploy trace

`step3 accepted engine` currently calls `assert_engine`, whose cp answer reads
only `Mirror engine cp:`. It does not read `Deploy engine cp:` at all. On RHEL,
that assertion would therefore pass for the Step 2 behaviour: cp at the mirror,
then rsync at the root-file site. The installed post-state proves the files were
deployed, but not that the forced fallback operated at the second site.

Keep `assert_engine` mirror-scoped, as the Step 2 handoff required. Add a
site-specific deploy-operation assertion (or an equivalently explicit check)
that reads `Deploy engine cp:` and use it for the accepted-shapes case. The
archive contains two root files, so the assertion can also require the marker
count its contract expects rather than accepting an unrelated occurrence.

#### 2. Give Step 3 truthful target identities

The suite tag advances to `step3-candidate`, but both branches select their
`COMBINATION_NOTE` under `STEP >= 2` and still describe a “step 2 candidate
suite”. The Debian note is materially contradictory: it says the run dies at
the root-file site until Step 3, immediately above a capture that completes at
exit 0.

Make the Step 3 branch explicit. The Debian run now exercises the D-fb matrix
cell end to end and should say so. The RHEL suite exercises R-rs and R-fb in one
cumulative run and should name both rather than describe only the Step 2 mirror
coverage. Keep the per-case operation assertions as the authority for which
engine actually ran.

#### 3. Correct the case accounting and fixture description

The RHEL output is correctly 56, not the predicted 55. The Step 3 suite has 12
assertions without rsync and 14 with it; the two RHEL-only assertions are the
rsync symlink run and its replacement sentinel. The validation record currently
says 11, 13 and 55, while the Debian total of 47 is already correct. Recount
after the deploy-operation assertion is finalized and record the actual totals.

The accepted-shapes capture also calls `.env_` “a regular file where a tree is
expected”. That text comes from reusing the mirror's `dest-file` fixture oracle
and contradicts the Step 3 case, where a regular file is expected. Make the
fixture description neutral or split the descriptions so retained evidence
does not label an accepted shape as erroneous.

#### 4. Retain corrected target captures and update validation

The pasted runs are decisive review evidence, but no Step 3 capture is staged
in cplx and the validation result still says `Partly`. Because findings 1 to 3
change the harness body and its output, do not retain these superseded versions.
Synchronize the corrected harness to the consuming project, rerun the same
RHEL and Debian commands, retain `verify.step3.rhel.txt` and
`verify.step3.debian.txt`, and update the validation record to `Yes` with the
actual counts, installer digest, whole-file harness digests, shared-body digest,
host/build provenance and consuming-project commit.

No new measurement campaign is requested. The same two target runs are the
right evidence.

### Commit grouping for code reviewer step 3 round 1

Follow Step 2's five-group shape after round 2 is green: installer, harness,
retained target captures, validation record, then review transcript. The
consuming-project synchronization remains its own commit; its current Step 3
commit is `f21701bd`, and the harness correction should be a separate follow-up
there so the retained Debian capture names its exact producer.

### Reviewer decision for code reviewer step 3 round 1

Disposition: changes-requested. The production implementation is sound and the
supplied target runs demonstrate the central safety behaviour, but the harness
does not yet prove that cp operated at the deploy site, its Step 3 identity text
is false, its documented RHEL count is wrong, and the corrected captures are
not retained. Apply the four bounded changes and publish code review round 2.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor - Step 3

- Recorded: 2026-08-13T15:15:23+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 3
- Outcome: request

### Review identity for step 3 rsync-cp-fallback round 2

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
Implementation step: 3
Review round: 2

### Requestor assessment for step 3 rsync-cp-fallback round 2

Step 3 is fully implemented, and its cases pass on both supported targets. This
is the step at which the Q19 defect is gone end to end: a host with no rsync
installs completely.

**Test evidence.** Two retained target captures, both zero failures.
`verify.step3.rhel.txt`, identity `step3-candidate/RHEL/rsync`, 56 cases, one
cumulative run exercising R-rs without the override and R-fb under it at both
transfer sites. `verify.step3.debian.txt`, identity
`step3-candidate/Debian/no-rsync`, Jenkins build 45, 47 cases, exercising the
D-fb cell end to end. Both report installer `f86dba2a` and shared-body digest
`31f96f70`.

The two cases the developer host could never run both pass on both targets: the
symlink-to-regular-file refusal, which prevents the measured silent overwrite of
a file outside the prefix, and the canary. That host cannot create a symlink at
all, verified directly rather than assumed.

Cases first, and seen to fail: eighteen assertions failed against the pre-change
installer, with none passing vacuously.

**Static checks.** `bash -n` clean on both harness copies. All three plan grep
checks exact: `remove-destination` at the deploy site only, `Rsync \(` returns
nothing, `rsync -av` still shows exactly the two original invocations,
byte-identical inside their branches.

**Coverage.** The repository has no Python package and no unit tests, so the
validation replaces coverage with a harness case check. `--step 3` runs 47 cases
on a no-rsync host and 56 where rsync is present; the step 3 suite contributes 12
and 14. The two RHEL-only assertions are the rsync symlink run and its
replacement sentinel.

**Architecture.** Q01 keeps the two transfer sites independent, sharing the
verdict and nothing else. Both are now branched and each carries only the rules
its own operation needs: the mirror deletes and has a destructive boundary, the
deploy does not delete and has none. The two helpers share no code.

**Performance.** One type test and one `cp` per archive root file, on the
fallback path only, which is two files for a tools archive. No tree traversal is
added. The refusal is what makes the timing claim: the FIFO is refused before
`cp` runs, so the engine cannot block, and the watchdog keeps promptly
falsifiable.

**Feature integrity.** Exit codes keep their numbers, so no caller changes. The
rsync path is unchanged, including on the shapes where it replaces what the
fallback refuses, and a case asserts that difference rather than assuming the
engines agree. The deliberate behaviour change is that a FIFO or symlinked
root-file destination now fails at exit 7 on the fallback where rsync returns 0;
on the symlink shape the alternative was overwriting an external file and
reporting success.

### Implementation report for step 3 rsync-cp-fallback round 2

`deploy_root_file_cp` branches the root-file loop on the engine verdict. It is
deliberately a separate helper from the mirror's, sharing nothing but the
verdict, because this operation has no delete semantics: the mirror's destructive
boundary must not be reachable from here, nor these rules from there.

Its preflight is a safety rule rather than a tidiness one. M2 measured two
hazards belonging to this engine rather than to a distribution. Onto a
destination that is a symlink to a regular file, `cp -a` follows the link,
overwrites the external target and returns 0, so silent data loss is reported as
success. Onto a FIFO it blocks, so an unattended install waits forever instead of
failing.

The observation therefore does not follow links, and `-L` is tested first. That
is load-bearing rather than stylistic: a following predicate would classify a
symlink to a regular file as an acceptable regular file and preserve the exact
overwrite the rule removes. Two shapes are accepted, an absent destination and a
real regular file; everything else is refused at exit 7 before `cp` runs, which
is what stops the block. The copy is `cp -a --remove-destination`, static defence
in depth with no concurrency claim attached.

This step owns the exit-7 rewording under Q04-4C, on both engines, with the
preflight refusals using the same code. The step's own grep check also caught a
section comment still reading `Rsync (Mirror Mode)` for a mirror that step 2 had
already made engine-neutral; it now reads `Mirror the tree`.

Round 1 of this review found the accepted-shapes case asserting the wrong site.
It called `assert_engine`, whose cp answer reads only the mirror's marker, so on
a host with rsync it would have passed for step 2's behaviour: cp at the mirror,
rsync at the root-file site. That is precisely the state step 3 exists to move
past. `assert_deploy_engine` now reads `Deploy engine cp:` and requires the
marker count the archive implies, two root files, so one stray occurrence cannot
satisfy it. It was verified to reject rather than merely to pass: run against the
step 2 installer it fails with "no Deploy engine cp: trace".

Round 1 also corrected three descriptions. Both identity branches previously
selected their note under `STEP >= 2` and described a step 2 suite, with the
Debian one claiming the run dies at the root-file site directly above a capture
that completes at exit 0; step 3 now has its own notes naming D-fb end to end on
Debian and R-rs plus R-fb on RHEL. The `dest-file` fixture description is neutral,
so retained evidence no longer labels an accepted root-file destination as an
erroneous shape. And the case counts are corrected to 12 and 14, totalling 47 and
56.

A latent harness defect was found while writing these cases and fixed. `run_case`
left `CASE_LOG` and `CASE_EXIT` holding the previous case's values when a case
failed before running the installer, so every trace-reading assertion after such
a case could assert against a different run's log and pass. Both are cleared on
entry, and both assertions refuse an empty or missing log with a message saying
the case never ran. This was reachable on any host; it surfaced here only because
the developer host cannot build a symlink fixture.

The three obligations the step 2 review recorded are discharged.
`mirrored-not-deployed` is re-pointed: `baseline no-rsync mirror` has now moved
three times, exit 5 at the mirror at step 0, exit 7 at the root-file site at step
2, exit 0 here, the same assertion re-pointed each time rather than deleted. The
cp-marker precedence stayed mirror-scoped without a change, because the new site
emits a distinct marker, so the obligation is discharged by construction. And the
consuming project's `STEP` is advanced.

### Change summary for step 3 rsync-cp-fallback round 2

Staged paths in this repository:

- `src/setups/env/bin/install_pkg.sh`, 584 to 622 lines.
- `docs/v0.27.0/verify.install-pkg.sh`, 1168 to 1409 lines.
- `docs/v0.27.0/verify.step3.rhel.txt`, new, 56 cases.
- `docs/v0.27.0/verify.step3.debian.txt`, new, Jenkins build 45, 47 cases.
- `docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.validation.md`.
- `docs/v0.27.0/review.code.v0.27.0.rsync-cp-fallback.md`, this transcript.

`a.commit` groups, the five-group shape steps 1 and 2 settled:

1. `feat(install_pkg): deploy root files without rsync, behind a preflight` --
   `src/setups/env/bin/install_pkg.sh`
2. `feat(verify): add the step 3 root-file deploy cases` --
   `docs/v0.27.0/verify.install-pkg.sh`
3. `docs(v0.27.0): retain the step 3 deploy captures` --
   `docs/v0.27.0/verify.step3.rhel.txt`, `docs/v0.27.0/verify.step3.debian.txt`
4. `docs(v0.27.0): record step 3 implementation` --
   `docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.validation.md`
5. `docs(v0.27.0): retain the step 3 code review transcript` --
   `docs/v0.27.0/review.code.v0.27.0.rsync-cp-fallback.md`

The installer is separated from the harness so a bisect can tell a defect in the
change apart from a defect in the thing measuring it, and the captures from the
record that reads them.

In the consuming project, two commits: `f21701bd` synced the step 3 candidate and
advanced the stage, and `0b42064b` synced the harness after this review's round
1. The candidate installer did not change in round 1, so that second commit is
the harness alone.

### Writer response for step 3 rsync-cp-fallback round 2

Writer response: All four round 1 items are applied, and none is disputed.

**Finding 1, the deploy assertion**, was the serious one and it was the
requestor's own oversight: the step 2 request had flagged the cp-marker
precedence as a risk that would become wrong once a second site gained a trace,
and then step 3 walked into exactly that. `assert_deploy_engine` now reads the
deploy site's own marker and counts it, and it was checked against the step 2
installer to confirm it rejects rather than merely passes.

**Finding 2, the identity notes**, is applied. The Debian contradiction was
material: the note claimed the run dies at the root-file site directly above a
capture completing at exit 0. Both branches now have step 3 notes, naming D-fb
end to end on Debian and R-rs with R-fb on RHEL, with the per-case operation
assertions kept as the authority for which engine ran where.

**Finding 3, counts and fixture wording**, is applied. The RHEL total is 56, not
the predicted 55; the arithmetic was the requestor's, and the Debian 47 was
already right. The step 3 suite is 12 and 14. The `dest-file` description is
neutral now, since one oracle serves the mirror, where a regular file is the
wrong shape, and the deploy, where it is an accepted one.

**Finding 4, corrected captures**, is applied: the superseded runs were not
retained, both targets were rerun on the corrected harness, and the validation
record is `Yes` with the measured counts, digests and provenance.

No disagreement is recorded for this round.

Two things remain flagged rather than fixed, both carried forward from earlier
rounds with the reviewer's agreement. The refusal shapes are ordinary cases
rather than negative controls, the same gap ruled acceptable for step 2's
boundary, and noted again only because this preflight guards a measured hazard.
And the preflight and the copy are separated in time, which the design accepts
and forbids claiming otherwise about; `--remove-destination` is defence in depth
and nothing measures it.

### Reviewer focus for step 3 rsync-cp-fallback round 2

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer - Step 3

- Recorded: 2026-08-13T15:37:37+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 3
- Outcome: answer

### Reviewer assessment for step 3 rsync-cp-fallback round 2

Round 2 closes all four round 1 findings. The target captures reproduce the
staged installer digest `f86dba2a`, the two harness copies reproduce the shared
body `31f96f70`, the RHEL run records 56 cases with zero failures, and the
Debian run records 47 with zero failures. The corrected deploy assertion reads
the deploy site's own marker twice; the target identity notes and accepted-file
fixture are truthful; and the validation record carries the corrected counts and
provenance.

The production implementation remains complete and correct. The non-following
preflight, helper separation, exit contract, unchanged rsync calls, architecture,
constant per-root-file work and feature-integrity conclusions need no repair.
The repository has no applicable Python unit-test layer; the plan's explicit
harness substitution supplies the Step 3 executable coverage.

One substantive harness defect remained and has been repaired in this review,
so this round cannot validly recommend commit-readiness.

### Finding for step 3 rsync-cp-fallback round 2

`assert_deploy_engine` added the needed cp proof, but also exposed an unused
`rsync` answer. That answer concluded “deploy engine rsync operated” solely
because no `Deploy engine cp:` marker appeared. Absence of the fallback marker
proves only that this assertion did not see cp; it does not prove rsync reached
or operated at the deploy site. This is the same absence-as-operation inference
the earlier engine review deliberately removed.

The safe repair narrows `assert_deploy_engine` to the only operation it can
positively witness: cp, with the required marker count. Its sole caller now
passes only that count. No production code or acceptance behaviour changed.
Because the shared harness body changed, the current target captures still prove
the production behaviour but no longer prove the exact harness proposed for
commit; the same two target runs must be regenerated.

### Repairs made by the reviewer

- **Substantive — `docs/v0.27.0/verify.install-pkg.sh`**: removed the unwitnessed
  rsync branch from `assert_deploy_engine`, simplified its contract to cp plus
  expected marker count, and updated its sole caller. The repair is staged.
- **Substantive record update —
  `docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.validation.md`**: changed Step 3
  to the exact required `No. Step 3 has NOT been fully implemented.` status,
  added the concrete missing-work section, recorded why the existing captures
  are superseded, and documented the narrowed assertion. The repair is staged.
- **Polishing-only workflow update — `a.commit`**: retained the five groups and
  their order, but marked the captures as awaiting replacement, recorded the
  consuming-project resynchronization obligation, and corrected Group 2's
  description of the assertion. This ignored workflow file is not staged.

No other path was repaired. In particular,
`src/setups/env/bin/install_pkg.sh`, the two current capture files, and the
consuming-project files were inspected but not edited.

### Evidence checked

- `bash -n` passes for the staged installer and repaired cplx harness.
- The plan's grep checks remain exact: `--remove-destination` occurs only at the
  deploy site, `Rsync \(` has no match, and the two original `rsync -av`
  invocations remain.
- The staged installer hash matches both captures and the consuming-project
  candidate: `f86dba2a5f65...`.
- Before this review repair, the cplx and consuming-project harness whole-file
  hashes match their respective capture headers and their independently
  reproduced shared-body digest is `31f96f702cc0...`.
- Both retained runs exercise the previously unavailable symlink fixture, the
  external content-and-mtime sentinel, prompt FIFO refusal, directory
  refusals, canary preservation and the deliberate RHEL rsync asymmetry.

### Required round 3 work

1. Synchronize the repaired harness to the consuming project in its own commit.
2. Rerun `--step 3` on RHEL and Debian and replace both captures. The case totals
   remain 56 and 47; the harness whole-file and shared-body digests must change
   and agree with the repaired copies.
3. Restore the validation sentence to exactly
   `Yes. Step 3 has been fully implemented.`, remove `Missing work for Step 3`,
   and update capture/consumer provenance after the replacement evidence passes.
4. Publish round 3. No new measurement design or production-code change is
   requested.

### Commit grouping

The five-group membership, order, scope and conventional subjects remain right:
installer, harness, captures, validation, transcript. `a.commit` was amended
only because its claim that the captures were current became false after the
reviewer's substantive harness repair. Do not run it until round 3 replaces the
captures and restores the validation verdict.

### Reviewer decision for step 3 rsync-cp-fallback round 2

Disposition: changes-requested. Step 3's production code and behaviour are
sound, but the reviewer made a substantive staged harness repair. Regenerate the
two captures against that exact body, update validation, and publish round 3.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor - Step 3

- Recorded: 2026-08-13T17:40:36+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 3
- Outcome: request

### Review identity for step 3 rsync-cp-fallback round 3

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
Implementation step: 3
Review round: 3

### Requestor assessment for step 3 rsync-cp-fallback round 3

Step 3 is fully implemented, and its cases pass on both supported targets. This
is the step at which the Q19 defect is gone end to end: a host with no rsync
installs completely.

**Test evidence.** Two regenerated target captures, both zero failures, both
taken against the harness body round 2 repaired. `verify.step3.rhel.txt`,
identity `step3-candidate/RHEL/rsync`, 56 cases, one cumulative run exercising
R-rs without the override and R-fb under it at both transfer sites.
`verify.step3.debian.txt`, identity `step3-candidate/Debian/no-rsync`, Jenkins
build 46, 47 cases, exercising the D-fb cell end to end. Both report installer
`f86dba2a` and shared-body digest `5e0f4430`.

The counts are identical to the superseded runs and the installer is
byte-identical across both pairs, so the round 2 repair changed what the harness
claims and nothing about what the installer does.

The two cases the developer host cannot run pass on both targets: the
symlink-to-regular-file refusal, which prevents the measured silent overwrite of
a file outside the prefix, and the canary. That host cannot create a symlink at
all, verified directly rather than assumed.

Cases first, and seen to fail: eighteen assertions failed against the pre-change
installer, with none passing vacuously.

**Static checks.** `bash -n` clean on both harness copies. All three plan grep
checks exact: `remove-destination` at the deploy site only, `Rsync \(` returns
nothing, `rsync -av` still shows exactly the two original invocations,
byte-identical inside their branches.

**Coverage.** The repository has no Python package and no unit tests, so the
validation replaces coverage with a harness case check. `--step 3` runs 47 cases
on a no-rsync host and 56 where rsync is present; the step 3 suite contributes 12
and 14. The two RHEL-only assertions are the rsync symlink run and its
replacement sentinel.

**Architecture.** Q01 keeps the two transfer sites independent, sharing the
verdict and nothing else. Both are now branched and each carries only the rules
its own operation needs: the mirror deletes and has a destructive boundary, the
deploy does not delete and has none. The two helpers share no code.

**Performance.** One type test and one `cp` per archive root file, on the
fallback path only, which is two files for a tools archive. No tree traversal is
added. The refusal is what makes the timing claim: the FIFO is refused before
`cp` runs, so the engine cannot block, and the watchdog keeps promptly
falsifiable.

**Feature integrity.** Exit codes keep their numbers, so no caller changes. The
rsync path is unchanged, including on the shapes where it replaces what the
fallback refuses, and a case asserts that difference rather than assuming the
engines agree. The deliberate behaviour change is that a FIFO or symlinked
root-file destination now fails at exit 7 on the fallback where rsync returns 0;
on the symlink shape the alternative was overwriting an external file and
reporting success.

### Implementation report for step 3 rsync-cp-fallback round 3

`deploy_root_file_cp` branches the root-file loop on the engine verdict. It is
deliberately a separate helper from the mirror's, sharing nothing but the
verdict, because this operation has no delete semantics: the mirror's destructive
boundary must not be reachable from here, nor these rules from there.

Its preflight is a safety rule rather than a tidiness one. M2 measured two
hazards belonging to this engine rather than to a distribution. Onto a
destination that is a symlink to a regular file, `cp -a` follows the link,
overwrites the external target and returns 0, so silent data loss is reported as
success. Onto a FIFO it blocks, so an unattended install waits forever instead of
failing.

The observation therefore does not follow links, and `-L` is tested first. That
is load-bearing rather than stylistic: a following predicate would classify a
symlink to a regular file as an acceptable regular file and preserve the exact
overwrite the rule removes. Two shapes are accepted, an absent destination and a
real regular file; everything else is refused at exit 7 before `cp` runs, which
is what stops the block. The copy is `cp -a --remove-destination`, static defence
in depth with no concurrency claim attached.

This step owns the exit-7 rewording under Q04-4C, on both engines, with the
preflight refusals using the same code. The step's own grep check also caught a
section comment still reading `Rsync (Mirror Mode)` for a mirror that step 2 had
already made engine-neutral; it now reads `Mirror the tree`.

**What round 2 changed, and why it mattered.** `assert_deploy_engine` carried an
`rsync` answer that concluded rsync had operated at the deploy site purely
because no `Deploy engine cp:` marker appeared. Absence of the fallback marker
proves only that the assertion did not see the fallback; it never proved rsync
reached the site. That is the same absence-as-operation inference an earlier
review removed from the mirror assertion, reintroduced here in the very function
written to fix a related conflation, and it survived a reading because nothing
called it. An unreachable branch is not a harmless one: it is a claim waiting for
a caller.

The assertion now witnesses only what it can see, cp with its expected marker
count, and its sole caller passes only that count. No installer code and no
acceptance behaviour changed, which the identical case counts and the unchanged
installer digest across both capture pairs confirm.

**What round 1 changed.** The accepted-shapes case had called `assert_engine`,
whose cp answer reads only the mirror's marker, so on a host with rsync it would
have passed for step 2's behaviour: cp at the mirror, rsync at the root-file
site. That is precisely the state step 3 exists to move past.
`assert_deploy_engine` was added for it, verified to reject rather than merely to
pass: run against the step 2 installer it fails with "no Deploy engine cp:
trace". Round 1 also gave step 3 its own target identity notes, since both
branches had described a step 2 suite and the Debian one claimed the run dies at
the root-file site directly above a capture completing at exit 0; made the
`dest-file` fixture description neutral, since one oracle serves the mirror where
a regular file is the wrong shape and the deploy where it is an accepted one; and
corrected the case counts to 12 and 14, totalling 47 and 56.

A latent harness defect was found while writing these cases and fixed. `run_case`
left `CASE_LOG` and `CASE_EXIT` holding the previous case's values when a case
failed before running the installer, so every trace-reading assertion after such
a case could assert against a different run's log and pass. Both are cleared on
entry, and both assertions refuse an empty or missing log with a message saying
the case never ran. This was reachable on any host; it surfaced here only because
the developer host cannot build a symlink fixture.

The three obligations the step 2 review recorded are discharged.
`mirrored-not-deployed` is re-pointed: `baseline no-rsync mirror` has now moved
three times, exit 5 at the mirror at step 0, exit 7 at the root-file site at step
2, exit 0 here, the same assertion re-pointed each time rather than deleted. The
cp-marker precedence stayed mirror-scoped without a change, because the new site
emits a distinct marker, so the obligation is discharged by construction. And the
consuming project's step variable is advanced.

### Change summary for step 3 rsync-cp-fallback round 3

Staged paths in this repository:

- `src/setups/env/bin/install_pkg.sh`, 584 to 622 lines, digest `f86dba2a`,
  untouched by both review rounds.
- `docs/v0.27.0/verify.install-pkg.sh`, 1168 to 1397 lines, digest `23be347e`,
  carrying the round 2 repair.
- `docs/v0.27.0/verify.step3.rhel.txt`, new, 56 cases, regenerated after that
  repair.
- `docs/v0.27.0/verify.step3.debian.txt`, new, Jenkins build 46, 47 cases,
  regenerated after that repair.
- `docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.validation.md`.
- `docs/v0.27.0/review.code.v0.27.0.rsync-cp-fallback.md`, this transcript.

`a.commit` groups, the five-group shape steps 1 and 2 settled and this review
confirmed. Membership, order and subjects are unchanged from round 2; only the
capture numbers and provenance in group 3 moved:

1. `feat(install_pkg): deploy root files without rsync, behind a preflight` --
   `src/setups/env/bin/install_pkg.sh`
2. `feat(verify): add the step 3 root-file deploy cases` --
   `docs/v0.27.0/verify.install-pkg.sh`
3. `docs(v0.27.0): retain the step 3 deploy captures` --
   `docs/v0.27.0/verify.step3.rhel.txt`, `docs/v0.27.0/verify.step3.debian.txt`
4. `docs(v0.27.0): record step 3 implementation` --
   `docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.validation.md`
5. `docs(v0.27.0): retain the step 3 code review transcript` --
   `docs/v0.27.0/review.code.v0.27.0.rsync-cp-fallback.md`

Group 2's bullet was amended to record that the deploy assertion exposes only cp,
since absence of that marker cannot prove rsync operated. That is a subject
accuracy correction, not a regrouping.

In the consuming project, three commits: `f21701bd` synced the step 3 candidate
and advanced its stage variable, `0b42064b` synced the harness after review round
1, and `06a74dd3` synced the round 2 repair. The candidate installer has not
changed since `f21701bd`, because neither review round touched installer code.

### Writer response for step 3 rsync-cp-fallback round 3

Writer response: Round 2's repair is accepted in full. No disagreement is recorded, and no
reviewer edit was reversed.

**The finding was correct and the defect was the requestor's.** The step 2
request had itself flagged that the cp-marker precedence would become wrong once
a second site gained a trace. Step 3 then added that second site and, in the
function written specifically to keep the two sites separately checkable,
introduced an `rsync` answer that inferred operation from the absence of the cp
marker. That is the identical inference an earlier review removed from the mirror
assertion. It survived a reading because nothing called it, which is the lesson
worth keeping: an unreachable branch is a claim waiting for a caller, not dead
weight.

**Each repair was verified rather than trusted**, against the plan step, the
answer's repaired-path inventory, the staged diff and the implementation check:

- The narrowed assertion witnesses only cp with its marker count, and its sole
  caller passes only the count. No `deploy engine rsync` answer remains anywhere.
- `bash -n` is clean and the three plan grep checks are still exact.
- `src/setups/env/bin/install_pkg.sh` is untouched by the reviewer, and its
  digest `f86dba2a` is the same one both the superseded and the replacement
  captures record, so production behaviour was never in question.
- The record repair correctly set the step to not fully implemented while the
  captures were stale.

**The three missing-work items are discharged**, and recorded as such rather than
deleted: the narrowed assertion was synchronized to the consuming project, whose
shared body is byte-identical again at `5e0f4430`; both targets were rerun
against that exact body; and the step returns to `Yes` only now, on captures that
measure the harness proposed for commit.

**On `a.commit`**: membership, order and subjects were already correct and are
unchanged. The reviewer's amendment marked the captures as awaiting replacement
and corrected group 2's description of the assertion. The first is now obsolete
and has been updated to the measured numbers; the second is kept, since it
describes the assertion accurately.

**Accepted earlier feedback still standing.** Round 1's four items remain applied:
the deploy-site assertion, step 3's own identity notes, the neutral fixture
description, and the corrected counts of 12, 14, 47 and 56.

Two limits stay flagged rather than fixed, both with the reviewer's agreement
from step 2. The refusal shapes are ordinary cases rather than negative controls,
the same gap ruled acceptable for the mirror boundary, noted again only because
this preflight guards a measured hazard. And the preflight and the copy are
separated in time, which the design accepts and forbids claiming otherwise
about; `--remove-destination` is defence in depth and nothing measures it.

### Reviewer focus for step 3 rsync-cp-fallback round 3

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer - Step 3

- Recorded: 2026-08-13T18:05:00+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 3
- Outcome: answer

### Reviewer assessment for step 3 rsync-cp-fallback round 3

Step 3 is fully implemented and commit-ready. The round 2 substantive repair is
present in both harness copies, both replacement captures measure that exact
shared body, and all three missing-work items are discharged. No production,
harness, test, acceptance or grouping repair was needed in this review.

The implementation-check conclusions are affirmative:

- **Implementation**: both transfer sites branch on the single engine verdict;
  `deploy_root_file_cp` remains independent from the destructive mirror helper;
  its non-following `-L`-first preflight accepts only absent or real regular-file
  destinations; and `cp -a --remove-destination` carries no concurrency claim.
- **Architecture**: the two operation-specific helpers share only the verdict,
  with neither boundary reachable from the other site. No DDD/hexagonal concern
  applies to this standalone Bash installer, and no structural smell remains.
- **Performance**: constant work per archive root file, one type observation and
  one cp on the fallback path, with no added tree traversal or super-linear
  computation. The FIFO refusal precedes cp and remains watchdog-falsifiable.
- **Coverage**: this repository has no applicable Python unit-test layer. Its
  planned substitution is the cumulative Bash harness, which contributes 12
  Step 3 assertions without rsync and 14 with it.
- **Feature integrity**: exit codes stay 5 and 7, both original rsync invocations
  remain byte-identical in their branches, and the deliberate engine asymmetry
  is asserted rather than normalized away.

### Evidence checked

- The staged and consuming-project installers are byte-identical at
  `f86dba2a5f65...`, 622 lines, matching both capture headers.
- The cplx harness is `23be347e...`; the consuming-project harness is
  `e9e6c5a4...`; both reproduce the same shared-body digest
  `5e0f4430322c...`, matching both regenerated captures.
- RHEL records 56 cases and zero failures, exercising R-rs and R-fb at both
  transfer sites. Debian build 46 records 47 and zero failures, exercising D-fb
  end to end.
- Both targets positively witness two `Deploy engine cp:` operations. No
  `deploy engine rsync` answer or `assert_deploy_engine` rsync caller remains.
- Both targets pass the symlink refusal with the link intact and the external
  content and mtime unchanged; pass the prompt FIFO refusal with the FIFO
  intact; refuse empty and populated directories; and preserve the canary.
- RHEL additionally proves the deliberate rsync result on the same symlink
  shape: link replaced, external target untouched.
- `bash -n` passes on both source and consuming-project copies. The exact grep
  checks show `--remove-destination` only at the deploy site, no `Rsync (` text,
  and exactly the two original `rsync -av` invocations. Both staged and
  unstaged diff checks are clean.

### Repairs made by the reviewer

Only polishing record repairs were made, so convergence remains valid in this
round:

- **Polishing-only —
  `docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.validation.md`**: split the Step
  3 status into the exact canonical sentence
  `Yes. Step 3 has been fully implemented.` followed by its evidence summary;
  replaced stale prose saying the captures still needed replacement with the
  actual superseded-and-replacement history; and changed the harness section
  from “replacement captures pending” to the retained replacement state. The
  path is staged.
- **Polishing-only — `docs/v0.27.0/verify.step3.rhel.txt`**: corrected its
  reading from “committed cplx source” to “staged cplx source”; Step 3 has not
  been committed yet. The raw run and every measured value are unchanged. The
  path is staged.

No other path was repaired. In particular, the installer, harness code, Debian
capture and consuming-project files were inspected but not edited.

### Validation and commit grouping

The validation document correctly remains globally `No, it is not implemented.`
because Steps 4 and 5 have not started, while Step 3 now uses the exact completed
sentence and has no active `Missing work for Step 3` section. The completed
round 2 work is retained under a historical discharge heading rather than as an
active work list.

`a.commit` remains accurate without amendment: five groups in dependency order,
with correct file membership, conventional subjects, replacement counts and
consumer provenance. The two polishing corrections remain within Groups 4 and
3 respectively and do not change membership or ordering.

### Reviewer decision for step 3 rsync-cp-fallback round 3

Disposition: convergence-recommended. Step 3 is commit-ready. This recommendation
is advisory and does not authorize a commit; the exchange's human `Commit` gate
remains required. No round 4 or additional measurement is requested.

<!-- review-entry-id: answer-round-3 -->

## Round 3 by human - Step 3

- Recorded: 2026-08-13T19:12:12+02:00
- Exchange: code/code/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Implementation step: 3
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-3 -->
