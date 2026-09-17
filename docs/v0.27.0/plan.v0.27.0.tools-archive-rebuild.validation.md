# Implementation validation v0.27.0: tools archive release

No, it is not implemented.

Track the seven steps in [the implementation plan](plan.v0.27.0.tools-archive-rebuild.md).
Steps 1-2 are checked below. Steps 3-7 and final-archive acceptance remain pending.

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

Yes. Step 2 has been fully implemented.

The archive-indexed sidecar, independent Python validator and application entry
separate publication eligibility from completion and bind the eligible SHA-256
to the closure gate's promoted bytes before any uploader load or call. Native
Python 3.9 fixtures, separate unit coverage and the application authoring walk
passed. The real candidate remains pending, as required by this step.

### Goal for Step 2

Check publication and completion obligations separately and bind eligible evidence to the bytes the closure gate streams.

### Step 2 improvement expectations

Missing or stale evidence and an omitted expected digest block before any
adapter call; adoption obligations do not create a circular publication
prerequisite. Validator and unit checks support Python 3.9 or later and run on
an independently supplied interpreter, never the candidate being qualified.

### What was implemented for Step 2

- `tools_release_record.py` provides explicit publication, completion and render
  commands with record, archive, evidence-root and release-revision inputs.
  It rejects duplicate JSON keys, missing required cells, unknown IDs/states,
  stale or contradictory identities, unsupported interpreter declarations,
  damaged or unavailable captures and incomplete D10 convergence. Required
  Debian and RHEL roles, optional RHEL cells and future adoption obligations
  remain distinct.
- Captures have retained identities, paths and hashes; each passing result
  keeps its producing run and original input identities. Exact reasoned
  assessments can preserve unaffected results, while wheel/lock changes force
  fresh D10, ABI and relevant application acceptance. The CLI records actual
  interpreter path/version, timing, read counts and both archive hashes locally,
  and refuses to overwrite its inputs or retained captures.
- `closure_publish.sh` checks the optional expected SHA-256 against the promoted
  identity before adapter loading. The application tools entry makes that guard
  mandatory, validates the selected release coordinate, and exits through the
  transaction before Maven lookup, search or POM preflight. Obsolete tools paths
  were removed; ordinary application publication retains its behavior.
- The versioned JSON and generated Markdown view index Step 1 preparation
  captures and retain an unqualified pending template outside `candidates`.
  Lifecycle checks preserve SHA-1/SHA-256 association, block unresolved retries,
  and require later publication/adoption evidence for completion.
- The cumulative Linux runner passed in 44 seconds: shell lint/compilation,
  16 unit tests (3.602s), 15 existing process tests (13.197s), six new entry
  tests (1.200s), 25 current SQLite checks and 254 inherited publication cases.
  The inherited suite uses the same verified historical pair as Step 1.
- The application forced Groundhog walk finished with `state=done`, exit 0,
  at 2026-09-17T10:33:54+02:00. Check took 2m 30.4s, affected selection 9.8s,
  full suite 4m 21.5s; 6040 collected, fail=0, warn=3, xfail=8, cov=100,
  outliers=0 and excluded=0.

See [the acceptance view](acceptance.tools-archive-rebuild.md),
[the sidecar](acceptance.tools-archive-rebuild.json) and
[the Step 2 capture](evidence.tools-archive-rebuild.step2-validation.txt) for
commands, observations, exact source hashes and limits. These results establish
the release controls, not actual final-archive qualification or publication.

### New types/classes introduced for Step 2

The production CLI uses stdlib mappings and pure validation functions, with no
new framework or domain class. `ReleaseRecordTests` creates isolated synthetic
records and finite generated mutations. `ReleasePublicationTests` exercises
the real Bash entry, promotion and stream with a spy adapter. Both test packages
include their required markers; the CLI is loaded by path.

### Architecture check for Step 2

cplx owns evidence composition and the inherited publication port. The
application entry supplies explicit identities and its existing backend adapter;
the validator neither executes the candidate nor imports application domain or
HTTP code. Pure validation, rendering and the filesystem CLI boundary have
separate functions. No closure result grammar or authority mechanism changed.

