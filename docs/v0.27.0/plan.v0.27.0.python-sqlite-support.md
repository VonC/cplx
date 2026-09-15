# v0.27.0 Python SQLite support implementation plan

Implement and prove SQLite capability in the RHEL 9 x86_64 Python toolchain,
then carry one identified non-release candidate through isolated acceptance.

References: [requirement](feature-request.v0.27.0.python-sqlite-support.md),
[design](design.v0.27.0.python-sqlite-support.md),
[umbrella item 6](draft.v0.27.0.debian-agent-tools.md) and
[environment reference](reference.environments.md).

## Ordered delivery for the SQLite candidate

1. Add the shared probe and focused verification; establish acceptance prerequisites.
2. Wire scoped configure inputs and source/installed capability checks.
3. Align the closure declaration and envelope with the candidate.
4. Build, assemble and deploy the isolated candidate; retain acceptance evidence.

The six design decisions and matching requirement correction are settled.
This plan assigns implementation files and execution gates. Item 7 owns the
final refresh, D5 version re-check, full integration and publication. Its work
is not satisfied by the item 6 candidate.

## Confirmed implementation constraints

- `python_install_functions.sh` builds or reuses `python`; its current configure array has no explicit SQLite dependency inputs.
- The shared driver has a checked configure marker and an explicit `--reconfigure` route that forces cleanup. Shared installation can reuse an existing prefix by timestamp.
- `main()` checks each stage's status and advances the installation `current` only after success. The optional callback belongs between successful `install()` and `package()`.
- The build environment exports sandbox `LD_LIBRARY_PATH` and `LD_RUN_PATH`. Passing its probe proves build capability; relocated acceptance must use the normal operator invocation without added overrides.
- `src/setups/env/.env` sources the incoming home's `.profile`, then sets `HOME` to its own directory. The build launcher receives the isolated account home; `.env` rebinds it to the isolated cplx root inside the build child. Promotion and packaging receive the enclosing account home.
- `rsync.sh` reads both Git and Python selectors, writes an exclude scratch file, mirrors into `$HOME/tools`, and deletes other version directories. The complete layout must be isolated.
- The installer rewrites `/home/<one-segment>/cplx/tools/` and `/home/<one-segment>/` anchors. A nested scratch build home leaves an unwanted path segment after relocation. H2 therefore requires an independently writable isolated home directly below `/home`, supplied without administrator operations by this workflow. Its availability is an external prerequisite.
- The closure envelope's source is a real 40-character commit containing the declared path. `closure_config_authority_check()` compares its blob's digest with the carried declaration. An invented SHA or the old declaration's commit cannot certify new bytes.
- `.review-validation` requires `bash src/utils/lint_shell.sh`. The repository has no `GROUNDHOG.md`, `pyproject.toml` or existing `tests/` tree; its effort harnesses use Bash fixtures.

### Physical-line inventory for the SQLite plan

Counts include blank lines and any final unterminated line, measured at
`c0b0d4f`. Recount before editing. Read-only entries identify integration
boundaries and do not authorize unrelated changes.

| Existing file | Lines | Planned use |
| --- | --- | --- |
| `src/install/env/python/python_install_functions.sh` | 51 | Step 2: Python policy and callers |
| `src/install/env/install` | 406 | Step 2: optional callback and status propagation |
| `src/install/env/install_functions.sh` | 327 | Read-only environment and installation reuse |
| `src/install/env/python/bin/python` | 131 | Read-only operator invocation |
| `src/install/env/python/bin/setenv` | 24 | Read-only operator environment |
| `src/install/install.bat` | 127 | Read-only remote status boundary |
| `src/setups/env/.env` | 251 | Read-only profile and HOME behavior |
| `src/setups/env/bin/rsync.sh` | 181 | Read-only promotion entry point |
| `src/setups/env/bin/pkg_tools.sh` | 270 | Read-only full archive entry point |
| `src/setups/env/bin/pkg.sh` | 452 | Read-only archive identity and staging |
| `src/setups/env/bin/install_pkg.sh` | 1308 | Read-only relocation entry point |
| `src/setups/env/bin/closure_check.sh` | 617 | Read-only closure orchestration |
| `src/setups/env/bin/closure_config.sh` | 636 | Read-only declaration and envelope grammar |
| `src/setups/env/bin/closure_publish.sh` | 650 | Read-only source authority helper |
| `src/setups/env/closure/closure-config.txt` | 34 | Step 3: version declaration and waiver |
| `src/setups/env/closure/closure-envelope.txt` | 3 | Step 3: exact-byte digest and source identity |
| `src/setups/env/closure/README.md` | 108 | Step 3: record item 6 ownership and maintenance commands |
| `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt` | 59 | Read-only selected SQLite payload inputs |
| `tools/senv.local.tpl` | 238 | Read-only 3.13.15 candidate pin |
| `docs/v0.27.0/verify.closure-check.sh` | 9136 | Existing regression harness; do not grow |
| `docs/v0.27.0/verify.install-pkg.sh` | 2181 | Existing relocation regression harness; do not grow |
| `src/utils/lint_shell.sh` | 43 | Mandatory shell lint floor |
| `.review-validation` | 21 | Read-only mandatory command inventory |
| `check.bat` | 26 | Read-only Windows environment precedent |

