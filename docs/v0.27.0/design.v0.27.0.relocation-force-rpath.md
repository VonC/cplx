# Design v0.27.0 -- Relocate with RPATH so wheels resolve inside the prefix

Reference issue: [issue.v0.27.0.relocation-force-rpath.md](issue.v0.27.0.relocation-force-rpath.md)

---

## Context for v0.27.0 relocation-force-rpath

The requirement settled twelve clarifications across five review rounds. It asks
for three things that the current `fix_elf_paths` pass cannot express: an
ordered classification of every walked ELF, a search-path tag that propagates
down the loading chain, and a report that describes two independent operations
without collapsing them into one number.

This design answers how those fit together inside one pass, and it settles one
question the requirement deliberately left at requirement level: where each
classification input comes from, given that the audited host-tool contract
carries `head` and `od` and does not carry `readelf`.

## Scope for v0.27.0 relocation-force-rpath

The v0.27.0 outcomes are:

1. Every shipped library, and every program the ordered classifier selects,
   carries `DT_RPATH` holding the deployed search path, so the python root
   object governs every lookup of the process.
2. Each walked ELF receives exactly one rpath outcome and exactly one
   interpreter outcome, each backed by an observation rather than by a
   fall-through, and each axis reconciles to the number of walked ELFs.
3. A prefix relocated by v0.26.0 migrates to the new tag without a reinstall,
   including under the default `$HOME` prefix where the deployed value itself
   contains `/home/`.

Everything else is either supporting design context for those outcomes or
explicitly deferred.

### In scope for v0.27.0 relocation-force-rpath

- The ordered classifier, its inputs, and where each input is observed.
- The two-axis outcome model, its vocabulary, and its reconciliation property.
- The post-classification migration-interpreter assertion and its two figures.
- The evidence boundary: which observations the shipped patchelf can supply and
  which must come from reading the ELF header directly.
- The validation architecture: the states a recipe must reach, which of them may
  share a prepared prefix, and the split between cplx-owned and downstream-owned
  claims.
- The three documentation surfaces that stop being accurate when the pass
  changes.

### Deferred from v0.27.0 relocation-force-rpath to later items and beyond

- Shipping, pruning or pairing libraries in the archive, which is item 4 of the
  collection.
- Changing which directories `build_elf_rpath` produces, and any move to
  `$ORIGIN`-relative entries.
- Recognizing a predecessor search-path value other than the one v0.26.0 wrote.
- Any new exit code for the ELF step, and any change to what `setenv` does.

---

## Confirmed Technical Facts for v0.27.0 relocation-force-rpath

These facts were confirmed by inspecting `src/setups/env/bin/install_pkg.sh` and
the wiki before writing this design.

**The pass already walks and filters ELFs.** `fix_elf_paths` (line 362) walks
`$DEST_PATH` with `find ... -type f -size +4c` (line 423), pruning `.git` and
`__pycache__`, and keeps a file only when its first four bytes read `7f454c46`,
read with `head -c 4 | od -An -tx1` (line 397). Symlinks are not regular files
and are not followed, so each real ELF is visited once. The walk and the filter
need no change; what changes is the decision taken per kept file.

**The pass makes exactly four patchelf calls per object today.**
`--print-rpath` (line 403), `--set-rpath` (line 405), `--print-interpreter`
(line 414) and `--set-interpreter` (line 416). `find_patchelf` (line 301)
resolves the binary from `<prefix>/tools/bin`, then `~/tools/bin`, then `PATH`,
and a missing patchelf skips the whole pass with a warning and `return 0`
(lines 370 to 374).

**The search path is one value computed once.** `build_elf_rpath` (line 329)
collects `root/usr/lib64`, `root/usr/lib`, `root/lib64` and `root/lib` per tool
directory, python first, then `lib` and `lib64` under each version directory,
deduplicated in order. `fix_elf_paths` computes it once (line 383) and applies
the same string to every object it rewrites.

**The installation prefix defaults to the operator home.**
`INSTALL_PREFIX="$HOME"` (line 40), and
[Relocate an install to another prefix](../../wiki/how-to/relocate-an-install-to-another-prefix.md)
promises re-running is safe "even for a prefix that itself lives under `/home`".
Under that layout the deployed value is `/home/<user>/tools/...`, so it matches
the current `*/home/*` guard. This is the fact that makes an unordered set of
predicates ambiguous.

**The two guards are independent and differently shaped.** The rpath guard tests
only `[[ "$old_value" == */home/* ]]` (line 404). The interpreter guard tests
that same anchor **and** that the value differs from the target (line 415). They
can therefore already fire on different objects, and the interpreter guard is
the only one of the two that is idempotent by construction.

**patchelf reports the search-path value, not the tag that holds it.**
`--print-rpath` prints the string whether it sits in `DT_RPATH` or
`DT_RUNPATH`, and the documented option set has no query that distinguishes
them. Every object the current pass has ever rewritten therefore looks identical
to a correctly converted one through that interface, which is exactly the pair
the requirement's case 3 and case 5 must tell apart.

**The audited host-tool contract carries `head` and `od`, not `readelf`.**
[Packaging and relocation tools](../../wiki/reference/relocation-tools.md)
records the mandatory list item 1 established, and a target image is validated
against it.

---

## Current Behavior for v0.27.0 relocation-force-rpath

Per kept file, the pass takes two independent decisions and increments one
shared counter:

```txt
for each ELF under <prefix>/tools:
    rpath:       print -> if value contains /home/ -> set (writes DT_RUNPATH)
    interpreter: print -> if value contains /home/ and differs -> set
    fixed += 1 per successful set, of either kind
report: "Fixed <n> ELF interpreter/rpath value(s)"     # 404 on the measured archive
```

Three consequences follow, and all three are what this design removes. An object
with no rpath is never selected, since an empty value cannot contain `/home/`.
Every rewritten object receives `DT_RUNPATH`, whose scope is the carrying
object's own needs. And the single counter cannot say which of the two
operations produced it, nor how many objects were passed over.

## Target Behavior for v0.27.0 relocation-force-rpath

Per kept file, one observation phase feeds one ordered classification, the two
axes are decided independently, and one assertion runs after classification:

```txt
for each ELF under <prefix>/tools:
    observe:   ELF header -> e_type, PT_INTERP present?, PT_DYNAMIC -> rpath tag
               patchelf   -> rpath value, interpreter value
    classify:  first matching case of 1..7            -> rpath disposition
    act:       cases 4,5,6 -> set-rpath --force-rpath (writes DT_RPATH)
               interpreter guard, unchanged           -> interpreter disposition
    assert:    case 5 objects -> shipped interpreter? -> checked, failed
report: one record per object, plus a trailer with one figure per rpath
        disposition, one per interpreter disposition, and the two migration
        figures; every figure reconciles against the records that carry it
```

