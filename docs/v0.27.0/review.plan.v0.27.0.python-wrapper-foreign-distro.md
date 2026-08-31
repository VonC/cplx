# Specification review transcript for v0.27.0

- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-08-31T09:11:13+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: request

### Review identity for plan python-wrapper-foreign-distro (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
Review round: 1

### Requestor assessment for plan python-wrapper-foreign-distro (round 1)

Assessment of the v0.27.0 python-wrapper-foreign-distro implementation plan, round 1.

Six open questions are placed, all of them implementation-level, none re-opening
the issue or the design. The design settled the mechanism (decisions W1 to W5);
these questions ask only how the plan executes it: step ordering, control
construction, the harness boundary to CI, the instrument used for measurement,
the fixture shape, and the guard form against the line budget.

Are questions missing? One area is deliberately unasked. The plan's decision P1,
that the harness runs on any host, is a plan decision already recorded with its
reason, and Q05 tests its consequence for the fixture rather than re-opening it.

Are the existing options and answers sufficient? Each question carries three
options with pros and cons, a recommendation with argument, and an acceptance
reason. Q01 is the one whose answer changes the plan's structure rather than
choosing between equivalent mechanisms, and it should be answered first, because
Q02's control design depends on whether a pre-change wrapper copy is retained.

Were reviewer wording suggestions applied? None yet: this is round 1 and no
reviewer answer exists.

THE SUBSTANTIVE FINDING, offered for the reviewer to confirm or refute. Q01 is
not a preference question. Step 2's completion criteria assert "the harness
asserts the mangling in the step 0 baseline", and step 0's criteria capture only
a clean first call over an unplanted fixture. Step 1 rewrites the wrapper before
step 2 runs, so the pre-change mangling cannot be produced at step 2 from the
file under test. As written the plan cannot execute in its own stated order, and
this is a defect rather than an ambiguity.

The reviewer is asked to check that reading specifically, since accepting it
changes step 0's scope.

### Change summary for plan python-wrapper-foreign-distro (round 1)

Document changes since the plan was first written, for round 1.

The plan was committed at 04ccde1 and has changed once since, at 4fa8104, in one
respect: the Debian acceptance stopped being deferred and became a step of this
plan.

- the executable target matrix gained row 4, "acceptance on Debian: the first
  call the defect actually breaks", on the Debian CI agent;
- the section "Step 3 what is OWED and not a criterion of this plan" was replaced
  by a full step 4: files involved, goal, completion criteria, and a narrowed
  "what remains OWED after it";
- step 4's completion criteria require the reverted-fix control in the same run,
  on the ground that without it a pass cannot be told from a pass on a host where
  the defect never fires;
- what remains owed to umbrella item 7 is now only the same first call over the
  archive item 7 rebuilds, which is a different artifact.

The reason for the change is external and factual rather than editorial: CI was
unreachable when the plan was written, and the reading that this requirement had
no Debian host in hand was correct then. CI answered again on 2026-08-30, so the
deferral no longer had a basis.

No other section of the plan changed. Steps 0 to 3 are as first written, which
is why Q01 finds an ordering defect that predates this revision.

### Writer response for plan python-wrapper-foreign-distro (round 1)

Writer response: Writer response for round 1.

No reviewer answer exists yet, so there is nothing accepted or disputed. This
response states what the writer is asking the reviewer to weigh, so the first
answer lands on the right questions rather than on the whole document.

WHAT THE WRITER ASKS THE REVIEWER TO RULE ON, in priority order:

1. Q01, the ordering defect. The writer's reading is that step 2 names a step 0
   artifact that step 0 does not produce, and that step 1 destroys the only file
   from which it could be produced. If the reviewer agrees, step 0 grows to two
   captures and the plan stays single-copy. If the reviewer disagrees, the
   writer needs to know which of the two readings of "the step 0 baseline" was
   intended, because option A2 is the only alternative that keeps the comparison
   and it costs a second wrapper copy.

2. Q02 depends on Q01's answer. If A1 is accepted, the pre-change wrapper is
   captured at step 0 and B2's retained copy may become redundant for the local
   steps while still being required for the Debian agent, which has no cplx
   history. The writer's recommendation of B2 assumes the agent constraint
   dominates.

3. Q03 asks a boundary question the writer cannot settle alone, because the
   answer names work in a repository this requirement does not own. The
   recommendation is the pattern already proven on that agent, with the digest
   promoted from a nicety to a required field. That promotion is a direct
   consequence of drift found on 2026-08-30, when the relocation harness copy in
   the pipeline repository was found to differ from its cplx source in the one
   place that changed what a run meant.

DISAGREEMENT: none recorded. This is the opening round.

A NOTE ON WHAT THIS PLAN IS TRYING NOT TO REPEAT. Umbrella item 2 spent nine
review rounds ending the same way, because it carried criteria it could not
discharge and gated itself on another item's artifact. This plan states its
boundary before the work starts, in both the issue and the plan, and Q01 exists
because the writer went looking for the same class of defect inside this plan
rather than waiting for a build to find it.

### Reviewer focus for plan python-wrapper-foreign-distro (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer

- Recorded: 2026-08-31T09:41:48+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: answer

### Reviewer assessment for plan python-wrapper-foreign-distro round 1

The plan has the right five-step shape and the portable-versus-target split is
sound, but it is not executable in its current order. Step 2 relies on a
pre-change planted-failure capture that Step 0 does not produce, while Step 1
has already replaced the only wrapper under test. Q01 identifies that defect
correctly; A1 must be integrated into Step 0 and the corresponding Step 2
comparison.

The six questions cover the remaining implementation choices, and I agree with
the recommended answers A1, B2, C1, D1, E1, and F1. Four answers need stronger
operational wording before consolidation. A printed digest is evidence, not a
comparison, so B2 and C1 need explicit provenance and equality gates. C1 also
crosses the repository boundary that the plan says it does not own, so the plan
must name the pipeline-side artifact, owner/handoff, and the condition under
which Step 4 may be marked complete.

The current wrapper also corrects one premise in Q04. Every external helper
invocation visible in `src/install/env/python/bin/python` is unqualified; none
uses an absolute executable path. The early `readlink -f` at line 12 is itself
PATH-resolved, however, so a `readlink` shim used for the three guarded sites
must delegate that bootstrap call and fail only the selected later path. The
harness must assert the recorded shim calls rather than infer coverage from
PATH setup.

Finally, F1 is the right shared form, but "a function taking the path and site
label" does not yet guarantee fail-closed behavior. A function invoked through
command substitution runs in a subshell; an `exit` there does not by itself
terminate the wrapper. The plan must specify a checked call contract that
distinguishes nonzero `readlink` status from empty output and makes every caller
exit before any `mv`, `ln`, `cp`, or `sed` mutation.

No seventh design question is needed. These are required integrations and
factual corrections to the selected six answers, not unresolved choices.

### Question verdicts for plan python-wrapper-foreign-distro round 1

