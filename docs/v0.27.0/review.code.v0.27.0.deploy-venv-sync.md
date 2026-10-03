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
  a behavior change with its own test, which belongs to the writer.

Paths staged:

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv_inputs.py`
- `src/setups/env/bin/deploy_venv_probe.py`
- `src/setups/env/bin/deploy_venv_transport.py`
- `tests/unit/deploy_venv_sync/__init__.py`
- `tests/unit/deploy_venv_sync/test_native_probe/__init__.py`
- `tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/__init__.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`

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
  `check_isolation` proves that only `lo` is present and that external access
  fails, but not that loopback is usable. A namespace from `unshare -rn` has `lo`
  DOWN by default. The probe then reports "both designed transports failed;
  design review required", which is the plan's trigger to stop the step and
  return to design review, although only the caller's namespace setup was wrong.
  Reproduction on RHEL 9.8, with the staged code and the retained release inputs:
  `unshare -rn bash acceptance.deploy-venv-sync.sh --step 1 ...` fails, with
  `loopback.log` showing `tcp connect error: Network unreachable (os error 101)`
  against `http://127.0.0.1:<port>/wheels/...`.
  The same command with `ip link set lo up` first passes, state `passed`,
  transport `loopback`.
  Suggested fix: after the interface check, bind a socket on `127.0.0.1:0`,
  connect to it and close it. On failure raise a distinct error such as
  "supplied namespace has no usable loopback", separate from any transport
  verdict. Add the matching case to `test_native_probe_tdd.py`.

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

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv_inputs.py`
- `src/setups/env/bin/deploy_venv_probe.py`
- `src/setups/env/bin/deploy_venv_transport.py`
- `tests/unit/deploy_venv_sync/__init__.py`
- `tests/unit/deploy_venv_sync/test_native_probe/__init__.py`
- `tests/unit/deploy_venv_sync/test_native_probe/test_native_probe_tdd.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/__init__.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_pbt.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`

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
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 2 --python <selected-python> --app-repo <consumer-root>` (sources: plan)
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 2 --tools-prefix <tools> --application-root <app> --manifest <manifest> --profile <profile> --selection-profile <selection-profile> --evidence-root <evidence> --python <selected-python> --installed-root <site-packages> --wheel-dir <wheels> --venv-root <venv>` (sources: plan)

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

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv_selection.py`
- `src/setups/env/bin/tools_wheel_inventory.py`
- `tests/unit/deploy_venv_sync/test_selection_integrity/__init__.py`
- `tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_pbt.py`
- `tests/unit/deploy_venv_sync/test_selection_integrity/test_selection_integrity_tdd.py`
- `tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py`
- `tests/unit/tools_release_transport/test_tools_release_transport/test_tools_release_transport_tdd.py`

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

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: Step 3 rows
  updated to the reviewer's No verdict, with a Missing work list and a
  corrected unit coverage row. The patch was attributed cleanly and staged.
- Classification: polishing-only review metadata. It changes no code, test,
  acceptance behavior or commit grouping.
- No implementation code or test was modified.

Paths staged:

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv.sh`
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py`
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py`

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

1. High: `interpreter_state` in `src/setups/env/bin/deploy_venv.sh` resolves
the shebang interpreter through the venv's `bin/python` symlink, so every
wheel console script is reported as a foreign Python shebang. No retained
run installed a console script.
2. Medium: the plan's tests-first finite state matrix is only partly
implemented. `interpreter_state`, `preflight`, the success path and the Bash
shipped-Python selection have no unit case, and stale lock, missing wheel,
interruption, failed post-sync check, changed toolchain and
repeated or mirror-removed target rows have neither unit nor retained target
evidence.
3. Low: the Bash `EXIT` trap overwrites the operation-bound not-ready record
after every lifecycle failure.
4. Low: the two `interpreter_state` calls share the `venv-state` log label.
5. Low: `operate` does not catch `zipfile.BadZipFile`.

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

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: Step 3 rows
  updated to the reviewer's No verdict with a Missing work list. The misplaced
  Yes-only summary section was removed. The patch was attributed cleanly and
  staged. Classification: polishing-only review metadata; no code, test,
  acceptance behavior or commit grouping changed.
- No implementation code or test was modified.

Paths staged:

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv.sh`
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py`
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_matrix_tdd.py`
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py`

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

1. Medium: after `trap EXIT`, a lifecycle that fails before `operate`
writes its record, on a rejected argument or a failed helper import, leaves
an earlier ready record in `readiness.json`.
2. Low: `interpreter_state` verifies only `bin/python`. Other `bin/python*`
links and the interpreter a shebang names are not checked.

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

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv.sh`
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/__init__.py`
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_matrix_tdd.py`
- `tests/unit/deploy_venv_sync/test_venv_lifecycle/test_venv_lifecycle_tdd.py`

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

## Round 1 by requestor - Step 3b

- Recorded: 2026-09-24T23:11:48+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 3b
- Outcome: request

### Review identity for step 3b deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 3b
Review round: 1

### Code review evidence for step 3b deploy-venv-sync (round 1)

request_index_tree: 808f024de9f828a5521fb098e7f810d76576bb4c
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- git diff --cached --check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(deploy-venv-sync): record step 3b validation
group 1 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
```

### Requestor assessment for step 3b deploy-venv-sync (round 1)

Yes. Step 3b has been fully implemented as the non-qualifying actual-agent probe defined in the plan. Part A probe build 201 and part B probe build 205 each reached the mandated pipeline. Both resolved publication as disabled, generated a distinct POM, skipped deployment, and finished without a publication command. The final result of each complete build and each relevant command's real status were recorded separately.

Part A showed that P11 runs once in the nested test shell after matching checkout and before dependency commands. Synchronization and activation returned 0, missing compatibility input made installation return 2, and a deliberate test failure returned 1 although the enclosing test shell returned 0. Part B verified the phase-1 archive digest, but P01 preparation returned 127 on the nested agent because a fixed host interpreter path was unavailable. The Step 4 reconstruction input was not yet present. The mandatory commands therefore selected an implicit environment: synchronization and activation returned 0; installation returned 0 with unchanged inventory in that wrong environment; the test command returned 1 but was masked. The focused 12 tests passed, while the whole-project coverage gate failed at 19.31% against 100%. Named-venv selection and zero drift were not proved.

The public validation entry is limited to sanitized outcomes. Detailed build, library and agent records remain private under AC13. No cplx source or shared-library file changed. Architecture and performance checks found no Step 3b issue; Step 5 items 2, 4 and 6 own the observed incompatibilities and fail-closed behavior. No class-level unit coverage target was added in this probe. The cplx groundhog walk passed its check phase and exited 9 at the non-applicable pytest phase because cplx has no pytest project; the actual-agent probe builds supply this step's execution evidence. This step qualifies no candidate and proves no acceptance criterion.

### Implementation report for step 3b deploy-venv-sync (round 1)

The consumer's P10 and P11 probe changes were committed outside this reviewed cplx batch. A dedicated probe branch was prepared first; the CI job did not index it, so a probe mode in the one consuming Jenkinsfile ran both parts. The original full mode was restored after the probes. P11 observed the nested test shell, command boundaries and outcomes in archived records. Probe-only failure injection stayed outside the normal mode.

The sole staged cplx change is the Step 3b validation-plan entry. It records build 201 and build 205, the publication verdict, command outcomes, the failed P01 reconstruction, and explicit Step 5 inputs in public vocabulary. The complete records are private under AC13. No cplx source file or shared-library source was changed.

### Change summary for step 3b deploy-venv-sync (round 1)

Staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md.

Root a.commit has one documentation group with subject `docs(deploy-venv-sync): record step 3b validation`. The plan is formatted and commit-plan-check reports ready. The staged diff passed `git diff --cached --check`, and the installed pre-commit hook passed. No commit has been made.

### Writer response for step 3b deploy-venv-sync (round 1)

Writer response:

This is the first review round for Step 3b. There is no earlier feedback or disagreement. Please assess the staged public validation entry against the plan's non-qualifying completion rule, including whether each failed observation is stated without implying named-venv or full-suite qualification.

### Reviewer focus for step 3b deploy-venv-sync (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-3b-round-1 -->

## Round 1 by reviewer - Step 3b

- Recorded: 2026-09-24T23:20:28+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3b
- Outcome: answer

### Assessed index identity for step 3b deploy-venv-sync (exchange 1) (round 1)

Baseline index tree: 808f024de9f828a5521fb098e7f810d76576bb4c

Assessed index tree: 54278034744cd76c34150202f1ce960c736d5eb7

### Implementation check for step 3b deploy-venv-sync (exchange 1) (round 1)

Result:

No. Step 3b has NOT been fully implemented.

The probe work itself is sound. The step is not complete because the plan's
feature-preservation clause is unproven.

Evidence I checked:

- the plan's Step 3b section;
- the staged validation diff and `a.commit`;
- the requestor's private journal and the probe record table, covering builds
  199 to 205;
- the P10 and probe-test diff on the consumer's default branch, from before
  the probe to the restored mode;
- the CI server's build list for that job, read-only.

What holds:

- **Two complete probes.** Part A (build 201) and part B (build 205) each ran
  on actual agents and reached the mandated pipeline in one build. P11 arrived
  once in the nested test shell after a matching checkout and before the first
  dependency command, and stayed inactive elsewhere.
- **Publication proven off.** Each build recorded the effective
  publication-disabled value, no overriding job parameter, the generated POM,
  and the explicit deployment skip with no deployment command.
- **Honest command records.** Real statuses are recorded apart from the masked
  shell status, including the deliberate failure in part A and the
  coverage-gate failure in part B.
- **Part B's negative result.** P01 preparation failed on the nested agent,
  and the release path lacks the Step 4 inputs. This is recorded as such, not
  as a pass, with each consequence named as a Step 5 input. P01 sits outside
  Step 3b's P10/P11 scope, so a record rather than a fix is the right outcome.
- **The fallback.** The dedicated probe branch was not indexed, so the probe
  used the plan's own fallback, a probe mode in P10.

What does not hold yet:

- **Feature preservation (blocking).** The plan requires the consumer's
  default CI mode to stay unchanged. The fallback puts a top-level read of the
  mode file ahead of the pre-existing declarative pipeline and moves that whole
  pipeline into the switch's fallback branch. Builds 199 to 205 all took the
  probe branch. The mode was restored in a later consumer commit, but the build
  list shows no build since then.

  So the default path has not run once in its new position. Whether the CI
  server's declarative parser accepts the pipeline there is unverified, and I
  cannot settle it statically. The validation text nonetheless states the
  default path and publication behavior as "preserved".
- **Transcript encoding (low).** The request's authored sections came from
  input files with a UTF-8 byte order mark. Four U+FEFF characters now sit
  inside the unstaged transcript, at the start of the requestor's round 1
  paragraphs, and would be committed with it.

Architecture: no violation. P10 orchestrates and P11 observes; no cplx source
or shared-library file changed. No architecture fix is needed.

Performance: one bounded record per build and no new scan. No performance fix
is needed.

Unit test coverage: no cplx production code changed. The probe-only failing
test skips unless part A is selected and sits outside the consumer's
configured test paths. No unit-tested class is below 100%, and no top-level
symbol outside the gate is unreferenced.

Validation plan effects:

The reviewer edited only the Step 3b rows of
`docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`:

- the status is now `No. Step 3b has NOT been fully implemented.`, with its
  reason;
- a `### Missing work for Step 3b` section follows
  `What was implemented for Step 3b`;
- the Yes-only `## Analysis of Step 3b Implementation` summary is removed.

No other row, step or umbrella entry changed, and the document-level status
stays `No, it is not implemented.`

### Pre-repair mandatory checks and coverage for step 3b deploy-venv-sync (exchange 1) (round 1)

The resolved validation set is requestor evidence, and the reviewer did not
rerun it. Reviewer evidence:

- `commit-plan-check.bat --format json`: `valid`, ready, one group, before
  and after the reviewer patch.
- `git diff --cached --check`: exit 0.
- The installed sensitive pre-commit hook: exit 0 on the staged blobs.
- A read-only query of the CI job's build list: the newest build is probe
  build 205, which predates the restore commit.

`ghog check` was not rerun: no shell file changed in cplx this step, and the
requestor's run passed the lint floor.

### Resolved validation set and sources for step 3b deploy-venv-sync (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project).
- `git diff --cached --check` (source: request).

### Resolver drift and direction for step 3b deploy-venv-sync (exchange 1) (round 1)

No drift. Step 3b names no plan command in cplx. The project floor matches,
and the one request addition only adds a check. The step's executed evidence
is its probe builds, recorded privately.

### Repository state around validation for step 3b deploy-venv-sync (exchange 1) (round 1)

The index tree was `808f024de9f828a5521fb098e7f810d76576bb4c` at request time
and at review entry. After the reviewer's validation-plan patch it is
`54278034744cd76c34150202f1ce960c736d5eb7`. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison reports one tracked
difference, the validation plan, confined to the Step 3b rows and attributed
to the reviewer. The only unstaged change is the protocol transcript.

### Repair inventory for step 3b deploy-venv-sync (exchange 1) (round 1)

Repairs made:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: Step 3b rows
  updated to the reviewer's No verdict, with a Missing work list; the Yes-only
  summary was removed. The patch was attributed cleanly and staged.
- Classification: polishing-only review metadata.
- No implementation file was modified.

Paths staged:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`

### Commit plan assessment for step 3b deploy-venv-sync (exchange 1) (round 1)

The independent `commit-plan-check.bat --format json` run returned `valid`,
`ready: true` and no diagnostics, before and after the reviewer patch. One
group holds the single staged path, with the required subject
`docs(deploy-venv-sync): record step 3b validation`. `a.commit` remains
accurate; the reviewer did not amend it. After rework, refresh its body if it
mentions the preservation claim.

### Findings and boundaries for step 3b deploy-venv-sync (exchange 1) (round 1)

Unresolved findings:

1. Medium: P10's default mode has not run since the probe switch moved it into
the fallback branch, so the plan's feature-preservation clause is
unproven, and the validation text asserts it.
2. Low: four U+FEFF characters from BOM-carrying input files sit in the
unstaged transcript.

Boundary-crossing work:

- Not a writer finding: part B's central observation, whether the mandated
- commands select the reconstructed named venv without drift, remains open. It
- needs a P01 change, since its agent-identity helper hard-codes the host
- interpreter path, and the Step 4 release inputs. Both are outside Step 3b's
- P10/P11 scope. The handoff already names it as a Step 5 input. The human may
- want to decide whether to re-run part B once those exist.

### Writer instructions for step 3b deploy-venv-sync (exchange 1) (round 1)

1. Trigger one consumer build of the restored default mode, with publication
   off as that mode already configures. Capture its console and stage list, and
   compare them with build 198, the last default-mode build before the probe.
   Record it in the probe handoff and the journal.
2. If that build fails because of the new position of the pre-existing
   pipeline, restructure P10 so that pipeline runs as before. One option is to
   keep the probe in its own file loaded only in probe mode. Rerun the build.
3. Replace the "preserved" and "remains selected" sentences in the Step 3b
   rows with that build's number and outcome. Then re-run implementation-check
   on step 3b.
4. Before staging the transcript at Commit, strip the four U+FEFF characters
   from the start of your round 1 paragraphs. Write future input files as UTF-8
   without a byte order mark.

### Decision rationale for step 3b deploy-venv-sync (exchange 1) (round 1)

The readiness floor does not pass:

- Identity, staged attribution and the mechanical `a.commit` check pass.
- Completeness fails on the plan's feature-preservation clause: the default
  mode was moved inside a new switch and has not run since.
- Two findings remain.

The disposition is changes-requested. One default-mode build closes the main
finding; it is needed anyway before Steps 4 and 5 rely on that job.

The probe itself met the plan's bar. Both parts ran on actual agents with
publication proven off, and every expected observation is recorded,
including part B's negative result.

### Final reviewer decision for step 3b deploy-venv-sync (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-3b-round-1 -->

## Round 2 by requestor - Step 3b

- Recorded: 2026-09-24T23:52:12+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3b
- Outcome: request

### Review identity for step 3b deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 3b
Review round: 2

### Code review evidence for step 3b deploy-venv-sync (round 2)

request_index_tree: 5fa28abb3c8ba0653d7cf910672a72820a0e9eb7
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- git diff --cached --check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(deploy-venv-sync): record step 3b validation
group 1 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
```

### Requestor assessment for step 3b deploy-venv-sync (round 2)

Yes. Step 3b has been fully implemented as a non-qualifying actual-agent probe. Part A build 201 and part B build 205 each reached the mandated pipeline in one build with effective publication disabled. Both generated a distinct POM, explicitly skipped deployment, ran no publication command and have retained console, stage and adapter records. The final build result and each relevant command's real status were recorded separately.

Part A proved P11 reaches the nested test shell once after matching checkout and before dependency commands. Synchronization and activation returned 0; missing compatibility input made installation return 2; the deliberately failing test returned 1 while the enclosing shell returned 0. Part B verified the phase-1 archive digest but P01 preparation returned 127 on the nested agent because a fixed host interpreter path was unavailable, and the Step 4 reconstruction input was not yet present. Synchronization and activation then selected an implicit environment, installation returned 0 with unchanged inventory in that environment, and the real test status 1 was masked to shell status 0. Named-venv selection and zero drift were not proved. These are named Step 5 inputs, not qualification claims.

The reviewer's default-mode finding was reproduced in build 206: a probe switch broke declarative execution before any stage. P10 was restored byte-for-byte to its pre-probe form, the probe-only failing test was removed from the default branch, and repaired build 207 succeeded. Its ordered stage names and statuses exactly matched pre-probe build 198, including the consumer's own publication stage skipped. No publication command ran in either default-mode check. The dedicated probe branch retains the pipeline call.

The public validation entry reports only sanitized outcomes. Detailed integration records remain private under AC13. No cplx source or shared-library file changed. Architecture and performance checks found no Step 3b issue; no class-level unit coverage target was added. The cplx groundhog walk passed its check phase and exited 9 at the non-applicable pytest phase because cplx has no pytest project. This step qualifies no candidate and proves no acceptance criterion.

### Implementation report for step 3b deploy-venv-sync (round 2)

The consumer's P10 and P11 probe changes were committed outside this reviewed cplx batch. A dedicated probe branch was prepared first; the CI job did not index it, so a probe mode in the one consuming Jenkinsfile ran both parts. The dedicated branch retains the mandated pipeline call. P11 observed the nested test shell, command boundaries and outcomes in archived records.

After the probes, the first restored default-mode check failed before stages because the top-level switch changed declarative execution. The consumer repair restored P10 to its pre-probe bytes and removed the probe-only failing test from the default branch. The next default-mode build succeeded with the exact pre-probe stage sequence and publication skipped. The private handoff records both outcomes and the comparison with the prior default build.

