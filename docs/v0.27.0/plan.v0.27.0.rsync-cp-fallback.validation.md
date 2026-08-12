# v0.27.0 rsync-cp-fallback implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.rsync-cp-fallback.md](plan.v0.27.0.rsync-cp-fallback.md), six
steps that give `install_pkg.sh` a second copy engine without changing the rsync
path. No installer code has changed: `src/setups/env/bin/install_pkg.sh` is
untouched at 505 lines and steps 1 to 5 have not started. Step 0 builds the
harness those steps are judged against, and it is checked below, corrected after
code review round 1 and awaiting regenerated evidence on both targets.

> Skeleton note: every per-step section other than `Goal` and
> `improvement expectations` carries the literal placeholder
> `_(empty — no check has taken place yet.)_.` until an implementation check
> replaces it. Step 0's sections are filled in; steps 1 to 5 are not.
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

Not started. Step 1 is not implemented because both rsync call sites are still
unconditional, nothing resolves an engine, and no trace names one.

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

_(empty — no check has taken place yet.)_.

### New helpers or cases introduced for Step 1

_(empty — no check has taken place yet.)_.

### Architecture check for Step 1

_(empty — no check has taken place yet.)_.

### Cost and timing check for Step 1

_(empty — no check has taken place yet.)_.

### Harness case check for Step 1

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 1

_(empty — no check has taken place yet.)_.

---

## Step 2. Mirror fallback with its destination boundary

### Analysis of Step 2 implementation state

Not started. Step 2 is not implemented because mirror mode still calls
`rsync -av --delete` unconditionally and no destination boundary exists.

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

_(empty — no check has taken place yet.)_.

### New helpers or cases introduced for Step 2

_(empty — no check has taken place yet.)_.

### Architecture check for Step 2

_(empty — no check has taken place yet.)_.

### Cost and timing check for Step 2

_(empty — no check has taken place yet.)_.

### Harness case check for Step 2

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 2

_(empty — no check has taken place yet.)_.

---

## Step 3. Root-file fallback with its non-following preflight

### Analysis of Step 3 implementation state

Not started. Step 3 is not implemented because the root-file loop still calls
`rsync -av` unconditionally, with no preflight and no copy-form flag.

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

_(empty — no check has taken place yet.)_.

### New helpers or cases introduced for Step 3

_(empty — no check has taken place yet.)_.

### Architecture check for Step 3

_(empty — no check has taken place yet.)_.

### Cost and timing check for Step 3

_(empty — no check has taken place yet.)_.

### Harness case check for Step 3

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 3

_(empty — no check has taken place yet.)_.

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
