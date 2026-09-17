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
