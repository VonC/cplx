# Implementation plan v0.27.0 -- Keep the python wrapper working on a foreign distribution

Reference design: [design.v0.27.0.python-wrapper-foreign-distro.md](design.v0.27.0.python-wrapper-foreign-distro.md)
Reference issue: [issue.v0.27.0.python-wrapper-foreign-distro.md](issue.v0.27.0.python-wrapper-foreign-distro.md)
Reference environments: [reference.environments.md](reference.environments.md)

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
| 0 | baseline: the current behavior, clean AND failing, before any change | any POSIX |
| 1 | the scope rule: helpers unset, interpreter set, measured from the run | any POSIX |
| 2 | failing closed: a planted helper failure stops the wrapper, tree unmodified | any POSIX |
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

It must run on any POSIX host, because the defect's cause needs a foreign
distribution but its OBSERVABLE does not. The harness plants a failing helper
rather than requiring one.

POSIX IS THE REAL BOUNDARY, and the original wording of "any host" was wrong
rather than merely loose. What steps 0 to 2 measure is symlink surgery, so a
host that cannot create a symlink cannot reproduce it at all. The harness
measures that with a probe before it plants anything, and a host that fails the
probe either reads a retained measurement or exits 4. The exact commands, which
are the plan additions to the resolved validation set and are green on both a
POSIX host and a Windows one, are

```text
bash docs/v0.27.0/verify.wrapper-scope.sh --step 0 \
     --wrapper docs/v0.27.0/wrapper.pre-change.verification-only \
     --capture docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt

bash docs/v0.27.0/verify.wrapper-scope.sh --step 1 \
     --capture docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt

bash docs/v0.27.0/verify.wrapper-scope.sh --step 2 \
     --capture docs/v0.27.0/verify.wrapper-scope.step2.rhel.txt
```

STEP 0'S COMMAND NAMES THE RETAINED WRAPPER, and from step 1 onward it must.
Step 0 describes the PRE-CHANGE wrapper, step 1 rewrites the live one, and the
subject binding then refuses step 0 against `src/install/env/python/bin/python`
on purpose, because a capture describing `88c4e0d2` says nothing about the file
that replaced it. That refusal is the binding working rather than a defect to
route around, and it was observed before this paragraph was written.

EVERY HARNESS EDIT INVALIDATES EVERY RETAINED CAPTURE, which is the price of
binding a capture to its instrument. Adding the step 1 suite changed the harness
digest, so both captures were retaken; adding the step 2 suite changed it again,
so all three were. The cost is deliberate: the alternative is a capture that
outlives the code it described.

THE RETAINED MEASUREMENT IS NOT A WAY OF PASSING WITHOUT RUNNING, and its
authority takes FOUR digests rather than one. A capture answers two separate
questions, and an early revision of this section answered only the first:

- WHICH INSTRUMENT MEASURED. The capture records the SHA-256 of the harness bytes
  that produced it, and the reading host asserts that against the harness it was
  asked to run. Edit the harness and the two diverge and the capture must be
  retaken.
- WHAT IT MEASURED. The capture also records the SHA-256 of the wrapper, of
  `setenv`, and of the retained pre-change wrapper, and the reading host asserts
  each against the exact `--wrapper`, `--setenv` and `--retained` inputs it was
  given.

THE SECOND HALF WAS MISSING AND THE GAP WAS DEMONSTRATED, not theorised. Code
review round 2 pointed the substitution at a wrapper with the SAME COMMAND
VOCABULARY as the real one and a deliberately broken relink target. The shim
coverage case saw nothing wrong, the harness digest still matched, and the run
reported `OBJECTIVE MET` with zero failures. A capture bound only to its
instrument certifies a run over inputs nobody compared to the ones present.

Each of the four bindings carries a control that must FAIL: one mutating the
harness digest line, and three substituting a broken wrapper, a mismatched
`setenv` and a mismatched retained wrapper. The broken-wrapper control keeps the
command vocabulary identical on purpose, so it is exactly the file that passed
before this binding existed. This is the idiom the relocation harness already
uses for `--target-capability`, carried to the inputs as well as the tool.

Every check the harness makes about the wrapper's BEHAVIOUR is measured from the
wrapper's own run. Reading the source and asserting what it says is not a check;
it is a restatement. The one deliberate exception is the shim coverage case,
which asks which command names the FILE CONTAINS rather than what one run
reached, and a run-derived answer there would report the helpers that one path
exercised and call the rest absent.

## Numbered steps for v0.27.0 python-wrapper-foreign-distro

### Step 0 files involved

- `docs/v0.27.0/verify.wrapper-scope.sh` (new)
- `docs/v0.27.0/wrapper.pre-change.verification-only` (new)
- `docs/v0.27.0/verify.wrapper-scope.step0.rhel.txt` (new, the retained capture)

THE THIRD FILE WAS MISSING FROM THIS LIST, and step 2 could not have executed
without it. Step 2's completion criteria require the comparison to be "against
STEP 0 RUN B, the recorded pre-change mangling" and say "the suite fails if that
baseline artifact is absent". Four of step 0's own criteria below say "the
capture records" something. No step produced such an artifact, so the plan asked
step 2 to compare against a file nothing created. Added after code review round 1
of step 0 raised it, together with the writer's own reading of the same gap.

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
- `docs/v0.27.0/verify.wrapper-scope.step1.rhel.txt` (new, the retained capture)

