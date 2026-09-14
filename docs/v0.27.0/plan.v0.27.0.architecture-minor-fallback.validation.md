# v0.27.0 architecture minor fallback implementation tracking and validation

No, it is not implemented

Track the four steps in [the implementation plan](plan.v0.27.0.architecture-minor-fallback.md).
This initial skeleton records no implementation or executed acceptance result.

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

Not started. Step 1 is not implemented because the selector, adapters and Bash verification seam have not been implemented.

### Goal for Step 1

Provide exact-first, integer-minor selection through one pure selector and per-kind adapters.

### Step 1 improvement expectations

- Preserve authoritative exact inputs and whole machine identities.
- Prove ordering and exclusion with generated fixture permutations.
- Make selected source diagnostics actionable without selection-side writes.

### What was implemented for Step 1

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 1

_(empty — no check has taken place yet.)_.

### Architecture check for Step 1

_(empty — no check has taken place yet.)_.

### Performance check for Step 1

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 1

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 1

_(empty — no check has taken place yet.)_.

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
