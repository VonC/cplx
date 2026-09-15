# Build the toolchain python with sqlite

- Type: feature-request
- Version: v0.27.0
- Topic: python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md

## Umbrella revision introducing Python SQLite support

As the maintainer of the tools archive, I want its Python interpreter to
include working SQLite support and ship the library it needs, so the same
archive can run the application's tests with coverage and pytest-testmon on
the Debian Jenkins agent and remain usable on RHEL deployment targets.

This is item 6 of the
[Debian agent tools umbrella](draft.v0.27.0.debian-agent-tools.md), derived
from work item 2 (Q24) and decision D7. The
[focused draft](draft.v0.27.0.python-sqlite-support.md) was approved on
2026-09-15. Items 4 (`toolchain-runtime-closure`) and 5
(`architecture-minor-fallback`) are completed prerequisites: the former
enforces the archive's required libraries, and the latter selects the
dependency metadata for the RHEL 9.8 build host.

## Current Python SQLite behavior entering v0.27.0

- The archive observed by the umbrella was built without `_sqlite3`.
  Jenkins develop#7 failed with
  `ModuleNotFoundError: No module named '_sqlite3'`. The extension is a
  compiled file under Python's `lib-dynload`, so adding a runtime library
  alone cannot restore the module.
- A live-tree search on the build account on 2026-08-08 also found no
  `libsqlite3.so.0` under `tools/*/root`. A missing compiled extension and a
  missing runtime library are separate gaps. These are retained historical
  observations, not new measurements of the current server.
- The consuming application's test walk consequently disables coverage and
  pytest-testmon and guards suites that import coverage-related code.
- The current retained Python package list,
  `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt`, already contains
  `sqlite-libs` and `sqlite-devel`. Those preparation changes must be retained.
- The configure array in
  `src/install/env/python/python_install_functions.sh` has explicit
  `LIBMPDEC_*` settings but no `LIBSQLITE3_*` settings.
- The runtime-closure requirement already declares `libsqlite3.so.0` as a
  required member under `tools/python`, with a temporary waiver owned by this
  item. The library requirement itself must remain after that waiver is removed.

## Expected SQLite behavior of the toolchain archive

The RHEL-built Python interpreter must compile its `_sqlite3` extension from
the SQLite development payload inside its own sandbox. The packaged Python
tree must carry both that extension and `libsqlite3.so.0`. After relocation,
`python3 -c 'import sqlite3'` must succeed on Debian 12 and RHEL 9.8 as well as
on the build account, using the shipped SQLite runtime dependency.

The build and deployed interpreter must preserve their existing independence
from host SQLite installations. A successful import that relies on a library
available only on the host does not satisfy the archive contract.

## Confirmed provenance and build constraints for SQLite

Decision D7 selects the existing RPM-payload extraction route. The Windows
side downloads the packages, `setup.sh` transfers them, and
`packages_management.sh` extracts them unprivileged inside
`~/cplx/tools/python/root`. No administrator rights, `dnf` invocation or system
package installation is required; the server work stays inside `~/cplx`.

| Payload | Required purpose |
| --- | --- |
| `sqlite-devel` | Supply `sqlite3.h` and the `libsqlite3.so` linker symlink inside the Python sandbox. |
| `sqlite-libs` | Supply `libsqlite3.so.0` inside the sandbox and retain it in the packaged Python tree. |
| `sqlite` CLI | Optional; the Python stdlib module does not require it. |

The umbrella records RHEL 9's SQLite 3.34.1 with backports as sufficient for
CPython's SQLite 3.15.2 minimum and the consuming test tools. It records libc,
libm and libz as its runtime dependencies, already present in the shipped root.
The existing closure checks remain responsible for checking the actual payload.

Copying from the server's `/usr` was rejected: the recorded server inventory
contains only the runtime library and its target, with no header, linker
symlink or `sqlite3.pc`. Building SQLite from source remains a future option
for a different version or provenance need; this item uses the selected RPM
payloads and the existing architecture resolver.

