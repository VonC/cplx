# Build the toolchain python with sqlite

- Type: feature-request
- Version: v0.27.0
- Topic: python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md

## User story for Python SQLite support

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

Each accepted interpreter must also create a small file-backed database, write
and commit data, close it, then reopen it and read the expected data. Run this
round trip through the toolchain invocation used by operators, including its
deployed or relocated invocation as applicable.

The build and deployed interpreter must preserve their existing independence
from host SQLite installations. A successful import that relies on a library
available only on the host does not satisfy the archive contract.

Retain a conclusive observation after a SQLite operation in the same process
showing that the loaded `libsqlite3.so.0` resolves under the built, deployed or
relocated `tools/python` tree. A trace showing no SQLite load is inconclusive.
Record this provider evidence with the database round trip on every accepted
environment. Both named distributions have recorded host SQLite copies that
can hide a resolution gap: `/usr/lib64/libsqlite3.so.0` on RHEL and
`libsqlite3-0 3.40.1` on the Debian Jenkins agent.

## Target scope and build-success contract for Python SQLite

SQLite is mandatory for the RHEL 9 x86_64 build family and its named Debian 12
and RHEL 9.8 consumers. Shared Python install changes must preserve other
targets' configure and build results, including targets whose package lists
have no SQLite payload. This item does not establish a SQLite guarantee for
every historical build target.

An in-scope build must refuse successful completion if `_sqlite3` is missing
from its built `lib-dynload`, or if the built interpreter cannot import
`sqlite3` against the sandbox payload. Its diagnostic must name the missing
capability. A later manual acceptance check cannot substitute for this build
result; the existing library floor does not prove the extension was compiled.

## Existing-tree rebuild behavior for Python SQLite

Support and document an explicit rebuild from the populated Python tree that
forces both reconfiguration and recompilation while preserving unrelated
reusable sandbox payloads. The existing workflow skips configuration while
`config.log` exists, and `build()` skips `make` while a compiled `python`
exists. The documented path must overcome both conditions and produce a
verified SQLite-capable interpreter. Automatic capability-triggered rebuild
detection is outside this item's scope.

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

The implementation adds `-Wl,--enable-new-dtags` to that scoped link setting.
The real promotion check established that `_sqlite3` must use `DT_RUNPATH`
so the existing wrapper can select the shipped library after promotion while
the original build sandbox still exists. The owning design records this fix.

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
   entry and the existing packaging checks. Replace the declared Python
   3.13.9 subdirectory with the candidate's 3.13.15 subdirectory, retaining
   `root` and `current` and renewing the matching closure envelope.
5. Demonstrate the SQLite acceptance on the build account, Debian after
   relocation, and RHEL after deployment, retaining evidence for item 7.

## SQLite closure contract with the completed runtime-closure item

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

The human-confirmed design Q06 J1 also corrects the candidate's declared
version shape: replace `subdir|python|python-3.13.9` with
`subdir|python|python-3.13.15`, retaining the Python `root` and `current`
subdirectory declarations. Do not retain the historical version declaration.
The checker still rejects undeclared immediate directories, including a
retained `python-3.13.9`; `current` alone does not declare its version target.
Renew the identity envelope with the declaration under the existing exact-byte
digest and source-identity contract.

This correction records the entry change required by the
[closure ownership rule](../../src/setups/env/closure/README.md) before the plan
relies on it. It preserves the SQLite floor and waiver-removal condition and
the approved 3.13.15 non-release candidate. Item 7 must align the declaration
again if its final permitted Python version changes.

## Acceptance criteria for Python SQLite support in v0.27.0

