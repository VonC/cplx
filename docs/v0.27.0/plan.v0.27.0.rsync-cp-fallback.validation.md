# v0.27.0 rsync-cp-fallback implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.rsync-cp-fallback.md](plan.v0.27.0.rsync-cp-fallback.md), six
steps that give `install_pkg.sh` a second copy engine without changing the rsync
path. Step 0 is complete, converged after four code review rounds and committed.
Step 1 is complete, converged after three code review rounds and committed. Step
2 is complete, converged after two code review rounds and committed. Step 3 is
implemented and passing on both supported targets: `install_pkg.sh` is now 622
lines, both transfer sites branch on the verdict, and both `rsync -av` invocations are
still byte-identical inside their branches. Steps 4 and 5 have not started.

> Skeleton note: every per-step section other than `Goal` and
> `improvement expectations` carries the literal placeholder
> `_(empty — no check has taken place yet.)_.` until an implementation check
> replaces it. Steps 0 to 3 are filled in; steps 4 and 5 are not.
>
> Markdown lint note: never leave a space immediately inside an inline code span
> (MD038) -- write a needed space as the token `[space]`, as in `` `[space]${x}` ``.
> The empty placeholder ends in `)_.` so the line is not pure italic text (MD036).

---

## How this validation departs from the standard template

The repository is Bash and Batch, with no Python package, no `pytest`, no
`tests/` tree and no coverage tooling, verified by inspection. Two template
sections are therefore replaced rather than filled in:

- **"Unit test coverage check" is replaced by "Harness case check"**. There are
  no unit-testable Python classes; the executable unit is a scratch-prefix case
  in `docs/v0.27.0/verify.install-pkg.sh`, and the question per step is which
  cases pass on which target.
- **"Performance check" is replaced by "Cost and timing check"**. The installer
  is a one-shot batch process with no hot loop. What matters is that no per-entry
  traversal was added, and that the FIFO refusal is prompt rather than blocking,
  which is the one measured timing obligation.

---

## Cost and IO clarification for v0.27.0 rsync-cp-fallback (implementation)

Carried forward from the plan:

- No per-entry traversal of the deployed tree is added; one `cp` per transfer
  site, not one per file.
- Constant work per destination, and no tree traversal: the mirror boundary
  observes one path, the deploy preflight observes one path per archive root
  file. The syscall count is not fixed here, since the shell construct is left
  to implementation.
- No entry counts, which the design rejected as evidence that proves nothing.
- The rsync transfer operation gains no filesystem call it did not already make.
  The run as a whole adds one path lookup for engine detection, on both engines.

---

## Equivalence comparison recipe for v0.27.0 rsync-cp-fallback

The design proves the two engines equivalent once and retains the output; it
ships no comparator. This is that recipe, recorded here so the check is
reproducible without a shipped tool.

Round 1 review asked for an executable recipe and round 2 rejected the result as
still descriptive: it left the formatter open with "or equivalent", named neither
the encoding nor the field separator, chose no digest utility, joined on
traversal order which nothing promises, and protected only the relative path
while leaving a symlink target able to forge a field. What follows is one
implementation, spelled out. No alternative is offered.

**Manifest emission**, as a harness function `emit_manifest <root> <out>`. The
whole function runs under `LC_ALL=C` and `TZ=UTC`, exported once at its top, so
no textual field depends on locale or zone.

1. Enumerate byte-safely, so no filename can forge a record:
   `find "$root" -mindepth 0 -printf '%P\0'`. The transfer root itself appears
   as the empty relative path.
2. Read each entry with `while IFS= read -r -d '' rel`, and emit exactly one
   line per entry, fields separated by a tab.
3. Encode both variable-length filename-bearing fields, the relative path and
   the symlink target, as lowercase hex, with a delete-complement that can only
   ever keep hex digits: `printf '%s' "$value" | od -An -v -tx1 | tr -dc '0-9a-f'`.
   Round 3 review caught the previous form, `tr -d '[space]\n'`, as a real
   defect rather than a typo: in `tr` that is a set containing brackets and the
   letters of the word, so it deleted the valid hex digits `a`, `c` and `e` and
   made the encoding neither reversible nor collision-safe. `-dc '0-9a-f'`
   cannot delete a hex digit by construction. The transfer root's empty path
   encodes to the empty string and is written as the literal token `ROOT`, which
   cannot collide with hex.
4. Determine the entry type with shell tests rather than a localized
   description, checking `-L` first so a symlink is never resolved:
   `l` for a symlink, then `d`, `f`, `p`, `S`, `b`, `c` for directory, regular
   file, FIFO, socket, block and character device, and `?` for anything else.
   This is one canonical character, locale-independent, and adds no process.
5. Emit the size only for a regular file, from `stat -c '%s'`, and the literal
   `-` for every other entry type, so directory and symlink sizes are never
   compared.
6. Emit the mtime at full filesystem precision with `stat -c '%.9Y'`, not whole
   seconds. Confirmed on the RHEL 9.8 target on 2026-08-11 and retained as
   `measurements.manifest-forms.rhel.txt`: coreutils 8.32 on xfs yields a
   fractional field, and the fraction varies across a short gap. The preflight
   still asserts it on each target and fails loudly rather than silently
   degrading to second resolution, since the Debian agent has not been probed.

   This field is measured, not argued, and the measurement is retained as
   `measurements.mtime-engines.rhel.txt`. An earlier version of this recipe
   claimed `rsync -a` transfers whole seconds only. That claim is **withdrawn as
   false**. On RHEL 9.8 with rsync 3.2.5, through the exact fresh forms this
   design specifies, both engines reproduce a source mtime of
   `1767319445.123456789` to the nanosecond: the mirror through
   `rsync -av --delete src/ dst/` and the fallback's empty-then-`cp -a src/. dst/`,
   and the root-file deploy through `rsync -av file prefix/` and
   `cp -a --remove-destination`. The manifest therefore keeps full precision and
   needs no carve-out, and the design's mtime decision stands untouched.

   What does exist is a different behaviour, and it is scoped rather than
   generalized. Against a destination file already present with the same size
   and the same integer second but a different fraction, rsync's default quick
   check (`--modify-window=0`) decides no transfer is needed and the destination
   keeps its own mtime. Measured: the destination stayed at
   `.987654321` where the source was `.123456789`. That is a skip decision on a
   populated destination, not truncation during transfer, and it does not touch
   this comparison, because the equivalence run installs into two fresh prefixes
   where nothing pre-exists and no quick check runs.

   It is recorded because it bounds a claim made elsewhere. "The two engines
   produce the same tree" is true of the fresh case this comparison measures. On
   a real redeployment over a populated prefix they are not interchangeable for
   entries that survive: rsync may skip what the fallback always rewrites, since
   the fallback empties first and cannot reach that state. This is standard,
   documented, unchanged rsync behaviour on the path the design deliberately
   leaves alone, so it is a scope note rather than a defect, and it does not
   reopen the design.
7. Emit the mode with `stat -c '%a'`, and the numeric owner and group with
   `stat -c '%u'` and `stat -c '%g'`. These may be read in the same `stat -c`
   call as the size and mtime; the fields are listed separately here only to fix
   their meaning.
8. Emit the digest for a regular file with a byte-exact extraction,
   `sha256sum -z -- "$root/$rel" | head -c 64`, which takes exactly the 64
   digest characters and is unaffected by the filename escaping GNU checksum
   tools apply to unusual names. For any other entry type, the literal `-`.
9. Emit the symlink target for a symlink by piping `readlink -n -- "$root/$rel"`
   directly into the encoder of item 3. The `-n` matters: without it `readlink`
   appends a newline the target does not contain, and capturing it in command
   substitution would instead strip every trailing newline the target does
   contain.
10. Field order, fixed: encoded path, type character, size, mode, mtime, uid,
    gid, digest, encoded symlink target.
11. Sort the whole file byte-stably: `LC_ALL=C sort -o "$out" "$out"`.

**Encoder control**, run with the other negative controls in Step 0: encode a
name whose hex representation contains the letters `a`, `c` and `e`, for example
`jln`, whose bytes encode to `6a6c6e`. Under the corrected encoder it survives
intact; under the round 3 defect it would have collapsed to `666`. This control
exists so that specific defect fails loudly rather than producing a plausible
manifest.

**Comparison**:

1. `emit_manifest "$prefix_rsync" manifest.rsync.txt` and
   `emit_manifest "$prefix_cp" manifest.cp.txt`.