All new files below start at zero lines. Only Python files have the shared
650-line ceiling. Below 550 is safe to extend; 550-650 is at risk and needs
concrete extraction guidance; above 650 requires a responsibility split.
Existing large Bash scripts have no Python ceiling and are not split by this
effort. Estimates are advisory and exceeding one below 650 is not missing work.

| New file | Responsibility | Advisory lines |
| --- | --- | --- |
| `src/install/env/python/sqlite_probe.py` | Standard-library database and provider probe | 300 |
| `tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py` | Pure identity/parser and database tests | 420 |
| `tests/__init__.py` | Test package marker | 0 |
| `tests/unit/__init__.py` | Test package marker | 0 |
| `tests/unit/sqlite_probe/__init__.py` | Test package marker | 0 |
| `tests/unit/sqlite_probe/test_sqlite_probe/__init__.py` | Test package marker | 0 |
| `docs/v0.27.0/verify.python-sqlite.sh` | Cumulative lint and fixture runner | 180 |
| `docs/v0.27.0/verify.python-sqlite-build.sh` | Driver, scope and reuse fixtures | 320 |
| `docs/v0.27.0/verify.python-sqlite-closure.sh` | Candidate bundle and closure refusal fixtures | 220 |
| `docs/v0.27.0/acceptance.python-sqlite-support.sh` | Explicit isolated acceptance phases and evidence capture | 360 |
| `docs/v0.27.0/acceptance.python-sqlite-support.md` | Sanitized prerequisite, command and candidate evidence | 220 |

The plan and validation skeleton are documentation, counted when written and
reviewed. Each step updates its matching validation section during the later
implementation check; this initial skeleton records no completed work.

## File-based IO cost clarification for SQLite implementation

Each probe creates one temporary file-backed database, commits a fixed record,
closes/reopens it, and reads `/proc/self/maps` once after the database operation.
SQLite's own bounded journal files are part of that operation. Resolve only
the supplied extension/provider paths and relevant map entries; do not scan
whole tool trees to discover a provider. Parse maps in linear time and deduplicate
mapping identities in a set. Emit one structured result; diagnostic stderr must
not corrupt it. Remove only that invocation's temporary database directory.

Build checks run once at each required stage, including reuse, with no extra
compile or automatic cache purge. Reuse existing closure inventories and
packaging stages. Hash the completed candidate once per transfer boundary to
establish byte identity. Live preservation records cover the actual write
boundaries; do not hash every cached RPM for every fixture test.

No Step 0 timeout/xfail phase is needed: there is no interactive latency target.
Use read/call counts and generated identity permutations for deterministic cost
checks, retaining elapsed timings as observations rather than arbitrary gates.

## Shared execution command checklist for SQLite steps

The runner uses `--step 1` through `--step 4` cumulatively and accepts an
explicit `--python PATH` for authoring tests. It validates that interpreter's
standard library before running the new `unittest` suite. Authoring Python
executes unit tests only; every build or acceptance probe runs under the
toolchain interpreter being assessed. No host Python package installation is
required. The production probe is a standalone script, so it needs no package
`__init__.py`; the four new test package directories do.

The existing support-tree copy ships `src/install/env/python/sqlite_probe.py`
as `cplx/tools/python/sqlite_probe.py` on the build host. Acceptance receives
the same tested script bytes as verification material; record their digest
at both locations. Do not substitute a separately maintained probe.

