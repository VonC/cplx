# RHEL architecture fallback acceptance evidence

Step 4 acceptance passed: controlled and final-tree RHEL Python/Git setup,
cumulative Windows/native Linux fixtures, actual CMD launcher and documentation
checks all succeeded. AC1-AC12 map to the executed evidence below.

## Acceptance inputs and isolation

The authoring revision is `9971799aa2b1f5aa856b90131e881625873a13d1`, plus the
Step 4 working-tree changes. On 2026-09-15 the remote host reported
`rhel_9.8_x86_64`. Existing version labels are Python `3.13.15` and Git `2.52.0`.
Raw commands, host identifiers and logs stay in ignored
`a.architecture-acceptance/`; the paths below use `<account-home>` for the remote
account directory.

The controlled authoring checkout is the sibling `cplx-afb-20260915`.
Its active setup properties and `senv.local.bat` are copies of operator files.
The copied `cplx_path` is `<account-home>/cplx-afb-20260915`; the copied exact
9.8 curated lists, active mirror key and generated index are absent.
The original generated indexes and operator configuration remain in place.
The Python legacy cursor is copied; Git's final-entry cursor is synthetic.
Configuration origins and hashes are in `control.origins.txt`.

The batch startup audit follows `.profile`, the shared login profile,
batch configuration and `loadenv_user_remote`. None imports a cplx `.env`
or writes beneath the live tree. The profile digest is
`6269a87370a5a1c7d3bed8860d3ff3c70a7f48760aa5a884fb337c57e8ffb26e`.
The batch shell-mode detector creates and removes `/tmp/<pid>.mode`;
that existing behavior is preserved. Import contents and digests are retained
in `host-preflight.log` and `profile-{chain,config,batch,leaves}.log`.

## Recorded bootstrap commands before host execution

`a.architecture-acceptance/bootstrap-host.sh` checked that the isolated root
did not exist, created it, and applied the existing environment layout:

```sh
mkdir "$target"
tar -cf - <tracked src/setups/env files> | ssh "$host" tar -xf - -C "$target" --strip-components=3
tar -cf - <tracked src/utils files> | ssh "$host" tar -xf - -C "$target/bin" --strip-components=2
tar -cf - <tracked src/echos files> | ssh "$host" tar -xf - -C "$target/echos" --strip-components=2
tar -cf - <tracked src/install/env files> | ssh "$host" tar -xf - -C "$target/tools" --strip-components=3
```

The bootstrap copies remote `cplx.properties`, keeping the existing services,
`CPLX_BIN=true`, `CPLX_ARCH_EXT=el9.x86_64` and matching check basenames. It
creates `certs/`, tool roots and relative `current`/`tool` links before `.env`
is sourced. The existing `tools/setup python 3.13.15` and
`tools/setup git 2.52.0` then prepare only directories and links.
Bootstrap passed: every resolved writable root and link remained beneath the
isolated root (`bootstrap.remote.log`). The copied remote properties have the
same SHA-256 as their source:
`6d15fec27bc922a5aacdcda8280e8461574065faf0772168078466b622ccd0db`.
The general setup, configure, build, packaging and deployment entry points are
outside this acceptance procedure.

## Curated correction evidence before removal

`rollout1.corrections.txt` records the three corrected names, each with one
ordinary match in the retained 9.8 generated index. The paired Git edits are
`libcom_err,` to `libcom_err` and `libxslti` to `libxslt`; Python changes
`zlib-dev` to `zlib-devel`. Corrected 9.6 and 9.8 lists are byte-identical:

| Tool | SHA-256 of each corrected list |
| --- | --- |
| Python | `b799098736789f5a14dd697397223bf9daf5155da7c90f0eb9f4199e770a7b91` |
| Git | `d40e8033f85e5ea0f9bc96e2aaff8873a81a162bee99c7f6ed51a511af1fa254` |

The tracked 9.6 and 9.8 mirror values were identical, each containing three
ordered URLs. The earlier raw correction note's count of two URLs is incorrect.
The corrected exact lists and template were retained as raw evidence before
their limited removal, after controlled acceptance passed.

## Fresh detected index and complete preflight

From CMD, `generate-index.cmd` cleared the controlled checkout's own
`NO_MORE_SENV_` guard, called its `senv.bat`, cleared completion/reload/repeat
settings and invoked Git Bash. `generate-index.sh` called the actual
`download_packages_list` function with the copied active properties. The log
confirmed `project_dir_unix` named the controlled sibling and reported:

```text
Package metadata mirror: rhel_9.8_x86_64 -> rhel_9_6_x86_64_pkgs_url
Published index '.../packages_rhel_9.8_x86_64.txt' (5898 packages)
```

The fresh index SHA-256 is
`488a1f5458bb1d80aff9fcba967fa0c8d263fa50ed529e050d76b735627ccce9`.
The authoring index snapshots were retained. An initial driver used Bash
`errexit`, which is incompatible with the existing logging helpers; the driver
was corrected to use the production caller's shell contract before generation.
No production code or mirror data was changed for this driver correction.

`preflight-packages.sh` used ordinary `find_package_in_arch` for all 105 active
entries (Python 56, Git 49), resolving 80 distinct RPMs with zero missing or
ambiguous names. Of these, 46 were cached above the existing size threshold and
34 passed HEAD requests to the selected active mirrors. The preserved
`initial.{resolution,availability}.tsv`, `initial.preflight.log` and
`fresh-index.log` retain this initial evidence.

| Corrected expression | Unique fresh-index match |
| --- | --- |
| `zlib-devel` | `zlib-devel-1.2.11-41.el9.x86_64.rpm` |
| `libcom_err` | `libcom_err-1.46.5-8.el9.x86_64.rpm` |
| `libxslt` | `libxslt-1.1.34-16.el9.x86_64.rpm` |

## Real setup commands and preservation checks

Each host pass uses this CMD entry, with its tool, progress mode and log prefix:

```cmd
cmd /d /c a.architecture-acceptance\run-tool.cmd python legacy controlled.python
cmd /d /c a.architecture-acceptance\run-tool.cmd git legacy controlled.git
```

The driver activates the controlled checkout in the same CMD process as Git
Bash, asserts its derived project directory and detected key, and switches the
isolated relative `tools/tool` link. It invokes the unmodified ordinary
`bash src/setups/setup_packages.sh`, including real download, SSH, SCP and remote
`install_packages_for_tool`. The actual CMD launcher has a separate fixture gate.

Before each measured legacy pass, a HEAD-verified RPM is omitted from the copied
cache: `zlib-devel` for Python and `unzip` for Git. An uncached omission seed is
first obtained by the ordinary downloader. Other matching cache entries remain.
Python uses its copied legacy marker; Git uses its labeled synthetic final
marker. A subsequent `resume` pass seeds a valid scoped cursor three entries
before the end and requires only those three entries to synchronize, with
existing remote installed state available for reuse.

`<pass>.setup.log`, `<pass>.pkgs.log`, `<pass>.progress.{before,after}`,
`<pass>.dependencies.list` and `<pass>.result` record actual work and duration.
Before/after snapshots compare authoring setup status, metadata/marker bytes,
RPM path/size/mtime inventories, and live remote staging/installed flags and
links. No pass is accepted without byte-identical preservation snapshots.

### Controlled host results

| Pass | Synchronized entries | Ordinary setup result | Preservation |
| --- | --- | --- | --- |
| `controlled.python` | 56, legacy restart | success, 552 seconds; copied selected 9.6 list and completed real installation | authoring status/bytes/cache and live remote inventory unchanged |
| `controlled.python.resume` | 3, after valid scoped cursor | success, 40 seconds; copied selected list and completed installation | all four preservation comparisons unchanged |
| `controlled.git` | 49, legacy restart | failed, 469 seconds; remote post-install fatal 152, propagated as setup exit 5 | all four preservation comparisons unchanged |
| `controlled.git.retry` | 49, legacy restart | failed, 257 seconds; `glib2-devel` runtime dependency check, fatal 199/29 propagated as setup exit 5 | all four preservation comparisons unchanged |
| `controlled.git.libelf` | 50, legacy restart | success, 233 seconds; selected 9.6 list copied and real installation completed | all four preservation comparisons unchanged |
| `controlled.git.resume` | 3, after valid scoped cursor | success, 31 seconds; selected list copied and all 50 installed packages reused | all four preservation comparisons unchanged |

Python's first pass reused 47 local cached entries and downloaded 9, including
the omitted `zlib-devel` RPM. Its resume control reported
`Resuming processing after line: 'readline'` and
`All 56 packages are already installed for tool 'python'`, proving both cursor
resume and installed-state reuse.

Git resolved, retrieved and synchronized every entry, including `libcom_err`
and `libxslt`, and copied the selected list. Its installation exposed an existing
`post_install_autoconf271` bug: `cp -a "${root}/opt/rh/autoconf271/*"` treats the
wildcard literally and fails on the freshly extracted directory. The focused
`architecture_entry_autoconf_hook` regression reproduced fatal 152 before any
production edit, including a fixture root containing spaces. The fix keeps the
root quoted and expands the wildcard outside those quotes. This is the only
additional change to production code required by the installation failure.

