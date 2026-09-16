# Rebuild, validate and publish the tools archive

- Type: feature-request
- Version: v0.27.0
- Slug: tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md

## Selected umbrella item

| Order | Type | Key title | Slug | Status | Requirement | Validation plan |
| --- | --- | --- | --- | --- | --- | --- |
| 7 | Feature-request | Rebuild, validate and publish the tools archive | `tools-archive-rebuild` | pending | - | - |

This item regroups the umbrella's rebuild, validation and publication section,
decisions D5 and D1, the D10 measurement owed to item 4, and the archive checks
transferred from item 2 on 2026-08-29. It depends on items 1 to 6. Their
requirements and validation plans are recorded in the umbrella; all six are
completed, with `Yes, it is implemented.` as their validation verdict.

## Purpose and environment

Produce the final tools archive combining the completed installer fallback,
RPATH relocation, foreign-distribution Python wrapper, runtime closure gate,
architecture-minor fallback and SQLite support. Refresh the sandbox payloads,
rebuild the interpreter, package the result, validate it on both distributions,
and publish it with the next application release.

The existing published baseline is `PDF-9.13.4-tools.tar.gz`, containing Python
3.13.9, Git, patchelf and the packaging/relocation scripts. The consuming
project keeps that archive and its pipeline interims until the release carrying
the replacement is published. Completion of an input item, including item 6's
non-release SQLite validation build, does not establish final-archive acceptance.

The archive serves three roles:

- The build account on a RHEL 9.8 deployment server compiles against sandbox
  RPM payloads from the rolling CentOS 9 Stream mirrors.
- RHEL 9.8 deployment targets must retain their existing behavior, including
  redeployment over an existing prefix and interactive operator use.
- Throwaway Jenkins containers with Debian 12 userland and glibc 2.36 consume
  the relocated tools, check out the application, run tests, and package/publish
  the application without compiling the tools.

[Environment reference](reference.environments.md) identifies the hosts and
what each can prove. RHEL injects `/lib64/liboneagentproc.so` through system
preload; Debian does not. Preserve working RHEL behavior when refreshing the
shipped glibc rather than assuming both environments have identical isolation.

The native RHEL build and installation-time relocation model stays in place.
cplx works without administrator rights and without installing packages into
the host OS: dependency payloads are unpacked into its sandbox roots.

## Final refresh, interpreter rebuild and packaging

Use the completed items 1 to 6 as inputs. Refresh the sandbox RPM payloads
before the release rebuild: the stream mirrors have rolled since 9.13.4, and
the shipped root must be one coherent snapshot. Use item 5's resolved curated
lists/mirrors and detected-architecture index rather than restoring duplicated
minor-version definitions.

Rebuild Python with the SQLite integration supplied by item 6. Git does not
need a rebuild for this effort. Keep the final interpreter version and
payload/archive identity associated with the validation evidence, and repeat
SQLite acceptance on the final archive even though item 6 already passed its
separate non-release validation.

D5 retains Python **3.13.14** as the settled release-build baseline, with
**3.13.15 to be checked for regression reports immediately before the release
rebuild and selected if clean**. Never select 3.13.10. The umbrella records
that its regressions required an expedited successor; the re-check is part of
this item's work, not a conclusion established by this draft.

