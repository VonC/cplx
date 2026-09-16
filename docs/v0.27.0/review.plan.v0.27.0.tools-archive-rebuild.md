# Specification review transcript for v0.27.0

- Exchange: specification/plan/v0.27.0/tools-archive-rebuild
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-16T20:20:17+02:00
- Exchange: specification/plan/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for plan tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Review round: 1

### Requestor assessment for plan tools-archive-rebuild (round 1)

The plan assigns seven ordered implementation steps and a matching unimplemented validation skeleton. Requirement/design decisions remain settled. Q01-Q04 concern only implementation: stdlib JSON validator, focused cplx cross-repository fixtures, batching native acceptance in Step 6, and extracting the ABI shell method. Options include pros/cons and recommended A answers. I found no additional unresolved implementation question after the code/test-tree and physical-line pass. Please independently check omitted file changes, sequencing, actual publication byte binding, wheel inventory completeness, full coverage/testmon selection, and whether the named acceptance gates can be executed without assuming backend capability. The four-document IO clarification is a mandatory write-plans follow-up and preserves required checks.

### Change summary for plan tools-archive-rebuild (round 1)

Initial implementation plan and seven-step validation skeleton written from the consolidated design. Direct code inspection supplied file baselines and repository-specific validation commands. Added an expected-SHA256 guard to the planned closure publisher changes to connect release-record eligibility with the exact streamed identity. Existing large harnesses are reused; new cases live in focused files, except removal of resolved literal relocation ownership entries. Native acceptance is scheduled against the final candidate in Step 6; Step 4 completion is wiring/fixture readiness. Requirement/design receive the same short IO clarification as both plans.

### Writer response for plan tools-archive-rebuild (round 1)

Writer response:

Initial request; no prior plan-review feedback. No backend, build, qualification, publication or adoption is claimed complete. The seven-step validation skeleton has only not-started states and required placeholders. Existing application coverage threshold is 100%; native Debian Jenkins runs its own full pytest stage because ghog is a Windows wrapper. The cplx runner follows its Bash floor plus explicit cumulative fixtures. Please give changes-requested for substantive gaps, or consolidation-ready when these implementation questions and recommendations are sufficient.

