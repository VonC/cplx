# Specification review transcript for v0.27.0

- Exchange: specification/plan/v0.27.0/architecture-minor-fallback
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-14T15:43:15+02:00
- Exchange: specification/plan/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for plan architecture-minor-fallback (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
Review round: 1

### Requestor assessment for plan architecture-minor-fallback (round 1)

The plain implementation plan is ready for independent review. Requirement round 3 and design round 2 are human-consolidated; their policies must not be reopened.

Six questions cover implementation file allocation, literal progress serialization, reset option spelling, Bash/CMD fixture organization, timing of Windows checks and the controlled RHEL acceptance workspace. All propose A. Review whether implementation gaps require another question or a substantive correction, and whether each option and proposed answer is sufficient.

The four steps are aligned with the initial validation skeleton. Direct inspection confirmed the 569-line main script, 100-line CMD launcher, current check.bat and Bash-only mandatory lint floor. There is no Python test project or GROUNDHOG.md; the plan explicitly adapts the generic Python/ghog day template to a cumulative Bash gate. Tests and host acceptance have not run. The plan includes physical-line baselines, current-shell context propagation, first-definition mirror handling, failure injection, actual CMD execution, Windows held-destination replacement, and pre-removal/final-tree RHEL setup.

Pay particular attention to whether the ready commands and fixture seams are executable without real setup side effects, whether new source files are linted before tracking, and whether all AC1-AC12 cases have an executable owner. Real RHEL acceptance must not be inferred from a skipped list or an exact local mirror override. A pre-existing package-list/mirror defect that prevents full synchronization is a Step 4 blocker, not permission to claim acceptance or change settled selection behavior.

The user authorized sensitive-term replacement, including the private application's short name. Use generic private application terminology in findings and versioned prose. RHEL packages/deploys tools and application; Jenkins Debian consumes prebuilt tools, checks out application source and runs tests, and packages/publishes application only. No GCC compilation, tools build or tools publication on Debian is in scope.

### Change summary for plan architecture-minor-fallback (round 1)

Initial four-step implementation plan and matching empty validation skeleton were written after design consolidation commit 642ef28. The plan carries the approved design into three Bash helpers, isolated fixture suites, explicit reset arguments, atomic index/progress work and controlled RHEL acceptance. Six proposed implementation answers were placed with oqm. No implementation change was made while writing these documents.

### Writer response for plan architecture-minor-fallback (round 1)

Writer response:

This is the first plan review round. There is no prior plan feedback or disagreement. Earlier requirement and design approvals remain settled. Please assess implementation feasibility and coverage rather than proposing different selection, index or resume policies.

### Reviewer focus for plan architecture-minor-fallback (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `C:/Users/vonc/git/cplx/.reviews/a.review-active.specification.plan.v0.27.0.architecture-minor-fallback.md`
- `C:/Users/vonc/git/cplx/.reviews/a.review-requested.plan.v0.27.0.architecture-minor-fallback.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-14T15:49:41+02:00
- Exchange: specification/plan/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan architecture-minor-fallback round 1

#### Overall reading of the plan for plan architecture-minor-fallback (round 1)

The plan carries the consolidated requirement and design into four ordered
steps without reopening any policy. Its facts check out:

- the physical-line inventory matches the files: `setup_packages.sh` 569,
  `setup.bat` 100, `pkgs/.gitignore` 2, the template 26, `lint_shell.sh` 43,
  `check.bat` 26, `.review-validation` 21, `.gitignore` 33;
- the gate description matches `check.bat`, `.review-validation` and
  `lint_shell.sh`, including the `docs/` exclusion that makes explicit linting
  of the new harnesses a plan obligation;
- the interfaces (four-line record, reset arguments, failure numbers,
  current-shell context) are concrete enough to implement.

AC1 to AC12 each have an executable owner:

- AC3, AC4 and AC11 in the Step 1 matrix;
- AC6, AC9 and AC10 in the Step 2 cross product;
- AC12 in Step 3;
- AC1, AC2, AC5, AC7 and AC8 in the Step 4 entry-point fixture, the host runs
  and the documentation.

The four-step order, and the rule that Windows checks belong to their owning
step, are right.

Three things block implementation as written. I checked two of them by
execution.

#### Findings against the repository for plan architecture-minor-fallback (round 1)

##### P1: the ready command reproduces the documented senv trap for plan architecture-minor-fallback (round 1)

The plan's command is
`cmd /d /v:on /c 'call senv.bat && "!GH!\bin\bash.exe" docs/... --step N'`. It
does not clear `NO_MORE_SENV_cplx`, and `senv.bat:19` returns immediately when
that guard is inherited. I ran the same form with the guard set and
`src/utils/lint_shell.sh` as the payload. It stopped with `lint_shell:
shellcheck not on PATH; run senv.bat first` and exit 2: the runner's mandatory
first stage would fail, or appear unavailable, depending on the caller's
environment. The guard-clearing form,
`cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat && !GH!\bin\bash.exe src/utils/lint_shell.sh"`,
under the same conditions answered `lint_shell: 54 tracked scripts` and
`lint_shell: clean` with exit 0. It also removes the inner double quotes that
the project's command rules forbid.

The accompanying sentence is inaccurate too. `senv.bat` does not establish
`GH`: it requires it (`senv.bat:52-53`, fatal 16 when undefined) and prepends
`%GH%\bin` to the path. `GH` is a prerequisite of the user environment, which
is also why `check.bat` can call `%GH%\bin\bash.exe` explicitly.

##### P2: the fixture root seam is undefined, and the obvious approach writes into the real tree for plan architecture-minor-fallback (round 1)

`setup_packages.sh:4` computes `SETUP_PKGS_DIR` unconditionally from
`readlink -f "${BASH_SOURCE[0]}"`. Everything the script touches hangs off it:

- `pkgs/`, the index, the `last` marker and the RPM cache;
- `setup.properties`, through `properties_file`;
- `steps.md`, through `steps_file` set in `main`;
- `pkgs.log`, which `main` deletes;
- `temp.pkgs.txt`, which the install functions write.

Sourcing the production script from the repository to unit-test its functions
therefore points every write at the real `src/setups`. Because of `readlink -f`,
a fixture tree built from symlinks resolves back to the real tree as well. In
addition, `fatal` in `src/echos/echos:37` calls `exit`, so a case that reaches a
fatal path in the harness's own shell ends the whole runner.

The plan says "use an isolated fixture tree" and "sourcing makes no network
calls or persistent writes", but it never says how the scripts find the fixture
root. The requestor asked precisely whether the fixture seams are executable
without real setup side effects. As written, that depends on an unstated
choice, and the natural one is unsafe. The plan must name the seam, the
per-case process boundary, and a check that proves the real tree was untouched.

##### P3: the host acceptance target on the RHEL side is not decided (missing question Q07) for plan architecture-minor-fallback (round 1)

Q06 isolates the local checkout and configuration, but the controlled run uses
the same remote account. The remote `.env` sets `HOME` to the cplx directory
(`src/setups/env/.env:21-22`), and `packages_management.sh` installs into
`${HOME}/tools/<tool>` and stages into `${HOME}/tools/pkgs`. The installed flag
is keyed by the versioned package base name (`base_package_name`, lines
294-308), so a package version not seen before is extracted into the live tool
sandbox.

A host run that regenerates the index (the AC1 "no index for either minor"
shape, or a reload flag) can therefore change the build account's python and
git sandboxes before items 6 and 7 plan their refresh. A run that holds the
committed, generated `packages_rhel_9.8_x86_64.txt` does not; it still
satisfies AC7's "generated 9.8 index", while index generation stays owned by
fixtures. The plan must decide which, because it determines what Step 4 is
allowed to change on the host.

##### P4: precision points for plan architecture-minor-fallback (round 1)

- **Held-open destination on Windows.** Whether a replace-rename fails depends
  on the holder's share mode. A holder that grants delete sharing lets the
  rename succeed, and the case passes without testing anything. Name the holder,
  for example a PowerShell `[IO.File]::Open(path, 'Open', 'Read', 'Read')` kept
  open for the duration, and assert that the failure actually occurred.
- **Failure numbers.** 114 and 115 are already used by the remote
  `packages_management.sh` (lines 339, 932, 940). Local and remote codes are
  different processes, but `wiki/reference/exit-codes.md` must attribute the new
  numbers to `setup_packages.sh` so the two sets cannot be read as one.
- **Ignored local state in the controlled checkout.** A fresh checkout carries
  none of the ignored inputs Step 4 relies on: the legacy `pkgs/<tool>/last`,
  the active `setup.properties` and the local RPM cache under
  `pkgs/rhel_9.8_x86_64/`. State that they are seeded (copied, not linked),
  recorded, and that "observe local reuse" refers to the seeded cache.

#### Disposition reasoning for the plan round for plan architecture-minor-fallback (round 1)

The disposition is `changes-requested`. P1 and P2 make the plan's own gate
either fail or write outside its fixtures, and P3 is a missing decision about
host side effects. None of them is wording polish.

### Question verdicts for plan architecture-minor-fallback round 1

#### Plan verdict table for plan architecture-minor-fallback (round 1)

| Question | Verdict | Answer I would choose |
| --- | --- | --- |
| Q01 helper allocation | Agree | A |
| Q02 progress record syntax | Agree | A |
| Q03 reset argument spelling | Agree | A |
| Q04 verification organization | Agree, add the fixture root seam | A |
| Q05 Windows validation timing | Agree, name the held-open share mode | A |
| Q06 controlled local workspace | Agree, add seeding of ignored local state | A |
| Q07 (missing) remote acceptance target | New question | A |

#### Plan verdict on Q01 to Q03 for plan architecture-minor-fallback (round 1)

Agree with A on all three. The three helpers match the three design
responsibilities. The four-line record is the simplest format that rejects
malformed input without evaluating it. A single reset flag with an optional
entry keeps Bash's combination checks in one place.

#### Plan verdict on Q04 for plan architecture-minor-fallback (round 1)

Agree with A. Add to the answer: "Each case group builds a temporary tree by
copying, not linking, `src/setups`, `src/utils` and `src/echos`, so the
`readlink -f` root lands in the fixture. Each case runs in its own subshell
because `fatal` exits. `ssh`, `scp` and `curl` are PATH stubs that record calls
and fail on any call a case did not declare. After every gate run, the runner
asserts that the real `src/setups` tree, including its ignored `last`,
`pkgs.log` and `temp.pkgs.txt`, is byte-identical to its state before the run."

#### Plan verdict on Q05 for plan architecture-minor-fallback (round 1)

Agree with A. Add: "The held-open case keeps the destination open without delete
sharing, for example `[IO.File]::Open(path, 'Open', 'Read', 'Read')`, and first
asserts that the replace attempt failed before checking that the prior index
survived."

#### Plan verdict on Q06 for plan architecture-minor-fallback (round 1)

Agree with A. Add: "The controlled checkout is seeded by copy with the legacy
`pkgs/<tool>/last` files, an active `setup.properties` without the exact 9.8
mirror key, and the local RPM cache. Their origin and digests are recorded in
the acceptance document."

#### Missing plan question Q07: which RHEL target may the host acceptance change? for plan architecture-minor-fallback (round 1)

Suggested body: "The controlled local checkout still drives the build account's
live cplx directory. Remote installation extracts any package version not yet
flagged installed into `tools/<tool>/root`, so a host run that regenerates the
index can refresh the python and git sandboxes before items 6 and 7."

- Option A: run both host passes against the live target with the committed,
  generated `packages_rhel_9.8_x86_64.txt` held (no reload, never deleted).
  Record a before/after inventory of `tools/pkgs` and each tool's installed
  flags, and require it to show no new extraction. Index generation, the "no
  index" shape and reload behavior stay owned by the fixtures.
  - Pro: meets AC7's "generated 9.8 index" with real synchronization and
    remote installation, and leaves the build sandbox exactly as items 6 and 7
    expect it.
  - Con: no host run exercises index generation. That evidence is fixture-only.
- Option B: bootstrap an isolated remote cplx directory for acceptance, and
  allow regeneration there.
  - Pro: exercises generation on the host without touching the live sandbox.
  - Con: needs a second remote environment (`.env`, `bin`, tool directories),
    which is setup work outside this item, and its evidence describes a tree
    nobody builds from.
- Option C: run against the live target and allow regeneration, accepting a
  sandbox refresh.
  - Pro: the most complete host evidence.
  - Con: changes the build account's sandboxes ahead of the items that own their
    refresh, which is not this item's decision to take.

Recommended: Option A. It gives AC7 its real host evidence without letting a
metadata-selection item change the toolchain inputs that later items own.

### Requested changes for plan architecture-minor-fallback round 1

Requested changes:

#### Requested changes to the shared checklist and commands for plan architecture-minor-fallback (round 1)

- **Ready command.** Replace the PowerShell block with
  `cmd /d /v:on /c "set NO_MORE_SENV_cplx=& call <NUL senv.bat && !GH!\bin\bash.exe docs/v0.27.0/verify.architecture-fallback.sh --step N"`.
  Replace "the delayed expansion is needed because `senv.bat` establishes `GH`"
  with: "`GH` comes from the user environment and `senv.bat` requires it; clearing
  the inherited guard makes `senv.bat` rebuild the path that exposes
  `shellcheck`, and delayed expansion reads `GH` after that call."
- **Checklist item 3.** After "Use an isolated fixture tree", add: "built by
  copying, never linking, `src/setups`, `src/utils` and `src/echos` into a
  temporary root, because `setup_packages.sh` derives its root through
  `readlink -f`. Run each case in a subshell, since `fatal` exits. Network
  commands are PATH stubs that fail on any undeclared call."
- **New checklist item after item 3.** "Before and after each gate run, record
  `git status --porcelain --ignored -- src/setups` together with the bytes of
  ignored `pkgs/*/last`. Fail the gate if either changed."
- **Failure-number paragraph.** Add: "114 and 115 also exist in the remote
  `packages_management.sh`; the exit-code reference attributes each number to
  its script."

#### Requested changes to Steps 2 and 4 for plan architecture-minor-fallback (round 1)

- **Step 2 tests.** Specify the held-open holder without delete sharing, and
  assert that the replace attempt failed.
- **Step 4 rollout item 2.** Add seeding by copy of the legacy `last` files, the
  active properties without the exact 9.8 key, and the local RPM cache, with
  origin and digests recorded.
- **Step 4 rollout items 4 and 5.** Under Q07 A: "both host passes hold the
  committed `packages_rhel_9.8_x86_64.txt`, set no reload flag, and record a
  before/after inventory of remote `tools/pkgs` and installed flags showing no
  new extraction; generation and the no-index shape are fixture evidence."
- **Step 1 completion.** Add the real-tree preservation check to "sourcing the
  main/helper scripts makes no network calls or persistent writes".

### Writer instructions for plan architecture-minor-fallback round 1

#### Instructions for the plan writer for plan architecture-minor-fallback (round 1)

1. Replace the ready command and its explanation as described in the requested
   changes. Keep the explicit Git Bash path; clear the guard; remove the inner
   quotes; state that `GH` comes from the user environment.
2. Add the fixture root seam, the per-case subshell, the failing network stubs
   and the real-tree preservation check to the shared checklist, to the Q04
   answer and to the Step 1 completion criterion.
3. Add plan question Q07 through `oqm`, with the suggested body, the three
   options, a BBQ in the same shape as the others, and Option A proposed. Align
   Step 4 rollout items 2, 4 and 5 with it.
4. Apply the P4 precisions to Q05, Q06, the failure-number paragraph and Step 4
   rollout item 2.
5. Keep the requirement, design, umbrella and focused draft unchanged. Perform
   no implementation, and publish a replacement request for plan round 2.

### Final reviewer decision for plan architecture-minor-fallback round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-14T15:53:48+02:00
- Exchange: specification/plan/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan architecture-minor-fallback (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
Review round: 2

### Requestor assessment for plan architecture-minor-fallback (round 2)

Round 1's P1-P4 findings are accepted and applied. The plan now has seven implementation questions, all proposing A. Requirement and design approvals, step numbering and scope are unchanged. The validation skeleton is aligned.

P1: the ready command clears NO_MORE_SENV_cplx, uses call <NUL senv.bat, and states that GH is a user-environment prerequisite. It uses the reviewed no-inner-quotes form for the current no-space installation and documents a temporary CMD-file fallback for a GH path containing spaces.

P2: case groups copy the required setup/utils/echos source files into a real fixture layout; readlink -f lands there. Cases run in subshells because fatal exits. Recording PATH stubs reject undeclared network operations and local output paths outside the fixture. The runner checks real setup status and content/existence of production mutation targets even on failure. We narrowed a literal copy/hash of the entire setup tree to required source files, targeted mutable-state bytes and a cache inventory plus pre-write stub path assertions: repeatedly copying or hashing the real RPM cache would defeat the plan's IO objective. This is an implementation refinement of the requested safety proof, not a disagreement with fixture isolation.

P3/Q07: proposed A holds the committed generated 9.8 index for both live-host passes and clears reload flags. Holding an index alone does not prove no extraction, so remote staged/installed package versions must pass preflight, then inventories and installation output must show no new extraction. Generation cases remain owned by fixtures. Because a held index plus a fully cached run would never lazily resolve mirrors, each tool's controlled cache seed deliberately omits one already-installed indexed RPM to force an actual mirror-fallback download; originals and remote staged files remain untouched. Other seeded entries prove cache reuse.

P4: the Windows holder denies delete sharing via a PowerShell read/read File.Open handle with a readiness/release handshake; replacement failure must be asserted. Exit codes are script-attributed. Controlled ignored properties, legacy progress and relevant RPMs are copied with origins/digests recorded. Q04-Q06 answers include these details.

Please confirm the seven proposed answers and their implementation coverage, or identify remaining substantive gaps. No implementation or host acceptance has run. Versioned review prose has received only the user's already-authorized mechanical sensitive-term replacements; protocol artifacts were not edited.

### Change summary for plan architecture-minor-fallback (round 2)

Applied the ready-command/environment correction, executable fixture-root/process seam and real-state preservation checks, Windows no-delete-sharing holder, script-qualified failures and controlled ignored-state seeding. Added Q07 for held-index live RHEL acceptance with preflight/no-new-extraction controls and a controlled cache omission that proves lazy mirror fallback. Re-aligned the Step 4 validation expectations; all four steps and 24 unchecked placeholders remain. Updated questions only through the oqm companion workflow.

### Writer response for plan architecture-minor-fallback (round 2)

Writer response:

Accepted all round 1 findings. The fixture proposal is implemented as copies of required source/dependency files rather than the full real cache, backed by state-byte checks, cache inventory and fixture-only output assertions. The Q07 proposal also preflights remote installed/staged state and forces one controlled cache miss per tool, because neither a held index nor a fully cached host run alone proves the required behavior. No disagreement flag is needed. Earlier requirement/design policies remain fixed.

### Reviewer focus for plan architecture-minor-fallback (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-14T16:03:01+02:00
- Exchange: specification/plan/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan architecture-minor-fallback round 2

#### Verification of the plan round 1 changes for plan architecture-minor-fallback (round 2)

P1 to P4 are applied.

- **P1.** The ready command is now the guard-clearing form I ran in round 1,
  with a correct account of `GH` and a `.cmd` fallback for a path with spaces.
- **P2.** The fixture seam copies the scripts, runs each case in a subshell and
  fails undeclared network calls. The writer narrowed my whole-tree comparison
  to a manifest of the mutable targets, plus a path/size/timestamp inventory of
  the RPM cache, plus output-path assertions in the stubs. That is sound. A
  write the stubs cannot see (a redirection or `mv` into the real cache) still
  changes the inventory. Hashing gigabytes of cached RPMs would contradict the
  plan's own IO rules.
- **Q07.** The proposed answer is A. The added remote preflight is right,
  because holding the index does not by itself guarantee a no-op installation.
  So is the one-RPM cache omission per tool, since a fully cached run would
  never resolve a mirror and could not prove the mirror fallback.
- **P4.** The share-mode holder, script-attributed codes and seeded ignored
  state are all present.

#### New finding: the Step 4 host procedure cannot complete for git for plan architecture-minor-fallback (round 2)

I checked what Step 4 would meet on the host by resolving every active entry of
both 9.8 lists against the held `packages_rhel_9.8_x86_64.txt`, with the same
regular expression as `find_package_in_arch`. I compared each result with the
local cache under `src/setups/pkgs/rhel_9.8_x86_64/`:

| Tool | Active entries | Resolve in held index | Already cached | Sync marker |
| --- | --- | --- | --- | --- |
| python | 56 | 56 | 56 | `pkgs/python/last`, dated 2026-08-23 |
| git | 49 | 47 | 22 | none |

Python is exactly the shape Step 4 assumes: a completed 9.8 sync, every entry
resolving, and every RPM cached.

Git is not. Its dependency setup has evidently never completed against the 9.8
index from this workstation, and three pre-existing defects stand in the way:

- `libcom_err,` (line 24, trailing comma) and `libxslti` (line 37) match nothing
  in the index, so synchronization stops with fatal 301. Both lines are
  identical in the 9.6 list. The evident intended names each have a single
  match: `libcom_err-1.46.5-8.el9.x86_64.rpm` and
  `libxslt-1.1.34-16.el9.x86_64.rpm`. The neighbouring `docbook-dtds` and
  `xmlto` entries are consistent with `libxslt`, which provides `xsltproc`.
- Of the 25 resolvable git RPMs that were never cached, I sent HTTP HEAD
  requests for each to the three configured 9.6 mirror URLs. 24 are still
  served. `unzip-6.0-59.el9.x86_64.rpm` returned no 200 from any of them: the
  rolling mirrors have dropped the version the held index names.

So under the plan as written, Step 4 rollout item 3 records blockers for git
(two unresolved entries, and remote installed state that almost certainly does
not exist). Its rules forbid the remedies: "do not silently correct unrelated
entries", and Q07 A forbids new extraction and regeneration. Even with both
typos corrected, the held index cannot serve `unzip`. Only a regenerated index
could, and one index is shared by python and git, so regenerating it for git
changes python's resolution too. AC7's "completes dependency setup for Python
and Git" is therefore unreachable inside the plan's own constraints. The plan
needs a decision (missing question Q08), and that decision touches the
consolidated acceptance scope, so it belongs to the human.

#### Smaller precision for the cache omission for plan architecture-minor-fallback (round 2)

The omitted python RPM must still be served by the selected mirrors. The
`unzip` result shows that a file named by the held index can already be gone.
If the omitted file has rolled, the forced download fails for a reason
unrelated to the resolver. The preflight should choose the omitted RPM among
filenames confirmed by a HEAD request to the selected mirror URLs, and record a
blocker only if none qualifies.

#### Disposition reasoning for plan round 2 for plan architecture-minor-fallback (round 2)

The disposition is `changes-requested`. Q08 is a missing decision that blocks
Step 4 and needs the human's call on AC7's host scope. The omission precision
travels with it. Everything else in the plan is ready.

### Question verdicts for plan architecture-minor-fallback round 2

#### Plan round 2 verdict table for plan architecture-minor-fallback (round 2)

| Question | Verdict | Answer I would choose |
| --- | --- | --- |
| Q01 helper allocation | Agree | A |
| Q02 progress record syntax | Agree | A |
| Q03 reset argument spelling | Agree | A |
| Q04 verification organization | Agree, as revised | A |
| Q05 Windows validation timing | Agree, as revised | A |
| Q06 controlled local workspace | Agree, as revised | A |
| Q07 remote acceptance target | Agree, add the served-file check for the omitted RPM | A |
| Q08 (missing) git host acceptance | New question | B |

#### Plan round 2 verdict on Q07 for plan architecture-minor-fallback (round 2)

Agree with A as revised. Add to the answer: "The deliberately omitted RPM is
chosen among cached filenames that a HEAD request confirms the selected mirror
URLs still serve; if none qualifies, record a blocker rather than a resolver
failure."

#### Missing plan question Q08: how is AC7's git half demonstrated? for plan architecture-minor-fallback (round 2)

Suggested body: "Against the held 9.8 index, git's list has two entries that
resolve to nothing (`libcom_err,` and `libxslti`, identical in the 9.6 list).
25 of its resolvable RPMs were never cached, and `unzip-6.0-59.el9.x86_64.rpm`
is no longer served by any configured mirror. Git has no sync marker. Under Q07
A, git's live setup cannot complete: the typos stop synchronization, and the
rolled `unzip` could only be served by regenerating the index that python
shares."

- Option A: live host acceptance for python only, under Q07 A. Git's list
  fallback, synchronization and copy are proven by the entry-point fixtures that
  already use the git list shape. The three git defects are recorded as a named
  follow-up for item 7, whose refresh regenerates the index anyway. AC7's host
  clause is amended to python at consolidation.
  - Pro: no curated change beyond the requirement's approval, no git sandbox
    change, and python exercises every resolver path on the host.
  - Con: needs the human to narrow a consolidated acceptance criterion, and the
    typos stay in both git lists until item 7.
- Option B: as A, but also correct `libcom_err,` to `libcom_err` and `libxslti`
  to `libxslt` in the retained 9.6 git list. The correction is evidenced by
  each name's single index match and recorded before the equivalence proof and
  the 9.8 removal. `unzip` remains item 7's regeneration follow-up. AC7's host
  clause is still amended to python.
  - Pro: the list this item retains, and item 7 will consume, is correct. The
    correction is the same kind the human already approved for `zlib-devel`,
    and it costs nothing on the host.
  - Con: extends Q10's curated correction to two more entries, which needs
    explicit human approval, and still narrows AC7.
- Option C: correct both typos, regenerate the 9.8 index on the host, and run
  full python and git setup, accepting new extraction into both live sandboxes
  (Q07 option C).
  - Pro: meets AC7 exactly as consolidated.
  - Con: refreshes the python sandbox ahead of items 6 and 7, and contradicts the
    Q07 answer the plan just adopted.

Recommended: Option B. The resolver behavior is fully demonstrated by python on
the host and by fixtures for git. Correcting two evidenced typos in the list
this item keeps is cheap and removes a certain failure from item 7. The rolled
`unzip` is exactly what item 7's regeneration exists for. Whichever option the
human picks, the change to AC7's host scope must be decided at consolidation,
not assumed by the implementation.

### Requested changes for plan architecture-minor-fallback round 2

Requested changes:

#### Plan round 2 requested changes for plan architecture-minor-fallback (round 2)

- **Confirmed facts.** Add a paragraph with the python and git resolution,
  cache and marker evidence, the two unresolved git entries with their
  single-match intended names, and the unserved `unzip` file.
- **Step 4 tests.** Keep the git list shape in the entry-point fixture,
  including a fixture that proves a git fallback selection and its
  `dependencies.list` copy without host access.
- **Step 4 rollout item 1 (under Q08 B).** After the `zlib-devel` correction,
  correct `libcom_err,` to `libcom_err` and `libxslti` to `libxslt` in the
  retained 9.6 git list. Record each name's single index match before the
  equivalence proof that precedes removing the 9.8 git list.
- **Step 4 rollout items 3 to 5.** Scope the live host passes, the preflight and
  the before/after inventories to python. State that git's host synchronization
  is not attempted, and why.
- **Step 4 rollout item 4.** Choose the omitted python RPM among cached
  filenames confirmed served by the selected mirror URLs.
- **Step 4 completion and acceptance document.** Replace "controlled
  pre-removal and final-tree RHEL Python/Git setup pass" with the python-only
  host scope. Add the git follow-up (the rolled `unzip`, and git host setup)
  for item 7.
- **Consolidation note.** Add: "AC7's host clause names Python and Git; plan Q08
  proposes a python-only host demonstration, which requires the human to amend
  AC7 at consolidation."

### Writer instructions for plan architecture-minor-fallback round 2

#### Plan round 2 instructions for the writer for plan architecture-minor-fallback (round 2)

1. Add plan question Q08 through `oqm`, with the suggested body, the three
   options, a BBQ in the same shape as the others, and Option B proposed. Mark
   it as requiring the human's decision on AC7's host scope.
2. Record the git evidence in the confirmed facts: 49 active entries, 2
   unresolved, 25 never cached, `unzip-6.0-59.el9.x86_64.rpm` no longer served,
   no `pkgs/git/last`. Record the python evidence as well: 56 entries, all
   resolved and cached, marker dated 2026-08-23.
3. Align Step 4 with the proposed Q08 answer, as listed in the requested
   changes, and add the served-file check to the Q07 answer and rollout item 4.
4. Do not change the requirement or design in this round. List the AC7 host
   scope amendment for consolidation. Perform no implementation, correction or
   host run, and publish a replacement request for plan round 3.

### Final reviewer decision for plan architecture-minor-fallback round 2

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-09-14T16:14:03+02:00
- Exchange: specification/plan/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan architecture-minor-fallback (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
Review round: 3

### Requestor assessment for plan architecture-minor-fallback (round 3)

Round 2's concrete Git list/cache/mirror findings are accepted and recorded. All round 1 fixes remain present. The plan now proposes eight implementation answers: Q07 B and all others A. The four-step validation skeleton is aligned, with no implementation claims.

I disagree with narrowing approved AC7 to Python-only host acceptance. The canonical plan question workflow explicitly prohibits reopening feature/requirement scope. Q07 A was a proposed plan answer, not a human decision, and Q07 already offered an isolated-target option B. Round 2's blocker justifies changing that proposed test strategy rather than weakening settled acceptance.

Q07 B now uses a unique remote sibling cplx target on the same RHEL host, with a fresh detected-key index generated only in the controlled authoring checkout. Existing tracked bootstrap materials and package-management code prepare directories and extract dependencies inside that target. The plan identifies the staging manifest, required configuration, pre-source tool/current links, per-tool link switching, resolved-path containment, startup/import-chain audit, and unchanged live-target inventories. No general setup main, tool compilation/build/packaging/deployment is invoked. Ordinary lookup/download failures leave Step 4 incomplete.

Q08 A explicitly inventories the two Git corrections in both lists before a direct equality proof and subsequent redundant-list removal. These exact edits are proposed for the upcoming human plan gate; no runtime normalization, added dependencies, or hidden curated changes are permitted. This preserves correction-before-comparison ordering and keeps the retained list usable for the required Git setup.

Served-file HEAD preflight for deliberately omitted RPMs is retained. The plan distinguishes copied Python legacy state from a synthetic Git legacy marker, because no Git marker exists. It records fresh-index generation, actual per-entry synchronization, new isolated extraction, reuse and final-tree repetition as separate evidence.

Please review the revised implementation strategy and eight proposed answers. Requirement AC7 and design decisions remain fixed. If you believe a prerequisite still requires an earlier-phase scope decision, identify the exact conflict without proposing a plan question that silently amends AC7.

### Change summary for plan architecture-minor-fallback (round 3)

Recorded the round 2 Python/Git resolution, cache, marker and stale-RPM findings. Changed proposed Q07 from held-index live-target A to fresh-index isolated-target B, with an existing-code bootstrap manifest and containment/preservation checks. Added Q08 A for paired Git typo corrections before direct equality and cleanup. Kept full real RHEL Python/Git acceptance and added served-file preflight plus explicit synthetic Git legacy state. Aligned the Step 4 file inventory and validation skeleton; no production implementation or host acceptance was executed.

### Writer response for plan architecture-minor-fallback (round 3)

Writer response:

Accepted the observed Git blockers and served-file preflight recommendation. Explicit disagreement: do not narrow consolidated AC7 or defer its Git host half to item 7. Plan Q07 A had no human approval and its existing option B provides a way to preserve AC7 without refreshing live roots. The plan now recommends B, with concrete bootstrap and isolation controls. New Q08 A proposes the two exact Git name corrections in both copies before equivalence and removal, subject to the upcoming plan approval. All previous implementation clarifications remain in place. This round changes only planning documents and questions; earlier requirement/design files and production files are unchanged.

### Reviewer focus for plan architecture-minor-fallback (round 3)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-09-14T16:18:32+02:00
- Exchange: specification/plan/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan architecture-minor-fallback round 3

#### Response to the writer's disagreement for plan architecture-minor-fallback (round 3)

The disagreement is correct, and I withdraw my round 2 Q08 recommendation.
Q07 option A was my proposal, not a human decision, and a plan question that
narrows AC7's host clause amends a consolidated requirement through the back
door. The right response to the git blocker was to change the proposed test
strategy while keeping the acceptance criterion, which is what round 3 does.
The round 2 evidence (typos, uncached RPMs, the unserved `unzip` file) remains
valid, and the plan records it as facts to recheck at implementation.

#### Feasibility of Q07 option B, checked against the code for plan architecture-minor-fallback (round 3)

The isolated remote target stands or falls on whether the remote environment
follows the target directory rather than the live tree. I checked each link the
plan relies on:

- **`HOME` follows the target.** `src/setups/env/.env:17-22` derives
  `env_HOME_DIR` from its own location through `readlink -f` and assigns it to
  `HOME`. Everything after that line (`tools`, `tool`, `root`, `tool_pkgs`,
  `properties_file`, the sourced `bin/` and `echos/` helpers) resolves inside
  whichever tree holds that `.env`.
- **The staging manifest matches the real bootstrap.** `copy_the_environment`
  (`setup.sh:177-183`) stages `src/setups/env/` at the root, `src/utils` at
  `bin/`, `src/echos` at `echos/` and `src/install/env` at `tools/`, exactly as
  the plan lists.
- **`tools/setup` only prepares directories and links.**
  `src/setups/env/tools/setup` sources `../.env`, creates
  `<tool>/<tool>-<version>/usr/bin`, `root`, `logs`, `pkgs` and `sources`, and
  switches the `tool` and `current` links. It compiles or fetches nothing.
  Because it sources `.env`, which reads `tools/tool` and needs `services`,
  `CPLX_ARCH_EXT` and matching `CPLX_CHECK_*` basenames
  (`.env:179-224`), the plan's order is required rather than arbitrary: links and
  properties first, then sourcing.
- **Remote installation stays under `HOME`.** `packages_management.sh`
  addresses `${HOME}/tools/...` throughout, and its only `/home/` and `~/`
  occurrences are comments (lines 1578, 1611, 1707).
  `src/install/env/install_functions.sh` has none.
- **The one remaining leak is the one the plan audits.** `.env:8` sources
  `${HOME}/.profile` before it reassigns `HOME`, so the real account's profile
  runs with the real `HOME`. The plan's "audit the account's startup profile ...
  and stop if they redirect writable state outside that target" is the right
  control. I suggest making its evidence concrete in the covered wording.

With a fresh detected-key index generated in the controlled checkout, `unzip`
resolves to whatever version the mirrors currently serve, so the round 2
blocker disappears without touching the live sandboxes. The HEAD-verified cache
omission, the copied versus synthetic legacy markers, and the live-target
before/after inventories give AC7 real host evidence of synchronization,
fallback, extraction and reuse.

#### Q08 option A for plan architecture-minor-fallback (round 3)

Correcting both git lists before a byte-equality proof is cleaner than a
normalized comparison, and it matches how the python correction is handled. One
point should be explicit for the human gate: this extends the requirement's Q10
correction set from one entry to three. The plan already makes that subject to
plan approval, and the covered wording asks it to say so in those terms.

#### Remaining observations for plan round 3 for plan architecture-minor-fallback (round 3)

Two small evidence gaps remain, both wording:

- the controlled checkout is a second tree with its own `senv.bat`, so its host
  passes should show that the authoring tree was untouched and that the run did
  not inherit the authoring session's environment;
- the profile audit should record what it saw.

Neither changes the strategy.

### Question verdicts for plan architecture-minor-fallback round 3

#### Plan round 3 verdict table for plan architecture-minor-fallback (round 3)

| Question | Verdict | Answer I would choose |
| --- | --- | --- |
| Q01 helper allocation | Agree | A |
| Q02 progress record syntax | Agree | A |
| Q03 reset argument spelling | Agree | A |
| Q04 verification organization | Agree | A |
| Q05 Windows validation timing | Agree | A |
| Q06 controlled local workspace | Agree | A |
| Q07 remote target and index | Agree, feasibility confirmed in the code | B |
| Q08 paired git corrections | Agree | A |

No plan question is missing. My round 2 proposal to narrow AC7 is withdrawn;
the requirement's acceptance scope stays as consolidated.

### Convergence evidence for plan architecture-minor-fallback round 3

Covered wording:

#### Plan wording edits covered by this recommendation for plan architecture-minor-fallback (round 3)

1. **Step 4 rollout item 4, at its end.** Add: "Run the controlled checkout's
   setup from a CMD process that clears that checkout's own `NO_MORE_SENV_`
   guard, and confirm that the environment values it derives (for example
   `project_dir_unix`) name the controlled checkout. Before and after each host
   pass, record the authoring tree's `git status --porcelain --ignored --
   src/setups` and its `pkgs/*/last` bytes, and require them unchanged."
2. **Bootstrap paragraph, after the startup-profile audit sentence.** Add:
   "`.env` sources the account's `~/.profile` before it reassigns `HOME`. Record
   that profile's digest and the files it sources, and stop if any of them
   sources a cplx `.env` or writes beneath the live tree."
3. **Q08 answer, at its end.** Add: "This extends the requirement's Q10 curated
   correction from one entry to three; approving this plan is where that
   extension is decided."

Convergence rationale:

#### Why this plan is ready for consolidation for plan architecture-minor-fallback (round 3)

- Every round 1 and round 2 finding is resolved: the ready command, the fixture
  seam and preservation proof, the served-file omission, and the git blockers.
- AC7 is kept as consolidated. The isolated remote target makes full Python and
  Git host acceptance reachable, and I confirmed its feasibility in `.env`,
  `setup.sh`, `tools/setup` and `packages_management.sh`.
- All eight answers are the ones I would choose. AC1 to AC12 each have an
  executable owner, and the steps and gates are concrete.
- What remains is three sentences of evidence and approval wording.

### Writer instructions for plan architecture-minor-fallback round 3

#### Plan round 3 instructions for the writer for plan architecture-minor-fallback (round 3)

1. Present this convergence recommendation to the human, calling out the Q07 B
   isolated remote target and the Q08 A extension of the curated corrections.
   The recommendation does not authorize consolidation.
2. When consolidating, apply the three covered wording edits.
3. Perform no implementation, curated edit or host run as part of
   consolidation.

### Final reviewer decision for plan architecture-minor-fallback round 3

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-3 -->

## Round 3 by human - human-confirmation

- Recorded: 2026-09-14T16:45:08+02:00
- Exchange: specification/plan/v0.27.0/architecture-minor-fallback
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.architecture-minor-fallback.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-3 -->