- **Q01: A1 confirmed.** Step 0 must capture both the clean first call and a
  selectively planted failing-`readlink` run over the unmodified wrapper. This
  is the only option that supplies the baseline Step 2 already names without
  retaining a second local wrapper copy.
- **Q02: B2 confirmed with provenance strengthened.** Use two isolated extracted
  trees in the same Debian-agent run. Bind the retained control bytes to a named
  pre-change cplx commit/blob and expected SHA-256, verify that equality before
  the control runs, and record it in the capture. Merely printing the copy's
  current digest does not prove that it is the historical wrapper.
- **Q03: C1 confirmed with an explicit cross-repository handoff.** The current
  no-credential constraint rules out C2 and C3 couples unrelated probes. Name
  the pipeline repository path and owner, require the pipeline copy's SHA-256
  to equal the canonical cplx harness SHA-256, and state that Step 4 remains
  owed until that pipeline-side change and its capture exist. C1 is executable
  only through that handoff, not by this repository alone.
- **Q04: D1 confirmed after correcting the premise.** The current wrapper uses
  no absolute executable paths. Use recording PATH shims for every helper whose
  environment is evidence, assert the exact shim calls, and make the
  `readlink` shim delegate the bootstrap `readlink -f` and selectively fail one
  guarded path at a time. The interpreter stub separately records the restored
  `LD_LIBRARY_PATH`.
- **Q05: E1 confirmed.** Steps 0-2 use a shell interpreter stub that records
  arguments and environment; Steps 3-4 use the actual archive interpreter so
  `-m venv` and the third guarded read site execute for real.
- **Q06: F1 confirmed with a checked-call contract.** Use one shared helper and
  keep 115 lines as a review trigger. Specify that the helper detects both a
  nonzero `readlink` result and empty output, emits the helper name, site, and
  path, and returns failure; every assignment must explicitly propagate that
  failure to wrapper termination before mutation.

### Requested changes for plan python-wrapper-foreign-distro round 1

Requested changes: Six changes are required before consolidation.

1. Integrate A1 into Step 0: capture the clean and selectively failing-helper
   pre-change runs, retain their evidence, and make Step 2 consume that actual
   baseline.
2. Strengthen B2 so the retained control wrapper is mechanically tied to a
   named pre-change commit/blob and expected SHA-256, verified before use, and
   run in a separate extracted tree from the fixed wrapper.
3. Strengthen C1 with the exact pipeline-side file, responsible handoff, a
   canonical-versus-copy SHA-256 equality gate, and a Step 4 completion boundary
   that does not claim an unlanded external-repository change.
4. Correct Q04's claim about absolute-path tools. All current helper commands
   are PATH-resolved. Require asserted per-helper shim evidence, including a
   selective `readlink` shim that delegates the line-12 bootstrap call.
5. Carry E1 into the step text: define the recording shell-stub contract for
   Steps 0-2 and require the real archive interpreter for Steps 3-4.
6. Define F1's failure-propagation contract. Both nonzero and empty `readlink`
   results must make the outer wrapper exit explicitly before any mutation;
   failure inside command substitution alone is insufficient.

### Writer instructions for plan python-wrapper-foreign-distro round 1

Revise `docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md` and publish
round 2. Do not consolidate yet. Keep the six selected answers A1, B2, C1, D1,
E1, and F1; no new open question is required.

1. Update Step 0's goal and completion criteria to run the unmodified wrapper
   twice: once clean and once with a path-selective failing `readlink` shim.
   Record the pre-change mangling and the exact injected call. Update Step 2 to
   compare its fail-closed result with that recorded artifact.
2. In Step 4, specify two freshly extracted and isolated trees. Define the
   retained pre-change wrapper's repository path, source commit/blob identity,
   expected SHA-256, pre-run equality check, and captured digest.
3. Resolve the repository-ownership contradiction around C1. Name the pipeline
   verification-only path and the handoff/owner that lands it. Add a mechanical
   equality check against the canonical harness digest and say plainly that the
   cplx change alone cannot complete Step 4.
4. Rewrite D1's con and answer to match the source: helper executables are not
   absolute-path invocations. Define the shim call log and its assertions. For
   `readlink`, distinguish the bootstrap `-f` call from the three guarded reads
   and inject failure by selected path/site so setup still succeeds.
5. State the E1 fixture contracts in Steps 0-2 and Steps 3-4, including what the
   stub records and why the real archive interpreter is required for the venv
   branch.
6. Define the F1 helper signature and caller form. Require explicit propagation
   from a failed or empty `readlink` result to outer-wrapper exit, and assert in
   the harness that no mutating helper ran after each of the three injected
   failures.
7. Reconcile the affected file lists, target matrix, completion criteria, line
   budget note, and validation-plan skeleton with these changes so the next
   review can trace every promise to one executable check.

### Final reviewer decision for plan python-wrapper-foreign-distro round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by human - escalation

- Recorded: 2026-08-31T09:50:14+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: escalation

wait timed out while request was absent

<!-- review-entry-id: escalation-round-2 -->

## Round 2 by human - human-reclaim

- Recorded: 2026-08-31T10:00:01+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: human-reclaim

The human explicitly determined that the recorded escalation was only a stopped
handoff caused by the reviewer's arbitrarily short 300-second wait, not a
workflow failure. Resume the intact round 2 in place, preserve all request,
answer, and transcript content, reset the lease, and return ownership to the
actor named by the existing artifact shape.

<!-- review-entry-id: human-reclaim-round-2 -->

## Round 2 by requestor

- Recorded: 2026-08-31T10:10:14+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: request

### Review identity for plan python-wrapper-foreign-distro (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
Review round: 2

### Requestor assessment for plan python-wrapper-foreign-distro (round 2)

Assessment of the v0.27.0 python-wrapper-foreign-distro implementation plan, round 2.

All six round-1 answers stand as selected: A1, B2, C1, D1, E1, F1. No answer was
reversed, and no seventh question was needed, which matches the reviewer's
reading that round 1 raised required integrations rather than unresolved choices.

Are questions missing? No new question is raised. Each of the six requested
changes was an instruction to make a selected answer operational, and each has
been written into the plan text rather than left in the answer prose. A question
whose answer is already binding does not need re-asking.

Are the existing options and answers sufficient? Yes, with one correction
applied to Q04's own premise, described below. The remaining five answers needed
stronger wording rather than different content.

Were reviewer wording suggestions applied? All seven writer instructions were
applied, and the seventh, the reconciliation pass, reached the target matrix, the
scope anchors, the confirmed-facts list, the decision table, the line budget note
and the validation plan skeleton.

