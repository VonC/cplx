# Specification review transcript for v0.27.0

- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-08-16T22:45:43+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 1

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 1

### Requestor assessment for plan relocation-force-rpath round 1

First review round for a new implementation plan. The requirement converged
after five rounds and twelve clarifications; the design after five rounds and
seven decisions. Nothing here reopens either, and every question is an
implementation detail the plan owns.

Two things were decided while writing rather than asked, and both should be
checked rather than inherited.

**The template does not fit this repository.** It assumes a Python project:
`pytest` files under `tests/unit/**`, `__init__.py` upkeep, a `ghog day` walk,
`check.bat`, and a big-file gate at 650 lines. cplx has no `tests/` tree, no
`pyproject.toml`, no `check.bat` and no `GROUNDHOG.md`, and the file this effort
changes is Bash. The plan substitutes `shellcheck` plus a Bash harness, which is
what item 1 of this collection actually did for the same file, and states the
substitution table at the top so it can be rejected as a whole. If the
substitution is wrong, every per-step execution checklist moves with it.

**The line-budget constraint is not the one the template protects.**
`install_pkg.sh` is 625 lines, and `check_big_files.bat` scans Python under
`tools` and `tests`, so no mechanical ceiling reaches it. The constraint that
does is deployment: the script is copied next to an archive on a bare account,
sources `echos` from beside it or one level up, and falls back to inline
definitions when neither exists. So the observer, the classifier and the report
formatter either all live in that one file or the deployment starts carrying a
second one, which is a requirement-level property rather than a refactor. The
plan keeps one file, records the measured size at each step, and puts the split
decision at Step 4 with a number attached.

The six questions:

- Q01 asks whether the harness is new or extends item 1's. `verify.install-pkg.sh`
  carries a shared-body marker whose content is byte-identical to a copy in the
  consuming project, with a printed digest, so adding cases to it either breaks
  that property or exports maintenance to another repository.
- Q02 is the line budget above, framed as what a plan may and may not decide.
- Q03 asks how the ELF fixtures exist, since the design fixed the matrix and
  left the bytes here. Committed binaries are opaque to review and to the
  sensitive-content scan; a generator is reviewable text that can itself be
  wrong.
- Q04 asks whether the report should be built before the behavior changes, so
  Step 3 is watched by the instruments that will accept it, against the cost of
  emitting a `case` field before cases exist.
- Q05 asks how the shell carries the normalized tuple, which the design
  explicitly left to the plan. The clearing rule exists because a Bash loop
  leaks, so the carrier choice is what makes that rule enforceable or merely
  hoped for.
- Q06 asks what Step 6 does when the monitoring evidence depends on another
  team. The requirement already allows a blocked criterion; the plan has to say
  where that record lives and what it must name.

Where the plan is most likely to be wrong:

- The step count and boundaries are asserted rather than derived. Seven steps
  with one behavior-changing step is the shape the writer believes keeps each
  diff attributable, but Steps 1 and 2 could be one step, and Step 5 could fold
  into Step 6.
- The advisory line estimates, 750 to 800 after Step 1 and 950 to 1000 after
  Step 4, are guesses from the size of the described work, not from a
  prototype. If they are badly wrong the Step 4 checkpoint fires early or late.
- The plan forbids a second walk of the tree as an absolute rule. That is taken
  from the design's IO clarification and is stated more strongly here than
  there.
- No perf-gate step is planned, and the reason is recorded rather than left
  silent, but a reviewer may think the walk duration deserves a gate rather than
  a recorded comparison.

### Change summary for plan relocation-force-rpath round 1

Round 1: there is no preceding round, so this records how the plan came to exist
and what it contains.

Provenance:

- `docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md`, converged on
  2026-08-16 with twelve clarifications.
- `docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md`, converged the same
  day with seven decisions.
- Both plans were written from those two plus a fresh reading of
  `src/setups/env/bin/install_pkg.sh` and the repository's actual gate and test
  infrastructure.

What `plan.v0.27.0.relocation-force-rpath.md` contains:

- A "How this plan departs from the standard template" section with a
  five-row substitution table, since the template assumes Python tooling this
  repository does not have.
- Four confirmed facts read from the tree: the 625-line count and why the
  Python big-file gate does not reach it, the standalone deployment constraint
  that does, the existing walk and its four-byte read, the four patchelf call
  sites, and that the archive ships no fixtures today.
- A file-based IO cost clarification whose operative rule is that no step may
  add a second full walk of the tree.
- Seven steps, 0 through 6, each with the three required subsections, analysis
  and intent, implementation, and addendums:
  - Step 0 builds the verification harness and captures the current behavior,
    writing no installer code.
  - Step 1 implements the observer and its guard-complete fixture matrix.
  - Step 2 implements the ordered classifier over controlled tuples.
  - Step 3 wires it in, adds `--force-rpath`, and adds the migration assertion.
    This is the only behavior-changing step.
  - Step 4 implements the two axes and the `CPLX-ELF/1` record stream, and is
    the checkpoint where the file size is judged.
  - Step 5 updates the three wiki pages.
  - Step 6 runs the acceptance and retains its evidence.
- An execution command checklist mutualized across steps: count lines before and
  after, run the gate-then-tests walk, run the host-tool grep check.
- A ready-to-run command, `shellcheck` followed by the harness at the step's
  number, repeated fix-and-walk.
- A Step 0 perf-gate pass that records why no time-bound `xfail` gate is
  planned, rather than omitting the section.

What `plan.v0.27.0.relocation-force-rpath.validation.md` contains:

- The opening line "No, it is not implemented."
- Seven `Analysis of Step N implementation state` sections, each opening with
  "Not started. Step N is not implemented because ...".
- A filled `Goal` and `improvement expectations` per step, and the literal
  placeholder `_(empty — no check has taken place yet.)_.` in every
  not-yet-checked section.
- No `Missing work` section, since no check has taken place.
- No decisions table and no `| Qxx` row, so `pw` routing does not read the fresh
  plan as already consolidated.

Six open questions were then placed by `oqm`, and no section of either plan has
been edited in response to review yet.

### Writer response for plan relocation-force-rpath round 1

Writer response: Round 1: no reviewer feedback exists yet, so there is nothing accepted and
nothing disputed.

The writer's position going into this round:

- The six recommended answers are recommendations. None is written into the
  plan's steps as a settled rule, so a different answer changes the affected
  step rather than the plan's shape.
- Q02 is the one the writer holds most firmly, and the reason is a boundary
  rather than a preference. Splitting `install_pkg.sh` changes what a deployment
  must carry, and the file exists to be runnable from a bare account with the
  archive and nothing else. That is a requirement-level property, so a plan that
  split the file would be deciding something it does not own. Measuring at Step
  4 and handing an amendment upward is the writer's answer to a real cost, not
  an avoidance of it.
- Q01 is held on a fact about another repository rather than on taste.
  `verify.install-pkg.sh` prints the digest of a body it declares byte-identical
  to the consuming project's copy, and item 1 spent review rounds on that
  property. Adding this effort's cases to it would either break the digest or
  oblige a cross-repo update on every change here.
- Q04 and Q05 are the two where the writer would most readily accept a different
  answer. Building the report before the wiring has a genuine argument, and the
  objection to it, a `case` field with no vocabulary yet, may be lighter than it
  looks. And the associative-array carrier of 5C is the safer shape; it was not
  recommended only because its Bash version dependency has not been checked
  against either target, which is itself a checkable thing rather than a reason.

Three things the writer wants examined rather than accepted:

- The template substitution is the largest unasked decision in this plan. It was
  made because the alternative was writing per-step checklists naming tools this
  repository does not have, and item 1's precedent is direct. If the reviewer
  disagrees, the substitution table is a single place to correct.
- The step boundaries are asserted. Steps 1 and 2 could be one, and Step 5 could
  fold into Step 6. The writer separated them so that the one behavior-changing
  diff, Step 3, stands alone, but that is a judgement about reviewability rather
  than a constraint from the design.
- The line estimates are guesses from the described work rather than from a
  prototype, and the Step 4 checkpoint depends on them being roughly right.

### Reviewer focus for plan relocation-force-rpath round 1

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer

- Recorded: 2026-08-16T23:17:12+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 1

The Python-template substitution is correct. This repository's executable
gate is `shellcheck` plus a Bash harness, and importing nonexistent `pytest`,
`ghog`, `check.bat` and Python package machinery would make the plan less
executable rather than more faithful. Keeping the observer and classifier in
the standalone installer is also the right requirement boundary; the measured
Step 4 checkpoint is preferable to inventing a line ceiling that no repository
gate enforces.

Round 1 is nevertheless `changes-requested`. Two current recommendations have
counterexamples, and one callable boundary is missing from the plan.

First, Steps 3 and 4 produce an incoherent intermediate production state.
Step 3 changes which objects are written and which tag they receive while the
pass still emits the old mixed count; Step 4 later adds the report that the
requirement says makes partial coverage legible. Building the final report
before the change is not viable either: its case/disposition relationships are
defined by the new action, so it would have to fabricate a disposition for a
selected object the old pass did not write. Add option 4D and choose it: keep
the observer and classifier as separately proved Steps 1 and 2, prepare both
behavior and report tests first, then land classifier wiring, `--force-rpath`,
the migration assertion, both axes and `CPLX-ELF/1` atomically in one production
step. A larger coherent diff is safer than either of the two invalid temporal
states. Renumber the documentation and acceptance steps and update the
validation skeleton with the main plan.

Second, Q03's proposed oracle is not independent. A generator that writes
`e_type` or a program-header field at the wrong offset and an observer that
reads that same wrong offset can make every generated accepted fixture green;
the ordinary cases do not necessarily fail first. Keep generated scratch
fixtures, but give them a pre-observer oracle: validation-only `readelf` checks
the lawful base fixtures and their tags, and explicit size/offset and
single-mutation assertions check each malformed derivative before the observer
runs. Declare `readelf` as a harness prerequisite, not an installer host tool.
The installer host-tool grep remains unchanged. Put the textual generator in
`verify.relocation-rpath.sh` (or name a separate committed generator) and
remove `docs/v0.27.0/fixtures/` from Step 1 when no committed fixture directory
will exist.

Third, the direct tests have no execution seam. The plan requires the harness
to invoke the observer and classifier without an install, but the current
`install_pkg.sh` continues into argument parsing and deployment when sourced.
Add Q07 and select a source-safe boundary: after all function definitions and
before the main flow, return when `BASH_SOURCE[0] != $0`; the harness sources
the installer inside a subshell and calls the production functions. An internal
test CLI would enlarge the invoked interface, and copying or extracting
function text would cease to test the production implementation.

Q05 should take the safer carrier rather than reject it on an unmeasured
assumption. Use one associative array for the named tuple, clear it in one
operation per object, and let controlled tests fill the same container. Add a
pre-Step-1 capability check for associative arrays on both supported targets;
if either fails, stop and revise the plan rather than silently falling back.
Debian 12's official package page identifies Bash 5.2, so only the target-side
RHEL evidence remains to be captured. This is an interpreter-capability check,
not a new external host program.

Q06 needs one semantic correction. Recording a blocked monitoring criterion
is a terminal, truthful validation outcome, but it does not make that criterion
satisfied or the acceptance green. Step 6 may finish collecting all evidence
and record the external criterion as `blocked`; the validation plan and retained
evidence must preserve that blocked overall status. Name the owning team or
contact channel, request timestamp/identifier, acceptable observable requested,
and response or absence. A personal name is neither required nor desirable in
committed evidence.

Answers 1A and 2A stand. Keep generated fixtures as a strengthened 3A; add and
choose 4D; choose 5C after the capability gate; revise 6A as a blocked verdict,
not a passing one; and add Q07 with 7A. No fixed performance threshold is
missing: retaining the duration comparison while forbidding a second production
tree walk is proportionate. Steps 1 and 2 should remain separate, as should the
documentation and final acceptance work.

References checked:

- https://packages.debian.org/bookworm/bash

### Question verdicts for plan relocation-force-rpath round 1

1. **Q01 -- choose 1A.** A new effort-local harness preserves the completed
   harness's byte-identical cross-repository body and digest. The duplicated
   runner is bounded scaffolding; extending or extracting the old harness would
   reopen already-retained evidence.

2. **Q02 -- choose 2A.** Keep one standalone installer, record measured growth,
   and escalate a split as a requirement amendment. Replace subjective line
   estimates with measurements as implementation proceeds, but do not turn an
   unenforced Python ceiling into a Bash rule.

3. **Q03 -- choose a strengthened 3A.** Generate fixtures into the harness
   scratch directory from committed text, but validate them before the observer:
   use validation-only `readelf` for lawful base shapes and tags, and assert
   exact sizes, targeted offsets and the intended single mutation for malformed
   derivatives. Remove the claim that accepted fixtures necessarily expose a
   generator/observer shared mistake. Put the generator in the named harness or
   name its source file; do not also schedule a committed `fixtures/` directory.

4. **Q04 -- the options are incomplete; add and choose 4D.** Land behavior and
   its final report atomically after both test surfaces exist. Building the
   report first cannot assign design-valid dispositions to old actions; landing
   behavior first leaves the requirement's partial-coverage report absent.
   Merge current Steps 3 and 4, then renumber both plans.

5. **Q05 -- choose 5C after an explicit capability gate.** Use one associative
   array, cleared and refilled per object, as the named-field carrier. It gives
   one reset and lets tests construct the production tuple directly. Before
   Step 1, record associative-array support on Debian 12 and the RHEL 9.8 target;
   stop for plan revision if either does not provide it. Do not reject the safer
   representation merely because the check was omitted.

6. **Q06 -- choose a narrowed 6A.** Evidence collection may terminate with the
   monitoring criterion recorded as blocked, but blocked is not satisfied and
   must not be presented as green acceptance. Record the owning team/contact
   channel, request time or identifier, the acceptable observable requested,
   the response or absence, and the retained evidence path in the validation
   document.

7. **Missing Q07 -- how direct tests reach production functions.** Add options
   for a source-safe guard, a test-only CLI, and copying/extracting functions.
   Choose 7A: after all definitions and before main argument parsing, return
   when the file is sourced; source it in an isolated harness subshell. This
   exposes the real observer and classifier without adding an invoked operating
   mode or duplicating implementation text.

8. **Other missing questions.** None. Validation-only `readelf` belongs to Q03,
   and the atomic-step correction belongs to Q04. The template substitution,
   absence of a fixed perf gate and single production-walk rule need no new
   decision.

### Requested changes for plan relocation-force-rpath round 1

Requested changes: Requested changes:

1. Merge behavior wiring and the final report into one coherent production
   step and renumber both plan documents.
2. Give generated ELF fixtures an independent pre-observer oracle and reconcile
   their actual committed/scratch artifacts with the file list.
3. Select the associative-array tuple carrier after target capability evidence.
4. Define blocked monitoring evidence without treating it as passed acceptance.
5. Add the missing source-safe seam through which the harness calls production
   observer and classifier functions.

### Writer instructions for plan relocation-force-rpath round 1

Revise both the implementation plan and its validation skeleton, then publish
another automated plan-review round.

1. Keep Q01=1A and Q02=2A. Preserve the Bash-harness substitution and the
   standalone installer boundary.
2. Strengthen Q03=3A with an oracle independent of the observer: declare
   validation-only `readelf`, verify lawful base fixtures, assert exact targeted
   mutations for malformed derivatives, and make the generator's committed
   location agree with Step 1's file list.
3. Add Q04 option 4D and select it. Merge the current behavior and report steps
   into one atomic production step after observer/classifier tests, then
   renumber the wiki and acceptance steps in both documents.
4. Change Q05 to 5C with a pre-Step-1 associative-array capability check on
   Debian 12 and RHEL 9.8. Use one cleared named container for observer,
   classifier and controlled tests.
5. Revise Q06=6A so a blocked external criterion is a terminal recorded
   validation status, never a satisfied/green criterion; record team/contact,
   request identity/time, requested observable, result and evidence path.
6. Add Q07 and choose the source-safe guard before the installer's main flow;
   require the harness to source it only in an isolated subshell and call the
   production functions directly.
7. State explicitly that the no-second-walk rule applies to the production ELF
   pass. Keep duration comparisons as evidence without inventing a timing gate.

### Final reviewer decision for plan relocation-force-rpath round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-08-17T09:07:57+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 2

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 2

### Requestor assessment for plan relocation-force-rpath round 2

Round 2. All five round 1 requested changes are applied, none disputed, and the
step list changed as a result, so both documents were renumbered together.

Two of the writer's own arguments were refuted rather than refined, and both are
the same kind of error: a property asserted about a structure without being
checked against it.

**Q03's oracle was not an oracle.** The plan argued that a generator wrong about
the ELF layout would be caught because the accepted fixtures would fail first.
They would not. A generator that writes `e_type` at the wrong offset and an
observer that reads that same wrong offset agree with each other; the ordinary
`ET_EXEC` and shared-library cases both go green, and the rejection rules the
fixtures exist for are never really exercised. The fixtures now pass an oracle
that cannot share the observer's assumptions: validation-only `readelf` for the
lawful base shapes and their tags, and, for each malformed derivative, a single
mutation from a validated base with its size and changed offset asserted. Option
3D records the refuted argument rather than quietly dropping it.

**Q04's two steps had no valid ordering.** The writer weighed behavior-then-
report against report-then-behavior and picked the first without noticing that
both leave a production state nobody would ship. Behavior first releases a pass
writing `DT_RPATH` over three populations while still printing the mixed count
the requirement exists to remove; report first would carry a `case` field for a
classifier the pass is not consulting. Option 4D is added and chosen: the
classifier wiring, `--force-rpath`, the migration assertion, both axes and the
record stream land atomically as Step 3, after Steps 1 and 2 have separately
proved the observer and the classifier. The wiki work is now Step 4 and the
acceptance Step 5, six steps in total, and the validation skeleton matches.

The other three:

3. Q05 becomes 5C. The associative-array carrier was rejected on an unmeasured
   Bash version assumption, which is a thing to check rather than a reason to
   take the weaker shape. It is now the carrier, with a Step 0 capability gate
   recording `declare -A` support on Debian 12, which ships Bash 5.2, and on the
   RHEL 9.8 target. A failure there stops the plan for revision rather than
   falling back quietly. This is an interpreter capability, so the host-tool
   contract is untouched.
4. Q06 keeps 6A with the semantic correction that matters: blocked is a
   terminal, truthful outcome for evidence collection and is **not** a satisfied
   criterion. The validation document and the retained evidence both carry it,
   the overall acceptance is not green while it stands, and the record names the
   owning team or contact channel rather than a personal name, the request time
   or identifier, which observable was requested, the response or its absence,
   and the evidence path.
5. Q07 is new and answers a seam two steps already assumed. `install_pkg.sh`
   runs top to bottom, so sourcing it to reach a function would perform an
   install. A guard after the definitions and before the main flow returns when
   the file was sourced; the harness sources it in a subshell and calls the
   production functions. Added in Step 0, before any function worth calling
   exists.

Also applied: the no-second-walk rule is now scoped to the production ELF pass,
with the harness and the acceptance explicitly outside it; `readelf` is declared
a harness prerequisite and the installer host-tool grep is unchanged; and the
committed `docs/v0.27.0/fixtures/` directory is removed from Step 1's file list,
since the generator lives in the harness and the fixtures are generated into its
scratch directory.

What round 2 should look at:

- The atomic Step 3 is now the largest diff of the effort and carries its whole
  risk. The plan argues it is safer than either invalid intermediate state, and
  that both test surfaces precede it, but a reviewer may think it should be
  bounded further, for instance by requiring the report-contract cases to pass
  against a stub before the wiring lands.
- The source-safe guard's position is load-bearing. A function defined below it
  is unreachable to the tests, silently. The plan notes this and relies on the
  step cases failing loudly if a called function is undefined, which is a
  detection rather than a prevention.
- The line estimate for the merged step is the sum of the two it replaces, 120
  to 180 lines, which assumes the merge neither adds nor removes work. It
  probably removes a little, since the report no longer has to be retrofitted.
- Nothing in the plan says what happens if the RHEL associative-array check
  cannot be run at all, as opposed to running and failing. The stop-and-revise
  rule covers a negative answer, not an unobtainable one, and Q06 shows this
  effort has a target-access problem worth being consistent about.

### Change summary for plan relocation-force-rpath round 2

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 1, applying round 1's five requested changes.

Step list, renumbered in both documents:

- Old Steps 3 and 4 are merged into one atomic Step 3 carrying the classifier
  wiring, `--force-rpath`, the migration assertion, both disposition axes and
  the `CPLX-ELF/1` record stream.
- Old Step 5, the wiki pages, becomes Step 4.
- Old Step 6, the acceptance, becomes Step 5.
- Six steps, 0 through 5. The validation skeleton now carries exactly six
  `Analysis of Step N` sections, and its opening line says six rather than seven.

Confirmed facts and IO clarification:

- The no-second-walk rule is scoped to the production ELF pass, with a paragraph
  stating that the harness and Step 5's acceptance may read a prepared tree as
  often as they need because none of it runs on a deployment.
- The fixtures fact is rewritten: nothing binary is committed, the generator is
  committed text in the harness, and fixtures are generated into the scratch
  directory.
- The Step 4 forward reference for the line-budget judgement is now Step 3, with
  the reason, that it is the last step adding production code.

Step 0 gains two subsections and one file:

- `src/setups/env/bin/install_pkg.sh` is added to its file list for the
  source-safe guard alone, with no behavior change.
- "Step 0 capability gate" records `declare -A` support on Debian 12 and the
  RHEL 9.8 target, and `readelf` on the validation host as a harness
  prerequisite that never runs during an install and never enters the host-tool
  grep.
- "Step 0 source-safe seam" specifies the guard after the definitions and before
  the main flow, returning when sourced, with the harness sourcing in a subshell.
- Completion criteria gain the sourcing case, the unchanged executed path, and
  both capability records. The line budget notes the guard's 3 to 5 lines.

Step 1:

- The committed `docs/v0.27.0/fixtures/` entry is removed from the file list; the
  harness is named as carrying the generator.
- A new "Step 1 fixture oracle, independent of the observer" subsection states
  why the fixtures cannot be validated by the observer, and specifies
  validation-only `readelf` for lawful bases and single-mutation assertions with
  size and offset for derivatives. It says plainly that the previous claim was
  wrong.
- Behavior notes the associative-array carrier cleared in one operation.
- Completion criteria gain the oracle-before-observer ordering, the sourcing
  seam, and the clarification that the harness's `readelf` is outside the
  installer grep.

Step 3, new and merged:

- Its issues section explains why the two halves cannot be separated, naming
  both invalid intermediate states.
- Test first covers both surfaces, behavior cases and report-contract cases.
- Completion criteria combine both halves and add the no-second-walk check.
- The line budget checkpoint is now here, as the last production step, with the
  estimate stated as the sum of the two merged steps.

Step 5 gains a "Step 5 blocked-evidence rule" subsection: blocked is terminal
and truthful, is not satisfied, must never be presented as green, and its record
names the owning team or contact channel rather than a personal name, the
request time or identifier, the observable requested, the response or absence,
and the evidence path. Its completion criteria reflect that the overall status
depends on which outcome applies.

Validation skeleton:

- Re-aligned to six steps; the Step 3 section is rewritten for the merged step
  and carries the reason both halves land together; old Steps 5 and 6 become 4
  and 5.
- Step 0's expectations gain the two capability facts and the seam.
- Step 1's expectations gain the independent oracle, with the refuted argument
  named, and the associative-array carrier.
- Step 5's expectations gain the blocked-versus-satisfied distinction and the
  fields a blocked record must carry.

Open questions, replaced as a whole:

- Q01 and Q02 carried. Q03 rewritten with the independent oracle and gaining
  option 3D, generate and trust, recorded as refuted. Q04 gaining option 4D and
  selecting it, with 4A and 4B kept and their invalid states named. Q05 changed
  from 5A to 5C with the capability gate. Q06 rewritten so blocked is distinct
  from satisfied. Q07 new, with options for a source-safe guard, a test-only CLI
  and copying the function text.
- Answers now stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A.

### Writer response for plan relocation-force-rpath round 2

Writer response: All five requested changes are applied. Nothing is disputed.

The Q03 refutation is the one worth dwelling on, because the writer had already
been caught twice by the same move in the design review and made it again here.
The pattern is asserting a property about a structure instead of checking it
against the structure. In the design it was "no disposition contains a space",
with three space-containing dispositions three sections above. Here it was "a
shared generator and observer mistake surfaces through the accepted fixtures",
which fails the moment you ask what happens when both read the same wrong
offset: they agree, and agreement is exactly what the test reports as success.
Option 3D now carries the refuted argument in the document so the reasoning is
on the record rather than silently replaced.

The Q04 finding is a different error and a more useful one. The writer framed
the question as an ordering choice, weighed two orderings, and picked one,
without asking whether either produced a state worth shipping. Neither did. That
is a question the writer did not think to ask about its own option set, and the
answer, landing both atomically, was not among the options offered. The plan now
says so directly in Step 3's issues section rather than presenting the merge as
though it had always been the intent.

On Q05 the correction is smaller but the reasoning error is the same shape as
Q03's. The associative array was rejected because its Bash support had not been
checked, which made the unchecked assumption the reason for avoiding the safer
mechanism, rather than a thing to spend a minute measuring. Debian 12's package
page settles half of it and Step 0 now measures the other half on the target.

Q06's correction is semantic and important. The writer said where a blocked
record goes without saying what it means, and a blocked criterion recorded
without that distinction reads as a passing one to anyone skimming. Terminal and
truthful is not satisfied, and the overall acceptance is not green while it
stands.

Q07 is the gap the writer should have found while writing Steps 1 and 2, both of
which assert that the harness calls the production functions directly. Nothing in
the plan said how, and `install_pkg.sh` would have performed an install on being
sourced. The guard is a few lines in Step 0, before any function worth calling
exists.

Four things are offered for round 2 rather than claimed as settled. The atomic
Step 3 now carries the effort's whole risk, and a reviewer may want it bounded
further. The guard's position is load-bearing and the plan detects rather than
prevents a function defined below it. The merged step's line estimate is the sum
of the two it replaces, which assumes the merge is work-neutral. And the
stop-and-revise rule for the capability gate covers a negative answer but not an
unobtainable one, which matters because Q06 shows this effort already has a
target-access problem.

### Reviewer focus for plan relocation-force-rpath round 2

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-08-17T09:33:17+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 2

The six-step revision fixes the incoherent behavior/report intermediate state,
and the Bash-project substitutions remain appropriate. Answers 1A, 2A, 3A,
4D, 5C, 6A, and 7A can all stand. Round 2 is nevertheless
`changes-requested`, because the implementation instructions still contain
three counterexamples and two ambiguities that can make a conforming execution
unsafe or impossible.

The strengthened Q03 oracle proves mutation provenance, not field semantics.
If the generator changes byte offset X believing it is `e_type`, and the
observer makes the same mistaken assumption, a size check plus "exactly offset
X changed" passes without establishing that X is `e_type`. Require an
independent semantic expected result for every fixture. Use validation-only
`readelf` output or diagnostics where it can express the state; for deliberately
malformed states it cannot identify, bind the mutation to a specification-based
golden offset/value manifest that is not derived through observer helpers. The
matrix must name the oracle used by each fixture. Keep 3A, but remove the claim
that single-mutation assertions alone break a generator/observer shared error.

Q04's atomic production outcome is right, but the merged Step 3 now contains
the formatter, retained-capture reader, behavior mutation, migration assertion,
and full integration in one 120--180-line unit. Its prose says both test
surfaces already exist, while the report-contract tests are created inside that
same step. Bound the risk without creating an observable intermediate state:
add a preparatory step that implements and makes green the uncalled report
formatter/reader contract, then atomically connect classification, mutation,
assertion, and report emission in the following production step. The helper is
not called by the installer main flow until that integration step, so 4D still
governs the shipped behavior. Renumber the plans consistently.

Q05 should specify one fixed, global associative-array name shared by the
observer, classifier, and controlled tests, cleared in one operation before
each observation. This avoids silently depending on associative-array namerefs
in addition to the capability being gated. The capability gate also needs
three outcomes: a successful supported check permits work; a successful
unsupported check requires plan revision; unavailable exact-target access
records Step 0 as blocked unless representative, version-pinned RHEL 9.8/UBI
evidence is captured, in which case exact-target confirmation remains due in
final acceptance. An unavailable check is not evidence of an unsupported
shell.

Q06 currently says both that a blocked result is terminal and does not hold the
effort open, and that acceptance is "not complete while it stands." Those are
different lifecycle meanings. Keep 6A by making evidence collection complete
with an overall terminal verdict of `blocked`: the monitoring criterion remains
unsatisfied, the acceptance is not green, and no implementation success may be
claimed. If the intended meaning is instead that acceptance remains incomplete,
the effort necessarily remains open; do not retain both readings.

Finally, Q07's required guard location does not exist in the current script.
`usage` and `select_copy_engine` are defined after top-level argument-processing
flow has begun, so a guard cannot be both after every function definition and
before main without rearrangement. Keep 7A, move those definitions above an
explicit main boundary, place the sourced-versus-executed guard at that
boundary, and make the harness assert the required production functions exist
after sourcing. Replace the stated 3--5-line addition with a measured net
change, since moving the two functions is part of the seam. Also correct Step
0's "No installer line changes" statement and Step 2's stale Step 6 reference.

No new open question is needed. These are implementability refinements to the
selected answers, not new design choices. The line estimate should remain an
advisory range replaced by measured growth; it must not be used as a gate.

### Question verdicts for plan relocation-force-rpath round 2

1. **Q01 -- keep 1A.** The effort-local Bash harness remains the correct reuse
   boundary and preserves the completed predecessor evidence.

2. **Q02 -- keep 2A.** Keep the standalone installer and measure its growth.
   Treat estimates as planning ranges, not as a mechanical line gate.

3. **Q03 -- keep and strengthen 3A.** For each fixture, name an oracle that is
   semantically independent of the observer. Validation-only `readelf` may
   validate lawful objects and supported rejection diagnostics; otherwise use
   a specification-based golden offset/value manifest. Exact size and
   single-mutation assertions remain useful provenance checks but are not the
   semantic oracle. Option 3D remains correctly rejected.

4. **Q04 -- keep 4D, with a preparatory contract step.** First implement and
   make green the report formatter and retained-reader contract without calling
   them from production flow. In the next step atomically wire the classifier,
   `--force-rpath`, migration assertion, dispositions, and report emission.
   This bounds the large step while preserving one coherent observable change.

5. **Q05 -- keep 5C.** Specify a fixed global associative array, cleared before
   every observation, rather than adding an unstated nameref dependency. Give
   the capability gate distinct supported, unsupported, and unavailable paths;
   representative pinned evidence may defer only the exact-target confirmation
   to acceptance.

6. **Q06 -- keep 6A with one lifecycle meaning.** Evidence collection can
   finish with the overall validation verdict `blocked`. The external criterion
   is then unsatisfied and acceptance is not green, but the recorded blocked
   outcome is terminal and need not leave the effort waiting indefinitely.

7. **Q07 -- keep and strengthen 7A.** Move the two functions currently below
   top-level flow above an explicit main boundary, put the source guard there,
   and assert after sourcing that every required production function is
   defined. The current script has no location satisfying the answer without
   this rearrangement.

8. **Other missing questions.** None. The remaining changes make the chosen
   options executable and internally consistent.

### Requested changes for plan relocation-force-rpath round 2

Requested changes: Requested changes:

1. Give every generated ELF fixture an independent semantic oracle; do not
   treat a single-mutation offset assertion as sufficient.
2. Bound the merged production step with a prior green, uncalled
   formatter/reader contract step while retaining atomic observable behavior.
3. Specify the associative-array carrier and all three capability-gate
   outcomes, including unavailable target evidence.
4. Give terminal `blocked` one consistent lifecycle meaning without presenting
   the monitoring criterion or acceptance as green.
5. Create a source boundary that can actually exist in the current script by
   moving the two late function definitions and testing the sourced seam.
6. Reconcile the Step 0 line-change contradiction, stale step reference, step
   numbering, and validation skeleton.

### Writer instructions for plan relocation-force-rpath round 2

Revise the implementation plan and validation skeleton together, then publish
another automated plan-review round.

1. Keep decisions 1A, 2A, 3A, 4D, 5C, 6A, and 7A.
2. Amend Q03 and Step 1 so every generated fixture names an independent
   semantic oracle. Keep size and single-mutation checks as additional
   provenance evidence, not as proof that the mutated bytes represent the
   intended ELF field.
3. Split preparation from observable integration under Q04: add a step that
   implements and makes green the uncalled formatter/retained-reader contract;
   follow it with one atomic production step for classifier wiring, relocation
   behavior, migration assertion, axes, and report emission. Renumber all later
   steps and both documents.
4. Under Q05, name one fixed global associative array and its clear-before-fill
   rule. Define capability outcomes for supported, unsupported, and unavailable
   evidence. If representative version-pinned evidence is used because the
   exact RHEL target is unavailable, require exact-target confirmation during
   acceptance.
5. Under Q06, state that collection may complete with overall verdict
   `blocked`; blocked is terminal but neither satisfied nor green. Remove the
   contradictory claim that acceptance itself remains incomplete indefinitely.
6. Under Q07 and Step 0, move `usage` and `select_copy_engine` above an explicit
   main boundary, place the source guard at that boundary, and require the
   harness to assert the observer, classifier, and report functions are defined
   after sourcing. Update the line-change estimate to include the rearrangement.
7. Remove the contradictory "No installer line changes" sentence, correct the
   stale Step 6 reference in Step 2, and keep all line estimates advisory until
   replaced by measurements.

### Final reviewer decision for plan relocation-force-rpath round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-08-17T09:44:50+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 3

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 3

### Requestor assessment for plan relocation-force-rpath round 3

Round 3. All six round 2 requested changes are applied, none disputed. Every
answer stands, 1A, 2A, 3A, 4D, 5C, 6A, 7A, and the step list grew by one: a
preparatory report-contract step now precedes the atomic integration, so the plan
runs 0 through 6 and the validation skeleton has seven sections.

Three of the writer's statements were wrong in the same way, and naming the
pattern once is more useful than apologising three times. Each asserted a
property of a structure without checking it against the structure.

**Q03: provenance is not semantics.** The plan asserted that a single-mutation
and exact-size check made the fixtures trustworthy. It proves the generator
changed one offset on purpose; it says nothing about what that offset is. If the
generator changes byte X believing it is `e_type` and the observer reads byte X
believing the same, the assertion passes and so does the observer. Every fixture
now names a semantic oracle sourced independently of the observer:
validation-only `readelf` where it can express the state, and a
specification-derived golden offset and value manifest where no tool will name a
deliberately malformed shape. Provenance checks stay, labelled as what they are.
Options 3D and 3E now both sit in the question, being the two versions this plan
proposed and had refuted.

**Q07: the guard had no valid location, and the file says so.** The plan
specified a guard "after every function definition and before the main flow".
Checked against the script: `usage` is defined at line 432, after the
argument-parsing section opens at 428, and `select_copy_engine` at 485 is called
at 498. No position satisfies both halves. Creating the boundary is now part of
the step: the two definitions move above an explicit main boundary, the guard
goes there, and the harness asserts after sourcing that every production function
it will call is defined, which turns the boundary's load-bearing position from
something a reader must remember into something the tests check. The line
estimate is replaced by a measured net change, since moving two definitions is
part of the seam rather than an aside.

**Q06: blocked carried two lifecycles at once.** The plan said blocked was
terminal and did not hold the effort open, and also that the acceptance was not
complete while it stood, which is the definition of holding it open. One meaning
now: evidence collection completes with an overall verdict of `blocked`, the
criterion is unsatisfied, the acceptance is not green, no implementation success
is claimed on its strength, and the verdict is terminal. Unsatisfied and terminal
are compatible; unsatisfied and still-running are not.

The other three:

- Q04 gains the preparatory step. The merged step carried the formatter, the
  reader, the behavior change, the assertion and the integration in one unit,
  while its own prose claimed both test surfaces existed beforehand and then
  created one of them inside it. The formatter and reader are now implemented
  and proved uncalled in Step 3; Step 4 adds the wiring, the writes and the call
  sites. The atomic property is preserved because it is about what a deployment
  observes, and an uncalled definition is indistinguishable from absence.
- Q05 names one fixed global associative array shared by observer, classifier
  and tests, cleared in one operation before each observation. Fixed and global
  because Bash cannot pass an associative array by value, so a per-call container
  would add a nameref dependency beyond the capability being gated. The Step 0
  check now has three outcomes, since the writer's two-outcome rule would have
  read "we could not log in" as "the shell does not support it".
- The stale references are fixed: the Step 0 "no installer line changes"
  sentence, which its own file list contradicted, the Step 2 forward reference,
  and the step numbering across both documents.

What round 3 should look at:

- Step 3's claim that an uncalled definition creates no observable intermediate
  state is the load-bearing argument for splitting the merged step, and it rests
  on nothing calling it. A stray call site added by accident would make it false
  silently. The step's completion criteria include re-running the Step 0
  baseline, which would catch an emitted record, but not an uncalled function
  that a later reader assumes is live.
- The golden manifest of Q03 is hand-derived from the ELF specification, so it
  is a new artifact that can itself be wrong. Its scope is bounded to the offsets
  the fixtures mutate, which the plan states, but nothing cross-checks it.
- The `unavailable` branch lets work proceed on representative version-pinned
  evidence with exact-target confirmation deferred to Step 6. If Step 6's target
  access is also unavailable, the effort would carry two deferred confirmations
  into a `blocked` verdict, and the plan does not say whether that compounds.
- The line estimates now span four steps and total 260 to 390 lines above the
  625 baseline. They remain advisory and are replaced by measurements, which the
  plan states, but the total is worth a sanity read.

### Change summary for plan relocation-force-rpath round 3

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 2, applying round 2's six requested changes.

Step list, renumbered in both documents:

- A new Step 3 implements the record formatter and the retained-capture reader
  and makes their contract green, with no call site in the installer's main
  flow.
- The atomic integration becomes Step 4: classifier wiring, `--force-rpath`, the
  migration assertion, the two axes and the emission call sites.
- The wiki work becomes Step 5, the acceptance Step 6.
- Seven steps, 0 through 6, and the validation skeleton now carries seven
  `Analysis of Step N` sections with its opening line saying seven.

Step 0:

- The "No installer line changes in this step" sentence is removed; it
  contradicted the step's own file list. The fix intent now says the installer
  changes structurally.
- The framings and complexity-impact subsections are corrected in the same way:
  the step changes no production behavior rather than no production code.
- The file entry for `install_pkg.sh` now names the main boundary, the guard and
  the two moved definitions.
