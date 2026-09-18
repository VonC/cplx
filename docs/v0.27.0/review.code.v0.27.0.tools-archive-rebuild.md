# Code review transcript for v0.27.0

- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor - Step 1

- Recorded: 2026-09-17T08:55:26+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 1
- Outcome: request

### Review identity for step 1 tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 1
Review round: 1

### Code review evidence for step 1 tools-archive-rebuild (round 1)

request_index_tree: 2455cdd3524b60db780b71a249bfbe4a83e6c6f6
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- powershell -ExecutionPolicy Bypass -File .reviews/a.validate-tools-step1.ps1 (sources: plan)
- powershell -ExecutionPolicy Bypass -File .reviews/a.validate-tools-application.ps1 (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(publication): require uncertain commit checks
group 1 path: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
group 1 path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/plan.v0.27.0.toolchain-runtime-closure.md
group 1 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 2: fix(publication): retain uncertain commit outcomes
group 2 path: src/setups/env/bin/closure_publish.sh
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-publish.sh
group 2 path: docs/v0.27.0/fixtures.tools-release-publish/README.md
group 2 path: docs/v0.27.0/fixtures.tools-release-publish/closure-config.txt
group 2 path: docs/v0.27.0/fixtures.tools-release-publish/closure-envelope.txt
group 2 path: tests/unit/tools_release_transport/__init__.py
group 2 path: tests/unit/tools_release_transport/test_tools_release_transport/__init__.py
group 2 path: tests/unit/tools_release_transport/test_tools_release_transport/test_tools_release_transport_tdd.py
group 3: docs(tools-archive-rebuild): record step 1 validation
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.adapter-http-probe.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.backend-preflight.txt
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.stream-probe.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.validation.txt
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/design.v0.27.0.toolchain-runtime-closure.md
staged path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.adapter-http-probe.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.backend-preflight.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.stream-probe.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.validation.txt
staged path: docs/v0.27.0/fixtures.tools-release-publish/README.md
staged path: docs/v0.27.0/fixtures.tools-release-publish/closure-config.txt
staged path: docs/v0.27.0/fixtures.tools-release-publish/closure-envelope.txt
staged path: docs/v0.27.0/plan.v0.27.0.toolchain-runtime-closure.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-publish.sh
staged path: src/setups/env/bin/closure_publish.sh
staged path: tests/unit/tools_release_transport/__init__.py
staged path: tests/unit/tools_release_transport/test_tools_release_transport/__init__.py
staged path: tests/unit/tools_release_transport/test_tools_release_transport/test_tools_release_transport_tdd.py
```

### Requestor assessment for step 1 tools-archive-rebuild (round 1)

Step 1 is fully implemented under the user's mandatory commit-response check.
The exact-asset GET and SHA-256 comparison run after missing, malformed or error
responses. Durable intent prevents a lost reply from permitting another upload.
Unresolved outcomes block adoption and automatic retry. No actual release was
rebuilt or published.

Native RHEL 9.8 / Bash 5.1.8 / independent Python 3.9.25 validation passed:
15 process tests in 11.244s, 25 current SQLite fixtures and 254 frozen closure
controls in 33s total. The latter explicitly use the historical input pair
already documented by the preceding SQLite effort; production inputs are intact.
The application ghog day exited 0 with coverage 100%, fail=0, warn=3, xfail=8,
outliers=0 and excluded=0. Coverage applies to src/pdfss, not the release tools.

The application adapter owns transport and state; cplx owns the gate port. New
Python files stay below 650 lines. Streaming, hashing and credential lookup are
linear; no new sort or all-pairs scan was introduced. Ordinary publication has
fresh/identical/different/snapshot regression coverage. New tests are process
integration despite their shared-convention path; no unit coverage claim or
additional property-testing dependency is made.

Inspect acceptance.tools-archive-rebuild.md and its four sanitized captures for
proof and limits. Live service proof uses the actual HTTP helper; native full
worker proof uses isolated TLS. Do not infer a live whole-worker run, concurrency
or large archive acceptance. Owned probe assets were cleaned up and checked.

### Implementation report for step 1 tools-archive-rebuild (round 1)

The application introduces tools_release_adapter.sh plus separate Python 3.9
HTTP and durable receipt helpers. They hold one unfinished chunked HTTPS request,
stream stdin, fsync commit intent/digest, then terminate the request. A successful
reply or matching independent GET confirms commit. Inconclusive read-back retains
UNKNOWN with exit 3. Recovery repeats GET without PUT; abort after intent never
deletes public bytes. Verified TLS and local Maven configuration remain required.

cplx corrects the inherited false absence diagnostic and records the authorized
owning-design resolution. The old application --with-tools entry refuses before
remote commands until Step 2 wires accepted release evidence. Existing ordinary
application publishing is unchanged. A separate SQLite diagnostic typing fix was
needed for the existing application authoring gate and passed a native smoke.

The application changes are staged in a separate checkout. Resolve its private
local path and exact additional index-tree identity from the ignored file
.reviews/a.tools-application-context.json; do not copy locator values into the
versioned transcript. Review its five staged files and separate a.commit as
cross-repository implementation dependencies. The cplx request_index_tree binds
the primary repository only. LF-normalized source hashes are retained in the
versioned validation capture. No commit authorization for either tree is assumed.

The added validation wrapper runs the plan's native cumulative command with an
explicit independent interpreter and application fixture. Its ignored builder
and remote driver can be inspected locally. The application wrapper sets PRJ_DIR
explicitly because the inherited environment otherwise points at cplx. Both
wrappers keep private paths out of versioned request text. Do not repeat live
writes: the existing sanitized probes supply the actual backend capability proof.

### Change summary for step 1 tools-archive-rebuild (round 1)

The primary staged set has 19 paths, grouped in the root a.commit:

1. Four owning/current design and plan documents resolve commit response loss.
2. The closure gate, two runners, three historical fixture files and three test
   package files exercise streaming publication and recovery.
3. Acceptance, four sanitized evidence captures and the Step 1 validation plan
   form the trailing docs(tools-archive-rebuild): record step 1 validation group.

The application staged set has five paths, grouped separately:

1. tools/sqlite_candidate_mapping.py: typing/platform authoring prerequisite.
2. tools/tools_release_adapter.sh, tools/tools_release_http.py,
   tools/tools_release_transport.py and tools/publish_pdf_nexus.sh: adapter and
   old tools-entry refusal.

Both root commit plans passed wrap_commit and commit-plan-check. No commits have
been created. The application path and additional immutable staged-tree identity
are supplied by the ignored local context file named in the implementation report.

### Writer response for step 1 tools-archive-rebuild (round 1)

Writer response:

This is the first implementation review round. There is no earlier code-review
feedback. The user explicitly required a mandatory double-check after a missing
proper commit response; the owning design and implementation reflect that choice.
Private application names, group identifiers and service hostnames must stay out
of versioned notes. Use generic application/backend labels.

### Reviewer focus for step 1 tools-archive-rebuild (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-1-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `.reviews/a.review-active.code.code.v0.27.0.tools-archive-rebuild.md`
- `.reviews/a.review-requested.code.v0.27.0.tools-archive-rebuild.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer - Step 1

- Recorded: 2026-09-17T09:15:12+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: answer

### Assessed index identity for step 1 tools-archive-rebuild (exchange 1) (round 1)

Baseline index tree: 2455cdd3524b60db780b71a249bfbe4a83e6c6f6

Assessed index tree: 2455cdd3524b60db780b71a249bfbe4a83e6c6f6

### Implementation check for step 1 tools-archive-rebuild (exchange 1) (round 1)

Result:

Yes. Step 1 has been fully implemented.

The reviewer reached that verdict independently from the plan step, the staged
diff in both trees, the retained captures and its own validation runs, not from
the writer's assessment.

Implementation against Step 1's named work:

- `app:tools/tools_release_adapter.sh` supplies the four inherited signatures
  plus a read-only `reconcile`, and passes configuration through the
  environment so no credential reaches a process argument.
- `app:tools/tools_release_http.py` holds one unfinished chunked HTTPS PUT and
  publishes only on its terminating chunk. `matches()` downloads the exact
  coordinate and compares SHA-256 over the returned bytes, so neither a search
  result, a HEAD nor a POM is ever accepted as proof of byte identity.
- `app:tools/tools_release_transport.py` owns durable state separately: it
  fsyncs the receipt and its directory, journals `COMMITTING` before the
  terminating chunk, and returns 0 only on a valid acknowledgement or a matching
  read-back. An unavailable check, an absent asset or different bytes retain
  `UNKNOWN` and return 3. `begin()` refuses any coordinate whose receipt is not
  `ABORTED`, which is what blocks automatic re-publication.
- `app:tools/publish_pdf_nexus.sh` refuses `--with-tools` before any remote
  command, as the step requires until Step 2 wires accepted release evidence.
- `src/setups/env/bin/closure_publish.sh` changes only to report an unconfirmed
  commit truthfully. The callback order, descriptor-bound hashing and the
  committed flag are untouched, and `closure_publish_cleanup` still calls
  `upload_abort` and names a retained stage on failure. That matches the plan's
  "the cplx gate changes in Step 1 only to report unresolved outcomes truthfully".
- `docs/v0.27.0/verify.tools-release-publish.sh` and
  `docs/v0.27.0/verify.tools-archive-rebuild.sh` provide the focused and
  cumulative runners. Both require an explicit absolute interpreter and
  application checkout and fail rather than skip when either is absent, which is
  the behavior decision Q02 records.
- `docs/v0.27.0/acceptance.tools-archive-rebuild.md` records the capability
  proof, its limits and the cleanup of every owned probe asset.

The mandatory commit-response check the user approved on 2026-09-17 is present
end to end: persisted intent and stream digest, exact-asset read-back, success
only on a match, status 3 with a retained attempt otherwise, read-only recovery,
and an abort after commit intent that reconciles instead of claiming absence or
deleting public bytes. The reviewer confirmed `NETWORK_ERRORS` includes
`ValueError`, so a truncated or unusable local reply also reaches that
reconciliation path rather than escaping as an unhandled failure.

Architecture: the application owns transport, credentials and durable state
while cplx keeps the four-operation port and its gate, so no technical HTTP or
filesystem concern moved into the closure layer. Transport and state are
separate modules, and the direct CLI import seam keeps Python 3.9 free of the
application's authoring helpers. No application domain code imports either
helper. Nothing needs fixing here.

Performance: streaming, hashing and credential lookup are linear in bytes with
bounded 1 MiB buffers; one receipt is addressed directly by coordinate digest;
an unconfirmed commit adds exactly one GET. No new sort, all-pairs scan or
directory-history discovery is introduced. No performance issue needs
addressing.

Unit test coverage: the measured gate is the application's `src/pdfss` source
scope, so the staged release helpers under `tools/` are outside it and their
100% walk result says nothing about them. The reviewer therefore established
exercise statically instead of converting a green walk into a percentage, and
counted module-level references as well as calls. Every top-level symbol the new
helpers define is reached: `main` dispatches `begin`, `worker` and `callback`;
`worker`, `serve` and `operate` reach `stream_body`, `commit`, `reconcile`,
`read_receipt`, `save`, `protect` and `locked`; `request` reaches
`receive_header`; `target_of` and `Target.configured` reach `service_root` and
`coordinate_path`; `write_chunk` and `finish` are used by the transport; and
`Receipt` is used in annotations. The new cplx test file is process integration
by design, so it carries no class-level coverage target, and no existing
unit-tested class was changed. No unit-tested class below 100% needs completing,
and no top-level symbol outside the coverage gate is unreferenced.

Feature integrity: ordinary application publication keeps its fresh, identical,
different-byte and snapshot behavior under fixtures, the tools entry refuses by
design until Step 2, and the current SQLite declaration and frozen harness are
unchanged. The historical control pair is used through `--shipped-dir` in an
owned copy, so no production waiver was restored.

Scope: the step's completion boundary is met without reaching into later steps.
No archive was rebuilt, nothing was published, and eligibility-record wiring,
qualification and adoption remain assigned to Steps 2 through 7.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 1 rows were checked against the template and the reviewer's
own verdict, and they already say what this check concluded, so there was
nothing to correct:

- The status sentence is exactly `Yes. Step 1 has been fully implemented.`, with
  no added introduction and no `Step checked:` prefix, followed by a blank line
  and a short prose summary.
- No stale `Missing work for Step 1` section remains, which is correct for a Yes.
- Every per-step section the template orders is present and filled: goal,
  improvement expectations, what was implemented, new types and classes,
  architecture, performance, unit test coverage and feature integrity.
- Each check section ends with its required explicit phrase, and the coverage
  section names the measured gate scope plus the second phrase about symbols
  outside it, which this step needs because it stages files the gate does not
  measure.
- The document-level status line correctly stays `No, it is not implemented.`,
  since Steps 2 through 7 are still pending, and its theme sentence was
  refreshed to say so.

Because no validation-plan path was edited, no pre-repair blob was recorded and
no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 1 tools-archive-rebuild (exchange 1) (round 1)

Every resolved mandatory command was run by the reviewer in this round, before
any repair could have been made, and all three passed. No result below was taken
from the writer's capture.

Project floor, `bash src/utils/lint_shell.sh`: `lint_shell: 57 tracked scripts`,
`lint_shell: clean`, exit 0. Run through the project environment so the pinned
ShellCheck resolved; an unavailable linter would have been missing mandatory
evidence, never a pass.

Native cumulative runner at `--step 1` on the RHEL 9.8 host, Bash 5.1.8, with
the independent `/usr/bin/python3` (3.9.25): `cumulative exit=0 elapsed=35s`.
The reviewer copied the whole remote log back rather than trusting the tail, and
confirmed inside it:

- `Ran 15 tests in 11.355s` followed by `OK`, with all fifteen process cases
  listed individually as `ok`.
- `SQLite closure: 25 checks passed in 1 seconds`.
- The historical input pair verified by digest: `closure-config.txt: OK` and
  `closure-envelope.txt: OK`, then `Historical closure input pair, current
  implementation scripts`.
- The frozen publication suite verdict: step 5, `cases 254`, `failures 0`, and
  `OBJECTIVE MET for step 5`.

Application walk: the declared wrapper first returned exit 0 while measuring
nothing, reporting `No Python file changed since the last green ghog day walk`
with `cov=skipped`. A cached-green skip is not coverage evidence, so the
reviewer forced a complete walk of the same tree. It reached the objective with
`fail=0 warn=3 xfail=8 cov=100 outliers=0 excluded=0 exit=0` in 4m 26.2s,
reproducing the recorded result. The three warnings and eight expected failures
are pre-existing and flagged by the tool as `worth a look`, not failures.

Coverage limits stated rather than assumed: the measured source scope is the
application's `src/pdfss`, so `cov=100` does not measure the staged release
helpers under `tools/`. Their exercise was established by static reference
review, reported in the implementation check, plus the fifteen process cases.

Independent byte binding, which is what ties these results to the reviewed code:
the nine LF-normalized SHA-256 values retained in the versioned validation
capture were recomputed from the current working trees and all nine match,
across both repositories. The application staged-tree identity recomputed as
`a43e84036de5736f337dc8f8d0b63066e4dc87d6`, exactly the identity recorded for
this round, and neither tree carries unstaged or untracked implementation work.

### Resolved validation set and sources for step 1 tools-archive-rebuild (exchange 1) (round 1)

The reviewer ran the union of the request validation set and the current
resolver set. The union is the same three commands, and every one of them was
executed in this round rather than read from the writer's capture.

- `bash src/utils/lint_shell.sh`, source `project`. Re-resolved independently
  from the versioned `.review-validation` declaration, whose only active line is
  that exact command. Run through the project environment so the pinned
  ShellCheck is on `PATH`. Result: `lint_shell: 57 tracked scripts`, then
  `lint_shell: clean`, exit 0.
- `powershell -ExecutionPolicy Bypass -File .reviews/a.validate-tools-step1.ps1`,
  source `plan`. Rebuilt the fixture bundle from the current working tree,
  shipped it to the native RHEL host and ran the cumulative runner at `--step 1`
  with the independent `/usr/bin/python3`. Result: `cumulative exit=0
  elapsed=35s`, exit 0.
- `powershell -ExecutionPolicy Bypass -File .reviews/a.validate-tools-application.ps1`,
  source `plan`. First run returned exit 0 without measuring anything: it
  reported `No Python file changed since the last green ghog day walk` and
  `cov=skipped outliers=skipped excluded=skipped`. The reviewer therefore forced
  a complete walk of the same tree rather than accept a cached-green skip, and
  used that forced walk as the mandatory evidence.

Evidence retained inside the artifact home, not in versioned notes:
`a.code-review.native-cumulative.log` (the full remote cumulative output) and
`a.code-review.app-ghog-force.log` (the forced application walk).

### Resolver drift and direction for step 1 tools-archive-rebuild (exchange 1) (round 1)

No drift in either direction.

The request's embedded set parses through the current resolver contract, and
re-resolving the project floor from `.review-validation` yields the same single
`project` command the request carries. The two `plan` additions are unchanged,
so the union equals both the request set and the current set. Nothing was added
by the request or retired by the plan since publication.

### Repository state around validation for step 1 tools-archive-rebuild (exchange 1) (round 1)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher rather than from equivalent Git commands.

- Request-time index tree `2455cdd3524b60db780b71a249bfbe4a83e6c6f6` equals the
  baseline captured at entry and the live index captured after all three
  validation runs and the implementation check. No drift, so no fresh baseline
  was required and no cached content was published under a stale identity.
- Umbrella digest comparison over
  `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`: `applicable: true`,
  `changed: false`, before and after both
  `0218245242f1ccec3561ef41f23322e0c6c2f3a12e69981a8fc1c9698e769fc6`. The
  protected umbrella was not touched, and no umbrella row was completed from
  reviewer mode.
- Validation-state comparison over the ordered path set, which holds all 19
  staged step paths, the validation plan and the three files named by the
  resolved commands: `acceptable: true` with empty `tracked_paths`,
  `untracked_paths` and `ignored_paths`. The native run, the lint run and the
  forced application walk left no tracked validation side effect to report,
  stage or revert.
- Reviewer-authored evidence stayed inside the artifact home as ignored `a.*`
  files, so none of it became a tracked side effect of this review.

### Repair inventory for step 1 tools-archive-rebuild (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 1 tools-archive-rebuild (exchange 1) (round 1)

`a.commit` remains accurate; the reviewer amended nothing.

The mechanical result comes from an independent
`commit-plan-check.bat --format json` rerun against the received state, not from
the value embedded in the request: `state: valid`, `ready: true`, exit 0, no
diagnostics. Its 19 staged paths and three ordered groups match the request
payload exactly.

- Group 1, `docs(publication): require uncertain commit checks`: the two owning
  closure documents plus this effort's design and plan. Least dependent, and
  correct as the group that records the authorized contract amendment.
- Group 2, `fix(publication): retain uncertain commit outcomes`: the closure
  gate, both new runners, the three historical fixture files and the three test
  package files. Depends on group 1's contract.
- Group 3, `docs(tools-archive-rebuild): record step 1 validation`: acceptance,
  the four sanitized captures and the Step 1 validation plan. Most dependent,
  since it records results produced by group 2.

Ordering is least to most dependent, membership covers every staged path once,
and each subject is a conventional single-purpose line. Scope matches the step:
no path outside Step 1's named files, its authorized Python helpers or its
evidence appears in the index.

The consuming application's separate plan was checked the same way in its own
checkout: `state: valid`, `ready: true`, exit 0, five staged paths in two groups
that place the authoring prerequisite before the adapter work. Its staged tree
identity matches the identity recorded for this round.

### Findings and boundaries for step 1 tools-archive-rebuild (exchange 1) (round 1)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 1 tools-archive-rebuild (exchange 1) (round 1)

No rework is required for Step 1, and nothing in the staged content needs to
change before the human decides.

Two optional improvements are recorded for the writer. Both touch only ignored
review scratch, never tracked content, so neither forces another round and
neither was applied by the reviewer:

- Add the forcing flag to `.reviews/a.validate-tools-application.ps1`, or use
  the documented detached mode, so the declared command measures the tree
  instead of returning exit 0 with `cov=skipped` whenever the cached green
  marker is current. As written, the mandatory application evidence is only
  reproducible by a reviewer who notices the skip and forces the walk.
- Move the bundle builder, the remote driver and the fixture tar
  (`a.prepare-tools-fixture.ps1`, `a.run-tools-cumulative.sh` and
  `a.tools-release-fixture.tar`) from the project root into the artifact home
  beside the wrappers that read them, so every runtime review file stays
  home-local.

When the exchange reaches the human gate, the registered choices are "Rework and
review again" and "Commit". The commit decision belongs to the human, not to
this reviewer and not to the requestor.

### Decision rationale for step 1 tools-archive-rebuild (exchange 1) (round 1)

The recommendation is commit-ready, and it is advisory only: it does not
authorize a commit in either repository.

All six readiness-floor results pass:

1. Identity. The live exchange context, the machine envelope, the
   human-readable request, the plan, the declared step, the positive round and
   the request-time index tree agree exactly. Step 1 exists in the named plan,
   the umbrella is the one the request carries, and the embedded validation set
   parses through the current resolver contract.
2. Completeness. Step 1's named files are all present and implement the
   four-operation transaction, the refusal of the old tools entry and the
   mandatory commit-response check the user approved on 2026-09-17. The real
   capability proof and the failing-path fixtures both exist, which is the
   step's stated completion boundary.
3. Validation and coverage. The reviewer ran the full union: the lint floor is
   clean, the native RHEL run passed with 15 of 15 process tests, 25 SQLite
   checks and 254 frozen publication controls at zero failures, and a forced
   application walk reached `cov=100` with zero failures. Coverage limits are
   stated rather than assumed, and out-of-gate symbols were established by
   static reference review.
4. Staged attribution. The reviewer made no repair, so nothing is attributed to
   it, and no pre-existing unstaged or untracked work was swept into either
   index. Both trees are clean apart from the staged sets, and the nine retained
   LF-normalized hashes match the current bytes.
5. Unresolved findings. None carried in, none raised as blocking.
6. `a.commit`. An independent rerun returns `valid` and `ready` with the same
   groups, ordering and subjects in cplx, and the same in the application
   checkout.

No substantive repair was made in this round, so the recommendation is not
disqualified by the same-round rule.

Two observations were deliberately not raised as findings, because neither
affects any readiness-floor result and neither lives in tracked content. The
first is the application wrapper's cached-green skip: the writer's recorded
numbers are accurate, and the forced walk reproduced them exactly, so the
evidence exists even though the declared command does not reproduce it
unaided. The second is the placement of three ignored review scratch files at
the project root instead of the artifact home; they are effectively ignored, so
the commit step cannot sweep them, and the canonical instruction set is itself
inconsistent on root placement for review evidence. Both are written into the
writer instructions as optional improvements.

What this answer does not claim, matching the request's own limits: no live
whole-worker run against the real backend, no concurrency or large-archive
acceptance, no release build, no publication and no adoption. Those remain the
work of Steps 2 through 7, and the frozen historical controls qualify no
candidate.

### Final reviewer decision for step 1 tools-archive-rebuild (exchange 1) (round 1)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-1-round-1 -->

## Round 1 by human - Step 1 - human-confirmation

- Recorded: 2026-09-17T09:41:38+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 1
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-1 -->

## Round 1 by requestor - Step 2

- Recorded: 2026-09-17T10:41:26+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 2
- Outcome: request

### Review identity for step 2 tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 2
Review round: 1

### Code review evidence for step 2 tools-archive-rebuild (round 1)

request_index_tree: 4d0f0bab1ef80c60661a74a48ccac5ee2659bc08
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- powershell -ExecutionPolicy Bypass -File .reviews/a.step2-native-check.ps1 (sources: plan)
- powershell -ExecutionPolicy Bypass -File .reviews/a.step2-app-check.ps1 (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(release): validate archive evidence
group 1 path: src/setups/env/bin/tools_release_record.py
group 1 path: tests/unit/tools_release_record/__init__.py
group 1 path: tests/unit/tools_release_record/test_tools_release_record/__init__.py
group 1 path: tests/unit/tools_release_record/test_tools_release_record/test_tools_release_record_tdd.py
group 2: fix(release): bind publication to accepted bytes
group 2 path: src/setups/env/bin/closure_publish.sh
group 2 path: tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-publish.sh
group 3: docs(tools-archive-rebuild): record step 2 validation
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step2-validation.txt
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step2-validation.txt
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-publish.sh
staged path: src/setups/env/bin/closure_publish.sh
staged path: src/setups/env/bin/tools_release_record.py
staged path: tests/unit/tools_release_record/__init__.py
staged path: tests/unit/tools_release_record/test_tools_release_record/__init__.py
staged path: tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py
staged path: tests/unit/tools_release_record/test_tools_release_record/test_tools_release_record_tdd.py
```

### Requestor assessment for step 2 tools-archive-rebuild (round 1)

Yes. Step 2 has been fully implemented. The validation plan records the exact
step, architecture, performance, coverage and feature-integrity assessment.
The real candidate stays pending; no release or adoption is claimed.

Final native RHEL 9.8/Python 3.9.25 cumulative run passed in 44 seconds:
16 validator units, 15 inherited transport tests, six new entry tests,
25 current SQLite checks and 254 inherited publication cases. Shell lint and
compilation passed. Separately measured validator coverage is 100% (276
statements, zero missing) under independent Windows Python 3.13.9.
The application's forced ghog day ended state=done exit=0 at
2026-09-17T10:33:54+02:00, with 6040 collected, fail=0, warn=3, xfail=8,
cov=100, outliers=0 and excluded=0. Its coverage source is src/pdfss.

The retained Step 2 evidence file lists exact LF source hashes, commands and
sanitized output. The CLI uses bounded streaming, one explicit record read
and one hash per indexed capture path. No new sorting, all-pairs scan or layer
dependency was introduced. Existing publisher behavior and gate controls pass.

### Implementation report for step 2 tools-archive-rebuild (round 1)

The stdlib CLI validates publication and completion separately, renders the
same structured record, verifies required cells and retained captures, and
tracks exact affected inputs with reasoned unaffected-result retention.
It records interpreter/timing/read-count/digest information locally, rejects
input or evidence overwrite, and verifies the bounded D10 generation decision.

The closure gate accepts an optional expected SHA-256 for compatibility;
CPLX_TOOLS_RELEASE=1 requires it. The promoted identity is checked before
adapter loading. The companion application tools-only publisher validates the
record and selected coordinate, passes the accepted digest, and runs before
Maven discovery, remote search or POM work. Legacy tools branches were removed.

This is a two-repository implementation as required by the plan. The staged
cplx tree is the immutable request index. The companion staged change is
app:tools/publish_pdf_nexus.sh, based on
7a2c1c1650a1252e9e73c4dbc9dfe73bcf5d8b87; its LF SHA-256 is
a597908dd96affc2730fd35c706f47b6ba2c0195a3bf1ff545235f618ed3a100.
Inspect this explicit companion path/diff and its separate root a.commit too.
It is not part of cplx's index tree and remains uncommitted. Both repositories
were initially clean, and no unrelated files changed. Do not commit either.

### Change summary for step 2 tools-archive-rebuild (round 1)

cplx root a.commit is formatted and mechanically ready, with all 12 staged
paths covered in dependency order:

1. feat(release): validate archive evidence
   - src/setups/env/bin/tools_release_record.py
   - tests/unit/tools_release_record/__init__.py
   - tests/unit/tools_release_record/test_tools_release_record/__init__.py
   - tests/unit/tools_release_record/test_tools_release_record/test_tools_release_record_tdd.py
2. fix(release): bind publication to accepted bytes
   - src/setups/env/bin/closure_publish.sh
   - tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py
   - docs/v0.27.0/verify.tools-archive-rebuild.sh
   - docs/v0.27.0/verify.tools-release-publish.sh
3. docs(tools-archive-rebuild): record step 2 validation
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
   - docs/v0.27.0/evidence.tools-archive-rebuild.step2-validation.txt
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

The companion application has a separate formatted, mechanically ready
a.commit containing its sole staged tools/publish_pdf_nexus.sh change under
feat(release): qualify tools before publication. Neither batch has run.

### Writer response for step 2 tools-archive-rebuild (round 1)

Writer response:

This is the first review round for Step 2. No prior reviewer repairs or
disagreements apply. The umbrella remains pending because Steps 3-7 are open.

The project .review-validation declares the Bash lint floor. The plan explains
why cplx has no pytest/ghog project, and adds native cumulative checks plus the
application authoring walk. Do not replace the floor or put effort-specific
commands in .review-validation. Existing local transport helpers run native
fixtures in an owned /tmp tree through the configured build host; they never
publish an actual release. The application interpreter is independent of the
candidate. The command additions below keep those platform boundaries.

### Reviewer focus for step 2 tools-archive-rebuild (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-2-round-1 -->

## Round 1 by reviewer - Step 2

- Recorded: 2026-09-17T11:09:26+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: answer

### Assessed index identity for step 2 tools-archive-rebuild (exchange 1) (round 1)

Baseline index tree: 4d0f0bab1ef80c60661a74a48ccac5ee2659bc08

Assessed index tree: 4d0f0bab1ef80c60661a74a48ccac5ee2659bc08

### Implementation check for step 2 tools-archive-rebuild (exchange 1) (round 1)

Result:

Yes. Step 2 has been fully implemented.

The verdict comes from the reviewer's own reading of the plan step, both staged
trees, the record itself and its own validation runs, not from the writer's
assessment.

Implementation against Step 2's named work:

- `src/setups/env/bin/tools_release_record.py` is the stdlib CLI with explicit
  `publication`, `completion` and `render` phases over one archive-indexed JSON
  record. It refuses duplicate JSON keys through an `object_pairs_hook`, unknown
  acceptance and assessment cells, unknown result states, contradictory
  identities, an archive whose bytes are not the indexed candidate, a release
  revision that differs, absent or digest-mismatched captures, a capture path
  that escapes the evidence root, an ignored `a.*` path offered as durable
  evidence, and a validator declaration that is not an independent Python 3.9 or
  later. Every path is explicit: it never scans a directory or document history
  to discover state.
- Publication and completion are genuinely separate. `publication` accepts
  pending adoption cells and refuses a record that already carries a published
  digest or a recorded recovery, which is what keeps an unresolved attempt from
  authorizing another upload. `completion` additionally requires passing
  publication and adoption, `not applicable` recovery, published digest
  association and both pin and configuration revisions.
- Retention is reasoned rather than assumed. A result may only survive changed
  inputs with an `unaffected` decision that names a reason, captures and the
  exact previous and current input identities, and a wheel or lock change can
  never retain a D10, ABI or application acceptance result.
- D10 binding is enforced: one reading, or a rebuild plus a second reading that
  must select exactly the rebuilt generation, with both GCC provider
  conclusions present, the lowest satisfying generation chosen, and packaged,
  selected and final readings converging. Neither provider satisfying refuses
  instead of guessing.
- `src/setups/env/bin/closure_publish.sh` gains the optional
  `--expected-sha256`. The reviewer verified the order in the file: the
  mandatory-guard check sits before promotion, the comparison against
  `CLOSURE_PUBLISH_IDENTITY` runs immediately after promotion at line 568, and
  the adapter is only sourced at line 641, so the binding is checked before any
  adapter load or call. Callers that supply neither the flag nor
  `CPLX_TOOLS_RELEASE=1` keep their existing interface, and every inherited
  descriptor, snapshot, stream-digest, waiver and authority check is retained.
- The companion application entry requires an explicit archive, version, record,
  evidence root, repository, revision, closure results and validator capture,
  refuses a snapshot version, requires an absolute executable independent
  interpreter, validates the record and the selected coordinate, then exits
  through the closure transaction before Maven resolution, remote search or POM
  preflight. Its obsolete tools branches are gone and the ordinary publication
  path is unchanged. The reviewer confirmed the coordinate's variables are
  defined earlier in that script, so the coordinate passed to the validator is
  complete.
- The versioned sidecar carries no candidate at all: `candidates` is an empty
  object and the unqualified template sits outside it under a separate key, with
  Step 1's four retained captures indexed under `preparation` and a recorded
  reason that no final candidate is built or qualified. That satisfies the plan's
  requirement that the record initially hold pending cells and that fixtures
  never stand in for real pass evidence.

Architecture: cplx owns evidence composition and the publication port; the
application supplies identities and its own backend adapter. The validator
neither executes the candidate nor imports application or HTTP code, and pure
validation, rendering and the filesystem CLI boundary are separate functions.
No closure result grammar or authority mechanism changed. Nothing needs fixing.

Performance: the record is read once, the archive is hashed once for both SHA-1
and SHA-256 with bounded 1 MiB buffers, and each resolved capture path is hashed
once through a dictionary that de-duplicates repeated references. Required-cell
lookups use a fixed matrix, and comparison and rendering are linear in their
data. No directory or history discovery, no sorting, no all-pairs traversal. No
performance issue needs addressing.

Unit test coverage: the validator's unit suite sits in the class-file directory
convention the project uses, and the reviewer measured it independently rather
than accepting the recorded figure: 16 tests pass and the statement coverage of
`tools_release_record.py` is 100% with 276 statements and zero missing, under
the independent Python 3.13.9 with coverage 7.14.0. That reproduces the recorded
measurement exactly. The six release-entry tests are process integration across
Bash, promotion, streaming and a spy adapter, so they carry no class-level
coverage target. The application walk's own gate measures `src/pdfss` and does
not measure this CLI or the shell entry, which the documents state rather than
assume. No unit-tested class below 100% needs completing, and no top-level
production symbol outside that gate is unreferenced.

Feature integrity: the negative entry cases refuse before the spy adapter is
even loaded, which the fixture proves by asserting its log does not exist;
eligible bytes stream unchanged; other gate callers stay compatible without the
guard; the inherited controls, the current SQLite declaration and the frozen
harness are unchanged. Publication does not require future adoption and
completion does. Nothing existing is impaired.

Scope: no real candidate, build, qualification, publication or adoption is
claimed, and the umbrella row stays pending with Steps 3 through 7 open.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 2 rows were checked against the template and against this
reviewer's own verdict, and they needed no correction:

- The status sentence is exactly `Yes. Step 2 has been fully implemented.`,
  followed by a blank line and a short prose summary.
- No stale `Missing work for Step 2` section remains, which is correct for a Yes.
- Goal, improvement expectations, what was implemented, new types and classes,
  architecture, performance, unit test coverage and feature integrity are all
  present and filled.
- Each check section ends with its required explicit phrase, and the coverage
  section names the measured gate scope and adds the second phrase about symbols
  outside it.
- The document-level line correctly remains `No, it is not implemented.` with
  its theme sentence updated to say Steps 1 and 2 are checked and Steps 3
  through 7 are pending. Flipping that line now would have been wrong.
- The recorded line counts in those rows are exact: the reviewer recounted all
  seven and each matches, including the closure gate at 670 Bash lines, which is
  outside the Python ceiling by the plan's own rule.

No validation-plan path was edited, so no pre-repair blob was recorded and no
reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 2 tools-archive-rebuild (exchange 1) (round 1)

Every resolved mandatory command was run by the reviewer in this round, before
any repair could have been made. All three pass, and one of them needed a second
measurement for an honest reason recorded below.

Project floor, `bash src/utils/lint_shell.sh`: `lint_shell: 57 tracked scripts`,
`lint_shell: clean`, exit 0, run through the project environment so the pinned
ShellCheck resolved.

Native cumulative runner at `--step 2` on RHEL 9.8 with the independent
`/usr/bin/python3` 3.9.25: `cumulative exit=0 elapsed=37s`. The reviewer copied
the whole remote log back rather than trusting the printed tail, and confirmed
each suite inside it:

- `Independent interpreter: /usr/bin/python3 3.9.25` at the top, so the
  candidate interpreter was not used.
- `Ran 16 tests` then `OK` for the validator units.
- `Ran 15 tests` then `OK` for the inherited transport and gate suite.
- `Ran 6 tests` then `OK` for the new release-entry suite.
- `SQLite closure: 25 checks passed`.
- The frozen publication verdict: step 5, `cases 254`, `failures 0`, and
  `OBJECTIVE MET for step 5`.

Application walk: the declared command again returned exit 0 while measuring
nothing, reporting no changed Python file and `cov=skipped`, so the reviewer
forced a complete walk. The first forced walk ended `fail=0 warn=3 xfail=8
cov=100 outliers=0 excluded=0` on every count except one duration outlier, which
exited 8: a pre-existing property-based application test measured 1.07s against
the suite's 1.00s floor. The reviewer had been running a coverage measurement on
the same machine during that walk, and the tool's own diagnostic warns that a
call this close to the floor flaps, so the reviewer repeated the walk with
nothing else running. The clean run reached the objective with `fail=0 warn=3
xfail=8 cov=100 outliers=0 excluded=0 exit=0` in 4m 09.9s, reproducing the
recorded result exactly. The outlier is therefore measurement contamination the
reviewer caused, not a condition of the reviewed work, and the affected test is
in application code this step does not touch: its only change in that
repository is one shell script.

Independent coverage measurement rather than an accepted figure: the reviewer
ran the validator's unit suite under the independent Python 3.13.9 with coverage
7.14.0 and obtained 276 statements, zero missing, 100%, with 16 tests passing.
That matches the recorded measurement exactly. The reviewer's own run created
byte-compile caches because it omitted the no-bytecode flag the project
harnesses use; those five directories were the reviewer's residue and were
removed, after which both trees matched their state at entry.

Independent identity binding of the evidence to the reviewed bytes:

- All nine LF-normalized SHA-256 values recorded in the Step 2 capture were
  recomputed and all nine match, including the companion publisher's, whose
  recorded base revision also matches that checkout.
- The four capture digests the sidecar indexes under `preparation` were
  recomputed from the versioned evidence files and all four match.
- The generated release-record section inside the acceptance document is
  byte-identical to the output of the validator's own `render` phase.
- The pending template's 38 result cells exactly equal the validator's matrix,
  with no missing or extra cell, `candidates` empty, and no cell in any state
  other than pending or not applicable, so the record certifies no candidate.

Coverage limits stated rather than assumed: the application gate measures
`src/pdfss`, so its 100% says nothing about this validator or the shell entry.
The validator has its own measured 100%, and the shell entry's exercise is the
six process tests.

### Resolved validation set and sources for step 2 tools-archive-rebuild (exchange 1) (round 1)

The reviewer ran the union of the request validation set and the current
resolver set. The union is the same three commands, and each was executed in
this round rather than read from the writer's capture.

- `bash src/utils/lint_shell.sh`, source `project`. Re-resolved from the
  versioned declaration, whose only active line is that exact command, and run
  through the project environment so the pinned ShellCheck resolved. Result:
  `lint_shell: 57 tracked scripts`, `lint_shell: clean`, exit 0.
- `powershell -ExecutionPolicy Bypass -File .reviews/a.step2-native-check.ps1`,
  source `plan`. Rebuilt the fixture bundle from the current working tree,
  shipped it to the native RHEL host and ran the cumulative runner at `--step 2`
  with the independent interpreter. Result: `cumulative exit=0 elapsed=37s`.
- `powershell -ExecutionPolicy Bypass -File .reviews/a.step2-app-check.ps1`,
  source `plan`. Ran as declared and again returned exit 0 without measuring
  anything, reporting that no Python file had changed since the last green walk
  and `cov=skipped`. The reviewer forced a complete walk of the same tree and
  used that as the mandatory evidence.

Caller evidence retained inside the artifact home, not in versioned notes:
`a.code-review.s2-native-cumulative.log` (the full remote cumulative output),
`a.code-review.s2-app-ghog-force.log` (the forced application walk),
`a.code-review.s2-coverage.data` with `a.code-review.s2-render.txt` (the
independent coverage measurement and the render comparison).

### Resolver drift and direction for step 2 tools-archive-rebuild (exchange 1) (round 1)

No drift in either direction.

Re-resolving the project floor from the versioned `.review-validation` yields
the same single `project` command the request carries, and the request's two
`plan` additions parse through the current resolver contract. The union
therefore equals both the request set and the current set. The plan additions
changed identity since Step 1, which is expected: they are effort-scoped
additions that name this step's native and application wrappers, and the
declaration file itself was correctly left alone.

### Repository state around validation for step 2 tools-archive-rebuild (exchange 1) (round 1)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher rather than from equivalent Git commands.

- Request-time index tree `4d0f0bab1ef80c60661a74a48ccac5ee2659bc08` equals the
  baseline captured at entry and the live index captured after all validation
  runs and the implementation check. No drift, so no fresh baseline was needed
  and nothing was published under a stale identity.
- Umbrella digest comparison over
  `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`: `applicable: true`,
  `changed: false`, before and after both
  `0218245242f1ccec3561ef41f23322e0c6c2f3a12e69981a8fc1c9698e769fc6`, which is
  also the digest observed in the Step 1 round. The protected umbrella was not
  touched and no umbrella row was completed from reviewer mode.
- Validation-state comparison over the ordered path set, holding all 12 staged
  step paths, the validation plan and the three files named by the resolved
  commands: `acceptable: true` with empty `tracked_paths`, `untracked_paths` and
  `ignored_paths`. No tracked validation side effect exists to report, stage or
  revert.
- Final working-tree state matches entry exactly. The primary tree holds its 12
  staged paths plus one unstaged modification to the versioned review transcript,
  which is the protocol's own append and is correctly left unstaged by the
  reviewer. The companion tree holds only its single staged path.
- The reviewer's own byte-compile residue from its coverage run was removed
  before this comparison, so it is neither counted as writer work nor left in
  the tree.
- Reviewer-authored evidence stayed inside the artifact home as ignored `a.*`
  files, including the remote cumulative log, both forced application walk logs,
  the coverage data and the render comparison, so none of it became a tracked
  side effect of this review.

### Repair inventory for step 2 tools-archive-rebuild (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 2 tools-archive-rebuild (exchange 1) (round 1)

`a.commit` remains accurate; the reviewer amended nothing.

The mechanical result is an independent
`commit-plan-check.bat --format json` rerun against the received state rather
than the value embedded in the request: `state: valid`, `ready: true`, exit 0,
no diagnostics. Its 12 staged paths and three ordered groups match the request
payload exactly.

- Group 1, `feat(release): validate archive evidence`: the validator plus its
  two package markers and its unit suite. Least dependent, and correct first
  because everything after it consumes the validator.
- Group 2, `fix(release): bind publication to accepted bytes`: the closure gate,
  the new publication-entry process tests and both runners. Depends on group 1.
- Group 3, `docs(tools-archive-rebuild): record step 2 validation`: the sidecar,
  the acceptance view, the Step 2 capture and the validation plan. Most
  dependent, since it records results the first two groups produce.

Ordering is least to most dependent, every staged path appears exactly once, and
each subject is a conventional single-purpose line whose type matches its
content. Scope matches the step: the two extra paths beyond the plan's explicit
list are the publication-entry test split and the Step 2 evidence capture, both
of which the plan authorizes when it asks for tests split by lifecycle and for
retained evidence.

The companion repository's separate plan was checked the same way in its own
checkout and is also `valid` and `ready` with one staged path, and its recorded
base revision and LF source digest both match what that tree currently holds.

### Findings and boundaries for step 2 tools-archive-rebuild (exchange 1) (round 1)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 2 tools-archive-rebuild (exchange 1) (round 1)

No rework is required for Step 2, and nothing in the staged content needs to
change before the human decides.

One item does need the writer's attention for the next round, and it is
deliberately described here without repeating the offending text, because this
answer is itself appended to the same tracked transcript.

- The Step 2 implementation report names the companion repository by its private
  directory name inside an absolute path under the author's home directory.
  The protocol appended that authored text to the versioned transcript beside
  this effort's documents, so tracked project documentation now carries both the
  private application name and the local account path. Step 1 handled the same
  need correctly and should be the pattern: use the `app:` label in authored
  request text, matching the plan's own generic convention, and keep the real
  locator in the ignored home-local context file that Step 1 used. The reviewer
  cannot repair this, because neither role may hand-edit a protocol transcript.
  Two mitigating facts belong with it: the repository's installed
  sensitive-content pre-commit hook carries case-insensitive rules covering both
  strings, so they cannot silently reach a commit, and the staged Step 2
  documents themselves are clean, which the reviewer verified by searching them.
  What remains is a human decision about the transcript line that already
  exists.

Two repeat observations from the Step 1 round, both in ignored review scratch
rather than tracked content, so neither forces another round:

- The declared application validation command still runs the walk without
  forcing it. The reviewer ran it as declared and it again returned exit 0 while
  measuring nothing, reporting that no Python file had changed and
  `cov=skipped`. The recorded numbers are accurate, but only because they came
  from a walk the writer forced by hand; a reviewer following the declared
  command gets a green that proves nothing. Adding the forcing flag to that
  wrapper, or using the documented detached mode, would make the declared
  evidence reproducible.
- The bundle builder, remote driver and fixture tar for the native check still
  sit at the project root rather than in the artifact home beside the wrappers
  that read them.

When the exchange reaches the human gate, the registered choices are "Rework and
review again" and "Commit". The commit decision belongs to the human, not to
this reviewer and not to the requestor.

### Decision rationale for step 2 tools-archive-rebuild (exchange 1) (round 1)

The recommendation is commit-ready, and it is advisory only: it does not
authorize a commit in either repository.

All six readiness-floor results pass:

1. Identity. The live context, the machine envelope, the human-readable
   request, the plan, the declared step, the positive round and the
   request-time index tree agree exactly. Step 2 exists in the named plan with
   the file list this work implements, and the umbrella is the one the request
   carries.
2. Completeness. The validator, its phase separation, the gate guard, the
   companion entry, the sidecar and both test suites cover Step 2's stated
   completion boundary: an incomplete record cannot reach the real tools entry,
   publication does not require future adoption, and completion does.
3. Validation and coverage. The reviewer ran the full union. The lint floor is
   clean. The native RHEL run passed with the independent 3.9.25 interpreter and
   four suites confirmed inside its log: 16 validator units, 15 inherited
   transport tests, 6 new entry tests and 25 SQLite checks, plus 254 frozen
   publication controls at zero failures. The validator's coverage was measured
   independently, not accepted: 276 statements, zero missing, 100%. The forced
   application walk needed two measurements, and the reason is recorded rather
   than smoothed over: the first exited 8 on a single duration outlier, a
   pre-existing property test 7% above the suite floor, measured while the
   reviewer was running its coverage work on the same machine. Repeated with
   nothing else running, the walk reached its objective and reproduced the
   recorded counts exactly. The contamination was the reviewer's, the affected
   test is in application code this step does not touch, and the passing clean
   run is the evidence this result rests on.
4. Staged attribution. The reviewer made no repair, so nothing is attributed to
   it. Both trees hold only their staged sets. One byte-compile cache appeared
   because the reviewer's own coverage run omitted the no-bytecode flag the
   project harnesses use; it was the reviewer's residue, not the writer's, and
   was removed, after which the tree matched its state at entry exactly.
5. Unresolved findings. None carried in from Step 1, none raised as blocking.
6. `a.commit`. An independent rerun returns `valid` and `ready` with the same
   groups, ordering and subjects, and the companion plan likewise.

No substantive repair was made in this round, so the recommendation is not
disqualified by the same-round rule.

Three claims were verified by recomputation rather than read, because a record
that indexes evidence is only as good as its digests:

- The nine LF-normalized source hashes in the Step 2 capture all match the
  current bytes, including the companion publisher's, and the companion staged
  tree's recorded base revision matches that checkout.
- The four capture digests the sidecar indexes under `preparation` all match the
  versioned evidence files byte for byte.
- The generated release-record section inside the acceptance document is
  byte-identical to the output of the validator's own `render` phase, which is
  what makes the deterministic-view claim real rather than asserted.

One item is reported to the writer without being raised as a blocking finding,
and the reasoning is worth stating plainly. The request's authored text put a
private repository name and a local account path into content the protocol
appends to the versioned transcript, against the constraint this exchange itself
recorded in Step 1. It is not raised as a finding because no writer action can
resolve it: the transcript entry already exists and neither role may hand-edit a
protocol transcript, so a changes-requested round would end with the same line
present. It is not ignored either: the staged documents are clean, the installed
pre-commit rules cover both strings before any commit, and the remaining choice
about the existing line belongs to the human. The writer instructions carry the
forward-looking fix.

What this answer does not claim: no candidate archive exists, none was built,
qualified, published or adopted, and the sidecar records no candidate pass. The
frozen controls and fixtures qualify nothing. Steps 3 through 7 and the umbrella
row remain open.

### Final reviewer decision for step 2 tools-archive-rebuild (exchange 1) (round 1)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-2-round-1 -->

## Round 1 by human - Step 2 - human-confirmation

- Recorded: 2026-09-17T14:06:42+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 2
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-1 -->

## Round 1 by requestor - Step 3

- Recorded: 2026-09-17T15:02:30+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 3
- Outcome: request

### Review identity for step 3 tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 3
Review round: 1

### Code review evidence for step 3 tools-archive-rebuild (round 1)

request_index_tree: 41ab4043949704dc8abd4d395bcc36684939941f
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 3 --python /usr/bin/python3 --app-repo /tmp/tools-release-step3.AlZy7J3B/app (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(d10): measure exact wheel consumers
group 1 path: src/setups/env/bin/tools_wheel_inventory.py
group 1 path: src/setups/env/bin/tools_wheel_inventory.sh
group 1 path: src/setups/env/bin/closure_d10.sh
group 2: test(d10): cover wheel identity and convergence
group 2 path: docs/v0.27.0/verify.tools-release-d10.sh
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 3: docs(tools-archive-rebuild): record step 3 validation
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step3-validation.txt
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step3-validation.txt
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-d10.sh
staged path: src/setups/env/bin/closure_d10.sh
staged path: src/setups/env/bin/tools_wheel_inventory.py
staged path: src/setups/env/bin/tools_wheel_inventory.sh
```

### Requestor assessment for step 3 tools-archive-rebuild (round 1)

Yes. Step 3 has been fully implemented.

The final native RHEL cumulative run exited 0 in 49 seconds with independent
/usr/bin/python3 3.9.25: 49 D10 cases, 16 release-record tests, 15 transport
tests, 6 publication tests, SQLite controls and 254 historical closure Step 5
cases passed. Shell syntax, ShellCheck and git diff --check passed. Exact source
hashes and result excerpts are retained in
docs/v0.27.0/evidence.tools-archive-rebuild.step3-validation.txt.

The shared ELF reader remains the sole ABI interpreter. The ZIP/identity
adapter owns capture and safe materialization; D10 owns selection. No new
class, layer violation, file-size excess or unreferenced top-level symbol was
found. The sole new Python file is 258 lines, below 650. New integration tests
do not carry a unit-class coverage target; no Python percentage is claimed.
The cplx gate is Bash lint, while the app coverage scope excludes these tools.

One instrumented reading used two walks and eight unique readelf calls, with
three archive objects, one wheel object and four candidate providers. D10
reported 0 seconds at whole-second resolution. Set/digest lookups and fixed
candidate passes avoid new sorting or all-pairs scans. Old archive-only
subjects, reports and selection remain compatible; policy and convergence
functions are unchanged.

The fresh required ghog day completed with exit 5 after successful lint because
cplx has no pytest configuration/executable. The plan explicitly assigns its
native cumulative runner instead. No effort-specific repository gate changed.
An optional frozen closure Step 7 run passed its D10 controls but exhausted
scratch space during its separate live archive acceptance. It is not in this
step's cumulative gate; Step 4 owns live wheel wiring and Step 6 final proof.

Native reproduction uses the owned snapshot at
/tmp/tools-release-step3.AlZy7J3B/cplx with the explicit sibling app snapshot
at revision 489bbbde741328ab7953e2338a29952cd1a9f18c. The ignored Windows
a.tools-step3-rerun.sh transports the current five source/test files and invokes
the canonical cumulative command there. Its compiler wrapper isolates existing
GCC libraries from test processes; follow the repository's CMD/senv contract.
The final raw log is a.tools-step3-native.log. No real candidate is claimed.

### Implementation report for step 3 tools-archive-rebuild (round 1)

The inventory CLI captures exact retained wheel identities together with lock
digest and installed ELF path/hash equality. Materialization verifies those
same bytes, rejects unsafe ZIP entries and writes only inside a new owned
private destination. Failures remove only that invocation's destination.
No dependency resolver is invoked. The describe phase emits identities, not
interpreted ABI requirements.

D10 accepts repeatable wheel roots, an explicit lock and an independent Python.
It snapshots archive provider identities before visiting other trees, matches
each discovered wheel ELF against the inventory and then adds its required
nodes to the shared selection input. It records origin/path/digest for each
consumer and identities/capabilities for every candidate. The extended union
also includes independent libgcc consumers without changing archive-only scope.

The native harness builds tiny controlled ELF providers/consumers and exercises
unsafe members, lock/wheel/ELF mismatches, unreadable/empty observations,
relocation, duplicate demand/root handling, deterministic wheel permutations,
lowest satisfying generation, zero headroom and all second-reading outcomes.
The cumulative runner now accepts Step 3 and retains earlier regression gates.
Only the Step 3 validation rows changed; the umbrella remains pending.

### Change summary for step 3 tools-archive-rebuild (round 1)

The root a.commit passed wac formatting and commit-plan-check with ready=true.
It contains these groups in dependency order:

1. feat(d10): measure exact wheel consumers
   - src/setups/env/bin/tools_wheel_inventory.py
   - src/setups/env/bin/tools_wheel_inventory.sh
   - src/setups/env/bin/closure_d10.sh
2. test(d10): cover wheel identity and convergence
   - docs/v0.27.0/verify.tools-release-d10.sh
   - docs/v0.27.0/verify.tools-archive-rebuild.sh
3. docs(tools-archive-rebuild): record step 3 validation
   - docs/v0.27.0/evidence.tools-archive-rebuild.step3-validation.txt
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

These are all seven staged paths. No application source changes are included.

### Writer response for step 3 tools-archive-rebuild (round 1)

Writer response:

This is the initial Step 3 review request. There is no earlier feedback or
disagreement for this step. Please assess the exact staged implementation and
the plan's fixture-only Step 3 scope, retaining the later live acceptance gates.

### Reviewer focus for step 3 tools-archive-rebuild (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-3-round-1 -->

## Round 1 by reviewer - Step 3

- Recorded: 2026-09-17T15:17:21+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: answer

### Assessed index identity for step 3 tools-archive-rebuild (exchange 1) (round 1)

Baseline index tree: 41ab4043949704dc8abd4d395bcc36684939941f

Assessed index tree: 41ab4043949704dc8abd4d395bcc36684939941f

### Implementation check for step 3 tools-archive-rebuild (exchange 1) (round 1)

Result:

Yes. Step 3 has been fully implemented.

The verdict comes from the reviewer's own reading of the plan step, the staged
diff and its own validation run, not from the writer's assessment.

Implementation against Step 3's named work:

- `src/setups/env/bin/tools_wheel_inventory.py` captures the lock digest, each
  retained wheel's digest and the exact installed ELF set, then requires set
  equality in both directions against the walked site-packages root, so an
  extraneous, absent or changed installed object is refused rather than
  tolerated. It holds one descriptor across hashing and ZIP reading and
  re-hashes afterwards, so the bytes measured are the bytes described.
  Materialization re-verifies the lock, every wheel digest and the same ELF map
  before publishing, creates its destination exclusively at mode 0700, and on
  any failure removes only the directory that invocation owns. ZIP safety is
  enforced independently of the inventory: absolute names, parent traversal,
  backslash and control characters, duplicate members, file and directory
  collisions and non-regular entries including symlinks are all refused.
  `.data/purelib` and `.data/platlib` relocation is modelled, and an ELF
  anywhere else under `.data` is refused rather than silently ignored.
- `describe` emits identities only, which is what keeps `closure_elf` the sole
  interpreter of ABI requirements. The tab-separated contract is unambiguous
  because control characters, tabs included, are rejected in member names.
- `src/setups/env/bin/tools_wheel_inventory.sh` is an 11-line wrapper that
  requires an absolute executable independent interpreter before exec.
- `src/setups/env/bin/closure_d10.sh` accepts repeatable `--wheel-root` with an
  explicit lock and interpreter, de-duplicating repeated roots. It snapshots the
  archive provider identities first and visits each reader slice once, so a
  later provider or wheel read can neither enter the consumer union nor change
  provenance already captured: origin is recorded first-seen. Every consumer
  carries origin, path and digest, and a digest that cannot be read becomes an
  inconclusive reason rather than a silent gap. Each wheel root is validated
  against its inventory by set equality in both directions, with symlinks under
  the measured subject tree refused, before its slice joins the union.
- Archive-only behavior is preserved exactly: the widened subject rule that also
  admits independent unwind consumers is conditional on wheel roots being
  supplied, so a legacy invocation keeps the inherited libstdc++ rule, its
  report fields and its selection. The selector and bounded convergence
  functions are untouched.
- The new argument-loop guard that requires an operand for every option also
  removes a real hazard in the inherited parser: previously a trailing option
  with no operand would leave `shift 2` unable to shift, which could spin.
- `docs/v0.27.0/verify.tools-release-d10.sh` builds real tiny ELF providers and
  consumers with version scripts and covers the step's whole planned matrix:
  legacy archive-only invocation, wheel-only demands, duplicate archive and
  wheel demands, matching, extraneous, missing and changed ELF subjects, corrupt
  and changed wheels, lock mismatch, five unsafe ZIP mutations exercised through
  both capture and materialization, unreadable consumer and provider, empty
  relevant set, mixed providers, zero headroom, neither candidate, all four
  second-reading outcomes, relocation, duplicate and multiple roots, malformed
  inventory, occupied destination and deterministic wheel-order permutations.
  It also pins the measurement cost at the process boundary by counting real
  `readelf` and `find` calls and asserting they are unique.

Architecture: filesystem, ZIP and JSON handling stay in the inventory adapter;
the shared ELF reader remains the only ABI interpreter; D10 remains the policy
owner. No production archive topology or application code changed. Nothing
needs fixing.

Performance: each explicit root is walked once and each reader slice visited
once, which the harness verifies rather than asserts: the instrumented union
recorded two walks and eight unique `readelf` calls for three archive objects,
one wheel object and four candidate providers. Required nodes and subject
identities are deduplicated through hash maps, candidate evaluation is linear
in the required nodes for two fixed generations, and ZIP ancestor checks are
bounded by path depth. No new sort or all-pairs traversal. No performance issue
needs addressing.

Unit test coverage: no Python class and no existing unit-tested class changed.
The new tests are native integration fixtures, so they carry no class-level
coverage target, and no Python percentage is claimed for them. The project's
declared floor measures shell lint, not Python coverage, and the application's
gate measures its own source scope. Every top-level symbol the new Python helper
defines is referenced: `main` dispatches `capture`, `materialize` and
`describe`; those reach `load_inventory`, `wheel_members`, `installed_elfs`,
`elf_map`, `digest`, `stream_digest`, `installed_name`, `safe_path`,
`hash_value`, `unique_object` and `require`. No unit-tested class below 100%
needs completing, and no top-level symbol outside the coverage gate is
unreferenced.

One clarification for the record, because the validation plan mentions it: the
`ghog day` exit 5 is not a failed gate for this repository. The versioned
`.review-validation` deliberately declares the shell lint gate as the project
floor precisely because cplx has no pytest project, so `ghog day` is not part
of the resolved mandatory set here. The declared floor ran and is clean.

Feature integrity: legacy selection, zero headroom, unread and empty
observations and all second-reading outcomes are covered and pass; the frozen
publication, record and SQLite controls still pass; production declarations and
the frozen harness are unchanged. The separately attempted frozen Step 7 run,
which was inconclusive after exhausting scratch space, is disclosed and is
outside this step's gate.

Scope: no real Debian wheel capture, no candidate, no release record pass and no
publication is claimed. Step 4 owns live wiring and Step 6 the final proof, and
the umbrella row stays pending.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 3 rows were checked against the template and against this
reviewer's own verdict, and they needed no correction:

- The status sentence is exactly `Yes. Step 3 has been fully implemented.`,
  followed by a blank line and a short prose summary.
- No stale `Missing work for Step 3` section remains, which is correct for a Yes.
- Goal, improvement expectations, what was implemented, new types and classes,
  architecture, performance, unit test coverage and feature integrity are all
  present and filled.
- Each check section ends with its required explicit phrase, and the coverage
  section names the measured scopes and adds the second phrase about symbols
  outside the gate.
- The document-level line correctly remains `No, it is not implemented.`, since
  Steps 4 through 7 are pending.
- Every line count in those rows was recounted and matches, including the
  before-and-after pair for the D10 module, which reconciles exactly with the
  staged diff.

No validation-plan path was edited, so no pre-repair blob was recorded and no
reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 3 tools-archive-rebuild (exchange 1) (round 1)

Both resolved mandatory commands were run by the reviewer in this round, before
any repair could have been made, and both pass.

Project floor: `lint_shell: 58 tracked scripts`, `lint_shell: clean`, exit 0.

Native cumulative runner at `--step 3` with the independent `/usr/bin/python3`:
`validation exit=0 elapsed=50s`. The reviewer copied the whole remote log back
rather than trusting the printed tail, and confirmed inside it:

- `Independent interpreter: /usr/bin/python3 3.9.25` at the top.
- `D10 fixtures: 49 cases passed`.
- `Measured union: walks=2 readelf=8 (archive=3 wheel=1 candidates=4); D10
  elapsed=0s`, which is the instrumented proof of the single-walk claim rather
  than a restatement of it.
- `Ran 16 tests` then `OK` for the release-record units.
- `Ran 15 tests` then `OK` for the transport suite.
- `Ran 6 tests` then `OK` for the publication-entry suite.
- `SQLite closure: 25 checks passed`.
- The frozen publication verdict with `failures 0` on RHEL 9.8 and Bash 5.1.8.

Independent identity binding of the evidence to the reviewed bytes:

- All five LF-normalized SHA-256 values recorded in the Step 3 capture were
  recomputed and all five match.
- The capture's own recorded digest for its raw local log matches that file.
- Every recorded line count was recounted and matches: 630, 11, 258, 218 and
  54. The recorded baseline of 524 for the D10 module was verified against
  `HEAD` and reconciled with the staged diff, where 126 insertions and 20
  deletions give exactly 630.

Coverage limits stated rather than assumed: this repository's declared floor is
shell lint, not a Python coverage gate, and the application's gate measures its
own source scope, so no percentage is claimed for these files. Exercise of the
new Python helper was established statically, as recorded in the implementation
check, and by the 49 native cases.

One honest note about reproducibility rather than about correctness: the
plan-sourced command names an absolute path inside an ephemeral host snapshot,
so it is not runnable from the authoring host as declared and will stop being
runnable anywhere once that scratch directory is cleaned. The evidence for this
round is real and was produced by running that exact command on the host through
the disclosed transport; the durability of the declaration is raised in the
writer instructions.

### Resolved validation set and sources for step 3 tools-archive-rebuild (exchange 1) (round 1)

The reviewer ran the union of the request validation set and the current
resolver set. The union is the same two commands, and both were executed in this
round.

- `bash src/utils/lint_shell.sh`, source `project`. Re-resolved from the
  versioned declaration and run through the project environment so the pinned
  ShellCheck resolved. Result: `lint_shell: 58 tracked scripts`, then
  `lint_shell: clean`, exit 0. The count moved from 57 to 58 for a documented
  reason rather than an unexplained one: that gate's scope is every tracked
  `*.sh` outside `docs/`, so the new `src/` helper joins it while the new
  `docs/` harness does not, and the harness is instead linted and ShellChecked
  by the cumulative runner this step extends. The reviewer read the gate to
  confirm that rather than assuming it.
- `bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 3 --python
  /usr/bin/python3 --app-repo <owned-app-snapshot>`, source `plan`. This is a
  native command against an absolute host snapshot, so it cannot run on the
  authoring host as written. The reviewer executed exactly that command on the
  native host through the disclosed ignored transport, which overlays the five
  current sources onto the snapshot first. Result: `validation exit=0 elapsed=50s`.

Caller evidence retained inside the artifact home, not in versioned notes:
`a.code-review.s3-native-validation.log` (the full remote validation log) and
`a.code-review.s3-d10-head.txt` (the baseline used for the line recount).

### Resolver drift and direction for step 3 tools-archive-rebuild (exchange 1) (round 1)

No drift in either direction.

Re-resolving the project floor from the versioned `.review-validation` yields
the same single `project` command the request carries, and the request's one
`plan` addition parses through the current resolver contract, so the union
equals both sets. The plan addition changed identity since Step 2, which is
expected for an effort-scoped addition, and the declaration file itself was
correctly left alone.

### Repository state around validation for step 3 tools-archive-rebuild (exchange 1) (round 1)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher rather than from equivalent Git commands.

- Request-time index tree `41ab4043949704dc8abd4d395bcc36684939941f` equals the
  baseline captured at entry and the live index captured after both validation
  runs and the implementation check. No drift, so no fresh baseline was needed.
- Umbrella digest comparison over
  `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`: `applicable: true`,
  `changed: false`, before and after both
  `0218245242f1ccec3561ef41f23322e0c6c2f3a12e69981a8fc1c9698e769fc6`, the same
  digest observed in the Step 1 and Step 2 rounds. No umbrella row was completed
  from reviewer mode.
- Validation-state comparison over the ordered path set, holding all seven
  staged step paths and the file named by the project command: `acceptable:
  true` with empty `tracked_paths`, `untracked_paths` and `ignored_paths`. The
  native run executes inside an owned host snapshot and left no tracked side
  effect here to report, stage or revert.
- Final working-tree state matches entry exactly: the seven staged paths plus
  one unstaged modification to the versioned review transcript, which is the
  protocol's own append and is correctly left unstaged by the reviewer. This
  round produced no reviewer residue of its own, since nothing was compiled or
  measured locally.
- Reviewer-authored evidence stayed inside the artifact home as ignored `a.*`
  files, so none of it became a tracked side effect of this review.

### Repair inventory for step 3 tools-archive-rebuild (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 3 tools-archive-rebuild (exchange 1) (round 1)

`a.commit` remains accurate; the reviewer amended nothing.

The mechanical result is an independent
`commit-plan-check.bat --format json` rerun against the received state rather
than the value embedded in the request: `state: valid`, `ready: true`, exit 0,
no diagnostics. Its seven staged paths and three ordered groups match the
request payload exactly.

- Group 1, `feat(d10): measure exact wheel consumers`: the Python helper, its
  Bash wrapper and the D10 module. Least dependent and correctly first, since
  the harness and the recorded evidence both describe this behavior.
- Group 2, `test(d10): cover wheel identity and convergence`: the new fixture
  harness and the cumulative runner that composes it.
- Group 3, `docs(tools-archive-rebuild): record step 3 validation`: the Step 3
  capture and the validation plan, which record results the first two groups
  produce.

Ordering is least to most dependent, every staged path appears exactly once,
and each subject is a conventional single-purpose line whose type matches its
content: `feat` for the new measurement input, `test` for the fixtures, `docs`
for the record. Scope matches the step: the one path beyond the plan's explicit
list is the Python helper beside its named Bash wrapper, which the step's own
addendum anticipates when it applies the Python ceiling to any Python
introduced here, and that file is 258 lines.

No application source is staged in this step, which matches the plan: Step 3
extends measurement input only, and live wheel wiring belongs to Step 4.

### Findings and boundaries for step 3 tools-archive-rebuild (exchange 1) (round 1)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 3 tools-archive-rebuild (exchange 1) (round 1)

No rework is required for Step 3, and nothing in the staged content needs to
change before the human decides.

One thing improved since the previous round and is worth recording, because a
review that only names faults teaches nothing: the Step 3 request keeps the
companion locator out of its authored text, using a snapshot path and an
explicit revision instead of the private repository name and home path that the
Step 2 request put into the versioned transcript. The staged Step 3 documents
are clean of private identifiers as well, which the reviewer verified by
searching them.

Three observations remain, all in ignored review scratch or in the declaration
rather than in tracked content, so none forces another round:

- The plan-sourced command is declared as a native command containing an
  absolute path inside an ephemeral host scratch directory. It therefore cannot
  be run from the authoring host as declared, and once that directory is cleaned
  nobody can re-run it, including a later reader of this transcript. Steps 1 and
  2 had the better shape: declare a self-transporting wrapper in the artifact
  home and let it own the snapshot, so the declared command stays runnable.
- The bundle builder, remote driver and overlay tar for this step again sit at
  the project root rather than in the artifact home beside the wrappers that
  read them.
- Two small consistency points inside the new work, neither of which changes a
  result. The new `defines` reporting loop expands an associative array without
  the guarded expansion idiom the rest of that module uses for exactly this
  hazard, which is safe on the Bash 5 versions this effort targets but
  inconsistent with its neighbours. And several harness assertions are bare
  test or `grep -q` commands relying on `set -e`, so a failure there exits
  without naming which assertion failed, unlike the helper that prints a
  diagnostic.

When the exchange reaches the human gate, the registered choices are "Rework and
review again" and "Commit". The commit decision belongs to the human, not to
this reviewer and not to the requestor.

### Decision rationale for step 3 tools-archive-rebuild (exchange 1) (round 1)

The recommendation is commit-ready, and it is advisory only: it does not
authorize a commit.

All six readiness-floor results pass:

1. Identity. The live context, the machine envelope, the human-readable
   request, the plan, the declared step, the positive round and the
   request-time index tree agree exactly. Step 3 exists in the named plan with
   the work this change implements.
2. Completeness. The inventory adapter, the D10 wheel roots and the native
   fixtures meet the step's completion boundary: additional wheel demands can
   change the selected generation, every missing or mismatched input is
   inconclusive, and archive-only callers keep their behavior.
3. Validation and coverage. Both resolved commands were run. The lint floor is
   clean, and the native run passed with the independent 3.9.25 interpreter,
   with 49 D10 cases, 16 record units, 15 transport tests, 6 entry tests, 25
   SQLite checks and 254 frozen controls all confirmed inside the full log the
   reviewer copied back. Coverage limits are stated rather than assumed, and the
   new helper's exercise was established statically plus by the native cases.
4. Staged attribution. The reviewer made no repair, so nothing is attributed to
   it. The tree holds its seven staged paths plus the protocol's own unstaged
   transcript append, and this round left no reviewer residue.
5. Unresolved findings. None carried in, none raised as blocking.
6. `a.commit`. An independent rerun returns `valid` and `ready` with the same
   groups, ordering and subjects.

No substantive repair was made in this round, so the recommendation is not
disqualified by the same-round rule.

Several claims were verified by measurement rather than accepted, because this
step's value is precisely that its inputs are identity-checked:

- All five recorded LF source hashes match, and the capture's recorded digest
  for its own raw log matches that file.
- Every recorded line count matches, including the D10 before-and-after pair:
  the 524 baseline was checked against `HEAD` and reconciles exactly with the
  staged diff's 126 insertions and 20 deletions to give 630.
- The single-walk performance claim is not taken on trust: the harness counts
  real `readelf` and `find` calls at the process boundary and asserts they are
  unique, and the reviewer confirmed the recorded line `walks=2 readelf=8` in
  the native log.
- The lint gate's count moving from 57 to 58 while two shell files were added is
  fully explained by that gate's documented scope, which excludes `docs/`; the
  new harness is linted by the cumulative runner instead. The reviewer read the
  gate to establish this rather than inferring it from the number.

One clarification that belongs in the record: the `ghog day` exit 5 mentioned in
the validation plan is not a failed gate for this repository. The versioned
declaration deliberately makes shell lint the project floor because cplx has no
pytest project, so `ghog day` is not in the resolved mandatory set here, and the
declared floor ran clean.

Three observations are reported to the writer without being raised as blocking
findings: the plan-sourced command's dependence on an ephemeral host path, which
makes the declaration unrunnable later even though this round's evidence is
real; the review scratch again living at the project root; and two small
internal consistency points that change no result. None of them affects any
readiness-floor result, and all three sit in ignored scratch or in the
declaration rather than in the staged work.

What this answer does not claim: no real Debian wheel capture, no candidate, no
release-record pass, no publication and no adoption. The separately attempted
frozen Step 7 run that ran out of scratch space is disclosed by the writer and
is outside this step's gate. Step 4 owns live wiring, Step 6 the final proof,
and the umbrella row stays pending.

### Final reviewer decision for step 3 tools-archive-rebuild (exchange 1) (round 1)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-3-round-1 -->

## Round 1 by human - Step 3 - human-confirmation

- Recorded: 2026-09-17T15:23:15+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 3
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-1 -->

## Round 1 by requestor - Step 4

- Recorded: 2026-09-17T17:53:47+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 4
- Outcome: request

### Review identity for step 4 tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 4
Review round: 1

### Code review evidence for step 4 tools-archive-rebuild (round 1)

request_index_tree: da030eb1cbc0e705a44a3d09da0ffd833fb8b01f
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 4 --python /usr/bin/python3 --app-repo ../app (sources: plan)
- ghog day (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: test(tools): qualify candidate agent integration
group 1 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 1 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2: docs(tools-archive-rebuild): record step 4 validation
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 4 tools-archive-rebuild (round 1)

Yes. Step 4 has been fully implemented, at the fixture/wiring completion
boundary defined by its plan and Q03. The implementation-check result is in
docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md, Step 4.

Native RHEL 9.8 validation used fresh owned copies of both repositories,
independent /usr/bin/python3 3.9.25 and pinned ShellCheck 0.10.0. The cumulative
Step 4 runner passed in 52 seconds with shell lint/syntax, Python compilation,
27 agent shell cases plus adapter fixtures, 49 D10 cases, 16 record tests,
15 transport tests, six publication tests, current SQLite controls and
254 historical closure cases. Two later test-only additions (hook roundtrip
and legacy SQLite bundle assertions) passed in a final focused run in one
second, with 29 shell cases. Production sources match the cumulative run.

The application authoring ghog day completed at 2026-09-17T17:42:56+02:00,
exit 0, with static/type/style/architecture checks passing. Its full walk took
4m 30.8s: coverage 100%, zero failures, zero duration outliers, three warnings
and eight expected failures. Coverage measures src/pdfss, not CI adapters.
Adapter exercise comes from explicit native integration fixtures and static
references; no adapter coverage percentage is claimed.

Retained source hashes, command results, line counts and raw-log hashes are in
docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt.
Local full captures are a.tools-step4-native-full.log,
a.tools-step4-focused.log and ../my-project/a.ghog.log.

No new application domain type or runtime dependency was introduced. New
Python adapters are 1-187 physical lines and the Python fixture is 172.
Responsibilities are divided among transport, bundle validation, wheel
selection, ABI observation, pytest hooks and evidence validation. Indexing,
inventory and hashing are linear in their inputs; there is no new all-pairs
scan or sort. Existing Jenkins timeouts remain unchanged.

Release-pin provisioning and independent SQLite diagnostics remain covered.
Actual final-archive Jenkins/Debian and native RHEL acceptance are Step 6,
after Step 5 builds the archive. No publication, release-pin change, final
candidate pass or umbrella completion is claimed. The raw-Python/UV_PYTHON
bypass remains as explicitly allowed pending wrapper-to-uv acceptance.

### Implementation report for step 4 tools-archive-rebuild (round 1)

The main application chain now selects complete pinned candidate inputs,
requires explicit publication off, verifies both archive and independent
bundle hashes before extraction, and retains the selected identities.
Conflicting legacy/candidate/verifier inputs fail. Release transport remains
available; verifier-only pins provide independent controls for release
acceptance. The legacy SQLite bundle form remains supported through the
shared transport helper and its existing acceptance checks.

Bundle extraction rejects traversal, links, special files and conflicting
members before writing. Control revision and manifest bytes are checked
again before use. Runtime capture retains only the actual executor container
and image IDs. Relocation rechecks archive bytes, and one resolved raw
interpreter plus derived venv feeds sync, ABI and tests; packaging uses the
same prefix.

Installed wheel tags resolve to exact uv.lock artifacts. The raw downloads,
lock and Step 3 installed-byte inventory are retained. Temporary URL-bearing
selection data is removed on both success and failure. No wheel ELF is
rewritten. The rsync shim, tools-patch fetch, patch-wheels implementation and
Groovy calls are removed.

The blocking ABI entry delegates closure policy to the independent checker,
inventories toolchain and venv ELFs once, retains loader maps and direct-venv
LD_DEBUG=libs,versions traces, and rejects unresolved versions, outside
providers, escaped aliases and inconclusive observations. Inherited OneAgent
exclusions, virtual-kernel entries, loaders and system-interpreter helpers
remain visible without added monitoring provenance conditions.

The full-test entry keeps coverage and testmon active, uses supported
--testmon-noselect with fresh state, records actual plugin configuration and
interpreter identity, and requires conclusive collected/executed counts,
100% coverage and full passing execution of both SQLite-guarded suites.
Existing platform skips remain explicit. Jenkins archives all retained
evidence and propagates gate failures.

cplx holds the cumulative runner, isolated transport/provisioning fixtures,
ABI/parser/wheel/plugin/evidence fixtures and the checked validation record.
The tests refuse missing app checkout input rather than silently skipping it.

### Change summary for step 4 tools-archive-rebuild (round 1)

This step spans two repositories, as the plan explicitly declares.
The protocol request_index_tree and typed commit-plan result cover cplx.
The companion application evidence below additionally fixes its reviewed
index, patch and separate commit plan; it is not part of cplx's Git index.

cplx root: C:/Users/vonc/git/cplx
Starting HEAD: 863933eeedb21bac5bfa7a662d1a0d25a048a079

cplx staged paths:

- docs/v0.27.0/fixtures.tools-release-agent.py
- docs/v0.27.0/verify.tools-archive-rebuild.sh
- docs/v0.27.0/verify.tools-release-agent.sh
- docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt
- docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

cplx a.commit groups, in order:

1. test(tools): qualify candidate agent integration (the three fixtures/runners)
2. docs(tools-archive-rebuild): record step 4 validation (evidence and validation)

Application root: C:/Users/vonc/git/my-project
Starting HEAD: 489bbbde741328ab7953e2338a29952cd1a9f18c
Companion index captured with capture_index_tree:
a10f56c4f17f09bc32296b1726b9235098de64b3
Retained patch: .reviews/a.step4.app-staged.patch
Patch SHA-256: 6b3acabd1ced06a489cbcebc6f58a8c443555211f9c83da8f5e643ee57573dd0

Application staged paths:

- Jenkinsfile
- ci/Jenkinsfile.diagnostics
- ci/Jenkinsfile.relocation
- ci/__init__.py
- ci/provision_toolchain.sh
- ci/tools_abi_acceptance.sh
- ci/tools_abi_scan.py
- ci/tools_agent_identity.sh
- ci/tools_candidate.sh
- ci/tools_candidate_bundle.py
- ci/tools_test_acceptance.sh
- ci/tools_test_evidence.py
- ci/tools_test_plugin.py
- ci/tools_wheel_capture.py
- tools/sqlite_candidate_capture.sh

Application a.commit has one separate coherent group:
ci(tools): qualify pinned candidate archives.
tools/publish.mode was already tracked off and is unchanged.

Both root a.commit files were formatted through wac and passed the canonical
commit-plan readiness checker with status 0, ready=true, no diagnostics.
Copies are .reviews/a.step4.cplx-commit-plan.md and
.reviews/a.step4.app-commit-plan.md. No commits have been made.

Review all listed paths in both repositories. Application repairs, if needed,
must stay staged in that repository and be identified with an app: prefix in
the answer, so the writer can assess the companion commit and refresh its
fixed evidence. Neither repository's commit plan authorizes a commit by itself.

### Writer response for step 4 tools-archive-rebuild (round 1)

Writer response:

This is the first implementation review round for Step 4 in this invocation.
No earlier Step 4 reviewer feedback or disagreement is being carried forward.
The user asked to resume implementation of this exact plan step.

The plan's declared cplx validation floor is bash src/utils/lint_shell.sh;
cplx has no configured pytest/groundhog project. The separate application
authoring checkout uses ghog day. Keep both obligations and the native
cumulative Step 4 runner in the validation assessment.

Native commands must run on native Linux against fresh owned copies of cplx
and the explicit app checkout. Existing ignored transport scripts are
a.tools-step4-transport.sh and a.tools-step4-native.sh. From the cplx Windows
root, the established transport command is:

```cmd
cmd /d /c "set NO_MORE_SENV_cplx=& senv.bat && bash a.tools-step4-transport.sh cumulative"
```

The native helper prints its owned /var/tmp snapshot path and keeps the full
validation.log there. It supplies a compiler-only wrapper and an independent
Python; it does not alter a live installation. Its app checkout is ../app
relative to that snapshot's cplx directory.

For the app authoring walk, use its Windows launcher from the app root with
PRJ_DIR explicitly set in the same CMD process because the caller environment
can still identify cplx. Use the documented detached/status mode for long work:

```cmd
cmd /d /c "set PRJ_DIR=%USERPROFILE%\git\my-project& %USERPROFILE%\git\llm-shared\bin\ghog.bat day --detach"
```

Respect the current passing evidence; rerun what the reviewer needs to
establish its independent validation, and rerun affected checks after repairs.
The reviewer must not claim actual final archive/agent acceptance for Step 4.

### Reviewer focus for step 4 tools-archive-rebuild (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-4-round-1 -->

## Round 1 by reviewer - Step 4

- Recorded: 2026-09-17T18:27:23+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: answer

### Assessed index identity for step 4 tools-archive-rebuild (exchange 1) (round 1)

Baseline index tree: da030eb1cbc0e705a44a3d09da0ffd833fb8b01f

Assessed index tree: da030eb1cbc0e705a44a3d09da0ffd833fb8b01f

### Implementation check for step 4 tools-archive-rebuild (exchange 1) (round 1)

Result:

No. Step 4 has NOT been fully implemented.

Almost all of the step is present and good, and the reviewer's own validation
runs all pass. The status is No for one reason: the main chain this step is
supposed to wire cannot complete an ordinary release build in the repository's
current tracked state, and Step 4's own stated intent is to preserve ordinary
release-pin provisioning.

What the reviewer verified as implemented and correct:

- The retirements the plan demands are complete. The rsync shim, the
  tools-patch-2 libstdc++ fetch, the whole `patch-wheels` implementation, its
  `all` entry and its Groovy caller are gone, and the wiring fixture asserts
  that none of `patchVenvElves`, `patch-wheels`, `tools-patch`, `RSYNC_SHIM`,
  `--no-cov` or `no:pytest-testmon` survives anywhere in the three files.
- The raw-Python bypass is retained with its reason, as the plan allows pending
  wrapper-to-uv acceptance, and the fragile `find | head -1` interpreter pick is
  replaced by `tools_python_path`, which now fails on ambiguity instead of
  silently choosing. `uv sync --locked` replaces `uv sync`.
- `ci/tools_candidate.sh` validates pins strictly: exact key set and count per
  format, verifier-only pins refusing archive keys, duplicate keys refused,
  HTTPS-only URLs with no embedded credentials and no whitespace, digest
  re-checked after download, and conflicting legacy, candidate and verifier
  inputs refused. Candidate provisioning requires publication explicitly off.
- `ci/tools_candidate_bundle.py` checks every member before writing anything:
  a top-level whitelist of `src` and `acceptance`, refusal of absolute names,
  traversal, backslashes and control characters, non-regular members including
  symlinks, duplicates and file/directory collisions, plus manifest coverage
  that must equal the bundle's regular members exactly and a source revision
  that must match the pin. The legacy SQLite form stays readable under its own
  format name and gets a locally written manifest.
- `ci/tools_abi_scan.py` is a genuine blocking replacement for a probe that
  ended in `exit 0`. It walks tools and the venv once, canonicalizes aliases and
  refuses any alias escaping the prefix, refuses outside-prefix providers,
  unresolved versions, unparsed loader lines, an empty or monitoring-only
  observation, an empty inventory and a walk with no dynamic subject measured.
  It verifies the venv interpreter identity against the toolchain base and
  requires exactly one direct-venv `LD_DEBUG=libs,versions` trace in which both
  heavy wheels actually initialize. The reviewer checked the removed 118-line
  probe and confirms the scope is genuinely widened rather than moved.
- The `system-interpreter-helper` category, which reports a `tools/bin` subject
  whose interpreter lies outside the prefix instead of refusing it, is not
  inherited from the old probe as the request states, because that probe never
  inventoried `tools/bin`. It is nevertheless authorized: the settled design
  says "Retained helper programs with system interpreters are reported
  separately from candidate execution", and the requirement says the same.
- The full-test gate matches the plan closely. `ci/tools_test_plugin.py`
  refuses a walk unless both plugins are loaded, testmon runs in collect-without-
  select mode, and no ambient selector is present, and it takes counts from
  hooks rather than console text. `ci/tools_test_evidence.py` independently
  refuses a walk whose executed plus setup-skipped count does not equal the
  collected count, any deselection, inactive plugins, a guarded SQLite suite
  that did not run to completion, and missing or sub-gate coverage output. The
  reviewer confirmed the two options the guard cannot set itself,
  `--cov=src/pdfss` and `--cov-fail-under=100`, do come from the project's own
  `addopts`, so the guard passes on a real run rather than refusing every run.
- `ci/tools_wheel_capture.py` resolves installed distributions to exact locked
  artifacts by name, version, full tag set and build tag, requires exactly one
  match, and refuses a non-registry install other than the editable first-party
  project. `ci/tools_agent_identity.sh` records container and image identity
  without ever printing the inspect response, and refuses when the real image
  identity is unavailable. URL-bearing selection data is removed on success and
  failure, and only filename and digest are retained.

#### Missing work for Step 4 for step 4 tools-archive-rebuild (exchange 1) (round 1)

- Make an ordinary release build provision again. `do_venv` resolves
  `tools_verification_path` unconditionally for its wheel-capture block, and
  `ci/tools_abi_acceptance.sh` does the same for the closure checker, but
  neither `tools/tools.candidate` nor `tools/tools.verification` exists or is
  tracked, nothing in the pipeline creates one, and no document states that a
  verifier pin is now required. The reviewer reproduced the consequence in
  isolation with only `tools/publish.mode` present: `controls=$(tools_verification_path)`
  exits 2 and prints "Candidate pin missing", so the unconditional Provision
  stage, and then the Test stage, fail. Either scope those two dependencies to
  the modes that genuinely need independent controls, or require a verifier pin
  explicitly and early with a diagnostic that names it, and then track or
  document how a release build obtains one. A release build should not fail
  deep inside venv creation with a message about a candidate pin.
- Add a fixture that runs `provision_toolchain.sh venv` in release mode without
  any pin. The current harness covers `select`, `fetch`, `relocate` and
  `venv-path`, and exercises release mode only through `select` and a
  verifier-pinned fetch, so no existing case can catch this. Step 4's own
  purpose includes reducing the risk of discovering basic pipeline wiring
  defects only during Step 6.
- Decide and record what the verification-only `sqlite` format should require.
  Routing it through `tools_candidate_read` now applies the candidate
  publication-off rule that the removed inline parser never applied, so with
  `tools/publish.mode` restored to `snapshot`, as Step 7 plans, the SQLite
  diagnostic stops producing evidence while remaining non-gating and quiet.
  Either exempt the verification-only format as the verifier format already is,
  or state the new coupling where an operator will see it.
- Correct the Step 4 rows of the validation plan once the above is settled:
  they currently record `Yes. Step 4 has been fully implemented.`
- Optionally cover the `system-interpreter-helper` branch with a fixture. Every
  sibling refusal axis has one, and this authorized exception is the only
  provider-accounting path whose behavior is established solely by a live run.

Architecture: responsibilities are cleanly divided across transport, bundle
validation, wheel selection, ABI observation, test hooks and evidence
validation, and no application domain code is touched. The shared ELF reader
remains the only ABI interpreter. Nothing else needs fixing here.

Performance: indexing, inventories and hashing are linear in their inputs, each
root is walked once, and no new sort or all-pairs scan appears. Existing Jenkins
timeouts are unchanged. No performance issue needs addressing.

Unit test coverage: no application class changed, and the new CI adapters sit
outside the application's measured `src/pdfss` scope, which the documents state
rather than assume. Their exercise is the native integration fixtures plus
static reference review. Two gaps are named in the missing work above rather
than counted as coverage. No unit-tested class below 100% needs completing, and
no top-level symbol outside the coverage gate is unreferenced.

Feature integrity: candidate transport, bundle refusals, ABI refusals, the test
gate and the SQLite diagnostic's shared transport are all exercised and pass,
and the packaged and tested venvs hold the same unmodified wheel bytes. The
impairment is the release path named above. No publication, release-pin change,
final candidate pass or umbrella completion is claimed, and the real Jenkins and
Debian acceptance remains Step 6's work.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, and that was a
deliberate choice rather than an omission.

Reviewer mode may write the reviewed step's validation rows, and those rows
count as review metadata rather than a substantive change. The reviewer did not
use that permission here because this round returns `changes-requested`: the
writer will rework the step and must then restate its own verdict, so flipping
the rows now would change the staged index mid-round, require a fresh baseline
and attribution, and still be overwritten. The correct record is the one the
writer produces after the rework.

What the writer must correct there is named in the missing-work list: the Step 4
rows currently record `Yes. Step 4 has been fully implemented.`, which does not
match this assessment.

The rest of those rows was checked against the template and is otherwise sound:
the section set is complete, each check section carries its required closing
phrase, the coverage section names the measured scope and adds the second phrase
about symbols outside it, and the document-level line correctly remains
`No, it is not implemented.`

Because no validation-plan path was edited, no pre-repair blob was recorded and
no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 4 tools-archive-rebuild (exchange 1) (round 1)

Every resolved mandatory command was run by the reviewer in this round, before
any repair could have been made, and all three pass. The finding below is not a
failing command: it is behavior no command in this set exercises.

Project floor: `lint_shell: 58 tracked scripts`, `lint_shell: clean`, exit 0.

Native cumulative runner at `--step 4` on RHEL 9.8 with the independent
`/usr/bin/python3` 3.9.25: `validation exit=0 elapsed=51s`. The reviewer copied
the whole remote log back rather than trusting the printed tail, and confirmed
inside it:

- `Independent interpreter: /usr/bin/python3 3.9.25` at the top.
- `Agent shell fixtures: 29 cases passed; parser and wiring fixtures passed`.
- `PASS hook-evidence-roundtrip` and `PASS hook-platform-skip-evidence`.
- `D10 fixtures: 49 cases passed`.
- `Ran 16 tests` / `OK`, `Ran 15 tests` / `OK` and `Ran 6 tests` / `OK`.
- `SQLite closure: 25 checks passed`.
- The frozen publication verdict with `failures 0`.

The writer's versioned capture records 27 agent cases for its cumulative run
plus a separate focused run of one second for two later test-only additions,
and states that production sources match the cumulative run. That disclosure is
accurate, and this reviewer's single run over the final tree supersedes it by
covering everything in one pass at 29 cases.

Application walk: as declared, `ghog day` again returned exit 0 while measuring
nothing, reporting no changed Python file and `cov=skipped`. This is the third
consecutive round in which the declared application command cannot produce its
own evidence, so the reviewer forced a complete walk, alone on the machine to
keep its duration measurements clean. Result: `fail=0 warn=3 xfail=8 cov=100
outliers=0 excluded=0 exit=0`, objective reached, reproducing the recorded
result.

Coverage limits stated rather than assumed: the application gate measures
`src/pdfss`, so its 100% says nothing about the new CI adapters. Their exercise
is the native integration fixtures plus static reference review, and the two
places where that exercise is absent are named as missing work rather than
counted as coverage.

Independent identity binding of the evidence to the reviewed bytes:

- All 17 LF-normalized SHA-256 values and all 17 line counts recorded in the
  Step 4 capture were recomputed across both repositories and every one matches.
  The bookkeeping is accurate; the findings concern behavior, not the record.
- The companion staged tree recomputed to `a10f56c4f17f09bc32296b1726b9235098de64b3`
  and its HEAD to the recorded starting revision, both exactly as recorded.

One methodological note, because it changed a conclusion. Reading pytest's
installed source suggested that the acceptance plugin's
`config.getoption("no-testmon")` would raise, since option-to-dest keys carry
their dashes, which would have been a latent crash in the blocking gate. The
reviewer probed the real behavior with the application's own interpreter,
pytest 9.1.0 and pytest-testmon 2.2.0 instead of reporting it: `"no-testmon"`
resolves and `"no_testmon"` is the spelling that raises, because that plugin
declares a hyphenated dest. The line is correct as written, and the fixture's
configuration double could not have shown either way.

### Resolved validation set and sources for step 4 tools-archive-rebuild (exchange 1) (round 1)

The reviewer ran the union of the request validation set and the current
resolver set. All three commands were executed in this round and all three pass.

- `bash src/utils/lint_shell.sh`, source `project`. Result:
  `lint_shell: 58 tracked scripts`, `lint_shell: clean`, exit 0, run through the
  project environment so the pinned ShellCheck resolved.
- `bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 4 --python
  /usr/bin/python3 --app-repo ../app`, source `plan`. Run on the native RHEL
  host through the disclosed transport, which takes fresh owned copies of both
  repositories. Result: `validation exit=0 elapsed=51s`. The relative
  `--app-repo` is an improvement over the previous step's absolute snapshot path.
- `ghog day`, source `plan`. Run in the application checkout, which is where the
  writer response and the plan's Step 4 addendum place it. As declared it
  returned exit 0 while measuring nothing, reporting that no Python file had
  changed since the last green walk and `cov=skipped`, so the reviewer forced a
  complete walk and used that as the mandatory evidence.

Caller evidence retained inside the artifact home, not in versioned notes:
`a.code-review.s4-native-validation.log` (the full remote validation log),
`a.code-review.s4-app-ghog.log` and `a.code-review.s4-app-ghog-force.log` (the
declared walk and the forced walk).

Two isolated reproductions supporting the findings were run outside both
repositories, in the reviewer's scratch area, and changed nothing in either
tree: one sourcing `ci/tools_candidate.sh` with only `tools/publish.mode`
present to observe `tools_verification_path`, and one probing real pytest option
resolution with the application's own interpreter and plugins.

### Resolver drift and direction for step 4 tools-archive-rebuild (exchange 1) (round 1)

No drift in either direction, with one ambiguity worth naming.

Re-resolving the project floor from the versioned `.review-validation` yields
the same single `project` command the request carries, and both `plan`
additions parse through the current resolver contract, so the union equals both
sets.

The ambiguity is in the second plan addition rather than in the resolution:
`ghog day` carries no repository context. Resolved for a cplx review it would
run in cplx, where the versioned declaration deliberately avoids it because
this repository has no pytest project, and it exits 5 there. The writer response
states the intended target is the separate application checkout, and the plan's
Step 4 addendum says to run the application authoring walk, so the reviewer ran
it there. A declaration that named its repository would remove the guesswork.

### Repository state around validation for step 4 tools-archive-rebuild (exchange 1) (round 1)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher rather than from equivalent Git commands.

- Request-time index tree `da030eb1cbc0e705a44a3d09da0ffd833fb8b01f` equals the
  baseline captured at entry and the live index captured after all three
  validation runs, both reproductions and the implementation check.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `0218245242f1ccec3561ef41f23322e0c6c2f3a12e69981a8fc1c9698e769fc6`,
  the same digest seen in every earlier round of this effort. No umbrella row
  was completed from reviewer mode, and none should be while Steps 4 to 7 are
  open.
- Validation-state comparison over the ordered path set, holding all five
  staged step paths and the file named by the project command: `acceptable:
  true` with empty `tracked_paths`, `untracked_paths` and `ignored_paths`.
- Both working trees match their entry state exactly: five staged paths plus the
  protocol's own unstaged transcript modification here, and the fifteen staged
  paths in the companion checkout with nothing else. The companion index tree
  still recomputes to its recorded identity.
- This round produced no reviewer residue. The native run executes inside an
  owned host snapshot, and the two reproductions supporting the findings ran in
  the reviewer's scratch area outside both repositories, one with copies of a
  single script and a synthetic workspace, the other with a throwaway pytest
  project. Neither touched a repository file.
- Reviewer-authored evidence stayed inside the artifact home as ignored `a.*`
  files, so none of it became a tracked side effect of this review.

### Repair inventory for step 4 tools-archive-rebuild (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 4 tools-archive-rebuild (exchange 1) (round 1)

`a.commit` remains accurate for what is staged; the reviewer amended nothing.

The mechanical result is an independent
`commit-plan-check.bat --format json` rerun against the received state rather
than the value embedded in the request: `state: valid`, `ready: true`, exit 0,
no diagnostics. Its five staged paths and two ordered groups match the request
payload exactly.

- Group 1, `test(tools): qualify candidate agent integration`: the Python
  fixture module, the agent harness and the cumulative runner.
- Group 2, `docs(tools-archive-rebuild): record step 4 validation`: the Step 4
  capture and the validation plan.

Ordering is least to most dependent, every staged path appears once, and each
subject is a conventional single-purpose line. The companion repository's
separate plan was checked the same way in its own checkout and is also `valid`
and `ready`, with its 15 staged paths in one coherent
`ci(tools): qualify pinned candidate archives` group.

Two notes rather than corrections, since a commit is not authorized by this
round anyway:

- The eight new application `ci/` helpers are not named in the plan's Step 4
  file list, but each maps onto a responsibility that list does assign, and the
  effort's own baseline section allows new Python files up to the repository
  ceiling of 650 lines. The largest is 187. The reviewer therefore treats them
  as in scope. The Step 4 line-budget checkpoint's phrase "no Python growth"
  reads naturally as no existing Python file growing, and a clarifying word in
  the plan would remove the ambiguity for the next reader.
- Group 2 will need to be re-recorded after the rework, since it carries the
  validation rows this answer contradicts.

### Findings and boundaries for step 4 tools-archive-rebuild (exchange 1) (round 1)

Unresolved findings:

- app:ci/provision_toolchain.sh `do_venv` and app:ci/tools_abi_acceptance.sh both resolve `tools_verification_path`, which returns 2 with "Candidate pin missing" whenever neither `tools/tools.candidate` nor `tools/tools.verification` exists, so the unconditional Provision and Test stages fail for an ordinary release build in the repository's current tracked state, against Step 4's requirement to preserve ordinary release-pin provisioning.
- app:ci/tools_candidate.sh `tools_candidate_read` applies the candidate publication-off rule to the verification-only `sqlite` format, which the inline parser it replaces never did, so restoring `tools/publish.mode` to `snapshot` as Step 7 plans would stop the non-gating SQLite diagnostic from producing its evidence.

Boundary-crossing work: None.

### Writer instructions for step 4 tools-archive-rebuild (exchange 1) (round 1)

Two concrete changes are required, both in the companion repository, plus the
validation-plan correction. Keep every repair staged in that repository.

1. Restore ordinary release-build provisioning.

   `app:ci/provision_toolchain.sh` `do_venv` resolves `controls=$(tools_verification_path)`
   unconditionally for its wheel-capture block, and `app:ci/tools_abi_acceptance.sh`
   resolves the same path for the closure checker. `tools_verification_path`
   requires either a candidate pin or a verifier pin. Neither
   `tools/tools.candidate` nor `tools/tools.verification` exists or is tracked,
   the Jenkinsfile creates neither, and no document states that a verifier pin is
   now required for every build.

   Reproduction, with only `tools/publish.mode` containing `off` present:
   `tools_candidate_select` prints `release`, then
   `controls=$(tools_verification_path)` exits 2 printing `Candidate pin missing`.
   The `Provision` stage calls `provisionVenv()` with no `when` guard, and the
   `Test` stage calls `abiContract()` the same way, so both fail.

   Either is acceptable, and the choice is the writer's because it is a policy
   decision this reviewer will not make:

   - scope both dependencies to the modes that need independent controls, leaving
     an ordinary release build able to provision without a pin; or
   - require a verifier pin for every build, refuse early with a diagnostic that
     names `tools/tools.verification` rather than a candidate pin, and track or
     document how a release build obtains one.

   Then add a fixture that runs `provision_toolchain.sh venv` in release mode with
   no pin present. The current harness covers `select`, `fetch`, `relocate` and
   `venv-path`, and touches release mode only through `select` and a
   verifier-pinned fetch, so nothing in it can catch this class of defect. This
   step exists partly to keep basic wiring defects out of Step 6.

2. Settle what the verification-only `sqlite` format requires.

   Routing `app:tools/sqlite_candidate_capture.sh` through
   `tools_candidate_read ... sqlite` now applies the candidate publication-off rule
   that the inline parser it replaces never applied. Reproduced: with
   `tools/publish.mode` set to `snapshot`, that read refuses with "Candidate
   requires publication explicitly off". Because the diagnostic is non-gating, the
   effect when Step 7 restores snapshot uploads is that it quietly stops producing
   SQLite evidence. Either exempt the verification-only format the way the
   `verification` format already is, or record the new coupling where an operator
   will see it.

3. Correct the Step 4 validation rows, which currently record
   `Yes. Step 4 has been fully implemented.`

Optional, and not required for the next round: cover the authorized
`system-interpreter-helper` branch of `app:ci/tools_abi_scan.py` with a fixture.
It is the one provider-accounting path whose behavior is established only by a
live run, while every sibling refusal axis has a fixture. Worth noting for the
record: that category is authorized by the settled design and requirement, which
both say retained helper programs with system interpreters are reported
separately, but it is not inherited from the probe being replaced, since that
probe never inventoried `tools/bin`. The word "inherited" in the implementation
report is imprecise, and the next reader of that sentence deserves the accurate
version.

Standing items from earlier rounds, all in ignored scratch or in the
declaration rather than in tracked content, so none of them drives this round:

- The declared application command still runs the walk without forcing it, and
  for the third consecutive round it returned exit 0 while measuring nothing.
  The recorded numbers are accurate, but only because the writer forced a walk
  by hand. Adding the forcing flag, or the documented detached mode, would make
  the declared evidence reproducible by whoever reviews it.
- `ghog day` is declared with no repository context. Resolved for a cplx review
  it would run where the versioned declaration deliberately avoids it. Naming
  the target repository in the declaration would remove the ambiguity.
- The review transport scripts and their tar again sit at the project root
  rather than in the artifact home beside the wrappers that read them.
- The request's authored text again names the companion repository by its
  private directory name inside an absolute path under the author's home
  directory, which the protocol appends to the versioned transcript. Step 3
  avoided this and Step 4 reintroduces it. The repository's installed
  sensitive-content pre-commit hook blocks a commit whose staged content matches
  those rules, so this will surface as a blocked commit rather than as leaked
  history; the transcript entries that already exist remain a human decision.
  Use the `app:` label in authored request text and keep the real locator in the
  ignored context file, as Step 1 did.

### Decision rationale for step 4 tools-archive-rebuild (exchange 1) (round 1)

The disposition is changes-requested, on one blocking finding and one smaller
behavioral change in the same file. The readiness floor is recorded as
incomplete, and the reviewer made no repair, so nothing is attributed to it.

Where the six readiness-floor results stand:

1. Identity. Passes exactly, in both repositories: request index tree
   `da030eb1cbc0e705a44a3d09da0ffd833fb8b01f` matches the live index at entry
   and at publication, and the companion tree and HEAD match their recorded
   identities.
2. Completeness. Fails. Nearly all of the step is implemented well, but the
   chain this step wires cannot complete an ordinary release build in the
   repository's current tracked state, and preserving ordinary release-pin
   provisioning is part of Step 4's own stated intent.
3. Validation and coverage. The three resolved commands were run and all pass:
   the lint floor is clean, the native run passed with 29 agent cases, 49 D10
   cases, 16 record, 15 transport and 6 publication tests, 25 SQLite checks and
   254 frozen controls, and a forced application walk reached `cov=100` with no
   failures or outliers. This result is worth reading precisely: the mandatory
   set passes, and the finding is behavior that no command in that set
   exercises. A green validation set is not the same as a working release path.
4. Staged attribution. Passes. Both trees hold only their staged sets, no
   pre-existing work was swept in, and this round left no reviewer residue: the
   two reproductions ran in a scratch area outside both repositories.
5. Unresolved findings. Two, listed in the findings inventory, each with a
   concrete writer action.
6. `a.commit`. Passes mechanically in both repositories, with the note that
   Group 2 carries validation rows this answer contradicts and will be
   re-recorded after the rework.

Why the blocking finding is blocking, stated plainly: `do_venv` and the ABI
acceptance entry both require independently pinned verification controls, no
such pin exists or is tracked, nothing creates one and nothing documents the new
requirement. Reproduced in isolation, `controls=$(tools_verification_path)`
exits 2 with a message about a missing candidate pin, and both the `Provision`
and `Test` stages call their entry points unconditionally. The fix needs a
policy choice between scoping the dependency and requiring a pin everywhere,
which is the writer's to make, so this is returned as feedback rather than
edited. It is also resolvable in one round, which is what separates it from
items this reviewer has previously recorded as observations instead of findings.

What the reviewer chased down and did not report, because checking changed the
answer:

- The ABI gate's `system-interpreter-helper` category looked like an
  unauthorized softening in the very gate this step makes blocking, and the
  request calls it inherited when the replaced probe never inventoried
  `tools/bin`. The settled design and the requirement both specify it, so it is
  authorized and only the word "inherited" is imprecise.
- The acceptance plugin's `config.getoption("no-testmon")` looked like a latent
  crash, since pytest maps option strings to dests with their dashes. Probing
  the real interpreter and plugins showed that spelling resolves and the
  underscored one is what raises. Reading alone would have produced a false
  finding, and the fixture's configuration double could not have settled it
  either way.
- The eight new application helpers are unnamed in the step's file list but each
  maps to a responsibility it assigns, and the effort's baseline section allows
  new Python files up to 650 lines, the largest here being 187. In scope.

Also verified rather than accepted: all 17 recorded source hashes and all 17
line counts match across both repositories, so the evidence record itself is
accurate, and the writer's disclosure that its cumulative capture predates two
test-only additions is precise.

What this answer does not claim: no final archive, no candidate qualification,
no Jenkins or Debian acceptance, no publication and no adoption. Those remain
Step 6's work after Step 5 builds the archive, and this answer authorizes no
commit in either repository.

### Final reviewer decision for step 4 tools-archive-rebuild (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-4-round-1 -->

## Round 2 by requestor - Step 4

- Recorded: 2026-09-17T19:07:40+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: request

### Review identity for step 4 tools-archive-rebuild (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 4
Review round: 2

### Code review evidence for step 4 tools-archive-rebuild (round 2)

request_index_tree: f21d7c09846f2aad1c9cb2ac79b485a580adba5b
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 4 --python /usr/bin/python3 --app-repo ../app (sources: plan)
- powershell -ExecutionPolicy Bypass -File .reviews/a.step4.app-walk.ps1 (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: test(tools): qualify candidate agent integration
group 1 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 1 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2: docs(tools-archive-rebuild): record step 4 validation
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 2 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 4 tools-archive-rebuild (round 2)

Yes. Step 4 has been fully implemented within the plan's fixture and pipeline
wiring completion boundary. Final archive production belongs to Step 5 and
actual Jenkins/Debian and final native candidate acceptance belong to Step 6.

Native validation passed all 33 agent shell cases plus Python ABI, wheel and
test-evidence fixtures, 49 D10 cases, 16 record cases, 15 transport cases,
six publication cases, 25 current SQLite controls and 254 historical closure
cases. The shell lint gate and adapter compilation passed. All 20 current
native input files match the retained successful source snapshot. See
docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt for hashes,
timing, application authoring results and limits.

The forced app-scoped walk finished at 2026-09-17T19:05:35+02:00 with exit 0:
100% coverage, zero failures and zero duration outliers, three warnings and
eight expected failures. The full suite took 4m 54.8s. Both repaired files
also passed ghog single. No real-agent candidate acceptance is inferred.

The new CI adapters remain outside the app coverage source, src/pdfss.
Every top-level adapter symbol has a fixture, package or CLI reference. No
unit-tested application class changed, no new domain dependency was added,
and all new Python files remain below 650 physical lines. Inventory and
manifest processing remain linear. Integration timing repairs retain every
assertion and do not alter coverage or duration gates.

Validation execution notes:

- Cplx is a Bash project. Its .review-validation shell lint floor and the
  plan's native cumulative runner are the applicable gate; cplx has no pytest
  project. Do not install or invent one to execute the typed ghog day default.
- The native command is bash docs/v0.27.0/verify.tools-archive-rebuild.sh
  --step 4 --python /usr/bin/python3 --app-repo ../app. On this Windows
  checkout, .reviews/a.step4.native-gate.ps1 invokes the retained transport
  driver, which creates an owned native snapshot with exactly that layout,
  runs the command and includes bash src/utils/lint_shell.sh. Inspect the
  driver first. It overlays the current sources and retains fresh logs.
- .reviews/a.step4.app-walk.ps1 resolves the private application checkout,
  sets PRJ_DIR explicitly and calls the absolute shared launcher with
  ghog day --force. This is a real application walk, not cplx or a no-op.
  Let a healthy execution finish; do not start another walk concurrently.
- .reviews/a.step4.app-context.json supplies the private app locator. Keep
  that value in ignored evidence and refer to app: paths in authored output.
- Review the current staged application paths as companion evidence. The
  request_index_tree applies only to cplx; the change summary separately
  captures the application index, patch and root a.commit.

The reviewer made no round 1 changes. The writer accepted all findings,
repaired them, and refreshed the evidence and grouping. No commit is authorized.

### Implementation report for step 4 tools-archive-rebuild (round 2)

Step 4 wires the main application's candidate and ordinary release provisioning
to independent verifier controls, one selected prefix, exact wheel capture,
blocking ABI observations and a full test/coverage acceptance entry. It removes
the rsync, tools-patch and wheel-mutation interims while retaining the permitted
raw-Python bypass pending wrapper acceptance. The SQLite diagnostic reuses
verified transport and remains independently selectable.

The repaired release contract fails at preflight if tools/tools.verification
is missing. ci/TOOLS-VERIFICATION.md explains how the job owner delivers that
independent pin. Candidate publication remains suppressed; the SQLite-only
format accepts the pre-existing publication-enabled diagnostic use case.

Cplx's cumulative native fixtures cover those entry points and negative
observations, including the authorized helper interpreter exception. Two
application integration test timing repairs were needed to clear the mandatory
authoring walk. They change setup/input size and preserve all assertions and
real integration paths. No application production behavior changed for timing.

Step 6 still owns live Jenkins/Debian and final RHEL candidate acceptance after
the Step 5 rebuild. No final candidate, publication, release-pin adoption or
umbrella completion is claimed by this implementation.

### Change summary for step 4 tools-archive-rebuild (round 2)

This step spans cplx and the separate application checkout declared by the
plan. The protocol's request_index_tree fixes the cplx index only. Resolve
the companion app root from .reviews/a.step4.app-context.json; keep its private
locator out of authored review text and the versioned transcript.

Cplx starting HEAD: 863933eeedb21bac5bfa7a662d1a0d25a048a079.

Cplx staged paths:

- docs/v0.27.0/fixtures.tools-release-agent.py
- docs/v0.27.0/verify.tools-archive-rebuild.sh
- docs/v0.27.0/verify.tools-release-agent.sh
- docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt
- docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
- docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md

Cplx root a.commit keeps two groups:

1. test(tools): qualify candidate agent integration (the three fixtures/runners).
2. docs(tools-archive-rebuild): record step 4 validation (evidence, validation
   and the versioned review record).

App starting HEAD: 489bbbde741328ab7953e2338a29952cd1a9f18c.
App index captured with capture-index-tree: a130e310e2abc8690abf7766c8a6efd998346e32.
Retained binary patch: .reviews/a.step4.app-staged.patch.
Patch SHA-256: a2f05e321c0286fb2b0d55146fd0d69152f877a6f2caf86f3cb86e14e6c1b6de.
Retained companion commit plan: .reviews/a.step4.app-commit-plan.md.

App staged paths:

- Jenkinsfile
- ci/Jenkinsfile.diagnostics
- ci/Jenkinsfile.relocation
- ci/TOOLS-VERIFICATION.md
- ci/__init__.py
- ci/provision_toolchain.sh
- ci/tools_abi_acceptance.sh
- ci/tools_abi_scan.py
- ci/tools_agent_identity.sh
- ci/tools_candidate.sh
- ci/tools_candidate_bundle.py
- ci/tools_test_acceptance.sh
- ci/tools_test_evidence.py
- ci/tools_test_plugin.py
- ci/tools_wheel_capture.py
- src/pdfss/tests/integration/adapters/inbound/sentinel_service/test_sentinel_auth_lifecycle/test_sentinel_auth_lifecycle_tdd.py
- src/pdfss/tests/integration/application/handlers/test_pdf_processing_handler_polluted_pdf/_synthetic_polluted_samples.py
- src/pdfss/tests/integration/application/handlers/test_pdf_processing_handler_polluted_pdf/test_pdf_processing_handler_polluted_pdf_acceptance_tdd.py
- tools/sqlite_candidate_capture.sh

App root a.commit keeps two groups:

1. test(perf): shorten two integration test calls (the three integration files).
2. ci(tools): qualify pinned candidate archives (the 16 CI/tool paths).

The existing tools/publish.mode was already off and is unchanged. Assess
companion repairs in the app index and name them with app: labels. Commit plans
are prepared for review; no commit has been authorized or executed.

### Writer response for step 4 tools-archive-rebuild (round 2)

Writer response:

All round 1 findings are accepted; there is no disagreement. The reviewer
reported no staged repairs. The writer made the following corrections:

- Ordinary release provisioning now requires an independent
  tools/tools.verification pin at the first pipeline/provisioner preflight.
  The diagnostic names that file and ci/TOOLS-VERIFICATION.md before any venv
  side effects. The documentation describes ownership, delivery, bootstrap,
  exact verifier inputs and refusal behavior. A release tag alone is
  intentionally insufficient for a main build's independent acceptance gates.
- Added a fixture invoking the actual release-mode provisioner without the
  verifier. Its diagnostic assertion failed before the repair, then passed.
  Successful verifier preflight and absence of venv side effects are covered.
- Exempted the diagnostic-only SQLite pin format from candidate publication
  suppression, with an enabled-publication fixture. Candidate/main acceptance
  still requires publication explicitly off.
- Added the optional authorized system-interpreter-helper case and refusal
  after the same ELF moves outside tools/bin.
- Replaced the no-op application walk with an explicitly app-scoped forced
  walk. Its first full suite had 100% coverage but two timing outliers.
  Profile-guided test repairs retain every assertion: prepare real auth
  routes/schema once and use the exact 1000-XObject activation threshold.
  No duration floor, threshold, timeout, xfail or exclusion was relaxed.
- Updated Step 4 validation and both commit plans. The application plan has
  a separate timing-repair group before the CI group. Cplx keeps fixtures
  before its trailing Step 4 validation/documentation group.

Use the private application locator only from .reviews/a.step4.app-context.json.
Use app: labels in authored review text and the versioned transcript.

### Reviewer focus for step 4 tools-archive-rebuild (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-4-round-2 -->

## Round 2 by reviewer - Step 4

- Recorded: 2026-09-17T19:25:27+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: answer

### Assessed index identity for step 4 tools-archive-rebuild (exchange 1) (round 2)

Baseline index tree: f21d7c09846f2aad1c9cb2ac79b485a580adba5b

Assessed index tree: f21d7c09846f2aad1c9cb2ac79b485a580adba5b

### Implementation check for step 4 tools-archive-rebuild (exchange 1) (round 2)

Result:

No. Step 4 has NOT been fully implemented.

Every round 1 finding is genuinely fixed, and the reviewer verified each one by
running the repaired code rather than by reading the writer's account. The
status is No for a different reason: the staged set cannot be committed, because
the repository's own sensitive-content pre-commit hook refuses it.

What the round 2 repairs achieved, each confirmed in the reviewer's own native
run:

- Release provisioning no longer fails obscurely. `tools_provision_select`
  refuses release mode without `tools/tools.verification` and names both that
  file and `ci/TOOLS-VERIFICATION.md`, and it is wired at every entry the
  finding named: the provisioner's own preamble, `tools_verification_path`, a
  new `preflight` subcommand, and the Jenkinsfile's first setup stage. The
  misleading "Candidate pin missing" text is now `Missing <format> pin: <path>`.
  The fixture the reviewer asked for exists and passes: `release-venv-needs-verifier`
  runs the actual provisioner's `venv` entry in release mode with no pin and
  asserts the new diagnostic, alongside `release-preflight-needs-verifier` and
  the positive `verifier-release-preflight`.
- `ci/TOOLS-VERIFICATION.md` documents pin ownership, delivery, the exact three
  keys, bundle contents, refusal behavior, candidate mode and adoption, and is
  honest that it selects no real artifact. The operational consequence is now
  explicit rather than accidental: a main build cannot provision until a
  verifier pin is delivered. That is the writer's legitimate choice between the
  two options the finding offered, and it is documented and diagnosed.
- The verification-only `sqlite` format is exempt from the candidate
  publication-off rule, restoring the diagnostic's inherited behavior, and
  `sqlite-diagnostic-with-uploads` passes with publication enabled while
  candidate and main acceptance still require it off.
- The authorized `system-interpreter-helper` category now has both halves
  covered: `system-interpreter-helper-accounting` asserts the recorded row for a
  `tools/bin` helper, and `outside-interpreter-runtime-refused` asserts refusal
  once the same ELF moves outside `tools/bin`.
- The declared application command is now app-scoped and forces the walk, so the
  mandatory evidence is reproducible from the declaration for the first time in
  four rounds. The reviewer ran it as declared: `fail=0 warn=3 xfail=8 cov=100
  outliers=0 excluded=0 exit=0`. This round's wrappers are home-local, and the
  private locator lives in the ignored context file.
- The two integration timing repairs are legitimate rather than gate-gaming, and
  the reviewer checked this specifically. The polluted-PDF case now builds the
  activation input at exactly 1000 XObjects, the real structural threshold, so it
  tests the boundary rather than a value comfortably above it, with the default
  still 1100 and the experimental fallback sample unchanged. The auth case moves
  adapter construction and schema generation into a module-scoped fixture, which
  is the canonical remedy for a slow call, while the measured call keeps real
  service startup, real HTTP and every assertion. No duration floor, threshold,
  timeout, xfail or exclusion was touched: the floor file still reads 1.0, there
  is no exclusions file, and neither it nor `pyproject.toml` is staged. Suite
  time fell from 4m 45s to 3m 39s.

#### Missing work for Step 4 for step 4 tools-archive-rebuild (exchange 1) (round 2)

- Make the staged set committable. The reviewer ran the repository's own
  sensitive-content checker against the staged blobs and it reported
  `Commit blocked` with five locations: four in
  `docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md` and one in
  `docs/v0.27.0/verify.tools-release-agent.sh`. Two distinct actions follow.
- Fix the staged source hit first, because it is entirely the writer's to fix:
  the `same-venv` assertion writes the private application name twice inside the
  expected venv path. Derive the expected value from the same source the
  provisioner derives it from, or assert the path shape without embedding that
  name, so the harness keeps its meaning without putting the name in versioned
  content. In fairness this line predates round 2 and the round 1 answer should
  have caught it.
- Then decide what to do about the transcript. Adding it to cplx group 2 is what
  turns four pre-existing transcript lines into a blocked commit. Dropping it
  from the staged set restores the arrangement rounds 1 through 3 used and makes
  this commit executable immediately. Sanitizing the entries instead is a human
  decision, not a writer repair, because neither role may hand-edit a protocol
  transcript; it needs raising with the human rather than resolving in a round.
  Whichever path is chosen, the effort will eventually have to commit that
  document, so the underlying question is worth settling deliberately.

Architecture, performance and feature integrity are unchanged from the round 1
assessment and remain sound: responsibilities stay divided across transport,
bundle validation, wheel selection, ABI observation, test hooks and evidence
validation; the shared ELF reader remains the only ABI interpreter; work is
linear in its inputs with each root walked once; and the retirements stay
complete, with the wiring fixture asserting that none of the removed interims
reappears. Nothing in those dimensions needs fixing.

Unit test coverage: no application class changed. The three staged application
test files are test-only timing repairs inside the measured scope, and the walk
still reports 100% with the same warning and expected-failure counts. The new CI
adapters remain outside that scope, and both coverage gaps the round 1 answer
named are now closed by fixtures. No unit-tested class below 100% needs
completing, and no top-level symbol outside the coverage gate is unreferenced.

Scope: no final archive, candidate qualification, publication, release-pin
adoption or umbrella completion is claimed, and Step 6 still owns the live
Jenkins and Debian acceptance after Step 5 builds the archive.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, for the same
deliberate reason as round 1: this round returns `changes-requested`, so the
writer will restate its own verdict after the rework, and editing staged rows
now would change the index mid-round for no lasting benefit.

The writer did update those rows as round 1 instructed, and they are otherwise
sound: the section set is complete, each check section carries its required
closing phrase, the coverage section names the measured scope and adds the
second phrase about symbols outside it, and the document-level line correctly
remains `No, it is not implemented.` with Steps 5 to 7 pending.

What the writer must correct there after this round is the Step 4 status
sentence, which records `Yes. Step 4 has been fully implemented.` while the
staged set cannot be committed.

Because no validation-plan path was edited, no pre-repair blob was recorded and
no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 4 tools-archive-rebuild (exchange 1) (round 2)

Every resolved mandatory command was run by the reviewer in this round and all
three pass. For the first time in this effort the declared set produced its own
evidence without the reviewer having to work around it.

Project floor: `lint_shell: 58 tracked scripts`, `lint_shell: clean`, exit 0.

Native cumulative runner at `--step 4` on RHEL 9.8 with the independent
`/usr/bin/python3` 3.9.25: `validation exit=0 elapsed=50s`. The reviewer copied
the whole remote log back rather than trusting the printed tail, and confirmed
inside it both the totals and each repair fixture by name:

- `Independent interpreter: /usr/bin/python3 3.9.25`.
- `PASS release-venv-needs-verifier` and `PASS release-preflight-needs-verifier`,
  the fixtures that exercise the actual provisioner in release mode with no pin.
- `PASS verifier-release-preflight` for the positive path.
- `PASS sqlite-diagnostic-with-uploads` for the publication-enabled exemption.
- `PASS system-interpreter-helper-accounting` and
  `PASS outside-interpreter-runtime-refused` for both halves of the authorized
  helper exception.
- `Agent shell fixtures: 33 cases passed; parser and wiring fixtures passed`.
- `D10 fixtures: 49 cases passed`.
- `Ran 16 tests` / `OK`, `Ran 15 tests` / `OK`, `Ran 6 tests` / `OK`.
- `SQLite closure: 25 checks passed` and the frozen verdict with `failures 0`.

Application walk, run as declared through the new app-scoped wrapper that forces
the walk: `fail=0 warn=3 xfail=8 cov=100 outliers=0 excluded=0 exit=0`,
objective reached, 3m 39.3s. The reviewer ran it alone on the machine, and the
duration drop from 4m 45s shows the timing repairs did real work rather than
moving a threshold.

Beyond the mandatory set, the reviewer ran one more check that the mandatory set
does not cover and that decides this round: the repository's own
sensitive-content checker against the staged blobs. It reported
`ERROR: sensitive content found in the pending commit`, five locations, and
`Commit blocked`. That checker is the same program the installed pre-commit hook
executes, so this is the commit gate's real answer rather than an inference.

Verification that no gate was relaxed by the timing repairs, since that claim
deserved independent checking: the duration floor file still reads `1.0`, no
exclusions file exists, and neither that file nor `pyproject.toml` appears in
the staged set.

Independent identity binding of the evidence to the reviewed bytes: the recorded
Step 4 capture now lists 20 files across both repositories. The reviewer
recomputed the eleven that changed in this round, including the three
application test files, the new verification document, the provisioner and the
transport helper, and every hash and line count matches. The companion staged
tree recomputed to `a130e310e2abc8690abf7766c8a6efd998346e32` and its HEAD to
the recorded starting revision, both exactly as recorded.

One process note about this round's own rigor. The reviewer captured the index
baseline and umbrella digest at entry, but took the validation-state baseline
after the read-only assessment rather than before it. Nothing could have drifted
in between: no repair was made, and the index identity was verified identical at
entry, after every validation run and at publication, which the manifest and the
comparisons record. The earlier rounds of this effort took that capture in the
prescribed order.

### Resolved validation set and sources for step 4 tools-archive-rebuild (exchange 1) (round 2)

The reviewer ran the union of the request validation set and the current
resolver set. All three commands were executed in this round and all three pass.

- `bash src/utils/lint_shell.sh`, source `project`. Re-resolved from the
  versioned declaration and run through the project environment so the pinned
  ShellCheck resolved. Result: 58 tracked scripts, clean, exit 0.
- `bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 4 --python
  /usr/bin/python3 --app-repo ../app`, source `plan`. Run on the native RHEL
  host through `.reviews/a.step4.native-gate.ps1`, which the reviewer inspected
  first as the request asks. That driver and its transport script are now
  home-local, and it creates an owned snapshot with exactly the declared layout.
  Result: `validation exit=0 elapsed=50s`.
- `powershell -ExecutionPolicy Bypass -File .reviews/a.step4.app-walk.ps1`,
  source `plan`. This replaces the bare `ghog day` of round 1, and it is the
  fix to a weakness this reviewer had raised in three consecutive rounds: it
  resolves the application checkout from the ignored context file, sets the
  project directory explicitly and forces the walk, so the declared command now
  measures the tree instead of returning exit 0 on a cached marker. Result:
  objective reached, `cov=100`, no failures and no outliers.

Caller evidence retained inside the artifact home, not in versioned notes:
`a.code-review.s4r2-native-validation.log` (the full remote validation log),
`a.code-review.s4r2-app-walk.log` (the declared walk),
`a.code-review.s4r2-cplx-plan.json` and `a.code-review.s4r2-app-plan.json` (the
two independent commit-plan results).

### Resolver drift and direction for step 4 tools-archive-rebuild (exchange 1) (round 2)

No drift in either direction, and the round 1 ambiguity is resolved.

Re-resolving the project floor from the versioned `.review-validation` yields
the same single `project` command the request carries, and both `plan`
additions parse through the current resolver contract, so the union equals both
sets.

The second plan addition changed identity since round 1, from a bare `ghog day`
with no repository context to an explicit app-scoped wrapper in the artifact
home. That is a deliberate improvement rather than drift: the earlier spelling
would have resolved against this repository, where the versioned declaration
deliberately avoids that command because there is no pytest project here. The
declaration file itself was correctly left alone in both rounds.

### Repository state around validation for step 4 tools-archive-rebuild (exchange 1) (round 2)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher rather than from equivalent Git commands.

- Request-time index tree `f21d7c09846f2aad1c9cb2ac79b485a580adba5b` equals the
  baseline captured at entry and the live index captured after all three
  validation runs, the staged-blob sensitive check and the implementation check.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `0218245242f1ccec3561ef41f23322e0c6c2f3a12e69981a8fc1c9698e769fc6`,
  the same digest observed in every round of this effort.
- Validation-state comparison over the ordered path set, holding all six staged
  step paths and the file named by the project command: `acceptable: true` with
  empty `tracked_paths`, `untracked_paths` and `ignored_paths`.
- Both working trees match their entry state: six staged paths here, with the
  versioned transcript showing as staged and further modified because the
  protocol appended this round's request after the writer staged it, and
  nineteen staged paths in the companion checkout with nothing else. The
  companion index still recomputes to its recorded identity.
- This round produced no reviewer residue. The native run executes inside an
  owned host snapshot, the application walk writes only ignored logs in its own
  repository, and the staged-blob check is read-only.
- One honest note on ordering: the validation-state baseline for this round was
  captured after the read-only assessment rather than before it. No repair was
  made and the index identity was verified identical at entry and at
  publication, so no drift was possible in the interval, but the prescribed
  order is before, and earlier rounds followed it.
- Reviewer-authored evidence stayed inside the artifact home as ignored `a.*`
  files, so none of it became a tracked side effect of this review.

### Repair inventory for step 4 tools-archive-rebuild (exchange 1) (round 2)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 4 tools-archive-rebuild (exchange 1) (round 2)

`a.commit` is mechanically accurate in both repositories and the reviewer
amended nothing, but its cplx group 2 cannot execute as staged.

Independent `commit-plan-check.bat --format json` reruns against the received
state: cplx `state: valid`, `ready: true`, exit 0, no diagnostics, six staged
paths in two groups; the companion checkout likewise `valid`, `ready`, exit 0,
nineteen staged paths in two groups.

- cplx group 1, `test(tools): qualify candidate agent integration`: the Python
  fixture module, the agent harness and the cumulative runner.
- cplx group 2, `docs(tools-archive-rebuild): record step 4 validation`: the
  Step 4 capture, the validation plan and, new in this round, the versioned
  review transcript.
- Companion group 1, `test(perf): shorten two integration test calls`: the three
  integration test files. Placing the timing repairs before the CI group is the
  right order, since the authoring walk must pass for the CI group's evidence.
- Companion group 2, `ci(tools): qualify pinned candidate archives`: the sixteen
  CI and tool paths, now including the new verification document.

Ordering is least to most dependent in both plans, membership covers every
staged path exactly once, and each subject is a conventional single-purpose
line whose type matches its content.

The mechanical checker and the commit gate are not the same gate, and that is
the gap this round leaves. Adding the transcript to cplx group 2 is what makes
the difference: with it staged, the repository's own pre-commit hook refuses the
commit. `commit-plan-check` does not consult that hook, so `ready: true` and an
executable commit are two different statements here. Either drop the transcript
from the staged set, as rounds 1 through 3 of this effort did, or resolve the
content it carries first.

### Findings and boundaries for step 4 tools-archive-rebuild (exchange 1) (round 2)

Unresolved findings:

- The staged set cannot be committed: the repository's installed sensitive-content pre-commit hook refuses it, and the reviewer confirmed this by running that exact checker against the staged blobs, which reported five locations and `Commit blocked`. Four are in the newly staged versioned transcript and one is in staged source at `docs/v0.27.0/verify.tools-release-agent.sh`, whose venv assertion embeds the private application name twice.

Boundary-crossing work: None.

### Writer instructions for step 4 tools-archive-rebuild (exchange 1) (round 2)

The round 1 findings are closed. Two actions remain, both about making this
commit executable, and one of them needs the human rather than the writer.

1. Fix the staged source hit, which is the writer's alone.

   `docs/v0.27.0/verify.tools-release-agent.sh` asserts the expected venv path with
   a literal that contains the private application name twice. The repository's
   sensitive rules match it, so the hook refuses the commit. Keep the assertion's
   meaning and drop the literal: derive the expected value from the same input the
   provisioner derives it from, or assert the path's shape around a name the
   fixture reads from ignored context. The reviewer did not repair this itself
   because the harness is staged content and any edit would be a substantive
   change that cannot finish a round anyway.

   This line predates round 2. The round 1 answer should have reported it, and did
   not, because that round's sanitization check covered the authored request text
   and not the staged harness. That is a gap in the earlier review, not a new
   defect introduced here.

2. Decide what to do about the versioned transcript, which needs the human.

   Adding `docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md` to cplx
   group 2 is what turns four pre-existing transcript lines into a blocked commit.
   Those lines came from authored request text in an earlier step and in round 1 of
   this step, and neither role may hand-edit a protocol transcript, so no writer
   action removes them.

- The immediate, reversible option is to drop the transcript from the staged set
  and keep the arrangement rounds 1 through 3 used. This commit then executes,
  and the question moves to whoever decides about the document.
- The durable option is a human decision about sanitizing those entries, since
  the effort must eventually commit that document and the hook will keep
  refusing it until its content matches the rules.

Raise it as a decision rather than resolving it silently either way.

Then correct the Step 4 status sentence in the validation plan, which currently
records `Yes. Step 4 has been fully implemented.`

Worth recording as done well, because three rounds of this review kept asking
for it: the declared application command now forces an app-scoped walk, so its
evidence is reproducible from the declaration; this round's wrappers and their
transport script are home-local; and the private locator lives in the ignored
context file. The two timing repairs also hold up under scrutiny, including the
choice to test the polluted-PDF gate at its exact threshold rather than above it.

One standing item, unchanged and still not driving a round: the project root
holds a large accumulation of earlier review scratch from this step's previous
attempts. This round's own files are placed correctly, so this is cleanup of
older material rather than a new lapse.

Optional, for a later round rather than this one: the `ghog day` ambiguity is
gone from the declaration, and the only remaining uncovered behavior the
reviewer knows of in this step is exercised by live runs that Step 6 owns.

### Decision rationale for step 4 tools-archive-rebuild (exchange 1) (round 2)

The disposition is changes-requested, on one finding, and the readiness floor is
recorded as incomplete. The reviewer made no repair, so nothing is attributed to
it. This is not a repetition of round 1: every round 1 finding is closed, and
the reason for another round is different.

Where the six readiness-floor results stand:

1. Identity. Passes exactly in both repositories. The cplx request index tree
   matches the live index at entry and at publication, and the companion tree
   and HEAD match their recorded identities.
2. Completeness. Fails, narrowly and for a reason outside the implementation
   itself: the staged set cannot be committed.
3. Validation and coverage. Passes, and this round it passes on the declaration's
   own terms. All three resolved commands were run: the lint floor is clean, the
   native run passed with 33 agent cases, 49 D10 cases, 16 record, 15 transport
   and 6 publication tests, 25 SQLite checks and 254 frozen controls, and the
   declared application walk forced a real measurement reaching `cov=100` with
   no failures and no outliers.
4. Staged attribution. Passes. Both trees hold only their staged sets and this
   round left no reviewer residue.
5. Unresolved findings. One, with the actions it needs.
6. `a.commit`. Mechanically accurate in both repositories, and not executable in
   cplx as staged.

Why that one finding blocks. A commit-ready recommendation tells the human the
staged work is ready for the commit they own. Here that commit cannot run: the
reviewer executed the same program the installed pre-commit hook executes,
against the staged blobs, and it answered `Commit blocked` with five locations.
Recommending commit-ready while knowing the commit fails at the gate would be
recommending an action that cannot succeed. The mechanical checker returns
`ready: true` because it does not consult that hook, so the two statements have
come apart, and naming that difference is the useful thing this round can do.

The finding splits into a writer action and a human decision, and the answer
keeps them separate rather than pretending one covers both. The staged harness
line is the writer's to fix and is straightforward. The four transcript lines
came from authored request text in an earlier step and in round 1 of this one;
neither role may hand-edit a protocol transcript, so the writer's realistic move
is to unstage that document, while sanitizing it is a human decision the effort
will have to face because that document must eventually be committed.

An honest correction about this review rather than the work: the staged harness
line existed in round 1 and the round 1 answer did not report it. That round's
sanitization check looked at the authored request text and not at the staged
harness, and steps 1 to 3 had been checked more thoroughly than step 4 was. The
finding is recorded now, attributed to the earlier gap rather than presented as
something new in this round.

What the round 2 repairs earned, since a review that only reports faults teaches
nothing. The release contract now refuses early and names the file and the
document it needs, wired at four separate entries, with the exact fixture this
reviewer asked for running the real provisioner. The SQLite exemption restores
the diagnostic's inherited behavior and is asserted with publication enabled.
The authorized helper exception now has both its accounting case and its refusal
case. The declared application command forces an app-scoped walk, closing a
weakness raised in three consecutive rounds. And the two timing repairs are real
work, not a relaxed gate: the floor file, exclusions and project configuration
are untouched and unstaged, the polluted-PDF case now tests its exact structural
threshold, and the suite time fell from 4m 45s to 3m 39s.

What this answer does not claim: no final archive, no candidate qualification,
no Jenkins or Debian acceptance, no publication, no adoption and no umbrella
completion. Those remain Step 6's work after Step 5 builds the archive, and this
answer authorizes no commit in either repository.

### Final reviewer decision for step 4 tools-archive-rebuild (exchange 1) (round 2)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-4-round-2 -->

## Round 2 by human - Step 4 - escalation

- Recorded: 2026-09-17T19:33:33+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: escalation

### Transcript redaction decision for step 4 tools-archive-rebuild (exchange 1) (round 2)

Round 2 independently passed all three mandatory validation commands and
accepted the earlier implementation repairs. It requested changes because the
installed sensitive-content checker refused one fixture assertion and four
older entries in the protocol-owned versioned transcript.

The writer repaired and staged the fixture assertion without a private name.
The fresh cumulative native Step 4 run passed in 53 seconds, including the
same-venv check; all 20 native inputs match the retained snapshot. The companion
application index is unchanged. The current staged sensitive-content check
reports only the four earlier transcript entries, at lines 1811, 1874, 1890 and
1961. The validation plan records Step 4 as incomplete while this gate remains.

An ignored proposal applies only configured repository replacements to those
four lines and passes the sensitive-pattern scan. No direct transcript edit,
unstaging, rule relaxation, commit or publication has been performed. The
requestor is stopping automation for the human decision the reviewer requested:
authorize applying the prepared redactions as an exception to protocol-owned
transcript editing, then resume the existing review workflow. The retained
round 2 answer and all implementation evidence remain authoritative.

<!-- review-entry-id: escalation-round-2 -->

## Round 2 by human - Step 4 - human-reclaim

- Recorded: 2026-09-17T19:50:36+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: human-reclaim

### Approved transcript correction for step 4 tools-archive-rebuild (exchange 1) (round 2)

The requestor paused this intact exchange solely for a human decision about
four sensitive entries in the protocol-owned transcript. The human answered
"Go ahead" to applying the prepared redactions and resuming review. This
authorizes the explicit transcript-edit exception and continuation of the
stopped handoff, not a commit or any change to the sensitive-content rules.

The requestor applied exactly the approved proposal to lines 1811, 1874, 1890
and 1961, using the configured repository replacements. Source and proposal
SHA-256 guards bound the action to the reviewed bytes. The original is retained
under the ignored artifact home. No other transcript text was changed by the
writer. The round 2 answer remains authoritative, including its requested
fixture repair, and the fresh native run passed in 53 seconds.

Resume the same exchange and round after this human decision. The requestor
will verify the complete staged sensitive-content gate, consume the retained
changes-requested answer with changed-work evidence, and publish round 3 for
the independently running reviewer. No counterpart session is created or
contacted, and no commit is authorized by this decision.

<!-- review-entry-id: human-reclaim-round-2 -->

## Round 3 by requestor - Step 4

- Recorded: 2026-09-17T19:57:59+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: request

### Review identity for step 4 tools-archive-rebuild (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 4
Review round: 3

### Code review evidence for step 4 tools-archive-rebuild (round 3)

request_index_tree: 293180b1662f45d0b486aeb38bfd2bc241ebe047
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 4 --python /usr/bin/python3 --app-repo ../app (sources: plan)
- powershell -ExecutionPolicy Bypass -File .reviews/a.step4.app-walk.ps1 (sources: plan)
- powershell -ExecutionPolicy Bypass -File .reviews/a.step4.sensitive-gate.ps1 (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: test(tools): qualify candidate agent integration
group 1 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 1 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2: docs(tools-archive-rebuild): record step 4 validation
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 2 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 4 tools-archive-rebuild (round 3)

Yes. Step 4 has been fully implemented within the plan's fixture and pipeline
wiring boundary. Final archive production belongs to Step 5; actual Jenkins,
Debian and final native candidate acceptance belong to Step 6.

Round 2 independently passed the shell lint floor, cumulative native runner and
forced application walk, and accepted every earlier implementation repair. Its
only remaining finding was the staged sensitive-content gate. The writer has
now repaired the fixture assertion and applied the human-approved four-line
transcript correction. The complete staged set passes the installed checker.
No reviewer-authored repair is present and no sensitive rule was relaxed.

The fresh cumulative native rerun after the fixture repair passed in 53 seconds:
33 agent shell cases plus ABI, wheel, test-evidence and plugin fixtures; 49 D10
cases; 16 record, 15 transport and six publication tests; 25 current SQLite
controls and 254 historical closure cases. Shell lint and adapter compilation
passed. All 20 native source inputs match that tested snapshot. The revised
same-venv assertion passed and retains its exact prefix, interpreter version
and matching application-directory/name checks.

The application index was recaptured as
a130e310e2abc8690abf7766c8a6efd998346e32, identical to round 2. Its independently
forced round 2 walk passed with fail=0, warn=3, xfail=8, cov=100 and outliers=0
in 3m 39.3s. The writer's prior forced walk passed in 4m 54.8s, with the same
counts. No application file changed for this round, so that evidence remains
applicable; the reviewer must still execute its declared mandatory set.

The CI adapters are outside the app coverage source, src/pdfss. Every top-level
adapter symbol has a fixture, package or CLI reference. No unit-tested class
changed, no new domain dependency was added, and new Python files remain below
650 physical lines. Inventory and manifest processing stay linear. Integration
timing repairs retain every assertion and all coverage/duration gates.

Validation execution notes:

- Cplx is a Bash project. Its .review-validation shell lint floor and native
  cumulative runner apply; it has no pytest project.
- The declared native command is bash docs/v0.27.0/verify.tools-archive-rebuild.sh
  --step 4 --python /usr/bin/python3 --app-repo ../app. On this Windows checkout,
  .reviews/a.step4.native-gate.ps1 creates an owned native snapshot with exactly
  that layout, overlays current sources and runs the command, including lint.
  Inspect its transport driver first and retain the full remote log.
- .reviews/a.step4.app-walk.ps1 resolves the private app checkout, sets PRJ_DIR
  explicitly and invokes the absolute shared launcher with ghog day --force.
  Let its forced walk finish without a concurrent second execution.
- The new request addition, .reviews/a.step4.sensitive-gate.ps1, runs the exact
  installed pre-commit sensitive checker against this Windows checkout's index.
  Run it locally, where the hook and its configured rules live. Inspect first.
- .reviews/a.step4.app-context.json holds the private locator. Use app: labels
  in authored/versioned text. Companion application paths and index identity
  are separate evidence; request_index_tree identifies cplx only.

Retained details and source hashes are in
docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt. No commit,
publication, final candidate qualification or umbrella completion is authorized
or claimed by the human's transcript correction approval.

### Implementation report for step 4 tools-archive-rebuild (round 3)

Step 4 wires the main application's candidate and ordinary release provisioning
to independent verifier controls, one selected prefix, exact wheel capture,
blocking ABI observations and a full test/coverage acceptance entry. It removes
the rsync, tools-patch and wheel-mutation interims while retaining the permitted
raw-Python bypass pending wrapper acceptance. The SQLite diagnostic reuses
verified transport and remains independently selectable.

The repaired release contract fails at preflight if tools/tools.verification
is missing. ci/TOOLS-VERIFICATION.md explains how the job owner delivers that
independent pin. Candidate publication remains suppressed; the SQLite-only
format accepts the pre-existing publication-enabled diagnostic use case.

Cplx's cumulative native fixtures cover those entry points and negative
observations, including the authorized helper interpreter exception. Two
application integration test timing repairs were needed to clear the mandatory
authoring walk. They change setup/input size and preserve all assertions and
real integration paths. No application production behavior changed for timing.

Step 6 still owns live Jenkins/Debian and final RHEL candidate acceptance after
the Step 5 rebuild. No final candidate, publication, release-pin adoption or
umbrella completion is claimed by this implementation.

### Change summary for step 4 tools-archive-rebuild (round 3)

This step spans cplx and the separate application checkout declared by the
plan. The protocol's request_index_tree fixes the cplx index only. Resolve
the companion app root from .reviews/a.step4.app-context.json; keep its private
locator out of authored review text and the versioned transcript.

Cplx starting HEAD: 863933eeedb21bac5bfa7a662d1a0d25a048a079.

Cplx staged paths:

- docs/v0.27.0/fixtures.tools-release-agent.py
- docs/v0.27.0/verify.tools-archive-rebuild.sh
- docs/v0.27.0/verify.tools-release-agent.sh
- docs/v0.27.0/evidence.tools-archive-rebuild.step4-validation.txt
- docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
- docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md

Cplx root a.commit keeps two groups:

1. test(tools): qualify candidate agent integration (the three fixtures/runners).
2. docs(tools-archive-rebuild): record step 4 validation (evidence, validation
   and the versioned review record).

App starting HEAD: 489bbbde741328ab7953e2338a29952cd1a9f18c.
App index captured with capture-index-tree: a130e310e2abc8690abf7766c8a6efd998346e32.
Retained binary patch: .reviews/a.step4.app-staged.patch.
Patch SHA-256: a2f05e321c0286fb2b0d55146fd0d69152f877a6f2caf86f3cb86e14e6c1b6de.
Retained companion commit plan: .reviews/a.step4.app-commit-plan.md.

App staged paths:

- Jenkinsfile
- ci/Jenkinsfile.diagnostics
- ci/Jenkinsfile.relocation
- ci/TOOLS-VERIFICATION.md
- ci/__init__.py
- ci/provision_toolchain.sh
- ci/tools_abi_acceptance.sh
- ci/tools_abi_scan.py
- ci/tools_agent_identity.sh
- ci/tools_candidate.sh
- ci/tools_candidate_bundle.py
- ci/tools_test_acceptance.sh
- ci/tools_test_evidence.py
- ci/tools_test_plugin.py
- ci/tools_wheel_capture.py
- src/pdfss/tests/integration/adapters/inbound/sentinel_service/test_sentinel_auth_lifecycle/test_sentinel_auth_lifecycle_tdd.py
- src/pdfss/tests/integration/application/handlers/test_pdf_processing_handler_polluted_pdf/_synthetic_polluted_samples.py
- src/pdfss/tests/integration/application/handlers/test_pdf_processing_handler_polluted_pdf/test_pdf_processing_handler_polluted_pdf_acceptance_tdd.py
- tools/sqlite_candidate_capture.sh

App root a.commit keeps two groups:

1. test(perf): shorten two integration test calls (the three integration files).
2. ci(tools): qualify pinned candidate archives (the 16 CI/tool paths).

The existing tools/publish.mode was already off and is unchanged. Assess
companion repairs in the app index and name them with app: labels. Commit plans
are prepared for review; no commit has been authorized or executed.

### Human guidance and writer response for step 4 tools-archive-rebuild (round 3)

Human guidance:

#### Approved transcript correction for step 4 tools-archive-rebuild (round 3)

The requestor paused this intact exchange solely for a human decision about
four sensitive entries in the protocol-owned transcript. The human answered
"Go ahead" to applying the prepared redactions and resuming review. This
authorizes the explicit transcript-edit exception and continuation of the
stopped handoff, not a commit or any change to the sensitive-content rules.

The requestor applied exactly the approved proposal to lines 1811, 1874, 1890
and 1961, using the configured repository replacements. Source and proposal
SHA-256 guards bound the action to the reviewed bytes. The original is retained
under the ignored artifact home. No other transcript text was changed by the
writer. The round 2 answer remains authoritative, including its requested
fixture repair, and the fresh native run passed in 53 seconds.

Resume the same exchange and round after this human decision. The requestor
will verify the complete staged sensitive-content gate, consume the retained
changes-requested answer with changed-work evidence, and publish round 3 for
the independently running reviewer. No counterpart session is created or
contacted, and no commit is authorized by this decision.

Writer response:

All round 2 findings are accepted; there is no disagreement. The reviewer made
no repair. The writer made the following corrections:

- Removed the private name from the same-venv fixture assertion. The check
  still requires the exact prefix, interpreter version and matching application
  directory/name. The fresh cumulative native run passed in 53 seconds,
  including this assertion, all 33 agent cases and the inherited gates.
- Prepared a proposal applying the configured sensitive replacements to exactly
  four older transcript lines: 1811, 1874, 1890 and 1961. The human explicitly
  approved that correction and resuming the stopped handoff. Source and proposal
  SHA-256 guards verified the approved bytes; the original stays in ignored
  evidence. The protocol recorded the approval when resuming round 2.
- Retained the corrected transcript in the staged documentation group. The
  exact installed pre-commit sensitive checker now passes the complete staged
  set. No rule, hook, gate, exclusion or commit boundary was weakened.
- Updated the validation plan and retained evidence to reflect the repaired
  commit blocker. Both commit plans retain their existing two-group structure.
  The companion app index is unchanged from round 2.

The user approved redaction and review continuation only. No commit is
authorized. The independently running reviewer remains the counterpart; the
requestor did not create, invoke or contact a reviewer session.

### Reviewer focus for step 4 tools-archive-rebuild (round 3)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-4-round-3 -->

## Round 3 by reviewer - Step 4

- Recorded: 2026-09-17T20:24:52+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: answer

### Assessed index identity for step 4 tools-archive-rebuild (exchange 1) (round 3)

Baseline index tree: 293180b1662f45d0b486aeb38bfd2bc241ebe047

Assessed index tree: 293180b1662f45d0b486aeb38bfd2bc241ebe047

### Implementation check for step 4 tools-archive-rebuild (exchange 1) (round 3)

Result:

Yes. Step 4 has been fully implemented.

Both round 2 items are closed, and the reviewer verified each by running the
repaired artifacts rather than by reading the writer's account.

- The staged sensitive-content gate is clean. The reviewer ran the actual
  installed hook script against this checkout's index, which is the gate a
  commit will meet, and it reported `Staged sensitive-content gate: clean` with
  exit 0. Cross-checked with the same checker module invoked directly, the one
  that returned five locations and `Commit blocked` in round 2: also exit 0 now.
- The staged harness hit is repaired, and the replacement is stronger than the
  literal it removed. Instead of matching a hardcoded path containing the
  private application name twice, the fixture now checks the exact prefix, the
  path shape, the pinned `3.13.15` interpreter version, and that the project
  directory name equals the venv name suffix, which is the invariant the literal
  encoded. `PASS same-venv` appears in the reviewer's own native log, alongside
  the neighbouring `one-interpreter` and `ambiguous-interpreter` cases.
- The four transcript entries were corrected with the repository's own declared
  replacements rather than an improvised edit: the private application name, the
  account name and the home path now appear as the generic values those rules
  define, and one entry uses the `app:` label convention this effort uses
  elsewhere. The surrounding review sentences are intact, so no review history
  was rewritten in substance. The reviewer also searched the whole working-tree
  transcript, including this round's freshly appended request text, and it is
  clean, so the authoring practice is fixed and not only the past lines.
- The writer added the staged sensitive check to the declared validation set as a
  fourth mandatory command, pointing at the installed hook. That turns a check
  this reviewer had to think of into one the declaration now requires.

One limit worth stating rather than glossing: the request says the transcript
correction was human-approved. A reviewer cannot verify that approval, and this
answer does not assert it. What the reviewer can and did verify is the effect,
that the substitutions follow the repository's declared rules and preserve the
content. The approval itself is visible to the human at the convergence gate.

Everything assessed in rounds 1 and 2 remains verified and unchanged: the
retirements are complete and fixture-asserted, the release contract refuses
early at four entries naming the file and document it needs, the SQLite
verification-only format is exempt from candidate publication suppression, the
authorized helper exception has both its accounting and refusal cases, and the
blocking ABI and full-test gates enforce what the plan specifies.

Architecture: responsibilities stay divided across transport, bundle validation,
wheel selection, ABI observation, test hooks and evidence validation; the shared
ELF reader remains the only ABI interpreter; no application domain code is
touched. Nothing needs fixing.

Performance: work is linear in its inputs with each root walked once, and the
instrumented measurements are unchanged from earlier rounds. The two integration
timing repairs remain legitimate: the reviewer re-confirmed that the duration
floor file still reads 1.0, no exclusions file exists, and neither it nor the
project configuration is staged. No performance issue needs addressing.

Unit test coverage: no application class changed in this round. The new CI
adapters remain outside the application's measured `src/pdfss` scope, which the
documents state rather than assume, and both coverage gaps named in round 1 are
closed by fixtures. No unit-tested class below 100% needs completing, and no
top-level symbol outside the coverage gate is unreferenced.

Feature integrity: candidate transport, bundle refusals, ABI refusals, the test
gate, the SQLite diagnostic and the release preflight are all exercised and
pass, and ordinary application publication keeps its existing path. Nothing is
impaired.

Scope: no final archive, candidate qualification, publication, release-pin
adoption or umbrella completion is claimed. Step 5 builds the archive and Step 6
owns the live Jenkins, Debian and native acceptance.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 4 rows were checked against the template and against this
reviewer's own verdict, and they now agree with it, so there was nothing to
correct:

- The status sentence is exactly `Yes. Step 4 has been fully implemented.`,
  followed by a blank line and a short prose summary, and this round's
  assessment reaches the same conclusion.
- No stale `Missing work for Step 4` section remains, which is correct now that
  the round 2 finding is closed.
- Goal, improvement expectations, what was implemented, new types and classes,
  architecture, performance, unit test coverage and feature integrity are all
  present and filled, each check section carries its required closing phrase,
  and the coverage section names the measured scope plus the second phrase about
  symbols outside it.
- The document-level line correctly remains `No, it is not implemented.`, since
  Steps 5 through 7 are pending. Flipping it here would be wrong.

Because no validation-plan path was edited, no pre-repair blob was recorded and
no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 4 tools-archive-rebuild (exchange 1) (round 3)

All four resolved mandatory commands were run by the reviewer in this round.
Three passed first time; the application walk needed two runs, and both are
recorded below rather than only the passing one.

Project floor: `lint_shell: 58 tracked scripts`, `lint_shell: clean`, exit 0.

Staged sensitive-content gate, new in this round's declaration: exit 0,
`Staged sensitive-content gate: clean`. The wrapper runs the installed hook
script itself, so this is the gate a commit meets rather than an approximation.
The reviewer also ran the checker module directly, the way it was invoked in
round 2 when it reported five locations and `Commit blocked`, and it now returns
exit 0 as well.

Native cumulative runner at `--step 4` on RHEL 9.8 with the independent
`/usr/bin/python3` 3.9.25: `validation exit=0 elapsed=52s`. The reviewer copied
the whole remote log back and confirmed inside it:

- `Independent interpreter: /usr/bin/python3 3.9.25`.
- `PASS one-interpreter`, `PASS same-venv` and `PASS ambiguous-interpreter`,
  which is the repaired assertion and its neighbours.
- `Agent shell fixtures: 33 cases passed; parser and wiring fixtures passed`.
- `D10 fixtures: 49 cases passed`.
- `Ran 16 tests` / `OK`, `Ran 15 tests` / `OK`, `Ran 6 tests` / `OK`.
- `SQLite closure: 25 checks passed` and the frozen verdict with `failures 0`.

Application walk, run as declared through the app-scoped wrapper that forces the
walk, with nothing else running:

- First run: `fail=0 warn=3 xfail=8 cov=100 outliers=2 excluded=0 exit=8`, full
  suite 6m 47.5s. The two outliers were
  `test_select_done_candidate_is_stable_under_candidate_permutations` at 1.08s
  and `test_literal_filter_wrapper_matches_python_re_search` at 1.04s, against a
  1.00s floor.
- Second run, same bytes, nothing else running: `fail=0 warn=3 xfail=8 cov=100
  outliers=0 excluded=0 exit=0`, objective reached, full suite 3m 25.9s.

The reviewer concluded the first result was measurement variance rather than a
defect, on evidence rather than convenience: the application index recomputed to
`a130e310e2abc8690abf7766c8a6efd998346e32`, byte-identical to the tree that
passed round 2 with zero outliers in 3m 39.3s; neither outlier test is staged by
this step, and both are property-based tests; both exceeded the floor by 4 and 8
percent while the next call sits at 0.99s; and the failing run took roughly
twice the wall-clock of the passing runs on a workstation that is also running
an interactive terminal, a chat client, a browser and other agents. The tool's
own diagnostic says a call this close to the floor flaps on the next jitter.

The passing run is therefore evidence about the same bytes, not a different
tree, and the tests involved are outside this step's staged set.

Independent identity binding of the evidence to the reviewed bytes: the Step 4
capture records the repaired harness as
`b479cfe14bf1815a32ecea5c908ac8a09cf605dd4c766d49badeb4114b1638ce` at 208 lines
and explicitly marks that row as superseding its round 2 row, which is accurate
bookkeeping rather than an ambiguous duplicate. The reviewer recomputed it and
the unchanged fixture module, and both match. The companion staged tree matches
its recorded identity and no application file changed in this round.

Coverage limits stated rather than assumed: the application gate measures
`src/pdfss`, so its 100% says nothing about the CI adapters, whose exercise is
the native fixtures and static references.

Process note, correcting this reviewer's own round 2 slip: the index baseline,
umbrella digest and validation-state baseline for this round were all captured
and the manifest written before any assessment, in the prescribed order.

### Resolved validation set and sources for step 4 tools-archive-rebuild (exchange 1) (round 3)

The reviewer ran the union of the request validation set and the current
resolver set. All four commands were executed in this round and all four pass.

- `bash src/utils/lint_shell.sh`, source `project`. Re-resolved from the
  versioned declaration and run through the project environment so the pinned
  ShellCheck resolved. Result: 58 tracked scripts, clean, exit 0.
- `bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 4 --python
  /usr/bin/python3 --app-repo ../app`, source `plan`. Run on the native RHEL
  host through the home-local driver, which the reviewer inspected first as the
  request asks. Result: `validation exit=0 elapsed=52s`.
- `powershell -ExecutionPolicy Bypass -File .reviews/a.step4.app-walk.ps1`,
  source `plan`. App-scoped and forcing the walk. Result: passed on the second
  run with `cov=100` and no outliers; both runs are recorded in the pre-repair
  section with the reasoning for treating the first as measurement variance.
- `powershell -ExecutionPolicy Bypass -File .reviews/a.step4.sensitive-gate.ps1`,
  source `request`. New in this round, and it is the check this reviewer had to
  supply itself in round 2, now part of the declaration. It runs the installed
  hook script against the index. Result: clean, exit 0.

The set has improved steadily across this step: round 1 declared a bare
`ghog day` with no repository context that measured nothing, and the set now
names an app-scoped forcing wrapper plus the commit gate that actually decides
whether staged work can be committed.

Caller evidence retained inside the artifact home, not in versioned notes:
`a.code-review.s4r3-native-validation.log` (the full remote log),
`a.code-review.s4r3-app-walk.log` and `a.code-review.s4r3-app-walk2.log` (both
application runs), and the two independent commit-plan results.

### Resolver drift and direction for step 4 tools-archive-rebuild (exchange 1) (round 3)

No drift in either direction.

Re-resolving the project floor from the versioned `.review-validation` yields
the same single `project` command the request carries, and the three additions
parse through the current resolver contract, so the union equals both sets.

One addition is new since round 2: the staged sensitive-content gate, labelled
`request`. Additions cannot subtract from the floor, and this one widens what
the review must prove rather than narrowing it, which is the direction the
resolver's no-removal rule protects. The declaration file itself was correctly
left alone in every round of this step.

### Repository state around validation for step 4 tools-archive-rebuild (exchange 1) (round 3)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher rather than from equivalent Git commands.

- Request-time index tree `293180b1662f45d0b486aeb38bfd2bc241ebe047` equals the
  baseline captured at entry and the live index captured after all four
  validation runs, both application walks and the implementation check.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `0218245242f1ccec3561ef41f23322e0c6c2f3a12e69981a8fc1c9698e769fc6`,
  the same digest observed in every round of this effort. No umbrella row was
  completed from reviewer mode, correctly, with Steps 5 to 7 open.
- Validation-state comparison over the ordered path set, holding all six staged
  step paths and the file named by the project command: `acceptable: true` with
  empty `tracked_paths`, `untracked_paths` and `ignored_paths`.
- Both working trees match their entry state: six staged paths here, with the
  versioned transcript staged and further modified because the protocol appended
  this round's request after the writer staged it, and nineteen staged paths in
  the companion checkout with nothing else. The companion index recomputes to
  its recorded identity and no application file changed in this round.
- This round produced no reviewer residue. The native run executes inside an
  owned host snapshot, the two application walks write only ignored logs in that
  repository, and both sensitive-content invocations are read-only.
- Ordering was correct this round: the index baseline, umbrella digest and
  validation-state baseline were captured and the manifest written before any
  assessment, which corrects the round 2 sequence where the validation baseline
  followed the read-only assessment.
- Reviewer-authored evidence stayed inside the artifact home as ignored `a.*`
  files, so none of it became a tracked side effect of this review.

### Repair inventory for step 4 tools-archive-rebuild (exchange 1) (round 3)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 4 tools-archive-rebuild (exchange 1) (round 3)

`a.commit` remains accurate in both repositories and is now executable; the
reviewer amended nothing.

Independent `commit-plan-check.bat --format json` reruns against the received
state: cplx `state: valid`, `ready: true`, exit 0, no diagnostics, six staged
paths in two groups; the companion checkout likewise `valid`, `ready`, exit 0,
nineteen staged paths in two groups.

- cplx group 1, `test(tools): qualify candidate agent integration`: the fixture
  module, the agent harness and the cumulative runner.
- cplx group 2, `docs(tools-archive-rebuild): record step 4 validation`: the
  Step 4 capture, the validation plan and the versioned review transcript.
- Companion group 1, `test(perf): shorten two integration test calls`, before
  the CI group, which is the right order since the authoring walk must pass for
  the CI group's evidence to exist.
- Companion group 2, `ci(tools): qualify pinned candidate archives`.

Ordering is least to most dependent in both plans, membership covers every
staged path exactly once, and each subject is a conventional single-purpose
line whose type matches its content.

The gap this reviewer reported in round 2 is closed. Keeping the transcript in
cplx group 2 is now safe, because the content it carries passes the installed
sensitive-content hook: the reviewer ran that hook against the index and it
reported clean. Mechanical readiness and an executable commit now agree, which
is the condition that was missing when `commit-plan-check` alone said ready.

### Findings and boundaries for step 4 tools-archive-rebuild (exchange 1) (round 3)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 4 tools-archive-rebuild (exchange 1) (round 3)

No rework is required for Step 4, and nothing in the staged content needs to
change before the human decides.

Both round 2 items are closed, and the way they were closed is worth recording:
the harness assertion was strengthened rather than merely sanitized, the
transcript correction used the repository's own declared replacements instead of
an improvised edit, and the staged sensitive gate was added to the declared
validation set so the next round proves it automatically.

Two items for the human rather than the writer:

- The transcript correction is described as human-approved. This reviewer cannot
  verify an approval and does not assert one; it verified the effect, that the
  substitutions match the declared rules and preserve the review content. If
  that approval is what the human intended, nothing further is needed.
- The application suite sits very close to its 1.00s duration floor. In this
  round's first walk two property-based calls measured 1.08s and 1.04s, with the
  next at 0.99s, and the same class of flap cost this reviewer a re-run in an
  earlier step as well. Neither test belongs to this step, so it is not Step 4's
  defect, but on a shared interactive workstation this gate will keep failing at
  random. The tool's own guidance applies: shorten those calls below the floor
  with margin, or accept them at their measured time through the documented
  exclusion, rather than raising the floor.

One standing item, unchanged and not driving a round: the project root still
holds a large accumulation of earlier review scratch from this step's previous
attempts. This round's own files are placed correctly in the artifact home, so
this is cleanup of older material.

When the exchange reaches the human gate, the registered choices are "Rework and
review again" and "Commit". The commit decision belongs to the human, not to
this reviewer and not to the requestor.

### Decision rationale for step 4 tools-archive-rebuild (exchange 1) (round 3)

The recommendation is commit-ready, and it is advisory only: it does not
authorize a commit in either repository.

All six readiness-floor results pass:

1. Identity. Exact agreement in both repositories, with the cplx request index
   tree matching the live index at entry and at publication, and the companion
   tree and HEAD matching their recorded identities.
2. Completeness. Step 4's fixture and wiring boundary is met, and the two items
   that held the previous rounds open are closed and verified by running the
   repaired artifacts.
3. Validation and coverage. All four resolved commands were run and pass,
   including the staged commit gate that this reviewer had to supply itself in
   round 2 and that the declaration now requires.
4. Staged attribution. No reviewer repair, so nothing is attributed to it. Both
   trees hold only their staged sets and this round left no residue.
5. Unresolved findings. None. The round 2 finding is closed and no new one
   arose.
6. `a.commit`. Mechanically valid in both repositories and, unlike round 2, now
   executable: the installed sensitive-content hook reports the staged set clean.

No substantive repair was made in this round, so the recommendation is not
disqualified by the same-round rule.

The one judgment call in this round was the application walk, and it is recorded
rather than smoothed over. Its first run exited 8 on two duration outliers of
1.08s and 1.04s against a 1.00s floor, in 6m 47s. The reviewer re-ran it once,
with nothing else running, and it reached its objective with zero outliers in
3m 25.9s. The failure was treated as measurement variance on evidence, not on
preference: the application index recomputed byte-identical to the tree that
passed round 2 with zero outliers in a comparable time, neither outlier test is
staged by this step, both are property-based, both exceeded the floor by single
-digit percentages while the next call sits at 0.99s, and the failing run took
about twice the wall-clock of both passing runs on a workstation that is also
running a terminal, a chat client, a browser and other agents. The tool itself
warns that a call this close to the floor flaps on the next jitter. Both runs
are reported, and the standing fragility is passed to the human as an
observation about the application suite rather than as a Step 4 defect.

What this reviewer verified rather than accepted, across the three rounds of
this step: the retirements are complete and fixture-asserted; the release
preflight refuses early at four entries and its fixture runs the real
provisioner; the SQLite exemption is asserted with publication enabled; the
authorized helper exception has both accounting and refusal cases; the test gate
enforces full selection, active plugins, guarded-suite execution and the 100%
threshold, with its option spelling confirmed against the real interpreter
rather than inferred from source; the timing repairs changed inputs and fixture
scope while every gate file stayed untouched and unstaged; and every recorded
hash and line count matches across both repositories, with the superseding row
for the repaired harness marked as such.

One limit this answer deliberately does not claim: the request describes the
transcript correction as human-approved, and a reviewer cannot verify an
approval. The effect was verified, that the substitutions follow the
repository's declared rules and leave the review content intact, and the
approval itself is the human's to confirm at the gate.

What this answer does not claim: no final archive exists, none was built,
qualified, published or adopted, and no umbrella row was completed. Step 5 owns
the rebuild and Step 6 the live Jenkins, Debian and native acceptance.

### Final reviewer decision for step 4 tools-archive-rebuild (exchange 1) (round 3)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-4-round-3 -->

## Round 3 by human - Step 4 - human-confirmation

- Recorded: 2026-09-17T20:50:07+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 4
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-3 -->

## Round 1 by requestor - Step 5

- Recorded: 2026-09-17T23:28:01+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 5
- Outcome: request

### Review identity for step 5 tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 5
Review round: 1

### Code review evidence for step 5 tools-archive-rebuild (round 1)

request_index_tree: 4e7c04e71c476c83a5be33af4f0b07eb69810b07
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 5 --python /usr/bin/python3 --app-repo /var/tmp/tools-release-step5.GBXjZi6r/app (sources: plan)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): remove staged compiler probe
group 1 path: src/setups/env/bin/pkg_tools.sh
group 1 path: docs/v0.27.0/verify.relocation-rpath.sh
group 2: test(tools): cover step 5 package boundaries
group 2 path: docs/v0.27.0/verify.tools-release-package.sh
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 3: docs(tools): retain step 5 candidate evidence
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.python-selection.md
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-inputs.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-validation.txt
group 3 path: docs/v0.27.0/inventory.tools-archive-rebuild.txt
group 4: docs(tools-archive-rebuild): record step 5 validation
group 4 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.python-selection.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-inputs.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-validation.txt
staged path: docs/v0.27.0/inventory.tools-archive-rebuild.txt
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/verify.relocation-rpath.sh
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-package.sh
staged path: src/setups/env/bin/pkg_tools.sh
```

### Requestor assessment for step 5 tools-archive-rebuild (round 1)

Yes. Step 5 has been fully implemented.

The exact candidate is tools.2026-09-17_222857.tar.gz, 545310257 bytes,
SHA-256 d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1.
Step 1 real-backend proof preceded the owned native RHEL refresh/build. Explicit
Python 3.13.15 selection, SQLite build and same-process file-backed probes,
private-stage cleanup, preservation checks and declaration authority are
recorded in the staged evidence. Only AR1/AR2/AR4/RA1 pass in the release record.
Steps 6 and 7, including actual Jenkins acceptance and publication, remain pending.

Native RHEL cumulative validation passed in 63 seconds at the four source hashes
in evidence.tools-archive-rebuild.step5-authority.txt. Its full-log SHA-256 is
0776c10a3fd39a2d7ef31f8c705cb5631d601428c0abc4eb664f5186edd84448. The separate
actual-candidate inherited archive run passed all 539 cases with no selected
residual programs. Historical library rows are parser input, not complete
qualification of the refreshed library inventory.

Fresh resumed verification matched current source hashes, the retained full
log, record/capture bindings, rendered Markdown and pending cells. Read-only
native checks rehashed both retained archives and verified their recorded
SQLite and archive assertions. The raw-capture bundle is 181694148 bytes,
SHA-256 7a06c17d136b0b6055cba861d4e4f220264ebf12a497a0a8e27e851aafb5d1bf.
Both authority commits remain ancestors of the build base. git diff --check
passed. A fresh ghog day passed shell lint and exited 5 at the unconfigured
pytest environment. The plan explicitly adapts validation to native Bash and
stdlib suites; it prohibits adding an unconfigured pytest gate.

No production Python type or class was added. The finite package and ownership
classes have explicit fixtures; no additional PBT dependency is needed. The
new operations have fixed cost within existing linear packaging passes.
No architecture, performance, coverage-gate or feature-integrity issue was
found. No cplx coverage percentage is claimed. The validation plan records this
scope and keeps the overall effort incomplete.

Reproduction context: the plan command below runs on native RHEL, with an
independent system Python and the application revision
ea8363c401c97b4cfae8dfb9d6e9f0b7318d42b0. The existing ignored transport helper
.reviews/a.step5.transport.sh full creates an isolated native fixture from
current sources and that application checkout; read its platform/setup contract
before invoking it from the Windows authoring environment. It does not rebuild
the candidate. The retained native fixture at /var/tmp/tools-release-step5.GBXjZi6r
also holds cplx, app, shellcheck-v0.10.0 and compiler entries used by the recorded
command. Its compiler environment is confined to compiler processes.

The ignored .reviews/a.step5.verify-record.py is a standalone stdlib record check.
The ignored .reviews/a.step5.resume-retained.sh performs read-only retained
artifact verification. Their captures and the full log remain in .reviews.
Do not rerun the costly payload build solely to reproduce fixture validation.

### Implementation report for step 5 tools-archive-rebuild (round 1)

The packager now rejects symlinked tools/python and tools/python/root boundaries
before copying and again in the private stage. It unlinks precisely the staged
tools/python/root/a.out before the closure gate and archive operation. A directory
at that path fails; terminal symlinks and hardlinks are unlinked without modifying
protected targets. No live-tree deletion is performed.

Only the resolved literal ownership entry was removed from the inherited
relocation harness. The focused test script exercises seven pathname cases and
five ownership cases through the original bookkeeping functions. The cumulative
runner accepts step 5 and runs these plus existing installer, wrapper and SQLite
acceptance controls.

The existing native build/acceptance workflow refreshed curated inputs, selected
Python 3.13.15 explicitly, rebuilt SQLite support and packaged the exact candidate.
Evidence preserves refused attempts and their repairs, actual measured runtime
bytes, unchanged payload/live/project sentinels, archive identity and source
authority. Git was reused, with two shared paths aligned from the refreshed
Python tree. No host packages were installed. The generated acceptance Markdown
matches the validated JSON sidecar. Step 5 validation is recorded separately.

### Change summary for step 5 tools-archive-rebuild (round 1)

Root a.commit contains four mechanically validated groups for 13 staged paths.

1. fix(tools): remove staged compiler probe
   - src/setups/env/bin/pkg_tools.sh
   - docs/v0.27.0/verify.relocation-rpath.sh
2. test(tools): cover step 5 package boundaries
   - docs/v0.27.0/verify.tools-release-package.sh
   - docs/v0.27.0/verify.tools-archive-rebuild.sh
3. docs(tools): retain step 5 candidate evidence
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
   - docs/v0.27.0/evidence.tools-archive-rebuild.python-selection.md
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-inputs.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-validation.txt
   - docs/v0.27.0/inventory.tools-archive-rebuild.txt
4. docs(tools-archive-rebuild): record step 5 validation
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

The generated Python bytecode cache is preserved locally and excluded through
.git/info/exclude. It is not source or release evidence. No application changes
are part of this staged request. The protocol owns transcript additions after
the request snapshot; the authorized commit continuation handles any residual
tracked changes after the reviewed batch.

### Writer response for step 5 tools-archive-rebuild (round 1)

Writer response:

This is the first review round for Step 5. There is no earlier Step 5 feedback
to accept or dispute. The requested review concerns the exact staged Step 5
implementation and evidence, with later acceptance explicitly pending.

### Reviewer focus for step 5 tools-archive-rebuild (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-5-round-1 -->

## Round 1 by reviewer - Step 5

- Recorded: 2026-09-17T23:46:37+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: answer

### Assessed index identity for step 5 tools-archive-rebuild (exchange 1) (round 1)

Baseline index tree: 4e7c04e71c476c83a5be33af4f0b07eb69810b07

Assessed index tree: 4e7c04e71c476c83a5be33af4f0b07eb69810b07

### Implementation check for step 5 tools-archive-rebuild (exchange 1) (round 1)

Result:

Yes. Step 5 has been fully implemented.

The verdict rests on the reviewer's own measurements, including hashing the
candidate archive itself rather than reading its recorded digest.

The candidate is real and is the archive the record names. The reviewer located
it on the build host and hashed both retained copies, the one inside the
isolated run root the build used and the retained evidence copy: both are
`d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1`, and the
retained copy is exactly 545310257 bytes, matching the record and the request.
Worth noting for a future reader: the archive is deliberately not in the
account's ordinary package directory, whose newest entry and `tools.latest`
symlink still point at a September 13 archive. The build ran in an isolated
owned namespace with its own home, which is what the plan requires of these
runs, so the live installation was left alone.

Implementation against Step 5's named work:

- `pkg_tools.sh` unlinks exactly the staged `tools/python/root/a.out` with
  `rm -f`, not a recursive remove, so a directory at that path fails the run
  instead of being deleted, and a terminal symlink or hardlink is unlinked
  without touching the protected provider it names. The symlink boundary checks
  now cover `tools/python` and `tools/python/root` as well, in both the live
  pre-check and the staged post-copy check, which is what stops a copied
  directory symlink from redirecting the cleanup into the live tree. Other
  `a.out` names stay unadjudicated, as the comment says.
- The inherited 6,661-line relocation harness changed by one line: the literal
  `STEP4_ARCHIVE_DEFECTS` register is now empty because the rebuild discharged
  its only entry. That is exactly the "only literal register updates" boundary
  the plan draws around that file.
- `verify.tools-release-package.sh` covers the step's whole planned matrix and
  proves the properties rather than asserting them. Seven package cases run the
  real packager over regular, absent, symlink, hardlink, directory, and
  symlinked `python` and `python/root` boundaries, and every case compares the
  entire live tree before and after with `diff -r --no-dereference`, so live
  preservation is verified rather than assumed. The gate stub records the staged
  prefix and copies the gated tree, and the test then unpacks the produced
  archive and diffs the two trees, which is the plan's "same trimmed inventory
  reaches gate and tar" as a byte comparison. It also confirms the probe is
  already gone when the gate runs, `.env` survives, `gcc` is trimmed, the
  unrelated `tools/git/root/a.out` survives, the protected providers and loader
  are byte-identical in the archive, the loader hardlink identity survives, and
  the staging prefix is removed afterwards.
- The five register controls drive the actual inherited bookkeeping functions,
  extracted by name from the production harness rather than reimplemented, with
  an assertion that each one loaded so a failed extraction fails the test. They
  cover clean, stale, unowned, owned and replaced, and they treat an unowned
  residual as an explicit later finding rather than a discharged population.
- The cumulative runner accepts step 5 and adds the new harness plus the
  inherited installer, wrapper-scope and SQLite acceptance suites.

Evidence and record, each item checked rather than accepted:

- The generated acceptance Markdown is byte-identical to the validator's own
  `render` output over the sidecar, 34341 characters, so the human view is
  derived from the record rather than written beside it.
- The record keys its single candidate by that candidate's own SHA-256, records
  Python 3.13.15 with a `clean` dated regression decision, which is the pairing
  the validator requires, and passes exactly AR1, AR2, AR4 and RA1 with
  everything else pending or not applicable. Four of thirty required
  publication cells pass, so this record cannot authorize publication, which is
  correct with Step 6 unstarted.
- All six indexed captures verify: the reviewer recomputed each digest from the
  versioned file, six unique reads, every one `versioned` retention rather than
  an ignored local path.
- The four recorded step-5 source hashes match the current files exactly.
- Both authority commits, the source authority and the retention merge the plan
  names, are ancestors of the recorded build base, which the reviewer verified
  with an ancestry check rather than trusting the claim. The declaration digest
  is unchanged and `renewed=no`, and no closure declaration file is staged, so
  the conditional renewal was correctly not performed and no digest was edited
  in place.

Architecture: the change stays in the native packaging adapter; no business
layer gains build responsibilities; the focused harness owns its fixtures. The
650-line Python ceiling does not apply to these Bash files. Nothing needs fixing.

Performance: the new unlink and two boundary checks are fixed cost, the existing
stage copy, closure walk and tar keep their linear passes, and the fixtures use
a fixed case count with linear tree comparisons. No new sort or quadratic path.
No performance issue needs addressing.

Unit test coverage: no Python class and no class-focused unit test changed. This
repository's declared floor is shell lint and its validation entry is the native
cumulative runner, so no percentage is claimed for these Bash files, and the
application's gate measures its own scope. Both new top-level test functions are
invoked by their case loops, their callbacks are invoked by the extracted
production functions, and the two affected packager functions are exercised by
the fixtures and by the real candidate build. No unit-tested class below 100%
needs completing, and no top-level symbol outside the coverage gate is
unreferenced.

Feature integrity: the real gate still runs against the same trimmed stage that
is archived, protected bytes and loader aliases survive, the live tree is
unchanged, and stale and unowned residual reporting still works. The inherited
installer, wrapper, SQLite, D10, agent, record and publication suites remain
green in the reviewer's own run.

Scope: no publication, adoption, release-pin change or umbrella completion is
claimed, and the platform acceptance cells remain pending for Step 6.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 5 rows were checked against the template and against this
reviewer's own measurements, and they needed no correction:

- The status sentence is exactly `Yes. Step 5 has been fully implemented.`,
  followed by a blank line and a short prose summary.
- No stale `Missing work for Step 5` section remains, which is correct for a Yes.
- Every section the template orders is present and filled, each check section
  ends with its required explicit phrase, and the coverage section names the
  measured scopes and adds the second phrase about symbols outside the gate.
- The document-level line correctly remains `No, it is not implemented.`, with
  its theme sentence updated to say Steps 1 to 5 are checked and Steps 6 and 7
  plus final-archive acceptance remain pending.
- The numbers in those rows are accurate. The reviewer independently confirmed
  the archive size and digest, the declaration digest and no-renewal state, the
  reachability of both authority commits from the build base, the six capture
  bindings, the passing cell set, the rendered Markdown equality and the four
  source hashes. The recorded 63-second native run matches the reviewer's 64.
- The rows also state their own limits, which is the part worth crediting: they
  say the historical library rows are inherited parser input rather than
  complete refreshed-library qualification, and that the `ghog day` exit 5 is
  the unconfigured pytest environment rather than a failed gate.

Because no validation-plan path was edited, no pre-repair blob was recorded and
no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 5 tools-archive-rebuild (exchange 1) (round 1)

Both resolved mandatory commands were run by the reviewer in this round, before
any repair could have been made, and both pass.

Project floor: `lint_shell: 58 tracked scripts`, `lint_shell: clean`, exit 0.

Native cumulative runner at `--step 5` on RHEL 9.8 with the independent
`/usr/bin/python3` 3.9.25: `validation exit=0 elapsed=64s`, against the writer's
recorded 63 seconds. The reviewer read the transport driver first as the request
asks, then copied the whole remote log back and confirmed inside it:

- `Independent interpreter: /usr/bin/python3 3.9.25`.
- All seven package cases by name: `PASS package/regular`, `absent`, `symlink`,
  `hardlink`, `directory`, `python-link` and `root-link`.
- All five register controls by name: `PASS register/clean`, `stale`, `unowned`,
  `owned` and `replaced`, then
  `PASS tools-release-package: 7 package cases, 5 register controls`.
- The inherited suites this step newly wires: the installer harness at step 3
  with zero failures, and the wrapper-scope harness reporting
  `OBJECTIVE MET for step 2`.
- Every earlier step's suite still green: 16 record tests, 49 D10 cases, 33
  agent shell cases, 15 transport tests, 6 publication tests and 25 SQLite
  checks.
- The frozen publication suite with `failures 0` and `OBJECTIVE MET for step 5`.

The reviewer honoured the request not to rebuild the payload. The expensive
build is not part of the fixture gate, and re-running it would have proved
nothing the archive's own digest does not already establish.

Beyond the declared set, the reviewer ran the installed staged sensitive-content
hook, which step 4 round 2 showed can refuse a commit that the mechanical plan
checker calls ready. It returns exit 0 here, so this staged set is committable
as well as mechanically valid.

Independent identity binding, which for this step means the archive itself:

- Both retained copies of `tools.2026-09-17_222857.tar.gz` hash to
  `d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1` and the
  retained evidence copy is exactly 545310257 bytes. The reviewer located them
  on the host and hashed the bytes rather than reading the recorded digest.
- All six indexed capture digests recomputed and matched, all `versioned`.
- All four recorded step-5 source hashes recomputed and matched.
- Both authority commits are ancestors of the recorded build base, checked by
  ancestry rather than accepted, and the declaration digest is unchanged with no
  renewal and no staged declaration file.
- The generated acceptance Markdown is byte-identical to the validator's render
  of the sidecar.

Coverage limits stated rather than assumed: this repository declares shell lint
as its floor and has no pytest project, so no percentage is claimed for these
files, and the application's gate measures its own source scope. The `ghog day`
exit 5 the evidence records is not a failed gate here, because that command is
not in this repository's resolved set; the declared floor ran clean.

One precision about what a check proved. The reviewer confirmed the record
cannot authorize publication from its cell census, four of thirty required cells
passing, rather than from a validator call: the direct call refused earlier, on
archive identity, because the reviewer passed a stand-in path instead of the
545 MB archive. The census is the sound basis for that statement.

### Resolved validation set and sources for step 5 tools-archive-rebuild (exchange 1) (round 1)

The reviewer ran the union of the request validation set and the current
resolver set. The union is the same two commands and both pass.

- `bash src/utils/lint_shell.sh`, source `project`. Re-resolved from the
  versioned declaration and run through the project environment so the pinned
  ShellCheck resolved. Result: 58 tracked scripts, clean, exit 0.
- `bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 5 --python
  /usr/bin/python3 --app-repo <owned-app-snapshot>`, source `plan`. Run on the
  native RHEL host through the retained home-local transport driver, which the
  reviewer inspected first: it builds its material from both repositories'
  committed state, overlays the four current staged sources, and runs that exact
  command in a fresh owned snapshot. Result: `validation exit=0 elapsed=64s`.

The declared command again embeds an absolute host snapshot path, as it did in
step 3, so it is not runnable from the authoring host as written and will stop
being runnable once that directory is cleaned. The home-local driver is what
makes it reproducible in practice, and naming the driver in the declaration
rather than the frozen path would close the gap.

Caller evidence retained inside the artifact home, not in versioned notes:
`a.code-review.s5-native-validation.log` (the full remote log),
`a.code-review.s5-render.txt` (the render comparison) and
`a.code-review.s5-plan.json` (the independent commit-plan result).

### Resolver drift and direction for step 5 tools-archive-rebuild (exchange 1) (round 1)

No drift in either direction.

Re-resolving the project floor from the versioned `.review-validation` yields
the same single `project` command the request carries, and the one `plan`
addition parses through the current resolver contract, so the union equals both
sets. The addition changed identity since step 4, which is expected for an
effort-scoped command that now names `--step 5`, and the declaration file itself
was correctly left alone.

One note rather than a drift finding: step 4's final round had four resolved
commands, including the application walk and the staged sensitive-content gate.
Step 5 declares two, which is consistent, since no application file is staged
here. The reviewer ran the sensitive gate anyway, because step 4 established
that a mechanically ready plan can still be refused at commit time.

### Repository state around validation for step 5 tools-archive-rebuild (exchange 1) (round 1)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher rather than from equivalent Git commands.

- Request-time index tree `4e7c04e71c476c83a5be33af4f0b07eb69810b07` equals the
  baseline captured at entry and the live index captured after both validation
  runs, the archive verification on the host and the implementation check.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `0218245242f1ccec3561ef41f23322e0c6c2f3a12e69981a8fc1c9698e769fc6`,
  the same digest observed in every round of this effort. No umbrella row was
  completed from reviewer mode, correctly, with Steps 6 and 7 open.
- Validation-state comparison over the ordered path set, holding all 13 staged
  step paths and the file named by the project command: `acceptable: true` with
  empty `tracked_paths`, `untracked_paths` and `ignored_paths`.
- The working tree matches its entry state: 13 staged paths plus the protocol's
  own unstaged transcript modification, which the reviewer correctly leaves
  unstaged.
- This round produced no reviewer residue in either repository. The native run
  executes inside a fresh owned host snapshot, the archive verification is
  read-only hashing on the host, and the record and render checks were run with
  bytecode writing disabled after an earlier step showed that omission creates
  untracked caches.
- Ordering was correct: the index baseline, umbrella digest and validation-state
  baseline were captured and the manifest written before any assessment.
- Reviewer-authored evidence stayed inside the artifact home as ignored `a.*`
  files, so none of it became a tracked side effect of this review.

### Repair inventory for step 5 tools-archive-rebuild (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 5 tools-archive-rebuild (exchange 1) (round 1)

`a.commit` remains accurate and is executable; the reviewer amended nothing.

The mechanical result is an independent
`commit-plan-check.bat --format json` rerun against the received state rather
than the value embedded in the request: `state: valid`, `ready: true`, exit 0,
no diagnostics, 13 staged paths in four ordered groups matching the request
exactly.

- Group 1, `fix(tools): remove staged compiler probe`: the packager and the
  inherited relocation harness. Least dependent and correctly first, since the
  behavior it changes is what the rest records.
- Group 2, `test(tools): cover step 5 package boundaries`: the new focused
  harness and the cumulative runner that wires it.
- Group 3, `docs(tools): retain step 5 candidate evidence`: the sidecar, the
  acceptance view, the four new evidence captures and the program inventory.
- Group 4, `docs(tools-archive-rebuild): record step 5 validation`: the
  validation plan alone, most dependent, since it summarizes the other three.

Ordering is least to most dependent, every staged path appears exactly once,
and each subject is a conventional single-purpose line whose type matches its
content: `fix` for the packager behavior, `test` for the fixtures, and two
`docs` groups separating retained candidate evidence from the step's validation
record. Splitting those two is a reasonable choice rather than a defect, since
the evidence captures and the validation verdict have different review
lifetimes.

Scope matches the step: no path outside Step 5's named files, its evidence or
its validation record, and no application change, which is right because Step 5
is a cplx-side build and packaging step.

Executability was checked as well, not just mechanical validity, because step 4
showed the two can differ: the installed staged sensitive-content hook returns
exit 0 over this index, so this commit can actually run.

### Findings and boundaries for step 5 tools-archive-rebuild (exchange 1) (round 1)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 5 tools-archive-rebuild (exchange 1) (round 1)

No rework is required for Step 5, and nothing in the staged content needs to
change before the human decides.

Three things are worth recording, none of them blocking.

- The declared plan command again embeds an absolute path inside a host scratch
  directory, as step 3's did. It is not runnable from the authoring host as
  written, and once that directory is cleaned nobody can re-run it, including a
  later reader of this transcript. The home-local transport driver is what makes
  it reproducible, and naming the driver in the declaration rather than the
  frozen snapshot path would close the gap. Step 4's final round did exactly
  that for its application walk, so the pattern is already established here.
- A future reader of this evidence will not find the candidate where the
  ordinary package directory would suggest: that directory's newest entry and
  its `tools.latest` symlink still point at a September 13 archive, because this
  build correctly ran in an isolated owned namespace. The reviewer had to search
  the host to find the two retained copies. One sanitized line in the candidate
  capture saying the archive is retained in an isolated run root and an evidence
  copy, without the private path, would save that search and make the retention
  claim checkable by whoever runs Step 6.
- Step 6 will need to bind exact inputs and reassess affected cells. The record
  is already shaped for that, with 26 of 30 required publication cells pending
  and the wheel, lock and platform cells untouched, so nothing here preempts
  that work.

Worth crediting, because these are the parts that made this round quick to
verify: the acceptance view is rendered from the sidecar rather than written
beside it, the register controls drive the real inherited functions instead of
reimplementations and fail if the extraction breaks, every package case compares
the whole live tree before and after, and the evidence states its own limits
about historical library rows and the unconfigured pytest environment.

When the exchange reaches the human gate, the registered choices are "Rework and
review again" and "Commit". The commit decision belongs to the human, not to
this reviewer and not to the requestor.

### Decision rationale for step 5 tools-archive-rebuild (exchange 1) (round 1)

The recommendation is commit-ready, and it is advisory only: it does not
authorize a commit.

All six readiness-floor results pass:

1. Identity. Exact agreement between the live exchange, the envelope, the
   human-readable request, the plan, the declared step, the positive round and
   the request-time index tree, which still matched at publication.
2. Completeness. Step 5's completion boundary is met: an identified archive, a
   conclusive Python and SQLite build result, the private-stage cleanup with its
   ownership accounting, and resolved declaration authority.
3. Validation and coverage. Both resolved commands were run and pass, with the
   native run confirming all seven package cases, all five register controls,
   the newly wired installer and wrapper suites and every earlier suite. The
   reviewer additionally ran the installed commit gate, which step 4 proved can
   refuse a plan the mechanical checker calls ready.
4. Staged attribution. No reviewer repair, so nothing is attributed to it, and
   this round left no residue in either repository.
5. Unresolved findings. None.
6. `a.commit`. Mechanically valid, correctly grouped and ordered, and
   executable.

No substantive repair was made in this round, so the recommendation is not
disqualified by the same-round rule.

What carried this round was measuring the deliverable rather than reading about
it. Step 5's whole point is that a specific archive exists with a specific
identity, so the reviewer located it on the build host and hashed the bytes:
both retained copies come to
`d8f205cc10d07a71618e730f69d09c179a884c85ce4bb93f163111b5188a15c1`, and the
retained evidence copy is exactly 545310257 bytes. That took a search, because
the archive is deliberately absent from the account's ordinary package
directory, whose newest entry is four days older; the build ran in an isolated
owned namespace, which is what the plan requires and what keeps the live
installation untouched. Finding it there is a confirmation of the isolation
rule, not an anomaly.

The rest of the evidence chain was checked the same way: the six indexed capture
digests recomputed from their versioned files, the four recorded source hashes
recomputed, both authority commits confirmed as ancestors of the recorded build
base by an ancestry check, the declaration digest unchanged with no renewal and
no staged declaration file, and the acceptance Markdown byte-identical to the
validator's own render of the sidecar. The record passes exactly four of thirty
required publication cells, so it cannot authorize publication, which is the
correct state before Step 6.

Two smaller judgments are recorded so they are not mistaken for oversights. The
statement that the record cannot authorize publication rests on the cell census
rather than on a validator call, because the reviewer's direct call refused
earlier on archive identity when handed a stand-in path instead of the 545 MB
file. And the reviewer honoured the request not to re-run the payload build: the
build is not part of the fixture gate, and re-running it would prove nothing the
archive's own digest does not already establish, while the plan explicitly warns
against repeated expensive build loops.

What this answer does not claim: no platform acceptance, no publication, no
adoption, no release-pin change and no umbrella completion. Twenty-six required
cells remain pending, the historical library rows are inherited parser input
rather than complete refreshed-library qualification, and Step 6 owns the actual
RHEL and Debian acceptance of this candidate.

### Final reviewer decision for step 5 tools-archive-rebuild (exchange 1) (round 1)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-5-round-1 -->

## Round 1 by human - Step 5 - human-confirmation

- Recorded: 2026-09-18T09:20:19+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-1 -->
