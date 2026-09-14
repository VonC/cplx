# v0.27.0 architecture minor fallback implementation plan

Implement selected metadata throughout package setup while keeping the detected
architecture authoritative for generated indexes and local downloads.

Reference: [approved design](design.v0.27.0.architecture-minor-fallback.md),
[approved requirement](feature-request.v0.27.0.architecture-minor-fallback.md),
and [umbrella item 5](draft.v0.27.0.debian-agent-tools.md).

## Plan goal and ordered delivery for architecture fallback

1. Add the pure selector, metadata adapters and isolated Bash verification.
2. Wire the invocation context, exact-index guard and safe index publication.
3. Implement scoped progress and restore CMD reset argument forwarding.
4. Prove RHEL setup, remove equivalent curated definitions and update operator docs.

The requirement's eleven answers and the design's seven answers are settled.
This plan assigns files, concrete interfaces, execution order and evidence.
RHEL prepares dependencies and packages/deploys tools and the private application.
Jenkins Debian fetches and deploys prebuilt tools, checks out application source
and runs tests, then packages and publishes only the application to Nexus.
Item 4's runtime-closure protection stays downstream; SQLite integration belongs
to item 6 and final tools rebuilding/platform delivery to item 7.

## Confirmed code and test-tree facts for this plan

The authoring boundary is Windows CMD launching Git Bash; RHEL operations run
through SSH. The new Bash functions must also be testable in isolated native
Linux fixtures, without assuming that native Linux proves CMD behavior.

`setup_packages.sh` currently checks completion before exact-index availability,
reconstructs the list for remote copying, uses a bare cursor and touches a
missing lookup index. Generation uses shared scratch names and truncates the
published file. `setup.bat` writes CRLF progress itself and forwards unshifted
`%*`, allowing a reset entry to reach the step helper a second time.

Plan round 2 inspection of the held 9.8 index found 56 active Python entries,
all resolved and locally cached, with a legacy marker dated 2026-08-23. Git has
49 active entries: 47 resolve, 22 are cached, 25 resolvable RPMs are uncached,
and there is no Git marker. Both Git lists contain `libcom_err,` and `libxslti`;
the intended names `libcom_err` and `libxslt` each have one exact index match.
The reviewer also found that the indexed `unzip-6.0-59.el9.x86_64.rpm` was not
served by any configured mirror. These are inspection-time observations to
recheck during implementation. A held-index, no-extraction host run therefore
cannot establish AC7. Proposed Q07 B uses a separate remote target and fresh
index, while Q08 A makes both Git corrections explicit before equivalence
checking. AC7 continues to require real Python and Git setup.

The repository has `check.bat`, which explicitly uses Git Bash to run
`src/utils/lint_shell.sh`. The mandatory floor in `.review-validation` is
`bash src/utils/lint_shell.sh`; it checks tracked shell scripts outside
`docs/`. There is no project Python test tree, `pyproject.toml` or
`GROUNDHOG.md`. The existing versioned harnesses demonstrate Bash fixture
testing. Do not extend the 9,136-line closure harness for this independent area.

Adapt the standard plan's Python test layout and `ghog day` default to this
repository: add focused Bash scripts beside this plan, run the mandatory lint
floor plus explicit effort checks, and introduce no Python runtime or test
dependency. Python `__init__.py`, pytest/PBT packages and Python coverage gates
are inapplicable. Assess ordering properties with generated Bash fixture
permutations instead. Coverage evidence is a named behavioral case matrix,
not an invented line-coverage percentage.

### Physical-line inventory at plan authoring

Counts include blank lines and the final unterminated line, if any, at
`642ef28`. Recount the files changed by each step immediately before editing.

| Existing file | Lines | Planned use |
| --- | --- | --- |
| `src/setups/setup_packages.sh` | 569 | Steps 1-3: source seam and orchestration |
| `src/setups/setup.bat` | 100 | Step 3: parse and forward arguments |
| `src/setups/pkgs/.gitignore` | 2 | Step 2: owned scratch patterns |
| `src/setups/setup.tpl.properties` | 26 | Step 4: curated mirror cleanup and comment |
| `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt` | 59 | Step 4: correct retained list |
| `src/setups/pkgs/python/python_rhel_9.8_x86_64.txt` | 59 | Step 4: prove equivalent, then remove |
| `src/setups/pkgs/git/git_rhel_9.6_x86_64.txt` | 49 | Step 4: correct two dependency names |
| `src/setups/pkgs/git/git_rhel_9.8_x86_64.txt` | 49 | Step 4: apply matching corrections, prove equivalent, then remove |
| `wiki/explanation/the-architecture-key.md` | 93 | Step 4: identity and ordering |
| `wiki/explanation/checkpoints-and-resume.md` | 56 | Step 4: scoped progress |
| `wiki/how-to/survive-a-server-os-upgrade.md` | 85 | Step 4: automatic fallback procedure |
| `wiki/how-to/resume-or-repeat-a-step.md` | 65 | Step 4: correct reset and resume examples |
| `wiki/how-to/add-or-fix-a-package-mirror.md` | 59 | Step 4: active configuration and refresh |
| `wiki/reference/package-list-formats.md` | 101 | Step 4: presence, naming, progress record |
| `wiki/reference/cplx-variables.md` | 53 | Step 4: both reload flags and repeat semantics |
| `wiki/reference/commands.md` | 63 | Step 4: reset/reset-after-entry command contract |
| `wiki/reference/exit-codes.md` | 101 | Step 4: new failures and launcher boundary |
| `src/setups/setup.sh` | 434 | Read-only detected-key preservation |
| `src/utils/properties.sh` | 87 | Read-only active-property compatibility |
| `src/utils/steps.sh` | 498 | Read-only completion and repeat integration |
| `src/setups/env/bin/packages_management.sh` | 2068 | Read-only remote installation behavior |
| `src/setups/pkgs/packages_rhel_9.6_x86_64.txt` | 5799 | Existing generated snapshot, outside cleanup |
| `src/setups/pkgs/packages_rhel_9.8_x86_64.txt` | 5898 | Existing generated snapshot, outside cleanup |
| `src/utils/lint_shell.sh` | 43 | Existing mandatory gate |
| `check.bat` | 26 | Existing Windows gate entry point |
| `.review-validation` | 21 | Existing mandatory command inventory |
| `.gitignore` | 33 | Existing ignored `last` coverage |
| `wiki/reference/steps-file-format.md` | 53 | Read-only general step contract |

