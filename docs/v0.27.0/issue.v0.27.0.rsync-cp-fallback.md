# Install without the host rsync

- Type: issue
- Version: v0.27.0
- Slug: `rsync-cp-fallback`
- Umbrella: [docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md](draft.v0.27.0.debian-agent-tools.md)
- Draft: [docs/v0.27.0/draft.v0.27.0.rsync-cp-fallback.md](draft.v0.27.0.rsync-cp-fallback.md)
- Environments: [reference.environments.md](reference.environments.md)

## What Q19 blocks today

`install_pkg.sh` is the entry point of the relocation: it unpacks a
`tools.*.tar.gz` on a bare account and makes the tree self-contained
there. It has to run before anything is installed, so everything it
calls must already exist on the target. What it needs, audited over the
whole script and split by kind rather than lumped into one list:

- **The Bash language and its builtins.** The interpreter is
  `#!/bin/bash`, and the script uses `shopt -s dotglob nullglob`,
  arrays, `[[`, `local`, `source`, `command -v`, `printf`, `echo`, `cd`
  and `exit`. None of these is an external host executable, and none is
  satisfied by a POSIX `sh`.
- **Mandatory external commands, invoked today.** tar, gzip, find, grep,
  sed, xargs, sort, head, cut, od, tr, basename, dirname, readlink, ln,
  rm, mkdir, chmod, touch. `gzip` never appears as a command in the
  script: line 437 runs `tar -xzf "$LATEST_ARCHIVE"`, and GNU tar's `-z`
  filters the archive through the external `gzip` program, which it
  looks up on `PATH` and runs as a subprocess. It is mandatory on a bare
  target all the same, and the extraction is the first thing the
  installer does.
- **Mandatory external command added by this fix.** `cp`. The current
  script never calls it; the fallback introduces it, so it belongs to
  the final-state contract and not to the current-state audit.
- **Optional, preferred when present.** rsync. This is the one entry the
  fix demotes from mandatory to optional.
- **Shipped, not a host tool.** patchelf, resolved by `find_patchelf`
  from the archive first and only then from `PATH`, and skipped with a
  warning when absent.

Several of those calls use GNU extensions rather than the POSIX forms:
`find -printf` (line 393), `grep -rlIZ --exclude-dir` and `xargs -0 -r`
piped into `sed -i` (lines 184 and 185). Every mandatory entry is
present on both supported targets. `rsync` is the single outlier, and it
is the only one the CI agent image does not carry.

The inventory method matters as much as the list, because a target image
is validated against it. It covers two kinds of dependency: the commands
appearing in command position in the script, and the external
subprocesses those commands start because of the options they are given.
A token-only scan finds the first kind and silently misses the second,
which is how `gzip` was absent from the first three versions of this
list. `tar -xzf` is the only such case in this script: it holds one tar
invocation and no other option implying a compressor or an external
filter.

Correcting two earlier claims, because the fix depends on the first.
This document and the child draft first described that set as "all POSIX
baseline", and the umbrella's D4 rationale says the fix "leaves the
installer needing only POSIX tools". That is not accurate: the script is
a Bash script using GNU coreutils and findutils behavior, and the `cp -a`
the fallback uses is itself a GNU and BSD extension rather than POSIX.
The second correction is to the first audit published in this document,
which listed `mv` and `file` as invoked and omitted `od`: `mv` and
`file` appear only in prose and in variable names such as `$file_path`,
while `od -An -tx1` is called at line 308 to read an ELF magic number.
The decision D4 recorded is unaffected, since it chose an in-script copy
fallback over shipping or compiling a binary; only its justification
needs restating. What this issue can promise is the removal of the one
observed host dependency the supported targets do not both satisfy, not
general POSIX portability.

