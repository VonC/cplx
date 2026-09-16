# Design v0.27.0: rebuild, qualify and publish the tools archive

Reference requirement:
[tools-archive-rebuild](feature-request.v0.27.0.tools-archive-rebuild.md).
Umbrella: [Debian agent tools](draft.v0.27.0.debian-agent-tools.md), item 7.

## Context and scope for the final tools archive

Items 1 to 6 provide the completed build, packaging, relocation, wrapper,
closure and SQLite mechanisms. This design composes them into a release
candidate, qualifies that candidate on the actual consuming platforms, and
connects its acceptance to immutable publication and application adoption.

The requirement's AR1-AR4, PA1-PA11 and RA1-RA8 remain the acceptance contract.
Its five consolidated clarifications are settled inputs. This design does not
reselect the coverage policy, platform matrix, Python selection rule or
recovery policy. The confirmed interfaces are a release evidence
record, a candidate input to the existing application flow, wheel inputs to
the existing D10 policy, and the real publication adapter.

Python 3.14, free-threading, a replacement agent image, host package additions,
a Git rebuild and the separate rsync follow-up remain outside this effort.
The later implementation plan owns file assignments, commands and rollout.

## Confirmed technical facts for v0.27.0 tools-archive-rebuild

These facts were checked in the current cplx source and the consuming
application working tree. They describe available mechanisms, not successful
acceptance of an item 7 candidate.

| Existing mechanism | Confirmed behavior and design consequence |
| --- | --- |
| `src/setups/env/bin/pkg_tools.sh` | Builds a private hardlink stage, trims build-only payload there, preserves loader identities, and calls `pkg.sh tools --closure-gate --source-root`. The gate and tar see the same staged tree; the live build tree remains separate. |
| `src/setups/env/bin/pkg.sh` | Stages the deployed declaration, envelope and checker copies; checks their consistency; emits timestamped archives and SHA-1 records under the caller's `~/pkgs`. It cannot package tools without the gate. |
| `src/install/env/python/python_install_functions.sh` | Configures Python against sandbox SQLite headers/libraries and invokes the existing SQLite probe for build and installed roles. |
| `src/setups/env/bin/closure_verify.sh` | Requires separately delivered verification tools, computes the archive SHA-256, derives pre-install and installed observations, and emits archive-keyed evidence. Embedded candidate scripts cannot certify themselves. |
| `src/setups/env/bin/closure_d10.sh` | Reads all shipped ELF subjects, measures GCC 11 and GCC 12 provider capabilities, and applies the existing bounded convergence policy. Its present public input is one subject root plus candidate roots. |
| `src/setups/env/bin/closure_publish.sh` | Resolves release-commit configuration, requires matching archive-keyed verification, repeats static checks, refuses active waivers, and streams an open archive descriptor through a transactional adapter. Default adapter functions refuse. |
| Application `tools/publish_pdf_nexus.sh` | `--with-tools` publishes tools only, accepts an explicit archive argument, requires `--version`, and otherwise selects `tools.latest.tar.gz`. It invokes Maven with a pathname, preflights the POM, and compares SHA-1 afterward. It does not currently implement the closure adapter's transaction. |
| Application Jenkins flow | Reads `tools/tools.version` and `tools/publish.mode` at startup. Its separate SQLite diagnostic can fetch a candidate and verification bundle by independent SHA-256 pins. The main test command still disables coverage and pytest-testmon. |

The older `tools/tools.validation` path targets an item 4 snapshot coordinate;
it is not the selected transport for this item. Item 6's archive-copy route
proved SQLite in a dedicated diagnostic prefix. That diagnostic alone does
not make the main application chain consume the candidate.

[The environment reference](reference.environments.md) owns platform and
access roles. Its historical report-only ABI behavior describes the current
pipeline; this item's requirement explicitly makes the adopted ABI check
blocking. Actual Debian userland and container/image identity must be observed,
not inferred from the shared host kernel.

## Target release state model for tools-archive-rebuild

