# Design v0.27.0: Python SQLite support

Reference feature request:
[feature-request.v0.27.0.python-sqlite-support.md](feature-request.v0.27.0.python-sqlite-support.md)

Umbrella: [Debian agent tools](draft.v0.27.0.debian-agent-tools.md), item 6.

## Context for the v0.27.0 SQLite design

The archive's historical Python omitted its compiled `_sqlite3` extension.
SQLite payload entries are already present, but the build does not explicitly
select them or reject a Python without the required capability. This design
connects sandbox inputs, build completion, archive closure and executable
acceptance evidence. The requirement's seven clarifications and this design's
six decisions are confirmed. The matching requirement correction records the
candidate's closure version declaration before planning.

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

The policy key is the existing declared build family,
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

The structure keeps SQLite policy with Python's install support.
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
the check. One shared Python probe performs the database operation and provider
observation, with explicit stage and independently supplied expected-root inputs.
Callers select the actual toolchain interpreter, enforce each stage's extension
location, and retain the environment, invocation and candidate evidence. The
probe uses that interpreter's standard library and needs no host Python package
installation; its presence as verification material is a prerequisite.

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

The observer reads `/proc/self/maps`. Linux documents mapped files
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
currently names `python-3.13.9`. Replace that version
record with `subdir|python|python-3.13.15` and retains `root` and `current`.
The checker compares declared and observed immediate subdirectories, so
declaring `current` alone would not cover the actual version directory.
Preserve rejection of undeclared directories, missing or misplaced SQLite,
and stale SQLite waivers.

The [closure ownership contract](../../src/setups/env/closure/README.md) requires
the owning requirement to state an entry change. The requirement's closure
contract and AC5 now record the exact `subdir|python|python-3.13.9` to
`subdir|python|python-3.13.15` replacement alongside waiver removal, following
the human's confirmation of design Q06 J1. Retain `root` and `current`, and
regenerate the envelope with the changed declaration under its existing
exact-byte and source-identity rules. A retained `python-3.13.9` directory is
UNEXPECTED under the new declaration; do not widen the accepted directory set
to accommodate it. Item 7 must align the declaration with its final permitted
Python version again if that version changes.

A candidate record ties together the cplx source revision, Python version,
selected package/payload identities, archive digest and closure bundle identity.
The build-account result and the two consumer results refer to that candidate;
similar filenames alone do not connect evidence to bytes. This is an item 6
validation archive, with no release coordinate or publication operation.

## Isolated assembly and deployment of the SQLite candidate

The assembly boundary is an isolated account home or equivalent
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
If that route cannot be established, acceptance remains blocked. Live-tool
replacement is outside this acceptance route, following the isolated-target
precedent in item 5. The plan supplies the exact setup and preservation commands.

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
| Candidate contains `python-3.13.15` with `root` and `current` | Replacement declaration and renewed envelope describe that candidate. | AC5 |
| Candidate retains an undeclared `python-3.13.9` directory | Existing UNEXPECTED rejection retained. | AC5, AC6 |
| Assembly or deployment isolation cannot be proven | Acceptance remains blocked, with live-tree preservation evidence required. | AC10 |
| Candidate identity or Debian environment evidence is absent | Item 6 remains incomplete. | AC10, AC11 |
| Item 7 refreshes payloads or selects a different permitted patch | Repeat SQLite acceptance on that final archive. | AC10 |

## Design decisions for Python SQLite support

The human confirmed the six reviewed recommendations after design review
round 2. Their answers are integrated below and in the referenced sections;
no further design question is required before the implementation plan.

| Question | Decision and reason | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | A1: Use the declared `CPLX_ARCH_EXT=el9.x86_64` family for configure and capability checks, retaining existing missing-value failures and recording the actual host in acceptance. One policy key keeps both stages aligned. | Target policy and sandbox selection | A2: A separate native-host classifier could disagree with dependency and archive selection. |
| Q02 | B1: Keep Python's source check and add an optional tool-owned post-install callback after installation or reuse and before packaging. Propagate failure through `main` before `current` advances. | Capability checks at Python build completion | B2: A Python-specific branch would embed SQLite policy in the shared driver. |
| Q03 | C1: Observe `/proc/self/maps` in the process that completed the database operation, matching the shipped provider's canonical backing-file identity within independently supplied canonical roots. Ambiguous or unavailable evidence cannot pass. | SQLite provider and database acceptance evidence | C2: Loader traces need extra interpretation and remain diagnostic material only. |
| Q04 | D1: Share one standard-library Python probe with explicit stage and expected-root inputs. Callers own interpreter selection, extension location and capture; build-environment capability and operator-invocation runtime-path acceptance remain distinct. | Capability checks at Python build completion; SQLite provider and database acceptance evidence; Acceptance environments and the item 7 handoff | D2: Separate validators could diverge on database and provider pass rules. |
| Q05 | H2: Isolate the complete assembly layout and RHEL deployment target, prove path and login-profile boundaries before use, and retain before/after live-tree evidence. Keep the packager's private source stage. | Isolated assembly and deployment of the SQLite candidate | H1: Live-tree promotion replaces operator tools and deletes historical versions. H3: A caller-source override changes the packaging contract beyond this item. |
| Q06 | J1: Replace the 3.13.9 declaration with 3.13.15, retaining `root` and `current`, and renew the envelope with the declaration. The owning requirement correction is recorded before planning so the candidate has the exact accepted version shape. | Archive closure and candidate identity; requirement closure contract and AC5 | J2: Keeping both version records admits an unnecessary historical directory. An unchanged or current-only declaration cannot cover the candidate under the existing checker. |
