# Implementation validation v0.27.0: tools archive release

No, it is not implemented.

Track the seven steps in [the implementation plan](plan.v0.27.0.tools-archive-rebuild.md).
Step 1 is checked below. Steps 2-7 and final-archive acceptance remain pending.

## File-based IO cost clarification

Read the selected archive-indexed release record directly; do not scan document
history or raw-capture directories to discover state. Resolve explicit evidence
references once per validation phase and reuse the collected identity map.
Retain required artifact hashing, ELF inventories and gate snapshots; reducing
IO must not remove byte-identity or completeness checks. Walk each declared
subject root once per measurement phase, keep provider and consumer inventories
separate, and stream publication bytes through the existing gate.

## Complexity and timing review scope

Review linear work in explicit evidence and artifact bytes, allowing existing
deterministic inventory sorting. Check that no repeated all-pairs scans were
introduced. Record phase durations and invocation counts; no new latency SLO
or Step 0 timeout/xfail gate is specified. Existing CI timeouts remain enforced.

## Step 1. Demonstrate the real publication transaction

### Analysis of Step 1 implementation state

Yes. Step 1 has been fully implemented.

The application adapter implements private stdin streaming, abort and immutable
commit, with the user-authorized mandatory exact-asset SHA-256 check when the
commit response is missing or unusable. Live backend probes and native Linux
process fixtures establish the scoped capability. The acceptance record retains
the observations, cleanup, exact starting revisions and final source hashes.

### Goal for Step 1

Implement and prove the inherited private-stage, stdin-stream, abort and atomic-commit contract before refresh/build work.

### Step 1 improvement expectations

Pre-commit refusal leaves no public candidate. After commit intent, a missing
reply requires read-back: matching bytes confirm success; inconclusive checks
retain uncertainty and block automatic retry/adoption. Ordinary application
publication remains intact. This reflects the 2026-09-17 owning-design
resolution rather than the disproved blanket absence guarantee.

### What was implemented for Step 1

- `app:tools/tools_release_adapter.sh` implements all four callbacks and a
  read-only reconciliation command. Separate HTTP and durable-state helpers
  stream through an unfinished chunked TLS request and journal intent/digest
  before its terminating chunk. No local archive buffering or production
  DELETE is used.
- `closure_publish.sh` retains descriptor-bound hashing and callback order,
  while reporting an uncertain commit without claiming absence. The old
  application `--with-tools` path refuses before remote work until Step 2.
- The owning design/plan and this effort's design/plan record mandatory
  read-back. Private backend identifiers and credentials remain out of notes.
- Live probes demonstrated private write, abort/absence, commit visibility,
  byte identity, immutable collision refusal and lost-response reconciliation.
  All owned probe assets were removed and absence checked. The implemented
  HTTP helper also exercised the real service; the full worker/gate ran against
  isolated TLS on native Linux. These complementary proofs do not claim a live
  whole-worker run, concurrent-client isolation or large-archive validation.
- The cumulative runner passed in 33 seconds: shell floor, 15 integration tests
  (11.244s), 25 current SQLite checks and 254 inherited publication controls.
  The frozen inherited suite uses its hash-verified historical input pair,
  following the previous effort's documented method. Production declarations
  and the frozen harness remain unchanged.
- The application `ghog day` ended 2026-09-17T08:42:25+02:00 with exit 0,
  fail=0, warn=3, xfail=8, cov=100, outliers=0 and excluded=0. A small typing
  and platform cleanup in its existing SQLite mapping diagnostic was necessary
  for this authoring gate; a native Python 3.9 smoke also passed.

See [acceptance](acceptance.tools-archive-rebuild.md) and the
[validation capture](evidence.tools-archive-rebuild.validation.txt) for hashes,
commands, observations and limits. No release build or publication is claimed.

### New types/classes introduced for Step 1

- `Target`: immutable endpoint/configuration value with authenticated verified
  TLS operations and exact downloaded-byte comparison.
- `Receipt`: typed durable attempt metadata, excluding backend credentials and
  archive bytes; records phase, digest and authenticated loopback IPC identity.
- `Repository` and `TransportTests`: isolated TLS failure server and process
  integration fixtures. Test package markers follow the shared test layout.

### Architecture check for Step 1

Repository-specific HTTP and credentials stay in the application adapter; cplx
continues to own the publication gate and its four-operation port. Durable state
and transport are separate modules. No application domain layer imports these
tools or their technical dependencies. Direct CLI imports preserve Python 3.9
compatibility without importing unrelated application authoring helpers.

Physical lines: HTTP helper 168, transport helper 354, diagnostic 68 and new
integration test 404. All are below the 650-line Python ceiling. There is no
DDD-Hexagonal violation, architecture smell or size issue needing correction.

### Performance check for Step 1

Upload forwarding and SHA-256 verification are O(n) in artifact bytes with
bounded 1 MiB buffers. One receipt is addressed directly by coordinate hash;
there is no archive/history scan, new sort or all-pairs traversal. Maven settings
are parsed linearly. A response failure adds one exact GET per reconciliation.
The worker uses bounded network timeouts and bounded idle/lock waits.

Recorded timings: cumulative 33s, focused 11.244s, current SQLite fixtures 1s;
application check 84.4s, affected 3m 51.6s, full 4m 17.7s. Probe observations
retain individual timings; no new latency SLO or build benchmark is asserted.
No performance issue needs addressing.

### Unit test coverage check for Step 1

The new unittest file follows the requested directory convention but performs
process integration across Bash, the worker, TLS and the gate. It is not a
class-level unit suite and has no unit coverage target. Its finite failure
matrix needs no additional PBT dependency. No existing unit-tested class was
changed.

