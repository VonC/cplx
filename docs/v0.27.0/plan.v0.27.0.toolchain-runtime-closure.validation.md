# v0.27.0 toolchain-runtime-closure implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.toolchain-runtime-closure.md](plan.v0.27.0.toolchain-runtime-closure.md)
step by step. Step 0 is implemented and checked: the harness, its host-tool
contract, its fixture corpus, the two target-host captures and the four
preservation captures exist, and the Step 0 verdict below is Yes against the
plan's corrected feature-preservation contract. There is still no checker, no
configuration bundle and no packaging gate, so steps 1 to 7 are at their initial
state and their check sections hold their placeholder. The document verdict
above stays No until every step is checked.

> Initial-skeleton note: the skeleton was written by the `write-plans` skill
> before any implementation check, and it still governs every step no check has
> reached yet. `Goal for Step N` and `Step N improvement expectations` are filled
> from the plan; an unchecked `Analysis of Step N implementation state` opens
> with "Not started"; every other unchecked section holds the literal placeholder
> `_(empty — no check has taken place yet.)_.` until an implementation check
> replaces it. A `Missing work for Step N` section exists only where a check
> concluded the step is not implemented.
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

Yes. Step 0 has been fully implemented.

The harness, contract, corpus and two target-host captures exist, and those
captures report 66 cases with no failures on the RHEL 9.8 build host and on the
Debian 12 agent. The four existing harnesses were run independently, never
chained, at the four invocations the plan fixes, and all four returned 0, so the
three-way preservation aggregate is PASS.

Code review round 1 refused an earlier version of this verdict, and it was right
to. The plan then fixed four ARGUMENT-FREE preservation commands, the retained
record showed them returning 2, 1, 1 and 2, and the verdict computed PASS from
different invocations without saying that the plan's own aggregate reads the
commands it names. That measurement is what resolved the contradiction rather
than excusing it: none of the four bare forms can return zero without changing a
frozen harness of items 1, 2 and 3, and `verify.wrapper-accept.sh` has no default
`--mode` at all, so its bare form is a usage error by construction and the bare
list was unsatisfiable rather than strict. The plan's Step 0 feature-preservation
section and completion criteria were therefore corrected, in this code review, to
fix the four invocable commands and to tabulate every bare outcome and the reason
it cannot answer. This verdict is against that corrected contract, and all four
commands plus the mandatory Step 0 command were re-measured on the declared hosts
after the correction.

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

- **The harness**: `docs/v0.27.0/verify.closure-check.sh`, 919 lines, with the
  `--step N` interface over steps 0 to 7 and a no-`--step` full run that
  re-invokes itself once per step. One step, one process, so a capability
  resolved for one step cannot survive into another.
- **The three-outcome capability gate**: `readelf`, GNU `sha256sum` and
  `declare -A` are each recorded `supported`, `unsupported` or `unavailable`.
  `supported` requires an observed result, not a resolution: `readelf -d -V`
  over the running shell's own ELF, the empty-input SHA-256 equal to the known
  constant, and an associative assignment that reads its own value back.
- **The distinction between the two failing outcomes, driven rather than
  described**: a PATH built from the harness's own declared tools yields
  `unavailable` for `readelf` and `sha256sum`, and a stub planted first on that
  PATH yields `unsupported`. Both pairs are cases, in both directions.
- **The `UNANSWERED` exit-5 refusal**: a step whose declared tool is missing
  exits 5 and names the command that would answer it, measured by re-invoking
  the harness as a child under the stripped PATH. Its control is the same step
  on the real PATH, which must refuse for a different reason and must not name
  the missing tool.
- **The host-tool contract**: `docs/v0.27.0/contract.closure-tools.txt`, the
  thirteen commands the plan enumerates, in the five-column ENTRY shape
  `contract.host-tools.txt` uses, with LAUNCHER rows so every `runs-argument`
  `yes` owns a token.
- **The mechanical assertion, proved before it has a subject**: the extractor
  that will run over the nine shipped scripts is exercised on two planted
  files, one clean and one carrying a single undeclared command, and the run
  records `0 of 9` shipped scripts present.
- **The fixture corpus**: `docs/v0.27.0/fixtures.closure-corpus.txt`, 19 `spec`
  rows and two `donor` rows behind a `count` row, so a truncated corpus fails
  on the count rather than becoming a smaller run. Its control removes one row
  and asserts the resulting `19/18` mismatch.
- **Validation evidence**: `bash src/utils/lint_shell.sh` reports 44 tracked
  scripts clean; `shellcheck` over the new harness is clean;
  `git diff --exit-code HEAD -- src/setups/env/bin/install_pkg.sh` exits 0; a
  ripgrep of `readelf|sha256sum|tar -t` over `install_pkg.sh` prints nothing;
  `declare -A` is present in the harness at four sites, one of them the probe.
- **The two captures**: `verify.closure.step0.rhel.txt` (RHEL 9.8, readelf
  2.35.2, coreutils 8.32, bash 5.1.8) and `verify.closure.step0.debian.txt`
  (Debian 12 agent, readelf 2.40, coreutils 9.1, bash 5.2.15, build 140). Both
  report 66 cases, 0 failures, all three capabilities `supported`, and both full
  runs refuse steps 1 to 7.
