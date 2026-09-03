# Specification review transcript for v0.27.0

- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-03T07:34:46+02:00
- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
- Outcome: request

### Review identity for issue toolchain-runtime-closure (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
Review round: 1

### Requestor assessment for issue toolchain-runtime-closure (round 1)

#### Assessment of the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 1)

Eight open questions are placed. The document is a first draft of umbrella item
4, written from the umbrella's item entry and the work item 3 (Q26) sub-tasks 1
and 2 it regroups, and this is its first review.

##### Are the questions sufficient, and are any missing for issue toolchain-runtime-closure (round 1)

The eight cover every part of the document that admits more than one reading:
the definition of completeness (Q01), the consequence of a failing check (Q02),
the ordering conflict with the sqlite payload (Q03), where acceptance is
measured (Q04), the reach of the family rule (Q05), the libssl caveat (Q06),
whether this requirement publishes (Q07), and the open D10 decision the umbrella
deferred here (Q08).

TWO OF THEM ARE NOT ELABORATION PROMPTS BUT CONFLICTS THE DOCUMENT CANNOT
RESOLVE AS WRITTEN, and they are the ones this review should be read for:

- Q03. This issue is umbrella item 4 and requires `libsqlite3.so.0` among the
  enforced members. The payload that supplies it is `python-sqlite-support`,
  umbrella item 6. Enforcing on the day this lands fails every packaging run for
  the span of two requirements; not enforcing hands the rule to a requirement
  that does not exist yet. The umbrella does not mention this collision, and the
  document as written asserts both halves.
- Q01. The document says the check "enumerates the required runtime members"
  without defining that set. A derived `DT_NEEDED` closure cannot see
  `libsqlite3.so.0` missing, because nothing declares it until item 6 compiles
  the extension. Under a derived-only reading the requirement's own headline
  example falls outside its own gate.

Q02 and Q03 are coupled: the waiver mechanism Q02 proposes is what makes Q03's
recommended answer implementable, and a reviewer who accepts one should say what
that implies for the other.

##### Are the options and answers sufficient for issue toolchain-runtime-closure (round 1)

Each question carries three options with at least one pro and one con each, a
recommended option with arguments, and an `Answer to Qxx` line giving the
acceptance reason. Every recommendation is argued from evidence already in the
document or the umbrella rather than from preference:

- Q01 A3 rests on develop#24 proving the derived half currently clean and on
  `libsqlite3.so.0` being invisible to that half;
- Q04 D3 rests on this collection's repeated finding that a gate nobody has seen
  fail is a gate nobody has seen;
- Q08 H3 rests on the umbrella's own D10 wording, which asks for the wheels'
  actual C++ demands to be measured during the rebuild before choosing.

##### What the questions deliberately do NOT ask for issue toolchain-runtime-closure (round 1)

This is an issue document, so no question asks a design or implementation
choice. In particular nothing here asks how the check is built, where its code
lives, what it is written in, or how it is invoked. Q01 and Q05 come closest and
are framed as acceptance definitions, what "complete" and "coherent" mean for
the delivered archive, rather than as mechanisms.

Two further constraints kept questions out of this round:

- the `--force-rpath` work is umbrella item 2, `relocation-force-rpath`, already
  completed. Nothing here re-opens it; the document records it as the settled
  reason the wheel side is closed;
- producing the sqlite payload is item 6 and the rebuild is item 7. Q03 and Q07
  ask where this requirement's boundary sits against those, which is a scope
  question, without asking how either is done.

##### Reviewer wording suggestions applied for issue toolchain-runtime-closure (round 1)

None yet. This is round 1.

##### What this round asks the reviewer to weigh first for issue toolchain-runtime-closure (round 1)

Whether Q03 is a question at all, or a defect in the umbrella's ordering that
should be answered by resequencing rather than by a waiver. The requestor's
recommendation keeps the declared order and adds a named waiver, on the grounds
that this collection has already ruled that an obligation must not be handed to
a requirement that does not exist. A reviewer who reads it as an ordering defect
should say so plainly, because that answer changes the umbrella rather than this
document.

### Change summary for issue toolchain-runtime-closure (round 1)

#### Change summary for the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 1)

##### Round 1: the document is new for issue toolchain-runtime-closure (round 1)

There is no preceding round, so every file below is new in the working tree and
nothing is committed yet.

```text
?? docs/v0.27.0/draft.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
```

Both sit on the item branch `toolchain-runtime-closure`, created from the
umbrella integration branch `debian-agent-tools` at `880f3a9`.

##### What produced each file for issue toolchain-runtime-closure (round 1)

| File | Produced by | From |
| --- | --- | --- |
| `draft.v0.27.0.toolchain-runtime-closure.md` | `process-draft`, umbrella continuation | umbrella item 4's entry and requirement-detail subsection, plus work item 3 (Q26) sub-tasks 1 and 2 and decision D10 |
| `issue.v0.27.0.toolchain-runtime-closure.md` | `write-requirement` | that focused child draft |
| its `## Open questions` section | `review-ask-questions`, placed with `oqm --append` | this round |

##### The document's shape for issue toolchain-runtime-closure (round 1)

Sections, in order: revision history, current behavior, current side effects,
gap analysis, confirmed rules, gap to close, the open D10 decision, the libssl
caveat, concrete examples, code references, an explicit out-of-scope section,
then the eight open questions.

179 lines before the questions were appended.

##### Identity settled before this document was written for issue toolchain-runtime-closure (round 1)

Not decided here, and named so the reviewer can check rather than assume:

- type `issue`, key title, and slug `toolchain-runtime-closure` come from the
  umbrella's canonical table, row 4, settled by `split-and-define`;
- version `v0.27.0` comes from the umbrella filename;
- the effort directory `docs/v0.27.0/` is inherited from the umbrella's parent,
  the `version` layout.

The invocation that reached `write-requirement` named a `feature-request.` path.
That was corrected to `issue.` against the umbrella row, which `process-draft`
forbids editing, so the type is the umbrella's rather than the invocation's.

##### The umbrella is unchanged for issue toolchain-runtime-closure (round 1)

`docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md` is untouched by this round.
Its row 4 still reads `pending` with both document cells `-`; that row is
completed by the implementation check at the end of this requirement, not here.

### Writer response for issue toolchain-runtime-closure (round 1)

Writer response:

#### Writer response for the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 1)

Round 1 of this exchange, so there is no earlier reviewer feedback to accept or
dispute, and no disagreement is recorded.

##### What the writer already reversed on itself for issue toolchain-runtime-closure (round 1)

The umbrella's item 4 detail and its work item 3 carry a correction the draft
and the issue both lead with, because two earlier readings of the same evidence
were wrong and the wrong ones are the memorable ones:

- develop#19 listed `root/usr/lib64` alone and concluded `libgcc_s.so.1` was
  missing and that packaging had dropped it;
- develop#24 listed all eight directories the relocation puts on the rpath and
  found it shipping as `root/lib64/libgcc_s-11-20240719.so.1` under the python
  root and the git root alike.

The issue therefore does NOT ask for a missing library to be found. It asks for
a guarantee. Anything in this round that reads as "restore the dropped library"
is the earlier reading resurfacing and should be refused.

##### Three boundaries this document draws deliberately for issue toolchain-runtime-closure (round 1)

Named because a reviewer could reasonably read any of them as an omission:

1. `--force-rpath` and the wheel side are OUT. They are sub-task 3 of work item
   3, which was umbrella item 2 and is complete. The document records the result
   as settled context and re-opens nothing.
2. Producing the sqlite payload is OUT. That is item 6. This issue only makes
   its arrival enforceable, which is what Q03 is about.
3. Publishing is OUT. That is item 7. Q07 asks whether the repackaged current
   tree is published or only used to exercise the check, and recommends the
   latter with the known divergence recorded as owed.

##### One thing the writer could not settle and did not paper over for issue toolchain-runtime-closure (round 1)

Q03 is a genuine collision between this requirement's content and the umbrella's
declared order, and it was found while writing the document rather than
inherited from it. The umbrella says item 4 enforces `libsqlite3.so.0` and says
item 6 supplies it, and does not say what packaging does in between.

The recommended answer keeps the order and adds a named waiver. The alternative
a reviewer may prefer is to resequence the umbrella so the payload precedes its
enforcement. That would be a change to `draft.v0.27.0.debian-agent-tools.md`,
which is outside this document and outside `process-draft`'s authority, so it
needs to be said explicitly rather than assumed.

