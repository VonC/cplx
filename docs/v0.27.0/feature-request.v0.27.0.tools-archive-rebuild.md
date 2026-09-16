# Rebuild, validate and publish the tools archive

- Type: feature-request
- Version: v0.27.0
- Slug: tools-archive-rebuild
- Draft: [Approved tools archive draft](draft.v0.27.0.tools-archive-rebuild.md)
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md

## Requirement origin for the final tools archive

As the maintainer of the application build and deployment toolchain, I want
one rebuilt tools archive that works on the Debian Jenkins agent and the RHEL
deployment servers, so that the application can run its tests with coverage
and testmon, use the supported Python interpreter with SQLite, and retire its
temporary pipeline repairs without breaking RHEL deployment or operator use.

This is item 7 of the
[Debian agent tools umbrella](draft.v0.27.0.debian-agent-tools.md). Items 1 to 6
are completed and their validation plans report `Yes, it is implemented.`.
They supply the installer copy fallback, RPATH relocation, Python wrapper
isolation, runtime closure gate, architecture-minor fallback and SQLite
integration. This requirement combines those inputs into the final release
artifact rather than reopening their implementation decisions.

The approved draft regroups the umbrella's rebuild, validation and publication
section, D1 and D5, the measurements consumed by item 4's D10 policy, and the
archive checks transferred from item 2 on 2026-08-29. That scope correction
moved archive-content assertions here because item 2 could validate its
relocation pass against the old archive but could not remove its residual
objects. This item must discharge those assertions against the rebuilt archive.

The author's clarification confirms that Debian tests with coverage belong
to this item's final acceptance. SQLite implementation belongs to completed
item 6; removing the consuming pipeline's disabling flags belongs to that
application repository and is coordinated with archive adoption.

## Current delivery state before the v0.27.0 release rebuild

The published baseline recorded by the umbrella is
`PDF-9.13.4-tools.tar.gz`, containing Python 3.13.9, Git, patchelf and the
packaging/relocation scripts. CI still relies on that archive and its
temporary repairs until the application release carrying the replacement.
The baseline evidence includes a Python without `_sqlite3`, a wrapper that
exposed foreign host helpers to shipped libraries, and installer and
library-resolution gaps addressed by the completed items.

Item 6 subsequently validated a separate non-release Python 3.13.15 build
with SQLite support. Its success establishes the integration mechanism and
its own acceptance, not acceptance of the final release archive. The
qualification Q06/F1 in
[the SQLite requirement](feature-request.v0.27.0.python-sqlite-support.md)
leaves the final payload refresh, regression re-check, release rebuild and
repeated SQLite acceptance with this item.

The build account is on RHEL 9.8 and compiles against sandbox RPM payloads
from rolling CentOS 9 Stream mirrors. RHEL 9.8 targets consume the deployed
archives. Jenkins uses throwaway Debian 12 containers with glibc 2.36 to
consume relocated tools, check out the application, run tests, and package
and publish the application without compiling the tools.

[The environment reference](reference.environments.md) records the roles and
their evidence boundaries. RHEL injects `/lib64/liboneagentproc.so` through
system preload; Debian does not. Existing working RHEL behavior must survive
the refresh of shipped libraries, including glibc.

## Changes required to deliver the tools archive

1. Refresh the sandbox payloads using the completed architecture-resolution
   behavior, then rebuild the explicitly selected Python 3.13 interpreter
   with the completed SQLite integration.
2. Package the refreshed tree through `pkg_tools`, applying the completed
   runtime closure and coherence gate and resolving all publication waivers.
3. Remove archive residuals and discharge the acceptance deferred by item 2.
4. Validate the identified final artifact across Debian and RHEL, including
   Debian tests with coverage and testmon and conclusive ABI evidence.
5. Publish the accepted tools artifact at the next application release version
   and coordinate the consuming project's pin, first integration run and
   removal of temporary repairs.

## Confirmed interpreter and payload rules