- The capability gate gains a three-outcome table: supported proceeds,
  unsupported stops the plan for revision, unavailable records Step 0 as blocked
  unless representative version-pinned RHEL 9.8 or UBI evidence is captured, in
  which case exact-target confirmation falls due in Step 6. A sentence states
  that an unavailable check is not evidence of an unsupported shell.
- The source-safe seam subsection is rewritten around the fact that no valid
  guard location exists today, citing `usage` at line 432 and
  `select_copy_engine` at 485 called at 498, and specifies the three ordered
  parts: move the definitions, mark and guard the boundary, assert after sourcing
  that every production function is defined.
- Completion criteria gain the post-source assertion and name the three-outcome
  record.
- The line budget replaces "3 to 5 lines" with a measured net change, stating
  that the earlier figure counted only the guard.

Step 1:

- The fixture-oracle subsection is rewritten around the provenance-versus-
  semantics distinction, with the refuted claim named. It specifies
  validation-only `readelf` where the state can be expressed and a
  specification-based golden offset and value manifest where it cannot, written
  independently of any helper the observer uses, and keeps size and
  single-mutation assertions as provenance evidence only. The matrix names the
  oracle per fixture.
- Completion criteria require each fixture to name and pass its semantic oracle.
- The behavior subsection specifies one fixed global associative array shared by
  observer, classifier and tests, with the reason that Bash cannot pass one by
  value and a nameref would add a second capability beyond the gated one.

Step 2:

- The stale forward reference to Step 6 is corrected and now names it as the
  acceptance.

Step 3, new:

- Its issues section explains what the preparatory step buys and why an uncalled
  definition is not the intermediate state Q04 rejected.
- Test first carries the report-contract cases; behavior specifies the formatter
  and reader without call sites; completion criteria include re-running the Step
  0 baseline to prove nothing observable changed.

Step 4, the former merged step:

- Rewritten as integration only, with the formatting bulk moved to Step 3 and
  the estimate reduced accordingly.
- Keeps the line-budget judgement, as the last step adding production code, with
  the estimate stated as advisory and never a gate.

Step 6:

- The blocked-evidence rule is rewritten to one lifecycle: collection completes
  with an overall verdict of `blocked`, the criterion is unsatisfied, the
  acceptance is not green, no implementation success is claimed, and the verdict
  is terminal. The contradictory "not complete while it stands" clause is gone,
  and the contradiction itself is named.
- Completion criteria state that the overall verdict says which outcome applies,
  and add the deferred exact-target confirmation when Step 0 ended
  `unavailable`.

Validation skeleton:

- Re-aligned to seven steps, with new Step 3 and Step 4 sections and the wiki
  and acceptance sections renumbered.
- Step 0's goal and expectations carry the structural change, the three-outcome
  gate and the rearrangement fact with its line numbers.
- Step 1's expectations carry the semantic oracle, the refuted provenance claim,
  and the fixed global container with its reason.
- Step 6's expectations carry the single blocked lifecycle and the deferred
  confirmation.

Open questions, replaced as a whole:

- Q01 and Q02 carried, with Q02 noting estimates are planning ranges not a gate.
  Q03 rewritten with the semantic oracle and gaining option 3E, size and
  single-mutation alone, recorded as refuted beside 3D. Q04 gaining option 4E,
  the single merged step, recorded as what this plan proposed last round, with
  4D restated to include the preparatory step. Q05 restated as a fixed global
  array with the three-outcome gate. Q06 rewritten to one lifecycle with the
  contradiction named. Q07 rewritten around the missing boundary, with the
  rearrangement and the post-source assertion in the option.
- Answers unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A.

### Writer response for plan relocation-force-rpath round 3

Writer response: All six requested changes are applied. Nothing is disputed.

Three findings share one cause and the writer would rather name it than repeat
the apology. In each case a property was asserted about a structure without being
checked against the structure. The single-mutation assertion was claimed to make
fixtures trustworthy without asking what it actually establishes. The guard
location was specified without opening the file to see whether such a location
exists. And blocked was given two lifecycle descriptions in adjacent sentences
without reading them together. All three were a minute's work to check, and the
Q07 one was a single `grep`.

The Q07 finding is the most embarrassing and the most useful. The plan told an
implementer to put a guard after every function definition and before the main
flow, in a script where two functions are defined after the main flow begins.
An implementer following that instruction would have discovered it immediately
and then had to decide, unaided, whether to move the functions or abandon the
seam. The plan now makes the rearrangement part of the step and adds the
post-source assertion, which is the part that matters beyond this instance: the
failure mode of a boundary is a function quietly left on the wrong side of it,
and a test that lists what must be defined catches that where a reader will not.

On Q03 the writer notes it has now proposed two insufficient oracles in
successive rounds, first trusting the accepted fixtures and then trusting a
provenance assertion. Both are recorded as options 3D and 3E rather than
replaced, because together they describe the two ways a fixture suite can look
rigorous and prove nothing, and the next person to write one will be tempted by
the same two.

The Q04 preparatory step is accepted and the writer had not seen it. The
question had been framed as a sequencing choice between two orderings, then as an
atomic merge, and in neither framing did the writer ask whether part of the work
was invisible to a deployment. The formatter and the reader are, so proving them
first costs nothing in coherence. That the merged step's prose claimed both test
surfaces preceded it while creating one inside it is the kind of internal
contradiction this plan has now produced twice.

Q05's fixed global container is accepted with the reasoning made explicit: Bash
cannot pass an associative array by value, so the alternative to a shared
container is a nameref, which is a second interpreter capability in a plan that
gates one. And the three-outcome gate corrects a real gap, since the writer's own
round 2 assessment flagged that the stop-and-revise rule covered a negative
answer but not an unobtainable one, and then did not fix it.

Four things are offered for round 3 rather than claimed as settled. Step 3's
no-observable-change argument rests on nothing calling the new functions, and
the completion criteria detect an emitted record but not a stray call site. The
golden manifest is a new hand-derived artifact that nothing cross-checks. The
`unavailable` branch defers confirmation to Step 6, which may itself be
unavailable, and the plan does not say whether that compounds. And the line
estimates now total 260 to 390 lines above the baseline across four steps, which
is worth a sanity read even though they are advisory.

### Reviewer focus for plan relocation-force-rpath round 3

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-08-17T10:33:52+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 3

Round 2's repairs are applied coherently. The seven-step skeleton matches the
plan, the Q07 seam now describes work the current script can actually perform,
and Q06 has one lifecycle meaning. Answers 1A, 2A, 3A, 4D, 5C, 6A, and 7A can
all stand. Round 3 is still `changes-requested`: one implementation placement
decision is missing, the provisional capability branch can currently bypass a
mandatory target gate, and two claimed proofs are not yet mechanically tied to
the properties they assert.

The missing decision is where the retained-output reader lives. The design
calls it the recipe's consumer of the external stream; it is validation code,
not something an installation invokes. Step 3 currently schedules both the
formatter and reader against `install_pkg.sh`, charges 80--120 production lines,
and then must argue neither is called. Put only the formatter in
`install_pkg.sh`; put the reader and malformed-capture constructors in
`verify.relocation-rpath.sh`. The harness can source and call the production
formatter over constructed dispositions, then pass its output to its local
reader. This keeps the two ends independent, removes an unnecessary shipped
parser, reduces the standalone file's measured growth, and makes a production
reader call site impossible. Add Q08 with this as option 8A; keeping both ends
in the installer and duplicating the reader should be the rejected alternatives.

Q04's preparatory step still needs a direct isolation assertion for the one
helper that does ship. Re-running the baseline proves no report was emitted; it
does not prove the formatter is unreachable, because a stray call can redirect
or discard its output. In Step 3, require a static harness assertion that the
formatter's identifier occurs in `install_pkg.sh` only at its definition and
that no production function body or main-flow line invokes it. Step 4 replaces
that step-scoped assertion with explicit expected call-site checks. The dynamic
baseline remains useful as a behavioral backstop, but it is not the proof of
the no-call-site property.

Q03's specification-derived manifest is a legitimate root oracle; it does not
need an infinite chain of oracle implementations. It does need to be auditable
rather than merely called golden. Each literal entry must record field name,
offset, width, byte order, original bytes, malformed replacement bytes, and an
exact ELF specification section/table citation. Before mutation, the harness
must show that a lawful `readelf`-validated base carries those original bytes at
that range; where a lawful alternate value exists, a second `readelf`-validated
fixture must show that changing the field changes that same range. The
generator and observer must not import constants from this validation table.
That does not make the specification infallible; it makes every hand-derived
calculation reviewable and cross-checks its anchor against the independent
tool wherever the format permits.

The serious lifecycle defect is between Q05 and Q06. Representative,
version-pinned RHEL/UBI evidence may justify implementing the associative-array
carrier while the exact target is inaccessible. It cannot satisfy the
requirement's real RHEL deployment acceptance. Q06's terminal `blocked` branch
is expressly for the monitoring observable after a real-target run; it is not
authority to omit the target run or the exact-target shell check. Step 6 must
therefore distinguish: exact-target `declare -A` support closes the provisional
debt; an executed unsupported result stops for plan revision; unavailable
target access leaves Step 6 incomplete and cannot be converted into Q06's
terminal monitoring block. Only after the real-target deployment and preload
measurement run may absent monitoring evidence yield the terminal `blocked`
verdict. The two unavailable conditions do not compound; the first prevents
the plan from reaching the second.

The 260--390-line planning range is not independently a blocker. Q02 already
discloses that the file may approach one thousand lines, makes estimates
advisory, and puts the decision at the measured Step 4 checkpoint. Moving the
reader to the harness should lower the production portion; recalculate the
per-file ranges rather than adding a new ceiling.

No other question is missing. Q08 is the only new plan-owned choice; the
manifest evidence belongs to Q03, isolation to Q04, and target-debt lifecycle
to Q05/Q06.

### Question verdicts for plan relocation-force-rpath round 3

1. **Q01 -- keep 1A.** The effort-local harness remains the correct boundary
   around the predecessor harness's retained digest and mirrored body.

2. **Q02 -- keep 2A.** Preserve the standalone installer and judge its measured
   size at Step 4. Recalculate the production estimate after moving validation
   reader code out; do not invent a numerical gate.

3. **Q03 -- keep and strengthen 3A.** Make the golden manifest literal and
   auditable: field, offset, width, byte order, before/after bytes, and exact
   specification citation per entry. Anchor each entry in a lawful base that
   `readelf` validates before mutation, using a lawful alternate-value pair
   where possible. Keep generator, observer, and manifest constants separate.
   Options 3D and 3E remain correctly rejected.

4. **Q04 -- keep 4D.** Step 3 must statically prove that the shipped formatter
   has no production call site, not infer that fact only from unchanged output.
   Step 4 replaces that temporary assertion with checks for the intended call
   sites and keeps behavior plus emission atomic.

5. **Q05 -- keep 5C with a bounded provisional branch.** Representative pinned
   evidence may allow Steps 1--5 to proceed. At Step 6, exact-target support
   must be confirmed; unsupported means revise, and unavailable target access
   leaves acceptance incomplete rather than becoming a monitoring block.

6. **Q06 -- keep 6A, narrowly.** Terminal `blocked` applies only when the real
   RHEL deployment and preload measurement ran but none of the three monitoring
   observables could be obtained. It cannot excuse an unavailable target or an
   unconfirmed shell capability.

7. **Q07 -- keep 7A.** The rearrangement, explicit boundary, guard, and
   post-source function assertions now form an executable and self-checking
   seam.

8. **Missing Q08 -- where the retained-output reader lives.** Add three options
   and choose 8A: the formatter ships in `install_pkg.sh`; the reader and
   malformed-capture constructors live only in `verify.relocation-rpath.sh`.
   Reject putting both ends in the installer because the reader is never used
   during deployment and expands both line budget and call surface. Reject a
   second copied reader because it permits the retained recipe and contract
   tests to disagree.

9. **Other missing questions.** None.

### Requested changes for plan relocation-force-rpath round 3

Requested changes: 1. Add and answer the missing reader-placement question, keeping the
   retained-output reader in the validation harness rather than the deployed
   installer.
2. Mechanically prove the Step 3 formatter has no production call site, then
   check the intended sites when Step 4 wires it.
3. Make every specification-derived manifest entry auditable and anchored to a
   lawful `readelf`-validated base.
4. Prevent unavailable real-target access from being collapsed into Q06's
   terminal monitoring-only blocked verdict.
5. Recalculate the production line estimate and align the seven validation
   sections with these changes.

### Writer instructions for plan relocation-force-rpath round 3

Revise the implementation plan and validation skeleton together, then publish
another automated plan-review round.

1. Keep decisions 1A, 2A, 3A, 4D, 5C, 6A, and 7A.
2. Add Q08 and choose 8A: production formatter in `install_pkg.sh`; the sole
   retained-output reader and malformed-capture constructors in
   `verify.relocation-rpath.sh`. Update Steps 3 and 4, file lists, complexity
   text, and per-file line estimates accordingly.
3. Under Q04 and Step 3, add a static assertion that the formatter has only its
   definition and no production call site. In Step 4 replace it with assertions
   for the intended call sites. Keep the Step 0 baseline as a separate dynamic
   backstop.
4. Under Q03 and Step 1, specify the manifest's literal fields and exact ELF
   specification citations. Cross-check each original byte range against a
   lawful `readelf`-validated base and use lawful alternate-value pairs where
   possible. State that generator and observer constants are not imported from
   the manifest.
5. Under Q05 and Step 6, define the end of the provisional capability branch:
   supported closes it; unsupported stops for revision; exact-target
   unavailability leaves acceptance incomplete. Do not report the latter as
   Q06's terminal monitoring block.
6. Narrow Q06 wording to the state reached after the real RHEL deployment and
   preload measurement succeeded but monitoring evidence could not be
   obtained. Reflect the same distinction in Step 6 completion criteria and the
   validation skeleton.
7. Recalculate advisory installer growth after the reader moves to the harness;
   retain the measured Step 4 checkpoint and add no line ceiling.

### Final reviewer decision for plan relocation-force-rpath round 3

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-08-17T10:45:04+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 4

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 4

### Requestor assessment for plan relocation-force-rpath round 4

Round 4. All five round 3 requested changes are applied, none disputed. Answers
1A, 2A, 3A, 4D, 5C, 6A, 7A stand, and Q08 is added and answered 8A.

**Q08 is a placement decision the plan never made.** Step 3 scheduled both ends
of the wire contract, the formatter and the retained-output reader, against
`install_pkg.sh`, and then had to argue that neither was called. One of those
arguments should never have been needed: the reader is the retained recipe's
consumer and never executes during an install. Shipping it would put a parser no
deployment runs into the one file whose size this effort is watching, and leave
a call surface to be argued away every round. The formatter now ships alone; the
reader and the malformed-capture constructors live in the harness. Two things
follow beyond the line count: a production reader call site becomes impossible
rather than merely unintended, and the round-trip becomes a check between two
independent ends rather than a file agreeing with itself.

**The lifecycle defect between Q05 and Q06 is the serious one.** Q05's
provisional branch let Steps 1 to 5 proceed on representative pinned evidence
when the exact RHEL target was unreachable. Q06 allowed a terminal `blocked`
verdict. Each was settled on its own, and nothing connected them, so nothing
stopped an unreachable target being reported as Q06's terminal blocked, which
would let the effort skip the real-target run entirely and still close. They do
not compound: an unreachable target leaves Step 6 **incomplete**, and terminal
blocked is reachable only after the real deployment and the preload measurement
ran and only the monitoring observable was missing. Step 6 now settles the
provisional debt in a three-outcome table, and Q06's entry condition is stated
rather than implied. Option 6D records the collapsed reading as rejected,
because that is what the plan had by omission.

The other three:

2. Step 3 now proves its own central claim. Re-running the Step 0 baseline shows
   no report was emitted, which is weaker than it looks, since a stray call whose
   output was redirected or discarded leaves the baseline unchanged. A static
   assertion now requires the formatter's identifier to occur in
   `install_pkg.sh` at its definition and nowhere else, with the reader's
   identifier absent entirely. Step 4 replaces it with checks for the intended
   call sites, so the property flips from "no caller" to "these callers" in the
   step that creates them. The baseline stays as a behavioral backstop.
3. The manifest is auditable rather than asserted. Every entry carries field,
   offset, width, byte order, original bytes, replacement bytes and an exact ELF
   specification citation, and two cross-checks anchor it outside itself: a
   lawful `readelf`-validated base must carry the stated original bytes at the
   stated range before mutation, and where a lawful alternate value exists a
   second validated fixture must differ at that same range and nowhere else.
   Generator and observer import no constants from it.
5. The estimates are recalculated. Step 3's production figure drops from 80 to
   120 lines to 40 to 60, and the running advisory total for `install_pkg.sh`
   falls from 260 to 390 above baseline to roughly 220 to 330. The saving lands
   entirely on the file that must ship; the harness absorbs the rest, where no
   constraint applies. No ceiling was added.

What round 4 should look at:

- The static no-call-site assertion is an identifier search, so it is only as
  good as the identifier being distinctive. A formatter named something that
  also appears in a comment or a message string would produce a false positive
  and, worse, a maintainer would then loosen the check.
- The manifest's alternate-value cross-check is available only for fields that
  have a lawful alternate. For the ones that do not, the citation and the base
  cross-check are the whole anchor, and the plan does not say which fields fall
  in which group.
- Step 6 now carries two independent debts that can each leave it incomplete,
  the exact-target capability confirmation and the real-target deployment run.
  They will in practice be settled by the same trip to the same machine, which
  the plan does not say, and if that is true the two entries could mislead a
  reader into planning two visits.
- Q08 splits the grammar's two ends across two files, so a future grammar change
  touches both. Nothing links them beyond the schema version, and the plan does
  not say whether the version bump is the intended coupling mechanism.

### Change summary for plan relocation-force-rpath round 4

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 3, applying round 3's five requested changes.

Step 3, the preparatory contract step:

- Fix intent now names the split: the formatter in `install_pkg.sh`, the reader
  in the harness, with the reason stated, that the reader never runs during an
  install and would otherwise add a shipped parser and a call surface to argue
  away.
- Framings gain a paragraph making the no-call-site property asserted rather
  than inferred, with the reason the baseline is insufficient: a redirected or
  discarded call leaves it unchanged.
- Complexity impact records that the reader leaves the installer entirely.
- The file list now names what each file receives: the formatter only, against
  the reader plus the malformed-capture constructors plus the cases.
- Behavior separates the two ends and states that nothing in the installer knows
  how to build a broken capture.
- Completion criteria gain the static assertion, the absence of the reader's
  identifier from the installer, and a restatement of the baseline as backstop
  rather than proof. The round-trip criterion now names production formatter to
  harness reader.
- The line budget drops from 80 to 120 to 40 to 60 for `install_pkg.sh`, with a
  note that the saving is on the shipped file rather than on total work.

Step 4, the atomic integration:

- Completion criteria gain the successor assertion, the formatter's identifier
  occurring at its definition and at exactly the named call sites, and that the
  reader is still absent from the installer.
- The line budget notes the Q08 move does not change this step's estimate and
  records the recalculated running total, roughly 220 to 330 above the 625-line
  baseline against 260 to 390 before.

Step 1, the fixture oracle:

- The manifest subsection is replaced. It now carries a seven-column table of
  what each entry records, field, offset, width, byte order, original bytes,
  replacement bytes and an exact specification citation, followed by the two
  cross-checks that anchor it: the lawful `readelf`-validated base carrying the
  stated original bytes at the stated range before mutation, and the lawful
  alternate-value pair differing at that range and nowhere else. It states that
  generator and observer import no constants from the manifest, with the reason.

Step 0, the capability gate:

- The `unavailable` row now says Steps 1 to 5 proceed **provisionally** and the
  confirmation becomes a debt due at Step 6.
- A paragraph states that the provisional branch is a loan rather than a waiver:
  representative evidence justifies writing the carrier and does not satisfy the
  requirement's real RHEL deployment acceptance.

Step 6:

- The blocked-evidence rule gains an entry condition: terminal blocked is
  reached only after the real deployment ran and the preload measurement
  succeeded with no monitoring observable obtainable. A paragraph states that
  the two unavailabilities do not compound, because the first prevents reaching
  the second, and that an unreachable target leaves the step incomplete.
- Completion criteria replace the single deferred-confirmation line with a
  three-outcome table: supported closes the branch, unsupported stops for plan
  revision, target still unavailable leaves the step incomplete and is expressly
  not the terminal blocked verdict.

Validation skeleton:

- Step 3's goal and expectations carry the two-file split with its reason, and
  the static assertion with the baseline demoted to backstop.
- Step 4's expectations carry the successor assertion and the property flip.
- Step 1's expectations carry the manifest's literal fields, its two
  cross-checks and the no-shared-constants rule.
- Step 6's expectations carry the three-outcome debt settlement, the statement
  that the two unavailabilities do not compound, and terminal blocked's entry
  condition.

Open questions, replaced as a whole:

- Q08 added with three options and answered 8A, with 8B, both ends in the
  installer, recorded as what the plan had by default rather than by decision,
  and 8C, a duplicated reader, rejected because two readers can disagree.
- Q06 gains option 6D, treating any unavailability as the same terminal verdict,
  recorded as the reading the plan had by omission.
- Q02, Q03, Q04 and Q05 restated with the round 3 refinements in their option
  text: the recalculated estimate, the auditable manifest, the static assertion,
  and the bounded provisional branch.
- Q01 and Q07 carried unchanged in substance.
- Answers now stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A.

### Writer response for plan relocation-force-rpath round 4

Writer response: All five requested changes are applied. Nothing is disputed.

Q08 is the finding the writer should have reached by following its own argument.
The plan had spent two rounds insisting that `install_pkg.sh` must ship
standalone and that its size is the effort's live constraint, and then scheduled
a parser that no install ever runs into that same file. The question the
constraint implies is not "how large may this grow" but "what actually has to be
in here", and the writer never asked it of the reader. The independence
consequence was invisible to the writer too: a formatter checked by a reader in
the same file proves the file agrees with itself, which is a materially weaker
statement than the two ends of a published grammar agreeing.

The Q05 and Q06 defect is a new kind for this exchange and worth naming as such.
Every earlier finding was inside one question. This one was between two, each
correct alone. Q05 said work may proceed provisionally when the target is
unreachable; Q06 said a terminal blocked verdict exists. Neither said anything
wrong, and together they permitted an effort that never reached the target to
close with a terminal verdict. The writer had even flagged, in the round 2
assessment, that the two unavailabilities might compound, and then answered its
own flag with a plan that let one impersonate the other. Recording option 6D is
deliberate: the collapsed reading was the plan's position by omission, and an
omission is easier to repeat than a rejected option.

The Step 3 assertion correction is accepted with the reasoning intact. The
writer's own round 3 assessment flagged that the completion criteria detect an
emitted record but not a stray call site, and then left the criteria as they
were. Flagging a gap and not closing it has now happened twice in this exchange,
and both times the reviewer closed it in the next round.

On the manifest the writer accepts that "specification-derived" was doing work
that "auditable" has to do instead. A hand-written table cited to nothing is
trusted for the same reason the previous two oracles were: it looks like
evidence. The citation makes each row's derivation checkable, and the base
cross-check ties it to a tool that never read it.

Four things are offered for round 4 rather than claimed as settled. The static
assertion is an identifier search and is only as good as the identifier being
distinctive, and a false positive would invite loosening the check. The
alternate-value cross-check is available only for fields with a lawful
alternate, and the plan does not say which fields those are. Step 6 now carries
two independent debts that will in practice be settled by one trip to one
machine, which the plan does not say. And Q08 splits the grammar across two
files with nothing linking them but the schema version, which the plan does not
name as the coupling mechanism.

### Reviewer focus for plan relocation-force-rpath round 4

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-08-17T11:15:04+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 4

Round 3's requested changes are applied coherently. Q08 now removes validation
code from the deployed script, the static Step 3/Step 4 property is present,
the manifest is auditable, and the target-unavailable state can no longer
impersonate Q06's monitoring-only block. Answers 1A, 2A, 3A, 4D, 5C, 6A, 7A,
and 8A can all stand. Round 4 is still `changes-requested` because the two-file
grammar has no independent contract anchor, and two flagged implementation
boundaries remain underspecified.

Q08 deliberately duplicates knowledge of `/1`: the production formatter knows
how to write it and the harness reader knows how to parse it. That duplication
is what gives the round-trip independence, but a round-trip alone proves only
that the two implementations agree. They can drift together while retaining
the same marker, just as the earlier generator and observer agreed about a
wrong ELF offset. The schema version is an identity, not an oracle. Add Q09 and
choose a literal contract corpus: committed textual canonical records and
trailers, plus malformed examples, written as test data rather than generated
from either end's vocabulary tables. The production formatter must match the
canonical bytes, and the reader must accept or reject the same literals. `/1`
stays frozen; any grammar change requires reviewed design/requirement change, a
new marker, and a new corpus. Sharing sourced constants or accepting a
round-trip alone should be recorded as rejected, because the first erases the
independence and conflicts with the standalone deployment, while the second
permits compatible wrongness.

Q04's identifier assertion is sound once its lexical boundary is specified.
Name the formatter now with one reserved, distinctive shell identifier, for
example `emit_cplx_elf_v1_record`, and make the check count that whole shell
word rather than an arbitrary substring. Forbid the exact identifier in
installer comments and message literals. Step 3 expects exactly the definition
occurrence; Step 4 expects the definition plus the explicitly enumerated call
occurrences. A false positive then fails loudly and is fixed by renaming prose,
not by weakening the assertion. This is test mechanics under 4D, not a new
question.

Q03's alternate-value condition must be resolved before implementation rather
than left as an implementer's judgement. Extend the fixture-oracle matrix so
every mutated field is assigned exactly one class: `readelf` direct;
manifest plus lawful-base and lawful-alternate pair; or manifest plus
lawful-base only. The last class must state why no lawful alternate exists in
the supported ELF64 little-endian x86-64 domain. Require zero unclassified
manifest entries. It is acceptable for a field genuinely to have no lawful
alternate: the exact specification citation and lawful-base anchor are then
the stated root oracle. The defect is not that this class exists, but that the
current plan does not identify its members.

The two RHEL debts should be one ordered acceptance session, not two planned
visits. Step 6 must create one run identity and record the exact target identity
and Bash version, then run the `declare -A` capability check before invoking the
installer. `unsupported` ends that session for plan revision; `supported`
closes the provisional debt and immediately permits the deployment and preload
measurement under the same run identity. Only after those succeed is the
monitoring-observable branch entered; evidence arriving later must name that
same run. If target access is unavailable, the session never reaches deployment
and remains incomplete. This makes Q05's debt settlement a prerequisite inside
Q06's real-target entry condition and prevents the plan text from suggesting
two machine visits.

The revised 220--330-line production estimate remains advisory and is not a
review blocker. Moving the reader out addressed the only scope error hidden by
the earlier total; Q02's measured Step 4 checkpoint remains sufficient.

No other question is missing. Add only Q09. The other changes are concrete
completion criteria under Q03 through Q06 and should be mirrored in the seven
validation sections.

### Question verdicts for plan relocation-force-rpath round 4

1. **Q01 -- keep 1A.** The separate effort harness remains the correct boundary
   around item 1's mirrored evidence.

2. **Q02 -- keep 2A.** Preserve the standalone installer and the measured Step
   4 checkpoint. The recalculated estimate needs no new ceiling.

3. **Q03 -- keep and strengthen 3A.** Classify every mutated field as
   `readelf` direct, manifest with lawful alternate, or manifest with lawful
   base only. Name the fields in each class, justify every base-only entry, and
   require zero unclassified manifest rows.

4. **Q04 -- keep 4D.** Reserve a distinctive whole-word formatter identifier
   and count it exactly: definition only in Step 3, definition plus named call
   sites in Step 4. Comments and messages may not contain that identifier.

5. **Q05 -- keep 5C.** Make exact-target capability confirmation the first gate
   in the same identified Step 6 RHEL session as deployment. Unsupported stops;
   supported closes the debt and continues; unavailable never reaches the run.

6. **Q06 -- keep 6A.** Enter the monitoring branch only after that session has
   confirmed capability and completed deployment plus preload measurement.
   Later monitoring evidence must identify the same validation run.

7. **Q07 -- keep 7A.** The source boundary and post-source assertions are now
   implementable and self-checking.

8. **Q08 -- keep 8A.** The formatter belongs in the installer and the sole
   reader plus malformed-input constructors belong in the harness.

9. **Missing Q09 -- how the independent grammar ends remain bound to `/1`.**
   Add and choose 9A: literal canonical and malformed contract vectors in the
   harness, independent of both implementations; compare formatter bytes to
   them and feed the same literals to the reader. Freeze `/1`, requiring a
   reviewed new marker and corpus for any grammar change. Reject shared sourced
   constants and round-trip-only validation.

10. **Other missing questions.** None.

### Requested changes for plan relocation-force-rpath round 4

Requested changes: 1. Add Q09 and bind the independent formatter and reader to a literal frozen
   `/1` contract corpus rather than to round-trip agreement alone.
2. Make the formatter call-site assertion whole-word and deterministic by
   reserving a distinctive identifier and enumerating its expected occurrences.
3. Classify every mutated fixture field by the semantic-oracle evidence it has,
   including explicit justification for fields with no lawful alternate.
4. Combine capability confirmation, deployment, and preload measurement into
   one ordered, identified RHEL acceptance session before monitoring is judged.
5. Apply the same completion evidence to the seven-section validation skeleton.

### Writer instructions for plan relocation-force-rpath round 4

Revise the implementation plan and validation skeleton together, then publish
another automated plan-review round.

1. Keep decisions 1A, 2A, 3A, 4D, 5C, 6A, 7A, and 8A.
2. Add Q09 and choose 9A: one literal `/1` contract corpus in the harness,
   authored independently of formatter and reader tables. Compare production
   formatter output byte-for-byte with its canonical vectors and feed those
   same vectors plus literal malformed forms to the reader. State that `/1` is
   frozen and grammar changes require reviewed authority, a new marker, and a
   new corpus.
3. Under Q04, reserve a distinctive formatter name such as
   `emit_cplx_elf_v1_record`. Make Step 3's assertion count that whole shell
   word at the definition only; Step 4 counts the definition and every named
   intended call site. Keep the identifier out of comments and messages rather
   than loosening the check on a false positive.
4. Under Q03, extend the fixture matrix with an exhaustive oracle-class column:
   `readelf` direct, manifest plus lawful alternate, or manifest plus lawful
   base only. Enumerate every mutated field, justify every base-only row, and
   require zero unclassified manifest entries in the completion criteria.
5. Under Q05/Q06 and Step 6, define one identified RHEL acceptance session:
   record target identity and Bash version; run the exact-target capability
   check first; on support continue immediately to deployment and preload
   measurement under the same run identity; only then enter the monitoring
   branch. Tie later monitoring evidence to that run. Unsupported stops for
   revision and unavailable access leaves the session incomplete.
6. Mirror the contract corpus, exhaustive manifest classification, exact
   identifier checks, and ordered RHEL session in the validation skeleton.
7. Keep the revised production estimate advisory and the measured Step 4
   checkpoint unchanged.

### Final reviewer decision for plan relocation-force-rpath round 4

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-4 -->

## Round 5 by requestor

- Recorded: 2026-08-17T11:47:55+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 5

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 5

### Requestor assessment for plan relocation-force-rpath round 5

Round 5. All five round 4 requested changes are applied, none disputed. Answers
1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A stand, and Q09 is added and answered 9A.

**Q09 is Q08's unfinished half.** Splitting the `CPLX-ELF/1` grammar across two
files made the two ends independent, and the plan treated that independence as
if it were an oracle. It is not. A round-trip is satisfied by any pair of
implementations that are wrong in the same way, and two ends written by the same
hand from the same reading of the same design are exactly such a pair; the `/1`
marker travels with them unchanged. This plan has already produced that failure
once, between the fixture generator and the observer agreeing about a wrong
offset. Both ends are now bound to a literal contract corpus,
`docs/v0.27.0/contract.cplx-elf-1.txt`: canonical records and trailers written
out byte for byte across every wire token and the closed pairs, plus one
malformed example per rejected form, authored by hand from the design's grammar,
generated from neither end's tables and sourced as constants by neither. The
formatter is compared byte for byte against the canonical vectors; the same
literals go to the reader. `/1` is frozen, so a grammar change needs reviewed
authority, a new marker and a new corpus rather than a quiet redefinition behind
the same token.

**Q03's base-only class was mislabelled as a weakness.** The plan had recorded
the missing lawful alternate as a con to be tolerated, which left the actual
evidentiary strength of each manifest row undetermined until implementation. A
field whose domain contains one lawful value has its citation and its lawful base
as a complete root oracle. What was defective was not naming its members. Every
mutated field now carries exactly one of three classes: `readelf` direct for
`e_ident[EI_CLASS]`, `e_ident[EI_DATA]`, `e_machine`, `e_type`, `e_phnum` and the
tag; manifest with a lawful-alternate pair for `e_phoff`, `p_offset` and
`p_filesz`; manifest with a lawful base only for `e_phentsize`, fixed at 56 by
ELF64, the dynamic entry size, fixed at 16, and `DT_NULL` termination, whose
presence is the only lawful state. Zero unclassified entries, and the choice is
made in the plan rather than silently per field by whoever implements it.

The other three:

2. The call-site assertion has a lexical boundary. The formatter is named
   `emit_cplx_elf_v1_record`, reserved and distinctive, counted as a whole shell
   word rather than as a substring, and forbidden in installer comments and
   message literals. Step 3 expects exactly the definition; Step 4 expects the
   definition plus each enumerated call site. A false positive is therefore a
   real collision, fixed by renaming the prose, which closes the drift the
   previous wording invited, where the natural repair for a noisy search is to
   weaken it.
4. Step 6 describes one ordered acceptance session rather than two debts. It
   opens by recording a run identity, the exact target identity and its Bash
   version; runs the `declare -A` check before the installer is invoked at all,
   where `unsupported` ends the session with nothing deployed and `supported`
   closes the Step 0 provisional debt and continues immediately; deploys and
   measures preload under the same run identity; and only then judges
   monitoring. Unavailable access never reaches the capability check, so the
   session never opened and no verdict of either kind is due. Late monitoring
   evidence must name that same run identity.
5. The same completion evidence is mirrored across the seven validation
   sections: the oracle classification in Step 1, the corpus and the whole-word
   identifier in Step 3, the successor assertion and the corpus against real
   captures in Step 4, and the ordered session with its run identity in Step 6.

What round 5 should look at:

- The plan requires the formatter to match the corpus and does not say what
  happens when it does not. Two different faults share that symptom, a wrong
  formatter and a mistyped vector, and the cheap resolution when a suite goes red
  is to edit the vector, which turns the corpus into a transcript of the
  formatter's behavior. The design's grammar is the tie-breaker in principle and
  the plan does not say to consult it.
- The corpus covers one "representative" encoded path. That word is carrying
  weight it has not earned: the path is the only field derived from runtime input
  rather than from a closed vocabulary, so one canonical example fixes the
  encoding for one input and leaves non-printable bytes, an empty relative
  remainder and any length-sensitive behavior outside the corpus entirely.

### Change summary for plan relocation-force-rpath round 5

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 4, applying round 4's five requested changes.

Step 1, the fixture oracle:

- A twelve-row oracle-class table is added after the manifest's column table,
  assigning every mutated field exactly one class. `readelf` direct covers
  `e_ident[EI_CLASS]`, `e_ident[EI_DATA]`, `e_machine`, `e_type`, `e_phnum` and
  the `DT_RPATH` against `DT_RUNPATH` tag. Manifest with a lawful-alternate pair
  covers `e_phoff`, `p_offset` and `p_filesz`. Manifest with a lawful base only
  covers `e_phentsize`, fixed at 56 by ELF64, the dynamic entry size, fixed at
  16, and `DT_NULL` termination, whose presence is the only lawful state.
- A paragraph states that the base-only class is legitimate, that its members
  are named rather than discovered, and that for each the citation and the
  lawful base are the whole root oracle. It records that the defect being fixed
  was not the class existing but its members being unnamed.
- The classification is stated to be settled in the plan rather than by the
  implementer, with the reason: "use a lawful alternate where one exists" would
  otherwise be decided silently and differently per field.
- Completion criteria now require every fixture to name its oracle class as one
  of the three, zero unclassified manifest entries, and a recorded reason on
  every base-only entry.

Step 3, the preparatory contract step:

- A new subsection, "Step 3 contract corpus", states why the two-file split is
  not sufficient on its own: a round-trip shows the two implementations agree
  and cannot show they are right, two ends written by the same hand can drift
  together while still carrying the marker, and this is the same failure already
  met between the fixture generator and the observer. The schema version is
  named an identity, not an oracle.
- The corpus is defined: canonical `obj` records and `end` trailers written byte
  for byte covering every wire token, the closed `state` and `reason` pairs and
  a representative encoded path, plus one malformed example per rejected form.
  It is authored by hand from the design's grammar, not generated from either
  end's vocabulary tables, and sourced as constants by neither, with the reason
  that a corpus derived from the formatter would agree with it by construction.
- The formatter's output is compared byte for byte against the canonical
  vectors, and the same literals, canonical and malformed, go to the reader.
- `/1` is frozen: a grammar change needs reviewed authority in the design or the
  requirement, a new marker, and a new corpus alongside the old one.
- The file list gains `docs/v0.27.0/contract.cplx-elf-1.txt` as new, described
  as committed test data read by the cases and sourced by neither end.
- Completion criteria lead with the byte-for-byte corpus match and the reader
  accepting and rejecting the same literals, and state that the round-trip is
  still checked but that it is the corpus that makes agreement mean correctness.

Step 3 and Step 4, the call-site assertion:

- The formatter is named: `emit_cplx_elf_v1_record`, reserved and distinctive.
- Step 3's criterion now reads that the identifier occurs in `install_pkg.sh`
  exactly once, **as a whole shell word**, at its definition, and appears in no
  comment or message literal.
- Step 4's successor criterion reads that the whole shell word occurs at its
  definition and at exactly the call sites that step enumerates, each named,
  still in no comment or message literal.
- Step 4 gains a criterion that the contract corpus still passes unchanged, now
  against captures a real run produced rather than constructed dispositions.

Step 6, the RHEL acceptance session:

- A new subsection, "Step 6 RHEL acceptance session", replaces two separately
  listed debts with one ordered session, and says so explicitly, with the
  reason: two listed debts read as two trips to be arranged, and they are the
  same trip. The four steps are: open and record the run identity, the exact
  target identity and its Bash version; run the `declare -A` check on that
  target before the installer is invoked, where `unsupported` ends the session
  for revision with nothing deployed and `supported` closes the Step 0
  provisional debt and continues immediately; deploy and measure preload under
  the same run identity; and only then judge monitoring.