The order of the classification is the load-bearing part. Under a prefix outside
`/home` the cases are separable without it; under the default `$HOME` prefix
they are not, because the deployed value satisfies the builder-anchored test as
well as the exact-target tests.

---

## Design Area 1 for v0.27.0 relocation-force-rpath: the observation phase

### The observation is a normalized tuple, not a set of shell variables

Every consumer downstream reads one value produced by one observer. The observer
answers, per walked ELF:

| Field | Domain | Source |
| --- | --- | --- |
| `structural_status` | `ok`, `inconclusive` | ELF identification, header and table bounds, the dynamic scan |
| `elf_kind` | `exec`, `dyn`, `unsupported` | `e_type`, 2 bytes at offset `0x10` |
| `has_dynamic` | yes, no | a `PT_DYNAMIC` program header |
| `has_interp` | yes, no | a `PT_INTERP` program header |
| `tag_state` | `none`, `rpath`, `runpath`, `ambiguous` | the dynamic entries |
| `rpath_probe_status` | `ok`, `skipped`, `blocked`, `failed` | `patchelf --print-rpath` |
| `rpath_value` | string, absent | the same probe |
| `interp_probe_status` | `ok`, `skipped`, `blocked`, `failed` | `patchelf --print-interpreter` |
| `interp_value` | string, absent | the same probe |

This tuple is an **internal named-field contract**, not a wire format. The
classifier reads these fields, the classifier tests supply them directly at that
callable boundary, and the observer-fixture tests assert them. It is never
serialized: the `CPLX-ELF/1` stream of Design Area 3 is post-classification
evidence and carries dispositions rather than observations. How the shell
carries the fields is a plan question, not a design one.

### One structural status, two probe statuses, because the faults differ

A single verdict over the whole observation cannot express the fault matrix this
design also states. That matrix requires a failed `--print-rpath` to leave the
interpreter answer standing, a failed `--print-interpreter` to leave the rpath
case standing, and an ambiguous tag to fail only rpath. Those are partial
outcomes, and one status covering everything would make each of them fail both
axes. So the observation carries three statuses, and each field is usable only
when the status that produced it permits:

- `structural_status: inconclusive` invalidates the whole tuple, because
  `elf_kind`, `has_dynamic`, `has_interp` and `tag_state` all rest on the same
  read. That is the only fault that blocks both axes.
- `rpath_probe_status` and `interp_probe_status` are independent, and each value
  names a distinct thing that happened:
  - `ok`: the probe ran and answered, and its value is usable.
  - `skipped`: successful structure proved the probe inapplicable, `has_dynamic:
    no` for the rpath probe and `has_interp: no` for the interpreter probe.
    Those are its only two producers. Nothing else may set it, so `skipped`
    always means "we know this object has nothing to read" rather than "we did
    not look".
  - `blocked`: the structural observation failed before applicability could be
    established, so the probe never ran and its inapplicability was never
    proved either.
  - `failed`: the probe ran and did not answer. It blocks only its own axis.

The structural-failure tuple is fully defined rather than left as "the other
fields are not touched". On `structural_status: inconclusive` every other field
is cleared: `elf_kind`, `has_dynamic`, `has_interp` and `tag_state` carry no
value, both probe statuses are `blocked`, and both probe values are absent. That
matters in a shell loop, where "not touched" is how a previous object's reading
survives into the next iteration and is read as this object's evidence.

`blocked` and the clearing rule are complementary rather than one guarantee
written twice, and both are kept deliberately. `blocked` is the observer's
reason, visible to every consumer that asks why a probe has no answer. Clearing
is the representation invariant that makes stale values impossible in the shell
carrier. Either alone leaves a gap: a status without clearing still permits a
previous object's value to be read from an unclear field, and clearing without
the status leaves a consumer unable to distinguish "there was nothing to read"
from "we never got to look".

`tag_state: ambiguous` is a **successful** structural observation, not an
inconclusive one. The reader established exactly what the object carries: both
`DT_RPATH` and `DT_RUNPATH`, or more than one of either. That successfully
observed state invalidates the rpath classification and leaves every interpreter
field intact, which is precisely the distinction a whole-tuple verdict would
have lost.

### The observation is eager; only the probes short-circuit

The structural read runs for every walked ELF, and there is no case in which it
can be skipped. `excluded` is case 7, the last one, so an object cannot be known
to be excluded until cases 1 to 6 have been evaluated against the same evidence
any other object needs; and the interpreter axis requires a positive `has_interp`
answer for every walked ELF whatever its rpath disposition turns out to be.
There is therefore no unusual payload object that can be recognized as harmless
early and spared the parse.

What may be skipped is a probe a completed observation has proved irrelevant:

- `has_dynamic` no means the dynamic scan and `--print-rpath` are not run, since
  there is no search path to read;
- `has_interp` no means `--print-interpreter` is not run, since there is no
  interpreter to read.

That is evidence-based short-circuiting, and it differs from lazy observation in
the way that matters: the decision to skip rests on an observation that
succeeded, never on a guess about where the object would have classified.

### The supported ELF domain, and everything outside it

The observer accepts exactly the archive's own contract: ELF64, little-endian,
`EM_X86_64`. Anything else, an ELF32 object, a big-endian one, another machine,
is outside the domain and yields `structural_status: inconclusive` rather than a
best-effort reading.

Inside the domain the observer validates before it trusts any field:

- the identification bytes: magic, class, data encoding and version;
- that the ELF header itself is present in full, since a file long enough to
  carry the four magic bytes the walk checks may still be shorter than the
  header the observer reads;
- `e_phnum` in its ordinary form. The extended count encoding, where `e_phnum`
  is `PN_XNUM` and the real count lives in the section header table, is outside
  the domain and is inconclusive rather than followed.

The remaining validations apply only when `e_phnum` is greater than zero:

- `e_phentsize` against the ELF64 program header size, and `e_phoff` plus
  `e_phnum` times `e_phentsize` against the file size;
- each program header's `p_offset` and `p_filesz` against the file size;
- the dynamic entry size, and that the entry list terminates on `DT_NULL`
  within `p_filesz`.

**A file with no program header table is valid and is accepted.** When `e_phnum`
is zero there is no table, so there is no entry whose size must equal the ELF64
program header size, and requiring it would reject a well-formed object. A
relocatable object legitimately has none. Such a file is observed successfully
as `has_dynamic: no`, `has_interp: no`, `tag_state: none`, with both probes
`skipped`, and the classifier then reaches case 2. It is an ordinary accepted
shape, not a rejection.

