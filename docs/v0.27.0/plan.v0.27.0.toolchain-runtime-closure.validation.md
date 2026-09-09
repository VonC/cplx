# v0.27.0 toolchain-runtime-closure implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.toolchain-runtime-closure.md](plan.v0.27.0.toolchain-runtime-closure.md)
step by step. Steps 0 to 3 are implemented and checked: the harness, its
host-tool contract, its fixture corpus and the retained captures exist, the four
checker modules of the fixed topology exist with `closure_check.sh` answering the
scope question, the configuration bundle is committed with the one parser, the
digest, the agent's consistency check and the cplx-side resolution that make it
authoritative rather than merely self-describing, and the object reader now walks
the tree once, treats every shipped ELF as a subject and refuses every
`DT_NEEDED` name that resolves nowhere in the observed loader scope, reporting
separately the subjects no edge resolves to. There is still no floor check, no
coherence rule, no duplicate-provider or family rule, no declared entry-point
set and no packaging gate, so steps 4 to 7 are at their initial state and their
check sections hold their placeholder. The document verdict above stays No until every
step is checked.

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

Yes. Step 1 has been fully implemented.

`src/setups/env/bin/closure_check.sh` exists and is filled, and the other three
modules of the fixed topology exist with their contract comment and a body of
zero lines. The declared candidate shape is derived from the declared roots and
their declared immediate subdirectory lists without touching the filesystem, in
the loader's order and deduped preserving first occurrence; the observed loader
scope comes from `build_elf_rpath` itself through the installer's MAIN BOUNDARY
seam, and a property case compares the two byte for byte so a future copy of
that logic fails immediately. The three locally observable typed results are
emitted, an undeclared root and an undeclared subdirectory are each refused by
name, and a scope that could not be observed becomes a typed UNDETERMINED rather
than an empty one or an inherited exit code. Every Step 1 completion criterion is
green on the RHEL 9.8 build host: 70 cases and 0 failures for `--step 1`, 48
tracked scripts clean for the lint gate, an empty diff on `install_pkg.sh`, both
drift greps silent, and 104 cases with 0 failures for
`verify.relocation-rpath.sh --step 3`.

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

- **The checker**: `src/setups/env/bin/closure_check.sh`, 429 lines of which 240
  are body, carrying the entry point, the run order, the scope derivation, the
  classification and the report. It is the first production file of this effort.
- **The declared candidate shape, derived without touching the filesystem**:
  `closure_scope_declared` takes the parsed roots and their subdirectory lists
  and prints the ordered deduped candidate list. Nothing in it tests, globs or
  reads a path. The order is the loader's: each root's four `root/` candidates
  first, then that root's declared subdirectories, then the next declared root,
  with the dedupe preserving the first occurrence.
- **`root` as a declared subdirectory by construction**: it leads every root's
  subdirectory list whether or not the declaration names it, and its two
  contributions dedupe against the four `root/` candidates exactly as the
  installer's own loop does. A declaration that omits it and one that names it
  derive the identical shape, which is a case rather than a claim.
- **The observed loader scope, taken from `build_elf_rpath` and nowhere else**:
  `closure_scope_observed` sources `install_pkg.sh` through its MAIN BOUNDARY
  seam and calls the installer's own function. No suffix list and no tool-root
  glob of the installer is reproduced in the checker.
- **How the no-reimplementation criterion is met, stated because it is not
  obvious**: the plan requires that
  `rg -n 'tools/\*/|root/usr/lib64' src/setups/env/bin/closure_check.sh` print
  nothing, while Design Area 1 requires the DECLARED derivation to use those
  same four suffixes. Both hold: the two `usr/` candidates are composed from a
  `rootdir` path variable rather than spelled as one literal, and the file's
  header says so in words rather than leaving a reader to discover it. The grep
  passes and the property case below is what actually detects drift.
- **The subshell, which is why a refusal is typed rather than fatal**: the
  source and the call run inside a command substitution. `install_pkg.sh` can
  refuse while being sourced through a `fatal` that calls `exit`; in the
  checker's own shell that would end the run and return the installer's exit
  code as if it were a verdict. In the subshell it ends the probe, and the
  result is a typed `UNDETERMINED` carrying the reason.
- **The probe reports through a sentinel, not through a status**: a refusal
  during sourcing exits with the installer's own code, which can be any value,
  so an `RPATH|` prefix is the only signal read as success. Four distinct
  reasons are produced: an absent installer, a non-zero source, a missing
  `build_elf_rpath`, and a failing call.
- **The classification**: `closure_scope_classify` joins the two scopes through
  associative arrays and emits one typed line per entry with the side it was
  observed on: `PRESENT|declared|<path>`, `ABSENT|declared|<path>`,
  `UNEXPECTED|observed|<path>|root|<name>` and
  `UNEXPECTED|observed|<path>|subdirectory|<name>`. Two further shapes,
  `path` and `shape`, classify an observed entry `build_elf_rpath` cannot
  produce today, so no observed directory can fall out of every branch and go
  unmentioned.
- **`UNEXPECTED` is unwaivable by construction**: no waiver code path exists in
  the file, and the harness strips the comments before grepping for one, so the
  property is stated in the header in words and measured in code.
- **The exit codes**: 0 nothing undeclared, 1 at least one `UNEXPECTED`, 2 the
  arguments are unusable, 5 the scope could not be observed. A refusal outranks
  an unobtainable input, and neither is reachable from the other.
- **The verdict says it is partial on every run, green ones included**: this
  checker answers the scope question and makes no claim about the four archive
  invariants, so a green scope check cannot read as a green archive.
- **The three remaining modules**: `closure_config.sh`, `closure_elf.sh` and
  `closure_rules.sh` are created here with their contract comment and a body of
  ZERO lines. Each names the functions it will own, the step that fills it, and
  the reason the responsibility is its own. `closure_rules.sh` records that it
  owns all four invariants including the derived membership half, and that
  `UNEXPECTED` is unwaivable so no waiver path there may reach one.
- **The harness suite**: `docs/v0.27.0/verify.closure-check.sh` gains
  `step1_suite`, 70 cases, and grows from 919 to 1351 lines.
- **The step 0 red baseline had to change, and the change is part of this
  step**: its loop asserted that every later step refuses with exit 5, which
  becomes false the moment any step is filled. It now asserts the refusal for
  the steps that are still unfilled and records a filled step as filled, without
  re-running it: `--step N` is the command that judges step N, and running it
  from inside step 0 would report the same result under a name that hides which
  step produced it.
- **A derived rule for functions obtained by sourcing**: `build_elf_rpath` sits
  in command position in the checker while being supplied by `install_pkg.sh`
  rather than by the host, so it belongs in neither host-tool contract. The
  harness's mechanical assertion gained `shipped_sourced_functions`, DERIVED
  from the installer's own text rather than listed, and SCOPED to files that
  name the installer. Two controls hold it shut: a planted script that sources
  the installer and calls an undefined function is still a finding, and one that
  never names the installer gets no exemption at all.
- **`contract.closure-tools.txt` is deliberately unchanged**: the checker
  introduces no host command, which the mechanical assertion confirms over all
  four modules, so the enumerated thirteen still cover the shipped set. Leaving
  it untouched also keeps the contract and corpus digests the Step 0 capture
  records valid, and the Step 1 capture reproduces both to show it.
- **Report readability, because a capture is evidence a person reads**: `chk_list`
  reports a list comparison as a size on a pass and in full on a failure, and
  the verdict now probes `sha256sum` for every step rather than reading a
  recorded state, so a capture from a step that declares no digest tool can
  still name its own bytes. The probe is not part of any step's declared tool
  set, so no step can refuse over it.
- **The capture**: `docs/v0.27.0/verify.closure.step1.rhel.txt`, 424 lines,
  carrying the step 1 run, the step 0 re-run, the aggregate, the preserved
  surface, the authoring-host half and the line budget.
- **Validation evidence**: `bash docs/v0.27.0/verify.closure-check.sh --step 1`
  reports 70 cases and 0 failures on the RHEL 9.8 build host;
  `--step 0` still reports 0 failures; the argument-free form aggregates to 5
  with steps 2 to 7 refusing as designed; `bash src/utils/lint_shell.sh` reports
  48 tracked scripts clean; `verify.relocation-rpath.sh --step 3` reports 104
  cases and 0 failures; `git diff --exit-code HEAD -- install_pkg.sh` exits 0;
  the installer-purity grep prints nothing. The sha256 of all five measured
  files matches the working tree byte for byte on both machines.

### New types or classes introduced for Step 1

The production side introduces one script and six functions, plus the seam and
the two globals that carry a result a shell function cannot return.

- `closure_scope_declared`: the ONE derivation of the declared candidate shape.
  Its inputs are the prefix and one `NAME=SUB,SUB` argument per root; its output
  is one absolute path per line. It is the definition Design Area 1's "one
  derivation, two callers" requires, and Step 6's verification half will call
  this same function twice rather than write a second one.
- `closure_scope_observed`: the sourcing probe. Sets `CLOSURE_OBSERVED_RPATH` on
  success and `CLOSURE_OBSERVED_REASON` on failure, returning non-zero for the
  second, which is what lets the caller produce a typed result instead of an
  inherited exit.
- `closure_scope_observed_lines`: splits the colon-joined loader value in the
  shell, because `tr` is not on this effort's host-tool contract.
- `closure_scope_classify`: the join, and the only producer of the three typed
  results. Both directions are hash lookups.
- `closure_scope_undetermined`: the typed result for a scope that could not be
  observed. Every declared candidate becomes one `UNDETERMINED` line, because
  its presence is exactly what could not be determined.
- `closure_scope_line_count`, `closure_check_usage`, `closure_check_main`: the
  counting helper, the usage text and the entry point.
- **The MAIN BOUNDARY seam**, taken from `install_pkg.sh` for the same reason it
  exists there: sourcing the checker defines its functions and runs nothing, so
  the harness calls `closure_scope_declared` itself rather than a copy, which is
  what makes the no-filesystem property provable rather than assertable.

The harness side introduces the instrument the later steps reuse.

- `run_checker`, `typed_lines`, `typed_count`: the checker is run as a CHILD
  PROCESS and its typed lines are read by their type column, so an exit code the
  checker did not produce cannot be mistaken for one it did.
- `declared_shape`, `observed_scope`, `build_elf_rpath_value`: the three
  sourcing probes, each in a child with its own codes for "the seam did not
  hold", so a syntax error in production code fails a case instead of killing
  the harness.
- `module_body_lines`: measures "created empty" as a number.
- `shipped_sourced_functions`: the derived, scoped exemption described above.
- `chk_list`, `list_size`: a list comparison whose pass line prints a size.
- `step1_write_fatal_stub`: writes the installer stub that refuses at source
  time, through a single-quoted variable rather than a heredoc so the
  dollar-brace operands reach the file unexpanded and no `cat` is needed.

### Architecture check for Step 1

