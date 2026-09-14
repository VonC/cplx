# v0.27.0 architecture minor fallback implementation tracking and validation

No, it is not implemented.

Track the four steps in [the implementation plan](plan.v0.27.0.architecture-minor-fallback.md).
Steps 1-3 are implemented and verified. Step 4 and real-host dependency acceptance remain pending.

## File-based IO cost clarification for architecture fallback implementation

Carry forward the plan's bounded inventory reads, lazy pinned mirror value,
in-memory active-entry validation, invocation-owned index scratch and single
atomic progress record. Preserve existing RPM lookup and aggregation costs.
Review fixture call counts and real-host evidence without inferring success
from a skipped package loop.

## Complexity clarification for architecture fallback implementation

Selection is linear in eligible inventory size and active-list handling is
linear in list length. No per-package metadata enumeration is planned.
The existing index aggregation and package lookup costs remain applicable.
There is no new elapsed-time threshold or Python coverage requirement.

## Step 1: Select curated metadata with isolated verification

### Analysis of Step 1 implementation state

Yes. Step 1 has been fully implemented.

The pure selector, list and active-mirror adapters, source-safe main guard and
isolated cumulative Bash gate satisfy the Step 1 matrix. Ordinary package setup
retains its existing exact-only flow until Step 2 connects the new helpers.

### Goal for Step 1

Provide exact-first, integer-minor selection through one pure selector and per-kind adapters.

### Step 1 improvement expectations

- Preserve authoritative exact inputs and whole machine identities.
- Prove ordering and exclusion with generated fixture permutations.
- Make selected source diagnostics actionable without selection-side writes.

### What was implemented for Step 1

- [Metadata helper](../../src/setups/package_metadata.sh): exact lookup before
  parsing, normalized integer comparison, whole-machine boundaries, highest
  lower/lowest higher selection and original source identity. Equal candidate
  numeric minors use literal-key C ordering for deterministic ties. An equal
  numeric minor to the request remains excluded from fallback. Mirror names
  follow the existing reader's canonical addressing: a dotted version spelling
  cannot become an exact definition or shadow the underscore property name.
- [Setup entry point](../../src/setups/setup_packages.sh): source the helper and
  guard `main` with `BASH_SOURCE`; existing execution and comments are preserved.
- [Cumulative runner](verify.architecture-fallback.sh) and
  [metadata matrix](verify.architecture-metadata.sh): copied setup/utils/echos
  fixtures, denied SSH/SCP/curl calls, per-case processes and live-tree
  preservation on normal and unsuccessful exits. Future unfinished step gates
  explicitly fail. The runner keeps `.review-validation` unchanged and executes
  its tracked ShellCheck floor before explicit syntax/lint checks and fixtures.
- **Executed evidence, 2026-09-14, Windows CMD and configured Git Bash**:
  `cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat && !GH!\bin\bash.exe docs/v0.27.0/verify.architecture-fallback.sh --step 1"`
  exited 0 in 35 seconds on the reviewer-repaired tree. All eight case groups
  passed, as did the 55-script
  mandatory lint floor, explicit effort checks and real-tree preservation.
  The [round 1 reviewer](review.code.v0.27.0.architecture-minor-fallback.md)
  ran both resolved commands before and after its canonical-property repair;
  the writer inspected and accepted the staged patch and its two added cases.
  The writer's preceding gate passed in 34 seconds, including a whitespace-only
  fixture representation correction found before publication.
  Before production edits, the same fixture entry failed because the helper
  was absent; the failure-exit preservation check passed in that run too.
- **Static verification**: the planned `package_metadata_|BASH_SOURCE` search,
  `git diff --check` and changed-file inspection passed. Only the four Step 1
  code/test paths and this validation record changed. Tests were not rerun as
  part of this separate implementation check.

Physical lines were recounted before production editing and after validation:

| File | Before | After | Advisory estimate |
| --- | --- | --- | --- |
| `src/setups/setup_packages.sh` | 569 | 575 | Existing main |
| `src/setups/package_metadata.sh` | 0 | 201 | 260 |
| `verify.architecture-fallback.sh` | 0 | 139 | 200 |
| `verify.architecture-metadata.sh` | 0 | 212 | 260 |

The new files are below their advisory estimates. No Python line ceiling applies.

### New types or classes introduced for Step 1