- Unavailable access never reaches step 2, so the session never opened, Step 6
  is incomplete, and no capability verdict and no monitoring verdict are due.
- The subsection states that ordering the capability check first is what makes
  Q05's debt a prerequisite inside Q06's entry condition rather than a parallel
  item settled elsewhere.
- Completion criteria now require the session to have run in its stated order
  with its recorded identities, restate the three outcomes with the
  target-unavailable row saying the session never opened, and add that any
  monitoring evidence arriving afterwards names that same run identity so a
  later answer cannot be attached to a run it did not describe.

Validation skeleton:

- Step 1's expectations carry the exhaustive oracle classification, the named
  base-only members with their reasons, and the statement that the class is
  assigned in the plan rather than left to the implementer.
- Step 3's expectations carry the contract corpus with its file name, the reason
  a round-trip is insufficient, the hand-authored and unshared-constants rules,
  the byte-for-byte comparison, the frozen `/1`, and the whole-word identifier
  assertion with the rename-the-prose rule.
- Step 4's expectations carry the whole-word successor assertion, the enumerated
  call sites, and the corpus passing against real captures.
- Step 6's expectations carry the ordered session with its run identity, the
  capability gate as the first gate, the three outcomes with the session never
  opening on unavailable access, the run-identity binding for late monitoring
  evidence, and terminal blocked's entry condition now including the supported
  capability result.

Open questions, replaced as a whole:

- Q09 added with four options and answered 9A. Option 9B, the round-trip alone,
  is recorded as the plan's position by default and as the same shape as the
  refuted generator-and-observer agreement. Option 9C, shared sourced constants,
  is rejected for destroying the independence and putting a harness artifact on
  the deployment path. Option 9D, extracting the grammar from the design at test
  time, is rejected for making prose formatting a test dependency and creating a
  third implementation with no oracle.
- Q03's option 3A carries the exhaustive oracle-class requirement and two new
  pros: classification in the plan replacing a silent per-implementer judgement,
  and the base-only class being legitimate rather than weak.
- Q04's option 4D carries the reserved identifier, the whole-word count, the
  comment and message-literal prohibition and the per-step expected counts, with
  a new pro on why a false positive is fixed by renaming prose.
- Q05's option 5C makes the debt settlement the first gate of the single
  identified session, before the installer is invoked.
- Q06's option 6A adds the supported capability gate to terminal blocked's entry
  condition and the run-identity binding for late monitoring evidence.
- Answers now stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A.

Unchanged: the advisory 220 to 330 line estimate and the measured Step 4
checkpoint, per round 4's item 7.

### Writer response for plan relocation-force-rpath round 5

Writer response: All five requested changes are applied. Nothing is disputed.

Round 4's four findings are the four items the round 3 response listed as
offered rather than settled. That is worth stating plainly rather than treating
as a good outcome: the writer knew the identifier had no lexical boundary, knew
the alternate-value anchor was unavailable for some unnamed set of fields, knew
Step 6 described two visits that would be one trip, and knew nothing but the
schema version linked the two grammar ends. It handed all four to the reviewer
and published anyway. Flagging a gap is not closing it, and this is now the
third round in which the reviewer has closed something the writer had already
seen. The correct behavior was to spend the round fixing them, and the honest
description of what happened instead is that naming a defect felt like enough.

Q09 is the more interesting one, because it is the same mistake in a third
costume. Round 2 refuted "the accepted fixtures will catch a shared mistake",
because a generator and an observer with the same wrong offset agree. Round 3
refuted "a single mutation proves the byte's meaning", because provenance is not
semantics. Round 4 refutes "the two ends round-trip, therefore the grammar is
right", because agreement between two implementations of the same reading is not
correctness. Each time the writer built a check whose passing condition was
mutual consistency and then read it as truth. Q08's independence argument made
this harder to see, not easier: having correctly argued that a formatter checked
by a reader in the same file only proves the file agrees with itself, the writer
stopped one step short and did not ask what the two separated ends were being
measured against. Independence removes one way of being trivially self-consistent
and supplies no oracle. The corpus is the oracle, and freezing `/1` is what keeps
it one over time.

The Q03 correction is accepted without reservation, and the reviewer's framing is
better than the writer's. The writer had recorded the missing alternate as a con,
a weakness of option 3A to be tolerated. It is not a weakness. A field whose
domain contains exactly one lawful value has a citation and a lawful base as its
whole root oracle, and that is a complete answer. What was defective was leaving
the membership of that class undetermined, so that each row's actual evidentiary
strength was unknown until someone implemented it. Naming `e_phentsize`, the
dynamic entry size and `DT_NULL` termination turns an unbounded caveat into three
justified rows.

Q05 and Q06 needed the fix the reviewer made, not the one the writer made. Round
3 gave the provisional branch a closing condition and left it beside the
deployment; round 4 puts it in front, as the session's first gate. Ordering was
the missing property, and its absence had a practical cost the writer never
priced: an unsupported result discovered after deployment would have been found
by exercising a carrier already known not to exist. The run identity is the part
the writer would not have reached at all. A blocked record that cannot name the
run it describes lets a later deployment's observable certify an earlier one.

Two things are offered for round 5 rather than claimed as settled, and this time
they are offered because the writer has looked for the answer and does not have
one, not as a substitute for doing the work.

The corpus is hand-authored, which is the whole point, and hand-authored bytes
can be mistyped. The plan says the formatter must match the corpus and does not
say what happens on a mismatch. There are two very different mismatches behind
one symptom: the formatter is wrong, or the vector is. Nothing in the plan
distinguishes them, and the tempting resolution when a suite goes red is to edit
the vector, which silently converts the corpus into a transcript of whatever the
formatter does. The design's grammar section is the tie-breaker in principle, and
the plan does not say to consult it.

The corpus covers every wire token, the closed pairs, and one representative
encoded path. "Representative" is doing unexamined work. The path encoding is the
one field whose value is derived from `$DEST_PATH` at runtime rather than drawn
from a closed vocabulary, so a single canonical example fixes the encoding for
one input and leaves the interesting inputs, a path containing a byte that is not
printable ASCII, an empty relative remainder, a path at the length where a
formatter might wrap, untested by the corpus and reachable only through the
constructed dispositions the corpus exists to backstop.

### Reviewer focus for plan relocation-force-rpath round 5

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-5 -->

## Round 5 by reviewer

- Recorded: 2026-08-17T12:57:34+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 5

Round 4's requested changes are applied coherently. The corpus is now an
independent third anchor, the formatter identifier check is deterministic, the
RHEL debts form one ordered session, and every row in the current Q03 table has
an assigned oracle class. Answers 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A can
all stand. Round 5 remains `changes-requested`: Q09 does not yet say which
artifact wins when its three independent parties disagree, its sole encoded
path vector is too weak for the only runtime-derived field, and Q03's claimed
exhaustive unit is not actually the unit that the fixtures mutate.

Q09 correctly prevents formatter and reader from proving only that they agree
with each other. It must now prevent a failing comparison from turning the
corpus into a transcript of either implementation. State an authority and an
adjudication rule. The reviewed `/1` design is semantic authority; the literal
corpus is the frozen executable witness established from it before formatter
work; formatter and reader are implementations. Record the corpus's exact
bytes (for example by Git blob id or a validation-only digest) in Step 3
evidence before comparing either implementation. On a mismatch: fix an
implementation when the corpus agrees with an unambiguous design clause;
correct a mistyped corpus in an isolated corpus-only change that cites that
clause and establishes new frozen bytes before changing an implementation; or
stop and reopen reviewed design when design and corpus cannot be adjudicated
unambiguously. Do not edit corpus and implementation together merely to make a
test green, and do not change `/1` semantics in place.

The path portion of that corpus needs a byte-oriented matrix, not one
representative example. Include independently authored raw input and exact
lowercase-hex output for at least: a simple relative path; a multi-component
path proving the base is `$DEST_PATH`; delimiter-looking bytes such as space,
newline, and `=`; a non-UTF-8 byte; a shortest non-empty path; and a path long
enough for the selected `od` invocation to wrap its textual output. Keep empty
`path=`, decoded absolute paths, and decoded `./` paths as rejected forms. The
raw byte recipes must not come from the production formatter, and the expected
hex must be literal corpus data. This exercises encoding, output normalization,
root-relative derivation, and reader validation independently.

Q03's 12-row table classifies labels called mutated fields, but two rows are
not stored ELF fields. `Elf64_Dyn` consists of `d_tag` and `d_un`; its 16-byte
size in this domain follows from that fixed layout. `DT_NULL` is a `d_tag`
value that terminates the entry sequence. The LSB dynamic-section definition
and Linux `elf(5)` both describe that structure and terminator:
https://refspecs.linuxfoundation.org/LSB_5.0.0/LSB-Core-generic/LSB-Core-generic/dynamicsection.html
and https://man7.org/linux/man-pages/man5/elf.5.html. A fixture for a bad
dynamic-entry extent therefore has to mutate an actual carrier such as
`PT_DYNAMIC.p_filesz` or truncate the file; a missing terminator has to replace
the terminator's `d_tag`, shorten the segment, or alter its extent. Those
operations can reuse a stored field already listed in another row, so
"every mutated field exactly once" both double-counts concepts and prevents
the table from describing the real fixtures.

Keep 3A, but make the exhaustive unit each malformed fixture or rejection
guard. For every fixture, name the reader guard, the exact carrier mutation(s)
or file operation, the semantic oracle and citation, whether a lawful alternate
exists, and the expected normalized tuple. Require zero unclassified fixtures
and zero unexercised rejection guards. A carrier such as `p_filesz` or `d_tag`
may correctly occur in multiple rows when different mutations prove different
rules. This preserves the intended oracle architecture while making the
constructed bytes auditable.

No new question is required. These are implementability corrections under Q03
and Q09. Mirror both in the validation skeleton and publish another plan-review
round.

### Question verdicts for plan relocation-force-rpath round 5

1. **Q01 -- keep 1A.** The separate effort harness remains the correct boundary
   around item 1's mirrored evidence.

2. **Q02 -- keep 2A.** Preserve the standalone installer and its measured Step
   4 checkpoint.

3. **Q03 -- keep and strengthen 3A.** Make fixtures or rejection guards, not
   nominal field names, the exhaustive rows. Each row must identify the actual
   stored-byte mutation or file operation, reader guard, semantic oracle,
   lawful-alternate status, and expected tuple. Treat dynamic-entry sizing and
   `DT_NULL` termination as invariants over actual carriers, and require zero
   unclassified fixtures and zero unexercised rejection guards.

4. **Q04 -- keep 4D.** The reserved whole-word formatter identifier and its
   Step 3/Step 4 occurrence counts are now specific and testable.

5. **Q05 -- keep 5C.** Exact-target capability confirmation remains the first
   gate in the identified Step 6 RHEL session.

6. **Q06 -- keep 6A.** Deployment and preload measurement must precede the
   monitoring judgment within that same session; unavailable access remains
   incomplete rather than blocked.

7. **Q07 -- keep 7A.** The sourced/executed boundary remains self-checking.

8. **Q08 -- keep 8A.** Ship only the formatter; keep the reader and malformed
   capture constructors in the independent harness.

9. **Q09 -- keep and strengthen 9A.** Make reviewed design the semantic
   authority and freeze the independently authored corpus before implementation
   comparison. Specify mismatch adjudication without simultaneous corpus and
   implementation edits. Expand `path` vectors across root-relative derivation,
   delimiter-looking and non-UTF-8 bytes, shortest input, and `od` wrapping,
   with literal expected hex and explicit rejected forms.

10. **Other missing questions.** None.

### Requested changes for plan relocation-force-rpath round 5

Requested changes: 1. Replace Q03's nominal-field exhaustiveness with fixture/guard exhaustiveness
   that names every actual carrier mutation or truncation, especially for
   dynamic-entry sizing and `DT_NULL` termination.
2. Give Q09 a design/corpus/implementation authority order and a mismatch
   adjudication procedure that cannot silently rewrite the corpus to match an
   implementation.
3. Expand `path` coverage from one example to independent byte vectors covering
   root-relative derivation, hostile/raw bytes, minimal input, and `od` output
   wrapping, with literal expected hex and rejected forms.
4. Apply the same evidence and completion rules to the validation skeleton.

### Writer instructions for plan relocation-force-rpath round 5

Revise the implementation plan and validation skeleton together, then publish
another automated plan-review round.

1. Keep decisions 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A.
2. Under Q03, replace the assertion that each mutated field appears exactly
   once with an exhaustive fixture/rejection-guard matrix. For every row name
   the reader rule, exact stored-field mutation(s) or file operation, semantic
   oracle and citation, lawful-alternate status, and expected normalized tuple.
   Recast bad dynamic-entry sizing through its real carrier (for example
   `PT_DYNAMIC.p_filesz` or truncation), and state exactly how the missing
   `DT_NULL` fixture alters a `d_tag`, segment extent, or file extent. Permit
   one carrier field to serve multiple distinct fixture rules. Require zero
   unclassified fixtures and zero unexercised rejection guards.
3. Under Q09, establish the reviewed `/1` design as semantic authority and the
   independently authored corpus as its frozen executable witness. Freeze and
   record the corpus bytes before formatter/reader comparison. Specify that a
   mismatch fixes an implementation when corpus and unambiguous design agree;
   fixes a corpus typo only in an isolated corpus-only change citing the design
   clause and re-freezing the bytes before implementation changes; and stops
   for reviewed design amendment when authority is ambiguous. Forbid editing
   corpus and implementation together simply to obtain agreement, and retain
   the rule that `/1` semantics cannot change in place.
4. Replace the one representative path vector with an independently authored
   byte matrix covering a simple path, a `$DEST_PATH`-relative multi-component
   path, space/newline/`=` bytes, a non-UTF-8 byte, a shortest non-empty path,
   and an input long enough to cross the actual `od` output-wrap boundary.
   Store literal lowercase expected hex for each. Keep empty, decoded absolute,
   and decoded `./` paths among the rejected forms. Neither production end may
   generate the raw vector recipes or their expected hex.
5. Mirror the revised fixture matrix, corpus-authority adjudication, corpus
   freeze evidence, and path-vector matrix in the validation skeleton.
6. Preserve the reserved formatter identifier, contract-corpus separation,
   measured line checkpoint, and ordered Step 6 RHEL session already added.

### Final reviewer decision for plan relocation-force-rpath round 5

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-5 -->

## Round 6 by requestor

- Recorded: 2026-08-17T15:00:07+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 6

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 6

### Requestor assessment for plan relocation-force-rpath round 6

Round 6. Both round 5 requested corrections are applied, neither disputed. No
question is added. Answers stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A.

**Q03's exhaustiveness was counting the wrong thing.** The previous matrix
claimed every mutated field was classified exactly once, and two of its rows
were not stored ELF fields. `Elf64_Dyn` consists of `d_tag` and `d_un`, so the
sixteen-byte entry size in this domain follows from that fixed layout rather
than from any field a fixture can write, and `DT_NULL` is a `d_tag` value that
terminates the entry sequence. Both are stated in the LSB dynamic-section
definition and in Linux `elf(5)`, now cited in the plan with links. A real
bad-extent fixture therefore mutates `PT_DYNAMIC`'s `p_filesz` or the file's
length, and a real missing-terminator fixture rewrites the terminating entry's
`d_tag`. Those reuse carriers other rows already name, so the old rule did not
merely mislabel: it forbade the table from describing the fixtures a correct
suite needs.

The exhaustive unit is now **each fixture and each rejection guard**, in three
tables split by outcome: nine accepted shapes, two ambiguous shapes recorded as
successful observations, and twelve rejected shapes all yielding
`structural_status: inconclusive` with every other field cleared and both probes
`blocked`. Every row names the guard exercised, the exact carrier mutation with
offset and width or the file operation, the semantic oracle with its citation,
the lawful-alternate status with a reason where it is "no" or "not applicable",
and the expected tuple. One carrier may appear in several rows when different
mutations prove different rules, which is the normal case: `d_tag` proves tag
identity in four rows and non-termination in a fifth, `p_filesz` proves a bounds
violation in one row and a non-integral entry count in another.

**The new criterion found work on its first application**, which is the argument
for it. Requiring zero unexercised rejection guards showed that the
identification guard has four parts and only class and encoding were tested, so
bad magic and a wrong `e_ident[EI_VERSION]` had no fixture; and requiring every
design-defined `elf_kind` value to be produced showed that nothing yielded
`unsupported`. Three fixtures are added for those. Counting fields could not
have surfaced a missing fixture at all.

**Q09 had an independent corpus and no rule for defending it.** Independence
stops the two implementations proving only that they agree with each other; it
does nothing about a failing comparison being resolved by editing the corpus,
after which the corpus is a transcript of the formatter and the independence is
gone without anyone having decided to give it up. The artifacts are now ranked:
the reviewed `/1` design is semantic authority, the corpus is its frozen
executable witness established before any formatter work, and the two ends are
implementations, presumed wrong when a comparison fails. The corpus's exact
bytes are recorded as evidence, by Git blob id or validation-only digest, before
either implementation is compared against it. A mismatch takes one of three
paths, chosen by reading the design rather than by which edit is smaller: fix
the implementation; correct a genuine typo in an isolated corpus-only change
citing the clause and re-freezing the bytes first; or stop for reviewed design
amendment when the clause is silent or admits both readings. Changing corpus and
implementation in one commit is forbidden outright, because the result is
indistinguishable from the first case resolved the wrong way.

**The `path` matrix replaces one example with seven vectors**, each carrying raw
input and literal lowercase expected hex, authored by neither production end:
`lib/foo.so` as `6c69622f666f6f2e736f`, which is the design's own sample value;
an object at `$DEST_PATH/usr/lib/libz.so.1` as `7573722f6c69622f6c69627a2e736f2e31`,
proving the encoded value is the remainder rather than the absolute path; `a b=c`
plus a newline as `6120623d630a` for the three delimiter-looking bytes, all
lawful in a Linux filename; `x`, `0xff`, `.so` as `78ff2e736f`, since a filename
is a byte string and any encoder that decodes to text first fails here; `a` as
`61` for the shortest non-empty input; and an adjacent pair at and just past the
`od` output wrap boundary, where a wrapping defect shows and nowhere else. That
boundary is measured against the shipped tool and recorded, not assumed; sixteen
is stated as the expected GNU figure to confirm rather than to trust. Empty,
non-hex, decoded absolute and decoded `./` values remain rejected forms.

Both are mirrored in the validation skeleton, and Step 3's completion criteria
now require the recorded freeze and the measured wrap width before any
comparison, the full matrix with its boundary pair, and every mismatch resolved
during the step to record which adjudication path was taken with the design
clause cited.

What round 6 should look at:

- The freeze proves the corpus bytes have not moved since they were recorded. It
  does not prove they were right when recorded, and the adjudication rule
  presumes any later divergence is an implementation defect or a typo. That the
  design is the authority a reviewer could read the corpus against is only an
  answer if someone is required to, and no completion criterion requires it. A
  corpus-to-design derivation review as an explicit gate before the freeze may
  be the missing step, or the freeze evidence may simply need to stop reading as
  though it establishes correctness rather than stability.

### Change summary for plan relocation-force-rpath round 6

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 5, applying round 5's four requested changes.

Step 1, the fixture oracle, Q03:

- The 12-row field table is removed and replaced by a fixture-and-guard matrix.
  A new subsection, "The exhaustive unit is the fixture, not the field name",
  states why: `Elf64_Dyn` consists of `d_tag` and `d_un`, so the sixteen-byte
  entry size follows from that layout rather than from a stored field, and
  `DT_NULL` is a `d_tag` value terminating the sequence rather than a separate
  item. Both are cited to the LSB dynamic-section definition and Linux `elf(5)`,
  with links.
- The consequence is stated: a bad dynamic extent must mutate `PT_DYNAMIC`'s
  `p_filesz` or the file's length, and a missing terminator must rewrite the
  terminating entry's `d_tag` or shorten the segment or file. Those reuse
  carriers other rows already name, so "each field exactly once" both counted
  concepts as fields and forbade the table from describing the real fixtures.
- One carrier appearing in several rows is stated to be the normal case, with
  the two examples: `d_tag` proving tag identity in four rows and
  non-termination in a fifth, `p_filesz` proving a bounds violation in one row
  and a non-integral entry count in another.
- Three tables replace the old one, split by outcome. Every row names the reader
  guard exercised, the exact carrier mutation or file operation with offset and
  width, the semantic oracle with its citation, the lawful-alternate status, and
  the expected tuple:
  - accepted shapes, nine rows: ordinary `ET_EXEC`, PIE, shared library, no
    `PT_DYNAMIC`, dynamic with no search-path tag, `DT_RPATH` only, `DT_RUNPATH`
    only, `e_phnum == 0`, and a new `ET_REL` relocatable object;
  - ambiguous shapes, two rows, both recorded as successful observations rather
    than rejections;
  - rejected shapes, twelve rows, all yielding `structural_status:
    inconclusive` with every other field cleared and both probes `blocked`.
- Two tuple conventions are stated once above the tables: inconclusive rows give
  the status alone because the design clears the rest, and probe statuses appear
  only where structure fixes them.
- The `readelf` direct, manifest-plus-alternate and manifest-plus-base-only
  distinction survives as the lawful-alternate column. Rows whose status is "no"
  or "not applicable" carry their reason: `\x7fELF` and `EV_CURRENT` are the
  only lawful values for their fields, 56 is the only lawful `e_phentsize`, and
  the file-operation and invariant rows have no stored field to vary.
- The manifest's seven-column entry table is unchanged and is now described as
  carrying one entry per mutation, with the matrix as the index saying which
  mutations exist and why.
- Three fixtures are added because the new completion criterion found them: bad
  magic and a wrong `e_ident[EI_VERSION]`, since the identification guard has
  four parts and only two were exercised, and the `ET_REL` object, since no
  fixture produced `elf_kind: unsupported`. The plan records that the criterion
  found them rather than inspection.
- The Step 1 test-first fixture list gains those three and renames "a bad
  dynamic entry size" to "a `PT_DYNAMIC` extent that is not a whole number of
  entries".
- Completion criteria now require every fixture to name its guard, mutation,
  oracle, alternate status and tuple; zero unclassified fixtures and zero
  unexercised rejection guards, counting the identification guard's four parts
  separately; a recorded reason on every "no" or "not applicable" row; and every
  design-defined `elf_kind` and `tag_state` value produced by some fixture.

Step 3, the contract corpus, Q09:

- A new subsection, "Authority order, and what happens when the three disagree",
  states why independence alone is insufficient: nothing stopped a red suite
  being made green by editing the corpus, which would turn it into a transcript
  of the formatter. A three-row rank table follows: the reviewed `/1` design is
  semantic authority; the corpus is its frozen executable witness established
  before any formatter work; the formatter and reader are implementations and
  are what a mismatch presumes wrong.
- The freeze is evidence: the corpus's exact bytes, by Git blob id or
  validation-only digest, recorded in Step 3 evidence with the commit that
  introduced them, before either implementation is compared against it, because
  bytes never recorded cannot later be shown not to have moved.
- Mismatch adjudication has exactly three paths, chosen by reading the design
  and not by which edit is smaller: fix the implementation when the corpus
  agrees with an unambiguous clause, the expected case; correct a genuine typo
  in an isolated corpus-only change citing that clause and re-establishing the
  frozen bytes, before any implementation change; or stop for reviewed design
  amendment when the clause is silent or admits both readings. Editing corpus
  and implementation together is forbidden outright, with the reason: the result
  is indistinguishable from the first case resolved the wrong way. `/1` still
  never changes in place.
- A new subsection, "The `path` vector matrix", replaces the single
  representative vector with seven vectors, each with raw input, what it proves
  and literal lowercase expected hex: `lib/foo.so` giving
  `6c69622f666f6f2e736f`, which is the design's own sample value; an object at
  `$DEST_PATH/usr/lib/libz.so.1` giving `7573722f6c69622f6c69627a2e736f2e31`,
  proving the encoded value is the remainder after `$DEST_PATH`; `a b=c` plus a
  newline giving `6120623d630a` for the three delimiter-looking bytes; `x`,
  `0xff`, `.so` giving `78ff2e736f` for a non-UTF-8 byte; `a` giving `61` as the
  shortest non-empty input; and an adjacent pair at and just past the `od`
  output wrap boundary, recorded literally with the vectors.
- The wrap pair's length is measured rather than assumed: run the exact `od`
  invocation the formatter uses, record the output line width in Step 3
  evidence, author the pair at that width and that width plus one. The plan
  states sixteen as the expected GNU `od -An -tx1` figure and explicitly says to
  confirm it against the shipped tool rather than take it on trust.
- The rejected `path` forms are retained as the matrix's negative half: empty,
  not non-empty even-length lowercase hex, decoded absolute, decoded `./`.
- Neither production end generates the raw recipes or the expected hex.
- The file list already carrying `docs/v0.27.0/contract.cplx-elf-1.txt` is
  unchanged; the corpus subsection now names it in place.
- Completion criteria gain the recorded freeze and measured wrap width before
  comparison, the full `path` matrix with its boundary pair, and a requirement
  that any mismatch resolved during the step record which adjudication path was
  taken with the design clause cited, with no commit changing corpus and
  implementation together.

Validation skeleton:

- Step 1's expectations carry the unit correction with its citations, the
  carriers a real bad-extent and missing-terminator fixture must mutate, the
  legitimacy of one carrier in several rows, the six things every row names, the
  zero-unclassified and zero-unexercised criteria with the identification
  guard's four parts counted separately, the `elf_kind` and `tag_state` coverage
  rule, and the three gaps the criterion found on first application.
- Step 3's expectations carry the artifact ranking, the recorded freeze and its
  reason, the three adjudication paths, the outright ban on the joint edit with
  its reason, and the `path` byte matrix with the measured wrap boundary.

Open questions:

- Q03's option 3A now states fixture-and-guard exhaustiveness, with two new pros
  on auditability of constructed bytes and on the criterion finding work rather
  than describing it. Its BBQ gains the indexing point, that a sheet indexed by
  feature invents entries nobody can machine and forbids one feature appearing
  twice for two different rules.
- Q09's option 9A gains the authority order, the recorded freeze, the three
  adjudication paths and the path byte matrix, with three new pros. A new option
  9E, the corpus with no stated authority corrected in place, is recorded as the
  plan's position by omission and rejected as 9B with extra steps. Its BBQ gains
  the gauge-block discipline: logged on the day it is cut, parts presumed wrong,
  a miscut block corrected on its own and logged again, and filing block and
  part together never allowed.
- Answers stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. No question is
  added.

Preserved per round 5's item 6: the reserved formatter identifier and its two
occurrence counts, the corpus separation, the measured Step 4 line checkpoint,
and the ordered Step 6 RHEL session.

### Writer response for plan relocation-force-rpath round 6

Writer response: Both requested corrections are applied. Nothing is disputed. The Q03 finding is
correct on the facts and the writer confirmed it against the specification
rather than accepting it on the reviewer's word: `Elf64_Dyn` is `d_tag` plus
`d_un`, and `DT_NULL` is a `d_tag` value, so neither "dynamic entry size" nor
"`DT_NULL` termination" is a stored field a fixture could write.

The Q03 defect is the failure mode this exchange has now produced five times,
and it is worth naming precisely rather than generally, because "asserting a
property without checking it" has stopped being a useful description. What
actually happened is narrower: the writer built a completeness claim, wrote down
the thing being counted, and never asked whether the unit was constructible. The
table said twelve mutated fields. Two of its rows could not be mutated at all.
Nothing in the plan's own text would have revealed that; only opening `elf(5)`
and looking at what an `Elf64_Dyn` actually contains would, and the writer had
already cited that document by name in the neighbouring column. The citation was
present and unread. That is a sharper accusation than carelessness: the plan
carried its own refutation as a footnote.

The consequence the reviewer identifies is the part the writer would not have
found alone. A wrong unit does not merely mislabel; it constrains. "Each field
exactly once" forbids `p_filesz` from proving both a bounds violation and a
non-integral entry count, and forbids `d_tag` from proving both tag identity and
non-termination, which are exactly the fixtures a real suite needs. The
exhaustiveness rule was quietly ruling out correct work in order to keep its own
arithmetic tidy.

The reviewer's criterion earned its place immediately, and the writer records
this because it argues for the criterion rather than for the writer. Applying
"zero unexercised rejection guards" to the existing matrix found three gaps in
one pass: the identification guard has four parts and only class and encoding
were tested, so bad magic and a wrong `e_ident[EI_VERSION]` had no fixture; and
no fixture produced `elf_kind: unsupported`, one of three values the design
defines. The previous formulation counted fields and therefore could not see
missing fixtures at all. A completeness rule that finds work is worth more than
one that certifies it, and the writer had built the second kind.

On Q09 the writer accepts the correction and notes that it closes a gap the
round 5 assessment had itself flagged. The assessment said the plan required the
comparison and did not say what happens on a mismatch, and that the cheap
resolution is to edit the vector. It then published without fixing it. This is
the fourth time in this exchange that the writer has named a gap and left the
reviewer to close it, and the previous response promised the opposite. The
promise was worth nothing; what would have been worth something was spending the
round on it.

The substance is accepted in full. Ranking the artifacts is what the writer
missed: it had "independent" as a property of the corpus and never asked what
makes independence survive contact with a failing test. The recorded freeze is
the part the writer would not have reached, because "the corpus is frozen" was
being carried as an intention rather than as evidence, and an intention leaves
nothing behind to check. Forbidding the joint edit outright, rather than
discouraging it, is right for the reason the reviewer gives and one more: it
removes a judgement call at the exact moment judgement is least reliable, with a
red suite and an obvious two-line fix in view.

The path matrix is accepted and the writer verified every hex value in it by
hand rather than deriving it from a formatter that does not exist yet. The
`lib/foo.so` vector matches the design's own sample capture, which is a small
consistency check the plan had available and had not used.

One thing is offered for round 6 rather than claimed as settled, and it is a
direct consequence of the corpus being hand-authored.

The plan now requires the corpus's bytes to be recorded before comparison, and
the adjudication rule assumes any later divergence is either an implementation
defect or a typo. It does not say what confirms the corpus was authored from the
design in the first place. The freeze proves the bytes have not moved since they
were recorded; nothing proves they were right when recorded. The obvious answer,
that the design is the authority so a reviewer can read one against the other,
is only an answer if someone is required to, and no completion criterion
requires it. The plan may need a corpus-to-design derivation review as an
explicit gate before the freeze, or it may not, and the writer does not know
which. What it should not do is leave the freeze looking like it establishes
correctness when it establishes only stability.

### Reviewer focus for plan relocation-force-rpath round 6

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-6 -->

## Round 6 by reviewer

- Recorded: 2026-08-17T16:15:52+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 6

Round 5's requested changes are applied in substance. Q03 now counts fixtures
and guards rather than invented field names, the added criterion found three
real coverage gaps, Q09 has a defensible authority order and mismatch process,
and the path matrix covers the runtime-derived field materially. Answers 1A,
2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A can all stand. Round 6 is still
`changes-requested`, because the newly explicit corpus authority is not yet
proved before it is frozen, and the current Q03/Q09 tests leave two stated
contracts unverifiable.

The requestor's Q09 concern is correct. A blob id or digest proves only that the
corpus has not changed since the measurement. It does not prove that the bytes
measured were derived correctly from the design. Add a pre-freeze, two-way
derivation audit. For every `/1` design obligation, record the corpus vector or
vectors that witness it; for every corpus vector, record the exact design clause,
its intended accept/reject result, and any canonical-output choice that the
design permits but does not require. Require zero uncovered design obligations
and zero corpus vectors without a derivation. The Step 3 implementation check
must read the literal corpus against that ledger and record the result before
the bytes are frozen. State plainly that the audit establishes derivation
correctness at that point and the digest establishes later stability; neither
claim substitutes for the other. If the audit exposes silence or two allowed
readings, it takes adjudication path 3 before the freeze rather than choosing a
corpus value.

That audit must expose one current hole in the contract corpus. The design says
the reader locates fields by name rather than position. Canonical vectors in
one formatter order do not test that rule: a positional `obj` reader and a
positional `end` reader can accept every stated canonical and malformed vector.
Add reader-only accepted literals that permute the fields of each record kind.
Keep formatter comparison against one canonical byte order, but classify the
corpus into canonical formatter vectors, other reader-valid vectors, and
rejected vectors so a valid permutation is never mistaken for malformed input.
This is a test consequence of 9A, not a new grammar decision.

Q03's new exhaustive unit is correct, but the matrix still contradicts two of
its own promises. First, it says every row names an exact carrier mutation with
offset and width or a file operation, while rows say only such things as “no
`PT_INTERP` program header emitted”, “two entries whose `d_tag` values are...”,
or “set past the file”. The manifest is described as holding exact mutation
bytes, but no stable row-to-manifest link is required. Give every fixture and
manifest mutation a stable id. A fixture row must cite all of its mutation ids,
or cite one exact lawful-generation/file-operation recipe. Each mutation id
then owns offset, width, original and replacement bytes. This permits one
carrier to appear in several fixtures without duplicating or losing the
evidence. In particular, either define the shared-library/no-dynamic shapes as
specific program-header mutations and prove their claimed lawful alternates, or
remove the “differs only” claims and record the actual multi-byte recipe.

Second, the matrix does not give an expected normalized tuple for every
successful fixture. Its convention omits probe statuses and values whenever
structure does not fix them, calling those probes the pass's concern. But the
Step 1 goal and the design define those fields as part of the observer tuple,
and the observer-fixture layer is required to assert the named tuple fields.
For every accepted and ambiguous fixture, state both probe statuses and whether
each probe value is present, with the literal expected value when status is
`ok`; then assert the complete array after the production observer returns. If
a synthetic lawful structure makes the shipped patchelf probe fail, record
`failed` rather than leaving the field unspecified. The fixed `skipped` and
`blocked` cases already follow this rule. A structural-only fixture layer would
instead require a reviewed design change; the plan cannot silently narrow the
tuple it claims to test.

No new question is needed. These are completion rules under Q03 and Q09, and
they must be mirrored in the validation skeleton. They are more than wording
polish, so convergence is not yet warranted.

### Question verdicts for plan relocation-force-rpath round 6

1. **Q01 -- keep 1A.** The separate harness remains the correct boundary around
   item 1's mirrored evidence.

2. **Q02 -- keep 2A.** Preserve the standalone installer and measured Step 4
   checkpoint.

3. **Q03 -- keep and strengthen 3A.** Give fixtures and manifest mutations
   stable ids so every fixture resolves to exact bytes or an exact generation
   operation. Complete every successful expected tuple with both probe statuses
   and value presence, because probes are fields of the observer contract, not
   a later concern. Retain zero unclassified fixtures and zero unexercised
   guards.

4. **Q04 -- keep 4D.** The reserved formatter identifier and atomic wiring
   boundary remain sound.

5. **Q05 -- keep 5C.** The associative-array carrier and exact-target gate
   remain fully specified.

6. **Q06 -- keep 6A.** The single identified RHEL session preserves the narrow
   terminal-blocked state.

7. **Q07 -- keep 7A.** The source-safe production seam remains correct.

8. **Q08 -- keep 8A.** Formatter and reader remain correctly separated.

9. **Q09 -- keep and strengthen 9A.** Before freezing, perform and record a
   two-way design-to-corpus derivation audit. Distinguish correctness-at-freeze
   from stability-after-freeze. Add accepted field-order permutations for both
   record kinds so the named-field reader rule is tested independently of the
   formatter's canonical byte order.

10. **Other missing questions.** None.

### Requested changes for plan relocation-force-rpath round 6

Requested changes: 1. Link every Q03 fixture to exact manifest mutation ids or an exact generation
   operation, and substantiate the claimed lawful-alternate differences.
2. Assert the complete observer tuple, including both probe statuses and values,
   for every structurally successful fixture.
3. Add a recorded two-way design-to-corpus derivation audit before the corpus
   bytes are frozen, separating correctness evidence from stability evidence.
4. Add reader-valid field-order permutations for both `/1` record kinds while
   retaining one canonical formatter byte order.
5. Mirror all four completion rules in the validation skeleton.

### Writer instructions for plan relocation-force-rpath round 6

Revise the implementation plan and validation skeleton together, then publish
another automated plan-review round.

1. Keep decisions 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A.
2. Under Q03 and Step 1, assign stable ids to every fixture and every manifest
   mutation. Make each fixture row cite all mutation ids that construct it, or
   one exact lawful-generation/file-operation recipe. Keep offset, width,
   original bytes, replacement bytes, byte order, and citation on the mutation
   entries. Correct the rows that currently describe only omission, generic
   tag presence, or “past the file”; substantiate or remove every “differs only”
   claim. Require zero fixture mutations without a manifest entry and zero
   manifest entries without a fixture/guard use.
3. Complete the expected normalized tuple for every accepted and ambiguous ELF
   fixture. State both probe statuses, whether each value is present, and the
   literal value whenever status is `ok`; assert every named associative-array
   field after invoking the production observer. A real patchelf failure on a
   synthetic but structurally accepted fixture is `failed`, not an omitted
   expectation. Preserve the already-complete `skipped` and `blocked` cases.
4. Under Q09 and Step 3, add a two-way derivation ledger before the corpus
   freeze: every `/1` design obligation maps to one or more corpus vectors, and
   every corpus vector maps to its exact design clause, intended result, and any
   canonical-output choice that the design permits without requiring. Require
   zero uncovered obligations and zero underived vectors. Make the Step 3
   implementation check read the literal corpus against this ledger and record
   success before recording the blob id or digest. State that the audit proves
   derivation correctness at freeze time and the digest proves stability after
   it. Ambiguous or silent authority takes adjudication path 3 before freezing.
5. Divide corpus vectors into canonical formatter output, other valid reader
   input, and rejected input. Add at least one accepted field-order permutation
   for `obj` and one for `end`, proving the reader resolves fields by name rather
   than position. Continue comparing formatter output byte-for-byte only with
   the canonical order; do not require the formatter to emit permutations.
6. Mirror the fixture-to-manifest traceability, complete-tuple assertions,
   pre-freeze derivation audit, and accepted permutation vectors in the
   validation skeleton. Preserve every already-settled Step 3 and Step 6 rule.

### Final reviewer decision for plan relocation-force-rpath round 6

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-6 -->

## Round 7 by requestor

- Recorded: 2026-08-17T16:31:11+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 7

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 7

### Requestor assessment for plan relocation-force-rpath round 7

Round 7. All five round 6 requested changes are applied, none disputed. No
question is added. Answers stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A.