- **The module topology is respected and is now a fact of the tree**: four
  modules exist, `closure_scope.sh` exists in no shape, and the harness asserts
  both. Scope derivation and classification live in `closure_check.sh`, which
  the topology table assigns them to and which is where the run order that
  consumes them lives.
- **No responsibility landed early**: the three modules the later steps fill
  have a body of zero lines, measured rather than assumed, so a parser, an
  object reader or an invariant written here would be visible immediately.
- **The dependency direction is one-way and narrow**: the checker reads
  `install_pkg.sh` and never writes it, depends on it for exactly one function,
  and reaches it only through the seam the installer already published for the
  relocation harness. `git diff --exit-code HEAD -- src/setups/env/bin/install_pkg.sh`
  exits 0.
- **The two host-tool contracts stay apart**: the installer-purity grep for
  `readelf|sha256sum|tar -t` over `install_pkg.sh` prints nothing, and the
  checker introduces no host command of its own, so neither contract moved.
- **The instrument does not become the subject**: the harness sources production
  code only in children, and every behavioural case runs the checker as a
  separate process. The checker never sources the harness in any direction.
- **The one new coupling is declared rather than incidental**: the harness's
  mechanical assertion now knows that a shipped script may obtain a function by
  sourcing another production script. It is derived from the sourced file and
  scoped to files that name it, with two controls, so it cannot widen into a
  general exemption.
- **Payload against authoritative is not yet exercised**: nothing is staged into
  an archive in this step, and no checker copy is executed to produce evidence.
  Step 5 is where that boundary first has two sides.

No DDD-Hexagonal violation or adapter smell needs to be addressed for Step 1.

### Cost and structure check for Step 1

- **No `O(n^2)` and no `O(n log n)` path**: the declared derivation is
  `O(roots x subdirectories)`, 14 entries on the declared shape this step
  measures. The dedupe and the join are associative-array lookups, so neither
  scans one list inside a loop over the other, and the checker sorts nothing.
- **The observed scope costs exactly what `build_elf_rpath` already costs**,
  because it is that function. The checker adds one subshell and one process
  substitution of its own, both constant.
- **No second walk reaches the production install path**: this step adds no line
  to `install_pkg.sh`, and the checker never runs during an install.
- **The rule Step 3 must keep is still ahead**: one tree walk, one `readelf` per
  ELF, a provider index built before the object loop. Nothing here walks a tree
  or reads an object.
- **Line budget, with every variance recorded**:

| File | Before | After | Plan advisory | Band |
| --- | --- | --- | --- | --- |
| `closure_check.sh` | 0 | 429 | 180 to 240 | below 550, safe; ceiling 650 |
| `closure_config.sh` | 0 | 35 | under 20 | below 550, safe |
| `closure_elf.sh` | 0 | 26 | under 20 | below 550, safe |
| `closure_rules.sh` | 0 | 37 | under 20 | below 550, safe |
| `verify.closure-check.sh` | 919 | 1351 | plus 200 to 300 | harness, not deployed |
| `install_pkg.sh` | 1308 | 1308 | no growth | unchanged |

  Every advisory estimate is exceeded and no BAND is: the deployment ceiling is
  650 and the largest shipped file is 429. One number explains it.
  `closure_check.sh` is 240 lines of body and 189 of comment, so its CODE lands
  exactly at the advisory upper bound and the total carries this repository's
  comment density on top. The same explains the three contract-comment modules,
  whose bodies are zero and whose comments enumerate what each will own. The
  plan's own rule for a variance above an advisory estimate is to record it and
  continue, which is what this table does.

No, there is no performance issue that needs to be addressed for Step 1.

### Harness case check for Step 1

The plan's five test-first cases and its one property case are all present and
all answered, in 70 cases with 0 failures.

- **The topology**: 4 existence cases, 1 asserting `closure_scope.sh` is absent,
  3 body-is-zero cases, 1 is-filled case, 4 mechanical-assertion cases over the
  real modules, and 2 controls for the sourced-function exemption.
- **A declared candidate absent under both roots**: `step1/absent/exit-code` and
  `step1/absent/named`, accepted and reported, exit 0.
- **An undeclared immediate subdirectory of a declared root**:
  `step1/unexpected-subdir/named` asserts the whole typed line including the
  offending name, with exit 1, and its CONTROL declares that same subdirectory
  and requires acceptance, so the refusal is shown to be about the declaration
  and not about the path.
- **The measured `tools/old/py3.13` root**: `step1/unexpected-root/named` with
  its own control of the same shape.
- **A floor member present only under an undeclared root**: the root is refused
  AND `step1/unexpected-root/member-still-in-scope` shows the directory holding
  it is still in the observed loader scope, so the two results sit side by side
  and the refusal is visibly the only thing stopping that resolution counting.
- **The alias and the version both declared and both present**:
  `step1/canonical/alias-present` and `step1/canonical/version-present`, with
  `current` planted as a real SYMLINK to `python-3.13.9`. This is the case a
  version-shaped declaration would have failed.
- **The property case**: `step1/observed/equals-build-elf-rpath` compares the
  checker's observed scope against `build_elf_rpath`'s own output byte for byte,
  and `step1/observed/canonical-order-matches-declared` shows the two scopes
  agree in ORDER as well as in content on a correct tree, which is the statement
  that the derivation follows the loader's order rather than merely producing
  the same set. Beside them the two drift greps run as cases.
- **The no-filesystem property, with its control**: derived against a prefix
  carrying the tree and against one that does not exist, identical with the
  prefix folded out, while the control shows the observed side DOES depend on
  the filesystem so the two prefixes are not interchangeable.
- **`UNDETERMINED`**: 4 driving cases, one per reason, each asserting the exit
  code is the checker's own 5 rather than the installer's 3; 2 cases asserting
  ZERO `ABSENT` and ZERO `PRESENT` lines, which is what a checker reading an
  unobtainable scope as an empty one would have produced; 1 asserting all
  fifteen candidates are `UNDETERMINED`; 1 asserting the report reaches its
  verdict line; and 1 CONTROL showing the real installer produces none.
- **The arguments**: 3 cases, so a usage error returns 2 and never a verdict.

**One finding carried forward, recorded so it is not lost.** The Step 0 fixture
corpus row `scope-unexpected-subdir` places its fixture at
`tools/python/current/cplxunexpected`, which is one level too deep to appear in
the observed scope: `build_elf_rpath` iterates the immediate subdirectories of a
tool ROOT, so an unexpected subdirectory has to sit at `tools/python/<name>`
with a `lib` or `lib64` beneath it. Step 1 plants that shape in the harness
directly, which is what the plan's own "Step 1 test first" section asks for, and
the corpus is left untouched: its header assigns extension to steps 3 and 4, and
editing it now would invalidate the corpus digest the Step 0 capture records as
evidence. The row should be corrected by the step that first consumes it.

No, there is no Step 1 case below its declared coverage that needs completing.
The plan's departure table replaces the pytest coverage number with a case
count, and 70 cases answered with 0 failures is the whole of what this step
declares.

### Feature integrity for Step 1

- **`install_pkg.sh` is read and never written**:
  `git diff --exit-code HEAD -- src/setups/env/bin/install_pkg.sh` exits 0, and
  it is HEAD-relative and exit-status driven so a staged edit could not read as
  proof that nothing changed.
- **The suite that would notice an installer edit first is green**:
  `bash docs/v0.27.0/verify.relocation-rpath.sh --step 3` reports 104 cases and
  0 failures on the RHEL 9.8 build host. It is the suite that asserts the
  installer's own host-tool allowlist over the installer text.
- **Two earlier runs of that command failed and neither was a regression**, and
  both are recorded in the capture rather than quietly retried. The first
  lacked `contract.cplx-elf-1.txt` in the `/tmp` subset, a missing input. The
  second reported `git hash-object` unavailable because `git` is absent from
  that host's login PATH while present in its own tools tree, which is the exact
  shape this repository already recorded once when a tool was called missing
  across six review rounds while the binary was there. It was verified rather
  than believed, and the third run, with `git` on PATH and
  `--target-capability` supplied, is green.
- **Step 0 still answers**: `--step 0` reports 0 failures after the harness
  change, and its red baseline now refuses for steps 2 to 7 and records step 1
  as filled. The contract and corpus digests it prints are unchanged from the
  Step 0 capture, so a reader can see step 1 added no command and no fixture row.
- **The lint floor covers the new files**: `bash src/utils/lint_shell.sh` reports
  48 tracked scripts clean. The four modules were STAGED before that run, and
  that is not a formality: the gate reads `git ls-files`, so its first run
  reported 44 scripts and `clean` while covering none of them. Staged, it
  reported 48 and one real finding, SC2034 over the `INSTALL_PREFIX` assignment
  inside the probe subshell, which shellcheck cannot see through the `source` on
  the line above. It now carries a scoped disable naming the reader.
- **Reporting**: nothing existing is changed. The new reporting is the checker's
  typed lines and its partial verdict. On the harness side two reporting
  improvements land: a list comparison prints a size on a pass rather than
  fourteen absolute paths, and the verdict digests are probed for every step so
  a capture can always name its own bytes.
- **Nothing is deployed yet**: no staging into an archive, no change to `pkg.sh`
  at 184 lines, and no packaging gate. The checker exists and is called by the
  harness only, so a half-built gate cannot refuse a real packaging run.

No, no existing feature or reporting capability is impaired by Step 1.

---

## Step 2. The configuration bundle and its authority

### Analysis of Step 2 implementation state

Yes. Step 2 has been fully implemented.

`src/setups/env/closure/closure-config.txt` carries the four declarations as one
document, `README.md` beside it states the digest domain where the data lives,
and `closure_config.sh` is filled with the one parser, the digest, the envelope
check and the cplx-side resolution. The digest is the SHA-256 of the document's
exact committed bytes and covers the envelope nowhere, which two driven cases
show rather than assert: the same declaration with CRLF endings produces a
different value, and byte-identical bytes read through another path produce the
same one. The three parties are asymmetric and every side that exists yet is
asserted: the agent ACCEPTS a paired edit and an authentic-but-wrong bundle
because internal consistency is the whole of what a host without cplx can read,
and packaging REFUSES both because it resolves the authoritative document from
cplx at the commit the envelope names. The agent's verdict states that limit on
every line it prints, and the checker reads the bundle before anything else runs,
which the absence of every typed scope line proves rather than the exit code
alone. Every Step 2 completion criterion is green on the RHEL 9.8 build host: 85
cases and 0 failures for `--step 2`, 48 tracked scripts clean for the lint gate,
the digest and the consistency statement both found in `closure_check.sh`, the
installer-purity grep silent and an empty diff on `install_pkg.sh`.

