# v0.27.0 relocation-force-rpath implementation tracking and validation

Yes, it is implemented.

This document tracks the implementation of
[plan.v0.27.0.relocation-force-rpath.md](plan.v0.27.0.relocation-force-rpath.md),
seven steps that give `install_pkg.sh` an ordered ELF classifier, a forced
`DT_RPATH`, and a report a retained recipe can assert on. All seven steps are
implemented and every criterion this requirement owns passes.

THE VERDICT FLIPPED ON 2026-08-29, and what changed was the SCOPE rather than
the code. Two step 6 criteria asserted what the deployed archive CONTAINS, and
three more needed a rebuild cycle. The umbrella places this requirement second
because it "needs no rebuild either, and can be proved against the current
archive", so those five were outside its boundary from the start. They are moved
to umbrella requirement 7, recorded in the umbrella against both items, and the
harness now hands them over by name instead of holding this verdict open.

The measurement behind the flip is `verify.acceptance.scope.rhel.txt`, run
`step6scope-20260829T203916Z`: 216 cases, 0 failures, `OBJECTIVE MET` at exit 0,
invoked with every input the harness asks for.

THAT RUN IS ON THE RHEL TARGET, NOT THE DEBIAN AGENT, and the departure is
deliberate. CI was down from 2026-08-29 with a sealed vault, failing before
checkout, so no agent build was obtainable. The RHEL target satisfies the step 6
capability gate on its own. The human owner of this effort decided to retain
that run rather than hold the umbrella frozen on another team's outage. The
retained Debian captures remain from build 123 and cite an earlier harness
digest; they are evidence for the steps they were taken against and are not
restated as evidence for this flip.

> Skeleton note: every per-step section other than `Goal` and
> `improvement expectations` carries the literal placeholder
> `_(empty — no check has taken place yet.)_.` until an implementation check
> replaces it.
>
> Markdown lint note: never leave a space immediately inside an inline code span
> (MD038) -- write a needed space as the token `[space]`, as in `` `[space]${x}` ``.
> The empty placeholder ends in `)_.` so the line is not pure italic text (MD036).

---

## Analysis of Step 0 implementation state

Yes. Step 0 has been fully implemented.

The harness reports `OBJECTIVE MET` on the Debian 12 CI agent, build 65, **46
cases and 0 failures**, and every claim it makes is asserted through the code
path that makes it. The production pass ran over a planted, asserted ELF; it
emitted `Fixed 1 ELF interpreter/rpath value(s)`; the donor's rpath **value** is
proved to have become the computed target and to have left the planted
`/home/builder/prefix/lib`, which is what ties the reported mutation to this
object rather than to any other walked ELF; and `readelf -d` confirms the tag it
wrote.

All three of the plan's capability outcomes are now reachable and distinct, and
each has a case. Exact evidence gives `supported`: `declare -A` is supported on
the exact RHEL 9.8 target at bash 5.1.8, measured on the target and retained in
`docs/v0.27.0/capability.rhel-9.8.txt`. Representative version-pinned RHEL 9 or
UBI 9 evidence opens the **provisional** branch and records the Step 6 debt
rather than discharging it. And **no evidence at all BLOCKS the step**, which is
the correction this round makes: silence about the target used to be a note that
let a capable run report success while knowing nothing about the machine it
exists to qualify.

The evidence is drawn through `capability_verdict` and `capability_source`, the
production functions every case calls, so a change to either is a change to what
those cases observe. They refuse a wrong distribution, a `9.80` near-miss, a
`9.7` near-miss, an `unsupported` outcome, an `unavailable` one, a malformed one,
a missing bash version, a self-contradicting file and a named-but-missing file,
and they cover all three source branches including the two that carry no file.

The seam is in place with the executed path byte-identical to before,
`shellcheck` is clean on both files, and both harness prerequisites resolved. The
retained evidence is `docs/v0.27.0/verify.relocation.step0.debian.txt`, carrying
the commit it was built from, `0a2b25e13b8f`, and the harness digest
`fbafc244…`, both checked against the local repository.

### Goal for Step 0

Build the executable oracle first, and open the seam every later step's tests
need, so each step is judged against a captured baseline rather than against the
plan's description. The installer changes structurally in this step, two
function definitions moving above an explicit main boundary and a guard placed
there, with no change to what an executed run does.

### Step 0 improvement expectations

The current mixed `Fixed <n>` count, the object count of a prepared prefix, and
the tag a rewritten object carries today are all recorded. A later step that
changes one of them can show the change rather than assert it.

Three assumptions stop being assumptions here. The associative-array check
records one of three outcomes for the RHEL 9.8 target, with Debian 12 documented
at Bash 5.2: supported proceeds, unsupported stops the plan for revision, and
unavailable records Step 0 as blocked unless representative version-pinned
evidence is captured, which defers exact-target confirmation to Step 6. An
unavailable check is not evidence of an unsupported shell.

Both harness prerequisites resolve to an executable on the validation host and
are recorded: `readelf` for the fixture oracle, and GNU `sha256sum` for Step 1's
shipped-patchelf content identity. The digest tool is named rather than left as
"such as a digest", because content identity is the only part of that check a
double cannot forge, a binary being replaceable at the same path and a version
string being printable by anything. Either prerequisite absent leaves this gate
incomplete, and neither absence licenses a fallback: not path plus version in
place of a digest, which is precisely what the digest strengthens, and not
another checksum chosen quietly. Both are harness prerequisites that never run
during an install, and both are excluded from the installer mechanically rather
than by intention, being named in the execution checklist's negative host-tool
grep over `install_pkg.sh`.

What Step 0 records is that a **reusable preflight** passed here, not a value
later steps reuse. The harness runs as `verify.relocation-rpath.sh --step N`, so
each step is a fresh process: a path resolved in the `--step 0` run cannot
survive into the `--step 1` run, and recording that a tool once existed does not
identify the executable a later run invokes. The preflight runs at the start of
every dependent harness invocation, before the installer is sourced and before
any case-specific environment mutation, so nothing a case arranges can influence
what it resolves. It resolves with Bash `type -P`, which yields a path rather
than a shell function or alias; requires an absolute path to a regular
executable file; verifies the required interface; and only then assigns to a
fixed read-only harness variable. That ordering is load-bearing rather than
stylistic: a combined `readonly VAR="$(...)"` returns the declaration's status
and not the substitution's, so a failed resolution would be masked and the
variable frozen empty, and `shellcheck` reports the combined form under SC2155,
so the gate already in place catches a regression. Any resolution, file-property
or interface failure leaves this gate incomplete.

The seam is real work rather than a one-line guard. `usage` and
`select_copy_engine` are defined after the main flow begins, at lines 432 and
485, so no location satisfies "after every definition and before main" until
they move. After the rearrangement, sourcing the installer defines its functions
without performing an install, the harness asserts every production function it
will call is defined, and executing the script is unchanged.

### What was implemented for Step 0

Four artifacts accompany the rearranged installer: the harness, the retained
Debian capture, the retained RHEL capability measurement, and this validation
record. No production behavior is intended to change.

**`docs/v0.27.0/verify.relocation-rpath.sh`** (new, 893 lines). The executable
oracle, a separate file rather than an extension of `verify.install-pkg.sh` per
Q01, so nothing here can break that file's mirrored shared-body digest. It takes
`--step N`, `--installer PATH`, `--prefix DIR`, `--patchelf PATH`, exact or
representative capability evidence, and the exact-target flag. Its `--step`
dispatch accepts only 0 today: accepting an unknown step would let the verdict
line report success for a suite that does not exist.

- **the prerequisite preflight**, run before the installer is sourced and before
  any case-specific mutation. It resolves with `type -P`, requires an absolute
  path to a regular executable file, verifies the interface, and only then pins
  the value read-only, in that order, so a failed substitution cannot be masked
  by the declaration builtin;
- **the capability gate**, recording one of the three `declare -A` outcomes;
- **a negative control** whose unplanted fixture must fail, so a suite that
  blesses anything is caught before any positive case is trusted;
- **the seam cases**: sourcing returns zero, the prefix gains no entry, every
  production function the harness will call is defined, the guard is present and
  precedes the main flow, both moved definitions sit above the boundary, and an
  executed run still refuses on the usage path;
- **the real baseline**: it plants a dynamically linked ELF by copying a shipped
  system object and anchoring it with `patchelf --set-rpath
  /home/builder/prefix/lib`, asserts that plant with `patchelf --print-rpath` and
  `readelf -d` before anything runs, invokes the **production** `fix_elf_paths`
  through the seam, reads the emitted `Fixed <n>` line out of that run's output,
  and inspects the rewritten object's tag with `readelf -d` independently. No
  compiler is needed and nothing is read from the installer's source text;
- **one host-tool contract rule** replacing the two the first round carried. It
  matches a forbidden name in **command position**, at the start of a command or
  after a pipe, separator, subshell opener or control keyword, so
  `/usr/bin/python` and `./readelf` are caught while
  `"$INSTALL_PREFIX/tools/python/root/..."` stays an argument. It carries six
  negative cases it must reject and two benign shapes it must allow, read from
  heredocs so the harness's own quoting is not the thing under test;
- **a host-capability gate** that refuses a step this machine cannot run,
  distinctly from a code failure. Step 0's baseline needs an ELF-capable Linux
  host with `patchelf`; where that is absent the harness prints `HOST CANNOT
  SATISFY STEP 0` and exits 4, and says in as many words that no substitute was
  accepted. Host-independent cases run first and their result stands.

**`src/setups/env/bin/install_pkg.sh`** (625 to 649 lines, a measured net of
**+24**). The rearrangement the plan requires and nothing else:

- `usage` and `select_copy_engine` move above a new `# --- MAIN BOUNDARY ---`,
  their call sites unchanged at their original positions;
- the sourced-versus-executed guard is placed at that boundary, returning when
  `BASH_SOURCE[0]` differs from `$0`;
- the `# --- 1b. Select the copy engine ---` marker is restored at the call site,
  since the section header traveled up with the definition.

Executed behaviour was compared before and after by running both copies from
identically-named paths and diffing the output: **identical once `$0` is
normalised**, with the same exit code 1 on the usage path.

Twelve defects were found before this round by running the harness or by reading
the environment it must run in: three before the first request, two in code
review round 1, two by reading the CI pipeline, four in builds 56 and 57, and
one in code review round 3. They are recorded because the shape matters more
than the fix.

- **the preflight could not fail.** `preflight_tool` returned the resolved path
  **on stdout** and was called in a command substitution, so its diagnostics went
  into the variable and its `PREFLIGHT_OK=0` ran in a subshell that could not
  reach the parent. The gate could not trip. It now returns through a named
  variable;
- **an assertion passed against the wrong line.** `seam/guard-precedes-main`
  matched the **first** `BASH_SOURCE[0]` in the file, a pre-existing legitimate
  use at line 19 for `INSTALL_PKG_DIR`. It reported PASS with `guard 19`, a false
  pass, which is worse than failing because it reports the property as held. It
  now matches the boundary marker and asserts the guard's exact text separately;
- **the plan's literal host-tool grep cannot reach zero** on this installer,
  matching `python` four times inside path strings it must contain and once in a
  comment;
- **the baseline measured a description, not a run** (round 1). It counted a
  planted plain-text file, inferred the written tag from the absence of
  `--force-rpath` in the source, and grepped the source for the `Fixed` format
  string. Step 0 exists so later steps are judged against a measurement rather
  than a description, and that version captured the description. It could not
  have been otherwise on this host, which has no ELF toolchain, and the harness
  wrote something it could run instead of refusing;
- **the narrowed host-tool rule let path-qualified commands through** (round 1).
  Excluding any name adjacent to `/` treats `/usr/bin/python` and `./readelf` as
  path text even in command position. Fixing the first false positive introduced
  a false negative, which is the same error the plan's alternate-pair column made
  twice: a correction made without checking what it now permits.

- **the round 2 host gate resolved patchelf on PATH only** (found after round 2
  was published, by reading the CI pipeline that would run it). The Debian agent
  ships patchelf inside the extracted prefix and never on PATH, so the gate added
  to stop the harness faking a baseline would have refused to run it on the one
  host able to produce one. It now resolves as `find_patchelf` does, prefix then
  home tools then command path, with a `--patchelf` override, and plants the
  resolved binary at `tools/bin/patchelf` in the fixture prefix so the production
  resolution runs on its ordinary surface;
- **the round 2 baseline would have measured a skipped pass** (same reading).
  `build_elf_rpath` derives the target search path from directories that must
  exist, and the fixture prefix held only `tools/bin`, so the computed value
  would be empty and `fix_elf_paths` would skip every write under its
  `[ -n "$new_rpath" ]` guard while still printing a `Fixed` line. The fixture
  now carries a realistic tool layout, and a new assertion fails loudly if the
  computed target rpath is ever empty, so a pass that does nothing can no longer
  read as a pass that worked;
- **build 56 sourced a foreign `echos` helper.** The candidate sat beside an
  unrelated helper, so the source probe exercised more than the standalone
  installer. The harness now sources an isolated scratch copy;
- **`seam/functions-defined` passed after the probe died.** Empty output became
  an empty missing-function list, which matched the expected empty value. A
  `PROBE` sentinel is now required before values are read;
- **`baseline/tag-written` passed after the production call exited 127.** The
  planted and expected tag were both `DT_RUNPATH`, so the untouched fixture
  satisfied the assertion. The tag check is now gated on a successful call and
  emitted count;
- **build 57 applied isolation to one of three source sites.** The target-rpath
  and production probes still sourced the caller's copy. All three now use the
  isolated copy;
- **the aggregate mutation did not identify the donor.** The baseline proved a
  call returned zero and counted one mutation, then checked only that the donor
  retained its planted `DT_RUNPATH` tag. It now asserts the donor's exact target
  rpath and that the planted builder value has gone.

The earlier host-distinction findings are why the harness now carries a
**host-capability gate**. The plan formerly said "the validation host" without
distinguishing it from the authoring host, and an unstated assumption of that
kind is exactly what produced a baseline nobody could run.

### Two plan amendments this step made

Both are applied to the plan itself, which is staged in this round rather than
carried as notes.

- **The plan's execution checklist now states the tested rule.** It required a
  bare-word grep to print nothing, which it cannot: `python` appears four times
  inside path strings the installer must contain and once in a comment. The
  checklist now names the harness's own `host-tool/no-invocations` case, with
  the command-position rule stated and the reason recorded, so the checklist and
  the tested rule cannot diverge.
- **The plan now says which host can answer which step.** A new subsection gives
  the per-step requirement: Steps 0, 1 and 4 need a Linux host with `patchelf`,
  `readelf` and GNU `sha256sum`; Step 6 needs the RHEL 9.8 target; Steps 2, 3 and
  5 are host-independent. It also states the two rules that follow, that a step
  the host cannot run must refuse distinctly, and that the host-independent cases
  still run when a prerequisite is unresolved. The plan's earlier silence on this
  is what let a baseline be written that could not be measured where it was
  written.

### New types or classes introduced for Step 0

None. This is a Bash effort: no classes, no modules. The new artefact is one
shell script, `docs/v0.27.0/verify.relocation-rpath.sh`, and the new named shell
functions in it are harness scaffolding (`pass`, `fail`, `chk`, `note`,
`section`, `control`, `preflight_tool`, `capability_verdict`,
`capability_source`, `cleanup`, `unplanted_case`), none of which ships to a
deployment.

### Architecture check for Step 0

The DDD-Hexagonal question does not apply: this repository is a Bash toolchain
with no layers, ports or adapters, and the effort adds none. The architectural
property that does apply is the **deployment contract**, that `install_pkg.sh`
must run alone from a bare account, and it is preserved: no file was added to the
installer's dependencies, no host tool was introduced, and the harness lives
under `docs/` where no deployment reaches it.

The seam is the one structural change, and it is inert on the executed path. The
guard returns only when `BASH_SOURCE[0]` differs from `$0`, which is never true
for an executed script, and the two moved definitions sit above their unchanged
call sites.

One separation is intended: `readelf` and `sha256sum` are harness prerequisites
and must be kept out of the installer mechanically. The harness's
command-position rule covers bare and path-qualified forms and has explicit
negative cases for both.

