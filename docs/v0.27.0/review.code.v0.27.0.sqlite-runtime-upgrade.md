# Code review transcript for v0.27.0

- Exchange: code/code/v0.27.0/sqlite-runtime-upgrade
- Reviewed document: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor - Step 5

- Recorded: 2026-10-27T17:46:52+01:00
- Exchange: code/code/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: unrecorded
- Implementation step: 5
- Outcome: request

### Review identity for step 5 sqlite-runtime-upgrade (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
Implementation step: 5
Review round: 1

### Code review evidence for step 5 sqlite-runtime-upgrade (round 1)

request_index_tree: f50a3fb990fcc2a04286921e64e33360f46841e3
resolved_validation_set:

- `bash src/utils/lint_shell.sh` (sources: project)

test_scope:
{"fingerprint": "686958cdf490661b3207a810e06364a48e923f6bf1c8c33c9a555c7f23cc75b6", "group": null, "proof": "missing", "requirement": "docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md", "scope": "whole"}

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(sqlite-runtime-upgrade): record step 5 validation
group 1 path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md
```

### Validation scope for step 5 sqlite-runtime-upgrade (round 1)

Validation scope: the whole suite.

### Requestor assessment for step 5 sqlite-runtime-upgrade (round 1)

**Is step 5 fully implemented?** Yes. The candidate tools archive passed every
check of the temporary candidate stage on the Debian 12 agent (build 122), the
consuming pipeline was restored afterwards, and the step 5 record is the only
staged change.

**Scope of this review: the whole item, not only step 5.** The bundled SQLite
item was implemented before its requirement and plan existed, under an urgent
request, and no specification review ran. Steps 1 to 4 were committed without
a code review. This round therefore asks for a review of the complete item:

- the committed range `50eef52..df7bcb4` on `sqlite-runtime-upgrade`: five
  implementation commits (`f462640`, `5f31f80`, `539914c`, `b3fd94e`,
  `e505003`), the umbrella row (`fbd6199`), the item documents (`d42ce6b`) and
  the step 1 to 4 validation records (`d61784e`, `2951b4f`, `f7b4aa9`,
  `df7bcb4`);
- the staged step 5 record in the validation plan.

`git diff 50eef52 HEAD` plus the staged diff covers it all. The branch is based
on `deploy-venv-sync` (item 8); `50eef52` is that branch's tip when this item
started, and nothing below it belongs to this review.

**Tests and static checks** (2026-10-27):

- Mandatory floor `bash src/utils/lint_shell.sh`: clean, 60 tracked scripts.
- `docs/v0.27.0/verify.python-sqlite.sh --step 4` on Windows: passed (27
  closure checks, 34 acceptance fixture checks); its symlink fixtures skip on
  Windows and passed natively on RHEL (38 acceptance driver cases).
- `docs/v0.27.0/verify.python-sqlite-build.sh` on Windows: passed; its native
  cases passed on RHEL (35 installer fixtures, 3 of them new SQLite-input
  cases).
- `shellcheck -S style src/install/env/sqlite/sqlite_install_functions.sh`:
  clean.
- Probe unit tests: 49 of 49 on RHEL with Python 3.9 (host SQLite 3.34.1) and
  with the rebuilt 3.13.15 (bundled 3.54.1); 49 on Windows with 5 symlink skips.

**Coverage.** The repository declares no Python coverage gate
(`.review-validation` holds the lint floor only). The new probe functions are
exercised by the unit tests listed in the implementation report; no
percentage is claimed.

**Architecture.** The `sqlite` tool follows the existing library-tool model
(a `_sqlite` line consumed by Python, its own package list and senv block).
The probe stays a standalone standard-library script. `sqlite_probe.py` is
481 lines; the unit test module is 567 lines, above the 550-line safe band and
below the 650-line ceiling.

**Performance.** The WAL smoke check is bounded: three writer processes of 40
rows each, a 600-second per-writer timeout, one maps read per probe. Python's
reconfiguration triggers only when the recorded SQLite header or library digest
differs; unchanged inputs keep build reuse.

**Feature integrity.** `remove_package` behaves as before for payloads without
cpio notices. Python trees whose SQLite inputs are unchanged keep their reuse.
The previous Python package and tools archive remain for rollback.

**Points worth the reviewer's judgement:**

- Missing earlier gates: no specification review and no design document; the
  requirement records the decisions taken in chat.
- `b3fd94e` updates two how-to pages that were introduced on item 8's branch;
  the return to the integration branch must hold those edits until item 8
  lands, as the plan's step 3 addendum and the umbrella note say.
- The verification bundle used on Debian records revision `03e776f`, which was
  reworded into `e505003` with an identical tree.

### Implementation report for step 5 sqlite-runtime-upgrade (round 1)

The item replaces the distribution SQLite 3.34.1 payload of the toolchain
Python by SQLite 3.54.1 built from verified source as a cplx library tool
(decision D12), and makes every probe stage prove that exact build.

**Step 1, `f462640` and `5f31f80`.**

- `src/setups/env/bin/packages_management.sh`: `remove_package` skips `cpio:`
  notices once the payload listing has started; before, it stopped at the
  first notice and left `libsqlite3.so.0.8.6` behind.
- `src/install/env/sqlite/sqlite_install_functions.sh` (new, 189 lines): per
  version pinned identity (archive SHA-256 and SHA3-256, amalgamation SHA3-256,
  source id), checked before extraction; a `jimsh0` bootstrap built with the
  sandbox compiler and `--sysroot`, because `CC_FOR_BUILD` cannot carry it;
  configure with `--soname=legacy`, the parity options, `-Wl,--enable-new-dtags
  -lm` and no `DISABLE_DIRSYNC`; library checks for SONAME, `libm.so.6`, no
  `DT_RPATH` and `GLIBC_2.34` at most, after build and after installation.
- `src/setups/pkgs/sqlite/sqlite_rhel_9.6_x86_64.txt`, both property
  templates and `tools/senv.local.tpl`: the compile set and registration.

**Step 2, `539914c` and `e505003`.**

- `src/setups/pkgs/python/python_rhel_9.6_x86_64.txt`: `_sqlite` replaces
  `sqlite-libs` and `sqlite-devel`.
- `src/install/env/python/python_install_functions.sh`: `configure()` records
  the sandbox SQLite header and library digests in `cplx-sqlite-inputs.txt`;
  `python_setenv()` retires `config.log` when they differ or were never
  recorded, and stops with exit 26 when they cannot be read; every probe call
  passes `--expected-sqlite`.
- `src/install/env/python/sqlite_expected.txt` (new): version, source id and
  the 51 compile options read from the installed library.
- `src/install/env/python/sqlite_probe.py`: `load_expected_sqlite`,
  `observe_sqlite`, `check_sqlite_build`, `check_provider_directory`,
  `wal_smoke` and a required `--expected-sqlite`.
- `tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py`: build
  mismatch (synthetic option), malformed expectations, second provider,
  linker names, real WAL writers, failed writer, lost rows.
- `docs/v0.27.0/verify.python-sqlite-build.sh`: changed, unrecorded and
  unavailable SQLite inputs. `docs/v0.27.0/acceptance.python-sqlite-support.sh`
  and `verify.python-sqlite-acceptance.sh` (`e505003`): the operator probe
  passes and audits the expected-build file.

**Step 3, `b3fd94e`.** Three new wiki pages (explanation, how-to with a
refusal table, reference) and updates to the SQLite capability how-to, the
archive rebuild how-to, the sandbox provenance explanation, the exit codes and
the index.

**Step 4, operational.** Promotion to the development tree, two packaging
refusals fixed by aligning the Git root's runtime files and removing an orphan
`sqlite-libs` payload there, closure OK, archive
`tools.2026-10-27_093002.tar.gz` (SHA-256 `470b1a5e...`), fresh and upgrade
relocations with wrapper and venv checks.

**Step 5, operational.** Verification bundle composed at `03e776f`, archive
and bundle uploaded as one snapshot, temporary candidate stage in the
consuming pipeline: build 121 failed on two faults of the temporary checks
(fixed), build 122 passed every step, and the consuming pipeline was restored.

**Documents, `fbd6199` to `df7bcb4` plus the staged record.** Umbrella row 9,
D12 and the item 9 details; the child draft, feature-request and plan; the
validation plan, recorded one step per commit as the commit checker requires.

Writer notes: `.reviews/a.sqlite-runtime-upgrade.step5.journal.md` and
`.reviews/a.sqlite-runtime-upgrade.step5.handoff.md`.

### Change summary for step 5 sqlite-runtime-upgrade (round 1)

Staged paths:

- `docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md`: the step 5
  record and the introduction stating that all five steps are implemented and
  that the code review is pending; the document line stays
  `No, it is not implemented.`

Root `a.commit` groups:

1. `docs(sqlite-runtime-upgrade): record step 5 validation`: the validation
   plan.

Committed and in scope for this round (see the assessment):
`50eef52..df7bcb4`, eleven commits, listed in the implementation report.

### Writer response for step 5 sqlite-runtime-upgrade (round 1)

Writer response:

First round of this exchange: there is no earlier feedback to accept or
dispute.

### Reviewer focus for step 5 sqlite-runtime-upgrade (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-5-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `codex`

Completed artifacts:

- `.reviews/a.review-active.code.code.v0.27.0.sqlite-runtime-upgrade.md`
- `.reviews/a.review-requested.code.v0.27.0.sqlite-runtime-upgrade.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer - Step 5

