# v0.27.0 python-wrapper-foreign-distro implementation tracking and validation

Yes, it is implemented.

This document tracks the implementation of
[plan.v0.27.0.python-wrapper-foreign-distro.md](plan.v0.27.0.python-wrapper-foreign-distro.md),
seven steps that scope the shipped search path to the interpreter and make the
wrapper fail closed on an unusable helper result. All seven are complete: the
mechanism is measured over a planted fixture, the RHEL target shows no
regression, the harness is frozen with its identity published and carried to the
Debian agent, and step 5 has proved the fix on Debian 12 over two freshly
deployed trees, with the pre-change control refusing in the same run and the
same suite refusing on RHEL where the defect cannot fire.

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

Yes. Step 2 has been fully implemented.

All three read sites are checked calls through one shared guard, and the stop is
measured from injected runs rather than read from the source.
`verify.wrapper-scope.sh --step 2` reports 53 cases and 0 failures on RHEL 9.8,
that run is retained as `docs/v0.27.0/verify.wrapper-scope.step2.rhel.txt`, the
plan names both the capture and its exact command, and the reviewing Windows host
now answers step 2 through the capture substitution instead of exiting 4.

The change is measured against step 0 run B rather than assumed. The suite
re-runs the retained pre-change wrapper under the same injection and reproduces
the recorded mangling: `python3_target` derived from an empty value, the
interpreter never reached, six `mv`/`ln`/`cp`/`sed` calls after the failed read,
and a silent zero exit. The guarded wrapper turns those six into zero and that
zero exit into a non-zero one.

The wrapper is 131 lines against a plan budget of 115. The code review examined
that overshoot under the plan's explicit trigger rule and accepted it, because
the named failure, per-site guard duplication, is absent: one shared guard serves
all three calls.

### Goal for Step 2

Stop at all three `readlink` sites rather than deriving paths from an empty
value, with the tree provably unmodified after the stop.

### What was implemented for Step 2

Three files, which is the plan's step 2 file list as the code review amended it:
the shipped wrapper, the harness, and the retained capture. The plan itself and
the step 0 and step 1 captures changed as consequences, and are covered below.

`src/install/env/python/bin/python` gained ONE shared `guarded_readlink` helper
and three checked calls:

- `guarded_readlink SITE PATH` runs `readlink` and returns non-zero when EITHER
  the exit status is non-zero OR the output is empty, printing
  `python: readlink failed at <site>: '<path>'` on stderr. On success it prints
  the value, so the call sites keep the shape they already had;
- every caller propagates with `|| exit`, at `relink-read`
  (`current/bin/python3`), `target-read` (`current/bin/python3_target`) and
  `venv-read` (`<venv>/bin/python3`). That propagation is the whole content of
  the contract: each call site is a command substitution and therefore a
  SUBSHELL, so an `exit` inside the helper would end only that subshell and leave
  the wrapper running with the empty value it exists to refuse;
- the bootstrap `readlink -f` at line 12 stays unchecked, by decision P6. It runs
  before `setenv` is sourced, and failing it would stop the wrapper before any
  guarded site is reached, so the run would prove nothing.

`docs/v0.27.0/verify.wrapper-scope.sh` gained the step 2 suite, the `0|1|2`
dispatch, `guarded_readlink` in the wrapper vocabulary the shim coverage case
reads, an optional wrapper argument on `plant_fixture` so the retained
pre-change copy can be planted as a fixture, an optional fail suffix on
`run_wrapper_venv`, and three oracles: `injected_argv`,
`mutations_after_injection` and `tree_snapshot`.

The step 2 code review made one polishing repair in that file, kept staged: a
targeted `shellcheck disable=SC2016` on the `unguarded-readlink-calls` case,
whose single-quoted `$(readlink` pattern, trailing space included, is
deliberately literal. The authoring host's shellcheck did not raise it and the
reviewer's did, so the suppression records the intent rather than silencing a
real finding.

`docs/v0.27.0/verify.wrapper-scope.step2.rhel.txt` is the retained capture the
review added to the plan: 53 cases, 0 failures, bound to harness `d4e347cc`,
wrapper `7213dfe0`, setenv `355bbec5` and retained wrapper `88c4e0d2`.

Criterion by criterion, with the case that answers it:

- a non-zero exit and a message naming the helper, the site and the path:
  `step2/site1|site2|site3/exit-status-non-zero` yes, and
  `.../message-names-helper-site-and-path` yes, which asserts the SITE LABEL and
  the PATH are both in the text rather than that any output appeared at all;
- the tree unmodified, asserted twice and in two different ways.
  `.../tree-unmodified` yes compares a shape snapshot taken before the run with
  one taken after; `.../no-mutation-after-injection` 0 counts the `mv`, `ln`,
  `cp` and `sed` lines appearing after the injected `readlink` in the call log.
  The snapshot records every path, every symlink target and every file size and
  deliberately ignores mtime, because the wrapper legitimately recreates an
  identical `pip` symlink on a repeat call and a shape that changed by nothing is
  not a modification;
- the comparison against STEP 0 RUN B: `step2/baseline/*` plants the RETAINED
  pre-change wrapper and injects the same site, reproducing
  `python3_target-derived-from-empty` `_bin`, `interpreter-never-reached` 0,
  `exit-status-is-a-silent-zero` 0, and six mutations after the failure. The
  baseline artifact is asserted present AND asserted to be the step 0 subject by
  digest, and the suite returns rather than skipping when it is absent;
- each of the three sites injected separately and identified:
  `.../injected-call-is-this-site` yes reads the exact argv the shim recorded for
  the injected failure, so a run that failed a different read than the one it
  names cannot pass;
- a legitimate run still accepted: `step2/legitimate/*` ends 0, performs the
  surgery, calls the interpreter once and produces no `current/bin/_bin`, and
  `step2/site2/first-call-accepted` and `step2/site3/first-call-accepted` assert
  the same for the clean call each of those two sites needs before it can be
  reached at all;