**Q03's matrix did not obey Q03's own rule.** The preamble promised every row
would name an exact carrier mutation with offset and width or a file operation,
and six rows named a recipe, a tag presence or a bounds description instead, with
nothing linking any row to the manifest entry holding its bytes. Fixtures,
mutations, lawful generation recipes and file operations now all carry stable ids
in one namespace: `F01` to `F23`, `M01` to `M15`, `G01` to `G08` and `X01`. A row
cites either all its `Mnn` ids or exactly one `Gnn` or `Xnn`, and prose is not a
citation. `G01` defines the lawful base explicitly, down to `PT_INTERP` naming
`/lib64/ld-linux-x86-64.so.2` and `PT_DYNAMIC` holding `DT_NEEDED`, `DT_STRTAB`
and `DT_NULL`; each `Mnn` carries its range and its original and replacement
bytes. Traceability closes both ways: zero fixture mutations without a manifest
entry, zero manifest entries without a use.

**The alternate-pair column was wrong in both directions**, which assigning ids
made unavoidable to see. It recorded a constructible lawful alternate for
`e_phoff`, `p_offset` and `p_filesz`, where none exists: a lawful object whose
table or segment sits elsewhere differs across the moved region, not at one
range. The same excludes `e_ident[EI_CLASS]`, `e_ident[EI_DATA]` and `e_phnum`.
It is constructible for exactly three entries, `e_type`, `e_machine` and the
search-path `d_tag` over an unchanged `d_un`, and the third was missing although
it is the cleanest pair in the matrix, `F06` against `F07` differing at eight
bytes with the same string underneath.

Removing those claims left the bounds and layout offsets unanchored, since the
per-entry value cross-check only shows that some bytes decode to some expected
number. **Layout confirmation** is added as the check that ties offsets to
fields: the base is emitted at the manifest's own offsets and widths, and
`readelf -h`, `-l` and `-d` must then report the intended value for every named
field, so a wrong offset puts a value where `readelf` does not look and either
the parse fails or a reported value disagrees. It is stronger than what it
replaces and was available from the start.

**The tuple is now the whole tuple.** Omitting probe statuses wherever structure
did not fix them, on the grounds that the probes are the pass's concern, was the
fixture layer asserting less than the contract it names, since the design defines
both statuses and their values as observer tuple fields. Every accepted and
ambiguous fixture states both statuses, value presence, and the literal value
where the status is `ok`; the case invokes the production probe step after the
production observer and asserts every named field. A patchelf refusal on a
structurally lawful synthetic object is recorded as `failed` with its diagnostic,
never omitted, and a refusal across most fixtures is reported at Step 4 as an
untested probe axis rather than absorbed. Completing the rule gave two fixtures
an explicit measuring purpose: `F07` measures the design's claim that
`--print-rpath` answers for either tag, and `F10` measures its stated patchelf
preference for `DT_RUNPATH`, which required distinct strings on the two entries,
since with one shared string the fixture would pass under either behavior.

**Q09's freeze proved stability and was being read as correctness.** A recorded
two-way derivation audit now precedes it: design to corpus, every `/1` obligation
against the vectors witnessing it, zero uncovered; corpus to design, every vector
against its exact clause, its intended result, and any canonical-output choice
the design permits without requiring, zero underived. That last column is what
catches the quiet decisions, since where the design permits a form the corpus
must pick one and the pick is authored rather than derived. Step 3 reads the
literal corpus against the ledger and records the result before freezing, and the
two claims are kept apart in as many words: the audit for correctness at freeze,
the digest for stability after it. Silence or a double reading takes adjudication
path 3 before the freeze.

**The corpus could not test the one rule the design states about parsing.** The
design says the reader locates fields by name rather than by position, and
canonical vectors in a single field order cannot fail that rule: a strictly
positional `obj` reader and a strictly positional `end` reader accept every
canonical vector and reject every malformed one. The corpus now declares three
classes, canonical formatter vectors, other reader-valid vectors including at
least one permuted `obj` and one permuted `end`, and rejected vectors. The
formatter is compared against the canonical class only and is never required to
emit a permutation; declaring the classes is what keeps a valid permutation from
being filed as malformed input.

All four are mirrored in the validation skeleton, and every already-settled Step
3 and Step 6 rule is preserved.

What round 7 should look at:

- The complete-tuple rule and the `failed` fallback are individually right and
  their interaction is unexamined. If the shipped patchelf refuses most of the
  hand-assembled fixtures, every probe field would be asserted as `failed` and
  the probe axis would be honestly recorded and entirely untested, which the plan
  treats as an acceptable outcome to report at Step 4. It does not say at what
  point that stops being a record and becomes a reason to build the fixtures from
  a lawfully linked object instead. No threshold is invented here, because the
  right one is not evident from this side.

### Change summary for plan relocation-force-rpath round 7

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 6, applying round 6's five requested changes.

Step 1, the manifest and its anchors:

- The manifest's column table gains an `id` column, a stable `Mnn` cited by every
  fixture the mutation constructs.
- Lawful generation recipes and whole-file operations take ids in the same
  namespace, `Gnn` and `Xnn`, and carry a recipe rather than an offset pair, with
  the reason: a fixture built by emitting a different program header table or by
  truncating a file has no single mutated range.
- Traceability is stated as a rule in both directions: zero fixture mutations
  without a manifest entry, zero manifest entries without a fixture or guard that
  uses them.
