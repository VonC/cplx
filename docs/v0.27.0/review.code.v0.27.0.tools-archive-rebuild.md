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