The CI agent is a throwaway Debian 12 container whose image does not
carry that outlier. The very first Jenkins run of the discovery
(`develop#2`, 2026-08-06) died at the mirror phase with exit 5, and the
consuming project has been writing an rsync stand-in on the bootstrap
`PATH` ever since. That stand-in is a plain recursive copy that ignores
every option, and it is exact only because CI installs into a fresh
empty prefix, so it cannot be promoted into the script as it stands.

## CDC revision history for the rsync dependency

- Earlier CDC state (up to v0.26.0): the archive has one consumer, the
  RHEL deployment servers, which are managed hosts carrying rsync. The
  installer may rely on the host toolbox, and the mirror step is
  specified directly in terms of `rsync --delete`, which
  [Packaging and relocation tools](../../wiki/reference/relocation-tools.md)
  records as such.
- Newer CDC state (v0.27.0): the same archive must relocate on two
  distributions, RHEL 9.8 servers and a Debian 12 CI container, and the
  installer must depend only on host tools that both supported targets
  actually carry. The umbrella states it as the host-toolbox gap, and
  [the Jenkins build synthesis](../../../my-project/docs/jenkins_build_synthesis.md)
  as the first of six gaps: the installer needs a binary the target may
  not have.
- The script header already claims the narrower dependency set, saying
  it "only needs the archive, this script, and the patchelf shipped in
  the tools archive". Today that sentence is false, and this issue is
  what makes it true.

## Current behavior in v0.27.0

1. `install_pkg.sh <target>` resolves the installation prefix, finds
   the newest `<target>.*.tar.gz` and extracts it into a staging area
   `$PKG_DIR/$BASE_NAME`.
2. Step 5, mirror mode: it runs `rsync -av --delete "$SOURCE_PATH/"
   "$DEST_PATH/"` from the staging copy of the target folder onto
   `<prefix>/<target>`, then calls `fix_home_symlink_targets` on the
   result.
3. Step 6, root files: for every regular file at the staging root
   (`.env`, `.env_`, and whatever `pkg.sh --add` shipped), it runs
   `rsync -av "$root_file" "$INSTALL_PREFIX/"` and re-anchors the
   deployed copy with `fix_text_paths`.
4. Steps 6b to 6e then clear the bytecode caches, rewrite text paths
   and ELF interpreters and rpaths, and install the convenience
   commands.

Both rsync calls are unconditional: there is no detection, no
alternative engine, and no message naming the engine actually used. The
only trace is the task line `Syncing to <dest> (Mirror Mode)...`, which
does not say what performs the sync.

## Current side effects in v0.27.0 for the missing rsync

- On a host without rsync, the mirror call fails with `rsync: command
  not found` and the script fatals `Error: Rsync (main) failed.` with
  exit 5. The failure lands after extraction, so the staging area is
  left behind and the prefix holds a partial tree.
- The root-file loop would fatal the same way with exit 7 and the
  message `Error: Rsync ($root_file_name) failed.`, which never shows
  in practice because exit 5 comes first.
- Both codes are published as rsync-specific in the wiki reference
  (`5` as "main rsync failed", `7` as "root file deploy failed"), and
  [Exit codes and fatal conditions](../../wiki/reference/exit-codes.md)
  points at that table, so the documented contract names the engine
  rather than the operation.
- The consuming project compensates outside cplx, with a shim written
  on the bootstrap `PATH` before the installer is called. That shim is
  a workaround in another repository for a cplx defect, and it silently
  narrows the semantics: options are ignored, so `--delete` does not
  happen, which is invisible only because the CI prefix starts empty.
- The RHEL side shows nothing at all, since those servers carry rsync.
  The gap is not latent there, it is genuinely absent, and the risk
  moves into the fix instead: a fallback that got the mirror semantics
  or the link handling wrong would break redeployments on production
  while CI stayed green.

## CDC wording and gap analysis for the installer bootstrap

The CDC now asks for an installer that runs on a bare account of either
supported target using only host tools both of them carry. Five concrete
gaps separate that from the current script.

- **No detection.** The script calls `rsync` unconditionally instead of
  probing for it once and choosing an engine.