2. `diff -u manifest.rsync.txt manifest.cp.txt > manifest.diff.txt`; an empty
   diff is the pass, and the diff is the evidence.
3. Retain all three files. The diff alone is not enough, since a reader cannot
   audit a comparison whose inputs are gone.

**What the manifest deliberately omits, and why**:

- Hard-link topology is not emitted, so it cannot appear in the diff. `cp -a`
  preserves hard links and `rsync -a` expands them, so emitting a link count
  would guarantee a false difference. This is an omission, not a normalization.
- ACLs, extended attributes and SELinux labels are not emitted. The exclusion
  rests on `rsync -a` never having promised them, and the inspected deployment
  directory does carry an extended ACL, so their presence is expected.
- Ownership is emitted as numeric uid and gid, not normalized away. Both runs use
  the same installing account, so the fields must match. If a validation ever
  runs them under different accounts, replace both uid and gid with a constant in
  both manifests before the diff, and say so in the retained output.

**Canary assertions**, run separately from the diff so they cannot be lost in
it: `libgcc_s.so.1` is still a symlink whose target is
`libgcc_s-11-20240719.so.1`, and every directory named on the toolchain rpath
still has the nature it had under rsync, real directory or link.

**Cost note**: this spawns `stat`, `od`, `sha256sum` and `readlink` per entry,
which is slow on a full toolchain tree. It runs twice, once, at acceptance, so
the cost is accepted rather than optimized.

---

## Step 0. Verification harness, calibrated oracles and baseline capture

### Analysis of Step 0 implementation state

Yes. Step 0 has been fully implemented.

This section has also said yes three times before and been wrong each time, which
is worth recording rather than tidying away: a harness whose own contract has
holes reports green while proving less than it claims, and reading it does not
reveal that. Three review rounds found twelve defects, and no run had ever failed
on any of them.

Code review round 1 refuted the first yes on four counts:

- `resolve_archive` searched two of the installer's four archive roots, so a
  newer archive in `$HOME` or `$HOME/pkgs` could be installed while the declared
  one was approved. The wrong-archive control shared the blind spot, since it
  planted its decoy inside the shortened search set.
- Two of the three baseline behaviours the plan requires did not exist: the
  root-file FIFO case and the root-file symlink-to-regular-file case, both with
  rsync present. The RHEL capture's nine passes therefore did not cover the two
  behaviours Step 3 changes for the fallback engine only.
- The exit-only control never entered `run_case`, so it proved only that its own
  private check could see an absent tree, not that a real case would refuse the
  same substitute. `run_case` did return success for an exit-only program
  whenever the expected exit was zero and the phase expression empty.
- The matrix label was derived from the requesting environment alone, so Debian
  with rsync present was still labelled D-fb, RHEL without rsync still R-rs, and
  a forced-fallback request still R-fb against an installer with no override.

All four were corrected, both copies brought into step, and both baselines
regenerated: RHEL 9.8 at sixteen cases and the Debian CI agent at eleven, zero
failures on either. Round 2 accepted those fixes as real and then refuted the
second yes on five further counts, three of which the regenerated captures
demonstrated rather than merely risked:

- **The Debian capture called itself D-fb.** That cell means the fallback engine
  was selected and ran. This installer has no fallback and dies at the mirror, so
  no engine ran at all, and the capture then claimed the label was asserted by
  `engine none`. Absence of rsync's banner proves only that rsync did not run,
  which is equally true of a successful fallback, so it cannot be affirmative
  evidence for one.
- **`run_case` checked only that the prefix was a directory.** No fixture oracle
  existed, so a failed `mkfifo` or `ln -s` produced a case that reported the
  required shape without ever planting it. The symlink case in particular would
  have passed on a host where `ln -s` yields a copy: the destination would carry
  archive content and the unused external file would be unchanged.
- **`--step` changed only the verdict label.** It was never validated and never
  dispatched a suite, so `--step 5` ran the step 0 cases and could print
  `Step 5: every assertion ... behaved as designed`, a vacuous pass at exactly
  the level later steps are meant to rely on.
- **Preflight was neither complete nor a gate.** It omitted commands the harness
  invokes, including the newly load-bearing `env`, and a missing one incremented
  the failure count and carried on into the controls and the installer cases, so
  a dependency failure surfaced as a red verdict twenty lines later rather than
  before anything ran.
- **A passing case printed only the archive basename**, which cannot say which of
  the four searched roots won, and the canonical-installer override added in
  round 1 was open to any case rather than to controls alone.

All five were corrected and both baselines regenerated, at sixteen cases on RHEL
and eleven on the Debian agent, zero failures on either. Both captures reported
the shared-body digest `0f2b90f8` from two different files in two repositories,
which closed the cross-copy provenance question by evidence rather than by
argument. Round 3 accepted that, accepted the honest Debian identity, and then
refuted the third yes on three further counts:

- **The engine assertion treated selection as proof of execution.** It recognised
  a guessed `copy engine: fallback` marker. The plan has Step 1 emit a
  **selection** line before archive discovery while both rsync call sites stay
  unchanged, so on a no-rsync host that line can say fallback and the same run
  still die at the unchanged mirror. The harness would have reported
  `engine fallback, read from the run trace` for a run in which no copy engine
  ran, making a guessed phrase stronger evidence than the event it describes.
- **The fixture oracle had no retained calibration.** It was demonstrated once on
  a developer host, which diagnoses rather than recalibrates: an error in the
  oracle could accept a false declaration on both targets while every ordinary
  case stayed green, and no retained run would show it.
- **Preflight dropped a plan-mandated command.** The plan names five
  verification-only additions required on every target before any case, and
  `diff` was not among the declared tools. The list also claimed to hold every
  external command the harness runs while excepting the child `bash` that
  `run_case` looks up on PATH.

The first of those also corrects reasoning recorded here. The round 3 request
flagged the speculative branch as risky because a wording mismatch would silently
report `none`. That is backwards: a mismatch fails loudly, and the unsafe case is
Step 1 choosing exactly the guessed wording. Guarding the wrong direction is why
the branch was kept rather than removed.

All three are corrected, and both baselines have been regenerated against the
corrected body. RHEL 9.8 captured R-rs by hand on 2026-08-12, seventeen cases and
zero failures, with the identity confirmed from rsync's own operation banner and
both root-file shapes measured. The Debian CI agent captured
`Debian/no-rsync/no-engine` in Jenkins build 38, twelve cases and zero failures:
exit 5 in the mirror phase, no tree deployed, staging retained. All seven
negative controls behave as designed on both targets, including the new
fixture-shape control, so the oracle that reads every setup is recalibrated in
the evidence itself rather than in an anecdote about a developer host. Both
captures report `all 28 present`, and both report the shared-body digest
`d9027ad8` from two different files in two repositories.

The superseded captures are replaced rather than kept alongside, which round 2
confirmed as the right call: a capture that cannot identify the archive actually
consumed, or that names the wrong matrix cell, would imply evidentiary value it
does not have. The review transcript preserves what each said and why it was
rejected.

### Goal for Step 0

Create `docs/v0.27.0/verify.install-pkg.sh`, a scratch-prefix probe covering the
destination shapes the design names, with a case contract that makes each case
prove it ran what it claims, a watchdog calibrated on a deliberate blocker, and
a captured baseline of the current installer.

### Step 0 improvement expectations

- The no-rsync run fails at exit 5 in the mirror phase on the current
  installer, recorded with its phase and message, which is the defect this
  effort removes.
- The watchdog is proved on a deliberate blocker, a copy onto a reader-less
  FIFO invoked directly, which must be reported as a timeout.
- No installer case asserts a timeout, because the current installer has no path
  that blocks: with rsync absent it never reaches the root-file site, and with
  rsync present M2 measured rsync replacing a FIFO promptly with exit 0.
- The negative controls fail as designed and for the right reason: an exit-only
  substitute that changes no state, a wrong-archive substitute that fails the
  archive-identity assertion, and a wrong-installer substitute that fails the
  installer-identity assertion.
- The encoder control survives intact, guarding the hex encoding against the
  digit-deleting defect round 3 review found.
- Every later step has an executable definition of done rather than a written
  one.

### What was implemented for Step 0

- **The harness**: `docs/v0.27.0/verify.install-pkg.sh`, 771 lines, effort-local
  per Q01 so it cannot reach the shipped archive. It takes `--step`,
  `--installer` and `--scratch`, works in a scratch directory it removes on
  exit, and never writes to a deployment prefix.