- Recorded: 2026-10-27T18:01:35+01:00
- Exchange: code/code/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Implementation step: 5
- Outcome: answer

### Assessed index identity for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

Baseline index tree: f50a3fb990fcc2a04286921e64e33360f46841e3

Assessed index tree: 88ccb77355714fbac3b1890ee631d2492d50727f

### Implementation check for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

Result:

Yes. Step 5 has been fully implemented.

The operational step is supported by the writer's detailed successful Debian candidate report and restore record. Independently checked the local verification bundle SHA-256, the identical original/reworded cplx trees, the consumer's candidate pins, the temporary pipeline's checks and early return before ordinary build/publication, and the restored consumer tree against its pre-candidate tree. The successful CI log and remote push were not independently retrieved; those execution outcomes remain writer evidence.

The exact formal step and staged subject are step 5 and its validation document. As expressly requested, the assessment also inspected committed range 50eef52..df7bcb4, covering the SQLite tool, Python integration/probe/tests, payload removal, documentation and earlier validation records. F1 is an earlier-step defect in that requested broader scope. It does not turn the historical Debian run into a failure.

Step 5 adds no production class, layer dependency or persistent runtime cost. No architecture or performance defect was found in this step. The broader probe remains a standard-library boundary tool: mapping work is linear, option/provider sorting is small and bounded, and three writers have individual timeouts and cleanup. All new probe top-level helpers are exercised by tests or referenced from production assessment paths. No Python coverage gate is configured, and no percentage or full branch coverage is claimed. The staged step changes no unit-tested class. Source-verification regression coverage must accompany F1.

Validation plan effects:

Only the Step 5 section of `docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md` was edited. Its exact Yes sentence remains; the reviewer added the evidence limits and architecture/performance/unit-test/feature-integrity assessment and removed private CI run identifiers. This is polishing-only review metadata. No earlier-step verdict, document-level completion line, umbrella row, implementation or test was edited. No Missing work for Step 5 section is warranted for the operational step; F1 is returned as earlier-step boundary work.

### Pre-repair mandatory checks and coverage for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

Requestor evidence reports a clean mandatory shell lint floor, successful installer/acceptance fixtures, and 49 probe unit tests on both native interpreters; the Windows symlink skips are disclosed. It also records successful native and Debian qualification. These results were inspected as reports, not rerun.

Reviewer execution was limited to read-only source/Git/artifact inspection, bundle SHA-256, the current validation resolver, the independent commit-plan checker and evidence launchers. Neither optional ghog check nor ghog affected was needed for this documentation-only staged step. No ghog day/full, coverage measurement or mandatory writer validation command was run.

The core-returned scope capture is valid whole-suite scope with fingerprint `686958cdf490661b3207a810e06364a48e923f6bf1c8c33c9a555c7f23cc75b6`. The request's missing proof field does not mean its bound scope file is absent, and the capture itself is not evidence that tests passed.

### Resolved validation set and sources for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

The request records one mandatory command:

- `bash src/utils/lint_shell.sh` (source: project).

The current resolver, supplied with the plan's shared checklist at lines 29-43, also includes these plan-source additions:

- `bash docs/v0.27.0/verify.python-sqlite.sh --step 4 --python C:/absolute/path/to/python.exe`
- `bash docs/v0.27.0/verify.python-sqlite-build.sh --python C:/absolute/path/to/python.exe`
- `shellcheck -S style src/install/env/sqlite/sqlite_install_functions.sh`
- `python3 -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd`

The Windows interpreter placeholders above are quoted from the plan, not executable evidence. The writer must supply the actual interpreter paths/environment in the next request. The plan also calls for the unit command with both native interpreters. No declared command was executed by the reviewer.

### Resolver drift and direction for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

