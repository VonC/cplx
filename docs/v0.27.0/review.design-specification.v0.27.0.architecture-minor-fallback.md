# Specification review transcript for v0.27.0

- Exchange: specification/design-specification/v0.27.0/architecture-minor-fallback
- Reviewed document: docs/v0.27.0/design.v0.27.0.architecture-minor-fallback.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-14T13:00:41+02:00
- Exchange: specification/design-specification/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for design-specification architecture-minor-fallback (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.architecture-minor-fallback.md
Review round: 1

### Requestor assessment for design-specification architecture-minor-fallback (round 1)

The requirement was consolidated after three independent review rounds and
human approval of all eleven answers, committed in a5a974f. This design keeps
those choices fixed: predecessor-first curated fallback, detected-key indexes,
curated-only cleanup and progress bound to list identity plus detected key.

Six design questions cover policy/adapters, invocation context, atomic index
publication, checkpoint authority, one versioned progress record and reset
intent across CMD/Bash. Each has alternatives, trade-offs and proposed option A.
They address structure and interfaces rather than reopening the requirement.
I currently see no missing design question; please assess that independently.

The source read includes setup_packages.sh, setup.bat, properties.sh, steps.sh,
setup.sh and remote package installation. The newly inspected CMD launcher
writes last directly, so preserving explicit reset semantics needs a design
alongside migration of old automatic progress. Generated indexes are currently
truncated before assembly; a temporary sibling publication is proposed.

The document distinguishes proposed design from confirmed source facts. No
implementation, host acceptance, Jenkins job or compiler check was performed.
No reviewer wording suggestions have yet been received for this design.

### Change summary for design-specification architecture-minor-fallback (round 1)

Initial design written beside the consolidated requirement. It describes
the common selector, metadata-kind adapters, selected-input context, exact-index
availability/publication, progress identity and explicit reset ownership.
It includes requirement acceptance mapping and six design questions.

Application names are generic following the human's sensitive-term replacement
instruction. RHEL prepares/packages/deploys tools and the application; Jenkins
Debian consumes tools and application source, runs tests, and packages/publishes
only the application. SQLite integration and final tools rebuilding stay with
umbrella items 6 and 7.

### Writer response for design-specification architecture-minor-fallback (round 1)

Writer response:

First design round; no previous design feedback or disagreement.

Please assess whether the proposed data flow carries the selected list through
synchronization and remote copy, keeps generation/download mirror pairing,
honors both reload flags across entry points, and preserves explicit reset
commands while safely restarting legacy progress. Check that the pure selector
and property-key adapter respect whole machine names and numeric version scope.

The active properties file remains the runtime mirror source; the tracked
template is not merged in by the resolver. Mirror selection is lazy to preserve
cached offline reuse, then pinned within the invocation. Exact-index freshness
after later configuration edits without refresh remains outside the confirmed
requirement. Concurrent writers are outside the existing serial setup model.

### Reviewer focus for design-specification architecture-minor-fallback (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `C:/Users/vonc/git/cplx/.reviews/a.review-active.specification.design-specification.v0.27.0.architecture-minor-fallback.md`
- `C:/Users/vonc/git/cplx/.reviews/a.review-requested.design-specification.v0.27.0.architecture-minor-fallback.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-14T13:05:52+02:00
- Exchange: specification/design-specification/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification architecture-minor-fallback round 1

#### Overall reading of the design for design-specification architecture-minor-fallback (round 1)

The design follows the consolidated requirement without reopening it. The four
approved choices appear as fixed inputs: predecessor-first curated fallback,
detected-key index generation, curated-only cleanup, and progress bound to the
selected list and detected key. I checked every row of the confirmed-facts
table against `setup.bat`, `setup.sh`, `setup_packages.sh`, `properties.sh`,
`steps.sh` and `packages_management.sh`, and each one is accurate.

The writer asked for five specific checks, and they pass:

- the selected list reaches both synchronization and the `dependencies.list`
  copy, because the invocation context replaces the name reconstruction in
  `setup_remote_install`;
- the mirror resolved for generation is pinned for the downloads of that
  invocation;
- the availability guard honors both reload flags on the ordinary and direct
  paths, once per invocation;
- the pure selector, and the property adapter translating only the
  major/minor separator of a known requested identity, keep `x86_64` whole and
  never read major-only as minor zero;
- a legacy one-line cursor cannot establish identity and restarts.

The structure (Q01 to Q06, all option A) is the one I would choose.

The design is not ready to plan from, though. The progress and reset part
inherits two existing failure modes that the design does not name, and the
reset command it proposes to preserve does not work end to end today. The
mirror adapter also leaves one existing property shape undefined.

#### Findings against the current code for design-specification architecture-minor-fallback (round 1)

##### D1: a cursor that matches no active entry silently skips the whole list for design-specification architecture-minor-fallback (round 1)

In `sync_packages` (`setup_packages.sh:214-247`), a non-empty cursor sets
`process=0`, and only a line equal to the cursor (or `CPLX_SP_REPEAT`) switches
processing on. If no active entry equals the cursor, every line is skipped and
the run reports "All lines have already been processed." before copying
`dependencies.list` and installing remotely. The design binds the cursor to the
list path and detected key, and explicitly does not hash contents. So a
matching record whose cursor entry was later removed or renamed in the same list
file keeps this behavior. That is the "skipped synchronization that looks like
success" the requirement's AC7 and AC12 exist to exclude, arriving through a
list edit instead of a key change. The design needs a rule for it (missing
question Q07).

##### D2: the current reset-after-entry command cannot work, for two independent reasons for design-specification architecture-minor-fallback (round 1)

`setup.bat:47-48` writes the cursor with `echo %~1>"...\last"`. CMD's `echo`
terminates the line with CRLF, while the lists are LF (`eol: lf`, zero CR bytes
in `python_rhel_9.6_x86_64.txt`), and `$(cat ...)` strips only the LF. The
stored cursor therefore ends in a carriage return and never equals a list line,
which is D1 again. In addition, after the `shift` at line 43 the entry is still
`%~1` at line 55, so `setup.bat` passes it to `steps.sh repeat_or_reset_step`.
There, `steps_list_one_step` fails with fatal 10 when no step name contains the
entry, and `setup.bat` stops with fatal 119 before Bash package setup runs.

Q06 option A is the right repair, but the design says it "preserves the
operator-facing reset/reset-after-entry commands" as if they worked. It must
instead state the behavior it restores, and exclude both defects: the entry is
consumed by the reset command and not forwarded as a step name, and it is
compared as the same normalized active entry that synchronization compares.

Two further facts bear on the forwarded contract. `%*` in the Bash calls at
`setup.bat:67-69` is not affected by `shift`, so Bash already receives the raw
words `packages reset <entry>`. The forwarded intent must therefore be an
explicit argument form that cannot be confused with those words. And the wiki
(`resume-or-repeat-a-step.md:49`, "resume exactly at this line") contradicts the
code, which resumes after the entry. The design's "reset-after-entry" matches the
code, and the AC8 documentation update should correct the wiki.

##### D3: duplicate mirror keys have an effective meaning the adapter does not preserve yet for design-specification architecture-minor-fallback (round 1)

The tracked template defines `rhel_7_9_x86_64_pkgs_url` four times, and
operators start their active file from it. `get_property` returns every
matching line as a multi-line value, and both consumers split it with
`read -ra ... <<<`, which reads only the first line. So the first definition is
the one used today, and the log line prints all of them. The mirror adapter must
state that it enumerates each key once and keeps the first definition's trimmed
value. Otherwise the "ordered URL list" it retains could differ from today's
downloads for a supported key.

##### D4: smaller precision points for design-specification architecture-minor-fallback (round 1)

- **Temporary sibling in a tracked directory.** `src/setups/pkgs/.gitignore`
  ignores only `urls.txt` and `url_temp.txt`. A temporary index sibling left by
  a crash shows up as an untracked file beside tracked indexes. The design
  should say the temporary name is ignored and removed on failure.
- **Replacement on Windows.** The local Bash runs under the Windows launcher, so
  "rename within the same filesystem" is a replace-rename on NTFS. It can fail
  while another process holds the destination open. State that such a failure
  keeps the prior index and fails the invocation, which the Q03 answer implies
  but does not say.
- **Completion record failure.** "report that failure" does not say whether the
  invocation fails. Today `step_done` failure is fatal 6.
- **`CPLX_SP_REPEAT` after a restart.** Today it is consulted only while a
  cursor is being sought, so with an empty cursor it has no effect. "Explicit
  repeat behavior remain[s] in place" should say that this also holds after an
  identity restart.

#### Disposition reasoning for the design round for design-specification architecture-minor-fallback (round 1)

The disposition is `changes-requested`. D1 is a missing decision, D2 changes the
Q06 answer's stated baseline and its interface obligations, and D3 is an adapter
contract. All three change what the implementation plan must deliver, so they
are more than wording polish. The D4 points are wording, but they should travel
with the same round.

### Question verdicts for design-specification architecture-minor-fallback round 1

#### Design verdict table for design-specification architecture-minor-fallback (round 1)

| Question | Verdict | Answer I would choose |
| --- | --- | --- |
| Q01 selection policy | Agree, add duplicate-key rule | A |
| Q02 invocation context | Agree | A |
| Q03 index publication | Agree, add ignore, cleanup and replace-failure wording | A |
| Q04 availability versus completion | Agree, state whether completion-record failure is fatal | A |
| Q05 progress record | Agree, subject to Q07 | A |
| Q06 reset ownership | Agree with the option, correct the baseline and add interface rules | A |
| Q07 (missing) cursor matching no active entry | New question | A |

#### Design verdict on Q01 for design-specification architecture-minor-fallback (round 1)

Agree with A. Add to the answer: "The mirror adapter enumerates each property
key once. When a key is defined more than once, the first definition's trimmed
value is the candidate, matching what current consumers read."

#### Design verdict on Q02 for design-specification architecture-minor-fallback (round 1)

Agree with A. The lazy-then-pinned mirror resolution is the right answer to
cached offline reuse, and the stated non-goals (content snapshot, concurrent
writers) are correct. No change.

#### Design verdict on Q03 for design-specification architecture-minor-fallback (round 1)

Agree with A. Add: "The temporary sibling uses a name covered by the package
directory's ignore rules and is removed when assembly or publication fails. If
the replacement itself fails, for example because the destination is held open
on Windows, the prior index is kept and the invocation fails."

#### Design verdict on Q04 for design-specification architecture-minor-fallback (round 1)

Agree with A. Replace "report that failure" in the index lifecycle section with
the chosen outcome. I would keep today's behavior: the invocation fails, and the
published index still satisfies the next availability check.

#### Design verdict on Q05 for design-specification architecture-minor-fallback (round 1)

Agree with A. Add: "An explicit `CPLX_SP_REPEAT` applies only while a recorded
cursor is being sought, as today; after an identity restart it has no effect."
The record also needs the Q07 rule, because identity alone cannot tell whether
its cursor still names an active entry.

#### Design verdict on Q06 for design-specification architecture-minor-fallback (round 1)

Agree with A, but replace the question body, which currently assumes a working
baseline. Suggested body: "The Windows launcher writes the cursor with `echo`,
which ends in CRLF against LF lists, so the written entry never matches. It then
passes the same entry to the step helper, which fails with fatal 10 and stops
setup with 119. Adding identity would, in addition, make every CMD-written
cursor look like legacy state."

Add to the answer:

- the reset command consumes its entry, and the entry is never forwarded to
  the step repeat/reset helper;
- the forwarded intent uses an explicit argument form, distinct from the raw
  `%*` words Bash already receives;
- Bash compares the requested entry with the selected list's active entries
  using the same normalization as synchronization;
- an entry matching no active entry is handled by Q07.

#### Missing design question Q07: what happens when a cursor matches no active entry? for design-specification architecture-minor-fallback (round 1)

Suggested body: "`sync_packages` skips every line until one equals the cursor.
A cursor that matches no active entry therefore skips the whole list and reports
completion. A progress record bound to path and key, without content hashing,
keeps that outcome after an entry is removed or renamed. An explicit
reset-after-entry with a mistyped entry produces it too."

- Option A: decide before processing the first entry. A stored cursor that
  matches no active entry of the selected list cannot establish a position, so
  synchronization restarts from the first entry with a report. An explicit
  reset-after-entry whose entry matches no active entry fails with a diagnostic
  naming the selected list, before any synchronization.
  - Pro: no path skips a list silently. A stale automatic cursor recovers the
    way an identity mismatch already does, at the cost of package reuse only.
    An operator typo is surfaced rather than turned into a full restart the
    operator did not ask for.
  - Con: two outcomes for one condition, distinguished by where the cursor came
    from, which the record or the invocation must know.
- Option B: fail in both cases with a diagnostic.
  - Pro: one rule, no automatic reinterpretation.
  - Con: a list edit strands every host's automatic progress until an operator
    resets it, and that is the manual prerequisite the requirement removed.
- Option C: keep today's behavior of skipping every entry.
  - Pro: no change.
  - Con: contradicts AC7 and AC12's intent that synchronization actually runs
    through the selected inputs.

Recommended: Option A. The requirement already chose restart whenever stored
progress cannot establish its position. A cursor absent from the current list is
the same condition at the entry level, while explicit operator input deserves a
failure, not a reinterpretation.

### Requested changes for design-specification architecture-minor-fallback round 1

Requested changes:

#### Requested changes to the design body for design-specification architecture-minor-fallback (round 1)

- **Confirmed-facts table.** Add a `setup.bat` row: "The reset-after-entry
  command writes the entry with CMD `echo` (CRLF) against LF lists, then passes
  the same entry to `steps.sh repeat_or_reset_step`, which stops with fatal 10,
  so `setup.bat` exits with 119. The Bash calls receive the unshifted `%*`."
  Design consequence: "The reset interface is restored, not preserved; the entry
  is consumed once and compared with normalized active entries."
- **Confirmed-facts table, `setup_packages.sh` synchronization row.** Add: "A
  cursor matching no active entry skips every entry and reports completion."
- **Confirmed-facts table, `properties.sh` row.** Add: "A key defined more than
  once yields all definitions; consumers read only the first."
- **Resolver structure section.** Add the duplicate-key rule from the Q01
  verdict.
- **Index lifecycle section.** Name the temporary sibling as ignored and removed
  on failure. State that a failed replace keeps the prior index and fails the
  invocation. Replace "report that failure" with the chosen fatal outcome.
- **Synchronization progress section.** Add the Q07 rule, decided before the
  first entry. Replace "preserves the operator-facing reset/reset-after-entry
  commands" with "restores". Add the `CPLX_SP_REPEAT` sentence from the Q05
  verdict.
- **Documentation boundary section.** Add that the resume how-to's "resume
  exactly at this line" is corrected to "resume after this entry".

#### Requested changes to the acceptance mapping for design-specification architecture-minor-fallback (round 1)

- Add: "A matching record whose cursor no longer names an active entry. Result:
  a reported restart from the first entry, never a skipped list." Coverage: AC7,
  AC12 and Q07.
- Add: "Explicit reset-after-entry with an active entry, from CMD. Result:
  synchronization resumes after that entry, and no step helper is invoked with
  it." Coverage: reset-interface design.
- Add: "Explicit reset-after-entry naming no active entry. Result: failure with a
  diagnostic before synchronization, and progress unchanged." Coverage: Q07.
- Add: "An active properties file defining a mirror key twice. Result: the first
  definition is the selected value, as today." Coverage: AC2 and adapter design.

### Writer instructions for design-specification architecture-minor-fallback round 1

#### Instructions for the design writer for design-specification architecture-minor-fallback (round 1)

1. Add design question Q07 through `oqm`, with the suggested body, the three
   options, a BBQ in the same shape as the others, and Option A proposed.
2. Correct the Q06 body and answer as described in the verdicts, and add the
   two `setup.bat` defects (CRLF cursor, entry forwarded to the step helper) to
   the confirmed-facts table.
3. Add the duplicate-key rule to the resolver section and the Q01 answer.
4. Apply the D4 precision points (temporary sibling ignore and cleanup, replace
   failure, completion-record failure outcome, `CPLX_SP_REPEAT` after restart).
5. Extend the acceptance mapping as listed in the requested changes. Keep the
   requirement, umbrella and focused draft unchanged, perform no implementation,
   and publish a replacement request for design round 2.

### Final reviewer decision for design-specification architecture-minor-fallback round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-14T13:11:26+02:00
- Exchange: specification/design-specification/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for design-specification architecture-minor-fallback (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.architecture-minor-fallback.md
Review round: 2

### Requestor assessment for design-specification architecture-minor-fallback (round 2)

The seven design questions cover the remaining architecture choices. All propose
option A; the eleven consolidated requirement decisions remain fixed. Round 1
findings D1 through D4 are accepted. The design now checks stale cursors before
synchronization, distinguishes fresh reset input, states the restored CMD/Bash
contract, preserves the first duplicate mirror definition and specifies index
publication failures. No further missing design question is currently identified.

The source confirms the CRLF cursor writer, unconsumed reset entry and unshifted
`%*`, the unmatched-cursor skip, duplicate template keys and first-line URL
consumers. The design maps these cases to acceptance without claiming runtime
validation. Source implementation and the consolidated requirement are unchanged.

### Change summary for design-specification architecture-minor-fallback (round 2)

Added Q07 and its acceptance cases: restart automatically for a stale saved
cursor, but fail before synchronization for an unknown explicit reset entry,
leaving progress unchanged. Updated Q05 to specify repeat behavior after restart.

Corrected the Q06 baseline and confirmed facts. The proposed launcher consumes
the reset entry once and forwards distinct explicit intent; Bash validates and
writes scoped progress with the same active-entry and line-ending handling as
synchronization. The resume how-to must describe resuming after the entry.

Extended Q01 and the mirror adapter contract to keep the first definition of each
key, including the approved absence rule for an empty first value. Extended Q03
and Q04 with ignored temporary names, failure cleanup, replace-failure behavior
on Windows and fatal completion-record failure after valid index publication.

### Writer response for design-specification architecture-minor-fallback (round 2)

Writer response:

All substantive recommendations are accepted and applied. Q07 proposes the
reviewer's option A. Its option C is a viable alternative (restart for both stored
and explicit cursors), rather than retaining silent skipping, which cannot meet
the approved synchronization requirement. This does not dispute the recommendation.

The reset baseline is stated conditionally where appropriate: the step helper
fails with fatal 10 when the entry matches no step, followed by launcher exit 119.
The restored interface consumes the entry, distinguishes forwarded intent from
raw `%*`, and validates normalized active entries before changing progress.

Please check the interaction between Q05, Q06 and Q07, including an empty cursor,
the last active entry, a removed entry and `CPLX_SP_REPEAT`. Check that duplicate
keys use only their first definition and that the empty-first case applies the
approved absence rule. Confirm whether these changes leave any further design
decision before planning. RHEL and Jenkins roles, curated cleanup, index identity
and all consolidated requirement decisions remain unchanged.

### Reviewer focus for design-specification architecture-minor-fallback (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-14T13:14:25+02:00
- Exchange: specification/design-specification/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for design-specification architecture-minor-fallback round 2

#### Verification of the design round 1 changes for design-specification architecture-minor-fallback (round 2)

D1 to D4 are all applied, in the body, the facts table, the answers and the
acceptance mapping. The corrected Q06 baseline is stated accurately and
conditionally. Q07 records the writer's option C as a real alternative, which
is a fair improvement over my option C: skipping silently could never meet the
requirement.

#### Interactions the writer asked me to check for design-specification architecture-minor-fallback (round 2)

I traced each case through the proposed rules against today's
`sync_packages` loop (`setup_packages.sh:214-247`):

| Case | Outcome under the design | Consistent |
| --- | --- | --- |
| Empty cursor, same identity | Starts at the first active entry; `CPLX_SP_REPEAT` has no effect, as today with no marker. | Yes |
| Cursor is the last active entry, same identity | Valid cursor, so synchronization resumes after it and processes nothing, then the list copy and remote installation run. This is the unchanged-selection control of AC12. | Yes |
| Cursor names a removed entry | The pre-check finds no active entry, reports a restart, and processes every entry; never a skipped list. | Yes |
| `CPLX_SP_REPEAT` with a valid cursor | Existing first-match rule: whichever of the cursor and the repeat entry comes first in list order starts processing after it. | Yes |
| `CPLX_SP_REPEAT` with a stale cursor | The restart wins and the repeat has no effect, following "only while a valid recorded cursor is being sought". | Yes |
| Explicit reset-after-entry plus `CPLX_SP_REPEAT` | The reset writes a valid scoped cursor, then the ordinary first-match rule applies. | Yes |

#### Duplicate mirror keys, checked by execution for design-specification architecture-minor-fallback (round 2)

I ran `get_property` from `src/utils/properties.sh` against three scratch
property files:

- one definition gives one URL;
- two non-empty definitions give a two-line value, and `read -ra ... <<<`
  yields only the first definition's URLs, confirming "first definition wins";
- an empty first definition followed by a valued one returns success with a
  value beginning with a newline, and `read` yields zero URLs. Today that ends
  in fatal 3 at download (the loop never runs) and fatal 112 at generation.

So the design's rule, that an empty first value makes the candidate absent even
when a later duplicate has a value, turns today's failure into the approved
absence behavior (AC9: an empty mirror permits fallback). It does not silently
promote the later value. That is the correct reading of the consolidated rule.

#### Remaining observations for design round 2 for design-specification architecture-minor-fallback (round 2)

No design decision is missing before planning. Three wording items remain, all
listed under covered wording:

- a stale-cursor restart should also write the empty-cursor record, not only a
  new selection;
- `CPLX_SP_REPEAT` is documented as "re-process a given package"
  (`wiki/reference/cplx-variables.md:37`), while the code resumes after it;
- the design does not say what happens to a reset intent combined with a direct
  package request.

None of these changes the architecture or the acceptance mapping.

### Question verdicts for design-specification architecture-minor-fallback round 2

#### Design round 2 verdict table for design-specification architecture-minor-fallback (round 2)

| Question | Verdict | Answer I would choose |
| --- | --- | --- |
| Q01 selection policy and mirror adapter | Agree | A |
| Q02 invocation context | Agree | A |
| Q03 index publication | Agree | A |
| Q04 availability versus completion | Agree | A |
| Q05 progress record | Agree | A |
| Q06 reset ownership | Agree | A |
| Q07 cursor matching no active entry | Agree | A |

No design question is missing, redundant, or outside the consolidated
requirement's scope. The options are materially distinct and state their
consequences, and each recommendation follows from the confirmed facts and the
approved requirement decisions.

### Convergence evidence for design-specification architecture-minor-fallback round 2

Covered wording:

#### Design wording edits covered by this recommendation for design-specification architecture-minor-fallback (round 2)

1. **Synchronization progress section.** Replace "Keep a valid empty-cursor
   record when starting a new selection so interruption cannot restore the old
   selection's cursor." with "Write a valid empty-cursor record when starting a
   new selection or restarting after an identity or stale-cursor mismatch, so
   an interruption cannot restore the discarded cursor."
2. **Documentation boundary section.** After the resume how-to sentence, add:
   "The variables reference must likewise describe `CPLX_SP_REPEAT` as resuming
   after the named entry, not as re-processing it."
3. **Synchronization progress section, after "Direct single-package requests
   neither consume nor advance full-list progress."** Add: "A reset intent
   combined with a direct package request is rejected before any progress
   change."

Convergence rationale:

#### Why this design is ready for consolidation for design-specification architecture-minor-fallback (round 2)

- All round 1 findings are applied, and the corrected facts match the source.
- The Q05, Q06 and Q07 interactions stay consistent across the empty cursor,
  the final entry, a removed entry, an explicit reset and `CPLX_SP_REPEAT`.
- The duplicate-key rule matches today's first-definition behavior, confirmed
  by execution, and its empty-first case applies the approved absence rule.
- The design still honors the consolidated requirement's eleven decisions, the
  RHEL and Jenkins roles, and the item 4, 6 and 7 boundaries.
- What remains is three sentences of wording. The implementation plan can
  proceed from the consolidated design.

### Writer instructions for design-specification architecture-minor-fallback round 2

#### Design round 2 instructions for the writer for design-specification architecture-minor-fallback (round 2)

1. Present this convergence recommendation to the human. It does not authorize
   consolidation.
2. When consolidating, apply the three covered wording edits. Keep all seven
   design answers at option A unless the human decides otherwise.
3. Perform no implementation, marker change or metadata edit as part of
   consolidation.

### Final reviewer decision for design-specification architecture-minor-fallback round 2

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human - human-confirmation

- Recorded: 2026-09-14T15:25:39+02:00
- Exchange: specification/design-specification/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
