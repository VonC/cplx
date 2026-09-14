# Resolve package metadata across server minor versions

- Type: feature-request
- Version: v0.27.0
- Topic: `architecture-minor-fallback`
- Source: [focused draft](draft.v0.27.0.architecture-minor-fallback.md)
- Collection: item 5 and decision D9 of [debian-agent-tools](draft.v0.27.0.debian-agent-tools.md)

## Revision that introduces architecture fallback

The umbrella's 7 August 2026 correction established that architecture-specific
filenames are operational inputs, not cosmetic labels. The server's upgrade
from RHEL 9.6 to 9.8 changed the detected architecture key and made the existing
package metadata unreachable through the exact-name lookups.

The temporary recovery created 9.8 copies of the Python and Git dependency
lists, added the corresponding mirror property and regenerated the package
index. Decision D9 replaces this repeated copying with exact-match precedence,
then a logged fallback within the same distribution, major version and machine
architecture. The approved ordering prefers the highest lower minor, then the
lowest higher minor when no lower candidate exists. Keeping a minor-specific
override remains necessary when its package requirements differ.

Later repository evidence changes how the generated index should be considered.
Commit `18c251d`, authored on 24 August 2026, records that resolving packages
from the 2025-era 9.6 index onto the upgraded 9.8 server produced a sandbox
whose binutils needed libraries the upgraded system no longer carried. Setup
had supplied the packages without exposing that runtime inconsistency. That
commit generated a 9.8 index and corrected the Python dependency spelling.

D9 originally applied fallback to all three metadata lookups. Consolidation
approved on 14 September 2026 narrows direct fallback to curated lists and
mirror definitions and requires an index for the detected key. All eleven
reviewed answers are accepted: Q01 option D, Q06 option C and option A for the
others. These decisions also settle ordering, curated cleanup and synchronization
resume behavior. The requirement clarifications below record their rationale.

## Operator need after a RHEL minor upgrade

As the operator preparing cplx tools and their dependencies on RHEL, I want
package setup to reuse the available metadata after a minor OS upgrade, so that
I can continue dependency preparation without copying a whole file set solely
to match the new minor number. When metadata exists for the exact release, I
want that definition to remain authoritative.

The detected server identity must remain accurate, and the output must identify
any substituted metadata. Finding an older list must not disguise which server
is being prepared.

## Current architecture lookup behavior before this v0.27.0 change

`setup.sh` obtains the distribution ID, version and machine from the remote
server and writes the resulting architecture into the properties on every
connection validation. For the current server this is `rhel_9.8_x86_64`.
Manually restoring an older property value does not provide a durable recovery.

The requested change covers three metadata lookups:

| Metadata | Current exact lookup for RHEL 9.8 | Consequence when absent |
| --- | --- | --- |
| Per-tool dependency list | `pkgs/<tool>/<tool>_rhel_9.8_x86_64.txt` | Synchronization stops with fatal 9 before the remote copy. The later copy as `dependencies.list` would fail with fatal 902 if its source were missing. |
| Package index | `pkgs/packages_rhel_9.8_x86_64.txt` | Lookup creates an empty exact-name file, then fails to resolve the package with fatal 301. Generation is skipped when its completion marker is already set, regardless of the architecture for which it was completed. |
| Mirror URL property | `rhel_9_8_x86_64_pkgs_url` | The property reader treats a missing key and an empty value alike. Generation then reports fatal 112, while download reports fatal 7 for the missing property. |

The Git dependency lists for 9.6 and 9.8 are byte-identical, and their mirror
values in `setup.tpl.properties` are identical rolling CentOS 9 Stream and
supplementary mirror definitions. The Python lists differ: 9.6 contains
`zlib-dev`, while 9.8 contains the `zlib-devel` correction from `18c251d`.
Only `zlib-devel` resolves in either generated index. The generated 9.6 and 9.8
indexes also differ; they are snapshots, not duplicate curated lists.

