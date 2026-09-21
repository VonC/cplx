# Implementation validation v0.27.0: tools archive release

Yes, it is implemented.

Track the seven steps in [the implementation plan](plan.v0.27.0.tools-archive-rebuild.md).
All seven steps are checked below. The accepted archive was published as
tools release 10.0.0 and adopted through the normal release pin in Jenkins
build 189. Required Debian, RHEL, D10 and publication obligations are complete;
snapshot uploads resumed only after actual adoption passed. Earlier failed
observations remain retained with their original scope and identities.

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

Yes. Step 4 has been fully implemented.

Review round 2 independently passed every implementation and validation check,
but the sensitive-content pre-commit checker refused one fixture assertion and
four earlier review-transcript entries. The fixture now asserts the prefix,
interpreter version and matching application-directory/name shape without a
private name. The human approved the prepared four-line transcript correction
using the repository's configured replacements. The complete staged set now
passes the sensitive-content check. A fresh cumulative native run passed in
53 seconds; the companion application index remains identical to round 2.
The replacement review will assess these final corrections before the commit
decision.

The main application chain now selects pinned candidate transport, retains
independent controls and exact wheel artifacts, and blocks on ABI or full-test
evidence failures. Native fixtures and the application authoring walk passed.
The plan assigns actual final-archive Jenkins and platform acceptance to Step 6.

### Goal for Step 4

Qualify the candidate through actual application provisioning, sync, package, full tests and blocking ABI probes.

### Step 4 improvement expectations

Coverage and testmon are active at the existing threshold; SQLite suites execute; interims are removed and uploads stay off.

### What was implemented for Step 4

- `app:ci/tools_candidate.sh` shares archive/bundle transport with the SQLite
  diagnostic. It rejects incomplete or conflicting pins and candidate uploads,
  verifies both downloads before extraction, and rechecks control revision and
  bytes before use. The stdlib bundle adapter rejects unsafe members and checks
  exact manifest coverage. The earlier SQLite bundle format remains supported.
- The provisioner keeps release-pin selection and adds candidate-copy mode.
  Ordinary release provisioning explicitly requires `tools/tools.verification`;
  the pipeline and provisioner preflight reject its absence before venv side
  effects and name `app:ci/TOOLS-VERIFICATION.md`. That document explains the
  job owner's independent verifier delivery and bootstrap contract. Relocation
  rechecks the archive digest, and one raw interpreter and derived venv path
  feed sync, test and ABI stages. Packaging uses that same prefix. Actual
  container/image identities are retained without copying Docker credentials.
- Locked installed wheel identities select the original downloadable artifacts;
  the Step 3 inventory proves installed ELF equality. Raw artifacts, lock and
  inventory are retained. Temporary URL-bearing selection data is removed on
  success or failure. No dependency is selected anew or wheel ELF rewritten.
- The rsync shim, tools-patch fetch, patch-wheels implementation and Groovy
  calls were removed. The explicitly permitted raw-Python/UV_PYTHON bypass
  remains. The existing tracked publication mode was already `off`.
- The blocking ABI entry calls independent closure policy, inventories tools
  and venv ELFs, retains loader observations and direct-venv `libs,versions`
  traces, and rejects unresolved versions, other outside providers, escaped
  aliases and inconclusive observations. Inherited OneAgent exclusions,
  virtual-kernel entries and system-interpreter helpers remain visible. A
  fixture exercises the authorized helper interpreter exception and refuses
  the same ELF when moved outside `tools/bin`.
- The test entry uses active coverage and testmon with supported full-selection
  mode and fresh evidence/state. Hooks check actual plugin configuration,
  record collection/execution and platform skips, and identify the interpreter.
  Independent validation requires 100% coverage and full execution of both
  SQLite-guarded suites. Missing selection, execution or coverage refuses.
- [Retained evidence](evidence.tools-archive-rebuild.step4-validation.txt)
  records source hashes, line budgets, commands and limits. Native cumulative
  validation passed in 53 seconds: 33 agent shell cases plus parser/configuration
  fixtures, 49 D10 cases, 16 record tests, 15 transport tests, six publication
  tests, 25 current SQLite controls and 254 historical closure cases. All 20
  native source inputs match the retained tested snapshot. Added cases invoke
  the actual provisioner without a release verifier, prove successful release
  preflight, and keep SQLite diagnostics usable with publication enabled.
  The application authoring result and timings are recorded in that evidence;
  its command sets the app checkout explicitly and forces a fresh full walk.
  It completed with exit 0, 100% coverage and zero failures or duration
  outliers. The full suite took 4m 54.8s; three warnings and eight expected
  failures remain reported.

### New types/classes introduced for Step 4

`GuardCounts` and `WalkRecord` are TypedDict declarations for pytest evidence,
not domain classes. The new `ci` package marker supports explicit plugin loading.
Transport, extraction, identity capture, wheel identification, ABI observation,
test hooks and evidence validation are separate focused adapters. No runtime
dependency or application domain type was introduced.

### Architecture check for Step 4

Jenkins owns stage order; Bash owns transport and process boundaries; stdlib
adapters validate filesystem and observation data. The independent cplx closure
checker retains declaration/family authority. Application business layers do
not import these CI adapters. The authoring architecture gate passed.

New Python files range from 1 to 187 physical lines; the integration fixture
has 213. The provisioner shrank from 371 to 297 lines and Groovy diagnostics
from 1114 to 1000; the Python ceiling does not apply to Groovy or Bash.
No architecture smell, violation or file-size issue needs addressing.

### Performance check for Step 4

Pin and manifest parsing use dictionaries. Wheel identification indexes expanded
tag identities once and performs direct installed-distribution lookups. Tool
and venv inventories walk each root once and deduplicate canonical files.
Hashing streams fixed-size blocks; loader observations and evidence processing
are linear in their subjects and records. Ancestor checks are bounded by path
depth. No new all-pairs comparison or sorting was introduced.

