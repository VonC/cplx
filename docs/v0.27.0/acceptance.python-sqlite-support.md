# Python SQLite support prerequisite and probe evidence

Scope: [implementation plan](plan.v0.27.0.python-sqlite-support.md), Steps 1 and 4.
Assessment updated: 2026-09-16. Step 4's identified candidate passes all three roles.
Access handles and raw operational captures remain in ignored local notes.

## Initial acceptance facilities checked before SQLite implementation

This table retains the initial preflight findings. The namespace route and
actual execution recorded below supersede its home-allocation blockers.

The first remote operation was a read-only preflight at 18:18:55 UTC through
the existing unprivileged RHEL connection. It read `/etc/os-release`, inspected
immediate `/home` entries, and tested ownership, writability and traversal
without creating a directory. It excluded the canonical live account home
and symlinked directory entries. No other owned, writable home was found.
No account creation, elevated command, promotion or deployment was attempted.

| Prerequisite | Observed state | Consequence for Step 4 |
| --- | --- | --- |
| Actual build and RHEL deployment role | SSH succeeded; `/etc/os-release` reports Red Hat Enterprise Linux 9.8 (Plow). The two roles share this host as recorded in the environment reference. | Host access established; candidate evidence is still required for each role. |
| Separate directly anchored isolated home | Zero other account-owned, writable, traversable real directories immediately under `/home`. | Blocked. No compatible home has been supplied or verified. |
| Independent cplx, tools, packages and environment trees | No compatible enclosing home is available. | Blocked; do not substitute a nested scratch build home. |
| Isolated profile and environment chain | Existing profile entry points were hashed; they source site-managed files. There is no isolated home whose complete chain can be audited. | Blocked; no inherited profile chain is approved for acceptance. |
| Separate RHEL deployment target | No candidate target has been allocated or its storage and preservation boundaries checked. | Blocked until the Step 4 target and live manifests are established. |
| Closure source identity | Plan Q04 D2 specifies the paired bundle, source-only evidence commit, authorized unchanged-tree merge and fresh-clone check. | Procedure established; concrete auxiliary Git authorization and execution belong to Step 3. |
| Debian 12 deployment/test runtime | The owner confirmed the existing consuming-project Jenkins job on 2026-09-16. Its Debian 12 agent is the deployment/test role documented in the environment reference. | Use Jenkins; Docker or Podman access on the RHEL account is not required. Capture the actual agent userland and image/container identity for the candidate run. |
| Debian archive-copy route | Verification scripts travel through the consuming repository; the job already fetches pinned toolchain archives. No SQLite candidate archive has been built or transferred. | Pin and transfer the RHEL-built candidate, compare its digest and retain the Jenkins capture. |