Any validation that does apply and fails sets `structural_status: inconclusive`,
and the observer then returns the cleared tuple described above, with both probe
statuses `blocked`.

The file size those bounds are checked against must itself come from the audited
host-tool contract, which carries neither `stat` nor `wc`. It comes from the walk
that is already running: GNU `find` emits each object's size beside its
NUL-delimited path, so the observer receives the size it needs without the pass
acquiring a tool the contract does not list. Any other source would need the
host-tool amendment the requirement describes.

### Reading the program header table once answers four questions

`e_type` gives the object kind, the presence of a `PT_INTERP` entry gives the
interpreter question, the presence of a `PT_DYNAMIC` entry gives the
not-dynamically-linked question, and following `PT_DYNAMIC` gives the tag state.
That is the design choice: **a single structured observation per object**,
rather than several independent probes whose answers could disagree.

### Why the tag cannot come from patchelf

This is the design's sharpest constraint and it is worth stating plainly.
`--print-rpath` returns the value for either tag, so it cannot separate case 3
from case 5: a prefix relocated by v0.26.0 and a prefix already converted by
this change return the same string. The requirement makes tag-and-value the
idempotence condition precisely because the tag is half the defect, so an
implementation that reads only the value cannot implement the requirement at
all.

Three ways out, and the design takes the first:

- **Read the tag from the dynamic section** with the already-mandatory `od`,
  using the header walk above. It keeps the host-tool contract intact, it
  answers the other three inputs in the same pass, and it is the only option
  that needs no amendment.
- **Add `readelf`** to the mandatory host-tool list. It is the direct tool, and
  it costs an amendment with availability evidence on both targets, for a
  contract the agent image is validated against.
- **Give up on distinguishing the tag** and always rewrite. Rejected by the
  requirement, since it makes case 3 unobservable, so a second run cannot report
  zero rewrites and idempotence has no evidence.

The cost of the first option is real and belongs in the design record: parsing a
program header table with `od` is more code than one `readelf` call, and it is
code that has to be right about offsets and bounds. The mitigating facts are
that the archive is x86-64 only, that the pass already reads a header with the
same tools, and that the domain and validation rules above make every input the
parser cannot honestly read an inconclusive one.

The 110-object happy path is not the parser's validation. Selecting the flagged
libraries proves the classifier over ordinary objects and says nothing about
what the reader does with a truncated table or an unsupported class, so the
parser is exercised against constructed fixtures as well as the real archive.

Every guard stated above gets at least one deterministic fixture, and the matrix
is guard-complete rather than illustrative:

| Class | Fixtures |
| --- | --- |
| accepted | ordinary `ET_EXEC`; PIE; shared library; no `PT_DYNAMIC`; dynamic with no search-path tag; `DT_RPATH` only; `DT_RUNPATH` only; **`e_phnum == 0`, no program header table at all** |
| ambiguous | both tags present; a duplicate of a single tag |
| domain | unsupported class (ELF32); unsupported byte order; unsupported machine; extended `e_phnum` |
| bounds | a file too short to hold the whole ELF header; `e_phentsize` disagreeing with the ELF64 program header size when `e_phnum` is nonzero; a program header table extending past the file; a program header whose offset and length extend past the file; a bad dynamic entry size |
| termination | a dynamic list that never reaches `DT_NULL` within `p_filesz` |

The zero-table fixture belongs in the accepted class, not the rejected one, and
it is there because an unconditional entry-size check would have put it in the
other: it is the fixture that proves a valid shape is not rejected. It does not
depend on the archive containing such an object, and it should not. A
deterministic fixture proves the reader implements a lawful shape; waiting for
the tree to happen to contain one would make the check a matter of luck.

Each fixture asserts the **internal named tuple fields** the observer produces,
which is the contract of Design Area 1, not a serialized form. Nothing in the
validation compares record-stream text against an expected observation, because
the stream carries dispositions rather than observations. How many bytes each
fixture is, and whether they are generated at validation time or carried in the
repository, is a plan question rather than a design one.

### Both tags at once is a defined state, and it fails closed

An object may legitimately carry `DT_RPATH` and `DT_RUNPATH` together, and the
loader ignores the former when the latter is present. patchelf resolves the
ambiguity the same way: `--print-rpath` returns the runpath value, so through
that interface the object presents as a clean case 5 candidate and the rpath it
also carries is invisible to the classifier.

`tag_state: ambiguous` therefore yields `rpath failed`, for two reasons and not
a third. The requirement defines no mixed-tag population, so a design that
converted such an object would be acting outside every case the requirement
settled. And the probe masks the state, so the classification would rest on
patchelf's preference rather than on what the object holds.

The third reason this design gave in round 2 was wrong and is withdrawn: it
claimed a forced conversion would leave the ignored tag behind. The upstream
change log records that `--force-rpath` deletes `DT_RUNPATH`, so the mutation is
not the silent half-conversion that argument assumed. The fail-closed outcome
stands on the two reasons above, which do not depend on it, and the shipped
binary's actual print and force behavior is measured during validation rather
than inferred from either the manual or this paragraph.

### Which fault blocks which axis

An observation that cannot answer its question is not permitted to produce a
benign classification. Which axis it blocks depends on what it was answering,
and the matrix below is the whole rule, so a shared fault and an axis-local one
are never confused:

| Fault | rpath axis | interpreter axis |
| --- | --- | --- |
| structural observation inconclusive (identification, bounds, domain) | `failed` | `failed` |
| dynamic scan or `--print-rpath` fails, header otherwise valid | `failed` | its own evidenced value |
| `tag_state: ambiguous` | `failed` | its own evidenced value |
| `--print-interpreter` fails while `has_interp` is yes | its own case | `failed` |
| the computed target search path is empty or unavailable | `failed` for each **selected** object, cases 4, 5 and 6, whose write cannot be formed; cases 1, 2, 3 and 7 keep their case-defined dispositions | its own evidenced value |
| `--set-rpath` fails on a selected object | `failed` | its own evidenced value |
| `--set-interpreter` fails | its own case | `failed` |

Two readings of that matrix matter. A structural failure blocks both because
both answers rested on it, and the two figures are then two views of one walk
rather than a deduplicated count of distinct faults. Everything below the first
row is axis-local: a write that fails on one axis never erases the other axis's
result, and a missing target search path stops the pass from writing any rpath
without preventing the interpreter guard from reaching its own evidenced
disposition on every object.