- **Case contract, per Q07, two mandatory oracles**: `run_case` applies a fixture
  oracle before anything runs, then asserts the declared installer and archive
  against the resolved values, then the exit code, then a phase-specific
  diagnostic, then a post-state oracle. Both oracles are mandatory arguments and
  an unnamed or unknown one is a failure, so neither a status-only pass nor a
  case reporting an unplanted shape is reachable. The fixture oracle covers
  `fresh`, `fifo:<path>`, `symlink:<path>=<target>` with the target verified by
  `readlink`, `decoy-newer:<path>` with the decoy proved newer than the declared
  archive, and `installer-copy:<path>` proved present, at another path, and
  byte-identical to the installer under test. Each passing case prints the shape
  it verified and the identity it asserted, the archive as a logical root plus
  name rather than a bare basename, since one name can exist under more than one
  of the four searched roots.
- **Step dispatch**: only `--step 0` has a case suite, and any other value is
  refused before preflight. The verdict names the suites that actually ran and
  fails if no baseline suite ran, so it can never rest on the requested label
  alone. Extending a later step means extending the dispatch and the suite record
  together.
- **Hermetic archive selection**: every case runs with `HOME` pinned to a scratch
  directory, and `resolve_archive` searches the same four roots `install_pkg.sh`
  line 393 searches, the prefix, its `pkgs` directory, `$HOME` and `$HOME/pkgs`.
  The archive the harness asserts is therefore the archive the installer
  consumes, and nothing it asserts depends on what sits in the real home.
- **Negative controls**: seven. The watchdog blocks a copy onto a reader-less FIFO
  and is killed at two seconds; the wrong-archive control plants a newer decoy so
  the installer's own selection diverges from the declaration; the omitted-root
  control plants the same decoy in `$HOME/pkgs`, the root the superseded resolver
  ignored, so a shortened resolver fails loudly; the wrong-installer control
  points at a present second copy of the script; the exit-only substitute is
  declared as its own canonical installer so it clears identity and travels the
  whole of `run_case`, and is refused by `assert_post_state`, the same oracle
  every real case is judged by; the fixture-shape control plants a plain regular
  file where a case declares an exact symlink and requires refusal on the shape
  rather than on anything downstream; the encoder control confirms that `jln`
  encodes to `6a6c6e`. Each control names the exact refusal reason it requires,
  not a broad prefix, so a missing fixture cannot satisfy a control that exists
  to prove an identity mismatch. The canonical-installer override is refused
  outside a control, so ordinary cases keep no escape hatch from the identity
  gate. The controls run on both targets, so the fixture oracle every behavioural
  conclusion rests on is recalibrated in the evidence being approved rather than
  demonstrated once on a developer host.
- **Synthetic archive builder, per Q02**: carries the shapes the acceptance
  names, a SONAME symlink onto `libgcc_s-11-20240719.so.1`, a linked rpath
  directory `root/lib64` onto `usr/lib64`, a hidden entry, and the `.env` and
  `.env_` archive root files.
- **Baseline capture, all three plan behaviours**: without rsync, exit 5 in the
  mirror phase with the `not-deployed` oracle asserting no populated `tools` tree
  and a retained staging directory. With rsync, a fresh install under the
  `installed` oracle, then the two root-file shapes on their own fresh prefixes:
  a FIFO at `.env`, which rsync must replace with a regular file carrying the
  archive content, and a symlink at `.env` onto a regular file outside the
  prefix, which rsync must replace while that external target stays identical in
  both content and mtime. Promptness needs no separate assertion: every case runs
  under the twenty-second watchdog, so a blocking engine returns 124 and fails
  the expected exit.
- **Engine operation asserted, never inferred**: `assert_engine` reads what
  actually operated from the run's own trace, rsync's file-list banner, which the
  transfer prints rather than a decision to transfer. `none` additionally
  requires a failed run, because absence of the rsync banner alone is equally
  true of a successful fallback and so cannot be affirmative evidence for one.
  The claim `no engine ran` therefore rests on no trace **and** a failure before
  any copy. There is deliberately no fallback expectation and no fallback marker
  recognition: Step 0 asserts only the two states it can witness, rsync operating
  and nothing operating. When Step 1 defines its trace, that belongs in a
  separately named selection assertion, and proof that the selected engine copied
  stays with the operation and post-state cases.
- **Preflight is a gate, not a case group**: it declares twenty-eight commands,
  cross-checked against the script's command positions rather than listed from
  memory; it asserts fractional `stat`; and it asserts the target identity. Any
  failure stops the run with a distinct exit code before a single control or
  baseline case, so a dependency problem cannot be buried under twenty later
  lines. The inventory holds every external command the harness runs, including
  the child `bash` that `run_case` looks up on PATH, which an earlier version
  quietly excepted while claiming to be complete. It also holds the plan's five
  verification-only additions, `timeout`, `stat`, `sha256sum`, `mkfifo` and
  `diff`. Only `diff` is not invoked at step 0: it is the manifest comparison's
  tool, and the target capture is the promised evidence that step 5's acceptance
  gate will have it, which is the point of asserting it. Dropping `env` in favour
  of setting `HOME` on the command itself removed one dependency rather than
  declaring it.
- **Target identity refused rather than qualified**: an identity is claimed only
  when the run can witness it. Debian with rsync present, RHEL without rsync, a
  forced-fallback request, and an installer that can select a fallback engine are
  each refused, and a target-claiming host that cannot produce its identity fails
  preflight instead of printing a qualified label. The last of those is the
  strongest form of the round 3 correction: rather than inferring `D-fb` or
  `R-fb` from the environment, the harness says it has no assertion for a
  fallback and refuses until Step 1 defines the selection trace. Fallback support
  is read from the installer under test rather than from the step number. On a
  non-target host the run states it is a self-test and is not target evidence.
- **The pre-change Debian result is not a matrix cell**: `D-fb` means the
  fallback engine was selected and ran, and this installer has none, so the run
  reports `Debian/no-rsync/no-engine` and says in the header that this is the
  state expected to become D-fb once the engine exists. The cell is reserved for
  a run whose fallback selection is evidenced, which Step 1's engine trace makes
  possible.
- **Installer fingerprint**: the header prints the installer's sha256, its line
  count, and whether it supports the fallback override.
- **Two harness fingerprints, doing different jobs**: the whole-file sha256 pins
  a capture to one exact file, and the shared-body sha256, taken from a marker
  line to the end, is equal in both repository copies. The two files now differ
  only in their header comment block, so the second digest turns "the copies are
  in step" into something a reader checks from the evidence rather than takes on
  prose.
- **Consuming-project stage**: the Debian capture exists because the harness was
  copied to that repository as `tools/installer_verify_step0.sh` and wired into
  a report-never-gate Jenkins stage placed after the relocate stage, in its own
  shell so the pipeline's rsync shim is not on PATH. The installer resolution is
  now one identical block in both files, so the two differ only in their header
  comment and the shared-body digest covers all of the code.
- **Retained baselines, both targets**: `verify.step0.rhel.txt` (R-rs, by hand,
  2026-08-12, seventeen cases: the rsync path installing cleanly with the canary
  symlink surviving, plus the FIFO and symlink root-file shapes with the external
  target byte- and mtime-identical) and `verify.step0.debian.txt`
  (`Debian/no-rsync/no-engine`, Jenkins build 38, twelve cases: exit 5 in the
  mirror phase, no tree deployed, staging retained). Both sanitized before
  retention. The Debian one comes from the build's archived artifact rather than
  the console, so it carries no timestamper prefix and nothing was reformatted,
  and it is tied to consuming-project commit `7503e53a` by a whole-file digest
  that matches that commit's copy byte for byte.
- **Validation evidence**: `bash -n` clean on both copies; the declared tool
  inventory cross-checked against the script's own command positions; the step
  guard and the preflight gate each exercised on a deliberate negative; the
  fixture oracle exercised by a retained control on both targets; both target
  runs exit 0; `install_pkg.sh` unchanged at 505 lines with `src/` untouched;
  both `rsync -av` call sites intact; the sanitization gate clean.

Both captures record the same installer, `3c1f6a56`, 505 lines, `fallback: no`.
That is the published installer the deployment host and CI run today, not this
branch's `8ffb726c`, which is correct for a pre-change baseline. Step 5 must name
which installer it exercises on each target rather than assume the branch one.

### New helpers or cases introduced for Step 0

- `run_case`: the case contract, one function, used by every installer case and
  by the exit-only control. It takes a mandatory fixture oracle and a mandatory
  post-state oracle, plus a canonical-installer override refused outside a
  control, which exists only so a control can be declared as its own installer
  and still travel the whole function.