The missing home was reported before probe implementation against
[design decision Q05 H2](design.v0.27.0.python-sqlite-support.md#design-decisions-for-python-sqlite-support).
That decision remains unchanged. Live staging would require an owning-design
amendment; changing relocation anchors would also require an owning-requirement
amendment. Local Step 1 work is allowed while these blockers remain explicit.

## Profile and relocation boundary evidence for SQLite

The preflight hashed readable profile entry points without sourcing them:

| Profile role | SHA-256 |
| --- | --- |
| System profile | `304bbca429881a74f3e8f8b1c003b29020c635b83661492accd576c99baf9f30` |
| System Bash configuration | `bb091ed0ed1cbf1cd40cd3da60a4a994e2246c551ab086e96f43fefca197f75e` |
| Account Bash login profile | `4cb5ddfb69f4c934aa86b4fc50772fe8359cd7a3be6cb039dcfc51420fb7b298` |
| Account Bash configuration | `3bf7f3096db27619ca96c0413e56736a35fb6636deb8809549da1282affd4447` |
| Account profile | `6269a87370a5a1c7d3bed8860d3ff3c70a7f48760aa5a884fb337c57e8ffb26e` |

The account entry points source site-managed login and shell files. Their
transitive contents have not been audited for an isolated acceptance home.
These hashes establish the inspected entry points, not approval of that chain.

The reviewed [environment setup](../../src/setups/env/.env) sources the incoming
home's `.profile`, rebinds `HOME` to the cplx environment directory, sets
`GNUPGHOME`, changes certificate-directory permissions, and sources support
scripts. Its inspected authoring-file digest is
`c05893b1d1384d512aa4383c00b2d1238582119a8d1eae12d08283a6af76ad02`.
Any future acceptance invocation must audit the exact copied bytes, environment
scalars and complete source chain again for the selected layout.

The existing [installer](../../src/setups/env/bin/install_pkg.sh) replaces
`/home/<one-segment>/cplx/tools/` first, then `/home/<one-segment>/`.
For example, `/home/isolated/cplx/tools/python/root` relocates to
`<prefix>/tools/python/root`; `/home/live/scratch/cplx/tools/python/root`
retains `scratch/cplx` after the fallback replacement. The latter cannot satisfy
the settled layout. No exact compatible source path was available to approve.

## Step 1 authoring and Linux verification results

The new probe is standalone standard-library Python. Its expected Python root
is the enclosing Python tool directory containing both the sandbox and the
source or installed version. The caller also supplies the exact extension
directory and provider. For build-stage checks, the supplied configured
`libpython` backing file's parent establishes the source directory containing
the executable and `Modules/`; observed extension paths never define expectations.

| Verification | Result on 2026-09-15 |
| --- | --- |
| Cumulative `--step 1` runner under configured Git Bash 5.3.9 | Exit 0; mandatory ShellCheck floor passed for 57 tracked scripts; explicit harness syntax and ShellCheck passed. |
| Explicit Windows authoring Python 3.13.9 | 33 tests: 30 passed, 3 symlink tests skipped because this account lacks Windows symlink privilege; unit duration 0.532 seconds, runner unit phase 0.623 seconds. |
| RHEL system Python 3.9.25 | All 33 tests passed, no skips; unit duration 0.261 seconds. |
| Real Linux provider fixture | Database persistence and expected copied provider passed; device major/minor/inode were `253/7/7526084`. |
| Different expected file control | Database still passed; provider result failed and process exited 2. |
| Temporary database cleanup | Scratch directory empty after both real probe calls. |

Windows invocation: `cmd /d /c a.sqlite-check.cmd`, using the plan's ignored
same-process setup wrapper and explicit shared authoring Python. Its substantive
command is the cumulative Bash runner with `--step 1 --python <absolute-python>`.
This repository's `.review-validation` and confirmed plan substitute that
runner for the inapplicable pytest/groundhog default. No coverage percentage
is claimed.

The RHEL fixture used only an invocation-owned directory under `/tmp`, a copy
of `/usr/bin/python3`, the system Python 3.9 extension, and a copy of the
system `libsqlite3.so.0`. Host files were read, never changed. The provider
copy was deliberately selected using fixture-only library and module paths.
This proves the probe mechanism, not the 3.13.15 candidate or operator acceptance.

The probe SHA-256 agreed before transfer and on RHEL:
`6df1bdf704afae1bfa7dbe965eec0262fb6feac421583caba6fda58c4a6c308f`.
The retained local raw capture is `a.sqlite-linux-check.raw.txt`; its fixture
identity is `cplx-sqlite-step1.c84KeNwq`. The live positive call completed within
one Bash `SECONDS` tick; the observed delta was 0 at one-second resolution.
There is no elapsed-time pass threshold.

## Reproducing the controlled Linux SQLite observation

Run in a copy of the reviewed repository material on the RHEL host. All new
payload and database paths are under the directory returned by `mktemp`.
Retain diagnostics until assessed; this recipe performs no recursive cleanup.

```bash
set -euo pipefail
/usr/bin/python3 -B -m unittest -v tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd
work=$(mktemp -d /tmp/cplx-sqlite-step1.XXXXXXXX)
root=$work/python
mkdir -p "$root/bin" "$root/lib-dynload" "$root/root/usr/lib64" "$work/scratch"
cp -L /usr/bin/python3 "$root/bin/python3"
modules=(/usr/lib64/python3.9/lib-dynload/_sqlite3*.so)
((${#modules[@]} == 1)) && [[ -f ${modules[0]} ]]
cp "${modules[0]}" "$root/lib-dynload/"
cp -L /usr/lib64/libsqlite3.so.0 "$root/root/usr/lib64/libsqlite3.so.0"
probe=src/install/env/python/sqlite_probe.py
sha256sum "$probe"
args=(--stage installed --expected-python-root "$root"
      --expected-extension-root "$root/lib-dynload" --scratch-dir "$work/scratch")
env LD_LIBRARY_PATH="$root/root/usr/lib64" PYTHONPATH="$root/lib-dynload" \
    "$root/bin/python3" -B "$probe" "${args[@]}" \
    --expected-provider "$root/root/usr/lib64/libsqlite3.so.0"
mkdir "$root/wrong"
cp "$root/root/usr/lib64/libsqlite3.so.0" "$root/wrong/libsqlite3.so.0"
set +e
env LD_LIBRARY_PATH="$root/root/usr/lib64" PYTHONPATH="$root/lib-dynload" \
    "$root/bin/python3" -B "$probe" "${args[@]}" \
    --expected-provider "$root/wrong/libsqlite3.so.0"
status=$?
set -e
[[ $status == 2 ]]
```

## Candidate evidence boundary established in SQLite Step 1

The initial Step 1 assessment did not establish a candidate source revision,
payload inventory, archive digest, closure bundle or any candidate runtime
result. The actual Step 4 execution below supplies these records for one
identified archive. Item 7 must repeat acceptance for its final refreshed
archive before publication.

## Step 4 environment clarification and current prerequisites

Python is compiled once on RHEL. Debian receives that same archive for
installation, relocation and SQLite runtime tests; Debian does not compile
Python or install extra SQLite packages for this check. A missing Docker or
Podman executable on the RHEL account does not block the Jenkins route.

The owner confirmed the consuming project's Jenkins route on 2026-09-16.
An authenticated, read-only API request succeeded: the job was buildable,
was not queued, and its last completed run was build 170, `SUCCESS`.
This establishes access, not SQLite candidate acceptance. Credentials were
used from the existing ignored credential file and were not copied or logged.
No candidate acceptance was inferred from that API preflight.

Follow [the environment reference](reference.environments.md#access-on-the-jenkins-ci-agent):
the root `Jenkinsfile` already calls `ci/Jenkinsfile.diagnostics` through
`verifyCplx()`. Land verification-only script copies plus their identity manifest
in the consuming repository, use its actual CI push target, run the job and
retrieve its archived evidence before artifact rotation. The diagnostics hook
reports without gating the application build, so Jenkins `SUCCESS` alone is
insufficient: the retained SQLite command statuses and JSON must pass.

The read-only RHEL preflight at `2026-09-16T08:29:32Z` found **zero** separate
account-owned writable homes immediately under `/home`. The later inspection
below resolves the facility question through a private namespace; it does not
require the operator to provision a root-owned path. The unchanged relocation
anchor still requires the build-visible home to be `/home/<one-segment>`.

## RHEL namespace capability confirmed on 2026-09-16

SSH inspection at `10:12:36Z` confirmed `/home` is owned by `root:root`, mode
`0755`, and is not writable by the available account. The existing account home
is writable and its filesystem had approximately 72 GiB available. The observed
Python and Git build trees used approximately 4.5 GiB and 1.3 GiB. `/tmp` had
about 1.5 GiB free and `/var/tmp` about 3.5 GiB; use the home filesystem for the
independent payload copies and check space again before preparing them.

`unshare` 2.37.4 is present and unprivileged user namespaces are enabled. An
empty user/mount namespace command passed. A first bind-mount fixture using
`--map-current-user` was refused by the mount helper; the successful route uses
`--map-root-user`. UID 0 exists only inside that namespace and maps to the
ordinary SSH UID, without host-root privileges or a parent mount change.

The [native capability fixture](verify.python-sqlite-namespace.sh) creates
only disposable owned directories. It verifies that:

- The child sees the independent candidate directory at its normal home path,
  verified by device/inode identity and an owned sentinel.
- The original home is exposed at a separate read-only bind mount. A write
  attempted against an owned disposable file through that view is refused.
- The child writes into the candidate backing directory. Its `.profile` and
  `.env` are absent, and execution uses a clean environment and non-login Bash.
- The parent retains the original home and live cplx/tools/packages directory
  identities. Its `.profile`, `.env` and `.env_` hashes are unchanged, and the
  child's mount is absent from the parent namespace after exit.
- Cleanup removes only the two checked invocation-owned fixture directories.

The fixture passed again on the actual RHEL host at 10:45:15 UTC on 2026-09-16.
The [namespace launcher](acceptance.python-sqlite-namespace.sh) applies that
route to the real build and retains UID mappings, mount records and parent
preservation results for each invocation. The independent bootstrap occupies
approximately 7.2 GiB. RHEL deployment uses its own separate writable target;
Debian remains deployment/testing through Jenkins. No new host home, account,
sudo access or installer change is needed.

Ignored raw evidence: `a.sqlite-layout-inspect.raw.txt`,
`a.sqlite-namespace-capability.raw.txt`,
`a.sqlite-namespace-fixture.current-uid-failure.txt` and
`a.sqlite-namespace-fixture.raw.txt`. The reusable fixture is checked by the
Step 4 Bash syntax/ShellCheck gate and run explicitly on RHEL.

## Step 4 capture driver and input contract

[The driver](acceptance.python-sqlite-support.sh) exposes `preflight`, `build`,
`assemble`, `deploy` and `probe`. Its
[capture helpers](acceptance.python-sqlite-capture.sh) provide path and hardlink
boundaries, profile absence, full live manifests, exact archive selection,
structured probe validation and three-role completeness checks. The cumulative
`--step 4` runner executes [recording fixtures](verify.python-sqlite-acceptance.sh);
it does not launch a real build or turn fixtures into candidate acceptance.

Every phase takes these explicit inputs. Exact operational paths stay in ignored
local notes; no phase defaults to the login account's home.

| Input | Meaning |
| --- | --- |
| `--role build`, `rhel` or `debian` | The evidence role; only `build` may compile or assemble. |
| `--home`, `--evidence` | Existing owned canonical home and its dedicated evidence directory. |
| `--live-root` (repeatable) | Disjoint live control/payload trees whose complete contents must be preserved. |
| `--parser` | Absolute existing Python used only to parse capture JSON, never as the candidate interpreter. |
| `--audit`, `--audit-sha256`, `--settings` | Reviewed control-file hash manifest, its independently recorded digest and scalar-only environment data. |
| `--revision`, `--probe` | Candidate build revision and owned standalone probe. A later verification-only correction records its own source revision and script digest in the separately pinned bundle. |
| `--expected-python-root`, `--expected-extension-root`, `--expected-provider` | Independently specified deployed Python tree, 3.13 extension directory and shipped SQLite library. |
| `--source`, `--sentinels`, `--payloads` | Build-only populated source and newline-separated absolute owned file inventories to preserve across reconfiguration. Include unrelated sandbox content and selected RPM/cache files. |
| `--archive`, `--sha256` | Consumer-only candidate path and the digest recorded before transfer. |
| `--image-digest`, `--container-id` | Debian run identity obtained from the actual Jenkins agent/runtime evidence. |

Prepare the isolated home only after its allocation and write boundaries are
verified. Bootstrap `cplx/` from tracked `src/setups/env/`, supplement `bin/`
with `src/utils/`, `echos/` with `src/echos/`, and `tools/` with
`src/install/env/`. Copy the populated Python source/sandbox and Git payload
independently; inspect their links and retained paths. Supply the Step 3 closure
pair and retained source Git object. Keep `.env`, `.env_`, `tools/` and `pkgs/`
inside the namespace-visible home and deliberately omit `.profile`. The actual
bootstrap and source-chain review have run for the candidate build described
below. The namespace removes the need for an externally allocated sibling home.

Also inventory copied extended directory ACLs before entering the namespace.
The single-user mapping cannot reproduce ACL entries for other host users when
the unchanged packager copies directories. On the independent promoted copy,
retain the ACL inventory, remove those inherited extended/default ACLs, and
restore and compare ordinary permission modes. Never alter the live ACLs.

Check shared runtime identities across the copied Git and Python roots before
packaging. The existing build sandboxes may contain different dependency
generations even when their package flags look compatible. For this candidate,
the populated Python runtime is the explicit source for paths supplied by both
roots: the available glibc runtime manifest and shared objects under `usr/lib64`,
including OpenSSL plugins. Retain the original copied Git files and every
before/source hash before aligning the independent copy. Do not substitute a
loader alone or weaken duplicate-provider checks. A cached RPM manifest can
supply path names; it does not prove the copied files came from that RPM.

The audit is data, with one `SHA256`, two spaces and home-relative file path per
line. It must cover the complete transitive environment chain, properties,
wrappers, installer inputs, closure files and scalar settings. The driver
requires the known control set and verifies every listed digest, but hashes
cannot establish that shell code has safe semantics: review all copied path
inputs and transitive sources before creating this manifest. Settings are
restricted `KEY=value` scalars, not a sourced shell program. Child commands use
a clean environment with explicit `HOME`; loader/Python overrides, exported
functions and `BASH_ENV` are not inherited. Normal Python wrappers remain
responsible for selecting their shipped libraries.

Installation may replace `.env` and `.env_`. Review the resulting owned controls
and provide their new audit digest before the probe phase. Retain both audits.
Each failed phase closes the live comparison and retains a `failed` marker;
inspect that evidence before preparing another sequence. There is no automatic
cleanup or retry of a failed build or package operation.

## Step 4 execution order and item 7 repeat

Keep role-specific arguments in an ignored Bash array named `sqlite_args`.
Use separate evidence directories for the three roles. After completing the
layout and audit above, the substantive commands are:

```bash
driver=docs/v0.27.0/acceptance.python-sqlite-support.sh
# RHEL build role, including populated source and preservation inventories.
bash "$driver" preflight "${sqlite_args[@]}"
bash "$driver" build "${sqlite_args[@]}"
bash "$driver" assemble "${sqlite_args[@]}"
bash "$driver" probe "${sqlite_args[@]}"

# Each deployment role, with its own home, audit, transferred archive and digest.
bash "$driver" preflight "${sqlite_args[@]}"
bash "$driver" deploy "${sqlite_args[@]}"
bash "$driver" probe "${sqlite_args[@]}"
```

Put the build-role sequence and audited arguments in an ignored, reviewed
control script. Invoke it through the namespace launcher from the ordinary
RHEL account, using independently checked absolute paths:

```bash
bash docs/v0.27.0/acceptance.python-sqlite-namespace.sh \
    "$sqlite_account_home" "$sqlite_backing_home" "$sqlite_control_root" -- \
    bash "$sqlite_control_root/run-sqlite-build.sh"
```

The consumer bootstrap runs its three phases after preparing the audited
layout. Its home must initially be empty. Each caller supplies its real live
roots; the Debian caller additionally supplies actual image/container inputs:

```bash
bash docs/v0.27.0/acceptance.python-sqlite-deploy.sh \
    "$sqlite_role" "$sqlite_deploy_home" "$sqlite_bundle" "$sqlite_bundle_sha" \
    "$sqlite_archive" "$sqlite_archive_sha" "$sqlite_build_revision" "$sqlite_parser" \
    "${sqlite_consumer_options[@]}"

# After retaining build/, rhel/ and debian/ evidence for the same archive:
bash docs/v0.27.0/acceptance.python-sqlite-report.sh \
    "$sqlite_parser" "$sqlite_role_evidence_root"
```

The build capture requires a previous configure marker and compiled executable,
then records reconfiguration, cleanup, compilation, `_sqlite3=yes`, the requested
prefix and the source/installed probe results. Assembly records promotion dry
run, promotion, the normal operator probe and one packaging invocation. Candidate
records include archive filename, full digest, size, Python version, revision
and closure envelope. Selected payload inventories accompany the build capture.
Each consumer checks the same archive digest before and after installation and
requires its normal operator probe to report database persistence and the
expected provider. Passing fixtures alone do not establish these observations.

Collect `role.json`, `operator.json`, raw command logs/statuses, audit manifests,
live manifests and identity records for all three roles. The role completeness
helper checks matching archive digests and bound probe files; review the actual
OS, image, transfer, payload and source evidence as well. Per-command elapsed
seconds and timestamped configure/compile/install milestones are retained.
[The report command](acceptance.python-sqlite-report.sh) checks the three bound
role records and extracts those timings. [The consumer bootstrap](acceptance.python-sqlite-deploy.sh)
takes an independently pinned source/verification bundle and candidate archive,
then runs preflight, unchanged relocation and normal operator probing. It is
shared by the RHEL deployment and Jenkins adapter. Item 7 repeats this sequence
for its final archive and renewed closure identities; earlier fixture or
candidate results cannot certify different archive bytes.

## Actual Step 4 execution on 2026-09-16

The build home contains independent copies of the populated Python and Git
trees and deployed tools. All symlinks and hardlinks were checked against the
owned layout. Four copied OpenSSL configuration links pointed to the host's
immutable FIPS configuration; their reviewed contents, hashes, modes and times
were retained as independent regular files. No SQLite library was added.

The minimal `.env` sources `.env_`, which sources `tools/.env_init`. There is
no `.profile`. The audit covers copied wrappers, environment support, installer,
properties and closure controls. The existing setenv retains a C++ include
path; this run compiles CPython's C sources. Candidate commands run with a
clean environment. Complete live
manifests include regular-file content hashes, and the original home is
read-only inside the namespace.

The first real build configured SQLite successfully and compiled Python, then
failed its source capability check. The executable's `DT_RPATH` selected the
older installed `libpython` before its source-first `LD_LIBRARY_PATH`. The probe
rejected the mapped path although SQLite database operations succeeded. Full
failure diagnostics were retained, and live preservation passed. Commit
`f5c4a21eaafe6c58ca0dd7c094f8ec4af7628167` fixes the source-stage invocation by
preloading its independently validated source library. Installed and operator
invocations receive no added preload. All 32 native installer fixtures pass.
The corrected isolated rebuild uses this revision and audit digest
`cb3b4ab7ac668aaca0e0c2daa3ed231a7da103285c87a5cc007728dfa9e36606`.

That rebuild completed successfully in 327 seconds, including source and
installed probes. A capture-only refusal then exposed an incorrect assumption
that Autoconf's check and result share a config.log line. The corrected capture
validated `MODULE__SQLITE3_STATE=yes`, both JSON records and unchanged sentinel
and payload manifests without recompiling. The original refusal and passing
live comparison remain retained.

The subsequent normal operator check after promotion failed because the
extension's inherited `DT_RPATH` selected the build sandbox's SQLite library.
A separate diagnostic copy with `DT_RUNPATH` selected the promoted provider
through the unchanged wrapper. Commit `14d4af084c303b4ccaa234b3c9a19e7110d8e1ec`
adds `--enable-new-dtags` only to the scoped SQLite link dependency. All 32
native installer fixtures pass. The new populated rebuild uses this revision
and audit `87618b518ac4199b28bdb0226a59040175858467be519102dbb98538c5a419e5`.
The previous promoted candidate was never packaged; its failure diagnostics
and passing live comparison are retained independently.

The corrected build passed in 322 seconds, and its `_sqlite3` dynamic section
contains `DT_RUNPATH`. The normal promoted operator now passes with SQLite
under the promoted `tools/python` tree. Packaging then refused its private
hardlink mirror before creating any archive: copied directory ACLs contained
an unmapped host user. The bootstrap correction cleared extended/default ACLs
on 1,815 independent promoted directories and preserved their ordinary modes
byte-for-byte. The original refusal and passing live comparison were retained.

The next assembly reached the loader check and refused differing Git/Python
loader bytes. The copied build sandboxes also contained other differing shared
runtime providers. After that failure's live comparison passed, a recorded
bootstrap correction checked 120 runtime paths and aligned 45 existing Git
files with the populated Python runtime. Original Git files and all source and
before digests are retained. Python source/runtime bytes, production packaging
rules, package lists and live trees were unchanged. No SQLite library was added.
An explicit assembly continuation reuses the successful 322-second build and
requires the unchanged packaging gate to validate the resulting candidate.

That gate answered all 4,516 version needs with no coherence, floor or declared
family refusal. It found three remaining duplicate providers: the OpenSSL
aliases selected different patch-level filenames, and `libgcc_s` lived under
`root/lib64`. After retaining this refusal and its passing live comparison, the
same recorded alignment was completed for those three lookups. The OpenSSL
pair now uses the existing Python 3.5.7 runtime; old Git 3.5.1 lookup names remain
contained aliases. Original files and before/source hashes remain retained.

The resulting packaging run passed. It produced exactly one candidate:

```text
Archive: tools.2026-09-16_140011.tar.gz
Size: 544587889 bytes
SHA-256: c9fcb783e10409411d2fd08f3951ec163b1143d7357203fc237afbb71ce24e91
SHA-1: cf9b4e85207873e476ccb712949e7e3dbf621d8e
Python: 3.13.15
Candidate build revision: 14d4af084c303b4ccaa234b3c9a19e7110d8e1ec
Closure source: 13c80d572ba7bda91728806ad7dc11c53629a506
Closure digest: 63a955f8bded96f6a469764c625e9653c0988abe03ebd8192fc541f802d9d5aa
```

The gate examined 605 ELF subjects, resolved all 1,251 dependency edges and
answered all 4,518 version needs. Its 10 floor members, 21 names with multiple
candidates and two declared families passed. There were no active waivers,
unresolved link chains or undetermined invariant results. The closure report
labels its scope `PARTIAL`: these static invariants do not establish that every
entry point or application workload runs. The three runtime roles separately
check SQLite for these exact archive bytes.

The neighboring consuming repository's commit `dbac4f4f` adds a sequential,
non-publishing SQLite diagnostic to its existing Jenkins flow. Build 171
confirmed Debian 12 and actual image
`sha256:9cb0364f561d564c78a249663fa184c370f2ac5f9f314a99afe06c5516337d3f`.
It intentionally reported a missing candidate pin while compilation was in
progress. This establishes the runtime and identity route; it is not candidate
acceptance. The publication setting remains `off`. The candidate run must
record its own container identity, compare both transferred digests and retain
the structured role capture.

### Selected SQLite payload and retained build records

The populated sandbox contains SQLite `3.34.1-11.el9.x86_64` runtime and
development payloads. Both linker names resolve to `libsqlite3.so.0.8.6`.
Its GNU Build ID is `d023717b116b3a14bff787ceedbae23ed513e46a`.

| Retained input | SHA-256 |
| --- | --- |
| `sqlite-libs-3.34.1-11.el9.x86_64.rpm` | `dfdc4f315ec0723e6c2687f810bcc5a9d3cb83f4d73496734645123bd5a6f3d4` |
| `sqlite-devel-3.34.1-11.el9.x86_64.rpm` | `6c7f364e6c25c427c83619b851df26bd96d917e3c0d58b4dfa9416a72e744259` |
| Sandbox `sqlite3.h` | `7a10c5b7ee4d2f9297bb08fdaae3e9f4f083909d3dd826f58c0463fede358f07` |
| Sandbox SQLite provider backing file | `92f6f0d3f0aee0f02e52abe4e4f55c6f47c60a5fb37e620f2398bffb2d186c33` |

The accepted build's `config.log` records `_sqlite3` result `yes` and
`MODULE__SQLITE3_STATE=yes`. Its commands retain the explicit sandbox include
and library settings, requested 3.13.15 prefix, cleanup, compilation and both
capability probes. The unrelated sentinel and selected payload manifests match
before/after. The complete live preservation inventory additionally covers the
existing RPM cache; the smaller selected build-payload list is not an RPM-cache
inventory.

Raw build evidence is retained locally in ignored
`a.sqlite-build.evidence.tar.gz`, SHA-256
`4478eec4af62c20c20e3fad5ba19876dd061ab8b378a74675cd0e26a01e654fd`.
The supplementary `a.sqlite-build.details.tar.gz`, SHA-256
`349045480edd78040062928e105b80e6c99c8ab4ea2f2001230d2e32945387c0`,
contains configure records, the dynamic-section inspection and selected
payload/RPM identities. Expanded raw records are kept under `a.sqlite-roles/`
and `a.sqlite-build-details/`; access paths in them are not tracked.

Diagnosed refusals remain in `a.sqlite-build.history.tar.gz`, SHA-256
`3815408677c3213e4f6a4091e3aef3aafdd53fb9d7c23699bb8e01b058e634ac`.
That capture includes the successful build's separate installed-stage JSON
under `evidence.package-acl-refusal/installed.json`; the final build capture
also retains its original JSON line in `build.full.log`. Assembly continuations
did not rerun or relabel those build probes. Namespace invocations and their
parent-view results are in `a.sqlite-namespace.history.tar.gz`, SHA-256
`1e769d36fa20c51c383e56e51313dd468ab35438a9124c815f580cfed93602c8`.
Every retained parent-preservation result is zero, including failed commands.

### Accepted RHEL runtime roles

Both operator probes returned exit 0, database `passed` and outcome `passed`.
Each probe's executable and extension belong to that role's owned Python
3.13.15 tree. The build role keeps its source sandbox present during probing,
so the mapped promoted provider establishes that the wrapper selected the
promoted payload. The separate deployment uses the unchanged archive installer.

The provider suffix in each case is
`tools/python/root/usr/lib64/libsqlite3.so.0.8.6`. The following device major,
device minor and inode triples are actual same-process map observations;
their different inodes are expected for independent copies.

| Role | Provider identity | Probe JSON SHA-256 | Live comparison |
| --- | --- | --- | --- |
| RHEL 9.8 build account | `253, 3, 1362928684` | `ce5f8eb9c9a22c9a8fb52d713b4ec42c9be057ae173195d69d1b1f7679005c77` | Passed |
| RHEL 9.8 separate deployment | `253, 3, 1203225779` | `d5495cb6cc8730ae818a05a39ca1fbcae9c85d95efe4e3f9b33eb3a03e7b2150` | Passed |

Both role records bind archive SHA-256 `c9fcb783e10409411d2fd08f3951ec163b1143d7357203fc237afbb71ce24e91`.
The deployment capture is retained as `a.sqlite-rhel.evidence.tar.gz`, SHA-256
`83666c026fbbd2aa40cb2f6676a746d82a1f14113a860cfa0a50a71c2c4a5ba7`.
It includes the original command, 357-second relocation, provider JSON,
archive checks and passing full-content preservation manifests.

### Measured candidate durations

The accepted build's timestamped log supplies configure, compile and install
milestones. Command records use whole-second elapsed time; a reported zero
means less than one timer tick, not an omitted check. These are observations,
with no performance pass threshold. Transfer records separately retain the
receiving digest checks; their elapsed scope follows the recorded commands.

| Operation | Seconds |
| --- | ---: |
| Configure | 52.744 |
| Compile | 218.914 |
| Install | 33.452 |
| Complete populated rebuild, including checks | 322 |
| Promotion dry run / promotion | 1 / 1 |
| Packaging and closure gate | 122 |
| Candidate RHEL-to-authoring transfer | 108.967 |
| Candidate upload to validation storage | 113.884 |
| Separate RHEL relocation | 357 |
| Accepted Debian archive / verification-bundle transfer | 13 / 0 |
| Accepted Debian relocation | 466 |
| Build / separate RHEL / Debian normal operator probes | 0 / 0 / 1 |

The combined `a.sqlite-final-report.json` validates the three role records,
their bound probe JSON digests and every retained command's zero exit status.
Its SHA-256 is
`3da7d4e3658e9a4e7aacf6439ebc24f00e7013510c5b1f0b83f809ff464493b7`.
Final role copies are under ignored `a.sqlite-final-roles/`; original captures,
including Debian refusals, remain intact. Failed-run durations remain separate
observations.

## Step 4 authoring verification on 2026-09-16

### Debian candidate refusal retained

The first candidate run used consuming commit `2f5d3a35`, Jenkins build 172,
Debian 12 and actual image
`sha256:9cb0364f561d564c78a249663fa184c370f2ac5f9f314a99afe06c5516337d3f`.
The archive and verification-bundle transfer digests matched their pins.
Archive transfer took 13 seconds and normal relocation took 475 seconds.

The normal Python 3.13.15 operator imported the expected extension and passed
the persistent database round trip. Its provider result refused acceptance:
`mapped backing file identity differs from disk`. The wrapper returned zero,
but the structured result was `failed`; the capture correctly refused it with
exit 2. Full live-content preservation passed on that failure path.

The raw refusal is retained in `a.sqlite-debian.evidence.tar.gz`, SHA-256
`839470544f1bf2f983ca9c42a6f0da7067dc18272e0398f89ef02b156957ddee`.
Consuming commit `c3006cb1` adds a separate same-process diagnostic to retain
the opened-file and mapped identities after a refusal. It does not change the
candidate, relax the acceptance rule or turn a database-only pass into a
provider pass.

Build 173 retained the same refusal and established its cause. The opened
provider's stat identity was `0, 41, 1368051742`; all loaded segments and a
private mapping made from the held descriptor reported `253, 2, 1368051742`.
The mount record identified OverlayFS. Access to `map_files` metadata was
refused by the kernel, so the unprivileged descriptor reference supplies the
independent connection between identities. The retained archive
`a.sqlite-debian173.evidence.tar.gz` has SHA-256
`1ff7251a951dfdd5af1e138f9c6a38f2d18950ecc1ce43b82a95ffe6d384b751`;
its live comparison passed.

Commit `d42014e2f358cb4b42564150f93625ae83784c73` implements this connection in
the shared observer without counting the reference as a loaded library.
The single maps read still follows the persistent database round trip.
All 42 native probe tests pass, including refusals for replaced, deleted,
missing and competing providers. The current source build, installed prefix
and promoted normal wrapper also pass with the corrected observer; no
recompilation was performed for this verification-only correction.

The supplemental source, installed and promoted checks retain the exact probe
script digest below, command statuses and full live manifests. The separate
RHEL deployment's normal wrapper also passes with those same probe bytes.
Both full-content comparisons pass. These records supplement the original
accepted role captures without replacing their original observations.

| Supplemental capture | SHA-256 |
| --- | --- |
| `a.sqlite-descriptor-build2.evidence.tar.gz` | `d5eb2e1fc964741fb0ba00774db5cd40a110ea5009f1aade226034d95f016a8e` |
| `a.sqlite-descriptor-rhel.evidence.tar.gz` | `ff840fa1dba8b279f36e09bd2cd7850d2492b0f26da9b713df80b105702e6508` |
| `a.sqlite-descriptor-namespace.history.tar.gz` | `f55cdf4e890b5dcfc81ba2ba0dbfc8991eb1916f2866d7c35ca238ed3b16d2ca` |

All 24 retained namespace invocations report parent-preservation exit zero.
An initial supplemental source precheck compared a symlink spelling with its
canonical path and stopped before probing; its live comparison passed. The
corrected precheck resolves both paths and produces the accepted build capture.

The corrected verification bundle is `a.sqlite-verification.20260916c.tar.gz`,
SHA-256 `96814af4ec5ac40455fbe3a005c2043de231dec97b5df0441b1995972e3fd4e5`.
Its manifest records source revision `d42014e2f358cb4b42564150f93625ae83784c73`,
candidate build revision `14d4af084c303b4ccaa234b3c9a19e7110d8e1ec` and probe
script SHA-256 `46d72267a8e10a4b6919629905f08a979d9f9a24106d52721c320357cec7a45e`.
Consuming commit `88f59d8c` pins this verification material while retaining
the original candidate archive digest.

### Accepted Debian runtime and completed role report

Jenkins build 174 checked out consuming commit
`88f59d8c08b04f95bc235c1d9fe6b473b2125ba2`. Its Debian 12 userland used image
`sha256:9cb0364f561d564c78a249663fa184c370f2ac5f9f314a99afe06c5516337d3f`
and container
`f4b715abb36469dc3d18906a46865a78ae7f28fc45a9f8f4171bdc8da9a0105c`.
Both transferred digests matched. The control audit records probe script
SHA-256 `46d72267a8e10a4b6919629905f08a979d9f9a24106d52721c320357cec7a45e`.

The unchanged installer relocated the archive in 466 seconds. The normal
Python 3.13.15 wrapper, with no added loader override, passed the database
round trip and loaded the expected extension and Python-root SQLite provider.
Its provider's filesystem identity is `0, 68, 279526489`; the independently
bound kernel mapping identity is `253, 2, 279526489`. Operator and capture
exit statuses are zero, structured outcome is `passed`, and the full live
comparison is `passed`. The capture completed at `2026-09-16T13:23:06Z`.

The role record binds the original candidate archive digest and operator JSON
SHA-256 `2a5aa5693ac09f6b6815186a787846dacfbd091cdb8eae0c54016c8b5d92ff6b`.
Its retained `a.sqlite-debian174.evidence.tar.gz` has SHA-256
`f6afcbe388fc2d60e4bb1823b7f012ba8be0adab7c6f22821f88456c9322be3f`.
The capture supplies no extra SQLite library and performs no compilation or
package installation. The combined report now accepts all three archive-bound
roles; Jenkins's overall application-job result is not the acceptance criterion.

Consuming commit `64a59cb9` removes the completed candidate pin and guards the
reusable capture hook with its presence. It was pushed to the authorized CI
target after retaining the accepted artifact. Publication remains `off`, and
item 7 can activate the adapter with a new final-archive verification pin.

### Focused authoring checks

| Check | Result |
| --- | --- |
| Missing-driver control before implementation | Recording harness exited 1 with `acceptance driver is missing`. |
| Cumulative `--step 4` under configured Git Bash | Exit 0; 57 tracked-script lint floor, all effort harness syntax/ShellCheck, 42 probe tests with 4 Windows skips, build-launcher fixtures and 27 closure checks passed. |
| Native shared probe tests after OverlayFS correction | All 42 passed without skips in 0.313 seconds; source, installed and promoted actual RHEL interpreter checks also passed. |
| Capture fixtures on Git Bash after build diagnosis | 34 passed; native symlink boundary and packaging-alias fixtures explicitly skipped because this account cannot create those symlinks. |
| Capture fixtures on RHEL after capture-schema corrections | All 38 passed, including native escaping-link and wrong archive-alias refusals, canonical wrapper paths, failure preservation and the recording preflight/deploy/probe sequence. |
| New candidate acceptance | Populated rebuild, packaging and all three runtime roles passed for the same archive. Jenkins build 174 supplies accepted Debian evidence; builds 172 and 173 remain retained refusals. |

The native recording run used a new invocation-owned `/tmp` directory; it
neither compiled nor deployed the production toolchain. Raw local captures
remain in ignored `a.sqlite-step4-check.log`, `a.sqlite-step4-native-final.log`,
`a.sqlite-step4-preflight.raw.txt` and `a.sqlite-jenkins-job.json`. The fixtures
exercise refusal/preservation controls and a recording consumer sequence. The
three-role captures above separately complete candidate acceptance for Step 4
and umbrella item 6; fixture results alone do not establish that outcome.

## Acceptance criteria evidence for the identified candidate

| Criterion | Evidence and assessment |
| --- | --- |
| AC1 | The recorded EL9 x86_64 SQLite RPMs supply the header, linker symlink and runtime provider. Header/provider hashes and package identities are retained in the build detail archive. Existing dependency-list entries remain present. |
| AC2 | The successful build log records sandbox `LIBSQLITE3_CFLAGS` and `LIBSQLITE3_LIBS`, including the scoped new-dtags setting. `config.log` reports `_sqlite3=yes`; source and installed imports pass. |
| AC3 | The archive's closure inventory contains the compiled extension and Python-root SQLite provider. The promoted operator resolves that provider while the original build sandbox remains present. |
| AC4 | The original two RHEL operator captures, corrected-observer supplemental probes and Jenkins build 174 all pass database persistence, expected extension/provider identity and preservation for the same archive. |
| AC5 | The packaged closure digest and source anchor match the renewed pair. All ten floor members and both declared families pass, including Python 3.13.15; zero active waivers remain. |
| AC6 | The 27 focused closure checks retain missing unwaived member, Git-only provider, stale waiver, unexpected historical directory and source-authority refusals. |
| AC7 | The 32 native build-launcher fixtures include absent extension and unusable interpreter failures. Real source/installed checks report structured capability outcomes before promotion or packaging. |
| AC8 | The focused installer checks retain the out-of-scope target behavior; SQLite settings and checks are selected only for `el9.x86_64`. |
| AC9 | The populated-tree `--reconfigure` run completes in 322 seconds with configure, clean, compile and install milestones. Unrelated payload sentinels and selected RPM/cache identities survive unchanged. |
| AC10 | The non-release 3.13.15 archive is identified above by build revision, payload identities, size and digests. Verification revision is recorded separately. Item 7 must refresh and repeat acceptance for its final archive. |
| AC11 | Jenkins build 174 confirms Debian 12, actual image/container identity, both transferred digests and normal relocated provider acceptance. No extra SQLite package is installed by the capture. |

### Item 7 execution handoff

Use the phase and consumer commands above with newly audited isolated homes,
the final refreshed archive and renewed source/closure identities. Build only
on RHEL. Pin that archive and its verification bundle in the consuming
repository's `tools/sqlite_candidate.verification-only.txt`, keep publication
off, and run the existing Jenkins diagnostics adapter for Debian acceptance.
Retrieve its early artifact before Jenkins retention removes it. Check the
structured role result even when the overall Jenkins job reports success.

The item 6 archive includes recorded bootstrap alignment of pre-existing
Git/Python runtime files; those observations do not replace item 7's fresh
payload inventory, Python patch-version regression decision or complete
application matrix. Its final archive must repeat all three SQLite roles and
the unchanged packaging gate. Reuse the descriptor-aware shared probe and
record both filesystem and kernel mapping identities. Remove the temporary
candidate pin after retaining acceptance evidence.