No architecture issue remains for Step 0. Missing exact-target evidence now
enters the blocked outcome and prevents a green verdict; representative pinned
evidence is distinguished as provisional and records the Step 6 debt.

### Performance check for Step 0

No production computation was added, so the installed pass has the same cost it
had before: the guard is one string comparison evaluated once, on a path where it
is always false.

The harness itself walks a prepared prefix once, greps the installer a fixed
number of times, and sources it in one subshell. Every operation is linear in the
file or the prefix, and nothing iterates a collection inside a walk of the same
collection. No O(n^2) or O(n log n) computation is introduced.

No, there is no performance issue that needs to be addressed.

### Unit test coverage check for Step 0

The 100% unit-coverage rule targets `src\pdfss\tests\unit`, a Python tree this
repository does not have. There is no pytest, no coverage gate and no unit-test
directory here; the project's gate is `src/utils/lint_shell.sh`, which runs
`shellcheck` over every tracked script outside `docs/`, plus the Bash harness,
which is what the plan's execution checklist substitutes for the groundhog walk.

What stands in its place is the 46-case Bash suite retained from build 65, with
one negative control and a successful production relocation run. It asserts the
planted donor's exact post-pass rpath and the removal of the planted value.
The capability table now calls the production verdict and covers the round-5
near-miss and duplicate findings, the named-but-absent evidence path, all source
branches, and the no-evidence blocked outcome. The request supplies a clean
ShellCheck 0.11.0 run; the reviewer could not reproduce it because `shellcheck`
is unavailable here.

No, there is no unit-tested class below 100% that needs completing, because the
rule's tree does not exist in this repository.

### Feature integrity for Step 0

No regression is visible in the rearranged source: the moved functions and their
call sites are unchanged, the sourced guard is at the new boundary, and the
usage path still exits with the same code. The request reports a byte-identical
pre/post comparison after normalising `$0`, and build 65 executes the production
relocation pass successfully while proving the donor's value changed. Missing
target evidence now blocks the step, while representative pinned evidence opens
the provisional path and records the Step 6 debt. The rsync-versus-cp selection
remains at its original call site before archive discovery.

---

## Analysis of Step 1 implementation state

Yes. Step 1 has been fully implemented.

Twenty-one blockers have been raised across ten rounds and all twenty-one are
closed by work. Two were in the observer and nineteen were in the check written
to guard it. That ratio is left unaveraged, because it is the most useful thing
this step has to say: the production code needed the integer guards and nothing
else, while the gate meant to prove it safe needed nineteen repairs.

The observer has not changed since round 3. Its two guards are the round 2 work:
`elf_read_le` refuses any value at or above `2^63`, because ELF64 offsets and
sizes are unsigned 64-bit while Bash arithmetic is signed and
`0xFFFFFFFFFFFFFFF0` decoded to `-16`; and every extent is checked against the
remaining file rather than by adding an offset to a size, because two values
that each decode exactly can still overflow when added. `F24` and `F25` witness
those separately, since they fail at different points, and both were measured
against the pre-fix observer, which reports `structural_status: ok` for each.

Round 10 raised two gaps and both are closed.

**The controls did not exist.** The previous round's record asserted that the
contract's consistency rules were exercised against mutated contracts. They were
not: the rules only ever ran over a clean file, so each reported zero and nothing
established that any of them could report anything else. That is a claim
outrunning the code, in the document that keeps naming that failure as this
effort's recurring one.

Each rule is a function now, and there are ten controls. Five mutate a copy of
the real contract and require the rule to REPORT: a duplicated entry, a
duplicated launcher token, an entry answering neither `yes` nor `no`, an entry
saying `yes` with no launcher row, and a launcher whose owner is permitted by
nothing. Five require silence on the real contract, which is the other half of
the same claim, because a rule that reports on everything is no more useful than
one that reports on nothing.

**Two dispatcher facts were wrong, and both had been reasoned rather than
measured.** `builtin -- eval "$p"` runs eval and slipped past the boundary,
because the command word was taken as the token straight after the dispatcher
and that token was `--`. Flags and `--` are skipped now, which is exact rather
than approximate because neither dispatcher has an option taking an operand.

And `exec eval "$p"` does not run eval at all: exec replaces the shell with an
external program of that name, there is none, and it exits 127. I had put `exec`
in the dispatcher set by analogy and shipped the claim in a capture before
testing it. It is out, and the reason is recorded where the set is defined.

Build 89 on the Debian 12 agent: **462 cases, 0 failures**, with forty-four
reject shapes, thirty-one allow shapes, thirteen boundary shapes and ten contract
controls, and with the harness, the installer and the contract all matching the
indexed files by digest. The deployment-target capture is unchanged and still
applicable: the observer is byte-identical to the one it names, which was checked
rather than assumed.

### Goal for Step 1

Implement the normalized observation of Design Area 1: one structural read per
walked ELF producing `structural_status`, `elf_kind`, `has_dynamic`,
`has_interp`, `tag_state` and a status and value per probe, with every other
field cleared and both probes `blocked` on structural failure.

### Step 1 improvement expectations

Every input has a defined result, including the ones no archive should contain.
The guard-complete fixture matrix exercises each acceptance and rejection rule,
and the `e_phnum == 0` object is accepted rather than rejected. The installer's
observable behavior is unchanged at the end of this step.

Each fixture names and passes a **semantic** oracle before the observer sees it,
sourced independently of the observer: validation-only `readelf` where it can
express the state, and a specification-derived manifest where it cannot, for the
deliberately malformed shapes no tool will name. The size and single-mutation
assertions remain as provenance evidence and are not the semantic oracle:
proving the generator changed exactly one offset does not prove that offset is
`e_type`, so a generator and an observer sharing a wrong belief about where a
field lives would still agree.

The manifest is auditable rather than merely called golden. Every entry carries a
stable `Mnn` id and records field, offset, width, byte order, original bytes,
replacement bytes and an exact ELF specification citation. Lawful generation
recipes and whole-file operations take ids in the same namespace, `Gnn` and
`Xnn`, since a fixture built by emitting a different program header table or by
truncating a file has no single mutated range. Every fixture cites either all its
`Mnn` ids or exactly one `Gnn` or `Xnn`, and no row describes its construction in
prose. Traceability closes both ways: zero fixture mutations without a manifest
entry, zero manifest entries without a fixture or guard that uses them. Neither
the generator nor the observer imports constants from it.

Three cross-checks anchor the manifest outside itself, and the previous two
included one that claimed more than it can deliver. Layout confirmation emits the
lawful base at the manifest's own offsets and widths and requires `readelf -h`,
`-l` and `-d` to report the intended value for every named field, which is what
ties offsets to fields: a wrong offset puts the value where `readelf` does not
look. The per-entry value cross-check requires the base's bytes at each stated
range, decoded at the stated width and byte order, to equal what `readelf`
reports. The alternate pair requires two lawful bases differing in exactly one
reported field to differ at exactly that range, and its status is about **this
plan's selection rather than about what ELF permits**. That column has now been
wrong twice in opposite directions: first recorded as available for `e_phoff`,
`p_offset` and `p_filesz`, which this recipe set does not provide, then declared
not constructible for them, which is false, since two otherwise identical lawful
files can carry identical program header tables at two offsets and differ only
in `e_phoff`, identical segment bytes at two congruent offsets and differ only
in `p_offset`, or the same slack bytes with adequate `p_memsz` and differ only in
`p_filesz`. Four statuses replace the universal: **provided**, for the three
pairs this plan builds, `e_type` via `F01`/`F02`, `e_machine` via the base and
`F16`, and the search-path `d_tag` via `F06`/`F07` over an unchanged `d_un`;
**not provided**, where a lawful pair exists but needs a purpose-built second
base serving no guard of its own; **no lawful pair in this profile**, where the
field's domain under ELF64, little-endian, x86-64 holds one value, kept distinct
because only the previous status could be revisited by changing the recipe set;
and **not applicable**, for file operations and invariants with no field pair at
all. Every entry without a provided pair rests on the first two checks, which
were carrying the weight in any case.

The exhaustive unit is **each fixture and each rejection guard**, not the field
name. An earlier reading classified labels: "dynamic entry size" and "`DT_NULL`
termination" are not stored ELF fields. `Elf64_Dyn` is `d_tag` plus `d_un`, so
the sixteen-byte entry size follows from that layout rather than from anything a
fixture can write, and `DT_NULL` is a `d_tag` value terminating the sequence,
both per the LSB dynamic-section definition and Linux `elf(5)`. A bad dynamic
extent therefore mutates `PT_DYNAMIC`'s `p_filesz` to a value that is not a whole
multiple of 16, or truncates the file; a missing terminator replaces the
terminating entry's `d_tag` with a lawful non-terminating tag. One carrier
legitimately appears in several rows when different mutations prove different
rules, which counting fields forbade.

Every row carries its `Fnn`, cites the ids that build it, and names the reader
guard exercised, the semantic oracle with its citation, its alternate-pair
status, and the complete expected tuple. Zero fixtures are
unclassified and zero rejection guards are unexercised, counting the
identification guard's magic, class, encoding and version parts separately, and
every status other than "provided" carries its reason and its correct one of the
three remaining values. Every value the design defines for `elf_kind` and
`tag_state` is produced by at least one fixture. Applying that criterion to the previous matrix immediately found
three gaps: magic and `e_ident[EI_VERSION]` were unexercised, and nothing
produced `elf_kind: unsupported`. Giving the rows ids found more: the matrix had
promised an exact mutation in every row and then offered "no `PT_INTERP` emitted"
and "set past the file", neither of which is one. The classification is settled
in the plan rather than left to the implementer, since "use an alternate where
one exists" would otherwise be decided silently and differently per fixture.

**The tuple asserted is the whole tuple.** An earlier reading omitted probe
statuses wherever structure did not fix them, calling those the pass's concern,
which silently narrowed the contract this step claims to test: the design defines
both probe statuses and their values as fields of the observer tuple. Every
accepted and ambiguous fixture now states both statuses, whether each value is
present, and the literal value wherever the status is `ok`, and the case asserts
every named field of the array after the production observer and the production
probe step have run.

**Probe coverage is categorical, not proportional**, and the fallback that
preceded it could not have run. It said a refusal across most fixtures leaves the
axis untested and is reported at Step 4, while eight fixtures state literal `ok`
outcomes, each fixture must produce exactly its tuple, and execution stops at the
first step that is not green: Step 4 is unreachable from a Step 1 whose witnesses
failed. It was also the wrong shape regardless, since what the classifier relies
on is a behavior and not a proportion, and honest failures elsewhere do not
substitute for one missing success. Every relied-on behavior therefore has a
named witness and zero probe obligations are uncovered: the empty no-tag rpath
answer, the `DT_RPATH` value, the `DT_RUNPATH` value, the mixed-tag `DT_RUNPATH`
preference and the present interpreter, each with an `ok` witness and its literal
value; both structure-proved `skipped` producers; the `blocked` producer; and
both axis-local `failed` producers.

A named `ok` witness returning `failed` leaves this step **incomplete**, with two
ways forward and no third: repair the lawful recipe until the witness works with
the shipped patchelf, or stop for a reviewed Q03 fixture-source revision.
Rewriting the expectation to match the refusal is excluded by name, being the
cheapest move available exactly when the suite is red.

The two `failed` witnesses are deliberate. `D01` and `D02` run the production
probe step over the lawful base with a controlled patchelf double, one failing
`--print-rpath` while the interpreter answers and one the converse, each
asserting the surviving axis's status and literal value, which is what shows the
fault is axis-local. Step 2's controlled tuples prove the classifier consumes
`failed`; they do not prove the production probe produces it or leaves the other
axis intact.

**The doubles are bounded, and the boundary is asserted rather than tidied.** An
earlier version said only that a double was installed where `find_patchelf`
resolves, which names no surface, no restoration and nothing establishing which
binary the next witness used. A double left behind would serve every later
expected-`ok` fixture while the complete tuples and the zero-uncovered rule
stayed green, since a double is expressly able to return literal successful
values; that changes what the positive evidence means rather than merely leaving
a mess. `find_patchelf` resolves over three ordered surfaces, read from lines 301
to 314: `$INSTALL_PREFIX/tools/bin/patchelf`, `$HOME/tools/bin/patchelf`, then
`command -v patchelf`, the last of which reads the command search path and also
finds a shell function or alias of that name. All three are injection surfaces
and all three are contained.

Each fault case runs in its own subshell with a private scratch
`INSTALL_PREFIX`, `HOME` and command-search directory, installs only its own
double there, removes it on an exit trap, and asserts before probing that
production `find_patchelf` returns exactly that case's expected double path, so
a case resolving something else fails rather than passing for the wrong reason.
The canonical shipped patchelf is never overwritten, modified or shadowed in
place. The parent's resolution inputs are captured beforehand and asserted
unchanged afterwards, and no double file, resolved-tool variable, cache, shell
function, alias or injected search location survives into the other fault case or
any positive witness. Scheduling the fault cases last is rejected as a
substitute: it hides contamination instead of testing for it.

Containment alone proves only that the known injection was removed, so the
shipped tool's identity is re-established positively. Its resolved absolute path,
version and content identity are recorded before the fault cases, and only the
third is decisive, the first two being forgeable by a replacement at the same
path printing the same version string. The identity is a GNU `sha256sum` digest.
This step runs the harness prerequisite preflight for its **own** process and
records the path it pinned, rather than referring to what Step 0 resolved in a
different one, and every digest invokes that pinned absolute path,
`"$SHA256SUM_BIN" -- "$resolved_patchelf_path"`, never the bare command name. A
bare lookup after the preflight is prohibited: the pin exists so that what
verifies the restoration cannot be resolved through a command path a case has
touched, and one bare call gives that back. The computation is fail-closed: a
nonzero result fails the step rather than yielding an empty identity, the first
whitespace-delimited field is taken by Bash parameter expansion so no further
external tool enters the harness, and exactly 64 lowercase hexadecimal
characters are required, since a short, empty or oddly-cased value would compare
nothing against nothing.

The ordering is fixed and every digest happens in the parent: preflight and pin;
initial digest recorded; the fault case runs in its private subshell; the
subshell **exits**, so its private command-search directory and scratch
`INSTALL_PREFIX` and `HOME` are no longer in effect; the unchanged-parent
resolution assertions pass; the parent recomputes through the same pinned path
over the path `find_patchelf` now returns; the two digests must be equal; then
`F06` runs. The checksum executable is never resolved inside a fault subshell,
which may inherit the read-only variable but neither resolves nor replaces the
executable. The recomputation sits after the subshell exits for the same reason
the sentinel does: a measurement taken while the injected state is still active
describes the injection rather than the restoration. `F06` is chosen
because its expected tuple is `ok` with a non-empty literal on both axes, where
`F01`'s expected rpath value is empty and a leaked double answering with nothing
would satisfy it: a sentinel whose expectation an impostor can meet is not a
sentinel. Failure of the identity assertion or of the sentinel fails this step,
which makes leakage an observed event rather than an inferred absence. No
controlled double counts as evidence for any of the matrix's five `ok`
obligations.

Two fixtures exist partly to measure behavior rather than to assume it: the
`DT_RUNPATH` fixture measures the design's claim that `--print-rpath` answers for
either tag, and the both-tags fixture measures its stated patchelf preference for
`DT_RUNPATH`, on which a case 5 disposition rests, which is why its two entries
carry distinct strings. `F11`, whose duplicate-tag preference the design does not
fix, has a lifecycle instead of an expectation: status and value presence are
predeclared, the value itself is measured on first run and recorded with the
patchelf version, then frozen and asserted like any other, a later change being a
finding. It witnesses no probe obligation.

The tuple is one fixed global associative array, shared by the observer, the
classifier and the controlled tests, cleared in a single operation before each
observation. Fixed and global because Bash cannot pass an associative array by
value, so a per-call container would add a nameref dependency beyond the
capability Step 0 gates.

### What was implemented for Step 1

Two files: the observer in the installer, and its fixture matrix in the harness.

**`src/setups/env/bin/install_pkg.sh`**, the observer (Design Area 1):

