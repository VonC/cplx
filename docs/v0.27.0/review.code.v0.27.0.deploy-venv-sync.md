# Code review transcript for v0.27.0

- Exchange: code/code/v0.27.0/deploy-venv-sync
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor - Step 1

- Recorded: 2026-09-23T13:52:53+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 1
- Outcome: request

### Review identity for step 1 deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 1
Review round: 1

### Code review evidence for step 1 deploy-venv-sync (round 1)

request_index_tree: f7c2fc3e2bad20aeb064f1ebff93b37e1fe5fb4a
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 1 --python $DEPLOY_TEST_PYTHON --app-repo $DEPLOY_CONSUMER_ROOT (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 1 --python $DEPLOY_TOOLS_PYTHON --tools-prefix $DEPLOY_TOOLS_PREFIX --application-root $DEPLOY_APPLICATION_ROOT --manifest $DEPLOY_MANIFEST --profile $DEPLOY_PROFILE --evidence-root $DEPLOY_EVIDENCE_ROOT (sources: plan)
- consumer: ghog day (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy): verify release inputs and transport
group 1 path: src/setups/env/bin/deploy_venv_inputs.py
group 1 path: src/setups/env/bin/deploy_venv_transport.py
group 1 path: tests/unit/deploy_venv_sync/__init__.py
group 1 path: tests/unit/deploy_venv_sync/test_release_inputs/__init__.py
group 1 path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
group 1 path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py
group 2: test(deploy): qualify isolated locked wheel sync
group 2 path: src/setups/env/bin/deploy_venv_probe.py
group 2 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 2 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 2 path: tests/unit/deploy_venv_sync/test_native_probe/__init__.py
group 2 path: tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py
group 2 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
group 3: docs(deploy-venv-sync): record step 1 validation
group 3 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_inputs.py
staged path: src/setups/env/bin/deploy_venv_probe.py
staged path: src/setups/env/bin/deploy_venv_transport.py
staged path: tests/unit/deploy_venv_sync/__init__.py
staged path: tests/unit/deploy_venv_sync/test_native_probe/__init__.py
staged path: tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/__init__.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
```

### Requestor assessment for step 1 deploy-venv-sync (round 1)

Yes. Step 1 has been fully implemented.

The writer's formal check records manifest-bound native acceptance on Debian 12
and RHEL 9.8, the same original static uv 0.12.17 and shipped Python 3.13.15,
empty caches and denied remote access. File transport was attempted first;
both targets passed the approved loopback fallback under --locked --no-build
without project installation. Missing-wheel, stale-lock and incompatible-wheel
cases failed as required. Native cumulative verification passed 106 tests,
syntax, mandatory shell lint, ShellCheck and the 650-line gate. Consumer static,
affected and full checks passed with fail=0 warn=8 xfail=8 cov=100 outliers=0.
Coverage measures only the configured application source, not these standalone
helpers. Their top-level references and unit/native exercise are documented.
No architecture, performance or existing-feature regression was identified.
Review should independently challenge the scoped completion claim.

### Implementation report for step 1 deploy-venv-sync (round 1)

Three standalone modules separate manifest/bundle integrity, structural metadata
transport and native qualification. The release record binds independent tools
and application identities without circular hashes. Extraction rejects unsafe,
duplicate, missing or unlisted members; canonical input bytes remain immutable.
The probe uses explicit delivered paths, a fresh environment/cache per command,
an allowlisted local server and retained commands/results.

Two native shell entries own cumulative verification and manifest-driven target
acceptance. Unit and generated fixtures cover the principal integrity boundaries.
Mapped consumer P01-P05 changes and original uv acquisition are committed and
qualified separately; P16 is preserved and P17 is a generated fixture at this
step. Required private handoff evidence is available locally, never copied into
this public transcript. Full production assembly is Step 4, the single-build
CI sequence is Step 5, and exact-candidate lifecycle acceptance is Step 7.

### Change summary for step 1 deploy-venv-sync (round 1)

The staged 13 paths form three validated groups in root a.commit:

1. feat(deploy): verify release inputs and transport
   Includes deploy_venv_inputs.py, deploy_venv_transport.py, the release-input
   TDD/PBT files and their two package markers.
2. test(deploy): qualify isolated locked wheel sync
   Includes deploy_venv_probe.py, the native probe test and marker, both native
   shell entries and the implementation plan's four completion checkpoints.
3. docs(deploy-venv-sync): record step 1 validation
   Includes only the exact validation plan, as the trailing completion group.

All implementation paths are under src/setups/env/bin, tests/unit/deploy_venv_sync
or docs/v0.27.0 as named in the plan. The renderer captures the exact staged tree.
The review transcript generated by publication is a subsequent workflow artifact.

### Human guidance and writer response for step 1 deploy-venv-sync (round 1)

Human guidance:

Read the mandatory local integration handoff named by AGENTS.md before assessing
the consumer obligations. Keep concrete corporate names, paths, endpoints and
build identities out of public documents and review summaries.

The native commands require a real supported Linux target and explicit paths to
the shipped Python, consumer checkout and retained manifest inputs. Resolve the
DEPLOY_* command variables from the retained private invocation/evidence; do not
run ELF qualification under Git Bash. Existing final native and consumer logs
are available through that handoff. cplx has no configured Python coverage gate;
its plan uses the cumulative native harness while the consumer uses ghog day.
The mandatory project validation remains additive and unchanged.

Writer response:

Initial implementation review request for Step 1; no prior implementation-review
findings exist. Please assess the staged implementation and recorded boundaries,
including the companion closure, transport identity preservation and actual
native acceptance evidence. Do not count later-step production lifecycle work
as completed by the minimal qualification fixture.

### Reviewer focus for step 1 deploy-venv-sync (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-1-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `.reviews/a.review-active.code.code.v0.27.0.deploy-venv-sync.md`
- `.reviews/a.review-requested.code.v0.27.0.deploy-venv-sync.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer - Step 1

- Recorded: 2026-09-23T14:09:53+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: answer

### Assessed index identity for step 1 deploy-venv-sync (exchange 1) (round 1)

Baseline index tree: f7c2fc3e2bad20aeb064f1ebff93b37e1fe5fb4a

Assessed index tree: f7c2fc3e2bad20aeb064f1ebff93b37e1fe5fb4a

### Implementation check for step 1 deploy-venv-sync (exchange 1) (round 1)

Result:

No. Step 1 has NOT been fully implemented.

The step is very nearly done. I reproduced every claim independently, on the
exact reviewed index tree rather than the writer's copy, and one defect in the
staged probe remains.

What I verified myself:

- **Native cumulative harness on RHEL 9.8**, against the reviewed tree shipped
  as a fresh archive: exit 0, 106 tests, syntax, the mandatory Bash lint floor,
  ShellCheck and the 650-line scan. The harness's own guard also proved itself:
  it refused a wrapper interpreter that masks exit codes.
- **Manifest-bound acceptance probe on RHEL**, in an isolated network namespace,
  using the staged code and the retained release inputs: state `passed`,
  loopback transport, uv `42949aef...` and toolchain `df7dff7d...` matching the
  release record, `packaging 25.0` installed, and the three negative cases
  refusing as required (missing wheel and stale lock exit 1, incompatible wheel
  exit 2). The file transport attempt exited 1 first, as the retained evidence
  also shows, so the approved fallback is the qualified path.
- **Debian side**: the focused consumer build succeeded in 10 minutes 27 seconds
  on the pushed revision. Concrete build and revision identities are retained
  in the required private integration handoff.
- **Release record binding**: the retained record binds toolchain 10.0.0 with
  digest `df7dff7d...`, the archive accepted in item 7, so this step reuses that
  archive rather than republishing it.
- Local lint, ShellCheck at style severity and `git diff --cached --check` all pass.

#### Missing work for Step 1 for step 1 deploy-venv-sync (exchange 1) (round 1)

- **`deploy_venv_probe.py`: `check_isolation` accepts a namespace whose
  loopback is down, and the resulting failure blames the design.** It compares
  interface names against `{"lo"}` and confirms that an external connect fails,
  but never confirms that loopback itself works. In a namespace created with
  `unshare -rn` and no `ip link set lo up`, `lo` exists and is DOWN. The file
  transport then fails for its own reason, the loopback server is unreachable
  (`Network unreachable`, errno 101, visible in `loopback.log`), and the probe
  ends with "both designed transports failed; design review required". That
  message is the plan's own trigger to stop Step 1 and return to design review,
  so an environment slip is reported as a design dead end. I hit exactly this
  before bringing `lo` up, and the same run passed afterwards with no code change.
  Add a loopback usability precondition to `check_isolation`: bind a socket on
  `127.0.0.1`, connect to it, and raise a distinct error naming the unusable
  loopback, so it cannot be confused with a transport verdict. Cover it with a
  case in `test_native_probe_tdd.py` beside the existing interface check.

Architecture: three standalone helpers with separate responsibilities (input
integrity, structural metadata mapping, native qualification), loaded by path,
with no new package or class hierarchy. Isolated-mode imports are handled
explicitly. No layer or DDD violation. Nothing needs to be addressed there.

Performance: work is linear in declared inputs and streamed by block. Each sync
uses its own empty cache and environment. No quadratic scan. No performance
issue needs to be addressed.

Unit test coverage: the new modules are standalone scripts outside any
configured coverage gate, and cplx has no coverage gate, so no percentage is
claimed. Every top-level function in the three modules is referenced by the
unit tests or by the native entries, except the loopback precondition that does
not exist yet. The 25 fixture tests and the 106-test cumulative run exercise
them. No unit-tested class is below 100%, and no changed top-level symbol
outside the gate is unreferenced.

Validation plan effects:

The reviewer made no edit to the validation plan. Its Step 1 rows were checked
against reproduced evidence; they will need the No verdict and the missing-work
entry once the writer applies the fix and reruns its own check.

### Pre-repair mandatory checks and coverage for step 1 deploy-venv-sync (exchange 1) (round 1)

All mandatory validation ran before any repair, and the reviewer made no repair.

- `bash src/utils/lint_shell.sh` through the project environment: exit 0, 58
  tracked scripts clean. Direct ShellCheck at style severity on both new
  scripts: exit 0.
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 1 --python <toolchain
  3.13.15> --app-repo <consumer checkout>` on native RHEL 9.8, against the
  reviewed index tree `f7c2fc3e2bad20aeb064f1ebff93b37e1fe5fb4a` shipped as a
  fresh `git archive`: exit 0 in 39 seconds, 106 tests, syntax, lint,
  ShellCheck and the 650-line scan.
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 1` on native RHEL
  9.8 in an isolated network namespace, with the retained manifest, profile and
  application root: exit 0, state `passed`, transport `loopback`, elapsed
  9.321 seconds. Commands: uv headers, uv dynamic and uv version 0; file 1;
  loopback 0; loopback inventory 0; missing wheel 1; stale lock 1;
  incompatible wheel 2. Isolation recorded `lo` only with external connect
  errno 101. Installed inventory `packaging 25.0`.
- `git diff --cached --check`: exit 0.
- Consumer `ghog day` was not rerun by the reviewer. Its recorded result is the
  writer's, and this round's finding does not touch consumer files.

The first acceptance attempt failed in a namespace whose loopback was down.
That run produced the finding rather than a defect verdict on the transport;
the passing run above used the same staged bytes.

### Resolved validation set and sources for step 1 deploy-venv-sync (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 1 --python $DEPLOY_TEST_PYTHON --app-repo $DEPLOY_CONSUMER_ROOT` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 1 --python $DEPLOY_TOOLS_PYTHON --tools-prefix $DEPLOY_TOOLS_PREFIX --application-root $DEPLOY_APPLICATION_ROOT --manifest $DEPLOY_MANIFEST --profile $DEPLOY_PROFILE --evidence-root $DEPLOY_EVIDENCE_ROOT` (source: plan).
- `consumer: ghog day` (source: plan); not rerun by the reviewer, as recorded in the validation notes.

### Resolver drift and direction for step 1 deploy-venv-sync (exchange 1) (round 1)

No drift. The current resolver set equals the request set. Three of the four
commands ran; the consumer walk is the writer's recorded result and is
untouched by this round's finding.

### Repository state around validation for step 1 deploy-venv-sync (exchange 1) (round 1)

The index tree was `f7c2fc3e2bad20aeb064f1ebff93b37e1fe5fb4a` at request time,
at review entry and after the assessment. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison over all thirteen staged paths
is acceptable, with no tracked, untracked or ignored differences. The only
unstaged change is the protocol transcript created by publication.

### Repair inventory for step 1 deploy-venv-sync (exchange 1) (round 1)

Repairs made:

- None. The reviewer made no repair and staged nothing. The single finding needs
- a behavior change with its own test, which belongs to the writer.

Paths staged:

- - `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md`
- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- - `docs/v0.27.0/verify.deploy-venv-sync.sh`
- - `src/setups/env/bin/deploy_venv_inputs.py`
- - `src/setups/env/bin/deploy_venv_probe.py`
- - `src/setups/env/bin/deploy_venv_transport.py`
- - `tests/unit/deploy_venv_sync/__init__.py`
- - `tests/unit/deploy_venv_sync/test_native_probe/__init__.py`
- - `tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py`
- - `tests/unit/deploy_venv_sync/test_release_inputs/__init__.py`
- - `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py`
- - `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`

### Commit plan assessment for step 1 deploy-venv-sync (exchange 1) (round 1)

The independent `commit-plan-check.bat --format json` run returned state
`valid`, `ready: true` and no diagnostics, covering all thirteen staged paths in
three groups: the input and transport modules with their tests
(`feat(deploy)`), the probe, native entries and plan checkpoints
(`test(deploy)`), then the validation plan alone (`docs(deploy-venv-sync)`).
Order and subjects match the staged content, and the fix requested in this
round touches files already inside groups 1 and 2. `a.commit` remains accurate;
the reviewer did not amend it.

### Findings and boundaries for step 1 deploy-venv-sync (exchange 1) (round 1)

Unresolved findings:

- One finding, in `src/setups/env/bin/deploy_venv_probe.py`.
- `check_isolation` proves that only `lo` is present and that external access
- fails, but not that loopback is usable. A namespace from `unshare -rn` has `lo`
- DOWN by default. The probe then reports "both designed transports failed;
- design review required", which is the plan's trigger to stop the step and
- return to design review, although only the caller's namespace setup was wrong.
- Reproduction on RHEL 9.8, with the staged code and the retained release inputs:
- - `unshare -rn bash acceptance.deploy-venv-sync.sh --step 1 ...` fails, with
- `loopback.log` showing `tcp connect error: Network unreachable (os error 101)`
- against `http://127.0.0.1:<port>/wheels/...`.
- - The same command with `ip link set lo up` first passes, state `passed`,
- transport `loopback`.
- Suggested fix: after the interface check, bind a socket on `127.0.0.1:0`,
- connect to it and close it. On failure raise a distinct error such as
- "supplied namespace has no usable loopback", separate from any transport
- verdict. Add the matching case to `test_native_probe_tdd.py`.

Boundary-crossing work:

- None. The consumer P01-P05 changes are committed and pushed in the consuming
- repository, as this step's plan expects, and were not modified here. Production
- record assembly stays in Step 4, the single-build CI sequence in Step 5, and
- lifecycle acceptance in Step 7.

### Human guidance response for step 1 deploy-venv-sync (exchange 1) (round 1)

Human guidance:

Read the mandatory local integration handoff named by AGENTS.md before assessing
the consumer obligations. Keep concrete corporate names, paths, endpoints and
build identities out of public documents and review summaries.
The native commands require a real supported Linux target and explicit paths to
the shipped Python, consumer checkout and retained manifest inputs. Resolve the
DEPLOY_* command variables from the retained private invocation/evidence; do not
run ELF qualification under Git Bash. Existing final native and consumer logs
are available through that handoff. cplx has no configured Python coverage gate;
its plan uses the cumulative native harness while the consumer uses ghog day.
The mandatory project validation remains additive and unchanged.

Guidance response:

The human guidance was followed. The mandatory local integration handoff named
by the repository instructions was read before assessing the consumer
obligations, and its private identifiers, paths, build numbers and endpoints
stay out of this answer and the transcript. The DEPLOY_* command values were
resolved from the retained private invocation and evidence: the toolchain
prefix and its shipped 3.13.15 interpreter, the retained manifest and profile,
and an application root whose canonical metadata matches the manifest digests.
All ELF and runtime qualification ran on the native Linux target, never under
Git Bash. The project validation floor ran unchanged and additively.

### Writer instructions for step 1 deploy-venv-sync (exchange 1) (round 1)

One change, then publish the next round.

- **Add a loopback usability precondition to `check_isolation` in
  `src/setups/env/bin/deploy_venv_probe.py`.** Keep the existing interface and
  external-access checks. After them, bind and connect a socket on `127.0.0.1`
  and fail with a distinct message when that does not work, so an unusable
  namespace is never reported as "both designed transports failed".
- **Add the matching test** in
  `tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py`,
  beside `test_isolation_rejects_an_external_interface`.
- Re-run the native cumulative harness. The target acceptance probe does not
  need a fresh platform run for this change, since the qualified transport
  result is unaffected; say so explicitly in the next round rather than
  implying a new platform qualification.
- `a.commit` needs no change: both files already belong to groups 1 and 2, and
  the group subjects still describe their contents.

### Decision rationale for step 1 deploy-venv-sync (exchange 1) (round 1)

The staged work is close to complete and its evidence is real: I reproduced the
native harness, the isolated target acceptance and the Debian build result
independently, on the exact reviewed tree.

The disposition is changes-requested for one defect in staged code: the probe's
isolation precondition accepts an unusable loopback, so a caller's namespace
mistake is reported as a design dead end, which is the plan's own trigger to
stop the step. That is a wrong verdict at the step's most important gate, and
it is cheap to fix.

The reviewer made no repair, so nothing in the staged set is reviewer-authored.
The implementation-check result is No, with the concrete missing work recorded.
`a.commit` is mechanically valid and accurate, the umbrella digest is
unchanged, and validation produced no tracked side effect.

### Final reviewer decision for step 1 deploy-venv-sync (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-1-round-1 -->

## Round 2 by requestor - Step 1

- Recorded: 2026-09-23T14:45:25+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: request

### Review identity for step 1 deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 1
Review round: 2

### Code review evidence for step 1 deploy-venv-sync (round 2)

request_index_tree: 323cbef1b33cbc63f824784e39e237afe23e88ed
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 1 --python $DEPLOY_TEST_PYTHON --app-repo $DEPLOY_CONSUMER_ROOT (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 1 --python $DEPLOY_TOOLS_PYTHON --tools-prefix $DEPLOY_TOOLS_PREFIX --application-root $DEPLOY_APPLICATION_ROOT --manifest $DEPLOY_MANIFEST --profile $DEPLOY_PROFILE --evidence-root $DEPLOY_EVIDENCE_ROOT (sources: plan)
- consumer: ghog day (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy): verify release inputs and transport
group 1 path: src/setups/env/bin/deploy_venv_inputs.py
group 1 path: src/setups/env/bin/deploy_venv_transport.py
group 1 path: tests/unit/deploy_venv_sync/__init__.py
group 1 path: tests/unit/deploy_venv_sync/test_release_inputs/__init__.py
group 1 path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
group 1 path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py
group 2: test(deploy): qualify isolated locked wheel sync
group 2 path: src/setups/env/bin/deploy_venv_probe.py
group 2 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 2 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 2 path: tests/unit/deploy_venv_sync/test_native_probe/__init__.py
group 2 path: tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py
group 2 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
group 3: docs(deploy-venv-sync): record step 1 validation
group 3 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_inputs.py
staged path: src/setups/env/bin/deploy_venv_probe.py
staged path: src/setups/env/bin/deploy_venv_transport.py
staged path: tests/unit/deploy_venv_sync/__init__.py
staged path: tests/unit/deploy_venv_sync/test_native_probe/__init__.py
staged path: tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/__init__.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
```

### Requestor assessment for step 1 deploy-venv-sync (round 2)

Yes. Step 1 has been fully implemented.

The writer's formal check records manifest-bound native acceptance on Debian 12
and RHEL 9.8, the same original static uv 0.12.17 and shipped Python 3.13.15,
empty caches and denied remote access. File transport was attempted first;
both targets passed the approved loopback fallback under --locked --no-build
without project installation. Missing-wheel, stale-lock and incompatible-wheel
cases failed as required. After the round 1 repair, native cumulative verification passed 108 tests in 23.583 seconds,
syntax, mandatory shell lint, ShellCheck and the 650-line gate. Consumer static,
affected and full checks passed with fail=0 warn=8 xfail=8 cov=100 outliers=0.
Coverage measures only the configured application source, not these standalone
helpers. Their top-level references and unit/native exercise are documented.
No architecture, performance or existing-feature regression was identified.
Review should independently challenge the scoped completion claim.

The round 1 finding is fixed: isolation now requires a usable loopback socket,
with a distinct namespace error on bind/connect failure. Two regression tests
failed before the repair and pass afterwards; the positive test uses real local
sockets. The consumer and supported-target acceptance results predate this
precondition-only change and were not rerun, as the reviewer requested. No new
platform qualification is claimed; qualified bytes and sync behavior are unchanged.

### Implementation report for step 1 deploy-venv-sync (round 2)

Three standalone modules separate manifest/bundle integrity, structural metadata
transport and native qualification. The release record binds independent tools
and application identities without circular hashes. Extraction rejects unsafe,
duplicate, missing or unlisted members; canonical input bytes remain immutable.
The probe uses explicit delivered paths, a fresh environment/cache per command,
an allowlisted local server and retained commands/results.

Round 2 adds a loopback usability prerequisite to prevent an unusable namespace
from being mistaken for failure of both designed transports. Bind/connect errors
have a separate diagnostic, with negative tests and a real socket success case.

Two native shell entries own cumulative verification and manifest-driven target
acceptance. Unit and generated fixtures cover the principal integrity boundaries.
Mapped consumer P01-P05 changes and original uv acquisition are committed and
qualified separately; P16 is preserved and P17 is a generated fixture at this
step. Required private handoff evidence is available locally, never copied into
this public transcript. Full production assembly is Step 4, the single-build
CI sequence is Step 5, and exact-candidate lifecycle acceptance is Step 7.

### Change summary for step 1 deploy-venv-sync (round 2)

The staged 13 paths form three validated groups in root a.commit:

1. feat(deploy): verify release inputs and transport
   Includes deploy_venv_inputs.py, deploy_venv_transport.py, the release-input
   TDD/PBT files and their two package markers.
2. test(deploy): qualify isolated locked wheel sync
   Includes deploy_venv_probe.py, the native probe test and marker, both native
   shell entries and the implementation plan's four completion checkpoints.
3. docs(deploy-venv-sync): record step 1 validation
   Includes only the exact validation plan, as the trailing completion group.

All implementation paths are under src/setups/env/bin, tests/unit/deploy_venv_sync
or docs/v0.27.0 as named in the plan. The renderer captures the exact staged tree.
The review transcript generated by publication is a subsequent workflow artifact.

### Human guidance and writer response for step 1 deploy-venv-sync (round 2)

Human guidance:

Read the mandatory local integration handoff named by AGENTS.md before assessing
the consumer obligations. Keep concrete corporate names, paths, endpoints and
build identities out of public documents and review summaries.

The native commands require a real supported Linux target and explicit paths to
the shipped Python, consumer checkout and retained manifest inputs. Resolve the
DEPLOY_* command variables from the retained private invocation/evidence; do not
run ELF qualification under Git Bash. Existing final native and consumer logs
are available through that handoff. cplx has no configured Python coverage gate;
its plan uses the cumulative native harness while the consumer uses ghog day.
The mandatory project validation remains additive and unchanged.

Writer response:

Accepted the single round 1 finding without disagreement. The reviewer made no
repairs. The writer changed check_isolation to bind/listen/connect on 127.0.0.1
after confirming interface isolation and external ENETUNREACH. Any socket failure
raises "supplied namespace has no usable loopback", before a transport verdict.
Success records loopback_connect in isolation evidence. Context managers close
all sockets; connect has a two-second bound.

Added regression tests for bind failure, connect failure, and a successful real
loopback connection. Observed failures against the old code, then six focused
tests passed. Native cumulative verification passed all 108 tests plus mandatory
shell lint, ShellCheck, syntax and the 650-line check. Updated validation evidence
and counts. No remaining missing work was found in the writer's Step 1 recheck.

Following the reviewer instruction, neither platform acceptance nor consumer
groundhog was repeated for this precondition-only repair. Those results remain
the earlier qualified evidence, not new runs on the changed helper. The frozen
consumer snapshot is unchanged. No synchronization behavior or input changed.

The same thirteen staged paths and three a.commit groups remain appropriate;
only the probe, its existing test file and validation document changed this round.
All repairs are writer-owned. No reviewer edit was reversed.

### Reviewer focus for step 1 deploy-venv-sync (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-1-round-2 -->

## Round 2 by reviewer - Step 1

- Recorded: 2026-09-23T14:52:29+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: answer

### Assessed index identity for step 1 deploy-venv-sync (exchange 1) (round 2)

Baseline index tree: 323cbef1b33cbc63f824784e39e237afe23e88ed

Assessed index tree: 323cbef1b33cbc63f824784e39e237afe23e88ed

### Implementation check for step 1 deploy-venv-sync (exchange 1) (round 2)

Result:

Yes. Step 1 has been fully implemented.

The round 1 finding is fixed, and I verified the fix in both directions on the
native target rather than from the report.

- `check_isolation` now binds and connects a loopback socket after the
  interface and external-access checks, and raises a distinct error when that
  fails. The control-flow restructure keeps the original refusal when external
  access is not denied, using an `else` branch on the connect attempt.
- Negative direction: the exact case that produced "both designed transports
  failed; design review required" in round 1, a namespace whose loopback is
  down, now stops with "supplied namespace has no usable loopback" and exit 2,
  before any transport attempt.
- Positive direction: with loopback up, the acceptance probe passes in 9.2
  seconds over the loopback transport, and the evidence record carries
  `loopback_connect: true` beside the external errno.
- The two new tests cover bind and connect failure through mocks, and the
  success path through real local sockets.

Re-verified for this round against the reviewed tree
`323cbef1b33cbc63f824784e39e237afe23e88ed`:

- native cumulative harness on RHEL 9.8: exit 0, 108 tests (106 plus the two
  new ones), syntax, mandatory Bash lint, ShellCheck and the 650-line scan;
- manifest-bound acceptance probe on RHEL in an isolated namespace: state
  `passed`, same uv `42949aef...` and toolchain `df7dff7d...` digests,
  `packaging 25.0` installed, negatives at exit 1, 1 and 2;
- local lint floor, ShellCheck at style severity, and `git diff --cached --check`.

The validation plan records the repair honestly: it states that the platform
and consumer results predate this precondition-only change and were not rerun,
and claims no fresh platform qualification. That matches what I observed, and
my rerun of both entries on the repaired tree shows the result unchanged.
Physical line counts are updated (probe 315, probe tests 99).

Architecture: unchanged from round 1. Three standalone helpers with separate
responsibilities, loaded by path, no new package or class hierarchy, isolated
imports handled explicitly. Nothing needs to be addressed.

Performance: the added precondition is one local bind and connect with a
2 second timeout, run once per probe. No performance issue needs to be addressed.

Unit test coverage: cplx has no configured coverage gate, so no percentage is
claimed. Every top-level function in the three modules is referenced by the unit
tests or the native entries, including the repaired precondition. No unit-tested
class is below 100%, and no changed top-level symbol outside a coverage gate is
unreferenced.

Validation plan effects:

The reviewer made no edit to the validation plan. The Step 1 rows were checked
against reproduced evidence and are accurate, including the explicit note that
the platform results predate the precondition-only repair.

### Pre-repair mandatory checks and coverage for step 1 deploy-venv-sync (exchange 1) (round 2)

All mandatory validation ran, and the reviewer made no repair.

- `bash src/utils/lint_shell.sh`: exit 0, clean. Direct ShellCheck at style
  severity on both native scripts: exit 0.
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 1` on native RHEL 9.8,
  against the reviewed index tree shipped as a fresh archive: exit 0, 108
  tests, syntax, lint, ShellCheck and the 650-line scan.
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 1` on native RHEL
  9.8 in an isolated namespace with the retained manifest, profile and
  application root: exit 0, state `passed`, transport `loopback`, elapsed
  9.203 seconds, `loopback_connect: true`, negatives at exit 1, 1 and 2.
- The same acceptance entry in a namespace with loopback down: exit 2 with
  "supplied namespace has no usable loopback", which is the repaired behavior.
- `git diff --cached --check`: exit 0.
- The consumer walk was not rerun by the reviewer. This round changes only cplx
  helper preconditions and touches no consumer file.

### Resolved validation set and sources for step 1 deploy-venv-sync (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 1 --python $DEPLOY_TEST_PYTHON --app-repo $DEPLOY_CONSUMER_ROOT` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 1 --python $DEPLOY_TOOLS_PYTHON --tools-prefix $DEPLOY_TOOLS_PREFIX --application-root $DEPLOY_APPLICATION_ROOT --manifest $DEPLOY_MANIFEST --profile $DEPLOY_PROFILE --evidence-root $DEPLOY_EVIDENCE_ROOT` (source: plan).
- `consumer: ghog day` (source: plan); the recorded result stands and no consumer file changed this round.

### Resolver drift and direction for step 1 deploy-venv-sync (exchange 1) (round 2)

No drift. The current resolver set equals the request set.

### Repository state around validation for step 1 deploy-venv-sync (exchange 1) (round 2)

The index tree was `323cbef1b33cbc63f824784e39e237afe23e88ed` at request time,
at review entry and after the assessment. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison over all thirteen staged paths
is acceptable, with no tracked, untracked or ignored differences. The only
unstaged change is the protocol transcript.

### Repair inventory for step 1 deploy-venv-sync (exchange 1) (round 2)

Repairs made:

- None. The reviewer made no repair and staged nothing this round.

Paths staged:

- - `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md`
- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- - `docs/v0.27.0/verify.deploy-venv-sync.sh`
- - `src/setups/env/bin/deploy_venv_inputs.py`
- - `src/setups/env/bin/deploy_venv_probe.py`
- - `src/setups/env/bin/deploy_venv_transport.py`
- - `tests/unit/deploy_venv_sync/__init__.py`
- - `tests/unit/deploy_venv_sync/test_native_probe/__init__.py`
- - `tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py`
- - `tests/unit/deploy_venv_sync/test_release_inputs/__init__.py`
- - `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py`
- - `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`

### Commit plan assessment for step 1 deploy-venv-sync (exchange 1) (round 2)

The independent `commit-plan-check.bat --format json` run returned state
`valid`, `ready: true` and no diagnostics for all thirteen staged paths in three
ordered groups: the modules with their tests, then the probe with the native
entries and the plan checkpoints, then the validation plan alone. The round 2
repair touched two files already inside group 2, so membership, order and the
conventional subjects still match the staged work. `a.commit` remains accurate;
the reviewer did not amend it.

### Findings and boundaries for step 1 deploy-venv-sync (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Human guidance response for step 1 deploy-venv-sync (exchange 1) (round 2)

Human guidance:

Read the mandatory local integration handoff named by AGENTS.md before assessing
the consumer obligations. Keep concrete corporate names, paths, endpoints and
build identities out of public documents and review summaries.
The native commands require a real supported Linux target and explicit paths to
the shipped Python, consumer checkout and retained manifest inputs. Resolve the
DEPLOY_* command variables from the retained private invocation/evidence; do not
run ELF qualification under Git Bash. Existing final native and consumer logs
are available through that handoff. cplx has no configured Python coverage gate;
its plan uses the cumulative native harness while the consumer uses ghog day.
The mandatory project validation remains additive and unchanged.

Guidance response:

The guidance was followed again this round. The private integration handoff was
read before assessing the consumer obligations, and no private name, path,
endpoint or build identity appears here. The DEPLOY_* values came from the
retained private invocation and evidence, every native check ran on the Linux
target and never under Git Bash, and the project validation floor ran unchanged.

### Writer instructions for step 1 deploy-venv-sync (exchange 1) (round 2)

No rework is required. If the human selects Commit, stage this protocol append
with the final group as the workflow prescribes, then run the installed hook and
the commit-plan checker once more against the final index before committing.

### Decision rationale for step 1 deploy-venv-sync (exchange 1) (round 2)

All six readiness-floor results pass: exact identity, complete implementation,
mandatory validation rerun independently on the native target for this tree,
attributable staged scope with no reviewer repair, no unresolved finding, and an
accurate `a.commit`. The round 1 finding is fixed, and I confirmed both its
failure and success paths on the real target. The recommendation is
commit-ready. It is advisory and does not authorize a commit.

One scope note for the human, not a finding: the Debian build and the consumer
walk recorded for this step predate the precondition-only repair, and both the
writer and this answer say so plainly. My rerun of the native harness and the
target acceptance on the repaired tree shows the qualified transport result
unchanged.

### Final reviewer decision for step 1 deploy-venv-sync (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-1-round-2 -->

## Round 2 by human - Step 1 - human-confirmation

- Recorded: 2026-09-23T15:07:04+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 1 by requestor - Step 2

- Recorded: 2026-09-23T19:50:10+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 2
- Outcome: request

### Review identity for step 2 deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 2
Review round: 1

### Code review evidence for step 2 deploy-venv-sync (round 1)

request_index_tree: 53ed76c3ec8edb601726280cd060de7594e010fa
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 2 --python <selected-python> --app-repo <consumer-root> (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 2 --tools-prefix <tools> --application-root <app> --manifest <manifest> --profile <profile> --selection-profile <selection-profile> --evidence-root <evidence> --python <selected-python> --installed-root <site-packages> --wheel-dir <wheels> --venv-root <venv> (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy-venv-sync): verify selected wheels
group 1 path: src/setups/env/bin/deploy_venv_selection.py
group 1 path: src/setups/env/bin/tools_wheel_inventory.py
group 2: test(deploy-venv-sync): cover selection drift
group 2 path: tests/unit/deploy_venv_sync/test_selection_integrity/__init__.py
group 2 path: tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_pbt.py
group 2 path: tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_tdd.py
group 2 path: tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py
group 2 path: tests/unit/tools_release_transport/test_tools_release_transport/test_tools_release_transport_tdd.py
group 3: build(deploy-venv-sync): run selection checks
group 3 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 3 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 4: docs(deploy-venv-sync): record step 2 validation
group 4 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_selection.py
staged path: src/setups/env/bin/tools_wheel_inventory.py
staged path: tests/unit/deploy_venv_sync/test_selection_integrity/__init__.py
staged path: tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_pbt.py
staged path: tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_tdd.py
staged path: tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py
staged path: tests/unit/tools_release_transport/test_tools_release_transport/test_tools_release_transport_tdd.py
```

### Requestor assessment for step 2 deploy-venv-sync (round 1)

Step 2 is fully implemented according to the writer check in the validation
plan. The new qualified selection helper binds lock, project, target markers,
groups, extras, wheel tags, wheel hashes and exact installed distributions.
The opt-in inventory compares ELF subjects in site-packages and bin while
preserving schema 1 clients. The native cumulative harness passed syntax,
ShellCheck, D10 compatibility and all unit tests on the target platform.
Native acceptance passed a retained wheel fixture; the consuming application
passed its full CI test and coverage run. The cplx local groundhog walk passed
tests but lacks a configured coverage TOTAL line; the plan names the native
cumulative harness as its equivalent. The consuming application's duration-only
groundhog exception was accepted for Step 2 only. No architecture or performance
issue was found. No production class was added, and every new helper symbol is
referenced by tests or within its module.

### Implementation report for step 2 deploy-venv-sync (round 1)

The staged change adds deploy_venv_selection.py and extends
tools_wheel_inventory.py with schema 2. It adds a native Step 2 acceptance path,
extends cumulative verification, and adds fixed and generated drift tests.
Two inherited Linux shell-path integration classes skip on Windows but still
run on native Linux. The validation plan now records a Yes verdict for Step 2;
later steps remain pending.

### Change summary for step 2 deploy-venv-sync (round 1)

Ten paths are staged. The ready root a.commit groups them as follows:

1. Selection and inventory implementation: two production helpers.
2. Tests: three new selection files and two Linux platform guards.
3. Native entry points: acceptance and cumulative verifier scripts.
4. Validation: the Step 2 validation-plan update.

The final group uses the required subject
`docs(deploy-venv-sync): record step 2 validation`. The commit-plan checker
reported ready with no diagnostics. No commits have been made.

### Writer response for step 2 deploy-venv-sync (round 1)

Writer response:

This is the first Step 2 implementation review round. There is no earlier
review feedback to accept or dispute.

### Reviewer focus for step 2 deploy-venv-sync (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-2-round-1 -->

## Round 1 by reviewer - Step 2

- Recorded: 2026-09-23T20:00:54+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: answer

### Assessed index identity for step 2 deploy-venv-sync (exchange 1) (round 1)

Baseline index tree: 53ed76c3ec8edb601726280cd060de7594e010fa

Assessed index tree: 53ed76c3ec8edb601726280cd060de7594e010fa

### Implementation check for step 2 deploy-venv-sync (exchange 1) (round 1)

Result:

Yes. Step 2 has been fully implemented.

I reproduced the step's evidence on the native target with the exact reviewed
tree `53ed76c3ec8edb601726280cd060de7594e010fa`, and exercised the new
acceptance path myself rather than reading its retained result.

- **Cumulative harness at `--step 2` on RHEL 9.8**: exit 0, 76 focused and 157
  all-unit tests, the D10 compatibility regression, the mandatory Bash lint
  floor, ShellCheck, syntax and the 650-line scan.
- **New Step 2 acceptance branch**, run with the retained release bundle, the
  writer's selection profile and a venv produced by my own Step 1 probe: exit 0,
  and the emitted selection record carries the same lock, project, profile,
  toolchain and wheel-manifest digests as the writer's retained result.
- **Drift is rejected on the real path, not only in unit tests.** Pointing the
  same command at two venvs that lack the selected distribution ends in exit 5
  with "installed distribution selection mismatch", and the acceptance script
  fails with it.
- **Step 1 remains green under the modified scripts**: the Step 1 acceptance
  probe still passes (state passed, loopback, negatives at exit 1, 1 and 2).

The selection helper binds the qualified profile to the canonical lock and
project digests, resolves markers, groups and extras through its own closure
walk, checks wheel tags, filenames and hashes against the lock, compares the
retained original wheels by digest, and finally requires the chosen set to equal
both the lock closure and the installed distributions. The inventory extension
adds opt-in schema 2 for wheel ELF subjects in site-packages and `bin` while
keeping the schema 1 interface, and its capture and describe paths still pass
the inherited regression.

Two points the human should see at the gate, both disclosed by the writer and
verified by me rather than open findings:

- **The staged set exceeds the plan's declared Step 2 file list by two files**,
  the inherited publication and transport test classes, which now skip outside
  native Linux. I verified the guards do not weaken the qualified platform: the
  RHEL run reports zero skipped tests, and those two classes contribute 23
  passing tests there. The validation plan and the commit grouping both name
  this change.
- **The consumer walk carries a duration-only exception for this step**, which
  the validation plan records as accepted for Step 2 only. That is a recorded
  human decision, not a reviewer judgement, and it is stated rather than hidden.

Architecture: the selection helper and the inventory extension stay separate
command-line helpers bound by JSON identities, with no new production class and
no layer violation. Nothing needs to be addressed.

Performance: selection builds identity maps and walks installed distributions
once; inventory capture walks site-packages and `bin` once each. The marker
evaluator visits each parsed node once. No quadratic scan. No performance issue
needs to be addressed.

Unit test coverage: cplx has no configured coverage gate, so no percentage is
claimed; the native cumulative harness is the repository equivalent, as the plan
states. Every top-level symbol in the new module and the inventory extension is
referenced by the new fixed and generated tests or within its module. No
unit-tested class is below 100%, and no changed top-level symbol outside a
coverage gate is unreferenced.

Validation plan effects:

The reviewer made no edit to the validation plan. Its Step 2 rows were checked
against reproduced evidence and are accurate, including the recorded scope of
the consumer walk exception and the platform guards.

### Pre-repair mandatory checks and coverage for step 2 deploy-venv-sync (exchange 1) (round 1)

All mandatory validation ran, and the reviewer made no repair.

- `bash src/utils/lint_shell.sh`: exit 0, clean, locally and inside the native
  harness.
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 2 --python <toolchain
  3.13.15> --app-repo <consumer checkout>` on native RHEL 9.8, against the
  reviewed index tree shipped as a fresh archive: exit 0, 76 focused and 157
  all-unit tests, the D10 compatibility regression with the shipped compiler
  wrapper, ShellCheck, syntax and the 650-line scan.
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 2` on native RHEL
  9.8 with the retained bundle, selection profile, wheel directory, and the
  installed root and venv from my own Step 1 probe: exit 0, with a selection
  record whose digests match the writer's retained result.
- Negative runs of the same command against two venvs lacking the selected
  distribution: exit 5, "installed distribution selection mismatch".
- Step 1 acceptance probe on the same tree, as a regression: exit 0, state
  passed, transport loopback.
- `git diff --cached --check`: exit 0.
- The consumer walk was not rerun by the reviewer. Its recorded result, and the
  duration-only exception accepted for this step, are the writer's and the
  human's respectively.

### Resolved validation set and sources for step 2 deploy-venv-sync (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 2 --python <selected-python> --app-repo <consumer-root>` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 2 ...` with selection profile, installed root, wheel dir and venv root (source: plan).
- `consumer: ghog day` (source: plan); recorded by the writer, with the duration-only exception accepted for this step.

### Resolver drift and direction for step 2 deploy-venv-sync (exchange 1) (round 1)

No drift. The current resolver set equals the request set. Three of the four
commands ran under the reviewer; the consumer walk is the recorded result.

### Repository state around validation for step 2 deploy-venv-sync (exchange 1) (round 1)

The index tree was `53ed76c3ec8edb601726280cd060de7594e010fa` at request time,
at review entry and after the assessment. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison over all ten staged paths is
acceptable, with no tracked, untracked or ignored differences. The only
unstaged change is the protocol transcript.

### Repair inventory for step 2 deploy-venv-sync (exchange 1) (round 1)

Repairs made:

- None. The reviewer made no repair and staged nothing.

Paths staged:

- - `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- - `docs/v0.27.0/verify.deploy-venv-sync.sh`
- - `src/setups/env/bin/deploy_venv_selection.py`
- - `src/setups/env/bin/tools_wheel_inventory.py`
- - `tests/unit/deploy_venv_sync/test_selection_integrity/__init__.py`
- - `tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_pbt.py`
- - `tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_tdd.py`
- - `tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py`
- - `tests/unit/tools_release_transport/test_tools_release_transport/test_tools_release_transport_tdd.py`

### Commit plan assessment for step 2 deploy-venv-sync (exchange 1) (round 1)

The independent `commit-plan-check.bat --format json` run returned state
`valid`, `ready: true` and no diagnostics for all ten staged paths in four
ordered groups: the two production helpers, then the tests including the two
platform guards, then the native entry points, then the validation plan alone
with the required subject. Each group depends only on the ones before it, and
the subjects match the staged content. `a.commit` remains accurate; the reviewer
did not amend it.

### Findings and boundaries for step 2 deploy-venv-sync (exchange 1) (round 1)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 2 deploy-venv-sync (exchange 1) (round 1)

No rework is required. If the human selects Commit, stage this protocol append
with the final group as the workflow prescribes, then run the installed hook and
the commit-plan checker once more against the final index before committing.

### Decision rationale for step 2 deploy-venv-sync (exchange 1) (round 1)

All six readiness-floor results pass: exact identity, complete implementation,
mandatory validation rerun independently on the native target, attributable
staged scope with no reviewer repair, no unresolved finding, and an accurate
`a.commit`. I exercised the new acceptance path and its rejection path myself
and obtained the same identities as the retained evidence. The recommendation is
commit-ready. It is advisory and does not authorize a commit.

Two notes for the human at the gate, neither an open finding:

- The staged set includes two inherited test files outside the plan's declared
  Step 2 list, now skipping outside native Linux. The qualified platform is
  unaffected: zero tests skip on RHEL and those classes contribute 23 passing
  tests there. The validation plan and the commit grouping disclose it.
- The new helper reports every refusal as "Selection INCONCLUSIVE" with exit 5,
  including a detected drift. That follows the inherited wheel-inventory
  helper's own convention, so it is consistent rather than wrong, but the word
  means something narrower elsewhere in this effort, where an inconclusive
  observation is distinct from a rejection. Worth aligning when the acceptance
  cells of a later step read these results.

### Final reviewer decision for step 2 deploy-venv-sync (exchange 1) (round 1)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-2-round-1 -->

## Round 1 by human - Step 2 - human-confirmation

- Recorded: 2026-09-23T20:18:32+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-1 -->