- one shared guard rather than three inline ones: `step2/source/guard-definitions`
  1, `step2/source/checked-calls` 3, and `step2/source/unguarded-readlink-calls`
  2, the two being the bootstrap and the one inside the guard. These read the
  FILE, for the same reason step 1's four source-level cases do.

A CONSEQUENCE THAT REACHES BACK INTO STEPS 0 AND 1, the same one step 1 recorded
and for the same reason. Every harness edit invalidates every retained capture,
and this step also changed the shipped wrapper, which invalidates the step 1
capture's SUBJECT binding as well as its instrument binding. All three captures
were taken from the same final harness bytes on the same host, and they report
34, 50 and 53 cases with 0 failures. All three plan commands are green on the
reviewing Windows host through the capture substitution.

THE PLAN NOW NAMES A RETAINED CAPTURE FOR STEP 2, and did not when this step was
first published for review. Its file list held only the wrapper and the harness,
so `--step 2` could be answered on a POSIX host and nowhere else and the reviewing
Windows host exited 4. The step 2 code review ruled that a plan-owned evidence
gap rather than an acceptable omission, and named the plan amendment as requestor
authority. The plan's step 2 file list now names
`docs/v0.27.0/verify.wrapper-scope.step2.rhel.txt`, its command block names the
matching `--step 2 --capture` command, and the capture is retained with the four
digests that make it admissible.

### Architecture check for Step 2

The change stays inside the plan's boundary: the same one shipped file the scope
anchors name, no new file in the shipped tree, and one new shell function whose
name is local to the wrapper and is declared in the harness vocabulary so the
shim coverage case still reads the file correctly. The harness and the captures
remain under `docs/v0.27.0/` and are never packaged. `setenv` is read and
digested, never written, and asserted byte-identical to the digest step 0
recorded. The DDD-Hexagonal criterion does not apply to a Bash and Batch project.

Two things were raised for the code review rather than settled alone, and both
are now closed:

- the wrapper is 131 lines against the plan's 115-line budget. The plan calls
  that budget a review trigger rather than a gate and names the failure it is
  meant to detect, guards written per site instead of shared. That cause is
  measured absent, `step2/source/guard-definitions` 1 against
  `step2/source/checked-calls` 3, so the overshoot is comment density in the
  wrapper's own explanation of W2 and of the subshell trap rather than duplicated
  guards. The action the trigger asks for is a review before it lands; the review
  examined it and accepted it on that measured ground;
- the plan named no retained capture and no resolved command for step 2, so the
  step's evidence could not be read on a host that cannot create a symlink. The
  review ruled that a plan-owned gap, the plan now names both, and the capture is
  retained and asserted from the reviewing host.

No, there is nothing that needs to be addressed. The girth trigger fired, was
reviewed and was accepted with its named cause measured absent, and the evidence
gap it was raised beside is closed rather than deferred.

### Performance check for Step 2

The wrapper gains one function call per read site, three per invocation at most,
each running the same single `readlink` the site already ran. No read is
performed twice, and the guard adds one emptiness test per site. The suite adds
four wrapper runs and one shape snapshot per guarded site, and a snapshot walks a
fixture of about a dozen entries once. No new computation grows with the size of
a deployment, and nothing introduced here is O(n^2) or O(n log n).

No, there is no performance issue that needs to be addressed.

### Unit test coverage check for Step 2

The 100 percent unit rule targets `src\pdfss\tests\unit`, which belongs to the
consuming project; cplx has no pytest suite and no unit-tested class file, so
there is no percentage to report and no legacy unit test is impacted by this
step. The project default `ghog day` reports that same absence: `ghog check`
green, then `ghog affected --no-cov` at exit 5 on `pytest not found on PATH`. The
substituted gate is `bash src/utils/lint_shell.sh`, green over 44 tracked
scripts, plus `shellcheck` on both the harness and the modified wrapper, each
with no finding.

The behavioural substitute is the step 2 suite: 53 cases, 0 failures, every claim
about the stop measured from an injected run, and each failure case asserting its
injection was OBSERVED before concluding anything from what followed it.

No, there is no unit-tested class below 100 percent that needs completing.

### Feature integrity for Step 2

No existing feature is impaired, and the runs say so rather than the reasoning.
The legitimate first call still ends 0, still performs the whole surgery, still
leaves `python3` relinked to the wrapper, still calls the interpreter once, and
still produces no `current/bin/_bin`. The already-converted second call and the
`-m venv` call are both accepted before their own sites are injected, so a guard
that refused a good read would fail those cases rather than pass the failure
ones.

Step 1's evidence is unchanged by this step: `--step 1` still reports 50 cases
and 0 failures against the guarded wrapper, so scoping the search path and
failing closed do not interfere with each other.

No, no feature-integrity evidence is still owed for Step 2.

## Step 3. No regression on the RHEL target

### Analysis of Step 3 implementation state

Yes. Step 3 has been fully implemented.

The three calls the step owes were made over a tree deployed from the published
archive on RHEL 9.8, through the wrapper under test, against the REAL archive
interpreter rather than the recording stub steps 0 to 2 plant.
`verify.wrapper-scope.sh --step 3` reports 40 cases and 0 failures under run
identity `rhel-wrapper-20260901T121352Z`, and the retained capture ends with the
session's own cleanup transcript: the prefix listed present, removed, then
listed absent, with the live install's mtime and its wrapper's digest read
before and after and identical. The plan names both the capture and its command,
and the reviewing Windows host answers step 3 through the capture substitution.

A discovery changed what this step asserts, and it is recorded rather than
worked around. THE ARCHIVE IS PACKAGED FROM A TREE THE WRAPPER HAS ALREADY
CONVERTED: it ships `current/bin/python3` pointing at the wrapper and
`python3_target` at `python3.13_bin`. A deployed tree therefore never takes the
relink arm, and every call takes the other one. The first draft of this suite
asserted a conversion the first call would perform; those cases would have
passed on work the archive did. The suite now records the shipped state as a
case and asserts that the calls leave it unchanged, which is the claim a
no-regression step can actually make here.

