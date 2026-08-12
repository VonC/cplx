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