FIVE OF THE EXPECTATIONS BELOW ARE STEP 6'S AND ARE NOT ANSWERED HERE, and that
is a skeleton defect rather than a gap in this step. The bullets naming evidence
negatives, the derived verdict truth table, the evidence semantic negatives and
the canonical evidence bytes all describe `CPLX-CLOSURE-EVIDENCE/1`, which Q10
routes to "Step 6 emit and `closure_evidence_parse`" and which this plan's Step 6
section already carries. They were written into this step's expectation list from
the whole Q10 answer rather than from the half Step 2 schedules. Step 2's own
behavior list is the four configuration and envelope functions, all four exist,
and the evidence document is named in `closure_config.sh` as the third table a
later step adds rather than silently omitted.

### Independent reviewer validation for Step 2 (round 1)

The received index was `5341871357e54b28529ea3170dcfe55a7c79f461`.
The reviewer reproduced two Step 2 defects and repaired both within the existing
module boundary: a trailing empty field was discarded by Bash `read -a`, and a
subdirectory before its root was accepted but omitted from the parsed model.
Duplicate subdirectories before their root were also accepted. The shared lexer
now refuses a trailing separator before splitting. Subdirectory insertion and
duplicate detection now run during the existing cross-reference pass, after all
roots are known. No declaration, envelope authority rule, or other step changed.

Six regression assertions cover configuration and envelope trailing fields,
forward-subdirectory acceptance and retention, and duplicate forward references.
Independent RHEL 9.8 runs over matching inputs pass before repairs (85 cases)
and after repairs (91 cases), with zero failures. Steps 1 and 0 remain at 70 and
66 cases; relocation Step 3 remains at 104. All 13 measured remote input hashes
match their corresponding local baseline or repaired files. The project lint
passes for 48 scripts and the harness ShellCheck passes. The Windows Step 2 run
has zero failures and exits 5 for unavailable host identity; it is not counted
as Linux evidence. The validation resolver reports no drift.

The reviewer retains both full independent runs in ignored review evidence, and
recorded here that the retained `verify.closure.step2.rhel.txt` was still the
original 85-case capture at the time it wrote this. The requestor has since
accepted both repairs, re-run the walk on the accepted bytes and replaced that
capture with the 91-case run, whose `round 1 repairs` section records both
defects, the superseded measurements beside the accepted ones, and which two of
the six digests moved. These substantive reviewer repairs require another round
and do not authorize a commit. The implementation verdict above describes the
repaired code. No umbrella row was changed.

### Independent reviewer validation for Step 2 (round 2)

Yes. Step 2 has been fully implemented.

Both round 1 parser repairs and their six assertions are accepted unchanged.
The final versioned capture names the repaired bytes and the 91-case run.
Independent round 2 RHEL checks pass: Step 2 has 91 cases, Step 1 has 70,
Step 0 has 66, and relocation Step 3 has 104, all with zero failures. All 13
remote input hashes match the reviewed files. The 48-script lint gate and
harness ShellCheck pass; the current validation resolver reports no drift.

The requestor repaired the reviewer's earlier encoding error. The content before
Step 2 and from Step 3 onward now matches the original submission byte for byte.
This round changes review metadata only, using explicit UTF-8 encoding; the same
outside-step bytes are checked before and after this update. The umbrella is
unchanged, the seven-path six-group commit plan is valid, and no substantive
repair or unresolved current finding remains. Commit readiness is advisory and
the commit decision remains with the human.

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

- **The configuration document**: `src/setups/env/closure/closure-config.txt`,
  25 lines, carrying all four declarations in one file because a check that read
  three of the four would evaluate a contract nobody wrote. Two `root` records in
  the loader's order, four `subdir` records, the issue's ten `floor` entries with
  `libsqlite3.so.0` constrained to `tools/python`, the two declared families at
  one generation each, and the one initial waiver. It is a SUBJECT of the harness
  and not a fixture: the committed bytes are parsed by the same parser the
  archive will use, so a document that stopped parsing fails here rather than in
  Step 5.
- **The digest domain, stated beside the data it governs**:
  `src/setups/env/closure/README.md` records that the digest is the SHA-256 of
  `closure-config.txt`'s exact committed bytes, that the envelope is outside it
  and cannot be committed here because it names the commit that holds the
  document, and what each of the three parties checks and refuses on. A second
  implementation reading only the code would have to infer the domain; this
  states it where the data lives.
- **The one parser**: `closure_config_parse` in `closure_config.sh`, implementing
  the grammar Q10 fixes. Record shape, ordering significant for `root` and
  nothing else with `python` first, duplicate keys, the two escapes with every
  other percent sequence a refusal, the permitted relative-path form, unknown
  records and the three cross-references. All of it fails closed.
- **One lexer, a record table per document**: `closure_stream_read` reads the
  shared lexical shape once and `closure_cfg_record` and `closure_env_record` are
  the two tables over it. The table is selected by a value rather than by naming
  a function to call, because an assembled command name is exactly the shape the
  host-tool contract calls its own known lexical limit.
- **The digest**: `closure_config_digest`, SHA-256 over the bytes on disk and
  never over parsed content, printed bare so the value is the digest rather than
  the tool's two-column line.
- **The identity envelope**: `CPLX-CLOSURE-ENVELOPE/1`, parsed by
  `closure_envelope_parse` with exactly one `digest` and one `source`, a
  64-character lowercase digest domain and a 40-character commit domain, so a
  short SHA, a branch and a tag all refuse at parse time.
- **The agent's check**: `closure_envelope_check`, which prints
  `CONSISTENT|<digest>|<limit>` or `INCONSISTENT|<limit>` and carries
  `CLOSURE_CONSISTENCY_LIMIT` on both, so a green agent run cannot be read as
  authority it does not have.
- **The cplx-side resolution**: `closure_config_resolve_commit`, refusing a
  reference that is not a 40-character commit SHA and refusing a 40-hexadecimal
  value that names a blob, a tree or a tag rather than a commit. The second half
  is the one a lexical check alone cannot answer.
- **The packaging and publication check**: `closure_config_authority_check`,
  which runs the agent's check first so an internally inconsistent bundle refuses
  for that reason, then requires the embedded document to be byte-identical to
  what cplx holds at the named commit. This is where the paired edit is refused.
- **The checker reads the bundle**: `closure_check.sh` gains `--bundle DIR`, the
  `closure_check_bundle` gate that runs before any classification, a report block
  stating the agent's limit in words, and the derivation of its declared roots
  from the parsed document when no `--root` is given. An explicit `--root` still
  wins, and the report names which of the two the roots came from.
- **The harness**: `verify.closure-check.sh` gains the step 2 suite, 85 cases,
  and two step-aware repairs described in the architecture check below.

### New types or classes introduced for Step 2

The reviewer adds `closure_cfg_add_subdir`, called only by the cross-reference
pass so forward declarations retain their subdirectories and duplicate checks.

The production side introduces one document, one README and fifteen functions in
the module the topology already reserved for them.

- `closure_lex_decode`: the escape decoder. It reports through globals rather
  than stdout because a command substitution would run it in a subshell and lose
  the offending sequence with it, which is what makes the refusal name `%2F`
  instead of saying only that something failed.
- `closure_lex_record`: splits and decodes one record, owning the two refusals
  that belong to the shared lexical shape rather than to any table, the empty
  field and the undefined escape.
- `closure_lex_domain`: the ONE place a lexical domain is decided, with ten
  kinds. Every placeholder of all three grammars resolves to one of them, so
  Step 6's evidence table adds records and not domains.
- `closure_stream_read`: the one record-stream reader, shared by both documents.
- `closure_cfg_record`, `closure_env_record`: the two record tables.
- `closure_cfg_root`, `closure_cfg_subdir`, `closure_cfg_floor`,
  `closure_cfg_family`, `closure_cfg_waiver`: one per configuration record.
- `closure_cfg_cross_refs`: the three cross-references, validated once the whole
  document is read so a record may name a root declared further down.
- `closure_cfg_refuse`, `closure_cfg_count`, `closure_cfg_domain`: the refusal
  shape, `REFUSED|<line>|<code>|<detail>`, with line 0 for a refusal about the
  document rather than about one of its records.
- `closure_config_reset`: empties the parsed model by unsetting keys rather than
  redeclaring the arrays, because a redeclaration inside a function would make
  them local to it and leave every caller reading the stale one.
- `closure_config_parse`, `closure_config_digest`, `closure_envelope_parse`,
  `closure_envelope_check`, `closure_config_resolve_commit`,
  `closure_config_authority_check`: the four the plan names, plus the envelope
  parser they share and the authority check that composes them.
- `closure_config_root_specs`: the parsed roots in the `NAME=SUB,SUB` shape
  `closure_check.sh --root` already takes. It is what makes the committed
  declaration the source of the declared candidate shape rather than a document
  nothing reads.
- `closure_check_bundle` in `closure_check.sh`: the gate, and the only new
  function there. The checker gains the call and the report and no logic.

The harness side introduces four probes and one fixture builder.

- `config_call`, `config_model`, `config_root_specs`, `config_digest`: each
  reaches the module through its own file in a CHILD PROCESS, so a syntax error
  fails a case instead of killing the harness and the parsed model one case
  leaves behind cannot reach the next.
- `step2_write_valid_config`, `step2_mutate`, `step2_write_envelope`,
  `step2_refuse`: the valid base document, the one-record mutation, the envelope
  writer, and the case that plants a defect, asserts it is planted, derives its
  line number from the fixture and asserts the exact refusal.
- `step2_build_repo`: the fixture repository the cplx-side resolution reads. It
  is built rather than pointed at cplx itself, because the case needs a commit
  holding a KNOWN document at a known path, and reading this repository's own
  history would make the case depend on what happened to be committed when it
  ran.

### Architecture check for Step 2

- **The module boundary is exactly the topology's**: the grammar parser, the
  digest, the envelope check and the cplx-side resolution live in
  `closure_config.sh` and nowhere else, which is what lets `closure_publish.sh`
  reuse them in Step 5 without pulling in the invariants. `closure_check.sh`
  gains one call, one gate function and its report.
- **No responsibility landed early**: `closure_elf.sh` and `closure_rules.sh`
  still have a body of zero lines and still digest to the values the Step 1
  capture recorded, so an object reader or an invariant written here would be
  visible immediately. No `closure_scope.sh` exists in any shape.
- **The dependency direction stays one-way**: `closure_config.sh` calls nothing
  from `closure_check.sh` and knows nothing about scope; the checker sources the
  module and not the reverse. The module is sourced at FILE SCOPE and not inside
  a function, because `declare -A` inside a function makes the arrays local to it
  and a lazy source would have left every later caller reading an empty model.
- **The two host-tool contracts stay apart**: the installer-purity grep for
  `readelf|sha256sum|tar -t` over `install_pkg.sh` prints nothing, and every
  command the new module runs, `sha256sum`, `git`, `mktemp` and `rm`, already
  carries an entry in `contract.closure-tools.txt`. The contract needed no edit,
  which the harness proves mechanically rather than by inspection.
