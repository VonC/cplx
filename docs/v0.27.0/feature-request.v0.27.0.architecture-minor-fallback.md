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
then a logged fallback to the closest available minor of the same distribution,
major version and machine architecture. Keeping a minor-specific override
remains necessary when its package requirements differ.

Later repository evidence changes how the generated index should be considered.
Commit `18c251d`, authored on 24 August 2026, records that resolving packages
from the 2025-era 9.6 index onto the upgraded 9.8 server produced a sandbox
whose binutils needed libraries the upgraded system no longer carried. Setup
had supplied the packages without exposing that runtime inconsistency. That
commit generated a 9.8 index and corrected the Python dependency spelling.

D9 originally applies fallback to all three metadata lookups. The reviewed
proposal below narrows direct fallback to curated lists and mirror definitions,
and generates the package index for the detected key. This is a proposed D9
application decision, not a previously confirmed rule. Q06 presents the
alternatives for explicit human decision at consolidation; Q01 also proposes
an ordering refinement, Q10 proposes the surviving curated file set, and Q11
proposes how synchronization resumes when the selected inputs change.

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
entry regardless of filename fallback. The proposed cleanup needs the targeted
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

## Proposed architecture selection for the D9 application decision

These expected results reflect the proposed answers, pending human approval.
They preserve exact overrides while distinguishing curated definitions from
generated snapshots.

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
5. Under Q11's proposed answer, synchronization resume state applies only to
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
9. Under Q10's proposed cleanup, correct `zlib-dev` to `zlib-devel` in the 9.6
  Python list, then remove the now-identical 9.8 Python and Git lists and the
  9.8 mirror key from the tracked template. Generated indexes and operators'
  ignored local properties are outside that removal. Retain differing exact
  definitions and support adding them later.

Copying every file set remains the workaround being replaced. Major-only
naming remains rejected because it would remove exact-minor overrides. The
proposed index rule eliminates manual copying after an upgrade but requires
mirror access on the first run lacking a usable index for the detected key;
it can leave one generated index per minor. It does not promise one file of
every metadata kind per major.

## Acceptance criteria for architecture minor fallback

The criteria below align with the proposed Q01, Q06, Q10 and Q11 answers and must
be consolidated with the human's decisions before implementation.

| ID | Scenario | Required result |
| --- | --- | --- |
| AC1 | The server reports `rhel_9.8_x86_64`; only the corrected 9.6 Python list, 9.6 Git list and 9.6 mirror definition are available, with no index for either minor. | Setup selects the lists and mirror by fallback, reports the selections, and generates `packages_rhel_9.8_x86_64.txt` without manual 9.8 copies. |
| AC2 | A usable exact 9.8 list or mirror definition exists alongside 9.6. | The exact definition wins, including when intentionally different. An existing nonempty exact index is used unless refresh is requested. |
| AC3 | Fallback candidates include another distribution, another major version or another machine architecture. | None of those definitions is eligible to satisfy the missing exact lookup. |
| AC4 | A 9.8 request has eligible curated candidates for 9.6, 9.9 and 9.10. | It selects 9.6 under the proposed ordering. A 9.5 request with only 9.6 and 9.10 selects 9.6. Minor 10 is compared as an integer, never as decimal .1. |
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

The pending consolidation must reconcile the umbrella's inherited wording
about fatal 902 and leaving one file per major, and, if Q06 option C is chosen,
its statement that the generated index itself falls back. Neither the umbrella
nor focused draft is changed during this review round.

New-tool creation currently seeds only hard-coded CentOS 8 and RHEL 7.9 lists;
it does not read the detected key and supplies no RHEL 9 seed. That is a
separate pre-existing gap, recorded as a follow-up rather than added here.
The local `pkgs/<arch>/` download cache remains keyed by the detected
architecture, and the remote `tools/pkgs/` remains unkeyed.

## RHEL and Jenkins responsibilities for this feature

