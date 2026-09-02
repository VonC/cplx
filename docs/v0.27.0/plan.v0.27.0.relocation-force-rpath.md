# v0.27.0 relocation-force-rpath implementation plan

Reference issue: [issue.v0.27.0.relocation-force-rpath.md](issue.v0.27.0.relocation-force-rpath.md)
Reference design: [design.v0.27.0.relocation-force-rpath.md](design.v0.27.0.relocation-force-rpath.md)
Reference environments: [reference.environments.md](reference.environments.md)

This plan introduces no design choice. Every rule it schedules is settled in the
requirement's twelve clarifications or the design's seven decisions, and where a
step needs a choice this plan does not own, it says which document owns it.

## How this plan departs from the standard template

The template assumes a Python project: `pytest` files under `tests/unit/...`,
`__init__.py` companions, a `ghog day` walk, `check.bat`, and a big-file gate at
650 lines. cplx has none of those. It carries no `tests/` tree, no
`pyproject.toml`, no `check.bat` and no `GROUNDHOG.md`, and the file this effort
changes is Bash. The substitutions below are stated once here rather than
re-explained per step, and each keeps the property the template was protecting.

| Template element | This effort | Why the property survives |
| --- | --- | --- |
| `pytest` unit tests under `tests/unit/**` | cases in a Bash harness, `docs/v0.27.0/verify.relocation-rpath.sh` | item 1 of this collection validated the same file this way, through `verify.install-pkg.sh`, and its evidence is retained beside it |
| `__init__.py` upkeep | none | there are no Python packages to register |
| `ghog day` walk | one harness walk plus `shellcheck` on every changed script | the property is "one command runs the gate and the tests and stops at the first failure", which the walk keeps |
| `check.bat` | `src/utils/lint_shell.sh`, which runs `shellcheck` over every tracked script outside `docs/`, using the `.shellcheckrc` and inline `# shellcheck disable=` directives the project already has | it is the lint gate this repository actually has, and one command runs it over the whole repository |
| the 650-line Python ceiling | the line budget of `install_pkg.sh`, tracked per step | the gate scans Python under `tools` and `tests` and does not reach this file, but its size is a real constraint for a different reason, recorded in the confirmed facts |

The `check.bat` substitution is **declared, not only stated**. `.review-validation`
at the repository root names `src/utils/lint_shell.sh` as this repository's mandatory
validation floor, and the shared code-review resolver reads it instead of assuming
the Python default. Prose in a plan cannot be checked by a tool; that file can, so
the two cannot drift apart.

The harness substitution is deliberately **not** declared there. That file binds
every future review of this repository, and a walk of `verify.relocation-rpath.sh`
is this effort's check, not the project's: it should retire when v0.27.0 does. It
enters the resolved validation set as a plan addition instead, which is the scope
that matches its lifetime.

## Confirmed facts this plan is built on

**`install_pkg.sh` is 625 lines today.** The repository big-file gate does not
apply to it, since `check_big_files.bat` scans Python under `tools` and `tests`.
The constraint is different and stronger: the script is deployed as a standalone
file next to an archive on a bare account, sources `echos` from beside it or one
level up, and falls back to inline definitions when neither exists (lines 17 to
34). Anything this effort adds either lives in that one file or becomes a second
file the deployment has to carry. This plan keeps it in one file and tracks the
cost per step; Step 4 is where that decision is re-examined against measurement,
being the last step that adds production code.

**The pass already walks and filters.** `fix_elf_paths` (line 362) reads the
first four bytes with `head -c 4 | od` (line 397) and the walk at line 423
prunes and selects. The observer of Step 1 extends that reading rather than
replacing the walk.

**The four patchelf calls are at lines 403, 405, 414 and 416**, and
`find_patchelf` at line 301 resolves the binary with a non-fatal absent path.

**The archive ships no fixtures today, and this effort commits none.** Step 1's
ELF fixtures are generated into the harness scratch directory from committed
text in `verify.relocation-rpath.sh`, so nothing binary enters the repository
and nothing changes about what the archive carries.

## File-based IO cost clarification for v0.27.0 relocation-force-rpath

The pass runs once per install over a tree of a few thousand files, of which
several hundred are ELF. The design adds one structural read per walked ELF, on
bytes the walk already opens to check the magic number, and removes work in the
same move: a probe is skipped when the structure proves it inapplicable, so an
object with no dynamic section costs one read instead of a read plus a patchelf
fork. Reading a header is cheaper than forking patchelf, so the expected change
is a reduction in process count and a small increase in bytes read.

The rule this effort holds to: **no step may add a second full walk of the tree
to the production ELF pass**. Every figure the report carries is accumulated
during the single existing walk in `fix_elf_paths`, and the record stream is
written as the walk proceeds rather than gathered and emitted at the end. A step
that finds itself wanting a second production pass has found a design question,
not an implementation one, and stops.

The rule is about the installer, not about validation. The harness may walk a
prepared prefix as often as its cases require, and Step 6's acceptance reads a
relocated tree repeatedly; none of that runs on a deployment.

---

## Step 0 analysis and intent

### Step 0 issues

There is no way to tell whether this effort changed anything. The current pass
prints one mixed count, and no baseline of the current tree's dispositions
exists. Item 1 met this and answered it with a harness that captured the current
behavior before any code changed; without the same here, every later step would
be judged against a description.

### Step 0 fix intent

Build the executable oracle first, and open the seam every later step's tests
need. The installer changes in this step, but only structurally: two function
definitions move and a guard is added, with no change to what an executed run
does.

### Step 0 expected outcome

A harness that runs the current installer against a prepared prefix and records
what it does, so Steps 1 to 6 are measured against a capture rather than against
this plan's prose. The same step establishes the two capability facts and the
source-safe seam every later step depends on.

### Step 0 framings

It is Step 0 rather than Step 1 because it changes no production behavior, and
because its output is the input to every later step's completion criteria. It
does touch the installer, which is why "writes no production code" is not the
framing: the seam is a rearrangement, and the earlier version of this plan that
claimed no installer change was contradicted by its own file list.

### Step 0 complexity impact

Adds one file under `docs/v0.27.0/` and moves two function definitions in
`install_pkg.sh` behind an explicit main boundary. No behavioral complexity: the
executed path is unchanged.

### Step 0 feature preservation

Nothing to preserve; nothing changes.

## Step 0 implementation

### Step 0 files involved

- `docs/v0.27.0/verify.relocation-rpath.sh` (new, to be created)
- `src/setups/env/bin/install_pkg.sh` (existing, to be updated): the main
  boundary, the source guard, and the two function definitions that move above
  it; no change to what an executed run does

### Step 0 capability gate

Three things must be established before Step 1 writes a line, because each is an
assumption the plan would otherwise carry silently into the implementation.

- **Associative arrays on both targets.** The observation tuple is one
  associative array (Q05), so `declare -A` must work on Debian 12 and on the
  RHEL 9.8 target. Debian 12 ships Bash 5.2, so the Debian side is documented.
  This is an interpreter capability, not a new external program, so the
  host-tool contract is unaffected.

  The check has **three** outcomes, not two, because "we could not ask" is not
  an answer:

  | Outcome | What it means | What happens |
  | --- | --- | --- |
  | supported | the check ran and `declare -A` works | Step 1 proceeds |
  | unsupported | the check ran and it does not work | stop and revise the plan; do not fall back quietly to loose variables |
  | unavailable | the exact target could not be reached to ask | Step 0 is recorded as blocked, unless representative version-pinned RHEL 9.8 or UBI evidence is captured instead, in which case Steps 1 to 5 proceed **provisionally** and exact-target confirmation becomes a debt due in Step 6 |

  The distinction matters because an unavailable check is not evidence of an
  unsupported shell, and treating it as one would revise the plan away from the
  safer carrier on the strength of a machine nobody could log into.

  **The provisional branch is a loan, not a waiver.** Representative pinned
  evidence justifies writing the carrier; it does not satisfy the requirement's
  real RHEL deployment acceptance, and it must not be allowed to become a way of
  never running on the target. Step 6 closes it, and how it closes is fixed
  there rather than left to whoever runs the acceptance.
- **`readelf` on the validation host.** The fixture oracle of Step 1 needs it.
  It is a **harness prerequisite**, not an installer host tool: it never runs
  during an install and is never named in the installer.
- **GNU `sha256sum` on the validation host.** Step 1's shipped-patchelf content
  identity needs it, and the plan names the tool rather than leaving "such as a
  digest" as an implementation choice, since content identity is the only part of
  that check a double cannot forge: a binary can be replaced at the same path,
  and a double can print the same version string. It is a **harness
  prerequisite** on the same footing as `readelf`, never an installer host tool.

  Step 0 must resolve it to an executable on the validation host and record that
  capability before Step 1. If it is absent the harness gate is **incomplete**.
  That is not permission to weaken the identity to path plus version, which is
  exactly what the digest exists to strengthen, nor to substitute a weaker
  checksum silently.

Both harness prerequisites are excluded from the installer **mechanically**, not
by intention: `readelf` and `sha256sum` are named in the execution checklist's
negative host-tool grep over `install_pkg.sh`, so an accidental production use is
detected rather than reasoned about. The installer's own host-tool contract is
unaffected, since neither ever runs during an install.

### Which host can answer which step

The plan said "the validation host" throughout and never said that it may not be
the machine the work is written on. That silence had a consequence: the first
Step 0 harness could not run the relocation pass where it was written, so it
inferred the baseline from the installer's source text instead, and the omission
made that look reasonable rather than wrong.

The steps do not all need the same host:

| Step | What it needs | Why |
| --- | --- | --- |
| 0 | Linux with `patchelf`, `readelf`, GNU `sha256sum` | its baseline runs the real pass over a real ELF |
| 1 | the same | ELF fixtures, the `readelf` oracle and patchelf probes |
| 2 | **two host classes**, see below | the controlled layer consumes tuples; the bridge and the inventory need real ELF objects |
| 3 | any host with Bash 4.0+ | the formatter, reader and corpus are text |
| 4 | Linux with `patchelf`, `readelf`, GNU `sha256sum` | integration rewrites real objects |
| 5 | any host | documentation coverage |
| 6 | the RHEL 9.8 target | deployment, preload and monitoring |

**Step 2 is the row that is not one host.** The earlier version of this table gave
it "any host with Bash 4.0+", which described the controlled layer and quietly
omitted two thirds of the step. Its three layers do not need the same machine:

| Step 2 layer | What it needs | Why |
| --- | --- | --- |
| the controlled rows, the tuple invariants and the inventory controls | any host with Bash 4.0+ | they feed literal tuples to the classifier and drive the assertion functions directly |
| the producer-to-consumer bridge | Linux with `patchelf`, `readelf` and a program donor | it plants real ELF fixtures through `resolve_fixture_donor` and `plant_patchelf_double`, and refuses at `bridge/donor` on a host with no program to cut one from |
| the `develop#24` inventory | the same, plus the extracted archive and the recorded oracle | it walks real objects and classifies each one |

Both of the last two are completion criteria, not optional extras, so the step as
a whole is answered only on the Linux validation host. The distinction is not
academic: build 92 exercised the bridge for the first time on any machine, and
every earlier round measured the controlled layer alone while the bridge sat
unproven behind a `bridge/donor` refusal that a single-host row gave no reason to
expect.

Two rules follow, and both are properties of the harness rather than advice.

**A step this host cannot run must say so distinctly.** The harness declares what
a step needs and refuses when the host cannot supply it, with its own exit code
so that "cannot answer" is never read as "answered" or as "the code is broken".
Answering a cheaper question is what the refusal exists to prevent.

**The host-independent cases still run.** A missing prerequisite leaves the gate
incomplete and the run non-zero, but the cases needing neither prerequisite
report first, so a host missing one tool still learns whether the seam and the
host-tool contract hold. Only the cases that genuinely need a tool are skipped,
and they are named when they are.

**A check a host cannot afford is unanswered, not skipped.** The two rules above
treat a missing *tool* as the reason a host cannot answer. A third reason is
cost, and the allowlist corpus is the case that forced it.

The corpus proves the host-tool rule can report and can stay silent, over
eighty-three planted shapes. It is not slow by construction: each shape writes a
probe and runs `hc_unlisted` through a short pipeline, and `hc_unlisted` spends a
dozen more subprocesses reading the file, so the corpus costs on the order of
fifteen hundred process spawns. Linux answers that in **4.5 seconds**, measured
on the Debian agent at step 2 of build 92. A Cygwin host emulates `fork` in user
space and does not answer at all: measured at over five minutes and killed at the
bound, having never reached the step's own cases. That is a property of the
platform, roughly seventy to one, not of the machine or of the rule.

So the corpus is gated **by platform**, the same way `patchelf` and `readelf`
are, and for the same reason: the harness declares what a check needs and refuses
when the host cannot supply it. Where it is refused, the run reports it through
the third outcome, `UNANSWERED` and exit 5, and names the exact command that
would answer it. It is never silently skipped, because a fast local run that
reads as a clean one is precisely the failure this plan has refused elsewhere.

Coverage is unchanged where it decides anything. CI is Linux, so the corpus runs
there on every step of every build. What changes is that `--step N` now reaches a
verdict on the authoring host, in 43 seconds rather than never, which is what
lets a local run exercise the shipped harness instead of an extraction driver
standing in for it.

### Step 0 harness prerequisite preflight

The harness runs as `bash docs/v0.27.0/verify.relocation-rpath.sh --step N`, so
**each step is a fresh process**. A path resolved during the `--step 0` run
cannot survive into the `--step 1` run, and recording that a tool once existed
does not identify the executable a later run invokes. Step 0's job is to test and
record the preflight, not to hand Step 1 a value, and the plan says so because
"Step 0 recorded it" reads like an answer and is not one.

There is therefore **one reusable preflight**, run at the start of every harness
invocation that depends on the validation tools, **before the installer is
sourced and before any case-specific environment mutation**, so that nothing a
case sets up can influence what the preflight resolves:

1. resolve with Bash `type -P sha256sum`, which searches the command path and
   yields a path rather than a shell function or an alias of that name;
2. require the result to be an **absolute** path to a **regular file** that is
   **executable**;
3. verify the required GNU interface;
4. **only after all of the above succeed**, assign the value to one fixed harness
   variable and mark it read-only.

The ordering in point 4 is not stylistic. `readonly SHA256SUM_BIN="$(type -P
sha256sum)"` yields the exit status of `readonly`, not of the substitution, so a
failed resolution is masked and the variable is frozen empty, which is the worst
of both: no error, and an unusable pin that cannot be reassigned. Resolve, check,
then declare, in that order. `shellcheck` reports the combined form under SC2155,
so the gate this plan already runs catches a regression here rather than the
reader having to remember it.

Any resolution, file-property or interface failure leaves the gate
**incomplete**. The same shape applies to `readelf`, which is pinned the same
way; the two prerequisites differ in which interface is verified and in nothing
else.

Step 0 runs the preflight and records it, with the path it resolved, as
capability evidence. **Step 1 runs the same preflight again** and records the
path *it* will use. Step 1 neither inherits a path from Step 0 nor promises
equality with it, because two processes on a host that changed between them are
entitled to resolve differently, and the run's evidence should say what that run
actually invoked.

### Step 0 source-safe seam

The harness must call the observer and the classifier without performing an
install, and `install_pkg.sh` today continues from its function definitions
straight into argument parsing and deployment.

**The guard has no valid location in the current script, and creating one is
part of this step.** Checked against the file: the main flow begins at
`# --- 1. Argument Parsing ---` (line 428) with the `FORCE` and `TARGET`
assignments, and two functions are defined after it. `usage` is defined at line
432, inside the argument-parsing section it belongs to, and `select_copy_engine`
is defined at line 485 and called at 498. A guard placed after every function
definition would therefore sit after the flow it was meant to precede, and a
guard placed before the flow would leave those two functions undefined when the
file is sourced.

So the seam is three things, in order:

1. move the `usage` and `select_copy_engine` definitions above an explicit main
   boundary, leaving their call sites where they are;
2. mark that boundary, and place the sourced-versus-executed guard there: the
   script returns when `BASH_SOURCE[0]` differs from `$0`;
3. have the harness, after sourcing, assert that every production function it
   intends to call is defined, so a function accidentally left below the
   boundary is a loud failure rather than a silent absence.

Three properties this keeps. Executing the script is unchanged, since moving a
definition above its call site changes nothing about the executed path and the
guard is a no-op there. The tests exercise the production functions rather than a
copy, which neither a test-only CLI nor an extracted copy of the text would do.
And the third item turns the guard's load-bearing position from something a
reader must remember into something the harness checks.

### Step 0 test first

The harness is the test surface. Its own first case asserts that it fails when
its fixture is not planted, so a case cannot report a shape it never created.
That convention is taken from `verify.install-pkg.sh`, which the same collection
already reviewed.

### Step 0 behavior

`--step N` selects the cases for one step, so later steps extend the file rather
than adding files. `--installer PATH` and `--prefix DIR` are asserted against
what the case declared, so a case cannot silently exercise the wrong copy.

Cases in this step capture the current behavior only: the mixed `Fixed <n>` line
over a prepared prefix, and the tag every rewritten object carries, which is
`DT_RUNPATH` before this effort.

### Step 0 completion criteria

- the harness runs against the installer and records a baseline;
- the baseline names the object count, the current mixed count and the observed
  tag on a rewritten object;
- sourcing the installer defines its functions and performs no install, proved
  by a case that sources it in a subshell and asserts the prefix is untouched;
- after sourcing, the harness asserts every production function it will call is
  defined, so nothing is left below the boundary unnoticed;
- executing the installer behaves exactly as before the rearrangement, proved
  against the Step 0 baseline itself;
- the associative-array check records one of its three outcomes for the RHEL 9.8
  target, with Debian 12 documented;
- **the harness prerequisite preflight runs and is recorded with the paths it
  resolved**, for `readelf` and for GNU `sha256sum`: `type -P`, an absolute
  regular executable path, the required interface, and only then the read-only
  pin, in that order, so a failed substitution cannot be masked by the
  declaration builtin. Any resolution, file-property or interface failure leaves
  this gate **incomplete**, and no absence licenses a fallback, not path plus
  version in place of a digest and not another checksum chosen quietly. What is
  recorded is that the preflight passed here, not a value later steps may reuse:
  each dependent step reruns it in its own process;
- `shellcheck` is clean on both files.

## Step 0 addendums

### Step 0 line budget checkpoint

- `install_pkg.sh`: 625 lines. The change is the guard plus moving two function
  definitions, so the net is close to zero and the figure to record is the
  **measured** net change rather than an estimate of the guard alone. The
  earlier "3 to 5 lines" was wrong because it counted only the guard.
- `verify.relocation-rpath.sh`: new. No ceiling applies; the reference point is
  `verify.install-pkg.sh`, which the collection accepted at its reviewed size.

### Step 0 workflow timing readiness

The harness must run to completion inside one walk of a prepared prefix. If it
needs longer than the item 1 harness took, the extra time is reported in the
capture rather than absorbed.

### Step 0 time-gated status

Not started.

---

## Step 1 analysis and intent

### Step 1 issues

The classifier cannot be written before something can answer, for one object,
what kind it is, whether it has a dynamic section, whether it has an interpreter,
and which tag holds its search path. `patchelf --print-rpath` answers none of
those four.

### Step 1 fix intent

Implement the observer of Design Area 1: one structural read producing the
normalized named tuple, with `structural_status`, the two probe statuses, and the
clearing rule on structural failure.

### Step 1 expected outcome

A callable observation with a defined result for every input, including the
inputs no archive should contain.

### Step 1 framings

Before the classifier, because the classifier is a decision over this tuple and
cannot be tested without it.

### Step 1 complexity impact

The largest single addition of the effort. It is where the line budget of
`install_pkg.sh` is first at issue.

