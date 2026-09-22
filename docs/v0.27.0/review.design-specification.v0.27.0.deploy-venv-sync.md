# Specification review transcript for v0.27.0

- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-22T10:49:20+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for design-specification deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
Review round: 1

### Requestor assessment for design-specification deploy-venv-sync (round 1)

The new design covers the consolidated requirement and all acceptance criteria. Six design questions address offline transport, delivery shape, uv provenance, inventory ownership, serialization and command-result evidence. The proposed answers are recommendations, not human decisions. No requirement decision is reopened. No reviewer wording has yet been received or applied.

Please assess missing design questions and the feasibility of the loopback transport with locked consistency, the release manifest/retention boundary, and complete installed ELF scope. Q06 intentionally refuses to treat unchanged inventory or an exit hook as proof of commands whose statuses are masked. Its actual private adapter still needs feasibility evidence; do not export private mechanics or identifiers in the response or transcript.

### Change summary for design-specification deploy-venv-sync (round 1)

Created the design beside the consolidated requirement. Added confirmed code facts, lifecycle and identity rules, a proposed digest-bound offline bundle and local transport, pinned uv provenance, full inventory plus ELF verification, recovery boundaries, two-phase CI orchestration and acceptance mapping. Added six design review questions through the question-management workflow. No runtime source changes or execution qualification are claimed.

### Writer response for design-specification deploy-venv-sync (round 1)

Writer response:

Initial review request. The settled requirement remains authoritative. The design distinguishes target behavior, inspected facts and unproven qualification conditions. Please propose concrete design corrections while preserving offline forward deployment and rollback, exact tools provenance, unchanged shared-library integration, phase-specific evidence and public/private separation.

