# Implementation plan v0.27.0 -- Keep the python wrapper working on a foreign distribution

Reference design: [design.v0.27.0.python-wrapper-foreign-distro.md](design.v0.27.0.python-wrapper-foreign-distro.md)
Reference issue: [issue.v0.27.0.python-wrapper-foreign-distro.md](issue.v0.27.0.python-wrapper-foreign-distro.md)

---

## Plan goal for v0.27.0 python-wrapper-foreign-distro

Change one 91-line bash file so that the shipped search path serves the
interpreter and nothing else the wrapper runs, and so that an unusable helper
result stops the wrapper instead of feeding its surgery.

The plan is deliberately small. The design settles the mechanism; there is no
new module, no new tool, and no change to any shipped file outside the wrapper.

## Scope anchors for the v0.27.0 python-wrapper-foreign-distro plan

- `src/install/env/python/bin/python`: the only SHIPPED file this plan modifies.
- `src/install/env/python/bin/setenv`: read, asserted byte-identical, never
  written.
- `docs/v0.27.0/verify.wrapper-scope.sh`: new, the verification harness.
- `docs/v0.27.0/wrapper.pre-change.verification-only`: new, the retained
  pre-change wrapper the step 5 control runs. Never shipped, never packaged.
- `docs/v0.27.0/verify.wrapper-scope.manifest.txt`: new, step 4's output,
  generated from the FROZEN harness bytes and written in a commit AFTER the
  freeze, naming `freeze_commit`, `harness_path` and `file_sha256` over the
  file bytes at that path.
- the pipeline-side copy, manifest and probe named at exact paths in "The
  cross-repository handoff" below. NAMED HERE, LANDED THERE by the cplx
  maintainer, and landed BY STEP 4 rather than owed after step 5.

Nothing in this plan touches the installer, the relocation pass or the archive.

## Confirmed technical facts for plan viability

Verified by reading the file at the commit this plan is written against:

- line 18 is `source "${DIR}/setenv"`;
- line 30 reads `readlink` on `current/bin/python3`;
- line 47 reads `readlink` on `current/bin/python3_target`;
- line 66 reads `readlink` on the venv's `python3`;
- lines 60 and 62 are the two interpreter invocations, in the two arms of one
  `if`;
- the first write of the surgery is the `mv` at line 34, so a check placed
  after line 30 and before line 32 protects the whole block.

TWO FACTS CORRECTED IN ROUND 1, both re-read from the source rather than
assumed, because round 1's own question got the first one wrong:

- EVERY external helper the wrapper runs is invoked UNQUALIFIED and resolved
  through `PATH`: `readlink`, `mv`, `ln`, `cp`, `sed` and `grep`. No helper uses
  an absolute executable path. Only the interpreter at lines 60 and 62 is called
  by absolute path, and it is not a helper. A `PATH` shim therefore reaches
  every helper invocation, and coverage is nonetheless asserted rather than
  assumed;
- line 12's `readlink -f` is itself `PATH`-resolved and runs BEFORE the export
  exists. It resolves the wrapper's own directory, so a `readlink` shim that
  fails it stops the wrapper before any guarded site is reached, and the run
  proves nothing. The shim must DELEGATE the bootstrap call and fail only the
  selected guarded path.

## Executable target matrix

| Step | What it proves | Host |
| --- | --- | --- |
| 0 | baseline: the current behavior, clean AND failing, before any change | any |
| 1 | the scope rule: helpers unset, interpreter set, measured from the run | any |
| 2 | failing closed: a planted helper failure stops the wrapper, tree unmodified | any |
| 3 | acceptance on RHEL: first call, second call, `-m venv`, no regression | RHEL target |
| 4 | preparation: freeze the harness, publish its identity, land the handoff, obtain a build | any, plus the pipeline repository |
| 5 | acceptance on Debian: the first call the defect actually breaks | Debian CI agent |

STEP 5 IS THE ONE THAT MATTERS, and it is a step here rather than an obligation
handed elsewhere. An earlier draft deferred the Debian first call to umbrella
item 7, on the correct reading that this requirement had no Debian environment
in hand. That is no longer true: the CI agent is Debian 12, it is reachable
again, and item 7's matrix runs after a rebuild this requirement does not need.

So the split is now the honest one. Steps 0 to 2 prove the mechanism on any
host. Step 3 proves nothing regressed where the defect is invisible. Step 5
proves the fix on the distribution the defect exists on, which is the only run
that can distinguish a working fix from a plausible one.

STEP 4 EXISTS BECAUSE STEP 5 CANNOT PRODUCE WHAT IT CONSUMES. An earlier draft
made the Debian step generate the identity manifest AND require that manifest to
be already landed and used by a build before it could start, which is circular.
Preparation is now its own step whose outputs are the frozen harness, the
manifest, the pipeline copies and one build capture; step 5 consumes exactly
those and produces none of them.

## The recording shim contract

Steps 0 to 2 measure the wrapper from its own run, never from its source. The
instrument is a set of recording shims placed FIRST on `PATH`, one per helper
name, each of which appends one line to a shim call log and then delegates to
the real tool.

Each logged line carries: the helper name, the argument vector, the observed
`LD_LIBRARY_PATH` exactly as inherited (with "unset" and "empty" distinguished),
and the working directory.

THE LOG IS ASSERTED, NOT SCANNED FOR ABSENCE. A check that passes because a
helper never appeared is the failure mode this whole umbrella exists to refuse,
so every step naming a helper asserts the EXPECTED CALLS ARE PRESENT with the
expected environment, and only then asserts that no unexpected call carries the
shipped search path.