THE FACTUAL CORRECTION, verified rather than accepted on trust. The reviewer
stated that every helper invocation in the wrapper is PATH-resolved and none uses
an absolute executable path, contradicting the con this writer wrote under Q04
option D1. That claim was checked against
`src/install/env/python/bin/python` before being adopted: `readlink`, `mv`, `ln`,
`cp`, `sed` and `grep` are all unqualified at every call site, and the only
absolute-path invocations are the interpreter at lines 60 and 62, which is not a
helper. The reviewer is right and the round-1 con was wrong. Both the question
and the plan's confirmed-facts list now carry the corrected reading, and the
sharper constraint the reviewer identified in its place, that the line-12
bootstrap `readlink -f` must be delegated rather than failed, is now a named plan
decision.

WHAT CHANGED IN SUBSTANCE RATHER THAN WORDING. Three of the six changes altered
what the plan will actually cause to be built:

- step 0 now runs the pre-change wrapper twice and retains it, so step 2 has a
  real baseline instead of a named one;
- step 4 now checks the control's provenance against a commit, blob and expected
  digest before running it, rather than printing whatever digest it finds;
- the guard is now a checked-call contract rather than a shared function, because
  a function called through command substitution cannot terminate the wrapper
  from inside its subshell.

That third point is the one this writer would flag for particular attention: it
is a correctness defect that would have produced a guard passing its own review
while leaving the original failure mode intact.

### Change summary for plan python-wrapper-foreign-distro (round 2)

Document changes since round 1, for round 2.

Every one of the seven round-1 writer instructions was applied to
`docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md`, and instruction 7
reached the companion validation plan as well.

NEW SECTIONS, none of which existed in round 1:

- "The recording shim contract": the shim call log, its fields, the rule that
  expected calls are asserted PRESENT before anything is concluded from absence,
  and the `readlink` shim's delegation of the line-12 bootstrap call with failure
  injected by selected path, one guarded site at a time;
- "The fixture contract": a table binding steps 0 to 2 to the recording shell
  stub and steps 3 and 4 to the real archive interpreter, with the reason stated
  as the venv branch rather than as preference;
- "The checked-call contract for the guards": the subshell hazard named
  explicitly, the `guarded_readlink SITE PATH` signature, the requirement that
  every caller propagates failure to outer-wrapper exit, and the harness
  assertion that no mutating helper appears in the call log after each injected
  failure;
- "The cross-repository handoff for step 4": the canonical harness path, the
  pipeline-side copy and probe, the SHA-256 equality gate, the named owner of the
  landing, and the plain statement that the cplx change alone cannot complete
  step 4.

CHANGED SECTIONS:

- confirmed technical facts gained two corrected entries: every helper is
  PATH-resolved and none is absolute, and the line-12 bootstrap must be
  delegated. The first reverses a claim this writer made in round 1;
- step 0 goal and criteria now specify RUN A clean and RUN B planted, retention
  of the pre-change wrapper with its digest, and a control that fails the suite
  when the injected failure did not appear at the intended site;
- step 1 criteria now assert the shim log shows expected calls present, so a
  helper that never ran cannot pass by absence, and require the stub to
  distinguish an empty saved value from an unset one;
- step 2 criteria now compare against step 0 RUN B by name, fail when that
  artifact is absent rather than skipping, and inject each of the three sites
  separately;
- step 3 criteria now require the real archive interpreter so the third guarded
  site executes;
- step 4 criteria now require two isolated extracted trees, checked control
  provenance, and the harness copy equality gate;
- "Step 4 what remains OWED after it" now lists two owed items with owners, the
  pipeline-side change and the item 7 rebuild, where round 1 listed only the
  second;
- the scope anchors, target matrix, decision table (P5 to P8 are new) and line
  budget note were reconciled with all of the above;
- Q04's con and answer in the open-questions section were rewritten to match the
  source.

VALIDATION PLAN: "four steps" became "five steps", the owed section was rewritten
to name the two remaining obligations, step 3's goal lost its stale deferral, and
a step 4 section was added in the skeleton shape. Its first line remains
"No, it is not implemented."

No implementation has started. Every change in this round is specification.

### Human guidance and writer response for plan python-wrapper-foreign-distro (round 2)

Human guidance:

The human explicitly determined that the recorded escalation was only a stopped
handoff caused by the reviewer's arbitrarily short 300-second wait, not a
workflow failure. Resume the intact round 2 in place, preserve all request,
answer, and transcript content, reset the lease, and return ownership to the
actor named by the existing artifact shape.

Writer response: Writer response for round 2.

ACCEPTED IN FULL. All six requested changes and all seven writer instructions
were applied. No recommendation was rejected, and no disagreement is recorded.

On each requested change, what was done and where:

1. A1 integrated into step 0. Step 0 now specifies RUN A and RUN B over the
   unmodified wrapper, records the pre-change mangling and the exact injected
   call from the shim log, and retains the pre-change wrapper with its digest.
   Step 2 consumes that artifact by name and FAILS when it is absent, rather
   than skipping the comparison. A skipped comparison would have been the same
   fail-open shape the criterion exists to prevent.

2. B2 strengthened. Step 4 binds the retained control to a named cplx commit and
   blob with an expected SHA-256, verifies that equality BEFORE the control runs,
   and records it. The plan now says plainly that a digest of whatever is on disk
   proves only that a file was read. Two freshly extracted isolated trees, so the
   mangled run cannot contaminate the passing one.

3. C1 strengthened and the ownership contradiction resolved. A dedicated section
   names the canonical harness, the pipeline-side copy and probe, the SHA-256
   equality gate that fails on difference, and the owner of the landing. The
   scope anchors now list that artifact as NAMED HERE, NOT OWNED HERE, and both
   the target matrix and the owed section state that step 4 cannot be completed
   by this repository alone.

4. Q04's premise corrected, after checking it. The reviewer's claim was verified
   against the source before adoption: all six helpers are unqualified at every
   call site and only the interpreter is absolute. The round-1 con was wrong and
   is replaced, in both the question and the plan's confirmed-facts list, by the
   real constraint: the line-12 bootstrap `readlink -f` must be delegated and
   failure injected by selected path. Decision P6 records that rule.

5. E1 carried into the step text. A fixture contract table binds steps 0 to 2 to
   the recording stub and steps 3 and 4 to the real archive interpreter, and the
   reason is stated as the venv branch executing the third guarded site, not as
   preference.

6. F1's failure-propagation contract defined. This is the change with the most
   consequence and the writer wants it on the record: the reviewer identified
   that a shared helper invoked through command substitution runs in a subshell,
   where an `exit` terminates only the subshell and leaves the wrapper running
   with an empty value. That is the original defect wearing a guard. The plan now
   carries the `guarded_readlink SITE PATH` signature, the checked-call caller
   form, the requirement that failure reaches outer-wrapper exit, and a harness
   assertion that no `mv`, `ln`, `cp` or `sed` follows each injected failure in
   the call log. The assertion is what proves propagation, rather than the
   presence of the word `exit` in the source.

7. Reconciliation done across the scope anchors, confirmed facts, target matrix,
   all five steps, the decision table (P5 to P8 added), the line budget note and
   the validation plan skeleton.

DISAGREEMENT: none.

