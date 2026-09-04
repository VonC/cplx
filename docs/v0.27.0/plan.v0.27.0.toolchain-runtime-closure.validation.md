# v0.27.0 toolchain-runtime-closure implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.toolchain-runtime-closure.md](plan.v0.27.0.toolchain-runtime-closure.md)
step by step. Nothing has been written yet: there is no checker, no
configuration bundle, no harness and no capture, so every step below is at its
initial state and every check section holds its placeholder.

> Initial-skeleton note: this is the first version, written by the `write-plans`
> skill before any implementation check. `Goal for Step N` and `Step N
> improvement expectations` are filled from the plan; every
> `Analysis of Step N implementation state` opens with "Not started"; every
> other check section holds the literal placeholder
> `_(empty — no check has taken place yet.)_.` until an implementation check
> replaces it. No `Missing work for Step N` section exists yet: only a check that
> concludes the step is not implemented adds one.
>
> Markdown lint note: never leave a space immediately inside an inline code span
> (MD038); write a needed space as the token `[space]`, as in `` `[space]${x}` ``.
> The placeholder ends in `)_.` so the line is not pure italic text (MD036). It
> carries the one em dash in this document, because the placeholder is a literal
> token an implementation check matches on rather than prose.

## How this validation departs from the standard template

The template's per-step check sections assume a Python project with a pytest
coverage number. cplx has no `tests/` tree and no coverage gate, so two section
names change and one is dropped, exactly as item 2 of this collection did:

| Template section | Here | Why |
| --- | --- | --- |
| `Unit test coverage check for Step N` | `Harness case check for Step N` | there are no unit tests and no coverage percentage; what exists is a case count in `verify.closure-check.sh`, and the honest question is whether each planned case is present and answered |
| `Performance check for Step N` | `Cost and structure check for Step N` | the plan's bound is a walk count and an index placement, not a latency; a structural check answers it and a timing one would measure the machine |

Everything else follows the template, including the rule that a step reported as
anything other than fully implemented gains a `Missing work for Step N` section.

## File-based IO cost clarification for v0.27.0 toolchain-runtime-closure (implementation)

Every step must respect the classification established in the plan:

- The checker walks the tree exactly once, and every per-object fact any
  invariant needs is collected during that walk.
- One `readelf -d -V` invocation per ELF, never one per question.
- The provider index is built once, before the object loop, so resolving a
  `DT_NEEDED` name is a hash lookup rather than a directory scan.
- Content digests are computed only for lookup names with more than one
  candidate path.
- No step adds a second full walk of the tree to the production install path,
  and no step adds a line to `install_pkg.sh`.

## Complexity bound clarification for v0.27.0 toolchain-runtime-closure (implementation)

- **O(1) amortized per object and per lookup name**: one read per ELF, one hash
  lookup per `DT_NEEDED` name, one hash lookup per version need.
- **O(n) total per phase**: one tree walk, one provider-directory enumeration,
  one pass per invariant over records already collected.

Every implemented step is reviewed against this bound in its cost and structure
check section. The shape that would break it is resolving a name by scanning the
provider directories inside the object loop.

---

## Step 0. Harness, capability gate and red baseline

### Analysis of Step 0 implementation state

Not started. Step 0 is not implemented because `docs/v0.27.0/verify.closure-check.sh`,
`docs/v0.27.0/contract.closure-tools.txt` and
`docs/v0.27.0/fixtures.closure-corpus.txt` do not exist, and no capture has been
taken on either host.

### Goal for Step 0

Create the harness with its `--step N` interface, its three-outcome capability
gate over `readelf`, GNU `sha256sum` and Bash associative arrays, and its
`UNANSWERED` exit-5 refusal path. Declare the checker's own host-tool allowlist,
commit the fixture corpus as text, and capture the red baseline on the RHEL 9.8
build host and on the Debian 12 agent.

### Step 0 improvement expectations

- The capability gate reports supported, unsupported or unavailable, and never a
  pass by omission.
- A step suite run on a host missing its declared tool exits 5 and names the
  command that would answer it.
- Every case this effort will add is shown failing for its stated reason before
  any production line exists.
- The FOUR existing harnesses the validation snapshot enumerates are RUN and
  named: `verify.install-pkg.sh`, `verify.relocation-rpath.sh`,
  `verify.wrapper-scope.sh` and `verify.wrapper-accept.sh`. Lint is not
  execution, and the preservation claim rests on the runs rather than the gate.