- The two cross-checks become three, and one of the two is corrected. Layout
  confirmation is new and is now the check that ties offsets to fields: the
  lawful base is emitted at the manifest's own offsets and widths, and `readelf
  -h`, `-l` and `-d` must report the intended value for every named field, so a
  wrong offset puts the value where `readelf` does not look. The per-entry value
  cross-check is retained. The alternate pair is retained and its availability is
  corrected.
- The alternate-pair correction is stated explicitly. It was recorded as
  available for `e_phoff`, `p_offset` and `p_filesz`, where it is not
  constructible: a lawful object whose table or segment sits elsewhere differs
  across the moved region too. The same argument excludes `e_ident[EI_CLASS]`,
  which changes the whole header layout, `e_ident[EI_DATA]`, which byte-swaps
  every multi-byte field, and `e_phnum`, whose second lawful value implies a
  different table. It is constructible for exactly three entries: `e_type`,
  `e_machine`, and the search-path `d_tag` over an unchanged `d_un` and string,
  the last of which the previous version had missed.

Step 1, the fixture matrix:

- A recipe table defines `G01` to `G08` and `X01`. `G01` is the lawful base
  `B0`: `ET_EXEC`, ELF64, little-endian, `EM_X86_64`, a program header table of
  `PT_INTERP`, `PT_LOAD` and `PT_DYNAMIC`, `PT_INTERP` naming
  `/lib64/ld-linux-x86-64.so.2`, `PT_DYNAMIC` holding `DT_NEEDED`, `DT_STRTAB`
  and `DT_NULL`, and a string table in the loaded segment, every field written at
  the manifest's own offset and width. The rest are `B0` variants: without
  `PT_INTERP` and `ET_DYN`; without `PT_DYNAMIC`; with `DT_SONAME` added; with
  `DT_RPATH` addressing `/opt/cplx-probe/lib`; with `e_phnum` zero and no table;
  with `DT_RPATH` and `DT_RUNPATH` addressing distinct strings; with two
  `DT_RPATH` entries addressing distinct strings. `X01` truncates `B0` to 32
  bytes.
- A mutation table defines `M01` to `M15` with field, range, original and
  replacement bytes and the base applied to: `e_type` `02 00` to `03 00` and to
  `01 00`; the search-path `d_tag` `0f` to `1d`; `e_ident[0..3]` `7f 45 4c 46` to
  `7f 45 4c 47`; `e_ident[EI_VERSION]` `01` to `00`; `e_ident[EI_CLASS]` `02` to
  `01`; `e_ident[EI_DATA]` `01` to `02`; `e_machine` `3e 00` to `b7 00`;
  `e_phnum` to `ff ff`; `e_phentsize` `38 00` to `20 00`; `e_phoff`, the
  `PT_LOAD` `p_offset` and `p_filesz`, and `PT_DYNAMIC`'s `p_filesz` to values
  derived from the base's file size; and the terminating `d_tag` `00` to `01`.
- The three fixture tables are rewritten. Every row carries `F01` to `F23`, cites
  either all its `Mnn` ids or exactly one `Gnn` or `Xnn`, and states its guard,
  oracle with citation, alternate-pair status and expected tuple. The rule that
  prose is not a citation is stated: "no `PT_INTERP` emitted", "two entries whose
  `d_tag` values are ..." and "set past the file" no longer appear as
  constructions.
- Every "not constructible" and "not applicable" alternate status carries its
  reason per row, including the three `F03`, `F04` and `F05` rows whose "differs
  only" claims were false and are now removed and explained.

Step 1, the complete tuple:

- The convention that omitted probe statuses wherever structure did not fix them
  is removed, with the reason stated: the design defines both probe statuses and
  their values as fields of the observer tuple, so omitting them narrowed the
  contract this step claims to test.
- Every accepted and ambiguous fixture now states both probe statuses, whether
  each value is present, and the literal value where the status is `ok`. The
  `skipped` cases state that no value is present. `F01`, `F02` and `F05` expect
  `ok` with a present and empty rpath value; `F06` and `F07` expect
  `/opt/cplx-probe/lib`; every fixture carrying `PT_INTERP` expects
  `/lib64/ld-linux-x86-64.so.2`.
- The Step 1 case invokes the production probe step on the fixture after the
  production observer returns and asserts every named field of the array. The
  plan records that this widens the step by a call and an assertion rather than a
  redesign.
- Two consequences are stated ahead of the run rather than left to it. A shipped
  patchelf refusing a structurally lawful synthetic object is recorded as
  `failed` with its diagnostic, never as an omitted expectation, and a refusal
  across most fixtures is reported at Step 4 as an untested probe axis rather
  than absorbed. Where the intended value turns on behavior the design does not
  fix, the plan says so, records the measured value with the patchelf version and
  asserts it thereafter, a later change being a finding rather than a reason to
  loosen the fixture.
- Two fixtures are given a measuring purpose that was implicit before. `F07`
  measures the design's claim that `--print-rpath` answers for either tag, and
  `F10` measures its stated patchelf preference for `DT_RUNPATH`, using distinct
  strings so the preference is observable, on which a case 5 disposition rests.
- Completion criteria gain the id citation rule, both traceability directions,
  the three cross-checks with the three constructible alternate pairs named, and
  the complete-array assertion.

Step 3, the corpus classes:

- The corpus is declared in three classes rather than two: canonical formatter
  vectors in one field order, other reader-valid vectors, and rejected vectors.
- At least one permuted `obj` and one permuted `end` are added to the second
  class. The reason is stated: the design says the reader locates fields by name
  rather than by position, and canonical vectors in a single order cannot test
  that rule, since a strictly positional reader for each record kind accepts
  every canonical vector and rejects every malformed one while implementing a
  different grammar. Declaring the classes is what stops a valid permutation
  being filed as malformed input.
- The formatter is compared against the canonical class only, and is never
  required to emit a permutation.

Step 3, the pre-freeze derivation audit:

- A new passage states that a digest is not a derivation and that the freeze must
  not be read as though it were: a blob id proves the bytes have not moved since
  measurement and says nothing about whether they were correctly derived, which
  the adjudication rule presumes.
- A two-way ledger is added as a table. Design to corpus: every `/1` obligation
  against the vectors witnessing it, zero uncovered obligations. Corpus to
  design: every vector against its exact design clause, its intended accept or
  reject result, and any canonical-output choice the design permits without
  requiring, zero underived vectors.
- The last column is explained: where the design permits a form without
  requiring it, the corpus must pick one, and recording the pick as authored
  keeps a later reader from mistaking a convenience for an obligation.
- Step 3 reads the literal corpus against the ledger and records the result
  before the bytes are frozen. The two claims are separated in as many words: the
  audit establishes derivation correctness at freeze time, the digest establishes
  stability afterwards, and neither substitutes for the other.
- Silence or a clause admitting two readings takes adjudication path 3 before the
  freeze, rather than being settled by choosing a corpus value and recording it
  as derived.
- Completion criteria are reordered accordingly: the ledger first, then the
  recorded bytes, then the comparisons; the canonical-only formatter comparison;
  and the reader accepting the permutations as well as the canonical vectors.

Validation skeleton:

- Step 1's expectations carry the id namespaces and the prose-is-not-a-citation
  rule, both traceability directions, the three cross-checks with the corrected
  alternate-pair availability and its reason, the complete-tuple rule with the
  `failed` and measured-value cases, and the two fixtures whose purpose is to
  measure patchelf behavior the design asserts.
- Step 3's expectations carry the digest-is-not-a-derivation passage, the two-way
  ledger with both completion rules and the permitted-but-not-required column,
  the ordering of audit before freeze, the separation of the two claims, and the
  three corpus classes with the permutations and why a positional reader would
  otherwise pass.

Open questions:

- Q03's option 3A carries the id citation rule, both traceability directions, the
  corrected alternate-pair availability, and the complete-tuple assertion, with
  two new pros on ids making the promise checkable and on not testing less than
  the named contract.
- Q09's option 9A carries the two-way derivation audit, the separation of
  correctness at freeze from stability after it, and the three corpus classes
  with the permuted records, with two new pros on why a digest over wrongly
  derived bytes proves only that the mistake is stable, and on what a strictly
  positional reader would otherwise pass.
- Answers stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. No question is
  added.

Preserved per round 6's item 6: every already-settled Step 3 rule, the reserved
formatter identifier and its occurrence counts, the `path` byte matrix with its
measured wrap boundary, the adjudication paths and the ban on the joint edit, and
the ordered Step 6 RHEL session.

### Writer response for plan relocation-force-rpath round 7

Writer response: All five requested changes are applied. Nothing is disputed. Applying the first
one exposed a further error the reviewer did not name, and the writer reports it
rather than quietly correcting it.

The pattern in round 6's two Q03 findings is worth stating precisely, because it
is not the same as the earlier ones. Round 5's finding was that the writer had
named a thing that does not exist. Round 6's is that the writer wrote a rule and
then a table that does not obey it. The rule said every row names an exact
carrier mutation with offset and width or a file operation. Three rows said "no
`PT_INTERP` program header emitted", one said "two entries whose `d_tag` values
are", and two said "set past the file". The rule and its violations were adjacent
on the page. Nothing about ELF was needed to see it; reading the table against
its own preamble was enough, and the writer did not do that, having spent the
round satisfied that the unit had been fixed. A corrected unit was treated as a
corrected table.

Assigning ids forced the check the prose had avoided, and it turned up a
substantive error the reviewer flagged only as a suspicion. The matrix recorded a
constructible lawful alternate for `e_phoff`, `p_offset` and `p_filesz`. There is
none. A lawful object whose program header table sits at a different offset has
the table at that different offset, so the two files differ across the moved
region and not at one range. The same disposes of `e_ident[EI_CLASS]`,
`e_ident[EI_DATA]` and `e_phnum`. The alternate pair is constructible for exactly
three entries: `e_type`, `e_machine`, and the search-path `d_tag` over an
unchanged `d_un`, and the writer had recorded the first two as available while
missing the third, which is the cleanest one in the whole matrix. So the column
was wrong in both directions at once.

That correction created a gap the plan had to fill rather than absorb. If the
alternate pair is unavailable for the bounds and layout fields, nothing was left
tying those offsets to their fields, since the base cross-check only shows that
some bytes at a range decode to some expected value. The answer added is layout
confirmation over the whole object: the base is emitted at the manifest's own
offsets and widths, and `readelf` must then parse it and report the intended
value for every named field, so a wrong offset puts a value where `readelf` does
not look and the parse fails or disagrees. This is stronger than what it
replaces, and it was available all along. The writer had built the anchor list
around the weaker check and never asked what the manifest's offsets were actually
being tested against.

The complete-tuple finding is accepted without qualification and is the more
serious of the two. Calling the probe fields the pass's concern was not a
simplification; it was the fixture layer testing less than the contract it names,
in a document that had spent four rounds arguing that a check must be measured
against what it claims. The convention read as tidy scoping and functioned as a
narrowing. Completing it also gave two fixtures a purpose they had been carrying
implicitly: the `DT_RUNPATH` fixture is where the design's claim that
`--print-rpath` answers for either tag is actually measured, and the both-tags
fixture is where its stated patchelf preference is measured, which required
giving the two entries distinct strings so that the preference is observable at
all. With one shared string the fixture would have passed under either behavior.

The Q09 findings close the gap the writer had itself flagged, and the writer
notes that this is the fifth round in which a flagged item was closed by the
reviewer rather than by the writer. The derivation audit is right and its
two-way form is better than the one-way check the writer had in mind: the
corpus-to-design direction with its permitted-but-not-required column is what
catches the choices a corpus must make and can silently present as obligations.

The permutation finding the writer did not see at all, and it is the sharpest
item in the round. The corpus was built to stop two implementations agreeing
about a wrong grammar, and it would have permitted exactly that on the one rule
the design states about parsing: a strictly positional `obj` reader and a
strictly positional `end` reader pass every canonical vector and reject every
malformed one. The corpus's own construction, one canonical order per record
kind, made the rule untestable. An oracle that cannot fail on a stated rule is
not covering that rule, and the writer had counted it as covered.

One thing is offered for round 7 rather than claimed as settled.

The plan now requires every accepted and ambiguous fixture to assert a literal
probe value, and it also concedes that the shipped patchelf may refuse a
synthetic object outright, in which case the recorded status is `failed`. Those
two rules are individually right and their interaction is unexamined. If patchelf
refuses most or all of the synthetic fixtures, the plan's stated fallback is to
report an untested probe axis at Step 4, which means the probe fields would be
asserted as `failed` everywhere and would prove nothing about the values the
design defines. The plan does not say at what point that outcome stops being an
honest record and starts being a reason to build the fixtures differently, for
instance from a lawfully linked object rather than a hand-assembled one. The
writer does not know where that line is, and states the question rather than
inventing a threshold.

### Reviewer focus for plan relocation-force-rpath round 7

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: requestor-round-7 -->

## Round 7 by reviewer

- Recorded: 2026-08-17T17:09:23+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 7

Round 6's five requested changes are applied coherently. The Q03 ids now make
fixture construction traceable in both directions, the complete tuple is
visible, the corpus has a pre-freeze derivation audit, and the two accepted
permutations make name-based parsing testable. Answers 1A, 2A, 3A, 4D, 5C,
6A, 7A, 8A, and 9A can all stand. Round 7 remains `changes-requested` for two
Q03 corrections: the probe fallback contradicts the step gate, and the revised
alternate-pair classification still states a false universal.

There should be no percentage threshold for synthetic-fixture probe failures.
Coverage is per semantic obligation. The plan names successful patchelf behavior
that later classification relies on: an applicable no-tag probe answers with an
empty value; both `DT_RPATH` and `DT_RUNPATH` answer with their stored value;
the mixed-tag probe returns the `DT_RUNPATH` value; and a present interpreter
probe returns the interpreter. Each such behavior needs at least one designated
fixture whose production probe status is `ok` and whose literal value matches.
The structure-proved `skipped` paths need their designated witnesses as already
written. Ten honest `failed` results on other fixtures cannot substitute for one
missing success witness.

The current fallback cannot operate under the plan's own sequencing. F01,
F02, F03, F04, F05, F06, F07 and F10 state literal `ok` outcomes; Step 1 says
each fixture must produce exactly its tuple; and the execution checklist stops
at the first non-green step. If one of those designated witnesses returns
`failed`, Step 1 is incomplete. It cannot be accepted and reported later as an
untested axis at Step 4, because Step 4 is unreachable. Replace that fallback
with a hard Step 1 rule: repair the lawful synthetic recipe until every named
success witness works with the shipped patchelf, or stop and revise Q03's
fixture-source/prerequisite decision before continuing. Do not weaken an
expected `ok` to `failed` merely to fit the first generated bytes.

Test `failed` deliberately rather than relying on an accidental refusal. Add
production-probe cases with a controlled patchelf double: one fails
`--print-rpath` while `--print-interpreter` answers, and one does the converse.
They must assert the design's axis-local fault outcomes through the actual probe
code. Step 2's controlled tuples prove the classifier consumes `failed`; they
do not prove the production probe creates it or preserves the other axis.
F11 may remain a version-recorded measurement because duplicate same-tag probe
preference is not fixed by the design, but it is not a success witness and its
first measurement must be distinguished from a predeclared test expectation.

The alternate-pair correction also overreaches. “Not constructible” and
“constructible for exactly three entries” are universal claims, and the reasons
given for the bounds fields assume data must be moved rather than duplicated.
Two otherwise identical files can carry identical program-header tables at two
offsets and differ only in `e_phoff`; can carry identical segment bytes at two
congruent offsets and differ only in `p_offset`; or can contain the same slack
bytes with adequate `p_memsz` and differ only in `p_filesz`. Those are artificial
fixtures, but they are lawful counterexamples. The plan does not need to add
them. Rename the status to “not provided by the selected base/recipe set” (with
the practical reason), reserve “not applicable” for invariants and file
operations, and say the three listed pairs are the ones this plan chooses to
construct. Layout confirmation and the per-entry value check remain the stated
anchors for every unpaired entry.

No new question is required. These are implementability and evidence corrections
under Q03. Q09 is now sufficient, and no other settled choice needs reopening.
The changes are more than wording polish because they change the Step 1 pass
condition and add direct fault-path tests, so convergence is not yet warranted.

### Question verdicts for plan relocation-force-rpath round 7

1. **Q01 -- keep 1A.** The independent effort harness remains the right
   boundary.

2. **Q02 -- keep 2A.** Preserve the standalone installer and measured Step 4
   checkpoint.

3. **Q03 -- keep and strengthen 3A.** Replace the “report at Step 4” fallback
   with categorical Step 1 probe witnesses: every behavior relied on by the
   classifier needs at least one applicable `ok` fixture with its literal
   value. Add controlled production-probe failures for both axis-local fault
   directions. Scope alternate-pair availability to what this fixture set
   provides rather than claiming other pairs are impossible to construct.

4. **Q04 -- keep 4D.** The atomic behavior/report boundary remains sound.

5. **Q05 -- keep 5C.** The associative-array carrier and target gate remain
   sufficient.

6. **Q06 -- keep 6A.** The ordered RHEL session and narrow blocked state remain
   sufficient.

7. **Q07 -- keep 7A.** The source-safe seam remains implementable.

8. **Q08 -- keep 8A.** Formatter and reader remain correctly separated.

9. **Q09 -- keep 9A.** The derivation ledger, freeze distinction, three corpus
   classes, permutations, path matrix, and adjudication rule now cover the wire
   contract sufficiently.

10. **Other missing questions.** None.

### Requested changes for plan relocation-force-rpath round 7

Requested changes: 1. Make probe coverage categorical: every relied-on successful behavior needs a
   named `ok` fixture, and an expected-`ok` refusal blocks Step 1 rather than
   being deferred to Step 4.
2. Exercise both axis-local `failed` statuses through the production probe code
   with controlled patchelf failures.
3. Keep the design-unspecified F11 result as an explicit baseline measurement,
   not a substitute for a success witness.
4. Scope alternate-pair availability to the pairs selected by this fixture set;
   remove the false claim that other lawful pairs are impossible to construct.
5. Mirror these Q03 completion rules in the validation skeleton.

### Writer instructions for plan relocation-force-rpath round 7

Revise the implementation plan and validation skeleton together, then publish
another automated plan-review round.

1. Keep decisions 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A.
2. Under Q03 and Step 1, add a categorical probe-witness matrix rather than a
   failure percentage. Require at least one production-probe `ok` witness for
   every behavior the design and classifier rely on: empty no-tag rpath;
   `DT_RPATH` value; `DT_RUNPATH` value; the mixed-tag `DT_RUNPATH` preference;
   and a present interpreter value. Retain explicit structure-proved witnesses
   for both `skipped` producers. Name the fixture ids that satisfy each
   obligation and require zero uncovered probe obligations.
3. Remove the statement that widespread synthetic-fixture refusals are merely
   reported at Step 4. An expected-`ok` witness returning `failed` leaves Step 1
   incomplete. Its lawful recipe must be repaired for the shipped patchelf, or
   implementation stops for a reviewed Q03 fixture-source/prerequisite revision.
   Do not rewrite the expected value to match an accidental refusal.
4. Add direct production-probe fault cases using a controlled patchelf double:
   fail `--print-rpath` while the interpreter probe succeeds, and fail
   `--print-interpreter` while the rpath probe succeeds. Assert every tuple field
   and the surviving opposite-axis evidence. Keep Step 2's controlled `failed`
   tuples as classifier tests; state that they do not replace these producer
   tests.
5. Treat F11's unspecified duplicate-tag preference as a versioned measurement,
   not as a designated success witness. Separate its first observation from the
   fixed expectations that exist before a test runs, then freeze and assert the
   measured complete tuple on later runs.
6. Replace universal alternate statuses such as “not constructible” and the
   claim that exactly three pairs can exist. Say instead which three pairs this
   plan selects/provides and mark the others “not provided by the selected
   base/recipe set,” with the practical reason. Keep “not applicable” for a file
   operation or invariant with no field pair. State that layout confirmation
   plus the per-entry value check anchor every entry without a provided pair.
7. Mirror the categorical probe coverage, hard Step 1 gate, direct fault cases,
   F11 measurement lifecycle, and scoped alternate-pair wording in the
   validation skeleton. Preserve the now-sufficient Q09 rules unchanged.

### Final reviewer decision for plan relocation-force-rpath round 7

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-7 -->

## Round 8 by requestor

- Recorded: 2026-08-17T20:00:24+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 8

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 8

### Requestor assessment for plan relocation-force-rpath round 8

Round 8. All five round 7 requested changes are applied, none disputed. No
question is added. Answers stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. Q09 is
untouched, having passed review unchanged.

**Probe coverage was proportional and is now categorical.** The plan had said a
patchelf refusal across most synthetic fixtures leaves the probe axis untested
and is reported at Step 4. That report could never have been written: `F01` to
`F07` and `F10` state literal `ok` outcomes, each fixture must produce exactly
its tuple, and execution stops at the first step that is not green, so Step 4 is
unreachable from a Step 1 whose witnesses failed. The rule was also the wrong
shape independently of sequencing, since what the classifier relies on is a
behavior rather than a proportion, and honest failures elsewhere cannot make up
for one missing success.

A ten-row probe-witness matrix replaces it, each row naming its witness and
expected outcome: the empty no-tag rpath answer at `F01`; the `DT_RPATH` value at
`F06`; the `DT_RUNPATH` value at `F07`, where the design's finding that one query
serves both tags is measured; the mixed-tag `DT_RUNPATH` preference at `F10`,
which a case 5 disposition rests on; the present interpreter at `F01` and every
other fixture carrying `PT_INTERP`; both structure-proved `skipped` producers at
`F04` and `F03`; the `blocked` producer across `F12` to `F23`; and both
axis-local `failed` producers at `D01` and `D02`. Zero uncovered obligations is a
completion criterion.

**A named `ok` witness returning `failed` now leaves Step 1 incomplete**, with two
ways forward and no third: repair the lawful recipe until the witness works with
the shipped patchelf, or stop for a reviewed Q03 fixture-source revision.
Rewriting the expectation to match the refusal is excluded by name, being the
cheapest move available exactly when the suite is red.

**Both `failed` statuses are produced deliberately.** `D01` and `D02` run the
production probe step over the lawful base with a controlled patchelf double
installed where `find_patchelf` resolves, one failing `--print-rpath` while the
interpreter answers and one the converse, each asserting the surviving axis's
status and literal value, which is what makes "axis-local" measured rather than
intended. Step 2's controlled tuples remain classifier tests: consuming a
`failed` value says nothing about whether the production probe produces it or
leaves the other axis standing.

**`F11` has a lifecycle rather than an expectation.** Status and value presence
are predeclared; the value itself is measured on first run, recorded with the
patchelf version, then frozen and asserted, a later change being a finding. It
witnesses no probe obligation, and its first observation is recorded as a
measurement rather than as a predeclared expectation that happened to hold.

**The alternate-pair column was wrong twice, in opposite directions.** It first
claimed pairs for `e_phoff`, `p_offset` and `p_filesz` that this recipe set does
not build, then said those pairs are not constructible, which is false: two
otherwise identical lawful files can carry duplicated program header tables at
two offsets and differ only in `e_phoff`, identical segment bytes at two
congruent offsets and differ only in `p_offset`, or the same slack bytes with
adequate `p_memsz` and differ only in `p_filesz`. Both sentences were claims
about what ELF permits, made without consulting ELF, and the second was made
while correcting the first.

The status is now about this plan's selection, in four values: **provided**, for
`e_type` via `F01`/`F02`, `e_machine` via the base and `F16`, and the search-path
`d_tag` via `F06`/`F07`; **not provided**, where a lawful pair exists but needs a
purpose-built second base serving no guard of its own, with `F20` and `F21` now
naming the constructions they decline; **no lawful pair in this profile**, at
`F12`, `F13` and `F19`, where the domain under ELF64, little-endian, x86-64 holds
one value; and **not applicable**, at `F18`, `F22` and `F23`, where there is no
field pair at all. The third is kept distinct because only the second could be
revisited by changing the recipe set, and it is scoped to the profile rather than
to ELF at large, which is the discipline the retracted claim lacked. Layout
confirmation and the per-entry value cross-check anchor every entry without a
provided pair.

All five are mirrored in the validation skeleton, and every settled Q04 to Q09
rule is preserved unchanged.

What round 8 should look at:

- `D01` and `D02` introduce a controlled patchelf double at the point where
  `find_patchelf` resolves, and the plan does not say what bounds it. A double
  left on the resolution path would silently replace the shipped tool for every
  later fixture, and the failure is quiet: the probe witnesses still return
  values, just not the shipped patchelf's. Scoping the substitution to a subshell
  or asserting the resolved patchelf identity at the start of every other case
  would each close it; no rule is invented here, because which belongs in this
  plan is not evident from this side.

### Change summary for plan relocation-force-rpath round 8

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 7, applying round 7's five requested changes.
Every change is under Q03; Q09 is untouched.

Step 1, probe coverage:

- The passage that made coverage proportional is removed. It had said a refusal
  across most synthetic fixtures leaves the probe axis untested and is reported
  at Step 4. The plan now records why that could never have run: `F01` to `F07`
  and `F10` state literal `ok` outcomes, Step 1 requires each fixture to produce
  exactly its tuple, and execution stops at the first step that is not green, so
  Step 4 is unreachable from a Step 1 whose witnesses failed. It also records
  that the shape was wrong regardless of sequencing, since what the classifier
  relies on is a behavior and not a proportion, and honest failures elsewhere
  cannot substitute for one missing success.
- A probe-witness matrix is added with ten obligations, each naming its witness
  and its expected outcome:
  - an applicable rpath probe with no search-path tag answers empty, `F01`, with
    `F02` and `F05` as further instances;
  - `DT_RPATH` answers with its stored value, `F06`, `/opt/cplx-probe/lib`;
  - `DT_RUNPATH` answers with its stored value, `F07`, the same literal, which is
    where the design's finding that one query serves both tags is measured;
  - with both tags the probe returns the `DT_RUNPATH` value, `F10`,
    `/opt/cplx-probe/runpath`, the preference a case 5 disposition rests on;
  - a present interpreter answers with the interpreter, `F01` and every other
    fixture carrying `PT_INTERP`;
  - structure proves the rpath probe inapplicable, `F04` with `F08` and `F09`;
  - structure proves the interpreter probe inapplicable, `F03` with `F08` and
    `F09`;
  - an inconclusive structure blocks both axes, `F12` to `F23`;
  - the rpath probe fails while the interpreter axis survives, `D01`;
  - the interpreter probe fails while the rpath axis survives, `D02`.
- Zero uncovered probe obligations is a completion criterion.

Step 1, the hard gate:

- A named `ok` witness returning `failed` leaves Step 1 **incomplete**, with two
  ways forward and no third: repair the lawful generation recipe until the
  witness works with the shipped patchelf, or stop for a reviewed Q03
  fixture-source revision.
- Rewriting an expected `ok` to `failed` so the first generated bytes pass is
  excluded by name, with the reason that it is the cheapest move available at
  exactly the moment the suite is red.

Step 1, the deliberate fault cases:

- `D01` and `D02` are added. Each runs the production probe step over the lawful
  base with a controlled patchelf double installed where `find_patchelf`
  resolves, so the production code path is the one under test. `D01`'s double
  fails `--print-rpath` and answers `--print-interpreter`; `D02`'s does the
  converse.
- Each asserts the complete array including the surviving axis's status and
  literal value, which is what shows the fault is axis-local.
- The plan states that Step 2's controlled tuples prove the classifier
  **consumes** `failed` and do not prove the production probe **produces** it or
  leaves the other axis intact, and that these are different claims.
- The Step 1 test-first list gains the two probe-fault cases.

Step 1, `F11`'s lifecycle:

- `F11` is given a lifecycle rather than an expectation: before the first run the
  predeclared expectation is the status and the presence of a value, not the
  value; the first run records the literal value with the patchelf version as a
  measurement; thereafter that value is frozen and asserted, and a change is a
  finding.
- Its row and the completion criteria both state that it is **not a witness for
  any probe obligation**, and that its first observation is recorded as a
  measurement rather than as a predeclared expectation that happened to hold.

Step 1, the alternate-pair status:

- The claim that the pair is "not constructible" for the bounds and layout fields
  is retracted, with the counterexamples recorded: two otherwise identical lawful
  files can carry identical program header tables at two offsets and differ only
  in `e_phoff`, identical segment bytes at two congruent offsets and differ only
  in `p_offset`, or the same slack bytes with adequate `p_memsz` and differ only
  in `p_filesz`. The plan states that both the original claim and its correction
  were universal statements about ELF made without consulting ELF.
- The status becomes one about this plan's selection, in four values: **provided**
  for the three pairs built here; **not provided**, where a lawful pair exists
  but needs a purpose-built second base serving no guard of its own; **no lawful
  pair in this profile**, where the field's domain under ELF64, little-endian,
  x86-64 holds one value; and **not applicable**, for file operations and
  invariants with no field pair at all.
- The third status is kept distinct rather than folded into either neighbour,
  with the reason: only "not provided" could be revisited by changing the recipe
  set. It is scoped to the profile rather than to ELF at large, which the
  retracted claim was not.
- Every row in the three fixture tables is restated in those terms. `F12`, `F13`
  and `F19` become "no lawful pair in this profile"; `F03`, `F04`, `F05`, `F08`,
  `F10`, `F11`, `F14`, `F15`, `F17`, `F20` and `F21` become "not provided" with
  their practical reason, `F20` and `F21` now naming the duplicated-table and
  congruent-offset constructions they decline; `F18`, `F22` and `F23` keep "not
  applicable". `F01`/`F02`, the base against `F16`, and `F06`/`F07` are marked
  provided.
- `F09`'s row is corrected: it and `F08` do differ only at `e_type`, but the plan
  does not count it as a provided pair, the `e_type` obligation already being met
  by `F01` against `F02`.
- Layout confirmation and the per-entry value cross-check are restated as the
  anchors for every entry without a provided pair.
- Completion criteria now require every non-provided row to carry its reason and
  its correct one of the three remaining statuses, and name the three provided
  pairs explicitly.

Validation skeleton:

- Step 1's expectations carry the categorical-coverage passage with the reason
  the previous fallback could not have run, the ten obligations in prose, the
  hard gate with its two ways forward and the excluded third, the two deliberate
  fault cases with the controlled double and the axis-local assertion, the
  statement that Step 2's tuples do not stand in for producer tests, and `F11`'s
  measurement lifecycle with its exclusion from the witness set.
- Step 1's manifest expectations carry the two-way retraction of the
  alternate-pair claim with the counterexamples, the four statuses with the
  reason the third is kept separate and scoped to the profile, and the three
  provided pairs named.

Open questions:

- Q03's option 3A carries the scoped alternate-pair statuses and the categorical
  probe coverage with its hard gate and its two produced failures, and gains four
  pros: a per-behavior witness cannot be satisfied by volume; a blocking failed
  witness keeps the pass condition honest, the deferral it replaces having named
  an unreachable report; a controlled double tests the production probe rather
  than the classifier; and scoping the status stops the column making unchecked
  claims about ELF. Its con now names the double as a second test mechanism to
  maintain.
- Answers stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. No question is
  added.

Preserved per round 7's item 7: every Q09 rule unchanged, including the
derivation ledger, the freeze distinction, the three corpus classes, the
permutations, the `path` matrix and the adjudication paths; and the settled Q04,
Q05, Q06, Q07 and Q08 material.

### Writer response for plan relocation-force-rpath round 8

Writer response: All five requested changes are applied. Nothing is disputed, and the
alternate-pair finding is accepted as fully as the round 6 one it corrects.

The alternate-pair column is the honest headline of this round, because it is the
same error twice, in opposite directions, in consecutive rounds. Round 5's table
claimed pairs for `e_phoff`, `p_offset` and `p_filesz` that this recipe set does
not build. Round 6's correction said those pairs are not constructible. Both
sentences are statements about what ELF permits, and neither was checked against
ELF. The reviewer's counterexample settles it in one line: two otherwise
identical lawful files can carry duplicated program header tables at two offsets
and differ only in `e_phoff`. The writer had reasoned "the table would have to
move", which is true only if you assume the second file is the first one edited
rather than a file built for the purpose, and the whole fixture layer is built
for the purpose. The unexamined assumption was smuggled in by the word "moved".

What makes this worth more than an apology is that the correction had felt like
rigor. Round 6's response presented the retraction as the writer catching
something the reviewer had only suspected, and it was catching one error by
committing a second of the same kind. Being right about a defect is not the same
as being right about its replacement, and confidence transferred from the first
to the second without earning it. The four-value status now says what the plan
selects, which is a claim the plan is entitled to make, and keeps "a lawful pair
exists and we decline to build it" apart from "the domain holds one value",
because only the first is revisitable.

The probe-coverage finding is accepted and is the more consequential of the two.
Two things were wrong and only one of them was visible from inside the passage.
Proportional coverage is wrong on its own terms: what the classifier consumes is
a behavior, so ten honest failures buy nothing against one missing success, and
the writer had written a rule that could be satisfied by volume. The second is
sharper. The fallback promised a report at Step 4 that the plan's own sequencing
makes unreachable, because eight fixtures state literal `ok` outcomes and
execution stops at the first step that is not green. The writer flagged the
interaction in the round 7 assessment, described it as unexamined, and did not
examine it. Reading two rules of the same document against each other would have
shown that one described an impossible event. That is now the sixth flagged item
closed by the reviewer, and the flag was more specific this time, which makes
leaving it open worse rather than better.

The deliberate fault cases are accepted with the distinction intact. The plan had
Step 2's controlled tuples proving the classifier consumes `failed`, and treated
the axis-local fault outcomes as covered on that basis. They are different
claims: consuming a value someone else constructed says nothing about whether the
production probe produces it or leaves the opposite axis standing. `D01` and
`D02` put a controlled double where `find_patchelf` resolves, so the code under
test is the shipped path rather than a stand-in, and each asserts the surviving
axis's literal value, which is the part that makes "axis-local" a measured
property instead of a design intention.

`F11`'s lifecycle is accepted and clarifies something the writer had left
ambiguous by convenience. A first observation and a predeclared expectation look
identical once written down, and the plan was going to record one as the other.
Separating them keeps the duplicate-tag preference honest as a versioned
measurement of unspecified behavior, and removes it from the witness set where it
never belonged.

One thing is offered for round 8 rather than claimed as settled.

`D01` and `D02` install a controlled patchelf double where `find_patchelf`
resolves. The plan does not say what stops that double from being reachable
outside those two cases. A double that a later case forgets to remove, or that
the harness leaves on the resolution path, would silently replace the shipped
patchelf for every fixture after it, and the failure mode is quiet: the probe
witnesses would still return values, just not the shipped tool's. The obvious
answers are scoping the substitution to a subshell, or asserting the resolved
patchelf identity at the start of every other case, and the writer does not know
which belongs in this plan or whether either rises to a stated rule. What it
should not do is introduce a fault-injection mechanism without saying what bounds
it.

### Reviewer focus for plan relocation-force-rpath round 8

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-8 -->

## Round 8 by reviewer

- Recorded: 2026-08-17T20:31:19+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 8

Round 7's requested changes are applied coherently. Probe coverage is now a
categorical ten-row obligation matrix, an expected-`ok` refusal makes Step 1
incomplete, D01 and D02 exercise the two producer-side failures, F11 has a
measurement lifecycle, and the alternate-pair claim is correctly scoped to what
this recipe set provides. Answers 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A can all
stand. Round 8 remains `changes-requested` because the new patchelf doubles are
not bounded, so the positive witnesses do not yet prove they used the shipped
binary.

`find_patchelf` has three ordered resolution surfaces in the production script:
`$INSTALL_PREFIX/tools/bin/patchelf`, `$HOME/tools/bin/patchelf`, and then
`command -v patchelf`. The plan says only that D01 and D02 install a double where
that function resolves. It does not say which surface is changed, which state is
restored, or what establishes the tool used by the next witness. A double left
in any one of those locations can serve every later expected-`ok` fixture. The
complete tuples and zero-uncovered-obligations rule would remain green because
the double is expressly capable of returning literal successful values. This is
not merely cleanup hygiene: it changes what the positive evidence means.

Strengthen Q03 with both containment and positive identity. Run D01 and D02 in
separate subshells, each with its own private scratch `INSTALL_PREFIX`, `HOME`,
and command-search directory, an exit trap that removes the scratch state, and
an assertion that `find_patchelf` resolves exactly that case's double before the
production probe runs. The double must never replace or modify the canonical
shipped patchelf. Capture the parent resolution inputs before each subshell and
assert they are unchanged afterwards; no resolved-tool variable, cache, shell
function, alias, or file created for one case may survive into another case or
the positive suite.

Containment alone proves only that the known injection was removed. Before the
fault cases, record the canonical shipped patchelf's resolved absolute path,
version, and a validation-only content identity such as a digest. Immediately
after each fault-case subshell, require `find_patchelf` to return that same path
and identity, then rerun one named lawful witness whose complete tuple exercises
both successful probe directions. This post-fault sentinel makes leakage an
observed failure rather than an inferred absence. Merely scheduling D01 and D02
last is insufficient: it would hide the contamination instead of testing its
boundary.

Two small wording residues should move with that amendment. The four-row
alternate-pair status table is introduced as having "three values", and both the
plan and validation skeleton still say each fixture records "whether the
alternate pair is constructible". Say "four statuses" and "alternate-pair
status" respectively; the historical account that the previous universal
`not constructible` claim was false should remain.

No new question is required. These are implementability and evidence corrections
under Q03; Q09 remains sufficient and no other settled choice needs reopening.
Because the fix changes test isolation, tool-identity evidence, and Step 1's
completion criteria, it is more than covered wording and convergence is not yet
warranted.

### Question verdicts for plan relocation-force-rpath round 8

1. **Q01 -- keep 1A.** The independent effort harness remains the right
   boundary.

2. **Q02 -- keep 2A.** Preserve the standalone installer and measured Step 4
   checkpoint.

3. **Q03 -- keep and strengthen 3A.** Preserve the categorical witness matrix,
   hard Step 1 gate, D01/D02 producer tests, F11 lifecycle, and scoped
   alternate-pair model. Isolate each patchelf double in its own subshell across
   all three `find_patchelf` resolution surfaces, prove exact double resolution
   inside the fault case, and prove exact shipped-binary path and content
   identity plus a successful two-axis sentinel after each case.

4. **Q04 -- keep 4D.** The atomic behavior/report boundary remains sound.

5. **Q05 -- keep 5C.** The associative-array carrier and target gate remain
   sufficient.

6. **Q06 -- keep 6A.** The ordered RHEL session and narrow blocked state remain
   sufficient.

7. **Q07 -- keep 7A.** The source-safe seam remains implementable.

8. **Q08 -- keep 8A.** Formatter and reader remain correctly separated.

9. **Q09 -- keep 9A.** The derivation ledger, freeze distinction, corpus
   classes, permutations, path matrix, and adjudication rule remain sufficient.

10. **Other missing questions.** None.

### Requested changes for plan relocation-force-rpath round 8

Requested changes: 1. Isolate D01 and D02 separately across every `find_patchelf` resolution surface, assert exact double resolution inside each case, and remove all injected state on subshell exit.
2. Record the shipped patchelf's exact path, version, and content identity; re-establish them and rerun a successful two-axis witness after each fault case so double leakage is tested rather than assumed absent.
3. Make any surviving resolver override, cache, file, or search-path mutation a Step 1 failure; ordering the fault cases last is not a substitute.
4. Correct the remaining alternate-pair wording to four scoped statuses and an `alternate-pair status` field in both plan documents.

### Writer instructions for plan relocation-force-rpath round 8

Revise the implementation plan and validation skeleton together, then publish
another automated plan-review round.

1. Keep decisions 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A.
2. Under Q03 and Step 1, specify that D01 and D02 each run in a separate
   subshell with a private scratch `INSTALL_PREFIX`, `HOME`, and command-search
   directory. Install only that case's double there, use an exit trap to remove
   it, and assert before probing that production `find_patchelf` resolves the
   exact expected double path. The double must never overwrite the canonical
   shipped patchelf.
3. State the full isolation invariant: parent resolution inputs and any
   resolved-tool variable or cache are unchanged after each subshell; no double
   file, shell override, alias, or injected search location survives into the
   other fault case or any positive witness. Assert these conditions rather
   than relying on test order.
4. Before the fault cases, record the shipped patchelf's canonical resolved
   absolute path, version, and validation-only content identity. Immediately
   after each D01/D02 subshell, assert `find_patchelf` returns that same path and
   identity, then rerun a named lawful fixture whose complete tuple exercises
   successful rpath and interpreter probes. Treat failure of either identity or
   sentinel as a Step 1 failure.
5. Keep the categorical witness matrix and D01/D02's axis-local expectations.
   Do not replace isolation with ordering the doubles last, and do not count a
   controlled double as evidence for any successful shipped-patchelf obligation.
6. Correct the scoped alternate-pair wording: the table has four statuses, and
   fixture rows record an `alternate-pair status`, not whether a pair is
   constructible. Preserve the historical explanation that the earlier
   universal `not constructible` claim was false.
7. Mirror the double isolation, shipped-tool identity, post-fault sentinel, and
   alternate-status wording in the validation skeleton. Preserve Q09 unchanged.

### Final reviewer decision for plan relocation-force-rpath round 8

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-8 -->

## Round 9 by requestor

- Recorded: 2026-08-18T07:19:20+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 9

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 9

### Requestor assessment for plan relocation-force-rpath round 9

Round 9. All four round 8 requested changes are applied, none disputed. No
question is added. Answers stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. Q09 is
untouched.

**The doubles are bounded, and the boundary is asserted rather than tidied.** The
previous text said only that a double was installed "where `find_patchelf`
resolves", which names no surface, no restoration and nothing establishing which
binary the next witness used. The consequence is recorded in the plan: a double
left behind serves every later expected-`ok` fixture, and the complete tuples and
the zero-uncovered-obligations rule stay green, because a double is expressly
able to return literal successful values. That changes what the positive evidence
means rather than leaving a mess.

The three resolution surfaces are named with their source, read from
`install_pkg.sh` lines 301 to 314: `$INSTALL_PREFIX/tools/bin/patchelf`, then
`$HOME/tools/bin/patchelf`, then `command -v patchelf`, the last of which reads
the command search path and also resolves a shell function or an alias of that
name. All three are injection surfaces, so all three are containment
obligations.

**Containment.** `D01` and `D02` each run in their own subshell with a private
scratch `INSTALL_PREFIX`, `HOME` and command-search directory. Only that case's
double is installed, only in that scratch state, and an exit trap removes it. The
case asserts before probing that production `find_patchelf` returns exactly its
own expected double path, so a case resolving something else fails rather than
passing for the wrong reason, and the canonical shipped patchelf is never
overwritten, modified or shadowed in place. The parent's resolution inputs are
captured beforehand and asserted unchanged afterwards, with no double file,
resolved-tool variable, cache, shell function, alias or injected search location
surviving into the other fault case or any positive witness. Scheduling the fault
cases last is rejected by name: it hides contamination instead of testing for it.

**Positive identity, which is the half that carries the argument.** Containment
proves only that the known injection was removed, and the failure worth catching
is the unplanned one, whose symptom is that everything still passes. So the
shipped patchelf's resolved absolute path, version and a validation-only content
identity are recorded before the fault cases and re-asserted immediately after
each subshell, followed by one named lawful witness rerun end to end. Failure of
either is a Step 1 failure, which makes leakage an observed event rather than an
inferred absence.

**The sentinel is `F06`, and the choice is load-bearing.** The requested
formulation was a fixture exercising both successful probe directions, which
`F01` does. But `F01`'s expected rpath value is empty, so a leaked double
answering nothing on both axes would satisfy it and the suite would report a
clean restoration. `F06` expects a non-empty literal on both axes,
`/opt/cplx-probe/lib` and `/lib64/ld-linux-x86-64.so.2`. A sentinel whose
expectation an impostor can meet is not a sentinel.

A closing rule states that no controlled double is evidence for a successful
shipped-patchelf obligation: the matrix's five `ok` rows are satisfied by the
shipped binary or not at all.

**Wording.** The alternate-pair status table is introduced as having four
statuses, and both documents now say a row records its `alternate-pair status`
rather than whether a pair is constructible. The historical account is preserved
in both: the earlier universal `not constructible` claim was false, with the
duplicated-table, congruent-offset and slack-byte counterexamples intact.

All four are mirrored in the validation skeleton, and the categorical witness
matrix, the hard Step 1 gate, `D01` and `D02`'s axis-local expectations, `F11`'s
measurement lifecycle and every Q09 rule are preserved unchanged.

What round 9 should look at:

- The plan now requires a validation-only content identity for the shipped
  patchelf and does not say which tool produces it. The audited host-tool
  contract this effort is bound by names neither `sha256sum` nor `md5sum`. The
  harness's prerequisites are a separate list, and `readelf` was added there
  under Step 0, so there is likely a clean answer; but the plan has stated a
  requirement whose mechanism it never checked against the list it maintains for
  that purpose, which is the shape of several earlier findings in this exchange.

### Change summary for plan relocation-force-rpath round 9

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 8, applying round 8's four requested changes.
Every change is under Q03; Q09 is untouched.

Step 1, a new subsection "Bounding the doubles":

- It opens with what was wrong. The previous text said only that a double was
  installed "where `find_patchelf` resolves", which names no surface, no
  restoration and nothing establishing which binary the next witness used. It
  records the consequence: a double left behind serves every later expected-`ok`
  fixture while the complete tuples and the zero-uncovered-obligations rule stay
  green, because a double is expressly able to return literal successful values,
  so this changes what the positive evidence means rather than being untidiness.
- The three resolution surfaces are named and their source is cited: read from
  `install_pkg.sh` lines 301 to 314, `find_patchelf` tries
  `$INSTALL_PREFIX/tools/bin/patchelf`, then `$HOME/tools/bin/patchelf`, then
  `command -v patchelf`. The plan records that the third reads the command search
  path and also finds a shell function or an alias of that name, so all three are
  injection surfaces and all three are containment obligations.
- Containment: each of `D01` and `D02` runs in its own subshell with a private
  scratch `INSTALL_PREFIX`, a private scratch `HOME` and a private
  command-search directory. Only that case's double is installed, only inside
  that scratch state, and an exit trap removes it. The double never overwrites,
  modifies or shadows the canonical shipped patchelf in place.
- Before the production probe runs, the case asserts that production
  `find_patchelf` returns exactly that case's expected double path, so a case
  that silently resolved something else fails rather than passing for the wrong
  reason.
- The isolation invariant is asserted, not assumed: the parent's resolution
  inputs are captured before each subshell and asserted unchanged afterwards, and
  no double file, resolved-tool variable, cache, shell function, alias or
  injected search location survives into the other fault case or into any
  positive witness.
- Scheduling the fault cases last is rejected in as many words, with the reason
  that it hides contamination instead of testing for it, which is the opposite of
  what the two cases exist to do.
- Positive identity: before the fault cases the harness records the canonical
  shipped patchelf's resolved absolute path, its version and a validation-only
  content identity such as a digest. Immediately after each fault-case subshell
  it asserts that `find_patchelf` returns that same path and that the binary
  there still carries that identity, then reruns one named lawful witness end to
  end.
- The sentinel is named as `F06`, with the choice argued: its expected tuple is
  `ok` with a non-empty literal on both axes, `/opt/cplx-probe/lib` and
  `/lib64/ld-linux-x86-64.so.2`. `F01` is rejected as the weaker choice, since
  its expected rpath value is empty and a leaked double answering with nothing
  would satisfy it. A sentinel whose expectation an impostor can meet is not a
  sentinel.
- Failure of the identity assertion or of the sentinel is a Step 1 failure, which
  is what makes leakage an observed event rather than an inferred absence.
- A closing rule states that a controlled double is never evidence for a
  successful shipped-patchelf obligation: the witness matrix's five `ok` rows are
  satisfied by the shipped binary or not at all.
- The `D01`/`D02` paragraph above it drops "installed where `find_patchelf`
  resolves", the placement now being the new subsection's subject.

Step 1 completion criteria:

- The `D01`/`D02` criterion is restated without the vague placement clause.
- A criterion is added for the bounded double: own subshell, private scratch
  `INSTALL_PREFIX`, `HOME` and command-search directory covering all three
  resolution surfaces, asserted resolution to that case's own double before
  probing, exit trap, and asserted-unchanged parent inputs with no surviving
  double file, resolved-tool variable, cache, shell function, alias or injected
  search location. It states that ordering the fault cases last is not accepted
  in place of any of this.
- A criterion is added for shipped-tool identity: path, version and content
  identity recorded before the fault cases, re-asserted after each subshell, with
  `F06` rerun end to end as the post-fault sentinel and the reason for choosing
  it over `F01`. Failure of either is a failure of this step.
- A criterion is added that no controlled double counts as evidence for any of
  the matrix's five `ok` obligations.

Wording corrections:

- The alternate-pair status table's introduction now reads "in four statuses"
  rather than "the three values are distinct".
- The plan's matrix preamble now says each row names its `alternate-pair status`
  rather than "whether the alternate pair is constructible".
- The validation skeleton's corresponding sentence is corrected the same way.
- The historical account is preserved verbatim in both documents: that the
  previous universal `not constructible` claim was false, with the duplicated
  program header table, congruent segment offsets and slack-byte counterexamples
  intact.

Validation skeleton:

- Step 1's expectations carry the whole amendment: what the unbounded double
  would have done to the positive evidence, the three resolution surfaces with
  their source lines and the shell-function and alias surface, the per-case
  subshell and private scratch state, the pre-probe resolution assertion, the
  exit trap, the asserted-unchanged parent inputs and the full non-survival list,
  the rejection of ordering as a substitute, the recorded shipped-tool identity
  and its re-assertion, the `F06` sentinel with the argument for it over `F01`,
  the Step 1 failure consequence, and the rule that no double is evidence for a
  successful obligation.

Open questions:

- Q03's option 3A carries the bounded-double text: own subshell with private
  scratch state across all three resolution surfaces, asserted resolution to that
  case's double before probing, exit trap, asserted-unchanged parent inputs, and
  the shipped binary's recorded path, version and content identity re-asserted
  after each case with a non-empty two-axis sentinel rerun; and that no double is
  evidence for any successful obligation.
- It gains a pro: an unbounded double can satisfy the success witnesses itself,
  so the zero-uncovered rule would stay green while proving nothing about the
  shipped binary, and the post-fault identity check turns that from an inferred
  absence into an observed event.
- The framing paragraph records the two halves of the correction and that only
  the first was obvious, containment proving merely that the known injection was
  removed.
- Answers stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. No question is
  added.

Preserved per round 8's item 5 and item 7: the categorical witness matrix, the
hard Step 1 gate, `D01` and `D02`'s axis-local expectations, `F11`'s measurement
lifecycle, the scoped four-status alternate-pair model, and every Q09 rule
unchanged.

### Writer response for plan relocation-force-rpath round 9

Writer response: All four requested changes are applied. Nothing is disputed. The reviewer's
account of `find_patchelf`'s three surfaces was checked against
`install_pkg.sh` lines 301 to 314 before being written into the plan, and it is
exact, including that the third surface is `command -v`, which also resolves a
shell function or an alias of that name.

The writer flagged this one and the reviewer still had to finish it, which is now
the seventh time. That framing flatters the writer, though, and the more accurate
reading is worse. The round 8 flag said the double "is a fault-injection
mechanism with nothing stated to bound it" and named two candidate fixes,
subshell scoping and an identity assertion. Both appear in the reviewer's answer.
So the writer had the diagnosis and most of the treatment, wrote them into the
assessment as a question for someone else, and published. The gap between
flagging and fixing has stopped being a matter of not knowing what to do.

What the writer genuinely did not have is the second half, and it is the half
that carries the argument. Containment proves the **known** injection was
removed. The interesting failure is the one nobody planned, and no amount of
tidying detects it, because the evidence of contamination is precisely that
everything still passes: a leaked double is expressly able to return literal
successful values, so the complete tuples stay green and the
zero-uncovered-obligations rule stays satisfied while none of it says anything
about the shipped binary. The positive identity check, path plus version plus
content digest re-asserted after each fault case, is what turns an inferred
absence into an observed event. The writer's two candidate fixes were both
containment; neither would have caught a double that arrived by some route the
plan had not enumerated.

Choosing the sentinel exposed a smaller version of the same error, and the writer
records it because the reviewer asked only for "a named lawful fixture whose
complete tuple exercises both successful probe directions" and the obvious
reading of that would have been wrong. `F01` exercises both directions. Its
expected rpath value is empty. A leaked double that answered nothing on both
axes would satisfy an `F01` sentinel and the suite would report a clean
restoration. `F06` is the correct sentinel because both its expected values are
non-empty literals. A sentinel whose expectation an impostor can meet is not a
sentinel, and the writer would have picked `F01` a round earlier on the grounds
that it is the base fixture.

The two wording residues are corrected and are worth one sentence rather than
three: a table introduced as having three values while listing four, and a
preamble still asking whether a pair is "constructible" after the plan had spent
a round establishing that constructibility is not what the column records. Both
are the kind of thing that survives a careful edit because the surrounding
argument reads correctly, and both would have taught a later reader the wrong
model of the column.

One thing is offered for round 9 rather than claimed as settled.

The plan now requires a validation-only content identity for the shipped
patchelf, recorded before the fault cases and re-asserted after each. It does not
say which tool produces that digest, and the audited host-tool contract this
effort is bound by carries neither `sha256sum` nor `md5sum` by name. The
harness's tool prerequisites are a different list from the installer's, and
`readelf` was already added there under Step 0, so there is probably a clean
answer. But the plan states a requirement whose mechanism it has not checked
against the list it maintains for exactly that purpose, which is the shape of
several earlier findings, and the writer would rather name it than discover it
during implementation.

### Reviewer focus for plan relocation-force-rpath round 9

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-9 -->

## Round 9 by reviewer

- Recorded: 2026-08-18T07:39:33+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 9

Round 8's four requested changes are applied coherently. The three
`find_patchelf` surfaces are bounded per fault case, the parent state and shipped
tool are re-established positively, `F06` is the correct non-empty two-axis
sentinel, and controlled doubles cannot satisfy the five successful obligations.
The four-state alternate-pair model is also restored in both documents. Answers
1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A can all stand.

Round 9 remains `changes-requested` because the content identity is currently a
requirement without an executable mechanism. Path and version do not substitute
for it: a binary can be replaced at the same path and a double can reproduce the
same version string. The digest is therefore load-bearing evidence, not an
optional example, and "such as a digest" leaves an implementation choice in a
plan whose stated purpose is to contain such choices.

The clean mechanism follows the boundary already established for `readelf`.
Choose GNU `sha256sum` explicitly as a **validation-harness prerequisite**, not
an installer host tool. Step 0 must resolve it to an executable on the validation
host and record that capability before Step 1; absence leaves the harness gate
incomplete and is not permission to fall back to path-plus-version or a weaker
checksum. Step 1 should run `sha256sum -- "$resolved_patchelf_path"`, capture the
successful command substitution, extract the first field with Bash parameter
expansion, and require exactly 64 lowercase hexadecimal characters. Record that
value before D01/D02 and compare the same computation after each case.

The separation must also be mechanically guarded. Add `sha256sum` to the
execution checklist's negative grep over `install_pkg.sh`, and update Step 1's
host-tool criterion to say both `readelf` and `sha256sum` are harness-only. That
way the new prerequisite cannot drift into production unnoticed. This choice can
also serve the existing optional validation-only digest in Q09 without changing
Q09's authority or corpus decisions.

Two wording residues should be corrected in the same edit. The plan currently
says a fixture names "whether the alternate-pair status"; it should say "its
alternate-pair status". Later, the historical summary still asserts that the
`e_phoff`/`p_offset`/`p_filesz` pairs are "not constructible". Rewrite that
sentence to say the earlier text first claimed those pairs were provided and
then falsely called them unconstructible, while the scoped statuses above replace
both claims. The validation skeleton already expresses that history correctly.

No new question is required. These are an implementability correction under
Q03 and two covered wording fixes. Q09 remains sufficient and no other settled
choice needs reopening. Naming and gating a new validation prerequisite is more
than wording-only polish, so convergence is not yet warranted.

### Question verdicts for plan relocation-force-rpath round 9

1. **Q01 -- keep 1A.** The independent effort harness remains the right
   boundary.

2. **Q02 -- keep 2A.** Preserve the standalone installer and measured Step 4
   checkpoint.

3. **Q03 -- keep and strengthen 3A.** Preserve the bounded D01/D02 cases and
   `F06` sentinel. Make the content identity concrete with validation-only GNU
   `sha256sum`, gate it in Step 0, define its exact 64-hex capture and comparison,
   and mechanically exclude it from `install_pkg.sh`.

4. **Q04 -- keep 4D.** The atomic behavior/report boundary remains sound.

5. **Q05 -- keep 5C.** The associative-array carrier and target gate remain
   sufficient.

6. **Q06 -- keep 6A.** The ordered RHEL session and narrow blocked state remain
   sufficient.

7. **Q07 -- keep 7A.** The source-safe seam remains implementable.

8. **Q08 -- keep 8A.** Formatter and reader remain correctly separated.

9. **Q09 -- keep 9A.** The corpus authority, derivation audit, freeze, vectors,
   and adjudication rule remain sufficient; the selected validation digest does
   not reopen them.

10. **Other missing questions.** None.

### Requested changes for plan relocation-force-rpath round 9

Requested changes: 1. Select and gate validation-only GNU `sha256sum` as the exact shipped-patchelf
   content-identity mechanism.
2. Specify its fail-closed 64-lowercase-hex capture before D01/D02 and exact
   recomputation after each case, before the `F06` sentinel.
3. Add `sha256sum` to the installer negative host-tool grep and mirror the
   prerequisite and evidence rules in the validation skeleton.
4. Fix the malformed alternate-pair sentence and make the remaining historical
   `not constructible` sentence describe the false prior claim rather than
   repeat it.

### Writer instructions for plan relocation-force-rpath round 9

Revise the implementation plan and validation skeleton together, then publish
another automated plan-review round.

1. Keep decisions 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A.
2. Replace the open-ended "validation-only content identity such as a digest"
   with GNU `sha256sum` as the selected mechanism. State that it is a harness
   prerequisite and never an installer host tool.
3. Add `sha256sum` to Step 0's validation-host capability gate beside
   `readelf`. Require an executable resolution before Step 1; if unavailable,
   leave the gate incomplete rather than weakening the identity to path and
   version or selecting another checksum silently.
4. Specify the Step 1 operation: invoke `sha256sum --` on the exact absolute
   patchelf path, fail on a nonzero command result, extract the first output
   field using Bash built-ins, require exactly 64 lowercase hexadecimal
   characters, record it before D01/D02, and recompute and compare it after each
   fault-case subshell before running `F06`.
5. Add `sha256sum` to the execution checklist's negative host-tool grep over
   `install_pkg.sh`, and update Step 1's completion criterion to identify
   `readelf` and `sha256sum` as harness-only prerequisites. This must detect an
   accidental production use.
6. Mirror the prerequisite, exact digest operation, failure behavior, and
   negative production check in the validation skeleton. Leave Q09's decisions
   unchanged; the same validation-only digest may implement its already allowed
   digest path.
7. Correct two plan sentences: "whether the alternate-pair status" becomes
   "its alternate-pair status", and the later historical summary must describe
   `not constructible` as the earlier false claim rather than assert it as true.

### Final reviewer decision for plan relocation-force-rpath round 9

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-9 -->

## Round 10 by requestor

- Recorded: 2026-08-18T08:20:47+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 10

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 10

### Requestor assessment for plan relocation-force-rpath round 10

Round 10. All four round 9 requested changes are applied, none disputed. No
question is added. Answers stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. Q09 is
untouched.

**The content identity was a requirement without a mechanism, and the mechanism
turned out to be the whole check.** The plan had recorded path, version and "a
validation-only content identity such as a digest" as three components of one
identity, as though they corroborated one another. Two of the three are forgeable
by exactly the adversary the check exists to catch: a binary can be replaced at
the same path, and anything can print a version string. The digest is therefore
not one component among three but the only one that carries weight, and it was
the one left as an example.

GNU `sha256sum` is now named, and it is gated rather than assumed. Step 0
establishes three things instead of two, resolving `sha256sum` to an executable
on the validation host beside `readelf` and recording the capability before Step
1. Absence leaves the harness gate **incomplete**, and the plan refuses both
fallbacks by name: not path plus version, which is precisely the weakness the
digest removes, and not another checksum chosen quietly.

**The operation is specified fail-closed**, in four points. `sha256sum --` is
invoked on the exact absolute path `find_patchelf` returned, capturing the
command substitution. A nonzero result fails the step rather than yielding an
empty identity. The first whitespace-delimited field is taken with Bash parameter
expansion, so the harness does not acquire a tool while measuring whether a tool
was acquired. The field must be exactly 64 lowercase hexadecimal characters,
which is the rule that makes the comparison mean something: an empty capture
compared against an empty capture is equal, and that is the failure mode a digest
check has. The value is recorded before `D01` and `D02`, recomputed over the path
`find_patchelf` returns after each subshell, and must match byte for byte before
`F06` runs.

**The separation is guarded mechanically.** The execution checklist's negative
grep becomes
`grep -nE '\b(readelf|sha256sum|stat|wc|awk|perl|python)\b' src/setups/env/bin/install_pkg.sh`,
and the plan says why two legitimate harness tools sit in a pattern of forbidden
ones: they belong to the validation host and never to a deployment, so their
appearance in the installer is the drift the check exists to catch. Step 1's
host-tool criterion identifies both as harness-only prerequisites rather than
mentioning `readelf` alone.

**Two wording residues are corrected.** A fixture row names "its alternate-pair
status" rather than "whether the alternate-pair status". More seriously, the
historical summary at the end of the fixture matrix had gone on asserting that
the `e_phoff`, `p_offset` and `p_filesz` pairs are "not constructible", two
rounds after the same document established that claim to be false. It now
describes both prior claims, the pair recorded as provided and the correction
that called it impossible, and says the four scoped statuses replace both. The
validation skeleton already expressed that history correctly and is unchanged.

Both are mirrored in the validation skeleton, and every Q09 decision, the bounded
`D01`/`D02` cases, the `F06` sentinel, the categorical witness matrix, the hard
Step 1 gate, `F11`'s lifecycle and the four-status alternate-pair model are
preserved.

What round 10 should look at:

- The plan does not say whether `sha256sum` is resolved once at Step 0 to an
  absolute path and invoked by that path thereafter, or looked up by name at each
  use. It is used inside the fault-case sequence, where the command search path
  is deliberately manipulated, so a name lookup would resolve the verifying tool
  through the same machinery whose containment it is verifying. Accidental
  exploitation seems unlikely, but this is the class of thing this exchange has
  repeatedly found to matter, so it is named rather than assumed benign.

### Change summary for plan relocation-force-rpath round 10

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 9, applying round 9's four requested changes.
Every change is under Q03; Q09 is untouched.

Step 0, the capability gate:

- The gate now establishes **three** things rather than two.
- GNU `sha256sum` is added as a second harness prerequisite beside `readelf`,
  with the reason for naming a tool rather than leaving "such as a digest": the
  content identity is the only part of the check a double cannot forge, since a
  binary can be replaced at the same path and a double can print the same version
  string, so the digest is load-bearing evidence and not a corroborating detail.
- Step 0 must resolve it to an executable on the validation host and record that
  capability before Step 1. Absence leaves the harness gate **incomplete**, and
  the plan says in as many words that this is not permission to weaken the
  identity to path plus version, which is exactly what the digest strengthens,
  nor to substitute a weaker checksum silently.
- A closing paragraph states that both prerequisites are excluded from the
  installer **mechanically rather than by intention**, being named in the
  execution checklist's negative host-tool grep, and that the installer's own
  host-tool contract is unaffected because neither ever runs during an install.
- Step 0's completion criteria split the old combined line: the associative-array
  outcome is one criterion, and both harness prerequisites resolving and being
  recorded is another, with either absence leaving the gate incomplete and
  neither licensing a fallback.

Step 1, the positive identity mechanism:

- "a validation-only content identity such as a digest" is replaced. The plan now
  records all three of path, version and content identity and states that only
  the third is decisive, for the reasons above.
- The mechanism is specified as a four-point fail-closed procedure: invoke
  `sha256sum --` on the exact absolute path `find_patchelf` returned, capturing
  the command substitution; treat a nonzero result as a failure of the step
  rather than as an empty identity; take the first whitespace-delimited field
  with Bash parameter expansion, so no further external tool enters the harness
  to parse the output; and require exactly 64 lowercase hexadecimal characters,
  with the reason that a short, empty or oddly-cased value would mean comparing
  nothing against nothing.
- The recorded value is taken before `D01` and `D02`; after each fault-case
  subshell the same computation is repeated over the path `find_patchelf` then
  returns and must equal it byte for byte, and only then does the sentinel run.
- The corresponding completion criterion names the tool, the fail-closed capture,
  the parameter-expansion extraction and the 64-lowercase-hex requirement, and
  states the recompute-and-compare ordering before `F06`.

The negative host-tool check:

- The execution checklist's grep pattern gains `sha256sum`:
  `grep -nE '\b(readelf|sha256sum|stat|wc|awk|perl|python)\b' src/setups/env/bin/install_pkg.sh`
  must print nothing.
- A sentence explains why the two harness prerequisites are in a pattern whose
  other members are forbidden tools: they belong to the validation host and never
  to a deployment, so their appearing in the installer is the drift the check
  exists to catch.
- Step 1's host-tool criterion now identifies `readelf` and `sha256sum` as
  harness-only prerequisites named in that grep, replacing the previous wording
  that mentioned only `readelf` being outside it.

Wording corrections:

- "names the reader guard it exercises, its semantic oracle with citation,
  whether the alternate-pair status" is corrected to "its alternate-pair status".
- The historical summary at the end of the fixture matrix no longer asserts that
  the `e_phoff`, `p_offset` and `p_filesz` pairs are not constructible. It now
  says the column was mishandled twice over: first recording a pair as provided
  for those three, which this recipe set does not build, and then correcting that
  to "not constructible", which was false, as the counterexamples above show;
  the four scoped statuses replace both claims. The note that the same pass
  missed the `F06` against `F07` pair is kept.

Validation skeleton:

- Step 0's expectations now cover three assumptions, with both harness
  prerequisites named, the reason the digest tool is chosen rather than
  exemplified, the incomplete-gate consequence, the explicit refusal of both
  fallbacks, and the mechanical exclusion from the installer.
- Step 1's positive-identity paragraph carries the full
  `sha256sum` procedure: the exact invocation, the nonzero-result failure, the
  Bash parameter-expansion extraction with its reason, the 64-lowercase-hex
  requirement with its reason, and the recompute-and-compare before `F06`.
- The skeleton's account of the alternate-pair history was already correct and is
  unchanged.

Open questions:

- Q03's option 3A names the GNU `sha256sum` digest in place of "content
  identity", records it as a Step 0 harness prerequisite beside `readelf`,
  captured fail-closed at exactly 64 lowercase hex characters, and notes both
  prerequisites are in the installer's negative host-tool grep.
- It gains a pro: naming the digest tool and its exact capture closes the last
  place where the identity check was a requirement without a mechanism, since
  path and version are both forgeable and leaving the one unforgeable component
  as an example would have left the whole check to an implementer's choice.
- The framing paragraph is rewritten around that finding.
- Answers stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. No question is
  added.

Preserved per round 9's item 6: every Q09 decision unchanged, the same
validation-only digest being available to implement the digest path Q09 already
allows; and the bounded `D01`/`D02` cases, the `F06` sentinel, the categorical
witness matrix, the hard Step 1 gate, `F11`'s measurement lifecycle and the
four-status alternate-pair model.

### Writer response for plan relocation-force-rpath round 10

Writer response: All four requested changes are applied. Nothing is disputed.

The writer flagged this one and the reviewer supplied the argument that makes it
matter, which is a distinction worth keeping straight. The round 9 flag was
narrow: the plan requires a digest and the audited host-tool contract names no
checksum tool, so the mechanism may not exist. That is a supply question. The
reviewer's answer reframes it as an evidence question, and the reframing is the
substance. Path, version and digest were listed as three components of one
identity, as though they corroborated each other. They do not. A binary can be
replaced at the same path, and anything at all can print a version string, so two
of the three are forgeable by exactly the adversary the check is built against
and the digest is not a component of the identity but the whole of it. The plan
had left the only load-bearing element as an example, in a document whose stated
purpose is to contain implementation choices, and the writer had noticed only
that the example might be unbuildable.

That is a recognisable shape from earlier rounds. A list of three checks reads as
stronger than one check, and the writer had never asked what each member actually
withstands. The same reasoning retired the alternate-pair column's weaker anchor
in round 6 and chose `F06` over `F01` as the sentinel in round 8. Three times now
the correct move has been to ask which part of a check an impostor can satisfy,
and three times the writer has had to be shown.

The specification of the operation is accepted without reservation and is more
than pedantry. Taking the first field with Bash parameter expansion rather than
`awk` or `cut` keeps the harness from acquiring a tool while measuring whether a
tool was acquired, which would have been a quiet joke at the plan's expense.
Requiring exactly 64 lowercase hexadecimal characters is the part that makes the
check fail-closed: an empty capture compared against an empty capture is equal,
and that is the failure mode a digest comparison has, so the width and case rule
is not tidiness but the thing that stops the comparison succeeding vacuously.

Gating it in Step 0 and adding it to the negative grep are the two halves the
writer would have got half of. Adding a prerequisite without gating it moves the
failure from a recorded gate to an implementation surprise. Adding it without the
grep leaves a tool that is legitimate on the validation host and forbidden in the
installer with nothing but intention keeping it out, which is the same argument
the plan already made for `readelf` and had not generalised.

Both wording residues are corrected. The second is the more embarrassing: a
sentence still asserting that the pairs are "not constructible" survived two
rounds of the plan explaining, elsewhere in the same document, that this claim is
false. The correction had been written into the argument and not propagated to
the summary of the argument, which is how a document ends up carrying its own
retracted position in the place a reader is most likely to quote.

One thing is offered for round 10 rather than claimed as settled.

Step 0 now records both harness prerequisites as capabilities, and Step 1 uses
`sha256sum` inside the fault-case sequence, where the whole point is that the
command search path is deliberately manipulated. The plan does not say whether
`sha256sum` is resolved once at Step 0 to an absolute path and invoked by that
path thereafter, or looked up by name at each use. If it is looked up by name,
the private command-search directory that isolates the patchelf double is also on
the path when the post-fault digest is computed, and the tool that verifies the
restoration is itself resolvable through the machinery under test. The writer
does not think this is likely to be exploited by accident, and it is precisely
the class of thing this exchange has repeatedly found to matter, so it is named
rather than assumed benign.

### Reviewer focus for plan relocation-force-rpath round 10

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-10 -->

## Round 10 by reviewer

- Recorded: 2026-08-18T08:45:24+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 10

Round 9's requested changes are applied coherently. GNU `sha256sum` is now a
gated harness prerequisite, its capture is fail-closed and structurally
validated, its production exclusion is mechanical, and both alternate-pair
wording residues are corrected. Answers 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A
can all stand.

The round 10 flag identifies a real lifecycle ambiguity, but its stated failure
mode is not quite the one the plan contains. The digest is computed before the
fault cases and **after each fault-case subshell has exited**. At that point the
private command-search directory is no longer active and the parent resolution
inputs must already be unchanged. A name lookup performed there is therefore not
resolved through D01 or D02's private `PATH`.

The actual gap is cross-invocation state. The plan runs
`bash verify.relocation-rpath.sh --step N`; Step 0 and Step 1 are fresh harness
processes. An executable path resolved during the Step 0 run cannot remain in a
shell variable for the Step 1 run, while merely recording that it once existed
does not identify the executable the later run invokes. The plan must distinguish
the Step 0 **test of the prerequisite resolver** from the reusable runtime
preflight every dependent harness invocation performs.

Strengthen Q03 with one reusable validation-tool preflight. At the start of each
harness invocation that needs it, before sourcing or entering any case-specific
environment, resolve GNU `sha256sum` with Bash `type -P sha256sum`, require the
result to be an absolute regular executable path, and verify the required GNU
interface. Perform failure-prone commands before assigning the successful path
to one fixed read-only harness variable; do not combine resolution with a
`readonly` declaration in a way that can mask command-substitution failure.
Step 0 records that preflight and its path as capability evidence. Step 1 runs
the same preflight again and records the path it will actually use; it does not
inherit or promise equality with a path from a previous process.

Every Step 1 digest operation must invoke the fixed absolute path, for example
`"$SHA256SUM_BIN" -- "$resolved_patchelf_path"`, never the bare command name.
The initial digest runs in the parent before D01/D02. Each comparison runs in
the parent only after the fault subshell returns and the unchanged-parent
resolution assertions pass, then `F06` runs. The private subshell may inherit
the read-only variable but does not resolve or replace the checksum executable.
This closes the lifecycle without pretending Step 0 runtime state survives into
Step 1 and without enlarging the installer tool contract.

No new question is required. This is an implementability correction under Q03;
Q09 remains sufficient and no other settled choice needs reopening. Because it
changes the harness preflight lifecycle and the exact executable invoked, it is
more than wording-only polish and convergence is not yet warranted.

### Question verdicts for plan relocation-force-rpath round 10

1. **Q01 -- keep 1A.** The independent effort harness remains the right
   boundary.

2. **Q02 -- keep 2A.** Preserve the standalone installer and measured Step 4
   checkpoint.

3. **Q03 -- keep and strengthen 3A.** Preserve the bounded fault cases and
   fail-closed digest. Separate Step 0 capability evidence from runtime state:
   every dependent harness invocation reruns one preflight, pins GNU
   `sha256sum` to a read-only absolute executable path, and invokes only that
   path for Step 1's parent-side digest operations.

4. **Q04 -- keep 4D.** The atomic behavior/report boundary remains sound.

5. **Q05 -- keep 5C.** The associative-array carrier and target gate remain
   sufficient.

6. **Q06 -- keep 6A.** The ordered RHEL session and narrow blocked state remain
   sufficient.

7. **Q07 -- keep 7A.** The source-safe seam remains implementable.

8. **Q08 -- keep 8A.** Formatter and reader remain correctly separated.

9. **Q09 -- keep 9A.** The corpus authority, derivation audit, freeze, vectors,
   and adjudication rule remain sufficient.

10. **Other missing questions.** None.

### Requested changes for plan relocation-force-rpath round 10

Requested changes: 1. Replace the implied Step-0-to-Step-1 shell state with a reusable prerequisite
   preflight run by every dependent harness invocation.
2. Resolve GNU `sha256sum` before case-specific mutation to an absolute regular
   executable path, validate it fail-closed, and store it only after success in
   a fixed read-only variable.
3. Invoke that absolute path, never a bare checksum command, for the parent-side
   initial and post-fault digests; record the path used by the current run.
4. State and mirror the ordering that post-fault hashing occurs only after the
   subshell exits and parent resolution state is re-established, before `F06`.

### Writer instructions for plan relocation-force-rpath round 10

Revise the implementation plan and validation skeleton together, then publish
another automated plan-review round.

1. Keep decisions 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A.
2. Correct the round framing: the post-fault digest runs after the fault
   subshell exits, when the private command-search path is no longer active and
   parent resolution inputs have been re-established. The unresolved issue is
   that separate `--step 0` and `--step 1` processes cannot share a resolved
   shell variable.
3. Define one reusable harness prerequisite preflight. Run it at the start of
   every harness invocation that depends on the validation tools, before
   sourcing or any case-specific environment mutation. Step 0 tests and records
   this preflight; Step 1 invokes it again for the current process.
4. Resolve GNU `sha256sum` with Bash `type -P sha256sum`; require an absolute
   regular executable path and the required GNU interface. Treat any resolution,
   file, or interface failure as an incomplete gate. Complete those checks
   before assigning the path to a fixed read-only harness variable so a failed
   command substitution cannot be masked by the declaration builtin.
5. In Step 1, invoke only the pinned absolute path for every digest operation,
   for example `"$SHA256SUM_BIN" -- "$resolved_patchelf_path"`; prohibit a bare
   `sha256sum` lookup after preflight. Record the actual pinned path with the
   current run's evidence rather than claiming a shell value persisted from
   Step 0.
6. State the exact ordering: parent preflight and initial digest; D01 or D02 in
   its private subshell; subshell exit; unchanged-parent assertions; parent
   recomputation through the same pinned checksum path; digest comparison; then
   `F06`. The checksum executable is never resolved inside a fault subshell.
7. Mirror the reusable-preflight lifecycle, absolute pinned invocation, failure
   behavior, and ordering in the validation skeleton. Preserve Q09 unchanged.

### Final reviewer decision for plan relocation-force-rpath round 10

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-10 -->

## Round 11 by requestor

- Recorded: 2026-08-18T08:53:21+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 11

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 11

### Requestor assessment for plan relocation-force-rpath round 11

Round 11. All four round 10 requested changes are applied, none disputed. No
question is added. Answers stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. Q09 is
untouched.

**The previous round's flag named the wrong failure mode**, and the plan records
the correction rather than quietly adopting the fix. It supposed the post-fault
digest might resolve `sha256sum` through the fault case's private command-search
directory. It cannot: that digest runs after the subshell has exited, when the
private path is no longer in effect and the unchanged-parent assertions have
already passed. A lifetime question was real; the mechanism named for it was not
the defect.

**The defect is cross-invocation state.** The harness runs as
`bash docs/v0.27.0/verify.relocation-rpath.sh --step N`, so `--step 0` and
`--step 1` are separate processes. A path resolved in one cannot survive into the
other, and recording that a tool once existed identifies no executable a later
run invokes. "Step 0 resolves it and records the capability" was therefore doing
work it cannot do, and the plan had been reasoning about its steps as phases of
one execution while its own ready-to-run command says otherwise.

**One reusable preflight replaces the recorded resolution.** It runs at the start
of every harness invocation that depends on the validation tools, before the
installer is sourced and before any case-specific environment mutation, so
nothing a case arranges can influence what it resolves: `type -P sha256sum`,
which yields a path rather than a shell function or alias of that name; an
absolute path to a regular executable file; the required GNU interface; and only
then the assignment to one fixed read-only harness variable. `readelf` is pinned
the same way, the two differing only in which interface is verified.

That ordering is load-bearing. `readonly SHA256SUM_BIN="$(type -P sha256sum)"`
yields the exit status of `readonly` rather than of the substitution, so a failed
resolution is masked and the pin is frozen empty, which is the worst available
outcome: no error and an unusable variable that cannot be reassigned. Resolve,
check, then declare. `shellcheck` reports the combined form under SC2155, so the
gate this plan already runs catches a regression.

**Step 0 records a passing preflight, not a value later steps reuse.** Step 1
runs the same preflight in its own process and records the path it will use,
inheriting nothing and promising no equality, since two processes on a host that
changed between them may legitimately resolve differently and the run's evidence
should say what that run invoked.

**Every Step 1 digest invokes the pinned absolute path**,
`"$SHA256SUM_BIN" -- "$resolved_patchelf_path"`, and a bare `sha256sum` lookup
after the preflight is prohibited. The pin exists so that what verifies the
restoration cannot be resolved through a command path a case has touched; that
the current ordering makes a bare call safe today is not a reason to depend on
the ordering.

**The ordering is fixed and every digest happens in the parent**: preflight and
pin; initial digest; the fault case in its private subshell; subshell exit;
unchanged-parent assertions; parent recomputation through the same pinned path;
digest comparison; then `F06`. The checksum executable is never resolved inside a
fault subshell, which may inherit the read-only variable but neither resolves nor
replaces the executable. The recomputation sits after the exit for the sentinel's
reason: a measurement taken while the injected state is active describes the
injection rather than the restoration.

Both are mirrored in the validation skeleton, and every Q09 decision, the bounded
fault cases, the `F06` sentinel, the categorical witness matrix, the hard Step 1
gate, `F11`'s lifecycle, the four-status alternate-pair model and the negative
host-tool grep are preserved.

**On convergence**, since it was asked. Rounds 5 and 6 changed what the plan
tests; round 7 changed a pass condition; rounds 8, 9 and 10 have each gone one
mechanism deeper on a single artifact introduced in round 7. Each finding was
correct and each was smaller than the last, which is convergence in the ordinary
sense. Two qualifications keep it from being a claim. The writer's flag was wrong
on the mechanism this round for the first time, which reads as diminishing
returns on the writer's own review rather than as remaining risk. And Steps 2 and
5 have not been revised since round 4, and Step 6 since round 5, while the last
three rounds have all landed in Step 1: silence there reflects where the
attention has been, not evidence of correctness. One or two rounds is a plausible
estimate; asserting convergence now would not be.

What round 11 should look at, deliberately outside Step 1:

- Step 2's controlled tuples have not been revised since round 4, and Step 1's
  contract has changed substantially since: the asserted tuple is now complete
  including probe statuses and values, and both axis-local `failed` statuses are
  produced by controlled doubles at Step 1. The plan says twice that Step 2's
  tuples do not stand in for the producer tests, and says nothing about whether
  the set Step 2 constructs is still the right one. There may be tuples Step 2
  constructs that Step 1 now supplies as observed evidence, and tuples the
  completed contract implies that Step 2 does not construct. This has not been
  checked, and "unchanged since round 4" is not "still correct".

### Change summary for plan relocation-force-rpath round 11

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 10, applying round 10's four requested changes.
Every change is under Q03; Q09 is untouched.

Step 0, a new subsection "Step 0 harness prerequisite preflight":

- It opens with the fact the previous version had elided: the harness runs as
  `bash docs/v0.27.0/verify.relocation-rpath.sh --step N`, so each step is a
  fresh process. A path resolved during the `--step 0` run cannot survive into
  the `--step 1` run, and recording that a tool once existed does not identify
  the executable a later run invokes. It states that Step 0's job is to test and
  record the preflight rather than to hand Step 1 a value, and says why the
  distinction is made explicit: "Step 0 recorded it" reads like an answer and is
  not one.
- One reusable preflight is defined, run at the start of every harness invocation
  that depends on the validation tools, before the installer is sourced and
  before any case-specific environment mutation, so nothing a case arranges can
  influence what it resolves. Its four points are: resolve with Bash
  `type -P sha256sum`, which yields a path rather than a shell function or alias
  of that name; require an absolute path to a regular executable file; verify the
  required GNU interface; and only after all of those succeed, assign to one
  fixed harness variable and mark it read-only.
- The ordering of the fourth point is argued rather than asserted:
  `readonly SHA256SUM_BIN="$(type -P sha256sum)"` yields the exit status of
  `readonly` rather than of the substitution, so a failed resolution is masked
  and the variable is frozen empty, which is the worst outcome available, no
  error and an unusable pin that cannot be reassigned. Resolve, check, then
  declare. The plan notes that `shellcheck` reports the combined form under
  SC2155, so the gate it already runs catches a regression here rather than the
  reader having to remember it.
- Any resolution, file-property or interface failure leaves the gate incomplete.
- The same shape is applied to `readelf`, which is pinned the same way; the two
  prerequisites differ in which interface is verified and in nothing else.
- Step 0 runs the preflight and records it with the path it resolved as
  capability evidence. Step 1 runs the same preflight again and records the path
  it will use, inheriting nothing and promising no equality with Step 0's, with
  the reason: two processes on a host that changed between them are entitled to
  resolve differently, and the run's evidence should say what that run actually
  invoked.
- Step 0's completion criterion is rewritten accordingly: the preflight runs and
  is recorded with the paths it resolved for both tools, in the stated order so a
  failed substitution cannot be masked by the declaration builtin; any of the
  three failures leaves the gate incomplete; no absence licenses a fallback; and
  what is recorded is that the preflight passed here rather than a value later
  steps may reuse.

Step 1, the pinned invocation:

- The digest passage now opens by stating that this step runs the harness
  prerequisite preflight for its own process, pins `$SHA256SUM_BIN`, and records
  the path that run will use.
- Point 1 of the fail-closed procedure becomes
  `"$SHA256SUM_BIN" -- "$resolved_patchelf_path"` rather than a bare
  `sha256sum --`. The remaining three points are unchanged.
- A bare `sha256sum` lookup after the preflight is prohibited, with the reason:
  the pin exists so that what verifies the restoration cannot itself be resolved
  through a command path a case has touched, and a single bare call would give
  that back.

Step 1, the fixed ordering:

- An eight-point ordering is added, every digest happening in the parent process:
  the parent runs the preflight and pins `$SHA256SUM_BIN`; the parent computes
  and records the initial digest; `D01` or `D02` runs in its private subshell;
  the subshell exits, so its private command-search directory and scratch
  `INSTALL_PREFIX` and `HOME` are no longer in effect; the unchanged-parent
  resolution assertions pass; the parent recomputes over the path
  `find_patchelf` now returns through the same pinned path; the digests must be
  equal; `F06` runs.
- The checksum executable is never resolved inside a fault subshell. The subshell
  may inherit the read-only variable, inheriting a pinned absolute path being
  harmless, but neither resolves nor replaces the executable.
- The reason the recomputation and comparison sit after the subshell exits is
  stated with the same argument as the sentinel's: a measurement taken while the
  injected state is still active describes the injection rather than the
  restoration.
- The corresponding completion criteria are split in two: one requiring this step
  to run the preflight for its own process, record the pinned path rather than
  refer to Step 0's, and contain no bare `sha256sum` call after the preflight;
  and one restating the identity re-establishment in the stated order, with the
  recomputation explicitly after the subshell has exited and after the
  unchanged-parent assertions have passed.

Validation skeleton:

- Step 0's expectations carry the whole preflight: the fresh-process fact with
  the `--step N` invocation, that what is recorded is a passing preflight rather
  than a reusable value, the placement before sourcing and before case-specific
  mutation with its reason, the four resolution points, the SC2155 argument for
  the ordering, and the incomplete-gate consequence.
- Step 1's positive-identity paragraph carries the per-process preflight, the
  pinned absolute invocation with the prohibition on a bare lookup and its
  reason, the unchanged fail-closed capture rules, the fixed ordering with the
  subshell exit called out, the rule that the checksum executable is never
  resolved inside a fault subshell, and the reason the recomputation sits after
  the exit.

Open questions:

- Q03's option 3A now describes the reusable per-process preflight, the ordering
  of resolve, check and pin, the pinned absolute invocation, and the parent-side
  recomputation after subshell exit and unchanged-parent assertions.
- It gains a pro: rerunning the preflight per process is what makes the pin true
  rather than assumed, since the harness starts a new process per step and a
  recorded Step 0 resolution names no executable a Step 1 run will invoke.
- The framing paragraph records the finding and also records that the previous
  round's flag named the wrong failure mode: it supposed the post-fault digest
  might resolve through the fault case's private command path, which it cannot,
  since that digest runs after the subshell has exited. The lifetime question was
  real and the mechanism named for it was wrong, and the plan keeps that
  distinction rather than smoothing it over.
- Answers stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. No question is
  added.

Preserved per round 10's item 7: every Q09 decision unchanged, and the bounded
`D01`/`D02` cases, the `F06` sentinel, the categorical witness matrix, the hard
Step 1 gate, `F11`'s measurement lifecycle, the four-status alternate-pair model,
and the negative host-tool grep naming both prerequisites.

### Writer response for plan relocation-force-rpath round 11

Writer response: All four requested changes are applied. Nothing is disputed, and the correction
to the writer's own flag is accepted as the more useful half of the answer.

The round 10 flag was wrong about the mechanism and right that something was
wrong. It supposed the post-fault digest might resolve `sha256sum` through the
fault case's private command-search directory. It cannot: that digest runs after
the subshell has exited, when the private path is no longer in effect and the
unchanged-parent assertions have already passed. The writer had the ordering in
front of it, in a list the same document had just written, and reasoned about the
lifetime without consulting it. Being right that a lifetime question existed is
not the same as having found the defect, and the two would have been easy to
conflate in the writer's favor.

The actual gap is the one the writer could not see from inside a single step. The
harness runs as `verify.relocation-rpath.sh --step N`, so `--step 0` and
`--step 1` are separate processes. Every previous round had reasoned about the
plan's steps as though they were phases of one execution, and the plan's own
ready-to-run command says otherwise on the page. So "Step 0 resolves it and
records the capability" was doing work it cannot do: it names no executable that
a later run will invoke, and a variable cannot cross a process boundary. The
correct model is a preflight that is reusable rather than a resolution that is
recorded, and the writer had no version of that distinction at all.

The `readonly` detail is accepted and is the kind of thing the writer would have
written wrongly without noticing. `readonly VAR="$(cmd)"` reports the
declaration's exit status, not the substitution's, so a failed resolution passes
silently and leaves a pin that is both empty and unreassignable. It is worth
recording that `shellcheck` already reports the combined form under SC2155, which
means the plan's existing gate catches it: the plan had a mechanism for this
defect and did not know the defect was one it could commit.

The pinned invocation is accepted with its reason intact. A bare `sha256sum` call
after the preflight would resolve the verifying tool through the same command
path the fault cases exist to manipulate. It does not matter that the current
ordering makes that safe today; a check whose safety depends on the ordering of
other work is a check waiting for the ordering to change, and pinning removes the
dependency instead of documenting it.

Now the question of convergence, which is asked directly and deserves a direct
answer rather than an optimistic one.

The trend is real but slower than it looks. Rounds 5 and 6 changed what the plan
tests. Round 7 changed a pass condition. Rounds 8, 9 and 10 have each been one
mechanism deep on a single artifact introduced in round 7, the patchelf double:
bound it, name the tool that verifies it, fix that tool's lifecycle. Each finding
was correct, none was cosmetic by the reviewer's own standard, and each was
smaller than the last. That is convergence in the ordinary sense.

The honest qualification is that the writer has offered a flag at the end of
every round and the reviewer has found something in every round, and the two
facts are related. This round's flag was, for the first time, wrong on the
mechanism, which suggests the writer is now generating candidate defects faster
than it can evaluate them. That is a signal about diminishing returns rather than
about remaining risk.

So: convergence is plausibly one or two rounds away, and the writer would not
assert it now. Two things would have to hold. The preflight would have to survive
without a further mechanism question, and the writer's judgement about that is
worth little, having been wrong about a smaller version of it this round. And no
finding would have to arrive in a part of the plan nobody has looked at recently,
Steps 2 and 5 having been untouched since round 4 and Step 6 since round 5.
Silence there is not evidence: the last three rounds have all landed in Step 1,
and that is where the attention has been.

One thing is offered for round 11, and it is deliberately not a mechanism
question in Step 1.

Steps 2 and 5 have not been revised since round 4, and Step 1's contract has
changed substantially since: the tuple asserted is now complete, including probe
statuses and values, and both axis-local `failed` statuses are produced by
controlled doubles at Step 1. Step 2's cases feed the classifier controlled
tuples, and the plan now says in two places that those do not stand in for the
producer tests. What the plan does not say is whether Step 2's controlled tuples
are still the right set given that Step 1 now produces real ones: there may be
tuples Step 2 constructs that Step 1 can now supply as observed evidence, and
tuples Step 2 does not construct that the completed contract implies. The writer
has not checked, and would rather say so than let "unchanged since round 4" pass
for "still correct".

### Reviewer focus for plan relocation-force-rpath round 11

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-11 -->

## Round 11 by reviewer

- Recorded: 2026-08-18T09:03:29+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 11

Round 11 does show convergence, but it is not yet a convergence round.

The round 10 repair is coherent. The plan now treats each `--step N` run as a
fresh process, reruns one prerequisite preflight in each dependent invocation,
checks resolution before making the pin read-only, and performs both identity
measurements in the parent around the bounded fault subshell. The earlier
private-`PATH` explanation is correctly withdrawn. No further Step 1 mechanism
change is required by this review.

Three bounded validation gaps remain.

First, Step 2 has not inherited the contract Step 1 now promises. Its complete
test specification is still one sentence naming all seven cases, two `$HOME`
overlaps, ambiguity, structural failure, and "each of the four probe statuses".
There are not four global probe states: there are two independent status fields,
each with four tokens, accompanied by two independently present or absent
values. A flat token checklist can pass without ever constructing either
axis-local failure (`rpath=failed` with a surviving interpreter value, and the
converse), and without proving that every controlled row is a complete,
producer-valid tuple. In Bash, a missing associative-array key is especially
dangerous because an unchecked expansion can look like the intended empty
value. Step 1 proves producer behavior and Step 2 says its controlled tuples do
not substitute for that proof, but nothing currently proves that the controlled
classifier inputs conform to the producer contract or that representative real
outputs cross the seam.

Second, Step 5 states several positive documentation obligations and tests only
two negative residues. Deleting the relevant prose would make both grep checks
green while leaving the tag, population, disposition, untouched-object,
`LD_LIBRARY_PATH`/`setenv`, and library-side-check promises undocumented. The
completion criteria therefore do not establish the step's expected outcome.

Third, Step 6's own inventory obligation is absent from its completion criteria,
and the plan disagrees with itself about the selected program set. Step 2 says
the 110 libraries and the python ELF are selected and every other program is
left alone; Step 6 says the inventory selects the 110 libraries and the python
and git executables. Both cannot be the acceptance oracle. The authoritative
settled classifier must decide that set, and the plan must use the same explicit
program inventory in Steps 2, 4, and 6. The Step 6 criteria must then require the
retained inventory and the python-ELF assertion rather than merely describe them
in `behavior`.

These are more than wording edits, so the disposition is
`changes-requested`. They do not reopen any settled design choice. They form a
finite exit condition: one classifier-contract matrix and bridge, one positive
documentation coverage check, and one reconciled acceptance inventory. Steps 5
and 6 were reviewed directly rather than treated as correct because they were
quiet. Subject to those changes surviving the next review without a new
substantive defect, convergence is in sight.

### Question verdicts for plan relocation-force-rpath round 11

No new open question is required. The live findings are missing or conflicting
implementation evidence for decisions the plan says are already settled, not
new design choices.

- Q01: choose 1A. The separate harness preserves the completed shared-body
  evidence.
- Q02: choose 2A. Measurement with requirement-level escalation for a split
  keeps the standalone deployment contract intact.
- Q03: choose 3A. The independent fixture oracle, complete producer tuples,
  bounded fault injection, and per-process prerequisite preflight remain the
  strongest option. Step 2 must now consume that complete contract explicitly;
  this is a consequence of 3A, not a different fixture-source choice.
- Q04: choose 4D. The uncalled formatter preparation followed by atomic
  behavior-and-emission wiring remains sound.
- Q05: choose 5C. The fixed associative array and its exact-target capability
  debt remain properly bounded.
- Q06: choose 6A. The terminal blocked state remains correctly distinguished
  from a RHEL session that never opened.
- Q07: choose 7A. The source-safe boundary remains necessary for production
  function tests.
- Q08: choose 8A. Keeping the reader in the harness preserves the standalone
  installer and the independence of the grammar ends.
- Q09: choose 9A. The ranked, audited, frozen corpus remains the only option
  that detects two implementations agreeing on the same error.

The options remain materially distinct and the recorded answers follow from the
confirmed constraints. No answer changes in this round.

### Requested changes for plan relocation-force-rpath round 11

Requested changes: 1. Specify Step 2's classifier tests as complete, contract-valid two-axis
   tuples rather than a flat occurrence of four status tokens.
2. Add representative production-observer-to-classifier bridge cases, including
   both axis-local failures, without conflating producer and consumer evidence.
3. Add positive Step 5 documentation coverage so deleting relevant prose cannot
   satisfy the negative grep.
4. Reconcile the contradictory python-only versus python-and-git program
   inventory against the settled specification and use one explicit set across
   Steps 2, 4, and 6.
5. Make the inventory, python ELF, excluded-program, and categorical retained-
   capture checks explicit Step 6 completion criteria, mirrored in the
   validation skeleton.

### Writer instructions for plan relocation-force-rpath round 11

Keep answers 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, and 9A unchanged. Make the
following plan and validation-skeleton changes.

1. Replace Step 2's flat controlled-tuple list with an explicit classifier
   contract matrix. Every row must state the complete normalized associative
   array: structural fields, both probe statuses, value presence, and each
   literal value when present. Require the array to be cleared, populated with
   the exact key set, and checked against the tuple invariants before the
   classifier is invoked. Cover every ordered case and boundary, both `$HOME`
   overlaps, both successful tag forms, ambiguity, structural inconclusiveness,
   both `skipped` producers, and both axis-local `failed` combinations. Do not
   ask for the Cartesian product of impossible combinations.

2. Add a producer-to-consumer bridge in Step 2. Feed representative actual Step
   1 observations through the classifier, including a library, no-dynamic
   object, `DT_RPATH`, `DT_RUNPATH`, ambiguity, one structural rejection, D01,
   and D02, and assert the same outcomes as the corresponding controlled rows.
   Keep the distinction that Step 1 proves production of a tuple while Step 2
   proves its consumption. A controlled tuple or controlled double must not
   count as both claims.

3. Give Step 5 positive completion evidence. Add a small page-by-obligation
   coverage table, or equivalent explicit assertions, for the written tag, the
   three populations, both disposition axes, untouched objects, the
   `LD_LIBRARY_PATH`/`setenv` consequence, the how-to's exact-`RPATH` check, and
   its library-side check. Retain the stale-wording grep as a negative backstop;
   do not let deletion of the relevant prose satisfy the step.

4. Resolve the selected-program contradiction from the already-authoritative
   requirement/design: Step 2 currently says every program other than python is
   untouched, while Step 6 says git executables are selected. State one exact
   inventory consistently in Steps 2, 4, and 6. If git programs are selected,
   name the expected objects or count; if they are not, remove that Step 6
   claim. In all cases retain an explicit python-ELF assertion, since its
   omission is the failure the requirement's acceptance was designed to catch.

5. Promote the full-inventory checks into Step 6 completion criteria: retained
   walked and selected counts/populations, the explicit program assertions,
   excluded-program preservation, and acceptance of each retained capture by
   the categorical reader. Mirror all changes in the validation skeleton.

For the next round, report these as validation-closure changes. Do not create a
new open question unless the authoritative requirement and design genuinely do
not settle the program inventory.

### Final reviewer decision for plan relocation-force-rpath round 11

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-11 -->

## Round 12 by requestor

- Recorded: 2026-08-18T09:20:19+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 12

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 12

### Requestor assessment for plan relocation-force-rpath round 12

Round 12. All five round 11 requested changes are applied, none disputed. No
question is added and no answer changes: 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. All
five are validation closure. Nothing in Step 1 or Step 3 is touched, and for the
first time since round 5 no finding was in Step 1.

**The plan contradicted itself about which objects the pass selects.** Step 2
said the 110 flagged libraries and the python ELF selected with every other
program left alone; Step 6 said the 110 libraries and the python **and git**
executables. Both were serving as the acceptance oracle. This was not the plan's
to settle by preference, and the design settles it under "Two owners, overlapping
objects, disjoint claims": the 110 flagged libraries selected, the python and git
programs selected, and every other archive program left rpath-excluded.

The set is now stated once, in Step 2, and used verbatim by Steps 4 and 6: the
110 flagged libraries as case 4; the python program asserted **explicitly by
name**, since its omission is the failure the requirement's acceptance was
written to catch; the git programs asserted by their **enumerated object paths**
from the `develop#24` inventory rather than by a remembered count, because a
count is a fact about one snapshot; and every other archive program preserved as
case 7 and asserted so rather than merely unmentioned.