ONE OBSERVATION OFFERED FOR THE NEXT ROUND, not a dispute. Three of the six
changes share a single shape: a check that would have reported success without
the thing it names having happened. A comparison against a baseline nobody took,
a digest that proves a file was read rather than that it is the right file, and
a guard that exits a subshell rather than the wrapper. That is the defect class
this umbrella exists to close, appearing inside the plan meant to close one
instance of it. The writer has stated it here so the next review can check
whether any remaining criterion still has that shape, rather than treating the
three as unrelated fixes.

### Reviewer focus for plan python-wrapper-foreign-distro (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-08-31T10:19:13+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: answer

### Reviewer assessment for plan python-wrapper-foreign-distro round 2

Round 2 correctly applies the baseline ordering, two-tree Debian control,
recording-shim, fixture, and checked-call corrections. The six selected answers
A1, B2, C1, D1, E1, and F1 still stand. The outer-wrapper propagation form is
now explicit and the validation skeleton has the required fifth step.

The plan is not yet internally executable. Its cross-repository section says it
names the pipeline-side copy, probe, and owner, but lines 154-163 provide no
repository-relative path for either file and identify the owner only as
"whoever holds the pipeline repository". Step 4 then says those files were
"named above". More importantly, the Debian agent has no cplx access, so it
cannot obtain the authoritative canonical SHA merely because the capture is
required to print it. Comparing a copied harness with an expected digest copied
beside it is not rooted in the current canonical file unless the handoff and
acceptance checks say how that authority is established.

One implementation question is therefore missing: how the canonical harness
identity crosses the repository boundary. The recommended answer is a committed
handoff manifest generated from the final cplx harness, carrying the cplx commit
and SHA-256. The pipeline probe verifies its local copy against that manifest,
and Step 4 acceptance independently verifies that the manifest identity matches
the canonical cplx file before accepting the retained capture. This preserves
the no-credential boundary while making the equality gate authoritative.

Two internal consistency defects also remain. First, Q01-Q03, Q05, and Q06 still
describe their original gaps as current facts, and Q02/Q03 still claim that a
printed digest prevents drift and that C1 can be executed by this repository
alone. Those claims contradict the newly strengthened plan body. Second, Step
1 says every helper invocation must observe no `LD_LIBRARY_PATH`, but the
line-12 bootstrap helper runs before `setenv`; the design's scope is the fourteen
post-source helpers. The assertion must exclude the bootstrap call from the
unset claim while still logging and delegating it.

Finally, the pipeline change is a prerequisite to Step 4, not something that
can remain owed after Step 4 completes. Separate that prerequisite from the
post-Step-4 item-7 rebuild in both the plan and validation skeleton.

### Question verdicts for plan python-wrapper-foreign-distro round 2

- **Q01: A1 confirmed.** The body now captures both pre-change runs. Rewrite the
  question and answer so they record that applied decision rather than claiming
  Step 0 still omits RUN B; also remove the obsolete single-copy rationale,
  because B2 deliberately adds a retained pre-change copy for Step 4.
- **Q02: B2 confirmed.** Two isolated trees and checked commit/blob/digest
  provenance are correct. Update the option and answer: printing a digest alone
  does not make the copy historical or make a mismatch fail.
- **Q03: C1 confirmed, but incomplete.** The no-credential copy is still the
  viable transport. Name the exact pipeline copy, probe, and capture paths and a
  concrete handoff owner/workflow; C1 cannot be described as executable by cplx
  alone.
- **Q04: D1 confirmed.** The selective `readlink` shim is correct. Restrict the
  no-`LD_LIBRARY_PATH` oracle to the fourteen post-source helper calls; line 12
  is logged and delegated but is outside the scope established by `setenv`.
- **Q05: E1 confirmed.** The fixture table settles it; rewrite the question's
  present-tense claim that the plan does not specify the fixture split.
- **Q06: F1 confirmed.** The checked-call contract settles it; rewrite the
  question's present-tense claim that the shared form is unspecified.
- **Q07, canonical identity transport: add G2.** G1 is an expected digest literal
  edited beside the pipeline copy, which is simple but can drift together with
  that copy; G2 is a committed handoff manifest generated from the final cplx
  harness, carrying cplx commit and SHA-256, verified by the pipeline probe and
  independently matched back to the canonical cplx file by Step 4 acceptance;
  G3 only prints both digests for human comparison. Recommend G2 because it is
  the only no-credential option that makes both sides of the equality gate
  authoritative and fail-closed.

### Requested changes for plan python-wrapper-foreign-distro round 2

Requested changes: Five changes are required.

1. Add Q07 on canonical harness identity transport, with G2 recommended: a
   generated handoff manifest carrying cplx commit and SHA-256, verified on the
   pipeline side and matched independently to the canonical cplx harness before
   Step 4 evidence is accepted.
2. Name the exact pipeline repository-relative harness-copy, probe, manifest,
   and capture paths plus the concrete handoff owner/workflow. Replace every
   claim that these are already "named above" until they actually are.
3. Reconcile Q01-Q03, Q05, and Q06 with the body. Their descriptions and answers
   must record the applied decisions and must not repeat the rejected
   printed-digest or cplx-can-execute-alone claims.
4. Scope the unset-environment assertion to the fourteen post-source helpers.
   Continue to log and delegate line 12, but do not require that pre-source call
   to observe an unset caller environment.
5. Move the pipeline-side change out of "what remains owed after Step 4" and
   describe it as Step 4's prerequisite. Leave only the rebuilt-archive run as
   an obligation after Step 4, and make the same correction in the validation
   skeleton.

### Writer instructions for plan python-wrapper-foreign-distro round 2

Revise the plan and validation skeleton, then publish round 3. Do not
consolidate. Keep A1, B2, C1, D1, E1, and F1 selected.

1. Add Q07 with three materially distinct options for transferring authoritative
   canonical identity to a credential-less pipeline agent. Recommend G2, the
   generated commit-and-SHA handoff manifest with verification on both sides.
2. Under the cross-repository handoff and Step 4 file list, supply exact
   repository-relative paths for the pipeline harness copy, probe, identity
   manifest, and retained capture. Name the responsible handoff workflow or
   actor, not "whoever holds" the repository.
3. Define when and from what final cplx bytes the manifest is generated, how the
   pipeline probe fails when its local copy differs, and how Step 4 acceptance
   proves the manifest's commit/SHA still identifies the canonical cplx harness.
4. Rewrite the open-question descriptions, recommendations, and answers that
   still speak about pre-round-2 gaps. Preserve the option history, but make the
   selected answers agree with the operational body.
5. Change the recording-shim and Step 1 wording from "every helper" to every
   post-source helper covered by the design. Treat bootstrap `readlink -f` as a
   separately asserted delegated setup call whose inherited caller environment
   is not part of the scope oracle.
6. Split Step 4 prerequisites from later obligations in both documents. The
   pipeline landing and capture gate Step 4 completion; only the item-7 rebuilt
   archive run remains owed after Step 4.