- **`CPLX_ELF_OBS`**, one fixed global associative array carrying the normalized
  tuple, with its key set named once so the clear and the fill cannot disagree
  about the field set. Fixed and global rather than passed, because Bash cannot
  pass an associative array by value and a per-call container would need a
  nameref, a second interpreter capability beyond the one Step 0 gates.
- **`elf_obs_clear`**, the clearing rule as a single operation in a single place.
- **`elf_obs_inconclusive`**, the fully defined structural-failure tuple: every
  other field cleared, both probe statuses `blocked`, both values `absent`.
- **`elf_read_le`**, a little-endian read of a field at an offset and width,
  built on `od -j -N`.
- **`elf_observe`**, one structural read: identification and whole-header
  presence unconditionally, then the table-dependent checks only when `e_phnum`
  is nonzero, then the dynamic scan.
- **`elf_probe`**, the two probes, with `skipped` set only by its two structural
  producers so it always means "this object has nothing to read" rather than "we
  did not look".

The size comes from the caller and must describe the bytes at the path actually
read. The production walk does **not** emit it yet; Step 4 must supply it without
silently measuring a symlink while reading its target. The current `-type f`
walk excludes symlinks, and the target verifier asserts that premise.

**`docs/v0.27.0/contract.host-tools.txt`** (new), the allowlist half of the
host-tool rule as committed data: twenty-one external commands, four columns
each, in the same shape as the Step 3 contract corpus. The harness requires every
command-position word in the installer to appear here and every entry here to be
used, so the file cannot drift in either direction, and adding a host dependency
means a reviewed edit rather than a passing silence.

**The allowlist gate** in the harness: `hc_join`, `hc_command_words`,
`hc_launcher_words`, `hc_unsupported_forms`, `hc_file_functions`, `hc_unlisted`
and `hc_unused`, plus the
contract's own validation, six negative shapes, the permitted shapes, a case
proving both halves fire independently, and `host-tool/dd-regression`, which
plants the `dd` call that shipped and asserts the denylist stays blind while the
allowlist names it.

**`docs/v0.27.0/verify.relocation-rpath.sh`**, the `--step 1` suite: the
manifest with its citations, the lawful bases and their mutations, layout
confirmation, the per-entry value cross-check, the alternate pair, all
twenty-five fixtures asserting complete tuples, the clearing rule in both
directions, eight named positive/structural probe witnesses, and the two
axis-local fault producers with bounded doubles. The repair adds the seven
previously absent recipes (`F04`, `F05`, `F10`, `F11`, `F21`, `F22`, `F23`),
independent `readelf` checks for their constructed semantics, an exact
twelve-column assertion on every fixture row, and the first-run freeze record
for `F11`.

**Result on the Debian 12 agent, build 89: 462 cases, 0 failures.** Retained as
`docs/v0.27.0/verify.relocation.step1.debian.txt`. The capture pins the harness,
the installer and the host-tool contract by digest, and all three equal the
indexed files, so it describes what is staged rather than a neighbouring
version. Three earlier builds are superseded and each for a stated reason. Build
69 and its 157 cases ran a sixteen-fixture harness with a denylist-only
host-tool rule. Build 76 was the measuring pass for `F11`, so its
`F11/rpath_value` compared the observation with itself and asserts nothing.
Build 77 and its 335 cases predate the integer guards, so it accepted the two
objects `F24` and `F25` now refuse.

**Result on the deployment target, RHEL 9.8**: the observer, sourced through the
Step 0 seam on the target's own bash 5.1.8, agrees with the target's own
`readelf` on all ten system objects in its corpus, with zero failures. Retained
as `docs/v0.27.0/verify.relocation.step1.target.txt`, produced by
`docs/v0.27.0/verify.relocation-target-observer.sh`, which is committed so the
run is reviewable and repeatable rather than a transcript to be taken on trust.

The target carries no patchelf, which is the design's premise and not a gap: the
structural read needs none, and the probes are the only part that does. What the
target run establishes is the half that must work where the install actually
lands, on an older bash and an older coreutils than the agent's.

### Five defects the runs found

None was found by re-reading the code. All five came from running: three on the
CI agent that can build fixtures, two on the deployment target itself.

- **`dd` is not in the audited host-tool contract.** The first observer read
  bytes with `dd`. The contract lists `od`, `head`, `find` and the shipped
  patchelf, and `dd` is none of them. It was replaced with `od -j -N`, which does
  offset and length natively. The check did not catch this, for a reason
  recorded below.
- **The program donor is a PIE.** `/bin/true` on this agent is `ET_DYN`, so
  every fixture expecting `ET_EXEC` failed. The base now normalises `e_type` by
  explicit mutation rather than inheriting whatever the distribution ships, so
  the matrix does not change meaning with the donor.
- **patchelf declines silently on a relabelled layout.** With `e_type` normalised
  first, patchelf was being asked to add a search path to a PIE layout marked
  `ET_EXEC`; it returned without doing so, and both tag fixtures observed
  `tag_state: none`. The tag fixtures now run patchelf on the unnormalised donor
  and set `e_type` afterwards.
- **The size argument's documented source did not exist.** The observer's comment
  said the size "comes from the caller: the walk already emits it beside the
  NUL-delimited path". The walk emits `-print0` and nothing else. The comment
  described the design rather than the code, in a place no check could see, and
  it was found only by writing a caller on the target and having to decide what
  to pass. The comment now states the obligation, that the walk does not yet meet
  it, and what the size must be.
- **The size must be the size of the bytes that will be READ.** On the target,
  three of ten system libraries are symlinks, and `find -printf '%s'` without
  `-L` reports the link's own size: fourteen bytes for `libz.so.1`. The observer
  was told the object was too short to hold a header and correctly refused it.
  The production walk cannot reach that state today, because `-type f` never
  yields a symlink, and that is now asserted rather than assumed, because a later
  step widening the walk would silently turn every symlinked library
  inconclusive.

### A defect in the checking, not in the code

The target cross-check compared the observer against the target's own `readelf`
over ten objects and printed agreement while three of them had produced no tuple
to compare. Inconclusive objects were excluded from the comparison rather than
counted against it, so the result line asserted agreement about ten objects on
the evidence of seven.

This is the same shape as the aggregate that stood for the object in Step 0, and
as the absent capability evidence that added no failure: a check whose passing
condition is that nothing contradicted it. Inconclusive is now a failure in that
script, and the corpus is real system objects precisely so that every entry has a
right answer and none of them can legitimately be skipped.

### What round 1 left open, and how each was closed

Both items the round-1 review recorded as blocking are closed by work, not by
re-argument. They are kept here rather than deleted, because the shape of each
is a standing hazard for the steps that follow.

**The host-tool check was a denylist where the contract is an allowlist.** A
tool on neither list passed silently, which is exactly what happened when the
observer was written with `dd`: shellcheck was clean, the host-tool case passed,
and a contract violation shipped.

Closed by a plan amendment and then an implementation. The amendment decides the
vocabulary in three parts, because the installer's command words are three
kinds of thing: keywords and builtins are the interpreter and are permitted
without listing, since the deployment contract already pins the interpreter and
a builtin adds no host dependency; functions are read from the installer rather
than listed, so a rename cannot drop one out of the vocabulary; and external
commands are the vocabulary proper, committed as
`docs/v0.27.0/contract.host-tools.txt` in the same shape as Step 3's contract
corpus. The gate checks both directions, so an unlisted word fails and an unused
entry fails too, and the negative cases reject a new dependency in each shape it
can take: plain, `!`-negated, piped, path-qualified, inside a command
substitution within a double-quoted string, and as a `find -exec` target.

Writing it exposed four blind spots in the extraction, each found by running it
rather than reading it. Blanking double-quoted strings before hoisting command
substitutions hid `$(readlink ...)`. Leaving `!` out of the opener class hid
every `if ! cp`, `if ! ln` and `if ! chmod` in the installer. Ignoring `-exec`
hid `rm`, which the installer reaches no other way. And `awk`'s `/\\$/` is a
regex literal meaning "a dollar sign", which silently joined most of the file
into one line; the join is done in Bash now, where there is no second level of
escaping to get wrong.

The rule's limit is stated rather than papered over. It is lexical, so a command
reached through a variable is invisible to it, and `patchelf` is exactly that,
always `"$patchelf_bin"`. Those entries carry `form: indirect` and must name a
resolver function the harness then confirms is defined, which converts an
unprovable claim into a checkable one without pretending the rule is total.

**The repaired matrix had not run on an ELF-capable host, and `F11` was
unfrozen.** Closed by two builds, in that order, because one could not do it.

Nothing specifies which of two `DT_RPATH` tags patchelf reports, so `F11`'s
expected value could not be written in advance. Build 76 ran the row in its
`@freeze@` state, where the expectation is assigned from the observation, and
measured `/opt/cplx-probe/rpath-b` under patchelf 0.19.1. That run asserts
nothing about that field and is not cited as though it did. The literal was
written into the row and build 77 re-ran it as a real comparison, and build 89 repeats it: **462 cases, 0
failures**, harness, installer and contract each matching the indexed file by
digest.

The freeze mechanism is kept, because a later step may meet another value no
specification predicts, and it is now bounded by two cases.
`fixtures/all-values-frozen` asserts that no row is currently in the state where
a comparison proves nothing, so the mechanism cannot be left switched on by
accident. `fixtures/table-readable` asserts the reader sees exactly twenty-five
rows, and it earned its place immediately: the first reader matched the
probe-witness table too, which shares the `F##|` prefix with a different column
layout, and the second re-opened its range on this function's own delimiter text
and ran to end of file. Both returned thirty-one, both would have reported zero
unfrozen rows, and neither would have been visible without a count to check.

### What round 2 left open, and how each was closed

Both items are closed by work. They are kept here because each is a standing
hazard for the steps that follow, and because both were the same shape: a check
reporting zero from a place it could not see.

**Unsigned ELF64 values decoded into signed Bash arithmetic.** ELF64 offsets and
sizes are unsigned 64-bit; Bash arithmetic is signed 64-bit. A `p_offset` of
`0xFFFFFFFFFFFFFFF0` decoded to `-16`, and `-16 + 8` is less than any file size,
so a segment starting past the end of the file finished with
`structural_status: ok`. Two extents that each decoded exactly could also
overflow when added: `2^62 + 2^62` reads as `-9223372036854775808`.

Closed in two places rather than one, because the two failures are different.
`elf_read_le` now refuses any value at or above `2^63`, since everything this
domain reads is bounded by a real file size and such a field is malformed rather
than merely large; the caller's existing read-failure path is already the right
response. And every extent is now compared against the remaining file,
`p_filesz <= size - p_offset`, never by adding an offset to a size. Subtraction
cannot overflow here because the left side is proved inside the file first.

`F24` and `F25` witness the two guards separately. `F24` carries an offset at
`2^64-16` and is refused by the reader. `F25` carries two extents at `2^62`,
each of which decodes exactly, so it passes the reader and must be refused by
the extent computation instead. A single fixture would have exercised one guard
and left the other with none, which is the arithmetic that has failed this
effort before.

Both fixtures were measured against the **pre-fix** observer as well, which
reports `structural_status: ok` for each. They are regression witnesses rather
than restatements of what the code now does, and the record says which run
established that.

**The allowlist rule was blind to three ordinary direct positions.** Its opener
set did not include a `case` arm's `)`, a brace group's `{`, or a command behind
`NAME=value` assignment prefixes. An unlisted external in any of those left
`host-tool/allowlist-unlisted` at zero.

This is the second time a check in this step reported zero because it could not
see, after the extraction that hid `$(readlink ...)`, `if ! cp` and `find -exec
rm`. The openers now cover all three, each is a named reject case, and matching
allow cases prove the wider rule did not start rejecting legitimate shapes. The
contract file's header now states this as a second known limit beside the
lexical one, because the first version stated only the limit that was already
understood, and the unstated one is exactly where the next gap will be.

### What round 3 left open, and how it closed

One item, and it is the most instructive of the five because it was caused by
the previous round's repair.

**Widening the openers broke the rule in the other direction.** Putting `{` in
the opener character class, where the following blank was optional, made every
`${parameter}` read as a command position: `plain_assignment=${value}` reported
`value` as an unlisted external. A bare `)` had the same shape of problem,
making `$(basename x)suffix` report `suffix`, and `arr=(one two three)` reported
its elements.

Closed by delimiting the two openers that need it and neutralising array
literals. `{` opens a group only when a blank follows, because `{` is a reserved
word and a reserved word must be delimited, so `{ cmd; }` is a group and
`${value}` is an expansion. `)` closes a case arm only when a blank follows. The
`=(...)` form is blanked before the openers apply.

That repair carried a cost I accepted and should not have: requiring a blank
after `)` meant an unspaced `a)cmd` arm was not seen, and I recorded it as a
stated narrowing with a passing case. Round 4 rejected that, correctly, and the
next section is where it is closed. It is left here rather than rewritten,
because the sequence matters: the fix for over-reporting introduced a fail-open,
and the way it was written up made the fail-open look deliberate.

**The aggregate allow case is why this could hide.** The reject side had always
been one case per shape; the allow side was a single verdict over a file of
eight shapes. A single verdict can only say that something was wrong, and it
could not have named `${value}` in any event, because that shape was not in the
file. The allow side is now one case per shape and carries the expansion,
concatenation and array forms explicitly.

Splitting it paid for itself in the same run. `myfun arg` failed immediately,
because the function definition and its call had been two lines of one blob and
were now two separate probes. That was a fixture defect rather than a rule
defect, and the aggregate had been concealing it: the case passed because the
definition happened to sit in the same file as the use.

The general lesson, and the reason this is recorded rather than summarised: a
check that reports one verdict over many inputs cannot tell which input it was
right about. Both sides of this rule are now per-shape.

### What round 4 left open, and how it closed

One item, and it is the one worth reading if only one of these sections is read.

**The rule was fail-open, and the harness asserted the fail-open as a pass.**
Round 3's repair made `)` an opener only when a blank follows, so that
`$(basename x)suffix` would stop being read as a command called `suffix`. The
price was that `a)cmd` was never seen. That is valid Bash which calls `cmd`, so
an unlisted external could sit in an ordinary direct command position with
`host-tool/allowlist-unlisted` reporting zero.

I recorded that as an accepted narrowing and wrote a case,
`host-tool/known-narrowing-unspaced-case-arm`, which PASSED while the shape was
invisible. The reasoning was that a hole with a case asserting its boundary is
better than a hole nobody has noticed. That reasoning is wrong, and the review
was right to reject it: a passing case makes a gap read as a decision, and the
suite's green line then covers a position the rule cannot see. Every other
defect in this step was something a check missed. This is the only one a check
was actively concealing.

Closed by removing the other meaning of `)` instead of narrowing the opener.
Every `$(` is already hoisted to the start of its own line, so the first `)` on
such a line is the substitution's close; deleting it positionally needs no
nesting count and no case-region parser. Both `a)cmd` and `a) cmd` are now seen,
and `$(basename x)suffix` is still one word.

The two obligations pull in opposite directions, so they are asserted as a pair
rather than one at a time: `host-tool/unspaced-case-arm-is-seen` and
`host-tool/substitution-close-is-not-an-opener`. A future repair that buys one
by giving up the other fails the suite instead of being written up as a trade.

**One requirement of that family is not a narrowing at all**, and grouping it
with the other was itself a small piece of imprecision. `{` opens a group only
when a blank follows, because `{` is a reserved word and a reserved word must be
delimited: `{ls; }` is a Bash syntax error rather than a call to `ls`. The
contract's header now separates the exact requirement from the withdrawn one and
records why the withdrawn one was wrong to claim.

### What round 5 left open, and how it closed

One item was raised and two were closed, because probing for the class of the
reported defect found a larger one underneath it.

**The reported defect: removing one close per line is not nesting-safe.**
`$(basename $(dirname x))suffix` hoists to a line carrying two closing parens.
Deleting the first closes the inner substitution and leaves the second to open
`suffix`. The suite passed because every substitution shape in it was
single-level, so the case that existed could not have failed.

