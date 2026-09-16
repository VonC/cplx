# Specification review transcript for v0.27.0

- Exchange: specification/design-specification/v0.27.0/python-sqlite-support
- Reviewed document: docs/v0.27.0/design.v0.27.0.python-sqlite-support.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-15T15:25:07+02:00
- Exchange: specification/design-specification/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for design-specification python-sqlite-support (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.python-sqlite-support.md
Review round: 1

### Requestor assessment for design-specification python-sqlite-support (round 1)

The design preserves the seven confirmed requirement choices. Four open
questions cover the actual architectural recommendations: declared build-family
identity, a tool-owned post-install callback, same-process provider observation,
and a shared probe with explicit caller inputs. Each has alternatives, tradeoffs
and a proposed answer awaiting human confirmation. No additional design question
is currently identified; please assess missing choices and the sufficiency of
the options and proposed answers.

The source review established configure/compile reuse, forced cleanup through
the existing reconfigure control, installed-prefix reuse based on a library
timestamp, and promotion only after the driver completes. The design separates
source and installed checks and does not promise transactional rollback.

Please examine whether declared family metadata reliably selects the approved
scope, whether the proposed callback covers all success paths, and whether
provider matching is conclusive for the shipped versioned backing file. Also
check that probe sharing does not change the operator's invocation or introduce
a host Python dependency. Closure declaration changes require envelope renewal
and verification of the actual candidate version layout.

No reviewer wording suggestions exist for this design round. The plain Debian
runtime host and copy route are still unconfirmed operational prerequisites;
the design does not claim acceptance has run or item 6 is complete.

### Change summary for design-specification python-sqlite-support (round 1)

Created the design beside the settled requirement, using the existing docs
layout. Documented the build flow, target scope, sandbox configure inputs,
source and installed capability checks, explicit rebuild, database/provider
evidence, closure identity, validation candidate and item 7 handoff.

Added Q01-Q04 with oqm. The explicit-file Markdown check passed. No build scripts,
payload selections, closure configuration or runtime environments were changed.

### Writer response for design-specification python-sqlite-support (round 1)

Writer response:

This is the first design review round. Recommendations are A1, B1, C1 and D1;
none is represented as human-approved. Requirement Q01-Q07 and umbrella D5/D7
remain authoritative. Assess architecture here; file-by-file tasks and exact
implementation commands belong to the later plan.

Use repository-relative paths in authored review text so tracked evidence
does not expose local account paths. The preceding requirement transcript was
sanitized and committed under explicit user authorization; this request does
not propose changing review substance or bypassing sensitive-content checks.

### Reviewer focus for design-specification python-sqlite-support (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `C:/Users/vonc/git/cplx/.reviews/a.review-active.specification.design-specification.v0.27.0.python-sqlite-support.md`
- `C:/Users/vonc/git/cplx/.reviews/a.review-requested.design-specification.v0.27.0.python-sqlite-support.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-15T15:30:35+02:00
- Exchange: specification/design-specification/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification python-sqlite-support round 1

The design follows the confirmed requirement (AC1-AC11, Q01-Q07) and states its
source facts accurately. The reviewer confirmed:

- the `install` driver's `CPLX_CONFIG_DONE` evaluation, `--reconfigure` forcing
  `clean()`, and the configure, clean, build, install, package order with
  `current` advanced only after `main` succeeds;
- `install()`'s `-nt` skip on the `CPLX_CHECK_PREFIX` file (`libpython3.so`);
- `CPLX_ARCH_EXT` persisted by `setup.sh`, read by the remote `.env`, and set to
  `el9.x86_64` in `tools/senv.local.tpl`;
- `closure-config.txt` holding `subdir|python|python-3.13.9`, the SQLite floor
  and the item 6 waiver.

The four questions are real architectural choices, and the reviewer agrees with
A1, B1, C1 and D1. Two design decisions are missing, however, and one closure
point is left open where the sources already determine the answer.

#### Missing decision: where the non-release candidate archive is assembled for design-specification python-sqlite-support (round 1)

The flow jumps from "installed capability check" to "existing packaging and
closure checks" to an "identified non-release candidate". In the existing
tooling that step crosses the build account's live tree:

- `pkg_tools.sh` packages the live `$HOME/tools` tree, and it refuses a
  caller-supplied `--source-root` ("the packaging source is owned by this
  script").
- Getting the new build into `$HOME/tools` means `rsync.sh`, which reads
  `~/cplx/tools/python/current`, syncs with `--delete` and removes every other
  `python-*` version directory from the live tree (wiki: "Promote a build into
  the live tree").

A validation candidate built this way therefore replaces the operator's live
Python and deletes whichever version the live tree held before item 7 has made
any release decision. This review did not inspect the live tree's current
version. The RHEL
"deployed" acceptance raises the same question for the receiving deployment
account.

The design must choose and state the candidate's assembly and deployment
boundary. Item 5's approved Q07 B precedent was an isolated sibling target with
preservation evidence.

#### Missing decision: build-stage checks run under the driver's library path for design-specification python-sqlite-support (round 1)

`install_functions.sh` exports
`LD_LIBRARY_PATH=${root}/usr/lib64:...` (and `LD_RUN_PATH`) for the whole
build. A source or installed check run inside the driver will therefore find
the sandbox `libsqlite3.so.0` through that variable, whatever the extension's
own runtime path says. The design's "no library-path overrides absent from the
operator's normal invocation" rule is written for acceptance.

The design should say plainly that build-stage provider results only prove
build capability under the driver environment, and that runtime-path
correctness is established only by the operator-invocation acceptance probe.
Otherwise D1's "one set of pass rules" can be read as the build stage proving
more than it does.

#### Closure layout and declaration ownership are left open for design-specification python-sqlite-support (round 1)

The design says to "verify the candidate's actual version layout" and record
"any required declaration adjustment". The layout is predictable: the tracked
pin is 3.13.15, so the driver prefix and promoted version directory are
`python-3.13.15`, while the declaration names only `python-3.13.9`. That record
does not match the candidate, and the design should say how it changes.

`src/setups/env/closure/README.md` also sets ownership: "A later requirement may
add, change or remove an entry only by saying so in its own document".
`python-sqlite-support` is authorized only to remove the waiver. A subdirectory
change therefore needs a matching requirement statement (or an explicit
assignment to item 7), not only a design note.

#### Wording points for design-specification python-sqlite-support (round 1)

- **Q01 "missing or inconsistent identity".** A missing `CPLX_ARCH_EXT` already
  fails before the build (`setup.sh` fatal 57, `.env` fatal 18, `package()`
  fatal 28), so that branch is already covered. "Inconsistent" has no second
  source to compare against under A1. Define what counts as inconsistent (for
  example a value outside the declared family set) or drop the word.
- **Debian container contents.** The design says the container "holds the
  candidate and verification material", while requirement AC11 says "holding
  only the candidate archive". State that the probe is verification material
  carrying no library, so the two statements are compatible.

### Question verdicts for design-specification python-sqlite-support round 1

#### Q01 verdict for design-specification python-sqlite-support (round 1)

Agree with A1. `CPLX_ARCH_EXT` is already required, persisted and read on the
server, and it names the archive family; a second host classifier would compete
with it.

Suggested replacement for A1's con: "Relies on the operator-declared family, so
a wrong declaration scopes the build wrongly; the existing presence fatals cover
a missing value, and acceptance evidence must show the actual build host."
Drop "inconsistent" unless the design defines it.

#### Q02 verdict for design-specification python-sqlite-support (round 1)

Agree with B1. The callback runs after `install()` returns success, including
its timestamp skip path, and before `package()`. That covers every success path
the driver has today, since `deploy` is reached only after `package`.

Suggested addition to B1: "The callback's nonzero result is returned by `main`
like any other stage, so `current` is not advanced."

#### Q03 verdict for design-specification python-sqlite-support (round 1)

Agree with C1. `/proc/self/maps` shows the kernel-resolved backing path, which
handles the versioned basename. It is available in the Debian container even
though that container reports the RHEL host kernel.

Suggested precision: canonicalize the caller-supplied expected root before the
containment comparison, so a legitimate symlinked deployment root is not
misread as an escape.

#### Q04 verdict for design-specification python-sqlite-support (round 1)

Agree with D1, subject to the build-stage library-path caveat in the assessment.

Suggested addition to D1's con: "Build-stage callers run under the driver's
exported `LD_LIBRARY_PATH`, so their provider result proves build capability
only; runtime-path correctness comes from acceptance under the operator
invocation."

#### Missing Q05: where the validation candidate is assembled and deployed for design-specification python-sqlite-support (round 1)

Add a question. Existing packaging reads the live `$HOME/tools` tree and forbids
a caller source root, and promotion deletes other Python versions from that
tree.

- **H1:** promote the candidate into the build account's live tree and deploy
  it to a real deployment account, recording the previous versions for
  restoration.
  - pro: uses the existing flow unchanged.
  - con: replaces the operator's live Python and a deployment account's tools
    with a non-release build, and `--delete` removes the restore source.
- **H2:** assemble and deploy the candidate in an isolated account home or
  sibling target that mirrors the layout, with before/after preservation
  evidence for the live trees, as item 5's Q07 B did.
  - pro: no operator-visible change before item 7.
  - con: must confirm that `rsync.sh`, `pkg_tools.sh` and deployment honour the
    isolated `HOME` without weakening `pkg_tools.sh`'s owned-source rule.
- **H3:** add a staging-source packaging mode.
  - pro: explicit.
  - con: reverses the deliberate refusal of caller source roots, which is a
    closure-contract change outside item 6.

The reviewer would choose H2. It matches the approved isolation precedent and
keeps item 6 from changing live tools ahead of item 7's release decision.

#### Missing Q06: who owns the Python closure subdirectory change for design-specification python-sqlite-support (round 1)

Add a question, or a settled statement with a requirement amendment. The
3.13.15 candidate layout makes `subdir|python|python-3.13.9` stale.

- **J1:** item 6 updates the record to the candidate version and the
  requirement states that change.
  - pro: the candidate's closure check describes its real layout.
  - con: a requirement amendment is needed.
- **J2:** replace the version-specific record with the declared `current` alone,
  if the checker's scope allows it, stated in the requirement.
  - pro: no per-version churn.
  - con: must be proven equivalent against the closure contract.
- **J3:** leave the record to item 7.
  - pro: no item 6 declaration change.
  - con: the item 6 candidate cannot pass closure against its real layout.

The reviewer would choose J1 unless J2 is proven equivalent; either way the
requirement must say so, per the closure README ownership rule.

### Requested changes for design-specification python-sqlite-support round 1

Requested changes:

- Add the missing decision on where the non-release candidate is assembled and
  deployed, given that packaging reads the live `$HOME/tools` tree and promotion
  deletes other Python versions.
- Decide the stale `subdir|python|python-3.13.9` closure record and flag the
  requirement statement the closure ownership rule requires.
- State that build-stage checks run under the driver's `LD_LIBRARY_PATH` and
  prove build capability only, and adjust Q04 D1 accordingly.
- Apply the Q01, Q02, Q03 and AC11 container wording refinements.

### Writer instructions for design-specification python-sqlite-support round 1

1. Add a design question on the candidate's assembly and deployment boundary
   (options H1-H3 in the verdicts). Cite `pkg_tools.sh`'s live `$HOME/tools`
   source and owned-source refusal, and `rsync.sh`'s `--delete` of other
   `python-*` versions. Recommend and keep the answer pending confirmation.
2. Add a question or settled statement on the stale `subdir|python|python-3.13.9`
   record (options J1-J3). Note that the closure README requires the owning
   requirement to state any entry change beyond waiver removal. Flag the
   requirement amendment it implies, and do not edit the requirement in this
   design round.
3. State that build-stage source and installed checks run under the driver's
   exported `LD_LIBRARY_PATH`, prove build capability only, and leave
   runtime-path proof to operator-invocation acceptance. Adjust Q04 D1 to match.
4. Apply the wording points:
   - Q01: define or remove "inconsistent" identity, and cite the existing
     presence fatals;
   - Q02: note that a callback failure prevents `current` advancement;
   - Q03: canonicalize the expected root;
   - reconcile "candidate and verification material" with AC11's "holding only
     the candidate archive".
5. Keep file-by-file tasks for the plan, and do not consolidate. Publish the
   next round.

### Final reviewer decision for design-specification python-sqlite-support round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-15T16:57:30+02:00
- Exchange: specification/design-specification/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for design-specification python-sqlite-support (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.python-sqlite-support.md
Review round: 2

### Requestor assessment for design-specification python-sqlite-support (round 2)

Accepted the round 1 findings. Six design questions now cover target identity,
post-install validation, provider observation, shared probe inputs, isolated
candidate assembly/deployment, and the closure declaration's version shape.
The options and proposed answers are sufficient in the writer's assessment;
no further design choice is currently identified. Recommendations remain
pending human confirmation.

The isolation boundary covers the complete account layout and packaging
metadata, not only the payload directory. It must be proven before promotion or
deployment, with live-tree preservation evidence. This is a design prerequisite,
not a claim that rebinding HOME alone has been demonstrated to work.

The requirement amendment required by closure ownership is explicitly flagged
before implementation. The settled requirement was not edited in this design
round. Q06 asks the architectural choice of exact replacement versus retaining
both version entries; it does not re-ask approved capability or release scope.

All suggested wording refinements were applied, including the build-environment
limit on provider results. The explicit-file Markdown check passed.

### Change summary for design-specification python-sqlite-support (round 2)

Added Q05 recommending H2: complete isolated assembly and RHEL deployment
layouts, with preservation evidence and no fallback to live replacement.
Documented rsync.sh deletion behavior and pkg_tools.sh's owned source, private
stage and account-local output boundary.

Added Q06 recommending J1: replace the 3.13.9 version declaration with 3.13.15,
retain root/current, and flag the owning requirement amendment and envelope
renewal. Documented that current alone does not cover the observed version
directory under the existing checker.

Clarified that build checks inherit the driver's library path and establish
build capability only; operator-invocation acceptance establishes runtime-path
correctness. Refined Q01's declared-identity trust and existing missing-value
failures, Q02's failure propagation, Q03's expected-root canonicalization, and
the Debian probe's status as verification material carrying no library.

### Writer response for design-specification python-sqlite-support (round 2)

Writer response:

Accepted the substantive review findings and all covered wording suggestions.
The assembly and deployment boundary was missing and is now explicit. The
observed source supports the owned-source refusal, account-local metadata and
version deletion concerns. The isolated-target precedent is item 5 plan Q07 B.

For the closure choice, source inspection confirms that observed immediate
version directories must be declared. Consequently, current-only and deferral
cannot meet the existing contract for this candidate. Q06 instead offers exact
replacement (J1) or retaining the historical declaration while adding the new
one (J2); J1 is recommended for the narrower candidate shape. This refines the
alternative set without disagreement on the review finding. A matching owning
requirement statement remains a prerequisite, and no requirement edit has been
made in this round.

Please review the amended choices and confirm whether the design can be
presented for human consolidation. No consolidation, live operation or code
change has been performed.

### Reviewer focus for design-specification python-sqlite-support (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-15T16:59:35+02:00
- Exchange: specification/design-specification/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification python-sqlite-support round 2

The reviewer reread the full design. Every round 1 point is resolved:

- **Candidate assembly and deployment (new Q05).** The confirmed facts table now
  records `pkg_tools.sh`'s live `$HOME/tools` source and owned-source refusal,
  and `rsync.sh`'s `--delete` of other version directories. H2 isolates the
  complete layout (cplx tree, tools, package outputs, environment metadata),
  requires the boundary to be proven before promotion or deployment, keeps
  live-tree preservation evidence, and blocks rather than falls back to live
  replacement. H3 is correctly rejected as a packaging-contract change outside
  item 6.
- **Closure version record (new Q06).** The writer's source claim holds:
  `closure_check.sh` states that the declared input is "a subdirectory list, not
  a version list" and that an undeclared root or subdirectory is UNEXPECTED and
  unwaivable. So `current` alone cannot cover `python-3.13.15`, and dropping the
  reviewer's round 1 option J2 (current-only) and J3 (deferral) is justified.
  The replacement pair, exact replacement versus keeping both versions, is the
  real remaining choice. The requirement amendment demanded by the closure
  README is flagged as a prerequisite and not silently applied.
- **Build-stage library path.** The capability section and Q04 D1 now state that
  build checks inherit the driver's `LD_LIBRARY_PATH` and `LD_RUN_PATH` and
  prove build capability only. Runtime-path correctness is left to
  operator-invocation acceptance.
- **Wording.** Q01 now describes trusting the declared family, with the existing
  missing-value failures. Q02 states that a callback failure prevents `current`
  advancement. Q03 canonicalizes the expected root. The Debian probe is called
  verification material carrying no library, consistent with AC11.

No material design choice is missing. The requirement amendment for the
version record can only follow human confirmation of Q06, so it belongs to
consolidation rather than another design round. The remaining suggestions are
wording-only.

### Question verdicts for design-specification python-sqlite-support round 2

#### Q01 verdict for design-specification python-sqlite-support (round 2)

Agree with A1 as revised.

#### Q02 verdict for design-specification python-sqlite-support (round 2)

Agree with B1. The added propagation sentence closes the round 1 point.

#### Q03 verdict for design-specification python-sqlite-support (round 2)

Agree with C1 with canonicalized expected roots.

#### Q04 verdict for design-specification python-sqlite-support (round 2)

Agree with D1. The build-capability-only limit is now in both the design body
and the option.

#### Q05 verdict for design-specification python-sqlite-support (round 2)

Agree with H2.

Wording-only suggestion for H2's con: "`rsync.sh` and `pkg_tools.sh` derive
every path from `$HOME`, so the isolated layout must also keep the account's
login-profile chain from writing into the live tree, as item 5 audited before
its isolated run."

#### Q06 verdict for design-specification python-sqlite-support (round 2)

Agree with J1.

Wording-only suggestion for J1's con: "Once the declaration names only
`python-3.13.15`, a tree still holding `python-3.13.9` is refused as
UNEXPECTED. After the waiver removal that tree already fails on its missing
SQLite floor member, so this adds no new refusal to live-tree packaging."

### Convergence evidence for design-specification python-sqlite-support round 2

Covered wording:

- Q05, Option H2 con, append: "`rsync.sh` and `pkg_tools.sh` derive every path
  from `$HOME`, so the isolated layout must also keep the account's login-profile
  chain from writing into the live tree, as item 5 audited before its isolated
  run."
- Q06, Option J1 con, append: "Once the declaration names only `python-3.13.15`,
  a tree still holding `python-3.13.9` is refused as UNEXPECTED. After the waiver
  removal that tree already fails on its missing SQLite floor member, so this
  adds no new refusal to live-tree packaging."
- "SQLite provider and database acceptance evidence": re-wrap "A copy under
  another tool, an escaped symlink or a host path fails." as one line of prose.

Convergence rationale:

Every in-scope architectural decision is now a question with source-backed facts,
distinct options and a pending recommendation the reviewer agrees with:

- policy identity (Q01);
- installed-check placement (Q02);
- provider observer (Q03);
- probe sharing with its build-stage limit (Q04);
- isolated candidate assembly and deployment (Q05);
- closure version record (Q06).

The round 1 findings are resolved, and the reviewer verified the writer's
closure-checker claim in `closure_check.sh`. The only cross-document follow-up,
the requirement statement for the version record, depends on confirming Q06 and
is flagged for consolidation. The remaining edits are optional wording. This
recommendation is advisory and does not authorize consolidation.

### Writer instructions for design-specification python-sqlite-support round 2

1. Optionally apply the two wording-only suggestions in the Q05 and Q06 verdicts,
   and re-wrap the broken line in "SQLite provider and database acceptance
   evidence" ("A copy under another tool, an escaped / symlink").
2. Present the six pending recommendations (A1, B1, C1, D1, H2, J1) for human
   confirmation.
3. At consolidation, if J1 is confirmed, amend the owning requirement so it
   states the `subdir|python|python-3.13.9` to `python-3.13.15` replacement
   alongside the waiver removal, as the closure README ownership rule requires,
   before the plan relies on it.
4. Do not treat this recommendation as authorization to consolidate.

### Final reviewer decision for design-specification python-sqlite-support round 2

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human - human-confirmation

- Recorded: 2026-09-15T17:12:14+02:00
- Exchange: specification/design-specification/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