- They run INDEPENDENTLY, never chained, because a chain would let one 5 stop
  the rest from running. Each capture is retained and the aggregate is
  THREE-WAY: any status other than 0 or 5 FAILS, any 5 with no failure returns
  UNANSWERED naming the harness, and only four zeros PASS. Exit 5 is never
  rounded up to a pass, which is the plan's own rule applied to its own step.
- The two captures are retained beside the plan.
- A lint failure STOPS the cycle: the workflow command chains with `&&`, so a
  red `lint_shell.sh` never lets the step suite run and report green beside it.
- The untouched-installer check is HEAD-relative and exit-status driven, so a
  STAGED edit to `install_pkg.sh` fails it. A `git diff --stat` that ignores the
  index would print nothing and read as proof.

### What was implemented for Step 0

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 0

_(empty — no check has taken place yet.)_.

### Architecture check for Step 0

_(empty — no check has taken place yet.)_.

### Cost and structure check for Step 0

_(empty — no check has taken place yet.)_.

### Harness case check for Step 0

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 0

_(empty — no check has taken place yet.)_.

---

## Step 1. The declared candidate shape and the observed loader scope

### Analysis of Step 1 implementation state

Not started. Step 1 is not implemented because
`src/setups/env/bin/closure_check.sh` does not exist, so nothing derives the
declared candidate shape and nothing classifies an observed directory as
PRESENT, ABSENT or UNEXPECTED.

### Goal for Step 1

Create the checker, deriving the declared candidate shape from the declared
roots, their declared immediate subdirectories and the fixed suffixes, in the
loader's order and deduped preserving first occurrence, while taking the observed
loader scope from `build_elf_rpath` itself through the installer's MAIN BOUNDARY
sourcing seam. Emit the three locally observable typed results and refuse on
UNEXPECTED.

### Step 1 improvement expectations

- The declared shape is derived without touching the filesystem.
- The observed scope equals `build_elf_rpath`'s output byte for byte, because it
  is that function rather than a copy of it.
- `current/lib` and `python-3.13.9/lib` are both accepted, since the second
  declared input is a subdirectory list rather than a version list.
- An undeclared root or subdirectory is refused by name, and the refusal is
  unwaivable by construction.
- `install_pkg.sh` is unchanged, and `verify.relocation-rpath.sh --step 3` is
  still green.
- The delivered script topology is fixed here, before any later step adds a
  script: every shipped file has a row naming where it runs, its deployed path
  and how it gets there, and `closure_publish.sh` and `closure_d10.sh` are
  recorded as NOT travelling in the archive.
- A failure to source the installer or to call `build_elf_rpath` becomes the
  checker's typed UNDETERMINED result, never an empty scope and never an
  inherited exit, proved by a case that drives a sourced `fatal` and a non-zero
  return and shows the aggregate report continuing to completion.
- The topology separates AUTHORITATIVE copies, delivered by the pipeline from
  the resolved cplx commit, from PAYLOAD copies staged into the archive for
  operator use. No evidence-producing script comes out of the archive it judges.
- The module set is FIXED AND UNCONDITIONAL: `closure_check.sh`,
  `closure_config.sh`, `closure_elf.sh` and `closure_rules.sh` are all created
  here with their contract comments, no step carries a conditional split, and no
  `closure_scope.sh` exists in any shape. Each step's files-involved list, line
  budget and module boundary agrees with the topology table.
- NINE production scripts exist in total, `ci/deliver-closure-tools.sh`
  included, since the pipeline step that places the authoritative copies is
  itself a shipped script and is the one that cannot be delivered by them. All
  four checker modules are staged as payload copies, and every invariant
  including derived membership has ONE owner, `closure_rules.sh`.
- The host-tool contract is enumerated rather than sampled and covers every
  shipped script: `readelf`, `sha256sum`, `git`, `tar`, `find`, `mktemp`,
  `chmod`, `rm`, `cp`, `ln`, `cat`, `tee` and `mkfifo`. Step 0's harness
  extracts every command-position word from those scripts and fails on any word
  absent from the contract, so the list cannot drift by hand.

### What was implemented for Step 1

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 1

_(empty — no check has taken place yet.)_.

### Architecture check for Step 1

_(empty — no check has taken place yet.)_.

