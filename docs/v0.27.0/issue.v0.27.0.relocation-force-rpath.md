# Relocate with RPATH so wheels resolve inside the prefix

- Type: issue
- Version: v0.27.0
- Slug: `relocation-force-rpath`
- Umbrella: [docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md](draft.v0.27.0.debian-agent-tools.md)
- Draft: [docs/v0.27.0/draft.v0.27.0.relocation-force-rpath.md](draft.v0.27.0.relocation-force-rpath.md)

## What Q26 blocks today

The relocation pass makes an unpacked archive self-contained by
rewriting two ELF values on disk: the program interpreter and the
library search path. The interpreter half works. The search-path half is
correct for the binaries it touches and silently incomplete for the rest
of the tree, and both halves of that incompleteness only show on a
foreign distribution.

Two distinct defects sit under the same Q identifier, and they are
distinct because the evidence for them arrived a year apart in the same
discovery.

- **The tag is the wrong kind.** `patchelf --set-rpath`, given without
  `--force-rpath`, writes `DT_RUNPATH`. Its documented default converts
  a classic `DT_RPATH` into the newer tag. A runpath is consulted only
  for the direct `DT_NEEDED` entries of the object that carries it: it
  is not inherited by that object's dependencies, and it does not apply
  to what the process later `dlopen`s. A classic `DT_RPATH` on the root
  object is consulted for every lookup in the chain. The consuming
  project met the difference concretely in `develop#15`: pikepdf's
  bundled `libqpdf` finds the `libjpeg` auditwheel grafted beside it
  only under RPATH semantics, and the CI interim broke it precisely by
  converting the wheel's own `DT_RPATH` into a runpath.
- **The pass skips most of what it ships.** `fix_elf_paths` rewrites an
  rpath only when the value already present points under `/home/`
  (line 404). A shipped library that carries no rpath of its own answers
  an empty string to `--print-rpath`, the empty string does not match
  that pattern, and the library is left as it is. `develop#24` measured
  the result over the eight directories the relocation puts on the
  rpath, plus the project venv: 110 of 388 inventoried ELFs are shipped
  libraries with no search path at all, 55 under the python root and 55
  under the git root, and none of them a wheel.

Whatever the loader cannot resolve from the deployed tree it takes from
the host `ld.so.cache`. On the RHEL 9.8 deployment servers that is
invisible, because their cache serves ABI-compatible copies. On the
Debian 12 CI agent it mixes glibc 2.36 objects into a glibc 2.34 process
and dies: `GLIBC_ABI_DT_RELR`, `GLIBC_2.36 not found`, the `develop#12`
and `develop#13` signatures. That asymmetry is why a defect this old
stayed invisible until the archive met a second distribution.

## CDC revision history for the relocation rpath

- Earlier CDC state (up to v0.26.0): the archive has one consumer, RHEL
  servers whose host libraries are compatible with the shipped ones.
  Re-anchoring the values that name the build account is enough for the
  tree to run, and
  [Packaging and relocation tools](../../wiki/reference/relocation-tools.md)
  specifies the ELF pass exactly that way: rewrite what still contains
  `/home/`.
- Newer CDC state (v0.27.0): the same archive must relocate onto a
  distribution whose libraries are not interchangeable with the shipped
  ones. Re-anchoring is no longer sufficient. Every ELF the archive
  ships must resolve inside the prefix, and the search path must reach
  the objects the process loads indirectly, which is what the manylinux
  wheels of the consuming project's venv do.
- The umbrella settles the direction as decision D3, resolved on
  evidence rather than preference: `patchelf --force-rpath` in the
  relocation pass, against keeping `DT_RUNPATH` and carrying an explicit
  `LD_LIBRARY_PATH` in CI and in the wrapper exec.

## Current behavior in v0.27.0

`fix_elf_paths` (line 362), called as step 6d on the mirrored tree
(line 611), after the text path fix and before the convenience-command
install:

1. It resolves patchelf through `find_patchelf` (line 301), which looks
   in `<prefix>/tools/bin`, then `~/tools/bin`, then `PATH`. When none
   answers, the whole pass is skipped with two warnings and a `return 0`
   (lines 370 to 374): the install still succeeds and there is no exit
   code for this pass.
2. It computes the new interpreter with `find_dynamic_linker` (line 316)
   and the new search path with `build_elf_rpath` (line 329). The latter
   walks `<prefix>/tools/python` first and then every other tool
   directory, collecting `root/usr/lib64`, `root/usr/lib`, `root/lib64`
   and `root/lib` for each, then `lib` and `lib64` under each version
   directory, deduplicated in order. On the measured archive that is the
   list of eight directories the probes inventory.
3. It walks the tree with `find "$root_path/." ... -type f -size +4c`
   (line 423), pruning `.git` and `__pycache__`, and keeps a file only
   when its first four bytes read `7f454c46`. Symlinks are not regular
   files and are not followed, so each real ELF is visited once.
4. For each kept file, it reads the current rpath with `--print-rpath`
   and calls `--set-rpath "$new_rpath"` only when that value matches
   `*/home/*` (lines 402 to 411).
5. It does the same for the interpreter, with the extra condition that
   the value actually differs (lines 413 to 422).
6. It reports one count covering both kinds of rewrite: `Fixed <n> ELF
   interpreter/rpath value(s)` (line 425). The measured archive answers
   404.

## Current side effects in v0.27.0 for the incomplete ELF pass

- Every rewritten object gets `DT_RUNPATH`, so the deployed tree has no
  root object whose search path governs the process. The python ELF
  resolves its own needs and nothing else.
- The venv wheels are outside the pass entirely, since they are not part
  of the archive. Under `DT_RUNPATH` nothing gives them the deployed
  directories, which is why the consuming project appends one directory
  to each wheel by hand, with `--replace-needed` onto `libc.so.6` and a
  `--force-rpath` append, marked `Q26 INTERIM, REMOVE` in its pipeline.
- The 110 shipped libraries with no rpath resolve host-side whenever
  they are the root object of a lookup. `libstdc++.so.6.0.29` is the
  representative case: probed alone it takes host `libm`, `libc` and
  `libgcc_s`, although `libgcc_s` does ship, as
  `root/lib64/libgcc_s-11-20240719.so.1` under both roots.
- The archive's own contract probe cannot be made blocking while that is
  true. The consuming project runs it as informative, against a
  `develop#24` baseline of 110 flagged out of 388.
- The probe also reports eight missing version nodes, the
  `OPENSSL_3.x` set demanded by the root's libssl 3.5.1 and served only
  by its sibling libcrypto, under both roots. Those are reported while
  libssl is listed as a root object, where no rpath applies and the host
  libcrypto answers, and `import ssl` passes on every run.
- On RHEL nothing of this shows. The host cache serves compatible
  copies, so the incomplete pass produces a working tree and the defect
  has no production symptom to point at.