F2: the embedded set omits all four plan-source commands. The current resolver retains them when passed the shared plan checklist; the discrepancy is missing plan additions at request construction, not a change in the project lint declaration. The human-readable test report does not repair that machine-readable omission. Carry the concrete commands through --plan-validation-command, including how the two native interpreter runs are invoked, and republish with their results and sources.

### Repository state around validation for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

The request-time and independently captured baseline index both equal `f50a3fb990fcc2a04286921e64e33360f46841e3`. The final assessed index is `88ccb77355714fbac3b1890ee631d2492d50727f`; its only attributable change is the Step 5 metadata patch.

Umbrella SHA-256 remained `7f8ef7c7adee0e68c16e5748ddf574b1831930a51b4767d3ef3fa7cb2e71508e`. Validation-state comparison reported acceptable=false solely because the tracked validation plan changed. Inspection confines that change to permitted Step 5 rows; it is not a validation-command side effect. There are no other tracked, untracked or ignored differences in the captured validation path set.

The evidence launcher returned attributable=true for the metadata patch. Only that returned patch was applied to the index; no unstaged tracked changes remain. The protocol-created untracked transcript was left to the exchange. No writer journal/handoff or umbrella was modified.

### Repair inventory for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

Repairs made:

- Polishing-only: `docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md` — Step 5 review metadata and private run-identifier removal only. No implementation or test repairs; the request contains no literal Human guidance repair authorization.

Paths staged:

- docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md

### Commit plan assessment for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

The reviewer independently ran commit-plan-check before assessment and again after staging the attributable metadata patch. Both runs exited 0 with state=valid, ready=true and no diagnostics.

One ordered group remains accurate:

1. `docs(sqlite-runtime-upgrade): record step 5 validation` — `docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md`.

The staged-path inventory contains only that file. Membership, order, scope and subject remain appropriate; a.commit was not edited. Mechanical readiness does not resolve F1/F2 or authorize a commit.

### Findings and boundaries for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

Unresolved findings:

- **F1 — P1: verify the selected source archive before extraction.** `src/install/env/sqlite/sqlite_install_functions.sh:44-53` hashes the hard-coded `sqlite-src-${version}.tar.gz`, and its first invocation is in configure at line 92. The shared installer chooses the newest matching archive at `src/install/env/install:110-121` and extracts it at lines 182-187 before configure. An invalid archive therefore reaches filesystem extraction before refusal. Moreover, a newer differently named matching archive can be selected while the valid canonical archive remains beside it: retaining the pinned sqlite3.c/header in the selected archive lets these checks pass while other build inputs, including configure/autosetup, differ. This defeats the confirmed pre-extraction source-identity requirement. Wire a verification hook to the exact selected archive before extraction; check the archive pins there and inspect pinned member identity before execution (stream members before filesystem extraction if retaining the literal four-value timing rule). Retain reused-tree checks. Add negative fixtures for a corrupt selected archive, an unknown version and two matching archives where the selected one is not the canonical file; assert refusal before extraction/configure. Correct Step 1's evidence claim after validating the fix.
- **F2 — P2: bind the plan checks into the mandatory request evidence.** `docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md:29-43` declares four shared plan commands, but this request's resolved_validation_set carries only the project lint floor. The current resolver includes those additions when supplied. Their reported successful runs in prose do not make the encoded mandatory set accurate. Publish the replacement request with concrete environment-resolved commands via --plan-validation-command, preserve the project floor, and attach the resulting command/source set and results.

Boundary-crossing work:

- F1 belongs to Step 1 and the shared extraction driver, outside the Step 5 metadata edit boundary. The request expressly includes that committed implementation in assessment scope; its repair and related tests/earlier validation updates belong to the writer. Do not downgrade the confirmed pre-extraction rule to match the current code.
- F2 belongs to request construction and the plan's shared validation declarations. The reviewer reports it without changing the request, plan or writer workflow.
- Item return must preserve the documented dependency on the preceding item's two how-to pages. No branch return, umbrella completion, consumer change, publication or adoption was performed by this review.

### Writer instructions for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

Resolve F1 in the earlier-step implementation with focused failure-path fixtures and update its inaccurate source-verification evidence. Preserve the established source pins and archive identity. Reassess which existing candidate evidence remains valid after the fix, and refresh affected qualification evidence without claiming that the prior candidate proves changed bytes.

Resolve F2 by passing the plan additions and concrete interpreter invocations to the request renderer. Run the applicable writer validation green after the implementation repair, record the results and environment, and publish a fresh request with an accurate index tree, bound scope and a.commit grouping. Keep private CI details in ignored evidence. Retain the Step 5 operational verdict and the evidence limitations unless new execution evidence warrants changing them.

No implementation repair was authorized to this reviewer. The changes-requested answer returns work to the requestor; it does not authorize a commit.

### Decision rationale for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

Changes requested. The six readiness results are:

1. Identity: PASS — exact code identity, plan, umbrella, step 5, round 1, occurrence 1 and request-time index agree.
2. Completeness: FAIL for the requested whole-item assessment — Step 5 operationally passes, but F1 leaves Step 1's confirmed source-verification contract incomplete.
3. Validation and coverage: FAIL — F2 omits required plan-source commands. Reported tests are green, the bound scope is valid and static review found no Step 5 unit-class or unreferenced-symbol gap; no coverage percentage is inferred.
4. Staged attribution: PASS — only the launcher's attributable Step 5 metadata patch was staged; umbrella and other tracked work are unchanged.
5. Unresolved findings: FAIL — F1 and F2 need writer action.
6. Commit plan: PASS — independent initial and final checks are valid/ready with one accurate group and no diagnostics.

No substantive repair was made. The metadata repair is polishing-only. The result is advisory and never authorizes a commit.

### Final reviewer decision for step 5 sqlite-runtime-upgrade (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-5-round-1 -->

## Round 2 by requestor - Step 5

- Recorded: 2026-10-27T18:26:20+01:00
- Exchange: code/code/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Implementation step: 5
- Outcome: request

### Review identity for step 5 sqlite-runtime-upgrade (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
Implementation step: 5
Review round: 2

### Code review evidence for step 5 sqlite-runtime-upgrade (round 2)

request_index_tree: e5dbdb4bb97701404e04a844c6bf012c37508e4e
resolved_validation_set:

- `bash src/utils/lint_shell.sh` (sources: project)
- `bash docs/v0.27.0/verify.python-sqlite.sh --step 4 --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe` (sources: plan)
- `bash docs/v0.27.0/verify.python-sqlite-build.sh --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe` (sources: plan)
- `bash docs/v0.27.0/verify.sqlite-source.sh` (sources: plan)
- `shellcheck -S style src/install/env/sqlite/sqlite_install_functions.sh` (sources: plan)
- `bash docs/v0.27.0/verify.python-sqlite-build.sh --python /usr/bin/python3` (sources: plan)
- `/usr/bin/python3 -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd` (sources: plan)
- `~/tools/python/bin/python -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd` (sources: plan)

