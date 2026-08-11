# Specification review transcript for v0.27.0

- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-08-11T10:36:57+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for plan rsync-cp-fallback round 1

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
Review round: 1

### Requestor assessment for plan rsync-cp-fallback round 1

The plan implements the settled design, whose seven decisions are recorded in
its "Design decisions" table, and the settled requirement behind it. Six steps:
a verification harness with a timing gate, engine selection, the mirror
fallback, the root-file fallback, the failure contract with its documentation,
and acceptance on both targets. Six open questions are placed, all
implementation-level.

One thing the reviewer should judge before anything else, because it shapes the
whole document. The `write-plans` instruction and its template assume a Python
repository: pytest TDD files, `__init__.py`, coverage percentages, a 550 and 650
line policy, and a `ghog day` gate loop. This repository has none of that. It
was checked rather than assumed: no `tests/` tree, no `pyproject.toml`, no
`check.bat`, no `GROUNDHOG.md`, and the only shell test in the tree is an
unrelated `tools/dev_workflow/shcolors/test_colors.sh`. The plan therefore
replaces that machinery rather than filling it in, and opens with a section
naming each substitution so no reader waits for a coverage number that will
never come.

The substitutions, for the reviewer to accept or reject as a set:

- the gate loop becomes a scratch-prefix shell harness run on both targets,
  modelled on the retained `measurements.*.txt` runs, which is the only
  precedent this repository has for proving installer behaviour;
- unit tests become harness cases, and the validation plan's "Unit test coverage
  check" becomes "Harness case check";
- the performance check becomes a cost and timing check, since the installer is
  a one-shot batch process with no hot loop, and the one real timing obligation
  is that a FIFO destination is refused promptly rather than blocking;
- the Step 0 perf gate becomes a timeout-bounded FIFO probe that must fail
  before Step 3 and pass after it, which is the same intent as an xfail.

Whether questions are missing. Three areas were considered and left out, and the
reviewer should confirm each: anything settled by the design's decision table,
which would be a question at the wrong altitude; the exact shell constructs
inside each helper, which is implementation detail below plan level; and the
consuming project's shim removal, which the design already places downstream.

Whether the options and answers are sufficient. Q02 and Q04 deserve the most
attention. Q02 proposes a synthetic archive for the per-step cases and a real
archive for acceptance, which is a two-fixture design that could reasonably be
called over-engineering for a six-step plan. Q04 splits the documentation step
rather than keeping or folding it whole, on the argument that the host-tool
inventory has been written wrong four times and should be written once from the
finished state while the fatal messages are cheap to keep correct continuously.
Both are judgement calls where the reviewer may prefer the simpler uniform
answer.

Two risks the plan carries that the reviewer may want stated more strongly.
First, the harness is new code with no harness of its own, so a false pass is
possible and nothing catches it; the plan mitigates only by requiring the Step 0
cases to fail on the current installer before any step claims them. Second, the
acceptance step needs a real archive and both targets, so it cannot run on a
developer machine, which makes it the one step whose readiness depends on
external access rather than on the repository.

### Change summary for plan rsync-cp-fallback round 1

Round 1 for the plan, so there is no preceding round to compare against. Both
documents were written in this cycle, immediately after the design consolidated.

Inputs:

- `design.v0.27.0.rsync-cp-fallback.md`, consolidated after five review rounds,
  with its seven-row "Design decisions" table;
- `issue.v0.27.0.rsync-cp-fallback.md`, consolidated after four rounds;
- `measurements.index.md` and its six retained raw outputs, which supply the
  behaviour every step's cases assert;
- direct inspection of `src/setups/env/bin/install_pkg.sh`, `pkg.sh` and the two
  wiki reference pages, for line counts and structural anchors.

Written this round:

- `plan.v0.27.0.rsync-cp-fallback.md`: six steps, each with its analysis and
  intent, its implementation with files and cases, and its addendums with the
  line-budget checkpoint. Plus the departures section, scope anchors, a cost and
  IO section rewritten for a batch process, confirmed facts with current line
  counts and the file's structural anchors, the verification harness definition,
  the shared execution checklist and the ready-to-run commands.
- `plan.v0.27.0.rsync-cp-fallback.validation.md`: the skeleton, with `Goal` and
  `improvement expectations` filled for all six steps, every other per-step
  section carrying the literal placeholder, each `Analysis` opening with "Not
  started. Step N is not implemented because ...", and no "Missing work"
  sections since no check has taken place.

Two things the validation plan carries beyond the skeleton, deliberately:

- the equivalence comparison recipe, in full, because the design settled that no
  comparator ships and the recipe must live somewhere reproducible;
- its own departures note, so the replaced "Unit test coverage check" and
  "Performance check" sections are explained where they are missing rather than
  only in the plan.

Six open questions were added through `oqm` after both documents were written,
so the plan body reflects the recommended answers where they touch it.

Facts asserted about the repository were read rather than recalled:
`install_pkg.sh` is 505 lines; `relocation-tools.md` is 85; `exit-codes.md` is
101; the helper convention sits at lines 108, 127, 170 and 212; the two call
sites are at the section comments on lines 441 and 459.

### Writer response for plan rsync-cp-fallback round 1

Writer response: No reviewer feedback exists yet: this is the first request of the plan exchange,
so nothing has been accepted, adapted or disputed.

Three boundaries the writer intends to hold, stated up front so a disagreement
can be raised in the first answer rather than in a later round:

- The design's seven decisions and the requirement's nine clarifications are
  settled and are not reopened at plan level. A reviewer point that would change
  which shapes are refused, what the override is called, or which copy forms are
  used belongs to those documents.
- Shell constructs inside a helper are below plan level. Which test builtin
  observes a file type, or how a variable is quoted, belongs to the
  implementation and its review, not here.
- The template departures are a package, not a menu. If the reviewer wants the
  pytest and coverage machinery restored, that is a decision to create this
  repository's first Python test tree, which is a larger change than this item
  and would need its own justification.

One thing offered for challenge rather than defended. The writer chose to state
the departures prominently, at the top of both documents, rather than quietly
adapting the template. That costs a section in each and makes the documents
open on what they are not doing. The alternative, adapting silently, reads
better but leaves a reader to wonder whether the missing coverage section was an
omission or a decision. If the reviewer finds the prominence excessive, moving
both notes to the end is a presentational change the writer would accept.

The writer's own doubt, for the record: the verification harness is the load
-bearing new artefact in this plan and it has nothing checking it. Its only
guard is that Step 0 requires its cases to fail on the current installer before
any later step is allowed to claim them. That is a real guard against a harness
that passes everything, but it is not a guard against a harness that tests the
wrong thing, and the writer does not have a better idea inside this item's
scope.

### Reviewer focus for plan rsync-cp-fallback round 1

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer

- Recorded: 2026-08-11T10:44:41+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 1

The departures from the Python-oriented plan template are justified as a
package. This repository has no Python package, pytest or Groundhog gate, and a
scratch-prefix shell harness plus retained two-target evidence is the right
substitute. A synthetic archive for fast per-step cases and a real archive for
final acceptance is also the right split. The six implementation steps follow
the settled requirement and design without reopening them.

The proposed Step 0 FIFO gate cannot produce its required baseline result,
however. Today's installer has no `cp` fallback. With rsync absent it exits 5 at
the mirror before reaching any root-file destination; with rsync present it
uses rsync for the root file, and M2 shows rsync replaces a FIFO promptly. There
is no current-installer path on which the root-file FIFO case times out. The
plan and validation skeleton repeatedly require exactly that impossible result,
so Step 0 could not complete as written.

Keep the timeout wrapper, but separate two duties. Calibrate the watchdog with
a controlled operation that deliberately blocks on a FIFO and must be reported
as a timeout. For the installer regression case, require an exact baseline
failure on the current installer—wrong phase, exit code or missing preflight
diagnostic—not a timeout. After Step 3 the same installer case must reach the
root-file preflight and return exit 7 promptly with the FIFO intact. This gives
the timing machinery a real negative control without inventing behavior the
current installer does not have.

The requestor's concern about trusting the harness is therefore a missing plan
question rather than only a risk note. Add a question deciding how its oracles
are calibrated. The recommended answer is a self-calibrating case contract:
each case verifies its fixture precondition, records the exact installer and
archive it invoked, asserts a phase-specific diagnostic and exit code, and
checks independent post-state sentinels. It also runs controlled negative
controls, including an exit-only/no-state-change substitute that must fail, so
an implementation that checks only status cannot bless itself. The retained
current-installer baseline and the M1-M4 rows then provide independent expected
results. This does not eliminate the need to review the harness code, but it
guards both "everything passes" and "the wrong operation was exercised" better
than a generic red-before-green requirement.

The equivalence recipe is not yet executable enough to be the one-off proof the
design requires. It says to emit and compare record sets but does not define a
stable record order, serialization, digest command or retained diff. It also
says ownership is normalized without emitting ownership in the record. Specify
the exact manifest command or harness operation, including deterministic order,
safe path encoding, entry type, bytes/digest, mode, mtime, owner, symlink target
and the transfer-root record. Retain both manifests and their comparison output.
Hard-link topology needs no emitted field if it is deliberately ignored, but
that omission should be explicit rather than described as a normalization that
never occurs.

Three accepted plan answers are not integrated into the numbered work:

- Q04 selects 4C, but Steps 2 and 3 do not take ownership of their fatal-message
  rewording, while Step 4 still lists both messages as its work. Move exit-5
  wording and its case into Step 2, exit-7 wording and its case into Step 3, and
  leave Step 4 with the header and final wiki contract.
- Q06 selects committed raw evidence with a sanitizing pass as a numbered shared
  checklist item, but the checklist goes directly from retaining output to its
  end and names no scan command or clean-result criterion. Add that mandatory
  step before any `verify.*.txt` becomes committable.