- The documentation describes the current state accurately, which means
  it becomes wrong the moment the pass changes:
  [Packaging and relocation tools](../../wiki/reference/relocation-tools.md)
  states the guard as "`patchelf` only rewrites values still containing
  `/home/`", and
  [Why binaries remember the build home](../../wiki/explanation/why-binaries-remember-the-build-home.md)
  presents the rpath as `DT_RPATH` throughout without recording that the
  install-time rewrite converts it.

## CDC wording and gap analysis for the ELF pass

The CDC now asks for a deployed tree in which every shipped ELF, and
everything the process loads through one, resolves inside the prefix on
either supported distribution. Five concrete gaps separate that from the
current pass.

- **Wrong tag kind.** `--set-rpath` alone yields `DT_RUNPATH`, whose
  scope is the carrying object's direct needs. Nothing in the deployed
  tree therefore governs an indirect or `dlopen`ed lookup.
- **Guard excludes the objects that need it most.** The `*/home/*`
  test selects objects that already had a builder-anchored search path,
  which is exactly the set that does not need help. A library shipped
  with no rpath, or with a distribution rpath naming `/usr/lib64`, is
  skipped.
- **No idempotence rule that survives the widening.** The current guard
  doubles as the idempotence rule: after one pass the value no longer
  names the builder, so a re-run is a no-op. A pass that must give an
  rpath to objects that never had one loses that property and needs an
  explicit replacement, since re-running the installer is documented as
  safe and `--force` reinstalls over a deployed tree.
- **No verification of the result.** The pass reports how many values it
  rewrote, not whether the tree resolves. The count is the only signal,
  and it counts interpreter and rpath rewrites together.
- **Scope is undefined for objects the archive did not build.** The
  deployed tree also holds RPM-extracted programs and libraries under
  `root/usr/bin` and `root/usr/lib64`, and the vendored patchelf itself.
  Today the `/home/` guard leaves all of them alone, and that exclusion
  is deliberate: the comment at line 400 says the pass leaves
  system-linked binaries alone. Widening the pass has to say what it now
  does with them instead of inheriting the answer from a guard that no
  longer applies.

Two consequences of forcing `DT_RPATH` are behavior changes rather than
gaps, and they land on the RHEL side where nothing is broken today.

- **Precedence over `LD_LIBRARY_PATH` inverts.** `DT_RPATH` is consulted
  before `LD_LIBRARY_PATH`, `DT_RUNPATH` after it. The deployed tree
  therefore stops being overridable by an operator's environment, which
  is more hermetic and is also a loss of an escape hatch. The wiki
  already states the rule for the build-time rpath; after this change it
  describes the deployed tree too. The `setenv` export that item 3 of
  the collection deals with becomes ineffective against the shipped
  directories, which is the intended direction but must be recorded.
- **The RHEL preload may enter the shipped search path.** Those servers
  inject `/lib64/liboneagentproc.so` into every process through the
  system preload. Documented loader precedence says a root-object
  `DT_RPATH` is consulted for lookups made further down the chain, which
  would move that host-built library's own dependencies from the system
  copies onto the shipped ones. Whether it actually moves depends on the
  dynamic tags the preloaded object carries for itself, which nobody has
  read, so this is stated as a hypothesis and not as a consequence. It is
  the one place where the change could regress a working production path,
  it is the only claim in this issue that no run has tested, and it is
  measurable on a deployment target.

## Confirmed rule for `relocation-force-rpath`

- Decision D3 is settled on `patchelf --force-rpath` in the relocation
  pass. The alternative, keeping `DT_RUNPATH` and carrying an explicit
  `LD_LIBRARY_PATH` in CI and in the wrapper exec, is rejected: it
  pushes the search list into the environment, so every entry point (the
  Jenkins stages, the python wrapper exec, an operator shell) has to
  carry it, and item 3 of this collection exists because an exported
  `LD_LIBRARY_PATH` is actively dangerous in the wrong process.
- The pass writes `DT_RPATH` on every ELF whose rpath it rewrites. The
  interpreter half is untouched, and an object may therefore have its
  interpreter rewritten without its rpath being in scope.
- The selector is **additive**: it adds a library population to what the
  pass already rewrites, and it never removes a program the current guard
  covers. This is the load-bearing property of the whole issue. The
  python ELF is a program, it is the root object whose `DT_RPATH` governs
  every lookup of the process, and D3 exists precisely to convert it, so
  a library-only selector would delete the mechanism while appearing to
  widen it.
- The selector is an **ordered classifier**, not a set of predicates that
  happen not to overlap. The order is what makes the outcome
  deterministic, and it is required rather than tidy, because
  `INSTALL_PREFIX` defaults to `$HOME` (line 40) and the how-to
  explicitly supports re-running against a prefix that itself lives under
  `/home`. In that supported shape the deployed search path is
  `/home/<user>/tools/...`, so the target value **contains** `/home/`
  and the broad builder-anchored test matches objects that are already
  relocated. Two overlaps follow, and both are resolved by precedence:
  - a v0.26.0-relocated program holds the exact target value under
    `DT_RUNPATH` and also satisfies the `/home/` test, so it would match
    both the migration and the fresh branch;
  - a program relocated by this version holds the exact target value
    under `DT_RPATH` and also satisfies the `/home/` test, so it would
    match both the fresh branch and the skip rule.
  Each walked ELF takes the first case below that applies, and no other:
  1. **rpath failed.** A required rpath-classification observation failed
     or was inconclusive, so the object receives `rpath failed` and no
     later rpath case may be assigned. This is axis-specific fail-closed
     routing rather than a predicate to be tested before inspection: an
     unreadable header or a patchelf probe that errored makes the later
     benign cases unavailable, instead of letting the object fall into
     one of them.
  2. **not dynamically linked.** patchelf reports no dynamic section, so
     there is no search path to set.
  3. **already correct.** It carries the exact target value under
     `DT_RPATH`. This precedes every rewriting case, which is what makes
     a re-run under `$HOME` report zero rewrites instead of rewriting the
     same value again.
  4. **Library population.** It is a dynamically linked `ET_DYN` object
     carrying no `PT_INTERP` program header. That is how the loader
     itself tells a shared object from a position-independent
     executable: both are `ET_DYN`, and only the executable names an
     interpreter. Neither the `.so` suffix nor a SONAME is part of the
     test, since the archive carries versioned real files such as
     `libgcc_s-11-20240719.so.1` and `libstdc++.so.6.0.29`.
  5. **Migration-program population.** It is a program whose
     `DT_RUNPATH` holds the exact target value. Placing it before the
     fresh branch is what makes a v0.26.0-relocated prefix under `$HOME`
     classify as a migration rather than as a fresh relocation. The
     promise is bounded to what it can recognize: it migrates a prefix
     relocated by **v0.26.0**, because this issue leaves
     `build_elf_rpath` unchanged and therefore computes the identical
     list. A later change to that list would make the old value stop
     matching silently, so that change must define and validate
     recognition of its own predecessor value rather than inherit this
     exact-current-value test.
  6. **Fresh-program population.** It is a program whose rpath is still
     builder-anchored under `/home/` and which none of the cases above
     claimed. This is the current guard, preserved, and it is what
     converts the python and git executables on a relocation of a freshly
     unpacked archive.
  7. **excluded.** Nothing above applies.