### Cost and structure check for Step 1

_(empty — no check has taken place yet.)_.

### Harness case check for Step 1

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 1

_(empty — no check has taken place yet.)_.

---

## Step 2. The configuration bundle and its authority

### Analysis of Step 2 implementation state

Not started. Step 2 is not implemented because
`src/setups/env/closure/closure-config.txt` does not exist, no digest domain is
defined anywhere, and the checker has no notion of an identity envelope.

### Goal for Step 2

Commit the four declarations as one document at a fixed path, define its digest
as the SHA-256 of its exact committed bytes, add the identity envelope naming
that digest and the cplx commit that holds it, and implement the three parties'
asymmetric checks: packaging resolves at the commit it names, the agent checks
internal consistency only, and publication resolves for itself.

### Step 2 improvement expectations

- The digest covers the document bytes and never the envelope, so it cannot
  cover itself.
- A branch or tag reference is refused; only a commit SHA is accepted.
- The agent's output states its own limit, so a green agent run cannot be read as
  authority it does not have.
- The paired-edit case is asserted from all three sides: the agent accepts, and
  packaging and publication refuse.
- The grammar is a contract of its own, separate from the digest, and one parser
  implements it for every party: record shape, ordering, escaping, permitted
  relative-path form, cross-references.
- The grammar is literal: `CPLX-CLOSURE/1`, five record tokens with exact field
  counts, two escape sequences, a relative-path rule, `root` order significant
  and nothing else, and cross-references validated at parse time.
- All three record documents have a literal grammar: `CPLX-CLOSURE/1` for the
  configuration, `CPLX-CLOSURE-ENVELOPE/1` for the identity envelope and
  `CPLX-CLOSURE-EVIDENCE/1` for the verification result, sharing one lexical
  shape and one parser per record table.
- Every configuration placeholder has an exact lexical domain, so a one-segment
  root name, a multi-segment subdirectory and a two-wildcard glob are each
  decidable rather than a matter of reading.
- The valid example from the plan round-trips through the parser unchanged, and
  so does a valid envelope.
- Envelope negatives: an uppercase digest, a short commit, a branch name in
  place of a commit, two `digest` records and a missing `source` each refuse.
- Decoding precedes domain validation, proved by a case where `%2F` would
  otherwise smuggle a separator past a no-slash domain.
- Evidence negatives: a `pre` path outside the declared candidate set, a `post`
  missing for a declared directory, two `pre` records for one path, `pre`
  records out of canonical byte order, an invalid `verdict`, an invalid
  `unexpected` side, and an invalid `pre` third field each refuse.
- The verdict is DERIVED from an exact truth table: `pass` only when every
  paired observation agrees AND no `unexpected` record exists, `divergent` in
  every other valid case, so unexpected-only evidence has a verdict rather than
  falling between the two rules.
- Evidence SEMANTIC negatives: a CONTRADICTORY PASS, `verdict|pass` beside a
  differing `pre` and `post` pair; `verdict|pass` beside any `unexpected`
  record; and an `unexpected` naming a path that is in the declared candidate
  set. Each refuses at parse time, on both ends, because publication trusts a
  passing result and must not be the first reader to check it.
- Evidence is CANONICAL BY CONSTRUCTION at the byte level: UTF-8, LF endings
  and never CRLF, exactly one final newline, no comments, no blank lines, and
  the canonical record order. A case per rule, so a CRLF document, a document
  with two trailing newlines and a document with none each refuse, and a
  noncanonical-equivalence case proves two documents differing only in
  formatting cannot both exist. Q06's byte comparison then compares meaning.
- Negative cases exist for each refusal the grammar names: a wrong field count,
  a duplicate key, an undeclared root in a `subdir`, an absolute `floor`
  location, a `floor` location naming an undeclared root, a leading zero in a
  generation count, a waiver naming a member the floor does not declare, an
  unknown record token, and an undefined `%` escape. All fail closed at parse
  time rather than being ignored.

### What was implemented for Step 2

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 2

_(empty — no check has taken place yet.)_.

### Architecture check for Step 2

_(empty — no check has taken place yet.)_.

### Cost and structure check for Step 2

_(empty — no check has taken place yet.)_.

### Harness case check for Step 2

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 2

_(empty — no check has taken place yet.)_.

---

## Step 3. The static subject set and the derived membership half

