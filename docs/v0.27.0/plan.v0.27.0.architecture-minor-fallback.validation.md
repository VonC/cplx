# v0.27.0 architecture minor fallback implementation tracking and validation

Yes, it is implemented.

Track the four steps in [the implementation plan](plan.v0.27.0.architecture-minor-fallback.md).
All four steps are implemented and verified, including controlled and final-tree
RHEL Python/Git dependency acceptance, curated cleanup and operator documentation.

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

Yes. Step 4 has been fully implemented.

The complete entry-point fixtures, real controlled and final-tree RHEL installs,
equivalence proofs, limited curated removals and nine wiki updates satisfy
AC1-AC12. Both cumulative platform gates and the actual CMD launcher passed.
Two installation failures exposed during acceptance were repaired and verified
before cleanup: Autoconf directory copying and Git's missing libelf dependency.

Round 1 independently confirmed implementation and all mandatory gates. Commit
readiness awaits review of the reconciled documentation. Plan implementation
amendment Q09 now records both acceptance-blocking repairs, updates the installer
inventory and rollout, and aligns requirement item 9/Q10 with the libelf addition.
This writer amendment records the work required by existing AC7; it does not
represent a new human approval of Q09.

### Goal for Step 4

Prove actual Python/Git dependency synchronization on RHEL 9.8 before and after limited curated cleanup.

### Step 4 improvement expectations

- Correct the retained Python list and both Git list typos, with paired 9.8 Git corrections and equivalence proof before removals.
- Complete controlled and final-tree RHEL setup without an exact local mirror override.
- Under approved Q07 B, generate a fresh detected-key index in the controlled checkout and complete Python/Git setup in a separate remote target. Prove served-file mirror fallback, cache/staged reuse and unchanged live-target state.
- Pass AC1-AC12 fixtures and Windows launcher checks, with sanitized evidence and accurate documentation.

### What was implemented for Step 4

- The retained Python list uses `zlib-devel`. Both Git lists received the
  paired `libcom_err` and `libxslt` corrections. Corrected list digests and
  equal tracked mirror values were recorded before any removal.
- Real Git installation exposed a literal wildcard in
  `post_install_autoconf271`. The existing hook now quotes the root while
  expanding directory contents. A focused regression failed with fatal 152
  before this one-line repair; the repaired fixture and actual direct-package
  recovery passed. This additional production edit was necessary for the
  required isolated install and changes no bootstrap or installer interface.
- Git's subsequent `glib2-devel` check exposed the missing `libelf.so.1`
  provider. Both Git lists gained ordinary `elfutils-libelf` before
  `glib2-devel`; the fresh index resolved it uniquely. The amended lists were
  byte-identical, and full preflight and real Git installation then passed.
  Runtime checks remain intact; no manually injected RPM or flag change was used.
- After controlled acceptance, only the redundant Python/Git 9.8 lists and
  equal tracked 9.8 mirror property were removed. The template comment now
  describes fallback and distinct exact overrides. Both generated indexes and
  operator configuration remain untouched.
- The cumulative runner adds actual setup-process fixtures for full Python/Git
  fallback, scoped resume, distinct exact overrides, terminal lookup/download
  failures and the real Autoconf hook. Only transport is stubbed for the entry
  fixtures. Git Bash fixture roots are normalized to long drive paths so child
  shells enforce the same containment boundary.
- Nine wiki pages document independent selection, detected index/cache identity,
  active-property precedence, refresh/publication, scoped progress and
  reset-after-entry. The OS-upgrade procedure also requires repeating connection
  validation when its earlier completion marker would skip detection.
- Round 1 reviewer repairs correct the package launcher's stale fatal 42 to
  `setup_packages.sh` fatal 12 for an unset tool, attribute fatal 111 by script,
  and document the CMD exit 119 boundary and closed argument forms in
  `wiki/reference/exit-codes.md` and `wiki/reference/commands.md`. The writer
  checked these repairs against the launcher and Bash entry points and retained
  both staged pages without reversal.
