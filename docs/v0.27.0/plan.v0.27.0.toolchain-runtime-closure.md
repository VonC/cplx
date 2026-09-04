# v0.27.0 toolchain-runtime-closure implementation plan

Reference issue: [issue.v0.27.0.toolchain-runtime-closure.md](issue.v0.27.0.toolchain-runtime-closure.md)
Reference design: [design.v0.27.0.toolchain-runtime-closure.md](design.v0.27.0.toolchain-runtime-closure.md)
Reference umbrella: [draft.v0.27.0.debian-agent-tools.md](draft.v0.27.0.debian-agent-tools.md), item 4
Reference environments: [reference.environments.md](reference.environments.md)

This plan introduces no design choice. Every rule it schedules is settled in the
issue's eleven clarifications or the design's nine decisions, and where a step
needs a choice this plan does not own, it names the document that owns it.

The implementation shape has three threads:

- **One checker, two contexts**: four new modules, `closure_check.sh`,
  `closure_config.sh`, `closure_elf.sh` and `closure_rules.sh`, answer the four
  archive invariants on the build account and on the Debian job, over a shape
  declared once and observed against two different roots. Nine production
  scripts exist by the end, and the delivered script topology says which is
  which.
- **Two scopes, never merged**: the declared candidate shape is derived from
  configuration and touches no filesystem; the observed loader scope comes from
  the installer's own `build_elf_rpath`, called rather than reimplemented.
- **Identity by recomputation**: the configuration digest identifies policy, the
  SHA-256 of the closed archive identifies bytes, and publication computes both
  itself rather than reading either from the artifact.

## How this plan departs from the standard template

The template assumes a Python project: `pytest` files under `tests/unit/...`,
`__init__.py` companions, a `ghog day` walk, `check.bat`, and a big-file gate at
650 lines. cplx has none of those. It carries no `tests/` tree, no
`pyproject.toml`, no `check.bat` and no `GROUNDHOG.md`, and every file this
effort adds or changes is Bash. The substitutions are stated once here rather
than re-explained per step, and each keeps the property the template protects.

| Template element | This effort | Why the property survives |
| --- | --- | --- |
| `pytest` unit tests under `tests/unit/**` | cases in a Bash harness, `docs/v0.27.0/verify.closure-check.sh`, invoked as `--step N` | items 1 and 2 of this collection validated the same tree this way, through `verify.install-pkg.sh` and `verify.relocation-rpath.sh`, and their evidence is retained beside them |
| `__init__.py` upkeep | none | there are no Python packages to register |
| `ghog day` walk | one harness walk plus `shellcheck` over every changed script | the property is "one command runs the gate and the tests and stops at the first failure", which the walk keeps |
| `check.bat` | `src/utils/lint_shell.sh`, already named in `.review-validation` as this repository's mandatory floor | it is the lint gate this repository actually has, and one command runs it over every tracked script outside `docs/` |
| the 650-line Python ceiling | a per-file budget on every script the deployment carries, tracked per step | the gate scans Python under `tools` and `tests` and reaches none of these files, but a deployed standalone script has a real size constraint for a different reason, recorded in the confirmed facts |

The harness is deliberately NOT added to `.review-validation`. That file binds
every future review of this repository, and a walk of `verify.closure-check.sh`
is this effort's check rather than the project's: it should retire when v0.27.0
does. It enters the resolved validation set as a plan addition instead, which is
the scope that matches its lifetime.

### Why the settled issue and design carry no IO cost section

The write-plans instruction asks for a file-based IO cost clarification in all
four documents of the cycle. This plan carries one, and the validation skeleton
carries it forward, which is where the constraint is read during implementation.
The issue and the design do not, for two reasons that are specific rather than
general: item 2 of this same collection settled the identical question the same
way, with the section in the plan alone, and its plan review accepted that; and
this design closed four review rounds on 2026-09-03, so amending it now would
reopen a converged document to add a statement no design decision depends on.

## Confirmed facts this plan is built on

These come from reading the current tree, not from the design's summary of it.

**`install_pkg.sh` is 1308 lines and already has the seam this effort needs.**
Its MAIN BOUNDARY at line 1132 returns early when the file is sourced rather
than executed, so sourcing it defines every function and performs no install.
`verify.relocation-rpath.sh` already uses that seam to call production functions
instead of copies. This is what lets the checker call `build_elf_rpath` itself.

**`build_elf_rpath` at line 881 is the one definition of the observed loader
scope.** It globs `$INSTALL_PREFIX/tools/python` first and then every
`tools/*/`, adds `root/usr/lib64`, `root/usr/lib`, `root/lib64`, `root/lib` per
root and `lib`, `lib64` per immediate subdirectory, tests each with `[ -d ]`,
dedupes preserving order, and prints one colon-joined value. It reads exactly
one global, `INSTALL_PREFIX`. Nothing in this effort reimplements it.

**`install_pkg.sh` already carries an ELF reader.** `elf_read_le` at line 357
decodes a little-endian integer at an offset with `od`, and `elf_observe` at
line 391 walks the program headers, locates `PT_DYNAMIC` and iterates `d_tag`
entries looking for `DT_RPATH` and `DT_RUNPATH`. The dynamic-array walk this
effort needs for `DT_NEEDED` and `DT_VERNEED` is the same walk with more tags,
which matters for the fallback path of Step 3 rather than for its main one.

**The installer's host-tool contract excludes `readelf` on purpose.**
[contract.host-tools.txt](contract.host-tools.txt) allowlists 20 commands, and
the harness extracts every command-position word from `install_pkg.sh` and fails
on any word absent from it. `readelf`, `sha256sum` and `tar -t` are not there.
THE CHECKER IS NOT THE INSTALLER: it never runs during an install, so its tools
are its own contract, and the execution checklist keeps a negative grep over
`install_pkg.sh` so a checker tool cannot leak into the installer by accident.

**Both validation hosts carry the checker's tools.**
[reference.environments.md](reference.environments.md) records `readelf` 2.40 on
the Debian 12 agent and GNU coreutils on both, and the RHEL 9.8 build host is
where the toolchain is compiled, so binutils is present there by construction.
Step 0 measures both rather than inheriting either.

**`pkg.sh` is 184 lines and has no gate.** It parses arguments, builds
`ITEMS_TO_ARCHIVE`, runs one `tar | gzip` at line 130, computes a SHA1 at line
135 and deduplicates against the previous archive. There is no place today where
a check could refuse, and no place where a bundle could be staged into the tree
before the tar. Both are added by this effort.

**The archive is `$HOME/tools` plus home-level env files.** `pkg.sh` archives
the target folder relative to `$HOME`, so anything the archive must carry has to
exist under that folder before line 130 runs.

**`--exclude=old` is already the packaging default.** `EXCLUDE_PARAMS` at line
78 excludes any folder named `old`, so `tools/old/py3.13` never enters the tar.
It is nonetheless on the rpath of every relocated ELF on the live install, per
[measurements.resolution-scope.rhel.txt](measurements.resolution-scope.rhel.txt),
because the installed tree still holds it. This is why Design Area 1's
unexpected-root refusal is a real finding on the build account rather than a
theoretical one, and Step 1 records which side each refusal was observed on.

**The measured numbers this plan schedules cases against**: 10 directories in
the observed scope across 3 tool roots; 628 shipped ELFs of which a walk from
185 entry points reaches 176 names and misses 395, including 76 under
`lib-dynload` and 28 under `site-packages`; 54 distinct `DT_NEEDED` names of
which 20 have several candidate paths, all resolving to one file; one violated
declared family, the `libbfd-2.35.2-63` and `libbfd-2.35.2-66` pair.

## File-based IO cost clarification for v0.27.0 toolchain-runtime-closure

The checker runs once per packaging run and once per verification run, over a
tree of a few thousand files of which 628 are ELF. It never runs during an
install and never on a response path, so the cost that matters is the count of
process spawns and full-tree walks, not latency.

The rule this effort holds to: **no step may add a second full walk of the tree
to the production install path, and the checker itself walks the tree exactly
once**. Every per-object fact any invariant needs, the `DT_NEEDED` names, the
`DT_SONAME`, the version needs and the file identity, is collected in that one
walk and held in associative arrays keyed by path. An invariant that finds
itself wanting a second walk has found a plan defect, not an implementation one,
and stops.

Three consequences are load-bearing:

- **One `readelf` invocation per ELF, not one per question.** A single
  `readelf -d -V` per object answers dynamic entries and version needs together.
  Four invariants asking separately would fork 2512 times where 628 suffice.
- **Provider resolution is a lookup, not a search.** The provider directories are
  enumerated once into a name-to-paths index, so resolving a `DT_NEEDED` name is
  a hash lookup rather than a directory scan per name.
- **Content digests are computed only where rule 1 needs them.** Only names with
  more than one candidate path are digested, which is 20 of 54 today rather than
  all 628 objects.

The rule is about the checker, not about the harness. The harness may build and
walk a prepared prefix as often as its cases require.

## Complexity bound clarification for v0.27.0 toolchain-runtime-closure

- **O(1) amortized per object and per lookup name**: one `readelf` read per ELF,
  one hash lookup per `DT_NEEDED` name, one hash lookup per version need.
- **O(n) total per phase**: one `find` walk of the tree, one enumeration of the
  provider directories, one pass over the collected records per invariant.

No path may become `O(n^2)`. The shape that would produce one is resolving a name
by scanning the provider directories inside the per-object loop, which the
name-to-paths index exists to prevent, and Step 3's completion criteria assert
that the index is built before the walk rather than inside it.

## Current validation-tree snapshot for v0.27.0 toolchain-runtime-closure

Existing harnesses this effort must not break:

- `docs/v0.27.0/verify.install-pkg.sh`, 2181 lines, item 1's harness over the
  installer's copy engines.
- `docs/v0.27.0/verify.relocation-rpath.sh`, 6662 lines, item 2's harness. It
  sources `install_pkg.sh` through the MAIN BOUNDARY seam and asserts the
  host-tool allowlist over the installer text. No step here changes an installer
  function, so its assertions must still pass unchanged, and that is a
  completion criterion rather than an expectation.
- `docs/v0.27.0/verify.wrapper-scope.sh` and `verify.wrapper-accept.sh`, item 3.

New validation files this effort creates, all under `docs/v0.27.0/`:

- `verify.closure-check.sh`, the harness, `--step 0` through `--step 7`.
- `contract.closure-tools.txt`, the host-tool allowlist for every script this
  effort ships, the checker, the verification driver, the staging and promotion
  code and the publication gate alike. Round 7 found the earlier version
  claiming that coverage while listing seven commands and omitting several the
  plan already invokes, so the contract is enumerated rather than sampled:
  `readelf`, `sha256sum`, `git`, `tar`, `find`, `mktemp`, `chmod`, `rm`, `cp`,
  `ln`, `cat`, `tee` and `mkfifo`, each with the five-column entry shape
  `contract.host-tools.txt` uses. `cp` and `ln` are named because staging copies
  bytes and promotion links without overwrite, and a promotion that silently
  fell back to a rename would lose the no-overwrite property.
- THE ASSERTION IS MECHANICAL, NOT A LIST TO KEEP IN STEP BY HAND. Step 0's
  harness extracts every command-position word from every shipped script and
  fails on any word absent from the contract, exactly as item 2's harness does
  for the installer, so a command added in a later step must be declared before
  that step can pass.
- PREFLIGHT COVERS EVERY COMMAND WHOSE ABSENCE COULD STRAND STATE. That is the
  publication set, `cat`, `tee`, `mkfifo`, `sha256sum`, `mktemp`, `chmod` and
  `rm`, resolved before `upload_begin` so a missing tool refuses before anything
  local or remote exists.
- `fixtures.closure-corpus.txt`, committed text from which the harness generates
  synthetic ELF objects and tree shapes into its scratch directory.

Nothing binary enters the repository, and nothing changes about what the archive
carries beyond the configuration bundle Step 2 adds and the four payload
checker modules Step 5 stages under `tools/bin/`.

## Line budget policy for v0.27.0 toolchain-runtime-closure

The repository big-file gate scans Python and reaches no file here, so the budget
this plan enforces is a deployment budget, and it is stated as a rule rather than
inherited from the template.

| Band | Meaning here | What the plan requires |
| --- | --- | --- |
| below 550 lines | safe to extend | record the baseline, no constraint |
| 550 through 650 | at risk | avoid growth where practical, give split guidance |
| above 650 | over the ceiling | a responsibility split is required before the step commits |

The ceiling applies to every script the deployment carries, because each is
copied beside the archive onto a bare account and read by whoever debugs an
install there. `install_pkg.sh` at 1308 lines is already past it and this effort
does not grow it: no step adds a line to it, which is a completion criterion in
Step 1 and a grep in the shared checklist.

## Delivered script topology for v0.27.0 toolchain-runtime-closure

Creating a source file is not delivering it. NINE production scripts exist by
the end of Step 7, and they do not all travel the same way, so the topology is
fixed here rather than left to each step. The table's first nine rows are those
nine scripts; the tenth row is the payload copies, which are not a tenth script
but the four checker modules again, staged into the archive.

| Script | Runs on | Where it is executed from | How it gets there |
| --- | --- | --- | --- |
| `closure_check.sh` | build account, and the Debian job | the cplx checkout on the build account; the pipeline workspace on the Debian job | present in cplx for packaging; delivered to the Debian workspace by the pipeline at the resolved cplx commit |
| `closure_config.sh` | the same | the same | the same, sourced by `closure_check.sh` |
| `closure_elf.sh` | the same | the same | the same, sourced by `closure_check.sh` |
| `closure_rules.sh` | the same | the same | the same, sourced by `closure_check.sh` |
| `closure_verify.sh` | the Debian job | the pipeline workspace, OUTSIDE the candidate archive | delivered by the pipeline at the resolved cplx commit, before the archive is opened |
| `closure_observe_live.sh` | the foreign host | the same | the same, invoked by `closure_verify.sh` |
| `closure_publish.sh` | publication host, umbrella item 7 | cplx only | never staged into the archive |
| `closure_d10.sh` | build account | cplx only | item 7 consumes it from cplx |
| `ci/deliver-closure-tools.sh` | the Debian job, first | the pipeline workspace | the pipeline runs it from the cplx checkout at the resolved commit; it is what PLACES the five authoritative copies, so it cannot itself be delivered by them, and it refuses rather than continuing when it cannot obtain them |
| the embedded copies of `closure_check.sh`, `closure_config.sh`, `closure_elf.sh` and `closure_rules.sh` | an installed tree, for an operator | `<prefix>/tools/bin/`, the directory `install_pkg.sh` promotes its own entries into | all four staged into the archive by Step 5 for LATER OPERATOR DIAGNOSTICS only, and never executed to produce evidence |

NO SCRIPT THAT PRODUCES EVIDENCE COMES OUT OF THE ARCHIVE IT JUDGES. Round 2 of
the review found the defect the first version of this table carried: staging
`closure_verify.sh` inside the candidate and then running it against that
candidate makes the archive certify itself. The archive identity proves WHICH
verifier bytes were present, and proves nothing about whether they match the
reviewed cplx implementation or report honestly. It also has no bootstrap: Step
6 must read the archive BEFORE installing it, so the executable cannot come from
inside it. The reasoning that keeps `closure_publish.sh` in cplx is the same
reasoning, and it applies here.

So the line is not travelling against non-travelling. It is AUTHORITATIVE
against PAYLOAD:

- the authoritative copies are delivered by the pipeline from the exact cplx
  commit the release is built at, and they are the only copies whose output is
  evidence;
- the embedded copies are payload, useful to an operator debugging an installed
  tree. They are examined by the authoritative checker like any other shipped
  file, and the authoritative copy compares their bytes against its own and
  REPORTS the result as a payload property. That comparison authorises nothing:
  Q12 is categorical, and an embedded copy is never executed to produce
  evidence, INCLUDING when it is byte-identical. Equality makes two files
  equivalent and does not make a candidate-supplied script an independent judge.

THE MODULE SET IS FIXED AND UNCONDITIONAL, which is what "fixed at Step 1"
has to mean. Round 3 found the earlier version claiming a fixed topology while
four modules were conditional on a measured count: `closure_elf.sh` and
`closure_rules.sh` were created only if a budget required them, and
`closure_scope.sh` and `closure_config.sh` were held in reserve without
appearing in the table at all. A topology that can still change is not a
contract. Step 1 creates all four checker files, each with its contract comment
and nothing else, and the step that owns a responsibility fills its file:

| Module | Owns | Filled by |
| --- | --- | --- |
| `closure_check.sh` | the entry point, the run order, the scope derivation and classification, the report and the exit code | Steps 1 and 5 |
| `closure_config.sh` | the grammar parser, the digest, the envelope check and the cplx-side resolution | Step 2 |
| `closure_elf.sh` | the object reader and the provider index, with no verdict of its own | Step 3 |
| `closure_rules.sh` | ALL FOUR INVARIANTS, the derived membership half included, the waiver outcomes and the UNDETERMINED producer | Steps 3, 4 and 5 |

DERIVED MEMBERSHIP HAS ONE OWNER AND IT IS `closure_rules.sh`. Round 4 found
Step 3 implementing it in `closure_check.sh` while this table assigned every
invariant to the rules module, which left an implementer two boundaries to
follow. Membership is an invariant, so it lands where the other three do, and
Step 3 fills two modules rather than one: the reader in `closure_elf.sh` and the
derived membership half in `closure_rules.sh`. `closure_check.sh` gains the call
and nothing else.