- **The parser is pure Bash by contract and not by taste**: no `grep`, no `sed`,
  no `tr`, no `wc`. Every word-initial `case` pattern is quoted, because unquoted
  it sits in command position for the harness's lexical reader and would be
  reported as an undeclared host dependency. That reader found one real instance
  during this step, a bare `a` after a vertical bar inside an error string, and
  the fix split the code and the detail into two globals rather than suppressing
  the finding.
- **Two step-aware harness repairs, both narrowing rather than widening**. The
  sourced-function exemption now derives its names from any shipped script the
  file NAMES IN CODE rather than from `install_pkg.sh` alone, since a checker
  module may now be sourced by another; comments are stripped first, so a header
  sentence naming a caller no longer earns the exemption, which the previous rule
  would have granted. The module body assertion reads which side each module is
  on from the topology's own `Filled by` column instead of a hand-kept list, so a
  later step filling its file cannot read as a Step 1 regression.
- **One harness case was repaired rather than left red**: the alias fixture
  reported a code FAILURE on a host where `ln` resolves and cannot make a
  symlink, which is the "resolved is not the same as able" distinction the
  capability gate makes for every other tool. It is measured now and reports
  UNANSWERED there, which is not a pass either. The RHEL result is unchanged.
- **Payload against authoritative is still not exercised**: nothing is staged
  into an archive in this step and no checker copy is executed to produce
  evidence. Step 5 is where that boundary first has two sides.

No DDD-Hexagonal violation or adapter smell needs to be addressed for Step 2.

### Cost and structure check for Step 2

- **No `O(n^2)` and no `O(n log n)` path**: the parser is one pass over a
  25-line document, the root, floor, family and waiver duplicate tests are
  associative-array lookups, and nothing sorts. The cross-references are
  collected during the pass and resolved in one pass over that list, so no record
  is re-read. Round 1's repair moves the subdirectory append from the record
  handler into that same cross-reference pass, which reorders the work rather
  than adding any.
- **One claim the round 1 answer corrected, recorded rather than argued away**:
  the subdirectory membership test and append are a pattern match and a
  concatenation on a comma-fenced string, so they are LINEAR in the length of one
  root's declared list and not constant-time as this section first said. The
  honest bound is linear in a list a human writes, four entries on the committed
  declaration; the cost the plan's complexity clarification actually governs is
  the per-object walk and the provider index, neither of which this module
  performs. No observed performance change follows, and the correction is here
  because a bound stated wrongly is worth more as a correction than as a
  footnote.
- **One file read and one digest per run**, as the plan's complexity impact
  states. The commit resolution is one `git cat-file -t` and one
  `git cat-file blob` at packaging time and none on the agent, which has no cplx
  access by construction.
- **The one temporary file is bounded and cleaned on every path**: the resolved
  document is written through `mktemp` and removed on success and on both
  refusal branches, so a refusal leaves nothing behind.
- **No second walk reaches the production install path**: this step adds no line
  to `install_pkg.sh` and touches `pkg.sh` not at all.
- **The rule Step 3 must keep is still ahead**: one tree walk, one `readelf` per
  ELF, a provider index built before the object loop. Nothing here walks a tree
  or reads an object.
- **Line budget, with every variance recorded**:

| File | Before | After | Plan advisory | Band |
| --- | --- | --- | --- | --- |
| `closure_config.sh` | 35 | 637 | 140 to 190 | 550 to 650, AT RISK; ceiling 650 |
| `closure_check.sh` | 429 | 523 | plus under 10 | below 550, safe |
| `closure_elf.sh` | 26 | 26 | untouched | below 550, safe |
| `closure_rules.sh` | 37 | 37 | untouched | below 550, safe |
| `verify.closure-check.sh` | 1351 | 1922 | not stated | harness, not deployed |
| `closure-config.txt` | 0 | 25 | data, no budget | data |
| `README.md` | 0 | 86 | data, no budget | data |
| `install_pkg.sh` | 1308 | 1308 | no growth | unchanged |
| `pkg.sh` | 184 | 184 | no change this step | unchanged |

  `closure_config.sh` is the one file in the AT RISK band and the one real
  variance. At submission it had 623 lines, 195 comment and blank; the reviewer fixes
  bring it to 637 lines, still below the ceiling. The 140-to-190 estimate
  was written when Q10 was still a property rather than a specification: what
  landed is one lexer, two record tables, ten exact lexical domains, an escape
  decoder, a five-array parsed model with its reset, the digest, the envelope
  check, the cplx-side resolution and the authority check that composes them. The
  band's rule is to avoid growth where practical, and two reductions were made
  for that reason and not for the count: the two near-identical parse loops
  became one shared record-stream reader, which is also the "one lexer, three
  record tables" shape the design asks for, and the subdirectory duplicate map
  was removed in favour of the comma-fenced list that was already the one record
  of what a root declares.

- **`closure_check.sh` exceeds its advisory by 84 lines, and the completion
  criteria are why.** Sourcing the module is the one line the estimate covered;
  the rest is the `--bundle` entrance, the gate that reads the bundle before
  anything else runs, and the report block. Two criteria require that block by
  name: `rg -n 'sha256sum'` must show the digest and `rg -n 'consistency'` must
  find the agent's own statement of its limit, and neither is satisfiable by a
  file that only sources a module.
- **A forward note for Step 6, recorded because this step is where the ceiling
  became visible.** `CPLX-CLOSURE-EVIDENCE/1` is a record TABLE and not a parser,
  so it costs less than this step's two did, but adding it to `closure_config.sh`
  would take that file over 650 and the topology forbids a fifth module. The
  table belongs with the two scripts that read evidence, `closure_verify.sh` and
  `closure_publish.sh`, which are separate rows in the delivered script topology
  rather than checker modules. Step 6 should place it there rather than
  discovering the ceiling at the end of its own implementation.

No, there is no performance issue that needs to be addressed for Step 2.

### Harness case check for Step 2

The plan's six test-first cases and its two digest-domain cases are all present
and all answered, in 91 cases with 0 failures on the RHEL 9.8 build host
after the round 1 reviewer repairs (85 cases before them).

- **The embedded document does not hash to the digest its envelope names**:
  `step2/agent/corrupted-document-refused` with exit 1,
  `step2/agent/refusal-names-both-digests` asserting both values travel in the
  refusal, and `step2/agent/refusal-still-states-the-limit`. Its control is
  `step2/agent/consistent-bundle-accepted` on the same bundle unmutated.
- **The bundle carries no configuration at all**:
  `step2/agent/no-configuration-at-all` and `step2/agent/absence-names-the-path`,
  with the envelope half beside it, so absence is refused by name rather than
  read as an empty declaration.
- **The envelope names a branch or a tag rather than a commit SHA**:
  `step2/envelope/branch-instead-of-a-commit` at parse time and
  `step2/authority/branch-refused-before-resolution` end to end, with
  `step2/authority/branch-refusal-is-lexical` showing the refusal is the domain's
  and is reached before any resolution runs, which is what "packaging refuses to
  produce it" means.
- **THE PAIRED EDIT, ASSERTED FROM ALL THREE SIDES.** A floor entry deleted and
  the document re-hashed to match its own envelope:
  `step2/authority/paired-edit/agent-ACCEPTS` exit 0,
  `step2/authority/paired-edit/packaging-REFUSES` exit 1,
  `step2/authority/paired-edit/refusal-names-both` asserting the refusal carries
  the embedded digest and the one cplx holds, and
  `step2/authority/paired-edit/publication-REFUSES` recorded as a NOTE naming
  Step 5 as the step that asserts it. The plan asks for all three sides and names
  publication's half as pending, which is exactly how it is recorded.
- **The bundle replaced with a different, internally consistent, authentic
  bundle**: `step2/authority/authentic-swap/agent-ACCEPTS` and
  `step2/authority/authentic-swap/packaging-REFUSES`, with publication's half
  recorded by name as pending.
- **The named cplx commit does not hold that configuration at that path**:
  `step2/authority/path-absent-at-that-commit` and its naming case. Beside it a
  case the plan does not list and the design implies:
  `step2/authority/40-hex-that-is-a-blob`, a value that satisfies the lexical
  domain and names a blob, refused on the OBJECT TYPE, which is the half a
  lexical check alone cannot answer.
- **The two digest-domain cases**: `step2/digest/crlf-is-a-different-digest` and
  `step2/digest/same-bytes-other-path`, with `step2/digest/control/crlf-still-digests`
  so the difference is about bytes and not about one of the two files being
  empty.
- **Decoding precedes domain validation, proved by the PAIR**:
  `step2/refuse/undefined-escape` refuses `%2F` as an escape and never reaches
  its domain, and `step2/refuse/defined-escape-reaches-the-domain` decodes `%7C`
  first and is refused BY THE DOMAIN naming the decoded `libc|so.6`. Either half
  alone would be satisfied by an implementation that validated first.
- **Seventeen grammar refusals, each naming its own record**: a wrong field
  count, a duplicate root, a duplicate subdirectory pair, an undeclared root in a
  `subdir`, an absolute `floor` location, a `floor` location naming an undeclared
  root, a two-wildcard glob, a leading zero in a generation count, a waiver
  naming a member the floor does not declare, an unknown record token, an
  undefined escape, an empty field, a TRAILING empty field, a multi-segment
  subdirectory, an out-of-order root record, a wrong version line, and the
  decoded-escape domain refusal. Each mutates ONE record of a base document that
  parses clean, the mutation is asserted to be planted before the parser is
  asked, and the line number is derived from the fixture rather than written into
  the expectation.
- **Forward references, which are what "ordering is significant for `root` and
  for nothing else" actually means**: `step2/forward/subdir-before-root-accepted`
  takes the record, and `step2/forward/subdir-before-root-retained` reads the
  parsed model back as `python=current`, which is the half that matters. The
  acceptance case alone would have passed against a parser that took the record
  and silently dropped its subdirectory, which is exactly the round 1 defect.
  `step2/forward/duplicate-before-root-refused` shows the duplicate test is not
  lost with the deferral. The two envelope trailing-separator cases sit beside
  them, because the shared lexer owns that refusal for both documents.
- **The committed document as a subject**: `step2/committed/parses-clean`,
  `step2/committed/root-specs`, the floor and family counts, the waiver and the
  constrained sqlite location, so the bytes the archive will carry are read by
  the same parser rather than trusted.
- **The gate, and the point of it**: `step2/gate/bad-bundle-ran-no-invariant`
  asserts ZERO `PRESENT`, `ABSENT` and `UNEXPECTED` lines, which is what a
  checker that refused and still classified would have produced. Beside it the
  good-bundle path, the roots coming from the document, the limit stated in the
  report, the digest carried in it, the explicit `--root` still winning, and a
  usage error for declaring neither.