### Goal for Step 3

Prove the no-regression half of the umbrella's acceptance on the only host where
it can be checked. The Debian first call is no longer recorded as owed here: it
is step 5.

### What was implemented for Step 3

Two files, which is the plan's step 3 file list: the harness and the retained
capture. The plan itself gained the step 3 command, and the three earlier
captures were retaken, both as consequences covered below.

`docs/v0.27.0/verify.wrapper-scope.sh` gained the step 3 suite and the machinery
it needs:

- four new arguments, all step 3 only: `--deployment` names the deployed python
  env root, `--prefix` the throwaway prefix that holds it, `--live-install` the
  install that must stay untouched, and `--run-identity` the identity the
  capture cites. THE SESSION DEPLOYS THE TREE, not the harness: a harness that
  deployed its own subject would be measuring an installer run rather than a
  wrapper, and the deployment recipe belongs to the operations note;
- a second host gate. Steps 0 to 2 ask whether the host can create a symlink;
  step 3 asks whether a deployed archive is named for this run, because that is
  what it cannot reproduce. A host without one reads the retained capture or
  exits 4, exactly as a host without symlinks does;
- `step3_call`, one call through the deployed wrapper with `HOME` pinned to the
  prefix, since the installer and the wrapper both read it, and from a stated
  working directory, since the venv site resolves its argument through `pwd`;
- the shim coverage case moved out of the steps 0 to 2 branch, because every
  step has the same wrapper as its subject, and the capture cross-check became
  `cross_check_capture` rather than the same eight lines in two gates;
- the verdict block gained `deployment` and `run-identity` lines, so a capture
  carries the tree it measured and the run it belongs to.

`docs/v0.27.0/verify.wrapper.rhel.txt` is the retained capture: 40 cases, 0
failures, bound to harness `b0d02647`, wrapper `7213dfe0`, setenv `355bbec5` and
retained wrapper `88c4e0d2`, taken under run identity
`rhel-wrapper-20260901T121352Z`.

Criterion by criterion, with the case that answers it:

- a first call over a deployed tree answering the toolchain version through the
  wrapper, on the REAL archive interpreter: `step3/call1/exit-status` 0,
  `step3/call1/answers-a-version` yes with `Python 3.13.9` recorded as a NOTE,
  and `step3/deploy/interpreter-is-an-elf` yes, which is the case that separates
  a real interpreter from the recording shell stub;
- a second call through the existing symlinks without repeating the surgery:
  `step3/call2/exit-status` 0, `step3/call2/same-version-as-the-first` yes, and
  `step3/call2/tree-unchanged` yes, a shape snapshot of `current/bin` before
  against after. `step3/call1/tree-unchanged` asserts the same of the first
  call, which is what a converted tree requires;
- `-m venv` creating and post-processing a virtualenv so the third guarded read
  site executes for real: `step3/venv/exit-status` 0, `step3/venv/created` yes,
  and the two writes that site produces,
  `step3/venv/target-relinked-to-wrapper` naming the deployed wrapper and
  `step3/venv/real-binary-copied-beside-it` yes. The target name is read from
  the venv the interpreter just built, exactly as the wrapper reads it;
- the capture naming the run identity, the target and the bash version, and
  citing that identity in its evidence: `step3/identity/run`,
  `step3/identity/target` `rhel 9.8` read from `/etc/os-release` rather than
  from `uname`, `step3/identity/bash`, and
  `step3/identity/prefix-carries-run-id` yes, which is the assertion that makes
  the identity evidence rather than decoration;
- every write under one throwaway prefix with `HOME` pinned, the live install
  unchanged, the prefix removed: `step3/prefix/deployment-under-prefix` yes,
  `step3/prefix/live-install-outside-prefix` yes,
  `step3/venv/under-the-prefix` yes, `step3/live/mtime-unchanged` across the
  three calls, and `step3/live/wrapper-is-not-the-subject` yes, which stops the
  mtime case passing by the two trees sharing a file. The removal itself is the
  last section of the capture rather than a sentence in its header: `post-run
  cleanup` is the session's own transcript, the exact commands and their exact
  output, listing the prefix present, removing it, listing it absent, and
  reading the live install's mtime and its wrapper's digest before and after.
  An earlier revision asserted those facts in the header and nowhere else, and
  the step 3 code review refused it, correctly.

THREE CONSEQUENCES, the first two the same ones the earlier steps recorded:

- the plan gained the step 3 command. A capture nothing reads answers nothing on
  the authoring host, which is what the step 2 code review ruled a plan-owned
  evidence gap. The command was added with the capture rather than after a
  second review found it missing;
- all four captures come from the same harness bytes, `b0d02647`. Adding the
  step 3 suite changed the digest, and the review's own repair changed it again,
  so all four were taken after the last edit and report their unchanged case
  counts, 34, 50, 53 and 40, with 0 failures;
- the cleanup runs in the SESSION, not in the harness. Removing the tree under
  measurement is not an oracle's job, and a harness that deleted its own subject
  would be one edit away from deleting something else. The transcript is what
  makes the session's action evidence.

### Architecture check for Step 3

This step changes no shipped file. The wrapper is untouched by it: its 131 lines
against the plan's 115-line budget were reviewed and accepted at step 2, on the
measured ground that the duplication the budget exists to detect is absent, and
nothing here alters that. The harness and all four captures remain under
`docs/v0.27.0/` and are never packaged, and the deployment the step measures is
built and destroyed inside a throwaway prefix.