```mermaid
flowchart TD
    P[Publication backend and adapter capability demonstrated] --> A[Qualified Python choice and refreshed sandbox]
    A --> B[Packaged candidate with exact identity]
    B --> C[Archive, RHEL and actual Jenkins acceptance]
    C --> D[Release evidence complete]
    D --> E[Closure and transactional publication gate]
    E --> F[Immutable tools release]
    F --> G[Agent downloads and uses release pin, uploads off]
    G --> H[Adoption accepted, snapshot uploads may resume]
    C --> I[Failed or inconclusive: retain evidence]
    E --> I
    G --> J[Adoption failed: restore and verify prior configuration]
```

An archive file is a candidate, not a release authorization. An ordinary
Jenkins success is insufficient if diagnostics were inconclusive or the main
application ran another interpreter. Every required result must refer to the
identified candidate and the relevant application/runtime inputs.

Publication eligibility is determined before the immutable coordinate is
used. Adoption is a later state that requires a run through the normal
published release pin. The candidate transport is absent from that later run.

## Candidate construction and authority for the tools release

The RHEL build uses item 5's resolved package lists and architecture index to
refresh a coherent sandbox without installing host packages. It explicitly
sets the selected `CPLX_VERSION`. The release record retains dated upstream
sources and the requirement's conclusive 3.13.15 versus 3.13.14 decision;
automatic repository tag selection is not an input to this release.

The build preserves item 6's SQLite headers/provider selection, compiled
`_sqlite3`, and same-process file-backed database acceptance. A successful
non-release item 6 artifact cannot certify this candidate. Build, relocated
Debian and deployed RHEL roles each supply their own SQLite result.

Packaging continues through the existing private stage. Archive cleanup and
relocation acceptance refer to the actual packaged inventory: remove the
residual `tools/python/root/a.out`, discharge every item 2 handoff member with
its owner, and retire stale ownership entries. Preserve migration positivity,
case 5 equality, the three HOME states and force reinstall. Inventory changes
that invalidate a prior measured scope require its reviewed amendment and
renewed validation, rather than exclusions to obtain zero flags.

The closure declaration remains an independently authorized input. The release
record keeps these identities distinct:

| Identity | Meaning |
| --- | --- |
| Source-envelope commit and declaration digest | Exact source blob underlying the delivered declaration/envelope pair. |
| Final cplx revision supplied to publication | Separately resolvable release history whose declaration must match the archive envelope. |
| Completed archive SHA-256 | Exact compressed bytes accepted and handed to publication. |