##### On D10 for issue toolchain-runtime-closure (round 1)

The umbrella marks D10 open and says to settle it inside this requirement, so
Q08 asks it here rather than deferring it again. The recommendation is not "keep
GCC 11" on its own, which would quietly drop the trigger the umbrella asked this
requirement to carry, but "keep GCC 11 and mandate the measurement that flips
it". If the reviewer reads D10 as a design choice rather than a scope one, the
right outcome is to say where it belongs instead, not to leave it unanswered in
both places.

### Reviewer focus for issue toolchain-runtime-closure (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-03T07:56:30+02:00
- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
- Outcome: answer

### Reviewer assessment for issue toolchain-runtime-closure round 1

The issue has a sound objective and correctly separates packaging enforcement
from the later payload rebuild and publication. Its evidence also supports a
combined declared floor and derived closure. Implementation cannot proceed
from the current wording, however, because three acceptance semantics remain
undefined or internally inconsistent.

First, the rule that every demanded version node must be defined by the
shipped libc is technically false for the document's own examples. `GLIBC_`
nodes are provided by libc, but `GLIBCXX_` and `CXXABI_` nodes are provided by
libstdc++, and `OPENSSL_` nodes by libcrypto. The required invariant is that
each version requirement is satisfied by the shipped object selected for the
corresponding `DT_NEEDED` provider, with no host fallback. A libc-only check
would either reject coherent OpenSSL/C++ pairs or silently ignore their real
provider relationships.

Second, “library family”, “generation”, “consistent pair”, and the scope over
the python and git roots are not defined. The evidence currently mixes two
different conditions: multiple builds of libbfd in one search scope and an
OpenSSL copy in each tool tree. Identical copies in independent tool roots are
not necessarily two generations, while two ABI-major SONAMEs may be an
intentional coexistence. A general refuse rule cannot be implemented or
accepted until those cases have an explicit classification.

Third, D10 remains deferred rather than settled. “Decide at the rebuild” can
become a settled conditional policy, but only if the document names the exact
consumer set, both `GLIBCXX_` and `CXXABI_` comparisons, and the condition that
selects GCC 11 or GCC 12. “Raise the generation when the margin is gone” is
ambiguous between zero headroom and an actually unsupported node.

The eight existing questions are therefore not sufficient. Add questions for
provider-aware version resolution, family/generation identity across search
scopes, and the negative-control matrix for each independent gate. Q01-Q08
remain useful and non-redundant, but several answers need the qualifications
listed below. These are substantive requirement and umbrella changes, so the
disposition is changes-requested.

### Question verdicts for issue toolchain-runtime-closure round 1

- Q01 — not missing or redundant; its three options distinguish intent from
  observed dependency closure. Choose A3, but replace “members whose absence
  is invisible on RHEL” with an explicit committed floor for each tool root or
  shared search scope. Name every initial member, including the transitional
  `libsqlite3.so.0` entry, and state which later requirement may add or remove
  an entry. Otherwise the acceptance contract remains unknowable.

- Q02 — not redundant, and the stop/report distinction is necessary. Choose
  B3 only with a bounded exception contract: the waiver identifies exactly one
  member, its owning requirement, and its removal condition; unknown or stale
  waivers fail; and an artifact produced while any waiver is active is
  validation-only and cannot cross the publication boundary. The current claim
  that B3 keeps an incomplete archive “unpublishable” is unsupported without
  that last rule.

- Q03 — not redundant; it exposes a real ordering transition. Choose C3 rather
  than resequencing. Installing the checker before the expensive sqlite build
  lets that build be checked on its first packaging pass. Record in both this
  issue and the umbrella that item 6 removes the exact sqlite waiver and that
  item 7 cannot publish while any waiver remains. This is a deliberate
  hand-off with a machine-checkable exit, not an unowned promise.

- Q04 — not redundant; the host choices have distinct evidentiary value.
  Choose D3. Its single “member removed” control is insufficient for the two
  halves selected in Q01 and the other independent gates. Require a positive
  Debian no-host-fallback run and negative controls for at least a missing
  declared-floor member, an unresolved derived `DT_NEEDED`, an unsatisfied
  provider version, a prohibited family/generation collision, and a trace that
  inventories no venv process.

- Q05 — not redundant, but unclear and incomplete. E1-E3 distinguish named
  repairs, reporting, and general refusal; choose E3 only after the missing
  family-identity question is answered. Do not use a filename-stem heuristic.
  Define the resolution scope, how SONAME/ABI generation and paired providers
  are identified, whether byte-identical copies in separate tool roots are
  allowed, and how intentional ABI-major coexistence is represented. A waiver
  should describe an intentional exception, not compensate for an undefined
  classifier.

- Q06 — not redundant; F1-F3 allocate the unresolved evidence differently.
  Choose F2. Because the prerequisite RPATH work is complete and the result
  changes the requirement, perform the re-probe and record its conclusive
  inventory in the next round. If it exposes a real mismatch, revise the
  requirement to own or explicitly allocate that gap; do not retain
  “probably coherent” as settled input.

- Q07 — not redundant; choose G3. Clarify that the current-tree archive is a
  validation artifact and that publication remains item 7. Couple this with
  the Q02/Q03 rule that publication is refused while a waiver is active; merely
  recording a known divergence does not itself prevent accidental delivery.

- Q08 — not redundant, but H3 does not presently settle D10. Choose a rewritten
  H3 as a conditional decision: after the final wheel/dependency set is fixed,
  measure every shipped C++ consumer; keep GCC 11 only if its shipped providers
  satisfy every required `GLIBCXX_` and `CXXABI_` node, otherwise ship GCC 12
  and re-run the same closure checks. State whether zero spare nodes is allowed;
  do not use “margin is gone” as the selection threshold. Mark D10 decided by
  this policy while item 7 supplies the measurement evidence.

- Missing Q09 — ask what “version-node coherence” means. Include libc-only,
  namespace-to-family mapping, and actual `DT_VERNEED` provider resolution as
  distinct options; choose provider resolution. The acceptance wording should
  require each version need to be satisfied by the shipped object selected for
  its recorded dependency and require that selection to remain inside the
  archive search scope.

- Missing Q10 — ask how a family and generation are identified and over which
  search scope. Options must distinguish a hard-coded known-family list, a
  filename heuristic, and explicit SONAME/provider-family rules with declared
  exceptions. Recommend the explicit rules, because the current OpenSSL and
  libbfd evidence does not establish that all duplicate paths are duplicate
  generations.

- Missing Q11 — ask what negative evidence proves the combined gate. Options
  should distinguish one representative failure, one failure per independent
  invariant, and exhaustive mutation of every library. Recommend one fixture
  per independent invariant; it is bounded and proves that each branch can
  reject without turning acceptance into an exhaustive implementation test.

### Requested changes for issue toolchain-runtime-closure round 1

Requested changes:

1. Replace every libc-only coherence statement with a provider-aware invariant:
   each shipped object's version needs must be satisfied by the shipped object
   selected for the corresponding dependency, and resolution must not fall
   back to the host. Retain libc as the provider specifically for `GLIBC_`
   needs, not for all namespaces.
2. Add and answer the missing provider-resolution, family-identity, and
   negative-control questions described in the verdicts.
3. Consolidate A3 into an explicit initial floor with scope and ownership.
   Define the exact sqlite waiver, reject unknown/stale waivers, name item 6 as
   its remover, and make any active waiver a publication blocker for item 7.
4. Define family, generation, pair consistency, and resolution scope before
   adopting E3. Distinguish duplicate generations from identical copies in
   independent tool roots and from intentional ABI-major coexistence.
5. Perform the post-RPATH libssl re-probe required by F2 and include its
   conclusive object inventory and result in the revised specification.
6. Rewrite H3 as a decided conditional D10 policy with the exact consumer set,
   `GLIBCXX_` and `CXXABI_` comparisons, and unambiguous GCC 11/GCC 12 switch
   condition. Reflect that policy in the umbrella decision table.
7. Expand acceptance to include a positive Debian no-host-fallback result and
   one negative control for every independent declared-floor, derived-closure,
   provider-version, family, and trace-conclusiveness invariant.
8. Update the umbrella where the cross-requirement contracts change: item 6
   removes the sqlite waiver and item 7 refuses publication with any waiver.

### Writer instructions for issue toolchain-runtime-closure round 1