### Step 1 feature preservation

The pass is not yet wired to the observer, so the installer behaves exactly as
before at the end of this step.

## Step 1 implementation

### Step 1 files involved

- `src/setups/env/bin/install_pkg.sh` (existing, to be updated)
- `docs/v0.27.0/verify.relocation-rpath.sh` (existing, to be updated): carries
  the fixture generator as committed text

No committed fixture directory exists. The fixtures are generated into the
harness scratch directory the run already creates and removes, so nothing binary
enters the repository and nothing is left behind.

### Step 1 fixture oracle, independent of the observer

The fixtures cannot be validated by the thing they exist to test. A generator
that writes `e_type` at the wrong offset and an observer that reads that same
wrong offset agree with each other, and every generated fixture goes green while
neither is right.

**Provenance is not semantics, and the previous version of this section confused
them.** Asserting that a derivative differs from its base at exactly one offset
proves the generator changed what it meant to change. It does not prove that the
offset is `e_type`. If the generator and the observer share a wrong belief about
where `e_type` lives, a single-mutation assertion at that wrong offset passes,
and so does the observer. Every fixture therefore needs an oracle that states
what the bytes **mean**, sourced independently of the observer:

- **Where `readelf` can express the state**, it is the semantic oracle:
  validation-only `readelf` confirms that the ordinary `ET_EXEC`, PIE, shared
  library and `e_phnum == 0` fixtures really are those shapes, and that the
  `DT_RPATH`, `DT_RUNPATH` and both-tag fixtures really carry those tags. It is
  a harness prerequisite recorded in Step 0 and never runs during an install.
- **Where it cannot**, because the fixture is deliberately malformed and no tool
  will name the state it is in, the oracle is a manifest of offsets and values
  taken from the ELF specification. Calling it golden is not enough; it has to be
  auditable, because it is hand-derived and nothing downstream will question it.
  Each entry records, literally:

  | Column | Content |
  | --- | --- |
  | id | a stable `Mnn`, cited by every fixture the mutation constructs |
  | field | the ELF field name, `e_phentsize` and so on |
  | offset | its byte offset, absolute or relative to a named structure |
  | width | its size in bytes |
  | byte order | little-endian, the domain's only value, stated per entry rather than assumed |
  | original bytes | the value the lawful base carries there |
  | replacement bytes | the value the malformed derivative carries |
  | citation | the exact ELF specification section or table the offset and width come from |

  Lawful generation recipes and whole-file operations get ids in the same
  namespace, `Gnn` and `Xnn`, and carry a recipe rather than an offset pair,
  because a fixture built by emitting a different program header table or by
  truncating a file has no single mutated range. Every fixture cites either all
  its `Mnn` ids or exactly one `Gnn` or `Xnn` id, and nothing else. **Zero
  fixture mutations lack a manifest entry and zero manifest entries lack a
  fixture or guard that uses them.**

  Three cross-checks anchor the manifest to something outside itself, which is
  what stops a hand-derived table being trusted merely because it is written
  down. The previous version had two, and one of them claimed more than it can
  deliver:

  - **layout confirmation, over the whole object.** The lawful base is emitted at
    the manifest's own offsets and widths, and `readelf -h`, `readelf -l` and
    `readelf -d` then parse it and report exactly the intended value for every
    field the manifest names. This is the check that ties offsets to fields: a
    manifest entry at the wrong offset puts the value somewhere `readelf` does
    not look, so either the parse fails or a reported value disagrees, against a
    tool that never read the manifest;
  - **value cross-check, per entry.** For each `Mnn`, the bytes at the stated
    range in the base, decoded at the stated width and byte order, equal the
    number or token `readelf` reports for that field. This is per-entry evidence
    that layout confirmation gives only in aggregate;
  - **alternate pair, where this fixture set provides one.** Two lawful bases
    that `readelf` reports as differing in exactly one field differ in bytes at
    exactly that field's stated range.

  The third has now been overclaimed twice in opposite directions, and both
  corrections are recorded because the column is load-bearing. It was first
  recorded as available for `e_phoff`, `p_offset` and `p_filesz`, which the
  base and recipe set does not provide. The correction then said those pairs are
  **not constructible**, and that is false as stated: two otherwise identical
  lawful files can carry identical program header tables at two offsets and
  differ only in `e_phoff`; can carry identical segment bytes at two congruent
  offsets and differ only in `p_offset`; and can carry the same slack bytes with
  adequate `p_memsz` and differ only in `p_filesz`. Those are artificial objects,
  but they are lawful, so "impossible" was a universal claim made without
  checking it, which is the same error the column already carried once.

  The status is therefore about **this plan's selection, not about what ELF
  permits**, in four statuses:

  | Status | Meaning |
  | --- | --- |
  | provided | this fixture set builds the pair, and the check runs |
  | not provided | a lawful pair exists but building it needs a second purpose-built base whose only difference is that field, serving no guard of its own |
  | no lawful pair in this profile | the field's lawful domain under ELF64, little-endian, x86-64 holds exactly one value, so there is no second value to pair with |
  | not applicable | there is no field pair at all, the row being a file operation or an invariant over a carrier rather than a field value |

  The third status is kept distinct rather than folded into either neighbour,
  because "a pair exists and this plan declines to build it" and "the domain has
  one value" are different facts and only the first could be revisited by
  changing the recipe set. It is scoped to the profile rather than to ELF at
  large, which is the discipline the retracted claim above lacked.

  **This plan provides three pairs**: `F01` against `F02` on `e_type`, the base
  against `F16` on `e_machine`, and `F06` against `F07` on the search-path
  `d_tag` over an unchanged `d_un` and string. Each is a classification value
  that changes while every other byte stays lawful and identical, which is why
  they are cheap here and the others are not. Every entry without a provided pair
  rests on layout confirmation and the per-entry value cross-check, which are the
  checks that were carrying the weight in any case.

  The generator and the observer do not import constants from this manifest. It
  is a validation table read by the cases; a shared constant would put the
  manifest back on the same side as the thing it checks.
- **Provenance checks remain**, the exact size and the single changed offset,
  as additional evidence that the generator did one intended thing. They are not
  the semantic oracle and are not sufficient on their own.

#### The exhaustive unit is the fixture, not the field name

An earlier version of this section claimed every mutated **field** was
classified exactly once. That unit was wrong, and wrong in a way that hid work
rather than merely misdescribing it. Two of its rows, "dynamic entry size" and
"`DT_NULL` termination", are not stored ELF fields at all. `Elf64_Dyn` consists
of `d_tag` and `d_un`, two eight-byte members, so the sixteen-byte entry size in
this domain follows from that fixed layout rather than from any field a fixture
could write; and `DT_NULL` is a `d_tag` **value** that terminates the entry
sequence, not a separate stored item. Both are stated in the LSB dynamic-section
definition and in Linux `elf(5)`:

- <https://refspecs.linuxfoundation.org/LSB_5.0.0/LSB-Core-generic/LSB-Core-generic/dynamicsection.html>
- <https://man7.org/linux/man-pages/man5/elf.5.html>

A fixture for a bad dynamic-entry extent therefore has to mutate a real carrier,
`PT_DYNAMIC`'s `p_filesz` or the file's own length; a missing terminator has to
replace the terminating entry's `d_tag`, or shorten the segment or the file.
Those operations reuse carriers that other rows already name, so "each field
exactly once" both counted concepts as fields and forbade the table from
describing the fixtures actually built.

The exhaustive unit is therefore **each fixture and each rejection guard**. One
carrier may appear in several rows when different mutations prove different
rules, which is the normal case rather than a defect: `d_tag` proves tag
identity in one row and non-termination in another, and `p_filesz` proves a
bounds violation in one row and a non-integral entry count in another.

Every fixture carries a stable `Fnn`, cites the ids that construct it, and names
the reader guard it exercises, its semantic oracle with citation, its
alternate-pair status, and its **complete** expected tuple. A fixture
cites either all the `Mnn` mutations applied to a named base, or exactly one
`Gnn` lawful generation recipe or `Xnn` file operation. Prose such as "no
`PT_INTERP` emitted" or "set past the file" is not a citation and does not
appear in a row: those are recipes, and a recipe gets an id and a definition of
its own.

The bases and recipes:

| Id | What it emits |
| --- | --- |
| `G01` | the lawful base `B0`: `ET_EXEC`, ELF64, little-endian, `EM_X86_64`; program header table of `PT_INTERP`, `PT_LOAD`, `PT_DYNAMIC`; `PT_INTERP` naming `/lib64/ld-linux-x86-64.so.2`; `PT_DYNAMIC` holding `DT_NEEDED`, `DT_STRTAB`, `DT_NULL`; a string table inside the loaded segment. Every field is written at the manifest's own offset and width |
| `G02` | `B0` with `e_type` `ET_DYN` and no `PT_INTERP` entry, `e_phnum` and the table rewritten accordingly |
| `G03` | `B0` with no `PT_DYNAMIC` entry, `e_phnum` and the table rewritten accordingly |
| `G04` | `B0` with an added `DT_SONAME` entry before `DT_NULL` |
| `G05` | `B0` with an added `DT_RPATH` entry whose `d_un` addresses the string `/opt/cplx-probe/lib` |
| `G06` | `B0` with `e_phnum` zero and no program header table emitted |
| `G07` | `B0` with two added entries, `DT_RPATH` addressing `/opt/cplx-probe/rpath` and `DT_RUNPATH` addressing `/opt/cplx-probe/runpath` |
| `G08` | `B0` with two added `DT_RPATH` entries addressing `/opt/cplx-probe/rpath-a` and `/opt/cplx-probe/rpath-b` |
| `X01` | truncate `B0` to 32 bytes, longer than the four magic bytes the walk filters on and shorter than the 64-byte ELF64 header |

The mutations, each an entry in the manifest with its offset, width, byte order,
original bytes, replacement bytes and citation:

| Id | Field and range | Change | Applied to |
| --- | --- | --- | --- |
| `M01` | `e_type`, 2 bytes at `0x10` | `02 00` to `03 00`, `ET_EXEC` to `ET_DYN` | `G01` |
| `M02` | `e_type`, 2 bytes at `0x10` | `02 00` to `01 00`, `ET_EXEC` to `ET_REL` | `G06` |
| `M03` | the search-path entry's `d_tag`, 8 bytes at its offset in `PT_DYNAMIC` | `0f 00 …` to `1d 00 …`, `DT_RPATH` to `DT_RUNPATH`, `d_un` and the string unchanged | `G05` |
| `M04` | `e_ident[0..3]`, 4 bytes at `0x00` | `7f 45 4c 46` to `7f 45 4c 47` | `G01` |
| `M05` | `e_ident[EI_VERSION]`, 1 byte at `0x06` | `01` to `00`, `EV_CURRENT` to `EV_NONE` | `G01` |
| `M06` | `e_ident[EI_CLASS]`, 1 byte at `0x04` | `02` to `01`, `ELFCLASS64` to `ELFCLASS32` | `G01` |
| `M07` | `e_ident[EI_DATA]`, 1 byte at `0x05` | `01` to `02`, `ELFDATA2LSB` to `ELFDATA2MSB` | `G01` |
| `M08` | `e_machine`, 2 bytes at `0x12` | `3e 00` to `b7 00`, `EM_X86_64` to `EM_AARCH64` | `G01` |
| `M09` | `e_phnum`, 2 bytes at `0x38` | the base's count to `ff ff`, `PN_XNUM` | `G01` |
| `M10` | `e_phentsize`, 2 bytes at `0x36` | `38 00` to `20 00`, 56 to 32, with `e_phnum` left nonzero | `G01` |
| `M11` | `e_phoff`, 8 bytes at `0x20` | the base's offset to the base's file size plus 16 | `G01` |
| `M12` | the `PT_LOAD` entry's `p_offset`, 8 bytes at entry `+0x08` | the base's offset to the base's file size plus 16 | `G01` |
| `M13` | that entry's `p_filesz`, 8 bytes at entry `+0x20` | the base's size to a length carrying the segment past the file end | `G01` |
| `M14` | `PT_DYNAMIC`'s `p_filesz`, 8 bytes at entry `+0x20` | the base's multiple of 16 to that value plus 8 | `G01` |
| `M15` | the terminating entry's `d_tag`, 8 bytes at its offset | `00 00 …` to `01 00 …`, `DT_NULL` to `DT_NEEDED`, `p_filesz` unchanged | `G01` |
| `M16` | `e_phnum`, 2 bytes at `0x38` | the base's count to `00 00`, a lawful zero meaning the object carries no program header table | `G01` |
| `M17` | a `PT_LOAD` entry's `p_offset`, 8 bytes at entry `+0x08` | the base's offset to `f0 ff ff ff ff ff ff ff`, an unsigned value at `2^64-16` | `G01` |
| `M18` | a `PT_LOAD` entry's `p_offset` and `p_filesz`, 8 bytes each at entry `+0x08` and `+0x20` | the base's values to `00 00 00 00 00 00 00 40` each, which is `2^62`: each decodes exactly, and only their sum passes `2^63` | `G01` |

Every accepted and ambiguous fixture states **both probe statuses, whether each
probe value is present, and the literal value when the status is `ok`**. The
probes are fields of the observer contract, not a later concern, and an earlier
version of this section narrowed the tuple it claimed to test by calling them
the pass's business. The Step 1 case therefore invokes the production probe step
on the fixture after the production observer returns, and asserts every named
field of the array. That widens this step by the probe invocation, which is a
call and an assertion rather than a redesign.

**Probe coverage is categorical, not proportional**, and the previous version of
this passage got that wrong in a way that would not have survived its own
sequencing. It said a refusal across most fixtures leaves the probe axis untested
and is reported at Step 4. That cannot happen: `F01` to `F07` and `F10` state
literal `ok` outcomes, Step 1 requires each fixture to produce exactly its tuple,
and the execution stops at the first step that is not green, so Step 4 is
unreachable from a Step 1 whose witnesses failed. The fallback described a report
that could never be written. It was also the wrong shape regardless of
sequencing: ten honest `failed` results do not substitute for one missing
success, because what the classifier relies on is a behavior, not a proportion.

Every behavior the design and the classifier rely on therefore has at least one
**named witness**, and zero probe obligations are uncovered:

| Obligation | Witness | Expected |
| --- | --- | --- |
| an applicable rpath probe on an object with no search-path tag answers with an empty value | `F01`, with `F02` and `F05` as further instances | rpath `ok`, value present and empty |
| `DT_RPATH` answers with its stored value | `F06` | rpath `ok`, value `/opt/cplx-probe/lib` |
| `DT_RUNPATH` answers with its stored value, which is the design's finding that one query serves both tags | `F07` | rpath `ok`, value `/opt/cplx-probe/lib` |
| with both tags present the probe returns the `DT_RUNPATH` value, the preference a case 5 disposition rests on | `F10` | rpath `ok`, value `/opt/cplx-probe/runpath` |
| a present interpreter answers with the interpreter | `F01`, and every other fixture carrying `PT_INTERP` | interp `ok`, value `/lib64/ld-linux-x86-64.so.2` |
| structure proves the rpath probe inapplicable | `F04`, with `F08` and `F09` | rpath `skipped`, no value |
| structure proves the interpreter probe inapplicable | `F03`, with `F08` and `F09` | interp `skipped`, no value |
| an inconclusive structure blocks both axes | `F12` to `F25` | both `blocked`, neither value present |
| the rpath probe fails while the interpreter axis survives | `D01` | rpath `failed`, no value; interp `ok` with its value |
| the interpreter probe fails while the rpath axis survives | `D02` | interp `failed`, no value; rpath `ok` with its value |

**A witness that returns `failed` where `ok` was expected leaves Step 1
incomplete.** There are two ways forward and no third: repair the lawful
generation recipe until the named witness works with the shipped patchelf, or
stop and revise Q03's fixture-source decision under review. Rewriting an expected
`ok` to `failed` so that the first generated bytes pass is not one of them, and
naming that is worth the sentence, because it is the cheapest move available at
exactly the moment the suite is red.

The two `failed` witnesses are **deliberate, not opportunistic**. `D01` and `D02`
are **producer witnesses at this step and nowhere else**: they run the production
probe step over `F01`, the lawful program base, with a controlled patchelf
double, so the production code path is the one under test. `D01`'s double fails
`--print-rpath` and answers `--print-interpreter`, `D02`'s does the converse.

The scoping matters because Step 4 has its own fault runs over different
subjects, and for one round the same two identifiers meant both. They are now
disjoint: `D01` and `D02` are producer witnesses over `F01`, whose surviving axes
are `ok` with a value; Step 4's integration runs are `IF01`, `IF02`, `IW01` and
`IW02` over enumerated integration objects. Step 2's bridge consumes the
**producer** ones, `D01` and `D02`, since it runs before Step 4 exists.
Each asserts the complete array, including the surviving axis's status and
literal value, which is what proves the fault is axis-local. Step 2's controlled
tuples prove the classifier **consumes** `failed`; they do not prove the
production probe **produces** it or leaves the other axis intact, and the two are
different claims.

#### Bounding the doubles

A double is a fault injected into the tool every other witness depends on, and
the previous version said only that it was installed "where `find_patchelf`
resolves". That is not a boundary. It names no surface, no restoration and
nothing that establishes which binary the next witness used, and a double left
behind would serve every later expected-`ok` fixture while the complete tuples
and the zero-uncovered-obligations rule stayed green, because the double is
expressly able to return literal successful values. The consequence is not
untidiness: it changes what the positive evidence means.

`find_patchelf` resolves over **three ordered surfaces**, confirmed by reading
lines 301 to 314: `$INSTALL_PREFIX/tools/bin/patchelf`, then
`$HOME/tools/bin/patchelf`, then `command -v patchelf`. The third reads the
command search path and also finds a shell function or an alias of that name, so
all three are injection surfaces and all three are containment obligations.

Containment. Each of `D01` and `D02` runs in its **own subshell** with a private
scratch `INSTALL_PREFIX`, a private scratch `HOME` and a private command-search
directory. Only that case's double is installed, only inside that scratch state,
and an exit trap removes it. Before the production probe runs, the case asserts
that production `find_patchelf` returns **exactly that case's expected double
path**, so a case that silently resolved something else fails rather than passing
for the wrong reason. The double never overwrites, modifies or shadows the
canonical shipped patchelf in place.

The isolation invariant is asserted rather than assumed. The parent's resolution
inputs are captured before each subshell and asserted unchanged afterwards, and
no double file, resolved-tool variable, cache, shell function, alias or injected
search location may survive into the other fault case or into any positive
witness. **Scheduling `D01` and `D02` last is not a substitute**: it hides
contamination instead of testing for it, which is the opposite of what the two
cases exist to do.

Positive identity. Containment on its own proves only that the known injection
was removed, and the interesting failure is the unknown one. So before the fault
cases the harness records the canonical shipped patchelf's **resolved absolute
path, its version and its content identity**. All three are recorded and only the
third is decisive: a binary can be replaced at the same path, and a double can
print the same version string, so the digest is load-bearing evidence rather than
a corroborating detail.

The mechanism is named rather than left open. The identity is a **GNU
`sha256sum`** digest, computed fail-closed. This step begins by running the
harness prerequisite preflight for its own process, pinning `$SHA256SUM_BIN`, and
recording the path that run will use; every digest below invokes **that absolute
path and never the bare command name**:

1. invoke `"$SHA256SUM_BIN" -- "$resolved_patchelf_path"` on the exact absolute
   path `find_patchelf` returned, capturing the command substitution;
2. treat a nonzero result as a failure of this step, never as an empty identity;
3. take the first whitespace-delimited field with Bash parameter expansion, so no
   further external tool enters the harness to parse the output;
4. require that field to be **exactly 64 lowercase hexadecimal characters**, and
   fail otherwise. A short, empty or oddly-cased value is a defect in the
   measurement, and accepting it would silently compare nothing against nothing.