- Q05 selects a hard 650-line Bash ceiling even though the plan correctly says
  the repository policy is Python-scoped. More importantly, its prescribed
  split into a required sourced companion would make `install_pkg.sh` cease to
  be a standalone file beside an archive. Choose 5A: record the per-step counts
  and treat unexpected growth as a review signal; any future split must first
  design how standalone delivery remains intact rather than firing at an
  imported numeric threshold.

One cost statement should be narrowed with Q05. The exact number of filesystem
observations depends on the shell construct that implements a non-following
type check, which the plan deliberately leaves to implementation. Promise
constant work per destination and no tree traversal, not "two stat-class calls
per transfer". Likewise, engine detection adds one path lookup even on rsync
runs, so "the rsync path adds nothing" should be scoped to the transfer
operation rather than the whole run.

No new measurement is required. These are plan consistency and harness-oracle
changes.

### Question-by-question decisions for specification reviewer round 1

1. **Q01: accept option 1A.** Keep the effort-local harness under
   `docs/v0.27.0/`; it is retained verification tooling and must not ship in the
   archive.
2. **Q02: accept option 2A.** Use a synthetic archive for Steps 0-4 and the real
   published archive for Step 5 acceptance.
3. **Q03: accept option 3A.** Use one helper per independent transfer path,
   following the script's existing convention.
4. **Q04: accept option 4C, but integrate it.** Fold each fatal message and case
   into the step that creates its engine branch; write the inventory and wiki
   contract once after the code is complete.
5. **Q05: choose option 5A, not 5B.** Record line counts and review unexpected
   growth without inventing a Bash ceiling or a split that breaks standalone
   operation.
6. **Q06: accept option 6A after adding the promised sanitization gate.** Commit
   retained outputs only after the named sensitive-content check passes.
7. **Missing Q07: how the new harness proves its own oracles are sensitive.**
   Recommend fixture preconditions, phase-specific outcomes, post-state
   sentinels, watchdog calibration and deliberate negative controls, with the
   exact contract recorded in Step 0.

### Requested changes for specification reviewer round 1

1. Redesign the Step 0 FIFO baseline so the watchdog is calibrated by a known
   blocker and the current installer fails for its real phase/behavior, not an
   impossible timeout. Synchronize the validation skeleton.
2. Add and answer the harness-oracle calibration question, then make its chosen
   controls and retained evidence explicit in Step 0.
3. Turn the equivalence recipe into an executable deterministic manifest recipe,
   including ownership handling and retained manifests/diff.
4. Apply Q04-4C to the actual step ownership: messages in Steps 2 and 3; header,
   wiki inventory and final contract in Step 4.
5. Replace Q05-5B with 5A and remove the 650-triggered companion split unless a
   standalone-safe extraction is separately designed.
6. Apply Q06-6A to the shared checklist with a named sanitization command and a
   clean gate before evidence is committed.
7. Replace unsupported syscall counts with constant-per-destination cost bounds
   and scope the unchanged-rsync claim to its transfer operation.

### Reviewer decision for specification reviewer round 1

Disposition: changes-requested. The template substitutions and most step
boundaries are sound, but the load-bearing harness begins with an impossible
negative result, lacks an oracle-calibration decision, and carries an
under-specified equivalence proof. Apply the changes and start plan review round
2; do not consolidate yet.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-08-11T13:25:06+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for plan rsync-cp-fallback round 2

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
Review round: 2

### Requestor assessment for plan rsync-cp-fallback round 2

All seven round 1 requested changes are applied. Seven questions are now live,
Q01 through Q07, the last added at the reviewer's request. No measurement is
requested.

The central finding was a genuine planning error and the writer verified it
before acting rather than accepting it on authority. Step 0 required the
root-file FIFO case to time out on the current installer. There is no such path,
and the two configurations fail differently for different reasons: with rsync
absent the installer exits 5 at the mirror site and never reaches the root-file
site at all, and with rsync present the root-file step uses rsync, which M2
measured replacing a FIFO promptly with exit 0. The block belongs to `cp`, which
today's installer never invokes. A step whose baseline cannot be produced would
have stalled the moment someone ran it.

The fix follows the reviewer's separation exactly. The watchdog is now
calibrated on a deliberate blocker, a copy onto a reader-less FIFO invoked
directly rather than through the installer, and that case is permanent: it must
keep reporting a timeout in every later step, which is what keeps the word
"promptly" falsifiable in Step 3. The installer case now records the current
installer's real behaviour per configuration, and Step 3's success criterion
became a transition from that recorded baseline, rsync replacing the FIFO with
exit 0, to the preflight refusing it with exit 7.

Q07 is added and answered on the reviewer's recommended contract: fixture
preconditions, recorded installer and archive identity, phase-specific
diagnostics paired with exit codes, independent post-state sentinels, and
deliberate negative controls including an exit-only substitute that must fail.
The question records the impossible baseline as its own evidence, because it is
the concrete demonstration that a generic red-before-green rule is not enough: it
was satisfiable in the abstract and false in the particular, and only writing the
baseline out per case exposed that.

The equivalence recipe is now executable. It specifies the field list and its
order, a path encoding that a newline in a filename cannot forge, a digest
stream joined on the path, `LC_ALL=C sort` for byte-stable ordering, the transfer
root as a record, and `diff -u` with both manifests and the diff retained.
Ownership is emitted rather than described as normalized, which was the
contradiction the reviewer caught, and hard-link topology is recorded as a
deliberate omission rather than a normalization that never occurs.

Q05 moved from 5B to 5A, and the reviewer's second argument was the decisive
one. The first answer adopted 650 as a harmless ceiling that would catch later
drift; the prescribed remedy was extracting the transfer helpers into a sourced
companion, which would end the script's standalone operation beside an archive.
Standalone delivery is a property of how the installer is used, so a borrowed
numeric threshold must not be able to fire a change that removes it. The plan now
records counts per step with no ceiling and no prescribed split.

Q04 and Q06 are integrated into the numbered work rather than left as accepted
answers: exit-5 wording and its case now belong to Step 2, exit-7 wording and its
case to Step 3, Step 4 keeps only the header and the wiki contract, and the
shared checklist gained a named scan command with a clean-result gate before any
`verify.*.txt` becomes committable.

The cost statements are narrowed as requested: constant work per destination and
no tree traversal, rather than a syscall count the plan cannot promise while
leaving the shell construct to implementation; and the unchanged-rsync claim is
scoped to the transfer operation, since engine detection adds one path lookup on
every run.

What the reviewer should press on. First, whether the negative controls are the
right three. They guard vacuous passes and wrong-operation passes, but nothing
guards a case whose sentinels are themselves wrong, and the writer does not have
a fourth control that would. Second, whether Step 0 has become large enough to
split: it now carries the case contract, three negative controls and a two-target
baseline capture, which is more than the other steps do.

### Change summary for plan rsync-cp-fallback round 2

Changes since round 1, mapped to the seven requested changes.

1. Step 0 redesigned and retitled "Verification harness, calibrated oracles and
   baseline capture". The watchdog is calibrated by a deliberate blocker
   invoked outside the installer; the installer cases record the current
   installer's real failures, exit 5 in the mirror phase with rsync absent, and
   rsync's prompt FIFO replacement with exit 0 when present. The step states in
   its own analysis why the previous baseline was impossible. Its time-gated
   status now says no installer case may assert a timeout. Step 3's criterion is
   restated as a transition from that baseline, and the departures section and
   the plan goal are reworded to match.
2. Q07 added and answered, on the self-calibrating case contract: fixture
   precondition, recorded installer and archive identity, phase-specific
   diagnostic with exit code, independent post-state sentinels, plus three
   negative controls, watchdog calibration, an exit-only substitute and a
   wrong-archive substitute. Step 0 carries the contract and the controls as
   named work with retained evidence.
3. The equivalence recipe in the validation plan is now executable: field list
   and order, path encoding, a digest stream joined on the path, `LC_ALL=C sort`,
   the transfer root as a record, `diff -u` with both manifests and the diff
   retained, ownership emitted rather than assumed normalized, and hard-link
   topology stated as a deliberate omission.
4. Q04-4C integrated. Step 2 owns the exit-5 rewording and its case, Step 3 owns
   the exit-7 rewording and its case including the preflight refusals, and Step 4
   now lists only the header comment and the wiki contract. The Step 4 grep check
   is reframed as a no-regression check on what Steps 2 and 3 achieved, and the
   plan goal line for Step 4 says where the messages went and why.
5. Q05 answered 5A instead of 5B. The departures section no longer adopts a
   ceiling, and the Step 2 split guidance is replaced: no split is prescribed,
   and any future extraction must first design how standalone delivery survives
   it.
6. Q06 integrated into the shared execution checklist as numbered steps 7 and 8:
   a named scan driven by the repository rule file rather than by inlined terms,
   which must return nothing, and only then retention and commit.
7. Cost statements narrowed in both the plan and the validation plan: constant
   work per destination with no tree traversal rather than two `stat`-class
   calls, and the unchanged-rsync claim scoped to the transfer operation, with
   the one added path lookup for engine detection stated.

No step was added or removed; the six steps and their boundaries are unchanged
apart from the message ownership move. Q01, Q02 and Q03 are untouched, all three
accepted in round 1.

### Writer response for plan rsync-cp-fallback round 2

Writer response: All seven requested changes are accepted and applied. No disagreement to record.

The impossible Step 0 baseline is the finding worth dwelling on, because it is a
different kind of error from the ones this effort has made before. The earlier
mistakes were inferences that reached past their evidence. This one was a rule
applied without checking whether it could be satisfied: "the gate must fail
before the work" is sound, and the writer instantiated it with a failure mode
the current installer cannot produce, having read the M2 FIFO row as a property
of the installer rather than of `cp`. The installer does not call `cp` at all
today. One minute of tracing the two configurations would have caught it, and
the writer did not spend it.

That is also why Q07 is written the way it is. The reviewer asked for a
calibration decision, and the honest way to argue for it was to put the failure
in the question: a generic red-before-green requirement is exactly what produced
an unsatisfiable baseline, because it says the case must fail without saying how,
and a wrong how is invisible until someone runs it.

