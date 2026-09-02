# Resume note for `relocation-force-rpath`

Umbrella requirement 2 of `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`.
Written 2026-08-29 because this effort is PARKED on an external blocker and the
next person to touch it, including a later session of this assistant, needs to
know what is done, what is not, and what may not be re-litigated.

## Branch and state

| | |
| --- | --- |
| Branch | `relocation-force-rpath`, cut from `debian-agent-tools` |
| Position | 59 commits ahead of the umbrella, 0 behind, NOT merged |
| Umbrella branch | `debian-agent-tools`, which already contains requirement 1 |
| CI repository | the consuming project, branch `develop`, at `9a37a822` |
| Review exchange | `code/code/v0.27.0/relocation-force-rpath`, round 10, in progress, nothing published |

Requirement 1 (`rsync-cp-fallback`) is merged into the umbrella. This one is
not, and cannot be until its acceptance closes.

## What is done

Steps 0 through 5 are implemented, reviewed and committed. Step 6, the
acceptance over the deployed archive, is implemented and its evidence retained.
On the Debian agent, the last good run is build 123 at CI `aa48ff8a`: steps 0 to
4 `OBJECTIVE MET` at 0 failures, step 6 at 216 cases.

The production change is one exclusion rule beside the loader rule in
`src/setups/env/bin/install_pkg.sh`: the pass must never rewrite the patchelf
binary executing it, found by the step 6 acceptance on a real deployment and
confirmed on both distribution paths, 27 write failures before and 26 after.

Two RHEL sessions are retained. Session 1
(`rhel-acceptance-20260827T114631Z`) carries the capability answer, the
deployment and the preload measurement. Session 2
(`rhel-acceptance2-20260827T222103Z`) carries the requirement's functional
evidence: git 2.52.0, Python 3.13.9 and `import ssl, zlib` all at exit 0, with
`libssl.so.3` and `libcrypto.so.3` resolved by the shipped loader inside the
prefix.

## RESOLVED 2026-08-29, and this section is kept as the record of how

The verdict is now `Yes, it is implemented.` The section below described a
deadlock that a SCOPE CORRECTION removed, and it is left standing because the
cause is worth not rediscovering.

Five criteria were moved to umbrella requirement 7, where the rebuild happens
and the archive's contents first become assertable: the residual assertion, the
Step 4 handoff, migration positivity and case 5 equality, the three `$HOME`
states, and force reinstall. The umbrella already drew that boundary when it
placed this requirement second because it "needs no rebuild either, and can be
proved against the current archive"; the step 6 acceptance had crossed it.

Measured afterwards by run `step6scope-20260829T203916Z` on the RHEL target,
retained as `verify.acceptance.scope.rhel.txt`: 216 cases, 0 failures,
`OBJECTIVE MET`. The run is on RHEL rather than the Debian agent because CI was
down with a sealed vault, and the human owner decided to retain it rather than
hold the umbrella frozen. Retaking the Debian captures was owed once CI came
back, and was never a condition of the verdict.

**DISCHARGED on 2026-08-30 by CI build 130**, at commit `96c5799c`, the first
build carrying the scope correction. All six steps ran on the Debian agent and
all six answered `OBJECTIVE_MET`: 162, 462, 355, 104, 540 and 216 cases, zero
failures anywhere. Step 6 reports `tools/python/root/a.out` as
`step6/handoff-resolved NOTE handed to umbrella requirement 7 with its owner
named`, where build 123 had ended `OBJECTIVE NOT MET for step 6: 2 failure(s)`
on that same line. The captures are retained beside this note as
`verify.relocation.step{0,1,2,3,4,6}.debian.txt`.

## What WAS not done, and why it blocked everything

`tools/python/root/a.out` is a stray program the PUBLISHED archive carries,
confirmed on both distribution paths. Removing it is umbrella requirement 7
(`tools-archive-rebuild`). Three further criteria sit behind that rebuild and
have NEVER EXECUTED: migration positivity and case 5 equality, the three `$HOME`
states, and force reinstall.

