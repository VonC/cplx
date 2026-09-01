# v0.27.0 python-wrapper-foreign-distro implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.python-wrapper-foreign-distro.md](plan.v0.27.0.python-wrapper-foreign-distro.md),
six steps that scope the shipped search path to the interpreter and make the
wrapper fail closed on an unusable helper result. Steps 0 and 1 are complete, the
retained measurements are bound to their instrument and subject files, and every
mandatory command is green on both a POSIX host and the reviewing Windows one;
steps 2 to 5 have not started.

> Skeleton note: every per-step section other than `Goal` carries the literal
> placeholder `_(empty -- no check has taken place yet.)_.` until an
> implementation check fills it.

Reference environments: [reference.environments.md](reference.environments.md)

## What this validation owes, and what it does not

The umbrella's acceptance for this item names a first call answering on a
Debian 12 container. That check is now STEP 5 of this plan rather than an
obligation handed elsewhere, because the CI agent is that Debian host and it is
reachable again.

WHAT IS A STEP, AND WHAT IS OWED, which are not the same thing:

- STEP 4, not an obligation: freezing the harness, generating the identity
  manifest in a later commit, landing the pipeline copies and probe, and
  obtaining one build capture. An earlier revision listed this as owed after the
  Debian step while that same step also produced the manifest, which was
  circular. It is now the step that comes first.
- OWED AFTER STEP 5: the same first call over the archive umbrella item 7
  REBUILDS, which is a different artifact from the one published today and is
  item 7's to check.

Neither gates steps 0 to 3. Item 2 of this umbrella spent nine review rounds
discovering that a criterion a requirement cannot discharge must not hold its
verdict open; this item states the boundary before the work rather than after,
and states it again here so a later reader does not have to reconstruct it.

## Step 0. Baseline over a planted fixture

### Analysis of Step 0 implementation state

Yes. Step 0 has been fully implemented.

Every finding of code review rounds 1 and 2 is resolved, and the complete
resolved validation set is green on both the reviewing Windows host and a POSIX
one: the project lint floor over 44 scripts, `shellcheck` with no finding, and
the plan command at 34 cases on RHEL 9.8 where it runs the suite and 22 on
Windows where it reads the retained measurement.

The retained measurement is now bound to four digests rather than one, the
instrument plus the three subject files, each with a named-reason control that
must fail. Round 2's exploit, a wrapper with identical command vocabulary and a
broken relink target, was reproduced against the fixed harness and is refused
with `SUBJECTID` and exit 1.

### Goal for Step 0

Capture what the wrapper does today over a planted fixture, in TWO runs: the
clean first call and a run with a path-selective failing `readlink`. The second
is the baseline step 2 compares against, and it can only be taken while the
pre-change wrapper is still the file on disk.

### What was implemented for Step 0

All three files the plan names, the third of them added to that list by this
round's plan correction.

- `docs/v0.27.0/verify.wrapper-scope.sh`, new, 823 lines. The executable oracle:
  argument parsing with a step dispatch that refuses any step whose suite does
  not exist, a prerequisite preflight over the six helper names plus
  `sha256sum`, the shim coverage case, the measured host gate, the recording
  shim factory, the recording interpreter stub, the fixture planter with its
  assertion, the run driver, the Step 0 suite, and the retained-measurement
  substitution with its four identity checks and their four controls.
- `docs/v0.27.0/wrapper.pre-change.verification-only`, new, a byte-identical
  copy of `src/install/env/python/bin/python` at
  `88c4e0d22207b387b6b0d24542ba5301164e01f6cc698c02945722493b7f5706`. Never
  shipped, never packaged.
- `docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`, new, the retained capture,
  134 lines. It records the harness digest and the three subject digests, which
  is what makes it admissible on a host that cannot run the suite. Round 1
  agreed with the writer's own reading that Step 0's "files involved" had to name
  it, since Step 2 fails when that baseline artifact is absent, and the plan was
  corrected rather than the capture dropped.

No production file was modified. `src/install/env/python/bin/python` and
`src/install/env/python/bin/setenv` are read and digested, never written, which
is what makes this a baseline rather than a change.

Criterion by criterion, with the case that answers it:

- the planted fixture: `step0/runA/fixture` and `step0/runB/fixture`, both
  asserted after planting rather than assumed;
