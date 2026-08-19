# v0.27.0 relocation-force-rpath implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.relocation-force-rpath.md](plan.v0.27.0.relocation-force-rpath.md),
seven steps that give `install_pkg.sh` an ordered ELF classifier, a forced
`DT_RPATH`, and a report a retained recipe can assert on. No step has started.

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
directory here; the project's gate is `shellcheck` plus the Bash harness, which
is what the plan's execution checklist substitutes for the groundhog walk.

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

Not started. Step 1 is not implemented because the observer does not exist and
the pass still reads only the four magic bytes.

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

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 1

_(empty — no check has taken place yet.)_.

### Architecture check for Step 1

_(empty — no check has taken place yet.)_.

### Performance check for Step 1

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 1

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 1

_(empty — no check has taken place yet.)_.

---

## Analysis of Step 2 implementation state

Not started. Step 2 is not implemented because the pass still has one condition
where the design specifies seven ordered cases.

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

Against the `develop#24` inventory the classifier selects exactly the set stated
once in the plan, and that statement is the same one Steps 4 and 6 use: the 110
flagged libraries as case 4, the python program asserted by name, the enumerated
git objects, every other archive program as case 7. The plan had contradicted
itself here, this step saying every program but python was untouched while Step 6
said python and git; the design settles it in favor of python and git, and the
git objects are enumerated rather than counted because a count is a fact about
one inventory snapshot.

### What was implemented for Step 2

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 2

_(empty — no check has taken place yet.)_.

### Architecture check for Step 2

_(empty — no check has taken place yet.)_.

### Performance check for Step 2

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 2

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 2

_(empty — no check has taken place yet.)_.

---

## Analysis of Step 3 implementation state

Not started. Step 3 is not implemented because the record formatter and the
retained-capture reader do not exist.

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

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 3

_(empty — no check has taken place yet.)_.

### Architecture check for Step 3

_(empty — no check has taken place yet.)_.

### Performance check for Step 3

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 3

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 3

_(empty — no check has taken place yet.)_.

---

## Analysis of Step 4 implementation state

Not started. Step 4 is not implemented because `--set-rpath` still runs without
`--force-rpath`, the classifier is not wired into the pass, and the pass still
prints one count mixing interpreter and rpath rewrites while a proved formatter
sits uncalled beside it.

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

The matrix is now twenty-eight rows, `A01` to `A28`, over fourteen runs `R0` to
`R13` and twelve enumerated objects at fixed paths, so every record is literal
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
second-pass excluded program, appeared in no entry. Every `A01` to `A28`, every
run and every fault run now has its own reverse entry naming its clause **and the
fields that clause fixes**, and the check is set equality on the id sets with
zero missing and zero extra. That set is the actual fourteen runs, `R0` to
`R7`, `IF01`, `IF02`, `IW01`, `IW02`, `R12` and `R13`; the earlier `R0..R13`
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

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 4

_(empty — no check has taken place yet.)_.

### Architecture check for Step 4

_(empty — no check has taken place yet.)_.

### Performance check for Step 4

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 4

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 4

_(empty — no check has taken place yet.)_.

---

## Analysis of Step 5 implementation state

Not started. Step 5 is not implemented because the three wiki pages still
describe the pass as it behaved before Step 4.

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

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 5

_(empty — no check has taken place yet.)_.

### Architecture check for Step 5

_(empty — no check has taken place yet.)_.

### Performance check for Step 5

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 5

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 5

_(empty — no check has taken place yet.)_.

---

## Analysis of Step 6 implementation state

Not started. Step 6 is not implemented because no acceptance run has taken
place.

### Goal for Step 6

Run the acceptance as a whole and retain its evidence: the states of the
validation table, the classifier against the `develop#24` inventory, the
`OPENSSL_3.x` verdict with its answering provider named, the shipped patchelf's
actual behavior, and the RHEL preload and monitoring measurement.

### Step 6 improvement expectations

Both failure dispositions and the migration failed figure are zero; the
migration checked figure is positive and equals the case 5 count on the
dedicated v0.26.0 run; and the downstream column is written up as a handoff
rather than claimed as done.

**The full inventory check is a criterion here, not a description of behavior.**
The retained evidence carries the walked and selected counts and populations, and
the assertions are the ones the plan states once and Steps 2 and 4 use verbatim:
the 110 flagged libraries as case 4, the python program asserted by name, since
its omission is the failure the requirement's acceptance was written to catch,
the enumerated git objects, and every other archive program preserved as case 7,
so an excluded program quietly rewritten fails this step. Every retained capture
is accepted by the Step 3 categorical reader rather than read by eye: a capture
no reader accepted is not acceptance evidence.

The RHEL evidence comes from one ordered acceptance session, not from two
machine visits. The session records one run identity, the exact target identity
and its Bash version, then runs the exact-target `declare -A` check before the
installer is invoked, then deploys and measures preload under that same run
identity, and only then judges the monitoring branch. Any monitoring evidence
arriving afterwards names that same run identity, so a late answer cannot be
attached to a run it did not describe.

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

_(empty — no check has taken place yet.)_.

### New types or classes introduced for Step 6

_(empty — no check has taken place yet.)_.

### Architecture check for Step 6

_(empty — no check has taken place yet.)_.

### Performance check for Step 6

_(empty — no check has taken place yet.)_.

### Unit test coverage check for Step 6

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 6

_(empty — no check has taken place yet.)_.