Consequently, using the real 9.6 Python list unchanged would fail at its third
entry regardless of filename fallback. Cleanup requires the targeted
curated-list correction in Q10 before the real-host fallback scenario can pass.

The `download_packages_list` marker records completion without an architecture.
Only `CPLX_FORCE_RELOAD_PACKAGES` currently bypasses that early return, so even
the ordinary reload flag cannot reliably request regeneration after completion.
An empty exact-name index left by lookup must not prevent later recovery.

Synchronization resumes after the entry recorded in the local, ignored
`pkgs/<tool>/last`, which records neither architecture nor list file. When it
holds a list's final active entry, the next synchronization processes nothing,
and remote installation resolves names against RPMs staged by earlier runs,
selecting the highest available version. The current local Python marker holds
`sqlite-devel`, the final active entry. Regenerating an index alone therefore
does not establish that synchronization used it.

The single-package `--package` path calls synchronization and installation
directly, bypassing the regular flow's package-index generation step. It needs
the same index availability rules before a package lookup.

The failure affects dependency preparation. It does not by itself invalidate
an installed tools tree or change installation of an existing archive.

## Architecture selection after consolidation of D9

These confirmed rules preserve exact overrides while distinguishing curated
definitions from generated snapshots.

1. For a per-tool list or mirror definition, try the exact architecture key
  first. Otherwise prefer the highest eligible minor below the requested one;
  if none exists, choose the lowest eligible minor above it. Compare minors as
  integers within the same distribution, major version and machine.
2. Resolve the list and mirror independently. Report the requested key and
  actual selected file or property for every substitution.
3. Use the package index for the detected key. If it is missing or zero-length,
  generate it under that key from the mirror definition resolved for that key,
  regardless of an earlier completion marker. Do not reuse another minor's
  generated index. A generation failure stops the operation with its diagnostic.
4. An explicit refresh through either `CPLX_RELOAD_PACKAGES` or
  `CPLX_FORCE_RELOAD_PACKAGES` regenerates under the detected key despite a
  completion marker. Generation and the corresponding downloads use the same
  resolved mirror definition. This is not an index freshness guarantee for
  later runs whose operator changes the mirror configuration without refreshing.
5. Synchronization resume state applies only to
  the selected list file and detected key it was recorded for. A different
  selection or key restarts synchronization from the first active entry and
  reports the restart. Legacy state that records neither identity cannot
  establish a match and also restarts. An unchanged file selection and detected
  key retain ordinary resume behavior.
6. A per-tool list is absent only when its file does not exist; a present list,
  including an empty or comment-only one, retains its existing semantics. An
  index is absent when missing or zero-length. A mirror definition is absent
  when the key is missing or its trimmed value is empty. Other unusable present
  inputs keep their ordinary errors rather than triggering another selection.
7. Metadata lookup must not create a placeholder file when it finds nothing.
  Deliberate index generation is a separate required setup operation, not an
  empty-file side effect of lookup. Diagnose missing mirror configuration before
  fetching, naming the requested key, metadata kind, eligibility boundary and
  considered candidates, or stating that none was eligible.
8. Preserve the detected server architecture. Keep existing exact lookup for
  keys such as `centos_8_x86_64`, but permit minor fallback only between numeric
  major.minor versions. Major-only and major.minor keys are not mutual fallback
  candidates. Distribution and machine must match as whole components.
9. Correct `zlib-dev` to `zlib-devel` in the 9.6
  Python list, then remove the now-identical 9.8 Python and Git lists and the
  9.8 mirror key from the tracked template. Generated indexes and operators'
  ignored local properties are outside that removal. Retain differing exact
  definitions and support adding them later. Confirm equivalence and demonstrate
  the accepted setup behavior before removing redundant curated definitions.
10. Keep the selected metadata authoritative after package lookup or download
  failure. Preserve ordered retries across URLs in the selected mirror definition
  and the fatal result on final URL failure. Do not select another minor because
  a package is absent or a download fails.