The harness now carries two host gates rather than one, and that is the shape
the step needs rather than a smell: what a host cannot reproduce genuinely
differs by step, a symlink for steps 0 to 2 and a deployed archive for step 3.
The duplication that would have come with it was removed instead: the capture
cross-check is one function called from both gates, and the shim coverage case
is stated once for every step.

The DDD-Hexagonal criterion does not apply to a Bash and Batch project.

No, there is nothing that needs to be addressed.

### Performance check for Step 3

The step adds three wrapper calls and two shape snapshots of one directory to a
run that already deploys 1.9 GB, so its own cost is not measurable beside the
deployment the session performs once. Nothing in the suite grows with the size
of the deployed tree: the snapshots walk `current/bin`, about thirty entries,
and every other case reads one file or one link. Nothing introduced here is
O(n^2) or O(n log n).

No, there is no performance issue that needs to be addressed.

### Unit test coverage check for Step 3

The 100 percent unit rule targets `src\pdfss\tests\unit`, which belongs to the
consuming project; cplx has no pytest suite and no unit-tested class file, so
there is no percentage to report and no legacy unit test is impacted by this
step. The project default `ghog day` reports that same absence: `ghog check`
green, then `ghog affected --no-cov` at exit 5 on `pytest not found on PATH`.
The substituted gate is `bash src/utils/lint_shell.sh`, green over 44 tracked
scripts, plus `shellcheck` on the harness, with no finding.

The behavioural substitute is the step 3 suite: 40 cases, 0 failures, every
claim measured from a call the wrapper actually made over a real deployment.

No, there is no unit-tested class below 100 percent that needs completing.

### Feature integrity for Step 3

This is the step whose whole subject is feature integrity, and it reports no
impairment. The deployed wrapper answers the toolchain version on the first
call and the same version on the second, leaves `current/bin` byte-identical in
shape across both, produces no `current/bin/_bin` and no doubled `_bin_bin`
name, and still creates and post-processes a virtualenv with the real
interpreter. The live install beside it is untouched, before and after.

What this step CANNOT say is that the fix works: the defect cannot fire on RHEL
at all, because the shipped libc is the host libc family there. That claim
belongs to step 5 on Debian, with its reverted-fix control in the same build.

No, no feature-integrity evidence is still owed for Step 3.

## Step 4. Freeze the harness

### Analysis of Step 4 implementation state

Yes. Step 4 has been fully implemented.

`docs/v0.27.0/verify.wrapper-scope.sh` is final at `fab864ee`, steps 0 to 3 all
report `OBJECTIVE MET` against those exact bytes on RHEL 9.8, and all four
retained captures were retaken from them and name that digest. The four
plan-owned capture commands are green on the reviewing Windows host, with
`lint_shell.sh` clean over 44 tracked scripts and `shellcheck` reporting no
finding.

This sub-step exists because its own code review refused step 4 as one unit. The
manifest names the commit that froze the harness, and a commit id cannot be
written into a file that commit contains, so the freeze must be committed before
the manifest can be generated. The plan now carries that as two ordered
sub-steps and this is the first.

### Goal for Step 4

Make the harness bytes final, prove steps 0 to 3 pass against exactly those
bytes, and land them in one commit that step 4b's manifest can name.

### What was implemented for Step 4

The freeze, and the wording repair folded into it because a freeze is the last
moment the harness can be edited at all.

Two things changed in the harness since step 3, and nothing else:

- the coined word `surgered` became `converted`, in four places, three comments
  and one section title. It was never an English word: the plan's metaphor for
  the wrapper's first-call work is SURGERY, a real noun the harness still uses
  nine times, and an earlier session turned it into a verb that does not exist.
  The consequence was not cosmetic. A spell-corrector kept rewriting
  `already-surgered` to `already-surged`, the nearest real word, twice during
  the step 3 exchange and once after a reviewer had already assessed the
  corrected text. Left alone it would have been committed, because every commit
  group stages with `git add -A`. `converted` is the design document's own term
  for the same state, at its lines 116 and 171;
- the same rename in the step 1 capture header and in this document's step 2
  section, so no retained text carries the invented word either.

ALL FOUR CAPTURES WERE RETAKEN from the frozen bytes in one session on RHEL 9.8:
34, 50, 53 and 40 cases, 0 failures each. The step 3 retake cost a second
deployment of the published archive, 1.9 GB under a throwaway prefix, because
the previous run's prefix had already been removed and a capture cannot be
stitched from two runs; its `post-run cleanup` transcript was retaken with it
under run identity `rhel-wrapper-20260901T145429Z`.

Criterion by criterion:

- the harness is final and steps 0 to 3 passed against these bytes: all four
  suites report `OBJECTIVE MET` on RHEL against `fab864ee`, and the commit half
  is what the review gate authorizes;
- every retained capture names the frozen digest: all four verdict blocks carry
  `harness fab864ee`, and the four capture commands re-assert it from the
  reviewing host, which is the identity binding doing its job;
- the freeze commit is the one step 4b's manifest names: recorded in the commit
  plan, whose group 2 is the freeze and whose id becomes `freeze_commit`.

THE HARNESS IS NOW FROZEN. No later step may edit it: step 5 reads it, and a
step 5 that changed it would invalidate the identity step 4b publishes.

### Architecture check for Step 4

This sub-step changes no shipped file and adds no file to this repository. The
harness keeps the shape step 3 gave it, two host gates and one capture
cross-check; this change renames a word in it and nothing else. The captures
stay under `docs/v0.27.0/` and are never packaged. The DDD-Hexagonal criterion
does not apply to a Bash and Batch project.

No, there is nothing that needs to be addressed.

### Performance check for Step 4

Nothing was added. The rename touches four comment and title sites; the captures
are the same runs over the same fixtures and the same deployment recipe, and
their case counts are unchanged at 34, 50, 53 and 40.

No, there is no performance issue that needs to be addressed.

### Unit test coverage check for Step 4