Two things the writer is uneasy about and would rather have challenged than
accepted quietly.

The negative controls guard two failure modes, a case that passes vacuously and
a case that exercises the wrong operation. They do not guard a case whose
post-state sentinels are themselves wrong, checking the wrong path or the wrong
property. The writer has no third control that would catch that without becoming
a second harness, and states it as a residual rather than pretending the
contract is complete.

Step 0 has grown. It now carries the case contract, three negative controls and a
two-target baseline capture, which is more work than any other step, and the
plan's own argument for small steps applies to it. Splitting it into a harness
step and a baseline step is a real option; the writer did not do it because the
controls and the baseline are what make each other meaningful, but that is a
judgement the reviewer may weigh differently.

The boundaries stated in round 1 still hold: the requirement's nine
clarifications and the design's seven decisions are not reopened, and shell
constructs inside a helper remain below plan level, which is why the cost
statement is now a bound rather than a syscall count.

### Reviewer focus for plan rsync-cp-fallback round 2

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-08-11T13:30:19+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 2

The round 1 FIFO finding is fixed correctly. Step 0 no longer asks the current
installer to exhibit a path it does not have: the deliberate blocker calibrates
the watchdog independently, the no-rsync run records its real exit-5 mirror
failure, and the rsync-present run records rsync replacing the root-file FIFO.
Step 3 then has a measurable transition to a prompt exit-7 refusal. Keeping the
watchdog case permanent makes the timing assertion falsifiable.

The other planning decisions also improved. Q04-4C now appears in the actual
step ownership, Q05-5A preserves standalone delivery without importing a Python
line ceiling, the cost statements make only constant-work claims they can
support, and Q06-6A places sanitization before evidence retention. Q07-7A is the
right answer: fixture, phase, identity and post-state evidence plus negative
controls are proportionate for a harness that will carry the acceptance case.
The inability to recursively prove every sentinel is an honest residual, not a
missing question. Step 0 is large but cohesive; splitting calibration from the
baseline would create an ordering seam without reducing the assurance burden,
so it should remain one step.

Three related executable-contract defects remain in that harness work.

First, the wrong-archive negative control cannot fail the fixture precondition
as written. The contract checks the planted destination shape before invoking
anything; that shape is independent of which archive is later selected.
Moreover, recording the installer and archive paths does not by itself stop a
case from using the wrong one. The case contract must declare and assert the
expected resolved installer and archive identities. The wrong-archive control
must then fail that identity assertion, not the unrelated fixture precondition,
and its retained output must show that this is the reason it failed.

Second, the equivalence recipe still describes an implementation rather than
providing the exact manifest command or harness operation requested in round 1.
It leaves `find ... -printf` open to an equivalent formatter, names neither the
path encoding nor its excluded field separator, and calls for a single digest
command without choosing the utility or invocation. "The same traversal order"
is not a deterministic join key because filesystem traversal order is not
promised. The serialization also protects only the relative path: a symlink
target containing a tab or newline can still forge a field or record boundary.

Choose one implementation and spell it out completely. It must encode every
variable-length filename-bearing field, including relative paths and symlink
targets, define the transfer-root representation, select the exact digest
utility, join by encoded relative path rather than traversal position, and name
the exact byte-stable sort and comparison operations. A harness function is as
acceptable as a pasted shell pipeline, but "or equivalent", an unnamed encoding
and an unnamed digest are not executable instructions.

Third, the declared harness dependency boundary does not match the work. The
plan says the harness uses only the installer's audited host-tool contract plus
`timeout`, while Step 5 also requires `sort`, `diff`, a digest utility and
whatever implements the chosen encoding. The shared checklist similarly says
to read patterns from the replacement mapping and grep with them, but supplies
no command that extracts only the pattern side of that mapping. Declare the
complete verification-only tool set and preflight it on each target, or choose
implementations from the already-audited set. Add a ready-to-run sanitization
command or named existing scanner that parses the mapping format without
embedding the protected terms in the plan. The clean-result gate and ordering
already present should remain.

No new measurement is required. These are deterministic harness and plan
contract corrections, and they do not reopen the settled requirement or design.

### Question-by-question decisions for specification reviewer round 2

1. **Q01: accept option 1A.** The effort-local harness is retained verification
   tooling and remains outside the shipped archive.
2. **Q02: accept option 2A.** Synthetic archives fit Steps 0 through 4; the real
   published archive belongs in final acceptance.
3. **Q03: accept option 3A.** Separate helpers preserve the mirror and root-file
   boundaries and match the script's existing structure.
4. **Q04: accept option 4C.** The plan now correctly owns fatal-message wording
   in Steps 2 and 3 and writes the wiki inventory once in Step 4.
5. **Q05: accept option 5A.** Per-step deltas are the defensible signal; no
   unsupported Bash ceiling or standalone-breaking split should be introduced.
6. **Q06: accept option 6A, with the executable scan correction above.** Retain
   the evidence, but make the rule-file-driven gate a command rather than prose.
7. **Q07: accept option 7A, with the archive-identity correction above.** The
   self-calibrating contract is sound once identity is asserted and its negative
   control targets that assertion.

No additional open question is needed. The remaining choices are implementation
details required to make already-selected answers executable.

### Requested changes for specification reviewer round 2

1. Make expected installer and archive identities assertions in the shared case
   contract, and make the wrong-archive negative control demonstrably fail the
   archive-identity assertion rather than the fixture precondition.
2. Replace the equivalence recipe's alternatives and placeholders with one
   exact harness operation: byte-safe encoding for relative paths and symlink
   targets, an explicit field separator and root representation, an exact digest
   command, path-keyed joining, deterministic sorting, and retained manifests
   plus `diff -u` output.
3. Reconcile the harness dependency statement with Step 5. Name and preflight
   every verification-only command on both targets, or constrain the operation
   to the audited host-tool set.
4. Turn the Q06 sanitization prose into a ready-to-run rule-file-driven command
   or named scanner that correctly parses the replacement mapping and exposes
   no protected literal in the committed plan.

### Reviewer response to the requestor's two concerns

Do not add a second harness merely to check the sentinels. Fixture assertions,
identity assertions, phase diagnostics, independent post-state checks, negative
controls and code review form a reasonable assurance boundary. The current
wrong-archive control does need correction because it does not exercise the
identity evidence it claims to calibrate.

Do not split Step 0 for size alone. Calibration and baseline capture establish
one prerequisite: trustworthy executable oracles for all later steps. Their
coupling is stronger than the line-count argument for separating them, and the
plan already calls for shared case-contract code rather than repetition.

### Reviewer decision for specification reviewer round 2

Disposition: changes-requested. The installer baseline and all seven plan
decisions are now sound, but the load-bearing verifier still contains a negative
control aimed at the wrong assertion and two prose-only execution contracts.
Make the focused corrections above and run plan review round 3; do not
consolidate yet.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-08-11T13:51:19+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for plan rsync-cp-fallback round 3

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
Review round: 3

### Requestor assessment for plan rsync-cp-fallback round 3

All four round 2 requested changes are applied. Seven questions remain live,
Q01 through Q07, all answered and none reopened. Step 0 stays one step, and no
measurement is requested.

The identity finding was correct and the correction is larger than it looks.
Round 2 review pointed out that the wrong-archive control could not fail the
fixture precondition, because the planted destination shape is independent of
which archive is later selected, so that control would have passed its
precondition and proved nothing. The deeper half of the finding is that
recording an identity is not asserting it: a case that records the wrong
installer path still passes. The case contract now requires each case to declare
the installer and archive it intends to exercise, and the harness asserts the
resolved values against those declarations before running, naming which identity
differed. The wrong-archive control now targets that assertion, and its retained
output must say so. A wrong-installer control is added on the same principle,
since the same weakness applied to the installer path.

The equivalence recipe is replaced rather than tightened, because round 2 was
right that the previous version described an implementation instead of being
one. It is now a single specified operation with no alternatives: byte-safe
enumeration by `find -printf '%P\0'`, both filename-bearing fields hex-encoded
so a tab or newline in a path or a symlink target cannot forge a field or a
record, a fixed nine-field order, `stat -c` for the fixed fields, `sha256sum`
for regular-file digests emitted on the same line so no join is needed at all,
`readlink` for symlink targets, `LC_ALL=C sort`, and `diff -u` with all three
files retained. The traversal-order join is gone, which was the subtlest of the
three defects: nothing promises traversal order, so a join on it was not
deterministic even though it looked like one.

The dependency boundary is now stated in full and reconciled with Step 5. Most
of what the harness uses is already inside the installer's audited set. Five
commands are verification-only additions, `timeout`, `stat`, `sha256sum`, `diff`
and `mkfifo`, listed with what each is for, and the harness preflights all five
on each target before running a case rather than failing part way through. The
sanitization scan is deliberately built from `sed` and `grep` alone so it adds
nothing to that list.

The sanitization gate is now a ready-to-run command rather than prose. It parses
the mapping format, extracts only the pattern side, strips the inline
case-insensitivity prefix because `grep -E` takes case-insensitivity as a flag,
and greps with a pattern file, so no protected term appears in the plan. The
clean-result semantics are stated explicitly: the grep exit status is 1 when
nothing matched, and only that allows retention.

That gate exists because the previous version of it broke its own rule. The
first attempt inlined the protected terms as a literal pattern, which made this
plan fail the scan it had just introduced and carried the terms into the review
transcript. Both were corrected in the same turn, and the rule is now stated in
the plan as well as implemented: a committed document must never enumerate the
terms it protects against.

The two concerns from round 2 are settled by the reviewer's answers and the plan
follows them: no second harness for the sentinels, and Step 0 stays unified,
since calibration and baseline capture establish one prerequisite and splitting
them would add an ordering seam without reducing the assurance burden.

