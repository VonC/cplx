# v0.27.0 bundled SQLite implementation plan

Build SQLite 3.54.1 from verified source as a cplx library tool, rebuild the
toolchain Python 3.13.15 against it, prove the exact build at every probe
stage, then qualify one tools archive on RHEL 9.8 and on the Debian 12 agent.

References: [requirement](feature-request.v0.27.0.sqlite-runtime-upgrade.md),
[umbrella item 9](draft.v0.27.0.debian-agent-tools.md) and
[item 6 plan](plan.v0.27.0.python-sqlite-support.md), whose probe and
verification runners this plan extends.

This plan was written after Steps 1 to 4 were implemented, under the urgent
request recorded in the requirement. It states what each step delivers and how
it is checked, so the validation plan can record the evidence.

## Ordered delivery for the bundled SQLite

| Step | Delivers | Commits |
| --- | --- | --- |
| 1 | The `sqlite` library tool and complete payload removal | `f462640`, `5f31f80` |
| 2 | Python linked to it, with input invalidation and an exact-build probe | `539914c`, `e505003` |
| 3 | Diataxis wiki pages for the process | `b3fd94e` |
| 4 | Promotion, packaging and archive qualification on RHEL 9.8 | operational |
| 5 | Archive qualification on the Debian 12 agent | operational |

Steps 4 and 5 change no tracked cplx file. Their evidence lives in the
validation plan; access details stay in ignored notes.

## Shared execution command checklist for bundled SQLite steps

From a CMD session that called `senv.bat`, at the repository root, with the
sibling llm-shared checkout's interpreter as the authoring Python (the step
runner requires an absolute path, which `%CD%` supplies):

```text
bash docs/v0.27.0/verify.python-sqlite.sh --step 4 --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe
bash docs/v0.27.0/verify.python-sqlite-build.sh --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe
bash docs/v0.27.0/verify.sqlite-source.sh
shellcheck -S style src/install/env/sqlite/sqlite_install_functions.sh
```

On the build host, from a copy of the tree: the native installer fixtures,
which Windows skips for want of real symlinks, and the probe unit tests with
the host Python and with the rebuilt 3.13.15 of the live tools tree:

```text
bash docs/v0.27.0/verify.python-sqlite-build.sh --python /usr/bin/python3
bash docs/v0.27.0/verify.sqlite-source.sh
/usr/bin/python3 -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd
~/tools/python/bin/python -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd
```

## Step 1: Build SQLite as a cplx library tool

### Step 1 analysis and intent

The third route of the sandbox-gap choices applies: a library built as a cplx
tool and consumed through a `_tool` line. The autoconf build needs three
adaptations to the sandbox: its `jimsh0` bootstrap cannot receive `--sysroot`
through `CC_FOR_BUILD`, its math probe is satisfied by an inlined `ceil` and
drops `-lm`, and the default linker flags write `DT_RPATH`. The existing
`remove_package` stops at the first cpio notice, which would leave the
distribution's `libsqlite3.so.0.8.6` behind.

### Step 1 implementation

Files:

- `src/setups/env/bin/packages_management.sh` (existing): skip `cpio:`
  notices once the payload listing has started, so removal reaches every file.
- `src/install/env/install` (existing): an optional `verify_archive` hook
  receives the exact archive the dispatcher selected, before extraction; a
  refusal stops with exit 27 and nothing extracted.
- `src/install/env/sqlite/sqlite_install_functions.sh` (new):
  - `sqlite_pinned_identity` holds, per version, the archive SHA-256 and
    SHA3-256, the amalgamation SHA3-256 and the source id; an unknown version
    has none and is refused;
  - `verify_archive` checks the selected archive's two digests, then the
    amalgamation digest and the header source id streamed from its members,
    before extraction;
  - `sqlite_verify_sources` checks the selected archive and the extracted
    tree again before configure and make, since a reused tree is not
    re-extracted;
  - `configure` builds `jimsh0` first with the sandbox compiler and
    `--sysroot`, then configures with `--soname=legacy`, the parity options,
    `-Wl,--enable-new-dtags -lm` and no `DISABLE_DIRSYNC`;
  - `sqlite_check_library` checks SONAME, `libm.so.6`, the absence of
    `DT_RPATH` and the highest `GLIBC_` node, after the build and after the
    installation;
  - `post_install_check` checks that both links reach the versioned library
    and that no `libsqlite3.so.0.8.6` exists.
