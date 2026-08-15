# v0.27.0 rsync-cp-fallback implementation plan -- one installer, two copy engines

`install_pkg.sh` gains a second copy engine, selected once per run, so a
relocation succeeds on a host without `rsync` while the rsync path stays exactly
as it is.

- **One decision, two independent paths**: the engine verdict is computed and
  announced before archive discovery, and the mirror and the root-file deploy
  consume it separately, each keeping its own boundary and its own fatal code.
- **Boundaries before destruction**: the mirror checks its destination before
  emptying it, and the root-file deploy checks its destination before copying,
  both without following symlinks.
- **Documentation is part of the change**: the published exit codes stop naming
  rsync, and the audited host-tool contract is recorded with the method that
  produced it.

> Markdown lint note: never leave a space immediately inside an inline code span
> (MD038); when a snippet starts or ends with a space, write that space as the
> literal token `[space]`, as in `` `[space]${x}` ``. End any line that would be
> only italic text with a period after the closing underscore (MD036).

## How this plan departs from the standard template, and why

This repository is Bash and Batch. It has **no Python package, no `pytest`, no
`tests/` tree, no `pyproject.toml`, no `check.bat` and no `GROUNDHOG.md`**,
which was verified by inspection before writing this plan. The template's
Python machinery is therefore not adapted here, it is replaced, and the
substitutions are named so no reader expects the missing pieces:

- **No `ghog day` loop and no `ghog single`.** Groundhog is not installed in
  this repository. The shared gate is the verification harness defined below,
  run on both supported targets.
- **No pytest test files, no `__init__.py`, no coverage percentage.** The unit
  of verification is a shell probe over a scratch prefix, of the same shape as
  the retained `measurements.*.txt` runs, which are the precedent this repository
  already has for proving installer behaviour.
- **No line-budget ceiling adopted.** The 650-line policy is stated for Python
  files and there are none in scope. `install_pkg.sh` is 505 lines today; this
  plan records its count per step and treats unexpected growth as a review
  signal. No numeric ceiling is borrowed, and no split is prescribed: the
  script must stay runnable standalone beside an archive, which a sourced
  companion would break.
- **Step 0 is a calibrated watchdog plus a baseline capture, rather than a
  `pytest.mark.timeout` xfail.** The design carries one time-sensitive
  obligation, that a FIFO destination must be refused promptly, and M2 measured
  the plain copy blocking for twenty seconds. The watchdog that detects such a
  block is proved on a deliberate blocker; the installer case captures the
  current installer's real failure instead.

## Plan goal for v0.27.0 rsync-cp-fallback

Implement the design in
[design.v0.27.0.rsync-cp-fallback.md](design.v0.27.0.rsync-cp-fallback.md),
whose seven decisions are settled in its "Design decisions" table, and the
requirement in
[issue.v0.27.0.rsync-cp-fallback.md](issue.v0.27.0.rsync-cp-fallback.md).

- **Step 0 goal**: a verification harness whose oracles are calibrated, whose
  watchdog is proved on a deliberate blocker, and which records the current
  installer's real baseline failures, so every later step has an executable
  definition of done.
- **Step 1 goal**: engine selection, the validation override, and the
  once-per-run trace, before archive discovery.
- **Step 2 goal**: the mirror fallback, with its destination boundary and the
  load-bearing `src/.` copy form.
- **Step 3 goal**: the root-file deploy fallback, with its non-following
  preflight and `--remove-destination`.
- **Step 4 goal**: the published documentation, the wiki reference with the
  host-tool contract and its inventory method, and the corrected script header.
  The two fatal messages are not here: Q04-4C folds each into the step that
  creates its engine branch, so exit 5 is reworded in Step 2 and exit 7 in
  Step 3.
- **Step 5 goal**: acceptance across the target matrix (D-fb, R-rs, R-fb),
  including the two-engine equivalence run from a fresh prefix each, with the
  evidence retained.

---

## Scope anchors for the v0.27.0 rsync-cp-fallback plan

1. A relocation completes on a host with no `rsync`, with no external shim and
   no change to the published exit contract.
2. The rsync invocation, its own per-entry output, its semantics, its exit codes
   and the tree it produces are unchanged; only surrounding diagnostics are new.
3. The two engines are shown equivalent on the design's manifest, each
   installing into a fresh prefix, with the comparison output retained. Over a
   populated prefix they are measured to diverge for surviving entries, which
   the requirement and design now scope explicitly.

Explicitly **in scope**:

- One engine verdict per run, consumed by two independent transfer paths.
- The mirror fallback: destination boundary, then empty, then `cp -a src/. dst/`.
- The root-file fallback: non-following preflight, then
  `cp -a --remove-destination src prefix/name`.
- `CPLX_INSTALL_PKG_FORCE_CP=1`, exact value only.
- Operation-named fatal messages behind unchanged exit codes 5 and 7.
- The wiki host-tool contract with its inventory method, and the script header.

Explicitly **deferred**, carried from the design:

- Every concurrent replacement of a destination, for both the mirror and the
  root-file step.
- A shipped tree comparator; the equivalence recipe lives in the validation plan.
- Hardening the rsync mirror against symlink-to-directory destinations, which is
  the umbrella follow-up raised by requirement 1.

---

## Cost and IO clarification for v0.27.0 rsync-cp-fallback

The installer is a batch, one-shot process, so there is no hot loop and no
response path. The bounds that matter are different in kind and are stated as
such rather than borrowed:

- **No added traversal.** The fallback copies the tree once. The plan adds no
  per-entry loop over the deployed tree, and in particular adds no entry counts,
  which the design rejected for exactly this reason.
- **Constant work per destination.** The mirror boundary observes one path; the
  root-file preflight observes one path per archive root file. Neither walks a
  tree. The exact number of filesystem calls depends on the shell construct that
  implements a non-following type check, which this plan deliberately leaves to
  implementation, so the promise is constant per destination rather than a
  syscall count.
- **No new process per entry.** The fallback runs one `cp` per transfer site,
  not one per file.
- **The rsync transfer operation adds nothing.** The `rsync -av` invocations
  gain no filesystem call they did not already make. The run as a whole does add
  one path lookup, since engine detection resolves `rsync` once even when rsync
  is selected, and the engine line is emitted once before archive discovery.

---

## Confirmed technical facts for plan viability

From direct inspection of the current tree.

**Files in scope, with current line counts** (the 650-line policy is stated for
Python files; there are none here, so these are recorded as review signals):

- `src/setups/env/bin/install_pkg.sh`: **505 lines**. All five code steps land
  here. Expected growth is roughly 60 to 90 lines, well under any ceiling.
- `wiki/reference/relocation-tools.md`: **85 lines**, gains the two-engine
  mirror description, the reworded codes and the host-tool contract.
- `wiki/reference/exit-codes.md`: **101 lines**, unchanged in content; it points
  at the relocation table, which is what changes.

**Structural anchors inside `install_pkg.sh`**, which the steps reuse rather
than reorganize:

- lines 17 to 31: `echos` resolution and inline `task`/`info`/`ok`/`warning`/
  `error`/`fatal` fallbacks. The engine trace uses `info`; every new fatal uses
  `fatal`.
- lines 33 to 43: the configuration block, where the engine verdict and the
  override belong.
- line 108 `install_optional_bin_entries`, 127 `fix_home_symlink_targets`, 170
  `fix_text_paths`, 212 `find_patchelf`: the existing helper-function
  convention, which new helpers follow.
- line 441 `# --- 5. Rsync (Mirror Mode) ---` and line 459 `# --- 6. Deploy the
  archive's root-level files ---`: the two call sites, and the section-comment
  style to keep.

**What does not exist yet**:

- Any engine abstraction, any destination-type check, any use of `cp` at all.
- Any test or verification harness in this repository.

**Other facts that shape the plan**:

- **`fix_home_symlink_targets` runs on the mirrored tree at line 457** and only
  sees links the copy preserved, so symlink fidelity is a correctness property
  of step 2, not a cosmetic one.
- **The staging tree survives a failure** and is cleared before the next
  extraction, so the documented recovery for a partial fallback is a rerun.
- **`gzip` is required although never invoked directly**, because `tar -xzf` at
  line 437 filters through it. Step 4 records this in the contract.

---

## Verification harness for v0.27.0 rsync-cp-fallback

This replaces the template's test tree. It is a scratch-prefix probe script,
kept with the effort documents rather than shipped in the archive, because the
design rejects shipping a comparator.

- `docs/v0.27.0/verify.install-pkg.sh` (new, to be created): builds a scratch
  prefix, plants each destination shape, runs the installer, and reports one
  line per case. It is written once in Step 0 and extended per step.
**Its tool set, declared in full.** Round 2 review caught the earlier claim that
the harness needs only the installer's contract plus `timeout`, which the
acceptance step contradicts. Most of what the harness uses is already inside the
installer's audited set: `find`, `sort`, `od`, `tr`, `sed`, `grep`, `rm`,
`mkdir`, `ln`, `cut`, `head`, plus shell builtins. Five commands are
verification-only additions, used by the harness and never by the installer:

| Command | Used for |
| --- | --- |
| `timeout` | the watchdog that turns a block into a reported failure |
| `stat` | size, mode, mtime, uid and gid in the manifest. Fractional-second mtime is confirmed on the RHEL 9.8 target (coreutils 8.32, xfs) and retained as `measurements.manifest-forms.rhel.txt`; the preflight still asserts it per target, since the Debian agent has not been probed |
| `sha256sum` | the regular-file content digest in the manifest |
| `diff` | the manifest comparison |
| `mkfifo` | planting the FIFO destination fixtures |

The harness preflights all five on each target before running any case, and
fails with a clear message naming the missing command rather than part way
through a run. The sanitization scan deliberately uses `sed` and `grep` only, so
it adds nothing to this list.

- Each run writes `docs/v0.27.0/verify.<step>.<target>.txt`, retained as
  evidence in the same way the `measurements.*.txt` outputs are.

---

## Executable target matrix for all v0.27.0 rsync-cp-fallback steps

"Both engines on both targets" is not executable, because the Debian agent has
no rsync at all. Three combinations exist, and every step's cases name which of
them they run on:

| Combination | Host | Engine | How it is selected |
| --- | --- | --- | --- |
| D-fb | Debian 12 CI agent | fallback | rsync absent, so selection is automatic |
| R-rs | RHEL 9.8 | rsync | the normal path, no override |
| R-fb | RHEL 9.8 | fallback | `CPLX_INSTALL_PKG_FORCE_CP=1`, disposable prefix only |

There is no Debian rsync combination and none can be constructed, which is the
Q19 defect itself. So a case that must compare engines runs R-rs against R-fb,
and a case that must prove the fallback on a foreign distribution runs D-fb. The
equivalence comparison is R-rs against R-fb, each into a fresh prefix.

## Shared execution checklist for all v0.27.0 rsync-cp-fallback steps

Apply for every numbered step, substituting the step's cases.

1. Count lines before the edit: `wc -l src/setups/env/bin/install_pkg.sh`.
2. Extend the harness with the step's cases **before** editing the installer,
   and run it to see the new cases fail.
3. Apply the installer edit.
4. Re-run the harness on the combinations the step names, from the target
   matrix above: D-fb, R-rs, R-fb.
5. Run the step grep checks.
6. Count lines after: `wc -l src/setups/env/bin/install_pkg.sh`, and record the
   delta.
7. Scan the harness output before it becomes committable, driving the scan from
   the repository's own rule file so no protected term is written into this
   plan. The mapping lines have the form `regex:<pattern>==><replacement>`. The
   gate fails closed: an extraction that produces nothing is an error, not a
   pass, and it uses no temporary file, so there is nothing to collide with.

   ```sh
   if ! patterns=$(sed -n '/^regex:/{s/^regex://;s/^(?i)//;s/==>.*$//;p}' \
     a.sensitive.replacements.effective.local.txt); then
     echo "sanitization gate: rule-file extraction failed" >&2
     exit 2
   fi
   if [ -z "$patterns" ]; then
     echo "sanitization gate: no patterns extracted from the rule file" >&2
     exit 2
   fi
   printf '%s\n' "$patterns" | grep -Eril -f - docs/v0.27.0/
   case $? in
     0) echo "sanitization gate: protected term found, substitute and re-run" >&2
        exit 1 ;;
     1) echo "sanitization gate: clean" ;;
     *) echo "sanitization gate: grep failed" >&2
        exit 2 ;;
   esac
   ```

   The three grep statuses are handled explicitly rather than left to prose: 0
   means a term was found and retention is refused, 1 is the only clean result,
   and anything above 1 is a scanner error that must not be read as clean. An
   empty pattern set would make grep return 1 and look clean, which is why the
   extraction is asserted first.
8. Only after that clean result, retain the output as
   `docs/v0.27.0/verify.<step>.<target>.txt` and commit it.

## Ready-to-run commands for all v0.27.0 rsync-cp-fallback steps

- Line count: `wc -l src/setups/env/bin/install_pkg.sh`
- Harness, one target: `bash docs/v0.27.0/verify.install-pkg.sh --step <n>`
- Forced fallback on a host with rsync:
  `CPLX_INSTALL_PKG_FORCE_CP=1 bash docs/v0.27.0/verify.install-pkg.sh --step <n>`
- Syntax gate: `bash -n src/setups/env/bin/install_pkg.sh`
- Grep check that the rsync path is untouched:
  `rg -n 'rsync -av' src/setups/env/bin/install_pkg.sh`