A bare `sha256sum` lookup after the preflight is prohibited. The pin exists so
that what verifies the restoration cannot itself be resolved through a command
path that a case has touched, and a single bare call would give that back.

The **ordering is fixed**, and every digest happens in the parent process:

1. the parent runs the preflight and pins `$SHA256SUM_BIN`;
2. the parent computes and records the initial digest;
3. `D01`, or `D02`, runs in its private subshell;
4. the subshell exits, so its private command-search directory and scratch
   `INSTALL_PREFIX` and `HOME` are no longer in effect;
5. the unchanged-parent resolution assertions pass;
6. the parent recomputes the digest over the path `find_patchelf` now returns,
   through the same pinned checksum path;
7. the digests must be equal;
8. `F06` runs as the sentinel.

The checksum executable is **never resolved inside a fault subshell**. The
subshell may inherit the read-only variable, since inheriting a pinned absolute
path is harmless, but it neither resolves nor replaces the executable. Steps 6
and 7 sit after step 4 rather than inside the subshell for the same reason the
sentinel does: a measurement taken while the injected state is still active
describes the injection rather than the restoration.

The sentinel is **`F06`**, and the choice is deliberate: its expected tuple is
`ok` with a non-empty literal on both axes, `/opt/cplx-probe/lib` and
`/lib64/ld-linux-x86-64.so.2`. `F01` would be the weaker choice, because its
expected rpath value is empty, so a leaked double that answered with nothing
would satisfy it. A sentinel whose expectation an impostor can meet is not a
sentinel. Failure of the identity assertion or of the sentinel is a **Step 1
failure**, which is what makes leakage an observed event rather than an inferred
absence.

Finally, a controlled double is never evidence for a successful shipped-patchelf
obligation. The witness matrix's five `ok` rows are satisfied by the shipped
binary or not at all.

Where the intended value turns on behavior the design does not fix, the plan says
so and the fixture has a lifecycle rather than an expectation: before the first
run the predeclared expectation is the status and the presence of a value, not
the value itself; the first run records the literal value with the patchelf
version as a measurement; from then on that recorded value is frozen and asserted
like any other, and a change is a finding. `F11` is the only such fixture, and it
is **not a witness for any obligation above**.

Accepted shapes, where no guard rejects. Every row is `structural_status: ok`:

| Id | Fixture | Guard exercised | Built from | Semantic oracle and citation | Alternate pair | Expected tuple |
| --- | --- | --- | --- | --- | --- | --- |
| `F01` | ordinary `ET_EXEC`, the lawful base | none; this is what every other row is measured against | `G01` | `readelf -h` names `ET_EXEC`, `EM_X86_64`, ELF64 and little-endian; `readelf -l` names `PT_INTERP` and `PT_DYNAMIC`; `readelf -d` lists no search-path tag (`elf(5)`, LSB dynamic section) | **provided**, with `F02` on `e_type` | `exec`, dynamic yes, interp yes, `tag_state: none`; rpath probe `ok`, value present and **empty**; interp probe `ok`, value `/lib64/ld-linux-x86-64.so.2` |
| `F02` | PIE | none | `G01` + `M01` | `readelf -h` names `DYN` | **provided**, with `F01`, differing at `0x10..0x11` and nowhere else | `dyn`, dynamic yes, interp yes, `none`; rpath `ok`, empty; interp `ok`, `/lib64/ld-linux-x86-64.so.2` |
| `F03` | shared library | none | `G02` | `readelf -h` names `DYN`; `readelf -l` lists no `INTERP` | not provided; dropping a program header changes `e_phnum` and the whole table, so the pair would need a purpose-built second base | `dyn`, dynamic yes, **interp no**, `none`; rpath `ok`, empty; interp **`skipped`**, no value |
| `F04` | no `PT_DYNAMIC` | none | `G03` | `readelf -l` lists no `DYNAMIC` | not provided, same reason as `F03` | `exec`, **dynamic no**, interp yes, `none`; rpath **`skipped`**, no value; interp `ok`, `/lib64/ld-linux-x86-64.so.2` |
| `F05` | dynamic with tags but none of them search-path | the dynamic scan, passing | `G04` | `readelf -d` lists `SONAME` and neither `RPATH` nor `RUNPATH` (LSB dynamic section) | not provided; the added entry changes `p_filesz` too | `exec`, dynamic yes, interp yes, `none`; rpath `ok`, empty; interp `ok`, `/lib64/ld-linux-x86-64.so.2` |
| `F06` | `DT_RPATH` only | the dynamic scan | `G05` | `readelf -d` names `RPATH` (LSB dynamic section) | **provided**, with `F07` on the search-path `d_tag` | `exec`, dynamic yes, interp yes, `tag_state: rpath`; rpath `ok`, value `/opt/cplx-probe/lib`; interp `ok`, `/lib64/ld-linux-x86-64.so.2` |
| `F07` | `DT_RUNPATH` only | the dynamic scan | `G05` + `M03` | `readelf -d` names `RUNPATH` | **provided**, with `F06`, differing at that `d_tag`'s 8 bytes and nowhere else | `exec`, dynamic yes, interp yes, `tag_state: runpath`; rpath `ok`, value `/opt/cplx-probe/lib`, which is where the design's finding that `--print-rpath` answers for either tag is actually measured; interp `ok`, `/lib64/ld-linux-x86-64.so.2` |
| `F08` | `e_phnum == 0` | `e_phnum` in ordinary form, passing; the four table-dependent guards **do not apply** | `G06` | `readelf -h` prints a zero count and `readelf -l` reports no table | not provided; a second lawful count implies a different table | `exec`, dynamic no, interp no, `none`; **both probes `skipped`**, neither value present |
| `F09` | `ET_REL` relocatable object | none | `G06` + `M02` | `readelf -h` names `REL` | not provided; `F09` is a lawful `ET_REL` and `F08` a lawful `ET_EXEC` differing at `0x10..0x11`, which is a pair this plan does not count, the `e_type` obligation already being met by `F01` against `F02` | **`elf_kind: unsupported`**, dynamic no, interp no, `none`; both probes `skipped`, neither value present |

Ambiguous shapes, which are **successful** observations rather than rejections.
Both rows are `structural_status: ok`:

| Id | Fixture | Guard exercised | Built from | Semantic oracle and citation | Alternate pair | Expected tuple |
| --- | --- | --- | --- | --- | --- | --- |
| `F10` | both tags | the dynamic scan, passing | `G07` | `readelf -d` lists `RPATH` and `RUNPATH` with their distinct strings | not provided; two added entries | `exec`, dynamic yes, interp yes, **`tag_state: ambiguous`**; rpath `ok`, intended value `/opt/cplx-probe/runpath`, which is where the design's stated patchelf preference for `DT_RUNPATH` is measured rather than assumed, a case 5 disposition resting on it; interp `ok`, `/lib64/ld-linux-x86-64.so.2` |
| `F11` | a duplicate of one tag | the dynamic scan | `G08` | `readelf -d` lists `RPATH` twice with distinct strings | not provided; two added entries | `exec`, dynamic yes, interp yes, **`tag_state: ambiguous`**; rpath `ok`, value present, the value itself measured and frozen on first run rather than predeclared, since which of two same-tag entries answers is not fixed by the design; **not a witness for any probe obligation**; interp `ok`, `/lib64/ld-linux-x86-64.so.2` |

Rejected shapes. Every row yields `structural_status: inconclusive`, every other
field cleared, both probe statuses `blocked` and neither value present:

| Id | Fixture | Guard exercised | Built from | Semantic oracle and citation | Alternate pair |
| --- | --- | --- | --- | --- | --- |
| `F12` | bad magic | identification, magic | `G01` + `M04` | `elf(5)` fixes the four-byte signature, which `readelf -h` prints on the base | no lawful pair in this profile; the four-byte signature has one lawful value |
| `F13` | wrong identification version | identification, version | `G01` + `M05` | `elf(5)`: `EI_VERSION` must be `EV_CURRENT`; `readelf -h` prints it | no lawful pair in this profile; `EV_CURRENT` is the only lawful `EI_VERSION` |
| `F14` | ELF32 | identification, class | `G01` + `M06` | `readelf -h` names the class (`elf(5)`) | not provided; a lawful ELF32 object differs across the whole header layout |
| `F15` | wrong byte order | identification, data encoding | `G01` + `M07` | `readelf -h` names the encoding | not provided; a lawful big-endian object byte-swaps every multi-byte field |
| `F16` | wrong machine | domain | `G01` + `M08` | `readelf -h` names the machine | **provided**; the base and this object are both lawful ELF headers differing at `0x12..0x13` and nowhere else |
| `F17` | extended `e_phnum` | `e_phnum` in ordinary form | `G01` + `M09` | `elf(5)` on `PN_XNUM` and the section-header escape | not provided; a second lawful count implies a different table |
| `F18` | file shorter than the ELF header | whole-header presence | `X01` | `elf(5)` fixes `Elf64_Ehdr` at 64 bytes; the base's pre-truncation size is the anchor | not applicable; a file operation with no mutated range |
| `F19` | `e_phentsize` wrong, nonzero count | program header entry size | `G01` + `M10` | ELF64 fixes `Elf64_Phdr` at 56 bytes (`elf(5)`); `readelf -h` prints it on the base | no lawful pair in this profile; ELF64 fixes `Elf64_Phdr` at 56 |
| `F20` | table past the file | table bounds | `G01` + `M11` | `readelf -h` prints the base's `e_phoff`, checked against the size the walk reports | not provided; an identical table duplicated at a second offset would differ only in `e_phoff`, but building it serves no guard of its own |
| `F21` | segment extent past the file | segment bounds | `G01` + `M12` + `M13` | `readelf -l` prints the base segment's real offset and size | not provided; identical segment bytes at two congruent offsets would do it, same reason as `F20` |
| `F22` | dynamic extent not a whole number of entries | dynamic entry sizing | `G01` + `M14` | `Elf64_Dyn` is `d_tag` plus `d_un`, so 16 follows from the layout rather than from a stored field (LSB dynamic section; `elf(5)`) | not applicable; the invariant is a whole number of entries, and this carrier proves a bounds rule in `F21` |
| `F23` | dynamic list never reaching `DT_NULL` | dynamic list termination | `G01` + `M15` | `DT_NULL` is the `d_tag` value ending the array (LSB dynamic section; `elf(5)`) | not applicable; the terminator's presence is the only lawful terminal state, and this carrier proves tag identity in `F06`, `F07`, `F10` and `F11` |
| `F24` | a segment offset whose unsigned value has its top bit set | integer representability: a field at or above `2^63` cannot be decoded faithfully by signed shell arithmetic and must be refused rather than wrapped | `G01` + `M17` | `readelf -l` reports the base segment's real offset, so the planted value is demonstrably not it; `readelf` itself rejects the mutated file, which is the semantic oracle's verdict that the object is malformed | not applicable; the guard is about a value's representability, and the lawful counterpart is every accepted fixture whose offsets decode exactly |
| `F25` | two segment extents that each decode exactly and whose SUM does not | extent arithmetic: an offset and a size that both pass the reader can still overflow when added, and a negative total satisfies any `-le` comparison against a file size. This is the guard `F24` cannot reach, because `F24` is refused one step earlier by the reader | `G01` + `M18` | `readelf -l` reports the base's real offset and size, so `2^62` is demonstrably neither; and the fixture is measured against BOTH observers, the pre-fix one reporting `ok` and the fixed one `inconclusive`, so it is a regression witness rather than an assertion about the current code alone | not applicable; the guard is about how an extent is computed, not about a field's identity |

Requiring zero unexercised guards paid for itself the first time it was applied.
The identification guard has four parts and the previous matrix exercised two,
leaving magic and version untested; and no fixture produced `elf_kind:
unsupported`, one of the three values the design defines. `F09`, `F12` and `F13`
close those gaps, and they were found by the criterion rather than by inspection.

Giving the rows ids paid for itself the same way. The previous matrix promised an
exact carrier mutation with offset and width in every row and then said "no
`PT_INTERP` program header emitted", "two entries whose `d_tag` values are …" and
"set past the file", none of which is a mutation. It also mishandled the
alternate-pair column twice over: it first recorded a pair as **provided** for
`e_phoff`, `p_offset` and `p_filesz`, which this recipe set does not build, and
the correction to that then called those pairs **not constructible**, which was
false, as the counterexamples above show. The four scoped statuses replace both
claims. The same pass had missed the pair at `F06` against `F07`, which this plan
does provide.

### Step 1 test first

Write the observer fixture cases before the observer. The matrix is fixed by the
design and every guard has at least one fixture:

- accepted: ordinary `ET_EXEC`; PIE; shared library; no `PT_DYNAMIC`; dynamic
  with no search-path tag; `DT_RPATH` only; `DT_RUNPATH` only; `e_phnum == 0`;
  an `ET_REL` relocatable object, the only shape yielding `elf_kind:
  unsupported`;
- ambiguous: both tags; a duplicate of one tag;
- identification: bad magic; a wrong `e_ident[EI_VERSION]`;
- domain: ELF32; wrong byte order; wrong machine; extended `e_phnum`;
- bounds: a file shorter than the ELF header; `e_phentsize` wrong with a nonzero
  count; a table past the file; a header whose offset and length are past the
  file; a `PT_DYNAMIC` extent that is not a whole number of entries;
- termination: a dynamic list never reaching `DT_NULL`;
- probe faults, over the lawful base with a controlled patchelf double: one
  failing `--print-rpath` while the interpreter answers, one the converse.

Each case asserts the **named tuple fields**, never serialized text. The matrix
below gives, per fixture, the guard it exercises and the exact bytes or file
operation that produce it, and the probe-witness matrix gives, per relied-on
probe behavior, the fixture that witnesses it.

### Step 1 behavior

The observer validates identification and whole-header presence
unconditionally, and the program-header checks only when `e_phnum` is nonzero.
File size comes from the `find` walk, which emits it beside the NUL-delimited
path.

The tuple is **one fixed global associative array**, named once and shared by
the observer, the classifier and the controlled tests, cleared in a single
operation before every observation fills it. Fixed and global rather than passed:
Bash cannot pass an associative array by value, so a per-call container would
mean passing its name and dereferencing through a nameref, which is a second
interpreter capability beyond the one Step 0 gates. One shared container avoids
that dependency and keeps the clearing rule to a single operation in a single
place. On structural failure the container is cleared and both probe statuses
are `blocked`.

### Step 1 completion criteria

- every fixture in the matrix carries its `Fnn`, cites either all its `Mnn` ids
  or exactly one `Gnn` or `Xnn` id, and names its reader guard, its semantic
  oracle with citation, its alternate-pair status and its expected tuple; passes
  that oracle before the observer runs; and then produces exactly that tuple.
  **Zero fixtures are unclassified and zero rejection guards are unexercised**,
  counting the identification guard's four parts separately, and every row whose
  alternate-pair status is other than "provided" carries its recorded reason and
  its correct one of the three remaining statuses;
- **traceability closes in both directions**: zero fixture mutations without a
  manifest entry, and zero manifest entries without a fixture or guard that uses
  them. No row describes its construction in prose instead of citing ids;
- the three cross-checks pass: layout confirmation over the whole base, the
  per-entry value cross-check, and the alternate pair on the three pairs this
  plan provides, `F01` against `F02`, the base against `F16`, and `F06` against
  `F07`;
- **every accepted and ambiguous fixture asserts the complete array** after the
  production observer and the production probe step have run: both probe
  statuses, the presence or absence of each probe value, and the literal value
  wherever the status is `ok`. No field of the tuple is left unasserted;
- **zero probe obligations are uncovered.** Every row of the probe-witness matrix
  has its named witness passing, the five `ok` behaviors, the two `skipped`
  producers, the `blocked` producer, and both axis-local `failed` producers. A
  named `ok` witness that returns `failed` leaves **this step incomplete**: the
  lawful recipe is repaired for the shipped patchelf, or implementation stops for
  a reviewed Q03 fixture-source revision. The expectation is never rewritten to
  match the refusal;
- `D01` and `D02` run the production probe step with a controlled patchelf
  double, and each asserts the complete array including the surviving axis's
  status and literal value. Step 2's controlled `failed` tuples remain classifier
  tests and do not stand in for these;
- **each double is bounded, and the boundary is asserted.** Each fault case runs
  in its own subshell with a private scratch `INSTALL_PREFIX`, `HOME` and
  command-search directory, covering all three of `find_patchelf`'s ordered
  resolution surfaces; the case asserts that production `find_patchelf` returns
  exactly its own expected double path before probing; an exit trap removes the
  scratch state; and the parent's resolution inputs are asserted unchanged
  afterwards, with no surviving double file, resolved-tool variable, cache, shell
  function, alias or injected search location. Ordering the fault cases last is
  not accepted in place of any of this;
- **this step runs the harness prerequisite preflight for its own process** and
  records the `sha256sum` path it pinned, rather than referring to the one Step 0
  resolved in a different process. Every digest invokes `"$SHA256SUM_BIN"`, and
  no bare `sha256sum` call appears after the preflight;
- **the shipped tool's identity is re-established after each fault case, in the
  stated order.** Its resolved absolute path, version and GNU `sha256sum` digest
  are recorded in the parent before the fault cases, the digest captured
  fail-closed, first field by Bash parameter expansion, exactly 64 lowercase
  hexadecimal characters. After the subshell has **exited** and the
  unchanged-parent assertions have passed, the parent recomputes through the same
  pinned path over the path `find_patchelf` then returns, the two digests must be
  equal, and `F06` is then rerun end to end as the
  post-fault sentinel, chosen because its expected tuple is `ok` with a non-empty
  literal on both axes, where `F01`'s empty rpath expectation could be met by a
  leaked double answering with nothing. Failure of the identity assertion or of
  the sentinel is a failure of this step;
- no controlled double is counted as evidence for any of the matrix's five `ok`
  obligations, which the shipped binary satisfies or nothing does;
- `F11`'s duplicate-tag value is recorded on first run with the patchelf version,
  frozen, and asserted thereafter. It is not counted as a witness for any probe
  obligation, and its first observation is recorded as a measurement rather than
  as a predeclared expectation that happened to hold;
- every value the design defines for `elf_kind` and `tag_state` is produced by
  at least one fixture;
- the zero-table fixture is accepted, not rejected;
- both ambiguity fixtures yield `tag_state: ambiguous`;
- the harness reaches the observer by sourcing the installer in a subshell, so
  the production function is the one under test;
- no new installer host tool is used, and this is now **two mechanical rules
  rather than one rule and one reading**. The denylist rule stays: no
  harness-only tool is invoked. The allowlist rule is new: every command-position
  word in the installer must appear in `docs/v0.27.0/contract.host-tools.txt`,
  the committed vocabulary, so a tool outside it fails the gate instead of
  passing unnoticed. Step 1's own additions resolve to `od`, `head`, `find` and
  the shipped patchelf, all of which the installer already used.
  **`readelf` and `sha256sum` are harness-only prerequisites**, and the execution
  checklist's negative host-tool grep over `install_pkg.sh` names both, so an
  accidental production use is detected rather than assumed away;
- the installer's observable behavior is unchanged, proved by re-running the
  Step 0 baseline.

## Step 1 addendums

### Step 1 line budget checkpoint

- `install_pkg.sh` baseline: 625 lines. Advisory estimate after this step: 750
  to 800.
- There is no Python gate on this file, so the estimate is advisory rather than
  a limit. The real constraint is the standalone deployment: this plan keeps the
  observer inside `install_pkg.sh` and records the resulting size, so Step 3 can
  weigh a split against measurement rather than against a guess.
- Split guidance if the file becomes unworkable: the observer is the only
  self-contained candidate, and extracting it means the deployment carries a
  second file. That is a change to what the archive ships and to the how-to, so
  it is not a refactor; it would need its own requirement amendment.