test_scope:
{"fingerprint": "686958cdf490661b3207a810e06364a48e923f6bf1c8c33c9a555c7f23cc75b6", "group": null, "proof": "missing", "requirement": "docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md", "scope": "whole"}

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(sqlite): verify the selected archive first
group 1 path: src/install/env/install
group 1 path: src/install/env/sqlite/sqlite_install_functions.sh
group 1 path: docs/v0.27.0/verify.sqlite-source.sh
group 2: docs(wiki): document the pre-extraction SQLite check
group 2 path: wiki/reference/bundled-sqlite.md
group 2 path: wiki/how-to/build-and-verify-the-bundled-sqlite.md
group 2 path: wiki/reference/exit-codes.md
group 2 path: wiki/reference/tool-contract.md
group 3: docs(sqlite-runtime-upgrade): scope the source check
group 3 path: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
group 3 path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
group 4: docs(sqlite-runtime-upgrade): record step 5 validation
group 4 path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md
staged path: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
staged path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
staged path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md
staged path: docs/v0.27.0/verify.sqlite-source.sh
staged path: src/install/env/install
staged path: src/install/env/sqlite/sqlite_install_functions.sh
staged path: wiki/how-to/build-and-verify-the-bundled-sqlite.md
staged path: wiki/reference/bundled-sqlite.md
staged path: wiki/reference/exit-codes.md
staged path: wiki/reference/tool-contract.md
```

### Validation scope for step 5 sqlite-runtime-upgrade (round 2)

Validation scope: the whole suite.

### Requestor assessment for step 5 sqlite-runtime-upgrade (round 2)

**Is step 5 fully implemented?** Yes, unchanged from round 1: the candidate
passed every check on the Debian 12 agent and the consuming pipeline was
restored. Round 1's two findings concerned the wider item and are repaired.

**Scope: unchanged, the whole item.** Committed range `50eef52..df7bcb4` plus
the staged round 2 work. The staged work now holds the F1 implementation fix,
its wiki pages, the requirement and plan updates, and the step 5 record with
the step 1 evidence correction.

**F1, source check after extraction: fixed.**

- `src/install/env/install` calls an optional `verify_archive` hook with the
  exact archive it selected, before extracting anything, and stops with exit
  27 (unused before) when the hook refuses.
- The SQLite `verify_archive` checks the selected archive's SHA-256 and
  SHA3-256, then the `sqlite3.c` SHA3-256 and the `sqlite3.h` source id
  streamed from the archive (`tar -xzO`), each member required exactly once
  under the top directory. No file is written before the four checks pass.
- `sqlite_verify_sources`, kept for reused trees in `configure` and `build`,
  now checks the selected archive (`archive_file`), not a fixed name, and the
  extracted tree.
- `docs/v0.27.0/verify.sqlite-source.sh` drives the real installer and tool
  functions on synthetic archives with a fixture pin table. Refused with exit
  27, no extraction folder and no configure: a corrupt selected archive, an
  unknown version (real pin table), a newer non-canonical archive selected
  beside the valid canonical one, a wrong pinned amalgamation digest, a wrong
  pinned source id. The canonical archive is extracted and reaches configure;
  a tampered reused tree is refused before configure.
- The same runner against the previous installer and tool file fails: the
  corrupt archive is extracted (exit 43), and the non-canonical archive is
  extracted, passes every check and runs its own configure (exit 199).
- On the build host, the corrected hook passes on the real selected archive
  before extraction, and the extracted tree passes the tree checks. The tool's
  `sources/` holds exactly one file matching 3.54.1, the canonical archive, so
  the library already built and shipped came from it; no built byte changes.

**F2, plan validation commands: fixed.** The plan's checklist now gives
concrete invocations (the Windows step runner requires an absolute
interpreter, supplied through `%CD%` in the CMD session), and each command is
passed to the renderer as a plan addition. Results, 2026-10-27, all exit 0:

- Windows, CMD session after `senv.bat`: the step 4 runner (27 closure and 34
  acceptance fixture checks; symlink fixtures skipped), the build fixture
  launcher check, the 7 source fixtures, ShellCheck at style severity on the
  tool file (and on the installer and the new runner).
- Build host, copy of the tree: the 35 native installer fixtures with
  `/usr/bin/python3`, the 7 source fixtures, the 49 probe unit tests with
  `/usr/bin/python3` (Python 3.9.25) and with `~/tools/python/bin/python`
  (Python 3.13.15, SQLite 3.54.1).
- Project floor `bash src/utils/lint_shell.sh`: clean, 60 tracked scripts.

**Evidence still valid after the fix.** Steps 2 to 5 evidence concerns the
built library, the Python build, the archive and its qualification. The fix
changes the build guard, not any built byte, and the selected archive was the
canonical one; the step 1 record says so explicitly. The verification bundle
used on Debian carries the earlier tool file, but the Debian checks never run
the installer, only the probe and its expected-build file.

**Coverage, architecture, performance.** No Python coverage gate is declared.
The installer change is one guarded call; only SQLite defines the hook. The
hook hashes the 3.3 MB archive and streams two members once per install. The
new runner stays below the 550-line safe band (169 lines).

### Implementation report for step 5 sqlite-runtime-upgrade (round 2)

Round 2 changes, on top of the committed range reported in round 1:

- `src/install/env/install`: after the archive selection, `if declare -F
  verify_archive` then `verify_archive "${archive_file}"`, refused with
  `fatal ... 27` and the message "failed its verification: nothing
  extracted". It runs before the extraction folder test, so a reused folder
  also gets the archive check.
- `src/install/env/sqlite/sqlite_install_functions.sh`:
  - `sqlite_member_sha3` hashes one member through `tar -xzO` under
    `pipefail`;
  - `sqlite_archive_member` resolves `<top>/sqlite3.c` and `<top>/sqlite3.h`,
    refusing a missing or repeated member;
  - `verify_archive` runs the four checks in order, archive digests first, so
    an archive whose digests differ is never listed or streamed;
  - `sqlite_verify_sources` reads `archive_file` and refuses when it is unset
    or missing;
  - the header comment counts four pinned values and names
    `sqlite_expected.txt`.
- `docs/v0.27.0/verify.sqlite-source.sh` (new, 169 lines): seven cases, each
  asserting the exit status, the recorded events (`gcc`, `configure`), the
  refusal text and, for refusals, the absence of the extraction folder.
- Wiki: the bundled SQLite reference (check order, a hook row in the checks
  table), the how-to (four values, an exit 27 refusal row), the exit codes
  (27) and the tool contract (the optional `verify_archive` hook and its
  reuse limit).
- Feature-request AC1 names the selected archive and the reused-tree check.
  The plan's step 1 lists the hook, the fixture runner and an addendum on the
  round 1 finding; its checklist gives concrete commands.
- Validation plan: the step 5 record with the reviewer's round 1 limits, and
  step 1's evidence corrected with the round 2 correction runs.

Writer notes: `.reviews/a.sqlite-runtime-upgrade.step5.journal.md` and
`.reviews/a.sqlite-runtime-upgrade.step5.handoff.md`.

### Change summary for step 5 sqlite-runtime-upgrade (round 2)

Staged paths:

- `src/install/env/install`
- `src/install/env/sqlite/sqlite_install_functions.sh`
- `docs/v0.27.0/verify.sqlite-source.sh` (new)
- `wiki/reference/bundled-sqlite.md`
- `wiki/how-to/build-and-verify-the-bundled-sqlite.md`
- `wiki/reference/exit-codes.md`
- `wiki/reference/tool-contract.md`
- `docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md`
- `docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md`
- `docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md`

Root `a.commit` groups, readiness check valid:

1. `fix(sqlite): verify the selected archive first`: the installer, the tool
   file and the new runner.
2. `docs(wiki): document the pre-extraction SQLite check`: the four wiki pages.
3. `docs(sqlite-runtime-upgrade): scope the source check`: the requirement
   and the plan.
4. `docs(sqlite-runtime-upgrade): record step 5 validation`: the validation
   plan.

Committed and still in scope: `50eef52..df7bcb4`, unchanged since round 1.

### Writer response for step 5 sqlite-runtime-upgrade (round 2)

Writer response:

- **F1, accepted.** The pre-extraction rule is kept, not relaxed: the check now
  runs on the exact selected archive before anything is extracted, all four
  values included, through a generic installer hook. The negative fixtures the
  answer asked for are in `verify.sqlite-source.sh`, with two more (wrong
  pinned member digest, wrong pinned source id) and a reused-tree case; the
  step 1 evidence claim is corrected. Existing candidate evidence is kept with
  the reason it still holds: no built byte changes and the build used the
  canonical archive, shown by the single matching file in `sources/` and the
  hook passing on it.
- **F2, accepted.** Every plan command is now concrete and passed through
  `--plan-validation-command`, the two native unit-test interpreters
  included, next to the unchanged project floor; results are in the
  assessment.
- **Reviewer polishing of the step 5 record, accepted** as staged, including
  the removal of the run identifiers.
- No disagreement.

### Reviewer focus for step 5 sqlite-runtime-upgrade (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-5-round-2 -->

## Round 2 by reviewer - Step 5

- Recorded: 2026-10-27T18:33:44+01:00
- Exchange: code/code/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Implementation step: 5
- Outcome: answer

### Assessed index identity for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

Baseline index tree: e5dbdb4bb97701404e04a844c6bf012c37508e4e

Assessed index tree: a05084a24e39599f5bb0f21230db8468d6544aab

### Implementation check for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

Result:

Yes. Step 5 has been fully implemented.

The Debian qualification and consuming-pipeline restoration retain the round-1 assessment: local bundle, candidate-pin, original/reworded-tree and restored-tree comparisons were independently checked then; successful CI execution and remote push remain writer-reported evidence. Round 2 leaves the bundle's probe and expected-build file unchanged.

The authorized whole-item scope remains committed range 50eef52..df7bcb4 plus this round's staged work. F1 is closed: the dispatcher verifies its exact selected archive before creating the extraction folder, SQLite checks both archive digests before streaming the two pinned members, and configure/build retain extracted-tree checks. F2 is closed: the current resolver reproduces every declared command and source. New finding F3 concerns the added fixture, not the historical operational result.

No architecture or performance defect was found: the hook is optional and only SQLite defines it; hashing and archive passes are linear in archive size. The new helpers are referenced by the hook and its fixture path. Step 5 introduces no unit-tested class; no Python coverage percentage gate exists and no percentage is claimed. Static fixture review found F3, so whole-item validation readiness is not complete.

Validation plan effects:

Updated only the Step 5 assessment and feature-integrity paragraphs in docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md. The exact Yes sentence remains. The paragraphs now close F1/F2, retain the execution-evidence limits and identify the outstanding fixture correction. These are polishing-only review metadata; earlier-step rows, the document-level completion line and umbrella remain untouched.

### Pre-repair mandatory checks and coverage for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

Writer evidence reports exit 0 for the Windows cumulative step-4 runner, build launcher fixture, seven source cases and style ShellCheck; native evidence reports 35 installer fixtures, seven source cases and 49 probe tests with each of the host and rebuilt interpreters. The project lint floor reports 60 scripts clean. These are reported results, not reviewer reruns.

The reviewer executed the current resolver, independent commit-plan checker and evidence launchers, and inspected the staged source, tests, docs and named handoff. Neither optional ghog command was needed to establish the static fixture defect. No mandatory writer command, ghog day/full or coverage measurement was run. F3 is a static finding with an explicit same-second condition, not a claimed observed failed run.

The returned whole-suite scope file exists with fingerprint 686958cdf490661b3207a810e06364a48e923f6bf1c8c33c9a555c7f23cc75b6; its capture does not itself prove a test pass.

### Resolved validation set and sources for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.python-sqlite.sh --step 4 --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe` (source: plan).
- `bash docs/v0.27.0/verify.python-sqlite-build.sh --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe` (source: plan).
- `bash docs/v0.27.0/verify.sqlite-source.sh` (source: plan).
- `shellcheck -S style src/install/env/sqlite/sqlite_install_functions.sh` (source: plan).
- `bash docs/v0.27.0/verify.python-sqlite-build.sh --python /usr/bin/python3` (source: plan).
- `/usr/bin/python3 -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd` (source: plan).
- `~/tools/python/bin/python -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd` (source: plan).