- **The four preservation captures**, one per harness, each run on its own
  whatever the previous returned.
- **The plan correction round 1 required**: the Step 0 feature-preservation
  section and completion criteria of
  [plan.v0.27.0.toolchain-runtime-closure.md](plan.v0.27.0.toolchain-runtime-closure.md)
  now fix the four invocable preservation commands, tabulate each bare form's
  measured status and the reason it cannot answer, and name the two declared
  Linux hosts the mandatory Step 0 command is green on.
- **The round 2 re-measurement**: the four preservation commands and
  `bash docs/v0.27.0/verify.closure-check.sh --step 0` were run again after the
  correction, three preservation commands and the mandatory command on the
  RHEL 9.8 build host and `verify.wrapper-accept.sh --mode identity` on the
  authoring host, each independently. All five returned 0, the mandatory command
  reporting 66 cases and 0 failures with the three staged digests matching the
  working tree byte for byte. It is appended to
  [verify.closure.step0.rhel.txt](verify.closure.step0.rhel.txt) with the route
  a reviewer repeats.

### New types or classes introduced for Step 0

This step introduces no production type: it adds no production file and no line
to any existing one. What it introduces is instrument structure, and the pieces
a later step will extend are named here.

- `capability_probe`: the one place a capability is measured. It prints
  `<state>|<detail>` and nothing else, because the refusal cases call it inside
  a command substitution under a modified PATH and a subshell cannot report
  through a variable.
- `capability_record`, `capability_state`, `capability_detail`: parallel indexed
  arrays rather than an associative one, deliberately, so the harness still runs
  on a shell without associative arrays and can report that capability
  `unsupported` instead of dying on its own infrastructure.
- `step_tools`, `step_host`, `step_filled_by`, `step_suite_exists`: the plan's
  host matrix in the harness. Step 5's tool list is derived from the contract
  file rather than repeated, which is what keeps the matrix synchronized with
  the mechanically checked contract.
- `shipped_command_words`, `shipped_assignment_targets`,
  `shipped_function_names`, `shipped_undeclared_words`: the lexical extractor
  the contract assertion runs on, taking the reading rule item 2's harness
  already uses for the installer.
- `contract_bad_entry_rows`, `contract_bad_launcher_rows`,
  `contract_yes_without_launcher`: the contract oracles.
- `corpus_declared_count`, `corpus_spec_rows`, `corpus_bad_spec_rows`,
  `corpus_duplicate_ids`, `corpus_undeclared_donors`: the corpus oracles.
- `oneline`: folds a multi-line finding onto one line in the shell rather than
  through `tr`, so the stripped PATH the refusal cases build stays as small as
  the preflight declares.

### Architecture check for Step 0

- **Repository layer separation**: every file this step adds is under
  `docs/v0.27.0/`. No file under `src/` is created or modified, so no production
  boundary is crossed in either direction.
- **The two host-tool contracts stay apart**: `contract.closure-tools.txt` is
  the checker's, `contract.host-tools.txt` is the installer's, and the harness
  reads only the first. The negative grep over `install_pkg.sh` is what keeps a
  checker tool from leaking into the installer, and it prints nothing.
- **The instrument does not reach into the subject**: the harness sources no
  production file and calls no production function. Step 1 is where
  `build_elf_rpath` is called through the MAIN BOUNDARY seam, and nothing here
  anticipates it.
- **The harness's own dependency surface**: six external tools, declared in one
  array, resolved by one preflight. The refusal cases build their stripped PATH
  from that same array, so a seventh tool added carelessly would widen the
  environment those cases run in, and the array is the single place a reviewer
  looks to see it.
- **Instrument size**: 919 lines in one file. This is the step's one structural
  variance and it is recorded rather than smoothed over. The file is not
  deployed, so the 650-line ceiling of the plan's line-budget policy does not
  bind it, and the two sibling harnesses of this collection run to 2181 and 6662
  lines. The number still exceeds the plan's own advisory estimate of 250 to 400
  and the plan directs that a variance above an advisory estimate is recorded
  and the step continues.

No DDD-Hexagonal violation or adapter smell needs to be addressed for Step 0.

### Cost and structure check for Step 0

- **No new `O(n^2)` or `O(n log n)` path in production**: the step adds no
  production line at all, so the plan's complexity bound is untouched by
  construction.
- **The harness's own cost**: bounded by the number of steps and the size of two
  committed text files. The step 0 suite spawns 9 child processes, seven for the
  declared steps 1 to 7 and two for the refusal probes, each of which runs a
  preflight and a gate and exits. Measured on the Debian agent, the step 0 run
  and the full eight-step run together took 2.8 seconds of wall clock, between
  the probe's BEGIN and END markers in build 140.
- **Set operations are hash-based, not nested loops**: every finding is produced
  by `grep -Fxv -f`, which reads the known set once, rather than by scanning the
  known set inside a loop over the found set.
- **The rule the checker will have to keep is not yet in force**: one tree walk,
  one `readelf` per ELF, a provider index built before the object loop. Nothing
  here walks a tree or reads an object, and Step 3's completion criteria are
  where that bound is first asserted.

