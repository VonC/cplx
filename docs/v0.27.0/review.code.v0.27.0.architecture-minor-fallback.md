# Code review transcript for v0.27.0

- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor - Step 1

- Recorded: 2026-09-14T17:06:21+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 1
- Outcome: request

### Review identity for step 1 architecture-minor-fallback (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
Implementation step: 1
Review round: 1

### Code review evidence for step 1 architecture-minor-fallback (round 1)

request_index_tree: 4cd0c7c9b4c18e36a2844a08893de36ffac95d5a
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.architecture-fallback.sh --step 1 (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(packages): select curated minor metadata
group 1 path: src/setups/package_metadata.sh
group 1 path: src/setups/setup_packages.sh
group 1 path: docs/v0.27.0/verify.architecture-fallback.sh
group 1 path: docs/v0.27.0/verify.architecture-metadata.sh
group 2: docs(architecture-minor-fallback): record step 1 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/verify.architecture-fallback.sh
staged path: docs/v0.27.0/verify.architecture-metadata.sh
staged path: src/setups/package_metadata.sh
staged path: src/setups/setup_packages.sh
```

### Requestor assessment for step 1 architecture-minor-fallback (round 1)

Yes. Step 1 has been fully implemented.

The selector is pure Bash policy, with separate list and active-properties
adapters. Exact presence, integer minor ordering, whole machine names, first
mirror definitions and ordinary present-input failure semantics are covered.
The main script's source guard makes copied fixtures safe without changing its
normal package flow. Consumer wiring belongs to Step 2.

The cumulative Windows CMD/Git Bash gate passes all eight named case groups,
the mandatory tracked ShellCheck floor and explicit effort syntax/lint checks.
It compares live metadata/status/cache inventories even on fatal/failure exits.
There is no Python class coverage gate. Every new top-level function has an
internal or test caller. Metadata IO counters establish one properties read and
one chosen-list read. The selector scans at most twice without sorting.

See the staged validation record for exact commands, timings, line counts and
the case matrix. No RHEL, Jenkins or compilation action belongs to this step.

### Implementation report for step 1 architecture-minor-fallback (round 1)

Added package_metadata.sh with one pure inventory selector, list and active
mirror adapters, decimal normalization/comparison, literal trimming and an
injectable read boundary. Caller-owned arrays carry results and diagnostics.
Fallback logs identify the requested architecture and original source.

The selector excludes major-only fallback, different distribution/major/whole
machine keys and equal numeric minors. Numeric ties among eligible candidates
use literal C-order identity so input order cannot alter selection. Empty exact
lists remain authoritative. Duplicate properties keep the first trimmed value,
even when empty. The active properties file is read once; no template is read.

The setup entry point sources the helper and guards main. New verification
scripts use copied source trees, synthetic state, denied external calls and
subprocess cases. They check the actual fatal exit and live-tree preservation.
The runner rejects unfinished future steps. No production consumer wiring,
index handling, progress handling, curated cleanup or host acceptance is claimed.

### Change summary for step 1 architecture-minor-fallback (round 1)

The staged implementation has five paths:

- src/setups/package_metadata.sh
- src/setups/setup_packages.sh
- docs/v0.27.0/verify.architecture-fallback.sh
- docs/v0.27.0/verify.architecture-metadata.sh
- docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md

Root a.commit is formatted and passes the readiness checker. Its groups are:

1. feat(packages): select curated minor metadata, containing the helper, setup
   source guard and both verification scripts.
2. docs(architecture-minor-fallback): record step 1 validation, containing only
   the validation record, last as required by the implementation workflow.

The protocol-produced review transcript is accumulated separately and will be
included by the authorized residual continuation after commit approval.

### Writer response for step 1 architecture-minor-fallback (round 1)

Writer response:

This is the initial Step 1 implementation review. There is no earlier code
feedback to accept or reject. All requirement, design and plan answers are
already approved. Check only Step 1 against the approved four-step plan.

The initial test run failed at the missing helper before production edits, with
preservation passing. The legacy fatal fixture disables errexit because the
logger's post-increment otherwise aborts before fatal's intended process exit.
Fixture whitespace is represented inside printf arguments to preserve the
trimming test without introducing trailing source whitespace.

Run Windows checks through the supplied CMD/Git Bash plan command. The project
floor is bash src/utils/lint_shell.sh from .review-validation. The approved plan
adapts the shared Python/ghog default to this Bash repository. Native Linux and
actual CMD launcher acceptance remain later-step work. Do not run live setup,
read private credentials or modify the adjacent private application.

### Reviewer focus for step 1 architecture-minor-fallback (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-1-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `C:/Users/vonc/git/cplx/.reviews/a.review-active.code.code.v0.27.0.architecture-minor-fallback.md`
- `C:/Users/vonc/git/cplx/.reviews/a.review-requested.code.v0.27.0.architecture-minor-fallback.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer - Step 1

- Recorded: 2026-09-14T17:18:57+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: answer

### Assessed index identity for step 1 architecture-minor-fallback (exchange 1) (round 1)

Baseline index tree: 4cd0c7c9b4c18e36a2844a08893de36ffac95d5a

Assessed index tree: 68f8dea116b2fc2d0683a80f67da40bad52f7803

### Implementation check for step 1 architecture-minor-fallback (exchange 1) (round 1)

Result:

Yes. Step 1 has been fully implemented.

This verdict holds for the assessed tree, which includes one substantive
reviewer repair. The staged work meets the Step 1 contract of the plan:

- one pure selector (`package_metadata_select`) plus list and active-properties
  adapters, with exact identity before parsing;
- integer minor ordering (highest lower, otherwise lowest higher) with
  normalized digits, so there is no octal or overflow risk;
- whole-machine, distribution and major boundaries, with major-only keys exact
  only;
- per-kind absence: a present list is authoritative, an empty first mirror
  value is absent, and a present unreadable input fails;
- first duplicate mirror definitions, original source identity, and substitution
  logging to stderr;
- the `BASH_SOURCE` main guard.

Before my repair, the mirror adapter did not honor the design rule that it keeps
"the definition current consumers read". Existing consumers address a mirror as
`${arch/./_}_pkgs_url` through `get_property`, so they never read a dotted
spelling. I executed the staged adapter against scratch property files:

- `rhel_9.8_x86_64_pkgs_url=...` alone was selected as the exact 9.8 definition,
  where `get_property rhel_9_8_x86_64_pkgs_url` returns nothing;
- the same dotted line placed before `rhel_9_8_x86_64_pkgs_url=...` shadowed the
  canonical key, which `get_property` returns.

The repair derives candidate keys only from names the existing reader can
address: the request's canonical name maps to the request, an underscore
major/minor name maps to its dotted key, and any other dotted spelling is
skipped. Two cases now cover it in `metadata_mirrors`, and the same probes now
select the canonical source, or fall back to 9.6 when only the dotted spelling
exists.

#### Architecture check by the reviewer for step 1 for step 1 architecture-minor-fallback (exchange 1) (round 1)

The selector does policy only and adapters own reads, with one injectable read
function. Nothing calls setup, remote commands, property writers or progress
code, and nothing evaluates property text. Caller-owned namerefs carry results,
under a documented `_pm_` reserved prefix. Consumer wiring is correctly left to
Step 2. No, there is no remaining architecture issue that needs to be addressed.

#### Performance check by the reviewer for step 1 for step 1 architecture-minor-fallback (exchange 1) (round 1)

Selection is linear in candidates with no sort. Mirror parsing reads the active
properties once, and the list adapter enumerates one tool directory and reads
only the chosen file, as the call-count case proves. The repair adds one string
comparison per property line. No, there is no performance issue that needs to
be addressed.

#### Coverage check by the reviewer for step 1 for step 1 architecture-minor-fallback (exchange 1) (round 1)

There is no measured coverage gate in this Bash repository. Every top-level
function in `package_metadata.sh` is referenced internally or by the matrix:
`number`, `parse`, `compare`, `select`, `read`, `report`, `list`, `trim` and
`mirror`. Every runner and suite function is invoked. No unit-tested class is
below 100%, since none exists. No top-level symbol is unreferenced.

Validation plan effects:

The reviewer made no edit to `docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md`.

The staged Step 1 record predates the reviewer repair. Its `metadata_mirrors`
case-matrix row and its "What was implemented" helper bullet do not mention the
dotted-spelling rule and its two new cases, and its executed-evidence bullet
reports the pre-repair run. The writer owns that update in the next round.

### Pre-repair mandatory checks and coverage for step 1 architecture-minor-fallback (exchange 1) (round 1)

Both commands of the resolved set were run on the received index tree
`4cd0c7c9b4c18e36a2844a08893de36ffac95d5a`, through
`cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat >NUL && !GH!\bin\bash.exe <command>"`
from PowerShell. `TMPDIR` was unset.

- `bash src/utils/lint_shell.sh`: `lint_shell: 55 tracked scripts`,
  `lint_shell: clean`, exit 0.
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 1`: all eight case
  groups passed, preservation passed after the fatal fixture and at exit,
  `Architecture gate: exit=0 elapsed=34s`, exit 0.

After the repair, both were run again on the repaired tree with the same results
(55 scripts clean; eight groups plus both preservation checks passed; exit 0 in
35 seconds). `git diff --check` over both repaired paths was also clean.

### Resolved validation set and sources for step 1 architecture-minor-fallback (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project `.review-validation`)
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 1` (source: plan Step 1)

Both were run before and after the reviewer repair; see the pre-repair validation
evidence.

### Resolver drift and direction for step 1 architecture-minor-fallback (exchange 1) (round 1)

No drift. The request's set equals the current sources: `.review-validation` still
declares only `bash src/utils/lint_shell.sh`, and the plan's shared ready command
for Step 1 is the `--step 1` runner invocation.

### Repository state around validation for step 1 architecture-minor-fallback (exchange 1) (round 1)

- **Request-time index tree:** `4cd0c7c9b4c18e36a2844a08893de36ffac95d5a`,
  identical to the tree captured at reviewer entry.
- **Assessed index tree after the staged repair:**
  `68f8dea116b2fc2d0683a80f67da40bad52f7803`.
- **Umbrella digest:** unchanged
  (`7e4bdb1e929a7ffbbcf650c1b60287934760f0469ef8599ebde54fab15a16294` before and
  after).
- **Validation state:** the comparison over the five staged Step 1 paths
  reports `acceptable: false`, with tracked differences limited to
  `src/setups/package_metadata.sh`, `docs/v0.27.0/verify.architecture-metadata.sh`
  and the index. Those are exactly the two recorded reviewer repairs and their
  staging. No validation command changed a tracked or ignored file: the runner's
  own before/after comparison of live setup status, metadata content and RPM
  cache inventory passed on both runs.
- **Untracked state:** the untracked protocol transcript
  `docs/v0.27.0/review.code.v0.27.0.architecture-minor-fallback.md` was present
  before assessment and was neither read nor staged.

### Repair inventory for step 1 architecture-minor-fallback (exchange 1) (round 1)

Repairs made:

- src/setups/package_metadata.sh (substantive): mirror adapter ignores dotted property spellings the existing reader never addresses; attributable patch staged
- docs/v0.27.0/verify.architecture-metadata.sh (substantive): metadata_mirrors adds dotted-shadowing and dotted-only cases; attributable patch staged

Paths staged:

- docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
- docs/v0.27.0/verify.architecture-fallback.sh
- docs/v0.27.0/verify.architecture-metadata.sh
- src/setups/package_metadata.sh
- src/setups/setup_packages.sh

### Commit plan assessment for step 1 architecture-minor-fallback (exchange 1) (round 1)

`commit-plan-check.bat --format json` was run independently before and after the
repair. Both times it returned status 0, `state: valid`, `ready: true`, no
diagnostics, and the same five staged paths in two groups:

1. `feat(packages): select curated minor metadata`: `package_metadata.sh`,
   `setup_packages.sh` and both verification scripts;
2. `docs(architecture-minor-fallback): record step 1 validation`: the validation
   record, last.

The reviewer repair stays inside group 1's paths and subject, so membership,
order and subjects remain accurate, and `a.commit` was not amended. When the
writer updates the validation record, group 1's "What" list may also mention the
dotted-spelling rule; that is optional. A status 0 here proves only the
mechanical grouping.

### Findings and boundaries for step 1 architecture-minor-fallback (exchange 1) (round 1)

Unresolved findings:

- The staged Step 1 validation record does not yet describe the reviewer repair: its metadata_mirrors row, helper bullet and executed-evidence bullet predate the dotted-spelling rule and its two cases.

Boundary-crossing work: None.

### Writer instructions for step 1 architecture-minor-fallback (exchange 1) (round 1)

1. Assess the staged reviewer repair in `src/setups/package_metadata.sh` and
   `docs/v0.27.0/verify.architecture-metadata.sh`. It keeps the design rule that
   the mirror adapter reads the same definition current consumers read:
   `get_property` addresses `${arch/./_}_pkgs_url`, so a dotted property
   spelling must neither become an exact definition nor shadow the canonical
   key.
2. Update the Step 1 validation record: add the dotted-spelling rule to the
   helper bullet and to the `metadata_mirrors` row, and replace the executed
   evidence with a run on the repaired tree. The reviewer's run passed all eight
   groups and both preservation checks in 35 seconds, with the 55-script lint
   floor clean. Recount `package_metadata.sh` and
   `verify.architecture-metadata.sh`, which grew with the repair.
3. Optionally mention the rule in group 1's "What" list in `a.commit`, re-run
   `commit-plan-check.bat --format json`, and publish the replacement request
   for round 2.

### Decision rationale for step 1 architecture-minor-fallback (exchange 1) (round 1)

Decision: changes-requested.

The implementation, validation, attribution and commit grouping floors pass on
the repaired tree. But this round made a substantive repair to production code
and a test, which by rule cannot finish the workflow in the same round. The
staged validation record also no longer describes the staged code. The requestor
should assess the repair, refresh the record, and request round 2. The
recommendation is advisory and authorizes no commit.

### Final reviewer decision for step 1 architecture-minor-fallback (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-1-round-1 -->

## Round 2 by requestor - Step 1

- Recorded: 2026-09-14T17:21:34+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: request

### Review identity for step 1 architecture-minor-fallback (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
Implementation step: 1
Review round: 2

### Code review evidence for step 1 architecture-minor-fallback (round 2)

request_index_tree: bec5b616c27e585f5cc0c459ad0cc13de7bc9963
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.architecture-fallback.sh --step 1 (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(packages): select curated minor metadata
group 1 path: src/setups/package_metadata.sh
group 1 path: src/setups/setup_packages.sh
group 1 path: docs/v0.27.0/verify.architecture-fallback.sh
group 1 path: docs/v0.27.0/verify.architecture-metadata.sh
group 2: docs(architecture-minor-fallback): record step 1 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/verify.architecture-fallback.sh
staged path: docs/v0.27.0/verify.architecture-metadata.sh
staged path: src/setups/package_metadata.sh
staged path: src/setups/setup_packages.sh
```

### Requestor assessment for step 1 architecture-minor-fallback (round 2)

Yes. Step 1 has been fully implemented.

The selector is pure Bash policy, with separate list and active-properties
adapters. Exact presence, integer minor ordering, whole machine names, first
mirror definitions and ordinary present-input failure semantics are covered.
The main script's source guard makes copied fixtures safe without changing its
normal package flow. Consumer wiring belongs to Step 2.

The cumulative Windows CMD/Git Bash gate passes all eight named case groups,
the mandatory tracked ShellCheck floor and explicit effort syntax/lint checks.
It compares live metadata/status/cache inventories even on fatal/failure exits.
There is no Python class coverage gate. Every new top-level function has an
internal or test caller. Metadata IO counters establish one properties read and
one chosen-list read. The selector scans at most twice without sorting.

See the staged validation record for exact commands, timings, line counts and
the case matrix. No RHEL, Jenkins or compilation action belongs to this step.

### Implementation report for step 1 architecture-minor-fallback (round 2)

Added package_metadata.sh with one pure inventory selector, list and active
mirror adapters, decimal normalization/comparison, literal trimming and an
injectable read boundary. Caller-owned arrays carry results and diagnostics.
Fallback logs identify the requested architecture and original source.

The selector excludes major-only fallback, different distribution/major/whole
machine keys and equal numeric minors. Numeric ties among eligible candidates
use literal C-order identity so input order cannot alter selection. Empty exact
lists remain authoritative. Duplicate properties keep the first trimmed value,
even when empty. The active properties file is read once; no template is read.
The accepted round 1 repair keeps property addressing compatible with existing
consumers: dotted version spellings cannot become exact sources or shadow the
canonical underscore property. Two regression cases cover these inputs.

The setup entry point sources the helper and guards main. New verification
scripts use copied source trees, synthetic state, denied external calls and
subprocess cases. They check the actual fatal exit and live-tree preservation.
The runner rejects unfinished future steps. No production consumer wiring,
index handling, progress handling, curated cleanup or host acceptance is claimed.

### Change summary for step 1 architecture-minor-fallback (round 2)

The staged implementation has five paths:

- src/setups/package_metadata.sh
- src/setups/setup_packages.sh
- docs/v0.27.0/verify.architecture-fallback.sh
- docs/v0.27.0/verify.architecture-metadata.sh
- docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md

Root a.commit is formatted and passes the readiness checker. Its groups are:

1. feat(packages): select curated minor metadata, containing the helper, setup
   source guard and both verification scripts.
2. docs(architecture-minor-fallback): record step 1 validation, containing only
   the validation record, last as required by the implementation workflow.

The protocol-produced review transcript is accumulated separately and will be
included by the authorized residual continuation after commit approval.

### Writer response for step 1 architecture-minor-fallback (round 2)

Writer response:

The writer accepts the round 1 repair in package_metadata.sh and its two added
metadata_mirrors cases. The existing reader addresses the canonical underscore
property, so a dotted version spelling must neither create an exact definition
nor shadow that canonical property. No repair was reverted and there is no
disagreement. The patch remains within Step 1 and changes no commit boundary.

The staged validation record now describes that rule, the two cases, the
reviewer's successful 35-second run on the repaired tree, and the recounted
201-line helper and 212-line matrix. Root a.commit retains the same membership,
grouping and subjects, with body wording refreshed for the rule and timing.
All requirement, design and plan answers remain approved. Check only Step 1.

The initial test run failed at the missing helper before production edits, with
preservation passing. The legacy fatal fixture disables errexit because the
logger's post-increment otherwise aborts before fatal's intended process exit.
Fixture whitespace is represented inside printf arguments to preserve the
trimming test without introducing trailing source whitespace.

Run Windows checks through the supplied CMD/Git Bash plan command. The project
floor is bash src/utils/lint_shell.sh from .review-validation. The approved plan
adapts the shared Python/ghog default to this Bash repository. Native Linux and
actual CMD launcher acceptance remain later-step work. Do not run live setup,
read private credentials or modify the adjacent private application.

### Reviewer focus for step 1 architecture-minor-fallback (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-1-round-2 -->

## Round 2 by reviewer - Step 1

- Recorded: 2026-09-14T17:25:49+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: answer

### Assessed index identity for step 1 architecture-minor-fallback (exchange 1) (round 2)

Baseline index tree: bec5b616c27e585f5cc0c459ad0cc13de7bc9963

Assessed index tree: bec5b616c27e585f5cc0c459ad0cc13de7bc9963

### Implementation check for step 1 architecture-minor-fallback (exchange 1) (round 2)

Result:

Yes. Step 1 has been fully implemented.

The code and tests are byte-identical to the tree I assessed and repaired in
round 1. `git diff` between that assessed tree
(`68f8dea116b2fc2d0683a80f67da40bad52f7803`) and this request's tree
(`bec5b616c27e585f5cc0c459ad0cc13de7bc9963`) touches only the validation record.
The round 1 assessment therefore still holds, now with the canonical mirror
addressing in place:

- one pure selector with list and active-properties adapters;
- exact identity before parsing;
- integer highest-lower then lowest-higher ordering;
- distribution, major and whole-machine boundaries;
- per-kind absence, first duplicate mirror definitions, and original source
  identity with substitution logging;
- the `BASH_SOURCE` main guard.

The validation record's round 2 edits match the tree: the dotted-spelling rule
in the helper bullet and in the `metadata_mirrors` row, the repaired-tree
evidence, and line counts of 201 and 212, which I recounted.

#### Architecture check by the reviewer for step 1 architecture-minor-fallback (exchange 1) (round 2)

Policy stays in the selector and reads stay in the adapters, behind one
injectable read function. No setup, remote, property-writer or progress code is
called, and no property text is evaluated. No, there is no architecture issue
that needs to be addressed.

#### Performance check by the reviewer for step 1 architecture-minor-fallback (exchange 1) (round 2)

Selection is linear in candidates with no sort. There is one active-properties
read and one selected-list read, both proven by the call-count case. No, there
is no performance issue that needs to be addressed.

#### Coverage check by the reviewer for step 1 architecture-minor-fallback (exchange 1) (round 2)

There is no measured coverage gate in this Bash repository. Every top-level
function in `package_metadata.sh` and in both harness scripts is referenced
internally or invoked by the matrix. No unit-tested class is below 100%, since
none exists, and no top-level symbol is unreferenced.

Validation plan effects:

The reviewer made no edit to the validation plan in round 2. The writer's staged
Step 1 record now describes the round 1 repair, its two cases, the repaired-tree
evidence and the recounted line sizes, and it matches the staged code.

### Pre-repair mandatory checks and coverage for step 1 architecture-minor-fallback (exchange 1) (round 2)

No repair was made in round 2, so the pre-repair run is the final run. Both
commands were run on index tree `bec5b616c27e585f5cc0c459ad0cc13de7bc9963`
through
`cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat >NUL && !GH!\bin\bash.exe <command>"`:

- `bash src/utils/lint_shell.sh`: `lint_shell: 55 tracked scripts`,
  `lint_shell: clean`, exit 0.
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 1`: all eight case
  groups passed, preservation passed after the fatal fixture and at exit,
  `Architecture gate: exit=0 elapsed=45s`, exit 0.

`git diff --cached --check` was also clean.

### Resolved validation set and sources for step 1 architecture-minor-fallback (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (source: project `.review-validation`)
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 1` (source: plan Step 1)

### Resolver drift and direction for step 1 architecture-minor-fallback (exchange 1) (round 2)

No drift: the request's set still equals `.review-validation` plus the plan's Step 1 runner command.

### Repository state around validation for step 1 architecture-minor-fallback (exchange 1) (round 2)

- **Index trees:** request-time, reviewer-entry and assessed trees are all
  `bec5b616c27e585f5cc0c459ad0cc13de7bc9963`.
- **Umbrella digest:** unchanged
  (`7e4bdb1e929a7ffbbcf650c1b60287934760f0469ef8599ebde54fab15a16294`).
- **Validation state:** the comparison over the five staged Step 1 paths
  reports `acceptable: true`, with no tracked, ignored or untracked differences.
  The runner's own live-tree comparison (setup status, metadata content, RPM
  cache inventory) also passed.
- **Staged set:** unchanged at five paths, the same as round 1.
- **Correction to round 1:** the round 1 answer's repair inventory listed all
  five staged paths under "Paths staged". The reviewer staged only
  `src/setups/package_metadata.sh` and
  `docs/v0.27.0/verify.architecture-metadata.sh`; the other three were staged by
  the writer.
- **Change since the round 1 assessed tree:** only
  `docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md`
  (14 insertions, 8 deletions).

### Repair inventory for step 1 architecture-minor-fallback (exchange 1) (round 2)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 1 architecture-minor-fallback (exchange 1) (round 2)

`commit-plan-check.bat --format json` was run independently and returned status
0, `state: valid`, `ready: true` and no diagnostics. It lists the five staged
paths in the same two groups:

1. `feat(packages): select curated minor metadata`: helper, setup guard and both
   verification scripts;
2. `docs(architecture-minor-fallback): record step 1 validation`: the validation
   record, last.

Group 1's body now names canonical mirror names, which matches the staged code.
`a.commit` is accurate and was not amended. The status 0 proves only mechanical
grouping.

### Findings and boundaries for step 1 architecture-minor-fallback (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 1 architecture-minor-fallback (exchange 1) (round 2)

No further change is requested for Step 1. Present this advisory commit-ready
recommendation at the human commit gate. The validation record links the review
transcript, which is still untracked; include it through the residual
continuation you described, so the link resolves once both commits exist.

### Decision rationale for step 1 architecture-minor-fallback (exchange 1) (round 2)

Decision: commit-ready (advisory).

All six readiness-floor results pass on the received tree:

- exact identity and unchanged index tree;
- complete Step 1 implementation, including the accepted round 1 repair;
- both mandatory validation commands passing, with the behavioral matrix
  covering every top-level function;
- no reviewer repair this round, and no untracked or tracked validation side
  effect;
- no unresolved or boundary-crossing findings;
- an independently checked, accurate `a.commit`.

This recommendation does not authorize a commit; the commit choice belongs to
the human.

### Final reviewer decision for step 1 architecture-minor-fallback (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-1-round-2 -->

## Round 2 by human - Step 1 - human-confirmation

- Recorded: 2026-09-14T17:37:35+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 1 by requestor - Step 2

- Recorded: 2026-09-14T18:07:55+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 2
- Outcome: request

### Review identity for step 2 architecture-minor-fallback (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
Implementation step: 2
Review round: 1

### Code review evidence for step 2 architecture-minor-fallback (round 1)

request_index_tree: 78c032ad4731715049cf5e5a0c7d7feb0eb8f68c
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.architecture-fallback.sh --step 2 (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(packages): publish guarded exact indexes
group 1 path: src/setups/package_metadata.sh
group 1 path: src/setups/package_index.sh
group 1 path: src/setups/setup_packages.sh
group 1 path: src/setups/pkgs/.gitignore
group 1 path: docs/v0.27.0/verify.architecture-fallback.sh
group 1 path: docs/v0.27.0/verify.architecture-index.sh
group 2: docs(architecture-minor-fallback): record step 2 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/verify.architecture-fallback.sh
staged path: docs/v0.27.0/verify.architecture-index.sh
staged path: src/setups/package_index.sh
staged path: src/setups/package_metadata.sh
staged path: src/setups/pkgs/.gitignore
staged path: src/setups/setup_packages.sh
```

### Requestor assessment for step 2 architecture-minor-fallback (round 1)

Yes. Step 2 has been fully implemented.

The invocation pins detected architecture, exact index identity, selected list
and first-resolved ordered mirror URLs. Ordinary and direct-package flows guard
the exact index independently of completion status. Generation validates a
unique sibling candidate before replacement and records completion afterward.
Cache hits and usable indexes remain independent of mirror configuration.

The cumulative gate passed on Windows CMD/Git Bash (215 seconds, 17 groups)
and native RHEL Bash (20 seconds, 16 applicable groups). Windows exercised a
real held destination, preserved old bytes on replacement failure, then
successfully retried after release. The final native run explicitly labels that
Windows-only case separately required. Mandatory tracked-shell ShellCheck,
explicit effort syntax/lint checks and live metadata/status/cache preservation
passed. The final fixture reporting clarification occurred after the Windows
run; review validation will exercise the exact final staged tree.

The index fixtures cover 48 guard combinations, ten generation/completion
failure boundaries, retry exhaustion, lookup failure, lazy mirror failure,
built-package bypass, cached/offline operation and selected-list copy identity.
The approved plan substitutes this Bash gate for Python/ghog coverage. There
is no Python class coverage claim. All new top-level functions have callers.

Architecture and performance evidence: orchestration shrinks from 575 to 442
lines; metadata, index and index-fixture files are 223, 150 and 296 lines.
All stay within advisory limits. Mirrors resolve once per invocation and a
served refresh is reused across packages. The recorded validation details the
commands, timing, boundaries and remaining Step 3/4 work.

Native validation used an isolated temporary source copy and pinned temporary
ShellCheck. It made no live setup changes and performed no compilation,
application packaging, Jenkins run or publication.

### Implementation report for step 2 architecture-minor-fallback (round 1)

Step 2 carries Step 1 metadata selection through exact-index production and
consumption. The main shell now owns one context and URL array. It resolves the
ordinary list once, retains its original source for synchronization and remote
dependencies.list copying, and retains a relative identity for Step 3 progress.

The new package_index.sh contains index availability, existing extraction and
aggregation policy, and checked publication. It creates isolated scratch and
candidate siblings, checks fetch and every extraction pipeline component,
checks final nonempty output, replaces through mv -fT, and cleans only owned
scratch. Failure preserves an existing index until successful replacement;
completion follows replacement. Missing/empty indexes regenerate even with a
completion marker. Reload and force-reload regenerate once per invocation.

Direct lookup uses the same guard, except the existing built-package form.
Lookup no longer creates an empty placeholder. Cached archives need no mirror
resolution, while actual downloads reuse pinned URLs and retry in their
existing order. Remote preparation copies the selected fallback list itself.

The cumulative runner adds dedicated index fixtures, including actual
orchestration and download paths with bounded fake network output. Windows
uses a real file handle to deny destination replacement, then retries after
release. Scoped progress and reset remain Step 3; curated cleanup and live
acceptance remain Step 4.

### Change summary for step 2 architecture-minor-fallback (round 1)

Seven staged paths form two prepared root a.commit groups:

1. feat(packages): publish guarded exact indexes
   - src/setups/package_metadata.sh
   - src/setups/package_index.sh
   - src/setups/setup_packages.sh
   - src/setups/pkgs/.gitignore
   - docs/v0.27.0/verify.architecture-fallback.sh
   - docs/v0.27.0/verify.architecture-index.sh
2. docs(architecture-minor-fallback): record step 2 validation
   - docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md

wac formatting and commit-plan-check passed with all seven paths assigned and
no diagnostics. The long validation subject is the required pw step marker.
The versioned review transcript is an owning-continuation residual after
authorization, as for Step 1. No Step 2 commit is authorized yet.

### Writer response for step 2 architecture-minor-fallback (round 1)

Writer response:

This is the first implementation review of Step 2. There is no earlier Step 2
feedback or disagreement. Step 1 review and its authorized commit lifecycle
are complete. The current request contains only Step 2 and its cumulative gate.

Preserve the approved platform roles: RHEL packages and deploys tools; Debian
Jenkins consumes tools, tests application sources, and packages/publishes the
application only. This step's validation uses isolated fixtures and no gcc or
build workflow. Public review prose must retain generic application names.

### Reviewer focus for step 2 architecture-minor-fallback (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-2-round-1 -->

## Round 1 by reviewer - Step 2

- Recorded: 2026-09-14T18:19:04+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: answer

### Assessed index identity for step 2 architecture-minor-fallback (exchange 1) (round 1)

Baseline index tree: 78c032ad4731715049cf5e5a0c7d7feb0eb8f68c

Assessed index tree: 78c032ad4731715049cf5e5a0c7d7feb0eb8f68c

### Implementation check for step 2 architecture-minor-fallback (exchange 1) (round 1)

Result:

No. Step 2 has NOT been fully implemented.

The context, guard, publication and consumer wiring are correct and well
tested. Two points break the plan's instruction to extract generation
"retaining the established HTML extraction and aggregation rules" without
impairing existing behavior, and one behavior change is not recorded.

#### What was verified for step 2 for step 2 architecture-minor-fallback (exchange 1) (round 1)

- **Invocation context.** `package_metadata_context` keys the exact index to the
  detected architecture. The ordinary list is selected once, before any mirror
  work. `sync_packages` and `setup_remote_install` consume
  `package_context[list_source]`, so synchronization and `dependencies.list`
  use the same fallback file (`index_selected_list_copy`).
- **Guard.** `package_index_available` ignores the completion marker. It
  regenerates on a missing or empty index or either reload flag, once per
  invocation, on both the ordinary and the direct path. The built `_` form
  bypasses the index and mirrors. This is proven by the 48-cell matrix and
  `index_direct_built_and_empty`.
- **Mirrors.** `package_metadata_pin_mirrors` resolves lazily and pins the
  selected URLs in the current shell, so generation and every download reuse
  one read, and cached or offline runs never read properties
  (`index_pinned_mirrors_and_cache`).
- **Publication.** Generation runs in a subshell with mktemp-owned
  `.cplx-index-*` scratch and a candidate cleaned by an EXIT trap. It checks
  every pipeline component through `PIPESTATUS`, requires a nonempty candidate,
  and replaces with `mv -fT`. It records completion only afterwards; a
  completion failure exits 6 with the new index kept. Ten injected failures
  keep the old bytes, and a real Windows handle without delete sharing yields
  115 and then recovers.
- **Lookup.** `find_package_in_arch` no longer creates a placeholder index; it
  fails with 201 on a missing or empty index.

#### Missing work for step 2 for step 2 architecture-minor-fallback (exchange 1) (round 1)

- **Soft skip of an empty listing lost.** The removed `process_packages_url`
  logged `Failed to extract URLs ...` and returned 0 when no pipeline matched a
  listing, so the other mirror URLs still produced the index.
  `package_index_listing` now returns 111 ("No package URLs extracted"), and the
  whole generation stops. Executed evidence: with two URLs, one serving
  `alpha-1.x86_64.rpm` and one a valid 50-line page without package links, the
  `HEAD` code returned 0, warned about the empty URL and published `alpha-1`,
  while the staged code returned fatal 111 with no index. Either restore the
  warn-and-skip for the case where every pipeline ran without a command error
  but matched nothing, keeping hard failures for fetch errors, short pages,
  grep status 2 and an empty final candidate (112), or record the stricter rule
  as a deliberate, justified change in this step's record. The restoration is
  the reading that keeps the established rules.
- **Generation reporting removed.** The old path reported the URL list, each
  URL's package count, the final unique package count and the saved index. A
  successful staged generation prints nothing: an executed run produced empty
  output with rc 0. The run output no longer shows which mirror property
  generated the detected-key index, or how large the published index is.
  Restore concise messages on the generation path only (not on every per-package
  guard reuse): the mirror source and URL count before generating, and the
  published path with its package count after publication. Keep them on the
  existing `task`/`ok` channel, not on data stdout.
- **Download URL normalization change not recorded.** `download_package` replaced
  `url="${url//\/\//\/}"`, which collapsed every double slash and so also
  rewrote `https://` into `https:/`, with a single trailing-slash strip on the
  mirror prefix. This is likely an improvement, but the validation record should
  state it, since it changes the exact URLs requested.

#### Architecture check by the reviewer for step 2 for step 2 architecture-minor-fallback (exchange 1) (round 1)

Responsibilities are well separated. Metadata owns selection and pinning, the
index helper owns listing and publication IO, and main owns synchronization and
remote orchestration. The subshells return only statuses and files, never
context. Yes, there is something that needs to be addressed: the generation
reporting regression listed above sits in this boundary.

#### Performance check for step 2 by the reviewer for step 2 architecture-minor-fallback (exchange 1) (round 1)

The guard costs one stat per package. Listing, aggregation and sorting keep
their previous cost, mirrors resolve once per invocation, and the selector
stays linear. No, there is no performance issue that needs to be addressed.

#### Coverage check for step 2 by the reviewer for step 2 architecture-minor-fallback (exchange 1) (round 1)

There is no measured coverage gate in this Bash repository. Every new top-level
function (`package_index_available`, `aggregate`, `extract`, `listing`,
`write_candidate`, `generate`, the trap callback, `package_metadata_context`,
`pin_mirrors`, `resolve_package_mirrors`) is referenced and exercised. No fixture
covers a listing that matches nothing next to a productive listing, which is the
case the first missing item concerns. No unit-tested class is below 100%, and no
top-level symbol is unreferenced.

Validation plan effects:

The reviewer made no edit to the validation plan. The staged Step 2 record reads
"Yes. Step 2 has been fully implemented." and its feature-integrity section does
not mention the empty-listing hard failure, the removed generation reporting, or
the download URL normalization change. The writer owns updating it with the
resolution of the missing work.

### Pre-repair mandatory checks and coverage for step 2 architecture-minor-fallback (exchange 1) (round 1)

No repair was made, so this is the only run. Both commands ran on the received
index tree `78c032ad4731715049cf5e5a0c7d7feb0eb8f68c`, which is the final staged
tree (the requestor noted a fixture reporting edit after its own Windows run),
through
`cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat >NUL && !GH!\bin\bash.exe <command>"`:

- `bash src/utils/lint_shell.sh`: `lint_shell: 56 tracked scripts`,
  `lint_shell: clean`, exit 0.
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 2`: 8 metadata and
  9 index groups passed, including `index_windows_held_destination` with a real
  PowerShell handle. Both preservation checks passed.
  `Architecture gate: exit=0 elapsed=213s`, exit 0.

`git diff --cached --check` was clean. Two further executed comparisons, on
scratch copies outside the repository, support the findings: `HEAD` against
the staged generation on an empty listing, and the staged generation's output
on success.

### Resolved validation set and sources for step 2 architecture-minor-fallback (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project `.review-validation`)
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 2` (source: plan Step 2)

### Resolver drift and direction for step 2 architecture-minor-fallback (exchange 1) (round 1)

No drift. `.review-validation` still declares only the lint floor, and the plan's
Step 2 ready command is the `--step 2` runner invocation. The plan's native Linux
portability run is recorded by the writer, which ran it on RHEL 9.8 in a
temporary checkout. It is not part of the resolved mandatory set, and the
reviewer did not repeat it.

### Repository state around validation for step 2 architecture-minor-fallback (exchange 1) (round 1)

- **Index trees:** request-time, reviewer-entry and assessed trees are all
  `78c032ad4731715049cf5e5a0c7d7feb0eb8f68c`.
- **Umbrella digest:** unchanged
  (`7e4bdb1e929a7ffbbcf650c1b60287934760f0469ef8599ebde54fab15a16294`).
- **Validation state:** the comparison over the seven staged Step 2 paths
  reports `acceptable: true` with no differences, and the runner's live-tree
  comparison passed.
- **Unstaged tracked change:** the protocol transcript
  `docs/v0.27.0/review.code.v0.27.0.architecture-minor-fallback.md` was already
  modified and unstaged before assessment; it was neither read nor staged.

### Repair inventory for step 2 architecture-minor-fallback (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 2 architecture-minor-fallback (exchange 1) (round 1)

`commit-plan-check.bat --format json` was run independently and returned status
0, `state: valid`, `ready: true` and no diagnostics. Seven staged paths fall into
two groups:

1. `feat(packages): publish guarded exact indexes`: metadata, index helper,
   setup script, package ignore file and both verification scripts;
2. `docs(architecture-minor-fallback): record step 2 validation`: the validation
   record, last.

Membership, order and subjects match the staged work, and `a.commit` was not
amended. Group 2's "Mark Step 2 complete" bullet will need to follow the outcome
of the missing work. The status 0 proves only mechanical grouping.

### Findings and boundaries for step 2 architecture-minor-fallback (exchange 1) (round 1)

Unresolved findings:

- package_index_listing turns a listing whose pipelines match nothing into fatal 111 for the whole generation, where the established process_packages_url warned and skipped that URL (executed: HEAD rc 0 with index, staged rc 111 without index)
- Successful index generation prints nothing (executed: empty output, rc 0); the mirror source, per-URL and final package counts and published path are no longer reported
- The download URL normalization change (no double-slash collapse, scheme kept, one trailing slash stripped) is not recorded in the Step 2 validation record

Boundary-crossing work: None.

### Writer instructions for step 2 architecture-minor-fallback (exchange 1) (round 1)

1. In `src/setups/package_index.sh`, restore the established soft skip. When
   every extraction pipeline ran without a component error (no status above 1)
   but matched nothing, emit a warning naming the URL and return success with
   no per-URL output, so the other URLs still contribute. Keep the current hard
   failures for a failed fetch, a page under 50 lines, a grep component error,
   and an empty final candidate (112). If you prefer the stricter rule, record
   it in the Step 2 record as a deliberate change with its rationale instead,
   since the plan asked to retain the established rules.
2. Add a fixture in `verify.architecture-index.sh` with one productive and one
   empty-but-valid listing, asserting the chosen behavior: a published index from
   the productive URL plus a warning, or the documented failure.
3. In `download_packages_list`, report generation only, not per-package guard
   reuse. Before generating, name the pinned mirror source and URL count; after
   publication, name the index path and its package count. Use the existing
   `task`/`ok` logging.
4. Record the download URL normalization change in the Step 2 record. Then
   re-run the Step 2 gate on Windows (and natively, per the plan), update the
   record and `a.commit` group 2 accordingly, and publish round 2.

### Decision rationale for step 2 architecture-minor-fallback (exchange 1) (round 1)

Decision: changes-requested.

Identity, mandatory validation, staged attribution and commit grouping pass, and
the core Step 2 design is correct. The implementation-check result is No,
because generation no longer retains the established skip of an empty listing,
and successful generation lost its operator reporting, both confirmed by
execution. A third behavior change is unrecorded. Those are unresolved findings,
so the readiness floor is incomplete. No reviewer repair was made; the soft-skip
choice belongs to the writer.

### Final reviewer decision for step 2 architecture-minor-fallback (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-2-round-1 -->

## Round 2 by requestor - Step 2

- Recorded: 2026-09-14T18:28:05+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: request

### Review identity for step 2 architecture-minor-fallback (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
Implementation step: 2
Review round: 2

### Code review evidence for step 2 architecture-minor-fallback (round 2)

request_index_tree: 0994cb5434057afac4f70a1f6fd00a33a2fe3384
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.architecture-fallback.sh --step 2 (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(packages): publish guarded exact indexes
group 1 path: src/setups/package_metadata.sh
group 1 path: src/setups/package_index.sh
group 1 path: src/setups/setup_packages.sh
group 1 path: src/setups/pkgs/.gitignore
group 1 path: docs/v0.27.0/verify.architecture-fallback.sh
group 1 path: docs/v0.27.0/verify.architecture-index.sh
group 2: docs(architecture-minor-fallback): record step 2 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/verify.architecture-fallback.sh
staged path: docs/v0.27.0/verify.architecture-index.sh
staged path: src/setups/package_index.sh
staged path: src/setups/package_metadata.sh
staged path: src/setups/pkgs/.gitignore
staged path: src/setups/setup_packages.sh
```

### Requestor assessment for step 2 architecture-minor-fallback (round 2)

Yes. Step 2 has been fully implemented.

The invocation pins detected architecture, exact index identity, selected list
and first-resolved ordered mirror URLs. Ordinary and direct-package flows guard
the exact index independently of completion status. Generation validates a
unique sibling candidate before replacement and records completion afterward.
Cache hits and usable indexes remain independent of mirror configuration.

The cumulative gate passed on Windows CMD/Git Bash (228 seconds, 17 groups)
and native RHEL Bash (17 seconds, 16 applicable groups). Windows exercised a
real held destination, preserved old bytes on replacement failure, then
successfully retried after release. The final native run explicitly labels that
Windows-only case separately required. Mandatory tracked-shell ShellCheck,
explicit effort syntax/lint checks and live metadata/status/cache preservation
passed. Both runs exercised the repaired code and expanded fixtures for this
round. The added regression first failed with 111 on the previous implementation.

The index fixtures cover 48 guard combinations, twelve generation/completion
failure boundaries, retry exhaustion, lookup failure, lazy mirror failure,
built-package bypass, cached/offline operation and selected-list copy identity.
The approved plan substitutes this Bash gate for Python/ghog coverage. There
is no Python class coverage claim. All new top-level functions have callers.

Architecture and performance evidence: orchestration shrinks from 575 to 444
lines; metadata, index and index-fixture files are 223, 152 and 310 lines.
All stay within advisory limits. Mirrors resolve once per invocation and a
served refresh is reused across packages. The recorded validation details the
commands, timing, boundaries and remaining Step 3/4 work.

Native validation used an isolated temporary source copy and pinned temporary
ShellCheck. It made no live setup changes and performed no compilation,
application packaging, Jenkins run or publication.

All round 1 findings are addressed. Valid empty listings warn and skip;
productive peers still publish, while all-empty listings fail with 112.
Generation reports its mirror property, URL count, published path and package
count through task/ok only when it generates. The validation record explicitly
documents the preserved URL scheme and single trailing-slash join.

### Implementation report for step 2 architecture-minor-fallback (round 2)

Step 2 carries Step 1 metadata selection through exact-index production and
consumption. The main shell now owns one context and URL array. It resolves the
ordinary list once, retains its original source for synchronization and remote
dependencies.list copying, and retains a relative identity for Step 3 progress.

The new package_index.sh contains index availability, existing extraction and
aggregation policy, and checked publication. It creates isolated scratch and
candidate siblings, checks fetch and every extraction pipeline component,
checks final nonempty output, replaces through mv -fT, and cleans only owned
scratch. Failure preserves an existing index until successful replacement;
completion follows replacement. Missing/empty indexes regenerate even with a
completion marker. Reload and force-reload regenerate once per invocation.

Direct lookup uses the same guard, except the existing built-package form.
Lookup no longer creates an empty placeholder. Cached archives need no mirror
resolution, while actual downloads reuse pinned URLs and retry in their
existing order. Remote preparation copies the selected fallback list itself.

The cumulative runner adds dedicated index fixtures, including actual
orchestration and download paths with bounded fake network output. Windows
uses a real file handle to deny destination replacement, then retries after
release. Scoped progress and reset remain Step 3; curated cleanup and live
acceptance remain Step 4.

Round 1 repairs restore the established warn-and-skip when all extraction
pipelines run without errors but match no packages. The generator only adds
per-URL files that exist; all-empty input fails with 112. Fetch failure, short
pages and component errors still fail. Main reports selected mirror property
and URL count before generation and published path/count after replacement.
The publication fixture now mixes productive and empty listings, captures the
warning and both reports, and checks silent guard reuse. Failure fixtures add
short and all-empty listing cases. URL joining is documented in the record.

### Change summary for step 2 architecture-minor-fallback (round 2)

Seven staged paths form two prepared root a.commit groups:

1. feat(packages): publish guarded exact indexes
   - src/setups/package_metadata.sh
   - src/setups/package_index.sh
   - src/setups/setup_packages.sh
   - src/setups/pkgs/.gitignore
   - docs/v0.27.0/verify.architecture-fallback.sh
   - docs/v0.27.0/verify.architecture-index.sh
2. docs(architecture-minor-fallback): record step 2 validation
   - docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md

wac formatting and commit-plan-check passed with all seven paths assigned and
no diagnostics. The long validation subject is the required pw step marker.
The versioned review transcript is an owning-continuation residual after
authorization, as for Step 1. No Step 2 commit is authorized yet.

Round 1 repairs changed the index helper, setup orchestration, index fixture
and validation record. Root a.commit retains its seven-path membership, group
order and subjects; its bodies now record empty-listing/reporting repairs and
twelve failure cases. The reviewer made no edits to accept or reverse.

### Writer response for step 2 architecture-minor-fallback (round 2)

Writer response:

All three Step 2 round 1 findings are accepted, with no disagreement. The
writer restored warn-and-skip for valid empty listings and generation-only
task/ok reports, added mixed-listing/reporting and all-empty/short-page
regressions, and documented the download URL joining improvement.

The new mixed-listing fixture failed before the repair (111, 113 seconds) and
the complete repaired suite passed on Windows (228 seconds) and native Linux
(17 seconds). Live-tree preservation passed throughout. Step 2 is fully
implemented after these repairs; its validation record and a.commit bodies
were updated, with unchanged path membership and commit boundaries.

The reviewer made no repairs. All new staged changes are writer-owned,
substantive code/test/evidence changes and require this replacement round.

Preserve the approved platform roles: RHEL packages and deploys tools; Debian
Jenkins consumes tools, tests application sources, and packages/publishes the
application only. This step's validation uses isolated fixtures and no gcc or
build workflow. Public review prose must retain generic application names.

### Reviewer focus for step 2 architecture-minor-fallback (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-2-round-2 -->

## Round 2 by reviewer - Step 2

- Recorded: 2026-09-14T18:35:44+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: answer

### Assessed index identity for step 2 architecture-minor-fallback (exchange 1) (round 2)

Baseline index tree: 0994cb5434057afac4f70a1f6fd00a33a2fe3384

Assessed index tree: 0994cb5434057afac4f70a1f6fd00a33a2fe3384

### Implementation check for step 2 architecture-minor-fallback (exchange 1) (round 2)

Result:

Yes. Step 2 has been fully implemented.

The round 1 missing work is resolved. The rest of Step 2 is unchanged from the
tree I verified in round 1: context, guard, lazy pinned mirrors, owned sibling
publication with `mv -fT`, completion after publication, read-only lookup, and
selected-list copy.

#### Resolution of the round 1 findings for step 2 for step 2 architecture-minor-fallback (exchange 1) (round 2)

- **Empty listing.** `package_index_listing` now warns
  (`Warning: No package URLs extracted from listing: <url>; skipping`) and
  returns 0 without output when every pipeline ran without a component error but
  matched nothing. `package_index_generate` aggregates only the per-URL files
  that exist, so an all-empty set still fails with 112. Fetch failure, a page
  under 50 lines and grep status 2 keep their hard failures. I re-ran my round 1
  probe on scratch copies. With one productive and one empty URL: rc 0, the
  warning, and `alpha-1.x86_64.rpm` published, matching the old code's outcome.
  With two empty URLs: both warnings, then fatal 112 and no index, the same
  final outcome as the old code.
- **Reporting.** `download_packages_list` emits `task` with the index path,
  pinned mirror property and URL count before generating, and `ok` with the
  published path and package count after publication. Guard reuse stays silent,
  which the new assertions in `index_generation_publication` prove.
- **URL joining.** The feature-integrity section now records the one-trailing-
  slash join and the preserved `https://` scheme.

#### Architecture check by the reviewer for step 2 architecture-minor-fallback (exchange 1) (round 2)

Selection, index IO and orchestration stay separate. The warning is emitted by
the index helper on stderr, independent of the setup logger, and reports use the
existing `task`/`ok` channel in main. No, there is no architecture issue that
needs to be addressed.

#### Performance check by the reviewer for step 2 architecture-minor-fallback (exchange 1) (round 2)

The repairs add one file-existence test per URL and one `wc -l` after
publication. Guard reuse, one mirror resolution per invocation and the preserved
aggregation cost are unchanged. No, there is no performance issue that needs to
be addressed.

#### Coverage check by the reviewer for step 2 architecture-minor-fallback (exchange 1) (round 2)

There is no measured coverage gate in this Bash repository. All new top-level
functions remain referenced and exercised. The regression that round 1 found
uncovered now has fixtures: productive plus empty listings, a short listing and
all-empty listings. No unit-tested class is below 100%, and no top-level symbol
is unreferenced.

Validation plan effects:

The reviewer made no validation-plan edit. The writer's staged Step 2 record now
documents the restored empty-listing skip, the generation reporting, the URL
joining change, the regression fixture that first failed with 111, the
post-review Windows (228 s) and native RHEL (17 s) runs, and recounted sizes
(444, 152 and 310 lines). It matches the staged code.

### Pre-repair mandatory checks and coverage for step 2 architecture-minor-fallback (exchange 1) (round 2)

No repair was made, so this is the final run. Both commands ran on index tree
`0994cb5434057afac4f70a1f6fd00a33a2fe3384` through
`cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat >NUL && !GH!\bin\bash.exe <command>"`:

- `bash src/utils/lint_shell.sh`: `lint_shell: 56 tracked scripts`,
  `lint_shell: clean`, exit 0.
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 2`: 8 metadata and
  9 index groups passed, including the real Windows held-destination case. Both
  preservation checks passed. `Architecture gate: exit=0 elapsed=242s`, exit 0.

`git diff --cached --check` was clean. A scratch-copy probe outside the
repository confirmed the empty-listing and reporting behavior described in the
implementation check.

### Resolved validation set and sources for step 2 architecture-minor-fallback (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (source: project `.review-validation`)
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 2` (source: plan Step 2)

### Resolver drift and direction for step 2 architecture-minor-fallback (exchange 1) (round 2)

No drift: the request's set still equals `.review-validation` plus the plan's Step 2 runner command.

### Repository state around validation for step 2 architecture-minor-fallback (exchange 1) (round 2)

- **Index trees:** request-time, reviewer-entry and assessed trees are all
  `0994cb5434057afac4f70a1f6fd00a33a2fe3384`.
- **Umbrella digest:** unchanged
  (`7e4bdb1e929a7ffbbcf650c1b60287934760f0469ef8599ebde54fab15a16294`).
- **Validation state:** the comparison over the seven staged Step 2 paths
  reports `acceptable: true` with no differences, and the runner's live-tree
  comparison passed.
- **Change since the round 1 tree:** limited to `package_index.sh`,
  `setup_packages.sh`, `verify.architecture-index.sh` and the validation record.
- **Unstaged tracked change:** the protocol transcript, which was neither read
  nor staged.

### Repair inventory for step 2 architecture-minor-fallback (exchange 1) (round 2)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 2 architecture-minor-fallback (exchange 1) (round 2)

`commit-plan-check.bat --format json` was run independently and returned status
0, `state: valid`, `ready: true` and no diagnostics, with the same seven paths
in two groups: `feat(packages): publish guarded exact indexes`, then
`docs(architecture-minor-fallback): record step 2 validation`, last. Group 2's
body now records the twelve injected failures and the review repairs, which
matches the staged record. `a.commit` is accurate and was not amended. The status
0 proves only mechanical grouping.

### Findings and boundaries for step 2 architecture-minor-fallback (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 2 architecture-minor-fallback (exchange 1) (round 2)

No further change is requested for Step 2. Present this advisory commit-ready
recommendation at the human commit gate, then include the review transcript
through the residual continuation, as for Step 1.

### Decision rationale for step 2 architecture-minor-fallback (exchange 1) (round 2)

Decision: commit-ready (advisory).

All six readiness-floor results pass:

- exact identity and an unchanged index tree;
- Step 2 complete, with the three round 1 findings resolved and independently
  re-probed;
- both mandatory commands passing on the final tree, including the real Windows
  held-destination case;
- no reviewer repair and no validation side effect;
- no unresolved or boundary-crossing findings;
- an independently checked, accurate `a.commit`.

The recommendation does not authorize a commit.

### Final reviewer decision for step 2 architecture-minor-fallback (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-2-round-2 -->

## Round 2 by human - Step 2 - human-confirmation

- Recorded: 2026-09-14T19:18:26+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 1 by requestor - Step 3

- Recorded: 2026-09-14T19:51:52+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 3
- Outcome: request

### Review identity for step 3 architecture-minor-fallback (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
Implementation step: 3
Review round: 1

### Code review evidence for step 3 architecture-minor-fallback (round 1)

request_index_tree: 245887f6e97f83a366f3a3a38004cd3bc8b92f26
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.architecture-fallback.sh --step 3 (sources: plan)
- cmd /d /c docs\v0.27.0\verify.architecture-launcher.cmd (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(packages): scope progress and forward resets
group 1 path: src/setups/package_progress.sh
group 1 path: src/setups/setup_packages.sh
group 1 path: src/setups/setup.bat
group 1 path: src/setups/pkgs/.gitignore
group 1 path: docs/v0.27.0/verify.architecture-progress.sh
group 1 path: docs/v0.27.0/verify.architecture-launcher.cmd
group 1 path: docs/v0.27.0/verify.architecture-fallback.sh
group 1 path: docs/v0.27.0/verify.architecture-index.sh
group 1 path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
group 2: docs(architecture-minor-fallback): record step 3 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
staged path: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md
staged path: docs/v0.27.0/verify.architecture-fallback.sh
staged path: docs/v0.27.0/verify.architecture-index.sh
staged path: docs/v0.27.0/verify.architecture-launcher.cmd
staged path: docs/v0.27.0/verify.architecture-progress.sh
staged path: src/setups/package_progress.sh
staged path: src/setups/pkgs/.gitignore
staged path: src/setups/setup.bat
staged path: src/setups/setup_packages.sh
```

### Requestor assessment for step 3 architecture-minor-fallback (round 1)

Step 3 is fully implemented. The validation plan records the exact Yes verdict,
file counts, function reachability, linear progress preparation and retained
setup behavior. No architecture, performance or feature-integrity gap remains
in this step. This Bash/CMD project has no applicable Python coverage percentage.

Final writer checks on 14 September 2026:

- Windows cumulative Step 3: exit 0, 433 seconds, 25 fixture groups and live
  metadata/status/cache preservation passed. This includes the tracked-shell
  lint floor and explicit new-script syntax/ShellCheck checks.
- Native RHEL 9.8 copied-root cumulative Step 3: exit 0, 20 seconds, 24 applicable
  fixture groups and preservation passed, using Bash 5.1.8 and ShellCheck 0.10.0.
- Real CMD launcher gate: exit 0 for eleven cases, including literal percent,
  exclamation and caret characters, dollar/backtick text, regex metacharacters,
  spaces, reset entry forwarding and Bash/step-helper exit 119 boundaries.
- `git diff --check` passed. The root commit-plan checker reports ready with
  all ten staged paths assigned to two groups.

The final interruption fixtures cover both missing state on first selection
and discarded state after an identity change. Failed publication preserves
prior bytes and does not report durable completion. Step 4 live dependency
acceptance, curated cleanup and wiki updates remain pending.

### Implementation report for step 3 architecture-minor-fallback (round 1)

The new progress helper owns normalized active-entry loading, literal four-line
record parsing, identity/membership checks and atomic sibling publication.
Main setup validates its complete argv before progress mutation, pins the
selected list, synchronizes one in-memory snapshot and records each successful
entry. First selections and restarts publish an empty record before package IO.
Valid stored cursors preserve the first matching cursor/repeat resume-after
rule. Explicit resets validate their normalized entry first; invalid resets
return 117 without synchronization or progress changes. Write failures return
116. Direct package requests neither read nor write full-list progress.

CMD consumes its public arguments with `shift`, disables delayed expansion for
literal input and invokes Bash directly with explicit options. It preserves
generic step repeat/reset and the `sdpl` index route, never forwards reset entry
text to the step helper, and maps Bash/helper failures to outer exit 119.

Eight progress fixture groups and eleven actual CMD cases cover the settled
contracts. The cumulative runner includes the new helper/suite. The retained
index fixture's selected-list assertion now checks the record's final field;
the plan inventory explicitly records that small compatibility update.

### Change summary for step 3 architecture-minor-fallback (round 1)

The staged paths are:

- `src/setups/package_progress.sh`
- `src/setups/setup_packages.sh`
- `src/setups/setup.bat`
- `src/setups/pkgs/.gitignore`
- `docs/v0.27.0/verify.architecture-progress.sh`
- `docs/v0.27.0/verify.architecture-launcher.cmd`
- `docs/v0.27.0/verify.architecture-fallback.sh`
- `docs/v0.27.0/verify.architecture-index.sh`
- `docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md`
- `docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md`

Root `a.commit` is formatted and mechanically ready:

1. `feat(packages): scope progress and forward resets`: the nine behavior,
  fixture and plan-inventory paths.
2. `docs(architecture-minor-fallback): record step 3 validation`: the validation
  plan only, following the implementation as the required trailing group.

The umbrella remains pending because Step 4 is not implemented. No curated list,
operator-local property, generated package index or adjacent application tree
is part of this change.

### Writer response for step 3 architecture-minor-fallback (round 1)

Writer response:

This is the first review round for Step 3. Steps 1 and 2 and their review records
are committed. There is no earlier Step 3 reviewer feedback or disagreement.

The writer's final contract pass added first-selection empty-record persistence,
a corresponding interruption fixture and normalized CRLF reset input before
the final green gates. The scope remains package progress and CMD forwarding;
the RHEL dependency acceptance and curated cleanup belong to Step 4. Jenkins
continues to consume tools and package/publish only the application, with no
compilation or tools publication introduced by this step.

### Reviewer focus for step 3 architecture-minor-fallback (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-3-round-1 -->

## Round 1 by reviewer - Step 3

- Recorded: 2026-09-14T20:07:03+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: answer

### Assessed index identity for step 3 architecture-minor-fallback (exchange 1) (round 1)

Baseline index tree: 245887f6e97f83a366f3a3a38004cd3bc8b92f26

Assessed index tree: 876c11a4e3a2f8d2106ecfbdcc6a7c1f3dfa99fd

### Implementation check for step 3 architecture-minor-fallback (exchange 1) (round 1)

Result:

Yes. Step 3 has been fully implemented.

Step 3 implements design Q05 to Q07 as planned.

#### What was verified for step 3 for step 3 architecture-minor-fallback (exchange 1) (round 1)

- **Progress record.** `package_progress_read` accepts exactly the four-line
  `cplx-package-progress-v1` record: CR tolerated per line, no NUL, no extra or
  missing fields, never evaluated. `package_progress_write` publishes through an
  owned `.cplx-progress-*` sibling with `mv -fT`, returns 116 on failure, and
  removes the candidate. The ignore rule covers leftovers.
- **Restart rules.** `package_progress_prepare`:
  - writes a durable empty record for a first selection, a legacy or malformed
    record, a changed architecture or list, or a stale cursor, before any
    package IO;
  - otherwise resumes after the first match of the cursor or
    `CPLX_SP_REPEAT`;
  - lets repeat have no effect with an empty or discarded cursor.

  Membership and iteration use one normalized snapshot of active entries, so a
  list edited mid-run cannot change the order. This is proven by
  `progress_single_snapshot`.
- **Explicit reset.** The entry is validated against that snapshot (a trailing
  CR is stripped) before any write. An unknown entry exits 117, names the
  selected list and leaves the record byte-identical. A valid entry resumes
  after that entry, which is the consolidated design's wording for explicit
  intent. `--reset-list` with `--package`, and `--after-entry` without reset,
  fail with 117 before any mutation. Direct packages never open the progress
  path, even when it is a directory.
- **Setup flow.** `main` validates the whole argv before any IO. Progress is
  published after each successful package, and a publication failure exits 116
  without claiming completion.
- **CMD launcher.** `setup.bat` runs with delayed expansion disabled, consumes
  `packages`, `p_<name>`, `reset` and its entry through `shift`, and calls Bash
  with explicit argv (`--package`, `--reset-list`, `--after-entry`), never raw
  `%*`. The step helper receives only a generic step name, including `sdpl`'s
  `download_packages_list`. Bash and helper failures reach exit 119.

#### Real-environment checks beyond the fixtures for step 3 architecture-minor-fallback (exchange 1) (round 1)

The CMD harness uses recording endpoints and a fixture `senv.bat`, so I ran two
checks against the real environment:

- `bash.exe <Windows path>\src\setups\setup_packages.sh --bogus`, through the
  real `senv.bat`, resolved Git's `bash.exe` first on PATH. The real script
  sourced its helpers from the Windows-form path and stopped with
  `FATAL [117] Unknown package setup argument: '--bogus'` before any IO; the
  tree was unchanged.
- The new `if errorlevel 1 exit /b 119` after `call senv.bat` cannot fire
  spuriously. With a prior ERRORLEVEL of 7, the real `senv.bat` returned 0 both
  with its guard set and cleared.

#### Architecture check by the reviewer for step 3 for step 3 architecture-minor-fallback (exchange 1) (round 1)

Parsing, validation and publication live in `package_progress.sh`; main owns
argv validation, synchronization and logging; CMD only translates its public
interface. No helper has source-time side effects or a network or remote
dependency. The plan edit only records the one-line index-fixture adaptation in
the Step 3 inventory and changes no design. No, there is no architecture issue
that needs to be addressed.

#### Performance check by the reviewer for step 3 for step 3 architecture-minor-fallback (exchange 1) (round 1)

Entries are read once. Membership validation and resume search are each one
linear pass, and each successful package writes one small record. There is no
sort and no metadata re-enumeration. No, there is no performance issue that
needs to be addressed.

#### Coverage check by the reviewer for step 3 for step 3 architecture-minor-fallback (exchange 1) (round 1)

There is no measured coverage gate in this Bash and CMD repository. All four
progress helpers are reached from main, and all eight progress groups and eleven
CMD cases are registered and executed. No unit-tested class is below 100%, and
no top-level symbol is unreferenced.

Validation plan effects:

One reviewer edit is confined to the Step 3 feature-integrity rows of
`docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md`. A new
paragraph before "No existing supported feature is impaired by Step 3" documents
that the launcher interface is now closed.

- **Accepted forms:** no argument, one step name, `packages`,
  `packages <step>`, `packages p_<name>` or `packages reset [entry]`.
- **Extra arguments:** exit 119 before any step helper or setup work.
- **Previous behavior:** the old launcher silently ignored extra words; it
  repeated only the first step and passed the rest to `setup.sh`, which never
  reads them.
- **Also affected:** `build.bat` forwards its non-release parameters through the
  same interface.

The record previously claimed no impairment without mentioning this tightening.
The edit was recorded as a pre-repair blob, attributed cleanly and staged. It is
review metadata and polishing only.

### Pre-repair mandatory checks and coverage for step 3 architecture-minor-fallback (exchange 1) (round 1)

All resolved commands ran on the received index tree
`245887f6e97f83a366f3a3a38004cd3bc8b92f26`. The later reviewer edit changed only
validation-record prose, so these results apply unchanged to the assessed tree.

- `bash src/utils/lint_shell.sh`, through the guard-clearing `senv.bat` form:
  `lint_shell: 57 tracked scripts`, `lint_shell: clean`, exit 0.
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 3`: 8 metadata,
  9 index (including the real Windows held destination) and 8 progress groups
  passed. Both preservation checks passed.
  `Architecture gate: exit=0 elapsed=498s`, exit 0.
- `cmd /d /c docs\v0.27.0\verify.architecture-launcher.cmd`: all 11 cases
  passed (reset, after, direct, conflict, repeat, reset_step, sdpl, literal,
  literal_after, bash_failure, helper_failure), exit 0.

`git diff --cached --check` was clean before and after the reviewer edit. The
two real-environment checks in the implementation check (the Windows-path
invocation and the `senv.bat` ERRORLEVEL reset) left the tree unchanged.

### Resolved validation set and sources for step 3 architecture-minor-fallback (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project `.review-validation`)
- `bash docs/v0.27.0/verify.architecture-fallback.sh --step 3` (source: plan Step 3)
- `cmd /d /c docs\v0.27.0\verify.architecture-launcher.cmd` (source: plan Steps 3 and 4)

### Resolver drift and direction for step 3 architecture-minor-fallback (exchange 1) (round 1)

No drift. The set equals `.review-validation` plus the plan's Step 3 runner
command and its required Windows launcher command. The writer's native RHEL run
is recorded evidence outside the mandatory set, and the reviewer did not repeat
it.

### Repository state around validation for step 3 architecture-minor-fallback (exchange 1) (round 1)

- **Index trees:** request-time and reviewer-entry trees are
  `245887f6e97f83a366f3a3a38004cd3bc8b92f26`. The assessed tree after the staged
  reviewer edit is `876c11a4e3a2f8d2106ecfbdcc6a7c1f3dfa99fd`.
- **Umbrella digest:** unchanged
  (`7e4bdb1e929a7ffbbcf650c1b60287934760f0469ef8599ebde54fab15a16294`).
- **Validation state:** the comparison over the ten staged Step 3 paths reports
  tracked differences only in
  `docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md` and the
  index. Both are the reviewer's Step 3 feature-integrity paragraph and its
  staging, which is permitted review metadata. There are no validation side
  effects; the runner's and launcher's preservation checks passed.
- **Unstaged tracked change:** the protocol transcript, which was neither read
  nor staged.

### Repair inventory for step 3 architecture-minor-fallback (exchange 1) (round 1)

Repairs made:

- docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md (polishing-only review metadata): Step 3 feature-integrity paragraph documents the closed launcher interface and extra-argument exit 119

Paths staged:

- docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.validation.md

### Commit plan assessment for step 3 architecture-minor-fallback (exchange 1) (round 1)

`commit-plan-check.bat --format json` was run independently before and after the
reviewer edit. Both times it returned status 0, `state: valid`, `ready: true`
and no diagnostics, with ten staged paths in two groups:

1. `feat(packages): scope progress and forward resets`: the progress helper,
   setup script, launcher, package ignore file, progress, launcher, runner and
   index fixtures, and the plan inventory note;
2. `docs(architecture-minor-fallback): record step 3 validation`: the validation
   record, last.

The reviewer edit stays in group 2's path. Membership, order and subjects remain
accurate, and `a.commit` was not amended. The status 0 proves only mechanical
grouping.

### Findings and boundaries for step 3 architecture-minor-fallback (exchange 1) (round 1)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 3 architecture-minor-fallback (exchange 1) (round 1)

No change is requested for Step 3.

1. Review the staged reviewer paragraph in the Step 3 feature-integrity section
   of the validation record. It documents that `setup.bat` now rejects extra
   arguments with 119, where they used to be silently ignored.
2. Present this advisory commit-ready recommendation at the human commit gate,
   and include the review transcript through the residual continuation.
3. When Step 4 updates `wiki/reference/commands.md`, mention the closed launcher
   interface there too.

### Decision rationale for step 3 architecture-minor-fallback (exchange 1) (round 1)

Decision: commit-ready (advisory).

The readiness floor passes:

- exact identity;
- Step 3 complete against the plan and the consolidated design;
- all three mandatory commands passing, including 25 cumulative groups and 11
  real CMD cases, plus two real-environment checks the fixtures cannot provide;
- attributable staged scope;
- no unresolved or boundary-crossing findings;
- an accurate `a.commit`.

The only reviewer edit is polishing-only review metadata in the Step 3
validation rows; it closes a documentation gap about the stricter launcher
arguments. No code, test, acceptance or grouping change was made. The
recommendation does not authorize a commit.

### Final reviewer decision for step 3 architecture-minor-fallback (exchange 1) (round 1)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-3-round-1 -->

## Round 1 by human - Step 3 - human-confirmation

- Recorded: 2026-09-14T20:11:28+02:00
- Exchange: code/code/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-1 -->