- RUN A, clean: `step0/runA/exit-status` 0, and the resulting tree shape in four
  cases (`python3` relinked to `../../bin/python`, the interpreter moved aside
  as `python3.13_bin`, `python3_target` naming it, and no empty-derived path);
- RUN B, planted: the `readlink` shim delegates both `-f` setup calls and fails
  only the line-30 site, proved by `step0/control-injection` observing exactly
  one injected failure and by `step0/runB/injected-call` recording its exact
  argument vector;
- the retained wrapper and its digest: `step0/retained-copy-matches-wrapper`
  compares it against the live file rather than printing both;
- the fixture control: `step0/control/unplanted-fixture-fails` requires the
  refusal to carry the `FIXTURE` reason, so a different failure cannot satisfy
  it;
- the RUN B control: `step0/control/clean-run-carries-no-injection` proves the
  injection oracle can fail, by demanding it refuse the clean log;
- the `setenv` digest: `step0/setenv-sha256`,
  `355bbec5cc5c1dfe7cf28c9b1bba0568acbe19c5b5662b97bbc5b549a8e5089d`.

THREE MEASUREMENTS CORRECTED WHAT THE HARNESS FIRST ASSERTED. Each is recorded
because a later step compares against the measured baseline, not the assumed
one.

- `readlink -f` runs TWICE as setup. The plan names line 12 of the wrapper;
  `setenv` line 7 calls it again, during the source and so still before `setenv`
  exports the search path at its own line 15. Both are delegated and neither
  carries an environment claim, which leaves decisions P6 and P9 intact and
  their arithmetic corrected.
- RUN B ENDS WITH EXIT STATUS ZERO. A non-zero status was expected, since line
  60 execs a path derived from an empty string. The two `if` statements after
  the exec both take their false branch, and a false `if` with no else is a
  successful statement, so the wrapper's last command succeeds. The pre-change
  defect is therefore SILENT: the tree is mangled, the interpreter never runs,
  and the caller is told the call worked. That is the fact Step 2 has to flip,
  and it is now asserted rather than hoped for.
- `current/bin/_bin` is a DANGLING REFERENT, not a file. RUN B leaves
  `current/bin` holding `python python3 python3.13 python3_target`, with
  `python3_target` a symlink to `_bin` and the interpreter never moved aside.
  The plan's phrase "the resulting `current/bin/_bin` shape" is satisfied by the
  symlink target and the derived exec path, which the capture states exactly so
  Step 2 asserts the same thing it measured here.

The baseline in one line: all seven post-source helper calls of a clean first
call observe the shipped search path, and so does the interpreter. Step 1 takes
the first count to zero and leaves the second where it is, and both halves are
asserted here so a change that broke the second could not pass on the first.

### What code review round 2 changed for Step 0

One finding, accepted without reservation, and it was demonstrated rather than
argued: the reviewer pointed the substitution at a wrapper with the SAME COMMAND
VOCABULARY as the real one and a deliberately broken relink target, and the
Windows path accepted it with 16 cases, 0 failures and `OBJECTIVE MET`.

THE GAP WAS EXACTLY ONE BOUNDARY OUT FROM ROUND 1'S FIX. Round 1 bound the
capture to the INSTRUMENT that produced it, and round 1's own request called that
binding the authority. It answers which harness measured. It says nothing about
what the harness measured, so a capture could certify a run over inputs nobody
compared to the ones present.

The capture verdict now carries four digests rather than one: `harness` plus
`wrapper-sha`, `setenv-sha` and `retained-sha`. A reading host asserts each of
the three subject digests against the exact `--wrapper`, `--setenv` and
`--retained` inputs it was given, and refuses with a `SUBJECTID` reason on any
mismatch. Three controls make those refusals asserted rather than assumed, one
per input, and the wrapper control keeps the command vocabulary identical on
purpose so it is exactly the file that passed before the binding existed.

The reviewer's exploit was reproduced against the fixed harness before this
record was written. The vocabulary comparison confirms the two wrappers are
indistinguishable to the coverage case, and the run now ends
`SUBJECTID wrapper recorded [88c4e0d2...], live is [e1064e8b...]`, one failure,
exit 1.