**One finding carried forward, recorded so it is not lost.** Five bullets of the
`Step 2 improvement expectations` list above describe `CPLX-CLOSURE-EVIDENCE/1`:
the evidence negatives, the derived verdict truth table, the evidence semantic
negatives, the canonical evidence bytes and the all-three-grammars statement. Q10
routes the evidence document to "Step 6 emit and `closure_evidence_parse`", the
plan's Step 2 behavior lists only the four configuration and envelope functions,
and this document's Step 6 section already carries the evidence records. The
bullets were written into this step from the whole Q10 answer rather than from
the half Step 2 schedules. They are left in place rather than moved, for the same
reason the Step 1 corpus finding was: the step that first consumes them is the
one that should correct them, and that step is Step 6.

No, there is no Step 2 case below its declared coverage that needs completing.
The plan's departure table replaces the pytest coverage number with a case count,
and 85 cases answered with 0 failures is the whole of what this step declares.

### Feature integrity for Step 2

- **`install_pkg.sh` is untouched**:
  `git diff --exit-code HEAD -- src/setups/env/bin/install_pkg.sh` exits 0, and
  the installer-purity grep for `readelf|sha256sum|tar -t` prints nothing, so
  neither the installer nor its audited host-tool contract moved.
- **`pkg.sh` gains no behavior**, at 184 lines unchanged. The packaging wiring is
  Step 5's, so a half-built gate cannot refuse a real packaging run in the
  meantime, which is exactly what the plan's Step 2 feature preservation asks
  for.
- **Step 1 still answers, and its two changed assertions changed for a reason**:
  `--step 1` reports 70 cases and 0 failures. The topology case that measured
  `closure_config.sh` at a body of zero became the case that measures it filled,
  read from the topology's `Filled by` column rather than a hand-kept list; and
  the alias fixture now reports UNANSWERED where `ln` resolves without making a
  symlink instead of a code failure. Neither weakens an assertion on a host that
  can answer it.
- **Step 0 still answers**: `--step 0` reports 66 cases and 0 failures. Its red
  baseline moved by one, since step 2 has a suite now and its two refusal cases
  became the NOTE naming the step that filled it. The contract and corpus digests
  it prints are unchanged, 78559532 and 558c66e5, so a reader can see step 2
  added no host command and no fixture row.
- **The suite that would notice an installer edit first is green**:
  `bash docs/v0.27.0/verify.relocation-rpath.sh --step 3` reports 104 cases and 0
  failures on the RHEL 9.8 build host, with and without
  `--target-capability capability.rhel-9.8.txt`.
- **The lint floor covers the new module**: `bash src/utils/lint_shell.sh`
  reports 48 tracked scripts clean, and the new files were STAGED before that
  run, which is not a formality: the gate reads `git ls-files`, so an unstaged
  file is silently uncovered. It reported one real finding on the first covered
  run, SC2034 over two of the three fixed-name variables the checker reads, and
  each now carries its own scoped disable naming the reader.
- **The harness itself is linted as this effort's plan addition**, since
  `lint_shell.sh` excludes `docs/` by design. It is clean with SC2016 excluded,
  and that exclusion is not new: the construct is the child-shell probe that must
  carry its operands unexpanded, and its count went from 3 to 6 with the three
  new module probes rather than introducing a different pattern.
- **Reporting**: nothing existing is changed. The new reporting is the
  configuration-bundle section of the checker's report, which prints the digest,
  the named source and the statement of the agent's limit, and the declared-roots
  section that names which of `--root` and the bundle the roots came from. A run
  with no `--bundle` prints neither and behaves exactly as Step 1 left it.
- **Nothing is deployed yet**: no staging into an archive, no packaging gate, and
  no checker copy executed to produce evidence.

No, no existing feature or reporting capability is impaired by Step 2.

---

## Step 3. The static subject set and the derived membership half

### Analysis of Step 3 implementation state

Yes. Step 3 has been fully implemented.

Six code review rounds reproduced five implementation defects, R1, R2, R3a, R4
and R5, and all five are repaired with a regression apiece that fails against the
module it repairs. Round 6 confirmed it: "All implementation findings
R1/R2/R3a/R4/R5 are resolved; this answer requests no further implementation
repair within the unchanged scope." The sixth finding, R3b, was the plan
disagreeing with itself about what this step owes, and the specification owner
resolved it on 2026-09-07 by amendment: design Q13 splits the unreferenced
finding into its two halves, plan Q13 gives the edge half to this step and the
entry-point half and its declaration to Step 4. Against the amended plan this
step's obligations are met, and the suite is green on the RHEL 9.8 build host at
124 cases and zero failures.

Independent round 7 review confirms this verdict against the specification-owner
amendment recorded in the request and in design Q13 and plan Q13. R3b is closed:
Step 3 owns UNREFERENCED-BY-EDGE, and Step 4 explicitly owns the declared
entry-point set and combined finding. R1, R2, R3a, R4 and R5 remain resolved.
No production code, harness or corpus changed from round 6, and no substantive
reviewer repair was needed.

### Goal for Step 3

Walk every shipped ELF once, collect its dynamic entries and version needs,
build the provider index before the walk, and check derived membership without
excluding objects that no entry point reaches.

### Step 3 improvement expectations

The single walk must either account for the complete subject set or report the
missing input. A successful reader process must also yield complete parseable
records. An unreferenced finding describes actual reachability of a subject.

The plan states the same obligations in more detail, and they are repeated here
because a later reader checks the implementation against them rather than
against a summary:

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
  non-passing because an UNDETERMINED never counts toward a green. UNANSWERED
  stays a harness outcome and never a production verdict.

### What was implemented for Step 3

- `closure_elf.sh` builds a provider name-to-paths index by globbing the observed
  loader directories in scope order, identifies ELF magic with the shell itself,
  reads each object with one `LC_ALL=C readelf -d -V`, and collects the SONAME,
  the NEEDED list and the version needs into associative arrays keyed by path.
- The walk is ONE `find` whose listing goes through a temporary file, so its exit
  status is collected. An incomplete traversal, a finder that fails and a finder
  that does not resolve are typed `UNDETERMINED|traversal|` naming the root and
  what could not be done, and each leaves the run non-passing on its own.
- The parser refuses the whole object when a recognized dynamic record carries no
  readable value, naming the field, and commits its counters only on success, so
  a refused output leaves no partial edge count behind.
- `closure_rules.sh` checks every collected dependency against the provider index
  and refuses a miss naming both the subject and the name. It separately reports
  the subjects that no edge RESOLVES TO, computed from the selected provider path
  of each name, with each selected provider that IS a symlink resolved to its
  target by FILE IDENTITY rather than by name, because the ordinary library
  layout does not share a name across the two paths.
- `closure_check.sh` sources both modules, runs index, walk and rules in that
  order, prints eight summary rows and three verdict lines, and returns 1 on a
  membership refusal and 5 on a walk or a reading that could not be taken.
- The corpus and harness generate real dynamic-section fixtures from host donors,
  test membership, reachability, reader failures and traversal failures, and
  instrument walk, index and reader counts. Step 0 derives its next absent suite
  from the dispatcher.

### New types or classes introduced for Step 3

No classes are introduced. The shell model adds ordered subject and provider
lists, associative maps for SONAME, NEEDED, version needs and provider paths, the
walk's own state, and counters consumed by the rules and the report. Round 1
added `closure_elf_bracketed`, the one place a string-valued dynamic entry is
read, and `closure_walk_failed`, the one place an incomplete traversal becomes a
typed result. The fixture helpers discover and validate donors, write dynamic
strings and entries, plant a corpus row and assert its own asserted result.

### Architecture check for Step 3

The reader, the rules module and the orchestration keep the planned dependency
direction: the reader has no verdict, every invariant is in the rules module, and
the entry point calls them and decides nothing. The harness asserts that
mechanically over comment-stripped text rather than by inspection.

The review repairs stayed inside those boundaries. The traversal outcome is a
reader concern and lands in `closure_elf.sh`; the reachability rule is an
invariant's and lands in `closure_rules.sh`; the entry point gained one summary
row, one verdict line and a renamed call.

THE REACHABILITY RULE RESOLVES BY FILE IDENTITY NOW, which is what closes R3a. It
distinguishes the selected provider from a second same-name object outside scope,
and it no longer loses identity when the selected soname link and its real target
carry different basenames, which is the ordinary `libz.so.1 -> libz.so.1.2.11`
layout and therefore the common case rather than an edge one. Each selected
provider that IS a symlink is matched against the subjects with `-ef` until its
target is found, stopping at the first match; a selected provider that is a real
file is already reached under its own path and is not swept. The cost is bounded
by the number of symlinked selected providers, which is the distinct needed names
resolving to a link, and it is not an inventory sweep per edge.

THE DECLARED ENTRY-POINT INPUT WAS A PLAN-LEVEL GAP AND IS NOW SCHEDULED.
Before the amendment, the design's full unreferenced finding needed declared
runtime entry points, but no step scheduled that declaration and Q10 carried no
record for it. Step 3 implemented the edge half under its own result name. That
name alone did not authorize a scope change; the specification-owner amendment
below now does.

THE PLAN DISAGREED WITH ITSELF HERE, which is why an implementation step could
not settle it: its Step 3 behavior line specified the finding "computed from the
edges already collected", and its Step 3 expected outcome quoted the design's
conjunction. The specification owner resolved it on 2026-09-07 by amendment
rather than by either role choosing. Design Q13 splits the finding into an EDGE
half and an ENTRY-POINT half with separate inputs; plan Q13 gives the edge half
to this step, under its own result name, and gives Step 4 the entry-point half,
the `CPLX-CLOSURE/1` record that declares the entry-point set, and the combined
result. The declaration is DECLARED and never derived, for the reason Design
Area 2 already gives for the subject rule.

So the result this step ships is what the amended plan asks of it, and the name
it carries is what stops a reader taking it for the whole finding. Step 4's
expected outcome now carries the pair that shows the declaration is being read: a
declared entry point is NOT reported, and the same object with the declaration
removed IS.

The report still sits in the 636-line entry point, below the 650 deployment
ceiling and inside the at-risk band. Move that responsibility to
`closure_rules.sh` before Step 5 grows the file.

Yes, there is something to address, and it is no longer the entry-point input:
the recorded report-size checkpoint before Step 5, with 14 lines of headroom
left under the ceiling.

THE SELECTED PATH IS RESOLVED BY THE FILESYSTEM'S OWN RULES, which is what
closes R5 across all three shapes round 5 reproduced. Components are taken one at
a time from a queue; a link's target is SPLICED BACK into that queue rather than
taken whole, so a component inside the target is resolved too; an absolute target
restarts the resolution from the root; and `..` pops the directory the resolution
actually reached, which is why the reader records the raw target and reduces
nothing when it builds the map. A chase that exceeds the cycle guard is typed
UNDETERMINED and NOTHING is cached, because a partially chased path is not the
physical one. The result is cached by input path, so the resolution is still a
lookup and the cost case that would catch a sweep returning still passes.

THE CYCLE GUARD IS NOT A POLICY. It is the kernel's own SYMLOOP_MAX, because
nothing in this plan says how deep a valid chain may be and a nine-link chain
resolves on the supported host; a tighter bound would refuse a tree that works.