- Cases 4, 5 and 6 rewrite; cases 1, 2, 3 and 7 do not. Every other
  program's **rpath** is left untouched exactly as today, RPM-extracted
  programs included. That is a statement about rpath selection only: the
  interpreter guard is unchanged by this issue and may still rewrite the
  `PT_INTERP` of a program whose rpath the classifier excludes.
- The ordering changes no scope decision. The set of rpaths rewritten is
  the same one round 3 settled; what the order adds is a single defined
  outcome per object under the `$HOME` layout, so population identity,
  the per-population interpreter reasoning, the migration count and the
  idempotence rule all read off the same classification.
- That selector is stated per class, so nothing is decided by accident:
  - RPM-extracted libraries under `root/usr/lib64` and `root/lib64` are
    covered by the library population. They are the 110 the probe
    flagged, and excluding them would leave the measured defect in place.
    "Shipped by the archive" is what makes them in scope; being built by
    a distribution rather than by cplx does not put them out of it.
  - Python extension modules under `lib-dynload`, including the
    `_sqlite3` extension item 6 of the collection will add, are covered
    by the library population.
  - The python ELF and the git executables reach case 6 on a fresh
    archive, case 5 on a v0.26.0-relocated prefix, and case 3 on any run
    after this issue lands. Under a prefix outside `/home` those three
    are distinguishable without the ordering; under the default `$HOME`
    prefix only the ordering separates them.
  - An RPM-extracted program with a distribution rpath reaches case 7, so
    its rpath stays untouched, which is the exclusion the current guard
    achieves by side effect and this classifier states by rule. Its
    interpreter remains whatever the unchanged interpreter guard does
    with it.
  - The vendored patchelf running the pass reaches case 7: it is a
    program, it carries no builder-anchored rpath, and it holds no target
    value. Its rpath is excluded by rule rather than by a name check.
  - An object patchelf reports as having no dynamic section reaches case
    2, never case 1.
- The classifier is validated against the `develop#24` inventory before
  it is trusted: it must select all 110 flagged libraries, and it must
  select the python ELF, which is the object D3 turns on.
- Idempotence is a condition on the tag and the value together, and case
  3 is where it lives. An object is already correct only when it carries
  `DT_RPATH`, not `DT_RUNPATH`, and its value equals the target list
  exactly; the classifier tests that before any rewriting case, which is
  what makes a second run under `$HOME` report zero rewrites rather than
  rewriting the same value through the builder-anchored branch. A
  matching string sitting under `DT_RUNPATH` is the exact state this
  issue exists to replace: on a library it is rewritten by case 4, and on
  a program it is what case 5 exists to catch.
- The selector must be evaluable with what the installer already
  depends on: the shipped patchelf and the audited mandatory host tools,
  which include `head` and `od` and do not include `readelf`. If an
  implementation cannot decide a population without a new host program,
  that program is added to the host-tool contract of
  [Packaging and relocation tools](../../wiki/reference/relocation-tools.md)
  with availability evidence on Debian 12 and RHEL 9.8, through an
  amendment to this requirement. It may not arrive silently in design or
  in code.
- The search path written is the one `build_elf_rpath` already computes.
  This issue does not change which directories are on it, and does not
  introduce `$ORIGIN`-relative entries: the deployed prefix is known at
  install time, and the current absolute form is what the probes
  inventory.
- `readelf -d` is a necessary check and not a sufficient one. The
  acceptance is a re-probe of the relocated tree, read as two
  independent readings, the static listing over the whole rpath and a
  live trace of a real venv process.
- Both readings must be conclusive before either counts. `develop#20`
  answered "no host library loaded" for a run that had looked at
  nothing, while the same run's listing had `pymupdf` and `pikepdf`
  resolving `libgcc_s` host-side. A trace must therefore report how many
  trace files it wrote and kept, and must trace the venv python
  directly, one process rather than uv plus its child. An empty trace
  reads as inconclusive, never as clean.
- The static listing must cover the whole rpath, not one directory.
  `develop#19` listed `root/usr/lib64` alone and concluded `libgcc_s`
  was missing from the archive; `develop#24` listed all eight and found
  it shipping under both roots. Two readings of the umbrella were wrong
  on that point, and the listing scope is what made them wrong.
- The search list is one value for the whole tree, python's directories
  first, and the archive's guarantee is that a demanded library resolves
  inside the prefix. It is not a guarantee that a library resolves within
  its own tool tree. Where the archive carries a duplicated family, one
  copy per tree, the acceptance records the exact provider path that
  answered, and a cross-tree provider is evidence handed to item 4 rather
  than a result silently read as coherent.
- The eight `OPENSSL_3.x` nodes are a verdict this issue owes and not a
  defect it fixes. Re-probe them once every shipped library carries a
  search path, and name the libcrypto that answered each libssl. Three
  outcomes close this issue and they are not equivalent: the nodes gone
  with a same-tree provider closes the question outright; the nodes
  satisfied by the other tree's libcrypto, and the nodes surviving, both
  close this issue while handing item 4 a named defect.
- The interpreter invariant is stated per population, because two of the
  three rewriting cases are programs and do have an interpreter:
  - a library (case 4) carries no `PT_INTERP`, so it cannot acquire a
    host-loader-plus-shipped-libraries mismatch;
  - a fresh program (case 6) keeps the existing interpreter rewrite
    unchanged, the two guards firing on the same object as they do today;
  - a migration program (case 5) is asserted, **after** classification
    and after the pass, to carry the shipped interpreter. It was
    relocated once already, so it should.
- That migration assertion is a post-classification check and never a
  classification filter. An object failing it keeps its rpath rewritten
  and is reported as a failed invariant: at install time a warning naming
  the object, and in its own reported count; in validation, a non-zero
  count blocks cplx acceptance. Excluding such an object instead would
  leave its target-valued `DT_RUNPATH` in place, which is precisely the
  state D3 exists to remove, so the wrong interpreter must be surfaced
  rather than used as a reason to skip the conversion.
- The assertion is reported as **two** figures, not one: the number of
  case 5 objects checked, and the number that failed. A failure count of
  zero on its own cannot be told from a branch that never ran, and a
  fresh relocation legitimately classifies nothing into case 5. So a
  fresh run may report zero checked, while the dedicated
  v0.26.0 migration run must report a checked count that is positive and
  equal to the number of objects it classified into case 5, with zero
  failures. That equality is what ties the assertion to the
  classification rather than to a separate walk.
- The RHEL side must be shown unchanged, on a deployment target rather
  than by argument. The preload hypothesis above is the specific thing to
  measure, and the measurement records the preloaded object, the
  `DT_RPATH` or `DT_RUNPATH` state it carries for itself, and the
  provider path of each of its dependencies before and after the change.
