# Specification review transcript for v0.27.0

- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-22T19:52:07+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for plan deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 1

### Requestor assessment for plan deploy-venv-sync (round 1)

The seven-step implementation plan and matching validation plan cover release input qualification, complete dependency selection, exact-path environment reconstruction, archive exclusion and recovery, single-build CI integration, operator promotion, and exact-candidate acceptance. Existing requirement and design decisions remain the implementation basis.

Seven open questions identify the remaining planning uncertainties. No additional missing question is known from the current source and document inspection. Each question includes options, advantages, disadvantages, a recommendation, and a proposed answer; those answers are proposals awaiting review and human consolidation.

Please assess feasibility, dependency ordering, file responsibilities, negative-case evidence, and completion criteria. In particular, Q03 proposes making the shared CI evidence validator an explicit step-5 implementation target, and Q05 proposes a dedicated phase-2 test observer. These are proposed amendments, not silently approved decisions. Q07 requires concrete operator execution details before live backend work. The options are sufficient to start independent review, but their recommended choices have not been independently validated.

No reviewer wording suggestions exist in this first round, so none have been applied. Repository Markdown checks passed for the four affected specification documents; whitespace checks passed. No implementation, target execution, CI build, or rollout has been performed as part of this documentation task.

The public plan represents consuming integration files through numbered handles and records their measured baselines. Private mappings and completion evidence remain outside the public repository. Review the generic integration obligations without requesting confidential names or treating unavailable private execution evidence as successful validation.

### Change summary for plan deploy-venv-sync (round 1)

This is the first plan review round. Added a seven-step implementation plan with file-level work, physical line baselines, test-tree additions, platform-specific commands, verification gates, deployment recovery, promotion, and acceptance evidence. Added a matching validation plan with every implementation step unstarted and unchecked evidence placeholders retained.

Recorded the file-based IO cost clarification consistently in the requirement, design, and plan. Added seven open questions through the question workflow. Preserved private integration obligations using public file handles and a separate private mapping.

### Writer response for plan deploy-venv-sync (round 1)

Writer response:

There is no preceding reviewer response in round 1. The writer recommends option A for Q01 through Q07, with the arguments stated in the plan. No reviewer disagreement has yet occurred, and no review recommendation or proposed answer has been treated as human authorization.

The user requested preparation through the first specification review request, then a stop. This publication is the requested handoff boundary; this session will not wait for or process an answer, consolidate the questions, or begin implementation.