| Environment | Responsibility |
| --- | --- |
| RHEL development and packaging account | Prepare cplx tools and dependencies, package tools with `pkg_tools`, and package the private my-project application with `pkg_application`. Architecture fallback belongs to this dependency-setup path. |
| RHEL deployment accounts | Deploy tools and application archives through my-project's `tools/deploy_pkgs.sh` and run the application. Existing archive deployment is not an architecture-metadata selection operation. |
| Jenkins Debian Docker container | Fetch and deploy an existing tools archive, check out my-project from source, provision application dependencies and run tests. The application job packages and publishes `application` only to Nexus. It does not compile, build tools or publish tools. |

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

## Open questions for the v0.27.0 architecture-minor-fallback feature request

The answer lines are proposals for human consolidation, not recorded user
decisions. Q01 refines closest-minor ordering; Q06 changes D9's direct fallback
scope for the generated index; Q10 chooses the surviving curated definitions;
Q11 proposes when synchronization resume state remains applicable.

### Q01: Which ordering should closest minor use?

D9 confirms exact precedence and closest-minor fallback, but does not define whether an older candidate should take priority over a numerically closer newer one. For a 9.8 request, candidates 9.6, 9.9 and 9.10 make that distinction observable.

#### BBQ for Q01

A recipe revision introduced after your kitchen's equipment changed may assume equipment you do not yet have. In this picture: the kitchen equipment is the server release, and the recipe revisions are eligible metadata minors.

#### Options for Q01

- Option A: Choose the smallest absolute integer distance, preferring the lower minor on a tie.
  - Pro: Gives closest its ordinary numeric meaning and a deterministic tie rule.
  - Con: Can prefer a newer release's divergent requirements over an available older definition.
- Option B: Choose the highest lower minor and refuse fallback when none exists.
  - Pro: Never selects a newer definition.
  - Con: Refuses a server older than all available metadata.
- Option C: Choose by absolute integer distance, but refuse ties.
  - Pro: Makes equally near choices explicit.
  - Con: A tie restores manual intervention even when both candidates are eligible.
- Option D: Choose the highest eligible minor below the requested one; if none exists, choose the lowest eligible minor above it.
  - Pro: Prefers the prior release definition while still resolving servers older than all available definitions; needs no tie rule.
  - Con: A closer newer minor loses to an older one, so this refines the ordinary numeric reading of D9's closest wording.

#### Recommended option for Q01

Option D. Prefer the prior minor's definition during an upgrade, while retaining an upward fallback when there is no older candidate. A 9.8 request selects 9.6 over 9.9 and 9.10; a 9.5 request with only 9.6 and 9.10 selects 9.6. Compare minors as integers, never decimal fractions.

#### Answer to Q01: option D

Option D is proposed as an explicit ordering decision for human consolidation. It stays within the confirmed distribution, major and machine boundaries, but its preference over absolute distance must be accepted knowingly.

### Q02: How should selections from different metadata minors interact?

A tool list may exist for 9.8 while the closest eligible mirror definition is 9.6. An index contains exact package filenames that must be downloaded from the mirrors associated with that index. The acceptable combination depends on Q06.

#### BBQ for Q02

A recipe can come from one edition, but the ingredient catalogue and supplier directory must describe the same supplies. In this picture: the recipe is the per-tool list, the catalogue is the index, and the directory is the resolved mirror definition.

#### Options for Q02

- Option A: Allow list and mirror selection to resolve independently, while pairing index generation and corresponding downloads with the same resolved mirror definition.
  - Pro: Preserves exact overrides and permits partially updated curated metadata.
  - Con: Does not itself prove that every dependency listed exists in those mirrors.
- Option B: Refuse setup unless the list, index and mirror definitions all carry the same minor label.
  - Pro: Avoids combinations of differently labelled metadata.
  - Con: Reintroduces duplicate definitions even when their contents and mirrors are equivalent.

