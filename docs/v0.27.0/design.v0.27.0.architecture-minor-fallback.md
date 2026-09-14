# Design v0.27.0: architecture minor fallback

Reference requirement:
[architecture-minor-fallback](feature-request.v0.27.0.architecture-minor-fallback.md)

Umbrella: [debian-agent-tools](draft.v0.27.0.debian-agent-tools.md), item 5 and D9.

## Context for the v0.27.0 metadata resolver

The requirement is consolidated in `a5a974f`. Its eleven clarifications fix the
selection policy, index identity, cleanup boundary and synchronization behavior.
This design describes the proposed structure for those rules. Its architectural
choices require design review; requirement decisions are not reopened.

RHEL is the tools/dependency preparation, packaging and deployment environment.
It packages both tools and the private application. Jenkins Debian consumes
prebuilt tools, checks the application out from source and runs tests; that job
packages and publishes only the application archive to Nexus. No compilation
or tools publication belongs to the Debian acceptance path.

## Scope of the v0.27.0 package setup change

The design covers curated list and mirror resolution, detected-key index
availability, propagation of selected inputs through setup, and synchronization
progress scoped to the selected list and detected key. It includes the ordinary
and direct single-package paths and compatibility with explicit reset commands.

Item 4's completed runtime-closure checker remains downstream of dependency
preparation. Item 6 owns SQLite integration and its rebuild; item 7 owns the final
tools refresh, rebuild, platform validation and release. New-tool RHEL 9 seeds,
package-version solving and automatic freshness detection are separate work.

## Confirmed facts about the current setup flow

These facts were checked in the source while writing this design:

| Source | Current behavior | Design consequence |
| --- | --- | --- |
| [setup.bat](../../src/setups/setup.bat) | CMD launches Bash with `cygpath`, translates `p_<name>` into `--package`, and deletes or writes the plain `pkgs/<tool>/last` marker for reset commands. | Keep CMD as the entry point and Bash as the owner of metadata behavior. Reset handling crosses that boundary. |
| [setup.bat](../../src/setups/setup.bat) | Reset-after-entry writes a CRLF cursor against LF lists, then passes the same entry to the step helper. An entry matching no step causes fatal 10 and launcher exit 119. Bash also receives the unshifted `%*` words. | Restore the reset interface: consume the entry once, forward unambiguous intent and compare normalized active entries. |
| [setup.sh](../../src/setups/setup.sh) | Connection validation reads the remote OS identity and stores the detected architecture. | Keep that property authoritative; selected metadata needs separate identity. |
| [setup_packages.sh](../../src/setups/setup_packages.sh) | Ordinary setup generates an index, synchronizes a list, then copies a separately reconstructed exact list for remote installation. Direct package setup skips generation. | Carry the selected list to both consumers and give both entry paths index availability checks. |
| [properties.sh](../../src/utils/properties.sh) | Reads only the active properties file and trims values. Duplicate definitions yield multiple lines, but package consumers read only the first line. | Enumerate each mirror key once, keeping its first definition; the tracked template is not a second runtime fallback source. |
| [steps.sh](../../src/utils/steps.sh) | Completion is stored by step name in Markdown. Package generation checks this before checking the exact index and only the force flag bypasses it. | File availability and either reload flag must take precedence over the historical marker. |
| [setup_packages.sh](../../src/setups/setup_packages.sh) | Index assembly empties the destination before merging results; lookup touches a missing index. | Separate read-only lookup from generation and publish a completed index without an empty placeholder. |
| [setup_packages.sh](../../src/setups/setup_packages.sh) | Synchronization records the last successful entry without list or architecture identity. A cursor matching no active entry can skip the entire list and report completion. Local downloads use `pkgs/<arch>/`; remote copies use `tools/pkgs/`. | Bind progress to identity and validate the cursor before synchronization; retain cache locations and ordinary reuse. |
| [packages_management.sh](../../src/setups/env/bin/packages_management.sh) | Remote installation resolves names against staged RPMs rather than reading the local generated index. | The selected list must reach remote installation, and validation must observe actual synchronization before installation. |

The CMD/Bash launcher and GNU command usage establish the local setup boundary.
RHEL commands execute remotely through SSH. This design adds no Python, Maven,
compiler or package-manager dependency to the resolver.