The plan's retained-measurement authority section was rewritten under writer
authority to state all four bindings and to record that the second half was
missing and how it was found.

### What code review round 1 changed for Step 0

Four findings, all accepted, none disputed. Two were defects the writer had not
seen, and both were the shape this requirement exists to remove, which is why
they are recorded rather than quietly fixed.

- THE HOST CONTRACT. The exact mandatory command failed on the reviewing Windows
  host with seven fixture and symlink failures. Those read as findings about the
  wrapper and were findings about the host. Decision P1 said "any host"; what
  steps 0 to 2 measure is symlink surgery, so the real boundary is any POSIX
  host. The harness now probes symlink capability BEFORE it plants anything. A
  host that fails the probe reads a retained measurement through `--capture`, or
  exits 4 saying it could not answer; it never reports 0 on its own account. P1
  and the target matrix were corrected under writer authority.
- THE CAPTURE'S AUTHORITY. A retained measurement is only worth reading if it
  cannot go stale unnoticed, so the capture records the SHA-256 of the harness
  bytes that produced it and the reading host asserts that value against the
  harness it was asked to run. A control feeds a copy mutated in exactly that
  digest line and requires the refusal, so the check that admits a capture is
  itself asserted. This was observed working during the rework: the capture from
  the previous harness revision was refused the moment the harness changed.
- THE PHANTOM COVERAGE CASE. A harness comment promised that "the coverage case
  below asserts the list against the wrapper" and no such case existed. That is a
  decorative gate written into the instrument built to refuse decorative gates.
  The case is now executable in both directions: no external command word in the
  wrapper lacks a shim, and no entry of the shim list is dead. The comment
  records why it must stay real.
- THE FINDINGS COUNT. The capture header said `TWO FINDINGS THIS RUN CORRECTED`
  while this record and the request said three. The header now says three and
  names the dangling `_bin` referent as the third.

The Step 0 file list gained `docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt`.
The reviewer and the writer reached that one independently: Step 2 requires the
comparison to be against a Step 0 baseline artifact and fails if it is absent,
and no step produced one, so the plan asked Step 2 to compare against a file
nothing created.

### New types or classes introduced for Step 0

None in the production sense: no shipped file changed. The harness introduces
three internal constructs, all confined to it.

- The recording shim, one generated script per helper name, placed first on
  `PATH`, logging one tab-separated line and delegating to the real tool by
  absolute path. Delegating by name would re-enter the shim through `PATH` and
  loop.
- The recording interpreter stub, a shell script standing in for the archive
  interpreter, which keeps Steps 0 to 2 runnable on any host (decision P1) and
  is exactly why Steps 3 and 5 use the real interpreter instead.
- The call log format, `helper TAB argv TAB search-path state TAB cwd TAB
  disposition`, whose third field distinguishes `unset` from `empty` from a
  value because that difference is the subject of decision W3.

### Architecture check for Step 0

The layering question this project actually has is what may reach a SHIPPED
file, and Step 0 respects it completely. The harness and the retained wrapper
live under `docs/v0.27.0/`, are never packaged, and are named
`verification-only` where they duplicate a shipped file. Nothing under `src/`
was modified, and the two source files the harness consumes are opened read
only and digested.

The harness keeps helpers and the interpreter in separate counts. Folding them
together would have made the Step 1 claim unfalsifiable in the direction that
matters, since the interpreter is the one caller that is supposed to see the
shipped search path, so this separation is a correctness property rather than
tidiness.

The DDD-Hexagonal criterion does not apply: cplx is a Bash and Batch project
with no adapters, ports, or domain layer, and no Python package under check.

No, there is nothing that needs to be addressed.

### Performance check for Step 0

The harness runs the wrapper twice and greps a log that holds at most a few
dozen lines. `count_calls` scans the log once per helper name, which is bounded
by six names times the log length and is linear in it. The fixture planter
writes seven small files. There is no sort over a growing input, no nested scan
of the same collection, and nothing whose cost grows with the size of a
deployment, because the fixture is planted rather than discovered.

No, there is no performance issue that needs to be addressed.

### Unit test coverage check for Step 0

The 100 percent unit coverage rule targets `src\pdfss\tests\unit`, which belongs
to the consuming project. cplx has no `pyproject.toml`, no `check.bat` and no
pytest suite, so there is no unit-tested class file to hold to that gate, and
reporting one would be inventing a measurement.