What the reviewer should check. First, whether the manifest's per-entry process
cost is acceptable: the recipe spawns `stat`, `od`, `sha256sum` and `readlink`
per entry, which on a full toolchain tree is slow, and the plan accepts that
rather than optimizing because it runs twice, once, at acceptance. Second,
whether hex-encoding both filename-bearing fields makes the retained manifests
unreadable to a human auditor, which is a real cost of byte-safety that the diff
inherits.

### Change summary for plan rsync-cp-fallback round 3

Changes since round 2, mapped to the four requested changes.

1. Identity becomes an assertion, in the Step 0 case contract. Each case
   declares the installer path and archive path it intends to exercise; the
   harness compares the resolved values against those declarations before the
   run and fails on mismatch, naming which identity differed. The wrong-archive
   negative control now targets the archive-identity assertion, and its retained
   output must name that as the reason it failed; the previous version expected
   it to fail the fixture precondition, which it could not, and the plan records
   why. A wrong-installer control is added, since the same weakness applied to
   the installer path. The validation skeleton's Step 0 expectations are
   synchronized.
2. The equivalence recipe in the validation plan is replaced by one exact
   operation, stated as the harness function `emit_manifest <root> <out>`:
   `find -printf '%P\0'` enumeration, hex encoding of the relative path and the
   symlink target through `od -An -v -tx1`, the transfer root written as the
   literal token `ROOT`, `stat -c` for entry type, size, mode, mtime, uid and
   gid, `sha256sum` for regular-file digests emitted on the same line so no join
   is required, `readlink` for symlink targets, a fixed nine-field tab-separated
   order, `LC_ALL=C sort`, then `diff -u` with all three files retained. The
   "or equivalent" formatter, the unnamed encoding, the unnamed digest and the
   traversal-order join are gone. The omissions section now distinguishes what is
   not emitted, hard links and extended attributes, from what is emitted and must
   match, ownership.
3. The harness dependency boundary is declared in full and reconciled with Step
   5: the commands already inside the installer's audited set are named, and the
   five verification-only additions, `timeout`, `stat`, `sha256sum`, `diff` and
   `mkfifo`, are tabulated with their purpose. The harness preflights all five on
   each target before running any case.
4. The Q06 sanitization prose became a ready-to-run command in the shared
   checklist: it extracts the pattern side of the mapping with `sed`, strips the
   inline case-insensitivity prefix, greps `docs/v0.27.0/` with the pattern file,
   and states that a grep status of 1 is the clean result that allows retention.
   It uses only `sed` and `grep`, so it adds nothing to the tool set, and it
   embeds no protected literal.

Also corrected in the same pass, and reported because it was self-inflicted: the
first version of that sanitization gate inlined the protected terms as a literal
grep pattern, which made this plan fail its own scan and carried the terms into
the round 2 transcript entry. The plan and the transcript are both corrected, and
the plan now states the rule it broke, that a committed document must never
enumerate the terms it protects against.

No step was added, removed or split. Step 0 remains one step per the reviewer's
answer, and all seven questions keep their answers.

### Writer response for plan rsync-cp-fallback round 3

Writer response: All four requested changes are accepted and applied. No disagreement to record,
and both of the writer's round 2 concerns are withdrawn on the reviewer's
reasoning: no second harness for the sentinels, and Step 0 stays whole.

The identity finding deserves a specific acknowledgement, because the writer had
the right instinct and stopped one step short of it. The case contract already
required recording the installer and archive it invoked. Recording is evidence
after the fact; it does not prevent the case from exercising the wrong thing,
and a control aimed at an unrelated precondition would have passed while
appearing to calibrate that evidence. Declaring the expected identity and
asserting it before the run is the difference between a log line and a check.

The traversal-order join is the subtler of the two recipe defects and the writer
would have missed it indefinitely. Joining two streams "in the same traversal
order" reads as deterministic and is not, because nothing promises that order.
Emitting the digest on the same line removes the join entirely rather than fixing
it, which is the better shape and would not have been reached without the
finding.

One thing offered for the reviewer to weigh rather than defended. Hex-encoding
both filename-bearing fields makes the manifests byte-safe and makes them
unreadable to a human. The retained diff, which is the evidence a later reader
opens, will show hex where they would want paths. The writer chose safety, since
a forged record boundary would silently corrupt the one proof this effort's third
scope outcome rests on, but a reviewer could reasonably ask for a decoded
companion listing alongside the encoded manifests. The writer did not add one
because a second rendering is a second thing to keep honest.

The self-inflicted sanitization defect is reported in the change summary rather
than quietly fixed. The first version of that gate inlined the protected terms,
so the plan failed the scan it had just introduced and the terms reached the
transcript. It is worth recording because the rule that prevents it, a committed
document must never enumerate the terms it protects against, is not obvious until
it is broken, and it is now written into the plan next to the command.

The boundaries stated in round 1 still hold: the requirement's nine
clarifications and the design's seven decisions are not reopened, and shell
constructs inside the installer's own helpers remain below plan level. The
harness is the exception the reviewer has consistently asked for, and its
operations are now specified exactly, because there it is the plan's own
deliverable rather than the installer's implementation.

### Reviewer focus for plan rsync-cp-fallback round 3

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-08-11T14:26:40+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 3

The identity correction is complete in concept. Declaring expected installer
and archive paths, resolving them before invocation, and failing on a mismatch
turns identity from a log into an oracle. Pointing the wrong-archive control at
that assertion fixes the round 2 defect, and adding the symmetric
wrong-installer control is appropriate. The dependency split is also clear:
the five verification-only programs are named, justified and preflighted before
cases run.

The retained manifests do not need a decoded companion. Hex is less convenient
to read, but the diff still localizes a record, the field order is documented,
and the separately named canary assertions preserve the human-readable checks
that matter most. Byte safety is the right side of that trade-off. The
per-entry process cost is also acceptable for a one-off, two-tree acceptance
run; it does not affect the installer or its runtime contract.

The exact manifest operation nevertheless contains executable correctness
defects, so it cannot yet prove the design's third outcome.

The encoder command is wrong. In `tr`, `'[space]\n'` is not the whitespace
character class; it is a set containing brackets and the letters in `space`,
plus newline. It therefore deletes valid lowercase hex digits such as `a`, `c`
and `e`. The resulting representation is neither reversible nor collision-safe.
Use an actual class, for example `tr -d '[:space:]'`, and retain lowercase hex.
A small encoder control containing bytes whose hex uses those letters would
make this precise defect fail loudly.

The record fields also do not implement the settled manifest exactly:

- `stat %s` is emitted for every entry and `diff -u` compares every field, so
  directory and symlink sizes are compared despite the text saying they are
  meaningful only for regular files. Emit the size only for a regular file and
  `-` otherwise.
- `stat %Y` records whole seconds, while the settled field is mtime without a
  precision carve-out. Emit the full filesystem mtime precision under a fixed
  locale/time-zone representation.
- `readlink --` writes a record-terminating newline. Piping that output into the
  encoder adds a byte not present in the target, while capturing it in command
  substitution removes every trailing newline that is present. Use a
  no-added-newline form such as `readlink -n -- ...` and pipe it directly into
  the encoder.
- `sha256sum -- ...` followed by “keep the first field” is still not an exact
  extraction and GNU checksum output escapes unusual filenames. Select an exact
  form and extraction, such as zero-terminated output with the first 64 digest
  characters retained.
- Apply `LC_ALL=C` to the emitter, not only to its final sort, so `stat %F` and
  every textual field are deterministic. Alternatively emit a canonical
  one-character type rather than the localized `%F` description.

These are corrections to the chosen recipe, not new design choices or new
measurements.

The sanitization command now parses the mapping instead of embedding protected
terms, and the observed grep status 1 is the expected clean result. As a plan
gate, however, the snippet should fail closed. A failed or empty `sed`
extraction currently gives `grep` an empty pattern file, which also returns 1;
a grep error is merely stored in `scan`; and the fixed temporary name is
overwritten and removed without checking whether it already exists. Assert that
pattern extraction succeeded and produced at least one pattern, handle grep
statuses 0, 1 and greater than 1 explicitly, and use a collision-safe temporary
file or an equivalent no-file construction. This keeps the command executable
as a gate rather than relying on the following prose to interpret it.

Finally, synchronize the Step 0 completion criteria with the cases already
specified: they mention the exit-only and wrong-archive controls but omit the
new wrong-installer control.

No new measurement is required, and no new open question is needed.

### Question-by-question decisions for specification reviewer round 3

1. **Q01: accept option 1A.** Keep the effort-local verification harness out of
   the shipped archive.
2. **Q02: accept option 2A.** Use synthetic archives for incremental cases and
   the real archive for final acceptance.
3. **Q03: accept option 3A.** Separate transfer helpers preserve the two
   independently specified boundaries.
4. **Q04: accept option 4C.** Message ownership and final documentation
   ownership are now correctly integrated into the numbered steps.
5. **Q05: accept option 5A.** Per-step line deltas are the appropriate signal;
   no imported Bash ceiling should threaten standalone delivery.
6. **Q06: accept option 6A, after making the command fail closed.** Retained
   evidence remains preferable to an unverifiable summary.
7. **Q07: accept option 7A.** The identity assertions and symmetric negative
   controls now complete the selected self-calibrating case contract.

The answers themselves are settled. Round 4 is only about making their
load-bearing validation commands match what the plan says they prove.

### Requested changes for specification reviewer round 3

1. Correct the hex encoder to delete actual whitespace and add a minimal known
   byte-sequence assertion that would catch corruption of valid hex digits.
2. Make the manifest fields exact: `-` size for non-regular entries, full mtime
   precision, canonical locale-independent type, newline-exact symlink targets,
   and a fully specified checksum extraction.
3. Make the sanitization command fail closed on mapping-extraction failure,
   empty patterns and grep errors, without clobbering a fixed root temporary
   file.
4. Add the wrong-installer negative control to Step 0's completion criteria and
   keep the validation skeleton synchronized.

### Reviewer response to the requestor's remaining concern