7. Extend the validation Step 4 goal enough to name the pipeline identity gate
   and the two isolated trees, so implementation-check does not have to recover
   those completion conditions from the plan prose alone.

### Final reviewer decision for plan python-wrapper-foreign-distro round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-08-31T10:26:32+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: request

### Review identity for plan python-wrapper-foreign-distro (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
Review round: 3

### Requestor assessment for plan python-wrapper-foreign-distro (round 3)

Assessment of the v0.27.0 python-wrapper-foreign-distro implementation plan, round 3.

Seven questions are now placed. Q01 to Q06 keep their round-1 selections, A1, B2,
C1, D1, E1 and F1, and Q07 is new, on how authoritative canonical identity
crosses the repository boundary to a credential-less agent. Its recommended
answer is G2, the generated handoff manifest verified on both sides.

Are questions missing? Round 2 identified the one that was, and it is now asked.
No further question is raised: the remaining four changes were reconciliations
between the questions and a body that had already moved past them, not open
choices.

Are the existing options and answers sufficient? Yes, and this round fixed the
reason they were not. Q01 to Q03, Q05 and Q06 still described their original
gaps as present-tense facts while the body had already closed them, and two
carried claims the body now contradicts: that a printed digest prevents drift,
and that C1 is executable by this repository alone. Each question now records the
APPLIED decision, keeps its option history, and states the correction where its
round-1 reasoning was wrong. Q01's single-copy rationale is explicitly withdrawn,
since B2 deliberately adds a retained copy.

Were reviewer wording suggestions applied? All seven writer instructions were
applied, including the seventh, which extended the validation step 4 goal so an
implementation check can read the completion conditions directly instead of
recovering them from plan prose.

THE FACTUAL CORRECTION, verified rather than accepted on trust. The reviewer
stated that the line-12 bootstrap `readlink -f` runs before `setenv` and is
therefore outside the scope oracle. Checked against the source: line 12 precedes
line 18's `source`, and the design already records that the bootstrap call runs
before the export exists and must not be changed. The round-2 criterion, "every
helper invocation observing NO LD_LIBRARY_PATH", was wrong in a way that would
have FAILED A LEGITIMATE RUN whose caller had exported the variable, since that
call inherits the caller's environment and nothing this requirement controls has
touched it. The oracle is now scoped to the fourteen post-source helpers, with
the bootstrap asserted separately as a delegated setup call carrying no
environment claim. Decision P9 records it.

WHAT THE WRITER ASKS THE REVIEWER TO WEIGH IN THIS ROUND. Q07's option G1, an
expected digest maintained beside the pipeline copy, was rejected on the ground
that the copy and its expected digest live in the same repository and move in
the same commit, so the gate can never go red. That is the same reasoning that
retired the printed digest in round 2, applied one level up. If the reviewer
sees a way G1 could fail honestly, the writer would rather hear it now than
build a manifest that turns out to be unnecessary machinery.

### Change summary for plan python-wrapper-foreign-distro (round 3)

Document changes since round 2, for round 3.

All seven round-2 writer instructions were applied to the plan, and instructions
6 and 7 also reached the validation skeleton.

THE NEW QUESTION:

- Q07, "how the canonical harness identity crosses the repository boundary", with
  three materially distinct options: G1 an expected digest literal beside the
  pipeline copy, G2 a generated handoff manifest carrying the cplx commit and
  SHA-256 verified on both sides, G3 printing both digests for a human. G2 is
  recommended, on the ground that G1 cannot go red because copy and expected
  digest move together, and G3 is not a gate at all.

EXACT PATHS AND A NAMED OWNER, replacing the round-2 prose that said these were
"named above" when they were not. The cross-repository handoff section now
carries a six-row table: the canonical harness and the identity manifest in this
repository, the harness copy, manifest copy, `wrapperScope()` probe and retained
capture on the pipeline side, each at a repository-relative path. The owner is
named concretely: `ci/Jenkinsfile.diagnostics` is the cplx maintainer's by its own
header, so the handoff is the same commit-and-push flow that already lands cplx
probes there, not an unidentified third party.

THE MANIFEST CONTRACT, new: generated from the FINAL canonical harness bytes,
carrying commit and SHA-256; the pipeline probe fails when its local copy differs
from its manifest copy; step 4 acceptance independently verifies the manifest's
commit and digest still identify the canonical harness before accepting the
capture. Neither check alone suffices and one careless edit cannot satisfy both.

THE SCOPE ORACLE NARROWED. The recording shim contract and step 1 now say
POST-SOURCE helpers rather than every helper. A new paragraph states that line
12's bootstrap runs before `setenv`, is logged and delegated, and carries no
environment claim, with the reason: requiring it to observe an unset variable
would fail a legitimate run whose caller exported one. Step 1 gained a separate
criterion asserting the bootstrap call present and delegated.

PREREQUISITE SPLIT FROM OBLIGATION. The pipeline landing moved out of "what
remains owed after step 4" into its own subsection in front of step 4, and out of
the scope-anchor wording that called it an obligation. The owed section now
carries one item, the item-7 rebuilt-archive run, and says plainly why the move
happened: listing the same work in both places let it read as optional. The
target matrix note changed from "depends on a change this repository cannot make"
to a prerequisite statement.

QUESTIONS RECONCILED WITH THE BODY. Q01 to Q06 now open with what was APPLIED,
keep their options as history, and correct three round-1 claims: Q01's
single-copy rationale is withdrawn, Q02 no longer suggests a printed digest
suffices, and Q03 no longer claims C1 is executable by this repository alone.
Q04 additionally records the post-source scoping correction.

DECISION TABLE: P9, the scope oracle covering post-source helpers only, and P10,
canonical identity transport by generated manifest checked on both sides.

VALIDATION SKELETON: the owed section became a prerequisite-and-obligation pair
rather than two owed items, and the step 4 goal now names the two isolated trees,
the control provenance check, both halves of the identity gate, and the
prerequisite, so an implementation check reads them directly.

No implementation has started. Every change in this round is specification.

### Writer response for plan python-wrapper-foreign-distro (round 3)

Writer response: Writer response for round 3.

ACCEPTED IN FULL. All five requested changes and all seven writer instructions
were applied. No recommendation was rejected, and no disagreement is recorded.

On each requested change:

1. Q07 added, with G1, G2 and G3 as materially distinct transports, and G2
   recommended: a manifest generated from the final canonical harness bytes,
   carrying the cplx commit and SHA-256, verified by the pipeline probe against
   its local copy and independently matched back to the canonical file by step 4
   acceptance. The argument against G1 is the one the reviewer used against the
   printed digest, one level up: an expected digest maintained beside the
   artifact it describes is restated by the same edit that changes the artifact,
   so the gate can never fail.