The native RHEL build and installation-time relocation model remains.
Dependency packages are unpacked into cplx sandbox roots without administrator
rights or installation into the host OS. The release rebuild refreshes the
RPM payloads because the stream mirrors have rolled since the published
baseline; it must build against one coherent set. Use item 5's resolved
curated lists and mirrors and its detected-architecture index. Do not restore
duplicated minor-version definitions as the rebuild mechanism.

D5 retains Python 3.13.14 as the settled release-build baseline. Immediately
before the release rebuild, check Python 3.13.15 for regression reports and
select it if clean. Python 3.13.10 is excluded. The tracked 3.13.15 pin and
item 6's non-release validation are not evidence that this release-time
re-check has happened.

Retain the checked upstream release and regression sources and the check date
with the selected version in the release evidence. Select 3.13.15 when no
known unresolved regression blocks required application or toolchain behavior.
A relevant regression selects the 3.13.14 baseline; inconclusive evidence
leaves selection unresolved until reviewed. Either version still owes the
complete final-archive acceptance. This does not require upstream to have
no outstanding bugs unrelated to the required behavior.

Set `CPLX_VERSION` explicitly; `CPLX_URL` already contains `[version]`.
Do not delegate this selection to `python_repository` tag discovery, which
the umbrella records as selecting 3.14.x. The consuming application requires
`>=3.13, <3.14`, with its lock selecting `==3.13.*`. D8 leaves Python 3.14
to another cycle. Git does not require a rebuild for this effort.

The final Python must retain item 6's SQLite integration, including the
compiled `_sqlite3` extension and its shipped runtime provider. Repeat the
SQLite acceptance on the final archive, retaining its interpreter version
and payload/archive identity with the evidence. Do not substitute the earlier
validation artifact for this acceptance.

Carry forward item 6's acceptance of a file-backed create/write/commit/close/
reopen/read round trip and a conclusive same-process observation of the
loaded SQLite provider under the applicable Python tree, on the build account,
Debian after relocation and RHEL after deployment. Import success alone does
not satisfy that existing contract. If the final permitted Python version
changes, align its declared version subdirectory and renew its matching
identity envelope, preserving `root`, `current`, the SQLite floor and the
refusal of undeclared historical version directories.

Refresh the live tree and package through `pkg_tools`, the front end of
`pkg.sh tools`. Keep `~/pkgs/tools.<stamp>.tar.gz` as the output naming
convention, including `.env`, `.env_` and the relocation scripts. The Maven
coordinate is a publication concern and does not replace timestamp naming.

## Confirmed closure and publication eligibility rules

Apply item 4's packaging gate over the complete resolution scope, not only
`root/usr/lib64`. Every required version node must be defined by its shipped
provider. Keep libc and the other library families coherent, including
matching libssl/libcrypto providers, and prune superseded generations such
as the two libbfd builds recorded in the old archive.

The evidence must distinguish an actual absent provider from incomplete
inventory or isolated root-object probing. develop#24 found `libgcc_s.so.1`
through `root/lib64/libgcc_s-11-20240719.so.1` under Python and Git, although
an earlier single-directory inventory had missed it. Of 388 inventoried
ELFs, zero wheels remained flagged with the full search path, while 110
shipped libraries lacked their own RPATH, 55 per root. The eight reported
`OPENSSL_3.x` misses were subsequently settled by item 4's measured comparison:
every needed node was defined by a shipped libcrypto, and the old misses were
an isolation artifact. The final refreshed providers still owe their own
coherence evidence; do not treat the historical artifact as an unresolved
defect or as proof of a new payload.

Inherit item 4's settled runtime scope for release verification. Recognized
Dynatrace OneAgent libraries are excluded monitoring objects wherever
injected, including build, CI and deployment. They and the raw external-object
count remain visible; no version/digest pin or injection-provenance condition
is added. This is an existing scope exclusion, not a publication waiver.
Other external runtime providers, including host libc, loader, libpython,
libm and libgcc, still refuse. Empty inventories and monitoring-only
inventories are inconclusive. Preserve item 2's explicit virtual-kernel and
loader-name accounting; an unreviewed new outside-prefix provider is not an
acceptable exception merely because the document calls a library
"ABI-critical".

