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
bash docs/v0.27.0/verify.install-pkg.sh --step 3
bash docs/v0.27.0/verify.relocation-rpath.sh --step 0 \
     --target-capability docs/v0.27.0/capability.rhel-9.8.txt
bash docs/v0.27.0/verify.wrapper-scope.sh --step 2
bash docs/v0.27.0/verify.wrapper-accept.sh --mode identity
```

EACH COMMAND CARRIES THE ARGUMENT ITS HARNESS NEEDS, AND THE ARGUMENT-FREE FORM
IS NOT THE CONTRACT. An earlier version of this section fixed the four bare
forms instead, and step 0's first code-review round measured what they actually
return on RHEL 9.8: 2, 1, 1 and 2. None of the four is a preservation failure,
and none can be made zero without changing a frozen harness of items 1, 2 and
3, so the bare list was an UNSATISFIABLE contract rather than a stricter one:

| Bare form | Measured | Why it cannot answer |
| --- | --- | --- |
| `verify.install-pkg.sh` | 2 | its step 0 preflight refuses BY DESIGN on an installer that can select a fallback engine, and names step 1 |
| `verify.relocation-rpath.sh` | 1 | its step 0 is BLOCKED without `--target-capability`, which is the retained exact-target evidence |
| `verify.wrapper-scope.sh` | 1 | its step 0 is the PRE-CHANGE wrapper baseline, and item 3's own fix made the retained copy unmatchable by construction |
| `verify.wrapper-accept.sh` | 2 | `--mode` has no default, so the bare form is a usage error by construction |

Each harness is therefore invoked at the step it can answer TODAY, that
invocation is what the aggregate reads, and the bare status stays recorded in
the capture beside it, so a reader sees the measurement rather than a silent
substitution. THE FOURTH RUNS ON THE AUTHORING HOST AND NOWHERE ELSE: its
identity mode reads cplx history through `git`, by its own header, and neither
validation host carries a cplx checkout with history.

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
  both captures retained. BOTH HOSTS ARE THE TWO LINUX HOSTS this step declares,
  the RHEL 9.8 build host and the Debian 12 agent, per
  [reference.environments.md](reference.environments.md). The Windows authoring
  host is not one of them and cannot answer this command: it carries no
  `readelf`, no `/etc/os-release` identity and no distinct-refusal control, so a
  run there returns UNANSWERED by design rather than a result.
- `rg -n 'declare -A' docs/v0.27.0/verify.closure-check.sh` finds the gate.
- The FOUR existing harnesses are RUN INDEPENDENTLY, not inferred and not
  chained, each at the exact invocation the feature-preservation section above
  fixes: `verify.install-pkg.sh --step 3`, `verify.relocation-rpath.sh --step 0`
  with `--target-capability`, `verify.wrapper-scope.sh --step 2` and
  `verify.wrapper-accept.sh --mode identity`, each invoked on its own whatever
  the previous returned, each capture retained. The aggregate is three-way: any
  status other than 0 or 5 FAILS, any 5 with no failure returns UNANSWERED
  naming the harness, and only four zeros PASS. The argument-free form of any of
  the four is NOT the criterion, for the reason that section measures and
  tabulates.
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

## Implementation decisions for v0.27.0 toolchain-runtime-closure

The twelve questions the plan review settled across eight rounds, closed on
2026-09-04 and recorded in
[the review transcript](review.plan.v0.27.0.toolchain-runtime-closure.md). Each
row is the decision, where the plan applies it, and what was rejected with the
reason.

FIVE OF THESE ROWS EXIST BECAUSE A ROUND REFUSED AN EARLIER ANSWER, and the
refused shapes are named rather than dropped: an archive that supplied its own
verifier, a gate a deletion could switch off, a topology that stayed conditional
while calling itself fixed, a handoff that returned a pathname, and an upload
that could not be retracted once begun. Each was a plan answer before it was a
rejected alternative.

| Question | Decision | Where it applies | Alternatives rejected |
| --- | --- | --- | --- |
| Q01 | AUTHORITATIVE against PAYLOAD, with four checker modules created unconditionally at Step 1 and nine production scripts in total. The pipeline delivers the authoritative copies from the resolved cplx commit; the embedded copies are operator payload | Delivered script topology; Steps 1 to 6 files-involved, budgets and module boundaries | A1, per-step delivery decisions, which is how the round 2 defect entered; A2, everything travelling in the archive, which makes the archive certify itself and has no bootstrap; A3, the same trust boundary with a conditional module set, which left the deployment contract unknowable until Step 4; A5, no embedded copies, which strands an operator with no cplx access |
| Q02 | Call `build_elf_rpath` in a status-tested subshell, mapping a source or call failure to the typed UNDETERMINED result | Step 1 behavior and completion criteria | B1, sourcing into the checker process, whose inherited `fatal` can exit a run that must report every invariant; B3, a `--print-scope` mode, which edits the installer three criteria forbid; B4, a second derivation with an equality case, the drift the design names |
| Q03 | `readelf` only, pinned to `LC_ALL=C`, with an absent, non-zero or unparsable reader typed UNDETERMINED and the aggregate non-passing | Step 3 behavior, `closure_read_failed`; the host matrix | C2, a second `od` reader with no rule for which answer wins; C3, `od` only, the largest body of Bash in the effort written for a host nobody has; C4, pushing the dependency into another umbrella item this plan does not own |
| Q04 | Two files at the fixed archive path `tools/closure/`, staged from the exact resolved commit, byte-verified before the tar, persisting on success and removed on refusal | Step 2 files and behavior; Step 5 staging | D2, one file with a header excluded from the digest, which reintroduces the normalisation Design Area 3 refuses; D3, `tools/etc/`, a directory that does not exist and says less; D4, `--add`, which ships the bundle outside the folder it describes |
| Q05 | An explicit `--closure-gate` flag as the only entrance, with the paired refusals that the flag with another target refuses and `tools` without the flag refuses | Step 5 behavior, test-first list and files-involved; `pkg_tools.sh` line 18 | E1, gating every target, which drives a consuming project to fork; E2, triggering on the bundle's presence, which lets a deletion switch the gate off; E4, an environment opt-in, which is not a gate |
| Q06 | An explicitly supplied results root keyed by archive identity, complete-only occupancy through no-overwrite promotion, byte-identical results idempotent, a differing result retained under a conflict name and stopping publication | Step 6 behavior, `closure_verify_emit` | F2, one appended file, a scan rather than a lookup with interleaved writers; F3, beside the archive, the co-location the design refuses as a binding; F4, deferring to item 7 while Step 5 implements the consumer here |
| Q07 | Mutate donor objects found on the host, after validating the donor's ELF class and section shape and asserting the mutated semantic result | Step 0 fixture corpus; Steps 3 and 4 cases | G2, hand-built hex nobody will review; G3, a compiler as a harness prerequisite on both hosts; G4, committed binary fixtures, which both earlier items refused |
| Q08 | Keep the order: Step 5 is a consumer-contract test against a fixture, Step 6 the producer assertion, both using one schema and one parser | Steps 5 and 6 test-first lists | H2, verification first, which makes the Debian agent a prerequisite for the packaging gate the issue centres on; H3, a separate publication step, which splits the waiver refusal from the waiver contract |
| Q09 | An operator prerequisite: inspect the exact `tools/old` target, move it recoverably out of `$HOME/tools`, re-run the observed scope, record the action and the retained location | Step 7 acceptance | J2, declaring the root, which widens the contract to fit the defect and lets a floor member satisfy on the build account while absent from the archive; J3, an implementation step removing it, a recursive delete on the workflow's own authority; J4, leaving the choice to whoever runs the acceptance |
| Q10 | Three literal grammars sharing one lexical shape, `CPLX-CLOSURE/1`, `CPLX-CLOSURE-ENVELOPE/1` and `CPLX-CLOSURE-EVIDENCE/1`, with exact lexical domains, decode before domain validation, a derived verdict truth table, and canonical evidence bytes | Step 2 behavior, `closure_config_parse`; Step 6 emit and `closure_evidence_parse` | K2, reusing the host-tools columns, a delimiter rather than a schema; K3, JSON, whose parser would be the largest new component and is used by nothing else here; K4, INI, which has no agreed rule for the repeated keys these documents must settle |
| Q11 | A descriptor-bound transactional callback: exclusive staging, hash the completed copy, no-overwrite promotion, then invoke a constrained uploader with the open descriptor under a begin, write, abort, commit adapter ABI that commits only after the digest matches | Step 5 behavior and its seventeen handoff cases | L1, exclusive staging with a returned pathname, which reopens the time-of-check gap; L2, re-hashing before upload, which narrows the window rather than closing it; L4, item 7 owning descriptor stability, kept as item 7's prerequisite rather than this item's fallback; L5, leaving enforcement entirely to item 7 |
| Q12 | Only pipeline-delivered workspace copies produce evidence. Embedded copies are compared byte for byte as a payload property and are never executed for evidence, including when identical | Delivered script topology; Step 6 behavior and its authority cases | M2, executing the embedded copy, which makes the archive certify itself with no bootstrap; M3, executing it after an out-of-band digest comparison, which moves the problem to whatever performs the comparison; M4, shipping no copies, which removes a real operator use |
