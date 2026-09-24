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

## Round 1 by requestor - Step 3

- Recorded: 2026-09-24T17:08:18+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 3
- Outcome: request

### Review identity for step 3 deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 3
Review round: 1

### Code review evidence for step 3 deploy-venv-sync (round 1)

request_index_tree: a9c1054104b5e5fc42bcfc99f421a65376b5a2be
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 3 --python /absolute/shipped/python --app-repo /absolute/consumer (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 3 with absolute delivered inputs and consumer serialization attestation (sources: plan)
- consumer ghog day --force (sources: plan)
- Debian 12 full-mode consumer build with publication off (sources: plan)
- shellcheck edited shell scripts through each project senv.bat (sources: request)
- git diff --cached --check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy-venv-sync): reconstruct exact venv
group 1 path: src/setups/env/bin/deploy_venv.sh
group 2: test(deploy-venv-sync): cover venv lifecycle
group 2 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 2 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 2 path: tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py
group 2 path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py
group 3: docs(deploy-venv-sync): record step 3 validation
group 3 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv.sh
staged path: tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py
staged path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py
```

### Requestor assessment for step 3 deploy-venv-sync (round 1)

Step 3 verdict: fully implemented. The six staged cplx paths match the plan's
Step 3 list. P01/P07 consumer changes are committed separately in the consumer.

Static and local checks: ShellCheck passed for every edited shell script with
each project's `senv.bat`; the cplx native unit fixture passed 11 cases. The
cplx `ghog day` walk passed 168 tests but exited 5 because this repository has
no configured coverage-total line. The plan specifies the cumulative native
Linux harness as the cplx equivalent, and it passed on the RHEL 9.8 target.
The consumer `ghog day --force` exited 0: 6,546 tests, 100% configured
application-source coverage, no duration outliers or exclusions. That coverage
gate measures its application source, not cplx shell code or consumer P01/P07.

Target and agent checks: RHEL cumulative verify `--step 3` passed 87 focused
and 168 total unit cases; Step 3 acceptance passed with shipped Python, a
foreign activation, wrong host Python and PATH helper decoys. The P07 companion
and legacy no-record paths both passed with exact `VENV`, lock and readiness
checks. Debian 12 agent build 198 passed Provision, Package and Test with
publication skipped; acceptance reported 100% configured source coverage.
Detailed commands, candidate identities, intermediate failures and artifacts
are retained privately under AC13.

Five review points settled before target execution:

1. P01 gets the full version from the shipped interpreter. P07 consumes the
   helper's exact `VENV=` result, validates it, and does not derive another
   directory name. There is one venv name source.
2. P01 and P07 parse the same ten-key release record at distinct integrity
   boundaries. Comments explain the reread, and both grammars accept the same
   key and version forms while rejecting disagreement.
3. The record-backed path omits Git restoration by Step 3 item 6 of the plan
   and the design's "Packaging and recovery boundaries" section: verified
   delivered metadata is used directly. The legacy no-record path retains
   tracked-content restoration and clean-repository readiness; both ran on
   the RHEL 9.8 target.
4. P01's two original ShellCheck `source=` directives were restored. Lint
   passes from the consumer root after its `senv.bat` setup.
5. The staged cplx paths are only the Step 3 public file list. Consumer
   changes are only P01/P07 and a byte-identical delivery snapshot needed
   for the agent run. No P10/P11 change or extra lifecycle helper is in this
   batch.

Architecture: deployment ownership and serialization remain in the consumer;
the cplx entry performs the venv lifecycle through existing input, selection,
transport and inventory helpers. No domain-layer dependency was added.
Performance: explicit release inputs and one exact target avoid recency scans;
necessary record rereads occur at distinct boundaries. No new quadratic
path was found. Feature integrity: the historical no-record path and
directory/artifact contracts passed named target checks. No new production
class was introduced. The 183-line unit fixture remains below the Python
line ceiling.

### Implementation report for step 3 deploy-venv-sync (round 1)

`deploy_venv.sh` selects the actual shipped Python from the verified tools
prefix, computes the full-version venv name, and validates an existing target's
base executable, prefix and version. It refuses a foreign or escaping target,
uses the verified local release inputs and absolute uv for locked wheel-only
sync, disables ambient Python and uv selection, and writes operation-bound
readiness or first-failure evidence.

The consumer P01 path replaces recency selection with the helper result. P07
verifies the record and delivered bundle, holds a stable root lock through
archive mirroring and reconstruction, uses the exact returned `VENV`, and
retains historical recovery when no release record is present. The native
verifier, acceptance mode and 11 new unit cases exercise the lifecycle.

### Change summary for step 3 deploy-venv-sync (round 1)

Staged cplx paths (root `a.commit` covers all six):

- `src/setups/env/bin/deploy_venv.sh` — exact-path lifecycle entry.
- `docs/v0.27.0/verify.deploy-venv-sync.sh` — cumulative Step 3 verifier.
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh` — Step 3 target acceptance.
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py` and
  `test_venv_lifecycle_tdd.py` — native unit fixture.
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` — checked
  Step 3 verdict and sanitized evidence.

The checked commit plan has three ordered groups: lifecycle feature, native
test/entry coverage, and the final exact-title Step 3 validation group.
`git diff --cached --check` and the read-only commit-plan checker passed.
Consumer P01/P07 changes and the agent delivery snapshot were committed in
the consumer repository; unrelated consumer working files were excluded.

### Writer response for step 3 deploy-venv-sync (round 1)

Writer response:

Round 1 has no earlier reviewer findings. The writer requests an independent
assessment of the exact staged Step 3 implementation and the named host gates.

Plan update since the Step 2 review: commits 9981c52 and 17fb93b add
Step 3b to the plan and its validation skeleton, requested by the human on
2026-09-24 before Step 3 started.

- Step 3b moves Step 5's existing non-qualifying actual-agent probe of the
  mandated pipeline earlier. It adds no design decision and changes no
  acceptance row. Completion criteria of Steps 3 and 4 are unchanged; Step 5
  item 2 now starts from Step 3b's results.
- Step 3's reviewed scope is unchanged: its public files plus P01/P07.
  P10/P11 changes are not in this batch, and their absence is not a finding.
  Step 3b work is reviewed under its own step.
- 17fb93b's title "record step 2 validation" was imposed by a commit-plan
  checker defect, since fixed in the shared tooling. Its content only adds
  the Step 3b skeleton; the Step 2 verdict is unchanged.