- `src/setups/pkgs/sqlite/sqlite_rhel_9.6_x86_64.txt` (new): the compile set,
  the first fifteen lines of Python's list.
- `src/setups/setup.tpl.properties`, `src/setups/env/cplx.tpl.properties`
  (existing): `sqlite` ordered between `git` and `python`.
- `tools/senv.local.tpl` (existing): the `sqlite` block with version, source
  URL and the two check paths, whose basenames must match.
- `docs/v0.27.0/verify.sqlite-source.sh` (new): the real installer and tool
  functions on synthetic archives, with a fixture pin table; a corrupt
  selected archive, an unknown version, a newer non-canonical archive beside
  the canonical one, a wrong member digest and a wrong source id are refused
  with exit 27 and nothing extracted; the canonical archive reaches
  configure; a tampered reused tree is refused before configure.

Completion: the tool builds and deploys
`sqlite-3.54.1-<timestamp>.el9.x86_64.tar.gz`, and its build log shows the four
source values matching and the library checks passing twice.

### Step 1 addendums

- `CPLX_BIN` stays empty: the tool ships a library, not a command.
- The `sqlite3` CLI that `make install` builds is used only to read the
  options in Step 2; it is not shipped through Python's sandbox.
- Code review round 1 found the first implementation checking a fixed archive
  name inside `configure`, after the dispatcher had already extracted the
  archive it selected. The `verify_archive` hook and its fixtures above are
  the correction; the library built on the build host is unchanged, since
  that build used the canonical archive.

## Step 2: Link Python to the bundled SQLite and require its exact build

### Step 2 analysis and intent

Python must stop receiving `sqlite-libs` and `sqlite-devel` and receive the
`sqlite` package instead. Its `build()` reuses an existing tree, so a new
SQLite would otherwise keep `_sqlite3` linked against the old headers. The
item 6 probe proved a provider identity, not a SQLite build, and had no WAL
check.

### Step 2 implementation

Files:

- `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt` (existing): replace the
  two distribution lines by `_sqlite`.
- `src/install/env/python/python_install_functions.sh` (existing):
  - `python_sqlite_inputs` hashes the sandbox header and the resolved library;
  - `configure` records them in `cplx-sqlite-inputs.txt`;
  - `python_setenv` retires `config.log` when they differ or were never
    recorded, which forces reconfiguration, and stops with exit 26 when the
    inputs cannot be read;
  - every probe call passes `--expected-sqlite`.
- `src/install/env/python/sqlite_expected.txt` (new): `version`, `source_id`
  and 51 `compile_option` lines, read from the installed library.
- `src/install/env/python/sqlite_probe.py` (existing):
  - `load_expected_sqlite` refuses a missing, repeated or unknown key;
  - `observe_sqlite` reads version, source id and `PRAGMA compile_options`;
  - `check_sqlite_build` compares them with the expected build;
  - `check_provider_directory` refuses a second real `libsqlite3.so*` beside
    the provider;
  - `wal_smoke` runs three writer processes of forty rows each at
    `synchronous=FULL` with passive checkpoints, then a truncating checkpoint,
    a reopen and an integrity check.
- `tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py`
  (existing): mismatch, ambiguity, second provider, linker names, real WAL
  writers, failed writer and lost rows.
- `docs/v0.27.0/verify.python-sqlite-build.sh` (existing): the three input
  cases, changed, unrecorded and unavailable.