2. Exact paths supplied, in a table naming all six artifacts, and the owner named
   concretely rather than as a role. `ci/Jenkinsfile.diagnostics` is owned by the
   cplx maintainer by its own file header, which states that probes may be added
   or removed there without touching the pipeline's reviewed stages, so the
   handoff is the same commit-and-push flow that already lands cplx probes on
   that repository. Every "named above" claim now has something behind it.

3. Manifest generation, failure and acceptance defined: generated from the FINAL
   harness bytes rather than an intermediate; the probe fails when its local copy
   differs from its manifest copy; acceptance verifies the manifest's commit and
   digest still identify the canonical harness before the capture is accepted.
   The plan states that neither check alone is sufficient, which is the point of
   splitting them.

4. Open questions reconciled with the body. Each of Q01 to Q06 now records the
   applied decision, preserves its options as history, and corrects the specific
   round-1 claim that the body had overtaken. Three corrections are explicit
   rather than silent: Q01's single-copy rationale withdrawn, Q02's printed
   digest replaced by a verified pre-run gate, Q03's "executable by this
   repository alone" replaced by a prerequisite with an owner.

5. Scope oracle narrowed to the fourteen post-source helpers, with line 12
   asserted separately as a logged and delegated setup call carrying no
   environment claim. The reviewer's reading was verified against the source
   before adoption: line 12 precedes line 18's `source`, and the design already
   records that the bootstrap runs before the export exists. The round-2
   criterion would have failed a legitimate run whose caller exported
   `LD_LIBRARY_PATH`, which is a caller's business and not this wrapper's.

6. Prerequisite split from obligation, in both documents. The pipeline landing
   now appears only in front of step 4; the owed section carries one item, the
   item-7 rebuilt-archive run. The plan says why: listing the same work in both
   places let it read as optional.

7. Validation step 4 goal extended to name the two isolated trees, the control
   provenance check, both halves of the identity gate and the prerequisite, so an
   implementation check does not recover completion conditions from prose.

DISAGREEMENT: none.

CONTINUING THE OBSERVATION FROM ROUND 2, which this round strengthens rather
than closes. Round 2 noted that three of its fixes shared one shape: a check that
reports success without the thing it names having happened. Round 3's Q07 is a
fourth instance of the same shape, found one level up from where round 2 fixed
it. The printed digest was retired for the control wrapper, and the identical
weakness reappeared in the expected digest guarding the harness copy. That
recurrence is the argument for G2 rather than a coincidence: each time this
umbrella removes an unfailable check, the next one is found at the boundary just
outside the last fix. The writer expects the remaining candidates to sit at the
edges of the manifest itself, and would welcome the reviewer looking there.

### Reviewer focus for plan python-wrapper-foreign-distro (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-08-31T10:34:02+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: answer

### Reviewer assessment for plan python-wrapper-foreign-distro round 3

Round 3 resolves every round-2 inconsistency and the seven current selections
A1, B2, C1, D1, E1, F1, and G2 are directionally correct. The exact paths,
post-source scope oracle, question reconciliation, and prerequisite-versus-owed
split now agree with the source and design.

The new manifest contract nevertheless creates a circular implementation order.
The Step 4 file list creates `verify.wrapper-scope.manifest.txt` from the final
harness, while Step 4's prerequisite says Step 4 cannot start until that
manifest has already been copied to the pipeline, landed, and used by a build.
The step therefore requires one of its own outputs before it may begin.

The manifest's commit field has a second cycle. A Git commit ID depends on every
file in its tree, including the manifest. A manifest cannot embed the ID of the
same commit that contains it. It must either identify an earlier commit that
already froze the final harness, omit the enclosing commit identity, or be
written in a later commit. The plan currently specifies none of those boundaries.

One more implementation question is missing: where the harness-freeze,
manifest-generation, cross-repository handoff, and Debian-acceptance boundaries
sit in the step and commit sequence. Recommend a separate preparation step:
freeze and commit the final harness first; generate a manifest in a following
cplx commit that names that earlier harness commit/blob and SHA-256; land the
pipeline copies and obtain the build; then perform Debian acceptance in the
following step. This makes every prerequisite exist before its consumer starts
and avoids self-referential commit identity.

Q07 also overstates G1. A digest literal beside the copy can go red when only
the copy drifts, which is exactly the accidental-drift case already observed.
Its weakness is that a joint copy-plus-literal edit can restate both sides, not
that the gate can never fail. G2 remains preferable because of the independent
cplx-side acceptance check, but that external check is the authority; the
manifest file format alone does not create it.

### Question verdicts for plan python-wrapper-foreign-distro round 3

- **Q01: A1 confirmed.** The applied two-run baseline is executable and now
  described consistently.
- **Q02: B2 confirmed.** The existing source commit/blob can authoritatively
  identify the pre-change wrapper without self-reference because that source
  already exists before the retained copy is added.
- **Q03: C1 confirmed.** The named copy-and-probe handoff is the viable
  credential-less transport.
- **Q04: D1 confirmed.** The fourteen post-source calls and separately delegated
  bootstrap call now form the correct scope oracle.
- **Q05: E1 confirmed.** The portable stub and target interpreter split covers
  both observability and real venv behavior.
- **Q06: F1 confirmed.** The checked caller form and mutation-log assertions
  make the shared guard fail closed in the outer wrapper.
- **Q07: G2 confirmed after correcting G1's comparison.** G1 can fail when the
  copy changes without its literal; it is weak because both can be restated in
  one pipeline edit. G2 is stronger only when its manifest is independently
  checked against cplx. Preserve that distinction and remove every "can never go
  red" claim.
- **Q08, sequencing the authoritative identity: add H2.** H1 drops the cplx
  commit field and verifies only the final harness SHA against the current cplx
  checkout; H2 freezes and commits the final harness first, generates the
  manifest in a later cplx commit naming that prior commit/blob and SHA, performs
  the pipeline handoff/build, then accepts the capture in a following step; H3
  tries to generate a manifest naming the commit that contains it. Recommend H2:
  H1 loses durable commit provenance, while H3 is impossible because changing
  the manifest changes the commit ID it tries to embed.

### Requested changes for plan python-wrapper-foreign-distro round 3

Requested changes: Four changes are required.

1. Add Q08 on the step and commit sequence for authoritative identity, with H2
   recommended: commit the final harness first, create the manifest later naming
   that earlier commit/blob/SHA, complete the pipeline handoff and build, then
   perform Debian acceptance.
2. Remove the circular Step 4 prerequisite. The step that generates the manifest
   cannot require the manifest and resulting build before it starts. Split
   preparation/handoff from Debian acceptance and mirror the new step count and
   goals in the validation skeleton.
3. State explicitly that the manifest's cplx commit is the earlier commit that
   froze the final harness, not the commit containing the manifest. Include the
   blob/path and SHA checks that prove the earlier commit contains those bytes.
4. Correct Q07's G1 analysis throughout: a local digest literal catches copy-only
   drift but can be jointly restated. Attribute G2's stronger authority to the
   independent cplx-side comparison, not to the mere existence of a manifest.

### Writer instructions for plan python-wrapper-foreign-distro round 3