The application coverage source is `src/pdfss`, with its configured exclusions;
the 100% application result does not measure `tools/`. Static reference review
finds all added top-level production symbols reached: `main` dispatches
begin/worker/callback; worker/serve/operate reach stream/commit and receipt/lock
helpers; recovery reaches Target through target_of; Target.configured reaches
service_root/coordinate_path; the worker imports write_chunk/finish. Receipt
is used by annotations. The SQLite diagnostic calls identity from main. Test
classes are reached by unittest and the HTTP server fixture.

No unit-tested class below 100% needs completing. No top-level symbol outside
the coverage gate is unreferenced.

### Feature integrity for Step 1

Ordinary fresh, identical, different-byte and snapshot application publication
remains covered. Tools publication deliberately refuses through the old entry
until Step 2 supplies eligibility evidence. The exact-byte gate and current
SQLite declaration remain intact; historical controls do not qualify a candidate.
Unknown outcomes preserve diagnostics and block automatic repeat publication;
recovery does not delete an already public release. Later build, qualification,
publication and adoption work remains assigned to Steps 2-7.

## Step 2. Validate and bind the durable release record

### Analysis of Step 2 implementation state

Not started. Step 2 is not implemented because the record validator, tests and publication digest guard are not implemented.

### Goal for Step 2

Check publication and completion obligations separately and bind eligible evidence to the bytes the closure gate streams.

### Step 2 improvement expectations

Missing or stale evidence and an omitted expected digest block before any
adapter call; adoption obligations do not create a circular publication
prerequisite. Validator and unit checks support Python 3.9 or later and run on
an independently supplied interpreter, never the candidate being qualified.

### What was implemented for Step 2

_(empty — no check has taken place yet.)_.

### New types/classes introduced for Step 2

_(empty — no check has taken place yet.)_.

### Architecture check for Step 2

_(empty — no check has taken place yet.)_.

### Performance check for Step 2

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 2

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 2

_(empty — no check has taken place yet.)_.

## Step 3. Include the agent's exact wheel artifacts in D10

### Analysis of Step 3 implementation state

Not started. Step 3 is not implemented because wheel inventory transport and additional D10 consumer roots are not implemented.

### Goal for Step 3

Measure exact Debian-resolved wheel artifacts on RHEL alongside archive consumers.

### Step 3 improvement expectations

Identity mismatches are inconclusive; lowest satisfying generation, zero headroom and bounded convergence are preserved.

### What was implemented for Step 3

_(empty — no check has taken place yet.)_.

### New types/classes introduced for Step 3

_(empty — no check has taken place yet.)_.

### Architecture check for Step 3

_(empty — no check has taken place yet.)_.

### Performance check for Step 3

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 3

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 3

_(empty — no check has taken place yet.)_.

## Step 4. Wire candidate qualification into the main application chain

### Analysis of Step 4 implementation state

Not started. Step 4 is not implemented because candidate main-chain provisioning and restored test/ABI gates are not implemented.

### Goal for Step 4

Qualify the candidate through actual application provisioning, sync, package, full tests and blocking ABI probes.

### Step 4 improvement expectations

Coverage and testmon are active at the existing threshold; SQLite suites execute; interims are removed and uploads stay off.

### What was implemented for Step 4

_(empty — no check has taken place yet.)_.

### New types/classes introduced for Step 4

_(empty — no check has taken place yet.)_.

### Architecture check for Step 4

_(empty — no check has taken place yet.)_.

### Performance check for Step 4

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 4

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 4

_(empty — no check has taken place yet.)_.

## Step 5. Refresh, rebuild and package the candidate

### Analysis of Step 5 implementation state

Not started. Step 5 is not implemented because no item 7 final candidate, cleanup result or release-time Python decision has been established.

### Goal for Step 5

Build the explicitly selected Python with SQLite, clean the private archive stage and preserve declaration authority.

### Step 5 improvement expectations

The exact timestamped archive has conclusive build evidence; every inherited ownership entry is discharged correctly.

### What was implemented for Step 5

_(empty — no check has taken place yet.)_.

### New types/classes introduced for Step 5

_(empty — no check has taken place yet.)_.

### Architecture check for Step 5

_(empty — no check has taken place yet.)_.

### Performance check for Step 5

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 5

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 5

_(empty — no check has taken place yet.)_.

## Step 6. Complete pre-publication platform acceptance

### Analysis of Step 6 implementation state

Not started. Step 6 is not implemented because the final archive has not completed the required RHEL and actual Debian acceptance matrix.

### Goal for Step 6

Collect conclusive candidate-bound AR/PA and pre-publication RA evidence, including exact wheels and D10.

### Step 6 improvement expectations

Changed inputs invalidate affected results; optional cells remain distinguishable; one permitted D10 rebuild cannot become an unbounded loop.

### What was implemented for Step 6

_(empty — no check has taken place yet.)_.

### New types/classes introduced for Step 6

_(empty — no check has taken place yet.)_.

### Architecture check for Step 6

_(empty — no check has taken place yet.)_.

### Performance check for Step 6

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 6

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 6

_(empty — no check has taken place yet.)_.

## Step 7. Publish, adopt and close with integration evidence

### Analysis of Step 7 implementation state

Not started. Step 7 is not implemented because the eligible archive has not been published and accepted through the normal release pin.

### Goal for Step 7

Publish immutable accepted bytes, then verify normal-pin retrieval and complete adoption before restoring uploads.

### Step 7 improvement expectations

Real integration evidence completes the record; verified recovery preserves service but leaves item 7 incomplete.

### What was implemented for Step 7

_(empty — no check has taken place yet.)_.

### New types/classes introduced for Step 7

_(empty — no check has taken place yet.)_.

### Architecture check for Step 7

_(empty — no check has taken place yet.)_.

### Performance check for Step 7

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 7

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 7

_(empty — no check has taken place yet.)_.