The build retains its sysroot isolation: sandbox headers and libraries are
selected through the existing `CFLAGS`, `CPPFLAGS` and `LDFLAGS`. Make SQLite
detection explicit alongside `LIBMPDEC_*` with the settings supplied by the
approved draft:

```sh
"LIBSQLITE3_CFLAGS=-I${root}/usr/include" \
"LIBSQLITE3_LIBS=-L${root}/usr/lib64 -lsqlite3" \
```

Setting both variables bypasses CPython 3.13's SQLite pkg-config probe. The
umbrella warns that its supplied `sqlite3.pc` has `prefix=/usr`; using
pkg-config without a sysroot can select host library paths. The selected
direction therefore remains the explicit sandbox settings. If pkg-config is
chosen later, it needs `PKG_CONFIG_SYSROOT_DIR=${root}`. Loadable SQLite
extensions are not required: `--enable-loadable-sqlite-extensions` is only
relevant if the application separately needs that capability.

## Gap to close in the implementation for Python SQLite support

1. Preserve the existing SQLite package-list entries and use the completed
   architecture selection workflow to populate the Python sandbox for the
   detected RHEL 9.8 key. Retain fresh observations of the module, header,
   linker symlink and runtime library when implementation starts.
2. Add the explicit SQLite configure inputs and rebuild Python so `_sqlite3`
   is compiled. Confirm detection in the configure output and the absence of
   `_sqlite3` from the final necessary-bits-not-found summary.
3. Include the compiled extension in Python's `lib-dynload` and the runtime
   library under `tools/python/root/usr/lib64` in the archive. A runtime
   library left only in the build sandbox does not close the gap.
4. Remove the satisfied SQLite waiver while preserving its declared floor
   entry and the existing packaging checks.
5. Demonstrate the SQLite acceptance on the build account, Debian after
   relocation, and RHEL after deployment, retaining evidence for item 7.

## SQLite waiver contract with the completed runtime-closure item

The [runtime-closure requirement](issue.v0.27.0.toolchain-runtime-closure.md)
defines the exact removal condition:

> a file named `libsqlite3.so.0` is present under `tools/python` in the
> resolution scope.

This is the existing floor entry's location test. The installer composes one
ordered resolution scope across the tool roots. A library present only under
`tools/git` does not satisfy the Python location constraint.

This item removes the waiver, not the floor entry. Packaging must continue to
refuse a missing required member without a waiver, and must refuse a stale
waiver whose removal condition is already satisfied. The payload condition
governs removal; a document's completion status is not the packaging signal.
Any remaining active waiver continues to prohibit release publication.

## Acceptance criteria for Python SQLite support in v0.27.0

| ID | Required result |
| --- | --- |
| AC1 | The Python sandbox contains `sqlite3.h`, the `libsqlite3.so` linker symlink and `libsqlite3.so.0` from the selected SQLite RPM payloads. Existing SQLite dependency-list entries are retained. |
| AC2 | CPython receives the explicit sandbox SQLite configure settings. `checking for stdlib extension module _sqlite3` answers `yes`, and `_sqlite3` is absent from the final necessary-bits-not-found summary. |
| AC3 | The archive contains the compiled `_sqlite3` extension in Python's `lib-dynload` and `libsqlite3.so.0` under `tools/python/root/usr/lib64`; neither file is supplied solely by the host. |
| AC4 | `python3 -c 'import sqlite3'` succeeds using the toolchain interpreter on the RHEL build account, on Debian 12 after relocation, and on a RHEL 9.8 target after deployment. |
| AC5 | The existing closure location test finds `libsqlite3.so.0` under `tools/python` in the resolution scope. The satisfied SQLite waiver is removed and its floor entry is retained. |
| AC6 | The existing packaging contract continues to reject a missing unwaived SQLite floor member, a copy only under `tools/git`, and a stale SQLite waiver after the removal condition is satisfied. |

## SQLite delivery boundary within the umbrella