I had asked in round 5 for exactly this: a shape where the positional deletion
was wrong. The reviewer named it. What I should have done instead of asking was
write the two-level case myself, since "I am convinced by construction but have
no case that would fail if I were wrong" is a description of an untested claim.

Closed by removing the need to count at all. `)` has two meanings and only one
of them is a command position: the end of a `case` PATTERN. That meaning is
recognised directly, from a line start, a `;`, a `&` or a `case`'s `in`,
followed by a run containing no parenthesis, no `$` and no separator, and it is
rewritten to `;`, which is already an opener. `)` then has no opener role, so a
close of any construct at any depth opens nothing by construction rather than by
arithmetic. Block terminators are excluded first, because `esac)`, `fi)`,
`done)` and `})` end a construct inside a substitution rather than a pattern.

**The defect found underneath it, which no round reported: keywords hid their
commands.** `grep -o` returns non-overlapping matches. An opener followed by a
keyword therefore consumed the keyword as its command word, and the real command
that followed had no opener left of its own. `if true; then zzunlisted -x; fi`
reported `if then fi` and never `zzunlisted`. So did `do`, `else`, `elif`, and a
command directly after `if` or `until`.

This was present from the rule's first version and survived five review rounds.
It survived because every reject shape in the matrix had been written with the
unlisted command in the FIRST position after the opener, which is the one
arrangement that cannot expose it. A matrix built by listing the openers will
test each opener once and never test what follows one.

Closed by making the command-introducing keywords transparent: after an opener,
a run of `if`, `then`, `else`, `elif`, `do`, `while`, `until` or `time` is
skipped before the command word is taken. Five reject shapes now cover those
positions.

It also had a visible consequence in the installer itself. With keywords
transparent, `read` becomes a command word for the first time, from
`while IFS= read -r line; do`: previously `while` was taken as the command and
`read` was never seen. It is a builtin, so the contract needed no entry, but the
rule had been blind to a real command word in the file it exists to audit.

### What round 6 left open, and how it closed

Two items were raised and three were closed, because probing the class found one
the round had not named.

**Non-literal `case` patterns and `coproc`.** A `case` pattern is not required to
be a literal word. `case $x in $pat) cmd ;; esac` and `case $x in \)) cmd ;;
esac` are both valid, and both hid the command behind them: the pattern class
excluded `$`, and an escaped `\)` was read as a real parenthesis. `coproc` was
outside the transparent keyword set for no reason other than being rare.

Closed by admitting `$` and escaped parens in the pattern class, substituting
escaped parens out first so they cannot be read as real ones, and by adding
`coproc` beside the other keywords that introduce a command. `(` and `)`
themselves stay excluded from the class, which is what still keeps
`$(basename x)suffix` from matching.

**Commands launched through a permitted launcher.** `command NAME`, `exec NAME`,
`builtin NAME` and `xargs NAME` all run NAME, and all were read as arguments.
The inconsistency is the sharp part of this finding: `find -exec NAME` had been
handled from the start for exactly that reason, and the same argument was never
applied to the other four. A host dependency introduced through a permitted
launcher is still a host dependency, and the launcher's own presence in the
vocabulary says nothing at all about what it runs.

Closed by collecting launcher targets the way `-exec` targets were already
collected, skipping option words and any following word that is not a plausible
command name, so `xargs -0 -r sed` yields `sed` and `xargs -I {} sed` is not
derailed by `{}`.

**The third, found by probing rather than reported: a leading redirection.**
`>/dev/null cmd` and `foo &>/dev/null cmd` both left the command with no opener,
because a redirection is neither an opener nor something the rule skipped. It is
now skipped like an assignment prefix.

**And one that is stated rather than closed.** A command inside `eval "..."` is
invisible, because the string is blanked before the openers run and no lexical
rule reaches inside it. That is the same limit as a command reached through a
variable, not a new kind of gap, and the installer uses neither form. It is
recorded in the contract beside the other limits rather than left for a later
round to find.

**What this round changed about how the record is kept.** The contract file now
states the COUNT of times the openers have been wrong, seven, rather than
describing the current opener list. The list keeps changing and has been wrong
in both directions; the count is the honest measure of how much to trust it.
Four of the seven were found by review rather than by the suite, and that ratio
is the part worth carrying into Step 2.

### What round 7 left open, and how it closed

Round 7 did something the six rounds before it had not: it named a finite exit
condition rather than a next defect. That is worth recording separately from the
items, because the previous rounds had each closed one shape and revealed
another, and a list of shapes has no end.

**The oracle accepted the wrong token.** Every reject case asked whether the rule
named _some_ unlisted word, not whether it named the one the case planted. So the
extractor and the oracle could be wrong together, and they already were:
`xargs -P 4 zzunlisted` returned `4`, which is unlisted, so the case passed while
the rule was reading an option operand instead of the command. A green matrix
under that oracle proved less than it read as proving, and every shape added in
rounds 5 and 6 inherited the same weakness.

This is the same defect as an unfrozen fixture row, in a different place: a
comparison whose expected side is not pinned. The fixture matrix had been fixed
for that two rounds earlier and the host-tool matrix had not, which is the kind
of inconsistency that only shows up when someone asks the second question.

Closed by requiring the exact planted dependency, compared by basename so a
path-qualified shape still counts.

**Launcher option operands.** `xargs -P 4 cmd`, `xargs -I {} cmd` and
`exec -a name cmd` each put a non-option word between the launcher and the
command, and a rule that skipped only `-`-prefixed words reported `4`, `{}` and
`name` as host dependencies. Which options take an operand is a fact about each
launcher rather than a rule of thumb, so it is declared in the contract beside
the launcher: short letters and long names, per launcher.

`builtin` was removed from the launcher set. `builtin NAME` runs a shell builtin
by definition and can never reach an external, so modelling it as a launcher had
the rule report interpreter vocabulary as a host dependency. It was added in the
previous round by analogy with `command` and `exec` without checking whether the
analogy held.

**A fail-closed boundary.** `eval "..."` and a launcher whose target is an
expansion are outside what any lexical rule can read. The previous round stated
that in the contract and stopped there, which meant a later step could add one
and the gate would keep reporting zero. The gate now refuses a file containing
either form, and two cases prove the refusal fires rather than merely existing.

**The coupling.** A declared launcher must itself be permitted, and a permitted
tool known to run its argument must be declared as a launcher. The second
direction is the one this record flagged two rounds ago and left open, on the
grounds that "which entries are launchers" is a fact about each tool rather than
about the file. That reasoning was right about where the fact lives and wrong
about what follows: the fact belongs in the contract, not in the harness, and
once it is there the coupling is mechanical. Adding `env` to the vocabulary
without declaring it now fails the gate by name, which was verified against a
mutated contract rather than reasoned about.

**Two syntax gaps closed alongside them**: extglob case arms such as `@(a|b))`,
valid where `extglob` is enabled at parse time, and a spaced leading
redirection.

### What round 8 left open, and how it closed

Three compositional gaps, and the third was the one that had been mine to see.

**Clustered short options.** `xargs -rP 4 cmd` and `exec -ca name cmd` selected
`4` and `name`. The table-driven parser assumed any option word longer than two
characters carried its own operand, which is true of `-n1` and `-I{}` and false
of a cluster of flags ending in an operand-taking letter. The letters are walked
now, so `-rP` finds `P` at the end of the word and takes the next one, while
`-n1` finds `n` with more characters after it and takes none.

The lesson is narrow but real: I generalised from two examples that happened to
share a shape, and the generalisation was about word length rather than about
what the letters mean.

**A boundary that only matched bare forms.** `eval` and a computed launcher
target each had a pattern of their own, anchored at the start of a command, so
`if eval "$p"` and `command -v "$x"` walked past a check whose whole purpose is
to refuse what it cannot read. The command-word extraction already understood
keyword and prefix positions, and the launcher extraction already understood
option semantics; the boundary was written without using either. It now uses
both, which is why `VAR=1 eval "$p"` and `xargs -rP 4 "$x"` are covered without
adding a third pattern.

**The curated list.** In round 8 I named `HC_KNOWN_LAUNCHERS` as the residual
and said I did not know a mechanical source for it: deriving it from the system
fails across two distributions, deriving it from the vocabulary is circular. Both
of those were true and the conclusion was still wrong, because there was a third
option I did not consider: stop deriving it and make every entry answer.

The list is gone. Each entry carries a `runs-argument` column with no default,
so a tool cannot be permitted without someone deciding whether the rule has to
follow it, and the decision is reviewed where the tool is rather than in a list
somewhere else. Both coupling directions now hold against the contract alone: a
launcher's owner must be permitted, and an entry that says yes must own a
launcher row.

This is the second time in this step that the repair was to move a fact into the
data rather than to improve the code that guessed it. The first was the launcher
option table itself, two rounds ago. Both times my stated reason for not doing it
was that the fact belonged to the tool rather than to the file, and both times
that was exactly the argument for putting it in the file.

Two controls were run against mutated contracts rather than reasoned about: an
entry declaring `yes` with no launcher row is named and fails, and an entry
answering neither `yes` nor `no` is counted and fails.

### What round 9 left open, and how it closed

Three finite gaps, and one repair nobody asked for.

**Option operands can be optional.** The table named which options take an
operand and had no notion of whether that operand may be omitted. GNU
`xargs -E eof-str` requires its operand and takes the next word;
`xargs --eof[=eof-str]` and `xargs -e[eof-str]` accept an optional one that must
be attached, so `xargs --eof cmd` runs `cmd`. Treating every operand as required
swallowed the command in those forms, and the reject matrix had only ever used
the required ones.

Closed by spelling optionality with a `?` suffix in the contract, on a short
letter or a long name, and by walking clusters so an optional letter never
consumes the next word. All seven option forms are now reject shapes: bare,
clustered, attached, required-separate, long-required-separate,
long-optional-bare and short-optional-bare.

**`eval` through a dispatcher.** `command eval "$p"` and `builtin eval "$p"` both
run eval, and neither puts `eval` where the command-word extraction looks: the
first has a literal launcher target, and the second is deliberately not a
launcher at all. The boundary now knows the three dispatchers that can reach the
`eval` builtin.

The distinction is worth keeping straight rather than blurring: `builtin` is not
a host-tool launcher and never will be, because it can only reach builtins. It
can reach that one, so the boundary knows about it while the vocabulary does not.
A rule about host tools and a rule about interpreter facilities are different
rules that happen to share a scanner.

**Contract uniqueness.** Nothing stopped a name appearing twice. A duplicated
entry can answer `runs-argument` both ways, and every consumer reads whichever
row it reaches first, so the contract would be self-contradicting while each
individual check still passed. No entry name and no launcher token may now appear
twice, and the control shows the contradiction it prevents rather than describing
it: a duplicated `sed` answering both `no` and `yes`.

**The repair nobody asked for.** The option semantics were duplicated, once in
the launcher extraction and once in the boundary. Both copies were correct when
written, and both would have needed the optional-operand fix. They are one shared
awk program now.

That is the same failure mode this step was caught by in round 3, when the allow
side was a single aggregate verdict and the reject side was per-shape: two things
that should have been one, drifting. I did not notice the duplication when I
wrote the boundary, because writing the second copy felt like reuse rather than
like forking.

### What round 10 left open, and how it closed

Two gaps. The first is the one worth reading, because it is a defect in what the
record claimed rather than in what the code did.

**The controls did not exist.** The round 10 record said the contract's
consistency rules were exercised against mutated contracts. They were not. I had
run those mutations in a shell while developing, seen them behave, and written
the record as though the suite contained them. It did not: the rules only ever
ran over a clean file, every one reported zero, and nothing in the suite
established that any of them could report anything else.

That is precisely the failure this document has been naming since round 1, and
it arrived in the section describing how the failure had been avoided. A rule
that has quietly stopped detecting anything passes a suite built only from clean
inputs, and so does a rule that was never wired up.

Closed by making each rule a function and adding ten controls. Five mutate a copy
of the real contract and require the rule to REPORT: a duplicated entry, a
duplicated launcher token, an entry answering neither `yes` nor `no`, an entry
saying `yes` with no launcher row, and a launcher owned by nothing. Five require
silence on the real contract, because a rule that reports on everything is no
more useful than one that reports on nothing, and only the pair distinguishes a
working rule from either.

The refactor matters as much as the controls: the real check and the control now
call the same function, so a control cannot pass against a second copy of the
rule that the gate does not use.

**Two dispatcher facts were wrong, both reasoned rather than measured.**
`builtin -- eval "$p"` runs eval and slipped past, because the command word was
taken as the token straight after the dispatcher and that token was `--`. And
`exec eval "$p"` does not run eval at all: exec replaces the shell with an
external program of that name, there is none, and it exits 127.

I had added `exec` to the dispatcher set by analogy with `command` and `builtin`,
and shipped that claim in a retained capture before testing it. Both facts took
one command each to check. The pattern is the same one as `builtin` in the
launcher table two rounds ago: three things that look alike, and I generalised
across them without asking whether the resemblance held.

### New types or classes introduced for Step 1

None. This is a Bash effort: no classes, no modules. What is introduced is one
global associative array, `CPLX_ELF_OBS`, and five shell functions in the
installer: `elf_obs_clear`, `elf_obs_inconclusive`, `elf_read_le`,
`elf_observe` and `elf_probe`.

In the harness, which is test code rather than production: seven functions
implementing the allowlist rule (`hc_join`, `hc_command_words`,
`hc_launcher_words`, `hc_file_functions`, `hc_unlisted`, `hc_unused`, plus the
denylist-side command reader) and one reading the fixture table
(`fixture_rows`). No new file type and no new data structure: the contract is a
pipe-separated text file, read line by line.

### Architecture check for Step 1

DDD-Hexagonal does not apply to a Bash toolchain. The architectural property that
does is the deployment contract, that `install_pkg.sh` runs alone from a bare
account, and it holds: the observer adds no file, no sidecar and no new host
tool once `dd` was removed. The observer is a set of functions above the main
boundary, so sourcing the installer reaches them without performing an install.

The separation the plan cares about is kept: the harness never reimplements the
observer, it calls the production function through the seam, and the fixtures
are validated by `readelf` and the manifest, neither of which shares the
observer's beliefs about where a field lives.

No, there is nothing outstanding to address at this step. Every contract
consistency rule is a function exercised by a control that mutates the real
contract, so a rule that has stopped detecting anything fails rather than
passing on a clean file; the boundary skips flags and `--` before taking a
dispatcher's command word; and `exec` is out of the dispatcher set because it
cannot reach the `eval` builtin, which was measured rather than reasoned.

### Performance check for Step 1

The observer reads a bounded number of fixed-width fields per object: the
identification bytes, six header fields, then one pass over the program header
table and one over the dynamic list. Both are linear in the object's own
structure and neither iterates a collection inside a walk of the same
collection, so the walk stays linear in the number of objects. No O(n^2) or
O(n log n) computation is introduced.

Each field read is one `od` invocation, so an object with a large program header
table costs one process per field. That is a constant factor rather than a
complexity change, and the plan's Step 4 timing checkpoint is where it will be
measured against the Step 0 baseline rather than estimated here.

No, there is no performance issue that needs addressing at this step.

### Unit test coverage check for Step 1

The 100% unit-coverage rule targets a Python tree this repository does not have.
What stands in its place is the fixture matrix. All twenty-five planned rows
are now present, every row has twelve mechanically checked columns, every row
asserts the complete tuple, and the named witness list includes the mixed-tag
preference and both `skipped` producers as well as the two axis-local fault
producers. Structurally, no planned guard or probe obligation is omitted.

The ELF fixture coverage is evidenced rather than only defined: build 89
executed all twenty-five rows on the CI agent with 462 cases and no failures,
`F11` completed its measure-freeze-rerun lifecycle across builds 76 and 77, and
`fixtures/all-values-frozen` asserts that no row is left comparing an
observation against itself.

The matrix now carries both signed-overflow boundary fixtures, `F24` for a value
the reader cannot represent and `F25` for a pair whose sum overflows, and the
host-tool negative matrix names ten shapes including the three ordinary direct
positions the extractor previously could not see.

