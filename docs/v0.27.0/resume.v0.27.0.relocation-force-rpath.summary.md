# Where `relocation-force-rpath` stands, seen from the umbrella

Umbrella requirement 2. This is a SUMMARY kept on the integration branch so the
state is visible without checking out the item branch. The full note, with the
evidence and the ordered resume sequence, is
`docs/v0.27.0/resume.v0.27.0.relocation-force-rpath.md` on branch
`relocation-force-rpath`, and it is not visible from here.

## State

| | |
| --- | --- |
| Branch | `relocation-force-rpath`, 68 commits ahead of this branch, NOT merged |
| Working tree | clean, everything committed |
| Review exchange | round 10, open, nothing published |
| Umbrella row | still `pending`, and its validation plan reads `No, it is not implemented.` |

## Done

Steps 0 through 5 implemented, reviewed and committed. Step 6, the acceptance
over the deployed archive, implemented with its evidence retained from both
hosts. The production change is one exclusion rule: the relocation pass must
never rewrite the patchelf binary executing it, found by the acceptance on a
real deployment and confirmed on both distribution paths.

Two target sessions are retained, carrying the capability answer, the
deployment, the preload measurement, and the requirement's functional evidence:
the toolchain git and python answer and `import ssl, zlib` passes, with the
OpenSSL provider resolved by the shipped loader inside the prefix.

## Not done, and the reason is a planning defect

`tools/python/root/a.out` is a stray program the PUBLISHED archive carries.
Removing it is umbrella requirement 7. Three further criteria sit behind that
rebuild and have never executed: migration positivity and case 5 equality, the
three `$HOME` states, and force reinstall.

**The requirements cannot advance in this umbrella's own ordering.** Item 2
gated itself on an artifact item 7 produces, item 7 consumes items 2 to 6, and
the `process-draft` ordering gate refuses to start item 3 while item 2 is not
`completed`. Nine review rounds ended the same way before the cause was named.

**The contradiction is inside requirement 2's own scope.** This umbrella places
it second because it "needs no rebuild either, and can be proved against the
current archive". Step 6's acceptance then added criteria that assert what the
DEPLOYED ARCHIVE CONTAINS, which no amount of work on `install_pkg.sh` can
satisfy and which the umbrella never asked for.

## Settled, and not to be reopened

- the monitoring criterion is `not-pursued` by two recorded human decisions
  dated 2026-08-28, retained with the questions that produced them;
- convergence to `commit-ready` was argued and refused: it means the step
  satisfies the readiness floor, not that the record accurately describes
  unfinished work.

## Carry forward

- step 6 selects objects only when the previous prefix sat under a home
  directory, because case 6 is gated on the rpath containing that string.
  Measured both ways on one host with one archive. A deployment elsewhere would
  report no selected residual over a tree that still carries the stray program;
- CI was down on 2026-08-29 with a sealed vault, failing before checkout.