THE SCOPE ORACLE COVERS THE FOURTEEN POST-SOURCE HELPERS ONLY. Line 12's
bootstrap `readlink -f` runs BEFORE `setenv` is sourced, so nothing this
requirement controls has touched the environment it inherits. It is logged and
delegated like every other call, and asserted separately as a delegated setup
call, but its inherited environment is NOT part of the unset claim. Requiring it
to observe an unset variable would fail a legitimate run whose caller exported
one, which is the caller's business and not this wrapper's.

The `readlink` shim is special and its rule is explicit:

- the bootstrap call at line 12, recognisable by its `-f` flag, is ALWAYS
  delegated and never failed;
- failure is injected BY SELECTED PATH, one guarded site at a time, so a run
  that fails site 30 still performs the setup that reaches it;
- the shim records which site it failed, and the harness asserts that the
  recorded injected call matches the site the case intended.

The interpreter stub records the restored `LD_LIBRARY_PATH` separately, since
the interpreter is invoked by absolute path and no `PATH` shim can observe it.

## The fixture contract

| Steps | Interpreter | Why |
| --- | --- | --- |
| 0 to 2 | a recording shell stub | keeps the portable steps runnable on any host, which is decision P1 |
| 3 and 5 | the real archive interpreter | `-m venv` must actually create a venv, so the third guarded read site executes for real |

The stub records its argument vector and its inherited environment, and exits
zero. It is not a python: it never runs `-m venv`, which is exactly why steps 3
and 5 use the real interpreter instead of extending the stub.

## The checked-call contract for the guards

Decision W4 stops at all three read sites. The shared helper form must make that
stop REACH THE WRAPPER, which a naive helper does not:

```text
value=$(guarded_readlink "<site-label>" "<path>") || exit
```

A function invoked through command substitution runs in a SUBSHELL. An `exit`
inside it terminates the subshell and the wrapper carries on with an empty
value, which is the original defect wearing a guard's clothes. The contract is
therefore:

- `guarded_readlink SITE PATH` runs `readlink` and returns non-zero when EITHER
  the exit status is non-zero OR the output is empty, printing a message naming
  the helper, the site label and the path on stderr;
- EVERY caller propagates that failure explicitly, so the outer wrapper exits;
- the harness asserts, for each of the three injected failures, that no `mv`,
  `ln`, `cp` or `sed` line appears in the shim call log after the injected
  `readlink`. That assertion is what proves the propagation, rather than the
  presence of the word `exit` in the source.

## The cross-repository handoff

Step 4 runs on the Debian CI agent, which builds the pipeline repository and has
no credentials for this one. The harness therefore has to travel, and this plan
names the exact artifacts rather than leaving them implied.

| Role | Exact path | Repository |
| --- | --- | --- |
| canonical harness | `docs/v0.27.0/verify.wrapper-scope.sh` | this one |
| identity manifest | `docs/v0.27.0/verify.wrapper-scope.manifest.txt` | this one, generated |
| harness copy | `tools/wrapper_scope_verify.verification-only.sh` | pipeline |
| manifest copy | `tools/wrapper_scope.manifest.verification-only.txt` | pipeline |
| probe | `wrapperScope()` in `ci/Jenkinsfile.diagnostics`, called from `verifyCplx()` | pipeline |
| retained capture | `a.evidence/verify-wrapper-scope.debian.txt` | pipeline, per build |

THE HANDOFF OWNER IS NAMED, not left as "whoever holds the repository". The
pipeline file `ci/Jenkinsfile.diagnostics` is owned by the cplx maintainer by its
own header, which states that probes may be added, moved or deleted there without
touching the pipeline's reviewed stages. The handoff is therefore the same
commit-and-push flow that already lands cplx probes on the pipeline repository's
`develop` branch, performed by the cplx maintainer, and it is a change in another
repository rather than a change this plan's steps make.

### The identity manifest, and where its authority actually comes from

The agent cannot reach cplx, so it cannot obtain the authoritative digest on its
own. An expected digest maintained beside the pipeline copy DOES catch the
accidental case, where the copy is edited and the literal is left behind, and
that is the case the relocation harness actually suffered. What it cannot catch
is a PAIRED edit restating copy and literal in one pipeline commit.

A manifest file sitting beside the copy would have exactly the same limit. THE
AUTHORITY IS NOT THE FILE FORMAT. It is the independent comparison performed on
the cplx side, in a repository the pipeline edit cannot reach:

The manifest carries exactly three fields, named to remove an ambiguity round 4
found in the earlier wording. "Blob SHA-256" could be read as a Git blob object
id, which is a different hash over different bytes, so the terms are separated:

| Field | Meaning |
| --- | --- |
| `freeze_commit` | the cplx commit that froze the final harness |
| `harness_path` | the harness path within that commit |
| `file_sha256` | SHA-256 over the FILE BYTES at `freeze_commit:harness_path`, not a Git object id |

- the manifest is GENERATED from the FINAL canonical harness bytes and carries
  those three fields;
- the pipeline probe verifies its local harness copy against its manifest copy
  and FAILS the capture when they differ. This catches the unpaired edit;
- ACCEPTANCE independently verifies that the manifest's `freeze_commit`, `harness_path`
  and digest still identify the canonical harness in this repository, before the
  retained capture is accepted. This is the check a paired pipeline edit cannot
  restate, and it is the reason this option is preferred at all.

### Why the manifest names an EARLIER commit

The manifest cannot name the commit that contains it. A commit identity is
computed over its tree, the tree contains the manifest, so writing the id into
the manifest changes the tree and therefore the id. This is impossible rather
than merely awkward.