- **No fallback.** There is no code path that mirrors a tree without
  rsync, and the external shim that stands in for it does not
  reproduce `--delete`, so it cannot be adopted as written.
- **No engine trace.** Nothing in the output says which engine ran, so
  a support reading of an install log cannot tell a native rsync mirror
  from a fallback one, which matters the day the two trees are compared.
- **Engine-named contract.** The wiki reference and the fatal messages
  describe the step as rsync rather than as a mirror, so the
  documentation stops matching the script the moment a second engine
  exists.
- **No destination boundary.** rsync is given `"$DEST_PATH/"` and
  decides for itself what to do with an existing entry of the wrong
  kind. A fallback that deletes before copying has to answer that
  question explicitly, because the delete is recursive and the
  destination could be a file, a dangling entry, or a symlink pointing
  somewhere else entirely.

One property that was implicit becomes load-bearing and must be stated,
because the runtime closure depends on it. The mirrored tree is not a
bag of regular files: the loader searches the SONAME `libgcc_s.so.1`
while the real file is `libgcc_s-11-20240719.so.1`, so a symlink
carries that lookup, and a directory named on the toolchain rpath can
itself be a link, as `root/lib64` is onto `usr/lib64` (measured by the
consuming project's `develop#24` probe on 2026-08-08). A copy engine
that dereferenced links would replace each link with its target,
doubling the tree and turning one physical library into several that
the later relocation pass would then patch separately. One that dropped
links would leave the SONAME unresolvable, and the loader would fetch
the host copy instead, which is the mixed-runtime failure class this
whole collection exists to remove, arriving through the installer
rather than through the archive. `fix_home_symlink_targets` runs on the
mirrored tree immediately after the copy and only sees links that the
copy kept as links, which is the second reason the property cannot be
left to chance.

## Confirmed rule for `rsync-cp-fallback`

- Decision D4 is settled on the in-script `cp` fallback. Shipping an
  rsync payload in the archive is rejected: it would drag `libpopt`,
  `libzstd`, `liblz4` and `libcrypto` onto a foreign distribution, the
  same failure class as the mixed runtime resolution already met with
  `libgcc_s` and `libstdc++`. Compiling rsync inside cplx is impossible
  for this purpose, since a cplx-built binary carries a
  `/home/<builder>` interpreter and rsync must run before the pass that
  repairs it. Asking the CICD team to add rsync and procps to the agent
  image stays a parallel, non-blocking track.
- Detect rsync once, with `command -v`, and reuse that verdict for both
  call sites.
- Prefer rsync whenever it is present, so the RHEL build account and
  the deployment servers keep a byte-identical path.
- Fall back only on absence, never on failure: an rsync that exists and
  returns non-zero still fatals with exit 5 or 7, unchanged. A silent
  retry with another engine would hide a real error.
- One validation override, and it is a test surface rather than an
  operating mode: an environment variable, set to an explicit
  affirmative value, forces the fallback on a host that has rsync. It
  exists because two acceptance criteria cannot otherwise be run, the
  redeployment reproducing `--delete` and the two-engine comparison, and
  because the installer is invoked by wrapper scripts (the consuming
  project's `deploy_pkgs.sh`, the Jenkins stages) where hiding rsync
  from `PATH` is not practical. A variable reaches those callers without
  editing them, where a command-line flag would have to be threaded
  through each one. Normal operation still prefers a resolved rsync, the
  engine trace states that the fallback was forced, and the override is
  never a licence to run the non-atomic path against a live deployment
  prefix: forced runs use a disposable test prefix.
- Mirror-mode fallback: empty the destination content, not the
  destination directory, then copy the source content with `cp -a`.
  That reproduces `--delete` for the whole-tree case this script
  actually uses.
- Destination boundary, checked immediately before any deletion: the
  fallback accepts an absent destination, which it creates, or a real
  directory, whose content it empties. Anything else, a regular file, a
  special file, or a symlink of any kind, fails the mirror step with
  exit 5 before a single entry is removed. The delete operates on the
  destination path the installer derived from its own arguments, and
  does not traverse a destination observed as a symlink. The guarantee
  is scoped to that observation: an ordinary check followed by a
  recursive delete is not race-free, and concurrent replacement of
  `<prefix>/<target>` between the check and the delete is outside this
  issue, unless the design chooses a race-resistant deletion technique.
- Root-file fallback: plain `cp -a` of the file into the prefix.
- The fallback is not atomic, and that is accepted rather than hidden: a
  failure between the delete and the end of the copy leaves a partial
  destination. The staging tree is still present when that happens, the
  next run removes an old staging directory before extracting, and the
  recovery is to rerun the install from the same archive.
- Log which engine runs, once per install and before the copy starts,
  through the existing `echos` helpers the script already resolves or
  defines. The line names the selected engine, the resolved binary path
  when rsync was selected, and the reason when the fallback was forced.
  The rsync path keeps its existing `rsync -av` invocation, its own
  per-entry output, its copy semantics and its exit codes unchanged; the
  install's complete output does change, since the engine line and the
  operation-named error text are new. The fallback path is not required
  to print per-file output or entry counts, since the evidence that a
  mirror succeeded is the command status plus the equivalence
  comparison.
- Keep exit codes 5 and 7 for the two steps whichever engine ran, so
  the published contract does not move, and reword their messages and
  the wiki entry in terms of the operation rather than of rsync.
- The two engines must produce the same tree **when each installs into a
  fresh prefix**, compared entry by entry over relative path, entry type,
  regular-file bytes, mode, mtime and symlink target. Ownership is the
  installing account and is either the same on both runs or normalized
  when the two validations use different accounts. Hard-link topology is
  the permitted divergence, since `cp -a` preserves hard links while
  `rsync -a` expands them into copies unless given `-H`.
- Amended 2026-08-11 on measurement, recorded in
  `measurements.mtime-engines.rhel.txt`. This rule first said "the same
  tree" without qualification, written before the evidence existed. On a
  fresh prefix the parity is exact, including mtime to the nanosecond,
  which the measurement confirms for both engines through the forms this
  issue selects. Over a **populated** prefix it is not: rsync's default
  quick check (`--modify-window=0`) skips an already-present destination
  whose size and integer-second mtime match the source, leaving that
  entry as it was, while the fallback empties the destination first and
  therefore always rewrites it. That is standard, documented, unchanged
  rsync behaviour on a path this issue does not touch, so it is a
  boundary on the parity claim rather than a defect to fix here.
- Amended 2026-08-14 on measurement, recorded in
  `verify.acceptance.rhel.txt` and its three retained manifests. The
  parity above is a claim about the copy **forms**, which is what
  `measurements.mtime-engines.rhel.txt` measured, and it holds. It does
  not transfer unchanged to a finished **install**, because the installer
  rewrites part of the tree after the copy: the text path fix, the ELF
  fix and the `__pycache__` clear all write files whose mtime is then the
  time of that run rather than anything the copy produced. Measured on
  the published archive, 30073 of 30665 entries are identical across the
  engines on every recorded field including mtime to the nanosecond. The
  unchanged same-engine control defines the run-variant set: 592 paths
  whose mtimes differ between two fresh rsync installs. In the retained
  measurement that is the same set whose mtimes differ between engines;
  independent inspection attributes those paths to the post-copy passes.
  Their mtimes fall in disjoint per-run windows, 84 seconds wide under
  rsync and 73 under the fallback. For those 592 the guarantee is stated
  behaviourally: the same entries exist under both engines, with the same
  type, size, mode, ownership, content digest and link target, and each
  carries an mtime written during its own install. Exact mtime equality
  there is not achievable across two separate runs of the current
  installer without adding timestamp normalization. That normalization
  is rejected because it would change installed metadata solely for a
  one-off parity proof rather than preserve copy-engine behaviour.
- What a redeployment over a populated prefix must still guarantee is
  stated behaviourally rather than as parity, and is unchanged: the
  fallback removes what the new tree no longer carries, hidden entries
  included, matching what `--delete` did. That guarantee is per engine
  and is not a claim that the two engines agree entry for entry on such a
  prefix.
- ACLs, extended attributes and SELinux labels are outside that parity.
  The archive does not transport them: `pkg.sh` creates the tarball with
  `tar --sort=name ... -cf -` and the installer extracts it with
  `tar -xzf`, neither passing `--acls`, `--xattrs` or `--selinux`, so no
  producer-side metadata is stored or restored. That is not the same as
  the staging tree carrying none: extraction creates files, and a
  created file can pick up a default ACL from its parent directory and a
  destination-local SELinux label from policy. GNU `cp -a` then attempts
  to preserve context and extended attributes, ACLs included where they
  are implemented through xattrs, while `rsync -a` enables neither `-A`
  nor `-X`. The exclusion therefore rests on the existing contract rather
  than on an absence: `rsync -a` has never promised parity for those
  attributes, normal RHEL operation stays on rsync, and what this issue
  validates is runtime behavior of the relocated tree, not metadata
  equality. A future archive that starts transporting metadata reopens
  this exclusion.
- The equivalence is proved once, when the fallback lands, not by a
  shipped tool. The validation plan carries the comparison recipe, exact
  enough to reproduce the manifest above, normalizing the ownership and
  hard-link differences named as permitted, and checking the canary
  links explicitly. Its output is retained as validation evidence rather
  than reduced to a pass or fail verdict. No comparator is shipped: one
  useful on the CI agent would itself have to run inside the host-tool
  contract this issue is about, which is a second version of this work
  rather than a support for it. A permanent archive-content check
  belongs to item 4 of the collection, which answers a different
  question, what the archive carries rather than whether two installs of
  it agree.

## Gap to close in the implementation for `rsync-cp-fallback`

1. Add a single engine detection near the start of the install
   sequence, storing whether rsync is available and whether the
   validation override forced the fallback, and emit one `info` line
   carrying the engine, the resolved path and the forced reason.
2. Replace the mirror call at step 5 with a mirror helper: rsync when
   available, otherwise validate the destination boundary, then create
   the destination if it does not exist (rsync creates it today, `cp`
   does not), remove the destination content including hidden entries,
   then `cp -a` the source content including hidden entries. Copying
   `"$SOURCE_PATH/."` rather than `"$SOURCE_PATH"/*` is what keeps
   hidden entries in without depending on the caller's globbing options.
3. Keep `fix_home_symlink_targets "$DEST_PATH"` running on the result
   of either engine, unchanged.
4. Replace the root-file call at step 6 with a deploy helper: rsync
   when available, otherwise `cp -a` into the prefix. The loop, its
   `dotglob nullglob` handling and the following `fix_text_paths` call
   stay as they are.
5. Preserve the fatal codes and reword the two messages so they name
   the step and the engine that failed, rather than naming rsync
   unconditionally.
6. Update [Packaging and relocation tools](../../wiki/reference/relocation-tools.md)
   so the mirror step is described as a mirror with two engines, so
   codes 5 and 7 read as the mirror and root-file failures rather than
   as rsync failures, and so the host-tool contract is recorded in the
   four groups above: the Bash language and its builtins, the mandatory
   external commands with `gzip` and `cp` among them, the optional
   rsync, and the shipped patchelf. Record the inventory method beside
   the list, so a later re-audit covers the external subprocesses
   implied by command options and not only command-position tokens.
7. Correct the script header, which already promises that the installer
   needs only the archive, itself and the shipped patchelf.

## Concrete examples for the two copy engines

- Debian 12 container, no rsync and no shim on `PATH`, fresh empty
  prefix -> the install logs the `cp` engine, creates
  `<prefix>/tools`, completes, and never reaches exit 5.
- RHEL 9.8 build account, rsync present -> the install logs the rsync
  engine with its resolved path, then runs the same `rsync -av` command
  with the same output and the same resulting tree as in v0.26.0.
- Redeployment over a populated prefix holding `tools/python/stale.so`
  that the new archive no longer carries, `cp` engine -> the file is
  gone after the install, matching what `--delete` did.
- Same redeployment, the stale entry being hidden
  (`tools/python/.stale`) -> also gone, since the emptying covers
  hidden entries.
- rsync present but returning non-zero (unreadable destination, for
  example) -> fatal with exit 5 as today, no fallback attempt.
- Fallback selected and `<prefix>/tools` existing as a regular file, or
  as a symlink to a directory -> fatal with exit 5 before anything is
  deleted, and the symlink target is untouched.
- Fallback interrupted between the delete and the end of the copy ->
  a partial `<prefix>/tools`, the staging directory still present, and
  a rerun of the same command restoring a complete tree.
- `tools/python/root/lib64/libgcc_s.so.1` after a shim-free install ->
  still a symlink onto `libgcc_s-11-20240719.so.1`, not a second copy
  of that file.
- `tools/python/root/lib64` after a shim-free install -> still a link
  onto `usr/lib64`, so the eight rpath directories keep resolving.
- Staging root holding `.env` and `.env_`, `cp` engine -> both land in
  the prefix and are re-anchored by `fix_text_paths`, the step 6 path
  behaving as with rsync.
- CI agent that still writes its stand-in shim -> `command -v rsync`
  finds the shim and the installer prefers it, so removing the shim
  from the pipeline is what actually exercises the new path.

## Code references for `rsync-cp-fallback`

- `src/setups/env/bin/install_pkg.sh` line 454: the mirror-mode call
  `rsync -av --delete "$SOURCE_PATH/" "$DEST_PATH/"`, followed by
  `fatal "Error: Rsync (main) failed." 5`.
- `src/setups/env/bin/install_pkg.sh` line 469: the root-file call
  `rsync -av "$root_file" "$INSTALL_PREFIX/"` inside the
  `dotglob nullglob` loop, followed by
  `fatal "Error: Rsync ($root_file_name) failed." 7`.
- `src/setups/env/bin/install_pkg.sh` lines 17 to 31: the `echos`
  resolution and its inline fallback definitions of `task`, `info`,
  `ok`, `warning`, `error` and `fatal`, which the engine log line uses.
- `src/setups/env/bin/install_pkg.sh` line 457 and the
  `fix_home_symlink_targets` definition at line 127: the symlink
  rewrite that runs on the mirrored tree and depends on links having
  survived the copy.
- `src/setups/env/bin/install_pkg.sh` lines 3 to 12: the header comment
  stating the intended dependency set.
- `wiki/reference/relocation-tools.md`: the mirror step described as
  `rsync --delete`, and codes 5 and 7 named after rsync.
- `wiki/reference/exit-codes.md`: points at that table for the
  `pkg.sh` and `install_pkg.sh` pair.
- `src/setups/env/bin/rsync.sh` and the `.env_user` aliases: an
  unrelated developer helper for syncing the build account, out of
  scope here and not to be confused with the installer call sites.

## Acceptance for `rsync-cp-fallback`

Closable in cplx, on evidence this repository can produce:

- A relocation into a fresh empty prefix succeeds on a Debian 12
  container with no rsync present and no external shim, using a
  standalone fixed installer against the currently published archive.
- A redeployment over a populated prefix removes what the new tree no
  longer carries, hidden entries included, matching what `--delete` did.
  On RHEL this runs with the fallback forced, into a disposable test
  prefix, never a live deployment prefix.
- The run states, before copying, which engine it used, the resolved
  rsync path when rsync was selected, and the forced reason when the
  override selected the fallback.
- With rsync present and no override, the `rsync -av` invocation, its
  own per-entry output, its exit codes and the resulting tree are
  unchanged from v0.26.0. The install's complete output is not, since
  the engine line and the operation-named error text are new.
- The fallback refuses a destination observed as anything other than a
  directory: exit 5 before any deletion, nothing removed, and a
  symlinked destination's target untouched. Concurrent replacement of
  that path between the check and the delete is outside this issue.
- An interrupted fallback leaves a partial destination with the staging
  directory retained, and rerunning the same command produces a complete
  tree.
- The two engines produce equivalent trees **from a fresh prefix each**,
  under the manifest of the confirmed rule. On the same-engine
  run-variant set, all compared fields except mtime agree exactly and
  each mtime lies within its own install window. Hard-link topology is
  the separate manifest omission. Fresh is a condition of the criterion, not a
  convenience: over a populated prefix the engines are measured to
  diverge for surviving entries, per the amendment in the confirmed rule.
  The canary pair is checked explicitly: `libgcc_s.so.1` still a symlink
  onto `libgcc_s-11-20240719.so.1`, and every directory named on the
  toolchain rpath keeping its nature, real directory or link. The
  comparison output is retained as validation evidence rather than
  reported as a verdict.
- The relocated prefix still resolves: the shipped loader lists the
  python ELF and the toolchain libraries with no `not found` line that
  the rsync-produced tree did not already have.
- An rsync that is present and fails still exits 5 or 7 without a
  fallback attempt.

Tracked downstream, not closable here:

- The consuming project deletes its rsync stand-in once its pipeline
  actually runs either a standalone fixed installer or an archive
  containing the fix. Publication alone does not establish that, and
  which of the two delivery routes the pipeline uses today is not
  recorded in the umbrella, the child draft, or the Jenkins build
  synthesis.

## Out of scope for this issue

- Shipping an rsync binary or its payload inside the tools archive,
  rejected by D4.
- Adding rsync and procps to the Jenkins agent image, a CICD-team track
  that stays useful and stays non-blocking.
- The rpath work that makes shipped libraries resolve inside the prefix
  (item 2 of the umbrella): this issue only guarantees that the
  installer does not damage the link structure that work relies on.
- `src/setups/env/bin/rsync.sh`, the developer sync helper, which is a
  different tool with a different purpose.

## Requirement clarifications for `rsync-cp-fallback`

Settled across four specification review rounds (2026-08-08 and
2026-08-09), recorded in
[the review transcript](review.issue.v0.27.0.rsync-cp-fallback.md).

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | The fallback mirror is not atomic, and that is accepted: an interruption between the delete and the end of the copy leaves a partial destination, the staging tree stays available, and the recovery is to rerun from the same archive. The property is general, not limited to forced runs | Confirmed rule (non-atomicity bullet); Concrete examples (interrupted fallback); Acceptance (interrupted run) | A stage-then-swap building beside the tree and renaming into place, rejected because the rsync path keeps in-place semantics and the two engines would stop being the same operation, and because it changes the staging contract `pkg.sh` and `install_pkg.sh` share; refusing the fallback over a populated prefix unless `--force`, rejected because it breaks the redeployment the acceptance requires and overloads a flag that already means something else |
| Q02 | One validation override, an environment variable taking an explicit affirmative value, forces the fallback where rsync exists. It is a test surface, not an operating mode, and forced runs use a disposable test prefix | Confirmed rule (validation override bullet); Acceptance (forced redeployment) | No override, using `PATH` surgery instead, rejected because the installer is invoked by wrapper scripts where that is impractical and because hiding rsync hides it from everything else in the run; a command-line flag, rejected because every intermediate caller, several owned by another repository, would have to thread it through |
| Q03 | The trace is one pre-copy line naming the engine, the resolved binary path when rsync was selected, and the forced reason when the override applied. The rsync path keeps its invocation, its own per-entry output, its semantics and its exit codes; the fallback prints neither per-file output nor entry counts | Confirmed rule (trace bullet); Concrete examples (RHEL run); Acceptance (engine trace, rsync invariance) | Entry counts on the fallback path, rejected because they cost a traversal, are not in D4, and do not prove the copy completed, which the equivalence comparison does; `cp -av` per-file output, rejected as tens of thousands of lines in a CI console; the engine name alone, rejected because it leaves the CI stand-in shim invisible |
| Q04 | Exit codes 5 and 7 stay for both engines, including the Q09 destination refusal. Their messages and the wiki entry are reworded to name the operation rather than rsync | Confirmed rule (exit-code bullet); Gap item 5; Gap item 6 | New codes per engine, rejected because no status-only consumer in the reviewed evidence needs the distinction and every wiki consumer would have to change; a distinct code for the destination-emptying failure, deferred on the same ground, since adding a code later is not a breaking change while renumbering one is |
| Q05 | The claim is split. cplx closes on a standalone fixed installer relocating the existing published archive; the consuming project removes its shim once its pipeline actually runs either that installer or an archive containing the fix | Acceptance (split into closable in cplx and tracked downstream) | Waiting for publication, rejected because it couples the collection's first and most independent item to its last and to a release schedule outside both repositories; asserting an immediate pipeline switch, rejected because the reviewed evidence does not establish which delivery route the pipeline uses |
| Q06 | An audited host-tool contract is recorded in the wiki reference in four groups: the Bash language and its builtins; the mandatory external programs, including `gzip` (started by GNU tar's `-z` at line 437) and `cp` as this fix's addition; the optional rsync; and the shipped patchelf. The inventory method is recorded beside the list, covering command-position tokens and the subprocesses that command options imply | What Q19 blocks today (four groups, inventory method); Gap item 6 | The original POSIX-only claim with its eight-command list, disproved: the script is Bash using GNU `find -printf`, `grep -rlIZ --exclude-dir`, `xargs -0 -r` and `sed -i`, and `cp -a` is itself non-POSIX; a runtime preflight, rejected as a new exit code plus a list that drifts, delivering the answer long after image-selection time; dropping the contract entirely, rejected because it leaves the next target unvalidatable |
| Q07 | The two engines are compared per entry over relative path, entry type, regular-file bytes, mode, mtime and symlink target, with ownership stated or normalized. Comparison is exact except that, on the same-engine run-variant set, every non-mtime field is exact and mtime is bounded to its own install window. Hard-link topology is omitted separately. ACLs, extended attributes and SELinux labels are outside parity because `rsync -a` never promised them, not because the staging tree lacks them | Confirmed rule (equivalence and metadata bullets) | Requiring xattr and SELinux parity, rejected because it would force `-A` and `-X` onto the rsync command that must stay unchanged; content and symlinks only, rejected because it drops mode and mtime, which both engines already preserve; timestamp normalization, rejected because it changes installed metadata solely for a one-off parity proof |
| Q08 | The equivalence is proved once, by a recipe recorded in the validation plan, reproducing the manifest, normalizing the permitted differences, checking the canary links explicitly, and retaining its output as evidence | Confirmed rule (one-off proof bullet); Acceptance (retained comparison output) | Shipping a comparator, rejected because one usable on the CI agent must itself run inside the host-tool contract this issue is about; folding the check into item 4, rejected because that item answers what the archive carries, not whether two installs agree |
| Q09 | The fallback accepts an absent destination, which it creates, or a real directory, whose content it empties. Anything else observed immediately before deletion fails the mirror step with exit 5 before any entry is removed, and the delete never traverses a destination observed as a symlink. Concurrent replacement of that path is outside this issue | Confirmed rule (destination boundary bullet); Gap item 2; Concrete examples (non-directory and symlinked destination); Acceptance (boundary refusal) | Replacing whatever is there, rejected because it deletes an entry the operator may not have meant to point at; resolving a symlinked destination and mirroring into its target, rejected because the recursive delete would then run somewhere the installer was never given, the exact outcome the boundary exists to prevent |