No, there is no performance issue that needs to be addressed for Step 0.

### Harness case check for Step 0

- **The capability gate**: 3 in-domain cases, 5 gate controls, and 1 case
  asserting the stripped PATH was actually planted before any control reads it.
  Both failing outcomes are asserted in both directions for `readelf` and
  `sha256sum`, and the `unavailable` outcome for `declare -A` is driven by
  removing `BASH_VERSION` rather than by a PATH, because a shell capability
  cannot be taken off a PATH.
- **The refusal path**: 5 cases. The exit code, the named command, the
  distinctness of the two refusals, and the second refusal naming its step. The
  distinctness pair is gated on `readelf` being supported and reports itself
  unanswered where it is not, because on a host with no `readelf` both children
  refuse alike and a pass there would say nothing. That is measured, not
  assumed: an earlier revision of this case FAILED on the authoring host for
  exactly that reason, which is how the gate came to exist.
- **The red baseline**: 28 cases, four per step for steps 1 to 7. Each step
  declares a non-empty tool set and a host, refuses with exit 5, and says why.
- **The contract**: 4 shape and consistency cases plus 2 controls, each planting
  exactly one defect and asserting the finding is that defect rather than that
  something was found.
- **The mechanical assertion**: 2 cases over planted subjects plus the topology
  count, with `0 of 9` shipped scripts recorded as a note.
- **The corpus**: 5 cases plus 2 controls, one of them the truncation control
  the plan asks for by name.
- **Preflight and host gate**: 7 preflight cases and 1 host case.

The plan's three test-first cases are all present and all answered: the
`unavailable`-not-`unsupported` case is `step0/gate/readelf-unavailable` with its
`step0/gate/readelf-unsupported` counterpart; the exit-5-naming-the-command case
is `step0/refusal/missing-tool-exit-code` with
`step0/refusal/names-the-missing-command`; and the corpus-count case is
`step0/corpus/count-matches-rows` with `step0/corpus/control/truncated-refused`.

No, there is no case below its declared coverage that needs completing for
Step 0. The plan's departure table replaces the pytest coverage number with a
case count, and 66 cases answered with 0 failures on each of the two hosts is
the whole of what this step declares.

### Feature integrity for Step 0

- **Existing feature behavior**: no production file is created or modified.
  `git diff --exit-code HEAD -- src/setups/env/bin/install_pkg.sh` exits 0, and
  the same is true of every other file under `src/`.
- **The four existing harnesses**: each was run on its own, never chained, at
  the invocation the plan's Step 0 feature-preservation section fixes, and each
  returned 0. `verify.install-pkg.sh --step 3`,
  `verify.relocation-rpath.sh --step 0 --target-capability` and
  `verify.wrapper-scope.sh --step 2` on the RHEL 9.8 build host,
  `verify.wrapper-accept.sh --mode identity` on the authoring host. Four zeros,
  so the plan's three-way aggregate returns its PASS row. Re-measured after the
  plan correction, with the same four statuses.
- **Why the plan's earlier bare list was corrected rather than satisfied**: all
  four argument-free forms were run first and returned 2, 1, 1 and 2.
  `verify.install-pkg.sh` step 0 refuses by design on an installer that can
  select a fallback engine and names step 1; `verify.relocation-rpath.sh` step 0
  is blocked without exact-target evidence; `verify.wrapper-scope.sh` step 0 is
  the pre-change wrapper baseline that item 3's own fix made unmatchable;
  `verify.wrapper-accept.sh` requires `--mode` and has no default for it. None
  of the four could be made zero without changing a frozen harness of items 1, 2
  and 3, so the bare list was unsatisfiable rather than strict, and code review
  round 1 named the plan change as the alternative to weakening a harness. The
  bare statuses and their reasons stay recorded in the RHEL capture and are now
  tabulated in the plan itself, so the correction is auditable rather than
  silent.
- **Why the fourth runs on a different host**: `verify.wrapper-accept.sh
  --mode identity` reads cplx history through `git`, by its own header. The
  build host carries no cplx checkout and no `git` on its login PATH, and the
  Debian agent holds no cplx credentials at all, which is the reason every cplx
  harness travels there as a verification-only copy. Its capture is retained
  beside the other three.
- **Reporting or diagnostics**: nothing existing is changed. The new reporting
  is the harness verdict, which prints the harness, contract and corpus digests
  so a retained capture carries the bytes that produced it and the bytes it
  measured, and which prints `unavailable` for those digests rather than a
  number when the `sha256sum` capability is not supported.
- **Compatibility or rollout note**: the CI side of this step lands in the
  pipeline repository as two commits, three verification-only copies and one
  `closureCheck()` probe. The probe reports and never gates, reads nothing under
  the extracted prefix and writes only under its own scratch directory, so it
  shares the `verifyCplx` parallel with the branches that copy that prefix.
  Build 140 succeeded with it.

No, no existing feature or reporting capability is impaired, and Step 0 has
established the feature-preservation result its plan requires: four independent
runs, four zeros, four retained captures, under the command contract the plan
now fixes.

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