- `assert_fixture`: what the case claims to have planted, verified before the
  installer runs, with five shapes: `fresh`, `fifo`, `symlink` including its
  exact target, `decoy-newer` including location and newness, and
  `installer-copy` proved present, elsewhere, and byte-identical. This is what
  stops a failed `mkfifo` or `ln -s` from producing a case that reports a shape
  it never planted.
- `assert_post_state`: the single place a deployment is judged, with two oracles,
  `installed` and `not-deployed`. Real cases and the exit-only control go through
  it, so proving the control also proves the cases.
- `assert_engine`: reads what actually operated from the run's own trace. It
  knows two answers, `rsync` and `none`, and `none` also requires a failed run,
  so it means no engine ran rather than only that rsync did not. It recognises no
  fallback marker, because a selection line is not an operation.
- `resolve_archive`: reproduces the installer's archive selection across all four
  of its search roots, under the pinned `HOME`, which is what makes the
  archive-identity assertion real.
- `archive_identity`: names which of the four roots a resolved archive came from,
  since a basename alone cannot say that and the same name can sit under more
  than one root.
- `body_digest`: the sha256 of the shared body, from its marker line to the end,
  printed beside the whole-file digest so a capture proves the two repository
  copies are in step.
- `build_archive`: the synthetic fixture of Q02.
- `enc`: the hex encoder, delete-complement form, shared with the manifest
  recipe and guarded by its own control.
- `control`: runs a negative control with failures captured, then reports one
  case that passes only if the control was refused for the exact reason it
  names. It is the only place `EXPECT_FAIL` and `CONTROL_ACTIVE` are set, and it
  always clears both, so no early return can leave the harness deaf to real
  failures or leave the identity override open. Inner case counting is rolled
  back, so a control is exactly one case either way.
- `suite`: records which case suites actually ran, so the verdict never rests on
  the requested `--step` label.
- `preflight`, `new_prefix`, `short_sha`, `pass`, `fail`, `chk`: supporting
  helpers.

### Architecture check for Step 0

- **Layering**: the DDD-Hexagonal question does not apply. This repository has
  no application layers, no ports and no adapters: it is Bash and Batch, and
  this step adds one standalone shell script. Reporting compliance would be
  meaningless rather than reassuring.
- **The boundary that does apply**: the harness must not reach the shipped
  archive. It lives under `docs/v0.27.0/`, which `pkg.sh` never packages, and
  its only reference to `src/` is the default path used to locate the installer
  under test. It writes nothing under `src/`.
- **Separation**: the harness reads the installer and never edits it, so Step 0
  cannot mask a later step's defect by changing the thing it measures.

- **Two copies of one script**: the Debian capture required a copy of the
  harness in the consuming project, since that agent is the only Debian target
  and it has no access to this repository. The copy names this repository as its
  source of truth in its header, and differs only there and in how it resolves a
  default installer. It can still drift.

Yes, there is something that needs to be addressed: the harness now exists in
two repositories and nothing enforces that they stay in step. It is a watch
point rather than a defect in this step, and the natural moment to check it is
Step 5, which runs on both targets. Two things now make drift visible rather
than silent, and they do different jobs.

Each run prints the sha256 of the whole file that produced it. That pins a
capture to one exact body, which is how a Debian capture is tied to the commit
that produced it. It cannot compare the copies: the digest covers the header, and
the headers differ by design, so those two values are expected to differ and
their difference means nothing.

Each run also prints the digest of the shared body, from a marker line to the
end, and that value is equal in both copies. The installer resolution is now one
identical block, so the marker sits directly under the header comment and the
shared digest covers all of the code rather than most of it. This is what proves
the copies are in step, and unlike the round 2 arrangement it is proved by the
evidence itself rather than by a `diff` a reader has to run and a paragraph
asking them to trust it.

Round 2's version of this paragraph claimed the whole-file digest let two
captures be compared. It does not, and the two captures disproved it by reporting
different values for identical bodies. The two digests are kept separate here for
that reason.

### Cost and timing check for Step 0

- **No new computation in the installer**: Step 0 changes no installer code, so
  the plan's cost bounds are untouched.
- **Harness cost**: each case builds a small synthetic archive and runs one
  installer invocation. Work is linear in the number of cases, with no nested
  iteration over tree entries, so nothing here is quadratic or `n log n`.
- **Timing**: every installer invocation runs under a twenty-second watchdog,
  and the watchdog itself is proved by a deliberate blocker rather than assumed.

No, there is no performance issue that needs to be addressed.

### Harness case check for Step 0

This replaces the template's unit-test coverage section: the repository has no
Python package and no unit tests, so there is no class to hold to 100%.

- **Preflight**: 3 cases, the command inventory, the fractional-`stat`
  assertion, and the target-identity assertion. It is a gate: any of the three
  failing stops the run before a single control or baseline case, with a distinct
  exit code, so nothing after it can be mistaken for evidence.
- **Negative controls**: 7 cases, each asserting the exact reason it failed
  rather than a broad prefix that a different failure could satisfy. They run on
  both targets, so every one of them is recalibrated in each retained capture.
- **Baseline, no-rsync branch**: 2 cases, the mirror failure under the
  `not-deployed` oracle and the engine assertion. Twelve cases in total on that
  branch.
- **Baseline, rsync branch**: 7 cases, the fresh install and its engine
  assertion, the root-file FIFO case with its replacement sentinel, and the
  root-file symlink case with its replacement sentinel and its external-target
  sentinel. Seventeen cases in total on that branch.
- **Coverage of the harness itself**: the negative controls stand in for it.
  They cover a vacuous pass, a wrong-operation pass, a resolver blind to one of
  the installer's search roots, and a false fixture declaration. The exit-only
  control runs through the same oracle a real case uses, so proving it proves the
  cases rather than only itself; the fixture-shape control does the same for the
  oracle that interprets every setup, and it is retained on both targets rather
  than demonstrated once on a developer host.
- **Guards proved on deliberate negatives during the rework**: the step guard
  refuses `--step 1` with exit 2, and an injected missing command stops the run
  at preflight with exit 2 and no case executed. These are host-independent, so a
  developer-host proof is sufficient for them, which is why they have no target
  control of their own.
- **Still uncovered**: a case whose sentinels are themselves wrong, which the
  plan records as an accepted residual.

No, there is no unexercised case left. Both branches have run on the target each
describes, against this harness body: seventeen cases on RHEL, twelve on the
Debian agent, zero failures on either, with the shared-body digest in both
captures confirming the two copies were the same code.

### Feature integrity for Step 0

- **Existing behaviour**: nothing under `src/` changed. `install_pkg.sh` is
  unchanged at 505 lines and both `rsync -av` call sites are intact, so no
  existing installer behaviour is impaired.
- **Reporting**: the installer's own diagnostics are untouched. The harness adds
  reporting of its own, in its output only.
- **Compatibility**: the harness is a new effort-local file. Nothing depends on
  it yet, and it cannot reach a deployment prefix or the shipped archive.

No existing feature or reporting capability appears impaired.

## Step 1. Engine selection, override and trace

### Analysis of Step 1 implementation state

Yes. Step 1 has been fully implemented, and its cases pass on both supported
targets.

`select_copy_engine` resolves the engine once, before archive discovery, from
`command -v rsync` and the override, and announces it with one `info` line
carrying the engine, the resolved rsync path when rsync was selected, and the
forced reason when the override applied. Both `rsync -av` call sites are
unmodified, as this step requires: nothing branches on the verdict yet.

The harness gained a step 1 suite and, with it, a `--step 1` dispatch that is
cumulative, so a step 1 run executes the step 0 preflight, controls and baseline
as well. Six cases cover the override matrix the plan names: unset, `1`, `0`,
`yes`, `true` and empty. The harness distinguishes unset from set-and-empty,
because the code under test does.

**The evidence position, stated plainly.** The step 1 cases were run against the
pre-change installer first, as the shared checklist requires, and failed on all
six with `SELECTION: no 'Copy engine:' line in the run trace`, with no case
passing vacuously. They pass against the implemented installer.

Round 1 of the step 1 code review found the first version of this suite could not
run on either target, and the cause was the harness rather than the installer.
Step 0 refuses an installer able to select a fallback, which was right while
nothing could witness one, and the step 1 candidate contains that token, so both
targets stopped at the identity preflight before any case ran. The developer host
hid it, an unsupported host being reported as a self-test either way. The identity
contract now advances with the suite, so a later step defines its own rules
instead of inheriting an earlier step's by accident.