There is no repository gate to run beyond these; see the departures section.

---

## Implementation decisions for v0.27.0 rsync-cp-fallback

Settled across six plan review rounds (2026-08-11), recorded in
[the review transcript](review.plan.v0.27.0.rsync-cp-fallback.md). Two rows,
Q05 and Q07, changed direction during review; both say so, because the reason is
part of the decision.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | The verification harness lives at `docs/v0.27.0/verify.install-pkg.sh`, effort-local, beside the evidence it produces | Verification harness section; Step 0 files | A repository-level `tests/` tree, rejected because the collection's smallest item should not found the repository's test layout; `src/setups/env/bin/`, disqualified by packaging, since `pkg.sh` builds the archive from that directory and the harness would ship to every deployment target |
| Q02 | A synthetic archive for Steps 0 to 4, the real published archive for Step 5 acceptance | Verification harness section; Step 0 and Step 5 cases | A real archive throughout, rejected because the per-step cases would then need a large archive present and would stop being run; synthetic throughout, rejected because the acceptance would never exercise the real link structure the loader depends on |
| Q03 | One helper per transfer site, following the file's existing convention at lines 108, 127, 170 and 212 | Step 2 and Step 3 implementation | Inline branches at both call sites, rejected because the mirror's boundary rule would sit textually beside the deploy path that must never use it; one helper with a mode argument, rejected as recreating the shared abstraction the design's Q01 declined |
| Q04 | Each fatal message folds into the step that creates its engine branch: exit 5 in Step 2, exit 7 in Step 3. The wiki inventory is written once in Step 4 from the finished state | Step 2 and Step 3 message-rewording subsections; Step 4 | Keeping all documentation in Step 4, rejected because an intermediate commit would publish a message naming rsync for a step that now runs `cp`; folding everything in, rejected because the host-tool inventory has been written wrong in four successive versions and a partial rewrite per step invites a fifth |
| Q05 | Record `install_pkg.sh` line counts per step and treat unexpected growth as a review signal. No numeric ceiling, no prescribed split | Departures section; per-step line-budget checkpoints; Step 2 split guidance | Adopting the repository's 650-line Python ceiling, **rejected during review after first being chosen**: the split it prescribed, extracting the transfer helpers into a sourced companion, would end the script's standalone operation beside an archive, and a borrowed threshold must not be able to fire a change that removes a delivery property. A tighter Bash-specific ceiling, rejected as manufacturing work |
| Q06 | Retained harness outputs are committed under `docs/v0.27.0/`, gated by a rule-file-driven sanitization command that fails closed | Shared execution checklist, items 7 and 8 | Keeping outputs as ignored `a.*` files, rejected because the acceptance would become a claim again; committing a sanitized summary only, rejected as reintroducing the quoted-but-unretained problem the design had to correct |
| Q07 | Harness oracles are self-calibrating: fixture precondition, declared and asserted installer and archive identity, phase-specific diagnostic with exit code, independent post-state sentinels, plus four negative controls (watchdog, exit-only, wrong-archive, wrong-installer) and an encoder control | Step 0 case contract and negative controls | A generic red-before-green requirement, **rejected on its own failure**: it produced a Step 0 baseline the current installer cannot exhibit, because it says a case must fail without saying how. Reviewing the harness code instead of instrumenting it, rejected as the assurance class this effort has repeatedly found insufficient, though it remains a complement rather than an alternative |

## Numbered steps for v0.27.0 rsync-cp-fallback

### Step 0. Verification harness, calibrated oracles and baseline capture

#### Step 0 -- analysis and intent for the harness

Issues to address:

- The repository has no way to execute a claim about installer behaviour, so
  every later step would otherwise be verified by reading.
- The harness is new code with nothing checking it, so a case that passes
  vacuously, or that exercises the wrong operation, would look like progress.
- One design obligation is time-sensitive: a FIFO destination must be refused
  promptly. M2 measured the plain copy blocking for twenty seconds.

Fix intent:

- Build the harness with a case contract that makes each case prove it ran what
  it claims, calibrate the watchdog on a deliberate blocker, and capture the
  current installer's real failures as the baseline every later step improves on.

Expected outcome:

- The watchdog is demonstrated to detect a real block, on an operation that
  genuinely blocks.
- The current installer's behaviour is recorded per case, as it actually is,
  with no case asserting a result the current installer cannot produce.