The host-tool allow matrix now covers the collision between the `{` opener and
`${parameter}` expansion, along with the concatenation and array-literal forms,
one case per shape on both sides of the rule.

No, there is no coverage gap. Ten controls exercise the five contract
consistency rules in both directions, five requiring the rule to report on a
mutated copy of the real contract and five requiring silence on the real one,
and each control calls the same function the gate calls rather than a second
copy of the rule. The boundary carries thirteen shapes including `builtin --`,
`command --` and a flagged dispatcher. Build 89 exercises all of it: 462 cases,
zero failures, forty-four reject shapes, thirty-one allow shapes, thirteen
boundary shapes and ten controls, with the harness, the installer and the
contract each matching the indexed file by digest.

### Feature integrity for Step 1

No existing feature or reporting capability is impaired. The observer is defined
and never called by the executed path: `fix_elf_paths` is unchanged, still reads
the four magic bytes, and still reports its mixed count. The Step 0 baseline is
unaffected, which the same build re-measures, and the previous effort's
copy-engine selection is untouched. Preventive integrity remains incomplete:
the boundary permits dynamically evaluated code through `builtin -- eval`, and
the uniqueness checks are not protected by controls that fail when their
rejection logic is broken.

---

## Analysis of Step 2 implementation state

Yes. Step 2 has been fully implemented.

The classifier, controlled matrix, bridge, and recorded inventory satisfy the
revised behavioral criteria, and the repository lint gate plus shared resolver
dependency are available and green. The executable verdict now agrees with the
criterion boundary: the harness asserts what Step 2 owns, that every residual
program was classified, and reports a residual whose case is not 7 as a note
naming it for Steps 4 and 6. Build 95 answers the mandatory Linux command at
**355 cases, 0 failures, OBJECTIVE MET**, with `tools/python/root/a.out` stated
in full and assigned downstream rather than suppressed.

The other round-15 boundary work is closed. `src/utils/lint_shell.sh` checks all
44 tracked non-documentation shell scripts and exits 0, the plan-scoped
ShellCheck and request-scoped `bash -n` commands exit 0, and the committed shared
resolver support passes its focused 271-test suite.

### Goal for Step 2

Implement the ordered classifier as a decision over the Step 1 tuple, callable
without running an install, with the exact-target tests placed before the broad
builder-anchored test.

### Step 2 improvement expectations

Each of the seven cases is reachable and separately exercised. The two `$HOME`
overlaps classify deterministically, a v0.26.0 tuple as case 5 and a
this-version tuple as case 3, where an unordered set of predicates would leave
both ambiguous.

**Every controlled row is a complete, contract-valid tuple**, not an occurrence
of a token. The earlier phrasing asked for "each of the four probe statuses",
which does not exist: there are two independent status fields, each drawn from
`ok`, `skipped`, `blocked` and `failed`, with two independently present or absent
values beside them, and a flat token checklist can be satisfied without ever
constructing either axis-local failure. So each row clears the array, populates
the exact key set with nothing missing and nothing extra, states both statuses
and both value-presence facts with each literal value where present, and is
checked against the tuple invariants before the classifier is invoked. The
exact-key rule is load-bearing in Bash, where an unset associative-array key
expands to the empty string, so a forgotten `interp_probe_status` is
indistinguishable from a deliberate empty one and the classifier would branch on
a value nobody wrote.

The matrix covers the seven ordered cases, both `$HOME` overlaps, both successful
tag forms, ambiguity, structural inconclusiveness with every other field cleared
and both probes `blocked`, both `skipped` producers, and **both axis-local
`failed` combinations**, without demanding the Cartesian product of combinations
the observer cannot produce.

**The producer-to-consumer bridge closes the gap neither layer sees alone.** Step
1 proves a tuple is produced and Step 2 proves one is consumed, and nothing
previously showed that the controlled inputs conform to the contract the producer
emits. Representative real Step 1 observations therefore cross the seam, a
library, a no-dynamic object, `DT_RPATH`, `DT_RUNPATH`, an ambiguous object, one
structural rejection, and the two fault cases, each yielding the same outcome as
its corresponding controlled row. A disagreement means the controlled rows have
drifted. No controlled tuple and no controlled double counts as evidence for both
production and consumption.

Against the `develop#24` inventory the classifier selects the recorded half of
the set stated once in the plan: the 110 flagged libraries as case 4, the python
program asserted by name, and the enumerated git objects. The revised plan keeps
the residual every-other-program case 7 invariant but binds it to Steps 4 and 6,
which hold the staging tree and deployed archive. The plan had contradicted
itself here, this step saying every program but python was untouched while Step 6
said python and git; the design settles it in favor of python and git, and the
git objects are enumerated rather than counted because a count is a fact about
one inventory snapshot.

### What was implemented for Step 2

**The ordered classifier, in `src/setups/env/bin/install_pkg.sh`.** One function,
`elf_classify TARGET_RPATH`, and one global, `CPLX_ELF_CASE`. It sits between
`elf_probe` and `find_patchelf`, above the main boundary, so sourcing the
installer reaches it without performing an install. It reads the Step 1 tuple and
writes nothing else.

The seven cases are the design's, in the design's order, each with the reason for
its position beside it:

- case 1 has three producers and no fourth: a structural status that is not `ok`,
  an rpath probe that `failed`, and `tag_state: ambiguous`. `skipped` is
  deliberately absent, so an object with no dynamic section reaches case 2 and
  never case 1. `blocked` is tested even though the observer cannot emit it
  beside a successful structure, because the rule is that a probe which never
  answered may not reach a benign later case, and `absent` holds no builder
  anchor, so the fall-through would otherwise be case 7;
- case 2 is `has_dynamic: no`;
- case 3 is the tag AND the value together, which is what leaves a matching
  string under `DT_RUNPATH` to be rewritten rather than skipped;
- case 4 is `ET_DYN` with no `PT_INTERP`, with neither the suffix nor a SONAME in
  the test;
- cases 5 and 6 are **program populations** and are gated on the kind before
  their own test, so an `unsupported` kind reaches case 7 whatever value it
  carries. Case 5 is then the exact target under `DT_RUNPATH`, bounded to a
  v0.26.0 prefix because `build_elf_rpath` is unchanged here, and case 6 is the
  pass's current builder-anchor test on the same value;
- the additive promise still holds where it was written to hold: it says no
  **program** the current guard covers is dropped, and case 4 has already taken
  `ET_DYN` with no `PT_INTERP`, so a `dyn` reaching case 5 carries a `PT_INTERP`
  and an `exec` is a program by `e_type`. An earlier version read that promise as
  covering every ELF kind and tested the value alone, which review round 2
  refused;
- case 7 is everything else, so the RPM-extracted programs and the vendored
  patchelf are excluded by rule rather than by a name check.

The classifier is not wired. `fix_elf_paths` is untouched, so an executed install
behaves exactly as it did after Step 1.

**Three case layers, in `docs/v0.27.0/verify.relocation-rpath.sh`.** The `--step`
dispatch accepts `2`, and the suite is reached through the same seam Step 1 uses.

The **controlled rows** are twenty-four complete tuples, `C01` to `C24`, each
stating all nine fields, the target it is judged against and its expected case.
`step2_load_row` clears the array by REMOVING its keys rather than by writing
empty strings, so a row that forgot a field leaves a missing key instead of an
indistinguishable empty one, and `step2_tuple_invariants` refuses it before the
classifier is invoked, on a reason beginning `TUPLE` so the refusal reads as a
defective test rather than as a classification. The invariant set is the
design's: the closed vocabularies, the fully defined structural-failure tuple,
`skipped` checked in both directions against its two producers, and a value that
is `absent` unless its own probe answered.

Eight negative controls mutate one valid tuple each and require that refusal: a
missing key, an extra key, `blocked` beside a successful observation, an unearned
skip, a missing skip, a value surviving a probe that did not answer, a structural
field surviving an inconclusive read, and a tag with no dynamic section.

The row groups the plan names are asserted over the table rather than claimed in
prose: each of the seven cases expected somewhere, two `$HOME` overlaps, both
successful tag forms, ambiguity, structural inconclusiveness, both `skipped`
producers, and **both axis-local failure combinations**, which is the pair a
four-token checklist does not require. The id set is checked for gaps and
duplicates, since a count of twenty-three is satisfied by one row written twice
and another missing.

The **bridge** is ten rows over seven real Step 1 subjects, `F01`, `F03`, `F04`,
`F06`, `F07`, `F10` and `F16`, plus the `D01` and `D02` doubles over `F01`. Each
subject is planted by the Step 1 recipe of that id rather than by a second recipe
written to the same description, which is why the recipes moved into shared
helpers. Each observed tuple is held to the same invariant checker the rows are
held to, and each classification must equal both its literal expected case and
the case its named controlled row produced, so a drift on either side of the seam
fails rather than passing quietly on both. `F06` and `F07` cross twice, once
against a target they hold and once against one they do not, which is what
exercises the exact-target comparison in both directions.

The **inventory** walks a real archive tree as production walks it, computes the
target with the production `build_elf_rpath` under the declared prefix, and
classifies every ELF without running an install. It compares against a
**recorded oracle**, `docs/v0.27.0/inventory.develop-24.txt`, rather than against
the tree it is checking:

- the reader requires exactly the 110 distinct recorded library paths, so a
  truncated, padded or duplicated record fails there rather than on the tree;
- every recorded library must be walked and answer case 4. Case 3 is refused: it
  is the state of a tree this version already converted, which is not the tree
  the criterion names;
- every **walked** library is collected independently of the record and must
  answer case 4, which is what stops one being skipped in silence;
- the recorded python path must be walked and selected, asserted by name;
- the recorded git paths must be walked and selected. Location is not population
  identity: an object the record does not name is residual whatever tree it sits
  in, and passes only as case 7;
- every residual program must answer case 7 **exactly**, not merely "not
  selected", since cases 1, 2 and 3 are outcomes the plan does not allow for that
  population.

The judgements live in `step2_inventory_assert`, which the thirteen controls
drive as well, so a rule that has quietly stopped detecting anything fails a
control rather than passing on a tree nobody could check. Eleven break one field
each and require the exact `ORACLE` or `INVENTORY` refusal; two require silence,
on a well-formed state and on an unrecorded case 7 program under the git tree.

An unrecorded walked library is counted and named rather than failed, and the
reason is measured rather than preferred: develop#24 flagged 110 of 388, "55 per
root and none from the venv", so the record names the flagged subset and the
archive's library population is larger by construction.

Without the record the criterion is **unanswered** rather than derived. Case 1
objects are still counted and named, because a malformed library is not
recognised as a library and would otherwise satisfy the preservation rule by
being excluded from nothing.

**Shared fixture planting.** `resolve_fixture_donor`, `plant_fixture_base`,
`plant_fixture` and `plant_patchelf_double` were extracted from `step1_suite`
without changing a recipe: the twenty-five recipe bodies moved verbatim, with
each `continue` becoming `return 1` and the caller doing the `|| continue`. Step
1's assertions are unchanged.

**A third harness outcome.** `UNANSWERED` and exit code 5 separate "every case
passed but an obligation could not be asked" from both a pass and a code failure.
The inventory is its first user: without the recorded oracle or the archive it
reports what to pass rather than being silently skipped.

**Platform-gated host-tool corpus.** The eighty-three-shape allowlist corpus runs
on Linux, where the retained measurement is 4.5 seconds, and is recorded as
unanswered on other platforms with the exact Linux command that can answer it.
That keeps the corpus in every Linux step invocation while allowing the exact
Step 1 and Step 2 entry points to terminate on the authoring host.

### What the Debian 12 agent answered for Step 2

Three builds closed most of what this section listed as owed, and the record
states what they measured rather than that they happened.

| Gate | Result |
| --- | --- |
| Step 1 re-run, build 95 | **462 cases, 0 failures, OBJECTIVE MET**, retained as `verify.relocation.step1.debian.txt` |
| Step 2, build 95 | **355 cases, 0 failures, OBJECTIVE MET**, retained as `verify.relocation.step2.debian.txt` |
| the producer-to-consumer bridge | runs, for the first time on any host |
| the develop#24 oracle | recorded as `inventory.develop-24.txt` and read: all its assertions pass |
| `shellcheck` on the agent | absent from that image, so the gate's only result is the local one |

**The oracle.** 272 rows: the 110 flagged libraries, the python program, and 161
git programs. The library rows are the ABI contract probe's flagged set, 388
ELFs inventoried and 110 flagged, 55 per root and none from the venv, which is
the develop#24 measurement reproduced. Build 24 itself is long gone, the job
retains ten builds, so the set was re-measured rather than recovered. It was
recorded in one build and read by a later one, never derived in the run that
checks it.

The git population is the git install and **not** the sysroot shipped beside it.
Those 74 binutils and glibc programs are residual, and the run measured that
rule holding: they all answer case 7 and none appears in the failure. Recording
them would have demanded they be selected, inverting what rounds 4 and 5 settled.

**The one failure, and it is not the classifier.** Build 91 failed 76 residual
entries. 75 were relocatable objects and static archives, the C and GCC startup
objects, the sanitizer preinit objects, `libmcheck.a` and `python.o`. None
carries a `PT_DYNAMIC`, none can be given a search path, and the pass would
never rewrite one, so demanding case 7 of them asked a question the pass never
asks. The walk now judges only `exec` and `dyn` objects as residual programs,
through `step2_inventory_is_program`, with four controls over that boundary in
both directions: two requiring an unsupported and a cleared kind to fall out,
two requiring `exec` and `dyn` to stay judged. What falls out is counted and
named, because a preservation rule is satisfied most easily by a population
nobody looked at.

The arithmetic is exact: 76 = 75 excluded and named, plus one that remains.
Builds 91 and 92 walked the same 675 objects and reported the same 26 case-1
objects, so the fix reclassified the population rather than shrinking it.

**`tools/python/root/a.out` answers case 5, which is selected.** A stray build
artifact shipped inside the archive would be given a search path by the pass.
Either the archive should not carry it or the program gate should not select it.

It is reported and not excluded. Step 2 asserts what Step 2 owns, that the
classifier answered for every residual program, and names a residual whose case
is not 7 as a note carrying it to Steps 4 and 6, which hold the population
assertion unqualified. That is a boundary, not a suppression: excluding the
object, or quietly dropping the line, would be the count-driven change this
effort has refused since Step 0. Two controls hold the boundary in place, one
refusing an unclassified residual and one requiring the other case to be
accepted here, so a drift back to failing it is caught by the suite rather than
by a later reader.

### New types or classes introduced for Step 2

None. This is a Bash effort: no classes, no modules. What is introduced in the
installer is one global, `CPLX_ELF_CASE`, and one function, `elf_classify`.

In the harness, which is test code rather than production: four shared planting
functions extracted from Step 1 (`resolve_fixture_donor`, `plant_fixture_base`,
`plant_fixture`, `plant_patchelf_double`) and eighteen Step 2 functions
(`step2_literal`, `step2_load_row`, `step2_tuple_invariants`, `step2_rows`,
`step2_bridge_rows`, `step2_inventory_oracle`, `step2_in_set`,
`step2_missing_members`, `step2_inventory_reset`, `step2_inventory_assert`,
`step2_inventory_controls`, `step2_ctl_write_oracle`,
`step2_inventory_record_program`, `step2_inventory_is_program`, `step2_ctl_silent`,
`step2_controlled_suite`, `step2_bridge_suite`, `step2_inventory_suite`), plus
nineteen single-purpose control functions. Two new data shapes: the associative
array `STEP2_CASE_OF`, which is how the bridge requires agreement with a row
rather than with a second copy of its expectation, and the recorded inventory
file, `population|path` rows read into three sets.

### Architecture check for Step 2

DDD-Hexagonal does not apply to a Bash toolchain. The property that does is the
deployment contract, that `install_pkg.sh` runs alone from a bare account, and it
holds: the classifier adds no file, no sidecar and no host tool. The allowlist
half of the host-tool rule was run against the changed installer and reports zero
unlisted words and zero unused contract entries, which is a measurement rather
than a reading: the classifier's only command-position words are `[`, `return`
and `local`, all interpreter rather than host.