Independent round 5 review found the directory-component fix incomplete when
a symlink target itself introduces another directory alias or a parent component.
Round 6 resolves all three through the component queue and explicit unresolved
result described above. The retained R5 probes and cycle control pass; R5 is
closed and R3b is the sole remaining obligation.

### Cost and structure check for Step 3

The instrumentation passes: one walk, one index construction before the first
read, and one reader call per planted ELF object. Dependency resolution is an
associative lookup rather than a directory scan per object, and the reachability
map is keyed by path.

The alias resolution is a LOOKUP, which is what closes R4. The round 2 repair
made it correct and quadratic: it scanned the subject list for each distinct
selected symlink, which is O(L*N) and not O(L), because the inner scan still
visits subjects skipped as already reached and an early break can come
arbitrarily late. Neither the grammar nor the code fixes L to a constant, and one
distinct soname symlink per library is the ordinary layout, so L grows with N.
Independent instrumentation counted 96, 331 and 1200 identity comparisons at 16,
32 and 64 aliases, and the plan's complexity clarification forbids that shape.

THE ONE WALK NOW RECORDS WHERE EVERY LINK POINTS. `find` is asked for the link
targets in the same invocation that lists the subjects, so resolving an alias is
a map lookup and costs constant work per edge, with the chase bounded at eight
hops so a cycle cannot hang it. No identity comparison is performed at all.

The bound is MEASURED rather than asserted, at two alias populations, because a
sweep and a lookup answer the same and differ only in growth. The case counts the
commands the rule executes under a DEBUG trap with `functrace`, and states its
threshold as work per alias pair rather than as a total ratio, because the totals
carry a base that is itself linear in the population: the round 2 sweep's total
grew 5.9 times for a fourfold population, which a loose ratio would have let
through. Per pair, the lookup holds at 47 then 46 and the sweep went 55 then 81.

Round 1's observation about the parser is repaired rather than accepted. The
output was consumed by slicing the remaining text, which copies what is left on
every iteration and is quadratic in the SIZE of one reader's output; the version
symbols section of a large object runs to hundreds of lines. The parser now reads
the output once with the shell's own line reader, so the per-object parse is
linear in its output and the plan's object and provider traversal bound is not
the only linear claim the evidence supports.

The walk holds its listing in a temporary file rather than a process
substitution. That is one extra file per run and no extra traversal: it is still
ONE `find`, which the instrumented case measures.

No performance issue needs addressing for Step 3: the one path that had a
product bound is a lookup now, and the measurement that would catch its return
runs in the suite.

### Harness case check for Step 3

This effort carries no `pytest` and no `src/pdfss/tests/unit` tree, so the
coverage target the template states is met by the substitution the plan's
departure table fixes: the harness suite, `--step 3`, is the unit of validation
and every production function is exercised by a case with a named control. The
suite is 99 cases with zero failures on the RHEL 9.8 build host.

- **The subject set**: the walked count equals the planted file count and the
  subject count equals the planted ELF count, both computed by the harness from
  what it planted rather than read back from the run.
- **The parser**: the edge count is asserted against a figure derived from the
  donors' own `DT_NEEDED` counts, so a parse that silently returned fewer needs
  fails on the number rather than on a shape.
- **The reading failures**: eight cases, one per way an input goes missing, each
  asserting the typed line, exit code 5, and that `refused` stayed at zero. Round
  1 added the real malformed-ELF case, whose fixture asserts the reader exited 0,
  and the three traversal cases, two of which assert the absence of the
  `CLOSURE MEMBERSHIP OK` line the submitted code printed.
- **The provider index**: the directory count, and the paths behind one lookup
  name asked of the module itself.
- **Membership**: the refusal is asserted whole, naming both the subject and the
  name, with a control that plants the provider and asserts the same tree is then
  accepted with zero refusals.
- **Reachability**: the orphan is named, the count is asserted, the one subject an
  edge reaches is asserted absent, and round 1 added the duplicate-name control:
  a consumer names `libssl.so.3`, the copy in a provider directory is asserted
  ABSENT from the list and the copy under `root/usr/bin` is asserted PRESENT.
- **The locale pin**: a stub reader that answers honestly under `LC_ALL=C` and
  translates otherwise, with both halves controlled.
- **The fixture engine**: each planted row asserts the corpus's own `assert`
  column on the generated object, and the control asserts the donor carries none
  of the invented names.

- **The SONAME alias**, added after round 2: a symlink at the soname beside its
  versioned target and a consumer that names the soname. The target is asserted
  ABSENT from the list, the consumer is asserted PRESENT so the case is about the
  alias resolving rather than about an edge nobody recorded, and the link itself
  is asserted not walked. On a host where `ln -s` copies, the fixture reports the
  obligation UNANSWERED rather than passing over a shape it never built.

EVERY REGRESSION WAS RUN AGAINST THE CODE IT REPAIRS, which is the only thing
that shows it bites.

- Against the SUBMITTED modules, the repaired harness reports 19 failures, among
  them `step3/walk/failing-finder-not-green` returning that code's own
  `CLOSURE MEMBERSHIP OK: 0 edges over 0 subjects all resolve`.
- Against the ROUND 2 modules, it reports 2 failures:
  `step3/unreferenced/alias-target-absent` returning
  `UNREFERENCED-BY-EDGE|subject|...libcplxalias.so.1.2.3`, a normally loaded
  library reported as reachable by nothing, and the count that follows from it.

The current suite is 99 cases with zero failures on the RHEL 9.8 build host, with
Steps 0, 1 and 2 and the relocation Step 3 harness green in the same session.

No unit-tested class is below its target: there is no unit-test tree in this
repository, and every function this step added is exercised by a harness case
with a named control.

All nine mandatory commands pass. Closure Steps 0, 1 and 2 and the relocation
Step 3 harness are green on the same host in the same session, local lint is
clean over 48 scripts, harness ShellCheck exits 0, the installer-purity grep
finds nothing and the HEAD-relative installer diff is empty. The alias behavior
and its cost are both covered by the suite now: the growing-population probe that
exposed R4 is a case in it, and it fails against the module R4 was filed against.

The nine-command union passes unchanged: closure Steps 0, 1 and 2 and the
relocation Step 3 harness are green on the same host in the same session, local
lint is clean over 48 scripts, harness ShellCheck exits 0, the purity grep finds
nothing and the installer HEAD-relative diff is empty. The `current -> version` probe and the three link-chain
probes that reproduced R5 are cases in the suite now, and each fails against the
module it was filed against.

Independent round 5 validation passed all nine mandatory commands: closure
Steps 0/1/2/3 passed 64/70/91/113 cases; relocation Step 3 passed 104 cases;
local lint passed over 48 scripts; harness ShellCheck passed; installer purity
and HEAD-relative preservation checks passed. The current resolver matches the
request. The RHEL code/harness/corpus digests match locally and mandatory
validation changed no tracked paths. Additional real-file probes reproduced all
three remaining R5 cases; in each, the host's `-ef` test confirms the selected
provider is the subject that the rule falsely reports unreferenced.

Independent round 6 validation passed the unchanged nine-command union:
closure Steps 0/1/2/3 passed 64/70/91/124 cases, relocation Step 3 passed 104,
all with zero failures and exit 0. The alias operation-count regression passed.
Local lint passed over 48 scripts, harness ShellCheck passed, installer purity
had no matches and its HEAD-relative diff was empty. The current resolver
matches the request. Production modules, harness and corpus match RHEL SHA-256
digests, and mandatory validation changed no tracked paths. The retained R5
probes and cycle probe passed independently of the harness. No applicable
class-based unit coverage target exists in this Bash repository; the plan's
harness substitute and the relevant regression controls pass.

Independent round 7 validation passed the unchanged nine-command union:
closure Steps 0/1/2/3 passed 64/70/91/124 cases, and relocation Step 3 passed
104 cases, all with zero failures and exit 0. Local lint passed over 48 scripts,
harness ShellCheck passed, installer purity had no matches (expected exit 1),
and the installer's HEAD-relative diff was empty. The tested production files,
harness and corpus match local SHA-256 digests. The current validation resolver
matches the request exactly; mandatory validation changed no review paths and
the umbrella digest is unchanged. The plan's Bash harness coverage substitute
passes, including its measured traversal, index and alias-cost checks.

### Feature integrity for Step 3

- **The installer is untouched**: `git diff --exit-code HEAD` over
  `install_pkg.sh` exits 0, and item 2's harness, which sources it through the
  MAIN BOUNDARY seam and asserts its host-tool allowlist over its text, reports
  `OBJECTIVE MET` on the same host in the same session.
- **Steps 0, 1 and 2 still pass unchanged**. Step 1's UNDETERMINED case still
  counts exactly fifteen typed lines rather than sixteen, because the subject
  phase emits no typed line when the loader scope could not be observed. Step 2's
  gate case still sees zero typed scope lines after a refused bundle.
- **The aggregate is the expected red baseline**: steps 0 to 3 exit 0 and steps 4
  to 7 exit 5, each naming the step that will fill it.
- **The fail-closed requirement now holds on every input this step reads.** The
  subject phase can no longer report membership OK after losing filesystem
  subjects or dynamic dependencies: a traversal that did not complete and an
  object whose record could not be read each refuse the green.
- **The false alias findings are gone**: a selected provider now reaches the file
  the filesystem reaches, through a soname link, through a symlinked directory in
  a prefix of the path, through a target whose own components are links, and
  through a chain. A normally loaded library is no longer reported as reachable
  by nothing, which is the class of defect that would have made this finding
  actively misleading on a real archive rather than merely partial.
- **The reporting limit is now a scheduled half rather than a gap**: the PARTIAL
  verdict is explicit and the result is named for the half it answers. A shipped
  executable is an entry point by definition and appears in this list until the
  declared entry-point set exists, which is exactly why the result carries its
  own name; Step 4 adds that declaration and the combined finding under plan
  Q13.

---

## Step 4. The floor, coherence, rule 1, rule 2 and aggregation

### Analysis of Step 4 implementation state

Yes. Step 4 has been fully implemented.

Round 2 independently confirmed the earlier coherence classification, the
alias-only digest guard and associative membership repairs. The definition
index still copied the remaining node list on every iteration, violating the
plan's linear-phase bound. The reviewer repaired that loop and the same
list-consumption pattern in the other new step 4 invariant functions, and the
requestor accepts that patch whole: a here-string keeps every loop in the
current shell, so the counters, accumulators and associative writes it depends
on all survive, and each nested loop redirects its own stdin.

The one obligation round 2 left open is closed. Both mandatory Linux suites
were rerun on RHEL 9.8 against the reviewer's own assessed index tree
d469c6f0fe2c4e6f8e1cc048faed3448f4d011eb, with the module digests compared on
both ends before the run: step 4 exits 0 at 152 cases and step 3 exits 0 at
124 cases, no failures, on the same harness, contract and corpus digests as
the request-time capture.

### Goal for Step 4