No classes were introduced. `package_metadata_select` operates on caller-owned
indexed inventories and returns an associative result plus indexed diagnostics.
`package_metadata_list` and `package_metadata_mirror` own the filesystem and
active-properties boundaries; the mirror adapter also returns ordered URLs.
Number parsing/comparison, trimming, reading and substitution reporting remain
small helpers inside the same file. Runner utilities and the eight metadata
case functions provide the verification seam.

### Architecture check for Step 1

The selector contains policy and Bash variable operations only. Adapters own
reads and successful substitution logging; the single read function permits
permission-independent failure injection. No selector calls setup, remote
commands, property writers or progress handling. Data never passes through
evaluated property text or diagnostic stdout. The main entry point imports
the helper without running setup when sourced.

No, there is no architecture issue that needs to be addressed for Step 1.

### Performance check for Step 1

Selection scans the candidate inventory at most twice, with no candidate sort.
Integer comparison uses normalized digit lengths and C-order comparison, so
leading zeroes do not invoke octal arithmetic and large integers do not overflow.
The list adapter enumerates only its tool directory when exact input is absent
and reads only the selected file. Mirror parsing reads active properties once
and retains first definitions in an associative table. The call-count case
proved one properties read followed by one selected-list read.

The repaired-tree gate took 35 seconds; no arbitrary timing threshold applies.
The runner batches metadata hashing and inventories cache paths/sizes/timestamps
without hashing cached RPM contents. No new quadratic or sorting operation was
added to the selector. No, there is no performance issue that needs addressing.

### Unit test coverage check for Step 1

This Bash repository has no Python class coverage gate. The approved plan uses
a named behavioral matrix, not a claimed line-coverage percentage:

| Case group | Verified behavior |
| --- | --- |
| `metadata_exact_and_lists` | Empty/comment-only exact authority, malformed exact identity, retained requested/source identity, substitution log, exclusion of indexes and other tools |
| `metadata_order_permutations` | All six candidate permutations for three requests (18 checks), 10-versus-9 ordering, deterministic numeric ties and clean selector stdout |
| `metadata_boundaries` | Distribution, major and whole-machine exclusions; major-only exact and fallback boundaries; equal leading-zero spelling excluded; large integer ordering and failure diagnostics |
| `metadata_mirrors` | First definition only, empty first exact absent, trimmed ordered URLs, CRLF, literal unevaluated values, active file only, major-only property, stale-output clearing, dotted-name shadowing excluded and dotted-only exact absent |
| `metadata_read_failures` | Injected unreadability for a present exact list and active properties, plus invalid present list directory; no fallback conceals either failure |
| `metadata_bounded_reads` | One active properties read and one selected-list read |
| `metadata_source_guard` | Copied main/helper sourcing without persistent changes or network calls; resolved main path stays in the fixture |
| `metadata_fatal_exit` | Actual legacy fatal exit 87 in a subprocess, followed by live-tree preservation comparison |

All new production and harness top-level functions have test or internal
callers. No unit-tested Python class needs completing, because none is involved.
No, there are no unreferenced top-level symbols in the new files.

### Feature integrity for Step 1

Empty exact lists remain authoritative; damaged present inputs fail; invalid
nonempty mirror text remains available for the ordinary download failure path.
List and mirror results are independent, and selected identities never replace
the detected architecture. The existing package flow changes only at its source
guard and helper import in this step.

Live setup metadata, Git status (including ignored paths), and cache inventory
matched before and after the gate, including its deliberately fatal fixture.
No Jenkins, RHEL host, compilation or packaging action was needed for this
isolated step. Native Linux and actual CMD launcher acceptance remain assigned
to the later plan steps; this record makes no claim that those ran.

## Step 2: Carry selections through exact-index generation and use

### Analysis of Step 2 implementation state

Yes. Step 2 has been fully implemented.

The invocation retains its selected list and lazy mirror value, guards the
detected-key index independently of completion, and publishes only a complete
nonempty candidate. The cumulative gate passed on Windows Git Bash and native
Linux. Windows also proved that a handle denying delete sharing blocks
replacement while preserving old bytes, followed by successful recovery.

### Goal for Step 2

Propagate selected inputs through synchronization, generation, downloading and remote list copying.

### Step 2 improvement expectations

- Keep generated indexes keyed to the detected architecture.
- Generate on missing/empty exact index or either refresh flag despite completion.
- Preserve old index bytes on failure while failing the current invocation.

### What was implemented for Step 2