The same round found the ordering oracle able to pass without evidence: it
compared line positions only when the archive discovery marker existed and
otherwise still reported `announced before discovery`. The marker is now required,
and a retained control feeds the oracle a synthetic trace without one.

**How both targets are covered.** The step 1 completion criterion says the cases
pass on both targets, and the Debian agent measures the installer extracted from
the published archive, which has no engine selection. The code review kept the
criterion literal and settled the route: the agent runs a **verification input**,
a byte-identical copy of the candidate at
`tools/install_pkg.candidate.verification-only.sh` in the consuming project,
exercised by a separate stage. It does not replace the bootstrap installer, does
not enter the packaged archive, and no deployment step reads it; the Step 0 stage
still measures the published installer, so the baseline continues to describe
what CI runs. Shipping the fixed installer through the archive stays Step 5's
obligation under Q05, and this does not discharge it. The duplication is
temporary and should be deleted once Step 5 does.

No plan amendment was needed, and none was made.

**A sanitization fix intervened between convergence and commit, and it moved the
installer digest.** The repository's pre-commit hook refused the step 1 commit:
three tracked files carried the deployment account name, in a public repository.
The rule covering that term was added to the sensitive-content rules during this
effort and nothing had scanned tracked source against it, so the leak surfaced
only when an unrelated commit was blocked. The hook scans whole staged blobs, so those
files were uncommittable until fixed.

All three are corrected, and none changed behaviour. `install_pkg.sh` line 36 was
a comment example. The other two, `gpg-agent.conf` and `git-pass-helper.sh`, hold
their literals inside a `/home/<account>/` anchor that `fix_text_paths` rewrites
to the install prefix on deploy, and its pattern `${HOME_ANCHOR}[^/]*/` matches
any account name, so the anchor is the mechanism rather than the address.
Parameterising off `$HOME` was considered and rejected as wrong: a relocated
install has a prefix that is not the home, and GnuPG expands no variable in a
conf file at all, which is what forced an absolute path there originally. The
rewrite was proved rather than assumed, by running the installer's own sed rules
over both files and confirming every anchor becomes the prefix and none survives.

The installer is therefore `312be8ae` rather than the earlier digest, still 535
lines, one comment line apart. Both captures were regenerated against it, at
identical case counts, so the only thing that moved is the digest. The step 1
review had already converged on code this does not change, and the exchange was
past its rounds by then, so the change is recorded here and in the commit rather
than carried by a further round.

**Both captures, regenerated.** RHEL 9.8, `step1-candidate/RHEL/rsync`, 32 cases
and zero failures: the six selections behave as the design settled, and the
divergence case records that a forced `cp` selection still operates rsync. The
Debian agent, `step1-candidate/Debian/no-rsync`, Jenkins build 41, 26 cases and
zero failures: every selection is `cp` because rsync is absent, and what the six
cases establish there is the reason attached to each, so a truthy-looking value
is not reported as a forced fallback on the target where the fallback will matter
most. Both report the shared-body digest `65451888`, and the Debian capture's
installer digest equals the staged source byte for byte.

Two things only the RHEL capture can show, permanently: the rsync-selected trace
form and the forced divergence both need rsync, which the Debian agent will never
have. That is the Q19 defect itself rather than a coverage gap.

Build 41 also regenerated the Debian step 0 capture at 12 cases and zero
failures, against the published installer, confirming the harness changes were
confined to step 1. The committed step 0 captures are **not** replaced with it:
step 0 is converged and committed, and each capture records the harness body that
produced it, which is what the two digests exist for.

### Goal for Step 1

Resolve the copy engine once, before archive discovery, from `command -v rsync`
and the `CPLX_INSTALL_PKG_FORCE_CP` override, and announce the selection with
the resolved rsync path or the forced reason.

### Step 1 improvement expectations

- One `info` line per run, emitted before archive discovery, reporting a
  selection rather than an action.
- A stand-in shim on `PATH` becomes visible, because the line carries the
  resolved path.
- Only the exact value `1` forces the fallback; every other value leaves rsync
  selected and is reported as rsync.

### What was implemented for Step 1

- **The verdict, declared in the configuration block**: `COPY_ENGINE`, either
  `rsync` or `cp`; `COPY_ENGINE_RSYNC`, the resolved binary when rsync was
  selected; and `CPLX_INSTALL_PKG_FORCE_CP`, defaulted from the environment so
  the override has one reading site.
- **`select_copy_engine`, called once before archive discovery**, per Q06. rsync
  is selected when `command -v rsync` resolves and the override is not exactly
  `1`; the fallback otherwise. The override never selects rsync.
- **The trace**: one `info` line, `Copy engine: rsync (<path>)`,
  `Copy engine: cp (forced by CPLX_INSTALL_PKG_FORCE_CP=1)` or
  `Copy engine: cp (rsync not found on PATH)`. The resolved path is not
  decoration: `command -v rsync` finds the consuming project's stand-in shim as
  readily as a real rsync, and that shim ignores `--delete`, so printing what was
  resolved turns an invisible degradation into a visible one. The smoke test
  confirms it, reporting the shim's own path.
- **Absence selects the fallback, failure does not**: nothing here reacts to an
  rsync that exists and exits non-zero, which stays a diagnosable error rather
  than becoming a silent success with different semantics.
- **Both call sites untouched**: `rsync -av --delete` and `rsync -av` are
  byte-identical to their pre-change form, and one detection site exists, both
  confirmed by the step's grep checks.

### New helpers or cases introduced for Step 1

- `select_copy_engine` in the installer: the only engine decision in the run.
- `assert_selection` in the harness: reads the `Copy engine:` line, requires
  exactly one of them, checks the engine and its detail, and asserts the line
  appears before archive discovery, which is Q06 made executable. It is a
  **different function from `assert_engine` on purpose**, and its pass message
  says so: a selection is not proof that anything copied. Step 0's code review
  removed a guessed fallback marker from `assert_engine` for exactly this reason,
  and separating the two functions is what stops the conflation returning now
  that the trace exists. The archive discovery marker is required rather than
  compared when present: an earlier version reported `announced before discovery`
  for a trace with nothing to order against, and an ordering oracle that
  concludes from absence orders nothing.
- **The step-aware identity contract**: at `--step 0` an installer able to select
  a fallback is refused, since nothing there can witness one. At `--step 1` the
  candidate is admitted on the two valid shapes, RHEL with rsync and Debian
  without, and the run is labelled `step1-candidate/...` rather than a matrix
  cell, because one run holds six selections and, on RHEL, the forced divergence,
  which no single engine cell describes. A global forced override and any host
  and tool shape the matrix does not contain stay refused at every step.
- **Two ordering controls**, named separately so each failure reason is checked
  independently and each counts once. `control selection-no-discovery` feeds a
  well-formed selection line with no discovery marker and must be refused on the
  marker; `control selection-out-of-order` feeds exactly one discovery marker
  followed by one otherwise-valid selection line and must be refused on the
  comparison. Both retained on both targets. The second exists because the first
  calibrates marker presence rather than ordering: the branch implementing Q06
  had never executed, since the six real cases only show a correctly ordered
  trace passing and no installer emits a wrongly ordered one.
- `CASE_FORCE_CP` in `run_case`: distinguishes unset, set-and-empty, and set to a
  value, because the code under test distinguishes them and the plan names both
  of the first two.
- **Six selection cases**, the override matrix: unset, `1`, `0`, `yes`, `true`,
  empty. Only `1` selects the fallback; `yes` and `true` are asserted to report
  rsync rather than a forced fallback, since tolerant parsing would be a
  liability where the consumers are scripts.
- **One divergence case**, `step1 forced still operates rsync`, run only where
  rsync is present. With the fallback forced, step 1 selects `cp` and still
  mirrors with rsync, because no call site has changed. Asserting that here
  records the divergence in evidence rather than describing it, and gives step 2
  something to show a transition against.

### Architecture check for Step 1

- **Layering**: not applicable, as for step 0. This repository is Bash and Batch
  with no application layers, ports or adapters.
- **The boundary that does apply**: one decision site, reused. The plan's Q01
  keeps the mirror and the root-file deploy as independent paths sharing the
  verdict and nothing else, so this step adds the verdict and no abstraction over
  the two transfers.
- **Placement**: the verdict is declared in the configuration block and resolved
  in its own section between prefix resolution and archive discovery, so the
  announcement precedes every step that can fail on a foreign target.

No, there is nothing that needs to be addressed.

### Cost and timing check for Step 1

- **One `command -v`** per run, replacing nothing and repeated nowhere. The
  design's cost note allowed exactly this: one path lookup for engine detection.
