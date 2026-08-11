# v0.27.0 rsync-cp-fallback implementation tracking and validation

No, it is not implemented.

This document tracks the implementation of
[plan.v0.27.0.rsync-cp-fallback.md](plan.v0.27.0.rsync-cp-fallback.md), six
steps that give `install_pkg.sh` a second copy engine without changing the rsync
path. Nothing has been implemented yet: this is the initial skeleton written
alongside the plan, before any code change and before any check.

> Initial-skeleton note: every per-step section other than `Goal` and
> `improvement expectations` carries the literal placeholder
> `_(empty — no check has taken place yet.)_.` until an implementation check
> replaces it.
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

Not started. Step 0 is not implemented because no verification harness exists in
this repository yet, and no case has been run against the current installer.

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
- Each case declares the installer and archive it intends to exercise, and the
  harness asserts the resolved identities against those declarations before
  running.
- The negative controls fail as designed and for the right reason: an exit-only
  substitute that changes no state, a wrong-archive substitute that fails the
  archive-identity assertion, and a wrong-installer substitute that fails the
  installer-identity assertion.
- The encoder control survives intact, guarding the hex encoding against the
  digit-deleting defect round 3 review found.
- Every later step has an executable definition of done rather than a written
  one.

### What was implemented for Step 0

_(empty — no check has taken place yet.)_.

### New helpers or cases introduced for Step 0

_(empty — no check has taken place yet.)_.

### Architecture check for Step 0

_(empty — no check has taken place yet.)_.

### Cost and timing check for Step 0

_(empty — no check has taken place yet.)_.

### Harness case check for Step 0

_(empty — no check has taken place yet.)_.

### Feature integrity for Step 0

_(empty — no check has taken place yet.)_.

---

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