**This is a circular dependency in the umbrella's own ordering.** Requirement 7
is the integration item where the five preceding changes, this one included,
become one artifact. So this requirement's step 6 gated itself on the output of
a requirement that consumes it. Nine review rounds ended the same way for that
reason; the criteria were unsatisfiable in the plan's own sequence.

The correction is recorded in the plan, the issue and the umbrella: the residual
and handoff criteria are TRANSFERRED to umbrella requirement 7 and are not
obligations of this requirement in any form.

ONE RESIDUAL CONTRACT, the same sentence the issue, the plan and the harness
carry. An adjudicated residual, one the ownership register names with an owner,
is reported as a HANDOVER naming that owner and is NOT `UNANSWERED`. An
unadjudicated one still FAILS outright. The gate keeps its strength and is made
where it can be answered, and it cannot outlive the defect because step 4
asserts the register exact in both directions.

An earlier revision of this note said `UNANSWERED`. That was the sequencing
amendment, which the scope correction superseded; carrying both readings is
what round 10 caught.

That change is VERIFIED on RHEL, run `step6verify-20260829T132824Z`, both
directions: `a.out` defers with its owner named, and a planted unadjudicated
`zz-stray.out` fails on both criteria. It is NOT yet verified on the Debian
agent, because CI is down.

## Settled decisions that must not be re-litigated

- **The monitoring criterion is `not-pursued`**, by two recorded human decisions
  dated 2026-08-28, retained verbatim with the questions that produced them. The
  preloaded agent is statically linked, so `DT_RPATH` cannot reach it. Forms 1
  and 2 are unobtainable by the deployment account; form 3 is OBTAINABLE and was
  declined. The second decision made `not-pursued` a PASSING outcome with the
  consequence stated in front of the decider. Do not reopen this.
- **Convergence to `commit-ready` was argued and refused**, round 9, explicitly:
  `commit-ready` means the step satisfies the readiness floor, not that the
  staged record accurately describes unfinished work. That ruling stands and
  arguing it again produced an escalation.

## Two findings worth carrying forward

- **Step 6 selection depends on where the prefix lives.** Case 6 is gated on the
  object's rpath containing the literal `/home/`. Measured both ways on one host
  with one archive: under `/tmp` nothing is selected and the residual criterion
  reports clean over a tree that still carries the stray program; under `/home`
  it behaves correctly. Step 6 caught `a.out` on CI because the workspace lives
  under a home directory. A deployment to `/opt` or `/srv` would not catch it.
  Not raised as a defect, because the guard may be intentional for the install
  pass, but never read "no selected residual remains" as "the archive is clean".
- **CI was down on 2026-08-29** with `Vault is sealed`, HTTP 503, failing before
  checkout. Builds 124, 125 and 126 all died in seconds. Nothing of ours ran.

## How to resume

Nothing is owed by this requirement until umbrella requirement 7 rebuilds the
published archive without `tools/python/root/a.out`. When that artifact exists:

1. DONE on 2026-08-30, build 130: the green Debian build confirming the
   sequencing change on the agent. It was committed at CI `9a37a822` and
   verified only on RHEL until then;
2. consume the rebuilt archive at step 6 and verify `a.out` is gone. The stale
   register entry will then FAIL at step 4 until it is dropped from
   `STEP4_ARCHIVE_DEFECTS`, which is the mechanism that retires the deferral;
3. run migration positivity and case 5 equality, the three `$HOME` states, and
   force reinstall, none of which has executed;
4. retake the affected evidence from a build carrying the current harness;
5. update `plan.v0.27.0.relocation-force-rpath.validation.md` and `a.commit`
   only as the results support;
6. publish the next review round into the open round 10.

The local operating notes, including host access, the CI sync list and the traps
that cost real time, are in the ignored root file `a.infra-access.local.md`.
That file is never versioned: it names hosts and accounts, and this repository
is public.