### Analysis of Step 3 implementation state

Not started. Step 3 is not implemented because nothing walks the tree for
subjects, nothing reads `DT_NEEDED` outside the installer, and no provider index
exists.

### Goal for Step 3

Walk the tree once, identify every ELF by its magic bytes, record its
`DT_SONAME`, `DT_NEEDED` list and version needs from a single `readelf -d -V`
per object, build the provider index once before the loop, and implement the
derived membership half over every shipped ELF rather than over a closure from
the entry points.

### Step 3 improvement expectations

- The subject count equals the planted ELF count, with no object excluded for
  being unreachable.
- A `lib-dynload` module with an unresolvable `DT_NEEDED`, reached by no
  entry-point walk, is refused by name. This is the case a walk-based subject set
  reports as a pass.
- An unreferenced shipped ELF is accepted and reported, never excluded.
- A `root/usr/bin` object is a subject and never a provider.
- The walk count and the index construction are measured by harness
  instrumentation during a real run, not read out of the source text: exactly
  one walk, exactly one index construction, and the construction observed before
  the first object read.
- `readelf` runs under a pinned `LC_ALL=C`, and a case with a translated locale
  proves the parse does not silently return empty needs.
- An absent, non-zero or unparsable `readelf` is typed UNDETERMINED naming the
  object and the missing input, not a semantic REFUSAL, and the aggregate run is
  non-passing because an UNDETERMINED never counts toward a green. A case
  asserts both halves: the typed result, and that publication is impossible from
  that run. UNANSWERED stays a harness outcome and never a production verdict.

### What was implemented for Step 3

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 3

_(empty — no check has taken place yet.)_.

### Architecture check for Step 3

_(empty — no check has taken place yet.)_.

### Cost and structure check for Step 3

_(empty — no check has taken place yet.)_.

### Harness case check for Step 3

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 3

_(empty — no check has taken place yet.)_.

---

## Step 4. The floor, coherence, rule 1, rule 2 and aggregation

### Analysis of Step 4 implementation state

Not started. Step 4 is not implemented because no floor check, no version
coherence, no duplicate-provider rule, no declared-family rule and no
UNDETERMINED producer exist.

### Goal for Step 4

Implement the declared floor half with its required-location column as the
observable test, provider-aware version coherence resolved through the provider
the object names, rule 1 over candidates of one exact lookup name compared by
content digest, rule 2 over the declared family list, and the aggregation rule
that reserves UNDETERMINED for an input that could not be obtained.

### Step 4 improvement expectations

- Every invariant is evaluated on every run, and no invariant suppresses another.
- Coherence still answers when rule 1 refuses, against the first candidate in
  scope order, which is the correction the design's round 2 required.
- The 20 multi-candidate names of the measured archive pass rule 1, which is the
  positive control against over-refusal.
- The measured `libbfd` pair fails rule 2, and the same pair with the family
  undeclared is not examined.
- An UNDETERMINED result is reported with the input it lacked and never counts
  toward a green.

### What was implemented for Step 4

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 4

_(empty — no check has taken place yet.)_.

### Architecture check for Step 4

_(empty — no check has taken place yet.)_.

### Cost and structure check for Step 4

_(empty — no check has taken place yet.)_.

### Harness case check for Step 4

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 4

_(empty — no check has taken place yet.)_.

---

## Step 5. Waivers, the packaging gate and the publication boundary

### Analysis of Step 5 implementation state

Not started. Step 5 is not implemented because `pkg.sh` still runs its `tar`
with no gate in front of it, no waiver is validated, and
`src/setups/env/bin/closure_publish.sh` does not exist.

### Goal for Step 5

Stage the configuration bundle into the tree before the tar, call the checker
from `pkg.sh` and refuse the run on any refusal, implement the unknown, stale and
active waiver outcomes, and add the publication re-check in its fixed five-step
order with step 0 computing the archive identity.

### Step 5 improvement expectations

- A missing floor member with no waiver refuses and produces no archive.
- The same run with the sqlite waiver active produces an archive, marks it a
  validation artifact, and publication refuses it.
- A waiver whose member is present is refused as stale, using the floor entry's
  own location test rather than a document fact.
- A waiver naming a tool root is refused as UNKNOWN, since waivers name floor
  members only.
- A stripped configuration fails at publication step 1, before the waiver
  question is asked, which is why the order is asserted as an order.