Revise the issue using the requested changes and update the umbrella only for
the cross-requirement contracts and D10 state identified here. Preserve the
settled RPATH boundary and do not turn this issue into the sqlite rebuild or
publication implementation. In the next request, show the exact initial floor,
waiver lifecycle, provider-resolution rule, family classifier, D10 switch
condition, acceptance controls, and the post-RPATH libssl evidence. Explain any
reviewer recommendation you reject, then publish another automated
specification review round; do not consolidate yet.

### Final reviewer decision for issue toolchain-runtime-closure round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-03T08:07:34+02:00
- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
- Outcome: request

### Review identity for issue toolchain-runtime-closure (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
Review round: 2

### Requestor assessment for issue toolchain-runtime-closure (round 2)

#### Assessment of the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 2)

Eleven open questions are placed, up from eight. The three the round 1 review
asked for are added, and the eight existing ones carry the qualifications it
required.

##### Are the questions sufficient now for issue toolchain-runtime-closure (round 2)

The eleven cover every part of the document that admits more than one reading.
The three new ones close the gaps the review named:

- Q09 asks what version-node coherence means, with libc-only, a
  namespace-to-family table, and actual `DT_VERNEED` provider resolution as
  distinct options. Provider resolution is recommended, and the no-host-fallback
  condition falls out of it rather than being bolted on.
- Q10 asks how a family and a generation are identified and over which scope,
  with a known-family list, a filename heuristic, and explicit SONAME and scope
  rules as options. The explicit rules are recommended, on measured cases rather
  than on principle.
- Q11 asks what negative evidence proves the combined gate, with one
  representative failure, one fixture per independent invariant, and exhaustive
  mutation as options. One per invariant is recommended, seven of them.

##### Are the options and answers sufficient for issue toolchain-runtime-closure (round 2)

Each of the eleven carries three options with pros and cons, a recommended
option with arguments, and an `Answer to Qxx` line. Every earlier answer that
the review qualified now names the qualification rather than restating the
option letter:

- Q01 A3 now points at an explicit per-scope floor table with named ownership,
  because "members whose absence is invisible on RHEL" is a criterion and not a
  list;
- Q02 B3 now carries the four-clause waiver contract, including the publication
  boundary that makes "unpublishable" true rather than asserted;
- Q03 C3 now names item 6 as remover and item 7 as refuser, recorded in the
  umbrella as well as here;
- Q04 D3 now requires the positive Debian no-host-fallback run and the
  seven-fixture matrix;
- Q05 E3 now depends on Q10's definitions and cites the measured cases;
- Q06 F2 is PERFORMED, with its inventory and verdict retained;
- Q07 G3 now couples to the publication refusal;
- Q08 H3 is rewritten as a decided conditional policy with zero spare nodes
  allowed.

##### Evidence added since round 1 for issue toolchain-runtime-closure (round 2)

`docs/v0.27.0/measurements.openssl-version-nodes.rhel.txt`, the post-RPATH
OpenSSL re-probe on RHEL 9.8 over the live install. Six shipped objects read,
every needed `OPENSSL_` node found defined by a shipped libcrypto.

Two things about it belong in this assessment rather than only in the capture.
Its comparator was wrong on the first run, reporting all six nodes missing while
its own inventory showed them defined, and it now carries a control requiring
both answers before its verdict is read. And it measured, incidentally, the
family cases the classifier needed: libssl twice per root with different
version-need sets, libcrypto once per root with identical definitions.

##### Reviewer wording suggestions applied for issue toolchain-runtime-closure (round 2)

All eight requested changes, in full. None was rejected and none was applied
partially, so this round records no disagreement.

##### What this round asks the reviewer to weigh first for issue toolchain-runtime-closure (round 2)

Whether the family classifier of Q10 is now sufficient to adopt E3 in Q05. The
definitions are written and the three measured shapes are classified, but the
`libssl.so.3` case is the interesting one: the same SONAME twice in one scope
with different version needs is called a collision here, and a reviewer who
thinks the archive intends that duplication should say so, because the rule
would then need a declared exception rather than a refusal.

### Change summary for issue toolchain-runtime-closure (round 2)

#### Change summary for the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 2)

##### Round 2: what changed since round 1 for issue toolchain-runtime-closure (round 2)

```text
 M docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
?? docs/v0.27.0/draft.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/measurements.openssl-version-nodes.rhel.txt
?? docs/v0.27.0/review.issue.v0.27.0.toolchain-runtime-closure.md
```

Nothing is committed. The item branch is `toolchain-runtime-closure`.

##### The reviewed issue for issue toolchain-runtime-closure (round 2)

Grew from 179 lines to 878 with its questions, 332 before them.

| Section | Change |
| --- | --- |
| Gap analysis | the coherence row now reads provider-aware, and a no-host-fallback row is added |
| The provider-aware coherence rule | NEW, replacing every libc-only statement, with the correction stated as a correction |
| Confirmed rules | two independent membership halves, scoped family coherence, gate with waiver |
| The declared floor and its scope | NEW: a per-scope table, ten members for `tools/python`, three for `tools/git`, with ownership named |
| The waiver contract | NEW: one member per waiver, unknown and stale fail, any active waiver blocks publication, and the one sqlite waiver |
| Family and generation | NEW: SONAME, generation, scope, collision and paired provider defined, with three measured cases classified |
| The libssl caveat | REWRITTEN: measured rather than carried, citing the retained capture |
| Gap to close | seven items, matching the invariants |
| The D10 decision | REWRITTEN as a decided conditional policy with an unambiguous switch |
| Acceptance | NEW: positive Debian no-host-fallback run plus seven negative fixtures |
| Concrete examples | eight, one per rule including the accepted cases |
| Open questions | eight, requalified, plus Q09, Q10 and Q11 |

##### New evidence for issue toolchain-runtime-closure (round 2)

`docs/v0.27.0/measurements.openssl-version-nodes.rhel.txt`, 156 lines: the
post-RPATH OpenSSL version-node re-probe, RHEL 9.8, six shipped objects, with
the comparator's own two-way control and an explicit statement of what it does
not answer. Sanitised.

##### The umbrella, edited only where the review named a contract for issue toolchain-runtime-closure (round 2)

`docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`, three edits:

| Location | Change |
| --- | --- |
| decision row D10 | from `open, to settle inside requirement 4` to the decided conditional policy, with consumer set, both namespaces, switch condition and the zero-spare-nodes rule |
| item 6 detail | records that this item REMOVES the sqlite waiver, and that a stale waiver fails item 4's check |
| item 7 detail | records that it REFUSES to publish while any waiver is active, and that it supplies the D10 measurement rather than the decision |

Its canonical table, ordering, other decision rows and work-item sections are
untouched. Row 4 still reads `pending` with both document cells `-`.

### Writer response for issue toolchain-runtime-closure (round 2)

Writer response:

#### Writer response for the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 2)

Round 1 returned `changes-requested` with eight concrete instructions. All eight
are applied. Nothing is rejected, so no disagreement is recorded.

##### The finding that mattered most, accepted without qualification for issue toolchain-runtime-closure (round 2)

THE LIBC-ONLY COHERENCE RULE WAS TECHNICALLY FALSE, and the review was right to
refuse the document over it. `GLIBC_` nodes come from libc, `GLIBCXX_` and
`CXXABI_` from libstdc++, `OPENSSL_` from libcrypto. A libc-only check would
have rejected a coherent OpenSSL pair or ignored its real provider.

The wording came from the umbrella, whose own examples contradict it, so this is
a defect inherited rather than invented. The issue now carries a provider-aware
invariant in four conditions, with libc as the provider for `GLIBC_` needs only,
and the correction is stated as a correction rather than quietly reworded. Q09
asks the same question as a first-class one.

##### The re-probe was performed, and its own comparator had to be fixed first for issue toolchain-runtime-closure (round 2)

F2 asked for the post-RPATH libssl re-probe rather than another round of
suspicion, and it is done and retained:
`docs/v0.27.0/measurements.openssl-version-nodes.rhel.txt`.

All six shipped OpenSSL objects were read. Every `OPENSSL_` node the shipped
libssl needs IS defined by a shipped libcrypto. The eight lines were the
isolation artifact the umbrella suspected.

THE PROBE'S FIRST RUN WAS WRONG AND ITS OWN INVENTORY SHOWED IT. It reported all
six needed nodes missing while printing, directly above, a defined set
containing every one of them: the membership test compared a space-delimited
pattern against newline-delimited data, so it could only ever answer "missing".
It now carries a control that requires the comparator to answer both ways, and
the verdict is believed only because that control passes. This is the same class
of defect this collection keeps finding, met inside a probe written to settle a
question about it.

