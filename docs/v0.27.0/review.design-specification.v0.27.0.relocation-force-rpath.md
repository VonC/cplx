# Specification review transcript for v0.27.0

- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-08-16T20:00:44+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for design-specification relocation-force-rpath round 1

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
Review round: 1

### Requestor assessment for design-specification relocation-force-rpath round 1

First review round for a new design document. The requirement it answers
converged after five rounds and twelve clarifications, so nothing here reopens
the ordered classifier, the two-axis report, the bounded v0.26.0 migration
promise or the host-tool contract. What the design owes is the machinery those
decisions imply.

One fact surfaced while writing the design that the requirement had not reached,
and it is the reason Q01 exists. `patchelf --print-rpath` returns the
search-path string whether it sits in `DT_RPATH` or `DT_RUNPATH`, and the
documented option set has no query that separates them. The requirement made
tag-and-value the idempotence condition, so the pass must tell an object
relocated by v0.26.0 from one already converted by this change, and through the
interface the pass uses today those two objects are indistinguishable. That is a
design-level gap in the only tool the pass is allowed to add nothing to, and
every option for closing it has a cost: parse the dynamic section with `od`,
amend the host-tool contract for `readelf`, or keep installer-side state that a
v0.26.0 prefix will not have.

What the six questions cover:

- Q01 is the tag observation above, and the design recommends reading it from
  the object with `od`, since the same header walk answers the object kind, the
  `PT_INTERP` question and the no-dynamic-section case that the classifier also
  needs.
- Q02 asks how far that observation runs before the ordered classifier consults
  it. The acceptance requires the `rpath failed` figure to be zero, and an eager
  reader turns any unusual RPM-payload header into a failure even for an object
  the classifier would have excluded untouched.
- Q03 asks what the interpreter axis records when the shared header observation
  fails. Both axes draw on the same walk, and each must sum to the walked-ELF
  count, so a shared fault cannot simply be absent from one of them.
- Q04 asks what the report is as an interface. The cplx acceptance asserts on
  the figures, a retained recipe makes those assertions, and the installer
  speaks today in human sentences through the `echos` helpers.
- Q05 asks how a predecessor relocation is recognized, exact equality against
  the current computed value being the design's present answer and a structural
  in-prefix test being the alternative that degrades better.
- Q06 asks how the classifier can be exercised against the 388-object inventory
  the requirement obliges it to be validated against, given that a rule living
  inside an install loop can only be exercised by running installs.

Where the design is most likely to be wrong or incomplete:

- The claim in Q01 that patchelf cannot report the tag rests on the documented
  option set rather than on a run of the shipped binary. If a patchelf option or
  output detail does distinguish them, Q01's answer changes and the largest
  piece of new machinery in this design disappears.
- The ELF offsets the design relies on, `e_type` at `0x10` and the program
  header table reached through `e_phoff`, `e_phentsize` and `e_phnum`, are
  stated for the ELF64 layout the archive uses. They are not measured against a
  real archive object in this document.
- Q02 and Q03 interact more than the document says. Lazy observation means fewer
  objects reach the point where a shared failure could affect both axes, so
  answering Q02 one way narrows what Q03 governs.
- Q04's recommendation adds a file the installer writes into a deployment
  prefix, and the design names its lifecycle as unsettled rather than settling
  it. If a reviewer thinks a design must answer that before recommending the
  artifact, the recommendation is the thing to challenge.

Questions deliberately not asked:

- Nothing about which directories `build_elf_rpath` produces, or `$ORIGIN`
  entries: the requirement froze the search list.
- Nothing about exit codes, the interpreter guard's own condition, or making a
  failure fatal: all settled at requirement level.
- Nothing about shipping or pruning libraries, which is item 4 of the
  collection.
- Nothing about the RHEL preload measurement or the monitoring observable: those
  are acceptance evidence the requirement already specifies exactly, and the
  design adds no structure to them.

### Change summary for design-specification relocation-force-rpath round 1

Round 1: there is no preceding round, so this records how the design came to
exist and what it contains.

Provenance:

- `docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md` is the requirement,
  converged on 2026-08-16 after five review rounds, carrying twelve
  clarifications in its `Requirement clarifications` table and its full
  acceptance split.
- `docs/v0.27.0/draft.v0.27.0.relocation-force-rpath.md` is the focused draft the
  requirement was written from, itself derived from row 2 of the umbrella.
- `docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md` is this document,
  written from the requirement plus a fresh reading of
  `src/setups/env/bin/install_pkg.sh`.

What the design contains:

- A scope section naming three outcomes and listing what is deferred to item 4
  and to whichever later change alters the directory list.
- Seven confirmed facts read from the tree rather than inherited: the existing
  walk and its ELF filter, the four patchelf calls the pass makes today, the
  single computed search path, the `INSTALL_PREFIX="$HOME"` default with the
  how-to promise that makes it a supported shape, the differing shapes of the
  two guards, the fact that patchelf reports the search-path value without its
  tag, and the audited host-tool list carrying `head` and `od` but not
  `readelf`.
- A current-behavior sketch and a target-behavior sketch, each as a short flow,
  showing that the change is one observation phase and one ordered
  classification inserted where two independent tests sit today.
- Six design areas: the observation phase and its evidence sources; the ordered
  classifier and why two of its orderings carry the weight; the two-axis outcome
  model and its reconciliation property; migration and its bounds; the
  validation architecture as states rather than jobs; and the three
  documentation surfaces.
- A table of twelve acceptance cases, each naming the case number that fires and
  the reason.

Two design positions worth flagging as positions rather than restatements:

- The design proposes that one structured header read per object answers every
  classification input, instead of several independent probes whose answers
  could disagree. That is a choice, and Q01 and Q02 are where it is examined.
- The design treats the three wiki pages as part of the change rather than as
  follow-up, on the ground that the archive would otherwise ship a loader
  behavior and a description of it that disagree.

Six open questions were then placed by `oqm`, and no section of the design has
been edited in response to review yet.

### Writer response for design-specification relocation-force-rpath round 1

Writer response: Round 1: no reviewer feedback exists yet, so there is nothing accepted and
nothing disputed.

The writer's position going into this round:

- The six recommended answers are recommendations, not settled decisions. None
  is written into the body as a confirmed rule, so the design can absorb a
  different answer without a rewrite.
- Q01 is the one that changes the size of the work rather than its shape. If the
  tag can be read from the object with the already-mandatory tools, this design
  adds a program header parser to a shell script; if the reviewer prefers the
  amendment, it adds a host-tool dependency and deletes the parser. The writer
  recommends the parser because the contract it protects is the thing a CI agent
  image is validated against, but the recommendation is held on the value of the
  contract, not on a belief that the parser is pleasant.
- Q02 and Q06 both push toward the same shape, a classification that exists
  apart from the walk loop. The writer did not merge them because they are
  answerable separately: lazy observation is a choice about cost and failure
  semantics, and a separately invocable classifier is a choice about how a
  requirement obligation is discharged. A reviewer who wants them merged should
  say so, since the two answers together determine most of the internal
  structure.
- Q05 is the one where the writer deliberately recommends the weaker engineering
  answer. A structural test recognizing any in-prefix search path would degrade
  better than exact equality, and the requirement bounded the promise to
  v0.26.0. Recommending the structural test would make the design claim more
  than the requirement promises, and the writer would rather the two documents
  agree and the gap be owned by whichever change alters the directory list, as
  the requirement already assigns it.

Two things the writer wants examined rather than accepted:

- The claim that patchelf cannot report which tag holds the search path is read
  from its documented option set, not from running the shipped binary. It is
  load-bearing for Q01 and it has not been measured here.
- The ELF offsets the observation phase relies on are stated for ELF64 and are
  not checked against a real archive object in this document. They are ordinary
  and stable, but "ordinary and stable" is how the earlier probe readings went
  wrong twice in the requirement's own history.

### Reviewer focus for design-specification relocation-force-rpath round 1

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer

- Recorded: 2026-08-16T20:13:42+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for design-specification relocation-force-rpath round 1

The design has the right overall shape, and its load-bearing patchelf claim is
correct. The upstream manual defines `--print-rpath` as printing either
`DT_RUNPATH` or `DT_RPATH` and exposes no tag-specific print operation. The
upstream change log adds an important detail the design does not yet model:
when both tags exist, patchelf prefers `DT_RUNPATH`. Reading the tag from the
object is therefore justified, but the reader must return a defined state for
none, one, both, malformed and unsupported inputs rather than the singular
"rpath tag" the current design assumes.

This round is not ready for convergence. Q02's recommended lazy observation is
not implementable with the ordered classifier. `excluded` is case 7, not an
early case; deciding that an object reaches it already requires the program
header facts, the tag/value facts and the program/library facts. Independently,
the interpreter axis needs a positive `PT_INTERP` result for every walked ELF.
There is no unusual RPM object that can first be known to be excluded and only
then spared the header parse. The observation may short-circuit a probe after a
successful earlier observation proves it irrelevant, but the structural header
observation itself is eager.

Q04 and Q06 also stop short of implementable interfaces. Q04 recommends a new
persistent deployment artifact while expressly leaving its path, schema,
encoding, atomicity and rerun lifecycle unanswered. Q06 says a distinct
classifier can classify an arbitrary recorded object list, but a list of paths
does not contain the observation tuple the classifier needs, and the full
388-object zero is downstream-owned and includes objects the install pass never
walks. The correct boundary is a classifier over normalized observations,
combined with an integration run of the same observer and classifier over the
prepared archive tree. The downstream 388-object resolution probe remains a
separate claim, as Design Area 5 already says.

The existing questions cover the right six areas, but one missing question (or
an explicit extension of Q01) is required: what exact ELF domain and dynamic-tag
states the `od` reader accepts, and how every other state fails closed. Without
that, a shell parser can silently turn an unsupported class, byte order,
truncated table, extended header count, duplicate tag or simultaneous
`DT_RPATH`/`DT_RUNPATH` into a benign classification. The design must also say
that failure to compute the target rpath is a missing required rpath input,
while leaving the independently observable interpreter axis running.

References checked for the patchelf conclusion:

- [upstream patchelf manual](https://github.com/NixOS/patchelf/blob/master/patchelf.1)
- [upstream patchelf change log](https://github.com/NixOS/patchelf/blob/master/ChangeLog.md)

### Question verdicts for design-specification relocation-force-rpath round 1

1. **Q01 — choose 1A, with a strict observation contract.** The documented
   patchelf interface really cannot distinguish the tags, so the `od` reader is
   warranted and preserves the settled host-tool boundary. Define its output as
   a normalized tuple, not as loosely related shell variables: ELF kind,
   `PT_DYNAMIC` presence, `PT_INTERP` presence, dynamic-tag state and probe
   values. State the supported ELF domain and validate the identification,
   header sizes, table bounds, entry sizes and termination before using any
   result. Treat unsupported or malformed input as inconclusive. Simultaneous
   or duplicate search-path tags also need an explicit rule; the recommended
   fail-closed answer is `rpath failed`, because patchelf prefers `DT_RUNPATH`
   when both exist and the requirement defines no mixed-tag population. Run the
   actual shipped patchelf in validation even though its documented interface
   is already sufficient to settle the design choice.

2. **Q02 — reject 2B; choose a refined 2A.** Perform the structural ELF
   observation eagerly for every walked ELF. Short-circuit only after a
   successful observation proves a later probe irrelevant: no `PT_DYNAMIC`
   means no dynamic scan or rpath-value probe is needed, and no `PT_INTERP`
   means no interpreter-value probe is needed. Do not claim excluded objects
   avoid parsing: exclusion is the last case and cannot be known without the
   evidence. This also preserves the requirement's zero-failure gate over the
   complete walked set rather than silently narrowing it to rewritten objects.

3. **Q03 — choose 3A.** A shared header failure blocks both answers, so both
   axes record `failed`; these are two disposition views, not a deduplicated bug
   count. Add a small dependency matrix so the converse remains explicit:
   dynamic-tag/value failure blocks only rpath when the header still established
   the interpreter fact, interpreter-value failure blocks only interpreter, and
   either write can fail without erasing the other axis's result.

4. **Q04 — reject 4B as presently defined; add and choose 4D.** Emit the human
   summary through `echos` and a versioned machine-readable record stream in the
   captured install output, with an exact schema, path encoding and aggregate
   trailer. This gives the retained recipe a stable interface without leaving a
   production-state file whose lifecycle is undecided. If the writer keeps 4B
   instead, the design must settle the artifact's exact path, versioned schema,
   root-relative path encoding, atomic replacement, behavior after a partial or
   skipped run, and overwrite/cleanup behavior on ordinary and `--force`
   reruns; those are part of the choice, not follow-on detail.

5. **Q05 — choose 5A.** Exact equality is the mechanism that matches the
   bounded v0.26.0 promise. Keep the stated future-change obligation and do not
   silently widen recognition to any in-prefix value.

6. **Q06 — choose a corrected 6A.** Make the classifier a single callable
   decision over the normalized observation tuple and have the install loop use
   that same producer. Exercise all seven cases and the `$HOME` overlaps with
   controlled tuples, then integration-test observer plus classifier against an
   actual prepared archive tree. A bare recorded path inventory is not valid
   classifier input. Compare per-object integration records with the cplx-owned
   expected set (the 110 libraries, python and git programs, and other archive
   programs left rpath-excluded). Keep the consuming project's full 388-object
   resolution zero downstream; it is not an install-classifier population.

7. **Missing question — parser domain and ambiguous tag state.** Add this as
   Q07 or fold it visibly into Q01. The recommended answer is a narrow,
   validated ELF64 little-endian x86-64 reader because that is the archive
   contract, with every unsupported, out-of-bounds, unterminated or ambiguous
   state routed to the affected failure dispositions. Validate ordinary
   `ET_EXEC`, PIE, shared-library, no-`PT_DYNAMIC`, no-rpath, `DT_RPATH`,
   `DT_RUNPATH`, both-tag and truncated-table fixtures, plus the real archive.

### Requested changes for design-specification relocation-force-rpath round 1

Requested changes: 1. Make the `od` observation a specified, fail-closed interface, including the
   supported ELF domain, bounds/termination checks, and simultaneous or
   duplicate `DT_RPATH`/`DT_RUNPATH` handling.
2. Replace lazy case-driven header observation with eager structural
   observation; retain only evidence-based short-circuiting of irrelevant
   downstream probes.
3. Define the report's machine-readable interface completely, without leaving
   an unspecified persistent artifact in the deployed prefix.
4. Make the classifier consume normalized observations, and separate tuple
   tests from real-tree observer integration.
5. Correct Q06's ownership and input claims: cplx validates archive selection;
   the consuming project owns the 388-object resolution zero; a bare inventory
   of paths cannot drive the classifier.
6. Add the parser/error/actual-patchelf validation matrix and define the
   missing-target-rpath failure behavior while preserving the independent
   interpreter outcome.

### Writer instructions for design-specification relocation-force-rpath round 1

Revise the design and request another automated review round.

1. Extend Design Area 1 and Q01 with a precise observation tuple and a strict
   parser contract. Name the supported ELF class, byte order and machine; the
   header/program-header/dynamic-entry validations; the tag states; and the
   fail-closed result for unsupported, malformed, duplicate or simultaneous
   search-path tags. Do not rely on the 110-object happy path as the only parser
   validation.
2. Replace Q02's answer 2B with eager structural observation plus evidence-based
   short-circuiting of probes that a successful earlier observation made
   irrelevant. Correct the body language that currently promises both one
   structured observation and lazy per-case reads.
3. Keep Q03 at 3A and add the observation-to-axis dependency matrix so shared
   and axis-local faults, and independent write failures, have unambiguous
   paired outcomes.
4. Complete Q04 as an interface decision. Prefer a new 4D: versioned structured
   records in captured output beside the human summary, with the exact schema,
   encoding and reconciliation trailer. If a prefix artifact is retained,
   settle all of its lifecycle and atomicity details in this round.
5. Keep Q05 at 5A.
6. Rewrite Q06 around two distinct checks: controlled observation tuples for
   the single classifier, and observer-plus-classifier integration over a real
   prepared archive. Correct the claim boundary so cplx validates its archive
   selection while the consuming project retains ownership of the 388-object
   resolution zero. State what callable boundary the retained recipe actually
   invokes; a path list alone is insufficient.
7. Add acceptance coverage for parser rejection and both-tag ambiguity, the
   actual shipped patchelf, every ordered case, the two `$HOME` overlaps, and
   per-axis failures. State that an empty/unavailable computed target rpath is a
   missing required rpath input and does not prevent the interpreter axis from
   reaching its own evidenced disposition.

Do not reopen the ordered classifier, the two-axis vocabulary, the v0.26.0
migration bound or the host-tool contract. These changes define the machinery
needed to implement those settled choices.

### Final reviewer decision for design-specification relocation-force-rpath round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-08-16T20:48:02+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for design-specification relocation-force-rpath round 2

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
Review round: 2

### Requestor assessment for design-specification relocation-force-rpath round 2

Round 2. All six round 1 requested changes are applied, none disputed. One of
them refuted the writer's reasoning outright rather than refining it, and that
is the one worth naming first.

Q02 recommended lazy observation on the argument that an object destined for
exclusion should not fail a parse it never needed. That argument does not
survive the ordering the requirement fixed. `excluded` is case 7, the last one,
so an object is known to reach it only after cases 1 to 6 have been evaluated,
and those need the program header facts, the tag and value facts and the
program-or-library fact. The interpreter axis independently needs a positive
`PT_INTERP` answer for every walked ELF whatever its rpath disposition. There is
no object that can be recognized as harmless before it is observed, so the
saving the writer proposed does not exist. The structural observation is eager;
what survives from the rejected answer is evidence-based short-circuiting, where
a completed observation proves a probe irrelevant, no `PT_DYNAMIC` meaning no
dynamic scan or `--print-rpath`, and no `PT_INTERP` meaning no
`--print-interpreter`.

Round 1 also confirmed the design's load-bearing premise from the upstream
manual, and supplied one fact the design had not modelled: patchelf prefers
`DT_RUNPATH` when an object carries both tags. That turns the mixed-tag state
from a theoretical case into one that would silently decide a disposition by
patchelf's preference rather than by the object, so `tag_state: ambiguous` now
yields `rpath failed` and Q07 exists to hold that with the rest of the parser
contract.

Where the other five landed:

1. The observation is specified as an interface rather than described. Design
   Area 1 now names a normalized tuple with a single `status`, so no consumer can
   proceed on a field another consumer would reject; states the supported ELF
   domain as ELF64 little-endian `EM_X86_64`, which is the archive's own
   contract; lists the validations, identification bytes, `e_phentsize`, table
   and header bounds against file size, dynamic entry size and `DT_NULL`
   termination; and puts the extended `e_phnum` encoding outside the domain.
   Anything unsupported, out of bounds, unterminated or ambiguous is
   inconclusive.
2. Q04's prefix artifact is replaced by option 4D, a versioned structured record
   stream in the captured install output beside the human `echos` lines, with
   the schema fixed in the design: a version-carrying line marker, one record per
   object with a prefix-relative encoded path, both dispositions and the case
   number, and a trailer carrying every count and the walked-ELF total. A skipped
   pass emits the trailer with a total of zero and no records, so "did not run"
   stays distinguishable from "ran and found nothing". No state is written into a
   deployment prefix, so no lifecycle question is left open.
3. Q06 is rewritten as two distinct checks: the classifier driven directly with
   controlled observation tuples, reaching all seven cases, both `$HOME`
   overlaps, the ambiguous tag state and an inconclusive status; and the observer
   plus that same classifier run over a prepared archive tree. The design now
   says plainly that a recorded path list is not classifier input, since a path
   carries none of the tuple.
4. Q06's ownership claim is corrected. The cplx expected set is the 110 flagged
   libraries selected, the python and git programs selected, and every other
   archive program left rpath-excluded. The consuming project's 388-object zero
   is a resolution result over a population that includes objects the install
   pass never walks, and the design states that it is not an install-classifier
   population.
5. Design Area 3 gains the observation-to-axis dependency matrix, covering the
   shared structural failure, the two axis-local probe failures, the ambiguous
   tag, the two write failures, and an empty computed target search path, which
   is a missing required rpath input for every walked ELF while leaving the
   interpreter axis to reach its own evidenced disposition. The acceptance table
   gained eleven cases covering parser rejection, both-tag ambiguity, per-axis
   failures, the skipped-pass trailer and a run of the actual shipped patchelf.

What round 2 should look at:

- The record stream of Q04 makes the retained capture the evidence. A run whose
  output was not captured leaves nothing to assert on, which is a weaker
  guarantee than a file on disk and was accepted deliberately. If a reviewer
  thinks the validation architecture needs the stronger form, that is the place
  to say so.
- The parser domain excludes the extended `e_phnum` encoding. The writer
  believes no archive object uses it, since it applies only past 65535 program
  headers, but that belief is not measured against the real tree.
- Q07's fixture set is named but not sized. Building a truncated-table and a
  both-tag fixture is straightforward; building an unsupported-class one that is
  otherwise realistic is less so, and the design does not say whether fixtures
  are constructed by hand, carried in the repository, or generated.
- The design still asserts the ELF64 field offsets from the specification rather
  than from a real archive object, which round 1 did not challenge and which
  remains the one place the reader's foundation is taken on trust.

### Change summary for design-specification relocation-force-rpath round 2

Changes to `docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md` since round 1,
applying round 1's six requested changes.

Design Area 1, the observation phase, largely rewritten:

- The "one header read supplies every classification input" subsection is
  replaced by a normalized tuple table: `elf_kind`, `has_dynamic`, `has_interp`,
  `tag_state`, `rpath_value`, `interp_value` and a single `status`. The text
  states that an inconclusive status carries no usable field, being a verdict
  about the whole observation.
- A new subsection makes the structural observation eager and explains why: case
  7 is last, so exclusion cannot be known early, and the interpreter axis needs
  `has_interp` for every walked ELF. It defines the two evidence-based
  short-circuits and distinguishes them from lazy observation.
- A new subsection states the supported ELF domain, ELF64 little-endian
  `EM_X86_64`, and lists the validation chain: identification bytes,
  `e_phentsize` against the ELF64 program header size, table and per-header
  bounds against file size, dynamic entry size, `DT_NULL` termination within
  `p_filesz`, and the extended `e_phnum` encoding placed outside the domain. Any
  failure makes the whole tuple inconclusive.
- A new subsection covers the both-tag state: patchelf prefers `DT_RUNPATH` when
  both exist, so `--print-rpath` would return the runpath value while an ignored
  rpath stayed behind. `tag_state: ambiguous` yields `rpath failed`, with the
  reasoning that guessing would make the disposition depend on patchelf's
  preference rather than on the object.
- The parser-cost paragraph now says the 110-object happy path is not the
  parser's validation, and that constructed fixtures are needed alongside the
  real archive.

Design Area 1's failure subsection is replaced by a dependency matrix listing
seven faults against their two axis outcomes: structural inconclusive fails
both; dynamic scan or `--print-rpath` failure, ambiguous tag, `--set-rpath`
failure and an empty computed target search path fail only rpath;
`--print-interpreter` and `--set-interpreter` failures fail only interpreter.
The text draws the two readings out, that a shared fault gives two views of one
walk and that everything else is axis-local.

Design Area 3, the outcome model, gains a report-interface subsection:

- Two readers, two forms, one captured stream. The human `echos` lines are
  unchanged; beside them a versioned structured record stream carries a
  version-bearing line marker, one record per object with its prefix-relative
  encoded path, both dispositions and the case number, and a trailer with every
  count and the walked-ELF total.
- Three rules are stated: the schema version on every record so a mismatched
  recipe fails loudly, path encoding that cannot be read as a field boundary,
  and reconciliation in the trailer so a truncated capture is detectable.
- A skipped pass emits the trailer with a zero total and no records.

Design Area 5, the validation architecture:

- The "two owners" subsection is preceded by a new "two checks" subsection: the
  classifier over controlled tuples, reaching all seven cases, both `$HOME`
  overlaps, the ambiguous tag and an inconclusive status; and observer plus
  classifier over a prepared archive tree compared against the expected set. It
  states that a recorded list of paths is not classifier input.
- The ownership subsection now names the cplx expected set explicitly, the 110
  flagged libraries, the python and git programs, and other archive programs left
  rpath-excluded, and says the downstream 388-object zero is a resolution result
  over a different population including objects the install pass never walks, so
  it is not an install-classifier population.

Acceptance cases:

- The unparseable-header row now fails both axes rather than only rpath.
- Eleven rows added: an unsupported class or extended `e_phnum`; a truncated
  table or unterminated dynamic list; an object carrying both tags; an
  axis-local `--print-rpath` failure with the interpreter answer standing; the
  converse `--print-interpreter` failure; an empty computed target search path;
  the skipped-pass trailer; and a run of the actual shipped patchelf recording
  observed rather than documented behavior. The reconciliation row now names the
  trailer.

Open questions, replaced as a whole:

- Q01 rewritten around the normalized tuple. Q02's answer changed from 2B to 2A,
  with 2B kept as an option and its refutation recorded in its cons. Q03 gains
  the matrix. Q04 gains option 4D and answers it, with 4B kept and its
  unsettled-lifecycle objection recorded. Q05 unchanged at 5A. Q06 rewritten as
  two checks, gaining option 6D, treating the downstream zero as the classifier's
  validation, so that the ownership error is recorded as rejected rather than
  merely absent. Q07 is new, covering the parser domain, the validation chain,
  the ambiguous tag state and the fixture set, with option 7B, a permissive
  reader falling back to the patchelf value, recorded and rejected.
- Answers now stand at 1A, 2A, 3A, 4D, 5A, 6A, 7A.

### Writer response for design-specification relocation-force-rpath round 2

Writer response: All six requested changes are applied. Nothing is disputed.

The Q02 refutation is accepted without reservation and it corrects a reasoning
error, not a wording one. The writer argued from a picture of the classifier
that the classifier does not have: a cheap early test that identifies harmless
objects, with the expensive evidence gathered only for the rest. There is no
such test, because the cheap-sounding outcome, `excluded`, is the last case in
the order and is reached by elimination. An outcome reached by elimination costs
every test above it. The interpreter axis settles it independently, since it
needs `has_interp` for every walked ELF whatever the rpath axis decided.

What survives from the rejected answer is worth keeping and is now stated as its
own rule: a probe may be skipped when a completed observation has proved it
irrelevant. That is not lazy observation, and the difference is exactly the one
the writer blurred, since the skip now rests on an observation that succeeded
rather than on a prediction about where the object would land.

The both-tag fact from the change log is the most useful thing this round
produced, because it turns a state the design would have left undefined into one
that would have failed quietly. patchelf preferring `DT_RUNPATH` means an object
carrying both tags would have presented as a clean case 5 candidate, been
converted, and left an ignored `DT_RPATH` behind, with nothing in the report to
show for it. It is now `rpath failed`, and Q07's option 7B records the tempting
alternative, a reader that falls back to the patchelf value when the structure is
unclear, so that the way this defect would be reintroduced is written down rather
than merely avoided.

On Q04 the writer accepts that leaving the artifact's lifecycle open was not a
deferral of detail but an incomplete decision. The record stream is the better
answer for a reason the writer had not weighed: the assertion surface and the
evidence retention become the same act, and the validation recipe already retains
its output. The cost, that a run whose output was not captured leaves nothing to
assert on, is accepted and named in the design rather than glossed.

On Q06 the ownership correction is the one the writer would most likely have
repeated. Borrowing the downstream 388-object zero would have left the
classifier unvalidated while looking validated, since that figure answers
resolution over a population including objects the install pass never walks.
Option 6D now records that as rejected, because it is the kind of shortcut that
looks like rigour.

Three things are offered for round 2 rather than claimed as settled. The record
stream makes the retained capture the evidence, which is weaker than a file on
disk and was chosen deliberately. The parser domain excludes the extended
`e_phnum` encoding on a belief about the archive that has not been measured. And
the fixture set of Q07 is named but not sized, with no statement of whether
fixtures are hand-built, carried in the repository, or generated.

### Reviewer focus for design-specification relocation-force-rpath round 2

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-08-16T21:03:38+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for design-specification relocation-force-rpath round 2

Round 1's decisions are applied in the right direction, and Q02 is now correct.
The design is nevertheless not internally implementable yet, so this round is
`changes-requested` rather than convergence-ready.

The largest remaining problem is the normalized observation contract. Design
Area 1 gives the tuple one `status`, says any failed validation makes the whole
tuple inconclusive, and says an inconclusive tuple has no usable field. Q03 then
requires a failed `--print-rpath` to preserve the interpreter result, a failed
`--print-interpreter` to preserve the rpath case, and an ambiguous tag to fail
only rpath. Those outcomes require partial independence by design. A single
whole-tuple status cannot represent them. The observation needs a structural
status plus separate rpath- and interpreter-probe statuses; an ambiguous tag is
a successfully observed structural state that invalidates rpath classification,
not a structurally inconclusive tuple.

The validation architecture has the corresponding gap. Q06 calls for two
checks: classifier tests over already-normalized tuples and integration over the
real archive. Q07 separately promises constructed malformed, unsupported and
mixed-tag ELF fixtures. Those fixtures exercise the observer and are neither of
Q06's two checks: tuple tests bypass the observer, while the real archive is
expected not to contain the rejected states. There are three layers: classifier
tuple tests, observer tests over constructed ELF fixtures, and observer-plus-
classifier integration over the real archive.

Q04 selects the right transport but has not yet fixed the interface it says is
fixed. "A fixed prefix", "encoded" and a list of fields do not choose a literal
record grammar or an encoding. More importantly, the specified skipped-pass
trailer (zero walked objects, no records) is identical to the specified result
for a completed walk of an empty tree, so it cannot make those states
distinguishable as claimed. The trailer needs a run status/reason, and the
per-object record must distinguish the classifier's assigned case from the
final disposition after a write failure.

Q07's narrow domain is appropriate, and excluding extended `e_phnum` is safe
when the real-tree integration proves no object uses it. No fixture count is
needed at design level, but the fixture matrix must cover each rejection rule;
the current list omits duplicate tags, unsupported class/byte-order/machine,
extended `e_phnum`, bad entry sizes/bounds and missing `DT_NULL`. The design
also needs a host-contract-compliant source for file size. `stat` and `wc` are
not in the audited list; the existing GNU `find` can supply the size alongside
the NUL-delimited path, or the requirement must be amended before another tool
is used.

Finally, keep the mixed-tag failure but correct its rationale. The upstream
change log says `--force-rpath` deletes `DT_RUNPATH`; the design therefore
cannot claim that a forced conversion necessarily leaves the ignored tag
behind. The reason to fail is sufficient without that claim: the requirement
defines no mixed-tag population, and `--print-rpath` masks the state by
preferring `DT_RUNPATH`. The exact mutation should be measured with the shipped
binary as Q07 already requires.

References checked:

- [upstream patchelf manual](https://github.com/NixOS/patchelf/blob/master/patchelf.1)
- [upstream patchelf change log](https://github.com/NixOS/patchelf/blob/master/ChangeLog.md)

### Question verdicts for design-specification relocation-force-rpath round 2

1. **Q01 -- keep 1A, but revise the tuple contract.** Use one
   `structural_status` for ELF identification, header/table bounds and dynamic
   scanning, plus an explicit status for each optional patchelf probe (`ok`,
   `skipped as structurally inapplicable`, or `failed`). Values are usable only
   when their own status permits it. A structural failure invalidates both
   axes; an axis-local probe failure preserves fields established independently.
   `tag_state: ambiguous` is a successful structural result that routes rpath to
   failure while preserving interpreter evidence. This makes Q01 implement the
   Q03 matrix instead of contradicting it.

2. **Q02 -- agree with 2A.** Eager structural observation plus
   evidence-based probe short-circuiting is the only model consistent with the
   ordered classifier and the interpreter axis. No further design choice is
   missing here.

3. **Q03 -- agree with 3A and the matrix.** The matrix is the authoritative
   dependency model. Reflect it directly in the tuple statuses, and say that a
   write failure changes the final axis disposition without changing the
   classifier case already assigned. This distinction is needed by the case 5
   count and per-object report.

4. **Q04 -- keep 4D after completing it.** Choose a literal versioned grammar,
   field order and path encoding rather than describing their properties. A
   host-boundary-safe option is lowercase hexadecimal UTF-8 path bytes produced
   with the already-required `printf`, `od` and `tr`. Give the trailer an
   explicit run state such as `completed` or `skipped`, plus a stable skip
   reason, because zero records and zero walked objects alone do not distinguish
   a missing-patchelf skip from a completed empty walk. Record both
   `classifier_case` and the final rpath disposition so a case 4/5/6 write
   failure does not erase population identity. Require exactly one valid trailer
   for a complete capture.

5. **Q05 -- agree with 5A.** Exact equality remains the mechanism matching the
   bounded v0.26.0 promise.

6. **Q06 -- keep 6A's callable classifier, but replace two checks with three
   validation layers.** First drive the classifier with controlled tuples.
   Second drive the observer with constructed ELF fixtures and assert the tuple
   or structural failure it emits. Third run observer plus classifier over the
   real prepared archive and compare the cplx-owned expected set. The first
   proves the ordering, the second proves the binary reader's rejection rules,
   and the third proves both survive real archive objects. None substitutes for
   another, and the downstream 388-object zero remains correctly excluded.

7. **Q07 -- keep 7A with a guard-complete fixture matrix.** The narrow ELF64
   little-endian x86-64 domain is appropriate. Excluding extended `e_phnum`
   needs no separate measurement before design closure because the required
   real-tree run will turn any occurrence into a visible failure. Add at least
   one deterministic observer fixture per acceptance and rejection class,
   including duplicate tags and every stated domain/bounds/termination guard;
   exact fixture count and whether bytes are generated or retained belong in
   the plan. State how file size reaches the observer without adding `stat` or
   `wc`; using the existing GNU `find` walk to emit size and NUL-delimited path
   is the recommended answer.

8. **Missing questions.** No new topic needs a separate Q08. The remaining
   decisions belong inside Q01, Q04, Q06 and Q07. Their current answers require
   substantive correction before consolidation.

### Requested changes for design-specification relocation-force-rpath round 2

Requested changes: 1. Split structural and axis-local observation status so the normalized tuple
   can implement the Q03 fault matrix.
2. Specify Q04's literal record grammar, concrete path encoding, run status and
   skip reason, and preserve classifier case separately from final disposition.
3. Expand Q06 from two checks to classifier, observer-fixture and real-tree
   integration layers.
4. Make Q07's fixture matrix cover every parser guard and specify a file-size
   source inside the audited host-tool contract.
5. Correct the mixed-tag mutation rationale while retaining its fail-closed
   outcome and shipped-binary measurement.

### Writer instructions for design-specification relocation-force-rpath round 2

Revise the design and publish another automated review round.

1. Replace the single whole-observation `status` with a structural status and
   per-probe statuses that can express every row of Q03. Make ambiguous tags a
   successfully observed rpath-invalid state, not a whole-tuple inconclusive
   result.
2. Preserve Q02 at 2A and Q03 at 3A. Define the classifier case as immutable
   population identity and the post-action disposition as a separate result,
   especially when a case 4, 5 or 6 write fails.
3. Finish Q04's record interface with a literal marker/grammar, schema version,
   field order and concrete path encoding. Add trailer run status and reason so
   `skipped: patchelf absent` differs from `completed: zero walked`. Require one
   trailer and reconcile its counts, record count and walked total.
4. Rewrite Q06 as three validation layers: classifier over controlled tuples;
   observer over deterministic constructed ELF fixtures; and observer plus
   classifier over the real prepared archive. Keep the corrected cplx/downstream
   ownership boundary.
5. Expand Q07's fixture matrix to cover every parser guard and both ambiguity
   forms, without prescribing an arbitrary fixture count. State the source of
   file size within the audited host-tool contract; prefer carrying GNU
   `find`'s size with its NUL-delimited path unless evidence supports another
   already-listed mechanism.
6. Remove the claim that forced conversion of a mixed-tag object necessarily
   leaves the ignored tag behind. Retain fail-closed handling because no
   mixed-tag population is specified and patchelf's value probe masks the
   state; record the shipped binary's actual print and force behavior.

These changes do not reopen answers 1A through 7A. They make the selected
interfaces mutually consistent and executable.

### Final reviewer decision for design-specification relocation-force-rpath round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-08-16T21:13:47+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for design-specification relocation-force-rpath round 3

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
Review round: 3

### Requestor assessment for design-specification relocation-force-rpath round 3

Round 3. All five round 2 requested changes are applied, none disputed. Answers
remain 1A, 2A, 3A, 4D, 5A, 6A, 7A; what changed is that four of them now specify
what they previously described, and one rationale was withdrawn as wrong.

The finding that matters most is that the design contradicted itself, and both
halves were written in the same round. Design Area 1 gave the observation a
single `status` and stated that an inconclusive tuple carries no usable field.
Design Area 3's fault matrix, three sections later, required a failed
`--print-rpath` to leave the interpreter answer standing, a failed
`--print-interpreter` to leave the rpath case standing, and an ambiguous tag to
fail only rpath. Those are partial outcomes, and a whole-tuple verdict makes
every one of them fail both axes. The observation now carries a
`structural_status` plus a status per probe, with `skipped` distinguished from
`failed` so an evidence-based short-circuit does not read as an error, and
`tag_state: ambiguous` is reclassified as a **successful** structural
observation that invalidates rpath classification while leaving every
interpreter field intact.

The withdrawn rationale is the second thing worth naming. This design argued
that converting a mixed-tag object would leave the ignored tag behind. The
upstream change log records that `--force-rpath` deletes `DT_RUNPATH`, so that
is not the mutation. The fail-closed outcome is retained on the two reasons that
survive without it, that the requirement defines no mixed-tag population and
that `--print-rpath` masks the state by preferring `DT_RUNPATH`, and the shipped
binary's actual print and force behavior is now measured in validation rather
than argued from a manual or from this paragraph.

Where the other three landed:

1. Q04 has a literal grammar rather than a description: a `CPLX-ELF/1` marker,
   an `obj` record carrying the classifier case, both dispositions and the
   prefix-relative path as lowercase hexadecimal UTF-8 bytes, and one `end`
   trailer carrying a run state, a stable reason token, the walked total and
   every count. The hex encoding was chosen because it settles the quoting
   question outright, the encoded form containing only `0` to `9` and `a` to
   `f`, and because it needs only the shell's `printf` plus the audited `od` and
   `tr`. The run state fixes a real defect the earlier text carried: a skipped
   pass and a completed walk of an empty tree both produced zero records and a
   zero total, so the trailer could not distinguish the two states it claimed
   to. Exactly one trailer per capture makes truncation and concatenation
   detectable.
2. Q06 is three layers rather than two. Controlled tuples bypass the observer
   and a real archive is expected to be well-formed, so the reader's rejection
   rules were exercised by neither; a middle layer over deterministic
   constructed ELF fixtures now covers them. The design says which layer proves
   what, and that a recorded path list is not classifier input for any of them.
3. Q07's fixture matrix is guard-complete rather than illustrative, with a table
   covering accepted forms, both ambiguity forms, the domain guards, the bounds
   guards and termination. Fixture count and whether bytes are generated or
   retained are named as plan questions. File size now comes from the GNU `find`
   walk already running, emitted beside the NUL-delimited path, since neither
   `stat` nor `wc` is in the audited list; option 7D records that shortcut as
   rejected.
4. Design Area 2 gains the case/disposition split: the classifier case is
   immutable population identity, the disposition is what happened. They differ
   exactly when a write fails, and collapsing them would shrink the migration
   checked count on the runs where something went wrong.

What round 3 should look at:

- The record grammar is positional and single-space separated, and the hex path
  encoding is what makes that safe. Every other field is drawn from a fixed
  vocabulary, so the writer believes no field can contain a space, but that is a
  property of the current vocabularies rather than something the grammar
  enforces.
- The `skipped` probe status is described as set when the structural result
  proves the probe irrelevant. That is the only producer named. If a probe could
  be skipped for another reason, an implementation could reach for the same
  value and the report would stop distinguishing evidence from omission.
- The fixture matrix asserts "the exact tuple or structural failure the observer
  should emit", which presumes the tuple has a serialized form the fixtures can
  compare against. The design does not say whether that is the record stream, a
  separate representation, or something the observer returns in-process.
- The design now specifies enough of the interface that some of it may belong to
  the plan rather than here. The writer has drawn that line at what a reader
  must implement to interoperate, and would rather the reviewer moved it than
  guessed at it.

### Change summary for design-specification relocation-force-rpath round 3

Changes to `docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md` since round 2,
applying round 2's five requested changes.

Design Area 1, the observation:

- The tuple table gains `structural_status`, `rpath_probe_status` and
  `interp_probe_status`, and loses the single whole-observation `status`. The
  probe values are listed against the status that governs them.
- A new subsection explains why one status cannot work, naming the three matrix
  outcomes it would break, and states the rule: `structural_status:
  inconclusive` invalidates the whole tuple and is the only fault blocking both
  axes; the two probe statuses are independent, with `skipped` meaning the
  structural result proved the probe irrelevant and `failed` meaning it ran
  without answering.
- `tag_state: ambiguous` is restated as a successful structural observation that
  invalidates rpath classification while leaving interpreter fields intact,
  rather than an inconclusive read.
- The validation subsection now says a failed validation sets
  `structural_status: inconclusive` and does not touch the probe statuses.
- A paragraph was added on the file-size source: the bounds checks need it, the
  audited contract carries neither `stat` nor `wc`, and it comes from the GNU
  `find` walk already running, emitted beside the NUL-delimited path.
- The mixed-tag subsection is rewritten. The claim that a forced conversion
  leaves the ignored tag behind is withdrawn explicitly, with the change-log
  fact that `--force-rpath` deletes `DT_RUNPATH` recorded in its place. The
  fail-closed outcome is retained on the two remaining reasons, and the shipped
  binary's behavior is deferred to measurement.
- The parser-cost subsection gains the guard-complete fixture matrix: a table of
  accepted forms, both ambiguity forms, the domain guards, the bounds guards and
  termination, with fixture count and generation named as plan questions.

Design Area 2, the classifier:

- A new subsection separates the classifier case from the disposition. The case
  is immutable population identity; the disposition records the outcome of
  acting on it; they differ exactly when a write fails, and a case 5 object whose
  write failed stays in the migration population with a `failed` disposition.

Design Area 3, the outcome model:

- The report subsection replaces the element table and the three properties with
  a literal two-line grammar, `CPLX-ELF/1 obj ...` and `CPLX-ELF/1 end ...`,
  followed by field-by-field definitions: the marker and schema version, the
  positional single-space fields, the case beside the disposition, the hex path
  encoding with its rationale and its tool cost, the run state and stable reason
  token, and the per-axis and migration counts.
- Two invariants are stated: exactly one trailer per capture, and reconciliation
  of the counts against the walked total and the record count.
- The earlier claim that a zero total distinguishes a skipped pass is replaced,
  since it does not; the run state is what does.

Design Area 5, validation:

- The two-check subsection becomes three layers, in a table naming each layer's
  input and what it proves, with a paragraph on why the middle layer is the one
  a design would most easily omit.

Acceptance cases:

- The unparseable-header row now names `structural_status: inconclusive`.
- Five rows added: a case 5 object whose write fails staying in the migration
  population; a skipped pass against a completed empty walk, distinguished by
  run state; a capture with no trailer or two; and a path containing a space or
  newline surviving the hex encoding.

Open questions, replaced as a whole:

- Q01 rewritten around the three statuses. Q02 and Q05 carried unchanged. Q03
  gains the case/disposition split in its option and answer. Q04's option 4D now
  carries the literal grammar and the run state, with the defect it fixes named.
  Q06 rewritten as three layers, gaining option 6B, two layers, so that the
  rejected shape is on the record. Q07 gains option 7D, obtaining file size with
  `stat` or `wc`, recorded and rejected on host-contract grounds, and its 7A
  option text now carries the guard-complete matrix and the `find` size source.
- Answers unchanged at 1A, 2A, 3A, 4D, 5A, 6A, 7A.

### Writer response for design-specification relocation-force-rpath round 3

Writer response: All five requested changes are applied. Nothing is disputed.

The internal contradiction is the finding the writer would most want to have
caught alone, because both halves were written in the same round and neither was
inherited. Design Area 1 promised a single verdict over the observation and
Design Area 3 required partial ones, three sections apart, and the document read
as coherent because each section was coherent on its own. The lesson the writer
takes is narrower than "check for contradictions": a status field is an
interface between sections, and this one was specified in the section that
produced it rather than in the section that consumes it.

`tag_state: ambiguous` is the part of the repair that changes meaning rather
than shape. Calling it inconclusive was wrong in a way that would have propagated:
the reader established exactly what the object carries, so treating that as a
failed observation would have failed the interpreter axis too, on an object whose
interpreter evidence is perfectly good. It is a successful observation of a state
that happens to be unusable on one axis, and those are different things.

The mixed-tag rationale is a straightforward correction and the writer notes what
it cost: the argument that a forced conversion leaves the ignored tag behind was
invented from the shape of the problem rather than read anywhere, and the change
log says the opposite. The outcome does not move, because the two reasons that
carry it never depended on the mutation, but the writer had put three reasons in
the document and only two were true. The shipped binary now settles it in
validation rather than a paragraph.

On Q04 the writer accepts the sharper half of the finding. Choosing the record
stream over a prefix file was a decision; calling the result "fixed" while
writing "a fixed prefix" and "encoded" was not. The zero-record defect is the
clearer failure: the design claimed the trailer distinguished a skipped pass from
a completed empty walk, and the specified output for the two was identical, so
the claim was false as written rather than merely vague.

On Q06 the middle layer is accepted as the gap it was. Two layers looked
complete because each was individually justified, and the reader's rejection
rules fell between them: tuples bypass the reader, and the real archive is
expected not to contain the states the rules exist for. That is the same shape as
the Q02 error two rounds ago, a boundary drawn where two justified things meet
without checking what falls in the gap.

Four things are offered for round 3 rather than claimed as settled. The record
grammar is positional and relies on no field containing a space, which holds for
the current vocabularies but is not enforced by the grammar. The `skipped` probe
status names only one producer, and a second would blur evidence and omission.
The fixture matrix asserts against "the exact tuple the observer should emit"
without saying what serialized form the fixtures compare against. And the design
may now specify more interface than belongs outside the plan; the writer drew the
line at what a reader must implement to interoperate and would rather the
reviewer moved it than guessed at it.

### Reviewer focus for design-specification relocation-force-rpath round 3

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-08-16T21:30:00+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for design-specification relocation-force-rpath round 3

Round 2's requested changes are substantively applied, and answers 1A through
7A remain the right choices. Round 3 is still `changes-requested`, because two
of the newly specified interfaces contain implementable counterexamples rather
than wording-only roughness.

First, Q04's positional grammar is not safe for the current vocabularies. It
says every field is single-space separated and no field may contain a space,
but the settled dispositions include `not dynamically linked`, `already
correct`, and `not applicable`. The current records are therefore ambiguous
before any future vocabulary change. The trailer is also still schematic:
`<r:...>`, `<i:...>` and `<mig:checked,failed>` do not fix names, order or
wire tokens. Keep 4D, but give the wire format closed, space-free enum tokens
distinct from the human labels and enumerate every trailer field literally.

Second, Q01 still has no probe-status value for structural failure. When
`structural_status` is inconclusive, neither probe may run. Such a probe is not
`ok`, not `failed` (it did not run), and not `skipped` under the design's exact
definition (positive structural evidence proved it inapplicable). Saying the
structural failure "does not touch" the statuses invites stale values from the
previous loop iteration. Either make the tuple a tagged union in which all
other fields are absent on structural failure, or add a `blocked` probe status.
The latter is clearer for controlled-tuple validation. Reserve `skipped`
exclusively for `has_dynamic: no` and `has_interp: no`; no second producer is
needed.

Q07 also rejects a valid ELF shape if its `e_phentsize` check is unconditional.
The ELF specification defines `e_phnum == 0` as a file with no program-header
table. In that branch there is no entry whose size must equal 56, and a valid
relocatable object can legitimately have no table. The observer should accept
that state as `has_dynamic: no`, `has_interp: no`, `tag_state: none`, with both
probes skipped; require the ELF64 program-header size only when ordinary
`e_phnum` is nonzero. Add the zero-table object and a truncated ELF header to
the guard matrix.

The three validation layers are now correct. Their tuple boundary needs one
sentence, not a serialized tuple protocol: classifier tests supply named fields
at the callable boundary, observer-fixture tests assert those same named fields,
and the record stream is post-classification evidence rather than the observer's
serialization. How Bash carries those fields and whether fixtures are generated
or retained belongs in the plan.

Two smaller corrections belong with the above edits. Hex encoding should be of
the pathname's raw bytes, not "UTF-8 bytes": Linux filenames may contain bytes
that are not valid UTF-8, and the current text claims those are supported. The
trailer reason vocabulary should be closed to `none` and `patchelf-absent` for
this schema, not introduced with "such as"; any later skip producer then owes a
new token and review rather than silently reusing `skipped`.

The amount of interface specification is appropriate. The stream is consumed
outside the implementation and therefore its wire grammar belongs in design.
Fixture byte counts, construction mechanics and the Bash representation of the
internal tuple belong in the plan.

References checked:

- [System V ELF specification](https://refspecs.linuxfoundation.org/elf/elf.pdf)
- [upstream patchelf manual](https://github.com/NixOS/patchelf/blob/master/patchelf.1)
- [upstream patchelf change log](https://github.com/NixOS/patchelf/blob/master/ChangeLog.md)

### Question verdicts for design-specification relocation-force-rpath round 3

1. **Q01 -- keep 1A, and close the structural-failure branch.** Add `blocked`
   to each probe-status domain, meaning the structural observation failed before
   probe applicability could be established. `skipped` remains legal only when
   successful structure proved `has_dynamic: no` or `has_interp: no`; `failed`
   remains legal only when the probe ran without answering. On structural
   failure, clear every other tuple field and set both probe statuses to
   `blocked`. This fully defines every tuple without manufacturing evidence or
   leaving stale state.

2. **Q02 -- agree with 2A.** Eager structure and evidence-based probe
   short-circuiting remain correct. The `blocked` status is not another
   short-circuit: it records that structure prevented the decision.

3. **Q03 -- agree with 3A.** The matrix and immutable case/final-disposition
   split are now correct. Make the Q01 statuses map to it explicitly:
   structural inconclusive plus blocked probes fails both axes; an axis probe
   failure affects only its axis; a write failure preserves the assigned case.

4. **Q04 -- keep 4D after replacing the schematic grammar with a closed wire
   grammar.** Use space-free wire enums, for example `not-dynamic`,
   `already-correct`, and `not-applicable`, while retaining the human phrases
   in prose. Prefer named fields so order and meaning are visible, for example
   `case=5 rpath=failed interp=unchanged path=<raw-byte-hex>`. Spell out every
   trailer count for the five rpath dispositions, four interpreter dispositions
   and two migration figures. Constrain case to 1 through 7 and counts to
   unsigned decimal. Close run state/reason to `completed/none` and
   `skipped/patchelf-absent`, and require all other pairings to be rejected.
   Hex-encode raw pathname bytes, not purported UTF-8, so the non-UTF-8 claim is
   true.

5. **Q05 -- agree with 5A.** No change is needed.

6. **Q06 -- agree with 6A's three layers.** State that the internal contract is
   the named tuple fields, not the `CPLX-ELF/1` stream. Controlled tests call the
   classifier with those fields; fixture tests call the observer and assert
   them; integration additionally consumes the post-classification records.
   The concrete Bash transport and fixture construction remain plan details.

7. **Q07 -- keep 7A with a zero-program-header branch.** When `e_phnum == 0`,
   accept the absence of a program-header table without requiring
   `e_phentsize == 56`; establish no dynamic section and no interpreter, and
   skip both probes. When ordinary `e_phnum > 0`, require the ELF64 entry size
   and existing bounds. Keep `PN_XNUM` outside the domain. Add deterministic
   fixtures for the zero-table case and a truncated ELF header/read, alongside
   the now guard-complete matrix. The GNU `find` size source remains valid.

8. **Missing questions.** No separate Q08 is needed. The live changes complete
   the selected interfaces inside Q01, Q04, Q06 and Q07; they do not change any
   selected answer.

### Requested changes for design-specification relocation-force-rpath round 3

Requested changes: 1. Define probe status on structural failure and reserve `skipped` for the two
   positively established inapplicable cases.
2. Replace Q04's space-ambiguous placeholder grammar with closed wire enums and
   explicit trailer fields, state/reason pairs and raw-byte path encoding.
3. State that observer fixtures assert the internal named tuple fields rather
   than an unstated serialized tuple.
4. Accept the valid `e_phnum == 0` no-table branch and exercise it, plus a
   truncated ELF header, in Q07's fixture matrix.
5. Correct the remaining stale status name and UTF-8 pathname wording.

### Writer instructions for design-specification relocation-force-rpath round 3

Revise the design and publish another automated review round.

1. Add `blocked` to both probe-status vocabularies and define the complete
   structural-failure tuple. Reserve `skipped` exclusively for positive
   structural evidence of probe inapplicability, and clear all unusable fields
   per object.
2. Replace Q04's placeholder grammar with literal, closed, space-free wire
   tokens and every named trailer count. Define valid run-state/reason pairs,
   numeric constraints, and raw-path-byte hex encoding. Keep the human
   disposition labels separate from their wire tokens.
3. Clarify that the normalized tuple is an internal named-field contract used
   directly by classifier and observer tests; it is not serialized through the
   post-classification record stream. Leave the Bash carrier and fixture
   construction mechanics to the plan.
4. Make the program-header validation conditional: accept `e_phnum == 0` as no
   table, and require `e_phentsize == 56` and table bounds only for ordinary
   nonzero counts. Add zero-table and truncated-header fixtures.
5. Apply the small consistency edits: use `structural_status` where one stale
   `status` name remains, and encode raw pathname bytes rather than claiming
   every filename is UTF-8.

Keep answers 1A, 2A, 3A, 4D, 5A, 6A and 7A. These repairs close their wire and
failure semantics; they do not reopen the settled classifier or requirement.

### Final reviewer decision for design-specification relocation-force-rpath round 3

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-08-16T21:38:11+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for design-specification relocation-force-rpath round 4

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
Review round: 4

### Requestor assessment for design-specification relocation-force-rpath round 4

Round 4. All five round 3 requested changes are applied, none disputed. Answers
remain 1A, 2A, 3A, 4D, 5A, 6A, 7A. Two of the findings were implementable
counterexamples rather than rough wording, and both are worth naming exactly.

The wire grammar was ambiguous on its own current vocabularies. It declared every
field single-space separated and positional, and three of the settled
dispositions are `not dynamically linked`, `already correct` and `not
applicable`. So a record was already unparseable, not merely fragile against a
future vocabulary change. The writer's own round 3 assessment had flagged the
space property as "true of the current vocabularies but not enforced by the
grammar", which was itself wrong: it was not true of them either. The grammar is
now `name=value` with closed space-free wire tokens, deliberately kept as a
second vocabulary distinct from the prose labels, since prose that reads well
contains spaces and a wire format that borrows it inherits them.

The ELF reader rejected a valid shape. Its `e_phentsize` check was
unconditional, and the specification defines `e_phnum == 0` as a file with no
program header table, where no entry exists whose size could be checked. That
object is now observed successfully as no dynamic section, no interpreter, both
probes skipped, reaching case 2, and its fixture sits in the accepted class
rather than the rejected one. This is the direction of error the design had not
considered: a validation chain can be wrong by being too strict, and the report
would have shown a lawful object and a malformed one identically.

The other three:

1. `blocked` is added to both probe-status vocabularies, for the branch where
   the structural read failed before applicability could be established. The
   structural-failure tuple is now fully defined rather than "not touched":
   every other field is cleared and both probes are `blocked`. That wording
   mattered more than it looked, because in a shell loop "not touched" is
   exactly how the previous object's reading becomes this object's evidence.
   `skipped` is reserved to its two producers, `has_dynamic: no` and
   `has_interp: no`, so it always means "there is nothing to read" rather than
   "we did not look".
2. The normalized tuple is stated as an internal named-field contract. The
   classifier tests supply those fields at the callable boundary, the observer
   fixtures assert them, and only the integration layer consumes the
   `CPLX-ELF/1` stream, because that stream carries dispositions rather than
   observations and would be the wrong thing to compare a fixture against. The
   three-layer table now names each layer's assertion target.
3. Path bytes are encoded as raw bytes rather than as purported UTF-8, since a
   Linux pathname is a byte string that need not be valid UTF-8 and the claim
   was untrue for exactly the filenames the encoding exists to survive. The one
   stale `status` name is now `structural_status`. The trailer's `state`/`reason`
   pair is closed to two valid combinations, with any other rejected, so a later
   skip producer owes a new token and a review.

What round 4 should look at:

- The `blocked` status and the clearing rule express the same guarantee twice,
  once as a value and once as a rule. Q01's option 1B, a tagged union, was
  considered and rejected because shell has no such type, so the guarantee rests
  on discipline either way. If the reviewer thinks one of the two should carry it
  alone, this is the round to say so.
- The design now carries two vocabularies for the same nine dispositions, prose
  and wire. The mapping table is the only thing keeping them in step, and nothing
  enforces it.
- The zero-table branch is accepted on the specification rather than on an
  observation that the archive contains such an object. That is the right
  direction, since accepting a valid shape needs no evidence that one is present,
  but it does mean the fixture is the only place it will ever be exercised unless
  the real tree happens to hold one.
- Interface specification has now been added in three consecutive rounds. Round 3
  judged the amount appropriate and drew the line at what is consumed outside the
  implementation. The writer has held that line and would rather it were checked
  again than assumed to still hold.

### Change summary for design-specification relocation-force-rpath round 4

Changes to `docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md` since round 3,
applying round 3's five requested changes.

Design Area 1, the observation:

- Both probe-status domains gain `blocked`, so each is `ok`, `skipped`,
  `blocked`, `failed`.
- The tuple table is followed by a new paragraph stating that the tuple is an
  internal named-field contract used directly by the classifier and its tests,
  never serialized, and that the `CPLX-ELF/1` stream carries dispositions rather
  than observations.
- The status subsection now defines all four probe values one by one, names the
  two and only two producers of `skipped`, and replaces "does not touch the
  probe statuses" with the full structural-failure tuple: every other field
  cleared, both probes `blocked`, both values absent, with the reason stated,
  that "not touched" in a shell loop is how a previous object's reading survives.
- The domain subsection splits its validation list in two. Identification and
  the presence of the whole ELF header apply unconditionally, and a new bullet
  covers a file long enough for the four magic bytes the walk checks but shorter
  than the header the observer reads. `e_phentsize`, table bounds, per-header
  bounds, dynamic entry size and `DT_NULL` termination apply only when `e_phnum`
  is nonzero.
- A new paragraph states that a file with no program header table is valid and
  accepted, observed as `has_dynamic: no`, `has_interp: no`, `tag_state: none`,
  both probes `skipped`, reaching case 2.
- The stale `status: inconclusive` reference is now `structural_status`.
- The fixture matrix gains the zero-table object in the **accepted** class and a
  too-short-for-the-header file in the bounds class, with a sentence on why the
  zero-table fixture is in the accepted class: an unconditional entry-size check
  would have put it in the other.
- The matrix paragraph now says fixtures assert the internal named tuple fields,
  and that nothing compares record-stream text against an expected observation.

Design Area 3, the report:

- The schematic grammar is replaced by a literal one. The `obj` record is
  `case=`, `rpath=`, `interp=`, `path=`; the `end` trailer names `state`,
  `reason`, `walked` and all eleven counts explicitly, five `r-`, four `i-` and
  two `mig-`.
- A wire-token table maps each axis's space-free tokens to the human labels used
  in prose, with the reason: three settled dispositions contain spaces, so the
  human labels would make a record ambiguous immediately.
- Field lookup is by name rather than by position, so a later schema may add a
  field without moving the others.
- `path` is defined as the raw bytes of the prefix-relative path in lowercase
  hexadecimal, with the UTF-8 claim removed and the reason stated.
- `state`/`reason` is closed to `completed`/`none` and
  `skipped`/`patchelf-absent`, with any other pairing rejected and a later skip
  producer owing a new token.
- Counts are unsigned decimal and always present, so an absent field is never
  confused with a zero one.

Design Area 5, validation:

- The three-layer table gains an "asserts on" column: the assigned case for the
  classifier layer, the named tuple fields for the observer layer, and the
  post-classification records for integration, followed by a sentence stating
  that only the third consumes the stream.

Acceptance cases:

- The unparseable-header row now names the cleared tuple and both probes
  `blocked`.
- Three rows added: an `e_phnum == 0` object observed successfully and reaching
  case 2; a file long enough for the magic bytes but shorter than the header; and
  a disposition written as its wire token rather than its prose label.
- The path row now covers a byte that is not valid UTF-8 and says why raw bytes
  are what make the claim true.

Open questions, replaced as a whole:

- Q01 rewritten around the four probe statuses and the clearing rule, gaining
  option 1B, a tagged union, recorded and rejected because shell has no such
  type. Q02 and Q05 carried. Q03's option 3C is now explicitly redundant, since
  `blocked` records that fact on the probe status where the observation reports
  what it did. Q04's option 4D carries the literal grammar, the wire-token
  distinction and the closed state/reason pair. Q06's option 6A names each
  layer's assertion target. Q07's option 7A carries the conditional validation
  branch and the zero-table acceptance.
- Answers unchanged at 1A, 2A, 3A, 4D, 5A, 6A, 7A.

### Writer response for design-specification relocation-force-rpath round 4

Writer response: All five requested changes are applied. Nothing is disputed.

The grammar defect is the one the writer should have caught, and the record shows
why it was not. In the round 3 assessment the writer flagged that "no field can
contain a space" was a property of the current vocabularies rather than something
the grammar enforced, and offered it for review. That flag was half right in the
worst way: it identified the right property and asserted the wrong thing about
it. The dispositions were sitting three sections above, `not dynamically linked`
among them, and checking the claim against them would have taken one look. The
writer flagged a risk instead of testing an assertion.

The `e_phnum == 0` finding is a kind of error the design had not been looking
for. Every earlier round pushed toward stricter reading, and the writer built the
validation chain in that direction without asking which of its checks are
conditional. A chain that rejects a lawful object reports it identically to one
that rejects a malformed object, so strictness bought nothing there and cost a
valid shape. The zero-table fixture is deliberately filed under accepted rather
than rejected, so the matrix records that the check is conditional rather than
absent.

On `blocked` the writer accepts both halves. The value was missing, and the
phrase it replaces, that a structural failure "does not touch" the probe
statuses, was worse than an omission in this context: shell variables persist
across loop iterations, so "not touched" is a mechanism for carrying the previous
object's reading forward, not a neutral silence. Option 1B, a tagged union, is
recorded as considered and rejected, because the language has no such type and
the guarantee would reduce to the same clearing discipline with a harder test
boundary.

The tuple boundary clarification is accepted as stated and is smaller than the
writer had feared: one sentence in Design Area 1 and one column in the layer
table. The writer had been prepared to specify a serialization and is glad not
to have, since the record stream carries dispositions and would have been the
wrong artifact to compare a fixture against.

Four things are offered for round 4 rather than claimed as settled. `blocked` and
the clearing rule express one guarantee twice, and the writer chose both
deliberately but would accept one. The design now carries two vocabularies for
nine dispositions, kept in step only by a table. The zero-table branch is
accepted on the specification rather than on evidence that the archive contains
such an object, which is the right direction but leaves the fixture as its only
exercise. And interface specification has grown in three consecutive rounds;
round 3 judged the amount appropriate and drew the line at what is consumed
outside the implementation, and the writer has held that line rather than
re-drawn it.

### Reviewer focus for design-specification relocation-force-rpath round 4

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-08-16T21:55:08+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for design-specification relocation-force-rpath round 4

Round 3's five requested changes are substantively applied, and answers 1A,
2A, 3A, 4D, 5A, 6A and 7A remain the right choices. The `blocked` value and
the clearing rule are complementary rather than redundant: the status records
why no probe answer exists, while clearing makes stale evidence impossible in
the shell representation. The accepted zero-program-header fixture is also the
right evidence even if the archive contains no such object, and the current
design/plan boundary remains appropriate.

Round 4 is nevertheless `changes-requested`, because the now-external report
contract still admits captures that satisfy every invariant it states while
misreporting the run. The design requires only that each axis's trailer counts
sum to `walked` and that `walked` equal the number of `obj` records. A capture
whose 388 object records all say `rpath=failed` can therefore claim
`r-rewritten=388 r-failed=0` and pass both stated checks. The requirement's
load-bearing migration equality is absent from the stream invariants too: a
capture may contain case-5 records and report `mig-checked=0`. The design prose
says the checked figure counts case-5 membership, but the retained recipe has
not been told to verify it.

Keep 4D, but make reconciliation categorical rather than aggregate. For every
rpath and interpreter wire token, the corresponding trailer count must equal
the number of object records carrying that token. `walked` must equal the
number of object records, `mig-checked` must equal the number with `case=5`, and
`mig-failed` must be no greater than `mig-checked`; the dedicated predecessor
run additionally requires that equality to be positive and failures zero. A
`skipped/patchelf-absent` trailer must have no object records and every numeric
field zero. These checks make the report evidence for what its records say,
not merely a collection of totals having the right sum.

The lexical grammar also leaves two implementers with different valid `/1`
readers. It calls the schema closed, but says named lookup lets a later schema
add a field, without deciding whether an unknown field in a `CPLX-ELF/1`
record is accepted. It does not reject duplicate names either. Freeze `/1`:
each record kind carries each listed field exactly once and no others; missing,
duplicate and unknown fields are rejected, and additions use a new schema
marker. This is the natural consequence of already rejecting an unknown
marker, and it prevents a duplicate such as `rpath=failed rpath=rewritten`
from being interpreted differently by first-wins and last-wins readers.

The pathname base must be fixed as well. `fix_elf_paths` walks
`$DEST_PATH`, which is `$INSTALL_PREFIX/tools`, while the grammar calls `path`
relative to the installation prefix and its example decodes to `lib/foo.so`
rather than `tools/lib/foo.so`. Specify the walked root (`$DEST_PATH`) as the
base, with no leading slash or `./`, and require an even-length lowercase hex
value for the non-empty relative pathname. Alternatively retain
`$INSTALL_PREFIX` as the base and repair the example and every expected-set
path, but the walked root is the smaller and more direct contract. The stale
acceptance example `end skipped patchelf-absent 0 ...` must use the named wire
form too.

Q06 now needs the check the requestor explicitly identified as absent: a
schema-contract test over the formatter and retained-output reader. Exercise
all nine wire tokens and their human mappings, all required fields, categorical
and migration reconciliation, and representative rejected forms (unknown,
missing or duplicate fields; bad token; malformed path hex; invalid
state/reason; inconsistent totals). This can be stated as the report-contract
part of 6A rather than a new Q08. Exact parser implementation and fixture bytes
still belong in the plan.

These are observable interface and acceptance changes, not wording-only polish,
so another automated round is required. No settled classifier, ELF-domain or
transport choice is reopened.

### Question verdicts for design-specification relocation-force-rpath round 4

1. **Q01 -- agree with 1A.** Keep both `blocked` and the clearing rule. They
   state different parts of one guarantee: `blocked` is the observer's reason
   visible to consumers, while clearing is the representation invariant that
   prevents a previous loop iteration from supplying values. A tagged union
   would still require conventional shell discipline and gives no stronger
   executable boundary here.

2. **Q02 -- agree with 2A.** Eager structure and evidence-based probe skipping
   remain the only model consistent with the ordered classifier and independent
   interpreter axis.

3. **Q03 -- agree with 3A.** The status-to-axis fault mapping is complete and
   the immutable case/final-disposition split remains necessary.

4. **Q04 -- keep 4D, but finish the `/1` contract.** Require each field for a
   record kind exactly once and reject missing, duplicate or unknown fields;
   additions require a new schema marker. Define `path` relative to the walked
   root (`$DEST_PATH`), canonically without a leading slash or `./`, as
   non-empty even-length lowercase hex. Reconcile each trailer disposition
   count against the matching object records, not only the axis sum; require
   `mig-checked == count(case=5)` and `mig-failed <= mig-checked`; and require a
   skipped trailer to have no objects and all numeric fields zero. Keep the two
   vocabularies, with their table normative and every mapping exercised. These
   rules remove ambiguity without returning to prose tokens.

5. **Q05 -- agree with 5A.** Exact-current-value migration remains identical to
   the predecessor promise.

6. **Q06 -- keep 6A and add report-contract coverage.** The three semantic
   layers correctly isolate classifier, observer and real-tree behavior. The
   external stream also needs formatter/reader contract tests covering every
   wire token and mapping, valid categorical and migration totals, and
   rejection of malformed or inconsistent `/1` records. That can be a
   contract sublayer beside the existing three; it does not change what the
   observer fixtures assert.

7. **Q07 -- agree with 7A.** The conditional `e_phnum == 0` branch and accepted
   fixture are correct. A deterministic accepted fixture is sufficient proof
   that the reader implements a lawful shape; the archive need not happen to
   contain one.

8. **Missing questions.** No new Q08 is necessary. Q04 already owns the report
   interface and Q06 owns validation. Completing those answers covers the live
   decisions without creating a second question about the same stream.

### Requested changes for design-specification relocation-force-rpath round 4

Requested changes: Requested changes:

1. Close `/1` field cardinality, unknown-field behavior and canonical path-base
   semantics, and fix the stale positional example.
2. Reconcile every trailer category to object records and restore the required
   case-5/migration-count equality, including skipped-run constraints.
3. Add exhaustive formatter/reader contract validation for the dual
   vocabularies and malformed or internally inconsistent records.

### Writer instructions for design-specification relocation-force-rpath round 4

Revise the design and publish another automated review round.

1. Complete the `CPLX-ELF/1` lexical contract: every listed field occurs
   exactly once, missing/duplicate/unknown fields are rejected, and field
   additions require a new marker. Define the pathname relative to
   `$DEST_PATH`, with its canonical relative form and hex constraints, and
   repair the stale positional acceptance example.
2. Replace aggregate-only reconciliation with categorical reconciliation:
   each trailer disposition count equals the matching object-record count,
   `walked` equals the object-record count, `mig-checked` equals the case-5
   record count, and `mig-failed` cannot exceed it. A skipped pass has no
   objects and all numeric fields zero; the dedicated migration run requires a
   positive checked equality and zero failures.
3. Extend Q06/Design Area 5 with report-contract validation over the formatter
   and retained-output reader. Cover all nine wire/human mappings plus missing,
   duplicate and unknown fields, bad tokens and path hex, invalid state/reason
   pairs, and inconsistent categorical or migration totals. Leave concrete
   parser mechanics and fixture bytes to the plan.
4. State that `blocked` plus clearing is intentional and complementary, that
   the accepted zero-table fixture does not require a matching archive object,
   and keep the existing external-interface design boundary.

Keep answers 1A, 2A, 3A, 4D, 5A, 6A and 7A. No Q08 is needed and no settled
classifier, observer-domain or transport decision is reopened.

### Final reviewer decision for design-specification relocation-force-rpath round 4

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-4 -->

## Round 5 by requestor

- Recorded: 2026-08-16T22:09:41+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for design-specification relocation-force-rpath round 5

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
Review round: 5

### Requestor assessment for design-specification relocation-force-rpath round 5

Round 5. All four round 4 requested changes are applied, none disputed. Answers
remain 1A, 2A, 3A, 4D, 5A, 6A, 7A.

The finding that mattered is a counterexample against the invariants this design
called the reason the report exists. Reconciliation was stated as two aggregate
properties, each axis summing to `walked` and `walked` equalling the record
count. A capture of 388 object records all reading `rpath=failed`, with a
trailer claiming `r-rewritten=388 r-failed=0`, satisfies both. The arithmetic is
right and every category is wrong, which is the one shape a report exists to
make impossible. The writer had described the aggregate property as making the
stream "checkable rather than merely readable", and it did not.

Reconciliation is now categorical. Nine per-token equalities, each trailer count
against the number of records carrying that token on that axis; `walked` against
the record count; and `mig-checked` against the number of `case=5` records,
which turns the requirement's migration equality into an invariant the recipe
verifies rather than a sentence the prose asserts. `mig-failed` cannot exceed
`mig-checked`, a `state=skipped` trailer carries no records and all-zero counts,
and the dedicated predecessor run still requires a positive checked count and
zero failures.

The other three:

1. `/1` is frozen. Each record kind carries each listed field exactly once and
   no others; missing, duplicate and unknown fields are rejected; an addition
   uses a new marker. The design had said the schema was closed and, two bullets
   later, that named lookup let a later schema add a field, which is the
   tolerance a closed schema forbids. The concrete cost of leaving it was a
   record like `rpath=failed rpath=rewritten`, on which a first-wins and a
   last-wins reader disagree about the run and neither is wrong.
2. `path` is based on the walked root `$DEST_PATH` rather than the installation
   prefix. This resolved a disagreement inside the design: the prose named one
   base while the example decoded under the other, so `lib/foo.so` and
   `tools/lib/foo.so` were both defensible readings of the same record. The
   walked root is the smaller contract and is what `fix_elf_paths` is actually
   given. The canonical form carries no leading `/` or `./`, is never empty, and
   is even-length lowercase hex.
3. Q06 gains a report-contract sublayer over the formatter and the
   retained-output reader, covering all nine wire tokens with their prose
   mappings, every required field, the categorical and migration equalities, and
   the rejected forms. It is a sublayer rather than a fifth semantic layer,
   since it asserts nothing about which case an object belongs to.

Two points round 4 confirmed rather than changed are now written into the design
rather than left implicit: that `blocked` and the clearing rule are
complementary, the status being the observer's reason and the clearing being the
representation invariant, neither sufficient alone; and that the accepted
zero-table fixture does not depend on the archive containing such an object,
since a deterministic fixture proves the reader implements a lawful shape where
waiting for the tree would make the check a matter of luck.

What round 5 should look at:

- The categorical rule adds nine equalities the reader must implement, against
  two before. That is the correct trade, but it is worth confirming that the
  design states them as the reader's obligation rather than as properties the
  formatter happens to produce.
- The stale positional example in the acceptance table is repaired, and the
  writer has looked for others; the acceptance table now uses the named form
  throughout. A second reading for stale wire syntax would be welcome, since
  this is the second round in which an example lagged its own grammar.
- The report-contract sublayer covers rejected forms, which means the validation
  now depends on being able to construct malformed captures. That is easier than
  malformed ELF fixtures and is not called out as an artifact anywhere.
- The design has now specified an external wire contract across four rounds. The
  writer continues to hold the boundary round 3 drew, at what is consumed
  outside the implementation, and notes that the categorical rules are the first
  additions that constrain the reader rather than the writer.

### Change summary for design-specification relocation-force-rpath round 5

Changes to `docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md` since round 4,
applying round 4's four requested changes.

Target behavior sketch:

- The report line no longer says each axis sums to the walked count. It now says
  one record per object plus a trailer whose every figure reconciles against the
  records that carry it.

Design Area 1, the observation:

- A paragraph was added stating that `blocked` and the clearing rule are
  complementary and both deliberate: the status is the observer's reason visible
  to consumers, the clearing is the representation invariant that makes stale
  shell values impossible, and either alone leaves a gap.
- The zero-table fixture paragraph now states that the fixture does not depend
  on the archive containing such an object, with the reason.

Design Area 3, the report:

- The `obj`/`end` bullet now freezes `/1`: each listed field exactly once, no
  others, with missing, duplicate and unknown fields rejected and additions
  requiring a new marker. The earlier clause about a later schema adding a field
  under the same marker is removed, and the `rpath=failed rpath=rewritten`
  first-wins versus last-wins case is named.
- The `path` bullet changes base from the installation prefix to the walked root
  `$DEST_PATH`, states why that base was chosen, requires the canonical relative
  form without a leading `/` or `./`, requires it non-empty, and notes that the
  raw-byte hex is therefore always of even length.
- The "Reconciliation is the property the report exists for" subsection now
  refers forward to the categorical rules instead of stating the aggregate sum.
- The two-invariant list is replaced by a new subsection, "Reconciliation is
  categorical, not aggregate", which opens with the counterexample, then states
  the nine per-token equalities, `walked` against the record count,
  `mig-checked` against the case 5 record count, `mig-failed` bounded by it, the
  skipped-run constraints, and the one-trailer rule.

Design Area 5, validation:

- A new subsection adds the report-contract sublayer over the formatter and the
  retained-output reader, in a table covering vocabularies, required fields,
  categorical totals and rejected forms, followed by a paragraph on why it is a
  sublayer rather than a fifth semantic layer.

Acceptance cases:

- The stale positional example `end skipped patchelf-absent 0 ...` is replaced
  with the named form.
- Six rows added: a trailer claiming `r-rewritten=388` over 388 `rpath=failed`
  records, rejected by categorical reconciliation where an aggregate sum would
  accept it; a trailer with `mig-checked=0` over a capture containing `case=5`
  records; a `state=skipped` trailer with a nonzero count or an object record; a
  record with a duplicated field; a record with an unlisted field; and a `path`
  decoding under the walked root.

Open questions, replaced as a whole:

- Q01 gains the complementary statement about `blocked` and clearing in its
  option and answer. Q02, Q03 and Q05 carried, with Q03's option 3C now noted as
  redundant against `blocked`. Q04's option 4D carries the categorical
  reconciliation, the frozen `/1` and the walked-root path base, and its BBQ is
  rewritten around the stocktake sheet whose totals add up while every category
  is wrong. Q06 is retitled to cover the stream as well and gains the
  report-contract sublayer in option 6A, with option 6B restated as three
  semantic layers only so the uncovered interface is recorded. Q07 gains the
  fixture-independence point.
- Answers unchanged at 1A, 2A, 3A, 4D, 5A, 6A, 7A.

### Writer response for design-specification relocation-force-rpath round 5

Writer response: All four requested changes are applied. Nothing is disputed.

The reconciliation counterexample is the most useful finding of this exchange,
because the defect was in the part of the design the writer was most confident
about. The stream was introduced with the claim that reconciliation is "the
property the report exists for", and the property actually written down was
arithmetic: totals that add up. A capture can add up perfectly and describe the
opposite run. The writer had even chosen two axes partly so a validator would
get "two independent reconciliations", without noticing that two aggregate sums
of the same permuted counts are not independent evidence of anything.

The general shape is one the writer should now recognize, since round 3 produced
it too. In both cases a property was asserted about a structure rather than
checked against it: that no disposition contained a space, and that summing the
counts proved the categories. Both were one comparison away from being tested.

Freezing `/1` closes a contradiction the writer introduced in the same bullet
list: the schema was called closed, and two bullets later named lookup was said
to let a later schema add a field without moving the others. Those cannot both
hold, and the second was written as a convenience argument for `name=value` over
positional fields, which the format does not need since its real advantage is
that a filename cannot break it.

The path base is a smaller correction with the same origin. The design named the
installation prefix and its example decoded to `lib/foo.so`, which is only right
under the walked root. Two readings of one record were defensible, and the
expected-set paths would have inherited whichever the implementer chose.

The report-contract sublayer is accepted as the gap the writer had itself named
and then not closed. In round 4 the assessment offered "nothing enforces the
mapping table" as a thing to look at; the right response would have been to
extend the validation architecture rather than to flag it and move on. That is
the same pattern as the space claim: noticing a weak spot and reporting it
instead of fixing it.

Four things are offered for round 5 rather than claimed as settled. The
categorical rules are stated as the reader's obligation, and it is worth
confirming they read that way rather than as properties the formatter happens to
produce. The acceptance table now uses the named wire form throughout, and a
second reading for stale syntax would be welcome since this is the second round
where an example lagged its own grammar. Validating the rejected forms means
constructing malformed captures, which is not named as an artifact anywhere. And
the wire contract has grown across four rounds; the writer has held the boundary
round 3 drew and notes that the categorical rules are the first additions
constraining the reader rather than the writer.

### Reviewer focus for design-specification relocation-force-rpath round 5

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-5 -->

## Round 5 by reviewer

- Recorded: 2026-08-16T22:25:34+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for design-specification relocation-force-rpath round 5

Round 4's requested changes are substantively applied. Answers 1A, 2A, 3A,
4D, 5A, 6A and 7A remain the right choices, no question is missing, and no
implementation decision remains open. Round 5 is `convergence-recommended`
after the covered wording edits below.

The categorical rules read as obligations on the retained-output reader, not
merely promises made by the formatter. Design Area 5 explicitly checks both
ends and lists inconsistent totals among the rejected forms. One normative
sentence saying that the reader rejects every violation will make that boundary
impossible to miss, but it does not change the selected interface.

Malformed captures do not need a new design-level artifact or lifecycle. They
are deterministic inputs to the report-contract check, analogous to table
cases rather than deployed evidence. Whether the plan constructs them inline
or retains fixture files is an implementation choice already covered by the
statement that parser mechanics and fixture bytes belong in the plan.

The second syntax reading found no remaining positional field syntax, but it
did find one example that is grammatically current and semantically stale. The
main code block shows one `case=5` object and immediately follows it with a
trailer containing `mig-checked=0`; it also shows `walked=388` without marking
the other 387 object records as omitted. Read as the complete capture the text
now says it is, the example violates both categorical rules it introduces.
Replace it with the supplied one-object, internally consistent capture. The
acceptance table's abbreviated `end ...` example should be prose rather than a
wire fragment, and its final aggregate-sum row should name categorical
comparison instead. These are example/wording repairs, not another report
design.

One review-relative sentence is stale too: Design Area 5 says the observer
fixture layer is "the one this round adds", although it predates the current
round and the report-contract sublayer is the latest addition. Remove the time
reference and retain the durable reason that the observer layer is easy to
omit.

With those edits, the stream has a closed lexical grammar, canonical path
identity, categorical reader reconciliation, the requirement's migration
equality, and explicit formatter/reader validation. The status model,
classifier, migration bound, ELF domain and validation ownership are all
settled. Further review would be polishing the same interface rather than
resolving an implementation choice.

### Question verdicts for design-specification relocation-force-rpath round 5

1. **Q01 -- agree with 1A.** `blocked` and clearing are complementary and the
   current answer states their distinct roles correctly.

2. **Q02 -- agree with 2A.** Eager structure with evidence-based probe skipping
   remains the only implementable choice.

3. **Q03 -- agree with 3A.** The fault-to-axis mapping and immutable case are
   complete.

4. **Q04 -- agree with 4D.** The frozen `/1`, walked-root paths, closed tokens
   and categorical equalities now define one implementable reader contract.
   State explicitly that the reader rejects any capture violating a grammar or
   reconciliation rule, and repair the self-inconsistent example, but neither
   edit changes 4D.

5. **Q05 -- agree with 5A.** The recognition rule remains exactly as bounded by
   the requirement.

6. **Q06 -- agree with 6A.** The report-contract sublayer closes the formatter/
   reader gap. Malformed captures are ordinary deterministic test inputs; their
   inline-versus-retained representation belongs in the plan and does not need
   a new design artifact decision.

7. **Q07 -- agree with 7A.** The accepted zero-table fixture is sufficient
   independent evidence of the supported lawful shape.

8. **Missing questions.** None. The four points offered for round 5 resolve as
   confirmations or covered wording; none introduces a materially distinct
   option.

### Convergence evidence for design-specification relocation-force-rpath round 5

Covered wording: Covered wording edits:

1. Replace the stream example with this complete, self-consistent capture (the
   trailer remains one physical line in emitted output):

   ```txt
   CPLX-ELF/1 obj case=5 rpath=failed interp=unchanged path=6c69622f666f6f2e736f
   CPLX-ELF/1 end state=completed reason=none walked=1 \
     r-rewritten=0 r-failed=1 r-already-correct=0 r-not-dynamic=0 r-excluded=0 \
     i-rewritten=0 i-failed=0 i-unchanged=1 i-not-applicable=0 \
     mig-checked=1 mig-failed=0
   ```

2. Open the categorical subsection with: "The retained-output reader MUST
   reject a capture that violates any `/1` grammar or reconciliation rule
   below; the formatter MUST emit captures satisfying the same rules."

3. In the report-contract rejected-forms row, add a path whose decoded value
   begins with `/` or `./`, and a skipped trailer with an object or nonzero
   numeric field.

4. Replace the abbreviated skipped/completed acceptance wire fragments with
   prose referring to two valid `/1` trailers, each carrying every required
   numeric field as zero. Replace "Summing either axis" with "Comparing every
   disposition trailer field with the object records carrying its token" and
   state that all nine equalities hold.

5. Replace "The middle layer is the one this round adds" with "The observer-
   fixture layer is the one this design would most easily omit" while retaining
   the explanation about states a real archive should not contain.

Convergence rationale: Convergence is recommended because every in-scope decision now has one selected,
implementable answer and the remaining edits only make examples and normative
wording agree with the already-settled contract. The reviewer found no missing
question, no requirement drift, and no unresolved artifact lifecycle. The
covered edits alter neither behavior nor validation scope: they repair an
inconsistent sample capture, make the reader's existing rejection duty
explicit, and remove stale shorthand and review-relative phrasing.

### Writer instructions for design-specification relocation-force-rpath round 5

Apply the covered wording edits before consolidation. They do not reopen any
selected answer:

1. Replace the inconsistent illustrative stream with the supplied complete
   one-object capture.
2. Say explicitly that the retained-output reader rejects any capture that
   violates a `/1` grammar or reconciliation rule.
3. Turn the abbreviated acceptance-table trailer fragment into prose, replace
   the final aggregate-sum wording with categorical reconciliation, and add
   decoded leading `/` or `./` paths to the contract's rejected forms.
4. Remove the stale "this round adds" phrase from the observer-fixture layer.
5. Keep malformed-capture construction and fixture storage as plan details; no
   new design artifact or Q08 is required.

Keep answers 1A, 2A, 3A, 4D, 5A, 6A and 7A. After these wording-only repairs,
the design is ready for authorized consolidation.

### Final reviewer decision for design-specification relocation-force-rpath round 5

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-5 -->

## Round 5 by human - human-confirmation

- Recorded: 2026-08-16T22:34:58+02:00
- Exchange: specification/design-specification/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.relocation-force-rpath.md
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-5 -->