`closure_scope.sh` does not exist in any shape: scope derivation stays in
`closure_check.sh`, which is where the run order that consumes it lives. No step
carries conditional split guidance any more, because there is no conditional
split left to guide; each step carries a budget it must stay inside, and a
module that would exceed 650 is a signal to move a responsibility to the module
that already owns its neighbours rather than to invent a fifth file.

The staging mechanism is the one Step 5 adds for the configuration bundle,
extended to `tools/bin/` for the payload copies only. A staging failure is a
pre-tar refusal, never a warning. The pipeline delivery of the authoritative
copies is a separate mechanism with a separate failure: a Debian job that cannot
obtain them refuses before it opens the archive, and never falls back to a copy
it found inside.

## Shared execution command checklist for all v0.27.0 toolchain-runtime-closure steps

Apply this for every numbered step, substituting the step's own paths.

1. Count lines before edits on every file the step touches:
   `wc -l src/setups/env/bin/closure_*.sh src/setups/env/bin/pkg.sh docs/v0.27.0/verify.closure-check.sh`.
2. Write the harness cases for the step BEFORE the production change, and record
   that they fail for the stated reason rather than for a harness defect.
3. Run the step suite: `bash docs/v0.27.0/verify.closure-check.sh --step N`.
4. Run the step grep checks named in the step's completion criteria.
5. Run the walk to green: `bash src/utils/lint_shell.sh` then the step suite,
   repeated fix-and-walk until both are green in the same cycle.
6. Run the installer-purity grep, every step, no exceptions:
   `rg -n 'readelf|sha256sum|tar -t' src/setups/env/bin/install_pkg.sh`
   must print nothing. A checker tool that reaches the installer breaks its
   audited host-tool contract, and this grep is why that cannot happen quietly.
7. Run the untouched-installer check when the step claims not to change it:
   `git diff --exit-code HEAD -- src/setups/env/bin/install_pkg.sh` must exit 0.
   It is HEAD-relative and exit-status driven on purpose: `git diff --stat`
   alone ignores the index, so a staged edit to the installer would print
   nothing and read as proof that nothing changed.
8. Count lines after edits and compare against the step's line-budget checkpoint.
   Above 650 on any shipped script, apply the split guidance before committing.
   Above only an advisory estimate, record the variance and continue.

## Ready-to-run command templates for all v0.27.0 toolchain-runtime-closure steps

- Line count: `wc -l <step files>`
- Step suite: `bash docs/v0.27.0/verify.closure-check.sh --step N`
- Full suite: `bash docs/v0.27.0/verify.closure-check.sh`
- Lint gate: `bash src/utils/lint_shell.sh`
- Walk to green: the lint gate then the step suite, repeated fix-and-walk until
  both report green in the same cycle. This is the `ghog day` substitute named in
  the departure table, and no step calls a test runner directly.
- Installer purity: `rg -n 'readelf|sha256sum|tar -t' src/setups/env/bin/install_pkg.sh`
- Captures: every host run is retained as
  `docs/v0.27.0/verify.closure.stepN.<host>.txt`, following the naming the two
  earlier items already use.

## Which host can answer which step for v0.27.0 toolchain-runtime-closure

The steps do not all need the same machine, and a step this host cannot run must
say so distinctly rather than answering a cheaper question.

| Step | What it needs | Why |
| --- | --- | --- |
| 0 | Linux with `readelf`, GNU `sha256sum`, Bash 4.0+ | the capability gate measures the checker's own tools on a real host |
| 1 | any Linux with Bash 4.0+ | prepared directory trees only, no ELF content |
| 2 | any Linux with GNU `sha256sum` and `git` | the digest domain and the commit-SHA source |
| 3 | Linux with `readelf` | synthetic ELF fixtures with real dynamic sections |
| 4 | the same | version needs, duplicate candidates and family generations |
| 5 | the same, plus every external command declared by `contract.closure-tools.txt` that the packaging and publication paths execute | the matrix stays synchronized with the mechanically checked contract rather than repeating a partial list |
| 6 | the Debian 12 agent | the foreign-host half: the archive-side observation, the install, the live trace |
| 7 | both hosts | acceptance is a positive result on the distribution the defect exists on, plus the RHEL packaging run |

The harness declares what a step needs and refuses when the host cannot supply
it, reporting `UNANSWERED` with exit 5 and naming the command that would answer
it, exactly as `verify.relocation-rpath.sh` does today. An unavailable check is
never recorded as a passing one.

## Time-gated status policy for v0.27.0 toolchain-runtime-closure

There is no event loop, no response path and no pytest, so there are no
`pytest.mark.timeout` gates to seed and none to remove later. The one time-shaped
constraint is the checker's own walk count, and it is asserted structurally
rather than by a clock: Step 3's completion criteria require that the provider
index is built outside the object loop and that exactly one `find` walk appears
in the checker. A timing gate would measure the machine; the structural assertion
measures the property.

---

## Step 0 analysis and intent

### Step 0 issues

- The checker needs three host tools this repository has never declared for a
  non-installer script: `readelf`, GNU `sha256sum` and Bash 4.0 associative
  arrays. Nothing today says which host supplies them, and item 2 of this
  collection recorded that a harness which inferred a capability from source
  text instead of running it produced a baseline that looked reasonable and was
  wrong.
- The design's acceptance cases span two hosts. Without a declared per-step host
  matrix, a local run that exercises a third of the cases reads as a clean run,
  which is the failure mode this collection has hit three times.
- There is no red baseline. Every case this effort adds must be shown failing
  for the stated reason before any production line exists, otherwise a case that
  passes vacuously is indistinguishable from one that passes correctly.

### Step 0 fix intent

- Create `docs/v0.27.0/verify.closure-check.sh` with the `--step N` interface,
  the three-outcome capability gate and the `UNANSWERED` exit-5 refusal the two
  earlier harnesses already use.
- Declare the checker's own host-tool allowlist in
  `docs/v0.27.0/contract.closure-tools.txt`, separate from the installer's, and
  assert it over the checker text once the checker exists.
- Commit the fixture corpus as text, `docs/v0.27.0/fixtures.closure-corpus.txt`,
  from which the harness generates ELF objects and tree shapes into scratch.
- Capture the red baseline on both hosts.

### Step 0 expected outcome

- `bash docs/v0.27.0/verify.closure-check.sh --step 0` reports the three tool
  capabilities as supported, unsupported or unavailable, and never as a pass by
  omission.
- Steps 1 through 7 have a declared host and a declared refusal path.
- `docs/v0.27.0/verify.closure.step0.rhel.txt` and
  `docs/v0.27.0/verify.closure.step0.debian.txt` are retained.

### Step 0 framings

- Design link: Design Area 5, `Two readings, both required to be conclusive`,
  is the general form of the rule this step applies to the harness itself.
- Execution checklist reference: `Shared execution command checklist for all
  v0.27.0 toolchain-runtime-closure steps`.
- Host: any Linux carrying the three tools. Both hosts are captured, because the
  gate's whole purpose is to measure rather than to assume.

### Step 0 complexity impact

None. The step adds no production code and no walk.

### Step 0 feature preservation

Nothing production changes, so nothing can regress. The one property to hold is
that the FOUR existing harnesses still pass unchanged, and LINT DOES NOT PROVE
THAT: running `lint_shell.sh` over the repository says the scripts parse, not
that their cases still answer. Round 4 was right to refuse the claim, so the
step RUNS them and names them:

```text
bash docs/v0.27.0/verify.install-pkg.sh
bash docs/v0.27.0/verify.relocation-rpath.sh
bash docs/v0.27.0/verify.wrapper-scope.sh
bash docs/v0.27.0/verify.wrapper-accept.sh
```

FOUR HARNESSES, NOT THREE: the validation snapshot enumerates
`verify.wrapper-accept.sh` beside `verify.wrapper-scope.sh` for item 3, and an
earlier version ran the first three and claimed the surface was preserved.

THEY RUN INDEPENDENTLY, NEVER CHAINED WITH `&&`. A chain would let one
per-harness 5 stop the harnesses after it from running at all, so a host
limitation would silently shrink the preserved surface. Each is run on its own,
whatever the previous one returned, and each result is captured.

THE AGGREGATE HAS THREE OUTCOMES, NOT TWO, and an earlier version got this
wrong by calling exit 5 a pass, which contradicts the plan's own rule that an
UNANSWERED never counts toward a green:

| Statuses across the four runs | Step 0 result |
| --- | --- |
| any status other than 0 or 5 | FAIL |
| no failure, and at least one 5 | UNANSWERED: the surface is not proven preserved on this host, and the run says which harness could not answer |
| all four returned 0 | PASS |

Only the third row is a pass. The second is the honest answer for a host that
cannot execute one of the four, and it is reported rather than rounded up.

## Step 0 implementation

### Step 0 files involved

- `docs/v0.27.0/verify.closure-check.sh` (new, to be created).
- `docs/v0.27.0/contract.closure-tools.txt` (new, to be created).
- `docs/v0.27.0/fixtures.closure-corpus.txt` (new, to be created).
- `docs/v0.27.0/verify.closure.step0.rhel.txt` (new, capture).
- `docs/v0.27.0/verify.closure.step0.debian.txt` (new, capture).

### Step 0 test first

The harness is the test, so what comes first here is the refusal path rather
than a case:

- A case that asserts the gate reports `unavailable` rather than `unsupported`
  when a tool cannot be resolved, driven by a `PATH` with the tool removed.
- A case that asserts a step suite invoked on a host missing its declared tool
  exits 5 and names the command that would answer it.
- A case that asserts the corpus file parses and yields the declared number of
  fixture specifications, so a truncated corpus is a failure rather than a
  smaller run.

### Step 0 behavior

- `--step N` runs one step suite in a fresh process, so no capability resolved
  in one step survives into another.
- The capability gate resolves `readelf`, `sha256sum` and `declare -A` and
  records each as supported, unsupported or unavailable, with the third outcome
  reserved for a host that could not be asked.
- `contract.closure-tools.txt` carries the same five-column ENTRY shape as
  `contract.host-tools.txt`, so the assertion written in Step 1 can reuse the
  reading rule rather than inventing a second format.

### Step 0 completion criteria

- `bash src/utils/lint_shell.sh` green.
- `bash docs/v0.27.0/verify.closure-check.sh --step 0` green on both hosts, with
  both captures retained.
- `rg -n 'declare -A' docs/v0.27.0/verify.closure-check.sh` finds the gate.
- The FOUR existing harnesses are RUN INDEPENDENTLY, not inferred and not
  chained: `verify.install-pkg.sh`, `verify.relocation-rpath.sh`,
  `verify.wrapper-scope.sh` and `verify.wrapper-accept.sh`, each invoked on its
  own whatever the previous returned, each capture retained. The aggregate is
  three-way: any status other than 0 or 5 FAILS, any 5 with no failure returns
  UNANSWERED naming the harness, and only four zeros PASS.
- `git diff --exit-code HEAD -- src/setups/env/bin/install_pkg.sh` exits 0.

## Step 0 addendums

### Step 0 line budget checkpoint

- `docs/v0.27.0/verify.closure-check.sh`: before 0; below-550 safe at creation;
  the harness is not deployed, so the 650 ceiling does not bind it, and the two
  earlier harnesses run to 2181 and 6662 lines. Expected 250 to 400 lines
  (advisory).
- No shipped script exists yet.

### Step 0 workflow timing readiness

`bash src/utils/lint_shell.sh && bash docs/v0.27.0/verify.closure-check.sh --step 0`

### Step 0 time-gated status

No perf gates are affected. See the time-gated status policy above.

---

## Step 1 analysis and intent

### Step 1 issues

- The declared candidate shape does not exist anywhere. Nothing in the tree can
  answer "which directories should this archive's search scope contain".
- The observed loader scope exists in exactly one place, `build_elf_rpath`, and
  a second implementation of it would reproduce one level up the drift this
  requirement exists to remove.
- `tools/old/py3.13` is on the rpath of every relocated ELF today. Until the
  refusal is implemented, that root counts as scope, and a floor member present
  only there would satisfy the floor.

### Step 1 fix intent

- Create `src/setups/env/bin/closure_check.sh`, sourcing `install_pkg.sh`
  through its MAIN BOUNDARY seam and calling `build_elf_rpath` for the observed
  scope. No installer line changes.
- Derive the declared candidate shape from three declared inputs, in the
  loader's order, deduped preserving first occurrence: roots python first, then
  each root's declared immediate subdirectories, with the fixed suffixes.
- Emit the three locally observable typed results: PRESENT, ABSENT and
  UNEXPECTED, the last a refusal.

### Step 1 expected outcome

- The checker prints one typed line per declared candidate directory and one per
  unexpected observed directory, and exits non-zero when any UNEXPECTED exists.
- `tools/python/current/lib` and `tools/python/python-3.13.9/lib` are both
  accepted as declared subdirectories, since the second declared input is a
  subdirectory list rather than a version list.
- An undeclared root or an undeclared immediate subdirectory is refused by name.
- The declared shape is derived without touching the filesystem, and the
  observed scope only through `build_elf_rpath`.

### Step 1 framings

- Design link: Design Area 1, all six subsections, and decision Q01 and Q02.
- Execution checklist reference: the shared checklist above.
- Host: any Linux with Bash 4.0+. The cases are prepared directory trees; no ELF
  content is read in this step.

### Step 1 complexity impact

One `find`-free enumeration of the declared shape, O(roots times subdirectories),
which is 10 entries on the measured tree. The observed scope costs exactly what
`build_elf_rpath` already costs, since it is that function.

### Step 1 feature preservation

`install_pkg.sh` is read and never written. The completion criteria assert an
empty diff on it and a green `verify.relocation-rpath.sh --step 3`, which is the
suite that asserts the installer's own host-tool allowlist and would be the first
to notice an accidental edit.

## Step 1 implementation

### Step 1 files involved

- `src/setups/env/bin/closure_check.sh` (new, to be created), filled here.
- `src/setups/env/bin/closure_config.sh` (new, to be created), contract comment
  only; Step 2 fills it.
- `src/setups/env/bin/closure_elf.sh` (new, to be created), contract comment
  only; Step 3 fills it.
- `src/setups/env/bin/closure_rules.sh` (new, to be created), contract comment
  only; STEP 3 STARTS FILLING IT with the derived membership invariant and
  Step 4 adds the other three.
- `docs/v0.27.0/verify.closure-check.sh` (existing, to be updated).
- `docs/v0.27.0/contract.closure-tools.txt` (existing, to be updated).

### Step 1 test first