##### What the measurement changed beyond its own question for issue toolchain-runtime-closure (round 2)

It supplied the concrete family cases Q05 and Q10 needed, which is why the
classifier is no longer stated on principle:

- `libssl.so.3` ships TWICE per tool root, in `root/usr/bin` and
  `root/usr/lib64`, with DIFFERENT version-need sets. Same SONAME, same ABI
  major, different builds, one scope: a real collision;
- `libcrypto.so.3` ships once per tool root with identical definitions:
  different scopes, not a collision.

The review's warning that duplicate paths are not necessarily duplicate
generations is therefore not a caution but a measured fact, and one of the two
shapes is a fault while the other is not.

##### The seven other instructions for issue toolchain-runtime-closure (round 2)

- CHANGE 1, provider-aware invariant: replaces every libc-only statement.
- CHANGE 2, missing questions: Q09 provider resolution, Q10 family identity,
  Q11 negative-control matrix, each with three options and a recommendation.
- CHANGE 3, the floor: now an explicit table, ten members for `tools/python` and
  three for `tools/git`, chosen as those whose absence is invisible on the build
  host. Ownership named. The sqlite waiver is defined with its member, owner and
  removal condition, unknown and stale waivers fail, and an artifact produced
  under any waiver cannot cross the publication boundary.
- CHANGE 4, family definitions: family by SONAME, generation as ABI-major,
  scope as one search list, collision as two different objects offering one
  SONAME in one scope, exceptions declared. A filename stem is explicitly
  refused as a classifier, and the rule refuses rather than prunes.
- CHANGE 5, the re-probe: above.
- CHANGE 6, D10: rewritten as a decided conditional policy with the exact
  consumer set, both namespaces, an unambiguous switch, and ZERO SPARE NODES
  ALLOWED. "Margin is gone" is named and rejected as a threshold.
- CHANGE 7, acceptance: a positive Debian no-host-fallback result read from a
  scope listing AND a live trace naming the venv process it inventoried, plus
  one negative control for each of seven independent invariants.
- CHANGE 8, umbrella: item 6 records that it removes the sqlite waiver, item 7
  records that it refuses to publish while any waiver is active and that it
  supplies the D10 measurement, and the D10 row records the policy as decided.

##### What was deliberately not done for issue toolchain-runtime-closure (round 2)

The umbrella was edited ONLY where the review named a cross-requirement contract
or the D10 state. Its canonical table, its ordering, its other decision rows and
its work-item sections are untouched. This issue did not become the sqlite
rebuild or the publication implementation, and the settled RPATH boundary from
umbrella item 2 is preserved: it is cited as the reason the wheel side is closed
and the reason the re-probe was worth taking, and nothing re-opens it.

### Reviewer focus for issue toolchain-runtime-closure (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-03T08:13:17+02:00
- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
- Outcome: answer

### Reviewer assessment for issue toolchain-runtime-closure round 2

Round 2 resolves the provider-aware version rule, supplies the requested
OpenSSL measurement, makes the floor explicit, bounds publication under a
waiver, and turns D10 into a conditional policy. Those are material
improvements. Implementation still cannot proceed because the new resolution-
scope and family model contradict both itself and the cited implementation.

The specification says the Python and Git roots resolve independently and
defines one scope per tool root. The cited `build_elf_rpath` implementation at
`src/setups/env/bin/install_pkg.sh:887` instead walks Python first and then
every tool root into one ordered list; lines 891-898 add only root library and
version library directories. That global value is computed at line 959 for the
relocation pass. Consequently, the two `libcrypto.so.3` paths are candidates
in the same runtime search scope, while `root/usr/bin/libssl.so.3` is not a
provider directory in that scope. The measurement proves version-node sets; it
does not prove the scope classifications asserted from them.

The family definitions are also impossible as written: “family is identified
by SONAME” and “generation is a different SONAME within one family” cannot both
hold. ELF provides a general same-SONAME provider identity, but it does not
provide a universal logical-family identifier across different SONAMEs. That
second relationship requires an explicit declaration. The specification must
separate automatic duplicate-provider collision detection from declared
cross-SONAME family-generation policy and define how two provider files are
determined to be identical or different.

Two smaller but implementation-significant ambiguities remain. A stale waiver
is defined by whether its owning requirement is complete, without naming a
machine-readable source for that state; use the waiver's measurable removal
condition instead. D10 says `CXXABI_` needs are compared against libstdc++ and
its libgcc companion, although `GLIBCXX_` and `CXXABI_` are both provided by
libstdc++; libgcc has its own `GCC_` version needs. It also needs an explicit
failure if neither GCC 11 nor GCC 12 satisfies the final consumers.

No twelfth question is needed: Q02/Q03, Q08, and Q10 already own these axes.
Their answers and the resulting normative sections must be corrected. The
changes alter enforcement scope and classifications, so the disposition
remains changes-requested.

### Question verdicts for issue toolchain-runtime-closure round 2

- Q01 — still necessary; choose A3. The explicit floor is useful, but “per
  resolution scope” is currently based on a false two-scope model. If product
  policy requires a member physically inside each tool root, call that a
  per-delivery-root floor and keep it distinct from the actual global runtime
  search scope. Otherwise consolidate the floor against the one global scope.

- Q02 — choose B3. The four waiver clauses and publication boundary are now
  clear, except that “owning requirement is complete” is not an observable
  packaging condition. Define stale mechanically as the named removal
  condition being satisfied while the waiver remains, or name an exact
  machine-readable state source.

- Q03 — choose C3. The hand-off and publication refusal are appropriate. Amend
  its removal condition and umbrella wording to use the same mechanically
  observable stale rule selected for Q02.

- Q04 — choose D3. The positive run and per-invariant negative matrix are
  sufficient once every fixture uses the corrected runtime scope and family
  classifier. This question is otherwise settled.

- Q05 — retain E3's general refusal intent, but E3 is not implementable with
  the current definitions. Split automatic same-SONAME provider collisions
  from declared logical families spanning different SONAME generations. A
  report-only or auto-pruning policy remains unacceptable.

- Q06 — choose F2. The retained capture adequately proves that the observed
  `OPENSSL_` needs are defined by each shipped libcrypto. It does not prove that
  `root/usr/bin/libssl.so.3` and `root/usr/lib64/libssl.so.3` are competing
  providers in one search scope, nor that the two libcrypto files are identical
  objects. Remove those family conclusions or add the missing path-membership
  and object-identity evidence.

- Q07 — choose G3. The validation/publication boundary is now explicit and
  sufficient, subject only to the corrected stale-waiver rule.

- Q08 — choose a corrected H3. Compare both `GLIBCXX_` and `CXXABI_` needs with
  the candidate `libstdc++.so.6`; let the general provider rule separately
  verify any `GCC_` needs on `libgcc_s.so.1`. Choose GCC 11 if it satisfies the
  final set, otherwise GCC 12 if it satisfies it, and refuse/reopen D10 if
  neither candidate does. Keep the settled zero-spare-node policy.

- Q09 — choose J3. Provider-aware `DT_VERNEED` resolution is complete and
  non-redundant. Preserve it while correcting the scope to the search list the
  loader actually receives.

- Q10 — none of K1-K3 is acceptable as currently worded. K3 contradicts itself
  by equating family with SONAME and then putting different SONAMEs in one
  family. Rewrite K3 as a hybrid: provider identity is SONAME; a collision is
  multiple non-identical provider candidates for that SONAME in one actual
  search scope; a logical family across SONAME generations is an explicit
  declaration; intentional coexistence is explicit. Define non-identical by an
  exact stable criterion such as content digest or build identity. Reclassify
  OpenSSL and libbfd against that model and the global rpath.

- Q11 — choose L2. One negative fixture per independent invariant is the right
  bounded evidence. Update the family fixture after Q10 is corrected; no other
  option change is needed.

The eleven questions are sufficient after these revisions; the problem in
round 2 is the selected answer semantics and their unsupported application,
not a missing decision axis.

### Requested changes for issue toolchain-runtime-closure round 2

Requested changes:

1. Correct the resolution topology throughout. `build_elf_rpath` currently
   builds one Python-first ordered list across all tool roots; either specify
   that global runtime scope or explicitly reopen and change the completed
   RPATH contract. Do not call the current Python and Git roots independent
   resolution scopes. Distinguish any per-tool physical floor policy from
   runtime resolution.
2. Rewrite Q10/K3 and the normative family section so SONAME identifies a
   provider ABI, while a logical family spanning different SONAME generations
   is explicitly declared. Define object equality, automatic same-SONAME
   collision, cross-generation policy, and intentional exceptions separately.
3. Reclassify the measured OpenSSL files using actual provider-directory
   membership and the corrected global scope. `root/usr/bin` is absent from the
   search directories listed by `build_elf_rpath`; identical version
   definitions do not prove two libcrypto files are identical. Remove the
   unsupported claims or add exact rpath and content/build-identity evidence.
4. Define stale waivers by a machine-observable removal condition (for sqlite,
   the member is present in the required physical location) or name the exact
   machine-readable requirement-state source. Apply the same definition in the
   issue and umbrella item 6.
5. Correct D10 in the issue and umbrella: `GLIBCXX_` and `CXXABI_` are supplied
   by libstdc++, while libgcc's own provider needs are checked independently.
   Select GCC 12 only if it satisfies the final set, and define refusal or a
   reopened decision when neither allowed candidate does.
6. Update the Q01, Q02, Q03, Q05, Q06, Q08, Q10, and affected Q11 wording and
   examples consistently, while preserving the now-settled provider-aware
   rule, validation matrix, and publication boundary.

### Writer instructions for issue toolchain-runtime-closure round 2

Apply the six requested changes and publish round 3 without consolidating.
Anchor the scope correction to the actual `build_elf_rpath` ordering and
directories, then separate per-tool delivery requirements from loader search
scope. Rework the family model before reclassifying OpenSSL/libbfd, and include
the exact evidence used to call provider files identical or competing. Make
the stale-waiver test machine-observable and correct the D10 providers and
unsupported-candidate outcome in both the issue and umbrella. In the next
request, explain any recommendation not accepted.

### Final reviewer decision for issue toolchain-runtime-closure round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-09-03T08:24:11+02:00
- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
- Outcome: request

### Review identity for issue toolchain-runtime-closure (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
Review round: 3

### Requestor assessment for issue toolchain-runtime-closure (round 3)

#### Assessment of the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 3)

Eleven open questions, unchanged in number. Round 2 of the review was explicit
that no twelfth is needed and that Q02/Q03, Q08 and Q10 already own the axes it
found wrong, so this round corrects answers rather than adding questions.

##### Are the questions sufficient for issue toolchain-runtime-closure (round 3)

Yes, and the review said so. What was insufficient was three answers and the
normative sections built on them. Q01's floor was per tool root, Q05 and Q10
carried a self-contradictory family definition, and Q08 attributed `CXXABI_` to
the wrong provider. All four are rewritten.

##### Are the options and answers sufficient for issue toolchain-runtime-closure (round 3)

Each of the eleven carries three options with pros and cons, a recommendation
and an acceptance reason. The four rewritten this round now rest on a
measurement rather than on an assumption:

- Q01 A3: the floor is declared once for the archive's one scope, because
  `build_elf_rpath` composes one list across every tool root;
- Q05 E3: two rules, one automatic by content digest and one declared, because
  a single SONAME rule would refuse the current archive 95 times falsely;
- Q08 H3: both libstdc++ namespaces against libstdc++, `libgcc_s` separately,
  and packaging fails if neither generation satisfies;
- Q10 K3: two identities, each taken from a source that can supply it.

##### Evidence added since round 2 for issue toolchain-runtime-closure (round 3)

`docs/v0.27.0/measurements.resolution-scope.rhel.txt`. It reads the composed
search list rather than the directory tree, which is precisely the distinction
the previous round failed to make.

ITS FINDINGS CHANGED THE RULE, not only the wording. 95 SONAMEs are offered more
than once in the one scope and all 95 are the same file, so a refusal keyed on
the SONAME alone would refuse today's archive 95 times over. The genuinely
different case has two SONAMEs and would have been invisible to that same rule.

##### What this round asks the reviewer to weigh first for issue toolchain-runtime-closure (round 3)

Rule 2's deliberate blind spot. An UNDECLARED family is not checked at all, so a
future duplicate generation ships silently until someone declares its family.
The alternative is a heuristic, and the measured evidence shows a filename stem
would be wrong in both directions. This is a real limit accepted on purpose, and
a reviewer who wants it closed differently should say what source could supply a
cross-SONAME kinship that ELF does not carry.

##### Reviewer wording suggestions applied for issue toolchain-runtime-closure (round 3)

All four findings, in full, plus one addition the review's own logic implies: a
positive control requiring the unmodified archive to PASS rule 1, since a rule
that over-refuses would otherwise be caught by nothing.

### Change summary for issue toolchain-runtime-closure (round 3)

#### Change summary for the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 3)

##### Round 3: what changed since round 2 for issue toolchain-runtime-closure (round 3)

```text
 M docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
?? docs/v0.27.0/draft.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/measurements.openssl-version-nodes.rhel.txt
?? docs/v0.27.0/measurements.resolution-scope.rhel.txt
?? docs/v0.27.0/review.issue.v0.27.0.toolchain-runtime-closure.md
```

Nothing is committed. The item branch is `toolchain-runtime-closure`.

##### New evidence this round for issue toolchain-runtime-closure (round 3)

`docs/v0.27.0/measurements.resolution-scope.rhel.txt`, 582 lines. It reads the
SEARCH LIST that `build_elf_rpath` composes, rather than the directory layout,
and it exists because round 2 of the review found the issue had confused the
two.

| What it measured | Result |
| --- | --- |
| scope shape | ONE scope, ten directories, across `tools/python`, `tools/git` and `tools/old/py3.13` |
| is `root/usr/bin` a provider directory | NO |
| SONAMEs offered more than once in the scope | 95 |
| of those, offered by DIFFERENT files | 0 |
| cross-SONAME family case | `libbfd-2.35.2-63.el9.so` and `-66.el9.so`, same scope, two SONAMEs |

##### The reviewed issue for issue toolchain-runtime-closure (round 3)

| Section | Change |
| --- | --- |
| Current behavior | step 2 now describes one composed list across every tool root, not eight directories per root |
| Gap analysis | the family row now reads one object per SONAME and one generation per DECLARED family |
| Confirmed rules | the scoped-family bullet becomes the two-rule bullet |
| The one resolution scope | NEW: reads the scope from `install_pkg.sh:881` and 959, names the ten directories, and tabulates the two classifications the previous revision got wrong |
| Duplicate providers, and the cross-SONAME family | NEW, replacing "Family and generation": rule 1 automatic by content digest, rule 2 declared, neither prunes |
| The declared floor | now ONE list for the archive, not per tool root |
| The waiver contract | stale is now defined by the removal condition, with the reason the requirement-state test is unusable |
| The libssl caveat | its family paragraph now records that its own classifications were wrong and points at the second measurement |
| Gap to close | item 5 declares the floor once, with the family list beside it |
| The D10 decision | `GLIBCXX_` and `CXXABI_` both against libstdc++, `libgcc_s` separately on `GCC_`, and an explicit neither-satisfies failure |
| Acceptance | a positive rule 1 control on the unmodified archive; the negative matrix splits rule 1 from rule 2 |
| Concrete examples | five examples replaced with the measured cases, including the two NOT EXAMINED ones |
| Code references | the composed list is described as one scope across every tool root, never including `root/usr/bin` |
| Q01, Q05, Q08, Q10 | options and answers rewritten around the corrected model |

##### The umbrella for issue toolchain-runtime-closure (round 3)

One further edit this round, in the D10 row only: the same provider correction
and the neither-satisfies failure. The cross-requirement contracts added in
round 2 for items 6 and 7 are unchanged, and the canonical table, ordering and
work-item sections remain untouched. Row 4 still reads `pending`.

### Writer response for issue toolchain-runtime-closure (round 3)

Writer response:

#### Writer response for the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 3)

Round 2 returned `changes-requested` with four findings. All four are accepted
and applied. Nothing is rejected, so no disagreement is recorded.

##### The finding that mattered, and how it was settled for issue toolchain-runtime-closure (round 3)

THE SCOPE MODEL WAS WRONG, AND SO WERE BOTH CLASSIFICATIONS I DREW FROM IT. The
issue said the python and git roots resolve independently. The review read the
installer instead: `build_elf_rpath` accumulates EVERY tool root into one
ordered list, dedupes it, and the pass writes that single value into every ELF.
`root/usr/bin` is never among the directories it adds.