Native cumulative and focused durations and the full authoring duration are
retained. The first forced application walk flagged two integration calls:
auth lifecycle at 1.24 seconds and PDF activation at 1.03 seconds. Profiling
identified real router/schema construction and XObject traversal. A module
fixture prepares the real auth graph; the activation sample now uses exactly
1000 XObjects, the production threshold. All assertions, real startup and
I/O remain; the experimental fallback input is unchanged. Focused calls were
below 0.10 seconds and 0.30 seconds respectively, and both files passed
`ghog single`. Jenkins keeps its existing timeout. No timing threshold,
timeout, xfail or duration exclusion was added. No performance issue needs
addressing.

### Unit test coverage check for Step 4

No existing unit-tested application class changed. Two existing integration
tests received the measured timing repairs above without losing assertions.
The added cases are
integration fixtures spanning CI entry points, with no class-level coverage
target. Generated bundle mutations and permuted provider observations cover
finite failure cases without adding a PBT dependency. Fixtures exercise
transport/provision entry points, wheel selection, ABI inventory/parsers,
plugin configuration and a collection-to-JSON hook roundtrip.

Every new top-level production symbol is referenced by a fixture, adapter or
CLI entry; TypedDict declarations annotate the record and pytest hooks are
registered through the explicit plugin. The app's 100% coverage measures
`src/pdfss`, not `ci` or the cplx fixtures. The cplx gate is the plan's native
cumulative runner; no artificial pytest project was added. No unit-tested
class below 100% needs completing. No top-level symbol outside the coverage
gate is unreferenced.

### Feature integrity for Step 4

Release-pin transport and the independent SQLite diagnostic remain available;
candidate pins require explicit publication suppression and cannot mix with
legacy or verifier-only pins. Every ordinary release provisioning run now
supplies independently pinned verifier controls through the documented early
preflight contract. SQLite-only diagnostics allow publication-enabled mode
because they do not publish an archive. Existing historical diagnostics keep
their reporting
behavior while the adopted ABI gate propagates failure. Artifacts preserve
raw observations, coverage, skip reasons and wheel identities.

Native regression controls and the application walk passed. Step 6 still owns
actual Debian/Jenkins and final RHEL acceptance against the Step 5 archive;
fixture success does not claim those results. The release record and umbrella
remain pending, and no archive or release pin was published or changed.
No existing feature or reporting capability is impaired.

## Step 5. Refresh, rebuild and package the candidate

### Analysis of Step 5 implementation state

Yes. Step 5 has been fully implemented.

The explicitly selected Python 3.13.15 was refreshed and rebuilt with SQLite
in the owned RHEL namespace. Handoff point 2 has now completed the installer-only
repackage as `tools.2026-09-18_220913.tar.gz`, with unchanged payload
bytes, fresh preservation checks and passing AR1/AR2/AR4 assertions. The original
candidate retains its historical evidence and RHEL PA6 failure. Declaration
authority remains valid. Step 6 runtime acceptance for the replacement and the
final publishing revision remain pending, as the plan requires.

### Goal for Step 5

Build the explicitly selected Python with SQLite, clean the private archive
stage and preserve declaration authority.

### Step 5 improvement expectations

The exact timestamped archive has conclusive build evidence; every inherited
ownership entry is discharged correctly.

### What was implemented for Step 5

- **Private stage**: `pkg_tools.sh` unlinks only `tools/python/root/a.out`
  before the closure gate and tar. It rejects symlinked parent boundaries and
  a directory at the exact residual path. The live tree and protected providers
  remain intact, including terminal symlink and hardlink cases.
- **Residual accounting**: only the discharged literal `STEP4_ARCHIVE_DEFECTS`
  register changed in the inherited relocation harness. The new focused harness
  checks seven package cases and clean, stale, unowned, owned and replaced
  ownership controls. Gate/tar trees compare equally; unrelated names survive.
- **Refresh and build**: the dated official-source review selected 3.13.15.
  Existing item 5 resolution supplied 106 curated rows and 81 distinct RPMs.
  Owned temporary space and selected-tool context repairs retained their refused
  attempts. The existing extraction can retain newer files; the capture records
  measured runtime bytes separately from input RPM identities. Git was reused,
  with 2 shared paths aligned from the refreshed Python tree.
  No host packages were installed and Git was not rebuilt.
- **SQLite and archive evidence**: the existing acceptance driver completed
  explicit reconfiguration, clean compilation, installation, promotion and
  operator probes. Configured SQLite, same-process mapped-provider identity and
  file-backed commit/close/reopen checks passed. `pkg_tools.sh` produced
  545310257 bytes, SHA-256 `d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1`, with SHA-1, commands and elapsed times
  recorded in the [candidate capture](evidence.tools-archive-rebuild.step5-original-candidate.json).
  Live trees, payloads, Git executables and the project sentinel passed their
  preservation comparisons. Raw captures and the exact archive are retained.
- **Actual archive assertions**: the pre-frozen program oracle, actual extracted
  archive and inherited harness established zero selected residual programs,
  an empty handoff and an empty, non-stale register. All 539 cases passed;
  AR1, AR2 and AR4 pass.
  Historical library rows provide the inherited parser input; they do not claim
  complete refreshed-library qualification.
- **Authority and record**: source authority `13c80d572ba7bda91728806ad7dc11c53629a506`
  and retention merge `5f8d4d67ca549bb74e3bcbb798124d628c3d0619` are reachable from
  build base `6ed601008162f0527d289758005f7e16cffaf806`. The declaration remains
  `63a955f8bded96f6a469764c625e9653c0988abe03ebd8192fc541f802d9d5aa` and matches the
  packaged file. No renewal was required. Source overlay, authority and future
  publishing revision are distinct. The sidecar binds six capture digests and
  only AR1/AR2/AR4/RA1 pass; its Markdown is rendered from that sidecar.
- **Cumulative validation**: native RHEL `verify.tools-archive-rebuild.sh --step 5`
  passed in 63 seconds with syntax, lint and compile gates; 7 package cases,
  5 register controls, 63 installer cases, 53 wrapper cases, 38 SQLite acceptance
  controls and all earlier suites passed. The inherited closure suite reported
  254 cases, zero failures. The [validation capture](evidence.tools-archive-rebuild.step5-validation.txt)
  records the full-log digest and distinguishes fixtures from candidate proof.