Cases from the design's `Scope: declared shape, observed loader scope, and the
comparison` table, each as a prepared tree:

- a declared candidate directory absent under both roots: ACCEPTED, reported
  absent;
- an observed immediate subdirectory under a declared root, absent from that
  root's declared list: refused as UNEXPECTED, naming it;
- `tools/old/py3.13` present and not declared: refused as an unexpected root;
- `current/lib` and `python-3.13.9/lib` both declared, both present: accepted,
  no refusal, which is the case a version-shaped declaration would have failed;
- a floor member present only under an undeclared root: refused on the root, and
  the member still reported resolvable in the observed scope, so the two results
  are visibly independent.

One property case beside them: for a prepared prefix, the checker's observed
scope must equal `build_elf_rpath`'s output byte for byte. It cannot drift,
because it is the same function, and the case exists so that a future refactor
that copies the logic fails immediately.

### Step 1 behavior

- `closure_scope_declared`: takes the parsed roots and subdirectory lists,
  returns the ordered deduped candidate list, touching no filesystem.
- `closure_scope_observed`: sets `INSTALL_PREFIX`, sources `install_pkg.sh`, and
  returns `build_elf_rpath`'s value split on the colon.
- `closure_scope_classify`: joins the two and emits PRESENT, ABSENT or
  UNEXPECTED per entry, with the side it was observed on.
- The UNEXPECTED result is unwaivable by construction: no waiver code path
  reaches it, which Step 5 asserts again once waivers exist.

### Step 1 completion criteria

- `bash docs/v0.27.0/verify.closure-check.sh --step 1` green.
- `bash src/utils/lint_shell.sh` green.
- `git diff --exit-code HEAD -- src/setups/env/bin/install_pkg.sh` exits 0.
- `rg -n 'build_elf_rpath' src/setups/env/bin/closure_check.sh` shows the call
  and no reimplementation, and
  `rg -n 'tools/\*/|root/usr/lib64' src/setups/env/bin/closure_check.sh` prints
  nothing, which is the drift the property case exists to catch.
- `bash docs/v0.27.0/verify.relocation-rpath.sh --step 3` still green.

## Step 1 addendums

### Step 1 line budget checkpoint

- `src/setups/env/bin/closure_check.sh`: before 0; below-550 safe at creation;
  deployment ceiling 650; expected 180 to 240 lines (advisory).
- `closure_config.sh`, `closure_elf.sh`, `closure_rules.sh`: before 0; each
  created here with its contract comment, expected under 20 lines until the step
  that fills it.
- `docs/v0.27.0/verify.closure-check.sh`: before the Step 0 count; harness, not
  deployed; expected plus 200 to 300 lines (advisory).

### Step 1 module boundary

None to decide here, and that is the point: the four modules and their
responsibilities are the topology table's, they are created in this step, and no
later step may add a fifth or move a responsibility without changing that table
first. A module approaching 650 moves work to the module that already owns its
neighbours.

### Step 1 workflow timing readiness

`bash src/utils/lint_shell.sh && bash docs/v0.27.0/verify.closure-check.sh --step 1`

### Step 1 time-gated status

No perf gates are affected.

---

## Step 2 analysis and intent

### Step 2 issues

- The four declarations do not exist: no roots list, no floor, no family list,
  no waivers. Step 1's declared shape is currently fed by test fixtures only.
- Nothing defines the digest domain, so two parties could hash the same
  declaration to different values and both be right.
- Nothing distinguishes self-describing from authoritative. An archive that
  carries its own configuration answers what it claims to owe and cannot answer
  whether cplx reviewed that claim.

### Step 2 fix intent

- Commit the configuration document at a fixed path,
  `src/setups/env/closure/closure-config.txt`, carrying the four declarations in
  one file.
- Define the digest as the SHA-256 of that file's exact committed bytes: UTF-8,
  LF endings, no normalisation, no canonicalisation, no re-serialisation.
- Add the identity envelope as a separate file naming the document digest and
  the cplx commit SHA that holds it, and keep the envelope out of the digest so
  the digest never covers itself.
- Implement the three parties' asymmetric checks.

### Step 2 expected outcome

- Packaging reads the configuration at the commit it is about to name, refuses a
  source that is not a committed state, and refuses a branch or tag reference.
- The Debian agent checks that the embedded document hashes to the digest its
  envelope names, and refuses an absent, substituted or corrupted bundle.
- The agent's check is labelled internal consistency in its own output, so a
  green agent run cannot be read as authority it does not have.

### Step 2 framings

- Design link: Design Area 3, all six subsections, and decision Q04.
- Execution checklist reference: the shared checklist above.
- Host: any Linux with GNU `sha256sum` and `git`.

### Step 2 complexity impact

One file read and one digest per run. The commit resolution is one `git` call at
packaging time and none on the agent, which has no cplx access by construction.

### Step 2 feature preservation

`pkg.sh` gains no behavior in this step; only the checker learns to read the
bundle. The packaging wiring is Step 5, so a half-built gate cannot refuse a
real packaging run in the meantime.

## Step 2 implementation

### Step 2 files involved

- `src/setups/env/closure/closure-config.txt` (new, to be created).
- `src/setups/env/closure/README.md` (new, to be created), stating the digest
  domain beside the data it governs.
- `src/setups/env/bin/closure_config.sh` (existing, created empty in Step 1),
  filled here with the parser, the digest, the envelope check and the resolution.
- `src/setups/env/bin/closure_check.sh` (existing, to be updated) to source it.
- `docs/v0.27.0/verify.closure-check.sh` (existing, to be updated).

### Step 2 test first

Cases from the design's `Configuration authority` table:

- the embedded document does not hash to the digest its envelope names: every
  host refuses, before any invariant runs;
- the bundle carries no configuration at all: every host refuses;
- the envelope names a branch or a tag rather than a commit SHA: packaging
  refuses to produce it;
- a floor entry deleted in the same edit that removes the payload, re-hashed to
  match its own envelope: the agent ACCEPTS, packaging and publication refuse.
  This case is the point of the whole area and must be asserted from all three
  sides, not only from the two that refuse;
- the bundle replaced with a different, internally consistent, authentic bundle:
  the agent ACCEPTS, and publication refuses on the digest it resolved itself.
  Publication's half lands in Step 5; this step asserts the agent's acceptance
  and records the pending half by name;
- the named cplx commit does not hold that configuration at that path: packaging
  refuses.

Two digest-domain cases beside them, because the domain is the part a second
implementation gets wrong: the same declaration with CRLF endings must produce a
different digest, and a byte-identical file read through a different path must
produce the same one.

### Step 2 behavior

- `closure_config_parse`: the ONE parser every party uses, implementing the
  grammar Q10 settles: record shape, ordering, duplicate handling, escaping,
  the permitted relative-path form, unknown records and cross-reference
  validation. An exact-byte digest makes two parties agree on the bytes and not
  on their meaning, so the grammar is a separate contract from the digest and
  both are required. Unknown and duplicate records fail closed.
- `closure_config_digest`: SHA-256 over the document bytes, never over parsed
  content.
- `closure_envelope_check`: the agent-side internal consistency check, whose
  output states its own limit.
- `closure_config_resolve_commit`: the cplx-side resolution, refusing a
  non-commit reference.

### Step 2 completion criteria

- `bash docs/v0.27.0/verify.closure-check.sh --step 2` green.
- `bash src/utils/lint_shell.sh` green.
- `rg -n 'sha256sum' src/setups/env/bin/closure_check.sh` shows the digest and
  the installer-purity grep still prints nothing.
- `rg -n 'consistency' src/setups/env/bin/closure_check.sh` finds the agent's
  own statement of its limit, which is a wording requirement of Design Area 3
  rather than a nicety.

## Step 2 addendums

### Step 2 line budget checkpoint

- `src/setups/env/bin/closure_config.sh`: before its contract comment;
  below-550 safe; deployment ceiling 650; expected 140 to 190 lines (advisory).
- `src/setups/env/bin/closure_check.sh`: unchanged apart from sourcing the new
  module, expected plus under 10 lines.
- `src/setups/env/closure/closure-config.txt`: data, not code; no budget.

### Step 2 module boundary

Fixed by the topology: the grammar parser, the digest, the envelope check and
the cplx-side resolution live in `closure_config.sh` and nowhere else, which is
also what lets `closure_publish.sh` reuse them in Step 5 without pulling in the
invariants.

### Step 2 workflow timing readiness

`bash src/utils/lint_shell.sh && bash docs/v0.27.0/verify.closure-check.sh --step 2`

### Step 2 time-gated status

No perf gates are affected.

---

## Step 3 analysis and intent

### Step 3 issues

- No subject set exists. The measurement shows a walk from 185 entry points
  misses 395 of 628 shipped ELFs, including the 76 `lib-dynload` and 28
  `site-packages` modules whose failures motivated this collection, so the
  subject set has to be the walk of the tree rather than a closure over edges.
- No `DT_NEEDED` reader exists outside the installer, and the installer's is
  scoped to `DT_RPATH` and `DT_RUNPATH`.
- Without a provider index, resolving 54 names over 10 directories inside the
  object loop is the `O(n^2)` shape the complexity bound refuses.

### Step 3 fix intent

- Walk the tree once, identify every ELF by its four magic bytes, and record per
  object: path, `DT_SONAME`, the `DT_NEEDED` list and the version needs.
- Build the provider index once, before the walk: for each provider directory in
  scope order, the file names it holds.
- Implement the derived membership half: every `DT_NEEDED` of every subject must
  resolve to a file in the provider directories.
- Report an unreferenced subject as a finding, never as an exclusion.

### Step 3 expected outcome

- The subject count over a prepared fixture tree equals the number of ELF files
  planted, with no object excluded for being unreachable.
- An unresolvable `DT_NEEDED` is refused by name, with the subject that records
  it.
- A shipped ELF reached by no entry point and no `DT_NEEDED` edge, otherwise
  sound, is ACCEPTED and reported unreferenced.
- A second `libssl.so.3` under `root/usr/bin` is examined as a subject and never
  counted as a provider.

### Step 3 framings

- Design link: Design Area 2, `Four sets, kept apart`, `The static subject set
  is every shipped ELF, and the measurement says why`, and decision Q06.
- Execution checklist reference: the shared checklist above.
- Host: Linux with `readelf`. The fixtures are real ELF objects with real
  dynamic sections, generated from the committed corpus into scratch.

### Step 3 complexity impact

One walk, one `readelf -d -V` per ELF, one hash lookup per name. The index is
built before the loop, which is the structural assertion that replaces a timing
gate.

### Step 3 feature preservation

The production files this step changes are `closure_elf.sh`, which it fills,
`closure_rules.sh`, which it starts filling with the derived membership
invariant, and `closure_check.sh`, which gains the calls. NOTHING ELSE CHANGES,
and the installer in particular keeps its own reader untouched: the
installer-purity grep asserts that `readelf` has not migrated into it, and the
untouched-installer check asserts an empty HEAD-relative diff.

## Step 3 implementation

### Step 3 files involved

- `src/setups/env/bin/closure_elf.sh` (existing, created empty in Step 1),
  filled here with the object reader and the provider index.
- `src/setups/env/bin/closure_rules.sh` (existing, created empty in Step 1),
  which gains the DERIVED MEMBERSHIP invariant here, because the responsibility
  table gives every invariant to this module and membership is one of the four.
  Step 4 fills the other three.
- `src/setups/env/bin/closure_check.sh` (existing, to be updated) to source both
  and to call them in order, gaining no invariant of its own.
- `docs/v0.27.0/verify.closure-check.sh` (existing, to be updated).
- `docs/v0.27.0/fixtures.closure-corpus.txt` (existing, to be updated).

### Step 3 test first

Cases from the design's `Subjects, and what the entry-point walk would have
missed` table:

- a `lib-dynload` extension module with an unresolvable `DT_NEEDED`, reached by
  no entry-point walk: refused, naming the module. This is the case a
  walk-based subject set reports as a pass, so it is the one that proves the
  subject rule rather than merely exercising it;
- a `site-packages` wheel extension with a version need its provider does not
  define: refused. The coherence half lands in Step 4, so this step asserts the
  subject is examined and defers the verdict by name;
- a shipped ELF that nothing reaches, otherwise sound: ACCEPTED and reported
  unreferenced;
- a second `libssl.so.3` under `root/usr/bin`: examined as a subject, absent
  from the provider index.

Two structural cases beside them: the walk count over a planted tree equals the
planted ELF count, and the provider index is built exactly once, asserted by
counting index-construction calls during a run.

### Step 3 behavior

- `closure_subjects_walk`: one `find` over the tree, magic-byte identification,
  one `readelf -d -V` per object under `LC_ALL=C`, records accumulated into
  associative arrays keyed by path. The locale is pinned because the parse reads
  `readelf`'s own field labels, and a translated build would silently yield
  empty needs on a host whose locale differs from the one this was written on.
- `closure_read_failed`: the fail-closed production rule, typed correctly. A
  `readelf` that is absent, non-zero, or produces output the parser cannot read
  is an UNAVAILABLE INPUT, so its typed result is UNDETERMINED naming the object
  and the input it lacked. It is NOT a semantic REFUSAL: a refusal says the
  archive is wrong, and this says the reading could not be taken. The
  consequence is identical where it matters, because Design Area 5 already fixes
  it: an UNDETERMINED never counts toward a green, so the aggregate run is
  non-passing and publication is impossible. UNANSWERED with exit 5 stays a
  HARNESS outcome for a host that cannot execute a case, and is never a
  production verdict.
- `closure_provider_index`: one enumeration of the observed provider
  directories in scope order into a name-to-paths map.
- `closure_membership_derived`, in `closure_rules.sh`: for every subject and
  every `DT_NEEDED`, a lookup in the index; a miss is a refusal naming both the
  name and the subject.
- `closure_report_unreferenced`: the separate finding, computed from the edges
  already collected rather than from a second walk.

### Step 3 completion criteria

- `bash docs/v0.27.0/verify.closure-check.sh --step 3` green.
- `bash src/utils/lint_shell.sh` green.
- The harness counts walks and index constructions during a real run rather
  than reading them out of the source text: the step suite wraps `find` and
  `closure_provider_index` with counting stubs and asserts exactly one walk and
  exactly one index construction, with the construction observed before the
  first object read. A source-text grep can show a single occurrence of a
  function name and prove nothing about how many times it ran or in what order,
  which is why the assertion is instrumented.
- The installer-purity grep prints nothing.

## Step 3 addendums

### Step 3 line budget checkpoint

- `src/setups/env/bin/closure_elf.sh`: before its contract comment; below-550
  safe; deployment ceiling 650; expected 200 to 260 lines (advisory).
- `src/setups/env/bin/closure_rules.sh`: expected plus 40 to 70 lines for the
  derived membership half (advisory), before Step 4 fills the rest.
- `src/setups/env/bin/closure_check.sh`: expected plus under 15 lines for the
  calls.
- `docs/v0.27.0/verify.closure-check.sh`: harness, not deployed; expected plus
  250 to 350 lines (advisory).

### Step 3 module boundary

Fixed by the topology, and the boundary is reading against deciding:
`closure_elf.sh` reads objects and builds the index and has no verdict of its
own, while EVERY invariant lives in `closure_rules.sh`, starting with the
derived membership half in this step. `closure_check.sh` calls them and decides
nothing, which is what keeps one boundary rather than two.

### Step 3 workflow timing readiness

`bash src/utils/lint_shell.sh && bash docs/v0.27.0/verify.closure-check.sh --step 3`

### Step 3 time-gated status

No perf gates are affected. The one-walk and index-placement greps in the
completion criteria are the structural stand-in described in the time-gated
status policy.

---

## Step 4 analysis and intent

### Step 4 issues

- The declared floor does not exist, and the derived half of Step 3 cannot see a
  member dropped from the payload and from its consumers in the same edit, which
  is the exact shape of the missing `libsqlite3.so.0`.
- Version coherence is unimplemented, and an earlier revision of the design
  suppressed it whenever rule 1 refused, which threw away a result that scope
  order already decides.
- Rule 1 and rule 2 are two rules with two mechanisms, and running them together
  is what produced the earlier mistaken claim that a library present once per
  tool root was a collision.
- Nothing yet distinguishes a refusal from an unobtainable input, so an
  UNDETERMINED result would either read as a pass or as a failure, and both are
  wrong.

### Step 4 fix intent

- Implement the declared floor half, with the required-location column as the
  observable test, `anywhere in the scope` for most members and `tools/python`
  for `libsqlite3.so.0`.
- Implement provider-aware version coherence: resolve each `DT_VERNEED`
  provider name through the provider directories in scope order, take the first
  candidate, require it to define the needed node, and require the resolution to
  have stayed inside the archive.
- Implement rule 1 over candidates of one exact lookup name, resolved through
  links and compared by content digest, and rule 2 over the declared family
  list and its permitted generation counts.
- Implement the aggregation rule: UNDETERMINED means an input could not be
  obtained, and nothing else.

### Step 4 expected outcome

- Every invariant is evaluated on every run, and no invariant suppresses
  another. Coherence still answers when rule 1 refuses, against the first
  candidate in scope order.
- The measured archive passes rule 1 on its 20 multi-candidate names, which is
  the positive control, and fails rule 2 on the measured `libbfd` pair.
- An UNDETERMINED result is reported with the input it lacked and never counts
  toward a green.

### Step 4 framings

- Design link: Design Area 2, `Membership, in two halves that cannot substitute
  for each other`, `Version coherence, resolved through the provider the object
  names`, `Duplicate providers, in the loader's terms`, `Declared family
  generations`, and Design Area 5, `Aggregation follows data availability`.
  Decisions Q03, Q06 and Q07.
- Execution checklist reference: the shared checklist above.
- Host: Linux with `readelf`.

### Step 4 complexity impact

Each invariant is one pass over records already collected in Step 3's single
walk. Rule 1 digests only the names with more than one candidate path, which is
20 of 54 on the measured archive rather than all 628 objects.

### Step 4 feature preservation

The three earlier harnesses stay green, and the derived half of Step 3 keeps its
own result: the completion criteria assert that adding the declared half did not
change any Step 3 case outcome, since the two halves must not substitute for each
other in either direction.

## Step 4 implementation

### Step 4 files involved

- `src/setups/env/bin/closure_rules.sh` (existing, holding the derived
  membership half from Step 3), which gains the other three invariants here: the
  declared floor, coherence, rule 1, rule 2 and the UNDETERMINED producer.
- `src/setups/env/bin/closure_check.sh` (existing, to be updated) to source it
  and to run the invariants in order.
- `src/setups/env/closure/closure-config.txt` (existing, to be updated) with the
  initial floor, the initial family list and the one sqlite waiver entry.
- `docs/v0.27.0/verify.closure-check.sh` (existing, to be updated).

### Step 4 test first

Cases from the design's `Membership, coherence, duplication and families` table:

- a floor member absent from the scope, unwaived: refused, naming the member;
- `libsqlite3.so.0` present only under `tools/git`: refused on the location
  constraint;
- a `DT_NEEDED` name resolving nowhere: refused, which Step 3 already asserts
  and this step must not change;
- a version need whose selected provider does not define it: refused, naming
  need, provider and scope;
- a resolution that leaves the archive: the static checker refuses, in either
  context, since all four coherence conditions are static;
- two candidate paths for one lookup name, different content: refused, naming
  both paths and both digests;
- twenty lookup names with several candidate paths, all one file: ACCEPTED. This
  is the positive control, and it fails loudly if rule 1 over-refuses, which no
  other case would catch;
- `libbfd` at two generations, family declared: refused;
- the same pair with the family undeclared: not examined, which is the declared
  blind spot rather than an oversight.

Cases from the design's `Aggregation` table:

- a `DT_NEEDED` resolving nowhere, with version needs recorded against that
  name: the name is a REFUSAL and those needs are UNDETERMINED, naming the
  unresolved provider;
- one lookup name with two candidates of different content, and version needs
  answered by that name: rule 1 REFUSES and coherence is EVALUATED against the
  first candidate in scope order and reported. This is the correction round 2
  asked for, so the case asserts the presence of the coherence result, not only
  the presence of the refusal;
- a floor member absent, and unrelated version needs elsewhere: the member is a
  refusal and the unrelated needs are evaluated normally;
- an UNEXPECTED directory on one host: a refusal, and every local result on that
  host still computed and reported;
- an UNDETERMINED result and no refusal anywhere: NOT a pass.

### Step 4 behavior

- `closure_floor_check`: per floor entry, the location test named in its own
  row, so the floor check, the waiver removal condition of Step 5 and umbrella
  item 6 all test the same thing.
- `closure_coherence_check`: per subject and per version need, provider
  resolution in scope order, first candidate selected, node presence required,
  in-archive resolution required.
- `closure_rule1_duplicates`: per lookup name, candidates in scope order, links
  resolved, distinct targets compared by content digest.
- `closure_rule2_families`: per declared family, SONAME patterns matched,
  generation count compared with the permitted count.
- `closure_result_undetermined`: the one place an UNDETERMINED is produced, so
  the rule that it means a missing input has one implementation and one place to
  read.

### Step 4 completion criteria

- `bash docs/v0.27.0/verify.closure-check.sh --step 4` green, including the
  positive control.
- `bash docs/v0.27.0/verify.closure-check.sh --step 3` still green with no case
  outcome changed.
- `bash src/utils/lint_shell.sh` green.
- `rg -n 'closure_result_undetermined' src/setups/env/bin/closure_*.sh | wc -l`
  shows one definition and no second producer of that verdict.
- The installer-purity grep prints nothing.

## Step 4 addendums

### Step 4 line budget checkpoint

- `src/setups/env/bin/closure_rules.sh`: before its contract comment;
  below-550 safe; deployment ceiling 650; expected 220 to 300 lines (advisory).
- `src/setups/env/bin/closure_check.sh`: expected plus 30 to 50 lines for the
  run order (advisory).

### Step 4 module boundary

Fixed by the topology, and the boundary is deciding against orchestrating:
`closure_check.sh` keeps the run order, the report and the exit code, and
`closure_rules.sh` holds no exit and no printing of its own. The UNDETERMINED
producer lives there too, so the rule that it means a missing input has one
implementation and one place to read.

### Step 4 workflow timing readiness

`bash src/utils/lint_shell.sh && bash docs/v0.27.0/verify.closure-check.sh --step 4`

### Step 4 time-gated status

No perf gates are affected.

---

## Step 5 analysis and intent

### Step 5 issues

- Nothing calls the checker. `pkg.sh` builds a tar with no gate in front of it,
  so every invariant implemented so far is unreachable from a real packaging
  run.
- The waiver contract is unimplemented, so an archive produced while a member is
  missing is indistinguishable from a complete one.
- The publication boundary does not exist, and it is the only thing that makes
  the gate mean unpublishable while incomplete rather than merely reported.

### Step 5 fix intent

- Stage the configuration bundle into the tree before the tar, so the archive
  carries the document and its envelope.
- Call the checker from `pkg.sh` before line 130 and refuse the packaging run on
  any refusal, printing every active waiver on every run.
- Implement the three waiver failures: UNKNOWN, STALE, and the validation
  artifact an active waiver produces.
- Create `src/setups/env/bin/closure_publish.sh` implementing the publication
  re-check in its fixed order, with step 0 computing the archive identity.

### Step 5 expected outcome

- A packaging run over a tree with a missing floor member and no waiver refuses
  and produces no archive.
- The same run with the sqlite waiver active produces an archive, marks it a
  validation artifact, and publication refuses it.
- A waiver whose member is now present is refused as stale, using the floor
  entry's own location test rather than a document fact.
- Publication refuses in a fixed order, and a stripped or swapped configuration
  fails before the waiver question is asked.

### Step 5 framings

- Design link: Design Area 4, all four subsections, and decisions Q05 and Q02.
  The unwaivable unexpected-root refusal of Design Area 1 is asserted again here
  now that waiver code exists to bypass it.
- Execution checklist reference: the shared checklist above.
- Host: Linux with `readelf` and `tar`.

### Step 5 complexity impact

One checker run per packaging run. Publication adds one SHA-256 over the archive
file and one `git` resolution, both once per publication.

### Step 5 feature preservation

`pkg.sh` keeps every existing behavior: the `--add` and `--` passthrough, the
`--exclude=old` default, the SHA1 deduplication and the `latest` symlink. The
gate is added before the tar and returns early on refusal, so a green run
produces exactly the archive it produces today plus the staged bundle. Cases in
`verify.install-pkg.sh` that exercise `pkg.sh` must still pass unchanged.

## Step 5 implementation

### Step 5 files involved

- `src/setups/env/bin/pkg.sh` (existing, to be updated) with the
  `--closure-gate` flag, the paired refusals and the staging branch.
- `src/setups/env/bin/pkg_tools.sh` (existing, to be updated), THE ONE IN-SCOPE
  CALLER: line 18 is `exec bash "${PKG_TOOLS_DIR}/pkg.sh" tools "$@"`, and it
  becomes the invocation that passes `--closure-gate`. It is the front end for
  the toolchain payload and the only place in this repository that packages
  `tools`.
- `src/setups/env/bin/pkg` (existing, no change required), the dispatcher:
  `pkg tools` finds the `pkg_tools.sh` overlay beside it and execs that, so it
  reaches the gate through the caller above and needs no flag of its own. A case
  asserts that path rather than assuming it.
- `src/setups/env/bin/closure_rules.sh` (existing, to be updated) with the
  waiver outcomes.
- `src/setups/env/bin/closure_publish.sh` (new, to be created), sourcing
  `closure_config.sh` for the resolution and the digest.
- `docs/v0.27.0/verify.closure-check.sh` (existing, to be updated).

OUT-OF-REPOSITORY CALLERS ARE A HANDOFF, NOT A SILENT BREAK. A consuming project
that packages its own folder is unaffected, since it never passes the flag and
never targets `tools`. A consuming project that packages `tools` through its own
overlay WOULD start refusing, which is the intended behavior and is recorded
here as the cross-item note: umbrella item 7 owns the release path and adopts the
flag there, and until it does, packaging `tools` outside `pkg_tools.sh` refuses
on purpose rather than producing an ungated archive.

### Step 5 test first

Cases from the design's acceptance tables:

- the same floor member absent, with the sqlite waiver active: an archive is
  produced, marked as a validation artifact, and publication refuses it;
- a waiver whose member is now present: refused as stale;
- a waiver naming a member not on the floor: refused as unknown;
- a waiver attempting to name a tool root: refused as UNKNOWN, since waivers
  name floor members only and this design does not amend that;
- publication given an archive whose divergence comparison never ran: refused at
  step 2 of the publication order;
- a stripped configuration with no active waiver: refused at step 1, before the
  waiver question, which is why the order matters and is asserted as an order
  rather than as a set of independent checks.

The four selector corners, each its own case, because they fail for four
different reasons and one case would assert only the corner it planted:

- `--closure-gate` with target `tools`: enters the branch, stages, checks;
- `--closure-gate` with any other target: refuses, since the gate has no
  contract for another payload;
- target `tools` with NO flag: refuses, which is the corner that stops the flag
  being quietly omitted for the one run this requirement exists to gate;
- an unrelated target with no flag: behaves exactly as it does today, byte for
  byte, and never enters the branch.

Two selector boundary cases beside them: a renamed target such as `tools2`
neither receives the gate nor stands in for `tools`, and `pkg tools` through the
dispatcher reaches the gate by way of the `pkg_tools.sh` overlay, asserted
rather than assumed.

Four staging and promotion cases for publication: a source MUTATED DURING THE
COPY still yields a digest describing the completed copy; a PRE-EXISTING
destination makes the promotion refuse rather than overwrite; a SYMLINKED
destination is refused; and a group-writable staging root refuses before any
copy runs.

Six handoff cases against a STUB UPLOADER that implements the four operations,
because a transactional contract is proved by what it leaves behind on failure
rather than by what it does on success:

- the stub accepts the descriptor, hashes and streams one read, and commits;
- a candidate PATH offered instead of the descriptor is refused;
- the promoted path is mutated, unlinked and replaced after the gate opens it,
  and the stub still streams the original bytes, because nothing reopens a name;
- the expected digest is wrong: the callback aborts and NO PUBLIC OBJECT EXISTS,
  asserted by asking the stub what it has published rather than by reading its
  exit status;
- the hasher fails: same outcome, and the failure is visible because the hasher
  is awaited rather than left inside a process substitution;
- `upload_write` fails: same outcome, its status carried out of the pipeline by
  the `|| pipe_rc=$?` capture.

Five more from round 6, because a transaction is proved by its failure paths:

- a PREFLIGHT failure, one of `cat`, `tee`, `mkfifo` or `sha256sum` absent:
  refuses BEFORE `upload_begin`, so nothing is ever staged;
- a SETUP failure after begin, `mkfifo` unable to create the FIFO: the trap runs
  `upload_abort`, nothing is public, and the scratch directory is gone;
- an INTERRUPTION, SIGINT during the stream: same outcome, because the trap
  covers INT, TERM and HUP as well as EXIT;
- a DIGEST-READ failure, an empty or unreadable `hash.out`: refuses before the
  comparison rather than comparing an empty string, and aborts;
- an ABORT failure, the stub refusing to abort: the run still refuses, and the
  stage handle is named on stderr so an operator can find what may persist;
- a COMMIT failure: nothing is public, because `committed` is still 0 when the
  trap runs.

Six more from round 7, which are the paths the previous flow left open:

- a `cat` failure and a `tee` failure, each its own case, because `pipefail` is
  what makes them visible and its absence would have been invisible in a test
  that only ever failed the last stage of the pipeline;
- a `chmod` failure on the scratch directory: refuses, and the directory is
  GONE, which the previous flow could not deliver because the trap was armed
  later;
- an `upload_begin` failure: refuses, the scratch directory is gone, and NO
  ABORT IS ATTEMPTED, because no stage exists to abort;
- a SIGNAL DURING CLEANUP: `upload_abort` runs EXACTLY ONCE, asserted by
  counting the stub's abort calls rather than by inspecting the exit status;
- a scratch removal failure: the path is named on stderr and the publication
  verdict is unchanged, which is the stated behavior rather than an accident.

The scratch directory is asserted gone on every path where removal succeeds, and
the stub is asked what it has made public rather than being trusted to have
exited correctly.

Two `pkg.sh` preservation cases beside them: a packaging run with `--add` and a
`--` passthrough still produces the same archive contents as before the gate,
and a duplicate archive is still deduplicated by SHA1 to the previous file.

### Step 5 behavior

- THE SELECTOR IS AN EXPLICIT ARGUMENT, NOT AN INFERENCE. `pkg.sh` gains one
  flag, `--closure-gate`, and the toolchain branch is entered when and only when
  that flag is present. Two refusals make the selector total rather than
  optional: the flag with any target other than `tools` refuses, because the
  gate has no contract for another payload, and the target `tools` WITHOUT the
  flag refuses, because that is exactly the packaging run this requirement
  exists to gate. Every other target, with no flag, behaves as it does today and
  never enters the branch. The positive and negative selector cases are named in
  the Step 5 test-first list, including a renamed target such as `tools2`, which
  must neither receive the gate nor be able to stand in for `tools`.
- Staging is what that branch does first. It copies the configuration document,
  the envelope and the four PAYLOAD checker modules, `closure_check.sh`,
  `closure_config.sh`, `closure_elf.sh` and `closure_rules.sh`, into the target
  folder, verifies every destination byte against its source, then calls the
  checker, then tars. THE SOURCE IS THE RESOLVED COMMIT, NOT THE WORKING TREE:
  the bytes staged are the bytes cplx holds at the commit the envelope names,
  read at that commit, so a dirty working tree cannot ship a declaration nobody
  reviewed. On a run that succeeds the staged files PERSIST in the packaged
  tree, which is what puts them in the archive.
- THE GATE IS KEYED TO THE SELECTOR, NOT TO THE BUNDLE'S PRESENCE: once the
  branch is entered, a missing source file, a failed copy or an absent staged
  bundle is a REFUSAL BEFORE `tar`, never a reason to skip the check. Deleting
  the bundle therefore cannot turn the gate off, which is the hole a
  bundle-presence trigger would have left.
- Publication keeps its own independent missing-bundle refusal at step 1, as
  defense in depth rather than as the only defense.
- A refusal exits before any tar runs, so no partial archive is left behind, and
  the staged files are removed on refusal so a later run cannot inherit a bundle
  it did not stage.
- `closure_waiver_validate`: unknown, stale and active, with the stale test
  being the floor entry's own location test.
- The gate refuses to act on a path it was merely shown, and the order is exact,
  because a digest-derived name is not immutable by itself:
  1. create a regular temporary file EXCLUSIVELY, failing if it already exists,
     inside a protected staging root the gate owns, mode 0700, refused if it is
     a symlink, not a directory, or writable by group or other;
  2. copy the candidate into that temporary file;
  3. compute the SHA-256 of the COMPLETED COPY, never of the source, so a source
     mutated during the copy cannot be certified;
  4. promote the copy atomically and WITHOUT OVERWRITE to its digest-derived
     name by linking it, which fails if the name exists, then unlink the
     temporary name;
  5. open that promoted file once, read-only, and use THAT instance for the five
     publication steps and for the handoff.
- THE HANDOFF IS A DESCRIPTOR, NEVER A PATHNAME. Round 3 found the decisive
  race in the earlier version: the gate opened the promoted file, then exited
  and returned a name, and any uploader that reopens that name has the
  time-of-check gap back. A 0700 directory and a digest-derived basename do not
  stop the owner modifying, unlinking or replacing the file after the gate
  returns. So the gate does not return a name and exit. It keeps the open
  descriptor and INVOKES A CONSTRAINED UPLOADER, passing that descriptor, and
  the uploader reads THAT DESCRIPTOR without reopening anything.
- THE UPLOAD IS TRANSACTIONAL, AND THAT IS WHAT MAKES THE ONE-READ DESIGN SAFE.
  Round 5 found the gap: a single pass can hand bytes to an uploader before the
  digest is known, and a non-zero exit cannot retract a public upload. So the
  callback drives an adapter with four operations: `upload_begin` creates an
  object that IS NOT PUBLICLY VISIBLE and prints its handle, `upload_write`
  consumes stdin into it, `upload_abort` destroys it leaving nothing public, and
  `upload_commit` makes it public atomically. THOSE FOUR NAMES ARE THIS
  EFFORT'S ADAPTER ABI, tested here against a stub. Umbrella item 7 keeps
  whatever public API it has and supplies an adapter with these semantics; this
  plan does not impose its names on item 7's surface.
- EVERY TRANSACTION COMMAND IS PREFLIGHTED BEFORE transaction scratch or a
  remote stage exists. The flow resolves `cat`, `tee`, `mkfifo`, `sha256sum`,
  `mktemp`, `chmod` and `rm` before `mktemp -d` and before `upload_begin`; an
  absent command therefore cannot strand either transaction-local scratch or a
  remote stage. Commands used by the earlier copy and no-overwrite promotion are
  also declared in `contract.closure-tools.txt` and are exercised before the
  uploader begins.
- THE CONTROL FLOW IS FAILURE-COMPLETE, and round 6 was right that the earlier
  sketch was not: nothing ran `upload_abort` on a `mkfifo` failure, an
  interruption, a digest-read failure or a commit failure, the scratch files
  were never cleaned, and the status captures would have been killed by an
  enclosing `errexit` before they were read.

  ```bash
  set -o pipefail
  for tool in cat tee mkfifo sha256sum mktemp chmod rm; do
      command -v "$tool" >/dev/null 2>&1 || exit 1
  done

  scratch=$(mktemp -d "$staging_root/.pub.XXXXXXXX") || exit 1
  stage=""; committed=0
  cleanup() {
      rc=$?
      trap - EXIT INT TERM HUP
      if [ -n "$stage" ] && [ "$committed" -eq 0 ]; then
          upload_abort "$stage" \
              || printf 'abort FAILED, stage %s may persist\n' "$stage" >&2
      fi
      rm -rf "$scratch" \
          || printf 'scratch %s NOT removed\n' "$scratch" >&2
      exit "$rc"
  }
  trap cleanup EXIT INT TERM HUP

  chmod 700 "$scratch" || exit 1
  fifo="$scratch/hash.fifo"; seen="$scratch/hash.out"
  stage=$(upload_begin) || exit 1

  mkfifo "$fifo" || exit 1
  sha256sum > "$seen" < "$fifo" &
  hasher=$!

  pipe_rc=0
  cat <&"${CPLX_CLOSURE_ARCHIVE_FD}" | tee "$fifo" | upload_write "$stage" \
      || pipe_rc=$?
  hash_rc=0
  wait "$hasher" || hash_rc=$?
  [ -s "$seen" ] || exit 1
  read -r digest _ < "$seen" || exit 1

  [ "$pipe_rc" -eq 0 ] && [ "$hash_rc" -eq 0 ] \
      && [ "$digest" = "$CPLX_CLOSURE_ARCHIVE_SHA256" ] || exit 1

  upload_commit "$stage" || exit 1
  committed=1
  ```

  FOUR THINGS IN THAT FLOW ARE LOAD-BEARING, and round 7 found the first three
  missing or wrong in the previous version:

  - `set -o pipefail` IS IN THE FLOW, not in the prose about it. Without it
    `pipe_rc` carries only the last command's status, so a `cat` or `tee`
    failure would have been invisible while the answer claimed otherwise.
  - THE TRAP IS ARMED AS SOON AS SCRATCH EXISTS, not after `upload_begin`. A
    `chmod` or `upload_begin` failure previously left the directory behind
    despite the rule that it is removed on every exit. `stage` starts empty and
    the trap aborts only when it is non-empty, so arming early cannot abort a
    stage that was never created.
  - CLEANUP IS SINGLE-ENTRY. `trap - EXIT INT TERM HUP` runs first inside
    `cleanup`, so a signal arriving during cleanup cannot re-enter it and call
    `upload_abort` twice.
  - `committed` FLIPS ONLY AFTER `upload_commit` RETURNS 0, so every other exit
    path, a signal and a commit failure included, aborts the stage.

  The scratch directory is created exclusively with `mktemp -d` at 0700 inside
  the protected staging root, so the FIFO and the digest file cannot be
  pre-existing symlinks. Statuses are captured through or-assignments rather
  than bare commands, so an enclosing `errexit` cannot kill the run before the
  values are read, and the digest file is checked for content before it is read.
  IF `rm -rf` ITSELF FAILS the scratch path is named on stderr and the exit
  status is unchanged: local cleanup is an operator concern, and the publication
  verdict does not depend on it.
- FAILURE POSTCONDITIONS ARE STATED, so a caller always knows what exists:
  `upload_begin` failing leaves NOTHING staged and nothing public, and the trap
  is not yet armed; `upload_abort` succeeding leaves nothing public and no
  retained stage, and failing leaves a stage that MAY persist, named on stderr,
  with the run still refusing; `upload_commit` succeeding makes the object
  public, and failing leaves nothing public because the trap aborts. An adapter
  whose commit could fail after publishing does not satisfy the ABI, since
  atomic commit is what makes the failure postcondition knowable.
- WHERE THE UPLOADER CANNOT BE INVOKED THIS WAY, THIS PLAN DOES NOT CLAIM THE
  PROPERTY. Umbrella item 7 owns the real uploader, so the four-operation
  callback interface is item 7's PREREQUISITE: until item 7 accepts it, or
  implements the same open-once, await-all, compare-then-commit obligation in
  its own code, the release path does not have checked-byte identity. This plan
  delivers the gate and proves the contract with a stub uploader in its own
  harness, and it says what is missing rather than describing item 7's
  obligation as a fallback that closes the gap here.
- `closure_publish.sh` runs the five steps in order: identity, configuration
  resolution, keyed verification result, static re-check, waiver refusal. It
  takes the archive path and the release commit. It reads the candidate's
  contents, because step 3 re-runs the static checker over them, and it takes
  no POLICY and no EVIDENCE from the archive: the configuration comes from cplx
  at the release commit, and the verification result comes from the results
  root keyed by the identity publication computed.

### Step 5 completion criteria

- `bash docs/v0.27.0/verify.closure-check.sh --step 5` green.
- `bash docs/v0.27.0/verify.install-pkg.sh` still green, which is the suite that
  owns `pkg.sh` behavior today.
- `bash src/utils/lint_shell.sh` green.
- `rg -n 'closure_check' src/setups/env/bin/pkg.sh` shows the gate before the
  `tar` at the archive-creation site, and
  `rg -c 'tar --sort=name' src/setups/env/bin/pkg.sh` returns 1. That is the
  form `pkg.sh` already uses at line 130 and the assertion is that it is
  PRESERVED: this effort schedules no archive-format change, and any edit to
  that line would move the archive bytes and therefore the SHA1 deduplication
  and the archive identity of Design Area 7.
- The installer-purity grep prints nothing.

## Step 5 addendums

### Step 5 line budget checkpoint

- `src/setups/env/bin/pkg.sh`: before 184; below-550 safe; deployment ceiling
  650; expected plus 40 to 70 lines (advisory).
- `src/setups/env/bin/closure_publish.sh`: 0; below-550 safe at creation;
  expected 140 to 200 lines (advisory).
- `src/setups/env/bin/pkg_tools.sh`: before 18; one line changes.
- `src/setups/env/bin/closure_rules.sh`: waiver handling adds an expected 60 to
  90 lines (advisory).

### Step 5 module boundary

Fixed by the topology, and this is the step that proves it pays: publication
needs the configuration parser, the digest and the resolution and needs none of
the invariants, so `closure_publish.sh` sources `closure_config.sh` alone. Every
shipped script is counted here and the counts are recorded in the validation
document, as a check against the budget rather than as a split decision.

### Step 5 workflow timing readiness

`bash src/utils/lint_shell.sh && bash docs/v0.27.0/verify.closure-check.sh --step 5`

### Step 5 time-gated status

No perf gates are affected.

---

## Step 6 analysis and intent

### Step 6 issues

- Only one half of the design runs so far. Nothing derives the archive-side
  observation, nothing installs and observes the installed tree, and nothing
  compares the two, so DIVERGENT cannot be produced by any actor.
- The live observer does not exist, and it owns the one condition no static read
  can answer.
- No evidence artifact exists, so publication's step 2 has nothing to check and
  Step 5's publication cases are asserted against a fixture rather than a
  producer.

### Step 6 fix intent

- Create `src/setups/env/bin/closure_verify.sh`, DELIVERED TO THE DEBIAN JOB BY
  THE PIPELINE from the exact resolved cplx commit and executed from the
  workspace, never from inside the candidate. It reads the archive it is about
  to install for the pre-install observation, installs, derives the installed
  observation, compares them, and refuses DIVERGENT. A job that cannot obtain
  the authoritative copy refuses before it opens the archive, and never falls
  back to a copy found inside it.
- Compare the archive's embedded payload copies of the checker modules against
  the authoritative ones, byte for byte, and report the result. They are payload
  under examination, never a source of evidence, and Q12 settles the rule.
- Run the static checker on the installed tree, and the live observer against
  one named process.
- Emit one evidence artifact keyed by the SHA-256 of the archive file, carrying
  the six fields Design Area 7 names.

### Step 6 expected outcome

- A directory present in the archive and absent under the installed tree is
  refused as DIVERGENT by verification, while packaging passes its own local
  check, which is the case the design moved out of packaging.
- A directory present on the build account that never entered the tar is also
  refused as DIVERGENT, which is the case a transported packaging claim would
  have reported as present on both sides.
- Verification unable to read the pre-install archive contents refuses, naming
  the missing input, rather than proceeding with one side.
- A live trace that inventoried no process is reported inconclusive and never as
  a pass.

### Step 6 framings

- Design link: Design Area 1, `Where the comparison actually happens`, Design
  Area 5, `Two readings, both required to be conclusive`, Design Area 7, all
  four subsections, and decisions Q01, Q03 and Q09.
- Execution checklist reference: the shared checklist above.
- Host: the Debian 12 Jenkins agent. This is the row that cannot be answered
  anywhere else, since the foreign distribution is the whole point.

### Step 6 complexity impact

One `tar -t` over the archive for the pre-install observation, one install, one
walk of the installed tree. The archive-side observation reads the table of
contents rather than extracting, so the pre-install half costs one pass over the
archive index and no unpacking.

### Step 6 feature preservation

The install itself is unchanged: `closure_verify.sh` calls `install_pkg.sh` as
any operator would and adds no argument to it. The installer-untouched grep
applies here as everywhere.

## Step 6 implementation

### Step 6 files involved

- `src/setups/env/bin/closure_verify.sh` (new, to be created), delivered to the
  Debian job by the pipeline from the resolved cplx commit.
- `src/setups/env/bin/closure_observe_live.sh` (new, to be created), delivered
  the same way.
- `ci/deliver-closure-tools.sh` (new, to be created), the pipeline step that
  places the authoritative copies in the Debian workspace at the resolved commit
  and refuses when it cannot.
- `src/setups/env/bin/closure_verify.sh` also carries the payload comparison,
  which reads the archive's embedded `tools/bin/` copies and reports whether
  they are byte-identical to the authoritative ones.
- `docs/v0.27.0/verify.closure-check.sh` (existing, to be updated).
- `docs/v0.27.0/verify.closure.step6.debian.txt` (new, capture).

### Step 6 test first

Cases from the design's `Scope` and `Evidence identity` tables:

- a directory PRESENT in the archive and ABSENT under the installed tree:
  packaging passes locally, verification refuses DIVERGENT;
- a directory present on the build account that never entered the tar:
  packaging passes, verification refuses DIVERGENT. The two cases differ only in
  where the missing side is, and both must be present, because a build-account
  claim would pass the second;
- verification unable to read the pre-install archive contents: refuses, naming
  the missing input;
- a live trace that inventoried no process: reported inconclusive;
- a valid passing result for archive A supplied with archive B: publication
  refuses, now driven by a real producer rather than a fixture;
- the candidate archive modified after verification: publication refuses,
  because the recomputed identity matches no result;
- a result present, passing and keyed to the exact archive: publication proceeds
  to step 3.

Four authority and bootstrap cases, which are the round 3 additions:

- the pipeline delivery is ABSENT: the job refuses before it opens the archive,
  and never falls back to a copy found inside it;
- an embedded copy DIFFERS from the authoritative one: reported as a payload
  difference, and the run still produces its evidence from the workspace copy;
- an embedded copy is byte-IDENTICAL: still not executed, because equality makes
  the bytes equivalent and does not make a candidate-supplied script an
  independent judge;
- the archive is opened before the authoritative copy exists: the case asserts
  the ordering, since the whole bootstrap argument is that reading the archive
  must come second.

Four evidence-storage cases: a results root that is a symlink, one not owned by
the running user, and one writable by group or other are each refused before any
write; and a PARTIAL write leaves nothing at the canonical name.

Three occupancy cases: a rerun after an incomplete first attempt succeeds; a
byte-identical completed result is idempotent; and a DIFFERENT result is
retained under a timestamped conflict name and stops publication.

### Step 6 behavior

- `closure_verify_preinstall`: the declared-shape observation derived from the
  archive's table of contents, so the compared build side is what the archive
  carries rather than what the build account had.
- `closure_verify_installed`: the same observation over the installed tree.
- `closure_verify_compare`: DIVERGENT entries with the side each was seen on.
- `closure_observe_live.sh`: one named process, refusing an empty inventory.
- `closure_verify_emit`: the one artifact, written into an explicitly supplied
  RESULTS ROOT under a filename derived from the archive identity alone, and
  never derived from where the archive sits. The root is validated before any
  write: it must be a real directory, not a symlink, owned by the running user
  and not writable by group or other, and a root that fails any of those is a
  refusal rather than a warning.
- ONLY A COMPLETE RESULT EVER OCCUPIES THE CANONICAL PATH. The write goes to an
  exclusively created temporary file in the same directory and is promoted by a
  no-overwrite link, so a crashed or partial write leaves nothing at the
  canonical name and a rerun simply proceeds. This is what stops a transient
  first failure from making an archive unverifiable forever, which the
  no-overwrite rule on its own would have done.
- THREE OUTCOMES WHEN THE CANONICAL PATH IS ALREADY TAKEN, not one. A
  byte-identical completed result is IDEMPOTENT and succeeds, because a rerun
  that agrees with itself has changed nothing. A DIFFERENT result for the same
  identity is retained beside the canonical file under a conflict name carrying
  the run's timestamp, and it STOPS publication under an explicit recovery rule:
  two different results for one set of bytes means one of them is wrong, and
  which one is a human decision rather than a race. Nothing is ever silently
  overwritten.
- The artifact is a `CPLX-CLOSURE-EVIDENCE/1` record document, the contract Q10
  fixes literally beside the configuration and envelope grammars. It is
  CANONICAL BY CONSTRUCTION: the evidence document forbids comments and blank
  lines and fixes a record order, so one observation has exactly one byte
  sequence and Q06's byte comparison is a comparison of meaning rather than of
  formatting. `verdict` is DERIVED from the paired observations and the
  unexpected findings rather than asserted beside them, and a document whose
  verdict contradicts its own records is refused by the parser before
  publication ever reads it. Its six
  required records map one to one onto the fields Design Area 7 names: `archive`
  carries the identity, `config` the configuration digest, `pre` and `post` the
  two observations one record per declared candidate directory, `verdict` the
  comparison outcome, and `unexpected` one record per finding with the side it
  was seen on. `closure_evidence_parse` is the only reader of that contract, and
  Step 5's publication consumer uses that same reader.
- `closure_evidence_parse`: the shared reader. Publication opens the exact keyed
  path and nothing else: it never scans the results root, and it never derives a
  location from the archive path, because either would reintroduce the
  co-location binding Design Area 7 refuses.

### Step 6 completion criteria

- `bash docs/v0.27.0/verify.closure-check.sh --step 6` green on the Debian
  agent, with the capture retained. On any other host the suite reports
  UNANSWERED with exit 5 and names the agent, which is the refusal path Step 0
  built.
- `bash src/utils/lint_shell.sh` green.
- `rg -n 'sha256sum' src/setups/env/bin/closure_verify.sh` shows the identity
  computed over the archive file and never over an unpacked tree.
- The installer-purity and installer-untouched greps both hold.

## Step 6 addendums

### Step 6 line budget checkpoint

- `src/setups/env/bin/closure_verify.sh`: 0; below-550 safe at creation;
  deployment ceiling 650; expected 200 to 280 lines (advisory).
- `src/setups/env/bin/closure_observe_live.sh`: 0; expected 80 to 120 lines
  (advisory).

### Step 6 split guidance

Keep the live observer in its own file from the start rather than splitting it
out later: it is the only component that runs on the foreign host alone, and a
separate file is what lets the static half be read without it.

### Step 6 workflow timing readiness

`bash src/utils/lint_shell.sh && bash docs/v0.27.0/verify.closure-check.sh --step 6`

### Step 6 time-gated status

No perf gates are affected.

---

## Step 7 analysis and intent

### Step 7 issues

- The D10 policy is decided and its interface is designed, but nothing
  implements either, so the umbrella's item 7 has no contract to produce
  evidence against.
- No acceptance run exists. The issue requires a positive result on the
  distribution the defect exists on, plus one negative control per independent
  invariant, and a gate nobody has seen fail is a gate nobody has seen.
- The project documentation says nothing about the checker, the configuration or
  the waiver contract.

### Step 7 fix intent

- Implement the D10 evidence shape and the policy that consumes it: requirements
  from the archive, capabilities from both candidate generations, the lowest
  satisfying candidate, and the convergence rule on re-read.
- Run the acceptance: the packaging check on the build account, and the archive
  resolving with no host fallback on Debian 12, reported from a listing over the
  whole scope and a live trace naming the process it inventoried.
- Add the wiki and reference documentation for the checker and its
  configuration.

### Step 7 expected outcome

- The policy returns GCC 11 when its capability entry defines every required
  node, GCC 12 when only that entry does, and fails when neither does.
- A second reading returning anything other than the same candidate fails as
  non-convergent, in all three shapes.
- A consumer set of zero is reported inconclusive and never as satisfaction.
- The acceptance captures exist for both hosts, and the unmodified archive
  passes rule 1, which is the positive control.

### Step 7 framings

- Design link: Design Area 6, all three subsections, Design Area 5, `Controls,
  one per independently refusable invariant`, and decision Q08.
- Execution checklist reference: the shared checklist above.
- Host: both. The policy cases are host-independent; the acceptance is not.

### Step 7 complexity impact

The policy is a set comparison over the required nodes and two capability
entries. The consumer set is filtered from records the Step 3 walk already
collected, so the evidence costs no additional walk.

### Step 7 feature preservation

This is the last step that adds production code, so it is where the whole
surface is re-read against the issue's acceptance rather than against its own
step. Every earlier step suite runs again in the same cycle.

## Step 7 implementation

### Step 7 files involved

- `src/setups/env/bin/closure_d10.sh` (new, to be created).
- `docs/v0.27.0/verify.closure-check.sh` (existing, to be updated).
- `wiki/reference/toolchain-runtime-closure.md` (new, to be created).
- `wiki/explanation/why-the-archive-declares-its-own-scope.md` (new, to be
  created).
- `docs/v0.27.0/verify.closure.step7.rhel.txt` (new, capture).
- `docs/v0.27.0/verify.closure.step7.debian.txt` (new, capture).

### Step 7 test first

Cases from the design's `The D10 interface` table, all nine rows, including the
three non-convergent shapes and the zero-consumer inconclusive result. The three
non-convergent rows are separate cases rather than one, because they fail for
three different reasons and a single case would assert only the one it happened
to plant.

Acceptance cases beside them, larger than the per-step suites:

- the packaging check passes on the build account over the real tree, with every
  refusal it produces named. `tools/old/py3.13` is expected to refuse until the
  root leaves the loader scope, and clearing it is an OPERATOR PREREQUISITE
  rather than a step of this implementation. The order is fixed: an operator
  lists the exact directory on the build account, confirms it is the superseded
  interpreter root and not a live one, MOVES it out of `$HOME/tools` to a
  retained location on the same account, and re-runs the observed scope to
  confirm the root is gone. No script in this effort removes it, no step deletes
  a directory on a live account on its own authority, and the acceptance records
  the operator action and its retained location. If the operator instead decides
  on deletion, that decision is recorded explicitly before the acceptance runs;
- the packaged archive resolves with no host fallback on Debian 12, reported
  from a listing over the whole scope AND a live trace naming the venv process;
- the unmodified archive passes rule 1 over its 20 multi-candidate names, which
  is the positive control that a rule 1 refusing too much would fail and nothing
  else would catch;
- one negative control per independently refusable invariant, which is the
  issue's nine plus the four this design adds: an unexpected directory or root,
  a divergent presence comparison, a configuration digest publication did not
  resolve, and a coherence answer that survives a rule 1 refusal.

### Step 7 behavior

- `closure_d10_evidence`: the four-field reading, with the consumer set bound to
  this design's subject rule so the compiler question is asked about the whole
  archive.
- `closure_d10_policy`: the lowest satisfying candidate, or the failure, with
  zero spare nodes allowed.
- `closure_d10_converge`: the re-read comparison, failing on higher, lower and
  neither.

### Step 7 completion criteria

- `bash docs/v0.27.0/verify.closure-check.sh` green end to end on the Debian
  agent, and green for every host-independent step on RHEL.
- `bash src/utils/lint_shell.sh` green.
- Both acceptance captures retained, each naming the host and the date.
- `rg -n 'toolchain-runtime-closure|closure_check' wiki/` finds the reference
  and explanation pages.
- The installer-purity and installer-untouched greps both hold.

## Step 7 addendums

### Step 7 line budget checkpoint

- `src/setups/env/bin/closure_d10.sh`: 0; below-550 safe at creation; expected
  120 to 180 lines (advisory).
- Every shipped script is counted again here and recorded in the validation
  document, since this is the last step that adds production code.

### Step 7 split guidance

None expected. If a shipped script is above 650 at this point, it did not take
the split its own step named, and the repair is that split rather than a new
boundary invented here.

### Step 7 workflow timing readiness

`bash src/utils/lint_shell.sh && bash docs/v0.27.0/verify.closure-check.sh`

### Step 7 time-gated status

No perf gates are affected. The acceptance is the last gate, and it is a
correctness gate rather than a timing one.

## Open questions for the v0.27.0 toolchain-runtime-closure implementation plan

### Q01: what is delivered where, which copies may produce evidence, and how many modules exist

Question description: three rounds have each found a different defect here.
Round 1: four files were called the deployment contract while seven scripts
exist. Round 2: the evidence-producing verifier was staged inside the candidate
archive, so the archive certified itself, with no bootstrap before extraction.
Round 3: the topology claimed to be fixed at Step 1 while four modules were
still conditional, `closure_elf.sh` and `closure_rules.sh` created only if a
measured budget required them and `closure_scope.sh` and `closure_config.sh`
held in reserve without appearing in the table. A topology that can still change
is not a contract.

#### BBQ for Q01

A courier firm with a manifest. Round 1 was writing the manifest after the vans
loaded. Round 2 was letting the crate supply its own inspector. Round 3 is the
manifest that says "three boxes, or possibly five, we will see on the day". In
this picture: the boxes are the shipped scripts, the crate's inspector is an
embedded verifier producing evidence about its own archive, and the see-on-the-
day clause is a split guidance that leaves the module set open.

#### Options for Q01

- Option A1: fix the checker core boundary at Step 1 and let each later step
  declare its own delivery.
  - pro: each step decides with its code in hand.
  - con: it is how the round 2 defect got in, because no step owned the question
    of where the verifier comes from.
- Option A2: fix the whole topology at Step 1, with every script travelling in
  the archive except the two publication-deciding ones.
  - pro: one staging mechanism.
  - con: the round 2 defect. The verifier comes out of the artifact it judges,
    and no bootstrap exists before extraction.
- Option A3: authoritative against payload, with the module set left to a
  measured split at Steps 3 and 4.
  - pro: the trust boundary is right.
  - con: the round 3 defect. The table and the steps disagree, and the
    deployment contract is not knowable until Step 4 runs.
- Option A4: authoritative against payload, with FOUR checker modules created
  UNCONDITIONALLY at Step 1, each carrying its contract comment and filled by
  the step that owns its responsibility, and no conditional module anywhere.
  `closure_check.sh` owns the entry point, run order, scope and report;
  `closure_config.sh` the grammar, digest, envelope and resolution;
  `closure_elf.sh` the reader and the provider index; `closure_rules.sh` ALL
  FOUR INVARIANTS, the derived membership half included, plus the waivers and
  the UNDETERMINED producer. NINE production scripts exist in total, the four
  checker modules plus `closure_verify.sh`, `closure_observe_live.sh`,
  `closure_publish.sh`, `closure_d10.sh` and `ci/deliver-closure-tools.sh`, the
  last being the pipeline step that places the authoritative copies and is
  therefore the one script that cannot be delivered by them. ALL FOUR checker
  modules are also staged into the archive as payload copies.
  - pro: the table, the files-involved lists, the budgets and the boundaries all
    say the same thing, and a module that would exceed 650 moves a
    responsibility rather than inventing a fifth file.
  - pro: `closure_scope.sh` disappears, because scope belongs with the run order
    that consumes it, and `closure_config.sh` becomes real, because publication
    needs it without the invariants.
  - pro: one owner for every invariant, so Step 3 puts derived membership in
    `closure_rules.sh` beside the other three rather than in the orchestrator,
    and an implementer has one boundary to follow rather than two.
  - pro: the authoritative copies are delivered by the pipeline from the exact
    resolved cplx commit; the embedded copies are payload for operator use.
  - con: four files exist with contract comments only for one or two steps.
- Option A5: ship nothing in the archive, so there are no embedded copies.
  - pro: the simplest rule.
  - con: an operator with an installed tree and no cplx access has no checker.

#### Recommended option for Q01

Option A4. Rounds 1 to 3 each removed one way for the topology to be less than a
contract, and this is the last of them: the module set is now knowable before
any code is written, and every step's own lists agree with it.

#### Answer to Q01: option A4 (with reason why it must be accepted as the answer)

Option A4. The conditional splits were a hedge against a budget, and the hedge
cost more than it saved: it made the deployment contract unknowable and it made
three steps describe a shape the table denied. Fixing four modules with named
responsibilities settles the budget question too, since each module now has one
job and a reason to stay small.

### Q02: how the checker obtains the observed loader scope, and what happens when that fails

Question description: the checker must not reimplement `build_elf_rpath`, so it
calls the installer's own function. Sourcing `install_pkg.sh` pulls in its
`echos` resolution and its fallback `task`, `info`, `ok`, `warning`, `error` and
`fatal` definitions, and that `fatal` calls `exit`. Round 1 added the half the
first version left out: a failure of the source or of the call must become a
typed result rather than an uncaught status or a terminated process. Round 2
accepted the answer and asked for one more case, which is now in the option.

#### BBQ for Q02

Borrowing a neighbour's tape measure. Moving into their shed to use it brings
their radio and a light switch wired to yours. Beyond that, if the tape snaps
mid-measurement you still have to write something in the column, and "the tape
snapped" is a different entry from "the wall is four metres". In this picture:
the tape is `build_elf_rpath`, the shed is the sourced installer, the shared
light switch is the inherited `fatal` that exits, and the column entry is the
checker's typed result for a measurement it could not take.

#### Options for Q02

- Option B1: source `install_pkg.sh` into the checker process.
  - pro: one definition of the observed scope, and a proven seam.
  - con: the inherited `fatal` can exit the checker, which is fatal to a design
    that requires every invariant to be evaluated and reported.
- Option B2: call it in a status-tested command substitution in a subshell,
  capture its diagnostics, map a source or call failure onto the checker's typed
  UNDETERMINED result, and carry a case that drives a sourced `fatal` and a
  non-zero return to prove the outer aggregate report continues and completes.
  - pro: one definition, no inherited state, and no inherited `exit`.
  - pro: the failure becomes an UNDETERMINED naming the input it lacked, which
    is the aggregation rule Design Area 5 already fixes for every other input.
  - pro: the case is what proves the containment rather than asserting it.
  - con: one extra process per run, and the substitution must be written in a
    tested context rather than assigned bare.
- Option B3: add a read-only `--print-scope` mode to `install_pkg.sh`.
  - pro: an explicit contract.
  - con: it edits the installer, which three completion criteria forbid, and it
    changes an argument surface item 2's harness asserts.
- Option B4: reimplement with an equality case.
  - pro: no coupling.
  - con: two derivations that agree today, the failure the design names.

#### Recommended option for Q02

Option B2, with the error contract and the proving case both inside the option.
The subshell keeps the single definition and removes the inherited `exit`; the
typed mapping stops a failed call from being read as an empty scope, which would
make every declared directory look UNEXPECTED.

#### Answer to Q02: option B2 (with reason why it must be accepted as the answer)

Option B2. An empty scope and an unavailable scope are different facts, and the
checker already has a vocabulary for the second. The added case is what turns
"an inherited `fatal` cannot abort the report" from a claim into an assertion.

### Q03: which ELF reader the checker uses, and how an unavailable reading is typed

Question description: the checker reads dynamic entries and version needs with
`readelf -d -V`, once per object. Round 1 added the locale pin and the
fail-closed rule. Round 2 corrected the RESULT VOCABULARY: the first version
called an unavailable reading a REFUSAL, and under the settled aggregation rule
it is an UNAVAILABLE INPUT, which is UNDETERMINED. The distinction is not
cosmetic. A refusal says the archive is wrong; an undetermined says the reading
could not be taken, and conflating them would contradict Q02 and Step 4.

#### BBQ for Q03

Reading a label with a scanner. Three things go wrong: the scanner is missing,
the printer switched to another language so the scanner reads nothing where a
code used to be, and the inspector writes "fine" instead of "not inspected". A
fourth is subtler: writing "this part is faulty" when what happened is that the
scanner was flat. In this picture: the scanner is `readelf`, the other language
is a translated locale changing the field labels the parser matches, "fine" is a
production gate treating an unobtainable reading as a pass, and "this part is
faulty" is typing a missing input as a semantic refusal.

#### Options for Q03

- Option C1: `readelf` only, pinned to `LC_ALL=C`, with an absent, non-zero or
  unparsable reader producing an UNDETERMINED result that names the object and
  the missing input, and the aggregate run non-passing because an UNDETERMINED
  never counts toward a green. `UNANSWERED` with exit 5 stays a harness outcome
  for a host that cannot execute a case.
  - pro: one reader, and version needs come free with `-V`.
  - pro: the vocabulary matches the settled aggregation rule, so no reader in
    the pipeline has to reconcile two meanings of a refusal.
  - pro: publication remains impossible either way, since a non-passing run
    produces no passing evidence.
  - con: a future agent image without binutils cannot run the verification half.
- Option C2: `readelf` with an `od` fallback.
  - pro: runs anywhere the installer runs.
  - con: two readers to keep in agreement, the largest body of Bash in the
    effort, and no rule for which answer wins when they differ.
- Option C3: `od` only.
  - pro: no new host tool anywhere.
  - con: a `DT_VERNEED` walk in pure Bash, large and hard to review, written for
    a host nobody has.
- Option C4: `readelf` only, with the dependency pushed into the umbrella's
  agent-tools item.
  - pro: the dependency becomes owned rather than assumed.
  - con: it adds a requirement to an item this plan does not own.

#### Recommended option for Q03

Option C1 with the corrected vocabulary. The three outcomes are then distinct and
each is used exactly once: UNDETERMINED for an input the run could not obtain,
REFUSAL for an archive that is wrong, and UNANSWERED for a host that could not
execute a case at all.

#### Answer to Q03: option C1 (with reason why it must be accepted as the answer)

Option C1. A pinned locale removes a failure that would look like an archive with
no dependencies, which passes every invariant and is the most dangerous shape a
reader can produce. Typing the failure as UNDETERMINED keeps the aggregation rule
consistent while producing the same practical outcome, a non-passing run that
cannot be published.

### Q04: where the configuration bundle lives, and what staging owes

Question description: the document is committed at
`src/setups/env/closure/closure-config.txt` and travels in the archive. Round 1
corrected two things: the archive path is a FIXED LOCATION rather than a mirror,
since the two paths differ, and staging needs its own contract. Round 2 added
the authority half: the bytes staged must come from the exact resolved commit
rather than from whatever the working tree happens to hold, and persistence on a
successful run must be stated beside the cleanup on a refusal.

#### BBQ for Q04

Posting a contract with a parcel. Naming the pocket it goes in, checking the
pocket before the van leaves, and refusing to send when the contract is missing
are all agreed. What round 2 added is which copy of the contract goes in: the
one the lawyers signed, not the marked-up draft on the desk. In this picture: the
signed copy is the file at the resolved commit, the marked-up draft is the
working tree, and the pocket is the fixed archive path.

#### Options for Q04

- Option D1: two files at the fixed archive path `tools/closure/`, staged from
  the exact resolved commit rather than from the working tree, every destination
  byte verified against that source before the tar, any failure a pre-tar
  refusal, the staged files persisting on a successful run because that is what
  puts them in the archive, and removed on a refusal.
  - pro: two files keep the envelope outside the digest domain by construction,
    with no exclusion rule to implement or to get wrong.
  - pro: the archive path is one literal, stated once, so the agent and
    publication read the same place.
  - pro: staging from the commit means a dirty working tree cannot ship a
    declaration nobody reviewed, which is the same authority argument Design
    Area 3 makes for publication.
  - con: it adds a directory to the archive root the installer walks.
- Option D2: one file with the envelope as a header the digest excludes.
  - pro: one file to stage and read.
  - con: the digest domain becomes "the file minus some lines", the
    normalisation Design Area 3 refuses.
- Option D3: stage under `tools/etc/`.
  - pro: a conventional name.
  - con: `tools/etc` does not exist today, and it says less about what the files
    are.
- Option D4: pass them through `pkg.sh --add`.
  - pro: no change to the packaged tree layout.
  - con: `--add` ships at the archive root beside `tools`, so the bundle sits
    outside the folder it describes.

#### Recommended option for Q04

Option D1 with both round corrections inside the option: a fixed location rather
than a mirror, and the resolved commit rather than the working tree as the
source of the staged bytes.

#### Answer to Q04: option D1 (with reason why it must be accepted as the answer)

Option D1. The two-file shape is the only one where the digest domain needs no
rule, and staging from the commit closes the gap that would otherwise let a
packaging run ship a declaration that exists on one machine's disk and nowhere
in the reviewed history.

### Q05: what exact predicate enters the toolchain branch, and which callers change

Question description: round 1 refused a bundle-presence trigger, round 2
accepted the code-path answer and refused it as incomplete because the predicate
was unnamed, and round 3 found two things still missing: the four selector cases
were promised and absent from the test-first list, and no caller was named even
though `pkg.sh tools` without the new flag now refuses, which changes behavior
for whoever invokes it today.

#### BBQ for Q05

A metal detector on the vault-room door. Round 2 asked which door. Round 3 asks
the question everyone forgets: who currently walks through that door, and have
they been told the lock changed. In this picture: the door is the `pkg.sh`
argument that selects the branch, and the people walking through it are
`pkg_tools.sh`, the `pkg` dispatcher, and any consuming project that packages
`tools` through an overlay of its own.

#### Options for Q05

- Option E1: gate every target unconditionally.
  - pro: no way to package the toolchain unchecked.
  - con: it refuses payloads the check was never written for, and the outcome is
    a fork.
- Option E2: trigger on the bundle's presence.
  - pro: the check runs where a contract exists.
  - con: deleting the bundle turns the gate off.
- Option E3: an explicit `--closure-gate` flag as the only entrance, with the
  paired refusals that the flag with another target refuses and `tools` without
  the flag refuses, PLUS the caller migration stated: `pkg_tools.sh` line 18 is
  the one in-scope invocation that packages `tools` and it passes the flag; the
  `pkg` dispatcher reaches the gate through that overlay and needs no flag; and
  a consuming project that packages `tools` through its own overlay starts
  refusing on purpose until umbrella item 7 adopts the flag on the release path.
  - pro: the predicate is one literal argument, named, testable, and impossible
    to infer wrongly.
  - pro: the migration is enumerated rather than assumed, so the one behavior
    change this effort makes to an existing caller is visible before it happens.
  - pro: the four corners plus the two boundary cases are in Step 5's own
    test-first list rather than promised in prose.
  - con: `pkg.sh` gains a flag and one existing caller changes.
- Option E4: an environment opt-in, off by default.
  - pro: nothing is affected.
  - con: a gate off by default is not a gate.

#### Recommended option for Q05

Option E3 with the migration named. The refusal for `tools` without the flag is
deliberate and is the reason the caller list matters: an out-of-repository
caller that packages `tools` will refuse rather than silently produce an ungated
archive, and that is the intended behavior recorded as a cross-item handoff.

#### Answer to Q05: option E3 (with reason why it must be accepted as the answer)

Option E3. Round 3 is right that a promised case is not a case and an unnamed
caller is an unplanned break. Naming `pkg_tools.sh` as the one file that changes,
and recording that any other `tools` packaging path refuses until item 7 adopts
the flag, turns a surprise into a decision.

### Q06: where the evidence artifact is written, and what happens when the path is taken

Question description: verification produces one result keyed by the archive
identity, and publication must find it without co-location. Round 1 added atomic
write, an existing-result rule and one shared parser. Round 2 found that the
existing-result rule as written was too blunt: a transient or inconclusive first
verification would occupy the canonical path and make a valid rerun impossible
forever. It also asked for the root's ownership and anti-symlink permissions.

#### BBQ for Q06

A lab files results and a warehouse releases pallets only for pallets that have
one. The filing rule needs more than a drawer and a batch number: nobody may file
a half-written sheet, filing the same sheet twice is not an error, two DIFFERENT
sheets under one batch number is a serious finding rather than an overwrite, and
a clerk who fainted mid-sheet must not lock that batch out of the system for
good. In this picture: the drawer is the results root, the batch number is the
archive SHA-256, the half-written sheet is a crashed writer, and the locked-out
batch is an archive nobody can ever verify again.

#### Options for Q06

- Option F1: an explicitly supplied results root, validated as a real directory
  that is not a symlink, owned by the running user and not group or other
  writable; a filename derived from the archive identity alone; an exclusively
  created temporary file promoted by a no-overwrite link, so ONLY A COMPLETE
  RESULT ever occupies the canonical path and a crashed run leaves nothing to
  clean up; a byte-identical completed result treated as IDEMPOTENT; a DIFFERENT
  result retained beside it under a timestamped conflict name and STOPPING
  publication under an explicit recovery rule; and one shared schema and parser
  at both ends.
  - pro: publication opens one computed path and never scans or derives a
    location from the archive.
  - pro: a partial write is never visible, and a failed first attempt does not
    make the archive permanently unverifiable.
  - pro: two different results for one set of bytes become a finding a human
    resolves, rather than a race whose winner is whoever wrote last.
  - pro: the byte comparison is a comparison of MEANING, because Q10 makes the
    evidence document canonical by construction: no comments, no blank lines,
    one record order. Two equivalent results cannot become a conflict because
    their formatting differs.
  - con: one more parameter on both entry points, and a conflict path to
    document.
- Option F2: one appended results file, scanned for a matching identity.
  - pro: one file to move between hosts.
  - con: a scan rather than a lookup, and concurrent writers interleave.
- Option F3: beside the archive, named after it.
  - pro: nothing to configure.
  - con: co-location, which the design rejects as a binding.
- Option F4: leave it to umbrella item 7.
  - pro: publication is item 7's work.
  - con: Step 5 implements the consumer inside this effort.

#### Recommended option for Q06

Option F1 with the recovery and permission semantics inside the option. The
identity is computed by both sides, so the lookup is a path join; everything else
exists to stop a reader seeing something that is not a complete, unique,
trustworthy result, and to stop one bad run from being permanent.

#### Answer to Q06: option F1 (with reason why it must be accepted as the answer)

Option F1. Round 2's objection is the one that matters operationally: a gate that
can be permanently jammed by a crashed run is a gate people learn to work around.
Complete-only occupancy plus idempotency plus a retained conflict keeps the
no-silent-overwrite property while leaving a way forward.

### Q07: how the harness produces ELF fixtures with real dynamic sections

Question description: Steps 3 and 4 need objects with real `DT_NEEDED`,
`DT_SONAME` and `DT_VERNEED` entries, including deliberately broken ones,
without committing binaries. Round 1 of the review accepted the donor-mutation
approach and added that the donor must be validated before it is mutated, so an
unsuitable host donor becomes an UNANSWERED rather than a checker failure.

#### BBQ for Q07

Testing an inspection line needs faulty parts. Taking a good part off the shelf
and damaging it in a known way is the cheap route, but if the shelf part is the
wrong model the damage lands somewhere else and the line reports a fault that is
the fault of the fixture. In this picture: the line is the checker, the shelf
part is the donor object on the host, the wrong model is a donor of the wrong ELF
class or missing the section the mutation targets, and the fixture's own fault is
a red case nobody can distinguish from a real finding.

#### Options for Q07

- Option G1: mutate donor objects found on the host, as item 2's harness already
  does, after validating the donor's ELF class and section shape, recording the
  mutation, and asserting the mutated semantic result.
  - pro: the mechanism is proven in this repository and its captures are
    retained.
  - pro: an unsuitable donor becomes UNANSWERED, so a fixture defect can never
    be read as a checker defect.
  - con: it needs a donor on the host.
- Option G2: assemble each fixture from committed hex.
  - pro: no donor needed.
  - con: a hand-built version-need section is a large amount of committed hex
    nobody will review, and an error in it looks like a checker defect.
- Option G3: compile fixtures with the host toolchain.
  - pro: real objects, easy to express.
  - con: it makes a compiler a harness prerequisite on both hosts.
- Option G4: commit binary fixtures.
  - pro: reproducible everywhere.
  - con: the plan states that nothing binary enters the repository, and both
    earlier items held that line.

#### Recommended option for Q07

Option G1 with donor validation. The corpus stays reviewable because the text
describes the mutation rather than the object, and the validation turns the one
failure mode that would confuse a reader into the refusal path Step 0 already
builds.

#### Answer to Q07: option G1 (with reason why it must be accepted as the answer)

Option G1. It satisfies the plan's own commitments, a text corpus and no
binaries, without asking for a compiler, and the added validation removes the
only way a fixture could produce a false finding.

### Q08: whether the Debian verification step should precede the packaging gate

Question description: Step 5 asserts publication's evidence check against a
fixture and Step 6 asserts it again against the real producer. Round 1 of the
review accepted the ordering and asked for two things the first version left
implicit: both ends must use one schema and one parser, and the Step 5
assertion must be named for what it is.

#### BBQ for Q08

Fitting a lock before the key exists. Carving a blank to prove the mechanism
turns is reasonable, as long as the blank is cut to the same specification the
real key will be, and as long as nobody records "the door opens" on the strength
of it. In this picture: the lock is publication's evidence check, the real key is
Step 6's artifact, the blank is Step 5's fixture, and the false record is calling
a consumer-contract test an end-to-end verification.

#### Options for Q08

- Option H1: keep the order. Step 5 is a CONSUMER-CONTRACT test against a
  fixture built with the shared schema and read by the shared parser; Step 6 is
  the producer assertion.
  - pro: the packaging gate, which is the issue's central requirement, lands
    without waiting on the agent.
  - pro: the fixture pins the artifact's schema before a producer exists, so
    Step 6 writes to a contract instead of inventing one.
  - con: the same cases are asserted twice, once against each end.
- Option H2: swap them, verification first.
  - pro: every publication case is asserted once, against a real artifact.
  - con: the Debian agent becomes a prerequisite for the packaging gate.
- Option H3: split publication into a step after verification.
  - pro: one assertion, packaging gate still early.
  - con: it separates the publication waiver refusal from the waiver contract
    Step 5 owns.

#### Recommended option for Q08

Option H1, with the Step 5 assertion named a consumer-contract test in the plan
and the shared schema and parser stated as the thing both ends hold in common.
The double assertion is the point rather than the cost: it is what makes the two
halves agree by construction.

#### Answer to Q08: option H1 (with reason why it must be accepted as the answer)

Option H1. The ordering was right and its justification was missing. Naming the
first assertion correctly prevents the one real risk the review identified,
which is a reader taking a fixture-driven case as evidence that verification and
publication have been exercised together.

### Q09: how the undeclared `tools/old/py3.13` root is cleared before acceptance

Question description: the measured tree carries a third tool root on the rpath of
every relocated ELF, and Design Area 1 makes it an unwaivable refusal. Round 1 of
the review accepted that the repair is removal rather than declaration, and
refused the first version's framing, which left the repair to whoever ran the
acceptance and did not say that it touches a live account.

#### BBQ for Q09

Scaffold left up after the building is finished. Taking it down is right. Taking
it down is also not something you let the inspection robot do on its own at three
in the morning: someone looks at it, confirms it is the old scaffold and not the
one holding the roof, and takes it to the yard rather than to the skip. In this
picture: the scaffold is `tools/old/py3.13`, the inspection robot is the
implementation workflow, the yard is a retained location on the same account, and
the skip is an irreversible delete.

#### Options for Q09

- Option J1: an operator prerequisite. An operator lists the exact directory,
  confirms it is superseded, moves it out of `$HOME/tools` to a retained
  location on the same account, and re-runs the observed scope to confirm. The
  action and the retained location are recorded, and deletion happens only on an
  explicitly recorded decision.
  - pro: the observed scope then matches the declared shape, and no superseded
    interpreter root sits on the rpath of every shipped object.
  - pro: `pkg.sh` already excludes `old` from the tar, so removal aligns the
    installed tree with what is shipped rather than changing what is shipped.
  - pro: it is recoverable, and no script deletes a live account directory.
  - con: the acceptance cannot run until an operator acts.
- Option J2: declare it as a fourth root.
  - pro: no operations action.
  - con: it declares as scope a root the archive does not contain, so a floor
    member found only there would satisfy the floor on the build account and be
    absent from the archive. That is the failure the floor exists to catch.
- Option J3: an implementation step removes it.
  - pro: the acceptance is unblocked without waiting.
  - con: a recursive delete of a live account directory on the workflow's own
    authority, for a path nobody inspected first.
- Option J4: leave the repair to whoever runs the acceptance.
  - pro: flexible.
  - con: the repairs are not equivalent, so this leaves a correctness decision
    to a run, and it hides that one of them is destructive.

#### Recommended option for Q09

Option J1. Removal is the right repair and an operator is the right actor. The
recoverable move is what makes the prerequisite safe to state as a step of the
acceptance rather than a risk taken during it.

#### Answer to Q09: option J1 (with reason why it must be accepted as the answer)

Option J1. J2 widens the contract to fit the defect and reintroduces the shape
the floor refuses. J3 and J4 differ only in who performs an unreviewed delete.
J1 keeps the correct repair and puts a human, an inspection and a recoverable
destination in front of it.

### Q10: what grammar the three record documents use

Question description: round 1 found the grammar missing, round 2 found the first
answer describing properties rather than defining one, round 3 found the literal
grammar covering only the configuration document, and round 4 found the evidence
grammar introducing two path placeholders with no lexical domain, no
decode-versus-validate order, and no ordering, duplicate or cardinality rules
for its repeated records. Two conforming producers could still disagree on what
one evidence document means.

#### BBQ for Q10

Two firms comparing photocopies, agreeing on columns, agreeing on the second
page and the covering letter, and then discovering that the covering letter has
a repeating line item with no rule about order, no rule against listing the same
item twice, and no statement of which catalogue the item codes come from. In
this picture: the covering letter is the evidence document, the repeating line
item is `pre`, `post` and `unexpected`, and the catalogue is the declared
candidate set the configuration fixes.

#### Options for Q10

- Option K1: three literal grammars, one shared lexical shape, one parser each,
  all fail-closed.

  Shared shape, used by all three: a version line first, one record per line,
  fields separated by `|`, no empty field,
  `%7C` for a literal `|` and `%25` for a literal `%` with any other `%`
  sequence a refusal, an unknown record token a refusal, and a known token with
  the wrong field count a refusal. DECODING PRECEDES DOMAIN VALIDATION, and the
  order is stated because reversing it is a defect: validating first would let
  `%2F` pass a no-slash domain check and become a separator afterwards.

  `#` COMMENT LINES AND BLANK LINES ARE IGNORED IN THE CONFIGURATION AND THE
  ENVELOPE, WHICH HUMANS AUTHOR, AND REFUSED IN THE EVIDENCE, WHICH ONLY A
  MACHINE WRITES. Q06 compares evidence documents byte for byte to decide
  idempotency, so an ignored comment would make two equivalent results conflict.

  Configuration, `CPLX-CLOSURE/1`:

  ```text
  root|<root-name>
  subdir|<root-name>|<subdir-name>
  floor|<lookup-name>|<location>
  family|<family-name>|<soname-glob>|<generations>
  waiver|<lookup-name>|<owning-requirement>
  ```

  Envelope, `CPLX-CLOSURE-ENVELOPE/1`, staged beside the configuration and
  outside its digest:

  ```text
  digest|<sha256>
  source|<repo-path>|<commit>
  ```

  Evidence, `CPLX-CLOSURE-EVIDENCE/1`, produced by verification and read by
  publication:

  ```text
  archive|<sha256>
  config|<sha256>
  pre|<candidate-path>|present
  post|<candidate-path>|absent
  verdict|pass
  unexpected|installed|<observed-path>
  ```

  Lexical domains, each exact, applied to the DECODED value:

  | Placeholder | Domain |
  | --- | --- |
  | `<root-name>` | ONE segment, `[A-Za-z0-9._+-]{1,64}`, never `.` or `..`, no `/` |
  | `<subdir-name>` | the same domain, ONE segment, so `current` and `python-3.13.9` are legal and `a/b` is not |
  | `<lookup-name>` | `[A-Za-z0-9._+-]{1,128}`, no `/`, the exact `DT_NEEDED` string |
  | `<location>` | the literal `any`, or exactly `tools/<root-name>` with a declared root |
  | `<family-name>` | `[a-z0-9-]{1,64}` |
  | `<soname-glob>` | the `<lookup-name>` domain plus at most one `*` |
  | `<generations>` | `[1-9][0-9]{0,2}`, no sign, no leading zero |
  | `<owning-requirement>` | `[a-z0-9-]{1,64}` |
  | `<sha256>` | exactly 64 characters of `[0-9a-f]`, LOWERCASE ONLY |
  | `<commit>` | exactly 40 characters of `[0-9a-f]`, so a short SHA, a branch or a tag refuses |
  | `<repo-path>` | 2 to 8 segments, each in the `<root-name>` character class extended with `/` as the separator only, relative, no leading `/`, no `.` or `..`, no empty segment, no trailing `/` |
  | `<candidate-path>` | 3 to 5 segments under the same rule, first segment literally `tools`, second a DECLARED root name, and the whole path a MEMBER OF THE DECLARED CANDIDATE SET derived from the configuration named by `config` |
  | `<observed-path>` | 2 to 6 segments under the same rule, first segment literally `tools`, and DELIBERATELY NOT required to be in the declared set, since an unexpected directory is precisely one that is not |

  Configuration rules: ordering is significant for `root` only, where it is the
  loader's order and `python` must come first; duplicate keys refuse, the keys
  being `root` name, `subdir` pair, `floor` name, `family` name and glob pair,
  and `waiver` member; a `family` name in several records carries the same
  `<generations>` in each; cross-references are validated at parse time, so a
  `subdir` root must be declared, a `waiver` member must be on the floor, and a
  `location` other than `any` must name a declared root.

  Envelope rules: exactly one `digest` and exactly one `source`, so a missing or
  repeated record refuses.

  Evidence rules, which round 4 asked for and the first version omitted:

  - CARDINALITY: exactly one `archive`, one `config` and one `verdict`; exactly
    one `pre` and exactly one `post` FOR EVERY member of the declared candidate
    set, no more and no fewer, so a missing observation refuses rather than
    reading as an absence; zero or more `unexpected`.
  - CANONICAL ORDER, and out of order refuses: `archive`, `config`, every `pre`
    in ascending byte order of its path, every `post` in the same order,
    `verdict`, then every `unexpected` ordered by side then path. A canonical
    order makes two producers byte-identical for one observation and makes two
    documents diffable, which is what a human comparing a conflict needs.
  - DUPLICATES: two `pre` or two `post` records naming one path refuse, and two
    `unexpected` records with the same side and path refuse.
  - CROSS-REFERENCE: the set of `pre` paths, the set of `post` paths and the
    declared candidate set derived from the configuration whose digest `config`
    names must be EQUAL. A path in one and not the others refuses.
  - FIELD VOCABULARIES: `verdict` is `pass` or `divergent`; the third field of
    `pre` and `post` is `present` or `absent`; the second field of `unexpected`
    is `archive` or `installed`.
  - VERDICT IS DERIVED, NOT ASSERTED, and the truth table is exact. Over a
    document that is otherwise valid:

    | Every `pre` and `post` pair agrees | Any `unexpected` record | Derived verdict |
    | --- | --- | --- |
    | yes | no | `pass` |
    | yes | yes | `divergent` |
    | no | no | `divergent` |
    | no | yes | `divergent` |

    `pass` is the single row where the observations agree and nothing
    unexpected was seen, and `divergent` IS THE COMPLEMENT of `pass`, which is
    what gives unexpected-only evidence a verdict at all. Round 6 found that
    gap: the earlier wording made `pass` require no unexpected record and made
    `divergent` require a differing pair, so a document with agreeing pairs and
    an unexpected finding had no valid verdict. THE PARSER DERIVES THE VERDICT
    FROM THE RECORDS AND REFUSES A SERIALIZED `verdict` THAT DIFFERS, on both
    ends, so publication is never the first reader to check it.
  - AN `unexpected` PATH MUST BE OUTSIDE THE DECLARED CANDIDATE SET, and one
    inside it refuses. A declared directory is by definition expected, so a
    document claiming otherwise describes something that cannot be true.
  - CANONICAL BYTES, stated at the byte level because Q06 compares bytes: the
    evidence document is UTF-8, uses LF line endings and never CRLF, carries
    EXACTLY ONE final newline after its last record, contains no comment lines
    and no blank lines, and holds its records in the canonical order above.
    Those five rules together, not the ordering alone, make one observation into
    exactly one byte sequence.

  Valid configuration example:

  ```text
  CPLX-CLOSURE/1
  root|python
  root|git
  subdir|python|root
  subdir|python|current
  floor|libc.so.6|any
  floor|libsqlite3.so.0|tools/python
  family|binutils-bfd|libbfd-*.so|1
  waiver|libsqlite3.so.0|python-sqlite-support
  ```

  Valid evidence example, for a declared candidate set of two directories:

  ```text
  CPLX-CLOSURE-EVIDENCE/1
  archive|0f1e2d3c4b5a69788796a5b4c3d2e1f00f1e2d3c4b5a69788796a5b4c3d2e1f0
  config|1a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f809
  pre|tools/python/current/lib|present
  pre|tools/python/root/lib64|present
  post|tools/python/current/lib|present
  post|tools/python/root/lib64|absent
  verdict|divergent
  unexpected|installed|tools/old/py3.13
  ```

  Invalid records, one refusal each. Configuration: `root|python|extra` wrong
  field count; a second `root|python` duplicate key; `root|py/thon` a slash in a
  one-segment domain; `subdir|perl|root` undeclared root;
  `floor|libfoo.so|/usr/lib` absolute; `family|f|lib*so*|1` two wildcards;
  `family|f|lib*.so|01` leading zero; `waiver|libfoo.so|req` member not on the
  floor; `mount|x` unknown token; `floor|lib%2Ffoo.so|any` undefined escape.
  Envelope: `digest|3B7C...` uppercase; `source|p|9f2c` short commit;
  `source|p|main` not a SHA; two `digest` records; no `source`. Evidence: a
  `pre` whose path is not in the declared candidate set; a `post` missing for a
  declared directory; two `pre` records for one path; `pre` records out of byte
  order; `verdict|maybe`; `unexpected|both|tools/x` an invalid side;
  `pre|tools/python/current/lib|yes` an invalid third field; `verdict|pass`
  beside a `pre` and `post` pair that differ, the CONTRADICTORY PASS;
  `verdict|pass` beside any `unexpected` record; an `unexpected` naming a path
  that IS in the declared candidate set; and a `#` comment or a blank line
  anywhere in an evidence document, which the configuration and the envelope
  permit and the evidence does not.
  - pro: nothing is left for an implementer to invent, in any of the three
    documents, including the repeated records.
  - pro: the three share one lexical shape, so there is one lexer and three
    record tables rather than three parsers.
  - pro: the canonical order and the cardinality rule make an evidence document
    a function of the observation rather than of the producer.
  - con: it is three grammars this project defines and tests rather than adopts.