Do not add a decoded companion manifest. It would duplicate the serialization
surface and create another artefact to reconcile. Correct hex is mechanically
decodable, while the retained diff, documented field order and readable canary
assertions are sufficient for audit. The one-off per-entry process cost is also
acceptable and needs no redesign.

### Reviewer decision for specification reviewer round 3

Disposition: changes-requested. The seven plan decisions, identity controls and
dependency boundary are ready, but the literal manifest encoder corrupts valid
hex and several emitted fields do not yet express the settled comparison. Make
the focused command corrections above and run plan review round 4; do not
consolidate yet.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-08-11T14:52:22+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for plan rsync-cp-fallback round 4

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
Review round: 4

### Requestor assessment for plan rsync-cp-fallback round 4

All six round 3 corrections are applied. Seven questions stay live and answered,
Step 0 stays unified, and no measurement, decoded companion or new question is
requested.

The encoder defect was real and the writer verified it before fixing it. In
`tr`, `'[space]\n'` is a set containing the brackets, the letters `s`, `p`, `a`,
`c`, `e`, and a newline. Three of those letters are valid lowercase hex digits,
so the encoder deleted them from its own output: `6a6c6e` would have become
`666`. That is worse than a broken encoding, it is a silently collision-forming
one, and a manifest built with it would have compared clean while proving
nothing.

The origin is worth recording because it is a class of mistake this document set
can repeat. `[space]` is the token this repository's markdown-lint convention
uses to mean "a literal space here"; the writer carried that token from prose
into a real command, where `tr` reads it as a character set. A lint workaround
leaked into executable text. The fix uses a delete-complement,
`tr -dc '0-9a-f'`, which cannot delete a hex digit by construction rather than
by getting the class right, and a new encoder control makes exactly that defect
fail loudly: a name encoding to `6a6c6e` must survive intact.

The other five corrections are applied as specified:

- Size is emitted only for regular files and `-` otherwise, so directory and
  symlink sizes are no longer compared by a diff that compares every field.
- Mtime is emitted at full precision with `stat -c '%.9Y'`, and the preflight
  asserts fractional support on each target rather than silently degrading to
  whole seconds.
- The entry type is now a canonical single character derived from shell tests
  with `-L` checked first, so it is locale-independent and never resolves a
  symlink, and the whole emitter runs under `LC_ALL=C` and `TZ=UTC` rather than
  applying the locale only to the final sort.
- The symlink target is piped from `readlink -n` straight into the encoder,
  which neither adds a newline the target lacks nor strips trailing newlines the
  target has, both of which the previous form did in opposite directions.
- The digest uses `sha256sum -z` with `head -c 64`, an exact byte extraction
  immune to the filename escaping GNU checksum tools apply.

The sanitization gate now fails closed. It asserts that pattern extraction
produced something before scanning, since an empty pattern set makes grep return
1 and look clean; it handles grep statuses 0, 1 and above 1 as three distinct
outcomes with the error case refusing retention; and it uses a pipe into
`grep -f -` rather than a fixed temporary name, so there is no file to collide
with, no cleanup to forget, and no new command in the tool set.

Step 0's completion criteria now list all four negative controls, the exit-only
substitute, the wrong-archive and wrong-installer identity controls, and the new
encoder control, and require each retained line to name the assertion that
failed rather than only that it failed.

What the reviewer should check. First, whether `stat -c '%.9Y'` is available on
both targets: the plan preflights it and fails loudly, which is the honest
handling, but if RHEL's coreutils 8.32 does not support it the preflight will
fail and the recipe needs a different precision source, so this is the one
correction that could still turn out to be unimplementable. Second, whether
deriving the entry type from shell tests is genuinely equivalent to `stat %F`
for the shapes the acceptance exercises, in particular whether a socket or a
device node in a toolchain tree would be classified as expected, since those
branches will rarely if ever be exercised in practice.

### Change summary for plan rsync-cp-fallback round 4

Changes since round 3, mapped to the six requested corrections.

1. The encoder is corrected from `tr -d '[space]\n'` to
   `printf '%s' "$value" | od -An -v -tx1 | tr -dc '0-9a-f'`. The recipe records
   what the old form actually did, deleting the valid hex digits `a`, `c` and
   `e`, and why the replacement is safe by construction rather than by naming
   the right class. A new encoder control is added to Step 0 and to the
   validation expectations: a name encoding to `6a6c6e` must survive intact,
   where the defect would have collapsed it to `666`.
2. Size is emitted only for regular files, from `stat -c '%s'`, and `-` for
   every other entry type.
3. Mtime is emitted with `stat -c '%.9Y'` at full filesystem precision, and the
   `stat` row of the verification-only tool table now says the preflight asserts
   fractional-second support and fails loudly without it. The emitter runs under
   `LC_ALL=C` and `TZ=UTC` exported at its top, so every textual field is
   deterministic, not only the final sort.
4. The entry type is emitted as one canonical character from shell tests, with
   `-L` checked first so a symlink is never resolved, replacing the localized
   `stat %F` description.
5. The symlink target is piped from `readlink -n -- ...` directly into the
   encoder, and the recipe states the two opposite failures the previous form
   had: a newline added by `readlink` without `-n`, and trailing newlines
   stripped by command substitution.
6. The digest is `sha256sum -z -- ... | head -c 64`, an exact 64-character
   extraction, replacing "keep the first field".

Sanitization gate, rewritten to fail closed:

- pattern extraction is asserted non-empty before scanning, since an empty
  pattern file makes grep return 1 and appear clean;
- grep statuses 0, 1 and greater than 1 are handled as three outcomes, with the
  error case refusing retention rather than being stored in a variable;
- the fixed temporary file is gone: patterns are piped into `grep -f -`, so
  there is nothing to collide with or clean up, and no command is added to the
  declared tool set.

Step 0 synchronization:

- completion criteria now list four negative controls, exit-only, wrong-archive,
  wrong-installer and encoder, and require each retained line to name the failed
  assertion;
- the cases section gains the encoder control beside the wrong-installer control
  added last round;
- the validation skeleton's Step 0 expectations gain the encoder control.

No step, question or answer changed. The corrections are confined to the
executable recipe, the sanitization gate and the Step 0 control list.

### Writer response for plan rsync-cp-fallback round 4

Writer response: All six requested corrections are accepted and applied. No disagreement to
record.

The encoder defect is the one worth dwelling on, because its cause is specific
to how these documents are written rather than to shell knowledge. `[space]` is
this repository's markdown-lint token for "a literal space belongs here". The
writer used it inside a real command, where `tr` reads it as a set of
characters, three of which are hex digits. A convention meant to keep prose
lint-clean silently changed the meaning of executable text, and the result would
not have failed: it would have produced a shorter, plausible, collision-forming
manifest and compared two of them successfully.

Two consequences the writer has taken beyond the literal fix. The replacement is
a delete-complement, `tr -dc '0-9a-f'`, chosen so the class cannot be got wrong
again: it keeps hex and can delete nothing else, where `tr -d '[:space:]'` would
have been correct but would still have been one typo away from the same failure.
And the encoder control exists specifically so this defect is loud, since the
general negative controls would not have caught it: an encoder that silently
drops digits still returns success, still writes a manifest and still diffs
clean against another manifest built the same wrong way.

That last point is the honest reason this correction matters more than its size
suggests. The three earlier controls guard the harness against passing when it
should fail. None of them guards the manifest against being wrong in the same
way twice, because both sides of the comparison are produced by the same code.
The encoder control is the first check in this plan that guards a shared-mode
failure, and the writer would not have thought to add one without the finding.

One item is flagged as possibly unimplementable rather than presented as done.
`stat -c '%.9Y'` is specified for full-precision mtime, and the plan preflights
it and fails loudly if unsupported. The writer has not verified it on RHEL 9.8's
coreutils 8.32. If it is unavailable there, the preflight will fail on a real
target and the recipe will need a different precision source, which would be a
round 5 item rather than an implementation surprise. Saying so now is preferable
to discovering it during acceptance.

The boundaries stated in round 1 still hold: the requirement's nine
clarifications and the design's seven decisions are not reopened, and installer
implementation detail stays below plan level. The harness remains the deliberate
exception, since there the plan is specifying its own deliverable.

### Reviewer focus for plan rsync-cp-fallback round 4

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-08-11T15:27:43+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 4

This review assesses the document currently on disk, including the RHEL
manifest-form measurement and probe added after the round 4 request was
rendered. The request is therefore stale as a change summary, and convergence
is unavailable on this round as the requestor notes.

The six round 3 command corrections are otherwise well taken. The
delete-complement encoder and its `6a6c6e` control directly guard the shared-mode
failure that the previous comparison would have missed. Non-regular sizes no
longer enter the diff, type is canonical and non-following, the emitter fixes
locale and zone, checksum extraction is bounded to the digest, and the recipe
uses `readlink -n` without command substitution. The RHEL output confirms these
forms and the five verification-only commands on coreutils 8.32 and xfs. The
per-entry cost remains acceptable, and no decoded companion is needed.

The fail-closed sanitization structure is also substantially correct and its
observed grep status 1 is a clean result. One small hole remains: the command
does not inspect the exit status of the `sed` command substitution. A total
failure normally produces an empty value and is caught, but a failure after
partial output would leave a non-empty pattern set and continue. Express the
assignment as a checked operation before the non-empty assertion, then keep the
existing three-way grep handling.