- [Acceptance evidence](acceptance.architecture-minor-fallback.md) records the
  audited bootstrap, configuration origins/digests, fresh 5898-package detected
  index, all 106 active entries and 81 distinct RPMs, failures and repairs,
  controlled/final results, preservation comparisons and AC1-AC12 mapping.
  Raw host identities and bulky logs remain in ignored evidence paths.

Executed evidence on 2026-09-15, reused by this implementation check:

| Required check | Result |
| --- | --- |
| Controlled Python legacy setup | 56 entries, real installation, exit 0 in 552 seconds |
| Controlled Python scoped resume | 3 entries, all 56 installed packages reused, exit 0 in 40 seconds |
| Controlled amended Git legacy setup | 50 entries, real installation, exit 0 in 233 seconds |
| Controlled Git scoped resume | 3 entries, all 50 installed packages reused, exit 0 in 31 seconds |
| Final curated Python legacy setup | 56 entries, 1 download / 55 cached, all staged/installed state reused, exit 0 in 260 seconds |
| Final curated Git legacy setup | 50 entries, 1 download / 49 cached, all staged/installed state reused, exit 0 in 230 seconds |
| Final Windows cumulative Step 4 | 30 groups, exit 0 in 1455 seconds |
| Final native Linux cumulative Step 4 | 29 applicable groups, exit 0 in 40 seconds |
| Actual Windows CMD launcher | All 11 cases passed, exit 0 |

Every host pass preserved authoring status/content/cache and the live remote
inventory. Final passes used the same controlled index and isolated target,
with reseeded labeled legacy markers and newly HEAD-verified cache omissions.
Both cumulative gates passed the 57-script lint floor, explicit effort syntax
and ShellCheck checks, and live-tree preservation. Windows also passed the held
destination check. Commands and individual raw evidence paths are in acceptance.
The planned `rg` inspection, Markdown headings/fences/local links and
`git diff --check` passed. No tests were rerun during this separate check.

The round 1 reviewer independently passed the lint floor, all 30 Windows groups
in 1428 seconds, all 11 CMD cases in 44 seconds, and all 29 native groups in
41 seconds (59 seconds including transport). The reviewed source and fixtures
remain unchanged during this documentation reconciliation; those results remain
applicable. The native driver refreshed its ignored driver and gate logs with
the reviewer's later run. The 40-second native result above is the earlier
writer run. No additional source, fixture or host-install rerun is required for
these documentation changes.

Physical-line recounts, including blank lines:

| File | Before | After |
| --- | --- | --- |
| `verify.architecture-fallback.sh` | 168 | 401 |
| `src/setups/env/bin/packages_management.sh` | 2068 | 2069 |
| `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt` | 59 | 59 |
| `src/setups/pkgs/python/python_rhel_9.8_x86_64.txt` | 59 | 0 |
| `src/setups/pkgs/git/git_rhel_9.6_x86_64.txt` | 49 | 50 |
| `src/setups/pkgs/git/git_rhel_9.8_x86_64.txt` | 49 | 0 |
| `src/setups/setup.tpl.properties` | 26 | 24 |
| `wiki/explanation/the-architecture-key.md` | 93 | 90 |
| `wiki/explanation/checkpoints-and-resume.md` | 56 | 76 |
| `wiki/how-to/survive-a-server-os-upgrade.md` | 85 | 77 |
| `wiki/how-to/resume-or-repeat-a-step.md` | 65 | 82 |
| `wiki/how-to/add-or-fix-a-package-mirror.md` | 59 | 77 |
| `wiki/reference/package-list-formats.md` | 101 | 136 |
| `wiki/reference/cplx-variables.md` | 53 | 60 |
| `wiki/reference/commands.md` | 63 | 75 |
| `wiki/reference/exit-codes.md` | 101 | 119 |
| `acceptance.architecture-minor-fallback.md` | 0 | 304 |
| `plan.v0.27.0.architecture-minor-fallback.md` | 589 | 595 |
| `feature-request.v0.27.0.architecture-minor-fallback.md` | 275 | 278 |