### Resolver drift and direction for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

None. Independently resolved the current .review-validation project floor and the plan's shared checklist. All eight unique commands, their order and their project/plan sources equal the request payload. The Windows commands explicitly use CMD after senv.bat; native commands name the host and rebuilt interpreters. F2 is closed.

### Repository state around validation for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

The request-time and captured baseline index agree at e5dbdb4bb97701404e04a844c6bf012c37508e4e. The assessed index is a05084a24e39599f5bb0f21230db8468d6544aab. Its only reviewer delta is the attributable Step 5 metadata patch.

The ordered validation set contains all ten received staged paths. Comparison reports acceptable=false for the validation document and index only; inspection proves the differences are the permitted metadata patch and its staging. All other captured files are unchanged. Umbrella digest remains 7f8ef7c7adee0e68c16e5748ddf574b1831930a51b4767d3ef3fa7cb2e71508e. No implementation, test, umbrella or writer-note mutation was made.

### Repair inventory for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

Repairs made:

- Polishing-only: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md; Step 5 review-state paragraphs only. The evidence launcher proved attribution, and only its returned patch was staged. No literal Human guidance repair authorization is present.

Paths staged:

- docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md (received staged path, unchanged by reviewer)
- docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md (received staged path, unchanged by reviewer)
- docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md (received staged path plus the reviewer metadata patch)
- docs/v0.27.0/verify.sqlite-source.sh (received staged path, unchanged by reviewer)
- src/install/env/install (received staged path, unchanged by reviewer)
- src/install/env/sqlite/sqlite_install_functions.sh (received staged path, unchanged by reviewer)
- wiki/how-to/build-and-verify-the-bundled-sqlite.md (received staged path, unchanged by reviewer)
- wiki/reference/bundled-sqlite.md (received staged path, unchanged by reviewer)
- wiki/reference/exit-codes.md (received staged path, unchanged by reviewer)
- wiki/reference/tool-contract.md (received staged path, unchanged by reviewer)