- Step 3's Debian and RHEL runs and Step 3b's mechanics are kept in private
  records by design (AC13). Public validation entries are sanitized outcomes.

### Reviewer focus for step 3 deploy-venv-sync (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-3-round-1 -->

## Round 1 by reviewer - Step 3

- Recorded: 2026-09-24T17:45:11+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: answer

### Assessed index identity for step 3 deploy-venv-sync (exchange 1) (round 1)

Baseline index tree: a9c1054104b5e5fc42bcfc99f421a65376b5a2be

Assessed index tree: 6af9ebd2f5f976f405efc3fab67849f4dd439263

### Implementation check for step 3 deploy-venv-sync (exchange 1) (round 1)

Result:

No. Step 3 has NOT been fully implemented.

The exact-path lifecycle and the consumer P01/P07 wiring are in place. The
post-sync shebang check, though, rejects any wheel console script in a uv venv,
and no run reached that branch. The plan's tests-first state matrix is also
only partly covered.

Evidence I checked: the exact plan Step 3 and its addendums, the design's
"Environment identity and synchronization" table and readiness paragraph, the
full staged diff of the six paths, `a.commit`, the imported helper signatures
(`deploy_venv_inputs`, `deploy_venv_probe`, `deploy_venv_selection.verify`,
`deploy_venv_transport`, `tools_wheel_inventory.capture`), the consumer
`runtime_env.sh` definition of `pdfss_runtime_run`, and the retained RHEL and
Debian evidence under the ignored `a.deploy-step3-*` directories.

- **Shebang containment (blocking).** `interpreter_state` resolves each
  script's shebang interpreter, then requires it to lie under the target.
  uv creates `bin/python` as a symlink to the shipped base interpreter, and
  console scripts get a `#!<venv>/bin/python` shebang, so the resolved path
  always leaves the venv. The check then raises "venv script has a foreign
  Python shebang" on the first entry point. The pre-sync call hits the same
  check whenever an existing venv is reused. The retained evidence confirms
  the gap: all five ready operations (acceptance and four P07 runs) installed
  only `packaging==25.0` (distributions=1), which has no console script. The
  Debian 12 build 198 console log never invokes `deploy_venv.sh`. A secondary
  defect: the target side of the comparison is not resolved, so a symlinked
  ancestor of the application root would also fail.
- **Tests-first matrix (blocking).** The 11 unit cases cover naming, suffix
  escape, target symlink and foreign base, prefix and version, selection flags,
  environment sanitizing, command logs, readiness revocation and the lock
  attestation. They do not reach `interpreter_state`, `preflight`,
  `prepare_sources`, `finish_checks`, the success path of `operate`, or the
  Bash shipped-Python selection. The plan asks for a finite state matrix
  covering stale lock, missing wheels, interruption, failed post-sync checks,
  changed toolchain at equal version, and repeated or mirror-removed targets.
  Only two negative target runs are retained: an unheld lock and metadata
  drift. The validation text claimed coverage of "runtime selection, changed
  toolchains, missing inputs" that the fixture does not contain; I corrected
  those rows.
- **Readiness record overwrite (minor).** `pdfss_runtime_run` returns
  Python's status instead of `exec`ing, so under `set -e` the Bash `EXIT` trap
  runs after every lifecycle failure. It then replaces the operation-bound
  not-ready record with `{"operation":"entry-preflight"}`, which cuts
  `readiness.json` loose from the `result.json` holding the first failure.
- **Log collision (minor).** Both `interpreter_state` calls log under
  `venv-state`, so the post-sync log overwrites the pre-sync one while
  `record["commands"]` lists the same file twice.
- **Uncaught corrupt wheel (minor).** `operate` does not catch
  `zipfile.BadZipFile` from `tools_wheel_inventory.capture`. The result then
  has no `error` field and a traceback replaces the diagnostic.
  `tools_wheel_inventory.main` already catches it.

Architecture: no DDD-Hexagonal violation. The consumer keeps lock and archive
ownership; the entry delegates selection, transport and inventory to the
existing helpers and adds no domain dependency. No architecture fix is needed.

Performance: explicit inputs, one computed path, and rereads at integrity
boundaries only. No quadratic or sorting-driven discovery was introduced. No
performance fix is needed.

Unit test coverage: cplx has no configured coverage gate, and the consumer's
100% gate measures only its own application source. Statically, every
top-level function is referenced from the fixture or from `operate`, so no
symbol is unreferenced. Branch coverage of the embedded lifecycle is
incomplete, as listed above.

Feature integrity: the record-backed path's omission of Git restoration
follows Step 3 item 6 and the design, and the legacy no-record path ran on RHEL.
No existing feature is impaired by the staged change.

Validation plan effects:

The reviewer edited only the Step 3 rows of
`docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`. The status sentence
now reads `No. Step 3 has NOT been fully implemented.` with its summary. A
`Missing work for Step 3` section follows `What was implemented for Step 3`.
The unit test coverage row now names the cases the fixture actually has and
the functions it does not reach. The Yes-only `Analysis of Step 3
Implementation` section is removed. The document-level status line was already
`No, it is not implemented.` and is unchanged. No other step's rows and no
umbrella row were touched.

### Pre-repair mandatory checks and coverage for step 3 deploy-venv-sync (exchange 1) (round 1)

The resolved validation set is requestor evidence, and the reviewer did not
rerun it. Reviewer evidence commands, each run once from the project root:

- `ghog check` (runs `check.bat`, the shell lint gate): exit 0, `lint_shell:
  59 tracked scripts`, clean. This includes the staged `deploy_venv.sh`.
- `ghog affected --no-cov`: exit 9, not applicable. cplx is not a pytest
  project, so the focused pytest step does not apply. This is not a red result.
- `git diff --cached --check`: exit 0 before and after the reviewer patch.

The reviewer also read the retained target evidence. The RHEL acceptance and
P07 operations report `distributions=1` and install only `packaging==25.0`.
The Debian 12 build 198 console log contains no `deploy_venv.sh` invocation.

### Resolved validation set and sources for step 3 deploy-venv-sync (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 3 --python /absolute/shipped/python --app-repo /absolute/consumer` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 3` with absolute delivered inputs and consumer serialization attestation (source: plan).
- `consumer ghog day --force` (source: plan).
- `Debian 12 full-mode consumer build with publication off` (source: plan, as labeled by the request).
- `shellcheck edited shell scripts through each project senv.bat` (source: request).
- `git diff --cached --check` (source: request).