### Step 1 workflow timing readiness

The structural read replaces no existing work and adds bytes per ELF. Record the
walk duration against the Step 0 baseline; a regression larger than the capture
noise is reported, not absorbed.

### Step 1 time-gated status

Not started.

---

## Step 2 analysis and intent

### Step 2 issues

The ordered classifier does not exist. The current pass has one condition,
`*/home/*`, which is case 6 of seven.

### Step 2 fix intent

Implement the seven-case ordered classifier as a decision over the Step 1 tuple,
callable independently of the walk.

### Step 2 expected outcome

Given a tuple, one case. Given the `develop#24` inventory, the **selected set**
defined once below.

#### The selected set, stated once

This plan carried a contradiction for several rounds: this step said the 110
flagged libraries and the python ELF were selected and every other program left
alone, while Step 6 said the 110 libraries and the python **and git**
executables. Both cannot be the acceptance oracle, and the disagreement was not
the plan's to settle by preference. The design settles it, under "Two owners,
overlapping objects, disjoint claims": *the 110 flagged libraries selected, the
python and git programs selected, and every other archive program left
rpath-excluded.*

So the inventory is, in one form used identically by Steps 2, 4 and 6:

| Population | Expectation |
| --- | --- |
| the 110 flagged libraries | selected, case 4 |
| the python program | selected, and asserted **explicitly** by name, since its omission is the failure the requirement's acceptance was written to catch |
| the git programs | selected, and asserted by their enumerated object paths recorded from the `develop#24` inventory rather than by a remembered count |
| every other archive program | rpath-excluded, case 7, and asserted as preserved rather than merely not mentioned |

The git objects are enumerated rather than counted because a count is a fact
about one inventory snapshot and would silently pass on a different one, which is
the kind of check this plan has already rejected twice elsewhere.

**Where each half is asserted.** The set is stated once, here, and every step
that names it means this table. The steps differ only in which half they must be
green for:

| Half | Asserted by |
| --- | --- |
| the recorded populations: 110 libraries, python, the git objects | Steps 2, 4 and 6 |
| the residual: every other archive program at case 7 | Steps 4 and 6, **not** Step 2 |

The recorded half is answerable from the record, which is data this effort owns
and commits. The residual half is answerable only from a real archive, so it is
asserted by the steps that have one: Step 4 over the staging tree it rewrites,
Step 6 over the deployed archive. Step 2 consumes tuples and cannot repackage a
tarball, so requiring it to be green for the archive's contents would make a
classifier step wait on an artifact the umbrella's last requirement owns.

Nothing about the invariant itself is relaxed by this split. No object is
excused and no exception is named; the harness reports every residual object it
walks at every step. Only the step that must be green for it moves.

### Step 2 framings

After the observer because it consumes the tuple; before the wiring because the
wiring should change behavior only once, with the classifier already proved.

### Step 2 complexity impact

Moderate. Seven ordered branches replacing one condition.

### Step 2 feature preservation

Still not wired: the installer behaves as before at the end of this step.

## Step 2 implementation

### Step 2 files involved

- `src/setups/env/bin/install_pkg.sh` (existing, to be updated)
- `docs/v0.27.0/verify.relocation-rpath.sh` (existing, to be updated)

### Step 2 test first

Controlled-tuple cases before the classifier. The previous version of this
section was one sentence ending "and each of the four probe statuses", and that
phrasing was wrong in a way that let a weaker suite satisfy it. **There are not
four probe states.** There are two independent status fields, each drawn from
`ok`, `skipped`, `blocked` and `failed`, and two independently present or absent
values beside them. A checklist that merely observes each of the four tokens
somewhere can be satisfied without ever constructing either axis-local failure,
which is exactly the pair Step 1 now goes to the trouble of producing.

So every row is a **complete, contract-valid tuple**, not a token occurrence:

- the array is **cleared**, then populated with the **exact key set** the design
  defines, no key missing and none extra;
- the row states every structural field, **both** probe statuses, the presence or
  absence of each probe value, and each literal value where present;
- the tuple invariants are checked **before** the classifier is invoked, so a
  malformed input fails as a defective test rather than as a classifier result.

The exact-key-set rule is not ceremony. In Bash an unset associative-array key
expands to the empty string, so a row that forgot `interp_probe_status` is
indistinguishable at the point of use from one that meant to set it empty, and
the classifier would branch on a value nobody wrote.

The matrix covers, without asking for the Cartesian product of combinations the
observer cannot produce:

| Row group | What it fixes |
| --- | --- |
| the seven ordered cases | one row each, the assigned case asserted |
| both `$HOME` overlaps | a v0.26.0 tuple and a this-version tuple under a `/home` prefix, classifying as case 5 and case 3 rather than case 6 |
| both successful tag forms | `tag_state: rpath` and `tag_state: runpath` |
| ambiguity | `tag_state: ambiguous`, a successful structural observation |
| structural inconclusiveness | every other field cleared, both probe statuses `blocked`, neither value present |
| both `skipped` producers | `has_dynamic: no` giving a skipped rpath probe, `has_interp: no` giving a skipped interpreter probe |
| both axis-local failures | `rpath_probe_status: failed` with a surviving interpreter status and value, and the converse |

### Step 2 producer-to-consumer bridge

Step 1 proves the production of a tuple; Step 2 proves its consumption. The plan
says twice that Step 2's controlled tuples do not substitute for Step 1's
producer evidence, and the converse needed saying too: **a controlled tuple and a
controlled double may not be counted as both claims.** What was missing between
them is anything showing that the controlled inputs conform to the contract the
producer actually emits.

So representative **real** Step 1 observations cross the seam. Each is named by
its Step 1 fixture id, and each carries the complete surviving-axis value, so the
bridge cannot quietly pick a different subject than the one that produced it:

| Producer observation | Step 1 subject | Tuple crossing the seam | Expected case |
| --- | --- | --- | --- |
| library | `F03` | `dyn`, dynamic yes, interp no, `tag_state: none`; rpath `ok` empty, interp `skipped` | 4 |
| no `PT_DYNAMIC` | `F04` | `exec`, dynamic no, interp yes, `none`; rpath `skipped`, interp `ok` `/lib64/ld-linux-x86-64.so.2` | 2 |
| `DT_RPATH` | `F06` | `exec`, dynamic yes, interp yes, `tag_state: rpath`; rpath `ok` `/opt/cplx-probe/lib`, interp `ok` with its value | per the target comparison |
| `DT_RUNPATH` | `F07` | `tag_state: runpath`; rpath `ok` `/opt/cplx-probe/lib` | per the target comparison |
| ambiguity | `F10` | `tag_state: ambiguous`; rpath `ok` `/opt/cplx-probe/runpath` | 1 |
| structural rejection | `F16` | `structural_status: inconclusive`, every other field cleared, both probes `blocked` | 1 |
| rpath probe fault | **`D01`** over `F01` | rpath `failed`, no value; interp **`ok`** with `/lib64/ld-linux-x86-64.so.2` | 1 |
| interpreter probe fault | **`D02`** over `F01` | rpath **`ok`** with `F01`'s value; interp `failed`, no value | per the rpath value |

`D01` and `D02` here are the **producer** witnesses of Step 1 over `F01`, not
Step 4's integration runs `IF01` and `IF02`, which use different subjects and
therefore different surviving-axis outcomes. For one round both meanings shared
two identifiers and this table could have been built from either.

Each observation is fed to the classifier and must yield the same outcome as its
corresponding controlled row. A disagreement means the controlled rows have
drifted from the contract, which is precisely the failure neither layer can see
alone.

### Step 2 behavior

First match wins, in the order the design fixes. The exact-target tests precede
the builder-anchored test.

### Step 2 completion criteria

- every controlled tuple yields the expected case;
- **every controlled row is a complete, contract-valid tuple**: the array cleared,
  populated with the exact key set with nothing missing or extra, both probe
  statuses and both value-presence facts stated, and the invariants checked
  before the classifier is invoked;
- the matrix covers every row group above, including **both axis-local failure
  combinations**, which a four-token checklist does not require;
- the two `$HOME` tuples classify as case 5 and case 3 rather than case 6;
- **the bridge passes**: each representative real Step 1 observation, the
  library, the no-dynamic object, `DT_RPATH`, `DT_RUNPATH`, the ambiguous
  object, one structural rejection, `D01` and `D02`, yields the same outcome as
  its corresponding controlled row. No controlled tuple or controlled double is
  counted as evidence for both production and consumption;
- the classifier is invoked in the harness without running an install, which is
  what makes the inventory check of Step 6, the acceptance, possible;
- against the `develop#24` inventory the classifier selects exactly the set
  stated once above, **for every object the record names**: the 110 flagged
  libraries as case 4, the python program by name, and the enumerated git
  objects. The recorded populations are what this step can answer, because the
  record is data the step owns.

#### What Step 2 deliberately does not accept

The residual half of the selected set, *every other archive program left
rpath-excluded at case 7*, is **not** a Step 2 completion criterion. It is
asserted where the artifact it describes is produced: the acceptance of Step 6
and the rebuilt archive of the umbrella's `tools-archive-rebuild`.

The reason is that the residual population is a property of the **archive**, not
of the classifier. Step 2 owns a decision over a tuple, and its recorded
inventory is the oracle for that decision. Whether some object nobody recorded
happens to sit in a published tarball is a fact about what was packaged, and a
step that consumes tuples cannot fix it. Making Step 2 fail on it couples a
classifier step to an artifact a later requirement owns, and the coupling is not
theoretical: `tools/python/root/a.out`, a compiler test binary that entered the
tree by none of the three routes and whose interpreter path exists only on the
build host, held this step at one failure while every population the record
names passed.

This is a relocation of the assertion, not a weakening of it. The invariant is
unchanged and unqualified: no exception is named, no object is excused, and the
harness still walks and reports every residual object it finds. What moves is
*which step must be green for it*. Step 4 and Step 6 state the same sentence and
run against the real tree, so the invariant is enforced twice downstream and is
never enforced against a tarball the step under test cannot rebuild.

## Step 2 addendums

### Step 2 line budget checkpoint

- Baseline: the Step 1 result. Advisory estimate: 60 to 90 further lines.
- Same policy as Step 1: advisory, with the standalone-deployment constraint as
  the real one.

### Step 2 workflow timing readiness

Classification is string comparison over already-read values and should not move
the walk duration.

### Step 2 time-gated status

Not started.

---

## Step 3 analysis and intent

### Step 3 issues

The atomic integration step that follows carries the formatter, the
retained-capture reader, the behavior change, the migration assertion and the
wiring in one diff. Its risk is not that the pieces are wrong together; it is
that the formatter and the reader are the largest and most mechanical of them,
and folding them into the same diff as the behavior change means a formatting
defect and a relocation defect arrive in the same commit with the same symptom,
an acceptance that will not go green.

The formatter and the reader can be written and proved without the installer
calling them. Nothing in the requirement or the design says they must arrive
with the behavior; what must arrive together is the behavior and the *emission*
of the report, since that is what a deployment observes.

### Step 3 fix intent

Implement the record **formatter** in the installer and the retained-capture
**reader** in the harness, and make their contract green, without the
installer's main flow calling the formatter.

The two ends live in different files, which is Q08's decision and not a
detail. The formatter must ship, because a run emits records. The reader never
runs during an install: it is the retained recipe's consumer, so putting it in
a script that must deploy standalone would add a parser no deployment executes,
to a file whose size is the effort's live constraint, and would create a call
surface that has to be argued away. The harness sources the production
formatter, drives it with constructed dispositions, and passes the output to its
own reader, so the two ends stay independent by construction.

### Step 3 expected outcome

The `CPLX-ELF/1` contract is proved from both ends before anything depends on
it, so the step that changes behavior carries only the wiring and the emission.

### Step 3 framings

This is a preparation step, not an observable one. Nothing a deployment can see
changes: no call site is added, the pass still prints its mixed count, and the
installer behaves exactly as it did after Step 0.

That is what distinguishes it from the invalid intermediate state Q04 rejected.
An uncalled helper is not a partial behavior change; it is a definition with no
caller, and a deployment cannot tell it apart from its absence.

**That property is asserted, not inferred.** Re-running the Step 0 baseline
proves no report was emitted, which is weaker than it looks: a stray call whose
output is redirected or discarded would leave the baseline unchanged. So this
step carries a static assertion that the formatter appears in `install_pkg.sh`
only at its definition. The baseline remains as a behavioral backstop beside it,
not as the proof.

An identifier search is only as good as the identifier, so the name is reserved
here rather than chosen at implementation time: the formatter is
`emit_cplx_elf_v1_record`. Three rules make the count deterministic:

- the assertion counts that **whole shell word**, not an arbitrary substring, so
  a longer name containing it cannot satisfy or defeat the check;
- the exact identifier is forbidden in comments and in message literals inside
  `install_pkg.sh`, so every occurrence is a definition or a call;
- Step 3 expects exactly one occurrence, the definition. Step 4 expects the
  definition plus the call sites it enumerates.

The third rule is what keeps the check honest over time. A false positive is
fixed by renaming the prose that collided, never by loosening the assertion,
because a loosened assertion is one that stops proving the property the step's
whole argument rests on.

### Step 3 complexity impact

It moves the formatting bulk out of the integration diff, and the reader out of
the installer entirely. The total work is unchanged; what changes is which
failures can arrive together, and how much of the work lands in a file that has
to ship.

### Step 3 feature preservation

Nothing changes for an executed install.

## Step 3 implementation

### Step 3 files involved

- `src/setups/env/bin/install_pkg.sh` (existing, to be updated): the record
  formatter only
- `docs/v0.27.0/verify.relocation-rpath.sh` (existing, to be updated): the sole
  retained-output reader, the malformed-capture constructors, and the cases
- `docs/v0.27.0/contract.cplx-elf-1.txt` (new): the literal `CPLX-ELF/1`
  contract corpus, committed test data read by the cases and sourced as
  constants by neither end

### Step 3 test first

The report-contract cases of the design's fourth validation layer, written
before the formatter: all nine wire tokens and their prose mappings; every
required field present exactly once; the nine per-token equalities, `walked`,
and `mig-checked` against the case 5 record count; and every rejected form, an
unknown marker, a missing, duplicate or unknown field, a bad token, a `path`
that is not non-empty even-length lowercase hex, a decoded `path` beginning with
`/` or `./`, an invalid `state`/`reason` pairing, a `skipped` trailer carrying a
record or a nonzero count, a trailer disagreeing with its records, and a capture
with no trailer or two.

The cases drive the formatter with constructed dispositions, exactly as Step 2's
cases drive the classifier with constructed tuples. Neither needs an install.

### Step 3 contract corpus

Q08 puts the formatter and the reader in different files, which is what makes
their agreement worth something. It is not enough on its own. A round-trip shows
that the two implementations agree; it cannot show that they are right, and two
ends written by the same hand can drift together while still carrying the
`CPLX-ELF/1` marker. That is the same failure this plan already met between the
fixture generator and the observer, which agreed with each other about a wrong
offset. The schema version is an identity, not an oracle.

So both ends are bound to a **literal contract corpus**, committed beside the
harness as `docs/v0.27.0/contract.cplx-elf-1.txt`, plain test data, in three
declared classes:

- **canonical formatter vectors**: `obj` records and `end` trailers written out
  byte for byte in the one canonical field order, covering every wire token, the
  closed `state` and `reason` pairs, and the `path` matrix below. The formatter's
  output is compared against these and only these;
- **other reader-valid vectors**: literals the reader must accept that the
  formatter is never required to emit. At minimum one permuted `obj` and one
  permuted `end`, carrying the same fields in a different order;
- **rejected vectors**: one literal per rejected form.

The permutations are not decoration. The design says the reader locates fields
**by name rather than by position**, and canonical vectors in a single formatter
order cannot test that rule at all: a strictly positional `obj` reader and a
strictly positional `end` reader accept every canonical vector and reject every
malformed one, passing the whole suite while implementing a different grammar.
Declaring the three classes is what stops a valid permutation being filed as
malformed input, which is the mistake a two-class corpus invites. This is a test
consequence of the grammar the design already fixed, not a new grammar decision:
the formatter still emits one order, and nothing requires it to emit more.

The corpus is authored from the design's grammar by hand. It is not generated
from either end's vocabulary tables, and neither end sources constants from it,
because a corpus derived from the formatter would agree with the formatter by
construction. The formatter's output is compared **byte for byte** against the
canonical vectors; the same literals, canonical and malformed, are fed to the
reader.

`/1` is frozen. A grammar change is not an implementation decision: it needs
reviewed authority in the design or the requirement, a new marker, and a new
corpus alongside the old one.

#### Authority order, and what happens when the three disagree

An independent corpus stops the two implementations proving only that they agree
with each other. It does not, on its own, stop a red suite being made green by
editing the corpus, which would quietly turn it into a transcript of whatever
the formatter does. So the plan states an order and an adjudication rule:

| Rank | Artifact | Standing |
| --- | --- | --- |
| 1 | the reviewed `/1` design | semantic authority; it says what the grammar means |
| 2 | `docs/v0.27.0/contract.cplx-elf-1.txt` | the frozen executable witness, established from rank 1 **before** any formatter work |
| 3 | the formatter and the reader | implementations, which are what a mismatch is presumed to have got wrong |

The corpus is frozen before either implementation is compared against it, and
the freeze is recorded as evidence: its exact bytes, by Git blob id or by a
validation-only digest, written into the Step 3 evidence with the commit that
introduced them. A corpus whose bytes were never recorded cannot later be shown
not to have moved.

**A digest is not a derivation, and the freeze must not be read as though it
were.** A blob id proves the bytes have not changed since they were measured. It
says nothing about whether those bytes were correctly derived from the design in
the first place, and the adjudication rule above presumes every later divergence
is either an implementation defect or a typo, which is only safe if the corpus
was right when it was frozen. So the freeze is preceded by a recorded **two-way
derivation audit**, kept as a ledger with two directions:

| Direction | What each row records | Completion rule |
| --- | --- | --- |
| design to corpus | every `/1` obligation the design states, against the corpus vector or vectors that witness it | zero uncovered obligations |
| corpus to design | every corpus vector, against the exact design clause it comes from, its intended accept or reject result, and any canonical-output choice the design permits without requiring | zero vectors without a derivation |

The second direction's last column is the one that catches the quiet decisions.
Where the design permits a form without requiring it, the corpus necessarily
picks one, and that pick is an authored choice rather than a derived
consequence; recording it as such keeps a later reader from mistaking a
convenience for an obligation.

The Step 3 implementation check reads the literal corpus against that ledger and
records the result **before** the bytes are frozen. The two pieces of evidence
say different things and neither substitutes for the other: **the audit
establishes derivation correctness at freeze time, and the digest establishes
stability afterwards.** If the audit finds the design silent, or finds a clause
admitting two readings, that is adjudication path 3 below, taken **before** the
freeze, rather than an occasion to choose a corpus value and record it as
derived.

On a mismatch, exactly one of three paths, chosen by reading the design and not
by which change is smaller:

1. the corpus agrees with an unambiguous design clause, so the **implementation
   is wrong**. Fix the implementation. This is the expected case;
2. the corpus is genuinely mistyped against an unambiguous design clause. Correct
   it in an **isolated corpus-only change** that cites the clause and
   re-establishes the frozen bytes, and only then touch an implementation. The
   two edits are never in one change;
3. design and corpus cannot be adjudicated unambiguously, because the clause is
   silent or admits both readings. **Stop.** This is a design defect, and it
   goes back for reviewed amendment rather than being settled by whichever
   artifact is easier to edit.

Editing the corpus and an implementation together to obtain agreement is
forbidden outright, whatever the justification, because the result is
indistinguishable from case 1 having been resolved the wrong way. `/1` semantics
still never change in place: case 3 resolving in favor of a different meaning
produces a new marker and a new corpus, not a redefinition behind the old token.