- The monitoring evidence is an exact observable, not a judgement. A
  process that merely starts is not the check. The requirement names one
  of three forms, each tied to the specific run rather than to the
  product in general:
  - a health or status query on the deployment target reporting the agent
    attached to the relocated process;
  - an agent-side log or event recording that attachment;
  - a written confirmation from the team owning the monitoring agent that
    it observed the agent attached to, and reporting for, the exact
    relocated process in the identified validation run. A general
    statement that the monitoring product supports this configuration
    does not satisfy this form.
  Whichever is used, the requirement records who produces it and the raw
  result, the confirmation itself included, is retained with the
  validation evidence. If none of the three can be obtained on a real
  target, this criterion is blocked and the issue says so, rather than
  letting a reader read process startup as health.
- The pass keeps its current failure behavior: patchelf absent stays a
  warning and a skipped pass rather than a fatal, and there is no new
  exit code. Widening the pass increases the number of objects patchelf
  rewrites, so a failure on an individual object must stay a warning
  that does not abort the install, as it is today (lines 408 and 418).
- Partial coverage must be legible at install time. The pass performs two
  independent operations on each object, and the report models them as
  two independent axes rather than one list of outcomes. A single
  partition is impossible: the rpath guard and the interpreter guard are
  separate conditions in the unchanged pass, so one object can be
  rewritten on both axes, on one, or on neither, and an interpreter
  rewrite can fail on its own.
  - **rpath disposition**, exactly one per walked ELF, and exactly the
    case the ordered classifier assigned: `failed`,
    `not dynamically linked`, `already correct`, `rewritten` (cases 4, 5
    and 6), or `excluded`.
  - **interpreter disposition**, exactly one per walked ELF, and each
    value earned by positive evidence rather than by falling through:
    - `rewritten`: the guard rewrote the interpreter;
    - `not applicable`: classification **successfully established** that
      the object carries no `PT_INTERP`;
    - `unchanged`: inspection **successfully found** a `PT_INTERP` and
      the unchanged guard performed no rewrite on it;
    - `failed`: neither state could be established, the inspection
      itself having failed.
    The distinction matters because an object with no interpreter and an
    object whose interpreter could not be read both fail the same
    condition in a naive implementation, and only one of them is benign.
    The evidence split is implementable within the tool boundary of the
    host-tool rule above: a successful `patchelf --print-interpreter`
    establishes a present `PT_INTERP` and supplies its value; failure of
    that command alone never establishes absence. `not applicable`
    requires the classifier's independent positive evidence that no
    `PT_INTERP` exists, and any inconclusive observation is
    `interpreter failed`.
  - **migration-interpreter invariant**, reported as two figures: the
    number of case 5 objects checked, and the number that failed.
  Each disposition axis sums to the number of walked ELFs, so a validator
  can reconcile the report to the walk twice over, and the two axes are
  read as a pair per object rather than as one label. A classification or
  inspection error, an unreadable header or a patchelf probe that fails,
  takes the `failed` disposition on the axis it blocked, and never
  `excluded`, `not dynamically linked`, `unchanged` or `not applicable`,
  so a malformed covered object cannot disappear into a benign
  disposition. The three pairs worth naming, because they are the ones a
  single partition could not express:
  - a fresh program is `rpath rewritten` **and** `interpreter rewritten`;
  - a program the classifier excludes, but whose interpreter still names
    the builder, is `rpath excluded` **and** `interpreter rewritten`;
  - an object patchelf refuses an rpath write on while its interpreter
    write succeeds is `rpath failed` **and** `interpreter rewritten`.
- The host-resolution gate is defined by path, not by judgement, and it
  fails closed. On Debian, every ELF dependency observed for a covered
  archive object and for the named venv process must be provided from the
  relocated prefix. The expected exceptions are named now and they are
  the kernel-supplied pseudo-objects that have no filesystem provider:
  `linux-vdso.so.1`, and the loader itself where it is reported by its
  pre-relocation name. Any other provider outside the prefix fails
  validation and blocks closure until its exact path and reason are added
  to this requirement through a reviewed amendment. A validator records
  evidence; it may not authorize a new exception, since an exception list
  a validator can extend is a gate that changes without the requirement
  changing. The term "ABI-critical library" is rejected as a gate: an
  undefined qualifier is how `develop#20` came to report a clean run that
  had observed nothing. The RHEL preload is not an exception to this
  rule, it is a separate measurement under the preceding one.

## Gap to close in the implementation for `relocation-force-rpath`

1. Add `--force-rpath` to the `--set-rpath` invocation at line 405, so
   every rewritten object carries `DT_RPATH`.
2. Extend the `*/home/*` rpath guard into the additive selector of the
   confirmed rule rather than replacing it. The existing
   builder-anchored branch stays exactly as it is, so the python and git
   executables keep being rewritten; a library branch is added, so a
   shipped library with no rpath or with a distribution rpath receives
   the deployed search path; and a migration branch is added, so a
   program whose `DT_RUNPATH` already holds the target value is converted
   on a v0.26.0-relocated prefix. Every other program's rpath stays
   untouched. Implement it as the ordered classifier of the confirmed
   rule, first matching case wins, with the exact-target tag and value
   tests placed **before** the broad `/home/` test. The order is required
   rather than tidy: `INSTALL_PREFIX` defaults to `$HOME` (line 40), so
   under the supported same-account layout the target value itself
   contains `/home/`, and without the precedence a v0.26.0 program would
   match both the migration and the fresh branch while a
   this-version program would match both the fresh branch and the skip
   rule.
3. Leave the interpreter guard at line 415 as it is. It continues to fire
   on the builder-anchored programs it fires on today, and a library has
   no `PT_INTERP` for it to reach. It is not restricted to the rpath
   selector: a program whose rpath no population selects may still have
   its interpreter rewritten, exactly as today.
4. Assert after classification that every case 5 object carries the
   shipped interpreter, and report the assertion as two figures, checked
   and failed. A failure warns at install time, is counted, and blocks
   cplx acceptance. It never turns the object into an exclusion, since
   leaving a target-valued `DT_RUNPATH` in place is the state D3 exists
   to remove.
5. Make the skip condition test the tag and the value together, as case 3
   of the classifier: skip only an object already carrying `DT_RPATH`
   whose value equals the target list. An object whose `DT_RUNPATH` holds
   that same string is rewritten, since converting the tag is the point,
   and on a program that object is case 5.
6. Verify idempotence by running the installer twice over the same
   prefix, which the how-to documents as safe, and once more with
   `--force`, including once with the default `$HOME` prefix. The second
   run reports zero rpath rewrites, the covered set having reached case
   3 rather than falling through to the builder-anchored branch.
7. Leave `build_elf_rpath`, `find_dynamic_linker` and `find_patchelf`
   unchanged, and keep the pass invoked at step 6d on `$DEST_PATH` after
   the text fix. Leaving `build_elf_rpath` alone is also what makes the
   migration branch work, since it is what keeps the computed list
   identical to the one v0.26.0 wrote.