- **Resume verification**: the four current source hashes and retained full-log
  digest match that native run. A fresh record check verified capture bindings,
  rendered Markdown and pending acceptance cells. Read-only checks of the
  retained candidate and raw-capture bundle verified their sizes, SHA-256 and
  SHA-1. A fresh `ghog day` passed shell lint, then stopped with exit 5 because
  cplx has no configured pytest environment. The plan's native cumulative runner
  supplies the required validation; no pytest or coverage percentage is claimed.

- **Installer-only return on 2026-09-18**: the committed installer was overlaid
  into both namespace copies before a fresh audit and the existing packager.
  `tools.2026-09-18_220913.tar.gz` is 545293468 bytes,
  SHA-256 `df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87`.
  Content hashes, modes, entry types and link targets match for all
  38070 archive members except `tools/bin/install_pkg.sh`;
  timestamps are excluded. No refresh, compilation or promotion was repeated.
  The source tree after the explicit overlay and protected live trees passed
  preservation checks. Fresh frozen-oracle archive checks passed all 539 cases,
  with zero selected residuals and empty handoff/register. The
  [replacement capture](evidence.tools-archive-rebuild.step5-candidate.json)
  binds a separate retained archive and raw bundle; the original captures remain
  byte-identical under explicit historical filenames. Authority and retention
  merge remain reachable from source revision `7aa660f8a2f182fc91790fd1182166ad8b662d5b`.
  The record verifier checks both candidates and their capture digests, preserves
  historical verdicts, reproduces the Markdown view and permits only
  AR1/AR2/AR4/RA1 passes for the replacement. No runtime pass was inherited.

### New types/classes introduced for Step 5

No production class or type was introduced. `package_case` and `register_case`
are test-only Bash functions in the focused harness; its callbacks exercise
unchanged inherited ownership functions. Existing refresh, acceptance and
packaging entry points perform the actual build.

### Architecture check for Step 5

The change stays in the native packaging adapter. No business layer imports a
technical dependency or gains build responsibilities. The focused test owns its
fixtures; the 6,661-line inherited harness changes only its literal register,
as the plan explicitly requires. The plan's 650-line Python-file ceiling does
not apply to these Bash files. Evidence files contain data, with
generated release-record prose derived from the existing validator.

No, there is no architecture violation, smell or size issue to address for Step 5.

### Performance check for Step 5

The new unlink and two parent-boundary checks have fixed cost. Existing stage
copying, closure walks and tar creation retain their linear passes. The focused
fixtures use a fixed number of cases and linear tree comparisons. Evidence
hashing and measured runtime alignment process each selected object once per
phase; no new quadratic or sorting path was introduced. The captures retain
refresh, build, promotion and package times. The successful native build was
not repeated after its checks passed.

No, there is no performance issue to address for Step 5.

### Unit test coverage check for Step 5

No Python class or class-focused unit test was changed. This repository's
planned native cumulative runner is the validation entry for these Bash
integration and acceptance checks. The application's separate coverage gate
measures `src/pdfss`; its prior green result supplies no percentage for cplx
scripts or developer tools. The stdlib fixture runs likewise make no percentage
claim for those files.

Both new top-level test functions are invoked by their case loops. Their local
callbacks are referenced by the extracted production functions. The affected
`pkg_tools_build_stage` and `pkg_tools_trim_stage` functions are called by the
real packager in fixtures and in the candidate build. The cumulative runner
executes every newly wired entry. The finite pathname and ownership classes are
covered explicitly; a property-based generator adds no required case here.

No, there is no unit-tested class below 100% that needs completing for Step 5.
No, there is no unreferenced top-level symbol outside the coverage gate.

### Feature integrity for Step 5

The real closure gate still runs against the same trimmed stage that is archived.
Protected loader/provider bytes and loader aliases survive; the live build tree
is unchanged. Stale and unowned residual reporting remains effective. Existing
installer, wrapper, SQLite, D10, agent, release-record and publication fixtures
remain green. PA results, multi-role RA2, lock/wheel identities, publication and
adoption remain pending. Step 6 must bind exact inputs and reassess affected cells.

No existing feature or reporting capability is impaired by Step 5.

## Step 6. Complete pre-publication platform acceptance

### Analysis of Step 6 implementation state

Yes. Step 6 has been fully implemented.

The checkpoint ending `92e361a` is committed. Fresh RHEL qualification binds
the final application, canonical lock and all 77 Debian-resolved wheels to
the unchanged archive. Its ten required cells pass, as do fresh AR1/AR2/AR4
checks. D10 compares both retained provider pairs and selects the packaged
GCC 11 runtime; no candidate rebuild or additional Jenkins job is needed.
Build 188 remains the exact Debian qualification: PA1 through PA9 pass,
6500 tests execute, coverage is 100%, and Q10 excludes only 31 identified
browser cases. No browser evidence is claimed.

The independent native publication validator accepts the exact archive after
checking the completed prepublication floor. The private coordinate is
retained by digest; materializing that one field leaves every other record
value equal. This is publication eligibility, not an upload. Immutable
publication, normal-pin retrieval and adoption remain Step 7, with uploads
off. The proposed interpreter DT_NEEDED additions remain unadopted.

### Goal for Step 6

Collect conclusive candidate-bound AR/PA and pre-publication RA evidence, including exact wheels and D10.

### Step 6 improvement expectations

Changed inputs invalidate affected results; optional cells remain distinguishable; one permitted D10 rebuild cannot become an unbounded loop.

### What was implemented for Step 6