#### The `path` vector matrix

`path` is the only field whose value comes from runtime input rather than from a
closed vocabulary, so one canonical example fixes the encoding for one input and
proves nothing about the rest. The corpus carries an independently authored byte
matrix. Each vector states its raw input and its expected lowercase hex as
literal corpus data; neither production end generates the recipes or the
expected output.

| Vector | Raw input | What it proves | Expected hex |
| --- | --- | --- | --- |
| simple | `lib/foo.so` | the base case, and it is the value the design's own sample capture carries | `6c69622f666f6f2e736f` |
| root-relative | object at `$DEST_PATH/usr/lib/libz.so.1`, with `$DEST_PATH` stated in the vector | the encoded value is the remainder **after** `$DEST_PATH`, not the absolute path, so a formatter that encoded the absolute path fails here and only here | `7573722f6c69622f6c69627a2e736f2e31` |
| delimiter-looking bytes | `a b=c` followed by a newline | space, `=` and newline are lawful in a Linux filename and are exactly the bytes the wire grammar reserves; encoding must be blind to them | `6120623d630a` |
| non-UTF-8 | `x`, byte `0xff`, `.so` | a filename is a byte string, not text, so any encoder that decodes to a string first breaks here | `78ff2e736f` |
| shortest | `a` | one byte, the minimum non-empty input, against off-by-one in the encoder's loop | `61` |
| at the wrap boundary | a name of exactly the measured `od` line width | the last input that produces single-line `od` output | recorded literally with the vector |
| across the wrap boundary | that name plus one byte | the first input whose `od` output wraps, where a lost byte or an injected separator would appear | recorded literally with the vector |

The last two are a deliberate adjacent pair, because a wrapping defect shows at
the transition and nowhere else. Their length is **measured, not assumed**: run
the exact `od` invocation the formatter uses, record the output line width in
the Step 3 evidence, and author the pair at that width and that width plus one.
GNU `od -An -tx1` is expected to write sixteen bytes per line, which is a figure
to confirm against the shipped tool rather than to take on trust.

The rejected forms already listed stay rejected and are the matrix's negative
half: an empty `path=`, a value that is not non-empty even-length lowercase hex,
a decoded value beginning with `/`, and a decoded value beginning with `./`.

### Step 3 behavior

The formatter, in the installer, emits `obj` records and the `end` trailer to
the grammar the design fixes, including the raw-byte hex path encoding based on
`$DEST_PATH`. It is defined and not called.

The reader, in the harness, parses a capture and rejects every malformed or
internally inconsistent form. The malformed-capture constructors live beside it:
they are validation inputs, not deployment code, so nothing in the installer
knows how to build a broken capture.

### Step 3 completion criteria

- the two-way derivation ledger is complete and recorded, zero uncovered `/1`
  obligations and zero corpus vectors without a design clause, an intended
  result and any permitted-but-not-required choice named. Any silence or double
  reading it found took adjudication path 3 **before** the freeze;
- the corpus's exact bytes are recorded as evidence, by Git blob id or
  validation-only digest, **after** the ledger and **before** either
  implementation is compared against it, together with the measured `od` output
  line width the two boundary path vectors are authored at. The evidence states
  which claim each artifact carries: the audit for correctness at freeze, the
  digest for stability after it;
- the corpus declares its three classes, and the production formatter's output is
  compared byte for byte against the canonical class **only**;
- the reader accepts every canonical vector, accepts every other reader-valid
  vector including at least one permuted `obj` and one permuted `end`, and
  rejects every literal malformed one. The permutations are what test the
  design's name-based field resolution, which canonical vectors in one order
  cannot. The round-trip between the two ends is checked as well, but it is the
  corpus that makes agreement mean correctness;
- every `path` vector in the matrix is present with its literal expected hex,
  including the adjacent pair straddling the measured wrap boundary, and every
  rejected `path` form is rejected;
- any mismatch resolved during the step is recorded with which of the three
  adjudication paths was taken and the design clause cited. No commit changes
  the corpus and an implementation together;
- every rejected form is rejected, with the reason distinguishable;
- the categorical equalities are checked by the reader, not merely produced by
  the formatter;
- **the formatter has no production call site**, asserted statically:
  `emit_cplx_elf_v1_record` occurs in `install_pkg.sh` exactly once, as a whole
  shell word, at its definition, and appears in no comment or message literal;
- the installer's observable behavior is unchanged, proved by re-running the
  Step 0 baseline. This is the backstop, not the proof: a call whose output was
  redirected would leave the baseline unchanged and the static assertion is what
  catches it;
- `install_pkg.sh` contains no reader, which the same static check confirms by
  the reader's identifier being absent from it;
- `shellcheck` is clean on both files.

## Step 3 addendums

### Step 3 line budget checkpoint

- Baseline: the Step 2 result. Advisory estimate for `install_pkg.sh`: **40 to
  60** further lines, the formatter alone.
- The earlier 80 to 120 figure covered the formatter and the reader together.
  With the reader in the harness, roughly half of that estimate moves out of the
  file that has to ship, which is a direct saving on the constraint Q02 tracks
  rather than a saving on total work: the harness grows by about the same
  amount, and no ceiling applies there.
- Advisory, replaced by the measured figure. The line budget is not a gate.

### Step 3 workflow timing readiness

Nothing runs during an install, so the walk duration is unchanged from Step 2.

### Step 3 time-gated status

Not started.

---

## Step 4 analysis and intent

### Step 4 issues

Nothing yet changes what the installer writes. `--force-rpath` is still absent,
the guard is still the single `/home/` test, and the pass still prints one mixed
count while a proved formatter sits uncalled beside it.

Those changes cannot be separated into two production steps, and an earlier
version of this plan tried to. Landing the behavior alone leaves a released
state in which the pass writes `DT_RPATH` over three populations while still
reporting one number that mixes interpreter and rpath rewrites, which is exactly
the illegible partial coverage the requirement exists to remove. Landing the
emission alone is worse: its `case` field is defined by a classifier the pass is
not yet consulting, so every record would carry a fabricated or absent case for
an action the old pass took. Neither intermediate state is one this effort would
be willing to ship.

### Step 4 fix intent

Land the behavior and its emission atomically: the classifier wired into
`fix_elf_paths`, `--force-rpath`, the post-classification migration assertion,
the two disposition axes accumulated during the walk, and the call sites that
emit through the Step 3 formatter.

### Step 4 expected outcome

The python ELF carries `DT_RPATH` after a relocation, from a fresh archive and
from a v0.26.0 prefix alike, and the run says so in a capture the Step 3 reader
already knows how to check.

### Step 4 framings

This is the only observable production step of the effort. Steps 1, 2 and 3
prove the observer, the classifier and the report contract separately, without
changing what an install does; this step is where they start doing something.

### Step 4 complexity impact

The largest observable diff, and smaller than it would have been: the formatting
bulk landed in Step 3, so what remains is the wiring, the writes, the
accumulation and the call sites.

### Step 4 feature preservation

The interpreter guard is untouched. Objects the classifier excludes keep exactly
their current treatment. The human `echos` lines stay; the mixed `Fixed <n>`
line is replaced, which is an intended output change the requirement records.

## Step 4 implementation

### Step 4 files involved

- `src/setups/env/bin/install_pkg.sh` (existing, to be updated)
- `docs/v0.27.0/verify.relocation-rpath.sh` (existing, to be updated)

### Step 4 test first

Behavior cases over a prepared prefix, before the production change: the python
ELF answering `RPATH` on a fresh archive; the same from a v0.26.0-relocated
prefix; a third run rewriting nothing; a shipped library that carried no rpath
carrying one; an excluded RPM-extracted program unchanged; a migration object
with a wrong interpreter counted as an invariant failure and still converted;
the three `$HOME` cases.

#### Two suites, not one

An earlier version of this section said the Step 3 report-contract cases are
"re-run unchanged, now against captures a real run produced rather than
constructed ones". That sentence cannot be true of the suite it names, and it
survived six rounds. Step 3's corpus holds three classes: canonical formatter
vectors, other reader-valid permutations the formatter is **not required to
emit**, and malformed vectors production must **never** emit and must reject. A
real run produces none of the second class and had better produce none of the
third, so "the same cases, now against real captures" describes a suite that
cannot exist.

They are two claims and they get two checks:

- **the Step 3 regression**, re-run **unchanged against its own literal and
  constructed inputs**: the frozen corpus, the canonical formatter vectors, the
  reader-valid permutations and the malformed inputs. Nothing here touches a real
  capture, and nothing here changes because Step 4 landed;
- **the Step 4 integration**, in which every capture a real matrix row produced
  is fed to the production reader and asserted in full.

#### The production outcome matrix

A single successful one-object sample proves one path through the wiring. It does
not prove that the observer, the ordered classifier, the two independent
disposition axes, the migration invariant, the mutation calls, the counters, the
formatter and the trailer compose on the paths where something goes wrong or
nothing is written.

The previous version of this matrix was not executable, and the reason is worth
recording. Several cells read `its own case`, `its own evidenced value`, `per
object` and `per the two axes`. Those are instructions to derive an expectation,
not expectations, and an interpreter's "evidenced value" is not even a
disposition: the closed interpreter tokens are `rewritten`, `failed`, `unchanged`
and `not applicable`. One row, `D02`, was also shifted a column, putting `failed`
under rpath where it belonged under interpreter, which reversed the very
axis-local premise the row exists to prove. A test could not have been written
from that table without making decisions the table claimed to have made.

##### The prepared objects

Every row below is one walked object in one run, so its `path` is fixed and its
record is literal. Twelve objects, each at a stated path under `$DEST_PATH`:

| Id | Path | Shape and initial state |
| --- | --- | --- |
| `X1` | `lib/libarch.so.1` | `ET_DYN`, no `PT_INTERP`, `DT_RUNPATH` builder-anchored |
| `X2` | `bin/pyprog` | program, `PT_INTERP` builder-anchored, `DT_RUNPATH` builder-anchored |
| `X3` | `bin/rpmprog` | program, `PT_INTERP` `/lib64/ld-linux-x86-64.so.2`, no search-path tag |
| `X4` | `bin/rpmprog-bh` | program, `PT_INTERP` builder-anchored, no search-path tag |
| `X5` | `lib/relobj.o` | `ET_REL`, `e_phnum` zero, no `PT_DYNAMIC` |
| `X6` | `lib/libamb.so.1` | `ET_DYN`, no `PT_INTERP`, carries **both** `DT_RPATH` and `DT_RUNPATH` |
| `X7` | `bin/migprog` | program, `PT_INTERP` already the target loader, `DT_RUNPATH` the exact target |
| `X8` | `bin/migprog-hostinterp` | program, `PT_INTERP` builder-anchored, `DT_RUNPATH` the exact target |
| `X9` | `lib/libtrunc.so.1` | program header table truncated |
| `X10` | `lib/libelf32.so.1` | ELF32, outside the domain |
| `X11` | `lib/libshort.so.1` | longer than the four magic bytes, shorter than the 64-byte header |
| `X12` | `lib/libprobe.so.1` | `ET_DYN`, no `PT_INTERP`, `DT_RUNPATH` builder-anchored |
| `X13` | `tools/python/root/lib64/ld-linux-x86-64.so.2` | `ET_DYN`, no `PT_INTERP`, no search-path tag, planted by the prefix builder and shaped like the real loader so case 4 claims it unless the rule stops it |

The interpreter guard read from lines 413 to 422 is
`[[ "$old_value" == */home/* ]] && [ "$old_value" != "$new_interp" ]`, so a
system interpreter and an already-target interpreter both yield `unchanged`, and
only a builder-anchored interpreter that differs from the target yields
`rewritten`. Every `unchanged` below is that guard, not an omission.

##### The runs

| Run | Prefix and inventory | What it exercises |
| --- | --- | --- |
| `R0` | a prefix **outside** `/home`, `{X2}` | both guards firing on one object |
| `R1` | prefix at `$HOME`, `{X1..X6}`, first pass | the ordinary walk |
| `R2` | the same prefix, second pass | idempotence |
| `R3` | prefix at `$HOME`, `{X7}` | migration |
| `R4` | prefix at `$HOME`, `{X8}` | migration with a host interpreter |
| `R5` | `{X9}` | truncated table |
| `R6` | `{X10}` | outside the domain |
| `R7` | `{X11}` | shorter than the header |
| `IF01` | `{X12}`, rpath-probe double | `--print-rpath` fails |
| `IF02` | `{X2}`, interpreter-probe double | `--print-interpreter` fails |
| `IW01` | `{X7}`, rpath-write double | `--set-rpath` fails on a **case 5** object |
| `IW02` | `{X2}`, interpreter-write double | `--set-interpreter` fails |
| `R14` | prefix at `$HOME`, `{X1..X6}`, no tool library directories | a missing rpath input, and the interpreter missing for the same reason |
| `R13` | any prefix, patchelf absent | the skipped pass |

##### The object outcomes

Seven columns, and the count is asserted mechanically so a shifted row fails as a
malformed table rather than as a puzzling expectation. Every cell is a closed
value: a case is 1 to 7, a disposition is one of its wire tokens.

| Row | Run / object | Case | rpath | interpreter | mutations | migration delta |
| --- | --- | --- | --- | --- | --- | --- |
| `A01` | `R0` / `X2` | 6 | `rewritten` | `rewritten` | both performed | none |
| `A02` | `R1` / `X1` | 4 | `rewritten` | `not-applicable` | `--set-rpath --force-rpath` only | none |
| `A03` | `R1` / `X2` | 6 | `rewritten` | `rewritten` | both performed | none |
| `A04` | `R1` / `X3` | 7 | `excluded` | `unchanged` | none, both forbidden | none |
| `A05` | `R1` / `X4` | 7 | `excluded` | `rewritten` | `--set-interpreter` only | none |
| `A06` | `R1` / `X5` | 2 | `not-dynamic` | `not-applicable` | none | none |
| `A07` | `R1` / `X6` | 1 | `failed` | `not-applicable` | none, `--set-rpath` forbidden | none |
| `A08` | `R2` / `X1` | 3 | `already-correct` | `not-applicable` | none | none |
| `A09` | `R2` / `X2` | 3 | `already-correct` | `unchanged` | none | none |
| `A10` | `R2` / `X3` | 7 | `excluded` | `unchanged` | none | none |
| `A11` | `R2` / `X4` | 7 | `excluded` | `unchanged` | none | none |
| `A12` | `R2` / `X5` | 2 | `not-dynamic` | `not-applicable` | none | none |
| `A13` | `R2` / `X6` | 1 | `failed` | `not-applicable` | none | none |
| `A14` | `R3` / `X7` | 5 | `rewritten` | `unchanged` | `--set-rpath --force-rpath` only | `mig-checked` +1, `mig-failed` +0 |
| `A15` | `R4` / `X8` | 5 | `rewritten` | `rewritten` | both performed | `mig-checked` +1, `mig-failed` **+1** |
| `A16` | `R5` / `X9` | 1 | `failed` | `failed` | none | none |
| `A17` | `R6` / `X10` | 1 | `failed` | `failed` | none | none |
| `A18` | `R7` / `X11` | 1 | `failed` | `failed` | none | none |
| `A19` | `IF01` / `X12` | 1 | `failed` | `not-applicable` | none | none |
| `A20` | `IF02` / `X2` | 6 | `rewritten` | `failed` | `--set-rpath --force-rpath` performed | none |
| `A21` | `IW01` / `X7` | 5 | `failed` | `unchanged` | `--set-rpath` attempted and failed | `mig-checked` **+1**, `mig-failed` +0 |
| `A22` | `IW02` / `X2` | 6 | `rewritten` | `failed` | `--set-rpath` performed, `--set-interpreter` attempted and failed | none |
| `A23` | `R14` / `X1` | 4 | `failed` | `not-applicable` | none, the write has no target | none |
| `A24` | `R14` / `X2` | 6 | `failed` | `unchanged` | none, neither input resolved | none |
| `A25` | `R14` / `X3` | 7 | `excluded` | `unchanged` | none | none |
| `A26` | `R14` / `X4` | 7 | `excluded` | `unchanged` | none, neither input resolved | none |
| `A27` | `R14` / `X5` | 2 | `not-dynamic` | `not-applicable` | none | none |
| `A28` | `R14` / `X6` | 1 | `failed` | `not-applicable` | none | none |
| `A29` | `R1` / `X13` | 7 | `excluded` | `not-applicable` | none | none |
| `A30` | `R2` / `X13` | 7 | `excluded` | `not-applicable` | none | none |

Each row's emitted record is fixed by its cells: `case`, `rpath`, `interp` and
the hex of the object's path. Its trailer contribution is `walked` +1, exactly
one `r-` bucket +1, exactly one `i-` bucket +1, and the stated migration deltas,
with every other bucket unchanged. That is the categorical rule made per-row
rather than left as a totals check.

Three rows carry the findings the earlier table blurred. `A21` is design row 750:
the case is population identity, so a case 5 object whose write fails is still
counted in `mig-checked` while its disposition is `failed` and never `rewritten`.
`A20` and `A22` produce **identical captures**, which is the point of having
both: the capture cannot distinguish a failed interpreter probe from a failed
interpreter write, so neither case can stand in for the other and the difference
lives in which production branch ran. `A05` is design row 746, an object excluded
on the rpath axis whose interpreter is nonetheless rewritten, which is where the
independence of the axes stops being an assertion.

##### The trailer totals

| Run | walked | r-rewritten | r-failed | r-already-correct | r-not-dynamic | r-excluded | i-rewritten | i-failed | i-unchanged | i-not-applicable | mig-checked | mig-failed | state |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `R0` | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | `completed` |
| `R1` | 6 | 2 | 1 | 0 | 1 | 2 | 2 | 0 | 1 | 3 | 0 | 0 | `completed` |
| `R2` | 6 | 0 | 1 | 2 | 1 | 2 | 0 | 0 | 3 | 3 | 0 | 0 | `completed` |
| `R3` | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | `completed` |
| `R4` | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 1 | `completed` |
| `R5` | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | `completed` |
| `R6` | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | `completed` |
| `R7` | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | `completed` |
| `IF01` | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | `completed` |
| `IF02` | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | `completed` |
| `IW01` | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | `completed` |
| `IW02` | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | `completed` |
| `R14` | 6 | 0 | 3 | 0 | 1 | 2 | 0 | 0 | 3 | 3 | 0 | 0 | `completed` |
| `R13` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | `skipped` |

**This table is not a second hand-maintained oracle.** It was written by hand and
it has been independently recomputed from the object rows and found correct, so
what follows protects against later drift rather than fixing a present error. The
harness **folds** the expected per-object rows into expected per-run counters and
then makes three comparisons, not two: the fold against this literal table, the
fold against the actual parsed trailer, and this literal table against the actual
parsed trailer. A row edited in one place and not the other then fails
mechanically instead of being caught by whoever next reads both.

Two arithmetic invariants are asserted over every row of this table and not left
to the reader: the five `r-` buckets sum to `walked`, and the four `i-` buckets
sum to `walked`. `R13` emits **no records and exactly one trailer**, and the
install still succeeds.

`R14` is the empty-search-path run and is given a fixed six-object inventory
rather than the phrase "`r-failed` equals `walked`", which said nothing about the
interpreter or migration totals.

**It replaces `R12`, which asked for a fixture nobody can build.** `R12` required
an empty computed search path AND a resolvable interpreter, so that its
interpreter axis would show a rewrite while its rpath axis failed. Those two
conditions are mutually exclusive in this codebase: every candidate
`find_dynamic_linker` accepts lives inside a directory `build_elf_rpath` collects,
so a prefix that resolves the interpreter always yields a non-empty target. The
contradiction was found while deriving the Step 4 matrix, reported as six
unanswered rows rather than settled by the writer, and adjudicated here.