| ID | Required result |
| --- | --- |
| AC1 | The Python sandbox contains `sqlite3.h`, the `libsqlite3.so` linker symlink and `libsqlite3.so.0` from the selected SQLite RPM payloads. Existing SQLite dependency-list entries are retained. |
| AC2 | CPython receives the explicit sandbox SQLite configure settings. `checking for stdlib extension module _sqlite3` answers `yes`, and `_sqlite3` is absent from the final necessary-bits-not-found summary. |
| AC3 | The archive contains the compiled `_sqlite3` extension in Python's `lib-dynload` and `libsqlite3.so.0` under `tools/python/root/usr/lib64`; neither file is supplied solely by the host. |
| AC4 | On the RHEL build account, Debian 12 after relocation and RHEL 9.8 after deployment, the operator's toolchain invocation imports `sqlite3` and completes a file-backed create/write/commit/close/reopen/read round trip. A conclusive observation after a SQLite operation in the same process identifies the loaded `libsqlite3.so.0` under the applicable `tools/python` tree. A trace showing no SQLite load cannot pass. |
| AC5 | The existing closure location test finds `libsqlite3.so.0` under `tools/python` in the resolution scope. The satisfied SQLite waiver is removed and its floor entry is retained. The Python subdirectory declaration replaces `python-3.13.9` with `python-3.13.15`, retains `root` and `current`, and travels with its renewed matching identity envelope. |
| AC6 | The existing packaging contract continues to reject a missing unwaived SQLite floor member, a copy only under `tools/git`, a stale SQLite waiver after the removal condition is satisfied, and undeclared directories, including a retained `python-3.13.9` under the corrected declaration. |
| AC7 | An in-scope Python build refuses success with a capability diagnostic when the built `_sqlite3` extension is absent or the built interpreter cannot import `sqlite3` against its sandbox payload. |
| AC8 | Other targets retain their existing configure and build results, including when their dependency lists have no SQLite payload. |
| AC9 | The documented explicit rebuild works from the populated tree, forces both reconfiguration and recompilation, preserves unrelated reusable sandbox payloads and produces a verified SQLite-capable interpreter. |
| AC10 | Item 6 records its non-release candidate's Python version and payload/archive identity on the tracked 3.13.15 pin. Item 7 applies D5's release regression re-check and repeats SQLite acceptance on the final rebuilt archive. |
| AC11 | Before candidate acceptance, the existing Debian 12 Jenkins container and archive-copy route are confirmed. Retained evidence identifies the host role, actual image digest and archive and demonstrates AC4 after relocation, with only the candidate toolchain and verification material supplied by this test. Missing environment or Debian evidence prevents item 6 completion. |

## Debian acceptance environment for the unpublished SQLite candidate

The owner's execution clarification on 2026-09-16 selects the existing Debian
12 Jenkins agent, reached by a script called from the consuming Jenkinsfile
and an explicitly triggered job. This replaces the earlier separate plain
`debian:12` route. Compile only on RHEL; Debian deploys and tests the same
identified archive. Record actual userland, image/container identity, transfer
digest and normal SQLite/provider observations. Supply no extra SQLite library
or package installation to make acceptance pass. Use existing access and keep
release publication disabled.

If this runtime or its required evidence cannot be established, retain that
gap and leave item 6 incomplete. The final release archive and full application
integration acceptance remain with item 7.

## SQLite delivery boundary within the umbrella

Item 6 owns the SQLite integration, a separate non-release validation rebuild
on the tracked 3.13.15 pin, and focused acceptance evidence. Record that
candidate's Python version and payload/archive identity. This confirmed Q06
choice qualifies D5's original single-rebuild decision: the extra item 6 build
establishes the capability before item 7's release rebuild.

Item 7 (`tools-archive-rebuild`) retains the final sandbox refresh, release
archive rebuild, complete cross-distribution validation matrix and publication.
It applies D5's existing release-version rule: 3.13.14, or 3.13.15 if its
pre-rebuild regression re-check is clean; never 3.13.10. The current 3.13.15 pin
does not prove that re-check was performed. Item 7 repeats SQLite acceptance on
the final archive, including if the re-check selects 3.13.14 or the payload
refresh changes its inputs. The approved extra validation rebuild is recorded
beside D5 in the umbrella.