- Option K2: reuse `contract.host-tools.txt` verbatim.
  - pro: nothing new to define.
  - con: those columns are specific to host tools, so the reuse is of a
    delimiter rather than a schema.
- Option K3: JSON.
  - pro: a defined grammar with existing parsers.
  - con: neither host is guaranteed a JSON parser the checker may use, and the
    checker is Bash.
- Option K4: an INI-style format.
  - pro: familiar.
  - con: INI has no agreed rule for repeated keys, which is the duplicate
    question these documents must answer.

#### Recommended option for Q10

Option K1 as written, with all three documents specified, every placeholder
carrying its domain, the decode-then-validate order stated, and the evidence
document's repeated records governed by cardinality, canonical order, duplicate
and cross-reference rules.

#### Answer to Q10: option K1 (with reason why it must be accepted as the answer)

Option K1. Rounds 2 through 5 each removed one way for two conformant
implementations to disagree about one document: the syntax, then the second and
third documents, then the placeholders, then the repeated records, and now the
MEANING. Deriving the verdict is the change that matters most, because
publication trusts a passing result and a verdict nobody checked against its own
records is exactly the shape this requirement exists to refuse. Forbidding
comments in the evidence is the small repair that keeps Q06's byte comparison
honest rather than accidental.

### Q11: how the checked bytes and the uploaded bytes are proved to be the same