So the manifest names the earlier commit that froze the final harness, together
with `harness_path` and `file_sha256`, and acceptance proves that earlier commit
contains exactly those bytes at that path. That ordering is decision Q08/H2 and
it is why preparation is its own step.

## Verification harness for v0.27.0 python-wrapper-foreign-distro

`docs/v0.27.0/verify.wrapper-scope.sh`, new, following the shape the v0.27.0
relocation harness established: numbered steps, one case per assertion, controls
that must FAIL for the suite to mean anything, and a verdict line carrying the
case and failure counts.

It must run on any host, because the defect's cause needs a foreign
distribution but its OBSERVABLE does not. The harness plants a failing helper
rather than requiring one.

Every check the harness makes is measured from the wrapper's own run. Reading
the source and asserting what it says is not a check; it is a restatement.

## Numbered steps for v0.27.0 python-wrapper-foreign-distro

### Step 0 files involved

- `docs/v0.27.0/verify.wrapper-scope.sh` (new)
- `docs/v0.27.0/wrapper.pre-change.verification-only` (new)

### Step 0 goal

Capture what the wrapper does today, before it changes, so every later claim has
a before to compare against. TWO RUNS, not one: the clean first call, and a run
with a path-selective failing `readlink`. The second is the one step 2 compares
against, and it can only be taken now, while the pre-change wrapper is still the
file on disk.

The baseline runs against a planted fixture tree rather than a real deployment,
because the surgery is destructive and a baseline that mutates the thing it
measures is worthless.

### Step 0 completion criteria

- the harness plants a fixture tree shaped like a fresh deployment: a
  `current/bin/python3` symlink onto the recording shell stub, and the wrapper
  and `setenv` beside it;
- RUN A, clean: a first call over that fixture is captured, recording the
  resulting tree shape and the wrapper's exit status;
- RUN B, planted: the same fixture, with the `readlink` shim delegating the
  line-12 bootstrap call and failing the line-30 site. The capture records THE
  MANGLING the pre-change wrapper produces, naming the resulting
  `current/bin/_bin` shape, and records the exact injected call from the shim
  log so a later step can prove which site was failed;
- the pre-change wrapper is retained as
  `docs/v0.27.0/wrapper.pre-change.verification-only` with its SHA-256 recorded
  in the capture, since step 4 needs those bytes on a host with no cplx history;
- a control proves the fixture is real: an unplanted fixture FAILS the suite, so
  a later green cannot come from a tree that was never built;
- a control proves RUN B is real: if the injected failure did not appear in the
  shim log at the intended site, the suite FAILS rather than recording a clean
  run as a baseline;
- the capture records the `setenv` digest, so a later step can assert it
  unchanged rather than assume it.

### Step 1 files involved

- `src/install/env/python/bin/python` (existing, to be updated)
- `docs/v0.27.0/verify.wrapper-scope.sh` (existing, to be updated)

### Step 1 goal

Implement decision D2: save and unset after the source, restore per interpreter
invocation.

### Step 1 completion criteria

- exactly ONE save site, immediately after line 18, and the value held in a
  variable rather than re-derived;
- exactly TWO restore sites, one per interpreter arm, using the per-command
  environment prefix form rather than an `export`;
- no `export LD_LIBRARY_PATH` anywhere in the wrapper after the change;
- MEASURED FROM THE RUN, not from the source: the shim call log shows every
  POST-SOURCE helper invocation observing NO `LD_LIBRARY_PATH`, and the
  interpreter stub records the saved value. The expected calls are asserted
  PRESENT first, so a helper that never ran cannot pass by absence;
- the line-12 bootstrap `readlink -f` is asserted separately: present in the log
  and delegated, with NO claim about the environment it inherited, since it runs
  before `setenv` and its caller may legitimately have exported the variable;
- an empty saved value reaches the interpreter as empty, not as unset, and the
  stub's record distinguishes the two;
- `setenv` is byte-identical to the digest step 0 recorded.

### Step 2 files involved

- `src/install/env/python/bin/python` (existing, to be updated)
- `docs/v0.27.0/verify.wrapper-scope.sh` (existing, to be updated)

### Step 2 goal

Make the wrapper fail closed on an unusable helper result, at all three
`readlink` sites the design names, through the checked-call contract above.

### Step 2 completion criteria

- an empty or failed `readlink` at any of the three sites stops the wrapper with
  a non-zero exit and a message naming the helper, the site and the path;
- THE TREE IS UNMODIFIED after that stop, asserted by comparing the tree before
  and after AND by asserting that no `mv`, `ln`, `cp` or `sed` line follows the
  injected `readlink` in the shim call log;
- the comparison is against STEP 0 RUN B, the recorded pre-change mangling, so
  the step 2 pass is a measured change rather than an assumption. The suite
  fails if that baseline artifact is absent, rather than skipping the
  comparison;
- each of the three sites is injected separately, and the harness asserts the
  recorded injected call matches the intended site;
- a legitimate run is still accepted: the same suite must PASS the unplanted,
  working case, or a wrapper that refuses everything would satisfy every failure
  control.

### Step 3 files involved

- `docs/v0.27.0/verify.wrapper-scope.sh` (existing, to be updated)
- `docs/v0.27.0/verify.wrapper.rhel.txt` (new, retained evidence)

### Step 3 goal

Prove no regression on RHEL, which is the only host where that half of the
umbrella's acceptance can be checked.

### Step 3 completion criteria