### Resolver drift and direction for step 3 deploy-venv-sync (exchange 1) (round 1)

One entry drifts, in the additive direction. The request labels "Debian 12
full-mode consumer build with publication off" as sourced from the plan, but
Step 3 of the plan names only the cumulative harness `--step 3`, the matching
acceptance mode and the consumer `ghog day` walk; the plan text has no
full-mode build entry. The project floor (`bash src/utils/lint_shell.sh`) and
the three Step 3 plan commands match. The two request additions are additive
and subtract nothing. Requestor action: source the Debian entry as a request
addition, or cite the plan line that adds it. Build 198 also did not execute
the lifecycle entry, so it is not Step 3 lifecycle evidence.

### Repository state around validation for step 3 deploy-venv-sync (exchange 1) (round 1)

The index tree was `a9c1054104b5e5fc42bcfc99f421a65376b5a2be` at request time
and at review entry. After the reviewer's validation-plan patch it is
`6af9ebd2f5f976f405efc3fab67849f4dd439263`. The umbrella digest is unchanged
(`46b95d18...`, `changed: false`). The validation-state comparison reports one
tracked difference, the validation plan, confined to the Step 3 rows and
attributed to the reviewer. It reports no untracked and no ignored difference.
The only unstaged change is the protocol transcript.

### Repair inventory for step 3 deploy-venv-sync (exchange 1) (round 1)

Repairs made:

- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: Step 3 rows
- updated to the reviewer's No verdict, with a Missing work list and a
- corrected unit coverage row. The patch was attributed cleanly and staged.
- Classification: polishing-only review metadata. It changes no code, test,
- acceptance behavior or commit grouping.
- No implementation code or test was modified.

Paths staged:

- - `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- - `docs/v0.27.0/verify.deploy-venv-sync.sh`
- - `src/setups/env/bin/deploy_venv.sh`
- - `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py`
- - `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py`

### Commit plan assessment for step 3 deploy-venv-sync (exchange 1) (round 1)

The independent `commit-plan-check.bat --format json` run returned state
`valid`, `ready: true` and no diagnostics, both before and after the reviewer
patch. It found all six staged paths in three ordered groups: the lifecycle
entry, then the verifier, acceptance and unit fixture, then the validation plan
alone with the required subject. Membership, order and subjects remain
accurate, and the reviewer did not amend `a.commit`. After rework, refresh the
third group's body: it still says the record "reports the completed step".

### Findings and boundaries for step 3 deploy-venv-sync (exchange 1) (round 1)

Unresolved findings:

- 1. High: `interpreter_state` in `src/setups/env/bin/deploy_venv.sh` resolves
- the shebang interpreter through the venv's `bin/python` symlink, so every
- wheel console script is reported as a foreign Python shebang. No retained
- run installed a console script.
- 2. Medium: the plan's tests-first finite state matrix is only partly
- implemented. `interpreter_state`, `preflight`, the success path and the Bash
- shipped-Python selection have no unit case, and stale lock, missing wheel,
- interruption, failed post-sync check, changed toolchain and
- repeated or mirror-removed target rows have neither unit nor retained target
- evidence.
- 3. Low: the Bash `EXIT` trap overwrites the operation-bound not-ready record
- after every lifecycle failure.
- 4. Low: the two `interpreter_state` calls share the `venv-state` log label.
- 5. Low: `operate` does not catch `zipfile.BadZipFile`.

Boundary-crossing work: None.

### Writer instructions for step 3 deploy-venv-sync (exchange 1) (round 1)

1. In `interpreter_state`, test the lexical absolute shebang path, not its
   resolution. Accept only `<target>/bin/<name>` with `target` resolved once,
   and use the same resolved form for the `site` and shebang comparisons.
2. Add `interpreter_state` unit cases with the command runner stubbed: a
   venv-shaped fixture with `bin/python` symlinked to a stand-in base and a
   console script shebang `#!<venv>/bin/python` passes; a foreign shebang, a
   foreign `pyvenv.cfg` home and a stdlib outside the base prefix each fail.
3. Implement the plan's finite state matrix, as unit rows with a stubbed
   runner or as named retained target runs: stale lock, missing wheel,
   interrupted sync, failed post-sync check, changed toolchain at equal Python
   version, repeated and mirror-removed targets, venv parent escape, and the
   `preflight` shipped-Python branches (zero or several candidates, directory
   version mismatch, running interpreter differs, unbound profile, metadata
   drift).
4. Re-run the Step 3 RHEL acceptance and the P07 companion path with a
   selection that installs at least one wheel entry point, including a
   repeated run over the existing venv, and record the distribution count.
5. Make the Bash `EXIT` trap write its generic record only when the embedded
   lifecycle never started, for example by clearing the trap just before
   `pdfss_runtime_run`.
6. Give the two `interpreter_state` calls distinct log labels.
7. Add `zipfile.BadZipFile` to the exceptions `operate` records.
8. Re-run implementation-check so the Step 3 rows return to Yes only when the
   Missing work list is done, then refresh the third `a.commit` body.

### Decision rationale for step 3 deploy-venv-sync (exchange 1) (round 1)

The readiness floor does not pass. Exact identity passes: envelope, request
fields, plan, step, round and request-time index tree all agree. Staged
attribution passes: the only reviewer change is attributable review metadata.
`a.commit` passes the mechanical check. Implementation completeness fails on
the shebang defect and the partial tests-first matrix. Validation and coverage
fail because the static assessment finds untested lifecycle branches, and the
only real runs used a one-distribution selection that could not reach the
defect. Five findings remain unresolved. The disposition is
changes-requested.

The shebang finding is static. I did not run a target reproduction, because a
reviewer runs only `ghog check` and `ghog affected --no-cov`. It rests on uv
creating `bin/python` as a symlink to the base interpreter on Linux, and on the
retained evidence showing no console script was ever installed. The first
writer instruction's unit case settles it either way.

Not raised as a finding: `operate` revokes readiness before it checks the
serialization attestation. The fixture asserts that order on purpose, and it
fails closed. An unserialized caller can still clobber a concurrent holder's
readiness record, though, so the writer may want to state that choice in the
design's readiness paragraph.

### Final reviewer decision for step 3 deploy-venv-sync (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-3-round-1 -->

## Round 2 by requestor - Step 3