### Reviewer focus for design-specification deploy-venv-sync (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `.reviews/a.review-active.specification.design-specification.v0.27.0.deploy-venv-sync.md`
- `.reviews/a.review-requested.design-specification.v0.27.0.deploy-venv-sync.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-22T10:52:33+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification deploy-venv-sync round 1

The design covers the consolidated requirement faithfully. It separates target
behavior from inspected facts and unproven qualification, and maps every
acceptance criterion, including the split AC10a and AC10b. Its main choices
are sound:

- a digest-bound offline bundle with a manifest, checked before destructive
  mirroring;
- one computed venv path, with an explicit state table for existing venvs;
- a complete selection check composed with item 7's ELF helper, extended to
  wheel executables under `bin`;
- first-transition rollback through the predecessor's historical procedure;
- fail-closed CI evidence.

Four points need more than wording.

- **Contradiction with the requirement on group selection.** The two-phase CI
  section says phase 1's selection "includes the default groups" of the
  mandated sync. The consolidated requirement (CI section and AC10a) requires
  it to equal that selection, because an exact sync also removes distributions
  outside its selection. The design must use the requirement's condition.
- **Phase 2 input sources are unspecified.** The phase 2 adapter must rebuild
  the venv on a fresh agent, from phase 1's toolchain archive digest, lock and
  groups. Phase 1's bundle and workspace are not reachable there, and the
  adapter runs inside a shell step with no access to CI artifact transfer. The
  design must say where phase 2 obtains the toolchain archive and the wheels,
  and how it proves they are phase 1's. The likely answer is the configured
  private mirror and artifact service, verified by the archive digest and the
  lock's wheel hashes. It must also say whether phase 2 uses the release
  bundle's CI selection.
- **Q06 can be made concrete without exporting private mechanics.** The design
  correctly refuses to let an unchanged inventory or an exit hook stand in for
  masked command statuses. But two generic observation boundaries cover the
  masked forms the requirement names.
  - A shell-level error observation installed before the mandated commands
    records every command that returns a failure outside a conditional
    construct. That covers the dependency sync and the installation.
  - The test framework records its own session result, independently of how
    the calling shell treats the test command's exit status. That covers a
    test command whose status is explicitly discarded.

  Naming both lets the plan test each one, instead of leaving the whole
  boundary as unresolved feasibility.
- **Q01 and Q03 have simpler options than the ones recommended.** See the
  question verdicts. In both cases the recommendation should be to qualify the
  simpler option first and fall back only if it fails.

Everything else, including Q02, Q04 and Q05, holds.

### Question verdicts for design-specification deploy-venv-sync round 1

**Q01, offline source transport: prefer option B, qualified first.** Both
options need the same effective lock. With `--locked`, the lock's recorded
registry and each wheel URL must point at the delivered location, and the
project's source configuration must match it, so the validator and round-trip
checks are identical either way. What differs is only the serving side. A
filesystem-backed index or artifact location, addressed through `file:` URLs
into the retained bundle, needs no listening socket, fixed port or server
lifetime. A loopback server adds all three and gains nothing offline. I would
choose B. Keep A as the fallback if the qualified uv does not accept
filesystem locations under `--locked`. Rephrase B's con to say it needs the
same effective lock as A, not a different representation.

**Q02, bundle delivery: agree with option A.**

**Q03, uv executable provenance: prefer option B with a statically linked
artifact.** uv publishes fully statically linked Linux builds. Such an artifact
runs unmodified on both targets and is immune to the shipped runtime libraries
placed first on the library path, so no target-specific adaptation arises and
the release keeps a single provenance identity. I would choose B, recording
that choice in the manifest. Keep A as a fallback only if a static artifact
proves unsuitable in qualification.

**Q04, inventory ownership: agree with option A.**

**Q05, serialization interface: agree with option A.**

**Q06, CI command outcome evidence: agree with option A, and name the
boundaries.** Replace "the private adapter must prove its observation
boundary" with the two generic boundaries from the assessment:

- shell-level error observation installed before the mandated commands, for
  failures outside conditional constructs;
- a session result recorded by the test framework itself, for a test command
  whose status is discarded.

Keep the requirement that both be qualified on the actual agent, and that a
command form neither boundary observes blocks acceptance.

**Missing Q07: where does phase 2 obtain its inputs?** Options:

- (A) the configured private mirror and artifact service, verified against the
  phase 1 toolchain archive digest and the lock's wheel hashes;
- (B) the release bundle produced by phase 1, made reachable to the phase 2
  agent through a supported, publication-free transfer.

I would choose A. Phase 1 artifacts are not reachable from the adapter's
shell step, and B risks resembling an upload.

### Requested changes for design-specification deploy-venv-sync round 1

Requested changes:

- Align the group-selection sentence with the requirement ("equals", not "includes").
- Add Q07: where phase 2 obtains its toolchain archive and wheels, and how
  their identity is proven.
- Make Q06's observation boundary concrete: shell-level error observation, plus
  a session result recorded by the test framework.
- Recommend a filesystem transport for Q01 and a statically linked uv for Q03,
  each with the current recommendation as fallback.

### Writer instructions for design-specification deploy-venv-sync round 1

Revise the design, then publish a replacement request for another round.

- **Two-phase CI section:** replace "includes the default groups" with the
  requirement's condition. Phase 1's effective selection equals the selection
  the mandated sync applies, so that sync neither adds nor removes
  distributions.
- **Add Q07 (phase 2 input sources)** with the options in the question
  verdicts, and state the chosen answer in the two-phase CI section. Also state
  whether phase 2 uses the bundle's CI selection.
- **Q06 and the command-evidence paragraph:** name the two generic observation
  boundaries, keep the "qualified on the actual agent, otherwise blocking"
  condition, and keep private mechanics out of the public text.
- **Q01:** recommend option B (filesystem locations through the same
  effective lock) with A as the fallback, and rephrase B's con as described.
- **Q03:** recommend option B with a statically linked uv artifact, with A as
  the fallback, and record the linkage in the manifest's uv row.
- Keep all content generic.

### Final reviewer decision for design-specification deploy-venv-sync round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-22T10:56:08+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for design-specification deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
Review round: 2

### Requestor assessment for design-specification deploy-venv-sync (round 2)

The revised design covers the consolidated requirement and all acceptance criteria. Seven design questions address offline transport, delivery shape, uv provenance, inventory ownership, serialization, command-result evidence and fresh-agent input acquisition. All round 1 changes are applied; recommendations remain subject to human consolidation. No requirement decision is reopened.

Please assess whether any design choice remains missing. Filesystem transport and static uv are now qualified first, with explicit fallbacks. CI group selection is exact equality. The two observation boundaries require expected start/completion evidence and deliberate failures on the actual agent. Phase 2 uses configured existing services with digest verification and the same bundle CI selection. Do not export private mechanics or identifiers.

### Change summary for design-specification deploy-venv-sync (round 2)

Round 2 changes: corrected effective group selection to equality; selected filesystem transport first with loopback fallback; selected unmodified static uv first with qualified adaptation fallback; recorded linkage in the manifest; named shell-level dependency failure observation and test-framework session outcome observation; added start/completion evidence; specified fresh-agent input acquisition and profile/manifest digest comparisons; added Q07. Updated Q01, Q03 and Q06 through question management. No runtime implementation or execution qualification is claimed.

### Writer response for design-specification deploy-venv-sync (round 2)

Writer response:

Accepted every round 1 recommendation; no disagreement. Confirmed static uv artifact availability in the official platform policy and linked it in the design, while retaining actual linkage/runtime qualification. Filesystem URL support under locked consistency remains a qualification gate, not an assumed working implementation. Phase 2 acquires existing inputs without uploading the tested package, uses the bundle CI selection, and verifies phase 1 digests; deployment/recovery remain offline. Command observation is now two complementary boundaries, with unobserved forms blocking completion.

### Reviewer focus for design-specification deploy-venv-sync (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-22T10:58:02+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification deploy-venv-sync round 2

Round 2 applies every round 1 change correctly.

- Group selection now requires equality with the mandated sync's selection,
  including defaults, which matches the requirement.
- The filesystem transport through `file:` locations is qualified first, with
  the loopback server as an explicit fallback. Both share one identity-preserving
  effective-lock contract, and the offline switch is scoped correctly to each.
- A statically linked uv is qualified first, with its linkage recorded in the
  manifest, and adaptation is kept only as a fallback that must be demonstrated.
- Command evidence now names the two complementary boundaries (shell-level
  error observation, and the test framework's own session result). Both need
  start and completion records and deliberate-failure qualification on the
  actual agent, and any form neither boundary observes blocks completion.
- Q07 settles phase 2 inputs: existing private services, verified against
  phase 1's archive digest, the canonical wheel hashes and the CI selection
  profile, with no upload and no reliance on phase 1's workspace. It keeps
  offline deployment and recovery on delivered bundles.

No design question is missing, and nothing reopens the consolidated
requirement. One sentence needs sharper wording (see the covered wording).

### Question verdicts for design-specification deploy-venv-sync round 2

- **Q01 (B, filesystem first):** agree.
- **Q02 (A, companion bundle):** agree.
- **Q03 (B, static uv first):** agree.
- **Q04 (A, composed verifiers):** agree.
- **Q05 (A, consumer serialization):** agree.
- **Q06 (A, two observation boundaries):** agree. Optionally add the start and
  completion records to the answer text, since they are what stop an observer
  that never ran from implying success.
- **Q07 (A, existing services with digest checks):** agree.

No missing question.

### Convergence evidence for design-specification deploy-venv-sync round 2

Covered wording:

- **Phase 2 input sources (two-phase CI section):** "whose digest is carried
  with the phase 1 provenance inputs" leaves open how phase 1's digests reach
  the phase 2 adapter. Say instead: "Phase 1 records the toolchain archive
  digest, the canonical lock digest, the selection profile digest and the
  selected wheel manifest digest in its archived evidence. The consuming
  Jenkinsfile passes them to the phase 2 adapter as build-scoped, non-secret
  values; no credential travels this way."
- **Q06 answer:** optionally append "Each boundary also records its own start
  and completion, so an observer that never ran cannot imply success."

Convergence rationale:

Every design decision is settled by a recommended answer I would also choose,
the round 1 corrections are applied without residue, and the design stays
within the consolidated requirement. The remaining edits clarify one sentence
and optionally one answer, and change no decision. Convergence is advisory:
consolidation, and confirmation of the seven design answers, remain the human's
choice.

### Writer instructions for design-specification deploy-venv-sync round 2

No further review round is needed. Apply the covered wording during
consolidation, after the human confirms the design answers. Do not treat this
convergence recommendation as that confirmation.

### Final reviewer decision for design-specification deploy-venv-sync round 2

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human - human-confirmation

- Recorded: 2026-09-22T17:08:25+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Revise and review again
Outcome: another-round
Guidance: Human guidance:

Revise and review again, with guidance such as:

Add the release path: which build produces and publishes the application
archive and its reconstruction bundle (same digests as the qualified
validation build, or a publication run of the same revision), where the
bundle is published and retained for offline rollback, and how that path
relates to the disabled publishers of validation builds. Show where the
mandated pipeline sits in the target flow (CI validation only, not
deployment).

Privacy-preserving rendering of the additional human guidance: ensure the
mandated pipeline entry point picks up our environment venv and tools Python;
do not name the private integration in public documents. The human clarified
that this means its specific pipeline entry point, not a generic library.
Private identifiers are deliberately omitted from this public review input.

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 3 by requestor

- Recorded: 2026-09-22T17:10:27+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for design-specification deploy-venv-sync (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
Review round: 3

### Requestor assessment for design-specification deploy-venv-sync (round 3)

﻿Eight design questions cover the remaining choices. Existing options remain sufficient; Q08 makes exact-byte publication versus qualified rebuild explicit. Round 2 wording is applied. The release path identifies the producing phase, separate promotion run, repository/local retention, partial-publication boundary and rebuilt-byte qualification. The mandated pipeline sits only in CI. Actual command-shell environment selection covers activation and dependency/test executables. Assess missing boundaries; no runtime success is claimed.

### Change summary for design-specification deploy-venv-sync (round 3)

﻿Round 3 adds the CI-to-publication-to-deployment flow, phase 1 candidate pair assembly/archiving, separate digest-preserving promotion, immutable companion repository coordinates, manifest-last logical publication, repository/local rollback retention, rebuilt-byte qualification, Q08 and release acceptance cases. Expanded actual-agent adapter contract for shipped Python, named venv, real tool PATH, runtime setup, activation alias, no-op compatibility installation and fail-closed observation. Public guidance omits private identifiers as required by the human; release guidance is verbatim.

### Human guidance and writer response for design-specification deploy-venv-sync (round 3)

Human guidance:

Human guidance:

Revise and review again, with guidance such as:

Add the release path: which build produces and publishes the application
archive and its reconstruction bundle (same digests as the qualified
validation build, or a publication run of the same revision), where the
bundle is published and retained for offline rollback, and how that path
relates to the disabled publishers of validation builds. Show where the
mandated pipeline sits in the target flow (CI validation only, not
deployment).

Privacy-preserving rendering of the additional human guidance: ensure the
mandated pipeline entry point picks up our environment venv and tools Python;
do not name the private integration in public documents. The human clarified
that this means its specific pipeline entry point, not a generic library.
Private identifiers are deliberately omitted from this public review input.

Writer response:

﻿Applied human guidance and checked the specific mandated pipeline's dependency/activation/test behavior in private sources. No private identifiers are exported. Prior reviewer recommendations remain accepted. Publication promotes qualified bytes by default; same-revision regeneration requires qualification of its actual pair. Both validation publishers remain disabled. Separate publication neither replaces the mandated validation phase nor adds deployment to CI. Please review release evidence/retention completeness and actual-command environment selection.

### Reviewer focus for design-specification deploy-venv-sync (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-09-22T17:13:44+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification deploy-venv-sync round 3

Round 3 closes the release-path gap well.

- The target flow now shows CI validation, release qualification, publication
  and deployment as distinct stages, with the mandated pipeline confined to
  CI validation.
- Phase 1 assembles the candidate pair and archives it as a CI artifact, not a
  release.
- A separate, authorized publication run promotes the exact digest-verified
  bytes, publishing the objects before the binding manifest.
- Partial publication and overwrites are refused, and rebuilt bytes need fresh
  qualification (Q08).
- Retention covers the repository and a local store outside the mirrored tree.
- The expanded adapter contract verifies resolved executables, not variable
  values, including after the mandated activation.

Three gaps remain in the new publication path.

- **Qualification evidence is not explicitly bound to the candidate digests.**
  The publication run checks "complete qualification evidence", but the design
  never requires the RHEL readiness, offline reconstruction and rollback
  evidence to be produced on the exact candidate pair. Nor does it say how
  those bytes reach the RHEL target. Without that binding, a candidate could be
  promoted on evidence taken from other bytes. Q08's own logic, that identical
  source does not establish identical artifacts, applies to evidence as much as
  to publication.
- **Candidate retention is assumed, not specified.** Q08's con names reliable
  retention, and the design says expiry blocks promotion. But the consuming
  application's current CI policy keeps artifacts for only the most recent
  build, so any later validation build discards a candidate before RHEL
  qualification can finish. The design must require retention that survives
  later builds until promotion or explicit abandonment, and must say where the
  candidate is kept if CI artifact retention cannot provide that.
- **Where the publication run executes is an open decision.** The requirement
  allows one Jenkinsfile, one job and one build for CI validation. The design
  says the publication run is separate and "not another phase/job replacing the
  mandated pipeline", but not whether it is a publication mode of the same job,
  a separate job, or an operator-run publication outside CI. Each choice
  interacts differently with the one-job rule, with where the release
  publisher's credentials live, and with any expectation that every build of
  the job goes through the mandated pipeline. That is a missing question.

### Question verdicts for design-specification deploy-venv-sync round 3

- **Q01 to Q07:** unchanged, and I agree with each recommended answer (Q01 B,
  Q02 A, Q03 B, Q04 A, Q05 A, Q06 A, Q07 A).
- **Q08 (A, promote exact bytes):** agree. Its recommendation depends on the
  retention and evidence-binding points below, so reference them from the answer.

**Missing Q09: where does the publication run execute?**

- Option A: a publication mode of the same CI job, selected by an explicit
  authorized parameter. It runs no validation phases, retrieves a named
  candidate from its source build, checks digests and evidence, and runs only
  the application release publisher.
  - pro: One job, and the publisher's credentials stay where they are today.
  - con: A build of this job would not go through the mandated pipeline.
    Confirm that the mandate accepts this, and that the mode cannot run by accident.
- Option B: a separate publication job that consumes candidates from the
  validation job.
  - pro: Validation and publication stay cleanly separated.
  - con: It adds a second job, which the requirement's one-job rule may not allow.
- Option C: an operator-run publication outside CI, using the existing
  application publisher with the retained candidate.
  - pro: No CI change, and it matches how the toolchain release itself was
    published.
  - con: Manual steps; the evidence and credential handling must be made
    reproducible.

I cannot choose without knowing the mandate's rules for builds of this job.
If the mandate allows a non-validation mode, I would choose A. Otherwise I
would choose C, which the toolchain release already proved workable.

### Requested changes for design-specification deploy-venv-sync round 3

Requested changes:

- Bind the RHEL readiness, offline reconstruction and rollback evidence to the
  exact candidate digests, and describe how the candidate reaches RHEL.
- Specify candidate retention that survives later builds until promotion.
- Add Q09: where the publication run executes, relative to the one-job rule and
  the mandate.
- Add the two acceptance cases, and reference both rules from Q08.

### Human guidance response for design-specification deploy-venv-sync round 3

Human guidance:

Revise and review again, with guidance such as:

Add the release path: which build produces and publishes the application
archive and its reconstruction bundle (same digests as the qualified
validation build, or a publication run of the same revision), where the
bundle is published and retained for offline rollback, and how that path
relates to the disabled publishers of validation builds. Show where the
mandated pipeline sits in the target flow (CI validation only, not
deployment).

Privacy-preserving rendering of the additional human guidance: ensure the
mandated pipeline entry point picks up our environment venv and tools Python;
do not name the private integration in public documents. The human clarified
that this means its specific pipeline entry point, not a generic library.
Private identifiers are deliberately omitted from this public review input.

Guidance response:

Both guidance items are applied. The release path now names the producing
phase, a separate promotion of the exact bytes, and the repository and local
retention, and it relates publication to the disabled validation publishers.
The target flow places the mandated pipeline in CI validation only. The
guidance on the mandated pipeline's entry point is met by the expanded adapter
contract, which verifies resolved executables after the mandated activation.
The remaining requests complete the release path the guidance asked for: which
bytes the qualification evidence describes, how long a candidate survives, and
where publication runs.

### Writer instructions for design-specification deploy-venv-sync round 3

Revise the design, then publish a replacement request.

- **Qualification binding (publication section):** require the RHEL readiness,
  offline reconstruction and rollback evidence to be produced on the exact
  candidate pair, identified by its digests. State how those bytes reach the
  RHEL target (retrieved from candidate retention and digest-checked). The
  publication run must refuse evidence bound to other digests.
- **Candidate retention:** require it to survive later validation builds until
  promotion or explicit abandonment. Note that the current CI artifact policy
  keeps only the latest build's artifacts, and say where candidates are kept if
  CI retention cannot guarantee this.
- **Add Q09** (where the publication run executes) with the options in the
  question verdicts, and relate each to the requirement's one-job rule and to
  the mandate.
- **Q08:** reference the retention and evidence-binding rules from the answer.
- **Acceptance cases:** add a case for "evidence bound to other digests is
  refused at promotion", and one for "a later validation build does not
  discard a pending candidate".
- Keep all content generic.

### Final reviewer decision for design-specification deploy-venv-sync round 3

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-09-22T17:16:10+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for design-specification deploy-venv-sync (round 4)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
Review round: 4

### Requestor assessment for design-specification deploy-venv-sync (round 4)

﻿Nine questions now cover the design choices. Q09 adds publication execution location with all three reviewer options; C is recommended provisionally to preserve the confirmed CI mandate without assuming an exception. A human preference question is pending, not an authorization request. All round 3 concrete requests are applied: exact candidate evidence binding, qualification delivery to RHEL, durable candidate retention, Q08 links and two acceptance cases. Assess remaining gaps; runtime qualification remains outstanding.

### Change summary for design-specification deploy-venv-sync (round 4)

﻿Round 4 protects pending candidates until promotion or explicit abandonment, using a durable non-release candidate store if CI retention cannot do so. RHEL receives digest-verified candidate bytes; offline/readiness/rollback records bind to them and identify predecessor inputs. Later evidence stays external to the frozen bundle. Publication rejects evidence for different digests. Q08 references these rules; Q09 covers publication runner choices and proposes operator execution outside CI. Added evidence-mismatch and later-build-retention acceptance cases.

### Human guidance and writer response for design-specification deploy-venv-sync (round 4)

Human guidance:

Human guidance:

Revise and review again, with guidance such as:

Add the release path: which build produces and publishes the application
archive and its reconstruction bundle (same digests as the qualified
validation build, or a publication run of the same revision), where the
bundle is published and retained for offline rollback, and how that path
relates to the disabled publishers of validation builds. Show where the
mandated pipeline sits in the target flow (CI validation only, not
deployment).

Privacy-preserving rendering of the additional human guidance: ensure the
mandated pipeline entry point picks up our environment venv and tools Python;
do not name the private integration in public documents. The human clarified
that this means its specific pipeline entry point, not a generic library.
Private identifiers are deliberately omitted from this public review input.

Writer response:

﻿Accepted all round 3 requests. No disagreement. Recommended Q09 C because no exception to the mandated validation flow has been established; A and B remain explicit options requiring confirmation of compatibility. This is a design recommendation pending human consolidation, not a claim of human selection or authorization to publish. Candidate storage is a qualification handoff, not release publication, preserving both disabled validation publishers. Qualification artifacts generated later bind to frozen candidate digests without modifying the bundle.

### Reviewer focus for design-specification deploy-venv-sync (round 4)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-09-22T17:18:04+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification deploy-venv-sync round 4

Round 4 applies every round 3 request.

- Pending candidates survive later validation builds until promotion or
  explicit abandonment, with a durable, access-controlled candidate store when
  CI retention cannot protect the named build. They are indexed by source
  build, revision and digests, and never replaced.
- RHEL qualification receives the digest-checked candidate pair into its local
  store before remote access is denied. The readiness, offline and rollback
  evidence names the candidate, toolchain and predecessor identities.
- Later evidence lives in a separate digest-bound qualification record rather
  than mutating the frozen bundle. Promotion refuses evidence for other bytes,
  even at the same revision.
- Q08 references both rules, and Q09 exposes the three publication runners with
  their consequences for the one-job rule and the mandate.
- Both requested acceptance cases were added.

No design question is missing, and nothing reopens the requirement. Q09's
recommendation (operator-run publication outside CI) is the right default
while no exception to the mandated validation flow has been established. It
remains the human's choice. Three clarifications remain, all wording-level;
see the covered wording.

### Question verdicts for design-specification deploy-venv-sync round 4

- **Q01 to Q08:** unchanged, and I agree with each recommended answer (Q01 B,
  Q02 A, Q03 B, Q04 A, Q05 A, Q06 A, Q07 A, Q08 A).
- **Q09 (C, operator-run publication):** agree as the default. If the human
  confirms that the mandate permits a build of the job without the validation
  phases, option A becomes preferable: one job, existing credentials, and a
  reproducible CI record.

No missing question.

### Convergence evidence for design-specification deploy-venv-sync round 4

Covered wording:

- **Candidate store transfer (publication section):** add "The copy to the
  candidate store uses neither a Maven deployment command nor the release
  repository, so the validation build's no-deployment and no-release-upload
  evidence stays true and distinguishable from this handoff."
- **Candidate retention (publication section):** name the simplest protection
  first: "Prefer marking the named source build as kept in CI, so its archived
  pair is exempt from routine discarding; use the durable candidate store only
  when that is unavailable."
- **Acceptance case mapping:** the cases "Qualification evidence identifies
  other candidate digests" and "A later validation build runs while a candidate
  awaits qualification" map to AC14, the no-source-build criterion, which they
  do not test. Map them to AC12 (rollback on qualified inputs) and AC11 (the
  validation build's publication boundary) as appropriate, or mark them as
  design-level release cases that have no single requirement criterion.

Convergence rationale:

Every design decision has a recommended answer I would also choose, and Q09's
default is sound until the human settles the mandate question. The release
path is now complete: candidate assembly, retention, qualification bound to the
candidate digests, promotion of the exact bytes, and repository and local
retention. The remaining edits clarify two sentences and correct an
acceptance-case mapping, without changing any decision. Convergence is advisory:
consolidation, and confirmation of the nine design answers (Q09 in
particular), remain the human's choice.

### Human guidance response for design-specification deploy-venv-sync round 4

Human guidance:

Revise and review again, with guidance such as:

Add the release path: which build produces and publishes the application
archive and its reconstruction bundle (same digests as the qualified
validation build, or a publication run of the same revision), where the
bundle is published and retained for offline rollback, and how that path
relates to the disabled publishers of validation builds. Show where the
mandated pipeline sits in the target flow (CI validation only, not
deployment).

Privacy-preserving rendering of the additional human guidance: ensure the
mandated pipeline entry point picks up our environment venv and tools Python;
do not name the private integration in public documents. The human clarified
that this means its specific pipeline entry point, not a generic library.
Private identifiers are deliberately omitted from this public review input.

Guidance response:

The carried guidance is fully met. The release path covers the producing phase,
retention, qualification bound to the candidate bytes, promotion of the exact
bytes, and repository and local retention for offline rollback, and it relates
publication to the disabled validation publishers. The mandated pipeline sits
in CI validation only, and its entry point is required to select our toolchain
Python and prepared venv, verified from resolved executables. The covered
wording only sharpens the candidate handoff and the acceptance-case mapping.

### Writer instructions for design-specification deploy-venv-sync round 4

No further review round is needed. Apply the covered wording during
consolidation, after the human confirms the design answers, including the
Q09 runner. Do not treat this convergence recommendation as that confirmation.

### Final reviewer decision for design-specification deploy-venv-sync round 4

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-4 -->

## Round 4 by human - human-confirmation

- Recorded: 2026-09-22T18:40:55+02:00
- Exchange: specification/design-specification/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-4 -->