- **No per-entry work**: nothing here touches the deployed tree.
- **Line budget**: 505 to 535, a delta of +30 against an advisory +15 to +25.
  The overage is comment, not code: the block explaining why the resolved path is
  printed is what stops a later step deleting the one field that makes a stand-in
  shim visible. Recorded rather than trimmed further.

No, there is no performance issue that needs to be addressed.

### Harness case check for Step 1

- **Cumulative dispatch**: `--step 1` runs preflight, the seven step 0 controls,
  the step 0 baseline and the step 1 suite, so 26 cases on a no-rsync host and 32
  on a host with rsync.
- **Step 1 suite**: 14 cases on a no-rsync host, the two ordering controls plus
  six runs each with its selection assertion; 15 where rsync is present, the
  extra being the divergence case.
- **Cases first, and seen to fail**: run against the pre-change installer the six
  selection assertions fail with `SELECTION: no 'Copy engine:' line in the run
  trace`, and no case passes vacuously. The six runs themselves still pass, which
  is correct: this step changes selection, not behaviour.
- **Both targets, retained**: `verify.step1.rhel.txt` at 32 cases and
  `verify.step1.debian.txt` at 26, zero failures on either. Every case in the
  suite has now run on at least one supported target.
- **Still unexercised, and permanently so on one target**: the rsync-selected
  trace form and the divergence case cannot run on the Debian agent, which has no
  rsync and never will. The RHEL capture is their only evidence, and that is the
  Q19 defect rather than a gap the harness can close.
- **The ordering oracle is now calibrated on both sides**: one control proves it
  refuses a trace with no discovery marker, the other proves it refuses a trace
  whose selection line follows the marker. An earlier version had only the first,
  which left the branch implementing Q06 never executed, and no installer emits a
  wrongly ordered trace to exercise it incidentally.

### Feature integrity for Step 1

- **Existing behaviour**: unchanged. Both `rsync -av` invocations are
  byte-identical, nothing branches on the verdict, and every exit code keeps its
  number. A host with rsync installs exactly as before; a host without still dies
  at exit 5 in the mirror phase, now having said which engine it would have used.
- **Reporting**: one line added, before archive discovery. It reports a selection
  and claims nothing about a transfer.
- **Compatibility**: `CPLX_INSTALL_PKG_FORCE_CP` is new and read once. Unset
  behaves exactly as before this step, so no existing caller changes. Only the
  exact value `1` does anything, which fails safe for a caller that sets a
  truthy-looking value expecting tolerance.
- **The one real risk, and it is deferred by design**: with the override set to
  `1` on a host with rsync, the run now says `cp` and still mirrors with rsync.
  That is visible in the evidence rather than hidden, and step 2 closes it. Until
  then the override is a test surface whose effect is a trace, which is why the
  design forbids pointing it at a live deployment prefix.

No existing feature or reporting capability appears impaired.

---

## Step 2. Mirror fallback with its destination boundary

### Analysis of Step 2 implementation state

Yes. Step 2 has been fully implemented, and its cases pass on both supported
targets.

`mirror_tree_cp` reproduces the mirror's delete semantics without rsync, and the
mirror site branches on the verdict. The rsync invocation is unchanged inside its
branch, so this step adds a second path rather than altering the first.

**The boundary is the point of this step, and it is stricter than rsync.** It
observes the destination without following any link: a symlink of any kind is
refused, and so is any present non-directory. Only two shapes are accepted, an
absent destination which it creates, and a real directory whose *content* it
empties. Emptying the content rather than removing the directory retains the
directory object, and with it any mount-point boundary on that path. It promises
nothing about the directory's metadata: the copy form deliberately gives the
transfer root the source's attributes, so no ACL on the destination is preserved,
and ACLs are outside the parity manifest in any case. The refusal happens before
a single entry is removed.

The sharpest shape is a destination that is a symlink to a directory. The design
records M1 measuring the rsync path following that link under `--delete`,
emptying the *external* target and returning 0. The fallback refuses it. So on
the one shape where the two engines differ most, the new engine is the safe one
and the unchanged one is silently destructive, which is the opposite of the
intuition an earlier design draft had recorded.

**Two existing cases changed rather than being deleted**, which is what the step
1 review required of this step:

- `step1 forced still operates rsync` became `step1 forced now operates cp`. It
  marked the step 1 divergence where a forced selection still operated rsync;
  step 2 closes that, so the assertion is re-pointed at the new engine.
- `baseline no-rsync mirror` expected exit 5 at the mirror, the Q19 defect
  itself. The fallback now completes the mirror on that target, so the case
  expects exit 7 at the root-file site, which still calls rsync unconditionally
  until step 3, under a new `mirrored-not-deployed` oracle.

That second change is the effort's central defect being removed, recorded as a
transition rather than as a green line. The step 1 selection cases moved with it
for the same reason: what a run does after selecting is a property of the step,
not of step 1, and their selection assertions are unchanged either way.

**Both captures are in hand.** RHEL 9.8, `step2-candidate/RHEL/rsync`, 42 cases
and zero failures, exercising both engines at the mirror. The Debian agent,
`step2-candidate/Debian/no-rsync`, Jenkins build 43, 35 cases and zero failures,
where the fallback is the only engine and the mirror completing is the defect
being removed rather than an override being honoured.

The developer host cannot create symlinks at all, so
two case classes could not be exercised there: the canary SONAME symlink after a
fallback mirror, and the symlink-to-directory boundary, whose fixture oracle
correctly refused rather than passing. Both pass on both targets. The step 2 cases
were run against the pre-change installer first, as the shared checklist
requires, and failed on nine assertions with none passing vacuously.

### Goal for Step 2

Branch the mirror on the engine verdict; on the fallback path, observe the
destination without following symlinks, refuse anything neither absent nor a
real directory, then empty the destination content and copy with
`cp -a src/. dst/`.

### Step 2 improvement expectations

- A fresh install and a redeployment both succeed without rsync, with hidden
  stale entries removed.
- A wrong-shape destination fails at exit 5 before anything is deleted, and a
  symlinked destination's target is untouched.
- `fix_home_symlink_targets` still receives a tree whose links are links, so
  `libgcc_s.so.1` survives as a symlink.

### What was implemented for Step 2

- **`mirror_tree_cp`**, following the existing helper convention: `local` args, a
  `task` line, `fatal` with an exit code inline, `ok` on success. Called from the
  mirror site so the surrounding `task` line and the `fix_home_symlink_targets`
  call after it are untouched.
- **The destination boundary**, applied before anything is removed. `-L` is
  tested first and no test follows a link. Refuses a symlink of any kind and any
  present non-directory; accepts an absent destination, which it creates, and a
  real directory, whose content it empties.
- **Emptying the content, not the directory**: `find "$dst" -mindepth 1 -maxdepth
  1 -exec rm -rf -- {} +`, so the directory object survives and a mount point
  stays a mount point. Its metadata does not survive and is not claimed to: the
  copy form resets the transfer root from the source, so an ACL on the
  destination is not preserved. An earlier version of this record said such a
  destination "survives as itself", which overstated what keeping the inode
  buys.
- **`cp -a "$src/." "$dst/"`**, the design's load-bearing copy form. It gives the
  transfer root the source mode and mtime, matching the other engine's treatment
  of its transfer root, and it carries hidden entries without depending on the
  caller's globbing. Both trees hold hidden entries.
- **The exit-5 rewording this step owns**, per Q04-4C: `Error: Rsync (main)
  failed.` is gone, replaced by messages naming the mirror step and the engine
  that failed. The code stays 5 on both engines, so no caller changes.
- **An operation trace for the fallback**, `Mirror engine cp:`, emitted by the
  helper at the point it copies. This is beyond the plan's named rewording and is
  flagged as such in the review: without it no assertion can witness a successful
  fallback, since the fallback has no equivalent of rsync's file-list banner, and
  the step 1 divergence case could not have been re-pointed.

### New helpers or cases introduced for Step 2

- `mirror_tree_cp` in the installer: the only new function, and the only place
  the destructive boundary lives.
- `assert_engine` gained a `cp` answer, recognised by the helper's operation
  trace. The cp marker takes **precedence** over the rsync banner, because at
  step 2 the root-file site still calls rsync unconditionally, so a forced run
  prints that banner from the later site while the mirror ran cp. Reading the
  banner alone would name the wrong engine for the site being asserted.
- Three fixture oracles: `dest-file`, `dest-symlink-dir` with its target read
  back and proved a directory, and `populated` with a named stale marker.
