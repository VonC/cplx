# Specification review transcript for v0.27.0

- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-08-16T10:06:30+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for issue relocation-force-rpath round 1

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
Review round: 1

### Requestor assessment for issue relocation-force-rpath round 1

This is the first review round for a new issue document. Nothing has been
reviewed before, so no reviewer wording suggestion has been applied yet.

What the specification settles without asking:

- The tag kind. Decision D3 of the umbrella is already resolved on evidence
  (`develop#15`, pikepdf's grafted libjpeg needing RPATH propagation), so
  `patchelf --force-rpath` is stated as a confirmed rule and is not offered as
  an option anywhere in the questions.
- The measured baseline. The `develop#24` probe figures (110 flagged of 388
  inventoried ELFs, 55 per root, zero wheels, `libgcc_s` located under
  `root/lib64`) are treated as measurement, not as inference, and the document
  records which earlier readings they corrected.
- The mechanism in the current script, read from the tree rather than from the
  umbrella: `fix_elf_paths` rewrites an rpath only when the existing value
  matches `*/home/*`, which is exactly why a shipped library carrying no rpath
  is skipped. The umbrella's "line 316" reference predates item 1 and has been
  restated against the current file.

What the ten questions cover, and why each exists:

- Q01 and Q03 are the scope pair. The `/home/` guard doubles as an exclusion of
  RPM-extracted programs and of the vendored patchelf the pass is executing
  from, and removing the guard removes that exclusion silently. Q03 exists
  because the rpath guard and the interpreter guard select the same set today
  and stop doing so the moment the first one widens.
- Q02 is the one hazard the widening extends rather than creates:
  `build_elf_rpath` computes a single value with python's directories first, and
  applying it to every shipped library lets a git-tree library prefer python's
  copies. The duplicated OpenSSL pair is the named case.
- Q04 is the delivery-boundary question item 1 already met once. The headline
  acceptance figure is produced by a probe living in the consuming project, and
  the issue claims to be closable against the currently published archive.
- Q05 is the only production-risk question. Every other item of the collection
  fixes something visible on the agent and leaves RHEL untouched; this one
  changes loader semantics on both targets, and those servers inject a
  host-built monitoring library into every process.
- Q06 to Q08 are the behavior consequences: the lost `LD_LIBRARY_PATH`
  override, what a patchelf failure on a shipped library means now that failure
  restores the defect, and what idempotence must be observed as once the guard
  that provided it is gone.
- Q09 and Q10 are acceptance-wording questions. The literal "110 to zero" is
  only reachable if nothing is excluded, and Q01 is likely to exclude something;
  the eight `OPENSSL_3.x` lines were deferred to this issue by the umbrella's
  item 4 and the document currently records both branches without saying which
  one closes it.

Where the specification is most likely to be wrong or incomplete, stated so the
review can target it:

- The scope predicate is described by the constraints it must satisfy rather
  than by a rule, because Q01 has not been answered. If the reviewer thinks an
  issue document owes a stated boundary here rather than a constrained one, that
  is the first thing to say.
- The RHEL preload reasoning (a root-object `DT_RPATH` being consulted for
  lookups made on behalf of a preloaded library) is derived from documented
  loader precedence, not measured on a server carrying the agent. Q05 exists
  because of that, but the reasoning itself may be wrong and would then change
  the answer rather than the question.
- The acceptance mixes evidence cplx can produce with evidence only the
  consuming project can produce, and Q04 proposes a split rather than applying
  one. The document as written still reads as if all of it were closable here.
- Two claims rest on documented behavior rather than on a run in this
  environment: that patchelf's `--set-rpath` converts `DT_RPATH` to
  `DT_RUNPATH` by default, and that the shipped patchelf supports
  `--force-rpath`. Both are checkable at implementation time and neither is
  measured in this document.

Questions deliberately not asked, so their absence is a decision rather than an
oversight:

- Nothing about which directories `build_elf_rpath` produces, or about
  `$ORIGIN`-relative entries: the confirmed rule freezes the search list, since
  changing it would make the probe figures incomparable.
- Nothing about shipping, pruning or pairing libraries: sub-tasks 1 and 2 of
  work item 3 belong to item 4 of the collection, and Q10 hands it a verdict
  rather than work.
- Nothing about the python wrapper's `LD_LIBRARY_PATH` handling beyond the
  precedence consequence in Q06: that is item 3.
- Nothing about the copy engines: item 1 settled them, and this issue shares
  the file and nothing else.

### Change summary for issue relocation-force-rpath round 1

Round 1: there is no preceding round, so this summarizes how the reviewed
document came to exist rather than what changed in it.

Provenance:

- `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md` is the umbrella. Its
  ordered status table row 2 (`relocation-force-rpath`, Issue, "Relocate with
  RPATH so wheels resolve inside the prefix") was selected after row 1
  (`rsync-cp-fallback`) reached `completed` with both documents named and a
  validation plan opening on `Yes, it is implemented.`.
- `docs/v0.27.0/draft.v0.27.0.relocation-force-rpath.md` is the focused child
  draft created from that row. It carries the split entry, the requirement
  detail verbatim as a blockquote, the Q26 defect row, sub-task 3 of work item
  3, decision D3, the `develop#19` to `develop#24` probe readings, and an
  explicit boundary section against items 1, 3 and 4. The umbrella was not
  modified.
- `docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md` is the reviewed
  document, written from that child draft plus the current source tree.

What the issue adds over the child draft, all of it read from the tree rather
than inherited:

- The exact mechanism of the current pass, with line references against the
  file as it stands after item 1 landed: the `*/home/*` rpath guard at line
  404, the `--set-rpath` call at line 405, the separate interpreter guard at
  line 415, the `find` at line 423 that feeds the walk, the patchelf lookup and
  its non-fatal absent path at lines 301 and 370, and the step 6d call site at
  line 611. The umbrella's own "line 316" reference is superseded, item 1
  having moved the file.
- Why a library with no rpath is skipped, which is the empty `--print-rpath`
  answer failing the `*/home/*` test. This is the measured cause of the
  `develop#24` figure of 110 flagged objects and was not stated anywhere
  before.
- That `build_elf_rpath` computes one value, python's directories first, and
  that `fix_elf_paths` applies that single value to every object it rewrites.
  This is what makes the cross-tree preference of Q02 a real question.
- Two behavior consequences of the forced tag that the umbrella does not
  mention: `DT_RPATH` taking precedence over `LD_LIBRARY_PATH`, and the RHEL
  system preload of `/lib64/liboneagentproc.so` entering the shipped search
  path.
- The three documentation surfaces the change invalidates, named with what each
  currently says: the ELF fix row of `wiki/reference/relocation-tools.md`, the
  rpath presentation of
  `wiki/explanation/why-binaries-remember-the-build-home.md`, and the
  `readelf -d ... RPATH|RUNPATH` check of
  `wiki/how-to/relocate-an-install-to-another-prefix.md`.
- An acceptance section split into what closes in cplx and what is tracked
  downstream, following the shape item 1 converged on.

Ten open questions were then placed by `oqm` and are the reason for this round.
No section of the document has been edited in response to review yet.

### Writer response for issue relocation-force-rpath round 1

Writer response: Round 1: no reviewer feedback exists yet, so there is nothing accepted and
nothing disputed.

The writer's position going into this round:

- The recommended answers attached to the ten questions are recommendations,
  not settled decisions. None of them has been written into the body of the
  issue, so the document can absorb a different answer without a rewrite.
- Two recommendations are held more firmly than the rest, and the reasons are
  worth stating so a disagreement lands on the argument rather than on the
  preference. Q01 recommends a library-only scope because all 110 flagged
  objects are libraries and none is a program, so widening to programs would
  change RHEL behavior with no observed defect to justify it. Q05 recommends a
  measured RHEL observation as a gating criterion because this is the only
  change in the collection whose RHEL side is pure downside risk.
- Q02 and Q10 should be read together. If the reviewer prefers per-tree
  resolution in Q02, the third outcome offered in Q10 (a version node satisfied
  by the other tree's libcrypto) stops being an acceptable result and Q10's
  answer has to move with it.
- Q01, Q03, Q08 and Q09 are one cluster: the scope decision determines whether
  the interpreter question can arise, what the idempotence condition has to
  test, and whether the acceptance figure can be a literal zero. A reviewer who
  changes Q01 should expect the other three to follow rather than treat them as
  independent.
- The writer will accept a wording-only convergence, but notes that four of the
  ten questions (Q01, Q04, Q05, Q09) change what the issue promises, so a
  convergence recommendation that leaves them at their defaults is a decision
  about the requirement and not a formatting judgement.

### Reviewer focus for issue relocation-force-rpath round 1

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer

- Recorded: 2026-08-16T10:27:29+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for issue relocation-force-rpath round 1

The issue is unusually well evidenced. Its account of the current
`fix_elf_paths` implementation matches the source tree, it correctly keeps D3
settled, and it preserves the important distinction between the static
root-object listing and the conclusive live trace. Q01 through Q10 also cover
real consequences rather than reopening the already-settled tag choice.

The specification is not ready to converge, however. Four substantive gaps
remain. First, option 1B states the right evidence-led boundary but does not
define an implementable library predicate: PIE executables and shared objects
can both be `ET_DYN`, while SONAME and `.so` naming are not universal. The
document must state a classification that preserves the 110 measured libraries
without accidentally admitting programs, and it must reconcile the focused
draft's promise that "system-linked binaries stay untouched" with the issue's
intent to patch RPM-extracted libraries.

Second, Q09's justification is contradicted by the recorded baseline. All 110
flags are libraries, none are programs or venv wheels, and option 1B covers all
shipped libraries. A literal zero over the exact develop#24 inventory is
therefore compatible with the recommended safety scope; weakening it to zero
only over a self-selected covered set would make a missed library excludable
after the fact and would no longer support the umbrella's blocking downstream
gate.

Third, Q08's "already correct" wording is incomplete. `--print-rpath` can
return the target string for either `DT_RPATH` or `DT_RUNPATH`. Skipping on
string equality alone can preserve the exact wrong tag this issue exists to
replace. Correctness and the second-run zero-rewrite check must include both
the dynamic tag and the value.

Fourth, several recommendations select combinations that their final answer
labels do not represent: Q04 is 4A plus part of 4C, Q06 is substantively 6C
while labelled 6A, and Q10 is 10A plus 10C. Those are requirement decisions,
not wording polish. The options must be made mutually intelligible and the
answer label must name the complete selected rule. The acceptance also retains
the undefined term "ABI-critical library" after Q09 explicitly rejects it as
an undefined gate; that missing decision needs its own question or an exact
confirmed definition.

The preload concern in Q05 is worth gating on a real RHEL observation, but the
body currently states the provider change as certain before the trace exists.
Loader lookup for a preloaded object's dependencies also depends on that
object's own dynamic tags. State the provider move as the hypothesis Q05 tests,
then require the retained before/after provider paths and an operational check
for the monitoring agent.

### Question verdicts for issue relocation-force-rpath round 1

- **Q01 — necessary; choose 1B in direction, but revise before settling.** The
  measured defect is library-only and the production-risk argument against
  widening programs is sound. Replace "the `.so` objects" and "decided from
  ELF type" with an exact classification that distinguishes loadable shared
  objects from PIE executables and is validated against the 110-object
  inventory. State explicitly how RPM-extracted libraries, Python extension
  modules, versioned SONAME files, static executables, and the patchelf binary
  classify. Reconcile the focused draft's "system-linked binaries stay
  untouched" wording by narrowing it to programs if that is the intended rule.

- **Q02 — choose 2A.** One shared python-first list is the existing deployed
  behavior and keeps this issue inside D3. Add the consequence already implied
  by Q10: for every duplicated family inspected, acceptance records the exact
  provider path, and a cross-tree provider is evidence handed to item 4 rather
  than silently called coherent.

- **Q03 — choose 3A, conditional on the repaired Q01 predicate.** A genuine
  shared library has no `PT_INTERP`, so a library-only widening does not create
  the host-loader/shipped-libc combination. State that property as part of the
  predicate and say that any later widening to programs reopens interpreter
  handling.

- **Q04 — choose 4A, with a precise evidence split.** cplx should retain a
  reproducible recipe and output for archive-only headers, tag/value checks,
  idempotence, failure counts, and shipped-loader listings. The exact 388-object
  inventory, venv imports, live trace, and downstream probe flip remain in the
  consuming project. Do not describe this as "4A combined with 4C" while the
  answer says 4A; either fold retained recipe/output into 4A or make evidence
  retention a separate orthogonal decision.

- **Q05 — choose 5A.** A real RHEL deployment observation is proportionate to
  the only production-only risk. Reword the claimed dependency-provider move
  as a hypothesis until measured, and require the trace to record the
  preloaded object, its own RPATH/RUNPATH state, before/after providers for its
  dependencies, and evidence that the monitoring integration remains
  operational rather than merely that Python starts.

- **Q06 — choose 6C, rewritten as the complete rule.** The selected outcome is
  that no environment escape hatch is restored, plus an audit documenting the
  new precedence and the now-ineffective part of `setenv`. That is option 6C's
  substance, not 6A alone. Make clear that this issue changes documentation,
  not the neighbouring wrapper implementation.

- **Q07 — choose 7C.** Keep installation nonfatal but make partial coverage
  unmissable. Specify separate summary fields or counts for rpath rewrites,
  interpreter rewrites, and rpath failures; acceptance requires zero attempted
  rpath failures. Deliberate scope exclusions must not be counted as successful
  coverage or merged with patchelf failures.

- **Q08 — choose 8C with a mandatory correction.** "Already correct" means
  the object has `DT_RPATH` (not `DT_RUNPATH`) and its value exactly equals the
  target list. The second pass then reports zero covered-object rewrites. A
  matching string under `DT_RUNPATH` must still be converted.

- **Q09 — choose 9B for the exact develop#24 inventory.** The evidence says all
  110 failures are libraries and 1B covers every shipped library, so there is
  no present conflict between safety scope and a literal zero. Preserve the
  umbrella and child-draft promise of 110 to zero. If a refreshed inventory
  discovers a legitimately excluded flagged program, record that as changed
  evidence that reopens the scope or acceptance; do not make exclusions an
  automatic way to satisfy this gate.

- **Q10 — choose a revised 10C.** Any of the three measured verdicts may close
  this issue, but the result must name the libcrypto provider for each libssl.
  Same-tree satisfaction closes the artifact; cross-tree satisfaction or
  surviving nodes become named item-4 defects. Rewrite 10C to include that
  closure rule and answer 10C directly instead of labelling a 10A/10C hybrid as
  10A.

- **Missing Q11 — define the host-resolution gate.** The body and acceptance
  use "ABI-critical library" without defining membership, while Q09 correctly
  says an undefined qualifier cannot gate completion. My choice is: on Debian,
  every resolved ELF dependency observed for the covered archive objects and
  the named venv process must come from the relocated prefix, with any
  unavoidable pseudo-object or host integration listed explicitly by path and
  reason. Reject a free-form "ABI-critical" judgement and reject delegation of
  the definition to the downstream probe, because either permits the gate to
  change without changing this requirement. Keep the RHEL preload exception
  separate under Q05.

### Requested changes for issue relocation-force-rpath round 1

Requested changes:

1. Make Q01 implementable: define the library/program classification, prove it
   selects the 110 measured libraries, and reconcile the focused draft's
   system-linked-binary wording with the intended treatment of RPM libraries.
2. Preserve the literal develop#24 zero target under Q09, and rewrite Q04 so
   cplx and downstream evidence have exact, non-overlapping inventories and
   claims.
3. Correct Q08 so the already-correct predicate tests `DT_RPATH` plus the exact
   value; a matching `DT_RUNPATH` string must not be skipped.
4. Normalize Q04, Q06, and Q10 so each recommendation and final answer names
   one option containing the full selected rule rather than an unlabelled
   combination of options.
5. Add a question or confirmed definition replacing the undefined
   "ABI-critical library" gate with an exact path-based Debian resolution
   contract and explicit exceptions.
6. Keep Q05's real-target gate, but state the preload provider change as a
   hypothesis and require before/after provider evidence plus an operational
   monitoring check.
7. Tighten the body wording from "every ELF the pass rewrites carries
   `DT_RPATH`" to every ELF whose **rpath** the pass rewrites, and make Q07's
   separate rewrite/failure reporting part of cplx acceptance.

### Writer instructions for issue relocation-force-rpath round 1

Apply all requested changes to the issue and its open questions without
reopening D3. In particular, keep Q01's evidence-led library-only direction,
but give it an executable classification; retain the exact 110-to-zero
develop#24 gate; and make tag-plus-value equality the idempotence condition.

Rewrite the option sets for Q04, Q06, and Q10 so the options are materially
distinct and the selected answer label covers the complete selected behavior.
Add the missing host-resolution-definition question (or an equivalently exact
confirmed rule with explicit rationale), and make the RHEL preload wording
observational rather than pre-decided.

Also flag the focused draft's "system-linked binaries stay untouched" sentence
for writer-side cross-document correction, since the selected issue scope
patches RPM-extracted libraries while preserving programs. Then publish a
replacement request for automated round 2. Do not consolidate on this round.

### Final reviewer decision for issue relocation-force-rpath round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-08-16T10:37:25+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for issue relocation-force-rpath round 2

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
Review round: 2

### Requestor assessment for issue relocation-force-rpath round 2

Round 2. Every round 1 requested change was accepted and applied; none was
disputed. Two of them were catches the writer had got wrong rather than
wording preferences, and they are worth naming because they change behavior:

- Q08's skip condition tested the value only, and `--print-rpath` returns the
  value string for either tag. A tree relocated by the current installer carries
  the target string under `DT_RUNPATH` on every object the pass touches, so the
  original wording would have skipped exactly those objects and converted
  nothing. The condition now tests `DT_RPATH` and the value together.
- Q01 named the covered set as "the `.so` objects, decided from ELF type", which
  is not implementable: a position-independent executable is `ET_DYN` like a
  shared object, and the archive carries real files named
  `libgcc_s-11-20240719.so.1` and `libstdc++.so.6.0.29` rather than plain `.so`
  names. The predicate is now `ET_DYN` with no `PT_INTERP`, which is the test
  the loader itself uses, and it is stated per class.

Where each requested change landed:

1. Q01 implementable classification: the predicate, the per-class outcome (RPM
   libraries covered, `lib-dynload` extensions covered, versioned SONAME real
   files covered, every program excluded, statically linked and
   not-dynamically-linked objects excluded and counted apart), and the
   obligation to validate it against the `develop#24` inventory before trusting
   it. Mirrored into the confirmed rule of the issue body.
2. Q09 back to the literal `develop#24` zero, with the reopening clause rather
   than an exclusion escape. The reviewer's argument is accepted in full: the
   tension the question was written for does not exist, since all 110 flags are
   libraries and the predicate covers every shipped library, and a covered-set
   gate would not support the blocking downstream probe this item unlocks.
3. Q04 rewritten so the two columns are disjoint and each names its own
   inventory. cplx closes on headers, tag and value, predicate validation,
   idempotence, the three reported figures and shipped-loader listings; the
   consuming project owns the 388-object inventory, the venv imports, the live
   trace and the probe flip. The retained recipe is folded into 4A rather than
   quoted as a hybrid, and 4C is now a materially different option, building a
   probe tool.
4. Q06 answers 6C, and 6A and 6C were rewritten so they differ materially: 6A
   records the loss in the requirement only, 6C adds the documentation audit and
   bounds it explicitly to documentation, leaving `setenv`'s implementation to
   item 3. Q10 answers 10C, rewritten to carry the three-outcome closure rule
   including the cross-tree provider case.
5. Q11 added: the host-resolution gate is defined positively and by path, with
   exceptions listed by exact path and reason, and the RHEL preload kept outside
   it under Q05. The undefined "ABI-critical library" phrase is removed from the
   body, the examples and the acceptance.
6. Q05 keeps its real-target gate; the body now states the provider move as a
   hypothesis whose outcome also depends on the tags the preloaded object
   carries for itself, and the evidence required is the preloaded object, its own
   tag state, before and after provider paths for its dependencies, and an
   operational monitoring check rather than a process that starts.
7. The body wording is "every ELF whose rpath the pass rewrites", with an
   explicit note that an object whose interpreter alone was rewritten is not
   covered by that criterion, and Q07's three separate figures with a zero
   failure count are now a cplx acceptance criterion.

Cross-document correction, as instructed: the focused draft
`docs/v0.27.0/draft.v0.27.0.relocation-force-rpath.md` read the guard's purpose
as "do not touch what the host provides", paraphrasing the source comment about
system-linked binaries. Read literally that excludes the RPM-extracted libraries
in `root/usr/lib64`, which are the objects the probe flagged and which this scope
covers. The draft now carries a dated correction stating that the distinction is
what ships rather than who built it, and pointing at the requirement as
authoritative.

What round 2 should look at, since round 1's findings are applied:

- Whether the per-class list in Q01 is complete. The classes named are RPM
  libraries, `lib-dynload` extensions, versioned SONAME files, programs,
  statically linked objects and not-dynamically-linked objects. A class the
  archive carries and this list misses would be decided by silence.
- Whether Q11's exception mechanism is sound. The rule is positive and the
  exceptions are recorded during validation rather than enumerated in advance,
  which is deliberate but does mean the requirement states a rule whose instance
  list does not exist yet.
- Whether Q09's reopening clause is strong enough. It says a refreshed inventory
  flagging a program is changed evidence reopening the scope or the target. It
  does not say who decides, or whether the issue can still close in that state.
- Q05 remains the only claim in the document that no run has tested, and it is
  now labelled as such in the body rather than only in the question.

### Change summary for issue relocation-force-rpath round 2

Changes to `docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md` since round 1,
all of them applying round 1's requested changes.

In the gap analysis section:

- The RHEL preload bullet changed from a consequence to a hypothesis. It now
  says documented loader precedence would move the preloaded library's
  dependency providers onto the shipped copies, that whether it actually moves
  depends on the dynamic tags the preloaded object carries for itself, that
  nobody has read them, and that this is the only claim in the issue no run has
  tested.

In the confirmed rule section:

- "The pass writes `DT_RPATH` on every ELF it rewrites" became "on every ELF
  whose rpath it rewrites", with the note that an object may have its
  interpreter rewritten without its rpath being in scope.
- The three-constraint placeholder for the scope predicate was replaced by the
  predicate itself: a shipped library is an `ET_DYN` object with no `PT_INTERP`,
  which is how the loader separates a shared object from a position-independent
  executable, and neither the `.so` suffix nor a SONAME is part of the test.
- A per-class list was added: RPM-extracted libraries covered, `lib-dynload`
  extension modules covered including the `_sqlite3` extension item 6 will add,
  versioned SONAME real files covered, every program excluded whatever built it,
  statically linked objects and anything patchelf reports as not dynamically
  linked excluded and counted apart.
- A validation obligation was added: the predicate must be shown to select all
  110 flagged objects and no program before it is trusted.
- An idempotence rule was added: an object is already correct only when it
  carries `DT_RPATH` and its value equals the target list, and a matching string
  under `DT_RUNPATH` is still converted.
- A shared-search-list rule was added: one value, python first, guaranteeing
  resolution inside the prefix and not within a tool's own tree, with the exact
  provider path recorded wherever the archive carries a duplicated family and a
  cross-tree provider handed to item 4.
- The `OPENSSL_3.x` rule moved from two outcomes to three, each with its own
  closure consequence.
- The RHEL rule now names the measurement: the preloaded object, its own tag
  state, before and after provider paths, and an operational monitoring check
  rather than a process that starts.
- Two rules were added: partial coverage reported as three separate figures with
  exclusions counted apart, and the host-resolution gate defined by path with
  exceptions listed explicitly, replacing "ABI-critical library" which is now
  rejected in the body as it already was in the questions.

In the gap-to-close list:

- Item 2 now names the predicate and states that the interpreter guard stays as
  it is because a shared library has no `PT_INTERP` to rewrite, so the two
  guards cannot disagree under this scope.
- A new item 3 requires the skip condition to test tag and value together.
- Item 4 requires the twice-plus-`--force` run to report zero rpath rewrites
  over the covered set.
- The reporting item became a split into three figures rather than a note that
  the count stops being comparable.
- The wiki item for `why-binaries-remember-the-build-home.md` gained the
  now-ineffective part of the `setenv` export. Items renumbered to nine.

In the examples:

- Four added: a position-independent executable excluded and counted as
  excluded, the vendored patchelf excluded by predicate rather than by name, an
  RPM-extracted library covered, and a `DT_RUNPATH` already holding the target
  string still rewritten.
- The `OPENSSL_3.x` example now covers three outcomes with their consequences.
- The trace example replaced "no ABI-critical library initialized from a host
  path" with "every resolved dependency provided from the relocated prefix".
- The second-run example asserts zero rpath rewrites rather than "the same
  tree".
- The RHEL example names the preload evidence.

In the acceptance:

- Rewritten as two disjoint columns with a preamble stating that neither
  restates the other's claim. The cplx column holds headers, predicate
  validation against the flagged set, the named library case, the three figures
  with a zero failure count, idempotence on tag and value, the `OPENSSL_3.x`
  verdict naming providers, the RHEL preload measurement, the patchelf-absent
  path and the three wiki pages. The downstream column holds the exact
  `develop#24` zero with its reopening clause, the venv imports, the live trace
  with exceptions listed by path, the interim deletion and the probe flip.

In the open questions, replaced as a whole:

- Q01, Q04, Q06, Q08, Q09, Q10 rewritten; Q02, Q03, Q05, Q07 amended; Q11 added.
  Answers now stand at 1B, 2A, 3A, 4A, 5A, 6C, 7C, 8C, 9B, 10C, 11A, each label
  naming one option that contains the complete selected rule.

In `docs/v0.27.0/draft.v0.27.0.relocation-force-rpath.md`:

- A dated correction was added to the paragraph reading "do not touch what the
  host provides", recording that it would exclude the RPM-extracted libraries
  this scope covers, that the distinction is what ships rather than who built
  it, that the idempotence half of the guard's purpose stands, and that the
  requirement is authoritative.

### Writer response for issue relocation-force-rpath round 2

Writer response: All seven requested changes are applied. There is no disagreement to record on
any of them, and two were corrections of writer error rather than differences of
preference.

The Q08 catch is the one that mattered most. `--print-rpath` returns the value
for either dynamic tag, and the current installer writes the target value under
`DT_RUNPATH` on every object it touches. A skip condition testing the string
alone would therefore have skipped precisely the objects this issue exists to
convert, on any tree relocated by the current installer, and the pass would have
reported a clean second run while changing nothing. The condition now tests
`DT_RPATH` plus the exact value, and the reasoning is written into the question
so the trap is visible rather than merely avoided.

The Q01 catch is the second. "The `.so` objects" and "decided from the ELF type"
were both wrong: a position-independent executable is `ET_DYN` exactly like a
shared object, and the archive's real library files carry versioned names rather
than plain `.so` ones. The predicate is now `ET_DYN` with no `PT_INTERP`. That
single clause also supplies the Q03 safety property, which is why it is stated
twice on purpose.

On Q09 the reviewer's argument is accepted without reservation, and it corrects
a reasoning error rather than a wording one. The question was written on the
assumption that the safety scope and the literal zero could conflict; they
cannot, because every one of the 110 flags is a library and the predicate covers
every shipped library. Weakening the gate would have made an exclusion a way to
satisfy it and would not have supported the blocking downstream probe this item
unlocks.

On the labelling of Q04, Q06 and Q10, the reviewer is right that a hybrid answer
is a requirement decision hidden in a formatting habit. The options were
rewritten so the selected label carries the complete rule, which changed the
option texts and not only the answer lines: 4C is now building a probe tool
rather than retaining a recipe, 6A is recording the loss without the
documentation audit, and 10A is the two-outcome verdict that cannot express the
cross-tree case.

Q11 was added as recommended, with the reviewer's own choice as option 11A. The
one place the writer went beyond the instruction is that 11A explicitly keeps
the RHEL preload outside the rule, so the single legitimate host integration
cannot be used as an argument for making the rule vague.

Two things are offered for round 2 rather than claimed as settled. The per-class
list in Q01 is complete as far as the writer knows the archive's contents, but a
class it misses would be decided by silence rather than by rule. And Q09's
reopening clause names the condition without naming who decides or whether the
issue can still close in that state, which may be a gap the reviewer wants
closed.

### Reviewer focus for issue relocation-force-rpath round 2

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-08-16T13:26:49+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for issue relocation-force-rpath round 2

Round 1's corrections are present and materially improve the issue. The
tag-plus-value idempotence rule now closes the `--print-rpath` trap; Q04, Q06
and Q10 each name the complete selected option; Q09 again supports the
umbrella's literal zero; Q11 replaces the subjective "ABI-critical" gate; and
the preload claim is correctly labelled as an unmeasured hypothesis. The
focused draft also contains the dated provenance correction requested in round
1.

The document cannot converge yet because Q01 introduced a regression while
applying the classification fix. The original option 1B widened the pass to
every library while retaining the existing `/home/`-selected executable
behavior. The amended option instead says "every shared library and no
program" and Gap item 2 replaces the old guard with that predicate. That would
leave the Python executable unmodified, despite the issue's central D3 example
requiring that root object to change from `DT_RUNPATH` to `DT_RPATH`. It would
also fail to migrate an already-relocated prefix whose Python executable
already holds the target value under `DT_RUNPATH`, because that program no
longer contains `/home/` and is outside the new library predicate.

The correct selection is additive: retain the current builder-anchored program
case; add every dynamically linked `ET_DYN` object without `PT_INTERP`; and add
the migration case for a program carrying the exact target value under
`DT_RUNPATH`. Skip only the exact target `DT_RPATH`. Other programs remain
excluded. Q03 must then state the interpreter invariant for the preserved and
migration program cases instead of claiming every covered object has no
interpreter.

Four smaller but still substantive closure gaps remain. Q04 calls the two
inventories non-overlapping even though the downstream 388-object inventory
contains the same 110 archive libraries whose predicate cplx validates; the
responsibilities and claims can be disjoint, but the object sets cannot. Q07
promises three figures while also saying exclusions and not-dynamically-linked
objects are "counted apart", which requires at least one additional reported
bucket. Q09 does not say that changed evidence blocks closure pending a reviewed
requirement amendment. Q11 says exceptions cannot drift, then permits the
validator to create their instance list during validation, which is exactly a
gate change without a requirement change.

Finally, Q05's "monitoring integration remains operational" is not yet an
observable acceptance criterion, and the new ELF predicate does not state how
`install_pkg.sh` evaluates `ET_DYN` and `PT_INTERP` without adding `readelf` to
the audited host-tool contract. Both need an exact evidence or dependency
boundary before implementation can proceed.

### Question verdicts for issue relocation-force-rpath round 2

- **Q01 — necessary, but none of the current options is complete.** Keep 1B's
  library classification, but restore its additive meaning. My answer is a
  revised 1B: rewrite an rpath when the object is a dynamically linked
  `ET_DYN` object without `PT_INTERP`, when its existing rpath remains
  builder-anchored under `/home/`, or when a program carries the exact target
  value under `DT_RUNPATH` from an earlier relocation. Skip only an exact
  target `DT_RPATH`; leave every other program untouched. This preserves the
  Python root object's D3 conversion, handles fresh and already-relocated
  prefixes, and still avoids widening RPM programs.

- **Q02 — choose 2A.** The shared python-first list and provider-path evidence
  remain appropriate once Q01 restores the program branch.

- **Q03 — choose a revised 3A.** The newly added library population cannot
  create an interpreter mismatch because it has no `PT_INTERP`. The preserved
  builder-anchored program population keeps the existing interpreter rewrite,
  and the migration population must be verified to carry the target
  interpreter after the pass. State those cases explicitly; the current claim
  that the Q01 predicate covers only objects without an interpreter is no
  longer true once D3 is preserved.

- **Q04 — choose 4A after correcting “disjoint.”** Make ownership and claims
  disjoint, not inventories. cplx proves selector membership, tag/value,
  reporting and archive-object resolution; the consuming project proves the
  full 388-object zero, venv imports, trace and probe flip. The downstream set
  intentionally contains the 110 archive objects examined by cplx, so call
  that shared baseline out rather than asserting non-overlap.

- **Q05 — choose 5A, but name the operational signal.** The dependency-provider
  trace is exact. Replace “monitoring remains operational” with the concrete
  health query, log/event, server-side status, or owning-team confirmation that
  is available on the deployment target, including who records it. If no such
  evidence is available, state that the requirement is blocked on obtaining it
  rather than allowing a reviewer to interpret process startup as health.

- **Q06 — choose 6C.** Its option and answer now carry the complete behavior
  and documentation boundary.

- **Q07 — choose a revised 7C.** Publish an exact report schema. At minimum it
  needs `rpath rewritten`, `interpreter rewritten`, `rpath failed`, and
  `excluded/not dynamically linked` as four distinct buckets; if “already
  correct” is reported, name it separately too. Three figures cannot also
  count exclusions apart. Define which classification or inspection errors
  are failures rather than exclusions so a malformed covered library cannot
  disappear into the latter bucket.

- **Q08 — choose 8C.** Tag plus exact value is the right idempotence rule. Apply
  it to the additive Q01 selection so a target-valued `DT_RUNPATH` program is a
  migration candidate, not an excluded program.

- **Q09 — choose 9B with a fail-closed reopening rule.** If a refreshed
  inventory flags a program or otherwise invalidates the measured scope, this
  issue cannot close. The writer must amend the scope or target through a new
  reviewed specification round and rerun validation; a validator cannot choose
  between them ad hoc.

- **Q10 — choose 10C.** The three provider-aware outcomes and handoff to item 4
  are now complete.

- **Q11 — choose a fail-closed revision of 11A.** Name any expected pseudo-
  objects now. Any new filesystem provider outside the prefix fails validation
  and blocks closure until its exact path and reason are added through a
  reviewed requirement amendment. A validator may record evidence but may not
  authorize a new exception; otherwise the exception list can drift without
  this requirement changing, contrary to 11A's rationale.

- **Missing Q12 — how the ELF predicate is evaluated on supported hosts.** The
  audited mandatory host-tool list contains `head` and `od`, but not `readelf`.
  My answer is to keep the existing host-tool contract: implement the predicate
  with the shipped patchelf and already-mandatory tools, and prove the class
  results against the measured inventory. If the implementation instead needs
  `readelf`, the requirement must add it to the host contract and provide
  Debian 12 and RHEL 9.8 availability evidence; it cannot arrive silently in
  design or code.

### Requested changes for issue relocation-force-rpath round 2

Requested changes:

1. Rewrite Q01 and the body as an additive selector that preserves fresh
   builder-anchored programs, converts already-relocated target-valued
   `DT_RUNPATH` programs, and adds every dynamically linked library. Restore
   the Python executable's D3 path in examples and acceptance.
2. Revise Q03 to state and verify the interpreter invariant for the library,
   fresh-program and migration-program populations.
3. Correct Q04 from non-overlapping inventories to disjoint evidence ownership
   and claims, explicitly acknowledging the shared 110-object baseline.
4. Give Q07 an exact reporting schema with exclusions separate from the three
   existing figures, and define classification/inspection failure handling.
5. Make Q09 and Q11 fail closed: changed inventory or a new host-path exception
   blocks closure until a reviewed requirement amendment authorizes the new
   rule and validation is rerun.
6. Replace Q05's generic monitoring-health phrase with an exact observable,
   evidence owner and retained result.
7. Add Q12 or an equivalent confirmed constraint governing how the ELF
   predicate is implemented without silently adding `readelf` or another host
   dependency.
8. Complete the focused-draft correction by replacing its remaining Definition
   of Done statement that “system-linked binaries stay untouched” with the
   precise additive program/library rule.

### Writer instructions for issue relocation-force-rpath round 2

Apply the requested changes without reopening D3, the shared search-list
decision, the environment-precedence decision, or the provider-aware OpenSSL
verdict. The first repair is mandatory: restore the existing executable rpath
rewrite and add the already-relocated `DT_RUNPATH` migration case while keeping
the new library classifier. Update every body section, example, acceptance row,
Q01 and Q03 consistently so the Python root object still becomes `DT_RPATH`.

Then make the evidence gates executable: use disjoint ownership rather than
impossible non-overlapping inventories, define the report buckets, require a
reviewed amendment for changed scope or new host exceptions, name the RHEL
monitoring-health observable, and settle the predicate's host-tool boundary.
Update the remaining stale focused-draft Definition of Done sentence as part of
the accepted cross-document correction.

Publish a replacement request for automated round 3 after these substantive
changes. Do not consolidate on round 2.

### Final reviewer decision for issue relocation-force-rpath round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-08-16T17:18:40+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for issue relocation-force-rpath round 3

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
Review round: 3

### Requestor assessment for issue relocation-force-rpath round 3

Round 3. All eight round 2 requested changes are applied, none disputed. The
first was a regression the writer introduced in round 2 while applying a round 1
correction, and it deserves to be named plainly rather than folded into a list.

Round 1's option 1B widened the pass to libraries **while retaining** the
existing `/home/`-selected program behavior. Applying round 1's classification
fix, the writer rewrote it as "every shared library and no program" and dropped
the retention clause. That selector would have left the python ELF unconverted.
The python ELF is a program; it is the root object whose `DT_RPATH` governs
every lookup of the process; converting it is what D3 buys. So the round 2
document would have given a search path to all 110 flagged libraries, brought
the listing to zero, passed every library-side criterion it stated, and left the
wheels resolving host-side. It would also have made an already-relocated prefix
unmigratable, since its python executable holds the target value under
`DT_RUNPATH`, names no builder, and matches no library test.

The selector is now additive over three populations, and the shape of the
document changed with it rather than only the wording of Q01:

- library population: dynamically linked `ET_DYN` with no `PT_INTERP`;
- fresh-program population: the existing `/home/` guard, preserved unchanged,
  which is what selects the python and git executables on a fresh archive;
- migration population: a program whose `DT_RUNPATH` already holds the exact
  target value from an earlier relocation.

1. Only an object already carrying the exact target value under `DT_RPATH` is
   skipped. Every other program, RPM-extracted ones included, stays untouched. The
   validation obligation moved with it: the selector must be shown to select all
   110 flagged libraries **and the python ELF**, which is the check that would have
   caught the round 2 regression before publication.

   Where the other seven landed:

2. Q03 rewritten. The round 2 claim that every covered object lacks `PT_INTERP`
   is false under an additive selector, since two populations are programs. The
   invariant is now stated per population, and the migration population is
   verified after the pass to carry the shipped interpreter, that being the one
   population whose interpreter this pass never writes.
3. Q04 corrected from non-overlapping inventories to disjoint ownership and
   claims. The shared 110-object baseline is named as the point of contact: cplx
   proves selector membership, tag and value, the buckets and archive-object
   resolution; the consuming project proves the 388-object zero, the venv
   imports, the trace and the probe flip; neither may be quoted for the other's
   claim.
4. Q07 given an exact six-bucket schema: `rpath rewritten`,
   `interpreter rewritten`, `rpath failed`, `already correct`, `excluded`,
   `not dynamically linked`. Every walked ELF lands in exactly one, and a
   classification or inspection error counts as `rpath failed`, closing the hole
   where a malformed covered library would land in a benign bucket.
5. Q09 and Q11 now fail closed. Changed inventory evidence blocks closure until
   a reviewed amendment; a new outside-prefix provider blocks validation until
   its path and reason are added by amendment. In both cases a validator records
   evidence and may not authorize the change.
6. Q05 names the observable: one of a health or status query reporting the agent
   attached to the relocated process, an agent-side log or event recording that
   attachment, or written confirmation from the owning team, with the producer
   named and the raw result retained, and an explicit blocked branch if none can
   be obtained.
7. Q12 added. The audited host-tool contract carries `head` and `od` and not
   `readelf`, and item 1 spent four rounds establishing that list, so a
   predicate needing a new program is a requirement change. The selector must be
   evaluable with the shipped patchelf and the already-mandatory tools; adding
   one requires an amendment with Debian 12 and RHEL 9.8 availability evidence.
8. The focused draft's remaining Definition of Done sentence is corrected. Its
   "system-linked binaries stay untouched" now reads as the three populations
   plus the explicit statement that every other program, RPM-extracted ones
   included, stays untouched.

What round 3 should look at:

- Whether the migration population is correctly bounded. It fires on an exact
  value comparison against the list `build_elf_rpath` computes, so it depends on
  that list being computed identically across versions. If a future change to
  the directory set alters the value, a previously relocated prefix stops
  matching and silently falls out of the population rather than failing.
- Whether the post-pass interpreter check on the migration population is the
  right assertion, or whether it should be a precondition that excludes an
  object rather than a check that reports one.
- Whether the six buckets are exhaustive. The claim that every walked ELF lands
  in exactly one is a claim about a partition, and the writer believes it holds
  for the states the pass can observe, but it has not been tested against a
  real tree.
- Q12 constrains the implementation from a requirement, which this document type
  normally avoids. The justification is that the host-tool contract is itself a
  requirement-level promise, but the boundary is worth a second reading.

### Change summary for issue relocation-force-rpath round 3

Changes to `docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md` since round 2,
applying round 2's eight requested changes.

Confirmed rule section:

- The library-only predicate is replaced by the additive selector, introduced
  with the reason it must be additive: the python ELF is a program, it is the
  root object whose `DT_RPATH` governs the process, and a library-only selector
  would delete the D3 mechanism while appearing to widen the pass. The three
  populations are stated with their own names and definitions.
- A skip rule was added: only an object already carrying the exact target value
  under `DT_RPATH`. Every other program stays untouched.
- The per-class list was rewritten around the populations. RPM libraries and
  `lib-dynload` extensions map to the library population; the python and git
  executables map to the fresh-program population on a fresh archive and to the
  migration population on an already-relocated prefix; RPM-extracted programs
  and the vendored patchelf match no population and are excluded by rule.
- The validation obligation now requires the selector to select all 110 flagged
  libraries and the python ELF, where round 2 required 110 libraries and no
  program.
- The idempotence rule was extended: a target-valued `DT_RUNPATH` is rewritten
  by the library population on a library and is what the migration population
  exists to catch on a program.
- A host-tool boundary rule was added, naming `head` and `od` as present in the
  audited contract and `readelf` as absent, and requiring an amendment with
  availability evidence before any new program is depended on.
- An interpreter invariant rule was added, stated per population, with the
  post-pass check on the migration population.
- The monitoring rule replaced "the monitoring integration must be shown still
  operational" with three named observable forms, a named producer, a retained
  raw result, and an explicit blocked branch.
- The reporting rule replaced three figures with the six-bucket schema, the
  exactly-one-bucket claim, and the rule routing classification and inspection
  errors to `rpath failed`.
- The host-resolution rule now names its expected exceptions,
  `linux-vdso.so.1` and the loader under its pre-relocation name, and fails
  closed: any other outside-prefix provider blocks closure until added by
  reviewed amendment, and a validator may not authorize one.

Gap-to-close list, renumbered to eleven:

- Item 2 now extends the guard rather than replacing it, spelling out the three
  branches.
- Item 3 is new: the interpreter guard stays as it is, with the per-population
  reasoning.
- Item 4 states the skip condition and names the migration case.
- Item 7 is new: evaluate the selector with the shipped patchelf and the audited
  tools, listing what the pass already calls.
- Item 8 replaces the three-figure split with the six buckets and the error
  routing.
- Item 9 asks the wiki reference to record the three populations and the
  buckets, not only the tag kind.

Examples:

- The python ELF now appears three times, once per population plus the
  `already correct` case on a third run, with the D3 consequence spelled out.
- An RPM-extracted program with a distribution rpath was added as `excluded`.
- The patchelf example is restated as matching no population rather than as
  excluded by predicate.
- A classification or inspection error example was added, landing in
  `rpath failed`.
- A `linux-vdso.so.1` example was added as a named exception, and an
  outside-prefix provider example as a closure blocker.
- The RHEL example now names the monitoring observable and its owner.

Acceptance:

- The preamble was rewritten from disjoint evidence to disjoint ownership and
  claims, stating that the object sets overlap by design and naming the shared
  110-object baseline as the point of contact.
- A criterion was added and placed first: the python ELF carries `DT_RPATH`
  after the pass, from a fresh archive and from a v0.26.0-relocated prefix
  alike, with the note that this is the object a library-only selector would
  silently leave behind.
- The selector criterion now requires the 110 libraries plus the python and git
  executables, and that every other program is untouched.
- The reporting criterion moved to the six buckets with a zero `rpath failed`.
- A migration-interpreter criterion was added.
- A host-tool criterion was added.
- The monitoring criterion was split from the preload trace criterion and now
  requires the named observable, its owner, and a retained result, with the
  blocked branch stated.
- The downstream column's reopening clause now fails closed through a reviewed
  amendment.

Out of scope:

- The interpreter entry was corrected: it is not reopened, but this issue does
  add the post-pass migration check.
- An entry was added for programs carrying neither a builder-anchored rpath nor
  the target value, RPM-extracted programs among them.

Open questions, replaced as a whole:

- Q01 and Q03 rewritten around the additive selector; Q04, Q05, Q07, Q09 and Q11
  rewritten to their fail-closed or named-observable forms; Q08 amended to name
  the migration case; Q02, Q06 and Q10 carried unchanged in substance; Q12
  added. Answers stand at 1B, 2A, 3A, 4A, 5A, 6C, 7C, 8C, 9B, 10C, 11A, 12A.

In `docs/v0.27.0/draft.v0.27.0.relocation-force-rpath.md`:

- The remaining Definition of Done sentence "system-linked binaries stay
  untouched" is corrected to the three-population rule with an explicit
  statement that every other program stays untouched, dated and cross-referenced
  to the requirement, completing the correction begun in round 1.

### Writer response for issue relocation-force-rpath round 3

Writer response: All eight requested changes are applied. Nothing is disputed.

On the first one the reviewer is simply right, and the failure mode is worth
recording because it is a general one. Round 1 asked for an implementable
classification; the writer produced one and, in the same edit, silently narrowed
the selector from "the current guard plus libraries" to "libraries". The
classification was the visible part of the change and the scope was the
invisible part, and only the scope mattered to whether the issue works. The
result would have passed every criterion the round 2 document stated: all 110
flagged libraries covered, the listing at zero, the named library case
resolving inside the prefix. It would have failed at the only thing the issue
exists to do, because the root object whose rpath governs the process is a
program.

Two consequences were followed through rather than patched at the point of
complaint. Q03's invariant had to be rewritten, since "every covered object has
no interpreter" was true only under the narrowed selector. And the acceptance
now leads with the python ELF rather than with the library case, so the first
thing a validator checks is the object whose omission would be invisible.

The migration population is the writer's own addition beyond the literal
instruction, and it is worth flagging as such. The reviewer named it, and the
reason it matters is that the prefixes most in need of this fix are the ones
already relocated by v0.26.0: those carry the target value under `DT_RUNPATH`,
name no builder, and are programs, so they match neither the old guard nor a
library test. Without that branch the fix would work only on prefixes installed
from scratch.

On Q12 the writer notes one boundary concern rather than a disagreement. The
question constrains the implementation from a requirement document, which this
type normally leaves to design. The justification is that the audited host-tool
contract is itself a requirement-level promise that item 1 spent four review
rounds settling, so enlarging it cannot be a design detail. If the reviewer
prefers this as a design constraint instead, the requirement can state only the
promise, that the host-tool contract does not grow without an amendment, and
leave the technique out entirely.

Three things are offered for round 3 rather than claimed as settled. The
migration branch fires on an exact value comparison, so it silently stops
matching if a future change alters the directory list rather than failing
loudly. The post-pass interpreter check on the migration population may belong
as a precondition that excludes an object instead of a check that reports one.
And the six buckets are asserted to partition every walked ELF, which is a claim
about states the pass can observe and has not been run against a real tree.

### Reviewer focus for issue relocation-force-rpath round 3

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-08-16T17:36:57+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for issue relocation-force-rpath round 3

Round 3 repairs the load-bearing regression from round 2. The additive selector again reaches the python root object on both a fresh archive and a v0.26.0-relocated prefix, and the revisions to Q03, Q04, Q05, Q09, Q11, Q12, the acceptance order, and the focused draft substantially improve the specification.

The document is not yet convergence-ready because Q07's claimed partition cannot be implemented as written. Rpath and interpreter processing are independent guards in the unchanged pass. A fresh program can therefore be both `rpath rewritten` and `interpreter rewritten`; the confirmed rule also expressly allows an object whose interpreter is rewritten while its rpath is outside the selector, making it both `excluded` and `interpreter rewritten`. An interpreter rewrite can fail independently, but the six-bucket schema has no interpreter-failure outcome. Consequently, “every walked ELF lands in exactly one” is false and a validator cannot reconcile the report to the walk.

Two selector statements need to be made exact at the same time. The fresh-program branch is named as a program population but its predicate only tests the rpath, so a builder-anchored library satisfies both the library and fresh-program branches while Q03 reasons as if the populations classify objects uniquely. Also, “every other program stays untouched” overstates an rpath-selection rule because the unchanged interpreter guard may still rewrite such a program. These can be corrected without changing the selected rpath set.

The migration branch is sound for the acceptance case actually promised here: a v0.26.0-relocated prefix, while `build_elf_rpath` remains unchanged. The broader wording “an earlier relocation” is not sound across a future directory-list change, because an old exact value would silently cease to match. Bound the present promise to the known predecessor and make a future list change carry its own migration rule.

No new decision question is required. Q01, Q03, Q05, and Q07 already own these points, but their accepted wording and the confirmed rule need the concrete corrections below.

### Question verdicts for issue relocation-force-rpath round 3

- Q01 — keep 1B. The additive direction, preservation of the existing selected set, and v0.26.0 migration case are correct. Make the fresh branch explicitly a program predicate and bound the exact-value migration promise to the predecessor list it can recognize.
- Q02 — agree with 2A.
- Q03 — agree with 3A. The migration interpreter assertion belongs after selection and must block acceptance when false; excluding the object as a precondition would preserve the wrong `DT_RUNPATH` and defeat D3. Give a failed assertion an explicit report and validation outcome.
- Q04 — agree with 4A. The ownership/claim split and shared 110-object baseline are now precise.
- Q05 — agree with 5A. Tighten the written-confirmation form so it confirms attachment and reporting for the exact relocated process and validation run, not merely general agent support.
- Q06 — agree with 6C.
- Q07 — agree with 7C's non-fatal, explicit-reporting intent, but not with the six mutually exclusive buckets as written. Use independent rpath and interpreter dispositions, or enumerate composite object states; the former is clearer.
- Q08 — agree with 8C.
- Q09 — agree with 9B.
- Q10 — agree with 10C.
- Q11 — agree with 11A.
- Q12 — agree with 12A. Protecting the published host-tool contract is a requirement constraint; design still owns the byte-level technique.

### Requested changes for issue relocation-force-rpath round 3

Requested changes:

1. Replace Q07's impossible single six-bucket partition with a model that represents the two independent operations. The recommended form is two per-object dispositions: every walked ELF has exactly one rpath disposition (`rewritten`, `failed`, `already correct`, `excluded`, or `not dynamically linked`) and exactly one interpreter disposition (`rewritten`, `failed`, or `unchanged/not applicable`, with more precise names if useful). A classification or inspection failure belongs in a failed disposition and never a benign one. Show how a fresh program records both successful rewrites, how an interpreter-only rewrite is represented, and how an rpath failure plus an interpreter success is represented. Require both failure dispositions to be zero in acceptance and reconcile each axis to the walked-ELF total. If a single per-object partition is retained instead, enumerate the composite states explicitly; the current six names cannot be declared mutually exclusive.

2. Route the Q03 migration-interpreter assertion through that reporting model. Keep it as a post-selection assertion rather than an exclusion: a migration candidate with the wrong interpreter must be reported as a failed invariant and must block cplx acceptance. State the install-time observation (warning/report) and the validation consequence. Do not classify the object as `excluded`, because leaving its target-valued `DT_RUNPATH` in place would defeat D3.

3. Make the population predicates match their names and Q03's reasoning. Define the fresh-program population as a program whose rpath remains builder-anchored, not merely any object with that rpath. Builder-anchored libraries remain selected through the library population, so this clarification preserves the rpath-selected set. Then replace every claim that “every other program stays untouched” with the exact claim that every other program's rpath is untouched by the new selector; the unchanged interpreter guard may still rewrite `PT_INTERP`. Apply the correction to the confirmed rule, Q01, acceptance, out-of-scope wording, and the focused draft.

4. Bound the migration promise to what this issue can recognize. State that the exact-target `DT_RUNPATH` branch migrates a v0.26.0-relocated prefix because this issue leaves `build_elf_rpath` unchanged and therefore computes the same list. Replace unqualified claims about any “earlier relocation” with that bounded statement. Record that any later change to the directory list must define and validate recognition of its predecessor value rather than silently inheriting this exact-current-value predicate.

5. In Q05 and acceptance, define the written-confirmation alternative as confirmation from the owning team that the agent was observed attached to, and reporting for, the exact relocated process in the identified validation run. Retain the confirmation itself as raw evidence. This closes the remaining reading under which a generic statement that the monitoring product is supported could satisfy the criterion.

### Writer instructions for issue relocation-force-rpath round 3

Retain decisions 1B, 2A, 3A, 4A, 5A, 6C, 7C, 8C, 9B, 10C, 11A, and 12A. Do not reopen D3 or the accepted scope. Amend the confirmed rule, implementation gaps, examples, acceptance, affected question text, and focused draft wherever the requested changes alter a repeated claim. Keep the report non-fatal as Q07 requires, but make every outcome auditable and make both failure dimensions zero in cplx acceptance.

### Final reviewer decision for issue relocation-force-rpath round 3

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-08-16T17:53:57+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for issue relocation-force-rpath round 4

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
Review round: 4

### Requestor assessment for issue relocation-force-rpath round 4

Round 4. All five round 3 requested changes are applied, none disputed. Round 3
accepted every decision (1B, 2A, 3A, 4A, 5A, 6C, 7C, 8C, 9B, 10C, 11A, 12A) and
found the reporting model unimplementable, which was a modelling error rather
than a wording one.

The pass performs two operations under two independent guards, and this issue
deliberately keeps them independent. So an object can be rewritten on both axes,
on one, or on neither, and an interpreter rewrite can fail on its own. Round 3's
six-name partition had no slot for a rpath failure alongside an interpreter
success, and its central claim, "every walked ELF lands in exactly one", was
false for the commonest object in the tree: a fresh program is rewritten on both
axes. A validator could not reconcile the report to the walk.

Q07 now reports two independent dispositions:

- rpath: `rewritten`, `failed`, `already correct`, `excluded`,
  `not dynamically linked`;
- interpreter: `rewritten`, `failed`, `unchanged`, `not applicable`;
- plus the migration-interpreter invariant, counted separately.

1. Each axis sums to the number of walked ELFs, so the report reconciles to the
   walk twice over. The three pairs a single partition could not express are named
   in the body and in the examples: rewritten on both, `rpath excluded` with
   `interpreter rewritten`, and `rpath failed` with `interpreter rewritten`. A
   classification or inspection error takes the `failed` disposition on the axis it
   blocked, never a benign one. Acceptance requires both failure dispositions and
   the invariant count to be zero.

   The other four:

2. Q03's migration-interpreter assertion is routed through that model as a
   post-selection invariant. A failing object keeps its rpath rewritten, warns at
   install time naming the object, is counted in its own figure, and blocks cplx
   acceptance. It is never reclassified as excluded. The reasoning is now stated
   in the question rather than assumed: excluding it would leave the
   target-valued `DT_RUNPATH` in place, so the cautious-looking rule is the only
   one that preserves the defect D3 exists to remove. Option 3C was added to the
   option set precisely so that trap is on the record rather than merely avoided.
3. The fresh-program branch is now a program predicate, so the three populations
   classify an object uniquely and Q03 can reason per population. A
   builder-anchored library is still selected, by the library branch, so the
   selected rpath set is unchanged by the clarification. Every "every other
   program stays untouched" claim became "every other program's rpath", in the
   confirmed rule, Q01, the acceptance, the out-of-scope list and the focused
   draft, because the unchanged interpreter guard may still rewrite a
   `PT_INTERP` this selector never reaches.
4. The migration promise is bounded to a v0.26.0-relocated prefix, which is the
   predecessor this issue can recognize because it leaves `build_elf_rpath`
   unchanged and therefore computes the identical list. An out-of-scope entry
   records that a later change to that list owes its own predecessor recognition
   and its own validation rather than inheriting this exact-current-value test.
5. Q05's written-confirmation form now requires the owning team to state that it
   observed the agent attached to, and reporting for, the exact relocated
   process in the identified validation run, with the confirmation text itself
   retained. An example was added showing the answer that does not qualify, a
   statement about what the monitoring product supports in general.

What round 4 should look at:

- Whether the two disposition vocabularies are complete for the states the pass
  can produce. The interpreter axis in particular has four values, and
  `unchanged` versus `not applicable` is a distinction the current code does not
  make explicitly: it tests whether the old value contains `/home/` and whether
  it differs from the target, so an object with no `PT_INTERP` and an object
  whose interpreter is already correct both simply fail the condition.
- Whether the migration-interpreter invariant should also be reported when it
  passes, as a count of migration objects checked, rather than only when it
  fails. As written only the failure count is specified, so a zero could mean
  either "all correct" or "no migration objects present".
- Whether bounding the migration branch to v0.26.0 needs a stated behavior when
  the value matches neither the current list nor v0.26.0's. Such an object
  currently falls out of all three populations and reports as `rpath excluded`,
  which is correct but silent.
- Q12 still constrains the implementation from a requirement. Round 3 agreed the
  host-tool contract is requirement-level, so this is settled, but the boundary
  remains the one place this document reaches toward design.

### Change summary for issue relocation-force-rpath round 4

Changes to `docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md` since round 3,
applying round 3's five requested changes.

Confirmed rule:

- The fresh-program population now requires the object to be a program as well
  as builder-anchored, with a sentence explaining that this makes the three
  populations classify uniquely while leaving the selected rpath set unchanged,
  since a builder-anchored library is selected by the library branch.
- The migration-program population drops "from an earlier relocation" and states
  the bounded promise: it migrates a v0.26.0-relocated prefix because this issue
  leaves `build_elf_rpath` unchanged and computes the identical list, and a
  later change to the directory list must define and validate recognition of its
  own predecessor value.
- The skip rule now says every other program's **rpath** is untouched, with an
  explicit note that this is a statement about rpath selection and that the
  unchanged interpreter guard may still rewrite the `PT_INTERP` of a program no
  population selects.
- The per-class list was adjusted in the same way for the RPM-extracted program,
  the vendored patchelf, and the not-dynamically-linked case, which now takes an
  rpath disposition rather than being described as a bucket.
- The interpreter invariant gained a second bullet making it a post-selection
  assertion: a failing object keeps its rpath rewritten, warns at install time,
  is counted in its own figure, and blocks cplx acceptance, and is never
  reclassified as excluded because that would leave the target-valued
  `DT_RUNPATH` D3 removes.
- The reporting rule was replaced entirely. The six-name partition is gone, with
  a sentence stating why a single partition is impossible. In its place are the
  rpath disposition (five values), the interpreter disposition (four values),
  the separately counted migration-interpreter invariant, the two-axis
  reconciliation to the walked-ELF total, the error-routing rule, and the three
  named pairs that a single partition could not express.
- The monitoring rule now lists its three forms explicitly and binds the written
  form to the exact relocated process in the identified validation run, stating
  that a general product-support statement does not satisfy it, and requires the
  confirmation text itself to be retained.

Gap-to-close list, renumbered to twelve:

- Item 2 states the program predicate on the fresh branch and bounds the
  migration branch to v0.26.0.
- Item 3 records that the interpreter guard is not bounded by the rpath
  selector: a program whose rpath no population selects may still have its
  interpreter rewritten.
- Item 4 is new: assert the migration interpreter after the pass, warn, count,
  block acceptance, never exclude.
- Item 7 notes that leaving `build_elf_rpath` alone is also what makes the
  migration branch work.
- Item 9 replaces the six buckets with the two-axis report plus the invariant
  count and the per-axis reconciliation.
- Item 10 asks the wiki reference to record the two dispositions rather than the
  buckets.

Examples:

- The fresh python ELF example now shows the pair, `rpath rewritten` and
  `interpreter rewritten`, and says it is the pair a single label could not
  express.
- The migration example shows `rpath rewritten` and `interpreter unchanged`.
- A new example shows a migration object failing the interpreter invariant:
  still `rpath rewritten`, one invariant count, a warning, blocked acceptance,
  and explicitly not reclassified as excluded.
- The third-run example is now `rpath already correct`.
- The library example shows `rpath rewritten` and `interpreter not applicable`.
- A new example shows `rpath excluded` with `interpreter rewritten`.
- The failure example now shows `rpath failed` with `interpreter rewritten`.
- A new example states that summing either axis gives the walked-ELF count.
- A new example shows the monitoring answer that does not qualify.

Acceptance:

- The selector criterion now claims every other program's rpath is untouched,
  with the note that such a program may still have had its interpreter
  rewritten.
- The reporting criterion is the two axes, the two reconciliations, and both
  failure dispositions zero.
- The idempotence criterion names `rpath already correct`.
- The migration-interpreter criterion is now an invariant count of zero that
  blocks acceptance and is not resolved by reclassification.
- A criterion was added requiring the migration branch to be exercised against a
  v0.26.0-relocated prefix, naming why that is the recognizable predecessor.
- The monitoring criterion states what a written confirmation must say and that
  a general support statement does not count.

Out of scope:

- The widening entry now says the **rpath** selector, and notes the interpreter
  is left to the unchanged guard either way.
- A new entry records that recognizing a predecessor value other than v0.26.0's
  is out of scope and owed by whatever change alters the directory list.

Open questions, replaced as a whole:

- Q01, Q03, Q05 and Q07 rewritten; Q07 gained option 7D (a single label with
  enumerated composite states) so the rejected alternative is on the record, and
  Q03 gained option 3C (exclude a migration candidate with a wrong interpreter)
  for the same reason. Q02, Q04, Q06, Q08, Q09, Q10, Q11 and Q12 carried with
  their reasoning intact. Answers unchanged at 1B, 2A, 3A, 4A, 5A, 6C, 7C, 8C,
  9B, 10C, 11A, 12A.

In `docs/v0.27.0/draft.v0.27.0.relocation-force-rpath.md`:

- The Definition of Done sentence corrected in round 2 is refined again on the
  two round 3 points: the fresh population is named as programs, the migration
  population is bounded to a v0.26.0-relocated prefix, and the untouched claim
  is narrowed to the rpath with the interpreter guard named as a separate matter.

### Writer response for issue relocation-force-rpath round 4

Writer response: All five requested changes are applied. Nothing is disputed.

The reporting finding is accepted without reservation and it is a modelling
error, not a wording one. The pass has two independent guards; this issue keeps
them independent on purpose; therefore the outcome of a walk is a pair, not a
label. The writer imposed a single partition on a two-dimensional result and
then asserted the property that made it look rigorous, "every walked ELF lands
in exactly one", which was false for the most ordinary object in the tree. A
fresh program is rewritten on both axes. The schema also had no slot at all for
an rpath failure alongside an interpreter success, which is the case a validator
would most want to see.

Two things were done rather than one. The model was replaced with two
dispositions, and the reconciliation property was made explicit: each axis sums
to the number of walked ELFs, so the report can be checked against the walk
twice over. That property is what the old schema was reaching for and could not
deliver, and it is the reason to prefer two axes over the enumerated composite
states that option 7D describes. 7D was added to the option set so that
alternative is recorded as considered rather than unmentioned.

On Q03 the writer wants to flag one thing as deliberate. Option 3C, excluding a
migration candidate whose interpreter is wrong, was added to the options and
rejected in writing, because it is the trap in this question: it reads as the
cautious choice, and it is the only rule that can leave a target-valued
`DT_RUNPATH` on a program while reporting a benign exclusion. Naming it is worth
more than quietly not doing it.

The bounded migration promise is accepted and the writer notes what it costs.
The branch now works for exactly one predecessor, v0.26.0, and the condition is
that `build_elf_rpath` stays unchanged. That is recorded in the confirmed rule,
in the gap list next to the instruction not to touch `build_elf_rpath`, and in
the out-of-scope list. A future list change inherits an obligation rather than a
mechanism, which is the honest arrangement.

Three things are offered for round 4 rather than claimed as settled. The
interpreter axis distinguishes `unchanged` from `not applicable`, a distinction
the current code does not make explicitly, since an object with no `PT_INTERP`
and an object whose interpreter already matches both simply fail the same
condition. The migration-interpreter invariant is specified only as a failure
count, so a zero cannot be told from "no migration objects were present"; a
checked count alongside it may be worth requiring. And an object whose stored
value matches neither the current list nor v0.26.0's falls out of all three
populations and reports as `rpath excluded`, which is correct and silent.

### Reviewer focus for issue relocation-force-rpath round 4

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-08-16T18:59:30+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for issue relocation-force-rpath round 4

Round 4 correctly replaces the impossible six-label partition with two independent dispositions. The paired model now represents ordinary dual rewrites, one-axis exclusions, and one-axis failures; per-axis reconciliation gives the report the audit property round 3 was trying to obtain. The post-selection migration invariant, precise monitoring confirmation, bounded v0.26.0 promise, and rpath-only untouched claim are also applied consistently.

The specification is not yet convergence-ready because the claim that the three populations classify uniquely is false for a supported installation shape. `install_pkg.sh` defaults the prefix to `$HOME`, and the relocation how-to explicitly promises safe reruns when the prefix itself is under `/home`. In that shape, a v0.26.0 program whose exact target value is under `DT_RUNPATH` also satisfies the fresh branch's `/home/` test. On a later run, an exact-target `DT_RPATH` program can likewise satisfy the fresh predicate while the skip rule requires `rpath already correct`. The selected set may still be right, but population identity, Q03's per-population reasoning, migration counting, and idempotence are ambiguous unless precedence or mutual exclusions are stated.

The clean repair is an ordered rpath classification: recognize inspection failure and non-dynamic objects; recognize exact-target `DT_RPATH` as already correct; classify libraries; classify exact-target `DT_RUNPATH` programs as migration; only then classify remaining `/home/`-anchored programs as fresh; otherwise exclude. That order preserves all accepted scope while making the v0.26.0 and third-run outcomes deterministic even under `$HOME`.

Of the three caveats the writer raised, the interpreter vocabulary is sound if its evidence is made explicit: `not applicable` requires a successful classification proving no `PT_INTERP`, while `unchanged` requires a successful observation of a present interpreter for which the guard did not rewrite. An observation failure is `interpreter failed`. The invariant report should add the number of migration objects checked, because a failure count of zero alone cannot distinguish a successful assertion from an unexercised branch; the existing v0.26.0 acceptance run then requires a positive checked count and zero failures. An unknown predecessor value remaining `rpath excluded` is correct under the deliberately bounded v0.26.0 contract and needs no scope expansion.

No new decision question is required. Q01 owns classification precedence and Q07 owns the observable counts. The accepted answers remain the right choices subject to these concrete corrections.

### Question verdicts for issue relocation-force-rpath round 4

- Q01 — keep 1B, but make it an ordered classifier rather than three predicates claimed to be inherently disjoint. Exact-target tag/value states must take precedence over the broad `/home/` test so `$HOME` relocations classify deterministically.
- Q02 — agree with 2A.
- Q03 — agree with 3A. Its post-selection assertion remains correct; tie it to the ordered migration classification and report both migration objects checked and invariant failures.
- Q04 — agree with 4A.
- Q05 — agree with 5A. The exact process/run wording now closes the generic-assurance loophole.
- Q06 — agree with 6C.
- Q07 — agree with 7C. Define the evidence boundary between `interpreter unchanged`, `interpreter not applicable`, and `interpreter failed`, and add the migration checked count alongside invariant failures.
- Q08 — agree with 8C. The ordered exact-target `DT_RPATH` check is the implementation-facing expression of this answer.
- Q09 — agree with 9B.
- Q10 — agree with 10C.
- Q11 — agree with 11A.
- Q12 — agree with 12A.

No additional open question is needed. A program carrying an unrecognized predecessor value remains excluded by the bounded Q01 answer; a future directory-list change owns any broader recognition rule.

### Requested changes for issue relocation-force-rpath round 4

Requested changes:

1. Replace the claim that the population predicates are naturally disjoint with an explicit ordered rpath classification, or add equivalent mutual exclusions. The recommended order is: classification/inspection failure; `not dynamically linked`; exact target value under `DT_RPATH` as `already correct`; library population; program with the exact target value under `DT_RUNPATH` as migration population; remaining program whose old rpath is builder-anchored under `/home/` as fresh population; otherwise `excluded`. The exact-target states must precede the broad `/home/` condition. Explain that this is necessary because the supported prefix defaults to `$HOME`: under `/home`, a v0.26.0 target-valued `DT_RUNPATH` program otherwise matches both migration and fresh, while a third-run target-valued `DT_RPATH` program otherwise matches both the fresh predicate and the skip rule.

2. Carry that precedence through the confirmed rule, implementation gap, Q01/1B, Q03 population reasoning, Q08 idempotence wording, examples, acceptance, and the focused draft. Add acceptance cases for a prefix under `/home`: the first relocation selects the fresh program as appropriate, the v0.26.0-relocated prefix classifies the exact-target `DT_RUNPATH` program as migration, and the next run classifies exact-target `DT_RPATH` as already correct with zero rpath rewrites. Preserve the selected rpath set and all existing scope decisions.

3. Report the migration assertion as two figures: migration-population objects checked and invariant failures. Require the checked count to be positive in the dedicated v0.26.0 migration acceptance run, require it to equal the number of objects classified into the migration population for that run, and require failures to be zero. A fresh run may legitimately report zero checked; the dedicated migration run is what proves the assertion was exercised.

4. Define the interpreter dispositions by positive evidence. `not applicable` means classification successfully established that the object has no `PT_INTERP`; `unchanged` means inspection successfully found a `PT_INTERP` and the unchanged guard performed no rewrite; inability to establish either state is `interpreter failed`. Apply the same rule to examples and the per-axis reconciliation so an inspection error cannot be counted benignly.

### Writer instructions for issue relocation-force-rpath round 4

Retain decisions 1B, 2A, 3A, 4A, 5A, 6C, 7C, 8C, 9B, 10C, 11A, and 12A. Apply the requested precedence and reporting clarifications everywhere the document repeats population uniqueness, idempotence, migration validation, or disposition semantics. Add explicit `$HOME` examples and acceptance coverage so the repaired classifier is tested in the layout that exposes the overlap. Keep unknown predecessor values outside the v0.26.0 migration promise.

### Final reviewer decision for issue relocation-force-rpath round 4

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-4 -->

## Round 5 by requestor

- Recorded: 2026-08-16T19:12:16+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: request

### Review identity for issue relocation-force-rpath round 5

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
Review round: 5

### Requestor assessment for issue relocation-force-rpath round 5

Round 5. All four round 4 requested changes are applied, none disputed. Round 4
accepted the two-axis reporting model and every decision, and found that the
claim the three populations classify uniquely is false in a supported
installation shape. That is verifiable in the tree rather than a matter of
reading: `install_pkg.sh:40` sets `INSTALL_PREFIX="$HOME"` as the default, and
the how-to's step 3 promises re-runs are safe "even for a prefix that itself
lives under `/home`". Under that historical same-account layout the deployed
search path is `/home/<user>/tools/...`, so the target value **contains**
`/home/` and the broad builder-anchored test matches objects that are already
relocated. Two overlaps follow:

- a v0.26.0-relocated program holds the exact target value under `DT_RUNPATH`
  and also satisfies the `/home/` test, so it matched both the migration and the
  fresh branch;
- a program relocated by this version holds the exact target value under
  `DT_RPATH` and also satisfies the `/home/` test, so it matched both the fresh
  branch and the skip rule.

The writer had added the program predicate in round 3 believing it made the
populations disjoint. It does separate libraries from programs; it does nothing
about programs overlapping each other, which is where the `$HOME` layout bites.

1. Q01 is now an ordered classifier, first matching case wins: (1) classification
   or inspection failure; (2) not dynamically linked; (3) exact target value under
   `DT_RPATH`; (4) library; (5) program with the exact target value under
   `DT_RUNPATH`; (6) remaining builder-anchored program; (7) excluded. The
   exact-target tests precede the broad `/home/` test, which is what makes the
   `$HOME` outcomes deterministic. The selected rpath set is unchanged from round
   3; what the order adds is one defined outcome per object.

   The other three:

2. The precedence is carried through the confirmed rule, the implementation gap,
   Q01, Q03's per-case reasoning, Q08's idempotence wording, the examples, the
   acceptance and the focused draft. Three `$HOME` acceptance cases were added:
   a first relocation into `$HOME` classifies the python ELF as a fresh program;
   a `$HOME` prefix relocated by v0.26.0 classifies it as a migration; the next
   run classifies it as already correct with zero rpath rewrites. Two negative
   examples were added showing what each overlap would do without the ordering.
3. The migration assertion is reported as two figures, checked and failed. The
   dedicated v0.26.0 run must report a positive checked count equal to the
   number of objects classified into case 5 on that run, with zero failures; a
   fresh run may legitimately report zero checked. The equality is what ties the
   assertion to the classification rather than to a separate walk.
4. The interpreter dispositions are now defined by positive evidence:
   `not applicable` requires classification to have established that there is no
   `PT_INTERP`; `unchanged` requires inspection to have found one on which the
   guard did not fire; inability to establish either is `interpreter failed`.
   Examples and the per-axis reconciliation carry the same rule, and option 7E
   was added to Q07 so the fall-through version is on the record as rejected,
   since it is the one an implementation would reach by accident: the current
   code decides both interpreter questions with a single condition.

Round 4 also resolved one of the three caveats the writer raised: an object
whose stored value matches neither the current list nor v0.26.0's remains
`rpath excluded`, correct under the deliberately bounded contract, needing no
scope expansion. That is recorded and no longer open.

What round 5 should look at:

- Whether the ordered classifier's case 1 is implementable as stated. It is
  defined as "classification or inspection could not establish the object's
  state", which is a negative condition covering several distinct failures, and
  it sits first, so anything mis-detected there is silently promoted to a
  failure rather than mis-filed as benign. That direction is deliberate, but it
  does mean case 1 is the one case whose boundary is described rather than
  tested.
- Whether the acceptance now requires more distinct runs than is reasonable: a
  fresh non-`$HOME` relocation, three `$HOME` runs, a dedicated v0.26.0
  migration run, a `--force` reinstall, and a RHEL deployment run. Each earns
  its place individually; the total is worth a second look.
- Whether the `interpreter unchanged` disposition can in fact be established
  with the audited tools, since it requires proving a `PT_INTERP` is present and
  that the guard did not fire, where the current code only evaluates one
  combined condition. This is the point where Q07 and Q12 meet, and the writer
  believes patchelf's `--print-interpreter` answers it, but has not proved so.

### Change summary for issue relocation-force-rpath round 5

Changes to `docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md` since round 4,
applying round 4's four requested changes.

Confirmed rule:

- The three-population list is replaced by an ordered classifier with seven
  numbered cases, introduced by the reason the order is required: the
  `INSTALL_PREFIX="$HOME"` default at line 40 and the how-to's promise about a
  prefix under `/home`, which together make the target value contain `/home/`.
  Both overlaps are named explicitly, the v0.26.0 program matching migration and
  fresh, and the this-version program matching fresh and the skip rule.
- Cases 4, 5 and 6 are marked as the rewriting ones; cases 1, 2, 3 and 7 do not
  rewrite. The "every other program's rpath is untouched" statement is kept with
  its interpreter caveat.
- A closing sentence records that the ordering changes no scope decision: the
  rewritten set is the one round 3 settled, and what the order adds is a single
  defined outcome per object so that population identity, the interpreter
  reasoning, the migration count and idempotence all read off one
  classification.
- The per-class list now refers to cases by number. The python and git
  executables are described as reaching case 6 on a fresh archive, case 5 on a
  v0.26.0-relocated prefix and case 3 afterwards, with the note that only the
  ordering separates them under `$HOME`.
- The idempotence rule is restated as case 3 and explains that testing it before
  any rewriting case is what makes a second `$HOME` run report zero rewrites
  instead of rewriting the same value through the builder-anchored branch.
- The interpreter invariant is restated per case and gains a paragraph requiring
  two figures, checked and failed, with the checked count positive and equal to
  the number of case 5 objects on the dedicated v0.26.0 run, and zero checked
  acceptable on a fresh run.
- The reporting rule now defines the rpath disposition as the case the
  classifier assigned, and defines each interpreter value by positive evidence,
  with an explicit note that an object with no interpreter and an object whose
  interpreter could not be read fail the same condition in a naive
  implementation and only one is benign.

Gap-to-close list:

- Item 2 requires the ordered classifier with the exact-target tests before the
  broad `/home/` test, and states the `$HOME` reason.
- Item 4 requires the assertion after classification and the two figures.
- Item 5 names case 3 and case 5.
- Item 6 adds a run under the default `$HOME` prefix to the idempotence check
  and explains that the covered set reaches case 3 rather than falling through.
- Item 9 requires the interpreter values to be earned by positive evidence and
  the invariant to be two figures.

Examples:

- A `$HOME` block was added covering all three runs under the default prefix and
  stating that the ordering decides each one.
- Two negative examples were added: without the ordering, a v0.26.0 `$HOME`
  prefix leaves the python ELF matching both case 5 and case 6, so whether the
  invariant checks it depends on implementation order; and a this-version
  `$HOME` re-run leaves it matching both case 3 and case 6, so idempotence would
  fail on a correct tree.
- The migration failure example now counts on the failed figure.
- Examples were added for `interpreter failed` versus `not applicable`, for
  `not applicable` and `unchanged` earned by evidence, for a fresh run reporting
  zero checked, and for the dedicated migration run reporting checked equal to
  the case 5 count with zero failed.

Code references:

- Two were added: `install_pkg.sh` line 40, the `INSTALL_PREFIX="$HOME"` default
  that creates the overlap, and the how-to's step 3 promise about a prefix under
  `/home`, the supported shape the ordering must survive.

Acceptance:

- The reporting criterion now requires the benign interpreter values to rest on
  positive evidence.
- A criterion was added for the three `$HOME` cases.
- The migration criterion is now two figures with the positivity and equality
  conditions.

Focused draft:

- The Definition of Done sentence is refined again: the selector is described as
  an ordered classifier with its seven cases in order, the `$HOME` reason is
  stated, and the migration case stays bounded to v0.26.0.

Open questions, replaced as a whole:

- Q01 rewritten as the ordered classifier, gaining option 1C (unordered
  predicates with pairwise mutual exclusions) so that alternative is recorded.
  Q03 rewritten around the classified cases and the two figures. Q07 rewritten
  with the positive-evidence definitions and gaining option 7E (benign values by
  fall-through) so the accidental implementation is on the record as rejected.
  Q08 rewritten around case 3 and its placement. Q02, Q04, Q05, Q06, Q09, Q10,
  Q11 and Q12 carried. Answers unchanged at 1B, 2A, 3A, 4A, 5A, 6C, 7C, 8C, 9B,
  10C, 11A, 12A.

### Writer response for issue relocation-force-rpath round 5

Writer response: All four requested changes are applied. Nothing is disputed.

The classification finding is accepted and it exposes a habit worth naming. In
round 3 the writer was told to make the populations classify uniquely and
responded by adding a program predicate to the fresh branch. That does separate
libraries from programs, and the writer then asserted uniqueness as though the
job were finished. It was not: the remaining overlap is between two *program*
cases, and it appears only when the target value happens to contain `/home/`,
which is exactly what the default `$HOME` prefix produces. The pattern is the
same one round 2 caught, a local fix applied to the visible half of a problem
with the claim upgraded to cover the whole of it.

The repair is an order rather than a scope change, and that is worth stating
plainly: the set of rpaths rewritten is identical to the one round 3 settled.
What the ordering adds is a single defined outcome per object, which is what the
per-case interpreter reasoning, the migration count and the idempotence rule all
depend on. Two negative examples were added to the document so the two overlaps
are recorded as concrete failures rather than as an abstract precedence rule: a
v0.26.0 `$HOME` prefix where the invariant may or may not check the python ELF
depending on implementation order, and a this-version `$HOME` re-run where
idempotence fails on a tree that is in fact correct.

On the interpreter dispositions the writer added option 7E, benign values
assigned by fall-through, and rejected it in writing rather than simply
implementing the accepted rule. It deserves to be visible because it is what an
implementation reaches by accident: the current code decides both interpreter
questions with one condition, so an object with no `PT_INTERP` and an object
whose interpreter could not be read take the same branch today. The rule that
each benign value be earned by positive evidence is the whole content of the
correction.

The migration invariant's two figures are accepted with the equality condition
the reviewer specified, checked equal to the number of case 5 objects on that
run. Without the equality the checked count could be produced by a separate walk
and would prove less than it appears to.

Three things are offered for round 5 rather than claimed as settled. Case 1 is
defined by a negative condition covering several distinct failure modes and sits
first in the order, which is deliberate but does mean its boundary is described
rather than tested. The acceptance now names a fresh non-`$HOME` relocation,
three `$HOME` runs, a dedicated v0.26.0 migration run, a `--force` reinstall and
a RHEL deployment run, each defensible individually and worth a look as a total.
And `interpreter unchanged` requires establishing that a `PT_INTERP` is present
and that the guard did not fire, which the writer believes patchelf's
`--print-interpreter` supports but has not proved; that is where Q07 and Q12
meet.

### Reviewer focus for issue relocation-force-rpath round 5

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-5 -->

## Round 5 by reviewer

- Recorded: 2026-08-16T19:28:26+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: answer

### Reviewer assessment for issue relocation-force-rpath round 5

Round 5 resolves the remaining substantive ambiguity. Q01 is now an ordered, first-match classifier whose exact-target cases precede the broad `/home/` case, so a supported `$HOME` relocation has one deterministic identity on the fresh, v0.26.0-migration, and already-correct runs. The ordering preserves the accepted rewrite scope while making Q03's population assertion, Q07's counts, and Q08's idempotence read from the same result.

The two-axis reporting model is complete for the states this pass promises. Case 1 is appropriately a fail-closed outcome rather than an ordinary positive predicate: when a required rpath-classification observation is inconclusive, later benign cases are unavailable. The interpreter axis applies the same rule independently. The distinction between `unchanged` and `not applicable` is implementable with the allowed tool boundary: a successful `patchelf --print-interpreter` positively establishes and returns a present interpreter, while absence is not represented as a successful empty observation. Upstream patchelf's implementation calls `getInterpreter()` for this option, and `getInterpreter()` requires the `.interp` section; the specification correctly requires separate positive classifier evidence for absence and routes inconclusive inspection to `interpreter failed`. See [upstream patchelf source](https://github.com/NixOS/patchelf/blob/master/src/patchelf.cc#L1387-L1394).

The acceptance burden is proportionate and does not inherently require six isolated jobs. The `$HOME` cases are state transitions over prepared fresh and v0.26.0 starting states; the already-correct and `--force` observations can reuse the resulting prefix. A non-`$HOME` recipe and the RHEL deployment remain distinct because they prove different environment claims. The validation plan may combine observations so long as every starting state and result remains explicit.

The migration checked/failed pair closes the vacuous-zero concern: on the dedicated v0.26.0 state, checked must be positive and equal case 5 membership, while failures must be zero. The deliberately bounded treatment of unrecognized predecessor values remains correct.

No question is missing. All twelve questions now present materially distinct options, their recommendations follow from D3 and the stated evidence boundaries, and implementation can proceed. Only wording-level clarification remains, so I recommend convergence and consolidation after the requestor applies the covered wording below.

### Question verdicts for issue relocation-force-rpath round 5

- Q01 — agree with 1B. The first-match order is the necessary and sufficient repair for `$HOME` overlap without changing scope.
- Q02 — agree with 2A.
- Q03 — agree with 3A. Checked equal to case 5 membership and failed equal to zero makes the post-classification assertion auditable.
- Q04 — agree with 4A.
- Q05 — agree with 5A.
- Q06 — agree with 6C.
- Q07 — agree with 7C. Positive evidence for each benign disposition and axis-specific failure routing make the two-axis report complete; 7E correctly records the unsafe fall-through alternative.
- Q08 — agree with 8C. Case 3's position before rewriting cases is what makes tag-and-value idempotence hold under `$HOME`.
- Q09 — agree with 9B.
- Q10 — agree with 10C.
- Q11 — agree with 11A.
- Q12 — agree with 12A. The shipped patchelf can positively establish a present interpreter, and the existing header-classification obligation supplies positive absence evidence without adding a host dependency.

No new open question is needed.

### Convergence evidence for issue relocation-force-rpath round 5

Covered wording:

1. In case 1 and the Q01 option, prefer: “A required rpath-classification observation failed or was inconclusive, so the object receives `rpath failed` and no later rpath case may be assigned.” This makes clear that case 1 is axis-specific fail-closed routing, not a negative predicate that must somehow be tested before inspection.

2. In Q07/Q12 or the confirmed reporting rule, add: “A successful `patchelf --print-interpreter` establishes a present `PT_INTERP` and supplies its value; failure of that command alone never establishes absence. `not applicable` requires the classifier's independent positive evidence that no `PT_INTERP` exists, and any inconclusive observation is `interpreter failed`.” This states the implementable evidence split already required by the current text.

3. In acceptance, add one sentence before the cplx list: “The retained recipe may reuse a prepared prefix or snapshot across observations when the required starting state remains explicit; these criteria name distinct states and claims, not a mandatory one-job-per-bullet topology.” This prevents the comprehensive matrix from being misread as requiring six unrelated harnesses while preserving every observation.

Convergence rationale: Every in-scope decision is settled and the round-4 functional blocker is repaired. The classifier is deterministic under both ordinary and `$HOME` prefixes; migration and idempotence have non-vacuous evidence; the reporting axes cover success, absence, exclusion, no dynamic section, and axis-specific failure; host-tool growth remains fail-closed; and downstream versus cplx ownership is explicit. The remaining edits only clarify already-selected semantics and validation organization. No additional automated review round is needed before consolidation.

### Writer instructions for issue relocation-force-rpath round 5

Apply the covered wording during consolidation without reopening the accepted decisions or expanding scope. Preserve the ordered cases, two independent disposition axes, migration checked/failed equality, bounded v0.26.0 promise, and all acceptance states. The wording should clarify evidence boundaries and permit validation-plan reuse of prepared prefixes; it must not remove any required observation.

### Final reviewer decision for issue relocation-force-rpath round 5

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-5 -->

## Round 5 by human - human-confirmation

- Recorded: 2026-08-16T19:47:15+02:00
- Exchange: specification/issue/v0.27.0/relocation-force-rpath
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.relocation-force-rpath.md
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-5 -->
