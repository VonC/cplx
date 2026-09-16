# Specification review transcript for v0.27.0

- Exchange: specification/plan/v0.27.0/python-sqlite-support
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-09-15T17:54:55+02:00
- Exchange: specification/plan/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: unrecorded
- Outcome: request

### Review identity for plan python-sqlite-support (round 1)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
Review round: 1

### Requestor assessment for plan python-sqlite-support (round 1)

The new plan has four ordered steps and a matching unstarted validation skeleton.
The six settled design decisions and requirement closure correction are preserved.

Six implementation questions cover the new standard-library test layout, complete
driver/Windows fixtures, exact source extension directory, real source-commit
anchoring, early acceptance feasibility and stronger preservation manifests.
Options and recommended answers are sufficient for a first review; please assess
missing implementation questions independently. No earlier reviewer wording
suggestions apply to this new plan round.

Inspect Q04 particularly: the proposed separate source-evidence branch preserves
the same-commit declaration/envelope rule, but its exact construction, hooks and
transfer obligations need review. Q03 and Q06 intentionally recommend tighter
implementation checks than the initial plan body. An unavailable isolated layout
or Debian route is a Step 4 blocker, never permission for live replacement or an
installer redesign. No implementation, remote acceptance or publication has run.

### Change summary for plan python-sqlite-support (round 1)

This is the first implementation-plan review for the Python SQLite effort.

Created the four-step implementation plan, counted production/integration files,
adapted test commands to the repository's Bash floor and standard-library Python
probe, and created the matching empty validation skeleton. Added consistent
file-based IO clarifications to the requirement, design, plan and validation
documents as required by write-plans; corrected one design grammar typo.

The preceding design consolidation and matching requirement correction were
committed as 1708823 and c0b0d4f. Their review exchange is closed. Six new plan
questions were placed through oqm; none reopens the six design choices.

### Writer response for plan python-sqlite-support (round 1)

Writer response:

No earlier answer exists for this plan exchange.

The writer recommends A1, B1, C1, D1, E1 and F1. Please verify the proposed
source-evidence Git procedure against existing authority and workflow contracts,
the build/assembly HOME distinction, the relocation anchor prerequisite, and
whether every acceptance claim has a concrete executable evidence path. The
validation skeleton remains unstarted and must stay aligned if steps change.

### Reviewer focus for plan python-sqlite-support (round 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

### LLM nature completion for reviewer (exchange 1)

Recorded nature: `claude`

Completed artifacts:

- `C:/Users/vonc/git/cplx/.reviews/a.review-active.specification.plan.v0.27.0.python-sqlite-support.md`
- `C:/Users/vonc/git/cplx/.reviews/a.review-requested.plan.v0.27.0.python-sqlite-support.md`

<!-- review-entry-id: llm-nature-completion-reviewer-exchange-1 -->

## Round 1 by reviewer

- Recorded: 2026-09-15T17:59:56+02:00
- Exchange: specification/plan/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan python-sqlite-support round 1

The plan keeps the settled design (A1, B1, C1, D1, H2, J1) and the requirement
correction, orders the work sensibly, and adapts the standard layout honestly
to the Bash floor. The reviewer checked its constraints against the sources:

- the install driver sources `${DIR}/../.env` itself;
- `.env` sources `${HOME}/.profile` and then rebinds `HOME` to its own
  directory;
- `rsync.sh` derives `${HOME}/cplx/tools/*` and `${HOME}/tools`;
- `pkg_tools.sh` mirrors `$HOME/tools` and refuses a caller source root;
- `closure_config_authority_check` reads `git cat-file blob <commit>:<path>`;
- the committed envelope names `089f214`, a declaration commit that precedes
  the envelope commit `fd12941`.

The six questions are real implementation choices. Three substantive issues
remain.

#### The relocation anchors already decide Q05's feasibility for plan python-sqlite-support (round 1)

`install_pkg.sh` re-anchors build paths with exactly two patterns (lines
157-162): `^/home/<one segment>/cplx/tools/` to `<prefix>/tools/`, then
`^/home/<one segment>/` to `<prefix>/`. Its interpreter and rpath passes are also
builder-anchored (the header comment at line 6 and the `*/home/*` test near line
1023). For a candidate built in a nested isolated
layout such as `/home/<account>/<iso>/cplx/tools/python/...`:

- the first pattern does not match;
- the second maps the path to `<prefix>/<iso>/cplx/tools/...`, which is wrong.

Only a build tree directly at `/home/<name>/cplx/tools` relocates correctly.
That means the account's own existing cplx staging tree, or a second account or
home directory under `/home`, which an unprivileged operator normally cannot
create.

Q05 E1 schedules this as Step 1 discovery, but the sources already answer it for
any nested layout. The plan should put the resulting decision to the human now,
instead of building Steps 1-3 toward a Step 4 that is likely blocked:

- keep the design's complete-layout isolation by obtaining an anchor-compatible
  `/home/<name>` home;
- or build in the account's existing `~/cplx/tools` staging tree (the normal,
  anchor-compatible build location, which is not the live `~/tools`) and isolate
  promotion, packaging and deployment from a copy of that staged result. That
  narrows design H2's "owns its `cplx`" wording and needs a design amendment;
- or change the installer's anchors, which the plan rightly refuses to expand
  silently and which would be a design and requirement change.

#### The source-build probe needs CPython's build-tree environment for plan python-sqlite-support (round 1)

Step 2 runs `${tool_src}/python` from the source tree. With `--enable-shared`,
that binary needs the build directory's `libpython3.13.so`. CPython's own
Makefile runs it through `RUNSHARED` (`LD_LIBRARY_PATH` including the build
directory). The driver's exported `LD_LIBRARY_PATH` names the sandbox and
`${tool_prefix}` directories but not `${tool_src}`. On a rebuild of an existing
prefix, the source binary can therefore load the previously installed
`libpython3.13.so` instead of the one just built, or fail to start.

Q03's "generated build-directory record" also exists concretely: CPython writes
`pybuilddir.txt` naming `build/lib.linux-x86_64-3.13`, which is where `./python`
imports compiled extensions from. Both facts should be stated so the source
check validates the new build, not a mix of new and installed parts.

#### Q04 creates commits outside the reviewed commit gate for plan python-sqlite-support (round 1)

Both D1 and D2 make an evidence commit, and D2 a merge, during Step 3
implementation, before the grouped `a.commit` of the reviewed staged tree. The
workflow commits only through that gate or with explicit human authorization,
and the sensitive-content hooks must run on every commit. The plan does not say
who authorizes these auxiliary commits or when.

The choice of construction also affects the transfer obligation:

- D1's side ref is dropped by any push, clone or Jenkins checkout that does not
  name it, and `closure_config_authority_check` then fails wherever publication
  runs.