8. Evaluate the selector with the shipped patchelf and the audited
   mandatory host tools only. `find_patchelf` already resolves the tool,
   the pass already calls `--print-rpath` and `--print-interpreter`, and
   the walk already reads a header with `head -c 4 | od`. Adding
   `readelf` or any other program to reach a decision requires amending
   the host-tool contract, with availability evidence on both targets.
9. Replace the single `Fixed <n> ELF interpreter/rpath value(s)` line,
   which counted 404 on the measured archive, with the two-axis report of
   the confirmed rule: one rpath disposition and one interpreter
   disposition per walked ELF, each interpreter value earned by positive
   evidence rather than by falling through a condition, plus the
   migration invariant as two figures, checked and failed. Each axis sums
   to the number of walked ELFs. A classification
   or inspection error takes the `failed` disposition on the axis it
   blocked, never a benign one.
10. Update
   [Packaging and relocation tools](../../wiki/reference/relocation-tools.md):
   the ELF fix row states the `/home/` guard as the rule, and it stops
   being the whole rule. Record the tag kind written, the three
   populations of the selector, the two reported dispositions, and what
   the pass deliberately does not touch.
11. Update
   [Why binaries remember the build home](../../wiki/explanation/why-binaries-remember-the-build-home.md):
   it presents the rpath as `DT_RPATH` and states that a `DT_RPATH`
   entry wins over `LD_LIBRARY_PATH`, without recording that the
   install-time rewrite converts the tag. After this change the
   statement holds for the deployed tree, which is worth saying rather
   than leaving implied, together with the part of the `setenv` export
   that stops having an effect on the shipped directories.
12. Update the check block of
   [Relocate an install to another prefix](../../wiki/how-to/relocate-an-install-to-another-prefix.md):
   `readelf -d "$BIN" | grep -E 'RPATH|RUNPATH'` currently accepts
   either tag, and the expected answer becomes `RPATH`. Add the
   library-side check, since the point of the change is that a shipped
   library, not only a program, now carries a search path.

## Concrete examples for the forced RPATH

- The python ELF, `<prefix>/tools/python/current/bin/python3.13_bin`,
  after relocating a fresh archive -> selected by the fresh-program
  population, since it is a program whose rpath still names the builder,
  and answering `RPATH` with the eight deployed directories where v0.26.0
  shows `RUNPATH`. It reports `rpath rewritten` **and**
  `interpreter rewritten`, which is the pair a single-label report could
  not express. This is the D3 case: it is the root object whose search
  path governs every dlopen of the process, and a selector that did not
  cover it would leave the wheels resolving host-side however many
  libraries it patched.
- The same python ELF on a prefix relocated by v0.26.0, so its
  `DT_RUNPATH` already holds the target value and nothing in it names the
  builder -> selected by the migration population, `rpath rewritten` and
  `interpreter unchanged`, since the earlier relocation already set the
  shipped interpreter. Without that branch it would match neither the old
  guard nor a library test, and the prefix could never be migrated.
- That same migration object, if it turned out **not** to carry the
  shipped interpreter -> still `rpath rewritten`, plus one on the failed
  figure of the migration invariant, a warning naming the object, and a
  blocked cplx acceptance. It is not reclassified as excluded, because
  leaving its target-valued `DT_RUNPATH` would be the D3 defect itself.
- The python ELF on a third run -> `rpath already correct`, since the
  value is the target one and the tag is `DT_RPATH`.
- The same three runs with the **default `$HOME` prefix**, where the
  deployed value is `/home/<user>/tools/...` and therefore matches the
  builder-anchored test as well -> the ordering decides, and it decides
  the same way: the fresh archive reaches case 6, the v0.26.0-relocated
  prefix reaches case 5 because the exact-target `DT_RUNPATH` test comes
  first, and the run after this issue reaches case 3 because the
  exact-target `DT_RPATH` test comes first. Without the ordering the
  first would be right by luck and the other two ambiguous.
- A v0.26.0-relocated `$HOME` prefix, without the ordering -> the python
  ELF matches both case 5 and case 6, so whether it counts as a migration
  or a fresh relocation, and therefore whether the invariant checks it at
  all, would depend on the order the implementation happened to test in.
- A this-version `$HOME` prefix re-run, without the ordering -> the
  python ELF matches both case 3 and case 6, so a second run could report
  a rewrite of the value it already holds, and the idempotence criterion
  would fail on a tree that is in fact correct.
- `<prefix>/tools/python/root/usr/lib64/libstdc++.so.6.0.29` -> selected
  by the library population, `rpath rewritten` and
  `interpreter not applicable`, where v0.26.0 shows neither tag.
- The shipped loader listing that library alone -> `libm`, `libc` and
  `libgcc_s` resolved inside the prefix, where the `develop#24` run
  resolved all three host-side.
- The same listing over the whole rpath plus the venv -> zero flagged
  ELFs, against the `develop#24` baseline of 110 out of 388.
- An RPM-extracted program under `root/usr/bin` carrying a distribution
  rpath -> matches no population, `rpath excluded`, and its rpath left
  exactly as v0.26.0 leaves it.
- A program whose rpath no population selects but whose interpreter still
  names the builder -> `rpath excluded` **and** `interpreter rewritten`.
  The interpreter guard is unchanged and is not bounded by the rpath
  selector, which is the second pair a single-label report could not
  express.
- The vendored `tools/patchelf/root/bin/patchelf`, the binary running the
  pass -> matches no population, since it is a program with no
  builder-anchored rpath and no target value, so its rpath is `excluded`
  by rule rather than by a name check.
- An RPM-extracted library in `root/usr/lib64` -> `rpath rewritten`,
  since shipped is what puts it in scope and built-elsewhere does not
  take it out.
- An object whose header cannot be read, or on which the rpath probe
  errors, while its interpreter write succeeds -> `rpath failed` **and**
  `interpreter rewritten`, the third pair. A `failed` disposition is
  never recorded as `excluded`, `not dynamically linked`, `unchanged` or
  `not applicable`.
- An object whose interpreter cannot be inspected at all ->
  `interpreter failed`, not `not applicable`. The benign value requires
  positive evidence that the object has no `PT_INTERP`, and an inspection
  that did not answer is not that evidence.
- A shipped library whose absence of `PT_INTERP` was established ->
  `interpreter not applicable`. A program whose `PT_INTERP` was read and
  which the unchanged guard did not rewrite -> `interpreter unchanged`.
- A fresh relocation -> the migration invariant reports zero checked and
  zero failed, which is correct rather than suspicious: nothing was
  classified into case 5.
- The dedicated v0.26.0 migration run -> the invariant reports a positive
  checked count equal to the number of objects classified into case 5,
  and zero failed. That equality is what proves the assertion ran over
  the classification rather than over some other set.
- Summing either disposition axis over a run -> the number of walked
  ELFs, so the report reconciles to the walk twice over.
