# Implementation plan v0.27.0 -- Keep the python wrapper working on a foreign distribution

Reference design: [design.v0.27.0.python-wrapper-foreign-distro.md](design.v0.27.0.python-wrapper-foreign-distro.md)
Reference issue: [issue.v0.27.0.python-wrapper-foreign-distro.md](issue.v0.27.0.python-wrapper-foreign-distro.md)

---

## Plan goal for v0.27.0 python-wrapper-foreign-distro

Change one 91-line bash file so that the shipped search path serves the
interpreter and nothing else the wrapper runs, and so that an unusable helper
result stops the wrapper instead of feeding its surgery.

The plan is deliberately small. The design settles the mechanism; there is no
new module, no new tool, and no change outside two files, one of which is only
read.

## Scope anchors for the v0.27.0 python-wrapper-foreign-distro plan

- `src/install/env/python/bin/python`: the only file this plan modifies.
- `src/install/env/python/bin/setenv`: read, asserted byte-identical, never
  written.
- `docs/v0.27.0/verify.wrapper-scope.sh`: new, the verification harness for
  this item.

Nothing in this plan touches the installer, the relocation pass, the archive,
or the CI pipeline.

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

## Executable target matrix

| Step | What it proves | Host |
| --- | --- | --- |
| 0 | baseline: the wrapper's current behavior, captured before any change | any |
| 1 | the scope rule: helpers unset, interpreter set, measured from the run | any |
| 2 | failing closed: a planted helper failure stops the wrapper, tree unmodified | any |
| 3 | acceptance on RHEL: first call, second call, `-m venv`, no regression | RHEL target |
| 4 | acceptance on Debian: the first call the defect actually breaks | Debian CI agent |

STEP 4 IS THE ONE THAT MATTERS, and it is a step here rather than an obligation
handed elsewhere. The earlier draft of this plan deferred the Debian first call
to umbrella item 7, on the correct reading that this requirement had no Debian
environment in hand. That is no longer true: the CI agent is Debian 12, it is
reachable again, and item 7's matrix runs after a rebuild this requirement does
not need.

So the split is now the honest one. Steps 0 to 2 prove the mechanism on any
host. Step 3 proves nothing regressed where the defect is invisible. Step 4
proves the fix on the distribution the defect exists on, which is the only run
that can distinguish a working fix from a plausible one.

What remains owed to item 7 is narrower and unchanged in kind: the same first
call over the REBUILT archive, which is item 7's artifact and not this one's.
Step 4 runs against the archive as published today.

## Numbered steps for v0.27.0 python-wrapper-foreign-distro

### Step 0 files involved

- `docs/v0.27.0/verify.wrapper-scope.sh` (new)

### Step 0 goal

Capture what the wrapper does today, before it changes, so every later claim
has a before to compare against. The baseline runs against a planted fixture
tree rather than a real deployment, because the surgery is destructive and a
baseline that mutates the thing it measures is worthless.

### Step 0 completion criteria

- the harness plants a fixture tree shaped like a fresh deployment: a
  `current/bin/python3` symlink onto a stub interpreter, and the wrapper and
  `setenv` beside it;
- a first call over that fixture is captured: the resulting tree shape and the
  wrapper's exit status;
- a control proves the fixture is real: an unplanted fixture FAILS the suite,
  so a later green cannot come from a tree that was never built;
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
- MEASURED FROM THE RUN, not from the source: a helper invocation observes no
  `LD_LIBRARY_PATH`, and the interpreter invocation observes the saved value.
  The harness instruments the wrapper's own environment at those two points;
- an empty saved value reaches the interpreter as empty, not as unset;
- `setenv` is byte-identical to the digest step 0 recorded.

### Step 2 files involved

- `src/install/env/python/bin/python` (existing, to be updated)
- `docs/v0.27.0/verify.wrapper-scope.sh` (existing, to be updated)

### Step 2 goal

Make the wrapper fail closed on an unusable helper result, at all three
`readlink` sites the design names.

