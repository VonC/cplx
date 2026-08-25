# CPLX-ELF/1 two-way derivation ledger

Required by Step 3 of
[the plan](plan.v0.27.0.relocation-force-rpath.md) before the corpus bytes are
frozen. It records that
[`contract.cplx-elf-1.txt`](contract.cplx-elf-1.txt) was **derived** from the
reviewed design, which a digest cannot show.

The two pieces of evidence say different things and neither substitutes for the
other: this audit establishes derivation correctness at freeze time, and the
digest below establishes stability afterwards.

Rank 1 is [the design](design.v0.27.0.relocation-force-rpath.md), Design Area 3.
Rank 2 is the corpus. Rank 3 is the formatter and the reader.

## Measured inputs

| Input | Value | How |
| --- | --- | --- |
| `od -An -tx1` output line width | **16 bytes** | ran the exact invocation the formatter uses, on the shipped tool |
| `od` build | GNU coreutils 8.32 | `od --version` |

The design expects sixteen "as a figure to confirm against the shipped tool
rather than to take on trust". It is confirmed, and the wrap pair is authored at
16 and 17 bytes rather than at an assumed width.

Every `path` vector's expected hex was computed with `perl unpack("H*", ...)`,
**not** with the `od` plus `tr` pipeline the formatter uses. Verifying the
corpus with the tool under test would make it a transcript of that tool. The
five vectors the plan states literally all matched the independent computation.

## Direction 1: design to corpus

Every `/1` obligation the design states, against the vectors that witness it.
Completion rule: **zero uncovered obligations**.

| # | Obligation, from Design Area 3 | Witnessing vectors |
| --- | --- | --- |
| 1 | `CPLX-ELF/1` is the literal marker; an unknown marker is rejected rather than guessed | `rejected/unknown-marker`, `capture-reject/unknown-marker-in-capture` |
| 2 | `obj` and `end` are the two record kinds | all `canonical-obj`, all `canonical-end`, `rejected/unknown-kind` |
| 3 | fields are `name=value`, located **by name rather than by position** | `reader-valid/obj-permuted`, `obj-permuted-2`, `end-permuted`, `end-permuted-2` |
| 4 | `/1` is closed: each listed field exactly once, no others; missing, repeated and unrecognized all rejected | `rejected/obj-missing-field`, `obj-duplicate-field`, `obj-unknown-field`, `end-missing-count`, `end-duplicate-count`, `end-unknown-count` |
| 5 | `obj` carries `case`, `rpath`, `interp`, `path` | all seven `canonical-obj` |
| 6 | `case` is an integer 1 to 7 | `canonical-obj` covers 1 to 7; `rejected/obj-case-zero`, `obj-case-eight` |
| 7 | `rpath` tokens are the closed five, space-free | `canonical-obj` covers all five; `rejected/obj-bad-rpath-token` uses the spaced human label |
| 8 | `interp` tokens are the closed four, space-free | `canonical-obj` covers all four; `rejected/obj-bad-interp-token` borrows an rpath-only token |
| 9 | `path` is relative to the walked root `DEST_PATH` | `path/root-relative`, whose expected hex is the remainder after `%DEST%` |
| 10 | `path` is raw bytes as lowercase hex, therefore even length, never empty | `path` matrix; `rejected/obj-path-empty`, `obj-path-odd-length`, `obj-path-uppercase-hex`, `obj-path-non-hex` |
| 11 | raw bytes, not UTF-8 | `path/non-utf8`, byte `0xff` in the middle of a name |
| 12 | the encoding is blind to bytes the wire grammar reserves | `path/delimiter-bytes`, carrying space, `=` and a newline |
| 13 | canonical `path` carries no leading `/` and no leading `./` | `rejected/obj-path-leading-slash`, `obj-path-leading-dot-slash` |
| 14 | `end` carries `state`, `reason`, `walked` and the eleven counts | both `canonical-end` |
| 15 | `state` and `reason` are a closed pair, exactly two valid pairings | `canonical-end/completed-design-sample`, `skipped`; `rejected/end-bad-state-reason`, `end-bad-state-reason-2`, `end-unknown-state` |
| 16 | `walked` and the eleven counts are unsigned decimal | `rejected/end-negative-count`, `end-non-numeric-count` |
| 17 | all eleven counts always present, including when zero | `canonical-end/skipped`, every count zero and present; `rejected/end-missing-count` |
| 18 | per-token reconciliation: nine equalities, not two sums | `capture-reject/token-miscount`, and `aggregate-only` whose sums are right and whose categories are wrong |
| 19 | `walked` equals the number of `obj` records | `capture-valid/design-sample`, `two-objects`; `capture-reject/walked-mismatch` |
| 20 | `mig-checked` equals the number of `case=5` records | `capture-valid/two-objects` (one of two is case 5); `capture-reject/mig-checked-mismatch` |
| 21 | `mig-failed` is not greater than `mig-checked` | `capture-reject/mig-failed-exceeds` |
| 22 | a `state=skipped` trailer carries no `obj` records and every numeric field is zero | `capture-valid/skipped`; `capture-reject/skipped-with-record`, `skipped-nonzero-count` |
| 23 | exactly one trailer per capture | `capture-reject/no-trailer`, `two-trailers` |
| 24 | a skipped pass and a completed walk of an empty tree are distinguishable | `capture-valid/skipped` beside `capture-valid/empty-completed`, identical counts, different pairing |
| 25 | the stream shares the captured install output with the human `echos` lines | `capture-valid/mixed-with-human-lines` |
| 26 | the trailer TERMINATES the capture: no record may follow it | `capture-reject/obj-after-trailer`, whose counts reconcile so only the position rule rejects it |

