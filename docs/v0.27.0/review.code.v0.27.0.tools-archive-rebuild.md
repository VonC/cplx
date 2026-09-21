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

## Round 1 by requestor - Step 6

- Recorded: 2026-09-18T20:03:17+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 1

### Code review evidence for step 6 tools-archive-rebuild (round 1)

request_index_tree: 3ad89cbe6b8e21c068be170abcdd7225eec57f12
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- git diff --cached --check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(relocation): define venv preservation
group 1 path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 2: feat(tools): add pinned platform acceptance
group 2 path: ci/deliver-closure-tools.sh
group 2 path: src/setups/env/bin/install_pkg.sh
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 3: docs(tools): record step 6 acceptance gaps
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-validation.txt
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-validation.txt
staged path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: src/setups/env/bin/install_pkg.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 1)

No. Step 6 has NOT been fully implemented.

The staged implementation provides the verification bundle, platform driver,
fixtures and venv exclusion correction. It is submitted at point 1 of the
human-provided handoff, before repackaging. This is not a claim that the plan's
pre-publication completion condition passes.

The real RHEL run bound ten cells: nine passed and PA6 failed because the
archive's old installer removed the wheel objects' ORIGIN search paths. The
corrected installer has not been packaged. Debian acceptance, the exact-wheel
D10 reading and remaining publication obligations are pending, as recorded in
the validation plan's Missing work for Step 6 section.

Validation evidence: the retained native cumulative Step 6 run exited 0 in
74 seconds, including 52 acceptance fixtures, 16 release-record unit tests and
the inherited suites. A separate relocation corpus passed 104 cases. All five
current script digests match that capture. The current local ShellCheck gate,
record binding verification and staged whitespace check pass. The three-group
root a.commit passes commit-plan-check with ready=true and no diagnostics.
The prior ghog day passed shell lint but exited 5 because cplx has no configured
pytest environment; this limitation is retained, not represented as a pass.

No Python class changed and no Python coverage percentage is claimed. Functions
are exercised by the fixture suite or real platform driver. Delivery remains
in CI, platform acceptance in the effort scripts, and relocation in the
installer. Venv discovery adds one listing walk; bundle member sorting is
O(n log n), while hashing and evidence scans are linear in input size. No new
quadratic path was identified. Existing into-directory delivery and inherited
installer/closure behavior remain covered. PA6 is a retained failure, never
relabeled from passing fixtures.

### Implementation report for step 6 tools-archive-rebuild (round 1)

The delivery script composes a deterministic verification bundle from a pinned
commit and verifies its revision, members and digests. The platform driver
checks explicit inputs, runs RHEL acceptance, reads retained Debian evidence,
wraps bounded D10 readings and summarizes missing cells as pending.

The installer excludes directories containing pyvenv.cfg from the ELF pass
and logs each excluded tree. The symlink and text relocation passes remain.
A failing-first fixture preserves a wheel's bytes and ORIGIN search path
while checking that an external library is still rewritten.

The cumulative Step 6 runner includes 52 acceptance fixtures. The structured
record, human-readable view and captures retain the real failed candidate.
Q06 and the umbrella document the venv decision and required repackage. The
handoff recheck corrected two stale fixture counts and preserved the No
verdict and explicit missing work. No archive was repackaged or published.

The plan validation command uses the existing ignored native transport helper
in cumulative mode. Run it inside the project CMD environment established by
senv.bat, with NO_MORE_SENV_cplx cleared, as CLAUDE.md requires. It transfers
the five current script files and an application checkout snapshot, then runs
the native cumulative runner with independent system Python and explicit app
path in owned scratch space. This is fixture validation, not the real
hour-long platform acceptance mode.

### Change summary for step 6 tools-archive-rebuild (round 1)

The root a.commit contains three groups, covering all 14 staged paths:

1. docs(relocation): define venv preservation
   - docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
   - docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
   - docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
2. feat(tools): add pinned platform acceptance
   - ci/deliver-closure-tools.sh
   - src/setups/env/bin/install_pkg.sh
   - docs/v0.27.0/acceptance.tools-archive-rebuild.sh
   - docs/v0.27.0/verify.tools-release-acceptance.sh
   - docs/v0.27.0/verify.tools-archive-rebuild.sh
3. docs(tools): record step 6 acceptance gaps
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-validation.txt
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

No group marks Step 6 complete. The staged code matches the retained native
validation digests; only documentation was corrected during the handoff check.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 1)

Human guidance:

The human explicitly requested the code review after confirming that only
point 1 of the handoff has been reached. Points 2 through 6 have not started.
The handoff orders committing the current Step 6 work before repackaging;
the validation plan must retain its No verdict while required evidence is
missing. The request does not authorize a commit or a declaration of completion.

Writer response:

This is the first review round for the current Step 6 work. No earlier feedback
or reviewer repair has been accepted or reversed in this exchange.

The handoff explicitly orders review of the current work before repackaging.
Please assess the exact staged implementation and its honest incomplete
validation state. Do not infer completion or weaken a required acceptance gate
from this requested ordering.

### Reviewer focus for step 6 tools-archive-rebuild (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-1 -->

## Round 1 by reviewer - Step 6

- Recorded: 2026-09-18T20:14:05+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 1)

Baseline index tree: 3ad89cbe6b8e21c068be170abcdd7225eec57f12

Assessed index tree: 3ad89cbe6b8e21c068be170abcdd7225eec57f12

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 1)

Result:

No. Step 6 has NOT been fully implemented.

The reviewer reaches the writer's verdict independently. Step 6's completion
condition is that the release validator's publication phase passes every
pre-publication obligation for the final candidate, and the record shows the
opposite for good reasons: PA6 failed on RHEL against the Step 5 candidate, that
candidate is now known to carry a defective installer and must be repackaged,
and the Debian cells and the exact-wheel D10 reading have not run. On top of
that, this round found the declared validation failing on the current
application, which the writer's evidence did not show.

What the staged work does correctly, verified rather than accepted:

- The installer fix in `src/setups/env/bin/install_pkg.sh` is sound and narrowly
  scoped. One listing walk collects every directory holding `pyvenv.cfg`, those
  subtrees are pruned from the ELF pass only, each exclusion is logged so the
  install output shows what was deliberately left alone, and the prune list uses
  the file's guarded-expansion idiom for an empty array. The symlink and text
  passes still relocate a shipped venv's `bin/python` link and `pyvenv.cfg`,
  which is what the deployment readiness checks require.
- The scope change was made the right way. `install_pkg.sh` was not in Step 6's
  planned files, and the writer did not simply edit it: the decision is recorded
  as Q06 in the requirement with its date, trigger, scope and rejected
  alternatives, then carried into the design's risk table, the plan's baseline
  row and Step 6 file list, the plan's test list, and the umbrella. The plan also
  states the consequence plainly: because the installer ships inside the
  archive, the Step 5 candidate is now a failed candidate and Step 5 must repeat
  a single repackage.
- The record is honest. It still names the Step 5 candidate, keys it by its own
  digest, and holds PA6 on RHEL as `fail` alongside 13 passing, 2 not applicable
  and 22 pending cells, with publication and adoption pending. The failure was
  not relabeled from fixtures, and with 30 required publication cells the record
  cannot authorize publication.
- The umbrella additions integrate with, rather than overwrite, the D11 decision
  and item 8 recorded earlier: they extend item 7's note with the correction and
  add item 8's venv-location and never-walk decisions, and the requirement's PA6
  row now says which venv the deployment provides before and after item 8.

What blocks the step beyond the evidence it admits is missing:

- The staged set is refused by the installed sensitive-content hook, so the
  commit the human's handoff orders next cannot run.
- The declared native cumulative validation fails. Three application CI helpers
  use PEP 604 annotations without the future import and cannot be imported by
  the required Python 3.9.25, which the reviewer demonstrated by importing each
  one under the host's independent interpreter. The syntax arrived in app commit
  `6281b10a`, after the writer's validation ran against `ea8363c4`.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 1)

- Remove the private application name from `docs/v0.27.0/acceptance.tools-archive-rebuild.sh`
  lines 330 and 415 by deriving the project directory rather than writing it,
  and from umbrella line 1286 by using the `my-project` name the umbrella uses
  elsewhere; then require the installed sensitive-content hook clean.
- Add `from __future__ import annotations` to `app:ci/tools_abi_scan.py`,
  `app:ci/tools_test_evidence.py` and `app:ci/tools_wheel_capture.py`, and add a
  check that imports the independent-interpreter helpers under the plan's
  minimum Python so a later lint pass cannot reintroduce the break unseen.
- Re-run the declared native cumulative validation against the current
  application and record the application commit it used; confirm the 52
  acceptance fixtures, which the reviewer's run did not reach.
- Return to Step 5 for the single repackage of the unchanged payloads with the
  corrected installer, record the new candidate identity, and repeat AR1, AR2
  and AR4, as the amended plan requires.
- Repeat the affected RHEL cells, PA6 first, against the repackaged candidate.
- Run the Debian acceptance and the exact-wheel D10 reading against both
  provider candidates, and complete the remaining pre-publication obligations.
- Keep the validation plan's `No` verdict until all of the above holds, then
  restate it from the evidence.

Architecture: acceptance stays in the effort scripts, delivery in CI, relocation
in the installer, and the venv decision is recorded in the owning documents. No
application domain code is touched. Nothing else needs fixing here.

Performance: venv discovery adds one listing walk rather than a fork per
directory, bundle member sorting is `O(n log n)` over a small member set, and
hashing and evidence scans are linear. No new quadratic path. No performance
issue needs addressing.

Unit test coverage: no Python class changed in cplx and no percentage is
claimed. The application helpers' failure is an import-time compatibility break,
not a coverage gap, and it is listed as missing work above. No unit-tested class
below 100% needs completing, and no top-level symbol outside the coverage gate
is unreferenced.

Feature integrity: into-directory delivery and the inherited installer and
closure behavior remain covered by the fixtures that ran before the failure, and
the failed PA6 cell is preserved as a failure. The regression in the application
CI helpers impairs the step 4 agent fixtures that the cumulative runner depends
on, which is recorded as missing work above.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows already state what this assessment concludes: the
status sentence is exactly `No. Step 6 has NOT been fully implemented.`, and a
`Missing work for Step 6` section is present, which is what a `No` verdict
requires. The document-level line correctly remains `No, it is not implemented.`

The writer should add two items to that missing-work list when reworking, since
neither was known when it was written: the three staged lines the
sensitive-content hook refuses, and the application CI helpers that the
required Python 3.9 cannot import. Both are stated concretely in this answer's
implementation check.

Because no validation-plan path was edited, no pre-repair blob was recorded and
no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 1)

All three resolved mandatory commands were run by the reviewer in this round,
before any repair could have been made. Two pass and one fails.

- `bash src/utils/lint_shell.sh`, source `project`: `lint_shell: 58 tracked
  scripts`, `lint_shell: clean`, exit 0. The count is unchanged although this
  step adds two shell harnesses, because both live under `docs/`, which that gate
  excludes by its documented scope; the cumulative runner lints them instead.
- `git diff --cached --check`, source `request`: no output, exit 0.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run inside the
  project environment as the request asks: `validation exit=1 elapsed=34s`. The
  run passed the 49 D10 cases and the step 4 agent shell fixtures, then stopped
  with a traceback importing `app:ci/tools_abi_scan.py`:
  `TypeError: unsupported operand type(s) for |: 'type' and 'NoneType'` at the
  signature `def trace_init(...) -> str | None:`.

The reviewer established the cause rather than inferring it. The host's
independent interpreter reports Python 3.9.25. Importing each application CI
helper under it, the way the cplx fixture loads them, gives: `tools_abi_scan.py`
fails with that `TypeError`, `tools_test_evidence.py` fails the same way,
`tools_wheel_capture.py` fails on a generic-alias union, `tools_candidate_bundle.py`
imports cleanly, and `tools_test_plugin.py` fails only because `pytest` is absent,
which is expected for a plugin that loads inside the application venv. None of
the three failing files carries `from __future__ import annotations`.

The application history places the change precisely: `6281b10a ci(checks): lint
acceptance helpers used by cplx` follows `ea8363c4`, and the writer's recorded
validation names `ea8363c4` as its application commit. The recorded pass was
real for that commit and does not describe the application now. The native
driver prints an "app commit" value for its transferred snapshot that does not
resolve in the application repository, so it identifies the fixture copy rather
than a real commit; the writer's evidence correctly records the real one.

Because the run stopped at that failure, the reviewer could not confirm the 52
acceptance fixtures this step adds, nor anything after them in the runner.

Beyond the declared set, the reviewer ran the installed sensitive-content hook,
which step 4 showed can refuse a plan that the mechanical checker calls ready.
It refuses this one: `Commit blocked` at three locations.

What was verified rather than accepted, apart from the commands:

- Index identity `3ad89cbe6b8e21c068be170abcdd7225eec57f12` at entry and after
  every run; commit plan `valid` and `ready` with three groups for 14 paths.
- The record's cell census: the Step 5 candidate, keyed by its own digest, with
  PA6 on RHEL held as `fail`, 13 passing, 2 not applicable and 22 pending.
- The validation plan's exact `No` sentence and its `Missing work for Step 6`
  section.
- The installer diff, the Q06 decision and its propagation through the
  requirement, design, plan and umbrella.

Coverage limits stated rather than assumed: no Python percentage is claimed for
cplx, which declares shell lint as its floor, and the application's gate
measures its own source scope rather than these CI helpers.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 1)

The reviewer ran the union of the request validation set and the current
resolver set: the same three commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean, exit 0.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Run inside the
  project environment established by `senv.bat` with the guard cleared, after
  the reviewer read the driver. It builds material from both repositories'
  committed state, overlays the five current step scripts, and runs the native
  cumulative runner with the independent system Python in owned scratch space.
  Result: exit 1 after 34 seconds, on the application CI helper import.
- `git diff --cached --check`, source `request`. Clean, exit 0.

The plan addition is now a home-local driver rather than a frozen host path,
which fixes the reproducibility weakness raised in steps 3 and 5.

Caller evidence retained inside the artifact home, not in versioned notes:
`a.code-review.s6-import-probe.sh` (the per-helper import check run under the
host's independent interpreter) and `a.code-review.s6-plan.json` (the
independent commit-plan result). The remote validation log stays in the owned
host fixture.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 1)

No drift in either direction.

Re-resolving the project floor from the versioned `.review-validation` yields
the same single `project` command the request carries; the `plan` addition and
the `request` addition both parse through the current resolver contract, so the
union equals both sets.

The request's addition of `git diff --cached --check` widens what the review
proves, which is the direction the no-removal rule protects. The declared set
still omits the installed sensitive-content hook, the check that decided both
this step and step 4 round 2; adding it as a standing request addition would
move that discovery from the reviewer to the declaration.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 1)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher rather than from equivalent Git commands.

- Request-time index tree `3ad89cbe6b8e21c068be170abcdd7225eec57f12` equals the
  baseline captured at entry and the live index captured after all runs.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `8aabd162a3800f3721b369ab4009f1081de5f7541bc2dfaff5216e2984b2db15`.
  The digest differs from earlier rounds because the umbrella gained D11 and
  item 8 in commit `3bbd15c` and the writer's staged Q06 additions since; within
  this round it did not change, and no umbrella row was completed.
- Validation-state comparison over the ordered path set, holding all 14 staged
  step paths and the file named by the project command: `acceptable: true` with
  empty `tracked_paths`, `untracked_paths` and `ignored_paths`.
- The working tree matches its entry state: 14 staged paths plus the protocol's
  own unstaged transcript modification, which the reviewer leaves unstaged.
- No reviewer residue in either repository. The cumulative run and the import
  probe executed in an owned host fixture, and the sensitive-content checks are
  read-only.
- Ordering was correct: the index baseline, umbrella digest and validation-state
  baseline were captured and the manifest written before any assessment.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 1)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 1)

`a.commit` is mechanically accurate and the reviewer amended nothing, but it is
not executable as staged.

Independent `commit-plan-check.bat --format json` rerun against the received
state: `state: valid`, `ready: true`, exit 0, no diagnostics, 14 staged paths in
three ordered groups matching the request.

- Group 1, `docs(relocation): define venv preservation`: the requirement,
  design, plan and umbrella, which record Q06. Least dependent and correctly
  first, since the decision precedes the code that implements it.
- Group 2, `feat(tools): add pinned platform acceptance`: the delivery script,
  the installer, the acceptance driver and both runners.
- Group 3, `docs(tools): record step 6 acceptance gaps`: the record, its view,
  the RHEL capture, the validation capture and the validation plan. Its subject
  says "gaps" rather than claiming completion, which is accurate.

Ordering is least to most dependent and every staged path appears once. One
scope note: group 1 places the installer's governing decision under a
`docs(relocation)` subject while the installer itself sits in a `feat(tools)`
group. That split is defensible, decision before code, but the installer change
is a fix to inherited behaviour, so a reader tracing the PA6 defect will find
the code change under `feat` rather than `fix`.

Not executable: the installed sensitive-content hook refuses the staged set,
with two locations in group 2's acceptance driver and one in group 1's umbrella.
`commit-plan-check` does not consult that hook, which is why it reports ready.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 1)

Unresolved findings:

- The staged set cannot be committed: the installed sensitive-content pre-commit hook refuses it at three locations, two in `docs/v0.27.0/acceptance.tools-archive-rebuild.sh` (lines 330 and 415, functional path and venv-discovery uses) and one in the umbrella (line 1286, the created-venv location), each embedding the private application name, which blocks the commit the human's handoff orders next.
- The declared native cumulative validation fails on the current application: `app:ci/tools_abi_scan.py`, `app:ci/tools_test_evidence.py` and `app:ci/tools_wheel_capture.py` use PEP 604 annotations without `from __future__ import annotations` and cannot be imported by the required independent Python 3.9.25, a regression introduced by app commit `6281b10a` after the writer's recorded validation ran against `ea8363c4`, so the recorded pass describes an application state that no longer exists.

Boundary-crossing work: None.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 1)

Human guidance:

The human explicitly requested the code review after confirming that only
point 1 of the handoff has been reached. Points 2 through 6 have not started.
The handoff orders committing the current Step 6 work before repackaging;
the validation plan must retain its No verdict while required evidence is
missing. The request does not authorize a commit or a declaration of completion.

Guidance response:

The guidance is followed on every point it makes, and one of its instructions
cannot be carried out yet for a reason the guidance could not have known.

- No completion is declared. This answer's own implementation check reaches the
  same `No` verdict as the writer, independently, and the disposition is
  changes-requested.
- The validation plan's `No` verdict is retained, and the reviewer confirmed it
  is structurally correct: the Step 6 status sentence is exactly
  `No. Step 6 has NOT been fully implemented.` and a `Missing work for Step 6`
  section is present, which is what a `No` verdict requires.
- No commit is authorized by this answer, and none was made by the reviewer.

The handoff's next action is to commit the current Step 6 work before
repackaging. That commit cannot run as staged. The reviewer ran the installed
sensitive-content hook against the index and it refuses the commit at three
locations, the first finding in this answer. So point 1's closing action is
blocked until those three lines stop embedding the private application name.

The second finding bears on the order of the remaining points. Repackaging is
point 2, and every later point re-runs the cumulative runner, which currently
fails on the application's CI helpers under the required Python 3.9. Making
that runner green again belongs before repackaging rather than after, so the
repackaged candidate is qualified against an application that the required
interpreter can actually load. The fix lives in the application repository.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 1)

Two concrete fixes, then re-run the declared validation, then commit point 1's
work as the handoff intends. Nothing here asks for the remaining acceptance
evidence to be faked or rushed; the step stays `No` until that evidence exists.

1. Make the staged set committable.

   The installed sensitive-content hook refuses three staged locations. Two are
   functional uses in `docs/v0.27.0/acceptance.tools-archive-rebuild.sh`: line 330
   changes into the project directory under the deployed prefix, and line 415
   discovers the venv under it with a pattern embedding the name. Derive the
   project directory instead of writing it: the deployed prefix holds exactly one
   project directory under `pdfs/`, so discover it and assert that it is unique,
   or take it as an explicit argument from the caller, which can hold the real
   value in ignored context. Step 4 round 3 fixed the same pattern in
   `verify.tools-release-agent.sh` by asserting the path's shape rather than its
   literal, and that approach carries over directly.

   The third is in the umbrella, line 1286, where the created venv's location is
   written with the real name twice. The umbrella names the consuming project
   `my-project` everywhere else, so write the path with that name, or describe it
   as the project's venv directory without the literal. Then run the installed
   hook against the index and require it clean before committing; it is the gate
   the commit will actually meet, and `commit-plan-check` does not consult it.

2. Restore the application CI helpers under the required interpreter.

   Add `from __future__ import annotations` at the top of
   `app:ci/tools_abi_scan.py`, `app:ci/tools_test_evidence.py` and
   `app:ci/tools_wheel_capture.py`. That keeps the annotations the lint pass added
   while making them lazy, so Python 3.9 never evaluates `str | None` at import.
   The reviewer imported all five helpers under the host's `/usr/bin/python3`
   (3.9.25) exactly as the cplx fixture loads them: those three raise `TypeError`,
   `tools_candidate_bundle.py` imports cleanly, and `tools_test_plugin.py` fails
   only on the absent `pytest`, which is expected for a plugin that loads inside
   the application venv. Two of the three run under `TOOLS_AUTHORING_PYTHON`, whose
   default is `/usr/bin/python3`, so this is not only a fixture concern.

   The same lint pass will reintroduce the problem unless something enforces the
   floor. A single check that imports the independent-interpreter helpers under
   the plan's minimum Python would have caught `6281b10a` before it landed. The
   cumulative runner already exercises them, but only when someone runs it, which
   is why the writer's recorded pass, taken at `ea8363c4`, still read green.

3. Re-run the declared native cumulative validation against the current
   application and record which application commit it used. The failure stopped
   the run at the step 4 agent fixtures, so the 52 acceptance fixtures this step
   adds were not reached in the reviewer's run and remain unconfirmed.

Worth recording as done well, because it is the part of this round that most
reduces risk: the writer found a real deployment defect through the real RHEL
run, kept PA6 as a failure instead of relabeling it from fixtures, fixed the
installer with a narrowly scoped and well-logged exclusion, and recorded the
decision as Q06 before changing an inherited file, propagating it through the
requirement, design, plan and umbrella. The plan's instruction to return to
Step 5 for a single repackage, because the installer ships inside the archive,
is also correct: the candidate verified in Step 5 is now a failed candidate.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 1)

The disposition is changes-requested and the readiness floor is recorded as
incomplete. That outcome was never in doubt, since the writer's own verdict is
`No` and the human guidance forbids declaring completion. What this answer adds
is two things neither party had seen, one of which blocks the human's next step.

Where the six readiness-floor results stand:

1. Identity. Passes exactly; the index tree matched at entry and after every run.
2. Completeness. Fails, as the writer states: PA6 failed, the candidate must be
   repackaged, and the Debian cells and exact-wheel D10 reading have not run.
3. Validation and coverage. Fails. The declared native cumulative command exits
   1 on the current application.
4. Staged attribution. Passes. The reviewer made no repair and left no residue in
   either repository; its import probe ran in the owned host fixture.
5. Unresolved findings. Two.
6. `a.commit`. Mechanically valid and correctly grouped, and not executable,
   because the installed hook refuses the staged set.

The first finding matters most to the human, because it blocks the one action
the handoff orders next: committing point 1's work before repackaging. It is the
same class of defect step 4 round 2 surfaced and fixed, recurring now in a new
927-line script and in the umbrella, which shows the fix was local rather than a
practice. The installed hook is the only gate that checks it, and it is not part
of any declared validation set, so it keeps being discovered late.

The second finding is a regression the process let through, and the rationale
is worth stating because the fix is easy but the lesson is not. The application
CI helpers were accepted in step 4. An application lint pass afterwards,
`6281b10a`, added annotations that Python 3.9 cannot evaluate, without the future
import, and nothing caught it because the application's own gates run on Python
3.13 while the only exercise under 3.9 is the cplx cumulative runner, which runs
when someone invokes it. The writer's recorded pass was honest and real, taken
at `ea8363c4`, and is simply older than the break. This is why the reviewer
re-runs the declared command rather than reading its recorded result: here the
recorded result and the current result disagree.

Two claims were checked because they could have made this answer wrong. The
failure is not an artifact of the reviewer's environment: the reviewer
reproduced it by importing each helper under the host's own interpreter and got
a consistent result per file, including a clean import for the one helper
without the syntax and an expected, unrelated failure for the pytest plugin. And
it is not caused by the staged cplx work, which touches no application file; it
comes from the application's history, which the cumulative runner ships.

The staged work itself deserves recognition, because it is the most valuable
thing this step has produced so far: a real RHEL run found a real deployment
defect that no fixture had shown, the failure was kept as a failure, the fix is
narrow and logged, and the decision was recorded before an inherited file
changed. None of the findings is a criticism of that work.

What this answer does not claim: no repackage, no new candidate, no passing PA6,
no Debian acceptance, no D10 reading and no publication. The Step 5 candidate is
now a failed candidate, and the next valid candidate does not exist yet.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-1 -->

## Round 2 by requestor - Step 6

- Recorded: 2026-09-18T20:36:00+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 2

### Code review evidence for step 6 tools-archive-rebuild (round 2)

request_index_tree: 7acde90db1e895042b4933fd8de95e4d24a75aca
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(relocation): define venv preservation
group 1 path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 2: feat(tools): add pinned platform acceptance
group 2 path: ci/deliver-closure-tools.sh
group 2 path: src/setups/env/bin/install_pkg.sh
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 3: docs(tools): record step 6 acceptance gaps
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-validation.txt
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-validation.txt
staged path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: src/setups/env/bin/install_pkg.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 2)

No. Step 6 has NOT been fully implemented.

This review is for handoff point 1: commit the current implementation and its honest incomplete acceptance record before repackaging. The real RHEL PA6 failure, Debian acceptance, exact-wheel D10 and publication obligations remain pending. They must not be promoted to passes or pulled into this commit gate.

Round 1's two current blockers are fixed. Native cumulative Step 6 passed in 84 seconds on independent Python 3.9.25 against application source HEAD 6b22c16fdf9d0aa2ba083f935771209d4a5fc862 plus the three repair overlays named and digested in the validation capture. It passed 58 acceptance cases, four helper imports, 16 record tests and all inherited suites. The older 74-second run and separate 104-case relocation run remain historical evidence.

Local ShellCheck, the installed sensitive-content hook, focused application Ruff, record binding and staged whitespace checks pass. The project review floor is bash src/utils/lint_shell.sh, also passed in the native cumulative run. No Python coverage percentage is claimed from these stdlib fixtures.

Discovery checks exactly one project and one venv before attempting the audit; six fixtures cover missing/ambiguous choices and its working directory. The new helper is linear in the number of immediate directory entries. Existing bundle composition and installer relocation behavior remain covered. No new class, architecture boundary crossing or quadratic path was introduced.

The cplx a.commit retains three groups, now covering 15 paths. The application repairs are separately staged in its sibling checkout, not hidden in the cplx index or described as committed. They need its separate commit flow before the later candidate build. No archive, payload, pipeline pin or remote changed.

### Implementation report for step 6 tools-archive-rebuild (round 2)

The delivery script composes a deterministic verification bundle from a pinned commit and verifies its revision, members and digests. The platform driver checks explicit inputs, runs RHEL acceptance, reads retained Debian evidence, wraps bounded D10 readings and summarizes missing cells as pending.

The installer excludes pyvenv.cfg trees from the ELF pass, logs each exclusion, and preserves wheel bytes and ORIGIN paths. Symlink and text relocation remain. The driver now discovers a unique deployed project/venv instead of embedding a private project name. The cumulative runner imports the independent app helpers and runs 58 acceptance cases. Its inherited agent fixture models the current typed pytest hooks. Three staged application reader repairs postpone annotations to support Python 3.9; their digests are explicit in the capture.

The release record preserves the failed RHEL candidate. Q06 and the umbrella document the venv decision and required repackage. Native cumulative validation passed against current application HEAD plus those repairs. The transport command runs in the project CMD environment, transfers six cplx overlay files and the app snapshot with its three repair files, and verifies their hashes. Use cumulative mode only for this review. The hour-long candidate acceptance mode and later handoff points have not been run.

### Change summary for step 6 tools-archive-rebuild (round 2)

The root a.commit contains three groups, covering all 15 staged cplx paths:

1. docs(relocation): define venv preservation
   - docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
   - docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
   - docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
2. feat(tools): add pinned platform acceptance
   - ci/deliver-closure-tools.sh
   - src/setups/env/bin/install_pkg.sh
   - docs/v0.27.0/acceptance.tools-archive-rebuild.sh
   - docs/v0.27.0/verify.tools-release-acceptance.sh
   - docs/v0.27.0/verify.tools-archive-rebuild.sh
   - docs/v0.27.0/fixtures.tools-release-agent.py
3. docs(tools): record step 6 acceptance gaps
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-validation.txt
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

No group marks Step 6 complete. Current overlay digests match the new native
capture. Three application CI reader repairs are separately staged in the
sibling checkout and await that repository's commit process;
they are not part of this cplx index or a.commit.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 2)

Human guidance:

The human explicitly requested the code review after confirming that only
point 1 of the handoff has been reached. Points 2 through 6 have not started.
The handoff orders committing the current Step 6 work before repackaging;
the validation plan must retain its No verdict while required evidence is
missing. The request does not authorize a commit or a declaration of completion.

Writer response:

Accepted both current blockers. No reviewer repair was reverted and there is no disagreement with the requested corrections. The reviewer explicitly knew the handoff's ordering; its writer instructions said to fix these blockers, rerun validation and commit point 1 before repackaging. The remaining acceptance work still belongs to handoff points 2 through 6.

1. Removed all three private-name references. The driver discovers a unique deployed project and a unique pyvenv.cfg-bearing venv, refusing missing or ambiguous choices, and the uv probe derives its working directory from that venv. The umbrella uses my-project. Six new fixtures pass; the installed sensitive-content hook passes and is now an explicit request validation.
2. Added postponed annotations to app:ci/tools_abi_scan.py, app:ci/tools_test_evidence.py and app:ci/tools_wheel_capture.py. The wheel reader's annotation-only Message import moved under TYPE_CHECKING for Ruff. Repairs are staged in the sibling application checkout, pending its separate commit process. Its HEAD is now 6b22c16f, newer than the review's 6281b10a; the transport overlays and verifies these precise three files.
3. Added actual imports of four independent helpers to the cumulative runner using the selected system Python rather than py_compile alone. The first rerun then exposed the inherited fixture's obsolete pytest double and old session-finish signature. Updated that fixture to model the typed hooks and call pytest_sessionfinish(0); no plugin behavior was relaxed.
4. Reran cumulative validation successfully: 84 seconds, Python 3.9.25, 58 acceptance fixtures and all inherited suites. Captures distinguish real application HEAD plus repair digests from transport-generated fixture commits. Full raw log remains at .reviews/a.step6.round2-native.log and on the native host; its digest is recorded in the versioned fixture capture.
5. Updated the plan file inventory, validation report, record capture digest, generated record view and a.commit membership/count. Candidate states remain unchanged. The No verdict is deliberate per the handoff.

The installed hook is included as bash .git/hooks/pre-commit. Native validation uses bash .reviews/a.step6.transport.sh cumulative, whose ignored transport now carries six cplx files plus the three explicitly identified app repairs.

### Reviewer focus for step 6 tools-archive-rebuild (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-2 -->

## Round 2 by reviewer - Step 6

- Recorded: 2026-09-18T20:51:32+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 2)

Baseline index tree: 7acde90db1e895042b4933fd8de95e4d24a75aca

Assessed index tree: 6b5a21d81b88e646133778439e58162f87d290cd

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 2)

Result:

No. Step 6 has NOT been fully implemented.

The reviewer reaches the writer's verdict independently, and it is the expected
one: this round reviews handoff point 1, the current implementation and its
honest incomplete record, before repackaging. The step's completion condition,
a passing publication phase for the final candidate, cannot hold yet. PA6 failed
on RHEL against a candidate that ships the uncorrected installer, and the Debian
cells, the exact-wheel D10 reading and the publication obligations have not run.

Both round 1 blockers are fixed, verified rather than accepted:

- Sensitive content. The driver no longer names the project. The new
  `deployed_venv` function takes the single directory under the prefix's
  `pdfs/` and the single `python_*` venv holding `pyvenv.cfg` below it, and
  refuses zero or several of either. The uv audit derives its working directory
  from the venv as `../..` instead of a literal path. The umbrella now writes
  `my-project`. The installed hook passes the staged set, and no private name
  appears in any added or removed staged line.
- Python 3.9. The three application readers carry
  `from __future__ import annotations`. The wheel reader's `Message` import
  moved under `TYPE_CHECKING`, and `Message` appears in a single annotation, so
  no runtime path lost it. Every remaining `|` in the three files sits in an
  annotation or a string literal. The staged application blobs equal the three
  digests recorded in the validation capture, byte for byte.

The round also closes the gap that let the regression through. The cumulative
runner now imports the four independent helpers under the selected interpreter
at step 4 and above, rather than only compiling them, which does evaluate
annotations. That import exposed a second stale piece, the agent fixture's
pytest double and its old two-argument `pytest_sessionfinish` call. The
application plugin at HEAD `6b22c16f` declares
`pytest_sessionfinish(exitstatus: int)`, so the fixture's one-argument call
matches it and weakens nothing.

Discovery was checked against a real deployment, not only its fixtures. The
pdfs archive holds exactly one directory under `pdfs/`; its other two entries
are files. The retained raw captures of the bound RHEL run show that during both
deployments and at the audit only the shipped venv existed; a second venv, named
after the candidate interpreter, appears only later, when the operator `senv`
probe runs. So the uniqueness rule selects the venv the old pattern selected,
and refuses rather than guesses if a later layout changes.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 2)

- Commit the three application reader repairs through the application
  repository's own flow, and record the application commit carrying the three
  digests, so the Step 6 evidence names a committed revision rather than an
  overlay.
- Return to Step 5 for the single repackage with the corrected installer,
  record the new candidate identity, and repeat AR1, AR2 and AR4.
- Rerun the RHEL driver over the repackaged candidate until PA6 passes, and
  rebind the affected RHEL cells.
- Run the Debian agent candidate build and the driver's `debian` mode, and bind
  the Debian cells, environment and consumers.
- Take the D10 reading with the agent's exact wheels against both provider
  candidates.
- Bind the remaining pre-publication obligations and run the publication phase
  until it prints the accepted digest; keep the `No` verdict until then.

Architecture: boundaries are unchanged. Discovery lives in the driver beside the
probes that use it, and the application change is a future import plus one
annotation-only import move. No violation or smell.

Performance: discovery is two glob expansions over immediate directory entries,
linear in their count, and the helper import runs once per helper. No new
quadratic path.

Unit test coverage: no Python class changed and the application readers gained
no symbol; the agent fixture and the new import check exercise all three. No
percentage is claimed. No unit-tested class below 100% needs completing, and no
top-level symbol outside the coverage gate is unreferenced.

Feature integrity: when discovery refuses, PA6 on RHEL records `inconclusive`
with the reason "no unique deployed project and venv", never a pass. The 58
acceptance fixtures, 49 D10 cases, 33 agent cases and every inherited suite
pass. Nothing is impaired.

Validation plan effects:

The reviewer edited three Step 6 rows of
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md` and staged
exactly that attributable patch. All three correct facts this round made stale;
none changes the verdict.

- Architecture check, size row: the driver is 943 physical lines, not 927. The
  row said no Python file changed, which this round made false; it now names
  the changed Python files (the agent fixture at 215 lines and the three
  repaired application readers at 250, 94 and 121) against the 650-line ceiling.
- New types row: the driver's function list now includes `deployed_venv`.
- Missing work for Step 6: a new bullet to commit the three application reader
  repairs through the application's own flow and record the commit carrying
  their digests. The request says they need that flow, and the plan now names
  them as Step 6 work, but the list omitted them.

The status sentence stays exactly `No. Step 6 has NOT been fully implemented.`,
the `Missing work for Step 6` section stays present, and the document-level line
stays `No, it is not implemented.` No umbrella row was touched.

Pre-repair blob `ac56a0ba0234fa9d72451845c3300055b4b0cf73` was recorded before
the first edit. `attribute-reviewer-patch` returned `attributable: true`, and
`git apply --cached` staged exactly that patch, leaving the working tree equal
to the index for this file.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 2)

The reviewer ran all four resolved mandatory commands before making any repair.
All four pass.

- `bash src/utils/lint_shell.sh`, source `project`, through the project
  environment: `lint_shell: 58 tracked scripts`, `lint_shell: clean`, exit 0.
- `git diff --cached --check`, source `request`: no output, exit 0.
- `bash .git/hooks/pre-commit`, source `request`, through the project
  environment: exit 0. The dispatcher runs the managed sensitive-content hook,
  which refused round 1 at three locations. A separate scan of every added and
  removed staged line for the private identifiers found none.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run by the
  reviewer alone after reading the transport and its native script:
  transport exit 0 in 98 seconds, native `validation exit=0 elapsed=75s`, on
  independent Python 3.9.25. The native script verified the three application
  overlay digests before running.

The log was read beyond its tail, not just its exit code: four
`PASS independent helper import` lines, 16 record tests, 49 D10 cases, 33 agent
shell cases, 63 and 53 installer and wrapper cases, 38 SQLite controls, the six
new discovery cases by name, `PASS tools-release-acceptance: 58 cases`, 15
transport and 6 publication tests, and 254 historical closure cases. No FAIL
line. The native log digest was
`e6147c5ad659d7cd6161b1a0250366b11bf1bb479bed98fa3907f890526a6e18`, and it
differs from the writer's retained log only because each run records its own
fixture paths and timings.

Bindings verified by recomputation:

- The staged validation capture hashes to `2b19ff97...100f`, the digest the
  record and its generated view both carry.
- Each of the six cplx overlay digests in that capture equals the staged blob,
  and the transport computed the same six in the reviewer's run.
- The writer's retained native log hashes to the recorded `df3ca54b...3923`.
- The three application repairs hash to the recorded digests both in the
  application's index and in its working tree.

The reviewer reran the three local gates after staging its own repair: clean.

Coverage limits stated rather than assumed: cplx declares shell lint as its
floor and no Python percentage is claimed; the application's gate measures its
own source scope, not these CI helpers.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 2)

The reviewer ran the union of the request validation set and the current
resolver set: the same four commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean, exit 0.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Run inside the
  project environment with the guard cleared. It archives both repositories'
  committed state, overlays the six current cplx step files and the three
  application repairs from their working trees, verifies their digests on the
  host, and runs the cumulative runner at step 6 in owned scratch space. Exit 0.
- `git diff --cached --check`, source `request`. Clean, exit 0.
- `bash .git/hooks/pre-commit`, source `request`. Clean, exit 0.

The transport's own ignored file was included in the validation-state path set,
so its digest is part of the before and after capture and did not change.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 2)

No drift in either direction.

The project floor still resolves to the single `project` command the request
carries. The `plan` addition and both `request` additions parse through the
current resolver contract, so the union equals both sets.

The new `request` addition, the installed pre-commit hook, is the addition
round 1 recommended. It moves the sensitive-content check from late reviewer
discovery into the declared set, which is where it belongs.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 2)

Every comparison came from the shared evidence launcher. The only change is the
reviewer's own attributable validation-row patch.

- Request-time index tree `7acde90db1e895042b4933fd8de95e4d24a75aca` equals the
  baseline captured at entry. The assessed tree is
  `6b5a21d81b88e646133778439e58162f87d290cd`, which differs by exactly the staged
  reviewer patch.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `e293c50bf3409247d15604fb8517eb74aeaab4db4eabdfdd617a5e437d5edde4`.
  No umbrella row was completed.
- Validation-state comparison over the ordered path set (the 15 staged step
  paths, the project command's file and the ignored transport): `acceptable:
  false`, naming only the validation plan and the index, with empty untracked
  and ignored lists. Both are the reviewer's patch to Step 6 validation rows,
  which reviewer mode permits. No validation command left a tracked side effect.
- The working tree matches its entry state apart from that staged patch: 15
  staged paths, plus the protocol's own unstaged transcript modification, which
  the reviewer leaves unstaged.
- No reviewer residue in either repository. The native run executed in owned
  host scratch space. The application checkout was read, never written.
- Ordering was correct: the index baseline, umbrella digest and validation-state
  baseline were captured and the manifest written before assessment. The
  pre-repair blob was recorded before the first edit, and the manifest was
  rewritten with the assessed tree and repair path afterwards.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 2)

Repairs made:

- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, polishing-only review metadata confined to Step 6 rows: driver size corrected from 927 to 943 lines, the stale "no Python file changed" replaced by the changed Python files and their sizes against the 650-line ceiling, `deployed_venv` added to the driver's function list, and a missing-work bullet added to commit the three application reader repairs

Paths staged:

- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md` (the attributable reviewer patch only, applied to the index with `git apply --cached`)

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 2)

`a.commit` is accurate, the reviewer amended nothing, and unlike round 1 it is
now executable: the installed hook accepts the staged set.

Independent `commit-plan-check.bat --format json`, run against the received
state and again after the reviewer's staged patch: `state: valid`,
`ready: true`, exit 0, no diagnostics, 15 staged paths in three ordered groups
matching the request.

- Group 1, `docs(relocation): define venv preservation`: the requirement,
  design, plan and umbrella.
- Group 2, `feat(tools): add pinned platform acceptance`: the delivery script,
  the installer, the driver, both runners and now the agent fixture. Its body
  names the 58 fixtures, the helper import check and the pytest double update,
  all of which the staged content bears out.
- Group 3, `docs(tools): record step 6 acceptance gaps`: the record, its view,
  both captures and the validation plan. The reviewer's missing-work bullet
  sits inside a group whose subject already says the step is incomplete, so
  neither subject nor body needs to change.

Ordering is least to most dependent and every staged path appears once. The
three application repairs are correctly absent: they are staged in the
application's own index and need its separate commit. Round 1's note on the
installer fix sitting under a `feat` subject still applies and is not blocking.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 2)

Unresolved findings: None.

Boundary-crossing work:

- The three application reader repairs live in the sibling application repository and need its own commit flow; the reviewer did not stage, commit or edit them, and recommends committing them before the cplx point 1 commit

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 2)

Human guidance:

The human explicitly requested the code review after confirming that only
point 1 of the handoff has been reached. Points 2 through 6 have not started.
The handoff orders committing the current Step 6 work before repackaging;
the validation plan must retain its No verdict while required evidence is
missing. The request does not authorize a commit or a declaration of completion.

Guidance response:

The guidance is followed on every point, and this time nothing in the staged
work stands in the way of the action it orders next.

- No completion is declared. The reviewer's own check reaches `No`
  independently.
- The `No` verdict is retained. The reviewer's validation-row patch corrects
  three stale facts and adds one missing-work bullet; it leaves the exact
  status sentence, the `Missing work for Step 6` section and the document-level
  `No` line in place.
- No commit is authorized by this answer, and the reviewer made none in either
  repository.

On point 1, committing the current Step 6 work before repackaging: round 1
found that commit blocked. It is no longer blocked. The installed hook accepts
the staged set, the commit plan is valid and ready, and the declared native
validation passes. One ordering matters: the cplx runner now imports the
application helpers under Python 3.9, which passes only with the three
application repairs. Committing those in the application repository first keeps
every committed state of the pair green; committing cplx first would leave a
committed cplx runner that fails against every committed application revision
until the application commit lands.

The disposition is changes-requested only because the completeness floor fails,
which is the `No` the guidance requires. Guidance cannot override that
disposition rule, and it does not need to: whether to commit point 1 now is the
human's decision, taken through the owning workflow.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 2)

No rework of the staged cplx work is needed for handoff point 1. The reviewer
found no current defect and fixed three stale validation rows itself. What
remains is ordering and the deliberately deferred acceptance work.

1. Commit the application repairs first. Commit the three staged application
reader repairs through the application repository's own commit flow before the
cplx point 1 commit. The staged blobs already equal the digests in the
validation capture, so the commit will carry exactly the bytes that were
validated. Once that commit exists, a later rework can record its identifier in
the capture; that is listed as missing work and does not block point 1.

2. Then commit point 1 through the owning workflow, if the human chooses to.
Treat this changes-requested answer as the completeness floor speaking, not as
a request to change the staged set: the six readiness results are identity
pass, completeness fail (by design), validation pass, attribution pass, no
unresolved findings, and `a.commit` pass.

3. Continue with handoff points 2 through 6 as the missing-work list states:
the single Step 5 repackage, the RHEL rerun until PA6 passes, the Debian build,
the exact-wheel D10 reading and the publication phase.

Done well this round, and worth keeping as practice: the fix went past the
symptom. Adding the helper import check to the runner means the next lint pass
that breaks Python 3.9 fails the runner rather than a reviewer's rerun, and
adding the installed hook to the declared validation set means the next private
name is refused at declaration time.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 2)

The disposition is changes-requested and the readiness floor is recorded as
incomplete, for one reason only: Step 6 is not complete, and the writer, the
human guidance and this review all agree it must not be declared complete yet.
Every other readiness result passes.

1. Identity. Passes. The request-time tree matched at entry, and the assessed
   tree differs by exactly the reviewer's staged patch.
2. Completeness. Fails by design: PA6, the repackage, the Debian cells, the
   exact-wheel D10 reading and publication are still ahead.
3. Validation and coverage. Passes. All four declared commands pass under the
   reviewer's own runs, including native Python 3.9.25, and no percentage is
   claimed where no gate measures it.
4. Staged attribution. Passes. One attributable reviewer patch, confined to
   Step 6 validation rows, which are review metadata rather than a substantive
   repair.
5. Unresolved findings. None. Both round 1 findings are fixed and verified.
6. `a.commit`. Passes, valid and ready, and now executable under the installed
   hook.

The rule ties a commit-ready recommendation to a complete implementation, and a
deliberate partial commit does not meet it. The reviewer does not bend that
rule, and states instead what it means here: there is nothing left for the
writer to rework before point 1. The human can commit point 1 through the owning
workflow, with the application repairs committed first.

Checked because it could have made this answer wrong: whether the new
uniqueness rule would have refused the real deployment. It would not have. The
pdfs archive holds one project directory, and the bound run's captures show a
single venv at audit time.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 2)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-2 -->

## Round 2 by human - Step 6 - escalation - attempt 2

- Recorded: 2026-09-18T20:59:05+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: escalation

## Partial Step 6 commit scope conflict (round 2)

The requestor has assessed the round 2 answer against the human handoff in
`.reviews/a.item7.handoff-prompt.md`, especially point 1: commit Step 6 as it
stands, retain the No completeness result, and do not delay the commit for the
Step 5 repackage. The human resumed this exchange knowing the reviewer found
nothing in the staged work that needs to change.

The reviewer reports no unresolved findings. Both round 1 defects are fixed,
and all four declared validation commands passed. The requestor accepts the
reviewer's staged validation-plan polishing. The reviewed a.commit remains
valid with three groups covering fifteen paths. No code rework is needed.

The changes-requested disposition rests solely on the intentionally incomplete
Step 6 acceptance work. The repackage, real RHEL rerun, Debian acceptance,
exact-wheel D10 and publication gates remain required and must retain their
truthful pending or failed status. They belong after the partial commit in the
human's ordered handoff. The separate application reader repairs also remain
staged and require their own repository commit workflow.

Automation stops because the registered code-review policy requires a
commit-ready convergence answer before durable Commit authorization, while
the reviewer applies full-step completeness to this deliberately partial
commit. Publishing the same work again would not resolve that conflict.
Retain the round 2 answer and staged work as authoritative evidence. No commit
has been made, no acceptance gate has been weakened, and no deferred execution
has been started. Human resolution must establish how this partial commit is
to pass the owning workflow without claiming Step 6 is complete.

<!-- review-entry-id: escalation-round-2-2 -->

## Round 2 by human - Step 6 - human-reclaim - attempt 2

- Recorded: 2026-09-18T22:35:54+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: human-reclaim

## Human authorization to reclaim the Step 6 exchange

The human instructed: "OK reclaim it and publish a new step 5 request then stop".

The old Step 6 round 2 found no defects in the staged work; its changes-requested
verdict reflected deliberately incomplete Step 6 acceptance. That partial work
has since been committed through 7aa660f8a2f182fc91790fd1182166ad8b662d5b.
This authorization does not declare Step 6 complete or alter its review verdict.

The next requested review concerns plan Step 5: handoff point 2, the completed
installer-only repackage and fresh archive checks. Preserve the historical failed
candidate and Step 6 results. Runtime acceptance of the replacement remains
pending. Publish the new Step 5 request and stop without waiting for an answer.

<!-- review-entry-id: human-reclaim-round-2-2 -->

## Round 2 by human - Step 6 - escalation - attempt 3

- Recorded: 2026-09-18T22:52:46+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: escalation

## Human resolution of Step 6 to Step 5 review scope

The human explicitly instructed: "OK resolve the context mismatch, then publish",
following "OK reclaim it and publish a new step 5 request then stop".

Archive the prior Step 6 answer and coordination as historical evidence and
start the next review round with implementation step 5, the same plan, umbrella,
identity and code-review policy. This is an authorized change of review scope.
It does not change the old changes-requested verdict or claim Step 6 complete.

The partial Step 6 work has been committed through
7aa660f8a2f182fc91790fd1182166ad8b662d5b. Handoff point 2 is now complete:
the corrected installer is repackaged with unchanged payloads, the new archive
passes AR1, AR2 and AR4, and old candidate evidence is preserved. Review that
Step 5 return. Replacement runtime acceptance and the rest of Step 6 remain
pending. Publish the Step 5 request and stop without waiting or committing.

<!-- review-entry-id: escalation-round-2-3 -->

## Round 3 by human - Step 6 - human-resolution

- Recorded: 2026-09-18T22:52:48+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: human-resolution

## Human resolution of Step 6 to Step 5 review scope (resolution record)

The human explicitly instructed: "OK resolve the context mismatch, then publish",
following "OK reclaim it and publish a new step 5 request then stop".

Archive the prior Step 6 answer and coordination as historical evidence and
start the next review round with implementation step 5, the same plan, umbrella,
identity and code-review policy. This is an authorized change of review scope.
It does not change the old changes-requested verdict or claim Step 6 complete.

The partial Step 6 work has been committed through
7aa660f8a2f182fc91790fd1182166ad8b662d5b. Handoff point 2 is now complete:
the corrected installer is repackaged with unchanged payloads, the new archive
passes AR1, AR2 and AR4, and old candidate evidence is preserved. Review that
Step 5 return. Replacement runtime acceptance and the rest of Step 6 remain
pending. Publish the Step 5 request and stop without waiting or committing.

<!-- review-entry-id: human-resolution-round-3 -->

## Round 3 by requestor - Step 5

- Recorded: 2026-09-18T22:55:08+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 5
- Outcome: request

### Review identity for step 5 tools-archive-rebuild (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 5
Review round: 3

### Code review evidence for step 5 tools-archive-rebuild (round 3)

request_index_tree: c6abb888c19f1eaf671904c5860e644d8a28e67f
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step5.repackage-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(tools): retain installer-only candidate
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-authority.txt
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-candidate.json
group 2: docs(tools): record review scope resolution
group 2 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools-archive-rebuild): record step 5 validation
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-authority.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-candidate.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
```

### Requestor assessment for step 5 tools-archive-rebuild (round 3)

Yes. Plan Step 5 is fully implemented, including the installer-only return
required by handoff point 2. Step 6 and the overall effort remain incomplete.

The replacement archive is tools.2026-09-18_220913.tar.gz, 545293468 bytes,
SHA-256 df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87.
Fresh native archive verification passed 539 cases and AR1, AR2 and AR4.
All 38070 archive members were compared: only tools/bin/install_pkg.sh changed
in content, type, mode or link target; timestamps were excluded. Protected live
trees and the source tools tree after the explicit installer overlay passed
preservation checks. There was no payload refresh, rebuild or promotion.

The record verifier checks all indexed capture digests, unchanged historical
verdicts, generated Markdown, installer and frozen-oracle digests, and absence
of inherited runtime passes. The repository lint passed all 58 tracked scripts;
Markdown checks and git diff checks passed during preparation. Existing native
cumulative Step 6 validation also covers Step 5; the review should rerun that
suite using the existing cumulative transport, not the acceptance mode.

No production code, architecture or execution path changes in this staged set.
No new runtime performance cost or test-coverage percentage is claimed. The
independent archive comparison and preservation checks establish unchanged
payloads; the original Python/SQLite build proof and authority remain retained.
See the updated Step 5 validation section for the complete implementation check.

### Implementation report for step 5 tools-archive-rebuild (round 3)

Repackaged the existing Step 5 namespace with the committed corrected installer,
after a fresh audit, using the existing pkg_tools.sh private-stage closure gate.
Both the cplx/bin and tools/bin installer copies were explicitly overlaid;
the closure gate does not copy the installer into tools/bin itself.

Retained the replacement archive and raw captures independently from the failed
original. The public candidate summary now describes the replacement. Added
byte-identical historical candidate and authority captures, and changed only
their capture paths in the historical record. The old RHEL PA6 failure remains.

The new record binds only AR1, AR2, AR4 and RA1 as passed. Required runtime and
publication results remain pending, consumers and runtime identities unbound.
Regenerated the Markdown view. Declaration authority was not renewed. Updated
the validation plan to retain Step 5 Yes, Step 6 No and overall No; remaining
work now calls for acceptance of the replacement, not another repackage.

Public evidence lives beside the plan in step5-candidate.json and
step5-authority.txt (both prefixed evidence.tools-archive-rebuild.), with
the corresponding step5-original captures preserving the prior candidate.
Private retained location and exact remote evidence paths are in the ignored
.reviews/a.item7.point2-result.md. Raw capture bundle SHA-256:
a8f80e6ce855b3cda7fd5fc137561a5eb87e4a33d25cf29e09fc07289815c0c1.

### Change summary for step 5 tools-archive-rebuild (round 3)

The staged set contains eight documentation/evidence paths. Root a.commit
has three groups, with the exact Step 5 validation commit last:

1. docs(tools): retain installer-only candidate
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-authority.txt
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-candidate.json
2. docs(tools): record review scope resolution
   - docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
3. docs(tools-archive-rebuild): record step 5 validation
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

The shared launcher appends this request to the transcript after capturing the
index. That publication append is protocol-owned evidence. No commit is being
performed. Separate application-repository staged repairs are outside this set.

### Human guidance and writer response for step 5 tools-archive-rebuild (round 3)

Human guidance:

#### Human resolution of Step 6 to Step 5 review scope for step 5 tools-archive-rebuild (round 3)

The human explicitly instructed: "OK resolve the context mismatch, then publish",
following "OK reclaim it and publish a new step 5 request then stop".

Archive the prior Step 6 answer and coordination as historical evidence and
start the next review round with implementation step 5, the same plan, umbrella,
identity and code-review policy. This is an authorized change of review scope.
It does not change the old changes-requested verdict or claim Step 6 complete.

The partial Step 6 work has been committed through
7aa660f8a2f182fc91790fd1182166ad8b662d5b. Handoff point 2 is now complete:
the corrected installer is repackaged with unchanged payloads, the new archive
passes AR1, AR2 and AR4, and old candidate evidence is preserved. Review that
Step 5 return. Replacement runtime acceptance and the rest of Step 6 remain
pending. Publish the Step 5 request and stop without waiting or committing.

Writer response:

The prior Step 6 round 2 found no remaining staged defects. Its changes-requested
verdict reflected the intentionally incomplete Step 6 acceptance. The partial
work was committed through 7aa660f8a2f182fc91790fd1182166ad8b662d5b under direct
human authority. No prior reviewer repair is reversed by this request.

The human subsequently authorized the Step 5 repackage, reclaim, explicit
resolution of the implementation-step context mismatch, and publication of a
Step 5 request. The shared archive operation retained the old answer and
coordination and opened this round with Step 5 context. This does not represent
Step 6 convergence or erase its failed/pending results.

Assess the exact Step 5 completion condition and handoff point 2 in
.reviews/a.item7.handoff-prompt.md. Incomplete RHEL runtime acceptance, Debian
acceptance, exact-wheel D10 and publication are subsequent Step 6 work. Do not
turn those pending cells into passes or require them to close this Step 5 review.
The user requires the requestor to stop after publication without waiting.

### Reviewer focus for step 5 tools-archive-rebuild (round 3)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-5-round-3 -->

## Round 3 by reviewer - Step 5

- Recorded: 2026-09-18T23:07:48+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: answer

### Assessed index identity for step 5 tools-archive-rebuild (exchange 1) (round 3)

Baseline index tree: c6abb888c19f1eaf671904c5860e644d8a28e67f

Assessed index tree: c6abb888c19f1eaf671904c5860e644d8a28e67f

### Implementation check for step 5 tools-archive-rebuild (exchange 1) (round 3)

Result:

Yes. Step 5 has been fully implemented.

The reviewer reaches the writer's verdict independently, by measurement rather
than from the record. Step 5's completion condition is an identified archive, a
conclusive Python and SQLite build result, AR1, AR2 and AR4, and resolved
declaration authority. The installer-only return satisfies all four for the
replacement, and Step 6 still owns its runtime acceptance.

- Identified archive. The retained replacement on the build host is 545293468
  bytes with SHA-256 `df7dff7d...be87`, and the original is still retained at
  `d8f205cc...c15c1`. Both match the record and the versioned summary, which is
  byte-identical to the host's retained copy.
- Unchanged payloads. The reviewer streamed both archives through the host's
  independent interpreter and compared every member's type, mode, link target
  and content digest: 38070 members in each, none added or removed, and exactly
  one changed, `tools/bin/install_pkg.sh`. Its old bytes are the pre-correction
  installer from `dab19c8` and its new bytes are the committed corrected
  installer `f915125e...2fca02`. Owners are identical. The build result is
  therefore inherited unchanged, which is what the plan's single repackage
  allows.
- AR1, AR2 and AR4. The retained raw bundle, digest `a8f80e6c...c0c1` as
  recorded, holds the check run: the script digest matches the local one, it
  verifies the new archive's digest before and after, extracts it, and runs
  the committed relocation harness (`bd977dd9...501e`) at step 4 with the
  corrected installer and the frozen oracle, whose host copy matches the
  versioned `f19f9cdc...c8db8`. Result: 539 cases, 0 failures, 85 residual
  programs walked and 0 selected, empty handoff, then `AR1`, `AR2` and `AR4`
  passed.
- Declaration authority. The closure gate staged and checked the same
  declaration, `63a955f8...9d5aa`. The declaration covers ELF closure and does
  not list the installer, so an installer change needs no renewal. The
  authority source and its retention merge are both ancestors of `7aa660f`,
  and neither the closure directory nor `pkg_tools.sh` has changed since the
  accepted Step 5 evidence.

The record is honest about what was not done. The original candidate's
captures are byte-identical to the previously committed ones under their new
historical names, its verdicts including the RHEL PA6 failure are unchanged,
and the replacement binds only AR1, AR2, AR4 and RA1, with every runtime,
environment, consumer and publication cell pending.

Architecture: no production code, execution path or layer changed; the
installer change was reviewed in Step 6 and only its packaging is new. No
violation or smell.

Performance: no runtime cost added. The member comparison is linear in archive
bytes and was a one-off verification.

Unit test coverage: no Python class or unit test changed, and no percentage is
claimed. No unit-tested class below 100% needs completing, and no top-level
symbol outside the coverage gate is unreferenced.

Feature integrity: the original candidate's evidence and failure are preserved,
the generated view reproduces from the record, and nothing is impaired.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 5 rows already match this assessment: the status sentence is
exactly `Yes. Step 5 has been fully implemented.`, no `Missing work for Step 5`
section remains, and the new installer-only bullet states the replacement's
identity, the member comparison, the 539 cases and the unrenewed authority,
each of which the reviewer confirmed independently. The document-level line
correctly stays `No, it is not implemented.`, and the Step 6 missing-work list
now targets the replacement rather than another repackage.

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 5 tools-archive-rebuild (exchange 1) (round 3)

The reviewer ran all four resolved commands. Three pass. The fourth passes as
declared but does not check this repository, and run correctly it reports one
new finding in a staged file.

- `bash src/utils/lint_shell.sh`, source `project`, through the project
  environment: `lint_shell: 58 tracked scripts`, `lint_shell: clean`, exit 0.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone
  after reading it: transport exit 0 in 105 seconds, native
  `validation exit=0 elapsed=76s` on the independent interpreter, no FAIL
  line, 58 acceptance cases, four helper imports, the packaging and relocation
  suites and 254 historical closure cases.
- The record verifier, source `request`, read first and read-only: both
  `PASS` lines, exit 0.
- `markdown-check.bat`, source `request`: exit 0, but on the wrong repository.
  The batch file changes into the llm-shared root before running, and the
  checker's `--root` defaults to the current directory, so it linted llm-shared.
  The project's own `markdown-check` task passes `--root` for the workspace. Run
  with `--root` set to cplx, it exits 1: every finding predates this round
  except `review.code.v0.27.0.tools-archive-rebuild.md:5778`, `MD024` and
  `LS003`, a duplicate heading inside the staged transcript group.

Beyond the declared set, the reviewer also ran `git diff --cached --check` and
the installed pre-commit hook: both clean.

Independent evidence, measured rather than read from the record:

- Both archives' sizes and digests on the build host, and a full member
  comparison of the two, with the changed member's old and new digests tied to
  `dab19c8` and to the committed installer.
- The retained raw bundle digest, the check script digest, the harness and
  installer digests the AR run used, the frozen oracle on the host, and the
  `539 cases, 0 failures` verdict with `AR1`, `AR2` and `AR4` passed.
- The closure gate's declaration digest in the packaging log, and the
  reachability of the authority source and retention merge from `7aa660f`.
- The original captures' blobs, identical to the previously committed ones,
  and the replacement summary, identical to the host's retained copy.

Coverage limits: cplx declares shell lint as its floor and no Python
percentage is claimed.

### Resolved validation set and sources for step 5 tools-archive-rebuild (exchange 1) (round 3)

The reviewer ran the union of the request validation set and the current
resolver set: the same four commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean, exit 0.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 0. It
  ships committed cplx HEAD `7aa660f` and the application's committed HEAD plus
  its three uncommitted reader repairs, verifying their digests on the host.
- The record verifier under llm-shared's Python, source `request`. Exit 0.
- `markdown-check.bat`, source `request`. Exit 0 as declared, over llm-shared;
  exit 1 with `--root` set to cplx, as reported above.

The transport and the record verifier are ignored files, so the reviewer
included both in the validation-state path set. Their digests did not change.

### Resolver drift and direction for step 5 tools-archive-rebuild (exchange 1) (round 3)

No drift in either direction.

The project floor still resolves to the single `project` command the request
carries, and the `plan` and `request` additions parse through the current
resolver contract, so the union equals both sets.

This round's request dropped the installed pre-commit hook and the
`git diff --cached --check` additions that Step 6 round 2 carried. Request
additions belong to their own request, so that is not drift, but the reviewer
ran both anyway and both are clean.

### Repository state around validation for step 5 tools-archive-rebuild (exchange 1) (round 3)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `c6abb888c19f1eaf671904c5860e644d8a28e67f` equals the
  baseline at entry and the live index after every run.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `e293c50bf3409247d15604fb8517eb74aeaab4db4eabdfdd617a5e437d5edde4`.
- Validation-state comparison over the 8 staged paths, the project command's
  file and the two ignored validation scripts: `acceptable: true` with empty
  tracked, untracked and ignored lists.
- The working tree matches its entry state: 8 staged paths, and the transcript
  also carries the protocol's unstaged append of this request, which the
  reviewer leaves unstaged.
- No reviewer residue in either repository. The native run and the archive
  comparison ran in host scratch space or read retained files; nothing
  retained was modified.
- Ordering was correct: the baselines and the manifest were written before
  assessment, and the manifest was rewritten with the post-assessment state.

### Repair inventory for step 5 tools-archive-rebuild (exchange 1) (round 3)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 5 tools-archive-rebuild (exchange 1) (round 3)

`a.commit` is mechanically accurate and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 8 staged paths in three
ordered groups matching the request.

- Group 1, `docs(tools): retain installer-only candidate`: the record, its view
  and the four captures. Its body's claims (replacement identity, preserved
  original captures, installer overlay without renewal, only AR1, AR2, AR4 and
  RA1 bound) are each borne out by the staged content and the host evidence.
- Group 2, `docs(tools): record review scope resolution`: the staged transcript
  entries. Accurate as a subject, but this group carries the duplicate heading
  in the findings, so its content needs the fix before it is committed.
- Group 3, `docs(tools-archive-rebuild): record step 5 validation`: the
  validation plan, last as the most dependent.

Ordering is least to most dependent and every staged path appears once. The
installed hook accepts the staged set. The fix to group 2 changes content only,
not membership or order, so `a.commit` stays accurate after it.

### Findings and boundaries for step 5 tools-archive-rebuild (exchange 1) (round 3)

Unresolved findings:

- The staged transcript repeats the heading `## Human resolution of Step 6 to Step 5 review scope` at lines 5748 and 5778, which the cplx Markdown gate reports as `MD024` and `LS003`: the same requestor-authored content, with an unqualified heading, was appended by both the escalation record (attempt 3) and the human-resolution record, and the shared heading rule makes a duplicate transcript heading a defect of the round that appended it.
- The declared `markdown-check.bat` validation did not check this repository: the batch file changes into the llm-shared root and the checker's `--root` defaults to the current directory, so its exit 0 covers llm-shared, and the request's statement that Markdown checks passed covers no staged file.

Boundary-crossing work:

- The cplx Markdown gate cannot pass as a whole: the repository has Markdown debt that predates this round (for example `CHANGELOG.md`, earlier review transcripts, and earlier entries of this transcript at lines 677 to 5620) with an empty `.markdownlint-baseline.json`, so baselining or cleaning that debt is separate work, and this round should be judged only on findings in its staged paths
- Step 6 was committed before the three application reader repairs, so the committed cplx runner currently fails against every committed application revision under the independent interpreter until the application commit lands; the declared transport passes only because it overlays those repairs, and committing them remains Step 6 missing work

### Human guidance response for step 5 tools-archive-rebuild (exchange 1) (round 3)

Human guidance:

#### Human resolution of Step 6 to Step 5 review scope for step 5 tools-archive-rebuild (exchange 1) (round 3)

The human explicitly instructed: "OK resolve the context mismatch, then publish",
following "OK reclaim it and publish a new step 5 request then stop".

Archive the prior Step 6 answer and coordination as historical evidence and
start the next review round with implementation step 5, the same plan, umbrella,
identity and code-review policy. This is an authorized change of review scope.
It does not change the old changes-requested verdict or claim Step 6 complete.

The partial Step 6 work has been committed through
7aa660f8a2f182fc91790fd1182166ad8b662d5b. Handoff point 2 is now complete:
the corrected installer is repackaged with unchanged payloads, the new archive
passes AR1, AR2 and AR4, and old candidate evidence is preserved. Review that
Step 5 return. Replacement runtime acceptance and the rest of Step 6 remain
pending. Publish the Step 5 request and stop without waiting or committing.

Guidance response:

The guidance is followed, and each of its factual claims was checked rather
than accepted.

- Scope. This answer assesses plan Step 5 and the installer-only return only.
  The replacement's runtime, Debian, D10 and publication cells were not
  required, not run and not turned into passes; the reviewer confirmed they
  are all pending in the record.
- "The corrected installer is repackaged with unchanged payloads." Confirmed by
  a full member comparison of both archives on the build host: one member
  changed, and it is the installer, going from the pre-correction bytes to the
  committed corrected bytes.
- "The new archive passes AR1, AR2 and AR4." Confirmed from the retained raw
  bundle: 539 cases, 0 failures, run against the new archive's verified digest
  with the committed harness and the frozen oracle.
- "Old candidate evidence is preserved." Confirmed: the original captures are
  byte-identical to the previously committed blobs, and the verdicts,
  including the RHEL PA6 failure, are unchanged.
- The old Step 6 verdict is not revisited, and nothing here claims Step 6
  complete. No commit is authorized by this answer, and none was made.

The disposition is changes-requested for two documentation and validation
findings in this round's own additions, not for anything about the Step 5
return itself, which the reviewer finds complete.

### Writer instructions for step 5 tools-archive-rebuild (exchange 1) (round 3)

The Step 5 return itself needs no rework: the archive, the comparison, the AR
checks, the authority and the record all hold under independent measurement.
Two small fixes remain, both in how this round is recorded and validated.

1. Make the transcript heading unique. In the staged transcript, the second
   `## Human resolution of Step 6 to Step 5 review scope` (line 5778, under the
   human-resolution record) repeats the one under the escalation record at line
   5748. Qualify the heading text of one of them with what distinguishes it, for
   example `## Human resolution of Step 6 to Step 5 review scope (resolution
   record)`, change nothing else in either entry, and restage. For later
   human-guidance content, qualify its headings before passing it to more than one
   operation, as the shared heading rule requires.

2. Declare the Markdown check against cplx. Replace the request addition with
   `markdown-check.bat --root <cplx root>`, which is what the project's own task
   runs. Because the repository carries older Markdown debt with an empty
   baseline, the run exits 1 regardless. Judge it on the staged paths: after
   fix 1, no finding should point into this round's staged content. Do not
   disable `MD024` or baseline the new finding away.

Both fixes change content only, so `a.commit` needs no amendment.

Worth keeping as practice, because it is what made this review fast to verify:
the original captures were preserved byte for byte under historical names, the
record verifier checks both candidates against the committed baseline, the
archive check verifies the candidate digest before and after the run, and the
raw bundle retained the exact scripts it ran.

### Decision rationale for step 5 tools-archive-rebuild (exchange 1) (round 3)

The disposition is changes-requested and the readiness floor is recorded as
incomplete. The substance of the Step 5 return passes every check the reviewer
could apply; the findings are about this round's record and one declared
validation, and both are cheap to fix.

1. Identity. Passes; the index tree matched at entry and after every run.
2. Completeness. Passes. Step 5 is complete for the replacement, and Step 6
   correctly keeps its runtime acceptance.
3. Validation and coverage. Does not pass. Three declared commands pass. The
   fourth was ineffective as declared, and run against cplx it reports a new
   finding in a staged path.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. Two: the duplicate transcript heading, and the
   Markdown check pointed at the wrong repository.
6. `a.commit`. Passes, valid and ready.

The two findings could look too small to block a commit, so the reason is
stated. The shared heading rule names a duplicate transcript heading as a
defect of the round that appended it and forbids working around it. And a
validation command that passes over the wrong repository is worse than one
that fails, because it looks like evidence. The request reported "Markdown
checks passed", and that report covered llm-shared, not cplx.

Checked because it could have made this answer wrong: whether "only the
installer changed" held at the byte level rather than by name, and whether
AR1, AR2 and AR4 ran against the new archive rather than the retained old one.
Both were confirmed from the host, the second by the check script's own digest
assertions before and after the run.

### Final reviewer decision for step 5 tools-archive-rebuild (exchange 1) (round 3)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-5-round-3 -->

## Round 4 by requestor - Step 5

- Recorded: 2026-09-18T23:23:23+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: request

### Review identity for step 5 tools-archive-rebuild (round 4)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 5
Review round: 4

### Code review evidence for step 5 tools-archive-rebuild (round 4)

request_index_tree: 3d0350c6bf8c77091339a691a2bec0f31e3bd2d3
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step5.repackage-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx (sources: request)
- git diff --cached --check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(tools): retain installer-only candidate
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-authority.txt
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-candidate.json
group 2: docs(tools): record review scope resolution
group 2 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools-archive-rebuild): record step 5 validation
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-authority.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-candidate.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
```

### Requestor assessment for step 5 tools-archive-rebuild (round 4)

Yes. Plan Step 5 is fully implemented, including the installer-only return
required by handoff point 2. Step 6 and the overall effort remain incomplete.

The replacement archive is tools.2026-09-18_220913.tar.gz, 545293468 bytes,
SHA-256 df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87.
Fresh native archive verification passed 539 cases and AR1, AR2 and AR4.
All 38070 archive members were compared: only tools/bin/install_pkg.sh changed
in content, type, mode or link target; timestamps were excluded. Protected live
trees and the source tools tree after the explicit installer overlay passed
preservation checks. There was no payload refresh, rebuild or promotion.

The record verifier checks all indexed capture digests, unchanged historical
verdicts, generated Markdown, installer and frozen-oracle digests, and absence
of inherited runtime passes. The repository lint passed all 58 tracked scripts;
Git diff checks passed. The earlier Markdown pass checked the wrong repository
and is withdrawn. The corrected command explicitly targets cplx; it reports
pre-existing Markdown debt, which is not a repository-wide pass. This round
fixes the duplicate heading and list formatting in the appended review prose,
and checks that no diagnostic intersects the current added lines. No lint rule
is disabled and no baseline is changed. Existing native
cumulative Step 6 validation also covers Step 5; the review should rerun that
suite using the existing cumulative transport, not the acceptance mode.

No production code, architecture or execution path changes in this staged set.
No new runtime performance cost or test-coverage percentage is claimed. The
independent archive comparison and preservation checks establish unchanged
payloads; the original Python/SQLite build proof and authority remain retained.
See the updated Step 5 validation section for the complete implementation check.

### Implementation report for step 5 tools-archive-rebuild (round 4)

Repackaged the existing Step 5 namespace with the committed corrected installer,
after a fresh audit, using the existing pkg_tools.sh private-stage closure gate.
Both the cplx/bin and tools/bin installer copies were explicitly overlaid;
the closure gate does not copy the installer into tools/bin itself.

Retained the replacement archive and raw captures independently from the failed
original. The public candidate summary now describes the replacement. Added
byte-identical historical candidate and authority captures, and changed only
their capture paths in the historical record. The old RHEL PA6 failure remains.

The new record binds only AR1, AR2, AR4 and RA1 as passed. Required runtime and
publication results remain pending, consumers and runtime identities unbound.
Regenerated the Markdown view. Declaration authority was not renewed. Updated
the validation plan to retain Step 5 Yes, Step 6 No and overall No; remaining
work now calls for acceptance of the replacement, not another repackage.

Public evidence lives beside the plan in step5-candidate.json and
step5-authority.txt (both prefixed evidence.tools-archive-rebuild.), with
the corresponding step5-original captures preserving the prior candidate.
Private retained location and exact remote evidence paths are in the ignored
.reviews/a.item7.point2-result.md. Raw capture bundle SHA-256:
a8f80e6ce855b3cda7fd5fc137561a5eb87e4a33d25cf29e09fc07289815c0c1.

### Change summary for step 5 tools-archive-rebuild (round 4)

The staged set contains eight documentation/evidence paths. Root a.commit
has three groups, with the exact Step 5 validation commit last:

1. docs(tools): retain installer-only candidate
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-authority.txt
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-candidate.json
2. docs(tools): record review scope resolution
   - docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
3. docs(tools-archive-rebuild): record step 5 validation
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

The shared launcher appends this request to the transcript after capturing the
index. That publication append is protocol-owned evidence. No commit is being
performed. Separate application-repository staged repairs are outside this set.

### Human guidance and writer response for step 5 tools-archive-rebuild (round 4)

Human guidance:

#### Human resolution of Step 6 to Step 5 review scope for step 5 tools-archive-rebuild (round 4)

The human explicitly instructed: "OK resolve the context mismatch, then publish",
following "OK reclaim it and publish a new step 5 request then stop".

Archive the prior Step 6 answer and coordination as historical evidence and
start the next review round with implementation step 5, the same plan, umbrella,
identity and code-review policy. This is an authorized change of review scope.
It does not change the old changes-requested verdict or claim Step 6 complete.

The partial Step 6 work has been committed through
7aa660f8a2f182fc91790fd1182166ad8b662d5b. Handoff point 2 is now complete:
the corrected installer is repackaged with unchanged payloads, the new archive
passes AR1, AR2 and AR4, and old candidate evidence is preserved. Review that
Step 5 return. Replacement runtime acceptance and the rest of Step 6 remain
pending. Publish the Step 5 request and stop without waiting or committing.

Writer response:

Accepted both round 3 findings. They concern this round's documentation and
validation, not a misunderstanding of handoff point 2 or missing Step 6 work.

Qualified the second duplicate transcript heading with "(resolution record)".
No other content in the escalation or human-resolution entry changed. The
reviewer's appended writer instructions also introduced MD032 findings: their
numbered-list continuation lines are now indented, with wording unchanged.
The live answer is retained unchanged until the core consumes it.

Corrected the Markdown validation addition to pass --root explicitly for cplx.
The previous claim that Markdown passed for cplx is withdrawn. The corrected
run reports older repository Markdown debt; the repair must leave no finding
on newly added lines, without disabling rules or changing the baseline.

The reviewer independently confirmed Step 5 complete: full archive-member
comparison, retained raw AR1/AR2/AR4 evidence, original captures and authority.
No archive or record rework is required. The reviewer staged no repair. Root
a.commit remains accurate with eight paths and three unchanged groups.

Step 6 remains incomplete, including application-reader commits, replacement
runtime acceptance, Debian, D10 and publication. These are not Step 5 defects.
The human's instruction to stop after publishing remains in effect; no commit
is authorized by this round.

### Reviewer focus for step 5 tools-archive-rebuild (round 4)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-5-round-4 -->

## Round 4 by reviewer - Step 5

- Recorded: 2026-09-18T23:29:47+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: answer

### Assessed index identity for step 5 tools-archive-rebuild (exchange 1) (round 4)

Baseline index tree: 3d0350c6bf8c77091339a691a2bec0f31e3bd2d3

Assessed index tree: 3d0350c6bf8c77091339a691a2bec0f31e3bd2d3

### Implementation check for step 5 tools-archive-rebuild (exchange 1) (round 4)

Result:

Yes. Step 5 has been fully implemented.

Nothing in the Step 5 substance changed since round 3: the index differs from
the round 3 tree only in the review transcript. The round 3 verification
therefore still stands, and this round re-ran every declared command against
the current index rather than relying on it. In round 3 the reviewer measured
the replacement archive's identity on the build host, compared all 38070
members of both archives (only `tools/bin/install_pkg.sh` changed, from the
pre-correction bytes to the committed corrected bytes), confirmed 539 cases
with AR1, AR2 and AR4 passed against the new archive, confirmed the unchanged
declaration and its reachable authority, and confirmed that the original
captures and verdicts are preserved.

Both round 3 findings are fixed, verified rather than accepted:

- The duplicate heading. The second entry's heading now reads
  `## Human resolution of Step 6 to Step 5 review scope (resolution record)`.
  The cplx Markdown gate reports no finding at or after the first staged
  transcript line, nor in the other staged Markdown files; all 37 remaining
  findings sit in content committed before this round.
- The Markdown command. It now passes `--root` for cplx, and the request
  withdraws the earlier pass claim.

The requestor also re-indented the continuation lines of the reviewer's own
round 3 writer instructions in the transcript, which the gate had reported as
list-spacing findings. The reviewer compared its rendered round 3 summary with
the staged copy: identical once whitespace is ignored, so only indentation
changed.

What blocks the staged set this round is new and sits outside Step 5's
substance: the installed sensitive-content hook refuses the staged transcript.
It is reported as a finding below and is fixable without touching any
Step 5 evidence.

Architecture, performance, unit test coverage and feature integrity are
unchanged from round 3: no production code, execution path or test changed, no
runtime cost was added, no percentage is claimed, and nothing is impaired.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, which is
unchanged since round 3. Its Step 5 status sentence is exactly
`Yes. Step 5 has been fully implemented.`, no `Missing work for Step 5` section
remains, and the document-level line correctly stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 5 tools-archive-rebuild (exchange 1) (round 4)

The reviewer ran all five resolved commands, plus the installed pre-commit hook.
The five declared commands behave as expected. The hook refuses the staged set.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean,
  exit 0.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  transport exit 0 in 106 seconds, native `validation exit=0 elapsed=83s` on
  the independent interpreter, no FAIL line, four helper imports and 58
  acceptance cases. The inputs are unchanged since round 3: cplx HEAD
  `7aa660f`, application HEAD `6b22c16f` and the same three verified overlays.
- The record verifier, source `request`: both `PASS` lines, exit 0.
- The Markdown gate with `--root` for cplx, source `request`: exit 1 with 37
  findings, none in this round's staged content. Every finding is at or before
  transcript line 5620 or in other files, all committed before this round; the
  staged transcript additions begin at line 5707.
- `git diff --cached --check`, source `request`: clean, exit 0.
- The installed pre-commit hook, run by the reviewer beyond the declared set:
  exit 1, `Commit blocked`, at staged transcript lines 5822 and 5823.

Also verified: the reviewer's round 3 summary and its staged transcript copy are
identical when whitespace is ignored, and both request-added commands work in a
sibling-relative form that needs no home path: the verifier passes, and the
Markdown gate reports the same 37 findings over cplx.

### Resolved validation set and sources for step 5 tools-archive-rebuild (exchange 1) (round 4)

The reviewer ran the union of the request validation set and the current
resolver set: the same five commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 0.
- The record verifier under llm-shared's Python, source `request`. Exit 0.
- The llm-shared Markdown gate with `--root` for cplx, source `request`. Exit 1
  on older debt only, with no finding in staged content.
- `git diff --cached --check`, source `request`. Clean.

The two ignored scripts stayed in the validation-state path set; their digests
did not change.

### Resolver drift and direction for step 5 tools-archive-rebuild (exchange 1) (round 4)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets.

The request still omits the installed pre-commit hook, which is the only check
that sees this round's blocking finding. It has now decided two rounds of this
effort; keeping it in the declared set moves that discovery to the requestor.

### Repository state around validation for step 5 tools-archive-rebuild (exchange 1) (round 4)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `3d0350c6bf8c77091339a691a2bec0f31e3bd2d3` equals the
  baseline at entry and the live index after every run. Against the round 3
  tree it differs only in the review transcript.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `e293c50bf3409247d15604fb8517eb74aeaab4db4eabdfdd617a5e437d5edde4`.
- Validation-state comparison over the 8 staged paths, the project command's
  file and the two ignored scripts: `acceptable: true` with empty lists.
- The working tree matches its entry state: 8 staged paths, and the transcript
  also carries the protocol's unstaged append of this request.
- No reviewer residue in either repository; the native run used host scratch
  space and the hook and gates are read-only.
- The baselines and manifest were written before assessment and the manifest
  was rewritten with the post-assessment state.

### Repair inventory for step 5 tools-archive-rebuild (exchange 1) (round 4)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 5 tools-archive-rebuild (exchange 1) (round 4)

`a.commit` is mechanically accurate and the reviewer amended nothing, but it is
not executable as staged.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 8 staged paths in the
same three ordered groups as round 3, which remain correct in membership,
order and subjects.

Not executable: the installed sensitive-content hook refuses group 2, the
review transcript, at two lines. `commit-plan-check` does not consult that
hook, which is why it reports ready. The fix is content-only, so `a.commit`
needs no amendment after it.

### Findings and boundaries for step 5 tools-archive-rebuild (exchange 1) (round 4)

Unresolved findings:

- The staged set cannot be committed: the installed sensitive-content pre-commit hook refuses the staged transcript at lines 5822 and 5823, where the round 3 request record lists the two request-added validation commands with absolute paths under the user's Windows home directory, which contain the private account name; the unstaged round 4 request record repeats the same two paths, so the next staging of the transcript would be refused as well.

Boundary-crossing work:

- The shared request renderer copies validation command strings verbatim into the versioned transcript, so any request addition declared with a home-directory path leaks it into history; rejecting or rewriting such paths at the request boundary would be an llm-shared change, not a cplx one
- The three application reader repairs are still uncommitted while cplx Step 6 is committed, so the committed pair fails the cplx runner under the independent interpreter until the application commit lands; this remains Step 6 missing work

### Human guidance response for step 5 tools-archive-rebuild (exchange 1) (round 4)

Human guidance:

#### Human resolution of Step 6 to Step 5 review scope for step 5 tools-archive-rebuild (exchange 1) (round 4)

The human explicitly instructed: "OK resolve the context mismatch, then publish",
following "OK reclaim it and publish a new step 5 request then stop".

Archive the prior Step 6 answer and coordination as historical evidence and
start the next review round with implementation step 5, the same plan, umbrella,
identity and code-review policy. This is an authorized change of review scope.
It does not change the old changes-requested verdict or claim Step 6 complete.

The partial Step 6 work has been committed through
7aa660f8a2f182fc91790fd1182166ad8b662d5b. Handoff point 2 is now complete:
the corrected installer is repackaged with unchanged payloads, the new archive
passes AR1, AR2 and AR4, and old candidate evidence is preserved. Review that
Step 5 return. Replacement runtime acceptance and the rest of Step 6 remain
pending. Publish the Step 5 request and stop without waiting or committing.

Guidance response:

The guidance is followed, as in round 3, and its claims about the Step 5 return
still hold: round 3 measured them on the build host, and nothing in the Step 5
evidence has changed since.

- The review stays on plan Step 5. The replacement's runtime, Debian, D10 and
  publication cells were not required and remain pending in the record.
- The old Step 6 verdict is not revisited, and nothing here claims Step 6
  complete.
- No commit is authorized by this answer, and none was made.

The reviewer agrees that the Step 5 return is complete and needs no archive or
record rework. The one remaining finding is in the review transcript's recorded
command strings, not in the handoff point 2 work.

### Writer instructions for step 5 tools-archive-rebuild (exchange 1) (round 4)

The Step 5 work needs no rework. One fix makes the staged set committable, and
two changes to the request keep the problem from coming back.

__Remove the home paths from the transcript__ In the staged transcript, lines
5822 and 5823 of the round 3 request record start with an absolute path under
the user's home directory. Replace that prefix with the sibling-relative
`../llm-shared/` and change nothing else on those lines. Make the same change to
the two matching lines of the round 4 request record before staging it. Then
run `bash .git/hooks/pre-commit` against the index and require it clean. The
hook is the gate the commit will actually meet, and `commit-plan-check` does not
consult it.

__Declare the request commands without home paths.__ Both work from the cplx
root in sibling-relative form, as the reviewer confirmed:
`../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step5.repackage-verify-record.py`
passes, and `../llm-shared/markdown-check.bat --root ../cplx` reports the same
37 findings over cplx. The Markdown batch file changes into the llm-shared root
before it runs, so `--root` is resolved from there, which is why `../cplx`
reaches this repository.

__Keep the hook in the declared set.__ Add `bash .git/hooks/pre-commit` back as
a request addition. It is the only check that sees this class of defect, and it
has decided two rounds of this effort.

The fix is content-only, so `a.commit` needs no amendment.

Both round 3 fixes were done well: one qualified heading and indentation-only
repairs, each confined to exactly what the gate reported, with no rule
disabled and no baseline changed.

### Decision rationale for step 5 tools-archive-rebuild (exchange 1) (round 4)

The disposition is changes-requested and the readiness floor is recorded as
incomplete, for one reason: the staged set cannot be committed.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Passes; Step 5 is complete for the replacement.
3. Validation and coverage. Passes; all five declared commands behave as
   expected, and the Markdown gate shows no finding in staged content.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. One: the hook refuses two transcript lines.
6. `a.commit`. Valid and correctly grouped, but not executable while the hook
   refuses group 2.

This finding is not a style point. The hook blocks the commit, so a
commit-ready answer would hand the human a commit that fails at the gate. It
also concerns what the hook exists to protect: the private account name would
otherwise enter versioned history through the transcript.

The cause is instructive. Round 3 fixed the Markdown command by making its
path absolute, and the protocol copies declared commands verbatim into the
transcript. The same round dropped the hook from the declared set, so nothing
the requestor ran could see the result. Sibling-relative paths remove the
cause, and restoring the hook restores the check.

### Final reviewer decision for step 5 tools-archive-rebuild (exchange 1) (round 4)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-5-round-4 -->

## Round 5 by requestor - Step 5

- Recorded: 2026-09-19T00:05:08+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: request

### Review identity for step 5 tools-archive-rebuild (round 5)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 5
Review round: 5

### Code review evidence for step 5 tools-archive-rebuild (round 5)

request_index_tree: c8e65b0bafebed9391730b59eba4ff39bdedd196
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step5.repackage-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(tools): retain installer-only candidate
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-authority.txt
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-candidate.json
group 2: docs(tools): record review scope resolution
group 2 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools-archive-rebuild): record step 5 validation
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-authority.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-candidate.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
```

### Requestor assessment for step 5 tools-archive-rebuild (round 5)

Yes. Plan Step 5 is fully implemented, including the installer-only return
required by handoff point 2. Step 6 and the overall effort remain incomplete.

The replacement archive is tools.2026-09-18_220913.tar.gz, 545293468 bytes,
SHA-256 df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87.
Fresh native archive verification passed 539 cases and AR1, AR2 and AR4.
All 38070 archive members were compared: only tools/bin/install_pkg.sh changed
in content, type, mode or link target; timestamps were excluded. Protected live
trees and the source tools tree after the explicit installer overlay passed
preservation checks. There was no payload refresh, rebuild or promotion.

The record verifier checks all indexed capture digests, unchanged historical
verdicts, generated Markdown, installer and frozen-oracle digests, and absence
of inherited runtime passes. The repository lint passed all 58 tracked scripts;
Git diff checks passed. The earlier Markdown pass checked the wrong repository
and is withdrawn. The corrected command explicitly targets cplx; it reports
pre-existing Markdown debt, which is not a repository-wide pass. This round
fixes the duplicate heading and list formatting in the appended review prose,
and checks that no diagnostic intersects the current added lines. No lint rule
is disabled and no baseline is changed. Existing native
cumulative Step 6 validation also covers Step 5; the review should rerun that
suite using the existing cumulative transport, not the acceptance mode.

No production code, architecture or execution path changes in this staged set.
No new runtime performance cost or test-coverage percentage is claimed. The
independent archive comparison and preservation checks establish unchanged
payloads; the original Python/SQLite build proof and authority remain retained.
See the updated Step 5 validation section for the complete implementation check.

### Implementation report for step 5 tools-archive-rebuild (round 5)

Repackaged the existing Step 5 namespace with the committed corrected installer,
after a fresh audit, using the existing pkg_tools.sh private-stage closure gate.
Both the cplx/bin and tools/bin installer copies were explicitly overlaid;
the closure gate does not copy the installer into tools/bin itself.

Retained the replacement archive and raw captures independently from the failed
original. The public candidate summary now describes the replacement. Added
byte-identical historical candidate and authority captures, and changed only
their capture paths in the historical record. The old RHEL PA6 failure remains.

The new record binds only AR1, AR2, AR4 and RA1 as passed. Required runtime and
publication results remain pending, consumers and runtime identities unbound.
Regenerated the Markdown view. Declaration authority was not renewed. Updated
the validation plan to retain Step 5 Yes, Step 6 No and overall No; remaining
work now calls for acceptance of the replacement, not another repackage.

Public evidence lives beside the plan in step5-candidate.json and
step5-authority.txt (both prefixed evidence.tools-archive-rebuild.), with
the corresponding step5-original captures preserving the prior candidate.
Private retained location and exact remote evidence paths are in the ignored
.reviews/a.item7.point2-result.md. Raw capture bundle SHA-256:
a8f80e6ce855b3cda7fd5fc137561a5eb87e4a33d25cf29e09fc07289815c0c1.

### Change summary for step 5 tools-archive-rebuild (round 5)

The staged set contains eight documentation/evidence paths. Root a.commit
has three groups, with the exact Step 5 validation commit last:

1. docs(tools): retain installer-only candidate
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-authority.txt
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-candidate.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-authority.txt
   - docs/v0.27.0/evidence.tools-archive-rebuild.step5-original-candidate.json
2. docs(tools): record review scope resolution
   - docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
3. docs(tools-archive-rebuild): record step 5 validation
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

The shared launcher appends this request to the transcript after capturing the
index. That publication append is protocol-owned evidence. No commit is being
performed. Separate application-repository staged repairs are outside this set.

### Human guidance and writer response for step 5 tools-archive-rebuild (round 5)

Human guidance:

#### Human resolution of Step 6 to Step 5 review scope for step 5 tools-archive-rebuild (round 5)

The human explicitly instructed: "OK resolve the context mismatch, then publish",
following "OK reclaim it and publish a new step 5 request then stop".

Archive the prior Step 6 answer and coordination as historical evidence and
start the next review round with implementation step 5, the same plan, umbrella,
identity and code-review policy. This is an authorized change of review scope.
It does not change the old changes-requested verdict or claim Step 6 complete.

The partial Step 6 work has been committed through
7aa660f8a2f182fc91790fd1182166ad8b662d5b. Handoff point 2 is now complete:
the corrected installer is repackaged with unchanged payloads, the new archive
passes AR1, AR2 and AR4, and old candidate evidence is preserved. Review that
Step 5 return. Replacement runtime acceptance and the rest of Step 6 remain
pending. Publish the Step 5 request and stop without waiting or committing.

Writer response:

Accepted the round 4 finding. It concerns recorded command paths, not the
completed Step 5 repackage or deferred Step 6 acceptance.

Replaced the five private home-directory prefixes in the round 3 and round 4
transcript command lines with sibling-relative paths, including the Markdown
root argument. No evidence, verdict or other wording changed. No reviewer
repair was staged. The Step 5 evidence remains unchanged.

The replacement request declares both commands using sibling-relative paths.
The Markdown root remains explicitly ../cplx, resolved from the launcher's
llm-shared working directory. The installed pre-commit hook is restored as a
request addition. Its success is required alongside the record verifier,
staged diff check and commit-plan validation. The full Markdown gate retains
its older findings, with none on newly added content; no rule or baseline is
changed. Root a.commit still covers the same eight paths in three groups.

Step 6 remains incomplete. Stop after request publication as instructed;
no commit is authorized by the review answer.

### Reviewer focus for step 5 tools-archive-rebuild (round 5)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-5-round-5 -->

## Round 5 by reviewer - Step 5

- Recorded: 2026-09-19T00:10:42+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: answer

### Assessed index identity for step 5 tools-archive-rebuild (exchange 1) (round 5)

Baseline index tree: c8e65b0bafebed9391730b59eba4ff39bdedd196

Assessed index tree: c8e65b0bafebed9391730b59eba4ff39bdedd196

### Implementation check for step 5 tools-archive-rebuild (exchange 1) (round 5)

Result:

Yes. Step 5 has been fully implemented.

The Step 5 evidence is unchanged since round 3, when the reviewer measured it
on the build host: the replacement archive's identity, a full comparison of
all 38070 members of both archives with only `tools/bin/install_pkg.sh`
changed (pre-correction bytes to the committed corrected bytes), 539 cases
with AR1, AR2 and AR4 passed against the new archive, the unchanged
declaration with its reachable authority, and the preserved original captures
and verdicts. Since then the index has changed only in the review transcript,
and every declared command was re-run against the current index this round.

The round 4 finding is fixed, verified rather than accepted:

- The five home-directory prefixes in the round 3 and round 4 request records
  are now sibling-relative. Apart from those prefixes and the appended protocol
  records, the transcript is unchanged against the round 4 tree, and the
  reviewer's round 4 answer copy is byte-identical to what it rendered.
- No private identifier appears anywhere in the staged transcript additions.
- The installed hook passes and is back in the declared set, and both
  request-added commands are declared in their sibling-relative form.

Architecture, performance, unit test coverage and feature integrity are
unchanged from round 3: no production code, execution path or test changed, no
runtime cost was added, no percentage is claimed, and nothing is impaired.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, which is
unchanged since round 3. Its Step 5 status sentence is exactly
`Yes. Step 5 has been fully implemented.`, no `Missing work for Step 5` section
remains, and the document-level line correctly stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 5 tools-archive-rebuild (exchange 1) (round 5)

The reviewer ran all six resolved commands. All six behave as expected.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean,
  exit 0.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  transport exit 0 in 106 seconds, native `validation exit=0 elapsed=80s` on
  the independent interpreter, no FAIL line, four helper imports and 58
  acceptance cases. The inputs are unchanged: cplx HEAD `7aa660f`, application
  HEAD `6b22c16f` and the same three verified overlays.
- The record verifier through the sibling-relative interpreter path, source
  `request`: both `PASS` lines, exit 0.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 with the
  same 37 findings as round 4, all in content committed before this round,
  none in the staged transcript additions or in any other staged file.
- `git diff --cached --check`, source `request`: clean, exit 0.
- `bash .git/hooks/pre-commit`, source `request`: exit 0.

Also verified: the round 4 answer copy in the staged transcript is
byte-identical to what the reviewer rendered, and a scan of the staged
transcript additions finds no private identifier.

### Resolved validation set and sources for step 5 tools-archive-rebuild (exchange 1) (round 5)

The reviewer ran the union of the request validation set and the current
resolver set: the same six commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 0.
- The record verifier under llm-shared's Python, source `request`. Exit 0.
- The llm-shared Markdown gate with `--root ../cplx`, source `request`. Exit 1
  on older debt only, with no finding in staged content.
- `git diff --cached --check`, source `request`. Clean.
- `bash .git/hooks/pre-commit`, source `request`. Clean.

The two ignored scripts stayed in the validation-state path set; their digests
did not change.

### Resolver drift and direction for step 5 tools-archive-rebuild (exchange 1) (round 5)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets. The request now carries the installed hook again,
and both llm-shared commands in a form that records no home path.

### Repository state around validation for step 5 tools-archive-rebuild (exchange 1) (round 5)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `c8e65b0bafebed9391730b59eba4ff39bdedd196` equals the
  baseline at entry and the live index after every run. Against the round 4
  tree it differs only in the review transcript.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `e293c50bf3409247d15604fb8517eb74aeaab4db4eabdfdd617a5e437d5edde4`.
- Validation-state comparison over the 8 staged paths, the project command's
  file and the two ignored scripts: `acceptable: true` with empty lists.
- The working tree matches its entry state: 8 staged paths, and the transcript
  also carries the protocol's unstaged append of this request.
- No reviewer residue in either repository.
- The baselines and manifest were written before assessment and the manifest
  was rewritten with the post-assessment state.

### Repair inventory for step 5 tools-archive-rebuild (exchange 1) (round 5)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 5 tools-archive-rebuild (exchange 1) (round 5)

`a.commit` is accurate and executable, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 8 staged paths in the
same three ordered groups as rounds 3 and 4.

- Group 1, `docs(tools): retain installer-only candidate`: the record, its view
  and the four captures.
- Group 2, `docs(tools): record review scope resolution`: the review
  transcript, now accepted by the installed hook.
- Group 3, `docs(tools-archive-rebuild): record step 5 validation`: the
  validation plan, last as the most dependent.

Membership, order and subjects match the staged work. The transcript will also
gain this answer's protocol append after publication; that append is protocol
evidence for the owning workflow to stage, not a reason to change the groups.

### Findings and boundaries for step 5 tools-archive-rebuild (exchange 1) (round 5)

Unresolved findings: None.

Boundary-crossing work: None.

### Human guidance response for step 5 tools-archive-rebuild (exchange 1) (round 5)

Human guidance:

#### Human resolution of Step 6 to Step 5 review scope for step 5 tools-archive-rebuild (exchange 1) (round 5)

The human explicitly instructed: "OK resolve the context mismatch, then publish",
following "OK reclaim it and publish a new step 5 request then stop".

Archive the prior Step 6 answer and coordination as historical evidence and
start the next review round with implementation step 5, the same plan, umbrella,
identity and code-review policy. This is an authorized change of review scope.
It does not change the old changes-requested verdict or claim Step 6 complete.

The partial Step 6 work has been committed through
7aa660f8a2f182fc91790fd1182166ad8b662d5b. Handoff point 2 is now complete:
the corrected installer is repackaged with unchanged payloads, the new archive
passes AR1, AR2 and AR4, and old candidate evidence is preserved. Review that
Step 5 return. Replacement runtime acceptance and the rest of Step 6 remain
pending. Publish the Step 5 request and stop without waiting or committing.

Guidance response:

The guidance is followed, and its claims about the Step 5 return hold: round 3
measured them on the build host, and nothing in the Step 5 evidence has
changed since.

- The review stays on plan Step 5. The replacement's runtime, Debian, D10 and
  publication cells were not required and remain pending in the record.
- The old Step 6 verdict is not revisited, and nothing here claims Step 6
  complete.
- This commit-ready recommendation is advisory. It does not authorize a
  commit, and the reviewer made none. The commit choice belongs to the human
  at the convergence gate.

### Writer instructions for step 5 tools-archive-rebuild (exchange 1) (round 5)

No further changes are needed for this Step 5 return. If the human selects
Commit, stage this answer's protocol append to the transcript with group 2
before committing, and run the installed hook once more against the final
index, since the append lands after this review's evidence.

Next, per the handoff: commit the three application reader repairs through the
application repository's own flow, then run the RHEL acceptance over the
replacement archive (handoff point 3).

### Decision rationale for step 5 tools-archive-rebuild (exchange 1) (round 5)

The recommendation is commit-ready: all six readiness results pass, and this
round made no repair.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Passes; Step 5 is complete for the replacement, and Step 6
   correctly keeps its runtime acceptance.
3. Validation and coverage. Passes; all six declared commands behave as
   expected, and no coverage percentage is claimed where no gate measures it.
4. Staged attribution. Passes; nothing was repaired or staged by the reviewer.
5. Unresolved findings. None; the round 3 and round 4 findings are fixed and
   verified.
6. `a.commit`. Passes; valid, ready and accepted by the installed hook.

The substance was settled in round 3. Rounds 4 and 5 were about the record:
a duplicate heading, a Markdown gate pointed at the wrong repository, and home
paths the protocol copied into history. Each fix was confined to what the
gates reported. The declared set now includes the hook, so the checks the
requestor runs are the checks the commit will meet.

Two notes that are not work for this step. The three application reader
repairs are still uncommitted while cplx Step 6 is committed, so the committed
pair fails the cplx runner under the independent interpreter until the
application commit lands; that is already on the Step 6 missing-work list. And
the shared request renderer copies command strings verbatim into the versioned
transcript, so rejecting home-directory paths at the request boundary would be
a worthwhile llm-shared change.

### Final reviewer decision for step 5 tools-archive-rebuild (exchange 1) (round 5)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-5-round-5 -->

## Round 5 by human - Step 5 - human-confirmation

- Recorded: 2026-09-19T00:25:15+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 5
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-5 -->

## Round 1 by requestor - Step 6 (exchange 2)

- Recorded: 2026-09-19T12:54:22+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (exchange 2) (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 1

### Code review evidence for step 6 tools-archive-rebuild (exchange 2) (round 1)

request_index_tree: 175a36c4936e7c717a6a0860daf19dc1088508fc
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.point3-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.point3-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.point3-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(tools): record replacement RHEL acceptance
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-original-rhel.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3.txt
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 2: docs(tools): record RHEL checkpoint gaps
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-original-rhel.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
```

### Requestor assessment for step 6 tools-archive-rebuild (exchange 2) (round 1)

No. Step 6 has NOT been fully implemented.

This review covers the user-authorized handoff point 3 evidence checkpoint,
not completion of Step 6. The replacement acceptance attempt is finished and
retained; its PA6 stop condition has been honored. No production code changes
are staged. The validation plan records concrete outstanding work.

The native RHEL run took 3936 seconds: eight required passes, one required
failure (PA3:rhel-build, missing probes capture), one required inconclusive
cell (PA6:rhel, unmet audit prerequisites), and an additional redeployment
pass. No wheel import or offline lock-audit success is claimed. Raw evidence
was retained, downloaded and verified; every indexed raw capture matches its
digest and size. The monitor's post-retention display SyntaxError is recorded
separately and did not affect the driver result.

Native cumulative --step 6 passed in 79 seconds. Project shell lint passed
for 58 tracked scripts. The point3 record verifier checks exact pins and cell
states, historical capture bytes, capture hashes, Step 5 snapshot preservation,
pending obligations and generated Markdown. git diff --cached --check,
the sensitive-content hook and commit-plan readiness all pass. Full Markdown
checking reports 39 existing findings; none intersects added lines. No rule
or baseline was disabled. No Python coverage percentage is claimed: this
repository's gate is shell lint and native fixtures, not a pytest project.

There is no new production type, layer dependency or performance path. No
existing feature is changed. Evidence records failures without weakening any
gate, preserving the original failed candidate alongside the replacement.

Do not repeat the 65-minute acceptance deployment as review validation. The
separate cumulative fixture command and retained evidence are sufficient to
review this checkpoint. Points 4-6 remain outside the user's current scope.

### Implementation report for step 6 tools-archive-rebuild (exchange 2) (round 1)

The replacement tools archive was passed to the existing RHEL acceptance
driver with verified archive and bundle pins. The run's JSON and raw captures
were retained under its exact identity. The canonical RHEL evidence file now
contains the replacement run; the former file is preserved byte-for-byte as
step6-original-rhel.json and the historical candidate's capture path follows it.

The release record binds ten required RHEL cells to the new measured states,
captures and environment, preserving Step 5 results and every nonexecuted
obligation. The additional PA1:rhel-redeploy measurement remains visible in
the raw result (it is not a separate release-record schema cell). The
acceptance view is regenerated from the record. A provenance capture states
source versus fixture revisions, unchanged-input reasoning, diagnostics,
validation and limitations. The Step 6 check remains No, with precise PA3
and PA6 missing-work entries and later work preserved.

### Change summary for step 6 tools-archive-rebuild (exchange 2) (round 1)

Root a.commit is formatted and mechanically ready with two groups:

1. docs(tools): record replacement RHEL acceptance
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-original-rhel.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3.txt
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
2. docs(tools): record RHEL checkpoint gaps
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

These six paths are the exact staged implementation checkpoint. Protocol
publication appends its own versioned transcript as normal. No commit is
authorized by this request.

### Human guidance and writer response for step 6 tools-archive-rebuild (exchange 2) (round 1)

Human guidance:

The user authorized only point 3 of `.reviews/a.item7.handoff-prompt.md`:
rerun RHEL acceptance against the installer-only replacement archive, retain
the results and report the actual PA6 verdict. Point 3 belongs to plan Step 6
but does not complete Step 6. Read that handoff before judging the scope.

Points 4 through 6, the Debian candidate build, application commits and push,
wheel-bound D10, and remaining publication obligations are outside this
checkpoint. Step 6 must remain No and those obligations must remain pending.
Do not request completion of those later points as a repair to this evidence
checkpoint, and do not relabel partial qualification as Step 6 completion.

Review the staged evidence, preservation of original-candidate history, exact
replacement pins, truthful cell states, generated view, validation-plan update,
and commit grouping. A failed or inconclusive measured cell is evidence to
retain, not permission to weaken its gate. The handoff explicitly says to stop
and report raw diagnostics if PA6 does not pass.

Do not launch acceptance mode during review: it is a costly real deployment
run already retained under one exact run identity. The cumulative fixture mode
is separate and safe to run as the declared validation command.

The user requests publication followed by an immediate stop, without waiting
for the review answer. No commit, upload, application push or later handoff
point is authorized by this review request.

Writer response:

This is a fresh review of handoff point 3 after the committed Step 5 round 5
checkpoint. Earlier Step 6 and Step 5 repairs are already in the source
baseline; none has been reversed. There is no reviewer answer to consume in
this exchange yet and no disagreement is being recorded.

The user specifically asks for the handoff context to govern scope. Step 6
remaining No is expected: this checkpoint stops at PA6's unsuccessful result
as the handoff directs. Review the accuracy and completeness of this evidence
checkpoint without treating later Debian, D10 or publication work as omitted
implementation in the currently authorized task. The user explicitly requests
publishing this request and stopping without waiting for an answer.

### Reviewer focus for step 6 tools-archive-rebuild (exchange 2) (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-1-exchange-2 -->

## Round 1 by reviewer - Step 6 (exchange 2)

- Recorded: 2026-09-19T13:05:10+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 2) (round 1)

Baseline index tree: 175a36c4936e7c717a6a0860daf19dc1088508fc

Assessed index tree: 08649acc40df39a22a261b1e0b78969be44f8d7b

### Implementation check for step 6 tools-archive-rebuild (exchange 2) (round 1)

Result:

No. Step 6 has NOT been fully implemented.

The reviewer reaches the writer's verdict independently. This round reviews the
handoff point 3 evidence checkpoint: the replacement archive's RHEL run,
retained and recorded, stopping where PA6 did not pass. The checkpoint itself
is accurate. Its central result needs a decision before any rerun.

What the staged evidence gets right, verified rather than accepted:

- Pins and identity. The recorded results file is byte-identical to the
  `results.json` retained on the build host (`56fd511c...41d5`), and all seven
  files in the retention list verify there. The run is pinned to the
  replacement archive `df7dff7d...be87`, the bundle `cbdbe129...5231` and the
  transferred fixture revision, which the provenance capture correctly
  distinguishes from source commit `b3387f9`.
- Preservation. The original candidate's results are byte-identical to the
  previously committed capture under their historical name, and the original
  candidate changes only that capture path. Its PA6 failure stays.
- Truthful states. Eight required cells pass, PA3:rhel-build fails and PA6:rhel
  is inconclusive, as measured. PA3's failure is the driver reading a build
  summary with no `probes` stages, which the capture calls a capture-contract
  failure rather than a build regression; that is accurate, and the cell was
  not relabeled.
- The record verifier and generated view reproduce, and the Step 5 snapshots
  for AR1, AR2, AR4 and RA1 are unchanged.

What PA6 actually measured: nothing. The driver took its prerequisite branch
and ran neither the offline lock audit nor the wheel import. The writer did not
isolate which prerequisite failed. The reviewer did, on the run's retained
prefix, which is still on the build host:

- By the end of the forced redeployment the project holds two venvs. The
  shipped `python_3.13.9_my-project` carries the heavy wheels (173
  site-packages entries, pymupdf and pikepdf present) and `uv`. A second
  `python_3.13.15_my-project` is empty (pip only, no `uv`), named after the
  candidate toolchain, and its `pyvenv.cfg` records creation with
  `python3.13_bin -m venv` at 12:33:35, inside the redeployment window
  (12:26:46 to 12:33:40). The PA6 cell was written at 12:33:40, after it.
- Discovery therefore saw two venvs and correctly refused to choose.
- The operator `senv` probe resolved `python` from the empty venv, and the
  newest-venv rule of `deploy_pkgs.sh` selects the empty venv on the final
  prefix.

This changes what PA6 means for this item. Its RHEL row requires the check
over the venv the deployment provides, shipped inside the pdfs archive until
item 8. The pdfs archive used here was built under 3.13.9, so its shipped venv
is named for 3.13.9. With the 3.13.15 toolchain, the deployment creates and
uses an empty 3.13.15 venv instead. The installer fix may well preserve the
shipped wheels' search path, but the environment the operator gets would not
import pymupdf at all. Which venv counts, and which pdfs archive produces it, is
a decision for the human, not a discovery fix.

This also corrects the reviewer's own earlier answer. In exchange 1 round 2 the
reviewer stated that only the shipped venv existed at audit time and that the
uniqueness rule would select the venv the old pattern selected. That was
inferred from the deployment logs never naming a 3.13.15 venv; the file system
was not checked. The file system shows the second venv existed at audit time.
The old pattern's lexical `sort | tail -n 1` would also have picked the
3.13.9 venv with both present, which is why the original run's PA6 measured
the shipped venv and failed on its search path.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 2) (round 1)

- Decide which venv the deployment provides for PA6 under the shipped-venv
  arrangement; the reviewer recommends a pdfs archive whose shipped venv is
  built with the candidate toolchain. Then rerun PA6 over that venv without
  relaxing discovery, and bind conclusive lock and import evidence.
- Supply candidate-bound PA3 build-role evidence the reader accepts, with
  explicit unchanged-payload evidence if the original probes are reused.
- Commit the three application reader repairs.
- Run the Debian candidate build, the exact-wheel D10 reading and the
  remaining pre-publication obligations, which the guidance keeps out of this
  checkpoint.

Architecture, performance and unit test coverage: no production code, type,
dependency or path changed in this checkpoint, and no percentage is claimed.
No unit-tested class below 100% needs completing, and no top-level symbol
outside the coverage gate is unreferenced.

Feature integrity: both candidates keep their exact states, the inconclusive
and failed cells stay as measured, and no gate was weakened.

Validation plan effects:

The reviewer rewrote one Step 6 missing-work bullet in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md` and staged
exactly that attributable patch.

The writer's bullet asked to identify the unavailable PA6 prerequisite and to
"correct the environment or discovery as warranted". The reviewer isolated the
prerequisite on the retained prefix, so the bullet now states the measured
cause: two venvs, the shipped one with the wheels and an empty one named after
the candidate toolchain, which is what `senv` resolves. It also states the
consequence as a decision about which venv the deployment provides, and it
rules out relaxing discovery to pick the wheel-bearing venv while the
deployment selects another. That last clause follows from the requirement's
PA6 row ("over the venv the deployment provides") and the driver's reviewed
refusal to choose between candidates; it adds no new design decision.

Every other Step 6 row is the writer's and was left as written. The status
sentence stays exactly `No. Step 6 has NOT been fully implemented.`, the
`Missing work for Step 6` section stays present, and the document-level line
stays `No, it is not implemented.`

Pre-repair blob `17e11fa0b3df9ede1852c3bb0f5c534c093d8271` was recorded before
the edit, `attribute-reviewer-patch` returned `attributable: true`, and
`git apply --cached` staged exactly that patch.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 2) (round 1)

The reviewer ran all seven resolved commands before its repair. Six behave as
expected. The Markdown intersection check fails, but only on content the
protocol appended after the request was captured.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  transport exit 0 in 100 seconds, native `validation exit=0 elapsed=77s`, no
  FAIL line, four helper imports and 58 acceptance cases.
- The point 3 record verifier, source `request`: `PASS`, measured verdict
  `fail`, exit 0.
- The Markdown gate over cplx with its log redirected, source `request`:
  exit 1 on repository debt, as the request states.
- The Markdown intersection checker, source `request`: exit 1. It reports 7
  duplicate headings (MD024 and LS003) at transcript lines 7206 to 7358. All
  of them are in the request record the protocol appended at publication, whose
  section headings end in `(round 1)` without the exchange occurrence, so they
  repeat exchange 1's round 1 request headings. None is in the staged set; the
  writer's run passed because it ran before publication.
- `git diff --cached --check`, source `request`: clean.
- `bash .git/hooks/pre-commit`, source `request`: clean.

The reviewer reran the diff check, the hook, the commit-plan check and the
Markdown gate after staging its repair: all as above, and no finding in the
validation plan.

Evidence measured on the build host rather than read from the record: the
retention list's seven digests, the results, raw bundle and verification
bundle digests, the raw PA3 log, and on the retained deployed prefix the two
venvs, their contents and `pyvenv.cfg` creation commands and times, the PA6
cell's write time, the `senv` probe's resolved `python`, and the newest-venv
selection. The deployment logs do not name the venv the readiness checks
inspected, so this answer makes no claim about it.

No coverage percentage is claimed; cplx's floor is shell lint.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 2) (round 1)

The reviewer ran the union of the request validation set and the current
resolver set: the same seven commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 0.
- The point 3 record verifier, source `request`. Exit 0.
- The Markdown gate over cplx, logged, source `request`. Exit 1 on older debt.
- The Markdown intersection checker, source `request`. Exit 1, on the
  protocol's appended request record only.
- `git diff --cached --check`, source `request`. Clean.
- `bash .git/hooks/pre-commit`, source `request`. Clean.

As declared, the acceptance mode was not launched. The retained run was
verified from its retention list and read on the host instead.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 2) (round 1)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets.

One property of the Markdown intersection checker is worth knowing: it diffs
the working tree against HEAD, so it includes the transcript that publication
appends. Run before publication it passes, and run at review time it fails on
the appended request. That is a timing property, not drift.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 2) (round 1)

Every comparison came from the shared evidence launcher. The only tracked change
is the reviewer's own attributable validation-row patch.

- Request-time index tree `175a36c4936e7c717a6a0860daf19dc1088508fc` equals the
  baseline at entry. The assessed tree is
  `08649acc40df39a22a261b1e0b78969be44f8d7b`, which differs by exactly the
  staged reviewer patch.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `e293c50bf3409247d15604fb8517eb74aeaab4db4eabdfdd617a5e437d5edde4`.
- Validation-state comparison over the 6 staged paths, the project command's
  file and the four ignored validation files: `acceptable: false`, naming the
  validation plan and the index (the reviewer's permitted Step 6 row patch)
  and the ignored Markdown log that the declared command rewrites. Ignored
  validation artifacts are acceptable, and no tracked side effect occurred.
- The working tree matches its entry state apart from that staged patch: 6
  staged paths, plus the protocol's unstaged transcript append.
- No reviewer residue in either repository. The native run used host scratch
  space, and the retained prefix and evidence on the host were only read.
- The baselines and manifest were written before assessment, the pre-repair
  blob before the edit, and the manifest rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 2) (round 1)

Repairs made:

- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, polishing-only review metadata confined to one Step 6 missing-work bullet: the PA6 bullet now states the measured cause (two venvs, the empty one named after the candidate toolchain and resolved by `senv`) and the decision it requires, and rules out relaxing discovery

Paths staged:

- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md` (the attributable reviewer patch only, applied to the index with `git apply --cached`)

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 2) (round 1)

`a.commit` is accurate and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json`, run against the received
state and again after the reviewer's staged patch: `state: valid`,
`ready: true`, exit 0, no diagnostics, 6 staged paths in two ordered groups
matching the request. The installed hook accepts the staged set.

- Group 1, `docs(tools): record replacement RHEL acceptance`: both RHEL
  captures, the point 3 provenance capture, the record and its view.
- Group 2, `docs(tools): record RHEL checkpoint gaps`: the validation plan,
  including the reviewer's rewritten PA6 bullet, which is a gap and fits the
  subject.

Ordering is least to most dependent and every staged path appears once. The
transcript is not in the plan, correctly: it carries the protocol's appends,
including the request record whose headings need the exchange occurrence
before it is committed.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 2) (round 1)

Unresolved findings:

- PA6 on RHEL was not measured for the replacement, and the cause is a product question rather than a driver fault: by the end of the forced redeployment the prefix holds the shipped `python_3.13.9_my-project` venv with the heavy wheels and an empty `python_3.13.15_my-project` venv created with `python -m venv` and named after the candidate toolchain, which the operator `senv` resolves, so under the shipped-venv arrangement with a 3.13.9-built pdfs archive the deployed application environment has no pymupdf or pikepdf at all, and which venv PA6 must measure needs a human decision before any rerun.

Boundary-crossing work:

- Umbrella item 7's note states that after the venv-tree exclusion "the shipped-venv arrangement holds until item 8 replaces it"; this run shows it does not hold with the 3.13.15 toolchain and a 3.13.9-built pdfs archive, so the note (written by this reviewer in commit 3bbd15c) needs revising once the human decides, which reviewer mode cannot do
- The shared request renderer qualifies request section headings with the round but not the exchange occurrence, so the exchange 2 round 1 request repeats seven headings of exchange 1 round 1 in the transcript; the answer renderer already adds the exchange, and fixing the request renderer is an llm-shared change

### Human guidance response for step 6 tools-archive-rebuild (exchange 2) (round 1)

Human guidance:

The user authorized only point 3 of `.reviews/a.item7.handoff-prompt.md`:
rerun RHEL acceptance against the installer-only replacement archive, retain
the results and report the actual PA6 verdict. Point 3 belongs to plan Step 6
but does not complete Step 6. Read that handoff before judging the scope.

Points 4 through 6, the Debian candidate build, application commits and push,
wheel-bound D10, and remaining publication obligations are outside this
checkpoint. Step 6 must remain No and those obligations must remain pending.
Do not request completion of those later points as a repair to this evidence
checkpoint, and do not relabel partial qualification as Step 6 completion.

Review the staged evidence, preservation of original-candidate history, exact
replacement pins, truthful cell states, generated view, validation-plan update,
and commit grouping. A failed or inconclusive measured cell is evidence to
retain, not permission to weaken its gate. The handoff explicitly says to stop
and report raw diagnostics if PA6 does not pass.

Do not launch acceptance mode during review: it is a costly real deployment
run already retained under one exact run identity. The cumulative fixture mode
is separate and safe to run as the declared validation command.

The user requests publication followed by an immediate stop, without waiting
for the review answer. No commit, upload, application push or later handoff
point is authorized by this review request.

Guidance response:

The guidance is followed on every point.

- Scope. The review covers point 3 only. It asks for no Debian build,
  application push, D10 reading or publication work as a repair, and Step 6
  stays `No`.
- Items to review. The staged evidence, original-candidate preservation, exact
  replacement pins, truthful cell states, generated view, validation-plan
  update and grouping were each checked and are accurate. The one repair makes
  the PA6 missing-work bullet state its measured cause.
- Measured cells. PA3's failure and PA6's inconclusive state are retained as
  measured. The finding explicitly rules out weakening PA6's discovery to
  produce a pass.
- No acceptance mode was launched. The retained run was verified from its
  retention list and its prefix was read on the host. Only the cumulative
  fixture mode ran.
- No commit, upload, push or later point was performed or is authorized.

The handoff's stop condition was honored and was the right call. Stopping at
PA6 is what surfaced the finding: rerunning or adjusting discovery would have
hidden it.

### Writer instructions for step 6 tools-archive-rebuild (exchange 2) (round 1)

The staged evidence needs no rework. Three things follow from this round.

__Take the PA6 venv question to the human before any rerun.__ The deployment
provides two venvs and the operator environment uses the empty one. PA6 has to
measure the venv the deployment provides, so the question is which pdfs archive
makes that venv carry the wheels. The reviewer recommends a pdfs archive whose
shipped venv is built with the candidate toolchain, which keeps item 7 on the
shipped-venv arrangement the umbrella describes. Other routes are auditing the
shipped 3.13.9 venv explicitly while recording that the operator path fails, or
bringing item 8 forward. Do not change discovery to pick the wheel-bearing
venv.

__Qualify the appended request headings before committing the transcript.__
The exchange 2 round 1 request record repeats seven headings from exchange 1
round 1. When the transcript is next staged, add the exchange occurrence to
those seven headings, for example
`### Review identity for step 6 tools-archive-rebuild (exchange 2) (round 1)`,
and rerun the intersection checker. Change nothing else.

__Keep the PA3 work as written.__ The missing-work bullet for build-role
evidence is accurate. Supply the reader's `probes` stages from the original
build with the member comparison as unchanged-payload proof, or rerun the
probes, but do not relax the reader.

Done well this round: the stop condition was honored, both candidates' evidence
is preserved byte for byte, the provenance capture separates source commits
from fixture commits, and PA3 and PA6 are recorded as measured rather than
explained away.

### Decision rationale for step 6 tools-archive-rebuild (exchange 2) (round 1)

The disposition is changes-requested and the readiness floor is recorded as
incomplete. Step 6 is deliberately incomplete, and this round adds one finding
that needs the human before Step 6 can move.

1. Identity. Passes. The request tree matched at entry, and the assessed tree
   differs by exactly the reviewer's staged patch.
2. Completeness. Fails, by design and per the guidance.
3. Validation and coverage. The staged set passes all its checks. The declared
   Markdown intersection checker fails only on the protocol's appended request
   record, which is outside the staged set.
4. Staged attribution. Passes. One attributable validation-row patch, which is
   review metadata rather than a substantive repair.
5. Unresolved findings. One: which venv PA6 must measure.
6. `a.commit`. Passes, valid, ready and accepted by the hook.

The finding is the most important result of point 3, more important than the
two cells' states. The item's premise was that the venv-tree exclusion keeps
the shipped-venv arrangement working until item 8. On the real target with the
candidate toolchain, the application environment does not use the shipped venv
at all: it gets an empty one named for 3.13.15. A PA6 pass over the shipped
3.13.9 venv would have been real and still misleading.

The reviewer corrects its own earlier claim here rather than letting it stand
in the transcript. Exchange 1 round 2 said only the shipped venv existed at
audit time. That came from logs that never named the second venv, not from the
file system, and it was wrong. The practice this round follows instead: a
claim about what is on the target is checked on the target.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 2) (round 1)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-1-exchange-2 -->

## Round 2 by requestor - Step 6 (exchange 2)

- Recorded: 2026-09-19T14:45:07+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (exchange 2) (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 2

### Code review evidence for step 6 tools-archive-rebuild (exchange 2) (round 2)

request_index_tree: 69b06f05b4e46d4b7031cb1a433d03db37fefff3
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root . > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(tools): qualify RHEL with Python 3.13.15
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-original-rhel.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3.txt
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-failed-rhel.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-r2-preparation.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-round2.txt
group 2: docs(tools): record repaired RHEL checkpoint
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 2 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 3: docs(review): retain point 3 review context
group 3 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-original-rhel.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-failed-rhel.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-round2.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-r2-preparation.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
```

### Requestor assessment for step 6 tools-archive-rebuild (exchange 2) (round 2)

#### Assessment for step 6 tools-archive-rebuild (round 2)

Step 6 remains deliberately incomplete because Debian, final consumer/D10
identities, publication and adoption are later handoff work. This request
covers point 3 and the explicitly authorised PA3/PA6 repairs after exchange 2
round 1. The human selected Python 3.13.15 and authorised installing uv.

The new RHEL acceptance run passed all ten required cells and the
additional forced-redeployment cell in 3930 seconds. The
record verifier checks those states, exact archive/bundle/pdfs pins, every
retained raw capture digest, preservation of both failed runs, unchanged
Step 5 snapshots and the generated view. No production reader, discovery
guard or acceptance condition was weakened.

Native cumulative Step 6 validation passed in 77 seconds. Project shell lint
passed for 58 scripts. Full Markdown checking retains 39 existing findings;
the intersection check finds none on changed lines. The sensitive-content
hook, staged whitespace check and commit-plan checker also pass.
There is no new executable source change or coverage reduction.

### Implementation report for step 6 tools-archive-rebuild (exchange 2) (round 2)

#### Implementation details for step 6 tools-archive-rebuild (exchange 2) (round 2)

Prepared a new pdfs verification archive using the candidate Python 3.13.15
interpreter and the unchanged July application lock. The archive contains one
complete shipped venv, including uv. Eighty compatible wheel files were
downloaded through the configured corporate mirror, checked against their
locked hashes and transferred to the offline host. The locked requirements
were installed there, and the offline dry-run audit and heavy imports passed
before packaging. Only generated venv text paths and symlinks were normalised
for the account-shaped archive; wheel ELF objects were not modified.

Used the existing application packaging overlay and cplx packager. The
unchanged acceptance driver tests fresh and forced deployment of that pdfs
archive with the exact replacement tools archive. The selected venv is the
operator environment for Python 3.13.15, not the old wheel-bearing 3.13.9 venv.

PA3 receives compatible build evidence with the original probe stages and
explicit provenance. A fresh comparison verifies all 38070 archive members:
only the installer changed, so the 38069 payload members retain the original
build observations. Replacement deployment acceptance is newly measured.

The acceptance record preserves both previous failures and binds the new
RHEL run. Preparation evidence identifies the pdfs lock, wheel transport and
package hash without promoting them to final Debian consumer identities.
The umbrella now makes the matching-Python prerequisite explicit. The seven
duplicate exchange 2 round 1 request headings were qualified as requested.

### Change summary for step 6 tools-archive-rebuild (exchange 2) (round 2)

#### Staged path inventory for step 6 tools-archive-rebuild (exchange 2) (round 2)

Group 1: Replacement RHEL acceptance and preserved failures.

- `docs/v0.27.0/acceptance.tools-archive-rebuild.json`
- `docs/v0.27.0/acceptance.tools-archive-rebuild.md`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-original-rhel.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3.txt`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-failed-rhel.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-r2-preparation.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-round2.txt`

Group 2: Step 6 checkpoint and shipped environment prerequisite.

- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`
- `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`

Group 3: Point 3 review exchange.

- `docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md`

### Human guidance and writer response for step 6 tools-archive-rebuild (exchange 2) (round 2)

Human guidance:

#### Human scope and review guidance for step 6 tools-archive-rebuild (round 2)

Review Step 6 handoff point 3 and the user's explicit follow-up: address round 1,
fix PA3 and PA6, use Python 3.13.15, install uv if needed, and publish round 2. The human has answered the venv question raised by round 1. Do not request
that same decision again or treat the earlier stop-at-PA6 instruction as
prohibiting these now-authorised repairs.

Step 6 remains No because later Debian, consumer/D10, publication and adoption
work has not run. Do not treat this checkpoint as final Step 6 completion.
Assess whether the reviewed evidence and bounded repairs are ready to commit.
The request does not authorise a commit, application push, Jenkins build,
upload or later handoff point.

Use the retained native results and input hashes. Do not launch acceptance
mode during review; it performs another costly real deployment. The declared
cumulative mode is the separate fixture validation and is safe to run.
The user requests publication followed by a stop without waiting for an
answer.

Writer response:

#### Response to round 1 for step 6 tools-archive-rebuild (round 2)

Accepted the reviewer's diagnosis and staged validation-row clarification.
The subsequent human instruction resolves the prerequisite decision:
"3.13.15 should be the target, so if uv is missing, install it."
That instruction also explicitly authorises repairing PA3 and PA6 and
publishing round 2. It supersedes the earlier handoff stop at the failed PA6
checkpoint; no additional permission question is needed.

Prepared a matching complete shipped 3.13.15 venv instead of selecting the old
3.13.9 venv or bringing item 8 forward. The same discovery guard and offline
audit remain in force. The earlier incomplete prefix and both failure
captures remain intact. The umbrella's previously unconditional claim is now
conditional on a matching complete environment.

Supplied the original PA3 probes with source hashes and a newly verified
installer-only member comparison. The build-role reader is unchanged.

Qualified exactly the seven new duplicate transcript headings. The Markdown
intersection check is now clean. This is the requested targeted transcript
repair, not a rewrite of review history. There is no disagreement with the
review findings; the human decision and new measurements resolve them.

### Reviewer focus for step 6 tools-archive-rebuild (exchange 2) (round 2)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-2-exchange-2 -->

## Round 2 by reviewer - Step 6 (exchange 2)

- Recorded: 2026-09-19T14:54:31+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 2) (round 2)

Baseline index tree: 69b06f05b4e46d4b7031cb1a433d03db37fefff3

Assessed index tree: 69b06f05b4e46d4b7031cb1a433d03db37fefff3

### Implementation check for step 6 tools-archive-rebuild (exchange 2) (round 2)

Result:

No. Step 6 has NOT been fully implemented.

The verdict is the expected one: Debian, the exact-wheel D10 reading, consumer
identities, publication and adoption have not run, and the guidance keeps them
out of this checkpoint. Within point 3, the repairs are sound and the RHEL
result is now conclusive. Every central claim was measured on the build host
rather than read from the record.

- PA6 now measures the venv the deployment uses. On the retained prefix the
  project holds exactly one venv, `python_3.13.15_my-project`, with `uv`; the
  operator `senv` probe resolves `python` from it, and the PA6 cell was written
  after both deployments. The offline audit reports "Would use project
  environment", "Checked 80 packages" and "Would make no changes" with exit 0.
  pymupdf 1.27.2.3 and pikepdf 10.7.1 import under the 3.13.15 interpreter with
  exit 0, and the wheel object keeps `RUNPATH [$ORIGIN]`. The discovery guard is
  unchanged and passed because the layout is now unambiguous, not because it
  was relaxed.
- The pdfs verification archive is what the preparation capture says. It is
  253693690 bytes with SHA-256 `0b3c120e...e9b0` and holds one venv. Its
  `uv.lock` digest `e43a6232...687b` equals the lock inside the July pdfs
  archive, so the lock is unchanged. All 80 transported wheel hashes appear in
  that lock. The reviewer checked every installed site-packages file against
  its wheel's `RECORD`: 9923 entries, zero mismatches, including all 80 ELF
  objects, so no wheel file was modified by the path normalisation.
- PA3 reuses the original build evidence faithfully. The build-role input
  (`13808e09...6b85`) carries probe stages byte-equal to the original Step 5
  summary, whose digest `7fb03bec...f693` matches the recorded provenance. The
  unchanged reader passed all four stages, and the installer-only member
  comparison was verified independently in Step 5 round 3.
- The record is honest. The results file equals the host's retained
  `results.json` (`08114f9e...8115`), all seven retention digests verify, both
  earlier failed runs are preserved byte for byte, and the Step 5 snapshots are
  unchanged.
- The umbrella note, which the reviewer wrote in `3bbd15c` and flagged in
  round 1 as contradicted, now makes the shipped-venv arrangement conditional
  on a complete venv for the candidate Python. That is accurate and scoped.
- The staged transcript's seven round 1 request headings now carry the
  exchange occurrence, no heading repeats, and the reviewer's round 1 answer
  copy is byte-identical to what it rendered.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 2) (round 2)

- Commit the three application reader repairs.
- Run the Debian agent candidate build and bind the Debian cells, environment
  and consumers.
- Take the D10 reading with the agent's exact wheels.
- Bind the remaining pre-publication obligations and pass the publication
  phase.

Architecture, performance and unit test coverage: no production code, reader,
guard or path changed, no runtime cost was added, and no percentage is
claimed. No unit-tested class below 100% needs completing, and no top-level
symbol outside the coverage gate is unreferenced.

Feature integrity: both earlier failures stay retained as measured, the
replacement's passes are candidate-bound, and no gate was weakened.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows match this assessment. The status sentence is exactly
`No. Step 6 has NOT been fully implemented.`, the `Missing work for Step 6`
section keeps only the genuinely remaining items (application commits, Debian
build, D10 and the pre-publication obligations), and the resolved PA3 and PA6
bullets, including the reviewer's round 1 PA6 bullet, were correctly removed
now that both pass. The round 2 repair bullet's claims were each confirmed on
the host. The document-level line stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 2) (round 2)

The reviewer ran all seven resolved commands. Six behave as expected. The
Markdown intersection checker fails, again only on the request record the
protocol appended at publication, which is outside the staged set.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  transport exit 0 in 99 seconds, native `validation exit=0 elapsed=75s`, no
  FAIL line, four helper imports and 58 acceptance cases.
- The round 2 record verifier, source `request`: `PASS`, exit 0.
- The Markdown gate over cplx with its log redirected, source `request`:
  exit 1 on repository debt, as the request states.
- The Markdown intersection checker, source `request`: exit 1 with three
  findings, all in the appended round 2 request record. Two are duplicate
  headings: the requestor's own sub-headings
  `Implementation report for step 6 tools-archive-rebuild (round 2)` and
  `Change summary for step 6 tools-archive-rebuild (round 2)` already carried a
  round suffix, so the renderer left them unqualified, and they repeat exchange
  1's round 2 section headings. The third is MD032: a wrapped guidance line
  begins with `2. The human`, which Markdown parses as a list item.
- `git diff --cached --check`, source `request`: clean.
- `bash .git/hooks/pre-commit`, source `request`: clean on the index.

The appended round 2 request record also lists three of this request's
validation commands with absolute paths under the user's home directory, which
contain the private account name. The hook does not see them yet because the
append is unstaged; it will refuse them when the transcript is next staged.

Measured on the build host: the round 2 retention list, the results and raw
bundle digests, the PA6 raw captures (audit, imports, search path), the
deployed prefix's single venv and cell timing, the `senv` resolution, the pdfs
verification archive's digest, venv, lock and a full `RECORD` check of its
installed files, the July lock digest, and PA3's probe equality with the
original summary.

No coverage percentage is claimed; cplx's floor is shell lint.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 2) (round 2)

The reviewer ran the union of the request validation set and the current
resolver set: the same seven commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 0.
- The round 2 record verifier, source `request`. Exit 0.
- The Markdown gate over cplx, logged, source `request`. Exit 1 on older debt.
- The Markdown intersection checker, source `request`. Exit 1, on the
  appended request record only.
- `git diff --cached --check`, source `request`. Clean.
- `bash .git/hooks/pre-commit`, source `request`. Clean on the index.

Acceptance mode was not launched, as the guidance directs. The retained run and
prefix were read on the host instead.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 2) (round 2)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets.

Three request additions are again declared with absolute home-directory paths,
which Step 5 round 5 had replaced with sibling-relative forms. That is not
drift, but it is why the appended request record now carries the account name.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 2) (round 2)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `69b06f05b4e46d4b7031cb1a433d03db37fefff3` equals the
  baseline at entry and the live index after every run.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `0c2f846213875be83c31e9a85cf51ab9cc804f3273488ab41e12dd398f0b4798`.
  The digest differs from earlier rounds because the writer's staged umbrella
  note is in the working tree; within this round it did not change, and no
  umbrella row was completed.
- Validation-state comparison over the 11 staged paths, the project command's
  file and the four ignored validation files: `acceptable: true` with empty
  lists.
- The working tree matches its entry state: 11 staged paths, and the
  transcript also carries the protocol's unstaged append of this request.
- No reviewer residue in either repository. The native run used host scratch
  space; the reviewer's two read-only host scripts ran from `/var/tmp` and were
  removed, and nothing retained was modified.
- The baselines and manifest were written before assessment and the manifest
  rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 2) (round 2)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 2) (round 2)

`a.commit` is accurate for the staged set, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 11 staged paths in three
ordered groups matching the request. The installed hook accepts the index.

- Group 1, `docs(tools): qualify RHEL with Python 3.13.15`: the record, its
  view and the six RHEL and preparation captures, including both preserved
  failures.
- Group 2, `docs(tools): record repaired RHEL checkpoint`: the validation plan
  and the umbrella note.
- Group 3, `docs(review): retain point 3 review context`: the staged
  transcript, which is clean.

Ordering is least to most dependent and every staged path appears once. One
caution for the commit: if the owning workflow stages the transcript's newer
protocol appends into group 3, the round 2 request record comes with it, and
the hook will refuse that record's three account-name lines until they are
fixed.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 2) (round 2)

Unresolved findings:

- The appended round 2 request record, built from this request's own content, will block or fail the next transcript commit: three of its validation-command lines carry absolute paths under the user's home directory with the private account name, which the installed hook refuses once staged (a regression of the Step 5 round 5 fix), and the declared Markdown intersection checker fails on two requestor-authored sub-headings that repeat exchange 1's round 2 section headings and on a wrapped guidance line that begins with `2.` and parses as a list.

Boundary-crossing work: None.

### Human guidance response for step 6 tools-archive-rebuild (exchange 2) (round 2)

Human guidance:

#### Human scope and review guidance for step 6 tools-archive-rebuild (exchange 2) (round 2)

Review Step 6 handoff point 3 and the user's explicit follow-up: address round 1,
fix PA3 and PA6, use Python 3.13.15, install uv if needed, and publish round 2. The human has answered the venv question raised by round 1. Do not request
that same decision again or treat the earlier stop-at-PA6 instruction as
prohibiting these now-authorised repairs.

Step 6 remains No because later Debian, consumer/D10, publication and adoption
work has not run. Do not treat this checkpoint as final Step 6 completion.
Assess whether the reviewed evidence and bounded repairs are ready to commit.
The request does not authorise a commit, application push, Jenkins build,
upload or later handoff point.

Use the retained native results and input hashes. Do not launch acceptance
mode during review; it performs another costly real deployment. The declared
cumulative mode is the separate fixture validation and is safe to run.
The user requests publication followed by a stop without waiting for an
answer.

Guidance response:

The guidance is followed on every point.

- The venv decision is taken as answered. The reviewer does not raise it
  again; it checked that the repair implements it: the deployment's only venv
  is the complete 3.13.15 one, and PA6 measured that venv.
- Step 6 stays `No`, and nothing here treats the checkpoint as completion.
- Readiness to commit: the staged evidence and bounded repairs are ready. Every
  claim that decides PA3 and PA6 was measured on the host and holds. The one
  finding concerns the round 2 request record the protocol appended after the
  index was captured, which is not in the staged set but will reach the next
  transcript commit.
- Acceptance mode was not launched. Only the declared cumulative fixture mode
  ran, and the retained run was read in place.
- No commit, push, build, upload or later point was performed or is
  authorized.

The disposition is changes-requested because Step 6 is incomplete by design
and because of that one transcript finding, not because of any defect in the
point 3 evidence.

### Writer instructions for step 6 tools-archive-rebuild (exchange 2) (round 2)

The staged checkpoint needs no rework. One transcript fix is needed before the
review history is committed, plus one habit to keep.

__Fix the appended round 2 request record before staging it.__ In the working
tree transcript, the round 2 request record lists three validation commands
with absolute paths under the user's home directory. Replace that prefix with
the sibling-relative form (`../llm-shared/...` and `--root ../cplx`), as was
done for Step 5 rounds 3 and 4. In the same record, add the exchange
occurrence to the two sub-headings that repeat exchange 1's round 2 section
headings, for example
`#### Implementation report for step 6 tools-archive-rebuild (exchange 2) (round 2)`.
Rewrap the guidance paragraph so that no line begins with `2.` followed by a
space. Then stage the transcript, run the hook and the intersection checker,
and require both clean.

__Declare request commands without home paths, and give sub-headings their
own names.__ The absolute paths came back in this request's declared
commands; the sibling-relative forms work and were used in Step 5 round 5. A
sub-heading inside an assessment or report section does not need to repeat the
section's own title; a short distinct title avoids the collision entirely.

Done well this round: the repair measured the venv the deployment actually
uses instead of steering discovery to the wheel-bearing one, the pdfs
verification archive's wheels are provably unmodified, PA3 reuses the original
probes with verifiable provenance, both failed runs are preserved, and the
umbrella note was corrected to match the evidence.

### Decision rationale for step 6 tools-archive-rebuild (exchange 2) (round 2)

The disposition is changes-requested and the readiness floor is recorded as
incomplete: Step 6 is incomplete by design, and one transcript finding remains.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Fails by design, per the guidance.
3. Validation and coverage. The staged set passes. The declared Markdown
   intersection checker fails only on the appended round 2 request record.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. One: the appended request record's home paths,
   duplicate sub-headings and list-parsing line.
6. `a.commit`. Passes, valid and ready, and the hook accepts the index.

On substance this is the round that makes RHEL acceptance real. Round 1 showed
that PA6 could not pass honestly with a 3.13.9-built pdfs archive under the
3.13.15 toolchain. This round changed the input, not the gate: one complete
3.13.15 venv, built from the unchanged lock with provably unmodified wheels,
deployed twice and audited by the unchanged driver. The reviewer checked the
properties that would have made a pass misleading: a second venv, a changed
lock, edited wheel objects, or a relaxed discovery guard. None is present.

For the human: the PA6 pass qualifies the tools archive with a pdfs
verification archive built for this purpose, not with a pdfs archive the
application pipeline produced. The record and umbrella say so. The pipeline's
own pdfs build with the candidate toolchain belongs to the Debian point, where
final consumer identities are bound.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 2) (round 2)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-2-exchange-2 -->

## Round 3 by requestor - Step 6

- Recorded: 2026-09-19T15:37:27+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (exchange 2) (round 3)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 3

### Code review evidence for step 6 tools-archive-rebuild (exchange 2) (round 3)

request_index_tree: df54d0dac9ea1f633b89ae970e2312feff83a60f
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: docs(tools): qualify RHEL with Python 3.13.15
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-original-rhel.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3.txt
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-failed-rhel.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-r2-preparation.json
group 1 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-round2.txt
group 2: docs(tools): record repaired RHEL checkpoint
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 2 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 3: docs(review): retain point 3 review context
group 3 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-original-rhel.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-failed-rhel.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-round2.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3.txt
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-r2-preparation.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
```

### Requestor assessment for step 6 tools-archive-rebuild (exchange 2) (round 3)

Step 6 remains deliberately incomplete because Debian, final consumer/D10
identities, publication and adoption are later handoff work. This request
covers point 3 and the explicitly authorised PA3/PA6 repairs after exchange 2
round 1. The human selected Python 3.13.15 and authorised installing uv.

The new RHEL acceptance run passed all ten required cells and the
additional forced-redeployment cell in 3930 seconds. The
record verifier checks those states, exact archive/bundle/pdfs pins, every
retained raw capture digest, preservation of both failed runs, unchanged
Step 5 snapshots and the generated view. No production reader, discovery
guard or acceptance condition was weakened.

Native cumulative Step 6 validation passed in 77 seconds. Project shell lint
passed for 58 scripts. Full Markdown checking retains 39 existing findings;
the intersection check finds none on changed lines. The sensitive-content
hook, staged whitespace check and commit-plan checker also pass.
There is no new executable source change or coverage reduction.

Round 3 changes only review-history formatting and command paths. The reviewer
independently confirmed the retained PA3/PA6 evidence and reran cumulative
validation in round 2. No executable or acceptance input changed since then.

### Implementation report for step 6 tools-archive-rebuild (exchange 2) (round 3)

Prepared a new pdfs verification archive using the candidate Python 3.13.15
interpreter and the unchanged July application lock. The archive contains one
complete shipped venv, including uv. Eighty compatible wheel files were
downloaded through the configured corporate mirror, checked against their
locked hashes and transferred to the offline host. The locked requirements
were installed there, and the offline dry-run audit and heavy imports passed
before packaging. Only generated venv text paths and symlinks were normalised
for the account-shaped archive; wheel ELF objects were not modified.

Used the existing application packaging overlay and cplx packager. The
unchanged acceptance driver tests fresh and forced deployment of that pdfs
archive with the exact replacement tools archive. The selected venv is the
operator environment for Python 3.13.15, not the old wheel-bearing 3.13.9 venv.

PA3 receives compatible build evidence with the original probe stages and
explicit provenance. A fresh comparison verifies all 38070 archive members:
only the installer changed, so the 38069 payload members retain the original
build observations. Replacement deployment acceptance is newly measured.

The acceptance record preserves both previous failures and binds the new
RHEL run. Preparation evidence identifies the pdfs lock, wheel transport and
package hash without promoting them to final Debian consumer identities.
The umbrella now makes the matching-Python prerequisite explicit. The seven
duplicate exchange 2 round 1 request headings were qualified as requested.

For round 3, repaired only the round 2 request record: sibling-relative
validation commands, distinct exchange-qualified subheadings, and guidance
paragraph wrapping. All native captures and their bindings remain unchanged.

### Change summary for step 6 tools-archive-rebuild (exchange 2) (round 3)

Group 1: Replacement RHEL acceptance and preserved failures.

- `docs/v0.27.0/acceptance.tools-archive-rebuild.json`
- `docs/v0.27.0/acceptance.tools-archive-rebuild.md`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-original-rhel.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3.txt`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-failed-rhel.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-rhel.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-r2-preparation.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-point3-round2.txt`

Group 2: Step 6 checkpoint and shipped environment prerequisite.

- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`
- `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`

Group 3: Point 3 review exchange.

- `docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md`

### Human guidance and writer response for step 6 tools-archive-rebuild (exchange 2) (round 3)

Human guidance:

Review Step 6 handoff point 3 and the user's explicit follow-up: address round 2 findings and publish round 3. The human has answered the venv question raised by round 1. Do not request
that same decision again or treat the earlier stop-at-PA6 instruction as
prohibiting these now-authorised repairs.

Step 6 remains No because later Debian, consumer/D10, publication and adoption
work has not run. Do not treat this checkpoint as final Step 6 completion.
Assess whether the reviewed evidence and bounded repairs are ready to commit.
The request does not authorise a commit, application push, Jenkins build,
upload or later handoff point.

Use the retained native results and input hashes. Do not launch acceptance
mode during review; it performs another costly real deployment. The declared
cumulative mode is the separate fixture validation and is safe to run.
The user requests publication followed by a stop without waiting for an
answer.

Writer response:

Accepted the round 2 finding. The reviewer made no staged repairs.

Replaced the three declared validation commands' private home prefixes with
sibling-relative paths in the round 2 request record. Renamed the two
redundant subheadings to distinct exchange-qualified titles, avoiding a
collision with their parent headings. Rewrapped the guidance paragraph.
The staged transcript is checked by the sensitive-content hook and Markdown
intersection checker. No linter rule or baseline was changed.

New authored inputs omit redundant headings, and new declared commands use
sibling-relative paths. Runtime launcher calls still follow the shared
absolute-path shell contract. The request summary receives exchange-qualified
section headings before publication. There is no disagreement. The three
commit groups and their subjects remain accurate and unchanged.

PA3 and PA6 remain passing on the retained Python 3.13.15 run. Step 6 remains
No for later handoff work; this request seeks review of the point 3 checkpoint.

The reviewer answer copied the same wrapped guidance paragraph, producing
one additional MD032 finding. Rewrapped that copy too; its words, findings
and verdict are unchanged.

### Reviewer focus for step 6 tools-archive-rebuild (exchange 2) (round 3)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-3 -->

## Round 3 by reviewer - Step 6

- Recorded: 2026-09-19T15:44:29+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 3)

Baseline index tree: df54d0dac9ea1f633b89ae970e2312feff83a60f

Assessed index tree: df54d0dac9ea1f633b89ae970e2312feff83a60f

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 3)

Result:

No. Step 6 has NOT been fully implemented.

The verdict is the expected one, per the guidance: Debian, the exact-wheel D10
reading, consumer identities, publication and adoption have not run. Within
handoff point 3 the checkpoint is complete and correct.

Since round 2 the index has changed only in the review transcript: 519 lines
appended and none removed, holding the round 2 request record and the
reviewer's round 2 answer. Every RHEL, pdfs and PA3 claim the reviewer measured
on the build host in round 2 therefore still stands on unchanged bytes, and
every declared command was re-run against the current index this round.

The round 2 finding is fixed, verified rather than accepted:

- The round 2 request record's three validation commands are sibling-relative,
  and no line in the working-tree transcript carries the private account name.
- Its two sub-headings no longer repeat exchange 1's section headings, and the
  guidance paragraph no longer wraps onto a line that parses as a list. The
  staged transcript has no duplicate heading anywhere.
- The reviewer's round 2 answer copy is word-for-word identical to what it
  rendered. The only edit rewrapped the copied guidance paragraph, which the
  reviewer had carried over with the same list-parsing line; the requestor
  fixed that too.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 3)

- Commit the three application reader repairs.
- Run the Debian agent candidate build and bind the Debian cells, environment
  and consumers.
- Take the D10 reading with the agent's exact wheels.
- Bind the remaining pre-publication obligations and pass the publication
  phase.

Architecture, performance and unit test coverage: no production code, reader,
guard or path changed, no runtime cost was added, and no percentage is
claimed. No unit-tested class below 100% needs completing, and no top-level
symbol outside the coverage gate is unreferenced.

Feature integrity: both earlier failures stay retained as measured, the
replacement's passes stay candidate-bound, and no gate was weakened.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, which is
unchanged since round 2. The Step 6 status sentence is exactly
`No. Step 6 has NOT been fully implemented.`, the `Missing work for Step 6`
section lists only the remaining later-point work, and the document-level line
stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 3)

The reviewer ran all seven resolved commands. All seven behave as expected.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  transport exit 0 in 99 seconds, native `validation exit=0 elapsed=75s`, no
  FAIL line, four helper imports and 58 acceptance cases.
- The round 2 record verifier, source `request`: `PASS`, exit 0.
- The Markdown gate over cplx with its log redirected, source `request`:
  exit 1 on repository debt, as declared.
- The Markdown intersection checker, source `request`: `PASS`, 39 existing
  diagnostics and none on lines added since HEAD. This run already includes
  the round 3 request record the protocol appended at publication, which the
  earlier rounds' runs did not survive.
- `git diff --cached --check`, source `request`: clean.
- `bash .git/hooks/pre-commit`, source `request`: clean.

Also verified: a scan of the whole working-tree transcript finds no line with
the private account name; the staged transcript has no duplicate heading; and
the reviewer's round 2 answer copy matches its rendering word for word.

No coverage percentage is claimed; cplx's floor is shell lint.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 3)

The reviewer ran the union of the request validation set and the current
resolver set: the same seven commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 0.
- The round 2 record verifier, source `request`. Exit 0.
- The Markdown gate over cplx, logged, source `request`. Exit 1 on older debt.
- The Markdown intersection checker, source `request`. Exit 0.
- `git diff --cached --check`, source `request`. Clean.
- `bash .git/hooks/pre-commit`, source `request`. Clean.

All request additions are declared in sibling-relative form. Acceptance mode
was not launched, as the guidance directs.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 3)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 3)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `df54d0dac9ea1f633b89ae970e2312feff83a60f` equals the
  baseline at entry and the live index after every run. Against the round 2
  tree it differs only in the review transcript.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `0c2f846213875be83c31e9a85cf51ab9cc804f3273488ab41e12dd398f0b4798`.
- Validation-state comparison over the 11 staged paths, the project command's
  file and the four ignored validation files: `acceptable: true` with empty
  lists.
- The working tree matches its entry state: 11 staged paths, and the
  transcript also carries the protocol's unstaged append of this request.
- No reviewer residue in either repository.
- The baselines and manifest were written before assessment and the manifest
  rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 3)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 3)

`a.commit` is accurate and executable, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 11 staged paths in the
same three ordered groups as round 2. The installed hook accepts the index.

- Group 1, `docs(tools): qualify RHEL with Python 3.13.15`: the record, its
  view and the six RHEL and preparation captures.
- Group 2, `docs(tools): record repaired RHEL checkpoint`: the validation plan
  and the umbrella note.
- Group 3, `docs(review): retain point 3 review context`: the staged
  transcript, now clean under both the hook and the Markdown checks.

When the owning workflow stages this answer's protocol append into group 3,
run the hook and the intersection checker once more on the final index, since
that append lands after this review's evidence.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 3)

Unresolved findings: None.

Boundary-crossing work: None.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 3)

Human guidance:

Review Step 6 handoff point 3 and the user's explicit follow-up: address round 2 findings and publish round 3. The human has answered the venv question raised by round 1. Do not request
that same decision again or treat the earlier stop-at-PA6 instruction as
prohibiting these now-authorised repairs.

Step 6 remains No because later Debian, consumer/D10, publication and adoption
work has not run. Do not treat this checkpoint as final Step 6 completion.
Assess whether the reviewed evidence and bounded repairs are ready to commit.
The request does not authorise a commit, application push, Jenkins build,
upload or later handoff point.

Use the retained native results and input hashes. Do not launch acceptance
mode during review; it performs another costly real deployment. The declared
cumulative mode is the separate fixture validation and is safe to run.
The user requests publication followed by a stop without waiting for an
answer.

Guidance response:

The guidance is followed on every point.

- The venv decision is not raised again.
- Step 6 stays `No`, and nothing here treats the checkpoint as completion.
- Readiness to commit: yes. The reviewed evidence and bounded repairs are ready
  to commit. The substance was measured on the build host in round 2 and is
  unchanged, the round 2 transcript finding is fixed, and no finding remains.
- Acceptance mode was not launched; only the declared cumulative fixture mode
  ran.
- No commit, push, build, upload or later point was performed or is
  authorized.

The disposition below is changes-requested only because the shared rule ties a
commit-ready recommendation to a complete step, and Step 6 is incomplete by
design. That is the same position as the exchange 1 round 2 checkpoint, which
the human then committed through the owning workflow. The commit choice for
this checkpoint is likewise the human's.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 3)

No rework is needed. The point 3 checkpoint is ready to commit through the
owning workflow if the human chooses to. Stage this answer's protocol append
into group 3 and run the hook and the intersection checker once more on the
final index before committing.

After that, per the handoff: commit the three application reader repairs, then
continue with the Debian candidate build when the human authorizes it.

Done well across this checkpoint: the stop at PA6 was honored, the human's
decision was implemented by changing the input rather than the gate, every
repair was confined to what the checks reported, and the review history is now
clean under both the hook and the Markdown checks.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 3)

The disposition is changes-requested and the readiness floor is recorded as
incomplete, for one reason only: Step 6 is incomplete by design. Every other
readiness result passes, and no finding remains.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Fails by design, per the guidance.
3. Validation and coverage. Passes; all seven declared commands behave as
   expected, including the Markdown intersection check after publication.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. None.
6. `a.commit`. Passes, valid, ready and accepted by the hook.

The reviewer does not bend the completeness rule for a partial checkpoint, and
states instead what it means here: nothing is left for the writer to rework,
and the evidence is ready to commit.

One process note from the reviewer's side. Its round 2 answer carried over the
guidance line that parsed as a list, and its own pre-publication lint of the
appended summary did not reproduce the finding, because the checker's list
detection depends on surrounding context. For its own content the reviewer now
also rejects any wrapped line that begins with a number and a period, rather
than relying on that lint alone.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 3)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-3 -->

## Round 4 by requestor - Step 6

- Recorded: 2026-09-19T17:00:47+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 4)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 4

### Code review evidence for step 6 tools-archive-rebuild (round 4)

request_index_tree: 20e98f6708897030a14926bda7f52c38409a8717
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: docs(tools): bind Debian candidate evidence
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3: docs(tools): record point 4 checkpoint
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 3 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 4)

No. Step 6 has NOT been fully implemented.

The handoff point 4 attempt is retained: committed candidate pins were pushed with
publication off; build 176 finished FAILURE; its full console
and archived evidence were retained and independently read on native Linux.
Every Debian cell and available application/runtime identity is bound to that
retained run. Provisioning failed because uv 0.12.17 refused uv.lock under
`uv sync --locked` with CPython 3.13.15. PA1 to PA4 pass; PA5 to PA9 are pending.
No agent wheel inventory or successful venv base capture exists. Their fields
remain pending; the committed lock digest is retained only as input provenance.
Resolve the lock refusal and repeat the candidate build before point 5 D10.
The agent also reports failures in historical diagnostic harnesses, including
the older Python 3.13.9 relocation inventory. Those raw findings are retained
and are not represented as passes by this checkpoint.

Native cumulative step 6 validation passed in 77 seconds, including 61
acceptance fixtures, the inherited suites and 16 release-record tests. The
project shell lint gate passes for 58 tracked scripts. The repaired Git Bash
bundle passes the application's unchanged strict adapter. Record/provenance
checks verify the exact pins, capture hashes, generated view, historical
snapshots and unchanged publication/adoption gates. Full Markdown lint has
existing repository debt; the added-line check records whether new findings
were introduced. No Python coverage percentage is claimed.

The code changes are a linear manifest normalization and one anchored console
prefix normalization. They preserve raw captures and keep production controls
and post-build reader provenance distinct. No new architectural layer or
unbounded processing is introduced. Historical failing evidence remains
retained. Fresh RHEL acceptance for the newly bound consumers, D10 with the
agent wheels, any unresolved Debian cells and the remaining publication
obligations are still required before Step 6 can complete.

### Implementation report for step 6 tools-archive-rebuild (round 4)

The composer now explicitly hashes binary bytes and normalizes the binary
marker to the two-space manifest format required by the application adapter.
Build 175 exposed the Git Bash incompatibility and is retained as a failure.
Build 176 used a native bundle from committed cplx source. The shipped archive
identity is unchanged.

The Debian evidence reader removes Jenkins timestamp prefixes for anchored
probe parsing while retaining the raw console byte-for-byte. Regressions cover
binary marker generation, timestamped passing evidence, and timestamped ABI
failure. Both original and repaired readers were run on the real evidence;
their results and exact reader digest are retained separately.

The application reader repairs were committed as 784f33ed. Candidate pins in
application commit 7acda8ac4b35f20ee0bfee2ac27ecfab6afa174e select archive
df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87, verification bundle
dab8bf5036715a45bc21932592923d50d660cb1674adb84111b3630d88fd3b51 and cplx source
72f6cb290700faf328b73d946e78e8fedab8c2cd. Publication remains off.

Recorded Debian cells:

- PA1:debian: pass. candidate relocated without a shim, trailer completed
- PA2:debian: pass. wrapper first-call acceptance met
- PA3:debian: pass. SQLite acceptance role over the pinned archive
- PA4:debian: pass. toolchain git answered --version after relocation
- PA5:debian: pending. not executed in this run
- PA6:debian: pending. not executed in this run
- PA7:debian: pending. not executed in this run
- PA8:debian: pending. not executed in this run
- PA9:debian: pending. not executed in this run

The sidecar, generated acceptance view, validation plan and umbrella record
this checkpoint. Earlier RHEL captures and input snapshots are unchanged.
The earlier RHEL PA5/PA6 passes cannot stand for this application or an
uncaptured agent wheel set, so their current release obligations remain pending.

### Change summary for step 6 tools-archive-rebuild (round 4)

The root a.commit orders the staged work as follows:

1. fix(tools): normalize candidate verification evidence
   - ci/deliver-closure-tools.sh
   - docs/v0.27.0/acceptance.tools-archive-rebuild.sh
   - docs/v0.27.0/verify.tools-release-acceptance.sh
2. docs(tools): bind Debian candidate evidence
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
3. docs(tools): record point 4 checkpoint
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
   - docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md

The request publication appends its protocol-owned transcript after index
capture. No cplx point 4 changes are committed by this request.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 4)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop".

Read `.reviews/a.item7.handoff-prompt.md` as the sequencing context. This
request covers point 4, after the reviewed point 3 checkpoint was committed.
Point 5 (D10 with the agent wheels) and point 6 (publication closure) are
deliberately outside this checkpoint. Step 6 remains checked No. Assess any
defects in the staged work separately from the unfinished later obligations;
do not weaken the completion or publication gates to obtain commit-ready.

The requestor stops after publication, as explicitly instructed by the human.

Writer response:

Step 6 round 3 (exchange 2) reported no findings. Its changes-requested verdict
reflected the deliberately incomplete step. The human authorized the sequence:
the point 3 checkpoint was committed, then the application reader repairs and
candidate pins were committed and pushed before the candidate run.

No reviewer repair was reversed and there is no disagreement. This replacement
round adds point 4 evidence and two integration corrections found during that
work: portable manifest formatting and timestamp-aware console parsing. The
acceptance expectations, evidence identity checks and release gates remain
unchanged. Historical failed captures are preserved rather than relabeled.

### Reviewer focus for step 6 tools-archive-rebuild (round 4)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-4 -->

## Round 4 by reviewer - Step 6

- Recorded: 2026-09-19T17:12:20+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 4)

Baseline index tree: 20e98f6708897030a14926bda7f52c38409a8717

Assessed index tree: 20e98f6708897030a14926bda7f52c38409a8717

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 4)

Result:

No. Step 6 has NOT been fully implemented.

The reviewer reaches the writer's verdict independently. Point 4's candidate
build failed at provisioning, so PA5 to PA9 on Debian, the agent's wheel
inventory and venv base, D10 with those wheels and the publication obligations
remain open. The checkpoint records that failure honestly, and its two code
repairs are correct.

Verified rather than accepted:

- Build 176. The Jenkins API reports build 176 `FAILURE`, built from application
  commit `7acda8ac`, which is the recorded application and pipeline revision.
  The retained console is byte-identical to the live `consoleText` (1151009
  bytes), and it contains the refusal verbatim: uv 0.12.17 reported that the
  lockfile needs to be updated but `--locked` was provided.
- The Debian reading. The staged capture equals the reading retained on the
  RHEL host except for the host node name, which was removed with a recorded
  sanitization note: same nine cells, pins and `incomplete` verdict. The
  reading archive and verification bundle digests on the host match the
  recorded ones. The reader that produced it is the staged driver, whose
  digest `b5b2a2ce...8789` is the one the retention records; the committed
  bundle reader is recorded separately with its own `fail` result.
- The record. PA1 to PA4 on Debian pass on build 176 and PA5 to PA9 stay
  pending. RHEL PA5 and PA6 move from pass to pending with their original run
  and input snapshot kept and a stated reason. That follows the requirement:
  a relevant change makes affected results pending until repeated, and the
  validator itself refuses a PA5 or PA6 pass whose lock or wheels changed. The
  original candidate and every earlier capture are unchanged.
- Manifest repair. `sha256sum --binary` plus a first-occurrence `sed` turns the
  `*` marker into the two-space form on every platform; a hex digest holds no
  space, so only the separator changes. The new fixture forces the binary
  marker on Linux and requires a byte-identical bundle.
- Reader repair. Only the anchored Jenkins timestamp prefix is stripped, for
  parsing; the raw console is kept byte for byte. New fixtures cover a
  timestamped pass and a timestamped ABI failure that must stay a failure.
- The umbrella note and validation rows describe this accurately, including
  the new sizes (driver 945 lines, delivery script 313).

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 4)

- Resolve the application lock refusal under uv 0.12.17 and CPython 3.13.15
  without bypassing `--locked`, then repeat the candidate build with
  publication off and capture its lock, wheels and venv base.
- Run PA5 to PA9 on Debian from that build.
- Repeat RHEL PA5 and PA6 against the new consumer inputs.
- Take the D10 reading with the agent's exact wheels.
- Bind the remaining pre-publication obligations and pass the publication
  phase.

Architecture: both repairs stay in the component that owns the behavior, the
composer and the post-build reader. No violation or smell.

Performance: one linear `sed` over the manifest and one anchored substitution
over the console. No new quadratic path.

Unit test coverage: no Python class changed and no percentage is claimed. No
unit-tested class below 100% needs completing, and no top-level symbol outside
the coverage gate is unreferenced.

Feature integrity: bundle bytes are unchanged on Linux, the raw console is
preserved, and a timestamped ABI failure still fails. Nothing is impaired.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows match this assessment: the status sentence is exactly
`No. Step 6 has NOT been fully implemented.`, the fixture count and sizes are
correct, and the `Missing work for Step 6` section replaces the finished
application-commit and build bullets with the lock refusal, the pending Debian
cells and the consumer-bound RHEL rerun. The document-level line stays
`No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 4)

The reviewer ran all seven resolved commands. Five pass as declared. The
declared Markdown pair does not check this repository.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`: the first
  attempt failed before validation because the RHEL host's `/var/tmp` was
  full. The reviewer removed only its own scratch from earlier review rounds
  there and reran: transport exit 0 in 104 seconds, native
  `validation exit=0 elapsed=81s`, no FAIL line, four helper imports, the
  three new cases and 61 acceptance cases. It ran against application HEAD
  `812e7949`, which now carries the reader repairs.
- The point 4 record verifier, source `request`: `PASS`, exit 0.
- The Markdown gate as declared, source `request`: exit 0 with zero findings,
  because the batch file changes into the llm-shared root and `--root .` then
  names llm-shared. The intersection checker, source `request`, therefore
  fails its own guard ("Expected retained repository-debt diagnostics").
  Rerun with `--root` naming cplx, the gate reports the 39 older findings and
  the checker passes: nothing in the staged content or the appended request.
- `git diff --cached --check`, source `request`: clean.
- `bash .git/hooks/pre-commit`, source `request`: clean on the index.

The working-tree transcript also carries one line with the private account
name: the round 4 request record's Markdown command. The hook will refuse it
when the transcript is next staged.

Measured independently: build 176's result and revision through the Jenkins
API; the retained console against the live one; the host retention's reading
and bundle digests; the staged Debian capture against the host's reading; and
the reader digest.

No coverage percentage is claimed; cplx's floor is shell lint.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 4)

The reviewer ran the union of the request validation set and the current
resolver set: the same seven commands, plus the corrected form of the Markdown
gate so the staged content could be judged.

- `bash src/utils/lint_shell.sh`, source `project`. Clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 0 on the
  second attempt.
- The point 4 record verifier, source `request`. Exit 0.
- The Markdown gate, source `request`. Declared with `--root .`, which lints
  llm-shared.
- The Markdown intersection checker, source `request`. Fails on the declared
  log, passes on a cplx log.
- `git diff --cached --check`, source `request`. Clean.
- `bash .git/hooks/pre-commit`, source `request`. Clean on the index.

The reviewer removed each of its own native scratch fixtures after use,
including the one from this round.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 4)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets.

The Markdown gate declaration regressed from the round 3 form
`../llm-shared/markdown-check.bat --root ../cplx` to an absolute home path with
`--root .`. That is not drift, but it both leaks the account name into the
transcript and points the gate at the wrong repository.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 4)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `20e98f6708897030a14926bda7f52c38409a8717` equals the
  baseline at entry and the live index after every run.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `aa8ef02c7c952e36c5dcec44c5366aec5972f0b24ce6d2d132d185defa4198ac`.
  No umbrella row was completed.
- Validation-state comparison over the 9 staged paths, the project command's
  file and the four ignored validation files: `acceptable: true` with empty
  lists.
- The working tree matches its entry state: 9 staged paths, and the transcript
  carries the protocol's unstaged append of this request.
- No reviewer residue in either repository. On the RHEL host the reviewer
  removed its own scratch from earlier review rounds, the failed attempt's
  partial fixture and transfer tar, and this round's fixture. It left the
  writer's fixtures and every retained evidence directory in place.
- The baselines and manifest were written before assessment and the manifest
  rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 4)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 4)

`a.commit` is accurate for the staged set, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 9 staged paths in three
ordered groups matching the request. The installed hook accepts the index.

- Group 1, `fix(tools): normalize candidate verification evidence`: the
  composer, the driver's reader and their fixtures. `fix` fits: both correct
  behavior the real build exposed.
- Group 2, `docs(tools): bind Debian candidate evidence`: the Debian capture,
  its retention, the record and its view.
- Group 3, `docs(tools): record point 4 checkpoint`: the validation plan and
  the umbrella note.

Ordering is least to most dependent and every staged path appears once. The
transcript is not in the plan; when it is staged later, its round 4 request
record needs the home-path fix first.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 4)

Unresolved findings:

- The declared Markdown gate `markdown-check.bat --root .` regressed to an absolute home-directory path and to a root that resolves to llm-shared, because the batch file changes into its own root first: as declared it checks no cplx file and the paired intersection checker fails its own guard, and the path copied into the round 4 request record puts the private account name in the transcript, which the installed hook will refuse once staged.

Boundary-crossing work: None.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 4)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop".

Read `.reviews/a.item7.handoff-prompt.md` as the sequencing context. This
request covers point 4, after the reviewed point 3 checkpoint was committed.
Point 5 (D10 with the agent wheels) and point 6 (publication closure) are
deliberately outside this checkpoint. Step 6 remains checked No. Assess any
defects in the staged work separately from the unfinished later obligations;
do not weaken the completion or publication gates to obtain commit-ready.

The requestor stops after publication, as explicitly instructed by the human.

Guidance response:

The guidance is followed on every point.

- Scope. The review covers point 4 only. D10 with the agent wheels and the
  publication closure are not requested, and Step 6 stays `No`.
- Defects in the staged work, assessed separately from the later
  obligations: the staged code, evidence, record and notes have none. The one
  finding is in the declared validation, not in the staged work.
- No gate was weakened, and none is proposed. The lock refusal stays a
  failure to resolve, not a gate to bypass, and RHEL PA5 and PA6 stay pending
  until repeated against the new consumers.
- No commit, push, build or later point was performed or is authorized.

The disposition is changes-requested because Step 6 is incomplete by design
and because the declared Markdown command must be corrected before the
transcript is committed.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 4)

The staged checkpoint needs no rework. Fix the declared Markdown command, then
continue with the lock refusal.

__Restore the working Markdown declaration.__ Declare
`../llm-shared/markdown-check.bat --root ../cplx`, the form round 3 used. The
batch file changes into the llm-shared root before running, so `--root .`
names llm-shared, and an absolute home path leaks the account name into the
transcript. Before staging the transcript, replace the round 4 request
record's home prefix with the sibling-relative form, then run the hook and the
intersection checker on the final index and require both clean.

__Next: the lock refusal.__ Build 176 shows uv 0.12.17 refusing the committed
`uv.lock` as out of date. Resolve that in the application, for example by
regenerating the lock with the agent's uv version and committing it, then
repeat the candidate build with publication off. The application HEAD has
already moved past the built revision, so the next run will bind new consumer
identities, which is what the pending RHEL PA5 and PA6 reruns need.

__RHEL host space.__ The RHEL host's `/var/tmp` was full during this review.
The reviewer cleared its own scratch, but many fixtures from earlier runs
remain there, and point 5 and the RHEL reruns will need room.

Done well: the failed build was recorded as a failure with its raw console
matching Jenkins byte for byte, the reader repair keeps the raw capture
intact, and the manifest repair is proven byte-identical on Linux by a
fixture that forces the Windows behavior.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 4)

The disposition is changes-requested and the readiness floor is recorded as
incomplete: Step 6 is incomplete by design, and one validation finding
remains.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Fails by design, per the guidance.
3. Validation and coverage. The staged work passes every check that actually
   examines it. The declared Markdown pair examines llm-shared instead.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. One: the Markdown declaration.
6. `a.commit`. Passes, valid and ready, and the hook accepts the index.

This is the third time the Markdown declaration has pointed away from cplx,
and the second time a home path has reached the transcript through a declared
command. The correct form has worked since Step 5 round 5. The finding is
small, but it matters because a validation that silently checks another
repository looks like evidence.

On substance, point 4 did what a checkpoint should: it ran the real build,
kept the failure as a failure, and fixed only the two integration defects the
real build exposed, each with a regression test.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 4)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-4 -->

## Round 5 by requestor - Step 6

- Recorded: 2026-09-19T17:32:21+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 5)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 5

### Code review evidence for step 6 tools-archive-rebuild (round 5)

request_index_tree: 8ec81a121c4a110d7917b12a47362803c02539d2
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: docs(tools): bind Debian candidate evidence
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3: docs(tools): record point 4 checkpoint
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 3 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 4: docs(review): correct point 4 validation declaration
group 4 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 5)

No. Step 6 has NOT been fully implemented.

The handoff point 4 attempt is retained: committed candidate pins were pushed with
publication off; build 176 finished FAILURE; its full console
and archived evidence were retained and independently read on native Linux.
Every Debian cell and available application/runtime identity is bound to that
retained run. Provisioning failed because uv 0.12.17 refused uv.lock under
`uv sync --locked` with CPython 3.13.15. PA1 to PA4 pass; PA5 to PA9 are pending.
No agent wheel inventory or successful venv base capture exists. Their fields
remain pending; the committed lock digest is retained only as input provenance.
Resolve the lock refusal and repeat the candidate build before point 5 D10.
The agent also reports failures in historical diagnostic harnesses, including
the older Python 3.13.9 relocation inventory. Those raw findings are retained
and are not represented as passes by this checkpoint.

Native cumulative step 6 validation passed in 77 seconds, including 61
acceptance fixtures, the inherited suites and 16 release-record tests. The
project shell lint gate passes for 58 tracked scripts. The repaired Git Bash
bundle passes the application's unchanged strict adapter. Record/provenance
checks verify the exact pins, capture hashes, generated view, historical
snapshots and unchanged publication/adoption gates. Full Markdown lint has
existing repository debt; the added-line check records whether new findings
were introduced. No Python coverage percentage is claimed.

The code changes are a linear manifest normalization and one anchored console
prefix normalization. They preserve raw captures and keep production controls
and post-build reader provenance distinct. No new architectural layer or
unbounded processing is introduced. Historical failing evidence remains
retained. Fresh RHEL acceptance for the newly bound consumers, D10 with the
agent wheels, any unresolved Debian cells and the remaining publication
obligations are still required before Step 6 can complete.

Round 5 corrects the declared Markdown root and removes the local account
path from the round 4 transcript command. No production code or retained
build evidence changed after round 4. Full cplx lint retains 39 existing
findings; the added-line check and final staged sensitive-content hook pass.

### Implementation report for step 6 tools-archive-rebuild (round 5)

The composer now explicitly hashes binary bytes and normalizes the binary
marker to the two-space manifest format required by the application adapter.
Build 175 exposed the Git Bash incompatibility and is retained as a failure.
Build 176 used a native bundle from committed cplx source. The shipped archive
identity is unchanged.

The Debian evidence reader removes Jenkins timestamp prefixes for anchored
probe parsing while retaining the raw console byte-for-byte. Regressions cover
binary marker generation, timestamped passing evidence, and timestamped ABI
failure. Both original and repaired readers were run on the real evidence;
their results and exact reader digest are retained separately.

The application reader repairs were committed as 784f33ed. Candidate pins in
application commit 7acda8ac4b35f20ee0bfee2ac27ecfab6afa174e select archive
df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87, verification bundle
dab8bf5036715a45bc21932592923d50d660cb1674adb84111b3630d88fd3b51 and cplx source
72f6cb290700faf328b73d946e78e8fedab8c2cd. Publication remains off.

Recorded Debian cells:

- PA1:debian: pass. candidate relocated without a shim, trailer completed
- PA2:debian: pass. wrapper first-call acceptance met
- PA3:debian: pass. SQLite acceptance role over the pinned archive
- PA4:debian: pass. toolchain git answered --version after relocation
- PA5:debian: pending. not executed in this run
- PA6:debian: pending. not executed in this run
- PA7:debian: pending. not executed in this run
- PA8:debian: pending. not executed in this run
- PA9:debian: pending. not executed in this run

The sidecar, generated acceptance view, validation plan and umbrella record
this checkpoint. Earlier RHEL captures and input snapshots are unchanged.
The earlier RHEL PA5/PA6 passes cannot stand for this application or an
uncaptured agent wheel set, so their current release obligations remain pending.

### Change summary for step 6 tools-archive-rebuild (round 5)

The root a.commit orders the staged work as follows:

1. fix(tools): normalize candidate verification evidence
   - ci/deliver-closure-tools.sh
   - docs/v0.27.0/acceptance.tools-archive-rebuild.sh
   - docs/v0.27.0/verify.tools-release-acceptance.sh
2. docs(tools): bind Debian candidate evidence
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
3. docs(tools): record point 4 checkpoint
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
   - docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md

   The request publication appends its protocol-owned transcript after index
   capture. No cplx point 4 changes are committed by this request.

4. docs(review): correct point 4 validation declaration
   - docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md

The existing transcript through round 4 is staged after correcting only the
reviewer-identified command. Round 5 publication appends after index capture.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 5)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop".

Read `.reviews/a.item7.handoff-prompt.md` as the sequencing context. This
request covers point 4, after the reviewed point 3 checkpoint was committed.
Point 5 (D10 with the agent wheels) and point 6 (publication closure) are
deliberately outside this checkpoint. Step 6 remains checked No. Assess any
defects in the staged work separately from the unfinished later obligations;
do not weaken the completion or publication gates to obtain commit-ready.

The requestor stops after publication, as explicitly instructed by the human.

Writer response:

Accepted the round 4 finding. The Markdown declaration now uses
`../llm-shared/markdown-check.bat --root ../cplx`, preserving the repository
selection after the launcher changes directory. The round 4 transcript's
command uses that same account-free form. The final index includes the
corrected transcript and a matching fourth a.commit group.

No reviewer repairs were staged, and no production repair was reversed.
The code and retained evidence remain exactly as reviewed in round 4.

The user supplied a separate investigation identifying the missing CI lock
URL smudge as the likely cause of build 176's locked-sync refusal. Local
inspection confirms the suggested one-line rewrite also needs coordinated
evidence handling: the reader compares the captured lock digest to the
committed lock bytes. Regenerating dependencies is therefore not adopted as
the presumed fix. Keep --locked and the committed-lock identity gate while
addressing transport URL handling in subsequent application work. Build 175
failed earlier at manifest verification, not at locked synchronization.

This round closes the declaration finding only. No new build was launched,
and the unresolved acceptance cells remain pending. Points 5 and 6 remain
outside this checkpoint; the requestor stops after publication as instructed.

### Reviewer focus for step 6 tools-archive-rebuild (round 5)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-5 -->

## Round 5 by reviewer - Step 6

- Recorded: 2026-09-19T17:38:30+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 5)

Baseline index tree: 8ec81a121c4a110d7917b12a47362803c02539d2

Assessed index tree: 8ec81a121c4a110d7917b12a47362803c02539d2

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 5)

Result:

No. Step 6 has NOT been fully implemented.

The verdict is the expected one: the point 4 candidate build failed at locked
synchronization, so PA5 to PA9 on Debian, the agent's wheels and venv base, the
consumer-bound RHEL reruns, D10 and the publication obligations remain open.

Since round 4 the index has changed only in the review transcript: 498 lines
appended and none removed, holding the round 4 request record and the
reviewer's round 4 answer. The code, record and retained evidence that round 4
verified (build 176 through the Jenkins API, the console byte-identical to
Jenkins, the host reading, the reader digest and both code repairs with their
fixtures) are unchanged, and every declared command was re-run this round.

The round 4 finding is fixed for this round's declaration:

- The request now declares `../llm-shared/markdown-check.bat --root ../cplx`,
  which lints cplx, and the intersection checker passes on its log.
- No line of the working-tree transcript carries the private account name, and
  the installed hook accepts the index with the transcript staged.
- The reviewer's round 4 answer copy is byte-identical to what it rendered, and
  the staged transcript has no duplicate heading.

One accuracy issue remains in how the round 4 record was edited: the recorded
round 4 command now reads `--root ../cplx`, although round 4 declared
`--root .`. The home prefix had to go; the root argument did not, because it
is what round 4 actually ran and what the reviewer's round 4 finding
describes. It is reported below.

The writer's note on the lock refusal is well founded. Keeping `--locked` and
the committed-lock identity gate, and treating build 176's refusal as a
transport URL handling issue to investigate rather than regenerating
dependencies, is the more careful course than the reviewer's round 4 example.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 5)

- Resolve build 176's locked-synchronization refusal without bypassing
  `--locked` or the committed-lock identity check, then repeat the candidate
  build with publication off and capture its lock, wheels and venv base.
- Run PA5 to PA9 on Debian from that build.
- Repeat RHEL PA5 and PA6 against the new consumer inputs.
- Take the D10 reading with the agent's exact wheels.
- Bind the remaining pre-publication obligations and pass the publication
  phase.

Architecture, performance and unit test coverage are unchanged from round 4:
no new code since then, no percentage claimed. No unit-tested class below 100%
needs completing, and no top-level symbol outside the coverage gate is
unreferenced.

Feature integrity: unchanged from round 4; nothing is impaired.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, which is
unchanged since round 4. The Step 6 status sentence is exactly
`No. Step 6 has NOT been fully implemented.`, the `Missing work for Step 6`
section is present, and the document-level line stays
`No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 5)

The reviewer ran all seven resolved commands. All seven behave as expected.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  transport exit 0 in 102 seconds, native `validation exit=0 elapsed=77s`, no
  FAIL line, four helper imports and 61 acceptance cases. The reviewer removed
  its own scratch fixture afterwards; the RHEL host's `/var/tmp` stays at 85%.
- The point 4 record verifier, source `request`: `PASS`, exit 0.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 on the 39
  older findings, as declared.
- The Markdown intersection checker, source `request`: `PASS`, none on lines
  added since HEAD, including this round's appended request.
- `git diff --cached --check`, source `request`: clean.
- `bash .git/hooks/pre-commit`, source `request`: clean, with the transcript
  now staged.

Also verified: no working-tree transcript line carries the private account
name, the staged transcript has no duplicate heading, and the reviewer's round
4 answer copy is byte-identical.

No coverage percentage is claimed; cplx's floor is shell lint.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 5)

The reviewer ran the union of the request validation set and the current
resolver set: the same seven commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 0.
- The point 4 record verifier, source `request`. Exit 0.
- The Markdown gate with `--root ../cplx`, source `request`. Exit 1 on older
  debt only.
- The Markdown intersection checker, source `request`. Exit 0.
- `git diff --cached --check`, source `request`. Clean.
- `bash .git/hooks/pre-commit`, source `request`. Clean.

Every request addition is declared in sibling-relative form and names cplx.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 5)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 5)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `8ec81a121c4a110d7917b12a47362803c02539d2` equals the
  baseline at entry and the live index after every run. Against the round 4
  tree it differs only in the staged review transcript.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `aa8ef02c7c952e36c5dcec44c5366aec5972f0b24ce6d2d132d185defa4198ac`.
- Validation-state comparison over the 10 staged paths, the project command's
  file and the four ignored validation files: `acceptable: true` with empty
  lists.
- The working tree matches its entry state: 10 staged paths, and the
  transcript also carries the protocol's unstaged append of this request.
- No reviewer residue in either repository or on the RHEL host.
- The baselines and manifest were written before assessment and the manifest
  rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 5)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 5)

`a.commit` is mechanically accurate and the reviewer amended nothing, but group
4's message overstates what the transcript edit should be.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 10 staged paths in four
ordered groups matching the request. The installed hook accepts the index.

- Groups 1 to 3 are unchanged from round 4 and remain accurate.
- Group 4, `docs(review): correct point 4 validation declaration`, carries the
  staged transcript. Its body says the round 4 command was corrected "as
  requested by the reviewer". The reviewer asked only for the home prefix to
  be replaced; the corrected declaration belongs to this round's request,
  which already carries it. Once the recorded round 4 command keeps its
  original `--root .`, a subject such as
  `docs(review): redact the point 4 validation path` describes the edit
  accurately. Membership and order do not change.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 5)

Unresolved findings:

- The staged transcript's round 4 request record now shows `../llm-shared/markdown-check.bat --root ../cplx`, but round 4 declared `--root .` and the reviewer's round 4 answer in the same transcript describes that declaration, so the record was changed beyond removing the home prefix and now misstates what round 4 ran; group 4's commit message repeats the claim that the declaration itself was corrected at the reviewer's request.

Boundary-crossing work: None.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 5)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop".

Read `.reviews/a.item7.handoff-prompt.md` as the sequencing context. This
request covers point 4, after the reviewed point 3 checkpoint was committed.
Point 5 (D10 with the agent wheels) and point 6 (publication closure) are
deliberately outside this checkpoint. Step 6 remains checked No. Assess any
defects in the staged work separately from the unfinished later obligations;
do not weaken the completion or publication gates to obtain commit-ready.

The requestor stops after publication, as explicitly instructed by the human.

Guidance response:

The guidance is followed on every point.

- Scope. The review covers point 4 only; points 5 and 6 are not requested, and
  Step 6 stays `No`.
- Defects in the staged work, assessed separately from the later obligations:
  the code, evidence, record and notes have none. The one finding is the edit
  to the round 4 request record in the staged transcript.
- No gate was weakened or proposed to be. The reviewer supports keeping
  `--locked` and the committed-lock identity gate while the lock refusal is
  investigated.
- No commit, push, build or later point was performed or is authorized.

The disposition is changes-requested because Step 6 is incomplete by design
and because of that one record-accuracy finding.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 5)

The code and evidence need no rework. One small transcript correction remains.

__Keep the round 4 record truthful.__ In the staged transcript's round 4
request record, restore the root argument round 4 actually declared while
keeping the home prefix out, so the line reads
`../llm-shared/markdown-check.bat --root . > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)`.
The redaction of the account path is right; the change of `--root .` to
`--root ../cplx` rewrites what round 4 ran, and the reviewer's round 4 answer
in the same transcript describes the original. The corrected declaration
already lives in this round's request. Then describe group 4 as a redaction,
for example `docs(review): redact the point 4 validation path`, and rerun the
hook and the intersection checker on the final index.

__Next: the lock refusal.__ Your investigation is the better lead: keep
`--locked` and the committed-lock identity check, and address the CI lock URL
handling in the application so the agent's uv sees the lock it expects. The
reviewer's round 4 suggestion to regenerate the lock was only an example and
is superseded by that finding.

Done well: the declaration now names cplx in its working form, the account
path is gone from the whole transcript, and the reviewer's answer copy is
untouched.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 5)

The disposition is changes-requested and the readiness floor is recorded as
incomplete: Step 6 is incomplete by design, and one small record-accuracy
finding remains.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Fails by design, per the guidance.
3. Validation and coverage. Passes; all seven declared commands behave as
   expected and now examine cplx.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. One: the round 4 request record's changed root
   argument and the matching group 4 wording.
6. `a.commit`. Mechanically valid and ready; group 4's message needs the same
   correction.

The finding is small, and it is raised for the reason this effort insists on
throughout: a record says what happened. Redacting a private path from a
recorded command is required; changing its arguments to what should have been
declared is a rewrite, and it leaves the transcript contradicting itself. The
fix is two tokens and a commit subject.

On the lock refusal, the reviewer defers to the investigation the writer
cites: it explains the refusal without touching dependencies, and it keeps
every gate in place.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 5)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-5 -->

## Round 6 by requestor - Step 6

- Recorded: 2026-09-19T17:51:23+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 6)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 6

### Code review evidence for step 6 tools-archive-rebuild (round 6)

request_index_tree: aff7f5f8e0817f27bb315da20130b5d8a5df4c6f
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: docs(tools): bind Debian candidate evidence
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3: docs(tools): record point 4 checkpoint
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 3 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 4: docs(review): redact the point 4 validation path
group 4 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 6)

No. Step 6 has NOT been fully implemented.

The handoff point 4 attempt is retained: committed candidate pins were pushed with
publication off; build 176 finished FAILURE; its full console
and archived evidence were retained and independently read on native Linux.
Every Debian cell and available application/runtime identity is bound to that
retained run. Provisioning failed because uv 0.12.17 refused uv.lock under
`uv sync --locked` with CPython 3.13.15. PA1 to PA4 pass; PA5 to PA9 are pending.
No agent wheel inventory or successful venv base capture exists. Their fields
remain pending; the committed lock digest is retained only as input provenance.
Resolve the lock refusal and repeat the candidate build before point 5 D10.
The agent also reports failures in historical diagnostic harnesses, including
the older Python 3.13.9 relocation inventory. Those raw findings are retained
and are not represented as passes by this checkpoint.

Native cumulative step 6 validation passed in 77 seconds, including 61
acceptance fixtures, the inherited suites and 16 release-record tests. The
project shell lint gate passes for 58 tracked scripts. The repaired Git Bash
bundle passes the application's unchanged strict adapter. Record/provenance
checks verify the exact pins, capture hashes, generated view, historical
snapshots and unchanged publication/adoption gates. Full Markdown lint has
existing repository debt; the added-line check records whether new findings
were introduced. No Python coverage percentage is claimed.

The code changes are a linear manifest normalization and one anchored console
prefix normalization. They preserve raw captures and keep production controls
and post-build reader provenance distinct. No new architectural layer or
unbounded processing is introduced. Historical failing evidence remains
retained. Fresh RHEL acceptance for the newly bound consumers, D10 with the
agent wheels, any unresolved Debian cells and the remaining publication
obligations are still required before Step 6 can complete.

Round 6 preserves the historical round 4 root argument while redacting
only its account path. The current declaration continues to name cplx.
No production code or build evidence changed since round 4.

### Implementation report for step 6 tools-archive-rebuild (round 6)

The composer now explicitly hashes binary bytes and normalizes the binary
marker to the two-space manifest format required by the application adapter.
Build 175 exposed the Git Bash incompatibility and is retained as a failure.
Build 176 used a native bundle from committed cplx source. The shipped archive
identity is unchanged.

The Debian evidence reader removes Jenkins timestamp prefixes for anchored
probe parsing while retaining the raw console byte-for-byte. Regressions cover
binary marker generation, timestamped passing evidence, and timestamped ABI
failure. Both original and repaired readers were run on the real evidence;
their results and exact reader digest are retained separately.

The application reader repairs were committed as 784f33ed. Candidate pins in
application commit 7acda8ac4b35f20ee0bfee2ac27ecfab6afa174e select archive
df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87, verification bundle
dab8bf5036715a45bc21932592923d50d660cb1674adb84111b3630d88fd3b51 and cplx source
72f6cb290700faf328b73d946e78e8fedab8c2cd. Publication remains off.

Recorded Debian cells:

- PA1:debian: pass. candidate relocated without a shim, trailer completed
- PA2:debian: pass. wrapper first-call acceptance met
- PA3:debian: pass. SQLite acceptance role over the pinned archive
- PA4:debian: pass. toolchain git answered --version after relocation
- PA5:debian: pending. not executed in this run
- PA6:debian: pending. not executed in this run
- PA7:debian: pending. not executed in this run
- PA8:debian: pending. not executed in this run
- PA9:debian: pending. not executed in this run

The sidecar, generated acceptance view, validation plan and umbrella record
this checkpoint. Earlier RHEL captures and input snapshots are unchanged.
The earlier RHEL PA5/PA6 passes cannot stand for this application or an
uncaptured agent wheel set, so their current release obligations remain pending.

### Change summary for step 6 tools-archive-rebuild (round 6)

The root a.commit orders the staged work as follows:

1. fix(tools): normalize candidate verification evidence
   - ci/deliver-closure-tools.sh
   - docs/v0.27.0/acceptance.tools-archive-rebuild.sh
   - docs/v0.27.0/verify.tools-release-acceptance.sh
2. docs(tools): bind Debian candidate evidence
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
3. docs(tools): record point 4 checkpoint
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
   - docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md

   The request publication appends its protocol-owned transcript after index
   capture. No cplx point 4 changes are committed by this request.

4. docs(review): redact the point 4 validation path
   - docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md

The transcript through round 5 is staged with the historical round 4 root
argument restored. Round 6 publication appends after index capture.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 6)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop".

Read `.reviews/a.item7.handoff-prompt.md` as the sequencing context. This
request covers point 4, after the reviewed point 3 checkpoint was committed.
Point 5 (D10 with the agent wheels) and point 6 (publication closure) are
deliberately outside this checkpoint. Step 6 remains checked No. Assess any
defects in the staged work separately from the unfinished later obligations;
do not weaken the completion or publication gates to obtain commit-ready.

The requestor stops after publication, as explicitly instructed by the human.

Writer response:

Accepted the round 5 record-accuracy finding. The round 4 request record
again declares --root ., which is what that round actually ran. Only the
private launcher path is redacted. The current declaration retains the
working --root ../cplx form. Group 4 now describes the historical redaction,
not a correction to what round 4 ran. Membership and order are unchanged.

There were no reviewer-staged repairs and no reversals of production fixes.
The code and retained evidence remain as independently verified in round 5.

The user asked whether a new Jenkins build could test recent fixes. Checking
origin3 develop found application commit 812e794934be08f921f2d82a224220de4c1c9c15.
The provisioning code still has no lock URL rewrite before uv sync --locked.
The recent changes corrected review declarations only. No expensive unchanged
build was launched; a coordinated application fix preserving committed-lock
identity is still needed before a run can test resolution. No dependency
regeneration, gate bypass, commit, push or later handoff point was performed.

### Reviewer focus for step 6 tools-archive-rebuild (round 6)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-6 -->

## Round 6 by reviewer - Step 6

- Recorded: 2026-09-19T17:55:47+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 6)

Baseline index tree: aff7f5f8e0817f27bb315da20130b5d8a5df4c6f

Assessed index tree: aff7f5f8e0817f27bb315da20130b5d8a5df4c6f

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 6)

Result:

No. Step 6 has NOT been fully implemented.

The verdict is the expected one: the point 4 candidate build failed at locked
synchronization, so PA5 to PA9 on Debian, the agent's wheels and venv base, the
consumer-bound RHEL reruns, D10 and the publication obligations remain open.
Within point 4 the checkpoint is complete and correct.

Since round 5 the index has changed only in the review transcript: 484 lines
appended (the round 5 request record and the reviewer's round 5 answer) and
one line changed. The code, record and retained evidence verified in round 4
are unchanged, and every declared command was re-run this round.

The round 5 finding is fixed, verified rather than accepted:

- The round 4 request record's Markdown command again reads `--root .`, what
  round 4 actually declared, with only the home prefix replaced by the
  sibling-relative form. The transcript no longer contradicts itself.
- Group 4 of `a.commit` is now `docs(review): redact the point 4 validation
  path`, which describes the edit accurately.
- The reviewer's round 5 answer copy is byte-identical to what it rendered,
  no transcript line carries the private account name, and no heading
  repeats.

The writer's decision not to launch an unchanged build is sound: the pushed
application still has no lock URL rewrite before `uv sync --locked`, so a new
run could only repeat build 176's refusal.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 6)

- Add the coordinated application fix for the lock URL handling while keeping
  `--locked` and the committed-lock identity check, then repeat the candidate
  build with publication off and capture its lock, wheels and venv base.
- Run PA5 to PA9 on Debian from that build.
- Repeat RHEL PA5 and PA6 against the new consumer inputs.
- Take the D10 reading with the agent's exact wheels.
- Bind the remaining pre-publication obligations and pass the publication
  phase.

Architecture, performance and unit test coverage are unchanged from round 4:
no new code since then, no percentage claimed. No unit-tested class below 100%
needs completing, and no top-level symbol outside the coverage gate is
unreferenced.

Feature integrity: unchanged from round 4; nothing is impaired.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, which is
unchanged since round 4. The Step 6 status sentence is exactly
`No. Step 6 has NOT been fully implemented.`, the `Missing work for Step 6`
section is present, and the document-level line stays
`No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 6)

The reviewer ran all seven resolved commands. All seven behave as expected.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  transport exit 0 in 104 seconds, native `validation exit=0 elapsed=82s`, no
  FAIL line, four helper imports and 61 acceptance cases. The reviewer removed
  its own scratch fixture afterwards.
- The point 4 record verifier, source `request`: `PASS`, exit 0.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 on the 39
  older findings, as declared.
- The Markdown intersection checker, source `request`: `PASS`, none on lines
  added since HEAD, including this round's appended request.
- `git diff --cached --check`, source `request`: clean.
- `bash .git/hooks/pre-commit`, source `request`: clean.

Also verified: the round 5 to round 6 index difference is the transcript only,
its single changed line is the restored `--root .`, the reviewer's round 5
answer copy is byte-identical, no working-tree transcript line carries the
private account name, and no heading repeats.

No coverage percentage is claimed; cplx's floor is shell lint.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 6)

The reviewer ran the union of the request validation set and the current
resolver set: the same seven commands, all clean or, for the full Markdown gate,
exiting on older debt only.

- `bash src/utils/lint_shell.sh`, source `project`.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`.
- The point 4 record verifier, source `request`.
- The Markdown gate with `--root ../cplx`, source `request`.
- The Markdown intersection checker, source `request`.
- `git diff --cached --check`, source `request`.
- `bash .git/hooks/pre-commit`, source `request`.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 6)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 6)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `aff7f5f8e0817f27bb315da20130b5d8a5df4c6f` equals the
  baseline at entry and the live index after every run. Against the round 5
  tree it differs only in the staged review transcript.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `aa8ef02c7c952e36c5dcec44c5366aec5972f0b24ce6d2d132d185defa4198ac`.
- Validation-state comparison over the 10 staged paths, the project command's
  file and the four ignored validation files: `acceptable: true` with empty
  lists.
- The working tree matches its entry state: 10 staged paths, and the
  transcript also carries the protocol's unstaged append of this request.
- No reviewer residue in either repository or on the RHEL host.
- The baselines and manifest were written before assessment and the manifest
  rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 6)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 6)

`a.commit` is accurate and executable, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 10 staged paths in four
ordered groups matching the request. The installed hook accepts the index.

- Groups 1 to 3 are unchanged since round 4 and remain accurate.
- Group 4, `docs(review): redact the point 4 validation path`, now describes
  the transcript edit as what it is.

When the owning workflow stages this answer's protocol append into group 4,
run the hook and the intersection checker once more on the final index.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 6)

Unresolved findings: None.

Boundary-crossing work: None.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 6)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop".

Read `.reviews/a.item7.handoff-prompt.md` as the sequencing context. This
request covers point 4, after the reviewed point 3 checkpoint was committed.
Point 5 (D10 with the agent wheels) and point 6 (publication closure) are
deliberately outside this checkpoint. Step 6 remains checked No. Assess any
defects in the staged work separately from the unfinished later obligations;
do not weaken the completion or publication gates to obtain commit-ready.

The requestor stops after publication, as explicitly instructed by the human.

Guidance response:

The guidance is followed on every point.

- Scope. The review covers point 4 only; points 5 and 6 are not requested, and
  Step 6 stays `No`.
- Defects in the staged work, assessed separately from the later obligations:
  none. The round 5 record-accuracy finding is fixed, and no finding remains.
- No gate was weakened or proposed to be; the lock refusal stays a failure to
  fix in the application, with `--locked` and the committed-lock identity
  check kept.
- No commit, push, build or later point was performed or is authorized.

The disposition is changes-requested only because the shared rule ties a
commit-ready recommendation to a complete step, and Step 6 is incomplete by
design. The point 4 checkpoint is ready to commit through the owning workflow
if the human chooses to, as the earlier Step 6 checkpoints were.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 6)

No rework is needed. The point 4 checkpoint is ready to commit through the
owning workflow if the human chooses to. Stage this answer's protocol append
into group 4 and run the hook and the intersection checker once more on the
final index before committing.

After that, per the handoff: make the coordinated application change for the
lock URL handling, keeping `--locked` and the committed-lock identity check,
then repeat the candidate build with publication off.

Done well across point 4: the failed build was recorded as a failure and
matched against Jenkins, both integration repairs came with regression tests,
no build was spent on an unchanged input, and every record correction was
confined to what the review reported.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 6)

The disposition is changes-requested and the readiness floor is recorded as
incomplete, for one reason only: Step 6 is incomplete by design. Every other
readiness result passes, and no finding remains.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Fails by design, per the guidance.
3. Validation and coverage. Passes; all seven declared commands behave as
   expected and examine cplx.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. None.
6. `a.commit`. Passes, valid, ready and accepted by the hook.

The reviewer does not bend the completeness rule for a partial checkpoint, and
states instead what it means here: nothing is left for the writer to rework,
and the point 4 evidence is ready to commit.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 6)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-6 -->

## Round 7 by requestor - Step 6

- Recorded: 2026-09-19T20:16:58+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 7)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 7

### Code review evidence for step 6 tools-archive-rebuild (round 7)

request_index_tree: bda08b9a786f08de4e0dff8ad55b3c52252fbef7
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-retry-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: docs(tools): bind Debian candidate evidence
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3: docs(tools): record point 4 checkpoint
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 3 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 4: docs(review): redact the point 4 validation path
group 4 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 7)

No. Step 6 has NOT been fully implemented.

This request is the handoff point 4 checkpoint after the human reported the
application lock fix pushed as 6b43b39e. Build 177 checked out that exact
commit with publication off. Its lock transport identity check passed for
83 packages and 491 artifacts. uv 0.12.17 completed uv sync --locked with
CPython 3.13.15, installing 80 packages and capturing the venv base.
The lock-URL refusal from build 176 is resolved.

Build 177 nevertheless finished FAILURE: exact wheel capture refused
playwright-1.60.0.dist-info. Package and Test were skipped. The console and
all 24 archived artifacts were retained and independently read on native
Linux. PA1-PA4 pass; PA5-PA9 remain pending. Agent wheels and the archived
agent lock remain missing. The committed lock digest is provenance only.
The new application-side capture blocker must be fixed before another build;
a successful venv base alone does not establish PA6 or permit point 5 D10.

Production code and regression fixtures are unchanged since round 4. The
manifest normalization and anchored timestamp parsing preserve strict input
checks and raw evidence, add no architecture layer, and remain linear in
their inputs. Feature integrity is unchanged. No new class or uncovered
production symbol is introduced and no coverage percentage is claimed.

Validation includes the project shell lint floor (58 scripts), the native
cumulative Step 6 suite (exit 0 in 77 seconds), the new exact build-177 record/provenance verifier,
the commit-plan check and staged hook. Full Markdown lint retains 39 existing
findings; none intersects added lines. Original build 176 sidecars and all
earlier RHEL capture bytes remain unchanged. Publication, adoption and source
authority are unchanged. Current historical RHEL PA5/PA6 obligations remain
pending with their original input snapshots preserved.

The validation plan retains its No result and explicit missing work:
application wheel capture, PA5-PA9 Debian, consumer-bound RHEL acceptance,
D10 with agent wheels and remaining pre-publication obligations. The current
checkpoint does not waive the finished-step rule for commit readiness.

### Implementation report for step 6 tools-archive-rebuild (round 7)

The staged integration repairs are unchanged: normalize Git Bash binary hash
markers in candidate manifests; strip Jenkins timestamps from the parser's
view while preserving the raw console; retain regression cases for passing
and failing timestamped evidence and binary-marker manifests.

This round adds two build-177 sidecars and binds their digests, application
and pipeline revision, Debian environment, venv base and all nine Debian
cells in the acceptance record. The generated view, validation plan and
umbrella now distinguish the resolved lock-URL issue from the remaining exact
wheel-capture failure. The commit plan includes both new sidecars.

Build 177 used application/pipeline revision
6b43b39ef60cd9ff895986492cd94dbeee81b569, archive
df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87,
bundle dab8bf5036715a45bc21932592923d50d660cb1674adb84111b3630d88fd3b51
and cplx source 72f6cb290700faf328b73d946e78e8fedab8c2cd.
Publication stayed off. The application fix itself was committed and pushed
by the sibling project; this cplx round does not change its source.

The raw console SHA-256 is
d4a76cd621662e6ff686a44fc1f03165f1458a66d4ffe9fa20dc977339e5a2f6.
The native reading archive SHA-256 is
baf7e379c674c7d84742a5c78332fe489ac71f9b9bfa6be60ad163525db8ae73.
Both original and repaired readers ran; the repaired reading is incomplete
with four passes and five pending cells. Historical diagnostic failures are
retained separately and are not turned into candidate acceptance passes.

The unchanged build-176 sidecars and earlier RHEL snapshots remain bound as
historical evidence. The new captures sanitize agent home/workspace prefixes
and omit the executor name; raw result and artifact digests are retained.
No D10 reading, publication closure, adoption, or cplx commit was performed.

### Change summary for step 6 tools-archive-rebuild (round 7)

The root a.commit groups all 12 staged paths in this order:

1. fix(tools): normalize candidate verification evidence
   - ci/deliver-closure-tools.sh
   - docs/v0.27.0/acceptance.tools-archive-rebuild.sh
   - docs/v0.27.0/verify.tools-release-acceptance.sh
2. docs(tools): bind Debian candidate evidence
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
3. docs(tools): record point 4 checkpoint
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
   - docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
4. docs(review): redact the point 4 validation path
   - docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md

The transcript through round 6 is staged. Round 7 publication appends its
protocol-owned request after index capture. No cplx commit is authorized by
this request.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 7)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop". They subsequently
authorized a new Jenkins build and reported the coordinated application fix
committed and pushed as 6b43b39e on develop.

Read `.reviews/a.item7.handoff-prompt.md` as the sequencing context. This
request covers point 4. Point 5 (D10 with agent wheels) and point 6
(publication closure) remain outside this checkpoint. Step 6 remains No.
Assess defects in the staged work separately from later unfinished
obligations; do not weaken completion or publication gates for commit-ready.

The requestor stops immediately after publishing round 7 as instructed.

Writer response:

Round 6 reported no unresolved findings and no reviewer repairs. Its
changes-requested disposition came only from Step 6 being unfinished by
design. The historical round 4 root argument and its account-path redaction
remain as accepted; no transcript history was rewritten in this round.

The human then reported the application lock fix committed and pushed as
6b43b39e. Under the existing authorization for a new candidate build, the
requestor verified publication-off mode and the pushed revision, then ran
build 177. That provides new reviewed evidence, hence reviewed-work-changed
is true even though no production code changed. There is no disagreement or
reversal of a reviewer repair.

The new evidence resolves the lock-URL refusal and establishes a separate
application-side blocker: ci/tools_wheel_capture.py refused the installed
Playwright identity after successful synchronization. The diagnostic does
not distinguish an absent match from an ambiguous match; no unsupported root
cause is asserted. A focused handoff is prepared for the human to pass to
the application project. No message was sent to another project or reviewer.

The root a.commit retains its four ordered groups, adding the new sidecars
to the Debian evidence group and updating the outcome wording. Current
evidence and pending obligations are accurate without promoting Step 6 to
complete or permitting point 5 before its required agent wheels exist.

### Reviewer focus for step 6 tools-archive-rebuild (round 7)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-7 -->

## Round 7 by reviewer - Step 6

- Recorded: 2026-09-19T20:24:45+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 7)

Baseline index tree: bda08b9a786f08de4e0dff8ad55b3c52252fbef7

Assessed index tree: bda08b9a786f08de4e0dff8ad55b3c52252fbef7

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 7)

Result:

No. Step 6 has NOT been fully implemented.

The verdict is the expected one. Build 177 resolved the lock refusal but
failed at exact wheel capture, so PA5 to PA9 on Debian, the agent wheels, the
consumer-bound RHEL reruns, D10 and the publication obligations remain open.
Within point 4 the checkpoint is accurate.

Verified rather than accepted:

- Build 177. The Jenkins API reports `FAILURE`, built from application commit
  `6b43b39e`, the recorded application and pipeline revision. The live
  console's SHA-256 equals the recorded `d4a76cd6...a2f6`, and it shows the
  lock transport identity check preserving 83 packages and 491 artifacts,
  83 packages resolved, 80 installed, and then "Wheel capture refused: locked
  wheel identity absent or ambiguous: playwright-1.60.0.dist-info".
- The record. The nine Debian cells move from build 176 to build 177 with the
  same states: PA1 to PA4 pass and PA5 to PA9 pending. The consumers now name
  `6b43b39e` and the captured venv base, with wheels and the agent lock still
  pending. Both build 176 sidecars stay versioned and unchanged, RHEL PA5 and
  PA6 keep their original run and input snapshot with only their reason text
  updated, and the original candidate is unchanged. The record verifier ties
  the build 177 sidecars to the retained raw reading byte for byte.
- The umbrella note and validation rows now distinguish the resolved lock-URL
  refusal from the new capture failure, accurately.
- The staged code and fixtures are unchanged since round 4, and the transcript
  only gained the round 6 records: nothing removed, the reviewer's round 6
  answer copy byte-identical, no private identifier, no repeated heading.

The reviewer also isolated the capture failure, which the writer
deliberately did not guess at. The capture script matches an installed
distribution by the exact tag set in its `WHEEL` metadata against the tag set
parsed from each locked wheel filename. The Linux x86_64 wheel the lock pins
is `playwright-1.60.0-py3-none-manylinux1_x86_64.whl`, whose filename tag set
is `py3-none-manylinux1_x86_64`. The installed Playwright 1.60.0 in the RHEL
verification archive, installed from that same lock-pinned file, declares
`Tag: py3-none-any` in its `WHEEL` metadata. The package's metadata disagrees
with its own platform filename, so no locked key matches: the "absent" branch
of the refusal. The fix belongs to the application's capture script, not to the
lock or to cplx.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 7)

- Make the application's wheel capture identify a wheel whose `WHEEL` tags
  disagree with its filename, without weakening the one-exact-match rule, then
  repeat the candidate build with publication off and capture the agent wheels
  and lock.
- Run PA5 to PA9 on Debian from that build.
- Repeat RHEL PA5 and PA6 against the new consumer inputs.
- Take the D10 reading with the agent's exact wheels.
- Bind the remaining pre-publication obligations and pass the publication
  phase.

Architecture, performance and unit test coverage are unchanged from round 4:
no new code since then, no percentage claimed. No unit-tested class below 100%
needs completing, and no top-level symbol outside the coverage gate is
unreferenced.

Feature integrity: unchanged from round 4; nothing is impaired.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows match this assessment. The status sentence is exactly
`No. Step 6 has NOT been fully implemented.`, the `Missing work for Step 6`
section names the application wheel capture as the next blocker, and the
document-level line stays `No, it is not implemented.` The reviewer's
Playwright diagnosis is offered in this answer for the application-side fix;
it does not require a validation-row change in cplx.

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 7)

The reviewer ran all seven resolved commands. All seven behave as expected.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  transport exit 0 in 99 seconds, native `validation exit=0 elapsed=77s`, no
  FAIL line, four helper imports and 61 acceptance cases. The reviewer removed
  its own scratch fixture afterwards.
- The build 177 record verifier, source `request`: both `PASS` lines, exit 0.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 on the 39
  older findings, as declared.
- The Markdown intersection checker, source `request`: `PASS`, none on lines
  added since HEAD.
- `git diff --cached --check`, source `request`: clean.
- `bash .git/hooks/pre-commit`, source `request`: clean.

Measured independently: build 177's result and revision through the Jenkins
API and its live console digest and key lines; the record's changes against
the round 6 tree; the transcript's round 6 additions; and, on the RHEL host,
the installed Playwright 1.60.0 `WHEEL` metadata, compared with the lock's
Playwright wheel filenames at `6b43b39e` and with the capture script's matching
rule.

No coverage percentage is claimed; cplx's floor is shell lint.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 7)

The reviewer ran the union of the request validation set and the current
resolver set: the same seven commands, all clean or, for the full Markdown gate,
exiting on older debt only.

- `bash src/utils/lint_shell.sh`, source `project`.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`.
- The build 177 record verifier, source `request`.
- The Markdown gate with `--root ../cplx`, source `request`.
- The Markdown intersection checker, source `request`.
- `git diff --cached --check`, source `request`.
- `bash .git/hooks/pre-commit`, source `request`.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 7)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 7)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `bda08b9a786f08de4e0dff8ad55b3c52252fbef7` equals the
  baseline at entry and the live index after every run.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `cd77192fcd2d8d32456d32781b9170ae2ac7e9966abe7097273c7866ebe97d2a`.
  No umbrella row was completed.
- Validation-state comparison over the 12 staged paths, the project command's
  file and the four ignored validation files: `acceptable: true`, naming only
  the ignored Markdown log that the declared command rewrites.
- The working tree matches its entry state: 12 staged paths, and the
  transcript also carries the protocol's unstaged append of this request.
- No reviewer residue in either repository or on the RHEL host.
- The baselines and manifest were written before assessment and the manifest
  rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 7)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 7)

`a.commit` is accurate and executable, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 12 staged paths in four
ordered groups matching the request. The installed hook accepts the index.

- Group 1 is unchanged since round 4 and accurate.
- Group 2 now also carries both build 177 sidecars next to the unchanged
  build 176 ones, the record and its view.
- Group 3 carries the validation plan and umbrella note, both updated for the
  capture failure.
- Group 4 carries the staged transcript through round 6.

When the owning workflow stages this answer's protocol append into group 4,
run the hook and the intersection checker once more on the final index.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 7)

Unresolved findings: None.

Boundary-crossing work: None.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 7)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop". They subsequently
authorized a new Jenkins build and reported the coordinated application fix
committed and pushed as 6b43b39e on develop.

Read `.reviews/a.item7.handoff-prompt.md` as the sequencing context. This
request covers point 4. Point 5 (D10 with agent wheels) and point 6
(publication closure) remain outside this checkpoint. Step 6 remains No.
Assess defects in the staged work separately from later unfinished
obligations; do not weaken completion or publication gates for commit-ready.

The requestor stops immediately after publishing round 7 as instructed.

Guidance response:

The guidance is followed on every point.

- Scope. The review covers point 4 only; points 5 and 6 are not requested, and
  Step 6 stays `No`.
- Defects in the staged work, assessed separately from the later obligations:
  none. The build 177 evidence, record, notes and transcript are accurate.
- No gate was weakened or proposed to be. The recommended application fix
  keeps the capture's one-exact-match rule; it only has to recognize a wheel
  whose metadata tags disagree with its own filename.
- No commit, push, build or later point was performed or is authorized.

The disposition is changes-requested only because Step 6 is incomplete by
design. The point 4 checkpoint is ready to commit through the owning workflow
if the human chooses to.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 7)

No rework is needed in cplx. The point 4 checkpoint is ready to commit through
the owning workflow if the human chooses to; stage this answer's protocol
append into group 4 and rerun the hook and the intersection checker first.

__For the application handoff: the Playwright refusal is a tag mismatch.__
`ci/tools_wheel_capture.py` keys each installed distribution by the exact tag
set in its `WHEEL` metadata and each locked wheel by the tag set in its
filename. Playwright 1.60.0's Linux x86_64 file is
`playwright-1.60.0-py3-none-manylinux1_x86_64.whl`, but the installed copy
declares `Tag: py3-none-any` (measured on the RHEL verification archive, which
installed that lock-pinned file). No locked key has that tag set, so the
capture reports the identity absent. A fix that keeps the gate strict would
fall back, only when the exact tag match finds nothing, to the locked wheels of
the same name, version and build, choose the ones whose filename tags the
running interpreter supports, and still require exactly one. Pass this
diagnosis with the handoff so the next build tests a fix rather than a guess.

Then repeat the candidate build with publication off, capture the agent wheels
and lock, and continue with PA5 to PA9 on Debian and the RHEL reruns.

Done well: the lock fix was confirmed by a real build rather than assumed, the
new failure was recorded without an invented cause, and both builds' evidence
is kept side by side.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 7)

The disposition is changes-requested and the readiness floor is recorded as
incomplete, for one reason only: Step 6 is incomplete by design. Every other
readiness result passes, and no finding remains.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Fails by design, per the guidance.
3. Validation and coverage. Passes; all seven declared commands behave as
   expected.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. None.
6. `a.commit`. Passes, valid, ready and accepted by the hook.

Build 177 moved point 4 forward by one real blocker. Its lock check and locked
synchronization now pass, so the failure is later and narrower. The reviewer
spent its extra effort on the one question the record left open: why the
capture refused Playwright. The answer is a metadata inconsistency inside the
Playwright wheel, measured rather than inferred, and it points at a strict,
bounded fix in the application.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 7)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-7 -->

## Round 8 by requestor - Step 6

- Recorded: 2026-09-19T21:39:19+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 8)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 8

### Code review evidence for step 6 tools-archive-rebuild (round 8)

request_index_tree: b92f2063de8be6473ae1f65b41ec65430a65ace5
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r8-verify-record.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: test(tools): cover ranked wheel metadata fallback
group 2 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 3: docs(tools): bind Debian candidate evidence
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 4: docs(tools): record point 4 checkpoint
group 4 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 5: docs(review): redact the point 4 validation path
group 5 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 8)

Round 7 requested changes with no unresolved findings or reviewer repairs.
Its checkpoint assessment is accepted without disagreement. Step 6 remains
No and its documentation state remains not implemented. This is the next
point 4 checkpoint, not a request to waive the finished-step commit gate.

Build 178 used application 68ef3af9 and unchanged committed candidate pins,
with publication off. Locked synchronization and all 80 wheel selections and
downloads succeeded. The Playwright generic-tag fix is confirmed on Linux.
All downloaded wheel hashes match the canonical committed application lock.

The build failed next in the delivered cplx inventory helper:
INCONCLUSIVE: ELF outside site-packages: ty-0.0.37.data/scripts/ty.
Its installed_name mapping supports purelib/platlib but excludes scripts.
Downloaded ruff and uv wheels also carry script ELFs. The repair belongs to
the cplx inventory contract, with coordinated application invocation for the
installed scripts root. No ELF was skipped and no acceptance gate weakened.
That repair and a newly committed verification bundle remain missing work.

The independent native reader binds PA1 through PA4 passing and PA5 through
PA9 pending. Pipeline failure is not converted into invented failed cells.
No completed inventory, wheels.tar.gz or archived agent lock was produced.
Raw downloaded wheels do not establish installed byte equality. Point 4
remains incomplete; point 5 D10 and point 6 publication closure follow later.

All four earlier Debian sidecars, historical RHEL captures and original
input snapshots are unchanged. Historical consumer-dependent passes remain
pending for the new application. Source authority, publication and adoption
gates are unchanged. No cplx commit is authorized.

### Implementation report for step 6 tools-archive-rebuild (round 8)

The staged checkpoint contains 15 paths in five a.commit groups. Existing
manifest portability and timestamp parsing repairs remain unchanged. The new
fixture accommodates the application's generic-tag fallback while checking
ranked selection, exact-match precedence, unsupported platforms, ties and
absent releases. No application source was modified.

Build 178 and all 104 archived artifacts, including 80 raw wheels, were
retained with hashes. Native Linux independently read the raw evidence using
the original bundled reader and repaired timestamp-aware reader. The latter
reports four passes and five pending cells. Two new versioned sidecars bind
the raw reading, transport, artifact digests, source pins and new blocker.
The acceptance JSON and generated Markdown now bind build 178. Validation
and umbrella notes identify the cplx installed-script inventory limitation.

Validation completed:

- Native cumulative suite passed in 78 seconds with independent Python 3.9.25.
  Its record, D10 fixture, helper-import, agent fixture, acceptance and installer
  checks passed. This fixture run does not execute handoff point 5 D10.
- The new application import requires packaging; authoring transport supplies
  lock-pinned packaging 26.2 as a hash-verified wheel on temporary PYTHONPATH.
  The first missing dependency and obsolete fixture failures remain retained.
- Canonical application uv.lock transport was checked byte-for-byte on Linux.
- All 80 downloaded wheels independently match canonical locked SHA-256s.
- The exact record verifier passed: nine cells, pins, every raw artifact hash,
  preserved prior sidecars and RHEL snapshots, generated view and release gates.
- Project shell lint passed for 58 scripts. git diff --cached --check passed.
- Full Markdown check has 39 existing diagnostics; none intersects added lines.
  No baseline or rule was relaxed. The full repository check remains non-green.
- Sensitive-content pre-commit hook passed after redacting a project name in
  the appended round 7 transcript. Its historical meaning is preserved.
- commit-plan-check reports five valid groups matching the staged paths.

Jenkins failed during inventory; Package, Test and Publish were skipped.
Neither full Jenkins success nor coverage is claimed. The native helper's
refusal is preserved and explicitly recorded as unresolved cplx work.

### Change summary for step 6 tools-archive-rebuild (round 8)

Since round 7, verified application fix 68ef3af9 and ran Jenkins build 178
once with publication off. Playwright wheel identification now passes.
Retained all 104 artifacts and independently bound the new Debian result.
Documented the next failure: cplx does not map wheel .data/scripts ELF files
to their installed venv destinations. PA1-PA4 pass; PA5-PA9 remain pending.

Updated the generic wheel metadata fixture to the new application contract
without weakening refusals. Preserved all build 176/177 captures and RHEL
history. Updated the acceptance view, missing work and umbrella checkpoint.
Redacted one sensitive project name from the appended historical transcript
after the pre-commit hook identified it. No reviewer repair was reversed.

Step 6 remains incomplete. Stop after publishing this round as requested.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 8)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop". They subsequently
asked to address round 7 and prepare round 8, explicitly authorizing another
Jenkins build after application commit 68ef3af9 was pushed.

Read .reviews/a.item7.handoff-prompt.md as the sequencing context. This
request covers point 4. Point 5 D10 and point 6 publication closure remain
later handoff work. Step 6 remains No. Assess staged defects separately from
unfinished later obligations; do not weaken readiness or publication gates.

The requestor stops immediately after publishing round 8. No cplx commit is
authorized by this request.

Writer response:

Round 7 has no unresolved findings and made no reviewer repairs. Its
assessment of the point 4 checkpoint is accepted. No repair was reversed and
there is no disagreement. Step 6 remains incomplete; this request does not
waive the finished-step rule.

The application project supplied commit 68ef3af9 in response to the measured
Playwright metadata mismatch. The writer verified that exact commit on the
CI remote, its unchanged candidate pins and publication-off setting, and
triggered build 178 once. This round binds the resulting evidence; the build
outcome and remaining cells are detailed in the assessment and report.

The native cumulative check initially stopped because the application helper
now imports packaging, absent from the independent system Python. The helper
runs in the synchronized candidate venv in Jenkins. For the authoring check,
the transport now supplies packaging 26.2 as a temporary pure-Python wheel on
the independent Python 3.9 import path. Its SHA-256 was checked against the
exact application lock. No import check or production gate was removed, and
the system site-packages were not changed. The original failed log is retained.

Once imports ran, the older absent-wheel-tag fixture rejected the behavior
the application fix intentionally supports. The writer updated that fixture
to assert the ranked generic-tag fallback and exact-match precedence, with
explicit unsupported-platform, tied-choice and absent-release refusals.
These are cplx test-contract changes; no application source or acceptance
gate was edited.

The native source transport also carries the exact committed uv.lock blob
instead of git archive's locally smudged lock, plus the root metadata blobs
needed for Git object validation. Native git show was checked byte for byte
against the transported canonical lock before reading the Jenkins evidence.

Reviewed work changed because this round adds new build evidence and updates
its current bindings and checkpoint notes. Earlier captures remain retained.

Build 178 confirms the application fix. The next refusal is owned by cplx:
the inventory does not support script ELFs outside site-packages. This is
explicit missing work, not a new finding attributed to the round 7 reviewer.
Neither wheel selection nor download hashing proves installed byte equality.
The sensitive-content hook also required redacting one project name in the
appended round 7 transcript; the historical statement is otherwise preserved.

### Reviewer focus for step 6 tools-archive-rebuild (round 8)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-8 -->

## Round 8 by reviewer - Step 6

- Recorded: 2026-09-19T21:47:16+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 8)

Baseline index tree: b92f2063de8be6473ae1f65b41ec65430a65ace5

Assessed index tree: b92f2063de8be6473ae1f65b41ec65430a65ace5

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 8)

Result:

No. Step 6 has NOT been fully implemented.

The verdict is the expected one. Build 178 resolved the Playwright refusal but
failed in the cplx wheel inventory, so PA5 to PA9 on Debian, the agent wheels
and lock, the consumer-bound RHEL reruns, D10 and the publication obligations
remain open.

Verified rather than accepted:

- Build 178. The Jenkins API reports `FAILURE`, built from application commit
  `68ef3af9`, the recorded application and pipeline revision. The live
  console's SHA-256 equals the one both build 178 sidecars record, and it shows
  the lock transport check, 80 packages installed, and then
  "wheel inventory: INCONCLUSIVE: ELF outside site-packages:
  ty-0.0.37.data/scripts/ty". The Playwright identification that failed in
  build 177 no longer stops the build.
- The record. The nine Debian cells now bind build 178 (PA1 to PA4 pass, PA5
  to PA9 pending), all four earlier Debian sidecars and every RHEL capture are
  unchanged, and the record verifier ties the new sidecars to the retained raw
  reading byte for byte.
- The fixture change. The agent fixture now asserts the application's ranked
  generic-tag fallback, exact-match precedence, and refusals for an
  unsupported platform, a tie and an absent release; all five pass natively.
  It supplies explicit platform tags, so its verdicts do not depend on the
  host.
- The transcript. Its round 7 additions are appended with nothing earlier
  removed; the redaction the writer made was in the requestor's own round 7
  request record, the reviewer's round 7 answer copy is byte-identical, and no
  private identifier or repeated heading remains.

What the validation does not show. From `68ef3af9` the application's
`ci/tools_wheel_capture.py` imports `packaging.tags` at module level and runs in
the candidate venv. The committed cplx runner still imports it with the
independent interpreter (`verify.tools-archive-rebuild.sh`, line 61), and the
staged agent fixture loads it too. The RHEL host's `/usr/bin/python3` 3.9.25
has no `packaging` module. The declared run passes only because the ignored
native script exports `PYTHONPATH` to a lock-pinned `packaging` wheel for the
whole run. The runner as the plan names it,
`verify.tools-archive-rebuild.sh --step 6 --python /usr/bin/python3`, would
fail at the helper import without that. The committed runner and plan should
own this dependency explicitly.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 8)

- Make the committed runner own the capture helper's third-party dependency:
  either supply the hash-verified, lock-pinned `packaging` wheel itself, scoped
  to the capture import and the agent fixture, or treat the capture as a
  candidate-venv helper and stop importing it with the bare independent
  interpreter. Update the plan's Step 6 helper wording to match.
- Extend the cplx wheel inventory to map and verify `.data/scripts` ELFs
  against the venv's scripts directory without skipping them, deliver the
  corrected bundle, and repeat the candidate build with publication off.
- Run PA5 to PA9 on Debian, repeat RHEL PA5 and PA6 against the new consumers,
  take the D10 reading with the agent's wheels, and complete the remaining
  pre-publication obligations.

Architecture: the fixture change stays in the test contract. The dependency
question above is a boundary issue between the independent interpreter and a
helper that became venv-bound.

Performance: no runtime cost added. Unit test coverage: no Python class
changed and no percentage is claimed. No unit-tested class below 100% needs
completing, and no top-level symbol outside the coverage gate is unreferenced.

Feature integrity: the capture's strict refusals are all still asserted.
Nothing is impaired, but the committed runner's portability to the stock
independent interpreter is lost until the dependency is owned.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows are accurate about build 178 and the `.data/scripts`
inventory gap, and they disclose that the native run supplied `packaging` to
the independent interpreter. What they lack is a missing-work bullet making the
committed runner own that dependency. Adding one needs a decision between
supplying the wheel in the runner and reclassifying the capture helper, so the
reviewer leaves it to the writer instead of choosing in a validation row.

The status sentence stays exactly `No. Step 6 has NOT been fully implemented.`,
and the document-level line stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 8)

The reviewer ran all seven resolved commands. All seven pass as declared.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone
  after reading the changed transport and native scripts: transport exit 0 in
  103 seconds, native `validation exit=0 elapsed=77s`, no FAIL line, four helper
  imports, the five new wheel-capture fixture cases and 61 acceptance cases.
  The native script printed `Independent dependency: 26.2` from the injected
  `packaging` wheel. The reviewer removed its own scratch fixture afterwards.
- The build 178 record verifier, source `request`: both `PASS` lines, exit 0.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 on the 39
  older findings, as declared.
- The Markdown intersection checker, source `request`: `PASS`.
- `git diff --cached --check`, source `request`: clean.
- `bash .git/hooks/pre-commit`, source `request`: clean.

Measured independently: build 178 through the Jenkins API and its live console
digest and key lines; the application capture's imports and caller at
`68ef3af9`; the RHEL host's `/usr/bin/python3` (3.9.25, `ModuleNotFoundError:
No module named 'packaging'`); the transcript's round 7 additions; and the
host's `/var/tmp`, now at 94% with 244 MB free.

No coverage percentage is claimed; cplx's floor is shell lint.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 8)

The reviewer ran the union of the request validation set and the current
resolver set: the same seven commands.

- `bash src/utils/lint_shell.sh`, source `project`.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Its native
  script now exports `PYTHONPATH` to a hash-checked `packaging` wheel before
  running the committed runner; that is the dependency in the finding.
- The build 178 record verifier, source `request`.
- The Markdown gate with `--root ../cplx`, source `request`.
- The Markdown intersection checker, source `request`.
- `git diff --cached --check`, source `request`.
- `bash .git/hooks/pre-commit`, source `request`.

The changed transport and native scripts were read in full before running and
kept in the validation-state path set.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 8)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets. The plan command is unchanged in name, but its
ignored native script now alters the interpreter's import path; the finding
covers that.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 8)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `b92f2063de8be6473ae1f65b41ec65430a65ace5` equals the
  baseline at entry and the live index after every run.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `a9856ba7bfacaaec37d2030f2285f17d079eaf2c498274385407e1bd4d45f759`.
  No umbrella row was completed.
- Validation-state comparison over the 15 staged paths, the project command's
  file and the five ignored validation files: `acceptable: true`, naming only
  the ignored Markdown log that the declared command rewrites.
- The working tree matches its entry state: 15 staged paths, and the
  transcript also carries the protocol's unstaged append of this request.
- No reviewer residue in either repository or on the RHEL host.
- The baselines and manifest were written before assessment and the manifest
  rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 8)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 8)

`a.commit` is mechanically accurate and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 15 staged paths in five
ordered groups matching the request. The installed hook accepts the index.

- Group 1 is unchanged since round 4 and accurate.
- Group 2, `test(tools): cover ranked wheel metadata fallback`, carries the
  agent fixture alone, which fits.
- Groups 3 to 5 carry the Debian evidence, the validation plan and umbrella,
  and the transcript, in dependency order.

When the runner is changed to own the `packaging` dependency, that change
belongs with the fixture in group 2 or in its own `fix(tools)` group before it.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 8)

Unresolved findings:

- The committed cplx runner and the staged agent fixture now depend on the third-party `packaging` module, because application commit `68ef3af9` made `ci/tools_wheel_capture.py` import `packaging.tags` at module level, yet the runner still imports that helper with the bare independent interpreter; the RHEL host's `/usr/bin/python3` 3.9.25 has no `packaging`, so the declared validation passes only because the ignored native script exports `PYTHONPATH` to a lock-pinned wheel, and `verify.tools-archive-rebuild.sh --step 6 --python /usr/bin/python3` as the plan names it would fail at the helper import.

Boundary-crossing work: None.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 8)

Human guidance:

The human instructed: "Follow the sequence and, after addressing point 4,
submit a new code review request for step 6, and stop". They subsequently
asked to address round 7 and prepare round 8, explicitly authorizing another
Jenkins build after application commit 68ef3af9 was pushed.

Read .reviews/a.item7.handoff-prompt.md as the sequencing context. This
request covers point 4. Point 5 D10 and point 6 publication closure remain
later handoff work. Step 6 remains No. Assess staged defects separately from
unfinished later obligations; do not weaken readiness or publication gates.

The requestor stops immediately after publishing round 8. No cplx commit is
authorized by this request.

Guidance response:

The guidance is followed on every point.

- Scope. The review covers point 4 only; D10 and the publication closure are
  not requested, and Step 6 stays `No`.
- Staged defects, assessed separately from the later obligations: one. The
  staged fixture and the committed runner rely on a dependency that only the
  ignored transport provides.
- No gate was weakened, and the recommended fix weakens none: it makes an
  existing dependency explicit and hash-verified in committed code, or moves
  the capture helper to the environment it already runs in.
- No commit, push, build or later point was performed or is authorized.

The disposition is changes-requested because Step 6 is incomplete by design
and because of that one finding.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 8)

The build 178 evidence and the fixture change are good. One cplx change is
needed so the committed runner passes without the ignored transport.

__Make the runner own the `packaging` dependency.__ The application's capture
helper now needs `packaging`, and the stock independent interpreter does not
have it. Choose one of these in committed cplx code, then update the plan's
Step 6 helper wording to match:

- Supply the lock-pinned `packaging` wheel from the runner itself, verified by
  its hash from the application lock, and scope it to the capture import and
  the agent fixture rather than the whole run. The other helpers then keep
  proving they import on the bare interpreter.
- Or treat the capture as the candidate-venv helper it now is: drop it from the
  bare-interpreter import list and exercise it where `packaging` is present.

The reviewer leans to the first option, because it keeps the fixture's
coverage of the ranked fallback in the cumulative runner. After the change,
remove the `PYTHONPATH` export from the native script and rerun, so the
evidence shows the committed runner passing on its own.

__Then the inventory.__ Extend the cplx wheel inventory to map `.data/scripts`
ELFs to the venv's scripts directory and verify them, as the missing work
says, deliver the corrected bundle, and repeat the build.

__RHEL host space.__ `/var/tmp` is at 94% with 244 MB free again. The next
native runs need about 130 MB each, so older fixtures should be cleared soon.

Done well: build 178 confirmed the application fix, the new failure was traced
to the component that owns it, and the dependency workaround was disclosed
rather than hidden.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 8)

The disposition is changes-requested and the readiness floor is recorded as
incomplete: Step 6 is incomplete by design, and one finding remains.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Fails by design, per the guidance.
3. Validation and coverage. The declared commands pass, but the plan command
   passes only with an interpreter change made in an ignored script.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. One: the hidden `packaging` dependency.
6. `a.commit`. Passes, valid and ready, and the hook accepts the index.

The finding matters because of what the independent interpreter is for. The
plan runs helpers under a Python that is independent of the candidate, and the
runner's import check exists to prove they load there. Exporting `PYTHONPATH`
for the whole run from an ignored script keeps the check green while changing
what it proves, and the committed runner can no longer be reproduced from
committed code. The writer disclosed the workaround, which is why this is a
clean finding rather than a surprise.

The build 178 evidence itself is sound: the application fix works, and the
next blocker is correctly placed in cplx.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 8)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-8 -->

## Round 9 by requestor - Step 6

- Recorded: 2026-09-19T22:55:30+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 9)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 9

### Code review evidence for step 6 tools-archive-rebuild (round 9)

request_index_tree: a990d62b63790d20f4270e1d6c3beaa22a967c4f
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r9-verify-record.py (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r9-check-wheels.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: fix(tools): separate wheel capture test dependencies
group 2 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools): bind Debian candidate evidence
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 4: docs(tools): record point 4 checkpoint
group 4 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 5: docs(review): redact the point 4 validation path
group 5 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 9)

Round 8's unresolved dependency finding is addressed using its explicit
application-venv option. The committed runner requires --capture-python for
Step 4 and later, checks its venv dependencies and runs capture fixtures there.
The other three helper imports remain isolated under bare Python 3.9.25.
The plan now describes this boundary. No temporary PYTHONPATH is required.

The instruction to expand installed-script ELF mapping is disputed in light
of application commits dae99121 and 6ce03c2c. CI does not use the native CLI
tools in its venv; the application now excludes their tooling group from its
locked sync. That preserves the existing inventory contract. The previous
writer assessment assigning this repair to cplx was too broad. No inventory
rule or refusal is relaxed, and no reviewer repair has been reverted.

Step 6 remains No, with its documentation status not implemented. This is
handoff point 4 only. D10, affected RHEL acceptance and publication obligations
remain later work. The actual build 179 evidence and cell states accompany
this assessment. No cplx commit is authorized. Stop after publication.

### Implementation report for step 6 tools-archive-rebuild (round 9)

The staged checkpoint contains 20 paths in five valid a.commit groups.
Existing manifest portability and timestamp parsing repairs remain unchanged.
The cumulative runner and agent harness require an explicit capture venv,
isolate capture fixtures from independent Python checks, and report actual
interpreter/dependency identities. The implementation plan describes this
boundary. The outside-home fixture now works when TMPDIR is inside home.
No application source or production inventory rule was changed.

Build 179 checked out application 6ce03c2c using the unchanged candidate
archive and verification bundle with publication off. Provision and Package
passed. Locked synchronization excluded the tooling group; installed-byte
inventory captured 77 wheels and 80 ELFs. All 77 downloaded wheel hashes
match the canonical lock; the archived lock matches committed public-URL bytes.

Test stopped before pytest because the ABI inventory encountered a dangling
tools/python/root/usr/lib/cpp -> ../bin/cpp alias. Inspection of the exact
pinned archive found that alias in both Python and Git roots, with neither
target present. This new candidate archive issue belongs to cplx and requires
candidate preparation and renewed acceptance. It was not bypassed or repaired
inside this point 4 evidence checkpoint. Publish was skipped.

All 109 artifacts and the raw console are retained locally and on the native
evidence volume. The original bundled reader and timestamp-aware working
reader were both run independently on Linux. The latter binds four passes
(PA1-PA4), two failures (PA5/PA7), and three pending cells (PA6/PA8/PA9).
Two new versioned sidecars bind the raw readings, transport and all artifact
digests. The release record now includes the agent lock and 77 wheel identities.
All six earlier Debian sidecars, historical RHEL captures and original input
snapshots remain unchanged. Authority, publication and adoption are unchanged.

Validation completed:

- Native cumulative Step 6 passed in 78 seconds, including 61 acceptance
  fixtures and project shell lint for 58 scripts, with PYTHONPATH unset.
  Independent Python 3.9.25 has no packaging; its three helper imports pass.
  The explicitly selected capture venv reports Python 3.13.9 and packaging
  26.2. This fixture interpreter does not qualify candidate Python 3.13.15;
  the real Jenkins provisioning uses the selected 3.13.15 target.
- Missing capture arguments and a bare capture interpreter are rejected.
  The initial 48-second TMPDIR fixture failure and successful rerun are kept.
  Native output is .reviews/a.point4-r9-native-full.log; explicit rejection
  checks are .reviews/a.point4-r9-boundary.log. New remote run material is
  retained below $HOME/cplx-release-evidence instead of the nearly full /var/tmp.
- Canonical application lock transport matches byte-for-byte on Linux.
- The record verifier passes all nine bindings, raw capture/artifact hashes,
  historical preservation, current reassessments, gates and generated view.
- git diff --cached --check and the sensitive-content pre-commit hook pass.
- Full Markdown check retains 39 existing diagnostics; none intersects added
  lines. No baseline or rule changed; the full repository check is non-green.
- commit-plan-check reports ready=true with five groups matching all 20 paths.
- The mandatory ghog day entry passed its check phase (21.6 seconds), then
  affected testing reported exit 5 because this repository has no pytest on
  its configured PATH. The wrapper returned 1. This known project limitation
  remains explicit; the planned native suite supplies the integration checks.

No full Jenkins success, executed pytest suite or coverage result is claimed.
Step 6 stays No; archive repair, remaining Debian cells, affected RHEL acceptance,
D10 and publication obligations remain. No cplx commit is authorized.

### Change summary for step 6 tools-archive-rebuild (round 9)

Since round 8, addressed the actual dependency finding in the committed runner:
capture uses an explicit application venv while independent checks stay on
bare Python. Updated its plan and made the outside-home fixture independent
of TMPDIR placement. Native validation passes without PYTHONPATH injection.

Ran build 179 once on application 6ce03c2c with unchanged candidate pins and
publication off. Provisioning, 77-wheel/80-ELF capture and packaging pass.
The application tooling-group change resolves the previous inventory refusal;
the prior instruction to broaden the cplx inventory contract is corrected.

Retained 109 artifacts and independently bound four Debian passes, two failures
and three pending cells. The new failure is the pinned archive's dangling cpp
alias, exposed by the ABI inventory before pytest. Current consumer identities
now include the exact agent lock and wheels. Earlier sidecars and RHEL history
are preserved. Updated the generated view, missing work, umbrella and a.commit.

Step 6 remains incomplete. Stop after publishing round 9 as requested.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 9)

Human guidance:

The human asks to address Step 6 round 8, check a fresh Jenkins build after
application 6ce03c2c, and publish round 9. Earlier handoff guidance requires
stopping immediately after publication. This is point 4 only, with publication
off. Point 5 D10 and point 6 closure remain later work. No cplx commit is
authorized. Read .reviews/a.item7.handoff-prompt.md for the sequence.

Writer response:

Accepted round 8's concrete dependency finding. No reviewer repairs were made,
so none was reversed. The committed cumulative runner now requires an explicit
--capture-python application-venv interpreter for Step 4 and later. The agent
harness checks its packaging and tomllib dependencies in isolated mode, and
imports and tests wheel capture there. The three independent helpers and
other parser fixtures still run with isolated independent Python 3.9. The
plan documents this boundary. This implements the reviewer's second option.
The ignored global PYTHONPATH export and wheel injection were removed.

Explicit disagreement with the instruction to extend the inventory contract:
new application commits dae99121 and 6ce03c2c address what the CI venv contains.
Native CLI tools move to the tooling group, excluded only from CI's locked
sync. They are not runtime consumers of the packaged application. Local default
groups still include them. The Test stage uses uvtool's uv. Therefore the
existing site-packages-only inventory remains the appropriate scope; it must
not silently skip an installed ELF or need a broader script-root contract for
this application. The fresh build tests that claim against the exact pinned
bundle, not the application's mock installation. Its measured outcome is
reported separately. The round 8 ownership assessment was too broad and is
corrected in current notes; historical build 178 captures remain unchanged.

Native scratch storage now uses the home evidence volume because /var/tmp is
almost full. This exposed an acceptance fixture that assumed TMPDIR was
outside /home. Its refused test path is now explicitly under /var/tmp, preserving
the same boundary assertion without creating a fixture tree on that volume.
The first failure remains retained. No acceptance boundary was relaxed.

Reviewed work changed through the committed runner/fixture/plan repairs, new
build evidence and current checkpoint bindings. a.commit is updated for those
paths and responsibilities. Step 6 remains incomplete; no commit is authorized.

### Reviewer focus for step 6 tools-archive-rebuild (round 9)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-9 -->

## Round 9 by reviewer - Step 6

- Recorded: 2026-09-19T23:07:45+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 9)

Baseline index tree: a990d62b63790d20f4270e1d6c3beaa22a967c4f

Assessed index tree: 10a769cf445f9743cd23891e133fa2a31b8fad56

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 9)

Result:

No. Step 6 has NOT been fully implemented.

The verdict is the expected one. Build 179 got past wheel capture, then failed
on a defect in the pinned tools archive itself, so the candidate must be
repaired and re-accepted before PA5 to PA9, D10 and publication can proceed.

The round 8 finding is fixed in committed code, verified rather than accepted:

- The runner now requires `--capture-python` for Step 4 and later, imports only
  the three stdlib helpers under the bare interpreter in isolated mode, and
  runs the wheel-capture import and fixtures under an explicit interpreter
  that must be a venv holding `packaging` and `tomllib`. The plan documents the
  boundary, and the native script no longer exports `PYTHONPATH`; it asserts
  the bare interpreter has no `packaging`.
- Against the committed application `6ce03c2c`, the reviewer's run passed:
  exit 0 in 78 seconds, three independent helper imports on bare 3.9.25, the
  capture helper and its five fixture cases under the capture venv, and 61
  acceptance cases.

Build 179, verified against the evidence and the archive:

- Consumers: 77 wheel hashes match the committed lock, 80 ELFs were captured,
  none of ruff, ty or uv is among them, and the archived lock equals the
  committed bytes, as the wheel checker confirms.
- The new failure is real and belongs to cplx. On the RHEL host the retained
  replacement archive holds `usr/lib/cpp -> ../bin/cpp` in both the Python and
  Git roots, plus two `usr/lib/.build-id/` links per root aimed at the same
  absent `usr/bin/cpp`: six dangling links. The original candidate carries the
  same six. The 539 archive cases never flagged them. PA5 and PA7 on Debian
  fail on exactly that missing target, as recorded.
- The record binds build 179 and the new consumers, keeps all six earlier
  Debian sidecars and every RHEL capture, and the transcript is clean: the
  reviewer's round 8 answer copy is byte-identical, nothing earlier was
  removed, no private identifier, no repeated heading.

On the writer's dispute about the inventory: the cplx inventory's
site-packages scope is a coherent contract, and moving the native CLI tools
out of CI's locked sync is the application's decision to make. But the
deployed venv still contains them: the application's `default-groups` include
`tooling`, the RHEL-qualified 3.13.15 venv holds 80 packages including ruff, ty
and uv, and the RHEL PA6 audit runs that venv's `uv`. All four binaries there
(uv, uvx, ruff, ty) need `libgcc_s.so.1`, one of the providers D10 selects.
That is a consumer-scope question for the human, not a cplx defect.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 9)

- Remove or resolve all six dangling `cpp` links through candidate packaging,
  add an archive check that refuses dangling links, produce a new candidate,
  and repeat the affected acceptance with exact new pins.
- Record the human's decision on whether the deployed venv's tooling binaries
  are in the qualified consumer set, and align the RHEL PA6 audit and the
  Debian consumer set with it.
- Run PA5 to PA9 on Debian, repeat RHEL PA5 and PA6 against the current
  consumers, take the D10 reading and complete the pre-publication obligations.

Architecture: the capture boundary is now explicit and enforced. Performance:
no runtime cost added. Unit test coverage: no Python class changed, no
percentage claimed; no unit-tested class below 100% needs completing, and no
top-level symbol outside the coverage gate is unreferenced.

Feature integrity: the independence check is stronger than before, since
isolated mode now keeps any caller `PYTHONPATH` out. Nothing is impaired.

Validation plan effects:

The reviewer extended one Step 6 missing-work bullet in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md` and staged
exactly that attributable patch.

The writer's `Candidate archive alias` bullet named only the
`usr/lib/cpp -> ../bin/cpp` alias. The reviewer measured both candidate
archives on the RHEL host and found two more dangling links per root under
`usr/lib/.build-id/`, aimed at the same absent `usr/bin/cpp`, six in all, and
the same six in the original candidate, which the 539 archive cases did not
detect. The bullet now says so and asks to resolve all six, so the repackage
does not fix only the first link the ABI scan tripped on. It is a factual
addition and adds no design decision.

The status sentence stays exactly `No. Step 6 has NOT been fully implemented.`,
the `Missing work for Step 6` section stays present, and the document-level line
stays `No, it is not implemented.`

Pre-repair blob `141e890261b8e1c8e2872b28126447e97ef8389e` was recorded before
the edit, `attribute-reviewer-patch` returned `attributable: true`, and
`git apply --cached` staged exactly that patch.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 9)

The reviewer ran all eight resolved commands. Seven pass. The native transport,
run as declared, failed, for a reason outside the staged work.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`: native
  `validation exit=1` after 34 seconds. The cplx agent fixture raised
  `TypeError: inventory() missing 1 required positional argument: 'dangling'`.
  The transport still overlays three application helpers from the
  application's working tree, a round 1 mechanism for then-uncommitted
  repairs. The application checkout now holds an uncommitted edit to
  `ci/tools_abi_scan.py` (working-tree digest `de10145e...1149`, committed
  `6ce03c2c` blob `13a07fd9...c176`) that adds that parameter. The declared
  run therefore tested unrelated, unfinished application work.
- The same run against the committed application: the reviewer used its own
  copy of the transport that ships only the committed HEAD (the same native
  script, unchanged), and got exit 0 in 78 seconds, no FAIL line, three
  independent helper imports on bare 3.9.25, the capture helper and its
  fixtures under the capture venv, and 61 acceptance cases.
- The build 179 record verifier, source `request`: both `PASS` lines, exit 0.
- The wheel checker, source `request`: `PASS`, 77 locked wheel hashes, 80
  ELFs, tooling excluded, canonical lock archived.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 on the 39
  older findings, as declared.
- The Markdown intersection checker, source `request`: `PASS`.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`: both clean, before and after the reviewer's staged patch.

Measured independently: the six dangling `cpp` links in both candidate
archives; the `libgcc_s.so.1` needs of uv, uvx, ruff and ty in the
RHEL-qualified venv and its 80 packages; the application's `default-groups`
and CI sync flags at `6ce03c2c`; and the application checkout's uncommitted
helper edit. The reviewer removed both of its scratch fixtures from the RHEL
host and did not touch the application checkout.

No coverage percentage is claimed; cplx's floor is shell lint.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 9)

The reviewer ran the union of the request validation set and the current
resolver set: the same eight commands, plus one reviewer-owned variant.

- `bash src/utils/lint_shell.sh`, source `project`. Clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 1 as
  declared, from the application working-tree overlay.
- The build 179 record verifier, source `request`. Exit 0.
- The wheel checker, source `request`. Exit 0.
- The Markdown gate with `--root ../cplx`, source `request`. Exit 1 on older
  debt only.
- The Markdown intersection checker, source `request`. Exit 0.
- `git diff --cached --check`, source `request`. Clean.
- `bash .git/hooks/pre-commit`, source `request`. Clean.

The variant is `.reviews/a.code-review.s6r9-transport-committed.sh`: the same
transport without the working-tree overlay, with helper digests taken from the
committed blobs. It is kept as caller evidence in the artifact home.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 9)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 9)

Every comparison came from the shared evidence launcher. The only tracked change
is the reviewer's own attributable validation-row patch.

- Request-time index tree `a990d62b63790d20f4270e1d6c3beaa22a967c4f` equals the
  baseline at entry. The assessed tree is
  `10a769cf445f9743cd23891e133fa2a31b8fad56`, which differs by exactly the
  staged reviewer patch.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `e1d94dba81fd7292cc260e9a1799f34293bbf286460ba05644e8191f0df9a23b`.
- Validation-state comparison over the 20 staged paths, the project command's
  file and the six ignored validation files: `acceptable: false`, naming the
  validation plan and the index (the reviewer's permitted Step 6 row patch)
  and the ignored Markdown log the declared command rewrites.
- The working tree matches its entry state apart from that staged patch, plus
  the protocol's unstaged transcript append and the reviewer's ignored
  transport variant.
- The application checkout was read, never written; its uncommitted edit is
  the application team's and was left in place.
- No residue on the RHEL host: both reviewer scratch fixtures were removed.
- The baselines and manifest were written before assessment, the pre-repair
  blob before the edit, and the manifest rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 9)

Repairs made:

- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`, polishing-only review metadata confined to one Step 6 missing-work bullet: the candidate archive bullet now names all six dangling `cpp` links (the `usr/lib/cpp` alias and two `usr/lib/.build-id/` links per root), notes the original candidate carries them too and that the 539 archive cases missed them

Paths staged:

- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md` (the attributable reviewer patch only, applied to the index with `git apply --cached`)

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 9)

`a.commit` is accurate, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json`, run against the received
state and again after the reviewer's staged patch: `state: valid`,
`ready: true`, exit 0, no diagnostics, 20 staged paths in five ordered groups
matching the request. The installed hook accepts the index.

- Group 1 is unchanged since round 4.
- Group 2, `fix(tools): separate wheel capture test dependencies`, carries the
  runner, the agent harness, the fixture and the plan text for the capture
  boundary. `fix` fits: it repairs the runner's hidden dependency.
- Groups 3 to 5 carry the Debian evidence, the validation plan (with the
  reviewer's patch) and umbrella, and the transcript, in dependency order.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 9)

Unresolved findings:

- The declared native validation is not hermetic: `.reviews/a.step6.transport.sh` still overlays `ci/tools_abi_scan.py`, `ci/tools_test_evidence.py` and `ci/tools_wheel_capture.py` from the application working tree, so with the application's current uncommitted edit to `tools_abi_scan.py` the declared command exits 1 in the cplx agent fixture, although the staged cplx work passes against the committed application `6ce03c2c`; the overlay served round 1's uncommitted repairs, which are now committed, and should be removed so the command validates committed inputs only.

Boundary-crossing work:

- The consumer scope of the deployed venv needs a human decision: CI now syncs without the application's `tooling` group, so the bound Debian consumer set is 77 wheels, while local syncs keep `default-groups = ["dev", "tooling"]`, the RHEL-qualified venv holds 80 packages including ruff, ty and uv, the RHEL PA6 audit executes that venv's `uv`, and uv, uvx, ruff and ty all need `libgcc_s.so.1`, a provider D10 selects; decide whether deployment venvs exclude the tooling group too (and where PA6 gets `uv`) or whether those binaries join the qualified consumer set
- The application checkout holds an uncommitted edit that changes `tools_abi_scan.inventory` to require a `dangling` argument; when it is committed, the cplx agent fixture's `abi.inventory(tools, venv)` call must change in the same coordinated step, or the cumulative runner will fail against that application revision

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 9)

Human guidance:

The human asks to address Step 6 round 8, check a fresh Jenkins build after
application 6ce03c2c, and publish round 9. Earlier handoff guidance requires
stopping immediately after publication. This is point 4 only, with publication
off. Point 5 D10 and point 6 closure remain later work. No cplx commit is
authorized. Read .reviews/a.item7.handoff-prompt.md for the sequence.

Guidance response:

The guidance is followed on every point.

- Round 8 is addressed, and the reviewer confirmed it against the committed
  application.
- Build 179 was checked through its retained evidence and the archive it
  pinned; the new blocker is confirmed and scoped more precisely.
- Scope stays point 4. D10 and the publication closure are not requested, and
  Step 6 stays `No`.
- No commit, push, build or later point was performed or is authorized, and
  the application checkout was not touched.

The disposition is changes-requested because Step 6 is incomplete by design,
because the declared validation must stop reading the application's working
tree, and because two items need the human: the tooling-group consumer scope
and the coordination of the in-progress application helper change.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 9)

The staged cplx work is sound. Three things follow.

__Make the declared validation hermetic.__ Remove the application working-tree
overlay from `.reviews/a.step6.transport.sh` and take the helper digests from
the committed blobs. The reviewer's copy,
`.reviews/a.code-review.s6r9-transport-committed.sh`, shows the change and
passes. The round 1 repairs it served are committed, and the overlay now pulls
in whatever the application team has in progress.

__Plan the candidate repair for all six links.__ Remove or resolve the
`usr/lib/cpp` alias and the two `usr/lib/.build-id/` links per root aimed at
`usr/bin/cpp`, in the Python and Git roots, through candidate packaging. Add an
archive check that refuses dangling links, since the 539 cases missed these.
A new candidate means a new Step 5 return and renewed acceptance, which needs
the human's go-ahead.

__Bring two items to the human.__ First, the consumer scope of the tooling
group: CI's consumer set is 77 wheels, while the deployed venv holds 80,
including uv, ruff and ty, which need `libgcc_s.so.1` and whose `uv` the RHEL
PA6 audit runs. Second, the application's in-progress change to
`tools_abi_scan.inventory`: the cplx agent fixture must change with it, in one
coordinated step.

The inventory dispute is accepted as far as cplx goes: the site-packages scope
is coherent, and the round 8 missing-work bullet was indeed broader than
needed. What remains is the scope decision above, which belongs to the human.

Done well: the dependency finding was fixed in committed code with explicit,
enforced boundaries, the fixture's TMPDIR assumption was found and corrected,
and the archive defect was traced to the candidate rather than patched around.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 9)

The disposition is changes-requested and the readiness floor is recorded as
incomplete.

1. Identity. Passes; the assessed tree differs from the request by exactly the
   reviewer's staged patch.
2. Completeness. Fails, now for a concrete reason beyond the plan: the pinned
   candidate archive has six dangling links and must be rebuilt.
3. Validation and coverage. The staged work passes against the committed
   application. The declared native command fails because it reads the
   application's working tree.
4. Staged attribution. Passes; one attributable validation-row patch, which is
   review metadata.
5. Unresolved findings. One: the transport's working-tree overlay.
6. `a.commit`. Passes, valid, ready and accepted by the hook.

This round's central result is the archive defect. It is not a point 4 issue:
it has been in both candidates since the original build, the archive checks
never looked for dangling links, and the application's ABI scan found it only
because the build finally got that far. It means another candidate, so the
human decides how and when.

The transport finding explains a run that fails for the reviewer but passed
for the writer, and shows why a declared validation should read only committed
inputs.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 9)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-9 -->

## Human-authorized recovery after round 9 - Step 6

- Recorded: 2026-09-19T23:53:49+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: escalation

review disagreement remained after the clarification round

<!-- review-entry-id: escalation-round-9 -->

## Round 9 by human - Step 6 - human-reclaim

- Recorded: 2026-09-20T01:04:22+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: human-reclaim

### Human resolution of archive disagreement for step 6 tools-archive-rebuild (round 10) (recovery record)

The human selected: Use c2b71daf/#180 evidence; publish round 10.
The current request reiterates publication after first writing instructions
for application-owned fixes in application.

The human subsequently explicitly authorized reclaiming ownership, publishing
round 10 and stopping. Resume this stopped manual handoff using that authority;
the archive disagreement is resolved by the evidence decision above.

Use application c2b71daf and retained Jenkins build 180 as authoritative
evidence that dangling aliases no longer stop inventory and loader maps.
Leave the candidate archive unchanged for this checkpoint. Preserve the
reviewer's measured links and historical build 179 evidence. Retain the real
host-library import failure as unresolved; no runtime or release waiver is
granted. Broader system-interpreter scope remains reviewable.

The application follow-up instructions were written first to
`.reviews/a.point4-runtime-import-handoff.md`. They identify the application
scanner's forced-map/runtime mismatch, require the direct-import refusal to
remain blocking, and require coordination if the runtime fix belongs to cplx.

Publish round 10 and stop without waiting or committing. Step 6 stays No;
D10, fresh RHEL qualification and publication remain later work.

<!-- review-entry-id: human-reclaim-round-9 -->

Editorial correction for round 11: application-project names in this recovery
record and its repeated round 10 guidance were redacted; recovery headings
were qualified. The decision and live exchange artifacts are unchanged.

## Round 10 by requestor - Step 6

- Recorded: 2026-09-20T01:06:59+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 10)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 10

### Code review evidence for step 6 tools-archive-rebuild (round 10)

request_index_tree: c0078dd0941f9871aa650a3fee5018f083c4f3ca
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r10-verify-record.py (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r10-check-wheels.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: fix(tools): align application verification fixtures
group 2 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools): bind Debian candidate evidence
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 4: docs(tools): record point 4 checkpoint
group 4 path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 5: docs(review): retain point 4 review exchanges
group 5 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 10)

Round 9's validation transport finding is addressed. Application source is
archived from one committed revision, with committed helper hashes retained;
the ignored transport no longer overlays application working-tree helpers.
The cplx fixtures now use the committed ABI scanner API, including explicit
dangling-link evidence and the venv interpreter search path.

The mandatory archive-rebuild repair is explicitly disputed. The six measured
cpp links are real and remain documented, but unused aliases and RPM debug
links alone do not establish a missing runtime provider. This disagreement
triggered the review exchange's escalation rule. The response preserves the
reviewer's observation and earlier captures, and identifies the remaining
system-interpreter scope question rather than claiming a release waiver.

The human chose deployment venvs without tooling and uv from the tools
installation. Requirement, design, plan and checkpoint notes record this
decision. Fresh RHEL qualification must measure that scope before D10.

Step 6 remains No. This is handoff point 4 only; D10, fresh consumer-dependent
RHEL acceptance and publication obligations remain later work. No cplx commit
is authorized. The human resolved the archive disagreement using c2b71daf
and build 180 as authority, and explicitly authorized ownership reclaim and
round 10 publication. Recovery succeeded. Dangling aliases remain unchanged
for this checkpoint; the actual import failure remains unresolved.

Application follow-up instructions were written before publication in
`.reviews/a.point4-runtime-import-handoff.md`. They identify the scanner's
forced-map/runtime mismatch without claiming a application-only runtime fix.

### Implementation report for step 6 tools-archive-rebuild (round 10)

The staged point 4 checkpoint contains 24 paths in five a.commit groups.
Existing manifest portability and timestamp parsing repairs remain included.
The cumulative runner uses an explicit application capture venv, keeping
independent helper imports isolated on bare Python. The transport archives
one committed application revision and checks its committed helper hashes,
without an application working-tree overlay. Fixtures supply the scanner's
new dangling-link argument and interpreter RPATH. Missing providers and
unknown outside interpreters still refuse. The reader supports the optional
dangling count and rejects malformed zero-flags lines.

The human chose deployment venvs without tooling and uv from the tools
installation. Requirement, design, plan, validation and umbrella record that
scope and the need for fresh RHEL acceptance before D10. No deployed venv
was modified in this evidence checkpoint.

Build 180 checked out c2b71daf with the unchanged candidate archive and
verification bundle, publication off. Provision and Package passed. Locked
synchronization used Python 3.13.15, uv 0.12.17 and --no-group tooling.
All 77 captured wheel hashes and the archived public-URL lock match the
committed lock; capture records 80 installed ELFs.

The scanner inventories 686 objects, records 488 dangling links and completes
519 per-object loader observations. The real direct-venv import then fails
in pymupdf: _extra.so's RUNPATH is searched for libpthread, followed by the
host cache, which selects /lib/x86_64-linux-gnu/libpthread.so.0. Its
GLIBC_ABI_DT_RELR requirement is absent from candidate libc. Host libdl,
libutil and libstdc++ are selected too. No ABI pass, pytest execution or
coverage result is claimed. Publish was skipped.

All 1320 artifacts and the console are retained locally and on the native
evidence volume. Both original bundled and updated readers ran on native
Linux. The updated reading binds PA1 to PA4 pass, PA5 to PA8 fail and PA9
pending. Two new sidecars bind readings, transport, raw captures and every
artifact digest. Eight earlier Debian sidecars, historical RHEL captures and
original input snapshots are preserved. Authority, publication and adoption
are unchanged. Consumer-dependent historical RHEL passes remain pending.

Validation:

- Native cumulative Step 6 passes in 77 seconds, including 63 acceptance
  fixtures and shell lint for 58 scripts. Bare Python 3.9.25 helper imports
  stay isolated; the fixture capture venv reports Python 3.13.9, packaging
  26.2. That fixture does not qualify candidate Python 3.13.15.
- Committed lock transport is byte-identical on Linux. All 77 wheel hashes,
  80 ELFs, tooling exclusion and canonical archived lock checks pass.
- The evidence verifier checks exact cells, all retained digests, historical
  preservation, reassessments, unchanged gates and the generated view.
- The staged diff passes. Commit-plan checking is
  ready=true for all 24 paths in five groups.
- Full Markdown checking reports 39 existing diagnostics plus two new
  diagnostics on the workflow-owned transcript's duplicate Round 9 requestor
  heading (LS003 and MD024, line 11721). The changed-line check therefore
  fails too. The review tool appended that heading while consuming this
  answer; no caller edit to the core-owned transcript is made or claimed.
  This new tooling diagnostic is reported, not hidden as existing lint debt.
- The required ghog day check phase passes in 17.2 seconds; affected testing
  exits 5 because pytest is absent from this repository's configured PATH.
  The wrapper exits 1. The planned native suite supplies integration checks;
  the repository-wide ghog result is not claimed green.

The mandatory archive rebuild solely for dangling cpp/debug links is explicitly
disputed; the human resolved that disagreement using c2b71daf/build 180 and
authorized reclaiming ownership and publishing round 10. Recovery succeeded.
The actual
direct-venv search-path failure remains unresolved, and broader scanner
system-interpreter exclusions still require review against the settled scope.
Step 6 stays No. D10, RHEL requalification and publication remain later work.
No cplx commit is authorized. Stop immediately after publishing round 10.

Before publication, wrote `.reviews/a.point4-runtime-import-handoff.md` for
the application. Its scanner forces per-object search paths which the real import
does not use. The instructions require truthful diagnostics and preservation
of the direct-import gate, with coordinated cplx follow-up if no supported
application-side runtime repair exists. No runtime fix is claimed.

Final publication checks after authorized ownership recovery:

- Commit-plan validation remains ready=true for 24 paths in five groups.
- The changed-line Markdown check still reports the duplicate Round 9 heading.
- The sensitive-content hook now fails on two application-name mentions in
  the core-appended human-reclaim summary (transcript lines 11751 and 11764).
  This is a new checkpoint defect, not a passing hook or existing lint debt.
  Authored inputs use generic application wording except the exact human
  recovery guidance, which the publication protocol requires verbatim.
  No manual edit to core-owned history was made; review must address it
  before any commit. No commit is authorized in this round.

### Change summary for step 6 tools-archive-rebuild (round 10)

Since round 9, removed the validation transport's application working-tree
overlay and bound application source and helper hashes to one commit. Updated
the agent fixtures for that committed scanner API, including dangling-link
accounting and interpreter RPATH. Missing and outside providers still refuse.
The reader accepts the optional dangling count only in a complete success line.

Recorded the human's deployment scope: exclude tooling and use tools-provided
uv. Fresh RHEL qualification must measure this scope before D10. Explicitly
disputed the mandatory archive rebuild for the six dangling cpp/debug links;
the human resolved that disagreement using c2b71daf/build 180 as authority
and explicitly authorized ownership reclaim and round 10 publication.
The archive remains unchanged for this checkpoint, with no runtime waiver.

Ran build 180 once on application c2b71daf, with unchanged candidate pins and
publication off. Provisioning, 77-wheel/80-ELF capture and packaging pass.
All 519 per-object loader observations complete after inventorying 686 objects
and recording 488 dangling links. The actual heavy-wheel import then fails:
pymupdf's RUNPATH and the host cache select host libpthread, whose
GLIBC_ABI_DT_RELR requirement is absent from candidate libc. The trace also
selects host libdl, libutil and libstdc++. No pytest execution is claimed.

Retained 1320 artifacts and both native reader outputs. Bound four Debian
passes, four failures and one pending cell, preserving eight earlier Debian
sidecars and the RHEL history. Updated missing work, the generated acceptance
view, umbrella and the five a.commit groups. No runtime repair, new scope
waiver, cplx commit, D10 execution or Step 6 completion is claimed.

Prepared the the application instructions in
`.reviews/a.point4-runtime-import-handoff.md` before publication. The scanner
diagnostic mismatch is application-owned; the runtime repair's ownership
still requires investigation against the current contract.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 10)

Human guidance:

#### Human resolution of archive disagreement for step 6 tools-archive-rebuild (round 10)

The human selected: Use c2b71daf/#180 evidence; publish round 10.
The current request reiterates publication after first writing instructions
for application-owned fixes in the application project.

The human subsequently explicitly authorized reclaiming ownership, publishing
round 10 and stopping. Resume this stopped manual handoff using that authority;
the archive disagreement is resolved by the evidence decision above.

Use application c2b71daf and retained Jenkins build 180 as authoritative
evidence that dangling aliases no longer stop inventory and loader maps.
Leave the candidate archive unchanged for this checkpoint. Preserve the
reviewer's measured links and historical build 179 evidence. Retain the real
host-library import failure as unresolved; no runtime or release waiver is
granted. Broader system-interpreter scope remains reviewable.

The application follow-up instructions were written first to
`.reviews/a.point4-runtime-import-handoff.md`. They identify the application
scanner's forced-map/runtime mismatch, require the direct-import refusal to
remain blocking, and require coordination if the runtime fix belongs to cplx.

Publish round 10 and stop without waiting or committing. Step 6 stays No;
D10, fresh RHEL qualification and publication remain later work.

Writer response:

Accepted the round 9 transport finding. The declared transport no longer
overlays application working-tree helpers. It captures one application commit,
archives that revision and verifies hashes from the same committed blobs.
The now-committed c2b71daf scanner API is integrated in the cplx fixtures:
inventory receives its dangling-link evidence list, the interpreter fixture
supplies its RPATH, and known system-loader helpers remain visibly classified.
Unknown external interpreters, external providers and missing runtime providers
still refuse. Independent Python and capture-venv roles remain separate.

Explicit disagreement with the reviewer repair's mandatory archive rebuild:
the six measured cpp links are real, and that observation remains recorded.
However, those non-loadable aliases do not by themselves establish a missing
runtime provider or violate the protected loader-alias contract. The committed
application fix records dangling links and still refuses an absent provider in
a loader map. Blanket rejection of every dangling RPM debug link would add an
archive requirement not present in the settled scope. Current missing-work
wording is corrected accordingly, rather than silently retaining an instruction
to rebuild the archive for this scanner failure. Historical build 179 sidecars
and the reviewer answer remain unchanged. No archive is repackaged this round.

This does not establish that every new system-interpreter classification is
acceptable. The settled exception covers retained helper programs; the new
scanner also reports system-interpreter objects outside tools/bin, including
the wheel's node executable. The request calls out that boundary for review;
it does not authorize additional outside-prefix runtime providers or treat a
pipeline verdict as sufficient release qualification.

The deployed tooling-group discrepancy is real. The human selected deployment
venvs without tooling, with uv supplied by the tools installation. The
requirement, design, plan and checkpoint notes record that decision. Fresh
RHEL acceptance must implement and measure this scope before D10; the old
tooling-inclusive RHEL captures remain historical. No deployed venv is changed
in this point 4 evidence round, and no fresh RHEL qualification is claimed.

The ABI evidence reader accepts the new optional dangling-links count and
requires a complete zero-flags verdict. Regression fixtures cover the old and
new formats, timestamps and refusal of malformed flags. The raw evidence is
preserved. Step 6 remains incomplete, and no cplx commit is authorized.

Build 180 on c2b71daf confirms that inventory and 519 per-object loader
observations complete. Its direct-venv pymupdf import then fails because
the wheel's RUNPATH and the host cache select host libpthread against
candidate libc, which lacks GLIBC_ABI_DT_RELR. This is a real runtime
failure, not an alias-inventory refusal. Host libdl, libutil and libstdc++
also appear in the trace. The forced observation path is not evidence of
actual import resolution. PA5 to PA8 remain failed and PA9 pending; the
new failure must be resolved within the settled runtime contract.

The human resolved the archive disagreement using c2b71daf/build 180 and
explicitly authorized ownership reclaim and round 10 publication. The shared
launcher reclaimed the stopped handoff and advanced to round 10. The prior
disagreement remains explained above; it is no longer awaiting a decision.
The application follow-up instructions were prepared before publication in
`.reviews/a.point4-runtime-import-handoff.md`.

### Reviewer focus for step 6 tools-archive-rebuild (round 10)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-10 -->

## Round 10 by reviewer - Step 6

- Recorded: 2026-09-20T01:18:00+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 10)

Baseline index tree: c0078dd0941f9871aa650a3fee5018f083c4f3ca

Assessed index tree: c0078dd0941f9871aa650a3fee5018f083c4f3ca

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 10)

Result:

No. Step 6 has NOT been fully implemented.

Build 180 got past inventory and loader observation, then failed on a real
runtime import, so PA5 to PA8 fail, PA9 stays pending, and D10, the fresh RHEL
qualification and the publication obligations remain open.

Verified rather than accepted:

- Round 9's transport finding is fixed. The transport archives one committed
  application revision and verifies committed helper digests; the reviewer's
  declared run passed, exit 0 in 79 seconds, with three isolated bare-interpreter
  helper imports, the capture venv, 63 acceptance cases and no FAIL line.
- Build 180. The Jenkins API reports `FAILURE` from application `c2b71daf`, and
  the live console's SHA-256 equals the recorded `5bc2029b...bb55`.
- The real failure, read from the retained artifact rather than the summary:
  `abi/imports.txt` records
  `ImportError: <candidate>/tools/python/root/usr/lib64/libc.so.6: version
  'GLIBC_ABI_DT_RELR' not found (required by /lib/x86_64-linux-gnu/libpthread.so.0)`.
  The host libpthread was loaded against the candidate libc. That matches the
  request's description exactly.
- Consumers: 77 wheel hashes match the committed lock, 80 ELFs captured, no
  ruff, ty or uv, canonical lock archived.
- The human's Q07 decision is recorded in the requirement, design, plan and
  umbrella: deployment venvs exclude `tooling`, uv comes from the tools
  installation, affected RHEL qualification is repeated at that scope, and the
  tooling-inclusive captures stay historical. The cells and record are honest.
- The reader change is bounded: the optional `dangling-links=N` count is
  accepted only inside a complete `flags=0` line anchored at end, and a
  malformed `flags=01` is refused, with fixtures for both.
- The archive disagreement is the human's to settle, and they settled it. The
  reviewer's measurement stands recorded, the archive is unchanged this round,
  and no waiver is claimed. The reviewer does not reopen it.
- The transcript's earlier content is unchanged and the reviewer's round 9
  answer copy is byte-identical.

What the evidence adds beyond the request, measured on the RHEL prefix:

- The candidate interpreter carries `DT_RPATH` listing the shipped lib
  directories. `pymupdf/_extra.so` carries its own `DT_RUNPATH` of `$ORIGIN`
  and needs `libpthread`, `libdl`, `libutil`, `libstdc++` and `libgcc_s`.
  A loader consults the executable's `RPATH` only for objects that have no
  `RUNPATH` of their own, so those five needs never reach the shipped
  providers: they fall through `$ORIGIN`, then `LD_LIBRARY_PATH`, then the host
  cache. That is why build 180 selected host libpthread, libdl, libutil and
  libstdc++.
- This contradicts the mechanism Q06 records, that wheel objects "resolve
  shipped providers through the interpreter's own search path". On RHEL the
  same objects also took host providers; PA6 passed there because the RHEL
  host's copies happen to be compatible with the candidate libc, not because
  the shipped ones were used. The same premise underpins D10's choice of a
  shipped `libstdc++` generation.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 10)

- Decide and record how venv wheel objects reach the shipped providers, given
  that their own `RUNPATH` shadows the interpreter's `RPATH`: for example an
  explicit `LD_LIBRARY_PATH` in the deployment environment, providers beside
  the objects, or a revision of Q06. Then re-establish PA6 on both platforms
  under that mechanism, and re-examine what D10's generation choice governs.
- Resolve the build 180 import failure under that decision and repeat PA5 to
  PA9 on Debian.
- Repeat RHEL qualification at the Q07 deployment scope before D10, then take
  the D10 reading and complete the pre-publication obligations.
- Make the staged set committable and settle the loader-scope question below.

Architecture: the fixture and reader changes stay in the test contract, except
the scope change noted in the findings. Performance: no new cost. Unit test
coverage: no Python class changed and no percentage is claimed; no unit-tested
class below 100% needs completing, and no top-level symbol outside the
coverage gate is unreferenced.

Feature integrity: missing providers, unknown interpreters and malformed ABI
lines are still refused, and the raw evidence is preserved.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md` this round.

The writer's Step 6 rows record build 180, the Q07 scope decision and the
corrected archive wording after the human's resolution, and the reviewer's
round 9 measurement of the six dangling links is preserved. The reviewer's
`RUNPATH` finding above belongs in those rows once the human decides the
mechanism, so it is offered in this answer rather than written as a row that
would presume the decision.

The status sentence stays exactly `No. Step 6 has NOT been fully implemented.`,
and the document-level line stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 10)

The reviewer ran all eight resolved commands. Six pass. Two fail, both on the
staged transcript's protocol-appended content.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone
  after reading the changed transport: transport exit 0 in 103 seconds, native
  `validation exit=0 elapsed=79s`, no FAIL line, three isolated helper imports
  on bare 3.9.25, the capture venv, the new dangling-count and malformed-flags
  cases, and 63 acceptance cases. The application source is now one committed
  revision with committed helper digests, as round 9 asked.
- The build 180 record verifier, source `request`: both `PASS` lines, exit 0.
- The wheel checker, source `request`: `PASS`, 77 locked hashes, 80 ELFs,
  tooling excluded, canonical lock archived.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1, now with
  two new findings beyond the 39 older ones, both on the duplicated round 9
  requestor heading.
- The Markdown intersection checker, source `request`: exit 1 on that heading
  at line 11721 and on a second duplicate at line 12023, the human-resolution
  heading that appears in both the reclaim summary and this round's request.
- `git diff --cached --check`, source `request`: clean.
- `bash .git/hooks/pre-commit`, source `request`: exit 1, `Commit blocked`, at
  staged transcript lines 11751 and 11764.

Measured independently: build 180's result, revision and live console digest
through the Jenkins API; the import failure read from the retained
`abi/imports.txt`; the candidate interpreter's `DT_RPATH` and
`pymupdf/_extra.so`'s `DT_RUNPATH` and NEEDED list on the RHEL prefix; the
staged transcript's two blocked lines and two duplicate headings; and the
reviewer's round 9 answer copy, byte-identical.

The reviewer removed its scratch fixture from the RHEL host and left the
application checkout untouched. No coverage percentage is claimed.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 10)

The reviewer ran the union of the request validation set and the current
resolver set: the same eight commands.

- `bash src/utils/lint_shell.sh`, source `project`. Clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`. Exit 0, now
  from one committed application revision.
- The build 180 record verifier, source `request`. Exit 0.
- The wheel checker, source `request`. Exit 0.
- The Markdown gate with `--root ../cplx`, source `request`. Exit 1, with two
  new findings on the transcript.
- The Markdown intersection checker, source `request`. Exit 1.
- `git diff --cached --check`, source `request`. Clean.
- `bash .git/hooks/pre-commit`, source `request`. Exit 1, commit blocked.

The request declared both failures before publication, which the reviewer
confirms rather than discovers.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 10)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets. Every request addition names cplx and carries no
home path.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 10)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `c0078dd0941f9871aa650a3fee5018f083c4f3ca` equals the
  baseline at entry and the live index after every run.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `3e1c04e74d54c61a0878b62454ab64cfd31dc5f61c5e7d0d18af7bdd9b01a3f7`.
  No umbrella row was completed.
- Validation-state comparison over the 24 staged paths, the project command's
  file and the six ignored validation files: `acceptable: true`, naming only
  the ignored Markdown log that the declared command rewrites.
- The working tree matches its entry state: 24 staged paths, plus the
  protocol's unstaged transcript append.
- No reviewer residue: the scratch fixture on the RHEL host was removed, the
  application checkout was only read, and no tracked file was changed.
- The baselines and manifest were written before assessment and the manifest
  rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 10)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 10)

`a.commit` is mechanically accurate and the reviewer amended nothing, but the
staged set is not committable.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 24 staged paths in five
ordered groups matching the request. Membership and order fit the work: the
delivery and driver repairs, the capture-boundary and scanner-API fixtures,
the Debian evidence with all ten sidecars, the requirement, design, plan,
validation and umbrella records of Q07, and the transcript.

Not executable: the installed hook refuses group 5, the transcript, at two
lines. `commit-plan-check` does not consult that hook. The fix is content-only
and changes neither membership nor order.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 10)

Unresolved findings:

- The staged set cannot be committed: the installed sensitive-content hook refuses the staged transcript at lines 11751 and 11764, where the protocol-appended human-reclaim summary quotes the human's guidance naming the application project, and the declared Markdown intersection checker fails on the duplicate heading `## Round 9 by requestor - Step 6` at staged line 11721 (a second appended round 9 request entry, the first at line 11159), with a further duplicate at line 12023 in this round's unstaged append; the reviewer cannot edit the transcript, so the requestor or the human must redact those two mentions and qualify the duplicated headings before any commit.
- The staged agent fixture relaxes a loader-scope rule without a recorded decision: it previously required that moving a system-interpreter subject out of `tools/bin` removed the exception, and it now asserts that such an object is accepted anywhere in the tree as `system-interpreter-object`, which the request itself flags as covering the wheel's `node` executable; the requirement's wording covers "retained helper programs" only, so this scope needs the human's explicit decision and a recorded question before the fixture asserts it.

Boundary-crossing work:

- The runtime search-path mechanism needs the human: `pymupdf/_extra.so` carries its own `DT_RUNPATH`, so the candidate interpreter's `DT_RPATH` is not consulted for that object's `libpthread`, `libdl`, `libutil`, `libstdc++` and `libgcc_s`, which is why build 180 loaded host libraries against candidate libc; Q06 records the opposite mechanism, the RHEL PA6 pass rested on host compatibility rather than shipped providers, and D10's generation choice rests on the same premise, so the decision spans the requirement, the design and item 8 rather than this checkpoint

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 10)

Human guidance:

#### Human resolution of archive disagreement for step 6 tools-archive-rebuild (exchange 1) (round 10)

The human selected: Use c2b71daf/#180 evidence; publish round 10.
The current request reiterates publication after first writing instructions
for application-owned fixes in the application project.

The human subsequently explicitly authorized reclaiming ownership, publishing
round 10 and stopping. Resume this stopped manual handoff using that authority;
the archive disagreement is resolved by the evidence decision above.

Use application c2b71daf and retained Jenkins build 180 as authoritative
evidence that dangling aliases no longer stop inventory and loader maps.
Leave the candidate archive unchanged for this checkpoint. Preserve the
reviewer's measured links and historical build 179 evidence. Retain the real
host-library import failure as unresolved; no runtime or release waiver is
granted. Broader system-interpreter scope remains reviewable.

The application follow-up instructions were written first to
`.reviews/a.point4-runtime-import-handoff.md`. They identify the application
scanner's forced-map/runtime mismatch, require the direct-import refusal to
remain blocking, and require coordination if the runtime fix belongs to cplx.

Publish round 10 and stop without waiting or committing. Step 6 stays No;
D10, fresh RHEL qualification and publication remain later work.

Guidance response:

The guidance is followed on every point.

- The archive disagreement is treated as settled by the human. The reviewer
  does not reopen it: the archive stays unchanged this round, the measured
  links remain recorded, build 179's evidence is preserved, and no waiver is
  read into that decision.
- Build 180 and application `c2b71daf` were used as the authority they were
  given, and both were verified against Jenkins and the retained artifacts.
- The host-library import failure is retained as unresolved, and this answer
  adds the measured reason it happens rather than a claim that it is fixed.
- The broader system-interpreter scope was reviewed, as the guidance invites,
  and is returned as a finding needing an explicit decision.
- Step 6 stays `No`. No commit, push, build or later point was performed or is
  authorized, and the application checkout was not touched.

The disposition is changes-requested: Step 6 is incomplete by design, the
staged set is blocked by the hook, and one scope question needs the human.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 10)

Three things, in order.

__Make the staged set committable.__ The hook refuses the staged transcript at
lines 11751 and 11764, where the appended human-reclaim summary quotes guidance
naming the application project. Redact those two mentions to the generic
wording used elsewhere, keeping the sentence otherwise verbatim, and note the
redaction. Then qualify the duplicated headings: the second
`## Round 9 by requestor - Step 6` entry at line 11721, and the
human-resolution heading that now appears both in the reclaim summary and in
this round's request. Rerun the hook and the intersection checker on the final
index and require both clean. If the protocol appended those entries in a way
a caller may not edit, say so and ask the human, since no commit is possible
while the hook refuses.

__Take the loader-scope question to the human before the fixture asserts it.__
The fixture now accepts a system-interpreter object anywhere in the tree, where
it previously required the exception to end outside `tools/bin`, and the
request notes this now covers the wheel's `node`. Record it as a numbered
question with its rationale, as Q06 and Q07 were, and keep the fixture's old
assertion until it is answered.

__Bring the runtime mechanism to the human too.__ Build 180's import failure is
not incidental: `_extra.so` has its own `RUNPATH`, so the interpreter's `RPATH`
never applies to its `libpthread`, `libdl`, `libutil`, `libstdc++` and
`libgcc_s`, and the host copies win. Q06 states the opposite, the RHEL pass
depended on host compatibility, and D10's generation choice rests on the same
premise. Decide the mechanism first; the application-side scanner instructions
you prepared are worth sending either way, but they will not resolve this.

Done well: the transport now validates committed inputs only, the Q07 decision
is recorded in all four documents with the requalification it implies, the
reader change is tightly bounded with fixtures for both formats, and both
publication defects were reported rather than left for the reviewer to find.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 10)

The disposition is changes-requested and the readiness floor is recorded as
incomplete.

1. Identity. Passes; the index matched at entry and after every run.
2. Completeness. Fails, and this round shows why in runtime terms rather than
   in pipeline terms.
3. Validation and coverage. Two declared commands fail: the hook and the
   Markdown intersection check, both on the staged transcript.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. Two: the blocked transcript and the unrecorded
   loader-scope relaxation.
6. `a.commit`. Mechanically valid and correctly grouped, and not executable
   while the hook refuses.

The substance of this round is good work: the transport is hermetic, Q07 is
recorded where it belongs, the reader change is bounded, and the failing build
was reported with its raw evidence rather than summarized away.

The reviewer's own contribution is the mechanism behind the failure. The
request describes what happened; the measurement explains why it must happen:
an object with `DT_RUNPATH` never consults the executable's `DT_RPATH` for its
own dependencies. That makes build 180's failure the expected outcome on any
host whose libraries are newer than the candidate's libc, and it makes the
RHEL pass a fact about the RHEL host rather than about the shipped providers.
It is raised as a decision for the human because it touches Q06, D10 and item
8, not because this checkpoint recorded it wrongly.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 10)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-10 -->

## Round 11 by requestor - Step 6

- Recorded: 2026-09-20T12:33:48+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 11)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 11

### Code review evidence for step 6 tools-archive-rebuild (round 11)

request_index_tree: 3280b1e74cd93c77a36c5378365f3fac819e80ad
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- bash .reviews/a.step6.r11-focused-transport.sh (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r11-verify-record.py (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r11-check-provision.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: fix(tools): align application verification fixtures
group 2 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools): bind Debian candidate evidence
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 4: docs(tools): record point 4 checkpoint
group 4 path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 5: docs(review): retain point 4 review exchanges
group 5 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 11)

Round 10's concrete findings are accepted. The transcript's recovery entry
and repeated guidance are redacted, duplicate recovery headings are qualified,
and the correction is explicitly recorded. The sensitive-content hook and
Markdown intersection check pass; the full Markdown check retains 39 existing
diagnostics, without changing the baseline or rules.

The human settled Q08's narrow helper exception and adopted Q09's shared
runtime mechanism subject to qualification. The fixture again requires
refusal outside the retained-helper scope. Its native cumulative run against
committed ad6d7ed8 correctly exposes the application scanner's broader
exemption; no cumulative green is claimed. The evidence reader also refuses
to treat those unmapped objects as whole-scope qualification.

The executable-RPATH premise in Q06, the design and item 8 is corrected using
the retained trace. The application shared runtime script derives the same
directory order as build_elf_rpath in a native fixture. An inherited-prefix
idempotence counterexample is retained and added to the application handoff.
That edge case is not assumed to occur in the Jenkins environment.

All 66 focused acceptance fixtures pass, including current and historical ABI
verdict formats, zero-runtime refusal, and the unresolved system-object scope.
The cumulative run's preceding shell lint checks 58 scripts successfully and
its independent helpers import on bare Python 3.9.25. The capture venv remains
separate. Real platform acceptance cannot be replaced by these fixtures.

Build 181 ran ad6d7ed8 and failed during Provision, exit 127. Host readlink
selected shipped libc after the shared runtime export and failed on
__rtld_libc_freeres (GLIBC_PRIVATE). Package, Test and Publish were skipped.
Only 24 artifacts were produced; there is no build 181 wheel/import evidence.
The independent reading binds PA1-PA4 pass and PA5-PA9 pending. Earlier
captures, including build 180's real import failure, remain unchanged.

Step 6 remains No. This is point 4's evidence checkpoint. Fresh RHEL consumer
qualification with Q07's venv scope and the settled runtime setup, D10 and
publication closure remain later work. No cplx commit is authorized.

### Implementation report for step 6 tools-archive-rebuild (round 11)

The Debian reader understands availability/runtime row counts while requiring
a complete zero-flags verdict and nonzero runtime rows when those fields are
present. Historical verdicts remain readable. System-loader objects outside
the retained-helper scope keep PA5/PA7 inconclusive; direct-import PA6/PA8
remain separate observations. Regression fixtures cover both changes.

The fixture no longer approves arbitrary system-loader objects. It preserves
the old refusal under confirmed Q08 and exposes the application regression.
Q09 adopts a library-only shared application setup, avoiding setenv's
unrelated environment changes and private account prerequisites. The documents
no longer claim that executable RPATH governs a wheel with its own RUNPATH.

The requestor's historical recovery prose has generic application wording and
unique headings. Live exchange artifacts and the reviewer's findings were not
edited. The application handoff records the independently reproduced runtime
ordering edge case and the confirmed decisions.

Build 181's 24 artifacts and raw console are retained with exact digests.
Both the original and current readers were run natively. The current reading
is incomplete, with PA1-PA4 pass and PA5-PA9 pending because Provision stopped
before consumer capture. Earlier wheel identities were not copied into the
new run. The handoff now also requires isolating host utility execution from
the shipped-libc environment across CI and deployment.

### Change summary for step 6 tools-archive-rebuild (round 11)

The staged work retains the five proposed commit groups, without committing:

- Keep committed application-helper provenance and the isolated capture venv
  in the native fixture transport; restore refusal for system-loader objects
  outside the retained-helper exception.
- Extend the independent evidence reader for availability/runtime counters,
  require nonzero runtime observations, and keep unqualified executable scope
  inconclusive. All 66 focused acceptance cases pass.
- Retain build 181 and its independent readings beside immutable earlier
  captures, update the candidate record and generated view, and preserve
  publication off and the incomplete Step 6 checkpoint.
- Correct the disproven executable-RPATH premise across requirement, design
  and item 8; record the human's Q08/Q09 decisions and require fresh RHEL
  qualification with Q07 before D10.
- Redact requestor recovery wording and distinguish duplicate historical
  headings; publish this response through the paired review renderer.

The ignored application handoff adds the independently reproduced runtime
ordering edge case. No application code or candidate archive was rewritten.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 11)

Human guidance:

The user asked to address round 10, run Jenkins on the application fixes at
ad6d7ed8, and publish round 11. The existing instruction to stop after
publication remains in effect. No cplx commit, D10 execution or release
publication is authorized by this checkpoint.

The human answered both round 10 decisions on 2026-09-20:

- Q08: keep the existing retained-helper exception; other executables must
  be qualified.
- Q09: adopt the shared runtime setup with shipped library directories first,
  unchanged wheel ELFs, and actual provider traces required on Debian and
  RHEL, subject to runtime qualification.

Writer response:

Accepted all three round 10 writer instructions. There were no reviewer repairs
to accept or reverse. No new disagreement is asserted, and the earlier human
resolution about unused dangling aliases remains settled.

The historical requestor recovery and its repeated guidance now use generic
application wording. The duplicate round-9/recovery headings are distinguished
and an editorial correction records the redaction. The final-index hook and
Markdown intersection checks are required again before publication.

The human selected Q08's existing helper exception, retaining the narrow assertion.
The application scanner still exempts system-loader objects elsewhere, so
the cumulative fixture fails at that exact boundary. The independent reader
keeps whole-scope acceptance inconclusive when such rows occur rather than
turning the scanner's PASS line into a scope waiver.

The human adopted Q09's shared application runtime setup, with implications for
Q06, fresh RHEL acceptance, D10 and item 8. The formerly asserted executable
RPATH mechanism is corrected. The native directory-order comparison passes;
an inherited-prefix idempotence edge case is recorded for application repair.
The reader consumes the new availability/runtime counts without conflating
forced availability with actual loading. No wheel ELF was modified.

The user requested a Jenkins retry on the committed application fixes, followed
by round 11 publication. The retained build and independent reading report
the actual outcome, with candidate pins unchanged and uploads off. Publication
of this request is the stopping point; no commit or later handoff point follows.

That retry is build 181, FAILURE in Provision: the shared export reaches
host readlink and causes a GLIBC_PRIVATE symbol failure against shipped libc.
The 24 retained artifacts prove no new wheel inventory, real import or pytest
run. PA1-PA4 pass; PA5-PA9 are pending in this run. The prior failed import
remains retained. The application handoff records this new integration failure
and requires a compatible loader/provider boundary for host tools as well as
the shipped interpreter; adoption of Q09 does not qualify this implementation.

### Reviewer focus for step 6 tools-archive-rebuild (round 11)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-11 -->

## Round 11 by reviewer - Step 6

- Recorded: 2026-09-20T12:40:01+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Exact disagreement for step 6 tools-archive-rebuild (exchange 1) (round 11)

The live index does not match the request-time index tree, so this round is
returned without an implementation assessment.

- Request-time index tree: `3280b1e74cd93c77a36c5378365f3fac819e80ad`.
- Live index tree at review entry, captured twice and stable:
  `79aa84c011ac8c046081f9e9b7d2e5d0ef85e1cb`.
- The difference is exactly one staged file,
  `docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md`, with 243 lines
  added and none removed: the protocol's own round 11 request record, from
  `## Round 11 by requestor - Step 6` through
  `### Reviewer focus for step 6 tools-archive-rebuild (round 11)`.

That record is written by the publication itself, after the request captures
the index, and it was then staged. Nothing in the implementation differs, and
the reviewer makes no claim that the staged work is wrong. The problem is only
that the described state and the reviewed state are not the same bytes: the
request's evidence, including its commit-plan result, describes an index the
repository no longer has, and every check the reviewer runs on the transcript,
the hook and the Markdown intersection check among them, would answer for a
different index than the one the request recorded.

Concrete writer action, either of:

- Leave the publication's own append unstaged while the round is under review,
  as rounds 3 to 10 of this step did, and publish the next request unchanged;
  the owning workflow can stage it with group 5 at commit time. In those
  rounds the transcript showed as staged plus unstaged, and the trees matched.
- Or stage it deliberately and then publish, so that the request captures the
  index after staging and its recorded tree is the one under review.

Nothing else is requested. The reviewer read the request, took the baselines
and stopped at this check: no validation command beyond the index capture was
run for the assessment, no repair was made, no staged path, `a.commit`,
validation plan or umbrella was touched, and the retained manifest records the
live tree.

For the record, so the next round is not slowed by it: the reviewer's own
round 10 answer copy in the staged transcript is byte-identical to what it
rendered, and the two lines the hook refused last round no longer carry the
application name.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 11)

Republish this round so that the recorded index tree is the one under review.
Either leave the publication's own transcript append unstaged while the round
is open, as rounds 3 to 10 did, or stage it first and publish afterwards, so
the request captures the index in its staged state. Change nothing else: the
staged implementation, the evidence, `a.commit` and the documents are not in
question here, and the reviewer made no change to them.

When the next request arrives, the reviewer will assess the round 11 work in
full: the Q08 and Q09 records, the restored fixture refusal, the reader's
availability and runtime counters, build 181's provisioning failure and the
corrected Q06 premise. Nothing in this answer prejudges any of it.

Two things are already confirmed and need no further work: the reviewer's
round 10 answer copy in the staged transcript is byte-identical to what it
rendered, and the installed hook now accepts the staged transcript, so the
round 10 blocking finding is resolved.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 11)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-11 -->

## Round 12 by requestor - Step 6

- Recorded: 2026-09-20T16:57:34+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 12)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 12

### Code review evidence for step 6 tools-archive-rebuild (round 12)

request_index_tree: aed587bd3a4ca871b306b88cb99dc6cdd480af88
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- bash .reviews/a.step6.r12-focused-transport.sh (sources: request)
- bash .reviews/a.step6.r12-runtime-transport.sh (sources: request)
- bash .reviews/a.step6.r12-bootstrap-transport.sh (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r12b-verify-record.py (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r12-check-build.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: fix(tools): align application verification fixtures
group 2 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools): bind Debian candidate evidence
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 4: docs(tools): record point 4 checkpoint
group 4 path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 5: docs(review): retain point 4 review exchanges
group 5 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 12)

Step 6 remains No. This request replaces returned round 11 at the user's
point 4 checkpoint; protocol numbering is round 12. The reviewer returned
round 11 solely because the requestor staged its transcript append after index
capture. That finding is accepted. Existing work is staged before rendering;
the new append remains unstaged while this request is open.

Build 183 ran application 97337c39, following bootstrap commit 7906fcbe and the
application's 30ef4422 runtime boundary repair. Its result is FAILURE.
Build 183 passes Provision and Package with shipped Python 3.13.15, its own pip 26.2.1 and relocated uv 0.12.17. The ABI gate passes (686 subjects, 603 dynamic, 732 availability rows, 265 runtime rows, 488 dangling links, zero flags), with both heavy wheels loaded by the direct trace. Test then exits 4 before collection: the command supplies a browser marker exclusion which the full-selection plugin rejects. The independent reader also leaves PA5/PA7 inconclusive for unresolved raw-map/canonical-provider alias bindings and reports PA6 fail because the console lacks its required literal locked-sync marker; those are evidence-reader limitations, not observed import failures.

Build 182 is preserved separately: shipped Python 3.13.15 created pip 26.2.1
and installed uv 0.12.17, but the new bootstrap validator incorrectly refused
the existing OneAgent exclusion before uv execution. The writer accepts that
defect. Commit 97337c39 reuses the scanner's provider policy without broadening
it; the retained map is also replayed through the exact embedded validator in
a native fixture that rejects host, unresolved and monitoring-only observations.

The independent reading binds PA1:debian pass; PA2:debian pass; PA3:debian pass; PA4:debian pass; PA5:debian inconclusive; PA6:debian fail; PA7:debian inconclusive; PA8:debian pass; PA9:debian inconclusive.
Raw build artifacts, committed application sources, original and current reader
outcomes and their digests are retained. Earlier captures remain unchanged.
The candidate archive and verification bundle pins are unchanged and uploads
remain off. No prior build's wheel inventory is attributed to this run.

The cumulative native fixture run passes on committed application 97337c39;
its final retained log is .reviews/a.step6.r12-cumulative-final-pass.log. The 71
acceptance-reader cases pass, including missing and failed system-executable
maps and visible monitoring exclusion. Agent fixtures require a map outside
tools/bin and reject host providers.
A separate native shell fixture passes installer-directory-order, inert
sourcing, command-local environment, inherited ordering and idempotence checks.
All 34 focused application boundary/scanner tests pass on Windows, with the 25
scanner tests repeated successfully for the bootstrap correction. ShellCheck
passes on the changed application scripts; cplx shell lint passes 58 scripts.

The fixture harness now supplies the scanner's required runtime data and
recognizes direct pytest interpreter execution. Initial failures at those
obsolete fixture assumptions are retained alongside the corrected successful
run. No runtime trace or provider gate was suppressed.

Fresh RHEL consumer qualification, host-subprocess behavior, D10 and publication
closure remain later work. The proposed DT_NEEDED change has not been tested or
adopted. Local fixtures do not prove glibc behavior. No cplx commit is authorized.

### Implementation report for step 6 tools-archive-rebuild (round 12)

The application now bootstraps its tooling through the shipped Python
3.13.15, creates an isolated pip environment, installs uv and relocates that
binary's interpreter and RPATH. It records the Python/pip identity, uv version,
hash, loader, RPATH and provider map, retaining recognized OneAgent exclusions
and refusing other external runtime providers through the scanner's policy.
Locked sync uses that uv and explicit shipped Python with downloads disabled.
Post-relocation inventory, scanner and test-evidence authoring also use shipped
Python. Application wheel ELFs, canonical lock and no-tooling scope are preserved.

The cplx reader accepts system-loader coverage only when retained per-subject
maps match availability rows. The fixture checks actual measurement outside the
retained-helper exemption and refusal of a host provider. Runtime trace remains
separate and blocking. Documentation records the per-command setup, the user's
bootstrap requirement and remaining host-child inheritance risk. Builds 182/183 and
its independent readings are added without rewriting historical captures.

### Change summary for step 6 tools-archive-rebuild (round 12)

The proposed cplx commit plan retains five groups, without executing them:

- Evidence portability: timestamp parsing and availability/runtime counters,
  with retained per-subject maps required for non-helper system executables.
- Application verification fixtures: explicit capture interpreter, committed
  helper provenance, required runtime data, narrow helper exemption and host
  provider refusal, with direct pytest interpreter wiring.
- Debian evidence: retain builds 182 and 183 and both independent reader outcomes beside
  unchanged earlier captures; bind the current candidate record and generated
  view to the actual result, preserving incomplete acceptance and uploads off.
- Runtime contract: preserve Q06 correction and Q07/Q08/Q09 decisions, add the
  user's shipped Python/pip/relocated-uv requirement and host-child risk.
- Review transcript: retain the returned round and earlier editorial repairs;
  stage existing content before request capture and leave the new append unstaged.

Separately, application commit 7906fcbe adds ci/tools_bootstrap_uv.sh, wires it
into provisioning, uses the relocated interpreter for post-relocation evidence
authoring and adds the helper to ShellCheck. That commit is pushed on the three
application develop remotes and is the exact input to build 182.
Commit 97337c39 corrects the omitted existing OneAgent exclusion by reusing the
scanner's provider policy. It is pushed to the same remotes for build 183.

### Human guidance and writer response for step 6 tools-archive-rebuild (round 12)

Human guidance:

The user requests the replacement for returned round 11 after a Jenkins job,
and explicitly requires relocated Python 3.13.15 to bootstrap pip and uv, with
uv itself relocated before locked dependency synchronization. Protocol numbering
advances the replacement to round 12; round 11 remains preserved.

Q08 keeps only the existing retained-helper exception. Q09 adopts the shared
runtime setup subject to real provider traces on Debian and fresh RHEL.
Application wheel ELFs and canonical public-lock identities remain unchanged.

Publish this evidence checkpoint and stop. No cplx commit, reviewer invocation,
D10 or immutable release publication is requested. Assess the staged index
captured in the request; the newly appended transcript entry remains unstaged.

Writer response:

Round 11's index mismatch is accepted. The reviewer made no implementation
assessment or repairs. The writer had staged the publication's own transcript
append after request capture. For this replacement, all existing changes and
the retained answer are staged before rendering; the new publication append
will remain unstaged. No disagreement is asserted.

The human then requested a Jenkins retry on the application boundary repair,
with shipped Python 3.13.15 bootstrapping its own pip and relocated uv. The
application successor 7906fcbe implements that instruction on top of 30ef4422.
It is committed and pushed separately; no cplx commit or release is performed.
Build 182 confirms that bootstrap but stops before uv execution because the
new checker omitted the existing OneAgent exclusion. The writer corrected that
defect in application 97337c39 by reusing the scanner policy, retaining visible
monitoring rows and refusal of all other external providers. Build 183 tests
that correction. Both exact outcomes are retained in the assessment and evidence.

Q08 remains the narrow retained-helper exception. Other executables now have
forced maps, labelled availability. The cplx fixtures require those objects
to be mapped and reject a host provider; the evidence reader requires retained
per-subject maps and corresponding availability rows. Missing or unusable maps
remain inconclusive. This is qualification of availability, not a claim that
the executable or its child processes ran successfully.

Q09 remains adopted subject to qualification. Native fixture checks confirm
the directory order matches build_elf_rpath, sourcing leaves the caller's
LD_LIBRARY_PATH unchanged, and command-local composition reorders inherited
shipped entries correctly and is idempotent. The cumulative harness now supplies
the required scanner runtime data and follows the direct pytest interpreter
entry. Its initial stale-fixture failures and successful corrected run remain
retained. No provider policy or actual import check was weakened.

The suggested interpreter DT_NEEDED additions remain an untested proposal.
Host subprocess inheritance is still a qualification risk. New archive bytes,
fresh RHEL qualification, D10 and publication are not claimed by this review.
After publishing protocol round 12, stop as instructed; do not wait or commit.

### Reviewer focus for step 6 tools-archive-rebuild (round 12)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-12 -->

## Round 12 by reviewer - Step 6

- Recorded: 2026-09-20T17:09:02+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 12)

Baseline index tree: aed587bd3a4ca871b306b88cb99dc6cdd480af88

Assessed index tree: aed587bd3a4ca871b306b88cb99dc6cdd480af88

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 12)

Result:

No. Step 6 has NOT been fully implemented.

Build 183 is the best result this step has produced: the Q09 runtime setup
works, both heavy wheels load, and the ABI gate passes. The test walk then
stops before collection, three Debian cells stay inconclusive, and PA6 is
recorded as a failure it did not observe. D10, the fresh RHEL qualification at
the Q07 scope and the publication obligations remain open.

Verified rather than accepted:

- Round 11's finding is fixed: the request-time tree equals the live index, and
  the publication's own append is left unstaged.
- Builds 182 and 183. The Jenkins API reports `FAILURE` for both, from
  application `7906fcbe` and `97337c39`, and both live console digests equal the
  recorded ones (`01c98991...d29a` and `48ccb182...e527`).
- The ABI verdict is exactly as claimed:
  `ABI PASS: subjects=686 dynamic=603 availability-rows=732 runtime-rows=265
  dangling-links=488 flags=0`.
- The heavy wheels load. The retained `abi/imports.txt` reads `wheels load`,
  where build 180's read an `ImportError` on host libpthread. PA8 passes with
  one direct-venv trace and zero host flags. That is the Q09 mechanism doing
  what round 10 said it had to do.
- The test walk exits 4 before collection with
  `ERROR: Tools acceptance requires coverage and full testmon selection`, so
  PA9 is correctly inconclusive for missing `tests.json` and `coverage.xml`.
- The reader change is conservative and matches Q08: a system-loader object
  outside the retained-helper scope must carry its own retained map whose
  providers all appear as availability rows, with monitoring exclusions limited
  to recognized OneAgent names in known directories and no path trickery; an
  unmapped or unusable map yields `inconclusive`, never a pass. The
  availability and runtime counters are accepted only inside a complete
  `flags=0` line with nonzero runtime rows.
- The fixtures now require a forced map outside `tools/bin`, refuse a host
  provider, keep the narrow helper exception, and check that the test walk
  runs pytest through the shipped runtime rather than `uv run`.
- The bootstrap and runtime decisions are recorded in the requirement, design
  and umbrella, including the per-command boundary that build 181 forced and
  the unresolved host-child inheritance risk.
- All ten declared commands pass, including 71 focused acceptance cases, the
  runtime ordering fixture and the bootstrap validator fixture.

The one thing the evidence does not support is PA6's state. Its pass branch
requires three things: `wheels load` in the imports evidence, a `venv_base=`
line, and the literal string `uv sync --locked` in the console. The first two
are present; the third appears zero times, because the bootstrap now invokes
the relocated uv differently. The locked synchronization did happen: the
declared build checker confirms the relocated uv executed and captured 77
canonical locked wheel hashes. So the cell is recorded `fail` with the reason
"heavy wheel imports or the locked sync are not evidenced" while the retained
evidence shows the imports succeeded and the sync ran. The driver treats
unobservable evidence as `inconclusive` everywhere else in this same round,
including PA5, PA7 and PA9; PA6 deserves the same distinction, and it matters
because a PA6 failure is what drove the Step 5 repackage earlier in this step.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 12)

- Distinguish an absent marker from an observed failure for PA6: emit a stable
  locked-sync marker from the pipeline, and split the reader's branch so a
  missing marker is inconclusive while a real import failure stays fail. Then
  rebind PA6 from the evidence.
- Resolve the test-walk selection so the walk reaches collection, and obtain
  PA9's `tests.json` and `coverage.xml`.
- Qualify the system-loader objects that keep PA5 and PA7 inconclusive.
- Qualify host subprocess inheritance under the per-command runtime boundary.
- Repeat RHEL acceptance at the Q07 scope with the settled runtime setup, take
  the D10 reading, and complete the pre-publication obligations.

Architecture: the runtime boundary is applied per command rather than to the
operator shell, which is what build 181's failure required. Performance: no
new cost. Unit test coverage: no Python class changed and no percentage is
claimed; no unit-tested class below 100% needs completing, and no top-level
symbol outside the coverage gate is unreferenced.

Feature integrity: host providers, unmapped objects, malformed verdicts and
unresolved maps are all still refused, and earlier captures are unchanged.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows record builds 182 and 183, the bootstrap requirement,
the per-command runtime boundary and the cells as measured. The PA6 labelling
finding belongs in those rows once the pipeline or the reader is changed, so
the reviewer leaves it in this answer rather than writing a row that would
presume which of the two fixes is chosen.

The status sentence stays exactly `No. Step 6 has NOT been fully implemented.`,
and the document-level line stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 12)

The reviewer ran all ten resolved commands. All ten pass.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  transport exit 0 in 106 seconds, native `validation exit=0 elapsed=81s`,
  against committed application `97337c39`.
- The focused transport, source `request`: `PASS tools-release-acceptance: 71
  cases`, exit 0.
- The runtime transport, source `request`: `PASS installer directory order,
  inert sourcing, command boundary, inherited-prefix reordering, idempotence`.
- The bootstrap transport, source `request`: the exact embedded validator
  accepts the retained OneAgent scope and refuses host, monitoring-only and
  unresolved maps.
- The build 183 record verifier, source `request`: both `PASS` lines.
- The build checker, source `request`: builds 182 and 183 identities, isolated
  shipped Python and pip, relocated uv loader and RPATH, 77 canonical locked
  wheel hashes, 80 ELF captures, heavy-wheel trace passed, walk refused before
  collection.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 on the 39
  older findings only.
- The Markdown intersection checker, source `request`: `PASS`.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`: both clean. The hook accepts the staged transcript, so round 10's
  blocking finding stays resolved.

Measured independently: builds 182 and 183 through the Jenkins API, with both
live console digests equal to the recorded ones; the ABI verdict line; the
absence of the literal `uv sync --locked` and the presence of `venv_base=` in
build 183's console; the retained `abi/imports.txt` reading `wheels load`; the
test walk's exit 4 message; and the staged transcript, where the reviewer's
round 11 answer copy is byte-identical, no private identifier appears and no
heading repeats.

The reviewer removed its scratch fixture from the RHEL host. The other native
commands reused the writer's retained fixture without modifying it. No
coverage percentage is claimed.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 12)

The reviewer ran the union of the request validation set and the current
resolver set: the same ten commands, each after reading the scripts it runs.

- `bash src/utils/lint_shell.sh`, source `project`.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`.
- The focused, runtime and bootstrap transports, source `request`. They reuse
  the writer's retained host fixture; the reviewer read each script and its
  native half before running and changed nothing there.
- The build 183 record verifier and the build checker, source `request`.
- The Markdown gate and its intersection checker, source `request`.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`.

All ten exit as expected, the Markdown gate on older debt only.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 12)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets. The three new native transports widen what the
round proves, which is the direction the no-removal rule protects.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 12)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `aed587bd3a4ca871b306b88cb99dc6cdd480af88` equals the
  baseline at entry and the live index after every run. Round 11's mismatch is
  resolved.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `f3a04d8910e6dfad1f62c4b0f3d9b0609b60422db39f7fa53e0652fa34cfba7a`.
  No umbrella row was completed.
- Validation-state comparison over the 30 staged paths, the project command's
  file and the nine ignored validation files: `acceptable: true` with empty
  lists.
- The working tree matches its entry state: 30 staged paths, plus the
  protocol's unstaged transcript append.
- No reviewer residue: the cumulative run's scratch fixture was removed, the
  writer's retained fixture was reused without modification, and the
  application checkout was only read.
- The baselines and manifest were written before assessment and the manifest
  rewritten after.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 12)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 12)

`a.commit` is accurate and executable, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 30 staged paths in five
ordered groups matching the request. The installed hook accepts the index.

- Group 1, evidence portability: the composer, the reader and its fixtures.
- Group 2, verification fixtures: the agent fixture, both runners and the plan
  text for the capture and map boundaries.
- Group 3, Debian evidence: all fourteen sidecars from builds 176 to 183 with
  the record and its view.
- Group 4, runtime contract: requirement, design, validation plan and umbrella.
- Group 5, the transcript.

Ordering is least to most dependent and every staged path appears once. The
PA6 finding, once fixed, touches group 1 and group 3 together, since the
reader and the bound cell change in the same step.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 12)

Unresolved findings:

- PA6:debian is recorded `fail` for evidence the run did not produce rather than for an observed failure: the reader's pass branch needs the literal `uv sync --locked` in the console, which appears zero times in build 183 because the bootstrap invokes the relocated uv differently, while `venv_base=` is present, the retained `abi/imports.txt` reads `wheels load`, and the declared build checker confirms the relocated uv executed and captured 77 canonical locked wheel hashes; the same round records PA5, PA7 and PA9 as inconclusive for unobservable evidence, so PA6 should either be driven by a stable marker the pipeline emits or split so that an absent marker is inconclusive and only an actual import or sync failure is a fail.

Boundary-crossing work:

- Host subprocess inheritance under the per-command runtime boundary is still unqualified: build 181 showed that a process-wide export makes host utilities load shipped libc, and the documents record the risk, but nothing yet measures what a host child of a shipped process inherits on either platform; that qualification spans the application's runtime helper and the cplx acceptance contract

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 12)

Human guidance:

The user requests the replacement for returned round 11 after a Jenkins job,
and explicitly requires relocated Python 3.13.15 to bootstrap pip and uv, with
uv itself relocated before locked dependency synchronization. Protocol numbering
advances the replacement to round 12; round 11 remains preserved.

Q08 keeps only the existing retained-helper exception. Q09 adopts the shared
runtime setup subject to real provider traces on Debian and fresh RHEL.
Application wheel ELFs and canonical public-lock identities remain unchanged.

Publish this evidence checkpoint and stop. No cplx commit, reviewer invocation,
D10 or immutable release publication is requested. Assess the staged index
captured in the request; the newly appended transcript entry remains unstaged.

Guidance response:

The guidance is followed on every point.

- The staged index captured in the request is what was assessed: the trees
  match, and the new append is unstaged.
- The bootstrap instruction is implemented and verified: shipped Python 3.13.15
  creates its own pip environment, installs uv, and that uv is relocated before
  the locked synchronization, with its loader, RPATH and provider map retained.
- Q08 stays narrow and Q09 stays adopted subject to qualification. Both are
  recorded, and the fixtures enforce them rather than assert them.
- Step 6 stays `No`. No commit, reviewer invocation, D10 or publication was
  performed or is authorized, and the application checkout was only read.

The disposition is changes-requested because Step 6 is incomplete by design
and because PA6 is labelled a failure the evidence does not show.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 12)

The staged work needs one correction, and the rest is next-step execution.

__Give PA6 a truthful label.__ Its pass branch requires the literal
`uv sync --locked`, which build 183's console never prints, while the retained
evidence shows the wheels load and the declared build checker confirms the
relocated uv executed and captured 77 canonical locked wheel hashes. Emit a
stable locked-sync marker from the pipeline, since that is the pipeline's own
claim to make, and split the reader's branch so an absent marker is
inconclusive while an actual import or sync failure stays a fail. Then rebind
PA6 from the evidence. Keep the cell blocking either way; this is about not
recording a failure that was not observed, in the cell whose earlier failure
justified a full repackage.

__Then the remaining Debian work.__ Fix the test-walk selection so the walk
reaches collection and produces `tests.json` and `coverage.xml` for PA9, and
qualify the system-loader objects that hold PA5 and PA7 inconclusive.

__Then qualification.__ Measure what a host child of a shipped process
inherits under the per-command boundary, repeat RHEL acceptance at the Q07
scope with the settled runtime setup, and take the D10 reading.

Done well, and worth saying plainly: round 10's `RUNPATH` finding was turned
into Q09, implemented per command after build 181 showed the ambient export
breaking host utilities, and build 183 now loads both heavy wheels with a
clean ABI verdict. The reader was tightened rather than loosened at every
step, the failing builds were kept with their raw evidence, and round 11's
index finding was accepted without argument.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 12)

The disposition is changes-requested and the readiness floor is recorded as
incomplete.

1. Identity. Passes; the request tree equals the live index at entry and after
   every run, which round 11 had returned.
2. Completeness. Fails by design, and the remaining work is now concrete.
3. Validation and coverage. Passes; all ten declared commands behave as
   expected.
4. Staged attribution. Passes; the reviewer made no repair.
5. Unresolved findings. One: PA6's label.
6. `a.commit`. Passes, valid, ready and accepted by the hook.

This round earns its result. The mechanism round 10 measured became Q09,
build 181 proved that applying it ambiently breaks host utilities, and the
per-command boundary in build 183 makes both heavy wheels load with a clean
ABI verdict. That is the first time this step has shown the shipped providers
actually serving the wheels.

The single finding is about labelling, not about substance: a cell that
reports a failure the run did not observe is the same class of problem as a
pass without evidence, and this step has been careful about that distinction
everywhere else, including PA5, PA7 and PA9 in this very round.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 12)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-12 -->

## Round 13 by requestor - Step 6

- Recorded: 2026-09-20T19:19:57+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 13)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 13

### Code review evidence for step 6 tools-archive-rebuild (round 13)

request_index_tree: 31f986b8e457df460723f034d210a51b96e359fb
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- bash .reviews/a.step6.r13-focused-transport.sh (sources: request)
- bash .reviews/a.step6.r12-runtime-transport.sh (sources: request)
- bash .reviews/a.step6.r12-bootstrap-transport.sh (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r13-verify-record.py (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r13-check-build.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: fix(tools): align application verification fixtures
group 2 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools): bind Debian candidate evidence
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184-retention.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 4: docs(tools): record point 4 checkpoint
group 4 path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 5: docs(review): retain point 4 review exchanges
group 5 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 13)

Step 6 remains No. Round 13 accepts round 12's single finding: missing PA6
evidence is inconclusive, while an observed import or locked-sync failure is
fail. No reviewer repair was reversed. An independent native rereading of the
original build 183 changes only PA6's classification; its historical sidecars
remain unchanged, with the rereading and its digests retained separately.

Build 184 ran the exact supplied application 4093c353. Result:
FAILURE. Build 184 passes Provision and Package with shipped Python 3.13.15, its own pip and relocated uv 0.12.17. The ABI gate passes with 686 subjects, 603 dynamic objects, 732 availability rows, 265 runtime rows, 488 dangling links and zero flags. The repaired selector allows pytest to run: 11 failed, 6438 passed, 15 skipped, 31 deselected and 9 xfailed; coverage is 99.90%, below the unchanged 100% gate. A host Bash child demonstrably inherits the shipped libc and fails on its GLIBC_2.36 requirement before the brownout harness starts. Ten runtime-boundary tests also fail at the host Bash launch, but their retained exception summaries do not include child stderr. Publish is skipped and publication remains off.

The current independent reading binds: PA1:debian pass; PA2:debian pass; PA3:debian pass; PA4:debian pass; PA5:debian inconclusive; PA6:debian inconclusive; PA7:debian inconclusive; PA8:debian pass; PA9:debian fail.
The new build 184 sidecars retain exact source, lock, wheel, reader and console
identities. Original and current reader outcomes are both retained. No earlier
build's evidence is attributed to this run. Candidate pins and publication-off
state remain unchanged; no application source was changed in this round.

PA9 supports the application's existing stealth-gate Q01 CI scope. It requires
the exact authorized marker, unique excluded identities and browser markers,
matching console/report counts and scope, and the committed application
validator's coverage, nonselecting testmon and guarded SQLite-suite gates.
This scope is not browser evidence. Broader application-local success claims
are reported by the application, not independently rerun by cplx this round.

Validation: the cumulative native fixture run passes in 84 seconds on the
committed application, with its full provenance in
.reviews/a.step6.r13-cumulative-retry.log. The 83 focused acceptance-reader
cases pass (.reviews/a.step6.r13-focused.log). The initial cumulative failure
is retained: updated application hook annotations require a newer interpreter
than the fixture's bare Python 3.9. Hook fixtures now use the existing explicit
application interpreter; independent evidence reading still uses Python 3.9.
Shell lint passes all 58 tracked scripts. Existing runtime-boundary and
bootstrap-policy fixtures remain applicable and their exact commands remain
in the resolved validation set. Local fixtures do not qualify native glibc.

The generated release view, raw artifact digests, historical captures,
consumer invalidation, candidate pins and publish-off state are checked by the
round 13 record and build validators. Markdown retains 39 existing diagnostics,
with none on added lines. Cached whitespace, the sensitive-content hook and
the five-group, 32-path commit plan all pass before publication. The initial
ignored build-check helper used the Windows default text encoding for the
Jenkins console; explicit UTF-8 corrected that diagnostic-only helper and the
complete build check then passed.

Stable locked-sync emission, unresolved path-alias evidence, fresh RHEL
consumer qualification, host-subprocess qualification, D10 and publication
closure remain open as recorded in the actual build outcome. The suggested
DT_NEEDED change remains untested and unadopted. Existing changes and transcript
entries are staged before rendering; round 13's append remains unstaged. The
user requests publication and stop, with no cplx commit or reviewer invocation.

### Implementation report for step 6 tools-archive-rebuild (round 13)

The cplx Debian reader distinguishes missing PA6 observations from retained
import or sync errors. It recognizes a stable locked-sync marker for a future
pipeline emitter while continuing to require import and venv identity evidence.
Current application sources do not emit that marker; its absence is blocking,
not a claimed runtime failure.

PA9 accepts the application's exact Q01 CI scope only when its console scope
and counts match tests.json, exclusions have unique nonempty identities and
browser markers, and the committed application validator passes the coverage,
testmon and SQLite-suite gates. Legacy full-scope records remain supported.
The reader does not present browser-excluded evidence as an all-tests walk.

Native fixtures cover missing/failing PA6 evidence and valid/invalid browser
scope, counts and identities. Application hook fixtures use the explicit
application interpreter required by current hook annotations. Requirement and
design text make these evidence boundaries explicit. New build 184 sidecars
and the current release-record binding preserve all earlier captures.

### Change summary for step 6 tools-archive-rebuild (round 13)

Five proposed cplx commit groups remain, with no commit executed:

- Evidence portability: PA6 missing/failure classification and PA9 Q01 scope
  binding join the existing conservative loader-map reader changes and fixtures.
- Application verification fixtures: use the explicit application interpreter
  for application hooks, preserving bare independent evidence reading.
- Debian evidence: add build 184 reading/retention sidecars and bind the record
  and generated view to the exact result without rewriting historical captures.
- Runtime contract: record Q01 CI scope and distinguish absent PA6 evidence
  from failure, alongside the existing Q08/Q09 and bootstrap requirements.
- Review transcript: stage existing entries before request capture, leaving
  round 13's own append unstaged after publication.

The application checkout is unchanged in this round. Its supplied revision
4093c353 is retained in Jenkins and reader provenance. Step 6 remains incomplete.

Staged path inventory:

- ci/deliver-closure-tools.sh
- docs/v0.27.0/acceptance.tools-archive-rebuild.json
- docs/v0.27.0/acceptance.tools-archive-rebuild.md
- docs/v0.27.0/acceptance.tools-archive-rebuild.sh
- docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
- docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/fixtures.tools-release-agent.py
- docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
- docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/verify.tools-archive-rebuild.sh
- docs/v0.27.0/verify.tools-release-acceptance.sh
- docs/v0.27.0/verify.tools-release-agent.sh

### Human guidance and writer response for step 6 tools-archive-rebuild (round 13)

Human guidance:

The user asks for round 13 after testing Jenkins on the supplied application
revision 4093c353. Assess the actual build and the round 12 repair, retaining
remaining blockers rather than declaring Step 6 complete. The user preserves
shipped Python 3.13.15, its own pip and relocated uv before locked sync.

Publish round 13 and stop. No cplx commit, reviewer invocation, QAL deployment,
D10 or release publication is authorized by this checkpoint. Assess the index
captured in the request; the new transcript append remains unstaged.

Writer response:

Round 12's single finding is accepted without disagreement. The reviewer made
no repairs and staged no paths. The reader had conflated missing PA6 evidence
with an observed import failure. The writer now classifies missing evidence
as inconclusive and explicitly observed import or locked-sync failures as fail.
Regression cases cover the absent marker, absent imports, explicit failures,
and the proposed stable marker. No pipeline success is substituted for evidence.

The user supplied application 4093c353 and requested a Jenkins run before round 13.
That exact revision is the input to build 184. No application source was
changed by the requestor in this round. The application implements its existing
stealth-gate Q01 browser exclusion; the cplx reader now binds that scope, counts
and unique excluded identities to the report and re-runs the application reader.
Other narrowing, missing guarded-suite execution and sub-gate coverage remain
refused. This CI scope is explicitly not browser evidence.

The native cumulative run initially exposed an outdated fixture assumption:
the application plugin now uses annotations requiring Python 3.10 or newer,
while the fixture invoked it through bare Python 3.9. Application hook fixtures
now use the existing explicit application interpreter. Independent evidence
reading remains on bare Python 3.9; no application source or dependency is
rewritten to suit the fixture. The corrected cumulative run and 83 focused
acceptance cases pass; the initial failure remains retained.

Build 183's historical reader result is preserved unchanged and identified as
superseded interpretation. The new build's current cells use the corrected
reader. Candidate pins, wheel ELFs, provider policy and publication-off state
are unchanged. Stable locked-sync emission, path-alias evidence, host-child
qualification, fresh RHEL acceptance, D10 and publication closure remain open
unless the retained build evidence explicitly settles them.

All existing changes and the retained round 12 answer will be staged before
rendering round 13. Its new publication append remains unstaged. Publish and
stop as instructed; no cplx commit or reviewer invocation.

### Reviewer focus for step 6 tools-archive-rebuild (round 13)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-13 -->

## Round 13 by reviewer - Step 6

- Recorded: 2026-09-20T19:51:56+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 13)

Baseline index tree: 31f986b8e457df460723f034d210a51b96e359fb

Assessed index tree: 31f986b8e457df460723f034d210a51b96e359fb

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 13)

Result:

No. Step 6 has NOT been fully implemented.

Build 184 is the first run in this step whose acceptance walk actually
executes, and it turns round 12's unqualified host-child risk into a measured
failure with a retained case. Round 12's PA6 finding is fixed exactly as
instructed. PA5, PA6 and PA7 stay inconclusive, PA9 fails, and D10, the fresh
RHEL qualification at the Q07 scope and the publication obligations remain
open. Three things need attention, and two of them are in the round 13 append
rather than in the staged work.

Verified rather than accepted:

- The PA6 split is right and conservative in all three branches. The cell now
  fails only on an observed import traceback or an explicit
  `TOOLS-LOCKED-SYNC/1 state=failed` marker; it passes only with `wheels load`,
  a `venv_base=` line and a passed marker (or the earlier literal); otherwise
  it is inconclusive. It stays blocking either way, as asked. Build 184 records
  it inconclusive because the pipeline does not yet emit the marker, and the
  request says so rather than claiming the sync.
- The reassessment of the original build 183 artifacts changes `PA6:debian`
  from `fail` to `inconclusive` and nothing else. The declared checker asserts
  that cell by cell against the committed reading, and both raw digests match.
- Build 184 itself: the Jenkins API reports `FAILURE` from application
  `4093c353`, and the live console digest equals the recorded
  `eb648176...128b`.
- The ABI verdict is exactly as claimed: `ABI PASS: subjects=686 dynamic=603
  availability-rows=732 runtime-rows=265 dangling-links=488 flags=0`.
- The walk ran: `11 failed, 6438 passed, 15 skipped, 31 deselected, 9 xfailed`
  in 232.85 seconds. Coverage is 99.90%, 27203 of 27231 lines, and the console
  carries `FAIL Required test coverage of 100% not reached`.
- The eleven failures share one cause, and it is precisely the qualification
  round 12 left open: `/usr/bin/bash: ... version 'GLIBC_2.36' not found
  (required by /usr/bin/bash)`. A host child of a shipped process inherits the
  library path and loads the shipped libc. One brownout lifecycle case and ten
  runtime-boundary cases fail there. The record names the observed case, calls
  the other ten an inference pending their stderr, and refuses to suppress
  them. That is the honest reading.
- PA9 fails before its new scope logic is reached: no acceptance PASS line
  exists, so the reader never consults the report. The recorded reason is
  exactly that.
- Where the scope binding does apply, it is tight: `markexpr` limited to empty
  or `not browser`, unique non-empty excluded identities, every exclusion
  marked `browser`, the console phrase and the marker forced to agree in both
  directions, collected, executed and setup-skipped reconciled, `excluded=N`
  equal to `deselected`, the application's own committed validator required to
  return zero, and `coverage=100%` still demanded in the same summary line. The
  gate is not lowered.
- The wheels: 77 canonical locked hashes equal to application `4093c353`'s
  committed lock, 80 ELF captures, no tooling wheel, the archived lock
  identical to the committed one, and `abi/imports.txt` reading `wheels load`.
- Ten of the eleven declared commands behave as declared, including 83 focused
  acceptance cases and a cumulative native run of 254 cases at exit 0 from the
  committed application revision.

Three things do not hold.

The round 13 append carries the application's private repository name twice.
The staged index has never carried it: the effective replacement rules map that
name to `my-project`, and the whole effort has respected that. The hook passes
today only because the append is unstaged, and the hook checks staged blobs
only. Run against those two lines, the same checker reports sensitive content
and blocks. Group 5 of `a.commit` stages that transcript, so the next commit
is refused unless the append is reworded first.

The declared Markdown intersection checker fails on the same append. Transcript
line 13629 begins with a number and a period, wrapped from the previous line,
which Markdown reads as an ordered-list item, so MD032 fires. The request's
claim of 39 diagnostics with none on added lines was true when it was measured,
before publication created the append; my run measures 40, and the one new
finding is that line. This is the same class the writer repaired for the
reviewer's own round 3 instructions.

PA9's scope narrowing is recorded, but not the way this effort records scope
decisions. The requirement's PA9 row still reads "Full application acceptance
suite", while a new paragraph below it authorizes certifying the application's
CI scope with browser-marked cases excluded. Q06, Q07, Q08 and Q09 are each a
dated numbered decision with the human's answer, and the paragraph immediately
above this one carries its own "human decision of 2026-09-19" attribution. This
paragraph carries none, and the request attributes the human only the supplied
application revision and the Jenkins run. The narrowing is defensible, tightly
fenced and currently inert, since PA9 fails for other reasons; it still changes
what a required cell may certify, and the browser cases are the ones closest to
the wheel that already refused capture in build 177.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 13)

- Reword the round 13 append so the application's private name does not enter
  the transcript, and reflow line 13629 so no wrapped line starts with a number
  and a period. Both must be clean before group 5 is committed.
- Record the PA9 CI-scope narrowing as a numbered human decision, or withdraw
  it. If it is confirmed, amend the PA9 row so the table and the prose agree.
- Qualify the shipped-process to host-child boundary before exec, retain the
  child stderr for the ten inferred cases, and rerun the host shell cases.
- Restore the unchanged 100% coverage gate.
- Emit the stable locked-sync marker so PA6 can bind to evidence.
- Qualify the system-loader objects that hold PA5 and PA7 inconclusive.
- Repeat RHEL acceptance at the Q07 scope with the settled runtime setup, take
  the D10 reading, and complete the pre-publication obligations.

Architecture: the runtime boundary stays per command, and build 184 shows the
cost of that choice at the process edge rather than hiding it. Performance: the
walk adds 232.85 seconds to the pipeline; no other new cost. Unit test
coverage: no Python class changed in cplx and no percentage is claimed for it;
no unit-tested class below 100% needs completing, and no top-level symbol
outside the coverage gate is unreferenced. The application's own 99.90% is
reported as a failure against its unchanged gate, not adopted as a new one.

Feature integrity: host providers, unmapped objects, malformed verdicts,
unresolved maps, broader test narrowing and sub-gate coverage are all still
refused, and earlier captures are unchanged.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows record build 184, the PA6 classification split, the
CI test scope and the cells as measured. The three findings belong in those
rows only after the append is reworded and the human answers the PA9 scope
question, so the reviewer leaves them in this answer rather than writing rows
that would presume either outcome.

The status sentence stays exactly `No. Step 6 has NOT been fully implemented.`,
and the document-level line stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 13)

The reviewer ran all eleven resolved commands. Ten behave as declared; the
Markdown intersection checker fails on the round 13 append.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  native `validation exit=0 elapsed=85s`, 254 cases, zero failures, against
  committed application `4093c353` with the three committed helper digests
  verified on the host.
- The focused transport, source `request`: `PASS tools-release-acceptance: 83
  cases`, exit 0, including both directions of the new scope binding and the
  PA6 classification cases.
- The runtime transport, source `request`: `PASS installer directory order,
  inert sourcing, command boundary, inherited-prefix reordering, idempotence`.
- The bootstrap transport, source `request`: the exact embedded validator
  accepts the retained scope and refuses host, monitoring-only and unresolved
  maps.
- The round 13 record verifier, source `request`: both `PASS` lines.
- The build checker, source `request`: all four `PASS` lines, covering the
  exact application identity, the shipped Python and pip, the relocated uv and
  its providers, 77 canonical locked wheel hashes, 80 ELF captures, the
  retained failing walk with its 31 identified browser exclusions and passing
  guarded suites, and the build 183 reassessment touching only PA6.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1, as
  expected for the repository's older debt, but 40 diagnostics rather than the
  39 the request measured.
- The Markdown intersection checker, source `request`: fails. The one new
  finding is `review.code.v0.27.0.tools-archive-rebuild.md:13629: MD032`, on a
  line of the round 13 append that begins with a number and a period after a
  wrapped sentence. Nothing in the staged tree is implicated.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`: both clean against the staged index. The hook checks staged blobs
  only, so it does not see the append.

Measured independently: build 184 through the Jenkins API, with the live
console digest equal to the recorded one; the ABI verdict line; the pytest
summary, the coverage failure line and the host Bash `GLIBC_2.36` message in
the retained walk; the commit plan through the shared readiness checker; and
the staged transcript, where the reviewer's round 12 answer is byte-identical
in all three sections and no heading repeats.

Two measurements were taken beyond the declared set, both read-only. The
effective sensitive-replacement rules were read, and the round 13 append's two
offending lines were passed to the same checker the hook runs, in its message
mode, against the cplx root: it reports sensitive content and blocks. The index
was not touched to obtain that result.

The reviewer removed its own scratch fixture from the RHEL host after the
cumulative run. The other native commands reused the writer's retained fixture
without modifying it, and the application checkout was only read. No coverage
percentage is claimed for cplx.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 13)

The reviewer ran the union of the request validation set and the current
resolver set: eleven commands, each after reading the scripts it runs.

- `bash src/utils/lint_shell.sh`, source `project`.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`.
- The round 13 focused transport, source `request`, read before running: it
  copies three committed documents to the retained host fixture and runs the
  native half from the reviewer's own side.
- The runtime and bootstrap transports, source `request`, unchanged since
  round 12 and reused without modification.
- The round 13 record verifier and the build checker, source `request`, both
  read in full before running.
- The Markdown gate and its intersection checker, source `request`.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`.

Ten exit as expected. The Markdown gate exits 1 on repository debt, which is
expected, but its declared interpreter then fails on a new diagnostic in the
round 13 append.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 13)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets. Round 12's ten commands are all still present; the
round 13 focused transport replaces the round 12 one at the same position and
widens the focused suite from 71 cases to 83, which is the direction the
no-removal rule protects.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 13)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `31f986b8e457df460723f034d210a51b96e359fb` equals the
  baseline at entry and the live index after every run, including after the
  five native transports.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `4db6be68...7200`. No umbrella row was completed.
- Validation-state comparison over the 42 captured paths: `acceptable: true`,
  with empty tracked and untracked lists. The only entry is the ignored
  Markdown log the declared command rewrites by design.
- The working tree matches its entry state: 32 staged paths, plus the
  protocol's unstaged transcript append.
- No reviewer residue: the cumulative run's scratch fixture was removed from
  the host, the writer's retained fixture was reused without modification, and
  the application checkout was only read.
- The sensitive-rule probe ran in message mode against a scratch file outside
  the repository. It read the index rules but changed nothing.
- The baselines and manifest were written before assessment, and the manifest
  is retired after publication.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 13)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 13)

`a.commit` is accurate and executable as a plan, and the reviewer amended
nothing. It will nevertheless be refused at commit time until the transcript
append is reworded.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 32 staged paths in five
ordered groups matching the request.

- Group 1, candidate evidence portability: the composer, the reader and its
  acceptance fixtures, including the PA6 split and the CI scope binding.
- Group 2, explicit wheel capture test environment: the agent fixture, both
  runners and the plan text.
- Group 3, Debian candidate evidence: all sixteen sidecars from builds 176 to
  184 with the record and its view.
- Group 4, point 4 checkpoint status: requirement, design, validation plan and
  umbrella.
- Group 5, point 4 review record: the transcript.

Ordering is least to most dependent and every staged path appears once. Group 1
and group 3 again move together, since the reader change and the cells it binds
belong in the same step.

The blocking point is group 5. The hook accepts the index today because the
round 13 append is unstaged and the hook checks staged blobs only. Once that
transcript is staged, the append's two occurrences of the application's private
repository name match the effective replacement rules, and the commit is
refused. The plan does not need restructuring; the append needs rewording.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 13)

Unresolved findings:

- The round 13 transcript append carries the application's private repository name on two lines, which the staged index has never contained and which the effective replacement rules map to `my-project`; the installed hook passes only because the append is unstaged and the hook checks staged blobs alone, and running the same checker over those two lines in message mode against the cplx root reports sensitive content and blocks, so group 5 of `a.commit`, which stages that transcript, will be refused until the append is reworded.
- The declared Markdown intersection checker fails on the same append: transcript line 13629 begins with a number and a period, wrapped from the sentence above it, so Markdown reads an ordered-list item and MD032 fires; the request's measurement of 39 diagnostics with none on added lines was taken before publication created the append, my run measures 40, and the single new diagnostic is that line, which is the same class the writer repaired for the reviewer's round 3 instructions.
- PA9's narrowing to the application's CI scope is recorded as unattributed prose while the requirement's PA9 row still reads "Full application acceptance suite": Q06, Q07, Q08 and Q09 are each a dated numbered decision carrying the human's answer, and the tooling-scope paragraph immediately above this one carries its own human-decision attribution, while this paragraph carries none and the request attributes the human only the supplied application revision and the Jenkins run; the narrowing is inert today because PA9 fails for other reasons, but it changes what a required cell may certify, and the excluded cases are the ones closest to the wheel whose identity already refused capture in build 177.

Boundary-crossing work:

- Host subprocess inheritance under the per-command runtime boundary is now a demonstrated failure rather than an open risk, and closing it still spans both repositories: build 184's walk fails eleven cases because a host child of a shipped process inherits the library path and `/usr/bin/bash` then loads the shipped libc and requires a missing `GLIBC_2.36`, with one case observed directly and ten inferred pending their stderr capture; the fix belongs to the application's runtime helper, which must settle the boundary before exec rather than inside an unstartable host shell, while the cplx acceptance contract must say what evidence qualifies that boundary on both platforms.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 13)

Human guidance:

The user asks for round 13 after testing Jenkins on the supplied application
revision `4093c353`. Assess the actual build and the round 12 repair, retaining
remaining blockers rather than declaring Step 6 complete. The user preserves
shipped Python 3.13.15, its own pip and relocated uv before locked sync.

Publish round 13 and stop. No cplx commit, reviewer invocation, QAL deployment,
D10 or release publication is authorized by this checkpoint. Assess the index
captured in the request; the new transcript append remains unstaged.

Guidance response:

The guidance is followed on every point.

- The index captured in the request is what was assessed: the trees match at
  entry and after every run, and the new append is unstaged.
- The actual build is assessed rather than the claim about it. Build 184 is
  `FAILURE` from the supplied revision, its live console digest equals the
  recorded one, and its walk, coverage figure and host Bash failure were read
  from the retained evidence.
- The round 12 repair is assessed and accepted: the PA6 split is correct,
  conservative in all three branches, and the build 183 reassessment changes
  that cell alone.
- Blockers are retained rather than closed. Step 6 stays `No`, PA9 fails,
  three cells stay inconclusive, and the host-child boundary is now a
  demonstrated failure.
- The bootstrap the user preserves is verified again this round: shipped Python
  3.13.15, its own pip environment, uv relocated before the locked sync, with
  its loader, RPATH and provider map retained.
- No cplx commit, reviewer invocation, deployment, D10 or publication was
  performed, and none is authorized here. The application checkout was only
  read.

The disposition is changes-requested because Step 6 is incomplete by design,
because the round 13 append would be refused by the installed hook once it is
staged, and because PA9's scope narrowing is not recorded as a decision.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 13)

The staged work is sound this round. Three corrections, then execution.

__Clean the round 13 append before it is staged.__ It names the application's
private repository twice, in the human guidance paragraph and in the writer
response about locally reported results. The staged index has never carried
that name, the effective rules map it to `my-project`, and the installed hook
refuses staged blobs that match. The hook passes today only because the append
is unstaged and it checks staged blobs alone; group 5 stages exactly that file.
While reflowing, fix line 13629, which wraps a sentence so the continuation
begins with a number and a period: Markdown reads an ordered-list item there
and MD032 fires, which is why the declared intersection checker fails. Neither
defect can be caught by validating before rendering, since publication creates
the append; a lint pass over the rendered text before publishing is the only
place that catches them.

__Record the PA9 narrowing as a decision, or withdraw it.__ The requirement's
PA9 row still reads "Full application acceptance suite", while a new paragraph
authorizes certifying the application's CI scope with browser-marked cases
excluded. Every comparable change here is a numbered human decision with a
date, including the tooling-scope paragraph directly above it. Put the question
to the human as Q10 with the alternatives stated, and if the answer confirms
the narrowing, amend the PA9 row so the table and the prose agree. Keep the
fence exactly as written: coverage and guarded-suite execution unchanged, no
other narrowing, and never described as browser evidence. The reader itself
needs no change; it already binds the scope tightly in both directions.

__Then the work build 184 exposed.__ Qualify the shipped-process to host-child
boundary before exec and retain the child stderr for the ten inferred cases, so
the count rests on measurement rather than a shared-cause inference. Restore
the 100% gate. Emit the stable locked-sync marker so PA6 binds to evidence
instead of staying inconclusive. Qualify the system-loader objects holding PA5
and PA7. Then repeat RHEL at the Q07 scope, take the D10 reading and close the
publication obligations.

Worth saying plainly: this round did the difficult thing correctly. The PA6
split is exactly the distinction that was asked for and it keeps the cell
blocking in every branch; the reassessment of the older build changed that one
label and nothing else, and proved it cell by cell. The walk finally runs, and
rather than presenting 6438 passing tests as progress, the record leads with
the eleven failures, names the observed case, marks the other ten an inference,
and states that suppressing them is not an option. That is what the per-command
boundary needed to be tested against, and it now has a reproducible case.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 13)

The disposition is changes-requested and the readiness floor is recorded as
incomplete.

1. Identity. Passes; the request tree equals the live index at entry and after
   every run.
2. Completeness. Fails by design, and the remaining work is concrete and now
   measured rather than anticipated.
3. Validation and coverage. Fails; ten of the eleven declared commands behave
   as declared, and the Markdown intersection checker fails on the round 13
   append rather than on anything staged.
4. Staged attribution. Passes; the reviewer made no repair and staged nothing.
5. Unresolved findings. Three: the private name in the append, the MD032 line
   in the same append, and the unattributed PA9 narrowing.
6. `a.commit`. Valid, ready and accepted against the current index, but group 5
   will be refused by the hook once the transcript is staged.

Two of the three findings sit in the append, not in the staged work, and that
is structural: the requestor validates before rendering, and publication then
creates text that nothing has checked. It is still content this repository will
carry, and the private name is the one class this effort has been strict about
everywhere else.

The staged work itself earns its result. The PA6 split is the correction that
was asked for, implemented conservatively in all three branches, with the older
build reassessed to change that label alone. The walk runs for the first time,
and the eleven failures it produces are exactly the host-child boundary round
12 listed as unqualified, now with a named case and a refusal to suppress it.
PA9 fails honestly on an unchanged 100% gate. The one substantive question is
whether the narrowing that PA9 may certify has been decided or merely written.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 13)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-13 -->

## Round 14 by requestor - Step 6

- Recorded: 2026-09-20T23:32:09+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 14)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 14

### Code review evidence for step 6 tools-archive-rebuild (round 14)

request_index_tree: afbab4030856f0fe69ca991422015aaa341f5ee5
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- bash .reviews/a.step6.r14-focused-transport.sh (sources: request)
- bash .reviews/a.step6.r12-runtime-transport.sh (sources: request)
- bash .reviews/a.step6.r12-bootstrap-transport.sh (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r14-verify-record.py (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r14-check-build.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r14-check-rendered.py (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: fix(tools): align application verification fixtures
group 2 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools): bind Debian candidate evidence
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187-retention.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 4: docs(tools): record point 4 checkpoint
group 4 path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 5: docs(review): retain point 4 review exchanges
group 5 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 14)

No. Step 6 has NOT been fully implemented.

Round 14 accepts all three round 13 findings. The exact retained writer append
no longer contains the application's private name or a numeric continuation
that Markdown interprets as a list. Human decision Q10 records the confirmed
PA9 scope and the requirement table agrees with its prose. No reviewer repair
was reversed. The new publication-input check examines the rendered request,
the simulated transcript append, and sensitive content before publication.

Build 187 ran application revision f8a0217f with the runtime and test repairs and finished
SUCCESS. Build 187 finishes SUCCESS on application f8a0217f. Provisioning and packaging use shipped Python 3.13.15, its own pip and relocated uv 0.12.17. The ABI gate and real heavy-wheel import pass. After fixture isolation, explicit empty-prefix preservation and portable branch tests, native acceptance passes with 6498 collected, 6497 executed and 31 individually identified browser exclusions. Coverage is 100%, 27256 of 27256 lines. Guarded SQLite suites pass and testmon collects without selecting. The failed builds 185 and 186 and their independent readings remain retained. Publication stays off; no browser evidence is claimed.

Build 185 on supplied revision 294b3066 failed twelve tests. Its raw artifacts
and independent reading remain retained. Application commit 23d141a0 fixes
three test files: module-local platform views preserve the real filesystem,
and synthetic runtime fixtures clear carried metadata after composing the
host launch environment. Local groundhog completed with zero failures,
100% coverage and no duration outliers before that commit was pushed.

Build 186 then failed one empty-toolchain fixture and left two path branches
uncovered on Linux. Commit f8a0217f preserves an explicitly published empty
shipped list and exercises both path branches without host filesystem
assumptions. A native synthetic regression reproduces the helper defect with
the old implementation and passes with the repair. The failed build and its
independent reading remain retained.

The final application revision's full local confirmation walk passed with
zero failures, 100% coverage and no duration outliers. One preceding walk
reported a 4.96-second property-test outlier; an isolated profile measured
that call at 0.27 seconds and the confirmation walk did not reproduce it.
No assertion, example count or timing threshold was changed. Both reports
and the profile remain retained in the local round 14 evidence.

The independent reading binds: PA1:debian pass; PA2:debian pass; PA3:debian pass; PA4:debian pass; PA5:debian inconclusive; PA6:debian inconclusive; PA7:debian inconclusive; PA8:debian pass; PA9:debian pass.
The build sidecars retain exact application, lock, wheel, reader and console
identities. Both original and current reader outcomes are retained. Historical
captures are unchanged; no earlier build's evidence is attributed to this run.

Q10 authorizes only the identified browser-marked exclusions. Coverage,
nonselecting testmon and guarded SQLite execution stay required. This CI pass
is not browser evidence, and Chromium launch qualification remains separate
application work. Wheel executable provider qualification is unchanged.

Validation: native cumulative fixtures pass in 87 seconds against committed
application 294b3066, and all 83 focused acceptance-reader cases pass. The
logs are .reviews/a.step6.r14-cumulative.log and
.reviews/a.step6.r14-focused.log. Shell lint passes all 58 tracked scripts.
The existing runtime and bootstrap fixture checks remain in the validation
set. No cplx Python class is changed and no cplx percentage is claimed.
The application coverage result is measured from the retained native walk.

Record and build checks verify raw artifact hashes, exact source identities,
wheel byte equality, unchanged candidate pins and publication off. The final
Markdown intersection, whitespace, sensitive-content and commit-plan checks
must pass before publication. Existing Markdown debt remains disclosed.

Fresh RHEL consumer qualification, D10, unresolved evidence cells and release
publication obligations remain open. The suggested DT_NEEDED change remains
untested and unadopted. Existing changes and transcript entries are staged
before rendering; round 14's publication append remains unstaged. Publish and
stop as requested, without a cplx commit or reviewer invocation.

### Implementation report for step 6 tools-archive-rebuild (round 14)

The writer repaired the round 13 transcript text and aligned PA9 with the
human-confirmed Q10 decision. The evidence record and generated view now
retain build 187, its independent reading and exact application provenance.
A publication-input checker validates rendered Markdown and sensitive
content before the append exists in the working tree. The application
revision supplies the host-child and cross-platform coverage fixes; the
writer repaired test isolation, empty-prefix fallback and path coverage
defects exposed by builds 185 and 186.

### Change summary for step 6 tools-archive-rebuild (round 14)

Five proposed cplx commit groups remain; no commit has been executed.

- Evidence portability and strict acceptance-reader fixtures.
- Application verification fixtures with an explicit interpreter.
- Debian evidence, adding builds 185 to 187 without rewriting historical captures.
- Runtime contract and checkpoint status, including human decision Q10.
- Review transcript, including repaired round 13 text and its answer.

The captured index contains these paths:

- ci/deliver-closure-tools.sh
- docs/v0.27.0/acceptance.tools-archive-rebuild.json
- docs/v0.27.0/acceptance.tools-archive-rebuild.md
- docs/v0.27.0/acceptance.tools-archive-rebuild.sh
- docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
- docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/fixtures.tools-release-agent.py
- docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
- docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/verify.tools-archive-rebuild.sh
- docs/v0.27.0/verify.tools-release-acceptance.sh
- docs/v0.27.0/verify.tools-release-agent.sh

### Human guidance and writer response for step 6 tools-archive-rebuild (round 14)

Human guidance:

The user requests round 14 after testing the supplied application revision
294b3066 in Jenkins, and requires the Jenkins job to finish green before
publication. Preserve shipped Python 3.13.15, its own pip, relocated uv,
unchanged wheel ELFs, coverage and provider gates, and publication off.

Builds 185 and 186 exposed application defects during that qualification.
The writer's repairs are committed as 23d141a0 and f8a0217f; build 187 tests
the latter exact revision. Retain both failed attempts alongside its result.

Publish round 14 and stop. No cplx commit, reviewer invocation, QAL deployment,
D10 or release publication is authorized by this checkpoint. Assess the index
captured in the request; the new transcript append remains unstaged.

Writer response:

Round 13's three findings are accepted without disagreement. The reviewer
made no repairs and staged no paths. The writer repaired the two private-name
occurrences and the numeric continuation in the exact retained round 13
append. The repository Markdown intersection check returns to 39 existing
diagnostics with none on added lines. A new publication-input check runs the
same Markdown rules against the rendered request and the staged transcript
with the proposed summary appended, and the installed sensitive-content
checker against both rendered artifacts. This runs after rendering, before
publication, without altering the captured index.

The transcript simulation permits only the staged baseline's existing
diagnostics. Sensitive-content checks use the publisher's exact repository
prefix removal, preserving canonical absolute identities in the private
request while checking the portable content that enters the transcript.

The supplied application revision implements host-child environment
composition in the parent before exec and adds cross-platform execution of
the previously uncovered branches. Its local reports are not substituted
for native Jenkins evidence. No DT_NEEDED proposal is adopted. Final build
facts are recorded in the assessment. After discussing both alternatives,
the human selected "PA9 excludes only browser-marked tests" on 2026-09-20.
Q10 records that answer, the PA9 row now matches it, and the scope paragraph
cites it. The reader's existing strict checks need no change. Browser
execution remains separate application qualification; Q08 still requires
provider qualification of wheel executables, including Node.

Step 6 remains incomplete while the independently measured acceptance cells,
fresh RHEL qualification, D10 and publication obligations remain unresolved.
A green Jenkins job does not itself close those obligations. Candidate pins,
historical captures and publication-off state remain preserved.

### Reviewer focus for step 6 tools-archive-rebuild (round 14)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-14 -->

## Round 14 by reviewer - Step 6

- Recorded: 2026-09-21T00:13:27+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 14)

Baseline index tree: afbab4030856f0fe69ca991422015aaa341f5ee5

Assessed index tree: afbab4030856f0fe69ca991422015aaa341f5ee5

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 14)

Result:

No. Step 6 has NOT been fully implemented.

Build 187 is the first green run of this step, and it is green for the right
reasons: the host-child boundary that failed eleven tests in build 184 is
fixed in the parent before exec, the walk covers 100% of 27256 lines, and the
three cells that lack evidence are still recorded as lacking it. Round 13's
three findings are all resolved, and all twelve declared commands behave as
declared, which has not happened before in this step. PA5, PA6 and PA7 remain
inconclusive, and the fresh RHEL qualification at the Q07 scope, D10 and the
publication obligations remain open, so the step stays incomplete.

Verified rather than accepted:

- All three live console digests equal the recorded ones: build 185
  `9458a286...46e9` FAILURE, build 186 `0e936508...3eaf` FAILURE, build 187
  `40b7d69c...ad31` SUCCESS, the last from application `f8a0217f`. The two
  failures are retained with their own readings rather than discarded.
- The acceptance line is exactly what the reader demands:
  `Acceptance PASS over all tests except the browser cases (stealth-gate Q01):
  collected=6498 executed=6497 setup_skipped=1 excluded=31; coverage=100%`.
- The report behind it binds: 31 excluded entries, 31 unique non-empty
  node identities, every one marked `browser`, equal to `deselected`, and
  collected, executed and setup-skipped equal to the console. The exclusions
  are three browser-driving test files, which is what Q10 authorizes.
- Coverage is measured, not claimed: `lines-valid` and `lines-covered` are both
  27256 with a line rate of 1, and the console reads `Required test coverage of
  100% reached`. The guarded SQLite suites ran 13 of 13 and 10 of 10 with zero
  skipped.
- The walk is green because tests were fixed, not removed: 6486 passed against
  build 184's 6438, five skipped against fifteen, no failures. The application
  adds a `host_runtime` module with its own unit tests that composes the host
  child's environment in the parent before exec, and its docstring cites build
  184's exact failure. The only `GLIBC_2.36` lines left in build 187 are the
  Debian host's own ABI ceiling report.
- PA6 stays inconclusive correctly even in a SUCCESS build. The literal
  `uv sync --locked` appears zero times and no locked-sync marker is emitted,
  so the pass branch cannot be reached although the imports evidence reads
  `wheels load` and `venv_base=` is present. A green pipeline is not allowed to
  stand in for the missing observation, which is the distinction round 12 asked
  for.
- Round 13's finding on the append is repaired surgically. Against the original
  rendered summary, exactly three things changed: two occurrences of the
  application's private name became neutral wording, and the wrapped line that
  began with a number and a period was rejoined. Nothing else in that
  290-line entry moved, and the private name now appears nowhere in the staged
  index or the working transcript.
- Round 13's Markdown finding is measured as fixed: the gate reports 39
  diagnostics again, and its declared interpreter passes with none on added
  lines.
- Round 13's scope finding is resolved the way it was asked. Q10 is a dated
  numbered decision carrying both options and the human's answer, the PA9 row
  now reads the narrowed scope and cites Q10, the requirement prose cites it,
  and the design says the same. The fence is unchanged: coverage, nonselecting
  testmon and guarded SQLite execution stay required, and no browser evidence
  is claimed.
- The reader, its fixtures, the verification runners, the plan and the
  composer are byte-identical to round 13. This round changed evidence and
  documents only, so the code I validated last round is the code that ran.
- The new publication-input checker does what the gap needed: it lints the
  rendered request, lints the staged transcript with the proposed summary
  appended and permits only the existing diagnostics, and runs the installed
  sensitive-content checker over both artifacts after stripping the repository
  prefix exactly as publication does. I confirmed the simulated append matches
  the real one in content, and that publication strips that prefix.
- The application's committed helpers are byte-identical across the three
  revisions of this round, so the cumulative fixture run against the earlier
  committed revision exercises the same helper bytes as build 187.
- The independent evidence validator ran under the independent 3.9.25
  interpreter and returned zero, so the reader path still holds the 3.9 floor.

One thing is not yet proven by the evidence it rests on.

PA9's pass depends on executing application code whose bytes the reader never
pins. The cell runs `ci/tools_test_evidence.py` from the checkout directory it
is handed, while `--application-revision` is used for one thing only: comparing
the build's `uv.lock` with that revision. The checkout is checked for the
existence of `ci/`, nothing more, and the retained reading records no digest of
the validator it executed. The transport carries only the commit, the root
tree and three blobs, so the reader could not read that file from the pinned
revision even if it tried.

In this round the bytes are right, and I checked that rather than assuming it:
the packer builds the material with `git archive` at the pinned revision. But
that is a property of a transport script in `.reviews`, not of the independent
reading, and the reading is what outlives the transport and is what the release
record cites. The same checkout could carry a modified validator, or one from
another revision, and every check in the reader would still pass as long as
`uv.lock` matched. This mattered less while PA9 was failing; it is now the cell
that turned green, and a pass whose validator is unpinned is the shape of
problem this step has refused everywhere else.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 14)

- Pin the validator the way the lock is pinned: transport the `ci` tree object
  and the validator blob, compare the file the reader is about to run against
  `<revision>:ci/tools_test_evidence.py`, and refuse or record inconclusive on
  a mismatch. Retain that digest in the reading so the evidence carries it.
- Emit the stable locked-sync marker so PA6 can bind to an observation.
- Qualify the system-loader objects and the provider path aliases that hold
  PA5 and PA7 inconclusive.
- Repeat RHEL acceptance at the Q07 scope with the settled runtime setup, take
  the D10 reading, and complete the pre-publication obligations.

Architecture: the host boundary now belongs to the parent process, which is
where it can be enforced, and the shipped and host environments are composed
explicitly rather than reset after the fact. Performance: the walk costs 233
seconds; no other new cost. Unit test coverage: no cplx Python class changed
and no cplx percentage is claimed; the application's 100% is measured from the
retained walk, not adopted as a cplx gate. No unit-tested class below 100%
needs completing, and no top-level symbol outside the coverage gate is
unreferenced.

Feature integrity: host providers, unmapped objects, malformed verdicts,
unresolved maps, broader test narrowing and sub-gate coverage are still
refused; historical captures and candidate pins are unchanged; publication
stays off, which I confirmed at the pinned application revision.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows record builds 185 to 187, Q10, the repaired append
and the cells as measured, and the Point 4 narrative now describes the build
187 checkpoint while the retained sidecars keep every earlier reading intact.
The validator-pinning finding belongs in those rows once the reader and the
transport are changed, so the reviewer leaves it in this answer rather than
writing a row that would presume the shape of the fix.

The status sentence stays exactly `No. Step 6 has NOT been fully implemented.`,
and the document-level line stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 14)

The reviewer ran all twelve resolved commands. All twelve behave as declared,
which is the first time this step has reached that state.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  native `validation exit=0 elapsed=87s`, 254 cases, zero failures, against the
  committed application revision, with the three committed helper digests
  verified on the host.
- The round 14 focused transport, source `request`: `PASS
  tools-release-acceptance: 83 cases`, exit 0.
- The runtime transport, source `request`: `PASS installer directory order,
  inert sourcing, command boundary, inherited-prefix reordering, idempotence`.
- The bootstrap transport, source `request`: the exact embedded validator
  accepts the retained scope and refuses host, monitoring-only and unresolved
  maps.
- The round 14 record verifier, source `request`: both `PASS` lines.
- The build checker, source `request`: all three `PASS` lines, covering the
  exact application identity, the shipped Python and pip, the relocated uv and
  its providers, 77 canonical locked wheel hashes, 80 ELF captures, Jenkins
  SUCCESS, the native acceptance PASS, 100% measured coverage, the guarded
  suites and the 31 identified browser exclusions.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 on the 39
  older findings, back to the count round 13 disturbed.
- The Markdown intersection checker, source `request`: `PASS: 39 existing
  diagnostics; none intersects added Markdown lines since HEAD`.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`: both clean.
- The publication-input checker, source `request`: `PASS`, covering the
  rendered request, the simulated transcript append and the sensitive-content
  check of both portable artifacts.

Measured independently rather than read from the request: builds 185, 186 and
187 through the Jenkins API, with all three live console digests equal to the
recorded ones and 187 reporting SUCCESS from the stated revision; the
acceptance PASS line and the coverage line in the live console; the retained
report's 31 unique browser-marked exclusions and their reconciliation with the
console counts; the coverage XML totals; the guarded suite results; the pytest
summary showing more tests passing than before and none failing; the three
application helper blobs compared across this round's three revisions; the
application change that fixed the host-child boundary; the surgical scope of
the round 13 append repair; the Q10 decision, the amended PA9 row and the
design text; and the commit plan through the shared readiness checker.

Two read-only measurements went beyond the declared set. I compared the
simulated transcript append against the real appended entry to confirm the new
checker lints what publication actually writes, and I traced how the reader
binds the application checkout, which is where this round's finding comes from.

The reviewer removed its own scratch fixture from the RHEL host after the
cumulative run. The other native commands reused the writer's retained fixture
without modifying it, and the application checkout was only read. No coverage
percentage is claimed for cplx.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 14)

The reviewer ran the union of the request validation set and the current
resolver set: twelve commands, each after reading the scripts it runs.

- `bash src/utils/lint_shell.sh`, source `project`.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`.
- The round 14 focused transport, source `request`, read before running.
- The runtime and bootstrap transports, source `request`, unchanged since
  round 12 and reused without modification.
- The round 14 record verifier and the build checker, source `request`, both
  read in full before running.
- The Markdown gate and its intersection checker, source `request`.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`.
- The publication-input checker, source `request`, new this round and read in
  full before running.

All twelve exit as expected, the Markdown gate on repository debt only.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 14)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets. Round 13's eleven commands are all still present,
with the focused transport advanced to this round's fixture and one command
added rather than removed. The addition is the publication-input checker, which
covers the gap round 13 found, so the set widens in the direction the
no-removal rule protects.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 14)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `afbab4030856f0fe69ca991422015aaa341f5ee5` equals the
  baseline captured at entry and the live index after every run, including
  after the five native transports and the publication-input checker.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `298f54d3...874a`. The umbrella changed with this round's staged
  work, before the review, and not during it. No umbrella row was completed.
- Validation-state comparison over the 50 captured paths, the 38 staged paths
  with the project command's file and the eleven ignored validation files:
  `acceptable: true` with empty tracked and untracked lists. The only entry is
  the ignored Markdown log the declared command rewrites by design.
- The working tree matches its entry state: 38 staged paths, plus the
  protocol's unstaged transcript append.
- No reviewer residue: the cumulative run's scratch fixture was removed from
  the host, the writer's retained fixture was reused without modification, and
  the application checkout was only read.
- The baselines and manifest were written before assessment, and the manifest
  is retired after publication.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 14)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 14)

`a.commit` is accurate and executable, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 38 staged paths in five
ordered groups matching the request. The installed hook accepts the index, and
this time it also accepts the transcript group, because the append that would
have blocked it was repaired before staging.

- Group 1, candidate evidence portability: the composer, the reader and its
  acceptance fixtures, all byte-identical to round 13.
- Group 2, application verification fixtures: the agent fixture, both runners
  and the plan text, likewise unchanged.
- Group 3, Debian candidate evidence: twenty-four sidecars from builds 176 to
  187 with the record and its generated view.
- Group 4, point 4 checkpoint status: requirement with Q10, design, validation
  plan and umbrella.
- Group 5, point 4 review record: the transcript.

Ordering is least to most dependent and every staged path appears once. Groups
1 and 2 carry no change this round, which is correct: they hold the reader and
fixtures that earlier rounds staged and that this round did not touch.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 14)

Unresolved findings:

- PA9's pass rests on application code the reader never pins: the cell executes `ci/tools_test_evidence.py` from whatever checkout it is handed, while `--application-revision` is used only to compare the build's `uv.lock` with that revision, the checkout is verified no further than the existence of `ci/`, and the retained reading records no digest of the validator it ran; the transport carries only the commit, the root tree and three blobs, so the reader could not read that file from the pinned revision even if it tried. In this round the bytes are correct, and I verified that by reading the packer, which builds the material with `git archive` at the pinned revision, but that is a property of an ignored transport script rather than of the independent reading that outlives it and that the release record cites. Pin the validator the way the lock is pinned: transport the `ci` tree object and the validator blob, compare the file about to run against `<revision>:ci/tools_test_evidence.py`, refuse or record inconclusive on a mismatch, and retain that digest in the reading.

Boundary-crossing work:

- Two obligations still span both repositories and cannot be closed from the cplx side alone: the stable locked-sync marker that would let PA6 bind to an observation must be emitted by the application pipeline, since it is the pipeline's own claim to make, while the cplx reader already refuses to accept stage success in its place; and the provider path aliases plus the system-loader objects that hold PA5 and PA7 inconclusive need the application scanner to carry qualified maps for subjects outside the retained helper exception, against a cplx contract that says what qualifies. Both are recorded, neither is claimed as done, and this round's green pipeline is explicitly not offered as a substitute for either.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 14)

Human guidance:

The user requests round 14 after testing the supplied application revision
294b3066 in Jenkins, and requires the Jenkins job to finish green before
publication. Preserve shipped Python 3.13.15, its own pip, relocated uv,
unchanged wheel ELFs, coverage and provider gates, and publication off.

Builds 185 and 186 exposed application defects during that qualification.
The writer's repairs are committed as 23d141a0 and f8a0217f; build 187 tests
the latter exact revision. Retain both failed attempts alongside its result.

Publish round 14 and stop. No cplx commit, reviewer invocation, QAL deployment,
D10 or release publication is authorized by this checkpoint. Assess the index
captured in the request; the new transcript append remains unstaged.

Guidance response:

The guidance is followed on every point.

- The index captured in the request is what was assessed: the trees match at
  entry and after every run, and the new append is unstaged.
- The job finished green, and I confirmed it from Jenkins rather than from the
  request: build 187 is SUCCESS on the stated revision, and its live console
  digest equals the recorded one.
- Both failed attempts are retained. Builds 185 and 186 are FAILURE with their
  own readings and sidecars staged, and their live console digests match the
  record too.
- The preserved elements are verified again this round: shipped Python
  3.13.15, its own pip environment, uv relocated before the locked sync with
  its loader, RPATH and provider map, 77 canonical locked wheel hashes with no
  tooling wheel, the coverage gate unchanged at 100%, and the provider gates
  still refusing what they refused before.
- Publication is off, checked at the pinned application revision, and the
  candidate pins are unchanged.
- No cplx commit, reviewer invocation, deployment, D10 or publication was
  performed, and none is authorized here. The application checkout was only
  read.

The disposition is changes-requested because Step 6 is incomplete by design,
with three Debian cells still lacking evidence and the RHEL, D10 and
publication obligations open, and because PA9's new pass depends on a
validator the reader does not pin.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 14)

One correction, one small hardening, then the remaining execution.

__Pin the validator PA9 runs.__ The cell executes the application's
`ci/tools_test_evidence.py` from the checkout it is handed, and the only thing
`--application-revision` currently governs is the `uv.lock` comparison. Carry
the `ci` tree object and the validator blob in the transport, compare the file
about to run against `<revision>:ci/tools_test_evidence.py`, refuse or record
inconclusive on a mismatch, and retain that digest in the reading. The bytes
are right today, and I checked the packer rather than assuming it, but that
correctness lives in an ignored transport script while the reading is what the
release record cites. This is the same pinning discipline the lock already
gets, applied to the one input that decides a cell that just turned green.

__Make the simulated append match the real one.__ The new publication-input
checker is the right answer to round 13, and it earned its place this round.
Its simulated entry uses a different heading form and one metadata bullet,
where publication writes the entry-id comment, `## Round N by <role> - Step 6`
and nine bullets. The content is what matters and the content is faithful, so
this is hardening rather than a defect: build the simulated entry from the
publisher's exact header so a future heading or metadata change cannot slip
past the check that exists to catch exactly that.

__Then the remaining evidence.__ Emit the stable locked-sync marker so PA6
binds to an observation instead of an absence. Qualify the system-loader
objects and the provider path aliases holding PA5 and PA7. Then repeat RHEL
acceptance at the Q07 scope with the settled runtime setup, take the D10
reading, and close the pre-publication obligations.

Worth saying plainly, because this round earned it. All three round 13
findings were fixed at the root rather than patched: the append repair changed
exactly the two names and the one wrap and nothing else in a 290-line entry;
Q10 was put to the human with both options and their real costs, and the table,
the prose and the design now agree; and the gap that let two defects reach a
published append is now closed by a check that lints what publication actually
writes. The build itself is the stronger result: the host-child boundary that
failed eleven tests is fixed in the parent before exec, with a new module, its
own tests and a docstring that cites the failing build, and the walk came back
green with more tests passing and fewer skipped rather than with fewer tests
run. In a green build, PA5, PA6 and PA7 are still recorded as lacking
evidence, and the request says in its own words that a green pipeline does not
close those obligations. That is the habit that makes the eventual pass worth
something.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 14)

The disposition is changes-requested and the readiness floor is recorded as
incomplete.

1. Identity. Passes; the request tree equals the live index at entry and after
   every run.
2. Completeness. Fails by design. Three Debian cells still lack evidence, and
   the RHEL qualification at the Q07 scope, D10 and the publication
   obligations remain open.
3. Validation and coverage. Passes; all twelve declared commands behave as
   declared, which this step had not achieved before.
4. Staged attribution. Passes; the reviewer made no repair and staged nothing.
5. Unresolved findings. One: the validator behind PA9's pass is not pinned.
6. `a.commit`. Passes, valid, ready, and now accepted by the hook including
   its transcript group.

Commit-ready is not available, and the reason is completeness rather than
quality. The rule reserves that recommendation for a complete implementation,
and the writer says plainly that Step 6 is not complete. It would be wrong to
convert a good round into a finished one.

The single finding is proportionate to what changed. PA9 moved from fail to
pass this round, so the inputs behind that verdict deserve the same scrutiny
the cell itself received, and one of them is bound only by an ignored transport
script. The evidence is not wrong: I traced the packer and it uses the pinned
revision. What is missing is that the independent reading cannot demonstrate
it, and the reading is the artifact that survives.

The rest of this round is the strongest work in this step. Every round 13
finding was fixed at its root, the narrowing question went to the human with
both options priced, the failing builds were kept with their evidence, and the
green walk is green because tests were repaired rather than removed. The three
cells without evidence are still recorded as inconclusive inside a SUCCESS
build, which is the distinction this step has been defending since round 12.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 14)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-14 -->

## Round 15 by requestor - Step 6

- Recorded: 2026-09-21T10:26:03+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 15)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 15

### Code review evidence for step 6 tools-archive-rebuild (round 15)

request_index_tree: 16c7b5e2c8643c9480569f6df95c370299a2d86a
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- bash .reviews/a.step6.r14-focused-transport.sh (sources: request)
- bash .reviews/a.step6.r12-runtime-transport.sh (sources: request)
- bash .reviews/a.step6.r12-bootstrap-transport.sh (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r15-verify-record.py (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r15-check-build.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r15-check-rendered.py (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: fix(tools): normalize candidate verification evidence
group 1 path: ci/deliver-closure-tools.sh
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2: fix(tools): align application verification fixtures
group 2 path: docs/v0.27.0/fixtures.tools-release-agent.py
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-agent.sh
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools): bind Debian candidate evidence
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187-retention.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build188.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build188-retention.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 4: docs(tools): record point 4 checkpoint
group 4 path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
group 4 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
group 4 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 5: docs(review): retain point 4 review exchanges
group 5 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build188-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build188.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
staged path: docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/fixtures.tools-release-agent.py
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: docs/v0.27.0/verify.tools-release-agent.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 15)

Checkpoint ready for independent review. Full Step 6 remains No.

The human selected checkpoint commit followed immediately by completing
Step 6. This round therefore assesses that checkpoint's commit readiness;
fresh RHEL consumer qualification, D10 and remaining pre-publication checks
remain required and follow the commit. No candidate publication is authorized
by this scope decision.

Round 14's finding is repaired: PA9 executes retained validator bytes checked
against the exact application commit, with a retained revision/path/digest
binding. Missing or modified validators are refused before execution. The
minimal Git transport includes the validator blob and ci tree.

Build 188 finishes SUCCESS on application ec2e72bc. The real relocated uv sync emits the stable success marker. Provider-map aliases retain their qualified physical targets. Shipped Python 3.13.15, its own pip, relocated uv 0.12.17, canonical lock, wheel bytes and blocking heavy-wheel traces remain intact. Native acceptance passes with 6501 collected, 6500 executed and 31 individually identified browser exclusions. Coverage is 100%, 27256 of 27256 lines. Guarded SQLite suites pass and testmon collects without selecting. No browser evidence is claimed.

All nine independent Debian acceptance cells PA1 through PA9 pass. Explicit
provider alias provenance closes the path-spelling gap without expanding the
provider policy. The stable locked-sync marker records the real relocated uv
command's outcome. Historical captures remain unchanged and preserve their
original identities. Both original-bundle and repaired-reader outcomes remain
retained. The proposed DT_NEEDED change is unadopted.

The application's complete local groundhog walk passed with zero failures,
100% coverage and no duration outliers. An earlier new regression exceeded
the duration floor because its shell stub launched two extra executables.
Profiling identified subprocess overhead; replacing that stub with a shell
function preserves the actual production branch, arguments, success/failure
assertions and exit-code check. The isolated regression and complete walk
then passed. No timing threshold or assertion was weakened.

Native cumulative fixtures passed against committed application ec2e72bc in
95 seconds. All 91 focused reader cases pass. Shell lint passes 58 tracked
scripts; runtime and bootstrap regression checks pass. Logs are retained in
the round 15 local evidence. No cplx Python coverage percentage is claimed.

Record and build checks bind raw hashes, source revisions, canonical lock,
77 wheels and 80 wheel ELFs, shipped Python/pip, relocated uv and publication
off. Markdown, whitespace, sensitive-content and commit-plan checks precede
publication. The publication check uses the actual publisher's entry renderer
including metadata and footer and rejects new transcript diagnostics.

The existing transcript and all implementation changes are staged before
the request captures its index. That index stays unchanged through assessment.
At checkpoint convergence, the human has already authorized Commit. Continue
through the canonical commit workflow, then complete the remaining Step 6
work and obtain its completion review.

### Implementation report for step 6 tools-archive-rebuild (round 15)

The independent acceptance reader now pins, retains and executes the exact
committed application test validator. Its fixture suite covers missing,
modified and unbound validators and qualified, conflicting or malformed
provider aliases. The application scanner emits explicit physical alias
bindings and provisioning records the real locked-sync outcome.

Build 188 evidence and both independent reader outcomes are retained with
exact source and artifact identities. The record, view and validation status
reflect all nine Debian cells passing while retaining full Step 6 as No.
Human guidance explicitly authorizes this checkpoint commit followed by the
remaining qualification. The publication checker validates the complete
publisher-rendered transcript entry before publication.

### Change summary for step 6 tools-archive-rebuild (round 15)

Five proposed cplx commit groups remain:

- Evidence portability, pinned validator and strict acceptance-reader fixtures.
- Application verification fixtures with an explicit interpreter.
- Debian evidence through build 188, preserving historical captures.
- Runtime contract and authorized checkpoint status, including Q10.
- Review transcript and retained responses.

The captured index contains these paths:

- ci/deliver-closure-tools.sh
- docs/v0.27.0/acceptance.tools-archive-rebuild.json
- docs/v0.27.0/acceptance.tools-archive-rebuild.md
- docs/v0.27.0/acceptance.tools-archive-rebuild.sh
- docs/v0.27.0/design.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build177.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build178.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build179.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build180.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build181.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build182.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build183.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build184.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build185.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build186.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build187.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build188-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-build188.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian-retention.json
- docs/v0.27.0/evidence.tools-archive-rebuild.step6-debian.json
- docs/v0.27.0/feature-request.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/fixtures.tools-release-agent.py
- docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
- docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
- docs/v0.27.0/verify.tools-archive-rebuild.sh
- docs/v0.27.0/verify.tools-release-acceptance.sh
- docs/v0.27.0/verify.tools-release-agent.sh

### Human guidance and writer response for step 6 tools-archive-rebuild (round 15)

Human guidance:

The human's latest instruction on 2026-09-21 is: "OK go for checkpoint,
then work on completing step 6". It follows the explicit instruction to
aim for convergence and commit after round 14.

Assess commit readiness of this repaired Debian checkpoint. Full Step 6
remains incomplete: fresh RHEL acceptance at Q07 scope, D10 and the remaining
pre-publication obligations follow immediately after the checkpoint commit.
The human explicitly selected this order rather than waiting for full Step 6
completion before committing. Do not mistake that scope decision for a waiver
of the later acceptance work or authorization to publish the candidate.

Preserve shipped Python 3.13.15, its own pip, relocated uv, unchanged wheel
ELFs, strict provider qualification, Q10 CI test scope, 100% coverage and
publication off. Assess the index captured in the request. No index mutation
will follow rendering or publication. The publisher's own entry renderer
checks the prospective transcript append before publication.

At checkpoint convergence the user has already authorized Commit. After the
canonical commit continuation, proceed with the remaining Step 6 work and its
own review; do not mark this checkpoint as completion of the entire step.

The human also requires Python package downloads to use the internal Nexus
mirror because direct public-index downloads are blocked. The exact uv wheel
for the subsequent RHEL qualification has been retained from that mirror and
checked against its index digest. D10's GCC 12 input is a runtime-provider
comparison; no compiler upgrade or host package installation is authorized.

Writer response:

Round 14's validator-pinning finding is accepted without disagreement. The
reviewer made no code repairs. The independent reader now requires the exact
application revision, reads its committed ci/tools_test_evidence.py blob,
compares the supplied checkout bytes before execution, and retains both the
verified executable bytes and their revision/path/SHA-256 identity. It runs
that retained copy in Python isolated mode. Missing revisions, missing Git
objects, absent validator files and changed bytes are refused before execution.
The transport now carries the ci tree and validator blob as well as the
previous minimal objects. Native fixtures cover each refusal and the positive
retained digest.

The publication checker now calls the publisher's actual pure transcript
renderer, including its exact heading, metadata and entry footer, rather than
approximating the surrounding Markdown. Existing baseline diagnostics remain
the only permitted diagnostics; sensitive-content checks still cover both
portable publication inputs.

The application scanner now records observed provider spellings and their
qualified physical targets as map-alias rows. The reader accepts an alias only
when its target has an availability row, and refuses malformed or conflicting
rows. This is availability evidence, not a loaded-provider claim. Actual import
traces remain authoritative and blocking; the retained-helper exception is
unchanged. The application's relocated uv sync now emits its stable success
marker only after exit zero, and emits the failure marker with the original
nonzero exit otherwise. New application regressions exercise both outcomes.

The human selected checkpoint commit followed immediately by completion of
the remaining Step 6 work. Full-step incompleteness is retained explicitly;
it is not represented as a completed release qualification. The new request
asks for commit readiness of this checkpoint under that authorized scope.

### Reviewer focus for step 6 tools-archive-rebuild (round 15)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-15 -->

## Round 15 by reviewer - Step 6

- Recorded: 2026-09-21T10:40:56+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 15)

Baseline index tree: 16c7b5e2c8643c9480569f6df95c370299a2d86a

Assessed index tree: 16c7b5e2c8643c9480569f6df95c370299a2d86a

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 15)

Result:

No. Step 6 has NOT been fully implemented.

I found no defect in the staged work this round. Round 14's finding is fixed
more thoroughly than it was raised, the three cells that had been inconclusive
since round 11 are now passing on evidence I could reproduce, and all twelve
declared commands behave as declared. What keeps this answer at `No` is the
step's own scope: the plan's Step 6 requires RHEL PA1 to PA6 at the Q07 venv
scope and the D10 reading against both actual provider candidates, and neither
has been done. The writer records the same status.

Verified rather than accepted:

- The validator pinning is right, and it is stronger than what round 14 asked
  for. `--application-revision` is now required for PA9; the reader reads the
  validator from `<revision>:ci/tools_test_evidence.py`, refuses unless the
  checkout's file matches those bytes exactly, writes the pinned bytes into the
  retained evidence, records revision, path and SHA-256 in a binding file, and
  executes the retained copy with `-I` rather than the checkout's. Both new
  artifacts are captured, so the retained reading now carries what it ran.
- The refusals are fixture-tested in four directions: absent revision, unknown
  revision, a foreign checkout whose validator raises on execution, and a
  missing file. The drift fixture also asserts that the poisoned validator's
  marker never appears in the log, which proves the refusal happens before
  execution rather than after it.
- Build 188 is SUCCESS on application `ec2e72bc`, and its live console digest
  `231c5a82...6f54` equals the recorded one.
- PA6's pass is a real observation. The marker is printed from the exit status
  of the relocated uv itself, in an if/else whose failure branch prints
  `state=failed` and exits, with a unit test covering both branches. The
  console shows the sync resolving 83 packages and installing 77 immediately
  before `TOOLS-LOCKED-SYNC/1 state=passed`, and the sync runs
  `--no-group tooling`, which is the Q07 scope.
- PA5 and PA7 close on spelling, not on policy. I replayed the reader's own
  provider logic over the retained evidence: across the 84 system-loader
  subjects, 111 providers resolve directly and 30 through an alias, and zero
  resolve to a target outside the shipped prefix. Every alias in use is a
  soname pointing at its real versioned file in the same shipped directory.
  The reader refuses a malformed row, a conflicting duplicate and an alias
  whose target has no availability row, and all three refusals are fixtures.
- The reader never normalizes paths against its own filesystem, which is the
  right call for a reader that runs on a different host than the agent.
- PA9 still binds the same way: 31 unique browser-marked exclusions equal to
  `deselected` and to the console's `excluded=31`, counts reconciled, coverage
  100% at 27256 of 27256, guarded SQLite suites passing with zero skipped.
- The publication-input checker now builds its simulated entry from the
  publisher's own renderer, metadata and footer included, which is the
  hardening round 14 suggested.
- The commit plan is valid and ready: 40 staged paths, five ordered groups, no
  diagnostics, and no stale commit-phase marker anywhere that would block the
  canonical workflow.
- The record is honest about scope: it states that the obligations after the
  checkpoint are not waived and that Step 6 remains `No` until their evidence
  is conclusive.

On the disposition, and why it is not a judgment on this work.

The human's instruction is to commit this checkpoint and then finish Step 6,
and the request asks me to assess the checkpoint's commit readiness. I can
report what I measured: five of the six readiness-floor results pass, and I
have no finding against the staged work. But the shared reviewer rule reserves
a `commit-ready` recommendation for a complete implementation among the six,
and `implementation-check` does not offer a partial status: a step that is not
fully implemented is recorded as `No`, which is what the writer wrote and what
the plan's Step 6 text supports. Guidance may direct scrutiny; it cannot move a
disposition rule. So the answer is `changes-requested`, and the change being
requested is the remaining Step 6 work itself, not a repair.

This answer neither authorizes nor blocks the checkpoint commit. That choice
belongs to the human, who has already made it, and no reviewer answer of either
kind would change that. If a mid-step checkpoint should be able to converge
through this protocol, that is a change to the shared instruction rather than
something a reviewer can grant inside a round.

#### Missing work for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 15)

- Run fresh RHEL acceptance for PA1 to PA6 at the Q07 venv scope, with
  `--no-group tooling` and uv from the tools installation, using the settled
  per-command runtime setup.
- Materialize the Step 4 agent's exact wheels on RHEL and take the D10 reading
  against both actual provider candidates, rebuilding once and repeating the
  affected acceptance if the generation changes.
- Record RHEL PA10 readiness, deploy and redeploy against the packaged
  inventory, and PA11 operator `senv` and `.env` behavior.
- Complete the remaining pre-publication obligations, then obtain the
  completion review for the whole step.

Architecture: unchanged this round; the reader gained a pinning step and an
alias lookup, both local to the functions that own those decisions.
Performance: no new cost. Unit test coverage: no cplx Python class changed and
no cplx percentage is claimed; the application's 100% is measured from the
retained walk. No unit-tested class below 100% needs completing, and no
top-level symbol outside the coverage gate is unreferenced.

Feature integrity: host providers, unmapped objects, malformed verdicts,
unresolved maps, unpinned validators, broader test narrowing and sub-gate
coverage are all refused; historical captures and candidate pins are unchanged;
publication stays off, checked at the pinned application revision.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows record build 188, the validator pinning, the alias
provenance, the observed locked sync, the human's checkpoint decision and the
obligations that survive it. The reviewer has no finding to add and no
correction to make to those rows.

The status sentence stays exactly `No. Step 6 has NOT been fully implemented.`,
and the document-level line stays `No, it is not implemented.`

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 15)

The reviewer ran all twelve resolved commands. All twelve behave as declared.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  native `validation exit=0 elapsed=87s`, 254 cases, zero failures, against
  committed application `ec2e72bc`.
- The round 14 focused transport, source `request`: `PASS
  tools-release-acceptance: 91 cases`, eight more than last round, covering the
  four validator refusals and the three alias refusals.
- The runtime and bootstrap transports, source `request`: both pass unchanged.
- The round 15 record verifier, source `request`: all three `PASS` lines,
  including that every raw cell is `pass` and that the retained executed
  validator equals the committed blob at the pinned revision.
- The build checker, source `request`: all four `PASS` lines, including the
  observed locked sync and the explicit provider aliases with no flagged or
  unresolved providers.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 on the same
  39 repository findings.
- The Markdown intersection checker, source `request`: `PASS`, none on added
  lines.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`: both clean.
- The publication-input checker, source `request`: `PASS`, now rendering its
  simulated entry through the publisher's own renderer.

Measured independently rather than read from the request: build 188 through
the Jenkins API, SUCCESS from the stated revision with its live console digest
equal to the recorded one; the locked-sync marker in the live console, its
emitting branch in the committed application pipeline and the unit test that
covers both of its branches; the uv sync resolving 83 and installing 77
packages just before the marker; a replay of the reader's own provider logic
over the retained evidence, giving 111 providers resolved directly, 30 through
an alias and none outside the shipped prefix; the alias rows themselves, which
are sonames pointing at their real versioned files; the PA9 report and its 31
unique browser-marked exclusions with the console counts; the coverage totals;
the reader diff and the fixture cases that exercise its new refusals; the
commit plan through the shared readiness checker; and the absence of any stale
commit-phase marker.

The reviewer removed its own scratch fixture from the RHEL host after the
cumulative run. The other native commands reused the writer's retained fixture
without modifying it, and the application checkout was only read. No coverage
percentage is claimed for cplx.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 15)

The reviewer ran the union of the request validation set and the current
resolver set: twelve commands, each after reading the scripts it runs.

- `bash src/utils/lint_shell.sh`, source `project`.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`.
- The focused, runtime and bootstrap transports, source `request`.
- The round 15 record verifier and build checker, source `request`, both read
  in full and diffed against their round 14 counterparts before running.
- The Markdown gate and its intersection checker, source `request`.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`.
- The publication-input checker, source `request`, read in full again because
  it changed to use the publisher's own entry renderer.

All twelve exit as expected, the Markdown gate on repository debt only.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 15)

No drift in either direction.

The project floor still resolves to the single `project` command, and the
`plan` and `request` additions parse through the current resolver contract, so
the union equals both sets. The twelve commands match round 14's set, with the
record and build checkers advanced to this round's build and the publication
checker strengthened rather than relaxed. Nothing was dropped.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 15)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `16c7b5e2c8643c9480569f6df95c370299a2d86a` equals the
  baseline captured at entry and the live index after every run.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `ea05112c...71b8`. The umbrella changed with this round's staged
  work, before the review, not during it. No umbrella row was completed.
- Validation-state comparison over the 52 captured paths, the 40 staged paths
  with the project command's file and the eleven ignored validation files:
  `acceptable: true` with empty tracked and untracked lists.
- The working tree matches its entry state: 40 staged paths, plus the
  protocol's unstaged transcript append.
- No reviewer residue: the cumulative run's scratch fixture was removed from
  the host, the writer's retained fixture was reused without modification, and
  the application checkout was only read. The live console fetch and the
  provider replay wrote only ignored reviewer scratch files.
- The baselines and manifest were written before assessment, and the manifest
  is retired after publication.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 15)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 15)

`a.commit` is accurate and executable, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 40 staged paths in five
ordered groups matching the request. The installed hook accepts the index.

- Group 1, candidate evidence portability: the composer, the reader with its
  validator pinning and alias rules, and the acceptance fixtures that exercise
  both.
- Group 2, application verification fixtures: unchanged this round.
- Group 3, Debian candidate evidence: twenty-six sidecars from builds 176 to
  188 with the record and its generated view.
- Group 4, point 4 checkpoint status: requirement, design, validation plan and
  umbrella.
- Group 5, point 4 review record: the transcript.

Ordering is least to most dependent and every staged path appears once. Group 1
and group 3 again move together, which is correct: the reader change and the
cells it binds belong in the same step.

Two things worth recording because a commit is imminent. No stale
`a.code-review-commit-phase` marker exists anywhere in the repository or the
artifact home, so the canonical workflow will not trip over a leftover from an
earlier step. And the hook accepts the staged transcript, including the round
14 append, so group 5 commits cleanly.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 15)

Unresolved findings:

- None. The reviewer found no defect in the staged work this round.

Boundary-crossing work:

- The remaining Step 6 work still spans both repositories, which is why it cannot be closed from the cplx side alone: the plan requires materializing the Step 4 agent's exact wheels on RHEL and running D10 against both actual provider candidates, so the application supplies the wheel identities and the venv at the Q07 scope while cplx owns the acceptance contract and the D10 reading, and a generation change there forces a rebuild, a new candidate identity and a repeat of the affected acceptance. None of that is waived by the checkpoint decision, and the staged record says so in its own words.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 15)

Human guidance:

The human's latest instruction on 2026-09-21 is: "OK go for checkpoint,
then work on completing step 6". It follows the explicit instruction to
aim for convergence and commit after round 14.

Assess commit readiness of this repaired Debian checkpoint. Full Step 6
remains incomplete: fresh RHEL acceptance at Q07 scope, D10 and the remaining
pre-publication obligations follow immediately after the checkpoint commit.
The human explicitly selected this order rather than waiting for full Step 6
completion before committing. Do not mistake that scope decision for a waiver
of the later acceptance work or authorization to publish the candidate.

Preserve shipped Python 3.13.15, its own pip, relocated uv, unchanged wheel
ELFs, strict provider qualification, Q10 CI test scope, 100% coverage and
publication off. Assess the index captured in the request. No index mutation
will follow rendering or publication. The publisher's own entry renderer
checks the prospective transcript append before publication.

At checkpoint convergence the user has already authorized Commit. After the
canonical commit continuation, proceed with the remaining Step 6 work and its
own review; do not mark this checkpoint as completion of the entire step.

Guidance response:

The guidance is followed on every point, and one of its requests cannot be
granted in the form it asks for.

- The index captured in the request is what was assessed: the trees match at
  entry and after every run, and the new append is unstaged.
- The checkpoint's readiness was assessed, not assumed. I found no defect in
  the staged work, and five of the six readiness-floor results pass.
- The scope decision is not treated as a waiver. The remaining RHEL
  acceptance at the Q07 scope, D10 and the pre-publication obligations are
  recorded as missing work, and no candidate publication is implied by
  anything here.
- The preserved elements are verified again: shipped Python 3.13.15, its own
  pip, relocated uv with the sync run at `--no-group tooling`, unchanged wheel
  ELFs, provider qualification that still refuses every unqualified target,
  the Q10 scope with its 31 identified exclusions, 100% coverage at 27256 of
  27256 lines, and publication off at the pinned application revision.
- The publication check does now use the publisher's own entry renderer, and
  it passes on both rendered artifacts.

What cannot be granted is the disposition the checkpoint framing asks for.
`commit-ready` is reserved by the shared rule for a complete implementation
among the six floor results, and `implementation-check` has no partial status:
a step that is not fully implemented is recorded as `No`, which is what the
writer wrote and what the plan's Step 6 text supports. Guidance may direct
additional scrutiny but cannot move a disposition rule, so this answer is
`changes-requested` and the change requested is the remaining Step 6 work.

This is not a block on the commit. The commit choice belongs to the human,
who has already made it, and neither disposition would change that: a
`commit-ready` recommendation never authorizes a commit either. If a mid-step
checkpoint is meant to converge through this protocol, that belongs in the
shared instruction rather than in a reviewer's in-round judgment.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 15)

There is nothing to repair in the staged work. The instructions are the
remaining step.

__Run the RHEL side at the Q07 scope.__ PA1 to PA6 on the build account and
deployment target, with the shipped venv prepared `--no-group tooling`, uv
taken from the tools installation, and the per-command runtime setup that
Debian has now exercised twice. Keep the earlier tooling-inclusive capture as
history without letting it stand in for this one. Record PA10 readiness,
deploy and redeploy against the packaged inventory, and PA11 operator `senv`
and `.env` behavior.

__Then D10.__ Materialize the Step 4 agent's exact wheels on RHEL and read D10
against both actual provider candidates. If the generation changes, rebuild
once, mint a new candidate identity and repeat the affected acceptance,
including the second reading the plan allows.

__Then close the step.__ Complete the remaining pre-publication obligations
and request the completion review for Step 6 as a whole. The checkpoint commit
does not shorten that list, and your own record already says so.

If the human commits the checkpoint first, nothing here needs to change. The
plan is valid and ready, no stale commit-phase marker exists, the hook accepts
the index including the transcript group, and the five groups are ordered
least to most dependent.

Worth saying plainly. Round 14's finding asked you to pin the validator the
way the lock is pinned; you did that and went further, retaining the bytes,
recording the binding and running the retained copy in isolated mode, then
proving with a fixture that a substituted validator is refused before it
executes rather than after. The two cells that had been inconclusive since
round 11 closed on real evidence: a marker printed from the actual relocated
uv's exit status with both branches unit-tested, and alias rows that resolve
sonames to their own versioned files inside the shipped prefix, with malformed,
conflicting and unqualified targets all refused and all three refusals
fixtured. I replayed the provider logic myself over the retained evidence and
not one accepted provider points outside the shipped prefix. That is the
opposite of loosening a gate to get a pass, and it is why nine passing cells
read as a result rather than as an outcome someone wanted.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 15)

The disposition is changes-requested and the readiness floor is recorded as
incomplete. Five of the six results pass.

1. Identity. Passes; the request tree equals the live index at entry and after
   every run.
2. Completeness. Fails. The plan's Step 6 requires RHEL PA1 to PA6 at the Q07
   venv scope, PA10 and PA11, and the D10 reading against both actual provider
   candidates. None of those has been run, and the writer records the same
   status.
3. Validation and coverage. Passes; all twelve declared commands behave as
   declared, and the focused suite grew by eight cases that all exercise
   refusals.
4. Staged attribution. Passes; the reviewer made no repair and staged nothing.
5. Unresolved findings. None. Round 14's finding is fixed, and this round
   produced no new one.
6. `a.commit`. Passes, valid, ready, accepted by the hook, with no stale
   commit-phase marker to trip the canonical workflow.

Only completeness fails, and it fails on scope rather than on quality. The rule
reserves `commit-ready` for a complete implementation, and `implementation-check`
offers no partial status, so a checkpoint that deliberately stops short of the
step cannot carry that signal no matter how sound it is. Human guidance can
direct scrutiny; it cannot move a disposition rule. Saying so plainly is more
useful than stretching the signal, because the recommendation would not have
authorized the commit anyway: that choice is the human's and is already made.

The work itself deserves its own sentence. Round 14's finding was not just
answered but overtaken: the validator is pinned to the committed revision,
retained, digested and executed in isolation, with a fixture proving a
substitute is refused before it runs. PA5, PA6 and PA7 closed on evidence I
could reproduce independently rather than on a relaxed rule: a marker printed
from the real uv's exit status, and aliases that only ever map a soname to its
own versioned file inside the shipped prefix. Across 84 system-loader subjects,
no accepted provider points outside that prefix. Nine passing cells, earned.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 15)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-15 -->

## Round 16 by requestor - Step 6

- Recorded: 2026-09-21T12:41:55+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: request

### Review identity for step 6 tools-archive-rebuild (round 16)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 6
Review round: 16

### Code review evidence for step 6 tools-archive-rebuild (round 16)

request_index_tree: 0fbbc6e0c96bceb24e2ca9adc6739063e7b1850e
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash .reviews/a.step6.transport.sh cumulative (sources: plan)
- bash .reviews/a.step6.r14-focused-transport.sh (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6-r16-verify-record.py (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.point4-r15-check-build.py (sources: request)
- ssh pdfsu01 /usr/bin/python3 cplx-release-evidence/tools-archive-rebuild-step6-r16-completion/a.step6-r16-recheck-native.py (sources: request)
- ../llm-shared/markdown-check.bat --root ../cplx > .reviews/a.step6.r2-markdown.log 2>&1 (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r2-check-markdown.py (sources: request)
- git diff --cached --check (sources: request)
- bash .git/hooks/pre-commit (sources: request)
- ../llm-shared/venvs/python_3.13.9_llm-shared/Scripts/python.exe .reviews/a.step6.r16-check-rendered.py (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: chore(editor): accept CI evidence terms
group 1 path: .vscode/settings.json
group 2: fix(tools): qualify deployed runtime boundaries
group 2 path: ci/deliver-closure-tools.sh
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/acceptance.tools-runtime-rhel.sh
group 2 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 2 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 2 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
group 3: docs(tools): bind final platform acceptance
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 3 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-final-rhel.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-final-archive.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-d10.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-readiness.json
group 3 path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-publication-check.json
group 4: docs(tools): retain step 6 review findings
group 4 path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
group 5: docs(tools-archive-rebuild): record step 6 validation
group 5 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: .vscode/settings.json
staged path: ci/deliver-closure-tools.sh
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/acceptance.tools-runtime-rhel.sh
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-d10.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-final-archive.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-final-rhel.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-publication-check.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step6-readiness.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
```

### Requestor assessment for step 6 tools-archive-rebuild (round 16)

Yes. Step 6 has been fully implemented.

The repaired checkpoint is committed through `92e361a6`. The completion adds
fresh deployed RHEL qualification, an exact-archive assertion run, one D10
comparison of the two real provider pairs, and the complete prepublication
readiness floor. The native publication validator accepts the actual archive
and resolved private coordinate. Actual publication and adoption remain Step 7.

The final native cumulative suite passes in 89 seconds, including 98 acceptance
cases, 16 record cases, ShellCheck and the inherited checks. The separate archive
run passes 539 cases. Real RHEL evidence covers all ten required cells, including
both SQLite roles and the deployed application's lock, unchanged wheel bytes,
provider traces and host/shipped subprocess boundaries. D10 selects packaged
GCC 11 from all 77 resolved wheel identities; no candidate rebuild is required.

Jenkins 188 remains the actual Debian evidence for unchanged inputs: 6500 tests,
100% measured application coverage, guarded suites executed, and only the 31
identified browser cases excluded under Q10. No browser evidence is claimed.
The cplx `ghog day` lint phase passes for its 58 tracked shell scripts; its pytest
phase exits 5 because this build-tooling repository has no pytest environment.
That command is retained in the validation set, and is not called a green walk.
Application coverage is not attributed to the Bash controls or Python heredocs.

The new deployed-runtime helper has a distinct responsibility. No application
layer depends on these evidence controls, and no new Python class is introduced.
The helper's wheel-check function runs before and after live imports; refusal
fixtures cover its source and input guards. Existing control functions remain
referenced. There is no architecture issue or unreferenced top-level symbol
requiring repair. Deterministic inventory sorting is O(n log n), and byte checks
are linear in artifact size; no repeated all-pairs scan or performance issue was
introduced. Reusing unchanged Jenkins evidence avoids another expensive build.

Historical observations remain intact when replaced by fresh results. The
unmodified Debian observations retain their original input snapshots and an
explicit unaffected assessment. The public coordinate is a digest reference;
private materialization proves that only that field changes before native
validation. No upload target is invented and uploads remain off. Existing
feature and reporting behavior is preserved.

### Implementation report for step 6 tools-archive-rebuild (round 16)

RHEL acceptance now binds the deployed application helper sources and offline
inputs before execution. A separate helper qualifies shipped Python, its own
pip and relocated uv, checks the Q07 locked environment, compares every wheel
ELF before and after real provider tracing, and exercises both the host child
boundary before exec and the shipped child runtime. Host utilities remain in
the host environment. New refusal fixtures reject altered source, lock,
application identity and offline bytes.

The summary retains recursive runtime captures and input pins. The live run
was frozen before the reporting correction, so both its original result and
the reporting-only reread are retained and separately identified. Runtime
execution was not repeated or relabeled to hide an earlier failure.

D10's wrapper now binds all resolved wheel identities, including pure-Python
wheels, while retaining the distinct subset that contributes ABI demands.
The inherited capability and lowest-generation selection rules are unchanged.
The real comparison chooses packaged GCC 11 in one reading. A pure-Python
fixture prevents the record from dropping those resolved identities again.

Fresh exact-archive checks and RHEL results replace only the affected current
observations; their old input snapshots remain in history. The unchanged
Debian observations retain their original inputs with explicit assessments.
Source authority, closure without active waivers, actual backend proof,
coordinate preflight and recovery preparation complete the release floor.

The native record validator is unchanged. It accepts the actual archive with
the real private coordinate in a private execution record. A digest binding
checks that only that coordinate field differs from the public record. No
publisher was invoked. Step 7 publication, retrieval, adoption and any required
recovery remain pending, with uploads off.

### Change summary for step 6 tools-archive-rebuild (round 16)

Group 1: `chore(editor): accept CI evidence terms`

- `.vscode/settings.json`

Group 2: `fix(tools): qualify deployed runtime boundaries`

- `ci/deliver-closure-tools.sh`
- `docs/v0.27.0/acceptance.tools-archive-rebuild.sh`
- `docs/v0.27.0/acceptance.tools-runtime-rhel.sh`
- `docs/v0.27.0/verify.tools-archive-rebuild.sh`
- `docs/v0.27.0/verify.tools-release-acceptance.sh`
- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md`

Group 3: `docs(tools): bind final platform acceptance`

- `docs/v0.27.0/acceptance.tools-archive-rebuild.json`
- `docs/v0.27.0/acceptance.tools-archive-rebuild.md`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-final-rhel.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-final-archive.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-d10.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-readiness.json`
- `docs/v0.27.0/evidence.tools-archive-rebuild.step6-publication-check.json`

Group 4: `docs(tools): retain step 6 review findings`

- `docs/v0.27.0/review.code.v0.27.0.tools-archive-rebuild.md`

Group 5: `docs(tools-archive-rebuild): record step 6 validation`

- `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`

### Human guidance and writer response for step 6 tools-archive-rebuild (round 16)

Human guidance:

The user authorized the checkpoint commit and then completion of Step 6,
asking to use at most one further Jenkins round if possible because each
costs more than 45 minutes. The checkpoint is committed through `92e361a`.
This request assesses the completed Step 6 readiness floor, not the earlier
checkpoint exception. No acceptance obligation is waived.

Candidate bytes and Debian execution inputs remain those of green build 188.
Fresh RHEL acceptance and D10 qualify the same final consumer set. Reuse the
unchanged Debian evidence with explicit impact assessments instead of
requiring another costly run solely because RHEL evidence was added.

Keep shipped Python 3.13.15, its own pip, relocated uv 0.12.17, unchanged wheel
ELFs, strict provider qualification, Q10 CI scope and 100% measured application
coverage. Only Nexus and retained inputs were used. GCC 12 libraries were
comparison inputs, not an installed compiler or a candidate upgrade.

The sensitive-content hook stays enabled. The public record stores a digest
reference to the private coordinate, not a fake public upload target. Native
validation uses its privately materialized value and proves that this is the
only changed record field. Actual publication and adoption stay pending.

The user has authorized convergence and commit. This does not authorize
publishing the release, changing its immutable bytes or enabling uploads.

Writer response:

Round 15's readiness finding is accepted. The authorized checkpoint was
committed, and this request supplies the remaining Step 6 evidence instead
of asking the reviewer to accept an incomplete readiness floor.

The current RHEL probes use the same final application, canonical lock and
77 wheels captured by Jenkins 188. Both actual candidate library pairs were
read for D10. Fresh archive assertions replace old unknown input snapshots;
they are not repaired by inventing historical identities. Every publication
obligation is backed by retained evidence and the native publication gate.

The prior round's validator provenance, provider alias accounting and real
locked-sync success marker remain intact. PA9 continues to certify only the
authorized CI scope; browser evidence is not claimed. No new interpreter
DT_NEEDED dependency, wheel rewrite or broad host-provider exception was added.

There is no disagreement with the readiness finding. The remaining Step 7
obligations are expressly retained and are not presented as completed by
prepublication qualification.

### Reviewer focus for step 6 tools-archive-rebuild (round 16)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-6-round-16 -->

## Round 16 by reviewer - Step 6

- Recorded: 2026-09-21T13:00:29+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: answer

### Assessed index identity for step 6 tools-archive-rebuild (exchange 1) (round 16)

Baseline index tree: 0fbbc6e0c96bceb24e2ca9adc6739063e7b1850e

Assessed index tree: 0fbbc6e0c96bceb24e2ca9adc6739063e7b1850e

### Implementation check for step 6 tools-archive-rebuild (exchange 1) (round 16)

Result:

Yes. Step 6 has been fully implemented.

I checked the completion claim against the plan's own Step 6 text, requirement
by requirement, and against the evidence rather than the summary of it. Every
required cell on both platforms now passes, D10 is settled, and the
pre-publication floor is complete with publication itself still pending. One
versioned document was left behind by the completion, and that is the single
finding below; it does not put any cell in doubt.

Verified rather than accepted:

- The checkpoint landed exactly as reviewed: five commits whose subjects and
  membership match the five groups of round 15's plan, with `92e361a6` recorded
  as the release revision in the record's authority block.
- RHEL is real and fresh. All ten required cells pass with an empty `missing`
  list, over a run that took 5734 seconds and retained 1340 captures. It covers
  both SQLite roles, the forced redeployment, PA10 readiness and PA11 operator
  behavior, at the Q07 venv scope.
- The new deployed-runtime qualifier earns PA6 on RHEL. It binds the deployed
  application helpers to the retained revision and asserts the packaged tree is
  clean rather than merely at that HEAD, verifies every offline input digest
  and the lock, bootstraps uv with shipped Python and its own pip from an
  offline wheel, relocates uv and checks its loader lies inside the shipped
  tools, then runs `uv sync --locked --offline --no-group tooling --dry-run`
  and refuses if the output would install, remove, replace, create or update
  anything. That is a strict reading of "matches the Q07 lock".
- Its wheel check compares every installed ELF against the agent inventory by
  digest, requires exact set equality, rejects symlinks, and runs both before
  and after the live trace. The host-child boundary is exercised for real: from
  inside the shipped runtime it asserts the library path is the shipped one,
  composes the host environment, launches a host shell that resolves and runs
  the shipped git, and then imports both heavy wheels in a shipped child.
- D10 is settled in one reading: packaged generation 11 selected, generation 12
  compared without installation, no rebuild and no second reading. The record
  now binds all 77 resolved wheel identities while keeping the measured ABI
  subset separate, and the reader refuses if a measured consumer disagrees with
  the resolved inventory.
- The Debian cells are legitimately retained rather than re-run. I read this
  round's reader diff in full: every change is in the RHEL path, the D10 wrapper
  and pin plumbing, and the `debian` decision path is untouched. Each of the
  nine Debian cells carries an explicit `unaffected` assessment with its
  previous inputs, and the only input that differs is the RHEL runtime identity.
  The recorded reason says exactly that, and it is true.
- The publication floor is complete and publication is not. The record's
  publication state is `pending` with no digests and no captures, the coordinate
  is an opaque digest reference, and the native replay proves that materializing
  only that one field reproduces the public record byte for byte before running
  the validator's publication phase. That script never invokes an uploader.
- The plan changes only add obligations: a new declared file, the deployed
  runtime requirements, and the private-coordinate handling that keeps a
  sensitive value out of versioned evidence while binding it by digest. Nothing
  in Step 6 was relaxed to reach a Yes.
- All eleven declared commands behave as declared, including 98 focused reader
  cases and the 254-case cumulative suite against the committed application.
- The `ghog day` exit 5 is disclosed rather than dressed up: the validation plan
  records that its lint phase passed and its pytest phase stopped because this
  repository has no pytest environment, and that the plan substitutes the native
  cumulative runner. No percentage is claimed for cplx.

The one thing the completion left behind.

The umbrella still says, in the present tense, that "Step 6 remains No until
their evidence is conclusive", and it still frames round 15 as the current
round with the RHEL work, D10 and the pre-publication checks yet to come. The
staged validation plan in the same change set says Step 6 is fully implemented.
Two versioned documents in one commit now disagree about the central claim of
this round. The umbrella was kept current in each of rounds 13, 14 and 15, so
this is an omission rather than a decision, and I am not permitted to fix it
from reviewer mode. It is the only thing between this round and a commit-ready
recommendation.

#### Architecture check for Step 6 for step 6 tools-archive-rebuild (exchange 1) (round 16)

No DDD-Hexagonal violation or smell. The new work is evidence control code, not
application code: a Bash qualifier and a reader path, with the application's own
helpers invoked as pinned external programs rather than imported into any layer.
Nothing in the application depends on these controls, and the controls reach the
application only through its committed, digest-checked sources. The deployed
runtime helper has one responsibility and keeps the two interpreter roles
distinct: the independent reader verifies bindings and wheel bytes, and only
application interpreter commands enter the application's shared runtime, with
host utilities deliberately left in the host environment. No new Python class is
introduced and no Python file grew, so the addendum's "no Python growth" holds
and the 650-line validator ceiling is untouched. The 113-line qualifier is a new
declared file rather than growth of an existing one.

Performance: inventory comparison is a dictionary equality over sorted inputs
and the byte checks are linear in artifact size, with no repeated all-pairs
scan. The RHEL run is long because it is a real deployment, not because of the
checks. Reusing the unaffected Debian evidence avoids another expensive build,
and that reuse is justified by an explicit assessment rather than by silence.

Unit test coverage: no cplx Python class changed and no cplx percentage is
claimed. No unit-tested class below 100% needs completing, and no top-level
symbol outside the coverage gate is unreferenced. The application's 100% is
measured from the retained walk and attributed to the application.

Feature integrity: host providers, unmapped objects, unpinned validators,
altered helper sources, offline input drift, an extra or missing deployed ELF,
symlinked site-packages entries, broader test narrowing and sub-gate coverage
are all refused, each by a fixture. Historical captures, candidate pins and the
adoption block are unchanged, and uploads remain off.

Validation plan effects:

None. The reviewer wrote no row in
`docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`.

The writer's Step 6 rows record the fresh RHEL qualification, the deployed
runtime helper, D10's single settled reading, the publication floor and the
disclosed `ghog day` exit, and they carry the exact status sentence this
answer confirms.

The status sentence stays exactly `Yes. Step 6 has been fully implemented.`
The document-level line correctly stays `No, it is not implemented.`, because
Step 7 still reads `Not started`; steps 1 to 6 now all read `Yes`.

No pre-repair blob was recorded and no reviewer patch was attributed or staged.

### Pre-repair mandatory checks and coverage for step 6 tools-archive-rebuild (exchange 1) (round 16)

The reviewer ran all eleven resolved commands, and two more that this round
dropped. All thirteen behave as declared.

- `bash src/utils/lint_shell.sh`, source `project`: 58 tracked scripts, clean.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`, run alone:
  native `validation exit=0 elapsed=90s`, 254 cases, zero failures, against the
  committed application revision.
- The focused transport, source `request`: `PASS tools-release-acceptance: 98
  cases`, seven more than last round.
- The round 16 record verifier, source `request`: all four `PASS` lines,
  including fresh RHEL raw evidence, the exact deployed helper digest, current
  cells, the 77-wheel generation 11 D10 and the complete publication floor with
  publication and adoption pending.
- The build checker, source `request`: all four `PASS` lines over build 188.
- The native RHEL replay, source `request`, run over ssh: exit 0. I read it
  before trusting its result. It verifies both record digests against their
  binding, proves the private record differs from the public one in the
  coordinate field alone, and then runs the validator's publication phase
  against the actual archive. It never invokes an uploader.
- The Markdown gate with `--root ../cplx`, source `request`: exit 1 on the same
  39 repository findings.
- The Markdown intersection checker, source `request`: `PASS`, none on added
  lines.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`: both clean.
- The publication-input checker, source `request`: `PASS`, rendering its
  simulated entry through the publisher's own renderer.

Beyond the declared set, the reviewer ran the runtime and bootstrap transports
that rounds 12 to 15 carried and this round does not. Both still pass, so the
narrowing of the declared set costs no coverage.

Measured independently rather than read from the request: the five checkpoint
commits against round 15's groups; the RHEL required set, its empty `missing`
list, elapsed time and capture count; the PA6 qualifier read line by line; the
D10 decision and its selected generation; the reader diff in full, to confirm
the Debian decision path is untouched; each Debian cell's `unaffected`
assessment and the single input that differs; the publication block's pending
state and opaque coordinate; the plan's own Step 6 text against the evidence;
every step's status sentence in the validation plan; the line budgets and the
absence of Python growth; the commit plan through the shared readiness checker;
and the staged transcript, where the reviewer's round 15 answer is verbatim.

The reviewer removed its own scratch fixture from the RHEL host after the
cumulative run. The other native commands reused retained fixtures without
modifying them, the ssh replay was read-only, and the application checkout was
only read. No coverage percentage is claimed for cplx.

### Resolved validation set and sources for step 6 tools-archive-rebuild (exchange 1) (round 16)

The reviewer ran the union of the request validation set and the current
resolver set: eleven commands, each after reading the scripts it runs, plus two
commands carried from earlier rounds that this request no longer declares.

- `bash src/utils/lint_shell.sh`, source `project`.
- `bash .reviews/a.step6.transport.sh cumulative`, source `plan`.
- The focused transport, source `request`.
- The round 16 record verifier and the build checker, source `request`.
- The native RHEL replay over ssh, source `request`, read on the host before
  its result was used.
- The Markdown gate and its intersection checker, source `request`.
- `git diff --cached --check` and `bash .git/hooks/pre-commit`, source
  `request`.
- The publication-input checker, source `request`.
- The runtime and bootstrap transports, carried from rounds 12 to 15 and not
  declared this round; the reviewer ran them anyway.

All thirteen exit as expected, the Markdown gate on repository debt only.

### Resolver drift and direction for step 6 tools-archive-rebuild (exchange 1) (round 16)

Drift in one direction, narrowing, and it costs no coverage.

The project floor still resolves to the single `project` command and the `plan`
and `request` additions parse through the current resolver contract. The request
set drops the two native transports that rounds 12 to 15 declared, the runtime
ordering fixture and the bootstrap validator fixture, and adds the native RHEL
replay. The reviewer ran the dropped pair anyway: both still pass, and the
deployed runtime qualifier now exercises the same boundary against a real
deployment rather than a fixture, so the substance moved rather than
disappeared. Reported here with its direction, as the rule requires; the union
still ran.

### Repository state around validation for step 6 tools-archive-rebuild (exchange 1) (round 16)

The repository state around validation is unchanged, and every comparison came
from the shared evidence launcher.

- Request-time index tree `0fbbc6e0c96bceb24e2ca9adc6739063e7b1850e` equals the
  baseline captured at entry and the live index after every run, including the
  native transports and the ssh replay.
- Umbrella digest comparison: `applicable: true`, `changed: false`, before and
  after both `ea05112c...71b8`. The umbrella did not change during the review,
  and it did not change with this round's staged work either, which is the
  finding above rather than a boundary problem. No umbrella row was completed.
- Validation-state comparison over the 28 captured paths, the 16 staged paths
  with the project command's file and the eleven ignored validation files:
  `acceptable: true` with empty tracked and untracked lists.
- The working tree matches its entry state: 16 staged paths, plus the
  protocol's unstaged transcript append.
- No reviewer residue: the cumulative run's scratch fixture was removed from
  the host, retained fixtures were reused without modification, the ssh replay
  wrote nothing, and the application checkout was only read.
- The baselines and manifest were written before assessment, and the manifest
  is retired after publication.

### Repair inventory for step 6 tools-archive-rebuild (exchange 1) (round 16)

Repairs made: None.

Paths staged: None.

### Commit plan assessment for step 6 tools-archive-rebuild (exchange 1) (round 16)

`a.commit` is accurate and executable, and the reviewer amended nothing.

Independent `commit-plan-check.bat --format json` against the received state:
`state: valid`, `ready: true`, exit 0, no diagnostics, 16 staged paths in five
ordered groups matching the request. The installed hook accepts the index.

- Group 1, editor dictionary terms for the new evidence vocabulary.
- Group 2, the deployed runtime qualification: the delivery script, the reader,
  the new RHEL qualifier, the syntax check list and the acceptance fixtures.
- Group 3, the final platform acceptance evidence: the RHEL, D10, archive,
  readiness and publication-check sidecars with the record and its view.
- Group 4, the review transcript.
- Group 5, the Step 6 validation record.

Ordering is least to most dependent and every staged path appears once. The
dictionary group sits first because nothing depends on it, and the record and
its generated view travel with the evidence they summarize, which is correct.

Once the umbrella finding is addressed, that document joins the group that
carries the checkpoint status, and the grouping needs no other change.

### Findings and boundaries for step 6 tools-archive-rebuild (exchange 1) (round 16)

Unresolved findings:

- The umbrella contradicts the completion claim it ships with: `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md` still states in the present tense that "Step 6 remains No until their evidence is conclusive" and still frames round 15 as the current round, with the fresh RHEL acceptance at Q07 scope, D10 and the remaining pre-publication checks described as work that follows, while the staged validation plan in the same change set records "Yes. Step 6 has been fully implemented." and the staged evidence shows all ten required RHEL cells passing, D10 settled on packaged generation 11 and the pre-publication floor complete; the umbrella was kept current in each of rounds 13, 14 and 15, so this reads as an omission rather than a decision, and a reviewer may not complete an umbrella row, so the writer should bring that item 7 narrative up to the state this round actually reached, keeping the item open for the Step 7 publication, retrieval and adoption work that genuinely remains.

Boundary-crossing work:

- None. The work that spanned both repositories through this step is closed: the locked-sync marker is emitted by the application pipeline and observed by the reader, the provider aliases carry qualified physical targets, the host-child boundary is composed in the parent before exec and exercised for real on both platforms, and the deployed venv is bound to the application's committed lock and wheel bytes. What remains is Step 7 publication, retrieval and adoption, which the record keeps pending with uploads off, and which belongs to that step rather than to this one.

### Human guidance response for step 6 tools-archive-rebuild (exchange 1) (round 16)

Human guidance:

The user authorized the checkpoint commit and then completion of Step 6,
asking to use at most one further Jenkins round if possible because each
costs more than 45 minutes. The checkpoint is committed through `92e361a`.
This request assesses the completed Step 6 readiness floor, not the earlier
checkpoint exception. No acceptance obligation is waived.

Candidate bytes and Debian execution inputs remain those of green build 188.
Fresh RHEL acceptance and D10 qualify the same final consumer set. Reuse the
unchanged Debian evidence with explicit impact assessments instead of
requiring another costly run solely because RHEL evidence was added.

Keep shipped Python 3.13.15, its own pip, relocated uv 0.12.17, unchanged wheel
ELFs, strict provider qualification, Q10 CI scope and 100% measured application
coverage. Only Nexus and retained inputs were used. GCC 12 libraries were
comparison inputs, not an installed compiler or a candidate upgrade.

The sensitive-content hook stays enabled. The public record stores a digest
reference to the private coordinate, not a fake public upload target. Native
validation uses its privately materialized value and proves that this is the
only changed record field. Actual publication and adoption stay pending.

The user has authorized convergence and commit. This does not authorize
publishing the release, changing its immutable bytes or enabling uploads.

Guidance response:

The guidance is followed on every point, and the convergence it authorizes is
one small document edit away.

- The completed Step 6 readiness floor is what was assessed, not the checkpoint
  exception, and the implementation check is `Yes` on the evidence.
- No obligation was treated as waived. I checked the plan's Step 6 text
  requirement by requirement: AR1, AR2 and AR4 in the archive run, AR3 and the
  ten required RHEL cells in the fresh run, the Debian cells, both SQLite
  roles, the forced redeployment, PA10, PA11, the optional RHEL downstream
  cells still marked optional, and D10 against both actual provider candidates.
- The reuse of build 188 is justified rather than assumed. I read this round's
  reader diff in full and confirmed the Debian decision path is untouched, and
  each Debian cell carries an explicit `unaffected` assessment naming the one
  input that changed. No further Jenkins round was needed, which is what the
  cost constraint asked for.
- The preserved elements hold: shipped Python 3.13.15 with its own pip,
  relocated uv 0.12.17, unchanged wheel ELFs checked byte for byte against the
  agent inventory, strict provider qualification with every refusal fixtured,
  the Q10 scope with its 31 identified exclusions, and 100% measured
  application coverage attributed to the application.
- GCC 12 is treated as a comparison input: D10 selects packaged generation 11
  in a single reading, with no installation, no rebuild and no second reading.
- The sensitive-content handling is exactly as described. The public record
  holds an opaque digest reference, and the native replay proves that
  materializing only that field reproduces the public record byte for byte
  before the validator's publication phase runs. No uploader is invoked,
  publication and adoption stay pending, and the hook passes.

The disposition is `changes-requested` for one reason only, and it is not an
acceptance obligation. The umbrella still asserts that Step 6 remains No and
still describes this round's work as future, contradicting the validation plan
it ships beside. The rule reserves a commit-ready recommendation for a round
with no unresolved finding, and a reviewer may not edit an umbrella row. Bring
that narrative up to date and the next round converges on this same evidence;
nothing here needs to be re-run.

### Writer instructions for step 6 tools-archive-rebuild (exchange 1) (round 16)

One document, then converge.

__Bring the umbrella up to the state this round reached.__ Its item 7 narrative
still says "Step 6 remains No until their evidence is conclusive" and still
describes the fresh RHEL acceptance, D10 and the pre-publication checks as work
that follows round 15's checkpoint. All of that has now happened and is staged
beside it. Record what the completion actually established: ten required RHEL
cells passing at the Q07 scope with the deployed venv bound to the committed
lock and wheel bytes, D10 settled on packaged generation 11 in one reading, the
pre-publication floor complete, and the Debian evidence retained by explicit
assessment rather than re-run. Keep item 7 itself open, because Step 7
publication, retrieval and adoption genuinely remain, and say that plainly so
the open row is not mistaken for unfinished Step 6 work. Nothing else in the
change set needs to move; the commit plan absorbs that file into the group that
already carries the checkpoint status.

__Then converge.__ No cell needs re-running, no evidence needs regenerating and
no Jenkins round is required. The next request can carry this same evidence
with the umbrella corrected.

Worth saying plainly, because this step took sixteen rounds to earn. The
completion did not reach for the cheapest route to a Yes. The deployed-runtime
qualifier asserts the packaged application tree is clean rather than merely at
the right HEAD, refuses any sync that would change a single package, compares
every installed ELF against the agent inventory before and after the live
trace, rejects symlinked entries, and launches a real host child and a real
shipped child to prove the boundary in both directions. D10 binds all 77
resolved wheel identities while keeping the measured ABI subset distinct, and
refuses if the two disagree. The Debian reuse is defended with an explicit
assessment naming the single input that changed, rather than by silence, and I
could confirm from the reader diff that the claim is true. The `ghog day` exit 5
is disclosed in the permanent record with its substitution named, when it would
have been easy to leave unmentioned. Publication stays pending with an opaque
coordinate and a replay that proves only that field differs. That is what a
release floor is supposed to look like.

### Decision rationale for step 6 tools-archive-rebuild (exchange 1) (round 16)

The disposition is changes-requested and the readiness floor is recorded as
incomplete. Five of the six results pass, and completeness is one of them.

1. Identity. Passes; the request tree equals the live index at entry and after
   every run.
2. Completeness. Passes. Step 6 is fully implemented, checked against the
   plan's own Step 6 text requirement by requirement and against the evidence
   rather than the summary of it.
3. Validation and coverage. Passes; all eleven declared commands behave as
   declared, and the two commands this round dropped still pass when run.
4. Staged attribution. Passes; the reviewer made no repair and staged nothing.
5. Unresolved findings. One: the umbrella contradicts the completion claim it
   ships with.
6. `a.commit`. Passes, valid, ready, accepted by the hook.

This is the first round of this step where completeness passes, and the
evidence deserves that. The RHEL run is real and long, the deployed venv is
bound to the committed lock and to byte-equal wheel ELFs, the host-child
boundary is exercised in both directions against a live deployment, D10 settles
in one reading over all 77 resolved wheel identities, and publication stays
pending behind an opaque coordinate whose replay proves only that field
differs. The reuse of the Debian evidence is the kind of shortcut that usually
deserves suspicion, and here it is defended with an explicit per-cell
assessment that I verified against the reader diff rather than accepted.

The single finding is small and it is not about acceptance. The umbrella still
says Step 6 remains No and still describes this round's work as future, in the
same change set that records Step 6 as fully implemented. The rule reserves a
commit-ready recommendation for a round with no unresolved finding, and a
reviewer may not complete or correct an umbrella row, so the honest result is
to name it and hand it back. It costs one paragraph and no re-run, and the next
round converges on exactly this evidence.

Recording it as a finding rather than waving it through is the same standard
this step has applied to itself for fifteen rounds: a document that says
something the evidence does not support is a defect, whichever direction it
points.

### Final reviewer decision for step 6 tools-archive-rebuild (exchange 1) (round 16)

Decision: changes-requested. The writer must address the concrete instructions and publish another review round. This advisory answer does not authorize a commit.

<!-- review-entry-id: answer-step-6-round-16 -->

## Round 17 by human - Step 6 - escalation

- Recorded: 2026-09-21T13:10:51+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 6
- Outcome: escalation

## Human acceptance and closure of Step 6 review

The user explicitly accepted convergence after Round 16 confirmed that Step 6
is fully implemented. The sole remaining finding, stale umbrella wording, is
corrected and staged. The user waived Round 17 and authorized committing all
remaining Step 6 work and leaving the working tree clean.

Round 16's formal recommendation remains changes-requested; no reviewer
commit-ready recommendation is manufactured. Round 17 was never published.
Automated review is stopped under this human decision. Commit authorization
comes directly from the user through the ordinary grouped commit workflow.

Step 7 remains pending and must not start before a separate user go-ahead.
No additional Jenkins run or acceptance regeneration is required for the
documentation correction.

<!-- review-entry-id: escalation-round-17 -->

## Round 1 by requestor - Step 7

- Recorded: 2026-09-21T17:01:30+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Implementation step: 7
- Outcome: request

### Review identity for step 7 tools-archive-rebuild (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Implementation plan: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
Implementation step: 7
Review round: 1

### Code review evidence for step 7 tools-archive-rebuild (round 1)

request_index_tree: d8d5e926a059c7582ad26b25c1bb8402fb49894c
resolved_validation_set:

- bash src/utils/lint_shell.sh (sources: project)
- bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 7 --python /usr/bin/python3 --app-repo $TOOLS_TEST_APP --capture-python $TOOLS_CAPTURE_PYTHON (sources: plan)
- git diff --cached --check (sources: request)

commit_plan_result:

```text
state: valid
ready: true
group 1: feat(tools-release): verify normal-pin adoption and coherent recovery
group 1 path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-archive-rebuild.sh
group 1 path: docs/v0.27.0/verify.tools-release-acceptance.sh
group 1 path: tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py
group 2: docs(tools-release): retain publication and release-pin adoption evidence
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
group 2 path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step7-completion.json
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step7-debian-retention.json
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step7-debian.json
group 2 path: docs/v0.27.0/evidence.tools-archive-rebuild.step7-execution.json
group 3: docs(tools-archive-rebuild): record step 7 validation
group 3 path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
group 3 path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.json
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.md
staged path: docs/v0.27.0/acceptance.tools-archive-rebuild.sh
staged path: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step7-completion.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step7-debian-retention.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step7-debian.json
staged path: docs/v0.27.0/evidence.tools-archive-rebuild.step7-execution.json
staged path: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md
staged path: docs/v0.27.0/verify.tools-archive-rebuild.sh
staged path: docs/v0.27.0/verify.tools-release-acceptance.sh
staged path: tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py
```

### Requestor assessment for step 7 tools-archive-rebuild (round 1)

Step 7 is fully implemented. Review the current staged implementation and the
Step 7 validation section against the exact plan and approved requirements.

Actual tools-only publication committed the accepted archive as release 10.0.0.
Independent full retrieval matched its SHA-256. Application commit 47418c764a5b7be5230896a6ebf31cf55c7f1728
removed the candidate selector and adopted the normal pin with uploads off.
Jenkins build 189 succeeded in 2854.823 seconds. All nine Debian acceptance
cells passed, including ABI (686 subjects, zero flags) and the authorized
non-browser tests with 100% application coverage. Snapshot uploads resumed only
afterward in mode-only application commit 1a5101e8.

Native RHEL cumulative step 7 passed in 92 seconds. The later digest-capture
refinement passed ShellCheck and 104 acceptance cases in 20 seconds. Controlled
whole-configuration recovery passed; actual recovery was not applicable.
Independent Python 3.9.25 completion validation passed against the real archive
and final record in 2.657 seconds. The completion proof binds the final record
hash and sole private-coordinate materialization.

No production class changed. New process tests are integration tests despite
their inherited directory. Application coverage measures src/pdfss, not these
external helpers. There is no new architecture issue, quadratic scan or feature
regression. The validation document records these boundaries explicitly.

The native runner is the previously approved cplx adaptation: cplx has no
pytest environment. The renderer resolves the configured project default to
bash src/utils/lint_shell.sh; retain that default and the additive native runner.
Do not mistake an unavailable cplx pytest setup for application validation. The application
ghog day passed with no changed Python files, and actual Jenkins supplies the
fresh required full-suite evidence. Run shell/platform checks on native Linux,
not Git Bash. Resolve TOOLS_TEST_APP and TOOLS_CAPTURE_PYTHON to the retained
native fixture app and application capture interpreter described in the local
execution scripts and evidence retention. Do not republish the immutable asset
or rerun the 48-minute CI without a concrete new concern.

### Implementation report for step 7 tools-archive-rebuild (round 1)

The Debian acceptance reader now accepts an explicit release version, checks
the downloaded archive digest, one startup release pin, release source,
uploads off and successful main chain, and retains digest/version captures.
Candidate qualification stays supported.

Fixtures cover release success and wrong digest, pin, surviving candidate,
premature uploads and failed chain. The composed local TLS integration covers
real transaction to normal-pin retrieval and completion, collision refusal
without PUT, and whole-tree versus pin-only recovery.

The durable release record now contains actual publication and fresh Debian
adoption results. Unchanged archive, application code, lock, wheels and
executable pipeline justify the explicit RHEL/D10 unaffected assessments.
Prior overwritten results retain their original identities in history.
Public evidence retains all original capture hashes; the sole workspace-prefix
redaction records both original and exported summary hashes.

Implementation-check completed the validation document and only umbrella row
7, with exact requirement and validation paths. The child draft's selected-row
copy remains historical context, not the canonical umbrella table.

### Change summary for step 7 tools-archive-rebuild (round 1)

The root a.commit is formatted and the readiness checker accepts all 12 staged
paths in three ordered groups:

1. feat(tools-release): verify normal-pin adoption and coherent recovery
   - docs/v0.27.0/acceptance.tools-archive-rebuild.sh
   - docs/v0.27.0/verify.tools-archive-rebuild.sh
   - docs/v0.27.0/verify.tools-release-acceptance.sh
   - tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py
2. docs(tools-release): retain publication and release-pin adoption evidence
   - docs/v0.27.0/acceptance.tools-archive-rebuild.json
   - docs/v0.27.0/acceptance.tools-archive-rebuild.md
   - docs/v0.27.0/evidence.tools-archive-rebuild.step7-completion.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step7-debian-retention.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step7-debian.json
   - docs/v0.27.0/evidence.tools-archive-rebuild.step7-execution.json
3. docs(tools-archive-rebuild): record step 7 validation
   - docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
   - docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md

The protocol-appended transcript is a workflow side effect for the later
authorized residual commit, not part of the captured implementation index.

### Writer response for step 7 tools-archive-rebuild (round 1)

Writer response:

This is a new step 7 review, round 1. The human explicitly closed the already
committed step 6 and prohibited a step 6 round 17. The prior exchange is closed;
do not reopen it. There is no earlier feedback for step 7 to consume.

Historical diagnostic failures in build 189 are explicitly non-gating in the
existing pipeline and remain retained as failures. The adopted blocking ABI,
test evidence and final SUCCESS are independently checked. No production
rollback was manufactured after successful adoption.

### Reviewer focus for step 7 tools-archive-rebuild (round 1)

Check the exact plan step, staged implementation, test evidence, repaired path inventory, and a.commit accuracy.

<!-- review-entry-id: request-step-7-round-1 -->

## Round 1 by reviewer - Step 7

- Recorded: 2026-09-21T17:27:02+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 7
- Outcome: answer

### Assessed index identity for step 7 tools-archive-rebuild (exchange 1) (round 1)

Baseline index tree: d8d5e926a059c7582ad26b25c1bb8402fb49894c

Assessed index tree: d8d5e926a059c7582ad26b25c1bb8402fb49894c

### Implementation check for step 7 tools-archive-rebuild (exchange 1) (round 1)

Result:

Yes. Step 7 has been fully implemented.

The reviewer checked the staged Step 7 work against the plan and confirmed its
external claims on the live systems. It did not rely on the retained summaries alone.

- Publication: the release repository answers HEAD for the 10.0.0 tools asset
  with HTTP 200, 545,293,468 bytes and an ETag SHA-1 of
  `5a0c68abac266a68ff5373376f6d55860781ede8`, which matches the COMMITTED
  receipt and the record. Its Last-Modified time falls inside the fourth,
  successful invocation window, so the three earlier failed invocations left no asset.
- Adoption: application revision `47418c764a5b7be5230896a6ebf31cf55c7f1728`
  pins `10.0.0`, keeps `publish.mode` at `off` and removes
  `tools/tools.candidate`. Jenkins build 189 built that revision and finished
  SUCCESS in 2,854,823 ms. Its live console hashes to the retained
  `console_sha256` (`1149f02e...`).
- Upload restoration: `1a5101e84491ed88e6c7944cde097a96da7dd932` changes only
  `tools/publish.mode` to `snapshot`, is a child of the adoption revision, and was
  committed after build 189 ended.
- Debian acceptance: the retained record for build 189 passes all nine cells
  with `release_version` 10.0.0 and the accepted archive digest.
- Record: publication and adoption are `pass` for the accepted archive, bound to
  the adoption revision. The three RHEL cells still pending (PA7, PA8, PA9) are
  `OPTIONAL` in the validator and stay outside the completion gate by design.
- Plan tests: the full fixture chain (streamed transaction, normal-pin
  retrieval, completion) and every listed negative exist and pass: changed
  download digest, different immutable asset without PUT, surviving candidate
  override, uploads before adoption, failed main chain, and pin-only recovery.
- Validation document: all seven step analyses read Yes, so the document-level
  `Yes, it is implemented.` is correct. The umbrella row 7 completion names an
  existing requirement and this validation plan.

Architecture: the reader extension stays in the acceptance script and the
validator neither publishes nor tests, so no layer or DDD violation was found. New work
is linear in bytes or console length, with no quadratic scan. The changed Python
test file has 278 lines, under the 650 ceiling. The new test methods are process
integration tests under the inherited unit directory, as the validation
document states. Nothing needs to be addressed.

Validation plan effects:

The reviewer made no edit to the validation plan. The writer's Step 7 rows and
the document-level status were checked and found accurate, so no reviewer
change was needed.

### Pre-repair mandatory checks and coverage for step 7 tools-archive-rebuild (exchange 1) (round 1)

All mandatory validation ran before any possible repair, and the reviewer made no repair.

- `bash src/utils/lint_shell.sh` through the project environment: exit 0,
  58 tracked scripts clean. Direct ShellCheck at style severity on the three
  changed scripts: exit 0.
- `bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 7 --python /usr/bin/python3 --app-repo <fixture-app> --capture-python <application-venv-python>`
  on native RHEL 9.8, with the bare independent Python 3.9.25. The shipped tree
  was exactly the request-time index tree
  `d8d5e926a059c7582ad26b25c1bb8402fb49894c` (git archive of the tree, no
  working-tree overlay). The fixture application was the adopted cicd revision
  `1a5101e84491ed88e6c7944cde097a96da7dd932`, with its committed helper digests
  checked. Exit 0 in 94 seconds, log SHA-256
  `c7047482cdcf5279412733668c1b3f803239668951d3aaaf1b72f22d1711aa09`. The run
  includes `PASS debian-release-complete`, the five release refusals, and both
  new publication and recovery test methods reported `ok`.
- `git diff --cached --check`: exit 0.

This rerun covers the later digest-capture refinement, which the writer had
validated only through the focused 104-case suite after its 92-second
cumulative run.

### Resolved validation set and sources for step 7 tools-archive-rebuild (exchange 1) (round 1)

- `bash src/utils/lint_shell.sh` (source: project).
- `bash docs/v0.27.0/verify.tools-archive-rebuild.sh --step 7 --python /usr/bin/python3 --app-repo $TOOLS_TEST_APP --capture-python $TOOLS_CAPTURE_PYTHON` (source: plan).
- `git diff --cached --check` (source: request).

### Resolver drift and direction for step 7 tools-archive-rebuild (exchange 1) (round 1)

No drift. The current resolver set equals the request set, and all three commands ran.

### Repository state around validation for step 7 tools-archive-rebuild (exchange 1) (round 1)

The index tree was `d8d5e926a059c7582ad26b25c1bb8402fb49894c` at request time,
at review entry and after the assessment. The umbrella digest was unchanged
before and after (`46b95d18...`). The validation-state comparison over all
twelve staged paths is acceptable, with no tracked, untracked or ignored
differences. The only unstaged change is the protocol-appended transcript,
which the request declares outside the captured index.

### Repair inventory for step 7 tools-archive-rebuild (exchange 1) (round 1)

Repairs made:

- None. The reviewer made no repair and staged nothing.

Paths staged:

- - `docs/v0.27.0/acceptance.tools-archive-rebuild.json`
- - `docs/v0.27.0/acceptance.tools-archive-rebuild.md`
- - `docs/v0.27.0/acceptance.tools-archive-rebuild.sh`
- - `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`
- - `docs/v0.27.0/evidence.tools-archive-rebuild.step7-completion.json`
- - `docs/v0.27.0/evidence.tools-archive-rebuild.step7-debian-retention.json`
- - `docs/v0.27.0/evidence.tools-archive-rebuild.step7-debian.json`
- - `docs/v0.27.0/evidence.tools-archive-rebuild.step7-execution.json`
- - `docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.validation.md`
- - `docs/v0.27.0/verify.tools-archive-rebuild.sh`
- - `docs/v0.27.0/verify.tools-release-acceptance.sh`
- - `tests/unit/tools_release_record/test_tools_release_record/test_release_publication_tdd.py`

### Commit plan assessment for step 7 tools-archive-rebuild (exchange 1) (round 1)

The independent `commit-plan-check.bat --format json` run returned state
`valid`, `ready: true` and no diagnostics. It covers all twelve staged paths in
three groups, in order: tests and harness (`feat(tools-release)`), then the retained
publication and adoption evidence (`docs(tools-release)`), then the validation
and umbrella completion (`docs(tools-archive-rebuild)`). Each group depends only
on the ones before it, and the subjects and bodies match the staged content.
`a.commit` remains accurate; the reviewer did not amend it.

### Findings and boundaries for step 7 tools-archive-rebuild (exchange 1) (round 1)

Unresolved findings: None.

Boundary-crossing work: None.

### Writer instructions for step 7 tools-archive-rebuild (exchange 1) (round 1)

No rework is required. If the human selects Commit, stage this answer's protocol
append to the transcript as the workflow prescribes, then run the installed
hook and the commit-plan checker once more against the final index before
committing.

### Decision rationale for step 7 tools-archive-rebuild (exchange 1) (round 1)

All six readiness-floor results pass: exact identity, complete implementation,
mandatory validation (rerun independently on native RHEL against the exact
tree), attributable staged scope with no reviewer repair, no unresolved
blocking finding, and an accurate `a.commit`. The step's external claims
(publication, retrieval identity, build 189 and its console, the adoption and
upload-restoration revisions) were confirmed on the live systems. The
recommendation is commit-ready. It is advisory and does not authorize a commit.

The writer asked the reviewer not to republish the immutable asset or rerun
the 48-minute CI without a concrete new concern. The reviewer did neither and
used read-only HEAD and API queries plus the retained console instead.

Two optional notes, neither a defect nor required for this step:

- The PA6 Debian detail string still reads "from the candidate venv" in release
  mode. The venv is the application venv provisioned from the release archive,
  and PA1 and the pins already record `source release` and `release_version`
  10.0.0, so no verdict depends on the wording. Changing it now would alter the
  reader digest bound in the retained build 189 evidence, so it fits a later
  reader change better.
- The five release refusal fixtures assert exit status 2 without a `said`
  message check. Each mutation changes exactly one input read by one release
  check, and only `refuse` exits 2, so each result is attributable today.
  Adding the message checks would be a possible hardening.

### Final reviewer decision for step 7 tools-archive-rebuild (exchange 1) (round 1)

Decision: commit-ready (advisory). The evidence floor is complete, but this recommendation does not authorize a commit; authority remains at the durable human gate.

<!-- review-entry-id: answer-step-7-round-1 -->

## Round 1 by human - Step 7 - human-confirmation

- Recorded: 2026-09-21T17:44:10+02:00
- Exchange: code/code/v0.27.0/tools-archive-rebuild
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.tools-archive-rebuild.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Implementation step: 7
- Outcome: human-confirmation

Human choice: Commit
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-1 -->