A third reading was added after the v0.27.0 plan review found the original
wording of the last row contradicting two other clauses. "`failed` for every
walked ELF" would have made a case 2 or case 7 object `failed` under a missing
search path, which the case-identity section forbids, since for cases 1, 2, 3 and
7 the case and the disposition always agree, and which the acceptance table
contradicts, calling `not dynamically linked` explicitly not a failure. The
missing input is **object-local**: it fails the objects whose write was due and
leaves the others as their cases fix them. The acceptance still fails through the
selected objects, so nothing is hidden by the narrower reading.

The benign values keep their positive-evidence rule throughout: a successful
`--print-interpreter` establishes a present interpreter and supplies its value,
its failure alone establishes nothing, and the absence of `PT_INTERP` is
established by the structural observation rather than inferred from a probe that
did not answer.

## Design Area 2 for v0.27.0 relocation-force-rpath: the ordered classifier

### The order is the contract

The seven cases are evaluated in order and the first match wins. Cases 4, 5 and
6 rewrite; cases 1, 2, 3 and 7 do not.

| Case | Condition | Disposition |
| --- | --- | --- |
| 1 | a required rpath observation failed or was inconclusive | `failed` |
| 2 | no `PT_DYNAMIC`, so no search path to set | `not dynamically linked` |
| 3 | `DT_RPATH` holding exactly the target value | `already correct` |
| 4 | `ET_DYN` with no `PT_INTERP` | `rewritten`, library |
| 5 | a program whose `DT_RUNPATH` holds exactly the target value | `rewritten`, migration |
| 6 | a remaining program whose search path contains `/home/` | `rewritten`, fresh |
| 7 | anything else | `excluded` |

Three orderings inside that list carry the weight. Case 3 before cases 4 to 6 is
what makes a second run report zero rewrites under `$HOME`, where the deployed
value would otherwise re-satisfy case 6 forever. Case 5 before case 6 is what
makes a v0.26.0 prefix classify as a migration rather than as a fresh
relocation, which in turn decides whether the interpreter assertion examines it.
And the loader rule below sits before case 3, so the one object the pass must
never write cannot report `already correct` either.

### The loader is excluded by identity, and why that is not a name check

Case 4 claims every `ET_DYN` with no `PT_INTERP`, and the shipped dynamic loader
is exactly that shape. It is also the file this pass installs as every program's
`PT_INTERP`. Giving it a search path destroys it, and destroying it kills every
program in the archive at exec.

This was measured on the RHEL 9.8 target, patchelf 0.19.1, glibc 2.34, on copies:

| Step | Result |
| --- | --- |
| the shipped loader, `--version` | exit 0 |
| `patchelf --force-rpath --set-rpath TARGET` on it | **exit 0**, 897856 to 905033 bytes |
| the same loader, `--version` | **exit 139, signal 11** |
| a program whose `PT_INTERP` names it | **exit 139, signal 11** |

The middle row is the dangerous one. patchelf reports success, so without a rule
the pass records `rewritten`, the trailer reconciles, and the report is a
faithful account of a tree that no longer runs. No amount of reconciliation can
show this, which is why validation grew a run-after assertion at the same time
as the classifier grew the rule.

The blast radius is one object and the rule is one exclusion, not a retreat from
case 4. The same write was applied to `libc.so.6`, `libm.so.6`, `libdl.so.2`,
`libpthread.so.0`, `libz.so.1` and `libstdc++.so.6`, together and then one at a
time, and a program ran through every set at exit 0. The acceptance table's own
case 4 exemplar, `libstdc++.so.6.0.29`, is therefore measured safe.

The rule is stated as **identity, not name**: the excluded object is the one
`find_dynamic_linker` answers with, whatever it is called. An object cannot be
given a search path by the mechanism it implements. A name check on
`ld-linux-*.so.*` would be the kind of test the case order exists to avoid, and
it would also be wrong in both directions, catching spare copies nothing execs
through and missing a loader shipped under another name.

Identity means device and inode, not string equality, and the archive is why.
`find_dynamic_linker` answers with its first existing candidate,
`root/lib64/ld-linux-x86-64.so.2`, which the archive ships as a **symlink** onto
`root/usr/lib64/ld-linux-x86-64.so.2`, while the walk yields real files and so
hands over the target. A string comparison never matches, and the rule would be
silently dead. The comparison costs two stats and no process.

The rule is **bounded to the object `PT_INTERP` will name**. Another copy of a
loader elsewhere in the tree stays in case 4 and is still rewritten: nothing
execs through it, and widening the rule to every file that looks like a loader
is the name check just refused. Whether a rewritten spare is acceptable in the
shipped archive is a question for the acceptance step, not for the classifier.

The rule adds no eighth case. It answers case 7, which is exactly the loader's
membership: selected by nothing. The vendored patchelf that runs the pass is
already there for the same reason.

### The classification is computed once and reused

Population identity is not re-derived anywhere. The interpreter assertion asks
"is this a case 5 object", the migration checked figure counts case 5
memberships, and the idempotence claim reads case 3 counts. One classification
per object, consulted by three consumers, is what keeps those three answers
consistent by construction rather than by three matching conditions kept in
step.

### The case is identity; the disposition is what happened

The two are separate values and must not be collapsed. The classifier assigns a
case from the observation, and that case is the object's population identity: it
does not change afterwards, whatever the pass then manages to do. The
disposition records the outcome of acting on it.

They differ exactly when a write fails. A case 5 object whose `--set-rpath`
fails is still a case 5 object, so the migration population still contains it
and the interpreter assertion still checks it; its rpath disposition is `failed`
rather than `rewritten`. Collapsing the two would shrink the migration checked
count whenever a write failed, which would make the count report fewer objects
examined precisely on the runs where something went wrong. Cases 1, 2, 3 and 7
have no write, so for them the case and the disposition always agree.

## Design Area 3 for v0.27.0 relocation-force-rpath: the two-axis outcome model

### Two axes because there are two guards

The rpath disposition and the interpreter disposition are decided
independently, because the two guards in the pass are independent and this
design keeps them so. An object may be rewritten on both axes, on one, or on
neither, and either write can fail alone. The vocabularies:

| Axis | Values |
| --- | --- |
| rpath | `failed`, `not dynamically linked`, `already correct`, `rewritten`, `excluded` |
| interpreter | `rewritten`, `failed`, `unchanged`, `not applicable` |

`unchanged` means a `PT_INTERP` was observed and the guard did not rewrite it.
`not applicable` means the header walk established that there is none. Neither
is reachable by a probe that simply failed.

### Reconciliation is the property the report exists for