No Python source is involved, so the standard bands below 550, 550-650 and above
650, and its mandatory 650-line Python ceiling, have no applicable files.
The Bash main script's 569 lines are a maintainability signal: extract index
generation and progress responsibilities rather than duplicating them there.
All Bash size estimates below are advisory. Existing large shell scripts and
generated indexes are neither targets for growth nor mandatory unrelated splits.

New files start at zero lines:

| New file | Responsibility | Advisory final size |
| --- | --- | --- |
| `src/setups/package_metadata.sh` | Selector, adapters, invocation context | 260 |
| `src/setups/package_index.sh` | Guard, generation scratch and publication | 250 |
| `src/setups/package_progress.sh` | Active entries, progress and cursor handling | 240 |
| `docs/v0.27.0/verify.architecture-fallback.sh` | Cumulative runner and fixture utilities | 200 |
| `docs/v0.27.0/verify.architecture-metadata.sh` | Metadata policy cases | 260 |
| `docs/v0.27.0/verify.architecture-index.sh` | Index/consumer integration cases | 320 |
| `docs/v0.27.0/verify.architecture-progress.sh` | Progress and interruption cases | 320 |
| `docs/v0.27.0/verify.architecture-launcher.cmd` | Actual CMD-to-Git-Bash fixture cases | 180 |
| `docs/v0.27.0/acceptance.architecture-minor-fallback.md` | Sanitized host and cleanup evidence | 180 |

The plan and its validation document are new documentation. Their size is
recorded when written and on review; no code-file ceiling applies.

## File-based IO cost clarification for architecture fallback

Carry forward the approved selection and invocation-context rules without
adding a freshness mechanism or a content snapshot.

| Operation | Required IO behavior |
| --- | --- |
| Tool-list selection | Enumerate only the selected tool directory once; never enumerate generated indexes as candidates. |
| Mirror selection | Read active properties at first need, retain each first definition, and pin the chosen ordered value for the invocation. |
| Package loop | Reuse selected identities and loaded active entries; do not re-enumerate metadata per package. Existing index lookup/download IO remains. |
| Index generation | Use owned scratch for listing extraction and one complete sibling candidate; publish once after success and nonempty validation. |
| Progress | Read one record; atomically replace it on a required restart/reset and after each successful synchronization. |
| Tests | Create an isolated temporary tree per case group, share fixture helpers, and remove only invocation-owned fixture paths. |

Candidate selection is linear in candidate count using integer comparisons;
there is no need to sort the inventory. Active-list reading and cursor validation
are linear in list length. Preserve the existing index aggregation/sorting cost
and package lookup behavior; this effort does not promise constant-time RPM
resolution. Do not introduce per-entry metadata scans or whole-tree hashing.

A Step 0 timeout/xfail phase is unnecessary: no latency contract or asynchronous
response path is introduced. Record elapsed gate durations as evidence, and use
call counters to prove bounded metadata reads. No arbitrary timing threshold is
a release condition.

## Concrete helper and persistence interfaces

Use Bash functions with a `package_metadata_`, `package_index_` or
`package_progress_` prefix in the corresponding helper. Pass results through
caller-owned Bash variables/arrays, never by mixing human diagnostics with
machine-readable stdout or evaluating file content. Keep sourcing side-effect
free with a guarded `main` in `setup_packages.sh`.

The context records detected key, selected repository-relative list path,
exact index path, optional resolved mirror identity/value/ordered URLs and a
refresh-served flag. Update context in the current shell; a command-substitution
subshell must not silently discard its lazy mirror or refresh state.

The progress representation is exactly four LF-terminated literal lines:

```text
cplx-package-progress-v1
architecture=rhel_9.8_x86_64
list=src/setups/pkgs/python/python_rhel_9.6_x86_64.txt
last=zlib-devel
```

The same shape with `last=` is a durable empty cursor. Parse fixed prefixes and
exact record length; reject unknown versions, missing/extra fields and embedded
line separators. Read CRLF records by removing one terminal CR per line.
Treat legacy/malformed records as restart input, never executable shell text.
Preserve entry text other than line-ending normalization and existing blank/
comment handling; use the same normalized active-entry array for validation
and iteration. Do not trim or rewrite a package expression into another one.

CMD forwards `--reset-list` and optionally `--after-entry <entry>` to Bash;
`--package <name>` remains the direct form. Consume `packages`, `p_<name>`,
`reset` and its optional entry once. Preserve the ordinary step repeat/reset
argument path, including `sdpl`, without forwarding reset entry text to it.
Do not pass raw `%*` alongside the parsed package arguments.
Reject reset plus direct package intent and `--after-entry` without reset
before any progress mutation. Require a value where an argument needs one.

Reserve package-setup failures 114 for metadata resolution, 115 for index
publication, 116 for progress IO and 117 for invalid package/reset arguments.
Keep existing extraction, lookup, retrieval and completion failures and CMD's
119 outer boundary. Diagnostics carry requested identity, metadata kind and
selected/considered sources where applicable; tests assert the actionable
message and unsuccessful process status. Codes 114 and 115 also exist in
remote `packages_management.sh`; the exit-code reference must attribute each
number to its script rather than combining the two process namespaces.

## Shared execution checklist and ready commands