- **Bundle composition**: `ci/deliver-closure-tools.sh` gains `--bundle FILE`
  beside the unchanged `--into DIR` delivery. It archives every tracked file
  below `src/` and the acceptance controls (the item 6 SQLite driver and
  helpers, the installer, relocation and wrapper harnesses, the archive
  oracle and the new platform driver) from the exact commit, writes
  `acceptance/source-revision.txt` and a two-space SHA-256 manifest over every
  other regular member, produces deterministic bytes (fixed owner, commit
  timestamp, sorted members, unstamped gzip), then reads the archive back as a
  consumer would and verifies the manifest, the revision and the member
  count before printing `BUNDLE|COMPLETE|commit|sha256|path`. Links below
  `src/`, a branch name, a missing control and an occupied destination refuse
  with nothing written.
- **Platform acceptance driver**: `docs/v0.27.0/acceptance.tools-archive-rebuild.sh`
  takes explicit archive, bundle, revision, pdfs, deploy-script and
  previous-installer pins and refuses a wrong digest, a misplaced or occupied
  run home or a non-timestamped archive before any probe. Its `rhel` mode runs
  PA1 (fresh `--prefix` relocation, forced reinstall reproducing the fresh
  counters, `deploy_pkgs.sh --force` over the existing prefix), PA2, the PA3
  deploy role through item 6's driver from the bundle plus the retained build
  role capture, PA4, PA5 through the delivered closure checker, PA6 (offline
  dry-run lock audit, heavy-wheel imports, retained wheel search path), PA10,
  PA11 through `env -i` operator probes, and AR3 with the relocation pass
  alone over a v0.26.0-relocated tree. Each probe leaves a raw log, an exit
  file and a cell file bound to the pinned archive and run. Its `debian` mode
  reads a retained agent build into the same cells, re-runs the application's
  test-evidence validator and checks the lock against the application
  revision. Its `d10` mode wraps the inherited reader with one permitted
  rebuild and refuses a third iteration. `summarize` digests every named
  capture, refuses foreign identities and unknown states, turns a pass without
  a capture into inconclusive and a required cell that never ran into pending,
  and exits 0, 1, 2 or 5.
- **Fixtures**: `docs/v0.27.0/verify.tools-release-acceptance.sh` covers 61
  cases: bundle composition on both sides including the consuming project's
  bundle adapter, tampering, missing controls and links; driver pin refusals;
  nine summary outcomes; fourteen Debian reader outcomes including a foreign
  identity and a drifted lock; and the D10 archive-only, rebuild, settle,
  third-iteration, non-convergent and inconclusive paths over compiled
  provider fixtures, plus the venv exclusion run and its wheel-preservation
  assertions. Three added cases cover binary-marker manifest production,
  timestamped Jenkins success with unchanged raw console bytes, and a
  timestamped ABI failure that must remain a failure.
- **Runner**: `verify.tools-archive-rebuild.sh --step 6` lints the three
  scripts with ShellCheck and runs the new fixtures before the inherited
  suites.
- **Real RHEL acceptance**: the driver ran natively for 3995 seconds over the
  exact archive with a bundle composed from the transferred tree. PA1, PA2,
  PA3 (both roles), PA4, PA5, PA10, PA11 and AR3 pass; AR3 observed the
  interpreter as a fresh program, then as a migration with 162 objects
  checked equal to the case 5 population and zero failures, then as already
  correct with zero rewrites, and the forced reinstall reproduced the 446
  rewrites of the fresh install before settling likewise. PA6 fails: the
  relocated `_extra.so` carries only the prefix toolchain directories where
  the production tree carries `RUNPATH [$ORIGIN]`, and `libmupdf.so.27.2` is
  not found. Two earlier runs the same day were driver corrections (force
  reinstall re-extraction, operator probes under errexit); the record binds
  the third run only.
- **Original record and view**: the [results capture](evidence.tools-archive-rebuild.step6-original-rhel.json)
  and [validation capture](evidence.tools-archive-rebuild.step6-validation.txt)
  are indexed in the sidecar; the RHEL deploy environment carries the run,
  OS and provider digests, the build environment its transfer digest, ten
  cells their state, run, captures and input snapshot, and the acceptance
  view gained a Step 6 section with the finding and the prepared Debian
  inputs. Raw captures and the bundle are retained on the build host under
  the run identity with their digests.
- **Venv-tree exclusion in the ELF pass (decided 2026-09-18)**: the
  requirement's PA6 row and a Q06 clarification, the design's acceptance
  table, the plan's Step 6 file set and umbrella item 8 now record the
  decision. `install_pkg.sh` lists every directory holding `pyvenv.cfg` in
  one walk and prunes those trees from the ELF pass, naming each excluded
  tree in the install output; wheel objects keep their `$ORIGIN` search path
  and resolve shipped providers through the application's shared runtime
  setup (Q09),
  while the symlink and text passes still relocate a shipped venv. The
  fixture harness compiles a venv tree with an `$ORIGIN`-relative wheel
  object beside a builder-anchored library outside the venv, runs the pass
  over that root and requires the wheel bytes and `RUNPATH` unchanged, one
  walked and rewritten object, and one case 4 record; it failed first
  against the unchanged installer and passes after the correction.
- **Validation evidence**: native cumulative `--step 6` passed in 74 seconds
  (shell lint, ShellCheck, 16 record tests, 49 D10, 33 agent, 12 packaging,
  63 installer, 53 wrapper, 38 SQLite controls, 52 acceptance fixtures, 21
  publication and transport tests, 254 historical closure cases), and the
  relocation corpus `--step 3` passed its 104 cases against the corrected
  installer. A `ghog day` walk passed the shell lint gate and stopped at
  exit 5 for the known absence of a cplx pytest environment. The inherited
  closure harness at `--step 6` passes all thirteen delivery cases with the
  updated script; its three other failures (two live-tree alias comparisons
  and the gate archive) are identical with the committed script and
  unrelated to delivery.