Each axis accounts for every walked ELF. That gives a validator two independent
readings of the same walk, which no single mixed count can offer, and it is the
reason to prefer two axes over one vocabulary of composite names. The migration
assertion adds two figures beside the axes rather than inside them, checked and
failed, because it is a claim about a subset rather than an outcome of the walk.
How that accounting is checked, per category rather than by sum, is specified
with the record grammar below.

### The install stays non-fatal

Nothing in this model changes the failure contract. A per-object failure remains
a warning, a missing patchelf still skips the pass, and no exit code is added.
The change is that a partial result becomes legible at install time instead of
being averaged into one number, and that the cplx acceptance can assert zero on
both failure dispositions.

### The report has two readers, so it has two forms in one stream

An operator reads sentences; a retained validation recipe asserts on figures.
Both are served from the captured install output, and no file is written into a
deployment prefix for the purpose, so nothing acquires a lifecycle the design
would then have to settle.

The human form stays as it is today, `echos` lines through the existing helpers.
Beside them the pass emits a versioned structured record stream, in the same
captured output, whose grammar is fixed here rather than described:

```txt
CPLX-ELF/1 obj case=5 rpath=failed interp=unchanged path=6c69622f666f6f2e736f
CPLX-ELF/1 end state=completed reason=none walked=1 \
  r-rewritten=0 r-failed=1 r-already-correct=0 r-not-dynamic=0 r-excluded=0 \
  i-rewritten=0 i-failed=0 i-unchanged=1 i-not-applicable=0 \
  mig-checked=1 mig-failed=0
```

(the trailer is one physical line in emitted output; it is wrapped here for the
page.)

That is a complete capture of a one-object run, and it satisfies every rule
below: `walked` is the record count, each of the nine per-token counts matches
the single record, and `mig-checked` is one because the record carries `case=5`.
An example that did not would be the first thing an implementer copied.

- `CPLX-ELF/1` is the literal marker and its schema version. A recipe reading a
  marker it does not know rejects the capture rather than guessing.
- `obj` and `end` are the two record kinds. Every field after them is
  `name=value`, so the reader locates fields by name rather than by position.
  `/1` is **closed**: a record of each kind carries each of its listed fields
  exactly once and carries no others. A missing field, a repeated one and an
  unrecognized one are each rejected, and a later schema that needs another
  field uses a new marker rather than appearing inside `/1`. That is the same
  rule as rejecting an unknown marker, applied one level down, and it settles a
  question two readers would otherwise answer differently: given
  `rpath=failed rpath=rewritten`, a first-wins reader and a last-wins reader
  disagree about the run, and neither is wrong under a grammar that does not
  say.
- The values are **closed, space-free wire tokens**, deliberately distinct from
  the human labels used in prose:

| Axis | Wire tokens | Human labels used in this document |
| --- | --- | --- |
| `rpath` | `rewritten`, `failed`, `already-correct`, `not-dynamic`, `excluded` | rewritten, failed, already correct, not dynamically linked, excluded |
| `interp` | `rewritten`, `failed`, `unchanged`, `not-applicable` | rewritten, failed, unchanged, not applicable |

  The distinction is not cosmetic. Three of the settled dispositions contain
  spaces as prose, `not dynamically linked`, `already correct` and `not
  applicable`, so writing the human labels on the wire would make a record
  ambiguous immediately rather than after some future vocabulary change.

- `case` is the classifier case, an integer 1 to 7, the object's immutable
  population identity. `rpath` is what actually happened, so a case 5 object
  whose write failed reads `case=5 rpath=failed`, keeping it in the migration
  population while recording the outcome.
- `path` is the object's path relative to **the walked root**, `$DEST_PATH`,
  which is `$INSTALL_PREFIX/tools`. That base is chosen because it is what
  `fix_elf_paths` actually walks, so every path in the stream is relative to the
  one directory the pass was given; naming the installation prefix instead would
  add a constant `tools/` to every record and invite the disagreement this
  design already had, where the prose said one base and the example decoded
  under the other. The canonical form carries no leading `/` and no leading
  `./`, and is never empty.
  Its value is the **raw bytes** of that relative path written as lowercase
  hexadecimal, and therefore always of even length. Raw bytes, not UTF-8: a
  Linux pathname is a byte string that need not be valid UTF-8, and claiming
  otherwise would make the encoding untrue for exactly the filenames it exists
  to survive. The encoded form contains only `0` to `9` and `a` to `f`, so a
  space, a newline, a quote or an undecodable byte cannot break the parse. It is
  producible with the shell's own `printf` plus the already-audited `od` and
  `tr`, so it adds no host tool.
- `state` and `reason` are a closed pair. Exactly two pairings are valid,
  `state=completed reason=none` and `state=skipped reason=patchelf-absent`, and
  a reader rejects any other combination. A later cause of skipping owes a new
  reason token and a review rather than reusing an existing one. This pair is
  the correction that matters most in the trailer: a skipped pass and a
  completed walk of an empty tree both produce zero records and `walked=0`, so
  the totals alone cannot tell them apart.
- `walked` and the eleven counts are unsigned decimal. The five `r-` fields
  cover every rpath disposition, the four `i-` fields every interpreter
  disposition, and `mig-checked` and `mig-failed` the two migration figures.
  All eleven are always present, including when zero, so a reader never has to
  distinguish an absent field from a zero one.

### Reconciliation is categorical, not aggregate

The retained-output reader MUST reject a capture that violates any `/1` grammar
or reconciliation rule below; the formatter MUST emit captures satisfying the
same rules. The rules are an obligation on both ends, not a property the
formatter happens to produce and the reader hopes for.

An earlier form of this design required only that each axis's counts sum to
`walked` and that `walked` equal the number of `obj` records. Those are true of
a capture that misreports the run entirely: 388 object records all reading
`rpath=failed`, with a trailer claiming `r-rewritten=388 r-failed=0`, satisfies
both. The sums are right and every category is wrong, which is the one shape a
report exists to make impossible.

Reconciliation is therefore per category, and the trailer is evidence for what
the records say rather than a set of totals with the right sum:

- **Per token.** For each of the five `r-` fields and each of the four `i-`
  fields, the count equals the number of `obj` records carrying that token on
  that axis. Nine equalities, not two sums.
- **Walked.** `walked` equals the number of `obj` records.
- **Migration.** `mig-checked` equals the number of `obj` records with `case=5`,
  which is what makes the requirement's "checked equals case 5 membership" an
  invariant of the stream rather than a claim in prose. `mig-failed` is not
  greater than `mig-checked`. The dedicated predecessor run additionally
  requires `mig-checked` to be positive and `mig-failed` to be zero.
- **Skipped runs.** A `state=skipped` trailer carries no `obj` records and every
  numeric field is zero. A skipped pass that reported counts would be describing
  work it did not do.