The claim `R12` was written to make, that a missing rpath input does not disturb
the interpreter axis, is still made and is now made by a run that exists: under
`R14` the interpreter axis reports `unchanged` or `not-applicable` throughout and
never `failed`, which is the same independence claim stated in the terms the code
can produce. What is given up is the stronger `i-rewritten=2` form, which no
prefix could ever have produced.

**`R12`'s rpath column is settled by Q10, and the previous version of these rows
was wrong on the design's own terms.** They assigned **case 1** to all six
objects, which collapses the case into the disposition, and the design forbids
that in as many words: the case is population identity assigned from the
observation, and an empty computed search path is not an observation of the
object. Every case above is now the object's own.

The dispositions then followed from **Q10, answered 10B**: an empty or
unavailable computed target search path gives rpath `failed` to the objects whose
write was due, cases 4, 5 and 6, and leaves cases 1, 2, 3 and 7 with the
dispositions their cases already fix. `A28` is `failed` for its own ambiguity
reason rather than for this one. The run still fails acceptance through `A23` and
`A24`, so the narrower object-local meaning hides nothing.

##### The two-way derivation ledger

Claiming the rows come from the design is one-way prose. The same discipline
Q09 applies to the `/1` corpus applies here, in both directions, with zero
uncovered and zero underived entries.

**Design to matrix**, over the design's fault matrix and the production-outcome
rows of its acceptance table:

| Authoritative clause | Rows |
| --- | --- |
| fault: structural inconclusive blocks both axes | `A16`, `A17`, `A18` |
| fault: dynamic scan or `--print-rpath` fails, header valid | `A19` |
| fault: `tag_state: ambiguous` | `A07`, `A13` |
| fault: `--print-interpreter` fails while `has_interp` is yes | `A20` |
| fault: computed target search path empty | `A23` to `A28` |
| fault: `--set-rpath` fails on a selected object | `A21` |
| fault: `--set-interpreter` fails | `A22` |
| acceptance: the resolved loader is excluded and still executes | `A29`, `A30`, and `step4/archive-loader-runs` |
| acceptance: an ordinary shipped library is rewritten and still works | `A02`, and `step4/archive-python-runs` |
| acceptance: python fresh, prefix outside `/home`, both guards fire | `A01` |
| acceptance: python fresh, prefix at `$HOME`, case 6 | `A03` |
| acceptance: `$HOME` prefix relocated by v0.26.0, case 5, checked incremented | `A14` |
| acceptance: the same prefix, second run, case 3, zero rewrites | `A08`, `A09` |
| acceptance: `libstdc++`-shaped library, case 4, interpreter not applicable | `A02` |
| acceptance: RPM-extracted program, case 7 | `A04`, `A10` |
| acceptance: the same with a builder-anchored interpreter | `A05` |
| acceptance: program header table does not parse | `A16` |
| acceptance: `e_phnum == 0`, no table, case 2 | `A06`, `A12` |
| acceptance: longer than four bytes, shorter than the header | `A18` |
| acceptance: case 5 object whose `--set-rpath` fails, still counted | `A21` |
| acceptance: object with no `PT_DYNAMIC`, case 2 | `A06`, `A12` |
| acceptance: case 5 object carrying a host interpreter, one invariant failure | `A15` |
| acceptance: fresh run with no v0.26.0 objects, checked zero failed zero | `R1`, `R2` totals |
| acceptance: ELF32, big-endian, or extended `e_phnum` | `A17` |
| acceptance: truncated table, or a list never reaching `DT_NULL` | `A16` |
| acceptance: both `DT_RPATH` and `DT_RUNPATH` | `A07`, `A13` |
| acceptance: library whose `--print-rpath` errors, header valid | `A19` |
| acceptance: program whose `--print-interpreter` errors | `A20` |
| acceptance: `build_elf_rpath` returning an empty search path | `A23` to `A28` |
| acceptance: pass skipped because patchelf is absent | `R13` |

The acceptance table's remaining rows are **report-contract** obligations, not
production outcomes: the two zero-count trailers distinguished by state, a
capture with no trailer or two, the aggregate-versus-categorical trailer, a
`mig-checked` of zero over `case=5` records, `state=skipped` carrying work,
duplicate and unknown fields, the `path` base and its raw-byte encoding, the
space-free tokens, and the nine equalities. They are Step 3's, and the ledger
records them as out of scope here rather than silently omitting them.

**Matrix to design.** The previous version of this direction was a sentence
claiming every row cites a clause, which is an assertion and not a ledger. It was
already false: `A11` appeared in no forward entry. A claim of zero underived rows
has to be checkable by set equality, so the mapping is enumerated per row and the
check is that the id set of this table equals `{A01..A30} ∪ {R0..R7, IF01, IF02,
IW01, IW02, R14, R13}` exactly, with zero missing and zero extra. That run set is
the actual fourteen: renaming the four fault runs left the earlier `R0..R13`
range demanding four ids that no longer exist, which the mechanical check would
have reported rather than tolerated:

| Row | Authoritative clause it derives from | Which fields it fixes |
| --- | --- | --- |
| `A01` | acceptance: python fresh, prefix outside `/home`, both guards fire | case 6, both dispositions |
| `A02` | acceptance: `libstdc++`-shaped library, case 4, interpreter not applicable | case 4, both dispositions |
| `A03` | acceptance: python fresh, prefix at `$HOME` | case 6; interpreter from the source guard at lines 413 to 422 |
| `A04` | acceptance: RPM-extracted program, case 7 | case 7, rpath `excluded`; interpreter from the guard, a system interpreter matching neither clause |
| `A05` | acceptance: the same with a builder-anchored interpreter | case 7, rpath `excluded`, interpreter `rewritten` |
| `A06` | acceptance: no `PT_DYNAMIC`, case 2, plus `e_phnum == 0` observed successfully | case 2, rpath `not-dynamic`; interpreter `not-applicable` from `has_interp: no` |
| `A07` | acceptance: both `DT_RPATH` and `DT_RUNPATH`; fault: `tag_state: ambiguous` | case 1, rpath `failed`; interpreter `not-applicable` from `has_interp: no` |
| `A08` | acceptance: the same prefix, second run, case 3, zero rewrites | case 3, rpath `already-correct` |
| `A09` | the same clause | case 3; interpreter `unchanged`, the guard's second condition failing once the value is the target |
| `A10` | acceptance: RPM-extracted program, case 7, with the second-run zero-rewrites clause | case 7, `excluded`, interpreter `unchanged` |
| `A11` | acceptance: RPM-extracted program with a builder-anchored interpreter, **read on the second run** against the zero-rewrites clause | case 7, `excluded`; interpreter `unchanged`, because the first run made the value the target and the guard's second condition now fails. This is the entry the previous prose claimed and did not have |
| `A12` | acceptance: no `PT_DYNAMIC`, case 2 | case 2, both dispositions |
| `A13` | acceptance: both tags; fault: ambiguous | case 1, both dispositions |
| `A14` | acceptance: `$HOME` prefix relocated by v0.26.0, case 5, checked incremented | case 5, rpath `rewritten`, interpreter `unchanged`, `mig-checked` +1 |
| `A15` | acceptance: case 5 object carrying a host interpreter, one invariant failure | case 5, both `rewritten`, `mig-checked` +1 and `mig-failed` +1 |
| `A16` | acceptance: program header table does not parse; and truncated table or list never reaching `DT_NULL`; fault: structural inconclusive | case 1, both axes `failed` |
| `A17` | acceptance: ELF32, big-endian, or extended `e_phnum` | case 1, both axes `failed` |
| `A18` | acceptance: longer than four bytes, shorter than the header | case 1, both axes `failed` |
| `A19` | acceptance: **library** whose `--print-rpath` errors, header valid; fault: dynamic scan or `--print-rpath` fails | case 1, rpath `failed`, interpreter `not-applicable` |
| `A20` | acceptance: program whose `--print-interpreter` errors; fault: same | interpreter `failed`; case 6 and rpath `rewritten` from the case table, the rpath axis being untouched |
| `A21` | acceptance: case 5 object whose `--set-rpath` fails, still counted; fault: `--set-rpath` fails | case 5 held, rpath `failed`, `mig-checked` +1 |
| `A22` | fault: `--set-interpreter` fails | interpreter `failed`; case 6 and rpath `rewritten` from the case table |
| `A23` | fault and acceptance: empty search path, interpreter axis unaffected | rpath `failed`; **case 4 from the case table**, not from this clause |
| `A24` | the same clause | rpath `failed`; case 6 from the case table; interpreter `unchanged` because no interpreter target resolves under `R14` |
| `A25` | the same clause, as settled by Q10 (10B) | case 7 from the case table; rpath `excluded`, no write being due, per Q10 (10B) |
| `A26` | the same clause, as settled by Q10 (10B) | case 7; interpreter `unchanged` because no interpreter target resolves under `R14`; rpath `excluded`, no write being due, per Q10 (10B) |
| `A27` | the same clause, as settled by Q10 (10B) | case 2; rpath `not-dynamic`, no write being due, per Q10 (10B) |
| `A28` | acceptance: both tags; fault: ambiguous. The empty search path is not what fails this object | case 1, rpath `failed` independently of `R14`'s fault |
| `A29` | acceptance: the loader `find_dynamic_linker` resolves is excluded and still executes | case 7 from the loader rule, not from fall-through; rpath `excluded`, no write being due; interpreter `not-applicable`, the object having no `PT_INTERP` |
| `A30` | the same clause, on the second pass | case 7 again and never `already correct`, which is what places the rule before case 3 |
| `R0`, `R1`, `R2` | acceptance: fresh run with no v0.26.0 objects, checked zero failed zero | `mig-checked` 0 and `mig-failed` 0 in those runs' totals |
| `R3`, `R4` | acceptance: v0.26.0 relocation and host-interpreter rows | their migration totals |
| `R5`, `R6`, `R7` | the structural, domain and short-file acceptance rows | one-object totals |
| `IF01`, `IF02` | the two probe-failure acceptance rows | one-object totals |
| `IW01`, `IW02` | the two write-failure fault rows | one-object totals |
| `R14` | fault and acceptance: empty search path, as settled by Q10 (10B) | run-level totals |
| `R13` | acceptance: pass skipped because patchelf is absent | zero records, one `skipped` trailer |

Two entries are worth reading closely. `A11` is the row the asserted ledger
missed entirely, and supplying it required noticing that `X4`'s interpreter was
rewritten on the **first** pass, so on the second the guard's `!=` condition
fails and the value is `unchanged`. And the `A23` to `A28` block is where the
field-level requirement did its work: the empty-search-path clause fixes an rpath
**disposition** and fixes no case at all, so the cases come from the case table
and the previous rows' uniform case 1 was an error rather than a shorthand.

Running the ledger in the second direction is what produced four of the rows
above. `A18` exists because the "shorter than the header" acceptance row had no
integration coverage; `A17` because the domain rejections were folded into the
structural one; `A21` because `W01` had been written over a case 6 object and the
design's row is specifically about a **case 5** object keeping its migration
count; and `A19` because the design's probe-failure row names a **library**,
whose interpreter axis is `not-applicable`, where the plan had used a program. A
one-way derivation would have found none of them.

If the ledger finds a clause that is silent or admits two readings, that is a
stop for a new reviewed question rather than permission to choose a value here.

#### Mutation failures are not probe failures

`D01` and `D02` make a **probe** fail, `--print-rpath` and `--print-interpreter`.
They say nothing about the write branches, and the write branches are the ones
that produce the acceptance's failure dispositions. Requiring both failure
figures to be zero on a healthy archive proves the success path and nothing else;
it cannot show that a failed write is reported on the correct axis while the
other axis survives.

`W01` and `W02` are therefore separate integration cases, each with a controlled
patchelf double that fails one **write**, and each with an exact subject rather
than a description:

| Case | Run / object | Double fails | Case assigned | Failing axis | Surviving axis, literally |
| --- | --- | --- | --- | --- | --- |
| `D01` | `R8` / `X12`, a library | `--print-rpath` | 1 | rpath `failed` | interpreter `not-applicable`, no value present, since `X12` has no `PT_INTERP` |
| `D02` | `R9` / `X2`, a program | `--print-interpreter` | **6** | interpreter `failed` | rpath `rewritten`, `--print-rpath` returning the builder-anchored value and the write performed |
| `W01` | `R10` / `X7`, a **case 5** object | `--set-rpath` | **5** | rpath `failed` | interpreter `unchanged`, and `mig-checked` still +1 |
| `W02` | `R11` / `X2`, a program | `--set-interpreter` | 6 | interpreter `failed` | rpath `rewritten`, the write performed |

The case column is the point of the table. A write failure changes the
**disposition**, never the case: the case is a function of the observed tuple,
which the write has not yet touched when the classifier runs. `W01` on a case 5
object is the design's own row, and it is what shows `mig-checked` counting a
population rather than a set of successes.

Each case asserts that the failed mutation is **not counted as rewritten**, and
that the surviving axis is neither erased nor fabricated. Both doubles are
bounded by the containment and shipped-identity rules already settled for `D01`
and `D02`, which apply unchanged: own subshell, private scratch state, asserted
resolution, exit trap, and the pinned-digest re-assertion with the `F06` sentinel
afterwards.

#### The formatter's call sites, enumerated

Step 3's assertion says the identifier occurs once; this step's successor said
"at exactly the call sites this step enumerates, each named", and then enumerated
none. The enumeration is load-bearing rather than bookkeeping, because record
cardinality is what stops a failed, excluded or not-dynamically-linked object
disappearing from the reconciliation.

There are exactly two production call sites:

| Site | Cardinality | How that is made structural |
| --- | --- | --- |
| the **object-record** site | exactly once per walked ELF, **whatever its disposition**, including failed, excluded and not dynamically linked | it sits at a single per-object emission point that every disposition falls through to, so no early `continue` in the loop body can bypass it. Dispositions are assigned to variables and emitted in one place rather than emitted per branch |
| the **terminal trailer** site | exactly once per run | it sits at a single exit point reached on every path, including the skipped one, with `state` and `reason` carried in variables. One exit means the skipped path cannot omit the trailer and no path can emit two |

So after this step `emit_cplx_elf_v1_record` occurs as a whole shell word in
`install_pkg.sh` **exactly three times**: the definition, the object-record site
and the terminal site, and in no comment or message literal. That is the number
the static assertion checks.

Placing both at single points is what makes `walked` equal the object-record
count **structurally**, rather than making the categorical reconciliation
responsible for catching a branch that forgot to emit.

### Step 4 behavior

`--set-rpath` gains `--force-rpath`. Cases 4, 5 and 6 write; 1, 2, 3 and 7 do
not. The migration assertion runs after classification and never filters it.
Records are emitted during the existing walk, never gathered for a second one.

### Step 4 completion criteria

- `readelf -d` shows `RPATH` on the python ELF and on `libstdc++.so.6.0.29`, and
  the selected set over the staging copy is the one Step 2 states once: the 110
  flagged libraries, the python program by name, and the enumerated git objects.
  **"Every other archive program preserved" is NOT asserted here.** It is an
  ACCEPTANCE claim, it lives under the requirement's `## Acceptance` heading,
  and acceptance is Step 6, which runs over the deployed archive and admits no
  exception. An earlier revision of this bullet asserted it at this step, which
  is how this plan came to forbid and permit the same object in one section.
  What Step 4 shows is the selected set it produced and the residuals it found;
  what Step 6 proves is that the archive contains nothing else selected;
- **the loader is excluded and the tree still runs.** The object
  `find_dynamic_linker` resolves answers case 7 and is never written, asserted
  at the classifier seam in both directions so the rows are not vacuous: the
  same tuple classified without the rule answers case 4, and with it answers 7,
  including through the symlink layout the archive actually ships. And after the
  pass over the real archive copy, **the shipped loader and the shipped python
  are executed**, not counted. This criterion exists because a reconciled
  account cannot see this class of damage: patchelf exits 0 on the loader and
  destroys it, so the record reads `rewritten`, the trailer balances, and the
  tree segfaults at exec;
- **the residual half runs here, and what it gates is what this step owns.**
  The pass walks a copy of the real extracted archive, the capture reconciles,
  and **every residual program is classified**: the pass answered for each one.
  That is the assertion Step 4 can honestly make, and an unclassified residual
  is a classifier defect and fails this step. It is a copy and not the tree
  itself because the pass mutates what it walks and this harness does not own
  that tree: on the build agent it is the prefix the next pipeline stage runs.
  What the copy costs is exact and stated: cases 3 and 5 compare an object
  against the search path computed for its prefix, so an object the live tree
  calls case 5 the copy calls case 6. Both are selected populations, and this
  step reports either the same way;
- **whether the ARCHIVE should carry a selected residual is NOT gated here.**
  Step 2 gave the reason and it has not changed: a residual is a property of the
  archive rather than of the classifier. Step 4 walks a staging copy; the object
  lives in the published archive; and the only work that removes it is a
  rebuild, which is umbrella requirement 7. So every selected residual is
  REPORTED here with its owner, and the gate is Step 6's, whose criteria already
  call themselves the final assertion of the residual half, over the deployed
  archive, admitting no exception. This step ends by naming the set it hands
  over. An earlier revision of this plan gated it here and then had to excuse
  the failure; moving the gate to where the deployed archive is in hand is the
  correction, and it narrows Step 4 rather than weakening Step 6;
- **the ownership register is literal and self-retiring, and THAT is gated
  here.** Each known selected residual is recorded by exact path with its owning
  requirement, so the handoff names an owner rather than a path and an
  unadjudicated violation is visibly different from an adjudicated one. It is a
  literal path list and never a pattern. It is asserted in both directions, and
  the second direction is this step's own bookkeeping rather than the archive's
  contents: an entry the archive no longer carries **fails**, so a rebuilt
  archive cannot land while this plan still names a violation the rebuild
  removed. Today it holds exactly one entry, `tools/python/root/a.out`, owned by
  umbrella requirement 7 (`tools-archive-rebuild`);
- a second run and a `--force` reinstall rewrite nothing and account for the
  covered set as `already correct`;
- the three `$HOME` cases behave as the design's acceptance table states;
- **every row of the production outcome matrix passes**, `A01` to `A30` over runs
  `R0` to `R7`, `IF01`, `IF02`, `IW01`, `IW02`, `R14` and `R13`, each against its
  literal cells. No cell is a placeholder: every
  case is 1 to 7, every disposition is one of its closed wire tokens, and every
  migration delta is a number;
- **the matrix is rectangular**, and its column count is asserted mechanically,
  so a shifted row fails as a malformed table rather than as a puzzling
  expectation. This is the check that would have caught the `D02` row;
- **every walked object reconciles on both axes.** Each row contributes `walked`
  +1, exactly one `r-` bucket +1, exactly one `i-` bucket +1 and its stated
  migration deltas, with every other bucket unchanged; and over every run the
  five `r-` buckets sum to `walked` and the four `i-` buckets sum to `walked`;
- **every capture a matrix row produced is parsed by the Step 3 reader and
  asserted in full**: the complete object record, field by field including the
  scenario-fixed `path`, and the categorical trailer, not merely accepted as
  syntactically valid. The design's one-object capture is retained as one
  verified row only if its fields and totals still match its scenario; if they do
  not, the Q09 adjudication rule applies and `/1` semantics are not edited here;
- `D01`, `D02`, `W01` and `W02` each name their exact run and object, their
  assigned case, and their surviving axis's literal outcome. `W01` runs over a
  **case 5** object and keeps `mig-checked` at +1 while its rpath disposition is
  `failed`, since the case is population identity and does not change with the
  outcome of acting on it. Their doubles are bounded by the same containment and
  shipped-identity rules as before;
