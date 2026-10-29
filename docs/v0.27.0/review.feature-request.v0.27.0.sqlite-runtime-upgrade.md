# Specification review transcript for v0.27.0

- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-10-27T20:52:14+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for feature-request sqlite-runtime-upgrade (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
Review round: 1

### Requestor assessment for feature-request sqlite-runtime-upgrade (round 1)

This is the first specification review of this feature request. Its
implementation came first, under an urgent request; the requirement records
the settled decisions and their evidence, and its code review converged on
2026-10-27. The independent assessment asked for is of the whole requirement,
not only of the questions below.

The writer review added fifteen open questions, Q01 to Q15. None existed
before. Each targets a gap between the requirement's statements, its
acceptance criteria and the delivered evidence:

- scope: the targets "every supported target" covers (Q01), what
  "reproducible" requires (Q02), whether item 9 completes before publication
  (Q12), whether a `sqlite3` shell is in scope (Q13) and whether known CPython
  defects are (Q15);
- expected behaviour: option parity as a floor or an exact set (Q03), the
  strictness of the expected-build comparison, compiler string included (Q04),
  and the meaning of "a later patch release is a reason to ask" (Q11);
- acceptance precision: AC4's sandbox scope against the archive-wide sentence
  (Q05), what passing AC7 means with five unnamed skips (Q06), AC9's literal
  wording against the injected monitoring library (Q07), the archive AC8
  upgrades from (Q08) and AC5's unrecorded-tree case (Q14);
- edge cases and contracts: rollback for data written under 3.54.1 (Q09) and
  the verification bundle pairing for consumers (Q10).

Every question has at least two options with pros and cons, a recommendation
with its arguments, an answer line and `User decision: pending`. Each
recommendation states whether the delivered behaviour already matches it.
Three recommendations would add evidence or documentation if accepted: the
skip reasons for Q06, the pinned archive's digest for Q08, and wiki notes for
Q09, Q13 and Q15.

The writer found no further question that belongs in a feature request.
Questions about how the checks are built (fixture design, hook placement,
probe structure) were left out as design or plan matters. The only lines over
80 columns are the template's own `Answer to Qxx` headings.

### Change summary for feature-request sqlite-runtime-upgrade (round 1)

Round 1 starts from the committed requirement (`f11aa8e`). The only change is
the new `## Open questions for the v0.27.0 bundled SQLite feature request`
section at the end of the document, placed through `oqm`, with questions Q01
to Q15. No earlier section of the requirement changed.

### Writer response for feature-request sqlite-runtime-upgrade (round 1)

Writer response:

No reviewer feedback exists yet for this exchange. The writer asks for an
independent check of the whole requirement: missing questions, questions that
belong in the design or the plan instead, options that miss a credible
alternative, and recommendations that conflict with the umbrella's decisions
(D7, D12) or with the delivery boundary.

### Reviewer focus for feature-request sqlite-runtime-upgrade (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `codex`

Completed artifacts:

- `.reviews/a.review-active.specification.feature-request.v0.27.0.sqlite-runtime-upgrade.md`
- `.reviews/a.review-requested.feature-request.v0.27.0.sqlite-runtime-upgrade.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-10-27T21:00:20+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: answer

### Reviewer assessment for feature-request sqlite-runtime-upgrade round 1

The current formulation needs substantive corrections before convergence.
Q01-Q15 are relevant requirement questions; implementation placement and test
fixture design correctly remain outside this review. No separate Q16 is needed:
the missing provider-identity and bundle-compatibility alternatives fit Q05 and
Q10. All fifteen human decisions remain pending.

The recommendation preserves the source-built release, feature floor, legacy
SONAME and removal of DISABLE_DIRSYNC confirmed in umbrella D12. It does not
reopen superseded D7. Completing the item at a qualified candidate is compatible
with the umbrella's later release rebuild only if the rebuilt bytes receive
the required qualification.

Five findings require another round: Q05 overstates the archive-wide guarantee
of the closure gate; Q06 understates the environments needing skip evidence;
Q08 hides a conditional upgrade run; Q10 conflates a qualified archive/bundle
pair with exact Git-commit identity; Q15 presents an upstream report as an
established defect of this runtime and offers an unsupported threading fix.

This is an independent specification assessment of the full current document,
the exact request, selected implementation and validation references, the
umbrella decisions, and the upstream issue reports. No build, runtime test,
pipeline run, publication, or consolidation was performed. Historical
qualification results remain recorded writer evidence. Earlier code-review
convergence does not establish newly proposed acceptance claims.

### Question verdicts for feature-request sqlite-runtime-upgrade round 1

- Q01: Agree with A1. The question is necessary because the user story is
  broader than AC8/AC9; A1/A2/A3 have distinct scope and evidence costs.
  Specify the RHEL 9 x86_64 build family and claims limited to the two qualified
  environments. Closure compatibility alone does not qualify another host.
- Q02: Agree with B1, with wording correction. B1/B2/B3 distinguish identified
  configuration, byte reproducibility and retained source availability.
  Say "repeatable verified configuration" or define identity precisely. The
  probes establish reported source/configuration identity and library shape;
  they do not prove byte equality or by themselves demonstrate two rebuilds.
  Do not describe configuration matching as proof of the shipped binary.
- Q03: Agree with C1. The floor/exact-set choice is relevant and materially
  distinct. Preserve every confirmed parity feature, reject DISABLE_DIRSYNC,
  and pin the complete reported option set including additional defaults.
  Acknowledge newer feature use can affect rollback; Q09 owns that consequence.
- Q04: Agree with D1 after wording correction. D1/D2/D3 clearly distinguish
  full option matching, compiler exclusion and a subset check. Keep COMPILER
  in the strict comparison and require review plus requalification on change.
  Replace "exact build" claims with "expected source/configuration identity";
  compiler-string equality is not binary equality. The cost includes
  requalification, not just a one-line edit.
- Q05: Revise; prefer strict E1 if the intended promise is one physical
  library. E1/E2 distinguish scope but omit the credible whole-archive
  alternative of one provider content identity with identical copies allowed.
  Present that distinction explicitly. Existing closure checks do not prove
  E1's physical-file count. Proposed E1 wording: "Packaging acceptance records
  an inventory of SQLite libraries across every tool root, showing one real
  library and links resolving to it." Mark the evidence gap instead of saying
  it is already covered; see R1.
- Q06: Agree with F1's policy, but revise its evidence claim. F1/F2/F3 expose
  meaningful strictness and waiver choices. Record named skips and reasons
  for each required installed/relocated and host environment, tied to the
  tested archive or build identity. Existing logs may supply this; otherwise
  obtain the missing runs or justified equivalent evidence. A user waiver
  must remain a recorded exception, not be reported as an ordinary pass.
  One build-host verbose run does not automatically cover Debian; see R2.
- Q07: Agree with G1. The alternatives distinguish a narrow host-injection
  exception, an injection-free environment and an overly broad exclusion.
  Keep a named, reported exception only for independently host-injected
  instrumentation. Never exempt a required toolchain library merely because
  it also appears in the host's injection configuration. Keep private agent
  identities and paths in private evidence.
- Q08: Agree with H1, but revise the conditional cost and completion claim.
  H1/H2/H3 are useful, distinct predecessor scopes. Record the actual
  consumer-pinned predecessor identity. Matching digest permits reuse of
  the existing upgrade evidence; a different or unknown digest requires
  qualification of that predecessor and retained results. This can require
  a new run and is not "at most one digest comparison"; see R3.
- Q09: Agree with I1. The options expose toolchain restoration, a narrow
  database check and a prohibition on rollback. State that restoring the
  previous archive restores its old defects and feature set; database and
  application compatibility remain the consumer's responsibility. Do not
  imply that every database written by 3.54.1 becomes unreadable by 3.34.1.
- Q10: Revise J1; prefer an immutable, demonstrated-compatible pair. Adopting
  both pins and changing the probe input is reasonable; exact equality of
  the archive and bundle's Git revision is a separate, stronger restriction
  not implied by an external trust anchor. Add the compatible committed
  bundle alternative, or revise J1 to include it. Proposed wording:
  "Adoption pins archive and verification-bundle digests together. The bundle
  comes from an identified committed revision and contains the compatible
  probe and expected-build file qualified with that archive; documented
  tree/content-equivalent revisions are allowed. The previous bundle need
  not verify the new archive." If strict same-revision policy is retained as
  an option, state its additional cost and evidence needs; see R4.
- Q11: Agree with K1. Monitoring, a build-time lookup and a scheduled watcher
  are distinct choices. K1 respects D12's human release selection, requires
  new pins and repeat acceptance, and does not introduce monitoring scope.
  Retain the procedure in documentation when this choice is confirmed.
- Q12: Agree with L1. Candidate qualification, publication and adoption are
  different completion gates. Preserve the separate authorization gates.
  Clarify that the umbrella's later rebuild is allowed, but its new archive
  requires qualification before release; a same-version rebuild cannot
  inherit the old candidate's digest or runtime evidence.
- Q13: Agree with M1, with wording correction. Library-only guidance and a
  newly shipped shell are meaningful scope alternatives. Say the toolchain
  wrapper's python -m sqlite3 selects the bundled provider and reduces the
  risk of accidentally using the host runtime. It still permits writes and
  does not remove concurrent-operation or workload risks. Avoid describing
  a documentation paragraph as removing the operator risk.
- Q14: Agree with N1. Missing metadata versus a known matching record is a
  necessary first-upgrade distinction, and N2 conceals the stale-build case.
  Include absence explicitly in AC5's proposed rebuild condition, preserving
  the existing unreadable-input failure rule.
- Q15: Revise; choose a bounded form of O1. Document relevant upstream reports
  with affected versions/platforms, evidence status and qualified guidance;
  do not claim this runtime is affected without evidence. The current O2
  is not a substantiated mitigation: changing reported threadsafety does not
  prevent check_same_thread=False and may reduce SQLite's protection.
  Preserve the confirmed threading setting; remove the asserted safety
  benefit or replace O2 with explicit applicability investigation as a
  separate scope choice. Attribute one-connection-per-thread advice as a
  reported avoidance pattern, not a proven fix for this qualified runtime;
  see R5.

### Requested changes for feature-request sqlite-runtime-upgrade round 1

Requested changes:

R1 - Q05's strict archive-wide single-file guarantee is not established.
src/setups/env/bin/closure_rules.sh:413-478 groups candidates by loader lookup
name, resolves links and permits distinct physical targets with equal content
digests (line 474). Differently named same-SONAME objects are not automatically
competing candidates. The provider-directory check in
src/install/env/python/sqlite_probe.py:337-346 is narrower than the archive.
Removing the observed stale Git-root provider and passing closure therefore
does not prove exactly one real libsqlite3.so* file across all roots.
Distinguish strict physical inventory from unique provider content; identify
the inventory evidence needed for strict E1, and remove "existing evidence
already covers it" unless that independent archive-wide evidence is supplied.

R2 - Q06 must cover all required qualification environments.
The validation plan reports 541 tests and five skips for the installed tree,
the RHEL relocation and Debian (lines 106-107, 161-163 and 230). Counts do not
identify skips or establish that each host skipped the same tests for the same
reason. Replace the one-build-host-run sufficiency claim with named skip
evidence for every required context, or a documented equivalence justification.
Unexplained skips stay unresolved. Preserve zero failures/errors and explicit
human waivers recorded as exceptions.

R3 - Q08 must state the extra run when the actual predecessor differs.
The recorded upgrade used an archive carrying Python 3.13.9 (validation plan
lines 164-165); the requirement does not identify it as the consumer's actual
pin. Keep H1, but replace "at most one digest comparison" with the two branches:
matching predecessor identity permits reuse; different or unknown identity
requires testing the actual pinned predecessor and retaining its identity and
results. Describe this as conditional missing evidence, not delivered coverage.

R4 - Q10 needs a credible compatible-bundle alternative.
AC9 requires a committed external bundle, while the acceptance environment
requires a digest-pinned archive/bundle pair. Neither requires equal Git commit
IDs. The validation plan records an original bundle commit with a tree equal
to its reworded commit (lines 197-201), and later changes that leave the probe
and expected-build files unchanged (lines 266-268). That history supports
explicit provenance and compatibility, not the asserted necessity of exact
revision equality. Revise J1 or add an option for compatible committed bundles
with immutable digests and documented equivalence. Do not claim the stronger
same-revision rule is already established by the candidate run.

R5 - Q15 must qualify applicability and remove the unsupported threading fix.
The report at <https://github.com/python/cpython/issues/160699> describes
CPython 3.15.1 on Windows 11 with SQLite 3.53.4; its confirmation comment
describes CPython 3.14.9 on Windows 11 with SQLite 3.53.1. Those reports do not
establish impact on CPython 3.13.15/Linux/SQLite 3.54.1. Replace "known to affect
the bundled runtime" for this example with "upstream report whose applicability
to this qualified runtime is unverified", unless specific evidence is supplied.
O2's "avoids the crash path" is unsupported: lowering SQLite's threading mode
does not enforce Python's connection-sharing check and can remove serialization.
Remove that asserted benefit, preserve THREADSAFE=1, and distinguish a reporter's
workaround from a verified guarantee. The title, analogy and O3 consequence
must likewise stop presenting this candidate's crash as established fact.

Wording alongside these findings: Q02/Q04 must distinguish reported
source/configuration identity from binary identity and include the cost of
requalification. Q13 should say guidance reduces host-provider confusion;
python -m sqlite3 is not a read-only or concurrency-safety guarantee.

### Writer instructions for feature-request sqlite-runtime-upgrade round 1

Revise the open-question formulations and proposed answers without
consolidating them or marking human decisions confirmed. Address R1-R5,
including their consequences for claimed delivered evidence. The wording
corrections for Q02, Q04 and Q13 can be included in the same revision.

Retain D12 and the existing delivery boundary. At this specification stage,
identify any additional implementation/qualification evidence that an accepted
choice would require; do not manufacture completed acceptance or imply that
the reviewer ran those checks. A clear pending evidence obligation is suitable
for reviewing the proposed requirement.

Keep the strict single-file choice distinguishable from unique content
identity, and bundle compatibility distinguishable from exact revision
identity. Explain a disagreement with either recommendation explicitly rather
than silently retaining the unsupported rationale.

Publish another specification review request with a concise response to each
finding. All Q01-Q15 user decisions remain pending. No consolidation, commit,
release, adoption or private-evidence disclosure is authorized by this answer.

### Final reviewer decision for feature-request sqlite-runtime-upgrade round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-10-27T21:09:55+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: request

### Review identity for feature-request sqlite-runtime-upgrade (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
Review round: 2

### Requestor assessment for feature-request sqlite-runtime-upgrade (round 2)

Round 1 raised five findings (R1 to R5) and wording corrections for Q02, Q04
and Q13. The writer accepted all of them; no disagreement remains. The
questions keep their IDs, and every user decision stays pending.

The revision states evidence the accepted choices would still need, instead
of presenting it as delivered:

- Q05 (E1): an inventory of SQLite libraries across every tool root of the
  qualified archive, showing one real library and links resolving to it.
- Q06 (F1): named skips with reasons for the installed tree, the RHEL
  relocation and the Debian agent, from existing logs where they suffice,
  otherwise from new runs or a documented equivalence.
- Q08 (H1): the consumer's pinned predecessor digest; a mismatch or an
  unknown pin requires a new upgrade run.
- Q10 (J1): a documented equivalence between the bundle's recorded commit and
  the current branch, which the validation plan already records as a tree
  equality.

The writer found no further missing question. The reviewer's suggested
provider-content and compatible-bundle alternatives now sit in Q05 (E3) and
Q10 (J1, with the strict rule as J4), as the reviewer proposed, rather than
in a new question.

### Change summary for feature-request sqlite-runtime-upgrade (round 2)

Only the open questions section changed; the body of the requirement is the
committed text.

- Q02: B1 is now "a repeatable verified configuration": every build either
  reports the expected source and configuration identity and shape, or is
  refused; no byte identity or demonstrated second build is claimed.
- Q04: "that exact build" reads "the expected source and configuration
  identity"; D1's cost includes requalification, and compiler-string equality
  is stated not to be binary equality.
- Q05: the description explains that the closure gate accepts identical
  content under one lookup name; E1 becomes a strict physical inventory with
  pending evidence, and a new E3 offers unique provider content.
- Q06: F1 covers every qualification environment, ties skips to the tested
  identity, keeps unexplained skips unresolved and records waivers as
  exceptions; the one-run cost claim is gone.
- Q07: G1 never exempts a required library named by the host's injection
  configuration, and keeps agent identities in private evidence.
- Q08: H1 states both branches, reuse on a matching digest and a new run on a
  different or unknown one, as conditional evidence.
- Q09: I1 says rollback restores the old defects and features, and that many,
  not all, databases written by 3.54.1 stay readable.
- Q10: J1 is a digest-pinned compatible pair from an identified committed
  revision, with documented equivalent revisions allowed; new J4 is the strict
  same-revision rule with its cost.
- Q12: L1's argument says a later rebuild needs its own qualification and
  cannot inherit the candidate's digest or evidence.
- Q13: M1 says the shell selects the bundled provider and reduces host
  confusion; it is not a read-only or concurrency-safety guarantee.
- Q14: N1 names absence in AC5's rebuild condition and keeps exit 26.
- Q15: retitled and rewritten around an upstream report whose applicability
  is unverified, with the reported versions and platforms; O2 is now an
  applicability investigation, the threading-mode change is gone, and
  `THREADSAFE=1` is kept.

### Writer response for feature-request sqlite-runtime-upgrade (round 2)

Writer response:

- **R1, accepted.** Checked against `closure_rules.sh`: rule 1 groups by
  lookup name and passes identical content at distinct paths. Q05 now
  distinguishes strict inventory (E1, recommended, evidence pending) from
  unique content (E3), and no longer claims existing evidence covers E1.
- **R2, accepted.** Q06 F1 requires named skips per qualification
  environment, Debian included, or a documented equivalence; the
  one-build-host claim is removed.
- **R3, accepted.** Q08 H1 states the reuse and new-run branches and calls the
  recorded upgrade conditional evidence.
- **R4, accepted.** J1 now uses the proposed compatible-pair wording; the
  strict same-revision rule is J4, with the cost that the recorded Debian run
  would not satisfy it.
- **R5, accepted.** Q15 no longer presents gh-160699 as a defect of this
  runtime; it records the reported versions and platforms as unverified for
  this runtime, drops the threading-mode change, keeps `THREADSAFE=1`, and
  attributes one connection per thread as the reporters' avoidance pattern.
- **Wording, accepted.** Q02 and Q04 separate reported identity from binary
  identity and include requalification; Q13 claims reduced confusion, not
  safety. Q07, Q09, Q12 and Q14 carry the clarifications from the verdicts.

### Reviewer focus for feature-request sqlite-runtime-upgrade (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-10-27T21:12:29+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: answer

### Reviewer assessment for feature-request sqlite-runtime-upgrade round 2

The revision resolves R2-R5 and the earlier wording corrections. R1 is
partially resolved: recommended E1 now correctly requires a pending archive
inventory, but new E3 still attributes a stronger global guarantee to the
closure evidence than that check supplies. One targeted substantive correction
remains before convergence; no new question is needed.

The review covers the full current requirement and the exact round-2 request,
with the previously inspected source and validation evidence. Confirmed D12,
the candidate/publication boundary, and all fifteen pending human decisions
remain intact. The unchanged body is intentionally awaiting consolidation;
that alone is not review drift.

The specification may describe future evidence obligations without first
executing them. This answer does not require new qualification work during
specification review. It requires the option and its stated cost to reflect
that obligation accurately.

### Question verdicts for feature-request sqlite-runtime-upgrade round 2

All Q01-Q15 remain relevant, within scope and distinct enough for a human
choice; none needs deletion or a separate replacement question. Except for
E3 in Q05, the options and proposed answers now state the material consequences
needed for this review.

- Q01: Choose A1. It limits qualification claims to RHEL 9.8 and Debian 12
  for the RHEL 9 x86_64 build family.
- Q02: Choose B1. The revised verified-configuration contract correctly
  avoids claiming binary identity or a demonstrated repeated build.
- Q03: Choose C1. The feature floor preserves confirmed parity while the
  full expected option list makes additional defaults explicit.
- Q04: Choose D1. Keep every reported option, including COMPILER, and review
  and requalify changes. Reported identity is now separated from binary
  equality. A small wording correction is supplied below.
- Q05: Choose E1. Its explicit archive inventory and pending evidence resolve
  the recommended answer's overclaim. Revise E3's scope/evidence relationship
  as specified in R1-E3 before presenting the alternatives as complete.
- Q06: Choose F1. It now covers installed, relocated and Debian contexts,
  ties skips to identity, leaves unexplained skips unresolved, and records
  any waiver as an exception. R2 is closed.
- Q07: Choose G1. The narrow instrumentation exception excludes required
  toolchain libraries even if also host-injected, and respects private
  evidence boundaries.
- Q08: Choose H1. Digest equality permits reuse; a different or unknown
  predecessor requires its own qualification. Conditional evidence is no
  longer described as completed coverage. R3 is closed.
- Q09: Choose I1. Toolchain restoration is distinct from application/database
  compatibility; the revised text explains both old defects and feature risk.
- Q10: Choose revised J1. The external committed bundle and archive are
  digest-pinned and qualified as a compatible pair, with documented equivalent
  revisions allowed. J4 exposes the stricter policy separately. R4 is closed.
  Update the analogy's stale same-revision phrase as wording only.
- Q11: Choose K1. Human release selection, new pins and repeat acceptance
  remain consistent with D12; automated monitoring is separate scope.
- Q12: Choose L1. Qualification can complete before publication/adoption,
  while later release rebuilds need qualification of their new bytes.
- Q13: Choose M1. Toolchain python -m sqlite3 selects the bundled provider;
  the revised wording no longer promises read-only operation or concurrency
  safety.
- Q14: Choose N1. Missing input records trigger rebuild; unreadable inputs
  still stop with exit 26.
- Q15: Choose revised O1. The runtime applicability of the reported Windows
  crashes is expressly unverified; attributed guidance preserves THREADSAFE=1.
  Investigation is now a credible separate option. R5 is closed.

These are reviewer preferences, not user decisions. All fifteen user decisions
remain pending. Evidence obligations from E1, F1 and H1 and the proposed
documentation obligations remain for the owning workflow if accepted.

### Requested changes for feature-request sqlite-runtime-upgrade round 2

Requested changes:

R1-E3 - The new alternative still conflates per-name consistency with global
provider-content uniqueness.

Q05's introduction correctly says the closure gate compares each loader lookup
name. E3 then promises "The whole archive, one provider content", says "any
candidate with different content is refused", and lists "Proven by the existing
closure evidence" as a benefit. The same implementation limit remains:
src/setups/env/bin/closure_rules.sh:413-478 deliberately does not group all
same-SONAME or all SQLite files together. A differently named SQLite file
without a competing lookup name need not enter the same comparison. A closure
pass therefore cannot establish that every SQLite copy in every root shares
one content digest.

Preferred replacement for E3, retaining the useful alternative:
"The whole archive, one provider content identity: identical real-file copies
may exist in several tool roots. An inventory of all SQLite libraries must
show that every copy has the same content digest; different content anywhere
fails acceptance."

Give that option its actual tradeoff:
"Allows redundant identical copies while excluding stale content. Requires
archive-wide inventory and digest evidence, which the per-lookup-name closure
gate alone does not supply; that evidence is pending."

Alternatively, explicitly narrow E3 to per-lookup-name loader-candidate
consistency and disclose that it does not fulfill archive-wide content
uniqueness. Do not retain a global promise with a claim of existing proof.
The option's acceptance scope and evidence cost affect the human choice, so
this is more than word polishing even though the edit can be small.

Wording only:

- Q04's final answer says the delivered probe enforces a "requalified event".
  The probe enforces the comparison; the qualification obligation belongs to
  the workflow. Suggested wording: "The delivered probe enforces the complete
  comparison; this policy requires review and requalification on change."
- Q10's analogy still calls the new key a bundle from "the same cplx revision".
  Use "an identified compatible cplx revision" to match revised J1.

### Writer instructions for feature-request sqlite-runtime-upgrade round 2

Make the targeted E3 correction without consolidating the requirement or
changing any user decision. Keep the E1 recommendation and the already
resolved findings intact. No test run is required to fix this specification
claim; accurately identify the additional evidence a choice would need.

Apply the two small wording corrections alongside it if useful, then publish
another review request with the response to R1-E3. The requestor retains
ownership of revisions; no release, adoption, commit or consolidation is
authorized by this answer.

### Final reviewer decision for feature-request sqlite-runtime-upgrade round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-10-27T21:16:53+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: request

### Review identity for feature-request sqlite-runtime-upgrade (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
Review round: 3

### Requestor assessment for feature-request sqlite-runtime-upgrade (round 3)

Round 2 closed R2 to R5 and left one correction, R1-E3, plus two wording
fixes. The writer accepted all three; no disagreement remains, no question was
added or removed, and every user decision stays pending.

E3 now promises one provider content identity across the archive and names
the archive-wide inventory and digest evidence it needs, which the
per-lookup-name closure gate does not supply. Q05's recommendation compares
E1 and E3 on that shared evidence: both need the same inventory, and E1 keeps
the requirement's sentence as written. E1 remains recommended.

The evidence obligations an accepted answer would create are unchanged from
round 2: the inventory for Q05, named skips per environment for Q06 and the
pinned predecessor's digest for Q08, plus the documentation obligations of
Q09, Q11, Q13 and Q15.

### Change summary for feature-request sqlite-runtime-upgrade (round 3)

Only the open questions section changed since round 2:

- Q05: E3 replaced by the reviewer's wording, "one provider content
  identity", with its pending archive-wide inventory and digest evidence as a
  con; the claim of existing closure proof is gone. The recommendation now
  explains why E1 is preferred over E3 when both need the same inventory.
- Q04: the answer says the delivered probe enforces the complete comparison,
  and the policy requires review and requalification on change.
- Q10: the analogy names "an identified compatible cplx revision".

### Writer response for feature-request sqlite-runtime-upgrade (round 3)

Writer response:

- **R1-E3, accepted.** E3 uses the preferred replacement and tradeoff
  wording. It no longer claims proof from the closure gate, which compares
  candidates per lookup name only. The narrower per-name alternative was not
  added, since the reviewer's replacement keeps E3 a whole-archive choice.
- **Q04 wording, accepted** as suggested.
- **Q10 wording, accepted** as suggested.

### Reviewer focus for feature-request sqlite-runtime-upgrade (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-10-27T21:18:59+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: answer

### Reviewer assessment for feature-request sqlite-runtime-upgrade round 3

Recommend convergence of the reviewed formulation. R1-R5, the round-2
R1-E3 remainder, and the covered wording corrections are resolved. No
substantive specification edit or additional question is needed before the
human decision stage.

Q05 now gives both whole-archive options their actual inventory obligation;
it no longer claims that per-lookup-name closure evidence proves global
content uniqueness. Q04 separates probe enforcement from workflow
requalification, and Q10's analogy matches its compatible-bundle policy.
The other twelve question sections and the requirement body are unchanged
from the assessed round-2 document.

The full current requirement, its proposed questions and the exact round-3
request remain consistent with confirmed umbrella D12 and with separate
candidate, release and adoption gates. The unchanged requirement body is
awaiting authorized consolidation of human choices; it is not evidence that
the proposals are already confirmed.

This is specification convergence, not a declaration that the proposed new
acceptance evidence has been collected. All fifteen user decisions remain
pending. Historical runtime and pipeline results remain recorded writer
evidence; no new runtime test or pipeline execution was performed by this
reviewer.

### Question verdicts for feature-request sqlite-runtime-upgrade round 3

All Q01-Q15 are relevant requirement questions. Their options now describe
materially distinct scope, policy or evidence choices with sufficient
consequences. None is missing, redundant or outside the selected scope in a
way that requires another question or review round. The provider-content and
bundle-compatibility alternatives fit Q05 and Q10 rather than a new Q16.

The reviewer's choices, with reasons, are:

- Q01: A1. Qualify the RHEL 9 x86_64 build family on RHEL 9.8 and Debian 12
  without claiming untested distributions.
- Q02: B1. Verified source and configuration identity is a clear enforceable
  contract; binary identity, a demonstrated second build and retained source
  availability are separate promises.
- Q03: C1. Preserve the confirmed feature floor, exclude DISABLE_DIRSYNC and
  pin every additional reported default.
- Q04: D1. Compare all options including COMPILER; review and qualification
  remain required workflow actions when that expected configuration changes.
- Q05: E1. One physical library best preserves the stated archive promise.
  E3 is now a credible distinct alternative allowing identical copies with
  archive-wide inventory and digest evidence. Both accurately state evidence
  still needed; the closure gate alone proves neither global inventory.
- Q06: F1. Explain skips for every required environment and identity; unknown
  skips remain unresolved and any waived failure remains an explicit exception.
- Q07: G1. A narrow, named and reported host-instrumentation exception permits
  the real agent check without exempting required toolchain libraries.
- Q08: H1. Qualify the consumer's actual predecessor. Reuse evidence only on
  matching identity; otherwise retain the new predecessor-specific run.
- Q09: I1. Restore the previous toolchain with its old defects and features;
  application and database rollback compatibility belongs to the consumer.
- Q10: J1. Pin and qualify the compatible archive/bundle pair with committed
  provenance and documented equivalence, keeping expected inputs external.
  Exact revision equality is correctly offered separately in J4.
- Q11: K1. Preserve human release selection and repeat qualification without
  adding automated release monitoring to this item.
- Q12: L1. Complete the item at a qualified candidate under its chosen
  acceptance rules. Publication and adoption remain separate; a later rebuilt
  archive needs its own qualification.
- Q13: M1. Document the toolchain wrapper's python -m sqlite3 to select the
  bundled provider, without a read-only or concurrency-safety guarantee.
- Q14: N1. Rebuild an unrecorded Python tree instead of recording new inputs
  over a possibly stale build; retain the unreadable-input failure.
- Q15: O1. Give bounded, attributed upstream-report guidance with explicitly
  unverified applicability to this runtime, preserving THREADSAFE=1.

Every choice above is reviewer agreement with a proposal. Q01-Q15 all retain
User decision: pending; none is confirmed by this answer.

### Convergence evidence for feature-request sqlite-runtime-upgrade round 3

Covered wording:

The reviewed wording covers all earlier corrections: expected configuration
instead of binary identity; inventory instead of overclaimed closure proof;
environment-specific skip evidence; both predecessor-qualification branches;
compatible committed bundle provenance; and attributed upstream reports with
unverified applicability.

Round 3 additionally states that the probe enforces comparison while the
policy requires requalification, and uses an identified compatible revision
in Q10's analogy. No further wording edit is required for convergence.

Convergence rationale:

The questions, credible alternatives and proposed answers are complete and
consistent for this feature-request scope. All substantive review findings are
resolved, and the document now distinguishes requirements to adopt from
evidence already delivered. Confirmed release, SONAME, feature and threading
constraints remain intact; release rebuild qualification and the consumer's
separate workload responsibility remain explicit.

Convergence recommends this formulation for human decisions. It does not
settle the fifteen pending choices, authorize consolidation, or mark the
newly stated inventory, skip and predecessor obligations completed. Those
remaining obligations are accurately specified future work, not unresolved
defects in the reviewed formulation.

### Writer instructions for feature-request sqlite-runtime-upgrade round 3

Present the convergence recommendation and all outstanding human decisions
through the owning workflow. Do not consolidate until the human authorizes
that action, and do not convert the reviewer's preferred options into user
decisions.

If those proposals are accepted, carry their consequences into the requirement,
related documentation and validation tracking. In particular, retain the
pending archive inventory for E1, named skip reasons per qualification context
for F1, and actual predecessor identity plus any conditional upgrade run for
H1. Preserve compatible bundle provenance under J1 and the documentation
obligations in I1, K1, M1 and O1. Apply selected scope and acceptance wording
consistently when consolidation is authorized.

This review does not grant commit, release, adoption, evidence-waiver or
private-information disclosure authority. No further automated specification
revision is requested for the current formulation.

### Final reviewer decision for feature-request sqlite-runtime-upgrade round 3

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-3 -->

## Round 3 by human - human-confirmation

- Recorded: 2026-10-28T10:39:58+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: human-confirmation

Human choice: Revise and review again
Outcome: another-round
Guidance: The user's directions, verbatim (2026-10-27, chat; the consuming project's
name is replaced by a bracketed role):

- "For all of this question, the urgency is to allow [the consuming project]
  to run/use SQlite on its target server (RHEL 9.8) or through its Jenkins
  CICD Docker Image Debian 12. That's it. I do not care about anything else
  right now. So adjust any claim to that specific scenario." Then: "(For all
  of those questions, actually, not just Q01)".
- "resume by accepting everything default narrowed to my scenario as the work
  as been done, sqlite has been compiled, the goal is to get that development
  effort back to the current integration branch as fast as possible".
- "This is release time, not feat/design/pan time".
- On this follow-up review: "one round of review (the reviewer will be up)".

<!-- review-entry-id: human-confirmation-round-3 -->

## Round 4 by requestor

- Recorded: 2026-10-28T10:41:23+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: request

### Review identity for feature-request sqlite-runtime-upgrade (round 4)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
Review round: 4

### Requestor assessment for feature-request sqlite-runtime-upgrade (round 4)

Round 3 converged with every question relevant and every recommendation
agreed. This replacement round reviews what happened after that convergence:
the user's decisions on Q01 to Q15, the scenario they narrow every claim to,
and the evidence and documentation collected to keep those decisions true.

The scenario is the consuming project's two environments: its RHEL 9.8
target server and its Debian 12 CI container image. The user asked that
every claim be narrowed to it and that no new feature, design or plan work be
added; the human guidance below quotes those directions. Fourteen decisions
take the recommended option, narrowed. Q05 departs from the reviewed
recommendation: the user chose E2 (Python's sandbox only) over E1, so the
archive-wide inventory is no longer required, and the expected-behaviour
sentence on "exactly one SQLite provider" is to be narrowed to AC4 at
consolidation.

No question is missing in the writer's assessment, no option or recommended
answer was edited, and the requirement body above the open questions section
still holds the pre-decision wording (for example "every supported target",
"reproducible from verified source" and the archive-wide single-provider
sentence): consolidation rewrites it from the recorded decisions, once this
round converges.

The evidence obligations listed at round 3 are now closed or removed:

- Q05 inventory: removed by the E2 decision.
- Q06 named skips: one verbose RHEL 9.8 run names all five, none tied to the
  SQLite build or the distribution; the Debian run's identical counts rest
  on that equivalence.
- Q08 predecessor: the consuming project's pinned archive differs from the
  Step 4 predecessor, so the upgrade was qualified again from the pinned
  archive, and passed.
- Q09, Q13, Q15 documentation: one new section of the wiki explanation page.
- Q11 procedure: the existing how-to already covers it; no edit.

Please check the decisions against each other and against the requirement,
the umbrella row, the plan, the validation plan and the wiki, within the
two-environment scenario: an inconsistency, a claim the recorded evidence does
not support, or a missing question that this scenario itself raises. A
recommendation that conflicts with a recorded human choice should be raised
as a conflict, not applied over the choice.

### Change summary for feature-request sqlite-runtime-upgrade (round 4)

Since round 3 converged, only recorded user decisions, one wiki section and
one validation-plan bullet changed. No question, option, recommendation or
answer text was edited; the
requirement body before the open questions section is unchanged and waits for
consolidation.

- Q01 to Q15 each carry `User decision: confirmed: ...` with a "Decided by
  the user on 2026-10-27" paragraph. Every decision takes the recommended
  option, narrowed to the consuming project's RHEL 9.8 target server and its
  Debian 12 CI container image, except Q05: the user chose E2 over the
  reviewed E1 recommendation.
- Q06 and Q08 record evidence collected on 2026-10-28 for the narrowed
  decision: the five skips named from a verbose run, and an upgrade run over
  the archive the consuming project pins today. The validation plan's Step 4
  gains one bullet recording that run and the named skips.
- `wiki/explanation/why-the-toolchain-builds-its-own-sqlite.md` gains one
  section, "What the consuming application still decides", holding the
  rollback note (Q09 I1), the inspection shell note (Q13 M1) and the
  attributed gh-160699 note (Q15 O1). The how-to already described the
  release switch procedure (Q11 K1), so it is unchanged.

### Human guidance and writer response for feature-request sqlite-runtime-upgrade (round 4)

Human guidance:

The user's directions, verbatim (2026-10-27, chat; the consuming project's
name is replaced by a bracketed role):

- "For all of this question, the urgency is to allow [the consuming project]
  to run/use SQlite on its target server (RHEL 9.8) or through its Jenkins
  CICD Docker Image Debian 12. That's it. I do not care about anything else
  right now. So adjust any claim to that specific scenario." Then: "(For all
  of those questions, actually, not just Q01)".
- "resume by accepting everything default narrowed to my scenario as the work
  as been done, sqlite has been compiled, the goal is to get that development
  effort back to the current integration branch as fast as possible".
- "This is release time, not feat/design/pan time".
- On this follow-up review: "one round of review (the reviewer will be up)".

Writer response:

Round 3 requested no change; this response explains the recorded decisions
and the work done to keep them true.

- **Q01 to Q04, Q07, Q09 to Q12, Q14.** Recommended options, each narrowed to
  the two environments with no new obligation: the delivered build, probe and
  runs already satisfy them. Q07 names the one monitoring-library exclusion on
  the Debian agent; the RHEL server needs none.
- **Q05, E2 instead of E1.** The user chose the smaller surface. The
  decision records why it suffices for the scenario: the consuming project
  starts Python with the shipped library directories first, Python's own
  before every other tool root, so a copy in another root is not the one
  `sqlite3` loads; the probe refuses any loaded library other than the
  qualified one; and the closure gate refuses a differing copy under the same
  lookup name at packaging.
- **Q06, F1.** The skips were unnamed at round 3. A verbose run on RHEL 9.8
  names them: four big-memory tests that the CPython runner skips without a
  `-M` memory limit, and `test_uri_windows`. Neither reason depends on the
  SQLite build or the host distribution, which is the documented equivalence
  for the Debian run. No failure needed a waiver.
- **Q08, H1.** The pinned archive's digest did not match the Step 4
  predecessor (Python 3.13.9), so the reuse branch did not apply. The upgrade
  from the pinned archive (Python 3.13.15, SQLite 3.34.1) ran on 2026-10-28
  and passed, including the case the earlier run could not show: the same
  Python version, where the old `libsqlite3.so.0.8.6` must disappear and a
  venv made before the upgrade must load the new library. The Debian image
  relocates a fresh archive per run, so it has no upgrade. The result is also
  recorded in the validation plan, Step 4.
- **Q09, Q13, Q15, documentation.** The new section "What the consuming
  application still decides" of
  `wiki/explanation/why-the-toolchain-builds-its-own-sqlite.md` carries the
  rollback note, the `python -m sqlite3` inspection note and the attributed
  gh-160699 note, worded as the options describe.
- **Q11, K1.** The how-to's first step already pins a changed release and the
  same steps build and verify it, so no edit was needed.

### Reviewer focus for feature-request sqlite-runtime-upgrade (round 4)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-10-28T10:49:24+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: answer

### Reviewer assessment for feature-request sqlite-runtime-upgrade round 4

I reviewed the complete current requirement and round 4 request, the implementation and validation plans, umbrella item 9 and D12, and the SQLite explanation and build how-to. I did not use the versioned review transcript as assessment context.

The recorded human choices form a coherent runtime prerequisite for the consuming project's RHEL 9.8 server and Debian 12 CI container. All fifteen questions remain relevant, their options distinguish real consequences, and no additional question is needed within that scope. I agree with the chosen answers, including E2 in place of the earlier E1 recommendation. A whole-archive physical inventory is no longer an acceptance obligation.

The new Step 4 record identifies an upgrade from the consumer's actual Python 3.13.15 / SQLite 3.34.1 predecessor, preserving a pre-upgrade venv. The requirement supplies the predecessor's full digest and names the five skips. Its Debian equivalence argument is coherent for the same archive and test invocation: the four big-memory exclusions and the Windows-only exclusion do not depend on the SQLite build or Linux distribution. This is documented equivalence, not a claim that a Debian verbose log was inspected here. The run results remain recorded writer evidence; I did not execute the remote checks or retrieve raw logs.

I directly checked that the wiki contains the limited rollback promise, the wrapper-based inspection command and its limitations, and the attributed upstream report with applicability explicitly unverified. The existing how-to covers pinning, rebuilding and qualification for a later release. No implementation change or new qualification is requested.

One cross-document correction remains: umbrella item 9 still promises that nothing loads outside the prefix, whereas Q07 G1, implementation-plan Step 5 and validation-plan Step 5 explicitly allow one host-injected monitoring library. This is a literal acceptance contradiction, not an unresolved user choice. The disposition is changes-requested for that bounded correction only. The requirement body's acknowledged pre-consolidation wording is not a separate finding.

### Question verdicts for feature-request sqlite-runtime-upgrade round 4

No missing question was identified. All existing questions are relevant; none needs additional options or reopening for this two-environment delivery. The alternatives remain materially distinct. The following verdicts concern the recorded human decisions, which take precedence over recommendation text awaiting consolidation.

| Question | Reviewer choice | Verdict and reason |
| --- | --- | --- |
| Q01 | A1, narrowed as recorded | Agree. The two named consumer environments bound the qualified claim; other distributions and build families add unrelated work. |
| Q02 | B1, narrowed as recorded | Agree. Verified source and expected configuration identity are supported; byte-identical rebuilds and source retention are separate obligations the user did not select. |
| Q03 | C1 | Agree. Preserve the listed feature floor, permit pinned newer defaults, and exclude DISABLE_DIRSYNC. This is not an assertion that every old application behavior is unchanged. |
| Q04 | D1 | Agree. Compare the entire reported option set, compiler included. Requalification on a compiler change is deliberate; matching options alone do not prove binary equality. |
| Q05 | E2 | Agree with the human choice over E1. Python-sandbox uniqueness, qualified runtime provider mapping and the existing per-name closure rule address the selected consumer use. Do not retain the archive-wide inventory requirement or describe the closure check as proof of one physical file. |
| Q06 | F1 | Agree. Zero failures/errors, named skips and documented same-archive equivalence close the stated evidence obligation. Preserve the distinction between the RHEL verbose observation and Debian equivalence; an upstream failure still needs an explicit waiver. |
| Q07 | G1 | Agree. The exclusion is only the existing host-injected instrumentation rule, never a toolchain dependency. The plan and Debian record agree; umbrella item 9's absolute wording needs correction C1. |
| Q08 | H1 | Agree. The recorded consumer-pinned predecessor differs from the earlier Python 3.13.9 predecessor, so the new same-Python-version upgrade is the relevant branch. Retaining the pre-upgrade venv directly covers the consumer transition. Fresh Debian containers need no upgrade scenario. |
| Q09 | I1 | Agree. Rollback restores the old toolchain, including its limitations; database compatibility remains the consumer's decision. The new wiki paragraph states both risks. |
| Q10 | J1 | Agree. Archive and compatible external verification bundle are adopted as a digest-pinned pair. Preserve documented tree/content equivalence rather than silently requiring identical commit IDs. The validation plan records that provenance. |
| Q11 | K1 | Agree. Human selection and new pins/qualification for a later release suffice; automated watching is outside this delivery. The how-to already describes the build and verification sequence. |
| Q12 | L1 | Agree. The item can complete at the qualified candidate, with publication/adoption retaining their own gates. Publish qualified bytes; a rebuilt archive requires its own qualification before publication/adoption. This review does not authorize either gate. |
| Q13 | M1 | Agree. The wrapper's python -m sqlite3 uses the bundled provider without adding a shipped executable. The wiki explicitly avoids a read-only or concurrency guarantee. |
| Q14 | N1 | Agree. A missing input stamp requires rebuilding, as implementation-plan Step 2 already says; neither consumer environment builds Python itself. |
| Q15 | O1 | Agree. The attributed report and unverified applicability are correctly bounded, and do not justify changing THREADSAFE=1 or adding an applicability study. |

No Q01-Q15 choice remains undecided. Consolidation remains a separate human/workflow authorization.

### Requested changes for feature-request sqlite-runtime-upgrade round 4

Requested changes:

1. **C1: Align umbrella item 9's loader acceptance with confirmed Q07.** In docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md, the item 9 acceptance paragraph at lines 1449-1455 says "nothing loads from outside the prefix". The recorded Q07 G1 decision at requirement lines 605-612 and validation-plan Step 5 at lines 235-244 explicitly allow the Debian agent's host-injected monitoring library under its existing rule. As written, the umbrella rejects the very run that the child requirement accepts.

   Replace the absolute clause with: "the interpreter loader checks find no library outside the prefix except the Debian agent's host-injected monitoring library under its existing reported exclusion rule; that exclusion never covers SQLite, Python or a dependency of a toolchain ELF". Keep private agent names and paths out of the public text. No new exception, implementation work or test execution is needed: this states the user's existing G1 choice consistently.

No other substantive change is requested. In particular, the pre-consolidation requirement body was explicitly retained for the later authorized consolidation and is not itself a reason for another question round.

### Human guidance response for feature-request sqlite-runtime-upgrade round 4

Human guidance:

The round 4 request records these human directions, with the consumer's private name replaced by its role:

- "For all of this question, the urgency is to allow [the consuming project] to run/use SQlite on its target server (RHEL 9.8) or through its Jenkins CICD Docker Image Debian 12. That's it. I do not care about anything else right now. So adjust any claim to that specific scenario." Then: "(For all of those questions, actually, not just Q01)".
- "resume by accepting everything default narrowed to my scenario as the work as been done, sqlite has been compiled, the goal is to get that development effort back to the current integration branch as fast as possible".
- "This is release time, not feat/design/pan time".
- On the follow-up: "one round of review (the reviewer will be up)".

Guidance response:

I applied the guidance limiting every claim to the consumer's RHEL 9.8 server and Debian 12 CI container, respecting the urgent return to integration and the request for one review round. I preserved every recorded human decision, including E2, and did not propose new feature, design, plan, implementation or qualification work.

The only requested correction makes the umbrella's acceptance text agree with the already selected monitoring exception. It changes no policy and adds no delivery obligation. The owning session retains the one-round constraint and all consolidation/release authority; this reviewer publishes its assessment and resumes waiting.

### Writer instructions for feature-request sqlite-runtime-upgrade round 4

Address C1 by aligning umbrella item 9's acceptance paragraph with the already confirmed G1 decision. Keep its pending status and existing release/review gates; this specification answer establishes no implementation or completion verdict.

Do not reopen Q01-Q15, add an inventory, rerun the pipeline, rebuild the archive, or expand this into feature/design/plan work. The requirement body's acknowledged earlier wording can be updated by the separately authorized consolidation workflow, using the recorded decisions. In that consolidation, retain the Python-only provider scope, source/configuration rather than binary identity, the pinned predecessor, bounded monitoring exclusion, and qualified-byte publication rule.

The request carries the user's instruction for one review round. Report this one bounded correction and the agreed decisions to that owning workflow; this answer is not authorization for consolidation, a commit, publication, or an additional human review cycle. If a replacement request is authorized and published, its remaining assessment is limited to the correction and any material intervening changes.

### Final reviewer decision for feature-request sqlite-runtime-upgrade round 4

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-4 -->

## Round 5 by requestor

- Recorded: 2026-10-28T11:18:40+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: request

### Review identity for feature-request sqlite-runtime-upgrade (round 5)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
Review round: 5

### Requestor assessment for feature-request sqlite-runtime-upgrade (round 5)

Round 4 agreed with every recorded decision, Q05 E2 included, found no
missing question, and requested one bounded correction, C1: umbrella item 9's
acceptance paragraph said nothing loads from outside the prefix, which
contradicted the confirmed Q07 G1 exclusion of the Debian agent's
host-injected monitoring library.

C1 is applied with the reviewer's replacement wording. Nothing else changed:
the requirement, its decisions, the plan, the validation plan and the wiki are
as round 4 reviewed them. The user authorized this round for C1 only, so the
assessment requested is whether the umbrella paragraph now agrees with Q07 G1
and the Step 5 records, and whether the change introduces anything new.

### Change summary for feature-request sqlite-runtime-upgrade (round 5)

Only `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md` changed since round
4, in item 9's acceptance paragraph. The clause "nothing loads from outside
the prefix" now reads: "the interpreter loader checks find no library outside
the prefix except the Debian agent's host-injected monitoring library under
its existing reported exclusion rule, an exclusion that never covers SQLite,
Python or a dependency of a toolchain ELF". The item stays pending, and no
private agent name or path was added.

### Human guidance and writer response for feature-request sqlite-runtime-upgrade (round 5)

Human guidance:

The user's choice for this round, verbatim (2026-10-28, chat): "Run round 5,
C1 only".

Writer response:

- **C1, accepted.** Applied with the reviewer's replacement text, joined to
  the existing sentence; no new exception, implementation work or test run.
- **Scope of this round.** The user authorized one more round for C1 only
  ("Run round 5, C1 only", 2026-10-28, chat). No question is reopened and no
  other document changed.

### Reviewer focus for feature-request sqlite-runtime-upgrade (round 5)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-5 -->

## Round 5 by reviewer

- Recorded: 2026-10-28T11:21:24+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: answer

### Reviewer assessment for feature-request sqlite-runtime-upgrade round 5

C1 is resolved. I independently read the current umbrella item 9 acceptance paragraph and compared it with the confirmed Q07 G1 decision, implementation-plan Step 5 and validation-plan Step 5. The paragraph now permits only the Debian agent's host-injected monitoring library under its existing reported exclusion rule. It expressly forbids applying that exception to SQLite, Python or a toolchain ELF dependency. The interpreter-process scope also matches the recorded checks.

The correction adds no exception beyond the confirmed choice, private agent identity, implementation obligation or qualification run. The umbrella's item 9 row remains pending. This review supplies no implementation-completion or release authorization.

The requirement's SHA-256 remains 16600552aace62aabad1d6b2d3f586f5e8fbdea870dfbc0dd7ff6e967acfd612, byte-identical to the complete specification assessed in round 4. I retain that assessment of the fifteen recorded choices and independently close its sole requested correction here. No material conflict or new question arises from the C1 change. Remote execution results remain recorded writer evidence, not tests independently rerun by this reviewer.

### Question verdicts for feature-request sqlite-runtime-upgrade round 5

No new question is needed for C1, and no settled question is reopened. The unchanged specification retains the explicit human decisions accepted in round 4: Q01 A1 narrowed to the two consumer environments; Q02 B1; Q03 C1; Q04 D1; Q05 E2; Q06 F1; Q07 G1; Q08 H1; Q09 I1; Q10 J1; Q11 K1; Q12 L1; Q13 M1; Q14 N1; Q15 O1. I continue to agree with those choices for the reasons recorded in the substantive round 4 assessment.

For the only question implicated by this correction, Q07, G1 remains appropriate: accept only the pre-existing, reported host-instrumentation exclusion, never a host replacement for a toolchain dependency. The corrected umbrella now states exactly that boundary. Neither the no-exception alternative G2 nor the broad non-SQLite exemption G3 has been introduced.

There are no outstanding Q01-Q15 human choices. Whether to consolidate remains a separate human/workflow gate; this recommendation does not decide it.

### Convergence evidence for feature-request sqlite-runtime-upgrade round 5

Covered wording:

Covered correction: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md, item 9 acceptance paragraph:

> the interpreter loader checks find no library outside the prefix except the Debian agent's host-injected monitoring library under its existing reported exclusion rule, an exclusion that never covers SQLite, Python or a dependency of a toolchain ELF

This agrees with requirement Q07 G1 and the Step 5 plan and validation records. The adjoining runtime, CPython-test, upgrade and consumer-workload boundaries remain intact, and the item 9 table row stays pending.

Convergence rationale:

Recommend convergence. Round 4's only requested correction is applied and independently verified. It reconciles the umbrella with an existing explicit human decision without broadening scope or weakening the dependency boundary. The complete requirement is byte-identical to the assessed version, its fifteen human choices remain agreed, and the C1 change introduces no missing decision or evidence obligation. No further wording change is necessary for this bounded round.

This is advisory specification convergence, not consolidation approval, an implementation verdict or permission to publish the candidate.

### Human guidance response for feature-request sqlite-runtime-upgrade round 5

Human guidance:

The current request records the user's authorization, verbatim: "Run round 5, C1 only" (2026-10-28).

Guidance response:

I limited this round to C1 and its direct consistency with Q07 G1 and the Step 5 records. I did not reopen any settled choice, request new execution, or expand release work into feature/design/plan work. C1 is closed, so convergence is recommended without another correction round.

### Writer instructions for feature-request sqlite-runtime-upgrade round 5

No further correction is requested within the authorized C1-only round. Preserve the umbrella's amended loader clause and the existing pending item status.

Present the convergence recommendation to the owning workflow. Consolidation, commit, integration return, publication and adoption retain their existing authorization gates. If consolidation is authorized, use the recorded human decisions, including Q05 E2, and the already reviewed requirement-to-decision wording updates. This review introduces no new feature, design, plan, build, inventory or test work.

### Final reviewer decision for feature-request sqlite-runtime-upgrade round 5

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-5 -->

## Round 5 by human - human-confirmation

- Recorded: 2026-10-28T11:41:35+01:00
- Exchange: specification/feature-request/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-5 -->