**Uncovered obligations: zero.**

## Direction 2: corpus to design

Every corpus vector, against the design clause it comes from, its intended
result, and any canonical-output choice the design **permits without
requiring**. Completion rule: **zero vectors without a derivation**.

The last column is the one that catches quiet decisions. Where the design
permits a form without requiring it, the corpus necessarily picks one, and that
pick is authored rather than derived.

### Canonical formatter vectors

| Vector | Design clause | Intended | Authored choice |
| --- | --- | --- | --- |
| `canonical-obj/simple` | the design's own sample capture, copied byte for byte | accept | none: it is the design's literal |
| `canonical-obj/root-relative` | `path` is relative to `DEST_PATH` | accept | the object path, and `case=3`/`rewritten`/`rewritten` |
| `canonical-obj/delimiter-bytes` | encoding blind to reserved bytes | accept | the name `a b=c\n`, and `case=4`/`already-correct`/`not-applicable` |
| `canonical-obj/non-utf8` | raw bytes, not UTF-8 | accept | byte `0xff` mid-name, and `case=2`/`not-dynamic`/`not-applicable` |
| `canonical-obj/shortest` | `path` never empty, even length | accept | the name `a`, and `case=7`/`excluded`/`not-applicable` |
| `canonical-obj/at-wrap` | producible with `od` plus `tr` | accept | the 16-byte name, and `case=6`/`rewritten`/`failed` |
| `canonical-obj/across-wrap` | same | accept | the 17-byte name, and `case=1`/`rewritten`/`unchanged` |
| `canonical-end/completed-design-sample` | the design's own sample trailer | accept | none: it is the design's literal |
| `canonical-end/skipped` | the `skipped`/`patchelf-absent` pairing, all counts zero | accept | none: the clause fixes every value |

The **case and token assignments** on six of the seven `obj` vectors are
authored. The design does not tie any disposition to any path; the assignments
were chosen so the canonical class covers all five `rpath` tokens, all four
`interp` tokens and all seven cases with no vector spent on coverage alone.

The **canonical field order** is taken from the design's sample capture. The
design fixes one order for the formatter and requires the reader to be
order-independent, so the order is derived, and the permutations in class 2 are
what prove the reader does not depend on it.

### Other reader-valid vectors

| Vector | Design clause | Intended | Authored choice |
| --- | --- | --- | --- |
| `reader-valid/obj-permuted` | fields located by name rather than by position | accept | the specific permutation, fully reversed |
| `reader-valid/obj-permuted-2` | same | accept | a second, differently scrambled order |
| `reader-valid/end-permuted` | same | accept | the fully reversed 14-field order |
| `reader-valid/end-permuted-2` | same | accept | `walked` first, then the pairing |