| File | Completed change | Physical lines before / after |
| --- | --- | --- |
| `src/setups/setup_packages.sh` | Current-shell context; selected-list synchronization and copy; ordinary/direct index guard; read-only lookup; pinned download URLs and generation reporting | 575 / 444 |
| `src/setups/package_metadata.sh` | Context initialization, lazy mirror pinning and individual URL whitespace normalization | 201 / 223 |
| `src/setups/package_index.sh` | Exact availability, checked extraction/aggregation, owned sibling scratch/candidate and replacement | 0 / 152 |
| `src/setups/pkgs/.gitignore` | Bounded `.cplx-index-*` crash-leftover exclusion | 2 / 3 |
| `docs/v0.27.0/verify.architecture-fallback.sh` | Cumulative Step 2 dispatch, copied helper and explicit effort checks | 139 / 154 |
| `docs/v0.27.0/verify.architecture-index.sh` | Guard matrix, consumer wiring, failure injection, empty-listing/reporting regression and actual Windows handle fixture | 0 / 310 |

Availability checks the exact nonempty file and both reload flags before any
completion information. Generation succeeds once per invocation; a completion
marker cannot conceal a missing/empty index or requested refresh. Failed refresh
never proceeds using the old index during that invocation. Completion is written
only after publication; completion failure leaves the valid new index available
to a later invocation but fails the current one.

The extraction patterns keep their first-success order, including single-quoted
href support. Per-listing and final aggregation retain last-entry-per-prefix
selection and sorted output. Every pipeline component is checked, including an
early grep error followed by a later no-match status. Scratch cleanup owns only
the unique paths created for that generation.

Round 1 review identified an unintended hard failure for a valid listing with
no package links. Restored behavior warns with that URL and skips its absent
output, allowing other URLs to contribute. All-empty listings still fail at
the final index boundary with 112. Fetch failure, a page under 50 lines and
extraction component errors retain their hard failures. Generation reports the
pinned mirror property and URL count through `task`, then the published index
path and package count through `ok`; guard reuse emits neither message.

### New types or classes introduced for Step 2

No classes or Python modules were introduced. `package_metadata_context` creates
a caller-owned associative array for detected identity, exact index, selected
list identities, mirror identity/value and refresh state. The ordered URL array
is caller-owned. `package_metadata_pin_mirrors` updates that context in the
current shell, so lazy state survives generation and repeated package downloads.

The index helper exposes availability, extraction, aggregation, candidate-write
and generation functions. Only generation and listing IO use subshells; their
results are files/statuses and they do not own invocation metadata state.

### Architecture check for Step 2

Selection policy remains independent of setup IO. Metadata adapters own
inventory reads and mirror pinning; the index adapter owns listing and
publication IO; main owns synchronization, completion and remote orchestration.
There is no dependency from the selector back into network or setup operations.
All new helper entry points are referenced by orchestration or another helper,
and the cleanup callback is reached through the generation EXIT trap.

The main script shrank by 131 lines through responsibility extraction. All new
and extended Bash helpers/fixtures remain below their plan advisory estimates;
the Python line ceiling is inapplicable. No architecture issue needs fixing.

### Performance check for Step 2

The 48-cell guard matrix checks absent/empty/nonempty index, present/absent
completion, neither/either/both refresh flags and ordinary/direct flow. Two
successive package synchronizations in each cell prove one generation and one
required mirror resolution, or neither for reusable indexes without refresh.
Another fixture counts one active-property read across generation and multiple
downloads, including after the fixture properties change.

Selection remains linear; the index aggregation/sorting cost is preserved.
No per-package inventory scan, content snapshot or whole-cache hashing was added.
The post-review Windows gate completed in 228 seconds. Native Linux completed
in 17 seconds with its separately required Windows check clearly labeled. These are
observations, with no elapsed-time threshold. No performance issue needs fixing.

### Unit test coverage check for Step 2

The approved Bash adaptation applies. There is no Python class coverage gate
or claimed line-coverage percentage. Static inspection finds every new top-level
helper referenced, including the trap callback; the behavioral matrix exercises
the index and consumer boundaries.