The substituted gate is the one CLAUDE.md names for this project: `shellcheck`,
which passes on the harness with exit 0 and no finding, after two scoped
suppressions that each carry the reason they are correct (the shim and stub
generators must keep `$` unexpanded, and the control functions are reached
indirectly). The harness's own suite is the behavioural equivalent, and it is
held to the case contract rather than to a coverage percentage: 31 cases, 0
failures, every claim measured from the wrapper's run, and two negative controls
that must refuse for a named reason so the suite cannot bless an empty tree or a
clean log.

No, there is no unit-tested class below 100 percent that needs completing.

### Feature integrity for Step 0

No existing feature or reporting capability is impaired, and none could be: Step
0 changes no shipped file. The wrapper on disk is byte-for-byte what it was, at
`88c4e0d2`, and the retained copy proves it.

Two facts worth carrying forward rather than rediscovering:

- the wrapper is 90 newline-terminated lines, where the plan's line budget says
  91. The budget is a review trigger rather than a gate, and the plan's other
  confirmed line numbers (12, 18, 30, 34, 47, 60, 62, 66) all match the file
  exactly, so this is a counting convention and not a drifted target. Step 1's
  expected landing point should be read as "under 115" against the measured 90.
- the authoring host CANNOT run this suite. Windows refuses to create the
  fixture's symlinks, and the harness reports that as a `FIXTURE` failure rather
  than proceeding, which is the negative control working. The capture was taken
  on RHEL 9.8 purely as the nearest POSIX host; Step 0 remains host-agnostic by
  decision P1, and nothing in it is RHEL-specific.

## Step 1. Scope the search path to the interpreter

### Analysis of Step 1 implementation state

Yes. Step 1 has been fully implemented.

Every completion criterion is answered by an executed run rather than by reading
the wrapper, and the runs now reach ALL FOURTEEN of the wrapper's post-source
helper sites rather than the seven an ordinary first call makes.
`verify.wrapper-scope.sh --step 1` reports 50 cases and 0 failures on RHEL 9.8,
and the whole resolved validation set is green on the reviewing Windows host
too. The scope rule flipped exactly as step 0's baseline predicted: seven of
seven post-source helper calls saw the shipped search path before, zero see it
now, on the first call and on the venv path alike, and the interpreter still
does on both of its arms.

The wrapper is 113 lines against a budget of 115, with one save site, one unset,
two restore sites and no `export`.

### Goal for Step 1

Implement decision D2: one save and unset after the source, one restore per
interpreter invocation, measured from the run rather than read from the source.

### What was implemented for Step 1

Three files: the shipped wrapper, the harness, and the retained capture the plan
gained in this step's file list.

`src/install/env/python/bin/python`, the FIRST shipped file this requirement
modifies. Two edits, both of them decision D2/W1:

- ONE save site, immediately after the `source` at line 18, holding the value in
  `CPLX_TOOLCHAIN_LD_LIBRARY_PATH` rather than re-deriving it, followed by
  `unset LD_LIBRARY_PATH`. The assignment is `${LD_LIBRARY_PATH-}`, which yields
  empty when unset, so one line covers W3's empty case without a branch;
- TWO restore sites, one per arm of the interpreter `if`, using the per-command
  environment assignment. That assignment is inherited by the interpreter and by
  everything it spawns, exactly as an `export` would be; what W2 buys is that it
  does not change the wrapper shell's own environment, so every helper after the
  call sites still sees no `LD_LIBRARY_PATH`.

`docs/v0.27.0/verify.wrapper-scope.sh` gained the step 1 suite, the `0|1`
dispatch, and a step-aware capture substitution. The suite has four source-level
cases and thirty-five measured from runs, over three fixtures: the ordinary
first call, the empty-value variant, and the `-m venv` tree the post-interpreter
branch rewrites.

`docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt`, the retained capture, 155
lines, 50 cases, 0 failures.

Criterion by criterion, with the case that answers it:

- exactly one save site, value held in a variable: `step1/source/save-sites` and
  `step1/source/unset-sites`, both 1;