Correction carried from round 1 review, recorded because the first version of
this step required an impossible result. It asked the root-file FIFO case to
time out on the current installer. There is no such path: with rsync absent the
installer exits 5 in the mirror phase and never reaches the root-file site, and
with rsync present the root-file step uses rsync, which M2 measured replacing a
FIFO promptly with exit 0. The block belongs to `cp`, which today's installer
never invokes. The watchdog and the installer baseline are therefore separate
duties, as below.

Step framing:

- Design link: "Measurement evidence behind this design", and the acceptance
  cases table.
- Execution checklist reference: "Shared execution checklist for all v0.27.0
  rsync-cp-fallback steps".

#### Step 0 -- implementation for the harness

**Files involved**:

- `docs/v0.27.0/verify.install-pkg.sh` (new, to be created).
- `docs/v0.27.0/verify.step0.<target>.txt` (new, to be created, retained
  baseline).
- `docs/v0.27.0/probe.manifest-forms.sh` (existing, created 2026-08-11) and its
  retained output `measurements.manifest-forms.rhel.txt`: the preflight forms
  and the manifest commands, all passing on the RHEL target. Every C2 and C3
  assertion feeds its exit status, so Step 0 runs it as a gate rather than
  reading its prose.
- `docs/v0.27.0/probe.mtime-engines.sh` and
  `measurements.mtime-engines.rhel.txt`: both engines preserve a fractional
  source mtime through the exact fresh forms, and rsync's quick check skips an
  already-present destination whose size and integer second match. Step 5 does
  not re-derive either.

**Case contract, applied to every case in every step**:

- Verify the fixture precondition before running anything, and fail the case if
  the planted shape is not what it claims to be.
- **Declare and assert the expected identities.** Each case states, before it
  runs, the installer path and the archive path it intends to exercise. After
  resolution and before the run, the harness compares the resolved values
  against those declarations and fails the case on any mismatch, naming which
  identity differed. Recording the identities is not enough: round 2 review was
  right that a recorded value still lets a case exercise the wrong copy and
  pass. The assertion is what makes the record load-bearing.
- Assert a phase-specific diagnostic together with the exit code, so a right
  code from the wrong phase fails.
- Check independent post-state sentinels, not only the exit status: what the
  destination is afterwards, and whether any external target changed.

**Negative controls, run as cases in their own right**:

- Watchdog calibration: a deliberate blocker, a copy onto a FIFO with no reader,
  invoked directly rather than through the installer, must be reported as a
  timeout. This is what proves the timing machinery works.
- An exit-only substitute that returns the expected status while changing no
  state must be reported as a failure. A harness that blesses it is checking
  status alone.
- A wrong-archive substitute must fail **the archive-identity assertion**, and
  its retained output must name that assertion as the reason. This control was
  wrong in the first version, which expected it to fail the fixture
  precondition: the planted destination shape is independent of which archive is
  later selected, so that control would have passed its precondition and proved
  nothing. It exists to exercise the identity evidence, so it must fail on
  identity.
- A wrong-installer substitute, on the same principle: a second copy of the
  script at a different path must fail the installer-identity assertion.
- An encoder control: a name whose hex encoding contains the letters `a`, `c`
  and `e`, which must survive encoding intact. It exists because round 3 review
  found an encoder that deleted exactly those digits, and a manifest corrupted
  that way would still look plausible.

**Baseline capture on the current installer**:

- No-rsync run: exits 5 in the mirror phase. Record the phase, the code and the
  message.
- Root-file FIFO case with rsync present: rsync replaces the FIFO and returns 0.
  Record that. It is the behaviour Step 3 changes for the fallback engine only.
- Root-file symlink-to-regular-file case with rsync present: rsync replaces the
  link, external target untouched. Record it for the same reason.

**Behaviour**:

- The script takes `--step <n>` and runs the cases enabled at that step.
- Each case prints its name, the fixture precondition result, the installer and
  archive identity, the exit code, the phase diagnostic and the post-state
  sentinels.

**Completion criteria**:

- `bash -n docs/v0.27.0/verify.install-pkg.sh` is clean.
- The watchdog calibration case reports a timeout.
- The exit-only substitute fails, the wrong-archive substitute fails the
  archive-identity assertion, the wrong-installer substitute fails the
  installer-identity assertion, and the encoder control survives intact rather
  than collapsing. Each retained line names the assertion that failed.
- The baseline runs on both targets and their output is retained and sanitized.

#### Step 0 -- addendums for the harness

Line-budget checkpoint:

- `src/setups/env/bin/install_pkg.sh`: unchanged at 505; no installer edit in
  this step.