This adapts the standard `ghog day`/pytest plan to the repository's declared
Bash floor. Do not invent a project pytest coverage gate, call `check.bat` or
pytest directly, or add effort commands to `.review-validation`. Run the
mandatory lint floor and explicit cumulative checks in one runner. Report
behavioral case coverage and actual unit results, without a fabricated coverage
percentage. New production Python receives syntax and unit checks; new and
existing effort Bash files receive `bash -n` and ShellCheck explicitly because
the tracked-file floor excludes `docs/` and cannot see untracked new files.

For each step:

1. Record `git status --porcelain` and count every touched file with `[IO.File]::ReadAllLines(path).Length` on Windows or `awk 'END {print NR}' file` in Bash.
2. Add the step's failing cases first. Fixture subprocesses use copied scripts in an invocation-owned root, synthetic properties and recording command stubs. `readlink -f` must stay inside the copy. Never source the real `.env` or invoke real SSH, setup, compilation or packaging from unit fixtures.
3. Run the affected cases, implement, then run the cumulative runner. Keep the first useful failure and retain nonzero process statuses; a successful diagnostic print is not evidence of command success.
4. Verify callback order and fixture filesystem preservation even after failure. Assert stub destinations are within the fixture root; retain diagnostics until assessed.
5. Run the step's `rg` checks and `git diff --check`. Recount, record Python policy bands and split a Python file above 650 by responsibility. At 550-650, prefer moving fixture factories or map parsing tests into a separate focused module if needed.
6. Record the command, interpreter/shell identity, exit status, named cases and elapsed time in the validation document. Repeat only after fixes or a concrete change to inputs.

Native Linux, in the prepared test environment:

```sh
bash docs/v0.27.0/verify.python-sqlite.sh --step N --python /absolute/path/to/python3
```

On Windows, create an ignored `a.sqlite-check.cmd` with the following commands;
substitute the current step for `N` and the selected Python executable's actual
path. Run it with `cmd /d /c a.sqlite-check.cmd`. The setup call and Git Bash
invocation must share that CMD process. Never select WSL's `bash.exe` by accident.

```bat
@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "NO_MORE_SENV_cplx="
call <NUL senv.bat
if errorlevel 1 exit /b %ERRORLEVEL%
"%GH%\bin\bash.exe" docs/v0.27.0/verify.python-sqlite.sh --step N --python "C:/absolute/path/to/python.exe"
exit /b %ERRORLEVEL%
```

Windows tests exercise pure mapping logic with fixtures; Linux exercises real
`/proc/self/maps`. A Windows fixture result never substitutes for Linux live
provider observation. The Step 2 runner checks the existing Windows remote
status boundary with a copied launcher and synthetic remote result when run
on Windows, recording that check as separately required on Linux.

## Step 1: Implement the shared probe and establish acceptance prerequisites

### Step 1 analysis and intent

The same database and provider rules must govern source, installed and operator
checks. Add one standard-library script with testable pure functions. Before
expensive implementation acceptance, resolve the actual container/copy route
and the isolated layout's profile, HOME and relocation constraints. Absence is
a recorded prerequisite failure, never permission to replace live tools.
At the start of Step 1, before probe implementation, confirm access to the
required directly anchored isolated home. Report its absence to the design
workflow immediately; independent local work can then proceed with that
acceptance blocker recorded.

The probe adds linear map parsing and bounded database IO. It changes no build
result until Step 2 wires it. Existing tool wrappers and closure policy remain
the owners of invocation and static validation.

### Step 1 implementation

Files:

- `src/install/env/python/sqlite_probe.py` (new, to be created).
- `tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py` (new, to be created).
- `tests/__init__.py` (new, to be created).
- `tests/unit/__init__.py` (new, to be created).
- `tests/unit/sqlite_probe/__init__.py` (new, to be created).
- `tests/unit/sqlite_probe/test_sqlite_probe/__init__.py` (new, to be created).
- `docs/v0.27.0/verify.python-sqlite.sh` (new, to be created).
- `docs/v0.27.0/acceptance.python-sqlite-support.md` (new, to be created).