#### Recommended option for Q02

Option A, with Q06 option C. The index is generated for the detected key using that key's resolved mirror definition, and corresponding downloads use that same resolution. The per-tool list can independently select an exact or fallback definition. Log the chosen identities.

#### Answer to Q02: option A

Option A is proposed because exact overrides should remain useful independently. If the human instead chooses cross-minor index reuse in Q06, a package resolved from a fallback index must be downloaded using the mirror definition resolved for that index's key; that alternative pairing must be reflected in acceptance.

### Q03: What should happen when no eligible definition exists?

A missing per-tool list or mirror definition may have no candidate within the allowed distribution, major and machine. An absent generated index is handled through Q06; its missing mirror input must still be diagnosed.

#### BBQ for Q03

If there is no recipe or supplier directory, the cook needs to know which input is missing before placing an order. In this picture: those inputs are the list and mirror definition, and the order is the affected setup operation.

#### Options for Q03

- Option A: Fail the affected operation with an actionable metadata diagnostic before the affected copy or fetch.
  - Pro: Makes unattended failure explicit and identifies what the operator must supply.
  - Con: A new distribution or major still requires metadata preparation.
- Option B: Warn and skip the unresolved dependency operation.
  - Pro: Allows unrelated work to continue.
  - Con: Can leave a tool unprepared despite a successful-looking invocation.

#### Recommended option for Q03

Option A. Name the requested key, metadata kind, eligibility boundary and considered candidates, or state that none was eligible. Missing mirror configuration must be reported before fetching, rather than as a later failure to find packages at the URLs.

#### Answer to Q03: option A

Option A is proposed because fallback must not silently omit dependencies or cross a forbidden boundary. Exact diagnostic codes are a later design concern; an unsuccessful result and the stated diagnostic content are acceptance requirements.

### Q04: What counts as absence for each metadata kind?

The index lookup currently creates an empty exact-name file when it finds nothing, while the generator has no successful empty-index result. The property reader already treats missing keys and empty trimmed values alike. A present empty or comment-only per-tool list can retain its existing meaning.

#### BBQ for Q04

A missing recipe, an empty catalogue and a blank supplier address need different treatment. In this picture: the recipe is a curated list, the catalogue is a generated index, and the address is the mirror property value.

#### Options for Q04

- Option A: Define absence per metadata kind and otherwise keep exact definitions authoritative.
  - Pro: Matches the property contract and prevents empty placeholder indexes from blocking recovery.
  - Con: Requires distinct absence rules for the three metadata kinds.
- Option B: Treat every unusable exact definition as absent and try another minor.
  - Pro: Can recover from more damaged inputs.
  - Con: Can conceal a broken or intentionally distinct exact override.
- Option C: Treat any existing file or property key as present regardless of content.
  - Pro: Gives presence one simple definition.
  - Con: An empty property or lookup-created empty index can permanently defeat recovery.

#### Recommended option for Q04

Option A. A per-tool list is absent only when its file does not exist. An index is absent when missing or zero-length. A mirror definition is absent when its key is missing or its trimmed value is empty. Other unreadable or invalid present inputs retain ordinary failure behavior; no new content-validation policy is introduced.

#### Answer to Q04: option A

Option A is proposed because it follows the existing property semantics and the meaning of generated indexes. A present empty or comment-only list stays authoritative. Lookup must not create placeholder metadata as a side effect of absence; Q06's deliberate index generation is a separate required behavior.

### Q05: How should versions without a numeric minor behave?

Existing keys include `centos_8_x86_64` as well as `rhel_7.9_x86_64`. A major-only key has no minor to rank, and the machine component `x86_64` itself contains an underscore.

#### BBQ for Q05

A main recipe edition does not identify a numbered revision, and the kitchen's full equipment label must still match. In this picture: the edition and revision are the OS major and minor, and the equipment label is the complete machine architecture.