- `docs/v0.27.0/verify.install-pkg.sh`: new; record its count, and keep the case
  contract shared rather than repeated per case.

Time-gated status for Step 0:

- The watchdog calibration case is permanent: it must keep reporting a timeout
  in every later step, since it is what makes a prompt-refusal claim meaningful.
- No installer case asserts a timeout at this step, and none may: the current
  installer has no path that blocks.

### Step 1. Engine selection, override and trace

#### Step 1 -- analysis and intent for engine selection

Issues to address:

- Both rsync calls are unconditional, so a host without rsync dies at exit 5
  after extraction.
- Nothing in the output says which engine ran, so a stand-in shim on `PATH` is
  indistinguishable from a real rsync.

Fix intent:

- Resolve the engine once, before archive discovery, from `command -v rsync` and
  the override, and announce it as a selection.

Expected outcome:

- One `info` line naming the engine, the resolved rsync path when rsync was
  selected, and the forced reason when the override applied.

Step framing:

- Design link: "Engine selection", decisions Q01, Q04 and Q06.
- Execution checklist reference: the shared checklist.

#### Step 1 -- implementation for engine selection

**Files involved**:

- `src/setups/env/bin/install_pkg.sh` (existing, to be updated).
- `docs/v0.27.0/verify.install-pkg.sh` (existing, to be updated).

**Cases first**:

- Engine line present and naming rsync with its resolved path, on a host with
  rsync.
- Engine line naming the fallback on a host without.
- `CPLX_INSTALL_PKG_FORCE_CP=1` selects the fallback and says it was forced.
- `CPLX_INSTALL_PKG_FORCE_CP=0`, `=yes`, `=true` and empty all leave rsync
  selected and report rsync.

**Behaviour**:

- A verdict variable set in the configuration block, near lines 33 to 43.
- Selection: rsync when `command -v rsync` resolves **and** the override is not
  exactly `1`; the fallback otherwise. The override never selects rsync.
- The trace uses `info`, is emitted once, and reports the selection rather than
  an action, since it precedes archive discovery.

**Completion criteria**:

- Harness step 1 cases pass on both targets.
- `rg -n 'command -v rsync' src/setups/env/bin/install_pkg.sh` shows exactly one
  detection site.
- `rg -n 'rsync -av' src/setups/env/bin/install_pkg.sh` still shows the two
  original invocations, unmodified.

#### Step 1 -- addendums for engine selection

Line-budget checkpoint:

- `install_pkg.sh`: before 505; expected +15 to +25 (advisory); repository has no
  Python ceiling to apply, and 650 is far away.

Time-gated status for Step 1:

- None. The FIFO gate stays failing until Step 3.

### Step 2. Mirror fallback with its destination boundary

#### Step 2 -- analysis and intent for the mirror

Issues to address:

- Mirror mode calls `rsync -av --delete` unconditionally at line 454.
- The fallback's delete is recursive, so a destination of the wrong shape is an
  unbounded hazard rather than a wrong tree.

Fix intent:

- Branch the mirror on the verdict. On the fallback path, observe the
  destination without following symlinks, refuse anything that is neither absent
  nor a real directory, then empty and copy.

Expected outcome:

- A fresh install and a redeployment both succeed without rsync, hidden entries
  included, and a wrong-shape destination fails at exit 5 before any deletion.

Step framing:

- Design link: "Mirror semantics", decisions Q02 and Q03.
- Execution checklist reference: the shared checklist.

#### Step 2 -- implementation for the mirror

**Files involved**:

- `src/setups/env/bin/install_pkg.sh` (existing, to be updated).
- `docs/v0.27.0/verify.install-pkg.sh` (existing, to be updated).

**Cases first**:

- Fresh prefix and populated prefix, fallback engine, hidden stale entry removed.
- Destination as a regular file, and as a symlink to a directory: exit 5, nothing
  deleted, symlink target untouched.
- `libgcc_s.so.1` still a symlink after a fallback install.

**Behaviour**:

- A mirror helper following the existing function convention, called from the
  step 5 site so the surrounding `task` line and the `fix_home_symlink_targets`
  call at line 457 are untouched.
- The copy form is `cp -a src/. dst/` and is load-bearing: it gives the transfer
  root the source mode and mtime, and carries hidden entries without `dotglob`.
- The boundary observes with a non-following type test and fatals 5 before the
  delete.

**Message rewording owned by this step** (Q04-4C: each message folds into the
step that creates its engine branch, so no intermediate commit publishes a
message naming rsync for a step that may now run `cp`):