The separation the plan cares about is kept and slightly strengthened. The
harness never reimplements the classifier: it sources the production function
through the seam and drives it. Extracting the fixture recipes removes the one
place where Step 2 could have grown a second copy of Step 1's inputs, so the
bridge compares the classifier against the producer rather than against a
lookalike.

One thing is worth naming rather than leaving implicit. The key-set rule compares
two independent statements, production's `CPLX_ELF_OBS_KEYS` and the harness's own
`STEP2_ROW_FIELDS`, and one case asserts they agree. Building the rows out of
production's list would have compared that list with itself.

The allowlist rule earned its keep here rather than merely passing. The kind gate
was first written as `case ... in exec|dyn)`, and the rule reported `dyn` as an
unlisted host tool: it rewrites a case pattern to `dyn;`, which leaves the word
in command position. That is the rule being literal, not wrong, so the gate is
two `[` comparisons instead and the reason is recorded beside them. A false
positive is fixed in the file that collided, never by loosening the assertion.

The inventory's judgements were factored into `step2_inventory_assert` for the
same reason Step 1 factored its contract rules into functions: a control that
exercised a second copy of a rule would prove nothing about the gate. The
round-4 pair also drives `step2_inventory_record_program`, the same population
router the walk calls, so neither case can bypass the location-independent rule
by prefilling assertion globals. The eleven refusal controls and the two silence
controls call the functions the walk calls.

No, there is nothing that needs to be addressed.

### Performance check for Step 2

The classifier is a fixed sequence of at most nine string comparisons over values
already read. It forks no process, opens no file and iterates nothing, so it is
O(1) per object and the walk stays linear in the number of objects. No O(n^2) or
O(n log n) computation is introduced, and the plan's rule that no step may add a
second full walk of the tree to the production ELF pass is untouched, since the
classifier is not wired to the pass at all.

The harness's inventory does walk a tree, which the plan permits for validation
and forbids only in the installer. Its cost is one fork-free four-byte read per
file, with `od` and the two probes reached only by the objects that answer the
ELF magic, so the many non-ELF files of an archive cost a builtin rather than a
process.

Its oracle comparison is the one place a quadratic shape appears, and it is
stated rather than hidden: each walked ELF is tested for membership of the
recorded sets, so the work is the walked count times the recorded size. On the
measured inventory that is 388 objects against roughly 120 recorded paths, it
runs in the harness rather than in the installer, and the plan's rule about a
second production walk is untouched because none of this is in the pass.

No, there is no performance issue that needs addressing at this step.

### Unit test coverage check for Step 2

The 100% unit-coverage rule targets a Python tree this repository does not have.
What stands in its place, per the plan's stated substitution, is the case matrix.

The matrix exercises every implemented branch, both `$HOME` overlaps, both
successful tag forms, ambiguity, structural inconclusiveness, both `skipped`
producers, both axis-local failure combinations, and both program-boundary
exclusions: an `unsupported` kind carrying a builder-anchored value and one
carrying the exact target under `DT_RUNPATH` each answer case 7. Every one of
those groups is asserted over the table itself, so a group that lost its last row
fails rather than leaving the suite green, and the id set is checked for gaps and
duplicates.

The controlled layer is exercised at 138 cases and 0 failures. Build 92 also
executes the bridge and the inventory against the recorded oracle: the bridge
passes, every oracle assertion passes, and the residual population reports one
real failure rather than an uncovered code path. The inventory controls include
eleven refusals, two silence cases, and four checks over the residual-program
boundary in both directions.

No, there is no unit-tested class below 100% to complete: there is no such class,
and the matrix that stands in its place covers the population boundary the
review found missing. The remaining Step 2 failure is an acceptance result over
the archive, not a unit-coverage gap.

### Feature integrity for Step 2

No existing feature or reporting capability is impaired. `elf_classify` is
defined and never called by the executed path: `fix_elf_paths` still reads the
four magic bytes, still applies its single builder-anchor guard, still writes
through `--set-rpath` without `--force-rpath`, and still reports its one mixed
count. The observer and the probe are unchanged, the copy-engine selection of the
previous effort is untouched, and the Step 0 baseline should re-measure
identically.

The Step 1 suite is refactored, not altered: the recipes, their failure messages
and every assertion moved without a change of text, and the donor and base
planting keep the same outcomes. Build 92 re-executes the suite through those
helpers at 462 cases and 0 failures.

---

## Analysis of Step 3 implementation state

Yes. Step 3 has been fully implemented.

The reviewed design amendment resolves the trailer-position ambiguity before
the corpus's second freeze, the re-audited ledger covers all 26 obligations,
and the aligned formatter and reader pass 104 Step 3 cases. Retained build-97
evidence executes the required Step 0 behavioral backstop against the exact
staged installer and confirms Steps 1 and 2 remain green.

### Goal for Step 3

Implement the `CPLX-ELF/1` formatter in `install_pkg.sh` and the sole
retained-output reader, with the malformed-capture constructors, in
`verify.relocation-rpath.sh`, and make their contract green without the
installer's main flow calling the formatter.

### Step 3 improvement expectations

The wire contract is proved from both ends before anything depends on it, so the
step that changes behavior carries only the wiring and the emission. Every wire
token round-trips from the production formatter to the harness reader, every
required field is present exactly once, the categorical equalities are checked by
the reader rather than merely produced by the formatter, and every rejected form
is rejected with a distinguishable reason.

The two ends live in different files on purpose. The reader never runs during an
install, so shipping it would add a parser no deployment executes to the file
whose size is this effort's live constraint, and would create a call surface
needing an argument. Keeping it in the harness makes a production reader call
site impossible rather than merely unintended.

Their agreement is anchored to a literal contract corpus,
`docs/v0.27.0/contract.cplx-elf-1.txt`, rather than to a round-trip. A round-trip shows the two implementations agree; it cannot show
they are right, and two ends written by the same hand can drift together while
still carrying the `CPLX-ELF/1` marker, which is the failure already met between
the fixture generator and the observer. The corpus is committed canonical
records and trailers plus malformed examples, authored by hand from the design's
grammar, not generated from either end's tables and not sourced as constants by
either. The formatter's output is compared byte for byte against the canonical
vectors, and the same literals go to the reader. `/1` is frozen: a grammar
change needs reviewed authority, a new marker and a new corpus.

Independence alone would still let a red suite be made green by editing the
corpus, turning it into a transcript of the formatter. So the artifacts are
ranked: the reviewed `/1` design is semantic authority, the corpus is its frozen
executable witness established before any formatter work, and the formatter and
reader are implementations. The corpus's exact bytes are recorded as evidence, by
Git blob id or validation-only digest, before either implementation is compared
against it, because bytes never recorded cannot later be shown not to have
moved.

A digest is not a derivation, and the freeze is not read as though it were. It
proves the bytes have not moved since measurement and says nothing about whether
they were correctly derived, which the adjudication rule below presumes. So a
recorded two-way derivation audit precedes the freeze: every `/1` design
obligation maps to the corpus vectors witnessing it, with zero uncovered
obligations; and every corpus vector maps to its exact design clause, its
intended accept or reject result, and any canonical-output choice the design
permits without requiring, with zero underived vectors. That last column is what
catches the quiet decisions, since where the design permits a form the corpus
must pick one, and the pick is authored rather than derived. Step 3 reads the
literal corpus against the ledger and records the result before freezing. The two
pieces of evidence make different claims and neither substitutes for the other:
the audit establishes derivation correctness at freeze time, the digest
establishes stability afterwards. Silence or a double reading found by the audit
takes adjudication path 3 before the freeze, not a chosen corpus value recorded
as derived.

The corpus declares three classes, and the audit exposes why two would not do.
Canonical formatter vectors in one field order are the only thing the formatter
is compared against. Other reader-valid vectors, at minimum one permuted `obj`
and one permuted `end`, are literals the reader must accept and the formatter is
never required to emit; they are what tests the design's rule that the reader
resolves fields by name rather than by position, which canonical vectors in a
single order cannot test at all, since a strictly positional reader passes every
one of them. Rejected vectors are the third class. Declaring the classes is what
keeps a valid permutation from being filed as malformed input.

A mismatch takes exactly one of three paths, chosen by reading the design
rather than by which edit is smaller: fix the implementation when the corpus
agrees with an unambiguous clause, which is the expected case; correct a genuine
corpus typo in an isolated corpus-only change citing that clause and re-freezing
the bytes before any implementation changes; or stop for reviewed design
amendment when the clause is silent or admits both readings. Changing the corpus
and an implementation in one commit is forbidden outright, since the result is
indistinguishable from the first case resolved the wrong way, and `/1` semantics
never change in place.

The `path` field gets a byte matrix rather than one example, being the only
field derived from runtime input instead of a closed vocabulary. Each vector
carries its raw input and its literal expected lowercase hex, authored by
neither production end: a simple relative path; a multi-component path whose
object sits under a stated `$DEST_PATH`, proving the encoded value is the
remainder rather than the absolute path; the delimiter-looking bytes space, `=`
and newline, all lawful in a Linux filename; a non-UTF-8 byte, since a filename
is a byte string and not text; a one-byte shortest input; and an adjacent pair
at and just past the `od` output wrap boundary, whose width is measured against
the shipped tool and recorded rather than assumed, a wrapping defect showing at
that transition and nowhere else. Empty, non-hex, decoded absolute and decoded
`./` values stay among the rejected forms.

Nothing a deployment can observe changes, and that is asserted rather than
inferred: `emit_cplx_elf_v1_record`, a reserved distinctive identifier, occurs
in `install_pkg.sh` exactly once as a whole shell word, at its definition, and
in no comment or message literal, with the reader's identifier absent entirely.
A false positive is fixed by renaming the colliding prose, never by loosening
the check. Re-running the Step 0 baseline is the behavioral backstop beside it,
not the proof, since a call whose output was redirected would leave the baseline
unchanged.

### What was implemented for Step 3

- `src/setups/env/bin/install_pkg.sh` defines the uncalled
  `emit_cplx_elf_v1_record` formatter and the `/1` marker.
- `docs/v0.27.0/verify.relocation-rpath.sh` implements the sole retained-capture
  reader, corpus constructors, categorical reconciliation, and the Step 3
  dispatch and verdict.
- `docs/v0.27.0/contract.cplx-elf-1.txt` supplies the three declared vector
  classes, path-byte matrix, and whole-capture reconciliation cases.
- `docs/v0.27.0/ledger.cplx-elf-1.md` records the two-way audit, measured
  16-byte `od` width, and frozen corpus blob.
- The Step 3 harness reports 104 owned cases, zero failures, and `OBJECTIVE
  MET`; repository lint, the two-file ShellCheck command, and Bash syntax are
  clean.

### New types or classes introduced for Step 3

No application type or class is introduced. The new contract artifacts declare
canonical formatter, other reader-valid, rejected, path, capture-valid, and
capture-reject vector classes.

### Architecture check for Step 3

The formatter remains in the standalone installer while the validation-only
reader remains in the harness, preserving the intended production/validation
boundary. The staged Design Area 3 amendment is the authority artifact required
by the plan's adjudication path and is independently reviewed in this round
before the derived corpus and implementations. No DDD-Hexagonal layer applies
to these Bash scripts, and no cross-boundary dependency smell was found.

No architecture issue needs to be addressed.

### Performance check for Step 3

The formatter has no production call site, so this step adds no install-time
walk or runtime work. The measured 105-line installer increase exceeds the
advisory estimate but is not a performance gate.

No performance issue needs to be addressed.

### Unit test coverage check for Step 3

This repository has no `src/pdfss/tests/unit` Python unit-test layer; the plan's
declared substitute is the Bash harness. Its Step 3 suite exercises the
formatter, reader, literal corpus classes, path matrix, malformed forms,
reconciliation, round trip, and static no-call-site assertions across 104 owned
cases with zero failures.

No unit-tested class below 100% needs completing.

### Feature integrity for Step 3

The static assertions show one formatter definition and no reader in the
installer. Retained build-97 evidence runs the real Step 0 production baseline
against the staged installer at 462/0 for Step 1 and keeps Step 2 at 355/0,
confirming the pass still writes `DT_RUNPATH`, emits its mixed count, and has no
observable Step 3 behavior change.

---

## Analysis of Step 4 implementation state

Yes. Step 4 has been fully implemented.

The mandatory command is green. This sentence was reworded on 2026-08-29 to the
exact form the check requires; the verdict is unchanged.

Round 4 found why the previous rounds could not converge, and it was not the
evidence. Step 4's completion criteria both forbade and permitted the one
selected residual the agent reports: the first bullet required every other
archive program preserved, and the later bullets handed selected residuals to
Step 6. No harness could satisfy both, so a green run proved one branch of a
contradiction.

The contradiction is resolved where it came from rather than by choosing a
branch. The clause sits under the requirement's `## Acceptance` heading and
acceptance is Step 6, so the claim was never Step 4's to assert and the first
bullet had been over-claiming since it was written. A staging copy cannot answer
a question about what the published archive contains. Nothing in the requirement
is weakened: every acceptance criterion keeps its wording and none admits an
exception. The issue now says once where its criteria are proved, which is the
sentence whose absence let an implementation step adopt one as its own gate.

That reading is offered for the reviewer to reject if the authority chain reads
differently to it. It is recorded as locating a claim, not amending one.

Build 110 on the Debian 12 agent: steps 0 to 3 `OBJECTIVE MET` with zero
failures, step 4 at 540 cases, zero failures, `OBJECTIVE MET`, harness exit 0,
capture `result: OBJECTIVE_MET`, and the pipeline SUCCESS.

Round 3's three findings are all closed, and two of them were right about
something no build could have told us.

The FORMATTER CONTRACT was implemented as the plan asks rather than the plan
amended to match the code. The installer emitted its terminal record from two
sites, the patchelf-absent early return and the end of the walk, and the harness
expected four occurrences, so passing that test proved divergence from the
criterion. The run state is now set in both branches and the trailer emitted
once below them: three occurrences, `step4/formatter-call-sites PASS 3`, and
`step4/skipped-state PASS skipped` shows the same path still reporting itself.

The GATE allocation is now consistent with the authority chain. The issue keeps
the end-state acceptance claim unchanged and locates its proof in Step 6 over
the deployed archive. Step 4 no longer repeats that end-state claim over a
staging copy: it gates classification and its exact ownership register, then
hands every selected residual to Step 6 by name. Build 110 proves that Step 4
contract, while Step 6 remains responsible for the zero-selected acceptance
result and admits no exception.

The LINE BUDGET is measured and recorded, with the method stated so it is
reproducible: 625 at the baseline, 1281 staged at Step 4, against an advisory
band of 845 to 955 for the whole effort. The maintainability assessment is
recorded with the number rather than the impression, and the deployment shape is
raised as an input to the archive-shape requirement rather than acted on here.

The loader defect found in the previous round remains fixed and is proved on
both hosts the archive runs on.

What changed since round 2, in order of importance.

A DEFECT was found in the pass. Running it over a real archive revealed that
case 4 rewrites the shipped dynamic loader, which no earlier version touched.
Measured on both hosts the archive runs on: the loader answers `--version` at
exit 0, the case 4 write on it exits 0 and grows it, and it then dies of signal
11, as does any program whose `PT_INTERP` names it. That is the Provision-stage
SIGSEGV of builds 102, 103 and 105. The round-2 writer instructions were
therefore aimed at the wrong blocker: rebuilding the archive and rerunning would
have produced the same crash with the `a.out` finding gone.

The fix is one exclusion, by identity and not by name, and the bound was
measured rather than assumed: six ordinary libraries take the same write and
keep working.

The first response to the `a.out` finding adjudicated it by exact path against
umbrella requirement 7, with its own verdict word and exit code. That response
was withdrawn: the final form records exact ownership in both directions and
hands the path to the acceptance step without excusing it from that gate.

Build 108 on the Debian 12 agent: steps 0 to 3 `OBJECTIVE MET` with zero
failures, step 4 at 540 cases, zero failures, `OBJECTIVE BLOCKED`, and the
pipeline itself SUCCESS for the first time since this step began mutating the
live prefix.

### Goal for Step 4