For each step, use its cumulative `--step N` gate; do not run a future step's
unfinished cases or add temporary expected-failure markers.

1. Count physical lines before editing using `[IO.File]::ReadAllLines(path).Length` in PowerShell. In Bash use `awk 'END {print NR}' file`, including blank and unterminated final lines.
2. Add the named failure/regression cases before production edits and retain the first useful failure.
3. Implement the step and run its cumulative gate. Build the fixture root by copying the required `src/setups`, `src/utils` and `src/echos` files, preserving their relative layout and never linking them: `readlink -f` must resolve the copied main script inside that root. Seed synthetic properties, steps, indexes, progress and RPM fixtures there; never copy the real RPM cache into unit fixtures. Run each case in a subshell because `fatal` calls `exit`. PATH stubs for SSH, SCP and curl record expected calls, reject undeclared calls and assert every local output path belongs to the fixture root.
4. Before and after the gate, compare `git status --porcelain --ignored -- src/setups` and a content/existence manifest of the real setup scripts, properties, steps, indexes, ignored `pkgs/*/last`, logs and temporary-file targets, including `pkgs.log` and `temp.pkgs.txt`. Fail if these differ. Record an inventory of existing RPM cache paths/sizes/timestamps; stub output-path assertions prevent writes there without hashing all cached RPM bytes. Run the preservation comparison even after a case fails.
5. Inspect the step's listed `rg` checks, `git diff --check`, changed-file set and before/after line counts.
6. Repair failures and rerun only the affected gate, then the cumulative command after those fixes. Record commands, environment and results in the implementation validation document.
7. Recount touched files and record advisory variances. If a future change actually adds Python, apply the shared 650-line ceiling and split rules before marking that step complete.

The new runner accepts `--step 1` through `--step 4`, includes every earlier
step's fixture cases, and returns nonzero on any failure. It runs the mandatory
`bash src/utils/lint_shell.sh` floor first, then explicit `bash -n` and
`shellcheck` over the effort's current scripts and new production helpers,
including untracked helpers that the tracked-file floor cannot yet see.
It then executes the requested fixture groups. Do not add version-specific
commands to `.review-validation`. Do not call `check.bat` or pytest directly.

From Windows, run setup and validation in the same CMD process. `GH` comes
from the user environment and `senv.bat` requires it. Clear the inherited
project guard so setup rebuilds the PATH exposing ShellCheck. Delayed expansion
reads `GH` after the setup call:

```powershell
cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat && !GH!\bin\bash.exe docs/v0.27.0/verify.architecture-fallback.sh --step N"
```

Here `N` is replaced by the current integer step. Run the harness as a script
file in the configured Git Bash, never the unrelated Windows/WSL `bash.exe`.
This inline command assumes the configured `GH` path contains no spaces.
For a Git installation under a path containing spaces, put the same guard
clear, `call <NUL senv.bat` and quoted `"%GH%\bin\bash.exe"` invocation on
separate lines of an ignored temporary `.cmd` file, with setup failure
propagation, and invoke that script through CMD.
In an explicitly prepared native Linux environment the counterpart is:

```sh
bash docs/v0.27.0/verify.architecture-fallback.sh --step N
```

Steps 3 and 4 additionally require, on Windows:

```cmd
cmd /d /c docs\v0.27.0\verify.architecture-launcher.cmd
```

The launcher harness uses the real CMD interpreter and Git Bash with a copied
launcher, a fixture `senv.bat`, recording setup/step endpoints and stub logging.
It must not initialize real package setup or launch a log viewer. Linux fixture
success is not a substitute for this Windows command. A native Linux run reports
the Windows check as separately required, never silently passed.

## Step 1: Select curated metadata with isolated verification

### Step 1 analysis and intent

The current exact-only lookup cannot retain an older curated definition after a
minor upgrade. Add the approved selector and adapters as one responsibility,
with no setup IO during selection. Preserve major-only exact keys, whole
machine names, independent list/mirror decisions and per-kind absence rules.
This step implements design Q01 and establishes the test seam for Q02.
Use the shared execution checklist and ready commands with `--step 1`.

### Step 1 implementation

Files involved:

- `src/setups/package_metadata.sh` (new, to be created).
- `src/setups/setup_packages.sh` (existing, to be updated).
- `docs/v0.27.0/verify.architecture-fallback.sh` (new, to be created).
- `docs/v0.27.0/verify.architecture-metadata.sh` (new, to be created).

Tests first: exact wins, empty/comment-only exact lists, trimmed-empty exact
mirrors, first duplicate property value including empty-first/nonempty-later,
unreadable present inputs, different distribution/major/whole machine,
major-only exact success and fallback exclusion, leading-zero/equal-numeric
minor spellings, and minor 10 versus minor 9. Generate candidate permutations
and assert invariant selection: highest lower, otherwise lowest higher.
Assert selection performs no writes or external fetches and reports exclusions.
Use permission-independent injected read failure where privileged execution
would defeat a chmod-only unreadability test.

Implement one selector plus list and active-properties adapters. Read only the
active properties file; enumerate a duplicate key once with its first trimmed
value. Parse the version boundary without splitting `x86_64` or translating
every property underscore. Exact resolution precedes fallback parsing.
Keep original source identity in successful results and log substitutions.
Add the source-safe main guard; ordinary execution remains unchanged until
Step 2 wires the context.

Completion: the cumulative Step 1 gate passes with the selection matrix, and
sourcing the main/helper scripts makes no network calls or persistent writes.
The real-tree preservation comparison passes even when a fixture case exits
through `fatal`.
Inspect `rg -n 'package_metadata_|BASH_SOURCE' src/setups/setup_packages.sh src/setups/package_metadata.sh`.

### Step 1 addendums

Line-budget checkpoint: main script baseline 569; three new files baseline 0.
Python policy band and 650-line ceiling: inapplicable to these Bash files.
New-file estimates are advisory as inventoried above. Split fixture data from
runner utilities if growth mixes responsibilities; do not copy selector logic
into tests as their oracle.

