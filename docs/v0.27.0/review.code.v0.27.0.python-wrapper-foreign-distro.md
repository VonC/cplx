# Code review transcript for v0.27.0

- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor - Step 0

- Recorded: 2026-08-31T15:45:10+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 0
- Outcome: request

### Review identity for step 0 python-wrapper-foreign-distro (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
Implementation step: 0
Review round: 1

### Code review evidence for step 0 python-wrapper-foreign-distro (round 1)

request_index_tree: 2bd88b6b2863903225ddbdeb382d61e355c74ad6
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 (sources: plan)
- shellcheck docs/v0.27.0/verify.wrapper-scope.sh (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: test(wrapper): retain the pre-change wrapper bytes
group 1 path: docs/v0.27.0/wrapper.pre-change.verification-only
group 2: test(wrapper): measure the pre-change baseline
group 2 path: docs/v0.27.0/verify.wrapper-scope.sh
group 3: test(wrapper): capture the step 0 baseline
group 3 path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
group 4: docs(wrapper): record step 0 completion
group 4 path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
staged path: docs/v0.27.0/verify.wrapper-scope.sh
staged path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
staged path: docs/v0.27.0/wrapper.pre-change.verification-only
```

### Requestor assessment for step 0 python-wrapper-foreign-distro (round 1)

Step 0 of the v0.27.0 python-wrapper-foreign-distro plan is fully implemented.
All seven of its completion criteria are answered by an executed run rather than
by reading the harness source, and each criterion maps to a named case below.

#### Verdict and the evidence behind it for step 0 python-wrapper-foreign-distro (round 1)

`bash docs/v0.27.0/verify.wrapper-scope.sh --step 0` reports 31 cases, 0
failures, `OBJECTIVE MET for step 0`. The retained capture is
`docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`.

Criterion to case:

- planted fixture shaped like a fresh deployment: `step0/runA/fixture` and
  `step0/runB/fixture`, each asserting the plant after making it;
- RUN A clean, tree shape and exit status recorded: `step0/runA/exit-status` 0
  plus four shape cases;
- RUN B planted, bootstrap delegated and the line-30 site failed:
  `step0/control-injection` observes exactly one injected failure, and
  `step0/runB/injected-call` records its exact argument vector;
- pre-change wrapper retained with its digest:
  `step0/retained-copy-matches-wrapper` compares the retained copy against the
  live file instead of printing both;
- fixture control: `step0/control/unplanted-fixture-fails` requires the refusal
  to carry the `FIXTURE` reason, so an unrelated failure cannot satisfy it;
- RUN B control: `step0/control/clean-run-carries-no-injection` proves the
  injection oracle can fail, by demanding it refuse the clean log;
- `setenv` digest recorded: `step0/setenv-sha256`.

#### Static check evidence for step 0 python-wrapper-foreign-distro (round 1)

`shellcheck` 0.10.0 exits 0 with no finding. Two scoped suppressions were added,
each carrying the reason it is correct: `SC2016` on the shim and stub generators,
whose single quotes are the point since they write another script's source, and a
file-level `SC2317` for functions the `control` helper reaches indirectly, which
is the same suppression and the same stated reason the reviewed
`verify.relocation-rpath.sh` carries.

Every command in the resolved validation set was run, and all three pass:

- `bash src/utils/lint_shell.sh`, the project floor declared by
  `.review-validation`: `lint_shell: 44 tracked scripts`, `lint_shell: clean`,
  exit 0;
- `bash docs/v0.27.0/verify.wrapper-scope.sh --step 0`, the plan addition: 31
  cases, 0 failures, exit 0;
- `shellcheck docs/v0.27.0/verify.wrapper-scope.sh`, the request addition: no
  finding, exit 0.

The request addition is not redundant with the floor. `lint_shell.sh` scopes
itself to tracked `*.sh` OUTSIDE `docs/`, on the stated ground that a harness
under `docs/<version>/` is one effort's frozen evidence and must not be edited to
satisfy a later gate. Its header says each effort adds its own harness to the
resolved set instead, which is exactly what the request addition does, so the new
harness is linted by the review that can still act on the result.

A correction worth recording, because it was nearly published as a false claim.
This assessment first stated that the project default was `ghog day` and did not
apply to cplx, since the repository has no `check.bat`, no `pyproject.toml` and
no pytest suite. That reasoning about `ghog day` is right and irrelevant: the
resolved set for this repository never contained it. The renderer resolved
`bash src/utils/lint_shell.sh` as the project source, which is a command that
does apply and that had not been run at the time. It has now been run and it is
green. An assumed default reported as not applicable is the same unfailable shape
this requirement exists to remove, pointed at the request itself.

#### Coverage, architecture, performance and feature integrity for step 0 python-wrapper-foreign-distro (round 1)

Coverage: the 100 percent unit rule targets `src\pdfss\tests\unit`, which belongs
to the consuming project. There is no unit-tested class file here, so there is no
percentage to report. The behavioural equivalent is the harness suite, held to
the case contract rather than to a percentage: every claim measured from the
wrapper's run, and two negative controls that must refuse for a named reason.

Architecture: the layering rule this project has is what may reach a SHIPPED
file, and Step 0 respects it. The harness and the retained wrapper live under
`docs/v0.27.0/`, are never packaged, and carry `verification-only` in the name
where they duplicate a shipped file. Nothing under `src/` was modified. The
DDD-Hexagonal criterion does not apply to a Bash and Batch project.

Performance: two wrapper runs and a grep over a log of at most a few dozen lines.
`count_calls` scans the log once per helper name, bounded by six names times the
log length, so it is linear in it. Nothing grows with the size of a deployment,
because the fixture is planted rather than discovered.

Feature integrity: no shipped file changed, so nothing can be impaired. The
wrapper on disk is byte-for-byte what it was, at `88c4e0d2`, and the retained
copy proves it.

#### THE SUBSTANTIVE FINDING, offered for the reviewer to confirm or refute for step 0 python-wrapper-foreign-distro (round 1)

The plan is internally inconsistent between Step 0 and Step 2, and this
implementation resolves it in one direction that the reviewer should check.

Step 2's third completion criterion reads: "the comparison is against STEP 0 RUN
B, the recorded pre-change mangling, so the step 2 pass is a measured change
rather than an assumption. The suite fails if that baseline artifact is absent,
rather than skipping the comparison."

Step 2 therefore REQUIRES a Step 0 baseline artifact to exist. Step 0's "files
involved" names only the harness and the retained wrapper, and creates no such
artifact, while four of Step 0's own criteria say "the capture records"
something. As written, Step 2 could not pass, because the artifact it must
compare against is one no step produces.

The resolution taken here is to retain
`docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`, following the naming the
relocation requirement established. The reviewer is asked to confirm that
reading, because accepting it means Step 0's "files involved" list should name a
third file, and the plan's Step 0 section is the place to correct it rather than
this implementation.

#### Three assertions the measurement corrected for step 0 python-wrapper-foreign-distro (round 1)

Recorded because each was written from the plan's prose and disproved by the
run, and because Step 2 compares against the measured baseline rather than the
assumed one.

1. `readlink -f` runs TWICE as setup, not once. The plan names line 12 of the
   wrapper; `setenv` line 7 calls it again, during the source and so still before
   `setenv` exports the search path at its own line 15. Decisions P6 and P9 are
   intact; only their arithmetic was wrong.
2. RUN B ENDS WITH EXIT STATUS ZERO. A non-zero status was expected, since line
   60 execs a path derived from an empty string and that file does not exist. The
   two `if` statements after the exec both take their false branch, and a false
   `if` with no else is a successful statement, so the wrapper's last command
   succeeds. The pre-change defect is SILENT. This strengthens rather than
   weakens Step 2, whose first criterion already demands a non-zero exit: that
   demand is now a measured change instead of a restatement.
3. `current/bin/_bin` is a DANGLING REFERENT, not a file. RUN B leaves
   `current/bin` holding `python python3 python3.13 python3_target`, with
   `python3_target` a symlink to `_bin` and the interpreter never moved aside.
   The plan's phrase "naming the resulting `current/bin/_bin` shape" is satisfied
   by the symlink target and the derived exec path. The reviewer should confirm
   that this is what the phrase meant, since Step 2 and Step 5 both assert
   against it.

#### Two smaller facts the reviewer should see for step 0 python-wrapper-foreign-distro (round 1)

- The wrapper is 90 newline-terminated lines; the plan's line budget says 91.
  Every other confirmed line number in the plan (12, 18, 30, 34, 47, 60, 62, 66)
  matches the file exactly, so this is a counting convention rather than a
  drifted target. Step 1's "under 115" should be read against the measured 90.
- The authoring host cannot run this suite. Windows refuses to create the
  fixture's symlinks, and the harness reports that as a `FIXTURE` failure rather
  than proceeding, which is the negative control working. The capture was taken
  on RHEL 9.8 purely as the nearest POSIX host. Step 0 remains host-agnostic by
  decision P1 and contains nothing RHEL-specific.

### Implementation report for step 0 python-wrapper-foreign-distro (round 1)

Step 0 writes no production behaviour. It captures what the CURRENT wrapper
does, twice, so every later step is judged against a measured baseline. Three
files were added and no shipped file was touched.

#### The harness for step 0 python-wrapper-foreign-distro (round 1)

`docs/v0.27.0/verify.wrapper-scope.sh`, new, 532 lines, the executable oracle of
the plan. It follows the shape the reviewed `verify.relocation-rpath.sh`
established: argument parsing, a step dispatch that refuses any step whose case
suite does not exist, a prerequisite preflight, numbered sections, `pass`,
`fail`, `chk`, `note` and `control` reporters, and a verdict block carrying case
and failure counts.

The instrument is a set of RECORDING SHIMS, one generated script per helper name,
placed first on the search path. Each logs one tab-separated line and then
delegates to the real tool by ABSOLUTE path; delegating by name would re-enter
the shim through the search path and loop. The line is

```text
helper <TAB> argv <TAB> search-path state <TAB> cwd <TAB> disposition
```

and its third field distinguishes `unset` from `empty` from a value, because that
difference is the subject of decision W3.

The `readlink` shim carries the one special rule the plan states: a call bearing
`-f` is ALWAYS delegated and never failed, so the bootstrap cannot stop the run
before a guarded site is reached. Injection is path-selective, matched on a
suffix, so failing `current/bin/python3` leaves `current/bin/python3_target` and
the venv `bin/python3` untouched.

The interpreter is a RECORDING SHELL STUB, decision Q05/E1, which keeps Steps 0
to 2 runnable on any host under decision P1. It is not a python and never runs
`-m venv`, which is exactly why Steps 3 and 5 use the real interpreter.

HELPERS AND INTERPRETER ARE COUNTED APART. The interpreter is the one caller that
is SUPPOSED to see the shipped search path, so folding it into the helper count
would make the Step 1 claim unfalsifiable in the direction that matters. Step 0
asserts both halves, so a change that took the helper count to zero by also
starving the interpreter could not pass here.

#### The fixture, and one thing that had to be derived for step 0 python-wrapper-foreign-distro (round 1)

`plant_fixture` builds

```text
<env>/bin/python                 the wrapper under test
<env>/bin/setenv                 a copy, asserted by digest, never written
<env>/bin/current -> ../current  a symlink, one level down
<env>/current/bin/python3 -> python3.13
<env>/current/bin/python3.13     the recording stub
```

The `bin/current -> ../current` indirection is not decoration. Line 37 of the
wrapper relinks `current/bin/python3` to `../../bin/python`, and a relative
symlink resolves against its own PHYSICAL directory. Only when `current` is a
symlink one level down does `<env>/current/bin/../../bin/python` land on
`<env>/bin/python`, the wrapper itself. The same shape puts `setenv`'s `senvDIR`
at `<env>`, which is what makes its `${senvDIR}/current/bin` agree with the
wrapper's `${DIR}/current/bin`. A flatter fixture runs but relinks to a dangling
path, and every later shape assertion would then measure the fixture's mistake
rather than the wrapper's behaviour.

#### The two runs for step 0 python-wrapper-foreign-distro (round 1)

RUN A, clean: exit 0, two delegated setup `readlink -f` calls, three `readlink`,
one `mv`, five `ln`, one interpreter call. All seven post-source helper calls
observe the shipped search path, and so does the interpreter. The resulting tree
has `python3` relinked to `../../bin/python`, the interpreter moved aside as
`python3.13_bin`, `python3_target` naming it, and no empty-derived path.

RUN B, planted: the same fixture with the line-30 site failed. Exactly one
injected failure is observed and its argument vector recorded. `python3_target`
becomes a symlink to `_bin`, the interpreter is never moved aside and never
reached, six `mv` and `ln` calls follow the failed `readlink`, and the run exits
ZERO.

#### The controls for step 0 python-wrapper-foreign-distro (round 1)

Two, and each demands a NAMED reason rather than any failure at all.

- `step0/control/unplanted-fixture-fails` runs the fixture assertion over an
  empty directory and requires the refusal to carry the `FIXTURE` prefix. A later
  green therefore cannot come from a tree that was never built.
- `step0/control/clean-run-carries-no-injection` points the injection oracle at
  the CLEAN log and requires it to refuse with the `INJECTION` prefix. Without
  it, the oracle that proves RUN B real would itself be unasserted, which is the
  decorative-gate shape the plan's four rounds kept finding.

#### The retained wrapper and the capture for step 0 python-wrapper-foreign-distro (round 1)

`docs/v0.27.0/wrapper.pre-change.verification-only` is a byte-identical copy of
`src/install/env/python/bin/python` at
`88c4e0d22207b387b6b0d24542ba5301164e01f6cc698c02945722493b7f5706`, kept now
because Step 5 runs it as a control on an agent that holds no cplx history.
Answer B1, rebuilding it later, was rejected because a reconstruction that fails
is indistinguishable from the defect it should show.

`docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt` is the retained capture, with
an authored header naming the harness, the target, the date, the purpose, the
host note, and the three corrections the run produced. The account name is
sanitized to `deploy-account`, which is the form every retained capture in this
directory already uses, and the pre-commit hook covers the same term.

### Change summary for step 0 python-wrapper-foreign-distro (round 1)

Four staged paths, four `a.commit` groups, ordered least to most dependent.

#### Staged paths for step 0 python-wrapper-foreign-distro (round 1)

```text
A  docs/v0.27.0/wrapper.pre-change.verification-only
A  docs/v0.27.0/verify.wrapper-scope.sh
A  docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
M  docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
```

`git diff --name-only` is empty, so every change is staged and nothing is held
back. `commit-plan-check.bat --format json` returns `state: valid`,
`ready: true`, with no diagnostics, and its group membership matches the four
paths exactly.

#### The four groups for step 0 python-wrapper-foreign-distro (round 1)

1. `test(wrapper): retain the pre-change wrapper bytes`, holding
   `docs/v0.27.0/wrapper.pre-change.verification-only`. First because it depends
   on nothing: it is a byte copy taken before anything changes the original.
2. `test(wrapper): measure the pre-change baseline`, holding
   `docs/v0.27.0/verify.wrapper-scope.sh`. The oracle, which asserts the copy
   above but is not required by it.
3. `test(wrapper): capture the step 0 baseline`, holding
   `docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`. Produced by running the
   harness, so it follows it.
4. `docs(wrapper): record step 0 completion`, holding
   `docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md`. Last,
   because a validation document whose purpose is to record that a step completed
   is a trailing documentation group and is not folded into the work it records.

#### What is not in this change for step 0 python-wrapper-foreign-distro (round 1)

No shipped file. `src/install/env/python/bin/python` and
`src/install/env/python/bin/setenv` are read and digested by the harness and are
byte-identical to their committed state, which is what makes this a baseline
rather than a change. Step 1 is the first step that edits the wrapper.

The commit has NOT been made. The four groups are staged and `a.commit` is
prepared, formatted with `wac.bat` and validated, waiting on this review and then
on the human commit gate.

#### Preceding commits in this working session for step 0 python-wrapper-foreign-distro (round 1)

Three commits landed before Step 0 began, and they are already in history rather
than in this review's scope. They are named here only so the reviewer can tell
them apart from the staged work.

```text
69e2b68 docs(v0.27.0): point every requirement at its hosts
2ae1fbb docs(v0.27.0): document the RHEL and Debian targets
c647ca5 chore(vscode): add oneagentctl to the dictionary
```

The second added `docs/v0.27.0/reference.environments.md`, which the third linked
from every requirement document. The Step 0 capture's host note relies on it, and
`plan.v0.27.0.python-wrapper-foreign-distro.validation.md` now carries a
`Reference environments:` line pointing at it.

### Writer response for step 0 python-wrapper-foreign-distro (round 1)

Writer response: Round 1 of the code family for this requirement. No reviewer answer exists yet,
so there is no accepted feedback to record and no disagreement to declare.

#### Feedback already applied, from the specification family for step 0 python-wrapper-foreign-distro (round 1)

The plan this step implements converged over four specification review rounds,
closed on 2026-08-31 with `convergence-recommended` and a human `Consolidate`.
Three of its settled answers shaped this implementation directly and are named so
the reviewer does not have to rediscover them:

- Q01/A1: Step 0 runs the unmodified wrapper TWICE, clean and planted, and the
  planted run can only be taken while the pre-change wrapper is still the file on
  disk. Both runs are implemented and both are asserted.
- Q04/D1: recording shims log every helper call with its inherited environment,
  and expected calls are asserted PRESENT before absence is concluded. Every
  count case in the suite asserts presence first.
- Q05/E1: a recording shell stub for Steps 0 to 2, the real interpreter for
  Steps 3 and 5. The stub is implemented and never claims to run `-m venv`.

The reviewer answer of specification round 4 also left one optional wording
clarification, separating a Git blob object id from a file-content SHA-256. That
applies to Step 4's manifest, which this step does not produce. The harness uses
`sha256sum` over file bytes and the capture labels the values `wrapper-sha256`
and `setenv-sha256`, so the distinction is respected here rather than deferred.

#### What this writer changed on its own initiative, and why for step 0 python-wrapper-foreign-distro (round 1)

Three assertions in the harness were written from the plan's prose and then
CORRECTED BY THE MEASUREMENT rather than defended. Each correction is recorded in
the capture, in the validation plan and in the assessment, because Step 2
compares against the measured baseline.

The corrections are the setup `readlink -f` count, the silent zero exit of the
planted run, and the fact that `current/bin/_bin` is a dangling referent rather
than a file. None of them changes a plan decision; all three change what the
harness asserts.

#### The one place this implementation went beyond the plan's file list for step 0 python-wrapper-foreign-distro (round 1)

`docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt` is retained although Step 0's
"files involved" names only two files. The reason is in the assessment: Step 2
requires a Step 0 baseline artifact and fails if it is absent, so the plan as
written could not execute. This is stated as a finding for the reviewer to
confirm or refute rather than presented as a silent extra.

No disagreement is recorded in this round, because there is nothing yet to
disagree with.

### Reviewer focus for step 0 python-wrapper-foreign-distro (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-0-round-1 -->

## Round 1 by reviewer - Step 0

- Recorded: 2026-08-31T16:33:33+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 0
- Outcome: answer

### Assessed index identity for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

Baseline index tree: 2bd88b6b2863903225ddbdeb382d61e355c74ad6

Assessed index tree: b2fec026a0ade8318c87ea55b45aa2cb25457aac

### Implementation check for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

Result: No. Step 0 has NOT been fully implemented.

The retained RHEL capture is green, but the exact mandatory Step 0 command fails
on the reviewer and authoring Windows host with seven fixture and symlink
failures. This contradicts plan decision P1's `any` host contract. The staged
capture also remains outside the exact Step 0 file list, and two smaller
evidence-contract inconsistencies remain unresolved.

Validation plan effects: The reviewer changed only the Step 0 validation status, its summary, its
concrete missing-work section, and the opening theme sentence that reports the
same Step 0 state. The attributable patch was staged. The ignored `a.commit`
metadata was updated so group 4 no longer claims completion. No production,
harness, capture, retained-wrapper, umbrella, or other-step content was edited.

### Pre-repair mandatory checks and coverage for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

`bash src/utils/lint_shell.sh` passed: 44 tracked scripts, clean.

`shellcheck docs/v0.27.0/verify.wrapper-scope.sh` passed with no finding.

`bash docs/v0.27.0/verify.wrapper-scope.sh --step 0` ran after the Git Bash
sandbox restriction was removed and failed with 7 failures. Both planted
fixtures lost the expected symlink behavior; the interpreter was not reached;
the clean-run tree assertions and planted-run `_bin` assertion failed. The
verdict was `OBJECTIVE NOT MET for step 0: 7 failure(s)`.

The retained RHEL 9.8 capture reports 31 cases and 0 failures. It is useful
historical evidence, but it cannot replace a failing command in the mandatory
resolved set.

### Resolved validation set and sources for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

The current set is identical to the request-time set.

- Project: `bash src/utils/lint_shell.sh`.
- Plan: `bash docs/v0.27.0/verify.wrapper-scope.sh --step 0`.
- Request: `shellcheck docs/v0.27.0/verify.wrapper-scope.sh`.

All three commands were run. Two passed and the plan command failed.

### Resolver drift and direction for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

No resolver drift was found. The versioned `.review-validation` still declares
the project lint command, and the plan and request additions are unchanged.

### Repository state around validation for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

The request-time index tree and fresh reviewer baseline were identical at
`2bd88b6b2863903225ddbdeb382d61e355c74ad6`. After the attributable Step 0
validation-plan correction was staged, the assessed tree became
`b2fec026a0ade8318c87ea55b45aa2cb25457aac`.

The umbrella digest did not change. The validation-state comparison names only
the exact validation plan and the index transition. No harness, capture,
retained-wrapper, umbrella, untracked, or ignored validation side effect was
introduced. The validation-plan difference is confined to the reviewed Step 0
state and missing-work record.

### Repair inventory for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

Repairs made:

- docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md: polishing-only reviewer metadata; changed Step 0 to the required No verdict and recorded concrete missing work
- a.commit: polishing-only ignored metadata; changed group 4 from a false completion claim to an accurate review-gaps subject and body

Paths staged:

- docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
- docs/v0.27.0/verify.wrapper-scope.sh
- docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
- docs/v0.27.0/wrapper.pre-change.verification-only

### Commit plan assessment for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

The independent checker exits 0 with `state: valid`, `ready: true`, four staged
paths, four ordered groups, and no diagnostics. Group membership and order are
unchanged. Group 4 now uses `docs(wrapper): record step 0 review gaps`, which is
accurate for the assessed tree. Mechanical commit-plan readiness does not cure
the failed implementation and validation floors.

### Findings and boundaries for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

Unresolved findings:

- The exact mandatory Step 0 command fails with seven fixture and symlink failures on the reviewer and authoring host, contradicting the plan's P1 `any` host decision
- The staged `docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt` capture is required by Step 2 but is omitted from the exact Step 0 file list
- The harness says a later coverage case asserts `HELPERS` against the wrapper, but no such executable case exists
- The retained capture says `TWO FINDINGS THIS RUN CORRECTED`, while the validation record and request claim three corrected measurements, including the dangling `_bin` referent

Boundary-crossing work:

- Changing the reviewed plan's host contract or resolved validation route belongs to the writer and specification authority; the reviewer did not amend the plan
- Adding the missing harness behavior or coverage assertion changes test and acceptance behavior and requires a substantive writer-owned replacement round
- Adding or replacing the baseline capture in the exact Step 0 file list changes the reviewed plan scope and requires writer-owned reconciliation

### Writer instructions for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

Keep the useful retained wrapper, RHEL capture, and green lint evidence, then
resolve every item in the Step 0 `Missing work` section. In particular, make the
exact mandatory plan command produce reviewer-runnable evidence consistent with
P1, or amend the reviewed host contract and validation route under writer
authority. Reconcile the capture path with the Step 0 file list, make the
helper-coverage claim executable or accurate, and align the capture's findings
count. Rerun all three mandatory commands, refresh the validation plan and
`a.commit`, and publish the replacement request for round 2.

### Decision rationale for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

`changes-requested` is required because only three of the six readiness-floor
results pass. Exact identity passes, the reviewer metadata patch is attributable,
and `a.commit` is mechanically accurate. Full implementation does not pass,
mandatory validation does not pass, staged scope has an unresolved plan-file-list
boundary, and current findings remain. The reviewer made no substantive repair,
so a replacement writer round is required.

### Final reviewer decision for step 0 python-wrapper-foreign-distro (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-0-round-1 -->

## Round 2 by requestor - Step 0

- Recorded: 2026-08-31T16:49:04+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 0
- Outcome: request

### Review identity for step 0 python-wrapper-foreign-distro (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
Implementation step: 0
Review round: 2

### Code review evidence for step 0 python-wrapper-foreign-distro (round 2)

request_index_tree: 2788ed12546c0c699b137207e6fad4a09f47d472
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt (sources: plan)
- shellcheck docs/v0.27.0/verify.wrapper-scope.sh (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: test(wrapper): retain the pre-change wrapper bytes
group 1 path: docs/v0.27.0/wrapper.pre-change.verification-only
group 2: docs(plan): make the step 0 host contract POSIX
group 2 path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
group 3: test(wrapper): gate the host and prove the gate
group 3 path: docs/v0.27.0/verify.wrapper-scope.sh
group 4: test(wrapper): capture the step 0 baseline
group 4 path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
group 5: docs(wrapper): record step 0 completion
group 5 path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
group 6: docs(review): record the step 0 review rounds
group 6 path: docs/v0.27.0/review.code.v0.27.0.python-wrapper-foreign-distro.md
staged path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
staged path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.python-wrapper-foreign-distro.md
staged path: docs/v0.27.0/verify.wrapper-scope.sh
staged path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
staged path: docs/v0.27.0/wrapper.pre-change.verification-only
```

### Requestor assessment for step 0 python-wrapper-foreign-distro (round 2)

Step 0 is fully implemented. All four round 1 findings are resolved, and the
complete resolved validation set is green on the reviewing Windows host as well
as on a POSIX one, which is the condition round 1 said was missing.

#### Mandatory validation, run on both hosts for step 0 python-wrapper-foreign-distro (round 2)

| Command | Source | Windows | RHEL 9.8 |
| --- | --- | --- | --- |
| `bash src/utils/lint_shell.sh` | project | 44 scripts, clean, exit 0 | not host-specific |
| `bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt` | plan | 16 cases, 0 failures, exit 0 | 34 cases, 0 failures, exit 0 |
| `shellcheck docs/v0.27.0/verify.wrapper-scope.sh` | request | no finding, exit 0 | no finding, exit 0 |

The plan command gained `--capture`. That is a change to the resolved validation
route, made under the writer authority round 1 named, and the plan now states the
exact command so the route is versioned rather than passed by hand.

#### Finding by finding for step 0 python-wrapper-foreign-distro (round 2)

**1. The host contract.** Accepted without reservation. The seven failures were
findings about the host presented as findings about the wrapper, which is the
inversion this requirement exists to remove. Decision P1 said "any host" on the
reasoning that the observable does not need a foreign glibc. True, and beside the
point: what steps 0 to 2 measure is symlink surgery, and a host that cannot
create a symlink cannot reproduce it. P1 now reads "any POSIX host" and records
why the original was wrong rather than merely loose, and the target matrix
follows.

The harness now MEASURES the host before it plants anything: it creates a symlink
and reads it back, so a host whose `ln -s` silently copies is caught as surely as
one that refuses. A host that fails the probe reads a retained measurement, or
exits 4 saying it could not answer. It never reports 0 on its own account, and
the no-capture path is a NOTE rather than a failure, because nobody asked the
question there and there is no answer to be wrong.

**2. The capture in the step 0 file list.** Accepted. The reviewer and the writer
reached this independently, which is why it is now fixed in the PLAN rather than
argued in the implementation. Step 2 requires its comparison to be against a step
0 baseline artifact and fails when that artifact is absent; step 0's file list
created none. The list now names it and states the step 2 dependency.

**3. The phantom coverage case.** Accepted, and it is the finding this writer is
least comfortable having needed. A comment in the harness promised that "the
coverage case below asserts the list against the wrapper" and no such case
existed: a decorative gate written into the instrument built to refuse decorative
gates. The case is now executable in both directions, over the wrapper's
command-position words with assignment targets removed: no external command word
lacks a shim, and no entry of the shim list is dead. Both currently report empty,
and the comment now records why the case must stay real.

**4. The findings count.** Accepted. The capture header said `TWO FINDINGS THIS
RUN CORRECTED` while this record and the round 1 request said three. The header
now says three and names the dangling `_bin` referent as the third.

#### The new mechanism, and the reason to distrust it until it is proved for step 0 python-wrapper-foreign-distro (round 2)

Reading a retained measurement is the part of this rework most able to become a
way of passing without running, so its authority is not that a file exists and
says the right words.

The capture records the SHA-256 of the harness bytes that produced it, printed in
every verdict as `harness`. A host reading the capture asserts that value against
the harness it was asked to run. Edit the harness and the two diverge and the
substitution refuses.

That check is itself asserted rather than trusted:
`step0/control/stale-capture-refused` feeds a copy mutated in exactly the digest
line and requires the refusal to carry the `CAPTUREID` reason. It also happened
for real during this rework, which is better evidence than the control: adding
the control changed the harness, and the capture taken minutes earlier was
refused on the next run until it was retaken. The mechanism was observed working
before it was relied on.

#### Coverage, architecture, performance and feature integrity for step 0 python-wrapper-foreign-distro (round 2)

Unchanged from round 1 in substance. No shipped file is modified, so no feature
can be impaired and the wrapper on disk is still `88c4e0d2`. The DDD-Hexagonal
and `src\pdfss\tests\unit` criteria belong to the consuming project and have no
subject here; the substituted gate is the project lint floor, which is green.

Performance: the coverage case adds two `sed` and `grep` passes over a 90-line
file and two `comm` calls over lists of a few dozen words. The host probe creates
one symlink. Nothing grows with the size of a deployment.

#### What this round did NOT do, and why it is not hiding for step 0 python-wrapper-foreign-distro (round 2)

No production file was touched, so this remains a baseline rather than a change.
The reviewer's boundary list said three items belonged to writer authority: the
host contract, the validation route, and the file list. All three were exercised,
each is named in the plan diff, and each carries the reason in the plan itself
rather than only in this request.

There is no disagreement to record. Every finding was correct.

### Implementation report for step 0 python-wrapper-foreign-distro (round 2)

Round 2 changes the plan, the harness and the capture. It still changes no
shipped file: `src/install/env/python/bin/python` and
`src/install/env/python/bin/setenv` are read and digested, never written.

#### The plan correction, made under writer authority for step 0 python-wrapper-foreign-distro (round 2)

`docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md`:

- decision P1 becomes "any POSIX host", carrying the correction and its reason:
  the observable does not need a foreign glibc, but it does need symlinks, and
  the original wording was wrong rather than loose;
- the executable target matrix host column for steps 0, 1 and 2 becomes
  "any POSIX";
- the step 0 file list names
  `docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt` and states the step 2
  dependency that makes it necessary: step 2 fails when that baseline artifact is
  absent, and nothing produced one;
- the verification harness section states the exact plan command, including
  `--capture`, and explains why a retained measurement is not a way of passing
  without running;
- the same section records the one deliberate exception to measuring from the
  run, which is the shim coverage case.

#### The harness for step 0 python-wrapper-foreign-distro (round 2)

`docs/v0.27.0/verify.wrapper-scope.sh`, now 717 lines.

THE SHIM COVERAGE CASE, which round 1 found promised and absent. It extracts the
wrapper's command-position words: the first token of a line, and any token
introduced by a pipe, a list operator, a command substitution, or a `then`, `do`
or `else` keyword, with comments stripped and assignment targets removed, since
`name=value` puts a word in command position that is not a command. It then
asserts two directions against a vocabulary of shell keywords, builtins, the
wrapper's own `echo_dbg`, and `dirname`, which is external but PRE-SOURCE and so
outside the oracle by decision P9:

- `step0/coverage/no-unshimmed-command`, empty, so no external command the
  wrapper runs is missing a shim;
- `step0/coverage/no-dead-shim-entry`, empty, so no name in the shim list has
  gone stale.

This case READS THE WRAPPER'S SOURCE, which every other case refuses to do, and
that is deliberate. The question is which command names the file CONTAINS, not
what one run reached; a run-derived answer would report the helpers that one path
exercised and call the rest absent, which is the same absence-as-evidence error
in a new place.

THE HOST GATE. Before anything is planted, the harness creates a symlink in its
scratch directory and reads it back. Both halves matter: a host whose `ln -s`
silently copies passes a creation-only probe and then fails every shape
assertion, which is exactly the confusing outcome round 1 saw. On a capable host
the suite runs as before. On an incapable one the harness either reads a retained
measurement or exits 4, a code this file now documents alongside 0, 1, 2 and 5.

THE RETAINED MEASUREMENT. `--capture PATH` names a capture from a host that could
answer. The reading host asserts that the capture's recorded `harness` digest
equals the digest of the harness it was asked to run, then that its verdict line
reads `OBJECTIVE MET for step 0`, that its failure count is zero, and that its
case count is positive. `HARNESS_SHA256` is computed from `BASH_SOURCE` and
printed in every verdict, which is what puts the digest into the capture in the
first place.

THE CONTROL ON THAT CHECK. `step0/control/stale-capture-refused` writes a copy of
the capture with the digest line replaced by zeroes and requires the identity
assertion to refuse with the `CAPTUREID` reason. Without it, the check that makes
a retained measurement admissible would be the one thing in this harness nobody
asserted. It runs on capable hosts too, where a capture is supplied alongside a
real run, so the two can never drift apart unnoticed.

The refactor that made this readable: the run-dependent part of step 0 moved into
`step0_runnable_suite`, so the gate CHOOSES between running it and reading a
measurement of it, instead of interleaving the two paths in one block.

#### The capture for step 0 python-wrapper-foreign-distro (round 2)

`docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`, retaken with the final
harness, 120 lines, 34 cases, 0 failures. Its header now states three corrected
findings rather than two, and adds a paragraph on why the capture is
authoritative and not merely present.

The two runs it records are unchanged in substance from round 1, because the
wrapper is unchanged: RUN A clean with seven post-source helper calls and the
interpreter all observing the shipped search path, RUN B planted with one
injected failure, six mutation calls after it, the interpreter never reached, and
the silent zero exit.

#### Evidence that the identity mechanism works for step 0 python-wrapper-foreign-distro (round 2)

Observed rather than argued. After the control was added, the harness digest
changed from `3d4d542e...` to `ac119445...`. The capture taken minutes earlier
still named the old value, and the next run refused it:

```text
step0/capture/names-this-harness  FAIL  CAPTUREID capture names [3d4d542e...],
                                        this harness is [ac119445...]
step0/control/stale-capture-refused  PASS  refused on [CAPTUREID], as designed
```

The capture was then retaken against the final bytes, and both hosts now report
`OBJECTIVE MET for step 0`.

### Change summary for step 0 python-wrapper-foreign-distro (round 2)

Six staged paths, six `a.commit` groups, ordered least to most dependent. Round 1
had four of each; the plan correction and the review transcript are new.

#### Staged paths for step 0 python-wrapper-foreign-distro (round 2)

```text
A  docs/v0.27.0/wrapper.pre-change.verification-only
M  docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
A  docs/v0.27.0/verify.wrapper-scope.sh
A  docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
M  docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
A  docs/v0.27.0/review.code.v0.27.0.python-wrapper-foreign-distro.md
```

`git diff --name-only` is empty, so every change is staged and nothing is held
back. `commit-plan-check.bat --format json` returns `state: valid`,
`ready: true`, six groups, no diagnostics.

#### The six groups for step 0 python-wrapper-foreign-distro (round 2)

1. `test(wrapper): retain the pre-change wrapper bytes`. Unchanged from round 1.
   First because it depends on nothing.
2. `docs(plan): make the step 0 host contract POSIX`. NEW. The contract
   correction the rest of the change implements, so it precedes the harness that
   satisfies it.
3. `test(wrapper): gate the host and prove the gate`. The harness. Retitled from
   round 1's `measure the pre-change baseline`, because the round's substantive
   work is the gate and the control on it, and a subject that still said
   "measure the baseline" would describe the previous revision.
4. `test(wrapper): capture the step 0 baseline`. The capture, retaken against the
   final harness bytes.
5. `docs(wrapper): record step 0 completion`. The validation record. Restored
   from the reviewer's accurate round 1 amendment to
   `record step 0 review gaps`, which described the tree as it then stood.
6. `docs(review): record the step 0 review rounds`. NEW. The versioned review
   transcript, written by the exchange rather than by the writer, grouped last
   because it is protocol evidence rather than implementation and keeps growing
   while the rounds continue.

#### What changed in the plan, since it is a reviewed document for step 0 python-wrapper-foreign-distro (round 2)

`docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md` is amended for the
first time since its specification review converged and consolidated at
`9d338ec`. The edits are confined to the host contract and the step 0 file list:
decision P1, three cells of the target matrix host column, the verification
harness section, and the step 0 files-involved list. No decision from the eight
consolidated questions is altered, no step boundary moves, and no completion
criterion is weakened.

#### What is not in this change for step 0 python-wrapper-foreign-distro (round 2)

No shipped file. Step 1 is the first step that edits the wrapper.

The commit has NOT been made. Six groups are staged and `a.commit` is prepared,
formatted and validated, waiting on this review and then on the human commit
gate. HEAD is `69e2b68`.

### Writer response for step 0 python-wrapper-foreign-distro (round 2)

Writer response: All four round 1 findings accepted and resolved. No disagreement is recorded,
because none is held: every finding was correct, and two of them named defects
the writer had not seen.

#### Accepted, with what was done for step 0 python-wrapper-foreign-distro (round 2)

- **The exact mandatory command failed on the reviewer's host.** Accepted. The
  harness now measures symlink capability before planting, and the plan command
  carries `--capture`. Green on both hosts. Decision P1 and the target matrix
  were corrected under writer authority, which is where the reviewer placed them.
- **The capture was outside the step 0 file list.** Accepted. Fixed in the plan,
  not worked around in the implementation.
- **The harness promised a coverage case that did not exist.** Accepted. The case
  is now executable in both directions.
- **The capture said two corrected findings where the record said three.**
  Accepted. The header says three and names the third.

#### The reviewer's own repairs, assessed and kept for step 0 python-wrapper-foreign-distro (round 2)

The reviewer made two polishing-only repairs and left both staged, as its answer
said it would.

- It rewrote the step 0 validation rows to the required `No` verdict with a
  concrete missing-work list. That was accurate for the tree as it then stood.
  Those rows are now rewritten again to the `Yes` verdict this rework earns, and
  the missing-work section is replaced by a record of what the round changed.
  This is not a reversal of the reviewer's edit: it is the same document moving
  to the state the reviewer's own instructions asked for.
- It changed `a.commit` group 4 from `record step 0 completion` to
  `record step 0 review gaps`. Correct at the time, since the tree did not
  support a completion claim. The subject is restored now that it does, and the
  group is renumbered to 5 because the plan correction became a new group 2.

Neither repair is reversed in substance, so neither is recorded as disagreement.

#### One thing the writer changed that no finding asked for for step 0 python-wrapper-foreign-distro (round 2)

Round 1's harness kept the whole step 0 body in a single block. Adding the host
gate to that shape would have meant a conditional wrapped around a hundred lines,
with the retained-measurement path interleaved into the same block. The
run-dependent part moved into `step0_runnable_suite` instead, so the gate chooses
between running the suite and reading a measurement of it.

That is a structural change to a file under review, made for readability rather
than for a finding, so it is declared here rather than left for the reviewer to
notice in the diff. No case was removed, renamed or weakened by the move.

#### On the pattern this requirement keeps meeting for step 0 python-wrapper-foreign-distro (round 2)

The plan's consolidated record says every specification round found the same
defect one boundary further out than the last, and predicted the remaining
candidates would sit at the edges of the newest gate. Round 1 of code review
found two more of them, and both were inside the instrument itself: a comment
promising a case that did not exist, and a suite that turned a host limit into
findings about the wrapper.

The gate added in response, the retained measurement, is the newest candidate for
the same failure. It is therefore shipped with a control that mutates its digest
line and requires the refusal, and that control was observed firing for real
during the rework rather than only by construction. The writer's expectation for
round 3, if there is one, is that anything left sits at the edge of that control:
what happens when a capture is well formed, correctly digested, and taken from a
host that was itself lying.

### Reviewer focus for step 0 python-wrapper-foreign-distro (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-0-round-2 -->

## Round 2 by reviewer - Step 0

- Recorded: 2026-08-31T17:16:10+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 0
- Outcome: answer

### Assessed index identity for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

Baseline index tree: 2788ed12546c0c699b137207e6fad4a09f47d472

Assessed index tree: 5add01e044b53d2e2b5809ac3d36d0c19bd5ddc3

### Implementation check for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

Result: No. Step 0 has NOT been fully implemented.

The round-1 findings are resolved and all nominal mandatory commands pass, but
the retained-capture substitution validates only the harness identity. A
behavior-mutated wrapper with unchanged command vocabulary is accepted with 16
cases, 0 failures, and `OBJECTIVE MET`, so the green capture is not bound to the
subject inputs whose behavior it certifies.

Validation plan effects: The reviewer changed only the Step 0 verdict, summary, missing-work section, and
the opening theme sentence reporting that same state. The attributable patch was
staged. The ignored `a.commit` group 5 wording was changed from completion to
review gaps. No plan, harness, capture, retained wrapper, transcript, umbrella,
or other-step content was edited by the reviewer.

### Pre-repair mandatory checks and coverage for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

All three mandatory commands pass on the reviewing Windows host: project lint
reports 44 tracked scripts and clean; the exact plan command reports 16 cases,
0 failures, and `OBJECTIVE MET`; ShellCheck reports no finding.

The independent negative control changes the wrapper's relink target from
`../../bin/python` to `../../bin/python-broken` while preserving the same command
vocabulary. Running the same capture substitution with that wrapper also exits
0 with 16 cases, 0 failures, and `OBJECTIVE MET`. This proves that the nominal
green is not bound to the wrapper bytes or behavior. Inspection shows the same
missing identity checks for the exact `--setenv` and `--retained` inputs.

### Resolved validation set and sources for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

The current resolved set exactly matches the round-2 request.

- Project: `bash src/utils/lint_shell.sh`.
- Plan: `bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`.
- Request: `shellcheck docs/v0.27.0/verify.wrapper-scope.sh`.

All three pass. The additional negative control demonstrates that this green set
is incomplete rather than replacing any mandatory command.

### Resolver drift and direction for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

No resolver drift was found. The project, plan, and request sources are unchanged
from the round-2 request envelope.

### Repository state around validation for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

The fresh reviewer baseline exactly matched the request-time index tree at
`2788ed12546c0c699b137207e6fad4a09f47d472`. After the attributable Step 0
validation-plan correction was staged, the assessed tree became
`5add01e044b53d2e2b5809ac3d36d0c19bd5ddc3`.

The umbrella digest is unchanged. The validation-state comparison names only
the reviewed validation plan and the index transition. No plan, harness,
capture, retained wrapper, transcript, umbrella, or untracked validation side
effect changed during assessment. The behavior-mutated wrapper is ignored
reviewer evidence and is not staged.

### Repair inventory for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

Repairs made:

- docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md: polishing-only reviewer metadata; changed Step 0 to No and recorded the subject-input identity work
- a.commit: polishing-only ignored metadata; changed group 5 from completion to an accurate round-2 review-gap subject and body

Paths staged:

- docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
- docs/v0.27.0/review.code.v0.27.0.python-wrapper-foreign-distro.md
- docs/v0.27.0/verify.wrapper-scope.sh
- docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
- docs/v0.27.0/wrapper.pre-change.verification-only

### Commit plan assessment for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

The independent checker exits 0 with `state: valid`, `ready: true`, six staged
paths, six ordered groups, and no diagnostics. Group 5 now uses
`docs(wrapper): record step 0 review gaps`, matching the assessed validation
record. The other subjects and dependencies remain accurate. Mechanical
readiness does not satisfy the incomplete implementation and finding floors.

### Findings and boundaries for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

Unresolved findings:

- The retained-capture substitution binds the capture only to the harness SHA-256, not to the exact wrapper, setenv, and retained-wrapper inputs whose behavior the capture certifies
- The current stale-capture control mutates only the harness digest line and does not prove refusal of subject-input drift
- An unchanged-vocabulary wrapper with a deliberately broken relink target is accepted by the Windows substitution path with OBJECTIVE MET and exit 0

Boundary-crossing work:

- Extending the capture identity contract and its named-reason controls changes harness and acceptance behavior and requires a substantive writer-owned replacement round
- The plan's retained-measurement authority text must be reconciled with the complete subject-input identity contract under writer authority

### Writer instructions for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

Bind the retained measurement to every input whose behavior it claims: compare
the capture's recorded wrapper and `setenv` digests with the exact live inputs,
and verify the exact retained wrapper against its recorded pre-change identity.
Add named-reason controls that substitute an unchanged-vocabulary broken
wrapper, a mismatched `setenv`, and a mismatched retained wrapper, and require all
three to be refused. Update the plan's authority wording, retake the capture if
needed, rerun the full validation set on Windows and POSIX, refresh the Step 0
validation record and `a.commit`, then publish round 3.

### Decision rationale for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

`changes-requested` is required. Exact identity, nominal mandatory validation,
attributable reviewer scope, and mechanical commit grouping pass. Full
implementation and absence of unresolved findings fail because a reproduced
behavior-mutated subject is accepted by the retained-capture path. The reviewer
made no substantive repair, so writer-owned rework and another round are needed.

### Final reviewer decision for step 0 python-wrapper-foreign-distro (exchange 1) (round 2)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-0-round-2 -->

## Round 3 by requestor - Step 0

- Recorded: 2026-08-31T17:24:51+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 0
- Outcome: request

### Review identity for step 0 python-wrapper-foreign-distro (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
Implementation step: 0
Review round: 3

### Code review evidence for step 0 python-wrapper-foreign-distro (round 3)

request_index_tree: 44fd348f5b6de9ec8269e9b376fa480c887b961f
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt (sources: plan)
- shellcheck docs/v0.27.0/verify.wrapper-scope.sh (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: test(wrapper): retain the pre-change wrapper bytes
group 1 path: docs/v0.27.0/wrapper.pre-change.verification-only
group 2: docs(plan): bind the step 0 host and capture rules
group 2 path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
group 3: test(wrapper): bind the capture to what it measured
group 3 path: docs/v0.27.0/verify.wrapper-scope.sh
group 4: test(wrapper): capture the step 0 baseline
group 4 path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
group 5: docs(wrapper): record step 0 completion
group 5 path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
group 6: docs(review): record the step 0 review rounds
group 6 path: docs/v0.27.0/review.code.v0.27.0.python-wrapper-foreign-distro.md
staged path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
staged path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.python-wrapper-foreign-distro.md
staged path: docs/v0.27.0/verify.wrapper-scope.sh
staged path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
staged path: docs/v0.27.0/wrapper.pre-change.verification-only
```

### Requestor assessment for step 0 python-wrapper-foreign-distro (round 3)

Step 0 is fully implemented. Round 2's single finding is resolved, its exploit is
reproduced against the fixed harness and refused, and the complete resolved
validation set is green on the reviewing Windows host and on a POSIX one.

#### Mandatory validation, run on both hosts for step 0 python-wrapper-foreign-distro (round 3)

| Command | Source | Windows | RHEL 9.8 |
| --- | --- | --- | --- |
| `bash src/utils/lint_shell.sh` | project | 44 scripts, clean, exit 0 | not host-specific |
| `bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt` | plan | 22 cases, 0 failures, exit 0 | 34 cases, 0 failures, exit 0 |
| `shellcheck docs/v0.27.0/verify.wrapper-scope.sh` | request | no finding, exit 0 | no finding, exit 0 |

#### The finding, accepted without reservation for step 0 python-wrapper-foreign-distro (round 3)

The retained-capture substitution bound a capture to the harness that produced it
and to nothing else. That answers WHICH INSTRUMENT MEASURED. It says nothing
about WHAT IT MEASURED, so a capture could certify a run over files nobody
compared to the ones present.

The reviewer proved it rather than describing it: a wrapper with the same command
vocabulary as the real one and a deliberately broken relink target passed the
Windows substitution path with 16 cases, 0 failures and `OBJECTIVE MET`.

Round 1's request called the harness binding "the authority", and that claim was
wrong. It was half of it.

#### What now binds, and what proves each binding for step 0 python-wrapper-foreign-distro (round 3)

The verdict carries four digests, and a reading host asserts all four:

| Digest | Answers | Refusal reason | Control |
| --- | --- | --- | --- |
| `harness` | which instrument measured | `CAPTUREID` | mutates the digest line |
| `wrapper-sha` | which wrapper it measured | `SUBJECTID` | a broken wrapper, vocabulary unchanged |
| `setenv-sha` | which `setenv` it measured | `SUBJECTID` | a mismatched `setenv` |
| `retained-sha` | which retained wrapper it measured | `SUBJECTID` | a mismatched retained wrapper |

The wrapper control keeps the command vocabulary IDENTICAL on purpose. It is
exactly the file that passed before this binding existed, so the control fails
for the reason the finding named rather than for an easier one, and the shim
coverage case alone would still accept it.

#### The exploit, reproduced against the fix for step 0 python-wrapper-foreign-distro (round 3)

Run before this request was written, not inferred from the code:

```text
vocabulary identical? YES
step0/capture/subject/wrapper  FAIL  SUBJECTID wrapper recorded [88c4e0d2...],
                                     live is [e1064e8b...]
OBJECTIVE NOT MET for step 0: 1 failure(s)   exit=1
```

The two wrappers are indistinguishable to the coverage case, which is the point:
the coverage case asks what command names the file contains, and this file
contains the same ones. Only the subject digest separates them.

#### Coverage, architecture, performance and feature integrity for step 0 python-wrapper-foreign-distro (round 3)

No shipped file is modified, so no feature can be impaired; the wrapper on disk
is still `88c4e0d2`. The DDD-Hexagonal and `src\pdfss\tests\unit` criteria belong
to the consuming project and have no subject here, and the substituted gate is
the project lint floor, which is green over 44 scripts.

Performance: the subject binding adds three `grep` reads of a 134-line capture
and three `sha256sum` calls over files under 4 KB. The three controls each write
one small copy into scratch. Nothing grows with the size of a deployment.

#### The plan change for step 0 python-wrapper-foreign-distro (round 3)

The retained-measurement authority section was rewritten under writer authority,
as the round 2 boundary list required. It now states all four bindings, and it
records that the second half was missing and how it was found, so a later reader
meets the correction rather than the original claim.

#### THE PATTERN, and where this writer expects the next one for step 0 python-wrapper-foreign-distro (round 3)

Round 1 found two unfailable gates. Round 2 found that round 1's own fix was
unfailable in a new direction. Each fix has relocated the weakness rather than
removed it, and each round found it at the edge of the previous repair, which is
the same shape the specification rounds recorded for this requirement.

Round 2's writer response predicted the next candidate would be "a capture that
is well formed, correctly digested, and taken from a host that was itself lying".
The subject binding does not close that. It proves the capture describes THESE
files; it cannot prove the host that produced it reported honestly. The
protections that exist are that the capture is generated by the harness rather
than hand-written, that its controls must fire in the run that produces it, and
that a capable host cross-checks the same capture it could have produced itself.

The reviewer is invited to say whether that residue needs closing inside step 0
or is properly step 3's and step 5's business, where the same suite runs on the
real target and the real agent.

There is no disagreement to record.

### Implementation report for step 0 python-wrapper-foreign-distro (round 3)

Round 3 changes the harness, the capture header and the plan's authority section.
It still changes no shipped file: `src/install/env/python/bin/python` and
`src/install/env/python/bin/setenv` are read and digested, never written.

#### The subject binding for step 0 python-wrapper-foreign-distro (round 3)

`docs/v0.27.0/verify.wrapper-scope.sh`, now 823 lines.

Three digests are computed once, beside the harness digest that round 2 added:

```text
WRAPPER_SHA256   digest of the exact --wrapper input
SETENV_SHA256    digest of the exact --setenv input
RETAINED_SHA256  digest of the exact --retained input, empty when absent
```

All four are printed in the verdict, which is what puts them into a capture:

```text
  harness      ab07e598...
  wrapper-sha  88c4e0d2...
  setenv-sha   355bbec5...
  retained-sha 88c4e0d2...
```

`assert_subject_identity` reads one recorded field from the capture and compares
it with the live value, refusing with a `SUBJECTID` reason that names both. An
absent field is refused too, so a capture predating this contract cannot be read
by silently skipping the check. `assert_all_subjects` runs all three and returns
non-zero when any fails, rather than stopping at the first, so one run reports
every mismatch.

#### The controls for step 0 python-wrapper-foreign-distro (round 3)

Three new ones, each substituting a real input for a mutated copy and requiring
the `SUBJECTID` refusal:

- `step0/control/broken-wrapper-refused` copies the wrapper and rewrites only the
  relink target, `../../bin/python` to `../../bin/NOT-THE-WRAPPER`. THE COMMAND
  VOCABULARY IS UNCHANGED, which is the property that matters: this is the file
  the reviewer used, the coverage case cannot tell it apart, and only the digest
  can;
- `step0/control/mismatched-setenv-refused` appends one comment line to a copy of
  `setenv`;
- `step0/control/mismatched-retained-refused` does the same to the retained
  wrapper.

Each control saves the real digest, substitutes the mutated one, asserts, and
restores. They run on the substitution path and on a capable host that was given
a capture, so the binding is exercised wherever it is relied on.

#### Where the checks run for step 0 python-wrapper-foreign-distro (round 3)

On a host that cannot create symlinks, the substitution path now asserts, in
order: the capture exists, it names this harness, the stale-capture control
refuses a mutated digest line, the three subject digests match, the three subject
controls refuse their mutations, the verdict line reads `OBJECTIVE MET`, the
failure count is zero, and the case count is positive. Twenty-two cases.

On a capable host the suite runs as before, thirty-four cases, and a capture
supplied alongside it is cross-checked with the same four bindings and the same
four controls.

#### The capture for step 0 python-wrapper-foreign-distro (round 3)

`docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`, retaken against the final
harness, 134 lines, 34 cases, 0 failures. Its authority paragraph now describes
four digests rather than one and records why the first version was not enough.

The two runs it records are unchanged in substance, because the wrapper is
unchanged: RUN A clean with seven post-source helper calls and the interpreter
all observing the shipped search path, RUN B planted with one injected failure,
six mutation calls after it, the interpreter never reached, and the silent zero.

#### The plan for step 0 python-wrapper-foreign-distro (round 3)

The retained-measurement authority section states the four bindings, separates
the two questions a capture answers, and records the demonstration that found the
gap. Decision P1, the target matrix and the step 0 file list keep the round 2
corrections.

### Change summary for step 0 python-wrapper-foreign-distro (round 3)

Six staged paths, six `a.commit` groups, ordered least to most dependent. The
membership and order are unchanged from round 2; two subjects changed to match
what the round actually did.

#### Staged paths for step 0 python-wrapper-foreign-distro (round 3)

```text
A  docs/v0.27.0/wrapper.pre-change.verification-only
M  docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
A  docs/v0.27.0/verify.wrapper-scope.sh
A  docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
M  docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
A  docs/v0.27.0/review.code.v0.27.0.python-wrapper-foreign-distro.md
```

`git diff --name-only` is empty, so every change is staged and nothing is held
back. `commit-plan-check.bat --format json` returns `state: valid`,
`ready: true`, six groups, no diagnostics.

#### The six groups for step 0 python-wrapper-foreign-distro (round 3)

1. `test(wrapper): retain the pre-change wrapper bytes`. First because it depends
   on nothing.
2. `docs(plan): bind the step 0 host and capture rules`. RETITLED this round,
   from `make the step 0 host contract POSIX`. The plan edit now carries the
   capture authority rewrite as well as the host contract, and a subject naming
   only the host would describe half of it.
3. `test(wrapper): bind the capture to what it measured`. RETITLED this round,
   from `gate the host and prove the gate`. The round's substantive work is the
   subject binding; the host gate it replaces in the subject line is still in the
   body.
4. `test(wrapper): capture the step 0 baseline`. The capture, retaken against the
   final harness bytes.
5. `docs(wrapper): record step 0 completion`. The validation record, a trailing
   documentation group rather than part of the work it records.
6. `docs(review): record the step 0 review rounds`. The versioned transcript,
   written by the exchange rather than by the writer, last because it is protocol
   evidence and keeps growing while the rounds continue.

Both retitles are subject accuracy rather than regrouping. No path moved between
groups and no group changed position.

#### What changed in the plan, since it is a reviewed document for step 0 python-wrapper-foreign-distro (round 3)

`docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md` is amended for the
second time since its specification review consolidated at `9d338ec`. This round
touches one section, the retained-measurement authority, and leaves the round 2
corrections to decision P1, the target matrix and the step 0 file list as they
were. No decision from the eight consolidated questions is altered, no step
boundary moves, and no completion criterion is weakened.

#### What is not in this change for step 0 python-wrapper-foreign-distro (round 3)

No shipped file. Step 1 is the first step that edits the wrapper.

The commit has NOT been made. Six groups are staged and `a.commit` is prepared,
formatted and validated, waiting on this review and then on the human commit
gate. HEAD is `69e2b68`.

### Writer response for step 0 python-wrapper-foreign-distro (round 3)

Writer response: Round 2's single finding is accepted in full. No disagreement is recorded, and
none is held.

#### Accepted, with what was done for step 0 python-wrapper-foreign-distro (round 3)

**The capture was bound to its instrument and not to its subjects.** Correct, and
demonstrated rather than asserted, which made it impossible to argue with and
quick to fix. The verdict now carries the wrapper, `setenv` and retained digests
beside the harness digest; a reading host asserts all three against the exact
inputs it was given; and three controls, one per input, require the refusal.

The reviewer named the wrapper control's required shape precisely, "an
unchanged-vocabulary broken wrapper". That is implemented literally: the control
copies the real wrapper and rewrites only the relink target, so the coverage case
cannot distinguish the two and only the digest can. Building the control any
other way would have let it pass for an easier reason than the finding.

#### The reviewer's own repairs, assessed and kept for step 0 python-wrapper-foreign-distro (round 3)

The reviewer again rewrote the step 0 validation rows to the required `No`
verdict with a concrete missing-work list, and left them staged. Accurate for the
tree as it then stood. Those rows now move to the `Yes` verdict this rework
earns, and the missing-work section is replaced by a record of what round 2
changed. That is the same document reaching the state the reviewer's own
instructions asked for, not a reversal, so it is not recorded as disagreement.

`a.commit` needed no reviewer repair this round.

#### Two things the writer changed that no finding asked for for step 0 python-wrapper-foreign-distro (round 3)

Declared here rather than left for the reviewer to find in the diff.

- `assert_all_subjects` reports EVERY subject mismatch rather than stopping at
  the first. A run with two wrong inputs would otherwise need two rounds to
  discover both.
- An absent digest field in a capture is refused with the same `SUBJECTID`
  reason as a wrong one. A capture predating this contract would otherwise be
  read by silently skipping the check, which is the absence-as-evidence error
  this requirement keeps meeting.

#### On the pattern, and the residue this round does not close for step 0 python-wrapper-foreign-distro (round 3)

Round 1 found two unfailable gates in this harness. Round 2 found that round 1's
fix was itself unfailable in a new direction: bound to the instrument, blind to
the subject. Round 1's request had called that binding "the authority", which was
wrong, and the correction is now in the plan rather than only in this exchange.

The writer's round 2 prediction was that the next candidate would be a capture
that is well formed, correctly digested, and taken from a host that was itself
lying. This round does not close that, and does not claim to. The subject binding
proves a capture describes THESE files; nothing in it proves the producing host
reported honestly.

What stands against that today: the capture is generated by the harness rather
than written by hand, its own controls must fire in the run that produces it, and
a capable host cross-checks the same capture it could have produced itself. The
writer's reading is that the remainder belongs to step 3 and step 5, where the
suite runs on the real target and the real agent and a dishonest intermediate
capture would contradict them. The reviewer is asked to confirm or refute that
placement rather than to accept it silently, since it is the one open edge this
round leaves.

### Reviewer focus for step 0 python-wrapper-foreign-distro (round 3)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-0-round-3 -->

## Round 3 by reviewer - Step 0

- Recorded: 2026-08-31T17:45:17+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 0
- Outcome: answer

### Assessed index identity for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

Baseline index tree: 44fd348f5b6de9ec8269e9b376fa480c887b961f

Assessed index tree: 44fd348f5b6de9ec8269e9b376fa480c887b961f

### Implementation check for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

Result: Yes. Step 0 has been fully implemented.

All plan criteria are represented by retained evidence or executable controls.
The harness now binds a capture to its instrument and to the wrapper, `setenv`,
and retained-wrapper subjects; the exact round-2 exploit and both other subject
substitutions are refused with `SUBJECTID` and exit 1.

Validation plan effects: No reviewer edit was needed. The Step 0 validation record already begins with
the exact full-implementation sentence, carries the round-1 and round-2 evidence,
and has no stale missing-work section. The document-level status correctly stays
`No, it is not implemented.` because Steps 1 through 5 remain pending.

### Pre-repair mandatory checks and coverage for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

All mandatory checks pass on the reviewing Windows host: project lint reports
44 tracked scripts and clean; the exact plan command reports 22 cases,
0 failures, and `OBJECTIVE MET`; ShellCheck reports no finding.

Three independent negative controls then substitute the exact round-2
unchanged-vocabulary broken wrapper, a mismatched `setenv`, and a mismatched
retained wrapper. Each run exits 1 with exactly its live subject reported under
`SUBJECTID`; the other two subjects still pass. The nominal path and all three
refusal paths therefore behave as claimed.

### Resolved validation set and sources for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

The current resolved set exactly matches the round-3 request.

- Project: `bash src/utils/lint_shell.sh`.
- Plan: `bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`.
- Request: `shellcheck docs/v0.27.0/verify.wrapper-scope.sh`.

All three commands pass, and the plan command's four named-reason controls are
also green on the substitution path.

### Resolver drift and direction for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

No resolver drift was found. The project, plan, and request sources are unchanged
from the round-3 request envelope.

### Repository state around validation for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

The request-time, baseline, and assessed index trees are all
`44fd348f5b6de9ec8269e9b376fa480c887b961f`. The umbrella digest is unchanged,
and the validation-state comparison is acceptable with no tracked, untracked,
ignored, or index difference. The external subject-substitution files are
ignored reviewer evidence and were not staged.

### Repair inventory for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

The independent checker exits 0 with `state: valid`, `ready: true`, six staged
paths, six ordered groups, and no diagnostics. The plan correction precedes the
harness, the capture follows the harness it records, the validation record is
trailing documentation, and the protocol transcript is last. Every subject and
group boundary accurately describes the assessed tree.

### Findings and boundaries for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

No implementation rework is requested. Present this advisory commit-ready
recommendation at the durable human gate with the registered choices. The
remaining possibility of a dishonest producing host is an evidence-provenance
limit, not a missing Step 0 acceptance criterion: this plan does not claim host
attestation, and Steps 3 and 5 independently run the suite on the real RHEL and
Debian environments. Do not commit without the human `Commit` authorization.

### Decision rationale for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

`commit-ready` is recommended because all six readiness-floor results pass:
exact identity, complete implementation, mandatory validation and coverage,
stable attributable staged scope, no unresolved current or carried finding, and
an accurate mechanically valid `a.commit`. This round made no repair. The
recommendation is advisory and stops at the human confirmation gate.

### Final reviewer decision for step 0 python-wrapper-foreign-distro (exchange 1) (round 3)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-0-round-3 -->

## Round 3 by human - Step 0 - human-confirmation

- Recorded: 2026-08-31T18:32:15+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 0
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-3 -->

## Round 1 by requestor - Step 1

- Recorded: 2026-08-31T19:26:10+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 1
- Outcome: request

### Review identity for step 1 python-wrapper-foreign-distro (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
Implementation step: 1
Review round: 1

### Code review evidence for step 1 python-wrapper-foreign-distro (round 1)

request_index_tree: bbb2e6e1a0f691b3f26e6627041441cc011fc5df
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.wrapper-scope.sh --step 1 --capture docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt (sources: plan)
- bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --wrapper docs/v0.27.0/wrapper.pre-change.verification-only --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt (sources: plan)
- shellcheck docs/v0.27.0/verify.wrapper-scope.sh (sources: request)
- shellcheck src/install/env/python/bin/python (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: chore(vscode): add SUBJECTID and theorised
group 1 path: .vscode/settings.json
group 2: docs(plan): name the step 1 command and capture
group 2 path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
group 3: fix(wrapper): unset the search path for helpers
group 3 path: src/install/env/python/bin/python
group 4: test(wrapper): add the step 1 scope suite
group 4 path: docs/v0.27.0/verify.wrapper-scope.sh
group 5: test(wrapper): retake the step 0 capture
group 5 path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
group 6: test(wrapper): capture the step 1 scope rule
group 6 path: docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt
group 7: docs(wrapper): record step 1 completion
group 7 path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
staged path: .vscode/settings.json
staged path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
staged path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
staged path: docs/v0.27.0/verify.wrapper-scope.sh
staged path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
staged path: docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt
staged path: src/install/env/python/bin/python
```

### Requestor assessment for step 1 python-wrapper-foreign-distro (round 1)

Step 1 of the v0.27.0 python-wrapper-foreign-distro plan is fully implemented.
Every completion criterion is answered by a named case, and the whole resolved
validation set is green on the reviewing Windows host as well as on a POSIX one.

#### Mandatory validation, run on both hosts for step 1 python-wrapper-foreign-distro (round 1)

| Command | Source | Windows | RHEL 9.8 |
| --- | --- | --- | --- |
| `bash src/utils/lint_shell.sh` | project | 44 scripts, clean, exit 0 | not host-specific |
| `bash docs/v0.27.0/verify.wrapper-scope.sh --step 1 --capture docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt` | plan | 22 cases, 0 failures, exit 0 | 30 cases, 0 failures, exit 0 |
| `shellcheck docs/v0.27.0/verify.wrapper-scope.sh` | request | no finding, exit 0 | no finding, exit 0 |
| `shellcheck src/install/env/python/bin/python` | request | no finding, exit 0 | no finding, exit 0 |

Step 0's command remains green and is now
`--step 0 --wrapper docs/v0.27.0/wrapper.pre-change.verification-only --capture
docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`, for the reason in the findings
section below.

#### Criterion by criterion for step 1 python-wrapper-foreign-distro (round 1)

- ONE save site, value in a variable: `step1/source/save-sites` 1 and
  `step1/source/unset-sites` 1;
- TWO restore sites in the per-command prefix form: `step1/source/restore-sites`
  2, `step1/source/no-export` 0;
- no `export LD_LIBRARY_PATH` in the wrapper: the same case, 0;
- MEASURED FROM THE RUN: `step1/helpers-seeing-search-path` 0, read only after
  `step1/post-source-helper-calls` 7 and the per-helper counts establish the
  calls happened;
- the bootstrap asserted separately with no environment claim:
  `step1/setup-readlink-delegated` 2, reported as a NOTE, per P6 and P9;
- an empty saved value arriving as empty:
  `step1/empty/reaches-interpreter-as-empty` records `empty`, not `unset`;
- `setenv` byte-identical to step 0's digest:
  `step1/setenv-unchanged-since-step0`, `355bbec5...`.

THE FOUR SOURCE-LEVEL CASES ARE A DELIBERATE EXCEPTION to measuring from the run,
and the plan already carries the same exception for the shim coverage case.
"Exactly one save site" is a claim about the FILE: no single run can distinguish
one save site from two that happen to agree, and a run-derived answer would be
measuring something else. The behavioural half is measured from the run beside
them.

#### THE SUBSTANTIVE FINDING, offered for the reviewer to confirm or refute for step 1 python-wrapper-foreign-distro (round 1)

The suite passed its own central claim while measuring NOTHING, on its first run,
and the presence assertions are the only reason it was caught.

`step1_runnable_suite` did not call `plant_shims`. The shim directory was empty,
`PATH` resolved every helper to the real tool, no call reached the log, and
`step1/helpers-seeing-search-path` reported 0 out of an empty log. Read alone
that is exactly the number the step wants. Five presence assertions failed
alongside it (`setup-readlink-delegated`, `readlink-calls`, `mv-calls`,
`ln-calls`, `post-source-helper-calls`, all wanting non-zero and getting 0) and
the verdict was `OBJECTIVE NOT MET`.

This is the fourth instance of the same shape in this effort and the second the
writer introduced. It is reported rather than quietly fixed because the reviewer
should judge whether the repair is sufficient: `plant_shims` is now called in the
suite, and the presence assertions that caught it remain. The writer's own view is
that the structural fix would be to make a run over an unplanted shim directory
impossible rather than merely detected, and that the presence assertions already
achieve that outcome at the cost of detecting rather than preventing.

#### Two consequences step 1 pushes back into step 0 for step 1 python-wrapper-foreign-distro (round 1)

Both are the step 0 subject binding working, and both were run before being
written down. The reviewer is asked to confirm the handling.

1. STEP 0'S COMMAND MUST NOW NAME THE RETAINED WRAPPER. Step 0 describes the
   pre-change file; step 1 replaced the live one; the binding refuses the
   mismatch with `SUBJECTID`. Running step 0 against `src/install/env/python/bin/python`
   now exits 1, which is correct: a capture describing `88c4e0d2` says nothing
   about the file that replaced it. The plan states the corrected command.
2. EVERY HARNESS EDIT INVALIDATES EVERY RETAINED CAPTURE. Adding the step 1 suite
   changed the harness digest, so both captures were retaken. The plan records
   this as a deliberate cost rather than leaving a later reader to discover it.

#### Coverage, architecture, performance and feature integrity for step 1 python-wrapper-foreign-distro (round 1)

Architecture: this is the FIRST shipped file this requirement modifies. The
change is confined to the one file the plan's scope anchors name, adds no file to
the shipped tree, and introduces one variable prefixed `CPLX_` so it cannot
collide with a caller's. `setenv` is read and digested, never written. The
harness and both captures stay under `docs/v0.27.0/`, never packaged. The
DDD-Hexagonal criterion does not apply to a Bash and Batch project.

Performance: one assignment and one `unset` per wrapper invocation, plus two
environment prefixes that replace nothing. The four source-level cases scan a
113-line file once each. Nothing grows with the size of a deployment.

Coverage: the 100 percent unit rule targets `src\pdfss\tests\unit`, which belongs
to the consuming project; cplx has no pytest suite and no unit-tested class file.
The substituted gate is the project lint floor plus `shellcheck` on both the
harness and the modified wrapper, all green.

Feature integrity: the clean first call still exits 0, still performs the whole
surgery, and still leaves `python3` relinked to the wrapper with `python3_target`
naming the real interpreter, which is the tree shape step 0 recorded BEFORE the
change. The only difference in the log is which processes saw the variable. The
interpreter's value is asserted to be the shipped search path rather than merely
present, so the change cannot have quietly broken the one caller that needs it.

No disagreement is recorded; this is round 1 and no reviewer answer exists.

### Implementation report for step 1 python-wrapper-foreign-distro (round 1)

Step 1 implements decision D2/W1: the shipped search path serves the interpreter
and nothing else the wrapper runs. Three files change, one of them shipped.

#### The wrapper, the first shipped file this requirement modifies for step 1 python-wrapper-foreign-distro (round 1)

`src/install/env/python/bin/python`, 90 lines to 113, budget 115.

Immediately after the `source` at line 18:

```bash
CPLX_TOOLCHAIN_LD_LIBRARY_PATH="${LD_LIBRARY_PATH-}"
unset LD_LIBRARY_PATH
```

ONE save site holding the value in a variable rather than re-deriving it, and the
`${VAR-}` form so an empty value stays empty instead of becoming unset, which is
W3 without a branch. The variable is prefixed `CPLX_` so it cannot collide with
anything the caller set.

At the two interpreter call sites, one per arm of the existing `if`, the
per-command environment prefix and never an `export`. W2 rejects the export
because it would leave the value live for everything the interpreter spawns and
for every line after, which is the state the save exists to end. Each site
carries a comment naming the decision it implements.

#### The step 1 suite for step 1 python-wrapper-foreign-distro (round 1)

`docs/v0.27.0/verify.wrapper-scope.sh`, 823 lines to 918.

FOUR SOURCE-LEVEL CASES, declared as the exception they are:
`step1/source/save-sites`, `unset-sites`, `restore-sites` and `no-export`. They
count occurrences in the wrapper file, because "exactly one save site" is a claim
about the file rather than about a run.

ELEVEN MEASURED FROM THE RUN, in the order the log contract requires. The counts
that establish the calls happened come first: exit status, two delegated setup
`readlink -f` calls, three `readlink`, one `mv`, five `ln`, one interpreter, and
seven post-source helper calls. Only then the claim itself, in both halves:
`helpers-seeing-search-path` 0, `interpreter-still-sees-it` yes, and
`interpreter-value-is-the-shipped-path` yes, which checks the value is the search
path `setenv` built from the fixture's own root rather than merely some value.

THE W3 CASE USES A VARIANT FIXTURE, and says so in the capture. The shipped
`setenv` always exports a non-empty value, so the only way to exercise an empty
saved value is to plant a `setenv` that exports one. The variant goes into a
second fixture, the interpreter's record is asserted to be `empty` rather than
`unset`, the helpers are asserted still unset in the same run, and the shipped
`setenv` bytes are asserted at step 0's digest separately.

Supporting changes: the step dispatch accepts `0|1` and its comment was corrected
with it; `step0_capture_substitution` became `step_capture_substitution` with a
step-aware verdict-line expectation; the capable-host branch dispatches by step.

#### The captures for step 1 python-wrapper-foreign-distro (round 1)

`docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt`, new, 109 lines, 30 cases, 0
failures. Its header states the flip against step 0 in both halves and records
the self-caught defect below.

`docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`, retaken. Two independent
reasons, both of them the identity bindings working: the harness digest changed
when the step 1 suite was added, and the live wrapper changed when step 1 ran.
The retake targets the RETAINED pre-change wrapper, and the header now says step
0 must be read that way from step 1 onward.

#### The defect the suite found in itself for step 1 python-wrapper-foreign-distro (round 1)

Reported in full because it is the failure this requirement exists to remove.

The first run of the step 1 suite produced:

```text
step1/helpers-seeing-search-path   PASS  0
step1/setup-readlink-delegated     FAIL  want [2] got [0]
step1/readlink-calls               FAIL  want [3] got [0]
step1/mv-calls                     FAIL  want [1] got [0]
step1/ln-calls                     FAIL  want [5] got [0]
step1/post-source-helper-calls     FAIL  want [7] got [0]
OBJECTIVE NOT MET for step 1: 5 failure(s)
```

The central claim PASSED. It passed over an empty log: `step1_runnable_suite` had
not called `plant_shims`, the shim directory did not exist, `PATH` resolved every
helper to the real tool, and nothing was recorded. The interpreter stub still
logged, because it is planted by `plant_fixture` and invoked by absolute path,
which is why the run looked superficially alive.

The repair is one line, `plant_shims` at the top of the suite, carrying a comment
that states what its absence caused so it is not later removed as redundant. The
five presence assertions that made the failure visible are unchanged.

### Change summary for step 1 python-wrapper-foreign-distro (round 1)

Seven staged paths, seven `a.commit` groups, ordered least to most dependent.

#### Staged paths for step 1 python-wrapper-foreign-distro (round 1)

```text
M  .vscode/settings.json
M  docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
M  src/install/env/python/bin/python
M  docs/v0.27.0/verify.wrapper-scope.sh
M  docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
A  docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt
M  docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
```

`git diff --name-only` is empty, so every change is staged and nothing is held
back. `commit-plan-check.bat --format json` returns `state: valid`,
`ready: true`, seven groups, no diagnostics.

#### The seven groups for step 1 python-wrapper-foreign-distro (round 1)

1. `chore(vscode): add SUBJECTID and theorised`. OF OUTSIDE ORIGIN, not authored
   in this step: both words entered the tree through the step 0 review prose and
   the dictionary entry arrived with them. It is grouped rather than dropped
   because a staged change belongs to some commit, and nothing depends on it, so
   it ranks first.
2. `docs(plan): name the step 1 command and capture`. The plan edit, before the
   code that satisfies it.
3. `fix(wrapper): unset the search path for helpers`. THE SHIPPED CHANGE, and the
   only group in this set that touches a delivered file.
4. `test(wrapper): add the step 1 scope suite`. The oracle for the change above.
5. `test(wrapper): retake the step 0 capture`. Produced by running the harness.
6. `test(wrapper): capture the step 1 scope rule`. Likewise.
7. `docs(wrapper): record step 1 completion`. The validation record, a trailing
   documentation group rather than part of the work it records.

#### What changed in the plan for step 1 python-wrapper-foreign-distro (round 1)

`docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md` is amended for the
third time since its specification review consolidated at `9d338ec`, and for the
first time for a reason step 1 created rather than one a code review found. The
edit touches the verification harness section, which now states both plan
commands and the two consequences, and the step 1 files-involved list, which now
names the capture.

No decision from the eight consolidated questions is altered, no step boundary
moves, and no completion criterion is weakened.

#### What is not in this change for step 1 python-wrapper-foreign-distro (round 1)

Step 2's guard. The wrapper still feeds an unusable `readlink` result into its
surgery: step 1 changes WHO sees the search path, not what happens when a helper
fails. The step 0 baseline's silent zero is unchanged and is still the thing step
2 must flip.

The commit has NOT been made. Seven groups are staged and `a.commit` is prepared,
formatted and validated, waiting on this review and then on the human commit
gate. HEAD is `e6090f3`.

### Writer response for step 1 python-wrapper-foreign-distro (round 1)

Writer response: Round 1 of the code family for step 1. No reviewer answer exists yet, so there is
no accepted feedback to record and no disagreement to declare.

#### Feedback from the step 0 exchange that shaped this step for step 1 python-wrapper-foreign-distro (round 1)

Step 0 closed at `commit-ready` after three rounds, and two of its findings
changed how this step was built rather than only what step 0 shipped.

- THE PRESENCE-FIRST RULE. Round 1 of step 0 found a comment promising a coverage
  case that did not exist. This suite was written with its presence assertions
  first for that reason, and they are what caught this step's own defect. The
  rule earned its place twice in the same effort.
- THE SUBJECT BINDING. Round 2 of step 0 found that a capture bound only to its
  instrument certifies runs over inputs nobody compared. That binding is the
  reason step 0's command had to change when step 1 rewrote the wrapper: it
  refused the mismatch rather than passing quietly. The consequence is reported
  in this request as a finding rather than buried in the plan diff.

#### What this writer changed that no criterion asked for for step 1 python-wrapper-foreign-distro (round 1)

Declared here rather than left for the reviewer to find in the diff.

- `step0_capture_substitution` was renamed `step_capture_substitution` and its
  expected verdict line became step-aware, so step 1 uses the same
  retained-measurement path rather than growing a second copy of it.
- The capable-host branch now dispatches by step. No case was removed, renamed or
  weakened by either change.
- The step 1 suite reports the two setup `readlink -f` calls as a NOTE carrying no
  environment claim, matching how step 0 reports them, rather than asserting
  anything about what they observed. Decisions P6 and P9 make that environment
  the caller's business.

#### On the pattern, and what this step adds to it for step 1 python-wrapper-foreign-distro (round 1)

The specification rounds for this requirement recorded that each fix relocated
the weakness rather than removing it, and the step 0 code review found two more
instances at the edges of its own repairs. This step found a fourth, in the
instrument again, and the writer introduced it: a suite that passed its central
claim over an empty log.

What is different this time is that the detection was already in place. The
presence-first rule came out of step 0 round 1, and it fired without anyone
looking for it. That is the first time in this effort the pattern was caught by a
guard built for it rather than by a reviewer.

The writer's expectation for the next instance is that it sits at the edge of the
four source-level cases this step adds. They count occurrences of a literal
string in the wrapper, so a save site written differently, or split across two
lines, would be counted as absent while behaving identically. Nothing in this
step detects that. The run-measured half would still pass, which is the right
outcome, but the structural claim would then be wrong in a way no case reports.
The reviewer is invited to say whether that matters at this step or belongs with
step 2, which touches the same lines again.

### Reviewer focus for step 1 python-wrapper-foreign-distro (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-1-round-1 -->

## Round 1 by reviewer - Step 1

- Recorded: 2026-09-01T08:09:14+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 1
- Outcome: answer

### Exact disagreement for step 1 python-wrapper-foreign-distro (exchange 1) (round 1)

The request binds round 1 to index tree
`bbb2e6e1a0f691b3f26e6627041441cc011fc5df`, and the retained reviewer
manifest records that same value as both its baseline and assessed tree.
The mandatory live capture now reports
`3a2d5dff94f41fff23a4bdea6698bf34672a915f`.

That change is not attributable through the retained manifest: it records no
repair paths, no pre-repair blobs, and no validation-after state. The request-
time index identity therefore no longer matches the repository state that would
be assessed. Publishing a cached implementation conclusion against this drifted
index would be untrustworthy.

### Writer instructions for step 1 python-wrapper-foreign-distro (exchange 1) (round 1)

Reconcile the current staged tree with the writer-owned Step 1 state, including
the validation-plan content that changed after the request was published. Keep
only changes the writer intentionally owns, regenerate `a.commit`, and rerun
`commit-plan-check.bat --format json`. Then consume this answer, continue the
exchange, and publish a replacement request whose `request_index_tree` matches
the live staged index. Do not reuse the abandoned request's implementation
assessment or its stale retained manifest.

### Final reviewer decision for step 1 python-wrapper-foreign-distro (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-1-round-1 -->

## Round 2 by requestor - Step 1

- Recorded: 2026-09-01T08:37:39+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 1
- Outcome: request

### Review identity for step 1 python-wrapper-foreign-distro (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
Implementation step: 1
Review round: 2

### Code review evidence for step 1 python-wrapper-foreign-distro (round 2)

request_index_tree: 80707c7313be77e2014702f8236db18afe712152
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project, request)
- bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --wrapper docs/v0.27.0/wrapper.pre-change.verification-only --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt (sources: plan)
- bash docs/v0.27.0/verify.wrapper-scope.sh --step 1 --capture docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt (sources: plan)
- shellcheck docs/v0.27.0/verify.wrapper-scope.sh src/install/env/python/bin/python (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: chore(vscode): add SUBJECTID and theorised
group 1 path: .vscode/settings.json
group 2: docs(plan): name the step 1 command and capture
group 2 path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
group 3: fix(wrapper): unset the search path for helpers
group 3 path: src/install/env/python/bin/python
group 4: test(wrapper): add the step 1 scope suite
group 4 path: docs/v0.27.0/verify.wrapper-scope.sh
group 5: test(wrapper): retake the step 0 capture
group 5 path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
group 6: test(wrapper): capture the step 1 scope rule
group 6 path: docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt
group 7: docs(wrapper): record step 1 completion
group 7 path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
staged path: .vscode/settings.json
staged path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
staged path: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md
staged path: docs/v0.27.0/verify.wrapper-scope.sh
staged path: docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt
staged path: docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt
staged path: src/install/env/python/bin/python
```

### Requestor assessment for step 1 python-wrapper-foreign-distro (round 2)

#### Assessment for step 1 python-wrapper-foreign-distro (round 2)

Step 1 is fully implemented. Every completion criterion is answered by an
executed run rather than by reading the wrapper, and the runs now reach ALL
FOURTEEN of the wrapper's post-source helper sites rather than the seven an
ordinary first call makes.

#### Test evidence for step 1 python-wrapper-foreign-distro (round 2)

`bash docs/v0.27.0/verify.wrapper-scope.sh --step 1` on RHEL 9.8 (kernel
5.14.0-687.41.1.el9_8.x86_64, bash 5.1.8(1)-release): 50 cases, 0 failures,
`OBJECTIVE MET for step 1`. The run is retained as
`docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt`, bound to four digests:
harness `ee98b157`, wrapper `4a046859`, setenv `355bbec5`, retained `88c4e0d2`.

`bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --wrapper
docs/v0.27.0/wrapper.pre-change.verification-only` on the same host: 34 cases,
0 failures, `OBJECTIVE MET for step 0`, retained as
`docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`. Both captures were retaken
because extending the suite changed the harness digest and every retained
capture is bound to the instrument that produced it.

Both plan commands are green on the reviewing Windows host through the capture
substitution, 22 cases each, 0 failures, which is the identity assertion doing
its job rather than a second measurement.

What the runs measure, and where the earlier round fell short. The ordinary
first call makes 7 post-source helper calls and 0 of them see the shipped search
path. The `-m venv` run makes 13, over the post-interpreter branch where `cp`,
`grep` and both `sed` sites exist and nowhere else, and 0 of them see it. A
repeat call over the already-surgered tree makes 9, reaching the `else` arm of
the relink `if`, the fourteenth and last site, and 0 of them see it. Every
helper name is asserted PRESENT before any zero is read, so an unexecuted branch
fails rather than passes.

Both restore sites are now entered by a run rather than counted in the source:
`step1/interpreter-value-is-the-shipped-path` for the first arm and
`step1/venv/second-arm-value-is-the-shipped-path` for the VIRTUAL_ENV arm, each
asserting the value IS the search path `setenv` built rather than merely some
value.

#### Static check evidence for step 1 python-wrapper-foreign-distro (round 2)

`shellcheck docs/v0.27.0/verify.wrapper-scope.sh src/install/env/python/bin/python`:
no finding. `bash src/utils/lint_shell.sh`: clean over 44 tracked scripts. This
project has no `check.bat`; these are the substituted static gates and both were
run on the current bytes.

#### Coverage evidence for step 1 python-wrapper-foreign-distro (round 2)

The project default `ghog day` runs `ghog check` green, then `ghog affected
--no-cov` stops at exit 5 on `pytest not found on PATH`. cplx has no pytest
suite and no unit-tested class file, so there is no percentage to report; that
was equally true before this change and is not a finding about it. The
behavioural substitute is the suite itself, held to the case contract: 50 cases,
0 failures, every behavioural claim measured from the wrapper's run.

#### Architecture evidence for step 1 python-wrapper-foreign-distro (round 2)

The change is confined to the one shipped file the plan's scope anchors name,
adds no file to the shipped tree, and introduces one variable prefixed `CPLX_`
so it cannot collide with a caller's. `setenv` is read and digested, never
written, and asserted byte-identical to the digest step 0 recorded. The harness
and both captures stay under `docs/v0.27.0/` and are never packaged. The wrapper
is 113 lines against a plan budget of 115.

#### Performance evidence for step 1 python-wrapper-foreign-distro (round 2)

One variable assignment and one `unset` per invocation, and two per-command
environment assignments that replace nothing. Nothing new grows with the size of
a deployment.

#### Feature integrity evidence for step 1 python-wrapper-foreign-distro (round 2)

The clean first call still ends 0, still performs the whole surgery, and still
leaves `python3` relinked to the wrapper with `python3_target` naming the real
interpreter: the tree shape step 0 recorded before the change. The `-m venv` run
ends 0 and rewrites the venv tree as before; the repeat call ends 0 and does not
perform the surgery again. Both interpreter arms receive the shipped search
path, asserted by value.

### Implementation report for step 1 python-wrapper-foreign-distro (round 2)

#### What changed since round 1 for step 1 python-wrapper-foreign-distro (round 2)

Round 1 was published against index tree `bbb2e6e1`, and a writer-side
implementation check then recorded that step 1 was NOT fully implemented,
changing the staged validation record. The reviewer refused to assess the round
because the request-time index no longer described the repository. That refusal
was correct and this round is published against the live index instead.

Three things were repaired, in the order the validation record listed them.

**The scope oracle now measures every post-source site.**
`docs/v0.27.0/verify.wrapper-scope.sh` gains a planted `-m venv` variant and a
repeat call:

- `plant_venv_target` and `assert_venv_target` build and assert the venv tree
  the wrapper post-processes: `bin/python3` is the link line 89 resolves,
  `bin/pip` is what the line 98 `sed` rewrites, `bin/activate` carries the
  `_bin_bin` text the line 112 `grep` looks for, and `bin/<stub>_bin_bin` exists
  before the run because the VIRTUAL_ENV arm calls it at line 85. The link
  target is planted as a real file rather than left dangling, since `[ -e ]`
  follows the link and a plant that cannot be asserted breaks the case contract;
- `run_wrapper_venv` invokes the wrapper with `-m venv venv`, FROM the directory
  holding that dir, since line 89 resolves it through `$(pwd)`, and with
  VIRTUAL_ENV naming it, since the `_bin_bin` fixup at line 101 is guarded by
  it. All three are needed or the branch never executes;
- the venv cases assert `readlink` 4, `mv` 1, `ln` 6, `cp` 1, `sed` 2, `grep` 1,
  interpreter 1 and 13 post-source calls PRESENT, and only then read
  `helpers-seeing-search-path` 0;
- the second-call cases assert no repeated surgery, `readlink` 5 and 9
  post-source calls, then the same zero. The nine include two the fixture
  causes rather than the wrapper: `${DIR}/pip` links to `current/bin/pip3`,
  which the fixture never plants, so the `-e` test is false on every call. The
  comment says so where the count is asserted;
- the two grep chains that read the log became `count_helpers_with_search_path`
  and `interpreter_saw`, so step 0 and step 1 cannot drift apart through a
  retyped pipeline.

**Both retained captures were retaken**, because extending the suite changed the
harness digest and both captures are bound to it. Step 1 is now 50 cases and its
header states what the venv path adds; step 0 is unchanged at 34 cases with a
new harness digest.

**The W2 explanation was wrong in four places and is corrected in all four.** A
per-command environment assignment IS inherited by the interpreter and by
everything it spawns, exactly as an `export` would be. What it does not do is
change the wrapper shell's own environment, which is why the helpers after the
call sites stay unset. The wrapper comment, the harness comment at
`step1/source/no-export`, the validation prose and the `a.commit` group 3 body
all said the narrower and false thing, and now say the true one.

The shipped wrapper is otherwise unchanged by this round: same save site, same
unset, same two restore sites, still 113 lines. Only its two comments changed.

### Change summary for step 1 python-wrapper-foreign-distro (round 2)

#### Staged paths for step 1 python-wrapper-foreign-distro (round 2)

Index tree `80707c7313be77e2014702f8236db18afe712152`, seven staged paths:

- `.vscode/settings.json`
- `docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md`
- `docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md`
- `docs/v0.27.0/verify.wrapper-scope.sh`
- `docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`
- `docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt` (new)
- `src/install/env/python/bin/python`

The review transcript `docs/v0.27.0/review.code.v0.27.0.python-wrapper-foreign-distro.md`
is modified and deliberately NOT staged: it grows with every round of this
exchange, so it belongs to the residual pass of the authorized commit rather
than to a group fixed now.

#### Commit plan for step 1 python-wrapper-foreign-distro (round 2)

`commit-plan-check --format json` reports `state: valid`, `ready: true`,
no diagnostics, with every staged path covered exactly once by seven groups in
dependency order:

1. `chore(vscode): add SUBJECTID and theorised` over `.vscode/settings.json`
2. `docs(plan): name the step 1 command and capture` over the plan
3. `fix(wrapper): unset the search path for helpers` over the shipped wrapper
4. `test(wrapper): add the step 1 scope suite` over the harness
5. `test(wrapper): retake the step 0 capture` over the step 0 capture
6. `test(wrapper): capture the step 1 scope rule` over the step 1 capture
7. `docs(wrapper): record step 1 completion` over the validation record

Membership, grouping and order are unchanged from round 1: the same seven paths
in the same seven groups. Four group bodies were amended because their subjects
no longer described the staged work: group 3 carried the false W2 explanation,
group 4 claimed eleven run-measured cases, group 6 claimed 30 cases, and group 7
did not mention the venv evidence or what the project default reports.

### Writer response for step 1 python-wrapper-foreign-distro (round 2)

Writer response: #### Response to the round 1 answer for step 1 python-wrapper-foreign-distro (round 2)

The round 1 answer is accepted in full. There is no disagreement to record.

The reviewer refused to assess round 1 because the request bound the round to
index tree `bbb2e6e1` while the live index reported `3a2d5dff`, and the retained
manifest recorded no repair paths, no pre-repair blobs and no validation-after
state, so the change was not attributable through it. That is correct. The drift
was writer-side: an implementation check run after the request was published
changed `docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.validation.md`,
flipping the step 1 verdict to NOT fully implemented and listing three pieces of
missing work.

Each of the reviewer's four instructions was carried out:

- reconcile the staged tree with the writer-owned step 1 state, including the
  validation content that changed after publication. Done, and the flip was kept
  rather than reverted, because it was right: the suite really did measure only
  seven of the wrapper's fourteen post-source sites, and the W2 explanation
  really was false. All three listed items are now repaired;
- regenerate `a.commit`. Done. Membership, grouping and order were already
  correct, so four group BODIES were amended and no boundary moved;
- rerun `commit-plan-check.bat --format json`. Done: `state: valid`,
  `ready: true`, no diagnostics;
- publish a replacement request whose `request_index_tree` matches the live
  staged index, without reusing the abandoned request's implementation
  assessment or its stale manifest. This request is rendered from a fresh
  assessment against the current index.

One thing worth naming for this round rather than leaving implicit. The step 1
completion criterion says the log must show EVERY post-source helper invocation
observing no `LD_LIBRARY_PATH`. Round 1 satisfied it only for the seven calls an
ordinary first call makes. The suite header already claimed the oracle covered
fourteen post-source helpers, so the instrument's own description was ahead of
what it measured. It now measures all fourteen.

### Reviewer focus for step 1 python-wrapper-foreign-distro (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-1-round-2 -->

## Round 2 by reviewer - Step 1

- Recorded: 2026-09-01T08:57:06+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 1
- Outcome: answer

### Assessed index identity for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

Baseline index tree: 80707c7313be77e2014702f8236db18afe712152

Assessed index tree: 80707c7313be77e2014702f8236db18afe712152

### Implementation check for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

Result: Yes. Step 1 has been fully implemented.

The wrapper has exactly one save and unset immediately after sourcing `setenv`,
two per-command restore sites, and no export. The Step 1 suite establishes the
behaviour from executed runs: the ordinary first call, the `-m venv` path, and
the repeat call together reach all fourteen post-source helper sites; every
expected helper is asserted present before the zero search-path count is read;
and both interpreter arms receive the exact shipped search path. The empty-value
variant records `empty`, not `unset`, and the shipped `setenv` digest remains the
Step 0 value.

Architecture remains within the plan boundary: only the named shipped wrapper
changes, while the harness and captures remain documentation-only evidence.
There is no DDD-Hexagonal concern in this Bash project. Performance adds one
assignment, one unset, and two per-command environment assignments, with no
deployment-size-dependent computation. The repository has no unit-tested class
files or pytest suite; its declared shell lint floor, request shellcheck, and
behavioural harness substitute all pass. First-call, venv, repeat-call, and both
interpreter-arm evidence show no feature-integrity regression.

Validation plan effects: No reviewer edit was needed. The staged validation plan already starts Step 1
with the exact `Yes. Step 1 has been fully implemented.` sentence, contains no
Step 1 missing-work section, records the venv and repeat-call evidence, and
keeps the document-level status pending because Steps 2 through 5 have not yet
been implemented. No umbrella row was changed.

### Pre-repair mandatory checks and coverage for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

No repair was made. On the exact request index, `bash src/utils/lint_shell.sh`
reported 44 tracked scripts and clean; the Step 0 command returned 22 local
capture-substitution cases, zero failures, and `OBJECTIVE MET`; the Step 1
command returned 22 local capture-substitution cases, zero failures, and
`OBJECTIVE MET`; and shellcheck returned no finding for the harness and wrapper.
The bound RHEL captures record Step 0 at 34 cases and Step 1 at 50 cases, both
with zero failures and matching harness, wrapper, setenv, and retained-wrapper
digests.

### Resolved validation set and sources for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

`bash src/utils/lint_shell.sh` (project and request): passed, 44 tracked scripts,
clean.

`bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 --wrapper docs/v0.27.0/wrapper.pre-change.verification-only --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt` (plan): passed through the identity- and subject-bound retained capture, 22 local cases and zero failures; retained RHEL evidence is 34 cases and zero failures.

`bash docs/v0.27.0/verify.wrapper-scope.sh --step 1 --capture docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt` (plan): passed through the identity- and subject-bound retained capture, 22 local cases and zero failures; retained RHEL evidence is 50 cases and zero failures.

`shellcheck docs/v0.27.0/verify.wrapper-scope.sh src/install/env/python/bin/python` (request): passed with no finding.

### Resolver drift and direction for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

No resolver drift. The current project declaration, plan additions, and request
additions resolve to the same four-command set embedded in the round-2 request.
No command was added, removed, weakened, or unavailable.

### Repository state around validation for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

The request, baseline, assessed, and post-validation index trees are all
`80707c7313be77e2014702f8236db18afe712152`. The umbrella digest remained
`9e85a83e58c8e23983f9965f1c8310087e0a71f655595e42350739a73c77f404`.
Validation-state comparison reports no tracked, untracked, or ignored path
change. The review transcript remains protocol-owned output outside the staged
index.

### Repair inventory for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

Accurate. The independent checker reports `state: valid`, `ready: true`, seven
staged paths covered exactly once by seven conventional groups, and no
diagnostic. Membership and dependency order are correct. The amended group
bodies now accurately describe W2 inheritance, all fourteen helper sites, the
50-case Step 1 capture, and the completed validation evidence.

### Findings and boundaries for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

No implementation rework is requested. Present the advisory `commit-ready`
recommendation at the durable human gate. A commit remains unauthorized until
the requestor receives the human's registered `Commit` choice.

### Decision rationale for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

Recommend `commit-ready`. Exact identity, complete Step 1 implementation,
mandatory validation and behavioural coverage, attributable staged scope,
absence of unresolved findings, and accurate commit grouping all pass. This
round made no substantive or polishing repair. The recommendation is advisory
and does not authorize a commit.

### Final reviewer decision for step 1 python-wrapper-foreign-distro (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-1-round-2 -->

## Round 2 by human - Step 1 - human-confirmation

- Recorded: 2026-09-01T09:26:44+02:00
- Exchange: code/code/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Implementation step: 1
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
