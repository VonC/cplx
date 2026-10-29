# Specification review transcript for v0.27.0

- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-21T21:36:54+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for feature-request deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
Review round: 1

### Requestor assessment for feature-request deploy-venv-sync (round 1)

The requirement carries umbrella item 8 and D11 into a generic public contract:
no shipped application venv, explicit tools Python, version-based naming, locked
reconstruction, source provenance, wheel verification, shared runtime behavior,
and target-proved rollback. It preserves item 7 evidence and requires execution
on RHEL and Debian using the same identified tools archive.

Eight questions address remaining behavioral boundaries. No further missing
requirement question is currently known; independently assess completeness.
Every question has alternatives, pros/cons, and a proposed answer. These are
writer recommendations, not confirmed decisions. Provisioning/source transport
mechanisms are deliberately reserved for design rather than requirement questions.

Pay particular attention to Q01's stronger index-outage recovery guarantee,
Q03's distribution-versus-file integrity boundary, Q05's migration qualification,
and Q06's distinction between controlled application validation and the unchanged
mandated CI phase. Check whether the current criteria overstate what retained
wheel evidence or a pipeline success status establishes.

No reviewer wording suggestions have been received or applied in round 1.
Earlier umbrella historical passages do not override the later child draft and
confirmed user decisions. The shared CI library must remain unchanged; one
Jenkinsfile/build runs blocking validation first and the mandated pipeline second.
Private consumer-specific implementation details are outside this review content.

### Change summary for feature-request deploy-venv-sync (round 1)

Initial requirement authored from the settled v0.27.0 child draft and umbrella
item 8. Added thirteen acceptance criteria and eight requirement-level questions.
Made archive-only installation, deliberate wheel ELF drift rejection, failure
propagation, cross-platform artifact identity, and previous-release reconstruction
explicit. Recorded the later single-build CI sequence without library changes.
No earlier review round exists and no runtime implementation was changed.

### Writer response for feature-request deploy-venv-sync (round 1)

Writer response:

This is the initial review request. No reviewer findings or disagreements exist
yet. Assess missing scope/acceptance questions and the proposed answers without
reopening confirmed tools-Python selection, full-version venv naming, locked sync,
no-shipped-venv policy, or unchanged mandated-library constraint.

Keep all authored review content generic. Do not copy private names, endpoints,
paths, or CI entry points from historical associated material into the public
requirement or versioned review transcript. Report unresolved integration
feasibility honestly rather than treating preliminary validation as proof that
the later mandatory phase works.

The user requested publication of round 1 followed by an immediate stop, without
waiting. This requestor will not wait for or process an answer in this turn.