## Target flow for ordinary and direct package setup

One invocation retains the detected key separately from its selected metadata.
Ordinary setup resolves its list before synchronization and supplies that exact
selected path to remote-copy preparation. It checks index availability before
package lookup. A direct package request needs no per-tool list or list cursor;
it checks the same exact index before resolving a normal package name.

```text
CMD setup entry -> Bash package setup -> detected architecture
  ordinary: resolve tool list -> prepare exact index -> inspect list progress
    -> synchronize selected entries -> copy selected list -> remote install
  direct package: prepare exact index -> synchronize package -> remote install

prepare exact index:
  nonempty exact index, no reload -> reuse
  otherwise -> resolve mirrors -> generate candidate -> publish exact index

download a package:
  reusable local package -> ordinary copy/reuse
  otherwise -> use the invocation's resolved mirrors in their existing order
```

The existing `_` built-package form does not consult a package index or download
an RPM. Direct requests of that form retain this exception; ordinary list setup
retains its existing index-preparation phase. A failure in package lookup or
retrieval never starts another minor selection.

## Resolver structure and result contract

The proposed architecture has one pure selection policy with two adapters:
per-tool list inventory and active mirror-property inventory. Adapters apply
their metadata kind's presence rule and return candidates with original source
identities. The selector ranks eligible candidates without copying, touching,
generating, downloading or changing properties.

The logical result contains the requested key, metadata kind, selected key,
selected source and whether fallback occurred. Mirror results also retain the
trimmed value and its ordered URL list. Failure carries the requested identity,
kind, eligibility boundary and considered sources with exclusion reasons.
Callers translate failure into the existing setup diagnostic/fatal boundary;
successful result data must remain separate from human log output.

Exact lookup occurs before parsing for fallback. For fallback, compare numeric
major.minor values within the same distribution, major and whole machine name.
The machine remainder is preserved, including the underscore in `x86_64`.
Property adapters translate only the version separator between the known
numeric major and minor, rather than treating every underscore as a separator.
Do not interpret a major-only key as minor zero. Compare integer minors, prefer
the highest lower one, and otherwise select the lowest higher one. A differently
spelled key with an equal numeric minor is neither lower nor higher.

| Metadata kind | Exact presence rule | Action when absent |
| --- | --- | --- |
| Tool list | File exists; empty and comment-only lists are authoritative. | Select an eligible curated list or fail. |
| Mirror | Active property exists with a nonempty trimmed value. | Select an eligible nonempty active property or fail before fetching. |
| Index | Detected-key file exists and is nonempty. | Generate for the detected key; never enumerate other minors' indexes. |

An unreadable or otherwise invalid present input retains its ordinary failure.
Selection does not introduce content validation or conceal a damaged exact
override. It enumerates only the relevant tool directory or active mirror keys.
Each substitution reports the requested key and original selected file/property.

The mirror adapter enumerates each property key once and keeps the first
definition's trimmed value, matching the definition current consumers read.
Later duplicate definitions neither replace nor extend its ordered URL list.
If the first value is empty, that candidate is absent under the approved mirror
presence rule, even when a later duplicate has a value.

## Invocation context for consistent metadata consumption

The proposed context is owned by the current Bash invocation. It holds the
detected key, selected list identity when needed, exact index path, resolved
mirror identity/value when needed, and whether explicit refresh has been served.
Consumers receive those selections instead of reconstructing exact names.

List synchronization and `dependencies.list` copy use the same selected list.
List and mirror selection remain independent. Resolve a mirror at the first
operation that requires it, then retain that value for index generation and
corresponding package downloads. This preserves offline reuse when an existing
exact index and cached packages require no mirror fetch. It also prevents
re-reading edited properties between generation and the downloads it supplies.

This is identity consistency within one invocation, not a filesystem snapshot
of list contents. Concurrent editing or multiple package-setup writers in one
working tree are outside the existing serial setup contract. A later invocation
uses the then-current configuration; it may reuse a nonempty exact index unless
refresh is requested, as the requirement explicitly permits.

## Index lifecycle and checkpoint authority

The proposed availability guard checks the exact file and both reload flags
before consulting completion information. A nonempty exact file may be reused
without refresh, even if the completion marker is absent. A missing or empty
exact file, or either reload flag, requires generation despite a done marker.
One explicit refresh is performed per invocation, not once per package lookup.
No global redesign of the Markdown step system is needed.