- Two post-state oracles: `mirrored-not-deployed`, the honest intermediate where
  the mirror completed and the root-file site has not; and `staging-retained`
  for the boundary refusals, where the tree is deliberately left as it was.
- Nine step 2 cases on a host without rsync, ten where rsync exists, the extra
  being the same wrong-shape fixture on the rsync engine so the reworded exit-5
  diagnostic is asserted on **both** engines rather than only the new one.

### Architecture check for Step 2

- **Layering**: not applicable, as for the earlier steps.
- **The boundary that applies**: Q01 keeps the mirror and the root-file deploy as
  independent paths sharing the verdict and nothing else. This step branches one
  of them and leaves the other untouched, so the destructive boundary attaches to
  exactly the site that deletes, and cannot be applied to the site that does not.
- **The rsync path is unchanged**, inside its branch. Both original invocations
  are byte-identical, which the step's grep check confirms.

No, there is nothing that needs to be addressed.

### Cost and timing check for Step 2

- **One `find` and one `cp` per mirror**, on the fallback path only. No per-entry
  shell iteration, so nothing here is quadratic.
- **The rsync path adds nothing**: it gains one string comparison on an
  already-computed verdict.
- **Line budget**: 535 to 584, a delta of +49 against an advisory +25 to +35. The
  overage is the boundary's five distinct diagnostics and the comments recording
  why the copy form and the refusal rule are design constraints rather than
  implementation choices. Recorded rather than trimmed, as at step 1.

No, there is no performance issue that needs to be addressed.

### Harness case check for Step 2

- **Cumulative dispatch**: `--step 2` runs preflight, the seven controls, the
  step 0 baseline, the step 1 suite and the step 2 suite: 35 cases on a no-rsync
  host and 42 where rsync is present.
- **Step 2 suite**: 9 cases without rsync, 10 with, covering a fresh fallback
  install, a redeployment over a populated tree, the hidden entry carried, the
  stale entries removed, both wrong-shape refusals, and the untouched-destination
  sentinels for each.
- **Cases first, and seen to fail**: nine assertions failed against the
  pre-change installer, including both boundary diagnostics and the engine
  assertion, with none passing vacuously.
- **Retained on both targets**: `verify.step2.rhel.txt` at 42 cases and
  `verify.step2.debian.txt` at 35, zero failures on either. The canary SONAME
  symlink after a fallback mirror, and
  the symlink-to-directory boundary, could not run on the developer host, which
  cannot create a symlink
  at all, verified directly rather than assumed. Both pass on both targets
  now. The fixture oracle refused the second rather than passing it, which is the
  oracle behaving correctly on a host that cannot build its fixture.

### Feature integrity for Step 2

- **The rsync path is unchanged.** Both original invocations are byte-identical,
  the mirror one now inside a branch. A host with rsync installs exactly as
  before, and the step's grep checks confirm the call sites and the absence of
  the old message.
- **Exit codes keep their numbers.** The mirror still fails at 5 on either
  engine, so no caller changes. Only the message text moved, which the plan
  assigns to this step precisely so no intermediate commit publishes a message
  naming rsync for a step that may now run `cp`.
- **A behaviour genuinely changes, and it is the intended one.** On a host
  without rsync the mirror now succeeds where it used to exit 5. That is the Q19
  defect being removed. The run still fails, at the root-file site and exit 7,
  until step 3 branches that site too, so this step leaves the installer working
  further than before and not yet working end to end on that target.
- **The new engine is stricter than the old one on one shape**, a destination
  that is a symlink to a directory. The rsync path follows it and can empty an
  external target while returning 0; the fallback refuses. A prefix configured
  that way changes from a silent success to a diagnosable exit 5. That is a
  deliberate behaviour change, scoped to the fallback, and it is the safe
  direction.
- **Compatibility**: no new variable, no new exit code, no new dependency. `cp`
  and `find` were already in the harness inventory and are already used by the
  installer.

No existing feature or reporting capability appears impaired.

---

## Step 3. Root-file fallback with its non-following preflight

### Analysis of Step 3 implementation state

Yes. Step 3 has been fully implemented.

Its cases pass on both supported targets. This is the step at which the Q19
defect is gone end to end.

Review round 2 narrowed an unwitnessed `rsync` answer out of the new deploy
operation assertion, which changed the harness body, so both captures were
regenerated against it. Every case outcome is unchanged and the installer is
byte-identical; only the harness digests moved.

`deploy_root_file_cp` branches the root-file loop on the verdict, and it is
deliberately a separate helper from the mirror's, sharing nothing with it but the
engine verdict. This operation has no delete semantics, so the mirror's
destructive boundary must not be reachable from here, nor these rules from there.

**The preflight is a safety rule, and M2 is why.** Measured on coreutils 8.32 and
9.1, this engine carries two hazards the rsync path does not. Onto a destination
that is a symlink to a regular file, `cp -a` follows the link, overwrites the
external target and returns 0: silent data loss reported as success. Onto a FIFO
it blocks, so an unattended install waits forever rather than failing. Both are
engine semantics rather than a distribution accident.

The observation therefore does not follow links, and `-L` is tested first. That
is load-bearing rather than stylistic: a following predicate would classify a
symlink to a regular file as an acceptable regular file and preserve the exact
overwrite the rule exists to remove. Two shapes are accepted, an absent
destination and a real regular file; every directory, every kind of symlink,
every FIFO and every other special file is refused at exit 7 before `cp` runs,
which is what stops the block. The copy is `cp -a --remove-destination`, static
defence in depth with no concurrency claim attached.

**The exit-7 rewording this step owns**, per Q04-4C: `Error: Rsync (...) failed.`
is gone from both engines, replaced by messages naming the deploy step and the
engine, with the preflight refusals using the same code. The step's own grep
check also caught a section comment still reading `Rsync (Mirror Mode)`, which
step 2 left behind when it made the mirror engine-neutral; it now reads
`Mirror the tree`.

**Three markers moved rather than being deleted**, which is what the step 2
review required this step to do:

- `baseline no-rsync mirror` has now moved twice. Exit 5 at the mirror at step 0,
  the Q19 defect written down; exit 7 at the root-file site at step 2, the honest
  intermediate; exit 0 here, with the install completing on the fallback engine
  alone. The sequence is readable only because each move re-pointed the same
  assertion.
- The step 1 selection cases and the step 2 suite follow it to exit 0 on a
  no-rsync host, for the same reason: what a run does after selecting is a
  property of the step.
- The cp-marker precedence stayed mirror-scoped without needing a change, because
  the new site emits `Deploy engine cp:` rather than the mirror's marker. That
  was the obligation the step 2 review recorded, and distinct markers discharge
  it by construction rather than by a rule someone must remember.

**A latent harness defect was found while writing these cases, and fixed.**
`run_case` left `CASE_LOG` and `CASE_EXIT` holding the previous case's values
when a case failed before running the installer. Every `assert_engine` and
`assert_selection` call reads `CASE_LOG` immediately after such a `run_case`, so
a case that failed at its fixture would have had the next assertion read the
wrong run's log, quite possibly passing. Both are now cleared on entry and both
assertions refuse an empty or missing log with a message saying the case never
ran. This was reachable on any host, not only this one; it surfaced here because
the developer host cannot build a symlink fixture.

**Both target behaviours were demonstrated before and after the round 2
reviewer repair.** The superseded runs established the production behaviour;
the replacements establish the narrowed harness body proposed for commit. RHEL
9.8, `step3-candidate/RHEL/rsync`, ran 56 cases with zero failures, exercising
R-rs and R-fb at both transfer sites in one run. The Debian agent,
`step3-candidate/Debian/no-rsync`, Jenkins build 46, ran 47 with zero failures,
exercising the D-fb cell end to end.

The two cases the developer host could not run both pass on both targets: the
symlink-to-regular-file refusal, which is the one preventing measured silent
external data loss, and the canary. That host cannot create a symlink at all,
verified directly rather than assumed, so until these runs everything said about
that refusal came from reading the code.

The step 3 cases were run against the pre-change installer first, as the shared
checklist requires, and failed on eighteen assertions with none passing
vacuously.
### Goal for Step 3

Branch the root-file loop on the verdict; on the fallback path, observe the
destination without following symlinks, accept only an absent destination or a
real regular file, and copy with `cp -a --remove-destination src prefix/name`.

### Step 3 improvement expectations

- A destination that is a symlink to a regular file fails at exit 7 with the
  external target byte-identical, mtime included.