- **Review round 1 repairs (2026-09-18)**: native cumulative validation passed
  again in 84 seconds with 58 acceptance fixtures and four independent helper
  imports under Python 3.9.25. The capture retains application HEAD
  `6b22c16fdf9d0aa2ba083f935771209d4a5fc862` plus three uncommitted reader
  repair digests, and all six current cplx overlay digests. The prior
  74-second run above is historical evidence for its earlier application.
  The driver derives a unique deployed project and venv, with six fixtures
  for missing/ambiguous discovery and the audit's working directory. The
  umbrella uses its public project alias. The installed sensitive-content
  hook passes. Postponed annotations repair the three application readers;
  the agent fixture now models the typed pytest hooks and current callback
  signature. Focused application Ruff passes. The application repairs remain
  staged in its sibling checkout for its separate commit flow. The RHEL PA6
  failure and remaining candidate acceptance stay unresolved; this check
  retains No and the missing-work list below. Per handoff point 1, those
  later acceptance obligations do not prevent reviewing the current work.

- **Handoff point 3 checkpoint (2026-09-19)**: the replacement RHEL run and
  all seven retained-file digests were downloaded and verified. The
  [results](evidence.tools-archive-rebuild.step6-point3-failed-rhel.json) and
  [provenance and raw diagnostics](evidence.tools-archive-rebuild.step6-point3.txt)
  bind eight required passes, one additional redeployment pass, the PA3
  build-role failure and PA6 inconclusive state to the replacement. The
  original result bytes are preserved under `step6-original-rhel.json`;
  the historical candidate changes only its capture path. Step 5 snapshots
  remain unchanged, with an explicit unaffected-input assessment. Native
  cumulative `--step 6` passed in 79 seconds; project shell lint passed for
  58 scripts. No production code changed in this checkpoint, and no later
  handoff point was attempted.

- **Point 3 review round 2 repairs (2026-09-19)**: the user selected Python
  3.13.15 and authorised installing uv. A new pdfs verification archive ships
  one complete locked venv for that interpreter. All 80 compatible wheel
  files were verified against the unchanged application lock before offline
  installation. Fresh and forced deployment now pass the unchanged PA6
  offline audit and heavy-wheel import checks, with wheel RPATH retained.
  PA3 passes using candidate-bound build evidence with original probe hashes
  and a fresh comparison proving 38069 unchanged payload members; only the
  installer differs. The earlier failed replacement capture is preserved as
  `evidence.tools-archive-rebuild.step6-point3-failed-rhel.json`.
  See [round 2 results](evidence.tools-archive-rebuild.step6-rhel.json),
  [preparation](evidence.tools-archive-rebuild.step6-r2-preparation.json), and
  [retained evidence](evidence.tools-archive-rebuild.step6-point3-round2.txt).
  Native cumulative `--step 6` passed in 77 seconds. The July application lock
  is a RHEL qualification input; final Debian consumer identities remain
  pending. The umbrella note now states the matching-Python prerequisite,
  and exactly seven exchange 2 round 1 transcript headings were qualified.

- **Point 4 transport and reader repairs (2026-09-19)**: application commit
  `784f33ed` contains the three postponed-annotation reader repairs. The
  candidate pins were committed and pushed with publication off; application
  commit `7acda8ac4b35f20ee0bfee2ac27ecfab6afa174e` selects the native bundle
  composed from cplx `72f6cb290700faf328b73d946e78e8fedab8c2cd`.
  Build 175 refused the earlier Git Bash bundle because its manifest used
  binary markers. The composer now hashes binary bytes explicitly and emits
  the consumer's required two-space format. The Debian reader strips only
  Jenkins timestamp prefixes for parsing, retaining the raw console intact.
  Native cumulative validation passed in 77 seconds with 61 acceptance
  fixtures; project shell lint passed for all 58 tracked scripts. A bundle
  from the repaired Git Bash composer also passed the application adapter.

- **Point 4 retained Debian reading (2026-09-19)**: build 176
  finished FAILURE. The independent native reader binds nine cells
  and available application/runtime identities from the retained console and
  archived artifacts. The original bundled reader and repaired reader were
  both run; their results and the exact reader digest are retained. See
  [Debian cells](evidence.tools-archive-rebuild.step6-debian.json) and
  [build provenance](evidence.tools-archive-rebuild.step6-debian-retention.json).
  The failed build 175 remains retained separately. Publication stayed off.
  That result binding preserved historical RHEL captures and original input
  snapshots; consumer-dependent PA5/PA6 still required fresh acceptance.
  At that checkpoint the wheel and venv captures were missing, rather than
  inferred from the committed lock. Build 177 below supersedes the current
  binding while retaining those historical captures.

- **Point 4 lock transport retry (2026-09-19)**: build 177 checked out
  application commit `6b43b39e` with publication off. The transport identity
  check preserved 83 packages and 491 artifacts; uv 0.12.17 completed
  `uv sync --locked`, installing 80 packages under CPython 3.13.15.
  Its venv base is captured. Provisioning then failed with
  `Wheel capture refused: locked wheel identity absent or ambiguous: playwright-1.60.0.dist-info`.
  Package and Test were skipped. All 24 artifacts and the raw console are
  retained, independently read on native Linux and bound in the
  [retry reading](evidence.tools-archive-rebuild.step6-debian-build177.json)
  and [retry provenance](evidence.tools-archive-rebuild.step6-debian-build177-retention.json).
  PA1 to PA4 pass; PA5 to PA9 remain pending. The original build 176 sidecars
  are unchanged. The committed lock digest is provenance only: no successful
  agent wheel inventory or archived lock was produced. The application owned
  the wheel-identification repair at this checkpoint; build 178 resolves it.