### Step 2 completion criteria

- an empty or failed `readlink` at any of the three sites stops the wrapper
  with a non-zero exit and a message naming the helper and the path;
- THE TREE IS UNMODIFIED after that stop: no `mv`, no `ln`, no `cp`, no `sed`.
  Asserted by comparing the tree before and after, not by reading the code;
- the control that proves it: a planted `readlink` shim that exits non-zero and
  prints nothing. Without the fix this control makes the wrapper mangle the
  tree, and the harness asserts the mangling in the step 0 baseline, so the
  step 2 pass is a measured change rather than an assumption;
- a legitimate run is still accepted: the same suite must PASS the unplanted,
  working case, or a wrapper that refuses everything would satisfy every
  failure control.

### Step 3 files involved

- `docs/v0.27.0/verify.wrapper-scope.sh` (existing, to be updated)
- `docs/v0.27.0/verify.wrapper.rhel.txt` (new, retained evidence)

### Step 3 goal

Prove no regression on RHEL, which is the only host where that half of the
umbrella's acceptance can be checked.

### Step 3 completion criteria

- a first call over a freshly deployed tree on the RHEL target answers the
  toolchain version through the wrapper;
- a second call answers through the existing symlinks without repeating the
  surgery;
- `-m venv` creates and post-processes a virtualenv;
- the retained capture names the run identity, the target and its bash version,
  and cites that identity in its evidence rather than only in its header;
- every write lands under one throwaway prefix, `HOME` pinned to it, the live
  install's mtime unchanged before and after, and the prefix removed.

### Step 4 files involved

- `docs/v0.27.0/verify.wrapper-scope.sh` (existing, to be updated)
- `docs/v0.27.0/verify.wrapper.debian.txt` (new, retained evidence)
- the CI probe that runs it, in the pipeline repository, not here

### Step 4 goal

Prove the fix on Debian 12, which is the only distribution the defect exists
on. Everything before this step is either mechanism or no-regression; this is
the acceptance.

### Step 4 completion criteria

- a first call over a freshly extracted tree on the Debian CI agent answers the
  toolchain version through the wrapper;
- the tree afterwards is in the expected shape: `python3` a symlink to the
  wrapper, `python3.13_bin` the real interpreter, `python3_target` pointing at
  it, and NO path in the tree derived from an empty string;
- the pre-change control is recorded in the same run: with the fix reverted, the
  same first call on the same agent MANGLES the tree, producing the
  `current/bin/_bin` rename the issue describes. Without that control a green is
  indistinguishable from a green on a host where the defect never fired, which
  is precisely what a RHEL run gives and why a RHEL run cannot substitute;
- the capture names the run identity, the agent image, its glibc version and the
  commit, and cites that identity in its evidence rather than only in its
  header;
- every write lands under the build's own prefix, and the extracted archive the
  later pipeline stages consume is left unmodified.

### Step 4 what remains OWED after it

The same first call over the archive umbrella item 7 REBUILDS. Step 4 runs
against the archive as published today, which is the right target for a wrapper
fix, and item 7's matrix re-runs it after the rebuild because a rebuilt archive
is a different artifact. That is a narrower obligation than the one this plan
started with, it has a named owner, and it does not hold this requirement's
verdict open.

## Implementation decisions for v0.27.0 python-wrapper-foreign-distro

| # | Decision | Chosen |
| --- | --- | --- |
| P1 | Harness host | any, since the observable is reproducible without a foreign glibc |
| P2 | Baseline before change | required, so step 2's pass is a measured change |
| P3 | Fixture rather than a real tree | required, since the surgery is destructive |
| P4 | Evidence for the scope rule | instrument the run, never read the source |

## Line budget

`src/install/env/python/bin/python` is 91 lines. The change adds a save, an
unset, two restore prefixes and three guards, and is expected to land under 115
lines. A larger result means the guards were written per site rather than
shared, and should be reviewed before it lands.