The 100 percent unit rule targets `src\pdfss\tests\unit`, which belongs to the
consuming project; cplx has no pytest suite and no unit-tested class file, so
there is no percentage to report and no legacy unit test is impacted. The
project default `ghog day` reports that same absence: `ghog check` green, then
`ghog affected --no-cov` at exit 5 on `pytest not found on PATH`. The substituted
gate is `bash src/utils/lint_shell.sh`, green over 44 tracked scripts, plus
`shellcheck` with no finding.

No, there is no unit-tested class below 100 percent that needs completing.

### Feature integrity for Step 4

No behaviour changed, and the runs say so rather than the reasoning: all four
suites report the same case counts and the same zero failures as the runs step 3
published. That is the evidence a rename of comment text changed nothing
measurable.

No, no feature-integrity evidence is still owed for Step 4.

## Step 4b. Publish the identity and land the handoff

### Analysis of Step 4b implementation state

Yes. Step 4b has been fully implemented.

The manifest is generated from the frozen bytes and names the freeze commit; the
harness copy, the manifest copy and the `wrapperScope()` probe are landed at the
exact paths the plan gives; build 131 ran them and retained
`a.evidence/verify-wrapper-scope.debian.txt`; and that capture shows the
unpaired-edit gate refusing a deliberately mutated copy, so the gate is
demonstrated rather than asserted.

### Goal for Step 4b

Publish the frozen harness's identity, carry both across the repository
boundary, and obtain one build capture, so that step 5 consumes only artifacts
that already exist.

### What was implemented for Step 4b

One file in this repository, three in the pipeline one, and one build.

`docs/v0.27.0/verify.wrapper-scope.manifest.txt` carries the three fields the
plan names and nothing else:

- `freeze_commit` `233b549d1bfa96b0e0e2cf7e9d31c996cf132389`, the commit that
  froze the harness;
- `harness_path` `docs/v0.27.0/verify.wrapper-scope.sh`;
- `file_sha256` `fab864ee...`, over the FILE BYTES at that path, which its own
  header separates from a Git blob object id because the two are different
  hashes over different bytes.

IT IS GENERATED, NOT WRITTEN. The values come from `git rev-parse` and from
`git show <freeze-commit>:<harness-path> | sha256sum`, so the digest cannot
disagree with the file it describes. Its header records why it names an earlier
commit than its own: a commit identity is computed over its tree, the tree
contains this file, so writing that id here would change the tree and therefore
the id.

IN THE PIPELINE REPOSITORY, landed as two commits on `develop`, `1f2c934e` and
`ba942700`:

- `tools/wrapper_scope_verify.verification-only.sh`, byte-identical to the
  frozen harness, compared with `sha256sum` rather than by date;
- `tools/wrapper_scope.manifest.verification-only.txt`, byte-identical to the
  manifest above;
- `wrapperScope()` in `ci/Jenkinsfile.diagnostics`, called from the
  `verifyCplx()` parallel and listed in the probe index at the top of that file.

The probe reports and never gates, exit 0, like the probes beside it. What it
reports is TRANSPORT, never the wrapper: it hashes the local harness copy
against the manifest copy, runs the same comparison against a deliberately
mutated copy and requires the refusal, and checks the harness executes on the
agent.

Criterion by criterion, with the line that answers it:

- the manifest in a commit after the freeze, naming that commit: the three
  fields above, and this document's own step 4 section records the freeze
  commit they name;
- generated rather than hand-written: the two commands above, recorded in the
  manifest header;
- the pipeline copies and the probe at the exact paths: `1f2c934e` adds the two
  `tools/` files and `ba942700` adds the probe;
- ONE BUILD HAS RUN and produced the capture: build 131, SUCCESS, 17 minutes,
  `a.evidence/verify-wrapper-scope.debian.txt` retained and archived;
- the gate refuses a mismatched copy: `control/mutated-copy-refused PASS`, with
  the mutated digest `8d51d40d8f3a...` printed beside it so the refusal names
  what it refused.

WHAT THE CAPTURE RECORDS, quoted because the artifact lives in the pipeline
repository per build rather than in this one, which is what the plan's handoff
table says:

```text
distribution    debian 12
glibc           ldd (Debian GLIBC 2.36-9+deb12u10) 2.36
bash            5.2.15(1)-release
  file_sha256   fab864ee...
  local copy    fab864ee...
  gate/local-copy-matches-manifest        PASS
  control/mutated-copy-refused            PASS mutated copy is [8d51d40d8f3a...]
  harness/runs-here                       PASS
TRANSPORT VERIFIED
```

TWO THINGS THE CAPTURE STATES ABOUT ITSELF, both deliberate. Its `kernel` line
reads `5.14.0-...el9_8` on a Debian 12 agent, because the container shares its
host's kernel; the probe therefore reads the distribution from `/etc/os-release`
and says so in the line itself, so a later reader cannot mistake it for a RHEL
run. And it states that it makes NO claim about the wrapper: the archive
extracted there carries the pre-change one, and the acceptance that tells a
working fix from a plausible one is step 5, with its reverted-fix control in the
same build.

### Architecture check for Step 4b

This sub-step changes no shipped file and adds one generated evidence file to
this repository. The harness is untouched, which is what step 4 froze it for: a
step 4b that edited it would invalidate the identity it publishes, and the
manifest's own digest would stop describing the file.

The pipeline change stays inside the boundary the plan draws. It adds a probe to
`ci/Jenkinsfile.diagnostics`, which that file's header declares owned by the
cplx maintainer, and two `tools/*.verification-only.*` files that are never
delivered and never packaged. No reviewed pipeline stage changed.

The authority for the identity is not the manifest file, and the architecture
reflects that: the pipeline compares copy against manifest, which catches an
unpaired edit, and the paired-edit case is answered on this side by an
independent comparison in a repository the pipeline cannot reach. That check is
step 5's, and it is why this option was chosen over an expected digest kept
beside the copy.

The DDD-Hexagonal criterion does not apply to a Bash, Batch and Groovy project.