- `docs/v0.27.0/acceptance.python-sqlite-support.sh` and
  `docs/v0.27.0/verify.python-sqlite-acceptance.sh` (existing): pass and audit
  the expected-build file in the operator probe.

Completion: the Python rebuild reports `_sqlite3... yes` after an automatic
reconfiguration, and the build and installed probes pass with the `sqlite` and
`wal` records.

### Step 2 addendums

- The unit tests use a synthetic compile option for the mismatch case, since
  a host SQLite may already report any real option.

## Step 3: Document the bundled SQLite

### Step 3 implementation

Files:

- `wiki/explanation/why-the-toolchain-builds-its-own-sqlite.md` (new).
- `wiki/how-to/build-and-verify-the-bundled-sqlite.md` (new), with a refusal
  table.
- `wiki/reference/bundled-sqlite.md` (new).
- `wiki/how-to/check-python-sqlite-capability.md`,
  `wiki/how-to/rebuild-and-publish-the-tools-archive.md`,
  `wiki/explanation/where-a-sandbox-file-comes-from.md`,
  `wiki/reference/exit-codes.md` and `wiki/README.md` (existing).

### Step 3 addendums

- The first two existing how-to pages were introduced on item 8's branch.
  When this item returns to the integration branch before item 8, their
  updates follow item 8 there, and the new pages' links to them resolve once
  item 8 lands.

## Step 4: Promote, package and qualify the archive on RHEL 9.8

### Step 4 analysis and intent

The archive is packaged from the live tree, so promotion comes first; the
development environment of that tree moves to 3.13.15 with it, by user
decision. The closure gate refuses differing loader bytes and duplicate
lookup names across tool roots.

### Step 4 implementation

- Promote with `rsync.sh`, then run the operator probe on the live wrapper.
- Repeat item 7's coherent-runtime preparation, aligning the Git root's shared
  runtime files to Python's bytes, and remove the orphan `sqlite-libs` payload
  from the Git root, where no ELF needs it.
- Package with `pkg_tools.sh` and keep the previous archive for rollback.
- In a scratch directory, relocate the archive fresh and as an upgrade over
  the previous archive; run the wrapper probe, the CPython SQLite tests, an
  application-style venv check and the leak scans.

Completion: closure gate OK, both installs pass every check.

## Step 5: Qualify the archive on the Debian 12 agent

### Step 5 analysis and intent

The agent fetches inputs from the snapshot repository only. Candidate mode
needs the archive and a verification bundle from a committed cplx revision,
and refuses a release verification pin beside them.

### Step 5 implementation

- Compose the bundle with `ci/deliver-closure-tools.sh --bundle` at the
  committed revision; upload the archive and the bundle as one snapshot.
- In the consuming project, a temporary pipeline commit pins the candidate,
  drops the release verification pin and runs: fetch and relocate, the wrapper
  probe with the bundle's probe and expected-build file, the CPython SQLite
  tests, the application venv and its SQLite check, and a loader check on both
  interpreters. It archives the evidence and skips the build stages and
  publication.
- The loader check reads only the interpreter process of the `LD_DEBUG`
  trace, since the wrapper's host helpers inherit it, and excludes the
  platform's monitoring library by the pipeline's existing rule. The venv
  check binds the provider mapping through the probe's held reference, as
  the probe does on overlay filesystems.
- Once the run is green, a restore commit removes the three changes.

Completion: every step of the run passes, and the restore commit is pushed.

## Implementation decisions for the bundled SQLite

| Decision | Choice | Source |
| --- | --- | --- |
| Release | 3.54.1, newest stable with the WAL-reset fix | D12, user, 2026-10-26 |
| Directory sync | `DISABLE_DIRSYNC` left out | D12, user, 2026-10-26 |
| Development tree | promote to 3.13.15 and package from it | user, 2026-10-27 |
| Debian check | temporary pipeline commit, then restore | user, 2026-10-27 |