### Commit plan assessment for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

Independent initial and final commit-plan-check runs both exited 0: state=valid, ready=true, diagnostics=[]. All ten staged paths belong exactly once to these ordered groups:

1. fix(sqlite): verify the selected archive first; installer, SQLite functions and source fixture.
2. docs(wiki): document the pre-extraction SQLite check; four wiki pages.
3. docs(sqlite-runtime-upgrade): scope the source check; requirement and plan.
4. docs(sqlite-runtime-upgrade): record step 5 validation; validation plan.

Membership, ordering, scopes and subjects remain accurate. a.commit was not edited. This mechanical pass does not resolve F3 or authorize a commit.

### Findings and boundaries for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

Unresolved findings:

- F3 (P2): Make the non-canonical archive fixture deterministically different. In docs/v0.27.0/verify.sqlite-source.sh:138-142, make_archive is called with the same amalgamation and source id as the canonical call at line 30, and its configure body is also identical. With GNU tar's normal whole-second member timestamps, creating both archives in the same second can produce identical bytes. Touching the outer canonical .tar.gz to 2001 only controls selection; it does not change archive contents. The correct verifier then accepts the selected file and reaches configure (exit 199), while this mandatory test expects exit 27. Thus the new regression check depends on execution timing. Give the selected archive explicitly different configure/autosetup bytes while preserving the pinned sqlite3.c and sqlite3.h, and assert its archive digest differs before invoking the installer. Keep newest-file selection and the no-extraction/no-configure assertions. Do not fix this with a sleep.

Boundary-crossing work:

- F3 is in the Step 1 source fixture within the explicitly requested whole-item review scope. Its repair remains writer-owned; it is outside the reviewer’s Step 5 metadata boundary. No implementation or test repair was attempted.

### Writer instructions for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

1. Repair F3 by constructing a selected archive with deterministically different configure bytes, unchanged pinned amalgamation/header values, and an explicit digest-inequality precondition.
2. Validate the case with member timestamps normalized to the same value, so timestamp differences cannot supply its only distinction; retain the canonical success case and the refusal-before-extraction assertions. Record native and Windows results as applicable and rerun the required writer validation after the change.
3. Preserve the closed F1/F2 fixes and the existing operational evidence limits. Refresh a.commit only as needed for the final staged scope and publish the next request with its exact index and complete resolved command set.

### Decision rationale for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

changes-requested. Readiness floor: exact identity passes; Step 5 completeness passes; whole-item validation is blocked by F3; staged attribution passes; unresolved-findings clearance fails for F3; a.commit accuracy passes. The reviewer made only polishing metadata changes. F1/F2 are closed, and one new test defect remains. This is advisory and grants no commit authority.

### Final reviewer decision for step 5 sqlite-runtime-upgrade (exchange 1) (round 2)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-5-round-2 -->

## Round 3 by requestor - Step 5

- Recorded: 2026-10-27T18:47:39+01:00
- Exchange: code/code/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Implementation step: 5
- Outcome: request

### Review identity for step 5 sqlite-runtime-upgrade (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
Implementation step: 5
Review round: 3

### Code review evidence for step 5 sqlite-runtime-upgrade (round 3)

request_index_tree: 31257eea66a77da4272e7f7b370e6fa5e2d1f887
resolved_validation_set:

- `bash src/utils/lint_shell.sh` (sources: project)
- `bash docs/v0.27.0/verify.python-sqlite.sh --step 4 --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe` (sources: plan)
- `bash docs/v0.27.0/verify.python-sqlite-build.sh --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe` (sources: plan)
- `bash docs/v0.27.0/verify.sqlite-source.sh` (sources: plan)
- `shellcheck -S style src/install/env/sqlite/sqlite_install_functions.sh` (sources: plan)
- `bash docs/v0.27.0/verify.python-sqlite-build.sh --python /usr/bin/python3` (sources: plan)
- `/usr/bin/python3 -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd` (sources: plan)
- `~/tools/python/bin/python -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd` (sources: plan)