**Step 2 had not inherited the contract Step 1 now promises.** Its whole test
specification ended "and each of the four probe statuses", which names a state
space the design does not have: there are two independent status fields, each
drawn from `ok`, `skipped`, `blocked` and `failed`, with two independently
present or absent values beside them. A checklist satisfied by observing each
token somewhere never has to construct either axis-local failure, which is
precisely the pair `D01` and `D02` exist to produce.

Every controlled row is now a complete, contract-valid tuple: the array cleared,
populated with the exact key set with nothing missing and nothing extra, every
structural field, both statuses, both value-presence facts, each literal value
where present, and the invariants checked before the classifier is invoked. The
exact-key rule is load-bearing in Bash, where an unset associative-array key
expands to the empty string, so a forgotten `interp_probe_status` is
indistinguishable from a deliberate empty one and the classifier would branch on
a value nobody wrote. The row groups cover the seven ordered cases, both `$HOME`
overlaps, both successful tag forms, ambiguity, structural inconclusiveness, both
`skipped` producers and **both axis-local failure combinations**, without
demanding combinations the observer cannot produce.

**A producer-to-consumer bridge closes what neither layer sees alone.** The plan
said twice that Step 2's controlled tuples do not substitute for Step 1's
producer evidence and never said the converse, so nothing showed that the
controlled inputs conform to the contract the producer emits, and both layers
could be internally correct about a contract neither implements. Representative
real Step 1 observations now cross the seam, a library, a no-dynamic object,
`DT_RPATH`, `DT_RUNPATH`, an ambiguous object, one structural rejection, `D01`
and `D02`, each yielding the same outcome as its corresponding controlled row. No
controlled tuple or double counts as evidence for both production and
consumption.

**Step 5 tested two negative greps against eight positive obligations.** Deleting
the relevant prose would have satisfied both, and a page whose ELF section had
been removed entirely would have gone green. An eight-row coverage table is now
asserted page by page, with the stale-wording grep kept as a backstop on the same
argument the plan applies to the Step 0 baseline in Step 3: absence of the wrong
thing is not presence of the right one.

**Step 6's inventory obligation lived in `behavior` rather than in its completion
criteria**, which is the difference between a description and a check. It is now
a criterion, requiring the retained walked and selected counts and populations,
the by-name python assertion, the enumerated git objects, and excluded-program
preservation, with an excluded program quietly rewritten failing the step. A
further criterion requires every retained capture to be accepted by the Step 3
categorical reader rather than read by eye.

All five are mirrored in the validation skeleton.

**On convergence, asked again and answered less optimistically than last round.**
Last round's estimate was one or two rounds, qualified by the observation that
the quiet steps were quiet because nobody had looked. The reviewer looked and
found three things, one of them a flat self-contradiction between two plainly
worded sentences that survived eleven rounds of a review that has caught the
width of a stored ELF field. That is evidence for the qualification and against
the estimate: the previous three rounds were small because they were all in the
most-worked part of the document, not because the document was nearly finished.

What has changed is the shape of the remaining work. These findings are all
validation closure, none reopens a decision, the exit condition is finite and
enumerated, and Steps 2, 5 and 6 have now been read directly rather than assumed
sound. The unexamined surface is down to Step 0's seam, Step 4's wiring, and the
addendums. So: one or two rounds again, for a better reason than last time, and
conditional on the same thing, that these changes survive a reading the writer
cannot perform on its own work.

What round 12 should look at, chosen from what has not been read recently:

- Step 4 has not been revised since round 5. Since then Step 1 acquired a
  complete tuple contract with both probe axes, Step 2 acquired the ordered-case
  matrix and now the bridge, and Step 3 acquired the corpus and its three
  classes. Step 4's criteria still speak of a one-object run emitting "exactly
  the capture the design shows" with the Step 3 reader accepting it. Whether that
  is still the right integration assertion given three layers that now assert
  considerably more, and whether the capture the design shows is still the
  capture a completed pass would emit, has not been checked. This is an
  unexamined area rather than a suspected defect.

### Change summary for plan relocation-force-rpath round 12

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 11, applying round 11's five requested changes.
All five are validation closure; no design choice is reopened and no answer
changes. Nothing in Step 1 or Step 3 is touched.

The selected set, reconciled and stated once:

- Step 2's expected outcome gains a subsection, "The selected set, stated once".
  It records the contradiction plainly: this step said the 110 flagged libraries
  and the python ELF selected with every other program left alone, while Step 6
  said the 110 libraries and the python **and git** executables, and both were
  being used as the acceptance oracle.
- It records that the plan had no business settling this by preference and cites
  the design, "Two owners, overlapping objects, disjoint claims": the 110 flagged
  libraries selected, the python and git programs selected, and every other
  archive program left rpath-excluded.
- A four-row table states the inventory in the one form Steps 2, 4 and 6 use: the
  110 flagged libraries as case 4; the python program selected and asserted
  **explicitly by name**, since its omission is the failure the requirement's
  acceptance was written to catch; the git programs selected and asserted by
  their **enumerated object paths** recorded from the `develop#24` inventory; and
  every other archive program rpath-excluded as case 7 and asserted as preserved
  rather than merely not mentioned.
- The reason for enumerating rather than counting the git objects is stated: a
  count is a fact about one inventory snapshot and would pass silently on a
  different one.
- Step 4's completion criterion now names that same set alongside its `readelf
  -d` assertions, so the three steps use one statement rather than three
  paraphrases.
- Step 6's behavior section says the classifier is exercised to show it selects
  exactly the set Step 2 states once, using that statement rather than a
  paraphrase.

Step 2, the classifier contract matrix:

- The one-sentence test specification is replaced. The plan records why its
  phrasing was wrong rather than merely thin: "each of the four probe statuses"
  names a thing that does not exist, there being two independent status fields
  each drawn from `ok`, `skipped`, `blocked` and `failed`, with two independently
  present or absent values beside them. A checklist satisfied by observing each
  token somewhere can pass without ever constructing either axis-local failure,
  which is the pair Step 1 now goes to considerable trouble to produce.
- Every row is now a complete, contract-valid tuple: the array cleared, populated
  with the exact key set with nothing missing and nothing extra, every structural
  field stated, both probe statuses, the presence or absence of each probe value,
  and each literal value where present, with the tuple invariants checked before
  the classifier is invoked so a malformed input fails as a defective test rather
  than as a classifier result.
- The exact-key-set rule carries its reason: in Bash an unset associative-array
  key expands to the empty string, so a row that forgot `interp_probe_status` is
  indistinguishable at the point of use from one that meant it empty, and the
  classifier would branch on a value nobody wrote.
- A row-group table replaces the flat list: the seven ordered cases; both `$HOME`
  overlaps; both successful tag forms; ambiguity; structural inconclusiveness
  with every other field cleared and both probes `blocked`; both `skipped`
  producers; and **both axis-local failure combinations**, `rpath_probe_status:
  failed` with a surviving interpreter status and value, and the converse. The
  plan states it does not ask for the Cartesian product of combinations the
  observer cannot produce.

Step 2, the producer-to-consumer bridge:

- A new subsection states the division: Step 1 proves the production of a tuple,
  Step 2 proves its consumption, and a controlled tuple or controlled double may
  not be counted as both claims. The plan already said the first half twice; the
  converse needed saying too.
- What was missing between them is named: nothing showed that the controlled
  inputs conform to the contract the producer actually emits.
- Representative real Step 1 observations now cross the seam: a library, an
  object with no `PT_DYNAMIC`, a `DT_RPATH` object, a `DT_RUNPATH` object, an
  ambiguous one, one structural rejection, and the two fault cases `D01` and
  `D02`. Each must yield the same outcome as its corresponding controlled row,
  and a disagreement means the controlled rows have drifted, which is the failure
  neither layer can see alone.
- Step 2's completion criteria gain the complete-tuple rule, the row-group
  coverage including both axis-local combinations, the bridge with its eight
  named observations, the prohibition on double-counting evidence, and the
  inventory assertion against `develop#24`.

Step 5, positive documentation coverage:

- The test-first section now has two checks where it had one, and states why the
  one was insufficient: a stale-wording grep is a negative test that passes when
  the offending phrase is absent, so deleting the surrounding prose satisfies it,
  and a page whose ELF section had been removed entirely would have gone green
  against eight stated positive obligations.
- An eight-row coverage table is added, asserted page by page:
  `relocation-tools.md` for the tag actually written, the three populations, the
  rpath disposition axis, the interpreter disposition axis, and what the pass
  leaves untouched; `why-binaries-remember-the-build-home.md` for the
  install-time rewrite now producing `DT_RPATH` with its consequence for
  `LD_LIBRARY_PATH` and for `setenv`; and
  `relocate-an-install-to-another-prefix.md` for a check expecting `RPATH`
  exactly rather than either tag, and for the library-side check.
- The stale-wording grep is kept as a backstop, with the same argument the plan
  already applies to the Step 0 baseline in Step 3: absence of the wrong thing is
  not presence of the right one.
- Completion criteria now require every row of the coverage table to be asserted
  present, with the grep clean as a backstop rather than as the evidence.

Step 6, inventory checks as criteria:

- The full inventory check is promoted from `behavior` into the completion
  criteria, with the difference named: a description is not a check.
- The criterion requires the retained evidence to carry the walked and selected
  counts and populations, and the assertions to be the ones Step 2 states once,
  the 110 flagged libraries as case 4, the python program asserted by name, the
  enumerated git objects, and every other archive program preserved as case 7. An
  excluded program quietly rewritten fails the step.
- A further criterion requires **every retained capture to be accepted by the
  Step 3 categorical reader** rather than read by eye, since a capture no reader
  accepted is not acceptance evidence.

Validation skeleton:

- Step 2's expectations carry the complete-tuple rule with the four-probe-statuses
  correction, the Bash unset-key reason, the row-group coverage including both
  axis-local failures, the bridge with its eight observations and the
  no-double-counting rule, and the reconciled inventory with the design citation
  and the enumerate-not-count reason.
- Step 5's expectations carry the per-obligation coverage table with all eight
  obligations named by page, the reason two negative greps established none of
  them, and the backstop framing.
- Step 6's expectations carry the inventory check as a criterion, the by-name
  python assertion with its reason, the enumerated git objects, excluded-program
  preservation, and the categorical-reader acceptance of every retained capture.

Open questions:

- The framing paragraph is rewritten around the three findings and records that
  for the first time in six rounds none of them is in Step 1.
- Answers stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. No question is
  added, per the instruction that the authoritative requirement and design do
  settle the program inventory, which they do.

Preserved: every Q09 decision, the Step 1 preflight and pinned digest, the
bounded fault cases, the `F06` sentinel, the categorical witness matrix, the hard
Step 1 gate, `F11`'s lifecycle, the four-status alternate-pair model, and the
negative host-tool grep naming both prerequisites.

### Writer response for plan relocation-force-rpath round 12

Writer response: All five requested changes are applied. Nothing is disputed. The program
inventory was settled from the design rather than by preference, and no new
question was created, because the design does settle it.

The inventory contradiction is the most instructive finding of the whole
exchange, and it is worth being precise about why. It is not a subtle one. Step 2
said every program other than python is left alone; Step 6 said the python and
git executables are selected. Two sentences, in one document, in plain language,
disagreeing about the acceptance oracle. It survived eleven rounds of a review
whose findings have included the width of a stored ELF field and the exit status
of a declaration builtin. Both the writer and the reviewer read this document
repeatedly at a level of care that caught `Elf64_Dyn`'s membership, and neither
read the two claims against each other.

The reason is worth stating rather than deflecting. Every round since round 4 has
been driven by the previous round's findings, and findings concentrate: rounds 8
through 10 were all one artifact deep in Step 1. Depth-first attention has a
blind spot exactly where nothing is currently wrong enough to attract it, and
"unchanged since round 4" quietly became "reviewed". The writer's round 11
assessment named that risk in general terms and pointed at Step 2's tuples, which
is where a piece of this finding lived, but did not think to check the plan's own
claims against each other. Naming the class of blind spot is not the same as
looking in it.

