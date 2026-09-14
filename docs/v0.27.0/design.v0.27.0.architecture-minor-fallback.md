# Design v0.27.0: architecture minor fallback

Reference requirement:
[architecture-minor-fallback](feature-request.v0.27.0.architecture-minor-fallback.md)

Umbrella: [debian-agent-tools](draft.v0.27.0.debian-agent-tools.md), item 5 and D9.

## Context for the v0.27.0 metadata resolver

The requirement is consolidated in `a5a974f`. Its eleven clarifications fix the
selection policy, index identity, cleanup boundary and synchronization behavior.
This design records the architecture approved after design review round 2.
All seven answers were confirmed as option A, including the covered cursor,
repeat and reset clarifications. Requirement decisions remain the fixed inputs.

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

The architecture has one pure selection policy with two adapters:
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

The context is owned by the current Bash invocation. It holds the
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

The availability guard checks the exact file and both reload flags
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

The progress record is one versioned, literal-data record at the
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

The current CMD reset command must stop writing a bare cursor. The approved
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

## Design decisions

All decisions below were approved for consolidation after review round 2.
No further design question is needed before implementation planning.

| Question | Decision and reason | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | A: One pure selector with list and mirror adapters keeps ordering consistent while retaining per-kind absence rules. Each mirror key uses its first definition only; an empty first value is absent. | [Resolver contract](#resolver-structure-and-result-contract) | Independent consumer selectors duplicate policy and risk divergence. |
| Q02 | A: Carry selected inputs in one invocation context and resolve mirrors lazily, preserving pairing and cached offline reuse. | [Invocation context](#invocation-context-for-consistent-metadata-consumption) | Resolving at each consumer adds comparison and can abort after configuration edits. |
| Q03 | A: Assemble a nonempty index in an ignored temporary sibling, then replace the exact file. Assembly or replacement failure preserves the old file but fails the invocation. | [Index lifecycle](#index-lifecycle-and-checkpoint-authority) | In-place generation with a durable marker requires a second validity protocol honored by every reader. |
| Q04 | A: Exact-file availability and either reload flag govern index preparation; step completion remains reporting. Completion-record failure is fatal after valid publication. | [Checkpoint authority](#index-lifecycle-and-checkpoint-authority) | Per-architecture completion records add redundant state and migration. |
| Q05 | A: One atomic versioned data record carries list path, detected key and cursor. Restarts write an empty cursor durably; repeat intent applies only while seeking a valid cursor. | [Synchronization progress](#synchronization-progress-and-reset-compatibility) | A cursor plus identity sidecar needs partial-update recovery across two files. |
| Q06 | A: CMD consumes reset input and forwards distinct intent to Bash, which validates normalized entries and writes scoped progress. Reject reset with a direct package request before progress changes. | [Reset compatibility](#synchronization-progress-and-reset-compatibility) | CMD selection and record writes duplicate policy and serialization across shells. |
| Q07 | A: Restart automatically for a stored cursor absent from the selected list; fail an unknown explicit reset entry before synchronization, preserving progress. | [Cursor validation](#synchronization-progress-and-reset-compatibility) | Failing both cases requires manual recovery after list edits; restarting both cases reinterprets mistyped operator input. |