- **Point 4 wheel metadata retry (2026-09-19)**: build 178 uses application
  `68ef3af9`, the same archive and verification bundle, with publication off.
  Locked synchronization and all 80 wheel selections/downloads pass, including
  Playwright. All 80 hashes match the committed lock. The cplx inventory then
  reports `INCONCLUSIVE: ELF outside site-packages: ty-0.0.37.data/scripts/ty`.
  Raw wheel inspection also finds script ELFs in ruff and uv; none are bypassed.
  All 104 artifacts and raw console are retained and independently read on
  native Linux. The [reading](evidence.tools-archive-rebuild.step6-debian-build178.json)
  and [retention](evidence.tools-archive-rebuild.step6-debian-build178-retention.json)
  bind PA1 to PA4 passing and PA5 to PA9 pending. All four build 176/177
  sidecars remain byte-identical. No completed inventory, wheel bundle or
  archived agent lock was produced; downloaded hashes alone cannot qualify PA6.
  The generic-tag fixture now checks ranked selection, exact-match precedence,
  unsupported platforms, ties and absent releases. Native cumulative validation
  passed in 78 seconds after correcting its obsolete rejection expectation and
  supplying the independent reader's new packaging dependency from the
  hash-verified, lock-pinned packaging 26.2 wheel. The independent interpreter
  remains Python 3.9.25. Initial prerequisite/fixture failures remain retained.

- **Round 8 dependency finding**: the committed cumulative runner now requires
  `--capture-python` for Step 4 and later. The application wheel-capture helper
  and its fixtures run in that explicit venv with `packaging` and `tomllib`;
  the other three application helpers retain isolated imports under independent
  Python 3.9.25. This implements the reviewer's application-venv option and
  updates the implementation plan. Native cumulative validation passed in
  78 seconds with `PYTHONPATH` unset and no packaging installed in the
  independent interpreter. The fixture venv reports Python 3.13.9 and packaging
  26.2; this fixture run does not qualify the candidate's Python 3.13.15 runtime.
  Missing capture arguments and a bare interpreter are rejected explicitly.
  New scratch and evidence use the home volume because `/var/tmp` is nearly
  full. The first run exposed an outside-home fixture that assumed `TMPDIR`
  was outside home; its explicit outside-home path now restores that boundary
  check. The initial 48-second failure and successful rerun are both retained.

- **Round 8 inventory ownership correction**: application commits `dae99121`
  and `6ce03c2c` move unused native CLI tools to a tooling group and exclude
  that group from CI's locked synchronization. The previous instruction to
  extend cplx inventory mapping was too broad: the existing site-packages ELF
  boundary matches the intended CI venv once those tools are excluded. No
  inventory rule is relaxed. The fresh build's outcome is recorded separately.

- **Point 4 tooling separation retry (2026-09-19)**: build 179 confirms the
  application fix under Python 3.13.15 and uv 0.12.17. The unchanged pinned
  inventory captures 77 wheels and 80 ELFs; all hashes and the archived lock
  match committed application `6ce03c2c`. All 109 artifacts and raw console
  are retained and independently read on Linux. The
  [reading](evidence.tools-archive-rebuild.step6-debian-build179.json) and
  [retention](evidence.tools-archive-rebuild.step6-debian-build179-retention.json)
  bind PA1 to PA4 passing, PA5/PA7 failing and PA6/PA8/PA9 pending. The ABI
  inventory stops at the pinned archive's dangling Python-root `usr/lib/cpp`
  alias; the same absent target exists in the Git root. Heavy-wheel tracing
  and pytest did not run. The six earlier Debian sidecars remain byte-identical.
  Current consumer identities now include the completed agent lock and wheels;
  historical RHEL passes and original snapshots are preserved, with affected
  acceptance still pending. Step 6 and publication remain incomplete.

- **Round 10 committed application validation**: removed the ignored transport's
  application working-tree overlay. Archive and helper hashes now use one
  captured commit. Updated agent fixtures for `c2b71daf`'s dangling-link list,
  interpreter RPATH and visible system-helper accounting, while retaining
  missing-provider and external-provider refusals. The reader accepts the
  optional dangling count in the complete zero-flags line. Native cumulative
  validation passes in 77 seconds with 63 acceptance cases, isolated bare
  Python 3.9.25 and the explicit fixture capture venv (actual Python 3.13.9).
  That fixture interpreter does not qualify candidate Python 3.13.15.

- **Point 4 ABI retry (build 180, 2026-09-19)**: `c2b71daf` progresses past
  the dangling-alias refusal and per-object loader observations. The direct
  import fails on host libpthread's GLIBC_ABI_DT_RELR requirement against
  candidate libc; pymupdf's RUNPATH and the host cache appear in the retained
  trace. All 1320 artifacts are retained. The independent native reading
  binds PA1 to PA4 pass, PA5 to PA8 fail, and PA9 pending. Exact wheel hashes
  and the archived lock match the committed public-URL lock. Both reader
  versions and earlier captures remain retained; no scan or import is skipped.

- **Step 6 completion after the checkpoint (2026-09-21)**: the
  [fresh RHEL evidence](evidence.tools-archive-rebuild.step6-final-rhel.json)
  retains the original run and a reporting-only reread adding runtime input
  pins and recursive captures. It passes all ten required cells in
  5734 seconds, with shipped Python 3.13.15, its own pip,
  relocated uv 0.12.17, the Q07 lock scope, byte equality for 77 wheels and
  80 ELF objects, real allowed-provider imports, a host child environment
  composed before exec, and a shipped child retaining its runtime.
- **Final archive and D10**: the [fresh archive checks](evidence.tools-archive-rebuild.step6-final-archive.json)
  pass 539 cases. The [D10 reading](evidence.tools-archive-rebuild.step6-d10.json)
  compares actual GCC 11 and GCC 12 libraries without installing GCC 12,
  records all 77 resolved wheels separately from ABI-bearing consumers, and
  selects generation 11 in one reading. Inputs came from retained artifacts
  and Nexus. Candidate bytes, the lock, application and Debian runtime did
  not change, so the nine build 188 cells keep their original run/input
  snapshots with explicit unaffected assessments. Replaced historical
  snapshots remain in the record history rather than gaining invented IDs.
- **Readiness and release boundary**: the [readiness capture](evidence.tools-archive-rebuild.step6-readiness.json)
  binds fresh source-authority and zero-waiver closure checks, the retained
  actual transactional backend proof with a byte-exact helper impact
  assessment, a read-only coordinate preflight and complete prior application
  configurations for recovery. Recovery must be verified before uploads
  resume; no actual restoration or adoption pass is claimed. The public
  record uses a digest reference for the private coordinate. The retained
  private record resolves only that field and passes the native publication
  validator against the real selected coordinate and exact archive. The
  [publication eligibility check](evidence.tools-archive-rebuild.step6-publication-check.json)
  retains both record digests and the one-field binding proof.
