# Design v0.27.0: Python SQLite support

Reference feature request:
[feature-request.v0.27.0.python-sqlite-support.md](feature-request.v0.27.0.python-sqlite-support.md)

Umbrella: [Debian agent tools](draft.v0.27.0.debian-agent-tools.md), item 6.

## Context for the v0.27.0 SQLite design

The archive's historical Python omitted its compiled `_sqlite3` extension.
SQLite payload entries are already present, but the build does not explicitly
select them or reject a Python without the required capability. This design
connects sandbox inputs, build completion, archive closure and executable
acceptance evidence. The requirement's seven clarifications are confirmed;
the architectural recommendations below remain subject to design review.

## Scope of the v0.27.0 SQLite design

The outcomes are a SQLite-capable RHEL 9 x86_64 Python build, an archive carrying
its extension and runtime library, and evidence from the build account, a
relocated Debian 12 candidate and a deployed RHEL 9.8 candidate.

The design includes explicit sandbox detection, rejection of an unusable build,
the existing-tree rebuild route, withdrawal of the satisfied closure waiver,
and one reproducible SQLite acceptance operation. Other targets retain their
configure and build behavior, including targets without SQLite packages.

Item 7 owns the release refresh, D5 regression re-check, final archive rebuild,
full integration matrix and publication. Item 6's identified validation build
uses the tracked 3.13.15 pin and is not a release. The consuming application's
coverage and pytest-testmon settings remain part of its later adoption work.

## Confirmed build facts for Python SQLite

| Component | Current fact | Design consequence |
| --- | --- | --- |
| Python dependency list | `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt` contains `sqlite-libs` and `sqlite-devel`. | Retain the selected RPM route and item 5's architecture resolution. |
| Python configure function | `src/install/env/python/python_install_functions.sh` passes `LIBMPDEC_*` and has no `LIBSQLITE3_*` pair. | Add the confirmed SQLite inputs to the Python configure environment within the accepted target scope. |
| Shared build environment | `install_functions.sh` selects sandbox headers, linker paths and runtime paths; `tool_prefix` names the requested version. | Check the newly built version directly, before changing `current`. |
| Linux install driver | `src/install/env/install` evaluates `CPLX_CONFIG_DONE`, recognizes `--reconfigure`, and forces `clean()` when reconfiguration is requested. | The explicit upgrade route already has a configure-and-clean control. |
| Python reuse and cleanup | `build()` skips `make` when `python` or `git-add` exists; `clean()` runs `make clean` when a Makefile exists and removes `python`. | Validate reused output as well as new output; prove the explicit rebuild overcomes both configure and compile reuse. |
| Install reuse | The shared `install()` can skip installation based on the `libpython3.so` timestamp. | Source-build success alone cannot establish the installed `lib-dynload` contents. |
| Promotion | The install driver calls configure, clean, build, install and package, then advances `current` only after successful completion. | A capability rejection must propagate before packaging or selector advancement. |
| Build-family metadata | `setup.sh` persists `CPLX_ARCH_EXT`; `senv.local.tpl` currently declares `el9.x86_64`. | There is an existing family identity to consider for the Python policy boundary. |
| Closure declaration | The declaration retains the Python SQLite floor and active item 6 waiver, and names Python's `current` and `python-3.13.9` subdirectories. | Preserve the floor, remove the satisfied waiver, and verify the candidate's actual version layout against the declared scope. |
| Closure identity | The declaration's exact committed bytes are hashed and its envelope travels with it. | Regenerate the envelope with a declaration change, following the existing configuration contract. |
| Full archive source | `pkg_tools.sh` mirrors `$HOME/tools` into its private stage and refuses a caller's `--source-root`. | Candidate assembly must provide an isolated account layout while preserving the owned-source boundary. |
| Live promotion | `rsync.sh` reads `$HOME/cplx/tools/*/current`, syncs with `--delete`, and deletes other version directories under `$HOME/tools`. | Candidate preparation must not use an operator's live destination inadvertently. |

The configure marker is more than file existence: the driver also checks its
configured success text. The requirement's abbreviated `config.log` reuse
description must therefore be read with this existing behavior. No new
automatic SQLite-triggered reconfiguration is proposed.

## Target flow for the SQLite candidate

```text
Selected SQLite RPM payloads in the Python sandbox
  -> scoped explicit configure inputs
  -> explicit rebuild, or ordinary build/reuse
  -> source-build capability check
  -> install into the requested version prefix
  -> installed capability check
  -> existing packaging and closure checks
  -> identified non-release candidate
  -> operator-invocation acceptance on all three environments
  -> item 7 repeats acceptance on its final archive
```

