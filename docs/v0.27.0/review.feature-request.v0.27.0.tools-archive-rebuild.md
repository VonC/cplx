# Specification review transcript for v0.27.0

- Exchange: specification/feature-request/v0.27.0/tools-archive-rebuild
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-16T17:54:25+02:00
- Exchange: specification/feature-request/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for feature-request tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
Review round: 1

### Requestor assessment for feature-request tools-archive-rebuild (round 1)

The requirement implements item 7 of the approved umbrella child. Its scope is
the final payload refresh, Python release rebuild, archive cleanup, cross-platform
acceptance, immutable publication and consuming-application adoption. Items 1 to 6
are completed inputs, not new implementation work for this requirement.

Five questions clarify release-time regression evidence, substantive Debian
coverage/testmon acceptance, evidence validity across changed inputs, whether
the established Jenkins candidate route is required before publication, and
recovery after failed adoption. Each has distinct options, pros and cons, a
recommendation and a proposed answer. They are feature acceptance questions;
the answer lines are explicitly not recorded human decisions.

No further independent scope question is currently identified. Please assess
whether questions are missing, whether these options and proposed answers are
sufficient, and whether any question merely reopens a settled requirement.
Q04 intentionally proposes stronger pre-publication acceptance than the minimum
draft sequence, without changing D1 or removing the post-publication pin run.

The author asked whether Python 3.13.15 with SQLite and Debian tests with coverage
belong here. The document keeps D5's conditional release-time selection, repeats
item 6 SQLite acceptance on final bytes, and makes Debian coverage/testmon
required. Application-repository cleanup remains a coordinated adoption input.

The umbrella summary predates several authoritative clarifications. The
requirement carries forward item 4's recognized OneAgent scope exclusion,
strict loader identity, measured OpenSSL conclusion and D10 policy; item 2's
exact residual register and reviewed inventory scope; and item 6's database
round trip, actual loaded provider, identity envelope and existing Jenkins
candidate delivery route. Check these against the linked completed requirements
rather than treating the older summary's shorthand as overriding them.

No reviewer wording suggestions have been received or applied in round 1.

### Change summary for feature-request tools-archive-rebuild (round 1)

Initial review: created the feature request from the human-approved child draft
on tools-archive-rebuild in the chosen current working tree and versioned docs
layout. Added explicit AR, PA and RA acceptance records and carried forward the
completed requirements' stricter runtime and SQLite clarifications.

Added five open questions through oqm. Made it explicit that a newer unqualified
local archive cannot inherit the accepted candidate's release qualification;
this follows the existing accepted-artifact requirement rather than posing a
new policy question. The canonical umbrella and completed item documents are
unchanged. No implementation, builds, external publication or commits were made.

### Writer response for feature-request tools-archive-rebuild (round 1)

Writer response:

This is the initial writer submission. There is no prior reviewer feedback or
disagreement. The human's "Fantastic. Go ahead" approved proceeding from the
displayed child draft into requirement writing; it did not answer the five new
questions or authorize consolidation at a future convergence gate.

Please review feature scope and acceptance completeness, especially the line
between already settled item 1 to 6 policy and new final-release acceptance.
Do not request design or implementation decisions in this feature request.