### Reviewer focus for feature-request deploy-venv-sync (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `.reviews/a.review-active.specification.feature-request.v0.27.0.deploy-venv-sync.md`
- `.reviews/a.review-requested.feature-request.v0.27.0.deploy-venv-sync.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-21T21:41:15+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for feature-request deploy-venv-sync round 1

The requirement carries umbrella item 8 and D11 faithfully into a generic
contract. Its confirmed parts (tools-Python selection, full-version naming,
locked sync, no shipped venv, unchanged mandated pipeline) are clear and need
no reopening. Six of the eight questions are well posed and I agree with their
recommended answers, with small wording refinements.

Three things keep this above wording polish:

- **Q05's recommendation over-constrains the first transition.** The
  predecessor of the first venv-free release is a release whose archive still
  ships its venv. Rolling back to it means redeploying that archive, and the
  archive restores its own copied environment. Demanding a lock reconstruction
  of that predecessor asks for something its release never promised, and could
  block adoption for no safety gain.
- **Two requirement-level decisions are missing as questions.** The first is
  whether a normal forward deployment may depend on a reachable private index,
  or must also work offline. The umbrella states that the source question and
  the rollback question "are one decision", and Q01's recommended answer already
  forces retained offline inputs for rollback. The second is where the qualified
  uv comes from. Shipping uv inside the tools archive changes that archive,
  which voids the "reuse the qualified item 7 archive" path and forces a new tools
  release with repeated acceptance. That is a scope consequence, not a design detail. The
  version is also unsettled: the release lock's `tooling` group pins uv
  0.11.19, while the requirement cites relocated uv 0.12.17 as qualified.
- **Two acceptance criteria overstate or miss a settled answer.** AC08 requires
  "without host fallback" on both platforms, but item 7's validation matrix marks
  the RHEL ABI probe and live trace not applicable, because host copies are
  compatible there. AC12 does not yet carry Q01's index-unavailable condition, so
  the recommended answer has no acceptance evidence.

On the writer's question about overstatement: AC07 stays within identities and
ELF bytes, and AC11 already requires evidence of the commands that actually ran.
AC10 and Q06 do overstate, though. A mandated pipeline can finish with a
success status while an inner test command's failure is ignored, so a phase's
success must be read from its executed commands, never from its status alone.
AC08 overstates for RHEL, as noted above.

### Question verdicts for feature-request deploy-venv-sync round 1

**Q01, recovery availability: agree with option A, tighten the wording.**
"Dependency index unavailable" leaves open whether a retained-artifact service
on the same infrastructure counts as available. Say what the test removes:
rollback of the immediately preceding release succeeds with every package index
and artifact service unreachable, using only inputs already present on the
target or delivered with the release archives, including its qualified uv. Carry
this into AC12.

**Q02, failed sync: agree with option A.** Suggested answer wording: "A failed
sync reports failure and blocks readiness; the environment may be unusable
afterwards. Recovery is a successful redeployment of the same or the preceding
release, not an unchanged prior environment."

**Q03, inventory boundary: agree with option A, name the reference.** Option A
should say what the installed set is compared against: the release lock's
selected distributions and artifact hashes for the target's platform and
groups, plus the retained wheel files for the ELF comparison. Also state that
"extra" means a distribution the lock selection does not name, so marker-based
platform differences are not reported as drift.

**Q04, same version with a changed tools payload: agree with option A.**
The payload identity (archive digest) should appear in the retained per-platform
evidence, so a reused environment's validation is visibly tied to the current payload.

**Q05, first migration: disagree with option A.** The predecessor ships its own
venv, so its natural rollback is to redeploy that archive with its own procedure,
restoring its copied environment. Replace the options with:

- Option A: For the first venv-free release, prove rollback by redeploying the
  predecessor archive with its shipped environment and the predecessor's own
  deployment procedure. Lock reconstruction applies from the second venv-free
  release onward.
  - pro: Uses the recovery path the predecessor was released with, proven on
    the target, with no historical input recovery.
  - con: Recovery takes two shapes during one transition window.
- Option B: Require lock reconstruction of the predecessor before accepting the
  first venv-free release.
  - pro: One recovery shape from the start.
  - con: Asks a copied-venv release for inputs it never retained, and may block
    adoption without a safety gain.

I would choose the new option A. Whichever is chosen, AC12 must name the first
transition explicitly.

**Q06, later CI phase scope: agree with option A, but qualify "successful".**
A mandated pipeline can report success while an inner command's failure is
tolerated, for example a test command whose exit status is ignored. Option A's
"truthful, successful" later-phase execution must therefore be established from
the commands that phase actually executed and their results, never from its
overall status alone. When a command failure is masked, report it as a failed
or inconclusive later-phase check. Replace "corporate-phase" in the answer with
"mandated-pipeline phase", matching the rest of the document.

**Q07, archive exclusion boundary: agree with option A, reuse the relocation
marker.** Define an environment as any directory under the packaging input that
holds a `pyvenv.cfg`, the same marker the relocation exclusion uses, so the two
boundaries cannot diverge.

**Q08, concurrency: agree with option A.**

**Missing Q09: may a forward deployment depend on a reachable private index?**
Options: (A) forward deployment also succeeds with every index unreachable, from
retained digest-pinned inputs delivered with the release; (B) a reachable
private index is a documented deployment prerequisite, verified before sync. I
would choose A. Q01 option A already requires those inputs to exist for
rollback, the umbrella treats source and rollback as one decision, and the
deployment account today receives archives and nothing else. B stays valid if
the human confirms index reachability as an operational guarantee. In that
case, the effective-source lock materialization already used in CI is the
natural mechanism. The deciding fact is target reachability, which only the
human can confirm, so this must be a question rather than a design choice.

**Missing Q10: where does qualified uv come from?** Options: (A) ship uv inside
the tools archive, which changes that archive and requires a new tools release
with item 7's acceptance repeated; (B) deliver the qualified uv as a digest-pinned input with the
application release and install it with tools Python explicitly, leaving the
tools archive unchanged; (C) install it at deployment from an index. I would
choose B, which keeps the qualified tools archive reusable and satisfies Q01
and Q09 offline. C contradicts Q01 option A. The question should also settle
which version is the qualified one. The release lock's `tooling` group
currently pins uv 0.11.19, while the requirement cites relocated uv 0.12.17 as
the qualified version. The answer must name one version and state whether the
lock's pin must follow it.

### Requested changes for feature-request deploy-venv-sync round 1

Requested changes:

- Rework Q05's options and recommendation (first transition redeploys the
  predecessor archive with its shipped environment).
- Add missing Q09 (forward deployment with the index unreachable) and Q10
  (source of qualified uv, its effect on the tools archive, and the 0.11.19
  lock pin versus the cited 0.12.17 qualified version).
- Make Q01's unavailability condition exact, and make Q03's reference and Q07's
  discovery marker explicit.
- Make AC10 and Q06 establish phase success from executed commands rather than
  status, and state that unresolved mandated-phase compatibility keeps the topic
  incomplete.
- Scope AC08's host-fallback and trace demands to Debian; add the Q01 condition
  and the first transition to AC12; make AC06 neutral about the source mechanism.

### Writer instructions for feature-request deploy-venv-sync round 1

Revise the requirement, then publish a replacement request for another round.

- **Q05:** replace the options with the two proposed in the question verdicts,
  recommend redeploying the predecessor archive for the first transition, and
  keep lock reconstruction as the rule from the second venv-free release onward.
- **Add Q09 and Q10** with the options above, each with a BBQ, pros and cons, a
  recommendation and an answer. State in Q10 which option keeps the item 7 tools
  archive reusable, and settle the uv version: the release lock pins 0.11.19
  in its `tooling` group while the requirement cites 0.12.17 as qualified.
- **Tighten Q01, Q03 and Q07** with the wording in the question verdicts, and
  replace "corporate-phase" in Q06's answer.
- **AC08:** scope "without host fallback" and the conclusive trace to Debian.
  State that RHEL providers are qualified according to item 7's validation
  matrix.
- **AC12:** add the Q01 condition (every index and artifact service
  unreachable), and name the first-transition rollback according to the Q05
  answer.
- **AC10 and Q06:** state that a phase's success is established from its
  executed commands and results, not its overall status, and that a masked
  command failure in the mandated phase is reported as failed or inconclusive.
  Also say explicitly that unresolved mandated-phase compatibility keeps this
  topic incomplete, as the confirmed draft already implies.
- **AC06:** say "effective-source locked sync" rather than "source-mapped", so
  the criterion also fits an offline answer to Q09.
- Keep all new content generic, with no private names, paths or endpoints.

### Final reviewer decision for feature-request deploy-venv-sync round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-22T07:54:28+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for feature-request deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
Review round: 2

### Requestor assessment for feature-request deploy-venv-sync (round 2)

The requirement and canonical child draft now distinguish confirmed human answers
from proposals. Q01/Q03/Q04/Q07/Q08 are explicitly confirmed; Q06 preserves the
previously confirmed one-Jenkinsfile, one-job, one-build arrangement with precise
phase terminology. Q02/Q05/Q09/Q10 remain proposed choices.

Round 1's missing Q09 and Q10 are added. Q05 now recommends the predecessor's
supported copied-venv recovery procedure for the first transition. Q10 proposes
application-delivered digest-pinned uv 0.12.17 and alignment of the consuming
tooling lock, leaving the qualified toolchain archive unchanged. This is a
recommendation, not a claim of human approval or completed qualification.

Review whether the options adequately expose all remaining requirement decisions.
In particular, check that offline rollback does not silently approve offline
forward deployment, that retained originals are sufficient for wheel ELF
comparison, and that the no-dependency-build rule covers sync/recovery while
leaving application packaging and separate toolchain compilation distinct.
Check that phase 2 command evidence does not overstate unchanged-library success.

All round 1 wording suggestions were applied in substance: precise offline
recovery boundary; target-selected lock/artifact reference; pyvenv.cfg exclusion;
current toolchain digest; Debian-only no-host-fallback/live-trace demands; RHEL
qualification against item 7; mechanism-neutral source acceptance; and masked
command failures treated as failed/inconclusive. No further missing requirement
questions were identified by the writer. Human confirmation remains necessary
for the four proposal questions before consolidation.

### Change summary for feature-request deploy-venv-sync (round 2)

Updated both the canonical draft and feature request.

- Replaced ambiguous dependency-source terminology with Python library referential
  or mirror; defined toolchain, Python venv, and retained original wheel artifacts.
- Recorded offline preceding-release recovery as confirmed, including qualified
  uv and all required target-local/archive-delivered inputs with every remote
  referential, mirror, and artifact service unreachable.
- Required prebuilt dependency wheels with no source-build fallback; clarified
  venv link/shebang checks versus preserved wheel ELF bytes.
- Defined selected lock identities/hashes, extra distributions, all pyvenv.cfg
  packaging exclusions, and same-version toolchain replacement evidence.
- Explained both CI phases within one Jenkinsfile/job/build and required actual
  command-result evidence rather than trusting a potentially masked status.
- Detailed serialized sync/mirroring/rollback scenarios on one application root.
- Revised Q05, added Q09/Q10, and corrected AC06/AC08/AC10/AC12; added AC14/AC15
  for the no-build, current-toolchain reuse, and serialization requirements.
- Kept all public content generic and maintained operational details privately.

### Writer response for feature-request deploy-venv-sync (round 2)

Writer response:

Accepted round 1 feedback without substantive disagreement. The first-transition
recommendation is changed to redeploy the predecessor archive with its shipped
venv using its own procedure, while later venv-free predecessors reconstruct
from their locks. This recommendation remains subject to human confirmation.

Q09 explicitly separates forward-deployment availability from confirmed offline
rollback. Q10 recommends application-delivered uv 0.12.17 and consistent tooling
lock pinning; it states the archive/requalification consequence of shipping uv
inside the toolchain archive. Service-only uv bootstrap without retained local
recovery inputs is shown as incompatible with confirmed Q01.

The human clarified the terminology and confirmed Q01/Q03/Q04/Q07/Q08. Q06
explains the already agreed arrangement: unchanged shared-library stages are
phase 2 of the same Jenkins job build, not another job or downstream build.
Neither a green status nor preliminary validation conceals failed later commands.

The requested review changes are applied, but reviewer agreement is not treated
as human approval of Q02/Q05/Q09/Q10. Please review the updated requirement and
its explicit confirmed/proposed boundary. No implementation, runtime validation,
dependency lock update, toolchain publication, or consolidation has occurred.

### Reviewer focus for feature-request deploy-venv-sync (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-22T07:56:37+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for feature-request deploy-venv-sync round 2

Round 2 resolves every round 1 point in substance.

- Q05 now uses the predecessor's own recovery path.
- Q09 and Q10 expose the two missing decisions with admissible options.
- AC08 scopes the host-fallback and live-trace demands to Debian.
- AC10 and Q06 read phase 2 success from executed commands and treat masked failures as failed or inconclusive.
- AC12 carries the confirmed offline condition and the first transition.
- AC06 is now neutral about the source mechanism.

The confirmed and proposed answers are clearly separated, and the new
terminology, retained-wheel definition, no-build rule (AC14) and serialization
rule (AC15) are consistent with the umbrella and item 7.

On the writer's four focus points:

- **Offline rollback versus forward deployment:** kept distinct. The recovery
  section and Q09 both say that offline rollback does not settle forward deployment.
- **Retained originals for ELF comparison:** sufficient as defined. They are the
  exact original `.whl` files, hash-verified against the lock and kept with a
  release/platform/group manifest outside any disposable cache. One consequence is
  worth stating in Q09 option B (see the wording below): wheels downloaded during
  a forward deployment must be kept as retained originals, both for the post-sync
  comparison and as the next rollback's inputs.
- **No-build scope:** correctly separates dependency wheels from application
  packaging and toolchain compilation. It should also say that the application
  project itself is not built during sync, for example as a non-packaged
  project. Otherwise `uv sync` installing the project could read as a source
  build under AC14, or as an "extra" distribution under AC07.
- **Phase 2 evidence:** does not overstate. Success is read from executed
  commands, and unresolved compatibility keeps the topic incomplete.

What remains is wording only. Four answers (Q02, Q05, Q09, Q10) still need human
confirmation; that belongs to the human's choice at the gate, not to another
review round.

### Question verdicts for feature-request deploy-venv-sync round 2

- **Q01 (confirmed A):** agree. The outage condition is now exact.
- **Q02 (proposed A):** agree; I would choose A.
- **Q03 (confirmed A):** agree. The reference artifacts are now explicit.
- **Q04 (confirmed A):** agree.
- **Q05 (proposed A):** agree; I would choose A. It also satisfies the offline
  condition naturally, because the predecessor archive carries its own venv.
- **Q06 (confirmed arrangement, A):** agree.
- **Q07 (confirmed A):** agree.
- **Q08 (confirmed A):** agree.
- **Q09 (proposed A):** agree; I would choose A unless the human can guarantee
  that the private mirror is reachable from deployment accounts. Add to option
  B's con that downloaded wheels must still be kept as retained originals, both
  for the post-sync comparison and as inputs for the next rollback.
- **Q10 (proposed B, uv 0.12.17):** agree; I would choose B. Option C is
  already excluded by confirmed Q01, so either drop it or label it
  "not admissible under Q01" in its heading, so it does not read as a live choice.

No further missing question.

### Convergence evidence for feature-request deploy-venv-sync round 2

Covered wording:

- **Terminology, uv:** "uv is its dependency management utility" places uv
  inside the toolchain, which contradicts Q10 option B. Use "uv is the dependency
  management utility used with that Python; which release delivers it is Q10."
- **Terminology, mirror example:** use a neutral phrase such as "for example an
  artifact-repository mirror" rather than naming a product.
- **Source section grammar:** "An Python library referential setting alone" should
  read "A Python library referential setting alone". "A reachable private Python
  library referential mirror" should read "a reachable private mirror".
- **CI section duplication:** the closing sentence of the phase 2 paragraph
  ("Unresolved phase 2 compatibility leaves this topic incomplete") and the
  last sentence of the next paragraph say the same thing; keep one.
- **AC14 and the no-build rule:** add "The application project itself is not
  built during sync (for example, it is declared as a non-packaged project);
  only its dependencies are installed."
- **Q09 option B con:** append "Downloaded wheels must still be kept as retained
  originals for post-sync comparison and as the next rollback's inputs."
- **Q10 option C:** remove it, or mark it "not admissible under confirmed Q01".

Convergence rationale:

Every in-scope decision is either human-confirmed (Q01, Q03, Q04, Q06's
arrangement, Q07, Q08) or exposed as a well-formed proposal whose recommended
answer I would also choose (Q02, Q05, Q09, Q10). No question is missing, and
the acceptance criteria no longer overstate their evidence. The remaining
edits are clarifications and grammar that change no decision. Convergence is
advisory: consolidation still requires the human's choice, including
confirmation of the four proposed answers.

### Writer instructions for feature-request deploy-venv-sync round 2

No further review round is needed. Apply the covered wording during
consolidation, after the human confirms Q02, Q05, Q09 and Q10. Do not treat this
convergence recommendation as that confirmation.

### Final reviewer decision for feature-request deploy-venv-sync round 2

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human - human-confirmation

- Recorded: 2026-09-22T08:37:11+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Revise and review again
Outcome: another-round
Guidance: Revise and review: we need to make sure the shared library uses the same environment (meaning our tool Python and our venv)

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 3 by requestor

- Recorded: 2026-09-22T08:39:17+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for feature-request deploy-venv-sync (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
Review round: 3

### Requestor assessment for feature-request deploy-venv-sync (round 3)

The human selected Revise and review again and explicitly requires the unchanged
mandated shared-library stages to use the SAME toolchain Python AND the SAME
actual full-version application venv validated in phase 1. A separate venv with
matching Python/packages does not satisfy the requirement.

Q06 and AC10 now require venv continuity across agents/workspaces, actual command
selection, and unchanged selected locked inventory before/after phase 2.
Assess whether these acceptance conditions are sufficient and consistent with
unchanged shared-library sources and Jenkinsfile-only orchestration. An inspected
library has a hardcoded alternate activation path, unqualified sync, dependency
installation, and a separately allocated agent. Those are feasibility blockers to
resolve, not evidence of a working integration. A truthful path alias is only a
possible design mechanism; no implementation choice or success is assumed.

No new question is presently identified: Q06 is a confirmed requirement, not an
open vote to allow a different venv. Q02/Q05/Q09 remain unconfirmed proposals.
Q10 B is confirmed with latest stable selected at qualification then pinned for
that release and recovery. Review the options/answers for sufficiency and identify
any real remaining ambiguity without relaxing the user's same-venv instruction.
All covered wording from round 2 has been applied.

### Change summary for feature-request deploy-venv-sync (round 3)

Updated the public draft, requirement, and outside-repository private handoff.
Removed the separate phase 2 venv allowance. Both CI phases must use the same
actual canonical full-version venv and shipped interpreter, without copying,
replacement, recreation, or package drift. Added agent/filesystem continuity and
before/after inventory evidence. Shared-library sources stay unchanged; failure
to satisfy the contract remains a completion blocker.

Recorded Q10 B as human-confirmed: latest stable uv at qualification, with exact
version/digest frozen for deployment/recovery and tooling lock aligned.
Applied round 2 wording: neutral mirror terminology, uv delivery separate from
toolchain archive, grammar and duplicate cleanup, dependency sync does not build
or install the application itself, downloaded originals retained for comparison
and rollback, and Q10 C explicitly inadmissible. Q02/Q05/Q09 remain proposals.

### Human guidance and writer response for feature-request deploy-venv-sync (round 3)

Human guidance:

Revise and review: we need to make sure the shared library uses the same environment (meaning our tool Python and our venv)

Writer response:

Accepted all round 2 covered wording. The human chose another review round rather
than consolidation and strengthened Q06 beyond the version the reviewer assessed:
using the same toolchain interpreter with a separate venv is explicitly insufficient.
The revised requirement carries this instruction as a confirmed outcome and
leaves the Jenkinsfile compatibility mechanism for design and actual validation.

Please check the same-venv requirement, preservation of lock/group/no-build/runtime
guarantees during mandatory shared-library dependency commands, truthful evidence
across agent boundaries, and absence of any residual separate-venv exception.
Do not equate pyvenv.cfg, matching Python versions, or matching path strings with
proof of reuse. If unchanged stages cannot meet the contract through authorized
configuration, identify that incompatibility rather than recommending an implicit
fallback. Keep public review content generic and all private identifiers outside
the public transcript. This request does not claim runtime feasibility is proven.

### Reviewer focus for feature-request deploy-venv-sync (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-09-22T08:41:54+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for feature-request deploy-venv-sync round 3

The human's same-environment instruction is carried faithfully. Q06, AC10 and
the CI section now require the same toolchain Python and the same actual
phase 1 venv, reject a second or recreated venv, and demand command-level and
before/after inventory evidence. No residual separate-venv exception remains,
and `pyvenv.cfg`, version strings and path strings are correctly denied the
status of proof. Round 2's covered wording is applied, and Q10's confirmed answer
(latest stable uv at qualification, then frozen per release) is precise.

Four points go beyond wording.

- **"Release its agent allocation" now contradicts the same-venv rule.** The CI
  section still requires phase 1 to release its agent allocation before phase 2,
  and says phase 2 "may allocate different agents and workspaces". The phase 1
  venv, and the toolchain its interpreter links to, live on the filesystem of
  that allocation. Where agents are ephemeral containers or workspaces,
  releasing the allocation destroys both. Copying is forbidden and recreation
  fails AC10, so the requirement has to state the invariant that makes both
  sentences true: when phase 2's commands run, the venv and toolchain must be the
  same files on the same storage, at the same absolute paths. Whether this is
  achieved through storage that outlives the allocation or by running phase 2
  where phase 1 ran depends on agent infrastructure only the human can confirm,
  so it is a missing question rather than a design detail.
- **An alias would contradict lifecycle rule 4.** Q06's answer admits a
  "verified compatibility mechanism" that resolves a hardcoded alternative
  activation path to our venv. Lifecycle rule 4 still forbids creating "an
  implicit `.venv` in the controlled application flow". Both can hold, but only
  if the text says an explicit, verified alias to the canonical venv is not an
  implicit environment. Otherwise the admitted mechanism is forbidden elsewhere.
- **An unqualified phase 2 sync changes the venv unless the selections match.**
  An exact sync installs the project's default dependency groups and removes
  anything else. If phase 1's CI group selection differs from that default, the
  unchanged phase 2 sync adds or removes distributions and fails the
  before/after inventory. The same applies if it runs with a different uv
  version than the qualified one. The requirement should state both
  consequences: phase 1's CI selection must equal what phase 2's sync
  selects, and any uv phase 2 invokes must be the qualified one or be shown not
  to change the inventory. Without this, the before/after check is the first
  place the conflict appears, after the build has already run.
- **Per-release uv against one shared install location.** Q10 freezes uv per
  application release, including recovery, but the provenance section installs
  it "in the toolchain installation". Rolling back to a release pinned to a
  different uv would then overwrite the uv that another release or application
  on the same toolchain relies on. The requirement should say that the uv
  selected for a deployment or recovery is exactly the one pinned by that
  release, whatever the install location.

### Question verdicts for feature-request deploy-venv-sync round 3

- **Q01, Q03, Q04, Q07, Q08 (confirmed):** no change.
- **Q02, Q05, Q09 (proposed A):** unchanged, and I would still choose A for each.
- **Q06 (confirmed A, same venv):** agree with the requirement as the human
  stated it; I do not reopen it. Two wording fixes: replace "corporate checks" in
  option A's pro with "mandated shared-library checks", and add a sentence to
  the answer saying that an explicit, verified alias to the canonical venv is
  not the implicit `.venv` that lifecycle rule 4 forbids.
- **Q10 (confirmed B):** agree. Add that the uv selected for a deployment or a
  recovery is exactly the release's pinned artifact, so a shared install location
  cannot silently serve another release's uv.

**Missing Q11: how does the phase 1 venv reach phase 2's commands?**

- Option A: Keep the venv and toolchain on storage that outlives the phase 1
  allocation and is mounted at the same absolute paths for phase 2's agents.
  Phase 1 may then release its allocation as the CI section requires.
  - pro: Keeps the confirmed "release the allocation" step and the same-venv rule together.
  - con: Requires persistent, shared agent storage, and proof that phase 2 sees
    the same files rather than a same-named path.
- Option B: Run phase 2's commands on the same agent and workspace as phase 1,
  selected through supported Jenkinsfile or configuration controls, and drop the
  requirement to release the phase 1 allocation first.
  - pro: No shared storage is needed; continuity follows from the same filesystem.
  - con: Changes the confirmed release step, and may be impossible if the
    unchanged stages allocate their own agents, or may deadlock when executors
    are scarce.

I cannot choose between these without knowing the agent infrastructure. I
would ask the human which the infrastructure supports. If neither is available
through supported controls, the confirmed rule already makes that a completion
blocker, and the requirement should say so explicitly for this case.

**Q12 (phase 2 dependency selection): a consequence to state, not a question.**
Phase 1's CI dependency groups must equal the selection an unqualified phase 2
sync applies, and any uv invoked by phase 2 must be the qualified uv or be shown
by the before/after inventory not to change the venv.

### Requested changes for feature-request deploy-venv-sync round 3

Requested changes:

- Reconcile the phase 1 allocation release and phase 2's separate agents with the
  same-venv rule. State the same-files, same-storage, same-absolute-path invariant.
- Add Q11 (how the phase 1 venv reaches phase 2), and state that failing it is a
  completion blocker.
- State that the phase 1 CI groups must equal phase 2's unqualified sync
  selection, and constrain phase 2's uv; reflect both in AC10.
- Clarify that a verified alias to the canonical venv is not an implicit `.venv`.
- Require the exact release-pinned uv for deployment and recovery, whatever the
  install location.

### Human guidance response for feature-request deploy-venv-sync round 3

Human guidance:

Revise and review: we need to make sure the shared library uses the same environment (meaning our tool Python and our venv)

Guidance response:

The human guidance requires the shared library to use our toolchain Python
and our venv. The revised requirement carries that fully, and this review does
not relax it. The requested changes serve the guidance. They remove two
surviving sentences that would make it unachievable, name the one
infrastructure fact it depends on (how the same files reach phase 2), and state
the dependency-selection condition under which the unchanged phase 2 sync
leaves the venv intact. None of them admits a second venv or a copy.

### Writer instructions for feature-request deploy-venv-sync round 3

Revise the requirement, then publish a replacement request.

- **CI section:** reconcile "release its agent allocation" and "may allocate
  different agents and workspaces" with the same-venv rule. State the invariant
  that the venv and toolchain are the same files, on the same storage, at the
  same absolute paths, when phase 2's commands run. Make the release step
  conditional on that invariant.
- **Add Q11** with the two options above, a BBQ, pros and cons, and a
  recommendation that defers to the human's knowledge of the agent
  infrastructure. State that no supported way to meet the invariant is a
  completion blocker.
- **Group selection:** state that phase 1's CI dependency groups must equal the
  selection that phase 2's unqualified sync applies. Also state that any uv
  phase 2 invokes must be the qualified uv, or must be shown by the before/after
  inventory not to change the venv. Reflect both in AC10.
- **Lifecycle rule 4 and Q06:** clarify that an explicit, verified alias to the
  canonical venv is not an implicit `.venv`.
- **Q10 and the provenance section:** require the uv used for a deployment or
  recovery to be exactly the release's pinned artifact, whatever the install location.
- **Q06 wording:** replace "corporate checks" with "mandated shared-library checks".
- Keep all new content generic.

### Final reviewer decision for feature-request deploy-venv-sync round 3

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-09-22T09:26:54+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for feature-request deploy-venv-sync (round 4)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
Review round: 4

### Requestor assessment for feature-request deploy-venv-sync (round 4)

The human supplied an authoritative addendum after round 3 and asked for round 4.
It replaces physical venv continuity with local reconstruction by our scripts
on the freshly provisioned phase 2 test agent. The requirement and source draft
now express same toolchain archive digest, canonical lock and dependency groups,
using toolchain Python, with actual comparison evidence.

No new requirement question is identified. The proposed Q11 and same-storage
invariant are unnecessary under the confirmed execution model and are not added.
Q02/Q05/Q09 remain human-unconfirmed proposals. Q06 and Q10 are confirmed with
the latest guidance; their options and answers reflect the superseded choices.

Review equivalence evidence, checkout revision comparison, effective group
selection making mandatory sync a no-op, failed dependency commands despite
masking, and the phase 2 uv-version exception. Verify that no physical continuity
or exact phase 2 uv demand survives as an active requirement. Generic acceptance
criteria only are public; the private design has been read and is not reproduced.
All still-applicable round 3 wording has been applied.

### Change summary for feature-request deploy-venv-sync (round 4)

Revised Q06, AC10 and both documents' CI sections: phase 2 reconstructs locally
before mandated Python commands using the same toolchain digest, canonical lock
and groups. Copying phase 1 venvs and library-created replacements remain forbidden.
Record interpreter/base-prefix/venv provenance, compare checkout revisions, and
compare phase 2 before/after inventory with phase 1. Fail on drift, revision
mismatch, missing comparison evidence, and masked dependency-command failures.

Phase 1 groups cover the unqualified sync defaults; effective selections must
prevent additions and removals. Any phase 2 uv version is acceptable when the
required inventory and command-success evidence passes. Deployment/recovery
still select exactly their release-pinned artifact regardless of install location.
Explicit verified aliases are distinguished from forbidden implicit venv creation.
No Q11 or same-storage invariant was introduced. Two-phase order, phase 1 archived
artifacts and unchanged mandated sources remain required. The integration scope
now includes a tracked application script alongside the consuming Jenkinsfile.

### Human guidance and writer response for feature-request deploy-venv-sync (round 4)

Human guidance:

Human guidance for round 4 (supersedes parts of the round 3 review answer):

The mandated shared-library stages run on freshly provisioned, one-shot agent
containers that the unchanged library allocates itself, each with its own
checkout. The phase 1 venv files cannot reach them, and running phase 2 on
phase 1's agent is not possible. "Same environment" therefore means our
toolchain Python and our locked dependencies. It does not mean the same venv
files.

Keep the two-phase order and phase 1's archived artifacts unchanged. In the
mandated test stage, a venv is built by our own scripts, before the library's
Python commands run, from the same toolchain archive digest and the same
canonical lock and dependency groups as phase 1. The library's own
dependency, activation and test commands must use that venv. The mechanism is
design, selected through the consuming Jenkinsfile and a tracked application
script; the shared-library sources stay unchanged.

Revise the requirement accordingly:

- Q06, AC10 and the CI section: replace "the same venv validated in phase 1"
  with "a venv built by our scripts in the phase 2 test agent from the same
  toolchain archive digest, canonical lock and dependency groups, using the
  toolchain Python". Keep a copied phase 1 venv forbidden. Keep a venv created
  by the library's own commands (for example an implicit project venv built
  with another interpreter) forbidden.
- Require phase 2 evidence of that equivalence: toolchain archive digest, lock
  digest and groups, resolved interpreter and base prefix, venv path, and the
  selected inventory captured before and after the library's Python commands,
  compared with phase 1. Any drift, or a failed library dependency command,
  fails validation even when the library masks it.
- Require the phase 1 dependency-group selection to include whatever the
  library's unqualified dependency sync selects by default, so that sync is a
  verified no-op rather than a change.
- Record the checked-out revision in phase 2 and compare it with phase 1's,
  because the library checks out the branch tip, not a pinned revision.
- Drop round 3's proposed Q11 (how the same files reach phase 2) and its
  same-storage invariant: this decision makes both unnecessary.
- Drop round 3's demand that phase 2 use exactly the qualified uv version.
  Any uv is acceptable there if the before/after inventory proves the locked
  set is unchanged.
- Keep round 3's other points: the explicit verified alias is not an implicit
  `.venv` under lifecycle rule 4, and deployment and recovery use the
  release-pinned uv exactly, whatever the install location.

Writer response:

Round 3's same-files reasoning followed the previous wording, but the human's
new decision supersedes that premise. Accordingly, its proposed Q11 and
same-storage invariant are dropped, and exact qualified uv in phase 2 is not
required. This is an explicit human-directed revision, not an inferred fallback.

Accepted the remaining reviewer points: effective group selection must make
mandatory sync a verified no-op; an explicit verified alias is not an implicit
venv under lifecycle rule 4; deployment and recovery must select exactly the
release-pinned uv artifact irrespective of install location. Added the human's
checkout-revision comparison and full equivalence evidence requirements.

The supplied addendum is passed verbatim as Human guidance. The private design
has been read; no private mechanism, library, image or script names are exported
to the requirement or this review. Please assess the new confirmed contract,
rather than reopening the superseded same-files decision. Runtime feasibility
and execution results are not claimed by this documentation update.

### Reviewer focus for feature-request deploy-venv-sync (round 4)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-09-22T09:31:48+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for feature-request deploy-venv-sync round 4

Round 4 applies the human's round 4 guidance completely and consistently.

- The CI section, Q06 and AC10 define "same environment" as toolchain Python
  and locked dependencies, reconstructed by our scripts on the phase 2 test
  agent from phase 1's toolchain archive digest, canonical lock and groups.
- A copied phase 1 venv and a library-created replacement are both forbidden.
- Phase 2 must record and compare the checkout revision, the digests, the groups,
  the interpreter and base-prefix provenance, and the inventory before and after
  the library's Python commands. Drift, revision mismatch and masked dependency
  failures all fail validation.
- The two-phase order, phase 1's archived artifacts and the unchanged library
  sources are kept.

No residual same-files demand survives. The phrase "release its agent
allocation" is now consistent, because phase 2 reconstructs its environment
rather than reaching phase 1's files. Round 3's proposed Q11 and same-storage
invariant are correctly absent. Phase 2's uv-version exception is bounded by
the inventory and command-success evidence, and the provenance section states
that it does not relax deployment or recovery, which still use exactly the
release-pinned uv. The explicit verified alias is distinguished from the implicit
`.venv` in both lifecycle rule 4 and Q06. The source draft carries no residual
of the superseded wording.

On the writer's focus points:

- **Equivalence evidence:** sufficient. Provenance is verified against the
  selected toolchain rather than requiring equal absolute paths, which is right
  for fresh agents.
- **Checkout revision comparison:** correct, and failing on mismatch is the
  truthful choice.
- **Effective group selection:** correct in substance. The wording "must
  include" understates the condition; see the covered wording.
- **Masked failures:** covered for dependency and test commands alike.

What remains is wording only. Q02, Q05 and Q09 still await human confirmation at the gate.

### Question verdicts for feature-request deploy-venv-sync round 4

- **Q01, Q03, Q04, Q07, Q08 (confirmed):** no change.
- **Q02, Q05, Q09 (proposed A):** unchanged; I would still choose A for each.
- **Q06 (confirmed A):** agree. It reflects the human's clarified meaning of
  "same environment", and option B is correctly kept only as the superseded choice.
- **Q10 (confirmed B):** agree, including the release-pinned uv rule for
  deployment and recovery.

No missing question. Round 3's proposed Q11 is no longer needed.

### Convergence evidence for feature-request deploy-venv-sync round 4

Covered wording:

- **Group selection (CI section, Q06 answer, AC10):** "Phase 1's
  dependency-group selection must include whatever the library's unqualified
  sync selects by default" understates the condition, because an exact sync
  also removes packages outside its selection. Say instead: "Phase 1's effective
  dependency selection must equal the selection the library's unqualified sync
  applies, so that sync neither adds nor removes distributions."
- **Revision mismatch (CI section):** add "A mismatch caused by a branch update
  between the two checkouts is reported as such and requires a new build; it is
  not treated as a product failure or silently accepted."
- **AC10:** consider splitting it into one criterion for phase 2 environment
  equivalence and evidence, and another for build sequencing and failure
  propagation. It currently carries both, which will make the validation plan's
  per-criterion results hard to read.

Convergence rationale:

Every in-scope decision is settled: human-confirmed for Q01, Q03, Q04, Q06,
Q07, Q08 and Q10, or exposed as a well-formed proposal I would also choose for
Q02, Q05 and Q09. The round 4 guidance is applied without residual superseded
wording, no question is missing, and the remaining edits change no decision.
Convergence is advisory: consolidation still requires the human's choice,
including confirmation of the three proposed answers.

### Human guidance response for feature-request deploy-venv-sync round 4

Human guidance:

Human guidance for round 4 (supersedes parts of the round 3 review answer):

The mandated shared-library stages run on freshly provisioned, one-shot agent
containers that the unchanged library allocates itself, each with its own
checkout. The phase 1 venv files cannot reach them, and running phase 2 on
phase 1's agent is not possible. "Same environment" therefore means our
toolchain Python and our locked dependencies. It does not mean the same venv
files.

Keep the two-phase order and phase 1's archived artifacts unchanged. In the
mandated test stage, a venv is built by our own scripts, before the library's
Python commands run, from the same toolchain archive digest and the same
canonical lock and dependency groups as phase 1. The library's own
dependency, activation and test commands must use that venv. The mechanism is
design, selected through the consuming Jenkinsfile and a tracked application
script; the shared-library sources stay unchanged.

Revise the requirement accordingly:

- Q06, AC10 and the CI section: replace "the same venv validated in phase 1"
  with "a venv built by our scripts in the phase 2 test agent from the same
  toolchain archive digest, canonical lock and dependency groups, using the
  toolchain Python". Keep a copied phase 1 venv forbidden. Keep a venv created
  by the library's own commands (for example an implicit project venv built
  with another interpreter) forbidden.
- Require phase 2 evidence of that equivalence: toolchain archive digest, lock
  digest and groups, resolved interpreter and base prefix, venv path, and the
  selected inventory captured before and after the library's Python commands,
  compared with phase 1. Any drift, or a failed library dependency command,
  fails validation even when the library masks it.
- Require the phase 1 dependency-group selection to include whatever the
  library's unqualified dependency sync selects by default, so that sync is a
  verified no-op rather than a change.
- Record the checked-out revision in phase 2 and compare it with phase 1's,
  because the library checks out the branch tip, not a pinned revision.
- Drop round 3's proposed Q11 (how the same files reach phase 2) and its
  same-storage invariant: this decision makes both unnecessary.
- Drop round 3's demand that phase 2 use exactly the qualified uv version.
  Any uv is acceptable there if the before/after inventory proves the locked
  set is unchanged.
- Keep round 3's other points: the explicit verified alias is not an implicit
  `.venv` under lifecycle rule 4, and deployment and recovery use the
  release-pinned uv exactly, whatever the install location.

Guidance response:

The round 4 human guidance supersedes the same-files premise of the round 3
answer, and this review assesses the requirement against it rather than
reopening that premise. Each item of the guidance is reflected in the current
text: the redefinition of "same environment", the equivalence evidence, the
default-group condition, the revision comparison, the two dropped round 3
demands, and the two retained round 3 points. The only refinement proposed is
the covered wording on group selection, which states the guidance's own "no-op"
intent exactly.

### Writer instructions for feature-request deploy-venv-sync round 4

No further review round is needed. Apply the covered wording during
consolidation, after the human confirms Q02, Q05 and Q09. Do not treat this
convergence recommendation as that confirmation.

### Final reviewer decision for feature-request deploy-venv-sync round 4

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-4 -->

## Round 4 by human - human-confirmation

- Recorded: 2026-09-22T09:52:23+02:00
- Exchange: specification/feature-request/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-4 -->