Full workflow timing readiness: record Step 1 cumulative runtime once green.
Time-gated status: no xfail or elapsed-time gate; permutation/call-count checks
establish ordering and bounded IO.

## Step 2: Carry selections through exact-index generation and use

### Step 2 analysis and intent

The main flow can skip required generation, lose a valid old index on failure
and copy a different list from the one synchronized. Extract generation and
wire the current-shell invocation context through every affected consumer.
Implement design Q02-Q04 while retaining ordinary package resolution, ordered
URL retries, cache paths and remote staging. Use the shared checklist and
ready commands with `--step 2`.

### Step 2 implementation

Files involved:

- `src/setups/package_index.sh` (new, to be created).
- `src/setups/package_metadata.sh` (existing after Step 1, to be updated).
- `src/setups/setup_packages.sh` (existing, to be updated).
- `src/setups/pkgs/.gitignore` (existing, to be updated).
- `docs/v0.27.0/verify.architecture-index.sh` (new, to be created).
- `docs/v0.27.0/verify.architecture-fallback.sh` (existing after Step 1, to be updated).

Tests first: cross product of absent/zero/nonempty exact index, completion
present/absent, neither/either/both reload flags, and ordinary/direct normal
package invocation. Check one refresh per invocation; direct `_` requests
bypass index/mirrors and ordinary empty lists still prepare the index.
Cover selected-list copy identity, differing list/mirror selections, pinned
mirror value after a fixture property edit, exact cached/offline success,
ordered URL retries and final failure without another minor selection.

Inject listing fetch, extraction/aggregation, empty output, sibling-write,
rename and completion-record failures. Check old-index bytes remain unchanged
until successful publication, failed refresh never continues through the old
file, later no-refresh invocation may reuse it, and completion failure leaves
the new index valid but the invocation unsuccessful. Verify lookup never
creates a placeholder. On Windows also exercise replacement while another
process holds the destination open without delete sharing. Use a temporary
PowerShell script holding `[IO.File]::Open(path, 'Open', 'Read', 'Read')` and
a readiness/release handshake. First assert the replace attempt actually
failed, then check old bytes, release the handle and verify recovery.

Extract `download_packages_list`/`process_packages_url` generation work into
the index helper, retaining the established HTML extraction and aggregation
rules. Check command statuses, not only output size. Use a unique
`.cplx-index-<detected-key>.*` sibling scratch directory and sibling candidate
under `pkgs/`; publish only the completed nonempty candidate on the same
filesystem. Remove only owned scratch on handled failure/success. Ignore crash
leftovers with bounded `.cplx-index-*` patterns. They are not index candidates.

Wire ordinary flow: select list, guard exact index, synchronize, copy that
selected path as `dependencies.list`, then install. Wire the applicable guard
before direct normal-package lookup. Lookup itself is read-only. Resolve and
pin mirrors lazily for generation or an actual download; propagate failure
without changing the detected architecture or attempting another minor.
Mark completion only after publication and serve explicit refresh once.

Completion: Step 2 cumulative fixtures pass on Git Bash, including the held
destination case, and native Linux fixture checks establish shell portability.
Inspect `rg -n 'touch|temp_|pkgs_url_name|packages_for_tools|package_index_' src/setups/setup_packages.sh src/setups/package_index.sh`
to verify removal of old placeholder/shared-scratch and reconstruction paths.

### Step 2 addendums

Line-budget checkpoint: main baseline 569 at authoring, use Step 1 actual count;
ignore file baseline 2; metadata/runner use Step 1 counts; new index/helper
test files baseline 0. Python 650-line policy: inapplicable. Extracting index
responsibility is required; a particular resulting Bash line count is advisory.
Keep download/copy orchestration in main and index scratch ownership in its
helper.

Full workflow timing readiness: run the shared Step 2 gate in each declared
environment and record duration. Time-gated status: call-count assertions
require one mirror resolution and one requested refresh per invocation;
no elapsed-time threshold.

## Step 3: Persist scoped progress and repair CMD reset forwarding

### Step 3 analysis and intent

A cursor from another selected list/key or one that no longer exists can skip
every package. CMD also corrupts reset-after-entry flow by writing bare state
and forwarding the consumed entry. Implement design Q05-Q07 as one durable
progress record and one explicit launcher-to-Bash reset interface. Preserve
download/copy reuse and the approved first-match resume-after semantics.
Use the shared checklist and ready commands with `--step 3` plus the Windows
launcher command.

### Step 3 implementation

Files involved:

- `src/setups/package_progress.sh` (new, to be created).
- `src/setups/setup_packages.sh` (existing, to be updated).
- `src/setups/setup.bat` (existing, to be updated).
- `src/setups/pkgs/.gitignore` (existing after Step 2, to be updated).
- `docs/v0.27.0/verify.architecture-progress.sh` (new, to be created).
- `docs/v0.27.0/verify.architecture-launcher.cmd` (new, to be created).
- `docs/v0.27.0/verify.architecture-fallback.sh` (existing after Step 1, to be updated).

Tests first: same identity resumes after an active cursor; changed list/key,
legacy/malformed record and stale cursor restart from the first active entry;
missing and empty cursors start normally. Cover empty/comment lists, CRLF
normalization, the final active entry, failed synchronization and failed state
publication. Interrupt immediately after a restart and before the first package,
then assert the discarded cursor cannot return on the next invocation.
Inject a shell-looking field and prove it is never evaluated.

For valid cursors, test repeat before cursor, cursor before repeat, absent
repeat and matching repeat/cursor: resume after the first matching active
entry. Empty/restarted cursor makes repeat ineffective. For explicit reset,
test no entry, valid entry and invalid entry; the latter preserves progress
and performs no synchronization. Direct package requests leave list progress
byte-identical; reset/direct combinations fail before progress changes.
Use actual CMD fixtures for `packages reset`, `packages reset zlib-devel`,
`packages p_zlib-devel`, `packages p_zlib-devel reset`, generic step repeat,
`r_<step>` and `packages download_packages_list`; record received argv and
step-helper invocations to prove the reset entry is consumed exactly once.