Check the declared floor, provider-aware version coherence, duplicate providers,
declared family generations and missing-input aggregation independently.
Combine the declared entry-point set with the unchanged edge-only finding.

### Step 4 improvement expectations

- Answer every version need against the first candidate in scope order.
- Preserve the declared floor's required-location test.
- Accept aliases of one provider without taking a digest.
- Report each invariant independently, including missing inputs.
- Traverse collected lists once and use indexed membership.

### What was implemented for Step 4

The configuration parser declares entry-point locations; the reader collects
version definitions and classifies reached files as object, not-elf or unread.
The rules module owns the floor, coherence, duplicate and family checks and
the combined unreferenced finding. The checker owns their order, summaries
and aggregate exit status. The eight configured entry-point locations and
the step 2 floor-fixture adjustment remain appropriate to this step.

Round 1's R1 is closed by definite refusals for known non-objects and absent
definitions, and UNDETERMINED for unavailable readings. R2's distinct-target
guard is retained. R3's associative membership changes are retained, with a
further round 2 repair to avoid quadratic copying while reading the lists.

The reviewer changed only closure_rules.sh substantively. Its new step 4
list consumers now use IFS= read -r through here-strings, preserving literal
values and final records without a trailing newline. The definition cache,
scope ordering, first-candidate choice, counters and alias-only guard remain.

### New types or classes introduced for Step 4

No classes are introduced. The shell model adds declared entry points,
version definitions, reached-file classifications, definition and digest
caches, and invariant counters. The reviewer adds no new model or interface.

### Architecture check for Step 4

The parser, reader, rules and orchestration boundaries remain intact.
The reader supplies facts; coherence supplies the verdict. The entry-point
grammar and reader changes are necessary dependencies of step 4.
The reviewer changes no module boundary or configuration contract.

The shipped module counts are closure_check.sh 650, closure_config.sh 645,
closure_elf.sh 479 and closure_rules.sh 635. All satisfy the 650-line ceiling.
The plan owner still owns any topology or headroom decision needed before
step 5; no future-step change is made here.

No current architecture issue needs addressing for Step 4.

### Cost and structure check for Step 4

The definition-index builder originally consumed a shrinking string. On the
authoring host, 1,000, 2,000 and 4,000 nodes took 0.260, 0.916 and 3.582
seconds respectively. After the streaming repair the same measurements were
0.038, 0.089 and 0.173 seconds, with all requested nodes indexed.
These are diagnostic measurements, not a new timing gate.

The same probe was rerun on the RHEL 9.8 target, over a series extended to
8,000 nodes, each run asserting that every requested node was indexed. The
received module took 0.154, 0.594, 2.307 and 9.096 seconds; the repaired one
took 0.016, 0.028, 0.056 and 0.064. The received column multiplies by about
four per doubling and the repaired column does not, which is the plan's
linear-phase bound measured on the platform that ships rather than on the
authoring host alone.

The same streaming change covers the new floor candidate loop, coherence
need loop, duplicate candidate loop, duplicate lookup-name loop and
entry-location lookup. The associative sets and caches remain.
The production walk and provider-index construction are unchanged.
The family and entry-location dimensions remain declared configuration.

No unresolved performance issue was found in the repaired step 4 assessment.

### Harness case check for Step 4

The plan substitutes Bash harness cases for Python class coverage.
No Python unit suite or coverage percentage applies.

The current resolver and the request contain the same seven commands, with
no additions or removals. The project floor is bash src/utils/lint_shell.sh;
the other commands come from the plan, including changed-harness shellcheck.

Reviewer evidence on 2026-09-08:

| Validation | Result |
| --- | --- |
| bash src/utils/lint_shell.sh | exit 0 after the final repair; 48 scripts, clean |
| shellcheck docs/v0.27.0/verify.closure-check.sh | exit 0 |
| bash docs/v0.27.0/verify.closure-check.sh --step 4 | RHEL 9.8, exit 0; 152 cases, 0 failures, on the assessed index tree |
| bash docs/v0.27.0/verify.closure-check.sh --step 3 | RHEL 9.8, exit 0; 124 cases, 0 failures, same subset and run |
| UNDETERMINED producer search | one definition and seven calls; no second invariant producer |
| Installer-purity search | no matches, the required result |
| Installer diff against HEAD | exit 0 |
| Original/repaired invariant probe | exit 0; identical findings and counters |
| Definition-index scaling probe | all requested nodes retained; measurements above |

The local comparison includes three literal defined nodes, an absent node,
a known non-object, unread and unresolved providers, repeated lookup names,
candidate ordering, empty definitions and entry-point path boundaries.
It preserves seven needs, five answered, two refused and two missing-input
results, plus three duplicate lookup names and one multi-candidate name.

Round 2's reviewer upload was rejected by automatic approval review. In round 3,
the reviewer independently ran both mandatory Linux suites from the requestor's
already-present subset, without transferring a repository payload. All nine
validation-input digests matched the reviewed files before and after the runs.
Step 4 returned exit 0 with 152 cases and no failures; step 3 returned exit 0
with 124 cases and no failures. The independent lint checks also passed, and
the validation-state comparison before this metadata update reported no tracked
or untracked repository side effect. No substantive repair was made in round 3.

The subset shipped to the host is `git archive` of the index tree, so the
bytes measured are the staged bytes rather than a working-tree copy of them,
and the two module digests were compared on both ends first:
closure_rules.sh 779bab04a8c43050a8aa540c9f264a55fd7f2930c65348957d6a2c3cbd42bd2f
and verify.closure-check.sh
c4528edb6287863eb7899635534cdbdeef7a116d633665282345335a9de84f5b. Step 4's
output is byte-for-byte the request-time capture apart from the run's own
scratch and subset paths, which is the assertion a performance repair has to
meet. Steps 0, 1 and 2, the aggregate and the preserved surface were rerun on
the same subset and reproduce at 62, 70, 91, 104 cases and an aggregate green
through step 4.

No, no mandatory harness evidence for the repaired bytes is still missing.

### Feature integrity for Step 4

The installer remains unchanged and contains none of the prohibited checker
tools. Earlier-step behavior is preserved by the local comparison and by the
full Linux step 3 regression, which passes at 124 cases on the repaired bytes.
The earlier suite captures remain historical evidence and are not rewritten.
The combined entry-point finding remains separate from the edge-only finding.
The umbrella and every other validation-plan step remain unchanged.

---

## Step 5. Waivers, the packaging gate and the publication boundary

### Analysis of Step 5 implementation state

Yes. Step 5 has been fully implemented.

Round 9 adds the last three acceptance cases the earlier rounds named: an
interruption during the upload stream, a signal during cleanup, and a candidate
pathname offered where the descriptor belongs. On RHEL 9.8 the step 5 suite is
exit 0 at 223 cases, and no production behaviour changed in this round.

BOTH SIGNAL CASES DELIVER A REAL SIGNAL TO A PROCESS GROUP. The stub announces
entry to `upload_write` or to `upload_abort` and holds the run there, so SIGINT
arrives while the run is demonstrably inside the phase under test rather than at
a moment a `sleep` guessed. `setsid` gives the run its own process group, which
is the only delivery that reaches `cat`, `tee` and the uploader subshell as well
as the shell that traps them. Signalling the shell alone would prove nothing
here: bash defers a trap until the foreground command completes, so the pipeline
would run to the end and the transaction would commit before the trap was ever
consulted.

THE PATHNAME CASE IS PROVED BY WHAT WAS PUBLISHED. It hands the production
handoff the REAL digest of the file whose name it puts in
`CPLX_CLOSURE_ARCHIVE_FD`, so an implementation that reopened that name would
stream those bytes, match the identity, commit, and leave one public object.
"Nothing public while the expected digest is correct" is therefore an assertion
the pathname-reopening version cannot pass, which "it refused" is not: every
refusal in that section shares a status. A descriptor control on the same
fixture commits and publishes exactly those bytes.

FIVE MUTATIONS WERE RUN AGAINST THE PRODUCTION MODULE, and the two that changed
nothing are reported below beside the three that did. A case that survives the
removal of what it guards is not a guard, and the only way to know which is
which is to remove the line and look.

Round 7 closed the duplicated-document regression: the complete suffix from
step 6 matches the prior request byte for byte and steps 5, 6 and 7 each occur
once. The real upload-after-replacement case and partial-copy failure are
present with their public-byte or unstaging assertions. The drained successful
empty-digest case asserts the read-back diagnostic and is accepted.

Round 8 closed both of those oracles and left the two signal cases and the
pathname-instead-of-descriptor refusal, which is what round 9 completes.

THE FAILING HASHER NOW EMITS THE CORRECT DIGEST. It drained the stream but
printed nothing, and production checks the digest file for CONTENT before it
tests the awaited status, so the refusal came from the empty-file branch and the
case would have passed unchanged if the status capture were deleted. Printing
the RIGHT digest while exiting non-zero removes every other reason to refuse and
leaves the awaited status as the only one.

THE REMOVED-BUNDLE FIXTURE RESTORES THE FLOOR FIRST. The earlier floor-refusal
case had moved `libssl.so.3` away, so that run refused on the FLOOR whatever the
deletion stub did. The library is put back before the case, the refusal now
asserts the bundle diagnostic rather than a bare non-zero status, and a CONTROL
runs the same fixture with a stub that deletes nothing and requires the gate to
pass, which is what makes the three assertions depend on the removal.

ONE MORE FIXTURE WAS FOUND COUPLED TO ITS NEIGHBOURS. The end-to-end case took
whichever archive was newest, so a later case that packaged again changed what
was published; and the envelope-mismatch case leaves the deployed declaration
tampered and self-consistent, which publication correctly refuses at STEP 1 for
a reason unrelated to waivers. The case now restores the deployed bundle, plants
the waiver state and runs the gate itself.

On RHEL 9.8 the step 5 suite is exit 0 at 223 cases, with steps 0 to 4 at 62,
73, 91, 124 and 152, the installer suite at 49 and 63, and the preserved surface
at 104. No production behaviour has changed since round 3.

### Goal for Step 5

Stage and validate the deployed bundle before packaging, report unknown, stale
and active waivers, and bind the fixed publication checks and transactional
upload to the completed archive's identity.

### Step 5 improvement expectations

- The selector gates tools and refuses mismatched flag/target combinations.
- Packaging verifies the deployed declaration and its committed envelope;
  publication resolves the authoritative declaration independently from Git.
- Refusals precede tar and clean the files staged by that run without corrupting
  an aliased source. Successful staging persists in the archive.
- An active waiver permits a marked validation artifact and prevents publication.
- The checked snapshot and streamed upload both hash to the promoted identity.
- Every planned transaction failure is bounded and checks its exact exit,
  abort count, scratch lifetime and public-object outcome.
- Existing --add, -- passthrough, exclusion, SHA1 deduplication and latest-link
  behavior remain covered by executable preservation cases.

### What was implemented for Step 5