### Reviewer focus for feature-request tools-archive-rebuild (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `.reviews/a.review-active.specification.feature-request.v0.27.0.tools-archive-rebuild.md`
- `.reviews/a.review-requested.feature-request.v0.27.0.tools-archive-rebuild.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-16T17:58:06+02:00
- Exchange: specification/feature-request/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for feature-request tools-archive-rebuild round 1

The requirement is a faithful, well-bounded statement of item 7. It keeps items
1-6 as completed inputs, carries their stricter clarifications forward instead
of the umbrella's older shorthand, and separates archive-content acceptance
(AR), platform acceptance (PA) and release acceptance (RA).

Claims the reviewer checked against the sources:

- D5's baseline, the conditional 3.13.15 selection and the 3.13.10 exclusion
  match the umbrella's decision row, and the document correctly refuses to let
  item 6's earlier 3.13.15 build stand in for the release-time re-check.
- D1's "next application release version", the hosted no-overwrite repository
  and the publisher's newest-local-archive selection match the umbrella.
- Item 2's 2026-08-29 scope correction really does move archive-content
  assertions to item 7, and the AR rows match its residual and ownership-register
  language.
- Item 4's OneAgent scope exclusion, strict loader identity, measured OpenSSL
  conclusion and conditional D10 policy are carried over, including "zero spare
  version nodes" and packaging failure when neither generation satisfies demand.
- Item 6's database round trip, same-process provider observation and the
  Jenkins delivery route are stated as inherited contracts, which matches the
  requirement as it now stands after its own amendment.

The five questions are real release-time decisions rather than reopened
implementation choices, and their options are materially distinct. The reviewer
agrees with the recommended answer in all five. One acceptance element is
missing, and one prose passage will need reconciling once Q04 is confirmed.

#### Missing: closure source authority at publication for feature-request tools-archive-rebuild (round 1)

The requirement says that if the final permitted Python version changes, the
implementation must "align its declared version subdirectory and renew its
matching identity envelope". That understates what renewal costs and what
publication checks.

`closure_publish.sh` refuses at `closure_publish_step1` when "the authoritative
configuration could not be resolved from cplx at $commit": publication resolves
the declaration from the commit the envelope names and compares digests. The
envelope therefore needs a real commit containing the new declaration bytes, and
that commit must be resolvable in the checkout used at publication.

Item 6 had to solve exactly this, and its Step 3 procedure is the precedent: a
declaration-only source snapshot, the paired declaration/envelope bundle commit,
an authorized tree-preserving merge so the snapshot becomes an ancestor, and a
fresh-clone check proving the anchor resolves without a temporary branch. Two
consequences belong in this requirement:

- if the release rebuild changes the declared version subdirectory, renewal
  repeats that whole procedure, not just an edited envelope line;
- even when the declaration does not change, publication must be run from a
  checkout where the existing anchor resolves. If item 6's retention merge and
  fresh-clone proof have not completed, that is an inherited prerequisite of
  this item's publication, not a detail of item 6's history.

Neither point appears in the closure/publication section or in RA2, whose
conditions stop at closure checks and the absence of an active waiver.

#### Q04's answer will contradict a prose passage for feature-request tools-archive-rebuild (round 1)

"Platform acceptance" currently says a plain `debian:12` container can supply
Debian validation and that the real Jenkins pipeline supplies the final
integration run once it can fetch the archive. Q04 option A, which the reviewer
agrees with, requires the existing Jenkins agent to pass the candidate chain
before publication. If A is confirmed, that passage must be rewritten at
consolidation so the pre-publication requirement and the post-publication pin
run are both stated; otherwise the document will read as permitting publication
on container evidence alone.

### Question verdicts for feature-request tools-archive-rebuild round 1

#### Q01 verdict for feature-request tools-archive-rebuild (round 1)

Agree with option A. It keeps D5's conditional selection assessable without
claiming an upstream release is defect-free, and it refuses to let an
inconclusive review become a positive qualification.

Suggested addition to A: record the checked sources and the date with the
selected version in the release evidence, so the re-check is auditable later.

#### Q02 verdict for feature-request tools-archive-rebuild (round 1)

Agree with option A. Plugin availability proves nothing about the suites this
release exists to restore, and the option correctly defers the threshold to the
application's own gate rather than inventing one.

Suggested clarification: say explicitly that the run happens with the final
archive's interpreter, since a passing run on some other toolchain would not
qualify this artifact.

#### Q03 verdict for feature-request tools-archive-rebuild (round 1)

Agree with option A. The runtime boundary includes the application's wheels, so
an archive digest alone cannot carry old ABI or coverage evidence forward.

Suggested addition: name who records the affected-or-unaffected assessment, so a
retained result always carries its stated reason.

#### Q04 verdict for feature-request tools-archive-rebuild (round 1)

Agree with option A, and note the prose reconciliation in the assessment. The
route is already proven by item 6, and an immutable coordinate is the wrong
place to discover a Jenkins-specific failure.

Suggested addition to A's con: the pre-publication agent run consumes the
established validation delivery route, so that route must still exist and be
usable at release time.

#### Q05 verdict for feature-request tools-archive-rebuild (round 1)

Agree with option A. It gives a defined recovery without disguising a failed
release or weakening the no-overwrite rule, and it correctly states that
restoring the prior pin is not completion of item 7.

#### Missing Q06: renewing and resolving the closure source anchor for feature-request tools-archive-rebuild (round 1)

Add a question, or state the rule directly in the closure/publication section
and RA2. Facts: publication resolves the declaration from the commit the
envelope names and refuses when that fails; item 6 established the snapshot,
paired bundle, authorized merge and fresh-clone procedure.

- **Option A:** require, as a release condition, that the envelope's source
  commit is an ancestor of the published implementation history and resolves in
  the publishing checkout; if the final Python version changes the declaration,
  repeat item 6's Step 3 procedure in full and record the new source identity
  with the archive evidence.
  - pro: keeps publication's own refusal from being discovered at release time.
  - con: adds an explicit authorized Git operation to the release sequence when
    the version changes.
- **Option B:** treat envelope renewal as an ordinary edit and rely on
  packaging to surface any problem.
  - pro: no extra release step is described.
  - con: packaging does not perform the publication resolution, so the failure
    appears only when the immutable coordinate is being spent.

The reviewer would choose A, and would add to RA2: "the archive's envelope
resolves its named source commit in the publishing checkout, and any renewed
declaration records its new source identity."

### Requested changes for feature-request tools-archive-rebuild round 1

Requested changes:

- Add the closure source-authority acceptance element, covering publication's
  resolution of the envelope's named commit, the full renewal procedure when the
  declared version changes, and the inherited item 6 merge and clone proof.
- Apply the Q01 to Q04 wording additions from the verdicts.
- Note, for consolidation, that confirming Q04 option A requires rewriting the
  plain-container passage in platform acceptance.

### Writer instructions for feature-request tools-archive-rebuild round 1

1. Add the missing closure-source-authority element: either a sixth question
   with the options above, or a direct statement in the closure and publication
   section plus an RA2 clause. State that publication resolves the declaration
   from the commit the envelope names, that a changed declared version repeats
   item 6's Step 3 snapshot, bundle, authorized merge and fresh-clone procedure,
   and that an unresolvable anchor blocks publication.
2. Record item 6's outstanding retention merge and fresh-clone proof, if they
   have not completed, as an inherited prerequisite of this item's publication.
3. Apply the small additions in the Q01 to Q04 verdicts: the dated sources for
   the regression decision, the final archive's interpreter for the Debian test
   run, the recorded affected-or-unaffected assessment, and the availability of
   the validation delivery route at release time.
4. At consolidation, if Q04 option A is confirmed, rewrite the platform-acceptance
   passage so pre-publication Jenkins qualification and the post-publication pin
   run are both stated.
5. Do not consolidate or settle any answer in this round; publish the next one.

### Final reviewer decision for feature-request tools-archive-rebuild round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-16T18:01:21+02:00
- Exchange: specification/feature-request/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for feature-request tools-archive-rebuild (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
Review round: 2

### Requestor assessment for feature-request tools-archive-rebuild (round 2)

Round 1 identified a missing inherited source-authority release condition.
That gap is now covered directly in the closure/publication section and RA2,
without adding a question about weakening an already settled contract.

The five existing questions remain sufficient in the writer's assessment;
their choices are unchanged. All Q01 to Q04 wording suggestions have been
applied. No answer is settled or consolidated. Q04 explicitly records the
prose reconciliation required if its stronger Jenkins prerequisite is approved.

The source identity and the final cplx release revision are now explicitly
separate. Both must resolve in the publishing checkout and match the carried
declaration, with renewal governed by item 6's established Step 3 contract.
The requirement records that the current source retention and fresh-clone
proof are already completed, while final publishing-checkout proof remains
item 7 acceptance.

Please check the substantive addition and these wording refinements for
convergence. No further missing scope or acceptance question is identified.

### Change summary for feature-request tools-archive-rebuild (round 2)

Since round 1, added three closure-authority paragraphs and extended RA2:

- Named source and release commits must resolve and match the archive's
  declaration digest; their identities are recorded separately.
- Changed declaration bytes repeat item 6's source snapshot, paired bundle,
  authorized retention merge, hooks and fresh single-branch clone proof.
- Existing retention is completed, as recorded in item 6's Step 3 validation;
  its source is also an ancestor of current HEAD. Final publishing-checkout
  resolution remains required.

Updated Q01 to retain dated sources with the version decision; Q02 to name
the final archive's interpreter; Q03 to assign the recorded impact assessment
to the maintainer operating the release; and Q04 to state delivery-route
availability and its conditional consolidation prose reconciliation.

Question placement used oqm. The umbrella, completed items and implementation
remain unchanged. No consolidation, commits or publication occurred.

### Writer response for feature-request tools-archive-rebuild (round 2)

Writer response:

Accepted the missing authority condition as a direct inherited rule rather
than a sixth question. There is no policy disagreement.

Two factual precisions from checking the requested evidence are reflected:

- In src/setups/env/bin/closure_publish.sh, closure_config_authority_check
  resolves the envelope's source commit; closure_publish_step1 resolves the
  separately supplied release commit. The requirement preserves both checks
  without describing them as the same identity or operation.
- Item 6's plan.v0.27.0.python-sqlite-support.validation.md, Step 3, already
  records retention merge 5f8d4d67ca549bb74e3bcbb798124d628c3d0619 and a successful
  fresh single-branch clone on 2026-09-16. The named source commit
  13c80d572ba7bda91728806ad7dc11c53629a506 is in current HEAD ancestry (git
  merge-base --is-ancestor returned 0). We therefore record the prerequisite
  as completed rather than inventing outstanding item 6 work. Its continued
  resolvability at publication and renewal when declaration bytes change
  remain explicit acceptance conditions.

Applied all four question wording suggestions. Q04 now states that accepting
A requires replacing the plain-container sufficiency passage at consolidation,
while retaining the post-publication release-pin run. The current main prose
continues to describe the approved draft until the human confirms the proposal.

The five answers remain proposed; no consolidation was performed.

### Reviewer focus for feature-request tools-archive-rebuild (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-16T18:03:44+02:00
- Exchange: specification/feature-request/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for feature-request tools-archive-rebuild round 2

Round 1's finding is resolved, and the writer corrected two factual points in
the reviewer's own description. The reviewer verified both corrections and
accepts them.

#### The correction the reviewer accepts for feature-request tools-archive-rebuild (round 2)

Round 1 said publication resolves the declaration from the commit the envelope
names. That conflated two different checks. Reading
`src/setups/env/bin/closure_publish.sh` again:

- `closure_config_authority_check(repo, config, envelope)` resolves the commit
  the envelope names and compares that blob with the carried declaration;
- `closure_publish_step1(archive, repo, commit, work)` resolves the declaration
  at a separately supplied release commit and compares its digest with the
  digest the archive's envelope carries, refusing with "the archive's envelope
  names ... and cplx at ... resolves to ...".

Two identities, two checks. The requirement now states exactly that, and names
both, rather than merging them into one operation. The substantive point from
round 1 survives in the correct form: both commits must resolve in the
publishing checkout, and an unresolvable commit or a digest mismatch blocks
publication.

#### The second correction, also verified for feature-request tools-archive-rebuild (round 2)

Round 1 treated item 6's retention merge and fresh-clone proof as possibly
outstanding. They are not. The reviewer confirmed with Git that
`13c80d572ba7bda91728806ad7dc11c53629a506` is an ancestor of the current head,
and that `5f8d4d67ca549bb74e3bcbb798124d628c3d0619` is the merge retaining it,
with the source snapshot as its second parent. Recording the prerequisite as
completed, with the final publishing-checkout resolution still required, is the
accurate statement.

#### What the addition now covers for feature-request tools-archive-rebuild (round 2)

- The named source commit must be a real ancestor of delivered history and
  resolvable in the publishing checkout, with the exact blob matching the
  carried digest.
- The source-envelope commit and the final cplx release revision are recorded
  separately, which matches the two checks above.
- A changed declaration repeats item 6's Step 3 contract in full: the
  declaration-only snapshot, the committed-blob digest, the paired delivery, the
  authorized tree-preserving retention merge with configured hooks, and a fresh
  single-branch clone proving resolution without a temporary ref. It states that
  an ordinary envelope-line edit does not renew authority, and preserves that
  plan's authorization boundary for auxiliary Git operations.
- RA2 carries the same conditions as release acceptance.

#### Wording additions from round 1 for feature-request tools-archive-rebuild (round 2)

All four are present: the dated regression review, the final archive's
interpreter in the Debian test condition, the recorded impact assessment
assigned to the maintainer operating the release, and the delivery route's
availability. Q04 now also records that confirming it obliges consolidation to
reconcile the platform-acceptance prose, which was round 1's remaining
consolidation note.

No material question is missing. What remains is the human's decision on the
five answers, so the reviewer recommends convergence.

### Question verdicts for feature-request tools-archive-rebuild round 2

#### Q01 verdict for feature-request tools-archive-rebuild (round 2)

Agree with option A, now recording the dated sources with the version decision.

#### Q02 verdict for feature-request tools-archive-rebuild (round 2)

Agree with option A, now naming the final archive's interpreter, so a passing
run on another toolchain cannot qualify this artifact.

#### Q03 verdict for feature-request tools-archive-rebuild (round 2)

Agree with option A, now assigning the recorded impact assessment to the
maintainer operating the release.

#### Q04 verdict for feature-request tools-archive-rebuild (round 2)

Agree with option A. It states the delivery route's availability as a condition
and records the consolidation prose reconciliation its confirmation requires.

#### Q05 verdict for feature-request tools-archive-rebuild (round 2)

Agree with option A, unchanged since round 1.

#### Closure source authority for feature-request tools-archive-rebuild (round 2)

No question is needed. The requirement states the rule directly, names both
checks with their distinct identities, cites item 6's completed retention and
clone proof with the real commits, and carries the condition into RA2. The
reviewer verified the commits and the two functions rather than accepting the
description alone.

### Convergence evidence for feature-request tools-archive-rebuild round 2

Covered wording:

None outstanding. Round 1's four wording additions and the conditional Q04
reconciliation note are already applied in the current document.

Convergence rationale:

Every in-scope release decision is expressed as a question with distinct
options and a pending recommendation the reviewer agrees with: the release-time
Python regression evidence (Q01), substantive Debian coverage and testmon
acceptance (Q02), evidence validity across changed inputs (Q03), Jenkins
qualification before immutable publication (Q04) and recovery after a failed
adoption (Q05).

Round 1's single substantive finding, the missing closure source-authority
condition, is now stated directly in the closure and publication section and in
RA2, with the two publication checks named separately and item 6's completed
retention cited by commit. The reviewer verified those facts independently and
accepted the writer's two corrections to round 1's description.

What remains is the human's decision on the five answers and, if Q04 is
confirmed, the prose reconciliation the document already schedules for
consolidation. This recommendation is advisory and does not authorize
consolidation.

### Writer instructions for feature-request tools-archive-rebuild round 2

1. Present the five pending recommendations (Q01 to Q05, all option A) for
   human confirmation.
2. At consolidation, if Q04 is confirmed, apply the reconciliation the question
   now records: the platform-acceptance passage must state both the
   pre-publication Jenkins qualification and the post-publication pin run, so it
   no longer reads as permitting publication on plain-container evidence alone.
3. Keep the source-envelope commit and the final release revision recorded as
   separate identities in the release evidence, as the new rule requires.
4. Do not treat this recommendation as authorization to consolidate.

### Final reviewer decision for feature-request tools-archive-rebuild round 2

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human - human-confirmation

- Recorded: 2026-09-16T18:47:29+02:00
- Exchange: specification/feature-request/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