- exactly two restore sites in the prefix form: `step1/source/restore-sites` 2,
  and `step1/source/no-export` 0. These four read the FILE rather than a run, for
  the same reason the shim coverage case does: no single run can distinguish one
  save site from two that happen to agree;
- measured from the run, helpers unset on every path the wrapper has:
  `step1/helpers-seeing-search-path` 0 on the ordinary first call, asserted only
  after `step1/post-source-helper-calls` 7 and the individual `readlink` 3,
  `mv` 1, `ln` 5 counts establish those calls happened;
  `step1/venv/helpers-seeing-search-path` 0 over the `-m venv` run, after its
  thirteen calls are established name by name, `cp`, `grep` and both `sed` sites
  included, which exist on that path and nowhere else; and
  `step1/second-call/helpers-seeing-search-path` 0 over a repeat call, the only
  way to execute the `else` arm of the relink `if`, which is the fourteenth and
  last post-source site;
- both restore sites entered by a run rather than counted in the file:
  `step1/venv/second-arm-still-sees-it` and
  `step1/venv/second-arm-value-is-the-shipped-path`, since the VIRTUAL_ENV arm
  is the one a first call never takes and a two-site change measured on one arm
  is half verified;
- the interpreter still set: `step1/interpreter-still-sees-it` yes, and
  `step1/interpreter-value-is-the-shipped-path` yes, which checks the value is
  the search path `setenv` built from the fixture root rather than merely some
  value;
- the bootstrap asserted separately with no environment claim:
  `step1/setup-readlink-delegated` 2, reported as a NOTE carrying no assertion
  about what it observed, per decisions P6 and P9;
- an empty saved value reaching the interpreter as empty:
  `step1/empty/reaches-interpreter-as-empty` records `empty`, not `unset`, over a
  VARIANT fixture whose planted `setenv` exports an empty value. The shipped
  `setenv` always exports a non-empty one, so a variant is the only way to
  exercise W3; its own bytes are asserted unchanged separately;
- `setenv` byte-identical to step 0's digest:
  `step1/setenv-unchanged-since-step0`, `355bbec5...`.

THE BUG THIS SUITE CAUGHT IN ITSELF, recorded because it is the exact failure the
requirement exists to remove and it happened inside the instrument again. The
first run of step 1 reported `helpers-seeing-search-path 0` and would have read
as a clean pass. It was measuring NOTHING: `step1_runnable_suite` had not called
`plant_shims`, so `PATH` resolved every helper to the real tool and no call
reached the log. The presence assertions failed on all five counts and stopped
it. Had the suite asserted only the absence it cares about, step 1 would have
been reported done on an empty log.

TWO CONSEQUENCES OF STEP 1 THAT REACH BACK INTO STEP 0, both handled in the plan
rather than worked around:

- step 0's command must now name the retained wrapper. Step 0 describes the
  pre-change file; step 1 replaced the live one; the subject binding refuses the
  mismatch. That refusal was run and observed before the plan text was written;
- every harness edit invalidates every retained capture. Adding the step 1 suite
  changed the harness digest, so both captures were retaken. That is the price of
  binding a capture to its instrument, and it is the right price.

### Architecture check for Step 1

The layering rule this project has is what may reach a SHIPPED file, and step 1
is the first time this requirement crosses it. The change is confined to the one
file the plan's scope anchors name, adds no new file to the shipped tree, and
introduces one variable whose name is prefixed `CPLX_` so it cannot collide with
a caller's. `setenv` is read and digested, never written.

The harness and both captures remain under `docs/v0.27.0/`, never packaged. The
DDD-Hexagonal criterion does not apply to a Bash and Batch project.

No, there is nothing that needs to be addressed.

### Performance check for Step 1

The wrapper gains one variable assignment and one `unset` per invocation, and
two environment assignments that replace nothing. The suite runs the wrapper
four times, over three fixtures, and greps logs of at most a few dozen lines.
The four source-level cases each scan a 113-line file once. No new computation
grows with the size of a deployment.

No, there is no performance issue that needs to be addressed.

### Unit test coverage check for Step 1