Test first: persistence after close/reopen; unavailable `_sqlite3`; wrong
extension root; duplicate map segments and map ordering; spaces, escaped path
characters and malformed records; absent/unreadable/deleted backing files;
versioned provider symlinks; root symlink acceptance; symlink escape; another
tool/host provider; two distinct provider identities; mismatched device/inode;
missing maps and missing probe material; source-stage module links backed by
`Modules/`; mismatched or unobservable source `libpython`. Generate permutations and duplicates
using the standard library, without Hypothesis or other PBT dependencies.
Keep synthetic parser inputs internal to unit tests, not a CLI pass override.
The unit test loads `src/install/env/python/sqlite_probe.py` by file path,
for example with `importlib.util.spec_from_file_location`; the standalone
probe needs no production package import.

Implement functions for argument validation, canonical containment, map
parsing, provider identity comparison, database operation and result emission.
Inputs include `--stage`, `--expected-python-root`, `--expected-extension-root`,
`--expected-provider` and caller-owned `--scratch-dir`. The caller chooses these
independently; the expected provider names the shipped `libsqlite3.so.0` link.
The build stage additionally requires `--expected-libpython`, selected from
the build configuration, and checks that identity using the same maps read.
Resolve its backing file, compare both canonical path containment and Linux
device/inode evidence, and reject competing SQLite backing files. Preserve
unrelated map entries without treating them as SQLite providers.

Use `build`, `installed` and `operator` stage labels. Record Python version,
executable, `_sqlite3.__file__`, database outcome, canonical provider/path identity
and overall outcome in one JSON result; include source `libpython` evidence
for the build stage. The caller supplies the stage's allowed
extension directory; the shared helper enforces that caller-selected boundary.
For source output, check the normalized import path inside the generated
directory and its canonical backing file inside the build's `Modules/` output.
Accept CPython's generated module symlink, but reject a link escaping the source
tree. Installed/operator extension backing files must remain in their supplied
`lib-dynload` directory. Test these distinct stage rules explicitly.
Nonzero failure or inconclusive status must accompany unsuccessful results,
including import failure; avoid importing SQLite at module import time so the
error can still be reported. Do not infer expected roots from observed modules.

Record a read-only prerequisite assessment in the acceptance document: actual
RHEL build role, availability of the required separate `/home/<one-segment>`
home with independent cplx/tools trees, login-profile
chain and digest, closure source-identity procedure, Debian container runtime
host and archive-copy route. Check the installer's existing anchor handling
against the exact proposed source paths; nested isolation is already excluded.
If no compatible isolation or Debian
route exists, record the blocker and leave real acceptance incomplete; local
probe work may continue. Access details stay in ignored operations notes.
Using live staging instead would amend settled design H2; extending relocation
would also amend the owning requirement. Neither is a plan option or fallback.
Report a missing compatible home to the design workflow before requesting
either scope change. Do not create an account or request elevated execution.

Completion: pure tests pass on the authoring platform; real Linux observation
passes a controlled provider fixture or records the required Linux run as
outstanding; every acceptance prerequisite is explicitly established or
recorded as blocking Step 4. Fixture success alone does not satisfy AC4.

### Step 1 addendums

- Line budget checkpoint: both Python files start at 0, safe band, ceiling 650; advisory 300/420. Test markers start at 0. Split parser fixtures from database integration tests if either Python file exceeds 650; no tighter mandatory estimate applies.
- Execute the shared checklist and `--step 1`; inspect `rg -n 'sqlite3|/proc/self/maps|expected|LD_LIBRARY_PATH' src/install/env/python/sqlite_probe.py tests/unit/sqlite_probe`.
- Timing readiness: record unit and Linux probe duration separately. No time-gated xfail or full compile is planned here.

## Step 2: Enforce SQLite capability before Python packaging

### Step 2 analysis and intent

Successful configure/make or a reused timestamp does not establish installed
SQLite capability. Use one Python-owned scope predicate for the declared
`el9.x86_64` family, check source output after build or reuse, and check the
requested prefix after installation or reuse. The shared callback carries no
Python-specific condition and preserves other tools' stage order.

Complexity increases by two bounded probe invocations for scoped Python builds.
No automatic reconfiguration or unrelated cache removal is added. Capability
failure protects packaging and selector advancement, without promising rollback
of an already selected prefix's internal files.

### Step 2 implementation

Files:

- `src/install/env/python/python_install_functions.sh` (existing, to be updated).
- `src/install/env/install` (existing, to be updated).
- `docs/v0.27.0/verify.python-sqlite-build.sh` (new, to be created).
- `docs/v0.27.0/verify.python-sqlite.sh` (existing, to be updated after Step 1).