Generation uses the resolved mirror list and preserves the existing listing
extraction and package-name aggregation rules. Assemble into a temporary sibling
of the detected-key index, using invocation-owned scratch paths and a name
covered by the package directory's ignore rules. Publish only
after required commands succeed and the assembled result is nonempty, by rename
within the same filesystem. Then record completion. Lookup itself never creates
a file, and never sees an intentionally empty generation placeholder. Remove the
temporary sibling when assembly or publication fails; a crash leftover remains
ignored and cannot satisfy availability checks.

On generation failure, fail the invocation with the underlying diagnostic and
retain any previous exact index. A failed replacement, including a destination
held open on Windows, also keeps the prior index and fails the invocation.
An explicit refresh failure does not fall back
to that old file during the same invocation. On a later invocation without a
reload request, ordinary reuse of a retained nonempty exact index still applies.
If recording completion fails after publication, fail the invocation with a
diagnostic; the valid index can still satisfy a later availability check.

This design does not make a rolling mirror immutable or change existing URL
retry behavior. It prevents a failed assembly from replacing a usable index and
prevents a generated index for another minor from being selected.

## Synchronization progress and reset compatibility

The proposed progress record is one versioned, literal-data record at the
existing ignored `pkgs/<tool>/last` location. Its fields are a format version,
the detected key, the selected repository-relative list path and the last
successfully synchronized active entry. The representation is parsed as data,
never sourced or evaluated as shell code. Relative identity is based on the
selected inventory path, so Windows and Bash absolute-path spellings do not
create artificial changes.

Read the record after list selection. Matching list identity and detected key
retain ordinary resume-after-entry behavior. A missing marker starts normally.
Changed identity, legacy one-line state or a malformed versioned record cannot
establish a valid match and triggers a reported restart at the first active
entry. Do not hash list contents or claim to detect every edit within the same
path. Before processing the first entry, check that a nonempty stored cursor
names an active entry of the selected list. If it does not, report a restart from
the first active entry; never interpret the missing cursor as completion.

Use the same active-entry parsing and line-ending normalization for cursor
validation, explicit reset input and synchronization. An explicit
`CPLX_SP_REPEAT` applies only while a valid recorded cursor is being sought, as
today. It has no effect with an empty cursor or after an identity or stale-cursor
restart. For a valid cursor, retain the existing first-match resume behavior.

After a package is successfully synchronized, replace the complete record
atomically. A crash before that write can repeat a package, which existing
download and remote-copy reuse already tolerate. A progress-write failure stops
setup with a diagnostic instead of claiming durable progress. Write a valid
empty-cursor record when starting a new selection or restarting after an identity
or stale-cursor mismatch, so an interruption cannot restore the discarded cursor.
Direct single-package requests neither consume nor advance full-list progress.
A reset intent combined with a direct package request is rejected before any
progress change.

The current CMD reset command must stop writing a bare cursor. The proposed
interface restores the operator-facing reset/reset-after-entry commands while
forwarding explicit reset intent to Bash. CMD consumes the reset entry and never
passes it to the step repeat/reset helper. The forwarded intent uses an explicit
argument form distinct from the raw `%*` words already received by Bash.

After selecting the list, Bash validates an explicit reset-after-entry against
its normalized active entries before changing progress or synchronizing packages.
An unknown entry fails with a diagnostic naming the selected list and leaves
progress unchanged. A valid entry creates a scoped record and resumes after that
entry; a reset without an entry starts at the first active entry. This fresh
operator intent is distinct from automatically trusting an old legacy marker.
No manual marker deletion becomes an OS-upgrade prerequisite.

The exact record syntax, helper names, diagnostic numbers and file allocation
belong to the implementation plan. The design decision is one atomic progress
unit owned by Bash and carrying both identities together with its cursor.

## Curated cleanup and documentation boundary

The retained 9.6 Python list must use `zlib-devel`. Once equivalence and the
accepted setup behavior are demonstrated, remove the redundant 9.8 Python/Git
lists and the tracked 9.8 mirror key. Generated indexes and operator-local
properties remain outside cleanup. Runtime mirror discovery does not merge in
the tracked template, so acceptance must use an active configuration containing
the 9.6 mirrors and no exact local 9.8 override.