Load normalized active entries once. Parse the fixed four-line record, validate
identity and cursor membership before syncing, and use atomic
`.cplx-progress-*` siblings under the tool directory for required empty/reset
records and each successful entry. Add ignore coverage for those scratch names;
the existing root `last` rule already covers the committed record path.
Explicit invalid resets are validated before writing. Fail a progress write
instead of claiming completion. Direct package flow does not read/write this
state.

Replace CMD's marker deletion/echo with parsed reset forwarding. Remove raw
unshifted `%*` from the package invocation, consume the entry with `shift`,
preserve supported step-helper behavior and propagate the Bash exit code
through the existing launcher error boundary. Keep argument quoting and literal
package expressions intact across CMD and Git Bash.

Completion: cumulative Step 3 and real CMD fixtures pass; interruption evidence
proves discarded cursors stay discarded and ordinary reuse remains available.
Inspect `rg -n '%\*|last|reset|after-entry|repeat_or_reset_step' src/setups/setup.bat src/setups/package_progress.sh src/setups/setup_packages.sh`
and classify remaining matches rather than forbidding all logging of arguments.

### Step 3 addendums

Line-budget checkpoint: CMD baseline 100; main and ignore use Step 2 actual
counts; new progress and progress/launcher harnesses baseline 0; runner uses
Step 2 count. Python bands/650-line ceiling: inapplicable. Advisory estimates
remain in the inventory. Extract progress parsing/validation/publication into
its helper and keep command orchestration in main/CMD.

Full workflow timing readiness: shared Step 3 gate plus actual Windows launcher
fixtures. Time-gated status: no timeout/xfail gate; deterministic interruption
and publication-failure injection own the recovery checks.

## Step 4: Demonstrate RHEL fallback, clean curated metadata and document it

### Step 4 analysis and intent

Passing fixture selection alone cannot demonstrate dependency preparation: an
old final cursor or a local exact mirror override can conceal an untested path.
Complete AC1-AC12 with controlled fixtures and real RHEL 9.8 setup evidence,
then perform only the approved equivalent curated cleanup. Keep dependency
lookup failures visible rather than masking them with another minor or a
manually staged dependency. Use the shared checklist and ready commands with
`--step 4` and the Windows launcher command.

### Step 4 implementation

Files involved:

- `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt` (existing, to be updated).
- `src/setups/pkgs/python/python_rhel_9.8_x86_64.txt` (existing, to be removed after acceptance).
- `src/setups/pkgs/git/git_rhel_9.6_x86_64.txt` (existing, to be updated under proposed Q08 A).
- `src/setups/pkgs/git/git_rhel_9.8_x86_64.txt` (existing, to receive matching corrections, then be removed after acceptance).
- `src/setups/setup.tpl.properties` (existing, to be updated).
- `docs/v0.27.0/verify.architecture-fallback.sh` (existing after Step 1, to be updated).
- `docs/v0.27.0/acceptance.architecture-minor-fallback.md` (new, to be created).
- `wiki/explanation/the-architecture-key.md` (existing, to be updated).
- `wiki/explanation/checkpoints-and-resume.md` (existing, to be updated).
- `wiki/how-to/survive-a-server-os-upgrade.md` (existing, to be updated).
- `wiki/how-to/resume-or-repeat-a-step.md` (existing, to be updated).
- `wiki/how-to/add-or-fix-a-package-mirror.md` (existing, to be updated).
- `wiki/reference/package-list-formats.md` (existing, to be updated).
- `wiki/reference/cplx-variables.md` (existing, to be updated).
- `wiki/reference/commands.md` (existing, to be updated).
- `wiki/reference/exit-codes.md` (existing, to be updated).

Tests first: add a full entry-point fixture using only corrected 9.6 Python/Git
lists and 9.6 active mirrors, no index for either minor, and legacy final-entry
state. Assert actual per-entry synchronization and matching selected-list copy,
generated 9.8 identity, fallback diagnostics and unchanged detected key.
Add a control with a deliberately distinct exact override, and a same-identity
second run proving ordinary resume/cache reuse. Preserve a negative case for a
package lookup/retrieval failure: no successful fallback claim or alternative
minor retry.

Execute rollout in this order:

1. Correct `zlib-dev` to `zlib-devel` in the retained 9.6 Python list. Under proposed Q08 A, correct `libcom_err,` to `libcom_err` and `libxslti` to `libxslt` in both 9.6 and 9.8 Git lists. Record each intended name's unique index match and the exact two-line paired changes. Prove corrected Python and Git 9.6/9.8 equivalence and tracked mirror-value equivalence before any removal. Do not normalize these names at runtime or hide other lookup failures.
2. Prepare a controlled authoring checkout/configuration for real RHEL 9.8 dependency setup using the implemented scripts and retained curated inputs. Exclude exact 9.8 curated lists and the exact active 9.8 mirror key there. Copy active properties and relevant local RPM cache entries; clear copied step completion and both reload flags. Set the copied `cplx_path` to a unique, absent sibling directory on the same RHEL host, outside the live cplx tree, as specified below. Preserve the actual detected architecture. Record revision, configuration origins and digests; template values alone are not runtime configuration. Copy the Python legacy marker; for Git explicitly create a synthetic legacy final-entry marker in the controlled checkout, since no original exists. Label copied versus synthetic evidence.
3. Bootstrap the separate remote target under proposed Q07 B using the manifest below. Remove the copied 9.8 generated index only from the controlled checkout, retain its committed original in the authoring tree, and invoke the package index-generation entry point with selected 9.6 mirrors. Record nonempty publication under the detected 9.8 filename. Preflight every corrected Python/Git expression against this fresh index for ordinary resolution, then prove each selected RPM is cached or currently downloadable. Preserve ordinary missing/ambiguous/unavailable errors as blockers; no cross-minor index substitution or manual RPM injection.
4. Run ordinary setup for Python and Git through CMD/Git Bash to the isolated RHEL target, starting from the recorded legacy markers. Record selected list/property, generated 9.8 index identity, restart and every successful active-entry synchronization, then actual remote installation completion. Per tool, omit one cache seed entry whose indexed filename a HEAD request confirms is currently served by a selected mirror; if no original cached entry qualifies, obtain one through the ordinary downloader in the controlled tree before the measured run. Retain other matching cached entries to prove reuse. New extraction is permitted only beneath the isolated target. Compare live-target staging/installed-flag inventories before and after and require them unchanged. Include the three corrected names, a valid same-identity resume control and isolated installed-state reuse on a second invocation. Run the controlled checkout's setup from a CMD process that clears that checkout's own `NO_MORE_SENV_` guard, and confirm that derived values such as `project_dir_unix` name the controlled checkout. Before and after each host pass, record the authoring tree's `git status --porcelain --ignored -- src/setups` and its `pkgs/*/last` bytes, and require them unchanged.
5. After controlled acceptance passes, remove only the tracked redundant Python/Git 9.8 lists and 9.8 mirror property, and revise its per-minor-copy comment. Preserve both generated index snapshots in the authoring tree and operator properties. Repeat setup from a controlled copy of the resulting curated tree, using the same isolated target and generated index, reseeding labeled legacy progress and one currently served cache omission per tool. Prove synchronization, lazy mirror fallback, cache/staged reuse and installation completion; repeat the live-target preservation comparison. Retain final successful evidence.
6. Update the listed wiki pages for selection ordering, separate detected/selected identities, per-kind absence, exact-index refresh despite completion, atomic progress/restart, and reset-after-entry. Use `sp reset <entry>` or `s packages reset <entry>`; correct the current singular `package` example and the claim of resuming at/reprocessing the supplied entry.
7. Run all four cumulative fixture groups on Git Bash and native Linux, the actual CMD launcher cases, the mandatory lint floor and documentation/diff checks. Record an AC1-AC12 result-to-evidence mapping and the controlled configuration facts with sensitive terms replaced.

Before host execution, record the concrete bootstrap commands and resolved
paths in the acceptance evidence. Stage the tracked contents of
`src/setups/env/` at the new root, `src/utils/` at its `bin/`, `src/echos/` at
its `echos/`, and `src/install/env/` at its `tools/`, matching the existing
`copy_the_environment` layout. Create `certs/` and a copied, adjusted
`cplx.properties` with the required services, architecture extension and matching
check basenames. Create the Python/Git tool directories and local relative
`current`/`tool` links using recorded existing version labels before sourcing
`.env`; then run the existing remote `tools/setup` for each tool. This only
prepares directories and links. Switch the isolated `tools/tool` link to the
tool being tested before each package invocation. Do not run the general
`setup.sh` main, `setenv`, configure, build, package or deployment entry points.

Resolve and assert every remote root, tool link, package directory and extraction
root is beneath the newly created target, with no links into the live tree.
Audit the account's startup profile and the existing `.env` import chain before
execution; preserve their behavior and stop if they redirect writable state
outside that target. `.env` sources the account's `~/.profile` before it
reassigns `HOME`. Record that profile's digest and the files it sources, and
stop if any of them sources a cplx `.env` or writes beneath the live tree.
Use only existing package-management code for remote
installation, with no remote stubs. Keep the isolated directory as diagnostic
evidence until verification is complete; cleanup is limited to that recorded,
owned directory after absolute-path containment checks. This acceptance setup
changes no production environment/bootstrap interfaces.

The acceptance document contains commands, sanitized environment identity,
case outcomes, active-entry totals and evidence references. Store bulky/raw host
logs under ignored `a.*` paths; include sufficient sanitized excerpts or
summaries in versioned evidence to audit actual work, not only a final exit code.
Failure to complete the required RHEL setup leaves Step 4 incomplete.

Jenkins execution is not needed to prove this RHEL metadata resolver. Any
additional application smoke evidence must fetch/deploy existing tools and
check out/test application source, with application-only packaging/publication;
it must not compile, build or publish tools. This item does not claim the later
tools rebuild or full downstream platform release has been performed.

Completion: controlled pre-removal and final-tree RHEL Python/Git setup pass;
curated equivalence and limited removals are proven; the full fixture/launcher
gate passes; operator documentation matches the approved behavior. Inspect
`rg -n '9[._]8|zlib-dev|reset|CPLX_SP_REPEAT' src/setups/setup.tpl.properties src/setups/pkgs/python wiki/explanation/the-architecture-key.md wiki/how-to/survive-a-server-os-upgrade.md wiki/how-to/resume-or-repeat-a-step.md wiki/reference/cplx-variables.md`
and confirm the diff contains no generated-index cleanup or operator data.
Update implementation tracking only from executed evidence; the umbrella item
remains pending until implementation-check confirms final completion.

### Step 4 addendums

Line-budget checkpoint: Python curated list 59, retained Git list 49,
removed lists 59/49, template
26; wiki baselines 93/56/85/65/59/101/53/63/101 in the inventory; runner uses
Step 3 actual count; acceptance document baseline 0. These are text/Bash files:
Python code bands and 650-line ceiling are inapplicable. Keep bulky raw evidence
out of the prose document; its 180-line estimate is advisory.

Full workflow timing readiness: cumulative Step 4, Windows launcher and both
controlled/final RHEL runs. Record fixture versus network/remote durations
separately so mirror latency is not confused with selector IO.
Time-gated status: no elapsed-time gate or compiler check; actual setup
completion and preservation controls are mandatory.

