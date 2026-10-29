# Step 4 two-way outcome ledger

Required by Step 4's completion criteria: every applicable row of the design's
fault matrix and every production-outcome row of its acceptance table maps to
one or more matrix rows with zero uncovered, and every `A01` to `A30` and every
run maps back to what it comes from.

The matrix itself is literal data in
[the harness](verify.relocation-rpath.sh), held as `STEP4_MATRIX` so the
expectations are read rather than derived. A cell saying "its own case" is an
instruction to compute an expectation, not an expectation, and a table of those
cannot be executed.

## Direction 1: design and plan to matrix

| Obligation | Rows that witness it |
| --- | --- |
| the fresh program population is rewritten | `A01`, `A03` |
| the shipped library population is rewritten | `A02` |
| an excluded RPM-extracted program is untouched on the rpath axis | `A04`, `A05` |
| a non-dynamic object is neither rewritten nor blamed | `A06` |
| an ambiguous object carrying both tags fails closed | `A07` |
| a second pass rewrites nothing and accounts for the covered set | `A08` to `A13` |
| the migration population is converted | `A14` |
| a migration object with a wrong interpreter is converted AND reported | `A15` |
| a structural failure fails both axes | `A16`, `A17`, `A18` |
| an rpath probe fault reaches case 1 | `A19` |
| an interpreter probe fault leaves the rpath axis intact | `A20` |
| a failed write on a case 5 object keeps its migration membership | `A21` |
| a failed interpreter write leaves the rpath axis intact | `A22` |
| an empty computed target fails the writes that were due | `A23` to `A28`, over `R14` |
| every residual program the record does not name is CLASSIFIED | `step4/residual-classified`, over a copy of the real extracted archive; whether the archive should carry it is Step 6 |
| the ownership register is exact in both directions | `step4/residual-register-stale`, and the `step4/residual-handoff-to-step-6` note |
| the formatter has one terminal site | `step4/formatter-call-sites`, expecting three occurrences |
| the interpreter guard is unchanged | every `unchanged` cell: `A04`, `A09`, `A10`, `A11`, `A14`, `A21` |
| a skipped pass emits a trailer and no records | `R13`, as `step4/skipped-*` |
| both axes account for every walked object | `step4/rpath-axis-sums-*`, `step4/interp-axis-sums-*` |
| the resolved loader is excluded, by rule and not by fall-through | `A29`, `A30`, and the seam pair `step4/loader-without-rule` answering 4 beside `step4/loader-with-rule` answering 7 |
| the archive still runs after the pass | `step4/archive-loader-runs`, `step4/archive-python-runs`, over the real archive copy |
| the tag becomes `DT_RPATH` | `baseline/tag-written` |

**Uncovered obligations: zero.**

All thirty rows execute and pass on the Debian 12 agent, build 110, together
with the loader seam pair, the two run-after assertions, the call-site count and
the residual classification: 540 cases, zero failures, `OBJECTIVE MET`, exit 0.

The route there is worth keeping. Build 105 answered `A01` to `A28`. Build 106
reported `matrix/row-count want [28] got [30]`, the guard this plan credits with
catching the `D02` row, catching two rows added without their count. Build 107
printed `result: UNEXPECTED_EXIT_6` over a clean verdict, because a new harness
exit code has to arrive with its line in the capture wrapper's mapping in the
same change. Build 108 was clean under the adjudicated gate. Round 3 then found
two things builds cannot: the formatter had two terminal sites where the plan
asks for one, so the harness had been written to the code rather than to the
plan and passing it proved divergence; and the line-budget checkpoint had never
been measured. Build 109 was the first run of the corrected shape; build 110
repeats it with the harness comments brought into line with the code, which
round 4 found still claiming the gate this step no longer holds.

## Direction 2: matrix to what it comes from

Every row names one walked object in one run, so its path is fixed and its
record is literal.

| Rows | Run | What the run is |
| --- | --- | --- |
| `A01` | `R0` | a prefix outside `/home`, one object, both guards firing |
| `A02` to `A07` | `R1` | the ordinary walk over six objects |
| `A08` to `A13` | `R2` | the same prefix, second pass, idempotence |
| `A14` | `R3` | migration |
| `A15` | `R4` | migration with a host interpreter |
| `A16` | `R5` | a truncated program header table |
| `A17` | `R6` | ELF32, outside the domain |
| `A18` | `R7` | shorter than the header |
| `A19` | `IF01` | the `--print-rpath` probe double |
| `A20` | `IF02` | the `--print-interpreter` probe double |
| `A21` | `IW01` | the `--set-rpath` write double, on a case 5 object |
| `A22` | `IW02` | the `--set-interpreter` write double |
| `A23` to `A28` | `R14` | an empty computed search path, reached the only way this code allows |
| `A29`, `A30` | `R1`, `R2` | the ordinary walk and its second pass, where the loader is planted in the shape the archive ships |
| none | `R13` | patchelf absent, asserted directly rather than by row |