#### Options for Q05

- Option A: Preserve exact lookup for supported keys, and permit minor fallback only between numeric major.minor versions.
  - Pro: Preserves existing major-only behavior without inventing a minor value.
  - Con: Other version forms receive no new fallback behavior.
- Option B: Treat a major-only version as minor zero.
  - Pro: Gives those keys a position in numeric ranking.
  - Con: Assumes equivalence between major-only and .0 metadata that the documents do not establish.

#### Recommended option for Q05

Option A. A major-only candidate is ineligible for a major.minor request, and a major.minor candidate is ineligible for a major-only request. Distribution and machine compare as whole components, so prefix or suffix matches cannot determine eligibility.

#### Answer to Q05: option A

Option A is proposed because it limits the new behavior to minor upgrades while preserving existing exact lookups. A missing exact definition outside the supported fallback form needs a clear diagnostic, not an invented identity.

### Q06: Should generated package indexes use cross-minor fallback?

Commit `18c251d`, authored on 24 August 2026, records that using the 2025-era 9.6 index on the 9.8 server supplied a binutils whose libraries the upgraded system no longer carried. The generated indexes differ. In addition, an architecture-independent completion marker currently skips generation, and lookup can leave an empty exact-name index. These facts make index reuse a separate D9 application decision.

#### BBQ for Q06

Reusing an old recipe can be reasonable, but its dated supplier catalogue may list supplies that no longer fit the kitchen. In this picture: the recipe is curated dependency metadata, the catalogue is a generated index snapshot, and the kitchen is the upgraded server.

#### Options for Q06

- Option A: Reuse an eligible cross-minor index for normal reads; generate under the detected key when no index exists or refresh is explicit.
  - Pro: Avoids a fetch when an older index is present and retains D9's original three-lookup fallback.
  - Con: Can recreate the documented old-snapshot incident; reuse needs the index's own resolved mirrors and prominent source reporting.
- Option B: Reuse and refresh the selected fallback index under its existing key and mirrors; generate under the detected key only if no index exists.
  - Pro: Keeps fewer generated index files.
  - Con: Changes shared input for another minor and still makes the older snapshot usable before refresh.
- Option C: Never reuse another minor's index. Generate a missing or zero-length exact index under the detected key using the mirrors resolved for that key, regardless of an earlier completion marker.
  - Pro: Automatically refreshes the index when an upgrade has no exact snapshot and keeps generation and corresponding downloads paired.
  - Con: Narrows D9's original application, requires mirror access on that first run, and can retain one generated index per minor.

#### Recommended option for Q06

Option C. Both explicit reload flags must also regenerate under the detected key despite a completion marker; generation failure must stop setup. Existing nonempty exact indexes retain ordinary reuse behavior unless refresh is requested. This prevents the documented incident from recurring through cross-minor fallback, without claiming that all exact indexes remain fresh forever.

#### Answer to Q06: option C

Option C is proposed for explicit human decision because it changes one of the three lookups D9 names. Fallback remains for curated lists and mirror definitions; the index is generated for the detected key. If A is chosen instead, retain the incident evidence, prominently report the selected index key, pair downloads with mirrors resolved for that index's key, and still address the completion marker and empty-file behavior.

### Q07: Which existing 9.8 definitions are actually removable?

Repository comparison finds identical Git lists and tracked mirror values, but the Python lists differ by `zlib-dev` versus `zlib-devel` and the generated indexes have different contents. Identical mirror URLs are not proof of identical metadata.

#### BBQ for Q07

Two folders with similar covers may contain different recipes or catalogues. In this picture: the folders are minor-specific definitions, and their contents are dependency entries, mirror values or generated package filenames.

#### Options for Q07

- Option A: Remove only confirmed equivalent curated definitions after the accepted setup behavior is demonstrated; retain differing definitions for an explicit decision.
  - Pro: Protects exact overrides and exposes the Python correction required by Q10.
  - Con: May leave more files than the umbrella's one-file-per-major shorthand suggests.