The new mtime residual is not settled by the retained probe. That probe proves
that `stat -c '%.9Y'` and the target filesystem can represent fractional mtime;
it does not pass a fractional source timestamp through either copy engine. The
plan now states that `rsync -a` transfers whole seconds only, but primary rsync
documentation distinguishes transfer from its default quick check. Rsync 3.1.0
added synchronization of nanosecond modification times, while the default
`--modify-window=0` compares integer seconds when deciding whether an existing
file needs transfer. The supported RHEL rsync is 3.2.5. Those facts make fresh
copy behavior and populated-destination quick-check behavior separate cases,
not one inferred rule. See the official
[rsync NEWS](https://download.samba.org/pub/rsync/NEWS.html) and
[rsync manual](https://download.samba.org/pub/rsync/rsync.1).

Measure that distinction on the supported RHEL target with a source whose mtime
has a known non-zero fractional component:

1. Run the exact fresh mirror forms, `rsync -av --delete src/ dst/` and the
   fallback empty-then-`cp -a src/. dst/`, and record source and destination
   `stat -c '%.9Y'` values.
2. Run the exact fresh root-file forms, rsync into the prefix and
   `cp -a --remove-destination` to the explicit destination, and record the
   same values.
3. For the mirror, add a populated destination file with the same size and
   integer second as the source but a different fractional component. Record
   whether rsync skips it and what mtime remains, separately from the fallback
   result.
4. Retain the actual extracted-staging scan for non-zero fractional mtimes as
   archive evidence, but do not use it as a substitute for the engine cases.

The outcome controls the correction. If both engines preserve the source's
fractional mtime for the acceptance-relevant fresh copy, retain the
full-precision manifest and remove the false whole-second-transfer residual.
If they diverge, the plan may not silently change the field to whole seconds:
the consolidated design defines mtime as compared metadata with no precision
carve-out. Such a result must amend or reopen that upstream decision before the
plan can proceed. If only the populated rsync quick-check case diverges, state
that separately and reconcile it with the design's redeployment/equivalence
scope rather than describing it as transfer truncation.

The new `probe.manifest-forms.sh` is useful evidence but is not yet safe to
reuse as a Step 0 gate. Only C1 changes `blocking_ok`. C2 can print `MISSING`,
and C3 can print `FAIL` or `skipped`, while the script still exits 0 with “C1
usable”. Wire every claimed C2 and C3 assertion into the final status. In
particular, assert checksum length/content, awkward-name creation/enumeration,
sort and grep results. The symlink check should use a target ending in a newline
and exercise the recipe's direct `readlink -n | encoder` pipeline; the current
plain target passed through command substitution cannot detect trailing-newline
stripping. Then Step 0 can genuinely reuse the probe instead of interpreting
its prose output.

The M3 correction from one prefix to two is accepted. Both measured prefixes
have real `tools` directories, so it strengthens the existing cost assessment
without moving any plan decision. The sensitive-rule correction likewise does
not change the reviewed plan.

### Question-by-question decisions for specification reviewer round 4

1. **Q01: accept option 1A.** Keep the effort-local verification harness out of
   the shipped archive.
2. **Q02: accept option 2A.** Use synthetic archives incrementally and the real
   archive for final acceptance.
3. **Q03: accept option 3A.** Separate helpers preserve the independent mirror
   and root-file boundaries.
4. **Q04: accept option 4C.** The numbered steps correctly own their messages
   and final documentation work.
5. **Q05: accept option 5A.** Per-step line deltas remain the right signal
   without threatening standalone delivery.
6. **Q06: accept option 6A, with the checked `sed` assignment.** Commit retained
   evidence only after the rule-file-driven gate succeeds.
7. **Q07: accept option 7A.** Identity and encoder controls now cover the
   selected oracle contract; make the reused probe's verdict equally strict.

No new plan question is needed yet. A measured full-precision engine divergence
would be an upstream design question, because a plan cannot create a new mtime
normalization after the design has consolidated.

### Requested changes for specification reviewer round 4

1. Publish round 5 from the actual current document, including the new probe,
   retained RHEL output, mtime residual, and corrected two-prefix M3 context.
2. Measure fractional-mtime behavior through both exact engines on RHEL for
   fresh mirror and root-file destinations, plus the populated same-second /
   different-fraction mirror case, and retain the output.
3. Remove the unmeasured statement that rsync transfers only whole seconds.
   Keep full-precision comparison if the engines agree; if they do not, reopen
   the consolidated mtime decision instead of normalizing it inside the plan.
4. Make every C2 and C3 assertion in `probe.manifest-forms.sh` affect its exit
   verdict, and test a trailing-newline symlink target through the exact direct
   pipeline.
5. Check the `sed` extraction status before accepting a non-empty sanitization
   pattern set.

### Reviewer response to the requestor's round 4 additions

Folding the post-request changes into this answer is preferable to reviewing an
obsolete snapshot, but they still require a fresh round 5 request for protocol
and audit accuracy. The RHEL `stat` measurement answers the originally flagged
availability question. It also exposed the more important distinction that now
needs measurement: what rsync compares when deciding to skip an existing file
is not necessarily what it can preserve during a transfer.

The corrected M3 scope is two inspected prefixes, not one. Neither is a
symlink, so Q03's accepted asymmetry remains cost-free on all inspected
deployments. No decision changes.

### Reviewer decision for specification reviewer round 4

Disposition: changes-requested. The round 3 serializer fixes are sound, but the
review request no longer describes the document, the new mtime branch makes an
unsupported rsync claim and proposes a plan-level normalization outside its
authority, and the reusable probe can report success after C2/C3 failures.
Publish a corrected round 5 request after the targeted mtime measurement; do
not consolidate on round 4.

<!-- review-entry-id: answer-round-4 -->

## Round 5 by requestor

- Recorded: 2026-08-11T17:13:37+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for plan rsync-cp-fallback round 5

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
Review round: 5

### Requestor assessment for plan rsync-cp-fallback round 5

All five round 4 requested changes are applied, and the measurement round 4
required has been taken on the supported target. Seven questions stay live and
answered. No design amendment is needed, for the reason the measurement gives.

The mtime claim was wrong and is withdrawn, not softened. Round 4 review said
"rsync -a transfers whole seconds only" was unmeasured and conflated transfer
with the default quick check. Both halves of that are confirmed by measurement,
retained as `measurements.mtime-engines.rhel.txt`, taken on RHEL 9.8 with rsync
3.2.5 and a source mtime of `1767319445.123456789`:

- **Case 1, fresh mirror.** `rsync -av --delete src/ dst/` reproduces
  `.123456789`. The fallback's empty-then-`cp -a src/. dst/` reproduces
  `.123456789`. Identical to the nanosecond.
- **Case 2, fresh root-file deploy.** `rsync -av file prefix/` and
  `cp -a --remove-destination src prefix/name` both reproduce `.123456789`.
- **Case 3, populated destination.** With the same size and the same integer
  second but a different fraction, rsync skipped: the destination kept
  `.987654321`. The fallback, which empties first, produced `.123456789`.

So the manifest keeps full precision, the design's mtime decision stands
untouched, and no upstream amendment is required. The writer's residual was not
merely unproven, it was backwards: rsync preserves the fraction on transfer, and
the integer-second comparison lives in the skip decision.

Case 3 is stated separately and scoped, as round 4 directed. It is a quick-check
decision on a populated destination, not transfer truncation. It cannot reach
the equivalence comparison, which installs into two fresh prefixes where nothing
pre-exists, and Step 5 now says fresh as a condition rather than as a
convenience. It does bound a claim made elsewhere, and the plan says so: "the two
engines produce the same tree" holds for the fresh case that the equivalence run
measures, while on a real redeployment the engines are not interchangeable for
entries that survive, since rsync may skip what the fallback always rewrites.
That is documented, unchanged rsync behaviour on the path the design leaves
alone, so it is recorded as a scope note rather than escalated as a defect.

The probe is now a gate rather than prose. Every C2 and C3 assertion feeds the
exit status, which round 4 correctly refused to accept on the earlier version:
it could print MISSING or FAIL and still exit 0 with "C1 usable". The corrected
version was run on both machines and the difference is visible in both
directions. On the writer's Windows box it now exits non-zero because the
symlink fixture cannot be created, where the old version exited 0. On the RHEL
target every assertion passes, including the two that were previously
unverifiable: the symlink check now uses a target ending in a newline through
the recipe's own `readlink -n | encoder` pipeline and returns `7467740a`, so a
trailing newline survives, and the encoder control returns `6a6c6e` on the real
machine. That capture supersedes the earlier one and says so in its header.

The sanitization gate now checks the `sed` exit status before the non-empty
assertion, closing the partial-output hole, with the three-way grep handling
unchanged. It was run as written: clean.

What the reviewer should check. First, whether case 3 deserves more than a scope
note. The writer's reading is that a quick-check skip is standard rsync
behaviour on an unchanged path, so recording it is proportionate; a reviewer
could argue that "the two engines produce the same tree" appears in the
requirement without the fresh-case qualifier the plan has now added, and that
the qualifier belongs upstream rather than in the plan. Second, whether Step 5's
acceptance should also exercise a redeployment comparison between engines, which
this measurement shows would fail by design and which the plan therefore does
not ask for.

### Change summary for plan rsync-cp-fallback round 5

Changes since round 4, mapped to the five requested changes.

1. Fractional mtime measured through both exact engines, on RHEL 9.8 with rsync
   3.2.5, retained as `measurements.mtime-engines.rhel.txt` with its probe
   `probe.mtime-engines.sh`. It implements the four cases round 4 specified:
   fresh mirror through both forms, fresh root-file deploy through both forms,
   populated destination with matching size and integer second but a differing
   fraction, and the one-liner for scanning a real extracted staging tree as
   separate archive evidence.
2. The whole-second claim is deleted from the recipe and replaced by the
   measured result: both engines reproduce `1767319445.123456789` on a fresh
   copy, so the manifest keeps full precision and the design's mtime decision is
   untouched.
3. No design amendment is opened, because the engines do not diverge on the case
   the equivalence comparison covers. The divergence that exists, rsync's quick
   check skipping an already-present destination, is stated separately in the
   recipe and reconciled with scope: it cannot affect a comparison between two
   fresh prefixes, and it bounds the "same tree" claim to that fresh case.
   Step 5's equivalence bullet now says fresh as a condition and explains why,
   citing the measurement.
4. `probe.manifest-forms.sh` rewritten so every C2 and C3 assertion feeds the
   exit status, through a shared `chk` helper and a failure counter. The symlink
   check now builds a target ending in a newline without command substitution
   and runs the recipe's direct `readlink -n | encoder` pipeline, which the
   previous plain target could not have exercised. Assertions added for digest
   length and value, awkward-name creation and enumeration, sort result and grep
   status. Re-run on both machines: it exits non-zero on Windows where the
   symlink fixture fails, and passes every assertion on RHEL. The retained
   capture is replaced and its header says it supersedes the earlier one.
5. The sanitization gate now tests the `sed` exit status before the non-empty
   assertion, so a partial extraction cannot pass a truncated pattern set to
   grep. The three-way grep handling is unchanged. Run as written: clean.

Also updated: the Step 0 file list cites both probes and says the forms probe is
run as a gate rather than read as prose, and the mtime probe's results are named
so Step 5 does not re-derive them.

No step, question or answer changed.

### Writer response for plan rsync-cp-fallback round 5

Writer response: All five requested changes are accepted and applied. No disagreement to record.

The mtime finding is the fourth time in this effort that a claim about tool
behaviour was corrected, and it is the one the writer should have been most
suspicious of, because it was invented to explain a risk rather than observed.
The writer noticed a real asymmetry, that `cp -a` handles nanoseconds, and
reached for a mechanism to complete the story. "rsync transfers whole seconds"
sounded plausible, matched a half-remembered fact about rsync's comparison
granularity, and was written into a recipe as a premise. The measurement shows
it inverted: rsync 3.2.5 preserves the fraction on transfer, and the
integer-second comparison lives in the skip decision, which is a different
operation on a different case.

Round 4 review is owed the specific credit for not accepting either the claim or
its removal. Deleting an unmeasured residual would have been easy and would have
left the real behaviour undiscovered; requiring the measurement is what turned
a wrong sentence into a documented property, including case 3, which nobody had
looked for and which genuinely bounds a claim the requirement makes.

One thing the writer has recorded rather than resolved, and would rather the
reviewer decided. The requirement says the two engines produce the same tree,
without a fresh-case qualifier. The measurement shows that is exact for two
fresh prefixes and not exact for a redeployment over a populated one, where
rsync may skip an entry the fallback rewrites. The plan now carries that
qualifier, because that is where the equivalence run is defined. Whether the
requirement's own wording should carry it too is an upstream question the writer
has not answered unilaterally: it is a settled document, the divergence is
pre-existing rsync behaviour rather than anything this change introduces, and
the plan can honestly scope its own claim. If the reviewer judges otherwise, it
is a requirement amendment rather than a plan edit.

The probe correction deserves one note. The writer wrote a gate whose exit
status ignored two thirds of its own assertions, then used its output as
evidence in a review request. It printed a clean verdict on a run that had
nothing to say about C2 or C3. That is the same shape as the harness-oracle
problem Q07 exists to prevent, committed in the tool built to prevent it, which
is why the corrected version was run on both machines rather than only the one
where it passes.

The boundaries stated in round 1 still hold: the requirement's nine
clarifications and the design's seven decisions are not reopened, and installer
implementation detail stays below plan level.

### Reviewer focus for plan rsync-cp-fallback round 5

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-5 -->

## Round 5 by reviewer

- Recorded: 2026-08-11T17:24:11+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 5

The mtime measurement settles the engine behavior cleanly. On a fresh
destination, both exact mirror forms and both exact root-file forms preserve
`1767319445.123456789` to the nanosecond. On the populated mirror case, rsync's
quick check skips a same-size destination with the same integer second and
leaves `.987654321`, while the fallback empties and recreates it at
`.123456789`. Transfer precision and skip comparison are now correctly
separated. The full-precision manifest is therefore right for the fresh
comparison, and no precision normalization belongs in the plan.

The verification mechanics requested in round 4 are also complete.
`probe.manifest-forms.sh` now feeds every C1, C2 and C3 assertion into its exit
status; the retained RHEL run passes the encoder, exact digest, trailing-newline
symlink target, NUL enumeration, sorting and grep controls. Its non-zero Windows
result where the symlink fixture cannot be created is further evidence that the
gate can fail. The sanitization command checks `sed`, rejects an empty pattern
set, distinguishes all grep statuses and has been run clean. These parts need no
further plan change.

The conclusion that no upstream amendment is needed does not follow from the
measurement, however. The requirement's confirmed rule says, without a
destination-state qualifier, that “the two engines must produce the same tree”
over bytes, mode, mtime and the other manifest fields. Its acceptance section
repeats that unqualified promise. The consolidated design likewise defines the
manifest without a fresh-only boundary and calls equivalence a property of the
change. The plan now limits the proof to two fresh prefixes because the measured
populated case disproves the broader wording. That is a real narrowing of a
settled observable promise, not merely a clearer description of an already
stated procedure.

The fact that the divergence comes from unchanged, standard rsync behavior does
not remove the inconsistency. It explains why the rsync path must remain as it
is; it does not make a populated rsync result equal to a fallback result. The
appropriate resolution is to accept the measured boundary explicitly upstream:

- Fresh-prefix parity is exact under the recorded manifest, including
  nanosecond mtime, and is what the one-off equivalence comparison proves.
- Redeployment parity is behavioral rather than tree-identical: the fallback
  removes stale visible and hidden entries and produces a valid relocated tree,
  while the unchanged rsync path retains its normal quick-check behavior.
- The measured populated mirror case is the concrete limit: rsync may keep an
  existing entry's fractional mtime when size and integer seconds match, while
  the fallback necessarily rewrites it after emptying the destination.

Amend the requirement's confirmed rule and acceptance bullet, and the design's
manifest/proved-once wording, with that dated measurement-backed boundary. The
plan's fresh Step 5 condition then implements its inputs rather than changing
them. Also narrow the plan's own broad goal statements such as “Nothing yet
proves the two engines produce the same tree” to “Nothing yet proves fresh
installs equivalent under the manifest.”

Two smaller consistency edits belong in the same round. Add
`measurements.mtime-engines.rhel.txt`, `probe.mtime-engines.sh`, and the updated
manifest-forms probe/output to `measurements.index.md`; the index currently does
not route readers to the new evidence. And replace Step 5's phrase “both
engines, both targets” with the actual matrix: fallback on Debian, and rsync plus
forced fallback on RHEL. Debian intentionally has no rsync engine to run.

The printed archive-staging one-liner need not be run now. It was relevant only
to the withdrawn theory that source fractions would force a precision carve-out;
the engine measurement instead shows fresh-copy parity at full precision for a
fractional source.

No additional measurement and no new plan question are required.

### Question-by-question decisions for specification reviewer round 5

1. **Q01: accept option 1A.** The effort-local verification harness stays out
   of the shipped archive.
2. **Q02: accept option 2A.** Synthetic archives serve incremental checks and
   the real archive serves final acceptance.
3. **Q03: accept option 3A.** Separate helpers preserve the two independent
   transfer boundaries.
4. **Q04: accept option 4C.** Message and documentation ownership are correctly
   integrated into the steps.
5. **Q05: accept option 5A.** Per-step line deltas remain sufficient without an
   imported ceiling.
6. **Q06: accept option 6A.** The retained-evidence gate is now executable and
   fail-closed.
7. **Q07: accept option 7A.** The identity, watchdog, post-state and encoder
   controls now provide the selected calibrated oracle contract.

The seven answers are ready. The remaining work aligns the upstream parity
promise with evidence discovered during plan review.

### Requested changes for specification reviewer round 5

1. Add a dated, measurement-backed fresh-prefix qualifier to the requirement's
   same-tree confirmed rule and acceptance criterion, while retaining the
   separately stated fallback redeployment guarantees.
2. Apply the same boundary to the consolidated design's equivalence model and
   “proved once” rationale, recording the populated quick-check divergence as
   the reason rather than treating it as plan-only scope.
3. Keep Step 5's fresh-prefix condition and narrow the plan's other unqualified
   same-tree statements to match the amended inputs.
4. Add the two new probes and retained outputs to `measurements.index.md` with
   host, date, purpose and supersession provenance.
5. Replace “both engines, both targets” with the executable target matrix:
   fallback on Debian; rsync and forced fallback on RHEL.
6. Publish round 6 from the aligned requirement, design, plan and validation
   plan. No new measurement is needed.

### Reviewer response to the requestor's remaining concern

Case 3 deserves an upstream scope amendment, not an additional redeployment
equivalence test. Such a test would fail for the measured reason and would ask
implementation to satisfy a promise the unchanged rsync path does not make.
The right contract is fresh-tree manifest parity plus separately defined
redeployment behavior.

This does not reopen the selected copy forms or any of Q01 through Q07. It
corrects the breadth of the existing parity statement using evidence that did
not exist when the requirement and design consolidated.

### Reviewer decision for specification reviewer round 5

Disposition: changes-requested. The plan and its validation machinery are
technically ready, but the fresh-only equivalence condition narrows unqualified
requirement and design promises. Amend those upstream documents, align the
remaining plan wording and evidence index, then run plan review round 6; do not
consolidate on round 5.

<!-- review-entry-id: answer-round-5 -->

## Round 6 by requestor

- Recorded: 2026-08-11T17:33:23+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for plan rsync-cp-fallback round 6

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
Review round: 6

### Requestor assessment for plan rsync-cp-fallback round 6

All six round 5 requested changes are applied, across four documents rather
than one. Seven questions stay live and answered. No measurement is requested.

The upstream amendment is the substance of this round, and it settles a question
the writer explicitly declined to decide alone in round 5. Round 5 review ruled
that case 3 deserves a scope amendment rather than an extra test, and that the
right contract is fresh-tree manifest parity plus separately defined
redeployment behaviour. Both consolidated documents now say so:

- The **requirement's** confirmed rule qualifies the same-tree promise with
  "when each installs into a fresh prefix", carries a dated amendment note
  explaining that the unqualified form was written before the evidence existed,
  and keeps the redeployment guarantee stated behaviourally and per engine: the
  fallback removes what the new tree no longer carries. Its acceptance criterion
  gains the same qualifier, with fresh named as a condition rather than a
  convenience.
- The **design's** equivalence model gains the same boundary with the measured
  reason attached, the rsync quick check leaving an already-present destination
  alone where the fallback empties first, and the "proved once" rationale now
  explains that proving it on fresh prefixes is a measured choice: a
  redeployment comparison would fail for that reason, and failing it would ask
  the implementation to satisfy a promise the unchanged rsync path never makes.

Neither amendment reopens a decision. The copy forms, the boundaries, the
override and Q01 through Q07 are untouched. What changed is the breadth of one
claim, corrected with evidence that did not exist when those documents
consolidated.

The target matrix replaces the phrase round 5 rejected. "Both engines on both
targets" was not executable, because the Debian agent has no rsync and none can
be constructed there, which is the Q19 defect itself. The plan now names three
combinations, D-fb, R-rs and R-fb, says how each is selected, and states which
kind of case runs on which: engine comparison is R-rs against R-fb into fresh
prefixes, and foreign-distribution proof is D-fb. The shared checklist, the Step
5 title, its goal and its behaviour paragraph all reference the matrix instead
of the loose phrase.

The evidence index now carries both new outputs with host, date and purpose,
including the supersession note on the manifest-forms capture, and its
introduction counts eight raw files rather than six and names the two rerunnable
probes.

What the reviewer should check. First, whether the requirement amendment reads
as an amendment rather than as a rewrite: it is a consolidated document, and the
writer added a dated note plus a qualifier rather than editing the original
sentence away, on the principle that a settled document should show its
corrections rather than absorb them. Second, whether the target matrix belongs
in the plan alone. It describes an executable fact about the two hosts that the
design's acceptance table also leans on, and the writer left the design's table
unchanged because the matrix is about how cases are run rather than about what
must hold.

### Change summary for plan rsync-cp-fallback round 6

Changes since round 5, mapped to the six requested changes. Four documents
changed this round, two of them consolidated.

1. Requirement `issue.v0.27.0.rsync-cp-fallback.md`: the same-tree confirmed
   rule now reads "when each installs into a fresh prefix", followed by a dated
   amendment bullet recording that the unqualified form predated the evidence,
   what the measurement shows on a fresh prefix, what rsync's quick check does
   on a populated one, and that this is unchanged rsync behaviour rather than a
   defect. A further bullet states the redeployment guarantee behaviourally and
   per engine, so it is not read as parity.
2. Requirement acceptance criterion: same qualifier, with fresh named as a
   condition of the criterion and a pointer to the confirmed-rule amendment.
3. Design `design.v0.27.0.rsync-cp-fallback.md`: the equivalence model opens on
   two trees "each installed into a fresh prefix" and carries a dated amendment
   with the measured numbers, attributing the divergence to the quick check
   rather than to the fallback. The "proved once" subsection now says proving it
   on fresh prefixes is a measured choice and explains why a redeployment
   comparison would fail by design.
4. Plan: scope anchor 3 and the Step 5 analysis are narrowed to the fresh case
   and point at the amended inputs; Step 5's equivalence bullet already carried
   the condition and keeps it.
5. Target matrix: a new section defines D-fb, R-rs and R-fb with host, engine
   and selection method, and states that no Debian rsync combination exists or
   can be constructed. The shared checklist step 4, the Step 5 goal, the Step 5
   title and its behaviour paragraph now reference the matrix rather than "both
   engines, both targets".
6. `measurements.index.md`: two rows added for the new outputs with host, date
   and purpose, the manifest-forms row carrying its supersession note; the
   introduction now counts eight raw files and names the two rerunnable probes.

Both amendments are additive and dated. Neither edits an original sentence away,
so a reader of either consolidated document sees what it said, what it says now,
and which measurement moved it.

No step, question or answer changed. Q01 through Q07 keep their answers.

### Writer response for plan rsync-cp-fallback round 6

Writer response: All six requested changes are accepted and applied. No disagreement to record.

Round 5 review decided the question the writer put down rather than answered,
and decided it the other way. The writer scoped the parity claim in the plan and
argued that the requirement's wording could stay, on the grounds that the
divergence is pre-existing rsync behaviour and the plan can honestly bound its
own claim. The review's answer is better and the reason is worth stating: the
requirement is where the promise is made, so a promise that is broader than the
evidence is wrong there, whatever the plan says downstream. Scoping in the plan
would have left a settled document making a claim its own effort had disproved.

The instruction to prefer an upstream amendment over an additional test is the
part the writer would not have reached alone. Adding a redeployment equivalence
case looked like the thorough answer. It would have failed for a measured
reason, and it would have asked implementation to satisfy something the
unchanged rsync path does not offer, which is a worse outcome than a narrower
promise.

One judgement call the writer made and would accept being corrected on. Both
consolidated documents are amended additively: the original wording is qualified
in place and a dated note explains what changed and why, rather than the earlier
sentence being rewritten out of existence. That makes them slightly longer and
visibly patched. The writer's view is that a settled document which has been
corrected by measurement should show that, since the correction is part of the
document's authority rather than an embarrassment to hide. A reviewer who wants
the clean form instead can have it.

The target matrix is a small thing that turned out to matter. Writing it down
made the Debian gap explicit: there is no D-rs combination, none can be
constructed, and that absence is the defect this whole effort exists to fix. The
phrase "both engines, both targets" had been carried through five rounds without
anyone noticing it described something impossible.

The boundaries stated in round 1 still hold: no decision is reopened, and
installer implementation detail stays below plan level.

### Reviewer focus for plan rsync-cp-fallback round 6

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-6 -->

## Round 6 by reviewer

- Recorded: 2026-08-11T17:38:48+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 6

The round 5 inconsistency is closed. The requirement now makes the promise at
the breadth the evidence supports: entry-for-entry parity when each engine
installs into a fresh prefix. It separately preserves the redeployment contract
as behavior required of each engine, rather than implying that populated
destinations must end with identical metadata. The acceptance criterion carries
the same boundary. The design uses that boundary in both the manifest model and
the one-off proof rationale, including the measured reason a populated
cross-engine comparison would be the wrong gate.

The additive, dated amendments are appropriate. They do not leave the old
unqualified rule standing beside a conflicting correction: the operative rule
is qualified in place, and the dated prose records why its scope changed. That
is a useful audit trail for a consolidated document whose evidence improved
after consolidation. A clean rewrite would be shorter but would discard the
provenance of a material correction.

The execution matrix is also correctly located in the plan. D-fb proves the
fallback on Debian; R-rs preserves the supported RHEL rsync path; R-fb enables
the same-host engine comparison. There is no meaningful D-rs cell because the
absence of rsync on Debian is the defect under test. The design should continue
to state the required outcomes, while the plan states which available host and
engine combination executes each case. Duplicating the matrix upstream would
mix validation logistics into the design without adding a guarantee.

The evidence index accounts for eight retained raw outputs and separately names
the two rerunnable probes. The new rows give the host, date, purpose and
supersession provenance needed to trace the manifest-form and mtime conclusions.
No additional measurement is needed.

No implementation question is missing. Q01 through Q07 remain internally
consistent with the settled nine requirement clarifications, seven design
decisions, six implementation steps and validation recipe. The plan can proceed
from their existing answers.

### Question-by-question decisions for specification reviewer round 6

1. **Q01: accept option 1A.** Keep the harness effort-local beside the evidence
   it produces and outside the packaged tree.
2. **Q02: accept option 2A.** Use synthetic archives for incremental shape
   checks and a real archive for final acceptance.
3. **Q03: accept option 3A.** Separate transfer-site helpers preserve the
   design's independent mirror and root-file boundaries.
4. **Q04: accept option 4C.** Fold operation-specific messages into their code
   steps and write the audited host-tool reference once from the completed
   implementation.
5. **Q05: accept option 5A.** Record per-step line deltas without importing a
   Python-only numeric ceiling or prescribing a split that would break
   standalone delivery.
6. **Q06: accept option 6A.** Commit the retained verification evidence behind
   the executable, fail-closed sanitization gate.
7. **Q07: accept option 7A.** Keep the self-calibrating case contract, identity
   assertions, state sentinels, negative controls and encoder control.

These answers are complete. None needs another option or another review round.

### Wording edits covered by this convergence recommendation

One directional word should be corrected during consolidation: in Step 5's
behavior paragraph, change "the executable target matrix below" to "the
executable target matrix above". The matrix is defined earlier in the plan.
This is editorial and does not change a step, decision, case or acceptance
condition.

The validation plan's statement that the populated-prefix observation "does
not reopen the design" remains accurate when read as a statement about the
seven design decisions: the design document was amended, but no design choice
was reopened.

### Convergence rationale

All substantive round 5 requests are present and mutually aligned across the
requirement, design, plan, validation plan and evidence index. The parity claim
now matches the measured fresh-prefix case; populated redeployment has a
separate behavioral guarantee; the executable target matrix replaces an
impossible four-cell formulation; and the evidence is routed and reproducible.
The only remaining correction is a one-word internal reference. Another
automated review round would not resolve an open technical choice or validate
new evidence.

### Reviewer response to the requestor's judgement calls

Keep the amendments additive and dated. Because the operative sentences are
already qualified in place, the notes preserve correction history without
leaving two competing contracts.

Keep the target matrix in the plan alone. It is an execution mapping, not an
additional requirement or design decision, and the upstream documents already
provide the outcomes against which its three cells are judged.

### Reviewer decision for specification reviewer round 6

Disposition: convergence-recommended. Apply the single "below" to "above"
wording correction as consolidation polish, then consolidate the plan. Do not
run round 7.

<!-- review-entry-id: answer-round-6 -->

## Round 6 by human

- Recorded: 2026-08-11T18:58:58+02:00
- Exchange: specification/plan/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/plan.v0.27.0.rsync-cp-fallback.md
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-6 -->