| Fixture group | Evidence |
| --- | --- |
| `index_guard_matrix` | All 48 availability/completion/flags/route combinations; one refresh per invocation |
| `index_direct_built_and_empty` | Direct built package bypasses index/mirrors; empty ordinary list still prepares an index |
| `index_lookup_read_only` | Missing lookup fails without creating a placeholder |
| `index_generation_publication` | Detected-key publication, independent mirror fallback, productive plus empty listing with warning, established extraction/aggregation, cleanup and generation-only reporting |
| `index_generation_failures` | Twelve injected fetch, short listing, all-empty listings, extraction, masked extraction, aggregation, final aggregation, empty output, sibling creation/write, rename and completion failures; later reuse |
| `index_pinned_mirrors_and_cache` | One mirror read, ordered retries, edited properties remain unobserved in the invocation, offline cache/index reuse |
| `index_terminal_downloads` | Direct main with actual download/retry functions, bounded output paths, terminal retrieval/lookup failures, no second minor, lazy absent-mirror failure |
| `index_selected_list_copy` | Synchronization and remote `dependencies.list` use the same fallback path |
| `index_windows_held_destination` | Actual separate PowerShell handle denies delete sharing; publication returns 115, old bytes remain and released-handle retry succeeds |

Windows command: `cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat && !GH!\bin\bash.exe docs/v0.27.0/verify.architecture-fallback.sh --step 2"`.
It returned 0 with all eight metadata and nine index fixture groups passing.
The tracked-script floor covered 56 scripts, with the effort fixtures also
checked explicitly. The pre-review run covered 55 scripts before staging the
new helper; the reviewer independently verified all 56 and the final staged
Windows gate in 213 seconds before requesting the repairs recorded here.

Native Linux command: `bash docs/v0.27.0/verify.architecture-fallback.sh --step 2`
in an isolated temporary checkout made from committed source plus the six
Step 2 paths. Environment: Linux 5.14.0 on RHEL 9.8 x86_64, Bash 5.1.8,
deployed Git wrapper and an isolated official ShellCheck 0.10.0 binary. It
returned 0, with 56 staged scripts passing lint, 16 applicable fixture groups
passing, and an explicit separately required Windows check message. The
temporary remote checkout and validator were removed on exit.

Before implementation, the new gate failed because `package_metadata_context`
did not exist, while preservation checks still passed. The expanded Windows
run and both post-review runs passed preservation. `git diff --check` is clean.
No unit-tested class needs completing; no new top-level helper is unreferenced.

The review regression fixture was added before its repair and failed with 111
at `index_generation_publication` after 113 seconds; live-tree preservation
still passed. Its assertions also cover warning identity, property/URL count,
published path/package count and silence on a second guard call.

### Feature integrity for Step 2

Detected architecture, exact index naming, local RPM cache paths, remote staging
and installation entry points remain intact. List and mirror selection stay
independent. Direct built packages bypass indexes and mirrors; ordinary empty
lists retain index preparation. Lookup, fetch and completion failures remain
unsuccessful and actionable. Failed generation leaves prior index bytes intact;
successful publication followed by completion failure retains the new index.

Download URL joining deliberately removes only one trailing slash from the
mirror prefix before adding the package name. The previous global double-slash
collapse also changed `https://` to `https:/`; preserving the scheme gives the
configured URL its intended meaning. Ordered retry fixtures exercise the
resulting `https://` URLs. Empty-listing skip behavior and successful generation
reporting were restored after review as described above.

Real setup metadata, ignored files, logs, indexes and RPM inventory were unchanged
by the Windows gate. Linux ran only copied fixtures in a temporary checkout.
No live RHEL package setup, Jenkins job, compilation or packaging ran. Scoped
progress and actual CMD reset tests remain Step 3; curated cleanup and real
Python/Git setup acceptance remain Step 4. The umbrella item remains pending.

## Step 3: Persist scoped progress and repair CMD reset forwarding

### Analysis of Step 3 implementation state

Yes. Step 3 has been fully implemented.

Progress now belongs to the detected key and selected list. A discarded cursor
is replaced before package synchronization, while valid cursors retain the
approved resume-after behavior. CMD forwards explicit reset intent once and
preserves literal expressions. The cumulative Windows and native Linux gates,
real CMD fixtures and live-tree preservation checks passed on 14 September 2026.

### Goal for Step 3

Bind durable resume state to detected key and selected list, and forward reset intent once.

### Step 3 improvement expectations

- Restart safely for changed, legacy, malformed or stale progress.
- Preserve approved resume-after and repeat behavior.
- Validate resets and preserve direct-package progress isolation across real CMD and Git Bash.

### What was implemented for Step 3