All four are lawful and the formatter is never required to emit them. Their
existence is a **test consequence** of the design's name-based resolution rule,
not a new grammar decision.

### Rejected vectors

| Vector | Design clause | Intended | Authored choice |
| --- | --- | --- | --- |
| `unknown-marker` | unknown marker rejected rather than guessed | reject `marker` | the marker `CPLX-ELF/2` |
| `unknown-kind` | `obj` and `end` are the two kinds | reject `kind` | the kind `blob` |
| `obj-missing-field` | each listed field exactly once | reject `missing` | `path` omitted |
| `obj-duplicate-field` | a repeated field is rejected; the design cites `rpath=failed rpath=rewritten` | reject `duplicate` | none: the design's own example |
| `obj-unknown-field` | carries no others | reject `unknown` | the field `extra` |
| `obj-bad-rpath-token` | space-free wire tokens distinct from prose labels | reject `token` | the human label `already correct` |
| `obj-bad-interp-token` | closed per-axis vocabularies | reject `token` | `not-dynamic`, lawful on the other axis |
| `obj-case-zero`, `obj-case-eight` | `case` is an integer 1 to 7 | reject `case` | the two adjacent out-of-range values |
| `obj-path-empty` | `path` is never empty | reject `path` | none |
| `obj-path-odd-length` | hex, therefore always even length | reject `path` | the odd value `616` |
| `obj-path-uppercase-hex` | only `0` to `9` and `a` to `f` | reject `path` | the simple vector upper-cased |
| `obj-path-non-hex` | same | reject `path` | the letter `g` |
| `obj-path-leading-slash` | canonical form carries no leading `/` | reject `path` | the simple vector prefixed |
| `obj-path-leading-dot-slash` | no leading `./` | reject `path` | the simple vector prefixed |
| `end-bad-state-reason`, `-2` | exactly two valid pairings | reject `pairing` | the two cross-products of the valid values |
| `end-unknown-state` | a later cause owes a new token and a review | reject `pairing` | the state `aborted` |
| `end-missing-count` | all eleven always present | reject `missing` | `i-not-applicable` omitted |
| `end-duplicate-count` | each field exactly once | reject `duplicate` | `walked` repeated |
| `end-unknown-count` | carries no others | reject `unknown` | the field `r-bogus` |
| `end-negative-count` | unsigned decimal | reject `number` | `walked=-1` |
| `end-non-numeric-count` | unsigned decimal | reject `number` | `walked=one` |

The **reason tokens** are authored. The plan requires every rejected form to be
rejected "with the reason distinguishable"; it does not fix a vocabulary, so
these spellings are a corpus labelling choice.

### Path matrix vectors

Every raw input and expected hex is stated in the plan's own matrix except the
wrap pair, which the plan requires be authored at a measured width.

| Vector | Design clause | Intended | Authored choice |
| --- | --- | --- | --- |
| `simple`, `root-relative`, `delimiter-bytes`, `non-utf8`, `shortest` | the plan's matrix, derived there from the design's `path` clause | accept | none: the plan states the literals |
| `at-wrap` | the last input producing single-line `od` output | accept | the 16-byte name `lib/abcdefg.so.1` |
| `across-wrap` | the first input whose `od` output wraps | accept | the same name plus one byte |

The **escape vocabulary** `%SP%`, `%NL%`, `%B255%`, `%DEST%` is authored. The
design says nothing about how a corpus writes a raw byte; the escapes are named
and decimal so the input is not expressed in the encoding under test.

### Capture vectors

