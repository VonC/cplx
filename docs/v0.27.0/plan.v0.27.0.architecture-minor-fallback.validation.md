# v0.27.0 architecture minor fallback implementation tracking and validation

No, it is not implemented.

Track the four steps in [the implementation plan](plan.v0.27.0.architecture-minor-fallback.md).
Step 1 is implemented and verified. Steps 2-4 and real-host acceptance remain pending.

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

Not started. Step 2 is not implemented because the invocation context, availability guard and safe publication have not been implemented.

### Goal for Step 2

Propagate selected inputs through synchronization, generation, downloading and remote list copying.

### Step 2 improvement expectations

- Keep generated indexes keyed to the detected architecture.
- Generate on missing/empty exact index or either refresh flag despite completion.
- Preserve old index bytes on failure while failing the current invocation.

### What was implemented for Step 2

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 2

_(empty — no check has taken place yet.)_.

### Architecture check for Step 2

_(empty — no check has taken place yet.)_.

### Performance check for Step 2

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 2

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 2

_(empty — no check has taken place yet.)_.

## Step 3: Persist scoped progress and repair CMD reset forwarding

### Analysis of Step 3 implementation state

Not started. Step 3 is not implemented because the scoped record and launcher reset interface have not been implemented.

### Goal for Step 3

Bind durable resume state to detected key and selected list, and forward reset intent once.

### Step 3 improvement expectations

- Restart safely for changed, legacy, malformed or stale progress.
- Preserve approved resume-after and repeat behavior.
- Validate resets and preserve direct-package progress isolation across real CMD and Git Bash.

### What was implemented for Step 3

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 3

_(empty — no check has taken place yet.)_.

### Architecture check for Step 3

_(empty — no check has taken place yet.)_.

### Performance check for Step 3

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 3

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 3

_(empty — no check has taken place yet.)_.

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