I had inferred scope from directory layout and never checked how the search list
is composed. The round 2 measurement proved version-node sets and nothing about
scope, and I asserted scope from it anyway. That is the same error class this
requirement exists to close, committed inside the document that closes it.

So the answer is not a rewording. It is a second measurement,
[measurements.resolution-scope.rhel.txt](../docs/v0.27.0/measurements.resolution-scope.rhel.txt),
which reads the search list:

- ONE scope, ten directories, spanning `tools/python`, `tools/git` and
  `tools/old/py3.13`;
- `root/usr/bin` is NOT a provider directory;
- 95 SONAMEs are offered more than once in that scope, and EVERY ONE of the 95
  is the SAME FILE reachable from several directories;
- `libbfd-2.35.2-63.el9.so` and `libbfd-2.35.2-66.el9.so` sit in that scope
  under two SONAMEs.

Both earlier classifications are corrected in the document, as corrections
rather than quiet rewrites: `libcrypto.so.3` in two roots is one scope and one
file, not two scopes; `libssl.so.3` under `root/usr/bin` is not in the scope at
all.

THE MEASUREMENT ALSO CHANGES THE RULE ITSELF. A refusal keyed on "same SONAME
twice in one scope" would refuse the current archive 95 times over, every one of
them false. That is not a detail: it is the difference between a rule that can
ship and one that cannot.

##### The four findings, each applied for issue toolchain-runtime-closure (round 3)

- FINDING 1, scope contradiction: the issue now carries a section that reads the
  scope from `install_pkg.sh:881` and 959, names the ten measured directories,
  and states the two classifications it got wrong. The floor is declared ONCE,
  not per root, because there is one scope.
- FINDING 2, impossible family definitions: split into two rules. RULE 1 is
  automatic, refusing two objects with DIFFERENT content digests offering one
  SONAME, with identity defined as SHA-256 over the file bytes. RULE 2 is
  declared, refusing two generations of a family named in a committed list,
  because ELF carries no cross-SONAME family identifier. An undeclared family is
  deliberately unchecked rather than guessed.
- FINDING 3, stale waiver: a waiver is stale when its REMOVAL CONDITION is
  satisfied, not when its owning requirement is complete. "Is
  `libsqlite3.so.0` present in the scope" is the measurement the floor check
  already performs; "is item 6 complete" has no machine-readable source at
  packaging time.
- FINDING 4, D10 providers: `GLIBCXX_` and `CXXABI_` are BOTH compared against
  the shipped libstdc++, which provides both, and `libgcc_s` is checked
  separately against its own `GCC_` needs. An explicit failure is added for the
  case where NEITHER generation satisfies the consumers: packaging fails rather
  than taking the closer one. The umbrella D10 row carries the same correction.

##### What changed beyond the four for issue toolchain-runtime-closure (round 3)

The acceptance matrix gained a POSITIVE control that the review's logic implies
but did not name: the unmodified archive must PASS rule 1. With 95 same-file
duplicates in the scope, a rule 1 that over-refused would be caught by nothing
else, and this collection's habit is to assert both directions of a gate.

The negative matrix now separates rule 1 from rule 2 rather than listing one
"family collision" fixture, since they are two independent invariants.

##### No twelfth question for issue toolchain-runtime-closure (round 3)

The review was right that Q02/Q03, Q08 and Q10 already own these axes. Q05 and
Q10 are rewritten around the two-rule model, Q01's floor is now archive-wide,
Q08 carries the provider correction and the neither-satisfies failure. The
question count stays at eleven.

### Reviewer focus for issue toolchain-runtime-closure (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-09-03T08:29:47+02:00
- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
- Outcome: answer

### Reviewer assessment for issue toolchain-runtime-closure round 3

Round 3 correctly replaces the false per-tool scope with the one global,
Python-first search list from `build_elf_rpath`. It also separates automatic
same-provider detection from declared cross-SONAME family policy, makes stale
waivers observable, and corrects the D10 providers and neither-candidate
outcome. The new resolution-scope capture supports the global-scope correction
and the recorded content identities.

Two normative inputs are still missing. The document repeatedly says a
committed declared-family list sits beside the floor, but no such list or
initial libbfd pattern appears there. Rule 2 therefore has no implementable
configuration and does not currently reject the measured libbfd pair. Also,
rule 1 says every ELF with the same internal SONAME “offers” that provider.
The loader actually searches each rpath directory for the exact `DT_NEEDED`
filename; a differently named ELF carrying the same internal SONAME is not an
alternative candidate unless a matching path or symlink exposes it. The rule
must define candidates from loader lookup paths before comparing resolved file
content, otherwise it can reject objects the loader would never choose between.

The single archive-wide floor also conflicts with the sqlite waiver wording.
The stale test says presence anywhere in the global scope satisfies the removal
condition, while the waiver table and examples require the sqlite payload in
the Python root. Choose one mechanical condition and state it identically. If
physical ownership matters, express a location-constrained floor entry rather
than calling the floor only a set of scope-wide SONAMEs.

No additional question is needed; Q01, Q02/Q03, Q05/Q10, and Q11 already own
these corrections. Several stale answer phrases also remain (Q01 still says
“ten for Python and three for Git” and “per-scope floor”; Q04/Q11 still count
seven invariants after the family check split into two). Because the absent
family declaration and loader-candidate definition affect what packaging
accepts, this is more than wording polish and the disposition is
changes-requested.

### Question verdicts for issue toolchain-runtime-closure round 3

- Q01 — choose A3, but reconcile the normative one-scope floor with its answer,
  which still describes “ten members for tools/python and three for tools/git”
  and a “per-scope floor.” State whether each entry is satisfied anywhere in
  the global scope or at a required physical root. Apply that choice to sqlite.

- Q02 — choose B3. The measurable stale-waiver approach is correct. Its test
  must use the exact same condition as the waiver table: either sqlite exists
  anywhere in scope or specifically in the Python root, not both wordings.

- Q03 — choose C3. The cross-requirement hand-off remains sound once the exact
  sqlite removal condition is consistent in the issue and umbrella.

- Q04 — choose D3. Update the option and rationale from seven to eight
  independent rejection invariants now that duplicate-provider rule 1 and
  declared-family rule 2 have separate fixtures. Keep the added positive
  no-over-refusal control.

- Q05 — choose E3's two-rule model. For rule 1, define a candidate as the file
  the loader can reach at `<scope-directory>/<DT_NEEDED-name>` (after resolving
  links), then compare full content digests among those candidates. Internal
  `DT_SONAME` grouping alone does not prove that a file is a lookup candidate.
  For rule 2, supply the actual committed initial family declaration instead of
  only promising one.

- Q06 — choose F2. The OpenSSL version-node conclusion is settled, and the
  second capture correctly retracts the earlier scope inference. No further
  option change is needed.

- Q07 — choose G3. The validation/publication boundary remains complete,
  subject to the consistent sqlite waiver condition.

- Q08 — choose H3 as now written. Both libstdc++ namespaces, the separate
  libgcc provider check, zero-spare-node policy, and neither-satisfies failure
  settle the decision adequately.

- Q09 — choose J3. Provider-aware resolution remains the correct complete
  semantics. Use the same loader-candidate definition when Q05/Q10 are revised.

- Q10 — choose K3 after completing it. Add the initial declared-family table,
  including the exact libbfd SONAME patterns, permitted generation count or
  coexistence policy, and owner. Correct the lingering K2 phrase that calls
  `libssl.so.1.1` and `libssl.so.3` different families; they are different ABI
  generations of the same logical lineage under the new model.

- Q11 — choose L2. Update its option and rationale to the eight normative
  rows: declared floor, derived closure, provider version, no host fallback,
  duplicate provider, declared family generation, waiver contract, and trace
  conclusiveness.

The existing eleven questions are sufficient. The remaining work completes
their selected answers; it does not introduce a new decision axis.

### Requested changes for issue toolchain-runtime-closure round 3

Requested changes:

1. Add the actual committed initial declared-family list beside the floor. At
   minimum, give libbfd's exact SONAME pattern set, permitted generation count
   or coexistence policy, and ownership so the measured `-63`/`-66` pair is
   mechanically refused by rule 2.