The focused regression passes after the fix, checking copied support files,
rewritten paths and repeat invocation. The real direct-package recovery
(`setup_packages.sh --package autoconf271`) completed in 13 seconds, copied the
extracted files and rewrote seven paths. This uses the ordinary installer to
finish a post-install after its earlier failure; it does not inject RPMs or
alter installed flags. Progress and all four preservation snapshots matched.
`controlled.git.repair.{setup.log,result,verified}` records the result. The first
driver assertion inspected the old full-install `pkgs.log`; its correction
validated the successful direct-entry output without repeating the operation.
The next full Git attempt reached `glib2-devel`, whose `gresource` executable
requires `libelf.so.1`. The RPM declares that dependency, but the curated list
omitted its provider. With no system `/usr/bin/gresource` available for
mirroring, the existing check correctly rejected the `/lib64/libelf.so.1`
resolution. `diagnose-libelf.log` records the RPM requirements and ELF metadata.

The additional input repair inserts `elfutils-libelf` immediately before
`glib2-devel` in both Git lists. It is an ordinary curated dependency, resolved
from the same fresh index as `elfutils-libelf-0.195-1.el9.x86_64.rpm`; no runtime
check is relaxed and no RPM is injected. This brings the required totals to
Python 56 and Git 50 (106 active entries, 81 distinct RPMs). The initial
105-entry preflight remains in `initial.{resolution,availability}.tsv`;
`preflight.log` and the current TSV files verify the amended lists before retry.
The amended preflight passed: 106 entries, 81 distinct RPMs, zero missing,
ambiguous or unavailable selections. Full Git legacy and resume acceptance then
passed with this dependency present before any curated removal.

The successful Git legacy pass reused 48 local cached entries, downloaded the
omitted `unzip` and newly declared `elfutils-libelf` RPMs, and reused 49 staged
RPMs. Its resume control reported
`Resuming processing after line: 'libmount-devel'`, synchronized the remaining
three entries without downloads, and reused all 50 installed packages.

After the dependency addition, both Git lists remain byte-identical with SHA-256
`2516c69c503c1b2345ebe0fc706d06a24e7106c9024f371cc3a9b4814df31041`.
The earlier Git digest records the state after the two name corrections and
before this additional runtime dependency was discovered.

### Limited cleanup and final-tree acceptance

After the four successful controlled host passes, the authoring tree removed
only Python/Git exact 9.8 curated lists and the equal tracked 9.8 mirror value.
The obsolete per-minor-copy comment now documents fallback and distinct exact
overrides. `curated.*.before-removal.*` preserves the corrected exact inputs;
`final.curated` records matching authoring/control digests and the unchanged
fresh 9.8 generated index.

The resulting curated files and repaired installer were copied into the same
controlled checkout. Final Python/Git runs use the same isolated remote root
and index, reseeded legacy markers and newly HEAD-verified cache omissions.
Their logs and preservation snapshots use `final.python` and `final.git`.

| Final pass | Entries synchronized | Downloaded / cached | Staged / installed reuse | Result |
| --- | --- | --- | --- | --- |
| `final.python` | all 56, restarted after copied legacy `sqlite-devel` | 1 / 55 | 56 / 56 | exit 0, 260 seconds |
| `final.git` | all 50, restarted after synthetic legacy `pinentry-tty` | 1 / 49 | 50 / 50 | exit 0, 230 seconds |

Each selected 9.6 list matched the remote `dependencies.list` byte for byte.
Both runs reported lazy selection of `rhel_9_6_x86_64_pkgs_url`, retrieved their
newly omitted served RPM, and completed remote installation. All four
before/after preservation comparisons passed for each run. The detected 9.8
index retained the recorded `488a1f...` SHA-256. `final.complete` records the
coordinator's successful checks, including the all-installed reuse messages.

The measured commands after cleanup were:

```cmd
cmd /d /c a.architecture-acceptance\run-tool.cmd python legacy final.python
cmd /d /c a.architecture-acceptance\run-tool.cmd git legacy final.git
```

## Cumulative verification gates

| Final gate | Passed groups | Result and raw evidence |
| --- | --- | --- |
| Windows CMD / Git Bash, Step 4 | 30 | exit 0, 1455 seconds; `windows-final.step4.resumed.log` |
| Native RHEL Linux, Step 4 | 29 | exit 0, 40 seconds; `native-final.step4.log` |
| Actual Windows CMD launcher | 11 | exit 0; `launcher.step4.log` |