- D2 done as `git merge -s ours --no-ff <evidence>` keeps the tree byte-identical
  (so D2's stated risk of replacing unrelated files does not arise), and carries
  the anchor with ordinary branch history through the feature merge.

#### Smaller points for plan python-sqlite-support (round 1)

- **Isolated home `.profile`.** `.env` sources `${HOME}/.profile` before
  rebinding `HOME`. The Step 4 layout lists `cplx/`, `tools/`, `pkgs/`, `.env`
  and `.env_`, but not whether the isolated home carries an audited copy of the
  operator's `.profile` or deliberately none. That choice changes the build
  environment and should be explicit.
- **Constraint wording.** Constraint 29 says "Build commands therefore use the
  isolated cplx root as `HOME`", while the Step 4 build command passes
  `HOME="$sqlite_account_home"`. Both are right, because `.env` performs the
  rebinding, but the constraint should say so.
- **Blob digest on Windows.** Step 3 should state that the envelope digest is
  computed from the committed blob (`git cat-file blob`), not a Windows
  working-tree file that `core.autocrlf` may have converted. The CRLF refusal
  test implies this without saying it.

### Question verdicts for plan python-sqlite-support round 1

#### Q01 verdict for plan python-sqlite-support (round 1)

Agree with A1. The standard-library `unittest` subtree follows the shared layout
without a host package dependency, and the Bash runner stays the single
cumulative entry point.

Wording: state that the probe is also shipped under the remote `tools/python`
support tree (from `src/install/env/python/`), so the tested file is the one
the build and acceptance callers execute.

#### Q02 verdict for plan python-sqlite-support (round 1)

Agree with B1. The copied-script precedent exists, and full-process fixtures are
needed anyway to prove selector behavior.

#### Q03 verdict for plan python-sqlite-support (round 1)

Agree with C1, made concrete. Suggested replacement for C1:

"Read CPython's generated `pybuilddir.txt` (for 3.13, `build/lib.linux-x86_64-3.13`)
from the current build, pass that exact directory as the extension boundary, and
run `${tool_src}/python` with the build tree's shared-library environment
(CPython's `RUNSHARED` equivalent, the build directory first) so it loads the
just-built `libpython3.13.so`, not an installed one. Test a missing or stale
`pybuilddir.txt`, a stale extension elsewhere in the source tree, inherited
`PYTHONPATH`, and a mismatched `libpython` load."

#### Q04 verdict for plan python-sqlite-support (round 1)

Both options are valid constructions. The reviewer would choose D2 done as
`git merge -s ours --no-ff <evidence-commit>`: the tree stays byte-identical and
the anchor travels with ordinary history. D1's separate ref is easy to lose on
push or clone, which breaks the authority check where publication runs.

Either option must add: "The evidence commit (and, for D2, the merge) is created
only with explicit human authorization, outside the grouped `a.commit`, with
sensitive-content hooks active. Its parent is the implementation branch HEAD and
its only change is the declaration. The digest and envelope are computed from
`git cat-file blob <sha>:src/setups/env/closure/closure-config.txt`."

Replace D2's con "the merge must not replace unrelated files with the evidence
tree" with "adds a non-first-parent commit whose declaration lacks its envelope;
tools that walk every ancestor (for example bisect) can land on it".

#### Q05 verdict for plan python-sqlite-support (round 1)

Agree that feasibility must be established before expensive work (E1). The
options need rewriting, though, because the installer anchors already exclude
any nested isolated layout. See the missing Q07 below. E1 alone would record a
foreseeable Step 4 blocker instead of deciding the route.

#### Q06 verdict for plan python-sqlite-support (round 1)

Agree with F1. Content digests are appropriate for the explicit preservation
claim, and a concurrent external change is correctly reported as unresolved,
not as success.

#### Missing Q07: which anchor-compatible layout builds the candidate for plan python-sqlite-support (round 1)

Add a question that cites the `install_pkg.sh` re-anchoring patterns
(`/home/<seg>/cplx/tools/`, then `/home/<seg>/`).

- **K1:** build in a separate home directly under `/home` (a second account or
  an administrator-provided directory), keeping design H2's complete isolation.
  - pro: no design change.
  - con: needs an account or directory the operator cannot create; this is an
    external prerequisite.
- **K2:** build in the account's existing anchor-compatible `~/cplx/tools`
  staging tree, which is not the live `~/tools`. Record and restore its selector
  and version directory, and run promotion, packaging and deployment in an
  isolated `HOME` from a byte copy of the staged result, with preservation
  evidence for the live `~/tools`.
  - pro: uses the normal build location and no administrator rights.
  - con: narrows H2's "owns its `cplx`" wording (needs a design amendment), and
    the staging tree changes during the candidate build.
- **K3:** extend the installer's anchors to accept a nested build root.
  - pro: allows fully nested isolation.
  - con: changes the relocation contract owned by earlier items; it needs design
    and requirement amendments and new relocation regression.

The reviewer would choose K2, with the design amendment presented for
confirmation. It stays within the project's no-administrator constraint and
keeps the live `~/tools` tree protected, which is what the design's isolation
claim exists to protect. Choose K1 instead if a separate home can be provided.

### Requested changes for plan python-sqlite-support round 1

Requested changes:

- Add the missing decision on an anchor-compatible build layout: `install_pkg.sh`
  relocates only `/home/<seg>/cplx/tools/` and `/home/<seg>/` build roots, so a
  nested isolated layout cannot relocate correctly. Reframe Q05 accordingly.
- Make the source-build probe use CPython's `pybuilddir.txt` and the build
  tree's shared-library environment, so it cannot mix the new binary with an
  installed `libpython3.13.so`.
- In Q04, require explicit human authorization and active hooks for the
  auxiliary evidence commit or merge, compute the digest from the committed
  blob, correct D2's con, and reconsider D2 via `git merge -s ours`.
- State the isolated home's `.profile` choice, and clarify constraint 29's
  `HOME` wording.

### Writer instructions for plan python-sqlite-support round 1

1. Add Q07 on the anchor-compatible build layout (options K1-K3), citing the two
   `install_pkg.sh` re-anchoring patterns. Update Q05's framing so Step 1
   confirms the chosen route instead of discovering whether nested isolation
   works. If K2 is recommended, flag the design amendment to H2 as a
   prerequisite; do not edit the settled design in this plan round.
2. Rewrite Q03 C1 and the Step 2 source-check text around `pybuilddir.txt` and
   the build tree's shared-library environment. Add the mismatched-`libpython`
   and stale-`pybuilddir.txt` controls to Step 2's test list.
3. In Q04, add the explicit-authorization, hook, parent and blob-digest
   conditions to both options, and correct D2's con. Reconsider the
   recommendation in light of the transfer robustness of
   `git merge -s ours --no-ff`.
4. State in Step 4 whether the isolated home carries an audited copy of
   `.profile` or none, and reword constraint 29 to say that `.env` rebinds
   `HOME` to the cplx root.
5. Apply the Q01 wording note about the probe's shipped location.
6. Keep the validation skeleton aligned with any step text changes. Do not
   consolidate; publish the next round.

### Final reviewer decision for plan python-sqlite-support round 1

Decision: changes-requested. The writer should apply the concrete instructions and publish another automated review round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-09-15T18:08:27+02:00
- Exchange: specification/plan/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: request

### Review identity for plan python-sqlite-support (round 2)

Umbrella draft: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
Review round: 2

### Requestor assessment for plan python-sqlite-support (round 2)

Four aligned steps remain unstarted. Six questions are sufficient for the
implementation plan after applying round 1's concrete source-library, Git,
environment and preservation corrections. Recommended answers are now A1, B1,
C1, D2, E1 and F1. The options include their practical costs and failure cases.

No missing plan question remains: the proposed Q07 alternatives K2/K3 reopen
settled design/requirement choices. The user just confirmed complete H2 isolation.
The plan now explicitly records K1's directly anchored separate home as an
external prerequisite, excludes nested homes and routes unavailable facilities
back to the owning design before any scope amendment. Q05 concerns assessment
timing only. Please assess this explicit disagreement, not an implied acceptance
of K2. All other reviewer wording suggestions have been applied.

### Change summary for plan python-sqlite-support (round 2)

Since round 1, the plan and matching validation goals now specify:

- validated pybuilddir.txt, generated Modules symlink handling, source-directory
  LD_LIBRARY_PATH precedence and mapped libpython identity using one maps read;
- source probe transport and matching tested-byte digest for acceptance;
- D2 auxiliary source snapshot and tree-preserving ours merge, prepared for
  explicit human authorization, with active hooks, committed-blob digest,
  normal grouped bundle gate and fresh local clone authority validation;
- the known nested-home incompatibility and mandatory separately writable
  `/home/<one-segment>` prerequisite under settled H2;
- deliberately absent isolated .profile, explicit audited scalar inputs,
  BASH_ENV removal and correct incoming/rebound HOME descriptions;
- one before/after content-manifest pair covering live payload/control trees.

Updated six questions via the ignored companion and oqm. No design decision was
changed, no implementation was marked complete and no remote execution occurred.

### Writer response for plan python-sqlite-support (round 2)

Writer response:

Accepted round 1's source libpython finding, concrete pybuilddir.txt checks,
Q01 transport wording, explicit HOME/profile choice, stronger manifests and
auxiliary Git authorization/hooks/blob requirements. Reconsidered Q04 and now
recommend D2: a normal reviewed paired bundle followed by an authorized ours
merge retains the anchor with ordinary branch history. The plan cannot grant
itself the later exceptional commit authorization.

CPython's primary Makefile also shows sharedmods links the generated import
directory to Modules/*.so. Exact canonical containment inside the import
directory would reject that valid build. C1 therefore checks the normalized
import location and the canonical Modules backing location, plus source
libpython identity, without broadening the installed-stage boundary.

Explicit disagreement with adding Q07 K1/K2/K3 or recommending K2 in this plan:
K2 narrows the H2 design the user has just confirmed, and K3 changes the owning
requirement/relocation contract. Shared review-ask-questions instructions forbid
reasking earlier-type decisions in a plan; they require identifying the owning
document instead. K1 is the compatible implementation of confirmed H2, now
explicitly required as an external facility. The plan names the exact anchors,
rules out nested homes and retains a visible Step 4 blocker if that facility is
unavailable. Changing H2 must be presented in the earlier design context and
cannot be smuggled in as a new implementation answer. Q05 now confirms facility
availability rather than rediscovering known anchor behavior.

Please assess the revised concrete plan and six remaining implementation
questions. The validation skeleton remains unstarted and aligned.

### Reviewer focus for plan python-sqlite-support (round 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-09-15T18:10:23+02:00
- Exchange: specification/plan/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: answer

### Reviewer assessment for plan python-sqlite-support round 2

The reviewer reread the full plan. The round 1 findings are resolved or answered
by an accepted disagreement.

#### Source-build probe for plan python-sqlite-support (round 2)

Step 1 and Step 2 now implement the CPython build-tree contract:

- `pybuilddir.txt` is validated (present, relative, inside the source tree,
  consistent with the build, not stale or escaping) and its exact directory is
  the extension boundary.
- CPython's generated import-directory links backed by `Modules/` are accepted,
  and a link escaping the source tree is refused. Installed and operator stages
  keep their stricter `lib-dynload` backing rule.
- `${tool_src}/python` runs with a command-scoped `LD_LIBRARY_PATH` that puts the
  build directory first, matching Linux `RUNSHARED`.
- The new `--expected-libpython` identity is checked from the same maps read,
  so an old installed `libpython` fails even if the binary starts.

The matching test controls (missing or stale marker, stale in-source extension,
`PYTHONPATH`, mismatched `libpython`) are listed.

#### Closure source anchor for plan python-sqlite-support (round 2)

Q04 now recommends D2. The evidence commit is prepared for explicit human
authorization as a named exception to the grouped `a.commit`, with hooks
active. Its parent is the clean branch HEAD and its only change is the
declaration. The digest comes from the committed blob. The paired bundle goes
through the normal gate, then `git merge -s ours --no-ff` runs with identical
before/after tree IDs and a fresh-clone resolution check. The all-ancestor
limitation is recorded, and no push runs. That construction is sound.

#### Profile and HOME for plan python-sqlite-support (round 2)

Constraint 29 now says `.env` rebinds the incoming account home to the cplx root
inside the build child. Step 4 deliberately creates no `.profile`, records an
explicit scalar environment, and unsets `BASH_ENV` on every child. That matches
`.env`'s `if [[ -e "${HOME}/.profile" ]]` source.

#### The Q07 disagreement is accepted for plan python-sqlite-support (round 2)

The reviewer proposed deciding the anchor-compatible layout now, including a K2
option that narrows H2. The writer answers that the user has just confirmed
complete H2 isolation, and that a plan must not re-ask a design or requirement
decision but name the owning document. The plan now does what matters for the
finding:

- constraint 31 states the exact `install_pkg.sh` anchors and that a nested home
  leaves an unwanted segment;
- Steps 1 and 4 require a separately writable home directly below `/home` as an
  external prerequisite, without account creation or elevation;
- a missing home blocks Step 4 and is reported to the design workflow before any
  scope change;
- live staging and anchor changes are explicitly excluded as fallbacks.

The risk the reviewer raised is now visible and routed to its owner, so no plan
change is outstanding on it.

#### Remaining suggestions for plan python-sqlite-support (round 2)

Remaining suggestions are wording-only (see the Q01, Q04 and Q05 verdicts).

### Question verdicts for plan python-sqlite-support round 2

#### Q01 verdict for plan python-sqlite-support (round 2)

Agree with A1.

Wording-only suggestion: the probe is a standalone script outside any package,
so state that the unit test loads `src/install/env/python/sqlite_probe.py` by
file path (for example `importlib.util.spec_from_file_location`) rather than
through the new `tests` packages.

#### Q02 verdict for plan python-sqlite-support (round 2)

Agree with B1.

#### Q03 verdict for plan python-sqlite-support (round 2)

Agree with C1 as revised. It follows CPython's `pybuilddir.txt` and `RUNSHARED`
contracts and adds the `libpython` identity check.

#### Q04 verdict for plan python-sqlite-support (round 2)

Agree with D2.

Wording-only precision for Step 3: `git merge` runs the `pre-merge-commit` and
`commit-msg` hooks, not `pre-commit`. Because the merge tree is verified
identical, the sensitive-content check applies in substance to the evidence
commit and the reviewed bundle. "Keep sensitive-content hooks active" should
say which hooks each operation runs, so the evidence does not imply a
`pre-commit` pass on the merge.

#### Q05 verdict for plan python-sqlite-support (round 2)

Agree with E1, and with the writer's decision to keep layout alternatives in
the design context.

Wording-only suggestion: since the anchor rule makes the home prerequisite the
most likely blocker, say that Step 1 confirms the directly anchored
`/home/<one-segment>` home first, before probe implementation. The design
workflow can then be engaged as early as possible if the home is unavailable.

#### Q06 verdict for plan python-sqlite-support (round 2)

Agree with F1.

### Convergence evidence for plan python-sqlite-support round 2

Covered wording:

- Step 1 test paragraph, append: "The unit test loads the standalone
  `src/install/env/python/sqlite_probe.py` by file path, for example with
  `importlib.util.spec_from_file_location`, not as a package import."
- Step 3, replace "Keep sensitive-content hooks active." with "Keep hooks active:
  the evidence commit and the reviewed bundle run `pre-commit` and `commit-msg`;
  the `-s ours` merge runs `pre-merge-commit` and `commit-msg`, and its tree is
  verified identical, so it introduces no content."
- Q05 Option E1, change "In Step 1, confirm access" to "At the start of Step 1,
  before probe implementation, confirm access".

Convergence rationale:

Every in-scope implementation decision is settled in the plan text with a
pending recommendation the reviewer agrees with:

- test layout (Q01);
- driver and launcher fixtures (Q02);
- source-build identification (Q03);
- closure source anchoring (Q04);
- facility assessment timing (Q05);
- preservation evidence (Q06).

The round 1 technical findings (build-tree `libpython`, `pybuilddir.txt`,
auxiliary commit authorization and blob digest, profile and HOME wording) are
incorporated. The anchor-layout finding is answered by an accepted disagreement:
the plan states the constraint, requires the compatible home as an external
prerequisite, and routes any H2 change to the design workflow instead of
re-asking it here.

What remains is three optional wording refinements. This recommendation is
advisory. It does not authorize consolidation or the auxiliary Git operations.

### Writer instructions for plan python-sqlite-support round 2

1. Optionally apply the three wording-only suggestions:
   - Q01: the file-path import of the standalone probe in the unit test;
   - Q04: the hooks each auxiliary Git operation actually runs;
   - Q05: the home availability check ordered first in Step 1.
2. Keep the validation skeleton aligned with any wording change.
3. Present the six pending recommendations (A1, B1, C1, D2, E1, F1) for human
   confirmation. Make it visible that Step 4 depends on an externally provided
   directly anchored home and a Debian runtime and copy route, and that the
   auxiliary Git operations need their own explicit authorization at Step 3.
4. Do not treat this recommendation as authorization to consolidate or to create
   any commit.

### Final reviewer decision for plan python-sqlite-support round 2

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human - human-confirmation

- Recorded: 2026-09-15T20:09:17+02:00
- Exchange: specification/plan/v0.27.0/python-sqlite-support
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: docs/v0.27.0/plan.v0.27.0.python-sqlite-support.md
- Requestor LLM nature: codex
- Reviewer LLM nature: claude
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