- **Final validation**: cumulative native Step 6 checks pass in 89 seconds,
  including 98 acceptance cases, the 16 record tests, ShellCheck and the
  inherited suites. The cplx `ghog day` shell lint gate passes for all 58
  tracked scripts but its pytest phase exits 5 because this repository has
  no pytest environment; this is not reported as a green walk. The new helper
  is also explicitly linted by the native runner. Application coverage is
  evidence for the unchanged application, not for these Bash controls.

### New types/classes introduced for Step 6

No production class or type was introduced. `deliver_check_source`,
`deliver_into`, `deliver_bundle` and `deliver_bundle_check` are Bash
functions extracted from and added to the delivery script's main flow. The
driver's `rhel_*`, `debian_main`, `d10_main`, `summarize_main`, `bundle_check`,
`deployed_venv` and `probe_main` are Bash functions; its JSON work runs in
stdlib Python heredocs under the explicitly named independent interpreter.
`expect`, `run_home`, `cell`, `evidence` and `debian` are test-only functions
of the fixture harness.

### Architecture check for Step 6

- **Placement**: delivery and bundle composition stay in the CI bootstrap
  script that already owned authoritative copies; the driver is effort
  evidence under `docs/v0.27.0/` that composes the shipped installer, the
  delivered closure checker, the item 6 acceptance driver and the consuming
  project's deployment entry without reimplementing any of them.
- **Boundaries**: the driver reads controls only from the verified bundle and
  never from the archive under test; the Debian reader re-runs the
  application's own evidence validator rather than reinterpreting its
  counts. Point 4 records the repaired post-build reader's working-tree digest
  separately from the committed bundle used by the agent; the release
  validator is unchanged. The D10 wrapper now separates
  complete resolved wheel identities from its ABI-bearing subset.
- **Size**: the platform driver is 1083 physical Bash lines;
  its deployed runtime helper is 115 lines. Runtime qualification has
  its own file. No new Python module or class is introduced; the Python line
  ceiling does not apply to these shell scripts. Independent Python heredocs
  remain local evidence parsing and checking, outside a percentage gate.
- **Installer change**: the venv exclusion stays inside the native
  relocation adapter's ELF pass, next to the existing `.git` and
  `__pycache__` prunes, and adds one listing walk rather than a fork per
  directory; the classifier, the record grammar and the other passes are
  untouched.

No, there is no architecture violation, smell or size issue to address for Step 6.

### Performance check for Step 6

- **Bounded inventory processing**: composition digests each bundle member
  once and sorts member names in `O(n log n)` for determinism; the summarizer
  hashes each named capture once and
  reads each cell once; the readers scan the console with anchored patterns.
- **Real run cost**: 3995 seconds for the original RHEL run, 3936 seconds
  for the first replacement run, 3930 seconds for the earlier passing repair
  run, and 5734 seconds for final qualification with the deployed runtime,
  dominated by four relocations, two
  deployments and the SQLite deploy role, all existing entry points.
- **Plan-bound alignment**: work is linear in explicitly supplied evidence and
  artifact bytes apart from deterministic sorting; no repeated all-pairs scan
  was introduced. The existing green Jenkins run is reused on unchanged inputs.

No, there is no performance issue to address for Step 6.

### Unit test coverage check for Step 6

No Python class or class-focused unit test was changed; `tools_release_record.py`
and its 16 tests are untouched and still pass natively. cplx has no configured
pytest coverage gate, so no percentage is claimed; the native cumulative runner
is the validation entry. Statically, every top-level function of the delivery
script is reached from `deliver_main`, every driver function from `main`, its
`rhel_*` phases from `rhel_main` and the probes through the driver's own
re-invocation, and every fixture helper from the harness body; the fixtures
exercise the composer, the consumer check, the summarizer, the Debian reader
and the D10 wrapper, while the RHEL phases are exercised by the real run.
The runtime helper's `check_wheels` function is called before and after live
imports. Its source/input refusal paths are covered by focused fixtures.

No, there is no unit-tested class below 100% that needs completing for Step 6.
No, there is no unreferenced top-level symbol outside the coverage gate.

### Feature integrity for Step 6

- **Delivery**: `--into` behaves as before; the inherited closure harness's
  thirteen delivery cases pass with the updated script, and the combined
  `--into` plus `--bundle` call refuses.
- **Inherited harnesses and record**: installer, wrapper, SQLite, D10, agent,
  packaging, publication and record suites remain green, and the relocation
  corpus step passes against the corrected installer, whose `.git` and
  `__pycache__` prunes, classifier and record grammar are unchanged; the
  record preserves original Step 5 snapshots in its history when fresh
  observations replace them, so no old pass was relabeled. The original PA6
  failure and
  replacement PA6 inconclusive state both remain explicit.
- **Reporting**: cells carry pass, fail, inconclusive or pending with a
  reason and digested captures; a skipped required cell cannot summarize as
  a pass.

No existing feature or reporting capability is impaired by Step 6. Actual
publication and adoption remain pending under Step 7.

## Step 7. Publish, adopt and close with integration evidence

### Analysis of Step 7 implementation state

Yes. Step 7 has been fully implemented.

The exact accepted archive was published through the real transactional
tools-only entry, retrieved independently, and accepted through the normal
10.0.0 release pin on the actual Debian Jenkins agent. Build 189 succeeded
with uploads off. All nine Debian acceptance cells and the independent
completion validator passed. Only afterward did the application restore
snapshot uploads. No actual adoption failure required production recovery.

### Goal for Step 7

Publish immutable accepted bytes, then verify normal-pin retrieval and complete adoption before restoring uploads.

### Step 7 improvement expectations

Real integration evidence completes the record; verified recovery preserves service but leaves item 7 incomplete.

### What was implemented for Step 7

