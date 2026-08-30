# v0.27.0 python-wrapper-foreign-distro implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.python-wrapper-foreign-distro.md](plan.v0.27.0.python-wrapper-foreign-distro.md),
four steps that scope the shipped search path to the interpreter and make the
wrapper fail closed on an unusable helper result. No step has started.

> Skeleton note: every per-step section other than `Goal` carries the literal
> placeholder `_(empty -- no check has taken place yet.)_.` until an
> implementation check fills it.

## What this validation owes, and what it does not

The umbrella's acceptance for this item names a first call answering on a
Debian 12 container. That check is already in umbrella item 7's validation
matrix, which runs on both distributions and names it.

It is recorded here as OWED with its owner, and it does NOT gate this
document's status. The defect is invisible on RHEL by construction, so no run
on the available hosts can substitute for it, and this validation will not
claim one. Item 2 of this umbrella spent nine review rounds discovering that a
criterion a requirement cannot discharge must not hold its verdict open; this
item states the boundary before the work rather than after.

## Step 0. Baseline over a planted fixture

### Analysis of Step 0 implementation state

_(empty -- no check has taken place yet.)_.

### Goal for Step 0

Capture what the wrapper does today, over a planted fixture rather than a real
deployment, so every later claim has a before to compare against.

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

Prove the no-regression half of the umbrella's acceptance on the only host
where it can be checked, and record the Debian first call as owed.

### What was implemented for Step 3

_(empty -- no check has taken place yet.)_.
