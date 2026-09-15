# Python SQLite support prerequisite and probe evidence

Scope: [implementation plan](plan.v0.27.0.python-sqlite-support.md), Step 1.
Assessment date: 2026-09-15. Candidate acceptance in Step 4 remains blocked.
Access handles and raw operational captures remain in ignored local notes.

## Acceptance facilities checked before SQLite implementation

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
| Plain Debian 12 runtime | Neither Docker nor Podman was on the checked RHEL account PATH or Windows command path. The existing Jenkins route is documented, but is not a confirmed plain-container route. | Blocked; runtime host, image digest and usable container access remain unconfirmed. |
| Debian archive-copy route | No endpoint for the unpublished candidate has been established. | Blocked; no transfer or Debian candidate run has taken place. |

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

## Remaining candidate evidence for SQLite Step 4

No candidate source revision, payload inventory, archive digest, closure bundle,
build-account probe, Debian image/copy identity, deployed RHEL probe or live-tree
before/after manifest is recorded yet. Step 4 must fill those records for the
same identified archive after its prerequisites are satisfied. Item 7 must
repeat acceptance for its final refreshed archive before publication.