Land the behavior and its emission atomically: the classifier wired into
`fix_elf_paths`, `--force-rpath`, the post-classification migration assertion,
the two disposition axes accumulated during the walk, and the call sites that
emit through the Step 3 formatter.

### Step 4 improvement expectations

The python ELF carries `DT_RPATH` from a fresh archive and from a
v0.26.0-relocated prefix alike, which is the object D3 turns on, and the run
reports it in a capture the Step 3 reader already knows how to check. A shipped
library that carried no rpath carries one. A second run and a `--force`
reinstall rewrite nothing. Objects the classifier excludes keep exactly their
current treatment. No second walk of the tree is added to the production pass.

Behavior and emission land together because neither intermediate state is
shippable: behavior alone leaves the illegible mixed count the requirement
removes, and emission alone would carry a `case` field for a classifier the pass
is not yet consulting.

**Two suites, not one.** An earlier reading said the Step 3 report-contract cases
are re-run unchanged "now against captures a real run produced", which cannot be
true of the suite it names: the corpus holds canonical formatter vectors, other
reader-valid permutations the formatter is not required to emit, and malformed
vectors production must never emit and must reject, so no real run produces the
second class and had better not produce the third. The Step 3 regression runs
unchanged against its **own literal and constructed inputs**, and the Step 4
integration separately feeds every real capture to the production reader. Neither
stands in for the other.

**A production outcome matrix replaces the single sample, and it is literal.**
One successful one-object run proves one path; it does not prove that the
observer, the ordered classifier, both disposition axes, the migration invariant,
the mutation calls, the counters, the formatter and the trailer compose where
something fails or nothing is written. The first attempt at that matrix was not
executable: cells reading `its own case`, `its own evidenced value`, `per object`
and `per the two axes` are instructions to derive an expectation rather than
expectations, and an interpreter's "evidenced value" is not a disposition at all,
the closed tokens being `rewritten`, `failed`, `unchanged` and `not applicable`.
One row was also shifted a column, putting `failed` under rpath where it belonged
under interpreter, reversing the axis-local premise it existed to prove.

The matrix is now thirty rows, `A01` to `A30`, over fourteen runs `R0` to
`R7`, `IF01`, `IF02`, `IW01`, `IW02`, `R14` and `R13`, with twelve enumerated
objects at fixed paths, so every record is literal
and every `path` is scenario-fixed. Every case is 1 to 7, every disposition is a
closed wire token, and every migration delta is a number. The table is
rectangular and its column count is asserted mechanically, which is the check
that catches a shifted row as a malformed table rather than as a puzzling
expectation.

Every walked object reconciles on **both** axes: each row contributes `walked`
+1, exactly one `r-` bucket +1, exactly one `i-` bucket +1 and its stated
migration deltas, with every other bucket unchanged; and over every run the five
`r-` buckets sum to `walked` and the four `i-` buckets sum to `walked`. The
earlier table gave several rows only one axis, which contradicted categorical
reconciliation while claiming to implement it. The empty-search-path run now has
a fixed six-object inventory with per-object records and complete totals rather
than the phrase "`r-failed` equals `walked`", which said nothing about the
interpreter or migration figures, and its interpreter axis is untouched by the
missing rpath input, which is what the design claims and what the phrase could
not check.

The interpreter guard, read from lines 413 to 422, is
`[[ "$old_value" == */home/* ]] && [ "$old_value" != "$new_interp" ]`, so a
system interpreter and an already-target interpreter both give `unchanged` and
only a builder-anchored interpreter differing from the target gives `rewritten`.
Every `unchanged` in the matrix is that guard rather than an omission.

**Mutation failures are not probe failures**, and each of the four fault cases
names an exact subject. `D01` fails `--print-rpath` over a library, so its
surviving interpreter axis is `not-applicable` with no value, which is the
design's own row. `D02` fails `--print-interpreter` over a program, keeping case
6 and rpath `rewritten`. `W01` fails `--set-rpath` over a **case 5** object,
giving rpath `failed` while `mig-checked` still increments, because the case is
population identity and does not change with the outcome of acting on it. `W02`
fails `--set-interpreter` over a program, keeping rpath `rewritten`. A write
failure changes the disposition and never the case, the case being a function of
a tuple the write has not yet touched. `D02` and `W02` produce identical
captures, which is why neither can stand in for the other: the difference lives
in which production branch ran, not in what it emitted. Their doubles are bounded
by the containment and shipped-identity rules already settled, unchanged.

Every capture a matrix row produces is parsed by the Step 3 reader and asserted
in full, the complete object record field by field including the scenario-fixed
`path`, and the categorical trailer, rather than merely accepted as
syntactically valid. The design's one-object capture is retained as one verified
row only if its fields and totals still match its scenario; otherwise the Q09
adjudication rule applies and `/1` semantics are not edited here.

**Traceability closes in both directions**, on the discipline Q09 applies to the
`/1` corpus, and the second direction is **enumerated rather than asserted**. The
previous version carried a design-to-matrix table followed by a sentence claiming
every row cites a clause, and that sentence was already false: `A11`, the
second-pass excluded program, appeared in no entry. Every `A01` to `A30`, every
run and every fault run now has its own reverse entry naming its clause **and the
fields that clause fixes**, and the check is set equality on the id sets with
zero missing and zero extra. That set is the actual fourteen runs, `R0` to
`R7`, `IF01`, `IF02`, `IW01`, `IW02`, `R14` and `R13`; the earlier `R0..R13`
range demanded four ids that the fault-run rename had removed, which the
mechanical check reports rather than tolerates.

Running the second direction produced four rows a one-way derivation had missed:
the file shorter than the ELF header had no integration coverage, the domain
rejections had been folded into the structural one, the rpath-write fault had
been written over a case 6 object where the design's row is specifically about a
case 5 object keeping its migration count, and the probe-failure row names a
library where the plan had used a program. Requiring the entries to justify
**fields** rather than scenarios then found two more things. The six
empty-search-path rows had been given case 1 across the board, which collapses
the case into the disposition, and the design says the case is population
identity assigned from the observation while an empty search path is not an
observation of the object; those cases are now the objects' own. And the same
clause turned out to contradict two others for objects the pass would never have
written, which became **Q10**, sent to reviewed authority rather than settled by
whoever was writing the table, and **answered 10B**: an empty or unavailable
computed target search path gives rpath `failed` to the objects whose write was
due, cases 4, 5 and 6, and leaves cases 1, 2, 3 and 7 with the dispositions their
cases already fix. The run still fails acceptance through its selected objects,
so the object-local reading hides nothing, and no row is provisional. The
authoritative design text is amended in step, so the plan does not remain
downstream of a clause saying "`failed` for every walked ELF".

**The fault identifiers are scoped.** For one round `D01` and `D02` meant both
the Step 1 producer witnesses over `F01`, whose surviving axes are `ok` with a
value, and Step 4's integration fault runs over a library and a program, whose
outcomes differ; and Step 2's bridge named them without saying which. The
producer witnesses keep `D01` and `D02`, Step 4's runs are `IF01`, `IF02`, `IW01`
and `IW02`, and the bridge names its eight producer subjects by Step 1 fixture id
with their complete surviving-axis values, so it cannot be built from the wrong
pair.

**Trailer expectations are derived, not transcribed.** The literal totals table
was written by hand and has been independently recomputed and found correct, so
what follows guards drift rather than fixing an error: the harness folds the
expected per-object rows into expected per-run counters and makes three
comparisons, the fold against the literal table, the fold against the actual
parsed trailer, and the literal table against the actual parsed trailer. A row
edited in one place and not the other then fails mechanically.

**The call sites are enumerated, which the previous wording promised and did
not do.** There are exactly two: the object-record site, reached once per walked
ELF whatever its disposition, sitting at a single per-object emission point every
disposition falls through to so no early `continue` can bypass it; and the
terminal trailer site, reached once per run at a single exit point on every path
including the skipped one, so the skipped path cannot omit the trailer and no
path can emit two. So `emit_cplx_elf_v1_record` occurs as a whole shell word
**exactly three times** after this step, definition plus those two, still in no
comment or message literal, and the reader is still absent from the installer.
The property flips from "no caller" to "these callers" in the step that creates
them. Single emission points are what make `walked` equal the record count
structurally, instead of leaving the categorical reconciliation to catch a branch
that forgot to emit.

This is also the checkpoint where the measured size of `install_pkg.sh` is
recorded against its standalone-deployment constraint, being the last step that
adds production code.

### What was implemented for Step 4

- `src/setups/env/bin/install_pkg.sh` wires classification into `fix_elf_paths`,
  applies `--force-rpath`, records the independent rpath and interpreter axes,
  checks migration after classification, and emits object and terminal records
  during the existing walk.
- `docs/v0.27.0/verify.relocation-rpath.sh` adds the Step 4 production matrix,
  literal record and trailer reconciliation, fault runs, idempotence checks,
  derivation-ledger checks, and Step 1 through Step 3 regressions. This round
  adds the loader seam pair, rows `A29` and `A30`, the run-after assertions, the
  residual half over a copy rather than the live tree, with a named handoff to
  Step 6.
- `src/setups/env/bin/install_pkg.sh` excludes the resolved dynamic loader from
  the write population by device and inode, before case 3, answering case 7.
  Identity and not name, because the archive ships the resolved candidate as a
  symlink onto the real file the walk hands over, so a string comparison would
  leave the rule silently dead.
- `docs/v0.27.0/probe.loader-survives-rpath.sh` is the target-side measurement,
  retained so the finding is reproducible rather than asserted: it copies, it
  never writes the archive, and it answers both halves, that the loader dies and
  that the ordinary libraries do not.
- The retained build-110 captures are this round's evidence: steps 0 to 3
  `OBJECTIVE MET` with zero failures, step 4 at 540 cases, zero failures and
  `OBJECTIVE MET` at exit 0, and `verify.relocation.loader-probe.debian.txt` carrying
  the agent's reading of the loader beside the target's.
- Round 3's three findings are closed in this round: the formatter now has one
  terminal site and three occurrences, `step4/formatter-call-sites PASS 3`; the
  gate moved to Step 6 by specification decision rather than being adjudicated;
  and the line budget is measured, 625 at the baseline to 1281 staged, with the
  method stated so it is reproducible.
- Two guards fired on this round's own work and both were right. Build 106
  reported `matrix/row-count want [28] got [30]`, the check the plan credits
  with catching the `D02` row, catching two rows added without their count.
  Build 107 printed `result: UNEXPECTED_EXIT_6` over a clean verdict, because
  the capture wrapper's exit mapping had not been taught the new code; its own
  comment already described that failure from the time exit 5 was collapsed
  into FAILURES. Both are fixed and build 108 is clean.
- The exact mandatory local commands passed repository shell lint, ShellCheck
  over the installer, the harness and the new probe, and Bash syntax. The Step 4
  harness returned capability exit 4 on Windows after its host-independent seam
  cases, at the same 36 cases and same two host-capability failures as before
  this round.

### Missing work for Step 4

- Nothing this step owns. Build 110 answers every Step 4 criterion and the
  mandatory command returns `OBJECTIVE MET` at exit 0.
- Owned by umbrella requirement 7 and proved at Step 6 acceptance: rebuild the
  published archive without `tools/python/root/a.out`, then drop that exact path
  from the ownership register. Step 4's handoff and stale-entry check keep that
  later work explicit without treating it as missing Step 4 implementation.

### New types or classes introduced for Step 4

No application type or class is introduced. The Step 4 harness adds matrix-run,
fault-run, record/trailer, derivation-ledger, loader-seam, run-after, and
residual-handoff test categories. Their declared coverage includes all 30 matrix
rows. The coverage debt is discharged: build 110 ran every one of them on the
Debian 12 agent, 540 cases and zero failures.

### Architecture check for Step 4

The production pass retains one filesystem walk and keeps the contract reader
in validation code. No DDD-Hexagonal layer applies to these Bash scripts.

The acceptance boundary is explicit: Step 4 produces and hands off the selected
residual set; umbrella requirement 7 rebuilds the archive; Step 6 proves the
unchanged zero-selected acceptance claim over the deployed result.

No architecture or ownership-boundary inconsistency remains for Step 4.

### Performance check for Step 4

The implementation obtains size and path during the existing traversal and does
not add a second production walk. No performance issue needs to be addressed.

### Unit test coverage check for Step 4

This repository uses the declared Bash harness in place of a Python unit-test
layer for this shell behavior. All 30 matrix rows execute, the formatter count is
correct at three, the loader seam and run-after checks pass, and the residual
suite asserts the Step 4 classification and ownership contract. No Step 4
coverage gap remains.

### Feature integrity for Step 4

The retained Step 1 through Step 3 regressions and all 30 Step 4 matrix rows are
green, and build 110's Step 4 command returns zero. The selected residual is
reported and handed to the unchanged Step 6 acceptance gate rather than hidden
or excused. Feature integrity is complete for Step 4.

---

## Analysis of Step 5 implementation state

Yes. Step 5 has been fully implemented.

The three wiki pages describe the pass as it behaves after Step 4, and the Step
5 suite asserts each obligation on its named page.

### Goal for Step 5

Update the reference, the explanation and the how-to so the archive stops
shipping a description that contradicts its own loader behavior, including the
part of the `setenv` export that no longer affects the shipped directories.

### Step 5 improvement expectations

The evidence is **positive, per obligation**, and the stale-wording greps are a
backstop beside it. Two negative greps established none of the eight
documentation obligations this step states: a page whose ELF section had been
deleted entirely would have passed both. So a coverage table is asserted page by
page: `relocation-tools.md` carries the tag actually written, `DT_RPATH`, the
three populations, both disposition axes and what the pass leaves untouched;
`why-binaries-remember-the-build-home.md` carries the install-time rewrite now
producing `DT_RPATH` with its consequence for `LD_LIBRARY_PATH` and for `setenv`;
`relocate-an-install-to-another-prefix.md` carries a check expecting `RPATH`
exactly rather than either tag, and the library-side check. Deleting the relevant
prose fails this step rather than satisfying it.

The backstop remains: no page still states the `/home/` guard as the whole rule,
and the how-to's check block accepts neither tag indifferently. Backstop rather
than proof, for the reason the Step 0 baseline is a backstop in Step 3, that
absence of the wrong thing is not presence of the right one. The host-tool list
is unchanged because no installer tool was added.

### What was implemented for Step 5

- `wiki/reference/relocation-tools.md`: the ELF row now names `DT_RPATH` and
  says the rpath axis selects by population rather than by the value it finds. A
  new section records the tag written and why it is not `DT_RUNPATH`, the three
  populations as a table, the two disposition axes as a table, and four things
  the pass leaves untouched with the reason for each.
- `wiki/explanation/why-binaries-remember-the-build-home.md`: layer 1 now opens
  with the install-time rewrite settling it at deployment, states that
  `LD_LIBRARY_PATH` no longer wins and that `setenv` stops affecting the shipped
  directories, and keeps the compile-time alternative as the explanation of why
  the install-time pass exists.
- `wiki/how-to/relocate-an-install-to-another-prefix.md`: the check block expects
  `RPATH` exactly instead of accepting either tag, adds a library-side check, and
  explains why each of those two changes matters.
- `docs/v0.27.0/verify.relocation-rpath.sh`: a Step 5 suite of twelve positive
  coverage rows, two stale-wording backstops and the host-tool row count, with
  its own dispatch above the capability gate.

Local evidence: `--step 5` returns `OBJECTIVE MET` at exit 0 on the authoring
host, 52 cases, zero owned failures, with the two step 0 preflight failures
named as inherited rather than absorbed. ShellCheck and repository shell lint
both exit 0.

### New types or classes introduced for Step 5

No application type or class is introduced, and no production code changed. The
harness gains one suite and two literal coverage tables.

### Architecture check for Step 5

No layer applies. The Step 5 suite reads Markdown and the contract file and
nothing else, which is why it exits above the capability gate: a step that needs
no patchelf, no readelf and no Linux must not report that a host cannot satisfy
it.

No architecture smell or violation needs to be addressed.

### Performance check for Step 5

Not applicable. The suite runs sixteen greps over three pages.

No performance issue needs to be addressed.