- Option B: Remove all 9.8 metadata after any common fallback scenario passes.
  - Pro: Immediately reduces the inventory.
  - Con: Can discard the Python correction and distinct generated package data.

#### Recommended option for Q07

Option A. The 9.8 Git list and template mirror value are equal to 9.6 and eligible for removal. The Python list is not removable until Q10 resolves its correction. The different generated indexes remain outside curated cleanup. Ignored local `setup.properties` files belong to operators and are not cleanup targets; an identical local exact mirror key may harmlessly remain.

#### Answer to Q07: option A

Option A is proposed because it applies the deletion rule to actual evidence. Q10 defines the curated survivors. Generated indexes must not be hand-edited to manufacture equivalence, and acceptance that specifically demonstrates mirror fallback must use a configuration without an exact local override.

### Q08: Should this item add RHEL 9 seed support for new tools?

`tools/add_tool.bat` does not read the detected architecture. It seeds only hard-coded CentOS 8 and RHEL 7.9 lists, and no RHEL 9 minimal seed exists. A new tool therefore has no RHEL 9 list with or without this fallback.

#### BBQ for Q08

Reusing established recipes does not provide a starter recipe that was never supplied. In this picture: established recipes are existing per-tool lists, and the absent starter recipe is new-tool RHEL 9 seed support.

#### Options for Q08

- Option A: Keep new-tool seed support outside this item and record the pre-existing RHEL 9 gap as a follow-up.
  - Pro: Matches the three named metadata kinds and the existing-tool setup need.
  - Con: New-tool creation continues to require separate RHEL 9 preparation.
- Option B: Add RHEL 9 seed support to this requirement.
  - Pro: Improves new-tool creation at the same time.
  - Con: Adds a separate user operation and acceptance obligation beyond the focused draft.

#### Recommended option for Q08

Option A. Fallback cannot change an operation that never looks up the detected key. Cover existing uses of the named setup metadata, including direct package setup and generation, and record the seed gap separately.

#### Answer to Q08: option A

Option A is proposed to preserve the focused scope. Downloaded-package directories and archive suffixes are not additional fallback lookups: the local `pkgs/<arch>/` cache stays keyed by the detected architecture, and remote `tools/pkgs/` remains unkeyed.

### Q09: Should a package or download failure trigger another minor selection?

A selected list may request a package absent from the chosen index, or selected mirrors may no longer serve its filename. Successful metadata selection does not guarantee successful package retrieval.

#### BBQ for Q09

Finding a catalogue does not guarantee that a listed ingredient is still in stock. In this picture: the catalogue is the selected index, the ingredient is the package, and stock availability is its mirror download result.

#### Options for Q09

- Option A: Keep selected metadata authoritative and retain normal package lookup and ordered retries across URLs in the selected mirror definition, with the last URL failure fatal.
  - Pro: Preserves real package failures as actionable diagnostics.
  - Con: May require the operator to refresh or correct metadata.
- Option B: Try successively more distant eligible metadata after a content or download failure.
  - Pro: May recover when another definition happens to work.
  - Con: Makes selection depend on content or transient network conditions and can bypass an exact override.

#### Recommended option for Q09

Option A. D9 addresses missing architecture definitions, not a new package solver. Preserve the existing retries among configured URLs, but do not switch architecture metadata after package or network failure.

#### Answer to Q09: option A

Option A is proposed because metadata resolution and package retrieval are distinct acceptance results. Failure in retrieval must not silently revise the selected exact or fallback definition.

### Q10: Which curated file set should survive cleanup?

The 9.6 Python list contains `zlib-dev`, which resolves in neither generated index. The 9.8 list corrects it to `zlib-devel`. Without deciding how to retain that correction, the real 9.8-to-9.6 acceptance scenario fails at the third dependency regardless of the resolver.