- A FIFO destination reaches the root-file preflight and fails promptly at exit
  7, against the Step 0 baseline where rsync replaced it with exit 0. The
  watchdog calibration case still reports a timeout, so "promptly" stays
  falsifiable.
- Directory destinations fail at exit 7 rather than swallowing the payload.
- No concurrency claim is made anywhere: the preflight and the copy remain
  separated in time, and that limit is stated.

### What was implemented for Step 3

- **`deploy_root_file_cp`**, separate from the mirror helper by design: this
  operation has no delete semantics, so neither helper's rules are reachable from
  the other's site.
- **The non-following preflight**: `-L` first, two shapes accepted, everything
  else refused at exit 7 before `cp` runs.
- **`cp -a --remove-destination`**, static defence in depth, with no concurrency
  claim made anywhere.
- **The exit-7 rewording**, on both engines, and the stale `Rsync (Mirror Mode)`
  section comment step 2 left behind.
- **`CASE_LOG` and `CASE_EXIT` cleared on entry to `run_case`**, with both
  trace-reading assertions refusing an empty log.

### Round 2 rework for Step 3, and how it was discharged

Review round 2 removed an unwitnessed `rsync` answer from `assert_deploy_engine`.
It had concluded that rsync operated at the deploy site purely because no
fallback marker appeared, which proves only that the assertion did not see the
fallback. That is the same absence-as-operation inference an earlier review
removed from the mirror assertion, reintroduced in the function written to fix a
related conflation, and it survived a reading because nothing called it.

- The narrowed assertion was synchronized to the consuming-project harness, whose
  shared body is again byte-identical at `5e0f4430`.
- Both targets were rerun against that exact body and the replacement captures
  retained: RHEL 56 cases, Debian 47, zero failures, matching the counts the
  superseded runs produced.
- The installer is byte-identical at `f86dba2a` across both the superseded and
  the replacement captures, so the production behaviour was never in question;
  only the harness digests moved.

### New helpers or cases introduced for Step 3

- `deploy_root_file_cp` in the installer, the second and last engine branch.
- `dest-dir` fixture oracle, for the empty and populated directory shapes.
- `assert_deploy_engine`: the deploy site's own operation trace, a separate
  function from `assert_engine` because that one stays mirror-scoped. Reading
  the mirror marker for a deploy assertion would prove only that the mirror used
  cp, which on a host with rsync is exactly step 2's behaviour and precisely
  what this assertion must reject. It also counts the marker, since a tools
  archive carries two root files and one stray occurrence must not satisfy a
  contract expecting two. It exposes no rsync answer: absence of this cp marker
  cannot prove rsync operated. The cp answer was verified by running the step 3
  suite against the step 2 installer, where it fails with "no Deploy engine cp:
  trace".
- `mirrored-only` post-state oracle: the mirror completed and the run failed at
  the root-file site. It deliberately asserts nothing about the root files,
  because each refusal case has its own destination shape and folding them in
  would weaken the oracle to whatever they share.
- Twelve step 3 cases without rsync, fourteen where it exists: both accepted
  shapes in one run with the deploy engine and its marker count asserted from
  the deploy trace, the symlink refusal with its link-intact and
  external-target-intact sentinels, the FIFO refusal with its FIFO-intact
  sentinel under the watchdog, the empty and populated directory refusals with a
  content-intact sentinel, a refusal-distinguishable-from-copy-failure check,
  and on rsync the same symlink shape asserting the engines DIFFER.

### Architecture check for Step 3

- **Layering**: not applicable, as for the earlier steps.
- **The boundary that applies**: Q01 keeps the two transfer sites independent,
  sharing the verdict and nothing else. Both are now branched, and each carries
  only the rules its own operation needs. The mirror deletes and has a
  destructive boundary; the deploy does not delete and has none.
- **Both original rsync invocations remain byte-identical** inside their
  branches, which the step's grep check confirms.

No, there is nothing that needs to be addressed.

### Cost and timing check for Step 3

- **One type test and one `cp` per archive root file**, on the fallback path
  only, which is two files for a tools archive. No tree traversal is added.
- **The refusal is what makes the timing claim**: the FIFO is refused before
  `cp` runs, so the engine cannot block. The watchdog proves promptness is
  falsifiable, and the calibration control still reports its timeout.
- **Line budget**: 584 to 622, a delta of +38 against an advisory +20 to +30.
  The overage is the comment recording M2's two measured hazards and why the
  observation must not follow links, which is the reason the rule exists.

No, there is no performance issue that needs to be addressed.

### Harness case check for Step 3

- **Cumulative dispatch**: `--step 3` runs preflight, the seven controls, the
  step 0 baseline and the step 1, 2 and 3 suites: 47 cases on a no-rsync host
  and 56 where rsync is present. The two extra RHEL assertions are the rsync
  symlink run and its replacement sentinel.
- **Cases first, and seen to fail**: eighteen assertions failed against the
  pre-change installer, including every refusal diagnostic, with none passing
  vacuously.
- **Retained replacement captures on both targets**:
  `verify.step3.rhel.txt` ran 56 cases and `verify.step3.debian.txt` ran 47, zero
  failures on either. The symlink-to-regular-file refusal and canary both pass.
  The developer host cannot create a symlink at all, verified directly, so both
  were unexercised until the target runs. These retained replacements use the
  shared harness body after review round 2 narrowed the unused, absence-based
  rsync answer out of the deploy assertion.

### Feature integrity for Step 3

- **Exit codes keep their numbers.** The root-file step still fails at 7 on
  either engine, and the preflight refusals use the same code, so no caller
  changes. Only the message text moved, which the plan assigns to this step.
- **The rsync path is unchanged**, including on the shapes where it replaces
  what the fallback refuses. That asymmetry is deliberate and is the same trade
  as the mirror boundary: on a symlinked destination rsync replaces the link and
  leaves the external target alone, and a harness case asserts that difference
  rather than assuming the engines agree.
- **The intended behaviour change**: on a host without rsync the install now
  completes end to end. That is the Q19 defect fully removed, and it is the first
  step at which the installer works on the Debian target.
- **A deliberate behaviour change for the fallback**: a FIFO or symlinked root
  file destination now fails at exit 7 where the rsync path returns 0. On the
  symlink shape the alternative was overwriting an external file and reporting
  success, so the refusal is the safe direction.

No existing feature or reporting capability appears impaired.

---

## Step 4. Failure contract and published documentation

### Analysis of Step 4 implementation state

Not started. Step 4 is not implemented because the fatal messages and the wiki
reference still name rsync rather than the operation, and no host-tool contract
is recorded anywhere.

### Goal for Step 4

Reword the two fatal messages and the wiki entries in terms of the operation
while keeping exit codes 5 and 7, record the audited host-tool contract in four
groups with the inventory method beside it, and correct the script header.

### Step 4 improvement expectations

- Exit codes keep their numbers, so no downstream caller changes.
- A reader can validate a candidate agent image against a written list that
  includes `gzip`, which no command position names.
- The inventory method is recorded, so a future re-audit covers subprocesses
  implied by command options rather than only command-position tokens.

### What was implemented for Step 4

_(empty — no check has taken place yet.)_.

### New helpers or cases introduced for Step 4

_(empty — no check has taken place yet.)_.

### Architecture check for Step 4

_(empty — no check has taken place yet.)_.

### Cost and timing check for Step 4

_(empty — no check has taken place yet.)_.

### Harness case check for Step 4

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 4

_(empty — no check has taken place yet.)_.

---

## Step 5. Acceptance on both targets

### Analysis of Step 5 implementation state

Not started. Step 5 is not implemented because no acceptance run has taken place
and no equivalence comparison exists.

### Goal for Step 5

Run the design's acceptance table end to end on both supported targets,
including the two-engine equivalence comparison over the recorded manifest, and
retain the output as evidence.

### Step 5 improvement expectations

- Every acceptance row passes on the target where the design marks it required.
- The equivalence comparison is retained in full rather than reduced to a pass
  or fail verdict.
- The forced-fallback run on RHEL uses a disposable prefix, never a live
  deployment prefix.
- The downstream shim removal is recorded as tracked elsewhere, not closed here.

### What was implemented for Step 5

_(empty — no check has taken place yet.)_.

### New helpers or cases introduced for Step 5

_(empty — no check has taken place yet.)_.

### Architecture check for Step 5

_(empty — no check has taken place yet.)_.

### Cost and timing check for Step 5

_(empty — no check has taken place yet.)_.

### Harness case check for Step 5

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 5

_(empty — no check has taken place yet.)_.