- Recorded: 2026-09-24T19:50:07+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: request

### Review identity for step 3 deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 3
Review round: 2

### Code review evidence for step 3 deploy-venv-sync (round 2)

request_index_tree: 27750f3da765d0232ae0dd254fb5d89248575066
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project, plan)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 3 --python /absolute/shipped/python --app-repo /absolute/consumer (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 3 with absolute delivered inputs and consumer serialization attestation (sources: plan)
- consumer ghog day --force (sources: plan)
- Debian 12 full-mode consumer build with publication off (sources: request)
- shellcheck edited shell scripts through cplx senv.bat (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy-venv-sync): reconstruct exact venv
group 1 path: src/setups/env/bin/deploy_venv.sh
group 2: test(deploy-venv-sync): cover venv lifecycle
group 2 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 2 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 2 path: tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py
group 2 path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py
group 2 path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_matrix_tdd.py
group 3: docs(deploy-venv-sync): record step 3 validation
group 3 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv.sh
staged path: tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py
staged path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_matrix_tdd.py
staged path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py
```

### Requestor assessment for step 3 deploy-venv-sync (round 2)

Step 3 is fully implemented against the plan's Step 3 file list. The seven
staged cplx paths contain the lifecycle entry, cumulative verifier, target
acceptance, 29 native unit cases across two test modules, and the updated
Step 3 validation verdict. P01/P07 consumer bytes are unchanged in this round.

Local gates: ShellCheck at style severity passed on the edited shell scripts
through cplx senv.bat; git diff --cached --check and the installed pre-commit
hook passed. The cplx ghog check passed, but ghog day stopped after its affected
stage reported exit 9 (repository not detected as a pytest project), so no cplx
coverage result is claimed. The plan's native Linux harness passed on the
RHEL 9.8 target: 186 all-unit cases, lint, syntax and line checks.

Target acceptance passed twice against the same venv with an offline console
script wheel selected from the consumer lock: 2 distributions installed and
bin/pygmentize had the exact venv Python shebang. The P07 record-backed
companion path passed with that selection, the script present and all 11
readiness checks. The earlier legacy no-record path also passed. Exact
commands, digests and logs are retained privately under AC13.

The consumer ghog day --force run passed 6,546 tests with 100% configured
application-source coverage and no outliers. Debian 12 agent build 198 passed
Provision, Package and Test with publication off; it exercised P01 but did not
run deploy_venv.sh. That full-mode build was a request addition, not a command
from the plan's Step 3 text. P01/P07 bytes did not change in round 2, so the
agent build was not repeated. The final byte-identical delivery snapshot and
source.sha256 passed all 14 digest checks and were committed in the consumer
for the next probe push.

Deployment ownership and serialization remain in the consumer; the cplx entry
uses the existing selection, transport and inventory helpers. Exact release
inputs and one named target avoid recency scans. No new production class or
separate Python helper was added. The 399-line matrix module and 183-line
existing unit module remain within the file ceiling.

### Implementation report for step 3 deploy-venv-sync (round 2)

The lifecycle entry selects the shipped Python from the verified tools prefix,
computes the full-version venv name, validates an existing target, performs
offline locked wheel sync with absolute uv and constrained environment, and
writes operation-bound readiness or first-failure evidence.

Round 2 repairs compare console-script shebangs as lexical absolute paths
under the once-resolved venv target, permitting the normal venv bin/python
symlink to the shipped base. The Bash entry clears its generic EXIT trap before
the lifecycle starts. Pre-sync and post-create interpreter checks use distinct
log labels. The operation records zipfile.BadZipFile as a controlled failure.

The new 18-case matrix module stubs process execution and covers the symlinked
console entry, foreign shebang and interpreter metadata, preflight shipped
Python branches, stale lock, absent and corrupt wheels, interrupted sync,
post-sync failure, changed toolchain at equal Python version, repeated and
mirror-removed targets, venv parent escape, source preparation, finish checks,
and Bash shipped-Python selection. Symlink tests skip on Windows and ran on
the RHEL 9.8 target. The existing 11-case module remains staged.

### Change summary for step 3 deploy-venv-sync (round 2)

Seven staged cplx paths, all covered by the valid three-group a.commit plan:

- src/setups/env/bin/deploy_venv.sh: lifecycle and round 2 repairs.
- docs/v0.27.0/verify.deploy-venv-sync.sh: cumulative verifier.
- docs/v0.27.0/acceptance.deploy-venv-sync.sh: target acceptance.
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py`,
  `test_venv_lifecycle_tdd.py` and `test_venv_lifecycle_matrix_tdd.py`:
  29 native unit cases total.
- docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md: checked Step 3
  Yes verdict, restored analysis, named unit cases and sanitized target outcomes.

The reviewed protocol transcript is unstaged. Consumer P01/P07 changes were
committed earlier; the final delivery snapshot digest refresh is a separate
consumer commit. No P10/P11 or unrelated consumer file is in this batch.
git diff --cached --check and commit-plan-check returned valid and ready.

### Writer response for step 3 deploy-venv-sync (round 2)

Writer response:

Round 1 findings addressed:

1. Blocking shebang containment: interpreter_state now checks the lexical
   absolute shebang path against the once-resolved target bin path. It does
   not resolve the venv Python symlink into the shipped base for this check.
   The symlink fixture passes, a foreign shebang fails, and RHEL acceptance
   twice installed a real console-script wheel with bin/pygmentize present.
2. Blocking tests-first matrix: the 18-case matrix module reaches
   interpreter_state, preflight, prepare_sources, finish_checks, operate
   success and failure paths, and Bash shipped-Python selection. It includes
   every state row listed in the round 1 answer. The RHEL cumulative verifier
   ran all 186 cases and the record-backed P07 path passed with the console
   wheel and all 11 readiness checks.
3. EXIT trap: the shell clears the generic entry-preflight trap immediately
   before lifecycle invocation, preserving the lifecycle's failure record.
4. Logs: pre-sync and post-create interpreter checks use distinct labels, so
   the latter cannot overwrite the former.
5. Corrupt wheel: operate catches zipfile.BadZipFile and writes a controlled
   failure record. A corrupt-wheel unit row checks that path.
6. Validation provenance drift: the Debian 12 full-mode consumer build was
   added by the requestor, not sourced from the plan's Step 3 text. Build 198
   passed but did not run deploy_venv.sh; P01/P07 bytes are unchanged in this
   round, so the build was not repeated. The RHEL 9.8 target runs are the
   direct Step 3 lifecycle evidence.

The implementation-check rerun restored the exact Step 3 Yes verdict and
removed the Missing work section. The commit plan remains valid for seven
staged paths. Please assess the exact staged index tree and the named gates.

### Reviewer focus for step 3 deploy-venv-sync (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-3-round-2 -->

## Round 2 by reviewer - Step 3

- Recorded: 2026-09-24T19:56:22+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: answer

### Assessed index identity for step 3 deploy-venv-sync (exchange 1) (round 2)

Baseline index tree: 27750f3da765d0232ae0dd254fb5d89248575066

Assessed index tree: 8fd56b8f5b8e4e166eac967620520744bcf12aae

### Implementation check for step 3 deploy-venv-sync (exchange 1) (round 2)

Result:

No. Step 3 has NOT been fully implemented.

The five round 1 findings are fixed, and the matrix reaches every row I asked
for. The first remaining gap comes from how finding 3 was fixed, which is the
way I suggested in round 1. The second is a smaller check that round 1 did not
raise.

Evidence I checked:

- the exact plan Step 3;
- the staged diff of all seven paths;
- the helper diff against its round 1 bytes, kept in the consumer's
  `22d5a666` snapshot;
- both unit modules in full;
- the Step 3 validation rows and `a.commit`;
- the consumer's P01 and P07 call sites of the entry.

Round 1 findings, as staged:

- **Shebang containment: fixed.** The check now takes the lexical absolute
  shebang path, normalizes it, resolves only its parent directory and compares
  it with the once-resolved `<target>/bin`. The symlinked-venv case passes, a
  foreign shebang fails, and RHEL acceptance installed a real entry point
  twice.
- **Tests-first matrix: fixed.** The 18-case module reaches
  `interpreter_state`, `preflight`, `prepare_sources`, `finish_checks`, the
  success and failure paths of `operate`, and the Bash shipped-Python
  selection, with every state row I listed.
- **Trap, log labels, corrupt wheel: fixed** as asked, plus the drift note:
  the Debian build is now sourced as a request addition.

Remaining gaps:

- **Readiness after an early lifecycle failure (medium).** `trap - EXIT` now
  runs just before `pdfss_runtime_run`. The embedded Python writes its first
  not-ready record inside `operate`, which runs only after the helper imports
  and `argparse`. Two failures fall in between:
  - a rejected argument, such as a relative `--manifest`, which the Bash loop
    does not check;
  - a helper module that fails to import.

  Either exits non-zero with no readiness write, so an earlier
  `"state":"ready"` record stays in `readiness.json`. Round 1 wrote not-ready
  there. The consumer branches on the exit status, not on that file, so the
  deployment itself still fails. But the plan's completion criterion says
  every failure leaves the operation not ready. Writing the generic record
  just before clearing the trap closes it, and `operate`'s own record still
  replaces it on the normal path.
- **Other interpreter links (low).** The design requires interpreter links
  and shebangs to be verified before readiness. Only `bin/python` is executed
  and checked. The loop skips every symlink in `bin`, and the shebang test
  accepts any name in `bin`. So a reused target whose `bin/python3` points to
  a host interpreter passes, along with every script that names it.

Architecture: no DDD-Hexagonal violation. The entry still delegates selection,
transport and inventory to the existing helpers, and the consumer keeps lock
and archive ownership. No architecture fix is needed.

Performance: the round 2 changes add one parent resolution per script and no
new scan. No performance fix is needed.

Unit test coverage: cplx has no configured coverage gate. Every top-level
function is referenced by a test, and the matrix covers the lifecycle branches.
One branch has no case: the early-failure path above. The new
`test_venv_lifecycle_matrix_tdd.py` is not in the plan's Step 3 file list. It
splits the step's own test folder by responsibility (183 + 399 lines), which
the plan's line-budget rule allows, so it is not a finding.

Feature integrity: unchanged from round 1. The record-backed path's omission
of Git restoration is authorized, and the legacy path ran on RHEL.

Validation plan effects:

The reviewer edited only the Step 3 rows of
`docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`:

- the status sentence is now `No. Step 3 has NOT been fully implemented.`,
  with its summary;
- a `### Missing work for Step 3` section now follows
  `What was implemented for Step 3`, in place of the
  `## Analysis of Step 3 Implementation` summary;
- the unit coverage row gains its closing Yes phrase.

That summary was staged mid-section, between `What was implemented` and
`New types or classes`. As a level-2 heading it re-parented the five Step 3
subsections after it. It exists only for a Yes verdict; the Missing work list
says to restore it after `Feature integrity for Step 3`, as Step 2 does. The
document-level status line is unchanged. No other step and no umbrella row
was touched.

### Pre-repair mandatory checks and coverage for step 3 deploy-venv-sync (exchange 1) (round 2)

The resolved validation set is requestor evidence, and the reviewer did not
rerun it. Reviewer evidence:

- `ghog check` (runs `check.bat`, the shell lint gate): exit 0, clean.
- `ghog affected --no-cov`: not run this round. It exited 9 in round 1 because
  cplx is not a pytest project, and that has not changed.
- `commit-plan-check.bat --format json`: `valid`, ready, no diagnostics, both
  before and after the reviewer patch.
- `git diff --cached --check`: exit 0 after the reviewer patch.

### Resolved validation set and sources for step 3 deploy-venv-sync (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (sources: project, plan).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 3 --python /absolute/shipped/python --app-repo /absolute/consumer` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 3` with absolute delivered inputs and consumer serialization attestation (source: plan).
- `consumer ghog day --force` (source: plan).
- `Debian 12 full-mode consumer build with publication off` (source: request).
- `shellcheck edited shell scripts through cplx senv.bat` (source: request).
- `git diff --cached --check` (source: request).
- `bash .git/hooks/pre-commit` (source: request).

### Resolver drift and direction for step 3 deploy-venv-sync (exchange 1) (round 2)

No drift. The round 1 drift is resolved: the Debian 12 full-mode build is now
sourced as a request addition. The project floor and the three Step 3 plan
commands match the plan text. The four request additions only add checks and
remove none.

### Repository state around validation for step 3 deploy-venv-sync (exchange 1) (round 2)

The index tree was `27750f3da765d0232ae0dd254fb5d89248575066` at request time
and at review entry. After the reviewer's validation-plan patch it is
`8fd56b8f5b8e4e166eac967620520744bcf12aae`. The umbrella digest is unchanged
(`46b95d18...`, `changed: false`). The validation-state comparison reports one
tracked difference, the validation plan, confined to the Step 3 rows and
attributed to the reviewer. The one ignored difference is `a.ghog.log`, from
`ghog check`. The only unstaged change is the protocol transcript.

### Repair inventory for step 3 deploy-venv-sync (exchange 1) (round 2)

Repairs made:

- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: Step 3 rows
- updated to the reviewer's No verdict with a Missing work list. The misplaced
- Yes-only summary section was removed. The patch was attributed cleanly and
- staged. Classification: polishing-only review metadata; no code, test,
- acceptance behavior or commit grouping changed.
- No implementation code or test was modified.

Paths staged:

- - `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- - `docs/v0.27.0/verify.deploy-venv-sync.sh`
- - `src/setups/env/bin/deploy_venv.sh`
- - `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py`
- - `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_matrix_tdd.py`
- - `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py`

### Commit plan assessment for step 3 deploy-venv-sync (exchange 1) (round 2)

The independent `commit-plan-check.bat --format json` run returned `valid`,
`ready: true` and no diagnostics, before and after the reviewer patch. All
seven staged paths sit in three ordered groups: the entry, then the harnesses
and both unit modules, then the validation plan alone with the required
subject. Membership, order and subjects are accurate, and the reviewer did not
amend `a.commit`. Once the fix lands, refresh two bodies:

- group 2's case count;
- group 3's "reports the completed step".

### Findings and boundaries for step 3 deploy-venv-sync (exchange 1) (round 2)

Unresolved findings:

- 1. Medium: after `trap - EXIT`, a lifecycle that fails before `operate`
- writes its record, on a rejected argument or a failed helper import, leaves
- an earlier ready record in `readiness.json`.
- 2. Low: `interpreter_state` verifies only `bin/python`. Other `bin/python*`
- links and the interpreter a shebang names are not checked.

Boundary-crossing work: None.

### Writer instructions for step 3 deploy-venv-sync (exchange 1) (round 2)

1. In `deploy_venv.sh`, write the generic not-ready record atomically just
   before `trap - EXIT`, for example by factoring the write out of
   `early_failure` and calling it once there. `operate`'s operation-bound
   record then replaces it on the normal path.
2. Add a Bash entry case to `test_venv_lifecycle_matrix_tdd.py`. Start with an
   earlier ready record in the evidence root and a `pdfss_runtime_run` stub
   that returns 2; after the run, `readiness.json` must be not ready.
3. In `interpreter_state`, require every `bin/python*` symlink to resolve to
   the same file as `bin/python`. Accept a shebang only when it names one of
   those links. Add one failing case: a `bin/python3` symlink to a foreign
   interpreter.
4. Rerun the RHEL `verify.deploy-venv-sync.sh --step 3` and one Step 3
   acceptance run: the entry changes on the success path too. P01/P07 are
   untouched, so no Debian build is needed. Refresh the consumer snapshot and
   `source.sha256` to the final bytes.
5. Re-run implementation-check. Restore the Step 3 summary after
   `Feature integrity for Step 3`, then refresh the `a.commit` bodies.
6. In the transcript's round 2 change summary, the unquoted
   `tests/unit/.../__init__.py` path reads as underscore bold, and the Markdown
   checker reports MD050. Wrap such paths in backticks in the round 3 request
   and summary, and fix that line when the transcript is next staged.

### Decision rationale for step 3 deploy-venv-sync (exchange 1) (round 2)

The readiness floor does not pass:

- Exact identity, staged attribution and the mechanical `a.commit` check
  pass.
- Implementation completeness fails on the early-failure readiness gap, which
  breaks the plan's "every failure leaves the operation not ready" criterion.
- Coverage fails on the one untested branch behind it.
- Two findings remain unresolved.

The disposition is changes-requested.

Finding 1 is a side effect of the trap fix I proposed in round 1. The writer
applied it as asked, and I should have named this path then. The consumer
already fails on the exit status, so no deployment would go ahead on a stale
record. The gap concerns the retained evidence and the plan criterion, and
the fix is a few lines.

Finding 2 was present in round 1 and I did not raise it then. It is low, and
it closes the design's "interpreter links" requirement. I am raising it now so
round 3 can close both. It adds no new host work beyond the rerun that
finding 1 already needs.

The split of the unit fixture into a second module is not a finding: it stays
inside the step's test folder and the plan's line-budget rule.

### Final reviewer decision for step 3 deploy-venv-sync (exchange 1) (round 2)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-3-round-2 -->

## Round 3 by requestor - Step 3

- Recorded: 2026-09-24T20:05:22+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: request

### Review identity for step 3 deploy-venv-sync (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 3
Review round: 3

### Code review evidence for step 3 deploy-venv-sync (round 3)

request_index_tree: 8342921c999e5ba8f278a3fa1fea3163ec051d15
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project, plan)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 3 --python /absolute/shipped/python --app-repo /absolute/consumer (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 3 with absolute delivered inputs and consumer serialization attestation (sources: plan)
- consumer ghog day --force (sources: plan)
- Debian 12 full-mode consumer build with publication off (sources: request)
- shellcheck edited shell scripts through cplx senv.bat (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy-venv-sync): reconstruct exact venv
group 1 path: src/setups/env/bin/deploy_venv.sh
group 2: test(deploy-venv-sync): cover venv lifecycle
group 2 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 2 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 2 path: tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py
group 2 path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py
group 2 path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_matrix_tdd.py
group 3: docs(deploy-venv-sync): record step 3 validation
group 3 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv.sh
staged path: tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py
staged path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_matrix_tdd.py
staged path: tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py
```

### Requestor assessment for step 3 deploy-venv-sync (round 3)

Step 3 is fully implemented against the plan's Step 3 boundaries. The seven
staged cplx paths contain the lifecycle entry, cumulative verifier, target
acceptance, 32 native lifecycle unit cases across two modules, and the checked
Step 3 Yes verdict. P01/P07 consumer bytes are unchanged in this round.

Local checks: ShellCheck at style severity passed on edited shell scripts
through cplx senv.bat; `git diff --cached --check`, installed pre-commit hook,
and commit-plan-check passed. The previous cplx ghog check passed, while ghog
day stopped at its affected stage because this repository is not configured as
a pytest project, so no cplx coverage result is claimed. The plan's native
Linux equivalent passed on the RHEL 9.8 target: 189 all-unit cases plus lint,
syntax and line checks.

RHEL Step 3 acceptance passed on first and repeated runs against the same venv
with an offline console-script wheel from the consumer lock: two distributions
installed and `bin/pygmentize` had the exact venv Python shebang. The earlier
P07 record-backed companion path with the console selection passed all 11
readiness checks, and the legacy no-record path passed. Exact commands,
digests and logs are retained privately under AC13.

The consumer `ghog day --force` passed 6,546 tests, 100% configured
application-source coverage and no outliers. Debian 12 agent build 198 passed
Provision, Package and Test with publication off; that full-mode build was a
request addition, not sourced from the plan's Step 3 text. It exercised P01
but did not run `deploy_venv.sh`. P01/P07 did not change in rounds 2 or 3, so
the agent build was not repeated. The final byte-identical delivery snapshot
and digest manifest passed all 14 checks and were committed locally in the
consumer for the next probe push.

Deployment ownership and serialization remain in the consumer; the entry uses
existing selection, transport and inventory helpers. No new production class
or separate Python helper was added. The matrix and core unit modules remain
below the file ceiling.

### Implementation report for step 3 deploy-venv-sync (round 3)

The lifecycle entry selects the shipped Python, computes the full-version venv
name, validates the target, runs offline locked wheel sync, and writes
operation-bound readiness or first-failure evidence. It validates console
script shebangs against the venv's exact interpreter names without resolving
the shebang through the shipped base interpreter.

Round 3 repairs write an atomic generic not-ready record immediately before
clearing the Bash EXIT trap and invoking the embedded lifecycle. An argument
rejection or helper import error after that boundary can no longer retain a
previous ready record; normal `operate` replaces it with operation-specific
evidence. `interpreter_state` now checks every `bin/python*` symlink against
`bin/python` and accepts a console shebang only for the primary name or a
verified interpreter link.

Three new matrix cases cover a matching `bin/python3` link and shebang, a
foreign `bin/python3` link, and an entry runtime failure after an earlier ready
record. The RHEL cumulative verifier ran all 189 unit cases and the direct
console-script acceptance passed on both first and repeated runs.

### Change summary for step 3 deploy-venv-sync (round 3)

Seven staged cplx paths, all covered by the valid three-group `a.commit` plan:

- `src/setups/env/bin/deploy_venv.sh`: lifecycle and round 3 readiness and
  interpreter-link repairs.
- `docs/v0.27.0/verify.deploy-venv-sync.sh`: cumulative verifier.
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`: target acceptance.
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py`,
  `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py`
  and `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_matrix_tdd.py`:
  32 native lifecycle unit cases total.
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: checked Step 3
  Yes verdict, restored analysis after feature integrity, case count and
  sanitized target outcomes.

The protocol transcript remains unstaged and was not manually edited. The
round 3 authored paths use code spans to avoid the Markdown underscore issue
reported in round 2. Consumer P01/P07 were committed earlier; the final
snapshot digest refresh is a separate local consumer commit. No P10/P11 or
unrelated consumer file is in this batch. `git diff --cached --check` and
commit-plan-check returned valid and ready.

### Writer response for step 3 deploy-venv-sync (round 3)

Writer response:

Round 2 findings addressed:

1. Early lifecycle failure: `write_not_ready` writes an atomic generic
   not-ready record just before `trap - EXIT` and `pdfss_runtime_run`. The
   embedded operation replaces it with its own record on the normal path.
   A native Bash entry case starts with a ready record, stubs the runtime to
   return 2, and verifies the record is not ready afterward.
2. Other interpreter links: `interpreter_state` verifies each `bin/python*`
   symlink resolves to the same file as `bin/python`. Console shebangs are
   accepted only for `bin/python` or a verified link. New unit cases accept a
   matching `bin/python3` link and reject a foreign link.

Both are substantive code and test repairs inside Step 3. ShellCheck and the
installed pre-commit hook pass. The RHEL cumulative `--step 3` verifier passed
189 cases, and direct console-wheel acceptance passed on first and repeated
targets with two distributions and `bin/pygmentize` present. The final helper
snapshot and digest manifest passed all 14 SHA256 checks and were committed
locally in the consumer. P01/P07 bytes are unchanged; the Debian 12 build was
not repeated. The Step 3 implementation-check restored the exact Yes verdict,
removed Missing work and placed the analysis after Feature integrity. The
three-group `a.commit` plan is valid for the seven staged files.

Round 1 findings remained fixed, as the round 2 reviewer confirmed. The
Debian full-mode build remains explicitly labeled a request addition. The
round 3 authored change summary uses code spans for every path with
underscores; the exchange-owned transcript stays unstaged. Please assess the
exact staged index tree and named gates.

### Reviewer focus for step 3 deploy-venv-sync (round 3)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-3-round-3 -->

## Round 3 by reviewer - Step 3

- Recorded: 2026-09-24T20:09:34+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: answer

### Assessed index identity for step 3 deploy-venv-sync (exchange 1) (round 3)

Baseline index tree: 8342921c999e5ba8f278a3fa1fea3163ec051d15

Assessed index tree: 8342921c999e5ba8f278a3fa1fea3163ec051d15

### Implementation check for step 3 deploy-venv-sync (exchange 1) (round 3)

Result:

Yes. Step 3 has been fully implemented.

Both round 2 gaps are closed, and the five round 1 fixes still hold. I checked:

- the helper diff against its round 2 bytes;
- the three new matrix cases;
- the staged Step 3 validation rows and `a.commit`;
- the requestor's journal entries for the round 3 host runs;
- the consumer's `09cb8580` snapshot blob, which is identical to the staged
  helper (`2700e23f`).

The round 3 fixes:

- **Early lifecycle failure.** A new `write_not_ready` holds the atomic
  generic write. `early_failure` calls it on a non-zero exit, and the entry
  also calls it unconditionally just before `trap - EXIT`. Any exit after
  that point therefore leaves not-ready unless `operate` writes its own
  record. `test_runtime_failure_invalidates_earlier_ready_record` starts from
  a ready record, stubs the runtime to return 2 and asserts not-ready. With
  the trap cleared, only the new write can produce that result.
- **Interpreter links.** Every `bin/python*` symlink must resolve to the same
  file as `bin/python`. A shebang must name one of the verified links by its
  lexical absolute path. New cases accept a matching `bin/python3` and reject
  a foreign one.

The links are compared against the once-resolved target. That fails closed
when an ancestor of the application root is a symlink, which
`require_target_directory` already rejects, so the policy stays consistent.

Architecture: no DDD-Hexagonal violation. The entry still delegates
selection, transport and inventory, and the consumer keeps lock and archive
ownership. No architecture fix is needed.

Performance: one directory glob per interpreter check and no new scan. No
performance fix is needed.

Unit test coverage: cplx has no configured coverage gate. Every top-level
function is referenced by a test, and 32 lifecycle cases cover the branches,
including the early-failure path. No unit-tested class is below 100%, and no
top-level symbol outside the gate is unreferenced.

Feature integrity: unchanged. The record-backed path's omission of Git
restoration is authorized by the plan and design, and the legacy path ran on
RHEL.

Validation plan effects:

The reviewer made no edit to the validation plan this round. The staged Step 3
rows are accurate:

- the status is the exact Yes sentence;
- the Missing work list is removed;
- `## Analysis of Step 3 Implementation` now sits after
  `Feature integrity for Step 3`;
- the rows state 21 matrix cases, 11 core cases and 189 RHEL cases;
- the closing phrases are present.

The document-level status stays `No, it is not implemented.`, which is
correct: Step 3b and Steps 4 to 7 are pending.

### Pre-repair mandatory checks and coverage for step 3 deploy-venv-sync (exchange 1) (round 3)

The resolved validation set is requestor evidence, and the reviewer did not
rerun it. Reviewer evidence:

- `ghog check`: exit 0, lint clean.
- `ghog affected --no-cov`: not run; cplx is not a pytest project (exit 9 in
  round 1).
- `commit-plan-check.bat --format json`: `valid`, ready, no diagnostics.
- `git diff --cached --check`: exit 0.
- The installed sensitive pre-commit hook: exit 0 on the staged blobs.
- The consumer snapshot blob matches the staged helper blob.

### Resolved validation set and sources for step 3 deploy-venv-sync (exchange 1) (round 3)

- `bash src/utils/lint_shell.sh` (sources: project, plan).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 3 --python /absolute/shipped/python --app-repo /absolute/consumer` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 3` with absolute delivered inputs and consumer serialization attestation (source: plan).
- `consumer ghog day --force` (source: plan).
- `Debian 12 full-mode consumer build with publication off` (source: request).
- `shellcheck edited shell scripts through cplx senv.bat` (source: request).
- `git diff --cached --check` (source: request).
- `bash .git/hooks/pre-commit` (source: request).

### Resolver drift and direction for step 3 deploy-venv-sync (exchange 1) (round 3)

No drift. The project floor and the three Step 3 plan commands match the plan
text. The four request additions, including the Debian 12 build, are labeled
as request additions and only add checks.

### Repository state around validation for step 3 deploy-venv-sync (exchange 1) (round 3)

The index tree was `8342921c999e5ba8f278a3fa1fea3163ec051d15` at request time,
at review entry and after the assessment. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison is acceptable, with no
tracked, untracked or ignored differences. The only unstaged change is the
protocol transcript.

### Repair inventory for step 3 deploy-venv-sync (exchange 1) (round 3)

Repairs made:

- None. The reviewer made no repair and staged nothing this round.

Paths staged:

- - `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- - `docs/v0.27.0/verify.deploy-venv-sync.sh`
- - `src/setups/env/bin/deploy_venv.sh`
- - `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py`
- - `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_matrix_tdd.py`
- - `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py`

### Commit plan assessment for step 3 deploy-venv-sync (exchange 1) (round 3)

The independent `commit-plan-check.bat --format json` run returned `valid`,
`ready: true` and no diagnostics. All seven staged paths sit in three ordered
groups:

1. the lifecycle entry;
2. the harnesses and both unit modules;
3. the validation plan alone, with the required subject
   `docs(deploy-venv-sync): record step 3 validation`.

The bodies now describe 11 core and 21 matrix cases and the completed step.
`a.commit` remains accurate, and the reviewer did not amend it.

### Findings and boundaries for step 3 deploy-venv-sync (exchange 1) (round 3)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 3 deploy-venv-sync (exchange 1) (round 3)

No rework is required. If the human selects Commit, three things to check:

- Stage the protocol transcript with the final group, as the workflow
  prescribes. Fix its round 2 change-summary line first: the unquoted
  `__init__.py` path reads as underscore bold, which the Markdown checker
  reports as MD050. Then run the pre-commit hook and the commit-plan check
  once more on the final index.
- The consumer snapshot commits `194d184b` and `09cb8580` are local only.
  Push them to the CI remote with the next Step 3b probe build.
- After the Commit flow prints `pw progress`, Step 3b is next.

### Decision rationale for step 3 deploy-venv-sync (exchange 1) (round 3)

All six readiness-floor results pass:

- Exact identity: the envelope, request fields, plan, step, round and
  request-time index tree agree.
- Complete implementation: every Missing work item from rounds 1 and 2 is
  closed in the staged bytes.
- Validation and coverage: the reviewer's `ghog check` is green, and the
  static assessment finds every lifecycle branch under test, including both
  round 3 paths. The requestor's RHEL verifier (189 cases) and console-wheel
  acceptance ran on the final helper bytes.
- Staged attribution: all seven paths belong to Step 3, and this round has no
  reviewer repair.
- Findings: none unresolved, current or carried.
- `a.commit`: accurate and mechanically valid.

The recommendation is commit-ready. It is advisory and does not authorize a
commit.

Two notes for the human at the gate. Neither is an open finding.

- The P07 record-backed companion run with the console-script selection used
  the round 2 helper bytes. The round 3 changes add a readiness write before
  the lifecycle and an interpreter-link check that the direct acceptance
  exercised on the same selection. P01/P07 did not change, so I did not ask
  for another companion run.
- Step 3's unit tests now span two modules. The second,
  `test_venv_lifecycle_matrix_tdd.py`, is not in the plan's Step 3 file list.
  It splits the step's own test folder by responsibility (183 + 437 lines),
  which the plan's line-budget rule allows.

### Final reviewer decision for step 3 deploy-venv-sync (exchange 1) (round 3)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-3-round-3 -->

## Round 3 by human - Step 3 - human-confirmation

- Recorded: 2026-09-24T20:23:35+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-3 -->