- **the two-way derivation ledger is complete and enumerated in both
  directions**: every applicable row of the design's fault matrix and every
  production-outcome row of its acceptance table maps to one or more matrix rows,
  with zero uncovered; and **every** `A01` to `A30` and every one of the fourteen
  runs, `R0` to `R7`, `IF01`, `IF02`, `IW01`, `IW02`, `R14` and `R13`, has its
  own reverse entry naming
  the clause and the fields that clause fixes. The check is **set equality** on
  the id sets, reporting zero missing and zero extra, not a sentence claiming
  coverage; the previous sentence was already false, `A11` having no entry. The
  acceptance table's report-contract rows are recorded as Step 3's;
- **expected trailer totals are derived, not transcribed.** The harness folds the
  expected per-object rows into expected per-run counters and makes three
  comparisons: fold against the literal totals table, fold against the actual
  parsed trailer, and literal table against the actual parsed trailer. The
  literal table has been independently recomputed and is correct, so this guards
  later drift rather than a present error;
- `R14`'s rows follow Q10, answered 10B: rpath `failed` only where a write was
  due, cases 4, 5 and 6, with cases 1, 2, 3 and 7 keeping their case-defined
  dispositions. No row is provisional;
- a skipped pass emits a trailer with a zero total, no records, and the skipped
  run state;
- with patchelf absent the pass is still skipped and the install still succeeds;
- no second walk of the tree was added to the production pass;
- **the formatter's call sites are the intended ones, and they are named**. Step
  3's assertion, that `emit_cplx_elf_v1_record` occurs exactly once, is replaced
  here by its successor: the whole shell word occurs **exactly three times**, at
  its definition, at the single object-record site and at the single terminal
  trailer site, and in no comment or message literal. The property flips from "no
  caller" to "these callers" in the step that creates them;
- the object-record site is reached once per walked ELF whatever its disposition,
  and the terminal site once per run on every exit path, both asserted by the
  matrix rather than inferred from the code's shape;
- **the Step 3 regression is re-run unchanged against its own literal and
  constructed inputs**, corpus, canonical vectors, permutations and malformed
  forms alike. It is a separate suite from the integration above and neither
  stands in for the other;
- the reader is still absent from `install_pkg.sh`.

## Step 4 addendums

### Step 4 line budget checkpoint

- Baseline: the Step 3 result. Advisory estimate: 60 to 90 further lines,
  unchanged by the Q08 move, since the wiring, the writes, the accumulation and
  the call sites all ship regardless of where the reader lives.
- Running advisory total for `install_pkg.sh` across the effort: the 625-line
  baseline plus roughly 220 to 330, against 260 to 390 before the reader moved
  out. The saving lands entirely on the file that must ship standalone.
- **This is the checkpoint where the file size is judged**, since it is the last
  step that adds production code. Record the measured total. If the standalone
  script has become unworkable to read or maintain, say so with the number
  rather than the impression, and raise it as a requirement amendment for the
  deployment shape. Do not split the file inside this step: it would change what
  the archive ships and what the how-to instructs, neither of which this plan
  owns. The estimate is advisory throughout and is never a gate.

#### Step 4 measured line budget

Measured with `wc -l` on `src/setups/env/bin/install_pkg.sh` at each step's own
commit, so every figure is reproducible from the history rather than recalled.

| Point | Commit | Physical lines | Delta |
| --- | --- | --- | --- |
| baseline, before the effort's production work | `ddebdc7` | 625 | - |
| Step 0, the source-safe seam | `a19da45` | 649 | +24 |
| Step 1, the observer | `2ab83f4` | 874 | +225 |
| Step 2, the classifier | `bed0229` | 1015 | +141 |
| Step 3, the formatter | `31db242` | 1120 | +105 |
| **Step 4, the wiring and the loader rule** | staged | **1281** | **+161** |

Non-blank, non-comment lines: 631 at Step 3, 693 staged at Step 4, so 62 of the
161 are code and 99 are comment or blank.

**The advisory band was exceeded, and by how much is the point.** Step 4's own
estimate was 60 to 90 further lines; the measured figure is 161, roughly double
the top of that band. The running estimate for the effort was the 625 baseline
plus 220 to 330, so 845 to 955; the measured total is 1281, between 326 and 436
lines past it. Every earlier step also ran over, so this is not one step's
surprise.

**Maintainability assessment: the file is at its limit but not past it, and the
number rather than the impression says so.** 693 lines carry logic and 588 carry
rationale, a ratio this project chose deliberately and which is the reason the
file reads at 1281 lines rather than becoming unreadable at 900. The logic is
seven functions with one walk between them and no nesting deeper than the walk
itself.

**Raised, not resolved here:** the deployment shape should be revisited before
the file grows again. Nothing in v0.27.0 may split it, for the reason this
checkpoint already gives, so this is recorded as an input to the archive-shape
requirement rather than acted on. The next production step that touches this
file should carry that amendment first.

The reviewer's round 3 answer cites 1010 to 1149 for the same checkpoint. Those
are not the figures `wc -l` produces at the commits above and the method behind
them is not stated, so the table records what is measurable and reproducible and
flags the difference rather than adopting either figure silently.

### Step 4 workflow timing readiness

More objects are written than before, roughly 110 additional patchelf writes,
and record emission is per object. Compare the walk duration with the Step 0
baseline and record it; there is no timing gate, and a regression is reported
rather than absorbed.

### Step 4 time-gated status

Not started.

---

## Step 5 analysis and intent

### Step 5 issues

Three wiki pages describe the pass accurately today and stop doing so the moment
Step 4 lands.

### Step 5 fix intent

Update them, and record the `setenv` export that stops affecting the shipped
directories.

### Step 5 expected outcome

The archive stops shipping a description that contradicts its own loader
behavior.

### Step 5 framings

After the behavior is final, so the pages describe what exists.

### Step 5 complexity impact

None in code.

### Step 5 feature preservation

Not applicable.

## Step 5 implementation

### Step 5 files involved

- `wiki/reference/relocation-tools.md` (existing, to be updated)
- `wiki/explanation/why-binaries-remember-the-build-home.md` (existing, to be updated)
- `wiki/how-to/relocate-an-install-to-another-prefix.md` (existing, to be updated)

### Step 5 test first

Two checks, and the previous version had only the second. A stale-wording grep is
a **negative** test: it passes when the offending phrase is absent, and deleting
the surrounding prose satisfies it perfectly. This step states eight positive
documentation obligations in its behavior section, and a suite of two negative
greps establishes none of them. A page that had its ELF section removed entirely
would have gone green.

So the primary check is **positive, per obligation**, a coverage table asserted
page by page:

| Page | Obligation asserted present |
| --- | --- |
| `relocation-tools.md` | the tag actually written, `DT_RPATH` |
| `relocation-tools.md` | the three populations |
| `relocation-tools.md` | the rpath disposition axis |
| `relocation-tools.md` | the interpreter disposition axis |
| `relocation-tools.md` | what the pass leaves untouched |
| `why-binaries-remember-the-build-home.md` | that the install-time rewrite now produces `DT_RPATH`, and the consequence for `LD_LIBRARY_PATH` and for `setenv` |
| `relocate-an-install-to-another-prefix.md` | a check expecting `RPATH` exactly, not either tag |
| `relocate-an-install-to-another-prefix.md` | the library-side check |

The stale-wording grep stays as a **backstop** beside it: no page states the
`/home/` guard as the whole rule, and the how-to's check block accepts neither
tag indifferently. Backstop, not proof, for the same reason the Step 0 baseline
is a backstop in Step 3: absence of the wrong thing is not presence of the right
one.

### Step 5 behavior

The reference records the tag written, the three populations, the two
dispositions and what the pass does not touch. The explanation records that the
install-time rewrite now produces `DT_RPATH` and what that means for
`LD_LIBRARY_PATH` and for `setenv`. The how-to expects `RPATH` and adds a
library-side check.

### Step 5 completion criteria

- **every row of the coverage table is asserted present** on its named page, all
  eight obligations, so deleting the relevant prose fails this step rather than
  satisfying it;
- the stale-wording grep is clean, as a backstop rather than as the evidence;
- the host-tool list is unchanged, since no installer tool was added.

## Step 5 addendums

### Step 5 line budget checkpoint

No code file changes.

### Step 5 workflow timing readiness

Not applicable.

### Step 5 time-gated status

Implemented on 2026-08-27. The suite is host independent and returns
OBJECTIVE MET at exit 0 on the authoring host, so no agent build is owed.

---

## Step 6 analysis and intent

### Step 6 issues

The individual steps are proved. The requirement's acceptance is not.

### Step 6 fix intent

Run the acceptance as a whole: the states of the design's validation table, the
inventory check, the `OPENSSL_3.x` verdict, and the RHEL evidence.

### Step 6 expected outcome

Retained evidence for every cplx-owned criterion, a recorded verdict for the one
that may be blocked, and a written handoff for the downstream ones.

### Step 6 framings

Last, because it consumes every earlier step.

### Step 6 complexity impact

One exclusion in the classifier, added because the acceptance measured the
defect it prevents. The step was planned as none in code and is no longer,
which is recorded above rather than absorbed.

### Step 6 feature preservation

This is where preservation is proved rather than asserted.

## Step 6 implementation

### Step 6 files involved

- `docs/v0.27.0/verify.relocation-rpath.sh` (existing, to be updated)
- `docs/v0.27.0/verify.acceptance.rpath.rhel.txt` (new): the first RHEL
  session's retained evidence
- `docs/v0.27.0/verify.acceptance.rpath.rhel.session2.txt` (new): the second
  RHEL session. The plan asked for ONE ordered session and this is two, which
  is recorded rather than smoothed over: session 1 wrote the requirement's
  functional criteria down as owed instead of collecting them, and session 2
  went back for them. It also corrects a form 1 finding session 1 got wrong
- `docs/v0.27.0/request.monitoring-observable.rhel.md` (new): the drafted
  monitoring request. It is a separate file because a blocked record whose
  retained evidence is the record itself is circular, which round 1 caught
- `docs/v0.27.0/verify.relocation.step6.debian.txt` (new): the acceptance
  capture over the deployed archive
- `docs/v0.27.0/verify.relocation.step1.debian.txt`,
  `verify.relocation.step2.debian.txt`, `verify.relocation.step3.debian.txt`,
  `verify.relocation.step4.debian.txt` and
  `verify.relocation.loader-probe.debian.txt` (existing, re-taken): the agent
  evidence, retaken from the build carrying this step's harness, because a
  capture recording a different harness digest is evidence about a different
  file
- `src/setups/env/bin/install_pkg.sh` (existing, updated): **and this is a
  declared change to this step's scope.** The step was written as "None in
  code", and the acceptance then found a production defect: the pass was
  rewriting the patchelf binary executing it, which the kernel refuses, so a
  write that was due failed silently behind a warning. Finding exactly that is
  what an acceptance step is for, and leaving a measured defect unfixed to
  protect a scope line would be the wrong trade. The fix is one exclusion beside
  the loader rule.
### Step 6 test first

Acceptance cases larger than the per-step ones: a full relocation of the
published archive into a fresh prefix outside `/home`; the three `$HOME` states;
a `--force` reinstall; and a RHEL deployment run.

### Step 6 behavior

The classifier is exercised against the `develop#24` inventory to show it selects
exactly the set Step 2 states once, using that same statement rather than a
paraphrase of it. The shipped loader lists `libstdc++.so.6.0.29` resolving inside
the prefix. The `OPENSSL_3.x` nodes are re-read and the answering libcrypto
named.

### Step 6 RHEL acceptance session

This effort carries two debts that need the RHEL target: the exact-target
capability confirmation, if Step 0 ended `unavailable`, and the deployment with
its preload measurement. They are **one ordered session**, not two visits. The
plan says so explicitly because two separately-listed debts read as two trips to
be arranged, and they are the same trip.

The session has one recorded identity, and everything below names it:

1. **Open.** Record the run identity, the exact target identity and the Bash
   version it reports. Every later artifact and any monitoring evidence arriving
   afterwards cites this run.
2. **Capability first.** Run the `declare -A` check on that target, before the
   installer is invoked at all:
   - `unsupported` ends the session here, for plan revision. Nothing is
     deployed, because the carrier the deployment would exercise is the thing
     just disproved;
   - `supported` closes the provisional debt from Step 0 and the session
     continues immediately.
3. **Deploy and measure.** Under the same run identity, run the deployment and
   the preload measurement, recording `liboneagentproc.so`, its own tag state,
   and its dependency providers before and after.
4. **Then, and only then, judge monitoring.** The monitoring branch is entered
   only after step 3 succeeded.

If target access is unavailable, the session never reaches step 2, and Step 6 is
**incomplete**. No capability verdict and no monitoring verdict are due, because
neither run happened. Ordering the capability check first is what makes Q05's
debt a prerequisite inside Q06's entry condition rather than a parallel item
that could be settled elsewhere.

### Step 6 blocked-evidence rule

The monitoring observable may depend on the team owning the monitoring agent,
and the requirement allows that criterion to be recorded as blocked.

**Terminal blocked is narrow, and it is reached from exactly one state.** It
applies only after the real RHEL deployment ran and the preload measurement
succeeded, and none of the requirement's three monitoring observables could be
obtained. It is not a verdict available to a run that did not happen.

That matters because this plan contains a second unavailability, the exact-target
capability check of Step 0, and collapsing the two would let the effort skip the
RHEL run entirely and still report a terminal verdict. **The two do not
compound: the first prevents reaching the second.** An unreachable target leaves
this step incomplete, with the acceptance unfinished, and no monitoring verdict
is due because the run that would have produced it never occurred.

**Given that a real-target run happened, blocked has exactly one lifecycle
meaning**, and an earlier version of this section carried two that cannot both
hold. It said blocked was terminal and did not hold the effort open, and also
that acceptance was not complete while it stood, which is the definition of
holding it open. The single meaning is:

- evidence collection **completes**, with an overall validation verdict of
  `blocked`;
- the monitoring criterion is **unsatisfied**, the acceptance is **not green**,
  and no implementation success may be claimed on the strength of it;
- the verdict is **terminal**: the effort does not sit waiting on another team's
  calendar, and the blocked record is what carries the gap forward.

Unsatisfied and terminal are compatible; unsatisfied and still-running are not,
and the earlier wording asserted both.

A blocked record names, at minimum:

- the owning team or contact channel, not a personal name, since this is
  committed evidence;
- the request timestamp or identifier;
- which of the requirement's three acceptable observables was requested;
- the response, or the fact that none was received by the recorded date;
- the path of the retained evidence for the request itself.

### Step 6 completion criteria

- **no write that was due failed**, and every observation failure is outside the
  supported domain for a nameable reason. `failed` on an axis covers two events
  and only one is a defect: an object at case 1 reports it because its
  OBSERVATION was inconclusive, which the domain excludes by rule and row `A17`
  fixes; an object at case 4, 5 or 6 reports it because a write that was due did
  not happen. Requiring the sum to be zero would fail this archive for shipping
  the 26 ELF32 objects the design already excludes, so the gate is stated over
  writes. The exclusions are checked against each object's own header rather
  than accepted because the classifier said case 1, so an unexplained case 1
  fails rather than joining an expected count. The raw trailer figures are
  reported beside both, since they are the complete numbers and neither is a
  verdict;
- the migration failed figure is zero;
- the migration checked figure is positive and equals the case 5 count on the
  dedicated v0.26.0 run. MOVED to umbrella requirement 7 by the scope correction
  below: it needs a v0.26.0 install followed by a candidate pass, which is a
  rebuild cycle this requirement does not perform;
- **the full inventory check is a criterion here, not a description in
  `behavior`.** The retained evidence carries the walked and selected counts and
  populations, and the assertions are the ones Step 2 states once: the 110
  flagged libraries as case 4, the python program **asserted by name**, the
  enumerated git objects, and every other archive program preserved as case 7. An
  excluded program that was quietly rewritten fails this step, because that is a
  statement about what the PASS did and this requirement owns the pass;
- **what the ARCHIVE CONTAINS is NOT a criterion of this requirement.** SCOPE
  CORRECTION of 2026-08-29, recorded in the umbrella against item 2.

  The umbrella places this requirement second because it "needs no rebuild
  either, and can be proved against the current archive". Two criteria written
  into this step crossed that boundary: that no residual program the archive's
  record does not name is selected, and that Step 4's handoff set is empty.
  Neither is answerable by any change to `install_pkg.sh`, because the only
  discharge is removing an object from the archive, and removal is umbrella
  requirement 7's work. This requirement therefore gated itself on an artifact
  produced by the requirement that consumes it, requirement 3 could not start
  behind it, and nine review rounds ended the same way before the cause was
  named.

  Both assertions MOVE TO UMBRELLA REQUIREMENT 7 whole and unsoftened, where the
  rebuild happens and the archive's contents first become assertable. So do the
  three criteria this step could never execute without a rebuilt archive:
  migration positivity and case 5 equality, the three `$HOME` states, and force
  reinstall.

  What this step still gates, and answers today against the current archive: an
  UNADJUDICATED residual, one no owner has claimed in the register, FAILS here
  and now. That is a statement about the pass selecting something nobody has
  accounted for, which this requirement owns. An adjudicated one is reported
  with its owner and handed to requirement 7. The handoff is the deliverable;
  the discharge is not;
- **every retained capture is accepted by the categorical reader**, the Step 3
  one, rather than being read by eye. A capture that no reader accepted is not
  acceptance evidence;
- the shipped patchelf's actual print and force behavior is recorded, and both
  are asserted on the VALUE rather than on the shape of the answer: print must
  return components that are existing directories inside the deployed prefix,
  and force must be shown to have written the value it was asked for. A tool
  that prints a stale target-valued rpath, or emits `DT_RPATH` while ignoring
  `--set-rpath`, satisfies a non-emptiness test and fails the requirement;
- **the functional evidence the requirement names is a criterion of this step,
  taken on the target over a relocated tree**: the toolchain git answers, the
  toolchain python answers, and `import ssl, zlib` passes, each at exit 0, with
  the provider the interpreter actually binds resolved by the shipped loader
  and shown to be inside the prefix. Needing a human to open the session does
  not move this criterion outside the acceptance; it means the acceptance is
  not finished until the session happens;
- the `OPENSSL_3.x` verdict names a provider per libssl;
- the monitoring criterion carries exactly one machine-readable disposition,
  `satisfied`, `not-pursued` or `blocked`, on exactly one retained capture, and
  the harness parses that token rather than inferring a verdict from a heading.
  Two captures naming two dispositions is two answers to one question and fails.
  - `satisfied` requires a retained evidence value;
  - `blocked` requires all five fields to carry values AND the request to have
    been despatched;
  - **`not-pursued` is an AMENDMENT and must read as one.** It requires the
    mechanism answer, the decider, the basis, and an outcome recorded for each
    of the three named forms. It is available only where the hazard is closed
    by construction rather than by observation, and it is a human decision that
    the harness records rather than makes. Today it is taken once: the
    preloaded agent is statically linked, so `DT_RPATH` cannot reach it, no
    observable form is obtainable by the deployment account, and the human
    owner decided on 2026-08-28 not to pursue a vendor attestation for a risk
    already closed. A `not-pursued` with any part of that record missing fails,
    and the harness retains eight controls proving it;
- the RHEL acceptance session ran in its stated order, with one recorded run
  identity **that the evidence below it actually cites**, the target identity
  and its Bash version. A capture naming its run once, in its own header, has
  not cited it: the uniqueness test passes on such a file no matter what, which
  is how both captures came to claim that every artifact cited the run while
  neither did. If Step 0's check ended
  `unavailable`, the debt is settled inside that session, with three outcomes
  and no fourth:

  | Exact-target result | Consequence |
  | --- | --- |
  | supported | the provisional branch closes and the session continues to deployment under the same run identity |
  | unsupported | the session ends here for plan revision; nothing is deployed |
  | target still unavailable | the session never opened, so this step is **incomplete**. No capability verdict and no monitoring verdict are due, and this is not Q06's terminal blocked verdict |