The human-confirmed Q06/F1 qualification in
[item 6's requirement](feature-request.v0.27.0.python-sqlite-support.md)
allowed a separate non-release validation rebuild on the tracked 3.13.15 pin.
That pin and validation do not prove the release-time regression re-check.
This item retains the final refresh, version re-check, release rebuild and
repeated SQLite acceptance.

Set `CPLX_VERSION` explicitly; `CPLX_URL` already uses the `[version]`
placeholder. Do not leave version selection to `python_repository` tag
discovery, which the umbrella records as selecting 3.14.x. The application
requires `>=3.13, <3.14` and its lock selects `==3.13.*`. D8 defers Python
3.14 to another cycle.

Refresh the live tree and package through `pkg_tools`
(`src/setups/env/bin/pkg_tools.sh`, the front end of `pkg.sh tools`). The
output remains `~/pkgs/tools.<stamp>.tar.gz`, including `.env`, `.env_` and
the relocation scripts. Maven release coordinates do not change this local
timestamp naming convention.

## Runtime closure, waivers and C++ evidence

Apply item 4's existing packaging-time closure and coherence checks to the
final root over the complete resolution scope, not only `root/usr/lib64`.
Every required version node must be defined by its shipped provider; this
includes libc coherence, matching libssl/libcrypto families and removal of
superseded generations such as the two libbfd builds in the old archive.

The discovery evidence explains the required breadth. develop#24 inventoried
388 ELFs: zero wheels remained flagged once the probe used the complete
runtime search path, while 110 shipped libraries lacked their own RPATH
(55 per root). `libgcc_s.so.1` was present through
`root/lib64/libgcc_s-11-20240719.so.1` under both Python and Git. The eight
reported `OPENSSL_3.x` misses needed re-probing after item 2's library-wide
RPATH pass before treating them as a real libssl/libcrypto mismatch.

The final archive must carry the `_sqlite3` extension and its shipped runtime
provider. Item 6 owns removal of the SQLite waiver when a file named
`libsqlite3.so.0` is present under `tools/python` in the resolution scope.
Its completed validation is an input; this release archive must pass the
closure gate and SQLite acceptance again.

**Any active item 4 waiver makes the packaged archive a validation artifact
and prohibits publication.** This item enforces that refusal; an incomplete
archive must not become publishable merely because packaging produced a file.

D10 remains the conditional policy owned by
[item 4](issue.v0.27.0.toolchain-runtime-closure.md). This item supplies its
evidence once the final wheel and dependency set is fixed:

- Inventory every shipped ELF recording `DT_NEEDED` on `libstdc++.so.6` and
  measure its `GLIBCXX_` and `CXXABI_` needs against the shipped `libstdc++`
  definitions. Measure the final wheels' real demands as part of that reading.
- Check `libgcc_s` separately against its `GCC_` needs.
- Keep GCC 11 `libstdc++.so.6.0.29` if every demand is satisfied. If not,
  use the GCC 12 toolset payload and rerun all item 4 closure checks against
  the new root. If neither generation satisfies the demands, packaging fails.
- Zero spare version nodes is allowed: satisfaction, not headroom, controls
  the choice. The recorded baseline is shipped `GLIBCXX_3.4.29` versus the
  Debian agent's `GLIBCXX_3.4.30` and `CXXABI_1.3.13`; host capabilities are
  not a substitute for the shipped provider's definitions.

## Archive checks inherited from item 2

The 2026-08-29 scope correction moved these assertions here because the
rebuilt archive is the first artifact that can satisfy them. Preserve their
strength and consume item 2's existing harness:

- No program absent from the archive's own record may be selected by the
  relocation pass. Remove `tools/python/root/a.out`, confirmed in the
  published archive on both distribution paths.
- The Step 4 handoff set must be empty against the rebuilt archive. Discharge
  every member, whose owner item 2 names, by removal or by evidence that it
  is preserved after all.
- Run the criteria deferred until the rebuild: migration positivity and case
  5 equality, the three `$HOME` states, and force reinstall.
- Retire discharged ownership-register entries. Item 2 checks the register
  exactly in both directions, so removing an object while keeping its stale
  deferral must fail until the register is updated.

## Validation before publication

Run the full matrix against the identified final archive, using the completed
installer and wrapper without pipeline repair shims or per-wheel patching.

| Check | Debian 12 container | RHEL 9.8 build account or deployment target |
| --- | --- | --- |
| `install_pkg.sh` relocation without a shim | Required | Required, redeploy over an existing prefix |
| Wrapper `python3 --version`, including its first call | Required | Required |
| `import ssl, zlib, sqlite3` | Required | Required |
| Toolchain `git --version` | Required | Required |
| Version-node coherence of shipped libraries and providers | Required | Required |
| `uv sync`, then `import pymupdf, pikepdf`, without patching wheels | Required | Required |
| Shipped loader `--list` over toolchain ELFs and venv wheels: no `not found`, missing version node or host-resolved ABI-critical library | Required | Not applicable to the host-fallback verdict; host copies are compatible |
| `LD_DEBUG=libs,versions` on the venv Python importing the heavy wheels: no ABI-critical library initialized from a host path | Required, with conclusive trace inventory | Not applicable to the host-fallback verdict; host copies are compatible |
| `pytest` with coverage and testmon active | Required | Optional; Windows development flow covers it |
| `deploy_pkgs.sh` end to end, including readiness checks | Not applicable | Required |
| Operator `senv` and `.env` sourcing | Not applicable | Required |

Read the ABI listing and live trace together. The listing must cover the
whole runtime search path; a root-object sweep alone can overstate fallback.
The trace must observe the venv Python directly, not merely uv and an
unverified child, and report the trace files written and kept. A result that
observed no venv process or retained no usable trace is inconclusive, even if
it prints no host-library load. Include the C++ consumer/provider measurements
with this evidence.

A plain `debian:12` container is suitable for the Debian checks. The consuming
project's real Jenkins pipeline provides the final integration run once it
can fetch the new tools archive. Its first run must use the new pin with
application snapshot publication disabled, as described below.

## Publication and consuming-project handoff

D1 couples this archive to the **next application release version**, published
at release time. The current archive and interims remain in CI until that
release; this effort does not introduce a dedicated intermediate Maven version.

The tools archive is manually published through the consuming project's
`tools/publish_pdf_nexus.sh --with-tools --version <version>` to the corporate
Nexus hosted `releases` repository, under `com/company/PDF/<version>` with
the `tools` classifier. That repository forbids overwriting a release:
`9.13.4` cannot be rebuilt and redeployed. Use a new release coordinate only
after the pre-publication matrix passes and no item 4 waiver remains active.

The publisher selects the newest local tools archive; retain the association
between the accepted local archive and the SHA-1 printed at publication.
Packaging stays timestamp-named; the version is recorded at publication and
in the consuming project's `tools/tools.version` pin. Jenkins reads that pin
at startup; it is not a configurable job parameter or Jenkinsfile constant.

The consuming project also reads `tools/publish.mode` at pipeline startup.
`snapshot` enables application upload; any other value runs relocate,
provision, package and walk without publishing. For the first run against the
new archive, raise `tools/tools.version` with this switch off. Prove the whole
chain and ABI probes on the real agent before allowing a snapshot upload,
then restore `snapshot` after acceptance. A failing walk still skips the
publish stage.

The consuming project's edits remain tracked in that repository: raise its
tools pin; remove `Q26 INTERIM, REMOVE` repair blocks, including the per-wheel
patchelf loop and dormant tools-patch fetch; remove the rsync shim; restore
coverage and testmon by dropping `--no-cov` and `-p no:pytest-testmon`; and
make the ABI contract probe blocking with zero expected flags. Coverage
imports and Q24 guarded suites self-enable when SQLite is available. The
permanent build-test-publish gate remains. Retiring the raw `python3*_bin`
and `UV_PYTHON` bypass is optional if uv works through the hardened wrapper.

## Boundaries

This item integrates the completed changes and owns the final refresh,
release rebuild, archive cleanup, validation and publication. It does not
reopen the installer, wrapper, architecture-resolution, closure-policy or
SQLite implementation decisions owned by items 1 to 6.

Python 3.14/free-threading, a replacement agent image, agent-image additions,
the consuming project's uv requirements pin, and the separate rsync
symlink-destination follow-up are outside this item. Downstream repository
cleanups are coordinated through the handoff above, not folded into cplx
implementation scope.