Revise the plan and validation skeleton, then publish round 4. Do not
consolidate. Keep A1, B2, C1, D1, E1, F1, and G2 selected.

1. Add Q08 with H1, H2, and H3 as described in the verdicts, recommending H2.
   Make the impossibility of a commit embedding its own ID explicit.
2. Introduce a separate preparation/handoff step before Debian acceptance. Its
   input is a committed final canonical harness; its outputs are the later cplx
   manifest, the pipeline copies/probe, and a completed build capture.
3. Move Debian acceptance to the following step. It consumes those already
   existing artifacts, verifies the pipeline copy against the manifest and the
   manifest against the earlier harness commit/blob/SHA, and retains the accepted
   capture. It must not update the supposedly final harness.
4. Update the target matrix, file lists, prerequisite prose, implementation
   decisions, numbered-step references, and validation skeleton to the resulting
   step count and order.
5. Rewrite G1's con, Q07's recommendation, and every matching body claim to say
   that same-repository expected data catches an unpaired edit but cannot prevent
   a paired restatement. Keep G2's independent cplx-side comparison as the reason
   for preferring it.

### Final reviewer decision for plan python-wrapper-foreign-distro round 3

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-08-31T10:41:19+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: request

### Review identity for plan python-wrapper-foreign-distro (round 4)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
Review round: 4

### Requestor assessment for plan python-wrapper-foreign-distro (round 4)

Assessment of the v0.27.0 python-wrapper-foreign-distro implementation plan, round 4.

Eight questions are now placed. Q01 to Q07 keep their selections, A1, B2, C1, D1,
E1, F1 and G2, and Q08 is new, on where the freeze, manifest, handoff and
acceptance boundaries sit. Its recommended answer is H2, the four ordered
boundaries.

Are questions missing? Round 3 identified the one that was, and it is now asked.
Q08 exists because Q07's answer introduced an ordering the plan had not settled,
which is the honest reason: the manifest was the right mechanism and the plan
then failed to say when it comes into being relative to what consumes it.

Are the existing options and answers sufficient? Yes, after one correction that
this writer got wrong and the reviewer caught.

THE CORRECTION, and it is this writer's error rather than a wording nicety. Round
3 argued for G2 on the ground that G1 "can never go red". That is false. A digest
literal maintained beside the pipeline copy DOES fail when only the copy is
edited, which is precisely the accidental drift the relocation harness suffered
and the case most likely to occur. G1's real limit is narrower: a PAIRED edit in
one pipeline commit restates both sides together. The overstatement mattered
because it credited the wrong thing with the authority. A manifest file sitting
beside the copy would have exactly G1's property; what makes G2 stronger is the
INDEPENDENT CPLX-SIDE COMPARISON at acceptance, in a repository the pipeline edit
cannot reach. Every "can never go red" claim has been removed from the question
and the body, and the authority is now attributed to the acceptance check rather
than to the existence of a manifest.

TWO STRUCTURAL DEFECTS FIXED, both verified before being accepted:

- THE CIRCULARITY. The round-3 step 4 listed the manifest as its own output while
  its prerequisite required that manifest to be already copied, landed and used
  by a build before the step could start. Confirmed by reading the two lines
  against each other. A step cannot consume what it produces, so preparation is
  now step 4 and Debian acceptance is step 5.
- THE SELF-REFERENCE. A manifest cannot name the commit that contains it. Checked
  rather than assumed: a commit identity is computed over its tree, and the tree
  contains the manifest, so writing the id into the manifest changes the tree and
  therefore the id. This is impossible, not merely inconvenient, and the plan now
  says the manifest names the EARLIER commit that froze the harness.

WHAT THE WRITER OFFERS FOR THIS ROUND. Step 4 now carries a control the earlier
drafts lacked: a deliberately mismatched pipeline copy must FAIL the probe. That
was added unprompted, because a gate introduced to catch drift and never shown to
fire is the same unfailable check this requirement keeps finding, one more level
down.

### Change summary for plan python-wrapper-foreign-distro (round 4)

Document changes since round 3, for round 4.

All five round-3 writer instructions were applied to the plan, and instruction 4
also reached the validation skeleton.

THE NEW QUESTION:

- Q08, "where the freeze, manifest, handoff and acceptance boundaries sit", with
  H1 dropping the commit field and checking only against the current checkout,
  H2 the four ordered boundaries, and H3 a manifest naming its own commit. H2 is
  recommended. H3 is recorded as IMPOSSIBLE rather than merely awkward, with the
  reason: a commit id is computed over its tree, the tree contains the manifest,
  so writing the id into the manifest changes the id.

THE STEP SPLIT, which removes the circularity:

- step 4 is now preparation: freeze and commit the final harness, generate the
  manifest in a LATER commit naming that earlier one, land the pipeline copies
  and probe, obtain one build capture. Its outputs are exactly what step 5
  consumes;
- step 5 is Debian acceptance, consuming those artifacts and producing none of
  them, and explicitly forbidden from modifying the harness, since a change there
  would invalidate the identity step 4 published;
- step 4 gained a control that was not requested: a deliberately mismatched
  pipeline copy must FAIL the probe, so the unpaired-edit gate is demonstrated
  rather than asserted.

THE MANIFEST SEMANTICS:

- a new subsection states that the manifest names the EARLIER freeze commit, the
  harness path and the blob SHA-256, and why naming its own commit is impossible;
- the authority is re-attributed: the section is retitled "where its authority
  actually comes from", and says plainly that the file format is not the source
  of it. The independent cplx-side comparison at acceptance is.

THE G1 CORRECTION, applied in three places: Q07's option list now records that G1
catches copy-only drift and fails only against a paired restatement; Q07's
recommendation and answer attribute G2's strength to the acceptance-side check;
and the body's handoff section no longer claims any gate "could never go red".

RECONCILED THROUGHOUT: the target matrix gained a step 4 preparation row and a
step 5 acceptance row, with a paragraph naming the circularity that forced the
split; the fixture contract table moved from "3 and 4" to "3 and 5"; the scope
anchors describe the manifest as step 4's output and the control as step 5's; the
handoff section heading dropped its step number; the decision table gained P11 for
the ordering and P10 was rewritten to attribute authority correctly; every stale
step-4 reference in the open questions now names the acceptance step or step 5.

VALIDATION SKELETON: "five steps" became "six steps"; the owed section separates
what is a STEP from what is OWED and records why the earlier pairing was
circular; step 4 was retitled and given freeze, manifest, handoff and build
conditions; a step 5 section was added carrying the two isolated trees, the
control provenance check, the independent identity check and the
do-not-modify-the-harness condition. Its first line remains "No, it is not
implemented."

No implementation has started. Every change in this round is specification.

### Writer response for plan python-wrapper-foreign-distro (round 4)

Writer response: Writer response for round 4.

ACCEPTED IN FULL. All four requested changes and all five writer instructions
were applied. No recommendation was rejected, and no disagreement is recorded.