Copying every file set remains the workaround being replaced. Major-only
naming remains rejected because it would remove exact-minor overrides. The
approved index rule eliminates manual copying after an upgrade but requires
mirror access on the first run lacking a usable index for the detected key;
it can leave one generated index per minor. It does not promise one file of
every metadata kind per major.

## Acceptance criteria for architecture minor fallback

The criteria below express the approved answers. They define implementation
acceptance; specification review has not performed the host validation.

| ID | Scenario | Required result |
| --- | --- | --- |
| AC1 | The server reports `rhel_9.8_x86_64`; only the corrected 9.6 Python list, 9.6 Git list and 9.6 mirror definition are available, with no index for either minor. | Setup selects the lists and mirror by fallback, reports the selections, and generates `packages_rhel_9.8_x86_64.txt` without manual 9.8 copies. |
| AC2 | A usable exact 9.8 list or mirror definition exists alongside 9.6. | The exact definition wins, including when intentionally different. An existing nonempty exact index is used unless refresh is requested. |
| AC3 | Fallback candidates include another distribution, another major version or another machine architecture. | None of those definitions is eligible to satisfy the missing exact lookup. |
| AC4 | A 9.8 request has eligible curated candidates for 9.6, 9.9 and 9.10. | It selects 9.6 under the approved ordering. A 9.5 request with only 9.6 and 9.10 selects 9.6. Minor 10 is compared as an integer, never as decimal .1. |
| AC5 | A 9.8 server uses 9.6 metadata. | The stored detected architecture remains `rhel_9.8_x86_64`, and the output identifies the actual selected file or property. |
| AC6 | A selected list is synchronized or copied, or a mirror definition feeds generation and downloads. A metadata lookup also encounters an absent file. | The affected operations use the selected inputs, and generation and corresponding downloads use the same mirror resolution. Failed lookup creates no placeholder file; a later run can still recover through fallback or generation. The same applicable lookup, absence and index-generation rules hold for the single-package (`--package`) path. |
| AC7 | The Q10 correction and curated removals have been performed, with no overriding local 9.8 mirror key in the acceptance environment. The host retains synchronization resume state from its pre-upgrade runs. | The RHEL 9.8 host completes dependency setup for Python and Git, reports list and mirror fallback, and resolves `zlib-devel`. It reports the synchronization restart and synchronizes every active Python and Git entry through the selected lists and generated 9.8 index, retaining existing download and copy reuse for the selected packages. Generated indexes remain outside curated cleanup; distinct exact overrides remain supported. |
| AC8 | The architecture fallback is delivered. | The architecture explanation, OS-upgrade procedure and package-list reference describe the new selection behavior and replace copying as the routine minor-upgrade recovery. |
| AC9 | The exact mirror value is empty, the exact index is zero-length, or a present per-tool list contains only comments. | An empty mirror permits fallback; an empty index requires generation. The present per-tool list remains authoritative. An unreadable or otherwise invalid present input is not silently bypassed. |
| AC10 | A 9.6 index exists, no usable 9.8 index exists, and generation is already marked complete, including when the operation is single-package setup. | A 9.8 server generates and uses a 9.8 index from its resolved mirrors, never the 9.6 snapshot. Generation failure remains a failure. Either explicit reload flag also forces regeneration despite the marker. |
| AC11 | No eligible list or mirror exists, or a requested/candidate version has no numeric minor. | Missing required inputs produce an actionable unsuccessful result before the affected operation. Existing exact major-only lookups remain supported; fallback never bridges major-only and major.minor keys. |
| AC12 | Resume state was recorded for `python_rhel_9.8_x86_64.txt` and selection changes to `python_rhel_9.6_x86_64.txt`, or the detected key changes, or legacy resume state lacks those identities. | Synchronization restarts from the first active entry and reports it. State recorded for the same selected file and detected key still resumes after the recorded entry. |

Acceptance must distinguish the detected architecture from the metadata selected
for it. A successful lookup is not evidence that the eventual tools archive
contains every required runtime library or works on both deployment platforms.

## Relationship to runtime closure and the following umbrella items