The architecture explanation, OS-upgrade procedure and package-list reference
must describe separate detected and selected identities, per-kind absence,
index generation and automatic progress restart. Checkpoint documentation and
reset-command descriptions must reflect the progress record and explicit reset
interface. The [resume how-to](../../wiki/how-to/resume-or-repeat-a-step.md)
must describe resuming after the supplied entry instead of its current claim of
resuming exactly at that line. The [variables reference](../../wiki/reference/cplx-variables.md)
must likewise describe `CPLX_SP_REPEAT` as resuming after the named entry instead
of re-processing it. Existing exact overrides remain supported.

## Acceptance mapping for the resolver design

| Design case | Expected outcome | Requirement coverage |
| --- | --- | --- |
| Exact curated input exists, including an empty tool list. | Preserve it and its ordinary semantics. | AC2, AC9 |
| An active properties file defines a mirror key twice. | Select the first definition's trimmed value; later definitions do not replace or extend it. | AC2 and mirror-adapter design |
| 9.8 has curated candidates 9.6, 9.9 and 9.10; 9.5 has 9.6 and 9.10. | Select 9.6 in both cases and report the source; preserve the detected key. | AC1, AC4, AC5 |
| Candidates differ in distribution, major, full machine, or numeric-minor form. | Exclude them; fail missing required input with candidate diagnostics. | AC3, AC11 |
| List resolves to 9.8 and mirror to 9.6. | Copy the selected list and pair index generation/downloads with the selected mirrors. | AC6 |
| Exact index is absent/empty or either reload flag is set, even after completion. | Generate and publish a nonempty detected-key index; also cover direct normal-package setup. | AC9, AC10 |
| Index generation fails during a refresh. | Fail that invocation; preserve the prior index without using it as recovery. | AC10 and index-publication design |
| List/key changes or a legacy cursor remains at the final Python entry. | Report restart and process every active entry through selected inputs; retain package reuse. | AC7, AC12 |
| The same list/key resumes after interruption or explicit reset-after-entry. | Resume after the selected cursor with a valid scoped record. | AC12 and reset-interface design |
| A matching record's cursor no longer names an active entry. | Report restart from the first active entry, never a skipped list. | AC7, AC12 and Q07 |
| CMD reset-after-entry names an active entry. | Resume after that entry with normalized comparison; do not pass it to the step helper. | Reset-interface design |
| Explicit reset-after-entry names no active entry. | Fail with a diagnostic before synchronization and leave progress unchanged. | Q07 |
| Corrected curated cleanup is exercised on RHEL 9.8 with no local exact mirror override. | Python/Git dependency setup demonstrates fallback and actual synchronization, with no compilation required in Jenkins. | AC7, AC8 |

These are design acceptance cases, not executed validation. The implementation
plan will assign affected files, narrow checks, host evidence and rollout order.

## Open questions for the v0.27.0 architecture-minor-fallback design

### Q01: Where should the selection policy live?

Lists and mirror properties use different source formats but must apply the same
approved eligibility and ordering rules. The index has a separate lifecycle.

#### BBQ for Q01

Two counters can use one queue policy without selling the same products. In this
picture: the counters are list/property adapters and the queue policy is the
shared architecture selector.

#### Options for Q01

- Option A: Use one pure selector with list and property adapters and typed results.
  - Pro: Keeps eligibility and ordering consistent and selection free of side effects.
  - Con: Introduces an internal interface between discovery and setup consumers.
- Option B: Keep independent selection logic beside each existing consumer.
  - Pro: Requires fewer shared abstractions.
  - Con: Duplicates boundary and ordering rules and risks divergent behavior.

#### Recommended option for Q01

Option A. Share only the common policy; preserve per-kind presence rules and
original source identities in adapters. Index generation remains outside it.

#### Answer to Q01: option A

Option A is proposed because the same confirmed policy must govern both curated
metadata kinds while their absence semantics stay different. The mirror adapter
enumerates each key once and keeps the first definition's trimmed value, matching
the definition current consumers read. Later duplicates do not extend or replace
it; an empty first value makes the candidate absent under the approved rule.