Test first with copied driver/tool support and stubs: selected and other family;
explicit configure variables; fresh compilation and both existing `python` and
`git-add` reuse branches; source failure; installed failure after install and
timestamp reuse; absent probe; generic tool without callback; callback success
and nonzero failure; previous stage failure suppressing callback; package and
selector unchanged on failure. Run process fixtures because `fatal` exits.
Also cover missing/stale `pybuilddir.txt`, an extension elsewhere in the source
tree, the supported generated module symlink, inherited `PYTHONPATH`, source
library precedence and a mismatched or missing mapped `libpython` identity.

Implement Python helpers `python_sqlite_required` and `python_check_sqlite`.
Append the two approved `LIBSQLITE3_*` assignments to the configure environment
only when the predicate matches. Preserve existing configure flags and shared
runtime paths. After either build branch, validate the current build's
`pybuilddir.txt`: one relative generated directory under the source tree,
present and consistent with that build's configuration; reject missing,
placeholder, escaping or stale records. Pass its exact directory as the
extension boundary, with the generated `_sqlite3` link backed by `Modules/`.
Do not guess the directory from host Python or accept an arbitrary source file.
Run `${tool_src}/python` with a command-scoped `LD_LIBRARY_PATH` that puts the
canonical build directory first and retains inherited entries afterward,
matching CPython's Linux `RUNSHARED` behavior. Pass the configured build
`libpython3.13.so` backing identity as `--expected-libpython`; reject an old
installed library even if the binary starts. Keep
`${root}/usr/lib64/libsqlite3.so.0` as the expected SQLite provider under
`${root}`. Validate the actual pinned source artifacts during implementation.
The [CPython build rules](https://github.com/python/cpython/blob/3.13/Makefile.pre.in)
define the generated import-directory links, and
[Linux configuration](https://github.com/python/cpython/blob/3.13/configure.ac)
defines the source shared-library environment. This build-only environment
does not alter normal operator acceptance.

Add Python's `post_install_check()` that applies the same scope predicate and
runs `${tool_prefix}/bin/python3` against the exact requested prefix's
`lib/python3.13/lib-dynload`. The expected provider is still the selected
Python sandbox. Validate the executable path and reject an old `current`
selector or an unexpected wrapper/target path before executing it.

In the shared `main()`, call the optional `post_install_check` function only
after `install()` succeeds and before `package()`. Capture and return its
nonzero status with stage context, matching existing checked stages. Tools
without this function continue through the existing sequence. Retain the
underlying interpreter diagnostic, requested version and expected paths.

Exercise the existing explicit `--reconfigure` route with a successful config
marker and compiled Python already present. Assert configure, clean and make
order; preserve an unrelated sandbox sentinel; establish that the installed
extension passes. Ordinary stale reuse must fail without automatically cleaning.
The copied Windows launcher fixture must prove remote nonzero results remain
failures at the authoring entry point.

Completion: cumulative fixtures pass; selected-family fresh and reuse checks
are enforced; other targets/tools preserve behavior. Real populated-tree build
and installed-prefix proof remain Step 4 acceptance work.

### Step 2 addendums

- Line budget checkpoint: Bash baselines 51 and 406; new harness 0, runner recount from Step 1. Python ceiling 650 applies if Step 1's Python helpers need changes; retain recorded baselines and policy bands. Bash estimates are advisory and no unrelated split is required.
- Execute the shared checklist and `--step 2`; inspect `rg -n 'post_install_check|res_install|res_package|current' src/install/env/install` and `rg -n 'LIBSQLITE3|python_sqlite|required|check_sqlite' src/install/env/python`.
- Timing readiness: preserve fixture call counts and ordering, then retain separate configure/compile/install timings in Step 4. No time-gated status applies.

## Step 3: Bind the candidate layout to its closure declaration

### Step 3 analysis and intent

The approved candidate uses Python 3.13.15 and supplies SQLite in the Python
root. The committed declaration still describes 3.13.9 and waives SQLite.
Change those entries and the paired envelope without widening checker policy.
Source anchoring must be reproducible without a self-referential commit hash.

### Step 3 implementation

Files:

- `src/setups/env/closure/closure-config.txt` (existing, to be updated).
- `src/setups/env/closure/closure-envelope.txt` (existing, to be updated).
- `src/setups/env/closure/README.md` (existing, to be updated).
- `docs/v0.27.0/verify.python-sqlite-closure.sh` (new, to be created).
- `docs/v0.27.0/verify.python-sqlite.sh` (existing, to be updated after Step 2).

Test first: candidate version accepted with `root`/`current`; retained 3.13.9
UNEXPECTED; missing SQLite; SQLite only under Git; stale waiver with present
SQLite; altered declaration with unchanged envelope; CRLF byte change; changed
source blob; valid exact source identity. Use the existing checker functions
on isolated fixture trees, keeping static floor cases distinct from dynamic
probe cases. Run applicable existing closure Step 2 and Step 5 regression
suites once after the change, using their documented prepared corpus.

Replace `subdir|python|python-3.13.9` with
`subdir|python|python-3.13.15`; retain Python `root` and `current` records and
the `libsqlite3.so.0` floor at `tools/python`. Remove only the SQLite waiver
when the candidate payload satisfies the existing condition. Do not change
grammar, root ordering, entry points, other tools or refusal rules.

Prepare exact LF UTF-8 declaration bytes, including comments and final newline.
Before creating the auxiliary evidence commit, prepare its complete one-path
diff, parent SHA, message, hook execution and merge procedure for explicit human
authorization. This is a specific exception to the grouped `a.commit` route,
not authorization granted by this plan. Keep configured hooks active: the evidence
commit and reviewed bundle run `pre-commit` and `commit-msg`; the `-s ours`
merge invokes `pre-merge-commit` and `commit-msg`. Record any configured
`pre-merge-commit` chaining to `pre-commit`; do not imply that Git directly
invokes `pre-commit` for a merge. Its verified identical tree adds no content.
The evidence commit's parent is the clean implementation branch HEAD and its
only changed path is the declaration; it is a source snapshot, not a delivered
bundle. Retain a temporary local ref while assembling the reviewed bundle.

Compute the digest from `git cat-file blob <source-sha>:src/setups/env/closure/closure-config.txt`,
not a Windows working-tree file. Write that real source SHA and exact digest
into the envelope. Commit the declaration and renewed envelope together through
the normal grouped review gate, then, with the same explicit auxiliary-operation
authorization, use `git merge -s ours --no-ff <source-sha>` to retain the source
commit as an ancestor. Require a clean worktree and identical before/after tree
IDs for the merge. Verify hooks and authority checks, and prove a fresh local
clone of the implementation branch resolves the source without extra refs.
This topology includes a non-first-parent source snapshot lacking its renewed
envelope; all-ancestor traversal can encounter it. Record that limitation and
the merge in item 7's handoff. No push runs. Never guess the final commit SHA,
leave an unreachable anchor or weaken the authority helper for old source bytes.

Document the chosen exact commands and resulting source SHA in the closure
README/validation evidence. Verify `closure_envelope_check` and
`closure_config_authority_check` without invoking a publication operation.
The candidate's final cplx revision and the source-envelope revision are
separate identities and both belong in the evidence.

Completion: the pair is internally consistent and resolves to matching source
bytes; all named refusal controls remain effective. Packaging an actual
candidate requires Step 4's populated SQLite tree. No release publication runs.

### Step 3 addendums

- Line budget checkpoint: declaration 34, envelope 3, README 108, new Bash harness 0; runner recount from Step 2. No Python growth is planned; any amended Python remains subject to 650 and its current measured band. Leave the 9,136-line closure harness unchanged.
- Execute the shared checklist and `--step 3`; inspect `rg -n 'subdir\|python|libsqlite3|waiver' src/setups/env/closure/closure-config.txt` and verify the exact source blob digest from Git.
- Timing readiness: record focused closure and existing regression durations separately. Source authority and refusal results, not timing, gate completion.

## Step 4: Prove one candidate on the three required environment roles

### Step 4 analysis and intent

Unit and build-environment checks cannot establish relocation or prevent a host
SQLite library from masking a broken payload. Build one non-release 3.13.15
candidate, retain its byte identity, and test it on the RHEL build account,
plain Debian 12 container and isolated RHEL deployment using normal invocations.
The isolation prerequisite established in Step 1 is mandatory before mutation.

### Step 4 implementation

Files:

- `docs/v0.27.0/acceptance.python-sqlite-support.sh` (new, to be created).
- `docs/v0.27.0/acceptance.python-sqlite-support.md` (existing, to be updated after Step 1).
- `docs/v0.27.0/verify.python-sqlite.sh` (existing, to be updated after Step 3).

Test the capture driver first with recording executables: missing prerequisite,
wrong HOME, escaping source/destination link, ambiguous candidate archive,
profile violation, wrong expected roots, mismatched digest, missing JSON,
nonzero probe and missing environment role all prevent successful acceptance.
Capture failure must still run the live preservation comparison. Each phase
requires explicit root and role arguments; never default to the operator home.

Implement separate `preflight`, `build`, `assemble`, `deploy` and `probe`
phases. Keep exact access handles and scalar environment configuration in
ignored notes, not tracked scripts. Record resolved paths before any command.
Use a verified isolated account-home layout containing `cplx/`, `tools/`,
`pkgs/`, `.env` and `.env_`, with copied cplx source/configuration and independent
mutable payload copies. Do not hardlink mutable build or deployment payloads
to the live tree. Preserve and inspect symlinks; copies must not point back to
live roots. The packager retains its own existing private stage implementation.
The build account-home path must be directly below `/home` and already writable
under the operator's available access. A nested scratch home is unsupported;
absence of the required home blocks this step under confirmed H2.

Bootstrap the copied cplx tree from tracked `src/setups/env/`, `src/utils/`
to `bin/`, `src/echos/` to `echos/`, and `src/install/env/` to `tools/`, using
the existing setup layout and approved scalar configuration. Copy the needed
populated Python source/sandbox and Git payload into owned locations. Apply
Step 2 source files and Step 3 closure bundle there. Audit the complete profile
source chain before sourcing any copied `.env`. Deliberately create no `.profile`
in the isolated home; record its absence and the explicit scalar environment
used instead. Launch non-login child shells with `BASH_ENV` unset so they cannot
silently source the operator profile. Audit the copied `.env` source chain and
all retained path-valued inputs; reject live-state imports or writes outside
the owned layout. Record the distinction from the operator login environment.
Recheck the source-layout anchor against the unchanged installer before building.

The following are phase commands inside the verified layout, executed by the
acceptance script with checked absolute variables; they are not permission to
substitute an unverified scratch layout. Keep the build's `.env` HOME changes
inside its child process. Record concrete expanded invocations in the capture.

```sh
env -u BASH_ENV HOME="$sqlite_account_home" bash "$sqlite_account_home/cplx/tools/install" python 3.13.15 --reconfigure
env -u BASH_ENV HOME="$sqlite_account_home" bash "$sqlite_account_home/cplx/bin/rsync.sh" --dry-run
env -u BASH_ENV HOME="$sqlite_account_home" bash "$sqlite_account_home/cplx/bin/rsync.sh"
env -u BASH_ENV HOME="$sqlite_account_home" bash "$sqlite_account_home/cplx/bin/pkg_tools.sh"
env -u BASH_ENV HOME="$sqlite_deploy_home" bash "$sqlite_installer" tools --prefix "$sqlite_deploy_home"
```

Before build, record a successful configure marker and existing compiled
Python in the copied populated tree. Preserve unrelated payload sentinels and
cache identity. Retain `_sqlite3` detection as `yes`, source and installed
probe results, exact requested prefix and evidence that reconfigure, cleanup
and compilation ran. Then promote only inside the approved account layout,
check the ordinary build-account operator invocation, and package once.

Record archive filename, SHA-256, size, cplx source revision, Python version,
selected RPM/payload identities, closure digest and source anchor. Place only
that candidate in each isolated consumer's archive search locations so the
installer's newest-file selection cannot choose another archive. Compare its
digest before and after transfer. Keep the normal installer invocation and
probe output, including actual provider identity after database reopen/read.

For Debian, establish the runtime and copy commands from Step 1's confirmed
host. Record `/etc/os-release`, actual image digest and container identity;
`uname` alone does not establish the userland. Supply the candidate, existing
installer/verification material and shared probe without extra SQLite libraries
or package installation. Run the relocated operator path with no added library
override. Treat an absent runtime, image/copy route or provider result as missing
acceptance; do not replace it with a Windows or RHEL result.

For RHEL deployment, install into the separately verified target and run its
normal operator path. At all three roles, supply independently known canonical
Python and extension roots and the shipped provider path. Record command exit
status and structured success; wrapper output alone is insufficient. Keep
build-stage capability and operator runtime-path evidence distinctly labeled.

Once before and once after the complete acceptance sequence, compare manifests
of live cplx/build/deployment payload and control trees: path/type, link target,
size, mtime and content digests for all regular files. Keep metadata-only
inventory for explicitly excluded immutable download caches after proving they
are outside every write boundary. Validate boundaries before each phase without
rehashing live trees in fixture loops. The acceptance script owns the exact
manifest commands and runs the final comparison on failure as well. Any live
change fails the preservation claim; concurrent external changes leave the
result unresolved and require assessment before continuing.
Retain owned diagnostics; cleanup may remove only checked owned absolute paths.

Completion: all requirement AC1-AC11 cases map to passing evidence or explicit
refusal controls; actual populated-tree rebuild, candidate closure, three
environment roles and live preservation pass for the same archive. Missing
facilities leave Step 4 and item 6 incomplete. Update the evidence document
with the commands item 7 must repeat against its final archive; do not advance
umbrella completion from fixture results or publish a release.

### Step 4 addendums

- Line budget checkpoint: new Bash driver 0, advisory 360; evidence and runner recount after prior steps. No Python growth is planned. Apply the 650-line policy to any amended probe/tests and extract by responsibility if exceeded.
- Execute the shared checklist and `--step 4`, then explicit acceptance phases on confirmed hosts. Inspect `rg -n 'HOME|prefix|expected|sha256|profile' docs/v0.27.0/acceptance.python-sqlite-support.sh` and review expanded paths before mutation.
- Full workflow timing readiness: record configure, compile, install, promotion, package, transfer, relocation and probe durations once for the accepted candidate. Reuse healthy work and retain the first actionable failure. No timeout xfail or arbitrary duration limit substitutes for acceptance.

## Implementation decisions for Python SQLite support

The human confirmed the six plan recommendations after specification review
round 2. Each answer is integrated into the execution instructions above.
The separate directly anchored home and Debian runtime/copy route remain
external acceptance prerequisites. The source-evidence commit and merge still
require the concrete Step 3 authorization described in that step.

| Question | Decision and rationale | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | A1: Use the conventional `unittest` tree with an explicit authoring interpreter and file-path import of the standalone probe. This needs no third-party test dependency; build and acceptance execute the same tested probe bytes. | Shared execution command checklist; Step 1 implementation | A2: An effort-local Python test script would need a test-layout exception and complicate reuse. |
| Q02 | B1: Exercise copied complete scripts with synthetic environment and command stubs, including actual CMD failure propagation. Process fixtures prove stage order and selector preservation without a production refactor. | Shared execution command checklist; Step 2 implementation | B2: Extracting orchestration and adding source guards would expand production changes while still requiring process checks. |
| Q03 | C1: Validate `pybuilddir.txt`, the generated import path and its `Modules/` backing file; put the source directory first for the build invocation and verify mapped `libpython` identity. This rejects mixed or stale build output. | Step 1 implementation; Step 2 implementation | C2: Whole-source containment with sanitized module paths cannot independently reject a stale extension elsewhere in that tree. |
| Q04 | D2: Keep the reviewed declaration/envelope bundle paired, then retain its source snapshot through an authorized `-s ours` merge. Check configured hooks, exact committed-blob digest, unchanged merge tree and fresh-clone source resolution; record the non-first-parent snapshot limitation. | Step 3 implementation | D1: A separately retained evidence ref can be lost during transfer, making the source anchor unresolvable. |
| Q05 | E1: Confirm the compatible home first in Step 1 and establish the audited environment and Debian route. Record absent facilities as Step 4 blockers while independent local work proceeds, reporting any needed scope change to its owning design. | Step 1 analysis and implementation; Step 4 implementation | E2: Deferring facility checks until Step 4 would discover blockers after implementation. Live staging and altered relocation anchors require earlier-document changes. |
| Q06 | F1: Compare live payload/control content, type and link records once before and once after acceptance, including failure cleanup. This detects same-size changes with preserved timestamps; retain only metadata for proven excluded immutable caches. | File-based IO cost clarification; Step 4 implementation | F2: Control-file hashes plus binary metadata provide weaker evidence for live-tree preservation. |