The runner and acceptance record exceed advisory estimates because Step 4 adds
five process/hook cases and audited real-host evidence. Raw logs stay outside
versioned prose. The Python 650-line ceiling is inapplicable.

### New types or classes introduced for Step 4

No production type, class or function was introduced. Test-only
`architecture_entry_stage`, `architecture_entry_run` and `architecture_refute`
support the five registered `architecture_entry_*` cases and their suite.
The existing installer hook retains its signature and caller contract.

### Architecture check for Step 4

Selection policy and metadata/index/progress adapters retain their existing
boundaries. Curated dependency names stay in data files. The Autoconf copy fix
belongs to the existing remote post-install adapter and adds no dependency back
into metadata selection. Local entry fixtures replace transport at its existing
boundary; host acceptance uses the actual downloader, SSH/SCP and installer.
No domain rule moved into a transport stub or bootstrap interface. The existing
large installer gains one explanatory line without a new responsibility.

Yes, there is follow-up work outside Step 4: round 1 reproduced a pre-existing
single-file defect in `post_install_autoconf271`. When the path-rewrite pipeline
passes only one `auto*` file to `grep`, its output omits the filename;
`awk -F :` then treats matching content as a path, and the hook fails with
fatal 153. A future repair must preserve filename identity regardless of input
count and test both one-file and multiple-file rewrites, including reuse.
The real accepted package has several files, so this does not invalidate the
recorded installs. The Step 4 hook change remains limited to wildcard copying;
no path-rewrite repair is included here.

Step 4's adapter boundaries are sound. Plan implementation amendment Q09
documents the two acceptance-blocking repairs within their existing adapter
and curated-data responsibilities.

Yes, there is something that needs to be addressed: the single-file
`post_install_autoconf271` path-rewrite follow-up above, outside Step 4.

### Performance check for Step 4

No new production quadratic or sorting computation was added. Selection and
progress preparation keep their established linear bounds; index aggregation
and RPM lookup costs are unchanged. Git processes one additional required
dependency through the ordinary loop. The copy repair uses the existing copy
operation. Fixture sorting prepares deterministic synthetic listings only.
Preservation checks batch metadata hashes and inventory RPM sizes/timestamps
without hashing the cache contents. Fixture and real-network durations are
reported separately above; this step defines no elapsed-time gate.

No, there is no performance issue that needs to be addressed for Step 4.

### Unit test coverage check for Step 4

This Bash project has no class-based unit-test or percentage coverage gate.
The mandatory lint source scope is tracked shell scripts outside `docs/`;
the cumulative runner explicitly checks the effort scripts outside that scope.
The five new cases are integration/regression fixtures, so their successful
execution is behavioral evidence, not a 100% line-coverage claim.

Static inspection finds every added top-level fixture helper referenced by a
case or the suite, and all five cases registered in Step 4 dispatch. The repaired
production hook is reached by ordinary post-install dispatch and the focused
test, which checks copying with spaces, support files, rewritten paths and reuse.
Earlier suites retain ordering permutations, the 48-cell index guard matrix,
failure injection, interruption recovery and literal progress/argument handling.

No, there is no unit-tested class below 100% that needs completing for Step 4.
No, there is no unreferenced new top-level symbol outside a coverage gate.

### Feature integrity for Step 4

Real setup reports list/mirror fallback and legacy restart, synchronizes every
active entry, copies the selected list, and completes installation. Valid scoped
resume and local cache, remote staging and installed-state reuse are retained.
Missing/ambiguous packages and exhausted downloads remain failures; distinct
exact overrides remain authoritative. The runtime closure checks that exposed
the missing dependency remain unchanged. Generated indexes and operator data
are preserved, and the live target was unchanged across every acceptance pass.

No existing supported feature or reporting capability is impaired by Step 4.
This completes upstream dependency acceptance; Python SQLite integration and
the tools rebuild/cross-platform release remain separate umbrella items.
