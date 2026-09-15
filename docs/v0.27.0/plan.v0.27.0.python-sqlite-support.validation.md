# v0.27.0 Python SQLite support implementation tracking and validation

No, it is not implemented

Track the four steps in the [implementation plan](plan.v0.27.0.python-sqlite-support.md).
This initial skeleton records no implementation checks or acceptance results.

## File-based IO cost clarification for SQLite validation

Check one bounded temporary database operation and one maps read per probe,
linear parsing with identity deduplication, independently supplied paths and
one structured result. Preserve existing build reuse and closure inventories.
Archive digest checks belong at transfer boundaries; fixture tests must not
walk or hash live RPM caches. Record actual timings without invented limits.

## Step 1: Implement the shared probe and establish acceptance prerequisites

### Analysis of Step 1 implementation state

Not started. Step 1 is not implemented because the probe, focused tests and
acceptance prerequisite assessment have not been implemented or checked.

### Goal for Step 1

Provide one standard-library database/provider probe and establish the exact
isolation, source anchoring and Debian runtime/copy prerequisites for acceptance.

### Step 1 improvement expectations

- Detect wrong, absent, escaped, deleted or ambiguous provider identities.
- Share database and identity rules across the three explicit stages.
- Confirm the separate anchor-compatible home first and establish the Debian route, or retain blockers.
- Verify the source module link and mapped build `libpython` identities.

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

## Step 2: Enforce SQLite capability before Python packaging

### Analysis of Step 2 implementation state

Not started. Step 2 is not implemented because scoped configure inputs,
source/installed checks and the optional driver callback have not been added.

### Goal for Step 2

Require SQLite capability for the declared RHEL 9 x86_64 family after build or
reuse and after install or reuse, before packaging and selector advancement.

### Step 2 improvement expectations

- Reject stale source and installed output with actionable stage diagnostics.
- Validate `pybuilddir.txt`, module backing files and source library precedence.
- Preserve other target families and tools without a callback.
- Prove explicit reconfigure order and nonzero propagation through the driver.

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

## Step 3: Bind the candidate layout to its closure declaration

### Analysis of Step 3 implementation state

Not started. Step 3 is not implemented because the candidate declaration,
renewed envelope and exact-source/refusal checks have not been delivered.

### Goal for Step 3

Declare only the approved Python version shape, remove the satisfied SQLite
waiver and retain a byte-consistent envelope anchored to real source bytes.

### Step 3 improvement expectations

- Accept the 3.13.15 layout with Python root/current and the SQLite floor.
- Preserve missing/misplaced payload, stale waiver and undeclared-version refusals.
- Resolve the envelope's real source commit without a publication operation.
- Check auxiliary-operation authorization, active hooks, blob digest and ancestry.

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

## Step 4: Prove one candidate on the three required environment roles

### Analysis of Step 4 implementation state

Not started. Step 4 is not implemented because no candidate has been rebuilt,
packaged or accepted under this plan on the three required environment roles.

### Goal for Step 4

Establish populated-tree rebuild, isolated assembly/deployment and same-process
SQLite provider success for one identified archive, with live-tree preservation.

### Step 4 improvement expectations

- Retain separate build-account, Debian 12 and RHEL deployment evidence.
- Tie all results to the same candidate and closure/source identities.
- Record the absent isolated `.profile`, audited inputs and full content manifests.
- Leave missing prerequisites or environment evidence incomplete.
- Give item 7 reproducible commands to repeat on its final refreshed archive.

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