The source-build and installed checks have different subjects. The former
checks the just-built interpreter and its extension in the build output. The
latter checks the requested installation prefix and its `lib-dynload`, even
when installation was skipped. Neither may accidentally inspect the old
`current` interpreter or Python found elsewhere on `PATH`.

## Target policy and sandbox selection for SQLite

The recommended policy key is the existing declared build family,
`CPLX_ARCH_EXT=el9.x86_64`, read through the build's established configuration
path. Both the configure environment and capability checks use the same
Python-owned scope decision. Existing presence checks already reject a missing
identity in setup and the remote environment. The policy trusts the declared
family; it does not introduce a second host classifier. A wrong declaration can
therefore select the wrong policy, and acceptance evidence must establish the
actual build host. Other declared families keep their current configure and
build result.

For the selected family, pass the requirement's explicit inputs beside the
existing dependency settings:

```sh
LIBSQLITE3_CFLAGS=-I${root}/usr/include
LIBSQLITE3_LIBS=-L${root}/usr/lib64 -lsqlite3
```

These dependency variables are part of the documented
[CPython 3.13 configure interface](https://docs.python.org/3.13/using/configure.html#options-for-third-party-dependencies).
Preserve the shared sysroot and runtime-path construction. No host-library
fallback, SQLite source build, SQLite CLI requirement or loadable-extension
feature is added. Configure output remains part of acceptance evidence and
must report the `_sqlite3` extension available.

## Capability checks at Python build completion

The recommended structure keeps SQLite policy with Python's install support.
The Python build function checks capability after either compilation or reuse.
An optional tool-owned post-install callback, invoked by the shared driver
after successful `install()` and before `package()`, checks the installed
version. Tools without that callback keep their existing flow; Python applies
its scoped policy inside the callback. A nonzero callback result is returned
by `main` like any other failed stage, preventing `current` advancement.

The check requires an importable `_sqlite3` belonging to the expected build or
installation tree and a usable `sqlite3` module against the sandbox payload.
The installed check additionally establishes the extension's presence in the
requested prefix's `lib-dynload`. A host or old-prefix module cannot satisfy
the check. A common Python probe can express the operation and provider
observation while callers supply the expected interpreter and allowed roots.

Both build-stage checks inherit the driver's exported `LD_LIBRARY_PATH` and
`LD_RUN_PATH`, including the sandbox library directories. Their provider result
establishes capability under that build environment only. It cannot establish
that the extension's runtime paths work after relocation. Only acceptance under
the operator invocation, without additional library-path overrides, establishes
that property. Shared probe logic preserves the same database and identity
rules while each result retains its stage and invocation context.

Failure reports the stage, requested Python version, expected tree and missing
capability, retains the interpreter's error, and returns a nonzero result to
the existing driver. The Windows install entry already reads the remote exit
status and reports failure. A missing probe or an unobservable provider cannot
produce a successful capability result.

This preserves the driver's existing promotion order. It does not promise
transactional rollback of modifications within an already selected version's
directory. An unsuccessful attempt is not an accepted candidate; a rebuild
that fails validation requires repair before packaging and acceptance.

## Explicit rebuild of the populated Python tree

Reuse the existing explicit reconfigure control as the operator interface.
The Linux driver invokes configure, forces Python cleanup, and then builds.
The Python sandbox root and unrelated tools remain reusable. There is no need
for a second rebuild flag or automatic capability-based cache invalidation.

The implementation plan must verify this route with the current successful
configure marker and compiled `python` already present, and verify that the
new extension reaches the requested installation prefix. A successful clean
or a changed configure log alone is insufficient. Ordinary reuse of a stale
interpreter must fail the capability check rather than silently succeed.

## SQLite provider and database acceptance evidence

Use a single reproducible probe operation under the actual toolchain invocation.
It creates a temporary file-backed database in caller-owned scratch space,
writes and commits a known value, closes the connection, reopens the database
and reads that value. After that operation, the same Python process observes
its loaded SQLite provider. Probe execution must not add library-path overrides
that are absent from the operator's normal invocation.

The recommended observer reads `/proc/self/maps`. Linux documents mapped files
and their paths in the [proc filesystem interface](https://www.kernel.org/doc/html/latest/filesystems/proc.html).
The probe must connect the mapping to the shipped `libsqlite3.so.0` and its
resolved backing file, which may have a versioned basename. It collapses
multiple mappings of the same file and compares canonical file identity and
path containment against the expected Python tree. Merely finding the text
`libsqlite3` or matching an unresolved symlink is insufficient.

The expected Python root is supplied independently by the caller, not inferred
from whichever provider was loaded. Canonicalize that root as well as the
provider before comparing containment, allowing a legitimate symlinked
deployment root without allowing escape from its resolved tree.
A copy under another tool, an escaped symlink or a host path fails.
No observed load, unreadable mappings, an absent
backing file or ambiguous provider identity is inconclusive and prevents a
pass. Deleted-file mappings cannot serve as evidence of an intact archive.
An external loader trace remains a diagnostic aid rather than a second
automatic observer with different pass rules.

The probe emits one structured result per invocation with Python version,
executable and extension identity, database result, provider identity and
overall outcome. The surrounding capture records the environment role,
candidate identity and invocation. Paths in tracked evidence use the
repository's configured sanitization; host and account access details remain
in the existing ignored operations notes.

## Archive closure and candidate identity for SQLite

The candidate carries `_sqlite3` under its installed `lib-dynload` and
`libsqlite3.so.0` with its backing file under `tools/python/root/usr/lib64`.
The existing closure checker continues to own the shared resolution scope and
the `tools/python` location constraint. Dynamic provider evidence complements
that static contract.

Remove the SQLite waiver when the floor's existing payload condition is met;
retain the floor. Follow the closure bundle's existing exact-byte digest and
source-identity rules when regenerating its envelope in the same change.
The 3.13.15 candidate has a `python-3.13.15` directory, while the declaration
currently names `python-3.13.9`. The recommended change replaces that version
record with `subdir|python|python-3.13.15` and retains `root` and `current`.
The checker compares declared and observed immediate subdirectories, so
declaring `current` alone would not cover the actual version directory.
Preserve rejection of undeclared directories, missing or misplaced SQLite,
and stale SQLite waivers.

The [closure ownership contract](../../src/setups/env/closure/README.md) requires
the owning requirement to state an entry change. Requirement AC5 currently
states waiver removal only. This version-record change therefore needs a
matching requirement amendment before implementation; the design review flags
that earlier-document correction and does not silently authorize or apply it.
Q06 compares the declaration shapes, with exact replacement recommended.

A candidate record ties together the cplx source revision, Python version,
selected package/payload identities, archive digest and closure bundle identity.
The build-account result and the two consumer results refer to that candidate;
similar filenames alone do not connect evidence to bytes. This is an item 6
validation archive, with no release coordinate or publication operation.

## Isolated assembly and deployment of the SQLite candidate

The recommended assembly boundary is an isolated account home or equivalent
sibling workspace that owns its `cplx`, `tools`, package outputs and environment
metadata. Promotion and packaging run within that complete layout. Merely
repointing one tool directory is insufficient: `rsync.sh` can delete other
version directories, and packaging also maintains archive and digest outputs
under its home. The existing packager continues to own its private source
stage; item 6 does not add a caller-source override.

RHEL deployed acceptance likewise uses an isolated deployment target with the
normal installer and operator invocation. Record before/after preservation
evidence for the actual live build-account and deployment trees. Establish that
the chosen layout and scripts honor the isolation boundary, including the
account's login-profile chain, before invoking promotion or deployment.
If that route cannot be established, acceptance remains
blocked; it does not fall back to replacing live tools. Q05 retains this choice
for human confirmation, following the isolated-target precedent in item 5.

## Acceptance environments and the item 7 handoff

The existing [environment reference](reference.environments.md) describes the
RHEL build/deployment host and the Jenkins agent. Requirement Q07 separately
approves a plain Debian 12 container for the unpublished candidate, contingent
on a confirmed runtime host and archive-copy route. Those facilities have not
been established by this design work.

The Debian capture records the host role, image digest, candidate archive
identity and relocated invocation. The container holds the candidate and
verification material without additional SQLite payloads supplied by the test.
The probe is a verification script carrying no library; the candidate remains
the sole supplied toolchain payload, consistent with requirement AC11.
The RHEL deployment capture likewise runs through the deployed operator path.
Build-account, Debian and RHEL evidence remain distinct even where build and
deployment share a physical host. Missing Debian facilities or evidence leaves
item 6 incomplete.

Item 7 applies the confirmed D5 version rule and repeats these checks against
its final refreshed archive. Item 6's 3.13.15 pin and successful candidate do
not establish the later regression re-check or authorize publication.

## Acceptance cases for the v0.27.0 SQLite design

| Scenario | Expected outcome | Requirement |
| --- | --- | --- |
| Selected-family configure with sandbox SQLite inputs | Explicit inputs used and extension detection reports `yes`. | AC1, AC2 |
| Compilation or reuse yields Python without `_sqlite3` | Capability failure before packaging or selector advancement. | AC7 |
| Source interpreter passes, installed extension is absent or stale | Installed-prefix check rejects completion, including an install reuse path. | AC3, AC7 |
| Other declared target without SQLite payloads | Existing configure and build result preserved. | AC8 |
| Populated tree is explicitly reconfigured | Reconfigure, cleanup and compilation run; installed capability passes while unrelated payloads remain. | AC9 |
| Database succeeds using the expected shipped provider | Functional and provider result retained for the named environment. | AC4 |
| Host provider, another tool's provider or escaped symlink | Failure despite successful database behavior. | AC3, AC4 |
| Provider observation is missing or ambiguous | Inconclusive; acceptance cannot pass. | AC4 |
| SQLite waiver removed but floor library missing or only under Git | Existing closure rejection retained. | AC5, AC6 |
| SQLite payload present while its waiver remains | Existing stale-waiver rejection retained. | AC6 |
| Candidate identity or Debian environment evidence is absent | Item 6 remains incomplete. | AC10, AC11 |
| Item 7 refreshes payloads or selects a different permitted patch | Repeat SQLite acceptance on that final archive. | AC10 |

## Open questions for the v0.27.0 Python SQLite design

These recommendations concern architecture. The requirement's Q01-Q07 remain
confirmed; the answers below are proposed and await human confirmation.

### Q01: Which identity should select the SQLite build policy?

The requirement selects the RHEL 9 x86_64 build family and preserves other
targets. The build already has a declared `CPLX_ARCH_EXT`, while the machine
also exposes operating-system and CPU information. Configure and validation
must share one scope decision. Existing presence checks reject missing identity;
the remaining tradeoff is whether to trust the declared family or introduce a
second classifier based on the executing host.

#### BBQ for Q01

A kitchen can choose a recipe from the order ticket or inspect the ingredients
to infer the order. Both cooks must agree before preparation starts.
In this picture: the ticket is declared build-family metadata, the ingredients
are detected host information, the recipe is the SQLite policy, and the cooks
are configure and capability validation.

#### Options for Q01

- Option A1: Use the existing declared family as the policy key.
  - Pro: Configure and validation share the same identity used by the build.
  - Con: A wrong operator declaration scopes the build wrongly; existing
    presence checks cover a missing value, while acceptance must show the
    actual build host.
- Option A2: Determine policy from the native host's OS and CPU independently.
  - Pro: The policy follows the machine executing this native build.
  - Con: A second classifier can disagree with dependency and archive selection,
    and must define handling for compatible distributions and aliases.

#### Recommended option for Q01

Option A1: Keep the existing declared family as the common policy key and retain
the existing missing-value failures. This avoids a competing classifier while
requiring acceptance evidence to establish the actual supported build context.

#### Answer to Q01: option A1 (pending human confirmation)

Option A1 is proposed because one build-family decision can govern both
configuration and validation without changing known out-of-scope families.
Setup and the remote environment already reject a missing identity; acceptance
records the actual build host instead of claiming the declaration proves it.

### Q02: Where should installed capability validation join the build flow?

The source interpreter and requested installation prefix are separate subjects;
the shared installer can reuse an older installed prefix. The design needs an
installed check after installation or reuse and before packaging, with the
Python-specific policy owned in a clear place.

#### BBQ for Q02

A bakery checks a loaf at the oven and checks the customer's box before it
leaves. The packing line can call a product-specific inspector or contain the
bread inspection rules itself.
In this picture: the loaf is source-build output, the box is the installed
prefix, the packing line is the shared install driver, and the inspector is
Python's capability check.

#### Options for Q02

- Option B1: Keep source validation in Python's build support and add an optional
  tool-owned post-install callback to the shared driver.
  - Pro: Python owns its policy while the common driver enforces the needed
    ordering even after install reuse.
  - Con: The driver gains a callback contract whose failure must propagate.
- Option B2: Add a Python-specific capability branch directly to the shared
  driver after installation, alongside the Python-owned source check.
  - Pro: The required ordering is explicit without introducing a callback.
  - Con: The shared driver acquires Python-specific policy and dependencies.

#### Recommended option for Q02

Option B1: Use an optional callback after successful installation and before
packaging, with Python applying the same scoped policy as its source check.
Tools without the callback retain their current control flow.
The callback's nonzero result is returned by `main` like any failed stage, so
`current` is not advanced.

#### Answer to Q02: option B1 (pending human confirmation)

Option B1 is proposed because it checks the actual installed result at the
required boundary while keeping the shared driver independent of SQLite rules.

### Q03: Which observer should establish the loaded SQLite provider?

The confirmed acceptance rule requires the same Python process to demonstrate
the shipped provider after a database operation. A static dependency listing
does not meet it. The observer must identify the actual backing file for
`libsqlite3.so.0`, which can have a versioned basename, and reject ambiguous
evidence without introducing library-path overrides.

#### BBQ for Q03

A diner needs to know which supplier's flour reached the loaf, not only which
suppliers were on the shopping list. They can inspect the baker's current
ingredient record or interpret the delivery log for that batch.
In this picture: the loaf is the database operation, flour is the loaded SQLite
library, the shopping list is static dependency metadata, the current record
is process mappings, and the delivery log is the loader trace.

#### Options for Q03

- Option C1: Read the process's own mappings and match the shipped library's
  canonical backing-file identity within the expected Python root.
  - Pro: Observation runs inside the process that performed SQLite work and
    needs no additional executable on the supported Linux environments.
  - Con: Mapping access or ambiguous identity can be inconclusive, and path
    escaping, deleted files and repeated mappings need precise handling.
- Option C2: Capture a loader trace for the probe process and interpret its
  successful library loading events.
  - Pro: The trace also helps explain loader search and fallback decisions.
  - Con: The capture must reliably bind trace events to the relevant process
    and operation and distinguish a searched path from the loaded provider.

#### Recommended option for Q03

Option C1: Use `/proc/self/maps` as the acceptance observer, comparing the
resolved shipped provider against independently supplied, canonicalized roots.
Keep loader traces available for diagnosis without a second automatic pass
rule. Unobservable or ambiguous identity remains inconclusive and cannot pass.

#### Answer to Q03: option C1 (pending human confirmation)

Option C1 is proposed because it ties provider evidence directly to the process
that completed the required database operation on the supported Linux targets.

### Q04: Should build validation and candidate acceptance share a probe?

Both stages need a functioning SQLite operation and provider identity, but
source-build, installed-prefix and relocated-archive layouts differ. The design
must choose whether to share these checks through an explicit caller contract
or maintain separate validators. The probe must run under the actual selected
interpreter without relying on a host Python package installation.

#### BBQ for Q04

A workshop and a delivery team can use the same calibrated gauge with different
fixtures, or each can maintain its own gauge. Fixtures must describe the object
being checked rather than adjust themselves until a measurement passes.
In this picture: the gauge is the SQLite probe, fixtures are caller-supplied
expected roots and layout, the workshop is build validation, and the delivery
team is relocated candidate acceptance.

#### Options for Q04

- Option D1: Share one Python probe with explicit stage and expected-root inputs;
  callers own invocation and environment/candidate evidence capture.
  - Pro: Database and provider pass rules remain consistent across environments.
  - Con: The interface must distinguish layouts and the probe must be available
    as verification material wherever acceptance runs. Build-stage callers
    inherit the driver's library path, so they establish build capability only;
    runtime-path correctness requires operator-invocation acceptance.
- Option D2: Maintain separate build guards and a candidate acceptance probe.
  - Pro: Each validator can be narrowly tailored to its environment.
  - Con: Repeated operation and provider rules can diverge and need independent
    maintenance and verification.

#### Recommended option for Q04

Option D1: Share the operation and provider checks through explicit inputs,
while stage callers enforce their own extension location and record environment
identity. Use the selected toolchain interpreter and its standard library;
probe availability is a verification prerequisite, with no host installation
dependency or additional runtime library-path override.

#### Answer to Q04: option D1 (pending human confirmation)

Option D1 is proposed because one set of pass rules connects build capability
with acceptance evidence while callers preserve each stage's expected layout
and operator invocation.

### Q05: Where should the validation candidate be assembled and deployed?

`src/setups/env/bin/pkg_tools.sh` takes its payload from `$HOME/tools` and
refuses a caller's `--source-root`. Promotion through the adjacent `rsync.sh`
reads `$HOME/cplx/tools/*/current`, uses `--delete` and deletes other Python
version directories under `$HOME/tools`. Using the live account layout would
replace operator-visible tools with the item 6 non-release build. The same
boundary matters for RHEL deployed acceptance.

#### BBQ for Q05

A restaurant can test a new menu by replacing the dining room's service or by
setting up a complete practice service in a separate room. Moving only the
serving plate leaves shared preparation and cleanup areas exposed.
In this picture: the menu is the candidate toolchain, service is promotion and
deployment, the dining room is the live account layout, the practice room is
the isolated layout, and preparation and cleanup areas are package outputs,
environment files and version-directory deletion targets.

#### Options for Q05

- Option H1: Assemble and deploy in the live build and deployment account trees,
  with separately preserved restoration material.
  - Pro: Uses the existing account layout directly.
  - Con: Replaces live Python before item 7, and promotion deletes previous
    version directories, so recording their names alone cannot restore them.
- Option H2: Use an isolated account home or equivalent sibling layout for
  candidate assembly and an isolated RHEL deployment target.
  - Pro: Preserves live tools while exercising normal packaging, installation
    and operator invocation, consistent with item 5's isolation precedent.
  - Con: Must establish that every relevant path, output and deletion stays
    within that layout and retain before/after live-tree preservation evidence.
    Also audit the account's login-profile chain for writes into live trees,
    as item 5 did before its isolated run; changing the payload home alone
    does not establish this boundary.
- Option H3: Add a caller-selected staging-source packaging interface.
  - Pro: Makes the candidate payload source explicit.
  - Con: Reopens the deliberate owned-source refusal and expands the packaging
    contract beyond this Python capability item.

#### Recommended option for Q05

Option H2: Isolate the complete assembly and deployment layouts, including
metadata and package outputs, while retaining the packager's private-stage
ownership. Confirm the boundary before running promotion or deployment; an
unavailable isolated route blocks acceptance instead of falling back to live
replacement. Exact setup and preservation commands belong in the plan.

#### Answer to Q05: option H2 (pending human confirmation)

Option H2 is proposed because it makes the required non-release candidate
reviewable without changing operator-visible tools before the release item.

### Q06: How should the closure declaration represent the candidate version?

The candidate's known `python-3.13.15` directory is absent from the current
declaration, which names `python-3.13.9`. The checker compares declared and
observed immediate subdirectories: the `current` alias does not declare the
version directory it points to. Leaving the entry unchanged, or retaining
`current` alone, cannot cover the candidate under the existing scope contract.

The choice here is the declaration's shape. The closure ownership contract also
requires a matching statement in the owning requirement before an entry change;
that earlier-document amendment is flagged as a prerequisite, not performed or
treated as approved by this design review.

#### BBQ for Q06

A warehouse checks each named storage bay against its approved floor plan.
When goods move to a newly numbered bay, the plan can replace the old bay or
approve both. A sign pointing to the active bay does not add it to the plan.
In this picture: bays are version directories, the floor plan is the closure
declaration, the sign is `current`, and approval is the owning requirement's
explicit statement of the declaration change.

#### Options for Q06

- Option J1: Replace the 3.13.9 version record with the candidate's 3.13.15 record,
  retaining `root` and `current`.
  - Pro: The declaration describes the candidate's intended version layout
    without allowing an additional historical version directory.
  - Con: The requirement must state the change and the envelope must be renewed;
    later version selection may require another deliberate declaration update.
    A retained `python-3.13.9` directory becomes UNEXPECTED under the new
    declaration, so the candidate must match the approved version shape.
- Option J2: Retain the historical version record and add the candidate record.
  - Pro: The declared shape can cover either version directory without changing
    the checker's grammar or comparison rules.
  - Con: It permits an additional historical directory the candidate does not
    need, and still requires the requirement statement and envelope renewal.

#### Recommended option for Q06

Option J1: Replace the exact version record and preserve the existing scope
checks. Record the corresponding requirement correction before implementation
and regenerate the envelope with the declaration. Item 7 must align its final
permitted Python version with the declaration again if that version changes.

#### Answer to Q06: option J1 (pending human confirmation)

Option J1 is proposed because it describes the selected candidate without a
broader accepted directory set. Implementation depends on the matching
requirement statement; the settled requirement has not been edited in this round.