The sole staged cplx change is the Step 3b validation-plan entry. It records builds 201, 205, 206 and 207, the publication verdict, command outcomes, failed named-venv reconstruction, successful default-mode repair and explicit Step 5 inputs in public vocabulary. Detailed records are private under AC13. No cplx source file or shared-library source changed.

### Change summary for step 3b deploy-venv-sync (round 2)

Staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md.

Root a.commit has one documentation group with subject `docs(deploy-venv-sync): record step 3b validation`. The plan is formatted and commit-plan-check reports ready. The staged diff passed `git diff --cached --check`, the cplx lint floor passed for 59 tracked scripts, and the installed pre-commit hook and sensitive checks passed. The append-only review transcript remains unstaged outside the reviewed batch. No cplx commit has been made.

### Writer response for step 3b deploy-venv-sync (round 2)

Writer response:

I accept the round 1 finding. Default-mode build 206 reproduced the parser regression before any stage. I restored the consumer's original P10 bytes, removed the probe-only failing test from its default branch, and recorded repaired build 207: SUCCESS with the same ordered stage names and statuses as pre-probe build 198, including publication skipped. The public Step 3b validation rows now cite both checks and the private handoff retains their console and stage evidence.

I also removed the four embedded U+FEFF characters identified in the unstaged transcript. The edited transcript passes the message-mode sensitive checker, and the new authored inputs use UTF-8 without a byte order mark. I retained the reviewer's Part B negative finding and its Step 5 ownership without claiming named-venv qualification. There is no disagreement with the round 1 answer.

### Reviewer focus for step 3b deploy-venv-sync (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-3b-round-2 -->

## Round 2 by reviewer - Step 3b

- Recorded: 2026-09-24T23:56:20+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3b
- Outcome: answer

### Assessed index identity for step 3b deploy-venv-sync (exchange 1) (round 2)

Baseline index tree: 5fa28abb3c8ba0653d7cf910672a72820a0e9eb7

Assessed index tree: 5fa28abb3c8ba0653d7cf910672a72820a0e9eb7

### Implementation check for step 3b deploy-venv-sync (exchange 1) (round 2)

Result:

Yes. Step 3b has been fully implemented.

Both round 1 findings are closed, and the probe results stand as recorded in
round 1. I checked:

- the staged Step 3b rows and `a.commit`;
- the consumer's default branch on the CI remote: P10 is byte-identical to
  its pre-probe version, the probe-only failing test is gone, the CI mode
  file reads the default mode, and only the inactive adapter and one ignore
  rule remain from the probe;
- the CI server's records for builds 206, 207 and 198, read-only;
- the transcript, for stray byte order marks.

Details:

- **Feature preservation.** My round 1 concern was real. Build 206, the first
  default-mode build after the probe, failed about two seconds in, before any
  stage: the switch had broken the pre-existing declarative pipeline. The
  writer restored P10's pre-probe bytes. Build 207, on that repair, succeeded,
  and its thirteen stage names and statuses match build 198 one for one,
  including the consumer's own publication stage not executed. The rows now
  say this with build numbers instead of asserting preservation.
- **Transcript.** No U+FEFF character remains, and this round's request
  carries none.
- **Probe result, unchanged from round 1.** Parts A and B each have a
  complete build (201 and 205) on actual agents, with publication proven not
  invoked. Every expected observation is recorded, including part B's
  negative result and the masked test status. That meets the plan's
  completion bar for a non-qualifying probe.

Architecture: no violation, and no cplx source or shared-library file changed.
No architecture fix is needed.

Performance: nothing changed since round 1. No performance fix is needed.

Unit test coverage: no cplx production code changed. No unit-tested class is
below 100%, and no top-level symbol outside the gate is unreferenced.

Validation plan effects:

The reviewer made no edit to the validation plan this round. The staged Step 3b
rows are accurate:

- the exact Yes sentence;
- no Missing work section;
- the summary placed after `Feature integrity for Step 3b`;
- builds 201, 205, 206 and 207 cited in public vocabulary.

The document-level status stays `No, it is not implemented.`

### Pre-repair mandatory checks and coverage for step 3b deploy-venv-sync (exchange 1) (round 2)

The resolved validation set is requestor evidence, and the reviewer did not
rerun it. Reviewer evidence:

- `commit-plan-check.bat --format json`: `valid`, ready, one group.
- `git diff --cached --check`: exit 0.
- The installed sensitive pre-commit hook: exit 0 on the staged blobs.
- A scan of the staged Step 3b rows for private names: none. The only hit is
  the plan's own generic "consuming Jenkinsfile".
- A read-only CI query: build 206 failed in about two seconds, and build 207
  succeeded with the same stages as build 198.

### Resolved validation set and sources for step 3b deploy-venv-sync (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (source: project).
- `git diff --cached --check` (source: request).

### Resolver drift and direction for step 3b deploy-venv-sync (exchange 1) (round 2)

No drift. The project floor matches, and the request addition only adds a
check.

### Repository state around validation for step 3b deploy-venv-sync (exchange 1) (round 2)

The index tree was `5fa28abb3c8ba0653d7cf910672a72820a0e9eb7` at request time,
at review entry and after the assessment. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison is acceptable, with no
differences. The only unstaged change is the protocol transcript.

### Repair inventory for step 3b deploy-venv-sync (exchange 1) (round 2)

Repairs made:

- None. The reviewer made no repair and staged nothing this round.

Paths staged:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`

### Commit plan assessment for step 3b deploy-venv-sync (exchange 1) (round 2)

The independent `commit-plan-check.bat --format json` run returned `valid`,
`ready: true` and no diagnostics. One group holds the single staged path, with
the required subject `docs(deploy-venv-sync): record step 3b validation`.
`a.commit` remains accurate; the reviewer did not amend it.

### Findings and boundaries for step 3b deploy-venv-sync (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 3b deploy-venv-sync (exchange 1) (round 2)

No rework is required. If the human selects Commit:

1. Stage the protocol transcript with the final group, as the workflow
   prescribes. Then run the hook and the commit-plan check once more on the
   final index.
2. Before or right after committing, add one bullet to the private probe
   handoff's "Inputs from the probes to Step 5". That file is ignored, so the
   edit does not touch the reviewed batch. The bullet covers the full-suite
   duration in the mandated test step: about 1,290 s against 271 s for the
   same suite in the consumer's own build. It also covers the outer allocation
   lost during that step in builds 200 and 204, which kept the later stages
   from running. Step 5 should capture the test agent's processor count and
   quota, and time the suite with its output redirected.

### Decision rationale for step 3b deploy-venv-sync (exchange 1) (round 2)

All six readiness-floor results pass:

- exact identity;
- complete implementation against the plan's non-qualifying completion bar;
- validation and coverage: no cplx code changed, the lint floor passed, and
  both probe parts plus the default-mode check are evidenced on actual
  agents;
- attributable staged scope: one validation file, no reviewer repair;
- no unresolved finding;
- accurate `a.commit`.

The recommendation is commit-ready. It is advisory and does not authorize a
commit.

A note for the human at the gate. Step 3b shows that the mandated pipeline
runs for the consumer on actual agents with publication off, and that the
adapter hook reaches its test shell. It does not yet show that the pipeline
tests on the cplx interpreter. Part B's named venv was never built: a P01
helper hard-codes a host interpreter path missing on the test agent, and the
release inputs arrive in Step 4. The full suite in the mandated test step is
also about five times slower than in the consumer's own build, and it lost the
outer allocation twice. Both are Step 5 inputs.

### Final reviewer decision for step 3b deploy-venv-sync (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-3b-round-2 -->

## Round 2 by human - Step 3b - human-confirmation

- Recorded: 2026-09-25T00:26:57+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3b
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 1 by requestor - Step 4

- Recorded: 2026-09-25T13:36:35+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 4
- Outcome: request

### Review identity for step 4 deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 4
Review round: 1

### Code review evidence for step 4 deploy-venv-sync (round 1)

request_index_tree: cc0e5bca162afba54c03e53b63f2757d4b5bee50
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 4 (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 4 (sources: plan)
- shellcheck -x -S style docs/v0.27.0/verify.deploy-venv-sync.sh docs/v0.27.0/acceptance.deploy-venv-sync.sh src/setups/env/bin/install_pkg.sh (sources: request)
- bash .git/hooks/pre-commit (sources: request)
- git diff --cached --check (sources: request)
- Debian 12 agent full-mode build 210 with publication off (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy-venv-sync): retain release inputs
group 1 path: src/setups/env/bin/deploy_venv_archive.py
group 1 path: src/setups/env/bin/deploy_venv_inputs.py
group 1 path: src/setups/env/bin/deploy_venv_release.py
group 1 path: src/setups/env/bin/install_pkg.sh
group 1 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 1 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 1 path: tests/unit/deploy_venv_sync/test_archive_recovery/__init__.py
group 1 path: tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py
group 1 path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
group 2: docs(deploy-venv-sync): record step 4 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_archive.py
staged path: src/setups/env/bin/deploy_venv_inputs.py
staged path: src/setups/env/bin/deploy_venv_release.py
staged path: src/setups/env/bin/install_pkg.sh
staged path: tests/unit/deploy_venv_sync/test_archive_recovery/__init__.py
staged path: tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
```

### Requestor assessment for step 4 deploy-venv-sync (round 1)

Step 4 is fully implemented. The archive adapter discovers venv roots once,
passes exclusions to the existing packager, and inspects each produced archive.
The release record binds the entry, companion, helper closure and independent
tools pin. Preflight refuses missing, truncated or wrong-digest local inputs
before mutation or fetching. Retained current and predecessor inputs remain
outside the mirrored tree; readiness gates promotion.

The final cumulative verifier passed on the RHEL 9.8 target, including 202
broader tests, shell lint, the tools release gate and syntax/line ceilings.
Acceptance passed with host interpreter and PATH decoys. Controlled fixtures
proved record-backed deployment, historical first transition, both offline
rollback formats, mirror deletion, root-lock contention and independent roots.
The installer relocation regression passed 63 cases. The Debian 12 agent's
full-mode build 210 succeeded on the final delivered bytes. It had the same 13
stage outcomes as build 207; Package and Test passed, Publish was not executed,
and package and assembly lists matched at 3,529 members with no `pyvenv.cfg`.

The cplx `ghog day` project default passed its check phase and then reached its
expected exit 9 at the non-applicable pytest phase. cplx is not a pytest
project. The consumer's own `ghog day` passed check, affected and full, with
fail=0 and its configured application-source coverage gate at 100%. That gate
does not measure the deployment scripts. Unit tests under the cplx unit root
exercise the new top-level helper functions; no new class hierarchy was added.
No architecture, performance or feature-integrity issue was found in this
check. Detailed target and build records are private under AC13.

### Implementation report for step 4 deploy-venv-sync (round 1)

The cplx archive helper supplies safe exclusions to the existing packager and
inspects its result. The input helper assembles a pinned helper and runtime
closure and emits a non-circular release record. The release helper validates
the record and referenced files, stages complete copies, selects retained
inputs and promotes a candidate only after readiness. The installer accepts an
exact selected archive. Cumulative verify and acceptance commands cover the
new release and recovery boundaries.

The consumer's P07-P09 and P16-P20 changes were committed separately, outside
this reviewed cplx batch. They use the new helpers for both packaging routes,
local qualification, serialized deployment and offline recovery. The default
pipeline file stayed byte-identical to its successful baseline and publication
remained off. Detailed consumer records are private under AC13.

### Change summary for step 4 deploy-venv-sync (round 1)

The staged cplx batch has ten paths and two commit groups in the root
`a.commit`:

- Behavior and tests: `deploy_venv_archive.py`, `deploy_venv_inputs.py`,
  `deploy_venv_release.py`, `install_pkg.sh`, the cumulative verify and
  acceptance scripts, and the archive/recovery and release-input unit tests.
- Validation: the Step 4 rows of
  `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`.

The first group is `feat(deploy-venv-sync): retain release inputs`. The trailing
group is `docs(deploy-venv-sync): record step 4 validation`. The staged
whitespace check, sensitive pre-commit hook and commit-plan readiness check
passed. No cplx commit has been made for this batch.

### Writer response for step 4 deploy-venv-sync (round 1)

Writer response:

This is round 1. There is no earlier reviewer feedback for Step 4.

### Reviewer focus for step 4 deploy-venv-sync (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-4-round-1 -->

## Round 1 by reviewer - Step 4

- Recorded: 2026-09-25T13:43:43+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: answer

### Assessed index identity for step 4 deploy-venv-sync (exchange 1) (round 1)

Baseline index tree: cc0e5bca162afba54c03e53b63f2757d4b5bee50

Assessed index tree: 3dfbfb4bec34a21d1dda27403fd3a866fe9ade81

### Implementation check for step 4 deploy-venv-sync (exchange 1) (round 1)

Result:

No. Step 4 has NOT been fully implemented.

The packaging, retention and recovery work is substantial and largely sound.
One integrity rule the plan names for item 3 is not enforced, and two new
behaviors have no unit case.

Evidence I checked:

- the plan's Step 4 section;
- all ten staged paths: both new helpers in full, the input-helper,
  installer and harness diffs, both unit modules' case lists, and the Step 4
  validation rows;
- `a.commit`;
- the consumer commits for P07-P09 and P16-P20, and how the consuming
  deployment route calls the release helper.

What holds:

- **Archive helper.** It walks each declared root once, without following
  aliases, and fails closed on a dangling alias. It passes literal
  exclusions after the caller's own rules and generates the assembly
  descriptor from the same discovery. The produced archive is rejected when
  any member is named `pyvenv.cfg` or sits under an excluded boundary.
- **Release helper.** It parses a strict ten-key record without shell
  evaluation, checks every outer input against the record before any
  mutation, and verifies inner and outer bindings through the companion.
  Promotion happens only on an explicit ready result and keeps the previous
  current release as predecessor.
- **Helper assembly.** Helpers come from one exact revision through the
  version-control store, never from working-tree bytes.
- **Evidence.** The requestor reports RHEL cumulative and acceptance runs
  covering both offline rollback formats, mirror deletion, competing root
  operations and independent roots, plus Debian build 210 matching build 207
  with no `pyvenv.cfg` in the 3,529 packaged members.

What does not hold yet:

- **Closure check (medium).** `verify` enforces the complete production
  helper closure only when `helpers/deploy_venv.sh` is among the members. A
  companion that omits exactly that entry helper therefore skips the check.
  `qualify` and release-record creation call the same `verify`, so such a
  candidate qualifies. The plan requires "Make missing helper delivery fail
  before candidate freeze" and "Reject missing members". The consuming
  bootstrap's later file check does not run before freeze.
- **Untested behaviors (medium-low).**
  - `stage_helpers`, the pinned-revision helper assembly at the core of
    item 3, has no unit case.
  - The installer's new `--archive` selection, which implements the
    tests-first row "unrelated newer archive ignored", has none either.
- **Installer scope (low).** `install_pkg.sh` is not in Step 4's file list,
  and the plan's table calls it a reused boundary. The opt-in change is
  justified by the plan: it never selects the newest file, and the helper
  closure now ships the installer. But the request and the validation rows do
  not say so, and `usage()` does not list the option.
- **Record operation (low).** It writes the record before qualifying it, so a
  failed qualification leaves a plausible record on disk. `tarfile.TarError`
  is also not recorded as a refusal.
- **Duplicate retention (low).** `deploy_venv_release.stage` refuses to
  re-stage an identical retained release, and the consuming route does not
  use it: it stages in its own Bash, which tolerates a retry. So two
  implementations of the retention layout can drift.

Architecture: no violation. Packaging, input validation and retention are
separate script boundaries. The duplicated retention is noted above.

Performance: discovery is one walk per root, and hashing is linear in input
size. `promote` re-verifies current, predecessor and candidate at that
boundary, which is an accepted integrity reread. No performance fix is needed.

Unit test coverage: no class hierarchy was added, and every top-level function
is referenced. `stage_helpers` and the installer option have no case, as
listed.

Validation plan effects:

The reviewer edited only the Step 4 rows of
`docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`:

- the status is now `No. Step 4 has NOT been fully implemented.`, with its
  reason;
- a `### Missing work for Step 4` section follows
  `What was implemented for Step 4`;
- the unit coverage row gains its closing Yes phrase;
- the Yes-only `## Analysis of Step 4 Implementation` summary is removed.

No other step or umbrella row changed.

### Pre-repair mandatory checks and coverage for step 4 deploy-venv-sync (exchange 1) (round 1)

The resolved validation set is requestor evidence, and the reviewer did not
rerun it. Reviewer evidence:

- `ghog check`: exit 0, lint clean, covering the staged installer and
  harness scripts.
- `ghog affected --no-cov`: not run, since cplx is not a pytest project.
- `commit-plan-check.bat --format json`: `valid`, ready, no diagnostics,
  before and after the reviewer patch.
- `git diff --cached --check` and the installed pre-commit hook: exit 0.

### Resolved validation set and sources for step 4 deploy-venv-sync (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 4` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 4` (source: plan).
- `shellcheck -x -S style` on the verify, acceptance and installer scripts (source: request).
- `bash .git/hooks/pre-commit` (source: request).
- `git diff --cached --check` (source: request).
- Debian 12 agent full-mode build 210 with publication off (source: request).

### Resolver drift and direction for step 4 deploy-venv-sync (exchange 1) (round 1)

No drift. The project floor and the two Step 4 plan commands match the plan
text. The four request additions, including the Debian build, only add
checks.

### Repository state around validation for step 4 deploy-venv-sync (exchange 1) (round 1)

The index tree was `cc0e5bca162afba54c03e53b63f2757d4b5bee50` at request time
and at review entry. After the reviewer's validation-plan patch it is
`3dfbfb4bec34a21d1dda27403fd3a866fe9ade81`. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison reports one tracked
difference, the validation plan, confined to the Step 4 rows and attributed
to the reviewer. The one ignored difference is `a.ghog.log`. The only unstaged
change is the protocol transcript.

### Repair inventory for step 4 deploy-venv-sync (exchange 1) (round 1)

Repairs made:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: Step 4 rows
  updated to the reviewer's No verdict, with a Missing work list; the Yes-only
  summary was removed. The patch was attributed cleanly and staged.
- Classification: polishing-only review metadata.
- No implementation file was modified.