test_scope:
{"fingerprint": "686958cdf490661b3207a810e06364a48e923f6bf1c8c33c9a555c7f23cc75b6", "group": null, "proof": "missing", "requirement": "docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md", "scope": "whole"}

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(sqlite): verify the selected archive first
group 1 path: src/install/env/install
group 1 path: src/install/env/sqlite/sqlite_install_functions.sh
group 1 path: docs/v0.27.0/verify.sqlite-source.sh
group 2: docs(wiki): document the pre-extraction SQLite check
group 2 path: wiki/reference/bundled-sqlite.md
group 2 path: wiki/how-to/build-and-verify-the-bundled-sqlite.md
group 2 path: wiki/reference/exit-codes.md
group 2 path: wiki/reference/tool-contract.md
group 3: docs(sqlite-runtime-upgrade): scope the source check
group 3 path: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
group 3 path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
group 4: docs(sqlite-runtime-upgrade): record step 5 validation
group 4 path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md
staged path: docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md
staged path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
staged path: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md
staged path: docs/v0.27.0/verify.sqlite-source.sh
staged path: src/install/env/install
staged path: src/install/env/sqlite/sqlite_install_functions.sh
staged path: wiki/how-to/build-and-verify-the-bundled-sqlite.md
staged path: wiki/reference/bundled-sqlite.md
staged path: wiki/reference/exit-codes.md
staged path: wiki/reference/tool-contract.md
```

### Validation scope for step 5 sqlite-runtime-upgrade (round 3)

Validation scope: the whole suite.

### Requestor assessment for step 5 sqlite-runtime-upgrade (round 3)

**Is step 5 fully implemented?** Yes, unchanged: the operational step and its
evidence limits stand as the reviewer recorded them.

**Scope: unchanged, the whole item.** Committed range `50eef52..df7bcb4` plus
the staged work of round 2, with the F3 repair added to the fixture runner and
the validation plan.

**F3, timing-dependent non-canonical fixture: fixed.**

- Every fixture archive is now built deterministically: `tar --sort=name
  --mtime=@0 --owner=0 --group=0 --numeric-owner`, fixed member modes, piped
  through `gzip -n`. A self-check at the top rebuilds the canonical inputs and
  requires byte equality, so timestamps can no longer distinguish two
  archives, as the answer asked.
- The selected non-canonical archive keeps the pinned `sqlite3.c` and
  `sqlite3.h` and differs in its build files (an extra line in `configure`).
  Before the installer runs, the case asserts that its SHA-256 differs from
  the canonical archive's and that both pinned members are byte-identical to
  the canonical ones. Newest-file selection, the exit 27, the no-extraction
  and the no-configure assertions are unchanged. No sleep is involved.
- Against the previous installer and tool file, the corrected case still
  fails as it should: the selected archive is extracted, passes every check
  and runs its own configure (exit 199).

**Validation rerun after the change, 2026-10-27, all exit 0:**

- Windows, CMD session after `senv.bat`: project floor (60 tracked scripts
  clean), the step 4 runner, the build fixture launcher check, the 7 source
  fixtures (GNU tar 1.35), ShellCheck at style severity on the tool file, the
  installer and the runner.
- Build host, copy of the tree: the 7 source fixtures (GNU tar 1.34, gzip
  1.12), the 35 native installer fixtures with `/usr/bin/python3`, the 49 probe
  unit tests with `/usr/bin/python3` and with `~/tools/python/bin/python`.

**F1 and F2** stay closed; no source file outside the fixture runner changed
in this round.

### Implementation report for step 5 sqlite-runtime-upgrade (round 3)

Round 3 change: `docs/v0.27.0/verify.sqlite-source.sh` builds every fixture
archive deterministically and checks it (byte-equal rebuild), and its
non-canonical case uses an archive with the pinned members and different build
files, asserted before the installer runs. The validation plan records it.
Nothing else changed since round 2, whose changes stay as follows.

Round 2 changes, on top of the committed range reported in round 1:

- `src/install/env/install`: after the archive selection, `if declare -F
  verify_archive` then `verify_archive "${archive_file}"`, refused with
  `fatal ... 27` and the message "failed its verification: nothing
  extracted". It runs before the extraction folder test, so a reused folder
  also gets the archive check.
- `src/install/env/sqlite/sqlite_install_functions.sh`:
  - `sqlite_member_sha3` hashes one member through `tar -xzO` under
    `pipefail`;
  - `sqlite_archive_member` resolves `<top>/sqlite3.c` and `<top>/sqlite3.h`,
    refusing a missing or repeated member;
  - `verify_archive` runs the four checks in order, archive digests first, so
    an archive whose digests differ is never listed or streamed;
  - `sqlite_verify_sources` reads `archive_file` and refuses when it is unset
    or missing;
  - the header comment counts four pinned values and names
    `sqlite_expected.txt`.
- `docs/v0.27.0/verify.sqlite-source.sh` (new, 186 lines): seven cases, each
  asserting the exit status, the recorded events (`gcc`, `configure`), the
  refusal text and, for refusals, the absence of the extraction folder.
- Wiki: the bundled SQLite reference (check order, a hook row in the checks
  table), the how-to (four values, an exit 27 refusal row), the exit codes
  (27) and the tool contract (the optional `verify_archive` hook and its
  reuse limit).
- Feature-request AC1 names the selected archive and the reused-tree check.
  The plan's step 1 lists the hook, the fixture runner and an addendum on the
  round 1 finding; its checklist gives concrete commands.
- Validation plan: the step 5 record with the reviewer's round 1 limits, and
  step 1's evidence corrected with the round 2 correction runs.

Writer notes: `.reviews/a.sqlite-runtime-upgrade.step5.journal.md` and
`.reviews/a.sqlite-runtime-upgrade.step5.handoff.md`.

### Change summary for step 5 sqlite-runtime-upgrade (round 3)

Staged paths:

- `src/install/env/install`
- `src/install/env/sqlite/sqlite_install_functions.sh`
- `docs/v0.27.0/verify.sqlite-source.sh` (new)
- `wiki/reference/bundled-sqlite.md`
- `wiki/how-to/build-and-verify-the-bundled-sqlite.md`
- `wiki/reference/exit-codes.md`
- `wiki/reference/tool-contract.md`
- `docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md`
- `docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md`
- `docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md`

Root `a.commit` groups, readiness check valid:

1. `fix(sqlite): verify the selected archive first`: the installer, the tool
   file and the new runner.
2. `docs(wiki): document the pre-extraction SQLite check`: the four wiki pages.
3. `docs(sqlite-runtime-upgrade): scope the source check`: the requirement
   and the plan.
4. `docs(sqlite-runtime-upgrade): record step 5 validation`: the validation
   plan.

Committed and still in scope: `50eef52..df7bcb4`, unchanged since round 1.

### Writer response for step 5 sqlite-runtime-upgrade (round 3)

Writer response:

- **F3, accepted.** The selected archive now differs from the canonical one by
  content (its build files) while keeping the pinned members, with a digest
  inequality and member equality precondition before the installer runs. All
  fixture archives are timestamp-normalized, with a byte-equality self-check,
  so the case cannot pass or fail on timing. No sleep was used.
- **Reviewer step 5 paragraphs of round 2, accepted.** Their sentences that
  named the fixture correction as outstanding now say it was made and
  validated before this round; nothing else in them changed.
- F1 and F2 remain closed. No disagreement.

### Reviewer focus for step 5 sqlite-runtime-upgrade (round 3)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-5-round-3 -->

## Round 3 by reviewer - Step 5

- Recorded: 2026-10-27T18:53:24+01:00
- Exchange: code/code/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Implementation step: 5
- Outcome: answer

### Assessed index identity for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

Baseline index tree: 31257eea66a77da4272e7f7b370e6fa5e2d1f887

Assessed index tree: 6c7fa3a62e5b33057ba7c34949289b6ebcfffe6b

### Implementation check for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

Result:

Yes. Step 5 has been fully implemented.

The Debian qualification and consuming-pipeline restoration retain the earlier assessment: local bundle, candidate-pin, original/reworded-tree and restored-tree comparisons were independently checked in round 1. Successful CI execution and remote push remain writer-reported evidence; the reviewer did not independently retrieve the successful raw CI log.

The authorized whole-item scope remains committed range 50eef52..df7bcb4 plus staged work. F1 remains closed: the installer verifies its exact selected archive before extraction, and SQLite checks both archive digests and pinned source members before configure/build. F2 remains closed: the independent resolver matches all eight declared commands and sources.

Round 3 closes F3. Archive construction normalizes member order, timestamps, ownership and file modes, and uses gzip -n. Rebuilding identical canonical inputs is checked for byte identity. The selected noncanonical archive has a distinct configure comment, retains identical pinned sqlite3.c/header members, and is checked for digest inequality and member equality before installer invocation. The fixture still verifies newest-file selection and refusal before extraction or configure. No new defect was found in the complete fixture or round delta.

The optional installer hook remains confined to SQLite, with linear archive checks and no new architecture or performance concern. Step 5 introduces no unit-tested class; the static coverage assessment finds no outstanding gap. No Python coverage percentage gate exists, and no percentage is claimed.

Validation plan effects:

Updated only the Step 5 summary in docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md to record the independent round-3 fixture assessment and closure of all three findings. The exact Yes sentence and operational evidence limits remain. This is polishing-only metadata; earlier-step rows, document-level status and the umbrella were not changed.

### Pre-repair mandatory checks and coverage for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

Post-fix writer evidence reports Windows lint clean for 60 scripts and successful Windows cumulative step-4, build-launcher, seven source-fixture and style ShellCheck runs. Native evidence reports seven source fixtures, 35 installer fixtures and 49 probe tests with each of the host and rebuilt interpreters. The corrected negative fixture reportedly still exposes the old installer behavior with exit 199. These are writer-reported execution results, not reviewer reruns.

The reviewer independently inspected the fixture and delta, ran the current validation resolver, initial and final commit-plan checks, and the evidence boundary launchers. Neither optional ghog command was needed. No mandatory writer validation, ghog day/full or coverage measurement was rerun.

The whole-suite scope fingerprint remains 686958cdf490661b3207a810e06364a48e923f6bf1c8c33c9a555c7f23cc75b6. Its capture alone is not evidence of a test pass.

### Resolved validation set and sources for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.python-sqlite.sh --step 4 --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe` (source: plan).
- `bash docs/v0.27.0/verify.python-sqlite-build.sh --python %CD%/../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe` (source: plan).
- `bash docs/v0.27.0/verify.sqlite-source.sh` (source: plan).
- `shellcheck -S style src/install/env/sqlite/sqlite_install_functions.sh` (source: plan).
- `bash docs/v0.27.0/verify.python-sqlite-build.sh --python /usr/bin/python3` (source: plan).
- `/usr/bin/python3 -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd` (source: plan).
- `~/tools/python/bin/python -m unittest tests.unit.sqlite_probe.test_sqlite_probe.test_sqlite_probe_tdd` (source: plan).