2. Define duplicate-provider candidates using loader lookup semantics: for each
   exact `DT_NEEDED` name, inspect matching paths in the ordered rpath
   directories, resolve links, then compare full file content digests. Do not
   treat every differently named ELF sharing an internal `DT_SONAME` as a
   competing provider. Revise the 95-provider wording if it counted aliases
   that are not separate lookup candidates.
3. Make the floor and sqlite waiver location semantics consistent. Decide
   whether global-scope presence or presence specifically in `tools/python`
   satisfies the floor/removal condition, express any location constraint in
   the floor schema, and use the identical observable test in Q01-Q03, the
   normative waiver section, examples, and umbrella item 6.
4. Remove the stale round-2 phrases in Q01, update Q04/Q11 to eight independent
   invariant fixtures, and correct Q10/K2 to call the OpenSSL SONAMEs different
   ABI generations rather than different families.
5. Preserve the corrected global scope, provider-aware version rule, two-rule
   family architecture, D10 policy, validation matrix, and publication gate,
   then publish another automated review round.

### Writer instructions for issue toolchain-runtime-closure round 3

Apply the four substantive corrections and the listed consistency edits, then
publish round 4 without consolidating. Include the concrete initial family
declaration, define rule-1 candidates from exact loader lookup names before
digest comparison, and make the sqlite floor/removal location one unambiguous
mechanical test across the issue and umbrella. Reconcile all Q01, Q04, Q10 and
Q11 remnants with the normative model. Explain any recommendation not accepted
in the next request.

### Final reviewer decision for issue toolchain-runtime-closure round 3

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-09-03T08:36:40+02:00
- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
- Outcome: request

### Review identity for issue toolchain-runtime-closure (round 4)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
Review round: 4

### Requestor assessment for issue toolchain-runtime-closure (round 4)

#### Assessment of the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 4)

Eleven open questions, unchanged. Round 3 of the review said no additional
question is needed and that Q01, Q02/Q03, Q05/Q10 and Q11 already own the
corrections, so this round fixes answers and normative sections.

##### Are the questions sufficient for issue toolchain-runtime-closure (round 4)

Yes. What was missing was configuration rather than a question: rule 2 named a
declared-family list in four places and never contained one, so it had nothing
to read and refused nothing. That list now exists.

##### Are the options and answers sufficient for issue toolchain-runtime-closure (round 4)

Each of the eleven carries three options with pros and cons, a recommendation
and an acceptance reason. Corrected this round:

- Q01: the floor is one list for the one scope, nine SONAMEs each with a
  required location, ownership named. The "ten for Python and three for Git"
  phrasing is gone;
- Q04 and Q11: nine invariant fixtures, not seven. The review asked for eight
  after the family split; the ninth is the floor location constraint the same
  round introduced;
- Q05 and Q10: rule 1's candidates are now defined by loader lookup, and the
  measured count is 20 rather than 95;
- Q10/K2: `libssl.so.1.1` and `libssl.so.3` are different ABI generations of
  one family, not different families.

##### Evidence added since round 3 for issue toolchain-runtime-closure (round 4)

`docs/v0.27.0/measurements.provider-candidates.rhel.txt`. It counts duplicate
providers the way the loader looks them up, by exact `DT_NEEDED` filename in the
ordered scope, resolving links before comparing content.

IT CORRECTS A PUBLISHED NUMBER. The previous probe grouped by internal
`DT_SONAME` and reported 95; that counted development aliases which are not
lookup candidates. The loader-semantics count is 20 of 54 needed names with more
than one candidate path, all 20 resolving to one file, zero to different
content. The archive still passes rule 1, on the right model.

It also shows why rule 2 is not foldable: the libbfd pair has two filenames, so
no lookup ever has both as candidates.

##### What this round asks the reviewer to weigh first for issue toolchain-runtime-closure (round 4)

The initial declared-family list has exactly two entries, and at one permitted
generation `binutils-bfd` REFUSES the archive as it stands. That is intended:
the `-63` and `-66` pair is a fault, and a list that permitted it would be a
list written to pass. A reviewer who reads the coexistence as deliberate should
say so, because the fix is then a permitted-generation count of two rather than
a change to the rule.

##### Reviewer wording suggestions applied for issue toolchain-runtime-closure (round 4)

All four findings. One departure is declared rather than absorbed: the fixture
count is nine, not the eight the review asked for, because finding 3 added an
independently refusable invariant in the same round.

### Change summary for issue toolchain-runtime-closure (round 4)

#### Change summary for the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 4)

##### Round 4: what changed since round 3 for issue toolchain-runtime-closure (round 4)

```text
 M docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
?? docs/v0.27.0/draft.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/measurements.openssl-version-nodes.rhel.txt
?? docs/v0.27.0/measurements.provider-candidates.rhel.txt
?? docs/v0.27.0/measurements.resolution-scope.rhel.txt
?? docs/v0.27.0/review.issue.v0.27.0.toolchain-runtime-closure.md
```

Nothing is committed. The item branch is `toolchain-runtime-closure`.

##### New evidence this round for issue toolchain-runtime-closure (round 4)

`docs/v0.27.0/measurements.provider-candidates.rhel.txt`, 75 lines: duplicate
providers counted with loader lookup semantics.

| What it measured | Result |
| --- | --- |
| distinct `DT_NEEDED` names required | 54 |
| names with more than one candidate path | 20 |
| of those, all candidates resolving to one file | 20 |
| of those, resolving to different content | 0 |
| rule 1 verdict on the current archive | PASSES |
| libbfd pair as rule 1 candidates | never, two different filenames |

It supersedes the 95 figure of the previous round, which grouped by internal
`DT_SONAME` and counted aliases that are not lookup candidates.

##### The reviewed issue for issue toolchain-runtime-closure (round 4)

| Section | Change |
| --- | --- |
| Rule 1, duplicate providers | REWRITTEN as the four ordered steps the loader performs: exact `DT_NEEDED` name, candidate paths in scope order, resolve links, compare content. Records the corrected 20-of-54 counts and states that the 95 was a model error |
| The initial declared-family list | NEW: `binutils-bfd` and `binutils-opcodes`, one permitted generation each, ownership named, with the reason the list is short and the blind spot stated |
| The declared floor | gains a REQUIRED LOCATION column; `libsqlite3.so.0` constrained to `tools/python` with its reason, every other member "anywhere in the scope" |
| The waiver contract | the removal condition and the stale test are now the floor entry's own location test, word for word |
| Acceptance | the matrix is nine rows: floor location is added as its own invariant, the rule 1 fixture is restated in candidate terms, and the rule 2 fixture is the measured libbfd pair |
| Q01 | floor is one list with locations; the per-root phrasing is gone |
| Q04, Q11 | nine fixtures, with the reason it is nine and not the eight requested |
| Q05, Q10 | candidate model and counts corrected; K2 says ABI generations |

##### The umbrella for issue toolchain-runtime-closure (round 4)

One edit this round, in item 6 only: the waiver removal condition now states the
identical observable test as the issue, a file named `libsqlite3.so.0` present
under `tools/python` in the resolution scope, and says the check fails on a
satisfied removal condition rather than on this item's state. The D10 row and
the item 7 contract from earlier rounds are unchanged, as are the canonical
table, ordering and work-item sections. Row 4 still reads `pending`.

### Writer response for issue toolchain-runtime-closure (round 4)

Writer response:

#### Writer response for the toolchain-runtime-closure issue for issue toolchain-runtime-closure (round 4)

Round 3 returned `changes-requested` with four findings. All four are accepted
and applied. Nothing is rejected, so no disagreement is recorded.

##### The finding that mattered: my candidate model was not the loader's for issue toolchain-runtime-closure (round 4)

Rule 1 said every ELF with the same internal `DT_SONAME` offers that provider.
That is not how lookup works. For a `DT_NEEDED` entry the loader searches each
scope directory in order for a file with that EXACT NAME; an object carrying a
matching internal SONAME under a different filename is never a candidate unless
a path or symlink exposes it under the needed name.

So the "95 SONAMEs offered more than once" figure was inflated by development
aliases: `libBrokenLocale.so` beside `libBrokenLocale.so.1` in one directory
counted as two providers, when only one of them is a candidate for any lookup.

RE-MEASURED WITH LOADER SEMANTICS,
[measurements.provider-candidates.rhel.txt](../docs/v0.27.0/measurements.provider-candidates.rhel.txt):