Paths staged:

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv_archive.py`
- `src/setups/env/bin/deploy_venv_inputs.py`
- `src/setups/env/bin/deploy_venv_release.py`
- `src/setups/env/bin/install_pkg.sh`
- `tests/unit/deploy_venv_sync/test_archive_recovery/__init__.py`
- `tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`

### Commit plan assessment for step 4 deploy-venv-sync (exchange 1) (round 1)

The independent `commit-plan-check.bat --format json` run returned `valid`,
`ready: true` and no diagnostics, before and after the reviewer patch. Two
ordered groups hold all ten staged paths: behavior and tests first, then the
validation plan alone with the required subject
`docs(deploy-venv-sync): record step 4 validation`. `a.commit` remains
accurate; the reviewer did not amend it. After rework, refresh the first
group's body if it gains new cases or the installer's rationale.

### Findings and boundaries for step 4 deploy-venv-sync (exchange 1) (round 1)

Unresolved findings:

1. Medium: the production helper-closure check is skipped for a companion
   that omits `helpers/deploy_venv.sh`, so qualification accepts it.
2. Medium-low: `stage_helpers` and the installer's `--archive` selection have
   no unit case.
3. Low: `install_pkg.sh` changed outside the file list without a stated
   basis or a `usage()` entry.
4. Low: the `record` operation leaves a record behind when qualification
   fails, and `tarfile.TarError` is not recorded as a refusal.
5. Low: the retention layout is implemented twice, and the cplx `stage` is not
   idempotent for an identical retained release.

Boundary-crossing work: None.

### Writer instructions for step 4 deploy-venv-sync (exchange 1) (round 1)

1. **Closure check.** Make the complete helper-closure check explicit on the
   production paths (assembly, record creation, qualification), and let
   fixtures opt out by an explicit argument rather than by omitting
   `helpers/deploy_venv.sh`. Add a qualification case that refuses a helper
   list without that entry helper.
2. **`stage_helpers` cases,** in `test_archive_recovery` or `test_release_inputs`,
   using a temporary Git repository:
   - exact-revision bytes win over working-tree edits;
   - an abbreviated or non-commit revision is refused;
   - an aliased or missing runtime setup is refused;
   - an existing destination member is refused.
3. **Installer option.** Add `--archive <absolute path>` to `install_pkg.sh`'s
   `usage()` and header comment. Add Linux-only cases showing that an explicit
   archive wins over a newer unrelated one, and that a relative path, a
   symlink and a mismatched name are refused. Say in "What was implemented"
   why a file outside the list changed: the plan's "never newest timestamp"
   rule and the helper closure that now ships the installer.
4. **Record operation.** In `deploy_venv_release.py record`, write to a
   temporary path and rename after qualification. Add `tarfile.TarError` to
   the refusals.
5. **Retention.** Either make `stage` idempotent for identical retained bytes
   and call it from the consuming deployment route instead of the Bash
   staging, or remove `stage` and state that the consumer owns staging.
6. Rerun `verify.deploy-venv-sync.sh --step 4` on the RHEL 9.8 target. Rerun
   the acceptance mode if the release helper's CLI changes. A Debian build is
   needed only if consumer packaging bytes change. Refresh the consumer's
   helper snapshot and its digest file.

### Decision rationale for step 4 deploy-venv-sync (exchange 1) (round 1)

The readiness floor does not pass:

- Identity, staged attribution and the mechanical `a.commit` check pass.
- Completeness fails on the plan's item 3 rule, since missing helper delivery
  must fail before candidate freeze.
- Coverage fails on the two untested behaviors.
- Five findings remain.

The disposition is changes-requested.

The fixes are small and local to the cplx helpers, apart from the optional
move of consumer staging onto the cplx `stage`. None of them touches the
archive, rollback or concurrency behavior the target runs already exercised.

### Final reviewer decision for step 4 deploy-venv-sync (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-4-round-1 -->

## Round 2 by requestor - Step 4

- Recorded: 2026-09-25T14:10:38+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: request

### Review identity for step 4 deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 4
Review round: 2

### Code review evidence for step 4 deploy-venv-sync (round 2)

request_index_tree: e92e0e777b2fd5829bf43c31387b03adadcd5817
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 4 (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 4 (sources: plan)
- shellcheck -x -S style docs/v0.27.0/verify.deploy-venv-sync.sh docs/v0.27.0/acceptance.deploy-venv-sync.sh src/setups/env/bin/install_pkg.sh (sources: request)
- bash .git/hooks/pre-commit (sources: request)
- git diff --cached --check (sources: request)
- Debian 12 agent full-mode build 210 with publication off (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy-venv-sync): retain release inputs
group 1 path: src/setups/env/bin/deploy_venv_archive.py
group 1 path: src/setups/env/bin/deploy_venv_inputs.py
group 1 path: src/setups/env/bin/deploy_venv_release.py
group 1 path: src/setups/env/bin/install_pkg.sh
group 1 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 1 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 1 path: tests/unit/deploy_venv_sync/test_archive_recovery/__init__.py
group 1 path: tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py
group 1 path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
group 2: docs(deploy-venv-sync): record step 4 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_archive.py
staged path: src/setups/env/bin/deploy_venv_inputs.py
staged path: src/setups/env/bin/deploy_venv_release.py
staged path: src/setups/env/bin/install_pkg.sh
staged path: tests/unit/deploy_venv_sync/test_archive_recovery/__init__.py
staged path: tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
```

### Requestor assessment for step 4 deploy-venv-sync (round 2)

Step 4 is fully implemented after the round 1 repairs. Production input
verification now requires the complete helper closure for assembly, record
creation and qualification. A candidate without the deployment entry helper
is refused. Pinned helper staging and exact installer archive selection have
focused tests, including Linux execution on the RHEL 9.8 target.

The cumulative verifier passed on the RHEL 9.8 target after repair, including
210 broader tests, shell lint, the tools release gate and syntax/line ceilings.
Acceptance passed with host interpreter and PATH decoys. Earlier controlled
fixtures proved record-backed deployment, historical first transition, both
offline rollback formats, mirror deletion, root-lock contention and independent
roots. The installer relocation regression passed 63 cases.

The Debian 12 agent's full-mode build 210 succeeded on the packaging bytes,
with the same 13 stage outcomes as build 207. Package and Test passed, Publish
was not executed, and package and assembly lists matched at 3,529 members
with no `pyvenv.cfg`. The review repairs did not change packaging bytes, so
the reviewer did not require a new Debian build.

The cplx `ghog day` project default passed its check phase and reached its
expected exit 9 at the non-applicable pytest phase. The consumer's own `ghog
day` passed check, affected and full, with fail=0 and its configured
application-source coverage gate at 100%. That gate does not measure the
deployment scripts; the focused and native tests exercise them. No new class
hierarchy was added. No architecture, performance or feature-integrity issue
was found. Detailed target and build records are private under AC13.

### Implementation report for step 4 deploy-venv-sync (round 2)

The archive helper discovers venv roots once, passes exclusions to the
packager, and inspects both produced archive routes. The input helper stages
the full pinned helper and runtime closure and creates the non-circular
release record. Verification now requires every production helper by name,
regardless of which helpers a candidate lists.

The release helper checks the record and local files, qualifies a temporary
record before publishing it atomically without replacement, refuses malformed
tar inputs, and reads current or predecessor retained inputs. The consumer
owns immutable retention staging and keeps its root lock through readiness.
The installer accepts an exact absolute archive so an unrelated newer archive
cannot be selected during retained reconstruction. The option and its
refusals are documented and tested.

The consumer's P07-P09 and P16-P20 changes were committed separately, outside
this reviewed cplx batch. Its refreshed probe snapshot and digest table were
also committed separately. The default pipeline file and packaging bytes
stayed unchanged; publication remained off. Detailed consumer records are
private under AC13.

### Change summary for step 4 deploy-venv-sync (round 2)

The staged cplx batch has ten paths and two groups in the root `a.commit`:

- Behavior and tests: the archive, input and release helpers, installer, the
  cumulative verify and acceptance scripts, and the archive/recovery and
  release-input unit tests.
- Validation: the Step 4 rows of
  `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`.

The first group is `feat(deploy-venv-sync): retain release inputs`. The trailing
group is `docs(deploy-venv-sync): record step 4 validation`. The staged
whitespace check, sensitive pre-commit hook and commit-plan readiness check
passed. No cplx commit has been made for this batch. The live review
transcript is left outside the stable reviewed index.

### Writer response for step 4 deploy-venv-sync (round 2)

Writer response:

All five round 1 findings were accepted and repaired:

1. Production verification requires the full helper closure unconditionally.
   The fixtures now supply that closure, and qualification refuses a candidate
   missing the entry helper.
2. Temporary-Git tests prove helper bytes come from the exact commit and
   reject abbreviated or non-commit revisions, missing or aliased runtime
   setup, and existing destinations. Linux installer cases cover an explicit
   archive winning over a newer one and relative, symlink and name refusals.
3. The installer header and usage name `--archive`; the validation plan states
   its basis in the Step 4 unrelated-newer-archive rule and helper closure.
4. Record creation qualifies a same-directory temporary file before atomic
   no-clobber publication, leaves no output after failure and handles tar
   errors as refusals.
5. The duplicate cplx retention writer was removed. The consumer owns staging;
   the cplx helper validates selection and readiness-gated promotion.

The RHEL 9.8 target cumulative verifier and acceptance passed on repaired
bytes. The consumer snapshot and checksums were refreshed and committed
separately. Its packaging bytes did not change, so build 210 remains the
Debian package-stage evidence under the reviewer's round 1 instruction.

### Reviewer focus for step 4 deploy-venv-sync (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-4-round-2 -->

## Round 2 by reviewer - Step 4

- Recorded: 2026-09-25T14:14:24+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: answer

### Assessed index identity for step 4 deploy-venv-sync (exchange 1) (round 2)

Baseline index tree: e92e0e777b2fd5829bf43c31387b03adadcd5817

Assessed index tree: d65660186c8e5201b0417211069e5131fb61adb1

### Implementation check for step 4 deploy-venv-sync (exchange 1) (round 2)

Result:

Yes. Step 4 has been fully implemented.

All five round 1 findings are fixed in the staged bytes. I checked the staged
helpers, the installer, both unit modules and the Step 4 validation rows.

- **Helper closure.** `verify` now requires the complete helper and runtime
  closure unconditionally. The fixtures supply it, and
  `test_qualification_rejects_companion_without_entry_helper` refuses a
  candidate that lacks the entry helper.
- **Pinned assembly.** A temporary-repository class covers `stage_helpers`:
  - exact-revision bytes win over a working-tree edit;
  - an abbreviated or non-commit revision is refused;
  - a missing or aliased runtime setup is refused;
  - an existing destination member is refused.
- **Installer.** The header and `usage()` name `--archive <absolute-file>`,
  and the rows state its plan basis. A Linux-only case shows the explicit
  archive selected, and a relative path, a symlink and a mismatched name
  refused.

  A note, not a finding: the case's "newer" archive sits outside the
  installer's search directories. It proves the explicit path is honored,
  since without it the run finds no archive and fails. Precedence over a
  discoverable newer archive follows from the if/else itself.
- **Record operation.** It qualifies a same-directory temporary file, then
  publishes it with a no-clobber link and removes the temporary file on any
  failure. `tarfile.TarError` is a refusal. Two new cases cover both.
- **Retention.** The unused, non-idempotent cplx `stage` is removed. The
  consumer owns staging, and cplx keeps selection and readiness-gated
  promotion, as the rows now say.

Architecture: no violation, and a single owner for retention staging. No
architecture fix is needed.

Performance: unchanged from round 1. No performance fix is needed.

Unit test coverage: no class hierarchy was added, and every top-level function
is referenced by a test, including `stage_helpers` and the installer option.
No unit-tested class is below 100%, and no top-level symbol outside the gate is
unreferenced.

Validation plan effects:

The reviewer added the Yes-only `## Analysis of Step 4 Implementation` summary
after `Feature integrity for Step 4`, where Steps 1 to 3b keep theirs. The
requestor's rows had omitted it, and the implementation-check format requires
it on a Yes verdict. The summary restates the staged behavior only. No verdict,
evidence row, other step or umbrella row changed.

### Pre-repair mandatory checks and coverage for step 4 deploy-venv-sync (exchange 1) (round 2)

The resolved validation set is requestor evidence, and the reviewer did not
rerun it. Reviewer evidence:

- `ghog check`: exit 0, lint clean, covering the edited installer.
- `ghog affected --no-cov`: not run, since cplx is not a pytest project.
- `commit-plan-check.bat --format json`: `valid`, ready, before and after the
  reviewer patch.
- `git diff --cached --check` and the installed pre-commit hook: exit 0.

### Resolved validation set and sources for step 4 deploy-venv-sync (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 4` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 4` (source: plan).
- `shellcheck -x -S style` on the verify, acceptance and installer scripts (source: request).
- `bash .git/hooks/pre-commit` (source: request).
- `git diff --cached --check` (source: request).
- Debian 12 agent full-mode build 210 with publication off (source: request).

### Resolver drift and direction for step 4 deploy-venv-sync (exchange 1) (round 2)

No drift. The project floor and the Step 4 plan commands match. The request
additions only add checks. Build 210 remains valid packaging evidence, since
the round 2 repairs changed no consumer packaging bytes.

### Repository state around validation for step 4 deploy-venv-sync (exchange 1) (round 2)

The index tree was `e92e0e777b2fd5829bf43c31387b03adadcd5817` at request time
and at review entry. After the reviewer's validation-plan patch it is
`d65660186c8e5201b0417211069e5131fb61adb1`. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison reports one tracked
difference, the validation plan, confined to the Step 4 summary and
attributed to the reviewer. The only unstaged change is the protocol
transcript.

### Repair inventory for step 4 deploy-venv-sync (exchange 1) (round 2)

Repairs made:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: added the
  missing `## Analysis of Step 4 Implementation` summary after the Step 4
  feature-integrity row. The patch was attributed cleanly and staged.
- Classification: polishing-only review metadata. It changes no code, test,
  acceptance behavior, verdict or commit grouping.

Paths staged:

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv_archive.py`
- `src/setups/env/bin/deploy_venv_inputs.py`
- `src/setups/env/bin/deploy_venv_release.py`
- `src/setups/env/bin/install_pkg.sh`
- `tests/unit/deploy_venv_sync/test_archive_recovery/__init__.py`
- `tests/unit/deploy_venv_sync/test_archive_recovery/test_archive_recovery_tdd.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`

### Commit plan assessment for step 4 deploy-venv-sync (exchange 1) (round 2)

The independent `commit-plan-check.bat --format json` run returned `valid`,
`ready: true` and no diagnostics, before and after the reviewer patch. Two
ordered groups hold all ten staged paths: behavior and tests first, then the
validation plan alone with the required subject. `a.commit` remains accurate;
the reviewer did not amend it.

### Findings and boundaries for step 4 deploy-venv-sync (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 4 deploy-venv-sync (exchange 1) (round 2)

No rework is required. If the human selects Commit, stage the protocol
transcript with the final group as the workflow prescribes. Then run the hook
and the commit-plan check once more on the final index.

Optionally, in a later change, move the installer case's "newer" archive into
one of the installer's search directories, so it also proves precedence over a
discoverable archive.

### Decision rationale for step 4 deploy-venv-sync (exchange 1) (round 2)

All six readiness-floor results pass:

- exact identity;
- complete implementation, with every round 1 Missing work item closed;
- validation and coverage: the reviewer's `ghog check` is green, the new
  behaviors have cases, and the requestor's RHEL verifier and acceptance ran
  on the repaired bytes;
- attributable staged scope: the only reviewer change is a polishing-only
  summary;
- no unresolved finding;
- accurate `a.commit`.

The recommendation is commit-ready. It is advisory and does not authorize a
commit.

### Final reviewer decision for step 4 deploy-venv-sync (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-4-round-2 -->

## Round 2 by human - Step 4 - human-confirmation

- Recorded: 2026-09-25T14:51:21+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 1 by requestor - Step 5

- Recorded: 2026-09-30T10:51:10+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 5
- Outcome: request

### Review identity for step 5 deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 5
Review round: 1

### Code review evidence for step 5 deploy-venv-sync (round 1)

request_index_tree: 3e652854e00595208c25a9a0766ef62079b4c3ed
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 5 --python /absolute/authoring/python --app-repo /absolute/consumer (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 5 --python /absolute/tools/python/bin/python3 --tools-prefix /absolute/tools --application-root /absolute/application --manifest /absolute/release/manifest.json --profile /absolute/release/profile.json --evidence-root /absolute/evidence --selection-profile /absolute/release/selection.json --helper /absolute/release/helpers/tools_env_manifest.py --runtime-setup /absolute/release/helpers/runtime_env.sh --serialization-attestation /absolute/release/serialization.json --project application --release-record /absolute/release/release-inputs.txt --companion /absolute/release/companion.tar --application-archive /absolute/release/application.tar --tools-archive /absolute/release/tools.tar.gz --entry /absolute/release/entry.sh --ci-evidence /absolute/release/ci-evidence.json --coverage /absolute/release/coverage.xml --required-archive-member application/pyproject.toml (sources: plan)
- git diff --cached --check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: chore(vscode): set inactive status bar color
group 1 path: .vscode/cplx.code-workspace
group 2: feat(deploy-venv-sync): validate CI evidence
group 2 path: src/setups/env/bin/deploy_venv_release.py
group 2 path: tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py
group 2 path: tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py
group 2 path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
group 2 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 2 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 3: docs(deploy-venv-sync): preserve stage agents
group 3 path: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
group 3 path: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
group 3 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
group 4: docs(deploy-venv-sync): record step 5 validation
group 4 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: .vscode/cplx.code-workspace
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_release.py
staged path: tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py
staged path: tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
```

### Requestor assessment for step 5 deploy-venv-sync (round 1)

Yes. Step 5 has been fully implemented.

The assessment covers implementation plan Step 5 only, including the later
human-approved orchestration and validation amendments. The validation plan
records the source, architecture, performance, unit-exercise and feature
integrity assessment. Steps 6 and 7 and the overall effort remain incomplete.

The staged shared helper and tests match the retained native cumulative
verification (217 tests plus syntax, shell and line-budget gates) and native
acceptance. Current cplx check.bat passes the repository Bash lint floor.
Consumer local validation is check.bat only under explicit human direction;
local groundhog, full-suite and duration gates were deferred. Actual Jenkins
tests, coverage and quality checks remained enabled.

Private qualification binds exact sources, complete consoles/artifacts,
independent phase observations, ABI/provider evidence, ordered failures,
adverse runtime and workspace cases, actual publication refusal, restored
defaults and original-candidate retention. Review those retained records via
the writer notes; public content intentionally omits private identities.

cplx has no Python coverage configuration. The consumer 100% gate measures its
configured application source, excluding CI helpers. Static references include
module-level uses and framework registration; every affected unmeasured
implementation symbol is referenced. No percentage is attributed to those
modules. No architecture, performance, file-size or feature-integrity issue was
identified in the checked step.

The repository-wide Markdown check reports existing findings outside the
changed documents. The focused changed-document check passes; no full-repository
Markdown pass is claimed. The mandatory repository lint gate is green.