The five-module topology separates reporting from checker status decisions.
Physical-path and digest facts moved to the reader; waiver decisions remain in
the rules module and use the floor entry's own predicate. Packaging stages the
committed declaration/envelope pair and five modules from the deployed tree.
The real pkg dispatcher invokes the overlay that adds --closure-gate.

Publication copies and promotes without overwrite, keeps the descriptor open,
reads a separate snapshot and refuses unless its digest is the promoted identity.
The checks consume that snapshot, and upload verifies its streamed digest before
commit. The pipeline-failure path terminates and awaits the hasher. Earlier
source-alias preservation and bounded tee-failure repairs remain present.

The declaration SHA-256 is
`d1a487b529c3ea1f2a6abac0fda90061f6a5d61a7e4a0d2b52be9f109aeeade1`, matching
the committed envelope. A separate deploy-time envelope producer is not required
under the corrected contract.

Round 9 adds harness coverage only. The stub adapter gains two waiting modes so
a phase can announce that it has been ENTERED and hold the run there, which is
what lets a signal be aimed at a phase rather than at a clock; and the handoff
section gains the pathname refusal with its descriptor control beside it.

### Completed acceptance cases for Step 5

None. The three cases this section carried are closed, each by the shape the
round 8 instructions asked for.

- The interruption during streaming is `step5/signal/stream-*`. The stub
  announces entry to `upload_write` and holds the pipeline there; SIGINT goes to
  the run's own process group under `setsid`, bounded by `timeout`. It asserts
  exit 130, one begun stage, exactly one abort, no public object and a removed
  scratch directory.

- The signal during cleanup is `step5/signal/cleanup-*`. A wrong expected digest
  refuses at step 4, the EXIT trap enters `closure_publish_cleanup`, and the stub
  announces entry to `upload_abort` and waits there. The group signal arrives
  inside that abort. It asserts termination, exactly one abort, no public object,
  and the two facts that place the signal inside the cleanup rather than beside
  it: the stage object the stub was told to destroy still exists, and the scratch
  directory the removal follows is still there.

- The pathname-instead-of-descriptor refusal is `step5/handoff/pathname-*` with
  `step5/handoff/descriptor-control-*` beside it. No production repair was
  required: the handoff already refuses, aborts once and leaves nothing public.

Production was not changed. Each new case was checked against a mutated module
rather than trusted, and the results, including two mutations that changed
nothing, are in the harness case check below.

### New types or classes introduced for Step 5

No classes: this is Bash. The new interfaces are archive identity, the
four-operation upload adapter and checker status 3 for accepted exceptions.

### Architecture check for Step 5

The five-module topology, shared floor predicate and independent publication
policy resolution fit the amended plan. The snapshot and upload each verify the
promoted digest. The committed-envelope authority wording now agrees across the
plan, design and pkg.sh comments. No producer is missing and no new DDD layering
defect was identified. The integration acceptance gaps that Missing work for
Step 5 carried are closed.

No, integration coverage no longer needs completion; the authority-text finding
stays closed and requires no further design work. The two interruption cases
touch no module boundary: they drive the existing four-operation adapter ABI
through the stub the earlier handoff cases already use.

### Cost and structure check for Step 5

The moved caches retain their previous bounds. Snapshot copying and hashing add
linear archive IO, with no new quadratic collection scan found. The known
tee-before-FIFO hang has an explicit termination path, and every failure path
this step names now has a bounded case: the two interruptions run under
`timeout` with `setsid`, and each one waits on a readiness file rather than on a
duration, so neither adds a fixed cost to the suite.

| File | Physical lines, unchanged since round 6 |
| --- | --- |
| closure_check.sh | 617 |
| closure_config.sh | 645 |
| closure_elf.sh | 607 |
| closure_report.sh | 196 |
| closure_rules.sh | 622 |
| closure_publish.sh | 569 |
| pkg.sh | 392 |
| pkg_tools.sh | 24 |

All are below 650, and round 9 changed none of them. No measured performance
regression was established, and the bounded failure-path validation this line
used to defer is now in the suite.

### Harness case check for Step 5

This Bash plan uses harness cases rather than Python class coverage.

| Independent round 8 validation | Result |
| --- | --- |
| Bash lint wrapper, all 50 tracked production scripts | exit 0, clean |
| ShellCheck, changed verification harness | exit 0 |
| Closure steps 5/4/3 on RHEL 9.8 | exit 0; 200/152/124 cases, zero failures |
| Installer steps 2/3 on RHEL 9.8 | exit 0; 49/63 cases, zero failures |
| Copied validation inputs | all 92 SHA-256 values match the local files |
| Tar form and ordering | one tar --sort=name; checker line 299, tar line 338 |
| Installer purity | no matches, expected exit 1 |
| Installer diff against HEAD | empty, exit 0 |
| Independent commit-plan-check | valid, ready, ten groups/fourteen paths, no diagnostics |

The current resolver adds the plan's closure_check call-location search to the
received ten-command set. No command was removed and all eleven passed with
their required expectations, including the negative installer-purity search.
Current evidence is retained under `.reviews/a.closure-s5r8.*`.

The earlier unavailable-runtime finding is closed. This reviewer independently
ran the received harness and production files on RHEL 9.8 after verifying the
copied input hashes. The failing hasher now drains and prints the correct digest
before returning nonzero; the removed-bundle case restores the missing floor
member and requires the bundle diagnostic. Both round 7 oracle findings are
accepted. Validation produced no tracked or untracked repository side effects.

The upload-after-replacement, partial-copy and drained empty-digest cases are
now accepted. The full successful-publication fixture asserts the public-byte digest. The
latest check compares the retained archive's digest. Both are accepted, as are
the new begin/abort/scratch assertions for command failures. Their acceptance
does not fill the distinct remaining cases above. The pre-existing second-level
archive-name collision remains separate work and adds no step 5 blocker.

| Round 9 writer validation | Result |
| --- | --- |
| Closure steps 5/4/3/2/1/0 on RHEL 9.8 | exit 0; 223/152/124/91/73/62 cases, zero failures |
| Installer steps 2/3 on RHEL 9.8 | exit 0; 49/63 cases, zero failures |
| Relocation step 3 on RHEL 9.8 | exit 0; 104 cases, zero failures |
| Bash lint wrapper, all 50 tracked production scripts | exit 0, clean |
| ShellCheck, changed verification harness | exit 0 |
| Copied validation inputs | all 92 SHA-256 values match the local files |

The step 5 suite has gone 76, 110, 121, 133, 166, 188, 198, 200, 223. The
twenty-three new cases are the nine of the pathname pair and the fourteen of the
two interruptions.

THE UNION WAS RUN MORE THAN ONCE against harness digest
`7dd46afdaa84eb49a3be46fc1f99c904933daea937c2b3739db7faed375100f1`, which is the
SHA-256 of the submitted `verify.closure-check.sh`, and every run reported the
same case counts and the same verdicts. The retained capture holds the log of
one of them. Two lines in it differ between runs, both of them digests of a tar
the run builds itself, so they are run artifacts rather than assertions about
these bytes; every other line is identical.

EACH NEW CASE WAS CHECKED AGAINST A MUTATED MODULE. The point of the exercise is
that two of the five mutations changed nothing, which is a fact about what these
cases can and cannot see and is recorded rather than left out.

| Mutation of closure_publish.sh | Step 5 result |
| --- | --- |
| M1: delete `trap 'exit 130' INT` | 223 cases, zero failures |
| M2: delete the `trap -` disarm at the head of cleanup | 223 cases, zero failures |
| M3: read `CPLX_CLOSURE_ARCHIVE_FD` as a NAME rather than a descriptor | 17 failures, six of them the pathname pair |
| M4: delete `trap closure_publish_cleanup EXIT` | 28 failures, six of them the new cases |
| M5: signal traps call cleanup directly AND cleanup does not disarm | 5 failures, both abort counters reading 2 |

M3 and M4 are what make the new cases guards rather than descriptions: with the
descriptor read as a name the pathname case publishes an object and says so,
and with no EXIT trap both interruptions leave zero aborts and a retained
scratch. M5 is the re-entrant cleanup the disarm exists to forbid, and both
abort counters read 2 under it.

M1 AND M2 CHANGED NOTHING, AND THAT IS NOT A GAP IN THE CASES. Bash runs the
EXIT trap on its own termination path, so removing the INT trap alone still
aborts once and still ends at 130; and bash already refuses to re-enter an EXIT
trap, so removing the disarm alone cannot produce a second abort either. The two
lines are distinguishable only together, which is what M5 measures. The cases
assert the transaction's postconditions under interruption, and they are honest
about which line each one reaches.

Yes, the three acceptance cases that Missing work for Step 5 carried are
complete and their evidence is above. No, there is no unit-tested class below
100% that needs completing.

Independent round 9 review confirms the completed cases on the received harness
digest `7dd46afdaa84eb49a3be46fc1f99c904933daea937c2b3739db7faed375100f1`.
All 92 copied input hashes matched before execution. Closure steps 5/4/3/2/1/0
passed at 223/152/124/91/73/62 cases; installer steps 2/3 passed at 49/63;
relocation step 3 passed at 104. Every command exited 0 with zero case failures.
Relocation's inherited step 0 capability note is outside its step 3 criteria.
The local lint wrapper passed all 50 tracked scripts and the harness ShellCheck
passed. The tar, call-order and installer checks passed with their declared
expectations. The fifteen-command resolver set has no drift. Evidence is
retained under `.reviews/a.closure-s5r9.*`.

R8-F1 and R8-F2 are closed. The streaming interruption aborts once and removes
scratch. Interruption inside abort leaves its private stage and scratch, with
one abort entry and no public object; the fixture records that interrupted
cleanup explicitly. The pathname refusal and valid-descriptor control exercise
the production handoff with the same expected bytes. No substantive reviewer
repair was needed and no required acceptance case remains open.

### Feature integrity for Step 5

The tar form, SHA1 implementation and installer bytes remain unchanged. The
real dispatcher, full successful publication, upload after name replacement and
latest identity are covered by the received harness. No production code or tests
were changed by this reviewer.

R6-F3 remains closed. In round 8 this reviewer updated only the step 5 validation
rows, retaining the exact No verdict and its existing completion list. The
surrounding steps, umbrella, document-level status, production code, tests and
a.commit are unchanged. The commit grouping remains mechanically ready.

In round 9 the writer changed the verdict because the work changed: the three
cases that verdict was waiting on exist, run and were checked against a mutated
module. Nothing in the round 8 record was reversed, and no production file,
other step, umbrella row or document-level status was touched. The only edited
files are the harness and this record.

The round 9 reviewer updated only this step's review metadata and the stale
completion descriptions in a.commit. Commit membership, order and subjects are
unchanged. Validation alone produced no tracked or untracked side effects, and
the reviewer preserved all surrounding steps and the umbrella. Step 5 is
recommended commit-ready; that advisory recommendation grants no commit
authority and does not complete the later steps of this effort.

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