## Open questions for the v0.27.0 architecture minor fallback implementation plan

These proposed implementation answers do not reopen the approved requirement or design.

### Q01: Helper file allocation

Should the three approved responsibilities live in three focused helpers or one combined helper beside setup_packages.sh?

#### BBQ for Q01

A cook can keep separate drawers for ingredient labels, preparation tools and order tickets. In this picture: the drawers are the metadata, index and progress helper files; the cook is setup_packages.sh.

#### Options for Q01

- Option A: Create package_metadata.sh, package_index.sh and package_progress.sh.
  - Pro: Keeps extraction and tests aligned with the four implementation steps.
  - Con: Adds three fixed source files and requires clear shared-context ownership.
- Option B: Put the same approved responsibilities in one package_setup_helpers.sh.
  - Pro: Uses one additional source statement and fewer files.
  - Con: Mixes unrelated state and IO code and creates another large helper.

#### Recommended option for Q01

Option A. Use the three inventoried helpers. Their fixed source cost is small and the split removes generation and progress code from the 569-line main script.

#### Answer to Q01: option A

Proposed answer: A. Use the three inventoried helpers. Their fixed source cost is small and the split removes generation and progress code from the 569-line main script.

### Q02: Literal progress record syntax

Which literal representation should implement the approved single versioned record with architecture, selected list and cursor?

#### BBQ for Q02

A delivery ticket can use four labeled lines or one tightly packed row. In this picture: the ticket is the atomic progress file, its labels are the version and identity/cursor fields, and the reader is the Bash parser.

#### Options for Q02

- Option A: Use the four-line, fixed-prefix LF record specified in the plan, with CRLF read normalization.
  - Pro: Easy to inspect and reject malformed records without evaluation or escaping machinery.
  - Con: Requires exact field/line-count checks and forbids embedded newlines.
- Option B: Use one versioned tab-separated line with explicit escaping for field separators.
  - Pro: Compact and potentially extensible for arbitrary field text.
  - Con: Adds an escaping/unescaping implementation and more malformed-input cases.

#### Recommended option for Q02

Option A. Use the fixed four-line representation. Curated list paths and active entries already have line-oriented identities, and literal parsing keeps recovery checks small.

#### Answer to Q02: option A

Proposed answer: A. Use the fixed four-line representation. Curated list paths and active entries already have line-oriented identities, and literal parsing keeps recovery checks small.

### Q03: Explicit reset argument spelling

Which concrete argument form should CMD use for the design-approved reset intent after consuming operator input?

#### BBQ for Q03

A dispatcher can send a restart instruction and an optional stop name, or two differently named restart instructions. In this picture: the dispatcher is CMD, the receiver is Bash and the stop name is the reset-after entry.

#### Options for Q03

- Option A: Forward --reset-list, optionally followed by --after-entry <entry>, alongside parsed package arguments only.
  - Pro: Makes the reset intent explicit and lets Bash reject invalid combinations uniformly.
  - Con: Needs a validation rule for --after-entry without --reset-list.
- Option B: Forward --reset-list for an empty reset and --reset-after <entry> for a reset cursor.
  - Pro: Each valid reset form is represented by one option.
  - Con: Introduces two reset operation spellings and an extra mutual-exclusion check.

#### Recommended option for Q03

Option A. Use --reset-list with optional --after-entry as specified. Both shells can test a single reset-intent flag; raw unshifted arguments never accompany the parsed package request.

#### Answer to Q03: option A

Proposed answer: A. Use --reset-list with optional --after-entry as specified. Both shells can test a single reset-intent flag; raw unshifted arguments never accompany the parsed package request.

### Q04: Bash verification file organization

Should the new cumulative fixture runner source focused metadata/index/progress suites, or contain all cases itself?

#### BBQ for Q04

A test workshop can use one checklist with separate stations, or one long checklist at a single bench. In this picture: the checklist is the cumulative runner and the stations are the focused Bash case files.

#### Options for Q04

- Option A: Use the runner plus three focused Bash case scripts and a separate actual CMD fixture harness.
  - Pro: Keeps each step's regression ownership readable and avoids extending the large closed closure harness.
  - Con: Requires shared fixture utilities and clear source-only test suite conventions.
- Option B: Keep all Bash cases and utilities in one new versioned harness, with the CMD harness still separate.
  - Pro: Simplifies locating the complete fixture suite.
  - Con: Risks rapid growth and makes later step-specific changes harder to review.

#### Recommended option for Q04

Option A. Use the focused suites and cumulative runner. No Python test package is needed; mandatory repository lint plus explicit effort lint and behavioral cases form the gate.

#### Answer to Q04: option A

Proposed answer: A. Use the focused suites and cumulative runner. No Python test package is needed; mandatory repository lint plus explicit effort lint and behavioral cases form the gate. Copy the required setup/utils/echos files into each fixture layout, never link them, and run cases in subshells because fatal exits. Recording network stubs reject undeclared calls and local outputs outside that root. Compare real-tree status and setup state bytes before/after even on failure; use cache inventory and stub output-path assertions instead of hashing or copying the real RPM cache for unit tests.

### Q05: Windows validation timing

Should the Windows held-destination check and actual launcher fixtures be required in their owning steps, or collected only in final acceptance?

#### BBQ for Q05

A bridge inspection can test each joint when installed or wait until the complete bridge opens. In this picture: the joints are index replacement and CMD forwarding, their installation stages are Steps 2 and 3, and bridge opening is Step 4.

#### Options for Q05

- Option A: Require the held-open destination check in Step 2 and actual CMD/Git Bash forwarding checks in Step 3; repeat both in Step 4.
  - Pro: Finds platform-specific defects before later code depends on them.
  - Con: Needs Windows fixture support during implementation rather than only at rollout.