- a first call over a freshly deployed tree on the RHEL target answers the
  toolchain version through the wrapper, using the REAL archive interpreter and
  not the stub;
- a second call answers through the existing symlinks without repeating the
  surgery;
- `-m venv` creates and post-processes a virtualenv, so the third guarded read
  site at line 66 executes for real;
- the retained capture names the run identity, the target and its bash version,
  and cites that identity in its evidence rather than only in its header;
- every write lands under one throwaway prefix, `HOME` pinned to it, the live
  install's mtime unchanged before and after, and the prefix removed.

### Step 4 files involved

- `docs/v0.27.0/verify.wrapper-scope.sh` (existing, FROZEN by this step)
- `docs/v0.27.0/verify.wrapper-scope.manifest.txt` (new, this step's OUTPUT,
  written in a LATER commit than the freeze)

Landed by this step in the pipeline repository, by the cplx maintainer:
`tools/wrapper_scope_verify.verification-only.sh`,
`tools/wrapper_scope.manifest.verification-only.txt`, and the `wrapperScope()`
probe in `ci/Jenkinsfile.diagnostics`.

### Step 4 goal

Freeze the harness, publish its identity, carry both across the repository
boundary, and obtain one build capture. This step exists because step 5 cannot
both produce and consume the manifest, and because a manifest cannot name the
commit that contains it. Everything step 5 needs is an OUTPUT of this step.

### Step 4 completion criteria

- THE FREEZE: `verify.wrapper-scope.sh` is final and committed. Steps 0 to 3
  have passed against these bytes, and no later step edits them. A step 5 that
  had to change the harness would invalidate the identity this step published;
- THE MANIFEST, written in a commit AFTER the freeze commit, naming the freeze
  `freeze_commit`, `harness_path` and `file_sha256` over the file bytes at that
  path. It never names its own commit,
  which is impossible;
- the manifest is generated from the frozen bytes rather than hand-written, so
  the digest cannot disagree with the file it describes;
- the pipeline copies and the `wrapperScope()` probe land at the exact paths
  above, through the same flow that lands the other cplx probes there;
- ONE BUILD HAS RUN and produced `a.evidence/verify-wrapper-scope.debian.txt`.
  The probe fails the capture when its local harness copy does not match its
  manifest copy, which is the unpaired-edit gate;
- a control proves that gate is live: a deliberately mismatched copy must FAIL
  the probe. Without it the gate is asserted rather than demonstrated.

### Step 5 files involved