For the current declaration, the source commit retained by item 6 remains the
starting authority. The publishing checkout must resolve it. If refresh or
Python selection changes the declaration, apply the complete
[item 6 Step 3 renewal contract](plan.v0.27.0.python-sqlite-support.md#step-3-bind-the-candidate-layout-to-its-closure-declaration),
including its concrete authorization boundary, paired delivery, retention
merge and fresh single-branch clone proof. Neither a digest edit nor a
temporary source ref replaces that contract.

## Release evidence composition and invalidation

The release record is a structured sidecar outside the archive,
indexed by its SHA-256. It aggregates references to existing evidence rather
than changing the closure result grammar or placing evidence inside the bytes
whose digest it names. A human-readable acceptance view presents the same
record for review.

The structured record and its acceptance view are versioned cplx evidence
under this effort's `docs/v0.27.0/` directory. The plan chooses their exact
filenames. Raw captures remain in their retained evidence locations, bound by
identity and digest; an ignored local file alone is not durable release
evidence. The release maintainer updates the record from candidate acceptance
through publication, adoption or recovery, retaining prior states in history.
A cplx-owned release validator checks the record and its referenced evidence
at the application's publication entry, before the closure gate can invoke
the adapter. It checks adoption completeness again before item 7 is completed.

The versioned record follows the same sanitization rule as item 6's acceptance
record: environment, container and runtime identities appear as evidence,
while account paths, workspace paths and access details remain in the ignored
captures it references.

| Record area | Required content |
| --- | --- |
| Candidate | Timestamped filename, byte size, SHA-256, packaging SHA-1, explicit Python version, payload identities and regression decision sources/date. |
| Authority | Source-envelope commit, declaration digest, cplx release revision, authority checks and any renewal proof. |
| Consumers | Application and pipeline revisions, dependency lock digest, resolved wheel filenames/digests, venv base interpreter identity. |
| Environments | Run/build identifier, observed OS, actual image/container identity for Debian, runtime/provider identities and transfer digest checks. |
| Results | Required AR/PA cells and RA obligations, status, referenced capture identities, producing run, and affected input identities. |
| D10 | Reading generation, every consumer and required node, both candidate capabilities, selected generation and any second reading. |
| Change assessment | Release maintainer's affected/unaffected decision, repeated results and explicit reasons for retained results. |
| Publication and adoption | Selected release coordinate, published SHA-1 and SHA-256 association, retrieval confirmation, pin/configuration revisions, adoption or recovery result. |

Result states distinguish pending, pass, fail, inconclusive and not applicable.
Only the requirement's optional or inapplicable cells can be omitted from a
gate; an empty result is pending. A pass requires identified, retained evidence
and a conclusive result. The record validates completeness and identity
consistency; it does not independently prove arbitrary maintainer prose true.

Before publication, the release gate requires all pre-publication obligations,
including Jenkins PA9 and the real uploader capability, plus the unchanged
closure publication gate. RA6 and post-publication portions of RA5/RA8 are
pending adoption obligations, not circular prerequisites for publication.
Completion requires those later obligations too; successful recovery leaves
item 7 incomplete.

A changed archive creates a new candidate identity. Changed application,
lock, wheels, pipeline or runtime inputs make dependent results pending until
the maintainer records the impact assessment. Unaffected evidence can be
referenced with its original identities and a reason for retention. History is
preserved; an old pass is not relabeled as a new run. A wheel or lock change
requires a fresh D10/ABI assessment and relevant application acceptance even
when the archive hash is unchanged.

## D10 consumer input and runtime validation

Keep the existing D10 selector and bounded convergence rule. Extend its
measurement input to identify the final application wheel ELF consumers in
addition to every shipped archive ELF. Keep archive consumers, wheel consumers
and candidate provider trees distinct in the evidence. Wheel demands must
participate in the same policy evaluation, not a later advisory check.

Measure both consumer sets on the RHEL build/measuring host. Materialize the
exact wheel artifacts resolved by the Debian qualification agent there, by
copying retained artifacts or retrieving the same artifacts by their recorded
identities. Bind the set to the agent's application lock digest and per-wheel
digests; do not resolve a replacement wheel set for the measuring host.
Extract those artifacts for the shared ELF reader and bind the measured ELF
paths/digests to the installed wheel ELF inventory observed on the agent.
Unavailable artifacts, a missing subject or a digest mismatch make the reading
inconclusive. This transports wheel bytes, not a separately interpreted
wheel-demand manifest; actual runtime validation still runs on Debian.

For GCC 11 and GCC 12, record provider identities and their actual `GLIBCXX_`,
`CXXABI_` and separate `GCC_` capabilities. Select the lowest candidate that
satisfies all required nodes; zero headroom is valid. An unreadable capability,
empty relevant consumer observation or incomplete wheel inventory is
inconclusive. If the selected generation differs from the reading generation,
rebuild, remeasure and require the second evaluation to return exactly that
generation. Any other result is non-convergent; there is no third iteration.
Any changed runtime root also repeats the inherited closure checks.

Static checking and live observation remain separate, complementary evidence.
The installed ABI sweep covers the whole declared resolution scope. Direct
venv Python execution establishes interpreter/base-executable identity and
loads the heavy wheels under `LD_DEBUG=libs,versions`; absent or unusable traces
are inconclusive. No per-wheel patching repairs a failing candidate.

Preserve item 4's strict provider and family checks, item 2's virtual-kernel
and loader-name accounting, and loader paths/aliases inside tools. Recognized
OneAgent objects remain visible excluded monitoring, without added digest or
provenance requirements. Other outside-prefix runtime providers refuse.
Empty or monitoring-only inventories do not pass. Retained helper programs
with system interpreters are reported separately from candidate execution.

## File-based IO cost clarification

Read the selected archive-indexed release record directly; do not scan document
history or raw-capture directories to discover state. Resolve explicit evidence
references once per validation phase and reuse the collected identity map.
Retain required artifact hashing, ELF inventories and gate snapshots; reducing
IO must not remove byte-identity or completeness checks. Walk each declared
subject root once per measurement phase, keep provider and consumer inventories
separate, and stream publication bytes through the existing gate.

## Candidate and release consumption on the actual Jenkins agent

Candidate mode reuses the existing application's main integration
chain. A separately identified archive-copy input selects the candidate and
its digest before provisioning the runtime used by that chain. The same
selection supplies relocation, dependency synchronization, tests, packaging,
walk and ABI probes. Logs report the selected source and interpreter identity.
The normal release pin remains available for ordinary builds and recovery.

This mode extends item 6's existing transport; it does not use its isolated
SQLite diagnostic as a substitute for main-chain qualification. Verification
tools arrive independently with their manifest, preserving the agent's lack
of cplx credentials. The cplx side compares their authoritative identity.
Candidate mode requires application publication explicitly off and refuses
ambiguous candidate inputs or digest mismatches before provisioning.

Qualification uses the intended adopted pipeline configuration: no rsync
shim, no temporary wheel patching, coverage and pytest-testmon enabled, and
the ABI probe blocking with zero flags. PA9 forces a full acceptance selection
with both plugins active, satisfies the application's existing threshold,
and demonstrates that SQLite-guarded suites executed. Persisted testmon state
cannot turn qualification into a no-tests-selected success. Later routine
incremental testmon use remains allowed.

RHEL supplies its required deployment, redeployment, readiness and operator
results against the same archive. The requirement's optional downstream RHEL
ABI/trace/test cells remain optional; inherited closure rules still apply.

After immutable publication, candidate mode is disabled. The real agent reads
the new `tools/tools.version`, downloads the release artifact, checks its
identity and uses it in the integration chain with application uploads still
off. This distinct run proves startup pinning and retrieval as well as chain
and ABI behavior. Relevant input changes trigger the evidence reassessment
above. Only accepted adoption permits restoring `snapshot`.

## Publication adapter and exact archive binding

Keep the application's manual `--with-tools --version` entry point and its
next-release coordinate. Resolve the archive once; pass the explicit accepted
archive instead of letting a later `latest` selection choose different bytes.
Record both the publication SHA-1 and the stronger archive SHA-256 association.
A changed selection invalidates the prior acceptance.

The application-owned adapter connects this entry point to
`closure_publish.sh`. The existing gate retains control of the open descriptor
and invokes the uploader only after authority, evidence, static closure and
waiver checks. Its four-operation contract remains:

| Operation | Required publication semantics |
| --- | --- |
| `upload_begin` | Create a private, non-public stage and return its handle. |
| `upload_write` | Consume the supplied byte stream into that stage without reopening the candidate pathname. |
| `upload_abort` | Remove the unpublished stage, leaving no public candidate. |
| `upload_commit` | Make the verified staged object public atomically at the intended immutable coordinate. |

The present Maven pathname upload and its post-upload checksum do not establish
those semantics. Actual repository/uploader staging and visibility behavior
must be demonstrated before this adapter is considered usable. A locally
buffered file followed by an unchecked public upload is not equivalent.
Repository capability is a release-blocking prerequisite, not an assumed
Nexus feature or permission. If unavailable, report the unmet inherited
contract and resolve it in its owning design before release; do not bypass
the gate or silently weaken its checked-byte guarantee.

Demonstrate that backend and adapter capability before spending the sandbox
refresh and rebuild work. This early prerequisite uses the actual publication
backend and applicable permissions; a mock adapter alone does not establish
it. Later publication still repeats the final candidate's eligibility and
transaction checks.

No release-side POM or tools asset is uploaded as a preflight before release
eligibility and the transaction are established. A publication failure retains
diagnostics and leaves adoption pending. Existing immutable-coordinate rules
still apply; observing an existing asset is not permission to overwrite it.

## Adoption failure and recovery boundary

Retain the previous working tools pin together with its compatible application
configuration, including any required interims. During failed adoption,
application uploads remain off. Recovery restores that coherent combination,
verifies it through the existing application gate, and records the restored
revision before uploads resume. It may restore coverage-disabling settings
temporarily, but cannot satisfy item 7 acceptance.

The failed release coordinate, archive and results remain identifiable. A
corrected archive starts a new candidate and needs a new eligible application
release coordinate and renewed acceptance. Recovery changes the consuming
configuration; it never replaces bytes under the failed immutable release.

## Acceptance cases for the composed tools release

| Scenario | Required outcome |
| --- | --- |
| Python 3.13.15 has no known relevant blocking regression at release time | Select it explicitly, retain dated sources and repeat all final-archive acceptance. |
| A relevant 3.13.15 regression is found, or the assessment is inconclusive | Use 3.13.14 for the former; keep selection unresolved for the latter. Renew authority if the declaration changes. |
| SQLite diagnostic succeeds but main tests still use the old archive | PA9 and candidate integration remain pending. |
| Testmon selects no tests, or SQLite suites skip for missing SQLite | PA9 refuses, regardless of plugin import success. |
| Archive unchanged but resolved wheels change | Assess and repeat dependent D10, ABI and application checks; do not reuse passes by archive hash alone. |
| A required node is satisfied only by the host | Refuse; host capability cannot satisfy shipped-provider closure or D10. |
| Source-envelope authority resolves but release-commit declaration differs | Publication refuses before upload. |
| A newer unqualified archive replaces the default latest target | Refuse that selection; explicit accepted bytes remain the only qualified candidate. |
| The publisher lacks a demonstrated private-stage/atomic-commit adapter | Publication remains blocked; Maven success is not evidence of the missing contract. |
| Pre-publication Jenkins passes, but release-pin retrieval or adoption fails | Preserve the failed coordinate, keep uploads off during recovery and verify the restored working configuration. |

## Design decisions for tools-archive-rebuild

The four option A answers are confirmed. Source-authority renewal, transaction
semantics, platform obligations and release immutability remain inherited
contracts. Actual release evidence, uploader capability and candidate results
are still to be produced by implementation. No open questions remain before
implementation planning.

| Question | Decision and reason | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | Use a structured archive-indexed sidecar and acceptance view, versioned as sanitized cplx effort evidence and maintained through adoption or recovery. A cplx validator checks referenced evidence, statuses and identities before the closure gate and checks adoption completeness later. Explicit identities expose stale or missing acceptance while preserving the original evidence formats and maintainer impact judgments. | [Release evidence composition and invalidation](#release-evidence-composition-and-invalidation) | A Markdown-only ledger with manual sign-off leaves completeness and identity consistency to repeated manual checks. |
| Q02 | Qualify the candidate through the existing main application chain on the actual Jenkins agent, with uploads off and the exact candidate interpreter supplying full coverage/testmon acceptance. Remove candidate mode for the separate release-pin run. Reusing the adopted stages avoids a second orchestration flow and its equivalence burden. | [Candidate and release consumption on the actual Jenkins agent](#candidate-and-release-consumption-on-the-actual-jenkins-agent) | A dedicated validation flow using shared stages still needs proof that its composition matches the adopted pipeline. |
| Q03 | Extend D10 with identified wheel consumer roots and keep its reader and selector. Measure the Debian agent's exact wheel artifacts on the RHEL measuring host, bound to the lock, per-wheel digests and installed ELF inventory. This keeps one interpretation of required nodes and one convergence policy. | [D10 consumer input and runtime validation](#d10-consumer-input-and-runtime-validation) | A transported normalized wheel-demand manifest adds another grammar and a trust boundary between wheel bytes and reported needs. Host-specific replacement resolution cannot represent the agent's consumers. |
| Q04 | The application owns the repository-specific transaction adapter; cplx owns and invokes the inherited contract. Prove actual backend and adapter capability before the sandbox refresh and rebuild, and repeat final publication checks. This keeps coordinates, credentials and publishing policy with the application's existing entry point. | [Publication adapter and exact archive binding](#publication-adapter-and-exact-archive-binding) | A cplx-owned repository adapter adds application transport policy to cplx and still needs the same backend proof. Ordinary public upload followed by a checksum cannot replace the inherited transaction. |