Both cumulative gates passed the 57-script lint floor, explicit effort checks
and live setup metadata/status/cache preservation. Windows additionally passed
the held-destination publication test. The five Step 4 groups cover complete
fallback, scoped resume, distinct exact overrides, terminal failures and the
real Autoconf post-install hook.

The final cumulative native Linux gate passed in 40 seconds
(`native-final.step4.log`, `native-final.driver.log`, exit 0), using the resulting
curated files and hook repair. It includes the mandatory 57-script shell lint
floor, all four entry fixtures and the added Autoconf hook regression.
Windows-specific held-destination and CMD cases are verified separately.

The plan's executable commands are:

```powershell
cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat && !GH!\bin\bash.exe docs/v0.27.0/verify.architecture-fallback.sh --step 4"
cmd /d /c docs\v0.27.0\verify.architecture-launcher.cmd
```

```sh
# Prepared native Linux environment, in the isolated copied source tree.
bash docs/v0.27.0/verify.architecture-fallback.sh --step 4
```

`windows-final.cmd` implements the first command as separate batch lines with
quoted Git Bash and explicit setup/exit checks. `native-final.ps1` transports
the current source into an owned temporary native tree and runs the Linux
command, recording Bash 5.1.8 and ShellCheck 0.10.0. The cumulative runner
executes `bash src/utils/lint_shell.sh` before effort syntax, ShellCheck and
behavioral checks; these gates do not claim a line-coverage percentage.

## Acceptance-criterion evidence map

The cumulative runner sources the metadata, index and progress fixture suites;
the names below identify executable assertions. All required final outcomes
passed; Windows-only cases are counted only on Windows.

| Criterion | Evidence |
| --- | --- |
| AC1 | `architecture_entry_fallback`: neither index initially exists, retained 9.6 lists/mirror, both legacy final cursors, every active entry processed; fresh real 9.8 generation and complete preflight above |
| AC2 | `metadata_exact_and_lists`, `architecture_entry_exact_override`, `index_guard_matrix`: distinct exact metadata and existing nonempty index win |
| AC3 | `metadata_boundaries`: other distributions, majors and complete machine names excluded |
| AC4 | `metadata_order_permutations`: numeric minor ordering and candidate-order invariance |
| AC5 | Entry fixtures retain detected properties and report selected sources; real generation reports detected 9.8 and selected 9.6 |
| AC6 | `index_selected_list_copy`, `index_pinned_mirrors_and_cache`, `index_lookup_read_only`, `index_guard_matrix`, `index_direct_built_and_empty`; entry negative cases preserve terminal failures |
| AC7 | All controlled and final-tree Python/Git host passes succeeded: every active entry, selected-list copies, cache omissions, corrected names, installed-state reuse and live-state preservation |
| AC8 | Nine updated wiki pages cover selection, upgrade recovery, index identity and scoped progress; local links, headings and fences checked |
| AC9 | `metadata_exact_and_lists`, `metadata_mirrors`, `metadata_read_failures`, `index_guard_matrix`: per-kind absence, authoritative empty lists and unreadable inputs |
| AC10 | `index_guard_matrix` covers 48 availability/completion/reload/ordinary-direct combinations; `index_generation_failures` and Windows held-destination replacement preserve old bytes on failure |
| AC11 | `metadata_boundaries`, `metadata_mirrors`, `metadata_read_failures`: actionable absence and exact-only major keys |
| AC12 | `progress_resume_matrix`, `progress_restart_matrix`, `progress_interrupt_restart`, `progress_literal_and_lines`, `progress_publication_failures`; entry legacy restart and scoped resume; real per-tool three-entry resume controls and both final legacy restarts passed |

The actual Windows CMD launcher gate passed (`launcher.step4.log`), including
literal arguments, reset-after-entry, direct/reset rejection and failure status
propagation. The initial Windows cumulative run passed Steps 1-3, then exposed
a Step 4 fixture containment mismatch between `/tmp`, Windows short paths and
the child's long drive path. The fixture root now uses the full drive path;
the focused exact-override case passed after this repair. Production paths and
transport code were unchanged. All four Windows entry fixtures subsequently
passed in 1005 seconds (`entry-gate.step4.resumed.log`). The final cumulative
gate passed all 30 groups, including the added hook regression, in 1455 seconds.
Changed Markdown headings, fences and local file links passed
`check-docs.ps1`; `git diff --check` passed. The planned source inspection
confirmed only the three curated removals, with both generated indexes and
operator data preserved.