### Unit test coverage check for Step 5

Twelve positive obligations, one per row of the plan's coverage table, each
naming its page and asserted present on it. This is the shape the plan asked for
and the reason it asked: the previous revision had two stale-wording greps and
nothing else, and a negative test passes when prose is deleted. Deleting the ELF
section from the reference page now fails five rows rather than satisfying two.

The two stale-wording greps are retained beside them as a backstop and are
labelled as such in the output, not as evidence.

No unit-test coverage gap needs completing.

### Feature integrity for Step 5

No behaviour changed. The host-tool contract still carries its 26 rows, asserted
here because no installer tool was added by this effort and a changed count
would mean a tool arrived without its contract row.
---

## Analysis of Step 6 implementation state

Yes. Step 6 has been fully implemented.

Round 11 closes the two canonical handover gaps found in round 10. Umbrella
requirement 7 now inherits the residual assertion, the empty Step 4 handoff,
migration positivity and case 5 equality, the three `$HOME` states, and force
reinstall. The issue, plan, resume note, harness, and umbrella also state one
residual contract: an adjudicated residual is a named handover and is not
`UNANSWERED`; an unadjudicated residual still fails here and now.

The retained RHEL run `step6scope-20260829T203916Z` exercises the amended scope
with 216 cases, 0 failures, `OBJECTIVE MET` at exit 0, and no `UNANSWERED`.
Its harness and installer digests match the staged files. The retained Debian
captures remain evidence for the earlier harness they name and are not used to
support this verdict.

- `tools/python/root/a.out` is still selected in the published archive,
  confirmed on both distribution paths. It is HANDED to umbrella requirement 7
  by name with its owner, printed in every capture, and it no longer holds this
  requirement's verdict open. Removal is that item's only available discharge
  and this item cannot perform it.
- What still fails here and now is an UNADJUDICATED residual, one no owner has
  claimed in the register. That direction was proved by a planted control in
  run `step6verify-20260829T132824Z`: `zz-stray.out` failed both criteria while
  the registered `a.out` deferred. The gate keeps its strength.
- The retained Debian captures are from build 123 and cite an earlier harness
  digest. They are evidence for the steps they were taken against. They are NOT
  restated as evidence for this verdict, which rests on the RHEL run named
  above, retained by a human decision while CI was down with a sealed vault.
- the second monitoring decision is now recorded as what it actually was. Round
  6 was right that the guidance quoted the question and then supplied only the
  writer's statement about the answer, while claiming both decisions were
  verbatim. The second answer was a SELECTION from three labelled options, not
  free text, and the record now carries the exact option chosen, its stated
  consequence, and the two alternatives it was chosen over, one of which was
  named in front of the human as the reviewer's preferred reading. A selection
  presented as a quotation was the writer's error and is corrected rather than
  defended.
- the structured reader is now anchored. `index($0, k)` matched the label
  anywhere in a line, so narrative text mentioning `form-N-outcome:` satisfied
  that form and handed back the rest of the sentence as its value. A control
  for exactly that near miss is retained, bringing the parser controls to
  twelve, of which two must be ACCEPTED rather than rejected.

The acceptance also found a production defect, which is what an acceptance step
is for: the pass was rewriting the patchelf binary executing it. That is fixed,
and the fix is a declared change to this step's scope, recorded in the plan
rather than absorbed.

### Goal for Step 6

Run the acceptance as a whole and retain its evidence: the states of the
validation table, the classifier against the `develop#24` inventory, the
`OPENSSL_3.x` verdict with its answering provider named, the shipped patchelf's
actual behavior, and the RHEL preload and monitoring measurement.

### Step 6 improvement expectations

No write that was due failed, every observation failure is outside the supported
domain for a reason read from the object's own header, and the migration failed
figure is zero. The migration checked figure is positive and equals the case 5
count on the dedicated v0.26.0 run; and the downstream column is written up as
a handoff rather than claimed as done.

**The full inventory check is a criterion here, not a description of behavior.**
The retained evidence carries the walked and selected counts and populations, and
the assertions are the ones the plan states once and Steps 2 and 4 use verbatim:
the 110 flagged libraries as case 4, the python program asserted by name, since
its omission is the failure the requirement's acceptance was written to catch,
the enumerated git objects, and every other archive program preserved as case 7,
so an excluded program quietly rewritten fails this step. Every retained capture
is accepted by the Step 3 categorical reader rather than read by eye: a capture
no reader accepted is not acceptance evidence.

The retained RHEL evidence comes from two visits because the first omitted the
functional criteria. Each session records one run identity, the exact target
identity and its Bash version, runs the exact-target `declare -A` check before
the installer, and deploys under that identity. The second visit carries the
functional evidence omitted by the first.

If Step 0's associative-array check ended `unavailable` and Steps 1 to 5
proceeded provisionally, the debt is settled at that first gate, with three
outcomes: exact-target support closes the branch and the session continues
immediately to deployment; an executed unsupported result ends the session for
plan revision with nothing deployed; and a target still unreachable means the
session never opened, leaving this step **incomplete**. That last case is not a
blocked verdict, and the distinction is load-bearing: collapsing it into one
would let the effort skip the RHEL run and still report a terminal result. The
two unavailabilities do not compound, because the first prevents reaching the
second.

Terminal `blocked` is reached from exactly one state: the session opened with a
supported capability result, the real RHEL deployment ran, the preload
measurement succeeded, and none of the three monitoring observables could be
obtained. Given that, it has one meaning: evidence
collection completes with an overall verdict of `blocked`, the criterion is
unsatisfied, the acceptance is not green, no implementation success is claimed
on its strength, and the verdict is terminal rather than leaving the effort
waiting. The record names the owning team or contact channel rather than a
personal name, the request time or identifier, which of the three acceptable
observables was requested, the response or its absence by the recorded date, and
the retained evidence path.

### What was implemented for Step 6

- `docs/v0.27.0/verify.relocation-rpath.sh`: the Step 6 acceptance suite, walking
  a copy of the deployed archive and asserting what the archive CONTAINS, which
  is the claim Step 4 only reports. It also splits the two meanings of `failed`
  and asserts each separately.
- `src/setups/env/bin/install_pkg.sh`: the running patchelf excluded by device
  and inode, beside the loader rule. A declared scope change, recorded in the
  plan's Step 6 files-involved section.
- `docs/v0.27.0/verify.acceptance.rpath.rhel.txt`: the first RHEL session's
  retained evidence under run identity `rhel-acceptance-20260827T114631Z`. Its
  monitoring verdict is marked SUPERSEDED rather than rewritten.
- `docs/v0.27.0/verify.acceptance.rpath.rhel.session2.txt`: the second session,
  `rhel-acceptance2-20260827T222103Z`, carrying the requirement's functional
  evidence and the standing monitoring disposition.

**THE MONITORING CRITERION IS AMENDED.** The requirement made it gating and
expected one of three observables. Forms 1 and 2 are unavailable to the
deployment account. Form 3 is obtainable, drafted, and deliberately not sent;
round 6 correctly stopped describing that choice as an inability.

The hazard itself is answered on the mechanism. The first retained human quote
authorizes not chasing the vendor attestation. The separate decision making
`not-pursued` a passing outcome is now retained in its actual form: a selection
from three labelled options, with the chosen option, its consequence, and both
rejected alternatives recorded rather than misrepresented as free-text prose.

The harness trims only token edges, requires three nonempty structured outcomes,
and anchors each outcome label at the start of its field line. Twelve controls
include two accepted records and reject a label token embedded in narrative.

- `docs/v0.27.0/verify.relocation.step6.debian.txt` (new): the acceptance
  capture retaken from build 123, 216 cases and 2 failures, both for the same
  `tools/python/root/a.out` object.
- `docs/v0.27.0/request.monitoring-observable.rhel.md` (new): the drafted form 3
  request, which is the retained artifact the blocked record points at.

Evidence, Debian agent, build 123: 216 cases and 2 failures. The tag is checked
on all 464 recorded rpath rewrites rather than
two samples, each carrying `RPATH` and no `RUNPATH`. The shipped loader resolves
`libm`, `libc` and `libgcc_s` inside the prefix, which are the three the
requirement names. The shipped patchelf reads back what the pass wrote and its
`--force-rpath` behaviour is recorded from its own run. All four shipped libssl
bind a libcrypto inside the prefix. The failed dispositions split 26 observation
and 0 write, and every observation failure is outside the domain for a nameable
reason. All five domain-reader controls run, including the two that were
previously skipping.

Round 3 closes the round 2 findings about silently absent archive subjects,
population tag coverage, named loader dependencies, and evidence ordering. It
does not close implementation completeness. The missing target functional run,
migration positivity, the three `$HOME` states, and force reinstall are explicit
Step 6 acceptance work even when they depend on target access or the requirement
7 archive rebuild. The monitoring lifecycle is allowed to end blocked only
after a request was actually made and every blocked-record field has a value.

Evidence, RHEL target, two ordered sessions. The plan asked for one and this is
two, because session 1 wrote the functional criteria down as owed instead of
collecting them; that is an error of that session rather than a property of the
work, and it is recorded that way.

Session 1, `rhel-acceptance-20260827T114631Z`: capability `supported` before the
installer was invoked; deployment `install-exit 0` in 334 seconds; the relocated
python carries `RPATH` into the new prefix and runs; `r-failed` 26 against the
agent's pre-fix 27, which is the patchelf exclusion confirmed on a real
deployment; the preloaded agent is statically linked and its own tag state is
unchanged before and after.

Session 2, `rhel-acceptance2-20260827T222103Z`: the same archive digest and the
same installer digest reproduce every trailer counter exactly, walked 675 and
`r-rewritten` 464 and `r-failed` 26, so the pass is reproducible on that target
rather than observed once. The functional evidence is taken from the tree that
run deployed: git 2.52.0, Python 3.13.9, `import ssl, zlib` all at exit 0, both
programs carrying `RPATH` and no `RUNPATH`, and the `_ssl` extension binding
`libssl.so.3` and `libcrypto.so.3` inside the prefix under the shipped loader.
The guards were re-verified at the end: the live install's mtime is unchanged
and the throwaway prefix was removed.

One measurement from session 2 does NOT satisfy its criterion and is recorded as
a measurement only. The preloaded agent was inspected from inside a process this
account owns, on a relocated python and on the system python, and it presents
identically in both: mapped in, one thread, no sockets, and no agent log written
for either. That says relocation changes nothing about it, and it is
process-side evidence where the requirement's form 2 asks for agent-side. A
criterion is not satisfied by evidence of a shape it did not ask for, however
good that evidence is. The separate authorized `not-pursued` amendment supplies
the standing passing disposition.

### Round 3 through round 7 findings addressed for Step 6

Round 4 closed seven of the ten round 3 findings. Rounds 5 through 7 close the
technical parser and authorization findings. The archive dependency and the
three criteria deferred behind its rebuild remain open.

- **Step 1 restored, Step 6 scope corrected.** Round 3's anchored edit matched
  the FIRST occurrence of a line that appears in both sections, so it truncated
  Step 1's harness entry, inserted the Step 6 file list there, and deleted the
  `Step 1 fixture oracle` heading with its opening paragraph. Step 1 is now
  byte-identical to `HEAD` under diff, and the Step 6 paths are in Step 6. This
  was the sixth file-damage incident in this effort from a line-range or
  first-match edit, and the missing discipline was never the matching strategy:
  it was that the result was not diffed before being reported as done.
- **The RHEL functional evidence is retained**, in a second session under run
  `rhel-acceptance2-20260827T222103Z`: git 2.52.0 at exit 0, Python 3.13.9 at
  exit 0, `import ssl, zlib` at exit 0 against OpenSSL 3.5.1 and zlib 1.2.11,
  with `libssl.so.3` and `libcrypto.so.3` both resolved by the shipped loader
  inside the prefix. The reviewer was right that needing target access does not
  move a criterion out of the acceptance, and the record no longer says it does.
- **The session parser reads values, not labels.** It compares the header run
  identity to the unique token, asserts the target identity and the Bash
  version, and reads the VALUE under each of the five blocked fields. Five
  negative controls were built and run against mutated captures; two of them
  passed on the first attempt and the fix was itself fail-open: the value
  scanner walked into the next field and reported its text, and the uniqueness
  test could never fail because both captures named their run exactly once, in
  their own header. Continuation is now bounded by indentation and a header-only
  citation fails.
- **Both read-failure branches execute, and the ELF32 plant has a failure
  branch.** Round 3 shipped that plant with no `else`, so a failed plant removed
  the case from the run with no fail and no count. The read-failure controls
  shadow the reading tool for one call, over a subject that NAMES itself when
  the read succeeds, so silence proves the branch rather than resembling it.
- **Both patchelf probes assert values.** Print requires every component to be
  an existing directory inside the deployed prefix; force reads back that
  `/probe` was written rather than that some `DT_RPATH` exists.
- **The local-command disagreement is resolved, and the harness was the thing
  that was wrong.** Round 3's request said exit 4, round 4's answer said exit 1,
  and both were reading the same run. The harness has two capability gates that
  returned 4 whatever the seam cases had found, while its own final verdict
  block documents the opposite rule in as many words: "a failure is a finding
  about the code and wins, since that is the thing to act on". So a real
  host-independent failure was being reported to a caller as a host limitation
  and disappearing behind an exit code meaning "not my problem". Both gates now
  honour the documented precedence. Round 7 reports the mandatory local command
  at **exit 1, 65 cases, 2 failures**. Neither earlier reader was wrong and the
  code was.

- **A form 1 finding is corrected rather than closed.** Session 1 recorded the
  vendor control tool as absent from every usual path. It is present at the
  standard path and is not executable by the deployment account, which is
  unavailable by permission, not absence. Session 1 read a traversal failure as
  an absence, the mistake this project already recorded once from the shellcheck
  incident and wrote into its own guidance. The original text is left standing
  in that capture with the correction marked beside it, because rewriting a
  retained record hides that the session erred.

### New types or classes introduced for Step 6

No application type or class. The harness gains an acceptance suite and a
domain-reason reader that works from an object's own header bytes rather than
from the record, so no `/1` schema change was needed.

### Architecture check for Step 6

No layer applies. The acceptance walks a copy for the reason Step 4 does: the
pass mutates what it walks, and on the agent the extracted prefix is the tree
the next pipeline stage runs.

No architecture smell or violation needs to be addressed.

### Performance check for Step 6

The acceptance copy and walk is the longest run of the effort. The RHEL
deployment took 334 seconds for 675 objects and 1.9 GB, recorded so a later
cycle knows what it costs.

No performance issue needs to be addressed.

### Unit test coverage check for Step 6

Every gap this section listed for round 3 is closed, and the paragraph is
rewritten rather than left describing a state that no longer exists.

The disposition token is trimmed at its edges and twelve controls are retained,
two of which require acceptance so the rejection controls cannot pass through a
parser that refuses everything. Structured outcome labels are anchored to field
lines, and a narrative-label near miss is rejected. The failed
size and header reader branches execute, over subjects that name themselves when
the read succeeds, so silence proves the branch. Both patchelf probes assert
their values. The RHEL functional check reads the named git and python versions,
the ssl and zlib versions, the tag state of both programs and the in-prefix
`_ssl` providers, rather than counting three zeroes.

The three archive-dependent acceptance groups are explicitly transferred to
umbrella requirement 7, which owns the rebuild needed to execute them.

The criterion that changed this round is worth naming. Asserting that both
failure dispositions are zero could never be satisfied by an archive shipping
ELF32 objects the design excludes by rule, and one number over two meanings hid
the single real write failure inside 27. It is now a gate on writes plus a
requirement that every observation failure be explained from the object's own
header, so an unexplained case 1 fails rather than joining an expected count.

Coverage is complete for every criterion this requirement owns. The transferred
migration, `$HOME`, and force-reinstall criteria remain visible in the receiving
umbrella requirement rather than disappearing from the backlog.

### Feature integrity for Step 6

The relocated tree runs on the deployment target: python executes, its libraries
resolve inside the prefix, and the preloaded monitoring agent still initialises
in that process. No behaviour regressed; one defect was found and fixed.