- **Scoped data and atomic publication**: `src/setups/package_progress.sh`
  reads the exact four-line `cplx-package-progress-v1` record, removes one
  terminal CR per line and rejects unknown versions, missing/extra fields,
  unterminated records, embedded separators and NUL data. It never sources or
  evaluates progress. Checked writes use owned `.cplx-progress-*` siblings and
  atomic replacement; failures return 116 and remove the owned candidate.
- **One list snapshot**: `src/setups/setup_packages.sh` loads normalized active
  entries once, preserving package text and existing blank/comment handling.
  Identity and cursor membership use that same array before iteration.
  Legacy, malformed, changed-identity and stale records restart and report why.
  First selections and restarts publish an empty cursor before package IO.
- **Resume and reset**: a valid cursor resumes after the first cursor or repeat
  match. Empty or discarded cursors ignore repeat. Explicit reset validates
  the normalized entry first, then publishes its cursor; an invalid entry names
  the selected list, returns 117 and preserves progress without synchronization.
  Reset without an entry starts at the beginning. Missing option values,
  reset/direct combinations and after-entry without reset fail before progress
  changes. Direct packages leave list progress untouched.
- **CMD boundary**: `src/setups/setup.bat` consumes package/reset arguments with
  `shift`, calls Bash with explicit argv and keeps delayed expansion disabled
  for literal input. It no longer deletes or echoes a marker or forwards raw
  `%*`. Generic repeat, `r_<step>` and the `sdpl` package-index route still call
  the step helper. Bash and step-helper failures reach launcher exit 119.
- **Fixtures and inventory**: `verify.architecture-progress.sh` adds eight
  copied-root groups; `verify.architecture-launcher.cmd` runs eleven real CMD
  cases against copied endpoints and fixture logging/environment setup.
  `verify.architecture-fallback.sh` includes Step 3, and the retained index
  fixture checks the new record's final field. The plan names that additional
  assertion update. `src/setups/pkgs/.gitignore` covers progress scratch names.

| File | Before | After |
| --- | --- | --- |
| `src/setups/package_progress.sh` | 0 | 112 |
| `src/setups/setup_packages.sh` | 444 | 442 |
| `src/setups/setup.bat` | 100 | 121 |
| `src/setups/pkgs/.gitignore` | 3 | 4 |
| `docs/v0.27.0/verify.architecture-progress.sh` | 0 | 304 |
| `docs/v0.27.0/verify.architecture-launcher.cmd` | 0 | 72 |
| `docs/v0.27.0/verify.architecture-fallback.sh` | 154 | 168 |
| `docs/v0.27.0/verify.architecture-index.sh` | 310 | 310 |

The new helper and fixture files stay within the plan's advisory estimates.
Python line bands and the 650-line Python ceiling are inapplicable.

### New types or classes introduced for Step 3

No production classes were introduced. `package_progress_entries` reads active
entries and comment diagnostics; `package_progress_read` parses literal data;
`package_progress_write` owns complete-record publication; and
`package_progress_prepare` checks identity/membership and returns the start
position, restart reason and resume entry through an associative array.
The CMD fixture adapter prepares recording endpoints and checks the actual
driver process's argv; it does not implement the production argument parser.

### Architecture check for Step 3

Progress parsing, validation and persistence live in the dedicated Bash helper.
Main setup owns argument validation, selected metadata, synchronization and
logging. CMD translates its public interface to explicit Bash arguments and
delegates selection/state ownership to Bash. The helper has no setup side
effects when sourced and does not depend on network or remote installation.
This script-based project has no DDD class layers; the relevant adapter
boundaries and existing metadata/index responsibilities remain intact.

No, there is nothing that needs to be addressed for Step 3 architecture.

### Performance check for Step 3

Active entries are read once into memory. Membership validation and finding the
first resume match each scan at most the selected list once, for O(n) total
progress preparation and O(n) storage. Iteration uses that snapshot, including
when the on-disk list changes during synchronization. Each successful package
publishes one four-field record, without metadata enumeration or mirror
resolution inside the new progress logic. Existing package lookup, download
and remote-copy costs are unchanged. No new quadratic or sorting path exists.

No, there is no performance issue that needs to be addressed for Step 3.

### Unit test coverage check for Step 3

This project has no Python class coverage gate. `.review-validation` defines
the tracked-shell ShellCheck floor; the plan adds executable Bash fixtures and
the actual CMD gate. These integration checks do not establish a coverage
percentage. Static inspection finds all four progress helpers reached from
main or another helper. Every fixture group is registered in its suite, and
the launcher fixture adapter is reached by the executable CMD gate.