Item 4 is complete and integrated. It prepares and checks the tools runtime
payload during packaging and binds subsequent verification to the archive's
actual bytes. Item 5 improves the upstream selection of dependency inputs.
There is no technical dependency on item 4's checker, and fallback does not
replace its runtime checks.

```text
Item 5: select package metadata for the detected RHEL server
  -> prepare tools and dependencies on RHEL
  -> Item 4: check the tools runtime payload during packaging
  -> deploy the tools archive on RHEL and consume it on Debian
```

Item 6 needs working architecture resolution for its SQLite dependency setup
on RHEL 9.8. It owns Python's SQLite integration, its rebuild and removal of
the remaining SQLite waiver. Item 7 owns the final tools refresh, rebuild,
cross-platform validation and release delivery. Those activities are outside
this requirement's implementation scope.

The umbrella and focused draft now reflect the confirmed D9 refinement: fatal 9
can precede the copy's fatal 902, generated indexes do not fall back, and cleanup
removes only confirmed equivalent curated definitions. The resulting inventory
may include different exact overrides and one generated index per minor.

New-tool creation currently seeds only hard-coded CentOS 8 and RHEL 7.9 lists;
it does not read the detected key and supplies no RHEL 9 seed. That is a
separate pre-existing gap, recorded as a follow-up rather than added here.
The local `pkgs/<arch>/` download cache remains keyed by the detected
architecture, and the remote `tools/pkgs/` remains unkeyed.

## RHEL and Jenkins responsibilities for this feature

| Environment | Responsibility |
| --- | --- |
| RHEL development and packaging account | Prepare cplx tools and dependencies, package tools with `pkg_tools`, and package the private application through its packaging command. Architecture fallback belongs to this dependency-setup path. |
| RHEL deployment accounts | Deploy tools and application archives through the application's `tools/deploy_pkgs.sh` and run the application. Existing archive deployment is not an architecture-metadata selection operation. |
| Jenkins Debian Docker container | Fetch and deploy an existing tools archive, check out the private application from source, provision application dependencies and run tests. The application job packages and publishes only the application archive to Nexus. It does not compile, build tools or publish tools. |

Validation for this feature must exercise the affected setup lookups and
preserve existing exact-key behavior. Compiler availability or compilation on
the Debian agent is not an acceptance condition. Jenkins can provide relevant
integration verification using the available credentials in `%HOME%\_netrc`
or `%USERPROFILE%\_netrc`; local Maven use must select 3.9.9 from
`%PRGS%\mavens` when needed. These are execution facilities, not a requirement
to run an unrelated pipeline for metadata selection.

## Code and documentation references for architecture resolution

- [setup.sh](../../src/setups/setup.sh): connection validation detects and stores
  the remote architecture.
- [setup_packages.sh](../../src/setups/setup_packages.sh): per-tool list
  synchronization and remote copy, package-index generation and lookup, and
  mirror-property consumption for generation and downloads. Lines 209-247
  contain the unkeyed synchronization resume logic; lines 30-34 select the
  direct single-package path.
- [packages_management.sh](../../src/setups/env/bin/packages_management.sh):
  lines 356-386 resolve short package names against staged RPMs, selecting the
  highest version rather than consulting the generated index.
- [steps.md](../../src/setups/steps.md): the architecture-independent package
  generation completion marker.
- [properties.sh](../../src/utils/properties.sh): missing and empty property
  values both return an unsuccessful read with an empty value.
- [setup.tpl.properties](../../src/setups/setup.tpl.properties): tracked mirror
  definitions and the per-minor-key comment to update under AC8.
- [add_tool.bat](../../tools/add_tool.bat): fixed CentOS 8 and RHEL 7.9 seed
  creation, with no detected-key lookup or RHEL 9 seed.
- [The architecture key](../../wiki/explanation/the-architecture-key.md):
  server identity, minor-specific names and the D9 fallback direction.
- [Survive a server OS upgrade](../../wiki/how-to/survive-a-server-os-upgrade.md):
  the current copy-and-regenerate recovery that this feature supersedes.