Item 6 owns the SQLite integration, the rebuild needed to produce its extension,
and focused acceptance evidence. Item 7 (`tools-archive-rebuild`) owns the final
sandbox refresh, release archive rebuild, complete cross-distribution validation
matrix and release publication. It applies the already decided D5: one rebuild
serves the Python refresh and SQLite integration, using 3.13.14, or 3.13.15 if
its pre-rebuild regression re-check is clean; never 3.13.10. The tracked
`tools/senv.local.tpl` currently pins 3.13.15. Q06 makes explicit the proposed
narrowing of D5's single-rebuild rule to allow a separate item 6 validation
candidate; that change remains pending confirmation.

This cycle retains the Python 3.13 line required by the application's
`>=3.13, <3.14` constraint. A move to Python 3.14 remains a later-cycle topic.
The preceding items own wrapper hardening, relocation, architecture fallback
and the closure checker.

After the consuming repository adopts the resulting archive, it can remove
`--no-cov` and `-p no:pytest-testmon`. The degraded `conftest_coverage` import
and Q24 skip guards self-enable once SQLite is available. Those pipeline edits
and its tools-version pin belong to that repository and the release handoff;
this requirement makes the necessary interpreter capability available.

## Code and evidence references for Python SQLite support

- `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt`: retained Python dependency
  list, including the two SQLite package entries already present.
- `src/install/env/python/python_install_functions.sh`: Python configure array
  and existing `LIBMPDEC_*` settings that the SQLite inputs follow.
- `tools/senv.local.tpl`: current tracked Python 3.13.15 pin; this records the
  local setting, not completion of D5's pre-rebuild regression re-check.
- `src/setups/pkgs/packages_rhel_9.6_x86_64.txt`: historical global package index
  cited by the umbrella; the architecture workflow generates the index for the
  detected build-host key.
- `src/setups/env/bin/packages_management.sh`: existing sandbox payload
  extraction machinery.
- [Runtime-closure requirement](issue.v0.27.0.toolchain-runtime-closure.md):
  required-member floor, shared resolution scope and SQLite waiver contract.
- [Architecture fallback requirement](feature-request.v0.27.0.architecture-minor-fallback.md):
  completed dependency metadata selection and detected-key index behavior.
- [Environment reference](reference.environments.md): build, deployment and
  Debian-agent identities and evidence boundaries.
- [Why recompile](../../wiki/explanation/why-recompile.md): sandbox build model.

## Open questions for the v0.27.0 Python SQLite feature request

The answer lines below record review recommendations, pending confirmation.
They do not change the approved draft or settle the requirement by themselves.

### Q01: Which existing Python build targets gain the mandatory SQLite contract?

The requirement names the RHEL 9.8 build and its Debian/RHEL consumers, while
the Python configure function is shared. Does mandatory SQLite support apply
only to that build family, or must this item extend the guarantee to every
existing Python build target?

#### BBQ for Q01

We are equipping one travelling kitchen, but the instruction sheet is shared
with other kitchens. In this picture: the travelling kitchen is the RHEL 9
tools build, its destinations are Debian and RHEL, and the shared sheet is
the Python build workflow used by other targets.

#### Options for Q01

- Option A1: Require SQLite for the RHEL 9 x86_64 build family and its named
  Debian/RHEL consumers; preserve existing behavior on other build targets.
  Changes to shared Python install functions must preserve other targets'
  configure and build results, including when they have no SQLite payload.
  - pro: Matches the umbrella's measured need and existing prerequisites.
  - con: Does not establish a SQLite guarantee for every historical target.
- Option A2: Require SQLite for every currently supported Python build target.
  - pro: Gives all Python archives one capability contract.
  - con: Broadens dependency and acceptance work beyond the named environments.

#### Recommended option for Q01 (with arguments for this choice)

Option A1: Keep the acceptance scope tied to the umbrella's RHEL 9 build and
two consumer distributions. Shared changes must preserve other targets, but
their SQLite enablement should not become an unstated prerequisite.

#### Answer to Q01: option A1 (with reason why it must be accepted as the answer)

Option A1: This delivers the requested archive capability without extending
the release obligation to unrelated build environments.

### Q02: Must a build refuse success when SQLite is still unavailable?