- 54 distinct `DT_NEEDED` names are required by the shipped objects;
- 20 of those names have more than one candidate path in the scope;
- all 20 resolve, through their links, to ONE file;
- 0 resolve to different content.

The conclusion is unchanged, the archive passes rule 1, but it now rests on the
right model and the right number. Rule 1 is rewritten as the four ordered steps
the loader actually performs, and the 95 is recorded as a corrected figure
rather than silently replaced.

The same measurement also shows why rule 2 cannot be folded into rule 1: the
libbfd pair carries two different FILENAMES, so no `DT_NEEDED` name ever has
both as candidates and rule 1 is silent on them by construction.

##### The other three findings for issue toolchain-runtime-closure (round 4)

- FINDING 1, no declared-family list. The document promised one repeatedly and
  never wrote it, so rule 2 had no configuration and did not refuse the measured
  libbfd pair. The list is now present with two entries, `binutils-bfd` matching
  `libbfd-*.so` and `binutils-opcodes` matching `libopcodes-*.so`, both at one
  permitted generation, with ownership on the same terms as the floor. At one
  generation, `binutils-bfd` REFUSES the current archive, which is the point:
  the `-63` and `-66` pair is a real fault this requirement surfaces.
- FINDING 3, floor and waiver location semantics. The floor gained a REQUIRED
  LOCATION column. Most members read "anywhere in the scope", because resolution
  is what the floor protects. `libsqlite3.so.0` carries a constraint to
  `tools/python`, with the reason stated: its consumer is the interpreter's
  `_sqlite3` extension, and a copy living only under the git root would make the
  python payload depend on another tool's payload. The floor check, the stale
  test, the waiver removal condition, the examples and umbrella item 6 now all
  state the identical observable test.
- FINDING 4, stale phrases. Q01 no longer says "ten for Python and three for
  Git" or "per-scope floor"; K2 now calls `libssl.so.1.1` and `libssl.so.3`
  different ABI generations of one family rather than different families.

##### Where this round departs from the instruction, and why for issue toolchain-runtime-closure (round 4)

The review asked for EIGHT independent invariant fixtures, counting the family
check splitting into rules 1 and 2. The matrix has NINE. The ninth is the floor
LOCATION constraint that finding 3 introduced in the same round: it is
independently refusable, so it is independently assertable, and its fixture is
`libsqlite3.so.0` present in the scope but only under `tools/git`. The count is
stated as nine with that reason rather than filed under eight.

##### What is preserved for issue toolchain-runtime-closure (round 4)

The corrected global scope, the provider-aware version rule, the two-rule family
architecture, the D10 policy with its provider correction and neither-satisfies
failure, the validation matrix and the publication gate are all unchanged except
where the four findings required. The question count stays at eleven.

### Reviewer focus for issue toolchain-runtime-closure (round 4)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-09-03T08:41:51+02:00
- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
- Outcome: answer

### Reviewer assessment for issue toolchain-runtime-closure round 4

Round 4 closes the remaining substantive gaps. The normative specification now
uses the actual one-scope loader topology, derives provider candidates from
exact `DT_NEEDED` lookup names and ordered directories, resolves links before
full-content comparison, and keeps cross-SONAME lineage in a concrete declared
family list. The initial `binutils-bfd` and `binutils-opcodes` declarations make
rule 2 implementable and cause the measured two-generation libbfd state to be
refused as intended.

The archive-wide floor now has explicit location constraints. In particular,
the sqlite entry, its waiver removal condition, stale-waiver test, example, and
umbrella hand-off all use the same observable requirement: a file named
`libsqlite3.so.0` under `tools/python` in the resolution scope. The additional
location failure justifies the ninth independent acceptance invariant. The D10
policy, provider-aware version rule, negative and positive controls, and
publication boundary are complete.

No questions are missing. The existing eleven questions cover the full set of
decisions, their options have distinct consequences, and the recommended
answers can be consolidated without another design choice. The remaining
issues are wording-only remnants listed as covered wording: the floor contains
ten SONAMEs rather than nine, and several summary/question phrases still say
“same SONAME” where the normative rule correctly uses candidates for one exact
`DT_NEEDED` lookup name. Those corrections do not change scope, behavior,
evidence, or ownership.

Implementation can proceed after the requestor's normal consolidation applies
those wording corrections. The disposition is convergence-recommended; this is
advisory and leaves consolidation at the durable human gate.

### Question verdicts for issue toolchain-runtime-closure round 4

- Q01: choose A3. The combined derived closure and explicit location-aware
  floor are sufficient; correct the prose count from nine SONAMEs to ten.
- Q02: choose B3. The bounded waiver, observable stale condition, reporting,
  and publication block are complete.
- Q03: choose C3. The sqlite hand-off is mechanical and consistently owned by
  item 6, with item 7 refusing publication while a waiver remains.
- Q04: choose D3. The Debian positive run, positive no-over-refusal control,
  and nine independent negative invariants provide bounded evidence.
- Q05: choose E3 in its two-rule form. Rule 1 is automatic over exact loader
  lookup candidates; rule 2 reads the declared cross-SONAME family list. In
  consolidation, replace the stale “offering one SONAME” shorthand with the
  exact `DT_NEEDED` lookup-name wording.
- Q06: choose F2. The retained measurement settles the OpenSSL version-node
  doubt and the later scope captures correctly delimit what it proves.
- Q07: choose G3. Validation-only repackaging and the mechanical publication
  refusal preserve the requirement boundary.
- Q08: choose H3. The conditional D10 policy names both libstdc++ namespaces,
  the separate libgcc check, zero-spare-node rule, and failure when neither
  candidate generation satisfies the final set.
- Q09: choose J3. Provider-aware `DT_VERNEED` resolution with no host fallback
  is the complete, general invariant.
- Q10: choose K3. Exact loader candidates plus content identity answer the
  automatic case, while the explicit initial family table supplies the
  cross-SONAME relationship ELF cannot encode. Consolidation should call the
  automatic identity a `DT_NEEDED` lookup identity rather than SONAME identity.
- Q11: choose L2. Its nine listed invariants and acceptance table now agree.

No additional question is required, and none of Q01-Q11 is redundant after
consolidation removes the alternatives.

### Convergence evidence for issue toolchain-runtime-closure round 4

Covered wording:

- Change “nine SONAMEs” in Q01's recommendation to “ten SONAMEs”; the floor
  table contains libc, four compat stubs, libstdc++, libgcc, two OpenSSL
  members, and sqlite.
- In the gap-analysis row, Q05/E3, Q10/K3, and the duplicate-provider concrete
  example, replace “one object/provider per SONAME” or “offering one SONAME”
  shorthand with the normative rule's exact concept: candidate paths for one
  exact `DT_NEEDED` lookup name resolving to different content.
- Rewrite gap-to-close item 3 as the two settled checks: duplicate lookup
  candidates under rule 1 and declared cross-SONAME generations under rule 2,
  instead of a singular “family-collision check using SONAME”.
- In umbrella item 6, prefer “the archive floor entry constrained to
  `tools/python`” over “the `tools/python` floor”, because the floor is one
  archive-wide list with a location column.
- During consolidation, remove round-history phrases such as “as rewritten
  twice” and preserve the final rationale without review-process narration.

Convergence rationale: All acceptance semantics, ownership boundaries, evidence requirements, and
failure outcomes are settled. The loader-candidate rule and declared-family
rule are now independently implementable; the current archive's accepted and
refused cases are measured; the sqlite transition is mechanically bounded; and
D10 has an exhaustive two-candidate policy with a failure outcome. The covered
edits only correct counts and terminology already contradicted by the detailed
normative sections. They require no new choice, evidence, or cross-document
scope change, so another automated review round would add no substantive value.

### Writer instructions for issue toolchain-runtime-closure round 4

At the human gate, consolidate the selected answers A3, B3, C3, D3, E3, F2,
G3, H3, J3, K3, and L2. Apply every covered wording correction while retaining
the normative loader-candidate algorithm, initial family table, location-aware
floor and sqlite waiver condition, nine-invariant acceptance matrix, D10
policy, and publication boundary. Remove the open-ended questions through the
owning consolidation workflow; no additional automated review round is needed.

### Final reviewer decision for issue toolchain-runtime-closure round 4

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-4 -->

## Round 4 by human - human-confirmation

- Recorded: 2026-09-03T10:07:29+02:00
- Exchange: specification/issue/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/issue.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: unrecorded
- Reviewer LLM nature: unrecorded
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-4 -->
