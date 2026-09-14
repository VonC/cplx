# Specification review transcript for v0.27.0

- Exchange: specification/feature-request/v0.27.0/architecture-minor-fallback
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-14T10:49:31+02:00
- Exchange: specification/feature-request/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for feature-request architecture-minor-fallback (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
Review round: 1

### Requestor assessment for feature-request architecture-minor-fallback (round 1)

The requirement derives from the focused item 5 draft, umbrella decision D9,
the architecture wiki and the user's clarified environment roles. It preserves
exact precedence, a logged fallback within distribution/major/machine, all three
named metadata kinds, and the detected server identity. Item 4 is complete;
item 5 improves upstream inputs without depending technically on its checker.

Nine questions address the remaining behavior and acceptance choices: numeric
distance and ties; mixed metadata minors; no candidate; unusable exact inputs;
major-only versions; generated-index refresh identity; evidence for duplicate
removal; new-tool seeds; and package/download errors after selection. No other
material requirement question is currently identified. Please identify any
missing observable behavior without moving into implementation design.

Each question has alternatives, pros and cons, a recommended answer and an
acceptance reason. These answers are expressly proposals, not user decisions.
The options are sufficient for an initial independent review. Q06 is the main
tradeoff to examine: generating under the detected key preserves shared indexes
and exact mirror overrides, but permits additional generated files while the
feature eliminates mandatory manual copies of curated metadata. Q07 must not
equate identical mirror URLs with identical dependency or index contents.

This is the first round; no reviewer wording suggestions have yet been received
or applied. The requirement body was written before the separate question
review. It does not claim implementation or new RHEL/Jenkins acceptance.

### Change summary for feature-request architecture-minor-fallback (round 1)

Created the v0.27.0 architecture-minor-fallback feature request beside its
canonical focused draft. It documents the operator need, current three exact
lookups, D9 behavior, eight acceptance criteria, item 4/5/6/7 boundaries and
RHEL versus Jenkins responsibilities. Added nine independently considered
feature questions through oqm, with proposed answers.

No implementation, metadata deletion, wiki rewrite, staging or commit was
performed. The umbrella and focused draft are unchanged by requirement writing.

### Writer response for feature-request architecture-minor-fallback (round 1)

Writer response:

Please assess this requirement and its proposed answers against the exact
focused draft and umbrella. The user explicitly states that RHEL is both the
development packaging environment for tools and application and the deployment
environment for their archives. Jenkins Debian consumes tools, checks out the
private my-project application from source and tests it; its application job
packages and publishes application only to Nexus. There is no compilation, tools build
or tools publication on Jenkins. These roles are confirmed context, not choices
to reopen in review.

The request is a specification review only. Runtime closure acceptance already
belongs to completed item 4. Python SQLite integration and the final tools
refresh/rebuild remain items 6 and 7. Do not turn this item into another archive
acceptance effort or a compiler exercise on Debian.

There is no preceding reviewer disagreement. Recommendations in the question
answer lines are proposed for review and need the normal human consolidation
decision after convergence.

### Reviewer focus for feature-request architecture-minor-fallback (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `C:/Users/vonc/git/cplx/.reviews/a.review-active.specification.feature-request.v0.27.0.architecture-minor-fallback.md`
- `C:/Users/vonc/git/cplx/.reviews/a.review-requested.feature-request.v0.27.0.architecture-minor-fallback.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-14T11:13:15+02:00
- Exchange: specification/feature-request/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for feature-request architecture-minor-fallback round 1

#### Overall reading of the requirement for feature-request architecture-minor-fallback (round 1)

The requirement is faithful to the focused draft and to D9, keeps the RHEL and
Jenkins roles as confirmed context, and stays out of implementation design. The
nine questions are well posed, their options are materially distinct, and six of
the nine proposed answers are the ones I would choose.

Implementation cannot proceed from the current answers, though. Checking the
metadata the requirement is about, and the code that consumes it, turned up
repository evidence that the requirement does not record. That evidence
contradicts three of its premises and changes three recommended answers. None of
it reopens D9's direction (exact match first, then a logged closest-minor
fallback). It does bear on how D9 applies to the generated package index.

#### Evidence the requirement does not yet carry for feature-request architecture-minor-fallback (round 1)

##### E1: cross-minor index reuse already caused a silent defect for feature-request architecture-minor-fallback (round 1)

Commit `18c251d` (2026-08-24, "move the package key to rhel 9.8") records why
the 9.8 index had to be generated: while the key still named 9.6, "the package
pipeline therefore resolved 9.6-era packages onto a 9.8 server, which is how the
sandbox came to hold a binutils whose libraries the upgraded system no longer
carried". The 9.6 index dates from 2025-07-21 (`af5f50c`). In other words, the
exact situation that index fallback would create on purpose (a 9.8 server
reading an older minor's index snapshot) has already produced an incoherent
sandbox. The setup reported success, and the failure only showed later. That
postdates D9 (2026-08-07) and is the main input to Q06.

##### E2: the 9.6 and 9.8 python lists are not duplicates for feature-request architecture-minor-fallback (round 1)

`git diff --no-index` over the two lists shows exactly one difference: the 9.6
list carries `zlib-dev` (added by `b1c7b16`), and `18c251d` corrected it to
`zlib-devel` in the 9.8 list only, noting that it "resolved to nothing and would
stop the list at its third line". `zlib-dev-[0-9]` matches zero lines in both
generated indexes, while `zlib-devel-1.2.11-41.el9.x86_64.rpm` is present in both.
So the documented AC1 and AC7 scenario (a 9.8 server resolving the 9.6 python
list) fails today with fatal 301 at line 3, whatever the resolver does. The two
git lists are byte-identical. The 9.6 and 9.8 mirror properties have identical
values, both in the tracked `setup.tpl.properties` and in the local
`setup.properties`. The two generated indexes differ by about 2400 lines
(235025 against 239558 bytes).

##### E3: the index lookup creates the exact file it failed to find for feature-request architecture-minor-fallback (round 1)

`find_package_in_arch` (`src/setups/setup_packages.sh:305-311`) runs `touch` on
`packages_<arch>.txt` when that file is absent, then fails with 301 because the
empty file matches nothing. After one such run an empty
`packages_rhel_9.8_x86_64.txt` exists. Under "exact definition wins" and the Q04
answer ("fall back only for absence"), that empty file would then mask every
fallback candidate permanently. The generator never legitimately writes an empty
index: `download_packages_list` stops with fatal 112 when no URL yields packages.

##### E4: index generation is gated by a completion marker that is not keyed by architecture for feature-request architecture-minor-fallback (round 1)

`download_packages_list` returns early when the `download_packages_list` step is
marked done in `src/setups/steps.md`, which is tracked and currently reads
`(done: ✅)`. The marker does not record which key it was done for. Only
`CPLX_FORCE_RELOAD_PACKAGES` bypasses it. So the Q06 answer "generate under the
detected key when no index exists" is not what happens today after a minor
upgrade: generation is skipped, and E3 follows.

##### E5: an empty property value and an absent key are indistinguishable today for feature-request architecture-minor-fallback (round 1)

`get_property` (`src/utils/properties.sh:10-21`) returns 1 and an empty variable
in both cases, and `download_package` reports the empty case as
`Property '...' not found` (fatal 7). The Q04 recommendation ("an invalid empty
mirror value remains an error under its consumer's contract") therefore
describes a distinction the existing contract does not make. For index
generation, an absent or empty property produces no URL at all and ends in the
misleading fatal 112 "No packages were found from any of the URLs".

##### E6: new-tool creation never reads the detected key for feature-request architecture-minor-fallback (round 1)

`tools/add_tool.bat:317-318` seeds only `<tool>_centos_8_x86_64.txt` and
`<tool>_rhel_7.9_x86_64.txt`, from the hard-coded `minimal_centos_8_x86_64.txt`
and `minimal_rhel_7.9_x86_64.txt`. No `minimal_rhel_9.*` seed exists. Q08's
premise, that new-tool creation "could encounter the same naming issue", is
therefore inaccurate. New-tool creation produces no RHEL 9 list at all, whether
or not fallback exists, so fallback cannot affect it. Option A remains right,
but for this reason.

##### E7: the first failure for a missing per-tool list is fatal 9, not 902 for feature-request architecture-minor-fallback (round 1)

In the regular flow `sync_packages` (`setup_packages.sh:203-206`) stops with
fatal 9 (`File '...' not found`) before `install_packages` reaches the
`dependencies.list` copy that fails with 902. The umbrella's "fatals 902" and
the current-behavior table inherit an imprecision that an acceptance test keyed
on the exit code would expose.

#### Assessment of scope and roles for feature-request architecture-minor-fallback (round 1)

The environment table and the item 4, 6 and 7 boundaries are correct and need no
change. Nothing in this review asks for Debian compilation, a Jenkins pipeline
run, or archive acceptance. All the evidence above was read from the repository
on the authoring host.

#### Disposition reasoning for feature-request architecture-minor-fallback (round 1)

The disposition is `changes-requested`. The following are all more than wording
polish: E1 changes the Q06 answer and needs a human decision on how D9 applies
to the index; E2 invalidates the AC1 and AC7 real-host scenario and creates a
missing decision about which file set survives; E3, E4 and E5 change the Q04 and
Q06 answer text; and Q01 has a missing option that I would choose over the
proposed one.

### Question verdicts for feature-request architecture-minor-fallback round 1

#### Summary of question verdicts for feature-request architecture-minor-fallback (round 1)

| Question | Verdict | Answer I would choose |
| --- | --- | --- |
| Q01 | Missing option | New option D: highest eligible minor not above the server, else the lowest above it |
| Q02 | Agree, conditional on Q06 | A |
| Q03 | Agree, add diagnostic content | A |
| Q04 | Agree in principle, answer text contradicts the code | A, with absence defined per metadata kind |
| Q05 | Agree, add candidate symmetry | A |
| Q06 | Disagree on the evidence of commit `18c251d` | New option C: no cross-minor index reuse; generate for the detected key |
| Q07 | Agree, must be applied to the actual files | A, plus new Q10 |
| Q08 | Agree, premise is inaccurate | A, for the corrected reason |
| Q09 | Agree | A |
| Q10 (missing) | New question | A: correct the 9.6 python list, then remove the 9.8 curated copies |

#### Verdict on Q01: closest minor for feature-request architecture-minor-fallback (round 1)

The question is necessary and the integer comparison is right. The options miss
the rule I would choose, which also makes the tie question disappear.

Proposed Option D: among eligible candidates, take the highest minor not greater
than the requested minor. When none exists, take the lowest minor greater than
it. Compare minors as integers.

- Pro: an exact-minor definition exists, once fallback lands, only because that
  minor diverged, and a divergence introduced at 9.10 does not apply to a 9.9
  server. Upgrades move forward, so the older definition describes the state
  the server grew out of. The order is total, so no tie rule is needed. A server
  older than every definition still resolves.
- Con: a numerically nearer newer candidate (9.9 for a 9.8 server when 9.6
  exists) loses to the older one. This reads "closest" as closest in upgrade
  history rather than as absolute distance, which the human should confirm
  against D9's wording.

Option A's own example shows what goes wrong: it would give a 9.8 server the 9.9
definition, the one definition that most likely records a change 9.8 never
received. Replacement answer: "Option D. A 9.8 request selects 9.6 over 9.9 and
9.10; a 9.5 request with only 9.6 and 9.10 present selects 9.6. Minors compare
as integers, so 9.10 is never read as 9.1."

#### Verdict on Q02: mixed minors for feature-request architecture-minor-fallback (round 1)

Agree with A. Keep it, but the rationale must name its dependency on Q06.
Downloads fetch filenames listed in the index from the URLs of the mirror
property. If the index is read from one key and the property is resolved for
another, and the two properties differ, the filenames can be missing from the
mirrors used. The option C answer I recommend for Q06 makes the index and its
download mirrors come from the same resolution, so the pairing holds by
construction. If Q06 keeps index reuse, add to this answer: "a package resolved
from a fallback index is downloaded from the mirror definition resolved for that
index's key".

#### Verdict on Q03: no eligible candidate for feature-request architecture-minor-fallback (round 1)

Agree with A. Add to the answer that the diagnostic names the requested key, the
metadata kind, the eligibility boundary (distribution, major, machine) and the
candidates considered, or states that none was eligible. For index generation, a
missing mirror definition must be diagnosed as missing before any fetch. Today it
surfaces as fatal 112, "No packages were found from any of the URLs", which
blames the mirrors rather than the configuration.

#### Verdict on Q04: unusable exact definitions for feature-request architecture-minor-fallback (round 1)

Agree with the principle of Option A. The answer text states a distinction the
code does not have, and it omits the one case that would break exact precedence
in practice. Replace the recommended-option paragraph with:

"Option A. Absence is defined per metadata kind and introduces no content
validation beyond it:

- a per-tool list is absent when its file does not exist; a present list,
  including one holding only comments, stays authoritative;
- a package index is absent when its file does not exist or has zero length,
  since the generator never writes an empty index;
- a mirror definition is absent when its key is missing or its value is empty,
  which is how the existing property reader already treats both.

No lookup may create a metadata file under any key as a side effect of not
finding one."

The last sentence covers `find_package_in_arch`, which today runs `touch` on the
missing exact index and would otherwise leave a file that masks every fallback.

#### Verdict on Q05: keys without a numeric minor for feature-request architecture-minor-fallback (round 1)

Agree with A. Add two sentences to the answer. First: "A major-only candidate is
never eligible for a major.minor request, and a major.minor candidate is never
eligible for a major-only request." Second, for AC3: "Distribution and machine
compare as whole components; the machine `x86_64` itself contains an
underscore, so no prefix or suffix match may decide eligibility."

#### Verdict on Q06: generated index identity for feature-request architecture-minor-fallback (round 1)

Disagree with the proposed Option A, on evidence the question does not cite.
Commit `18c251d` records that a 9.8 server resolving packages from the 9.6 index
(generated 2025-07-21) produced a sandbox holding a binutils whose libraries the
upgraded system no longer carried, with no setup failure. Option A's "reuse an
eligible existing index for normal reads" reproduces that situation on purpose
at every minor upgrade, and Q09 correctly prevents any later correction. A
generated index is a dated snapshot of rolling mirrors. It is stale in
proportion to its age, and the older minor's index is by construction older
than the upgrade.

Two further facts affect both options as written. Generation is skipped today
whenever the `download_packages_list` marker in the tracked
`src/setups/steps.md` reads done, and that marker records no key. And the lookup creates an empty exact index
when none exists (see Q04). "Generate when no index exists" is therefore a new
behavior to require, not a description of today's behavior.

Proposed Option C: "The package index takes no cross-minor fallback. When the
exact index for the detected key is absent, it is generated under that key from
the mirror definition resolved for that key (exact or fallback), whatever a
completion marker recorded for an earlier run. An explicit refresh
(`CPLX_RELOAD_PACKAGES` or `CPLX_FORCE_RELOAD_PACKAGES`) also writes under the
detected key. A generation failure stops with its diagnostic."

- Pro: a minor upgrade is exactly the event at which the snapshot must be
  refreshed, and C turns it into an automatic regeneration instead of a manual
  copy. The index and its download mirrors come from one resolution (Q02).
  The incident of `18c251d` cannot recur through fallback.
- Con: this narrows D9's application. Fallback then covers the per-tool list and
  the mirror definition, not the index. The first package run after an upgrade
  needs mirror access, and one generated index per minor accumulates as a
  tracked file to commit.

I would choose C. Because it changes one of the three lookups D9's item text
names, record it as a D9 application decision for the human at consolidation,
not as a silent rewording. If the human keeps index reuse (A), the requirement
must at least: record the `18c251d` incident; report the selected index's key
prominently; add the Q02 pairing sentence; and state the marker and empty-file
behaviors above, since otherwise "generate when absent" never happens.

#### Verdict on Q07: evidence for removal for feature-request architecture-minor-fallback (round 1)

Agree with A as the rule. Apply it in the requirement to the files that actually
exist, because the umbrella's "duplicated `rhel_9.8` copies" is only partly
true:

- `git/git_rhel_9.8_x86_64.txt`: identical to 9.6, removable;
- `rhel_9_8_x86_64_pkgs_url`: identical value in `setup.tpl.properties`,
  removable from the template (the local `setup.properties` is ignored and
  belongs to each operator, so the item cannot remove it there; a leftover local
  key is an identical exact definition and harmless);
- `python/python_rhel_9.8_x86_64.txt`: differs, carrying the `zlib-devel`
  correction the 9.6 list lacks, so it is not removable as it stands (see Q10);
- `packages_rhel_9.8_x86_64.txt`: generated and different, outside curated
  removal whatever Q06 decides.

#### Verdict on Q08: new-tool seed lists for feature-request architecture-minor-fallback (round 1)

Agree with A, but replace the premise. `tools/add_tool.bat:317-318` never reads
the detected key: it seeds `centos_8_x86_64` and `rhel_7.9_x86_64` lists from
hard-coded seed names, and no `minimal_rhel_9.*` seed exists. Replace the
question body's last sentence with: "New-tool creation does not read the
detected key; it seeds only CentOS 8 and RHEL 7.9 lists, so a new tool has no
RHEL 9 list with or without fallback." Replace the recommended reason with:
"Option A. Fallback cannot affect an operation that never looks up the detected
key. The missing RHEL 9 seed is a separate, pre-existing gap to record as a
follow-up." Keep the sentence about downloaded-package directories, and add that
the local download cache `pkgs/<arch>/` stays keyed by the detected key and the
remote `tools/pkgs/` stays unkeyed.

#### Verdict on Q09: package-content and download failures for feature-request architecture-minor-fallback (round 1)

Agree with A, no change needed. Optional precision: replace "configured-mirror
retry" with "the existing ordered retry across the URLs of the selected mirror
definition, the last URL being fatal".

#### Missing question Q10: which curated set survives the duplicate removal for feature-request architecture-minor-fallback (round 1)

The requirement needs this decision before AC7 can be accepted, because the
python lists differ (Q07) and the 9.6 one is the defective one.

- Option A: correct `zlib-dev` to `zlib-devel` in the 9.6 python list, then
  remove the now-identical 9.8 python and git lists and the 9.8 key from
  `setup.tpl.properties`. Generated indexes stay outside this removal.
  - Pro: AC1, AC5 and AC7 keep their 9.8-to-9.6 shape, and the real RHEL 9.8
    host exercises list and mirror fallback rather than only fixtures. The
    correction targets a curated file; Q07 forbids hand-editing generated ones.
  - Con: the surviving curated files carry an older minor label than any server
    in use.
- Option B: keep the 9.8 curated set and remove the superseded 9.6 set.
  - Pro: the survivors carry the corrected content and the newest label.
  - Con: the 9.8 host takes exact lookups, so fallback is exercised only by
    fixtures until a 9.9 server exists; AC1, AC5 and AC7 need rewriting; a 9.6
    host would need upward selection (Q01).
- Option C: remove nothing in this item.
  - Pro: no deletion risk.
  - Con: leaves the churn D9 exists to remove and misses the umbrella's stated
    outcome.

Recommended: Option A. It keeps the scenario the requirement is written around
executable on the real build host, and it fixes a defect that would otherwise
make that scenario fail at line 3 whatever the resolver does.

### Requested changes for feature-request architecture-minor-fallback round 1

Requested changes:

#### Requested changes to the requirement body for feature-request architecture-minor-fallback (round 1)

- **Current behavior table, per-tool list row.** Replace the consequence with:
  "Synchronization stops with fatal 9 (`File '...' not found`) before any copy;
  the later copy to the server as `dependencies.list` would fail with fatal
  902."
- **Current behavior table, package index row.** Add: "The lookup then creates
  an empty file under the exact name and fails with fatal 301; generation is
  skipped whenever the `download_packages_list` step is already marked done,
  whatever key it was done for."
- **Current behavior table, mirror property row.** Add: "An absent key and an
  empty value are read identically; generation then ends in fatal 112 and
  download in fatal 7 ('not found')."
- **After the table.** Replace "The RHEL 9.6 and 9.8 definitions use the same
  rolling CentOS 9 Stream mirrors. Their duplicated names..." with a statement
  per file: the git lists and mirror values are identical; the python lists
  differ by the `zlib-dev` to `zlib-devel` correction made in `18c251d`, the
  9.6 entry resolving to nothing; the generated indexes differ.
- **New paragraph in the revision section.** Record the `18c251d` incident: a
  9.8 server resolving packages from the 2025-07-21 9.6 index produced a sandbox
  whose binutils needed libraries the upgraded system no longer carried, without
  a setup failure.
- **Expected selection, step 2.** Replace "closest available minor" with the
  Q01 rule the writer adopts, stated once here and referenced from AC4.
- **Expected selection, step 4.** If Q06 option C is adopted, restrict fallback
  to the per-tool list and the mirror definition, and add a step: "an absent
  exact package index is generated under the detected key from the mirror
  definition resolved for that key, whatever a completion marker recorded for
  an earlier run."
- **Expected selection, step 6.** Replace with the Q10 outcome: name the files
  removed and the file corrected, and state that generated indexes are outside
  curated removal.
- **New expected-selection step.** "No lookup creates a metadata file under any
  key as a side effect of not finding one."

#### Requested changes to the acceptance criteria for feature-request architecture-minor-fallback (round 1)

- **AC1.** Under Q06 option C: "only 9.6 dependency lists and mirror
  definition, and no index for either minor, are available" resolves the list
  and mirror by fallback, reports both, and generates
  `packages_rhel_9.8_x86_64.txt`. Add the precondition that the 9.6 python list
  is the corrected one, or state that the scenario uses a fixture list.
- **AC4.** Replace "the precise ordering and tie policy must be settled" with
  the adopted Q01 rule and one worked example (9.8 request with 9.6, 9.9 and
  9.10 present).
- **AC6.** Add: "a lookup that finds nothing leaves no new file under the exact
  name, and a run following it still resolves by fallback."
- **New AC9.** "An exact definition present in the form Q04 calls absent (a
  zero-length index, an empty mirror value) does not block fallback or
  generation; a present per-tool list holding only comments does."
- **New AC10, only under Q06 option C.** "With a 9.6 index present and no 9.8
  index, a 9.8 server generates and uses a 9.8 index rather than reading the 9.6
  one, even when the generation step is already marked done."
- **AC7.** Tie the scenario to Q10: after the chosen correction and removal,
  the RHEL 9.8 host completes package setup for python and git. The run output
  shows the fallback selections, and the `zlib-devel` entry resolves.

#### Requested changes to the boundary and references for feature-request architecture-minor-fallback (round 1)

- Add `tools/add_tool.bat` to the references, with the Q08 finding that it
  seeds only CentOS 8 and RHEL 7.9 lists. Record the missing RHEL 9 seed as an
  out-of-scope follow-up.
- Add `src/setups/steps.md` and `src/utils/properties.sh` to the references for
  the marker and property-reading behaviors.
- Add `setup.tpl.properties` to the references. Its comment "One key per minor is
  needed until cplx falls..." belongs to the AC8 documentation update.
- Note for consolidation that the umbrella's "fatals 902 when the file is
  missing" and "leaving one file per major" need the corrections above.

### Writer instructions for feature-request architecture-minor-fallback round 1

#### Instructions for the writer for feature-request architecture-minor-fallback (round 1)

1. Revise the requirement body before the questions. Record the new evidence
   (the commit `18c251d` incident, the `zlib-dev` defect in the 9.6 python list,
   the lookup-created empty index, the architecture-independent generation
   marker, the empty-or-absent property contract, fatal 9 before 902) where it
   bears on current behavior. Keep it as evidence, not implementation design.
2. Rework Q01, Q04, Q06 and Q08, and extend Q02, Q03, Q05 and Q07, using the
   replacement wording in the question verdicts. Where you disagree, answer the
   stated evidence explicitly rather than keeping the prior text.
3. Add Q10 (which curated set survives the duplicate removal) through `oqm`,
   with its options, recommendation and BBQ in the same shape as the others.
4. Present Q06 option C as a decision on how D9 applies to the package index,
   so the human decides it knowingly at consolidation. If you keep option A as
   the recommendation, carry the four mandatory additions listed in the Q06
   verdict.
5. Align the acceptance criteria with whatever Q06 and Q10 recommend (see the
   requested changes). Do not modify the umbrella or the focused draft in this
   round; list any umbrella wording that later needs correcting ("fatals 902",
   "one file per major") under the requirement's own boundary section, for
   consolidation.
6. Do not perform the correction or deletion of any metadata file, and do not
   start implementation. Publish a replacement request for round 2.

### Final reviewer decision for feature-request architecture-minor-fallback round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-14T11:31:48+02:00
- Exchange: specification/feature-request/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for feature-request architecture-minor-fallback (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
Review round: 2

### Requestor assessment for feature-request architecture-minor-fallback (round 2)

The round 1 changes are supported by repository evidence and have been applied
to the requirement and its proposed answers. I verified commit 18c251d, the
Python zlib-dev/zlib-devel difference, identical Git lists, different generated
index contents, identical tracked mirror values, the generation completion
marker and reload behavior, empty index creation, property-reader semantics,
fatal 9 versus 902, and the hard-coded new-tool seeds. I agree with the findings.

The ten questions now cover the identified observable behavior and acceptance
choices. Q01 proposes predecessor-first numeric ordering (option D); Q06 adds
detected-key index generation without cross-minor snapshot reuse (option C);
Q10 proposes correcting the 9.6 Python list before removing identical curated
9.8 definitions (option A). These options and their consequences are explicit
proposals requiring the human's decision. The body and eleven acceptance
criteria have been aligned with them rather than leaving contradictory rules.

No further material requirement question is currently identified. Alternatives
remain available with pros, cons and acceptance rationale. Q02 distinguishes
independent list/mirror selection from the generation/download mirror pairing;
Q04 differentiates absence by input kind; Q05 states symmetric major-only
exclusion; Q07 requires content evidence and excludes generated snapshots and
ignored operator properties; Q08 corrects the seed premise and records the
pre-existing seed gap separately. Q09 retains ordinary failures after selection.

The main D9 tradeoff is deliberately not declared confirmed: Q06 narrows the
umbrella's original all-three-kinds fallback wording in light of the recorded
runtime regression, while permitting one generated index per detected minor.
Q01 refines closest-minor ordering and Q10 fixes the real-list acceptance
precondition. Pending consolidation must reconcile the umbrella and focused
draft; this review round leaves them unchanged. Please assess readiness for
that explicit human decision, not treat the proposals as already approved.

### Change summary for feature-request architecture-minor-fallback (round 2)

Added the 18c251d stale-index incident and the actual curated-file differences
to the requirement. Corrected the missing-list failure path, index placeholder
and completion-marker behavior, empty mirror semantics, and new-tool seeds.

Revised Q01 to recommend D and Q06 to recommend the new C. Added Q10 with a
targeted zlib-devel correction and evidence-based curated cleanup. Reworked
Q02-Q08 as requested; retained Q09's existing URL retries and ordinary errors.
Recreated and appended the full ten-question companion with oqm.

Aligned the proposed behavior and AC1-AC11 with numeric predecessor-first
selection, per-kind absence, exact detected-key index generation, both refresh
flags bypassing completion markers, consistent generation/download mirrors,
no lookup placeholders, actionable failures, corrected real-host prerequisites,
and retained exact-minor overrides. Explicitly marked the D9 refinements as
pending human consolidation. Added the supporting code references and the
separate RHEL 9 seed follow-up.

Validation checked the cited repository behavior and the requirement's
whitespace. No implementation, package metadata removal, operator configuration
change, RHEL/Jenkins execution, staging or commit was performed.

### Writer response for feature-request architecture-minor-fallback (round 2)

Writer response:

All round 1 findings are accepted; there is no substantive disagreement.

R1/Q01: adopted proposed option D, retaining its alternatives and making its
refinement of D9 explicit. Both older-first and all-newer examples are in AC4.

R1/Q02-Q03: kept independent curated list and mirror selection, bound generation
and corresponding downloads to the same resolved mirrors, and specified the
requested-key/kind/boundary/candidates diagnostic. The index-reuse alternative
also explains that its mirror resolution would have to follow the selected
index key. Missing mirrors are diagnosed before fetching.

R1/Q04-Q05: defined absence separately for lists, indexes and mirror values,
retained present empty/comment-only list semantics and ordinary invalid-input
errors, removed lookup placeholder creation, and made numeric-minor fallback
and whole distribution/machine boundaries explicit in both directions.

R1/Q06: accepted the new proposed option C based on 18c251d. Missing or empty
detected-key indexes require generation despite completion markers; either
reload flag forces regeneration. Generation failure remains a failure, and no
other minor's snapshot is reused. Existing nonempty exact indexes retain their
ordinary reuse behavior; the requirement does not promise freshness after an
operator changes mirror configuration without requesting a refresh.

R1/Q07 and new Q10: verified the identical Git lists and tracked mirror values,
the zlib spelling difference in Python, and the distinct generated indexes.
Proposed correcting the surviving 9.6 Python list before deleting identical
9.8 curated definitions. AC7 states the real-host precondition and excludes an
overriding local 9.8 mirror key in that acceptance environment. Ignored operator
properties and generated snapshots are not cleanup targets.

R1/Q08-Q09 and scope: corrected the seed premise, recorded the RHEL 9 seed gap
as follow-up, distinguished the detected-key local download cache from the
unkeyed remote directory, and retained existing URL retries and final errors.
RHEL packaging/deployment and Jenkins application-only publication remain confirmed.
Items 4, 6 and 7 retain their existing ownership boundaries.

The requirement now records the consolidation work needed for the umbrella's
fatal 902 explanation, one-file-per-major wording and index fallback scope.
Neither the umbrella nor the focused draft was changed during this round.

### Reviewer focus for feature-request architecture-minor-fallback (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-14T11:36:37+02:00
- Exchange: specification/feature-request/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for feature-request architecture-minor-fallback round 2

#### Verification of the round 1 changes for feature-request architecture-minor-fallback (round 2)

Every round 1 finding is applied, and applied accurately. I re-read the whole
requirement against the code and found:

- the current-behavior table now matches `setup_packages.sh` (fatal 9 before
  902, the placeholder index and 301, the architecture-independent marker, and
  fatal 112 against fatal 7);
- the file comparison paragraph matches the repository (identical Git lists and
  template mirror values, the `zlib-dev` defect, different generated indexes);
- Q01 D, Q06 C and Q10 A are presented as proposals for the human, and their
  refinement of D9 is stated in the revision section, the proposed selection,
  and the boundary section;
- the proposed selection steps, AC1 to AC11 and the ten answers agree with one
  another. I found no contradiction left between body and questions.

The wording of Q02 to Q09 is clear and I have no further polish to request on
them.

#### One remaining gap: synchronization resume state recorded for another list for feature-request architecture-minor-fallback (round 2)

The requirement now makes stale generation state harmless: step 3, step 4 and
AC10 require generation "regardless of an earlier completion marker". It says
nothing about the second piece of resume state that sits on the same path, and
that one stops the real-host acceptance.

`sync_packages` (`src/setups/setup_packages.sh:209-247`) reads
`pkgs/<tool>/last`, skips every list line up to and including the recorded
value, and writes each processed line back to it. The file is ignored
(`.gitignore:23`), keyed neither by architecture nor by the list file it was
recorded against, and only `CPLX_SP_REPEAT` or deleting it changes where
synchronization restarts. On the authoring host today,
`src/setups/pkgs/python/last` holds `sqlite-devel`, which is the 56th and final
active entry of the python list. The next python synchronization therefore
processes no line at all. It logs the warning "All lines have already been
processed.", and still proceeds to copy `dependencies.list` and run the remote
installation.

That installation resolves each short name against the RPMs already staged in
the remote `~/tools/pkgs` (`get_full_package_name` in
`src/setups/env/bin/packages_management.sh:356-386`, highest version wins), not
against the index. Under the proposed Q06 C and AC10, the freshly generated 9.8
index would then feed no download and no copy. The remote installation would
reuse whatever the pre-upgrade runs staged. That is the `18c251d` failure mode
again, reached through the resume marker instead of through index reuse, and
AC7 ("completes dependency setup for Python and Git ... resolves `zlib-devel`")
could pass without a single package having gone through the selected metadata.

This is not an implementation detail: it decides whether AC1, AC7 and AC10 mean
anything on a host that has run package setup before, which is every real host.
It needs a question and an acceptance statement.

#### Smaller precision: the single-package path for feature-request architecture-minor-fallback (round 2)

`main` (`setup_packages.sh:30-34`) sends `--package <name>` straight to
`sync_package` and `install_package`, without `download_packages_list`. Step 3
is worded generally, but no criterion covers that path. An implementation that
only changes the regular flow would satisfy AC1 to AC11 while the direct path
still creates the placeholder index and fails with 301. One clause in AC6 and
AC10 closes it.

#### Disposition reasoning for round 2 for feature-request architecture-minor-fallback (round 2)

The disposition is `changes-requested`, for one missing decision (Q11) and two
acceptance clauses. Everything else is ready for the human decision, so round 3
should be narrow: add Q11, align AC6, AC7 and AC10 with it, and name the
single-package path.

### Question verdicts for feature-request architecture-minor-fallback round 2

#### Round 2 verdict table for feature-request architecture-minor-fallback (round 2)

| Question | Verdict | Answer I would choose |
| --- | --- | --- |
| Q01 | Agree, as revised | D |
| Q02 | Agree, as revised | A |
| Q03 | Agree, as revised | A |
| Q04 | Agree, as revised | A |
| Q05 | Agree, as revised | A |
| Q06 | Agree, as revised | C |
| Q07 | Agree, as revised | A |
| Q08 | Agree, as revised | A |
| Q09 | Agree, as revised | A |
| Q10 | Agree, as revised | A |
| Q11 (missing) | New question | A: resume state applies only to the list it was recorded for |

#### Notes on the revised questions for feature-request architecture-minor-fallback (round 2)

Q01 to Q10 need no further change. Two optional polish points, which do not by
themselves justify a round:

- Q06 option C's Pro could name the evidence directly: "prevents the `18c251d`
  outcome from recurring through fallback".
- Q10's question body could say "resolves in neither generated index" instead of
  "resolves in neither index", matching the body's snapshot wording.

#### Missing question Q11: does synchronization resume state apply across a changed list selection? for feature-request architecture-minor-fallback (round 2)

Suggested body: "`sync_packages` resumes after the line recorded in
`pkgs/<tool>/last`, a local ignored file keyed neither by architecture nor by
list file. On the current host the python value is the list's final active
entry, so the next synchronization processes nothing while the remote
installation resolves names against previously staged RPMs. After a minor
upgrade, a fallback selection or a newly generated index would then feed no
download or copy."

- Option A: honor resume state only for the selected list file and detected key
  it was recorded against; when either differs, restart synchronization from the
  first entry and report the restart.
  - Pro: consistent with step 3, which already refuses to let a stale completion
    marker suppress work. It makes AC1, AC7 and AC10 meaningful on hosts that ran
    setup before, and prevents pre-upgrade RPMs from being installed silently
    after an upgrade.
  - Con: changes resume behavior beyond the lookup itself. A run interrupted
    across an upgrade restarts, which costs little because `scp_package` skips
    files already present remotely.
- Option B: keep the unkeyed resume state. The OS-upgrade procedure (AC8) tells
  the operator to delete `pkgs/<tool>/last`, and AC7 requires that clean state.
  - Pro: no behavior change outside metadata selection.
  - Con: leaves, on the same path, the class of trap the requirement just
    removed for generation. The only signal is a warning that reads like success.
- Option C: leave resume state out of this item and record a follow-up.
  - Pro: narrowest scope.
  - Con: AC7 on the real host then depends on an undocumented manual step, and
    its result does not show that the selected metadata was used.

Recommended: Option A. The requirement's own index rule says earlier completion
state must not decide work for a different selection. The synchronization marker
is the same kind of state, and on the current host it would otherwise empty the
real-host acceptance. If the human prefers the narrower scope, Option B is
acceptable only with the AC8 procedure step and an explicit AC7 precondition.

### Requested changes for feature-request architecture-minor-fallback round 2

Requested changes:

#### Round 2 requested changes for feature-request architecture-minor-fallback (round 2)

- **Current-behavior section.** After the marker paragraph, add: "Synchronization
  resumes after the entry recorded in the local, ignored `pkgs/<tool>/last`,
  which records neither architecture nor list file. When it holds a list's final
  entry, the next synchronization processes nothing, and the remote installation
  resolves names against RPMs staged by earlier runs."
- **Proposed selection, new step after step 4 (under Q11 option A).**
  "Synchronization resume state applies only to the selected list file and
  detected key it was recorded for. A different selection restarts
  synchronization from the first entry and reports the restart."
- **AC6.** Append: "The same lookup, absence and generation rules hold for the
  single-package (`--package`) path."
- **AC7.** Add to the scenario: "the host keeps the synchronization resume state
  left by its pre-upgrade runs". Add to the result: "every active Python and Git
  entry is synchronized through the selected list and the generated 9.8 index,
  with the restart reported."
- **AC10.** Append: "including when the operation is a single-package setup."
- **New AC12 (under Q11 option A).** "Scenario: resume state was recorded for
  `python_rhel_9.8_x86_64.txt` and the selection is now
  `python_rhel_9.6_x86_64.txt`, or the detected key changed. Result:
  synchronization restarts from the first entry and reports it. The same file
  and key still resume after the recorded entry."
- **References.** Add `packages_management.sh`: remote installation resolves
  short names against staged RPMs, highest version first.

### Writer instructions for feature-request architecture-minor-fallback round 2

#### Round 2 instructions for the writer for feature-request architecture-minor-fallback (round 2)

1. Add Q11 through `oqm`, with the suggested body, the three options, a BBQ in
   the same shape as the others, and Option A as the proposed answer for human
   consolidation.
2. Add the resume-state behavior to the current-behavior section and a proposed
   selection step matching the Q11 recommendation. Cite
   `setup_packages.sh:209-247` and `packages_management.sh:356-386` in the
   references.
3. Apply the acceptance clauses in the requested changes. Leave Q01 to Q10
   unchanged apart from the two optional polish points, which you may take or
   leave.
4. Keep the umbrella and focused draft unchanged. Perform no metadata edit, no
   deletion of `last` files, and no implementation. Publish a replacement
   request for round 3.

### Final reviewer decision for feature-request architecture-minor-fallback round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-09-14T11:40:02+02:00
- Exchange: specification/feature-request/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for feature-request architecture-minor-fallback (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
Review round: 3

### Requestor assessment for feature-request architecture-minor-fallback (round 3)

The remaining round 2 gap is supported by the code and the current ignored
Python marker. I verified the unkeyed resume logic, its final-entry skip, the
direct single-package path and remote selection from staged RPMs. The proposed
Q11 option A now binds resume applicability to the selected list file and
detected key and restarts when either changes. Legacy markers cannot establish
that match, so the proposal explicitly restarts them as well.

All eleven questions have alternatives, pros, cons and proposed answers. Q01
through Q10 are unchanged. Q11 supplies the missing observable state behavior;
AC6, AC7, AC10 and new AC12 now cover the identified paths. I identify no other
material question needed for this requirement and consider the choices
sufficient for human consolidation, subject to the independent assessment.

All requested round 2 wording changes have been applied. The optional Q06 and
Q10 polish was left unchanged because their existing wording is accurate.
The requirement still labels Q01, Q06, Q10 and Q11 as proposals, preserves the
confirmed RHEL/Jenkins and item 4/6/7 boundaries, and leaves umbrella alignment
to consolidation. There is no substantive disagreement.

### Change summary for feature-request architecture-minor-fallback (round 3)

Added current behavior for the unkeyed synchronization marker, the current
Python final-entry marker and remote staged-RPM selection. Documented that
single-package setup bypasses regular index generation.

Added Q11 through oqm with the three requested alternatives and proposed A.
Specified restart on a changed selected list or detected key, including legacy
markers without identity, while retaining resume for an unchanged selection.
Added this proposed behavior to the body and made its pending-human status
explicit alongside the earlier D9 application decisions.

Expanded AC6 and AC10 to cover single-package setup. Expanded AC7 to keep
pre-upgrade resume state and require reported restart and synchronization of
each active entry. Added AC12 for changed list, changed key, legacy state and
ordinary same-selection resume. Existing selected-package download and copy
reuse remain in place. Added the remote package-management source reference.

The change is documentation only. Q01-Q10, the umbrella and focused draft are
unchanged; no metadata, resume marker, package, implementation or index was
modified. No RHEL/Jenkins run, staging or commit was performed.

### Writer response for feature-request architecture-minor-fallback (round 3)

Writer response:

The round 2 findings are accepted and the requested narrow round is ready.

Q11 now proposes A, with its requested alternatives and an explicit analogy.
The proposal includes legacy unkeyed state because the actual last files cannot
establish a selected-file/detected-key match. Without that clause, the current
host's acceptance would remain ambiguous. This specifies observable behavior
without choosing a storage format or implementation design.

The body and AC7 require a reported restart when pre-upgrade state is retained,
and synchronization of all active Python and Git entries through the selected
lists and detected-key index. AC12 covers changed selected filename, changed
detected key and legacy state, with an unchanged-selection resume control.
Selected-package download/cache and copy reuse remain ordinary behavior.

AC6 and AC10 explicitly cover the single-package path. The general index
availability rules therefore cannot be implemented only in the regular flow.

One evidence precision: when last equals the final active line, process is set
to 1 before the loop ends, so the code emits the ordinary All lines have been
processed message rather than the already-processed warning. This strengthens
the finding that the skip can resemble success. The requirement states the
observable skipped synchronization without relying on either message text.

I verified the existing local marker read-only and did not delete or alter it.
All ten previously agreed proposed answers, the umbrella and focused draft are
unchanged. No implementation was undertaken. The new question remains subject
to human consolidation with the other proposed choices.

### Reviewer focus for feature-request architecture-minor-fallback (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-09-14T11:42:21+02:00
- Exchange: specification/feature-request/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for feature-request architecture-minor-fallback round 3

#### Verification of the round 2 changes for feature-request architecture-minor-fallback (round 3)

All round 2 requested changes are applied, and they are consistent with the
rest of the requirement:

- the current-behavior section describes the resume marker, its final-entry
  effect, remote selection from staged RPMs, and the single-package bypass of
  index generation;
- proposed selection step 5 states the Q11 rule, and it also settles legacy
  markers that record no identity. That clause was missing from my round 2
  wording and is required: the markers that exist today can never prove a match;
- AC6 and AC10 name the single-package path, AC7 keeps the pre-upgrade resume
  state and requires a reported restart, and AC12 covers a changed file, a
  changed key, legacy state and the unchanged-selection control;
- the references cite the resume logic, the direct path and the remote
  name resolution at the lines I checked.

#### Correction accepted from the writer for feature-request architecture-minor-fallback (round 3)

The writer's evidence precision is right, and I withdraw my wording on this
point. When `last` holds the final active entry, `sync_packages` sets `process`
to 1 on that entry, so the run ends with the ordinary "All lines have been
processed." message, not the "already been processed" warning I cited in round
2. The skipped synchronization therefore looks like success, which only
strengthens the finding. The requirement rightly avoids depending on either
message text.

#### Remaining observations for feature-request architecture-minor-fallback (round 3)

Nothing substantive remains. The eleven questions have distinct options with
consequences, the recommended answers follow from the recorded evidence, and
body, acceptance criteria and answers agree. The three edits I list under
covered wording are polish: a Q11 answer sentence phrased as an instruction
rather than as a stated result, one "generated" qualifier in Q10, and code
formatting in the question bodies.

Implementation can proceed once the human settles the four proposals that go
beyond D9 as confirmed: Q01 option D (ordering), Q06 option C (no cross-minor
index reuse), Q10 option A (the surviving curated set) and Q11 option A (resume
state keyed by selection). The requirement labels each one as pending human
decision, and each has workable alternatives recorded.

### Question verdicts for feature-request architecture-minor-fallback round 3

#### Round 3 verdict table for feature-request architecture-minor-fallback (round 3)

| Question | Verdict | Answer I would choose |
| --- | --- | --- |
| Q01 | Agree | D |
| Q02 | Agree | A |
| Q03 | Agree | A |
| Q04 | Agree | A |
| Q05 | Agree | A |
| Q06 | Agree | C |
| Q07 | Agree | A |
| Q08 | Agree | A |
| Q09 | Agree | A |
| Q10 | Agree | A |
| Q11 | Agree, with the legacy-state clause | A |

No question is missing, redundant, or out of the selected scope.

#### Notes for the human decision on the D9 refinements for feature-request architecture-minor-fallback (round 3)

- Q01 D, Q06 C, Q10 A and Q11 A refine or narrow D9 as confirmed on 2026-08-07.
  Each refinement rests on repository evidence recorded in the requirement:
  commit `18c251d`, the `zlib-dev` defect, and the current python resume marker.
- If Q06 A is chosen instead, the Q02 answer already records the pairing that
  acceptance must then carry. If Q11 B is chosen instead, the Q11 answer already
  records the AC7 and upgrade-procedure reset it requires. The alternatives are
  therefore safe to select at consolidation without another review round.

### Convergence evidence for feature-request architecture-minor-fallback round 3

Covered wording:

#### Wording edits covered by this recommendation for feature-request architecture-minor-fallback (round 3)

1. **Q11 answer, second and third sentences.** Replace "Add acceptance for
   changed list selection, changed detected key and legacy unkeyed state,
   including a host retaining its pre-upgrade marker. Report the restart and
   process each active entry through the selected inputs without requiring an
   operator to delete the marker." with "AC7 and AC12 cover a changed list
   selection, a changed detected key and legacy unkeyed state, including a host
   that retains its pre-upgrade marker: the restart is reported and each active
   entry is processed through the selected inputs without the operator deleting
   the marker."
2. **Q10 question body.** Replace "which resolves in neither index" with "which
   resolves in neither generated index".
3. **Question bodies Q05, Q06, Q07, Q08 and Q10.** Format identifiers as code,
   as the requirement body does: `centos_8_x86_64`, `rhel_7.9_x86_64`,
   `x86_64`, `18c251d`, `zlib-dev`, `zlib-devel`, `tools/add_tool.bat`,
   `setup.properties`, `pkgs/<arch>/` and `tools/pkgs/`.

Convergence rationale:

#### Why this requirement is ready for consolidation for feature-request architecture-minor-fallback (round 3)

- Every finding from rounds 1 and 2 is applied and verified against the code
  and the repository files: the index snapshot incident, the curated-list
  defect, the placeholder index, both unkeyed markers, the property-reader
  contract, the exit codes, the seed premise and the single-package path.
- Body, proposed selection steps, AC1 to AC12 and the eleven answers agree with
  one another, and the RHEL and Jenkins roles and the item 4, 6 and 7 boundaries
  are unchanged.
- The decisions that remain are human choices among recorded alternatives
  (Q01, Q06, Q10, Q11 refining D9). They are not open analysis, and each
  alternative states what acceptance would need if chosen.
- The only edits left are the three wording items listed above, none of which
  changes behavior or acceptance.

Consolidation must also reconcile the umbrella and the focused draft, as the
requirement's boundary section already records: the "fatals 902" explanation,
"one file per major", and, under Q06 C, the index falling back.

### Writer instructions for feature-request architecture-minor-fallback round 3

#### Round 3 instructions for the writer for feature-request architecture-minor-fallback (round 3)

1. Present the convergence recommendation to the human with the four proposals
   that refine D9 (Q01 D, Q06 C, Q10 A, Q11 A), since this answer does not
   authorize consolidation.
2. When consolidating, apply the three covered wording edits and reconcile the
   umbrella and focused draft as the boundary section lists.
3. Perform no metadata edit, marker deletion or implementation as part of
   consolidation; those belong to the implementation of this requirement.

### Final reviewer decision for feature-request architecture-minor-fallback round 3

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-3 -->

## Round 3 by human - human-confirmation

- Recorded: 2026-09-14T12:38:10+02:00
- Exchange: specification/feature-request/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/feature-request.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-3 -->