Preserve the completed loader-identity contract: existing loader paths and
aliases remain inside the tools tree, differing or broken providers refuse,
and installed duplicate-provider checking remains strict. Candidate Python,
Git and the application venv must execute the candidate runtime, with venv
base-prefix and base-executable identities resolved through wrappers and
symlinks. Retained helper programs with system interpreter paths are reported
separately, not used to claim that a loader alias is unnecessary.

The final archive must pass the SQLite floor and acceptance again. Item 6
owns removal of the SQLite waiver when a file named `libsqlite3.so.0` is
present under `tools/python` in the resolution scope. Any active item 4
waiver makes an archive a validation artifact and prohibits its publication,
even if packaging produced a file.

The declaration/envelope pair must also retain its source authority. Its
named source commit must be a real ancestor of the delivered implementation
history, resolvable in the publishing checkout, with the exact declaration
blob matching the carried digest. Record the source-envelope commit and the
final cplx release revision separately. `closure_config_authority_check()`
resolves the envelope's source; `closure_publish_step1()` separately resolves
the declaration at the supplied release commit and compares that digest with
the archive's envelope. An unresolvable source or release commit, or a digest
mismatch, blocks publication.

If the selected Python version or another permitted payload change alters
the declaration, repeat the established
[item 6 Step 3 renewal contract](plan.v0.27.0.python-sqlite-support.md#step-3-bind-the-candidate-layout-to-its-closure-declaration):
the declaration-only source snapshot, exact committed-blob digest, paired
declaration/envelope delivery, authorized tree-preserving retention merge
with the configured hooks, and a fresh single-branch clone proving source
resolution without a temporary source ref. Preserve that plan's concrete
authorization boundary for new auxiliary Git operations. Record the renewed
identity and distinguish the non-first-parent source snapshot from a valid
delivery bundle; an ordinary envelope-line edit does not renew authority.

For the current 3.13.15 declaration, item 6's
[Step 3 validation](plan.v0.27.0.python-sqlite-support.validation.md#analysis-of-step-3-implementation-state)
records the completed retention merge and fresh-clone proof on 2026-09-16.
The source is `13c80d572ba7bda91728806ad7dc11c53629a506`, retained by
`5f8d4d67ca549bb74e3bcbb798124d628c3d0619`; it is also an ancestor of this
item's starting history. This completed prerequisite is not outstanding
item 6 work. Item 7 must still demonstrate resolution from the checkout
actually used to publish, or repeat renewal and its proof if the declaration
changes.

D10 remains the conditional policy owned by
[the runtime closure requirement](issue.v0.27.0.toolchain-runtime-closure.md).
Once the final wheel and dependency set is fixed, this item supplies:

- Every shipped ELF recording `DT_NEEDED` on `libstdc++.so.6`, with its
  `GLIBCXX_` and `CXXABI_` needs compared with shipped `libstdc++`
  definitions, including the final wheels' measured demands.
- The separate comparison of `libgcc_s` against its `GCC_` needs.
- Evidence that GCC 11 `libstdc++.so.6.0.29` satisfies every demand, or,
  if it does not, evidence for the GCC 12 toolset payload with all item 4
  closure checks repeated against the new root. Packaging fails if neither
  generation satisfies the demands.

Zero spare version nodes is allowed. Satisfaction controls the choice,
not headroom or the host's capabilities. The recorded comparison is shipped
`GLIBCXX_3.4.29` versus the agent's `GLIBCXX_3.4.30` and `CXXABI_1.3.13`;
the final consumer/provider measurement supplies the release decision.

## Archive-content acceptance inherited from relocation

Use item 2's existing harness and preserve the scope correction in full:

| ID | Required result against the rebuilt archive |
| --- | --- |
| AR1 | No program absent from the archive's own record is selected by relocation. Remove the published `tools/python/root/a.out` residual, recorded on both distribution paths. |
| AR2 | The Step 4 handoff set is empty. Discharge every member, with its named owner, by removal or evidence that it is preserved after all. |
| AR3 | Migration positivity and case 5 equality, the three `$HOME` states, and force reinstall pass against the rebuilt archive. |
| AR4 | Discharged ownership-register entries are retired. Preserve item 2's exact comparison in both directions so a stale entry fails after its object is removed. |

## Platform acceptance for the identified final archive

The final archive must satisfy every required cell below using the completed
installer and wrapper, without pipeline repair shims or per-wheel patching.

| ID | Check | Debian 12 container | RHEL 9.8 build account or deployment target |
| --- | --- | --- | --- |
| PA1 | `install_pkg.sh` relocation without a shim | Required | Required, including redeploy over an existing prefix |
| PA2 | Wrapper `python3 --version`, including its first call | Required | Required |
| PA3 | `import ssl, zlib, sqlite3` and repeated item 6 SQLite acceptance on the final artifact | Required | Required, retaining the build and deployment role evidence |
| PA4 | Toolchain `git --version` | Required | Required |
| PA5 | Version-node coherence of shipped libraries and providers | Required | Required |
| PA6 | `uv sync`, then `import pymupdf, pikepdf`, without patching wheels | Required | Required |
| PA7 | Shipped loader `--list` over toolchain ELFs and venv wheels: no `not found`, missing version node or in-scope host runtime provider | Required | The downstream probe is optional; inherited item 4 closure rules still apply |
| PA8 | `LD_DEBUG=libs,versions` on venv Python importing the heavy wheels: no in-scope runtime dependency from a host path | Required, with conclusive trace inventory | The downstream probe is optional; inherited item 4 runtime-scope rules still apply |
| PA9 | Full application acceptance suite with the final archive's interpreter, coverage and testmon active, and the application's existing coverage threshold satisfied | Required | Optional; Windows development flow covers it |
| PA10 | `deploy_pkgs.sh` end to end, including readiness checks | Not applicable | Required |
| PA11 | Operator `senv` and `.env` sourcing | Not applicable | Required |

PA9 must show that previously SQLite-guarded suites execute. A successful
plugin import, a no-tests-selected testmon result or SQLite-availability skips
do not satisfy acceptance. Unrelated expected skips remain governed by the
application's existing rules. This qualification does not impose a new cplx
coverage threshold or prevent later incremental testmon use.

Read the static ABI listing and live trace together. The listing covers the
whole runtime search path; a root-object sweep alone can overstate host
fallback. The trace observes the venv Python directly, rather than merely
uv and an unverified child, and reports the trace files written and kept.
Observing no venv process or retaining no usable trace is inconclusive, even
when the output prints no host-library load. Include the D10 measurements
with this evidence.

The old downstream zero-of-388 reading is evidence for a specific inventory,
not an assumed size for the refreshed archive. Item 2 requires a reviewed
scope or target amendment and renewed validation when refreshed evidence
invalidates that measured scope. A validator may not silently exclude an
object to obtain zero flags.

Before immutable tools publication, the existing Debian 12 Jenkins agent must
pass the candidate integration chain, ABI checks and full PA9 acceptance
using item 6's established archive-copy validation route, with application
uploads disabled. That route must still be available and usable at release
time. Record the actual userland/container identity and transfer digest;
no extra SQLite payload or host package installation may make the final
candidate appear self-contained.

A plain `debian:12` container can supply supporting validation, but cannot
replace that pre-publication Jenkins qualification. After tools publication,
separately confirm retrieval and use through the new release pin on the real
agent, still with application snapshot upload disabled. This later run proves
the published artifact, its download and the startup pin together before
snapshot uploads resume. Neither run substitutes for the other, and no
intermediate Maven release is introduced.

## Validity of the final archive acceptance evidence

Associate acceptance with the archive identity, application revision,
dependency lock, resolved wheel set and observed platform/runtime identities.
A relevant change makes the affected acceptance results pending until
reassessed and repeated. Unchanged, demonstrably unaffected results may be
retained with a recorded reason rather than rerunning unrelated checks.

The maintainer operating this release records the affected-or-unaffected
assessment and the reason for each retained result in the release evidence.
An unchanged archive digest alone cannot carry old ABI or coverage evidence
forward when the consuming application's wheels or runtime have changed.

## File-based IO cost clarification

Read the selected archive-indexed release record directly; do not scan document
history or raw-capture directories to discover state. Resolve explicit evidence
references once per validation phase and reuse the collected identity map.
Retain required artifact hashing, ELF inventories and gate snapshots; reducing
IO must not remove byte-identity or completeness checks. Walk each declared
subject root once per measurement phase, keep provider and consumer inventories
separate, and stream publication bytes through the existing gate.

## Release publication and consuming-project adoption

D1 selects the next application release version and publication at release
time. Do not introduce a dedicated intermediate Maven version. CI retains
the existing archive and its interims until that release is available.

The consuming project's
`tools/publish_pdf_nexus.sh --with-tools --version <version>` publishes the
tools manually to the corporate Nexus hosted `releases` repository under
`com/company/PDF/<version>` with the `tools` classifier. The repository
forbids overwriting a release, so `9.13.4` cannot be rebuilt and redeployed.
Use a new release coordinate only after the pre-publication matrix passes
and no item 4 waiver remains active.

The publisher selects the newest local tools archive. Retain the association
between the accepted local artifact and the SHA-1 printed at publication.
If a newer, unqualified candidate becomes the selected archive, publication
cannot proceed under the earlier artifact's acceptance: select the accepted
bytes or qualify the replacement before publishing it.
Record the version at publication and in the consuming project's
`tools/tools.version`; the archive itself retains its timestamp name.
Jenkins reads the pin at pipeline startup, not from a configurable job
parameter or a Jenkinsfile constant.

The application also reads `tools/publish.mode` at startup. `snapshot`
enables application upload; any other value runs relocate, provision, package
and walk without publishing. Raise the tools pin with this switch off for
the first post-publication real-agent run, prove the chain and ABI probes, then restore
`snapshot` after acceptance. A failing walk still skips publication.

The consuming-repository handoff includes:

- Raising `tools/tools.version` to the published coordinate.
- Removing `Q26 INTERIM, REMOVE` repair blocks, including the per-wheel
  patchelf loop and dormant tools-patch fetch, and removing the rsync shim.
- Dropping `--no-cov` and `-p no:pytest-testmon` so coverage and testmon run.
  Coverage imports and the Q24 guarded suites self-enable when SQLite is
  available.
- Making the ABI contract probe blocking with zero expected flags while
  preserving the permanent build-test-publish gate.
- Optionally retiring the raw `python3*_bin` and `UV_PYTHON` bypass if uv
  works through the hardened wrapper; retaining it is allowed.

These are application-repository edits coordinated with adoption. Their
location does not make Debian coverage optional in this requirement.

If the published archive fails adoption, keep adoption incomplete and
application uploads disabled during failure handling. When the new archive
cannot pass, restore the known working pin and its compatible pipeline
settings/interims. Confirm that restored configuration before resuming normal
uploads. This may temporarily restore coverage-disabling settings; it does
not count as completion of this item.

Preserve the failed coordinate and its evidence. A corrected tools archive
requires a new eligible release coordinate and renewed acceptance; never
overwrite the failed release or silently qualify it with replacement bytes.

## Release acceptance and evidence for tools-archive-rebuild

| ID | Acceptance condition |
| --- | --- |
| RA1 | The final payloads are refreshed and coherent; the explicitly selected Python 3.13 version, dated upstream sources and conclusive release-time 3.13.15 regression decision are recorded with the final payload/archive identity. |
| RA2 | The final archive contains `_sqlite3` and its shipped SQLite provider, repeats item 6 acceptance, and passes every item 4 closure check with no active waiver. Its retained source-envelope commit resolves in the publishing checkout; any renewed declaration has the required source identity, retention and clone proof. The separately recorded release commit resolves to the declaration digest carried by the archive. |
| RA3 | D10 consumer/provider evidence covers the fixed final wheel and dependency set; the selected runtime satisfies all demands or packaging fails. |
| RA4 | All AR1-AR4 archive-content assertions and all required PA1-PA11 platform cells pass with conclusive static and runtime evidence. The existing Jenkins agent passes the candidate integration chain, ABI checks and full PA9 acceptance before immutable publication, with application uploads disabled. |
| RA5 | Publication uses the next application release coordinate, preserves local timestamp naming and accepted-artifact traceability, and does not overwrite a release. |
| RA6 | The first post-publication consuming-project real-agent run uses the new pin with snapshot upload disabled and confirms published-artifact retrieval and use, the chain and ABI probes before snapshot upload is re-enabled. The coordinated pipeline changes restore coverage/testmon and retire the applicable interims. |
| RA7 | Acceptance identifies the archive, application revision, lock, resolved wheels and platform/runtime state; relevant changes repeat affected checks, with the release maintainer recording the assessment and reasons for retaining unaffected evidence. |
| RA8 | Failed adoption remains incomplete, preserves its coordinate and evidence, and follows the verified prior-configuration recovery rule. A corrected archive requires a new eligible release coordinate and renewed acceptance. |

## Implementation references and scope boundaries

- `src/setups/env/bin/pkg_tools.sh`: existing front end of `pkg.sh tools`
  for producing the timestamped archive.
- `src/setups/env/bin/install_pkg.sh`: completed installation and relocation
  behavior exercised by this item's archive and platform acceptance.
- `src/install/env/python/python_install_functions.sh`: completed Python
  configure integration for the SQLite-enabled rebuild.
- `src/install/env/python/bin/python`: completed wrapper behavior exercised
  on the first interpreter call and subsequent operator/venv use.
- [Item 2 requirement](issue.v0.27.0.relocation-force-rpath.md): relocation
  contract and the existing harness assertions inherited by this item.
- [Item 4 requirement](issue.v0.27.0.toolchain-runtime-closure.md): closure,
  waiver and D10 policies consumed by the final packaging and release.
- [Item 5 requirement](feature-request.v0.27.0.architecture-minor-fallback.md):
  dependency-input resolution used during refresh.
- [Item 6 requirement](feature-request.v0.27.0.python-sqlite-support.md):
  completed SQLite integration and acceptance repeated on the final archive.

This requirement owns final refresh, release rebuild, archive cleanup,
validation, publication and the consuming-project handoff. Python 3.14 and
free-threading, a replacement agent image, agent-image additions, the
application's uv requirements pin, and the separate rsync symlink-destination
follow-up remain outside this item. It does not reopen the completed
implementation decisions of items 1 to 6.

## Requirement clarifications

The author selected `Consolidate` after independent specification review
converged in round 2, accepting option A for Q01 to Q05.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | Keep dated upstream sources with the version decision. Choose 3.13.15 absent a known relevant blocking regression, fall back to 3.13.14 for a relevant regression, and resolve uncertainty before selection. This preserves D5's fresh qualification. | Confirmed interpreter and payload rules; RA1 | Falling back automatically when evidence is inconclusive converts missing information into a release decision. |
| Q02 | Run the full application acceptance suite on Debian with the final archive's interpreter, coverage and testmon active, the existing coverage threshold met, and SQLite-dependent suites executed. | Platform acceptance; PA9 and RA4 | Plugin availability or an incremental run selecting no tests leaves the restored capability unproven. |
| Q03 | Bind acceptance to the archive and its consuming application, dependency and runtime identities. The release maintainer records change impact, repeats affected checks and explains retained results. | Validity of the final archive acceptance evidence; RA7 | Treating unchanged archive bytes as sufficient permits stale wheel, ABI or coverage evidence. |
| Q04 | Require candidate qualification on the existing Jenkins agent before immutable publication, using the available validation route, and separately confirm the published release pin afterward. | Platform acceptance; release publication; RA4 and RA6 | Plain-container qualification alone can expose Jenkins-specific failures only after consuming an immutable coordinate. |
| Q05 | Keep failed adoption incomplete and uploads off during recovery; restore and verify the known working configuration before normal uploads resume. Preserve the failure and use a new eligible coordinate for a corrected archive. | Release publication and consuming-project adoption; RA8 | Keeping the failing pin indefinitely can block otherwise working application delivery. |