- **Exactly one trailer per capture.** A capture with none is truncated; a
  capture with two is two runs concatenated. Either way the recipe knows not to
  assert on it.
- **The trailer terminates the capture.** `end` is positional as well as a
  kind: no record may follow it. A capture carrying `obj`, `end`, `obj` is a
  second run whose own trailer was lost, which is the truncated case above
  wearing the shape of a valid one. The count rule alone would admit it whenever
  the trailer figures happened to reconcile across all three records, so the
  position is what closes it structurally rather than by arithmetic coincidence.

  This CLARIFIES `/1` rather than redefining it, and the distinction matters
  because `/1` is frozen. The position was previously unstated rather than
  stated otherwise: no conforming consumer could have relied on a form the
  grammar never described, and nothing that already parses `/1` changes meaning.
  A resolution that reversed a stated meaning would owe a new marker and a new
  corpus instead of a rule added behind the old token.

## Design Area 4 for v0.27.0 relocation-force-rpath: migration and its bounds

### What the migration case recognizes

Case 5 matches a stored string against the value `build_elf_rpath` computes now.
That works for a prefix relocated by v0.26.0 for one reason only: this change
does not touch `build_elf_rpath`, so the two versions compute the same list.
The design records that as a dependency rather than a coincidence, because a
later change to the directory set would make the stored value stop matching
silently: such an object would fall to case 7 and be reported as excluded, which
is correct under the bounded contract and is the reason the contract is stated.

### The assertion sits after classification, never before

A case 5 object whose interpreter is not the shipped one still has its rpath
converted, and the anomaly is reported rather than used to skip the conversion.
Placing the check before classification would be the intuitive choice and the
wrong one: it would leave a target-valued `DT_RUNPATH` in place on the very
object the change exists to convert, and it would report that as a benign
exclusion. The failure is therefore a distinct figure, a warning naming the
object, and a blocked cplx acceptance.

## Design Area 5 for v0.27.0 relocation-force-rpath: validation architecture

### States, not jobs

The acceptance names starting states rather than isolated harnesses. Three of
them are transitions over the same prefix and may share one prepared tree, so
long as each starting state is explicit in the retained output:

| Starting state | What it exercises |
| --- | --- |
| fresh archive, prefix outside `/home` | cases 4 and 6, the ordinary path |
| fresh archive, prefix at `$HOME` | case 6 under the value that also matches case 3 and 5 conditions |
| v0.26.0-relocated prefix, at `$HOME` | case 5 and the migration assertion, checked positive |
| the same prefix, run again | case 3 and zero rewrites, then `--force` |
| RHEL deployment target | the preload measurement and the monitoring observable |

### Three layers, because there are three things that can be wrong

The requirement obliges the classifier to be shown to select a named set of
objects, and the design adds a binary reader in front of it. Those fail
differently, and a two-layer split leaves the reader's rejection rules
unexercised: controlled tuples bypass the observer entirely, and a real archive
is expected not to contain a truncated table or an unsupported class. So there
are three layers, and none substitutes for another:

| Layer | Input | Asserts on | What it proves |
| --- | --- | --- | --- |
| classifier over controlled tuples | named tuple fields supplied at the callable boundary | the assigned case | the ordering, including all seven cases, both `$HOME` overlaps, `tag_state: ambiguous`, an inconclusive structural status and each of the four probe statuses |
| observer over constructed ELF fixtures | deterministic byte-level fixtures | the named tuple fields the observer produces | the reader's acceptance and rejection rules, which the real archive will not exercise |
| observer plus classifier over a prepared archive | a real relocated prefix | the post-classification records | that both survive real objects, compared against the cplx-owned expected set |

The first two layers assert on the internal named tuple, never on serialized
text. Only the third consumes the `CPLX-ELF/1` stream, and it does so because
that stream is what a real run produces, not because the tuple has a wire form.

### A fourth check, over the stream contract itself

Those three layers prove the pass reaches the right decisions. None of them
proves the stream that reports those decisions is well formed, and the stream is
the only part of this design consumed outside the implementation, so a defect in
it is a defect in an external interface. It gets its own contract check over the
formatter and the retained-output reader:

| Covers | Cases |
| --- | --- |
| vocabularies | all nine wire tokens on their axes, and each one's mapping to the human label the prose uses |
| required fields | every listed field present exactly once on each record kind |
| categorical totals | each of the nine per-token equalities, `walked`, and `mig-checked` against the case 5 record count |
| rejected forms | an unknown marker; a missing, duplicate or unknown field; a token outside its axis vocabulary; a `path` that is not non-empty even-length lowercase hex; a `path` whose decoded value begins with `/` or `./`; an invalid `state`/`reason` pairing; a `state=skipped` trailer carrying an object record or a nonzero numeric field; a trailer whose categorical or migration totals disagree with the records; a capture with no trailer or two |

This is a contract sublayer of the same validation architecture rather than a
fifth semantic layer: it asserts nothing about which case an object belongs to,
only that what the pass writes and what the recipe reads agree. The parser
mechanics and the fixture bytes remain plan questions.

The observer-fixture layer is the one this design would most easily omit: its
whole subject is the states nobody wants a real archive to contain, so nothing
in ordinary use would notice its absence.

A recorded list of paths is not classifier input for any of the three. A path
carries none of the observation tuple, so replaying an inventory means
re-observing those objects, which is the third layer rather than the first.

### Two owners, overlapping objects, disjoint claims

The expected set cplx compares against is its own: the 110 flagged libraries
selected, the python and git programs selected, and every other archive program
left rpath-excluded. That is a claim about which objects the install pass
classifies, over the objects it walks.

The consuming project's 388-object zero is a different claim over a different
population. It is a resolution result, measured by its probe over the eight
rpath directories plus the venv, and it includes objects the install pass never
walks. It is not an install-classifier population and this design does not treat
it as one. The 110 archive libraries sit in both object sets by design; what
does not cross is the claim, and neither column is evidence for the other's.

## Design Area 6 for v0.27.0 relocation-force-rpath: documentation surfaces

Three pages describe the pass accurately today and stop doing so on the day it
changes: the ELF fix row and host-tool list in
[Packaging and relocation tools](../../wiki/reference/relocation-tools.md), the
rpath presentation and its precedence over `LD_LIBRARY_PATH` in
[Why binaries remember the build home](../../wiki/explanation/why-binaries-remember-the-build-home.md),
and the tag-agnostic check block in
[Relocate an install to another prefix](../../wiki/how-to/relocate-an-install-to-another-prefix.md).
The design treats them as part of the change rather than as follow-up, because
the archive would otherwise ship a loader behavior and a description of it that
disagree, including a `setenv` export that no longer affects the shipped
directories.