- **Publication**: the existing manual tools-only entry used the explicit
  timestamped archive and authoritative eligible record. The COMMITTED
  receipt binds SHA-256
  `df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87`
  to SHA-1 `5a0c68abac266a68ff5373376f6d55860781ede8`. Independent HEAD
  and full GET returned HTTP 200 and the same 545,293,468 bytes. No intermediate
  Maven artifact, POM preflight, latest-file reselection or overwrite was used.
- **Adoption**: application revision
  `47418c764a5b7be5230896a6ebf31cf55c7f1728` selects 10.0.0, removes
  `tools/tools.candidate`, retains the accepted independent verification
  bundle in `tools/tools.verification`, and keeps uploads off. Build 189
  passed relocation, wrapper and SQLite acceptance, provisioning, package,
  complete ABI and required application tests. ABI counted 686 subjects,
  603 dynamic subjects, and zero flags. PA9 retains the authorized browser
  exclusion and does not claim browser evidence.
- **Evidence reader**: `acceptance.tools-archive-rebuild.sh` accepts an explicit
  immutable release version. It binds the release download digest and bundle
  identity, requires one matching startup pin, release selection, uploads off
  and Jenkins SUCCESS, and retains digest/version evidence in its summary.
  Candidate-mode acceptance remains available.
- **Fixtures**: `verify.tools-release-acceptance.sh` covers complete release
  adoption and wrong digest, pin, candidate override, premature uploads and
  failed main-chain refusals. The publication integration composes the real
  local TLS adapter, transaction, normal-pin retrieval and completion gate;
  a different immutable asset receives no PUT. The owned Git recovery test
  rejects pin-only restoration, accepts the whole compatible configuration,
  and proves recovered failed adoption still cannot complete the release.
- **Input assessment**: the archive, application code, lock, wheels and
  executable pipeline are unchanged from the accepted candidate. Exact
  revision comparison permits only the pin and verification-selector changes.
  Fresh Debian results replace the old run; explicit unaffected assessments
  preserve archive, RHEL and D10 results and their original identities.
  RA5:adoption, RA6 and RA8:adoption now pass in the archive-indexed record.
- **Recovery and uploads**: the acceptance document retains both whole prior
  configurations, their evidence and a reviewable restore-and-verify procedure.
  Actual adoption succeeded, so production recovery is not applicable. The
  mode-only follow-up `1a5101e8` restores snapshot uploads after acceptance;
  the qualifying run remains bound to the uploads-off revision.
- **Completion**: independent system Python 3.9.25 validated the real archive
  and final record. The retained proof binds public and private record hashes,
  the prior coordinate preflight and the sole coordinate-field materialization;
  all other values remain equal. The public summary explicitly records its
  single private workspace-prefix substitution while retaining the original
  summary and every raw capture identity.

Evidence:

- [Execution and timings](evidence.tools-archive-rebuild.step7-execution.json).
- [Actual Debian acceptance](evidence.tools-archive-rebuild.step7-debian.json).
- [Original artifact retention](evidence.tools-archive-rebuild.step7-debian-retention.json).
- [Completion proof](evidence.tools-archive-rebuild.step7-completion.json).
- [Acceptance record and recovery procedure](acceptance.tools-archive-rebuild.md).

### New types/classes introduced for Step 7

None. This step extends existing acceptance functions and process-integration
tests; it introduces no production class or type.

### Architecture check for Step 7

Publication, platform acceptance and record validation remain separate
responsibilities. The acceptance reader consumes retained actual evidence;
the record validator does not publish or run tests. Release selection extends
the existing reader without moving platform behavior into application domain
code. Fixture-only Docker identity and bundle-fetch replacements are explicit
and are not used as actual Jenkins evidence. No DDD or layer violation was
introduced. The changed Python integration file remains below 650 lines.

No, there is nothing that needs to be addressed.

### Performance check for Step 7

Native cumulative Step 7 validation took 92 seconds. The later digest-capture
refinement passed ShellCheck and all 104 acceptance cases in 20 seconds.
The successful real publication took 61 seconds; independent full retrieval
took 11.621 seconds. Jenkins adoption took 2,854.823 seconds, within its
existing 60-minute timeout. Controlled recovery took 0.351 seconds.
Completion read the record once, resolved 47 captures and processed
550,396,181 bytes in 2.657 seconds. Earlier setup failures and historical
non-gating diagnostics remain retained, not silently counted as successes.

New digest work is linear in bytes; release-log parsing is linear in console
length. Existing deterministic capture sorting remains unchanged. No repeated
all-pairs scan, new latency target or additional full build was introduced.

No, there is no performance issue that needs to be addressed.

### Unit test coverage check for Step 7

No production class is introduced or changed. Although located under the
existing unit-test directory, the new publication and recovery cases exercise
multiple real processes and are integration tests, without a per-class
coverage claim. Both new test methods are discovered by unittest; the shell
fixture helper is invoked by the release cases, and every changed acceptance
entry remains reachable from its dispatcher.

The application's coverage scope is `src/pdfss`; actual build 189 revalidated
100% coverage, active nonselecting testmon and the guarded SQLite suites in
the authorized non-browser scope. This does not measure the cplx acceptance
scripts or external release helpers. Their evidence is the native cumulative
and focused process/acceptance runs. The local application ghog walk exited 0
with no changed Python files, and is not claimed as a fresh full suite.
Implementation-check reasoned from these retained results and code without
rerunning tests.

No, there is no unit-tested class below 100% that needs completing.
No, none of the changed top-level symbols outside the coverage gate is
unreferenced.

### Feature integrity for Step 7

Normal release-pin operation now uses the accepted archive with the independent
verification bundle. Existing candidate qualification, immutable collision
refusal and recovery protections remain exercised. Snapshot restoration changes
only its mode file and follows actual acceptance. Historical diagnostic failures
are explicitly non-gating and remain visible; required acceptance failures
still refuse completion. The final archive and all current required obligations
pass the completion gate. No existing feature or reporting capability is
impaired. This final check completes umbrella item 7 with the requirement and
validation-plan paths.