- any monitoring evidence arriving after the session names that same run
  identity, so a later answer cannot be attached to a run it did not describe;
- the downstream column is written up as a handoff, not claimed as done.

## Step 6 addendums

### Step 6 line budget checkpoint

The step was planned as no production file change and became one, so the figure
is recorded here rather than left saying none.

`src/setups/env/bin/install_pkg.sh`, measured with `wc -l` before the first edit
of this step and after the last:

| Point | Lines |
| --- | --- |
| entering Step 6, the Step 5 result | 1281 |
| after the running-patchelf exclusion | 1308 |
| delta | +27 |

Twenty-seven lines for one identity comparison and the rationale that records the
measurement forcing it, of which 5 are code and 22 are comment. The Step 4
checkpoint judged the file at its limit and raised the deployment shape as an
input to the archive-shape requirement; +27 does not change that judgement and
does not reopen it.

### Step 6 workflow timing readiness

The full acceptance is the longest run of the effort. Record its duration so a
later cycle knows what it costs.

### Step 6 time-gated status

Run on 2026-08-28. The Debian agent half is answered by the build carrying this
step's harness, and the RHEL half by two sessions:
`rhel-acceptance-20260827T114631Z` and `rhel-acceptance2-20260827T222103Z`. The
plan asked for one and there are two, because the first recorded the
requirement's functional criteria as owed instead of collecting them.

THE ACCEPTANCE IS GREEN for every criterion this requirement owns, measured by
run `step6scope-20260829T203916Z`: 216 cases, 0 failures, `OBJECTIVE MET` at
exit 0, with no `UNANSWERED`.

- `tools/python/root/a.out` is still selected in the published archive, on both
  distribution paths. It is TRANSFERRED to umbrella requirement 7 with its owner
  named, reported here as a handover and NOT as `UNANSWERED`, under the one
  residual contract the issue states and the harness implements. Migration
  positivity and case 5 equality, the three `$HOME` states and force reinstall
  are transferred to the same requirement for the same reason: each needs a
  rebuild cycle this requirement does not perform.
- an UNADJUDICATED residual, one no owner has claimed in the register, still
  FAILS here and now. Proved by a planted control in run
  `step6verify-20260829T132824Z`.

The monitoring criterion is no longer one of them. It is recorded `not-pursued`
by a human decision dated 2026-08-28, answered on the mechanism rather than by
observation, and that is an **amendment to the acceptance** rather than a pass.
An earlier revision of this section called it terminally blocked while the
retained record said the request was never made, which round 4 was right to call
contradictory: an undespatched request has no terminal verdict. The
contradiction is resolved by deciding, not by relabelling.

Everything else Step 6 owns passes on both hosts.

---

## Execution command checklist for v0.27.0 relocation-force-rpath

Every step runs the same three checks, in this order, stopping at the first
failure. They are described once here and referenced by each step.

1. **Count lines before and after.** Record the physical line count of every
   file the step touches, before the first edit and after the last:
   `wc -l src/setups/env/bin/install_pkg.sh`. Write both numbers into the step's
   line budget checkpoint. The baseline is 625.
2. **Run the gate and the tests.** One walk, which lints and then exercises the
   step's cases and stops at the first non-green result:
   `shellcheck src/setups/env/bin/install_pkg.sh docs/v0.27.0/verify.relocation-rpath.sh`
   followed by
   `bash docs/v0.27.0/verify.relocation-rpath.sh --step N`.
   Repeat fix-and-walk until it reports the step's objective. This is the
   substitute for the `ghog day` walk the template assumes, and it keeps the
   same property: one command sequence, gate first, stop at the first failure.
3. **Run the host-tool check.** Confirm the step introduced no host tool outside
   the audited contract. The check is the harness's own, which is where its
   negative cases live:
   `bash docs/v0.27.0/verify.relocation-rpath.sh --step 0` must report
   `host-tool/no-invocations` passing, alongside the six shapes it must reject
   and the two it must allow.

   **This replaces the bare-word grep the checklist carried until now**, and the
   replacement is a narrowing rather than a loosening. The old form was
   `grep -nE '\b(readelf|sha256sum|stat|wc|awk|perl|python)\b'` over the
   installer, required to print nothing. It cannot: `python` appears four times
   inside path strings the installer must contain,
   `tools/python/root/lib64/...` and the `tool_dir` loop, and once in a comment.
   A check that can never pass is not a gate, and the two available repairs were
   to weaken it or to make it match the property it is actually about.

   The property is that no forbidden tool is **invoked**. An invocation is a name
   in command position: at the start of a command, or after a separator, a pipe,
   a subshell opener, a command substitution, or a `then`, `else`, `do` or `elif`
   keyword. A name anywhere else is an argument or a path fragment, and a comment
   invokes nothing. That rule rejects `/usr/bin/python -c pass` and
   `./readelf -d x`, which an earlier slash-adjacency attempt let through, and
   accepts the installer's own path strings.

   `readelf` and `sha256sum` are in the forbidden set because they are **harness
   prerequisites**: they belong to the validation host and never to a deployment,
   so their appearing in the installer is the drift this check exists to catch.

   **Amendment, Step 1: the allowlist half is now a rule too.** Until now this
   checklist item enforced only the denylist, and the completion criteria asked
   for the other half as "a read of the diff confirms only `od`, `head`, `find`
   and the shipped patchelf". A reading is not a check. The consequence arrived
   on schedule: the first Step 1 observer read bytes with `dd`, shellcheck was
   clean, `host-tool/no-invocations` passed, and a tool outside the contract
   shipped. A denylist cannot enforce an allowlist, because a tool on neither
   list is exactly what it fails to see.

   So the permitted vocabulary is decided here, and the decision has three
   parts, because the installer's command words are three different kinds of
   thing.

   **Shell keywords and builtins are permitted without being listed.** They are
   the interpreter, not the host. The deployment contract already pins the
   interpreter, so a builtin adds no host dependency and listing one would grow
   the vocabulary without measuring anything. The two sets are bash's own and
   are named in the harness rather than curated.

   **Functions are permitted when the installer defines them, or when a shipped
   file it sources defines them.** They are read from the installer rather than
   listed, so a renamed function cannot silently fall out of the vocabulary.

   **External commands are the vocabulary, and they live in
   `docs/v0.27.0/contract.host-tools.txt`**, committed beside the harness as
   plain data, in the same shape as Step 3's contract corpus: one entry per
   line, four columns, name, invocation form, resolver, purpose. Every
   command-position word the harness extracts must appear there, and every entry
   there must appear in the installer, so the file cannot drift in either
   direction. Adding a host dependency therefore means editing a reviewed file,
   which is the visibility the reading was supposed to provide and did not.

   **The rule's limit is stated rather than papered over.** It is lexical, so a
   command reached through a variable is invisible to it. That is not
   hypothetical: patchelf is always invoked as `"$patchelf_bin"`. The `form`
   column carries `indirect` for those, and an `indirect` entry must name a
   resolver function that the harness then confirms is defined in the installer.
   That turns an unprovable claim into a checkable one. It does not make the
   rule total, and the harness must not report it as though it did.

   The gate is `bash docs/v0.27.0/verify.relocation-rpath.sh --step 0`, which
   must report `host-tool/allowlist-unlisted` and `host-tool/contract-unused` at
   zero, the contract well-formed, and BOTH matrices green.

   **Every reject case requires the exact planted dependency**, compared by
   basename so a path-qualified shape still counts. That is the single most
   load-bearing sentence in this section. An earlier matrix accepted "some
   unlisted word", which let the extractor and the oracle be wrong together, and
   it had already happened: `xargs -P 4 cmd` returned `4`, which is unlisted, so
   the case passed while the rule was reading an option operand rather than the
   command. Under that oracle a green matrix proved less than it read as
   proving, and adding shapes to it would not have helped.

   The reject matrix names each shape a new dependency can take: plain,
   `!`-negated, piped, path-qualified, inside a command substitution within a
   double-quoted string, as a `case` arm's command in every pattern form,
   literal, computed as `$pat)`, escaped as `\))` and extglob as `@(a|b))`,
   inside a brace group, after one or more `NAME=value` assignment prefixes,
   after a leading redirection both attached and spaced, after each keyword that
   introduces a command including `coproc`, and as the operand of every declared
   launcher in each of its option forms.

   **Launcher semantics are declared data rather than a rule of thumb.** Which
   options take an operand, and whether that operand is REQUIRED or OPTIONAL, are
   facts about each launcher, so the contract carries a launcher table beside the
   vocabulary: the token, its owner, the short option letters and the long option
   names, with a `?` marking an optional operand.

   Arity matters as much as the option list. `xargs -E eof-str cmd` consumes its
   operand and `xargs --eof cmd` consumes nothing, so a rule with one notion of
   operand swallows the command in the optional forms. Short options cluster, so
   the letters are walked rather than the word measured: `xargs -rP 4 cmd` has
   its operand-taking letter at the end of the cluster, while `-n1` carries its
   operand attached.

   `builtin` is deliberately absent from the launcher table, because
   `builtin NAME` runs a shell builtin by definition and can never reach an
   external. It appears in the BOUNDARY instead, because it can reach `eval`.
   That is not an inconsistency: a rule about host tools and a rule about
   interpreter facilities are different rules that happen to share a scanner.

   The option semantics are written once and shared by the launcher extraction
   and the boundary. Two copies of a rule drift apart while each looks right in
   isolation, and this effort has already been caught by that once.

   **The coupling runs in both directions.** A declared launcher must itself be
   permitted, and a permitted tool KNOWN to run its argument must be declared as
   a launcher. Without the second direction, adding `env` or `timeout` to the
   vocabulary would leave the rule blind to whatever it runs, and the harness
   would keep reporting zero.

   The allow matrix names each shape the rule must NOT claim, **one case per
   shape rather than one verdict over a file of them**. That is not a
   presentation choice. Widening the openers broke the rule in the other
   direction, and the aggregate form could not say which shape broke it: `{` in
   the opener class made every `${value}` read as a command, and a bare `)` made
   `$(basename x)suffix` read as a command called `suffix`. The matrix therefore
   carries `${value}`, `${HOME}/tools`, `$(basename x)suffix`, `$(dirname y).bak`,
   `arr=(one two three)`, `arr+=(four five)`, and the `${g:-default}` and
   `${i#prefix}` expansion forms, each as its own case.

   It also carries the NESTED closes, because a rule that removes one close per
   line passes the single-level shape and fails the double:
   `$(basename $(dirname x))suffix`, `$(basename $(dirname $(readlink y)))tail`,
   and a construct closing inside a substitution in each of its four forms,
   `esac)`, `fi)`, `done)` and `})`. Each of those was a false positive at some
   point in this rule's history, and the single-level case would not have caught
   any of them.

   And it carries the launcher forms the installer actually uses, so widening the
   rule to see launcher targets cannot start claiming their options:
   `$(command -v rsync)`, `$(echo a | xargs -0 -r sed -i -e s/a/b/)`, and a
   `case` whose pattern is an escaped paren inside a substitution.

   **The lexical boundary is fail-closed, not merely stated.** A command inside
   `eval "..."` is invisible, and so is a launcher whose target is an expansion,
   for the same reason a command reached through a variable is: the string is
   blanked before the openers run and no lexical rule reaches inside it. Saying
   so in prose was not enough, because a later step could add one and the gate
   would keep reporting zero.

   So the gate REFUSES a file containing any of those forms rather than answering
   for it, and ten boundary shapes prove the refusal fires while a literal-target
   case proves it is not indiscriminate. `eval` is also reachable through a
   DISPATCHER: `command eval "$p"` and `builtin eval "$p"` both run it, and
   neither puts `eval` where the command-word extraction looks. The installer
   uses none of these forms today, which is why the boundary is green rather than
   why it is absent.

   The contract must also not contradict itself, since a duplicated entry can
   answer `runs-argument` both ways while every other check still passes: no
   entry name and no launcher token may appear twice.

   **Every contract rule is exercised in both directions by a control.** Five
   controls mutate a copy of the real contract and require the rule to report;
   five require silence on the real one. A rule that has quietly stopped
   detecting anything passes a suite built only from clean inputs, and so does a
   rule that was never wired up: the round that first claimed these controls had
   not in fact written them, and every rule reported zero. Each control calls the
   same function the gate calls, so it cannot pass against a second copy the gate
   does not use.

   The dispatcher set is `command` and `builtin`, and both facts about it were
   measured. `builtin -- eval "$p"` runs eval, so flags and `--` are skipped
   before the command word is taken. `exec eval "$p"` does NOT run eval: exec
   replaces the shell with an external program of that name, there is none, and
   it exits 127.

   Over-reporting is not the safe direction. A rule that names `${HOME}` as a
   forbidden external command does not get tightened, it gets switched off.

   `)` is **not an opener at all**, and reaching that took three failed attempts
   worth recording, because each failure was a repair for the one before it.

   As a bare opener it read `$(basename x)suffix` as a command called `suffix`.
   Requiring a blank after it fixed that and made `a)cmd` invisible, which is
   valid Bash calling `cmd`, so the rule became fail-open. Deleting the first
   `)` on a hoisted substitution line fixed both at one level of nesting and
   broke at two: `$(basename $(dirname x))suffix` hoists to a line carrying two
   closes, and removing one leaves the other to open `suffix`.

   Counting closes was the wrong instinct, because the ambiguity is not about
   depth. `)` has two meanings and only one of them is a command position: the
   end of a `case` PATTERN. That meaning is recognised directly and rewritten to
   `;`, which is already an opener, so `)` needs no opener role and a close of
   any construct at any depth opens nothing by construction. Block terminators
   are excluded first, since `esac)`, `fi)`, `done)` and `})` end a construct
   inside a substitution rather than a pattern.

   **Keywords that introduce a command are transparent**, and the reason is a
   property of the tool rather than of the shell: `grep -o` yields
   non-overlapping matches, so an opener followed by a keyword consumed the
   keyword as its command word and left the real command with no opener of its
   own. `if true; then cmd; fi` reported `if then fi` and never `cmd`. That was
   the largest fail-open this rule has had, it existed from the rule's first
   version, and no case caught it because every reject shape had been written
   with the command in the first position after the opener.

   `{` opens a group only when a blank follows, and that one is **exact rather
   than narrowing**: `{` is a reserved word, a reserved word must be delimited,
   and `{ls; }` is a Bash syntax error rather than a call to `ls`.

   The obligations pull against each other, so the gate asserts them together
   rather than one at a time: `host-tool/unspaced-case-arm-is-seen` and
   `host-tool/substitution-close-is-not-an-opener`. A repair that satisfies one
   by giving up the other fails here rather than being written up as a trade.

## Ready-to-run command for v0.27.0 relocation-force-rpath

For step N:

```bash
shellcheck src/setups/env/bin/install_pkg.sh docs/v0.27.0/verify.relocation-rpath.sh \
  && bash docs/v0.27.0/verify.relocation-rpath.sh --step N
```

Run it, fix what it reports, run it again, until it reports the step objective.
Do not run individual cases by hand as a substitute: the walk order is what
makes a lint failure stop the run before a test result can be misread as
meaningful.

## Step 0 perf-gate pass

No time-bound `xfail` gate is planned, and the reason is worth recording rather
than leaving as an omission. The template's perf-gate exists for a model whose
runtime is the feature. Here the pass runs once per install, its duration is
already captured by the Step 0 baseline, and the design's IO clarification names
the only structural risk, a second walk of the tree, which is forbidden outright
rather than gated by a timing test. Each step records its walk duration against
the Step 0 baseline instead, which catches the same regression without a test
that would be measuring a host rather than a change.

## Implementation decisions for v0.27.0 relocation-force-rpath

The ten questions the plan review settled, consolidated from the rounds that
answered them. Each row is the decision, where the plan applies it, and what was
rejected with the reason. The narrative that produced each answer stays in the
open-questions section below; this table is what a reader needs before reading
the steps.

| Question | Decision | Where it applies | Alternatives rejected |
| --- | --- | --- | --- |
| Q01 | A new `docs/v0.27.0/verify.relocation-rpath.sh` with its own case scaffolding | Verification harness; every step's cases | Extending `verify.install-pkg.sh`, rejected because its shared-body marker declares everything below one line byte-identical to a consuming project's copy, so additions either split that file's identity or owe a cross-repo update on every change; extracting shared scaffolding into a third sourced file, rejected because it changes a completed item's harness whose output is already retained |
| Q02 | One file for the whole effort, measured at each step, with a split decided on a measured figure rather than an estimate | Line-budget checkpoints; Step 4 timing | Splitting the observer into a shipped sidecar now, rejected because the deployment contract is that `install_pkg.sh` runs alone from a bare account; a mandatory shrink target funded by extracting existing functions, rejected as a commitment made before any measurement exists |
| Q03 | Generate fixtures into the harness scratch from committed recipes, each validated by a semantic oracle independent of the observer | Step 1 fixture matrix; `readelf` and manifest oracles | Committing fixture bytes, rejected because a binary in the tree is reviewed by nobody; deriving fixtures by patching a real archive object, rejected as unreproducible; trusting the accepted cases to catch a shared error, rejected because generator and observer then agree while both are wrong; size-and-single-mutation validation, rejected as too weak to name a field |
| Q04 | Land behavior and its emission atomically, after a preparatory step that proves the property the bounding rests on | Step ordering; Steps 2 to 4 | Behavior first then report, and report first then behavior, both rejected for creating an observable intermediate state; splitting the report across steps, rejected for the same reason; one merged step, rejected because the diff stops being bounded |
| Q05 | One fixed global associative array, named once and shared by the observer, the classifier and the controlled tests | `CPLX_ELF_OBS`; Step 1 observer | Prefixed shell variables with an explicit reset, rejected because the clearing rule stops being one mechanism; one delimited string parsed by the classifier, rejected as a second grammar nobody validates |
| Q06 | Terminal `blocked` reached from exactly one state, inside one lifecycle, with a missing run kept distinguishable from a failed one | Step 6 acceptance; the capability gate | Leaving the acceptance incomplete until monitoring evidence exists, rejected because a step that cannot answer must say so distinctly; substituting a weaker signal such as the process starting, rejected as answering a cheaper question; treating every unavailability as the same outcome, rejected because target and monitoring gaps differ |
| Q07 | Create the main boundary, then guard it: move `usage` and `select_copy_engine` above it and return early when sourced | Step 0 seam; every harness call into production code | A test-only CLI flag, rejected as shipped code no deployment executes; copying the function text into the harness, rejected because the harness would then test a copy rather than the production function |
| Q08 | The formatter ships in `install_pkg.sh`; the sole retained-output reader lives in the harness | Step 3 report contract | Both ends in the installer, rejected as shipping code no deployment executes and growing the file this effort is watching; the reader in both places, rejected because two readers drift |
| Q09 | A literal `CPLX-ELF/1` contract corpus committed beside the harness, canonical and authoritative over both ends | Step 3 contract corpus; formatter and reader cases | The round-trip alone, rejected because it passes when both ends are wrong in the same way; shared constants sourced by both ends, rejected for the same reason; extracting the grammar from the design at run time, rejected as making a prose document executable; a corpus with no stated authority order, rejected because a disagreement then has no arbiter |
| Q10 | `failed` for the objects the pass would have written, cases 4, 5 and 6, with cases 1, 2, 3 and 7 keeping their case-defined dispositions | Empty computed search path; the rpath axis | `failed` for every walked ELF, rejected because an empty search path is not an observation of an object the pass would not have touched; a run-level skipped fault, rejected as losing the per-object reading; leaving it to the implementer, rejected because the plan must not defer a reporting rule |