- Every existing `pkg.sh` behavior is preserved: `--add`, the `--` passthrough,
  `--exclude=old`, the SHA1 deduplication and the `latest` symlink, including
  the `tar --sort=name` form at line 130, which this effort does not change.
- The selector is the explicit `--closure-gate` flag, and all four corners plus
  the two boundary cases are in Step 5's own test-first list rather than
  promised in prose: the flag with `tools`, the flag with another target,
  `tools` without the flag, an unrelated target with no flag, a renamed `tools2`
  target, and `pkg tools` reaching the gate through the `pkg_tools.sh` overlay.
- The caller migration is named: `src/setups/env/bin/pkg_tools.sh` line 18 is
  the one in-scope invocation that changes, the `pkg` dispatcher needs no
  change, and any out-of-repository path that packages `tools` refuses on
  purpose until umbrella item 7 adopts the flag.
- Staged bytes come from the resolved commit rather than the working tree, and a
  case with a dirty working tree proves the shipped declaration is the reviewed
  one. Staged files persist on success and are removed on refusal.
- Negative cases exist for a MISSING SOURCE file, a FAILED COPY and an ABSENT
  STAGED bundle, and each refuses before `tar` rather than skipping the check.
- Publication stages exclusively: a case with a SOURCE MUTATED DURING THE COPY
  proves the digest describes the completed copy and not the source; cases with
  a PRE-EXISTING and with a SYMLINKED destination prove the promotion refuses
  rather than overwrites or follows; and a case with a group-writable staging
  root refuses before any copy.
- THE HANDOFF IS A DESCRIPTOR, NOT A PATHNAME, under the interface Q11 fixes:
  `CPLX_CLOSURE_ARCHIVE_FD` and `CPLX_CLOSURE_ARCHIVE_SHA256`, no pathname
  passed at all, the gate owning the descriptor's lifetime, a single pass that
  feeds hashing and streaming from the same read, and any non-zero callback exit
  a publication refusal.
- THE UPLOAD IS TRANSACTIONAL: `upload_begin` creates a non-public object,
  `upload_write` fills it, both pipeline participants are awaited and their
  statuses collected, the digest is compared, and only then does `upload_commit`
  make it public. `upload_abort` runs on every failure path.
- The four operation names are THIS EFFORT'S ADAPTER ABI, implemented and
  tested here; umbrella item 7 keeps its own public API and supplies an adapter
  with the same lifecycle.
- Every command whose absence could strand state is PREFLIGHTED BEFORE
  `upload_begin`: `cat`, `tee`, `mkfifo`, `sha256sum`, `mktemp`, `chmod` and
  `rm`, all declared in the closure host-tool contract.
- `set -o pipefail` is in the executable flow, so an independent `cat` or `tee`
  failure reaches the status check instead of being masked by the last stage.
- The cleanup trap is armed as soon as the scratch directory exists, aborts only
  when a stage exists, disarms itself on entry so a signal cannot re-enter it,
  and names the scratch path on stderr without changing the verdict when
  removal itself fails.
- A STUB UPLOADER implementing the four operations demonstrates the contract on
  seventeen cases: the good path; a pathname refused; the original bytes still
  streamed after the promoted path is mutated, unlinked and replaced; and NO
  PUBLIC OBJECT after each of a wrong expected digest, a failing hasher, a
  failing `cat`, a failing `tee`, a failing `upload_write`, a preflight failure,
  a `chmod` failure, an `upload_begin` failure, a setup failure, an
  interruption, a digest-read failure, an abort failure and a commit failure.
  Two further cases assert that an `upload_begin` failure attempts NO abort,
  since no stage exists, and that a signal during cleanup aborts EXACTLY ONCE,
  counted from the stub rather than inferred. Each outcome is asserted by asking
  the stub what it has made public, and the scratch directory is asserted gone
  wherever removal succeeds.

### What was implemented for Step 5

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 5

_(empty — no check has taken place yet.)_.

### Architecture check for Step 5

_(empty — no check has taken place yet.)_.

### Cost and structure check for Step 5

_(empty — no check has taken place yet.)_.

### Harness case check for Step 5

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 5

_(empty — no check has taken place yet.)_.

---

## Step 6. Verification on the Debian agent and the evidence artifact

### Analysis of Step 6 implementation state