#### BBQ for Q10

Before discarding duplicate recipe cards, retain the corrected ingredient name on the card that stays. In this picture: the cards are the 9.6 and 9.8 Python lists, and the ingredient correction is `zlib-dev` to `zlib-devel`.

#### Options for Q10

- Option A: Correct the 9.6 Python list, then remove the now-identical 9.8 Python and Git lists and the 9.8 mirror key from the tracked template; retain generated indexes.
  - Pro: Keeps the stated 9.8-to-9.6 scenario executable on the real host and preserves the corrected dependency.
  - Con: The retained curated files carry an older minor label.
- Option B: Keep the corrected 9.8 curated set and remove the superseded 9.6 set.
  - Pro: Retains the newer label and correct content.
  - Con: The current 9.8 host uses exact definitions, so fallback requires a different request scenario; 9.6 hosts need upward selection.
- Option C: Remove no curated definitions in this item.
  - Pro: Avoids deletions.
  - Con: Leaves the duplicate-maintenance problem and the old Python typo unresolved.

#### Recommended option for Q10

Option A. Correct only the curated dependency spelling, then confirm equivalence before removing the redundant curated definitions. The 9.8 host must complete Python and Git dependency setup using the retained definitions, with `zlib-devel` resolved. Q06 governs generated indexes separately.

#### Answer to Q10: option A

Option A is proposed because it preserves the umbrella's real-host list and mirror fallback scenario and fixes the defect that would otherwise invalidate it. This is proposed implementation scope, not work performed during specification review; local operator properties and generated indexes are excluded from cleanup.

### Q11: Does synchronization resume state apply across a changed list selection?

Synchronization resumes after the entry recorded in the ignored local `pkgs/<tool>/last`, which records neither the selected list file nor the detected server key. The current Python marker holds the final active entry, so another run processes no package before remote installation resolves names against previously staged RPMs. A new index alone therefore does not prove that the selected metadata fed synchronization.

#### BBQ for Q11

A bookmark saying "last ingredient packed" cannot safely continue a different recipe's shopping trip in another kitchen. In this picture: the bookmark is synchronization resume state, the recipe is the selected dependency-list file, and the kitchen is the detected server key.

#### Options for Q11

- Option A: Honor resume state only for the selected list file and detected key it was recorded against; otherwise restart from the first active entry and report the restart.
  - Pro: Makes setup after a minor upgrade or changed selection actually synchronize against its selected inputs, even when earlier runs reached the old list's final entry.
  - Con: Extends the change into resume behavior and restarts an interrupted run when the selection or detected key changes, or legacy state cannot establish their identity.
- Option B: Keep unkeyed resume state and require the OS-upgrade procedure and real-host acceptance to clear it explicitly.
  - Pro: Keeps implementation scope limited to metadata selection and index availability.
  - Con: Leaves a manual state-reset prerequisite on the upgrade path; a successful installation can otherwise reuse old staged packages without exercising the new metadata.
- Option C: Leave resume state outside this item and record a follow-up.
  - Pro: Has the narrowest immediate scope.
  - Con: Leaves real-host acceptance unable to show that the selected metadata was used unless a separate manual prerequisite is introduced.

#### Recommended option for Q11

Option A. Earlier progress for a different list or detected server must not suppress synchronization for the selected inputs. Legacy state lacking those identities also restarts because it cannot establish a match. The same selected file and detected key retain ordinary resume-after-entry behavior. Existing download and remote-copy reuse remain available for packages selected during the restarted synchronization.

#### Answer to Q11: option A

Option A is proposed for human consolidation. AC7 and AC12 cover a changed list selection, a changed detected key and legacy unkeyed state, including a host that retains its pre-upgrade marker: the restart is reported and each active entry is processed through the selected inputs without the operator deleting the marker. If Option B is chosen instead, both the upgrade instructions and AC7 must explicitly require the reset.