- Debian 12 container, `uv sync` then `python -c 'import pymupdf,
  pikepdf'` with no patchelf pass on any wheel -> both import, pikepdf
  exercising the `libqpdf` to grafted `libjpeg` chain that `develop#15`
  broke under runpath semantics.
- `LD_DEBUG=libs,versions` on that same import, traced on the venv
  python directly -> every resolved dependency provided from the
  relocated prefix, and a trace inventory naming the files written and
  kept, so the silence is attributable to a process that ran.
- The eight `OPENSSL_3.x` lines on the root's libssl, re-read after the
  pass -> gone with each libssl naming the libcrypto beside it, which
  closes the question; gone with the git-tree libssl naming python's
  libcrypto, which closes this issue and hands item 4 a named cross-tree
  bind; or still reported, which closes this issue and hands item 4 a
  real pairing defect.
- A second run of the installer over the same prefix -> zero rpath
  rewrites over the covered set, and a `--force` reinstall behaving the
  same way.
- An object left carrying `DT_RUNPATH` whose value already equals the
  target list -> still rewritten, because the tag is what is wrong.
- `linux-vdso.so.1` appearing as a provider with no filesystem path ->
  a named expected exception, not a failure.
- Any other provider outside the prefix, say `/lib64/libz.so.1` ->
  validation fails and closure is blocked until that exact path and its
  reason are added to this requirement through a reviewed amendment. The
  validator records it; it does not authorize it.
- RHEL 9.8 deployment target, redeployment over an existing prefix ->
  the toolchain git and python answer as before, `import ssl, zlib`
  passes, the preloaded `liboneagentproc.so` has its own tag state and
  its dependency providers recorded before and after, and the named
  monitoring observable is produced by its named owner and retained.
- A monitoring answer reading "the agent supports relocated interpreters"
  -> does not satisfy the criterion, being about the product rather than
  about this run. The written-confirmation form requires the owning team
  to state that it observed the agent attached to, and reporting for,
  the exact relocated process in the identified validation run.
- Archive without `tools/bin/patchelf` on a host with none on `PATH` ->
  the pass is still skipped with its two warnings and the install still
  succeeds, unchanged from v0.26.0.

## Code references for `relocation-force-rpath`

- `src/setups/env/bin/install_pkg.sh` line 405: the
  `"$patchelf_bin" --set-rpath "$new_rpath" "$file_path"` call this
  issue changes, with its `warning` on failure at line 408.
- `src/setups/env/bin/install_pkg.sh` lines 400 to 404: the comment
  stating the guard's intent (idempotence, leave system-linked binaries
  alone) and the `[[ "$old_value" == */home/* ]]` test that implements
  it for the rpath.
- `src/setups/env/bin/install_pkg.sh` lines 413 to 422: the interpreter
  half of the pass, unchanged by this issue.
- `src/setups/env/bin/install_pkg.sh` line 329, `build_elf_rpath`: the
  eight-directory search path, python root first, deduplicated in order.
- `src/setups/env/bin/install_pkg.sh` line 423: the `find` that feeds
  the pass, pruning `.git` and `__pycache__`, keeping regular files over
  four bytes, not following symlinks.
- `src/setups/env/bin/install_pkg.sh` lines 301 to 314, `find_patchelf`:
  the lookup order and the absent-patchelf path that warns and returns.
- `src/setups/env/bin/install_pkg.sh` line 611: the step 6d call site.
- `src/setups/env/bin/install_pkg.sh` line 40: `INSTALL_PREFIX="$HOME"`,
  the default that makes the deployed search path contain `/home/` on the
  historical same-account layout, which is why the classifier must be
  ordered rather than a set of predicates assumed disjoint.
- `wiki/how-to/relocate-an-install-to-another-prefix.md` step 3: the
  promise that re-running is safe "even for a prefix that itself lives
  under `/home`", the supported shape the ordering has to survive.
- `wiki/reference/relocation-tools.md`: the ELF fix row naming the
  `/home/` guard, and the exit-code table, which gains nothing here.
- `wiki/explanation/why-binaries-remember-the-build-home.md`: the rpath
  presented as `DT_RPATH`, its precedence over `LD_LIBRARY_PATH`, and
  the layer-1 discussion of `--enable-new-dtags`.
- `wiki/how-to/relocate-an-install-to-another-prefix.md`: the check
  block accepting either tag.
- `docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md`: the `develop#19`
  to `develop#24` probe readings this issue's acceptance is measured
  against.

## Acceptance for `relocation-force-rpath`

The two columns below divide **ownership and claims**, not object sets.
The object sets deliberately overlap: the 110 archive libraries whose
selection cplx proves are inside the 388-object inventory the consuming
project sweeps, and that shared baseline is the point of contact between
the two columns rather than a duplication to remove. What must not be
shared is the claim. cplx proves selector membership, tag and value,
reporting, and resolution of archive objects. The consuming project
proves the full 388-object zero, the venv imports, the live trace and the
probe flip. Neither column may be quoted as evidence for the other's
claim.

The retained recipe may reuse a prepared prefix or snapshot across
observations when the required starting state remains explicit; these
criteria name distinct states and claims, not a mandatory
one-job-per-bullet topology.

Closable in cplx, from a relocated prefix and a retained recipe whose
output is kept as validation evidence rather than reduced to a verdict:

- Every ELF whose rpath the pass rewrote carries `DT_RPATH`, verified
  with `readelf -d`. An object whose interpreter alone was rewritten is
  not covered by this criterion.
- The python ELF carries `DT_RPATH` after the pass, from a fresh archive
  and from a prefix previously relocated by v0.26.0 alike. This is the
  first criterion to check, because it is the object D3 turns on and the
  one a library-only selector would silently leave behind.
- The selector is shown to select all 110 objects the `develop#24`
  listing flagged, plus the python and git executables, and to leave
  every other program's rpath untouched. The claim is about rpath
  selection: an untouched program may still have had its interpreter
  rewritten by the unchanged guard.
- A shipped library that carried no rpath carries one after the pass,
  with `libstdc++.so.6.0.29` as the named case, and the shipped loader
  lists it resolving `libm`, `libc` and `libgcc_s` inside the prefix
  when probed alone.
- The pass reports one rpath disposition and one interpreter disposition
  per walked ELF; each axis sums to the number of walked ELFs; and both
  failure dispositions, `rpath failed` and `interpreter failed`, are
  zero. A benign disposition never stands in for a failure, and
  `interpreter not applicable` and `interpreter unchanged` are recorded
  only on positive evidence, an established absence of `PT_INTERP` and an
  observed one respectively.
- Idempotence holds on tag and value: a second run and a `--force`
  reinstall report zero rpath rewrites and account for the covered set as
  `rpath already correct`, and an object whose `DT_RUNPATH` already held
  the target string was converted on the first run rather than skipped.