1. Q08 added, with H1, H2 and H3, recommending H2. H3's impossibility is stated
   as a mechanism rather than as a caution: a commit id is computed over its
   tree, the tree contains the manifest, so writing the id into the manifest
   changes the tree and therefore the id. No amount of care makes it converge.
   H1 is rejected not because it fails but because it decays: verifying against
   "the current cplx checkout" gives a retained capture nothing fixed to cite
   later.

2. The circular prerequisite is gone. Preparation became step 4 and Debian
   acceptance became step 5. The plan states the reason where a reader meets it,
   under the target matrix: the earlier draft made one step both produce the
   manifest and require it already landed and used by a build. Step 4's outputs
   are now exactly step 5's inputs, and step 5 produces none of them.

3. The manifest names the EARLIER freeze commit, with the harness path and blob
   SHA-256, and acceptance proves that commit contains those bytes at that path.
   A dedicated subsection carries the impossibility argument so the constraint is
   not rediscovered later as a bug.

4. THE G1 CORRECTION, which is mine to own. I wrote that G1 "can never go red".
   That is wrong. A digest literal beside the copy fails whenever only the copy
   moves, and that unpaired case is both real and the one actually observed in
   the relocation harness. G1's limit is a paired edit restating both sides in
   one commit. The overstatement was not merely imprecise: it attributed the
   authority to the wrong thing. A manifest beside the copy would share G1's
   property exactly. What makes G2 stronger is the independent cplx-side
   comparison at acceptance, and the plan and the question now say so, with every
   "can never go red" claim removed.

5. Reconciliation done across the target matrix, fixture contract, scope anchors,
   handoff heading, decision table (P11 added, P10 rewritten), all step
   references in the open questions, and the validation skeleton, which now
   carries six steps with completion conditions readable without the plan prose.

DISAGREEMENT: none.

ONE ADDITION MADE WITHOUT BEING ASKED, offered for the reviewer to accept or
strike. Step 4 now requires a control proving its own gate is live: a
deliberately mismatched pipeline copy must FAIL the probe. Round 3 introduced
that gate to catch drift and never required anyone to see it fire, which is the
same unfailable-check shape this requirement has now corrected at four
successive levels: the baseline nobody took, the digest that proved only a file
was read, the guard that exited a subshell, and the equality gate whose halves
moved together. Adding a control at the moment a gate is introduced is cheaper
than discovering in round five that the newest gate was decorative.

THE PATTERN, stated once more because it has now held for four rounds. Each fix
has relocated the weakness rather than removed it, and the next instance appeared
at the boundary just outside the previous repair. Round 3 predicted the remaining
candidates would sit at the edges of the manifest; round 4 found two there, the
circular ordering and the self-referential commit. The writer's expectation for
round 5 is that anything left sits at the edges of the freeze itself: what makes
"final" checkable, and what happens if steps 0 to 3 are re-run after it.

### Reviewer focus for plan python-wrapper-foreign-distro (round 4)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-08-31T10:49:20+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: answer

### Reviewer assessment for plan python-wrapper-foreign-distro round 4

The plan is implementation-ready. Round 4 removes both structural cycles: Step
4 now freezes and commits the final harness, creates the identity manifest in a
later commit naming that closed point, lands the pipeline handoff, and obtains
the build capture; Step 5 consumes those artifacts and is forbidden from
changing the harness. The validation skeleton mirrors all six steps and carries
the same identity and control gates.

The cross-repository evidence chain is now sound. The pipeline-side comparison
catches an unpaired copy drift, the deliberately mismatched-copy control proves
that gate can fail, and the independent cplx-side comparison prevents a paired
pipeline edit from restating both sides. The manifest names an earlier freeze
commit rather than its own commit, so no self-reference remains.

All eight implementation questions are sufficient and no additional question
is missing. I agree with A1, B2, C1, D1, E1, F1, G2, and H2. The open-question
history, target matrix, file lists, decision table, numbered steps, and
validation goals are aligned.

One optional wording clarification remains: use distinct terms for the Git blob
identity and the file-content SHA-256. For example, define the manifest fields
as `freeze_commit`, `harness_path`, `git_blob_oid`, and `file_sha256`, or omit
`git_blob_oid` if the commit-plus-path bytes are verified directly. This does
not change the selected design or implementation order and does not require
another automated review round.

### Question verdicts for plan python-wrapper-foreign-distro round 4

- **Q01: A1 confirmed.** Step 0 supplies the clean and planted pre-change
  baselines before Step 1 changes the wrapper.
- **Q02: B2 confirmed.** The retained historical wrapper has a checked source
  identity and runs in an isolated control tree.
- **Q03: C1 confirmed.** The exact pipeline copy, probe, paths, and owner make
  the credential-less handoff actionable.
- **Q04: D1 confirmed.** Recording shims cover the fourteen post-source helpers
  while the bootstrap call is separately logged and delegated.
- **Q05: E1 confirmed.** The shell stub preserves portable observability and the
  real target interpreter exercises venv behavior.
- **Q06: F1 confirmed.** The shared helper plus explicitly checked callers and
  mutation-log assertions propagates failure to the outer wrapper.
- **Q07: G2 confirmed.** The pipeline-local comparison catches unpaired drift;
  the independent cplx-side comparison supplies the authority against a paired
  restatement.
- **Q08: H2 confirmed.** The final harness is committed before a later manifest
  names it, the handoff/build follows, and Debian acceptance consumes those
  closed artifacts. H3 is self-referential and H1 loses durable provenance.

### Convergence evidence for plan python-wrapper-foreign-distro round 4

Covered wording: The only remaining polish is terminology: "blob SHA-256" can be read as either
a Git blob object ID or a SHA-256 over file bytes. Distinguish those fields or
state that the file bytes at `freeze_commit:harness_path` are hashed directly.
No behavior, question choice, step boundary, or acceptance criterion changes.

Convergence rationale: All eight questions have settled answers, every selected answer is integrated
into the executable plan, the six-step validation skeleton matches the plan,
and the evidence chain has both a demonstrated pipeline-side failure control and
an independent cplx-side authority check. The only remaining edit is optional
terminology clarification, so consolidation can proceed after human confirmation.

### Writer instructions for plan python-wrapper-foreign-distro round 4

No substantive specification change or additional automated review round is
required. After human confirmation, consolidate all eight selected answers into
the plan through the owning workflow.

During consolidation, optionally disambiguate the manifest terminology by
naming the Git blob OID separately from the ordinary file-content SHA-256, or by
stating that commit-plus-path bytes are hashed directly. Preserve the six-step
ordering and every existing evidence gate.

### Final reviewer decision for plan python-wrapper-foreign-distro round 4

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-4 -->

## Round 4 by human - human-confirmation

- Recorded: 2026-08-31T12:30:12+02:00
- Exchange: specification/plan/v0.27.0/python-wrapper-foreign-distro
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-wrapper-foreign-distro.md
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-4 -->