No, there is nothing that needs to be addressed.

### Performance check for Step 4b

The probe hashes two files, writes one scratch copy and hashes it, and runs the
harness's `--help`. It adds seconds to a build that already takes seventeen
minutes, and it runs inside the existing `verifyCplx()` parallel rather than
adding a stage. Nothing here grows with the size of the archive or the tree.

No, there is no performance issue that needs to be addressed.

### Unit test coverage check for Step 4b

The 100 percent unit rule targets `src\pdfss\tests\unit`, which belongs to the
consuming project; cplx has no pytest suite and no unit-tested class file, so
there is no percentage to report and no legacy unit test is impacted. The
project default `ghog day` reports that same absence: `ghog check` green, then
`ghog affected --no-cov` at exit 5 on `pytest not found on PATH`. The substituted
gate is `bash src/utils/lint_shell.sh`, green over 44 tracked scripts, plus
`shellcheck` with no finding.

The probe's own script was extracted from its Groovy string and checked with
`bash -n` and `shellcheck` before it was pushed, which is the only lint a script
embedded in a Jenkinsfile gets: the pipeline's shellcheck branch reads the
`tools/*.sh` copies, not the pipeline file.

No, there is no unit-tested class below 100 percent that needs completing.

### Feature integrity for Step 4b

No existing behaviour changed here. The harness is byte-identical to the frozen
copy, its four retained captures still name `fab864ee`, and the plan command for
step 3 was re-run against its capture on this host and reports `OBJECTIVE MET`.

In the pipeline repository the probe was added beside the existing ones rather
than into them: build 131 returned SUCCESS with every other cplx probe reporting
as before, which is the evidence that a new branch in the `verifyCplx()` parallel
disturbed nothing.

No, no feature-integrity evidence is still owed for Step 4b.

## Step 5. Acceptance on the Debian agent

### Analysis of Step 5 implementation state

Yes. Step 5 has been fully implemented.

Build 139 of the pipeline `develop` branch deployed the published archive twice
on the Debian 12 agent and ran the acceptance over both trees: `OBJECTIVE MET`,
42 cases and 0 failures, with the discriminator
`step5/acceptance/fixed-answers-and-control-does-not` reading `yes:no`. The same
instrument run on RHEL 9.8 over two equally fresh deployments REFUSES with five
failures, because the defect cannot fire on the distribution whose libc family
the archive ships. The cplx-side identity check then admitted both blocks, 24
cases and 0 failures.

Code review round 1 refused the first implementation on two counts and both were
right. It copied one already-deployed tree twice where the criterion says two
freshly extracted trees, and it wrote to `/tmp` where the criterion names the
build's own prefix. The trees are now genuine deployments, which the acceptance
MEASURES rather than promises, and the write location is settled by an amended
criterion whose reason is a measurement rather than a preference.

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

Two files in this repository, four in the pipeline one, one probe and one build.

THE STEP FOUND ITS PLAN INCOMPLETE BEFORE IT FOUND ANYTHING ELSE. The plan's
step 5 file list named the four artifacts step 5 CONSUMES and nothing that could
run it, on the reading that the frozen harness would. It cannot: its `--step`
dispatch accepts 0 to 3 and refuses anything else on purpose, and its step 3
suite asserts `rhel 9.8` as its target. Step 4 then froze those bytes and step 4b
published their digest, so step 5 may not extend it either. The acceptance is
therefore a SECOND FILE beside the frozen harness, which it reads and never
writes, and the plan's own list and validation commands were repaired to say so.
That is the same omission step 0's file list carried and step 2 would have
tripped on.

`docs/v0.27.0/verify.wrapper-accept.sh`, the instrument, with two modes because
the step has two halves and neither host can answer the other's:

- `--mode accept` runs on the Debian agent over two freshly deployed trees it is
  handed. It installs the fixed wrapper in one and the retained pre-change
  wrapper in the other, and asserts that the first answers a version and the
  second does not;
- `--mode identity` runs HERE and needs git. It verifies the manifest triple
  against the canonical harness, both wrapper bodies against the commits they
  came from, and the digests a retained capture records against the files this
  repository holds.

`docs/v0.27.0/verify.wrapper.debian.txt`, the retained evidence, carrying three
runs rather than one, because a passing suite says nothing about whether it
would pass anywhere: the Debian acceptance, the RHEL refusal that qualifies it,
and the identity check that admitted both.

IN THE PIPELINE REPOSITORY, landed on `develop` the same way step 4b's were:
`tools/wrapper_accept.verification-only.sh` byte-identical to the instrument,
`tools/wrapper_python.fixed.verification-only.sh` and
`tools/wrapper_python.pre-change.verification-only.sh` byte-identical to the two
wrapper bodies, `tools/wrapper_accept_rsync_shim.verification-only.sh`, and
`wrapperAccept()` in `ci/Jenkinsfile.diagnostics`, called from the
`verifyCplx()` parallel in its own branch. The `.sh` suffix is that repository's
rule for `text eol=lf`, and a copy whose line endings drifted would fail the
digest check it exists to pass; the names differ from the canonical ones and the
digests do not, which is what binds them.

THE PROBE DEPLOYS THE ARCHIVE TWICE, with the same recipe
`ci/provision_toolchain.sh` uses: bootstrap `install_pkg.sh` out of the archive,
hard-link the archive into each throwaway prefix, stand in for the rsync the
image does not ship, and let the installer rewrite every ELF to live under that
prefix. Both deployments cost 253 seconds and 3.3 GB together. The deployments
are made THERE and not in the instrument, by the rule step 3 of the plan already
states: an oracle that deployed its own subject would be measuring an installer
run rather than a wrapper.

Criterion by criterion, with the line that answers it:

- TWO FRESHLY EXTRACTED, ISOLATED TREES IN ONE RUN, and the extraction is
  measured: the installer rewrites every ELF to live under the prefix it deploys
  into, so `step5/fixed/deployed-for-its-own-root` and its control twin assert
  that each tree's interpreter carries ITS OWN root in its run path, and
  `step5/control/tree-deployed-elsewhere-refused` proves the same predicate
  refuses a tree whose ELFs were written for somewhere else, which is exactly
  the shape a copy has. `step5/trees/are-independent` reads `3` because it
  counts distinct inodes across the archive and the two trees;
- THE FIXED TREE: `step5/fixed/answers-a-version` `yes`, version `Python
  3.13.9`, exit 0, `python3` a symlink to `../../bin/python`, `python3_target`
  naming `python3.13_bin`, that file present and asserted an ELF, and no path
  derived from an empty string either in the tree or in the run;
- THE CONTROL TREE: `step5/control/derives-the-empty-path` `yes`, with the
  derived path recorded as `.../control/tools/python/bin/current/bin/_bin` and
  the first helper failure recorded verbatim: `readlink: symbol lookup error:
  .../control/tools/python/root/usr/lib64/libc.so.6: undefined symbol:
  _dl_readonly_area, version GLIBC_PRIVATE`. That is the defect itself, measured
  on the agent;
- THE CONTROL'S PROVENANCE CHECKED BEFORE IT RUNS:
  `step5/control-wrapper/bytes` against commit `a665f4fc` at
  `src/install/env/python/bin/python`, and the fixed body against `c5764088`,
  both before either tree runs, with
  `step5/control/wrong-control-bytes-refused` proving the gate fires;
- THE INDEPENDENT IDENTITY CHECK: `identity/manifest/harness-at-freeze-commit`
  against `233b549d:docs/v0.27.0/verify.wrapper-scope.sh`, its mutated-manifest
  control refusing, and the capture's three recorded digests admitted;
- THIS STEP DID NOT MODIFY THE HARNESS:
  `identity/harness/canonical-file-is-still-frozen` reads `fab864ee`, the value
  the manifest names, so the file a reader runs today is the file step 4 froze;
- THE CAPTURE NAMES ITS RUN AND CITES IT: run identity
  `debian-wrapper-accept-b139-20260902T102546Z`, agent `debian 12`, glibc 2.36,
  commit `c96d5a73`, and `step5/identity/throwaway-carries-run-id` asserts the
  throwaway root carries that identity rather than the header merely stating it;
- EVERY WRITE UNDER ONE THROWAWAY ROOT the probe creates and removes, with the
  archive untouched: four cases place both trees and the scratch under it and
  the archive outside it, and `step5/archive/signature-unchanged` and
  `step5/archive/wrapper-unchanged` say the extracted archive is what the later
  stages will consume.

THE ONE CRITERION THIS STEP CHANGED, and why it is a measurement rather than a
convenience. The criterion said every write lands under the build's own prefix.
In this pipeline that is `$PREFIX`, and the relocation acceptance runs in the
SAME parallel branch set: its step 4 and step 6 suites each begin with
`cp -a "$prefix/." "$work/"`, copying the whole prefix. Two fresh deployments
placed inside it would be copied wholesale by them while this step was still
writing them, and a copy the relocation harness cannot make is an UNANSWERED
criterion it refuses to work around. Honouring the earlier wording would have
broken another requirement's measurement to satisfy a phrase. The plan now
states the requirement as step 3 already stated its own, one throwaway prefix
the step creates and removes, and records that mechanism as the reason.

The first version's stated reason for `/tmp` was that the trees would appear to
the relocation inventory as unrecorded libraries. That mechanism was wrong: the
inventory reports unrecorded entries as a NOTE and already tolerates 193 of
them. The wholesale copy is the real one, and it was found by reading the
relocation harness rather than by reasoning about it.

THREE DEFECTS IN THE INSTRUMENT WERE FOUND BY ITS OWN CONTROLS OR BY ITS OWN
CODE REVIEW, which is the only way this class is ever found:

- the mutated-capture control mutated NOTHING. Its `sed` was anchored at
  `^accept-script-sha256` while a verdict block is indented, so the "mutated"
  copy was byte-identical, the gate accepted it, and the control reported that
  its oracle was not asserted. A decorative gate written into the instrument
  built to refuse decorative gates;
- the capture check then read only one verdict block, and the retained evidence
  carries two. Reading the first would have fixed the symptom and lost the
  check, so every occurrence is collapsed with `sort -u`;
- the check that the capture carries the fresh-deployment evidence was written
  as one `grep -c` expecting three, and the capture's own header names those
  three cases in its prose, so it counted nine and refused a correct capture.
  Raising the number would have kept the defect and hidden it. Each case is now
  asked for by name and matched only where a PASS follows it, so prose cannot
  answer for a measurement.

THE RHEL RUN IS A CONTROL AND NOT A SECOND ACCEPTANCE. Every mechanic passes
there, including both fresh deployments, the copy-refusing control, and the
fixed tree answering `Python 3.13.9`; what does not pass is the control half,
because the pre-change wrapper's `readlink` resolves normally on RHEL and both
trees answer. The discriminator reads `yes:yes` and the suite refuses with five
failures, all and only the ones a host where the defect cannot fire must
produce. Both blocks name the same instrument, `ccea6ea4`, asserted by the
identity check rather than assumed.

EIGHT BUILDS WERE SPENT AND ONE IS EVIDENCE. Build 139 is the retained one.
Build 132 ran the first acceptance green but named a pre-fix instrument and its
artifacts were discarded when a later build superseded them under the one-build
artifact retention; builds 133 to 135 died at SCM checkout on a Jenkins Vault
outage, `No route to host`, which is infrastructure rather than this change, and
build 132 had already failed its own Publish stage the same way after every
probe had run. Build 136 carried the first acceptance and its code review
refused it. Build 137 carried the reworked probe whose archive symlink the
installer could not see, since it discovers its archive with `-type f`. Build
138 carried the working deployments and a capture the identity gate then
miscounted.