### Reviewer focus for plan tools-archive-rebuild (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `.reviews/a.review-active.specification.plan.v0.27.0.tools-archive-rebuild.md`
- `.reviews/a.review-requested.plan.v0.27.0.tools-archive-rebuild.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-16T20:23:12+02:00
- Exchange: specification/plan/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan tools-archive-rebuild round 1

The plan is implementable and correctly ordered. Its seven steps match the
settled design, and the sequencing reflects the design's own lesson: Step 5's
rebuild cannot start until Step 1 proves the real backend transaction, and
Step 7 cannot publish until the record and the inherited closure gate pass.

Checked against the sources:

- the cited baselines are right, including the 9,136-line closure harness and
  the 1,114-line diagnostics file the plan refuses to grow;
- the validation skeleton it names already exists and reads
  `No, it is not implemented.`;
- the recorded source authority `13c80d57...` and its retention merge
  `5f8d4d67...` are the real commits, and Step 5 requires reachability from the
  actual publishing checkout;
- Step 4's removals (`--no-cov`, `-p no:pytest-testmon`, the rsync shim, the
  patch-wheels loop) match the application-side interims the requirement
  retires, and the plan keeps the 100% threshold rather than inventing one;
- the D10 wheel work keeps the archive and wheel consumer inventories separate,
  as the existing reader does.

Two implementation details are missing, and one wording defect runs through all
four questions.

#### Missing: which interpreter runs the new validator for plan tools-archive-rebuild (round 1)

Step 2 adds `tools_release_record.py` under `src/setups/env/bin/`, beside
`closure_publish.sh`, and says "an independently supplied authoring Python runs
this cplx validator, not an unverified candidate executable". It never states a
version floor.

That directory is deployed to the build account's `cplx/bin`, and publication
runs there, next to the gate it feeds. The build host's system interpreter is
Python 3.9.25, and the candidate interpreter is explicitly excluded. The
existing `sqlite_probe.py` already set the precedent by remaining 3.9
compatible, which is why its suite runs there.

So the plan should state the floor and the identity rule together: the validator
and its tests run on Python 3.9 or later, and never on the candidate being
qualified. Without that, Step 2 can be implemented against 3.13 syntax and fail
at the moment it is needed, at publication, on the host that has 3.9.

#### Missing: a test that the optional guard cannot become a bypass for plan tools-archive-rebuild (round 1)

Step 2 adds an expected-SHA-256 guard to `closure_publish.sh` and keeps it
optional "when this optional guard is not supplied", while requiring the
application release entry to always supply it from successful record validation.

The planned negatives cover a mismatched digest and archive replacement with a
spy adapter proving zero calls. They do not cover omission. As written, the
compatibility path is a bypass: a tools release invocation that simply omits the
guard reaches the adapter with only the inherited checks, which is the gap the
guard exists to close.

Add the case: the tools release entry refuses when the expected digest is
absent, with the spy adapter proving zero calls. That keeps backward
compatibility for other callers while making the release path's requirement
mechanically checked rather than documented.

#### Wording defect in all four questions for plan tools-archive-rebuild (round 1)

In Q01 to Q04 the "Recommended option" and the "Answer" repeat the same sentence
verbatim. The answer is supposed to give the reason the option must be accepted,
which is a different statement from the recommendation. As they stand, each
question's final section adds nothing a reader has not just read.

### Question verdicts for plan tools-archive-rebuild round 1

#### Q01 verdict for plan tools-archive-rebuild (round 1)

Agree with option A, a stdlib JSON CLI with unittest mutations.

Two additions: state the Python 3.9 floor and that the validator never runs on
the candidate interpreter, and rewrite the answer so it differs from the
recommendation, for example: "Option A should be accepted because duplicate
keys, contradictory identities and lifecycle states are directly testable in
the standard library, and publication must not depend on a package the build
account may lack."

#### Q02 verdict for plan tools-archive-rebuild (round 1)

Agree with option A: focused cplx harnesses with a required `--app-repo`. The
refusal to silently skip application contracts when the checkout is absent is
the right default.

Suggested answer text, distinct from the recommendation: "Option A should be
accepted because a single cumulative entry point keeps the two repositories'
contracts verified together at recorded revisions, and a missing checkout fails
rather than quietly reducing coverage."

#### Q03 verdict for plan tools-archive-rebuild (round 1)

Agree with option A: fixtures and wiring in Step 4, full native qualification
batched in Step 6 against the final archive.

Its con is real, so state the mitigation the plan already implies: Step 4's
fixtures exercise the transport and selection paths that would otherwise first
fail in Step 6.

#### Q04 verdict for plan tools-archive-rebuild (round 1)

Agree with option A: extract the ABI probe into a focused shell entry with a
status-propagating Groovy call.

Suggested answer text: "Option A should be accepted because the blocking
inventory, exclusion and inconclusive paths can then be executed directly in
fixtures, instead of only through a pipeline run."

#### No missing question for plan tools-archive-rebuild (round 1)

The two gaps in the assessment are implementation details of already settled
choices, not new decisions, so they belong in Step 2's text rather than in a
fifth question.

### Requested changes for plan tools-archive-rebuild round 1

Requested changes:

- State the release validator's Python floor (3.9 or later, the build account's
  system interpreter) and that it never runs on the candidate.
- Add the omitted-expected-digest refusal case, so the guard's optional
  compatibility path cannot become a release bypass.
- Give Q01 to Q04 answers that differ from their recommendations.

### Writer instructions for plan tools-archive-rebuild round 1

1. In Step 2, state the validator's interpreter contract: Python 3.9 or later,
   matching the build account's system interpreter and the existing probe's
   compatibility, and never the candidate interpreter being qualified. Add the
   same constraint to the Step 2 addendum's readiness line.
2. In Step 2's tests-first list, add the omitted-guard case: the tools release
   entry refuses when no expected digest is supplied, with a spy adapter proving
   zero adapter calls. Keep the guard optional for other existing callers.
3. Rewrite the "Answer" section of Q01 to Q04 so each states why the option must
   be accepted rather than repeating its recommendation verbatim; suggested
   wording is in the verdicts.
4. Keep everything else unchanged: step order, the Step 1 before Step 5
   dependency, the D10 measurement locality, the batching decision and the
   refusal to grow the inherited harnesses.
5. Do not consolidate in this round; publish the next one.

### Final reviewer decision for plan tools-archive-rebuild round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-16T20:25:11+02:00
- Exchange: specification/plan/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan tools-archive-rebuild (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Review round: 2

### Requestor assessment for plan tools-archive-rebuild (round 2)

Q01-Q04 remain implementation-only and sufficiently cover the remaining choices; no missing question was identified by either role. Applied every round 1 request: Python 3.9-or-later compatibility for validator/tests using an identified independent interpreter never the candidate; an omitted/empty expected-digest tools-entry negative proving zero adapter calls plus a separate legacy-caller compatibility positive; distinct acceptance reasons for all four answers. The Step 2 validation expectation is aligned. No step or settled design changed.

### Change summary for plan tools-archive-rebuild (round 2)

Step 2 now names Python 3.9 compatibility, including the build host's 3.9.25, interpreter identity capture, and readiness checks at the floor. Its publication fixtures now refuse an absent expected digest, empty validator result or omitted guard, before any adapter call. The seven-step validation skeleton carries the same Step 2 expectations and remains entirely not started. Q01-Q04 answer prose is rewritten through oqm with distinct reasons; Q03 explicitly names transport/selection fixtures as mitigation for batching native acceptance in Step 6.

### Writer response for plan tools-archive-rebuild (round 2)

Writer response:

Accepted all round 1 findings with no disagreement. The optional closure guard remains compatible for unrelated existing callers, while the application tools release entry has a tested mandatory binding. No additional runtime implementation, backend proof or acceptance is claimed. Please verify the concrete round 1 changes and whether the plan is now consolidation-ready.

### Reviewer focus for plan tools-archive-rebuild (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-16T20:26:37+02:00
- Exchange: specification/plan/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan tools-archive-rebuild round 2

All three round 1 points are resolved, and nothing else changed that needs
re-examination.

- **Validator interpreter.** Step 2 now requires the validator and its tests to
  support Python 3.9 or later, naming the build account's system Python 3.9.25,
  run with an explicitly identified, independently supplied interpreter and
  never the candidate being qualified. It also records that interpreter's path
  and version in the local capture and its sanitized identity in the release
  record, which is more than was asked and is the right amount: the evidence now
  says which interpreter produced the validation. The Step 2 readiness line
  repeats the floor, so the constraint is visible where the step is executed.
- **The guard cannot become a bypass.** Step 2's tests-first list now covers an
  absent expected digest at the tools release entry, including both shapes that
  matter: an empty validator result and an omitted guard in the gate
  invocation. Each must refuse with the spy adapter proving zero calls, and
  compatibility for other callers is kept as a separate positive test rather
  than as the absence of a negative one.
- **Question answers.** Q01 to Q04 now give a reason for acceptance that differs
  from the recommendation, and Q03 states the mitigation for its own con.

The rest of the plan is unchanged: the step order with Step 1's real backend
proof before Step 5's rebuild, the D10 measurement locality and wheel identity
binding, the batching of native acceptance into Step 6 against the final
archive, the refusal to grow the inherited 9,136-line and 1,114-line harnesses,
and the recorded source authority with its reachability check from the actual
publishing checkout.

No question is missing and no wording change remains outstanding, so the
reviewer recommends convergence.

### Question verdicts for plan tools-archive-rebuild round 2

#### Q01 verdict for plan tools-archive-rebuild (round 2)

Agree with option A, now carrying the interpreter floor and identity rule.

#### Q02 verdict for plan tools-archive-rebuild (round 2)

Agree with option A, with the required application checkout and no silent skip.

#### Q03 verdict for plan tools-archive-rebuild (round 2)

Agree with option A, now stating that Step 4's fixtures reduce the risk its con
describes.

#### Q04 verdict for plan tools-archive-rebuild (round 2)

Agree with option A, extracting the ABI probe into a testable shell entry.

### Convergence evidence for plan tools-archive-rebuild round 2

Covered wording:

None outstanding. Round 1's interpreter, guard-omission and answer-text changes
are all applied in the current plan.

Convergence rationale:

The plan assigns implementation and evidence work for all seven steps without
reopening the settled requirement or design, and its four implementation
choices carry pending recommendations the reviewer agrees with.

Round 1's two gaps are closed in Step 2: the validator's Python 3.9 floor with
an explicitly identified non-candidate interpreter recorded in the evidence, and
the absent-expected-digest refusal that keeps the optional guard from becoming a
release bypass. The repeated question answers now state why each option should
be accepted.

What remains is the human's decision on the four answers. This recommendation is
advisory: it does not authorize consolidation, and it does not authorize any of
the implementation work the plan describes.

### Writer instructions for plan tools-archive-rebuild round 2

No change is requested for this plan.

1. Present the four pending recommendations (Q01 to Q04, option A each) for
   human confirmation.
2. Keep visible at consolidation that Step 1 gates Step 5: the real backend and
   adapter capability must be demonstrated before any refresh or rebuild work is
   spent, and a mock does not establish it.
3. Keep the two application-repository obligations, candidate mode in the main
   chain and the publication adapter, tracked with their exact revisions in the
   cplx acceptance record, as the plan already requires.
4. Do not treat this recommendation as authorization to consolidate or to start
   implementation.

### Final reviewer decision for plan tools-archive-rebuild round 2

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human - human-confirmation

- Recorded: 2026-09-16T20:31:30+02:00
- Exchange: specification/plan/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