- Option B: Run native Linux fixtures in intermediate steps and defer both Windows checks to Step 4.
  - Pro: Allows earlier work to proceed with a Linux-only execution environment.
  - Con: Can mark intermediate slices done while their authoring-platform behavior is still unproven.

#### Recommended option for Q05

Option A. Require Windows checks in the owning steps. Native Linux cannot prove Windows rename failure behavior or CMD argument consumption, and this working environment already supplies Windows.

#### Answer to Q05: option A

Proposed answer: A. Require Windows checks in the owning steps. Native Linux cannot prove Windows rename failure behavior or CMD argument consumption, and this working environment already supplies Windows. Hold the destination without delete sharing using a PowerShell File.Open read/read handle and assert that replacement actually fails before testing preservation and recovery.

### Q06: Controlled RHEL acceptance workspace

How should implementation stage the approved pre-removal demonstration while excluding exact 9.8 inputs and preserving operator configuration?

#### BBQ for Q06

A rehearsal can use a separate stage or rearrange the live stage and put everything back. In this picture: the rehearsal is fallback acceptance, the stage is the local authoring checkout/configuration, and the props are curated lists and active mirror keys.

#### Options for Q06

- Option A: Use a controlled authoring checkout/configuration with only retained curated inputs, then remove proven duplicates in the working tree and repeat final-tree acceptance.
  - Pro: Keeps operator properties and existing indexes outside cleanup and makes the absence of exact overrides auditable.
  - Con: Requires recording which script revision and configuration the controlled run used.
- Option B: Temporarily back up and remove exact curated/configuration entries in the current authoring tree, test, restore, then perform approved removals.
  - Pro: Uses one checkout and fewer copied fixture files.
  - Con: Interruption can leave the operator's working configuration temporarily altered and complicates evidence ownership.

#### Recommended option for Q06

Option A. Use the controlled checkout/configuration and record its revision and inputs. Preflight every active expression and leave Step 4 incomplete if ordinary package/data failures prevent the required full Python/Git setup.

#### Answer to Q06: option A

Proposed answer: A. Use the controlled checkout/configuration and record its revision and inputs. Seed ignored active properties, legacy progress and relevant local RPMs by copy, with origins and digests. Preflight every active expression and leave Step 4 incomplete if ordinary package/data failures prevent the required full Python/Git setup. Controlled per-tool cache omissions exercise lazy mirror fallback while other seeded entries prove reuse.

### Q07: Remote target and index used for RHEL acceptance

Which remote target and index should both host acceptance passes use, given
the stale held-index Git RPM and AC7's required Python and Git setup?

#### BBQ for Q07

A rehearsal can use the existing kitchen with its prepared ingredients, a
second kitchen, or replace the live kitchen's ingredients as it runs.
In this picture: the kitchen is the remote cplx target, ingredients are RPM
versions, the recipe is the generated index, and the rehearsal is host acceptance.

#### Options for Q07

- Option A: Use the live target with the committed 9.8 index held and require already-installed/staged versions.
  - Pro: Limits changes to the existing target.
  - Con: The observed unavailable Git RPM makes full AC7 acceptance unreachable under these controls.
- Option B: Bootstrap a separate remote cplx target and generate a fresh detected-key index in the controlled authoring checkout.
  - Pro: Exercises generation, Python/Git synchronization and extraction on real RHEL while preserving the live target.
  - Con: Requires the documented bootstrap manifest, path checks and additional remote storage.
- Option C: Use the live target and allow index regeneration and new package extraction.
  - Pro: Exercises generation and installation together in the existing directory.
  - Con: Refreshes existing dependency roots ahead of later umbrella work.

#### Recommended option for Q07

Option B. Use the documented existing environment/bootstrap materials in a
unique remote sibling target, allow extraction only there and preserve the
live-target inventories. Generate the index through the implemented resolver,
then preflight all corrected active entries. Choose cache omissions only after
a HEAD check proves the indexed filename is currently served by a selected
mirror. Keep both Python and Git mandatory; unavailable packages remain
ordinary setup blockers, not reasons to narrow AC7.

#### Answer to Q07: option B

Proposed answer: B. Use the isolated target and fresh index with the bootstrap,
containment, served-file, reuse and preservation checks in Step 4. Both host
passes must complete Python and Git setup. The previous A answer was only a
proposal; requirement and design approvals are unchanged.

### Q08: Paired Git list corrections before equivalence checking

Which curated files should receive the two evidenced Git dependency-name
corrections before the approved equivalence check and 9.8 removal?

#### BBQ for Q08

Two copies of a shopping list contain the same misspelled ingredients.
In this picture: the copies are the 9.6 and 9.8 Git lists, spelling corrections
are the two dependency names, and comparing the copies is the cleanup gate.

#### Options for Q08

- Option A: Correct libcom_err, to libcom_err and libxslti to libxslt in both Git lists, prove equality, then remove the redundant 9.8 list after acceptance.
  - Pro: Leaves a correct retained input and an exact, reviewable equivalence proof before removal.
  - Con: Adds two explicit corrections in the retained list and matching temporary edits to the list being removed.
- Option B: Correct only the retained 9.6 list and account for the two known differences in a normalized comparison.
  - Pro: Avoids temporary edits to the list being removed.
  - Con: Replaces simple byte equality with a special comparison and leaves the exact override broken before removal.

#### Recommended option for Q08

Option A. Apply the same two evidenced corrections to both lists, record each
intended name's unique index match and prove direct equality. This is an
explicit addition to Step 4's file edits, subject to the plan's human approval;
it adds no dependency or runtime normalization and preserves the approved
Python/Git acceptance scope and correction-before-removal ordering.

#### Answer to Q08: option A

Proposed answer: A. Correct both copies before comparison and acceptance, then
remove only the proven redundant 9.8 copy. Record the two Git corrections
alongside the already-approved Python correction. Do not implement these
changes during specification review.
This extends the requirement's Q10 curated correction from one entry to three;
approving this plan is where that extension is decided.