AC2 requires a positive configure result, but it does not state the unattended
build's result if configuration or compilation still omits `_sqlite3`, or the
built interpreter cannot import it. The library floor alone cannot prove that
the extension exists. Should this become a required build-success condition,
or remain an acceptance check performed after a nominally successful build?

#### BBQ for Q02

A kitchen can receive ingredients and still send out an empty dish. In this
picture: the ingredients are the SQLite development and runtime payloads,
the dish is the working Python module, and the dispatch decision is the build's
success result.

#### Options for Q02

- Option B1: Refuse successful completion of a Python build for a target in
  Q01's scope when `_sqlite3` is missing from the built `lib-dynload`, or when
  the built interpreter cannot import `sqlite3` against the sandbox payload.
  The diagnostic names the missing capability. Builds outside Q01's scope
  retain their current result.
  - pro: Prevents the original silent omission from returning unnoticed.
  - con: Makes SQLite mandatory for these builds and requires a target-scoped
    condition in shared build code.
- Option B2: Keep the build result unchanged and reject the result only during
  this item's acceptance or subsequent archive validation.
  - pro: Preserves current optional-module behavior in the build workflow.
  - con: A successful build can still deliver a Python lacking this capability.

#### Recommended option for Q02 (with arguments for this choice)

Option B1: The defect originated in an optional module being omitted without
stopping the build. Once this capability is required for the selected target,
success should mean that it is available, independent of a later manual review.

#### Answer to Q02: option B1 (with reason why it must be accepted as the answer)

Option B1: An unattended build must distinguish a usable SQLite-enabled
interpreter from one that merely completed CPython compilation.

### Q03: What functional SQLite behavior must acceptance demonstrate?

AC4 currently requires only `import sqlite3`. That establishes module loading,
while coverage and pytest-testmon use databases. What minimum behavior must
the focused acceptance demonstrate on the named environments?

#### BBQ for Q03

Opening the kitchen proves that the door works; serving a meal proves that
the kitchen works. In this picture: opening the door is importing `sqlite3`,
preparing the meal is a database operation, and serving it later is reopening
and reading a committed database.

#### Options for Q03

- Option C1: Retain import-only acceptance.
  - pro: Matches the original observed failure directly and keeps checks small.
  - con: Does not demonstrate database operations or persistence.
- Option C2: Require import plus a small file-backed database round trip:
  create, write, commit, close, reopen and read the expected data.
  Use the toolchain interpreter as operators invoke it, including its relocated
  or deployed invocation, in the same run that records Q04's provider evidence.
  - pro: Demonstrates the database behavior needed by the motivating tools.
  - con: Adds a small acceptance case beyond the draft's import command.
- Option C3: Require the consuming application's full coverage/testmon run
  before this item can complete.
  - pro: Demonstrates the motivating end-to-end outcome immediately.
  - con: Couples completion to another repository and the later release chain.

#### Recommended option for Q03 (with arguments for this choice)

Option C2: A small persistent database round trip establishes usable SQLite
without transferring the full application integration gate from item 7 and
the consuming repository into this item.

#### Answer to Q03: option C2 (with reason why it must be accepted as the answer)

Option C2: Acceptance should prove the module's basic database capability,
while the complete application test walk remains with the integration handoff.

### Q04: What evidence establishes that the interpreter uses shipped SQLite?

AC3 and AC5 establish archive presence, while AC4 establishes a successful
import. Neither explicitly requires evidence of which `libsqlite3.so.0` the
interpreter actually loaded. Recorded observations show a host copy on both
distributions: `/usr/lib64/libsqlite3.so.0` on RHEL and `libsqlite3-0 3.40.1`
on the Debian Jenkins agent. Either can hide a resolution gap. What observation
is required to support the archive-autonomy claim on each accepted environment?

#### BBQ for Q04

A kitchen may carry flour yet quietly borrow the neighbour's bag. In this
picture: the carried bag is the packaged SQLite library, the borrowed bag is
the host library, and watching which bag is opened is observing the library
actually loaded by the interpreter.

#### Options for Q04