Question description: round 1 found publication was evidence rather than
enforcement. Round 2 required exclusive creation, hashing after the copy and
no-overwrite promotion. Round 3 found the race that survived all of it, because
the gate returned a PATHNAME and any uploader reopening that name has the
time-of-check gap back. Round 4 accepted the descriptor shape and found it not
yet implementable: the plan said "pass the descriptor" without saying how it is
named, inherited, positioned, read once, or what happens when the callback
fails. It also refused L4 as a fallback, since an obligation in another item
cannot prove a property this item claims to deliver.

#### BBQ for Q11

A safety inspection at a loading bay. The inspector now watches the pallet being
assembled, weighs the finished pallet, and puts it in a slot nobody can
overwrite. Round 3 stopped the inspector going home and leaving a note saying
"load slot 12". Round 4 asks the next question: the inspector is handing the
pallet over in person, so exactly how, with what paperwork, standing where, and
what happens if the forklift driver drops it. In this picture: handing over in
person is the inherited descriptor, and the paperwork is the interface below.

#### Options for Q11

- Option L1: exclusive staging with a returned pathname.
  - pro: it closes the copy and promotion races.
  - con: the round 3 defect. A name is not the instance that was checked.
- Option L2: re-hash immediately before upload and compare.
  - pro: no copy.
  - con: it narrows the window rather than closing it.
