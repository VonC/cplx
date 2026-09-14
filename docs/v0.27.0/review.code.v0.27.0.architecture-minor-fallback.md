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