**Rows without a derivation: zero.**

The doubles are bounded the same way Step 1's are: one flag, one failure, every
other invocation forwarded to the real tool. They are planted at
`$INSTALL_PREFIX/tools/bin/patchelf`, which is the surface `find_patchelf`
resolves first. An earlier version planted them on `PATH` and the fault rows
never fired, because the double was not the binary the pass ran.

## The R12 adjudication, and what replaced it

`R12` was defined as a prefix with an **empty computed search path** whose
**interpreter axis is untouched**, and its trailer row expects `i-rewritten=2`.
Both halves are needed: without the interpreter working, the run stops testing
the axis independence it exists to test.

That fixture cannot be built against this production code:

- `find_dynamic_linker` accepts `tools/python/root/lib64/ld-linux-x86-64.so.2`
  or `tools/python/root/usr/lib64/ld-linux-x86-64.so.2`;
- `build_elf_rpath` collects `root/usr/lib64`, `root/usr/lib`, `root/lib64` and
  `root/lib` under every `tools/*/`.

Every interpreter candidate therefore lives **inside** a directory the search
path builder collects, so a prefix that resolves the interpreter always yields a
non-empty target, and a prefix with an empty target never resolves an
interpreter. The two conditions are mutually exclusive.

The rows were first reported **unanswered**, with no fixture invented to make
them pass: reporting them green would have claimed a run that never happened,
and failing them would have blamed the pass for a fixture nobody can construct.

**The adjudication has since been made, and `R12` is retired.** The reviewer
declined to choose, correctly: the meaning and constructibility of a run is
reviewed plan authority rather than a reviewer repair, and the same rule that
corrected Step 3 applies here. The decision taken was to retest the claim rather
than weaken it or change production behaviour to suit a fixture.

`R14` replaces it: a prefix with **no tool library directories**, which is the
only way this code reaches an empty computed target. The interpreter goes
missing for the same reason, so rows `A24` and `A26` expect `unchanged` rather
than the rewrite `R12` demanded, and the trailer row moves `i-rewritten` from 2
to 0 and `i-unchanged` from 1 to 3. Those figures are what the code produces,
confirmed against build 105 rather than predicted.

The claim `R12` was written to make still stands and is now made by a run that
exists: under `R14` the interpreter axis reports `unchanged` or `not-applicable`
throughout and never `failed`, which states the same independence in the terms
the code can produce. What was given up is the stronger `i-rewritten=2` form,
which no prefix could ever have produced.

## The second adjudication, withdrawn and replaced by an ownership boundary

`R12` was retired because no fixture could satisfy it. The `a.out` violation was
first handled the same way: adjudicated, reported `blocked`, given its own exit
code. Round 3 rejected that, and was right to.

The objection was not about the violation. It was that a mandatory command
returning a non-zero exit cannot be presented as a passed readiness check, and
that deciding whether a step may transfer a failed completion criterion is
specification authority rather than a writer's call. Both hold. The adjudication
was an exception carved into a gate this step had just failed, which is exactly
the shape a reviewer should distrust.

What replaced it is not a smaller exception. It is an ownership boundary, and it
was already in the plan. Step 2 deferred the residual half with the reason still
written in its criteria: **a residual is a property of the ARCHIVE rather than of
the classifier.** That sentence decides this. Step 4 walks a copy of the staging
tree, so what it can honestly gate is what the classifier did with every residual
it found. `a.out` lives in the published archive, and the only work that removes
it is a rebuild. The deployed archive is in hand at Step 6, whose criteria
already called themselves the final assertion of the residual half.

So the gate moved to where the evidence is, rather than the failure being
excused where it was not.

| Outcome | Why refused or taken |
| --- | --- |
| report it a failure at Step 4 | blames this step for a tree it cannot change, and leaves it permanently red on work owned elsewhere |
| report it a pass, or drop the criterion | claims a green the archive does not deserve |
| adjudicate it `blocked` at Step 4 | refused in round 3: a non-green mandatory command is not a passed readiness check, and the gate transfer is specification authority |
| gate it at Step 6 and report it at Step 4 | taken, by specification decision |