Not started. Step 6 is not implemented because nothing derives the archive-side
observation, nothing compares two observations, no live observer exists, and no
evidence artifact is produced for publication to check.

### Goal for Step 6

Create the verification driver that reads the archive it is about to install for
the pre-install observation, installs, derives the installed observation,
compares the two and refuses DIVERGENT, runs the static checker on the installed
tree and the live observer against one named process, then emits one evidence
artifact keyed by the SHA-256 of the archive file.

### Step 6 improvement expectations

- A directory present in the archive and absent under the installed tree is
  refused as DIVERGENT, while packaging passes its own local check.
- A directory present on the build account that never entered the tar is also
  refused, which a transported packaging claim would have reported as present on
  both sides.
- Verification unable to read the pre-install archive contents refuses, naming
  the missing input, rather than proceeding with one side.
- A live trace that inventoried no process is reported inconclusive.
- The archive identity is computed over the archive file and never over an
  unpacked tree.
- The authoritative verifier is delivered by the pipeline from the resolved cplx
  commit and runs from the workspace BEFORE the archive is opened, and the
  ordering itself is a case.
- ONLY WORKSPACE COPIES PRODUCE EVIDENCE, categorically. A case with no delivery
  proves the job refuses rather than falling back; a case with a TAMPERED
  embedded copy proves it is reported as a payload difference and never
  executed; and a case with a BYTE-IDENTICAL embedded copy proves it is STILL
  not executed, because equality is not authority.
- The evidence document is `CPLX-CLOSURE-EVIDENCE/1`, and its six records map
  one to one onto the fields Design Area 7 names.
- The results root is validated before any write: a real directory, not a
  symlink, owned by the running user, not group or other writable. A case for
  each failure.
- Only a COMPLETE result occupies the canonical path. Cases cover a PARTIAL
  write leaving nothing at the canonical name, a RERUN after an incomplete first
  attempt succeeding rather than being blocked forever, an IDENTICAL completed
  result being idempotent, and a DIFFERENT result being retained under a
  timestamped conflict name and stopping publication.
- Producer and consumer share one schema and one parser, and publication opens
  the exact keyed path without scanning the root or deriving a location from the
  archive.
- On any host other than the Debian agent, the suite reports UNANSWERED with
  exit 5 and names the agent.

### What was implemented for Step 6

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 6

_(empty — no check has taken place yet.)_.

### Architecture check for Step 6

_(empty — no check has taken place yet.)_.

### Cost and structure check for Step 6

_(empty — no check has taken place yet.)_.

### Harness case check for Step 6

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 6

_(empty — no check has taken place yet.)_.

---

## Step 7. The D10 interface, acceptance and documentation

### Analysis of Step 7 implementation state

Not started. Step 7 is not implemented because the D10 evidence shape and policy
do not exist, no acceptance run has been taken on either host, and the project
documentation says nothing about the checker or its configuration.

### Goal for Step 7

Implement the D10 evidence shape and the policy that consumes it, with the
consumer set bound to this design's subject rule, the lowest satisfying candidate
as the result and the convergence rule on re-read. Run the acceptance on both
hosts, and add the reference and explanation pages.

### Step 7 improvement expectations

- The policy returns the lowest satisfying candidate, with zero spare nodes
  required, and fails when neither candidate satisfies.
- All three non-convergent shapes fail as separate cases: a higher second
  result, a lower one, and neither satisfying.
- A consumer set of zero is reported inconclusive, never as satisfaction.
- The packaging check passes on the build account, with every refusal named and
  the `tools/old/py3.13` repair recorded rather than treated as a check failure.
- The packaged archive resolves with no host fallback on Debian 12, from a
  listing over the whole scope and a live trace naming the venv process.
- The unmodified archive passes rule 1, and one negative control exists per
  independently refusable invariant.
- Clearing `tools/old/py3.13` is an OPERATOR PREREQUISITE, recorded with the
  inspected target and the retained location of the recoverable move. A case
  asserts that no script in this effort removes a directory on a live account,
  so an unauthorized automated deletion is a failure rather than a shortcut.

### What was implemented for Step 7

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 7

_(empty — no check has taken place yet.)_.

### Architecture check for Step 7

_(empty — no check has taken place yet.)_.

### Cost and structure check for Step 7

_(empty — no check has taken place yet.)_.

### Harness case check for Step 7

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 7

_(empty — no check has taken place yet.)_.