- The three `$HOME` cases are run, since the default prefix is where the
  ordering earns its place: a first relocation into `$HOME` classifies
  the python ELF as a fresh program; a `$HOME` prefix relocated by
  v0.26.0 classifies it as a migration rather than as a fresh
  relocation; and the next run over that prefix classifies it as already
  correct with zero rpath rewrites.
- The migration invariant reports two figures. On the dedicated
  v0.26.0 migration run the checked count is positive and equal to the
  number of objects classified into case 5 on that run, and the failed
  count is zero. A fresh run may legitimately report zero checked; it is
  the dedicated run that proves the assertion was exercised rather than
  merely not violated.
- The migration branch is exercised against a prefix relocated by
  v0.26.0, which is the predecessor this issue can recognize, since
  leaving `build_elf_rpath` unchanged is what makes the stored value
  match.
- The eight `OPENSSL_3.x` nodes are re-read after the pass and the
  verdict names the libcrypto that answered each libssl. A same-tree
  provider closes the question; a cross-tree provider or a surviving node
  closes this issue and is handed to item 4 as a named defect.
- The selector was evaluated with the shipped patchelf and the audited
  mandatory host tools, with no host program added. If one was needed,
  the host-tool contract carries it with Debian 12 and RHEL 9.8
  availability evidence, added by amendment rather than in passing.
- On a RHEL 9.8 deployment target, a redeployment behaves as before: the
  toolchain git and python answer, `import ssl, zlib` passes, and the
  preload measurement records `liboneagentproc.so`, its own
  `DT_RPATH` or `DT_RUNPATH` state, and the provider path of each of its
  dependencies before and after.
- The named monitoring observable is produced by its named owner and its
  raw result retained, the confirmation text itself included where that
  is the form used. A written confirmation counts only when it states
  that the agent was observed attached to, and reporting for, the exact
  relocated process in the identified validation run; a statement about
  what the monitoring product supports in general does not. If none of
  the three named forms can be obtained on a real target, this criterion
  is recorded as blocked rather than satisfied by a process that started.
- With patchelf absent the pass is still skipped with a warning and the
  install still succeeds.
- The three wiki pages describe the pass as it now behaves.

Tracked downstream, not closable here:

- The consuming project re-runs its contract probe over the exact
  `develop#24` inventory and reports zero flagged of 388. If a refreshed
  inventory flags a program, or otherwise invalidates the measured scope,
  this issue cannot close: the writer amends the scope or the target
  through a new reviewed specification round and validation is rerun. A
  validator may not choose between amending and excluding on its own, and
  an exclusion never satisfies the gate.
- On a Debian 12 container, `uv sync` then `python -c 'import pymupdf,
  pikepdf'` succeeds in the project venv with no patchelf pass on any
  wheel, and the live trace taken on the venv python directly shows every
  resolved dependency provided from the relocated prefix, with any
  exception listed by exact path and reason, read from a trace whose
  inventory proves it observed a process.
- It deletes its `Q26 INTERIM, REMOVE` venv patchelf loop, with its
  `--replace-needed` and its per-wheel `--force-rpath` append, once its
  pipeline runs an installer carrying this fix.
- It flips its walk-stage ABI contract probe from informative to
  blocking, with an expected flag count of zero.

## Out of scope for this issue

- Shipping any library into the archive, pruning superseded generations,
  and the packaging-time closure check. Those are sub-tasks 1 and 2 of
  work item 3, and they belong to item 4 of the collection,
  `toolchain-runtime-closure`.
- The C++ generation decision D10, which item 4 carries.
- Changing which directories `build_elf_rpath` produces, or moving to
  `$ORIGIN`-relative entries.
- Any new exit code for the ELF step. The interpreter half of the pass is
  not reopened either: it keeps its current guard, and this issue only
  adds a post-pass check that a migration program carries the shipped
  interpreter.
- Widening the **rpath** selector to programs that carry neither a
  builder-anchored rpath nor the target value, RPM-extracted programs
  among them. Their interpreter is not in scope either way, being left to
  the unchanged guard, which may still rewrite it.
- Recognizing a predecessor value other than the one v0.26.0 wrote. The
  migration branch matches the list `build_elf_rpath` computes today,
  which this issue does not change; a later change to that list owes its
  own migration rule and its own validation.
- The python wrapper's handling of `LD_LIBRARY_PATH`, which is item 3 of
  the collection, `python-wrapper-foreign-distro`. This issue only
  records that a forced `DT_RPATH` changes the precedence that wrapper
  operates under.
- The copy engines of `install_pkg.sh`, settled by item 1. This issue
  shares the file and nothing else.

## Requirement clarifications for `relocation-force-rpath`