- The exit-5 fatal is reworded to name the mirror step and the engine that
  failed, replacing `Error: Rsync (main) failed.`. The code stays 5.
- A harness case asserts the reworded exit-5 diagnostic on both engines.

**Completion criteria**:

- Harness step 2 cases pass on both targets, and on RHEL with the override.
- `rg -n 'cp -a' src/setups/env/bin/install_pkg.sh` shows the `src/.` form at the
  mirror site.
- `rg -n 'Rsync \(main\)' src/setups/env/bin/install_pkg.sh` returns nothing.
- The rsync grep check still shows both original invocations.

#### Step 2 -- addendums for the mirror

Line-budget checkpoint:

- `install_pkg.sh`: before as left by Step 1; expected +25 to +35 (advisory).

Split guidance:

- None prescribed. A sourced companion would end standalone operation beside an
  archive, which is a delivery property rather than a style preference, so any
  future extraction must first design how standalone delivery survives it.

Time-gated status for Step 2:

- None.

### Step 3. Root-file fallback with its non-following preflight

#### Step 3 -- analysis and intent for the root-file deploy

Issues to address:

- The root-file loop calls `rsync -av` unconditionally at line 469.
- M2 measured two hazards in the fallback engine: `cp -a` follows a symlink to a
  regular file and overwrites an external target returning 0, and blocks on a
  FIFO.

Fix intent:

- Branch the loop on the verdict. On the fallback path, observe the destination
  without following symlinks, accept only an absent destination or a real
  regular file, and copy with `--remove-destination`.

Expected outcome:

- A symlinked destination fails at exit 7 with the external target byte-identical,
  and a FIFO fails promptly instead of blocking.

Step framing:

- Design link: "Root-file deploy", decisions Q05 and Q07.
- Execution checklist reference: the shared checklist.

#### Step 3 -- implementation for the root-file deploy

**Files involved**:

- `src/setups/env/bin/install_pkg.sh` (existing, to be updated).
- `docs/v0.27.0/verify.install-pkg.sh` (existing, to be updated).

**Cases first**:

- `.env` and `.env_` deployed onto an absent destination and onto a real regular
  file.
- Destination as a symlink to a regular file: exit 7, link intact, external
  target byte-identical including mtime.
- Destination as a FIFO, under `timeout 20`: exit 7 promptly, FIFO intact. This
  is the Step 0 gate closing.
- Destination as an empty and a populated directory: exit 7.

**Behaviour**:

- A deploy helper, separate from the mirror helper, with no delete semantics and
  its own fatal 7.
- The preflight uses a non-following type observation. A following test would
  classify a symlink to a regular file as acceptable and reintroduce the
  measured overwrite.
- The copy is `cp -a --remove-destination src prefix/name`. It is static defence
  in depth only, and the plan makes no concurrency claim.
- The loop, its `dotglob nullglob` handling and the following `fix_text_paths`
  call stay as they are.

**Message rewording owned by this step** (Q04-4C, same rule as Step 2):

- The exit-7 fatal is reworded to name the root-file deploy step and the engine
  that failed, replacing `Error: Rsync ($root_file_name) failed.`. The code
  stays 7, and the preflight refusals use it too.
- A harness case asserts the reworded exit-7 diagnostic, and asserts that the
  preflight refusal is distinguishable from a copy failure.

**Completion criteria**:

- Harness step 3 cases pass on both targets. The FIFO case now reaches the
  root-file preflight and returns exit 7 promptly with the FIFO intact, against
  the Step 0 baseline where rsync replaced it with exit 0.
- The watchdog calibration case still reports a timeout, so "promptly" remains a
  claim the harness can actually falsify.
- `rg -n 'remove-destination' src/setups/env/bin/install_pkg.sh` shows the
  selected spelling at the deploy site only.
- `rg -n 'Rsync \(' src/setups/env/bin/install_pkg.sh` returns nothing.

#### Step 3 -- addendums for the root-file deploy

Line-budget checkpoint:

- `install_pkg.sh`: before as left by Step 2; expected +20 to +30 (advisory).

Time-gated status for Step 3:

- The Step 0 installer baseline is superseded here for the fallback engine: the
  FIFO case moves from "rsync replaces it, exit 0" to "preflight refuses it,
  exit 7, promptly". The watchdog calibration case is untouched and must keep
  reporting a timeout.

### Step 4. Failure contract and published documentation

#### Step 4 -- analysis and intent for the contract

Issues to address:

- The wiki publishes exit 5 and 7 as "main rsync failed" and "root file deploy
  failed", naming the engine rather than the operation. The in-script messages
  are already corrected, in Steps 2 and 3.