### Reviewer focus for plan deploy-venv-sync (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `.reviews/a.review-active.specification.plan.v0.27.0.deploy-venv-sync.md`
- `.reviews/a.review-requested.plan.v0.27.0.deploy-venv-sync.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-22T19:55:15+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync round 1

The plan is well built. Seven steps in a defensible order, each with file
lists, tests-first cases, line-budget checkpoints, a bounded inspection
command, and completion criteria that refuse fixture success as a substitute
for actual target or backend evidence. The rollout table maps AC01 to AC15 and
the design's retention and promotion boundaries to owning steps. The private
integration is represented through numbered handles with measured baselines,
and no private identifier appears in the public plan.

One gap blocks implementation, and two smaller items need correcting.

- **How the new deployment helpers reach the targets is unspecified.** Steps 3
  and 4 create `deploy_venv.sh`, `deploy_venv_archive.py`,
  `deploy_venv_release.py` and their companions under
  `src/setups/env/bin/`, which is the toolchain payload directory. The RHEL
  deployment target and the Debian agent must execute those commands, but this
  effort explicitly excludes toolchain archive republication and preserves item
  7's accepted archive, which was published before these files existed. The
  reconstruction bundle manifest lists the application, metadata, toolchain, uv,
  selection, wheels, transport map and runtime evidence, and no cplx helper
  payload. So no step delivers the new commands to the hosts that must run them.
  AC02, archive-only installation on both platforms, cannot pass as planned.
  The existing verification-bundle delivery (`ci/deliver-closure-tools.sh`,
  already listed as reused) is one candidate answer, and delivering the helpers
  with the release inputs is another. This is a planning decision with
  consequences for the bundle manifest, retention and rollback, so it needs its
  own question and explicit step ownership.
- **Q03's recommended answer is not reflected in Step 5's file list.** If the
  shared eligibility validator becomes a Step 5 target, `deploy_venv_release.py`
  must appear in Step 5's files and line-budget checkpoint. Today it appears
  only in Steps 4 and 6.
- **The validation plan is listed only under Step 7.** Implementation-check
  updates the reviewed step's rows after every step, so
  `plan.v0.27.0.deploy-venv-sync.validation.md` is touched by each step, not
  just the last one.

Everything else holds: the IO clarification, the harness and command forms, the
650-line ceiling enforced explicitly in the native harness, the refusal to
invent a cplx coverage gate, and the negative-case coverage in every step.

### Question verdicts for plan deploy-venv-sync round 1

- **Q01, verification commands: agree with option A.** The native cumulative
  harness plus the consumer's configured walk is the honest pairing, and
  option B would invent a coverage gate this repository does not have.
- **Q02, early probe: agree with option A.** Keep the narrow real-tool probe in
  Step 1 and deny it final-qualification status. Option B would let Steps 2 to 5
  build on an unproven locked transport.
- **Q03, shared CI evidence target: agree with option A,** provided Step 5's
  file list and line budget gain `deploy_venv_release.py`.
- **Q04, selection oracle: agree with option A.** Record the provenance of each
  captured fixture (uv version, toolchain digest, profile) with the fixture, so
  a refreshed oracle is traceable.
- **Q05, phase 2 observer: agree with option A.** A separate module keeps phase
  1's strict policy intact; a mode switch inside one observer is the easier
  thing to weaken by accident.
- **Q06, packaging exclusions: agree with option A.** Inspecting the real
  archive is the only way to catch option ordering and alias traversal.
- **Q07, operator runner details: agree with option A.**

**Missing Q08: how do the new cplx deployment helpers reach the targets?**

- Option A: Deliver them through the existing verification-bundle mechanism,
  digest-bound like the other release inputs.
  - pro: Reuses a proven delivery path and leaves the accepted toolchain archive
    untouched.
  - con: The bundle manifest, retention and rollback must cover the helper
    payload, and its version must be pinned per release.
- Option B: Deliver them inside the release reconstruction bundle as an
  additional manifest row.
  - pro: One delivery, one manifest, one retention rule for everything the
    deployment needs.
  - con: Couples cplx helper versioning to the application release.
- Option C: Republish the toolchain archive containing the new helpers.
  - pro: The helpers live beside the interpreter they use.
  - con: Excluded by this effort's scope, and it would repeat item 7's
    acceptance for a new archive.

I would choose A, with the helper payload pinned by digest in the release
manifest and retained for the predecessor exactly like the wheels. C should be
rejected explicitly, so the scope boundary stays visible.

### Requested changes for plan deploy-venv-sync round 1

Requested changes:

- Add Q08 and settle how the new deployment helpers reach the RHEL target and
  the Debian agent without republishing the toolchain archive.
- Give that delivery step ownership, a manifest binding, retention and rollback
  rules, and rollout-table evidence under AC02 and AC12.
- Add `deploy_venv_release.py` to Step 5's file list and line budget under Q03.
- List the validation plan in every step's file list, not only Step 7.

### Writer instructions for plan deploy-venv-sync round 1

Revise the plan, then publish a replacement request.

- **Add Q08** (delivery of the new cplx deployment helpers) with the options in
  the question verdicts.
- **Give the chosen delivery explicit step ownership:** name the step that
  produces the helper payload, the step that verifies it on the target before
  use, and the manifest row that binds its digest. Add it to the retention and
  rollback rules, so a predecessor rollback runs the helper version that
  release was qualified with.
- **Extend the rollout table:** AC02 and AC12 must name the helper delivery as
  required closing evidence.
- **Step 5:** add `deploy_venv_release.py` to the file list and line-budget
  checkpoint, conditional on Q03's answer.
- **Validation plan file:** list it in every step's file list, not only Step 7,
  since implementation-check updates the reviewed step's rows each time.
- Keep the public plan generic; the helper delivery is a public cplx concern
  and needs no private identifier.

### Final reviewer decision for plan deploy-venv-sync round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-22T21:39:57+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 2

### Requestor assessment for plan deploy-venv-sync (round 2)

The revised seven-step plan addresses the round 1 delivery gap and the two file-list corrections. Eight open questions now cover the known planning uncertainties. Their options, recommendations, and proposed answers are sufficient for another independent review; no additional missing question is currently known. The recommendations remain proposals awaiting review and human consolidation.

The reviewer-requested clarifications have been applied: helper delivery has explicit producer, bootstrap verification, manifest binding, retention, rollback, and AC02/AC12 evidence; Step 5 includes the shared release validator; every step lists the validation plan. Selection fixtures carry provenance, and a dedicated phase 2 observer preserves the existing phase 1 observer unchanged.

Please assess Q08 option B in particular, including the independently delivered bootstrap record, verification before extraction, helper invocation without relying on host Python, and predecessor retention. Also assess the ordering between candidate qualification and final publication: changed helper bytes require a fresh qualified candidate, and prepublication automation uses candidate staging.

The public obligations and numbered integration handles remain generic. Private integration mappings are maintained outside this repository. Markdown and whitespace checks passed for the affected specifications. This is planning evidence only: implementation, deployment automation, target execution, and CI qualification remain outstanding.

### Change summary for plan deploy-venv-sync (round 2)

Since round 1, the plan and matching validation plan now specify:

- A release-versioned entry script delivered separately by deployment automation, plus a frozen release-input record and helper-bearing reconstruction companion.
- Independent tools version, digest, and coordinate selection; exact local archive reuse or verified preparatory acquisition before destructive deployment changes; offline reconstruction and rollback from retained inputs.
- Q08 with the three reviewer-proposed delivery options, recommending B and explicitly excluding tools archive republication from scope.
- A complete helper closure with immutable revision and member bindings; a strict versioned key/value bootstrap record; verification before safe extraction; explicit producer and consumer ownership across Steps 1, 3, 4, 5, 6, and 7.
- Retention of each release's own script, record, helpers, and tools outside the replaced application tree, including predecessor rollback and the historical-release exception.
- Helper delivery evidence under AC02 and AC12, actual automation qualification, and candidate staging before final publication.
- The shared release validator in Step 5's file list and line checkpoint, and the validation plan in every step's file list.
- Selection-fixture provenance and a dedicated phase 2 observer with its own integration handle and line budget, leaving the phase 1 observer unchanged.

The private handoff and file mapping were updated separately. All implementation-validation steps remain not started. No recommendation has been consolidated or treated as implementation authorization.

### Writer response for plan deploy-venv-sync (round 2)

Writer response:

The round 1 requested changes are addressed in the plan and matching validation plan.

1. Helper delivery: Q08 now contains options A, B, and C. The writer recommends B, the release reconstruction companion, rather than the reviewer's A, the separate verification bundle. The clarified consuming flow already delivers a release entry script separately and needs the reconstruction companion. Adding the complete helper closure to that companion avoids another required deployment bundle and gives it the same retention boundary. This pins the helper revision per application release without forcing tools archive versions to advance with application versions. This is an explicit disagreement about the recommended option, not a claim that the user approved B. C remains excluded because tools archive republication is outside this effort.
2. Ownership and binding: Step 1 defines the release-input and companion schemas and fixture assembly; Step 3 owns bootstrap verification; Step 4 completes deployment assembly, automation delivery, acquisition, and recovery; Step 5 qualifies the exact closure on agents; Step 6 promotes that frozen set; Step 7 closes actual target evidence. The outer record binds the final script, application, and companion, while the inner manifest binds helper revision and members without circular hashes. The strict bootstrap record is parsed as data, never sourced or evaluated; no unshipped Python or helper is assumed. Extraction follows companion verification, and helpers run by absolute path using the shipped runtime.
3. Retention and rollback: predecessor script, record, helper payload, tools, and other reconstruction inputs remain retained outside the replaced application tree. Rollback uses that predecessor's qualified helper version and retained inputs offline. AC02 and AC12 explicitly require helper delivery and recovery evidence.
4. Q03: Step 5 now lists deploy_venv_release.py and its line-budget checkpoint as the proposed shared evidence validator target.
5. Validation updates: every implementation step now lists the matching validation plan as a touched file; validation status remains not started.
6. Q04 and Q05: selection fixtures record uv version, tools digest, and profile. A new dedicated phase 2 observer has its own file handle and line budget; the existing phase 1 observer remains unchanged. The earlier Step 5 inconsistency has been removed.

Q01 through Q07 retain recommendation A. Public wording remains generic, with deployment-specific mappings and unverified integration details confined to private handoff notes. Preparatory acquisition is distinct from offline reconstruction; missing or mismatched release inputs fail before destructive changes. No live deployment or implementation success is claimed.

The user requested preparation of round 2. This session stops after publishing that request, before processing its answer or consolidating questions.

### Reviewer focus for plan deploy-venv-sync (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-22T21:43:11+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync round 2

Round 2 answers the round 1 gap properly, and I accept the writer's
disagreement on Q08.

- **Q08 option B is the better choice.** The consuming automation already
  copies a separately published entry script, and the reconstruction companion
  is already required and retained. Putting the helper closure there avoids a
  second mandatory bundle and gives helpers one retention boundary, while my
  option A would have reused a bundle carrying unrelated acceptance controls.
  The explicit member manifest, the immutable cplx source revision, the
  verification before extraction, the absolute-path dispatch with the shipped
  runtime, and the refusal of any PATH or installed-helper fallback all make
  the delivery checkable.
- The outer record's fixed key=value format, parsed but never sourced or
  evaluated, is the right shape for a bootstrap that cannot assume host Python
  or a JSON tool. Avoiding circular hashes is stated explicitly.
- Step ownership (1, 3, 4, 5, 6, 7), predecessor retention including the
  historical first-transition exception, the AC02 and AC12 evidence rows, the
  Step 5 validator target and the per-step validation plan are all in place.
  Selection fixtures now carry their provenance, and the phase 2 observer is a
  separate module leaving the phase 1 observer untouched.

One conflict with the consolidated requirement remains.

**Preparatory toolchain acquisition contradicts AC06.** The new delivery
section allows deployment, before installation mutation, to acquire the exact
pinned toolchain archive from the configured artifact service with the host's
network tools when no verified local copy exists. AC06 requires forward
deployment to succeed "with empty caches and every Python library referential,
mirror, and remote artifact service unreachable, using digest-pinned
release-delivered inputs". A first deployment to a host without that archive
therefore needs a service AC06 declares unreachable. Calling the fetch
preparatory does not remove the conflict: it is part of reaching readiness for
that release.

Two ways out, and the choice is the human's because one of them amends a
consolidated requirement:

- Deliver the pinned toolchain archive with the release inputs, like the
  companion and the entry script, so forward deployment stays fully offline as
  AC06 states. The independently recorded tools version and digest still select
  it, and rollback still uses the predecessor's own archive.
- Amend AC06 to scope its offline guarantee to dependency and helper inputs,
  and record toolchain availability as a documented prerequisite of the
  preparatory phase. This needs a requirement round and human confirmation,
  not a plan-level assumption.

Until this is settled, Step 4 and Step 7 would be planning evidence that cannot
satisfy AC06 as written.

### Question verdicts for plan deploy-venv-sync round 2

- **Q01 to Q07:** unchanged, and I still agree with option A for each. Q03's
  proviso is satisfied: Step 5 now lists the shared validator and its budget.
- **Q08: I withdraw my option A recommendation and agree with option B.** The
  writer's reasons are better than mine: the companion is already required and
  retained, and the automation already delivers a separate entry script, so B
  adds no artifact. Option C stays correctly rejected as outside this effort.

**Missing Q09: how does forward deployment obtain the pinned toolchain archive
under AC06?**

- Option A: Deliver the pinned toolchain archive with the release inputs, so
  forward deployment needs no service at all.
  - pro: Satisfies AC06 exactly as consolidated; the same retention rule
    already covers the predecessor's archive.
  - con: Each release delivery carries the archive, which is large, even when
    the target already has that exact version.
- Option B: Keep the preparatory acquisition, and amend AC06 so its offline
  guarantee covers dependency and helper inputs, with toolchain availability as
  a stated prerequisite.
  - pro: Avoids repeatedly delivering an archive the target usually has.
  - con: Amends a consolidated requirement, so it needs a requirement round and
    human confirmation.

I would choose A for a first deployment of a release whose toolchain version is
not already present, and note that an exact verified local copy is reused
without any fetch, which is what makes A affordable in practice. If the human
prefers B, the requirement must change before this plan is consolidated.

### Requested changes for plan deploy-venv-sync round 2

Requested changes:

- Add Q09 and reconcile the preparatory toolchain acquisition with AC06, whose
  offline guarantee currently excludes it.
- Align the delivery section, Step 4, Step 7 and the AC02/AC06 rollout rows
  with the recommended answer, marking any requirement amendment as a
  prerequisite rather than an assumption.

### Writer instructions for plan deploy-venv-sync round 2

Revise the plan, then publish a replacement request.

- **Add Q09** (toolchain acquisition against AC06) with the two options above,
  and say plainly that option B requires amending the consolidated requirement
  through its own round and human confirmation.
- **Make the plan consistent with whichever answer is recommended:** if the
  toolchain archive is release-delivered, say which step produces and binds it,
  add its digest to the release record's delivered set, and keep the
  exact-local-copy reuse as the optimization it is. If the acquisition path is
  kept, mark every affected plan statement and rollout row as blocked on the
  requirement amendment rather than as satisfied evidence.
- **AC02 and AC06 rollout rows:** state which inputs are release-delivered and
  which, if any, are acquired, so the closing evidence matches the criterion
  being claimed.
- Keep the plan generic; this is a public cplx delivery concern.

### Final reviewer decision for plan deploy-venv-sync round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by requestor (b)

- Recorded: 2026-09-22T21:52:36+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: escalation

review disagreement remained after the clarification round

<!-- review-entry-id: escalation-round-2 -->

## Round 3 by human - human-resolution

- Recorded: 2026-09-22T22:21:05+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-resolution

## Human resolution of the consumer-delivery boundary (round 3)

The human approved amending requirement AC02/AC06 and requirement Q09, aligning the design and plan Q09, and retaining design Q09's separate publication decision. cplx starts with complete locally supplied release inputs and verifies/reconstructs offline; the consumer owns earlier acquisition. Include definitions of empty caches and no target Git checkout and retain the generic supplied-information/purpose table. Concrete integration mechanisms stay in the private handoff.

Independent cplx work may progress with its own validation while private integration remains pending. Mixed-step and whole-topic completion and promotion retain all mandatory integration evidence gates. This guidance resolves the disagreement behind the round 2 escalation. Preserve the stopped review evidence and advance to round 3 for review of the amended documents. The human explicitly requested publication if possible; no consolidation or implementation is authorized by this resolution.

<!-- review-entry-id: human-resolution-round-3 -->

### LLM nature completion for requestor (exchange 1)

Recorded nature: `codex`

Completed artifacts:

- `.reviews/a.review-active.specification.plan.v0.27.0.deploy-venv-sync.md`

<!-- review-entry-id: llm-nature-completion-requestor-exchange-1 -->

## Round 3 by requestor

- Recorded: 2026-09-22T22:20:41+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for plan deploy-venv-sync (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 3

### Requestor assessment for plan deploy-venv-sync (round 3)

Nine questions cover the known uncertainties; no additional missing question is known. Existing options and answers are sufficient for review against the amended requirement and design. Q01-Q07 retain A; Q08 retains B, accepted in round 2. Plan Q09 now records the human-approved consumer-delivery boundary rather than an unresolved requirement dependency.

Round 2 correctly identified a conflict with the previous AC06. The human has now approved changing that boundary: the consumer supplies complete local release inputs, and cplx verifies and reconstructs offline. Requirement AC02/AC06 and Q09, the design, plan Q09, Steps 4 and 7 and validation expectations are aligned. Design Q09 remains the separate operator-publication decision. Definitions cover empty caches, no target Git checkout and remote-service denial during reconstruction. The generic supplied-information table is retained.

Please assess consistency, input-integrity failures before mutation, offline reconstruction and retained predecessor recovery. Independent cplx tasks may progress with their own evidence, while private integration and mixed-step completion remain pending. No implementation or qualification is claimed; all validation steps remain not started. Plan consolidation remains a later human gate.

### Change summary for plan deploy-venv-sync (round 3)

- Amended requirement AC02/AC06 and requirement Q09 with explicit human approval; aligned the design and plan Q09 while preserving design Q09's publication meaning.
- Added clear consumer delivery versus cplx reconstruction responsibilities, the generic supplied-information/purpose table, and definitions of empty caches, no target Git checkout and remote services denied during reconstruction.
- Replaced public acquisition mechanics and pending-amendment blockers with local input verification and offline reconstruction tasks. Kept concrete acquisition and independent tools-version details in private handoff notes.
- Preserved complete local predecessor recovery inputs, digest binding, failure before mutation and real target/CI qualification requirements.
- Separated independently verifiable cplx progress from private integration completion; mixed steps and full-topic completion still require their integration evidence. Corrected AC14's mapping to prebuilt wheel inputs.
- Retained the reviewer's accepted Q08 B helper delivery and all other proposed answers.

### Human guidance and writer response for plan deploy-venv-sync (round 3)

Human guidance:

Verbatim public excerpts of the human's latest guidance (the consumer-specific sentence is kept in the private handoff):

> 1. OK but do add your empty cache and no target git checkout definition in addition of your simpler proposal that I agree to. And update the three Q09 references accordingly.
>
> 2. agreed.
>
> 3. agreed.
>
> 4. agreed.
>
> Can you then tell me if you can publish round 3? If you can, do so.

Writer response:

I accept the round 2 finding against the previous AC06: fetching a missing tools archive cannot count as offline success merely because it occurs before mutation. The human has explicitly approved a requirement/design amendment to make the cplx boundary start with complete locally supplied release inputs. That amendment is applied, not awaiting a separate approval. Please review the plan against the updated requirement and design.

The consumer owns earlier acquisition and delivery. cplx verifies supplied files and expected identities, rejects missing or invalid inputs before mutation, and reconstructs with empty caches, no target Git checkout and all remote artifact services denied. Retained archives and wheels are release inputs rather than caches. Recovery still requires the complete retained predecessor set and never fetches. Concrete consumer mechanisms remain privately tracked.

The human-approved boundary resolves the Q09 disagreement that stopped automation. Q08 B remains accepted from round 2. Independent cplx implementation and validation may proceed without private acquisition blocking those tasks; mandatory integration evidence still gates mixed-step completion, full-topic validation and real promotion. This request does not claim implementation, qualification or plan consolidation. The user requested publication of round 3 and a stop at that handoff.

### Reviewer focus for plan deploy-venv-sync (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-09-22T22:24:21+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync round 3

Round 3 resolves the round 2 conflict properly, and the resolution is the
human's, recorded verbatim rather than assumed.

- The amended AC02 and AC06 now start from complete locally supplied release
  inputs: cplx verifies them, reconstructs with empty caches, no target Git
  checkout and remote artifact services denied, and fails before any mutation
  when an input is missing or invalid.
- The design's supplied-information table gives the interface generically:
  paths, the required tools version and archive digest, the companion digest
  and the application release record, with the note that versions and checksums
  identify files and are not credentials.
- The definitions the human asked for are present and precise. Empty caches
  means no reliance on packages left by an earlier run, while retained release
  archives and wheels stay available as required inputs. No target Git checkout
  means no clone and no Git filters for dependency information.
- Plan Q09 records the boundary without reopening the consumer's transport
  choice, and it correctly keeps design Q09 as the separate operator-publication
  decision. The public acquisition mechanics and the earlier
  pending-amendment blockers are gone; acquisition is named as the consumer's
  responsibility, tested through the private mapping.
- Rollback still requires the complete retained predecessor set and permits no
  fetch. Q08 B, accepted in round 2, is unchanged, and AC14's rollout row is
  corrected to prebuilt wheel inputs.

I checked the requirement, the design and the plan against each other and found
no residual of the superseded offline wording. No question is missing, and the
plan's own questions keep answers I would choose.

One defect remains, in the validation plan rather than the plan: its
document-level status line reads `No, it is not implemented` without the final
period. The implementation-check contract expects exactly
`No, it is not implemented.`, and the release preparation step stops on that
line. It is a one-character fix, so convergence is still the right disposition.

### Question verdicts for plan deploy-venv-sync round 3

- **Q01 to Q07:** agree with option A for each, unchanged.
- **Q08:** agree with option B, as accepted in round 2.
- **Q09:** agree with option B. It matches the human's approved boundary:
  the consumer supplies and cplx verifies and reconstructs offline. Option A,
  making cplx own end-to-end acquisition, is correctly rejected, since it would
  tie reusable cplx behavior to one consumer's transport.

No missing question. The nine questions cover the planning uncertainties, and
each recommended answer is one I would also choose.

### Convergence evidence for plan deploy-venv-sync round 3

Covered wording:

- **Validation plan status line:** change `No, it is not implemented` to
  `No, it is not implemented.` with the final period, so it matches the exact
  sentence the implementation check and the release preparation step read.
- **Plan delivery section, Q08 sentence:** "Q08 proposes carrying the new
  helpers inside the already required reconstruction companion ... This is a
  review proposal, not a consolidated decision" can now say that the reviewer
  accepted option B in round 2 and it awaits human consolidation, which is the
  same status as the other answers.

Convergence rationale:

Every planning decision is settled by an answer I would also choose, the round 2
conflict is resolved by an explicit human amendment applied consistently across
the requirement, design and plan, and the steps, rollout rows and validation
skeleton follow it. The remaining edits are a missing period and one status
sentence, changing no decision. Convergence is advisory: consolidation, and
confirmation of the nine plan answers, remain the human's choice. Implementation
and integration qualification are untouched by this review.

### Human guidance response for plan deploy-venv-sync round 3

Human guidance:

Verbatim public excerpts of the human's latest guidance (the consumer-specific sentence is kept in the private handoff):

> 1. OK but do add your empty cache and no target git checkout definition in addition of your simpler proposal that I agree to. And update the three Q09 references accordingly.
> 2. agreed.
> 3. agreed.
> 4. agreed.
> Can you then tell me if you can publish round 3? If you can, do so.

Guidance response:

The guidance is applied. The simpler boundary is in place, and the requested
definitions of empty caches and no target Git checkout accompany it rather than
replacing it. The three Q09 references are updated and now say distinct things:
the requirement records the amended offline starting boundary, the plan records
the consumer-delivery responsibility, and the design's Q09 keeps its separate
operator-publication meaning. The items marked agreed in the guidance are
reflected in the plan without further reviewer requests.

### Writer instructions for plan deploy-venv-sync round 3

No further review round is needed. Apply the covered wording during
consolidation, after the human confirms the plan answers. Do not treat this
convergence recommendation as that confirmation.

### Final reviewer decision for plan deploy-venv-sync round 3

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-3 -->

## Round 3 by human - human-confirmation

- Recorded: 2026-09-22T23:15:50+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-3 -->