The 100 percent unit rule targets `src\pdfss\tests\unit`, which belongs to the
consuming project; cplx has no pytest suite and no unit-tested class file, so
there is no percentage to report. The project default `ghog day` says the same
thing from the other side: `ghog check` is green, then `ghog affected --no-cov`
stops at exit 5 on `pytest not found on PATH`. That is the absent suite, not a
finding about this change, and it was equally true before it. The substituted
gate is `bash src/utils/lint_shell.sh`, green over 44 tracked scripts, plus
`shellcheck` on both the harness and the modified wrapper, each with no finding.

The behavioural substitute is the suite itself, held to the case contract rather
than to a percentage: 50 cases, 0 failures, every behavioural claim measured from
the wrapper's run, over all fourteen of its post-source helper sites rather than
the seven a `--version` call reaches, and the presence assertions that caught the
empty-log pass.

No, there is no unit-tested class below 100 percent that needs completing.

### Feature integrity for Step 1

No existing feature is impaired, and the runs say so rather than the reasoning.
The clean first call still ends 0, still performs the whole surgery, and still
leaves `python3` relinked to the wrapper with `python3_target` naming the real
interpreter: the same tree shape step 0 recorded before the change. The only
difference in that log is which processes saw `LD_LIBRARY_PATH`.

The venv path is exercised rather than argued about. The `-m venv` run ends 0,
makes its thirteen post-source helper calls, and rewrites the venv tree as
before; the repeat call ends 0 and does not perform the surgery again. Both
interpreter arms are entered by a run, and each hands the shipped search path
over, asserted by value rather than by presence:
`step1/interpreter-value-is-the-shipped-path` for the first arm and
`step1/venv/second-arm-value-is-the-shipped-path` for the second. The change
cannot have quietly broken the one caller that needs the search path, on either
arm.

No, no feature-integrity evidence is still owed for Step 1.

## Step 2. Fail closed on an unusable helper result

### Analysis of Step 2 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 2

Stop at all three `readlink` sites rather than deriving paths from an empty
value, with the tree provably unmodified after the stop.

### What was implemented for Step 2

_(empty -- no check has taken place yet.)_.

## Step 3. No regression on the RHEL target

### Analysis of Step 3 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 3

Prove the no-regression half of the umbrella's acceptance on the only host where
it can be checked. The Debian first call is no longer recorded as owed here: it
is step 5.

### What was implemented for Step 3

_(empty -- no check has taken place yet.)_.

## Step 4. Freeze, publish identity, land the handoff

### Analysis of Step 4 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 4

Freeze the harness, publish its identity, carry both across the repository
boundary, and obtain one build capture, so that step 5 consumes only artifacts
that already exist.

The completion conditions are named here rather than left to be recovered from
the plan prose:

- the harness is FINAL and committed, and steps 0 to 3 passed against those
  bytes. No later step edits it;
- the manifest is generated from the frozen bytes in a commit AFTER the freeze,
  naming `freeze_commit`, `harness_path` and `file_sha256` over the file bytes
  at that path. It never
  names its own commit, which is impossible;
- the pipeline harness copy, manifest copy and `wrapperScope()` probe land at
  the exact paths the plan names;
- one build has produced the capture, and a deliberately mismatched copy is
  shown to FAIL the probe, so the unpaired-edit gate is demonstrated rather than
  asserted.

### What was implemented for Step 4

_(empty -- no check has taken place yet.)_.

## Step 5. Acceptance on the Debian agent

### Analysis of Step 5 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 5

Prove the fix on Debian 12, the only distribution the defect exists on, with the
reverted-fix control in the same run so a pass cannot be confused with a pass on
a host where the defect never fires.

The completion conditions are named here rather than left to be recovered from
the plan prose, so an implementation check can read them directly:

- TWO freshly extracted isolated trees in one run, the fixed wrapper in one and
  the retained pre-change control in the other;
- the control bytes verified against their named cplx commit, path and
  expected `file_sha256` BEFORE the control runs, failing the suite on mismatch;
- THE INDEPENDENT IDENTITY CHECK, performed here rather than on the agent: the
  manifest's `freeze_commit`, `harness_path` and `file_sha256` verified against
  the canonical harness in this repository before the capture is accepted. This
  is the half a paired pipeline edit cannot restate;
- the harness is NOT modified by this step; a digest that no longer matches the
  manifest is a failure, not a new baseline.

### What was implemented for Step 5

_(empty -- no check has taken place yet.)_.