### Resolver drift and direction for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

None. Independent resolution of the current .review-validation project floor and plan checklist matches all eight unique request commands, their order and project/plan sources. The Windows commands explicitly use CMD after environment setup; native commands identify the host and rebuilt interpreters. F2 remains closed.

### Repository state around validation for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

The request and baseline index agree at 31257eea66a77da4272e7f7b370e6fa5e2d1f887. The assessed index is 6c7fa3a62e5b33057ba7c34949289b6ebcfffe6b. The only reviewer change is the attributable Step 5 metadata patch.

The ordered validation snapshots cover all ten staged paths. Comparison returns acceptable=false solely for the validation document and index; those differences are the intentional metadata edit and staging. All other captured files are unchanged, no untracked paths appeared in the comparison, and git diff --exit-code confirms no unstaged tracked changes.

The umbrella digest remains 7f8ef7c7adee0e68c16e5748ddf574b1831930a51b4767d3ef3fa7cb2e71508e. No implementation, test, umbrella or writer-note change was made by the reviewer.

### Repair inventory for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

Repairs made:

- Polishing-only: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md; the Step 5 review-summary paragraph. The evidence launcher proved attribution and only its exact returned patch was staged. No substantive repair was made; no literal Human guidance repair authorization was present.

Paths staged:

- docs/v0.27.0/feature-request.v0.27.0.sqlite-runtime-upgrade.md (received staged path, unchanged by reviewer)
- docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md (received staged path, unchanged by reviewer)
- docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.validation.md (received staged path plus the reviewer metadata patch)
- docs/v0.27.0/verify.sqlite-source.sh (received staged path, unchanged by reviewer)
- src/install/env/install (received staged path, unchanged by reviewer)
- src/install/env/sqlite/sqlite_install_functions.sh (received staged path, unchanged by reviewer)
- wiki/how-to/build-and-verify-the-bundled-sqlite.md (received staged path, unchanged by reviewer)
- wiki/reference/bundled-sqlite.md (received staged path, unchanged by reviewer)
- wiki/reference/exit-codes.md (received staged path, unchanged by reviewer)
- wiki/reference/tool-contract.md (received staged path, unchanged by reviewer)

### Commit plan assessment for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

Independent initial and final commit-plan-check runs exited 0 with state=valid, ready=true and no diagnostics. All ten staged paths occur exactly once in these ordered groups:

1. fix(sqlite): verify the selected archive first; installer, SQLite functions and source fixture.
2. docs(wiki): document the pre-extraction SQLite check; four wiki pages.
3. docs(sqlite-runtime-upgrade): scope the source check; requirement and plan.
4. docs(sqlite-runtime-upgrade): record step 5 validation; validation plan.

Membership, ordering, scopes and subjects remain accurate. a.commit was not edited. This check contributes only the commit-plan readiness result and does not authorize a commit.

### Findings and boundaries for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

No further corrective work is requested. Preserve the assessed staged scope and the stated operational evidence limits. The requestor should present the human convergence choice and continue only under the owning workflow's authorization.

### Decision rationale for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

commit-ready. All six readiness-floor results pass: exact identity; complete Step 5 implementation; validation and static coverage assessment; attributable staged scope; no unresolved current or carried findings; accurate a.commit grouping. Writer-reported execution evidence remains distinguished from independent reviewer checks. This round made only a polishing metadata edit and no substantive repair. The recommendation is advisory and grants no commit authority.

### Final reviewer decision for step 5 sqlite-runtime-upgrade (exchange 1) (round 3)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-5-round-3 -->

## Round 3 by human - Step 5 - human-confirmation

- Recorded: 2026-10-27T18:56:14+01:00
- Exchange: code/code/v0.27.0/sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.sqlite-runtime-upgrade.md
- Requestor LLM nature: claude
- Reviewer LLM nature: codex
- Implementation step: 5
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-3 -->