---

## Acceptance Cases for v0.27.0 relocation-force-rpath

| Scenario | Expected outcome | Reason |
| --- | --- | --- |
| `python3.13_bin`, fresh archive, prefix outside `/home` | `rpath rewritten` (case 6) and `interpreter rewritten` | both guards fire on the same object, the pair a single label could not express |
| `python3.13_bin`, fresh archive, prefix at `$HOME` | `rpath rewritten` (case 6) | the value contains `/home/` but holds no target value yet, so cases 3 and 5 do not match |
| `python3.13_bin`, `$HOME` prefix relocated by v0.26.0 | `rpath rewritten` (case 5), `interpreter unchanged`, checked incremented | case 5 precedes case 6, so the object is a migration rather than a fresh relocation |
| The same prefix, second run | `rpath already correct` (case 3), zero rewrites | case 3 precedes case 6, so the deployed value is not rewritten through the builder-anchored branch |
| `libstdc++.so.6.0.29` | `rpath rewritten` (case 4) and `interpreter not applicable` | `ET_DYN` with no `PT_INTERP`, established by the header walk; measured to survive the write |
| `ld-linux-x86-64.so.2`, the object `find_dynamic_linker` resolves | `rpath excluded` (case 7) and `interpreter not applicable`, and **the loader still executes after the pass** | it has case 4's shape and is the file every program's `PT_INTERP` names; the write succeeds and destroys it, so the account cannot be the only evidence |
| Another copy of a loader elsewhere in the tree | `rpath rewritten` (case 4) | the rule is identity, not name: nothing execs through a spare, and widening it to every loader-looking file is the name check the case order refuses |
| An RPM-extracted program under `root/usr/bin` | `rpath excluded` (case 7) | it is a program with neither a builder-anchored value nor a target value |
| The same program with a builder-anchored interpreter | `rpath excluded` and `interpreter rewritten` | the interpreter guard is unchanged and is not bounded by the rpath classifier |
| An object whose program header table does not parse | `rpath failed` (case 1) **and** `interpreter failed`, both probe statuses `blocked`, every other tuple field cleared | `structural_status: inconclusive`, the one fault that blocks both axes; clearing the fields is what stops a previous object's reading surviving into this one |
| An object with `e_phnum == 0`, no program header table | observed successfully, `has_dynamic: no`, `has_interp: no`, both probes `skipped`, reaching case 2 | a valid shape; the ELF64 entry-size check applies only when the count is nonzero, so requiring it unconditionally would reject a well-formed object |
| A file long enough for the four magic bytes but shorter than the ELF header | `structural_status: inconclusive` | the walk's filter reads four bytes, the observer reads more, so the header's presence is its own check |
| A case 5 object whose `--set-rpath` fails | classifier case 5, rpath disposition `failed`, still counted in the migration checked population | the case is population identity and does not change with the outcome of acting on it |
| A skipped pass versus a completed walk of an empty tree | two valid `/1` trailers, each carrying every required numeric field as zero, differing only in their state and reason | the run state distinguishes them, which zero records and zero counts cannot |
| A capture holding no trailer, or two | rejected as truncated or as two concatenated runs | exactly one trailer per capture is what makes the counts assertable |
| A trailer claiming `r-rewritten=388 r-failed=0` over 388 records that all read `rpath=failed` | rejected | categorical reconciliation compares each count with the records carrying that token, where an aggregate sum would accept it |
| A trailer with `mig-checked=0` over a capture containing `case=5` records | rejected | `mig-checked` equals the case 5 record count, so the requirement's equality is a stream invariant rather than prose |
| `state=skipped` with any nonzero count or any `obj` record | rejected | a skipped pass would be describing work it did not do |
| A record carrying `rpath=failed rpath=rewritten` | rejected | `/1` requires each field exactly once, so first-wins and last-wins readers cannot disagree about the run |
| A record carrying a field `/1` does not list | rejected | the schema is closed; a new field needs a new marker, as an unknown marker already does |
| `path` decoding to `lib/foo.so` | the object at `$DEST_PATH/lib/foo.so` | the base is the walked root, so no record carries a constant `tools/` and the prose and the examples agree |
| A path containing a space, a newline, or a byte that is not valid UTF-8 | recorded as the lowercase hexadecimal of its raw bytes | a Linux pathname is a byte string, so encoding raw bytes is what makes the claim true for the filenames the encoding exists to survive |
| A disposition written on the wire | the space-free token, `not-dynamic` rather than `not dynamically linked` | three settled dispositions contain spaces as prose, so the human labels would make a record ambiguous immediately |
| An object with no `PT_DYNAMIC` | `rpath not dynamically linked` (case 2) | there is no search path to set, which is not a failure |
| A case 5 object carrying a host interpreter | `rpath rewritten`, one invariant failure, acceptance blocked | excluding it would preserve the target-valued `DT_RUNPATH` the change exists to remove |
| A fresh run with no v0.26.0 objects | checked zero, failed zero | the branch legitimately did not run, which the checked figure makes visible |
| An ELF32 or big-endian object, or one with an extended `e_phnum` | `rpath failed` and `interpreter failed` | outside the supported domain, so no field of the tuple is trusted |
| A truncated program header table, or a dynamic list that never reaches `DT_NULL` | `rpath failed` and `interpreter failed` | the bounds and termination checks reject it before any field is used |
| An object carrying both `DT_RPATH` and `DT_RUNPATH` | `rpath failed` | `tag_state: ambiguous`, and patchelf's preference for `DT_RUNPATH` would otherwise decide the disposition instead of the object |
| A shared library whose `--print-rpath` errors, header valid | `rpath failed` and `interpreter not applicable` | an axis-local probe failure, so the interpreter answer stands on its own evidence |
| A program whose `--print-interpreter` errors while `has_interp` is yes | its own rpath case and `interpreter failed` | the converse axis-local failure |
| `build_elf_rpath` returning an empty search path | `rpath failed` for every object with a write due, cases 4, 5 and 6; cases 1, 2, 3 and 7 keep their case-defined dispositions; interpreter axis unaffected | a missing required rpath input, which does not stop the interpreter guard reaching its own evidenced disposition, and cannot make a write fail for an object that had none due |
| The pass skipped because patchelf is absent | trailer with a walked-ELF total of zero and no records | "did not run" stays distinguishable from "ran and found nothing" |
| The shipped patchelf, run in validation | its observed behavior recorded, not only its documented one | the tag-reading design rests on the documented interface, so the shipped binary is exercised rather than assumed |
| Comparing every disposition trailer field with the object records carrying its token | all nine equalities hold, `walked` equals the record count, and `mig-checked` equals the case 5 record count | categorical comparison makes the trailer evidence for what the records say, where a sum only proves arithmetic and a truncated or permuted capture would pass |