- Option D1: Accept the existing static closure result together with a
  successful SQLite operation.
  - pro: Reuses the current archive checks with little extra evidence.
  - con: Does not directly identify the provider used by the running process.
- Option D2: Require conclusive runtime evidence, alongside the existing
  closure checks, that each accepted environment loads SQLite from the shipped
  Python tree within the archive's resolution scope.
  Observe the loaded `libsqlite3.so.0` after a SQLite operation in the same
  process, showing that it resolves under the built, deployed or relocated
  `tools/python` tree as applicable. An observation showing no SQLite load is
  inconclusive and cannot pass acceptance.
  - pro: Directly verifies independence from host SQLite on both distributions.
  - con: Requires retaining a provider observation with each acceptance run.

#### Recommended option for Q04 (with arguments for this choice)

Option D2: The umbrella already distinguishes library presence from actual
runtime resolution. Apply that evidence standard to the newly shipped SQLite
provider without redefining the existing closure scope or its rules.

#### Answer to Q04: option D2 (with reason why it must be accepted as the answer)

Option D2: A positive operation and its observed shipped provider together
establish the capability this item promises; archive presence alone cannot.

### Q05: What upgrade behavior is required for an existing Python build tree?

The real starting point is a populated sandbox and an interpreter previously
built without SQLite. The current workflow skips configuration while
`config.log` exists, and `build()` skips `make` while a compiled `python`
exists. Must ordinary reruns automatically upgrade that output, or is an
explicit documented rebuild sufficient to close this item?

#### BBQ for Q05

Delivering a missing ingredient does not change a meal already cooked. In
this picture: the ingredient delivery is the SQLite payload update, the cooked
meal is the existing interpreter, and cooking again is the supported rebuild.

#### Options for Q05

- Option E1: Support and document an explicit rebuild from the existing
  populated tree that forces both reconfiguration and recompilation,
  producing a verified SQLite-enabled interpreter while preserving unrelated
  reusable sandbox payloads.
  - pro: Covers the actual upgrade case without requiring general automatic
    build invalidation.
  - con: Operators must invoke the documented rebuild when changing inputs.
- Option E2: Require ordinary setup/build reruns to detect the missing
  capability and upgrade the existing interpreter automatically.
  - pro: Removes the operator's need to recognize the stale-build condition.
  - con: Extends this item into the workflow's automatic rebuild behavior.
- Option E3: Accept only a fresh-tree build and leave existing-tree upgrades
  unspecified.
  - pro: Minimizes the supported starting states.
  - con: Does not establish how the existing build account gains the capability.

#### Recommended option for Q05 (with arguments for this choice)

Option E1: The requirement explicitly calls for a rebuild. Establish that
the documented path works from the existing tree and preserves unrelated
reusable state; automatic rebuild detection can remain outside this feature.

#### Answer to Q05: option E1 (with reason why it must be accepted as the answer)

Option E1: This makes the real upgrade supported and reviewable without adding
an unrelated incremental-build redesign to the SQLite requirement.

### Q06: Which interpreter version and artifact can establish item 6 acceptance?

Item 6 requires a real rebuild and relocated acceptance, while item 7 owns the
final sandbox refresh and release archive. D5 already decides one rebuild for
the Python refresh and SQLite integration, on 3.13.14, taking 3.13.15 instead
if its pre-rebuild regression re-check is clean; never 3.13.10. The tracked
`tools/senv.local.tpl` already pins 3.13.15, but the pin alone does not record
that re-check.

May item 6 add a separate validation rebuild, explicitly narrowing D5's
single-rebuild rule, or should it perform the re-check and combined rebuild
itself? The patch differs from the current pin only if the re-check selects
3.13.14; payload refresh can still change the final artifact.

#### BBQ for Q06

A kitchen planned one cooking session for both a new recipe and refreshed
ingredients. A tasting would add a second session. In this picture: the
one-session plan is D5, the recipe is SQLite integration, the tasting is
item 6's validation candidate, and the banquet is item 7's release archive.

#### Options for Q06