Settled across five specification review rounds on 2026-08-16, recorded in
[the review transcript](review.issue.v0.27.0.relocation-force-rpath.md).
Two of those rounds repaired defects the writer had introduced while
applying an earlier correction, and both are recorded in the rows below
rather than smoothed over: a library-only selector that would have left
the python ELF unconverted, and a single-label report that could not
describe two independent guards.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | The rpath selector is an additive **ordered classifier**, first match wins, over seven cases: rpath-classification failure; not dynamically linked; exact target under `DT_RPATH`; library (`ET_DYN` with no `PT_INTERP`); program with the exact target under `DT_RUNPATH` (migration, bounded to a v0.26.0-relocated prefix); remaining builder-anchored program (fresh); otherwise excluded. Cases 4, 5 and 6 rewrite. The order is required, not tidy: `INSTALL_PREFIX` defaults to `$HOME`, so the target value itself contains `/home/` and the exact-target tests must precede the broad builder-anchored test | Confirmed rule (ordered classifier, per-class list); Gap item 2; Concrete examples (`$HOME` block and its two negative cases); Acceptance (selector membership, `$HOME` cases) | Covering every ELF with the running patchelf excluded by name, rejected because it rewrites RPM-extracted programs' rpaths with no observed defect and because a name check is fragile across the three patchelf lookup paths; unordered predicates with pairwise mutual exclusions, rejected because each predicate then restates the others negatively, which is an order written three times and drifts; a library-only selector, rejected because it leaves the python ELF unconverted and so contradicts D3 while passing every library-side criterion |
| Q02 | One shared search list, python's directories first, applied to every rewritten object. The archive guarantees that a demanded library resolves inside the prefix, not that it resolves within its own tool tree. Wherever the archive carries a duplicated family the acceptance records the exact provider path, and a cross-tree provider is evidence handed to item 4 | Confirmed rule (shared search list); Acceptance (`OPENSSL_3.x` verdict) | Tree-local preference with the other tree as fallback, rejected because it needs a per-object value, reaches beyond D3, and alters a working production path for a hazard no run has produced; requiring one copy of each duplicated library, rejected because pruning is item 4's work and would make this issue unclosable against the published archive |
| Q03 | The interpreter invariant is stated per case: a library has no `PT_INTERP`; a fresh program keeps the existing rewrite; a migration program is asserted **after** classification to carry the shipped interpreter. A failure warns, counts, and blocks cplx acceptance, and never reclassifies the object | Confirmed rule (interpreter invariant, post-classification assertion); Gap items 3 and 4; Concrete examples (failed invariant); Acceptance (migration invariant) | Rewriting the interpreter on every object the classifier rewrites, rejected as a far larger RHEL behavior change than the rpath and beyond D3; excluding a migration candidate whose interpreter is wrong, rejected because it leaves the target-valued `DT_RUNPATH` in place, so the cautious-looking rule is the only one that preserves the defect D3 removes, and it reports the anomaly as a benign exclusion |
| Q04 | The acceptance divides **ownership and claims**, not object sets. The object sets overlap by design, the 110 archive libraries cplx examines being inside the 388 the downstream probe sweeps, and that shared baseline is named as the point of contact. cplx owns classifier membership, tag and value, the reported dispositions and archive-object resolution, proved by a retained recipe; the consuming project owns the 388-object zero, the venv imports, the live trace and the probe flip | Acceptance (preamble, both columns) | Requiring the downstream evidence before closing, rejected because it couples this item to another repository and to an archive that stays 9.13.4 until item 7, inverting the umbrella's ordering; building a probe tool in cplx, rejected because a second probe disagreeing with the first creates a reconciliation problem, the ground on which item 1 rejected a shipped comparator |
| Q05 | A measured observation on a real RHEL deployment target is a gating criterion. The trace records the preloaded object, its own tag state, and each dependency's provider path before and after. The health evidence is one of three named forms, each tied to the run, with the producer named and the raw result retained; a general statement of product support does not qualify. If none can be obtained the criterion is recorded as blocked | Confirmed rule (RHEL measurement, monitoring evidence); Concrete examples (RHEL run, the answer that does not qualify); Acceptance (preload measurement, monitoring observable) | Relying on the existing RHEL rows, rejected because a successful import proves the process started while a silently degraded agent passes every listed check; treating the preload as outside the archive's contract, rejected because the umbrella already records it as a real constraint on how far the shipped glibc may drift |
| Q06 | The loss of the `LD_LIBRARY_PATH` override is intended and no escape hatch is restored, and the documentation audit that follows is part of the same decision: the wiki records the new precedence for the deployed tree and the now-ineffective part of the `setenv` export is written down. Documentation only; `setenv`'s implementation belongs to item 3 | Gap analysis (precedence inversion); Gap items 10 and 11 | Recording the loss in the requirement alone, rejected because it leaves the archive shipping a wiki page and a script that contradict the loader; leaving `DT_RUNPATH` where propagation is not needed, rejected because a tree with two tag kinds is harder to reason about than either uniform choice and the hatch would close exactly where it would be used |
| Q07 | The report models two independent operations as two independent axes plus one invariant: an rpath disposition (the case the classifier assigned) and an interpreter disposition, each value earned by positive evidence, plus the migration invariant as two figures, checked and failed. Each axis sums to the walked-ELF count. A classification or inspection error takes `failed` on the axis it blocked | Confirmed rule (reporting schema); Gap item 9; Concrete examples (the three pairs, evidence cases, reconciliation); Acceptance (dispositions, invariant) | Keeping one mixed count, rejected because an incomplete tree is reported as a successful install; making a failure fatal, rejected because it adds an exit code for a failure mode never observed and lets one awkward object block a working deployment; a single label with enumerated composite states, rejected because the names multiply as the product of the axes and reconciliation becomes arithmetic on labels; benign interpreter values assigned by fall-through, rejected because an object whose interpreter cannot be read would be filed as one that has none, which is the failure the report exists to surface |
| Q08 | Idempotence is a condition on the tag **and** the value together, expressed as case 3 of the ordered classifier and tested before every rewriting case. An object is already correct only when it carries `DT_RPATH` and its value equals the target list exactly; a matching string under `DT_RUNPATH` is rewritten, by case 4 on a library and case 5 on a program | Confirmed rule (idempotence, case 3); Gap items 5 and 6; Concrete examples (third run, `$HOME` re-run); Acceptance (idempotence) | Defining idempotence on the value alone, rejected because it does not distinguish the tags and would skip every migration candidate, the current pass writing the target value under `DT_RUNPATH` on every object it touches; defining it on the bytes, rejected because it constrains patchelf's internals and still needs a skip condition |
| Q09 | The gate is a literal zero over the exact `develop#24` inventory of 388 objects, with a fail-closed reopening rule: changed evidence blocks closure until the writer amends the scope or the target through a new reviewed round and validation is rerun. A validator records the evidence and may not choose between amending and excluding | Acceptance (downstream column) | Zero over a self-selected covered set with exclusions enumerated, rejected because there is nothing to enumerate on the measured evidence, because it makes an exclusion an automatic way to satisfy the gate, and because it cannot support the blocking downstream probe this item unlocks; an "ABI-critical library" criterion, rejected as an undefined qualifier in a gate |
| Q10 | The `OPENSSL_3.x` verdict names the libcrypto provider for each libssl and has three outcomes: gone with a same-tree provider closes the question; gone with a cross-tree provider closes this issue and hands item 4 a named cross-tree bind; surviving closes this issue and hands item 4 a pairing defect | Confirmed rule (`OPENSSL_3.x` verdict); Concrete examples (three outcomes); Acceptance (verdict) | A two-outcome verdict, rejected because it cannot express the cross-tree case, which reads as "gone" while being a finding; refusing to close until the nodes are gone, rejected because the fix is packaging work this issue excludes and cannot be done against the published archive, and because it would invert the umbrella's order |
| Q11 | The host-resolution gate is positive and path-based, and fails closed. Every ELF dependency observed for a covered archive object and the named venv process must be provided from the relocated prefix; the expected exceptions are named now, `linux-vdso.so.1` and the loader under its pre-relocation name. Any other outside-prefix provider blocks closure until added by reviewed amendment; a validator records evidence and may not authorize an exception | Confirmed rule (host-resolution gate); Concrete examples (vdso, an outside provider); Acceptance (downstream trace) | Defining "ABI-critical" as an enumerated library list, rejected because anything absent from it is permitted from the host while the archive gains libraries over time, sqlite being next; delegating the definition to the downstream probe, rejected because the gate could then change without this requirement changing, contradicting the ownership split of Q04 |
| Q12 | The classifier must be evaluable with the shipped patchelf and the audited mandatory host tools, which include `head` and `od` and not `readelf`. A successful `patchelf --print-interpreter` establishes a present `PT_INTERP`; its failure alone never establishes absence. Any new host program requires an amendment to the host-tool contract with Debian 12 and RHEL 9.8 availability evidence | Confirmed rule (host-tool boundary, interpreter evidence); Gap item 8; Acceptance (host-tool criterion) | Adding `readelf` to the mandatory list now, rejected because it enlarges a bootstrap contract the agent image is validated against, before anyone has shown the existing tools insufficient; leaving the mechanism to design, rejected because the host-tool contract is a requirement-level promise item 1 established, so growth in it cannot be a design detail invisible until it fails on an agent image |