The Step 2 finding is accepted with the correction that matters most. "Each of
the four probe statuses" is not merely vague, it is a description of a state
space the design does not have. The tuple carries two independent status fields
and two independently present or absent values, and the writer's own Step 1 work
had spent two rounds establishing exactly that, building `D01` and `D02` to
produce the two axis-local failures because nothing else would. Then the
consuming step's specification, written before all that and never revisited,
asked for four tokens in any arrangement, which those two cases are not required
to satisfy. The producer was rebuilt and the consumer's contract was left
describing the old shape.

The bridge is the reviewer's addition and closes something the writer had argued
itself out of noticing. The plan says twice that Step 2's controlled tuples do
not substitute for Step 1's producer evidence, and the writer treated that
separation as complete. It is only half a rule. Nothing showed that the
controlled tuples resemble what the producer emits, so both layers could be
internally correct while agreeing about a contract neither implements. That is
the same shape as the fixture generator and the observer in round 2 and the two
grammar ends in round 5, and it is now the third time this exchange has found it
in a different place.

Step 5's finding is the plainest. Eight positive obligations, two negative greps,
and deleting the prose passes both. The writer had written the obligations in the
behavior section and the checks in the completion criteria and never compared the
two lists, which is the same omission as Step 6's inventory living in `behavior`
rather than in the criteria. Two steps, one habit: describing what will be true
and then testing something adjacent.

On convergence, asked again and answered less optimistically than last round.

Last round's estimate was one or two rounds, with the qualification that the
quiet steps were quiet because nobody had looked. The reviewer looked, and found
three things, one of them a flat self-contradiction. That is evidence for the
qualification rather than for the estimate, and the honest update is that the
estimate was made from the wrong sample: the previous three rounds had been small
because they were all in the most-worked part of the document, not because the
document was nearly finished.

What has genuinely changed is the shape of the remaining work. These three
findings are all validation closure, none reopens a decision, and the reviewer's
exit condition is finite and enumerated. Steps 2, 5 and 6 have now been read
directly rather than assumed sound. The parts of the plan that have never been
the subject of a finding are now few: Step 0's seam, Step 4's wiring, and the
addendums. So the writer's estimate is one or two rounds again, but for a better
reason than last time, that the unexamined surface has shrunk rather than that
the findings have got smaller. And it remains conditional on the same thing it
was conditional on before, which is that these changes survive a reading the
writer cannot perform on its own work.

One thing is offered for round 12, chosen from what has not been read recently.

Step 4 is the atomic integration and has not been revised since round 5, when its
completion criteria gained the successor identifier assertion. Since then Step 1
has acquired a complete tuple contract with both probe axes, Step 2 has acquired
the ordered-case matrix and now the bridge, and Step 3 has acquired the corpus
and its classes. Step 4's criteria still speak of a one-object run emitting
"exactly the capture the design shows" and the Step 3 reader accepting it. The
writer has not checked whether that is still the right integration assertion
given three layers beneath it that now assert considerably more, nor whether the
capture the design shows is still the capture a completed pass would emit. This
is offered as an unchecked area rather than as a suspected defect, which is the
distinction the last two rounds have taught.

### Reviewer focus for plan relocation-force-rpath round 12

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-12 -->

## Round 12 by reviewer

- Recorded: 2026-08-18T09:42:09+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 12

Round 12 is not convergence-ready, but convergence is now visible for a better
reason than a shrinking round count: the remaining defect is confined to the
atomic integration step, while this review also read Step 0's seam and the
addendums and found no further substantive gap there.

All five round 11 changes are applied correctly. Step 2 now carries complete
two-axis tuples and an explicit producer-to-consumer bridge; the inventory is
settled from the design and stated consistently; Step 5 has positive evidence;
and Step 6 promotes the inventory and categorical-reader checks into completion
criteria. No answer changes and no new design question is needed.

Step 4, however, currently conflates two different suites. Step 3's contract
corpus contains canonical formatter vectors, other reader-valid permutations
that the formatter is not required to emit, and deliberately malformed vectors
that production must reject and must never emit. Those report-contract cases
cannot be "re-run unchanged, now against captures a real run produced", and the
completion criterion cannot truthfully say the unchanged corpus now runs against
real captures instead of constructed dispositions. The Step 3 corpus regression
and the Step 4 production-capture integration are separate claims and need
separate checks.

The production-capture side is also too thin for the work Step 4 owns. A single
successful one-object sample proves one path through the wiring. It does not
prove that the observer, ordered classifier, both independent disposition axes,
migration invariant, mutation calls, counters, formatter, and trailer compose on
their failure and non-writing paths. In particular, Step 1 proves the production
of axis-local probe failures and Step 2 proves their classification, but Step 4
does not prove those outcomes become independent object-record dispositions and
categorical totals. Nor does any case make `--set-rpath` or
`--set-interpreter` fail, so the two write-failure branches that produce the
acceptance's failure dispositions are untested. Requiring both figures to be
zero on a healthy archive proves the success path, not that a failed mutation is
reported on the correct axis while the other axis survives.

Finally, the static assertion is not implementable as written. Step 4 says the
formatter identifier occurs at the definition and at "exactly the call sites
this step enumerates, each named", but the step names no call site. The missing
enumeration is load-bearing because object records must be emitted exactly once
for every walked ELF, including failed, excluded, and not-dynamically-linked
objects, while a complete or skipped trailer has different cardinality.

These are more than wording edits, so the disposition is
`changes-requested`. They do not reopen Q04 or the wire grammar. The finite exit
condition is to separate corpus regression from real-capture integration, add a
production outcome matrix over every wiring branch including both probe and
write failures, and enumerate the formatter call sites with record/trailer
cardinality. If that closure survives the next review, no currently identified
substantive surface remains; that is the concrete sense in which convergence is
in sight.

### Question verdicts for plan relocation-force-rpath round 12

No open question is missing. The Step 4 findings are consequences of settled
Q04, Q08, and Q09 decisions, not choices between new designs.

- Q01: choose 1A; the separate harness preserves the completed shared-body
  evidence.
- Q02: choose 2A; measurement and requirement-level escalation preserve the
  standalone deployment contract.
- Q03: choose 3A; the independent fixture oracle, complete tuples, bounded
  doubles, and per-process prerequisite preflight remain necessary.
- Q04: choose 4D; behavior and emission still must land atomically after the
  uncalled formatter preparation. The current Step 4 needs the integration
  evidence that makes this choice executable, not a different sequencing.
- Q05: choose 5C; the fixed associative-array carrier and exact-target debt are
  properly bounded.
- Q06: choose 6A; terminal monitoring blockage remains distinct from a session
  that never opened.
- Q07: choose 7A; the source-safe boundary remains the correct production seam.
- Q08: choose 8A; the reader belongs in the harness.
- Q09: choose 9A; the ranked, audited, frozen corpus remains the external oracle
  for the grammar.

The options remain materially distinct and their recommended answers follow
from the confirmed constraints. Answers remain 1A, 2A, 3A, 4D, 5C, 6A, 7A,
8A, and 9A.

### Requested changes for plan relocation-force-rpath round 12

Requested changes: 1. Separate the unchanged Step 3 literal/constructed contract regression from
   Step 4 validation of real production captures.
2. Add a Step 4 production outcome matrix covering every wiring branch and the
   complete two-axis record and trailer effects.
3. Add bounded, axis-local `--set-rpath` and `--set-interpreter` mutation-failure
   cases; probe-failure cases do not exercise these branches.
4. Parse and categorically assert every real matrix capture, retaining the design
   sample only as one verified row.
5. Actually enumerate the formatter's object and trailer call sites, their
   cardinality, and the resulting exact static occurrence count.
6. Mirror all five changes in the validation skeleton.

### Writer instructions for plan relocation-force-rpath round 12

Keep all nine answers unchanged. Amend Step 4 and its validation-skeleton mirror
as follows.

1. Separate the Step 3 regression suite from Step 4 integration. Re-run the
   frozen corpus, formatter-vector, reader-valid-permutation, and malformed-input
   cases unchanged against their literal or constructed inputs. Separately feed
   every real Step 4 capture to the production reader. Do not claim that
   malformed or noncanonical corpus vectors are now produced by a real run.

2. Replace the single-sample integration assertion with a compact production
   outcome matrix. For every production wiring branch, state the input scenario,
   ordered case, rpath disposition, interpreter disposition, migration checked
   and failed effects, mutation expected or forbidden, object record, and
   trailer-counter effect. Include the existing success, idempotence, exclusion,
   no-dynamic, ambiguity/structural-failure, migration-invariant, and skipped-run
   cases, plus both axis-local probe failures.

3. Add controlled **mutation-failure** integration cases distinct from D01 and
   D02: one where `--set-rpath` fails while the interpreter axis retains its
   truthful outcome, and one where `--set-interpreter` fails while the rpath
   axis retains its truthful outcome. Bound any double with the already-settled
   containment and shipped-identity rules. Assert no failed mutation is counted
   as rewritten and that the surviving axis is neither erased nor fabricated.

4. For every matrix row, parse the actual emitted capture with the Step 3
   reader and assert the complete object record and categorical trailer, not
   merely acceptance of the syntax. Keep the design's one-object capture as a
   canonical integration row only if its current fields and totals still match
   the actual scenario; otherwise stop for the existing Q09 adjudication rule
   rather than editing `/1` semantics in Step 4.

5. Enumerate the production formatter call sites and their cardinality. At
   minimum the plan must identify the object-record site, reached exactly once
   per walked ELF regardless of disposition, and the terminal site or sites that
   emit exactly one complete or skipped trailer. State the exact whole-word
   occurrence count the static assertion expects after those sites are added.
   This enumeration must make it impossible for failed, excluded, or
   not-dynamically-linked objects to disappear from the reconciliation.

6. Mirror the integration matrix, suite separation, mutation-failure cases,
   complete-capture assertions, and named call-site cardinality in the
   validation skeleton.

Do not add a new question unless applying the matrix exposes a genuine silence
in the reviewed design. These changes implement the already-selected atomic
integration and frozen grammar.

### Final reviewer decision for plan relocation-force-rpath round 12

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-12 -->

## Round 13 by requestor

- Recorded: 2026-08-18T09:58:32+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 13

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 13

### Requestor assessment for plan relocation-force-rpath round 13

Round 13. All six round 12 requested changes are applied, none disputed. No
question is added and no answer changes: 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A.
Every change is in Step 4 and its mirror; no other step is touched.

**The suite conflation was a false statement, not a gap.** Step 4 said the Step 3
report-contract cases are "re-run unchanged, now against captures a real run
produced rather than constructed ones". The Step 3 corpus holds canonical
formatter vectors, other reader-valid permutations the formatter is not required
to emit, and malformed vectors production must never emit and must reject. A real
run produces none of the second class and had better produce none of the third,
so the sentence described a suite that cannot exist. It was written in round 6
and repeated in the completion criteria and the validation skeleton, in a
document that already said the corpus contains inputs production must never
produce.

Two claims now get two checks: the **Step 3 regression**, re-run unchanged
against its own literal and constructed inputs and unaffected by Step 4 landing;
and the **Step 4 integration**, feeding every real capture to the production
reader.

**A sixteen-row production outcome matrix replaces the single sample.** One
successful one-object run proves one path and nothing about how the observer, the
ordered classifier, both disposition axes, the migration invariant, the mutation
calls, the counters, the formatter and the trailer compose where something fails
or nothing is written. Each row states scenario, ordered case, both dispositions,
migration effect, mutation expected or forbidden, and trailer effect. Beyond the
writing, idempotence, exclusion, no-dynamic, ambiguity, structural-failure,
migration-invariant and skipped-run cases, the matrix adds both axis-local probe
failures, both mutation failures, the empty or unavailable target search path
which fails the rpath axis for every walked ELF while the interpreter axis
reaches its own evidenced value, and the excluded program whose **interpreter is
still rewritten**, which is where the design's independence of the two axes stops
being an assertion and becomes a test. Every row is derived from the design's
fault matrix and acceptance table rather than from this plan's judgement.

**Mutation failures are not probe failures, and had no witness at all.** `D01`
and `D02` fail a probe. The design's fault matrix has two rows for `--set-rpath`
and `--set-interpreter` failing, and those are the branches that produce the
acceptance's failure dispositions. The plan had built producers for the probe
rows, left the write rows alone, and then written a criterion requiring both
failure figures to be zero on a healthy archive, which is a check that the
failure branches never fire. `W01` and `W02` are added as separate integration
cases: `W01` fails `--set-rpath` while the interpreter axis keeps its truthful
outcome, `W02` the converse. Each asserts the failed write is reported on its own
axis, never counted as rewritten, with the other axis neither erased nor
fabricated. Their doubles are bounded by the containment and shipped-identity
rules already settled, unchanged.

**Every matrix capture is parsed and asserted in full**, the complete object
record field by field and the categorical trailer, rather than merely accepted as
syntactically valid. The design's one-object capture is retained as one verified
row only if its fields and totals still match its scenario; otherwise the Q09
adjudication rule applies and `/1` semantics are not edited in Step 4.

**The call sites are enumerated, which the previous criterion promised and did
not do.** "At exactly the call sites this step enumerates, each named" described a
list in a step containing no list. There are exactly two: the object-record site,
reached once per walked ELF whatever its disposition, at a single per-object
emission point every disposition falls through to, with dispositions assigned to
variables rather than emitted per branch so no early `continue` can bypass it;
and the terminal trailer site, reached once per run at a single exit point on
every path including the skipped one, with `state` and `reason` in variables so
the skipped path cannot omit the trailer and no path can emit two. So
`emit_cplx_elf_v1_record` occurs as a whole shell word **exactly three times**
after this step. Supplying the enumeration forced a decision that had been
implicit: single emission points make `walked` equal the record count
structurally, where per-branch emission would leave the categorical
reconciliation responsible for catching a branch that forgot to emit.

All six are mirrored in the validation skeleton.

**On convergence.** The estimate has been "one or two rounds" for three
consecutive rounds and has been wrong twice, so the interesting question is what
is different rather than whether to repeat it. Two rounds ago it was drawn from
the wrong sample, small findings in the most-worked part of the document. One
round ago the quiet steps turned out to be unread rather than sound. This round
the difference is coverage that can be named by round: Step 1 continuously since
round 5, Step 3 since round 5, Steps 2, 5 and 6 in round 11, Step 4 in round 12,
Step 0's seam and the addendums in round 12. That is coverage rather than an
impression of it.

The qualification is narrower and specific. This is the largest single amendment
since round 6, sixteen matrix rows, two new integration cases and a structural
decision about emission points, and amendments of that size to a document this
heavily reviewed have not previously landed without a finding. One more round on
the matrix's contents rather than on its absence is the expectation.

Also worth recording: rounds 11 and 12 both produced internal contradictions
between plainly worded claims in different sections, the inventory and this
corpus sentence, in a review that has caught the exit status of a declaration
builtin. The attention in this exchange has been consistently at the level of
individual mechanisms and consistently weak at the level of whether two parts of
the document say compatible things. That is the class of defect most likely to
remain.

What round 13 should look at:

- The matrix rows were derived from the design's fault matrix and acceptance
  table and each was checked against them. The converse was not checked: whether
  every row of the design's fault matrix and every row of its acceptance table
  now has a corresponding integration row. Those are two different completeness
  claims, and this exchange has established repeatedly that the second is the one
  that finds missing work. A one-way derivation is offered here, not coverage.

### Change summary for plan relocation-force-rpath round 13

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 12, applying round 12's six requested changes.
Every change is in Step 4 and its mirror. No answer changes, no new question, and
no other step is touched.

Step 4, suite separation:

- A new subsection, "Two suites, not one", removes the sentence that said the
  Step 3 report-contract cases are "re-run unchanged, now against captures a real
  run produced rather than constructed ones", and records why it could not be
  true of the suite it names: the Step 3 corpus holds canonical formatter
  vectors, other reader-valid permutations the formatter is **not required to
  emit**, and malformed vectors production must **never** emit and must reject,
  so a real run produces none of the second class and had better produce none of
  the third.
- The two claims are given two checks: the **Step 3 regression**, re-run
  unchanged against its own literal and constructed inputs, corpus, canonical
  vectors, permutations and malformed forms, touching no real capture and
  changing nothing because Step 4 landed; and the **Step 4 integration**, in
  which every capture a real matrix row produced is fed to the production reader.

Step 4, the production outcome matrix:

- A new subsection replaces the single-sample assertion, stating why: one
  successful one-object run proves one path through the wiring and nothing about
  how the observer, the ordered classifier, both disposition axes, the migration
  invariant, the mutation calls, the counters, the formatter and the trailer
  compose on the paths where something fails or nothing is written.
- Sixteen rows, each stating scenario, ordered case, rpath disposition,
  interpreter disposition, migration effect, mutation expected or forbidden, and
  trailer effect: the case 4 library write; the same library on a second run as
  `already correct` with mutation forbidden; the case 6 fresh program writing
  both axes; the case 5 migration program with `mig-checked` positive; the
  migration object whose interpreter is wrong, counted as `mig-failed` and still
  converted; the case 7 RPM-extracted program; **the same program with a
  builder-anchored interpreter, excluded on the rpath axis and `rewritten` on the
  interpreter axis**; the case 2 object with no `PT_DYNAMIC`; `tag_state:
  ambiguous` failing the rpath axis with the write forbidden; structural
  inconclusiveness failing both axes as two views of one walk; both axis-local
  probe failures; both mutation failures; the empty or unavailable target search
  path, which fails the rpath axis for every walked ELF while the interpreter
  axis reaches its own evidenced value per object; and the skipped run.
- The plan records that every row is grounded in the design's fault matrix and
  acceptance table rather than in this plan's judgement, and names the
  excluded-program-with-rewritten-interpreter row as the one where the
  independence of the two axes stops being an assertion and becomes a test.

Step 4, mutation-failure cases:

- A new subsection separates them from the probe failures in as many words:
  `D01` and `D02` make a **probe** fail and say nothing about the write branches,
  which are the branches that produce the acceptance's failure dispositions.
  Requiring both failure figures to be zero on a healthy archive proves the
  success path and cannot show that a failed write is reported on the correct
  axis while the other axis survives.
- `W01` and `W02` are added as separate integration cases, each with a controlled
  patchelf double that fails one **write**: `W01` fails `--set-rpath` while the
  interpreter axis keeps its truthful outcome, `W02` fails `--set-interpreter`
  while the rpath axis keeps its own case.
- Each asserts that the failed mutation is not counted as rewritten and that the
  surviving axis is neither erased nor fabricated.
- Both doubles are bounded by the containment and shipped-identity rules already
  settled for `D01` and `D02`, applied unchanged: own subshell, private scratch
  state, asserted resolution, exit trap, and the pinned-digest re-assertion with
  the `F06` sentinel afterwards.

Step 4, the enumerated call sites:

- A new subsection supplies the enumeration the previous criterion promised and
  omitted, and states why it is load-bearing: record cardinality is what stops a
  failed, excluded or not-dynamically-linked object disappearing from the
  reconciliation.
- Two sites, with their cardinality and how it is made structural: the
  **object-record** site, reached exactly once per walked ELF whatever its
  disposition, sitting at a single per-object emission point that every
  disposition falls through to, with dispositions assigned to variables rather
  than emitted per branch, so no early `continue` can bypass it; and the
  **terminal trailer** site, reached exactly once per run at a single exit point
  on every path including the skipped one, with `state` and `reason` carried in
  variables, so the skipped path cannot omit the trailer and no path can emit
  two.
- The exact static occurrence count is stated: `emit_cplx_elf_v1_record` occurs
  as a whole shell word in `install_pkg.sh` **exactly three times** after this
  step, the definition plus those two sites, and in no comment or message
  literal.
- The plan records that single emission points are what make `walked` equal the
  object-record count structurally, rather than leaving the categorical
  reconciliation responsible for catching a branch that forgot to emit.

Step 4 completion criteria:

- The single-sample criterion is replaced by one requiring **every row of the
  matrix to pass**, all sixteen, naming both axis-local probe failures, both
  mutation failures, the empty target search path, the excluded program whose
  interpreter is still rewritten, and the skipped run.
- A criterion requires **every capture a matrix row produced to be parsed by the
  Step 3 reader and asserted in full**, the complete object record field by field
  and the categorical trailer, not merely accepted as syntactically valid. The
  design's one-object capture is retained as one verified row only if its fields
  and totals still match its scenario; if they do not, the Q09 adjudication rule
  applies and `/1` semantics are not edited in Step 4.
- A criterion covers `W01` and `W02` and their bounded doubles.
- The call-site criterion now states the exact count of three and names both
  sites, and a further criterion requires the object-record site's per-object
  cardinality and the terminal site's per-run cardinality to be asserted by the
  matrix rather than inferred from the code's shape.
- A criterion states that the Step 3 regression is re-run unchanged against its
  own literal and constructed inputs and that the two suites do not stand in for
  each other.
- The false "contract corpus still passes unchanged, now against captures a real
  run produced" criterion is removed.

Validation skeleton:

- Step 4's expectations carry all five: the suite separation with the reason the
  earlier sentence could not be true, the sixteen-row matrix summarised with its
  distinctive rows named and its grounding in the design, the mutation-versus-
  probe distinction with `W01` and `W02` and their bounded doubles, the
  full-capture parsing with the Q09 fallback for the design's sample row, and the
  two enumerated call sites with their structural cardinality and the exact count
  of three.

Open questions:

- The framing paragraph is rewritten around the three Step 4 findings.
- Answers stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. No question is
  added: applying the matrix exposed no silence in the reviewed design, every row
  being derivable from its fault matrix and acceptance table.

### Writer response for plan relocation-force-rpath round 13

Writer response: All six requested changes are applied. Nothing is disputed. No new question was
created: building the matrix required reading the design's fault matrix and
acceptance table row by row, and every branch was derivable from them, which is
the test the instruction set for whether a silence existed.

The corpus sentence is the finding worth dwelling on, because it is not a gap but
a false statement, and the writer wrote it. "The report-contract cases from Step 3
are re-run unchanged, now against captures a real run produced rather than
constructed ones" was added in round 6 and repeated in the completion criteria
and in the validation skeleton. By round 6 the same document already said the
corpus contains malformed vectors that production must never emit. The sentence
therefore claimed a real run produces inputs the plan elsewhere forbids it from
producing, and it said so in two documents for seven rounds. Nothing about ELF or
Bash was needed to see it; only reading the two sentences together.

That is the same failure as round 11's inventory contradiction, one round apart,
and the pair is now a pattern rather than a coincidence. Both are internal
contradictions between plainly worded claims in different sections. Both survived
a review that has caught the exit status of a declaration builtin. The writer's
attention has been consistently at the level of individual mechanisms and
consistently absent at the level of whether two parts of the document say
compatible things. The round 12 response named the depth-first blind spot in
general terms and then produced another instance of it in the same document.

The mutation-versus-probe distinction is the reviewer's, and the writer had the
material to reach it. Round 7 established `D01` and `D02` because the axis-local
`failed` statuses needed producing rather than hoping for. The design's fault
matrix has seven rows, and two of them are `--set-rpath` and `--set-interpreter`
failing. The writer built producers for the probe rows and left the write rows
alone, then wrote a completion criterion requiring both failure figures to be
zero on a healthy archive, which is a check that the failure branches never fire.
Having spent three rounds arguing that a proportion cannot substitute for a
behavior, the writer left two behaviors with no witness at all and a criterion
that would stay green forever.

The call-site finding is smaller and more embarrassing. "At exactly the call
sites this step enumerates, each named" is a sentence that describes a list, in a
step containing no list. It was written in round 6 as the successor to Step 3's
single-occurrence assertion, and the successor's whole value is the count it
expects. Supplying it turned out to be more than bookkeeping: choosing single
emission points for the record and the trailer is what makes `walked` equal the
record count structurally, and choosing per-branch emission would have made the
categorical reconciliation responsible for catching a branch that forgot to emit.
The enumeration forced a design decision that had been left implicit.

On convergence, asked again.

The reviewer's position is that the remaining surface is now confined to Step 4
and that Step 0's seam and the addendums were read this round without further
finding. If that holds, the identified surface after this round is empty. The
writer's own estimate has been one or two rounds for three consecutive rounds and
has been wrong twice, so it is worth being explicit about what would make it
right this time rather than repeating it.

Two rounds ago the estimate was wrong because it was drawn from the wrong sample,
small findings in the most-worked part of the document. One round ago it was
wrong because the reviewer looked at the quiet steps and found three things,
including a contradiction. This round the difference is that the reviewer states
it has now read every part of the document, and the writer can name what was read
when: Step 1 continuously since round 5, Step 3 since round 5, Steps 2, 5 and 6
in round 11, Step 4 in round 12, and Step 0's seam and the addendums in round 12.
That is coverage rather than an impression of coverage, which is the thing the
previous two estimates lacked.

So: convergence is in sight in a sense the earlier estimates did not have. The
qualification is narrower than before and it is specific. This round's changes
are the largest single amendment since round 6, sixteen matrix rows, two new
integration cases and a structural decision about emission points, and large
amendments to a document this heavily reviewed have not previously landed
without a finding. The writer would expect one more round on the matrix's
contents rather than on its absence, and would be pleased to be wrong.

One thing is offered for round 13.

The matrix's rows are derived from the design's fault matrix and acceptance
table, and the writer checked each against those sources. It did not check the
converse: whether every row of the design's fault matrix and every row of its
acceptance table now has a corresponding integration row. Those are two different
completeness claims, and this exchange has established repeatedly that the second
is the one that finds missing work. The writer has not performed that
reverse-direction check, and says so rather than presenting a one-way derivation
as coverage.

### Reviewer focus for plan relocation-force-rpath round 13

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-13 -->

## Round 13 by reviewer

- Recorded: 2026-08-18T10:29:45+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 13

Round 13 is not convergence-ready, but convergence is in sight in a concrete
sense: the design choices, suite boundary, write-failure mechanisms, and
production call-site topology are now settled. The remaining defect is a finite
normalization and traceability pass over the new Step 4 matrix rather than a
reopened design decision.

All round 12 structural changes are present. The contract regression and
production integration are separate suites; W01 and W02 exercise mutation
failures rather than probe failures; the formatter call sites are enumerated as
one per-object site and one terminal site, with three whole-word occurrences;
and the validation skeleton mirrors those claims.

The sixteen-row matrix, however, does not yet satisfy the exact contract the
surrounding prose assigns to it. Several cells use placeholders such as `its own
case`, `its own evidenced value`, `per object`, and `per the two axes`. Those are
instructions to derive an expectation, not exact ordered cases, disposition
tokens, or counter effects. In particular, an interpreter's evidenced value is
not an interpreter disposition: the wire tokens are `rewritten`, `failed`,
`unchanged`, and `not applicable`. A test cannot assert a complete object record
field by field from these rows without making decisions the matrix claims to
have made.

The D02 row is structurally malformed. Its cells are shifted: `failed` appears
under rpath, `none` under interpreter, a mutation description under migration,
and an interpreter-counter effect under mutation, with no trailer-effect cell.
That also reverses the axis-local premise: an interpreter probe failure must
leave the rpath axis at its truthful case-derived outcome, not declare rpath
failed by default.

The trailer column contradicts categorical reconciliation in multiple rows.
Every walked object must increment `walked`, exactly one rpath bucket, and
exactly one interpreter bucket, with exact migration deltas. Yet the idempotent
library row records only `r-already-correct +1` despite stating interpreter
`not applicable`; the ordinary excluded, no-dynamic, ambiguous, D01, W01, W02,
and empty-target rows likewise give only one axis or a placeholder. The
empty-target row is especially underdetermined: it describes many objects with
different ordered cases and interpreter outcomes as one row, while promising a
complete record and categorical trailer. It needs a fixed prepared inventory
and exact per-object records and totals, or it must be split into exact rows.

Finally, the claim that every matrix row comes from the design's fault matrix
and acceptance table is only one-way prose. The plan needs the same kind of
two-way ledger already used successfully for the `/1` corpus: every applicable
authoritative row maps to one or more production outcomes, and every production
outcome maps back to its clause, with zero uncovered and zero underived entries.
That is the inverse-coverage check requested in round 13 and is what prevents a
plausible sixteen-row list from silently omitting or inventing a branch.

The disposition is `changes-requested`. No open question or answer change is
needed unless the two-way audit finds a genuine silence in the reviewed design.
The exit condition is now bounded: make the matrix rectangular and literal,
make every object reconcile on both axes and migration, and close traceability
in both directions. If those checks pass without exposing a new design silence,
the review has a defensible convergence point; the number of rounds alone is no
longer the evidence.

### Question verdicts for plan relocation-force-rpath round 13

No open question is missing at present. The Step 4 findings are execution gaps
inside settled Q04, Q08, and Q09 decisions, not choices between new designs.

- Q01: choose 1A; the separate harness preserves the completed shared-body
  evidence.
- Q02: choose 2A; measurement and requirement-level escalation preserve the
  standalone deployment contract.
- Q03: choose 3A; the independent fixture oracle, complete tuples, bounded
  doubles, and per-process prerequisite preflight remain necessary.
- Q04: choose 4D; behavior and emission still land atomically after the
  uncalled formatter preparation. The new matrix must make that integration
  executable rather than approximate.
- Q05: choose 5C; the fixed associative-array carrier and exact-target debt are
  properly bounded.
- Q06: choose 6A; terminal monitoring blockage remains distinct from a session
  that never opened.
- Q07: choose 7A; the source-safe boundary remains the correct production seam.
- Q08: choose 8A; the retained-output reader belongs in the harness.
- Q09: choose 9A; the ranked, audited, frozen corpus remains the external oracle
  for `/1`. Apply its two-way traceability discipline to Step 4's derivation
  from the design, without merging the two suites.

The options remain materially distinct and their recommended answers follow
from the confirmed constraints. Answers remain 1A, 2A, 3A, 4D, 5C, 6A, 7A,
8A, and 9A.

### Requested changes for plan relocation-force-rpath round 13

Requested changes: 1. Make the Step 4 outcome matrix rectangular and literal; correct the shifted,
   incomplete D02 row.
2. Replace every case, disposition, and counter placeholder with exact closed
   values, splitting scenarios where necessary.
3. Specify a complete object record and both-axis categorical trailer effect for
   every walked-object outcome, including migration deltas and `walked`.
4. Give the empty-target, D01/D02, and W01/W02 cases exact objects, cases,
   surviving-axis outcomes, records, and totals.
5. Add two-way traceability between the design fault/acceptance rows and the
   production outcome matrix, with zero uncovered and zero underived entries.
6. Mirror the repaired matrix and traceability checks in the validation
   skeleton while preserving the two-suite and two-call-site structure.

### Writer instructions for plan relocation-force-rpath round 13

Keep all nine answers unchanged. Amend Step 4 and its validation-skeleton mirror
as follows.

1. Give every production outcome a stable row id and make the matrix strictly
   rectangular. Mechanically assert the expected column count. Correct D02 in
   particular: it must state the exact case and truthful rpath disposition,
   interpreter `failed`, exact migration effect, mutation rule, complete object
   record, and complete trailer effect in their proper columns.

2. Replace every placeholder (`its own case`, `its own evidenced value`, `per
   object`, `per the two axes`, and equivalents) with literal expectations.
   Cases must be 1 through 7, or explicitly not applicable for the skipped run;
   dispositions must use the closed wire tokens. Where one scenario permits
   more than one disposition or case, split it into exact rows rather than
   hiding the variants behind prose.

3. Make each walked-object row specify the complete emitted record, including
   the exact case, rpath disposition, interpreter disposition, migration
   effect, and scenario-fixed path. Make its trailer effect state `walked +1`,
   exactly one rpath bucket `+1`, exactly one interpreter bucket `+1`, exact
   `mig-checked` and `mig-failed` deltas, and that every other bucket is
   unchanged. Keep the skipped row at zero records with exactly one skipped
   trailer.

4. Repair the multi-object empty-target scenario. Define a prepared prefix with
   an exact enumerated inventory and give the expected record for each object
   plus the complete categorical totals, or split it into one-object rows whose
   exact cases and interpreter dispositions are independently assertable. Do not
   use `r-failed = walked` as a substitute for the interpreter and migration
   totals.

5. Give D01, D02, W01, and W02 exact source objects and cases. For D01 and D02,
   assert the surviving probe axis's literal value and resulting disposition.
   For W01 and W02, assert the attempted write fails only its own axis, is never
   counted as rewritten, and the other axis reaches its exact truthful outcome.

6. Add a two-way production-outcome derivation ledger. Map every applicable row
   of the design fault matrix and acceptance table to one or more Step 4 row ids,
   with zero uncovered authoritative outcomes; map every Step 4 row id back to
   its exact authoritative clause, with zero underived outcomes. Treat a silence
   or double reading as a stop for a new reviewed question, not as permission to
   choose a value in the plan.

7. Retain the corrected suite separation and the definition-plus-two-call-sites
   topology. Mirror the exact matrix, complete categorical assertions, row-count
   check, and two-way derivation ledger in the validation skeleton.

Do not change the grammar, corpus authority, or selected answers while applying
these repairs.

### Final reviewer decision for plan relocation-force-rpath round 13

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-13 -->

## Round 14 by requestor

- Recorded: 2026-08-18T10:49:21+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 14

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 14

### Requestor assessment for plan relocation-force-rpath round 14

Round 14. All six round 13 requested changes are applied, none disputed. No
question is added and no answer changes: 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A.
Every change is in Step 4 and its mirror; the two-suite boundary and the
definition-plus-two-call-sites topology are retained unchanged.

**The matrix is now literal, and the placeholders were not shorthand.** Cells
reading `its own case`, `its own evidenced value`, `per object` and `per the two
axes` were the writer deferring a derivation and presenting the deferral as a
specification. `its own evidenced value` was worse than vague: the interpreter
axis has four closed tokens and "evidenced value" is not among them, so the cell
named a category the design does not have. Every cell is now a closed value, and
resolving them required decisions, which is the proof they were not shorthand.

**The `D02` row was a six-cell row in a seven-column table.** It read `failed`
under rpath and `none` under interpreter, the exact inversion of the axis-local
premise it existed to prove. The remedy is not care but the **mechanical column
count** now asserted over the table, since a writer who missed one absent cell
will miss the next.

**Twenty-eight rows over fourteen runs and twelve enumerated objects.** Each
object has a fixed path under `$DEST_PATH`, so every record is literal and every
`path` is scenario-fixed. Each row states case 1 to 7, an rpath wire token, an
interpreter wire token, the mutations performed or forbidden, and a numeric
migration delta.

**Every walked object reconciles on both axes.** Each row contributes `walked`
+1, exactly one `r-` bucket +1, exactly one `i-` bucket +1 and its migration
deltas, with every other bucket unchanged, and a fourteen-row totals table gives
every run's complete trailer with two invariants asserted over each: the five
`r-` buckets sum to `walked`, the four `i-` buckets sum to `walked`. The
empty-search-path run now has the fixed six-object inventory with per-object
records and complete totals, replacing "`r-failed` equals `walked`", which said
nothing about the interpreter or migration figures; its interpreter axis is
untouched by the missing rpath input, which is the design's claim and what the
phrase could not check.

**Two substantive decisions came out of being forced to the literal.** Reading
the interpreter guard at lines 413 to 422 rather than describing it settled that
`unchanged` covers both a system interpreter and an already-target one, the guard
requiring `*/home/*` **and** a difference from the target. And filling in the
case column for the write-failure cases made explicit that a write failure
changes the **disposition** and never the case, the classifier having already run
on a tuple the write has not touched.

**The two-way ledger justified itself in one pass.** Running the inverse
direction produced four rows the forward derivation had missed, two of them
substantive: the design's probe-failure row names a **library**, whose
interpreter axis is `not-applicable`, where `D01` had used a program, so the row
proving axis-local probe failure was proving it over the wrong subject; and the
design's write-failure row is specifically about a **case 5** object still
counted in `mig-checked`, where `W01` had used a case 6 object, so that row's
most interesting property had no test. The other two are the file shorter than
the ELF header, previously uncovered, and the domain rejections, previously
folded into the structural one. The acceptance table's report-contract rows are
recorded as Step 3's rather than silently omitted.

A limit is recorded rather than hidden: `D02` and `W02` produce **identical
captures**, since the wire format cannot distinguish a failed interpreter probe
from a failed interpreter write. That is correct behavior, both being the
interpreter axis failing, and it is why capture-level evidence cannot substitute
for exercising both branches.

All six are mirrored in the validation skeleton.

**On convergence.** The estimate has been one or two rounds for four consecutive
rounds, so repeating it is worth nothing. What is worth saying is narrower.

What changed this round: the exit condition was fully mechanical, and so was the
work. Its output is a table a test can be written from directly. That is a
different kind of round from 5 through 10, each of which changed what the plan
believed. No design decision has reopened for six rounds.

What did not change: this round's findings were again defects findable by reading
the plan's own table against its own column headings, the third consecutive round
of that class after the inventory contradiction and the corpus sentence. The
writer has named that pattern three times and produced an instance in each round
it named it.

So: there is no identified design work left, and the remaining failure mode,
tables not saying what the surrounding prose claims, now has two mechanical
detectors added this round, the column-count assertion and the two-way ledger,
both of which fail loudly rather than reading plausibly. That is the concrete
sense in which convergence is in sight, and it does not rest on the round count.

What round 14 should look at:

- The trailer totals table was computed by hand from the twenty-eight object
  rows, and the two sum invariants were checked by the same party that did the
  arithmetic. The plan states them as assertions the harness must make, which is
  the right answer, but until the harness exists the totals table is unverified
  arithmetic presented in a form that looks verified. Its tidiness should not be
  read as a check.

### Change summary for plan relocation-force-rpath round 14

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 13, applying round 13's six requested changes.
Every change is in Step 4 and its mirror. No answer changes, no new question, no
other step touched, and the two-suite boundary and the
definition-plus-two-call-sites topology are retained unchanged.

Step 4, why the matrix is being rebuilt:

- The subsection opens by recording what was wrong rather than silently
  replacing it: cells reading `its own case`, `its own evidenced value`, `per
  object` and `per the two axes` are instructions to derive an expectation rather
  than expectations; an interpreter's "evidenced value" is not a disposition at
  all, the closed tokens being `rewritten`, `failed`, `unchanged` and `not
  applicable`; and the `D02` row was shifted a column, putting `failed` under
  rpath where it belonged under interpreter, which reversed the axis-local
  premise that row exists to prove.

Step 4, the prepared objects:

- A twelve-row table defines every subject with a fixed path under `$DEST_PATH`,
  so each record is literal and each `path` is scenario-fixed: `X1`
  `lib/libarch.so.1`, a library with a builder-anchored `DT_RUNPATH`; `X2`
  `bin/pyprog`, a program with both builder-anchored; `X3` `bin/rpmprog`, a
  program with a system interpreter and no tag; `X4` `bin/rpmprog-bh`, the same
  with a builder-anchored interpreter; `X5` `lib/relobj.o`, `ET_REL` with
  `e_phnum` zero; `X6` `lib/libamb.so.1`, carrying both tags; `X7`
  `bin/migprog`, exact target under `DT_RUNPATH` with the target loader; `X8`
  `bin/migprog-hostinterp`, the same with a builder-anchored interpreter; `X9`
  `lib/libtrunc.so.1`, truncated table; `X10` `lib/libelf32.so.1`, ELF32; `X11`
  `lib/libshort.so.1`, shorter than the header; `X12` `lib/libprobe.so.1`, a
  library with a builder-anchored `DT_RUNPATH`.
- The interpreter guard is quoted from lines 413 to 422,
  `[[ "$old_value" == */home/* ]] && [ "$old_value" != "$new_interp" ]`, with the
  consequence stated: a system interpreter and an already-target interpreter both
  give `unchanged`, only a builder-anchored interpreter differing from the target
  gives `rewritten`, so every `unchanged` in the matrix is that guard rather than
  an omission.

Step 4, the runs and the object outcomes:

- Fourteen runs `R0` to `R13` are defined with their prefix and inventory: the
  prefix outside `/home`; the six-object prefix at `$HOME` first and second pass;
  migration and migration-with-host-interpreter; truncated, out-of-domain and
  short objects; the four fault runs; the empty-search-path run over the same six
  objects; and the skipped run.
- The outcome table is twenty-eight rows `A01` to `A28`, one per walked object
  per run, each with case, rpath token, interpreter token, mutations performed or
  forbidden, and migration delta. Every cell is closed: a case is 1 to 7, a
  disposition is a wire token, a delta is a number. The column count is asserted
  mechanically, which is the check that would have caught the shifted `D02` row.
- Each row's record is stated to be fixed by its cells, and its trailer
  contribution is `walked` +1, exactly one `r-` bucket +1, exactly one `i-`
  bucket +1 and its stated migration deltas, with every other bucket unchanged.
- Three rows are called out: `A21` is design row 750, a case 5 object whose write
  fails, still counted in `mig-checked`, disposition `failed` and never
  `rewritten`; `A20` and `A22` produce **identical captures**, so neither can
  stand in for the other and the difference lives in which branch ran; `A05` is
  design row 746, excluded on the rpath axis with the interpreter rewritten.

Step 4, the trailer totals:

- A fourteen-row table gives every run's complete trailer: `walked`, all five
  `r-` buckets, all four `i-` buckets, `mig-checked`, `mig-failed` and `state`.
- Two arithmetic invariants are asserted over every row rather than left to the
  reader: the five `r-` buckets sum to `walked`, and the four `i-` buckets sum to
  `walked`.
- `R13` emits no records and exactly one trailer, and the install still succeeds.
- `R12`, the empty-search-path run, is given the fixed six-object inventory with
  per-object records and complete totals, replacing "`r-failed` equals `walked`",
  which said nothing about the interpreter or migration figures. Its interpreter
  axis is untouched by the missing rpath input, which is the design's claim and
  what the phrase could not check.

Step 4, the fault cases:

- `D01`, `D02`, `W01` and `W02` get a table naming each one's run, object, the
  call its double fails, the **case assigned**, the failing axis and the
  surviving axis's literal outcome.
- `D01` runs over a library, so its surviving interpreter axis is
  `not-applicable` with no value, which is the design's own row; the plan had
  used a program.
- `W01` runs over a **case 5** object, giving rpath `failed` while `mig-checked`
  still increments; the plan had used a case 6 object.
- A paragraph states why the case column is the point: a write failure changes
  the disposition and never the case, the case being a function of a tuple the
  write has not yet touched.

Step 4, the two-way derivation ledger:

- A new subsection replaces the one-way prose claim, applying the discipline Q09
  uses for the `/1` corpus.
- Design to matrix: a table maps all seven fault-matrix rows and every
  production-outcome row of the acceptance table to their matrix row ids, with
  zero uncovered.
- The acceptance table's remaining rows are explicitly recorded as **report
  contract**, Step 3's rather than silently omitted: the two zero-count trailers,
  the missing or doubled trailer, aggregate versus categorical, `mig-checked`
  zero over `case=5` records, `state=skipped` carrying work, duplicate and
  unknown fields, the `path` base and raw-byte encoding, the space-free tokens,
  and the nine equalities.
- Matrix to design: every row `A01` to `A28` and every run `R0` to `R13` cites
  its clause, with zero underived.
- The subsection records that running the second direction produced four rows the
  first had missed: `A18`, the file shorter than the header, uncovered; `A17`,
  the domain rejections folded into the structural one; `A21`, `W01` over a case
  6 object where the design's row is about case 5; and `A19`, the probe-failure
  row naming a library where the plan had used a program.
- A silent or double-read clause stops for a new reviewed question rather than
  being settled in the plan.

Step 4 completion criteria:

- Rows `A01` to `A28` over runs `R0` to `R13` all pass against their literal
  cells, with no placeholder in any cell.
- The matrix is rectangular and its column count asserted mechanically.
- Every walked object reconciles on both axes and migration, and over every run
  the five `r-` buckets and the four `i-` buckets each sum to `walked`.
- Every capture is parsed by the Step 3 reader and asserted in full, including
  the scenario-fixed `path`, with the Q09 fallback for the design's sample row.
- The four fault cases name their exact run, object, case and surviving-axis
  outcome, with `W01` on a case 5 object keeping `mig-checked` at +1.
- The two-way ledger is complete in both directions with zero uncovered and zero
  underived, the report-contract rows recorded as Step 3's.

Validation skeleton:

- Step 4's expectations carry all six: the reason the earlier matrix was not
  executable including the shifted row, the twenty-eight rows over fourteen runs
  and twelve objects with the rectangularity check, both-axis reconciliation with
  the per-run sums and the repaired empty-search-path run, the interpreter guard
  quoted with its consequence, the four fault cases with their exact subjects and
  the case-versus-disposition distinction and the identical-capture observation,
  the full-capture parsing, and the two-way ledger with the four rows the inverse
  direction produced.

Open questions:

- The framing paragraph is rewritten around the three findings.
- Answers stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. No question is
  added: the ledger found no silence and no double reading in the reviewed
  design, every row being derivable from its fault matrix or acceptance table.

### Writer response for plan relocation-force-rpath round 14

Writer response: All six requested changes are applied. Nothing is disputed. No new question was
created, because the ledger ran to completion in both directions without finding
a silence or a double reading.

The shifted `D02` row deserves the plainest statement available: the writer built
a seven-column table and wrote a six-cell row into it, and did not count. The row
then read `failed` under rpath and `none` under interpreter, which is the exact
inversion of what the row was for, in a document that had spent a round arguing
that axis-local failures must be produced deliberately because nothing else would
prove they are axis-local. The remedy is not care. It is the mechanical column
count now asserted over the table, because a writer who did not notice a missing
cell will not notice the next one either.

The placeholder finding is the same defect at the level of the whole table. `its
own case` and `its own evidenced value` are not shorthand for values the reader
can look up; they are the writer deferring a derivation and presenting the
deferral as a specification. And `its own evidenced value` is worse than vague:
the interpreter axis has four closed tokens and "evidenced value" is not among
them, so the cell named a category that does not exist in the design it claims to
implement. Every one of those cells has now been resolved to a token, and
resolving them required deciding things, which is the proof they were not
shorthand.

Two of those decisions were substantive and the writer would not have made them
without being forced to the literal. Reading the interpreter guard at lines 413
to 422 rather than describing it settled that `unchanged` covers both a system
interpreter and an already-target interpreter, since the guard needs
`*/home/*` **and** a difference from the target; the writer had been carrying a
vaguer model in which "unchanged" meant roughly "nothing happened". And filling
in the case column for `W01` and `W02` made explicit that a write failure changes
the disposition and never the case, because the classifier has already run on a
tuple the write has not touched. That sentence is now in the plan and it was not
in the writer's head.

The two-way ledger is the finding that justifies itself, and it did so
immediately. Running the inverse direction produced four rows the forward
derivation had missed, and none of them was a nicety. The design's probe-failure
row names a **library**, whose interpreter axis is `not-applicable`, and the
plan's `D01` used a program, so the row proving axis-local probe failure was
proving it over a subject the design does not use. The design's write-failure row
is specifically about a **case 5** object still counted in `mig-checked`, and the
plan's `W01` used a case 6 object, so the single most interesting property of
that row, that the case is population identity, had no test. Those are two
substantive misses found by a mechanical inverse check in one pass. The writer's
round 13 response offered the inverse check as an unexamined area; it turned out
to be where the work was.

Also worth recording plainly: the identical-capture observation between `D02` and
`W02` is not a defect but it is a limit, and the plan now says so. The wire
format cannot distinguish a failed interpreter probe from a failed interpreter
write. That is correct behavior, since both are the interpreter axis failing, but
it means capture-level evidence can never substitute for having both branches
exercised, which is precisely the argument for keeping four fault cases rather
than two.

On convergence.

The writer's estimate has now been one or two rounds for four consecutive rounds.
Repeating it again would be worth nothing, so here is what actually changed and
what did not.

What changed: the reviewer's exit condition for this round was fully mechanical,
make the matrix rectangular and literal, reconcile both axes, close traceability
both ways, and all three are checkable by inspection rather than by judgement.
The work done in response was correspondingly mechanical, and its output is a
table a test can be written from directly. That is a different kind of round from
rounds 5 through 10, each of which changed what the plan believed.

What did not change: this round's findings were again defects the writer could
have found by reading its own table against its own column headings, which is the
third consecutive round of that class after the inventory contradiction and the
corpus sentence. The writer has now named that pattern three times and produced
an instance in each of the three rounds it named it in.

So the honest statement is narrower than a round count. The design decisions,
architecture, suite boundary, fault mechanisms and call-site topology are settled
and have survived several rounds without reopening. The remaining risk is not in
what the plan decides but in whether its tables say what its prose claims they
say, and that risk is now substantially reduced by the two mechanical checks
added this round, the column-count assertion and the two-way ledger, because both
fail loudly rather than reading plausibly. Convergence is in sight in the sense
that there is no identified design work left and the remaining failure mode has
been given a mechanical detector. Whether one more round finds a twenty-ninth row
is not something the writer can assess about its own arithmetic.

One thing is offered for round 14.

The trailer totals table was computed by hand from the twenty-eight object rows,
and the writer checked the two sum invariants for each run while writing it. That
is the same act as the arithmetic being checked, performed by the same party, and
this exchange has established repeatedly what that is worth. The invariants are
stated in the plan as assertions the harness must make, which is the right
answer, but until the harness exists the totals table is unverified arithmetic
presented in a table that looks verified. The writer would rather flag that than
let the table's tidiness stand in for a check.

### Reviewer focus for plan relocation-force-rpath round 14

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-14 -->

## Round 14 by reviewer

- Recorded: 2026-08-18T11:01:55+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 14

Convergence is in sight, but round 14 is not convergence-ready. The remaining
findings do not reopen a design decision; they are two finite consistency defects
in the test plan. They are nevertheless more than wording because an implementer
would build different fixtures and bridge assertions depending on which section
they followed.

The round 13 matrix repair is materially successful. Its 28 object rows are
rectangular and literal, the 14 trailer rows cover both axes and migration, the
empty-target run has a fixed inventory, W01 uses a case 5 object, and the suite
and call-site boundaries remain intact. I independently folded the object rows
into their per-run totals: every published rpath bucket, interpreter bucket,
migration counter, and `walked` value matches. The writer's flagged hand
arithmetic is therefore correct in the current document.

The horizontal read exposes a cross-step contradiction, however. Step 1 defines
`D01` and `D02` over `F01`, the lawful program base with a present interpreter:
there D01's surviving interpreter probe is `ok` with a value, and D02's surviving
rpath probe is `ok` with the base's value. Step 4 reuses the same identifiers for
different integration subjects and outcomes: D01 is now `X12`, a library whose
interpreter is `not-applicable`, while D02 is `X2`, whose rpath is rewritten and
whose emitted case is 6. Step 2 then names `D01` and `D02` as bridge inputs
without saying which pair it means. The validation skeleton repeats the split,
describing the lawful base in Step 1 and the library/program integration cases
in Step 4. The inverse ledger repaired the Step 4 subject but did not propagate
that repair through the producer-to-consumer chain.

The purported reverse derivation ledger also is not yet a ledger. The document
contains a design-to-matrix table, followed by the assertion that every matrix
row and run cites a clause. There is no matrix-to-design table or per-row source
column to verify that assertion. The gap is already observable: `A11`, the
second-pass `X4` outcome, appears in no row of the forward mapping. The range
`A23` to `A28` covers the other ids that a literal token search would miss, but
nothing covers A11. Thus the stated zero-underived property is false even before
asking whether every field, especially the all-case-1 empty-target rows, follows
from its cited clause.

The current totals should not become a second hand-maintained oracle in the
harness. The plan already has enough data to derive them: fold the per-object
expected rows into expected trailer totals, compare that derivation with the
literal totals table, and separately compare the actual capture. This preserves
the now-verified table while making future drift fail mechanically.

The disposition is `changes-requested`. No new question and no answer change is
needed unless completing the literal reverse mapping exposes an actual silence
in the design. Convergence is genuinely visible because the exit condition is
now exact: give the fault cases unambiguous scope through all three steps, make
the reverse mapping real and exhaustive, and derive trailer expectations from
the object rows. If those checks close without a design silence, no identified
substantive surface remains.

### Question verdicts for plan relocation-force-rpath round 14

No open question is missing at present. The round 14 findings are internal
consistency and validation-derivation defects inside settled decisions.

- Q01: choose 1A; the separate harness preserves the completed shared-body
  evidence.
- Q02: choose 2A; measurement and requirement-level escalation preserve the
  standalone deployment contract.
- Q03: choose 3A; the independent fixture oracle, complete tuples, bounded
  doubles, and per-process prerequisite preflight remain necessary. Its fault
  witness identifiers must be made unambiguous across Steps 1, 2, and 4.
- Q04: choose 4D; behavior and emission still land atomically after the
  uncalled formatter preparation.
- Q05: choose 5C; the fixed associative-array carrier and exact-target debt are
  properly bounded.
- Q06: choose 6A; terminal monitoring blockage remains distinct from a session
  that never opened.
- Q07: choose 7A; the source-safe boundary remains the correct production seam.
- Q08: choose 8A; the retained-output reader belongs in the harness.
- Q09: choose 9A; the ranked, audited, frozen corpus remains the external oracle
  for `/1`. The same two-way discipline must be implemented, not merely named,
  for the Step 4 derivation ledger.

The options remain materially distinct. Answers remain 1A, 2A, 3A, 4D, 5C,
6A, 7A, 8A, and 9A.

### Requested changes for plan relocation-force-rpath round 14

Requested changes: 1. Disambiguate D01/D02 across Steps 1, 2, and 4, including their subjects,
   surviving-axis values, bridge references, and validation mirror.
2. Replace the asserted reverse ledger with an explicit exhaustive mapping for
   `A01`-`A28` and `R0`-`R13`; add the currently missing `A11` derivation.
3. Verify that each mapping derives case, both dispositions, and migration
   effects, especially for the empty-target rows.
4. Derive per-run expected trailer totals mechanically from the expected object
   rows before comparing them with the literal table and actual capture.
5. Mirror these changes in the validation skeleton without reopening settled
   decisions.

### Writer instructions for plan relocation-force-rpath round 14

Keep all nine answers unchanged. Amend the plan and its validation-skeleton
mirror as follows.

1. Give the Step 1 probe-failure witnesses and the Step 4 integration fault
   runs unambiguous identities. Either use one consistent D01/D02 subject and
   expected tuple throughout, or give the producer witnesses and integration
   runs distinct scoped ids. Do not let one id mean `F01` with interpreter `ok`
   in Step 1 and `X12` with interpreter `not-applicable` in Step 4.

2. Update Step 2's producer-to-consumer bridge to name the exact producer
   observations and the exact integration/controlled counterparts. State the
   complete surviving-axis value for each, so the bridge cannot silently choose
   one of the two current meanings. Apply the same names to containment,
   sentinel, and validation-skeleton references.

3. Replace the prose reverse-ledger assertion with an explicit, mechanically
   checked mapping. Each `A01` through `A28` and each `R0` through `R13` must map
   to its exact authoritative clause or clauses; set equality must report zero
   missing and zero extra ids. Add the missing derivation for `A11` rather than
   relying on the statement that every row is covered.

4. Make each reverse entry justify the fields the matrix derives from it, not
   merely the broad scenario. In particular, show the authoritative source for
   the case values as well as both dispositions and migration deltas in the
   empty-target rows `A23` to `A28`. If the source fixes only the failed rpath
   disposition and not case 1, stop for the already-stated reviewed-question
   path instead of assigning the case in the plan.

5. Make trailer verification a derivation rather than two copies of arithmetic.
   In the harness, fold the expected per-object rows into per-run expected
   counters; compare that fold with the literal totals table and independently
   compare the actual parsed trailer. Keep the two categorical sum invariants.
   Record that the current literal totals were independently recomputed and
   match, so this change protects later drift rather than correcting a present
   arithmetic error.

6. Mirror the identifier scoping, exact bridge, explicit reverse mapping, set
   checks, and derived-total check in the validation skeleton.

Do not reopen the suite boundary, call-site topology, wire grammar, or selected
answers. Add a new question only if the completed field-level reverse mapping
finds a genuine design silence or double reading.

### Final reviewer decision for plan relocation-force-rpath round 14

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-14 -->

## Round 15 by requestor

- Recorded: 2026-08-18T11:10:50+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for plan relocation-force-rpath round 15

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
Review round: 15

### Requestor assessment for plan relocation-force-rpath round 15

Round 15. All five round 14 requested changes are applied, none disputed.
**Q10 is added**, which the instruction permits only if the completed
field-level reverse mapping finds a genuine design silence or double reading. It
did. Answers otherwise stand at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A. The suite
boundary, call-site topology and wire grammar are untouched.

**Justifying fields rather than scenarios is what produced Q10.** Justifying the
scenario, "empty search path, rpath fails", passes without incident. Justifying
the fields forces the question of where each cell comes from, and the
empty-search-path clause fixes an rpath disposition and fixes **no case at all**.
The six rows had been given case 1 across the board, which is an error rather
than a shorthand: the design's "The case is identity; the disposition is what
happened" says the two must not be collapsed, and an empty computed search path
is not an observation of the object. The cases are now the objects' own, 4, 6, 7,
7, 2 and 1.

**With the cases corrected, the dispositions conflict.** The fault matrix says
`failed` for every walked ELF. The case-identity section says cases 1, 2, 3 and 7
have no write, "so for them the case and the disposition always agree". The
acceptance table says an object with no `PT_DYNAMIC` is `not dynamically linked`
because there is no search path to set, "which is not a failure". A case 2 object
under an empty search path cannot satisfy all three. Q10 states the conflict with
four options and recommends 10B, failure only for the writing cases, on a
two-clauses-against-one count and on the case-identity rule having three named
consumers. **It is not answered here**: Q09's adjudication discipline sends a
contested clause to reviewed authority, and this is the first time that rule has
bound outside the corpus. `A25`, `A26`, `A27` and the `R12` totals are marked
provisional and carry both readings' numbers.

**The fault identifiers had collided, and the origin is a new failure mode.**
Round 13's inverse ledger correctly moved Step 4's probe-fault subject from a
program to a library. The repair was applied to the subject and not to the
identifier, so `D01` meant `F01` with interpreter `ok` in Step 1 and `X12` with
interpreter `not-applicable` in Step 4, and Step 2's bridge named both without
distinguishing them. A correct local fix created a cross-step ambiguity, checked
against the design and not against the rest of the document. Step 1's witnesses
keep `D01` and `D02`; Step 4's runs are `IF01`, `IF02`, `IW01`, `IW02`; and the
bridge now names its eight producer subjects by Step 1 fixture id with their
complete surviving-axis values.

**The reverse ledger was one table and one claim.** The claim, that every row
cites a clause, was false on inspection: `A11` had no entry, and it is not
obscure. Supplying its derivation required noticing that its interpreter was
rewritten on the first pass, so the guard's `!=` condition fails on the second
and the value is `unchanged`. Every row, run and fault run now has a reverse
entry naming its clause and the fields that clause fixes, checked by set equality
with zero missing and zero extra.

**Trailer expectations are derived rather than transcribed.** The reviewer
verified the literal table and asked for the fold anyway, on the ground that the
risk is not today's arithmetic but the table becoming a second hand-maintained
oracle. The harness folds expected object rows into expected per-run counters and
makes three comparisons: fold against the literal table, fold against the actual
trailer, and literal table against the actual trailer.

All five are mirrored in the validation skeleton.

**On convergence, and on the stated goal of converging next round.** This round
cannot converge by construction: Q10 is open and it is the reviewer's to answer,
and every prior round has treated an open decision as disqualifying. What can be
said is that Q10 is bounded, its options are enumerated, its recommendation rests
on a clause count rather than a preference, and the plan is written under both
readings, so whichever is chosen the change is three cells and one totals row.

Beyond Q10 the stated exit condition is met literally: the fault cases have
unambiguous scope through all three steps, the reverse mapping is exhaustive with
a set-equality check, and the trailer expectations are derived. The two
mechanical detectors added in round 13, the column count and the ledger, both
fired this round and found real defects, which is the first direct evidence that
they work rather than merely exist.

What remains is a pattern rather than an item: five consecutive rounds of defects
findable by reading the document against itself, this round adding a new kind, a
correct fix propagated to one place and not the others. No mechanism is offered
for that, and inventing one now would be worse than naming it.

What round 15 should look at:

- `R12`'s totals were recomputed by hand after the case correction, and it is the
  only run whose object rows changed this round. The fold the plan now requires
  would catch an error there, but the fold does not exist yet, so that row has
  the status the whole table had last round: hand arithmetic checked by the party
  that performed it. One row rather than fourteen, and the one most recently
  disturbed.

### Change summary for plan relocation-force-rpath round 15

Changes to `docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md` and its
validation skeleton since round 14, applying round 14's five requested changes.
No answer changes; **Q10 is added**, which the instruction permits and requires
if the completed field-level reverse mapping finds a genuine design silence or
double reading. It did. The suite boundary, call-site topology and wire grammar
are untouched.

Fault identifier scoping, across Steps 1, 2 and 4:

- Step 1's paragraph now states that `D01` and `D02` are **producer witnesses at
  that step and nowhere else**, over `F01`, the lawful program base, with
  surviving axes `ok` carrying a value.
- It records why the scoping is needed: round 13's inverse ledger moved Step 4's
  fault subjects to a library and a program, and the plan kept the same two ids,
  so for one round `D01` meant `F01` with interpreter `ok` in Step 1 and `X12`
  with interpreter `not-applicable` in Step 4.
- Step 4's four fault runs are renamed `IF01`, `IF02`, `IW01` and `IW02`, with a
  consistent prefix, throughout the runs table, the object-outcome rows `A19` to
  `A22`, the trailer totals table and the fault-case table.
- Step 2's bridge is replaced by an eight-row table naming each producer
  observation by its **Step 1 fixture id** with the complete tuple crossing the
  seam and the expected case: `F03`, `F04`, `F06`, `F07`, `F10`, `F16`, and
  `D01` and `D02` over `F01` with their surviving-axis values stated literally.
- The bridge states in as many words that these are the producer witnesses and
  not `IF01`/`IF02`, which use different subjects and therefore different
  surviving-axis outcomes, and that for one round the table could have been built
  from either.

The reverse ledger, made real:

- The prose assertion is replaced by a per-row table covering every `A01` to
  `A28`, every run `R0` to `R13` and every fault run, each naming its
  authoritative clause **and the fields that clause fixes**.
- The check is stated as **set equality** on the id sets with zero missing and
  zero extra, rather than a sentence claiming coverage. The plan records that the
  previous sentence was already false, `A11` having had no entry.
- `A11`'s derivation is supplied: the RPM-extracted program with a
  builder-anchored interpreter read on the **second** run against the
  zero-rewrites clause, giving case 7 and `excluded`, with the interpreter
  `unchanged` because the first run made the value the target so the guard's `!=`
  condition now fails.
- Several entries name two clauses where two are needed, and several name the
  source guard at lines 413 to 422 as the authority for an interpreter token that
  no acceptance row states directly.

The empty-target rows, corrected and made provisional:

- `A23` to `A28` had been given **case 1** across the board. That is wrong on the
  design's own terms: the case is population identity assigned from the
  observation, the design forbids collapsing case into disposition, and an empty
  computed search path is not an observation of the object. The cases are now the
  objects' own, 4, 6, 7, 7, 2 and 1.
- The ledger entries for those rows state that the empty-search-path clause fixes
  an rpath **disposition** and fixes no case at all, so the cases come from the
  case table.
- `A25`, `A26` and `A27` and the `R12` totals are marked **(Q10)** and are
  provisional. They carry 10B's recommended numbers, and the plan records that
  under 10A the three rows become `failed` and `r-failed` becomes 6.
- A paragraph states that only the contested rpath disposition waits; the cases
  are settled.

Derived trailer totals:

- A paragraph states that the literal totals table is not to become a second
  hand-maintained oracle, and records that it was written by hand and has been
  independently recomputed and found correct, so the change guards later drift
  rather than fixing a present error.
- The harness **folds** the expected per-object rows into expected per-run
  counters and makes **three** comparisons: fold against the literal table, fold
  against the actual parsed trailer, and literal table against the actual parsed
  trailer, so a row edited in one place and not the other fails mechanically.
- The two categorical sum invariants are kept.

Step 4 completion criteria:

- The ledger criterion now requires both directions enumerated, names the id sets
  including the four fault runs, requires set equality with zero missing and zero
  extra, and records that the previous claim was false.
- A criterion is added for the three-way derived-totals comparison, with the note
  that the literal table is already verified.
- A criterion states that the `(Q10)` rows are provisional and not asserted until
  Q10 is answered.

Open questions:

- **Q10 is added**: what an empty computed target search path does to objects the
  pass would not have written. The question states the two clauses that
  disagree, the fault matrix's "`failed` for every walked ELF" against the
  case-identity section's "for cases 1, 2, 3 and 7 the case and the disposition
  always agree" plus the acceptance row calling `not dynamically linked`
  explicitly not a failure.
- Four options: 10A the literal every-walked-ELF reading; 10B failure only for
  the writing cases 4, 5 and 6; 10C a run-level skip; 10D leave it to the
  implementer. 10B is recommended on a two-clauses-against-one count and on which
  clause is load-bearing, the case-identity rule having three named consumers.
- **The answer is deferred to the reviewer**, not chosen in the plan, because
  Q09's adjudication discipline says a contested clause goes back for reviewed
  authority. The plan notes this is the first time that rule has bound on
  something other than the corpus.
- The framing paragraph is rewritten around the identifier collision, the
  ledger's falsity, the case-collapse error and Q10.
- Answers otherwise stand unchanged at 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A.

Validation skeleton:

- Step 4's expectations carry the enumerated reverse ledger with its set-equality
  check and the record that the earlier sentence was false; the four rows the
  inverse direction produced last round; the two things the field-level
  requirement found this round, the case-collapse error and Q10; the scoped fault
  identifiers with the reason; and the three-way derived-totals comparison with
  the note that the literal table is already verified.

### Writer response for plan relocation-force-rpath round 15

Writer response: All five requested changes are applied. Nothing is disputed. One question is
added, which the instruction permits only if the completed field-level reverse
mapping finds a genuine design silence or double reading, and it did.

Q10 is the substantive outcome of this round and it vindicates the reviewer's
insistence on justifying **fields** rather than scenarios. Justifying the
scenario, "empty search path, rpath fails", passes without incident. Justifying
the fields forces the question of where each cell's value comes from, and the
empty-search-path clause fixes an rpath disposition and fixes no case at all. The
writer had filled the case column with 1 across all six rows, which is not a
shorthand but an error, and the design refutes it in a section titled "The case
is identity; the disposition is what happened", which says the two must not be
collapsed. The plan quoted that section's consequence for write failures three
rounds ago and then collapsed the same two values somewhere else.

Having corrected the cases, the dispositions then produced a real conflict. The
fault matrix says `failed` for every walked ELF. The case-identity section says
cases 1, 2, 3 and 7 have no write "so for them the case and the disposition
always agree". The acceptance table says an object with no `PT_DYNAMIC` is `not
dynamically linked` because there is no search path to set, "which is not a
failure". A case 2 object under an empty search path cannot satisfy all three.
That is the design's problem rather than the plan's, and the plan's own Q09
adjudication rule says a contested clause goes back for reviewed authority. So
Q10 is raised with a recommendation and left unanswered, and the affected rows
are marked provisional with both readings' numbers recorded. This is the first
time that rule has bound on something outside the corpus, and the writer notes
that it would have been easy, and wrong, to pick 10B quietly and present the
matrix as complete.

The identifier collision is the writer's, and its origin is worth naming because
it is a new failure mode rather than a repeat. Round 13's inverse ledger showed
that the design's probe-failure row names a library, so the writer moved Step 4's
fault subject from a program to a library. That was the correct repair. It was
applied to the subject and not to the identifier, so `D01` went on meaning `F01`
with interpreter `ok` in Step 1 while meaning `X12` with interpreter
`not-applicable` in Step 4, and Step 2's bridge, written before either, named
`D01` and `D02` with no way to tell which. A correct local fix created a
cross-step ambiguity, and the writer checked the fix against the design and not
against the rest of its own document. That is the horizontal read the reviewer
performed and the writer still does not perform.

The ledger finding is the plainest of the three. The writer wrote a
design-to-matrix table, then a sentence saying every row cites a clause, and
called that two-way. It was one table and one claim. The claim was false on
inspection, `A11` having no entry, and `A11` is not an obscure row: it is the
second-pass excluded program, and supplying its derivation required noticing that
its interpreter was rewritten on the first pass so the guard's `!=` condition
fails on the second. The writer had asserted coverage of a row whose expected
value it had not derived.

The derived-totals change is accepted without reservation and the reviewer's
framing is better than the writer's flag. The writer flagged the totals table as
unverified arithmetic. The reviewer verified it, said so, and then asked for the
fold anyway, on the ground that the risk is not the arithmetic being wrong today
but the table becoming a second hand-maintained oracle tomorrow. That is the more
useful reading: a verified table and a derived table are the same today and
diverge the first time someone edits one row.

On convergence, and on the stated goal of converging next round.

The writer will not predict convergence, and the reason is specific rather than
modest. Q10 is now open and it is the reviewer's to answer, so this round cannot
converge by construction: an unanswered question is an open decision, and every
prior round has treated one of those as disqualifying. What the writer can say is
that Q10 is bounded, its options are enumerated, the recommendation rests on a
clause count rather than a preference, and the plan is fully written under both
readings, so whichever the reviewer picks the change is three cells and one
totals row.

Beyond Q10, the writer's honest position is that the exit condition the reviewer
stated has been met literally: the fault cases have unambiguous scope through all
three steps, the reverse mapping is real and exhaustive with a set-equality
check, and the trailer expectations are derived. The two mechanical detectors
added in round 13, the column-count assertion and the ledger, both fired this
round and found real defects, which is the first direct evidence that the
detectors work rather than merely existing.

What remains unaddressed is the pattern rather than any item: four consecutive
rounds of defects findable by reading the writer's own document against itself,
and this round added a fifth kind, a correct fix propagated to one place and not
the others. The writer has no mechanism to offer for that, and inventing one on
the last round would be worse than naming it.

One thing is offered for round 15.

The `R12` totals under 10B were recomputed by hand after the case correction, and
they are the only run whose object rows changed this round. The fold the plan now
requires would catch an error there, but the fold does not exist yet, so that row
of the totals table has the same status the whole table had last round: hand
arithmetic checked by the party that performed it. It is one row rather than
fourteen, and it is the row most recently disturbed.

### Reviewer focus for plan relocation-force-rpath round 15

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-15 -->

## Round 15 by reviewer

- Recorded: 2026-08-18T14:23:53+02:00
- Exchange: specification/plan/v0.27.0/relocation-force-rpath
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for plan relocation-force-rpath round 15

Round 15 is convergence-ready after the covered wording below. Q10 is a real
question and should be answered 10B. No further design choice, missing question,
or implementation uncertainty is identified.

Option 10B preserves the distinction the report is built to expose: the case is
the object's identity, while the disposition records what happened to the action
due for that object. An empty target search path prevents an rpath write for
selected cases 4, 5, and 6, so those objects are `failed`. It cannot make a write
fail for case 2, where no dynamic search path exists, case 3, where no write is
due, or case 7, which is deliberately excluded. Case 1 remains failed for its
own inspection or ambiguity reason. The writing objects still make the run fail
acceptance, so the narrower object-local meaning does not hide the fault in the
covered archive.

The plan already carries 10B's correct object rows and R12 totals. I
independently recomputed the changed run: its six rpath dispositions are three
`failed`, two `excluded`, and one `not-dynamic`; its interpreter totals remain
two rewritten, one unchanged, and three not applicable. The arithmetic is
correct.

All round 14 substantive work is present. Step 1's D01/D02 producer witnesses
are distinct from Step 4's IF/IW integration runs, Step 2 names the producer
tuples explicitly, the reverse mapping now enumerates A01 through A28 including
A11, and trailer expectations are folded rather than merely transcribed.

One mechanical residue remains and is covered wording rather than another
round. After R8 through R11 were renamed IF01, IF02, IW01, and IW02, the set
equality and two completion statements still say `R0..R13` plus the four fault
runs. That set demands four obsolete ids which no longer exist. The actual 14-run
set is R0 through R7, IF01, IF02, IW01, IW02, R12, and R13. Correcting those
ranges is necessary for the newly mechanical check to pass, but it introduces
no new behavior or choice.

The disposition is `convergence-recommended`. The covered edits settle Q10 as
10B, remove its provisional markers, replace the conflicting global fault
wording with object-local wording, correct the stale run-id sets, and mirror the
same text in the validation skeleton. The existing options otherwise remain
sufficient, and answers are 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A, and 10B.

### Question verdicts for plan relocation-force-rpath round 15

No question is missing. Q10 is necessary, its options are materially distinct,
and option 10B follows from the settled report semantics.

- Q01: choose 1A; keep the relocation harness separate from the mirrored item-1
  harness.
- Q02: choose 2A; preserve the standalone deployment contract and measure the
  production file.
- Q03: choose 3A; retain the independent ELF oracle, complete tuples, bounded
  doubles, and per-process preflight.
- Q04: choose 4D; land behavior and emission atomically after the uncalled
  formatter preparation.
- Q05: choose 5C; use the fixed associative-array carrier with the exact-target
  capability debt explicitly bounded.
- Q06: choose 6A; keep terminal monitoring blockage distinct from a session that
  never ran.
- Q07: choose 7A; create and test the source-safe production seam.
- Q08: choose 8A; keep the retained-output reader in the harness.
- Q09: choose 9A; retain the ranked, audited, frozen `/1` corpus and its
  adjudication rule.
- Q10: choose 10B. Only cases 4, 5, and 6 have an rpath write due and therefore
  fail when its target cannot be formed. Cases 1, 2, 3, and 7 retain their
  case-defined dispositions; case 1 can still be failed for its independent
  reason. This keeps failure counts object-local, preserves the explicit
  not-dynamic acceptance, and still fails the covered run through its selected
  objects.

The final answers are 1A, 2A, 3A, 4D, 5C, 6A, 7A, 8A, 9A, and 10B.

### Convergence evidence for plan relocation-force-rpath round 15

Covered wording: 1. Replace `#### Answer to Q10: deferred to the reviewer` and its paragraph with
   an answer selecting option 10B: an empty computed target search path gives
   rpath `failed` to cases 4, 5, and 6, whose writes were due; cases 1, 2, 3,
   and 7 keep their case-defined dispositions. State that case 1 may already be
   failed for its independent inspection or ambiguity reason.

2. Remove the `(Q10)`, `provisional`, `contested`, and deferred-answer markers
   from A25, A26, A27, R12, their reverse-ledger entries, and the completion
   criteria. Keep the current 10B values unchanged: A25 and A26 `excluded`, A27
   `not-dynamic`, and R12 totals of `r-failed=3`, `r-not-dynamic=1`, and
   `r-excluded=2`.

3. Replace the conflicting fault wording, wherever the plan quotes or carries
   it as authority, with: an empty or unavailable computed target search path
   makes the rpath disposition `failed` for each selected case 4, 5, or 6 object
   whose write cannot be formed; non-writing cases retain their case-defined
   dispositions, and the interpreter axis remains independent. Carry this same
   clarification into the authoritative design text before implementation so
   the plan does not remain downstream of a contradictory clause.

4. Correct the reverse-ledger set equality from
   `{A01..A28} union {R0..R13, IF01, IF02, IW01, IW02}` to
   `{A01..A28} union {R0..R7, IF01, IF02, IW01, IW02, R12, R13}`. Apply the
   same actual run set to the Step 4 statements currently saying the matrix
   covers `R0` to `R13` and every run `R0` to `R13` plus the four fault runs.

5. Mirror the settled Q10 wording, removal of provisional status, authoritative
   fault clarification, and corrected run-id set in the validation skeleton.

Convergence rationale: Every in-scope decision is now settled. Q10 resolves the sole live conflict as
10B, and the plan already contains the resulting object rows and verified totals.
The remaining edits are covered wording: make that answer final, remove
provisional labels, amend the conflicting global phrase to the selected
object-local rule, and correct a stale identifier range after four runs were
renamed.

The implementation contract is otherwise closed and mechanically checkable:
fixtures and fault identities are scoped, the producer-to-consumer bridge is
literal, the matrix is rectangular, traceability closes in both directions,
expected trailers are derived from object rows, captures reconcile
categorically, and production emission has two enumerated call sites. Another
automated review round would repeat settled analysis rather than decide an open
question. Consolidation remains subject to the human gate.

### Writer instructions for plan relocation-force-rpath round 15

Apply only the covered wording for Q10 and the stale run-id ranges before
presenting the convergence gate. Do not reopen the matrix, suite boundary,
call-site topology, wire grammar, fixture decisions, or answers Q01 through
Q09.

Settle Q10 as 10B, make its already-written rows and totals final, and ensure the
authoritative design wording used by the plan no longer says every walked ELF
fails when only selected writing objects do. Then replace every obsolete
`R0..R13`/`R0 to R13` enumeration with the actual 14-run set and mirror those
wording edits in the validation skeleton.

### Final reviewer decision for plan relocation-force-rpath round 15

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-15 -->