Physical lines are 369 for the validator, 332 for unit tests and 148 for process
tests, each below 650. Shell sizes are 670 for the closure gate, 336 for the
application publisher and 46/20 for the cumulative/focused runners; the Python
ceiling does not apply to Bash. No architecture smell, violation or size issue
needs addressing.

### Performance check for Step 2

The validator reads one explicit JSON record and hashes each resolved indexed
capture once using a dictionary. It hashes the archive once, computing SHA-1
and SHA-256 together with bounded 1 MiB buffers. Required-cell lookups use a
fixed matrix, and input comparisons and rendering are linear in their data.
There is no directory/history discovery, sorting or all-pairs traversal.
The inherited gate still performs its required independent promoted/snapshot
and stream identity checks; those reads are not removed as an IO shortcut.

The CLI captures phase duration and read counts; fixtures assert one record
read and one unique capture read. Native cumulative time was 44 seconds, with
unit and process timings above. No new latency threshold or timeout xfail was
introduced. No performance issue needs addressing.

### Unit test coverage check for Step 2

The single-file validator unit suite follows the requested class-file directory
convention and reaches every top-level production function: tests call
validation, loading, rendering and the CLI; these call metadata, D10, lifecycle,
capture, input, hashing and primitive checks. The CLI main guard is exercised
through `runpy`. The prior independent Windows Python 3.13.9 measurement reports
276 statements, zero missing, 100% coverage. Its 16 tests also passed on the
native independent system Python 3.9.25 floor.

Finite generated mutations cover every mandatory matrix cell and nonpassing
state, metadata removal, stale identities, reasoned retention, capture damage,
sanitization and lifecycle separation. No new property-testing dependency is
needed. The six Bash process tests are integration tests, with no class-level
coverage target; their spy records adapter loading as well as callbacks.

The application Groundhog coverage scope is `src/pdfss`; its 100% result does
not measure this external CLI or the shell entry. The separate measurement and
static references above establish their exercise. No existing unit-tested
Python class changed. No unit-tested class below 100% needs completing. No
top-level production symbol outside the application coverage gate is unreferenced.

### Feature integrity for Step 2

Archive replacement after validation, mismatched eligibility, empty validator
output and an omitted tools guard all refuse before even sourcing the spy
adapter. Eligible bytes stream unchanged; non-tools gate callers remain
compatible without the optional guard. Existing process tests cover ordinary
fresh, identical, different-byte and snapshot application publication. Full
inherited controls preserve descriptor, snapshot, stream, authority and waiver
checks; the current SQLite declaration remains intact.

Publication eligibility permits future adoption cells to remain pending;
completion requires their passes, published digests and pin/configuration
revisions. Unresolved publication and actual recovery cannot complete the item.
The sidecar records no real candidate pass. Steps 3-7 and the umbrella item remain
pending. No existing feature or reporting capability is impaired.

## Step 3. Include the agent's exact wheel artifacts in D10

### Analysis of Step 3 implementation state

Yes. Step 3 has been fully implemented.

Exact retained wheels, lock identity and installed ELF identities now feed the
existing D10 reader and policy. Native RHEL fixtures prove that additional wheel
demands change the selection, while incomplete inputs remain inconclusive.
The cumulative Step 3 command passed with independent Python 3.9.25.

### Goal for Step 3

Measure exact Debian-resolved wheel artifacts on RHEL alongside archive consumers.

### Step 3 improvement expectations

Identity mismatches are inconclusive; lowest satisfying generation, zero headroom and bounded convergence are preserved.

### What was implemented for Step 3

- `tools_wheel_inventory.sh` requires an explicit independent interpreter.
  Its stdlib Python helper captures the lock, retained wheel hashes and exact
  installed ELF set, then verifies those same bytes before materialization into
  an exclusively created private directory. ZIP traversal, links, duplicate
  entries, file/directory collisions and inventory mismatches refuse; failure
  removes only the destination owned by that invocation.