### Q02: How should consumers retain resolved inputs?

Synchronization and remote list copy must agree on the selected list. Index
generation and corresponding downloads must use the same mirror resolution.

#### BBQ for Q02

Keep the selected recipe and supplier address for the current shopping trip.
In this picture: the recipe is the list path, the address is the mirror value,
and the trip is one package-setup invocation.

#### Options for Q02

- Option A: Retain an invocation context, resolving mirrors lazily when first required.
  - Pro: Preserves pairing and cached offline reuse without repeatedly reading properties.
  - Con: Consumers must accept selected inputs instead of reconstructing exact names.
- Option B: Resolve again at each consumer and reject any identity/value mismatch.
  - Pro: Each consumer observes the current configuration directly.
  - Con: Requires extra comparison and can abort after work when configuration changes.

#### Recommended option for Q02

Option A. The context holds detected identity separately, retains the list path,
and pins mirror identity/value for the rest of the invocation after first use.
It does not claim to snapshot mutable list contents or solve concurrent writers.

#### Answer to Q02: option A

Option A is proposed because carrying selections directly satisfies the pairing
contract and keeps mirror access unnecessary when all required artifacts are cached.

### Q03: How should a generated index become visible?

The current generator truncates the destination before completing aggregation.
A failed refresh should fail the invocation without leaving a partial index that
a later run mistakes for a usable exact snapshot.

#### BBQ for Q03

Finish a replacement catalogue before putting it on the shelf. In this picture:
the catalogue is the generated index and the shelf is its detected-key pathname.

#### Options for Q03

- Option A: Generate a temporary sibling and atomically replace the exact index after success.
  - Pro: Preserves a prior valid index on failure and avoids exposing partial assembly.
  - Con: Requires invocation-owned scratch space and a publication step.
- Option B: Generate in place, with a durable in-progress marker checked by every reader.
  - Pro: Uses the destination directly without a final replacement.
  - Con: Adds persistent recovery state and requires every reader to honor it.

#### Recommended option for Q03

Option A. Publish only a nonempty successfully assembled index, then mark
completion. A failed explicit refresh still fails that invocation; retaining the
previous file does not authorize immediate recovery with it.

#### Answer to Q03: option A

Option A is proposed because same-filesystem replacement protects later reads
without a second durable index-validity protocol. The temporary sibling has an
ignored name and is removed on assembly or publication failure. A failed
replacement, including an open destination on Windows, keeps the prior index and
fails the invocation.

### Q04: What should own index availability versus step completion?

The existing Markdown done marker is not architecture-specific. Both reload
flags and missing or empty exact indexes must override it, including direct setup.

#### BBQ for Q04

Check that today's catalogue is on the shelf even if an old checklist says done.
In this picture: the catalogue is the exact index and the checklist is the
download_packages_list completion marker.

#### Options for Q04

- Option A: Make exact-file availability and reload intent authoritative; retain the marker as completion reporting.
  - Pro: Satisfies the requirement without changing the shared step-state model.
  - Con: The marker alone cannot establish index availability.
- Option B: Add per-architecture completion records, while still checking exact files and reload intent.
  - Pro: Makes recorded completion explicitly architecture-aware.
  - Con: Adds redundant state and migration beyond what availability needs.

#### Recommended option for Q04

Option A. One availability guard serves ordinary and normal direct-package
lookup. Serve explicit refresh once per invocation, and record completion only
after successful publication. No cross-minor snapshot can satisfy that guard.

#### Answer to Q04: option A

Option A is proposed because filesystem availability already supplies the
required identity-specific evidence, while the existing marker can remain useful.
Failure to record completion after publication fails the invocation; the valid
published index can still satisfy a later availability check.

### Q05: How should synchronization identity and cursor be stored?

The selected list and detected key must accompany the last successful entry.
Legacy one-line markers cannot establish either identity and must restart.

#### BBQ for Q05

Keep the bookmark and the recipe edition together. In this picture: the bookmark
is the last completed entry and the edition is the selected list plus detected key.

#### Options for Q05

- Option A: Replace the ignored last marker with one versioned data record, written atomically.
  - Pro: Identity and cursor form one recoverable unit, avoiding mismatched sidecars.
  - Con: Existing direct writers must use the new owner, and legacy records restart.