- Option F1: Accept an identified non-release candidate on the tracked
  3.13.15 pin, recording its version and payload identity. This explicitly
  narrows D5: item 6 adds a validation rebuild, while item 7 performs the
  release rebuild, applies D5's regression re-check and repeats SQLite
  acceptance on the final archive.
  If confirmed, consolidation records this narrowing beside D5 in the umbrella,
  so its decisions table no longer states a single rebuild without qualification.
  - pro: Keeps the ordered items independently completable and preserves
    item 7's ownership of the release rebuild.
  - con: Requires two rebuilds and final acceptance, including after a
    re-check selects 3.13.14 or a payload refresh changes the inputs.
- Option F2: Have item 6 perform D5's pre-rebuild regression re-check and
  refresh so its rebuild becomes the single combined D5 rebuild.
  - pro: Honors D5's single-rebuild decision literally.
  - con: Moves the re-check and refresh timing from item 7, requiring its
    delivery boundary to change; any later payload refresh needs revalidation.

#### Recommended option for Q06 (with arguments for this choice)

Option F1: A separate candidate lets item 6 establish focused capability
evidence while item 7 retains the final refresh and release rebuild. This is
an explicit proposed narrowing of D5's one-rebuild decision, pending human
confirmation. It neither establishes a clean regression re-check for the
3.13.15 pin nor substitutes for final archive acceptance.

#### Answer to Q06: option F1 (with reason why it must be accepted as the answer)

Option F1: Accept the cost of a separate validation rebuild so item 6 can
complete independently, while retaining D5's release-version re-check and all
final acceptance and publication gates in item 7.

### Q07: Where can the unpublished candidate establish Debian 12 acceptance?

AC4 requires Debian acceptance after relocation within item 6. Q06's proposed
candidate is unpublished, while the environment reference identifies the
Jenkins agent as the only Debian host currently in hand, reached through the
consuming pipeline and without cplx credentials. The umbrella permits a plain
`debian:12` container holding the archive, but no host for that candidate run
has been confirmed. Where must item 6 establish its Debian acceptance?

#### BBQ for Q07

A tasting needs a venue before the banquet opens. In this picture: the tasting
is the unpublished archive candidate, the temporary kitchen is a plain Debian
container, the banquet kitchen is the Jenkins agent, and delivering ingredients
is transferring the candidate without publishing a release.

#### Options for Q07

- Option G1: Accept the candidate in a plain `debian:12` container holding only
  the candidate archive, on a confirmed host able to run it. Record the host
  role, image digest and archive identity. The Jenkins integration run remains
  with item 7. Confirm that host and a candidate transfer route before executing
  acceptance; if unavailable, report the gap rather than defer Debian acceptance
  silently or mark item 6 complete.
  - pro: Uses the umbrella's permitted acceptance environment without release
    publication or new agent credentials.
  - con: Requires a host with a confirmed container runtime and a confirmed
    copy route for the candidate archive; this evidence is not a run on the
    actual Jenkins agent.
- Option G2: Deliver the candidate to the Jenkins Debian agent through a
  distinct non-release location, such as staging or a snapshot, and run a
  diagnostics probe there. Never reuse the immutable release coordinate.
  - pro: Exercises the actual agent used by the consuming application.
  - con: Requires a confirmed delivery route and access not established by the
    current environment reference, plus consuming-pipeline diagnostics work.
- Option G3: Defer Debian acceptance to item 7 and complete item 6 on RHEL only.
  - pro: Removes the need to arrange a separate Debian candidate environment.
  - con: Changes AC4 and the umbrella's item 6 acceptance, postponing the foreign
    distribution check that exposed earlier archive problems.

#### Recommended option for Q07 (with arguments for this choice)

Option G1: The umbrella already permits a plain Debian 12 container for the
archive checks. Use that acceptance boundary with an explicitly confirmed host
and candidate identity, retaining the actual pipeline run in item 7. Selecting
this option does not assert that the required host is already available.

#### Answer to Q07: option G1 (with reason why it must be accepted as the answer)

Option G1: This retains Debian acceptance within item 6 without requiring a
release publication. Completion still depends on establishing the environment
and retaining successful relocated SQLite and provider evidence there.
