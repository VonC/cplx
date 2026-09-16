# Specification review transcript for v0.27.0

- Exchange: specification/design-specification/v0.27.0/tools-archive-rebuild
- Reviewed document: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-16T19:02:56+02:00
- Exchange: specification/design-specification/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for design-specification tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
Review round: 1

### Requestor assessment for design-specification tools-archive-rebuild (round 1)

The settled requirement is fully consolidated and committed after round 2.
This design composes existing mechanisms without reopening its five answers.
Four proposed interface/ownership choices need review: a structured release
record, candidate mode in the existing main application chain, wheel inputs
to the existing D10 selector, and application ownership of the real uploader.
Each question has two viable architectural options, pros and cons, a mapped
BBQ analogy, and a proposed option A answer. No additional design question is
currently identified; please check completeness and inherited contracts.

No reviewer suggestions have yet been received for this design. Source reads
confirmed that the existing publisher still invokes Maven with a pathname
and does not supply closure_publish's private-stage/atomic-commit adapter.
The design explicitly makes backend capability a release prerequisite and
does not claim that hosted Nexus provides it. Q04 chooses ownership, not a
waiver of item 4's inherited transaction semantics. If this boundary is
insufficient for an implementable design, identify the precise missing
design choice rather than assuming the adapter already exists.

The item 6 archive-copy route was inspected in the application working tree:
its SQLite diagnostic uses a separate prefix. The proposed candidate mode
must therefore make the main application chain use that runtime, not just
rerun the diagnostic. The old item 4 snapshot override is not the selected
route. Full Debian coverage/testmon and a separate post-publication pin run
remain required.

The requirement's pre-publication obligations and later adoption obligations
are separated in the proposed record so publication does not depend on an
already completed post-publication run. D10 retains the two-generation
capability comparison and bounded second-reading convergence, and source
authority retains item 6's already completed retention proof and its renewal
contract when the declaration changes.

### Change summary for design-specification tools-archive-rebuild (round 1)

Initial design from the settled tools-archive-rebuild requirement. Added the
release state model, source/commit/archive identity separation, composed
evidence and invalidation, D10 wheel inputs, actual main-chain Jenkins
candidate qualification, transactional uploader integration and adoption
recovery. Added four design questions with proposed option A answers.

Read the existing cplx packaging, closure verification, D10 and publication
sources and application publisher/Jenkins inputs. No implementation source,
application working-tree file, deployment or remote publication was changed.

### Writer response for design-specification tools-archive-rebuild (round 1)

Writer response:

Please independently review the exact design and its four open questions
against the settled requirement and inherited item 2, 4 and 6 contracts.
There is no earlier design-round response to resolve. Proposed options remain
subject to human consolidation after this independent review converges.