- [Package list formats](../../wiki/reference/package-list-formats.md):
  metadata paths, naming conventions and generated-index ownership.
- [Item 4 validation](plan.v0.27.0.toolchain-runtime-closure.validation.md):
  the completed runtime-closure protection that remains downstream of setup.

## Requirement clarifications

Human consolidation approved all eleven answers after review round 3. These
clarifications settle the requirement; no further requirement question is needed
to start the design.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | D: exact first, then highest lower minor, otherwise lowest higher minor; integer ordering prefers prior metadata during upgrades and still supports older servers. | [Selection](#architecture-selection-after-consolidation-of-d9), AC4 | Absolute distance can prefer a newer definition; lower-only rejects older servers; refusing ties adds intervention. |
| Q02 | A: select list and mirror independently; pair generation and corresponding downloads with the same mirror resolution, retaining independent exact overrides. | [Selection](#architecture-selection-after-consolidation-of-d9), AC6 | Requiring every label to match would recreate duplicate curated definitions. |
| Q03 | A: fail before the affected copy or fetch with the requested key, metadata kind, eligibility boundary and candidates, so missing preparation is explicit. | [Selection](#architecture-selection-after-consolidation-of-d9), AC11 | Warning and skipping can leave dependencies unprepared behind a successful-looking result. |
| Q04 | A: absence means nonexistent list, missing or zero-length index, or missing or trimmed-empty mirror value. Other present inputs keep ordinary semantics and errors; lookup creates no placeholder. | [Selection](#architecture-selection-after-consolidation-of-d9), AC6, AC9 | Treating every unusable input as absent hides broken overrides; treating empty indexes and mirror values as usable blocks recovery. |
| Q05 | A: preserve exact lookup for existing keys; fallback requires numeric major.minor and matching whole distribution and machine components. | [Selection](#architecture-selection-after-consolidation-of-d9), AC3, AC11 | Treating major-only as minor zero invents equivalence. |
| Q06 | C: use only the detected key's index; generate when missing or zero-length and on either explicit reload flag despite completion state. This prevents reuse of the documented incompatible older snapshot. | [Lookup evidence](#current-architecture-lookup-behavior-before-this-v0270-change), [Selection](#architecture-selection-after-consolidation-of-d9), AC2, AC10 | Reusing another minor's index risks the recorded incident; refreshing it under the fallback key also changes another minor's shared input. Mirror access and separate generated indexes are accepted costs. |
| Q07 | A: remove only proven equivalent curated definitions after accepted setup is demonstrated; preserve distinct overrides, generated indexes and ignored operator properties. | [Selection](#architecture-selection-after-consolidation-of-d9), AC7 | Removing every 9.8 artifact would discard corrections and distinct generated data. |
| Q08 | A: record missing RHEL 9 new-tool seeds as a separate pre-existing gap; keep the detected-key local cache and unkeyed remote staging directory. | [Scope boundary](#relationship-to-runtime-closure-and-the-following-umbrella-items) | Adding seed support expands the focused existing-tool operation into a separate feature. |
| Q09 | A: preserve ordinary package errors and ordered URL retries, with final failure fatal; a retrieval failure never selects another minor. | [Selection](#architecture-selection-after-consolidation-of-d9) | Trying more distant metadata after failure hides defects and makes selection depend on transient network conditions. |
| Q10 | A: correct the 9.6 Python list to `zlib-devel`, then remove equivalent 9.8 Python/Git lists and the tracked 9.8 mirror key; retain indexes. This makes real-host fallback executable. | [Selection](#architecture-selection-after-consolidation-of-d9), AC1, AC7 | Keeping only 9.8 would make the current host exact-only; retaining every list leaves duplicates and the 9.6 typo. |
| Q11 | A: resume only for the same selected list file and detected key; changed or legacy unkeyed state restarts and reports it. Download and copy reuse remain available for selected packages. | [Selection](#architecture-selection-after-consolidation-of-d9), AC7, AC12 | Requiring manual resets or deferring the problem can suppress synchronization and invalidate real-host evidence. |