- The script header claims the installer needs only the archive, itself and the
  shipped patchelf, which is false, and no audited host-tool contract exists.

Fix intent:

- Reword the wiki entries in terms of the operation, and record the contract
  with the method that produced it, written once from the finished state rather
  than amended per step.

Expected outcome:

- The published codes keep their numbers and gain accurate names, and a reader
  can validate a candidate agent image against a written list.

Step framing:

- Design link: "Failure and diagnostic contract" and "Documented contract",
  decision Q04 for the override row.
- Execution checklist reference: the shared checklist.

#### Step 4 -- implementation for the contract

**Files involved**:

- `src/setups/env/bin/install_pkg.sh` (existing, to be updated, header comment
  only; the two fatal messages were reworded in Steps 2 and 3).
- `wiki/reference/relocation-tools.md` (existing, to be updated).

**Cases first**:

- The Step 2 and Step 3 message cases still pass unchanged, since this step does
  not touch them.

**Behaviour**:

- The wiki gains: the mirror described as a mirror with two engines; codes 5 and
  7 named for the mirror and root-file deploy; the host-tool contract in four
  groups, Bash and its builtins, the mandatory external programs including
  `gzip` and `cp`, the optional rsync, the shipped patchelf; and the inventory
  method, covering command-position tokens and the subprocesses that command
  options start.
- The header points at the recorded contract instead of implying nothing else is
  needed.

**Completion criteria**:

- `rg -n 'Rsync \(' src/setups/env/bin/install_pkg.sh` returns nothing, which
  Steps 2 and 3 already achieved; this step must not regress it.
- `rg -n 'gzip' wiki/reference/relocation-tools.md` shows the contract entry.
- The wiki no longer names rsync in the code 5 and 7 rows.
- Exit codes unchanged: the harness still observes 5 and 7.

#### Step 4 -- addendums for the contract

Line-budget checkpoint:

- `install_pkg.sh`: before as left by Step 3; expected +0 to +5 (advisory).
- `wiki/reference/relocation-tools.md`: before 85; expected +30 to +45.

Time-gated status for Step 4:

- None.

### Step 5. Acceptance across the target matrix

#### Step 5 -- analysis and intent for acceptance

Issues to address:

- Nothing yet proves the two engines produce the same tree from a fresh prefix
  each, which is the third scope outcome as the amended requirement and design
  now state it.
- The equivalence must be proved once, with its output retained, and no
  comparator may be shipped.

Fix intent:

- Run the full acceptance set on both targets, including the two-engine
  comparison over the design's manifest, and retain the evidence.

Expected outcome:

- Every acceptance case in the design's table passes, and the comparison output
  is on disk beside the measurements.

Step framing:

- Design link: the acceptance cases table and "Equivalence and validation model".
- Execution checklist reference: the shared checklist, plus the recipe in the
  validation plan.

#### Step 5 -- implementation for acceptance

**Files involved**:

- `docs/v0.27.0/verify.install-pkg.sh` (existing, to be updated).
- `docs/v0.27.0/verify.acceptance.<target>.txt` (new, to be created, retained
  evidence).

**Cases first**:

- The full acceptance table, run end to end rather than per step.
- The equivalence run: install once per engine into two **fresh** scratch
  prefixes from the same archive, then compare with the recipe in the validation
  plan, transfer root included, canary links checked explicitly. Fresh is a
  condition rather than a convenience: `measurements.mtime-engines.rhel.txt`
  shows rsync's default quick check skipping an already-present destination
  whose size and integer second match, which the fallback cannot do because it
  empties first. Two fresh prefixes is the case the equivalence claim covers, and
  the case in which both engines were measured to preserve mtime to the
  nanosecond.
- The loader check: the shipped loader lists the python ELF and the toolchain
  libraries with no `not found` line the rsync tree did not already have.

**Behaviour**:

- Acceptance is an integration run: a real archive, a real relocation, on the
  executable target matrix above rather than a loose "both engines, both
  targets". The forced-fallback run on RHEL uses a disposable test
  prefix, never a live deployment prefix.

**Completion criteria**:

- Every acceptance row passes on the target where the design marks it required.
- The comparison output is retained rather than reduced to a verdict.
- The consuming project can drop its shim once it runs an installer carrying
  this fix; that half is tracked downstream and is not closed here.

#### Step 5 -- addendums for acceptance

Line-budget checkpoint:

- No installer change in this step; record the final `wc -l` for the record.

Time-gated status for Step 5:

- The FIFO case stays in the acceptance set as a permanent bounded check.