### Architecture check for Step 5

This step changes no shipped file. The wrapper and `setenv` are read and never
written, and the acceptance asserts that: the fixed body it installs into its
own tree is the live `src/install/env/python/bin/python` byte for byte, checked
against commit `c5764088` before anything runs.

THE FROZEN HARNESS STAYS FROZEN, which is the structural claim this step had to
make and the reason the instrument is a second file. `verify.wrapper-scope.sh`
is untouched, its digest still `fab864ee`, and the identity check asserts that
against the manifest rather than leaving it to the diff. Its four capture
commands were re-run on this host after the change and all four still report
`OBJECTIVE MET`.

The two new files stay under `docs/v0.27.0/` with the rest of the effort's
evidence and are never packaged. The pipeline change stays inside the boundary
the plan draws: one probe added to `ci/Jenkinsfile.diagnostics`, which that
file's header declares owned by the cplx maintainer, four
`tools/*.verification-only.*` files that are never delivered, and no reviewed
pipeline stage touched.

THE DEPLOYMENT RECIPE SITS IN THE PROBE AND THE ORACLE SITS IN THE INSTRUMENT,
which is the seam step 3 of the plan already drew and the reason this step keeps
it: a harness that deployed its own subject would be measuring an installer run
rather than a wrapper. The instrument is handed two roots and asserts what it
can measure about them, including that they were deployed rather than copied.

The rsync stand-in moved out of the Groovy string into
`tools/wrapper_accept_rsync_shim.verification-only.sh`. A heredoc nested inside a
Groovy string is a shape nobody should have to read, and a file gets `bash -n`
and `shellcheck` where a string inside a Jenkinsfile gets neither. Both were run
over it, and the `A && B || C` form the inline copy uses became an `if` because
shellcheck reports it under SC2015.

The probe reports and never gates, exit 0 like every probe beside it, and it
takes its own branch in the existing parallel rather than adding a stage. It
writes only into a run-keyed throwaway root under the workspace and removes it
before `stageClone()` copies that workspace, so it cannot reach the archive the
later stages consume nor the prefix the relocation suites copy wholesale in the
same parallel.

The DDD-Hexagonal criterion does not apply to a Bash, Batch and Groovy project.

No, there is nothing that needs to be addressed.

### Performance check for Step 5

Nothing here grows with anything. The acceptance is a fixed number of cases over
two trees, and the cost that dominates is measured rather than estimated and
recorded in the capture: the two fresh deployments take 253 seconds and 3.3 GB
together on the agent, and 255 seconds on the RHEL target.

THAT COST BUYS THE CRITERION AND IT IS PAID IN PARALLEL. Deploying is four
minutes against copying's three seconds, which is what the first version chose
and what its code review refused. The branch sits in a stage whose other
branches already run eight to ten minutes, so the stage's wall clock is
unchanged and Jenkins reports the branch's own duration. Build 138 and build 139
both returned SUCCESS inside the pipeline's 60 minute timeout, with the same
duration profile as the builds before this step existed.

The one loop that walks a variable set is `tree_signature`, over the entries of
`bin` and `current/bin`, a dozen names each, sorted once. That is O(n log n) on
n = the entries of two directories, not on the archive: the tree it compares
holds tens of thousands of files and the signature reads two of its directories
by design, because the surgery this step measures touches nowhere else.

The identity mode hashes four files and runs two `git show` calls.

No, there is no performance issue that needs to be addressed.

### Unit test coverage check for Step 5

The 100 percent unit rule targets `src\pdfss\tests\unit`, which belongs to the
consuming project; cplx has no pytest suite and no unit-tested class file, so
there is no percentage to report and no legacy unit test is impacted. The
project default `ghog day` reports that same absence, and did again for this
step: `ghog check` exit 0 with `check.bat not found - skipped`, then
`ghog affected --no-cov` exit 5 on `pytest not found on PATH`.

The substituted gate is `bash src/utils/lint_shell.sh`, clean over 44 tracked
scripts, plus `shellcheck docs/v0.27.0/verify.wrapper-accept.sh` with no
finding, the new instrument being under `docs/` and therefore outside the lint
gate's own scope by that script's stated rule.

On the pipeline side the probe's embedded shell was extracted from its Groovy
string and checked with `bash -n` and `shellcheck`, and the rsync stand-in it
now calls is a file rather than a nested heredoc precisely so both reach it.
Both are clean.

No, there is no unit-tested class below 100 percent that needs completing.

### Feature integrity for Step 5

No shipped behaviour changed, and the runs say so rather than the reasoning.

In this repository the four frozen-harness capture commands were re-run after
the change and report `OBJECTIVE MET` for steps 0, 1, 2 and 3, with the same
digests they carried before. The wrapper, `setenv` and the harness are all
byte-identical to what step 4 committed.

On the agent, build 139 returned SUCCESS with every other cplx probe reporting
as before, which is the evidence that a new branch in the `verifyCplx()`
parallel disturbed nothing. The acceptance asserts the extracted archive is
unchanged, by signature and by wrapper digest, so the archive the Provision,
Package and Test stages consume after it is the archive they would have consumed
without it. The two deployments it makes live outside that prefix and are
removed before `stageClone()` copies the workspace.

THE RELOCATION SUITES ARE THE FEATURE MOST AT RISK HERE, since they walk and
copy the same prefix in the same parallel, and their own retained captures say
they are unchanged: build 139 carries `result: OBJECTIVE_MET` for relocation
steps 0, 1, 2, 3, 4 and 6, read from
`a.evidence/verify-relocation-step<n>.debian.txt` rather than inferred from the
build being green.

On the RHEL target the control run left the live install untouched, asserted the
same way, and both its deployments and its scratch were removed; `df` on that
partition is back where it started.

No, no feature-integrity evidence is still owed for Step 5.