| Vector | Design clause | Intended | Authored choice |
| --- | --- | --- | --- |
| `capture-valid/design-sample` | the design's complete one-object capture | accept | none: the design's literal |
| `capture-valid/empty-completed` | a completed walk of an empty tree | accept | none |
| `capture-valid/skipped` | a skipped pass | accept | none |
| `capture-valid/two-objects` | per-token and `mig-checked` over more than one record | accept | the two-record composition, one case 5 |
| `capture-valid/mixed-with-human-lines` | the stream shares the captured output with the `echos` lines | accept, ignoring the foreign lines | the two human lines quoted |
| `capture-reject/unknown-marker-in-capture` | a recipe rejects a marker it does not know | reject `marker` | placing it before a valid trailer |
| `capture-reject/no-trailer`, `two-trailers` | exactly one trailer | reject `trailer` | none |
| `capture-reject/obj-after-trailer` | the trailer terminates the capture, Design Area 3 as amended | reject `trailer` | the counts are made to reconcile deliberately, so the vector isolates the position rule from the arithmetic |
| `capture-reject/walked-mismatch` | `walked` equals the record count | reject `walked` | `walked=2` against one record |
| `capture-reject/token-miscount` | per-token equality | reject `per-token` | one record, the wrong token counted |
| `capture-reject/aggregate-only` | the design's own counter-example: right sums, wrong categories | reject `per-token` | two records, both `failed`, trailer claiming both `rewritten` |
| `capture-reject/mig-checked-mismatch` | `mig-checked` equals the case 5 count | reject `migration` | a case 3 record with `mig-checked=1` |
| `capture-reject/mig-failed-exceeds` | `mig-failed` not greater than `mig-checked` | reject `migration` | 2 against 1 |
| `capture-reject/skipped-with-record` | a skipped trailer carries no records | reject `skipped` | one record present |
| `capture-reject/skipped-nonzero-count` | every numeric field zero | reject `skipped` | `r-rewritten=1` |

**Vectors without a derivation: zero.**

## Silences found, and how they were adjudicated

The audit is also where a design silence has to surface, because the
adjudication rule presumes every later divergence is an implementation defect,
and that is only safe if the corpus was right when frozen.

**One silence found: the position of the trailer within a capture.** The design
called `end` a trailer and required exactly one, but did not state whether an
`obj` record appearing after it is rejected. Two readings survived: "trailer" as
a positional obligation, or as a name for the kind.

**Adjudication path 3 was taken.** The plan is explicit that a clause which is
silent or admits both readings is a design defect, to be returned for reviewed
amendment rather than settled by whichever artifact is easier to edit. An
earlier draft of this ledger instead declared the form out of scope and froze
`/1` around the gap. That was the same mistake wearing different clothes:
declaring a form undefined is still deciding it, and the decision was not the
corpus author's to make. The code review caught it.

The ambiguity was routed to design authority and resolved there:
**the trailer terminates the capture, and no record may follow it.**
Design Area 3 now states it, with the reason: `obj`, `end`, `obj` is the shape a
second run leaves when its own trailer was lost, and the count rule alone would
admit it whenever the figures happened to reconcile across all three records.

**The resolution CLARIFIES `/1` rather than redefining it, so the marker
stands.** The plan requires a changed meaning to produce a new marker and a new
corpus rather than a redefinition behind the old token, and that rule is not
engaged here: the position was previously unstated rather than stated otherwise,
nothing had implemented `/1` before this step, and no conforming consumer could
have relied on a form the grammar never described. A resolution reversing a
stated meaning would have owed `/2`.

The corpus, the ledger and the reader were then redone in the plan's required
order: amendment first, audit second, freeze third, implementations last. The
blob id below is the SECOND freeze, and it supersedes the pre-adjudication one.

No other clause was found silent or double-read. Every other vector traces to a
clause that admits one reading.

## The freeze

Recorded **after** the ledger above and **before** either implementation was
compared against the corpus, so the bytes cannot have been fitted to what an
implementation happened to do.

<!-- markdownlint-disable MD034 -->

| Artifact | Claim it carries | Value |
| --- | --- | --- |
| this ledger | derivation correctness at freeze time | the two directions above, zero uncovered, zero underived |
| the corpus blob id | stability after the freeze | recorded below |
| the measured `od` width | the wrap pair is authored at a real boundary | 16 bytes, GNU coreutils 8.32 |

Corpus Git blob id, `git hash-object docs/v0.27.0/contract.cplx-elf-1.txt`:

```text
64a3173cebf84add5c7c40020a50e93390df32b2
```

A digest proves the bytes have not moved since they were measured. It says
nothing about whether they were correctly derived, which is what the two
directions above are for.