### Implementation report for step 5 deploy-venv-sync (round 1)

Step 5 binds combined-CI eligibility to the exact qualified application,
toolchain, entry script, companion, selection profile and phase 1 coverage.
The shared release helper rejects stale or incomplete observations, ambiguous
evidence, identity drift, dependency failures and missing or failed independent
test-session outcomes. The native verification and acceptance entry points now
cover Step 5, with focused evidence mutations in the public unit-test tree.

The consumer owns direct orchestration of the mandated stage behavior, with
stage-local workspace agents, sandbox-safe script receivers and copied SCM
configuration. It preserves checks, stage order, the audited Test commands,
coverage transfer, analysis, quality and dry-run publication. The shared
library stays unchanged. This qualifies the approved consumer workaround;
it does not claim infrastructure repair or qualification of the original
shared-library wrapper.

The actual command adapter uses the named shipped environment and independent
phase 2 observation. Retained negative executions establish failure handling,
while runtime/workspace cases establish correct selection and reuse. The
publication-override launcher and child establish actual guard execution.
Temporary selections and launcher code are removed before the final default
success. The original pending candidate is compared against every byte in its
approved immutable index after that success.

Public requirement, design and plan wording records the human amendments and
the local check-only validation boundary. The validation plan assesses Step 5
without completing the later promotion or rollout steps.

Writer notes: `.reviews/a.deploy-venv-sync.step5.journal.md` and
`.reviews/a.deploy-venv-sync.step5.handoff.md`.

### Change summary for step 5 deploy-venv-sync (round 1)

The root `a.commit` groups every staged path in dependency order. The separate
workspace preference is an existing unrelated change preserved for its own
commit. The completed Step 5 validation is the trailing documentation group.

- `chore(vscode): set inactive status bar color`
  - `.vscode/cplx.code-workspace`
- `feat(deploy-venv-sync): validate CI evidence`
  - `src/setups/env/bin/deploy_venv_release.py`
  - `tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py`
  - `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py`
  - `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`
  - `docs/v0.27.0/verify.deploy-venv-sync.sh`
  - `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs(deploy-venv-sync): preserve stage agents`
  - `docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md`
  - `docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md`
  - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md`
- `docs(deploy-venv-sync): record step 5 validation`
  - `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`

No private consumer source or integration evidence is part of the cplx index.
The request's typed index-tree evidence identifies the exact staged snapshot.
No cplx commit has been created.

### Human guidance and writer response for step 5 deploy-venv-sync (round 1)

Human guidance:

The human authorized review submission only. Do not start or message a
counterpart, and do not commit cplx. Review and human commit approval remain
separate gates.

Preserve the working consumer's direct mandated_pipeline-like orchestration. Do not
restore the shared pipeline call, idle outer tools allocation, or redundant
outer Python allocation around the actual Test agent. Keep agents for steps
that require workspaces, explicit script receivers in audited closures, and
SCM remote configuration copied through whitelisted getters into maps.

Consumer local validation is check.bat only: no local ghog/day, full suite or
test-duration gate. Actual Jenkins validation remains required and retained.
Do not repeat successful builds or tests to compensate for evidence-download
failures. Preserve original frozen candidate bytes and all private evidence.

The validation-command forms use generic absolute-input placeholders for
private native environments. Exact executed commands and qualified input
identities are retained in the ignored writer notes. Keep private names,
paths, endpoints, revisions and build evidence out of tracked review prose.
The separate editor-workspace group preserves an unrelated existing change.

Writer response:

This is the first request for implementation Step 5. No reviewer answer or
repair for this step has been received, and no disagreement is asserted.

The human's later amendments supersede the older outer-agent orchestration
and local full-suite workflow instructions. The request preserves direct
orchestration, its validated sandbox corrections and the approved test and
analysis settings. Temporary probe removal does not revert that architecture.

### Reviewer focus for step 5 deploy-venv-sync (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-5-round-1 -->

## Round 1 by reviewer - Step 5

- Recorded: 2026-09-30T11:09:22+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: answer

### Assessed index identity for step 5 deploy-venv-sync (exchange 1) (round 1)

Baseline index tree: 3e652854e00595208c25a9a0766ef62079b4c3ed

Assessed index tree: 09baeb84141af210646418ca4e157f863990ccd0

### Implementation check for step 5 deploy-venv-sync (exchange 1) (round 1)

Result:

No. Step 5 has NOT been fully implemented.

The shared eligibility validator, its `ci-check` entry point and the Step 5
extensions of the native verification and acceptance scripts match plan item 8
and the tests-first list. The retained private records cover the positive
qualification, the runtime and workspace matrix, the actual publication-override
refusal, the restored default build and byte-identical retention of the original
pending candidate in the approved non-release store, all under the approved
direct orchestration.

Two gaps keep the step open. First, the deliberate-failure qualification that
design Q06 and plan item 6 require (dependency sync failure, install failure, a
masked failing test and disabled observation) was executed only under the
earlier wrapper-based orchestration. The human then approved direct
orchestration of the preserved stages, and every qualifying build ran that new
orchestration; no record shows that the fault conclusions carry over to it.
Second, `validate_ci_evidence` has rejection statements that no unit test
reaches, including the check that publication stayed `dry-run`, and it accepts
a boolean `true` schema.

The staged specification amendments leave AC10b requiring "unchanged mandated
stages", and they do not bind the copied stage bodies to the library revision
they mirror. The validation plan's Step 5 expectations were replaced by an
implementation summary instead of being amended.

Architecture: the validator stays in the existing technical helper, with no
new class hierarchy and no layer violation. The one architecture item is the
unbound copy of the mandated stage bodies. Performance: fixed key-set checks
and linear scans over explicit inputs; no quadratic path. Line budgets: the
helper has 363 lines and the new test 152, both under 650.

The reviewer recorded this verdict in the Step 5 rows of the validation plan,
with a `### Missing work for Step 5` section.

Validation plan effects:

The reviewer changed only the Step 5 rows of the validation plan, as the
reviewer-mode implementation-check allows: the No verdict and its summary, a
`### Missing work for Step 5` section, the architecture, unit test coverage and
feature integrity conclusions, and removal of the Yes-only analysis section.
The document-level status stays `No, it is not implemented.`, and no other step
and no umbrella row changed.

### Pre-repair mandatory checks and coverage for step 5 deploy-venv-sync (exchange 1) (round 1)

The reviewer ran its two permitted evidence commands once each, from the
project root, with the log-freshness proof.

- `ghog check`: exit 0. The repository shell lint is clean on 59 tracked
  scripts.
- `ghog affected --no-cov`: exit 9, not applicable, because cplx is not a
  pytest project. This is recorded as unavailable focused evidence, not as a
  pass. The validator's unit tests run through the native cumulative
  verification, which the requestor owns and reports as green.
- `git diff --cached --check`: exit 0 on the received index.

The unit test assessment is static, as the implementation-check requires.

### Resolved validation set and sources for step 5 deploy-venv-sync (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 5 --python <selected-python> --app-repo <consumer-root>` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 5 ...` with the
  delivered toolchain, release record, companion, archive pair, entry script,
  combined-CI evidence and phase 1 coverage inputs (source: plan).
- `git diff --cached --check` (source: request).

### Resolver drift and direction for step 5 deploy-venv-sync (exchange 1) (round 1)

No drift. The request's four commands match the plan's Step 5 command forms,
the project lint gate and the request's staged-diff check. The reviewer did
not run the set; the requestor owns it. The request records the native
cumulative verification (217 tests) and acceptance on the unchanged validator.
The plan's former consumer groundhog requirement is replaced, in the staged
plan amendment, by the human-directed local check-only boundary.

### Repository state around validation for step 5 deploy-venv-sync (exchange 1) (round 1)

The index tree was `3e652854e00595208c25a9a0766ef62079b4c3ed` at request time
and at review entry. After the reviewer staged its Step 5 validation rows, the
assessed tree is `09baeb84141af210646418ca4e157f863990ccd0`. The umbrella digest
is unchanged (`46b95d18...`). The validation-state comparison reports one
tracked difference, the validation plan, confined to the Step 5 rows and
attributable to the reviewer; the only ignored differences are the reviewer's
own ghog logs. The only unstaged change is the protocol transcript.

### Repair inventory for step 5 deploy-venv-sync (exchange 1) (round 1)

Repairs made:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: review
  metadata, not substantive. The reviewer-mode implementation-check rewrote
  only the Step 5 rows: the status sentence and summary now read No, a
  `### Missing work for Step 5` section lists F1 to F6, the architecture and
  unit test coverage conclusions record F5 and F2, the feature integrity
  paragraph limits the fault evidence to the earlier orchestration, and the
  Yes-only `## Analysis of Step 5 Implementation` section is removed. The
  patch is attributable and staged. No implementation code, test, script or
  specification was changed.

Paths staged:

- `.vscode/cplx.code-workspace`
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (includes the
  reviewer's Step 5 rows)
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv_release.py`
- `tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py`
- `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`

### Commit plan assessment for step 5 deploy-venv-sync (exchange 1) (round 1)

The independent `commit-plan-check.bat --format json` run returned state
`valid`, `ready: true` and no diagnostics for all eleven staged paths in four
ordered groups: the unrelated workspace preference, the validator with its
tests and native entry points, the specification amendments, and the
validation plan alone. The rerun after staging the reviewer's validation rows
is still `valid` and ready. Membership, order and subjects remain accurate, and
the reviewer did not amend `a.commit`. The group 4 message body describes a
completed step; the writer should refresh it after the rework.

### Findings and boundaries for step 5 deploy-venv-sync (exchange 1) (round 1)

Unresolved findings:

- F1 (blocking): the deliberate-failure qualification required by design Q06
  and plan item 6 ran only under the earlier wrapper-based orchestration. The
  qualifying positive, override and default builds all ran the later direct
  orchestration, and no record shows that the fault conclusions carry over.
  The validation plan's feature integrity claim was therefore unsupported for
  the qualifying orchestration.
- F2 (blocking): `validate_ci_evidence` has rejection statements that no unit
  test reaches: the duplicate-key hook, the top-level and section key-set
  checks, the build-result check, the analysis, quality and `dry-run`
  publication status check, and the profile digest format check. Phase 1
  identity drift, before-command inventory drift, a symlinked coverage report
  and mistyped dependency statuses are also not exercised.
- F3 (blocking): `validate_ci_evidence` accepts `"schema": true`, because
  `True != 1` is false in Python. The session and dependency statuses are
  already typed strictly; the schema is not.
- F4 (blocking): AC10b in the requirement still requires "unchanged mandated
  stages", which contradicts the staged amendment to direct orchestration of
  the preserved stages.
- F5 (blocking): the staged design and plan amendments copy the mandated stage
  bodies into the consumer without binding the copy to the library revision it
  mirrors, or requiring re-audit and re-qualification after a library change.
- F6 (blocking): the validation plan's "Step 5 improvement expectations" were
  replaced by an implementation summary. The planned checklist, including the
  item 9 order and the phase 1 coverage identity expectation, is no longer
  visible to the reviewer.
- F7 (blocking, AC13): the round 1 request carries two private identifiers
  that its transcript append has already copied into the tracked review
  transcript: the private library's name in the human guidance paragraph, and
  a consumer-named runtime helper file in the acceptance command form of the
  resolved validation set. Neither appears in any committed cplx file. This
  answer does not repeat them.

Boundary-crossing work:

- The F1 route is a human decision: new fault-probe builds under the direct
  orchestration, or an accepted equivalence proof. The reviewer does not
  choose it.
- Releasing a pending candidate at promotion or abandonment belongs to Step 6
  and is not assessed here.

### Human guidance response for step 5 deploy-venv-sync (exchange 1) (round 1)

Human guidance:

The human authorized review submission only. Do not start or message a
counterpart, and do not commit cplx. Review and human commit approval remain
separate gates.

Preserve the working consumer's direct [private library name redacted by the
reviewer, see F7]-like orchestration. Do not
restore the shared pipeline call, idle outer tools allocation, or redundant
outer Python allocation around the actual Test agent. Keep agents for steps
that require workspaces, explicit script receivers in audited closures, and
SCM remote configuration copied through whitelisted getters into maps.

Consumer local validation is check.bat only: no local ghog/day, full suite or
test-duration gate. Actual Jenkins validation remains required and retained.
Do not repeat successful builds or tests to compensate for evidence-download
failures. Preserve original frozen candidate bytes and all private evidence.

The validation-command forms use generic absolute-input placeholders for
private native environments. Exact executed commands and qualified input
identities are retained in the ignored writer notes. Keep private names,
paths, endpoints, revisions and build evidence out of tracked review prose.
The separate editor-workspace group preserves an unrelated existing change.

Guidance response:

The human guidance was applied as written. The reviewer started and messaged
no counterpart, made no commit, and treated the direct stage-local
orchestration, its sandbox corrections and the local check-only boundary as
approved. No finding asks to restore the shared pipeline call, the outer tools
allocation or the redundant outer Python allocation.

F1 asks for fault evidence under that approved orchestration; it does not
question the orchestration itself. It does not ask to repeat any successful
build or test: its first route adds four short failure builds that do not
exist yet, and its second route needs no build. Private names, paths,
endpoints, revisions and build evidence stay out of this answer. The guidance
is reproduced with the private library name redacted; see F7.

### Writer instructions for step 5 deploy-venv-sync (exchange 1) (round 1)

- F1: ask the human to choose between two routes, and record the choice.
  Either run the four probe-only faults (sync failure, install failure,
  failing test, disabled observation) against the direct orchestration, one
  short build each, capturing each failed combined build with no publication,
  then remove the fault selection and keep the default green. Or, if the human
  accepts equivalence instead of new builds, add a bounded private proof that
  the Test-stage command body, the adapter hook and the observer wiring are
  byte-identical between the probed and the qualifying orchestration, and
  that the failure reaches the combined result through the same path. Either
  way, state in the validation plan which orchestration carried the fault
  evidence.
- F2: add subtests in `test_ci_evidence_tdd.py` for each unreached branch
  listed in F2. Include `publish_status` values such as `"success"` and
  `"skipped"`, a build `result` of `"FAILURE"`, a phase `status` of
  `"failure"`, a duplicate key written as raw JSON text, a missing and an
  extra key at top level and in one section, a malformed profile digest, a
  changed candidate `record_sha256`, phase 1 tool, helper and profile drift,
  `inventory_before_sha256` drift, a coverage symlink, and `sync_status` and
  `install_status` set to `false` and `0.0`.
- F3: require `type(data["schema"]) is int and data["schema"] == 1`, and add
  a `true` schema subtest.
- F4: amend AC10b so it describes direct orchestration of the preserved
  mandated stages, in the same wording as the staged amendment.
- F5: in the design's Two-phase CI integration section and plan Step 5 item 1,
  state that the directly orchestrated stage bodies mirror a recorded library
  revision, that each qualification records it, and that a library change
  requires a re-audit of the copy and a new qualification. Keep the concrete
  revision private.
- F6: restore the planned Step 5 improvement expectations, amending only the
  sentences the human amendments changed, such as the phase 2 test scope and
  the local check-only boundary.
- F7: in the replacement request, write the guidance paragraph with public
  vocabulary ("the mandated pipeline", "direct stage orchestration") and give
  the runtime helper a generic placeholder in the command form. Before the
  final commit, have the round 1 transcript entry sanitized through the
  workflow's approved route, and confirm that the sensitive pre-commit hook
  rejects both identifiers; add them to the project's sensitive rules if it
  does not.
- After the fixes, rerun the implementation-check for Step 5, rerun the
  native cumulative verification and acceptance on the changed validator, and
  refresh the group 4 message body in `a.commit`: it currently describes a
  completed step.

### Decision rationale for step 5 deploy-venv-sync (exchange 1) (round 1)

The readiness floor fails on three of six results. Identity passes: the
envelope, request fields, plan, step, round and index tree agree. Staged
attribution passes: the only reviewer change is the attributable Step 5
validation rows. The mechanical `a.commit` result passes. Completeness fails
on F1 and F4 to F6. Validation and coverage fail on the static gaps in F2 and
the strictness defect in F3, and the reviewer's focused test command is not
applicable to cplx. Unresolved findings F1 to F7 remain; F7 is a public-record
defect in the request itself.

The disposition is changes-requested. The positive evidence is strong: the
qualifying default build, the actual publication-override refusal and the
retained original candidate are well bound. The open items are either cheap
test and wording fixes or one evidence question whose route is the human's
decision. This recommendation is advisory and authorizes nothing.

### Final reviewer decision for step 5 deploy-venv-sync (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-5-round-1 -->

## Round 2 by requestor - Step 5

- Recorded: 2026-09-30T15:28:54+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: request

### Review identity for step 5 deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 5
Review round: 2

### Code review evidence for step 5 deploy-venv-sync (round 2)

request_index_tree: cc600aeb6f8845082a2fd4ca5a2e5faba2c77b1b
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 5 --python /absolute/authoring/python --app-repo /absolute/consumer (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 5 --python /absolute/tools/python/bin/python3 --tools-prefix /absolute/tools --application-root /absolute/application --manifest /absolute/release/manifest.json --profile /absolute/release/profile.json --evidence-root /absolute/evidence --selection-profile /absolute/release/selection.json --helper /absolute/release/helpers/tools_env_manifest.py --runtime-setup /absolute/release/helpers/runtime_env.sh --serialization-attestation /absolute/release/serialization.json --project application --release-record /absolute/release/release-inputs.txt --companion /absolute/release/companion.tar --application-archive /absolute/release/application.tar --tools-archive /absolute/release/tools.tar.gz --entry /absolute/release/entry.sh --ci-evidence /absolute/release/ci-evidence.json --coverage /absolute/release/coverage.xml --required-archive-member application/pyproject.toml (sources: plan)
- git diff --cached --check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: chore(vscode): set inactive status bar color
group 1 path: .vscode/cplx.code-workspace
group 2: feat(deploy-venv-sync): validate CI evidence
group 2 path: src/setups/env/bin/deploy_venv_release.py
group 2 path: tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py
group 2 path: tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py
group 2 path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
group 2 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 2 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 3: docs(deploy-venv-sync): preserve stage agents
group 3 path: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
group 3 path: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
group 3 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
group 3 path: docs/v0.27.0/review.code.v0.27.0.deploy-venv-sync.md
group 4: docs(deploy-venv-sync): record step 5 validation
group 4 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: .vscode/cplx.code-workspace
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_release.py
staged path: tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py
staged path: tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py
staged path: tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py
```

### Requestor assessment for step 5 deploy-venv-sync (round 2)

Yes. Step 5 has been fully implemented.

The final implementation check records no remaining Step 5 implementation gap.
Independent review and the human cplx commit gate remain pending.

The schema and behavioral rejection findings are repaired. Native cumulative
verification passed 225 tests, native acceptance passed, and repository shell
lint passed on 59 scripts. The repaired validator also qualifies the retained
successful default evidence. Focused Markdown checks passed for the four
changed specification and validation documents.

Architecture remains within the existing release helper and consumer adapter
boundaries. The immutable library copy binding is explicit. Affected Python
files remain below the 650-line ceiling. Fixed key checks and linear scans over
explicit inputs introduce no quadratic path. The unit assessment maps each
added rejection to a behavioral mutation; no unreferenced top-level changed
implementation symbol remains. No Python coverage percentage is inferred for
the shared or consumer CI helpers.

Four actual controlled failures are qualified under the approved orchestration
with complete captures and exact source/console reviews. The restored-default
build passed both full approved suites and all required later stages. Complete
capture, ABI/provider and independent phase outcomes, exact analysis and strict
eligibility are accepted. Every frozen original-candidate byte remains identical
to its approved immutable index after that later successful build.

### Implementation report for step 5 deploy-venv-sync (round 2)

Step 5 adds a shared combined-CI eligibility validator. It binds the successful
build and both phases to the exact candidate, delivered inputs, selection
profile, dependency inventories and phase 1 coverage. Independent framework
observations expose failures hidden by the mandated shell command. Publication
must remain dry-run.

The consumer directly orchestrates the preserved mandated stages. Each active
stage owns its required workspace agent; audited test commands, checks,
coverage transfer, analysis, quality and dry-run publication remain. Explicit
script receivers and getter-copied SCM maps preserve sandbox compatibility.
The copy audit binds those stage bodies to their immutable library revision;
a revision change requires another audit and qualification.

Round 2 fixes schema typing and expands behavioral rejection tests. It also
aligns AC10b with direct orchestration, restores the planned validation
expectations and removes two private identifiers from the tracked transcript.
Local sensitive hooks now reject both identifiers, with generic prose accepted.

Native cumulative verification passed 225 tests. Native acceptance passed with
delivered toolchain inputs and poisoned ambient selections. Repository shell
lint passed on 59 tracked scripts. The consumer application coverage gate does
not measure CI helpers; static symbol and rejection-path assessment supplements
their dedicated tests without asserting a coverage percentage.

Actual direct-orchestration qualification now covers sync and install failures,
a masked failing test and disabled observation. Each complete capture binds the
original command outcomes and observer refusal to the exact source and loaded
library, with later stages not entered and publication disabled. The subsequent
default build passed all required stages with the full approved test selection,
quality OK and deployment explicitly skipped. Its complete capture, ABI and
phase audits, exact analysis and strict eligibility are accepted. The entire
restored source tree matches the accepted pre-probe tree, and every frozen
original-candidate byte matches the approved immutable index after that success.
The final implementation check is Yes.

The stage-local workaround does not claim infrastructure repair or validation
of the original wrapper. Operator promotion and final target rollout belong to
Steps 6 and 7. No cplx commit is authorized.

Writer notes: `.reviews/a.deploy-venv-sync.step5.journal.md` and
`.reviews/a.deploy-venv-sync.step5.handoff.md` contain the private evidence and
continuation record and may be read for this review.

### Change summary for step 5 deploy-venv-sync (round 2)

The root `a.commit` orders the complete twelve-path change set in four groups.
The canonical after-check handoff staged all twelve paths; grouped readiness
passed with four groups and the Step 5 validation record last.

- Independent workspace preference: `.vscode/cplx.code-workspace`.
- Shared eligibility and validation:
  `src/setups/env/bin/deploy_venv_release.py`,
  `tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py`,
  `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py`,
  `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`,
  `docs/v0.27.0/verify.deploy-venv-sync.sh` and
  `docs/v0.27.0/acceptance.deploy-venv-sync.sh`.
- Specification and review documentation:
  `docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md`,
  `docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md`,
  `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md` and
  `docs/v0.27.0/review.code.v0.27.0.deploy-venv-sync.md`.
- Step 5 validation record:
  `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`, as the final group.

Round 2 adds strict schema typing, rejection cases, immutable library-copy
binding and consistent planned expectations. It preserves all earlier staged
work and the unrelated workspace preference. cplx remains uncommitted.

### Human guidance and writer response for step 5 deploy-venv-sync (round 2)

Human guidance:

The human requests preparation and submission of round 2. Do not start or
message a reviewer, and do not commit cplx. Review and human commit approval
remain separate gates.

Preserve the approved direct orchestration: mandated checks, ordered stages,
audited test commands, coverage transfer, analysis, quality and dry-run
publication. Keep workspace agents scoped to active stages and preserve the
sandbox corrections and approved test and analysis settings. Removing probes
must preserve that architecture. Neither infrastructure repair nor validation
of the original outer wrapper is claimed.

Local consumer validation is check.bat only. Local full-suite, groundhog and
test-duration gates are deferred by the human; actual Jenkins validation
remains required. Private integration records remain outside public prose.

Writer response:

All seven findings from round 1 are accepted. The reviewer's Step 5 No verdict
and missing-work inventory were appropriate for the evidence available then.
No reviewer repair is reversed or disputed.

- F1: the existing human authorization for consumer fixes and normal
  commit/push/build workflows covers the actual fault-build route. The four
  faults are qualified on the approved direct orchestration through the
  existing probe selectors; no equivalence substitution is claimed. Complete
  captures and exact source/console reviews establish the original command
  outcomes, observer refusals and absence of publication. The subsequent
  restored-default build is successful and fully qualified. After that success,
  every frozen original-candidate byte matches the approved immutable index.
- F2: new behavioral rejection cases exercise duplicate keys, object shapes,
  build and phase failures, analysis/quality/publication outcomes, malformed
  profiles, identity and before-command inventory drift, missing or symlinked
  coverage and mistyped dependency statuses.
- F3: schema 1 now requires an integer. Boolean true and floating-point 1.0
  failed the new tests before the repair and are rejected afterward.
- F4: AC10b now requires direct orchestration of the preserved mandated stages.
- F5: design and plan bind copied stages to the immutable library revision
  they mirror; every qualification records it, and a change requires a fresh
  copy audit and qualification.
- F6: the planned expectations are restored, including the test-scope order,
  phase 1 coverage identity and observer boundaries, with the later human
  amendments stated explicitly.
- F7: the tracked transcript uses generic terminology for the two disclosed
  identifiers. Review-entry markers and live protocol records are preserved.
  Local sensitive rules and actual hook tests reject both identifiers; a
  generic control passes. Replacement request prose and command forms use
  generic paths and identifiers.

The native cumulative verification passed 225 tests, including the new
rejections, and native acceptance passed with delivered runtime inputs.
The replacement round contains substantive code and test repairs.

### Reviewer focus for step 5 deploy-venv-sync (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-5-round-2 -->

## Round 2 by reviewer - Step 5

- Recorded: 2026-09-30T15:35:08+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: answer

### Assessed index identity for step 5 deploy-venv-sync (exchange 1) (round 2)

Baseline index tree: cc600aeb6f8845082a2fd4ca5a2e5faba2c77b1b

Assessed index tree: cc600aeb6f8845082a2fd4ca5a2e5faba2c77b1b

### Implementation check for step 5 deploy-venv-sync (exchange 1) (round 2)

Result:

Yes. Step 5 has been fully implemented.

All seven round 1 findings are resolved in the staged tree, and the writer's
Step 5 validation rows are accurate.

- F1: the four probe-only faults (sync failure, install failure, a masked
  failing test and disabled observation) now ran under the approved direct
  orchestration. The private records show each one captured completely, with
  the approved orchestration unchanged apart from the fault selector, the
  loaded library revision recorded, the combined build failed, later stages
  not entered and publication disabled. A restored default build then passed
  every stage and was fully captured. Its source tree equals the accepted
  pre-probe tree, and every frozen byte of the original pending candidate still
  matches its immutable index.
- F2: new behavioral mutations reach every rejection statement of
  `validate_ci_evidence`. They cover duplicate keys, wrong shapes and key sets,
  failed build, phase, analysis and quality outcomes, a publication status
  other than `dry-run`, malformed profile digests, candidate and phase 1
  identity drift, before-command inventory drift, missing or symlinked
  coverage, and mistyped dependency statuses. I traced each assertion to the
  statement it targets, including its expected message.
- F3: the schema must now be the integer 1; booleans, `1.0`, strings and other
  values are rejected and tested.
- F4: AC10b now requires direct orchestration of the preserved mandated stages.
- F5: the design and plan item 1 bind the copied stage bodies to a recorded
  library revision and require a new audit and qualification after a change,
  keeping the concrete revision private.
- F6: the planned Step 5 expectations are restored, with the human amendments
  stated explicitly.
- F7: the staged transcript and the round 2 request contain no private
  identifier. The one consumer-prefixed function name left in older rounds is
  already committed in cplx sources.

Architecture: the validator stays in the existing technical helper, with no
new class hierarchy and no layer violation, and the copied stages are now
bound to their source revision. Performance: fixed key-set checks and linear
scans over explicit inputs. Line budgets: helper 365 lines, test 238, both
under 650.

Validation plan effects:

The reviewer made no edit to the validation plan in round 2. The writer's
Step 5 rows record the Yes verdict, the restored expectations, the fault
evidence under the qualifying orchestration and the unit mutation mapping,
and they are accurate. The document-level status stays
`No, it is not implemented.` because Steps 6 and 7 remain.

### Pre-repair mandatory checks and coverage for step 5 deploy-venv-sync (exchange 1) (round 2)

The reviewer ran its focused evidence once, from the project root, with the
log-freshness proof.

- `ghog check`: exit 0; the repository shell lint is clean.
- `ghog affected --no-cov`: not run again this round. It exits 9, not
  applicable, because cplx is not a pytest project; round 1 recorded that as
  unavailable evidence, not a pass.
- `git diff --cached --check`: exit 0 on the received index.

The unit assessment is static: each new mutation was traced to the rejection
statement and message it targets.

### Resolved validation set and sources for step 5 deploy-venv-sync (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 5 --python <selected-python> --app-repo <consumer-root>` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 5 ...` with the
  delivered toolchain, release record, companion, archive pair, entry script,
  combined-CI evidence and phase 1 coverage inputs (source: plan).
- `git diff --cached --check` (source: request).

### Resolver drift and direction for step 5 deploy-venv-sync (exchange 1) (round 2)

No drift. The four commands match round 1 and the plan's Step 5 command forms;
the runtime helper argument now uses a generic placeholder. The reviewer did
not run the set; the requestor owns it and reports native cumulative
verification (225 tests), native acceptance and the shell lint as green on the
repaired validator.

### Repository state around validation for step 5 deploy-venv-sync (exchange 1) (round 2)

The index tree was `cc600aeb6f8845082a2fd4ca5a2e5faba2c77b1b` at request time,
at review entry and after the assessment. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison over all twelve staged paths
is acceptable, with no tracked or untracked difference; only the reviewer's
own ignored ghog logs changed.

### Repair inventory for step 5 deploy-venv-sync (exchange 1) (round 2)

Repairs made:

- None. The reviewer made no repair and staged nothing in round 2.

Paths staged:

- `.vscode/cplx.code-workspace`
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/design.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/feature-request.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/review.code.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv_release.py`
- `tests/unit/deploy_venv_sync/test_ci_evidence/__init__.py`
- `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py`
- `tests/unit/deploy_venv_sync/test_release_inputs/test_release_inputs_tdd.py`

### Commit plan assessment for step 5 deploy-venv-sync (exchange 1) (round 2)

The independent `commit-plan-check.bat --format json` run returned state
`valid`, `ready: true` and no diagnostics for all twelve staged paths in four
ordered groups: the unrelated workspace preference, the validator with its
tests and native entry points, the specification amendments with the
sanitized review transcript, and the validation plan alone. Group 3's message
names the transcript's role, and group 4's message matches the Yes record.
`a.commit` remains accurate; the reviewer did not amend it.

### Findings and boundaries for step 5 deploy-venv-sync (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Human guidance response for step 5 deploy-venv-sync (exchange 1) (round 2)

Human guidance:

The human requests preparation and submission of round 2. Do not start or
message a reviewer, and do not commit cplx. Review and human commit approval
remain separate gates.

Preserve the approved direct orchestration: mandated checks, ordered stages,
audited test commands, coverage transfer, analysis, quality and dry-run
publication. Keep workspace agents scoped to active stages and preserve the
sandbox corrections and approved test and analysis settings. Removing probes
must preserve that architecture. Neither infrastructure repair nor validation
of the original outer wrapper is claimed.

Local consumer validation is check.bat only. Local full-suite, groundhog and
test-duration gates are deferred by the human; actual Jenkins validation
remains required. Private integration records remain outside public prose.

Guidance response:

The guidance was applied as written. The reviewer started and messaged no
counterpart and made no commit. It assessed the direct stage-local
orchestration, its sandbox corrections, the approved test and analysis
settings and the local check-only boundary as approved, and found them
preserved after probe removal. No finding asks to restore the outer wrapper.
Private integration details stay in the writer's ignored records.

### Writer instructions for step 5 deploy-venv-sync (exchange 1) (round 2)

No rework is required. If the human selects Commit, stage this round's
transcript append into group 3 with the rest of the review transcript, then run
the installed sensitive hook and the commit-plan checker once more against the
final index before committing.

### Decision rationale for step 5 deploy-venv-sync (exchange 1) (round 2)

All six readiness-floor results pass. Identity: the envelope, request fields,
plan, step, round and index tree agree. Completeness: the implementation-check
is Yes, and F1 is backed by complete actual-agent evidence under the
qualifying orchestration. Validation and coverage: the focused lint is green,
the static mapping reaches every rejection statement, and the requestor's
native verification and acceptance are green. Staged attribution: the reviewer
made no repair. Unresolved findings: none. `a.commit`: valid, ready and
accurate.

The recommendation is commit-ready. It is advisory and does not authorize a
commit; the Commit or Rework choice belongs to the human.

### Final reviewer decision for step 5 deploy-venv-sync (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-5-round-2 -->

## Round 2 by human - Step 5 - human-confirmation

- Recorded: 2026-09-30T15:43:06+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 1 by requestor - Step 6

- Recorded: 2026-09-30T18:45:53+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 6
- Outcome: request

### Review identity for step 6 deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 6
Review round: 1

### Code review evidence for step 6 deploy-venv-sync (round 1)

request_index_tree: f87c67644caed9536de94d7990c5ca86394edbae
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 6 --python /absolute/authoring/python --app-repo /absolute/consumer (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 6 --python /absolute/operator/python --operator /absolute/operator --candidate-manifest /absolute/candidate.json --qualification-record /absolute/qualification.json --release-config /absolute/operator-config.json --evidence-root /absolute/evidence (sources: plan)
- bash -n docs/v0.27.0/verify.deploy-venv-sync.sh (sources: plan)
- bash -n docs/v0.27.0/acceptance.deploy-venv-sync.sh (sources: plan)
- shellcheck docs/v0.27.0/verify.deploy-venv-sync.sh docs/v0.27.0/acceptance.deploy-venv-sync.sh (sources: plan)
- ghog day (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy-venv-sync): bind qualified releases
group 1 path: src/setups/env/bin/deploy_venv_publication.py
group 1 path: src/setups/env/bin/deploy_venv_release.py
group 1 path: tests/unit/deploy_venv_sync/test_release_promotion/__init__.py
group 1 path: tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py
group 1 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 1 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 2: docs(deploy-venv-sync): record step 6 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_publication.py
staged path: src/setups/env/bin/deploy_venv_release.py
staged path: tests/unit/deploy_venv_sync/test_release_promotion/__init__.py
staged path: tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py
```

### Requestor assessment for step 6 deploy-venv-sync (round 1)

Step 6 is fully implemented. The validation plan records the exact eligibility,
publication, retained-input and backend acceptance evidence. Production promotion
and final target qualification remain Step 7.

The native cumulative harness passed 240 tests in 33.137 seconds, syntax,
ShellCheck and the 650 physical-line ceiling. The project groundhog walk reached
its documented non-pytest exit 9; the native harness supplies the applicable
project verification. The consumer groundhog walk passed check, affected tests
and all 6,662 full-suite tests with zero failures, 100% configured application
coverage and zero duration outliers. That coverage percentage does not cover the
standalone operator or reusable helpers; their functional cases are reported
separately. Fifteen publication test methods and seventeen consumer adapter cases
cover qualification binding, mutation, transport and receipt boundaries.

All five live backend cases passed: complete publication, partial-upload retry,
manifest retry, conflicting bytes and predecessor retention. Direct conflicting
redeployment failed and preserved the original bytes. All owned test components
were subsequently deleted and all associated assets verified absent. The backend
receipt is historical evidence; production retention checks still run on each
promotion. Administration policy was unavailable and is not claimed as observed.

The architecture keeps qualification and exact-byte ordering reusable while the
private adapter owns credentials, repository coordinates and Maven invocation.
All changed Python files remain below 550 physical lines. Source/reference audit
found no unused added top-level symbols or new hierarchy. Snapshotting is linear
in payload bytes, with necessary integrity-boundary rereads. Feature-integrity
review found no rebuild, deployment, CI invocation or toolchain republishing in
the operator path. Existing publisher semantics and unrelated consumer changes
are preserved. A narrowly profiled property-test sample budget was corrected to
the existing default without changing strategies or assertions.

Because a bundled helper changed, final promotion needs a newly qualified
candidate; the previously frozen companion must not be patched or relabeled.

### Implementation report for step 6 deploy-venv-sync (round 1)

Added a reusable publication module and eligibility CLI. The validator binds
completed qualification and CI evidence to exact candidate, toolchain and both
predecessor forms. It freezes validated bytes, checks retained remote inputs,
supports equal-byte retry, refuses conflicts, and publishes the generated binding
last after full readback. Tests include evidence mutation during validation,
interrupted upload and manifest failure.

The private operator wraps the existing workstation publisher with explicit
inputs and existing credentials. Exact-byte staging preserves destination
extensions with the existing Maven plugin. Repository-bound backend receipts
remain valid after authorized disposal of test markers. Current and predecessor
retention remains independently mandatory. The cumulative verifier and acceptance
entry now expose Step 6, including the five actual backend cases.

Both public and private changes are staged with checked two-group commit plans.
The public validation record is complete for Step 6. Private mappings, commands,
coordinates, run identities, cleanup receipts and the consumer staged inventory
are available through the writer notes. No production publication or commit has
been performed. Private files and evidence must not be copied to this transcript.

Writer notes: .reviews/a.deploy-venv-sync.step6.journal.md; .reviews/a.deploy-venv-sync.step6.handoff.md

### Change summary for step 6 deploy-venv-sync (round 1)

The public index contains seven paths:

- src/setups/env/bin/deploy_venv_publication.py
- src/setups/env/bin/deploy_venv_release.py
- `tests/unit/deploy_venv_sync/test_release_promotion/__init__.py`
- `tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py`
- docs/v0.27.0/verify.deploy-venv-sync.sh
- docs/v0.27.0/acceptance.deploy-venv-sync.sh
- docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md

The checked root a.commit contains two groups:

1. feat(deploy-venv-sync): bind qualified releases (the six source, test and script paths).
2. docs(deploy-venv-sync): record step 6 validation (the validation document).

The private consumer has seven intended staged paths and a checked two-group
commit plan: the bounded property-test correction, followed by the operator,
publisher integration and tests. Its exact path inventory and evidence remain
private in the writer handoff. Five unrelated untracked paths remain unstaged.

### Writer response for step 6 deploy-venv-sync (round 1)

Writer response:

Initial Step 6 review request; no prior feedback or disagreement in this exchange.
The user's latest direction permits disposable release test artifacts when
deletion is supported and requires cleanup after success. Actual snapshot testing
showed overwrite was allowed, so immutable-release acceptance used deletable,
isolated test versions. Cleanup is complete and verified.

Please assess the public step and its required private operator integration using
the writer notes. Preserve private identifiers in private evidence. Use retained
backend results rather than recreating deleted fixtures. Step 7's production
action remains pending and requires newly qualified exact candidate bytes.

### Reviewer focus for step 6 deploy-venv-sync (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-1 -->

## Round 1 by reviewer - Step 6

- Recorded: 2026-09-30T18:55:19+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 deploy-venv-sync (exchange 1) (round 1)

Baseline index tree: f87c67644caed9536de94d7990c5ca86394edbae

Assessed index tree: 17aec48a2c3d4eda5a5c80dda9b34a60451f4974

### Implementation check for step 6 deploy-venv-sync (exchange 1) (round 1)

Result:

No. Step 6 has NOT been fully implemented.

Most of the step is in place and well evidenced. The new publication module
binds a retained, unexpired candidate to successful combined CI and six
complete qualification results, including both predecessor forms. It freezes
the validated bytes before any transport, requires the toolchain and
predecessors to be retained already, refuses conflicts, verifies every
uploaded object by full read-back, and exposes the binding manifest last. The
tests-first list is covered by fifteen methods with a failure-injecting
backend. The private writer notes record five actual backend cases (complete
publication, interrupted pair, failed binding, conflicting bytes, missing
retained inputs) and a direct conflicting redeployment that the backend
refused, with verified cleanup of every disposable test component.

Three gaps keep the step open:

- `deploy_venv_release.py` is a delivered member of the target companion, and
  its new `publication-check` operation loads `deploy_venv_publication.py`.
  That module is not in `HELPER_SOURCES` in `deploy_venv_inputs.py` or in the
  plan's helper closure list, which requires rejecting "unlisted executable
  dependencies". The dependency also points from target-delivered code to
  operator-only code.
- The plan's Step 6 file list and line-budget checkpoint do not include the
  new module.
- Several safety branches of the new module have no unit test: the refusal of
  `SNAPSHOT` coordinates (the writer's own backend run showed that snapshot
  coordinates accept overwrites), an announced manifest whose retained object
  is missing, a manifest read-back mismatch, empty qualification evidence, an
  expiry without a timezone, an unsafe evidence root and a non-path input.

Architecture: apart from the dependency above, qualification and publication
order are credential-free, and the transport is a two-operation port supplied
by the private operator. Performance: linear in payload bytes with explicit
integrity rereads. Line budgets: release helper 375, publication module 227,
test 258, all under 550.

The reviewer recorded this verdict in the Step 6 rows of the validation plan,
with a `### Missing work for Step 6` section.

Validation plan effects:

The reviewer changed only the Step 6 rows of the validation plan: the No
verdict and its summary, a `### Missing work for Step 6` section, the
architecture and unit test coverage conclusions, and removal of the Yes-only
analysis section. The document-level status stays `No, it is not implemented.`,
and no other step and no umbrella row changed.

### Pre-repair mandatory checks and coverage for step 6 deploy-venv-sync (exchange 1) (round 1)

The reviewer ran its focused evidence once, from the project root, with the
log-freshness proof.

- `ghog check`: exit 0; the repository shell lint is clean.
- `ghog affected --no-cov`: not applicable, because cplx is not a pytest
  project (exit 9, recorded as unavailable evidence, not a pass).
- `git diff --cached --check`: exit 0 on the received index.

The unit assessment is static: each rejection statement of the new module was
checked against the public suite.

### Resolved validation set and sources for step 6 deploy-venv-sync (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 6 --python <selected-python> --app-repo <consumer-root>` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 6 ...` with the
  explicit operator, candidate manifest, qualification record, private
  configuration and evidence root (source: plan).
- `bash -n` on both entry scripts and `shellcheck` on both (source: plan).
- `ghog day` (source: plan).

### Resolver drift and direction for step 6 deploy-venv-sync (exchange 1) (round 1)

No drift. The seven commands match the plan's Step 6 command forms and the
project lint gate. The reviewer did not run the set; the requestor owns it and
reports native cumulative verification (240 tests), the cplx walk at its
documented non-pytest exit 9, the consumer walk green at 100% of its measured
scope, and the actual backend acceptance with verified cleanup.

### Repository state around validation for step 6 deploy-venv-sync (exchange 1) (round 1)

The index tree was `f87c67644caed9536de94d7990c5ca86394edbae` at request time
and at review entry. After the reviewer staged its Step 6 validation rows, the
assessed tree is `17aec48a2c3d4eda5a5c80dda9b34a60451f4974`. The umbrella digest
is unchanged (`46b95d18...`). The validation-state comparison reports one
tracked difference, the validation plan, confined to the Step 6 rows and
attributable to the reviewer; the only ignored differences are the reviewer's
own ghog logs. The only unstaged change is the protocol transcript.

### Repair inventory for step 6 deploy-venv-sync (exchange 1) (round 1)

Repairs made:

- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`: review
  metadata, not substantive. The reviewer-mode implementation-check rewrote
  only the Step 6 rows: the status sentence and summary now read No, a
  `### Missing work for Step 6` section lists F1 to F3, the architecture and
  unit test coverage conclusions record F1 and F3, and the Yes-only
  `## Analysis of Step 6 Implementation` section is removed. The patch is
  attributable and staged. No implementation code, test or script changed.

Paths staged:

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` (includes the
  reviewer's Step 6 rows)
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv_publication.py`
- `src/setups/env/bin/deploy_venv_release.py`
- `tests/unit/deploy_venv_sync/test_release_promotion/__init__.py`
- `tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py`

### Commit plan assessment for step 6 deploy-venv-sync (exchange 1) (round 1)

The independent `commit-plan-check.bat --format json` run returned state
`valid`, `ready: true` and no diagnostics for all seven staged paths in two
ordered groups: the helpers, tests and native entry points, then the
validation plan alone. The rerun after staging the reviewer's validation rows
is still valid and ready. Membership, order and subjects are accurate, and the
reviewer did not amend `a.commit`. The group 2 message body describes a
completed step; refresh it after the rework.

### Findings and boundaries for step 6 deploy-venv-sync (exchange 1) (round 1)

Unresolved findings:

- F1 (blocking): the bundled `deploy_venv_release.py` gains an unlisted
  executable dependency. Its `publication-check` operation loads
  `deploy_venv_publication.py`, which `HELPER_SOURCES` and the plan's helper
  closure do not list, so a delivered companion carries a member whose new
  operation cannot run from the delivered set. It fails closed with exit 2,
  but it breaks the closure rule and couples target-delivered code to
  operator-only code.
- F2 (blocking): the plan's Step 6 file list and line-budget checkpoint omit
  `deploy_venv_publication.py`; only the validation plan records it.
- F3 (blocking): `test_release_promotion_tdd.py` does not reach these
  rejection statements of `deploy_venv_publication.py`: the `SNAPSHOT`
  coordinate refusal, the "announced release lost required retained objects"
  check, the manifest read-back check, the empty-evidence check, the
  timezone-less expiry check, the unsafe evidence root check and the non-path
  input check.

Boundary-crossing work:

- If the two F1 routes lead to different Step 7 candidate requirements, the
  choice between them is the human's.
- Production promotion of a real candidate belongs to Step 7 and is not
  assessed here.

### Writer instructions for step 6 deploy-venv-sync (exchange 1) (round 1)

- F1, preferred route: give `deploy_venv_publication.py` its own `main()`
  with the `publication-check` operation, and restore `deploy_venv_release.py`
  to its previous bytes, docstring included. Operator-only code then stays out
  of the target companion. Point the private operator and the acceptance entry
  at the new command. Afterwards, reassess privately whether Step 7 still needs
  a newly built candidate, and update the validation plan's statement on that
  point to match. Alternative route: add `deploy_venv_publication.py` to
  `HELPER_SOURCES` and to the plan's helper closure list, with a test proving
  the delivered set carries it. The human should choose if the requalification
  cost differs between the two routes.
- F2: add `deploy_venv_publication.py` (new) to the plan's Step 6 "Files
  involved" list and line-budget checkpoint, with one sentence on why
  publication is a separate module.
- F3: add subtests for a coordinate containing `SNAPSHOT` in any case, an
  existing remote manifest with one retained object absent, a backend whose
  manifest read-back differs after upload, a zero-byte evidence file whose
  digest matches, a naive `expires_at` in the future, a relative or symlinked
  evidence root, and a non-string local path value. Assert that no upload
  happens in each rejection before transport.
- Transcript lint: the round 1 request's change summary lists paths without
  backticks, so `__init__.py` renders as bold text and the transcript fails
  MD050. Backtick the paths in the replacement request, and fix that line in
  the transcript before the final commit.
- After the fixes, rerun the implementation-check for Step 6, the native
  cumulative verification, and the consumer gates affected by any operator
  change. Keep the retained backend results; the fixes do not require
  recreating the deleted backend fixtures unless the operator's transport
  calls change.

### Decision rationale for step 6 deploy-venv-sync (exchange 1) (round 1)

The readiness floor fails on three of six results. Identity passes. Staged
attribution passes: the only reviewer change is the attributable Step 6
validation rows. The mechanical `a.commit` result passes. Completeness fails
on F1 and F2, validation and coverage fail on the static gaps in F3, and
unresolved findings F1 to F3 remain.

The disposition is changes-requested. The publication design is sound and the
backend evidence is strong; the open items are a dependency placement, a plan
list update and seven small tests. This recommendation is advisory and
authorizes nothing.

### Final reviewer decision for step 6 deploy-venv-sync (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-1 -->

## Round 2 by requestor - Step 6

- Recorded: 2026-09-30T19:06:03+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 6
Review round: 2

### Code review evidence for step 6 deploy-venv-sync (round 2)

request_index_tree: 33857df35afed192f97f9e0e093105a071582f4f
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 6 --python /absolute/authoring/python --app-repo /absolute/consumer (sources: plan)
- bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 6 --python /absolute/operator/python --operator /absolute/operator --candidate-manifest /absolute/candidate.json --qualification-record /absolute/qualification.json --release-config /absolute/operator-config.json --evidence-root /absolute/evidence (sources: plan)
- bash -n docs/v0.27.0/verify.deploy-venv-sync.sh (sources: plan)
- bash -n docs/v0.27.0/acceptance.deploy-venv-sync.sh (sources: plan)
- shellcheck docs/v0.27.0/verify.deploy-venv-sync.sh docs/v0.27.0/acceptance.deploy-venv-sync.sh (sources: plan)
- ghog day (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(deploy-venv-sync): bind qualified releases
group 1 path: src/setups/env/bin/deploy_venv_publication.py
group 1 path: tests/unit/deploy_venv_sync/test_release_promotion/__init__.py
group 1 path: tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py
group 1 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 1 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 2: docs(deploy-venv-sync): record step 6 validation
group 2 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
group 2 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_publication.py
staged path: tests/unit/deploy_venv_sync/test_release_promotion/__init__.py
staged path: tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py
```

### Requestor assessment for step 6 deploy-venv-sync (round 2)

Step 6 is fully implemented. The validation plan records the exact eligibility,
publication, retained-input and backend acceptance evidence. Production promotion
and final target qualification remain Step 7.

The native cumulative harness passed 248 tests in 33.265 seconds, syntax,
ShellCheck and the 650 physical-line ceiling. The project groundhog walk reached
its documented non-pytest exit 9; the native harness supplies the applicable
project verification. The consumer groundhog walk passed check, affected tests
and all 6,662 full-suite tests with zero failures, 100% configured application
coverage and zero duration outliers. That coverage percentage does not cover the
standalone operator or reusable helpers; their functional cases are reported
separately. Twenty-three publication test methods and seventeen consumer adapter cases
cover qualification binding, mutation, transport and receipt boundaries.

All five live backend cases passed: complete publication, partial-upload retry,
manifest retry, conflicting bytes and predecessor retention. Direct conflicting
redeployment failed and preserved the original bytes. All owned test components
were subsequently deleted and all associated assets verified absent. The backend
receipt is historical evidence; production retention checks still run on each
promotion. Administration policy was unavailable and is not claimed as observed.

The architecture keeps qualification and exact-byte ordering reusable while the
private adapter owns credentials, repository coordinates and Maven invocation.
All changed Python files remain below 550 physical lines. Source/reference audit
found no unused added top-level symbols or new hierarchy. Snapshotting is linear
in payload bytes, with necessary integrity-boundary rereads. Feature-integrity
review found no rebuild, deployment, CI invocation or toolchain republishing in
the operator path. Existing publisher semantics and unrelated consumer changes
are preserved. A narrowly profiled property-test sample budget was corrected to
the existing default without changing strategies or assertions.

All round 1 findings are addressed. The publication module owns its isolated
command entry and the delivered release helper is byte-identical to HEAD. The
plan includes the new operator module and line budget. Additional tests reach
the seven identified safety boundaries. The actual symlink case ran on Linux;
the native result has no skips. Consumer code and transport behavior did not
change, so their retained green evidence still applies.

This step no longer changes the companion helper closure or requires rebuilding
for that reason. Step 7 still requires complete exact-candidate qualification;
changed candidate inputs require renewed qualification and frozen bytes must
never be patched or relabeled.

### Implementation report for step 6 deploy-venv-sync (round 2)

Added a reusable publication module with its own operator eligibility CLI.
The delivered release helper remains unchanged. The validator binds
completed qualification and CI evidence to exact candidate, toolchain and both
predecessor forms. It freezes validated bytes, checks retained remote inputs,
supports equal-byte retry, refuses conflicts, and publishes the generated binding
last after full readback. Tests include evidence mutation during validation,
interrupted upload and manifest failure. Round 2 adds snapshot refusal, lost
objects after announcement, corrupt manifest readback, matching empty evidence,
naive expiry, unsafe evidence roots, non-path inputs and isolated CLI execution.

The private operator wraps the existing workstation publisher with explicit
inputs and existing credentials. Exact-byte staging preserves destination
extensions with the existing Maven plugin. Repository-bound backend receipts
remain valid after authorized disposal of test markers. Current and predecessor
retention remains independently mandatory. The cumulative verifier and acceptance
entry now expose Step 6, including the five actual backend cases.

Both public and private changes are staged with checked two-group commit plans.
The public validation record is complete for Step 6. Private mappings, commands,
coordinates, run identities, cleanup receipts and the consumer staged inventory
are available through the writer notes. No production publication or commit has
been performed. Private files and evidence must not be copied to this transcript.

Writer notes: .reviews/a.deploy-venv-sync.step6.journal.md; .reviews/a.deploy-venv-sync.step6.handoff.md

### Change summary for step 6 deploy-venv-sync (round 2)

The public index contains seven paths:

- `src/setups/env/bin/deploy_venv_publication.py`
- `tests/unit/deploy_venv_sync/test_release_promotion/__init__.py`
- `tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`

The checked root a.commit contains two groups:

1. feat(deploy-venv-sync): bind qualified releases (the five source, test and script paths).
2. docs(deploy-venv-sync): record step 6 validation (the plan and validation document).

The release helper was restored exactly to HEAD and is no longer a staged path.
The protocol transcript remains an unstaged generated review artifact for the
canonical commit continuation; the known path-formatting issue was repaired.

The private consumer has seven intended staged paths and a checked two-group
commit plan: the bounded property-test correction, followed by the operator,
publisher integration and tests. Its exact path inventory and evidence remain
private in the writer handoff. Five unrelated untracked paths remain unstaged.

### Writer response for step 6 deploy-venv-sync (round 2)

Writer response:

Accepted all round 1 findings and the reviewer's preferred dependency placement.
No disagreement and no reviewer repair was reversed without addressing its cause.

- F1: restored the complete delivered release helper to HEAD, including its
  docstring. The publication module now provides its own publication-check main
  entry. A subprocess test proves isolated valid execution and refusal of an
  incomplete qualification. That regression failed before implementation and
  passed afterwards. The private adapter already selects this publication module,
  and the acceptance entry delegates to that adapter, so neither needs rewiring
  and transport calls are unchanged. The companion closure is unchanged; this
  correction avoids a helper-driven rebuild while preserving Step 7's complete
  qualification gate for the selected exact candidate.
- F2: added the publication module to the Step 6 file list and line budget, and
  documented why its operator responsibility stays separate. Updated the plan's
  behavior description and commit-plan membership consistently.
- F3: added the seven requested safety mutations and isolated CLI execution.
  Early rejection checks prove no transport or upload, as appropriate. The
  post-upload manifest readback case proves failure and absence of a success
  receipt. Native Linux exercises the actual symlink; all 248 tests pass without
  skips. Consumer and backend evidence is retained because transport did not
  change. Deleted backend fixtures were not recreated.
- Formatting: backticked the new request's staged paths and repaired the known
  earlier transcript lines mechanically, without using the transcript as context.

Implementation-check now records Step 6 Yes, removes the completed missing-work
list, and reports the unchanged companion and the expanded test evidence.
Production promotion remains Step 7. Both repositories remain uncommitted.

### Reviewer focus for step 6 deploy-venv-sync (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-2 -->

## Round 2 by reviewer - Step 6

- Recorded: 2026-09-30T19:11:11+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 deploy-venv-sync (exchange 1) (round 2)

Baseline index tree: 33857df35afed192f97f9e0e093105a071582f4f

Assessed index tree: 33857df35afed192f97f9e0e093105a071582f4f

### Implementation check for step 6 deploy-venv-sync (exchange 1) (round 2)

Result:

Yes. Step 6 has been fully implemented.

All three round 1 findings are resolved in the staged tree, and the writer's
Step 6 validation rows are accurate.

- F1: `deploy_venv_release.py` and `deploy_venv_inputs.py` are byte-identical
  to HEAD in both the index and the working tree, so the target companion's
  helper closure is unchanged. `deploy_venv_publication.py` now has its own
  `main()` with the `publication-check` operation and the same caught
  exception set as the release helper. A subprocess test in isolated mode
  proves both the accepted and the refused paths. Because the delivered helper
  no longer changes, this step no longer forces a rebuilt candidate.
- F2: the plan's Step 6 file list, behavior item 1 and line-budget checkpoint
  now name the publication module and state why it is separate.
- F3: new tests reach every rejection branch I listed: `SNAPSHOT` in any case
  for an object or the manifest, an announced manifest with a missing object
  (never repaired, no upload), a corrupted manifest read-back (no receipt),
  zero-byte evidence with a matching digest, a timezone-less expiry, relative
  and symlinked evidence roots, and non-path inputs. Every rejection before
  transport asserts that the backend saw no call. I traced each assertion to
  the statement and message it targets.

Architecture: operator code now depends on the release helper, not the reverse.
Performance: unchanged, linear in payload bytes. Line budgets: the publication
module and its test stay under 550 lines.

Validation plan effects:

The reviewer made no edit to the validation plan in round 2. The writer's Step
6 rows record the Yes verdict, the unchanged release helper, the separate
operator command, the added tests and the 248-test native result, and they are
accurate. The document-level status stays `No, it is not implemented.` because
Step 7 remains.

### Pre-repair mandatory checks and coverage for step 6 deploy-venv-sync (exchange 1) (round 2)

The reviewer ran its focused evidence once, from the project root, with the
log-freshness proof.

- `ghog check`: exit 0; the repository shell lint is clean.
- `ghog affected --no-cov`: not applicable, because cplx is not a pytest
  project.
- `git diff --cached --check`: exit 0 on the received index.

The unit assessment is static: each new test was traced to the rejection
statement and message it targets.

### Resolved validation set and sources for step 6 deploy-venv-sync (exchange 1) (round 2)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 6 --python <selected-python> --app-repo <consumer-root>` (source: plan).
- `bash docs/v0.27.0/acceptance.deploy-venv-sync.sh --step 6 ...` with the
  explicit operator, candidate manifest, qualification record, private
  configuration and evidence root (source: plan).
- `bash -n` on both entry scripts and `shellcheck` on both (source: plan).
- `ghog day` (source: plan).

### Resolver drift and direction for step 6 deploy-venv-sync (exchange 1) (round 2)

No drift. The commands match round 1 and the plan's Step 6 command forms. The
reviewer did not run the set; the requestor owns it and reports native
cumulative verification at 248 tests with no skips. Consumer and backend
evidence is carried over because neither the consumer code nor the transport
calls changed in this round, which matches the staged diff.

### Repository state around validation for step 6 deploy-venv-sync (exchange 1) (round 2)

The index tree was `33857df35afed192f97f9e0e093105a071582f4f` at request time,
at review entry and after the assessment. The umbrella digest is unchanged
(`46b95d18...`). The validation-state comparison over all staged paths is
acceptable, with no tracked or untracked difference; only the reviewer's own
ignored ghog logs changed. The only unstaged change is the protocol transcript.

### Repair inventory for step 6 deploy-venv-sync (exchange 1) (round 2)

Repairs made:

- None. The reviewer made no repair and staged nothing in round 2.

Paths staged:

- `docs/v0.27.0/acceptance.deploy-venv-sync.sh`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md`
- `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`
- `docs/v0.27.0/verify.deploy-venv-sync.sh`
- `src/setups/env/bin/deploy_venv_publication.py`
- `tests/unit/deploy_venv_sync/test_release_promotion/__init__.py`
- `tests/unit/deploy_venv_sync/test_release_promotion/test_release_promotion_tdd.py`

### Commit plan assessment for step 6 deploy-venv-sync (exchange 1) (round 2)

The independent `commit-plan-check.bat --format json` run returned state
`valid`, `ready: true` and no diagnostics for all seven staged paths in two
ordered groups: the publication module, tests and native entry points, then
the plan and validation plan. The release helper is no longer staged, so the
first group correctly omits it. `a.commit` remains accurate; the reviewer did
not amend it.

### Findings and boundaries for step 6 deploy-venv-sync (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 6 deploy-venv-sync (exchange 1) (round 2)

No rework is required. If the human selects Commit, stage the review
transcript, including this round's append and the earlier path-formatting
repair, with the final group as the workflow prescribes. Then run the installed
sensitive hook, a Markdown check of the transcript, and the commit-plan checker
once more against the final index before committing.

### Decision rationale for step 6 deploy-venv-sync (exchange 1) (round 2)

All six readiness-floor results pass. Identity: the envelope, request fields,
plan, step, round and index tree agree. Completeness: the implementation-check
is Yes and the companion closure is unchanged. Validation and coverage: the
focused lint is green, the static mapping reaches every rejection statement,
and the requestor's native, consumer and backend evidence is green. Staged
attribution: the reviewer made no repair. Unresolved findings: none.
`a.commit`: valid, ready and accurate.

Production promotion of a real candidate, with its full exact-candidate
qualification, remains the scope of Step 7.

The recommendation is commit-ready. It is advisory and does not authorize a
commit; the Commit or Rework choice belongs to the human.

### Final reviewer decision for step 6 deploy-venv-sync (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-6-round-2 -->

## Round 2 by human - Step 6 - human-confirmation

- Recorded: 2026-09-30T19:50:53+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->

## Round 1 by requestor - Step 7

- Recorded: 2026-10-03T14:10:33+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 7
- Outcome: request

### Review identity for step 7 deploy-venv-sync (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 7
Review round: 1

### Code review evidence for step 7 deploy-venv-sync (round 1)

request_index_tree: 1e6e3dd43cc53a55110176a58f6b8e5f9b48d24c
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 7 --python <qualified-python> --app-repo <consumer-root> (sources: plan)
- ghog check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: chore(editor): set the active tab background
group 1 path: .vscode/cplx.code-workspace
group 2: feat(deploy): validate published CI observations
group 2 path: src/setups/env/bin/deploy_venv_release.py
group 2 path: tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py
group 3: feat(deploy): bind native acceptance evidence
group 3 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 3 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 3 path: docs/v0.27.0/acceptance.deploy-venv-sync.md
group 3 path: docs/v0.27.0/acceptance_deploy_venv_sync.py
group 3 path: tests/unit/deploy_venv_sync/test_acceptance_evidence/__init__.py
group 3 path: tests/unit/deploy_venv_sync/test_acceptance_evidence/test_acceptance_evidence_tdd.py
group 4: docs(deploy-venv-sync): record step 7 validation
group 4 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: .vscode/cplx.code-workspace
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/acceptance_deploy_venv_sync.py
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_release.py
staged path: tests/unit/deploy_venv_sync/test_acceptance_evidence/__init__.py
staged path: tests/unit/deploy_venv_sync/test_acceptance_evidence/test_acceptance_evidence_tdd.py
staged path: tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py
```

### Requestor assessment for step 7 deploy-venv-sync (round 1)

Yes. Step 7 has been fully implemented.

The validation plan now records exact-candidate acceptance, authorized immutable
publication through the unchanged operator, normal retrieval and both offline
predecessor recovery sequences. All 27 acceptance rows have digest-bound evidence
within explicitly documented execution or unchanged-component reuse scopes.
The writer-owned umbrella row is completed and belongs to the trailing validation
commit. Reviewer assessment must preserve that already-staged umbrella state.

The cumulative native verification passed 263 unit checks, Bash syntax,
ShellCheck, Python syntax and the 650-line ceiling. The observation change has
retained test-first evidence and 28 passing focused checks. Both native recovery
sequences passed all ten expected outcomes using normally retrieved release
inputs, and independent capture verified the recorded bytes. Actual consumer
delivery and independent service supervision passed separately.

Current consumer changes passed ghog check and ghog affected --no-cov, plus the
focused release-label and artifact-contract checks. Markdown lint passed for the
updated validation, umbrella, acceptance guide and private status report.
Git diff whitespace checks and the public private-identifier scan passed.

Validation scope exception: cplx is not a Python application supported by ghog
day; the retained attempt exits 9 and is not claimed green. The human explicitly
forbids further consumer ghog day/full runs and requests check/affected only.
The typed renderer still includes its mandatory default, but neither that field
nor the consumer coverage gate establishes coverage of these cplx scripts.
Do not rerun broad suites or reinterpret the unsupported command as success.
The native cumulative suite is the actual project-appropriate executable check.

Architecture: orchestration and evidence validation stay in the driver; consumer
adapters own acquisition, credentials and target lifecycle. Published observation
does not relax nonpublishing promotion eligibility. No boundary violation found.
Performance: streamed hashing has bounded memory; maps and identity checks use
linear traversal, with bounded deterministic sorts. No quadratic work found.
Coverage: no percentage gate measures these scripts; every added top-level symbol
is referenced by tests or within its module, including import-time case creation.
Feature integrity: toolchain and original wheel bytes remain bound; historical
evidence and negative outcomes keep their original scope. Reboot is untested and
nonblocking by the human's explicit instruction.

The operational evidence is private. Use the writer notes to inspect its exact
receipts locally; never copy private infrastructure identities into the answer
or the versioned transcript.

### Implementation report for step 7 deploy-venv-sync (round 1)

The acceptance driver executes explicit adapters and checks process status,
fresh run identity, exact candidate binding, complete observations and evidence
digests. Negative cases require their failing status and explicit observations.
Fixture success remains nonqualifying; subsets remain incomplete. The shell
entry validates native inputs and the cumulative runner includes the new tests.

The release helper now offers explicit published-CI observation while its existing
promotion validator retains the strict dry-run default. Unit tests reject stale,
changed, failed or incomplete observations and prove the default is unchanged.

The operator guide documents complete local delivery, offline reconstruction,
predecessor retention and publication responsibilities. The final validation
records executed rollout and the writer-owned umbrella completion. Historical
reuse is bounded by recorded unchanged-component comparisons. No new production
class hierarchy or acquisition redesign is introduced.

Writer notes: `.reviews/a.deploy-venv-sync.step7.journal.md` and
`.reviews/a.deploy-venv-sync.step7.handoff.md`.

### Change summary for step 7 deploy-venv-sync (round 1)

The root a.commit groups all 11 staged paths from least to most dependent:

1. `chore(editor): set the active tab background`: existing workspace preference
   in `.vscode/cplx.code-workspace`.
2. `feat(deploy): validate published CI observations`:
   `src/setups/env/bin/deploy_venv_release.py` and
   `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py`.
3. `feat(deploy): bind native acceptance evidence`:
   `docs/v0.27.0/acceptance.deploy-venv-sync.sh`,
   `docs/v0.27.0/verify.deploy-venv-sync.sh`,
   `docs/v0.27.0/acceptance.deploy-venv-sync.md`,
   `docs/v0.27.0/acceptance_deploy_venv_sync.py`, and
   `tests/unit/deploy_venv_sync/test_acceptance_evidence/` (empty leaf marker
   and `test_acceptance_evidence_tdd.py`).
4. `docs(deploy-venv-sync): record step 7 validation`:
   `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` and the matching
   completed row in `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`.

The formatted plan passed the canonical readiness checker. The generated review
transcript is a later workflow artifact and will be handled by the authorized
residual commit continuation if needed.

### Human guidance and writer response for step 7 deploy-venv-sync (round 1)

Human guidance:

The human authorized unattended completion of the exact release sequence and
Step 7 closure. Do not request the same publication authorization again.
Reboot is explicitly untested and nonblocking. No additional deployment or
publication is required for this review.

Do not run ghog day/full in the consumer; the human explicitly limited subsequent
test commands to check and affected. cplx ghog day is unsupported and its recorded
exit 9 is not green. Assess the retained native cumulative checks and explicit
coverage scope instead. The additive native command is shown with sanitized
arguments; the exact executed invocation is retained in the private writer notes.

Private evidence may be read locally but infrastructure names, paths, endpoints,
build identities and operational receipts must stay out of the public transcript.

Writer response:

This is the first review round for Step 7. There is no earlier feedback to accept
or reverse. The writer requests independent assessment of the completed step and
the four prepared commit groups, preserving the stated evidence boundaries.

### Reviewer focus for step 7 deploy-venv-sync (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-7-round-1 -->

## Round 1 by reviewer - Step 7

- Recorded: 2026-10-03T14:31:55+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 7
- Outcome: answer

### Assessed index identity for step 7 deploy-venv-sync (exchange 1) (round 1)

Baseline index tree: 1e6e3dd43cc53a55110176a58f6b8e5f9b48d24c

Assessed index tree: 1e6e3dd43cc53a55110176a58f6b8e5f9b48d24c

### Implementation check for step 7 deploy-venv-sync (exchange 1) (round 1)

Result:

Yes. Step 7 has been fully implemented.

The staged work delivers every Step 7 file named by the plan: the acceptance
driver and its shell entry, the cumulative verifier update, the sanitized
operator guide, the new acceptance-evidence unit tests and the validation
record, plus the explicit published-CI observation API in
`deploy_venv_release.py` with its unit cases. The retained private evidence
supports the operational claims within their stated scopes: the final
acceptance map lists all 27 driver cases as evidence-verified with stated
scope, the publication and normal-retrieval receipts verify the qualified
bytes, and the offline recovery capture records both predecessor formats
through baseline, deliberate failed upgrade, recovery, successful upgrade and
successful-upgrade rollback with network denied. The candidate binding in that
evidence carries the repaired consumer entry.

The retained native cumulative run reports 263 tests OK, the Python syntax
check and the 650-line ceiling. Its retained input copies of the six staged
code and script files match the staged blobs (the two new files byte for byte,
the four modified files after line-ending normalization), so that executed
evidence applies to exactly the reviewed bytes.

Architecture: the driver owns orchestration and evidence validation; adapters
own target commands, acquisition and credentials. `validate_ci_evidence` keeps
the strict dry-run eligibility and delegates to `validate_ci_observation`, whose
published mode is opt-in and cannot satisfy the promotion entry. The driver
loads the shared publication helper by repository-relative path, which matches
the existing verifier pattern under `docs/v0.27.0/`. No DDD or ports/adapters
violation found. Something needs addressing: the guide misdescribes the
publication-authorization flag (finding 4).

Performance: hashing streams with `hashlib.file_digest`; plan validation and
case execution are linear in the number of cases; no quadratic work. No
performance issue needs addressing.

Unit test coverage: no configured coverage gate measures these cplx scripts,
so no percentage is claimed. Every top-level symbol of the driver (`case`,
`unique`, `document`, `digest`, `write`, `evidence_file`, `validate_command`,
`run_case`, `candidate_binding`, `main`) and the new `validate_ci_observation`
is referenced by tests or at module level. Branch-level gaps remain on behavior
the guide and the implementation report state: the successful `main()` summary
path (`complete`, `missing`, `qualifying` for non-fixture runs) has no test, and
the refusal test cannot distinguish its three refusal reasons. Yes, test work
needs completing; no staged out-of-gate top-level symbol is unreferenced.

Feature integrity: strict promotion eligibility is preserved and covered by the
new negative case; published observations are explicit and recorded in the
binding; negative outcomes stay failures; no existing reporting capability is
impaired. The validation record contains one factual inaccuracy (finding 1).

Validation plan effects:

The reviewer made no edit to `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`.
The writer's staged Step 7 rows and the document-level status line are unchanged.
The validation-state comparison over the 11 staged step paths and the validation
plan reports acceptable, with no tracked, untracked or ignored differences.
The umbrella digest of `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md` is
unchanged, so the writer-owned completed umbrella row is preserved as staged.
The writer should update the Step 7 rows when addressing findings 1 to 3.

### Pre-repair mandatory checks and coverage for step 7 deploy-venv-sync (exchange 1) (round 1)

No repair was made, so no pre-repair blob was recorded. The baseline index tree
`1e6e3dd43cc53a55110176a58f6b8e5f9b48d24c` equals the request-time index tree.
Validation state was captured before assessment over the 11 staged step paths,
including the validation plan, and the umbrella digest was captured before the
implementation check.

### Resolved validation set and sources for step 7 deploy-venv-sync (exchange 1) (round 1)

The request resolves three requestor-owned commands, which the reviewer did not
run:

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 7 --python <qualified-python> --app-repo <consumer-root>`
  (source: plan).
- `ghog check` (source: request).

Requestor evidence inspected read-only: the retained native cumulative run
reports 263 tests OK plus the syntax and 650-line ceiling check, and its input
copies of the six staged code and script files match the staged blobs.

Reviewer evidence, each run once from the cplx root through the project
environment: `ghog check` exited 0 (fail=0, warn=0). `ghog affected --no-cov`
exited 9 because cplx is not a pytest project; that is a not-applicable step,
not a pass, and the native unittest run above is the project-appropriate test
evidence. `ghog day` and `ghog full` were not run.

### Resolver drift and direction for step 7 deploy-venv-sync (exchange 1) (round 1)

No resolver drift found. The current plan still names the Step 7 native command
form of `verify.deploy-venv-sync.sh`, the project lint command is unchanged, and
the staged verifier now accepts `--step 7`, matching the request's plan-sourced
command. The comparison was made by reading the plan and project files; the set
was not executed by the reviewer.

### Repository state around validation for step 7 deploy-venv-sync (exchange 1) (round 1)

The live index tree after assessment is `1e6e3dd43cc53a55110176a58f6b8e5f9b48d24c`,
identical to the baseline and the request-time tree. The umbrella digest compare
reports unchanged. The validation-state compare reports acceptable with no
differences. The only unstaged change in the worktree is the versioned review
transcript maintained by the exchange; the reviewer staged nothing.

### Repair inventory for step 7 deploy-venv-sync (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 7 deploy-venv-sync (exchange 1) (round 1)

The independent `commit-plan-check.bat --format json` run exited 0 with state
`valid`, ready true and no diagnostics. Its four groups and 11 staged paths
match the request exactly: the workspace preference chore, the published CI
observation API with its tests, the acceptance driver group, and the trailing
validation plus umbrella documentation group. The order runs from least to most
dependent and the subjects are conventional. `a.commit` is accurate for the
current staged state. If the writer changes files for the findings below, the
same four groups should still hold; refresh the group bodies where they cite
line counts or test behavior.

### Findings and boundaries for step 7 deploy-venv-sync (exchange 1) (round 1)

Unresolved findings:

1. Validation record accuracy: the Step 7 "What was implemented" bullet in
   `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` states that the
   driver has 277 lines and its new unit test file 193. The staged
   `docs/v0.27.0/acceptance_deploy_venv_sync.py` has 257 lines and
   `tests/unit/deploy_venv_sync/test_acceptance_evidence/test_acceptance_evidence_tdd.py`
   has 179.
2. Weak refusal assertions: `test_missing_inputs_recovery_and_unauthorized_promotion_never_run_adapter`
   (test file lines 158-175) checks only exit 2 and the generic
   "acceptance refused" prefix. Off Linux all three cases stop at the platform
   gate before the gates the test names; on Linux any refusal reason, including
   the wrong one, satisfies it.
3. Untested success path: no unit test runs `main()` to a written summary. The
   guide (lines 103-106) and the implementation report state that a successful
   subset yields `complete: false` with the remaining cases, and that
   non-fixture runs are marked qualifying; neither behavior, nor
   `--published-candidate` through `main()`, is exercised.
4. Guide misstatement: `docs/v0.27.0/acceptance.deploy-venv-sync.md` lines
   151-153 say `--publication-authorized` "records authorization already
   obtained", but `main()` only uses the flag as a gate (driver lines 234-235)
   and neither `result.json` nor the summary records it.
5. Minor style: the test class has two consecutive blank lines before
   `candidate_fixture` (test file lines 115-116), where one is expected inside
   a class.

Boundary-crossing work: None.

### Human guidance response for step 7 deploy-venv-sync (exchange 1) (round 1)

Human guidance:

The human authorized unattended completion of the exact release sequence and
Step 7 closure. Do not request the same publication authorization again.
Reboot is explicitly untested and nonblocking. No additional deployment or
publication is required for this review.

Do not run ghog day/full in the consumer; the human explicitly limited subsequent
test commands to check and affected. cplx ghog day is unsupported and its recorded
exit 9 is not green. Assess the retained native cumulative checks and explicit
coverage scope instead. The additive native command is shown with sanitized
arguments; the exact executed invocation is retained in the private writer notes.

Private evidence may be read locally but infrastructure names, paths, endpoints,
build identities and operational receipts must stay out of the public transcript.

Guidance response:

No publication authorization was requested and no deployment or publication is
asked for. Reboot is treated as untested and nonblocking. No `ghog day` or
`ghog full` was run anywhere; in cplx the reviewer ran only `ghog check` (exit 0)
and `ghog affected --no-cov` (exit 9, not a pytest project, recorded as not
applicable rather than green). The retained native cumulative checks and the
explicit coverage scope were assessed instead, and their inputs were matched to
the staged bytes. Private evidence was read locally only; this answer names no
infrastructure, path, endpoint, build identity or receipt.

### Writer instructions for step 7 deploy-venv-sync (exchange 1) (round 1)

1. Correct the driver and test line counts in the Step 7 validation rows to the
   staged values (or remove the counts), keeping the 650-line statement.
2. In the refusal test, assert the specific refusal reason for each case:
   missing predecessor inputs for `rollback-shipped-venv`, missing publication
   authorization for `promotion`, and the missing local tools input for
   `fresh`. Make the test run its gates on any host, for example by patching
   `platform.system` in-process or skipping off Linux with an explicit reason.
3. Add a unit test that drives `main()` to success with a one-case plan and the
   existing worker fixture: exit 0, one summary file, `complete` false,
   `missing` equal to the 26 other case names, the result `qualifying` true,
   and a `--published-candidate` variant whose binding records the published
   mode. Keep it within the existing test file and under the line ceiling.
4. Either record `publication_authorized: true` in the summary (and cover it in
   the new test), or reword the guide to say the flag is a required gate that
   is not recorded.
5. Remove the extra blank line inside the test class.
6. Rerun the native cumulative check for `--step 7` on the changed bytes and
   update the validation rows and the `a.commit` group bodies accordingly.

### Decision rationale for step 7 deploy-venv-sync (exchange 1) (round 1)

The step's operational goals are met and the executed evidence binds to the
reviewed bytes, so the implementation check is Yes. The readiness floor is not
complete: findings 1 to 5 are unresolved, two of them leave stated driver
behavior without precise tests, and the validation record contains an
inaccurate figure. Each fix is small and stays inside the Step 7 files, but
fixing test and documentation content is writer work under the request's
guidance, which authorized no reviewer repair. Changes are therefore requested.
Items outside this step's plan, such as deploying the released bytes to the
consumer's test target or the separately tracked reboot test, were not required
and are not findings.

### Final reviewer decision for step 7 deploy-venv-sync (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-7-round-1 -->

## Round 2 by requestor - Step 7

- Recorded: 2026-10-03T14:49:18+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 7
- Outcome: request

### Review identity for step 7 deploy-venv-sync (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
Implementation step: 7
Review round: 2

### Code review evidence for step 7 deploy-venv-sync (round 2)

request_index_tree: 7a3745f48c9e52244cb3aafa536288228bc7416b
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 7 --python /qualified/python --app-repo /consumer/root (sources: plan)
- ghog check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: chore(editor): set the active tab background
group 1 path: .vscode/cplx.code-workspace
group 2: feat(deploy): validate published CI observations
group 2 path: src/setups/env/bin/deploy_venv_release.py
group 2 path: tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py
group 3: feat(deploy): bind native acceptance evidence
group 3 path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
group 3 path: docs/v0.27.0/verify.deploy-venv-sync.sh
group 3 path: docs/v0.27.0/acceptance.deploy-venv-sync.md
group 3 path: docs/v0.27.0/acceptance_deploy_venv_sync.py
group 3 path: tests/unit/deploy_venv_sync/test_acceptance_evidence/__init__.py
group 3 path: tests/unit/deploy_venv_sync/test_acceptance_evidence/test_acceptance_evidence_tdd.py
group 4: docs(deploy-venv-sync): record step 7 validation
group 4 path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: .vscode/cplx.code-workspace
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.md
staged path: docs/v0.27.0/acceptance.deploy-venv-sync.sh
staged path: docs/v0.27.0/acceptance_deploy_venv_sync.py
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md
staged path: docs/v0.27.0/verify.deploy-venv-sync.sh
staged path: src/setups/env/bin/deploy_venv_release.py
staged path: tests/unit/deploy_venv_sync/test_acceptance_evidence/__init__.py
staged path: tests/unit/deploy_venv_sync/test_acceptance_evidence/test_acceptance_evidence_tdd.py
staged path: tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py
```

### Requestor assessment for step 7 deploy-venv-sync (round 2)

Yes. Step 7 remains fully implemented; all five round 1 findings are addressed.

The refreshed native cumulative harness passed 264 tests, shell lint, Bash
syntax, ShellCheck, Python syntax and the 650-line ceiling on the changed bytes.
The focused acceptance-driver suite passed 12 tests on the authoring host,
including exact preflight reasons without depending on the host platform.
The new main-entry test executes the worker subprocess for both nonpublishing
and explicitly published inputs. It checks the written summary, the 26 missing
cases, incomplete status, qualifying result and published binding.
The current cplx ghog check passed with no failures or warnings.

The validation record removes the incorrect physical-line counts and records
the refreshed checks. The guide now states that the authorization flag gates
execution and that the adapter must retain authorization evidence. No runtime
behavior or candidate input changed in this review round.

The retained operational evidence still covers all 27 acceptance cases within
their stated execution or unchanged-component reuse scopes: qualification,
authorized immutable publication, normal retrieval and both offline predecessor
recovery sequences. Delivery and independent service supervision passed
separately. No repeat publication or deployment was needed for these repairs.
The writer-owned completed umbrella row is unchanged.

Architecture and performance are unchanged: the runner validates evidence;
adapters own target commands and acquisition. Hashing streams input, and maps
and case processing remain linear. Strict nonpublishing promotion eligibility
is preserved. No feature or existing check was weakened.

No percentage coverage gate measures these cplx scripts. Each new helper has
direct test callers. No consumer ghog day/full was run, as instructed by the
human; the unsupported cplx day result is not claimed green. The native harness
is the executable project-appropriate evidence. Reboot remains untested and
nonblocking. Exact operational receipts remain private in the writer notes.

### Implementation report for step 7 deploy-venv-sync (round 2)

The acceptance driver executes explicit adapters and checks process status,
fresh run identity, exact candidate binding, complete observations and evidence
digests. Negative cases retain their required failing status and observations.
Fixture results remain nonqualifying; successful subsets remain incomplete.

Round 2 strengthens only tests and documentation. The main-entry tests now
check precise refusal gates on every host and verify written native summaries
for nonpublishing and published candidates using real worker subprocesses.
The guide precisely describes the publication-authorization gate, and the
validation plan records refreshed executable checks without stale line counts.

The explicit published-CI observation API remains opt-in. The existing promotion
entry retains strict nonpublishing eligibility. Previously retained release,
retrieval, recovery and service evidence keeps its exact scope and identities.

Writer notes: `.reviews/a.deploy-venv-sync.step7.journal.md` and
`.reviews/a.deploy-venv-sync.step7.handoff.md`.

### Change summary for step 7 deploy-venv-sync (round 2)

The root a.commit groups all 11 staged paths from least to most dependent:

1. `chore(editor): set the active tab background`: existing workspace preference
   in `.vscode/cplx.code-workspace`.
2. `feat(deploy): validate published CI observations`:
   `src/setups/env/bin/deploy_venv_release.py` and
   `tests/unit/deploy_venv_sync/test_ci_evidence/test_ci_evidence_tdd.py`.
3. `feat(deploy): bind native acceptance evidence`:
   `docs/v0.27.0/acceptance.deploy-venv-sync.sh`,
   `docs/v0.27.0/verify.deploy-venv-sync.sh`,
   `docs/v0.27.0/acceptance.deploy-venv-sync.md`,
   `docs/v0.27.0/acceptance_deploy_venv_sync.py`, and
   `tests/unit/deploy_venv_sync/test_acceptance_evidence/` (empty leaf marker
   and `test_acceptance_evidence_tdd.py`).
4. `docs(deploy-venv-sync): record step 7 validation`:
   `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md` and the matching
   completed row in `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`.

The formatted plan passed the canonical readiness checker. The generated review
transcript is a later workflow artifact and will be handled by the authorized
residual commit continuation if needed.

### Human guidance and writer response for step 7 deploy-venv-sync (round 2)

Human guidance:

The human authorized unattended completion of the exact release sequence and
Step 7 closure. Do not request the same publication authorization again.
Reboot is explicitly untested and nonblocking. No additional deployment or
publication is required for this review.

Do not run ghog day/full in the consumer; the human explicitly limited subsequent
test commands to check and affected. cplx ghog day is unsupported and its recorded
exit 9 is not green. Assess the retained native cumulative checks and explicit
coverage scope instead. The additive native command is shown with sanitized
arguments; the exact executed invocation is retained in the private writer notes.

Private evidence may be read locally but infrastructure names, paths, endpoints,
build identities and operational receipts must stay out of the public transcript.

Writer response:

All five findings are accepted. The reviewer made no staged repair, so the
writer owns these changes and reports reviewed-work-changed true without
disagreement.

1. Removed inaccurate driver and test physical-line counts from the validation
   record, preserving the verified 650-line ceiling.
2. Replaced generic subprocess refusal assertions with in-process entry calls
   that patch only the platform gate. Each case asserts its exact refusal text,
   empty stdout, absent evidence and no adapter call. The missing tools case
   removes only that input; rollback and authorization exercise their own gates.
3. Added the requested successful one-case main-entry test for both input modes.
   It runs the existing worker subprocess and verifies exactly one summary,
   exit zero, incomplete status, the other 26 cases, qualifying non-fixture
   result, exact record binding and the explicit published mode when requested.
4. Corrected the guide instead of changing the runtime result schema: the flag
   gates execution but does not record authorization; the adapter retains it.
5. Removed the extra blank line inside the test class.

The focused authoring-host suite passed 12 tests. The refreshed native cumulative
Step 7 check passed 264 tests and all syntax, lint and line-ceiling checks.
The current ghog check passed. The same four commit groups remain accurate;
the acceptance group body now also names refusal and native-summary checks.
No operational candidate bytes, publication or deployment were changed.

### Reviewer focus for step 7 deploy-venv-sync (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-7-round-2 -->

## Round 2 by reviewer - Step 7

- Recorded: 2026-10-03T14:58:27+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 7
- Outcome: answer

### Assessed index identity for step 7 deploy-venv-sync (exchange 1) (round 2)

Baseline index tree: 7a3745f48c9e52244cb3aafa536288228bc7416b

Assessed index tree: 7a3745f48c9e52244cb3aafa536288228bc7416b

### Implementation check for step 7 deploy-venv-sync (exchange 1) (round 2)

Result:

Yes. Step 7 has been fully implemented.

Round 2 changes only three staged paths relative to round 1: the acceptance
unit test file, the operator guide and the Step 7 validation rows. The driver,
the release helper, both shell entries and the CI evidence tests are byte
identical to the round 1 review, so the round 1 implementation assessment and
operational evidence review still apply.

All five round 1 findings are resolved:

1. The validation rows no longer state the incorrect line counts; they keep the
   650-line statement and record the refreshed 264-test native run.
2. The refusal test now calls `main()` in-process with only the platform gate
   patched, and asserts the exact refusal text for each of the three gates,
   empty standard output, no adapter call and no evidence directory.
3. A new test drives `main()` to success with the real worker subprocess, for
   both nonpublishing and explicitly published inputs. It checks one summary,
   exit 0, `complete` false, the 26 missing cases, the record binding, the
   published mode only when requested, and a passed, qualifying, non-fixture
   result.
4. The guide now states that `--publication-authorized` gates execution and
   neither grants nor records authorization, and that the adapter retains the
   authorization evidence. This matches the unchanged driver.
5. The extra blank line inside the test class is removed.

The refreshed native cumulative run reports 264 tests OK and the syntax and
650-line check, and both new tests appear as passing. Its input copies of the
six staged code and script files match the staged blobs. The test file has 232
lines.

Architecture: unchanged; the runner validates evidence and adapters own target
commands. No DDD or ports/adapters violation; nothing needs addressing.
Performance: unchanged and linear; no performance issue needs addressing.
Unit test coverage: no coverage gate measures these cplx scripts; every
top-level symbol is referenced, and the previously untested success path and
precise refusal gates are now tested. No unit-tested class needs completing and
no staged out-of-gate top-level symbol is unreferenced.
Feature integrity: strict promotion eligibility, explicit published
observation and negative outcomes are unchanged; no capability is impaired.

Validation plan effects:

The reviewer made no edit to `docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.validation.md`.
The writer's updated Step 7 rows are accurate for the staged state. The
validation-state comparison over the 11 staged step paths reports acceptable
with no differences, and the umbrella digest is unchanged, so the writer-owned
completed umbrella row is preserved as staged.

### Pre-repair mandatory checks and coverage for step 7 deploy-venv-sync (exchange 1) (round 2)

No repair was made, so no pre-repair blob was recorded. The baseline index tree
`7a3745f48c9e52244cb3aafa536288228bc7416b` equals the request-time index tree.
Validation state and the umbrella digest were captured before assessment.

### Resolved validation set and sources for step 7 deploy-venv-sync (exchange 1) (round 2)

The request resolves three requestor-owned commands, which the reviewer did not
run:

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.deploy-venv-sync.sh --step 7 --python /qualified/python --app-repo /consumer/root`
  (source: plan).
- `ghog check` (source: request).

Requestor evidence inspected read-only: the refreshed native cumulative run
reports 264 tests OK and the syntax and 650-line check, with input copies of
the six staged code and script files matching the staged blobs.

Reviewer evidence: `ghog check` from the cplx root through the project
environment exited 0 (fail=0, warn=0). `ghog affected --no-cov` was not run
this round: round 1 established that cplx is not a pytest project (exit 9,
not applicable), and the native run above is the project-appropriate test
evidence. `git diff --cached --check` passed. No `ghog day` or `ghog full`.

### Resolver drift and direction for step 7 deploy-venv-sync (exchange 1) (round 2)

No resolver drift found. The set matches round 1 apart from sanitized
placeholder arguments in the plan-sourced command; the plan's Step 7 command
form and the project lint command are unchanged. Compared by reading, not
executed by the reviewer.

### Repository state around validation for step 7 deploy-venv-sync (exchange 1) (round 2)

The live index tree after assessment is `7a3745f48c9e52244cb3aafa536288228bc7416b`,
identical to the baseline and the request-time tree. The umbrella digest compare
reports unchanged and the validation-state compare reports acceptable with no
differences. The reviewer staged nothing.

### Repair inventory for step 7 deploy-venv-sync (exchange 1) (round 2)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 7 deploy-venv-sync (exchange 1) (round 2)

The independent `commit-plan-check.bat --format json` run exited 0 with state
`valid`, ready true and no diagnostics. Its four groups and 11 staged paths
match the request. The order runs from least to most dependent, the subjects
are conventional, and the acceptance group body now names the refusal and
native-summary checks added in this round. `a.commit` remains accurate.

### Findings and boundaries for step 7 deploy-venv-sync (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work: None.

### Human guidance response for step 7 deploy-venv-sync (exchange 1) (round 2)

Human guidance:

The human authorized unattended completion of the exact release sequence and
Step 7 closure. Do not request the same publication authorization again.
Reboot is explicitly untested and nonblocking. No additional deployment or
publication is required for this review.

Do not run ghog day/full in the consumer; the human explicitly limited subsequent
test commands to check and affected. cplx ghog day is unsupported and its recorded
exit 9 is not green. Assess the retained native cumulative checks and explicit
coverage scope instead. The additive native command is shown with sanitized
arguments; the exact executed invocation is retained in the private writer notes.

Private evidence may be read locally but infrastructure names, paths, endpoints,
build identities and operational receipts must stay out of the public transcript.

Guidance response:

No publication authorization was requested and no deployment or publication is
asked for. Reboot is treated as untested and nonblocking. No `ghog day` or
`ghog full` was run; the reviewer ran only `ghog check` in cplx (exit 0). The
refreshed native cumulative checks and the explicit coverage scope were assessed
and matched to the staged bytes. Private evidence was read locally only; this
answer names no infrastructure, path, endpoint, build identity or receipt.

### Writer instructions for step 7 deploy-venv-sync (exchange 1) (round 2)

No further changes are requested. Present the convergence gate to the human with
the existing registered labels; the commit decision belongs to the human.

### Decision rationale for step 7 deploy-venv-sync (exchange 1) (round 2)

All six readiness criteria pass: exact identity, complete implementation,
validation and coverage (green reviewer `ghog check`, native run on the staged
bytes, no static coverage gap), attributable staged scope with no reviewer
repair, no unresolved finding, and an accurate `a.commit` confirmed by the
independent checker. The round 1 findings are fully resolved without runtime
changes. Commit-ready is recommended as advice only; it does not authorize a
commit.

### Final reviewer decision for step 7 deploy-venv-sync (exchange 1) (round 2)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-7-round-2 -->

## Round 2 by human - Step 7 - human-confirmation

- Recorded: 2026-10-03T14:59:59+02:00
- Exchange: code/code/v0.27.0/deploy-venv-sync
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.deploy-venv-sync.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 7
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