What Step 4 gave up: the right to gate on the archive's contents. What it kept,
and what it never had before: an assertion that every residual program was
classified, an ownership register asserted in both directions, and a named
handoff set.

What Step 6 gained: nothing it did not already claim. Its residual criterion is
unchanged and admits no exception; it now also consumes Step 4's handoff by name
and closes with the sentence that keeps this honest, that Step 4 may narrow what
it gates and Step 6 may not.

The register survives because ownership is still worth recording, and it is
asserted exactly and in both directions: an entry the archive no longer carries
fails, so the rebuilt archive cannot land while this file still names a
violation the rebuild removed. That check is Step 4's because it is this
harness's own bookkeeping, not the archive's contents.

## The loader exclusion, and why it needed its own assertion

Not an adjudication: a defect, found because the residual half ran the pass over
a real archive for the first time.

The pass wrote `--force-rpath --set-rpath` into the shipped dynamic loader,
which case 4 claims by shape. Measured on the RHEL 9.8 target, patchelf 0.19.1,
glibc 2.34, on copies:

| Step | Result |
| --- | --- |
| the shipped loader, `--version` | exit 0 |
| the case 4 write on it | **exit 0**, 897856 to 905033 bytes |
| the same loader, `--version` | **exit 139, signal 11** |
| a program whose `PT_INTERP` names it | **exit 139, signal 11** |

The middle row is why this step gained a run-after assertion. patchelf reports
success, so the record reads `rewritten`, the trailer reconciles, and every
categorical check in this harness passes over a tree that segfaults at exec.
Three builds reported a clean walk and then died in the next pipeline stage. A
reconciled account is not a working tree, and no amount of accounting can tell
the difference: the tree has to be run.

The blast radius was measured rather than assumed. `libc.so.6`, `libm.so.6`,
`libdl.so.2`, `libpthread.so.0`, `libz.so.1` and `libstdc++.so.6` all took the
same write, together and one at a time, and a program ran through every set at
exit 0. One object breaks, so one object is excluded.

## What the loader defect cost, counted

Not a lesson in the abstract. Three builds, and the exact shape of each:

| Build | What it reported | What was true |
| --- | --- | --- |
| 102 | step 4 clean walk, 269 residual failures | the pass had destroyed the loader |
| 103 | step 4 clean walk, 1 residual failure | the same, with the residual check scoped |
| 105 | step 4 clean walk, 519 cases, 1 failure | the same, and the finding recorded as the archive's fault |
| 108 | 540 cases, 0 failures, BLOCKED | the loader is excluded and the tree runs |

In every one of 102, 103 and 105 the CPLX-ELF/1 stream reconciled. Records read
`rewritten`, the trailer balanced, categorical reconciliation passed, and the
interpreter was already dead when the account was written. The stage after it
died on the tree the check had just walked, and the finding those builds
produced was aimed at the archive while the defect was in the pass.

A reconciled account is not a working tree. The step now runs what it rewrites.

## Where the contradiction actually was, and how round 4 found it

The selected-residual question took three answers to settle, and the first two
were wrong in ways worth keeping apart.

The first was the adjudication: an exception carved into a gate this step had
just failed. Round 3 refused it on the right grounds, that a non-green mandatory
command is not a passed readiness check and that transferring a failed criterion
is specification authority.

The second looked like the fix and was half of one. The later bullets of Step 4's
criteria were narrowed to what the step owns, and the FIRST bullet was left
saying "every other archive program preserved". So the same section forbade and
permitted the same object, and the harness implemented only the permissive
reading. A green run then proved one branch of a contradiction, which is the
same failure the formatter cardinality had: a passing test that certifies
divergence.

Round 4 found it by reading the requirement rather than the plan, and that is
what located the real answer. The clause sits under the issue's `## Acceptance`
heading. Acceptance is Step 6. So the claim was never Step 4's to make, and the
first bullet had been over-claiming since it was written: a staging copy cannot
answer a question about what the published archive contains.

Nothing in the requirement was weakened to resolve it. Every acceptance
criterion keeps its wording and admits no exception. What was added is one
paragraph saying WHERE they are proved, which is the sentence whose absence let
an implementation step adopt one as its own gate.
