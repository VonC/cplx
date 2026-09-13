# Specification review transcript for v0.27.0

- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-03T10:28:10+02:00
- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: claude
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for design-specification toolchain-runtime-closure (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
Review round: 1

### Requestor assessment for design-specification toolchain-runtime-closure (round 1)

#### Assessment of the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 1)

Seven open questions are placed. This is the design's first review, written from
the consolidated issue and from three measurements taken before the design was
drafted rather than after it.

##### Are the questions sufficient, and are any missing for design-specification toolchain-runtime-closure (round 1)

The seven cover every place the design leaves a structural choice open: how the
scope derivation stays one rule (Q01), what the `old/` tool root is (Q02),
whether one mechanism or two carry the invariants (Q03), how the declared
configuration reaches the verification host (Q04), how the publication boundary
observes waiver state (Q05), what the derived closure's subject set is (Q06),
and what a refusal reports (Q07).

THREE OF THEM ARE NOT ELABORATION PROMPTS, and they are what this round should
be read for:

- Q04. The floor and the family list are committed in cplx. The verification
  host is the Debian CI agent, which holds no cplx history and no credentials.
  The design says the configuration is data owned by this requirement and never
  says how the host that must evaluate it obtains it. This is the transport
  problem umbrella item 3 already solved once, for a different artifact, and the
  design must say whether it repeats that solution or removes the problem.
- Q05. The design asserts that publication is refused mechanically while a
  waiver is active, and publication belongs to umbrella item 7. Nothing states
  how item 7 observes the waiver state of an archive it did not package. Without
  an answer, "mechanical" is a claim rather than a mechanism.
- Q02. The measured scope contains `tools/old/py3.13`, on the rpath of every
  relocated ELF. The design treats all `tools/*/` roots uniformly, which means a
  floor member present ONLY under a superseded root satisfies the floor. Nobody
  had stated this before the measurement; the design has to decide whether the
  closure counts that root, excludes it, or reports it.

##### What the questions deliberately do NOT ask for design-specification toolchain-runtime-closure (round 1)

This is a design document, so nothing here asks an implementation detail: no
file layout, no step order, no test-strategy or line-budget question. Q01 and
Q03 come closest and are framed as coupling and composition choices, which is
where they belong; the design text itself says explicitly that how the sharing
is expressed is an implementation concern.

Nothing re-opens the issue either. The four invariants, the waiver contract, the
declared floor and family list, the D10 policy and the nine-control acceptance
matrix are all settled by the eleven clarifications and are treated here as
given. Where the design needed one of them to be more precise, it asks HOW to
express it, never WHETHER it holds.

##### The design's own hard problem, and whether it is answered for design-specification toolchain-runtime-closure (round 1)

The invariants are defined over a search scope that does not exist when they
must be checked: `build_elf_rpath` runs at install time against
`$INSTALL_PREFIX`, and `pkg.sh` archives the build account's tree before any
rpath has been written.

The design answers it by separating the scope's SHAPE, an ordered relative
directory list, from its instantiation against a root. That is the load-bearing
idea, and Q01 asks the question it raises: what keeps the shape one rule rather
than two implementations that agree today.

##### Evidence the design rests on for design-specification toolchain-runtime-closure (round 1)

Three retained measurements, all taken on the deployment target before the
design was written, and each cited by the fact it establishes: the resolution
scope and its ten directories, the loader-semantics provider candidate counts,
and the OpenSSL version-node coherence. The design states no scope or
classification claim that is not one of these.

##### Reviewer wording suggestions applied for design-specification toolchain-runtime-closure (round 1)

None yet. This is round 1 of the design exchange.

### Change summary for design-specification toolchain-runtime-closure (round 1)

#### Change summary for the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 1)

##### Round 1: the design is new for design-specification toolchain-runtime-closure (round 1)

There is no preceding round. One file is new in the working tree and nothing is
committed.

```text
?? docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/review.design-specification.v0.27.0.toolchain-runtime-closure.md
```

The item branch is `toolchain-runtime-closure`, and the issue this design
answers was consolidated and committed at `0c180ff`.

##### The document's shape for design-specification toolchain-runtime-closure (round 1)

329 lines before the questions were appended.

| Section | What it carries |
| --- | --- |
| Context | the one hard problem: the invariants are defined over a scope that does not exist when they are checked |
| Scope | four outcomes, what is in, what defers to umbrella items 6 and 7 |
| Confirmed Technical Facts | six facts, each from a source read or a measurement taken |
| Current and Target Behavior | the two flows, as diagrams, showing where the check enters |
| Design Area 1 | the scope as an ordered relative SHAPE instantiated against a root |
| Design Area 2 | the four invariants, their inputs and what each refuses |
| Design Area 3 | the declared configuration, floor entry shape and family entry shape |
| Design Area 4 | the waiver lifecycle and the publication boundary |
| Design Area 5 | the evidence model, two hosts, two readings, nine controls plus one positive |
| Acceptance Cases | thirteen scenarios, including the four that must be ACCEPTED or NOT EXAMINED |

##### What is inherited rather than decided here for design-specification toolchain-runtime-closure (round 1)

The design decides nothing the issue settled. Carried in as given: the four
invariants, the provider-aware coherence rule, rule 1 and rule 2 as separate
mechanisms, the declared floor with its location column, the waiver contract and
its three failures, the D10 conditional policy, and the acceptance matrix of one
positive and nine negative controls.

##### Evidence cited, not re-taken for design-specification toolchain-runtime-closure (round 1)

Three measurements committed at `03cfbe7`, each cited by the design fact it
establishes:

| Measurement | What the design takes from it |
| --- | --- |
| `measurements.resolution-scope.rhel.txt` | one scope, ten directories, three tool roots, `root/usr/bin` excluded |
| `measurements.provider-candidates.rhel.txt` | 54 needed names, 20 with several candidate paths, all resolving to one file |
| `measurements.openssl-version-nodes.rhel.txt` | the shipped OpenSSL pair is coherent |

##### Sources read for the confirmed facts for design-specification toolchain-runtime-closure (round 1)

`src/setups/env/bin/install_pkg.sh`, `build_elf_rpath` at line 881 and its one
use at line 959, and `src/setups/env/bin/pkg.sh`, whose archive step packages
`$HOME/<folder>` from the build account's live tree. The second is what makes
the design's central constraint a fact rather than a supposition.

### Writer response for design-specification toolchain-runtime-closure (round 1)

Writer response:

#### Writer response for the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 1)

Round 1 of the design exchange, so there is no earlier reviewer feedback for
this document to accept or dispute, and no disagreement is recorded.

##### Feedback carried forward from the issue's four rounds for design-specification toolchain-runtime-closure (round 1)

Applied here without being asked again, because the rounds that produced them
were about this subject matter rather than about one document:

- a rule must name the provider that actually defines what it checks. The
  design's coherence area resolves each version need through its own
  `DT_VERNEED` provider, never through libc alone;
- a classifier must be obtainable from something. Rule 1 reads lookup names and
  content digests, which the format supplies; rule 2 reads a declaration,
  because cross-SONAME kinship is not in the format at all;
- a scope claim must come from the search list, not from the directory tree. The
  design derives the shape from `build_elf_rpath` and cites the measurement that
  read it;
- an assertion about an archive must be a measurement of that archive. Every
  confirmed fact here names the source read or the capture taken.

##### Three things this round asks the reviewer to look at first for design-specification toolchain-runtime-closure (round 1)

1. THE CENTRAL CONSTRAINT AND ITS ANSWER. Packaging runs before any rpath
   exists, so the invariants are defined over a scope that does not yet exist.
   The design separates the scope's SHAPE from its instantiation against a root.
   If that separation does not hold, most of Design Area 1 and 2 follows it
   down, so it is the first thing worth attacking.

2. TWO INTERFACES THIS DESIGN DOES NOT YET CLOSE, and says so as questions
   rather than asserting a mechanism it has not chosen. Q04 asks how the
   declared configuration reaches a host with no cplx access; Q05 asks how the
   publication step in umbrella item 7 observes waiver state. Both are
   cross-boundary interfaces, both are recommended answers rather than settled
   ones, and a reviewer who thinks either is out of this design's scope should
   say where it belongs instead.

3. A FINDING THE MEASUREMENT PRODUCED AND THE DESIGN HAS NOT DIGESTED.
   `tools/old/py3.13` is on the rpath of every relocated ELF. The design treats
   every `tools/*/` root uniformly, which means a floor member present only
   under a superseded root would satisfy the floor. Q02 asks what to do about
   it. This is a real property of the archive that nobody had written down, and
   the recommended answer keeps the loader's view while making the root's
   presence its own finding.

##### What the writer deliberately did not put in this document for design-specification toolchain-runtime-closure (round 1)

The design says twice that a question is an implementation concern and leaves it
there: how the shared scope derivation is expressed, and how the invariants are
packaged as artifacts. Those belong to the plan, and Q01 and Q03 ask only the
structural half, which is whether one definition exists at all and how the parts
compose.

No file-by-file work, no step order, no line budget and no test-strategy
question appears here for the same reason.

##### One thing the writer would flag against itself for design-specification toolchain-runtime-closure (round 1)

The design asserts that the scope shape is identical in both evaluation
contexts, because both hold the same `tools/` subtree. That is true of the
directory NAMES. It is not obviously true of the directory SET, since a
directory that exists in the installed tree may be absent from the build tree
or the reverse, and the shape is built by testing existence. The design does not
address that asymmetry, and a reviewer may reasonably ask whether the shape must
be derived from a declared layout rather than from what happens to be on disk.

### Reviewer focus for design-specification toolchain-runtime-closure (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-03T10:41:12+02:00
- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: answer

### Reviewer assessment for design-specification toolchain-runtime-closure round 1

The design is not ready for convergence. Its central separation of an ordered,
relative search-scope shape from the root against which that shape is evaluated
is the right foundation, and the split between one static invariant mechanism
and a separate live observer is also sound. The current answers nevertheless
leave several load-bearing contracts unresolved.

The strongest gap is authority for the declared configuration. An archive that
carries its own floor, family list, expected-root list, and waivers is
self-describing, but it is not thereby bound to the configuration reviewed in
cplx. A payload and its embedded contract can drift together and still pass.
That also weakens the proposed publication re-check: removing or weakening the
embedded declaration could make the same archive publishable. The verification
host does not need repository access, but the transported configuration needs a
cplx-side identity or digest that the host and publication boundary both verify.

The subject-set answer has a second correctness gap. A transitive walk from
executables and the interpreter does not include Python extensions, wheel
extensions, plugins, or other objects reached through `dlopen` rather than
`DT_NEEDED`. The design's own evidence depends on such objects. Choosing F3 as
written would therefore make the new guarantee blind to the exact dynamic-load
class that motivated the cross-distribution work.

The scope is also still partly empirical. Calling one shared function is not
enough if that function conditionally includes directories that happen to
exist under each root: the build and installed evaluations can still produce
different directory sets. The design must distinguish the declared ordered
candidate shape from observed directory presence, and define how a missing or
unexpected root/directory affects the verdict. Q02 introduces an expected-root
declaration but does not settle the measured `tools/old/py3.13` disposition or
say whether an unexpected root refuses, warns, or can be waived.

Finally, the document says item 7 supplies D10 evidence and this design consumes
the policy, but it never defines that policy's input and result. The reporting
order in G3 is likewise under-specified: duplicate-provider resolution can
affect which provider is checked for version nodes, so “coherence before
duplication” is not a safe universal dependency order. These are design
decisions, not wording polish.

### Question verdicts for design-specification toolchain-runtime-closure round 1

**Q01 — relevant, but A1 is incomplete.** I choose A1 only after “one shared
derivation” is defined as an ordered candidate-shape declaration independent of
which directories currently exist. Root instantiation may then report observed
presence without silently changing the shape. The same function with
existence-sensitive enumeration does not prove packaging and verification use
the same set.

**Q02 — relevant, but B3 does not finish the decision.** B3 is the best
direction because provider scope must match loader scope. The answer must also
name the expected tool-root declaration, state whether an unexpected root is a
refusal or another result, and decide the initial status of the measured
`tools/old/py3.13` root. If it is temporarily permitted, the existing waiver
schema cannot express that because waivers name floor members only.

**Q03 — accept C3 with clarified boundaries.** One static checker should own
the four archive invariants and one separate live observer should own process
inventory and actual host fallback. Verification composes both results. The
design should stop describing the live no-host-fallback observation as though
it were also a packaging-time condition.

**Q04 — reject D2 as written; choose D3, or an explicit D2/D3 hybrid.** Shipping
the configuration with the archive solves availability, not authority. The
transported bytes need an identity or digest checked against the authoritative
cplx-side configuration before they are accepted. D3 already contains that
property and can reuse the item 3 transport pattern. If the configuration is
also embedded for self-contained inspection, the authoritative identity check
must remain mandatory.

**Q05 — choose E3 only with a closed input contract.** Publication should
validate the authoritative configuration identity, re-run the static checker
against the exact archive, and use a publication mode that refuses whenever any
validated waiver is active. “Any active waiver it finds” is insufficient if
the configuration can be stripped, replaced, or paired with the wrong archive.

**Q06 — reject F3; choose F1 unless a fourth option explicitly covers dynamic
loads.** Every shipped ELF should be a static subject even when it is not a
provider directory. That includes Python extensions, wheel extensions, and
plugins that are not reachable through `DT_NEEDED` from a declared executable.
Provider scope and subject set are different concepts. Unreferenced objects may
be reported separately, but reachability must not remove them from closure
checking.

**Q07 — choose a revised G3.** Produce a complete inventory per invariant, but
encode dependencies rather than only a total display order. Validate
configuration and scope first; establish membership and unambiguous provider
selection next; evaluate version coherence only where provider selection is
valid; evaluate independent family and waiver findings even when another group
fails. Dependent checks should report “not evaluated because …” rather than
emit misleading secondary failures.

**Missing question — how is transported configuration authenticated?** Add a
question that distinguishes self-description from authority and settles the
identity/digest comparison performed by the verification and publication
hosts. This may replace Q04 if its options are rewritten to cover both
transport and binding.

**Missing question — what exactly is the D10 policy interface?** State the
measurement item 7 supplies, the declared ceiling or comparison it is evaluated
against, and the pass/refuse/upgrade outcome. Saying the policy is consumed
without designing the consumption leaves an umbrella-owned decision absent.

### Requested changes for design-specification toolchain-runtime-closure round 1

Requested changes:

- Bind the transported floor, family, root, and waiver declarations to an
  authoritative cplx-side identity or digest; reject absent or mismatched
  configuration at verification and publication.
- Define a root-independent ordered candidate scope and typed results for
  missing and unexpected observed directories.
- Complete the B3 decision for `tools/old/py3.13`, including refusal and waiver
  semantics.
- Replace F3 with a subject-set rule that cannot omit `dlopen`-loaded Python,
  wheel, or plugin objects.
- Make the publication re-check consume the exact archive/configuration pair
  and hard-fail on every active validated waiver.
- Specify the D10 evidence-to-policy interface owned by this design.
- Define dependency-aware result aggregation and add the corresponding
  negative acceptance cases.

### Writer instructions for design-specification toolchain-runtime-closure round 1

Revise the design rather than consolidating it.

First, split scope definition from scope observation. Define one ordered,
root-relative candidate shape and one explicit result for missing or unexpected
roots/directories. Update Q01 and Q02 so their answers fully determine the
measured `old/` root and any waiver implications.

Second, rewrite Q04 and Q05 as one end-to-end trust boundary. Name the artifact
or bundle transported to Debian and publication, the cplx-side identity or
digest that makes its configuration authoritative, the comparison each host
performs, and the hard failure for missing, substituted, or mismatched
configuration. Publication must re-check the exact candidate archive in a mode
that rejects any active validated waiver.

Third, replace F3 or add a new option whose subject set includes dynamically
loaded ELF objects. Keep provider directories, static subjects, runtime entry
points, and live-trace observations as separate sets. State the result for an
unreferenced shipped ELF without excluding it from static closure checks.

Fourth, describe C3 consistently in the target flow and invariant sections:
the static checker runs in both contexts; the live observer runs only on the
foreign host; verification combines their typed results; packaging does not
claim to observe runtime host fallback.

Fifth, add the missing D10 design contract and replace G3's simple ordering with
an explicit dependency/suppression model. Add acceptance cases for a weakened
or mismatched configuration, a dynamically loaded extension absent from a
`DT_NEEDED` entry-point walk, divergent directory presence under the two roots,
an unexpected tool root, and a version check blocked by ambiguous provider
selection.

### Final reviewer decision for design-specification toolchain-runtime-closure round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-03T11:00:15+02:00
- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: request

### Review identity for design-specification toolchain-runtime-closure (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
Review round: 2

### Requestor assessment for design-specification toolchain-runtime-closure (round 2)

#### Assessment of the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 2)

Round 2. Eight open questions are placed, six of them rewritten against round 1's
verdicts with a new option and a new answer, one unchanged with its boundary made
explicit, and one new.

##### Are the questions sufficient, and are any missing for design-specification toolchain-runtime-closure (round 2)

Round 1 named two missing questions. Both are now placed, in the form it asked
for:

- CONFIGURATION AUTHENTICATION was folded into Q04 rather than added beside it,
  which round 1 offered as the preferred shape if Q04's options were rewritten
  to cover both transport and binding. They were: D4 is a new option, and the
  question title and description now name both halves.
- THE D10 POLICY INTERFACE is Q08, new, and Design Area 6 is the contract it
  decides. The three results are stated, including the one an earlier reading
  left out, which is that neither generation satisfying is a packaging failure
  rather than a silent selection of the larger option.

THREE OF THE EIGHT ARE WHERE THIS ROUND SHOULD BE READ HARDEST:

- Q04. The design now claims a three-party division of labour, and it states a
  limitation rather than hiding it: the Debian agent verifies internal
  consistency only, which catches substitution in transit and cannot catch a
  paired edit. Whether that is the right place to draw the line is the load
  bearing question of the whole trust boundary.
- Q07. The replacement for the refused ordering is a third result type,
  UNDETERMINED, with four named dependencies. Each dependency is an assertion
  about resolution that can be checked against loader behaviour, and if one is
  wrong the aggregation is wrong in a specific, findable way.
- Q02. The answer refuses the current archive. `tools/old/py3.13` is undeclared,
  so packaging fails until it is removed or a root waiver names it. The cost is
  real and it is stated rather than discovered later.

##### What round 1 refused, and whether the refusals are answered for design-specification toolchain-runtime-closure (round 2)

| Round 1 verdict | Round 2 |
| --- | --- |
| A1 incomplete: one function with existence-sensitive enumeration proves nothing | A4 declares a root-independent shape and makes presence a separate typed result; DIVERGENT refuses |
| B3 unfinished: name the declaration, the severity, and `old/`'s status | B4 does all three, and adds the typed waiver subject round 1 correctly said the schema lacked |
| C3 accepted with clarified boundaries | the boundary is now a table in Q03 and is repeated consistently in Target Behavior and Design Area 5 |
| D2 rejected: self-describing is not authoritative | D4 keeps D2's binding and adds D3's authority, with the check each party can actually perform |
| E3 needs a closed input contract | E4 fixes the pair, the order, and the absence of any waiver-permitting mode |
| F3 rejected: it cannot see `dlopen` loads | measured, confirmed at 76 modules and 0 declaring edges, and replaced by F4 |
| G3's ordering unsafe: duplication decides which provider coherence examines | G4 encodes that exact dependency, among four |

##### The design's own hard problem, and whether it is still answered for design-specification toolchain-runtime-closure (round 2)

Unchanged and now stronger. The invariants are defined over a search scope that
does not exist when they must be checked. Round 1 accepted the separation of
shape from root and showed it was not yet real, because the shape was still
built by testing what happened to exist. Round 2 makes the shape a function of
the declaration alone, which is what turns "both contexts see the same scope"
from an assumption into a comparison that can refuse.

##### Evidence the design rests on for design-specification toolchain-runtime-closure (round 2)

Four retained measurements, all taken on the deployment target, each cited by
the fact it establishes: the resolution scope and its ten directories, the
provider candidate counts by lookup name, the OpenSSL version-node coherence,
and now the closure-subject reading that refutes an entry-point walk. The design
states no scope, classification or subject claim that is not one of these.

##### Reviewer wording suggestions applied for design-specification toolchain-runtime-closure (round 2)

None carried forward. Round 1 recorded requested changes rather than wording
suggestions, and all seven are applied.

### Change summary for design-specification toolchain-runtime-closure (round 2)

#### Change summary for the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 2)

##### Round 2: revised, not consolidated for design-specification toolchain-runtime-closure (round 2)

Round 1 returned `changes-requested` with the instruction to revise. The design
grew from 700 lines to 1223, one measurement was taken and retained, and nothing
is committed yet.

```text
?? docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/measurements.closure-subjects.rhel.txt
?? docs/v0.27.0/review.design-specification.v0.27.0.toolchain-runtime-closure.md
```

The item branch is `toolchain-runtime-closure`, and the issue this design
answers was consolidated and committed at `0c180ff`.

##### What changed, section by section for design-specification toolchain-runtime-closure (round 2)

| Section | Round 1 | Round 2 |
| --- | --- | --- |
| Scope | four outcomes | five: configuration AUTHORITY joins availability, the subject rule is named, and the D10 interface becomes an outcome |
| Deferrals | the D10 measurement deferred, interface unstated | TAKING the measurement is deferred; the interface is designed here |
| Confirmed facts | six | eight: `build_elf_rpath` existence-sensitivity, and the closure-subjects measurement |
| Target Behavior | one flow with four invariants twice | two mechanisms drawn explicitly, static checker in both contexts, live observer on the foreign host only, packaging's verdict stated as partial |
| Design Area 1 | scope shape instantiated against a root | candidate shape DECLARED, presence OBSERVED, four typed results including DIVERGENT and UNEXPECTED, and the `old/` root decided |
| Design Area 2 | four invariants over "shipped objects" | four SETS separated first, subject set is every shipped ELF, then the four invariants |
| Design Area 3 | declared configuration as data | plus the cplx-side identity and the three-party check table |
| Design Area 4 | waiver lifecycle, publication refuses | typed waiver subjects, and publication re-checks the exact pair in a fixed order |
| Design Area 5 | evidence model, nine controls plus one positive | plus dependency-aware aggregation and the UNDETERMINED result |
| Design Area 6 | absent | new: the D10 evidence-to-policy interface |
| Acceptance Cases | 13 in one table | 33 in six grouped tables |
| Open questions | seven | eight, six of them rewritten with a new option and a new answer |

##### The answers that moved for design-specification toolchain-runtime-closure (round 2)

| Question | Round 1 answer | Round 2 answer |
| --- | --- | --- |
| Q01 | A1, one shared derivation | A4, declared candidate shape plus separate observation |
| Q02 | B3, an unexpected root is a finding | B4, the finding refuses, is root-waivable, and `old/py3.13` is unexpected today |
| Q03 | C3 | C3, unchanged, with its boundary table added |
| Q04 | D2, the archive carries its contract | D4, it carries it AND its cplx identity, checked by three parties |
| Q05 | E3, publication re-evaluates | E4, over the exact pair, identity first, no waiver-permitting mode |
| Q06 | F3, transitive closure from entry points | F4, four sets kept apart, every shipped ELF a static subject |
| Q07 | G3, a fixed invariant order | G4, named dependencies and an UNDETERMINED result |
| Q08 | absent | H3, the D10 input, comparison and three results |

##### The new measurement for design-specification toolchain-runtime-closure (round 2)

`docs/v0.27.0/measurements.closure-subjects.rhel.txt`, taken on the RHEL target
after round 1 and before the rewrite. It exists because round 1's F3 objection
was a claim about this archive: 628 shipped ELFs, a walk from 185 entry points
reaching 176 names, 395 not reached, 76 of those `lib-dynload` modules, 28
`site-packages` extensions, and 0 shipped objects declaring any of them.

##### Acceptance cases added for round 1's five named gaps for design-specification toolchain-runtime-closure (round 2)

Weakened or mismatched configuration, five cases. A dynamically loaded extension
absent from any entry-point walk, two cases. Divergent directory presence under
the two roots, one case. An unexpected tool root, three cases. A version check
blocked by ambiguous provider selection, one case among five aggregation cases.
The D10 interface adds four more, including the empty-consumer refusal.

##### What is still inherited rather than decided here for design-specification toolchain-runtime-closure (round 2)

The four invariants, the provider-aware coherence rule, rule 1 and rule 2 as
separate mechanisms, the declared floor with its location column, the waiver
contract's three failures, the D10 conditional policy and the nine-control
acceptance matrix. Round 2 changes one thing the issue settled and says so: the
waiver subject gains a TYPE, because a root waiver cannot be expressed by a
schema that names floor members only.

### Writer response for design-specification toolchain-runtime-closure (round 2)

Writer response:

#### Writer response for the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 2)

##### Round 2: every requested change accepted, one of them measured first for design-specification toolchain-runtime-closure (round 2)

Round 1 returned `changes-requested` with seven items. All seven are accepted
and applied. Nothing is disputed, and one item was verified on the deployment
target before being applied, because it was a factual claim about the archive
rather than a preference about the document.

| Round 1 requested change | Where it now lives |
| --- | --- |
| bind the transported declarations to an authoritative cplx identity, reject absent or mismatched configuration | Design Area 3, and Q04 rewritten as option D4 |
| define a root-independent ordered candidate scope with typed results | Design Area 1, and Q01 rewritten as option A4 |
| complete the B3 decision for `tools/old/py3.13`, refusal and waiver semantics included | Q02 rewritten as option B4, waiver types in Design Area 4 |
| replace F3 with a subject-set rule that cannot omit `dlopen`-loaded objects | Design Area 2, and Q06 rewritten as option F4 |
| make the publication re-check consume the exact archive and configuration pair, hard-fail on every active waiver | Design Area 4, and Q05 rewritten as option E4 |
| specify the D10 evidence-to-policy interface | Design Area 6, new, and Q08, new |
| define dependency-aware aggregation and add the negative acceptance cases | Design Area 5, Q07 rewritten as option G4, and 20 new acceptance cases |

##### The one finding that was measured rather than argued for design-specification toolchain-runtime-closure (round 2)

Round 1 refused F3 on the ground that a `DT_NEEDED` walk from the entry points
cannot reach `dlopen`-loaded Python extensions, wheel extensions and plugins.
That is a claim about this archive, so it was measured on the RHEL target before
the design was rewritten, and the measurement is retained as
`docs/v0.27.0/measurements.closure-subjects.rhel.txt`.

The probe walks the transitive closure from 185 entry points and matches names
ANYWHERE in the tree, deliberately more generously than any rule the design
would use, so that a miss under the probe is a miss under every stricter rule.

| Reading | Value |
| --- | --- |
| shipped ELF objects under the tools tree | 628 |
| distinct names the walk reaches | 176 |
| shipped ELFs the walk does NOT reach | 395 |
| of those, CPython extension modules under `lib-dynload` | 76 |
| of those, extensions under `site-packages` | 28 |
| shipped objects declaring a cpython module in a `DT_NEEDED` | 0 |

CONFIRMED, and worse than the design assumed: F3 would have examined a minority
of the archive and would have been blind to the exact class of object whose
failures produced this umbrella. The pymupdf and manylinux wheel cases live
entirely inside the 395.

##### Three things this round asks the reviewer to look at first for design-specification toolchain-runtime-closure (round 2)

1. THE TRUST BOUNDARY, END TO END, in Design Area 3 and Q04. Three parties check
   three different things, and the design states plainly what the Debian agent
   CANNOT do: it can detect substitution in transit and it cannot detect a
   paired edit, because detecting one needs cplx. If that division is wrong, the
   publication contract in Q05 moves with it.

2. THE UNDETERMINED RESULT, in Design Area 5 and Q07. Round 1 refused the
   coherence-before-duplication ordering on a specific technical ground, and the
   replacement is not a new order but a third result type with named
   dependencies. The dependency list is short and each entry is arguable
   individually, which is the point.

3. THE COST OF Q02's ANSWER. B4 refuses the CURRENT archive: `tools/old/py3.13`
   is undeclared, so packaging fails until the root is removed or a root waiver
   names it. That is deliberate and it is a real bill, so it should be agreed
   rather than discovered.

##### What the writer deliberately did not put in this document for design-specification toolchain-runtime-closure (round 2)

The design still says twice that a question is an implementation concern: how
the shared candidate-shape derivation is expressed, and how the invariants are
packaged as artifacts. Those belong to the plan.

Design Area 6 defines the D10 interface and does NOT take the D10 measurement,
which is umbrella item 7's work. The distinction is stated in the deferral list
rather than left to be inferred.

##### One thing the writer would flag against itself for design-specification toolchain-runtime-closure (round 2)

Q02's waiver type is a schema change to a contract the issue already settled.
The issue's waivers name floor members; a root waiver names a root and expires
on that root's absence. Round 1 identified the gap and this is the smallest
answer to it, but it is still this design amending a settled artifact rather
than implementing it, and a reviewer may prefer the amendment to be recorded in
the issue instead.

### Reviewer focus for design-specification toolchain-runtime-closure (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-03T11:04:44+02:00
- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: answer

### Reviewer assessment for design-specification toolchain-runtime-closure round 2

Round 2 materially improves the design and answers every round 1 topic, but it
is not ready for convergence. F4 is now supported by direct measurement, C3 is
mostly separated cleanly, and the configuration/publication discussion has the
right trust-boundary shape. Four remaining contradictions affect what an
implementation would do.

First, the two-root scope comparison is assigned to the wrong time and actor.
Packaging runs before the installed root exists, so it cannot know that a
candidate directory will later be absent there and cannot refuse a DIVERGENT
result. Packaging can record its observed set; verification can compare the
installed observation with that retained set; publication can require the
comparison to pass. The current target flow and acceptance table instead say
packaging refuses a fact that is not yet observable.

The candidate shape is not fully root-independent as described. It is computed
from declared roots but also contains each root's version directories. Those
version-directory names currently come from the filesystem unless the
configuration declares them or declares a deterministic layout expansion. A
root list of only python and git cannot itself produce paths such as the
versioned Python and Git library directories.

Second, G4 confuses an invariant refusal with unavailable input. A duplicate
lookup name with different content does not make loader selection unknown: the
design itself says directory order deterministically selects the first
candidate. Coherence can and should still be evaluated against that selected
provider while rule 1 independently refuses. Likewise, a missing floor member
does not make unrelated version needs undetermined, and an unexpected directory
does not erase each host's locally observed order. UNDETERMINED should be
reserved for genuinely missing or unreadable inputs, such as a needed provider
that resolves nowhere.

Third, D4 authenticates configuration bytes but does not establish the claimed
archive-to-bundle binding. Placing a bundle inside an archive does not prevent
replacement with another authentic bundle. The design also needs to define the
digest domain, canonical byte representation, configuration path in the named
commit, and which immutable cplx reference is authoritative. Either bind that
identity to the archive/build identity, or remove the wrong-pair refusal and
state that re-evaluating any archive against the authoritative configuration is
the actual protection.

Fourth, H3 cannot take its second branch from the evidence it defines. The
evidence lists only nodes supplied by the providers shipped in the rebuilt
archive. If that archive carries GCC 11 and it is insufficient, nothing in the
four fields says what GCC 12 defines. Conversely, if the archive already carries
GCC 12 and satisfies, the current condition incorrectly returns GCC 11. The
interface must carry candidate-generation identity and capabilities for both
choices, or define an iterative candidate-build procedure.

One cross-document authority issue also remains: B4 adds root waivers to a
settled requirement whose waivers name floor members. The design correctly
admits this is a schema change, but cannot silently make it authoritative.

### Question verdicts for design-specification toolchain-runtime-closure round 2

**Q01 - accept A4 only after two corrections.** Declare enough layout data to
derive every candidate directory without filesystem discovery, including the
version-directory component. Packaging records its local observed set;
verification performs the first build-versus-installed comparison; publication
requires the comparison result. Packaging cannot refuse future divergence.

**Q02 - B4 is the best design direction, but it is not internally consistent
yet.** The design says the candidate shape comes only from declared roots while
B4 says every observed tools root, including undeclared roots, remains in
loader resolution scope. Define the observed loader scope separately so an
unexpected root is both examined and refused. The new root-waiver subject also
requires an explicit requirement-level amendment or must be removed.

**Q03 - accept C3 after one stale statement is removed.** Target Behavior and
Design Area 5 now draw the boundary correctly. Design Area 2 still says a
fourth version-coherence condition is what packaging cannot answer. Actual host
fallback belongs only to the live observer; the static checker can evaluate its
four archive invariants on either tree.

**Q04 - choose a revised D4.** Keep the three-party verification model, but
define exactly which bytes are hashed, how the digest field avoids
self-reference, the path checked in the named commit, and the authoritative
commit/build relation. Being inside the tar does not itself prevent an authentic
bundle from being paired with another archive.

**Q05 - accept E4 contingent on the corrected D4 contract.** Identity first,
static re-check second, and unconditional active-waiver refusal is the right
sequence. The exact-pair language must use a real archive/configuration binding
or state that the authoritative configuration is intentionally reusable and
that re-evaluation, rather than co-location, validates the pair.

**Q06 - accept F4.** The four sets now distinguish subjects from providers and
the retained measurement directly supports every-shipped-ELF coverage. No
further structural change is needed.

**Q07 - reject G4 as written; choose a narrower dependency-aware variant.**
Report all independent invariant results. Mark a dependent result
UNDETERMINED only when an input cannot be obtained. A missing DT_NEEDED
provider makes its version checks undetermined. Different-content duplicates do
not: scope order still selects one provider, so coherence evaluates that file
while rule 1 refuses independently. Floor absence affects coherence only when
it is also the unresolved needed provider. Cross-host divergence blocks the
combined verdict but does not suppress each host's local results.

**Q08 - reject H3 as currently specified.** Add the actual generation of the
shipped provider and the provided-node inventories for both GCC 11 and GCC 12,
or specify how item 7 obtains and evaluates the second candidate after the
first fails. Then return the lowest candidate satisfying all required
GLIBCXX, CXXABI, and GCC nodes, or fail when neither does.

**Missing authority decision - may this design add root waivers?** The reviewed
issue settled waivers over floor members. B4 requires a second subject type.
Record an approved requirement amendment before treating root waivers as
settled, or make an unexpected root an unwaivable refusal until removal. This
cannot remain an acknowledged design-only schema change.

### Requested changes for design-specification toolchain-runtime-closure round 2

Requested changes:

- Move DIVERGENT comparison from packaging to verification/publication and
  retain the packaging observation needed for that later comparison.
- Fully declare version-directory layout and reconcile candidate scope with
  unexpected roots that the loader still observes.
- Limit UNDETERMINED to genuinely unavailable inputs; keep deterministic
  provider selection and independent invariant results.
- Define D4's digest domain, immutable source path, and real
  archive/configuration binding or remove the unsupported wrong-pair claim.
- Give H3 provider capability data for both GCC 11 and GCC 12 and account for
  the generation actually being evaluated.
- Obtain requirement authority for root waivers or make unexpected roots
  unwaivable.

### Writer instructions for design-specification toolchain-runtime-closure round 2

Revise the design for a focused round 3.

Move cross-root divergence detection to the first actor that can observe both
sets. Have packaging retain its candidate identity and observed set,
verification compare them with the installed observation, and publication
require the comparison. Define the complete root-independent layout input,
including how versioned subdirectories are obtained, and reconcile declared
candidate scope with loader-observed unexpected roots.

Correct G4 so dependency suppression follows data availability rather than the
presence of another refusal. Preserve deterministic loader selection for
different-content duplicates and continue evaluating coherence against the
selected provider. Replace the floor-member dependency with unresolved
provider resolution, and distinguish local host results from the combined
cross-host verdict.

Finish D4's digest and binding contract. Define canonical hashed bytes, exclude
the identity envelope from its own digest, name the configuration path in the
immutable commit, and either bind the approved configuration identity to the
archive/build or remove the unsupported claim that co-location prevents a
wrong pair. Update E4 and its acceptance cases to match that decision.

Repair H3 by supplying the information needed to evaluate both GCC candidates
and by conditioning the result on the actual candidate generation rather than
only on whatever provider happens to ship.

Finally, resolve the root-waiver requirement boundary explicitly. If root
waivers are necessary for item ordering, route the schema expansion through the
requirement owner and record it as an amendment; otherwise make the unexpected
root refusal unwaivable. Add acceptance cases for verification-time divergence,
deterministic coherence under a duplicate-provider refusal, bundle replacement,
and GCC 11 failure followed by GCC 12 evaluation.

### Final reviewer decision for design-specification toolchain-runtime-closure round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-09-03T11:15:52+02:00
- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: request

### Review identity for design-specification toolchain-runtime-closure (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
Review round: 3

### Requestor assessment for design-specification toolchain-runtime-closure (round 3)

#### Assessment of the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 3)

Round 3. Eight open questions are placed: five rewritten against round 2's
verdicts with a new option and a new answer, two accepted in round 2 and
unchanged apart from one stale statement removed, and none added.

##### Are the questions sufficient, and are any missing for design-specification toolchain-runtime-closure (round 3)

No question is missing. Round 2 named one cross-document authority decision,
whether this design may add root waivers, and the design ANSWERS IT BY NOT
NEEDING IT: the unexpected-root refusal is unwaivable, and the issue's waiver
contract is restored exactly as settled. That removes the amendment rather than
routing it, which is the cheaper of the two exits round 2 offered and the only
one available without a second document changing.

THREE OF THE EIGHT ARE WHERE THIS ROUND SHOULD BE READ HARDEST:

- Q04. The binding claim did not survive round 2 and it has not been patched: it
  has moved. Publication resolves the authoritative configuration from cplx at
  the release commit and compares digests, so nothing the archive says about its
  own contract is load-bearing. If that relocation is wrong, Q05 moves with it,
  because E5's first step is exactly this resolution.
- Q01. Two corrections in one option. The declared shape now includes version
  identifiers, because `build_elf_rpath` globs version directories as well as
  roots, and the DIVERGENT comparison has moved to verification, because
  packaging cannot see a tree that does not exist. Both were factual errors and
  both were checked in the source before the fix was written.
- Q08. The evidence now carries capabilities for BOTH GCC candidates plus the
  generation the reading was taken under, which is what makes the second branch
  answerable. The re-read and convergence rule is new and is the part most worth
  attacking: it bounds an iteration that could otherwise run.

##### What round 2 refused, and whether the refusals are answered for design-specification toolchain-runtime-closure (round 3)

| Round 2 verdict | Round 3 |
| --- | --- |
| A4: shape not root-independent, and DIVERGENT assigned to an actor that cannot observe it | A5 declares version identifiers per root and retimes the comparison to verification, with publication requiring the result |
| B4: two scopes conflated, and a waiver schema this design cannot amend | B5 names the declared candidate shape and the observed loader scope separately, and makes the root refusal unwaivable |
| C3 accepted, one stale statement remains | Design Area 2 now says all four coherence conditions are static and that host fallback belongs to the live observer alone |
| D4: co-location is not a binding, digest undefined | D5 defines the digest domain, excludes the envelope from its own digest, names a path at a commit SHA, and moves the binding to publication's own resolution |
| E4: contingent on the corrected D4 | E5 evaluates against the configuration publication resolved, in a four-step order |
| F4 accepted, no change needed | unchanged |
| G4: suppression too broad | G5 limits UNDETERMINED to inputs that could not be obtained, preserves deterministic selection, and separates local from combined verdicts |
| H3: cannot take its second branch | H4 adds the candidate capability table and the reading generation, and returns the lowest satisfying candidate |

##### The design's own hard problem, and whether it is still answered for design-specification toolchain-runtime-closure (round 3)

Unchanged, and now answered without a factual error in it. The invariants are
defined over a search scope that does not exist when they must be checked. Round
1 accepted the separation of shape from root; round 2 showed the shape was still
partly discovered and that one of its results was assigned to the wrong actor.
Round 3's shape is derivable from the declaration alone, and each typed result
is refused by a party that can observe it.

##### Evidence the design rests on for design-specification toolchain-runtime-closure (round 3)

Four retained measurements, all taken on the deployment target, each cited by
the fact it establishes: the resolution scope and its ten directories, the
provider candidate counts by lookup name, the OpenSSL version-node coherence,
and the closure-subject reading that refutes an entry-point walk. Round 3 adds
no measurement and one source reading: the two globs in `build_elf_rpath`, at
`src/setups/env/bin/install_pkg.sh:888` and `:894`, which are what make the
version identifiers a declaration rather than a discovery.

##### Reviewer wording suggestions applied for design-specification toolchain-runtime-closure (round 3)

None carried forward. Round 2 recorded requested changes rather than wording
suggestions, and all six are applied.

### Change summary for design-specification toolchain-runtime-closure (round 3)

#### Change summary for the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 3)

##### Round 3: revised for the six named contradictions for design-specification toolchain-runtime-closure (round 3)

Round 2 returned `changes-requested` with the instruction to revise for a
focused round 3. The design grew from 1223 lines to 1380, no new measurement was
needed, and nothing is committed yet.

```text
?? docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/measurements.closure-subjects.rhel.txt
?? docs/v0.27.0/review.design-specification.v0.27.0.toolchain-runtime-closure.md
```

The item branch is `toolchain-runtime-closure`, and the issue this design
answers was consolidated and committed at `0c180ff`.

##### What changed, section by section for design-specification toolchain-runtime-closure (round 3)

| Section | Round 2 | Round 3 |
| --- | --- | --- |
| Scope | outcome 1 was one scope model | two scopes named, and each result assigned to an actor that can observe it |
| Scope | outcome 3 was a bound cplx identity | plus a defined digest, and publication resolving the source for itself |
| Confirmed facts | eight | nine: `build_elf_rpath` globs TWICE, roots at line 888 and version directories at line 894 |
| Target Behavior | one comparison, drawn at packaging | packaging retains its observation, verification compares, publication resolves its own configuration |
| Design Area 1 | shape declared from roots, DIVERGENT refused anywhere | declared shape from roots AND version identifiers, observed loader scope beside it, and a table of who may produce each result |
| Design Area 2 | the fourth coherence condition was "what packaging cannot answer" | all four conditions are static; host fallback belongs to the live observer alone. Duplicate refusal no longer removes the selected provider |
| Design Area 3 | a bundle with an identity | a two-part bundle, digest domain stated, envelope excluded from its own digest, path at a commit SHA, and publication resolving independently |
| Design Area 4 | typed waiver subjects, floor members and roots | the issue's contract restored untouched; the root refusal is unwaivable; the publication order now names the RESOLVED configuration |
| Design Area 5 | suppression driven by other refusals | suppression driven by data availability, with a six-row table and local versus combined verdicts separated |
| Design Area 6 | evidence from the shipped provider | four fields: reading generation, consumer set, required nodes, and a capability table for BOTH candidates, plus a re-read and convergence rule |
| Acceptance Cases | 34 in six tables | 44 in six tables, retimed and extended |

##### The answers that moved for design-specification toolchain-runtime-closure (round 3)

| Question | Round 2 answer | Round 3 answer |
| --- | --- | --- |
| Q01 | A4, declared shape plus observation | A5, layout fully declared and the comparison retimed to verification |
| Q02 | B4, unexpected root refuses, root-waivable | B5, two named scopes and an UNWAIVABLE refusal |
| Q03 | C3 with a boundary table | C3, unchanged, with the one stale statement removed from Design Area 2 |
| Q04 | D4, co-location as the binding | D5, digest defined and the binding moved to publication's own resolution |
| Q05 | E4, the exact archive and its bundle | E5, evaluated against the configuration publication resolves |
| Q06 | F4 | F4, accepted in round 2, unchanged |
| Q07 | G4, suppression by other refusals | G5, suppression by data availability only |
| Q08 | H3, evidence from the shipped provider | H4, capabilities for both candidates and a convergence rule |

##### Acceptance cases added for round 2's four named gaps for design-specification toolchain-runtime-closure (round 3)

VERIFICATION-TIME DIVERGENCE, three cases: the divergent directory itself,
verification with no retained observation, and publication with no comparison.
DETERMINISTIC COHERENCE UNDER A DUPLICATE REFUSAL, one case in the aggregation
table asserting that rule 1 refuses AND the coherence answer is reported.
BUNDLE REPLACEMENT, one case asserting that the agent accepts it and publication
refuses. GCC 11 FAILURE FOLLOWED BY GCC 12, three cases covering the rebuild,
the convergent re-read, and the divergent re-read that fails.

Two cases were also REMOVED, both about root waivers, which no longer exist. One
replaced them: a waiver attempting to name a root is refused as UNKNOWN.

##### What is still inherited rather than decided here for design-specification toolchain-runtime-closure (round 3)

The four invariants, the provider-aware coherence rule, rule 1 and rule 2 as
separate mechanisms, the declared floor with its location column, the waiver
contract and its three failures, the D10 conditional policy, and the acceptance
matrix of one positive and nine negative controls. ROUND 3 CHANGES NOTHING THE
ISSUE SETTLED. The round 2 waiver schema change is withdrawn, so the
cross-document authority question round 2 raised no longer applies.

### Writer response for design-specification toolchain-runtime-closure (round 3)

Writer response:

#### Writer response for the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 3)

##### Round 3: six requested changes, all accepted, none disputed for design-specification toolchain-runtime-closure (round 3)

Round 2 returned `changes-requested` with six items and one cross-document
authority question. Every one is applied. Two of them corrected a factual error
in the design rather than a preference, and both were checked against the source
before the fix was written.

| Round 2 requested change | Where it now lives |
| --- | --- |
| move DIVERGENT from packaging to the first actor that can observe both sets, and retain the packaging observation | Design Area 1, the "where the comparison actually happens" table, Target Behavior, and Q01 as option A5 |
| fully declare the version-directory layout, and reconcile the candidate scope with loader-observed unexpected roots | Design Area 1, two named scopes, and Q02 as option B5 |
| limit UNDETERMINED to unavailable inputs, keep deterministic provider selection | Design Area 5's availability table, Design Area 2's duplicate-provider paragraph, and Q07 as option G5 |
| define D4's digest domain and immutable source, and either bind the identity or drop the wrong-pair claim | Design Area 3's two-part bundle and three-party table, and Q04 as option D5 |
| give H3 capability data for both GCC candidates | Design Area 6's four-field evidence, and Q08 as option H4 |
| obtain requirement authority for root waivers, or make unexpected roots unwaivable | UNWAIVABLE. Design Area 4 restores the issue's waiver contract untouched, and Q02's option B5 drops the schema change |

##### The two corrections that were verified in the source first for design-specification toolchain-runtime-closure (round 3)

ROUND 2's VERSION-DIRECTORY OBJECTION IS CORRECT AND THE DESIGN HAD IT WRONG.
`build_elf_rpath` globs twice, not once: `"$INSTALL_PREFIX"/tools/*/` at
`src/setups/env/bin/install_pkg.sh:888` for the roots, and `"$tool_dir"/*/` at
line 894 for the version directories. A declaration of `python` and `git` cannot
produce `tools/python/3.13.9/lib`, so the round 2 shape was not root-independent
at all. The configuration now declares version identifiers per root, and the
fact is recorded in Confirmed Technical Facts with both line numbers.

ROUND 2's RETIMING OBJECTION IS ALSO CORRECT. `pkg.sh` archives the build
account's tree, and no installed tree exists at that moment, so asking packaging
to refuse DIVERGENT asked it to refuse something it cannot observe. Packaging
now retains its observation, verification performs the comparison, and
publication requires the result.

##### Three things this round asks the reviewer to look at first for design-specification toolchain-runtime-closure (round 3)

1. THE BINDING, WHICH MOVED RATHER THAN BEING PATCHED. Round 2 offered two
   exits, bind the configuration identity to the archive or drop the co-location
   claim. The first is impossible in the order the artifacts exist, since the
   bundle is sealed into the tar before the tar has a digest. So the design takes
   the second and puts the binding where it can actually hold: PUBLICATION
   RESOLVES THE CONFIGURATION FROM CPLX ITSELF and requires the archive's
   envelope to carry that digest. A swapped authentic bundle is caught not
   because it traveled apart from the archive but because publication never
   asked the archive what the standard was.

2. THE TWO SCOPES, IN Q02 AND DESIGN AREA 1. Round 2 called the previous answer
   internally inconsistent, and it was: one sentence said the shape comes from
   declared roots, another said every observed root stays in resolution scope.
   These are now two named sets. Resolution uses the OBSERVED LOADER SCOPE, so
   `old/` really is reachable and the design says so; expectations are stated
   against the DECLARED CANDIDATE SHAPE, so `old/` is UNEXPECTED and refuses.

3. THE UNWAIVABLE ROOT REFUSAL. The design had no authority to add a waiver
   subject type to a settled requirement, and rather than route an amendment it
   removes the need. A waiver buys an ORDERED TRANSITION when the repair belongs
   to a later item, which is the sqlite case. An undeclared root has no such
   dependency: remove it or declare it, both available now. The current archive
   consequently fails until `tools/old/py3.13` is dealt with, with no temporary
   permission, and that is the intended bill.

##### What the writer deliberately did not put in this document for design-specification toolchain-runtime-closure (round 3)

How the shared candidate-shape derivation is expressed, and how the invariants
are packaged as artifacts, remain implementation concerns for the plan. Design
Area 6 defines the D10 interface and does not take the D10 measurement, which is
umbrella item 7's work.

##### One thing the writer would flag against itself for design-specification toolchain-runtime-closure (round 3)

Design Area 6 places a new obligation on umbrella item 7: obtain the provided
node inventory for a GCC generation it did not build with. If that inventory
turns out to be unobtainable without a build, the re-read rule degenerates into
the iterative procedure round 2 offered as the alternative, and the interface
still works, but item 7 then pays for two builds to answer one question. A
reviewer who knows what the toolchain hosts actually make available may judge
that cost differently from the writer, who has not measured it.

### Reviewer focus for design-specification toolchain-runtime-closure (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-09-03T11:19:22+02:00
- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: answer

### Reviewer assessment for design-specification toolchain-runtime-closure round 3

Round 3 resolves the substantive contradictions from round 2. The declared
layout now includes version identifiers, divergence is evaluated by an actor
that can observe both roots, the static and live responsibilities agree, root
waivers no longer exceed requirement authority, deterministic provider
selection survives rule 1 refusal, configuration authority is resolved from
cplx at publication, and the D10 policy can evaluate both candidates.

One load-bearing contract remains open. Publication requires the retained
packaging observation and the verification comparison to be present and passing
for THIS archive, but the design never defines how either evidence artifact is
bound to that archive. The configuration digest cannot provide that binding: it
identifies reusable policy bytes, not archive bytes. Co-location does not bind
evidence any more than it bound configuration in round 2, and an unqualified
retained observation from another archive could satisfy the stated presence
check.

The design should either key the packaging observation and verification result
to a digest of the completed archive, with publication recomputing that digest,
or have verification derive the build-side observation directly from the exact
archive before installation and compare it with the installed observation.
Whichever route is chosen must also explain how publication validates the
comparison belongs to the exact candidate it re-checks.

This is more than wording because it determines the evidence identity and the
ordering around archive creation. The remaining points are wording-level: A5's
declared version identifiers should explicitly cover non-version immediate
subdirectories such as current, and H4 should say that any non-identical
second result, lower, higher, or failure, is non-convergent.

### Question verdicts for design-specification toolchain-runtime-closure round 3

**Q01 - accept A5, contingent on evidence binding.** The shape inputs and actor
timing are now correct. Clarify that the per-root declaration covers every
immediate subdirectory the installer loop can add, including aliases such as
current, rather than only numeric version names. Bind the retained build
observation to the archive later compared.

**Q02 - accept B5.** Declared candidate shape and observed loader scope now have
separate meanings, the measured old root remains visible to resolution, and the
unwaivable refusal respects the settled requirement.

**Q03 - accept C3.** The stale static-versus-live contradiction is removed and
the ownership table is consistent with the target flow.

**Q04 - accept D5.** The digest domain, self-reference boundary, immutable
source, and publication-side authority are now defined. The configuration
identity is intentionally policy identity and should not be presented as the
identity of retained per-archive evidence.

**Q05 - E5 is correct except for one missing identity.** Keep its four-step
order, but define how step 2 proves that the retained packaging observation and
verification comparison belong to the exact archive in steps 1 and 3. Choose
an archive-digest keyed sidecar/result, or rederive the pre-install observation
from the exact archive during verification.

**Q06 - accept F4.** No further change is required.

**Q07 - accept G5.** UNDETERMINED is now limited to unavailable data, and local
results remain independent from the combined cross-host verdict.

**Q08 - accept H4 with one wording correction.** Both candidate capabilities
and the reading generation are now available. State that the second evaluation
must return the same candidate and that every other result, lower, higher, or
neither, is a non-convergent failure; the current text and cases name only the
higher branch explicitly.

**Missing question - how is cross-root evidence bound to the archive?** Decide
whether the completed archive digest keys both retained artifacts, or whether
verification recomputes the build-side observation from the exact pre-install
archive. The answer must let publication authenticate the comparison for the
same bytes it is about to publish.

### Requested changes for design-specification toolchain-runtime-closure round 3

Requested changes:

- Bind the retained packaging observation and verification comparison to the
  exact archive publication re-checks, or rederive the build observation from
  that archive during verification.
- Add wrong-archive and post-verification archive-change acceptance cases.
- Clarify that declared per-root subdirectories include aliases such as
  current.
- Make every non-identical H4 second result explicitly non-convergent.

### Writer instructions for design-specification toolchain-runtime-closure round 3

Add one focused evidence-identity decision and revise A5 and E5 to apply it.

Define when the archive identity becomes available, what exact bytes it covers,
what the packaging observation records, what the verification comparison
records, and how publication proves both records belong to the archive it
re-checks. A digest-keyed external evidence pair is acceptable. Recomputing the
pre-install observation from the exact archive during verification is also
acceptable and may remove the need to trust a retained packaging claim.

Add acceptance cases in which a valid observation or comparison from archive A
is supplied with archive B, and in which the candidate archive changes after
verification. Publication must refuse both.

As wording cleanup, replace version identifiers with language covering every
declared immediate subdirectory used by the installer loop, including current,
and make H4's second-evaluation rule reject every result that differs from the
first selected candidate.

### Final reviewer decision for design-specification toolchain-runtime-closure round 3

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-09-03T11:28:07+02:00
- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: request

### Review identity for design-specification toolchain-runtime-closure (round 4)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
Review round: 4

### Requestor assessment for design-specification toolchain-runtime-closure (round 4)

#### Assessment of the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 4)

Round 4. Nine open questions are placed: seven accepted in round 3 and left as
they were, two touched, and one new.

##### Are the questions sufficient, and are any missing for design-specification toolchain-runtime-closure (round 4)

Round 3 named one missing question, how cross-root evidence is bound to the
archive, and it is placed as Q09 with the two routes the reviewer offered stated
as options J2 and J3. Nothing else is outstanding: the three remaining round 3
items were wording-level and are applied in place rather than as questions.

TWO OF THE NINE ARE WHERE THIS ROUND SHOULD BE READ HARDEST, and the rest are
settled:

- Q09. The design takes J3, verification deriving both sides, over J2, the
  digest-keyed sidecar pair. Round 3 called both acceptable, so this is a choice
  rather than a compliance, and the argument for it is a correctness argument:
  under J2 a directory that never entered the tar reads as present on both
  sides. If that argument is wrong, J2 is still available and Design Area 7
  would change shape rather than disappear.
- Q05. Its step 2 now depends on Q09. The order and the cplx-side resolution
  were accepted in round 3; what changed is that "present for THIS archive" now
  names an identity publication computes rather than reads.

##### What round 3 refused, and whether the refusals are answered for design-specification toolchain-runtime-closure (round 4)

| Round 3 verdict | Round 4 |
| --- | --- |
| A5 accepted contingent on evidence binding, and the declaration must cover aliases such as `current` | the input table is a subdirectory list, the `current` and `python-3.13.9` pair is a confirmed fact from the retained measurement, and A5 points at Q09 |
| E5 correct except for one missing identity | step 0 computes the archive identity and step 2 requires a result keyed to it |
| H4 accepted with one wording correction | every non-identical second result is non-convergent, with the higher, lower and neither cases each named and each given an acceptance case |
| Q04 accepted, with a caution that configuration identity is policy identity | Design Area 3 says so in its own subsection, and Design Area 7 supplies the identity that can bind evidence |
| B5, C3, F4, G5 accepted | unchanged |
| missing question on evidence binding | Q09, with J1 refused as impossible, J2 stated fairly, and J3 chosen |

##### The design's own hard problem, and whether it is still answered for design-specification toolchain-runtime-closure (round 4)

Unchanged. The invariants are defined over a search scope that does not exist
when they must be checked. What round 4 adds is the other end of the same
ordering problem: THE ARCHIVE IDENTITY DOES NOT EXIST UNTIL THE TAR IS CLOSED,
so nothing sealed inside can name it. That is why the evidence is external and
why publication binds by recomputation. It is the same impossibility round 2 met
from the configuration side, met again from the evidence side, and answered the
same way.

##### What this design does not claim for design-specification toolchain-runtime-closure (round 4)

Design Area 7 closes with its own limit, stated rather than left to be
discovered: keying by the archive identity proves the evidence describes those
bytes, and does not authenticate it against a party able to write both the
archive and the result. Publication re-runs the static checker itself for that
reason. A reviewer who wants that gap closed should say which mechanism closes
it, because it is not this one.

##### Evidence the design rests on for design-specification toolchain-runtime-closure (round 4)

Four retained measurements, all taken on the deployment target, each cited by
the fact it establishes: the resolution scope and its ten directories, now also
cited for the `current` alias; the provider candidate counts by lookup name; the
OpenSSL version-node coherence; and the closure-subject reading that refutes an
entry-point walk. Round 4 adds no measurement and one source reading already in
the document, the two globs at `src/setups/env/bin/install_pkg.sh:888` and
`:894`.

##### Reviewer wording suggestions applied for design-specification toolchain-runtime-closure (round 4)

Three, all from round 3: the subdirectory declaration covering aliases, the
non-convergent wording for every H4 second result, and the distinction between
policy identity and evidence identity.

### Change summary for design-specification toolchain-runtime-closure (round 4)

#### Change summary for the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 4)

##### Round 4: one new design area, one new question, three wording fixes for design-specification toolchain-runtime-closure (round 4)

Round 3 returned `changes-requested` with one substantive item and three
wording items. The design grew from 1380 lines to 1637, no new measurement was
needed, and nothing is committed yet.

```text
?? docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
?? docs/v0.27.0/measurements.closure-subjects.rhel.txt
?? docs/v0.27.0/review.design-specification.v0.27.0.toolchain-runtime-closure.md
```

The item branch is `toolchain-runtime-closure`, and the issue this design
answers was consolidated and committed at `0c180ff`.

##### What changed, section by section for design-specification toolchain-runtime-closure (round 4)

| Section | Round 3 | Round 4 |
| --- | --- | --- |
| Scope | five outcomes | six: the archive identity and the evidence keyed to it |
| Confirmed facts | nine, the second glob described as version directories | ten: the glob adds EVERY immediate subdirectory, and the measured `current` alias sits beside `python-3.13.9` on the rpath |
| Target Behavior | packaging transports its observation | packaging's observation stays local; verification derives both sides; publication computes the archive digest itself |
| Design Area 1 | declared version identifiers, packaging retains its observation | declared immediate subdirectories, and a three-actor table where verification derives the build-side half from the archive |
| Design Area 3 | digest domain and three-party table | plus one subsection: the configuration digest is POLICY identity and never evidence identity |
| Design Area 4 | four publication steps | five: step 0 computes the archive identity, and step 2 requires a result keyed to it |
| Design Area 6 | a higher second result fails | every non-identical second result fails, with the three cases named |
| Design Area 7 | absent | new: the archive identity, when it exists, what the verification result records, and how publication proves the result is this archive's |
| Acceptance Cases | 44 in six tables | 54 in seven tables |
| Open questions | eight | nine |

##### The answers that moved for design-specification toolchain-runtime-closure (round 4)

| Question | Round 3 answer | Round 4 answer |
| --- | --- | --- |
| Q01 | A5 | A5, with the declaration restated as a subdirectory list and the build-side half derived by verification |
| Q02 | B5 | B5, unchanged |
| Q03 | C3 | C3, unchanged |
| Q04 | D5 | D5, unchanged, with policy identity distinguished from evidence identity in Design Area 3 |
| Q05 | E5 | E5, with step 2 keyed by Q09's archive identity |
| Q06 | F4 | F4, unchanged |
| Q07 | G5 | G5, unchanged |
| Q08 | H4 | H4, with every non-identical second result explicitly non-convergent |
| Q09 | absent | J3, new: verification derives both sides, and its one result is keyed by the archive identity |

##### The route not taken, and why for design-specification toolchain-runtime-closure (round 4)

Round 3 offered two acceptable routes. J2, a digest-keyed sidecar pair, keeps a
transported packaging claim. J3, taken here, has verification derive the
build-side observation from the exact archive.

J3 is preferred on correctness rather than economy: the divergence worth
detecting is between the ARCHIVE and the installed tree. Under J2, a directory
that existed on the build account but never entered the tar reads as present on
both sides; under J3 it is DIVERGENT. Q09 records both options with that
argument.

##### Acceptance cases added for design-specification toolchain-runtime-closure (round 4)

EVIDENCE IDENTITY, a new table of five: a valid result from archive A supplied
with archive B, an archive modified after verification, a result whose
configuration digest differs from the one publication resolved, two archives
under one configuration each publishing against their own, and the passing case.

SCOPE, three more: a directory present on the build account that never entered
the tar, the `current` and `python-3.13.9` pair resolving to one file, and an
undeclared immediate subdirectory. One case was reworded, since verification no
longer consumes a retained packaging observation.

D10, two more: a LOWER second result and a NEITHER second result, both
non-convergent, beside the HIGHER case that was already there.

##### What is still inherited rather than decided here for design-specification toolchain-runtime-closure (round 4)

The four invariants, the provider-aware coherence rule, rule 1 and rule 2 as
separate mechanisms, the declared floor with its location column, the waiver
contract and its three failures, the D10 conditional policy, and the acceptance
matrix of one positive and nine negative controls. Round 4 changes nothing the
issue settled, and the round 2 waiver schema change remains withdrawn.

### Writer response for design-specification toolchain-runtime-closure (round 4)

Writer response:

#### Writer response for the toolchain-runtime-closure design for design-specification toolchain-runtime-closure (round 4)

##### Round 4: one design decision and three wording corrections, all accepted for design-specification toolchain-runtime-closure (round 4)

Round 3 accepted seven of the eight questions and named one load-bearing
contract still open, plus three wording items. All four are applied and nothing
is disputed.

| Round 3 requested change | Where it now lives |
| --- | --- |
| bind the retained observation and the comparison to the exact archive, or rederive the build observation from that archive | Design Area 7, new, and Q09, new. THE SECOND ROUTE IS TAKEN |
| add wrong-archive and post-verification archive-change acceptance cases | a new "Evidence identity" acceptance table, five cases |
| clarify that declared per-root subdirectories include aliases such as `current` | Design Area 1's input table, a new confirmed fact, and A5 |
| make every non-identical H4 second result explicitly non-convergent | Design Area 6's convergence paragraph, H4's option text, and three acceptance cases |

##### Why J3 rather than J2, when round 3 offered both for design-specification toolchain-runtime-closure (round 4)

Round 3 said a digest-keyed sidecar pair is acceptable and that rederiving the
pre-install observation is also acceptable and may remove the need to trust a
retained packaging claim. The design takes the second, and not only for the
economy the reviewer mentioned.

THE COMPARISON THAT MATTERS IS ARCHIVE AGAINST INSTALLED TREE. A build-account
observation and an installed observation can agree perfectly while the archive
between them is missing a directory: a directory that existed where the tar was
made but never entered the tar reads as PRESENT on both sides under J2, and as
DIVERGENT under J3. That is a delivery this design would otherwise have passed,
and it is the same class of gap the requirement exists to close.

So packaging's observation stays local, as an early gate that refuses an
UNEXPECTED directory before a tar is built, and nothing downstream trusts it.
Verification derives both sides from what it holds, and emits ONE result keyed
by the archive identity. One artifact, one producer, one recomputation.

##### The alias point was measured, not just accepted for design-specification toolchain-runtime-closure (round 4)

Round 3 asked for `current` to be covered. It is in the retained measurement
already: entries 4 and 5 of
`docs/v0.27.0/measurements.resolution-scope.rhel.txt` are
`tools/python/current/lib` and `tools/python/python-3.13.9/lib`. The installer
loop at `src/setups/env/bin/install_pkg.sh:894` globs every immediate
subdirectory and does not test for version-shaped names, so an alias is on the
rpath in its own right.

Two consequences are now written down. The declaration is a SUBDIRECTORY list,
so `current` is declared rather than refused. And this is a case rule 1 must
ACCEPT: two candidate paths reaching one file is one provider, which the
provider-candidate measurement already showed for all twenty multi-candidate
names.

##### Three things this round asks the reviewer to look at first for design-specification toolchain-runtime-closure (round 4)

1. THE LIMIT OF WHAT DESIGN AREA 7 CLAIMS, stated in its own closing section.
   Keying by the archive identity proves the evidence describes THESE BYTES. It
   does NOT authenticate the evidence against a party who can write both the
   archive and the result. Publication re-runs the static checker itself in step
   3 for that reason, so the evidence corroborates the cross-root comparison
   rather than being the sole basis for publishing. If more is wanted there, it
   is a different mechanism and should be named as one.

2. THE ORDERING FACT IN DESIGN AREA 7. The archive identity does not exist until
   the tar is closed, so nothing sealed inside can name it. That is why the
   evidence is external, and it is the same impossibility Design Area 3 met from
   the other side when round 2 asked for an archive-to-bundle binding.

3. PACKAGING'S REDUCED ROLE. Its observation is now purely local. A reader may
   reasonably ask why it runs at all, and the answer is in Design Area 1: it
   refuses an UNEXPECTED directory before anything is packaged, which is cheap
   and early, and it is not evidence.

##### What the writer deliberately did not put in this document for design-specification toolchain-runtime-closure (round 4)

How the shared candidate-shape derivation is expressed, how the invariants are
packaged as artifacts, and where the verification result is stored remain
implementation concerns for the plan. Design Area 7 says what the result must
record and how publication checks it, not what file format it takes or which
system holds it.

##### One thing the writer would flag against itself for design-specification toolchain-runtime-closure (round 4)

J3 makes verification read the archive's directory shape before installing it.
The design states that as a requirement without saying how, and on a tar the
cheapest honest answer is a listing pass over the archive index rather than a
full extraction. If the CI agent's tooling makes that awkward, the cost lands on
umbrella item 5's probe rather than here, and a reviewer closer to that pipeline
may judge it differently from the writer, who has not measured it.

### Reviewer focus for design-specification toolchain-runtime-closure (round 4)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-09-03T11:30:26+02:00
- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: answer

### Reviewer assessment for design-specification toolchain-runtime-closure round 4

Round 4 is ready for convergence. J3 closes the last substantive gap by making
verification derive both observations from the exact archive/install pair and
by keying the single result to the SHA-256 of the completed archive bytes.
Publication recomputes that identity, resolves policy independently from cplx,
requires the matching comparison, and re-runs the static checker. The ordering
and trust boundaries are now explicit rather than implied.

The rest of the design is coherent end to end. The declared candidate shape and
observed loader scope are separate; immediate subdirectories include aliases;
unexpected roots are visible to resolution and unwaivably refused; every
shipped ELF is a static subject; live host fallback remains a separate foreign
host observation; configuration identity and archive evidence identity have
different jobs; result aggregation preserves deterministic loader selection;
and D10 can evaluate both candidates with a bounded convergence rule.

No open decision or missing question remains. The stated limitation of J3 is
acceptable for this scope: the digest binds evidence to bytes, while producer
authenticity remains an operational trust boundary. Publication's independent
static re-check does not recreate the cross-root or live observations, and the
design does not claim that it does.

Two optional wording refinements would improve precision but do not change any
decision or implementation contract.

### Question verdicts for design-specification toolchain-runtime-closure round 4

**Q01 - accept A5.** The full candidate layout is declared, both observations
are derived by an actor that can obtain them, and Q09 supplies the archive
identity required downstream.

**Q02 - accept B5.** The two scopes and the unwaivable unexpected-root refusal
are complete and remain within requirement authority.

**Q03 - accept C3.** Static checking, live observation, verification
composition, and packaging's partial verdict have consistent ownership.

**Q04 - accept D5.** Policy bytes, digest domain, immutable source, and
publication-side authority are fully specified.

**Q05 - accept E5 with Q09.** The five-step publication sequence now has exact
inputs and fails closed on missing policy, comparison, static validity, or
waiver state.

**Q06 - accept F4.** Every shipped ELF is covered without confusing subjects,
providers, entry points, or live observations.

**Q07 - accept G5.** UNDETERMINED is limited to unavailable input and does not
erase independent deterministic results.

**Q08 - accept H4.** Both candidate capabilities are available, the lowest
satisfying candidate is selected, and every non-identical re-read result fails
as non-convergent.

**Q09 - accept J3.** Verification derives archive and installed observations
from one exact file, emits one archive-digest keyed result, and publication
recomputes the identity. Wrong-archive and post-verification mutation cases are
covered.

No question is missing.

### Convergence evidence for design-specification toolchain-runtime-closure round 4

Covered wording:

In Design Area 7, make the trust boundary maximally explicit: publication's
static re-check provides independent static assurance; it does not authenticate
or reproduce the verification-only cross-root comparison and live observation.
The provenance of that verification result is an operational trust assumption
outside the archive-identity binding.

In Q09 option J2, replace the statement that a digest-keyed packaging claim can
arrive authentic and belong to another archive. The digest already prevents
that mismatch. Its actual cost is retaining two evidence artifacts and
authenticating two producers instead of deriving both observations under one
verifier.

Convergence rationale:

Every in-scope design decision is settled with a selected option, an explicit
input and ownership contract, and negative acceptance coverage. The four-round
review closed scope derivation, configuration authority, dynamic-load subjects,
cross-host composition, waiver publication, dependency-aware reporting, D10
candidate evaluation, and per-archive evidence identity.

The remaining suggestions only clarify claims already bounded by the document.
They do not change behavior, authority, data flow, or acceptance outcomes.

### Writer instructions for design-specification toolchain-runtime-closure round 4

No substantive revision is required. Consolidation may proceed when the human
selects it.

During consolidation, the optional wording refinements may be applied without
another review round. Keep all nine selected answers and their acceptance cases
unchanged.

### Final reviewer decision for design-specification toolchain-runtime-closure round 4

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-4 -->

## Round 4 by human - human-confirmation

- Recorded: 2026-09-03T23:04:27+02:00
- Exchange: specification/design-specification/v0.27.0/toolchain-runtime-closure
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-4 -->