- `closure_d10.sh` accepts repeatable wheel roots with explicit lock and
  interpreter inputs. It snapshots archive provider identities first, validates
  each measured wheel subject against the captured inventory, then combines
  GLIBCXX/CXXABI and separate GCC requirements. Every consumer carries origin,
  path and digest; candidate identities and defined nodes are reported.
- The original selector and bounded convergence functions are unchanged.
  Archive-only calls retain their original subject rule and report fields;
  the extended union also includes independent libgcc consumers.
- `verify.tools-release-d10.sh` exercises 49 native cases, including all planned
  refusal and convergence outcomes, installed-set equality, safe cleanup,
  data relocation and deterministic wheel-order permutations. The cumulative
  runner composes these with the existing publication and SQLite controls.
- [Retained validation evidence](evidence.tools-archive-rebuild.step3-validation.txt)
  records exact source identities, invocation counts, line budgets and results.
  The final cumulative run exited 0 in 49 seconds: 49 D10 cases, 16 record
  tests, 15 transport tests, 6 publication tests and 254 historical closure
  Step 5 cases passed, alongside the SQLite controls and shell gates.

### New types/classes introduced for Step 3

No classes or runtime dependencies were introduced. The helper is a standalone
Python 3.9+ CLI with a versioned JSON identity record, not an ABI-demand format.

### Architecture check for Step 3

Filesystem, ZIP and JSON handling stay in the inventory adapter. The shared
ELF reader remains the only interpreter of ABI requirements and capabilities;
D10 remains the policy owner. Wheel and candidate reads cannot overwrite the
archive snapshot. No application domain code or production archive topology
changed. DDD/hexagonal boundaries have no new smell or violation.

Physical lines before/after: D10 524/630; helper Bash 0/11; helper Python 0/258;
fixture Bash 0/218; cumulative runner 46/54. The only new Python file is below
the 650-line ceiling. No architecture or file-size issue needs addressing.

### Performance check for Step 3

Each explicit root is walked once; each new reader slice is visited once.
Hash maps deduplicate required nodes and compare subject identities. Wheel
bytes are streamed with a fixed number of integrity passes; candidate checks
are linear in the required nodes for the two fixed generations. There is no
new all-pairs comparison or sort. ZIP ancestor checks are bounded by path depth.

The instrumented union measured two find walks and eight unique readelf calls:
three archive objects, one wheel object and four candidate providers. D10
reported 0 seconds at whole-second resolution; no deadline is inferred.
No performance issue needs addressing.

### Unit test coverage check for Step 3

No Python class or existing unit-tested class changed. New tests are native
integration fixtures and carry no unit coverage target. Deterministic ZIP
mutations and wheel-order permutations provide generated-case checks without
a PBT dependency. Every top-level Python helper is referenced by another
helper or the CLI dispatch; every new Bash function is called by the entry
path or fixture driver, including the exported instrumentation functions.

The cplx gate measures shell lint, not Python coverage; the app's coverage
scope is src/pdfss and excludes these tooling files. No percentage is claimed.
The required fresh ghog day completed with exit 5 after successful lint because
cplx has no configured pytest environment. The plan explicitly substitutes
the native cumulative runner, which passed; no pytest gate was added.
No unit-tested class below 100% needs completing. No top-level symbol outside
the coverage gate is unreferenced.

### Feature integrity for Step 3

Legacy archive-only selection, zero headroom, unread/empty observations and
equal/lower/higher/neither second readings are covered. Existing publication,
record and SQLite regression controls passed. An additional frozen closure
Step 7 attempt passed its D10 policy/evidence assertions but was inconclusive
in its separate live archive extraction after exhausting scratch space; it is
not part of the Step 3 cumulative gate or evidence of candidate acceptance.
The frozen harness and production declarations remain unchanged.

Real Debian wheel capture/wiring belongs to Step 4, and final candidate D10
and runtime proof to Step 6. No candidate pass was added to the release record;
Steps 4-7 and the umbrella remain pending. No existing feature or reporting
capability is impaired.

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