- Option L3: exclusive staging, and THE GATE INVOKES A CONSTRAINED UPLOADER
  while holding the open descriptor, under this exact interface:

  | Element | Contract |
  | --- | --- |
  | opening | the gate opens the promoted file read-only exactly once, `exec {fd}< "$promoted"`, after the promotion and before publication step 1 |
  | naming | the descriptor number is passed in `CPLX_CLOSURE_ARCHIVE_FD`, and the expected digest in `CPLX_CLOSURE_ARCHIVE_SHA256`. NO PATHNAME IS PASSED AT ALL, which is what makes the no-reopen rule checkable rather than advisory |
  | inheritance | the descriptor is left inheritable, so the callback's process receives it across `exec`; the gate never marks it close-on-exec |
  | ownership and lifetime | the gate owns it: it opens before the callback, closes after the callback returns, and the callback must neither close it nor duplicate it beyond its own run |
  | offset | the gate positions the descriptor at 0 before invoking the callback, and the callback performs EXACTLY ONE PASS over it. There is no second seek and no second read |
  | hashing and streaming | the one pass feeds both, in the shape below, so the bytes hashed and the bytes streamed are the same read of the same descriptor rather than two reads that must be argued to agree |
  | verification | the callback compares its computed digest with `CPLX_CLOSURE_ARCHIVE_SHA256` and refuses on any difference, so the pass proves itself |
  | uploader operations | the callback drives four: `upload_begin` creates an object that is NOT PUBLICLY VISIBLE and prints its handle, `upload_write` consumes stdin into it, `upload_abort` destroys it leaving nothing public, and `upload_commit` makes it public atomically. THESE FOUR NAMES ARE THIS EFFORT'S ADAPTER ABI, implemented and tested here against a stub; item 7 keeps its own public API and supplies an adapter with the same lifecycle |
  | preflight | every command whose later absence could strand state is resolved BEFORE `upload_begin`: `cat`, `tee`, `mkfifo`, `sha256sum`, `mktemp`, `chmod` and `rm`. An absent one refuses before transaction-local scratch or a remote stage exists |
  | pipeline status | `set -o pipefail` is IN the flow rather than described beside it, so an independent `cat` or `tee` failure reaches `pipe_rc` instead of being masked by the last stage's success |
  | cleanup arming | the trap is armed as soon as the scratch directory EXISTS, not after `upload_begin`, so a `chmod` or begin failure cannot leak it. `stage` starts empty and the abort runs only when it is non-empty |
  | cleanup re-entry | `trap - EXIT INT TERM HUP` runs first inside the handler, so a signal arriving during cleanup cannot re-enter it and abort the same stage twice |
  | cleanup failure | if `rm -rf` fails the scratch path is named on stderr and the exit status is unchanged, because local cleanup is an operator concern and the publication verdict does not depend on it |
  | scratch state | the FIFO and digest file live in a directory created exclusively with `mktemp -d` at 0700 inside the protected staging root, so neither can be pre-existing or a symlink. Cleanup attempts removal on every exit; if removal fails, it names the retained path as specified by the cleanup-failure row |
  | abort coverage | the EXIT, INT, TERM and HUP trap is armed immediately after scratch creation and before `chmod` or `upload_begin`. It calls `upload_abort` only when `stage` is non-empty and commit has not succeeded, so every post-begin failure aborts while pre-begin failures only clean local scratch |
  | status capture under errexit | every status is captured through an or-assignment rather than read from a bare command, as the control flow below shows, so an enclosing `errexit` cannot end the run before the value is examined |
  | failure postconditions | `upload_begin` failure leaves nothing staged or public; the already-armed trap removes scratch and attempts no abort because `stage` is empty. Successful `upload_abort` leaves nothing public and no remote stage; failed abort may leave the named stage while the run still refuses. Successful `upload_commit` makes the object public atomically; failed commit leaves nothing public because cleanup aborts. An adapter whose commit can fail after publishing does not satisfy the ABI |
  | transactionality | nothing becomes public before the digest matches. Both participants are awaited and their statuses collected, the comparison happens after that, and only then does `upload_commit` run |
  | failure | any non-zero callback exit is a publication REFUSAL, and on every failure path `upload_abort` has already run, so NO PUBLIC OBJECT EXISTS. The gate does not retry, does not fall back to a path, and leaves the promoted file in place for diagnosis |

  The control flow, failure-complete:

  ```bash
  set -o pipefail
  for tool in cat tee mkfifo sha256sum mktemp chmod rm; do
      command -v "$tool" >/dev/null 2>&1 || exit 1
  done

  scratch=$(mktemp -d "$staging_root/.pub.XXXXXXXX") || exit 1
  stage=""; committed=0
  cleanup() {
      rc=$?
      trap - EXIT INT TERM HUP
      if [ -n "$stage" ] && [ "$committed" -eq 0 ]; then
          upload_abort "$stage" \
              || printf 'abort FAILED, stage %s may persist\n' "$stage" >&2
      fi
      rm -rf "$scratch" \
          || printf 'scratch %s NOT removed\n' "$scratch" >&2
      exit "$rc"
  }
  trap cleanup EXIT INT TERM HUP

  chmod 700 "$scratch" || exit 1
  fifo="$scratch/hash.fifo"; seen="$scratch/hash.out"
  stage=$(upload_begin) || exit 1

  mkfifo "$fifo" || exit 1
  sha256sum > "$seen" < "$fifo" &
  hasher=$!

  pipe_rc=0
  cat <&"${CPLX_CLOSURE_ARCHIVE_FD}" | tee "$fifo" | upload_write "$stage" \
      || pipe_rc=$?
  hash_rc=0
  wait "$hasher" || hash_rc=$?
  [ -s "$seen" ] || exit 1
  read -r digest _ < "$seen" || exit 1

  [ "$pipe_rc" -eq 0 ] && [ "$hash_rc" -eq 0 ] \
      && [ "$digest" = "$CPLX_CLOSURE_ARCHIVE_SHA256" ] || exit 1

  upload_commit "$stage" || exit 1
  committed=1
  ```

  The hasher is a BACKGROUND JOB READING A FIFO rather than a process
  substitution, because a process substitution's exit status cannot be
  collected. Each round found the next layer down. Round 5: the flow could
  finish the upload before the hasher finished, never showed the comparison, and
  dropped the hasher's status. Round 6: nothing aborted on a `mkfifo` failure,
  an interruption, a digest-read failure or a commit failure, the scratch files
  were never cleaned, and a bare status read would have been killed by an
  enclosing `errexit`. Round 7: `pipefail` was described rather than executed so
  a `cat` or `tee` failure was invisible, the trap was armed after
  `upload_begin` so a `chmod` or begin failure leaked the scratch directory, and
  a signal during cleanup could have re-entered it and aborted twice. The
  `pipefail` line, the early arming with an empty `stage`, the `trap -` disarm
  on entry, the exclusive scratch directory, the or-assignment captures and the
  `committed` flag answer those in that order.

  - pro: the bytes checked and the bytes uploaded are one read of one open file,
    and no filesystem operation between them can intervene: a mutation, unlink
    or replacement at the promoted path changes nothing.
  - pro: EVERY post-begin failure leaves no public object, not only the three
    stream failures: a setup failure, an interruption, a digest-read failure, an
    abort failure and a commit failure are all covered by the trap, so the
    property does not depend on an exit status being able to retract something
    that already happened.
  - pro: the four names are a LOCAL ADAPTER ABI rather than a demand on another
    item's public surface, so item 7 keeps its own API and supplies an adapter.
  - pro: passing no pathname turns "never reopen by path" from an instruction
    into a thing the callback cannot do.
  - pro: the single pass removes the seek question entirely, which matters
    because a shell consumer cannot reposition a shared descriptor portably.
  - pro: this item can PROVE the contract now, with a stub uploader in the
    harness, rather than waiting on another item.
  - con: it requires the real uploader to be invocable as a callback, and
    umbrella item 7 owns the real uploader.