- Option B: Retain the one-line cursor and add a separate identity sidecar with mismatch recovery.
  - Pro: Keeps the cursor readable in its current shape.
  - Con: Needs a protocol for partial updates across two files and direct legacy writes.

#### Recommended option for Q05

Option A. Store format version, detected key, selected repository-relative list
path and last successful active entry as literal data. Missing state starts;
legacy, malformed or mismatched state restarts with a diagnostic. Matching
state keeps ordinary resume behavior, without hashing list contents.

#### Answer to Q05: option A

Option A is proposed because an atomic record makes crash behavior simple:
the last entry may repeat, using existing package download and copy reuse.
An explicit `CPLX_SP_REPEAT` applies only while a valid recorded cursor is being
sought. With an empty cursor, including after an identity or stale-cursor restart,
it has no effect. Q07 covers a cursor that no longer names an active entry.
Starting a new selection or restarting after an identity or stale-cursor mismatch
writes a valid empty-cursor record so interruption cannot restore discarded state.

### Q06: Who should write progress for explicit reset commands?

The Windows launcher writes a CRLF cursor against LF lists, preventing an entry
match. It also passes that entry to the step helper, where an entry matching no
step causes fatal 10 and launcher exit 119. Adding identity would make its bare
writes legacy state too. Bash already receives the raw, unshifted `%*` words.

#### BBQ for Q06

Ask the person holding the recipe to move its bookmark. In this picture: that
person is Bash after list resolution, and moving the bookmark is CMD's reset intent.

#### Options for Q06

- Option A: Keep the operator-facing commands and forward reset intent to Bash, which writes scoped progress after list selection.
  - Pro: Restores reset semantics with one owner of selection and progress format.
  - Con: Extends the CMD-to-Bash argument contract.
- Option B: Teach CMD to resolve the selected list and write the versioned record itself.
  - Pro: Retains reset writes at the current launcher location.
  - Con: Duplicates policy and record serialization across different shells.

#### Recommended option for Q06

Option A. Explicit reset-after-entry is current operator intent and can create
a cursor for the selected identities; an old unkeyed marker cannot. Direct
single-package requests do not consume or advance full-list progress.

#### Answer to Q06: option A

Option A is proposed because Bash already owns architecture resolution and can
apply reset intent without copying that policy into CMD. CMD consumes the entry
without passing it to the step helper. Explicit forwarded intent is distinct from
the raw `%*` words. Bash uses synchronization's active-entry parsing and line-ending
normalization to compare the requested entry. Q07 governs an unknown entry.
A reset intent combined with a direct package request is rejected before any
progress change.

### Q07: What happens when a cursor matches no active entry?

The current loop skips entries until a cursor matches and can report completion
without synchronizing anything. A record bound to path and key, without content
hashing, still needs to handle an entry removed or renamed in the same list.
An explicit reset-after-entry can also contain a mistyped entry.

#### BBQ for Q07

A saved shopping bookmark may name an ingredient removed from the recipe; a new
instruction can also mistype that ingredient. In this picture: the bookmark is
stored progress, the recipe is the selected list, and the new instruction is an
explicit reset-after-entry command.

#### Options for Q07

- Option A: Restart for an absent stored cursor; fail for an unknown explicit reset entry.
  - Pro: Recovers stale progress automatically while reporting operator mistakes before synchronization.
  - Con: Requires distinguishing stored progress from fresh reset intent.
- Option B: Fail in both cases with a diagnostic before synchronization.
  - Pro: Uses one rule without automatically changing the resume position.
  - Con: A list edit requires manual recovery before setup can proceed.
- Option C: Restart in both cases with a diagnostic before synchronization.
  - Pro: Uses one recovery rule and always processes the selected list.
  - Con: A mistyped explicit entry starts more work than the operator requested.

#### Recommended option for Q07

Option A. Decide before processing the first entry. Stored progress whose cursor
is absent cannot establish a resume position, so restart and report why. An
unknown explicit entry fails with a diagnostic naming the selected list, leaving
progress unchanged. A valid explicit entry resumes after that entry.

#### Answer to Q07: option A

Option A is proposed because stale automatic state should recover without a
manual prerequisite, while fresh operator input should not be reinterpreted.
Neither case may silently skip synchronization and report completion.