- `docs/v0.27.0/verify.wrapper-scope.sh` (existing, READ ONLY at this point)
- `docs/v0.27.0/verify.wrapper-scope.manifest.txt` (existing, step 4's output)
- `docs/v0.27.0/wrapper.pre-change.verification-only` (existing, the control)
- `docs/v0.27.0/verify.wrapper.debian.txt` (new, retained evidence)

### Step 5 goal

Prove the fix on Debian 12, the only distribution the defect exists on.
Everything before this step is mechanism, no-regression, or transport; this is
the acceptance. It consumes step 4's outputs and produces none of them.

### Step 5 completion criteria

- TWO FRESHLY EXTRACTED, ISOLATED TREES in the same run, one for the fixed
  wrapper and one for the control, so the mangled run cannot contaminate the
  passing one;
- the fixed tree: a first call answers the toolchain version, and the tree
  afterwards has `python3` a symlink to the wrapper, `python3.13_bin` the real
  interpreter, `python3_target` pointing at it, and NO path derived from an
  empty string;
- the control tree: the retained pre-change wrapper produces the mangling,
  `current/bin/_bin` appearing, on the same agent in the same run. Without this
  a pass cannot be told from a pass on a host where the defect never fires;
- THE CONTROL'S PROVENANCE IS CHECKED, NOT PRINTED. The capture names the cplx
  commit and path the retained wrapper came from and the expected `file_sha256`,
  the
  harness verifies that equality BEFORE the control runs, and the suite fails on
  a mismatch. That commit already existed before the copy was made, so it
  carries no self-reference problem;
- THE INDEPENDENT IDENTITY CHECK, performed here and not on the agent: the
  manifest's `freeze_commit`, `harness_path` and `file_sha256` are verified
  against the canonical harness in this repository before the capture is
  accepted as evidence. This is the half a paired pipeline edit cannot restate,
  and it is why the manifest is worth having;
- THIS STEP DOES NOT MODIFY THE HARNESS. A change here would break the identity
  step 4 published, and the suite treats a harness whose digest no longer
  matches the manifest as a failure rather than as a new baseline;
- the capture names the run identity, the agent image, its glibc version and the
  commit, and cites that identity in its evidence rather than only in its
  header;
- every write lands under the build's own prefix, and the extracted archive the
  later pipeline stages consume is left unmodified.

### Step 5 what remains OWED after it

ONE thing. The pipeline landing is NOT here: it is step 4's work, and an
obligation met before a step can run is not one that survives it.

1. The same first call over the archive umbrella item 7 REBUILDS. Step 5 runs
   against the archive as published today, which is the right target for a
   wrapper fix, and item 7's matrix re-runs it after the rebuild because a
   rebuilt archive is a different artifact. That obligation has a named owner
   and does not hold this requirement's verdict open.

## Implementation decisions for v0.27.0 python-wrapper-foreign-distro

| # | Decision | Chosen |
| --- | --- | --- |
| P1 | Harness host | any, since the observable is reproducible without a foreign glibc |
| P2 | Baseline before change | required, and TWO runs: clean and planted, both over the pre-change wrapper |
| P3 | Fixture rather than a real tree | required for steps 0 to 2, since the surgery is destructive |
| P4 | Evidence for the scope rule | instrument the run through recording shims, never read the source |
| P5 | Shim coverage | asserted from the call log, never inferred from PATH setup |
| P6 | Bootstrap `readlink -f` | always delegated, never failed, since failing it stops the run before any guarded site |
| P7 | Control provenance | bound to a named commit and path with a verified `file_sha256`, not a printed digest |
| P8 | Guard form | one shared helper, with explicit failure propagation at every caller |
| P9 | Scope oracle | the fourteen POST-SOURCE helpers only. The line-12 bootstrap is logged and delegated but carries no environment claim |
| P10 | Canonical identity transport | a generated manifest, whose authority is the INDEPENDENT cplx-side comparison at acceptance, not the file format. A pipeline-local expected value catches an unpaired edit but cannot survive a paired restatement |
| P11 | Ordering | freeze and commit the harness, THEN generate the manifest in a later commit naming that earlier one, THEN land the handoff and obtain a build, THEN accept. A manifest cannot name the commit that contains it |

## Line budget

`src/install/env/python/bin/python` is 91 lines. The change adds a save, an
unset, two restore prefixes, one shared guard helper and three checked calls,
and is expected to land under 115 lines.

The budget is a REVIEW TRIGGER, not a gate. A larger result means the guards
were written per site rather than shared, which is the failure the shared helper
exists to prevent, and it should be reviewed before it lands rather than
silently split.

## Open questions for the v0.27.0 python-wrapper-foreign-distro implementation plan

Q01 to Q06 were selected in round 1 and their decisions are now written into the
plan body. Their descriptions below RECORD WHAT WAS APPLIED rather than restate
the gap that prompted them, and their option history is preserved so a later
reader can see what was weighed. Q07 was added in round 3, on how canonical
identity crosses the repository boundary. Q08 is new in round 4, on where the
freeze, manifest, handoff and acceptance boundaries sit, because Q07's answer
introduced an ordering the plan had not settled.

### Q01: which step captures the pre-change mangled baseline

Question description: step 2 compares its fail-closed result against the
mangling the pre-change wrapper produces. The question was which step records
that mangling, given that step 1 rewrites the wrapper before step 2 runs.

APPLIED: option A1. Step 0 now runs the unmodified wrapper twice, RUN A clean
and RUN B with a path-selective failing `readlink`, and step 2 consumes RUN B by
name and FAILS when it is absent rather than skipping the comparison.

#### BBQ for Q01

You are replacing a lock because you claim the old one can be slipped with a
credit card. The new lock holds, so you write "the old one failed, this one does
not". Except nobody ever filmed the old lock being slipped, and you already
threw it in the skip. Filming it before the swap is the whole fix.

In this picture: the old lock is the wrapper before step 1, slipping it with the
card is the planted `readlink` shim, the film is step 0's RUN B, and the skip is
step 1 overwriting the wrapper.

#### Options for Q01

- Option A1, SELECTED: step 0 captures BOTH runs over the unmodified wrapper.
  - pro: the mangled baseline is recorded while the pre-change wrapper is still
    the file on disk, which is the only moment it can be recorded honestly.
  - pro: step 2 then compares two real captures rather than one capture and one
    belief.
  - con: step 0 grows, and part of what it captures is a failure mode it does
    not yet explain.
- Option A2: let step 2 plant the failure against a retained pre-change copy.
  - pro: step 2 becomes self-contained.
  - con: it makes step 2 depend on a copy whose provenance is unchecked at that
    point, which is the weakness Q02 had to close for Debian acceptance.
- Option A3: drop the comparison and assert only the post-fix behaviour.
  - pro: simplest.
  - con: it removes the only evidence that the change did anything, which is the
    same shape as a control that cannot fail.

#### Recommended option for Q01

Option A1, applied. Note that A1 and B2 are not in tension: A1 governs WHERE the
local baseline is taken, and B2 separately retains a pre-change copy because the
Debian agent has no cplx history. Round 1 argued A1 partly on keeping a single
wrapper copy; that rationale is withdrawn, since B2 deliberately adds one. A1
stands on the timing argument alone, which is sufficient.

#### Answer to Q01: option A1 (with reason why it must be accepted as the answer)

Option A1: accept it because the pre-change wrapper exists on disk exactly once
in this plan's timeline, during step 0. A baseline not taken then cannot be
taken later from the file under test, and a comparison against a capture nobody
took is not a comparison.

### Q02: how the reverted-fix control runs on the Debian agent

Question description: Debian acceptance requires the reverted-fix control in
the same run as the passing call, on an agent that builds one commit and has no
cplx history.
The question was how the control obtains pre-change bytes it can be trusted to
be.

APPLIED: option B2, strengthened. Step 5 runs TWO freshly extracted isolated
trees, and the retained control is bound to a named cplx commit and path with an
expected SHA-256 that is VERIFIED BEFORE the control runs, failing the suite on
mismatch.

#### BBQ for Q02

Two identical cars, one with the recalled brake part and one with the fixed part,
down the same hill on the same afternoon. That is a test. The recalled part is no
longer made, so you keep one deliberately, and you check the part number before
you fit it rather than trusting the label on the box.

In this picture: the hill is the first call on the Debian agent, the recalled
part is the pre-change wrapper, and checking the part number is the verified
commit, path and file digest.

#### Options for Q02

- Option B1: reconstruct the pre-change wrapper by undoing the fix.
  - pro: no second file to keep in sync.
  - con: a reconstruction can fail because the reconstruction is wrong, which is
    indistinguishable from the defect it should demonstrate.
- Option B2, SELECTED: retain the pre-change wrapper, bound to a named commit and
  path, with a verified expected `file_sha256`.
  - pro: the control runs against bytes proven to be the historical wrapper.
  - pro: the verification is a GATE, not a print. A digest merely printed beside
    the copy proves a file was read, not that it is the right file, and cannot
    fail the run.
  - con: one more retained file, and its identity has to be re-verified whenever
    the pre-change commit is restated.
- Option B3: check out the parent commit inside the build.
  - pro: exact provenance by construction.
  - con: the agent's checkout is the pipeline repository; cplx history is not
    available there.

#### Recommended option for Q02

Option B2, applied with the equality treated as a fail-closed gate. Round 1's
wording relied on printing the copy's digest into the capture; that is evidence
of what ran and not evidence that the right thing ran, and it is corrected here.

#### Answer to Q02: option B2 (with reason why it must be accepted as the answer)

Option B2: accept it because the control must fail only for the right reason.
Bytes verified against a named commit and path before use fail exactly when the
pre-change wrapper fails, and the pre-run check turns a stale copy into a red
run rather than a quiet one.

### Q03: how the wrapper harness reaches the Debian agent

Question description: Debian acceptance runs on an agent that builds the
pipeline repository and holds no cplx credentials, so the harness has to travel.
The
question was which transport this requirement can actually execute.

APPLIED: option C1. The pipeline side carries a verification-only copy and a
probe, at the exact paths the plan body now names, landed by the named handoff
owner. C1 IS NOT EXECUTABLE BY THIS REPOSITORY ALONE, and the plan says so: the
pipeline landing is STEP 4 of the plan, performed before the acceptance step
rather than owed after it.
How the canonical identity crosses the boundary is Q07, which C1 alone did not
settle.

#### BBQ for Q03

The recipe lives in your kitchen, the oven in someone else's. You post a copy.
That works until you change the recipe and forget to post again. Writing the
version on the tin helps only if the other kitchen can check that version against
your kitchen, rather than against the note you posted beside the copy.

In this picture: the recipe is the canonical harness, the other kitchen is the
Debian agent, the posted copy is the verification-only file, and the checkable
version is Q07's manifest.

#### Options for Q03

- Option C1, SELECTED: a verification-only copy and probe on the pipeline side.
  - pro: proven on this exact agent by the relocation probes, needs no new
    plumbing and no new credentials.
  - con: two copies of one file. The relocation harness drifted from its cplx
    source exactly this way, which is why the equality gate of Q07 is required
    rather than optional.
- Option C2: have the pipeline fetch the harness from cplx at build time.
  - pro: one copy, no drift possible.
  - con: the agent has no cplx credentials, and granting them is outside this
    requirement.
- Option C3: fold the wrapper checks into the relocation capture script.
  - pro: no new file crosses the boundary.
  - con: it couples two unrelated requirements and edits a merged artifact
    belonging to another requirement.

#### Recommended option for Q03

Option C1, applied, with its boundary stated rather than implied. Round 1
described C1 as "the only option this requirement can execute on its own", which
was wrong: the transport is executable without new credentials, but the LANDING
is a change in another repository and therefore a prerequisite with a named
owner.

#### Answer to Q03: option C1 (with reason why it must be accepted as the answer)

Option C1: accept it because C2 needs credentials nobody is granting here and C3
edits another requirement's artifact. C1 costs a copy, and Q07 is what stops that
copy from being trusted on its own.

### Q04: how the scope rule is measured from the wrapper's own run

Question description: step 1 must show the scope rule from the run rather than
from the source. The question was which instrument records it.

APPLIED: option D1. Recording shims on `PATH` write a call log carrying each
helper's argument vector and inherited `LD_LIBRARY_PATH`, and the harness
asserts the expected calls are PRESENT before concluding anything from absence.

TWO CORRECTIONS TO THIS QUESTION'S OWN PREMISE, both re-read from the source:
every helper is unqualified and PATH-resolved, so the round-1 claim that some are
called by absolute path was wrong; and the scope oracle covers the FOURTEEN
POST-SOURCE helpers only. Line 12's bootstrap `readlink -f` runs before `setenv`
is sourced, so it is logged and delegated but its inherited environment is
outside the claim, exactly as the design states.

#### BBQ for Q04

You want to know whether the driver switched the engine off outside each house.
Ask the driver, read the policy, or put a logger on the engine. Only the logger
survives the driver being wrong about their own habits. And the depot start-up
before the round began is not one of the houses.

In this picture: the driver is the wrapper, the policy is its source text, the
houses are the fourteen post-source helper calls, the logger is the shim call
log, and the depot start-up is line 12.

#### Options for Q04

- Option D1, SELECTED: recording shims on PATH that log and delegate.
  - pro: records what each helper process actually inherited, which is the claim.
  - pro: the same shim mechanism serves step 2's failing-helper control.
  - con: the bootstrap `readlink -f` is PATH-resolved too and runs before any
    guarded site, so the shim must delegate it and inject failure by selected
    path rather than failing indiscriminately.
- Option D2: probe lines added to a copy of the wrapper.
  - pro: trivial to write.
  - con: it measures a modified wrapper, which is a modified source, and the
    plan's own rule rejects a source reading as a check.
- Option D3: `strace -e trace=execve -v`.
  - pro: measures the shipped wrapper unmodified.
  - con: needs strace on an image already known to lack rsync and procps.

#### Recommended option for Q04

Option D1, applied, with the oracle scoped to post-source helpers. Requiring the
line-12 call to observe an unset environment would fail a legitimate run whose
CALLER exported `LD_LIBRARY_PATH`, since that call precedes anything this
requirement controls.

#### Answer to Q04: option D1 (with reason why it must be accepted as the answer)

Option D1: accept it because it measures the shipped wrapper with a tool the
agent is known to have, and because the assertion discipline is what makes it
sound: expected calls present first, absence concluded second.

### Q05: what stands in for the interpreter in the fixture

Question description: steps 3 and 4 exercise `-m venv`, which a stub cannot do,
while steps 0 to 2 must stay runnable on any host. The question was whether one
fixture serves both.

APPLIED: option E1. The plan's fixture contract binds steps 0 to 2 to a recording
shell stub and steps 3 and 4 to the real archive interpreter, so the third
guarded read site executes for real.

#### BBQ for Q05

A crash-test dummy is right for measuring where the seatbelt bites and useless
for measuring whether the passenger can drive home. Using the dummy throughout is
cheap and answers half the questions; noticing which half is the job.

In this picture: the dummy is the stub, the seatbelt measurement is the scope
rule and the guards, and driving home is `-m venv` and the version answer.

#### Options for Q05

- Option E1, SELECTED: stub for steps 0 to 2, real interpreter for steps 3 and 4.
  - pro: the portable steps stay runnable anywhere, which is decision P1.
  - pro: the acceptance steps use the real thing, where realism is the point.
  - con: two fixture shapes to build and keep straight.
- Option E2: the real interpreter everywhere.
  - pro: one fixture.
  - con: it breaks P1, since steps 0 to 2 would need an extracted archive.
- Option E3: a stub everywhere.
  - pro: fully portable.
  - con: no venv is ever created, so the third guarded read site never executes,
    and that site is what decision W4 argued about.

#### Recommended option for Q05

Option E1, applied. The two shapes follow the split the target matrix already
committed to between what any host can prove and what only the target can.

#### Answer to Q05: option E1 (with reason why it must be accepted as the answer)

Option E1: accept it because collapsing the two shapes costs either portability
or coverage of the venv branch, and the venv branch holds one of the three
guards.

### Q06: where the three guards live, against the line budget

Question description: decision W4 stops at all three read sites, each naming the
helper and path. The question was the shared form, and what happens if it
overflows the 115-line budget.

APPLIED: option F1, with a checked-call contract the round-1 wording lacked. The
plan now specifies `guarded_readlink SITE PATH`, the caller form
`value=$(guarded_readlink ...) || exit`, and a harness assertion that no
mutating helper follows an injected failure in the call log.

#### BBQ for Q06

Three doors, each needing the same sign. One stencil beats painting it three
times. But a sign that falls off the door as you close it has not locked
anything, and that is the part the first draft missed.

In this picture: the doors are the three `readlink` sites, the stencil is the
shared helper, and the sign falling off is an `exit` that terminates only the
subshell created by command substitution.

#### Options for Q06

- Option F1, SELECTED: one shared helper, with an explicit checked-call contract
  at every caller.
  - pro: one message format, so the three cannot drift apart.
  - pro: smallest line cost, which keeps the budget credible.
  - con: a helper called through command substitution runs in a SUBSHELL, so its
    `exit` does not stop the wrapper. Failure must be propagated explicitly by
    every caller, and the harness must assert that no mutation followed.
- Option F2: an inline guard at each site.
  - pro: each site reads in place.
  - con: three copies of a message format, drifting with the budget as the only
    late and indirect signal.
- Option F3: shared helper plus a rule that overflow splits the file.
  - pro: names the overflow response in advance.
  - con: splitting a 91-line wrapper is a structural change this requirement did
    not set out to make.

#### Recommended option for Q06

Option F1, applied with the propagation contract. Without it F1 produces a guard
that passes its own review while leaving the original failure mode intact, which
is the defect this requirement exists to remove, reproduced one level down.

#### Answer to Q06: option F1 (with reason why it must be accepted as the answer)

Option F1: accept it because the shared form is what the budget note already
asks for, and because the contract is what makes the guard reach the wrapper.
The harness assertion, not the presence of the word `exit`, is what proves it.

### Q07: how the canonical harness identity crosses the repository boundary

Question description: Q03 settled that a verification-only copy travels to the
Debian agent, and acceptance requires the copy to match the canonical cplx harness by
SHA-256. But the agent has no cplx access, so it cannot obtain the authoritative
digest by itself. An expected digest edited beside the copy is not rooted in the
canonical file: both can be changed in the same commit and the gate still passes.
The question is how an authoritative identity reaches a credential-less agent so
the equality gate can actually fail.

#### BBQ for Q07

A courier carries a parcel and, in the same bag, a note saying what the parcel
should weigh. If the sender writes both, a swapped parcel with a rewritten note
passes every check at the door. The fix is not a better note; it is a weight the
recipient can check against something the sender cannot quietly restate after the
fact, and that the depot re-checks against the original before accepting the
delivery.

In this picture: the parcel is the pipeline harness copy, the note is the expected
digest, the courier is the pipeline commit, and the depot re-check is the
acceptance step matching the manifest back to the canonical cplx file.

#### Options for Q07

- Option G1: an expected digest literal maintained beside the pipeline copy.
  - pro: simplest, one line, no new artifact.
  - pro: it DOES catch the accidental case, which is the one actually observed:
    when only the copy is edited and the literal is left alone, the gate goes
    red. Round 3 of this review corrected an earlier overstatement here that
    claimed G1 could never fail.
  - con: both sides live in the same repository, so a PAIRED edit restates the
    copy and its literal together and the gate passes. It defends against
    forgetting, not against a coherent change made in one commit.
- Option G2, RECOMMENDED: a committed handoff manifest generated from the final
  cplx harness, carrying the cplx commit and the SHA-256; the pipeline probe
  verifies its local copy against the manifest, and the acceptance step
  independently verifies that the manifest's commit and digest still identify the
  canonical cplx harness before the retained capture is accepted.
  - pro: both sides of the equality gate become authoritative: the agent checks
    copy against manifest, and acceptance checks manifest against canon.
  - pro: it needs no credentials on the agent, since the manifest travels as a
    committed file like the copy does.
  - pro: a copy edited without regenerating the manifest fails on the agent; a
    manifest regenerated without the canonical file matching fails at acceptance.
  - con: one more artifact, and a generation step that must run against the FINAL
    harness bytes rather than an intermediate.
- Option G3: print both digests and leave the comparison to a human reader.
  - pro: no gate to maintain.
  - con: it is not a check. The relocation harness drift went unnoticed for weeks
    with both bodies available to read, which is the evidence against this option
    rather than an argument about diligence.

#### Recommended option for Q07

Option G2, and the reason must be stated precisely rather than as a slogan. G1 is
not unfailable: it catches copy-only drift, which is the accidental case the
relocation harness actually suffered. Its limit is that a paired edit in one
pipeline commit restates both sides at once.

WHAT MAKES G2 STRONGER IS NOT THE MANIFEST FILE. A manifest sitting beside the
copy would have exactly G1's property. The authority comes from the INDEPENDENT
CPLX-SIDE COMPARISON at acceptance: the manifest's `freeze_commit`,
`harness_path` and `file_sha256`
are checked against the canonical harness in a repository the pipeline edit
cannot reach. A paired pipeline edit still fails there, which is the case G1
cannot cover. G3 is not a gate at all, since it defers the comparison to a reader.

#### Answer to Q07: option G2 (with reason why it must be accepted as the answer)

Option G2: accept it because the acceptance-side check is the only part of any of
these options that a pipeline-side edit cannot restate. The manifest is the
vehicle for that check rather than the source of its authority, and describing it
the other way round would credit a file format with a property it does not have.

### Q08: where the freeze, manifest, handoff and acceptance boundaries sit

Question description: Q07 settled that a manifest carries the canonical identity
and that acceptance checks it back against cplx. That leaves an ordering problem
Q07 did not answer, and round 3 found two cycles in the round-2 wording. First,
the step that GENERATES the manifest also required the manifest to be already
copied, landed and used by a build before it could start, so the step needed one
of its own outputs. Second, the manifest names a cplx commit, and a Git commit
identity is computed over the tree that contains the manifest, so a manifest
cannot name the commit it sits in. The question is where the boundaries fall in
the step and commit sequence.

#### BBQ for Q08

You want to ship a sealed sample with a certificate saying what the sample is.
The certificate cannot be printed with the seal number of the box it is sealed
inside, because sealing the box with the certificate in it changes the number.
So you seal the sample first, note that number, then print the certificate
referring to it, then ship both. Trying to do it in one motion is not difficult,
it is impossible.

In this picture: the sample is the final harness, the seal number is the cplx
commit that froze it, the certificate is the manifest, and shipping is the
pipeline handoff and its build.

#### Options for Q08

- Option H1: drop the commit field and verify only the harness SHA against
  whatever the current cplx checkout holds.
  - pro: no ordering constraint at all, and no self-reference to avoid.
  - con: it loses durable provenance. "Matches the harness as it is right now"
    is a moving claim, and a capture retained months later can no longer say
    which bytes it was accepted against.
- Option H2, RECOMMENDED: four ordered boundaries. Freeze and commit the final
  harness; generate the manifest in a LATER cplx commit naming that earlier
  commit, `harness_path` and `file_sha256`; land the pipeline copies and probe,
  obtain a
  build capture; then perform Debian acceptance in the following step.
  - pro: every prerequisite exists before its consumer starts, so no step needs
    its own output.
  - pro: the commit the manifest names is already closed, so there is no
    self-reference.
  - pro: it makes the retained capture durably checkable, since the named commit
    and path do not move.
  - con: one more step and one more commit boundary to respect, and the harness
    must genuinely be final at the freeze rather than nearly final.
- Option H3: generate a manifest naming the commit that contains it.
  - pro: one commit, conceptually tidy.
  - con: IMPOSSIBLE, not merely awkward. A commit id is computed over its tree,
    the tree contains the manifest, so writing the id into the manifest changes
    the tree and therefore the id. No amount of care makes this converge.

#### Recommended option for Q08

Option H2. H3 is ruled out by construction rather than by preference, and H1
trades away the property that makes the manifest worth having: a capture retained
as evidence must remain checkable against a fixed point, and "the current
checkout" is not one. H2 costs an extra step boundary, which is the honest price
of an artifact that refers to another artifact by identity.

The extra step also removes the circularity the reviewer found: preparation and
handoff become their own step whose OUTPUTS are the manifest, the pipeline copies
and the build capture, and Debian acceptance becomes the following step whose
INPUTS are exactly those, so nothing consumes what it produces.

#### Answer to Q08: option H2 (with reason why it must be accepted as the answer)

Option H2: accept it because the alternative orderings are impossible or
lossy. H3 cannot be built. H1 can be built but produces evidence that decays,
since it is checked against a target that keeps moving. H2 is the only ordering
where each artifact exists before the thing that consumes it, and where the
identity a retained capture cites still means the same thing when someone reads
it later.