- Option L4: item 7 opens the promoted file once and hashes and streams that one
  descriptor, with the cross-item interface owning descriptor stability.
  - pro: it works when the uploader cannot be a callback.
  - con: round 4 is right that this cannot be a fallback for a property THIS
    item claims. It is item 7's PREREQUISITE: until item 7 accepts the L3
    interface, or implements L4 in its own code, the release path does not have
    checked-byte identity, and this plan says so rather than claiming it.
- Option L5: leave enforcement entirely to item 7.
  - pro: it respects the item boundary.
  - con: a documented expectation with nothing that fails when it is not met.

#### Recommended option for Q11

Option L3 with transactional publication, the interface table and the control
flow as the deliverable, and a STUB UPLOADER in the harness that implements the
four operations and demonstrates ORDERING AND CLEANUP rather than only receipt:
it succeeds on the good path; it refuses a pathname; it still streams the
original bytes after the promoted path is mutated, unlinked and replaced; and on
a wrong expected digest, a failing hasher, a failing `cat`, a failing `tee`, a
failing `upload_write`, a preflight failure, a `chmod` failure, an
`upload_begin` failure, a setup failure, an interruption, a digest-read failure,
an abort failure and a commit failure it publishes NOTHING, asserted by asking
the stub what it has made public rather than by reading an exit status, with the
scratch directory asserted gone wherever removal succeeds. Two further cases
assert that an `upload_begin` failure attempts NO abort, since no stage exists,
and that a signal during cleanup aborts EXACTLY ONCE. L4 is item 7's
prerequisite, not this item's escape hatch.

