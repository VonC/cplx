# v0.27.0 python-wrapper-foreign-distro implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.python-wrapper-foreign-distro.md](plan.v0.27.0.python-wrapper-foreign-distro.md),
six steps that scope the shipped search path to the interpreter and make the
wrapper fail closed on an unusable helper result. No step has started.

> Skeleton note: every per-step section other than `Goal` carries the literal
> placeholder `_(empty -- no check has taken place yet.)_.` until an
> implementation check fills it.

Reference environments: [reference.environments.md](reference.environments.md)

## What this validation owes, and what it does not

The umbrella's acceptance for this item names a first call answering on a
Debian 12 container. That check is now STEP 5 of this plan rather than an
obligation handed elsewhere, because the CI agent is that Debian host and it is
reachable again.

WHAT IS A STEP, AND WHAT IS OWED, which are not the same thing:

- STEP 4, not an obligation: freezing the harness, generating the identity
  manifest in a later commit, landing the pipeline copies and probe, and
  obtaining one build capture. An earlier revision listed this as owed after the
  Debian step while that same step also produced the manifest, which was
  circular. It is now the step that comes first.
- OWED AFTER STEP 5: the same first call over the archive umbrella item 7
  REBUILDS, which is a different artifact from the one published today and is
  item 7's to check.

Neither gates steps 0 to 3. Item 2 of this umbrella spent nine review rounds
discovering that a criterion a requirement cannot discharge must not hold its
verdict open; this item states the boundary before the work rather than after,
and states it again here so a later reader does not have to reconstruct it.

## Step 0. Baseline over a planted fixture

### Analysis of Step 0 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 0

Capture what the wrapper does today over a planted fixture, in TWO runs: the
clean first call and a run with a path-selective failing `readlink`. The second
is the baseline step 2 compares against, and it can only be taken while the
pre-change wrapper is still the file on disk.

### What was implemented for Step 0

_(empty -- no check has taken place yet.)_.

## Step 1. Scope the search path to the interpreter

### Analysis of Step 1 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 1

Implement decision D2: one save and unset after the source, one restore per
interpreter invocation, measured from the run rather than read from the source.

### What was implemented for Step 1

_(empty -- no check has taken place yet.)_.

## Step 2. Fail closed on an unusable helper result

### Analysis of Step 2 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 2

Stop at all three `readlink` sites rather than deriving paths from an empty
value, with the tree provably unmodified after the stop.

### What was implemented for Step 2

_(empty -- no check has taken place yet.)_.

## Step 3. No regression on the RHEL target

### Analysis of Step 3 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 3

Prove the no-regression half of the umbrella's acceptance on the only host where
it can be checked. The Debian first call is no longer recorded as owed here: it
is step 5.

### What was implemented for Step 3

_(empty -- no check has taken place yet.)_.

## Step 4. Freeze, publish identity, land the handoff

### Analysis of Step 4 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 4

Freeze the harness, publish its identity, carry both across the repository
boundary, and obtain one build capture, so that step 5 consumes only artifacts
that already exist.

The completion conditions are named here rather than left to be recovered from
the plan prose:

- the harness is FINAL and committed, and steps 0 to 3 passed against those
  bytes. No later step edits it;
- the manifest is generated from the frozen bytes in a commit AFTER the freeze,
  naming `freeze_commit`, `harness_path` and `file_sha256` over the file bytes
  at that path. It never
  names its own commit, which is impossible;
- the pipeline harness copy, manifest copy and `wrapperScope()` probe land at
  the exact paths the plan names;
- one build has produced the capture, and a deliberately mismatched copy is
  shown to FAIL the probe, so the unpaired-edit gate is demonstrated rather than
  asserted.

### What was implemented for Step 4

_(empty -- no check has taken place yet.)_.

## Step 5. Acceptance on the Debian agent

### Analysis of Step 5 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 5

Prove the fix on Debian 12, the only distribution the defect exists on, with the
reverted-fix control in the same run so a pass cannot be confused with a pass on
a host where the defect never fires.

The completion conditions are named here rather than left to be recovered from
the plan prose, so an implementation check can read them directly:

- TWO freshly extracted isolated trees in one run, the fixed wrapper in one and
  the retained pre-change control in the other;
- the control bytes verified against their named cplx commit, path and
  expected `file_sha256` BEFORE the control runs, failing the suite on mismatch;
- THE INDEPENDENT IDENTITY CHECK, performed here rather than on the agent: the
  manifest's `freeze_commit`, `harness_path` and `file_sha256` verified against
  the canonical harness in this repository before the capture is accepted. This
  is the half a paired pipeline edit cannot restate;
- the harness is NOT modified by this step; a digest that no longer matches the
  manifest is a failure, not a new baseline.

### What was implemented for Step 5

_(empty -- no check has taken place yet.)_.