Writer evidence, reused by this implementation check without rerunning tests:

- Final Windows cumulative gate: the plan's guard-cleared `senv.bat` command
  with Git Bash and `verify.architecture-fallback.sh --step 3` returned 0 in
  433 seconds; 25 groups passed, including the Windows held-destination check.
  The mandatory tracked-shell floor and explicit new-helper/fixture syntax and
  ShellCheck checks passed. Live metadata/status/cache preservation passed.
- Final native RHEL 9.8 copied-root gate: Bash 5.1.8 and ShellCheck 0.10.0 ran
  `bash docs/v0.27.0/verify.architecture-fallback.sh --step 3`, returning 0 in
  20 seconds with all 24 applicable groups and preservation passing. Windows
  checks were reported separately, not counted as native passes. This used an
  owned temporary source tree, not live dependency setup.
- `cmd /d /c docs\v0.27.0\verify.architecture-launcher.cmd` returned 0 for all
  eleven cases: reset, reset-after, direct, invalid direct/reset, generic
  repeat, generic reset, `sdpl`, two literal-expression paths, Bash failure and
  helper failure. Literal inputs include spaces, regex metacharacters,
  exclamation/percent signs, ampersands, carets, dollar text and backticks.
- Recovery checks interrupt before the first package after both a first
  selection and an identity restart. The durable record has an empty cursor;
  restoring the old architecture still cannot recover the discarded cursor.
  Create/write/rename failures preserve prior bytes; a successful package with
  failed progress publication is repeated on the next invocation.
- The remaining matrix covers CRLF records/lists/reset input, an unterminated
  last list entry, empty/comment lists, duplicate/final cursors, all relative
  repeat positions, shell-looking data, invalid reset preservation, direct
  isolation and a selected list edited after its snapshot was loaded.

No, there is no unit-tested class below 100% that needs completing for Step 3.
No, there is no unreferenced top-level symbol in the Step 3 production/helper
or verification code outside a coverage gate.

### Feature integrity for Step 3

The cumulative gate retains Steps 1 and 2, including selected-list copying,
the exact-index guard matrix, pinned mirrors and cached/offline reuse.
Comment, resume, per-entry and completion reporting remains, with explicit
restart and progress-publication diagnostics added. A completed entry is
reported only after its record is published. The final-entry cursor reports
that all entries were already processed.

The planned `rg` inspection found no raw `%*` forwarding or marker writes in
CMD. Remaining `last` matches describe the record, URL retry order or remote
exit status; reset and step-helper matches implement the explicit interface.
Raw argument logging was removed alongside shell re-parsing to keep literal
expressions intact; Bash still reports direct packages and progress outcomes.
The fixtures do not initialize real package setup or launch a log viewer.

The launcher interface is now closed. It accepts no argument, one step name,
`packages`, `packages <step>`, `packages p_<name>` or `packages reset [entry]`.
Any further argument exits 119 before any step helper or setup work. The
previous launcher silently ignored extra words: it repeated only the first
step and passed the rest to `setup.sh`, which never reads them. `build.bat`
forwards its non-release parameters through this same interface.

No existing supported feature is impaired by Step 3. Step 4's real dependency
acceptance, curated cleanup and wiki work remain pending, so the umbrella row
and document-level implementation status remain incomplete.

## Step 4: Demonstrate RHEL fallback, clean curated metadata and document it

### Analysis of Step 4 implementation state

Not started. Step 4 is not implemented because the controlled RHEL acceptance, curated cleanup and operator documentation changes have not been implemented.

### Goal for Step 4

Prove actual Python/Git dependency synchronization on RHEL 9.8 before and after limited curated cleanup.

### Step 4 improvement expectations

- Correct the retained Python list and both Git list typos, with paired 9.8 Git corrections and equivalence proof before removals.
- Complete controlled and final-tree RHEL setup without an exact local mirror override.
- Under approved Q07 B, generate a fresh detected-key index in the controlled checkout and complete Python/Git setup in a separate remote target. Prove served-file mirror fallback, cache/staged reuse and unchanged live-target state.
- Pass AC1-AC12 fixtures and Windows launcher checks, with sanitized evidence and accurate documentation.

### What was implemented for Step 4

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 4

_(empty — no check has taken place yet.)_.

### Architecture check for Step 4

_(empty — no check has taken place yet.)_.

### Performance check for Step 4

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 4

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 4

_(empty — no check has taken place yet.)_.
