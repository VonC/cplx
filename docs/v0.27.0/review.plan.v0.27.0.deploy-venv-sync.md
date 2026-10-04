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

## Round 1 by requestor (exchange 2)

- Recorded: 2026-10-03T22:29:51+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for plan deploy-venv-sync (exchange 2) (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 1

### Requestor assessment for plan deploy-venv-sync (exchange 2) (round 1)

The requirement (AC16, AC17 and Q11), design (original-orchestration section and Q10), topic draft, umbrella item 8 status and validation plan were amended by human decision on 2026-10-03. Treat these as settled context. The same-day human follow-up also settles a deployment-only idempotent stop recheck using the attempt-pinned, already verified stable scripts. It does not use incoming scripts, refetch, resnapshot or alter plain start/recovery.

The plan adds Step 8 A-I while preserving Steps 1-7, AC01-AC15 and earlier decisions. All thirteen findings and the required stop/start flows have requirement, mechanism, task, test and exit coverage. The private mapping holds exact contract details and file bindings; public documents stay generic. No reusable runtime or acceptance-driver change is planned.

Q11-Q20 ask implementation questions only: file split, stable closure preparation/promotion, exact argv fixtures, dependencies, archive identity, HTTP/deadline implementation, inherited lock ownership, phase budgets, measured staging qualification and failure-test allocation. Each has alternatives, pros/cons and a substantive proposed answer. No missing implementation question is currently known; please challenge omissions and whether the proposed answers are sufficiently concrete. No reviewer wording suggestions exist yet for this new exchange.

Pay particular attention to P24 refresh versus final activation, the complete stable helper closure under damaged replaced trees, same-byte replacement and inode reuse, single root-lock ownership through readiness, stop recheck preserving evidence, and staging timing before restoration. Actual AC16/AC17 remain open until separately authorized execution. Fixtures and check mode cannot close them.

### Change summary for plan deploy-venv-sync (exchange 2) (round 1)

The human amendment on 2026-10-03 changed the topic draft, requirement (new AC16/AC17 and Q11), design (original-orchestration mechanisms, cases and Q10), plan (Step 8 A-I, evidence accounting and Q10), validation opening and Step 8 skeleton, and only the umbrella item 8 status. Steps 1-7 validation records remain unchanged.

Private mapping was updated outside the repository with P22-P37, refreshed existing counts, corrected historical source attribution, all sixteen fatal gate owners and concrete rollout stops. The proposed source allocation keeps six focused new helpers, merges runtime verification into existing owners and drops bundled transport/publication changes and account-home entrypoints.

The follow-up human choice adds an idempotent stable stop-only recheck as the first deployment lifecycle action after mode classification, with preserved reservation/archive baseline/checkpoint, no acquisition and nonzero held failure before installation. It is carried through the amended documents and tests.

Q11-Q20 were placed with the open-question workflow. The mandatory Markdown gate passes; all six edited public documents pass sensitive scans, and edited documents contain no em dash. There is no implementation, test/CI/target run, consumer or operations source edit, commit or push.

### Writer response for plan deploy-venv-sync (exchange 2) (round 1)

Writer response:

This is the first round of the Step 8 amendment exchange. Prior settled decisions remain intact. There is no prior answer to accept or dispute in this exchange.

Review the amended plan and its implementation questions against the amended requirement/design as settled context, including the human's stable stop recheck choice. Do not reopen the fixed orchestration contract, one-archive transport, four-input stop prefetch, bootstrap-before-restoration, no-home-code rule, independent selection, mode table, explicit offline recovery or exact-byte qualification.

If a genuine requirement/design gap remains, identify it as such instead of converting it into a plan option. No execution or source change is authorized by this review. Intermediate plan corrections may be applied automatically; convergence must remain a human gate, with no consolidation, implementation, commit or push in this task.

### Reviewer focus for plan deploy-venv-sync (exchange 2) (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1-exchange-2 -->

### LLM nature completion for reviewer (exchange 2)

Recorded nature: `claude`

Completed artifacts:

- `.reviews/a.review-active.specification.plan.v0.27.0.deploy-venv-sync.md`
- `.reviews/a.review-requested.plan.v0.27.0.deploy-venv-sync.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-2 -->

## Round 1 by reviewer (exchange 2)

- Recorded: 2026-10-03T23:03:57+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync (exchange 2) (round 1)

The amended plan carries the settled human decision faithfully: Step 8 parts A to I, the thirteen findings, the stop and start flows with the seven-row mode table, the deployment-only stable stop recheck, AC16 and AC17 accounting, and the separate execution authorizations all match the amended requirement and design. Public text stays generic, and the private mapping binds every handle and all sixteen former responsibilities. Q11 to Q20 are genuine implementation questions with substantive answers, and I agree with each recommended option.

Implementation cannot start from the current text yet. Checking the plan against the consumer sources behind P07, P23, P25 and P26 shows four gaps that change what gets built or tested, plus two smaller corrections:

1. **No activation owner outside the original path.** Q12 activates the stable version "at successful finalization", but finalization is defined only inside P32. Part C bootstraps through the temporary delivery path, where P32 never runs, so the first activation has no owner. Manual or maintenance installs are not covered either.
2. **The stable closure still runs code from the replaced tree.** P25's hold release loads the daemon-ownership helper by an absolute path inside the replaceable application tree. P26's deployment stop loads the prefix environment file and calls the prefix application command wrapper, which enters that tree. P23 loads the same environment file. The claim "stable recovery when application and tools trees are damaged" is therefore not achievable as written. The plan must say which steps must work from the closure alone and which legitimately need application code.
3. **No attempt-state transitions.** The plan defines modes for a fresh attempt but not what stop does when a previous attempt is held and failed. The most likely operator sequence after a role transfer failure (application stopped and held, start never called) is to re-run the deployment or run a stop-and-start recovery. Today both would meet a "conflicting live attempt" refusal. The rule "hold failure releases the hold with the application running" also cannot hold when stop starts from an already stopped installation.
4. **No venue for the Q19 measurement.** The staging-cost gate must close before restoration. Check mode skips the loop, no exact-workload receipt exists, and the managed path cannot run the restored role before restoration. The plan must name a replica venue and its representativeness criteria, and make the first real run re-measure against the same gates.

The two smaller corrections:

- **The staging directory is shared with P07.** The rule that nothing we rely on lives in the role's staging directory conflicts with P07's existing use of that directory: newest-archive selection, completion markers and legacy recovery copies. It needs a precise, tested non-collision invariant.
- **Part G's candidate is not named.** If it is the bootstrap candidate, the first original-path run redeploys the same release, and its effect on the predecessor index must be specified and tested.

A related ordering change also needs to be explicit. The plan parks before stopping, while P26 currently parks after stopping, so the reorder must appear as a P25/P26 edit and be requalified.

None of these reopens the settled requirement or design. They are implementation and test precision inside Step 8. If the writer judges that the closure boundary in gap 2 changes the design's "survive replaced trees" meaning, record that as a design gap for the human instead of resolving it in the plan. Concrete source references for every point are in the private notes named in the writer instructions.

### Question verdicts for plan deploy-venv-sync (exchange 2) (round 1)

**Q11, option A: agree.** The six-file split follows real execution boundaries: pre-toolchain host code, controller Python, and stable lifecycle code. Keep runtime verification in P23. The closure-manifest work of R2 must add the daemon-ownership helper P25 loads, under its own private handle.

**Q12, option A: agree, but the answer is incomplete.** Add the activation owner for every path (R1) and the closure boundary (R2). Wording fix: "because it ordinary wrappers were refreshed" should read "because ordinary wrappers were refreshed".

**Q13, option A: agree.** The fixtures should reproduce the argument vector the orchestration's command module produces after splitting: the launcher path, then the home-relative script, then the optional operand. They should also reproduce the prefix as working directory and non-terminal standard streams, so `nohup` writes no output file and passes on an ignored hangup signal. Add one assertion that the dispatcher and its targets never read HOME to locate code, and that they anchor HOME to the prefix before any application command.

**Q14, option A: agree.** Add two prerequisites before Part C: the Q19 venue measurement and the attempt-state table of the new Q21.

**Q15, option A: agree.** The orchestration renames the previous download to its previous-version name, after deleting the older one, and then copies a new file. Every delivery therefore produces a new file object. A hard-link anchor outside staging, on the same filesystem, keeps the old object allocated, which rules out inode reuse. The fixture should replay that exact sequence: delete the older previous version, rename to previous version, recursive copy, then the identical single-file copy. Refuse when the anchor and staging directories are on different filesystems, and remove the anchor when the attempt ends.

**Q16, option A: agree, with one addition.** Record the TLS policy as an evidenced choice: the trust store must cover the repository certificate, and verification is never silently downgraded. SHA-256 against the independent selection stays the integrity guarantee.

**Q17, option A: agree.** P07 already accepts an inherited lock: with its held flag set, it requires the agreed descriptor to resolve to the root lock file and relocks it. Its legacy recovery sets the same flag before running a historical entry. Reuse exactly that contract, do not invent a new one, and keep the flag-without-descriptor refusal tested.

**Q18, option A: agree.** Include the R7 reorder in the budgets: parking before the stop can consume up to 55 seconds while the application is still running.

**Q19, option A: change requested (R4).** The "existing exact-workload execution receipts" branch has nothing to point at: only check-mode runs exist, and check mode skips the loop. Name the pre-restoration venue and its representativeness criteria, and add the first-real-run re-measurement and its stop rule.

**Q20, option A: agree.** Add the R3 state transitions, the R5 non-collision invariant and the R6 same-release cases to P35's case-to-gate map.

**Missing Q21: attempt-state transitions across stop and start (R3).** Proposed answer: a single P29 state table, covered by P35 tests and described below.

**Missing Q22: which candidate Part G deploys (R6).** Proposed answer: the bootstrap candidate, with explicit same-release tests.

### Requested changes for plan deploy-venv-sync (exchange 2) (round 1)

Requested changes:

1. **R1, activation owner in every path (Q12, Part B, Part C).** Define who activates a prepared stable version, path by path:
   - original-path deployment: P32 finalization, only after the held runtime checks, hold release and same-daemon observation pass;
   - Part C bootstrap through the temporary delivery path, where P32 never runs: the first activation is bound to P23's complete held runtime success in that run, never to P07's install step or P24's refresh;
   - manual or maintenance installs prepare a version but never activate it.

   Never delete or alter a version pinned by a running attempt. Never replace the dispatcher in place, only by atomic rename. Test activation after bootstrap success, no activation after bootstrap failure, and no activation from P24 alone.
2. **R2, stable closure boundary (Q12, Part B tests).** Derive the closure manifest from the transitive source and exec graph of the dispatcher, P31, P32 and the P23/P25/P26 functions they call. Classify every place where that graph enters the replaceable application tree, the tools tree or the prefix environment file. Three such places exist today:
   - P25's hold release loads the daemon-ownership helper from the application tree by absolute path;
   - P26's deployment stop loads the prefix environment file and calls the prefix application command wrapper, which enters the application tree;
   - P23 loads the same environment file.

   For each one, either move the code into the closure and resolve it relative to the closure root, or declare it an application-runtime dependency with a defined outcome: a held failure with evidence, never a guessed process kill. Then replace the broad test claim "stable recovery when application/tools trees are damaged" with a precise one. With those trees damaged or absent, dispatch, mode selection, reservation, hold enter/park/release, observation and invocation of the retained predecessor entry must still work. Stopping or starting application processes may require application code and then fails held. Also state how recovery quiesces survivors of a damaged failed install before the predecessor entry runs its own fully-stopped check.
3. **R3, attempt-state transitions (new Q21; P29, P31, P32, P35).** Add one state table covering: no attempt, reserved, held and stopped awaiting start, installing, failed and held before the installer, failed and held after the installer, consumed, and recovered. For each state, define what a new stop accepts:
   - a fresh deploy selection superseding a terminal failure that never reached the installer;
   - an armed recovery bound to the failed attempt;
   - a plain restart;
   - refusal in every other case.

   Define stop on an already held, stopped installation: idempotent hold and park, nothing to stop, and no "application left running" claim. In that state, a park failure must not release the hold. Bound the selection's validity by the measured role staging duration, so a long staging window cannot expire a valid attempt between stop and start. Test the three operator paths that follow a role transfer failure after stop: re-run of the same deployment, stop-and-start recovery, and maintenance-access recovery.
4. **R4, staging-cost venue (Q19, Part A, Part G).** Remove the "existing exact-workload receipts" branch: none exist, and check mode skips the loop. Name the pre-restoration venue: an isolated, separately authorized replica run of the vendored role tree at its audited fingerprints, with the recorded execution-environment orchestration version. Run it against a non-production host with the same OS family and filesystem, a pre-populated current and previous staging tree, and the real candidate application archive. Record per-task timing, remote operation counts and peak disk. State the margin used to extrapolate to the managed path's controller-to-target latency. Make Part G record the actual staging duration and disk peak against the same gates, with a stop rule if the real figure exceeds the margin.
5. **R5, staging directory shared with P07 (Part B tests, verification-claim wording).** P07 already uses the role's staging directory: newest-archive selection without a record, completion markers for first-candidate legacy detection, and legacy recovery copying predecessor archives there and proving they are newest before running the historical entry. Replace the absolute rule "nothing we rely on lives in staging" with a precise invariant. DVS retention, selection, reservation and journals stay outside staging. Every staging name P07 or a historical entry uses must be disjoint from the set the role renames: each unpacked directory basename at any depth, each top-level member, and the literal download name. None of the role's written names may match P07's or a historical entry's selection patterns. Generate the test from the real candidate archive's member list and repeat it for each new candidate.
6. **R6, Part G candidate and same-release redeployment (new Q22; Part G, P35).** State that Part G deploys the candidate Part C bootstrapped, or explain why a different, separately qualified candidate is needed. For the same candidate, specify and test the same-release redeployment:
   - the predecessor index must not make the release its own predecessor;
   - the attempt's last-working checkpoint is that same release;
   - a failed same-release redeployment recovers to it, not to an older predecessor.
7. **R7, stop and park order (Part B for P25/P26, Q18).** P26's existing deployment stop parks after stopping the stack and daemon. The plan and design park first. List this reorder explicitly as a P25/P26 change. Test "park failure with the application still running releases the hold and restores supervision", and note that it changes the lifecycle order Step 7 qualified, so the new candidate's qualification must cover it.
8. **R8, wording (Q16, Q12).** In Q16, add that TLS verification is an evidenced policy, never silently downgraded, and that SHA-256 against the independent selection remains the integrity guarantee. In Q12, fix "because it ordinary wrappers were refreshed".

### Writer instructions for plan deploy-venv-sync (exchange 2) (round 1)

Read the private reviewer notes at `.reviews/a.dvs-step8-plan-r1.reviewer-notes.md` first. They hold the concrete consumer and orchestration source references behind R2, R5, R7, Q15 and Q17. Keep those references in the private mapping only; the public plan and this transcript stay generic.

Apply the requested changes R1 to R8 to Step 8 and to the open questions:

- Amend the Q12 and Q19 answers.
- Add Q21 (attempt-state transitions) and Q22 (Part G candidate) as new open questions, through the open-question workflow, with options, a recommendation and an answer line each.
- Extend Part B's tests and P35's case-to-gate map for R3, R5, R6 and R7.
- Add the daemon-ownership helper and any other closure member R2 finds to the private file table, under new handles with measured baselines.

Do not reopen requirement Q11, design Q10 or plan Q10. If R2's closure boundary reads to you as changing the design's meaning of "survive replaced trees", say so in the next writer response as a design gap for the human instead of settling it in the plan.

Keep the existing boundaries: no implementation, test, CI, target or operations action, and no commit. Rerun the mandatory Markdown gate and the sensitive scan of the edited public files before publishing the next round.

### Final reviewer decision for plan deploy-venv-sync (exchange 2) (round 1)

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1-exchange-2 -->

## Round 2 by requestor (exchange 2)

- Recorded: 2026-10-03T23:24:38+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (exchange 2) (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 2

### Requestor assessment for plan deploy-venv-sync (exchange 2) (round 2)

The requirement (AC16, AC17 and Q11), design (original-orchestration section and Q10), topic draft, umbrella item 8 status and validation plan were amended by human decision on 2026-10-03 and remain settled context. The deployment-only idempotent stop recheck uses attempt-pinned previously verified stable scripts, with no refetch, resnapshot or incoming-code execution.

Round 1 identified implementation gaps. The amended Step 8 now names activation owners for every path, derives the stable helper closure including P38, distinguishes runtime dependencies, specifies safe survivor handling, and gives P29 one durable attempt-state table. It adds an authorized representative replica measurement before bootstrap, actual-run remeasurement, archive-derived staging non-collision and same-release predecessor/checkpoint tests. The park-before-stop reorder is explicit and requires fresh qualification.

Q11-Q20 retain option A with strengthened answers. Q21 (state transitions) and Q22 (Part G candidate) were placed through the open-question workflow with alternatives, pros/cons and substantive recommended answers. No further missing implementation question is currently known. All R1-R8 edits and the related Q13/Q15/Q17 fixture precision were applied. Please check that the transition table, survivor boundary and activation receipts are sufficiently concrete.

The stable-control boundary refines implementation rather than changing the design: dispatch, hold/observation and retained-entry invocation survive missing trees; executing application code requires verified runtime or a held refusal. Unknown survivors never authorize guessed signals. All prior acceptance criteria and decisions are preserved. Actual AC16/AC17 stay open and no execution is authorized.

### Change summary for plan deploy-venv-sync (exchange 2) (round 2)

Since round 1, amended only Step 8 in the plan, its question companion through oqm, the Step 8 validation expectations and private integration mapping. Earlier Step 1-7 records and settled requirement/design remain unchanged.

Added activation owner and atomic pinned-version rules; P38 daemon ownership (57 lines at the mapped consumer revision); transitive dependency and runtime-crossing table; verified-survivor quiescence; single attempt-state table and three transfer-failure operator routes; selection/reservation deadline distinction; representative replica timing/disk/latency margin and first-real-run remeasurement; per-candidate staging name/glob invariant; same-release Part G checkpoint/index behavior; explicit park-before-stop reorder; HOME/nohup, TLS, identity-anchor and inherited-lock precision.

Q11-Q20 answers were revised and Q21/Q22 added using the canonical question placement tool. New source files remain the six focused helpers; P38 is an existing helper, not a seventh new helper. Runtime verification remains with P23; no new transport, registry schema, publication or home-entry code is proposed.

The original human amendment to draft, requirement AC16/17/Q11, design/Q10, umbrella status and validation remains settled. There is no implementation, test/CI/target action, consumer/operations edit, commit or push.

### Writer response for plan deploy-venv-sync (exchange 2) (round 2)

Writer response:

Accepted R1-R8 and the related question-verdict refinements. R1 now assigns bootstrap activation to P23's complete success and original activation to P32; P07/P24/manual maintenance prepare only. R2 inventories actual transitive crossings, adds P38 and stable observer bridges, and distinguishes control survival from application-runtime availability. P26 may signal only exact receipt-backed survivors after identity recheck; ambiguous survivors fail held before recovery installation.

R3 is implemented as the single P29 table and Q21, with terminal-owner evidence, fresh retry selection, held-entry semantics and staging-inclusive reservation deadlines. R4 now requires a separately authorized representative replica before C with recorded environment/source identities, concrete margins and Part G remeasurement. R5 names the legacy staging uses and derives a per-candidate non-collision check. R6/Q22 binds G to C's same candidate and exact checkpoint. R7 names the lifecycle reorder and its requalification. R8 corrects wording and makes TLS policy explicit.

There is no explicit disagreement and no unresolved requirement/design choice identified. The closure wording does not promise successful application execution from a missing tree; it implements the design's stable recovery control path with safe held failure when identity or quiescence cannot be proven. Please flag any remaining mismatch instead of weakening the settled contract.

All concrete source references remain private. No orchestration-side change or option is introduced. Intermediate implementation-plan corrections may continue automatically. At convergence retain the answer and stop for the human without consolidation, implementation, commit or push.

### Reviewer focus for plan deploy-venv-sync (exchange 2) (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2-exchange-2 -->

## Round 2 by reviewer (exchange 2)

- Recorded: 2026-10-03T23:30:56+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync (exchange 2) (round 2)

Round 2 applies R1 to R8 thoroughly:

- the activation owner is now defined for every path;
- the stable-control boundary and the verified-survivor rule are precise and keep the existing "no guessed kill" policy;
- the replica venue has concrete headroom, a concrete latency adjustment and a re-measurement during the first real run;
- the staging non-collision invariant is generated from the real archive;
- the park-before-stop reorder is explicit and requalified;
- the HOME, nohup, TLS, identity-anchor and inherited-lock details match the consumer sources.

Q11 to Q20 now read well and I agree with them. Q21 and Q22 are the right questions with the right options.

Checking the new transition table and Q22 against the orchestration's handlers and the existing installer's rollback branch shows two remaining correctness gaps and one small test gap. All three are implementation-level and none reopens the requirement or design.

1. **A failed stop cannot terminalize itself, and a failure before the hold has no state of its own.**
   - The orchestration's handlers only delete a controller work path and nothing notifies them. When our stop task fails, it is therefore the last action on the host, and start cannot arrive from that job. Yet the table keeps such an attempt "Reserved" until an operator terminalizes it through the maintenance channel. That is the most common transient failure: a fetch failure at stop, with the application still running and untouched.
   - The same failure then maps to "failed and held before installer", whose row refuses a plain restart, even though nothing is held.
   - The stop target should terminalize its own handled failures, and a separate "failed before hold, application running" state should admit a fresh deploy or a plain restart.
2. **An attempt-bound recovery can step back one release too far.**
   - The installer's rollback switch recovers to the pending target only while a pending record exists. Without one, it takes the index predecessor. A successful rollback deletes the pending record, and the forward entry leaves it in place on failure but never rolls back by itself.
   - A second recovery for the same failed attempt therefore rolls back to N-1. That happens, for example, when the first rollback succeeded but the post-recovery runtime checks failed and recovery is armed again. In Q22's same-release case, the attempt checkpoint is N, so Q22's promise to recover to it does not hold on that path.
   - The bound recovery must choose its action from the persisted installer state and the checkpoint, and never reach the index-predecessor branch.
3. **The bridge change needs regression tests.** Moving recorded-daemon observation into the stable hook bridges is sound and matches the existing runtime watcher's logic. Because those bridges are the unit's start and pre-start commands, fixtures must prove that the non-held path still behaves exactly as today's.

Concrete source references are in the private round 2 notes named in the writer instructions.

### Question verdicts for plan deploy-venv-sync (exchange 2) (round 2)

**Q11 to Q20, option A: agree as revised.** The round 1 points are all integrated. No further change, apart from the R11 test cases that also belong in Q20's case map.

**Q21, option A: agree, with R9.** Centralizing the table in P29 is right. Add these to the answer:

- the stop target terminalizes its own handled failures, because no orchestration task can run on the host after a failed stop;
- a distinct "failed before hold, application running" state admits a fresh deploy or a plain restart without recovery;
- external terminalization proof stays mandatory only for a stop that exited 0 (held and stopped, awaiting start) and for killed or interrupted processes (reserved, installing).

**Q22, option A: agree, with R10.** Bind the C and G candidates as proposed. Add that an attempt-bound recovery selects its action from the persisted installer state and the attempt checkpoint, and never uses the installer's no-pending index-predecessor branch:

- **pending record present:** the rollback is directed by the pending record, toward the checkpoint;
- **no pending record, and the installed identity equals the checkpoint:** no installer call, only the held plain-start checks against the checkpoint;
- **anything else:** refuse and stay held.

A rollback to the previous successful release remains a separate selection, bound to a consumed checkpoint (the "Consumed" row). Test a repeated recovery after a successful rollback followed by failed runtime checks.

**No other missing question.** R11 is a test addition, not a new decision.

### Requested changes for plan deploy-venv-sync (exchange 2) (round 2)

Requested changes:

1. **R9, self-terminalizing stop and a running pre-hold state (state table, Q21, P29/P31/P35).**
   - Record in Step 8 that the orchestration runs nothing on the host after a failed stop task: its handlers only delete a controller work path and nothing notifies them. P31 therefore terminalizes its own handled failures before exiting nonzero:
     - a failure before the hold records a new state, "failed before hold, application running";
     - a failure after the hold records "failed and held before installer".
   - Keep "Reserved" and "Installing" for killed or interrupted processes. Require the external terminalization proof only for those two states and for "held and stopped, awaiting start", where the stop exited 0 and cannot know the role's fate.
   - The new running state admits a fresh deploy (including the same candidate) or an explicit plain restart. It needs no recovery and never invents a hold.
   - Test in P35 that a fetch failure at stop leaves the application running and untouched, then that an immediate re-run of the same deployment with a fresh selection is accepted without maintenance-channel terminalization.
2. **R10, recovery action chosen from installer state, never the index-predecessor fallback (Recovery mode, transition table, Q22, P32/P35).** An attempt-bound recovery reads the persisted installer state and the attempt checkpoint before acting:
   - **pending record present:** invoke the rollback switch, which follows the pending target, and verify that target equals the checkpoint;
   - **no pending record, installed identity equal to the checkpoint:** do not call the installer; run the held plain-start checks against the checkpoint;
   - **no pending record, any other installed identity:** refuse and stay held;
   - **failure before the installer:** keep the existing checkpoint restart.

   Never let an attempt-bound recovery reach the installer's no-pending branch, which selects the index predecessor. Rolling back to the previous successful release remains a separate explicit selection bound to a consumed checkpoint. Test in P35:
   - a first rollback that succeeds while the runtime checks fail, followed by a second armed recovery: the installed release stays N, never N-1;
   - the same sequence for the same-release case of Q22;
   - a recovery armed for a preinstaller failure, which never calls the rollback switch.
3. **R11, regression tests for the stable hook bridges (stable control closure table, P34/P35).** The bridges are the unit's start and pre-start commands, so test their non-held paths:
   - with no record, or a record from a previous boot, they exec the installed runtime watcher and pre-start hook exactly as today, with unchanged arguments and no environment loaded by the bridge;
   - a live recorded daemon is observed through the closure's P38 without loading the application environment;
   - the held state parks as today.

   Keep the existing reboot status (untested, nonblocking), but prove the fallback cannot block the first unit start after a boot.

### Writer instructions for plan deploy-venv-sync (exchange 2) (round 2)

Read the private notes at `.reviews/a.dvs-step8-plan-r2.reviewer-notes.md` first. They hold the orchestration handler evidence and the installer line references behind R9 to R11. Keep those references in the private mapping; the public plan and this transcript stay generic.

Apply R9 to the Step 8 transition table, its explanatory text and the Q21 answer. Apply R10 to the Step 8 recovery-mode text, the table rows that admit recovery and the Q22 answer. Apply R11 to the stable control closure table and the P34/P35 test lists. Then update P35's case-to-gate map and Q20's case list for all three. Change nothing else.

Keep the existing boundaries: no implementation, test, CI, target or operations action, and no commit. Rerun the mandatory Markdown gate and the sensitive scan of the edited public files before publishing the next round. If these three edits are applied as written, I expect to recommend convergence in round 3.

### Final reviewer decision for plan deploy-venv-sync (exchange 2) (round 2)

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2-exchange-2 -->

## Round 3 by requestor (exchange 2)

- Recorded: 2026-10-03T23:40:23+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (exchange 2) (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 3

### Requestor assessment for plan deploy-venv-sync (exchange 2) (round 3)

The requirement (AC16, AC17 and Q11), design (original-orchestration section and Q10), topic draft, umbrella item 8 and validation plan remain settled human context from 2026-10-03. Deployment-only stable stop recheck is unchanged.

Round 2 identified two implementation correctness gaps and a regression-test gap. R9 is applied: handled stop failures terminalize themselves after owned children exit; a distinct running pre-hold failure admits fresh deploy/plain restart without maintenance terminalization. External proof remains for interrupted/killed reserved or installing states and successful stop awaiting start.

R10 is applied: attempt-bound recovery validates pending recovery against the checkpoint before invoking rollback. No pending plus installed checkpoint runs held checks only; other identities refuse held. Preinstaller recovery never calls rollback. Repeated recovery cannot reach the index-predecessor fallback. R11 adds all non-held and held stable bridge regressions without claiming reboot execution.

Q11-Q22 retain option A. Q20's case map and Q21/Q22 recommendations and answers incorporate R9-R11 through the canonical question tool. No missing implementation question, unresolved requirement/design choice or explicit disagreement is identified. Reviewer wording was applied with an explicit actual-state rule for an already held entry or safely unwound fresh hold. AC16/AC17 remain open and no execution is authorized.

### Change summary for plan deploy-venv-sync (exchange 2) (round 3)

Since round 2, changed only Step 8's tests, lifecycle/recovery text, stable bridge row and attempt transitions; Q20-Q22 through the question companion; and the private mapping with concrete source evidence. Earlier steps, settled requirement/design/draft, umbrella and validation records are unchanged this round.

Added handled-stop self-terminalization, a running failure state and immediate same-candidate retry case. Added pending/checkpoint recovery selection, zero-installer recovery when the checkpoint is already installed, refusal for mismatched state, and repeated-recovery regression including same-release deployment. Clarified that forward failure restores the local snapshot and retains pending state rather than invoking rollback automatically. Added four stable bridge paths, preserving runtime fallback exec arguments and no bridge-loaded environment.

No new source handle or question was needed. Public documents remain generic. This is documentation only: no implementation, tests, CI, target access, consumer/operations edit, commit or push.

### Writer response for plan deploy-venv-sync (exchange 2) (round 3)

Writer response:

Accepted R9-R11 without disagreement. The state table and Q21 now let P31 terminalize handled failures, distinguish running from held failures, and retain external termination proof only for successful stop awaiting start and interrupted/killed owners. Existing held entries never release their hold; safely unwound fresh hold failure records running only after restored supervision is verified.

The recovery mode, recovery-admitting rows, Part I and Q22 now select from persisted installer state and exact checkpoint under the root lock. A matching pending target is checked before rollback; no pending plus installed checkpoint means held checks without the installer; any other state refuses held. A preinstaller failure never calls rollback, and separately armed intentional rollback remains distinct. P35 includes repeated recovery after rollback success but failed runtime checks, both version-advance and same-release cases.

The stable closure row and P34/P35 map now test no-record and previous-boot fallbacks with unchanged watcher/pre-start arguments, live-daemon observation through P38 without the application environment, and held parking. The actual reboot status stays untested/nonblocking.

Q20 includes all requested regression cases. Private notes retain source references. Nothing reopens the fixed orchestration contract or settled human choices. If converged, retain the answer and stop at the human gate without selecting either label.

### Reviewer focus for plan deploy-venv-sync (exchange 2) (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3-exchange-2 -->

## Round 3 by reviewer (exchange 2)

- Recorded: 2026-10-03T23:43:11+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync (exchange 2) (round 3)

Round 3 applies R9 to R11 correctly and consistently, in the stop and recovery text of Part B, Part I, the transition table, the bridge row, the P34/P35 test map and the Q20 to Q22 answers:

- a handled stop failure terminalizes itself after its owned children exit, and the new "failed before hold, application running" state admits an immediate fresh deploy or plain restart;
- external terminalization proof is now limited to the states where it is actually needed;
- an attempt-bound recovery chooses its action from the persisted installer state and the checkpoint, never calls the rollback switch for a preinstaller failure, and can no longer reach the index-predecessor fallback, including on a repeated recovery and in the same-release case;
- the stable hook bridges keep today's fallback, with all four paths tested.

All twelve open questions are now settled in substance, and I agree with every recommended answer. Nothing reopens the requirement or design, and the plan remains generic in public with concrete bindings in the private mapping.

One precision point remains, and it is wording only. The pending-target check compares the installer's recovery value with the attempt checkpoint. That value is not always a release identity: the installer also writes a marker for the retained historical predecessor, and a marker for "no target". As worded, a strict identity comparison would refuse every bound recovery to the historical predecessor format, which AC17 requires. The covered wording below makes the comparison explicit. Implementation can proceed from the plan once it is applied, so I recommend convergence.

### Question verdicts for plan deploy-venv-sync (exchange 2) (round 3)

**Q11 to Q20, option A: agree.** These are settled as revised in rounds 1 and 2. Q20's case map now includes the self-terminalized retry, the pending and checkpoint mismatch refusals, the repeated-recovery regression and all four bridge paths.

**Q21, option A: agree.** The handled-failure self-terminalization, the separate running pre-hold state and the narrowed external terminalization proof are exactly what the implementation needs.

**Q22, option A: agree, with the covered wording.** The recovery decision is correct. Apply the covered wording so the pending-target comparison also handles the installer's historical-predecessor and no-target markers.

**No missing question.**

### Convergence evidence for plan deploy-venv-sync (exchange 2) (round 3)

Covered wording:

In Step 8 Part B's attempt-bound recovery text, in the "Failed and held after installer" row of the transition table, and in the Q22 recommendation and answer, replace "validate its association and recovery target against that checkpoint" and "validate pending recovery target equals the checkpoint" with:

> validate its association and recovery value against the attempt checkpoint: a release identity must equal a release checkpoint; the installer's historical-predecessor marker is accepted only when the checkpoint is the retained historical predecessor; its no-target marker refuses held

Add to the P35 list in Q20 and in the Step 8 test map: "a bound recovery to the historical predecessor format through the pending marker, and a no-target marker refused held".

Convergence rationale:

Every in-scope implementation decision for Step 8 is settled, and the plan text implements each of them:

- file allocation and the stable closure;
- activation owners;
- exact-argument fixtures;
- part ordering and gates;
- the identity anchor for redelivery detection;
- bounded acquisition;
- inherited lock ownership;
- deadlines;
- the replica measurement venue;
- the case-to-gate map;
- attempt-state transitions;
- the same-release first run.

All round 1 and round 2 requested changes are applied without disagreement. The only remaining edit is the covered wording that makes the pending recovery-value comparison explicit for the historical predecessor and no-target markers. It clarifies an existing decision and introduces none. The requirement and design remain untouched. AC16 and AC17 stay open until separately authorized execution, which this plan correctly does not grant.

### Writer instructions for plan deploy-venv-sync (exchange 2) (round 3)

Apply the covered wording to the Step 8 recovery text, the "Failed and held after installer" row, Q22 and the Q20/P35 test map. The installer's recovery-value format behind it is cited in `.reviews/a.dvs-step8-plan-r3.reviewer-notes.md`; keep those references private.

This answer recommends convergence. It does not authorize consolidation: present the human gate with both registered choices and wait for the human's selection. Do not consolidate, implement, run tests, touch the consumer or the operations repository, commit or push in this task.

### Final reviewer decision for plan deploy-venv-sync (exchange 2) (round 3)

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-3-exchange-2 -->

## Round 3 by human - human-confirmation (exchange 2) (round 3)

- Recorded: 2026-10-04T00:37:28+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Revise and review again
Outcome: another-round
Guidance: Human decision on 2026-10-04, given at the round 3 convergence gate.

**Revise and review again.** First apply the round 3 covered wording on the pending recovery value. Then make the following changes, and keep everything already settled in Steps 1 to 8 intact.

**1. Step 8 scope is explicit.** Step 8 covers only the qualification environment, the one the temporary delivery task can still bootstrap before restoration. Say so in Step 8's analysis and intent and in its completion criteria: Step 8 does not cover a first-time installation, and it does not cover a production deployment. Both move to Step 9.

**2. Add plan Step 9, which is mandatory: deliver first-time and production installations through the unchanged original orchestration.**

- The topic is not complete, and its umbrella item stays pending, until Step 9 is validated.
- Step 9 starts only after Step 8 has proven the original path on the qualification environment, that is, after AC16 and AC17 are closed by actual evidence.
- The fixed-contract rule applies unchanged: conform to the orchestration exactly as it exists, and request no variable, role, template, job or operations change.

**3. Step 9 must address at least:**

- **Bootstrap without the temporary delivery task.**
  - Neither a new environment nor production has that task. The orchestration's first action on the host is our stop, through the prefix dispatcher, so the dispatcher and the stable stop and start scripts must already be installed.
  - Define a bootstrap route through existing authenticated maintenance access, from independently verified bytes, before the first original-path run.
  - Preferred direction: install only the stable scripts, with no application, and allow a first activation only when no stable version exists yet. If a better route exists, list it for the human as an open design choice; do not settle it silently.
- **First-time installation.** Nothing is installed or running, and there is no last working release and no recovery target. Define:
  - a stop with nothing to stop;
  - start's deploy mode on an empty prefix;
  - the installer's first-install path;
  - what a refusal or a failure leaves behind when there is nothing to restart.

  The environment provisioning the operations team must already have done becomes evidence gates, never change requests: the account, the scripts folder, the staging folder, and the service unit with its expected identity.
- **Production, from the historical shipped-environment release it currently runs:**
  - the unchanged orchestration's production approval step pauses before our stop for up to two hours, until the operations pilot validates. Our deployment pipeline's time budget and the selection's freshness must cover that wait;
  - production rejects snapshot coordinates, so only published, qualified release coordinates are deployable;
  - a managed production job and template that run the restored production playbook must exist, as an evidence gate;
  - rollback to the historical release depends on its archives and completion markers being present in staging at the first new-format install. Inspect this read-only, and define a verified route that retains the historical release if they are absent, before any production upgrade;
  - our stop's service-unit identity check must come from evidence gathered on each environment, never be assumed from the qualification environment;
  - the health checks used by refusal and recovery must match the historical release's runtime interfaces;
  - target access to the artifact repository from production, and the production arming channel (who has existing access to the production application account), are separate evidence gates.
- **Rehearsals before production.** Run a first-time rehearsal on an empty prefix and a historical-release upgrade-and-rollback rehearsal on a production-like prefix, each separately authorized, before any production run. Production execution needs its own explicit human authorization and still goes through the operations team's approval step.

**4. Documents to amend.**

- The requirement: new acceptance criteria for first-time delivery and production delivery, plus a requirement clarification recording this decision.
- The design: the bootstrap route, the first-install and production flows, per-environment identity evidence, and historical-release checks.
- The validation plan: a Step 9 skeleton marked not started.

Implementation choices become new plan questions. Any genuinely open design choice, such as the bootstrap route, is listed for the human in the writer response.

Concrete hosts, accounts, paths, versions and source lines are in `.reviews/a.dvs-step9-scope.private-notes.md`. Keep them private, and keep the public documents and this transcript generic.

No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

<!-- review-entry-id: human-confirmation-round-3 -->

## Round 4 by requestor

- Recorded: 2026-10-04T00:54:11+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (exchange 2) (round 4)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 4

### Requestor assessment for plan deploy-venv-sync (exchange 2) (round 4)

The plan is ready for round 4 specification review of implementation details.

Questions Q11-Q22 retain their round 3 answers and covered wording. The typed
pending recovery rule is already applied: release identity must equal the
checkpoint, the historical marker requires a retained historical checkpoint,
and a no-target marker refuses held. It was verified and not duplicated.

The human's 2026-10-04 guidance adds mandatory Step 9 after actual AC16/AC17
closure and limits Step 8 explicitly to qualification. Requirement Q12 and
AC18/AC19, design Q11, the topic draft and the not-started validation skeleton
now carry that scope. The umbrella row stays pending. Earlier Steps 1-8 behavior
and validation records remain intact.

New questions Q23-Q30 cover implementation only: existing-owner allocation,
explicit empty/retry states, historical retention, profile parsing, timing,
managed routing, fixture leaves and gate sequencing. Each has two options,
pros/cons, a recommendation and an answer. The recommended answers are sufficient
for these implementation choices; no additional implementation question is known.
Please examine first-install retry after installer success but failed readiness,
the verified historical-retention route, first-activation interruption/races and
production approval/admission budget composition in particular.

The preferred scripts-only bootstrap route from the human guidance is used.
No better route is established and no separate design alternative is silently
selected. Environment access, unit identity, historical pair availability,
supported historical health evidence and existing managed routing remain
execution evidence gates, not questions that a plan reviewer can waive.

### Change summary for plan deploy-venv-sync (exchange 2) (round 4)

Since round 3, applied the human-confirmed scope extension and retained the
already applied pending-recovery wording.

- The topic draft records the dated first-time/production decision.
- The requirement adds the new behavior section, AC18/AC19 and Q12.
- The design adds scripts-only bootstrap, a guarded first activation, private
  environment profiles, empty-prefix and provisional-index retry behavior,
  exact historical retention and health checks, and production approval/freshness.
- The plan states Step 8's qualification-only scope in its goals, analysis and
  completion criteria. Mandatory Step 9 parts A-G, the empty-prefix table,
  file owners, tests, line budgets, execution gates and AC18/AC19 accounting
  follow it. New implementation questions Q23-Q30 were placed through the
  canonical open-question workflow, preserving Q11-Q22.
- The validation plan keeps Steps 1-7 records unchanged, clarifies Step 8 scope
  and adds Step 9 as not started. The existing umbrella item stays pending.
- The private mapping records concrete source facts and proposed P39-P42 paths;
  public documents and this review remain generic.

No implementation, test, pipeline, target observation, operations action, commit
or push occurred. Only document edits, documentation hygiene and review workflow
commands belong to this round. No orchestration-side change is proposed.

### Human guidance and writer response for plan deploy-venv-sync (exchange 2) (round 4)

Human guidance:

Human decision on 2026-10-04, given at the round 3 convergence gate.

**Revise and review again.** First apply the round 3 covered wording on the pending recovery value. Then make the following changes, and keep everything already settled in Steps 1 to 8 intact.

**1. Step 8 scope is explicit.** Step 8 covers only the qualification environment, the one the temporary delivery task can still bootstrap before restoration. Say so in Step 8's analysis and intent and in its completion criteria: Step 8 does not cover a first-time installation, and it does not cover a production deployment. Both move to Step 9.

**2. Add plan Step 9, which is mandatory: deliver first-time and production installations through the unchanged original orchestration.**

- The topic is not complete, and its umbrella item stays pending, until Step 9 is validated.
- Step 9 starts only after Step 8 has proven the original path on the qualification environment, that is, after AC16 and AC17 are closed by actual evidence.
- The fixed-contract rule applies unchanged: conform to the orchestration exactly as it exists, and request no variable, role, template, job or operations change.

**3. Step 9 must address at least:**

- **Bootstrap without the temporary delivery task.**
  - Neither a new environment nor production has that task. The orchestration's first action on the host is our stop, through the prefix dispatcher, so the dispatcher and the stable stop and start scripts must already be installed.
  - Define a bootstrap route through existing authenticated maintenance access, from independently verified bytes, before the first original-path run.
  - Preferred direction: install only the stable scripts, with no application, and allow a first activation only when no stable version exists yet. If a better route exists, list it for the human as an open design choice; do not settle it silently.
- **First-time installation.** Nothing is installed or running, and there is no last working release and no recovery target. Define:
  - a stop with nothing to stop;
  - start's deploy mode on an empty prefix;
  - the installer's first-install path;
  - what a refusal or a failure leaves behind when there is nothing to restart.

  The environment provisioning the operations team must already have done becomes evidence gates, never change requests: the account, the scripts folder, the staging folder, and the service unit with its expected identity.
- **Production, from the historical shipped-environment release it currently runs:**
  - the unchanged orchestration's production approval step pauses before our stop for up to two hours, until the operations pilot validates. Our deployment pipeline's time budget and the selection's freshness must cover that wait;
  - production rejects snapshot coordinates, so only published, qualified release coordinates are deployable;
  - a managed production job and template that run the restored production playbook must exist, as an evidence gate;
  - rollback to the historical release depends on its archives and completion markers being present in staging at the first new-format install. Inspect this read-only, and define a verified route that retains the historical release if they are absent, before any production upgrade;
  - our stop's service-unit identity check must come from evidence gathered on each environment, never be assumed from the qualification environment;
  - the health checks used by refusal and recovery must match the historical release's runtime interfaces;
  - target access to the artifact repository from production, and the production arming channel (who has existing access to the production application account), are separate evidence gates.
- **Rehearsals before production.** Run a first-time rehearsal on an empty prefix and a historical-release upgrade-and-rollback rehearsal on a production-like prefix, each separately authorized, before any production run. Production execution needs its own explicit human authorization and still goes through the operations team's approval step.

**4. Documents to amend.**

- The requirement: new acceptance criteria for first-time delivery and production delivery, plus a requirement clarification recording this decision.
- The design: the bootstrap route, the first-install and production flows, per-environment identity evidence, and historical-release checks.
- The validation plan: a Step 9 skeleton marked not started.

Implementation choices become new plan questions. Any genuinely open design choice, such as the bootstrap route, is listed for the human in the writer response.

Concrete hosts, accounts, paths, versions and source lines are in `.reviews/a.dvs-step9-scope.private-notes.md`. Keep them private, and keep the public documents and this transcript generic.

No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Writer response:

Accepted the round 3 covered wording and all settled Step 8 answers. The pending
recovery type rule remains explicit in the plan, fixtures and private mapping.
The exact human choice was recorded with the supplied guidance file unchanged.

Applied every new scope item: qualification-only Step 8; mandatory Step 9 after
actual AC16/AC17; no completion before AC18/AC19; existing-access scripts-only
bootstrap; explicit empty/no-predecessor behavior and safe retry; production's
actual historical retention and compatible checks; independent environment,
managed-route, repository-access and arming gates; two-hour approval-aware timing;
release-only production coordinates; separate rehearsals and production authority.

Design choices for the human: no alternative bootstrap route is proposed. The
preferred scripts-only route in the guidance is the documented direction, with
first activation limited to the no-stable-version case and existing-version
activation rules preserved. If evidence disproves its feasibility, the plan
stops and reports alternatives for a human design decision. Exact historical
archives and adequate identity/health evidence are required; absence blocks
production rather than silently substituting another pair or a weaker check.

Implementation recommendations are option A for Q23-Q30. P28 retains control
installation, P29 retains transitions, P30 retains controller validation, P23
retains runtime checks; new P39 isolates historical preparation and P40-P42
separate new fixture responsibilities. A first-install index written before
runtime readiness is provisional and cannot manufacture a last-working release.

There is no disagreement with the preceding reviewer. Please review the added
implementation details with requirement Q12/design Q11 as human-directed scope,
while retaining all prior Step 8 guarantees. No execution or consolidation is
authorized; stop at the next convergence gate.

### Reviewer focus for plan deploy-venv-sync (exchange 2) (round 4)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-10-04T01:03:19+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync (exchange 2) (round 4)

Round 4 applies the human guidance faithfully:

- Step 8 is explicitly qualification-only.
- Step 9 is mandatory, starts only after AC16 and AC17 are actually closed, and keeps the topic and umbrella item pending.
- Requirement Q12 with AC18 and AC19, and design Q11, carry the decision.
- The scripts-only bootstrap with a guarded first activation is used as the guidance's preferred direction and is not silently replaced.
- The empty-prefix table handles a missing predecessor honestly, including the provisional index after a failed first readiness.
- Historical retention never fabricates completion markers.
- The production approval wait, release-only coordinates, managed routing, access and arming are evidence gates, never change requests.

Q23 to Q30 are genuine implementation questions, and I agree with every recommended option. Q24, Q27 and Q30 are particularly well constructed.

Implementation can still not be planned to completion. The plan does not say where the two rehearsals run, and that may make AC18 unachievable as written. Some smaller precision is also missing around the production bootstrap:

1. **No rehearsal venue.** AC18 requires a first-time install through the unchanged original path, and Part D a production-like historical rehearsal. Both need a managed orchestration job and template plus a provisioned service unit with the expected identity. The only managed route evidenced so far is the qualification environment's. Our own build host has neither a system unit nor a managed job, so it can only provide fixture or replica evidence. Unless the qualification environment itself is used (emptied for AC18, then set to the historical release for Part D, each under authorization and with its current release retained for restoration), a new provisioned environment is required. That is operations provisioning, outside this effort's no-request boundary. This is a choice for the human, and the plan must expose it rather than leave it implicit.
2. **The production bootstrap could change the running service's start hooks.** The existing hold helper installs the unit's hook bridges when the deployment hold is entered, which is at the approved stop. The plan says the scripts-only bootstrap leaves the running historical release untouched, but it never states that the bootstrap must not replace the unit's start and pre-start hooks. Doing so would change the running production service outside the pilot's approval window.
3. **The first-activation publication order is unstated.** The orchestration reaches our code only through the prefix dispatcher, so publishing it last makes a concurrent original-path run fail closed.
4. **One retry interleaving is untested.** After a first install whose readiness failed, a retry that fails after installer entry writes a pending recovery value naming the provisional release. Step 8's typed checkpoint rule already refuses that recovery, but no test covers it.

Concrete source references are in the private round 4 notes named in the writer instructions.

### Question verdicts for plan deploy-venv-sync (exchange 2) (round 4)

**Q11 to Q22, option A: agree as settled in rounds 1 to 3.** The round 3 covered wording is present.

**Q23, option A: agree, with R14.** Add the publication order: verify the closure and the version pointer first, publish the dispatcher last by atomic rename, and test a concurrent original-path stop at each point.

**Q24, option A: agree, with R15.** Add a test where a retry fails after installer entry with a pending value naming the provisional release: recovery is refused under the typed checkpoint rule.

**Q25, option A: agree.** Retention prepared ahead of the first new-format install makes the installer's existing first-candidate logic select the historical predecessor without fabricated markers. Keep the "exact installed pair" proof as the precondition.

**Q26, option A: agree.** Proving that missing modern API fields cannot select historical mode is the right safeguard.

**Q27, option A: agree.** The admission window before the stop and the execution deadline after it are cleanly separated, and the full approval wait is tested with a controlled clock.

**Q28, option A: agree.** An absent production route correctly stays an evidence stop.

**Q29, option A: agree.**

**Q30, option A: agree, with R12.** The ledger needs a venue entry for Parts C and D, gated by the human's venue decision.

**Missing decision, for the human (R12), not a plan question: where AC18 and Part D run.** Recommended direction: the qualification environment, emptied for AC18 and then set to the exact historical pair for Part D. Each step is separately authorized, and the current release is retained offline to restore it. The alternative is a separately provisioned environment, which needs an operations request this effort does not make.

### Requested changes for plan deploy-venv-sync (exchange 2) (round 4)

Requested changes:

1. **R12, rehearsal venue (Step 9 Parts A, C and D, the Q30 ledger, AC18/AC19 accounting).** State the venue requirements for both rehearsals: a managed job and template that run the restored original playbook, a provisioned account, folders and service unit with evidenced identity, and maintenance access.
   - Record that the only evidenced managed route is the qualification environment's, and that our own build host can only provide fixture or replica evidence, never AC18 or Part D.
   - List this choice for the human in the writer response; do not settle it in the plan:
     - **(a)** use the qualification environment, emptied for AC18 under separate authorization with its current release retained offline for restoration, then set to the exact historical pair for Part D through the proven recovery route or an exact historical reinstall;
     - **(b)** use a separately provisioned environment, which requires operations provisioning outside this effort's no-request boundary.
   - Until the human decides, Parts C and D stay blocked in the ledger, with a stop rule.
2. **R13, production bootstrap leaves the running service's hooks untouched (Step 9 Parts B and F; Part D for the production-like prefix).**
   - The scripts-only bootstrap writes only the stable closure, the version pointer, the dispatcher and our control folders. It never replaces the unit's start or pre-start hook paths while the historical release runs.
   - The hook bridges are installed, as today, when the deployment hold is entered at the first approved stop.
   - Test that a unit restart in the window between bootstrap and the first approved stop runs the historical runtime exactly as before. Test also that the first stop's bridging of the historical hooks follows the evidenced per-environment profile.
   - The empty-prefix case of Part C, where no release runs, may still establish hold-aware hooks at bootstrap, as the plan says.
3. **R14, first-activation publication order (Step 9 Part B, Q23, P40).**
   - Guarded first activation verifies the complete closure and publishes the version pointer first. It publishes the dispatcher last, by atomic rename.
   - A concurrent original-path stop before that point fails closed: the role fails at stop, and the application is untouched or the prefix stays empty.
   - Test each interleaving: before the closure, between the pointer and the dispatcher, and after.
4. **R15, provisional-index retry (empty-prefix table, Q24, P41).** Add a case: a retry fails after installer entry after an earlier first install whose readiness failed. Its pending recovery value names the provisional release. Bound recovery refuses under the typed checkpoint rule, because the first-install checkpoint has no predecessor. The attempt stays held and nonzero, and no restart or rollback runs.

### Human guidance response for plan deploy-venv-sync (exchange 2) (round 4)

Human guidance:

Human decision on 2026-10-04, given at the round 3 convergence gate.

**Revise and review again.** First apply the round 3 covered wording on the pending recovery value. Then make the following changes, and keep everything already settled in Steps 1 to 8 intact.

**1. Step 8 scope is explicit.** Step 8 covers only the qualification environment, the one the temporary delivery task can still bootstrap before restoration. Say so in Step 8's analysis and intent and in its completion criteria: Step 8 does not cover a first-time installation, and it does not cover a production deployment. Both move to Step 9.

**2. Add plan Step 9, which is mandatory: deliver first-time and production installations through the unchanged original orchestration.**

- The topic is not complete, and its umbrella item stays pending, until Step 9 is validated.
- Step 9 starts only after Step 8 has proven the original path on the qualification environment, that is, after AC16 and AC17 are closed by actual evidence.
- The fixed-contract rule applies unchanged: conform to the orchestration exactly as it exists, and request no variable, role, template, job or operations change.

**3. Step 9 must address at least:**

- **Bootstrap without the temporary delivery task.**
  - Neither a new environment nor production has that task. The orchestration's first action on the host is our stop, through the prefix dispatcher, so the dispatcher and the stable stop and start scripts must already be installed.
  - Define a bootstrap route through existing authenticated maintenance access, from independently verified bytes, before the first original-path run.
  - Preferred direction: install only the stable scripts, with no application, and allow a first activation only when no stable version exists yet. If a better route exists, list it for the human as an open design choice; do not settle it silently.
- **First-time installation.** Nothing is installed or running, and there is no last working release and no recovery target. Define:
  - a stop with nothing to stop;
  - start's deploy mode on an empty prefix;
  - the installer's first-install path;
  - what a refusal or a failure leaves behind when there is nothing to restart.

  The environment provisioning the operations team must already have done becomes evidence gates, never change requests: the account, the scripts folder, the staging folder, and the service unit with its expected identity.
- **Production, from the historical shipped-environment release it currently runs:**
  - the unchanged orchestration's production approval step pauses before our stop for up to two hours, until the operations pilot validates. Our deployment pipeline's time budget and the selection's freshness must cover that wait;
  - production rejects snapshot coordinates, so only published, qualified release coordinates are deployable;
  - a managed production job and template that run the restored production playbook must exist, as an evidence gate;
  - rollback to the historical release depends on its archives and completion markers being present in staging at the first new-format install. Inspect this read-only, and define a verified route that retains the historical release if they are absent, before any production upgrade;
  - our stop's service-unit identity check must come from evidence gathered on each environment, never be assumed from the qualification environment;
  - the health checks used by refusal and recovery must match the historical release's runtime interfaces;
  - target access to the artifact repository from production, and the production arming channel (who has existing access to the production application account), are separate evidence gates.
- **Rehearsals before production.** Run a first-time rehearsal on an empty prefix and a historical-release upgrade-and-rollback rehearsal on a production-like prefix, each separately authorized, before any production run. Production execution needs its own explicit human authorization and still goes through the operations team's approval step.

**4. Documents to amend.**

- The requirement: new acceptance criteria for first-time delivery and production delivery, plus a requirement clarification recording this decision.
- The design: the bootstrap route, the first-install and production flows, per-environment identity evidence, and historical-release checks.
- The validation plan: a Step 9 skeleton marked not started.

Implementation choices become new plan questions. Any genuinely open design choice, such as the bootstrap route, is listed for the human in the writer response.

Concrete hosts, accounts, paths, versions and source lines are in `.reviews/a.dvs-step9-scope.private-notes.md`. Keep them private, and keep the public documents and this transcript generic.

No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Guidance response:

The amended documents follow the 2026-10-04 guidance item by item:

- **Item 1:** Step 8's scope is explicit in its goals, analysis and completion criteria.
- **Item 2:** Step 9 is mandatory, follows actual AC16/AC17 closure, and keeps the topic and umbrella item pending.
- **Item 3, bootstrap:** the scripts-only route with a guarded first activation follows the preferred direction, and the writer reports no alternative.
- **Item 3, first-time installation:** covered by the empty-prefix table and its retry rules.
- **Item 3, production:** each listed point is a gate, a test or an execution part: the approval wait, release-only coordinates, the managed job evidence, historical retention, per-environment unit identity, historical-release checks, repository access and the arming channel.
- **Item 4:** the requirement, design and validation amendments are present.

The guidance's demand for two rehearsals is where a decision remains: neither document says where they can run. R12 asks the writer to list that venue choice for the human, as the guidance requires for open design choices. R13 keeps the guidance's "running historical service untouched" promise true for the unit's start hooks during the bootstrap.

### Writer instructions for plan deploy-venv-sync (exchange 2) (round 4)

Read the private notes at `.reviews/a.dvs-step8-plan-r4.reviewer-notes.md` first. They hold the routing, host and hook-installation evidence behind R12 to R15. Keep those references in the private mapping; the public plan and this transcript stay generic.

Apply R12 to R15 to Step 9, the empty-prefix table, Q23, Q24 and Q30, and the P40/P41 test lists. List the R12 venue choice in the next writer response, as a decision for the human, with the two options and the recommended direction. Do not choose a venue in the plan, and do not request any operations provisioning.

Keep the existing boundaries: no implementation, test, pipeline, target or operations action, and no commit. Rerun the mandatory Markdown gate and the sensitive scan of the edited public files before publishing the next round.

### Final reviewer decision for plan deploy-venv-sync (exchange 2) (round 4)

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-4 -->

## Round 5 by requestor

- Recorded: 2026-10-04T01:10:59+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (exchange 2) (round 5)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 5

### Requestor assessment for plan deploy-venv-sync (exchange 2) (round 5)

Round 4 agrees with all Q23-Q30 recommendations and retains Q11-Q22. Applied
R12-R15 across Step 9, its state table, Q23/Q24/Q30, the design, requirement,
validation expectations and private mapping. The implementation options and
answers are sufficient; no additional implementation question is missing.

The unresolved rehearsal venue is explicitly a human design decision. Both
rehearsal ledger entries are blocked until that decision and their existing
managed route/unit/access and separate preparation/restoration evidence close.
No venue is chosen by this plan and no provisioning request is made.

Publication order, historical hook preservation and provisional-index retry
refusal now have concrete P40/P41 cases. All earlier Step 8 guarantees remain.
Only documentation and the review exchange have changed; no execution evidence
or implementation is claimed.

### Change summary for plan deploy-venv-sync (exchange 2) (round 5)

R12 adds the venue prerequisites and separate blocked C/D ledger entries.
Qualification is the only evidenced managed route; the build host supplies only
fixtures or replica evidence. The design and writer response expose the human
choice and the requirement/accounting/validation keep both rehearsals unclosed.

R13 limits historical bootstrap writes to the stable closure, pointer, dispatcher
and control folders. Unit start/pre-start hooks remain unchanged until the first
approved hold entry; intervening restart and evidenced bridge behavior are P40
and historical-rehearsal requirements. The empty-prefix exception is preserved.

R14 makes closure verification and version-pointer publication precede final
atomic dispatcher publication. Q23/P40 cover stop before closure, between pointer
and dispatcher, and afterward, with fail-closed prepublication behavior.

R15 extends the state table and Q24/P41 to a failed retry naming a provisional
release as pending recovery. The no-predecessor checkpoint rejects recovery,
held and nonzero, without restart or rollback. Q30 tracks venue dependencies.

### Human guidance and writer response for plan deploy-venv-sync (exchange 2) (round 5)

Human guidance:

Human decision on 2026-10-04, given at the round 3 convergence gate.

**Revise and review again.** First apply the round 3 covered wording on the pending recovery value. Then make the following changes, and keep everything already settled in Steps 1 to 8 intact.

**1. Step 8 scope is explicit.** Step 8 covers only the qualification environment, the one the temporary delivery task can still bootstrap before restoration. Say so in Step 8's analysis and intent and in its completion criteria: Step 8 does not cover a first-time installation, and it does not cover a production deployment. Both move to Step 9.

**2. Add plan Step 9, which is mandatory: deliver first-time and production installations through the unchanged original orchestration.**

- The topic is not complete, and its umbrella item stays pending, until Step 9 is validated.
- Step 9 starts only after Step 8 has proven the original path on the qualification environment, that is, after AC16 and AC17 are closed by actual evidence.
- The fixed-contract rule applies unchanged: conform to the orchestration exactly as it exists, and request no variable, role, template, job or operations change.

**3. Step 9 must address at least:**

- **Bootstrap without the temporary delivery task.**
  - Neither a new environment nor production has that task. The orchestration's first action on the host is our stop, through the prefix dispatcher, so the dispatcher and the stable stop and start scripts must already be installed.
  - Define a bootstrap route through existing authenticated maintenance access, from independently verified bytes, before the first original-path run.
  - Preferred direction: install only the stable scripts, with no application, and allow a first activation only when no stable version exists yet. If a better route exists, list it for the human as an open design choice; do not settle it silently.
- **First-time installation.** Nothing is installed or running, and there is no last working release and no recovery target. Define:
  - a stop with nothing to stop;
  - start's deploy mode on an empty prefix;
  - the installer's first-install path;
  - what a refusal or a failure leaves behind when there is nothing to restart.

  The environment provisioning the operations team must already have done becomes evidence gates, never change requests: the account, the scripts folder, the staging folder, and the service unit with its expected identity.
- **Production, from the historical shipped-environment release it currently runs:**
  - the unchanged orchestration's production approval step pauses before our stop for up to two hours, until the operations pilot validates. Our deployment pipeline's time budget and the selection's freshness must cover that wait;
  - production rejects snapshot coordinates, so only published, qualified release coordinates are deployable;
  - a managed production job and template that run the restored production playbook must exist, as an evidence gate;
  - rollback to the historical release depends on its archives and completion markers being present in staging at the first new-format install. Inspect this read-only, and define a verified route that retains the historical release if they are absent, before any production upgrade;
  - our stop's service-unit identity check must come from evidence gathered on each environment, never be assumed from the qualification environment;
  - the health checks used by refusal and recovery must match the historical release's runtime interfaces;
  - target access to the artifact repository from production, and the production arming channel (who has existing access to the production application account), are separate evidence gates.
- **Rehearsals before production.** Run a first-time rehearsal on an empty prefix and a historical-release upgrade-and-rollback rehearsal on a production-like prefix, each separately authorized, before any production run. Production execution needs its own explicit human authorization and still goes through the operations team's approval step.

**4. Documents to amend.**

- The requirement: new acceptance criteria for first-time delivery and production delivery, plus a requirement clarification recording this decision.
- The design: the bootstrap route, the first-install and production flows, per-environment identity evidence, and historical-release checks.
- The validation plan: a Step 9 skeleton marked not started.

Implementation choices become new plan questions. Any genuinely open design choice, such as the bootstrap route, is listed for the human in the writer response.

Concrete hosts, accounts, paths, versions and source lines are in `.reviews/a.dvs-step9-scope.private-notes.md`. Keep them private, and keep the public documents and this transcript generic.

No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Writer response:

Accepted R12-R15 without disagreement. Applied all concrete reviewer instructions
and retained every settled recommendation. Q23, Q24 and Q30 were amended through
the open-question companion workflow; Q11-Q22 and the remaining options remain.

The rehearsal venue remains a human design decision, not a plan question:

| Option | Benefit | Constraint and recommendation |
| --- | --- | --- |
| A, use qualification | Uses the only evidenced managed route and existing unit/access. | Recommended. Retain the current release and its recovery inputs offline before separately authorized empty-prefix preparation, then prepare the exact historical pair through proven recovery or an exact historical reinstall. Record restoration and authorize each disruptive action separately. |
| B, separately provisioned environment | Avoids repurposing qualification. | Requires operations provisioning outside this effort's no-request boundary. This plan requests none and cannot assume such an environment exists. |

No venue is selected. Parts C and D remain blocked until the human decides and
their managed route/unit/access, retention, preparation/restoration and separate
authorizations are evidenced. Our build host cannot satisfy either rehearsal
with fixture or replica evidence. Production remains blocked behind both.

Historical bootstrap leaves existing hook paths intact; the first approved hold
entry owns bridging. First activation publishes the dispatcher last. The added
retry case refuses recovery to a provisional release under the existing typed
checkpoint rule. No new execution or consolidation is authorized.

The round 3 human guidance remains unchanged and is reproduced verbatim by the
renderer. Please review these refinements and retain the open venue decision for
the human at convergence.

### Reviewer focus for plan deploy-venv-sync (exchange 2) (round 5)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-5 -->

## Round 5 by reviewer

- Recorded: 2026-10-04T01:16:09+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync (exchange 2) (round 5)

Round 5 applies R12 to R15 precisely, and nothing else changed:

- **R12:** a new "rehearsal venue gate" section states the venue requirements, records that only the qualification route is evidenced, and limits our build host to fixture or replica evidence. It leaves the venue choice to the human, with the two options and a recommendation in the writer response, and keeps Parts C and D blocked in the ledger until the human decides. The requirement and the accounting rows for AC18 and AC19 now name the human-selected venue as a closing condition.
- **R13:** on a running historical installation, the bootstrap writes only the stable closure, version pointer, dispatcher and control folders. The unit's start and pre-start hooks stay untouched until the first approved stop enters the hold, in Part B, Part D and Part F alike. The empty-prefix exception remains.
- **R14:** the closure and version pointer are verified first, and the dispatcher is published last by atomic rename. A concurrent stop fails closed. P40 covers the three interleavings.
- **R15:** the state table and P41 now include the failed retry whose pending value names the provisional release. Recovery is refused under the typed checkpoint rule, held and nonzero, with no restart or rollback.

Every implementation question, Q11 to Q30, is settled in substance, and I agree with every recommended answer. The requirement and design remain consistent with the plan, and public text stays generic.

One decision remains open by design: where the two Step 9 rehearsals run. It is a human design choice, not a plan question, and the plan handles it correctly as a blocking gate that does not prevent implementing Parts A and B. The human can settle it at this gate or later. No further plan edit is needed either way, so I recommend convergence.

### Question verdicts for plan deploy-venv-sync (exchange 2) (round 5)

**Q11 to Q22, option A: agree as settled in rounds 1 to 3.**

**Q23, option A: agree.** The publication order and its three interleavings are now explicit.

**Q24, option A: agree.** The provisional-release retry refusal is now covered.

**Q25 to Q29, option A: agree.** These are unchanged since round 4 and were already sufficient.

**Q30, option A: agree.** The ledger now carries separate blocked entries for Parts C and D, gated by the human venue decision.

**No missing implementation question.** The rehearsal venue is correctly a human design decision outside the plan's questions.

### Convergence evidence for plan deploy-venv-sync (exchange 2) (round 5)

Covered wording:

No wording edit remains. The plan, the requirement and the design can be consolidated as they stand.

Convergence rationale:

Every in-scope implementation decision for Steps 8 and 9 is settled, and the plan text implements each one: Q11 to Q30 have substantive, agreed answers, and requested changes R1 to R15 are all applied without disagreement. The human guidance of 2026-10-04 is fully carried by the requirement, the design, the plan and the validation skeleton.

The only open item is the rehearsal venue for Step 9 Parts C and D. It is a human design decision that the plan records as a blocking gate, not a missing plan decision. Settling it changes no plan text beyond recording the choice in the ledger.

AC16 to AC19 remain open until separately authorized execution, which the plan correctly does not grant.

### Human guidance response for plan deploy-venv-sync (exchange 2) (round 5)

Human guidance:

Human decision on 2026-10-04, given at the round 3 convergence gate.

**Revise and review again.** First apply the round 3 covered wording on the pending recovery value. Then make the following changes, and keep everything already settled in Steps 1 to 8 intact.

**1. Step 8 scope is explicit.** Step 8 covers only the qualification environment, the one the temporary delivery task can still bootstrap before restoration. Say so in Step 8's analysis and intent and in its completion criteria: Step 8 does not cover a first-time installation, and it does not cover a production deployment. Both move to Step 9.

**2. Add plan Step 9, which is mandatory: deliver first-time and production installations through the unchanged original orchestration.**

- The topic is not complete, and its umbrella item stays pending, until Step 9 is validated.
- Step 9 starts only after Step 8 has proven the original path on the qualification environment, that is, after AC16 and AC17 are closed by actual evidence.
- The fixed-contract rule applies unchanged: conform to the orchestration exactly as it exists, and request no variable, role, template, job or operations change.

**3. Step 9 must address at least:**

- **Bootstrap without the temporary delivery task.**
  - Neither a new environment nor production has that task. The orchestration's first action on the host is our stop, through the prefix dispatcher, so the dispatcher and the stable stop and start scripts must already be installed.
  - Define a bootstrap route through existing authenticated maintenance access, from independently verified bytes, before the first original-path run.
  - Preferred direction: install only the stable scripts, with no application, and allow a first activation only when no stable version exists yet. If a better route exists, list it for the human as an open design choice; do not settle it silently.
- **First-time installation.** Nothing is installed or running, and there is no last working release and no recovery target. Define:
  - a stop with nothing to stop;
  - start's deploy mode on an empty prefix;
  - the installer's first-install path;
  - what a refusal or a failure leaves behind when there is nothing to restart.

  The environment provisioning the operations team must already have done becomes evidence gates, never change requests: the account, the scripts folder, the staging folder, and the service unit with its expected identity.
- **Production, from the historical shipped-environment release it currently runs:**
  - the unchanged orchestration's production approval step pauses before our stop for up to two hours, until the operations pilot validates. Our deployment pipeline's time budget and the selection's freshness must cover that wait;
  - production rejects snapshot coordinates, so only published, qualified release coordinates are deployable;
  - a managed production job and template that run the restored production playbook must exist, as an evidence gate;
  - rollback to the historical release depends on its archives and completion markers being present in staging at the first new-format install. Inspect this read-only, and define a verified route that retains the historical release if they are absent, before any production upgrade;
  - our stop's service-unit identity check must come from evidence gathered on each environment, never be assumed from the qualification environment;
  - the health checks used by refusal and recovery must match the historical release's runtime interfaces;
  - target access to the artifact repository from production, and the production arming channel (who has existing access to the production application account), are separate evidence gates.
- **Rehearsals before production.** Run a first-time rehearsal on an empty prefix and a historical-release upgrade-and-rollback rehearsal on a production-like prefix, each separately authorized, before any production run. Production execution needs its own explicit human authorization and still goes through the operations team's approval step.

**4. Documents to amend.**

- The requirement: new acceptance criteria for first-time delivery and production delivery, plus a requirement clarification recording this decision.
- The design: the bootstrap route, the first-install and production flows, per-environment identity evidence, and historical-release checks.
- The validation plan: a Step 9 skeleton marked not started.

Implementation choices become new plan questions. Any genuinely open design choice, such as the bootstrap route, is listed for the human in the writer response.

Concrete hosts, accounts, paths, versions and source lines are in `.reviews/a.dvs-step9-scope.private-notes.md`. Keep them private, and keep the public documents and this transcript generic.

No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Guidance response:

The 2026-10-04 guidance is now fully applied.

Round 4 found one gap in it: the guidance demands two rehearsals but names no venue for them. That gap is closed the way the guidance requires for open design choices. The writer lists the venue choice for the human with both options and a recommendation, and does not choose. The guidance's promise that the running historical service stays untouched now also covers the unit's start and pre-start hooks during the bootstrap.

### Writer instructions for plan deploy-venv-sync (exchange 2) (round 5)

No plan edit is required.

This answer recommends convergence. It does not authorize consolidation. Present the human gate with both registered choices, and with the open rehearsal-venue decision shown next to them: option A, the qualification environment (recommended), or option B, a separately provisioned environment. Wait for the human's selection.

If the human also decides the venue, record that decision only after the gate choice authorizes an owning action. Do not consolidate, implement, run tests, touch the consumer or the operations repository, commit or push in this task.

### Final reviewer decision for plan deploy-venv-sync (exchange 2) (round 5)

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-5 -->

## Round 5 by human - human-confirmation

- Recorded: 2026-10-04T02:37:34+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Revise and review again
Outcome: another-round
Guidance: Human decision on 2026-10-04, given at the round 5 convergence gate.

**Revise and review again.** Keep everything settled in rounds 1 to 5 intact, including Q11 to Q30 and requested changes R1 to R15. The rehearsal venue stays open; this guidance does not decide it.

**Why.** A first deployment through the unchanged orchestration cannot install anything before our stop: the orchestration's first command on the host runs the prefix dispatcher, and its delivery step only unpacks into staging and runs nothing from there. The scripts-only bootstrap therefore has to be a separate operation, done on the target before the first original-path run. The plan treats it as "existing maintenance access", but it never says who performs it, when, with what, or what happens if nobody on our side can run commands as the application account. Make that explicit in Step 9, Parts C, D and F, and in the gate ledger.

**1. One-time bootstrap session.** Describe it as its own operation, before the first deployment of each environment and never part of a pipeline run:

- who performs it, logged in as the application account on the target host;
- what is transferred and how it is verified. The trust chain must lead back to the registered, published release identity, with no new publication object. For example, transfer the exact published application archive and check it against its registered SHA-256, then extract the compatibility installer and the stable-script closure from that verified archive;
- the order:
  1. guarded first activation, with the dispatcher published last;
  2. historical retention preparation when it is needed;
  3. arming of the first deployment;
- what the session must not touch: the running release, staging, and the unit's start and pre-start hooks;
- how its result is checked and receipted without running the dispatcher's stop or start shapes;
- what happens if the session is interrupted, or if a deployment is launched before it completes.

State that later deployments never repeat the bootstrap, because each successful deployment activates its own stable scripts for the next one.

**2. Arming access before every deployment.** Arming needs the same access each time. Say so.

**3. Name the access dependency as an explicit gate, with two routes.**

- **Route (a):** our operator holds existing authenticated shell access as the application account on that host.
- **Route (b):** an operator of the operations team runs, as the application account, the exact self-verifying commands we hand over: the bootstrap session once, and arming before each deployment.

Route (b) is an operator action, not an orchestration, variable, role, template, job or privilege change. It does make each deployment depend on that team's availability, so record that consequence. Automated arming from our pipeline remains possible only if existing access is proven for it.

The human chooses the route per environment once the evidence is known. Until then, the bootstrap and arming steps of Parts C, D and F stay blocked in the ledger. Do not request access or any other change from the operations team in this effort.

**4. Apply the same rule to the first-time environment.** Part C and its rehearsal venue need the same bootstrap session and the same access route.

**5. Questions and responses.** Any new implementation choice becomes a plan question through the canonical workflow, for example the exact command sequence and the bootstrap transfer unit. Report any design choice for the human in the writer response.

Concrete hosts, accounts and paths belong to the private mapping only. Keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

<!-- review-entry-id: human-confirmation-round-5 -->

## Round 6 by requestor

- Recorded: 2026-10-04T02:55:35+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (exchange 2) (round 6)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 6

### Requestor assessment for plan deploy-venv-sync (exchange 2) (round 6)

The plan now states the one-time bootstrap session separately from every-deployment
arming, and repeats the access gates explicitly in Parts C, D and F. The named
operator works as the application account on the target. Two routes are listed
without selecting either: our existing authenticated shell access, or an
operations-team operator executing the same exact self-verifying commands.
Recurring availability is a consequence of the latter; pipeline arming requires
independent evidence of existing pipeline access. Bootstrap is never a pipeline
step. All relevant gates remain blocked pending the human decisions and evidence.

The proposed session transfers the exact published application archive, verifies
its independently registered SHA-256 on target, safely extracts verified members,
first-activates with dispatcher last, prepares historical retention when needed,
then arms the first real run. Dedicated inspection receipts avoid dispatcher
stop/start. Interruption and premature launch are explicit refusal states,
including the unchanged-staging ordinary-restart ambiguity after dispatcher
publication. Later successful deployments supply their own next stable version;
they do not repeat bootstrap.

Q11-Q30 remain byte-for-byte unchanged in the question companion. Q31-Q33 are the
new implementation questions: transfer unit, checked phase/inspection owners and
operator receipt handoff. Each has options, trade-offs and a proposed option A
answer. No further implementation question was found in this bounded review.
The existing answers and the new options are sufficient for review, subject to
the independently assessed design gate below. Round 5 required no wording edits;
R1-R15 remain the baseline and are not reopened as implementation questions.

There is one explicit conflict to resolve as a human design decision. Earlier
empty-prefix bootstrap installs hold-aware hooks under an initial hold. The new
guidance forbids touching unit start/pre-start hooks in the bootstrap session.
Historical bootstrap already conforms, but empty-prefix hook placement cannot
keep both timings. The design/writer response exposes alternatives and blocks
Part C and affected implementation without choosing. The venue and access route
also remain human decisions, not implementation questions. This review may
settle implementation allocation without pretending any of those gates is closed.

Requirement, design, draft, validation expectations, umbrella text and private
mapping agree on these boundaries. Step 9 remains not started, and the umbrella
row remains pending. No implementation, test, pipeline, target or operations
action, consumer edit, commit or push has occurred in this round.

### Change summary for plan deploy-venv-sync (exchange 2) (round 6)

- Added Step 9's separate one-time target session and recurring access ledger.
  Parts C/D/F name the operator, account context, two undecided access routes,
  recurring availability, evidence and separate authorization gates.
- Specified exact published archive verification before extraction/execution,
  dispatcher-last first activation, then required historical retention and
  first real arming, with non-dispatch inspections and receipts. Check mode is
  unarmed; when scheduled, its traversal precedes real arming.
- Added interruption and premature-deployment refusal, including an incomplete
  bootstrap gate after dispatcher publication. Later releases activate their
  stable scripts through success and require fresh arming without repeat bootstrap.
- Made runtime/staging/unit-hook immutability apply to the whole session and
  recorded the conflicting earlier empty-prefix hook placement as a blocked
  human design decision. No venue, access route or hook placement was selected.
- Amended requirement AC18/AC19, design, topic draft, validation expectations,
  umbrella explanation and private mapping consistently. Kept public text generic.
- Preserved Q11-Q30 through the canonical companion workflow and placed Q31-Q33
  for transfer, phase ownership and verifiable operator handoff. Their proposed
  fixture coverage is documentation only, with no test execution.

### Human guidance and writer response for plan deploy-venv-sync (exchange 2) (round 6)

Human guidance:

Human decision on 2026-10-04, given at the round 5 convergence gate.

**Revise and review again.** Keep everything settled in rounds 1 to 5 intact, including Q11 to Q30 and requested changes R1 to R15. The rehearsal venue stays open; this guidance does not decide it.

**Why.** A first deployment through the unchanged orchestration cannot install anything before our stop: the orchestration's first command on the host runs the prefix dispatcher, and its delivery step only unpacks into staging and runs nothing from there. The scripts-only bootstrap therefore has to be a separate operation, done on the target before the first original-path run. The plan treats it as "existing maintenance access", but it never says who performs it, when, with what, or what happens if nobody on our side can run commands as the application account. Make that explicit in Step 9, Parts C, D and F, and in the gate ledger.

**1. One-time bootstrap session.** Describe it as its own operation, before the first deployment of each environment and never part of a pipeline run:

- who performs it, logged in as the application account on the target host;
- what is transferred and how it is verified. The trust chain must lead back to the registered, published release identity, with no new publication object. For example, transfer the exact published application archive and check it against its registered SHA-256, then extract the compatibility installer and the stable-script closure from that verified archive;
- the order:
  1. guarded first activation, with the dispatcher published last;
  2. historical retention preparation when it is needed;
  3. arming of the first deployment;
- what the session must not touch: the running release, staging, and the unit's start and pre-start hooks;
- how its result is checked and receipted without running the dispatcher's stop or start shapes;
- what happens if the session is interrupted, or if a deployment is launched before it completes.

State that later deployments never repeat the bootstrap, because each successful deployment activates its own stable scripts for the next one.

**2. Arming access before every deployment.** Arming needs the same access each time. Say so.

**3. Name the access dependency as an explicit gate, with two routes.**

- **Route (a):** our operator holds existing authenticated shell access as the application account on that host.
- **Route (b):** an operator of the operations team runs, as the application account, the exact self-verifying commands we hand over: the bootstrap session once, and arming before each deployment.

Route (b) is an operator action, not an orchestration, variable, role, template, job or privilege change. It does make each deployment depend on that team's availability, so record that consequence. Automated arming from our pipeline remains possible only if existing access is proven for it.

The human chooses the route per environment once the evidence is known. Until then, the bootstrap and arming steps of Parts C, D and F stay blocked in the ledger. Do not request access or any other change from the operations team in this effort.

**4. Apply the same rule to the first-time environment.** Part C and its rehearsal venue need the same bootstrap session and the same access route.

**5. Questions and responses.** Any new implementation choice becomes a plan question through the canonical workflow, for example the exact command sequence and the bootstrap transfer unit. Report any design choice for the human in the writer response.

Concrete hosts, accounts and paths belong to the private mapping only. Keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Writer response:

Accepted the round 5 convergence as the settled baseline; it required no further
wording changes. The human then selected "Revise and review again" with the
supplied guidance file, which was passed unchanged to confirm and is included
verbatim in this request. The resulting amendments and the response here are
separate from that guidance.

The added session is outside every pipeline run and occurs before the first
original-path deployment of an environment. P20/P30 carry the exact commands;
P28/P39/P29 verify and receipt activation, retention and arming. The target verifies
the exact published archive against its independently bound registered digest
before extracting or running anything from it. No new publication object is
introduced. The session leaves runtime, staging and unit hooks untouched. A
premature stop fails before delivery, or refuses through incomplete-bootstrap
state after dispatcher publication. Successful later deployments activate stable
scripts normally; each still requires fresh arming through evidenced access.

Q31-Q33 propose option A for implementation only. Existing Q11-Q30 remain intact.
Please assess the phase/receipt ordering, interruption behavior and recurring
handoff coverage as well as the explicit blocked design choices.

Human design decisions remain open:

| Decision | Alternatives and boundary |
| --- | --- |
| Rehearsal venue | The previous recommendation remains qualification reuse with retained current release and separately authorized preparation/restoration; separately provisioned infrastructure is the alternative outside this effort's no-request scope. Neither is selected. |
| Access route per environment | (a) Our operator's existing authenticated application-account shell access, or (b) an operations-team operator running the exact commands once for bootstrap and for every arming. Route (b) requires their availability for every deployment. Neither has evidence sufficient for selection and neither is chosen. No access request is made. |
| Empty-prefix initial hook placement | Separate authorized venue preparation preserves hook readiness before bootstrap but needs independently verified bytes and safe inactive preparation; first approved stop preserves the no-hook-write session boundary but requires evidence of safe inactivity until initial hold/bridge. Neither is selected. |

The hook-placement item is a conflict between the previous empty-prefix timing
and the new absolute session boundary, not a reopened historical-bootstrap rule.
The newer boundary applies immediately: no hook writes during bootstrap. Part C
and affected implementation stay blocked until the human places the hook step
safely outside that session. The writer has not silently changed R13's safety
intent or chosen either alternative. Please keep this as an explicit human design
gate rather than a plan implementation question.

The human-selected venue does not select an access route. The C/D/F ledger names
the independent access gates, and Part C applies the same session/access rules
as production. P22 cannot infer its own shell access from an operator's access.
Route (b) is an operator action, with no role, vars, template, job, privilege or
other configuration change. Existing access remains an evidence prerequisite.

This is documentation and review only. Actual AC16-AC19 evidence, implementation,
tests and every operational action remain pending under their original separate
authorization requirements. The topic and umbrella remain pending.

### Reviewer focus for plan deploy-venv-sync (exchange 2) (round 6)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-6 -->

## Round 6 by reviewer

- Recorded: 2026-10-04T03:00:29+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync round 6

Round 6 applies the 2026-10-04 round 5 guidance completely:

- **A separate bootstrap session.** The new section makes the one-time bootstrap its own target operation: never a pipeline step, before an environment's first original-path deployment, and run by a named operator as the application account. The transfer has a trust chain back to the registered release digest and no new publication object. The order is guarded first activation with the dispatcher last, then historical retention when needed, then arming of the first real run. Inspections never use the dispatcher's stop or start shapes.
- **Interruption and premature launch.** Both are explicit, including the subtle case where the dispatcher is published but the session is incomplete and an unchanged-staging run would otherwise look like an ordinary restart.
- **Arming before every deployment** is stated, and later deployments never repeat the bootstrap.
- **Access.** The two access routes are listed without choosing, with route (b)'s recurring dependency on the operations team recorded. Pipeline arming is gated on independently proven access. The ledger blocks the session and arming entries of Parts C, D and F until the human decides.

Q31 to Q33 are sound implementation questions, and I agree with each recommended option. Q11 to Q30 are unchanged.

The writer correctly surfaced one conflict instead of resolving it silently. The round 5 guidance forbids touching the unit's start and pre-start hooks during the session. Applied to an empty prefix, that contradicts the earlier allowance for installing hold-aware hooks at bootstrap there. The source shows why the choice matters: the existing hold entry accepts only a replaceable link into the application tree or an already installed bridge, and fails when the hook file is absent, as on an empty prefix. So "install the hooks at the first approved stop" needs new absent-hook behavior. Meanwhile, an enabled unit pointing at absent hooks fails on any start before the first deployment. Reading the guidance's boundary as "never modify the hooks of an installed or running release" would restore the earlier empty-prefix allowance as a third, simplest alternative. Only the human can choose.

No implementation question remains open, and no wording edit is needed. The three remaining items are human design decisions, which the plan records as blocking gates for Parts C, D and F without preventing Parts A and B: the rehearsal venue, the access route per environment, and the empty-prefix hook placement. I recommend convergence.

### Question verdicts for plan deploy-venv-sync round 6

**Q11 to Q30, option A: agree as settled in rounds 1 to 5.**

**Q31, option A: agree.** Verifying the whole published archive on the target keeps the registry as the only trust root.

**Q32, option A: agree.** Keeping the incomplete-bootstrap state in P29, so that a post-publication run is refused before any mutation, is the right guard.

**Q33, option A: agree.** Rechecking the returned receipts both before launch and at reservation catches stale handoffs.

**No missing implementation question.**

**Human design decisions, not plan questions:**

- **Rehearsal venue.** Unchanged: option A (qualification) remains the recommended direction.
- **Access route per environment.** It depends on evidence not yet gathered.
- **Empty-prefix hook placement.** In addition to the writer's two alternatives, consider the simplest one: the session boundary forbids modifying the hooks of an installed or running release. On an evidenced empty prefix with an inactive unit, the session installs the hold-aware hooks with the deployment hold set, receipted, and never starts the unit.

### Convergence evidence for plan deploy-venv-sync round 6

Covered wording:

No wording edit remains. The plan, the requirement and the design can be consolidated as they stand. If the human settles the empty-prefix hook placement, the venue or an access route, record that decision afterwards under the gate's chosen owning action.

Convergence rationale:

Every implementation decision for Steps 8 and 9 is settled: Q11 to Q33 have agreed answers, and requested changes R1 to R15 are applied. The round 5 guidance on the bootstrap session and access is fully carried by the plan, requirement, design, validation skeleton and private mapping.

The three open items are human design decisions, recorded as blocking gates rather than missing plan text: the rehearsal venue, the access route per environment, and the empty-prefix hook placement. They block only the execution parts that depend on them. Recording any of them later is a ledger update and does not change the implementation decisions.

AC16 to AC19 remain open until separately authorized execution.

### Human guidance response for plan deploy-venv-sync round 6

Human guidance:

Human decision on 2026-10-04, given at the round 5 convergence gate.

**Revise and review again.** Keep everything settled in rounds 1 to 5 intact, including Q11 to Q30 and requested changes R1 to R15. The rehearsal venue stays open; this guidance does not decide it.

**Why.** A first deployment through the unchanged orchestration cannot install anything before our stop: the orchestration's first command on the host runs the prefix dispatcher, and its delivery step only unpacks into staging and runs nothing from there. The scripts-only bootstrap therefore has to be a separate operation, done on the target before the first original-path run. The plan treats it as "existing maintenance access", but it never says who performs it, when, with what, or what happens if nobody on our side can run commands as the application account. Make that explicit in Step 9, Parts C, D and F, and in the gate ledger.

**1. One-time bootstrap session.** Describe it as its own operation, before the first deployment of each environment and never part of a pipeline run:

- who performs it, logged in as the application account on the target host;
- what is transferred and how it is verified. The trust chain must lead back to the registered, published release identity, with no new publication object. For example, transfer the exact published application archive and check it against its registered SHA-256, then extract the compatibility installer and the stable-script closure from that verified archive;
- the order:
  1. guarded first activation, with the dispatcher published last;
  2. historical retention preparation when it is needed;
  3. arming of the first deployment;
- what the session must not touch: the running release, staging, and the unit's start and pre-start hooks;
- how its result is checked and receipted without running the dispatcher's stop or start shapes;
- what happens if the session is interrupted, or if a deployment is launched before it completes.

State that later deployments never repeat the bootstrap, because each successful deployment activates its own stable scripts for the next one.

**2. Arming access before every deployment.** Arming needs the same access each time. Say so.

**3. Name the access dependency as an explicit gate, with two routes.**

- **Route (a):** our operator holds existing authenticated shell access as the application account on that host.
- **Route (b):** an operator of the operations team runs, as the application account, the exact self-verifying commands we hand over: the bootstrap session once, and arming before each deployment.

Route (b) is an operator action, not an orchestration, variable, role, template, job or privilege change. It does make each deployment depend on that team's availability, so record that consequence. Automated arming from our pipeline remains possible only if existing access is proven for it.

The human chooses the route per environment once the evidence is known. Until then, the bootstrap and arming steps of Parts C, D and F stay blocked in the ledger. Do not request access or any other change from the operations team in this effort.

**4. Apply the same rule to the first-time environment.** Part C and its rehearsal venue need the same bootstrap session and the same access route.

**5. Questions and responses.** Any new implementation choice becomes a plan question through the canonical workflow, for example the exact command sequence and the bootstrap transfer unit. Report any design choice for the human in the writer response.

Concrete hosts, accounts and paths belong to the private mapping only. Keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Guidance response:

Each item of the round 5 guidance is applied:

1. The one-time session is described as its own operation, covering who, what, the trust chain, the order, what it must not touch, receipts, interruption and premature launch.
2. Arming access before every deployment is explicit.
3. Both access routes are listed without choosing, with route (b)'s recurring dependency recorded and pipeline arming gated on proven access.
4. Part C applies the same rules.
5. Q31 to Q33 hold the new implementation choices.

The guidance's "do not touch the unit's start and pre-start hooks" was aimed at a running release. Taken literally, it also forbids the earlier empty-prefix allowance. The writer rightly raised this as a human decision instead of reinterpreting the guidance, and the assessment adds the facts the human needs to settle it.

### Writer instructions for plan deploy-venv-sync round 6

No plan edit is required. The facts behind the hook-placement alternatives are in `.reviews/a.dvs-step8-plan-r6.reviewer-notes.md`; keep them private.

This answer recommends convergence. It does not authorize consolidation. Present the human gate with both registered choices and the three open human decisions beside them:

- **Rehearsal venue:** option A, qualification (recommended), or option B, a separately provisioned environment.
- **Access route per environment:** route (a), our operator's existing access, or route (b), an operations-team operator running our commands.
- **Empty-prefix hook placement:** the writer's two alternatives plus the reviewer's third: allow hook installation with the hold set on an evidenced empty prefix, because the boundary targets installed or running releases.

Wait for the human's selection. Do not consolidate, implement, run tests, touch the consumer or the operations repository, commit or push in this task.

### Final reviewer decision for plan deploy-venv-sync round 6

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-6 -->

## Round 6 by human - human-confirmation

- Recorded: 2026-10-04T17:49:58+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Revise and review again
Outcome: another-round
Guidance: Human decision on 2026-10-04, given at the round 6 convergence gate.

**Revise and review again.** Keep Q11 to Q33, R1 to R15 and every Step 9 decision intact unless this guidance changes them for Step 8.

**1. Step 8's goal.** Step 8 tests one deployment on the qualification environment through the original orchestration state, restored and unchanged. It builds on the existing deployment there: the dispatcher, the stable stop and start scripts and the control folders are already in place, installed by our existing delivery path in Part C. Step 8 must not depend on any operations-team operator, for anything. The only operations-team involvement left is the agreed restoration pull request, through their normal review.

**2. Fact.** Nobody on our side can open a shell as the qualification application account; the evidence is in the private mapping. So in Step 8, no part may rely on "existing maintenance access", an operator-assisted channel or a maintenance-channel terminalization. That covers Part A evidence, Part D arming and checkpoint, Part G, Part H and Part I recovery. Route (a) and route (b), and the operator-run bootstrap session, stay Step 9 only.

**3. Every target-side action in Step 8 goes through paths we already control.**

- Before restoration: the existing temporary delivery path, which runs our verified deployment entry with controller-checked inputs. It performs the bootstrap, and also the target probes, the receipts, the Part G arming and the recovery pre-authorization described below.
- After restoration: the original orchestration actions launched by our pipeline. The forward action is used for the test, and the stop/start-only action for a plain restart or a recovery.
- Evidence comes back only through the existing shared log location, our pipeline's console output and the two external endpoints.

**4. Arming for Part G.**

- Part G redeploys the same candidate Part C bootstrapped (Q22). The bootstrap deployment records, on the target, a single-use same-release selection for that later run. It is bound to the retained release record that the controller-checked delivery verified.
- Its four other inputs are reused from local retention by hash, so the stop fetches nothing.
- It stays valid until consumed or superseded, not for a short time window, because the restoration's merge date is outside our control.
- A delivery whose archive does not match that record is refused, exactly as today.

If this weakens the independent-selection guarantee, explain how in the writer response and propose operator-free alternatives for the human.

**5. Recovery for Part G without an operator.**

- The bootstrap deployment also records a recovery authorization bound to the Part G attempt and its same-release checkpoint. Our pipeline launches it through the original stop/start-only action. The typed recovery rules stay unchanged.
- Terminal proof for that attempt comes from local target evidence, checked by the stop target itself: the root lock is free, no attempt-owned process is alive, and our pipeline shows the orchestration job terminal. This replaces the maintenance-channel terminalization in Step 8.

**6. Part A target evidence.** Gather it through the bootstrap deployment's own read-only probes and receipts, returned through the shared log location: the current dispatcher and closure state, the unit identity, repository reachability from the target, and the HTTP client. The inherited orchestration defaults come from our pipeline's console output of the check-mode traversal. Anything that cannot be obtained that way is a gate reported to the human, never an operator request.

**7. Consistency.** Where the requirement or the design names an operator-assisted channel as the first route, scope that to Step 9. For Step 8, record this decision as a dated human decision in the requirement clarifications, the design decisions and the plan decisions. Update AC16 and AC17 so they cannot be read as requiring operator access. Any new implementation choice becomes a plan question through the canonical workflow.

**8. Open design choice for Step 9: operator-free arming of later deployments.** The Step 8 arming above works only because the test redeploys the release the bootstrap already knows. After the restoration, deploying a different release, on the qualification environment or in production, needs a selection the target cannot receive through the unchanged orchestration: the delivered archive cannot vouch for itself, and the stop and start commands take no parameters. Without a new mechanism, every later deployment depends on route (a) or route (b). Record this in the design and the writer response as an open human decision with these options:

- **Recommended: a signed selection.** The pipeline, or a named publisher, signs each selection, which carries the exact hashes, canonical URLs, a single-use attempt identity and an expiry. It is published to a known per-environment location in the artifact repository. The stop target downloads it with its other inputs and verifies the signature against a public key that ships inside the verified stable-script closure. The bootstrap installs that key; on the qualification environment that is the existing delivery path, with no operator. A new key arrives in a later release and becomes active only when that release's stable scripts are activated after a successful deployment. Costs to state: signing-key custody and rotation, one small published object per deployment, and a known fetch location made safe by the signature, attempt identity and expiry. Those last two conflict with the earlier "no new publication object" and "no moving resolution" rules, so the human must extend them explicitly.
- **Alternative: a selection fetched over fully verified TLS** from an artifact-repository path that only the publisher can write. It needs no key, but repository write permission becomes the trust root.
- **Rejected:** downloading the verification key from the artifact repository on first use. It only proves the selection came from the repository.

The one-time bootstrap on an environment without the temporary delivery path still needs route (a) or route (b) once, whichever option is chosen. If the human selects the signed selection before Part B is implemented, the key must already be part of the closure that Step 8 qualifies, so that later deployments on the qualification environment need no operator.

Concrete accounts, hosts and log locations belong to the private mapping only. Keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

<!-- review-entry-id: human-confirmation-round-6 -->

## Round 7 by requestor

- Recorded: 2026-10-04T18:02:39+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (exchange 2) (round 7)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 7

### Requestor assessment for plan deploy-venv-sync (exchange 2) (round 7)

The plan implements the human's round 6 direction as documentation only. Step 8
now tests one operator-free same-release qualification deployment through restored,
unchanged original orchestration. Part C supplies stable bootstrap, target probes,
selection and conditional recovery authority using existing controller-checked
delivery. Parts D and G-I need no separate access channel. The pipeline owns job
terminal proof; stable stop owns local lock/process proof. Shared logs, console
and external endpoints supply all evidence, with missing observations gated.

Q11-Q33 are retained. Their Step 8 wording is scoped where the guidance supersedes
operator transfer, short selection expiry and maintenance terminalization; Step 9
questions remain intact. Q34-Q36 cover genuine implementation choices: bootstrap
receipt ownership, durable linked authority, and composed terminal-proof fixtures.
All recommend option A with alternatives, pros/cons and proposed answer reasons.
No further implementation question is identified at this pass. Please check that
fixed command shapes, conditional recovery and A/C evidence sequencing are complete.

Round 6 requested no covered wording edits. Its agreed Q31-Q33 recommendations
remain, with current operator-assisted arming explicitly conditional on the open
Step 9 design decision. Signed selection is recommended but unselected; publication
and location extensions and trusted-key timing need human decisions. Rehearsal
venue, bootstrap access routes and empty-prefix hook placement remain unselected.
No implementation or execution evidence is claimed; AC16-AC19 remain open.

### Change summary for plan deploy-venv-sync (exchange 2) (round 7)

- Restated Step 8's goal and removed its operator/maintenance dependencies from
  Part A evidence, Part D arming, G-I observations and recovery, state transitions,
  acceptance rows and earlier implementation-question wording.
- Part C now records same-release selection and conditional recovery, both bound
  to its controller-verified retained record and Part G attempt/checkpoint. Stop
  rehashes four local inputs without network. Selection remains valid until
  consumed/superseded, with no short expiry across restoration.
- Distinguished the pipeline's job-terminal launch gate from stop's local
  lock/process proof. Fixed arguments convey neither a new mode nor controller
  status; outstanding authority and pipeline launch order determine the route.
- Scoped operator routes to Step 9. Added the open signed-selection versus
  verified-TLS selection decision, rejected first-use fetched keys, and exposed
  trusted-key timing before Step 8 Part B. No option or access route was selected.
- Synchronized draft, requirement AC16/AC17 and clarifications, design decisions,
  plan decisions and gate ledger, validation expectations, pending umbrella
  narrative and private mapping. Preserved earlier validation evidence.
- Placed Q34-Q36 through the canonical open-question companion workflow.

### Human guidance and writer response for plan deploy-venv-sync (exchange 2) (round 7)

Human guidance:

Human decision on 2026-10-04, given at the round 6 convergence gate.

**Revise and review again.** Keep Q11 to Q33, R1 to R15 and every Step 9 decision intact unless this guidance changes them for Step 8.

**1. Step 8's goal.** Step 8 tests one deployment on the qualification environment through the original orchestration state, restored and unchanged. It builds on the existing deployment there: the dispatcher, the stable stop and start scripts and the control folders are already in place, installed by our existing delivery path in Part C. Step 8 must not depend on any operations-team operator, for anything. The only operations-team involvement left is the agreed restoration pull request, through their normal review.

**2. Fact.** Nobody on our side can open a shell as the qualification application account; the evidence is in the private mapping. So in Step 8, no part may rely on "existing maintenance access", an operator-assisted channel or a maintenance-channel terminalization. That covers Part A evidence, Part D arming and checkpoint, Part G, Part H and Part I recovery. Route (a) and route (b), and the operator-run bootstrap session, stay Step 9 only.

**3. Every target-side action in Step 8 goes through paths we already control.**

- Before restoration: the existing temporary delivery path, which runs our verified deployment entry with controller-checked inputs. It performs the bootstrap, and also the target probes, the receipts, the Part G arming and the recovery pre-authorization described below.
- After restoration: the original orchestration actions launched by our pipeline. The forward action is used for the test, and the stop/start-only action for a plain restart or a recovery.
- Evidence comes back only through the existing shared log location, our pipeline's console output and the two external endpoints.

**4. Arming for Part G.**

- Part G redeploys the same candidate Part C bootstrapped (Q22). The bootstrap deployment records, on the target, a single-use same-release selection for that later run. It is bound to the retained release record that the controller-checked delivery verified.
- Its four other inputs are reused from local retention by hash, so the stop fetches nothing.
- It stays valid until consumed or superseded, not for a short time window, because the restoration's merge date is outside our control.
- A delivery whose archive does not match that record is refused, exactly as today.

If this weakens the independent-selection guarantee, explain how in the writer response and propose operator-free alternatives for the human.

**5. Recovery for Part G without an operator.**

- The bootstrap deployment also records a recovery authorization bound to the Part G attempt and its same-release checkpoint. Our pipeline launches it through the original stop/start-only action. The typed recovery rules stay unchanged.
- Terminal proof for that attempt comes from local target evidence, checked by the stop target itself: the root lock is free, no attempt-owned process is alive, and our pipeline shows the orchestration job terminal. This replaces the maintenance-channel terminalization in Step 8.

**6. Part A target evidence.** Gather it through the bootstrap deployment's own read-only probes and receipts, returned through the shared log location: the current dispatcher and closure state, the unit identity, repository reachability from the target, and the HTTP client. The inherited orchestration defaults come from our pipeline's console output of the check-mode traversal. Anything that cannot be obtained that way is a gate reported to the human, never an operator request.

**7. Consistency.** Where the requirement or the design names an operator-assisted channel as the first route, scope that to Step 9. For Step 8, record this decision as a dated human decision in the requirement clarifications, the design decisions and the plan decisions. Update AC16 and AC17 so they cannot be read as requiring operator access. Any new implementation choice becomes a plan question through the canonical workflow.

**8. Open design choice for Step 9: operator-free arming of later deployments.** The Step 8 arming above works only because the test redeploys the release the bootstrap already knows. After the restoration, deploying a different release, on the qualification environment or in production, needs a selection the target cannot receive through the unchanged orchestration: the delivered archive cannot vouch for itself, and the stop and start commands take no parameters. Without a new mechanism, every later deployment depends on route (a) or route (b). Record this in the design and the writer response as an open human decision with these options:

- **Recommended: a signed selection.** The pipeline, or a named publisher, signs each selection, which carries the exact hashes, canonical URLs, a single-use attempt identity and an expiry. It is published to a known per-environment location in the artifact repository. The stop target downloads it with its other inputs and verifies the signature against a public key that ships inside the verified stable-script closure. The bootstrap installs that key; on the qualification environment that is the existing delivery path, with no operator. A new key arrives in a later release and becomes active only when that release's stable scripts are activated after a successful deployment. Costs to state: signing-key custody and rotation, one small published object per deployment, and a known fetch location made safe by the signature, attempt identity and expiry. Those last two conflict with the earlier "no new publication object" and "no moving resolution" rules, so the human must extend them explicitly.
- **Alternative: a selection fetched over fully verified TLS** from an artifact-repository path that only the publisher can write. It needs no key, but repository write permission becomes the trust root.
- **Rejected:** downloading the verification key from the artifact repository on first use. It only proves the selection came from the repository.

The one-time bootstrap on an environment without the temporary delivery path still needs route (a) or route (b) once, whichever option is chosen. If the human selects the signed selection before Part B is implemented, the key must already be part of the closure that Step 8 qualifies, so that later deployments on the qualification environment need no operator.

Concrete accounts, hosts and log locations belong to the private mapping only. Keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Writer response:

The supplied human guidance is preserved verbatim and was passed unchanged to
confirm "Revise and review again". Round 6's accepted Q31-Q33 implementation
recommendations remain. No reviewer wording edit was outstanding.

The former Step 8 operator route was unsupported and is removed. Existing temporary
delivery is the only pre-restoration target path; our pipeline's original actions
are the only post-restoration path. A declares target evidence collected in C,
so those results are required before E, not before the bootstrap that obtains them.
Retained check-console evidence supplies inherited defaults and F reconfirms them.
Any inaccessible fact stays a human gate without an operator request.

Independent selection is narrowed in scope, not replaced by archive self-trust:
C's controller-verified retained record authorizes the later G archive. It covers
only the same release and does not establish selection of a different release
after restoration. No short expiry applies across an uncontrolled merge date;
single-use attempt, target binding, consumption/supersession and exact hashes
remain mandatory, with a bounded execution reservation after stop.

C records separate forward and conditional recovery authority. Fixed stop/start
arguments cannot communicate a new intention or terminal job proof. The pipeline
therefore gates which original action may launch, proves the prior job terminal,
and blocks ordinary restart while selection authority is outstanding. Stop verifies
local root-lock/process quiescence and terminalizes the bound G attempt itself.
The next authorized stop/start after G uses that checkpoint recovery; failed
recovery checks retain authority, full success consumes it. No-pending/checkpoint
and typed pending rules remain intact, including successful G followed by failed
external H checks. Q35/Q36 explicitly qualify the composed behavior without a
maintenance channel. Unknown proof refuses; there is no claimed automatic rescue
for an ambiguous live process or unavailable receipt.

For later different releases, the operator-free alternatives are now explicit in
the design: signed selection is recommended; publisher-only fully verified TLS
selection is the alternative; fetching a verification key on first use is rejected.
The human must extend the publication-object and moving-location rules and decide
key custody/rotation and trusted-key timing. If signed selection is chosen before
Step 8 B, its key must be in that qualified closure and bootstrap, avoiding later
qualification operator access. No option is chosen. Step 9 environments without
temporary delivery still need one-time bootstrap through a human-selected route.
Venue and empty-prefix hook placement remain independent open design decisions.

No implementation, product test, pipeline, target, operations action, commit or
push occurred. Review coordination and documentation checks are the only commands
beyond reads and documentation edits. Concrete facts remain in the private mapping.

### Reviewer focus for plan deploy-venv-sync (exchange 2) (round 7)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-7 -->

## Round 7 by reviewer

- Recorded: 2026-10-04T18:14:04+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync round 7

Round 7 applies the round 6 guidance thoroughly:

- Step 8's goal is restated as one operator-free deployment on the qualification environment, through the restored original orchestration, on top of the bootstrap that Part C installs through the existing delivery path.
- Part A defines the target probes that Part C itself collects, so nothing is required before it can be observed.
- Part D is receipt verification only.
- Parts G to I need no maintenance channel: the pipeline proves the job terminal, and the stop target proves root-lock and process quiescence locally.
- The operator routes are scoped to Step 9.
- The signed selection is recorded as the recommended, still unselected Step 9 option, with the alternative and the rejected first-use key fetch.

Q34 to Q36 are sound implementation questions. Q11 to Q33 are scoped correctly where the guidance supersedes them.

The new one-run arming, though, leaves three gaps. Each can make Step 8 fail to complete, or block the environment, with no operator-free way out:

1. **A stop/start-only run burns the pending forward selection.**
   - Our pipeline gate covers only our own launches. The managed job can also be started outside our pipeline, by the operations team or by a schedule.
   - A stop/start-only run while the Part G selection is pending reserves the G attempt at stop. Start then refuses "armed deploy, nothing delivered", and the attempt is failed. G is lost, and after restoration nothing can re-arm it without an operator.
   - In the forward action, a failed delivery ends the role before start. So that start row can only come from a stop/start-only action, and it can be handled without ambiguity.
2. **One transient failure ends the step for good.** After restoration, Step 8 offers exactly one attempt and no operator-free re-arming. A transient failure before full success, such as an exceeded staging cap or a flaky runtime check, therefore ends Step 8 without AC16. The round 6 guidance said "single-use", which produced this; the human should decide whether the bootstrap-recorded selection may admit bounded retries of the exact same release.
3. **The recovery authority has no end.** It is consumed only by a successful recovery, and ordinary restart is available only when no selection is outstanding. If Part G succeeds and recovery is never needed, nothing retires that authority, and ordinary restart stays blocked indefinitely.

Gaps 1 and 2 touch the settled mode table and the round 6 guidance, so they are listed below as human decisions, with recommendations. Gap 3 is a plan-level definition. Concrete evidence is in the private round 7 notes named in the writer instructions.

### Question verdicts for plan deploy-venv-sync round 7

**Q11 to Q33, option A: agree, as scoped by the round 6 guidance.**

**Q34, option A: agree.** The A/C/E dependency ledger correctly separates pre-bootstrap safety gates from observations the bootstrap supplies.

**Q35, option A: agree, with R16 to R18.** Add three things:

- a stop/start-only run never reserves, consumes or fails the pending forward selection;
- the retry rule the human selects under R17;
- the recovery authority is retired when Part G fully succeeds.

**Q36, option A: agree.** Add an out-of-band stop/start-only launch, while the forward selection is pending, to its adversarial cases.

**No missing implementation question.** R16 and R17 are human decisions, listed in the requested changes.

### Requested changes for plan deploy-venv-sync round 7

Requested changes:

1. **R16, a stop/start-only run must not burn the pending forward selection** (human decision: it changes a settled mode-table row).
   - Record that the managed job can be launched outside our pipeline, so P22's gate covers only our own launches.
   - Also record that in the forward action a failed delivery ends the role before start. "Armed deploy, nothing delivered" at start can therefore only come from a stop/start-only action.
   - Recommended handling: the stop leaves the forward selection pending and unused; the start restarts the last working release with the full held runtime and supervision checks, releases its own reservation, and records a receipt. Its exit status comes from those checks, so a correct restart launched by the operations team does not fail their job.
   - List it for the human with the alternative: keep the current refusal and accept that such a launch loses Part G.
   - Test it in P35/Q36, before and after restoration.
2. **R17, retries of the exact same release** (human decision: it amends "single-use" in the round 6 guidance).
   - With no operator-free re-arming after restoration, one transient failure before full success ends Step 8 without AC16.
   - Recommended: the bootstrap-recorded same-release selection admits repeated forward attempts of that exact release until the first full success. Each attempt gets its own reservation and terminal proof, and the count is bounded and recorded at Part C. Recovery after each failed attempt keeps the same-release checkpoint.
   - Alternatives to list for the human:
     - **(b)** decide the Step 9 signed selection before Part B, so that a fresh selection can be published after restoration;
     - **(c)** keep a single attempt and accept the risk.
   - Test the retry count, its exhaustion and its interaction with recovery.
3. **R18, recovery authority lifetime (Part D, Part I, Q35).**
   - Retire the conditional recovery authority when Part G fully succeeds. Because the checkpoint is the same release, a failed external check after a successful Part G is handled by an ordinary stop/start-only restart with the full runtime checks. It needs no recovery authority, and ordinary restart is never blocked indefinitely.
   - Keep the authority, unchanged, for a failed Part G attempt.
   - Test the success-then-failed-external-check path and the restart after it.

### Human guidance response for plan deploy-venv-sync round 7

Human guidance:

Human decision on 2026-10-04, given at the round 6 convergence gate.

**Revise and review again.** Keep Q11 to Q33, R1 to R15 and every Step 9 decision intact unless this guidance changes them for Step 8.

**1. Step 8's goal.** Step 8 tests one deployment on the qualification environment through the original orchestration state, restored and unchanged. It builds on the existing deployment there: the dispatcher, the stable stop and start scripts and the control folders are already in place, installed by our existing delivery path in Part C. Step 8 must not depend on any operations-team operator, for anything. The only operations-team involvement left is the agreed restoration pull request, through their normal review.

**2. Fact.** Nobody on our side can open a shell as the qualification application account; the evidence is in the private mapping. So in Step 8, no part may rely on "existing maintenance access", an operator-assisted channel or a maintenance-channel terminalization. That covers Part A evidence, Part D arming and checkpoint, Part G, Part H and Part I recovery. Route (a) and route (b), and the operator-run bootstrap session, stay Step 9 only.

**3. Every target-side action in Step 8 goes through paths we already control.**

- Before restoration: the existing temporary delivery path, which runs our verified deployment entry with controller-checked inputs. It performs the bootstrap, and also the target probes, the receipts, the Part G arming and the recovery pre-authorization described below.
- After restoration: the original orchestration actions launched by our pipeline. The forward action is used for the test, and the stop/start-only action for a plain restart or a recovery.
- Evidence comes back only through the existing shared log location, our pipeline's console output and the two external endpoints.

**4. Arming for Part G.**

- Part G redeploys the same candidate Part C bootstrapped (Q22). The bootstrap deployment records, on the target, a single-use same-release selection for that later run. It is bound to the retained release record that the controller-checked delivery verified.
- Its four other inputs are reused from local retention by hash, so the stop fetches nothing.
- It stays valid until consumed or superseded, not for a short time window, because the restoration's merge date is outside our control.
- A delivery whose archive does not match that record is refused, exactly as today.

If this weakens the independent-selection guarantee, explain how in the writer response and propose operator-free alternatives for the human.

**5. Recovery for Part G without an operator.**

- The bootstrap deployment also records a recovery authorization bound to the Part G attempt and its same-release checkpoint. Our pipeline launches it through the original stop/start-only action. The typed recovery rules stay unchanged.
- Terminal proof for that attempt comes from local target evidence, checked by the stop target itself: the root lock is free, no attempt-owned process is alive, and our pipeline shows the orchestration job terminal. This replaces the maintenance-channel terminalization in Step 8.

**6. Part A target evidence.** Gather it through the bootstrap deployment's own read-only probes and receipts, returned through the shared log location: the current dispatcher and closure state, the unit identity, repository reachability from the target, and the HTTP client. The inherited orchestration defaults come from our pipeline's console output of the check-mode traversal. Anything that cannot be obtained that way is a gate reported to the human, never an operator request.

**7. Consistency.** Where the requirement or the design names an operator-assisted channel as the first route, scope that to Step 9. For Step 8, record this decision as a dated human decision in the requirement clarifications, the design decisions and the plan decisions. Update AC16 and AC17 so they cannot be read as requiring operator access. Any new implementation choice becomes a plan question through the canonical workflow.

**8. Open design choice for Step 9: operator-free arming of later deployments.** The Step 8 arming above works only because the test redeploys the release the bootstrap already knows. After the restoration, deploying a different release, on the qualification environment or in production, needs a selection the target cannot receive through the unchanged orchestration: the delivered archive cannot vouch for itself, and the stop and start commands take no parameters. Without a new mechanism, every later deployment depends on route (a) or route (b). Record this in the design and the writer response as an open human decision with these options:

- **Recommended: a signed selection.** The pipeline, or a named publisher, signs each selection, which carries the exact hashes, canonical URLs, a single-use attempt identity and an expiry. It is published to a known per-environment location in the artifact repository. The stop target downloads it with its other inputs and verifies the signature against a public key that ships inside the verified stable-script closure. The bootstrap installs that key; on the qualification environment that is the existing delivery path, with no operator. A new key arrives in a later release and becomes active only when that release's stable scripts are activated after a successful deployment. Costs to state: signing-key custody and rotation, one small published object per deployment, and a known fetch location made safe by the signature, attempt identity and expiry. Those last two conflict with the earlier "no new publication object" and "no moving resolution" rules, so the human must extend them explicitly.
- **Alternative: a selection fetched over fully verified TLS** from an artifact-repository path that only the publisher can write. It needs no key, but repository write permission becomes the trust root.
- **Rejected:** downloading the verification key from the artifact repository on first use. It only proves the selection came from the repository.

The one-time bootstrap on an environment without the temporary delivery path still needs route (a) or route (b) once, whichever option is chosen. If the human selects the signed selection before Part B is implemented, the key must already be part of the closure that Step 8 qualifies, so that later deployments on the qualification environment need no operator.

Concrete accounts, hosts and log locations belong to the private mapping only. Keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Guidance response:

Every item of the round 6 guidance is applied:

1. Step 8's operator-free goal is restated.
2. No Step 8 part relies on maintenance or operator access.
3. Target actions use only the existing delivery path and pipeline-launched original actions.
4. Part G is armed by the bootstrap deployment.
5. Recovery uses pipeline-proven job termination plus local proof.
6. Part A evidence comes from bootstrap probes and check-mode console output.
7. The requirement, design and plan decisions are consistent.
8. The signed selection is recorded as the recommended, still open Step 9 option.

Two consequences of that guidance need the human's attention, and the requested changes list them:

- The guidance's "single-use" wording leaves Step 8 one transient failure away from incompleteness (R17).
- The guidance assumes our pipeline is the only launcher, but the managed job can be launched outside it (R16).

### Writer instructions for plan deploy-venv-sync round 7

Read the private notes at `.reviews/a.dvs-step8-plan-r7.reviewer-notes.md` first; keep their references private.

- **R18:** apply it to Part D, Part I and Q35, and to the P35/Q36 test lists.
- **R16 and R17:** they change a settled mode-table row and the round 6 guidance's "single-use" wording. Do not settle them in the plan. List both in the next writer response as human decisions, with the recommended handling and the alternatives given in the requested changes. Mark the affected Part C, D, G and I rules as pending those decisions in the ledger.

Keep every other boundary: no implementation, test, pipeline, target or operations action, and no commit. Rerun the mandatory Markdown gate and the sensitive scan of the edited public files before publishing the next round.

### Final reviewer decision for plan deploy-venv-sync round 7

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-7 -->

## Round 8 by requestor

- Recorded: 2026-10-04T18:19:30+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (round 8)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 8

### Requestor assessment for plan deploy-venv-sync (round 8)

Round 7's R18 correction is applied in Part D, Part I, Q35/Q36 and P35 coverage,
with matching requirement, design, validation and private-mapping wording. Full G
success retires conditional recovery with forward finalization; failed G preserves
it, and failed H after successful G uses an ordinary checked restart of the same
release. The external failure remains failed and no older predecessor is selected.

R16 and R17 are recorded as open human design decisions, with recommendations and
alternatives, rather than silently changing the settled refusal or single-use rule.
The C/D/G/I ledger blocks affected work. P22 only gates our launches; other
authorized managed-job launches and schedules are now explicit.

No implementation question is missing at this pass. Q11-Q34 are unchanged from
round 7. Q35/Q36 retain option A and now cover R18 and future tests against the
human-selected R16/R17 rules. These are not answers to the two human decisions.
The updated questions were placed through the canonical companion workflow.

Please assess whether the instructions have been applied and the plan can reach
the human gate with R16/R17 explicitly open. No implementation-readiness claim
overrides those decisions, Step 9's other open design choices or execution gates.

### Change summary for plan deploy-venv-sync (round 8)

- Applied R18: successful G retires conditional recovery atomically with forward
  finalization; failed G retains it; failed H after successful G uses ordinary
  restart with full held runtime/supervision checks and no rollback.
- Added the C/D/G/I human-decision gate ledger and matching design options for
  R16 outside launches and R17 forward retries. No recommendation is selected.
- Recorded that P22 cannot gate outside managed-job launches, and that failed
  original forward delivery aborts before start. The mode row remains under review.
- Updated P35, Q35/Q36 and validation to cover success retirement, external-failure
  restart, outside stop/start before/after restoration and the eventual selected
  attempt/count/exhaustion/recovery policy.
- Synchronized requirement, design and private mapping. Preserved earlier
  implementation questions, validation evidence and all Step 9 human choices.

### Human guidance and writer response for plan deploy-venv-sync (round 8)

Human guidance:

Human decision on 2026-10-04, given at the round 6 convergence gate.

**Revise and review again.** Keep Q11 to Q33, R1 to R15 and every Step 9 decision intact unless this guidance changes them for Step 8.

**1. Step 8's goal.** Step 8 tests one deployment on the qualification environment through the original orchestration state, restored and unchanged. It builds on the existing deployment there: the dispatcher, the stable stop and start scripts and the control folders are already in place, installed by our existing delivery path in Part C. Step 8 must not depend on any operations-team operator, for anything. The only operations-team involvement left is the agreed restoration pull request, through their normal review.

**2. Fact.** Nobody on our side can open a shell as the qualification application account; the evidence is in the private mapping. So in Step 8, no part may rely on "existing maintenance access", an operator-assisted channel or a maintenance-channel terminalization. That covers Part A evidence, Part D arming and checkpoint, Part G, Part H and Part I recovery. Route (a) and route (b), and the operator-run bootstrap session, stay Step 9 only.

**3. Every target-side action in Step 8 goes through paths we already control.**

- Before restoration: the existing temporary delivery path, which runs our verified deployment entry with controller-checked inputs. It performs the bootstrap, and also the target probes, the receipts, the Part G arming and the recovery pre-authorization described below.
- After restoration: the original orchestration actions launched by our pipeline. The forward action is used for the test, and the stop/start-only action for a plain restart or a recovery.
- Evidence comes back only through the existing shared log location, our pipeline's console output and the two external endpoints.

**4. Arming for Part G.**

- Part G redeploys the same candidate Part C bootstrapped (Q22). The bootstrap deployment records, on the target, a single-use same-release selection for that later run. It is bound to the retained release record that the controller-checked delivery verified.
- Its four other inputs are reused from local retention by hash, so the stop fetches nothing.
- It stays valid until consumed or superseded, not for a short time window, because the restoration's merge date is outside our control.
- A delivery whose archive does not match that record is refused, exactly as today.

If this weakens the independent-selection guarantee, explain how in the writer response and propose operator-free alternatives for the human.

**5. Recovery for Part G without an operator.**

- The bootstrap deployment also records a recovery authorization bound to the Part G attempt and its same-release checkpoint. Our pipeline launches it through the original stop/start-only action. The typed recovery rules stay unchanged.
- Terminal proof for that attempt comes from local target evidence, checked by the stop target itself: the root lock is free, no attempt-owned process is alive, and our pipeline shows the orchestration job terminal. This replaces the maintenance-channel terminalization in Step 8.

**6. Part A target evidence.** Gather it through the bootstrap deployment's own read-only probes and receipts, returned through the shared log location: the current dispatcher and closure state, the unit identity, repository reachability from the target, and the HTTP client. The inherited orchestration defaults come from our pipeline's console output of the check-mode traversal. Anything that cannot be obtained that way is a gate reported to the human, never an operator request.

**7. Consistency.** Where the requirement or the design names an operator-assisted channel as the first route, scope that to Step 9. For Step 8, record this decision as a dated human decision in the requirement clarifications, the design decisions and the plan decisions. Update AC16 and AC17 so they cannot be read as requiring operator access. Any new implementation choice becomes a plan question through the canonical workflow.

**8. Open design choice for Step 9: operator-free arming of later deployments.** The Step 8 arming above works only because the test redeploys the release the bootstrap already knows. After the restoration, deploying a different release, on the qualification environment or in production, needs a selection the target cannot receive through the unchanged orchestration: the delivered archive cannot vouch for itself, and the stop and start commands take no parameters. Without a new mechanism, every later deployment depends on route (a) or route (b). Record this in the design and the writer response as an open human decision with these options:

- **Recommended: a signed selection.** The pipeline, or a named publisher, signs each selection, which carries the exact hashes, canonical URLs, a single-use attempt identity and an expiry. It is published to a known per-environment location in the artifact repository. The stop target downloads it with its other inputs and verifies the signature against a public key that ships inside the verified stable-script closure. The bootstrap installs that key; on the qualification environment that is the existing delivery path, with no operator. A new key arrives in a later release and becomes active only when that release's stable scripts are activated after a successful deployment. Costs to state: signing-key custody and rotation, one small published object per deployment, and a known fetch location made safe by the signature, attempt identity and expiry. Those last two conflict with the earlier "no new publication object" and "no moving resolution" rules, so the human must extend them explicitly.
- **Alternative: a selection fetched over fully verified TLS** from an artifact-repository path that only the publisher can write. It needs no key, but repository write permission becomes the trust root.
- **Rejected:** downloading the verification key from the artifact repository on first use. It only proves the selection came from the repository.

The one-time bootstrap on an environment without the temporary delivery path still needs route (a) or route (b) once, whichever option is chosen. If the human selects the signed selection before Part B is implemented, the key must already be part of the closure that Step 8 qualifies, so that later deployments on the qualification environment need no operator.

Concrete accounts, hosts and log locations belong to the private mapping only. Keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Writer response:

I accept round 7's findings and applied R18. Conditional recovery no longer survives
full G success. It remains unchanged after failed G and across failed recovery
checks, and is consumed by complete recovery success. Successful G followed by
failed H uses ordinary stop/start of the same installed release, with full held
runtime/supervision checks, no rollback and the external failure retained.

R16 and R17 require human decisions. They are recorded in the design and the
plan's C/D/G/I gate ledger; neither is settled by this response.

| Decision | Recommendation | Alternatives and cost |
| --- | --- | --- |
| R16: outside stop/start with pending forward selection | Keep forward selection pending and unused; restart the last working release with a separate reservation, full held runtime/supervision checks and receipt. Release that reservation and return the checks' status, so a correct outside restart succeeds. | Keep the current refusal and accept that an outside launch loses G. The recommended option changes the settled mode row and needs before/after-restoration adversarial fixtures. |
| R17: attempts after a transient forward failure | Let C record a bounded count of attempts of its exact release until first full success. Each gets a fresh reservation and terminal proof; recovery keeps the same-release checkpoint. | (b) Choose Step 9 signed selection before B, permitting publication of fresh selections after restoration with its trust/publication decisions; or (c) keep one attempt and accept the risk that AC16 cannot complete. Recommended retries require explicit amendment of single-use guidance and count/exhaustion/recovery fixtures. |

The managed job can be launched outside P22; no route or configuration restriction
is invented. Original forward delivery failure aborts before start, so armed start
with unchanged staging can identify stop/start-only. This supports the R16
recommendation but does not authorize replacing the settled refusal row.

Q35/Q36 are amended through the open-question companion workflow, without new
implementation questions. Signed selection, rehearsal venue, Step 9 access routes
and empty-prefix hook placement remain open. The round 6 human guidance is repeated
verbatim; no file content was changed. No implementation, product test, pipeline,
target or operations action, commit or push occurred. Private evidence remains
outside tracked documents.

### Reviewer focus for plan deploy-venv-sync (round 8)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-8 -->

## Round 8 by reviewer

- Recorded: 2026-10-04T18:22:01+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync round 8

Round 8 applies the round 7 answer exactly:

- **R18:** a fully successful Part G retires the conditional recovery authority together with the forward finalization, so an unused authority can no longer block ordinary restart. A failed Part G keeps it. A failed external check after a successful Part G uses an ordinary checked restart of the same release, with no rollback, and keeps the external failure on record. Part D, Part I, Q35, Q36, the P35 test list and the requirement, design and validation wording all match.
- **R16 and R17:** both are recorded as open human decisions, in the design and in a new Part C/D/G/I gate ledger, with the recommendation and alternatives from the round 7 answer. Nothing is chosen in the plan. The plan now states that our pipeline gates only its own launches, and that a failed forward delivery ends before start.

Q11 to Q36 are settled, and I agree with every recommended answer. No wording edit remains.

What stays open is entirely human decisions, each recorded as a blocking gate rather than as missing plan text:

- **Step 8:** R16, the handling of an outside stop/start-only launch while the forward selection is pending; and R17, the retry policy for the same-release forward attempt.
- **Step 9:** the operator-free arming mechanism for later deployments (signed selection recommended), the rehearsal venue, the access route per environment, and the empty-prefix hook placement.

R16 and R17 block Step 8's Parts C, D, G and I until decided. Parts A and B can proceed. I recommend convergence.

### Question verdicts for plan deploy-venv-sync round 8

**Q11 to Q34, option A: agree, unchanged since round 7.**

**Q35, option A: agree.** The recovery authority's lifetime is now complete, and the open R16/R17 policies are referenced, not decided.

**Q36, option A: agree.** It now covers success retirement, the restart after a failed external check, and outside stop/start launches before and after restoration.

**No missing implementation question.**

**Human decisions with the reviewer's recommendation:**

- **R16:** keep the forward selection pending and unused, and restart with the full checks, returning their status.
- **R17:** allow bounded same-release retries until the first full success, recorded at Part C. Alternatively, decide the Step 9 signed selection before Part B.

### Convergence evidence for plan deploy-venv-sync round 8

Covered wording:

No wording edit remains. The plan, the requirement and the design can be consolidated as they stand. If the human settles R16, R17 or any of the Step 9 decisions, record them afterwards under the gate's chosen owning action.

Convergence rationale:

Every implementation decision for Steps 8 and 9 is settled: Q11 to Q36 have agreed answers, and requested changes R1 to R15 and R18 are applied. The round 6 guidance is fully carried by the requirement, the design, the plan, the validation expectations and the private mapping.

The remaining items are human design decisions, recorded as blocking gates: R16 and R17 for Step 8, and the arming mechanism, venue, access routes and empty-prefix hook placement for Step 9. Settling them changes ledger entries and the policies they reference, not the implementation decisions already made.

AC16 to AC19 remain open until separately authorized execution.

### Human guidance response for plan deploy-venv-sync round 8

Human guidance:

Human decision on 2026-10-04, given at the round 6 convergence gate.

**Revise and review again.** Keep Q11 to Q33, R1 to R15 and every Step 9 decision intact unless this guidance changes them for Step 8.

**1. Step 8's goal.** Step 8 tests one deployment on the qualification environment through the original orchestration state, restored and unchanged. It builds on the existing deployment there: the dispatcher, the stable stop and start scripts and the control folders are already in place, installed by our existing delivery path in Part C. Step 8 must not depend on any operations-team operator, for anything. The only operations-team involvement left is the agreed restoration pull request, through their normal review.

**2. Fact.** Nobody on our side can open a shell as the qualification application account; the evidence is in the private mapping. So in Step 8, no part may rely on "existing maintenance access", an operator-assisted channel or a maintenance-channel terminalization. That covers Part A evidence, Part D arming and checkpoint, Part G, Part H and Part I recovery. Route (a) and route (b), and the operator-run bootstrap session, stay Step 9 only.

**3. Every target-side action in Step 8 goes through paths we already control.**

- Before restoration: the existing temporary delivery path, which runs our verified deployment entry with controller-checked inputs. It performs the bootstrap, and also the target probes, the receipts, the Part G arming and the recovery pre-authorization described below.
- After restoration: the original orchestration actions launched by our pipeline. The forward action is used for the test, and the stop/start-only action for a plain restart or a recovery.
- Evidence comes back only through the existing shared log location, our pipeline's console output and the two external endpoints.

**4. Arming for Part G.**

- Part G redeploys the same candidate Part C bootstrapped (Q22). The bootstrap deployment records, on the target, a single-use same-release selection for that later run. It is bound to the retained release record that the controller-checked delivery verified.
- Its four other inputs are reused from local retention by hash, so the stop fetches nothing.
- It stays valid until consumed or superseded, not for a short time window, because the restoration's merge date is outside our control.
- A delivery whose archive does not match that record is refused, exactly as today.

If this weakens the independent-selection guarantee, explain how in the writer response and propose operator-free alternatives for the human.

**5. Recovery for Part G without an operator.**

- The bootstrap deployment also records a recovery authorization bound to the Part G attempt and its same-release checkpoint. Our pipeline launches it through the original stop/start-only action. The typed recovery rules stay unchanged.
- Terminal proof for that attempt comes from local target evidence, checked by the stop target itself: the root lock is free, no attempt-owned process is alive, and our pipeline shows the orchestration job terminal. This replaces the maintenance-channel terminalization in Step 8.

**6. Part A target evidence.** Gather it through the bootstrap deployment's own read-only probes and receipts, returned through the shared log location: the current dispatcher and closure state, the unit identity, repository reachability from the target, and the HTTP client. The inherited orchestration defaults come from our pipeline's console output of the check-mode traversal. Anything that cannot be obtained that way is a gate reported to the human, never an operator request.

**7. Consistency.** Where the requirement or the design names an operator-assisted channel as the first route, scope that to Step 9. For Step 8, record this decision as a dated human decision in the requirement clarifications, the design decisions and the plan decisions. Update AC16 and AC17 so they cannot be read as requiring operator access. Any new implementation choice becomes a plan question through the canonical workflow.

**8. Open design choice for Step 9: operator-free arming of later deployments.** The Step 8 arming above works only because the test redeploys the release the bootstrap already knows. After the restoration, deploying a different release, on the qualification environment or in production, needs a selection the target cannot receive through the unchanged orchestration: the delivered archive cannot vouch for itself, and the stop and start commands take no parameters. Without a new mechanism, every later deployment depends on route (a) or route (b). Record this in the design and the writer response as an open human decision with these options:

- **Recommended: a signed selection.** The pipeline, or a named publisher, signs each selection, which carries the exact hashes, canonical URLs, a single-use attempt identity and an expiry. It is published to a known per-environment location in the artifact repository. The stop target downloads it with its other inputs and verifies the signature against a public key that ships inside the verified stable-script closure. The bootstrap installs that key; on the qualification environment that is the existing delivery path, with no operator. A new key arrives in a later release and becomes active only when that release's stable scripts are activated after a successful deployment. Costs to state: signing-key custody and rotation, one small published object per deployment, and a known fetch location made safe by the signature, attempt identity and expiry. Those last two conflict with the earlier "no new publication object" and "no moving resolution" rules, so the human must extend them explicitly.
- **Alternative: a selection fetched over fully verified TLS** from an artifact-repository path that only the publisher can write. It needs no key, but repository write permission becomes the trust root.
- **Rejected:** downloading the verification key from the artifact repository on first use. It only proves the selection came from the repository.

The one-time bootstrap on an environment without the temporary delivery path still needs route (a) or route (b) once, whichever option is chosen. If the human selects the signed selection before Part B is implemented, the key must already be part of the closure that Step 8 qualifies, so that later deployments on the qualification environment need no operator.

Concrete accounts, hosts and log locations belong to the private mapping only. Keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Guidance response:

The round 6 guidance remains fully applied. Its two consequences raised in round 7 are now explicit human decisions, R16 and R17, and its "single-use" wording is no longer treated as settled while R17 is open.

### Writer instructions for plan deploy-venv-sync round 8

No plan edit is required.

This answer recommends convergence. It does not authorize consolidation. Present the human gate with both registered choices and the open human decisions beside them:

- **R16, outside stop/start-only launch:** the recommendation is to keep the selection pending and run a checked restart.
- **R17, retry policy:** the recommendation is bounded same-release retries; the alternatives are an early signed-selection decision or a single attempt.
- **Step 9, arming mechanism for later deployments:** the signed selection is recommended.
- **Step 9, rehearsal venue:** the qualification environment is recommended.
- **Step 9, access route per environment.**
- **Step 9, empty-prefix hook placement.**

Wait for the human's selection. Do not consolidate, implement, run tests, touch the consumer or the operations repository, commit or push in this task.

### Final reviewer decision for plan deploy-venv-sync round 8

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-8 -->

## Round 8 by human - human-confirmation

- Recorded: 2026-10-04T22:01:18+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Revise and review again
Outcome: another-round
Guidance: Human decisions on 2026-10-04, given at the round 8 convergence gate.

**Revise and review again.** Apply the decisions below, which settle every open human decision except where a point says it stays open. Keep Q11 to Q36 and the applied requested changes unless a decision here supersedes them.

**Correction of a fact used since round 4.** The native host we reach directly is the qualification host itself. Our own development account has a shell there, with its own development installation in that account's home, but no systemd unit of its own. We have no shell as the qualification application account. The shared drive used for deployment logs is mounted on that host, both the non-production and the production trees. Concrete names and paths are in the private mapping.

**Decision 1 (R16): option A.** A stop/start-only launch while a forward selection is pending leaves that selection pending and unused. The start restarts the last working release with the full held runtime and supervision checks, releases its own reservation, records a receipt, and returns the checks' status.

**Decision 3: the signed selection, delivered through the shared drive.**

- **Delivery.** The human signs each selection on their workstation and writes it to a fixed per-environment folder on the shared drive. That drive is already writable from the human's workstation for both the qualification and production trees, and readable on the hosts through their NFS mounts. The stop target reads the selection before touching anything and verifies its signature against a public key that ships inside the verified stable-script closure.
- **Contents.** A selection names the exact five input hashes and canonical URLs, the target environment, a single-use attempt identity and an expiry. The host records consumed attempt identities outside staging, so a replayed file is refused.
- **Failures.** A missing, unreadable, unsigned, expired, consumed or mismatched selection refuses before any lifecycle change, with the application untouched.
- **Key custody.** The human holds the signing key on their corporate workstation for now.
- **Key loss.** The plan must address it, so that losing the key does not lock deployments out. One option is a second, offline backup public key in the closure. Propose options in a plan question; the human decides.
- **Timing.** The public key and the verification code are part of release N, qualified in Step 8 Part B and installed by the Part C bootstrap.
- **No new published object.** The arming file is not published to the artifact repository, so the "no new publication object" rule is unaffected. Its fixed location is a filesystem path, not artifact resolution.
- **Recovery** uses the same mechanism: a signed recovery selection bound to the failed attempt and its checkpoint.
- **Signature tooling** is an implementation question. It must use host utilities only, verifiable without the application's Python.
- **Production:** the same mechanism through the production tree of the shared drive. Its one-time bootstrap still goes through route (b).

**Decision 2 (R17): every Part G attempt is armed by a fresh signed selection on the shared drive, retries included.**

- This supersedes the round 6 guidance items that made the bootstrap deployment record the Part G selection and the recovery authorization. It also supersedes R17's bounded pre-recorded count and the "single-use, valid until consumed or superseded" bootstrap selection.
- Part C installs the stable closure, the public key, the probes and their receipts, and no arming.
- Each attempt, each retry and each recovery uses its own signed selection, with a short expiry chosen when it is signed.
- The other round 6 rules stay: no operator in Step 8, terminal proof from our pipeline plus the stop target's local check, and evidence returned through the shared drive, the console and the external endpoints.

**Decision 4: Step 9 rehearsals run in the development installation, with a replay of the original role.**

- Both rehearsals (empty-prefix first install, and historical upgrade and rollback) run under our own development account on the qualification host. No operations-team operator is needed, and the qualification environment is not disturbed.
- A replay script reproduces the original role's command sequence on the target: stop through the prefix dispatcher with the exact argument forms, download under the literal filename, unpack, the per-directory rename rotation, copy into staging, permission changes, then start through the dispatcher. Each replay step names the role task it reproduces, at the audited baseline. Do not install or run the orchestration tool itself.
- The replay must exercise both the literal and the expanded home argument forms, and must run commands without an intermediate shell where the role uses none.
- Accepted limits, to be stated in AC18, AC19, the design and Step 9:
  - the development installation has no service unit, so hold, parking and same-daemon supervision are not rehearsed there. A development-only "no unit" profile is allowed and is never accepted for the qualification or production environments;
  - the replay is not the managed orchestration path;
  - the unit-related first-install hooks and the historical hook bridging first run for real in production. They are backed by fixtures and by read-only production unit evidence obtained through route (b);
  - the running-release unit behavior is proven on the qualification environment by Step 8 Part G.
- AC18 and AC19 accept the development replay rehearsal together with Step 8's real managed run. The historical pair comes from the retained exact archives on that host.

**Decision 5: option (i).** On an evidenced empty prefix, the bootstrap installs the hold-aware hooks with the deployment hold set. The "do not touch the hooks" rule applies only where a release is installed or running.

**Decision 6: route (b)** for production and any new environment: an operations-team operator runs our exact self-verifying commands. Route (a) is not possible in production. With decision 3, route (b) is needed once per environment, for the bootstrap, and not before every deployment.

**Step 8 Part A addition.** Use our own development account on the qualification host to gather host-level evidence before Part C: network route and client availability towards the artifact repository, read and write access to the shared-drive folder, and a staging-time measurement with the replay script on the same disks. The replay measures filesystem cost only. Add the orchestration's per-task overhead multiplied by the remote operation count, taking the per-task overhead from retained or newly authorized check-mode console timings. The Part C probes, run as the application account, remain the final evidence, because proxy settings can differ per account.

Record these as dated human decisions in the requirement clarifications, the design decisions and the plan decisions. Update the gate ledger, AC16 to AC19, Steps 8 and 9 and the private mapping consistently. Implementation choices, such as signature tooling, key-loss handling, the replay script's location and the arming folder layout, become plan questions through the canonical workflow. Keep concrete hosts, accounts, shares and paths in the private mapping only, and keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

<!-- review-entry-id: human-confirmation-round-8 -->

## Round 9 by requestor

- Recorded: 2026-10-04T22:33:51+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (exchange 2) (round 9)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 9

### Requestor assessment for plan deploy-venv-sync (exchange 2) (round 9)

The round 8 human decisions are now integrated across the topic draft,
requirement, design, plan, validation expectations, umbrella row and private
mapping. The exact supplied guidance is unchanged. Round 8 requested no further
covered wording; prior accepted R1-R15 remain, and R18's failed external-check
behavior remains with the new signed-restart interpretation below.

Q11-Q36 retain their implementation allocations and accepted safeguards except
where human decisions supersede bootstrap arming, retry counts, operator access,
rehearsal venue or empty-prefix hooks. Q37-Q41 cover the implementation questions
introduced by those decisions. Each has options, costs, a recommendation and a
proposed answer. No other missing implementation question is known; please check
completeness and the interactions rather than treating recommendations as settled.

| Question | Proposed answer | Review focus |
| --- | --- | --- |
| Q37 | A: qualify one evidenced key-format/host-utility adapter | No assumed key algorithm, private-key access or application Python |
| Q38 | A: pre-provision an independent offline backup key | Explicit human key-loss policy choice, as requested in the guidance |
| Q39 | A: versioned consumer replay helper P43 | Step 8 staging-only subset before C; Step 9 lifecycle mode after AC16/AC17 |
| Q40 | A: fixed ready-envelope path and atomic publication | Evidence filesystem semantics, authenticate local snapshot, preserve replay state |
| Q41 | A: one journal separates reservation, spent identity and success | Crash safety, failed-use replay refusal and the R16 release exception |

Please review one explicit writer interpretation: because decision 3 requires
missing signed authority to refuse before any lifecycle change, an ordinary
restart without pending forward intent needs a signed restart payload bound to
the working checkpoint and authorizing no installation. That also covers failed
external H after successful G. It is not presented as an independently selected
human option. The requirement/design contain this interpretation so the state
table has no unsigned restart gap; Q41 asks whether it follows the settled rule.

A valid pending forward selection remains unused after an identified R16
stop/start-only launch, including a checked failed restart with held-state
receipt. Failed/interrupted forward or recovery use cannot reuse authority.
Unknown interrupted use fails closed. A reservation is not a success receipt;
consumed attempt state and spent signature identity are distinct.

AC16-AC19 remain unexecuted. The development replay cannot establish managed
orchestration or service-unit behavior. The accepted combined evidence and
first-real-production hook/bridge limits are explicit. No product execution is
claimed by these documentation changes.

### Change summary for plan deploy-venv-sync (exchange 2) (round 9)

Applied all human round 8 decisions consistently:

- R16 option A restarts/checks the working release, releases its own reservation,
  records and returns the checks' status, leaving forward intent pending/unused.
- Every deployment attempt, retry and recovery needs a fresh short-lived signature
  with a unique ID. C installs trust/probes/retention/activation receipts only.
  Bootstrap arming, non-expiring authority and pre-recorded retry counts are gone.
- Human workstation signing and a fixed per-environment shared-drive folder replace
  artifact-repository arming. Release N contains the public key and host-utility
  verifier, qualified in B and installed in C. Exact five hashes/URLs, target,
  expiry, attempt identity and recovery checkpoint binding remain mandatory.
- Step 9 C/D use the development account/installation on the qualification host.
  P43 replays audited original task order, argv, literal download filename, unpack,
  per-directory rotation, copy and permissions, with both home forms and no added
  shell. No orchestration tool is installed or run.
- AC18/AC19 state the DEV-only no-unit profile and accepted evidence limits:
  Step 8 proves running-release managed unit behavior; first-install hooks and
  historical bridging first execute with a real unit in production, backed by
  fixtures and route (b) read-only production evidence.
- Empty-prefix option (i) installs verified hold-aware hooks with initial hold.
  Installed/running bootstrap keeps hooks untouched until approved stop.
- Route (b) is selected once for production/new-environment bootstrap, with no
  recurring operator arming. Step 8 remains free of application-account shell
  and operations-operator dependencies.
- Step 8 A adds development-account network/client/shared-folder evidence and
  same-disk staging-only replay. Budget filesystem T plus operation-count N times
  evidenced orchestration overhead O, at least `2 * (T + N * O)` and `2 * D` incremental
  disk headroom. Account-specific C probes remain final.
- New Q37-Q41 were placed by the canonical open-question workflow. Private mapping
  records concrete facts and proposed file placement without public identities.

Clarified missing-authority refusal versus a reserved attempt's checked failure
restoration, authenticated restart with unexpected delivery, and preservation of
an incoming held state. Steps 1-7 validation records remain unchanged.

### Human guidance and writer response for plan deploy-venv-sync (exchange 2) (round 9)

Human guidance:

Human decisions on 2026-10-04, given at the round 8 convergence gate.

**Revise and review again.** Apply the decisions below, which settle every open human decision except where a point says it stays open. Keep Q11 to Q36 and the applied requested changes unless a decision here supersedes them.

**Correction of a fact used since round 4.** The native host we reach directly is the qualification host itself. Our own development account has a shell there, with its own development installation in that account's home, but no systemd unit of its own. We have no shell as the qualification application account. The shared drive used for deployment logs is mounted on that host, both the non-production and the production trees. Concrete names and paths are in the private mapping.

**Decision 1 (R16): option A.** A stop/start-only launch while a forward selection is pending leaves that selection pending and unused. The start restarts the last working release with the full held runtime and supervision checks, releases its own reservation, records a receipt, and returns the checks' status.

**Decision 3: the signed selection, delivered through the shared drive.**

- **Delivery.** The human signs each selection on their workstation and writes it to a fixed per-environment folder on the shared drive. That drive is already writable from the human's workstation for both the qualification and production trees, and readable on the hosts through their NFS mounts. The stop target reads the selection before touching anything and verifies its signature against a public key that ships inside the verified stable-script closure.
- **Contents.** A selection names the exact five input hashes and canonical URLs, the target environment, a single-use attempt identity and an expiry. The host records consumed attempt identities outside staging, so a replayed file is refused.
- **Failures.** A missing, unreadable, unsigned, expired, consumed or mismatched selection refuses before any lifecycle change, with the application untouched.
- **Key custody.** The human holds the signing key on their corporate workstation for now.
- **Key loss.** The plan must address it, so that losing the key does not lock deployments out. One option is a second, offline backup public key in the closure. Propose options in a plan question; the human decides.
- **Timing.** The public key and the verification code are part of release N, qualified in Step 8 Part B and installed by the Part C bootstrap.
- **No new published object.** The arming file is not published to the artifact repository, so the "no new publication object" rule is unaffected. Its fixed location is a filesystem path, not artifact resolution.
- **Recovery** uses the same mechanism: a signed recovery selection bound to the failed attempt and its checkpoint.
- **Signature tooling** is an implementation question. It must use host utilities only, verifiable without the application's Python.
- **Production:** the same mechanism through the production tree of the shared drive. Its one-time bootstrap still goes through route (b).

**Decision 2 (R17): every Part G attempt is armed by a fresh signed selection on the shared drive, retries included.**

- This supersedes the round 6 guidance items that made the bootstrap deployment record the Part G selection and the recovery authorization. It also supersedes R17's bounded pre-recorded count and the "single-use, valid until consumed or superseded" bootstrap selection.
- Part C installs the stable closure, the public key, the probes and their receipts, and no arming.
- Each attempt, each retry and each recovery uses its own signed selection, with a short expiry chosen when it is signed.
- The other round 6 rules stay: no operator in Step 8, terminal proof from our pipeline plus the stop target's local check, and evidence returned through the shared drive, the console and the external endpoints.

**Decision 4: Step 9 rehearsals run in the development installation, with a replay of the original role.**

- Both rehearsals (empty-prefix first install, and historical upgrade and rollback) run under our own development account on the qualification host. No operations-team operator is needed, and the qualification environment is not disturbed.
- A replay script reproduces the original role's command sequence on the target: stop through the prefix dispatcher with the exact argument forms, download under the literal filename, unpack, the per-directory rename rotation, copy into staging, permission changes, then start through the dispatcher. Each replay step names the role task it reproduces, at the audited baseline. Do not install or run the orchestration tool itself.
- The replay must exercise both the literal and the expanded home argument forms, and must run commands without an intermediate shell where the role uses none.
- Accepted limits, to be stated in AC18, AC19, the design and Step 9:
  - the development installation has no service unit, so hold, parking and same-daemon supervision are not rehearsed there. A development-only "no unit" profile is allowed and is never accepted for the qualification or production environments;
  - the replay is not the managed orchestration path;
  - the unit-related first-install hooks and the historical hook bridging first run for real in production. They are backed by fixtures and by read-only production unit evidence obtained through route (b);
  - the running-release unit behavior is proven on the qualification environment by Step 8 Part G.
- AC18 and AC19 accept the development replay rehearsal together with Step 8's real managed run. The historical pair comes from the retained exact archives on that host.

**Decision 5: option (i).** On an evidenced empty prefix, the bootstrap installs the hold-aware hooks with the deployment hold set. The "do not touch the hooks" rule applies only where a release is installed or running.

**Decision 6: route (b)** for production and any new environment: an operations-team operator runs our exact self-verifying commands. Route (a) is not possible in production. With decision 3, route (b) is needed once per environment, for the bootstrap, and not before every deployment.

**Step 8 Part A addition.** Use our own development account on the qualification host to gather host-level evidence before Part C: network route and client availability towards the artifact repository, read and write access to the shared-drive folder, and a staging-time measurement with the replay script on the same disks. The replay measures filesystem cost only. Add the orchestration's per-task overhead multiplied by the remote operation count, taking the per-task overhead from retained or newly authorized check-mode console timings. The Part C probes, run as the application account, remain the final evidence, because proxy settings can differ per account.

Record these as dated human decisions in the requirement clarifications, the design decisions and the plan decisions. Update the gate ledger, AC16 to AC19, Steps 8 and 9 and the private mapping consistently. Implementation choices, such as signature tooling, key-loss handling, the replay script's location and the arming folder layout, become plan questions through the canonical workflow. Keep concrete hosts, accounts, shares and paths in the private mapping only, and keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Writer response:

I accept the round 8 review and the human's superseding decisions. No covered
wording remained in that answer. R16 A is selected; R17 is resolved by fresh
shared-drive signatures for every attempt/retry/recovery, not by a bootstrap
count. R18's no-rollback restart after successful G/failed H remains, now requiring
authenticated restart authority under decision 3's missing-selection refusal.

The former Step 9 design choices are now recorded as dated human decisions:
shared-drive signing with the human's own workstation key, development replay,
empty-prefix option (i) and route (b) once per production/new environment.
Neither the route nor venue remains proposed. Implementation recommendations
Q37-Q41 remain proposed, especially Q38's backup-key policy. No key algorithm,
concrete folder or implementation file is selected beyond the private proposal.

Please specifically assess the signed ordinary-restart interpretation and the
reservation/spent/success distinction. Only an identified R16 unchanged-archive
restart releases unused forward authority. A failed or ambiguous deployment use
cannot become an unsigned retry. Admission failure with no valid authority changes
no lifecycle state; an authenticated reserved delivery failure may restore its own
recorded working checkpoint while preserving the failed verdict.

The fixed shared folder is a filesystem control location, not moving artifact
resolution. No new artifact-repository object, role/job/template/library change,
or target-shell arming channel is introduced. Offline recovery uses local inputs;
its newly signed control still arrives through the existing shared drive.

Development replay explicitly lacks a unit and is not managed orchestration.
Fixtures and read-only production unit evidence support the accepted first real
production hook/bridge execution. Step 8's actual managed run supplies only the
running-release unit evidence it really proves.

This round performed documentation edits and review-workflow/document-hygiene
operations only. No implementation, product test, pipeline, target or operations
action, consumer/operations-repository edit, commit or push occurred.

### Reviewer focus for plan deploy-venv-sync (exchange 2) (round 9)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-9 -->

## Round 9 by reviewer

- Recorded: 2026-10-04T23:33:26+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync round 9

Round 9 integrates the round 8 human decisions consistently:

- **Decision 1 (R16 option A):** a pending forward selection stays unused through an outside stop/start-only launch.
- **Decision 2 (fresh signed arming):** every attempt, retry and recovery is armed by a fresh short-lived signed selection with a unique identity. The bootstrap installs trust, probes and receipts only.
- **Decision 3 (shared-drive delivery):** the human signs on their workstation into a fixed per-environment folder. The verifier and public key ship in release N.
- **Decision 4 (development replay):** P43 replays the audited task order, argument vectors and file operations, and the stated limits of a development installation without a unit are carried into AC18 and AC19.
- **Decisions 5 and 6:** empty-prefix option (i), and route (b) once per production or new environment.
- **Step 8 Part A:** the development-account evidence and the same-disk staging measurement come with the `2 * (T + N * O)` budget.

Q37 to Q41 are the right implementation questions. I agree with Q37, Q39 and Q40 as proposed, and with Q41's journal design. Q38 is correctly left to the human.

**One interpretation must be reversed: the signed ordinary restart.** The writer reads the round 8 rule "a missing, unreadable, unsigned, expired, consumed or mismatched selection refuses before any lifecycle change" as covering every stop. As a result, an ordinary restart with no pending forward intent, including the restart after a failed external check following a successful Part G, would need a freshly signed restart payload. That rule was meant for deployment authority, and this reading contradicts three settled decisions:

1. **Decision 1 (R16).** It exists so that a correct stop/start-only launch by the operations team or a schedule succeeds. Under the signed-restart reading, every such launch fails whenever the human has not signed a restart beforehand.
2. **The settled mode table.** Its "no selection, nothing delivered" row is a plain start with full checks.
3. **The signature's purpose.** The signature protects what gets installed. A restart installs nothing, and a delivery arriving without a valid selection is already refused at start without installing.

Requiring signatures for restarts also lets anyone who can write the shared folder block every restart, by leaving an invalid file there.

The correct rule is: **authorization is required to install, never to restart.** The requested change gives the exact behavior for each case. The writer asked the reviewer to check this point and was right to; because it reinterprets wording in the human's decision text, the requested change also asks the writer to put it to the human for confirmation.

### Question verdicts for plan deploy-venv-sync round 9

**Q11 to Q36: agree as amended by the human decisions.**

**Q37, option A: agree.** One qualified verifier, with key identity taken only from the verified closure, never from the selection.

**Q38: a human policy decision.** The reviewer recommends option A, a second offline backup key whose custody does not share the primary key's loss condition. It must be decided before Part B, because the public keys are frozen into release N.

**Q39, option A: agree.** A single versioned helper, with the staging-only mode in Step 8 and the lifecycle mode in Step 9.

**Q40, option A: agree.** One fixed ready-envelope per environment, atomically replaced, snapshotted locally under the root lock.

**Q41, option A: agree with the journal design. The restart sentence must change (R19).** Replace "Ordinary restart with no pending forward intent needs an authenticated restart payload for the recorded checkpoint under the missing-selection refusal rule" with the R19 rule: an ordinary restart needs no authority; only installation and recovery do.

**No missing implementation question.**

### Requested changes for plan deploy-venv-sync round 9

Requested changes:

1. **R19, authorization is required to install, never to restart.** Requirement, design, plan Step 8 (Part I, the state table, the line saying "failed H uses fresh authenticated restart authority") and Q41. Replace the signed-ordinary-restart interpretation with the following behavior.
   - **No selection at stop:** the selection folder is empty, or the shared drive is unreadable or unavailable. The stop performs an ordinary stop, with the hold and the identity checks, reserves no deployment attempt, and never consults the shared drive again in that run.
   - **A selection that is present but not currently valid:** expired, consumed, for another target, badly signed, partial or malformed. It is never acted upon. The stop records a receipt and proceeds as an ordinary stop. A stale or tampered file on a multi-writer shared drive can therefore neither block a restart nor authorize anything.
   - **A currently valid selection:** a deployment or recovery stop, exactly as designed. If nothing is delivered, the R16 rule applies: the selection stays pending and unused, and the restart is checked.
   - **Start without a valid reserved selection:**
     - nothing delivered: an ordinary checked restart of the current release, whose exit status comes from the checks;
     - something delivered: refuse. Install nothing, restart the last working release with the checks, and return nonzero.
   - **Failed external check after a successful Part G:** an ordinary stop/start-only restart with the full checks, with no signature needed.
   - **Recovery** keeps its signed recovery selection, because it reinstalls.
   - **Untouched:** the round 8 rule that an invalid selection refuses before any lifecycle change still holds for deployment and recovery authority, and the shared drive's availability affects only deployments and recoveries, never restarts.
   - **Tests in P35/P41:** absent folder, unreadable share, expired, consumed, other-target, tampered and partial files, each followed by both a stop/start-only start and a delivered start.

   This rule reinterprets wording in the human's round 8 decision text. State it in the writer response as the reviewer's correction for the human to confirm at the next gate.
2. **R20, Q38 timing.** Record in the gate ledger that the Q38 key-loss policy must be decided before Part B, because the public keys are frozen into release N's qualified closure.

### Human guidance response for plan deploy-venv-sync round 9

Human guidance:

Human decisions on 2026-10-04, given at the round 8 convergence gate.

**Revise and review again.** Apply the decisions below, which settle every open human decision except where a point says it stays open. Keep Q11 to Q36 and the applied requested changes unless a decision here supersedes them.

**Correction of a fact used since round 4.** The native host we reach directly is the qualification host itself. Our own development account has a shell there, with its own development installation in that account's home, but no systemd unit of its own. We have no shell as the qualification application account. The shared drive used for deployment logs is mounted on that host, both the non-production and the production trees. Concrete names and paths are in the private mapping.

**Decision 1 (R16): option A.** A stop/start-only launch while a forward selection is pending leaves that selection pending and unused. The start restarts the last working release with the full held runtime and supervision checks, releases its own reservation, records a receipt, and returns the checks' status.

**Decision 3: the signed selection, delivered through the shared drive.**

- **Delivery.** The human signs each selection on their workstation and writes it to a fixed per-environment folder on the shared drive. That drive is already writable from the human's workstation for both the qualification and production trees, and readable on the hosts through their NFS mounts. The stop target reads the selection before touching anything and verifies its signature against a public key that ships inside the verified stable-script closure.
- **Contents.** A selection names the exact five input hashes and canonical URLs, the target environment, a single-use attempt identity and an expiry. The host records consumed attempt identities outside staging, so a replayed file is refused.
- **Failures.** A missing, unreadable, unsigned, expired, consumed or mismatched selection refuses before any lifecycle change, with the application untouched.
- **Key custody.** The human holds the signing key on their corporate workstation for now.
- **Key loss.** The plan must address it, so that losing the key does not lock deployments out. One option is a second, offline backup public key in the closure. Propose options in a plan question; the human decides.
- **Timing.** The public key and the verification code are part of release N, qualified in Step 8 Part B and installed by the Part C bootstrap.
- **No new published object.** The arming file is not published to the artifact repository, so the "no new publication object" rule is unaffected. Its fixed location is a filesystem path, not artifact resolution.
- **Recovery** uses the same mechanism: a signed recovery selection bound to the failed attempt and its checkpoint.
- **Signature tooling** is an implementation question. It must use host utilities only, verifiable without the application's Python.
- **Production:** the same mechanism through the production tree of the shared drive. Its one-time bootstrap still goes through route (b).

**Decision 2 (R17): every Part G attempt is armed by a fresh signed selection on the shared drive, retries included.**

- This supersedes the round 6 guidance items that made the bootstrap deployment record the Part G selection and the recovery authorization. It also supersedes R17's bounded pre-recorded count and the "single-use, valid until consumed or superseded" bootstrap selection.
- Part C installs the stable closure, the public key, the probes and their receipts, and no arming.
- Each attempt, each retry and each recovery uses its own signed selection, with a short expiry chosen when it is signed.
- The other round 6 rules stay: no operator in Step 8, terminal proof from our pipeline plus the stop target's local check, and evidence returned through the shared drive, the console and the external endpoints.

**Decision 4: Step 9 rehearsals run in the development installation, with a replay of the original role.**

- Both rehearsals (empty-prefix first install, and historical upgrade and rollback) run under our own development account on the qualification host. No operations-team operator is needed, and the qualification environment is not disturbed.
- A replay script reproduces the original role's command sequence on the target: stop through the prefix dispatcher with the exact argument forms, download under the literal filename, unpack, the per-directory rename rotation, copy into staging, permission changes, then start through the dispatcher. Each replay step names the role task it reproduces, at the audited baseline. Do not install or run the orchestration tool itself.
- The replay must exercise both the literal and the expanded home argument forms, and must run commands without an intermediate shell where the role uses none.
- Accepted limits, to be stated in AC18, AC19, the design and Step 9:
  - the development installation has no service unit, so hold, parking and same-daemon supervision are not rehearsed there. A development-only "no unit" profile is allowed and is never accepted for the qualification or production environments;
  - the replay is not the managed orchestration path;
  - the unit-related first-install hooks and the historical hook bridging first run for real in production. They are backed by fixtures and by read-only production unit evidence obtained through route (b);
  - the running-release unit behavior is proven on the qualification environment by Step 8 Part G.
- AC18 and AC19 accept the development replay rehearsal together with Step 8's real managed run. The historical pair comes from the retained exact archives on that host.

**Decision 5: option (i).** On an evidenced empty prefix, the bootstrap installs the hold-aware hooks with the deployment hold set. The "do not touch the hooks" rule applies only where a release is installed or running.

**Decision 6: route (b)** for production and any new environment: an operations-team operator runs our exact self-verifying commands. Route (a) is not possible in production. With decision 3, route (b) is needed once per environment, for the bootstrap, and not before every deployment.

**Step 8 Part A addition.** Use our own development account on the qualification host to gather host-level evidence before Part C: network route and client availability towards the artifact repository, read and write access to the shared-drive folder, and a staging-time measurement with the replay script on the same disks. The replay measures filesystem cost only. Add the orchestration's per-task overhead multiplied by the remote operation count, taking the per-task overhead from retained or newly authorized check-mode console timings. The Part C probes, run as the application account, remain the final evidence, because proxy settings can differ per account.

Record these as dated human decisions in the requirement clarifications, the design decisions and the plan decisions. Update the gate ledger, AC16 to AC19, Steps 8 and 9 and the private mapping consistently. Implementation choices, such as signature tooling, key-loss handling, the replay script's location and the arming folder layout, become plan questions through the canonical workflow. Keep concrete hosts, accounts, shares and paths in the private mapping only, and keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Guidance response:

Every round 8 decision is applied. One sentence of the decision text, "a missing, unreadable, unsigned, expired, consumed or mismatched selection refuses before any lifecycle change", was written for deployment and recovery authority. The writer applied it to every stop, and that would make ordinary restarts depend on a signature, contrary to decision 1. R19 restores the intended scope. The human confirms it at the next gate.

### Writer instructions for plan deploy-venv-sync round 9

Apply R19 and R20 to the requirement, the design, Step 8, the state table, Q41, the gate ledger and the P35/P41 test lists. Name R19 in the writer response as a reviewer correction of the decision-text scope, for the human to confirm. Leave Q38 as the human's policy decision.

Keep every other boundary: no implementation, test, pipeline, target or operations action, and no commit. Rerun the mandatory Markdown gate and the sensitive scan of the edited public files before publishing the next round.

### Final reviewer decision for plan deploy-venv-sync round 9

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-9 -->

## Round 10 by requestor

- Recorded: 2026-10-04T23:41:32+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan deploy-venv-sync (exchange 2) (round 10)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Review round: 10

### Requestor assessment for plan deploy-venv-sync (exchange 2) (round 10)

The round 8 human decisions remain authoritative and verbatim. The amended
requirement, design, plan, validation expectations and private mapping implement
the selected signed shared-drive delivery, fresh attempt/recovery authority,
development replay and its evidence limits, empty-prefix hooks, bootstrap route,
and Part A evidence and timing budget.

Q11-Q41 provide the implementation questions needed at this stage. No new
implementation question is missing. Q37, Q39, Q40 and Q41 remain sufficient
proposals; Q38 remains an explicit human key-loss policy decision. R20 is applied
as a gate before Part B because the qualified release freezes its public keys.

R19 exposes a requirement/design ambiguity, not an implementation question. The
reviewer recommends ordinary restart without signature and preservation of
signed installation/recovery. I recommend that behavior too, subject to explicit
human confirmation of its availability tradeoff. With identical stop arguments,
an unsigned ordinary stop and an unsigned forward launch cannot be distinguished
before stopping. The latter can therefore cause downtime before start refuses
installation. This does change the literal pre-lifecycle refusal guarantee.

The documents now present both choices and their expected behavior, conditional
fixtures and recovery safeguards. They do not claim the reviewer can redefine
the human's guidance. Existing strict operational clauses remain pending the
choice, and their signed ordinary-restart payload is explicitly a writer proposal,
not a human-selected requirement. This remaining scope clarification belongs at
the human gate. No owning action is authorized by a readiness recommendation.

### Change summary for plan deploy-venv-sync (exchange 2) (round 10)

- Added the pending R19 human clarification consistently to the requirement,
  design, plan, validation expectations, topic draft and private mapping.
- Stated the unavoidable downtime tradeoff when the fixed stop command accepts
  unsigned ordinary restart, and distinguished that recommendation from the
  literal round 8 failure rule.
- Specified proposed ordinary-mode local exclusion, archive baseline and
  checkpoint evidence, no signed deployment reservation, no second shared-drive
  read, checked restart status and nonzero unauthorized-delivery refusal.
- Restricted R16's unused-selection exception to a valid forward selection;
  recovery stays typed recovery, even when no installer invocation is needed.
  Preserved failed/held and unresolved-attempt recovery safeguards.
- Added conditional P35/P41 fixture expectations for missing/unreadable selection
  and each invalid selection with both unchanged and delivered starts.
- Applied R20: the human Q38 key-loss choice gates Part B, before release N's
  public keys are frozen. Updated Q38/Q41 through the question companion and oqm.
- Preserved all settled round 8 decisions, the verbatim guidance, private facts
  boundary and Steps 1-7 validation evidence. No implementation or operational
  evidence is claimed.

### Human guidance and writer response for plan deploy-venv-sync (exchange 2) (round 10)

Human guidance:

Human decisions on 2026-10-04, given at the round 8 convergence gate.

**Revise and review again.** Apply the decisions below, which settle every open human decision except where a point says it stays open. Keep Q11 to Q36 and the applied requested changes unless a decision here supersedes them.

**Correction of a fact used since round 4.** The native host we reach directly is the qualification host itself. Our own development account has a shell there, with its own development installation in that account's home, but no systemd unit of its own. We have no shell as the qualification application account. The shared drive used for deployment logs is mounted on that host, both the non-production and the production trees. Concrete names and paths are in the private mapping.

**Decision 1 (R16): option A.** A stop/start-only launch while a forward selection is pending leaves that selection pending and unused. The start restarts the last working release with the full held runtime and supervision checks, releases its own reservation, records a receipt, and returns the checks' status.

**Decision 3: the signed selection, delivered through the shared drive.**

- **Delivery.** The human signs each selection on their workstation and writes it to a fixed per-environment folder on the shared drive. That drive is already writable from the human's workstation for both the qualification and production trees, and readable on the hosts through their NFS mounts. The stop target reads the selection before touching anything and verifies its signature against a public key that ships inside the verified stable-script closure.
- **Contents.** A selection names the exact five input hashes and canonical URLs, the target environment, a single-use attempt identity and an expiry. The host records consumed attempt identities outside staging, so a replayed file is refused.
- **Failures.** A missing, unreadable, unsigned, expired, consumed or mismatched selection refuses before any lifecycle change, with the application untouched.
- **Key custody.** The human holds the signing key on their corporate workstation for now.
- **Key loss.** The plan must address it, so that losing the key does not lock deployments out. One option is a second, offline backup public key in the closure. Propose options in a plan question; the human decides.
- **Timing.** The public key and the verification code are part of release N, qualified in Step 8 Part B and installed by the Part C bootstrap.
- **No new published object.** The arming file is not published to the artifact repository, so the "no new publication object" rule is unaffected. Its fixed location is a filesystem path, not artifact resolution.
- **Recovery** uses the same mechanism: a signed recovery selection bound to the failed attempt and its checkpoint.
- **Signature tooling** is an implementation question. It must use host utilities only, verifiable without the application's Python.
- **Production:** the same mechanism through the production tree of the shared drive. Its one-time bootstrap still goes through route (b).

**Decision 2 (R17): every Part G attempt is armed by a fresh signed selection on the shared drive, retries included.**

- This supersedes the round 6 guidance items that made the bootstrap deployment record the Part G selection and the recovery authorization. It also supersedes R17's bounded pre-recorded count and the "single-use, valid until consumed or superseded" bootstrap selection.
- Part C installs the stable closure, the public key, the probes and their receipts, and no arming.
- Each attempt, each retry and each recovery uses its own signed selection, with a short expiry chosen when it is signed.
- The other round 6 rules stay: no operator in Step 8, terminal proof from our pipeline plus the stop target's local check, and evidence returned through the shared drive, the console and the external endpoints.

**Decision 4: Step 9 rehearsals run in the development installation, with a replay of the original role.**

- Both rehearsals (empty-prefix first install, and historical upgrade and rollback) run under our own development account on the qualification host. No operations-team operator is needed, and the qualification environment is not disturbed.
- A replay script reproduces the original role's command sequence on the target: stop through the prefix dispatcher with the exact argument forms, download under the literal filename, unpack, the per-directory rename rotation, copy into staging, permission changes, then start through the dispatcher. Each replay step names the role task it reproduces, at the audited baseline. Do not install or run the orchestration tool itself.
- The replay must exercise both the literal and the expanded home argument forms, and must run commands without an intermediate shell where the role uses none.
- Accepted limits, to be stated in AC18, AC19, the design and Step 9:
  - the development installation has no service unit, so hold, parking and same-daemon supervision are not rehearsed there. A development-only "no unit" profile is allowed and is never accepted for the qualification or production environments;
  - the replay is not the managed orchestration path;
  - the unit-related first-install hooks and the historical hook bridging first run for real in production. They are backed by fixtures and by read-only production unit evidence obtained through route (b);
  - the running-release unit behavior is proven on the qualification environment by Step 8 Part G.
- AC18 and AC19 accept the development replay rehearsal together with Step 8's real managed run. The historical pair comes from the retained exact archives on that host.

**Decision 5: option (i).** On an evidenced empty prefix, the bootstrap installs the hold-aware hooks with the deployment hold set. The "do not touch the hooks" rule applies only where a release is installed or running.

**Decision 6: route (b)** for production and any new environment: an operations-team operator runs our exact self-verifying commands. Route (a) is not possible in production. With decision 3, route (b) is needed once per environment, for the bootstrap, and not before every deployment.

**Step 8 Part A addition.** Use our own development account on the qualification host to gather host-level evidence before Part C: network route and client availability towards the artifact repository, read and write access to the shared-drive folder, and a staging-time measurement with the replay script on the same disks. The replay measures filesystem cost only. Add the orchestration's per-task overhead multiplied by the remote operation count, taking the per-task overhead from retained or newly authorized check-mode console timings. The Part C probes, run as the application account, remain the final evidence, because proxy settings can differ per account.

Record these as dated human decisions in the requirement clarifications, the design decisions and the plan decisions. Update the gate ledger, AC16 to AC19, Steps 8 and 9 and the private mapping consistently. Implementation choices, such as signature tooling, key-loss handling, the replay script's location and the arming folder layout, become plan questions through the canonical workflow. Keep concrete hosts, accounts, shares and paths in the private mapping only, and keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Writer response:

R20 is accepted and applied: Q38 is a human policy gate before Part B. The backup
key remains the recommended option, not a selected policy.

I agree with R19's desired restart independence and recommend it to the human.
I disagree that it preserves the literal promise that invalid deployment
authority refuses before any lifecycle change. At stop time the original role
supplies identical arguments for forward deployment and ordinary restart. If
missing/invalid selection permits ordinary stop, an unsigned forward launch
also stops, then delivers, then reaches start's refusal. No unapproved input is
installed, but the application was touched and downtime may have occurred.

The pending R19 section states this openly in the requirement, design and plan.
It presents the two choices for human confirmation and describes the proposed
unsigned-restart behavior completely. I have not silently made that choice on
the human's behalf. Existing strict flow text is explicitly conditional pending
that choice; its signed ordinary restart is a writer proposal. Please assess
convergence for presenting this precise clarification, alongside Q38, to the
human. The review recommendation cannot itself settle either choice.

Two clarifications preserve already settled safety boundaries in proposed R19:
R16 applies to valid forward selection only, and an unsigned ordinary restart
cannot bypass failed/held or unresolved-attempt recovery safeguards. Valid
recovery remains typed recovery even when restoring readiness does not require
an installer call. Ordinary mode still needs local lifecycle exclusion, archive
identity and checkpoint evidence; it reserves no signed deployment authority
and does not reread the shared drive later in that run.

Q11-Q41 are sufficient. R19 is a requirement/design scope clarification, not a
new plan implementation question. Q38's options and required timing are explicit.
No new protocol object, recurring operator access or mutable artifact selector
is introduced. No implementation, product test, pipeline, target or operations
action, consumer/operations-repository edit, commit or push occurred.

### Reviewer focus for plan deploy-venv-sync (exchange 2) (round 10)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-10 -->

## Round 10 by reviewer

- Recorded: 2026-10-04T23:44:17+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan deploy-venv-sync round 10

Round 10 handles R19 and R20 correctly.

**R20 is applied.** The Q38 key-loss policy is a human gate before Part B, because the qualified release freezes its public keys.

**R19 is presented as a human clarification, with an accurate correction of the reviewer's claim.** The reviewer said restart independence keeps the round 8 refusal rule intact for deployment authority. That is not fully true. The stop receives identical arguments for a forward deployment and an ordinary restart. So, without a valid selection, an unsigned forward launch also stops the application. It then delivers, and start refuses to install. Nothing unapproved is installed, but there is downtime before the refusal. The pending section states both human choices and this tradeoff precisely:

- **Literal pre-lifecycle refusal:** every unsigned stop refuses, including correct outside restarts, unless a signed ordinary-restart payload is added.
- **Restart-independent admission:** unsigned restarts work, and an unsigned forward launch costs a refused delivery and its downtime.

It also keeps the right safeguards in both cases:

- R16 applies only to a valid forward selection;
- a valid recovery selection stays recovery even when no installer call is needed;
- an ordinary restart never bypasses a required checkpoint-bound recovery;
- the shared drive is not reread within an ordinary run.

The reviewer still recommends restart-independent admission. Its residual risk is bounded downtime caused by a forward launch that nobody armed, which our own pipeline never performs; it is never an installation. The strict alternative makes every correct outside restart fail unless the human has signed beforehand, which contradicts decision 1.

Q11 to Q41 are sufficient, and no wording edit remains. Two human decisions remain at the gate: R19, recommended as restart-independent admission; and Q38, recommended as an offline backup key, required before Part B. I recommend convergence.

### Question verdicts for plan deploy-venv-sync round 10

**Q11 to Q41: agree as proposed.** Q38 remains the human's policy decision, now correctly gated before Part B.

**No missing implementation question.** R19 is a requirement and design scope clarification for the human.

**Reviewer recommendations for the human:**

- **R19:** restart-independent admission. Unsigned ordinary restarts work, nothing is ever installed without a valid signed selection, and an unsigned forward launch costs only a refused delivery and its downtime.
- **Q38:** option A, a second offline backup public key in release N, with custody that does not share the primary key's loss condition.

### Convergence evidence for plan deploy-venv-sync round 10

Covered wording:

No wording edit remains. When the human confirms R19 and decides Q38, record both choices as dated human decisions and remove the "pending" and "conditional" qualifiers they resolve.

Convergence rationale:

Every implementation decision for Steps 8 and 9 is settled: Q11 to Q41 have agreed answers, and every requested change is applied or presented for the human as asked. The round 8 human decisions are fully carried by the requirement, design, plan, validation expectations and private mapping.

The two remaining items are human decisions with complete, accurate options and tradeoffs in the documents:

- R19, the scope of restart authority;
- Q38, key-loss handling, required before Part B.

Recording them resolves existing conditional text and adds no plan decisions.

AC16 to AC19 remain open until separately authorized execution.

### Human guidance response for plan deploy-venv-sync round 10

Human guidance:

Human decisions on 2026-10-04, given at the round 8 convergence gate.

**Revise and review again.** Apply the decisions below, which settle every open human decision except where a point says it stays open. Keep Q11 to Q36 and the applied requested changes unless a decision here supersedes them.

**Correction of a fact used since round 4.** The native host we reach directly is the qualification host itself. Our own development account has a shell there, with its own development installation in that account's home, but no systemd unit of its own. We have no shell as the qualification application account. The shared drive used for deployment logs is mounted on that host, both the non-production and the production trees. Concrete names and paths are in the private mapping.

**Decision 1 (R16): option A.** A stop/start-only launch while a forward selection is pending leaves that selection pending and unused. The start restarts the last working release with the full held runtime and supervision checks, releases its own reservation, records a receipt, and returns the checks' status.

**Decision 3: the signed selection, delivered through the shared drive.**

- **Delivery.** The human signs each selection on their workstation and writes it to a fixed per-environment folder on the shared drive. That drive is already writable from the human's workstation for both the qualification and production trees, and readable on the hosts through their NFS mounts. The stop target reads the selection before touching anything and verifies its signature against a public key that ships inside the verified stable-script closure.
- **Contents.** A selection names the exact five input hashes and canonical URLs, the target environment, a single-use attempt identity and an expiry. The host records consumed attempt identities outside staging, so a replayed file is refused.
- **Failures.** A missing, unreadable, unsigned, expired, consumed or mismatched selection refuses before any lifecycle change, with the application untouched.
- **Key custody.** The human holds the signing key on their corporate workstation for now.
- **Key loss.** The plan must address it, so that losing the key does not lock deployments out. One option is a second, offline backup public key in the closure. Propose options in a plan question; the human decides.
- **Timing.** The public key and the verification code are part of release N, qualified in Step 8 Part B and installed by the Part C bootstrap.
- **No new published object.** The arming file is not published to the artifact repository, so the "no new publication object" rule is unaffected. Its fixed location is a filesystem path, not artifact resolution.
- **Recovery** uses the same mechanism: a signed recovery selection bound to the failed attempt and its checkpoint.
- **Signature tooling** is an implementation question. It must use host utilities only, verifiable without the application's Python.
- **Production:** the same mechanism through the production tree of the shared drive. Its one-time bootstrap still goes through route (b).

**Decision 2 (R17): every Part G attempt is armed by a fresh signed selection on the shared drive, retries included.**

- This supersedes the round 6 guidance items that made the bootstrap deployment record the Part G selection and the recovery authorization. It also supersedes R17's bounded pre-recorded count and the "single-use, valid until consumed or superseded" bootstrap selection.
- Part C installs the stable closure, the public key, the probes and their receipts, and no arming.
- Each attempt, each retry and each recovery uses its own signed selection, with a short expiry chosen when it is signed.
- The other round 6 rules stay: no operator in Step 8, terminal proof from our pipeline plus the stop target's local check, and evidence returned through the shared drive, the console and the external endpoints.

**Decision 4: Step 9 rehearsals run in the development installation, with a replay of the original role.**

- Both rehearsals (empty-prefix first install, and historical upgrade and rollback) run under our own development account on the qualification host. No operations-team operator is needed, and the qualification environment is not disturbed.
- A replay script reproduces the original role's command sequence on the target: stop through the prefix dispatcher with the exact argument forms, download under the literal filename, unpack, the per-directory rename rotation, copy into staging, permission changes, then start through the dispatcher. Each replay step names the role task it reproduces, at the audited baseline. Do not install or run the orchestration tool itself.
- The replay must exercise both the literal and the expanded home argument forms, and must run commands without an intermediate shell where the role uses none.
- Accepted limits, to be stated in AC18, AC19, the design and Step 9:
  - the development installation has no service unit, so hold, parking and same-daemon supervision are not rehearsed there. A development-only "no unit" profile is allowed and is never accepted for the qualification or production environments;
  - the replay is not the managed orchestration path;
  - the unit-related first-install hooks and the historical hook bridging first run for real in production. They are backed by fixtures and by read-only production unit evidence obtained through route (b);
  - the running-release unit behavior is proven on the qualification environment by Step 8 Part G.
- AC18 and AC19 accept the development replay rehearsal together with Step 8's real managed run. The historical pair comes from the retained exact archives on that host.

**Decision 5: option (i).** On an evidenced empty prefix, the bootstrap installs the hold-aware hooks with the deployment hold set. The "do not touch the hooks" rule applies only where a release is installed or running.

**Decision 6: route (b)** for production and any new environment: an operations-team operator runs our exact self-verifying commands. Route (a) is not possible in production. With decision 3, route (b) is needed once per environment, for the bootstrap, and not before every deployment.

**Step 8 Part A addition.** Use our own development account on the qualification host to gather host-level evidence before Part C: network route and client availability towards the artifact repository, read and write access to the shared-drive folder, and a staging-time measurement with the replay script on the same disks. The replay measures filesystem cost only. Add the orchestration's per-task overhead multiplied by the remote operation count, taking the per-task overhead from retained or newly authorized check-mode console timings. The Part C probes, run as the application account, remain the final evidence, because proxy settings can differ per account.

Record these as dated human decisions in the requirement clarifications, the design decisions and the plan decisions. Update the gate ledger, AC16 to AC19, Steps 8 and 9 and the private mapping consistently. Implementation choices, such as signature tooling, key-loss handling, the replay script's location and the arming folder layout, become plan questions through the canonical workflow. Keep concrete hosts, accounts, shares and paths in the private mapping only, and keep the public documents and this transcript generic. No implementation, test, pipeline, target or operations action, commit or push belongs to this round.

Guidance response:

The round 8 decisions remain fully applied. The one sentence whose scope was unclear, the refusal rule for missing or invalid selections, is now an explicit pending human clarification (R19). Both readings are described, and the writer's correction of the reviewer's claim is accepted. The human chooses at this gate.

### Writer instructions for plan deploy-venv-sync round 10

No plan edit is required.

This answer recommends convergence. It does not authorize consolidation. Present the human gate with both registered choices and the two open human decisions beside them:

- **R19, restart authority:** the choices are restart-independent admission, recommended by the reviewer and the writer, or literal pre-lifecycle refusal. State the downtime tradeoff of the first.
- **Q38, key loss:** the choices are option A, an offline backup public key (recommended), or option B, a trust re-bootstrap. It is required before Part B.

Wait for the human's selection. Do not consolidate, implement, run tests, touch the consumer or the operations repository, commit or push in this task.

### Final reviewer decision for plan deploy-venv-sync round 10

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-10 -->

## Round 10 by human - human-confirmation

- Recorded: 2026-10-05T00:57:04+02:00
- Exchange: specification/plan/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow
Guidance: R19 confirms restart-independent admission, Q38 confirms **offline backup key**, Consolidate

<!-- review-entry-id: human-confirmation-round-10 -->