This cycle retains the Python 3.13 line required by the application's
`>=3.13, <3.14` constraint. A move to Python 3.14 remains a later-cycle topic.
The preceding items own wrapper hardening, relocation, architecture fallback
and the closure checker.

After the consuming repository adopts the resulting archive, it can remove
`--no-cov` and `-p no:pytest-testmon`. The degraded `conftest_coverage` import
and Q24 skip guards self-enable once SQLite is available. Those pipeline edits
and its tools-version pin belong to that repository and the release handoff;
this requirement makes the necessary interpreter capability available.

## File-based IO cost clarification for Python SQLite support

SQLite validation uses a bounded temporary file-backed database operation and
one same-process provider observation. It must not add repeated whole-tool-tree
scans or automatic cache invalidation to builds. Preserve reusable sandbox and
unrelated tool payloads, and retain candidate byte-identity checks at transfer
boundaries. No interactive latency threshold is required by this feature.

## Requirement clarifications

The human confirmed the seven reviewed recommendations after specification
review round 2. All answers are integrated in this document; no open questions remain
for the requirement phase.

Design consolidation adds the matching closure-entry correction authorized by
the human's confirmation of design Q06 J1. The `Design Q06` row below records
that cross-document correction separately from requirement Q06's candidate
and release boundary.

| Question | Decision and reason | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | A1: Require SQLite for the RHEL 9 x86_64 build family and named consumers, preserving other targets including those without SQLite payloads; this matches the umbrella's scope. | Target scope and build-success contract; AC8 | A2: Guaranteeing every target would add unrelated dependency and acceptance work. |
| Q02 | B1: Refuse success for missing or unusable SQLite on in-scope builds with a capability diagnostic, preventing the original silent omission. | Target scope and build-success contract; AC7 | B2: Acceptance-only rejection would leave nominally successful builds without the required capability. |
| Q03 | C2: Require a persistent database round trip through the operator invocation, alongside provider evidence, to establish usable database behavior. | Expected SQLite behavior; AC4 | C1: Import alone does not prove persistence. C3: The consuming application's complete test run belongs to the integration handoff. |
| Q04 | D2: Require conclusive same-process evidence of the shipped provider after a SQLite operation on every accepted environment; host copies can hide a gap. | Expected SQLite behavior; AC4 | D1: Static closure plus an operation does not directly identify the loaded provider. |
| Q05 | E1: Document an explicit existing-tree rebuild forcing reconfiguration and recompilation while retaining unrelated payloads, covering the actual upgrade case. | Existing-tree rebuild behavior; AC9 | E2: Automatic capability-triggered rebuilding extends scope. E3: Fresh-tree-only acceptance leaves the existing build account unsupported. |
| Q06 | F1: Add an identified 3.13.15 validation candidate before item 7's final rebuild, explicitly qualifying D5; this keeps item 6 independently completable at the cost of another rebuild. | SQLite delivery boundary; AC10; umbrella D5 | F2: Moving D5's regression re-check and refresh into item 6 would change item 7's delivery responsibility. |
| Q07 | Updated by the owner on 2026-09-16: use the existing Debian 12 Jenkins container for deployment/runtime testing, with the same RHEL-built archive and retained actual identities. | Debian acceptance environment; AC11 | The earlier plain-container route is superseded by confirmed Jenkins access. Deferring Debian evidence still conflicts with item 6's scope. |
| Design Q06 | J1: The candidate's accepted closure shape replaces Python 3.13.9 with 3.13.15, retaining `root`, `current` and the SQLite floor, with a renewed envelope alongside waiver removal. This records the owning requirement's entry change before planning. | SQLite closure contract; gap item 4; AC5, AC6 | J2: Retaining both versions admits an unnecessary historical directory. An unchanged or current-only declaration cannot cover the candidate. |

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