#### Answer to Q11: option L3 (with reason why it must be accepted as the answer)

Option L3 with transactional semantics. Round 5 found the flaw the writer had
already suspected and stated: a single pass hands bytes to an uploader before
the digest is known, and no exit status can retract a public upload. The repair
is not to abandon the one-read design, which is what makes the checked bytes and
the uploaded bytes the same bytes, but to make the upload a transaction whose
commit happens after the comparison. Awaiting both participants through a FIFO
and `pipefail`, comparing, and only then committing gives both properties at
once, and the stub uploader proves the cleanup rather than asserting it.

### Q12: which copies may produce evidence

Question description: round 2 found the archive certifying itself and this
question was added to settle verifier authority. Round 3 found the first answer
contradicting itself: the topology said embedded copies are never a source of
evidence, and option M1 then allowed them to contribute evidence after a byte
comparison. Equality of bytes makes two files equivalent; it does not create a
reason to switch executables mid-verification, and it reintroduces the ambiguity
the question exists to remove.

#### BBQ for Q12

A crate with its own inspector inside. Round 2 settled that the independent
inspector does the inspection. Round 3 catches the loophole in the small print:
"unless the crate's inspector turns out to have the same credentials, in which
case either may sign". Nobody wanted that clause, and it puts the crate's
inspector back on the paperwork. In this picture: the credentials are the byte
comparison, and signing is producing evidence publication trusts.

#### Options for Q12

- Option M1: pipeline-delivered workspace copies produce ALL evidence, without
  exception. The embedded copies are payload: the authoritative copy compares
  their bytes as one more checked property of the archive and reports the
  result, and they are never executed to produce evidence, EVEN WHEN EQUAL.
  They exist for later operator diagnostics on an installed tree.
  - pro: one categorical rule, with no condition under which the judged supplies
    the judge.
  - pro: the comparison keeps its value as a payload invariant, which is what it
    was always for.
  - pro: it removes the contradiction between the topology and the answer.
  - con: an operator's embedded copy is not covered by the evidence contract, so
    its output is diagnostic only, which the plan must say plainly.
- Option M2: execute the embedded copy.
  - pro: one delivery mechanism.
  - con: the archive certifies itself, and there is no bootstrap before
    extraction. The round 2 defect, kept here so it is refused on the record.
- Option M3: execute the embedded copy after comparing its digest out of band.
  - pro: no pipeline delivery of executables.
  - con: whatever performs the comparison must itself be delivered
    authoritatively, so the problem moves rather than closes. This is also the
    round 3 contradiction in its general form.
- Option M4: ship no copies in the archive at all.
  - pro: nothing to compare, and one sentence of rule.
  - con: an operator with an installed tree and no cplx access has no checker.

#### Recommended option for Q12

Option M1 in its categorical form. The byte comparison stays, and what changes
is what it authorises: nothing. It is a property of the payload, reported like
any other, and it never promotes an embedded script to a producer of evidence.

#### Answer to Q12: option M1 (with reason why it must be accepted as the answer)

Option M1. Round 3 is right that equality is not authority. A rule with an
exception for equal bytes would have to be checked, argued about and eventually
relied on, and its only benefit was saving a delivery the pipeline performs
anyway. Categorical is both safer and shorter.