### Reviewer focus for design-specification tools-archive-rebuild (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `.reviews/a.review-active.specification.design-specification.v0.27.0.tools-archive-rebuild.md`
- `.reviews/a.review-requested.design-specification.v0.27.0.tools-archive-rebuild.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-16T19:07:52+02:00
- Exchange: specification/design-specification/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification tools-archive-rebuild round 1

The design composes the completed mechanisms without reopening the settled
requirement. The reviewer checked its inherited claims:

- the consolidated requirement now carries RA1-RA8 and a decision table with all
  five answers confirmed, so the design's references are accurate;
- the confirmed technical facts match the sources: `pkg_tools.sh` stages
  privately and calls `pkg.sh tools --closure-gate --source-root`;
  `closure_publish.sh` refuses by default and streams through a transactional
  adapter; the application publisher invokes Maven with a pathname and supplies
  none of those four operations;
- the state model keeps publication eligibility ahead of the immutable
  coordinate, keeps adoption after it, and refuses to let successful recovery
  count as completion;
- the authority section keeps the source-envelope commit, the release revision
  and the archive digest as three separate identities, and requires the full
  item 6 Step 3 contract when the declaration changes.

The four questions are genuine architectural choices, and the reviewer agrees
with option A in each. One design decision is missing, and two points would
benefit from an explicit statement.

#### Missing: where the final wheel ELFs are measured for design-specification tools-archive-rebuild (round 1)

Q03 option A extends D10's measurement input with "identified wheel consumer
roots", read through the existing ELF reader. That reader runs where the
measurement runs. The final resolved wheels, however, come into existence on
the Debian agent when the application synchronizes its locked dependency set;
the archive ELFs live on the build host. The design never says how the same
wheel bytes become available to the reader, or how their identity is bound to
the set the agent actually resolved.

That is exactly the difference between the two options: option B contemplates
"consumption of a transported measurement", so option A implicitly requires the
wheel bytes themselves to be present where D10 runs. Implementation cannot
proceed without choosing one of:

- materialize the identical locked wheel set on the measuring host, binding it
  to the agent's lock digest and per-wheel digests already recorded in the
  release record's Consumers area, and measure both consumer sets there; or
- run the reader on the agent for wheel subjects and transport its output, which
  is option B's boundary and needs its trust statement.

Without that sentence, "extend the input with wheel roots" is not implementable,
and a plan could silently measure a differently resolved wheel set from the one
the release consumes, which is the failure Q03's own acceptance case
("archive unchanged but resolved wheels change") exists to prevent.

#### Worth stating explicitly for design-specification tools-archive-rebuild (round 1)

- **Order the adapter capability check early.** The design correctly makes the
  private-stage and atomic-commit capability a release-blocking prerequisite and
  refuses to relabel a Maven upload as a transaction. It does not say when to
  establish it. Item 6 learned this the expensive way: its facilities were
  checked in Step 1, before the costly work. Say that the repository and
  uploader capability is demonstrated before the refresh and rebuild are spent,
  so an unmet inherited contract surfaces early rather than at the gate.
- **Name the release record's home and lifecycle.** Q01 option A places the
  record outside the archive and indexed by its SHA-256, but not whether it is
  tracked evidence in this repository or a retained ignored artifact, nor who
  validates it at the gate. The plan can fix the path, but the design should fix
  the boundary, since the record is what the publication gate consults.

### Question verdicts for design-specification tools-archive-rebuild round 1

#### Q01 verdict for design-specification tools-archive-rebuild (round 1)

Agree with option A. Composing references keeps closure's domain intact while
making stale or inconclusive acceptance visible at the gate, and it correctly
keeps post-publication obligations out of the pre-publication check.

Suggested addition to A: state where the record lives (tracked evidence in this
repository or a retained ignored artifact) and which side validates it, since
the gate consults it.

#### Q02 verdict for design-specification tools-archive-rebuild (round 1)

Agree with option A. Reusing the main chain is what proves the candidate
interpreter runs the same provisioning, tests, packaging, walk and ABI gates
that adoption will use; a dedicated flow would owe a separate equivalence
argument, which is option B's own con.

The refusals around it are right: diagnostic-only success is not qualification,
uploads must be off, ambiguous inputs or digest mismatches refuse before
provisioning, and candidate mode is disabled for the release-pin run.

#### Q03 verdict for design-specification tools-archive-rebuild (round 1)

Agree with option A, but it is incomplete as written. Add the locality and
binding sentence described in the assessment: either the identical locked wheel
set is materialized where the reader runs and bound to the recorded lock and
wheel digests, or the reader runs on the agent and its output is transported,
which is option B's boundary.

#### Q04 verdict for design-specification tools-archive-rebuild (round 1)

Agree with option A. Repository coordinates, credentials and publishing policy
belong to the application that owns the Nexus entry point, while cplx keeps the
checked-byte guarantee and invokes the contract.

Suggested addition to A: require the capability demonstration before the refresh
and rebuild are spent, not only before the gate.

### Requested changes for design-specification tools-archive-rebuild round 1

Requested changes:

- State where the final wheel ELFs are measured and how their identity binds to
  the agent's resolved set, completing Q03 option A and the D10 section.
- Require the publication adapter and backend capability demonstration before
  the refresh and rebuild are spent.
- Name the release record's location and its validating side in Q01 option A.

### Writer instructions for design-specification tools-archive-rebuild round 1

1. Complete Q03 option A with the wheel measurement locality and identity
   binding: state whether the locked wheel set is materialized where the ELF
   reader runs, bound to the recorded lock and per-wheel digests, or measured on
   the agent and transported. Reflect the same statement in the D10 section, so
   the union of archive and wheel consumers is measurable as described.
2. Add to Q04 option A, and to the publication-adapter section, that the
   repository and uploader transaction capability is demonstrated before the
   refresh and rebuild are spent.
3. Add to Q01 option A where the release record lives and which side validates
   it at the gate.
4. Keep the rest unchanged: the state model, identity separation, candidate-mode
   refusals, D10 convergence rule and adoption recovery all match the settled
   requirement and the inherited item 2, 4 and 6 contracts.
5. Do not consolidate or settle any answer in this round; publish the next one.

### Final reviewer decision for design-specification tools-archive-rebuild round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-16T19:11:11+02:00
- Exchange: specification/design-specification/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for design-specification tools-archive-rebuild (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
Review round: 2

### Requestor assessment for design-specification tools-archive-rebuild (round 2)

All three round 1 recommendations are applied to the design and the relevant
question options. The four questions remain sufficient; option A is still
recommended for each, and no additional unresolved design question is known.
The reviewer should verify the completed boundaries without reopening the
settled requirement or inherited transaction and convergence contracts.

Q03 now chooses measurement on the RHEL build/measuring host using the exact
Debian-resolved wheel artifacts. Lock and per-wheel digests bind that set;
measured ELF paths/digests must match the installed wheel inventory observed
on the agent. Host-specific resolution and unbound measurement transport are
not allowed. Missing artifacts, subjects or matching identity are inconclusive.

Q01 now versions the structured record and human view as cplx effort evidence.
Raw captures stay in retained evidence locations with identity/digest binding.
A cplx-owned validator checks the record at the application publication entry
before the closure gate, and checks adoption completion later. The maintainer
owns updates and impact assessments; history preserves prior states.

Q04 now requires actual backend and adapter capability before spending the
sandbox refresh/rebuild work. A mock is insufficient. Candidate eligibility
and the transaction remain checked again for real publication.

No disagreement remains with round 1. Source authority renewal, closure,
full Debian coverage/testmon, candidate/main-chain selection, post-release
pin confirmation, D10 convergence and recovery remain unchanged.

### Change summary for design-specification tools-archive-rebuild (round 2)

Completed D10 measurement locality and wheel identity binding in the D10
section and Q03 option A. Added the explicit cost of obtaining and validating
the agent's exact wheel artifacts on the measuring host.

Named versioned cplx effort evidence as the release record's home, the release
maintainer as its lifecycle owner, and the cplx validator as its gate checker;
updated Q01 option A to match.

Moved real backend/adapter capability demonstration ahead of refresh/rebuild
in the state model, adapter section and Q04 option A. Final publication checks
still apply. Updated the question companion consistently. No implementation
source, application working-tree file or external publication was changed.

### Writer response for design-specification tools-archive-rebuild (round 2)

Writer response:

Accepted all three requested changes from design review round 1.

1. Q03 option A now explicitly materializes the exact Debian-resolved wheel
   bytes on the RHEL measuring host. The lock/per-wheel digests and installed
   ELF inventory bind the static reading to the agent's actual consumers.
2. The actual repository and adapter transaction capability must be proven
   before refresh/rebuild expense, with final checks retained at publication.
3. The structured release record and acceptance view are versioned cplx effort
   evidence, maintained through adoption/recovery. A cplx-owned validator
   checks referenced evidence and identities before the closure gate and
   checks adoption completion separately.

No disagreement and no consolidation in this round. Please check whether
these additions complete the four choices for human consolidation.

### Reviewer focus for design-specification tools-archive-rebuild (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-16T19:12:50+02:00
- Exchange: specification/design-specification/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification tools-archive-rebuild round 2

All three round 1 points are resolved, and the reviewer found no new gap.

- **Wheel measurement locality, the substantive finding.** The D10 section and
  Q03 option A now say both consumer sets are measured on the RHEL
  build/measuring host, that the Debian agent's exact wheel artifacts are
  materialized there by copying retained artifacts or retrieving them by their
  recorded identities, and that the set is bound to the agent's lock digest and
  per-wheel digests. Measured ELF paths and digests must match the installed
  wheel inventory observed on the agent. Resolving a replacement set for the
  measuring host is refused, an unbound transported measurement is refused, and
  missing artifacts, subjects or identity matches are inconclusive. That closes
  the hole exactly: the release can no longer be qualified against a differently
  resolved wheel set, and the design now states the cost of obtaining those
  artifacts rather than assuming they are present.
- **Record home and validator.** Q01 option A versions the structured record and
  its human-readable view as cplx evidence under this effort's docs directory,
  gives the release maintainer its lifecycle with prior states retained, and
  puts a cplx-owned validator at the application's publication entry, before the
  closure gate can invoke the adapter, with a second check for adoption
  completeness. Raw captures stay in retained evidence bound by identity and
  digest, which keeps the versioned record small and reviewable.
- **Capability before cost.** The state model, the adapter section and Q04
  option A now require the real backend and adapter capability to be
  demonstrated before the sandbox refresh and rebuild are spent, and state that
  a mock adapter does not establish it. Eligibility and the transaction are
  still checked again at real publication, so the early check adds a gate rather
  than replacing one.

The rest of the design is unchanged and still matches the settled requirement
and the inherited item 2, 4 and 6 contracts: identity separation, the item 6
Step 3 renewal contract, candidate-mode refusals with uploads off, the bounded
two-generation convergence rule with no third iteration, static and live
evidence kept separate, and recovery that never counts as completion.

One wording suggestion remains, and it is not a blocker.

### Question verdicts for design-specification tools-archive-rebuild round 2

#### Q01 verdict for design-specification tools-archive-rebuild (round 2)

Agree with option A as completed.

Wording-only suggestion: say that the versioned record follows the same
sanitization rule item 6's acceptance record used, since it will carry
environment, container and runtime identities. Account paths, workspace paths
and credentials stay in the ignored captures it references.

#### Q02 verdict for design-specification tools-archive-rebuild (round 2)

Agree with option A, unchanged since round 1.

#### Q03 verdict for design-specification tools-archive-rebuild (round 2)

Agree with option A as completed. The locality, the binding to the agent's lock
and per-wheel digests, the refusal of host-specific resolution and unbound
transport, and the inconclusive outcomes are all stated.

#### Q04 verdict for design-specification tools-archive-rebuild (round 2)

Agree with option A as completed. Demonstrating the real backend capability
before the refresh and rebuild is what keeps an unmet inherited contract from
surfacing only after the expensive work.

### Convergence evidence for design-specification tools-archive-rebuild round 2

Covered wording:

- Q01 option A and the release record section, append: "The versioned record
  follows the same sanitization rule as item 6's acceptance record: environment,
  container and runtime identities appear as evidence, while account paths,
  workspace paths and access details remain in the ignored captures it
  references."

Convergence rationale:

The four architectural choices are settled in the document with pending
recommendations the reviewer agrees with: the composed release record (Q01),
candidate qualification through the main application chain (Q02), wheel inputs
to the existing D10 policy (Q03) and ownership of the publication transaction
adapter (Q04).

Round 1's substantive finding, the unstated locality and identity binding of
the final wheel measurement, is now answered in both the D10 section and the
question. The two supporting points, the record's home and validator and the
early capability demonstration, are also in place.

What remains is one optional sanitization sentence and the human's decision on
the four answers. This recommendation is advisory and does not authorize
consolidation.

### Writer instructions for design-specification tools-archive-rebuild round 2

1. Optionally add the sanitization sentence to Q01 option A and the release
   record section.
2. Present the four pending recommendations (Q01 to Q04, option A each) for
   human confirmation.
3. Keep visible for planning that two obligations live in the application
   repository: candidate mode in the main chain and the publication adapter,
   with the capability demonstration scheduled before the rebuild.
4. Do not treat this recommendation as authorization to consolidate.

### Final reviewer decision for design-specification tools-archive-rebuild round 2

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human - human-confirmation

- Recorded: 2026-09-16T20:01:53+02:00
- Exchange: specification/design-specification/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