---

## Design decisions for v0.27.0 relocation-force-rpath

Settled across five design review rounds on 2026-08-16, recorded in
[the review transcript](review.design-specification.v0.27.0.relocation-force-rpath.md).
Three rounds repaired defects rather than refining wording, and the rows below
name them rather than smoothing them over: a lazy observation the ordered
classifier cannot support, a single observation status that contradicted this
design's own fault matrix, and a reconciliation rule that a misreporting capture
would have passed.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | The dynamic tag is read from the object with the already-mandatory `od`, since `patchelf --print-rpath` returns the value for either tag and has no tag-specific query. The observer emits a normalized **internal named tuple**, never serialized: one `structural_status`, plus `elf_kind`, `has_dynamic`, `has_interp`, `tag_state`, and a status and value per probe. Probe statuses are `ok`, `skipped` (structure proved it inapplicable, two producers only), `blocked` (structure failed first) and `failed` (ran without answering). On structural failure every other field is cleared and both probes are `blocked` | Design Area 1 (tuple, statuses, clearing rule); Design Area 5 (what the first two layers assert on) | Adding `readelf` by amendment, rejected because it enlarges a bootstrap contract the CI agent image is validated against before anyone showed the existing tools insufficient; installer-side state recording what this version converted, rejected because a v0.26.0-relocated prefix carries no such record, which is exactly the migration case; a tagged union instead of the clearing rule, rejected because shell has no such type so the guarantee reduces to the same discipline with a harder test boundary; a single whole-tuple status, rejected because it cannot express the partial outcomes the fault matrix requires |
| Q02 | The structural observation is **eager** for every walked ELF. Only probes short-circuit, and only on evidence: `has_dynamic: no` skips the dynamic scan and `--print-rpath`, `has_interp: no` skips `--print-interpreter` | Design Area 1 (eager observation); Target behavior sketch | Lazy per-case observation, rejected as not implementable: `excluded` is case 7 and is reached by elimination, so it costs every test above it, and the interpreter axis needs `has_interp` for every walked ELF regardless, so the saving does not exist; scoping the zero-failure gate to acted-on objects, rejected because deciding "would have acted on" after a failed observation needs the judgement the failure prevented |
| Q03 | A structural failure blocks both axes, with both probes `blocked`; every other fault is axis-local, per a seven-row dependency matrix; and the classifier case is immutable population identity, separate from the disposition, so a case 5 object whose write fails stays in the migration population | Design Area 1 (fault matrix); Design Area 2 (case versus disposition) | Failing only the rpath axis and recording `interpreter not applicable`, rejected because it asserts an absence nobody established, on the axis where it is hardest to notice; a fifth interpreter value for "not observed", rejected as redundant once `blocked` records that on the probe status, where the observation reports what it did |
| Q04 | The report is a versioned `CPLX-ELF/1` record stream in the captured install output beside the human `echos` lines, with a closed `name=value` grammar, space-free wire tokens distinct from the prose labels, raw-byte hex paths based on the walked root `$DEST_PATH`, a closed `state`/`reason` pair, and **categorical** reconciliation: nine per-token equalities, `walked` against the record count, `mig-checked` against the case 5 record count. `/1` is frozen: each field exactly once, missing, duplicate and unknown fields rejected | Design Area 3 (grammar, tokens, path, categorical reconciliation) | Human `echos` lines alone in a fixed phrasing, rejected because the phrasing becomes a contract nothing enforces; a machine-readable artifact under the deployment prefix, rejected because its lifecycle, atomicity and rerun behavior would all need settling and none was; recomputing the figures from the tree, rejected because it measures the tree rather than the pass, so a reporting defect stays invisible; positional space-separated fields, rejected because three settled dispositions contain spaces so records were ambiguous already; aggregate reconciliation, rejected because a capture of 388 `rpath=failed` records with a trailer claiming `r-rewritten=388` satisfies it |
| Q05 | Case 5 recognizes a predecessor by exact equality against the search path `build_elf_rpath` computes now, which works for a v0.26.0 prefix because this change leaves that function unchanged | Design Area 4 (what the migration case recognizes) | A maintained set of known predecessor values, rejected because it carries version history inside a script whose job is the present tree; a structural test matching any `DT_RUNPATH` entirely inside the prefix, rejected because it recognizes more than the requirement promises, so the design would claim more than the requirement and the two would drift |
| Q06 | Validation is three semantic layers plus a contract sublayer: the classifier over controlled tuples asserting the assigned case; the observer over constructed ELF fixtures asserting the named tuple fields; observer plus classifier over a prepared archive asserting the records against the cplx-owned expected set; and a report-contract check over the formatter and retained-output reader covering every wire token, required field, categorical equality and rejected form | Design Area 5 (three layers, contract sublayer) | Two layers without the observer fixtures, rejected because controlled tuples bypass the reader and a real archive is expected not to contain a truncated table or an unsupported class, so the rejection rules would be exercised by neither; integration only, rejected because it cannot reach the ambiguous tag or the `$HOME` overlaps; treating the consuming project's 388-object zero as the classifier's validation, rejected because it is a resolution result over a population including objects the install pass never walks; a bare recorded path list as classifier input, rejected because a path carries none of the tuple |
| Q07 | The ELF reader accepts exactly ELF64, little-endian, `EM_X86_64`. Identification and whole-header presence are validated unconditionally; `e_phentsize`, table and per-header bounds, dynamic entry size and `DT_NULL` termination only when `e_phnum` is nonzero, since a file with no program header table is lawful and is observed as no dynamic section, no interpreter, both probes skipped. `PN_XNUM` is outside the domain. A guard-complete fixture matrix covers every accepted and rejected shape, and file size comes from the GNU `find` walk already running | Design Area 1 (domain, validation chain, zero-table branch, fixture matrix) | A permissive reader falling back to the patchelf value when structure is unclear, rejected because the fallback cannot distinguish the tags, so cases 3 and 5 collapse on exactly the objects the reader was unsure about; a wider ELF domain handling ELF32 and both byte orders, rejected as code written against a hypothetical with paths no fixture exercises; obtaining file size with `stat` or `wc`, rejected because neither is in the audited host-tool list and using one would enlarge the contract without anyone deciding to; an unconditional `e_phentsize` check, rejected because it rejects a lawful zero-table object and reports it identically to a malformed one |