The capture is named here for the reason step 0's is: a host that cannot create
a symlink reads it rather than running the suite, and a step whose evidence
exists only in a terminal has no evidence.

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
- `docs/v0.27.0/verify.wrapper-scope.step2.rhel.txt` (new, the retained capture)

The capture is named here for the reason step 0's and step 1's are, and it was
added after the step 2 code review found the omission: a host that cannot create
a symlink reads it rather than running the suite, and without it `--step 2`
exits 4 on the reviewing host and the step's evidence lives only in a terminal.

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

Eight questions were opened and settled across four review rounds. Each row
names the question, the decision, where it lives in this plan, and what was
rejected. The rationale, the pros and cons weighed, and the acceptance reason
for each answer are preserved in commit `a9f8351`, recorded immediately before
this table replaced them.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | Step 0 runs the unmodified wrapper TWICE, clean and with a path-selective failing `readlink`, and step 2 compares against RUN B by name | "Step 0 goal", "Step 0 completion criteria", "Step 2 completion criteria" | A2, planting the failure at step 2 against a retained copy whose provenance is unchecked at that point; A3, dropping the comparison, which removes the only evidence the change did anything |
| Q02 | The step 5 control is a retained pre-change wrapper bound to a named cplx commit and path with a verified `file_sha256`, run in its own extracted tree | "Step 5 completion criteria", decision P7 | B1, reconstructing the pre-change wrapper, whose failure is indistinguishable from the defect it should show; B3, checking out the parent commit on the agent, which holds no cplx history |
| Q03 | The harness travels to the Debian agent as a verification-only copy plus a `wrapperScope()` probe, at named paths, landed by the cplx maintainer | "The cross-repository handoff", "Step 4 files involved" | C2, fetching from cplx at build time, which needs credentials this requirement is not granting; C3, folding the checks into the relocation script, which couples two requirements and edits another's merged artifact |
| Q04 | Recording `PATH` shims log every helper call with its inherited environment, expected calls asserted PRESENT before absence is concluded, scoped to the fourteen POST-SOURCE helpers | "The recording shim contract", "Step 1 completion criteria", decisions P4, P5, P6, P9 | D2, probe lines in a wrapper copy, which measures a modified source; D3, `strace`, unavailable on an image already missing rsync and procps |
| Q05 | A recording shell stub for steps 0 to 2, the real archive interpreter for steps 3 and 5 | "The fixture contract", decisions P1, P3 | E2, the real interpreter everywhere, which costs portability; E3, a stub everywhere, which never creates a venv so the third guarded site never executes |
| Q06 | One shared `guarded_readlink SITE PATH`, non-zero on failed OR empty output, with explicit propagation at every caller and a harness assertion that no mutation follows an injected failure | "The checked-call contract for the guards", "Step 2 completion criteria", decision P8 | F2, an inline guard per site, whose drift the budget notices late and indirectly; F3, splitting the file, a structural change this requirement did not set out to make |
| Q07 | A generated identity manifest, whose authority is the INDEPENDENT cplx-side comparison at acceptance rather than the file format | "The identity manifest, and where its authority actually comes from", "Step 5 completion criteria", decision P10 | G1, a digest literal beside the pipeline copy, which catches an unpaired edit but not a paired restatement; G3, printing both digests for a reader, which defers the comparison instead of making it |
| Q08 | Four ordered boundaries: freeze and commit the harness, generate the manifest in a LATER commit naming that earlier one, land the handoff and obtain a build, then accept | "Why the manifest names an EARLIER commit", "Executable target matrix", "Step 4", "Step 5", decision P11 | H1, dropping the commit field and checking against the current checkout, which decays because the target keeps moving; H3, a manifest naming its own commit, which is impossible since a commit id is computed over the tree containing it |

### Decisions not arising from a question

These were settled while writing the plan, or follow directly from a question's
answer without having been asked separately.

| # | Decision | Chosen |
| --- | --- | --- |
| P1 | Harness host | any POSIX host, since the observable is reproducible without a foreign glibc but NOT without symlinks. CORRECTED after code review round 1 of step 0: the original wording said "any", the authoring and reviewing host is Windows, and the harness produced seven fixture failures there that read as findings about the wrapper and were findings about the host. A host that cannot create a symlink now fails a measured gate BEFORE anything is planted, and then either reads a retained measurement through `--capture` whose recorded digest must name the exact harness bytes it was asked to run, or exits 4 saying it could not answer. It never reports 0 on its own account |
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

### What the four rounds kept finding

Recorded because it shaped six of the eight answers and should outlive the
questions that produced them. Every round found the same defect one boundary
further out than the last: a comparison against a baseline nobody took (Q01), a
digest proving only that a file was read (Q02), a guard whose `exit` terminated
a subshell rather than the wrapper (Q06), an equality gate whose two halves
moved in the same commit (Q07), a gate introduced and never shown to fire
(step 4's mismatched-copy control), and a step consuming its own output beside
a manifest that could not name its own commit (Q08).

Each is a check that reports success without the thing it names having
happened, which is the defect class this umbrella exists to close. The plan
carries controls against all six rather than trusting that the last fix was the
final one.

## Line budget

`src/install/env/python/bin/python` is 91 lines. The change adds a save, an
unset, two restore prefixes, one shared guard helper and three checked calls,
and is expected to land under 115 lines.

The budget is a REVIEW TRIGGER, not a gate. A larger result means the guards
were written per site rather than shared, which is the failure the shared helper
exists to prevent, and it should be reviewed before it lands rather than
silently split.
